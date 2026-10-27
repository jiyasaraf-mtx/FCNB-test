import { LightningElement, api } from 'lwc';
import updateActualVisitStartTime from '@salesforce/apex/LPI_NewVisitRecord.updateActualVisitStartTime';
import checkIfCurrentUserIsInspector from '@salesforce/apex/LPI_NewVisitRecord.checkIfCurrentUserIsInspector';


import {
    showAsyncErrorMessage,
    showMessage
} from 'c/lpiUtil';
export default class LpiStartInspection extends LightningElement {
    @api
    recordId;


    connectedCallback(){
        checkIfCurrentUserIsInspector({
            recordId: this.recordId
        }).then(result =>{
            if(result){
                updateActualVisitStartTime({
                    recordId: this.recordId
                }).then(result => {
                    if (result) {
                        showMessage(this, {
                            title: "Success",
                            message: "Inspection is In Progress now.",
                            messageType: "success",
                            mode: "dismissable"
                        });
                        this.closeQuickAction()
                    }else{
                        showAsyncErrorMessage(this,'Error saving record.');
                    }
                }).catch(error => {
                    showAsyncErrorMessage(this,error);
                });
            }else{
                showAsyncErrorMessage(this,'You are not the inspector on this inspection.');
                this.closeQuickAction();
            }
        }).catch(error => {
            showAsyncErrorMessage(this,error);
        });

    }
    closeQuickAction() {
        this.dispatchEvent(new CustomEvent('close'));
    }
}