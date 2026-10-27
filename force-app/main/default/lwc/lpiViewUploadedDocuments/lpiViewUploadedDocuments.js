import {
    LightningElement,
    api,
    track,
    wire
} from 'lwc';
import {
    ShowToastEvent
} from 'lightning/platformShowToastEvent';
import getApplicationDocumentList from '@salesforce/apex/LPI_ViewUplodDocContoller.getApplicationDocumentList';
import documentDownloadUrl from '@salesforce/apex/LPI_ViewUplodDocContoller.documentDownloadUrl';
import createApplicationDocuments from '@salesforce/apex/LPI_ApplicationDocumentReviewController.createApplicationDocuments';
import updateApplicationDoc from '@salesforce/apex/LPI_GetApplicationDocumentController.createApplicationDocument';
import handleScanAndReturnDocs from '@salesforce/apex/LPI_ViewUplodDocContoller.handleScanAndReturnDocs';
import downloadFile from '@salesforce/apex/LPI_OnBaseIntegrationController.downloadFileFromSf';
import handleDeleteAndFetchDoc from '@salesforce/apex/LPI_ViewUplodDocContoller.handleDeleteAndFetchDoc';
import handleSaveNewDoc from '@salesforce/apex/LPI_ViewUplodDocContoller.handleSaveAndReturnDocs';
import handleCancel from '@salesforce/apex/LPI_OnBaseIntegrationController.handleCancel';
import handleContentDocumentDelete from '@salesforce/apex/LPI_OnBaseIntegrationController.handleContentDocumentDelete';
// import updateApplicationDocumentRecord from '@salesforce/apex/LPI_ViewUplodDocContoller.updateApplicationDocumentRecord';


import {
    showAsyncErrorMessage,
    showMessage
} from 'c/lpiUtil';
const MAX_FILE_SIZE = 2097152;
export default class LpiViewUploadedDocuments extends LightningElement {
    @api objectId;
    @api deficiencyId;
    @api showDeficiencyRecor = false;
    @api showFdRecord = false;
    @api iaId;
    @track appDocumentList;
    @track showSpinner = false;
    @track filesData = [];
    @track fileName = [];
    get acceptedFormats() {
        ".doc",
        ".docx",
        ".ppt",
        ".pptx",
        ".pdf",
        ".bmp",
        ".jpeg",
        ".jpg",
        ".png",
        ".heic",
        ".webp"
    }
    documentIdForFileUpload;
    documentName;
    activeElement;
    isShowUploadModal;
    isAddNewShowModal;
    newContentDocumentId;
    newContentVersionId;
    newDocumentName;
    newDocumentDescription;
    @track uploadedFiles;

    uploadedFileslength;
    @track newFileAttachment; //Changes made
    @track documentsIdSet = [];
    @track dataRecordId;
    payLoad;
    twoByTwoPhotoRecommendation;
    header;
    docIdForUpload;
    index;
    modalHeading;
    isDeleteModal;
    @track deleteFileobj = {};
    newRecCreated;
    //@track appDocumentId;
    getApplicationDocumentList() {
        this.showSpinner = true;
        getApplicationDocumentList({
                applicationId: this.showFdRecord ? this.iaId : this.deficiencyId,
                showDeficenyRec: this.showDeficiencyRecor
            })
            .then(result => {
                if (!result) {
                    this.showSpinner = false;
                    return;
                }
                this.twoByTwoPhotoRecommendation = result.twoByTwoPhotoRecommendation && !this.twoByTwoPhotoRecommendation ? JSON.parse(result.twoByTwoPhotoRecommendation) : this.twoByTwoPhotoRecommendation;
                this.header = this.twoByTwoPhotoRecommendation.with2x2header;
                this.processDocs(result.documents)
            })
            .catch(error => {
                this.showToast("Error", error.body.message, "error");
                this.showSpinner = false;

            })
    }

