import downloadFile from '@salesforce/apex/LPI_OnBaseIntegrationController.downloadFileFromSf';
import handleCancel from '@salesforce/apex/LPI_OnBaseIntegrationController.handleCancel';
import handleContentDocumentDelete from '@salesforce/apex/LPI_OnBaseIntegrationController.handleContentDocumentDelete';
import handleFileDelete from '@salesforce/apex/LPI_OnBaseIntegrationController.handleFileDelete';
import createApplicationDocumentForTask from '@salesforce/apex/LPI_VisitRegCodeViolationController.createApplicationDocumentForTask';
import fetchTaskRecords from '@salesforce/apex/LPI_VisitRegCodeViolationController.fetchOnlyTaskRecords';
import getFileScanResult from '@salesforce/apex/LPI_VisitRegCodeViolationController.getFileScanResult';
import getCurrentLanguage from '@salesforce/apex/EMP_LanguageCtrl.getCurrentLanguage';
import getLabels from '@salesforce/apex/EMP_LanguageCtrl.getLabels';
import AccountId from '@salesforce/schema/User.AccountId';
import Name from '@salesforce/schema/User.Name';
import userId from '@salesforce/user/Id';
import fileScanSetTimoutValue from '@salesforce/label/c.Upload_File_Scan_Timeout_Value';
import lpiResource from '@salesforce/resourceUrl/LPI_Design';
import {
    showAsyncErrorMessage,
    showMessage
} from 'c/lpiUtil';
import {
    LABEL_API_NAMES,
    mapApiToCamel,
    translateStatus,
    readStoredLanguage,
    writeStoredLanguage
} from 'c/lpLanguageUtils';
import {
    getRecord
} from 'lightning/uiRecordApi';
import {
    LightningElement,
    track,
    wire
} from 'lwc';

export default class LpiMyTasks extends LightningElement {
    noRecord = lpiResource + '/media/icons/no-record.svg';

    @track labels = {
        allTasks: 'All Tasks',
        noTaskAvailable: 'No Task Available',
        subject: 'Subject',
        dueDate: 'Due Date',
        status: 'Status',
        dateReceived: 'Date Received',
        results: 'Results',
        files: 'Files',
        action: 'Action',
        uploadFiles: 'Upload Files',
        addFileToUpload: 'Add file to upload',
        attachFile: 'Attach file',
        deleteFileConfirm: 'Are you sure you want to delete this file ?',
        allTasksTableCaption: 'All Tasks Table',
        cancel: 'Cancel',
        close: 'Close',
        yes: 'Yes',
        remove: 'Delete',
        warning: 'Warning',
        completed: 'Completed'
    };

    @track columns = [];

    @track isTaskDataLoaded = false;
    @track isTaskAvailable = false;
    accId;
    portalUserName;
    @track taskRecords = [];
    @track showSpinner = false;
    languageReady = false;
    onBaseRecord;
    twoByTwoPhotoRecommendation;
    displayModal;
    isDeleteModal = false;
    @track deleteFileobj = {};
    @track dataObj = {};

    get acceptedFormats() {
        ".doc", ".docx", ".ppt", ".pptx", ".pdf", ".bmp", ".jpeg", ".jpg", ".png", ".heic", ".webp"
    }
    modalHeading = 'Add file to upload';

    connectedCallback() {
        this.showSpinner = true;
        this.initLanguage().then(() => {
            this.buildColumns();
            this.modalHeading = this.labels.addFileToUpload;
            this.languageReady = true;
            if (this.accId) {
                this.getAllMyTasks();
            }
        });
    }

    async initLanguage() {
        const stored = readStoredLanguage();
        let lang = stored;
        if (!lang) {
            try {
                lang = await getCurrentLanguage();
            } catch (e) {
                lang = 'en_US';
            }
        }
        lang = lang === 'fr' ? 'fr' : 'en_US';
        writeStoredLanguage(lang);
        try {
            const apiMap = await getLabels({
                apiNames: LABEL_API_NAMES,
                language: lang
            });
            this.labels = { ...this.labels, ...mapApiToCamel(apiMap) };
        } catch (e) {
            // keep defaults
        }
    }

