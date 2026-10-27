/**
 * @                  : 
 * @author            : Abel David Solomon
 * @group             : 
 * @last modified on  : 09-17-2026
 * @last modified by  : Juhi Goel
**/
import {
    LightningElement,
    api,
    track,
    wire
} from 'lwc';
import {
    NavigationMixin
} from 'lightning/navigation';
import {
    ShowToastEvent
} from 'lightning/platformShowToastEvent';
import {
    showAsyncErrorMessage,
    showMessage
} from 'c/lpiUtil';
import getDocuments from '@salesforce/apex/LPI_ApplicationDocumentReviewController.getApplicationDocuments';
import createApplicationDocument from '@salesforce/apex/LPI_GetApplicationDocumentController.createApplicationDocument';
import updateDocuments from '@salesforce/apex/LPI_ApplicationDocumentReviewController.updateDocuments';
import createApplicationDocuments from '@salesforce/apex/LPI_ApplicationDocumentReviewController.createApplicationDocuments';
import handleCancel from '@salesforce/apex/LPI_OnBaseIntegrationController.handleCancel';
import scanFileAndReturnDocs from '@salesforce/apex/LPI_ApplicationDocumentReviewController.scanFileAndReturnDocs';
import downloadFile from '@salesforce/apex/LPI_OnBaseIntegrationController.downloadFileFromSf';
import handleFileDelete from '@salesforce/apex/LPI_ApplicationDocumentReviewController.handleFileDelete';
import handleContentDocumentDelete from '@salesforce/apex/LPI_OnBaseIntegrationController.handleContentDocumentDelete';
import userProfileName from '@salesforce/schema/User.Profile.Name';
import Id from '@salesforce/user/Id';
import { getRecord } from 'lightning/uiRecordApi';
import LPI_InternalCSS from "@salesforce/resourceUrl/LPI_Design";
import { loadStyle } from "lightning/platformResourceLoader";
const MAX_FILE_SIZE = 2097152;

export default class LpiapplicationDocumentReview extends NavigationMixin(LightningElement) {
    @api recordId;
    @track documentsList = [];
    @track documentsListCopy = [];
    @track lawfulPresenceDocumentsList = [];
    @track flowDocumentsList = [];
    @track lawfulPresenceDocumentsListCopy = [];
    @track flowDocumentsListCopy = [];
    @track existingData = [];
    @track existingLawfulData = [];
    @track existingFlowData = [];
    @track showSpinner = false;
    @track isLoaded = false;
    @track isDisabled = true;
    @track showUploadModal = false;
    @track lstAllFiles;
    @track filesData = [];
    @track fileName = [];
    @track allFiles = [];
    @track uploadedFiles;
    @track newDocumentName;
    @track newDocumentStatus = 'Unsubmitted';
    @track newDocumentComments;
    @track isRequired = 'true';
    @track isAttachment = false;
    @track newFileAttachment;
    @track documentIdSet = [];
    @track onbaseMetadata;
    @track addDocId;
    @track newDocumentDescription;
    @track isFromValid = false;
    @track isfileUploaded = false;
    @track isaddNewDoc = false;
    @track isShowAddModal = false;
    @track intakeFileDelete = true;
    @track doNotDelete = false;
    @track fromhandleSave = true;
    @track isAdditionalRec = true;
    @track isShowDeleteModal = false;
    @track showAddpinner = false;
    @track isfromAddDoc = false;
    @track fromAdditionalDelete = false;
    @track addOtherDocDisabled = false;
    currentContentDocumentId;
    twoByTwoPhotoRecommendation;
    documentIdForFileUpload;
    isDeleteModal;
    buttonDisabled;
    newfilename;
    contentDocId;
    isSubmissionRequired = true;
    showNewModal = false;
    dcumentId;
    isLoading = false;
    ContentdocumentId;
    ContentdocumentName;
    uploadedFileslength;
    header;
    @track deleteObj = {};
    modalHeading;
    additionalUploadDocTxt = 'Add additional relevant documents using the button to the right. Multiple documents related to the application may be uploaded.';
    isTwoByTwoPhoto = 'except for 1X1 jpeg photo and 2X2 Photo';
    noDataFound = LPI_InternalCSS + '/media/icons/internal-no-data-found.svg';