    processDocs(documents){
        console.log('process doc entered');
        const data = documents? JSON.parse(documents) : null;
        if (data != null) {
            var temArr = [];
            this.documentsIdSet = [];
            data.forEach(arrayItem => {
                if (arrayItem.documentRecord != null) {
                    if (arrayItem.documentRecord.ContentDocumentLinks != undefined && arrayItem.documentRecord.ContentDocumentLinks.records.length > 0) {
                        this.documentsIdSet.push(arrayItem.documentRecord.Id);
                        arrayItem.filePresentOnParent = true;
                        arrayItem.documentRecord.ContentDocumentLinks.records.forEach(function (arrayItem1) {
                            if (arrayItem1.ContentDocument != undefined) {
                                const myArray = arrayItem1.ContentDocument.Title.split(".");
                                arrayItem1['FileName'] = arrayItem.documentRecord.Uploaded_By_Internal_User__c ? myArray[0] + '.' + arrayItem1.ContentDocument.FileExtension + '(Uploaded By MOPRO Staff)' : myArray[0] + '.' + arrayItem1.ContentDocument.FileExtension;
                                arrayItem1['deleteAriaLabelIcon'] = arrayItem1['FileName'] + ' Delete Icon';
                                arrayItem1['downloadAriaLabelIcon'] = arrayItem1['FileName'] + ' Download Icon';
                                arrayItem1['parentRecId'] = arrayItem.documentRecord.Id;
                                if (arrayItem1.ContentDocument.CreatedBy != undefined) {
                                    arrayItem1['showFileDelete'] = !arrayItem.documentRecord.Uploaded_By_Internal_User__c;
                                    // if (arrayItem1.ContentDocument.CreatedBy.Profile.Name === 'Portal User') {
                                    //     arrayItem1['showFileDelete'] = true;
                                    // } else {
                                    //     arrayItem1['showFileDelete'] = false;
                                    // }
                                } else {
                                    arrayItem1['showFileDelete'] = false;
                                    
                                }
                            }
                        });
                    }
                    if (arrayItem.files && arrayItem.files.length > 0) {
                        this.documentsIdSet.push(arrayItem.documentRecord.Id);
                        arrayItem.files.forEach(file => {
                            arrayItem.filePresentOnParent =  arrayItem.filePresentOnParent || file.parentRecId == arrayItem.documentRecord.Id;
                            file.deleteAriaLabelIcon = file.fileName + ' Delete Icon';
                            file.downloadAriaLabelIcon = file.fileName + ' Download Icon';
                         })
                    }
                    arrayItem['uploadAriaLabel'] = arrayItem.documentRecord.Document_Name__c + ' Upload Button Action';
                    arrayItem['deleteAriaLabel'] = arrayItem.documentRecord.Document_Name__c + ' Delete Button Action';
                }
                temArr.push(arrayItem);
            });
            this.appDocumentList = data;
            console.log('appDocumentList',JSON.stringify(this.appDocumentList));
            this.showSpinner = false;
        } else {
            this.showSpinner = false;
            this.appDocumentList = [];
            console.log('appDocumentList else block',this.appDocumentList);
        }

        if(this.documentIdForFileUpload){
            this.template.querySelector(`[data-docid="${this.documentIdForFileUpload}"]`) ?.focus();
        }
    }

    connectedCallback() {
        this.showSpinner = true;
        this.getApplicationDocumentList();
    }

    handleUpload() {
        let valid = false;
        this.focus = false;
        this.focusIndex = -1;

        valid = [...this.template.querySelectorAll('lightning-input,lightning-textarea')].reduce((validSoFar, input) => {
            input.reportValidity();
            let valid = input.checkValidity();
            valid = input.disabled ? true : valid;
            if (!valid && (!this.focus || this.focusIndex == -1 || this.focusIndex > parseInt(input.dataset.index))) {
                input.focus();
                this.focus = true;
                this.focusIndex = input.dataset.index;
            }
            return validSoFar && valid;
        }, true);
        if (valid) {
            this.handleUploadOnbase(false);
        }
    }

    handlePreviewFile(event) {
        let contentId = event.currentTarget.dataset.contentid;
        documentDownloadUrl({
                contentDocRecordId: contentId
            })
            .then(result => {
                let downloadContentURL = result;
                window.open(downloadContentURL, "_blank");
            })
            .catch(error => {
                this.showToast("Error", error.body.message, "error");
            });
    }