    buildColumns() {
        this.columns = [
            { label: this.labels.subject, fieldName: 'Subject' },
            { label: this.labels.dueDate, fieldName: 'DueDate' },
            { label: this.labels.status, fieldName: 'Status' },
            { label: this.labels.dateReceived, fieldName: 'DateReceived' },
            { label: this.labels.results, fieldName: 'Results' },
            { label: this.labels.files, fieldName: 'Files' },
            { label: this.labels.action, fieldName: 'Action' }
        ];
    }

    @wire(getRecord, {
        recordId: userId,
        fields: [AccountId, Name]
    })
    userRecInfo({
        error,
        data
    }) {
        if (data) {
            this.accId = data.fields.AccountId.value;
            this.portalUserName = data.fields.Name.value;
            if (this.languageReady) {
                this.getAllMyTasks();
            }
        }
    }

    getAllMyTasks() {
        this.showSpinner = true;
        fetchTaskRecords({
            accountId: this.accId
        })
            .then(rec => {
                this.getTaskRecords(rec);
            })
            .catch(err => {
                this.showSpinner = false;
                showAsyncErrorMessage(this, err);
            });
    }

    handleFile(event) {
        this.showSpinner = true;
        let boardName = event.target.dataset.board;
        let recordid = event.target.dataset.recordid;
        let ownerId = event.target.dataset.ownerid;
        let taskAction = event.target.dataset.taskaction;
        let caseNumber = event.target.dataset.casenumber;
        let caseSubject = event.target.dataset.casesubject;
        let duedate = event.target.dataset.duedate;
        let status = event.target.dataset.status;
        let ownerName = event.target.dataset.ownername;
        let onBaseMeta = event.target.dataset.metadata;

        this.dataObj = {
            documentName: 'Task Document',
            boardName: boardName,
            lookupFieldName: 'Task_Id__c',
            lookupFieldId: recordid,
            isSendNotification: true,
            ownerId: ownerId,
            activeActivity: taskAction,
            caseNumber: caseNumber,
            caseSubject: caseSubject,
            portalUserName: this.portalUserName,
            dueDate: duedate,
            status: status,
            ownerName: ownerName,
            onbasePayload: onBaseMeta
        };
        createApplicationDocumentForTask({
            accountId: event.target.dataset.accountid,
            jsonData: JSON.stringify(this.dataObj)
        }).then((responseMap) => {
            this.showSpinner = false;
            this.appDocRecordId = responseMap.appDocId;
            this.modalHeading = this.labels.addFileToUpload;
            this.displayModal = true;
            // eslint-disable-next-line @lwc/lwc/no-async-operation
            setTimeout(() => {
                this.focusFirstEle();
            }, 500);
        }).catch(error => {
            showAsyncErrorMessage(this, error);
            this.showSpinner = false;
        }).finally(() => {
            this.showSpinner = false;
        });
    }

    handleUploadFinished(event) {
        this.showSpinner = true;
        showMessage(this, {
            title: "Warning",
            message: "Document has been uploaded and it is currently being scanned ,do not refresh the page, or click on any button.",
            messageType: "warning",
            mode: "dismissable"
        });
        this.displayModal = false;
        let scanDataObj = {
            contentDocumentId: event.detail.files[0].documentId,
            appDocumentId: this.appDocRecordId,
            newDocumentName: event.detail.files[0].name
        };
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        setTimeout(() => {
            getFileScanResult({
                jsonData: JSON.stringify(scanDataObj),
                notiJsonData: JSON.stringify(this.dataObj),
                accountId: this.accId
            }).then(result => {
                this.getTaskRecords(result);
                showMessage(this, {
                    title: "Success",
                    message: 'Document uploaded successfully.',
                    messageType: "success",
                    mode: "dismissable"
                });
                this.showSpinner = false;
            }).catch(error => {
                showAsyncErrorMessage(this, error);
                this.showSpinner = false;
            });
        }, fileScanSetTimoutValue);
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        setTimeout(() => {
            this.template.querySelector(".uploadbtn").focus();
        }, 18000);
    }

