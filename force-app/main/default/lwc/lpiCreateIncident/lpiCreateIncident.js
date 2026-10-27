import {
    LightningElement,
    api,
    track,
    wire
} from 'lwc';
import {
    showAsyncErrorMessage,
    checkLength,
    showMessage
} from 'c/lpiUtil';
import {
    getPicklistValues,
    getObjectInfo
} from 'lightning/uiObjectInfoApi';
import ACCOUNT_OBJECT from '@salesforce/schema/Account';
import StateCode from '@salesforce/schema/Account.PersonOtherStateCode';
import INICDENT_OBJECT from '@salesforce/schema/Incident';
import InjurySeverity from '@salesforce/schema/Incident.Injury_Severity__c';
import LocationCategory from '@salesforce/schema/Incident.Location_Category__c';
import Urgency from '@salesforce/schema/Incident.Urgency';
import Impact from '@salesforce/schema/Incident.Impact';
import Priority from '@salesforce/schema/Incident.Priority';
import saveIncidentData from '@salesforce/apex/LPI_IncidentController.saveIncidentData';
import getIncidentDetails from '@salesforce/apex/LPI_IncidentController.getIncidentDetails';
import getAddressDetail from "@salesforce/apex/LPI_NewVisitRecord.getAddressDetail";

import {
    CloseActionScreenEvent
} from 'lightning/actions';

export default class LpiCreateIncident extends LightningElement {
    @track publicComplaintId;
    @track addressId;
    @track injurySevevrityOptions;
    @track locationCategoryOptions;
    @track stateOptions;
    @track urgencyOptions;
    @track impactOptions;
    @track priorityOptions;
    @track dataObj = {};
    @track addressRec;
    showSpinner;
    maxDateValue;
    accountRecordTypeId;
    incidentRecordType;
    @api fromQuickAction;
    _recordId;
    // _objectApiName
    @api
    set recordId(value) {
        this._recordId = value;
        this.publicComplaintId = this._recordId;

        getIncidentDetails({
            recordId: this._recordId
        })
        .then(result => {
            if(result){
                console.log('getIncidentDetails : ',result);
                this.dataObj = result
                this.publicComplaintId = result.publicComplaintId;
                this.addressId = result.addressId;
            }
            
        })
        .catch(error => {
            showAsyncErrorMessage(this, error);
        }).finally(() => {
            this.showSpinner = false;
        })
    }
    get recordId() {
        return this._recordId;
    }

    
    @wire(getObjectInfo, {
        objectApiName: ACCOUNT_OBJECT
    })
    wiredGetAccountObjectInfoDetails({
        error,
        data
    }){
        if(data){
            this.accountRecordTypeId = data.defaultRecordTypeId;
        }
        
    }
    // objectInfo;

         @wire(getPicklistValues, {
        //recordTypeId: '$objectInfo.data.defaultRecordTypeId',
        recordTypeId: '$accountRecordTypeId',
        fieldApiName: StateCode
        })
        wiredPicklistValuesStateCode({
            error,
            data
        }) {
            this.showSpinner = true;
            if (data && data.values) {
                this.stateOptions = data.values;
                this.showSpinner = false;
            } else if (error) {
                this.showSpinner = false;
                showAsyncErrorMessage(this, error);
            }

        }
   

    
    @wire(getObjectInfo, {
        objectApiName: INICDENT_OBJECT
    })
    wiredGetObjectInfoDetails({
        error,
        data
    }){
        if(data){
            console.log('data.defaultRecordTypeId : ',data.defaultRecordTypeId);
            this.incidentRecordType = data.defaultRecordTypeId;
        }
    }
    //objectInfo;

   
    @wire(getPicklistValues, {
        //recordTypeId: '$objectInfo.data.defaultRecordTypeId',
        recordTypeId:'$incidentRecordType',
        fieldApiName: InjurySeverity
    })
    wiredPicklistValuesInjurySeverity({
        error,
        data
    }) {
        this.showSpinner = true;
        if (data && data.values) {
            this.injurySevevrityOptions = data.values;
            console.log('this.injurySevevrityOptions : ',this.injurySevevrityOptions);
            this.showSpinner = false;
        } else if (error) {
            this.showSpinner = false;
            showAsyncErrorMessage(this, error);
        }

    }
    