    doFileUpload(event) {
        this.showSpinner = true;
        this.documentIdForFileUpload = event.currentTarget.dataset.docid;
        this.documentName = event.currentTarget.dataset.docname;
        this.modalHeading = this.documentName;
        this.index = event.currentTarget.dataset.index;
        console.log('enetered do fiel upload');
        console.log('event.target.dataset.filepresentonparent value',event.target.dataset.filepresentonparent);
        console.log(' event.currentTarget.dataset.filepresentonparent',event.currentTarget.dataset.filepresentonparent);
        let optionsData = {};
        if (event.target.dataset.filepresentonparent != 'false' && event.target.dataset.filepresentonparent  && JSON.parse(JSON.stringify(this.documentsIdSet)).includes(this.documentIdForFileUpload)) {
            if (this.showFdRecord) {
                console.log('enetered showFdrecord');
                optionsData = {
                    appDocumentId: this.documentIdForFileUpload,
                    createNewRec: JSON.parse(JSON.stringify(this.documentsIdSet)).includes(this.documentIdForFileUpload),
                    embalmerFdDoc: this.showFdRecord,
                    type: 'Registration Form',
                    subType: 'Registration Form',
                    appRecordId: this.iaId,
                    docName: this.documentName,
                    fromUploadDocument :true
    
                }; 
            }else{
                console.log('enetered else statemnetshowFdrecord');
                optionsData = {
                    appDocumentId: this.documentIdForFileUpload,
                    createNewRec: JSON.parse(JSON.stringify(this.documentsIdSet)).includes(this.documentIdForFileUpload),
                    fromUploadDocument :true,
                    fromDeficiency : true,
                    applicationId : this.objectId
               };
            }
            this.newRecCreated = true;
            this.handleCreateAppDoc(optionsData);

        } else {
            console.log('enetered else bolcj');
            this.showSpinner = false;
            this.docIdForUpload = this.documentIdForFileUpload;
            this.isShowUploadModal = true;
            this.newRecCreated = false;
            setTimeout(() => {
                this.focusFirstEle();
            }, 500);
        }
    }


    @api
    requiredDocumentsUploaded() {
        let allRequiredDocumentsUploaded = true;
        this.appDocumentList.forEach(item => {
            if (item ?.documentRecord ?.Is_Document_Required__c && item ?.files.length === 0 && (item ?.documentRecord?.ContentDocumentLinks == null || 
                item ?.documentRecord.ContentDocumentLinks?.records.length === 0)) {
                allRequiredDocumentsUploaded = false;
                return;
            }
        });
        return allRequiredDocumentsUploaded;
    }


    // Focus Leak Acessibiltiy Issue 
    focusFirstEle() {
        const focusableElements = 'lightning-combobox, lightning-button-icon, button, lightning-helptext, lightning-input, lightning-button';
        const modal = this.template.querySelector('.slds-modal');
        const firstFocusableElement = modal.querySelectorAll(focusableElements)[0];
        const focusableContent = modal.querySelectorAll(focusableElements);
        const lastFocusableElement = focusableContent[focusableContent.length - 1];
        firstFocusableElement.focus();
        this.template.addEventListener('keydown', function (event) {
            let isTabPressed = event.key === 'Tab' || event.keyCode === 9;
            if (!isTabPressed) {
                return;
            }
            if (event.shiftKey) {
                if (this.activeElement === firstFocusableElement) {
                    lastFocusableElement.focus();
                    event.stopPropagation()
                    event.preventDefault();
                }
            } else {
                if (this.activeElement === lastFocusableElement) {
                    firstFocusableElement.focus();
                    event.preventDefault();
                    event.stopPropagation()
                }
            }
        });
    }