    get options() {
        return [{
            label: 'Required',
            value: 'Required'
        },
        {
            label: 'Optional',
            value: 'Optional'
        },
        ];
    }

    get statusOptions() {
        return [{
            label: 'Unsubmitted',
            value: 'Unsubmitted'
        },
        {
            label: 'Submitted',
            value: 'Submitted'
        },
        {
            label: 'Approved',
            value: 'Approved'
        },
        {
            label: 'Rejected',
            value: 'Rejected'
        },
        {
            label: 'Notice',
            value: 'Notice'
        }
        ];
    }

    get showNoDocumentsError() {
        return (this.documentsList && this.documentsList.length == 0);
    }
    get is2x2Photo() {
        return this.ContentdocumentName && this.twoByTwoPhotoRecommendation && this.twoByTwoPhotoRecommendation.docName === this.ContentdocumentName;
    }
    get modeOptions() {
        return [{
            label: 'Required',
            value: 'true'
        },
        {
            label: 'Optional',
            value: 'false'
        }
        ];
    }

    connectedCallback() {
        console.log('profile name' + userProfileName);
        this.showSpinner = true;
        this.loadDocumentsList();
        loadStyle(this, LPI_InternalCSS + "/styles/internal-main.css");
    }
    get acceptedFormats() {
        ".doc", ".docx", ".ppt", ".pptx", ".pdf", ".bmp", ".jpeg", ".jpg", ".png", ".heic", ".webp";
    }

    @wire(getRecord, { recordId: Id, fields: [userProfileName] })
    currentUserInfo({ error, data }) {
        if (data) {
            this.disableDeleteForInteUser = data.fields.Profile.value.fields.Name.value == 'MODPR Integration User' ? true : false;
        } else if (error) {
            this.error = error;
        }
    }


    handleFile(event) {
        if (!this.twoByTwoPhotoRecommendation.acceptedOtherFormats.includes(event.target.files[0].name.split('.').pop().toLowerCase())) {
            showMessage(this, {
                title: "Error",
                message: "Document/File format is not acceptable. Please upload a file of accepted type.",
                messageType: "error",
                mode: "dismissable"
            });
            this.newFileAttachment = null;
            return;
        }
        else if ((event.target.files[0].size / (1024 * 1024)).toFixed(2) > this.twoByTwoPhotoRecommendation.maxFileSizeOther) {
            showMessage(this, {
                title: "Error",
                message: `File size should not exceed ${this.twoByTwoPhotoRecommendation.maxFileSizeOther} MB.`,
                messageType: "error",
                mode: "dismissable"
            });
            this.newFileAttachment = null;
            return;

        }
        else {
            this.newFileAttachment = new File([event.target.files[0]], event.target.files[0].name.split(".")[0] + '.' + event.target.files[0].name.split('.').pop().toLowerCase(), { type: event.target.files[0].type });
        }
    }


    async upload2By2Photo() {
        this.buttonDisabled = true;
        this.showUploadModal = false;
        this.showSpinner = true;

        await this.template.querySelector('c-lpi-image-compression').handleUpload([this.newFileAttachment], this.dcumentId)
            .then(async (result) => {
                this.isLoaded = false;
                showMessage(this, {
                    title: "Success",
                    message: "File Uploaded Successfully.",
                    messageType: "success",
                    mode: "dismissable"
                });
                this.loadDocumentsList();
            })
            .catch(err => {
                showAsyncErrorMessage(this, err);
            })
            .finally(() => {
                this.dcumentId = null;
                this.newFileAttachment = null;
                this.showSpinner = false;
                this.buttonDisabled = false;
            });
    }


