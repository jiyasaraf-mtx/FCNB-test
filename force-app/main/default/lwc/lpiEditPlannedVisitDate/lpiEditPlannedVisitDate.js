import {
    LightningElement,
    api,
    track
} from 'lwc';
import {
    showAsyncErrorMessage,
    showMessage
} from 'c/lpiUtil';
import getRecordDetail from "@salesforce/apex/LPI_NewVisitRecord.getRecordDetail";
import updatePlannedVisitDate from "@salesforce/apex/LPI_NewVisitRecord.updatePlannedVisitDate";

export default class LpiEditPlannedVisitDate extends LightningElement {
    showSpinner
    _recordId;
    @track visitRec = {};
    displayCmp;
    // _objectApiName

    @api
    set recordId(value) {
        this._recordId = value;
        this.showSpinner = true;
        getRecordDetail({
            recordId: this._recordId
        }).then(result => {
            if(result && result.isCurrentUserInspector && result.showVisit){
                this.visitRec = JSON.parse(JSON.stringify(result.visitRec));
                this.displayCmp = true;
            }else{
                showAsyncErrorMessage(this,'Looks like you are not the inspector on this visit.')
                this.dispatchEvent(new CustomEvent('close',{}));
            }
            
        }).catch((error) => {
            this.showSpinner = false;
            showAsyncErrorMessage(this, error);
        }).finally(() => {
            this.showSpinner = false;
        })
    }

    get recordId() {
        return this._recordId;
    }

    handleChange(event) {
        this.visitRec[event.target.name] = event.target.value;
        if (event.target.value) {
            this.comparePlannedDateWithCurrentDate(event.target.value);
        }
    }

    comparePlannedDateWithCurrentDate(enteredDate) {
        let plannedDateElement = this.refs.vPlannedStartTime;
        if (plannedDateElement) {
            plannedDateElement.setCustomValidity('');
            plannedDateElement.reportValidity();
        }
        let today = new Date();
        today.setHours(0,0,0,0);
       if (enteredDate && plannedDateElement && new Date(enteredDate) < today) {
            plannedDateElement.setCustomValidity('Planned Start Date Cannot be Past Date');
            plannedDateElement.reportValidity();
            return false;
        }
        return true;
    }

    handleSave() {

        if (this.checkValidity()) {
            this.showSpinner = true;
            updatePlannedVisitDate({
                    jsonData: JSON.stringify(this.visitRec)
                })
                .then((result) => {
                    if(result){
                        showMessage(this, {
                            title: "Success",
                            message: "Planned Inspection Date has been successfully updated.",
                            messageType: "success",
                            mode: "dismissable"
                        });
                        this.dispatchEvent(new CustomEvent('close',{}));
                        eval("$A.get('e.force:refreshView').fire();");
                    }else{
                        showAsyncErrorMessage(this,'Error saving record.');
                    }
                })
                .catch(error => {
                    showAsyncErrorMessage(this,error);
                }).finally(()=> {
                    this.showSpinner = false;
                })
        }
    }

    checkValidity() {
        this.focus = false;
        this.focusIndex = -1;
        let isAllValid = [...this.template.querySelectorAll('lightning-combobox')].reduce((validSoFar, input) => {
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

        if (!this.comparePlannedDateWithCurrentDate(this.visitRec.vPlannedStartTime)) {
            isAllValid = false;
        }

        if (!isAllValid) {
            showAsyncErrorMessage(this, 'Please validate all the input fields.')
        }

        return isAllValid;
    }


}