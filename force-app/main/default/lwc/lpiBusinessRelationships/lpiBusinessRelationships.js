import { LightningElement,api,track,wire } from 'lwc';
import getEmployeeRec from '@salesforce/apex/LPI_VisitController.getEmployeeDetails';
import {
    showAsyncErrorMessage
} from 'c/lpiUtil';
import {CurrentPageReference} from 'lightning/navigation';
import LPI_InternalCSS from "@salesforce/resourceUrl/LPI_Design";
export default class LpiBusinessRelationships extends LightningElement {
    @api recordId;
    @track employeeRecordData;
    noDataFound =  LPI_InternalCSS + '/media/icons/internal-no-data-found.svg';
    get hasRecords() {
        return this.employeeRecordData && this.employeeRecordData.length > 0;
    }

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.recordId = this.recordId || currentPageReference.state.recordId;
        }
    }
    columns = [
        {
            label: 'Account Name',
            fieldName: 'accRecordUrl',
            type: 'url',
            typeAttributes: {label: { fieldName: 'accName' }, 
            target: '_blank'}
        },
        { label: 'Role', fieldName: 'Roles__c' }
    ];

    connectedCallback() {
        this.handleFetchEmployeeDetails();
    }

    handleFetchEmployeeDetails(){
        getEmployeeRec({
            recordId: this.recordId
        }).then(result =>{
            let accRecordUrl;
            if (result != null) {
                this.employeeRecordData = result.map( row => {
                    accRecordUrl = `/${row.Related_To__c}`;
                    return {...row, accRecordUrl, accName : row.Related_To__r.Name}
                })
            }
        }).catch(error => {
            showAsyncErrorMessage(this, error);
        })
    }
}