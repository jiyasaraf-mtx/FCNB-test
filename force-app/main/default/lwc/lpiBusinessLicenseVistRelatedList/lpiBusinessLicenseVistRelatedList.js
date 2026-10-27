import { LightningElement, api, track } from 'lwc';
import {NavigationMixin} from 'lightning/navigation';
import {
    showAsyncErrorMessage
} from 'c/lpiUtil';
import fetchBlRelatedVisitRecords from '@salesforce/apex/LPI_NewVisitRecord.fetchBlRelatedVisitRecords';
import fetchAdhocInspections from '@salesforce/apex/LPI_NewVisitRecord.fetchAdhocInspections';

import lpiTheme from "@salesforce/resourceUrl/LPI_Design";
import { loadStyle, loadScript } from "lightning/platformResourceLoader";

const COLOUMNS =  [
    {
        label: 'Name',
        fieldName: 'visitRecUrl',
        type: 'url',
        typeAttributes: {label: { fieldName: 'visitName' }, 
        target: '_blank'}
    },
    {label : 'Inspection Type', fieldName : 'visitTypeName'},
    {label : 'Number of Open Violations', fieldName : 'noOfOpenViolations'},
    {label : 'Status', fieldName : 'vStatus'},
    {
        label: 'Date of Inspection', 
        fieldName : 'vPlannedStartTime', 
        type: 'date',
        typeAttributes: {
            day: "numeric",
            month: "numeric",
            year: "numeric"
        }
    }
];

const ADHOC_COLUMNS = [
    {
        label: 'Name',
        fieldName: 'visitRecUrl',
        type: 'url',
        typeAttributes: {label: { fieldName: 'visitName' }, 
        target: '_blank'}
    },
    {label : 'Status', fieldName : 'vStatus'},
    {label : 'Planned Start Date', fieldName : 'plannedStartTime', 
    type: 'date',
    typeAttributes: {
        day: "numeric",
        month: "numeric",
        year: "numeric"
    }}
];
export default class LpiBusinessLicenseVistRelatedList extends LightningElement {
    @api recordId;
    columns = COLOUMNS;
    @track visitsData;
    modalOpen = false;
    connectedCallback() {
        if(this.recordId) {
            this.columns = COLOUMNS;
            this.handleFetchBlRelatedVisitRecords();
        } 
        else {
            this.columns = ADHOC_COLUMNS;
            this.fetchAdhocInspections();
        }

        loadStyle(this, lpiTheme + "/styles/internal-main.css");
        
    }

    get isAdhocVisitListView() {
        return !this.recordId;
    }

    get openNewAdhocModal() {
        return this.modalOpen;
    }

    handleFetchBlRelatedVisitRecords(){
        fetchBlRelatedVisitRecords({
            recordId: this.recordId
        }).then(result => {
            let visitRecUrl;
            if (result != null) {
                this.visitsData = result.map( row => {
                    visitRecUrl = `/${row.visitId}`;
                    return {...row, visitRecUrl}
                })
            }
            console.log('==>'+JSON.stringify(this.visitsData));
        }).catch((error) => {
            showAsyncErrorMessage(this, error);
        }).finally(() => {})
    }

    handleVisitRowAction(event){
        this[NavigationMixin.Navigate]({
                "type": "standard__recordPage",
                "attributes": {
                    "recordId": '/' +event.detail.row.visitId,
                    actionName: 'view'
                }
            });
    }

    fetchAdhocInspections() {

        fetchAdhocInspections()
        .then(result=>{
            if(!result.recordList)  {
                return;
            }
            this.visitsData = result.recordList.map(row => {
                const visitRecUrl = `/${row.visitId}`;
                return { 
                    visitRecUrl,
                    visitTypeName : row.visitTypeId,
                    vStatus : row.vStatus,
                    plannedStartTime : row.vPlannedStartTime,
                    visitName : row.visitName
                }
            })
            
        })
        .catch(error=>{
            showAsyncErrorMessage(this, error);
        })
    }

    toggleModalController(){
        this.modalOpen = !this.modalOpen;
    }

    handleSaveVisit(){
        let cmp = this.template.querySelector('c-lpi-new-visit-record');
        if(cmp){
            cmp.handleCreateNewVisit();
        }
    }
    
}