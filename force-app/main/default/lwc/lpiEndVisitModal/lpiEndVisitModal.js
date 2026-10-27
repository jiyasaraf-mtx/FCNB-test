import { LightningElement,api,track,wire } from 'lwc';
import {
    showAsyncErrorMessage,
    showMessage
} from 'c/lpiUtil';
import saveVisitStatusRemark from '@salesforce/apex/LPI_NewVisitRecord.saveVisitStatusRemark';
import fetchVisitAssessmentStatus from "@salesforce/apex/LPI_NewVisitRecord.fetchVisitAssessmentStatus";
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import ACTUAL_VISIT_END_TIME_FIELD from '@salesforce/schema/Visit.Actual_End_Date__c';
const fields = [ACTUAL_VISIT_END_TIME_FIELD];
export default class LpiEndVisitModal extends LightningElement {
    showSpinner
    _recordId;
    @track dataObj = {};
    displayCmp;
    success = true;
    @api
    set recordId(value) {
        this._recordId = value;
        this.displayCmp = true;
        this.showSpinner = true;
        fetchVisitAssessmentStatus({
            recordId: this._recordId
        }).then(result => {
            if (result != null) {
                this.visitRec = result;
                this.displayCmp = true;
            }
        }).catch((error) => {
            this.showSpinner = false;
            showAsyncErrorMessage(this, error);
            this.closeQuickAction();
        }).finally(() => {
            this.showSpinner = false;
        })
    }

    get recordId() {
        return this._recordId;
    }
    @wire(getRecord, { recordId: "$recordId", fields })
    visitRecord;
    get actualVisitEndTime() {
        return getFieldValue(this.visitRecord.data, ACTUAL_VISIT_END_TIME_FIELD);
    }  

    get isInprogress() {
        return this.visitRec;
    }
    handleTextAreaChange(event) {
        if(event.target.name === 'AbandonComment')
        {
            this.dataObj.StatusRemarks = event.target.value;
        } else if(event.target.name === 'CompleteComment')
        {
            this.dataObj.StatusRemarks = event.target.value;
        }
    }
    handleClickVisit(event) {
        if(this.actualVisitEndTime == null){
            showAsyncErrorMessage(this,'Inspection Completion Date should not be blank before completing inspection.');
        }else{
            this.showSpinner = true;
            if(event.target.name === 'Abandon')
            {
                this.dataObj.Status = 'Abandoned';
            } else {
                this.dataObj.Status = 'Completed';
            }
            saveVisitStatusRemark({
                recordId: this._recordId,
                dataObj : JSON.stringify(this.dataObj)
            }).then((result) => {
                if(result){
                    showMessage(this, {
                        title: "Success",
                        message: "Status has been successfully updated.",
                        messageType: "success",
                        mode: "dismissable"
                    });
                    this.closeQuickAction();
                }else{
                    showAsyncErrorMessage(this,'Error saving record.');
                }
            })
            .catch(error => {
                showAsyncErrorMessage(this,error);
            }).finally(()=> {
                this.showSpinner = false;
            });
        }
    }

    closeQuickAction() {
        this.dispatchEvent(new CustomEvent('close'));
    }
}