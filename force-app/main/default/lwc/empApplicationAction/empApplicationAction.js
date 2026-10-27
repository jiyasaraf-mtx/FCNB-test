import { LightningElement, track, api, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { loadStyle } from "lightning/platformResourceLoader";
import lpiTheme from "@salesforce/resourceUrl/LPI_Design";
import { NavigationMixin } from 'lightning/navigation';


// Static Resources
// import visitRCVApplicableBoards from '@salesforce/label/c.Visit_RCV_Applicable_Board';
 
//Apex Controllers
import getApplicationData from '@salesforce/apex/LPI_ApplicationActionsController.getApplicationData';
import createPARRecord from '@salesforce/apex/LPI_NeedYourAttention.createPARRecord';
import setActionAllowedValidation from '@salesforce/apex/LPI_ApplicationFlowUtility.setActionAllowedValidation';
import getAdobeDocumentLink from '@salesforce/apex/LPI_ApplicationViewController.getAdobeDocumentLink';
import allowResume from '@salesforce/apex/LPI_ApplicationViewController.allowResume';
import { showAsyncErrorMessage } from 'c/lpiUtil';
import {
    buildOmniLwcName,
    resolveOmniLanguageCode
} from 'c/lpLanguageUtils';
import fetchSelectedApplicationRecords from '@salesforce/apex/EMP_DashbaordTableCtrl.fetchSelectedApplicationRecords';
import uploadFile from '@salesforce/apex/EmpDocumentUpload.uploadFile';
//import uploadFileSF from '@salesforce/apex/EmpDocumentUpload.uploadFileSF';




//Static Constants Declaration
const DOWNLOAD_PAYMENT_RECEIPT_URL = '/apex/LPI_PaymentReceiptPDFPage?targetId=';
const DOWNLOAD_APPLICATION_URL = '/apex/LPI_PDFTemplatePage?targetId=';
const NAVIGATION_COMPONENT_NAME = 'omnistudio__vlocityLWCOmniWrapper';
const TYPE_ADOBE_PDF = 'AdobePDF';
const TEMPLATE_NAME = 'templateName';
const ADOBE_MDT_NAME = 'adobePdfMtdName';
const TYPE_RESUMEAPP = 'ResumeApplication';
const TYPE_MAKE_PAYMENT = 'MakePayment';
const TYPE_OVER_MAKE_PAYMENT = 'Overpayment';
const VIEW_VISITS_VIOLATIONS = 'View Inspections & Regulatory Code Violations';
const CRR_HOLD_ERROR = 'We regret to inform you that your License has been put on hold, '+
'therefore you will be unable to submit any new applications at this time. Please contact the board for further information.';
const SUBMIT_REGISTRATION_FORM = 'Submit Registration Form(s)';
const DOWNLOAD_APPLICATION_REVIEW_INFO = 'Download Application/Licensee Review Information';
const DOWNLOAD_APPLICATION_REVIEW_INFO_URL = '/apex/LPI_ApplicationReviewInfoTemplatePage?targetId=';
const APPLICATION_REVIEW_INFO_CASE= 'downloadApplicationReviewInfo';
export default class EmpApplicationAction extends LightningElement {
    @wire(CurrentPageReference)
    currentPageReference;
    @track applicationData = {}
    @track buttonList = [];
    isProcessing = false;
    isPortal = false;
    @api hideDetails = false;
    @api recordId;
    showSpinner = false;
    showLicenseVerificationForm = false;
    licensureVerificationButtonJSON;
    fileData;
    applicationDocId;
    fileName;
    showSubmitButton = false;

    // showVisitRCVRecords = false;
    /**
     * This is Component Connected Callback
     */
    connectedCallback(){
        //Loading CSS
        loadStyle(this, lpiTheme + "/styles/internal-main.css");

        this.fetchSelectedApplicationRecord();
    }



  
fetchSelectedApplicationRecord(){
    fetchSelectedApplicationRecords().then((result) => {
        this.showSpinner = false;
        console.log(' hhhhhhhhh: ', JSON.stringify(result));
        console.log('OUTPUT : ', result);
        console.log('page reference : ', this.currentPageReference.state.name);
        this.applicationNumber = this.currentPageReference.state.name
        
        result.forEach(element => {
                if (element.Name == this.currentPageReference.state.name) {
                        this.applicationData = element
                        console.log('applicationData : ', element);
                    }
                
                });
                console.log('applicationData : ', this.applicationData);
     


    
    }).catch((error)=>{
        console.log(error);
        this.showSpinner = false;
    })
}
    handleUploadFinished(event) {
        const file = event.target.files[0]
        this.fileName = file.name;
        this.showSubmitButton = true;
        var reader = new FileReader()
        reader.onload = () => {
            var base64 = reader.result.split(',')[1]
            this.fileData = {
                'filename': file.name,
                'base64': base64
            }
        }
        reader.readAsDataURL(file)

   }

   handleSubmitClick(){
    console.log('file.name:- '+this.applicationData.Id);
    this.showSpinner = true;
    uploadFile({ fileContent:this.fileName, filename: this.fileName,base64: this.fileData.base64, IndividualApplicationID:this.applicationData.Id}).then((result) => {
        console.log('uploadFinished', result);
        this.applicationDocId = result;
        this.showSubmitButton = false;
        this.showSpinner = false;
        const evt = new ShowToastEvent({
            title: 'SUCCESS',
            message: this.fileName + ' File(s) uploaded successfully',
            variant: 'success',
        });
        this.dispatchEvent(evt);  

        }).catch((error)=>{
            console.log(error);
            this.showSpinner = false;
        })
   }

    /**
     * This method is used to handle the other application actions
     * This method will check setActionAllowedValidation if true, this will navigate to the configured flow after PAR Creation
     * @param {*} event 
     */
    handleOtherActions(event){
        const requestData = this.getRequestData(event);
        this.isProcessing = true;
        setActionAllowedValidation({inputMap: requestData})
            .then(isAllowedToCreatePAR => {
                if(isAllowedToCreatePAR){
                    createPARRecord({
                        inputMap: requestData
                    })
                    .then(launchURL => {
                        //This is only if the actions is called from the license -> Need to Check
                        if(requestData.licenceId){
                            launchURL +='&blId='+this.recordId;
                        }
                        launchURL  += '&type='+requestData.type.toLowerCase()+'&portalUser='+this.isPortal;
                        if(this.isPortal){
                            //Navigation For The Community Portal
                            window.open(launchURL, '_self');
                        }else{
                            //For For The Internal Users
                            const params = this.getURLParams(launchURL);
                            this.handleNavigationInternal(params);
                        }
                    })
                    .catch(error => {
                        this.toastMessage('Error', error , 'error')
                        //alert('Error', error?.body?.message, 'error');
                    })
                    .finally(()=>{
                        this.isProcessing = false;
                    })
                }else{
                    this.isProcessing = false;
                    this.showMessageForInvalidPAR();
                }
            })
            .catch(error => {
                //alert('Error', error?.body?.message, 'error');
                this.toastMessage('Error', error , 'error')
                this.isProcessing = false;
            })
    }

    /**
     * This method is used to create JSON object to check and validate PAR creation
     * @param {*} event 
     * @returns JSON Object 
     */
    getRequestData(event){
        const buttonData = JSON.parse(event.target.dataset.buttonData);
        const data = {};
        if((this.applicationData?.licenceType == 'Embalmer Apprentice' || this.applicationData?.licenceType == 'Funeral Director Apprentice')
            && buttonData.type == 'New'
            && this.applicationData?.EmbalmerFdLicenseId != null){
            data.regAuthId = this.applicationData.EmbalmerFdLicenseId;
        }else{
            data.regAuthId = this.applicationData.licenceTypeId;
        }
        
        data.type = buttonData.type;
        data.amendmentType = buttonData.subType;
        data.accountId = this.applicationData.accountId;
        data.applicationId = this.applicationData.applicationId;
        data.primaryStateOfResidence = this.applicationData?.primaryStateOfResidence;
        if(this.applicationData.licenceId){
            data.blId = this.applicationData.licenceId;
        }
        return data
    }

    /**
     * This method is used to show the Toast Message is PAR creation is not allowed (Application/PAR already existed)
     */
    showMessageForInvalidPAR(){
        if(this.isPortal){
            this.toastMessage('Info', 'The same application has already been submitted or a draft application has been created. Go to My Applications section on Dashboard in order to access it.','info');
        }else{
            this.toastMessage('Info', 'The same application has already been submitted or a draft application has been created. Please check the associated applications to the Account.','info');
        }
    }

    /**
     * This is the helper method to show the toast as per the parameters provided
     * @param {*} title 
     * @param {*} message 
     * @param {*} variant 
     */
    toastMessage(title, message, variant) {
        const toastEvt = new ShowToastEvent({title, message, variant});
        this.dispatchEvent(toastEvt);
    }

    /**
     * This method is used to handle the navigation on configured flow for the internal users
     * @param {*} params 
     */
    handleNavigationInternal(params){
        const requiredState = {
            c__layout: 'lightning',
            c__tabIcon: 'custom:custom18',
            c__tabLabel: 'Apply for license',
            c__accountId: this.applicationData.accountId,
            c__portalUser : this.isPortal,
        };
        const state = Object.assign(requiredState, params);
        this[NavigationMixin.Navigate]({
            type: 'standard__component',
            attributes: {
                componentName: NAVIGATION_COMPONENT_NAME
            },
            state: state
        });
    }

    /**
     * This method is used to get the JSON object of the query params from the String URL
     * @param {*} urlString 
     * @returns 
     */
    getURLParams(urlString){
        const urlParams = new URLSearchParams(new URL(urlString).search);
        const params = {};
        for(const entry of urlParams.entries()) {
            params[`${entry[0]}`] = `${entry[1]}`;
        }
        return params;
    }

    /**
     * This method will redirect to the PDF link in a new window
     * @param {*} buttonDetail 
     * @returns 
     */
    handleAdobePDFAction(buttonDetail){
        this.showSpinner = true;
        const buttonJSON = JSON.parse(buttonDetail.buttonData);
        if(buttonJSON[TEMPLATE_NAME]){
            if(buttonJSON[TEMPLATE_NAME] === 'PR_LicenseVerification'){
                this.showLicenseVerificationForm = true;
                this.licensureVerificationButtonJSON = JSON.parse(buttonDetail.buttonData);
                this.showSpinner = false;
            }else{
                getAdobeDocumentLink({ recordId: this.applicationData.applicationId, mdtName: buttonJSON[ADOBE_MDT_NAME], buttonLabel: buttonDetail.label})
                .then((result) => {
                    if(result !== null && result !== ""){
                        let redirectionUrl = this.base64toBlob(result,'application/pdf');

                        this[NavigationMixin.Navigate]({
                            type: 'standard__webPage',
                            attributes: {
                                url: redirectionUrl
                            }
                        });
                    }else{
                        this.showMessage('Error','Something went wrong!', 'error');
                    }
                })
                .catch((error) => {
                    this.showMessage('Error',error?.body?.message, 'error');
                 })
                .finally(() => {
                    this.showSpinner = false;
                })
            }
        }
    }

    /**
     * This method will redirect to the application flow 
     * @param {*} buttonDetail 
     * @returns 
     */
    handleResumeApplication(buttonDetail){
        this.showSpinner = true;
        //If BL is hold from CRR team
        if(this.applicationData.isCRRHold){
            this.showMessage(
                'Error',
                CRR_HOLD_ERROR,
                'error'
            );
            this.showSpinner = false;
            return;
        }

        //If Payment is pending will not be able to resume application
        allowResume({ applicationId : this.recordId} )
        .then((result) => {
            if(result){
                const buttonJSON = JSON.parse(buttonDetail.buttonData);
                let type = buttonJSON['osType'];
                let subtype = buttonJSON['osSubType'];
                let language = buttonJSON['osLanguage'];
                let omniScriptName = buildOmniLwcName(type, subtype, language);
                this[NavigationMixin.Navigate]({
                    type: "standard__component",
                    attributes: {
                        componentName: "omnistudio__vlocityLWCOmniWrapper"
                    },
                    state: {
                        c__target: "c:" + omniScriptName,
                        c__layout: "lightning",
                        c__tabIcon: "custom:custom18",
                        c__tabLabel: "Apply for license",
                        c__accountId: this.applicationData.accountId,
                        c__ContextId: this.applicationData.licenceTypeId,
                        c__portalUser: "false",
                        c__parid: this.applicationData.parId,
                        c__blId: this.applicationData.licenceId,
                        c__language: resolveOmniLanguageCode()
                    }
                });
            }else{
                const event = new ShowToastEvent({
                    title: 'Error',
                    message: 'Payment Pending Error',
                    variant: 'error',
                });
                this.dispatchEvent(event);
                
            }
            this.showSpinner = false;
        })
        .catch((error) => {
            const event = new ShowToastEvent({
                title: 'Error',
                message: 'Something went wrong! '+ error,
                variant: 'error',
            });
            this.dispatchEvent(event);
            this.showSpinner = false;
        });
    }

    handleMakePayment(buttonDetail,isOverPayment){
        const buttonJSON = JSON.parse(buttonDetail.buttonData);
        const state = {
            c__recordId: buttonJSON['recordId'] || buttonJSON['applicationId'],
            c__applicationId: buttonJSON['applicationId'],
            c__licenseTypeId: buttonJSON['licenseTypeId'],
            c__accId: buttonJSON['accId'],
            c__objectType: buttonJSON['objectType'],
            c__applicationType: buttonJSON['applicationType'],
            c__applicationSubType: buttonJSON['applicationSubType'] || '',
            c__isBadCheckPayment: 'false',
            c__isOverPayment: String(!!isOverPayment)
        };
        if (buttonJSON['regTrxFeeId']) {
            state.c__regTrxFeeId = buttonJSON['regTrxFeeId'];
        }
        this[NavigationMixin.Navigate]({
            type: "standard__component",
            attributes: {
                componentName: "c__lpiPendingPaymentComp"
            },
            state
        });
    }

    showMessage(title,message, variant) {
        const toastEvt = new ShowToastEvent({
            title,
            message,
            variant
        });
        this.dispatchEvent(toastEvt);
    }

    base64toBlob(base64Data, contentType) {
        contentType = contentType || ''; 
        let sliceSize = 1024;
        let byteCharacters = atob(base64Data);
        let bytesLength = byteCharacters.length;
        let slicesCount = Math.ceil(bytesLength / sliceSize);
        let byteArrays = new Array(slicesCount);
    
        for (let sliceIndex = 0; sliceIndex < slicesCount; ++sliceIndex) {
            let begin = sliceIndex * sliceSize;
            let end = Math.min(begin + sliceSize, bytesLength);
    
            let bytes = new Array(end - begin);
            for (let offset = begin, i = 0; offset < end; ++i, ++offset) {
                bytes[i] = byteCharacters[offset].charCodeAt(0);
            }
            byteArrays[sliceIndex] = new Uint8Array(bytes);
        }
        let pdfBlob = new Blob(byteArrays, { type: contentType });
        // Create a blob URL for the PDF
        const pdfUrl = URL.createObjectURL(pdfBlob);
        return pdfUrl;
    }

    closeVerificationModal(){
        this.showLicenseVerificationForm = false;
    }
    handleSubmitRegistrationForm(event) {
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: 'Submit_Registration_Form__c'
            },
            state: {
                recordId : this.applicationData.applicationId
            }
        });
    }
}