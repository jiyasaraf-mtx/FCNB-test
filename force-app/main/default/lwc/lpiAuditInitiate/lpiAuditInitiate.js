import { LightningElement,  api, track,wire } from 'lwc';
import fetchAuditData from "@salesforce/apex/LPI_AuditInitiateController.fetchAuditData";
import saveAuditData from "@salesforce/apex/LPI_AuditInitiateController.saveAuditData";
import {ShowToastEvent} from "lightning/platformShowToastEvent";
import { NavigationMixin,CurrentPageReference } from "lightning/navigation";
import { showAsyncErrorMessage } from "c/lpiUtil";
import { CloseActionScreenEvent } from "lightning/actions";


export default class LpiAuditInitiate extends NavigationMixin(LightningElement) {

    isProcessing = false;
    auditData;
    auditType;
    boardName;
    auditTypeOptions = [];
    data = [];
    auditId;
    selectedSubProfession;
    openConfirmationModal;
    selectedAuditYears;

    subProfessionOptions = [
    { label: "Meridian therapy/acupressure/acupuncture (MTAA)/Insurance Consultant", value: "MTAA + Insurance Consultant"},
    { label: "Doctor of Chiropractic (DC) Insurance Consultant", value: "Insurance Consultant"},
    { label: "Doctor of Chiropractic (DC)/Meridian therapy/acupressure/acupuncture (MTAA)", value: "MTAA"}
    ];

    @api recordId;
    
    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
         this.recordId = currentPageReference.state.recordId;
        }
    } 

    connectedCallback(){       

        this.isProcessing = true;
        fetchAuditData({licenseId: this.recordId})
        .then((auditResult)=>{
            this.auditData = JSON.parse(JSON.stringify(auditResult));
            this.auditTypeOptions = this.auditData.auditTypes;
            this.boardName = this.auditData.boardName;
            this.showSubProfessions = this.auditData.showSubProfession;
        })
        .catch((error)=>{
            showAsyncErrorMessage(this, error);
            })
        .finally(()=>{
            this.isProcessing = false;
        });
    }

    get showYearPickList(){
        return this.boardName === 'Accountancy';
    }

    get yearOptions(){
        let currYear = new Date().getFullYear();
        let yearOptionList = [];
        for(let counter=0;counter<5;counter++){
            yearOptionList.push({label: currYear.toString(), value: currYear.toString()});
            currYear--;
        }
        return yearOptionList;
    }

    handleChange(e){ 
        if (e.target.name === "auditType") {
			this.auditType = e.target.value;
		} else if (e.target.name === "subProfession") {
			this.selectedSubProfession = e.target.value;
		}else if(e.target.name === 'auditYear'){
            this.selectedAuditYears = e.target.value;
        }
	}

    validateFields() {
        this.focus = false;
        this.focusIndex = -1;
        let isAllValid = [...this.template.querySelectorAll('lightning-combobox')].reduce((validSoFar, input) => {
            input.reportValidity();
            return validSoFar && input.checkValidity();
        }, true);

        return isAllValid;
	}

    handleSaveButton(){
        this.isProcessing = true;
        if (this.validateFields()) {
        saveAuditData({
            auditData: JSON.stringify(this.auditData), 
            auditType: this.auditType, 
            subProfession: this.selectedSubProfession,
            selectedYear: this.selectedAuditYears?.toString()
        })
            .then((result)=>{
                if(result){
                    this.auditId = result.auditId;
                    if(result.resultFound){
                        this.openConfirmationModal = true;
                    }else{
                        this.showMessage('Success','Audit created.','success');
                        this.navigateToBoardRecordPage(result);
                    }
                    
                } else {
                    showAsyncErrorMessage(this, error);
                }
            })
            .catch((error)=>{
                showAsyncErrorMessage(this, error);
            })
             .finally(()=>{
                this.isProcessing = false;
            });
        }else {
             showAsyncErrorMessage(this, "Required Field Missing");
             this.isProcessing = false;
            }
    }

    handleCancelButton(){
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    handleCancelConfirmation(){
        this.openConfirmationModal = false;
    }
    
    navigateToBoardRecordPage() {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.auditId,
                objectApiName: 'Audit_Detail__c',
                actionName: 'view'
            },
        }, true);
    }

    showMessage(title, message, variant) {
		const toastEvt = new ShowToastEvent({
			title,
			message,
			variant
		});
		this.dispatchEvent(toastEvt);
	}

}