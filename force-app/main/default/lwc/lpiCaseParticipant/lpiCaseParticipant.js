import {
    LightningElement,
    api,
    track,
    wire
} from 'lwc';
import {
    CloseActionScreenEvent
} from 'lightning/actions';
import {
    showAsyncErrorMessage,
    showMessage
} from 'c/lpiUtil';
import {
    getPicklistValues,
    getObjectInfo
} from 'lightning/uiObjectInfoApi';
import CASE_PARTICIPANT_OBJECT from '@salesforce/schema/CaseParticipant';
import StatusOptions from '@salesforce/schema/CaseParticipant.Status';
import getCaseParticipantDetails from '@salesforce/apex/LPI_CaseParticipantController.getCaseParticipantDetails';
import saveCaseParticipantDetails from '@salesforce/apex/LPI_CaseParticipantController.saveCaseParticipantDetails';
export default class LpiCaseParticipant extends LightningElement {
    showSpinner;
    caseId;
    isRecordUpdate;
    @track roleToComplaintParticipant;
    @track dataObj = {};
    @track rolesList;
    @track participantsList;
    @track statusOptionsList = [];
    @api fromQuickAction;
    _recordId;
    // _objectApiName


    // GET OBJECT INFO
    @wire(getObjectInfo, {
        objectApiName: CASE_PARTICIPANT_OBJECT
    })
    objectInfo;

    // GET PICKLIST VALUES OF Injury_Severity__c FIELD
    @wire(getPicklistValues, {
        recordTypeId: '$objectInfo.data.defaultRecordTypeId',
        fieldApiName: StatusOptions
    })
    wiredPicklistValuesStatusOptions({
        error,
        data
    }) {
        this.showSpinner = true;
        if (data && data.values) {
            this.statusOptionsList = data.values;
            this.showSpinner = false;
        } else if (error) {
            this.showSpinner = false;
            showAsyncErrorMessage(this, error);
        }

    }

    @api
    set recordId(value) {
        this._recordId = value;
        this.showSpinner = true;
        getCaseParticipantDetails({
                recordId: this._recordId
            })
            .then(result => {
                if (result) {
                    this.isRecordUpdate = result.caseParticipant != null;
                    this.dataObj = this.isRecordUpdate ? result.caseParticipant[0] : this.dataObj;
                    this.rolesList = [];
                    if(this.isRecordUpdate){
                        this.participantsList = [];
                        this.participantsList.push({
                            'label' : this.dataObj.participantName,
                            'value' : this.dataObj.participantId
                        })
                        this.rolesList.push({
                            'label' : this.dataObj.role,
                            'value' : this.dataObj.role
                        })
                    }
                    this.roleToComplaintParticipant = this.isRecordUpdate ? this.roleToComplaintParticipant : result;
                    if(this.roleToComplaintParticipant){
                        for (let key in this.roleToComplaintParticipant) {
                            this.rolesList.push({
                                'label': key,
                                'value': key
                            })
                        }
                    }
                    

                    //this.rolesList = JSON.parse(JSON.stringify(Object.keys(this.roleToComplaintParticipant.keys())));
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




    get isParticipantSelectionDisabled() {
        return this.isRecordUpdate || !this.dataObj.role;
    }

    handleChange(event) {
        this.dataObj[event.target.name] = event.target.value;
        if (event.target.name === 'role') {
            this.dataObj.participantId = null;
            this.participantsList = [];
            this.roleToComplaintParticipant[event.target.value].forEach(record =>{
                this.participantsList.push({
                    'label' : record.participantName,
                    'value' : record.participantId
                })
            });
        }
    }

    handleCancel(){
        this.dispatchEvent(new CloseActionScreenEvent());
        this.dispatchEvent(new CustomEvent('closemodal'));
    }

    handleSave(){
        if(this.checkValidity()){
            this.showSpinner = true;
            this.dataObj.caseId = this.isRecordUpdate ? this.dataObj.caseId : this._recordId;
            this.dataObj.status = this.isRecordUpdate ? this.dataObj.status : 'Active';
            this.dataObj.role = this.dataObj.role;
            saveCaseParticipantDetails({ jsonData: JSON.stringify(this.dataObj) })
              .then(result => {
                if(result){
                    let message = this.isRecordUpdate ? 'Case Participant record has been successfully updated.' : 'Case Participant record has been successfully created.'
                    showMessage(this, {
                        title: "Success",
                        message: message,
                        messageType: "success",
                        mode: "dismissable"
                    });
                    this.dispatchEvent(new CloseActionScreenEvent());
                    this.dispatchEvent(new CustomEvent('closemodal'));
                }else{
                    showAsyncErrorMessage(this,'Error saving the record.')
                }
                
              })
              .catch(error => {
                showAsyncErrorMessage(this,error)
            }).finally(()=>{
                this.showSpinner = false;
            })
        }
    }

    checkValidity() {
        this.focus = false;
        this.focusIndex = -1;
        let isAllValid = [...this.template.querySelectorAll('lightning-input,lightning-radio-group,lightning-textarea,lightning-combobox')].reduce((validSoFar, input) => {
            input.reportValidity();
            let valid = input.checkValidity();
            valid = input.disabled ? true : valid;
            if (!valid && (!this.focus || this.focusIndex == -1 || this.focusIndex > parseInt(input.dataset.index))) {
                input.focus();
                this.focus = true;
                this.focusIndex = input.dataset.index;
            }
            return validSoFar && valid;
        }, true);

        if (!isAllValid) {
            showAsyncErrorMessage(this, 'Please validate all the input fields.')

        }
        return isAllValid;
    }

}