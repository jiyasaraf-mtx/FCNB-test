import { LightningElement, api, track } from "lwc";
import getFilteredLicenseRecords from "@salesforce/apex/LPI_AuditRandomSelectorController.getFilteredLicenseRecords";
import fetchProfessions from "@salesforce/apex/LPI_AuditRandomSelectorController.fetchProfessions";
import fetchAuditData from "@salesforce/apex/LPI_AuditRandomSelectorController.fetchAuditData";
import getRandomRecords from "@salesforce/apex/LPI_AuditRandomSelectorController.getRandomRecords";
import auditLicenses from "@salesforce/apex/LPI_AuditRandomSelectorController.auditLicenses";
import {ShowToastEvent} from "lightning/platformShowToastEvent";
import { NavigationMixin } from "lightning/navigation";

import { loadStyle } from 'lightning/platformResourceLoader';
import LPI_InternalCSS from "@salesforce/resourceUrl/LPI_Design";
// import InternalStyle from '@salesforce/resourceUrl/InternalStyle';

const TABEL_COLUMNS = [
    { label: 'License Number', fieldName: 'BlUrl', type: 'url', typeAttributes: { label: { fieldName: 'Name' }, target: '_blank' } },
    { label: 'Licensee Name', fieldName: 'EntityName', type: 'String' },
    { label: 'Issuance Date', fieldName: 'PeriodStart', type: 'date' },
    { label: 'Expiration Date', fieldName: 'PeriodEnd', type: 'date' }
];
// Define constants for configuration values
const IS_APPLICABLE_FOR_ACTIVE_LICENSE = 'Is Applicable for Active License';
const CANNOT_AUDIT_TWO_YEARS_IN_A_ROW = 'Cannot Audit Two Years in a Row';
const CANNOT_AUDIT_DURING_FIRST_RENEWAL = 'Cannot Audit during First Renewal';
 

export default class LpiAuditRandomSelector extends NavigationMixin(LightningElement) {
	//Common variables accross the steps
	stepNumber = 1;
    isProcessing = false;
    @api boardId;
    tableColumns = TABEL_COLUMNS;
    auditData;
    totalPage = 0;
    pageSize = 18;
    page = 1;
    startingRecord = 1;
    endingRecord = 0;
    noDataFound =  LPI_InternalCSS + '/media/icons/internal-no-data-found.svg';
	//Variables for step-1
    auditType;
    boardName;
    auditTypeOptions = [];
    data = [];
	disciplinaryActionOptions = [
		{ label: "Probation", value: "Probation" },
		{ label: "Suspension", value: "Suspension" },
        { label: "Open Complaints", value: "Open Complaints"}
	];
	professionOptions = [];
	selectedDiscAction;
	selectedProfession;
    selectedProfessionValue;
    selectedExpDate;
	selectedIssueDateFrom;
    selectedIssueDateTo
    isApplicableforActiveLicense = false;
    lastAuditCheck = false;
    firstRenewalCheck = false;
    //Added by piyush aneja
    selectedSubProfession;
    subProfessionOptions = [
        { label: "Meridian therapy/acupressure/acupuncture (MTAA)/Insurance Consultant", value: "MTAA + Insurance Consultant"},
        { label: "Doctor of Chiropractic (DC) Insurance Consultant", value: "Insurance Consultant"},
        { label: "Doctor of Chiropractic (DC)/Meridian therapy/acupressure/acupuncture (MTAA)", value: "MTAA"}
    ];

	//variables for step-2
	filteredRecordCount;
    auditLicensesBy;
    recordsCount;
    recordsPercentage;
    @track totalFilteredLicenses = [];
    @track existingAuditRecords = [];

    auditLicenseRecordsLength;
    @track auditLicenseRecords = [];
    auditLicensesByOptions = [
		{ label: "Percentage", value: "Percentage" },
		{ label: "Count", value: "Count" }
	];
    selectedAuditYears;

    get auditByPercentage() {
        return this.auditLicensesBy === 'Percentage' ? true : false;
    }
    get auditByCount() {
        return this.auditLicensesBy === 'Count' ? true : false;
    }
    get showSubProfessions() {
        const subProfessions = ['Chiropractic Physician', 'Continuing Education Provider', 'Chiropractic Physician Temp'];
        return subProfessions.includes(this.selectedProfession);
    }

