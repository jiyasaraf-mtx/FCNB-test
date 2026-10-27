import { api, LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getDueDiligence from '@salesforce/apex/LPI_ApplicationDueDiligenceCtrl.getDueDiligenceList';
import updateDueDiligence from '@salesforce/apex/LPI_ApplicationDueDiligenceCtrl.updateDueDiligence';
import dueDiligenceAfterApproved from '@salesforce/apex/LPI_ApplicationDueDiligenceCtrl.dueDiligenceAfterApproved';
import Id from '@salesforce/user/Id';
import { updateRecord } from 'lightning/uiRecordApi';
import { loadStyle } from "lightning/platformResourceLoader";
import LPI_InternalCSS from "@salesforce/resourceUrl/LPI_Design";

export default class MtxLpi_ApplicationDueDiligence extends LightningElement {
    @api recordId;
    @track dueDiligenceList = [];
    @track dueDiligenceListCpy = [];
    @track dueDiligenceListAfterApproved = [];
    @track dueDiligenceListAfterApprovedCpy = [];
    isStatusApproved = false;
    showSpinner = false;
    noDdRecords = false;
    noStatusDdRecords = false;
    isDisabled = true;
    isChanged = false;
    responsiblePartyCheck = false;
    noDataFound =  LPI_InternalCSS + '/media/icons/internal-no-data-found.svg';
    connectedCallback() {
        loadStyle(this, LPI_InternalCSS + "/styles/internal-main.css");
        this.loadDueDiligence();
        this.statusReasonApproved();

    }

    get statusOptionsWithNotApplicable() {
        return [
            {
                label: 'Not Applicable',
                value: 'Not Applicable'
            },
            {
                label: 'Not Started',
                value: 'Not Started'
            },
            {
                label: 'In Progress',
                value: 'In Progress'
            },
            {
                label: 'Completed',
                value: 'Completed'
            },
            {
                label: 'Missing',
                value: 'Missing'
            }
        ];
    }


    get statusOptionsWithoutNotApplicable() {
        return [
            {
                label: 'Not Started',
                value: 'Not Started'
            },
            {
                label: 'In Progress',
                value: 'In Progress'
            },
            {
                label: 'Completed',
                value: 'Completed'
            },
            {
                label: 'Missing',
                value: 'Missing'
            }
        ];
    }

    statusReasonApproved() {
        this.showSpinner = true;
        dueDiligenceAfterApproved({
            recordId: this.recordId
        })
            .then(data => {
                if (data) {
                    console.log('approved dd ==> ' + JSON.stringify(data));
                    var tempdata = data;
                    tempdata.forEach(row => {
                        row.isdisable = true;
                        row.convertedDate = row.Completion_Date__c ? (new Date(row.Completion_Date__c).toISOString()) : null;
                        let applicationStatus;
                        if (row.Individual_Application__c != null) {
                            applicationStatus = row.Individual_Application__r.Status;
                        } else {
                            applicationStatus = row.Application__r.Status;
                        }
                        row.isApprover = (Id == row.Responsible_Party__c && (applicationStatus != 'License Issued' && applicationStatus != 'Draft')) ? true : false;
                        if (row.Enable_Not_Applicable__c == true) {
                            row.statusOptions = this.statusOptionsWithNotApplicable;
                        } else {
                            row.statusOptions = this.statusOptionsWithoutNotApplicable;
                        }
                        row.statusClass = 'slds-badge ';
                        if(row.Status == 'In Progress'){
                            row.statusClass = row.statusClass + 'slds-theme_info';
                        } else if(row.Status == 'Not Started' || row.Status == 'Not Applicable'){
                            row.statusClass = row.statusClass + 'slds-theme_disabled';
                        } else if(row.Status == 'Completed'){
                            row.statusClass = row.statusClass + 'slds-theme_success';
                        } else if(row.Status == 'Missing'){
                            row.statusClass = row.statusClass + 'slds-theme_error';
                        }
                        this.dueDiligenceListAfterApproved.push(row);
                    })
                    this.isStatusApproved = true;
                    if (this.dueDiligenceListAfterApproved.length == 0) {
                        this.noDdRecords = true;
                    }
                }
            })
            .catch(error => {
                this.showToast('Error', error.body.message, 'error');
            })
            .finally(() => {
                this.showSpinner = false;
            })
    }

    loadDueDiligence() {
        this.showSpinner = true;
        getDueDiligence({
            recordId: this.recordId
        })
            .then(data => {
                this.dueDiligenceList = [];
                let applicationId;
                let ddList = JSON.parse(data);
                ddList.forEach(row => {
                    row.convertedDate = row.CompletionDate ? (new Date(row.CompletionDate).toISOString()) : null;
                    let applicationStatus;
                    if (row.IndividualApplication != null) {
                        applicationStatus = row.IAStatus;
                        applicationId = row.IndividualApplication;
                    } else if (row.BusinessApplication != null) {
                        applicationStatus = row.BLAStatus;
                        applicationId = row.BusinessApplication;
                    }
                    // row.isApprover = ((Id == row.ResponsiblePartyId || row.isSupportStaff) && (applicationStatus != 'License Issued' && applicationStatus != 'Draft' && applicationStatus != 'Rejected')) ? true : false;
                    row.isApprover = true;//(((Id == row.isSupportStaff) || row.isQueueMember) && (applicationStatus != 'License Issued' && applicationStatus != 'Draft' && applicationStatus != 'Rejected')) ? true : false; //for I-240575
                    if (row.isApprover) {
                        this.responsiblePartyCheck = true;
                    }
                    if (row.EnableNotApplicable == true) {
                        row.statusOptions = this.statusOptionsWithNotApplicable;
                    } else {
                        row.statusOptions = this.statusOptionsWithoutNotApplicable;
                    }
                    row.statusClass = 'slds-badge ';
                    if(row.Status == 'In Progress'){
                        row.statusClass = row.statusClass + 'slds-theme_info';
                    } else if(row.Status == 'Not Started' || row.Status == 'Not Applicable'){
                        row.statusClass = row.statusClass + 'slds-theme_disabled';
                    } else if(row.Status == 'Completed'){
                        row.statusClass = row.statusClass + 'slds-theme_success';
                    } else if(row.Status == 'Missing'){
                        row.statusClass = row.statusClass + 'slds-theme_error';
                    }
                })
                console.log('JSON.stringify(data) ==>> ' + JSON.stringify(JSON.parse(data)));

                this.dueDiligenceList.push({ value: ddList, key: applicationId, showNoDDError: ddList.length == 0 ? true : false });
                console.log('JSON.stringify(this.dueDiligenceList) ==>> ' + JSON.stringify(this.dueDiligenceList));
                this.noStatusDdRecords = this.dueDiligenceList.length == 0 ? true : false;
                this.dueDiligenceListCpy = JSON.parse(JSON.stringify(this.dueDiligenceList));
            })
            .catch(error => {
                this.showToast('Error', error.body, 'error');
            })
            .finally(() => {
                this.showSpinner = false;
            })
    }

    handleEdit(event) {
        this.isDisabled = false;
    }

    showToast(title, msg, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: msg,
            variant: variant,
            mode: 'dismissable'
        });
        this.dispatchEvent(event);
    }

    handleStatusChange(event) {
        const ddindex = event.target.dataset.ddindex;
        const recordindex = event.target.dataset.dataindex;
        this.dueDiligenceList[ddindex].value[recordindex].Status = event.detail.value;
        this.dueDiligenceList[ddindex].value[recordindex].isChanged = true;
        //this.dueDiligenceList[ddindex].value[recordindex].IsCommentRequired = this.dueDiligenceList[ddindex].value[recordindex].Status === 'Missing' ? true : false;


        if (this.dueDiligenceList[ddindex].value[recordindex].Status === 'Missing') {
            this.dueDiligenceList[ddindex].value[recordindex].IsCommentRequired = true;
        } else {
            this.dueDiligenceList[ddindex].value[recordindex].IsCommentRequired = false;
            this.template.querySelector('.required-data').classList.remove('slds-has-error');
        }
        setTimeout(() => {
            this.isInputFieldsValid();
        }, 100);
        this.handleKeyUp(event);

    }
    handleCommentChange(event) {
        const ddindex = event.target.dataset.ddindex;
        const recordindex = event.target.dataset.dataindex;
        let input = event.target.value;
        let sanitizedInput = input.replace(/<[^>]+>/g, '');
        event.target.value = sanitizedInput;
        this.dueDiligenceList[ddindex].value[recordindex].Comment = sanitizedInput;
        this.dueDiligenceList[ddindex].value[recordindex].isChanged = true;
    }
    handleInternalCommentChange(event){
        const ddindex = event.target.dataset.ddindex;
        const recordindex = event.target.dataset.dataindex;
        let input = event.target.value;
        let sanitizedInput = input.replace(/<[^>]+>/g, '');
        event.target.value = sanitizedInput;
        this.dueDiligenceList[ddindex].value[recordindex].internalComment = sanitizedInput;
        this.dueDiligenceList[ddindex].value[recordindex].isChanged = true;
    }
    lookupRecord(event) {
        const ddindex = event.target.dataset.ddindex;
        const recordindex = event.target.dataset.dataindex;
        if (event !== null && event.detail !== null && event.detail !== undefined && event.detail.selectedRecord !== null && event.detail.selectedRecord !== undefined) {
            this.dueDiligenceList[ddindex].value[recordindex].ResponsiblePartyId = event.detail.selectedRecord.Id;
            this.dueDiligenceList[ddindex].value[recordindex].isChanged = true;
        }
    }



    isInputFieldsValid() {
        let validLongText = [...this.template.querySelectorAll('.required-data')].reduce((validSoFar6, input) => {
            input.reportValidity();
            return validSoFar6 && input.checkValidity();
        }, true);

        setTimeout(() => {
            let allInput = this.template.querySelector(".slds-has-error");
            if (allInput) {
                allInput.focus();
            }
        }, 100);

        return validLongText;
    }


    handleRecordChangeSave(event) {
        if (this.isInputFieldsValid()) {
            this.showSpinner = true;
            const recordsToSave = [];

            this.dueDiligenceList.forEach(dd => {
                dd.value.forEach(record => {
                    if (record.isChanged) {
                        let responsiblePartyId;
                        if (record.ResponsiblePartySS != null || record.ResponsiblePartySS != undefined) {
                            responsiblePartyId = record.ResponsiblePartySS;
                        }
                        else {
                            responsiblePartyId = record.ResponsiblePartyId;
                        }
                        recordsToSave.push({
                            Id: record.Id,
                            Status: record.Status,
                            Comment: record.Comment,
                            ResponsiblePartyId: responsiblePartyId,
                            internalComment: record.internalComment
                        });
                    }
                });
            });
            updateDueDiligence({
                record: JSON.stringify(recordsToSave),
                applicationId: this.recordId
            })
                .then(result => {
                    if (result) {
                        this.showToast('Success', 'Updated Successfully', 'success');
                        this.isDisabled = true;
                        this.loadDueDiligence();
                    } else {
                        this.showToast('Error', 'You are not allowed to edit.', 'error');
                        this.dueDiligenceList[ddindex]['value'][recordindex] = JSON.parse(JSON.stringify(this.dueDiligenceListCpy[ddindex]['value'][recordindex]));
                    }
                })
                .catch(error => {
                    this.showToast('Error', error.body.message, 'error');
                    this.dueDiligenceList[ddindex]['value'][recordindex] = JSON.parse(JSON.stringify(this.dueDiligenceListCpy[ddindex]['value'][recordindex]));
                    this.dueDiligenceList[ddindex] = JSON.parse(JSON.stringify(this.dueDiligenceListCpy[ddindex]));
                })
                .finally(() => {
                    this.showSpinner = false;
                })
        }
    }

    handleRecordEditCancel(event) {
        this.dueDiligenceList = JSON.parse(JSON.stringify(this.dueDiligenceListCpy));
        this.isDisabled = true;
        this.template.querySelector('.required-data').classList.remove('slds-has-error');
        setTimeout(() => {
            this.isInputFieldsValid();
        }, 100);
    }
    handleKeyUp(event) {
        event.currentTarget.reportValidity();
    }
}