    hideUploadModalBox() {
        this.isShowUploadModal = false;
        if(this.deleteFileobj.fromaddnew){
            this.isAddNewShowModal = true;
            setTimeout(() => {
                this.focusFirstEle();
            }, 500);
        }else{
            this.newFileAttachment = null;
            if(!this.newRecCreated){
                this.template.querySelector(`[data-docid="${this.documentIdForFileUpload}"]`) ?.focus();

            }else{
               this.handleCancelApplication(this.documentIdForFileUpload);
            }
        }
        this.isDeleteModal = false;
        this.deleteFileobj = {};
        
       
    }
    addOtherDocuments() {
        this.createAppDocRecord(true);
    }
    handleNewDocumentNameChange(event) {
        this.newDocumentName = event.detail.value;
    }
    handleNewDocumentDescChange(event) {
        this.newDocumentDescription = event.detail.value;
    }

    hideAddModalBox() {
        this.showSpinner = true;
        this.filesData = [];
        this.fileName = [];
        this.newDocumentDescription = '';
        this.newDocumentName = '';
        this.isAddNewShowModal = false;
        this.showSpinner = false;
        this.newFileAttachment = null;
        this.index = null;
    }

    handleNewFileUploadFinished(event) {
        this.newContentDocumentId = event.detail.files[0].documentId;
        this.newContentVersionId = event.detail.files[0].contentVersionId;
    }
    handleSaveNewDocument() {
        console.log('enetered method');
        let valid = false;
        this.focus = false;
        this.focusIndex = -1;

        valid = [...this.template.querySelectorAll('lightning-input,lightning-textarea,lightning-file-upload')].reduce((validSoFar, input) => {
            input.reportValidity();
            let valid = input.checkValidity();
            valid = input.disabled ? true : valid;
            if (!valid && (!this.focus || this.focusIndex == -1 || this.focusIndex > parseInt(input.dataset.index))) {
                input.focus();
                this.focus = true;
                this.focusIndex = input.dataset.index;
            }
            return validSoFar && valid;
        }, true);
        if (valid) {
            console.log('called method');
            this.handleSaveAndReturnDocs(this.docIdForUpload);
            // updateApplicationDocumentRecord({
            //     docId: this.docIdForUpload
            // })
            // .then(result => {
            //     console.log('success :>> ');
            // })
            // .catch(error => {
            //     this.showToast("Error", error.body.message, "error");
            // });
            // this.createAppDocRecord(true)
        }
    }

    handleCreateAppDoc(optionsData) {
        console.log('enetered handle create app');
        updateApplicationDoc({
            options: optionsData
        }).then((response) => {
            this.isShowUploadModal = true;
            this.docIdForUpload = response.newid;
            setTimeout(() => {
                this.focusFirstEle();
            }, 500);
        }).catch(error => {
            showAsyncErrorMessage(this, error);
        }).finally(() => {
            this.showSpinner = false;
        })
    }

    handleUploadFinished(event) {
        this.dofileScanning(event, false);
    }

    handleUploadFinishedNewDoc(event){
        this.dofileScanning(event,true);
    }

    dofileScanning(event, fromAddNew){
        let file = event.detail.files[0];
        console.log('field details',file);

        showMessage(this, {
            title: "Warning",
            message: "Document has been uploaded and it is currently being scanned,do not refresh the page,or click on any button.",
            messageType: "warning",
            mode: "dismissable"
        });
        this.showSpinner = true;
        this.isShowUploadModal = false;
        let dataObj = {
            contentDocumentId: event.detail.files[0].documentId,
            isSubmittedAsPartOfDeficiency: true,
            recordId : this.docIdForUpload,
            applicationId : this.objectId,
            appDocumentId : this.docIdForUpload
        }
        setTimeout(() => {
            handleScanAndReturnDocs({
                jsonData: JSON.stringify(dataObj),
                applicationId: this.showFdRecord ? this.iaId : this.deficiencyId,
                showDeficenyRec: this.showDeficiencyRecor
            }).then((response) => {
                if(!fromAddNew){
                    this.processDocs(response.documents);
                    showMessage(this, {
                        title: "Success",
                        message: "Document has been uploaded successfully.",
                        messageType: "success",
                        mode: "dismissable"
                    });
                }else{
                    this.newFileAttachment = file;
                    this.newFileAttachment.downloadAriaLabelIcon =this.newFileAttachment.name + ' Download Icon';
                    this.newFileAttachment.deleteAriaLabelIcon =this.newFileAttachment.name + ' Delete Icon';
                }
                
            }).catch(error => {
                showAsyncErrorMessage(this, error);
                this.newFileAttachment = null;
            }).finally(() => {
                this.showSpinner = false;
            })
        }, 12000);

    }

    