    handleUpload(event) {
        this.modalHeading = 'Upload file';
        this.fileName = [];
        this.filesData = [];
        this.ContentdocumentId = event.currentTarget.dataset.id;
        this.ContentdocumentName = event.currentTarget.dataset.name;
        this.dcumentId = event.currentTarget.dataset.docid; //Rachna's change

        if (this.documentIdSet.includes(this.dcumentId) && event.currentTarget.dataset.parentfilepresent && event.currentTarget.dataset.parentfilepresent != 'false') {

            this.showSpinner = true;
            let options = {
                'appDocumentId': this.dcumentId,
                'createNewRec': true
            };
            createApplicationDocument({
                options: options
            }).then((response) => {
                this.documentIdForFileUpload = response.newid;
                console.log('documentIdForFileUpload==>', this.documentIdForFileUpload);
                this.showUploadModal = true;


            }).catch(error => {
                if (error && error.body && error.body.message) {
                    this.showToast('Error', 'error', error.body.message);
                }
            }).finally(() => {
                this.dcumentId = null;
                this.showSpinner = false;
            });
        } else {
            this.showUploadModal = true;
            this.documentIdForFileUpload = this.dcumentId;
        }
    }

    handleUploadFinished(event) {
        this.uploadedFiles = event.detail.files;
        this.uploadedFileslength = event.detail.files.length;
        if (event.target.files.length > 0) {
            for (var i = 0; i < event.target.files.length; i++) {
                if (event.target.files[i].size > MAX_FILE_SIZE) {
                    this.showToast('Error!', 'error', 'File size exceeded the upload size limit.');
                    return;
                }
                let file = event.target.files[i];
                this.fileName.push(file.name);

                let reader = new FileReader();
                reader.onload = event => {
                    var fileContents = reader.result.split(',')[1];
                    this.filesData.push({
                        'fileName': file.name,
                        'fileContent': fileContents
                    });
                };
                reader.readAsDataURL(file);
            }
        }
    }


    handleUploadFinishedOnbase(event) {
        if (!this.isaddNewDoc) {
            this.showSpinner = true;
            this.addOtherDocDisabled = true;
        }
        this.showUploadModal = false;
        this.newfilename = event.detail.files[0].name;
        this.contentDocId = event.detail.files[0].documentId;
        this.contentDocumentId = event.detail.files[0].documentId;
        if (this.isaddNewDoc) {
            this.currentContentDocumentId = event.detail.files[0].documentId;
            this.showAddpinner = true;
            this.addOtherDocDisabled = true;
        }
        showMessage(this, {
            title: "Warning",
            message: 'Document has been Uploaded and it is currently being scanned,do not refresh the page,or click on any button.',
            messageType: "Warning",
            mode: "dismissable"
        });
        let docuId = this.documentIdForFileUpload;
        this.addDocId = docuId;
        console.log('addDocId-->', this.addDocId);
        let dataObj = {
            contentDocumentId: event.detail.files[0].documentId,
            recordId: this.isaddNewDoc ? this.addDocId : this.documentIdForFileUpload,
            appDocumentId: this.addDocId,
            newDocumentName: this.newDocumentName,
            newDocumentDescription: this.newDocumentDescription,
            payload: JSON.stringify(this.onbaseMetadata),
            fromhandleSave: !this.isaddNewDoc,
            uploadByInternalUser: !this.isaddNewDoc

        };
        setTimeout(() => {
            scanFileAndReturnDocs({
                jsonData: JSON.stringify(dataObj),
                recordId: this.recordId
            }).then(result => {
                const evt = new ShowToastEvent({
                    title: 'Success',
                    message: ' File uploaded successfully.',
                    variant: 'success',
                });
                this.dispatchEvent(evt);

                if (this.isaddNewDoc) {
                    this.isfileUploaded = true;
                    this.showAddpinner = false;
                    this.addOtherDocDisabled = false;
                }

                if (!this.isaddNewDoc) {
                    this.dcumentId = null;
                    this.showSpinner = false;
                    this.addOtherDocDisabled = false;
                    this.documentIdForFileUpload = null;
                    this.currentContentDocumentId = '';
                    this.processDocs(result);
                }
            }).catch(error => {
                showAsyncErrorMessage(this, error);
                this.showSpinner = false;
                this.addOtherDocDisabled = false;
            });
        }, 12000);

    }
    addNewDoc(event) {
        this.showSpinner = true;
        this.isaddNewDoc = true;
        this.isfromAddDoc = true;

        let params = {
            documentName: '',
            documentStatus: this.newDocumentStatus,
            documentComment: '',
            filedata: '',
            isAttachment: '',
            isRequired: '',
            isSubmissionRequired: '',
        };
        setTimeout(() => {
            createApplicationDocuments({
                'applicationId': this.recordId,
                'inputMap': params,
                'deficiencyId': null
            }).then(result => {
                this.showSpinner = false;
                this.addDocId = result;
                this.isShowAddModal = true;

            }).catch(error => {
                showAsyncErrorMessage(this, error);
                this.showSpinner = false;
            });
        }, 12000);
    }



