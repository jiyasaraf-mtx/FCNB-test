import {
    LightningElement,
    api,
    track
} from 'lwc';
import {
    NavigationMixin
} from 'lightning/navigation';
import getInspectionQuestions from '@salesforce/apex/LPI_AssessmentTaskController.getInspectionQuestions';
import handleSaveInspectionQues from '@salesforce/apex/LPI_AssessmentTaskController.handleSaveInspectionQues';
import updateTaskStatus from '@salesforce/apex/LPI_AssessmentTaskController.updateTaskStatus';
import createApplicationDocument from '@salesforce/apex/LPI_VisitRegCodeViolationController.createApplicationDocument';
import getFileScanResult from '@salesforce/apex/LPI_OnBaseIntegrationController.bypassOnbase';
import downloadFile from '@salesforce/apex/LPI_OnBaseIntegrationController.downloadFileFromSf';
import handleFileDelete from '@salesforce/apex/LPI_OnBaseIntegrationController.handleFileDelete';
// import handleCancel from '@salesforce/apex/LPI_OnBaseIntegrationController.handleCancel';
import handleContentDocumentDelete from '@salesforce/apex/LPI_OnBaseIntegrationController.handleContentDocumentDelete';
import fileScanSetTimoutValue from '@salesforce/label/c.Upload_File_Scan_Timeout_Value';
import {
    RefreshEvent
} from 'lightning/refresh';
import { getRecordNotifyChange } from 'lightning/uiRecordApi';

import {
    showMessage,
    showAsyncErrorMessage,
    checkLength
} from 'c/lpiUtil';

import { loadStyle } from "lightning/platformResourceLoader";
import lpiTheme from "@salesforce/resourceUrl/LPI_Design";
import DocumentFormats from '@salesforce/label/c.DocumentFormats';


export default class LpiAssessmentTaskCmp extends NavigationMixin(LightningElement) {

    @api recordId;
    @track questionsList;
    showSpinner;
    taskDoneInProgress;
    readOnly;
    twoByTwoPhotoRecommendation;
    showUploadModal;
    docIdForUpload;
    modalHeading = 'Upload Document';
    isDeleteModal;
    currentIndex;
    fileName;
    fileIndex;
    header;
    @track deleteFileobj ={};
    connectedCallback() {
        this.fetchInspectionQuestions();
        //Loading CSS
        loadStyle(this, lpiTheme + "/styles/internal-main.css");
    }

    get acceptedFormats() {
        return DocumentFormats.split(",");
    }

    fetchInspectionQuestions() {
        this.showSpinner = true;
        getInspectionQuestions({
            recordId: this.recordId
        }).then((result) => {
            this.questionsList = result;
            this.questionsList.forEach(ques => {
                this.readOnly = ques.readOnly;
                ques.isMultiPicklist = ques.dataType === 'Multi-Select Picklist';
                if (ques.isMultiPicklist) {
                    ques.multiselectValueList = ques.value ? ques.value.split(';') : [];
                }
                ques.isDateField = ques.dataType === 'DateTime';
                ques.isNumberic = ques.dataType === 'Number';
                ques.isString = ques.dataType === 'String';
                ques.questionLabel = ques.boardName === 'Nursing' ? 'Result' : ques.questionName;
                ques.isBoardNursing = ques.boardName === 'Nursing';
                ques.commentsLabel = ques.boardName === 'Pharmacy' ? 'Comments' : 'Rationale/Suggestions/Recommendations/Comments';
                this.twoByTwoPhotoRecommendation = ques.twoByTwoPhotoRecommendation && !this.twoByTwoPhotoRecommendation ? JSON.parse(ques.twoByTwoPhotoRecommendation) : this.twoByTwoPhotoRecommendation;
                this.header =  this.twoByTwoPhotoRecommendation.without2x2header;
                let payload = ques.onbasePayload ? JSON.parse(ques.onbasePayload) : null;
                if (payload && payload.keywordCollection && payload.keywordCollection.items) {
                    payload.keywordCollection.items.forEach(item => {
                        item.keywords.forEach(keyWord => {
                            keyWord.values.forEach(keyValue => {
                                keyValue.value = ques[keyValue.value]
                            })
                        })
                    })
                    payload.documentDate = ques.documentDate;
                    ques.payload = JSON.stringify(payload);
                }
                if (!ques.doesNotaccountForViolation && ques.options && this.isViolationAnswer(ques.options.find(opt => opt.value === ques.value)?.label, ques.questionName)) {
                    ques.isViolationDone = true;
                    ques.markRequired = true;
                } else {
                    ques.isViolationDone = false;
                    ques.markRequired = false;
                }
            })
        }).catch(error => {
            showAsyncErrorMessage(this, error);
        }).finally(() => {
            this.showSpinner = false;
        })
    }

