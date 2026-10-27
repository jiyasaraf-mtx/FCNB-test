import validateApplicationForEnotify from '@salesforce/apex/LPI_ApplicationViewController.validateLicenseFromENotifyService';
import fetchSelectedApplicationRecords from '@salesforce/apex/EMP_DashbaordTableCtrl.fetchSelectedApplicationRecords';
import fetchAmendmentSubtype from '@salesforce/apex/LPI_DashbaordTableCtrl.fetchAmendmentSubtype';
import launchApplication from '@salesforce/apex/LPI_DashbaordTableCtrl.launchApplication';
import withdrawApplication from '@salesforce/apex/LPI_RemoteActionForApplicationWithdraw.withdrawApplication';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { LightningElement, api, track } from 'lwc';
const LICENSE_ACTIONS_RNLPN = ['Renewal', 'Reinstatement'];
const ESC=27;
export default class EmpDashboardTableDetails extends LightningElement {
    @api columns;
    @api recordsdata
    @api licensedata
    @api applicationdata
    @api paymentdata
    @api titledata


    showWithdrawModal = false;
    selectedRecordId = '';
    showSpinner=false;
    statusCode=null;
    showEnotifyModal = false;
    modalDescription = '';
    type= '';
    subtype = '';
    showAmendModal = false;
    regAuthId = ''; 
    accountId = '';

    @track requestData = {};
    @track childButtonList = [];
    @track childofChildList = {};
    @track childOfchildOption = [];
    @track childValueMap = {};
    @track applicationData = [];

    enotifyMessageText = '';
    headerNotifyMsg = '';
    
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
    get tableTitleData() {
        return this.titledata + ' Table';
    }