    hideAddModalBox() {
        this.showSpinner = true;
        this.isShowAddModal = false;
        handleCancel({
            recordId: this.addDocId
        })
            .then(data => {
                this.showSpinner = false;
                this.isShowAddModal = false;
                this.newDocumentName = '';
                this.newDocumentDescription = '';
                this.isaddNewDoc = false;
                this.contentDocId = '';
                this.isfileUploaded = false;
            })
            .catch(error => {
                showAsyncErrorMessage(this, error);
            });

    }

    handleNewDocumentNameChange(event) {
        this.newDocumentName = event.detail.value;
        this.isFromValid = !(this.isValid());
    }
    isValid() {
        let isAllValid = [...this.template.querySelectorAll("lightning-input"),
        ...this.template.querySelectorAll("lightning-textarea"),
        ].reduce((validSoFar, input) => {
            input.reportValidity();
            if (input.checkValidity() == false) {
                input.focus();
            }
            return validSoFar && input.checkValidity();
        }, true);
        return isAllValid;
    }

    handleNewDocumentDescChange(event) {
        let isHtmlTag = !(/^((?!(<\s*|\s*>)).)*$/.test(event.detail.value));
        if (isHtmlTag) {
            event.target.setCustomValidity('Invalid input. This field only accepts letters and numbers. Special characters are not allowed.');
            event.target.reportValidity();
            this.isFromValid = !(this.isValid());
        } else {
            event.target.setCustomValidity('');
            event.target.reportValidity();
            this.isFromValid = !(this.isValid());
        }
        this.newDocumentDescription = event.detail.value;
    }

    handleSaveNewDocument(event) {

        if (this.newDocumentName === undefined || this.newDocumentName === '') {
            this.isValid();
            showMessage(this, {
                title: "Error",
                message: 'Please Enter Document Name',
                messageType: "error",
                mode: "dismissable"
            });
            return;
        }

        if (!this.contentDocId || !this.currentContentDocumentId) {
            showMessage(this, {
                title: "Error",
                message: 'Please Upload Document',
                messageType: "error",
                mode: "dismissable"
            });
            return;
        }

        this.handleSaveFile(this.addDocId, this.newDocumentName, this.newDocumentDescription);
        this.showSpinner = true;
        this.showUploadModal = false;
        this.isShowAddModal = false;
        this.isfileUploaded = false;

    }

    handleSaveFile(addDocId, newDocumentName, newDocumentDescription) {
        let dataObj = {
            contentDocumentId: this.contentDocId,
            recordId: this.recordId,
            appDocumentId: addDocId,
            newDocumentName: newDocumentName,
            newDocumentDescription: newDocumentDescription,
            payLoad: JSON.stringify(this.onbaseMetadata),
            fromhandleSave: this.fromhandleSave,
            uploadByInternalUser: true
        };
        setTimeout(() => {
            scanFileAndReturnDocs({
                jsonData: JSON.stringify(dataObj),
                recordId: this.recordId
            }).then(result => {
                const evt = new ShowToastEvent({
                    title: 'Success',
                    message: ' File uploaded successfully.',
                    variant: 'success',
                });
                this.dispatchEvent(evt);
                this.processDocs(result);

                this.showSpinner = false;
                this.newDocumentName = '';
                this.newDocumentDescription = '';
                this.contentDocId = '';
                this.isaddNewDoc = false;
                //this.isfromAddDoc = false;
                this.isfileUploaded = false;
            }).catch(error => {
                showAsyncErrorMessage(this, error);
                this.showSpinner = false;
            });
        }, 12000);
    }