    updateApplicationDoc(documentIdOnbase) {
        let optionsData = {};
        if (this.showFdRecord) {
            optionsData = {
                appDocumentId: this.documentIdForFileUpload,
                fileName: this.newFileAttachment.name,
                createNewRec: true,
                onbaseDocId: documentIdOnbase,
                embalmerFdDoc: this.showFdRecord,
                type: 'Registration Form',
                subType: 'Registration Form',
                appRecordId: this.iaId,
                docName: this.documentName
            };
        } else {
            optionsData = {
                appDocumentId: this.documentIdForFileUpload,
                fileName: this.newFileAttachment.name,
                createNewRec: JSON.parse(JSON.stringify(this.documentsIdSet)).includes(this.documentIdForFileUpload),
                onbaseDocId: documentIdOnbase,
                fromDeficiency : true,
                applicationId : this.objectId
            };
        }
        updateApplicationDoc({
            options: optionsData
        }).then(() => {
           this.showToast("Success", 'Document Created Successfully!!', 'success');
            this.isShowUploadModal = false;
            this.newFileAttachment = null;
            this.template.querySelector(`[data-docid="${this.documentIdForFileUpload}"]`) ?.focus();
            this.getApplicationDocumentList();
        }).catch(error => {
            showAsyncErrorMessage(this, error);
        }).finally(() => {
            this.showSpinner = false;
        })
    }

    handleSaveAndReturnDocs(appDocId){
        try {
            this.showSpinner = true;
        let params = {
            documentName: this.newDocumentName,
            documentComment: this.newDocumentDescription,
            appDocId : appDocId,
            setStatusToUploadToOnbase : true

        };
        console.log('patams',JSON.stringify(params));
        handleSaveNewDoc({
            'inputMap'  : params,
            'applicationId': this.showFdRecord ? this.iaId : this.deficiencyId,
            'showDeficenyRec': this.showDeficiencyRecor,
        }).then((response)=>{
            console.log('Success '+JSON.stringify(response));
            this.showToast("Success", 'Document Created Successfully!!', 'success');
            this.hideAddModalBox();
            this.handleModalClose();
            this.processDocs(response.documents);
        }).catch(error => {
            console.log('Error while processing'+JSON.stringify(error));
            showAsyncErrorMessage(this, error);
            this.showSpinner = false;
        }) 
        } catch (error) {
            console.log('Error while processing  !!'+JSON.stringify(error));
        }
       
    }

