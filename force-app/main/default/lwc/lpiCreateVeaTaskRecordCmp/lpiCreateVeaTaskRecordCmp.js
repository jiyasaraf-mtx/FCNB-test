import { LightningElement ,api ,wire} from 'lwc';
import {
    showAsyncErrorMessage
} from 'c/lpiUtil';
import createVeaTaskRecord from "@salesforce/apex/LPI_TaskController.createVeaTaskRecord";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import TYPE_FIELD from "@salesforce/schema/ViolationEnforcementAction.Type";
import FREQUENCY_FIELD from "@salesforce/schema/ViolationEnforcementAction.Frequency__c";
import END_DATE_FIELD from "@salesforce/schema/ViolationEnforcementAction.DateResolved";
import START_DATE_FIELD from "@salesforce/schema/ViolationEnforcementAction.Start_Date__c";
const fields = [TYPE_FIELD, FREQUENCY_FIELD, END_DATE_FIELD, START_DATE_FIELD];
export default class LPICreateVeaTaskRecordCmp extends LightningElement {
    @api recordId;
    @wire(getRecord, { recordId: "$recordId", fields })
    veaRecord;
    get type() {
        return getFieldValue(this.veaRecord.data, TYPE_FIELD) ;
    }  
    get frequency() {
        return getFieldValue(this.veaRecord.data, FREQUENCY_FIELD);
    }
    get startDate() {
        return getFieldValue(this.veaRecord.data, START_DATE_FIELD) ;
    }  
    get endDate() {
        return getFieldValue(this.veaRecord.data, END_DATE_FIELD);
    }
    @api invoke() {
        if(!this.startDate || !this.endDate || !this.frequency){
            showAsyncErrorMessage(this,'Start Date,End Date and Frequency should be populated before creating the task records.');
            return;
        }
        let jsonData = {
            type : this.type,
            startDate : this.startDate,
            endDate : this.endDate,
            frequency : this.frequency,
            id : this.recordId
        };
        createVeaTaskRecord({jsonData : JSON.stringify(jsonData)})    
        .then( result => {  
            if(result == 'true'){
                this.dispatchEvent(
                    new ShowToastEvent( {
                        title: 'Success',
                        message: 'Violation Enforcement Tasks Created Succesfully!',
                        variant: 'success'
                    })
                );
                setTimeout(() => {
                    window.location.reload();
                 }, 1000);
            }else{
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message:  'Violation Enforcement Tasks Cannot be Created',
                        variant: 'error',
                    }),
                );
            }
            
        }).catch( error => { 
            console.log('error ' + JSON.stringify(error)); 
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message:  'Error in creating Violation Enforcement Tasks ',
                    variant: 'error',
                }),
            );
         });         
    }
}