    //Step variables
	get showFirstStep() {
		return this.stepNumber === 1;
	}
	get showSecondStep() {
		return this.stepNumber === 2;
	}
    get showThiredStep() {
		return this.stepNumber === 3;
	}
    get showPreviousButton() {
		return this.stepNumber === 1 ? false : true;
	}
    get showNextButton() {
		return this.stepNumber === 3 ? false : true;
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

    


    connectedCallback(){
        this.isProcessing = true;
        console.log('boardId :>> ', this.boardId);
            fetchAuditData({issuingDepartmentId: this.boardId})
            .then((auditResult)=>{
                this.auditData = JSON.parse(JSON.stringify(auditResult));
                this.auditTypeOptions = this.auditData.auditTypes;
                this.noResponseNotificationPeriod = this.auditData.noResponseNotificationPeriod;
                this.reminderNotificationPeriod = this.auditData.reminderNotificationPeriod;
                this.boardName = this.auditData.boardName;
            })
            .catch((error)=>{
                this.showMessage('Error',JSON.stringify(error),'error');
             })
            .finally(()=>{
                this.isProcessing = false;
            });

            this.fetchProfessions();

            Promise.all([
                loadStyle(this, LPI_InternalCSS + "/styles/internal-main.css")
                // loadStyle(this, InternalStyle)
            ]).then(() => {
            }).catch(error => {
            });    
    }

    fetchProfessions(){
        this.isProcessing = true;
        fetchProfessions({issuingDepartmentId: this.boardId, auditType: this.auditType})
            .then((result)=>{
                this.professionOptions = result;
            })
            .catch((error)=>{
                this.showMessage('Error',JSON.stringify(error),'error');
            })
            .finally(()=>{
                this.isProcessing = false;
            });
        
    }

	handleChange(e) { 
		if (e.target.name === "discAction") {
			this.selectedDiscAction = e.target.value;
		} else if (e.target.name === "profession") {
            this.selectedProfessionValue = e.target.value;
            let arr = e.target.value.split('-##-');
			this.selectedProfession = arr[0];
            this.minimumCeHours = arr[1];
            let configArr = arr[2].split(';');

            // Check if the configArr includes each configuration
            if (configArr.includes(IS_APPLICABLE_FOR_ACTIVE_LICENSE)) {
                this.isApplicableforActiveLicense = true;
            }

            if (configArr.includes(CANNOT_AUDIT_TWO_YEARS_IN_A_ROW)) {
                this.lastAuditCheck = true;
            }

            if (configArr.includes(CANNOT_AUDIT_DURING_FIRST_RENEWAL)) {
                this.firstRenewalCheck = true;
            }
		} else if (e.target.name === "expDate") {
			this.selectedExpDate = e.target.value;
		} else if (e.target.name === "issuanceDateFrom") {
			this.selectedIssueDateFrom = e.target.value;
		} else if (e.target.name === "issuanceDateTo") {
			this.selectedIssueDateTo = e.target.value;
		} else if (e.target.name === "auditLicensesBy") {
			this.auditLicensesBy = e.target.value;
		} else if (e.target.name === "recordsPercentage") {
			this.recordsPercentage = e.target.value;
		} else if (e.target.name === "recordsCount") {
			this.recordsCount = e.target.value;
		} else if (e.target.name === "auditType") {
			this.auditType = e.target.value;
            this.fetchProfessions();
            this.selectedProfessionValue = null;
            this.selectedProfession = null;
		} else if (e.target.name === "subProfession") {
			this.selectedSubProfession = e.target.value;
		}else if(e.target.name === 'auditYear'){
            this.selectedAuditYears = e.target.value;
        }
	}

	handleNextButton() {
        if(this.isInputValid()){
            this.stepNumber += 1;
            if (this.stepNumber === 2) {
                this.getFilteredLicenseRecords();
            } else if (this.stepNumber === 3 ) {
                this.getRandomRecords();
            }
        }
	}

	handlePrevButton() {
		this.stepNumber -= 1;
	}

    navigateToBoardRecordPage() {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.boardId,
                objectApiName: 'RegulatoryAuthority',
                actionName: 'view'
            },
        }, true);
    }

	getFilteredLicenseRecords() {
        this.isProcessing = true;
		let params = {
			selectedDiscAction: this.selectedDiscAction,
			selectedProfession: this.selectedProfession,
			selectedExpDate: this.selectedExpDate,
			selectedIssueDateFrom: this.selectedIssueDateFrom,
            selectedIssueDateTo: this.selectedIssueDateTo,
            selectedSubProfession: this.selectedSubProfession,
            minimumCeHours: this.minimumCeHours,
            isApplicableforActiveLicense: this.isApplicableforActiveLicense,
            auditType: this.auditType,
            lastAuditCheck: this.lastAuditCheck,
            firstRenewalCheck: this.firstRenewalCheck
		};
        if(this.auditType === "Certification_Audit" && this.boardName === "Private Investigator and Private Fire Investigator Examiners"){
            this.noResponseNotificationPeriod = 30;
            this.reminderNotificationPeriod = 15;
        }
        getFilteredLicenseRecords({filters: JSON.stringify(params), discActionList: this.selectedDiscAction})
            .then((result)=>{
                this.totalFilteredLicenses = JSON.parse(JSON.stringify(result));
                this.filteredRecordCount = this.totalFilteredLicenses.length;
            })
            .catch((error)=>{
                this.showMessage('Error',error?.body?.message,'error');
             })
             .finally(()=>{
                this.isProcessing = false;
            });
	}

    getRandomRecords(){
        
        this.isProcessing = true;
        let recordsCountToPick = 0;
        if(this.auditByPercentage){
            recordsCountToPick = (this.recordsPercentage/100) * this.filteredRecordCount;
        } else {
            recordsCountToPick = this.recordsCount;
        }
    
        if(recordsCountToPick >= 1 && recordsCountToPick <= this.filteredRecordCount){
            getRandomRecords({inputData: JSON.stringify(this.totalFilteredLicenses), auditSize: Math.round(recordsCountToPick)})
                .then((result)=>{
                    this.auditLicenseRecords = JSON.parse(JSON.stringify(result));
                    this.processRecords(this.auditLicenseRecords);
                    this.auditLicenseRecordsCount = this.auditLicenseRecords.length;
                })
                .catch((error)=>{
                    this.showMessage('Error',JSON.stringify(error),'error');
                })
                .finally(()=>{
                    this.isProcessing = false;
                });
        } else {
            this.stepNumber -= 1;
            this.isProcessing = false;
            if(this.filteredRecordCount !== 0){
                this.showMessage('Enter valid input.');
            } else {
                this.showMessage('There should be atleast one record to move forward.');
            }
            
        }

        
    }

    handleAuditLicenses(){
        this.isProcessing = true;
        auditLicenses({
            blListToAudit: JSON.stringify(this.auditLicenseRecords), 
            auditType: this.auditType, 
            noResponseNotificationPeriod: this.noResponseNotificationPeriod,
            reminderNotificationPeriod: this.reminderNotificationPeriod,
            selectedAuditYear: this.selectedAuditYears?.toString()
        })
        .then((result)=>{
            if(result){
                this.showMessage('Success','License audit initiated.','success');
                this.navigateToBoardRecordPage();
            } else {
                this.showMessage('Error','An error occured while license audit.','error');
            }
        })
        .catch((error)=>{
            this.showMessage('Error',JSON.stringify(error),'error');
        })
         .finally(()=>{
            this.isProcessing = false;
        });
    }

    //Data table
    processRecords(data) {
        this.items = data;
        /*this.items.forEach(res => {
            res.blLink = '/' + res.Id;
        });*/
        if (data.length > 0) {
            this.showTable = true;
        }
        this.auditLicenseRecordsCount = data.length;
        this.totalPage = Math.ceil(this.auditLicenseRecordsCount / this.pageSize);

        this.data = this.items.slice(0, this.pageSize);
        this.endingRecord = this.pageSize;
    }

    //clicking on previous page button this method will be called
    previousHandler() {
        this.isPageChanged = true;
        if (this.page > 1) {
            this.page = this.page - 1; //decrease page by 1
            this.displayRecordPerPage(this.page);
        }
    }
    //clicking on next button this method will be called
    nextHandler() {
        this.isPageChanged = true;
        if ((this.page < this.totalPage) && this.page !== this.totalPage) {
            this.page = this.page + 1; //increase page by 1
            this.displayRecordPerPage(this.page);
        }
    }

    //this method displays records page by page
    displayRecordPerPage(page) {

        this.startingRecord = ((page - 1) * this.pageSize);
        this.endingRecord = (this.pageSize * page);

        this.endingRecord = (this.endingRecord > this.auditLicenseRecordsCount)
            ? this.auditLicenseRecordsCount : this.endingRecord;

        this.data = this.items.slice(this.startingRecord, this.endingRecord);
        this.startingRecord = this.startingRecord + 1;
    }


    showMessage(title, message, variant) {
		const toastEvt = new ShowToastEvent({
			title,
			message,
			variant
		});
		this.dispatchEvent(toastEvt);
	}

    isInputValid() {
		let isValid = true;
        if(this.issuanceDateFrom < this.issuanceDateTo){
            this.showMessage('Date Error','Please enter valid Issuance date period.','error');
            return false;
        }
		let inputFields = this.template.querySelectorAll(".validate");
		inputFields.forEach((inputField) => {
			if (!inputField.checkValidity()) {
				inputField.reportValidity();
				isValid = false;
			}
		});
		return isValid;
	}
    
}