    handleChange(event) {
        if (event.target.dataset.multipicklist) {
            this.questionsList[event.target.dataset.index][event.target.name] = event.detail.value;
        } else {
            this.questionsList[event.target.dataset.index][event.target.name] = event.target.value;
            if (event.target.name != 'comment') {

                if (!this.questionsList[event.target.dataset.index].doesNotaccountForViolation && this.questionsList[event.target.dataset.index].options && this.isViolationAnswer(event.target.options.find(opt => opt.value === event.detail.value)?.label, event.target.dataset.question)) {
                    this.questionsList[event.target.dataset.index].isViolationDone = true;
                    this.questionsList[event.target.dataset.index].markRequired = true;
                } else {
                    this.questionsList[event.target.dataset.index].isViolationDone = false;
                    this.questionsList[event.target.dataset.index].markRequired = false;
                }
            }
        }

        if (this.questionsList[event.target.dataset.index].options && event.target.options && !event.target.dataset.multipicklist) {
            this.questionsList[event.target.dataset.index]['optionLabel'] = event.target.options.find(opt => opt.value === event.detail.value).label;

        }

        if (!this.taskDoneInProgress) {
            this.showSpinner = true;
            updateTaskStatus({
                recordId: this.recordId,
                status: 'InProgress'
            }).then(() => {
                this.taskDoneInProgress = true;
                this.dispatchEvent(new RefreshEvent());
            }).catch(error => {
                showAsyncErrorMessage(this, error);
            }).finally(() => {
                this.showSpinner = false;
            })
        }

    }

    handleSave() {
        if (this.checkValidity()) {
            this.showSpinner = true;
            this.questionsList.forEach(ques => {
                if (ques.isMultiPicklist) {
                    ques.multiPicklistValue = ques.multiselectValueList.join(';');
                }
            })
            handleSaveInspectionQues({
                jsonData: JSON.stringify(this.questionsList)
            }).then(() => {
                this.taskDoneInProgress = false;
                const visitId = this.questionsList && this.questionsList.length > 0
                    ? this.questionsList[0].visitId
                    : null;
                // Invalidate LDS cache for task + parent Visit so status/related lists refresh.
                const recordsToNotify = [{ recordId: this.recordId }];
                if (visitId) {
                    recordsToNotify.push({ recordId: visitId });
                }
                getRecordNotifyChange(recordsToNotify);
                this.dispatchEvent(new RefreshEvent());
                showMessage(this, {
                    title: "Success",
                    message: "Responses have been successfully saved.",
                    messageType: "success",
                    mode: "dismissable"
                });
                setTimeout(() => {
                    this.navigateToVisit(true);
                }, 1000);
            }).catch(error => {
                showAsyncErrorMessage(this, error);
            }).finally(() => {
                this.showSpinner = false;
            })
        }
    }

    checkValidity() {
        this.focus = false;
        this.focusIndex = -1;
        let isAllValid = [...this.template.querySelectorAll('lightning-textarea,lightning-combobox')].reduce((validSoFar, input) => {
            input.reportValidity();
            let valid = input.checkValidity() && checkLength(input);
            valid = input.disabled ? true : valid;
            if (!valid && (!this.focus || this.focusIndex == -1 || this.focusIndex > parseInt(input.dataset.index))) {
                input.focus();
                this.focus = true;
                this.focusIndex = input.dataset.index;
            }
            return validSoFar && valid;
        }, true);


        if (!isAllValid) {
            showAsyncErrorMessage(this, 'Please validate all the input fields.')

        }
        return isAllValid;
    }

    handleFileUpload(event) {
        let boardName = event.target.dataset.board;
        let recordid = event.target.dataset.recordid;
        this.currentIndex = event.target.dataset.index;
        let dataObj = {
            documentName: 'Inspection Document',
            boardName: boardName,
            lookupFieldName: 'Inspection_Assessment_Indicator__c',
            lookupFieldId: recordid,
            onbasePayload: event.target.dataset.metadata
        }
        createApplicationDocument({
            jsonData: JSON.stringify(dataObj)
        }).then((response) => {
            this.docIdForUpload = response.appDocId;
            this.showUploadModal = true;
        }).catch(error => {
            showAsyncErrorMessage(this, error)
        }).finally(() => {
            this.showSpinner = false;
        })
    }