    loadDocumentsList() {
        this.showSpinner = true;
        this.isLoaded = false;
        getDocuments({
            applicationId: this.recordId
        })
            .then(data => {
                this.processDocs(data);
            })
            .catch(error => {
                showAsyncErrorMessage(this, error);
            }).finally(() => {

                this.showSpinner = false;
            });
    }

    processDocs(data) {
        console.log('=== 1. RAW APEX RESPONSE AFTER UPLOAD ===', data);
        if (!data) {
            this.documentsList = [];
            this.documentsListCopy = [];
            this.lawfulPresenceDocumentsList = [];
            this.lawfulPresenceDocumentsListCopy = [];
            this.flowDocumentsList = [];
            this.flowDocumentsListCopy = [];
        } else {
            console.log('data:- ' + JSON.stringify(data));
            this.documentsList = data.documents ? JSON.parse(data.documents) : [];
            console.log('this.documentsList:- ' + this.documentsList);
            this.splitAppDocumentList();
            this.twoByTwoPhotoRecommendation = data.twoByTwoPhotoRecommendation && !this.twoByTwoPhotoRecommendation ? JSON.parse(data.twoByTwoPhotoRecommendation) : this.twoByTwoPhotoRecommendation;
            this.header = this.twoByTwoPhotoRecommendation.with2x2header;
            let payload = data.onbaseMetadata ? JSON.parse(data.onbaseMetadata) : null;
            if (payload && payload.keywordCollection && payload.keywordCollection.items) {
                payload.keywordCollection.items.forEach(item => {
                    item.keywords.forEach(keyWord => {
                        keyWord.values.forEach(keyValue => {
                            keyValue.value = data[keyValue.value];
                        });
                    });
                });
                payload.documentDate = data.documentDate;
                this.onbaseMetadata = payload;
            }
            this.lawfulPresenceDocumentsListCopy = this.lawfulPresenceDocumentsList;
            this.flowDocumentsListCopy = this.flowDocumentsList;
            for (let i = 0; i < this.lawfulPresenceDocumentsListCopy.length; i++) {
                let conData = [];
                for (var key in this.lawfulPresenceDocumentsListCopy[i].contentDocumentId) {
                    conData.push({
                        value: this.lawfulPresenceDocumentsListCopy[i].contentDocumentId[key],
                        key: key
                    });
                }
                this.lawfulPresenceDocumentsList[i].contentDocumentId = conData;
            }
            for (let i = 0; i < this.flowDocumentsListCopy.length; i++) {
                let conData = [];
                for (var key in this.flowDocumentsListCopy[i].contentDocumentId) {
                    conData.push({
                        value: this.flowDocumentsListCopy[i].contentDocumentId[key],
                        key: key
                    });
                }
                this.flowDocumentsList[i].contentDocumentId = conData;
            }
        }
        this.existingData = JSON.parse(JSON.stringify(this.documentsList));
        this.existingLawfulData = JSON.parse(JSON.stringify(this.lawfulPresenceDocumentsList));
        this.existingFlowData = JSON.parse(JSON.stringify(this.flowDocumentsList));
        this.showSpinner = false;
        console.log('flowDocumentsList::: ' + JSON.stringify(this.flowDocumentsList));
    }

