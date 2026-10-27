import { LightningElement,api,wire,track } from 'lwc';
import {CurrentPageReference} from 'lightning/navigation';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import {CloseActionScreenEvent} from 'lightning/actions';
import { RefreshEvent } from 'lightning/refresh';
import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';
// Apex Class 
import updateRespDetails from '@salesforce/apex/LPI_ComplaintsRespChangeController.updateRespondentDetails';
import getProfessionOptions from '@salesforce/apex/LPI_ComplaintsController.getProfessionOptions';
import getLicenseTypeOptions from '@salesforce/apex/LPI_ComplaintsController.getLicenseTypeOptions';

// Account Fields 
import ACCOUNT_OBJECT from '@salesforce/schema/Account';
import ACCOUNT_STATE_CODE from '@salesforce/schema/Account.PersonOtherStateCode';

import NAME_FIELD from "@salesforce/schema/Account.Name";
import PHONE_FIELD from "@salesforce/schema/Account.PersonHomePhone";
import EMAIL_FIELD from "@salesforce/schema/Account.PersonEmail";
import FICTIOUS_NAME from "@salesforce/schema/Account.Fictitious_Name__c";
import DOING_BUSINESS_AS_TRADE_NAME from  "@salesforce/schema/Account.Doing_Business_As_DBA_or_Trade_Name__c";

// Address Fields/Object.
import ADDRESS_OBJECT from '@salesforce/schema/Address';
import COUNTRY_CODE_FIELD from '@salesforce/schema/Address.CountryCode';

// License Fields 
import LICENSE_NAME from "@salesforce/schema/BusinessLicense.Name";
import LICENSE_PROFESSION from "@salesforce/schema/BusinessLicense.RegulatoryAuthorizationType.Name";
import LICENSE_BOARD from "@salesforce/schema/BusinessLicense.Board_Name__c";
import LICENSE_ACCOUNT from "@salesforce/schema/BusinessLicense.AccountId";
import LICENSE_ACCOUNT_NAME from "@salesforce/schema/BusinessLicense.Account.Name";

// Complaint Fields 
import COMPLAINT_BOARD_NAME from "@salesforce/schema/PublicComplaint.Board_Names_List__c";
import COMPLAINT_LICENSE_NAME from "@salesforce/schema/PublicComplaint.License_Name__c";


import {
    showAsyncErrorMessage,
    showMessage,
    formatPhoneNumber
} from 'c/lpiUtil';

