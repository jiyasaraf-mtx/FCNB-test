import { LightningElement,api,track} from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getApplicationReviewData from '@salesforce/apex/LPI_ApplicationReviewAndUpdateCtrl.getApplicationReviewData'
import updateRecords from '@salesforce/apex/LPI_ApplicationReviewAndUpdateCtrl.updateRecords'
import {
    ShowToastEvent
} from 'lightning/platformShowToastEvent';
import LPI_InternalCSS from "@salesforce/resourceUrl/LPI_Design";
import { updateRecord } from 'lightning/uiRecordApi';
export default class Lpi_applicationChecklistUpdate extends NavigationMixin(LightningElement) {
    showSpinner = false;
    showViewModal = false;
    showApproveButton = false;
    selectedRecordId = '';
    selectedObjectName = '';
    allDisabled = false;
    showList = false;
    @track checklistData = [];
    @track updatedMap = {};
    @track changeRecordId = [];
    @track viewFields = [];
    @track updatedFields ={};
    @track selectedIndex;
    _recordId;
    noDataFound =  LPI_InternalCSS + '/media/icons/internal-no-data-found.svg';
    @api 
    set recordId(value) {
        this.showSpinner = true;
        this._recordId = value;
        this.getApplicationReviewData();
    }
    get recordId() {
        return this._recordId;
    }
    getApplicationReviewData(){
        getApplicationReviewData({
            recordId : this._recordId
        }).then(result =>{
            if(result != null){
                this.checklistData = JSON.parse(JSON.stringify(result.checklistWrapList));
                this.allDisabled = result.allDisabled;
                this.showList = false;
                if(this.checklistData.length > 0){
                    this.showList = true;
                }
            }
            this.showSpinner = false;
        }).catch((error) => {
            this.showToast("Error", error.body.message, "error");
            this.showSpinner = false;
        })
    }
    showToast(title, message, variant) {
        const evt = new ShowToastEvent({
           title: title,
           message: message,
           variant: variant,
        });
        this.dispatchEvent(evt);
    }
    handleChange(event){
        let recordId = event.target.dataset.id;
        let apiName = event.target.dataset.apiname;
        let objName = event.target.dataset.objname;
        if(recordId in this.updatedMap){
            if(apiName == 'IsActive__c'){
                this.updatedMap[recordId][apiName] = event.target.checked;
            }else{
                this.updatedMap[recordId][apiName] = event.target.value;
            }
        }else{
            const obj = {};
            if(apiName == 'IsActive__c'){
                obj[apiName] = event.target.checked;
            }else{
                obj[apiName] = event.target.value;
            }
            obj['Id'] = recordId;
            const obj1 = {};
            obj1["type"]=objName;
            obj['attributes'] = obj1;
            this.updatedMap[recordId] = obj;
        }
        this.changeRecordId.push(recordId);
    }
    handleViewButtton(event){
        this.selectedRecordId = '';
        this.selectedObjectName = '';
        this.selectedRecordId = event.target.dataset.recordid;
        this.selectedObjectName = event.target.dataset.objname;
        let index = event.target.dataset.ind;
        this.selectedIndex = index;
        this.viewFields = [];
        let data = this.checklistData[index]['fieldsVisibleOnView'];
        let fieldsData = [];
        data.forEach(row=>{
            let obj = {};
            obj['fieldApiName'] = row;
            obj['objectApiName'] = this.selectedObjectName;
            fieldsData.push(obj);
        })
        this.viewFields = fieldsData;
        if(this.checklistData[index]['showButtons']){
            this.showApproveButton = true;
        }else{
            this.showApproveButton = false;
        }
        this.updateRecordView(this.selectedRecordId);
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        setTimeout(() => {
            this.showViewModal = true;
        }, 500);
        
    }
    isValid() {
        let isAllValid = true;
        this.changeRecordId.forEach((row)=>{
            if(isAllValid){
                isAllValid = [...this.template.querySelectorAll(`[data-id='${row}']`)].reduce((validSoFar, input) => {
                    input.reportValidity();
                    if (input.checkValidity() == false) {
                        input.focus();
                    }
                    return validSoFar && input.checkValidity();
                }, true);
            }
        })
        return isAllValid;
    }
    handleSaveAll(){
        if(this.isValid()){
            this.showSpinner = true;
            let updatedList = [];
            for(const [key, value] of Object.entries(this.updatedMap)) {
                    updatedList.push(this.updatedMap[key]);
            }
            if(updatedList.length > 0){
                this.updateRecords(updatedList);
            }else{
                this.showSpinner = false;
                this.showToast("Error",'No Records To Update!!', "error");
            }
        }
    }
    updateRecords(updatedList){
        updateRecords({
            dataList : JSON.stringify(updatedList)
        }).then(result =>{
            this.showToast("Success",'Records Updated Successfully!!', "success");
            this.checklistData = [];
            this.updatedMap = {};
            this.selectedIndex = '';
            this.getApplicationReviewData();
        }).catch((error) => {
            this.showToast("Error", error.body.message, "error");
            this.showSpinner = false;
        })
    }
    hideViewModalBox(){
        this.showViewModal = false;
        this.selectedIndex = '';
        this.selectedRecordId = '';
        this.selectedObjectName = '';
    }
    handleApproveButtton(){
        this.showViewModal = false;
        this.showSpinner =true;
        this.updatedFields = this.checklistData[this.selectedIndex]['onApproveFields'];
        if(this.updatedFields != undefined){
            const obj1 = {};
            obj1["type"]=this.selectedObjectName;
            this.updatedFields['attributes'] = obj1;
            this.updatedFields['Id'] = this.selectedRecordId;
            let updatedList = [];
            updatedList.push(this.updatedFields);
            this.updateRecords(updatedList);
        }else{
            this.showToast("Error",'Something went wrong!!', "error");
        }
        
    }
    handleRejectButtton(){
        this.showViewModal = false;
        this.showSpinner =true;
        this.updatedFields = this.checklistData[this.selectedIndex]['onRejectFields'];
        if(this.updatedFields != undefined){
            const obj1 = {};
            obj1["type"]=this.selectedObjectName;
            this.updatedFields['attributes'] = obj1;
            this.updatedFields['Id'] = this.selectedRecordId;
            let updatedList = [];
            updatedList.push(this.updatedFields);
            this.updateRecords(updatedList);
        }else{
            this.showToast("Error",'Something went wrong!!', "error");
        }
    }
    navigateToRecordViewPage(event){
        this[NavigationMixin.GenerateUrl]({
            type: "standard__recordPage",
            attributes: {
                recordId: event.target.dataset.lookup,
                actionName: 'view'
            }
        }).then(url => {
            window.open(url, "_blank");
        });
    }
    updateRecordView(recordId) {
        updateRecord({fields: { Id: recordId }});
    }
}