    handleKeyDown(event) {
        if (event.code === 'Enter') {
            this.handleDownload(event);
        }
    }

    handleClose() {
        if (!this.isDeleteModal) {
            handleCancel({
                recordId: this.appDocRecordId
            }).then().catch(error => {
                showAsyncErrorMessage(this, error);
            });
        }
        this.displayModal = false;
        this.isDeleteModal = false;
        this.deleteFileobj = null;
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        setTimeout(() => {
            this.template.querySelector(".uploadbtn").focus();
        }, 5000);
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
            window.open(response.downloadUrl.toString(), "_blank");
        }).then(() => {
            if (fromOnbase) {
                // eslint-disable-next-line @lwc/lwc/no-async-operation
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

    handleDeleteConfirmation(event) {
        this.isDeleteModal = true;
        this.modalHeading = this.labels.deleteFileConfirm;
        this.deleteFileobj = {
            appDocumentId: event.target.dataset.parentid
        };
        this.displayModal = true;
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        setTimeout(() => {
            this.focusFirstEle();
        }, 800);
    }

    handleDelete() {
        this.showSpinner = true;
        handleFileDelete({
            jsonData: JSON.stringify(this.deleteFileobj)
        }).then(() => {
            this.handleClose();
            showMessage(this, {
                title: "Success",
                message: 'File has been deleted successfully.',
                messageType: "success",
                mode: "dismissable"
            });
            this.getAllMyTasks();
        }).catch(error => {
            showAsyncErrorMessage(this, error);
            this.showSpinner = false;
        });
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        setTimeout(() => {
            this.template.querySelector(".uploadbtn").focus();
        }, 8000);
    }

    getTaskRecords(rec) {
        if (!rec) {
            this.showSpinner = false;
            this.isTaskDataLoaded = true;
            return;
        }
        if (rec.taskWrapList.length > 0) {
            this.isTaskAvailable = true;
            this.taskRecords = rec.taskWrapList.map(record => {
                let isStatusCompleted = record.taskStatus == 'Completed' || (record.filesList.length >= 5) ? true : false;
                let accountId = this.accId;
                record.fileUploadAriaLabel = `Upload Files for ${record.taskSubject}`;
                const displayStatus = translateStatus(record.taskStatus, this.labels);
                return { ...record, isStatusCompleted, accountId, displayStatus };
            });
            this.showSpinner = false;

            this.twoByTwoPhotoRecommendation = rec.twoByTwoPhotoRecommendation ? JSON.parse(rec.twoByTwoPhotoRecommendation) : null;
            this.taskRecords.forEach(task => {
                task.filesList.forEach(file => {
                    file.downloadAriaLabel = `Download ${file.fileName} for ${task.taskSubject}`;
                    file.deleteAriaLabel = `Delete ${file.fileName} for ${task.taskSubject}`;
                });
            });
        }
        this.isTaskDataLoaded = true;
    }

    focusFirstEle() {
        const focusableElements =
            "lightning-button-icon, lightning-helptext, lightning-button, button, lightning-input, lightning-textarea, lightning-combobox";
        const modal = this.template.querySelector(".slds-modal");
        const firstFocusableElement = modal.querySelectorAll(focusableElements)[0];
        const focusableContent = modal.querySelectorAll(focusableElements);
        const lastFocusableElement = focusableContent[focusableContent.length - 1];
        firstFocusableElement.focus();
        this.template.addEventListener("keydown", function (event) {
            let isTabPressed = event.key === "Tab" || event.keyCode === 9;
            if (!isTabPressed) {
                return;
            }
            if (event.shiftKey) {
                if (this.activeElement === firstFocusableElement) {
                    lastFocusableElement.focus();
                    event.stopPropagation();
                    event.preventDefault();
                }
            } else if (this.activeElement === lastFocusableElement) {
                firstFocusableElement.focus();
                event.preventDefault();
                event.stopPropagation();
            }
        });
    }

    handleEscCloseModal(event) {
        const ESC = 27;
        if (event.key === "Escape" || event.key === "Esc" || event.keyCode == ESC) {
            this.handleDeleteConfirmation();
            this.handleClose();
        }
    }
}