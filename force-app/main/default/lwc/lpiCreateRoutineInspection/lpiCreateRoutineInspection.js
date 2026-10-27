import { LightningElement,api } from 'lwc';

import {
    CloseActionScreenEvent
} from 'lightning/actions';
import {
    showAsyncErrorMessage,
    showMessage
} from 'c/lpiUtil';
import createRoutineInspections from "@salesforce/apex/LPI_ScheduleInspections.createRoutineInspections";
export default class LpiCreateRoutineInspection extends LightningElement {

    _recordId;
    showSpinner;
    get recordId() {
        return this._recordId;
    }
    @api
    set recordId(value) {
        this._recordId = value;    
    }

    createRoutineInspectionsRecords(){
       
        this.showSpinner = true;
        createRoutineInspections({
            recordId: this._recordId,
            inspectionType : 'Routine'
        })
        .then(() => {
            showMessage(this, {
                title: "Success",
                message: "Routine inspections have been created..",
                messageType: "success",
                mode: "dismissable"
            });
            this.dispatchEvent(new CloseActionScreenEvent());
        })
        .catch((error) => {
            showAsyncErrorMessage(this,error);
        }).finally(()=>{
            this.showSpinner = false;
        })
    }
}