const LICENSED  = 'Licensed';
const UNLICENSED = 'UnLicensed';
const BUSINESS = 'Business';
const INDIVIDUAL = 'Individual';
const NEW = 'New';
const EXISTING = 'Existing';
const US_COUNTRY_CODE = 'US';
export default class LpiChangeComplaintRespondentInfo extends LightningElement {
    // INIT RECORDID - STARTS
    @api recordId;
    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.recordId = this.recordId || currentPageReference.state.recordId;
        }
    }
    // INIT RECORDID - ENDS 

    // VARIABLES - START
    @track respondentTypeOptions = [ { label : LICENSED, value : LICENSED }, { label: UNLICENSED, value: UNLICENSED }];
    @track newExistingOptions = [ { label : NEW , value : NEW }, { label : EXISTING, value : EXISTING } ];
    @track entityIndividualOptions = [ { label : BUSINESS, value : BUSINESS }, { label: INDIVIDUAL, value: INDIVIDUAL }];
    @track dataObj = {
        accountInfo : {
            addressData  : {}
        }
    };
    @track confirmationText = '';
    @track accMatchingInfo = {
        primaryField: { fieldPath: "Name" },
        additionalFields: [{ fieldPath: "Doing_Business_As_DBA_or_Trade_Name__c" }],
    };
    @track accDisplayInfo = {
        // if we want to display multiple fields in addition to the primary field go with the formula field - Vamsi 
        additionalFields: ["PersonEmail", "PersonHomePhone"], 
    };

    @track licenseMatchingInfo = {
        primaryField: { fieldPath: "Name" },
    };
    @track licenseDisplayInfo = {
        additionalFields : ["Board_Name__c"]
    }

    @track accountId;
    @track licenseId;
    spinnerText = 'Please Wait, While we update the details.';
    openConfirmationModal = false;
    @track sObjectName = 'Account';
    @track pickerConfig = {
        sObjectName : 'Account',
        label: 'Select Account',
        placeholder : 'Select Accounts'
    };
    @track boardOptions = [];
    @track professionOptions = [];
    @track stateOptions=[];
    @track countryOptions=[];
    @track authType;
    @track patternObj = {
        text: '^((?!(<)|(>)).)*$',
        digits: '^(\\([0-9]{3}\\) |[0-9]{3}-)[0-9]{3}-[0-9]{4}$',
        email: '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,10}',
        zipCode: '^[A-Za-z]\\d[A-Za-z][ -]?\\d[A-Za-z]\\d$',
        ssn: '^(?!.*(<|>))[0-9]*$'
    }
    // VARIABLES - END

    // GETTERS STARTS 

        get showRecordPickerDetails() {
            return !!this.dataObj.respondentType && (this.dataObj.newOrExisting === EXISTING || this.dataObj.respondentType == LICENSED);
        }
        get showNewAccountSection() {
            return !!this.dataObj.respondentType && this.dataObj.newOrExisting === NEW;
        }

        get accountDataSelectedAndFetched() {
            return this.dataObj?.newOrExisting === EXISTING && this.accountId && this.accountRecord?.data;
        }
        get licenseDataSelectedAndFetched() {
            return this.dataObj.respondentType === LICENSED && this.licenseId && this.licenseRecord?.data;
        }
        get showBoardProfessionOptions() {
            return this.boardOptions && this.dataObj?.newOrExisting === EXISTING && this.dataObj.respondentType === UNLICENSED;
        }
        get isUnLicensed() {
            return this.dataObj.respondentType === UNLICENSED;
        }
        get businessAccountSelected() {
            return this.isUnLicensed && this.showNewAccountSection && this.dataObj.entityOrIndividual === BUSINESS;
        }
        get boardNotSelected() {
            return (!this.boardOptions || !this.dataObj.selectedBoardName) || !this.professionOptions;
        }
        get authTypeUnSelected() {
            return !this.dataObj.entityOrIndividual;
        }
        get showOtherStateField() {
            return this.dataObj.accountInfo && this.dataObj.accountInfo?.addressData.country !== US_COUNTRY_CODE;
        }

        get selectedAccName() {
            return getFieldValue(this.accountRecord?.data, NAME_FIELD);
        }
        get selectedAccPhone() {
            return getFieldValue(this.accountRecord?.data, PHONE_FIELD);
        }
        get selectedAccEmail() {
            return getFieldValue(this.accountRecord?.data, EMAIL_FIELD);
        }
        get selectedAccDBAName() {
            return getFieldValue(this.accountRecord?.data, DOING_BUSINESS_AS_TRADE_NAME);
        }
        get selectedAccFitousName() {
            return getFieldValue(this.accountRecord?.data, FICTIOUS_NAME);
        }

        // License Details.
        get selectedLicenseName() {
            return getFieldValue(this.licenseRecord?.data, LICENSE_NAME);
        }
        get selectedLicenseProfession() {
            return getFieldValue(this.licenseRecord?.data, LICENSE_PROFESSION);
        }
        get selectedLicenseBoard() {
            return getFieldValue(this.licenseRecord?.data, LICENSE_BOARD);
        }
        get selectedLicenseAccountId() {
            return getFieldValue(this.licenseRecord?.data, LICENSE_ACCOUNT);
        }
        get selectedLicenseAccountName() {
            return getFieldValue(this.licenseRecord?.data, LICENSE_ACCOUNT_NAME);
        }

        // Complaint Details 
        get currentObjBoardName() {
            return getFieldValue(this.complaintDetails?.data,COMPLAINT_BOARD_NAME);
        }
        get currentObjProfession() {
            return getFieldValue(this.complaintDetails?.data,COMPLAINT_LICENSE_NAME);
        }
    // GETTERS END

    // WIRE CALLS START
        @wire(getRecord, {
            recordId: "$recordId",
            fields: [COMPLAINT_LICENSE_NAME, COMPLAINT_BOARD_NAME],
        })
        complaintDetails;

        @wire(getRecord, {
            recordId: "$accountId",
            fields: [NAME_FIELD],
            optionalFields: [PHONE_FIELD, EMAIL_FIELD,FICTIOUS_NAME,DOING_BUSINESS_AS_TRADE_NAME],
        })
        accountRecord;

        @wire(getRecord, {
            recordId: "$licenseId",
            fields: [LICENSE_NAME],
            optionalFields: [LICENSE_PROFESSION, LICENSE_BOARD,LICENSE_ACCOUNT,LICENSE_ACCOUNT_NAME]
        })
        licenseRecord;

        // Fetching board names. 
        @wire(getProfessionOptions,{})
        fetchBoardOptions({error,data}) {
            if(error) {
                showAsyncErrorMessage(this,error);
                return;
            }
            this.boardOptions = data;
        }
        @wire(getLicenseTypeOptions,{
            selectedBoardName : '$dataObj.selectedBoardName',
            authType : '$dataObj.entityOrIndividual' 
        })
        fetchProfessionFromBoard({error,data}) {
            if(error) {
                showAsyncErrorMessage(this,error);
                return;
            }
            this.professionOptions = data;
        }

        // GET OBJECT INFO
        @wire(getObjectInfo, {
            objectApiName: ACCOUNT_OBJECT
        })
        objectInfo;

        // GET PICKLIST VALUES OF STATE FIELD
        @wire(getPicklistValues, {
            recordTypeId: '$objectInfo.data.defaultRecordTypeId',
            fieldApiName: ACCOUNT_STATE_CODE
        })
        wiredPicklistValues({
            error,
            data
        }) {
            if (data && data.values) {
                this.stateOptions = data.values;
            } else if (error) {
                this.showSpinner = false;
                showAsyncErrorMessage(this, error);
            }
        }

         // GET OBJECT INFO FOR ADDRESS 
        @wire(getObjectInfo, {
            objectApiName: ADDRESS_OBJECT
        })
        objectCountryInfo;
    
        @wire(getPicklistValues, {
            recordTypeId: '$objectCountryInfo.data.defaultRecordTypeId',
            fieldApiName: COUNTRY_CODE_FIELD,
        })
        countryPicklistValues({
            error,
            data
        }) {
            if (data && data.values) {
                this.countryOptions = data.values;
                const index = this.countryOptions.findIndex(opt => opt.value === 'US');
                if (index !== -1) {
                    // Create a new array with the modified order
                    this.countryOptions = [
                        this.countryOptions[index],
                        ...this.countryOptions.slice(0, index),
                        ...this.countryOptions.slice(index + 1)
                    ];
                }
            } else if (error) {
                showAsyncErrorMessage(this, error);
            }
        }

    // WIRE CALLS END
    

    // HANDLERS STARTS
    handleSubmit(event) {
        if(this.checkValidity()) {

            this.openConfirmationModal = true;
            this.confirmationText = 'Are you sure, you want to change the respondent on this Complaint and their related records?';
        } else {
            showAsyncErrorMessage(this,'Please fill in the Required Fields.')
        }
    }
    

    checkValidity() {
        this.focus = false;
        this.focusIndex = -1;
        let isAllValid = [...this.template.querySelectorAll('lightning-input, lightning-combobox, lightning-record-picker, lightning-radio-group')].reduce((validSoFar, input) => {
            input.reportValidity();
            let valid = input.checkValidity();
            valid = input.disabled ? true : valid;

            return validSoFar && valid;
        }, true);

        return isAllValid;
    }


    handleInputChange(event) {
        const addressData = event.currentTarget.dataset.address;
        const respondentData = event.currentTarget.dataset.respondent;

        if(respondentData && addressData) {
            this.dataObj.accountInfo.addressData[event.currentTarget.name] = event.currentTarget.value;
        }
        else if(respondentData){
            this.dataObj.accountInfo[event.currentTarget.name] = event.currentTarget.value;
        }
        else if(event.target.name === 'respondentType') {
            this.dataObj.respondentType = event.target.value;
            this.refs.recordPicker && this.refs.recordPicker.clearSelection(); 
            this.accountRecord = null;
            this.licenseRecord = null;

        } else if(event.target.name === 'pickerVal') {
            if(this.dataObj.respondentType === LICENSED) 
                this.licenseId = event.detail.recordId; 
            else 
                this.accountId = event.detail.recordId;
        } else if(event.target.name === 'newOrExisting') {
            
            this.dataObj[event.currentTarget.name] = event.currentTarget.value;

            if(event.currentTarget.value == EXISTING) {
                this.refs.recordPicker && this.refs.recordPicker.clearSelection(); 
                this.accountRecord = null;
            }
        } 
        else {
            this.dataObj[event.currentTarget.name] = event.currentTarget.value;
        }
        this.handleTelephoneFormat(event);

        console.log('UPDATED JSON FORMED >> '  + JSON.stringify(this.dataObj));
    }

    renderedCallback() {
        if(this.dataObj.respondentType === LICENSED) {
            this.refs.recordPicker.label = 'Select License';
            this.refs.recordPicker.objectApiName = 'BusinessLicense';
            this.refs.recordPicker.placeholder = 'Select a License';
            this.refs.recordPicker.matchingInfo = {...this.licenseMatchingInfo};
            this.refs.recordPicker.displayInfo = {...this.licenseDisplayInfo};    
        } 
        else if(this.dataObj.respondentType === UNLICENSED && this.dataObj.newOrExisting === EXISTING) {
            this.refs.recordPicker.objectApiName = 'Account';
            this.refs.recordPicker.placeholder = 'Select an Account';
            this.refs.recordPicker.label = 'Select Account';
            this.refs.recordPicker.matchingInfo = {...this.accMatchingInfo};
            this.refs.recordPicker.displayInfo = {...this.accDisplayInfo};
        }
    }

    handleEscKeyDown(event) {
        if (event.code === 'Escape' || event.keyCode === 27) {
            this.handleCancelConfirmation();
        }
    }

    handleCancelConfirmation(event) {
        this.openConfirmationModal = false;
    }

    handleConfirmation(event) {
        // pass in the accountId or License Id and Respondent Type along with BoardName, Profession and other details to the backend.
        this.openConfirmationModal = false;
        
        let combinedName = this.dataObj.entityOrIndividual === BUSINESS ?
        this.dataObj.accountInfo.entityName :
        (this.dataObj.accountInfo.middleName ?
            this.dataObj.accountInfo.firstName + ' ' + this.dataObj.accountInfo.middleName + ' ' + this.dataObj.accountInfo.lastName :
            (this.dataObj.accountInfo.firstName || '') + ' ' + (this.dataObj.accountInfo.lastName || ''));


        let jsonData = {
            respondentType : this.dataObj?.respondentType,
            board : this.dataObj?.respondentType === LICENSED ? this.selectedLicenseBoard : this.dataObj.selectedBoardName,
            profession : this.dataObj?.respondentType === LICENSED ? this.selectedLicenseProfession : this.dataObj.selectedProfessionName,
            accountId : this.dataObj?.respondentType === LICENSED ? this.selectedLicenseAccountId : this.accountId,
            licenseId : this.licenseId,
            complaintId : this.recordId,
            accountName : this.dataObj.respondentType === LICENSED ? this.selectedLicenseAccountName : (this.dataObj.newOrExisting === EXISTING ? this.selectedAccName : combinedName ),
            licenseNum : this.selectedLicenseName || '',
            newOrExisting : this.dataObj.newOrExisting,
            businessOrIndividual : this.dataObj.entityOrIndividual
        }
        if(this.showNewAccountSection) {

            // Change the telephone format to normal numeric text and then prepare json. 
            let telephoneText = this.dataObj.accountInfo.telephone;

            this.dataObj.accountInfo = {
                ...this.dataObj.accountInfo,
                telephone : telephoneText ? telephoneText.replace(/[^\d]/g, "") : telephoneText
            }
            this.dataObj.accountInfo.cellPhone = this.dataObj.accountInfo.telephone; // creating additional mapping for cellPhone.

            jsonData = {
                ...jsonData,
                accountInfo : {
                    ...this.dataObj.accountInfo
                }
            }
        }

        console.log('JSON DATA SENDING >> ' + JSON.stringify(jsonData));
        this.showSpinner = true;
        updateRespDetails({jsonData : JSON.stringify(jsonData)})
        .then(result=>{
            this.showSpinner = false;
            console.log('RESULT >> ' + JSON.stringify(result));
            showMessage(this, {
                title: "Success",
                message: "Respondent Updated Successfully!",
                messageType: "success",
                mode: "dismissable"
            });
            this.closeQuickAction();
            this.dispatchEvent(new RefreshEvent());
        })
        .catch(err=>{
            this.showSpinner = false;
            showAsyncErrorMessage(this,err);
        })
    }

    closeQuickAction() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }


    handleTelephoneFormat(event) {
        event.currentTarget.setCustomValidity("");
        event.currentTarget.reportValidity("");
        
        if (event.target.name === 'telephone' || event.target.name === 'telephoneHome') {
            this.dataObj.accountInfo[event.currentTarget.name] = formatPhoneNumber(event.currentTarget.value);
            this.dataObj.accountInfo[event.currentTarget.name] = this.dataObj.accountInfo[event.currentTarget.name] ? this.dataObj.accountInfo[event.currentTarget.name] : event.currentTarget.value;
       } 
    }


    // HANDLERS END
}