    @wire(getPicklistValues, {
        recordTypeId: '$objectInfo.data.defaultRecordTypeId',
        fieldApiName: LocationCategory
    })
    wiredPicklistValuesLocationCategory({
        error,
        data
    }) {
        this.showSpinner = true;
        if (data && data.values) {
            this.locationCategoryOptions = data.values;
            this.showSpinner = false;
        } else if (error) {
            this.showSpinner = false;
            showAsyncErrorMessage(this, error);
        }

    }

    
    @wire(getPicklistValues, {
        recordTypeId: '$objectInfo.data.defaultRecordTypeId',
        fieldApiName: Urgency
    })
    wiredPicklistValuesUrgency({
        error,
        data
    }) {
        this.showSpinner = true;
        if (data && data.values) {
            this.urgencyOptions = data.values;
            this.showSpinner = false;
        } else if (error) {
            this.showSpinner = false;
            showAsyncErrorMessage(this, error);
        }

    }

    
    @wire(getPicklistValues, {
        recordTypeId: '$objectInfo.data.defaultRecordTypeId',
        fieldApiName: Impact
    })
    wiredPicklistValuesImpact({
        error,
        data
    }) {
        this.showSpinner = true;
        if (data && data.values) {
            this.impactOptions = data.values;
            this.showSpinner = false;
        } else if (error) {
            this.showSpinner = false;
            showAsyncErrorMessage(this, error);
        }

    }

    
    @wire(getPicklistValues, {
        recordTypeId: '$objectInfo.data.defaultRecordTypeId',
        fieldApiName: Priority
    })
    wiredPicklistValuesPriority({
        error,
        data
    }) {
        this.showSpinner = true;
        if (data && data.values) {
            this.priorityOptions = data.values;
            this.showSpinner = false;
        } else if (error) {
            this.showSpinner = false;
            showAsyncErrorMessage(this, error);
        }

    }

    connectedCallback() {
        console.log('OUTPUT : ','connectedcallback');
        let today = new Date();
        this.maxDateValue = today.getFullYear() + '-' + (today.getMonth() + 1) + '-' + today.getDate();
    }

    handleChange(event) {
        this.dataObj[event.target.name] = event.target.value;
        if((event.target.name === 'beginDate' || event.target.name === 'endDate') && event.target.value){
            let beginDateElement = this.refs.beginDateRef;
            beginDateElement.setCustomValidity('');
            beginDateElement.reportValidity();
        }
    }

    handleSave() {
        if (this.checkValidity()) {
            this.dataObj.publicComplaintId = this.dataObj.publicComplaintId ? this.dataObj.publicComplaintId : this._recordId;
            this.showSpinner = true;
            saveIncidentData({
                    jsonData: JSON.stringify(this.dataObj)
                })
                .then(() => {
                    let message = this.dataObj.incidentId ? 'Incident record has been successfully updated.' : 'Incident record has been successfully created.';
                    showMessage(this, {
                        title: "Success",
                        message: message,
                        messageType: "success",
                        mode: "dismissable"
                    });
                    this.dispatchEvent(new CloseActionScreenEvent());
                    this.dispatchEvent(new CustomEvent('closemodal'));
                    
                })
                .catch(error => {
                    showAsyncErrorMessage(this, error);
                }).finally(() => {
                    this.showSpinner = false;
                })
        }
    }

    lookupRecord(event) {
        console.log('lookupRecord : ');
        if (event.detail.selectedRecord != null) {
            this.showSpinner = true;
            console.log('lookupRecord : ');
            getAddressDetail({
                    recordId: event.detail.selectedRecord.Id
                })
                .then((result) => {
                    console.log('result : ',result);
                    this.addressRec = JSON.parse(JSON.stringify(result));
                    this.dataObj.locationId = this.addressRec.ParentId;
                })
                .catch((error) => {
                    showAsyncErrorMessage(this, error)
                    console.log('error : ',error);
                }).finally(() => {
                    this.showSpinner = false;
                })

        }
    }

    handleRemoveAddress(){
        this.addressRec = null;
    }
    checkValidity() {
        this.focus = false;
        this.focusIndex = -1;
        let isAllValid = [...this.template.querySelectorAll('lightning-input,lightning-radio-group,lightning-textarea,lightning-combobox')].reduce((validSoFar, input) => {
            input.reportValidity();
            let valid = input.checkValidity() && checkLength(input);
            valid = input.disabled ? true : valid;
            if (!valid && (!this.focus || this.focusIndex == -1 || this.focusIndex > parseInt(input.dataset.index))) {
                input.focus();
                this.focus = true;
                this.focusIndex = input.dataset.index;
            }
            return validSoFar && valid;
        }, true);

        let customLookup = this.template.querySelector("c-custom-look-up");
        if(customLookup){            
            isAllValid = customLookup.checkValidation() && isAllValid;
        }

        if (!isAllValid) {
            showAsyncErrorMessage(this, 'Please validate all the input fields.')

        }
        if (isAllValid && this.dataObj.beginDate > this.dataObj.endDate) {
            let beginDateElement = this.refs.beginDateRef;
            if(beginDateElement){
                beginDateElement.setCustomValidity('Begin Date should be less than end date.');
                beginDateElement.reportValidity();
            }
            isAllValid = false;
        }
        return isAllValid;
    }

    handleCancel() {
        this.dispatchEvent(new CloseActionScreenEvent());
        this.dispatchEvent(new CustomEvent('closemodal'));
    }
}