    createAppDocRecord(initialCall) {
        let newDocNameField = this.template.querySelector('[data-id="newDocName"]');
        this.showSpinner = true;
        let registrationFormType = this.showFdRecord ? true : false;
        let params = {
            documentName: this.newDocumentName,
            documentStatus: !initialCall ? 'Submitted' : 'Unsubmitted',
            embalmerFdDoc: registrationFormType,
            documentComment: this.newDocumentDescription,
            filedata: JSON.stringify(this.filesData),
            isAttachment: true,
            isRequired: false,
            isSubmissionRequired: true,
            isAdditionalRec : true,
            fromUploadDocument :true
            // fileName: this.newFileAttachment.name,
            // onbaseDocId: onbaseDocId
        };
        createApplicationDocuments({
            'applicationId': this.showFdRecord ? this.iaId : this.objectId,
            'inputMap': params,
            'deficiencyId': this.deficiencyId
        }).then(result => {
            if (result == 'Duplicate Name') {
                newDocNameField.setCustomValidity('An Application document exist with the same name. Please enter a different name.');
                newDocNameField.reportValidity();
            } else{
                this.isAddNewShowModal = true;
                this.docIdForUpload = result;
                setTimeout(() => {
                    this.focusFirstEle()
                }, 100);
                setTimeout(() => {
                    this.focusFirstEle();
                }, 500);
                console.log('docIdForUpload',this.docIdForUpload);
                // this.handleUploadOnbase(true);
            } 
            // else if (result == 'success') {
            //     this.showToast("Success", 'Document Created Successfully!!', 'success');
            //     this.hideAddModalBox();
            //     // this.getApplicationDocumentList();
            // }

        }).catch(error => {
            showAsyncErrorMessage(this, error);
        }).finally(() => {
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
        let fromOnbase;
        downloadFile({
            recordId: event.target.dataset.parentid
        }).then((response) => {
            fromOnbase = response.fromOnbase;
            dataObj.contentDocId = response.contentDocId;
            window.open(response.downloadUrl.toString(), "_blank")

        }).then(() => {
            
            if(fromOnbase){
                setTimeout(() => {
                    handleContentDocumentDelete({
                        contentDocumentId: dataObj.contentDocId,
                        appDocId : dataObj.appDocId
                    }).then().catch(error => {
                        showAsyncErrorMessage(this, error)
                    });
                }, 12000)
            }
           
        }).catch(error => {
            showAsyncErrorMessage(this, error)
        }).finally(() => {
            this.showSpinner = false;
        })
    }

    handleDeleteConfirmation(event) {
        if(event.target.dataset.fromaddnew){
            this.isAddNewShowModal = false;
        }

        this.isDeleteModal = true;
        this.index = event.target.dataset.index;
        this.modalHeading = 'Confirmation Required';
        this.deleteFileobj = {
            appDocumentId: event.target.dataset.parentid,
            fileId: event.target.dataset.fileid,
            fromfilelist: event.target.dataset.fromfilelist,
            fromcvlist: event.target.dataset.fromcvlist,
            fromaddnew : event.target.dataset.fromaddnew ? true: false,
            doNotDelete : event.target.dataset.fromaddnew ? true: false,
            fromDeficiencyResponse :  !event.target.dataset.fromaddnew,
            intakeFileDelete : true
        }
        this.isShowUploadModal = true;
        setTimeout(() => {
            this.focusFirstEle();
        }, 500);
    }

    handleDelete() {
        this.showSpinner = true;
        console.log('deleteFileobj :>> ', JSON.stringify(this.deleteFileobj));
        console.log('showFdRecord :>> ', this.showFdRecord);
        console.log('deficiencyId :>> ', this.deficiencyId);
        console.log('iaId :>> ', this.iaId);
        console.log('showDeficiencyRecor :>> ', this.showDeficiencyRecor);
        handleDeleteAndFetchDoc({
            jsonData: JSON.stringify(this.deleteFileobj),
            applicationId: this.deleteFileobj.fromaddnew ?  null : this.showFdRecord ? this.iaId : this.deficiencyId,
            showDeficenyRec: this.showDeficiencyRecor
        }).then((response) => {
            showMessage(this, {
                title: "Success",
                message: 'File has been deleted successfully.',
                messageType: "success",
                mode: "dismissable"
            })

            let fromAddNew =  this.deleteFileobj.fromaddnew;
            if(!fromAddNew){
                this.processDocs(response.documents);
            }else if(fromAddNew){
                this.isAddNewShowModal = true;
                this.showSpinner = false;
                this.newFileAttachment = null;
            }

            this.handleModalClose();

           
        }).catch(error => {
            showAsyncErrorMessage(this, error);
            this.showSpinner = false;
        })
    }

    handleModalClose(){
        this.isShowUploadModal = false;
        this.isDeleteModal = false;
        this.deleteFileobj = {};

    }

    handleCancelApplication(dataIdToMoveFocus){
        handleCancel({
            recordId : this.docIdForUpload
        }).then(()=>{
            this.template.querySelector(`[data-docid="${dataIdToMoveFocus}"]`) ?.focus();

        }).catch(error =>{
            showAsyncErrorMessage(this,error);
        }).finally(()=>{
            this.showSpinner = false;
        })
    }
}