    handleViewDocument(event) {
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
            window.open(response.downloadUrl.toString(), "_blank");

        }).then(() => {

            if (fromOnbase) {
                setTimeout(() => {
                    handleContentDocumentDelete({
                        contentDocumentId: dataObj.contentDocId,
                        appDocId: dataObj.appDocId
                    }).then().catch(error => {
                        showAsyncErrorMessage(this, error);
                    });
                }, 12000);
            }

        }).catch(error => {
            showAsyncErrorMessage(this, error);
        }).finally(() => {
            this.showSpinner = false;
        });
    }

    handleFileDeleteConfirmation(event) {
        this.deleteObj = {
            appDocumentId: event.target.dataset.parentid,
            intakeFileDelete: this.intakeFileDelete,
            doNotDelete: this.isaddNewDoc ? true : false

        };
        this.modalHeading = 'Delete Document';
        this.isDeleteModal = true;
        this.showUploadModal = true;

    }
    handleDelFile(event) {
        this.isShowAddModal = false;
        this.fromAdditionalDelete = true;
        this.isShowDeleteModal = true;
        this.deleteObj = {
            appDocumentId: event.target.dataset.parentid,
            intakeFileDelete: this.intakeFileDelete,
            doNotDelete: this.isaddNewDoc ? true : false

        };


    }
    handlecancel(event) {
        this.isShowDeleteModal = false;
        this.isShowAddModal = true;

    }

    handleFileDelete() {
        this.buttonDisabled = true;
        this.showSpinner = true;
        handleFileDelete({
            jsonData: JSON.stringify(this.deleteObj),
            recordId: this.recordId
        }).then(data => {
            showMessage(this, {
                title: "Success",
                message: "File deleted successfully.",
                messageType: "success",
                mode: "dismissable"
            });
            if (this.isaddNewDoc) {
                this.currentContentDocumentId = '';

            }
            if (this.fromAdditionalDelete) {
                this.isShowAddModal = true;

            }
            this.isDeleteModal = false;
            this.showUploadModal = false;

            this.isaddNewDoc = this.deleteObj.doNotDelete ? true : false;
            this.isfileUploaded = false;
            this.isShowDeleteModal = false;
            this.fromAdditionalDelete = false;
            this.doNotDelete = false;
            this.processDocs(data);
        }).catch(error => {
            this.showSpinner = false;
            showAsyncErrorMessage(this, error);
        }).finally(() => {
            this.buttonDisabled = false;
        });
    }

    handleCommentChange(event) {
        const recordindex = event.target.dataset.index;

        if (recordindex == -1) {
            this.newDocumentComments = event.detail.value;
        } else if (event.target.dataset.id == 'lawful') {
            this.lawfulPresenceDocumentsList[recordindex].comments = event.detail.value;
        } else {
            this.flowDocumentsList[recordindex].comments = event.detail.value;
        }
    }

    handleStatusChange(event) {
        const recordindex = parseInt(event.target.dataset.index, 10);
        const newStatus = event.detail.value;

        if (recordindex === -1) {
            this.newDocumentStatus = newStatus;
        } else if (event.target.dataset.id === 'lawful') {
            // Create new array with updated object to trigger LWC reactivity
            this.lawfulPresenceDocumentsList = this.lawfulPresenceDocumentsList.map((doc, idx) => {
                if (idx === recordindex) {
                    return { ...doc, status: newStatus };
                }
                return doc;
            });
        } else {
            // Create new array with updated object to trigger LWC reactivity
            this.flowDocumentsList = this.flowDocumentsList.map((doc, idx) => {
                if (idx === recordindex) {
                    return { ...doc, status: newStatus };
                }
                return doc;
            });
        }
    }

    handleModeChange(event) {
        const recordindex = event.target.dataset.index;
        if (recordindex == -1) {
            this.isRequired = event.detail.value;
        } else if (event.target.dataset.id == 'lawful') {
            this.lawfulPresenceDocumentsList[recordindex].documentMode = event.detail.value;
        } else {
            this.flowDocumentsList[recordindex].documentMode = event.detail.value;
        }
    }

    handleEdit() {
        this.isDisabled = false;
    }

    handleSave() {
        this.showSpinner = true;
        // Merge flowDocumentsList and lawfulPresenceDocumentsList for saving
        const mergedDocumentsList = [...this.flowDocumentsList, ...this.lawfulPresenceDocumentsList];
        console.log('wrapper ', JSON.stringify(mergedDocumentsList));
        updateDocuments({
            wrapperStr: JSON.stringify(mergedDocumentsList),
            applicationId: this.recordId
        })
            .then(data => {
                this.isDisabled = true;
                this.showSpinner = false;
                this.loadDocumentsList();
            })
            .catch(error => {
                this.showSpinner = false;
            });
    }

    handleCancel() {
        this.documentsList = JSON.parse(JSON.stringify(this.existingData));
        this.lawfulPresenceDocumentsList = JSON.parse(JSON.stringify(this.existingLawfulData));
        this.flowDocumentsList = JSON.parse(JSON.stringify(this.existingFlowData));
        this.isDisabled = true;
        this.loadDocumentsList();
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

    showModalBox() {
        this.showUploadModal = true;
    }

    hideModalBox() {
        this.buttonDisabled = true;
        if (this.is2x2Photo && !this.documentIdSet.includes(this.documentIdForFileUpload)) {
            this.showUploadModal = false;
            this.newFileAttachment = null;
            this.dcumentId = null;
            this.documentIdForFileUpload = null;
            this.isDeleteModal = false;
            this.buttonDisabled = false;
        } else if (this.isDeleteModal) {
            this.showUploadModal = false;
            this.isDeleteModal = false;
            this.buttonDisabled = false;
        } else {
            handleCancel({
                recordId: this.documentIdForFileUpload

            }).then(() => {
                this.showUploadModal = false;
                this.isDeleteModal = false;
                this.documentsList = JSON.parse(JSON.stringify(this.existingData));
                this.lawfulPresenceDocumentsList = JSON.parse(JSON.stringify(this.existingLawfulData));
                this.flowDocumentsList = JSON.parse(JSON.stringify(this.existingFlowData));
                this.isDisabled = true;
                this.loadDocumentsList();
            }).catch(error => {
                showAsyncErrorMessage(this, error);
                this.showUploadModal = false;
            }).finally(() => {
                this.buttonDisabled = false;
            });
        }

    }

    handleNew() {
        this.showNewModal = true;
        this.filesData = [];
        this.fileName = [];
    }

    hideNewModalBox() {
        this.showNewModal = false;
    }

    handleCheckboxChange(event) {
        let fieldName = event.target.name;
        let fieldValue = event.target.checked;
        if (fieldName == 'isAttachment') {
            this.isAttachment = fieldValue;
        } else if (fieldName == 'isSubmissionRequired') {
            this.isSubmissionRequired = fieldValue;
        }
    }

    documentChangeHandler(event) {
        this.newDocumentName = event.detail.value;
        const inputBox = event.currentTarget;

        inputBox.setCustomValidity('');
        inputBox.reportValidity();
    }


    splitAppDocumentList() {
        let tempLawfulPresenceDocumentsList = [];
        let tempFlowDocumentList = [];

        if (this.documentsList !== null && this.documentsList !== undefined) {
            this.documentsList.forEach(document => {

                document.parentFilePresent = document.contentDocumentId || document.files.filter(function (file) { return (file.parentRecId == document.documentId); }).length > 0;
               if (document.parentFilePresent && document.status === 'Unsubmitted') {
                document.status = 'Submitted';
               }       
                if (document.status === 'Submitted' || document.contentDocumentId || (document.files && document.files.length > 0)) {
                    this.documentIdSet.push(document.documentId);
                }
                document.statusClass = 'slds-badge ';
                if (document.status == 'Unsubmitted') {
                    document.statusClass = document.statusClass + 'slds-theme_disabled';
                } else if (document.status == 'Submitted') {
                    document.statusClass = document.statusClass + 'slds-theme_info';
                } else if (document.status == 'Approved') {
                    document.statusClass = document.statusClass + 'slds-theme_success';
                } else if (document.status == 'Rejected') {
                    document.statusClass = document.statusClass + 'slds-theme_error';
                } else if (document.status == 'Notice') {
                    document.statusClass = document.statusClass + 'slds-theme_warning';
                }
                if (document.isLawfulPresentDocument) {
                    tempLawfulPresenceDocumentsList = [...tempLawfulPresenceDocumentsList, document];
                } else {
                    tempFlowDocumentList = [...tempFlowDocumentList, document];
                }
            });
        }

        this.lawfulPresenceDocumentsList = tempLawfulPresenceDocumentsList;
        this.flowDocumentsList = tempFlowDocumentList;
        this.isLoaded = true;
    }
    get islawfulDocumentsPresent() {
        if (this.lawfulPresenceDocumentsList.length > 0) {
            return true;
        } else {
            return false;
        }
    }
    get isFlowDocumentsPresent() {
        if (this.flowDocumentsList.length > 0) {
            return true;
        } else {
            return false;
        }
    }
}