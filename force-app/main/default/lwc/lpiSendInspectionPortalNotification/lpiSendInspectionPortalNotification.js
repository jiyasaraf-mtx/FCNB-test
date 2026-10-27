import { LightningElement,api,track } from 'lwc';
import {
    showAsyncErrorMessage,
    showMessage
} from 'c/lpiUtil';
import sendInspectionPortalNotification from '@salesforce/apex/LPI_VisitRegCodeViolationController.sendInspectionPortalNotification';
import fetchInspectionDetails from '@salesforce/apex/LPI_VisitRegCodeViolationController.fetchInspectionDetailsInternal';

export default class LpiSendInspectionPortalNotification extends LightningElement {
    @api recordId;
    showSpinner = false;
    get _recordId() {
        return this.recordId;
    }
    portalNotifWrapper = {};
    @track portalNotificationOptions = [
        {
            label : 'Inspection & Regulatory Code Violations',
            value : 'inspectionRCV'
        }
    ];
    connectedCallback() {
        this.fetchInspectionInfo();
    }

    fetchInspectionInfo() {
        fetchInspectionDetails({recordId : this.recordId})
        .then(rec=>{
            if(rec.inspectionDetails.qualAssuranceApplicable) {
                this.portalNotificationOptions = [...this.portalNotificationOptions,{
                    label : 'Quality Assurance Report',
                    value : 'qualAssuranceReport'
                }];
            }
        })
        .catch(err=>{
            showAsyncErrorMessage(this,err);
        })
    }

    checkValidity() {
        this.focus = false;
        this.focusIndex = -1;
        let isAllValid = [...this.template.querySelectorAll('lightning-combobox')].reduce((validSoFar, input) => {
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

    handleInputChange(event) {
        this.portalNotifWrapper[event.currentTarget.name] = event.currentTarget.value;
    }

    sendNotificationHandler(event) {

        if(this.checkValidity()) {

            let objToPass = {
                recordId : this._recordId,
                notifType : this.portalNotifWrapper.notificationType
            }
            this.showSpinner = true;
            sendInspectionPortalNotification({jsonData: JSON.stringify(objToPass) })
            .then(rec=>{
                showMessage(this, {
                    title: "Success",
                    message: "Notifications Have Been Sent to the Associated Contact.",
                    messageType: "success",
                    mode: "dismissable"
                });
                this.showSpinner = false;
                this.handleCloseQuickAction();
            })
            .catch(err=>{
                this.showSpinner = false;
                showAsyncErrorMessage(this,err);
            })
            
        }
    }

    handleCloseQuickAction() {
        this.dispatchEvent(new CustomEvent("close"));
    }
}