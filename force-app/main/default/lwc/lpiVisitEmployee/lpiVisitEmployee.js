import { LightningElement,api,track,wire } from 'lwc';
import getInscpetcionQuestion from '@salesforce/apex/LPI_VisitController.getInscpetcionQuestion'
import {
    showAsyncErrorMessage,
    showMessage
} from 'c/lpiUtil';
import { refreshApex } from '@salesforce/apex';
import { loadStyle } from "lightning/platformResourceLoader";
import LPI_InternalCSS from "@salesforce/resourceUrl/LPI_Design";

const actions = [
    { label: 'Edit', name: 'edit' }
];
export default class LpiVisitEmployee extends LightningElement {
    noDataFound =  LPI_InternalCSS + '/media/icons/internal-no-data-found.svg';
    @api recordId;
    @track employeeRecordData = null;
    @track columns = [];
    @track columnsToCreateInsCon = [];
    isEditRecord = false;
    isCreateRecord = false;
    inspectionResult;
    showSpinner = false;
    showSpinnerPopUp = false;
    showEmployeeTable = false;
    hasRecords = true;
    allowedToCreate;
		
    connectedCallback() {
				console.log('Entered Call back');
        this.showSpinner = true;
       // console.log('Entered Call back');
    }

    get showAddButton() {
        return this.hasRecords && this.allowedToCreate;
    }

    @wire(getInscpetcionQuestion,{recordId : '$recordId'})
    inspectionRec(result){
        console.log('result>>>'+JSON.stringify(result));
        this.showSpinner = true;
        this.inspectionResult = result;
        if(result.data == null){
            this.showEmployeeTable = false;
            this.showSpinner = false;
        }
        if(result.data){
            this.showSpinner = false;
            if (!result.data) {
                return;
            }
            if (result.data.ratInspectionQuestionRec.length > 0) {
                console.log('Inspection Question cond');
                const {form:formDetails} = JSON.parse(result.data.ratInspectionQuestionRec[0].Inspection_Questions__c);
                console.log('FD...'+JSON.stringify(formDetails,null,2));
                console.log('Form Details>>>>'+formDetails);
                this.columns = this.generateColumns(formDetails); 
                console.log('columns...'+ this.columns);
                this.columnsToCreateInsCon = this.generateColToCreateInsCon(formDetails);
                console.log('columns to create....'+ this.columnsToCreateInsCon);
                this.allowedToCreate = result.data.allowedToCreate[0];
                if(result.data.inspectionContentList && result.data.inspectionContentList.length > 0){
                    this.showEmployeeTable = true;
                    this.employeeRecordData = result.data.inspectionContentList;
                }
            } else {
                this.hasRecords = false;
            }
        }else if(result.error){
            this.showSpinner = false;
            showAsyncErrorMessage(this, result.error);
        }
    }

    refreshData() { 
        this.showSpinner = false;
        return refreshApex(this.inspectionResult);
    }
    handleOpenEmployeeModal() {
        this.showEmployeeModal = true;
    }

    generateColumns(questions) {
        
        const columns = questions.map(question => {
            return {
                label: question.question,
                fieldName: question.apiName,
                type : 'text',
                wrapText : true,
            };
        });
        if(this.allowedToCreate){
            columns.push({
                type: 'action',
                typeAttributes: { rowActions: actions },
                doNotLoad : true
            });
        }
       

        return columns;
    }

    generateColToCreateInsCon(questions){
        console.log('Entered Generate Columns>>>>'+questions);
        const columns = questions.map(question => {
            return {
                label: question.question,
                fieldName: question.apiName
            };
        });

        columns.push({
            label: 'Inspection',
            fieldName: 'Inspection__c',
            value : this.recordId,
            doNotLoad : true
        });

        return columns;
    }

    handleSpinner(){
        this.showSpinnerPopUp = false;
    }

    handleEditRow( event ) {  
        this.isEditRecord = true;
        this.showSpinnerPopUp = true;
        this.rowId = event.detail.row.Id;
    }

    createInspectionContent(){
        this.isCreateRecord = true;
        this.showSpinnerPopUp = true;
    }

    handleSubmit(event) {
        this.showSpinner = true;
        this.isEditRecord = false;
        this.isCreateRecord = false;
        this.refreshData();
    }
    handleSuccessEdit(event) {
        this.refreshData();
        showMessage(this, {
            title: "Success",
            message: 'Employee detail updated Successfully.',
            messageType: "success",
            mode: "dismissable"
        });
    }

    handleSuccessNew(event){
        this.refreshData();
        showMessage(this, {
            title: "Success",
            message: 'Employee detail added successfully.',
            messageType: "success",
            mode: "dismissable"
        });
    }

    closeModal(){
        this.isEditRecord = false;
        this.isCreateRecord = false;
    }

    connectedCallback() {
        loadStyle(this, LPI_InternalCSS + "/styles/internal-main.css");
    }
}