    handleUploadFinished(event) {
        this.showSpinner = true;
        showMessage(this, {
            title: "Warning",
            message: 'Document has been Uploaded and it is currently being scanned,do not refresh the page,or click on any button.',
            messageType: "warning",
            mode: "dismissable"
        });
        console.log('>>>',this.docIdForUpload);
        this.showUploadModal = false;
        let dataObj = {
           // contentDocumentId: this.docIdForUpload,
            appDocumentId:this.docIdForUpload,
            uploadByInternalUser : true,
            newDocumentName: 'Inspection Document'
        }
        console.log('Hello');
        //console.log('>>>>',event.detail.files[0].documentId,'><><>',uploadByInternalUser,'edwfwer',this.docIdForUpload);
        setTimeout(() => {
            getFileScanResult({
                jsonData: JSON.stringify(dataObj)
            }).then((res) => {
                console.log('Bypass Response>>',res);
                showMessage(this, {
                    title: "Success",
                    message: 'Document uploaded successfully.',
                    messageType: "success",
                    mode: "dismissable"
                });
                let temp = JSON.parse(JSON.stringify(this.questionsList[this.currentIndex]));
                temp.filesList = temp.filesList ? temp.filesList : [];
                temp.filesList.push({
                    "fileName": event.detail.files[0].name,
                    "parentRecId": this.docIdForUpload
                });
                this.questionsList[this.currentIndex].filesList = temp.filesList;
                this.docIdForUpload = null;
            }).catch(error => {
                showAsyncErrorMessage(this, error)
                this.showSpinner = false;
            }).finally(() => {
                this.showSpinner = false;
            });
        }, fileScanSetTimoutValue)

    }

    handleDownload(event) {
        this.showSpinner = true;
        showMessage(this, {
            title: "Info",
            message: 'Document will download shortly.',
            messageType: "info",
            mode: "dismissable"
        });
        let dataObj = {
            appDocId: event.target.dataset.parentid
        };
       // let fromOnbase;
        downloadFile({
            recordId: event.target.dataset.parentid
        }).then((response) => {
           // fromOnbase = response.fromOnbase;
            dataObj.contentDocId = response.contentDocId;
            window.open(response.downloadUrl.toString(), "_blank")

        }).then(() => {
            console.log('File Downloaded');
            
            // if(fromOnbase){
            //     setTimeout(() => {
            //         handleContentDocumentDelete({
            //             contentDocumentId: dataObj.contentDocId,
            //             appDocId : dataObj.appDocId
            //         }).then().catch(error => {
            //             showAsyncErrorMessage(this, error)
            //         });
            //     }, 12000)
            // }
           
        }).catch(error => {
            showAsyncErrorMessage(this, error)
        }).finally(() => {
            this.showSpinner = false;
        })
    }

    handleClose() {
        if(!this.isDeleteModal){
            // handleCancel({
            //     recordId : this.docIdForUpload
            // }).then().catch(error =>{
            //     showAsyncErrorMessage(this,error);
            // })
        }
        this.showUploadModal = false;
        this.isDeleteModal = false;
        this.deleteFileobj = null;
        this.currentIndex = null;
        this.fileIndex = null;
    }

    handleDeleteConfirmation(event){
        this.currentIndex = event.target.dataset.parentindex;
        this.fileIndex = event.target.dataset.fileindex;
        this.isDeleteModal = true;
        this.modalHeading = 'Are you sure you want to delete this file ?';
        this.deleteFileobj = {
            appDocumentId : event.target.dataset.parentid,
            fileId : event.target.dataset.fileid
        }
        this.showUploadModal = true;
    }

    handleDelete(){
        
        this.showSpinner = true;
        handleFileDelete({
            jsonData : JSON.stringify(this.deleteFileobj)
        }).then(() =>{
                
            this.questionsList[this.currentIndex].filesList.splice(this.fileIndex,1);
            this.handleClose();
            showMessage(this,{
                title: "Success",
                message: 'File has been deleted successfully.',
                messageType: "success",
                mode: "dismissable"
            })
        }).catch(error => {
            showAsyncErrorMessage(this,error);
            
        }).finally(()=>{
            this.showSpinner = false;
        })
    }

    handleCancel(){
        this.navigateToVisit();
    }

    /**
     * Status values that require comments and create RCVs.
     * Supports: legacy Violation/No/Yes, Pass/Fail/N/A, and Completed/Not Completed/N/A.
     */
    isViolationAnswer(label, questionName) {
        if (!label) {
            return false;
        }
        if (label === 'Violation' || label === 'Fail' || label === 'Not Completed') {
            return true;
        }
        if (label === 'No' && questionName !== 'Are there any other violations?') {
            return true;
        }
        if (label === 'Yes' && questionName === 'Are there any other violations?') {
            return true;
        }
        return false;
    }

    navigateToVisit(forceRefresh) {
        const visitId = this.questionsList && this.questionsList.length > 0
            ? this.questionsList[0].visitId
            : null;
        if (visitId) {
            const pageRef = {
                type: 'standard__recordPage',
                attributes: {
                    recordId: visitId,
                    objectApiName: 'Visit',
                    actionName: 'view'
                }
            };
            if (forceRefresh) {
                // Soft NavigationMixin reuse keeps a stale Visit page (Assessment Task status).
                // Full assign forces related lists / record view to reload with Completed status.
                this[NavigationMixin.GenerateUrl](pageRef).then((url) => {
                    window.location.assign(url);
                });
            } else {
                this[NavigationMixin.Navigate](pageRef);
            }
        } else {
            window.history.back();
        }
    }
}