    connectedCallback() {
        this.fetchSelectedApplicationRecord();
        console.log('$$$$ ', this.applicationData);
    }
    fetchSelectedApplicationRecord(){
        fetchSelectedApplicationRecords().then((result) => {
            this.showSpinner = false;
            console.log(' hhhhhhhhh: ', JSON.stringify(result));
            console.log('OUTPUT : ',result);
            this.applicationData = result;

        
        }).catch((error)=>{
            console.log(error);
            this.showSpinner = false;
        })
    }
    licenseEyehandler(event){
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: 'Renew_License_Details__c'
            },
            state: {
                blId : event.target.dataset.id
            }
        });
        // Generate a URL to a User record page
        this[NavigationMixin.GenerateUrl]({
            type: 'comm__namedPage',
            attributes: {
                name: 'Renew_License_Details__c'
            },
            state: {
                blId : event.target.dataset.id
            }
            }).then((url) => {
                window.open(url, '_self');
        });
    }
    applicationEyehandler(event) {
        console.log(event.target.dataset.element)
        let url = '/employerportal/s/application-detail?name=' + event.target.dataset.element
        window.open(url,'_self');
    }
    paymentEyeHandler(event){
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: 'payment_detail_view__c'
            },
            state: {
                trxnid : event.target.dataset.id
            }
        });
        // Generate a URL to a User record page
        this[NavigationMixin.GenerateUrl]({
            type: 'comm__namedPage',
            attributes: {
                name: 'payment_detail_view__c'
            },
            state: {
                trxnid : event.target.dataset.id
            }
            }).then((url) => {
                window.open(url, '_self');
        });
    }
    handleClickApplication(event){
        this.selectedRecordId = event.target.dataset.id;
        this.showWithdrawModal = false;
        console.log('selectedRecordId >>>> ', this.selectedRecordId);
        //console.log('Titledata >> ', this.titledata);
        if(event.target.dataset.openurl == 'true'){
            window.open(event.target.dataset.url,'_self');
        }else{
            if(event.target.value == 'Withdraw'){
                this.showWithdrawModal = true;
                setTimeout(() => {
                    this.focusFirstEle();
                }, 200);
            }
        }
    }
    handleCloseModal(){
        this.showWithdrawModal = false;
    }
    handleWithdrawYes(){
        this.showSpinner = true;
        withdrawApplication({
            applicationId : this.selectedRecordId
        }).then((result)=>{
            this.showMessage('Success','Your Application is Withdrawn Successfully!!', 'success');
            this.showWithdrawModal = false;
            let paramData = {uniqueValue : 'Withdraw'};
            this.callParent(paramData);
        }).catch((error)=>{
            this.showMessage('Error', error?.body?.message, 'error');
        }).finally(()=>{
            this.showSpinner = false;
        })
    }
    callParent(paramData){
        let ev = new CustomEvent('childmethod',{detail : paramData});
        this.dispatchEvent(ev);      
    }
    showMessage(title,message, variant) {
        const toastEvt = new ShowToastEvent({
            title,
            message,
            variant
        });
        this.dispatchEvent(toastEvt);
    }
    @api
    disabelSpinner(){
        this.showSpinner = false;
    }
    handleClickPayment(event){
        this.selectedRecordId = event.target.dataset.id;
        if(event.target.value == 'Re-Initiate Payment'){
            this[NavigationMixin.Navigate]({
                type: 'comm__namedPage',
                attributes: {
                    name: 'Payment_Redirect__c'
                },
                state: {
                    c__parid : this.selectedRecordId,
                    c__isreinitiate : true
                }
            });
        }
    }
    handleClickLicense(event){
        this.showSpinner = true;
        this.type = event.target.dataset.type;
        this.selectedRecordId = event.target.dataset.id;
        this.regAuthId = event.target.dataset.regid;
        this.accountId = event.target.dataset.accountid;
        var data = {
            regAuthId : this.regAuthId,
            type : this.type,
            amendmentType : this.type,
            blId : this.selectedRecordId,
            lateRenewal : event.target.dataset.late
        };
        if(this.type == 'Manage Account')
        {
            let urlToManageAccount = '/s/manage-business-account?accId='+this.accountId;
            window.open(urlToManageAccount, '_self');
        }
        if(this.type != 'Amendment'){
            //This statement is added for RN and LPN License Types to Validate the License from E-Notify Validation API
            //This is applicable only to "Renew" and "Reinstatement" actions
            if(event.target.dataset.validcheck == 'true' &&  LICENSE_ACTIONS_RNLPN.includes(this.type)){
                validateApplicationForEnotify({
                    blId : this.selectedRecordId
                })
                .then(result => {
                    if(result.isValidated) {
                        this.statusCode = result.status;
                        this.showEnotifyModal = true;
                        this.showSpinner = false;
                        this.requestData = data;
                        // Added Enotify Message By piyush aneja for S-52726 - Started
                        // Assign the message values to the respective properties - Piyush aneja
                        this.enotifyMessageText = result.message;
                        this.headerNotifyMsg = result.headerNotifyMsg;
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
        }else{
            this.showSpinner = true;
            this.showAmendModal = true;
            setTimeout(() => {
                this.focusFirstEle();
            }, 200);
            this.fetchAmendmentSubtype();
        }
    }
    fetchAmendmentSubtype(){
        fetchAmendmentSubtype({
            blid : this.selectedRecordId
        })
        .then(result => {
            let tempData = {};
            let tempArr = [];
            result.forEach(function (arrayItem) {
                tempArr.push({
                    label: arrayItem.buttonLable == 'Change of Interim Designated Incharge'? 'Designate Interim Person In Charge (PIC)' : arrayItem.buttonLable,
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
            this.showSpinner = false;
        })
        .catch(error => {
            this.showMessage('Error', error?.body?.message, 'error');
            this.showSpinner = false;
        });
    }
    getFormattedDate(date) {
        let year = date.getFullYear();
        let month = (1 + date.getMonth()).toString().padStart(2, '0');
        let day = date.getDate().toString().padStart(2, '0');
      
        return month + '/' + day + '/' + year;
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
    hideModalBox() {
        this.showAmendModal = false;
        this.type = '';
        this.subtype = '';
    }
    handleChildChangeType(event){
        this.childValue = event.target.value;
        let tempChild = {};
        tempChild[this.subtype]=event.target.value;
        this.childValueMap = tempChild;
    }
    handleAmendContinueButtton(){
        if(this.validateRadioButton()){
            this.showSpinner = true;
            var data = {
                regAuthId : this.regAuthId,
                type : this.type,
                amendmentType : this.subtype,
                blId : this.selectedRecordId,
                changeStatusAmendmentSubType: this.childValueMap['Change status to other status'] !== undefined ? this.childValueMap['Change status to other status'] : null,
                additionalLicenseType: this.childValueMap['Obtain Additional License'] !== undefined ? this.childValueMap['Obtain Additional License'] : null
            };
            this.handleAction(data);
        }
    }
    handleAction(data){
        this.showSpinner = true;
        launchApplication({
            inputMap: data
        })
        .then(result => {
            this.showSpinner = false;
            if (result == 'Duplicate') {
                this.showMessage(
                    'Info',
                    'The same application has already been submitted or a draft application has been created. Go to My Applications section on Dashboard in order to access it.',
                    'info'
                );
            } else if (result == 'Error') {
                console.log('result-->',result);
                this.showMessage(
                    'Error',
                    'Something went wrong.Please contact your adminstration!!',
                    'error'
                );
            } else if (result == 'BadCheck'){
                this.showMessage(
                    'Error',
                    'We regret to inform you that your License has been put on hold, therefore you will be unable to submit any new applications at this time. Please contact the board for further information.',
                    'error'
                );
            } else {
                result = result + '&blId='+this.selectedRecordId+'&type='+this.type.toLowerCase()+'&portalUser=true';
                if(data.hasOwnProperty('lateRenewal')){
                    result = result + '&lateRenewal='+data['lateRenewal'];
                }
                window.open(result, '_self');
            }
        })
        .catch(error => {
            this.showMessage('Error', error?.body?.message, 'error');
            this.showSpinner = false;
        });
    }

    validateRadioButton(){
        return [...this.template.querySelectorAll("lightning-radio-group")].reduce((validSoFar, field) => {
            return (validSoFar && field.reportValidity());
        }, true);
    }

   
    /* Modal Focus Function */
    focusFirstEle() {
        const focusableElements = 'lightning-combobox, lightning-button-icon, button, input, lightning-textarea, lightning-helptext, lightning-input, lightning-button';
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
    escCloseModal(event){
        if (event.keyCode === ESC) {
            this.hideModalBox();
        }
    }
}