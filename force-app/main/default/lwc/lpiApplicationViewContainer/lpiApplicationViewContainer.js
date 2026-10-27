import {LightningElement,track,wire,api} from 'lwc';
import {CurrentPageReference} from 'lightning/navigation';
 import {ShowToastEvent} from 'lightning/platformShowToastEvent';
 import getApplicationData from '@salesforce/apex/LPI_ApplicationViewController.getApplicationData'
 import checkLicenseeModification from '@salesforce/apex/LPI_ApplicationViewController.checkLicenseeModification'
 import createPARRecord from '@salesforce/apex/LPI_NeedYourAttention.createPARRecord'
 import setActionAllowedValidation from '@salesforce/apex/LPI_ApplicationFlowUtility.setActionAllowedValidation'
import validateApplicationForEnotify from '@salesforce/apex/LPI_ApplicationViewController.validateLicenseFromENotifyService'
import getAdobeDocumentLink from '@salesforce/apex/LPI_ApplicationViewController.getAdobeDocumentLink'

import {NavigationMixin} from 'lightning/navigation';
 import lpiTheme from "@salesforce/resourceUrl/LPI_Design";
 import { loadStyle } from "lightning/platformResourceLoader";
 const LICENSE_ACTIONS_RNLPN = ['Renewal', 'Reinstatement'];
 const BUTTON_TYPE_WEB_LINK = 'weblink';
 const TYPE_ADOBE_PDF = 'AdobePDF';
 //const TEMPLATE_NAME = 'templateName';
 const ADOBE_MDT_NAME = 'adobePdfMtdName';
 const WEB_LINK_KEY = 'url';
 const AUDIT_BUTTONS = 'AuditButton';
 //added by neeraj mani sai S-51784 -- Start
 import getSchoolRelatedStudentApplications from '@salesforce/apex/LPI_ApplicationViewController.getSchoolRelatedStudentApplications'
 const COLOUMNS =  [
    {label : 'SNo.', fieldName : 'sNo'},
    {label : 'Application Number', fieldName : 'Name', wrapText: true},
    {label : 'Student Name', fieldName : 'studentName', wrapText: true},
    {label : 'License Type', fieldName : 'licenseTypeName', wrapText: true},
    {label : 'Submission Date', fieldName : 'studentAppliedDate', wrapText: true},
    {label : 'Status', fieldName : 'Status__c', wrapText: true},
    {label : 'Actions', fieldName : ''}
    ];
 //added by neeraj mani sai S-51784 -- End
 //Added by Adarsh Singh S-52881  Bad Check Functionality -- Start 
 import fetchBLBadCheck from '@salesforce/apex/LPI_ApplicationFlowUtility.fetchBLBadCheck'
 //Added by Adarsh Singh S-52881  Bad Check Functionality -- End
 import visitRCVApplicableBoards from '@salesforce/label/c.Visit_RCV_Applicable_Board';
 //added by neeraj mani sai S-45809 -- Start
 import {getPicklistValues,getObjectInfo} from 'lightning/uiObjectInfoApi';
 import ADDRESS_OBJECT from '@salesforce/schema/Address';
 import AddressState from '@salesforce/schema/Address.StateCode';
 import AddressCountry from '@salesforce/schema/Address.CountryCode';
 import getBranchAddressDetails from '@salesforce/apex/LPI_ApplicationViewController.getBranchAddressDetails'
 import saveBranchAddressDetails from '@salesforce/apex/LPI_ApplicationViewController.saveBranchAddressDetails'
 import removeExistingAddress from '@salesforce/apex/LPI_ApplicationViewController.removeExistingAddress'
 import getMOCountyValues from '@salesforce/apex/LPI_ApplicationViewController.getMOCountyValues'
 //added by neeraj mani sai S-45809 -- End
 // S-55551 Added By Mahesh 
 //import getAuditButton from '@salesforce/apex/MODPR_ApplicationViewController.getAuditButton'
 //Start - Added by Nitish (S-56015)
 import NursingLicenseDownloadLink from '@salesforce/label/c.Nursing_License_Download_License_Link';
 //End - Added by Nitish (S-56015)
 
 export default class LpiApplicationViewContainer extends NavigationMixin(LightningElement) {
    @wire(CurrentPageReference)
    currentPageReference;
    @track jsonData = [];
    @track buttonData = [];
    showModal = false;
    showButtons = false;
    modalHeaderTitle = '';
    @track childButtonList = [];
    type = '';
    subtype = '';
    regId;
    accId;
    showSpinner = false;
    isPortal = false;
    @track extraUrlParams;
    @track childofChildList = {};
    showChildOfchild = false;
    @track childOfchildOption = [];
    childHeadingValue = '';
    childValue = '';
    @track childValueMap = {};
    statusCode=null;
    showEnotifyModal = false;
    @track requestData = {};
    modalDescription = '';
    busLicenseId = '';
    busLicesnNumber = '';
    showErrorForNoLicense = false;
    // added by neeraj mani sai S-51784 -- Start
    @track studentsData;
    columns = COLOUMNS;
    isStudentDataAvailable = false;
    licenseNotPresentError =  'Loading License Detail..';
    //added by neeraj mani sai S-51784 -- End
    //added by neeraj mani sai S-45809 -- Start
    patternObj = {
		text: "^((?!(<)|(>)).)*$",
		zipCode: "^[0-9]{5}(?:-[0-9]{4})?$",
        phone: '^(\\([0-9]{3}\\) |[0-9]{3}-)[0-9]{3}-[0-9]{4}$'
	};
    @track addressDataObj = {country:'US', state: 'MO'};
    showAddressModal = false;
    showAddOrRemoveAddressButtons = false;
    showAddAddressModal = false;
    showRemoveExistingAddressModal = false;
    showVisitRCVRecords = false;
    showPharmacyReportForm = false;
    addressModalLabel = ''
    @track stateOptions = [];
    @track countryOptions = [];
    @track licenseType = '';
    showAuditDetailsButton = false;
    auditButtonId;
    auditButtonName;
    @track auditDetailButtonList = [];
    @track auditDetailObj = {};
    //Start - Added by Nitish (S-56015)
    showNursingDownloadModal = false;
    //End - Added by Nitish (S-56015)
    licenseeModification = false;
    headerNotifyMsg = '';
    // BusinessLicenseId = '0cEWF00000000WH2AY';


    // GET OBJECT INFO
    @wire(getObjectInfo, {
        objectApiName: ADDRESS_OBJECT
    }) objectInfo;
    @wire(getPicklistValues, {
        recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: AddressCountry
    }) wiredCountryPicklistValues({
        error, data
    }){ if (data && data.values) {
            this.countryOptions = data.values;
        }
    }
    @wire(getPicklistValues, {
        recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: AddressState
    }) wiredStatePicklistValues({
        error, data
    }){ if (data && data.values) {
            this.stateOptions = data.values;
        }
    }
    get isAddressCountryUS(){
        let temp = this.addressDataObj.country && this.addressDataObj.country === 'US' ? true : false;
        return temp;
    }
    get isStateMO(){
        let temp = this.addressDataObj.state && this.addressDataObj.state === 'MO' ? true : false;
        return temp;
    }
    branchAddresslist;
    isRemoveBranchAddressDataFound = false;
    @track removeAddressLocIdsList = [];
    picklistOrdered;
    searchResults;
    selectedSearchResult;
    selectedCountyValue;
    //added by neeraj mani sai S-45809 -- End
    enotifyMessageText = '';

    get isColourRed() {
        return this.statusCode === 0;
    }
    get isColourGreen() {
        return this.statusCode === 2;
    }
    get isColourYellow() {
        return this.statusCode === 1;
    }
    get isError() {
        return this.statusCode === -1;
    }

    get getModalTitle() {
        return (this.isColourGreen?'Green Status':this.isColourRed?'Red Status':'Yellow Status');
    }

    get selectedValue() {
        return this.selectedSearchResult ? this.selectedSearchResult.label : null;
    }
    _recordId;
    @api 
    set recordId(value) {
        this.showSpinner = true;
        this._recordId = value;
        this.getApplicationData();
    }
    get recordId() {
        return this._recordId;
    }
    getApplicationData(){
        this.showErrorForNoLicense = false;
        let visitRCVBoardList = visitRCVApplicableBoards.split('@');
        getApplicationData({
            blId : this.recordId,
            blNumber : this.busLicesnNumber,
            isCCRActions: false
        }).then(data =>{
                if(data != null){
                    this.regId = data.regId;
                    this.accId = data.accId;
                    this.busLicenseId = data.blId;
                    this.jsonData = JSON.parse(JSON.stringify(data.dataList));
                    this.buttonData = JSON.parse(JSON.stringify(data.buttonList));
                    if(this.buttonData.length > 0){
                        this.showButtons = true;
                        if(true){
                            this.buttonData.forEach(test => {
                                //S-57250 - added by Ankur
                                test.buttonLable = this.titleCase(test.buttonLable);
                            });
                        }
                        if (data.licenseType === 'Temp Permit - BEHIS') {
                            this.buttonData.forEach(ele => {
                                if (ele.buttonLable === 'Renew') {
                                    ele.buttonLable = 'Extension';
                                }
                            });
                        }
                    }
                    else{
                        this.showButtons = false;
                    }
                    this.showSpinner = false;
                    if(data.boardName === 'Healing Arts'){ //45809
                        this.showAddOrRemoveAddressButtons = true; //45809
                    } else if(visitRCVBoardList.includes(data.boardName)) {
                        this.showVisitRCVRecords = true;
                    }
                    //added for S-43410 - Sukanya
                    if(data.boardName === 'Pharmacy' && this.isPortal){
                        this.showPharmacyReportForm = true;
                    }
                }else{
                    this.showErrorForNoLicense = true;
                    this.licenseNotPresentError = 'You have provided Invalid Licesne Number!!';
                    this.showSpinner = false;
                }
        }).catch((error) => {
            this.showMessage('Error', error?.body?.message, 'error');
            this.showSpinner = false;
        })
    }
    connectedCallback() {
        if(this.currentPageReference.attributes.name != 'Renew_License_Details__c'){
            loadStyle(this, lpiTheme + "/styles/internal-main.css");
            
            console.log("true");
        }
        this.showSpinner = true;
        if (`${this.currentPageReference.state.blId}` != 'undefined') {
            this.isPortal = true;
            this.recordId = `${this.currentPageReference.state.blId}`;
            this.checkLicenseeModification();
            this.getApplicationData();
        }else{
            if (`${this.currentPageReference.state.blNumber}` != 'undefined') {
                this.isPortal = true;
                this.busLicesnNumber = `${this.currentPageReference.state.blNumber}`;
                this.recordId = '';
                this.checkLicenseeModification();
                this.getApplicationData();
            }
        }
        getMOCountyValues().then((result) => {
            this.picklistOrdered = result.map(({value: label, key: value}) => ({ label,value}))
            this.picklistOrdered = this.picklistOrdered.sort((a,b)=>{
                if(a.label < b.label){
                    return -1
                }
            })
        })
    } 
    //S-57250 - added by Ankur
    titleCase(str) {
        var splitStr = str.split(' ');
        for (var i = 0; i < splitStr.length; i++) {
            if(splitStr[i].length >3){
                splitStr[i] = splitStr[i].charAt(0).toUpperCase() + splitStr[i].substring(1);  
            }
               
        }
        return splitStr.join(' '); 
     }
    checkLicenseeModification(){
        checkLicenseeModification({
            blId : this.recordId
        }).then(result =>{
            if(result === true)
            {
                this.licenseeModification = true;
            }else{
                this.licenseeModification = false;
            }
        })
        .catch((error) => {
            this.showMessage('Error', error?.body?.message, 'error');
            this.showSpinner = false;
        })

    }
    handleButtton(event) {
        this.showSpinner = true;
        this.extraUrlParams = event.target.dataset.name;
        if (this.type != '') {
            if (this.subtype === '' || (this.showChildOfchild && this.childValue === '')) {
                this.showSpinner = false;
                this.showMessage('Error', 'Select Required Value!', 'error');
            } else {
                this.getButtonProperties(null);
            }
        } else {
            let index = event.target.dataset.id;
            let buttonDetail = this.buttonData[index];
            console.log('>>>Button type/NAme ',buttonDetail.buttonName,' >>> ',JSON.stringify(buttonDetail));
            this.type = buttonDetail.buttonName;
            if (buttonDetail.hasChild) {
                this.showSpinner = false;
                this.showModal = true;
                this.showChildOfchild = false;
                this.childValue = '';
                this.childValueMap = {};
                this.modalHeaderTitle = 'Select ' + this.type + ' Type';
                let tempArr = [];
                this.childHeadingValue = '';
                let tempData = {};
                buttonDetail.childButton.forEach(function (arrayItem) {
                    tempArr.push({
                        label: arrayItem.buttonLable === 'Change of Interim Designated Incharge'? 'Designate Interim Person In Charge (PIC)' : arrayItem.buttonLable,
                        value: arrayItem.buttonName
                    });
                    if(arrayItem.hasChild){
                        let tempArr1 = [];
                        arrayItem.childButton.forEach(function (arrayItem1) {
                            tempArr1.push({
                                label: arrayItem1.buttonLable,
                                value: arrayItem1.buttonName
                            });
                        });
                        tempData[arrayItem.buttonName] = {listOfChildItem : tempArr1,headingLabel : arrayItem.headingLabel};
                    }
                });
                this.childButtonList = tempArr;
                this.childofChildList = tempData;
            } else {
                if(this.type.toLocaleLowerCase() === BUTTON_TYPE_WEB_LINK){
                    this.handleLinkButton(buttonDetail);
                }else if(this.type === TYPE_ADOBE_PDF){
                    if(this.isSiteCom()){
                        window.open('https://lpi-psf-core--widpi.sandbox.my.site.com/s/download-license?BusinessLicenseId='+this.busLicenseId,'_blank');
                    }else{
                        window.open('https://lpi-psf-core--widpi.sandbox.lightning.force.com/lightning/cmp/omnistudio__vlocityLWCOmniWrapper?c__target=c:docGenCertificateGenerationEnglish&c__layout=lightning&c__tabIcon=custom:custom18&c__tabLabel=LPI_CertificateGeneration&c__BusinessLicenseId='+this.busLicenseId,'_blank');
                        // window.open('https://mtx-lpi-psf-core--lpicoredev.sandbox.lightning.force.com/lightning/cmp/omnistudio__vlocityLWCOmniWrapper?c__target=c:lPICertificateGenerationEnglish&c__layout=newport&c__tabIcon=custom:custom18&c__tabLabel=LPI Certificate Generation&c__BusinessLicenseId='+this.busLicenseId,'_blank');
                        //window.open('https://mtx-lpi-psf-core--lpicoredev.sandbox.lightning.force.com/lightning/cmp/omnistudio__vlocityLWCOmniWrapper?c__target=c:lPIDOCGENEnglish&c__layout=lightning&c__tabIcon=custom:custom18&c__tabLabel=LPI_PDFGen&c__BusinessLicenseId='+this.busLicenseId,'_blank');
                    }
                    this.showSpinner = false;
                //    this.handleAdobePDFAction(buttonDetail);
                    
                }else if(this.type === AUDIT_BUTTONS){
                    this.handleAuditDetails(buttonDetail);
                }
                else{
                    this.getButtonProperties(null);
                }
            }
        }
    }

    isSiteCom() {
        const currentUrl = window.location.href;
        return currentUrl.toLowerCase().indexOf('site.com') !== -1;
    }
    handleChangeSubType(event) {
        this.subtype = event.target.value;
        if(this.childofChildList[this.subtype] !== undefined){
            this.childValue = '';
            this.showChildOfchild = true;
            this.childOfchildOption = this.childofChildList[this.subtype].listOfChildItem;
            this.childHeadingValue = this.childofChildList[this.subtype].headingLabel;
        }else{
            this.childValue = '';
            this.showChildOfchild = false;
        }
    }
    handleChildChangeType(event){
        this.childValue = event.target.value;
        let tempChild = {};
        tempChild[this.subtype]=event.target.value;
        this.childValueMap = tempChild;
    }


    getFormattedDate(date) {
        let year = date.getFullYear();
        let month = (1 + date.getMonth()).toString().padStart(2, '0');
        let day = date.getDate().toString().padStart(2, '0');
      
        return month + '/' + day + '/' + year;
    }

    getButtonProperties(event) {
        let data;
        if (this.subtype === '') {
            this.subtype = this.type;
        }
        if (event !== null && event.detail !== null && event.detail !== undefined) {
            this.showSpinner = true;
            data = JSON.parse(JSON.stringify(event.detail));
            //data = JSON.parse(data);
            data['regAuthId'] = this.regId;
            data['blId'] = this.busLicenseId;
            this.type = data['type'];
            this.subtype = data['amendmentType'];
            data['changeStatusAmendmentSubType'] = this.childValueMap['Change status to other status'] !== undefined ? this.childValueMap['Change status to other status'] : null;
            data['additionalLicenseType'] = this.childValueMap['Obtain Additional License'] !== undefined ? this.childValueMap['Obtain Additional License'] : null;
            if(!this.isPortal){
                data['accountId'] = this.accId;
            }
        } else {
            //Start logic for buttonjsonData
            if(this.extraUrlParams != '' && this.extraUrlParams != undefined){
                data = JSON.parse(JSON.stringify(this.extraUrlParams));
                data = JSON.parse(data);
                data['regAuthId'] = this.regId;
                data['type'] = this.type;
                data['amendmentType'] = this.subtype;
                data['blId'] = this.busLicenseId;
                data['changeStatusAmendmentSubType'] = this.childValueMap['Change status to other status'] !== undefined ? this.childValueMap['Change status to other status'] : null;
                data['additionalLicenseType'] = this.childValueMap['Obtain Additional License'] !== undefined ? this.childValueMap['Obtain Additional License'] : null;
                if(!this.isPortal){
                    data['accountId'] = this.accId;
                }
            }else{
                data = {
                    regAuthId : this.regId,
                    type : this.type,
                    amendmentType : this.subtype,
                    blId : this.busLicenseId,
                    changeStatusAmendmentSubType: this.childValueMap['Change status to other status'] !== undefined ? this.childValueMap['Change status to other status'] : null,
                    additionalLicenseType: this.childValueMap['Obtain Additional License'] !== undefined ? this.childValueMap['Obtain Additional License'] : null,
                    accountId : this.isPortal ? null : this.accId
                }
            }
        }

        //This statement is added for RN and LPN License Types to Validate the License from E-Notify Validation API
        //This is applicable only to "Renew" and "Reinstatement" actions
        if(LICENSE_ACTIONS_RNLPN.includes(this.type)){
            this.showSpinner = true;
            validateApplicationForEnotify({
                blId : this.busLicenseId
            })
            .then(result => {
                if(result.isValidated) {
                    this.statusCode = result.status;
                    this.showEnotifyModal = true;
                    this.showSpinner = false;
                    this.requestData = data;
                    this.headerNotifyMsg = result.headerNotifyMsg;
                    // Added Enotify Message By piyush aneja for S-52726 - Started
                    // Assign the message values to the respective properties - Piyush aneja
                    this.enotifyMessageText = result.message;
                    // Added Enotify Message By piyush aneja for S-52726 - Ended
                }else{
                    this.handleAction(data);
                }
            })
            .catch(error => {
                this.showMessage('Error', error?.body?.message, 'error');
                this.showSpinner = false;
            })
        }else{
            this.handleAction(data);
        }
    }
    handleAction(data){
        this.showSpinner = true;
        console.log('fetched data',JSON.stringify(data));
        fetchBLBadCheck({
            inputMap: data
        }).then(badCheck =>{
            if(badCheck){
                this.showMessage('Error', 'We regret to inform you that your License has been put on hold, therefore you will be unable to submit any new applications at this time. Please contact the board for further information.','error');
                this.showSpinner = false;
            } else {
                setActionAllowedValidation({
                    inputMap: data
                })
                .then(result => {
                    if (result) {
                        createPARRecord({
                                inputMap: data
                            })
                            .then(result => {
                                result = result + '&blId='+this.busLicenseId+'&type='+this.type.toLowerCase()+'&portalUser='+this.isPortal;
                                if(data.hasOwnProperty('lateRenewal')){
                                    result = result + '&lateRenewal='+data['lateRenewal'];
                                }
                                this.type = '';
                                this.subtype = '';
                                this.modalHeaderTitle = '';
                                this.showModal = false;
                                this.showSpinner = false;
                                if (!this.isPortal) {
         
         
                                    const myUrlSplit = result.split("&");
                                    let target = '';
                                    let c__ContextId = '';
                                    let c__parid = '';
                                    let lateRenewal = '';
                                    let c__type = '';
                                    myUrlSplit.forEach(element => {
                                        let paramSplit = element.split("=");
                                        if (paramSplit[0] === 'c__target') {
                                            target = paramSplit[1];
                                        } else if (paramSplit[0] === 'ContextId') {
                                            c__ContextId = paramSplit[1];
                                        } else if (paramSplit[0] === 'c__parid') {
                                            c__parid = paramSplit[1];
                                        }else if (paramSplit[0] === 'lateRenewal') {
                                            lateRenewal = paramSplit[1];
                                        }else if (paramSplit[0] === 'type') {
                                            c__type = paramSplit[1];
                                        }
                                    });
                                    this[NavigationMixin.Navigate]({
                                        type: 'standard__component',
                                        attributes: {
                                            componentName: 'omnistudio__vlocityLWCOmniWrapper'
                                        },
                                        state: {
                                            c__target: target,
                                            c__layout: 'lightning',
                                            c__tabIcon: 'custom:custom18',
                                            c__tabLabel: 'Apply for license',
                                            c__ContextId: c__ContextId,
                                            c__parid: c__parid,
                                            c__blId : this.busLicenseId,
                                            c__type : c__type,
                                            c__lateRenewal : lateRenewal,
                                            c__portalUser : this.isPortal,
                                            c__accountId : this.accId
                                        }
                                    })
                                } else {
                                    window.open(result, '_self');
                                }
                            })
                            .catch(error => {
                                this.showMessage('Error', error?.body?.message, 'error');
                                this.showSpinner = false;
                            });
                    } else {
                        if(this.isPortal){
                            this.showMessage('Info', 'The same application has already been submitted or a draft application has been created. Go to My Applications section on Dashboard in order to access it.','info');
                        }else{
                            this.showMessage('Info', 'The same application has already been submitted or a draft application has been created. Please check the associated applications to the Account.','info');
                        }
                        this.showSpinner = false;
                    }
                })
                .catch(error => {
                    this.showMessage('Error', error?.body?.message, 'error');
                    this.showSpinner = false;
                });
            }
        })
        .catch(error => {
            this.showMessage('Error', error?.body?.message, 'error');
            this.showSpinner = false;
        });
    }

    handleENotifyModalOnClose(event) {
        if(event.target.name && event.target.name === "confirm"){
            if(this.isColourGreen){
                this.handleAction(this.requestData);
            }
            this.showEnotifyModal = false;
        } else{
            this.showEnotifyModal = false; 
        }
    }
 
    hideModalBox() {
        this.showModal = false;
        this.type = '';
        this.subtype = '';
    }
    showMessage(title,message, variant) {
        const toastEvt = new ShowToastEvent({
            title,
            message,
            variant
        });
        this.dispatchEvent(toastEvt);
    }
    handleLinkButton(buttonDetail){
        const linkDetails = JSON.parse(buttonDetail.buttonJSONData);
        if(linkDetails[WEB_LINK_KEY]){
            this[NavigationMixin.Navigate]({
                type: 'standard__webPage',
                attributes: {
                    url: linkDetails[WEB_LINK_KEY]
                }
            });
            this.showSpinner = false;
        }
        this.type = '';
    }
    handleViewVisits(event) {        
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: 'Visits_regulatory_code_violation__c'
            },
            state: {
                recordId : this.recordId
            }
        });
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


    handleAdobePDFAction(buttonDetail){
        const buttonJSON = JSON.parse(buttonDetail.buttonJSONData);
        //Start - Added by Nitish (S-56015)
        if(buttonJSON.IsNursing !== undefined && buttonJSON.IsNursing === 'true'){
            this.showNursingDownloadModal = true;
            this.showSpinner = false;
            //End - Added by Nitish (S-56015)
        } else{
            if(buttonJSON[ADOBE_MDT_NAME]){
                getAdobeDocumentLink({ recordId: this.busLicenseId, mdtName: buttonJSON[ADOBE_MDT_NAME],buttonLabel : buttonDetail.buttonLable})
                .then((result) => {
                    //Added By Piyush Aneja for S-63281 development
                    if (buttonJSON.isSalesforceConfigured === 'true' && result !== null && result !== "") {
                        window.open(result, '_blank'); // Open the link in a new tab
                    } else if(result !== null && result !== ""){
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
                    this.showSpinner = false;
                })
                .catch((error) => {
                    this.showMessage('Error',error?.body?.message, 'error');
                    this.showSpinner = false;
                });
            }
            this.type = '';
        }
    }
    
    handlePharmacyReportForm(event) {
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: 'Pharmacy_Reporting_Form__c'
            },
            state: {
                recordId : this.recordId
            }
        });
    }
    //added by Neeraj Mani Sai  S-51784 -- start
    @wire(getSchoolRelatedStudentApplications, {
        blId: '$recordId',
        blNumber : '$busLicesnNumber'
    })
    getSchoolRelatedStudentApplications(value) {
        if(value){
            const { data,error } = value;
            if (data) {
                if(data.length > 0){
                    this.isStudentDataAvailable = true;
                    this.studentsData = data.map((studentDataRow, index)=>{
                        return{...studentDataRow, studentName: studentDataRow.Account.Name, sNo : index+1,
                            licenseTypeName : studentDataRow.LicenseType.Name,
                            studentAppliedDate: this.getFormattedDate(new Date(studentDataRow.AppliedDate)),
                            appUrl : studentDataRow.SavedApplicationRef.ViewApplicationURL__c}
                    })
                }
                this.showSpinner = false;
            } else if (error) {
                this.showMessage('Error', error?.body?.message, 'error');
                this.showSpinner = false;
            }
        }else{
            this.showMessage('Error','Something went wrong!', 'error');
            this.showSpinner = false;
        }
    };

    handleSchoolRelatedStudentApplicationRowAction(event){
        if(this.isPortal){
             this[NavigationMixin.Navigate]({
                "type": "standard__webPage",
                "attributes": {
                    "url": window.location.origin +event.target.dataset.appurl,
                }
            });
        }else {
            this[NavigationMixin.Navigate]({
                "type": "standard__recordPage",
                "attributes": {
                    "recordId": event.target.dataset.id,
                    actionName: 'view'
                }
            });
        }
    }
    //added by Neeraj Mani Sai S-51784 -- End
    handleClickBackDashbaord(){
        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                pageName: 'home'
            },
        });
    }
    //added by neeraj mani sai S-45809 -- Start
    handleAddOrRemoveAddressButton(event){        
        this.showSpinner = true;
        this.showAddressModal = true;
        this.addressModalLabel = event.target.label;
        if(event.target.label === 'Add an Additional Address'){
            this.showAddAddressModal = true;
            this.showRemoveExistingAddressModal = false;
            this.showSpinner = false;
            //S-57276 added by Vamshi
            setTimeout(() => {
                this.focusFirstEle();
                this.clearSearchResults();
            }, 200);
        }else if(event.target.label === 'Remove Existing Address'){
            this.showAddAddressModal = false;
            this.showRemoveExistingAddressModal = true;
            getBranchAddressDetails({blId : this.busLicenseId})
            .then((result) => {
                this.showSpinner = false;
                if(result.length > 0){
                    this.isRemoveBranchAddressDataFound = true;
                    this.branchAddresslist = result.map((branchRow, index) => {
                        return {...branchRow,branchNumName : 'Branch Address '+(index+1).toString().padStart(2, '0')}
                    });
                }else{
                    this.isRemoveBranchAddressDataFound = false;
                }
            })
            .catch((error) => {
                this.showSpinner = false;
                this.showMessage('Error', error?.body?.message, 'error');
            });
            //S-57276 added by Vamshi
            setTimeout(() => {      
                this.focusFirstEle(); 
                this.clearSearchResults();
            }, 200);
        }
    }

    handleCloseAddOrRemoveAddressButton(){
        this.showAddressModal = false;
        if(this.showAddAddressModal == true){
            this.template.querySelector('.addAdditionBtn').focus();
            this.showAddAddressModal = false;            
        }else if(this.showRemoveExistingAddressModal == true){
            this.template.querySelector('.removeBtn').focus();
            this.showRemoveExistingAddressModal = false;            
        }      
    }
    handleAddressInputChanges(event){
        this.addressDataObj[event.target.name] = event.target.value;
        this.addressDataObj.state = 
        this.addressDataObj.state && this.isAddressCountryUS ? this.addressDataObj.state : null;
        if(event.target.name === 'telephoneNum'){
            var numbers = event.target.value.replace(/\D+/g, "");
            let teleValue = "";
            for (var i = 0; i < numbers.length; i++) {
                if(i === 0){
                    teleValue += '('+ numbers[i];
                }else if(i === 3){
                    teleValue += ') '+ numbers[i];
                }else if(i === 6){
                    teleValue += '-'+ numbers[i];
                }else{
                    teleValue += ''+ numbers[i];
                }
            }
            this.addressDataObj[event.target.name] = teleValue;
        }else if(event.target.name === 'RemoveCheckBox'){
            this.removeAddressLocIdsList = [...this.template.querySelectorAll('.removeCheckbox')]
            .filter(element => element.checked)
            .map(element => element.dataset.id);
        }
    }
    handleAddressContinueButton() {
        if (this.isInputValid() && this.addressModalLabel === 'Remove Existing Address') {
            if (this.removeAddressLocIdsList.length > 0) {
                this.showSpinner = true;
                this.handleCloseAddOrRemoveAddressButton();
                removeExistingAddress({
                        branchAddressList: JSON.stringify(this.removeAddressLocIdsList)
                    })
                    .then(result => {
                        this.showSpinner = false;
                        this.showMessage('Success', 'Your Address details have been updated in our records', 'success');
                        setTimeout(() => {
                            location.reload(), 9000
                        });
                    }).catch(error => {
                        this.showSpinner = false;
                        this.showMessage('Error', error?.body?.message, 'error');
                    })
            } else {
                this.showMessage('Error', 'Please select atleast one Branch Address to Continue', 'error');
                // eslint-disable-next-line @lwc/lwc/no-async-operation
                setTimeout(() => {
                    this.setFocusOnFirstBranchAddress();
                }, 2000);
            }
        } else if (this.isInputValid() && this.addressModalLabel === 'Add an Additional Address') {
            this.showSpinner = true;
            this.addressDataObj.telephoneNum = this.addressDataObj.telephoneNum ?
                this.addressDataObj.telephoneNum.replace(/[^\d]/g, "") :
                this.addressDataObj.telephoneNum;
            if (this.isStateMO && (this.selectedCountyValue === undefined ||
                    this.addressDataObj.countyLookup !== this.selectedCountyValue)) {
                this.showSpinner = false;
                this.showMessage('Error', 'Please select valid County', 'error');
            } else {
                this.handleCloseAddOrRemoveAddressButton();
                saveBranchAddressDetails({
                    blId: this.busLicenseId,
                    accId: this.accId,
                    branchDataObj: JSON.stringify(this.addressDataObj),
                    locationType: 'Branch'
                }).then(result => {
                    this.showSpinner = false;
                    this.showMessage('Success', 'Your Address details have been updated in our records', 'success');
                    setTimeout(() => {
                        location.reload(), 9000
                    });
                }).catch(error => {
                    this.showSpinner = false;
                    this.showMessage('Error', error?.body?.message, 'error');
                })
            }
    
        }
    }
    renderedCallback() {
        this.setFocusOnFirstBranchAddress();
        }
    
    setFocusOnFirstBranchAddress() {
        const firstCheckbox = this.template.querySelector('.removeCheckbox');
        if (firstCheckbox) {
            firstCheckbox.setAttribute('tabindex', '0');
            firstCheckbox.focus();
        }
    }

    isInputValid() {
        let isValid = true;
        let inputFields = this.template.querySelectorAll('.validate');
        let errorFields = [];
        inputFields.forEach(inputField => {
            if(!inputField.checkValidity()) {
                inputField.reportValidity();
                isValid = false;
                errorFields.push(inputField);
            }
        });
        //S-57276 Added by Vamshi
        if(errorFields.length>=1){
            errorFields[0].focus();
        }
        return isValid;
    }
    search(event){
        const input = event.detail.value.toLowerCase();
        if (input.length >= 1){
            const result = this.picklistOrdered.filter((picklistOption) =>
            picklistOption.label.toLowerCase().includes(input)
            );
            this.addressDataObj.countyLookup = event.target.value;
            this.searchResults = result;      
        }else {
            this.clearSearchResults()
        }
    }
    selectSearchResult(event) {
        const selectedValue = event.currentTarget.dataset.name;   
        this.selectedSearchResult = this.picklistOrdered.find(
          (picklistOption) => picklistOption.label === selectedValue
        );
        this.selectedCountyValue = selectedValue;
        this.addressDataObj.countyLookup = this.selectedCountyValue;
        this.clearSearchResults();
    }    

    clearSearchResults() {
    this.searchResults = null;
    }
    //added by neeraj mani sai S-45809 -- End
    //Start - Added by Nitish (S-56015)
    handleNursingDownloadProceed(){
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: NursingLicenseDownloadLink
            }
        });
        this.showNursingDownloadModal = false;
        this.showSpinner = false;
        this.type = '';
        this.subtype = '';
    }
    closeNursingModal(){
        this.showNursingDownloadModal = false;
        this.type = '';
        this.subtype = '';
    }
    //End - Added by Nitish (S-56015)

    // S-55551 Added By Mahesh
    handleAuditDetails(buttonDetail){
        const buttonJSON = JSON.parse(buttonDetail.buttonJSONData);
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: 'Audit_Details__c'
            },
            state: {
                audId : buttonJSON.audId
            }
        });
    }
    //S-57276 Added by Vamshi - Start
    handleEscKeyDown(event) {
        if (event.code === 'Escape' || event.keyCode === 27) {
            this.handleCloseAddOrRemoveAddressButton();
        }
    }
    focusFirstEle() {
		const focusableElements = 'button, lightning-input, lightning-combobox';
		const modal = this.template.querySelector('.slds-modal');
		const firstFocusableElement = modal.querySelectorAll(focusableElements)[0];
		const focusableContent = modal.querySelectorAll(focusableElements);
		const lastFocusableElement = focusableContent[focusableContent.length - 1];
		firstFocusableElement.focus();
		this.template.addEventListener('keydown', function (event) {
			let isTabPressed = event.key === 'Tab' || event.keyCode === 9;
			if (!isTabPressed) {
				return;
			}
			if (event.shiftKey) {
				if (this.activeElement === firstFocusableElement) {
					lastFocusableElement.focus();
					event.stopPropagation()
					event.preventDefault();
				}
			} else {
				if (this.activeElement === lastFocusableElement) {
					firstFocusableElement.focus();
					event.preventDefault();
					event.stopPropagation()
				}
			}
		});
	}
    //S-57276 Added by Vamshi - End

    //focus on the lookup dropdown list 

    preventFocusLosing(event) {
        // Stops the Typeahead input element from losing focus so that a user can use the scroll bar in the list
        event.preventDefault();
      }
     selectedItemIndex = -1;

     setFocus(index) {
         const listItems = Array.from(this.template.querySelectorAll('.slds-listbox__item'));

         if (listItems.length > 0 && index >= 0 && index < listItems.length) {
             const selectedItem = listItems[index];
             if (selectedItem) {
                 listItems.forEach(item => {
                     //reset everything
                     item.style.border = 'none';
                     item.style.backgroundColor = 'transparent';
                     item.setAttribute('aria-selected', 'false');
                 });

                 // Applying visual indication to the focused item
                 selectedItem.style.border = '1px solid blue';
                 selectedItem.style.backgroundColor = 'lightgray';
                 selectedItem.scrollIntoView({ behavior: 'smooth', block: 'nearest', inline: 'start' });
                 selectedItem.focus();
             }
         }
     }

     handleKeyDown(event) {
         const listItems = Array.from(this.template.querySelectorAll('.slds-listbox__item'));
         if (listItems.length > 0) {
             if (event.keyCode === 38) {
                 this.selectedItemIndex = Math.max(this.selectedItemIndex - 1, 0);
                 this.setFocus(this.selectedItemIndex);
                 event.stopPropagation()
                 event.preventDefault();
             } else if (event.keyCode === 40) {
                 this.selectedItemIndex = Math.min(this.selectedItemIndex + 1, listItems.length - 1);
                 this.setFocus(this.selectedItemIndex);
                 event.stopPropagation()
                 event.preventDefault();
             }
         }
         const countyMO = this.template.querySelector('.countyMO');
         if (countyMO) {
             countyMO.setAttribute('tabindex', '0');
             countyMO.focus();
         }
     }

    toPascalCase(sentence) {
        // Split the sentence into words
        let words = sentence.split(' ');
    
        // Capitalize the first letter of each word
        let pascalCaseWords = words.map(word => word.charAt(0).toUpperCase() + word.slice(1));
    
        // Join the words without spaces
        let pascalCaseSentence = pascalCaseWords.join('');
    
        console.log(pascalCaseSentence);
        //return pascalCaseSentence;
    }
 }