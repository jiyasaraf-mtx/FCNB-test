import {
    LightningElement,
    api,
    track
} from 'lwc';
import {
    showAsyncErrorMessage,
    checkLength,
    showMessage
} from 'c/lpiUtil';
import {
    NavigationMixin
} from "lightning/navigation";

import getTaskDetails from '@salesforce/apex/LPI_TaskController.getTaskDetails';
import saveTaskDetails from '@salesforce/apex/LPI_TaskController.saveTaskDetails';
import { RefreshEvent } from 'lightning/refresh';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import {
    CloseActionScreenEvent
} from 'lightning/actions';

const COMPLAINANT = 'Complainant';
const RESPONDENT  = 'Respondent';
export default class LpiAddTask extends NavigationMixin(LightningElement) {
    showSpinner;
    actionOptions;
    activityStatusOptions;
    minDateValue;
    relatedToOptions;
    @api fromQuickAction;
    _recordId;
    @track dataObj = {};
    @api
    set recordId(value) {
        this._recordId = value;
        this.init()

    }
    get recordId() {
        return this._recordId;
    }

    get relatedToName() {
        return this.dataObj.relatedTo == COMPLAINANT ? this.dataObj.relatedToCompName : this.dataObj.relatedToRespName;
    }

    init() {
        let today = new Date();
        this.minDateValue = today.getFullYear() + '-' + (today.getMonth() + 1) + '-' + today.getDate();
        this.showSpinner = true;
        getTaskDetails({
                recordId: this._recordId
            })
            .then(result => {
                if (result) {
                    this.activityStatusOptions = result.activityStatusOptions;
                    this.actionOptions = result.actionOptions;
                    this.dataObj.caseId = result.caseId;
                    this.dataObj.relatedToName = result.relatedToName;
                    this.dataObj.relatedToCompName = result.relatedToCompName;
                    this.dataObj.relatedToRespName = result.relatedToRespName;
                    this.relatedToOptions = result.relatedToOptions;
                    this.dataObj.boardName = result.boardName;
                }
                
            })
            .catch(error => {
                showAsyncErrorMessage(this, error);
            }).finally(() => {
                this.showSpinner = false;
            })
    }

    handleChange(event) {
        this.dataObj[event.target.name] = event.target.value;
    }

    handleSave() {
        if (this.checkValidity()) {
            this.showSpinner = true;
            this.dataObj.relatedToName = this.relatedToName;
            saveTaskDetails({
                    jsonData: JSON.stringify(this.dataObj)
                })
                .then(result => {
                    if (result) {
                        const event = new ShowToastEvent({
                            title: 'Success!',
                            message: 'Task record has been successfully created.',
                            variant : 'success'
                        });
                        this.dispatchEvent(event);
                        this.dispatchEvent(new RefreshEvent());
                        this.dispatchEvent(new CloseActionScreenEvent());
                       
                    } else {
                        showAsyncErrorMessage(this, 'Error saving the record.')
                    }
                })
                .catch(error => {
                    showAsyncErrorMessage(this, error)
                }).finally(() => {
                    this.showSpinner = false;
                })
        }
    }

    lookupRecord(event) {
        if (event.detail.selectedRecord != null) {
            this.dataObj.assignedUserId = event.detail.selectedRecord.Id;
        }
    }

    handleRemoveUser() {
        this.dataObj.assignedUserId = null;
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
        if (customLookup) {
            isAllValid = customLookup.checkValidation() && isAllValid;
        }

        if (!isAllValid) {
            showAsyncErrorMessage(this, 'Please validate all the input fields.')

        }
        return isAllValid;
    }

    handleCancel() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }

}