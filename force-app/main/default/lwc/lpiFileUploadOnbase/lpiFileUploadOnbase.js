import {
    LightningElement,
    api,
    track
} from 'lwc';
import {
    showAsyncErrorMessage,
    showMessage
} from 'c/lpiUtil';
import getUploadDetails from '@salesforce/apex/LPI_OnBaseIntegrationController.getUploadDetails';
import LPI_Onbase_App_Doc_Field_Mapping from '@salesforce/label/c.Onbase_App_Doc_Field_Mapping';
import createApplicationDocument from '@salesforce/apex/LPI_VisitRegCodeViolationController.createApplicationDocument';
import getFileScanResult from '@salesforce/apex/LPI_OnBaseIntegrationController.bypassOnbase';
import downloadFile from '@salesforce/apex/LPI_OnBaseIntegrationController.downloadFileFromSf';
import handleFileDelete from '@salesforce/apex/LPI_OnBaseIntegrationController.handleFileDelete';
import handleCancel from '@salesforce/apex/LPI_OnBaseIntegrationController.handleCancel';
import handleContentDocumentDelete from '@salesforce/apex/LPI_OnBaseIntegrationController.handleContentDocumentDelete';
import fileScanSetTimoutValue from '@salesforce/label/c.Upload_File_Scan_Timeout_Value';
import lpiTheme from "@salesforce/resourceUrl/LPI_Design";
import { loadStyle } from "lightning/platformResourceLoader";
import LPI_DocumentFormats from '@salesforce/label/c.LPI_DocumentFormats';


export default class lpiFileUploadOnbase extends LightningElement {
    @api objectApiName;
    @api recordId;
    @track newFileAttachment;
    @track uploadedFiles;
    displayModal;
    payLoad;
    showSpinner;
    response;
    displayFilesTable;
    onbaseFieldLabel = LPI_Onbase_App_Doc_Field_Mapping;
    twoByTwoPhotoRecommendation;
    showCmp;
    uploadNotRequired;
    appDocRecordId;
    header;
    isDeleteModal = false;
    @track deleteFileobj ={}
    @track columns = [{
            label: 'File Name',
            fieldName: 'fileName'
        },
        {
            label: 'Action',
            fieldName: 'action'
        }
    ]

    get acceptedFormats() {
        return LPI_DocumentFormats.split(",");
    }

    modalHeading = 'Add file to upload'
    connectedCallback() {
        this.showSpinner = true;
        this.loadData();
        //loading css file
        // loadStyle(this, lpiTheme + "/Alpha_internal.css");
        loadStyle(this, lpiTheme + "/styles/internal-main.css");
    }

    loadData() {
        console.log(JSON.parse(this.onbaseFieldLabel)[this.objectApiName].apiFieldName + ' = \'' + this.recordId + '\'');
        getUploadDetails({
            recordId: this.recordId,
            objectApiName: this.objectApiName,
            whereClause : JSON.parse(this.onbaseFieldLabel)[this.objectApiName].apiFieldName + ' = \'' + this.recordId + '\''
        }).then((result => {
            if (!result) {
                showAsyncErrorMessage(this, 'Error loading Component');
                return;
            }
            this.processData(result);
           
        })).catch(error => {
            showAsyncErrorMessage(this, error);
            this.uploadNotRequired = true;
            this.showSpinner = false;
        })
    }

    processData(result){
        this.showCmp = result.uploadReqd;
        this.uploadNotRequired = !this.showCmp;
        this.response = result;
        this.payLoad = result.onbaseConfig && result.onbaseConfig.payload ? JSON.parse(result.onbaseConfig.payload) : null;
        this.twoByTwoPhotoRecommendation = result.twoByTwoPhotoRecommendation && !this.twoByTwoPhotoRecommendation ? JSON.parse(result.twoByTwoPhotoRecommendation) : this.twoByTwoPhotoRecommendation;
        this.header = this.twoByTwoPhotoRecommendation.without2x2header;
        this.uploadedFiles = result.fileList;
        this.displayFilesTable = this.uploadedFiles && this.uploadedFiles.length > 0;
        if (this.payLoad && this.payLoad.keywordCollection && this.payLoad.keywordCollection.items) {
            this.payLoad.keywordCollection.items.forEach(item => {
                item.keywords.forEach(keyWord => {
                    keyWord.values.forEach(keyValue => {
                        keyValue.value = result[keyValue.value]
                    })
                })
            })
            this.payLoad.documentDate = result.documentDate
        }
        this.showSpinner = false;
    }

    createAppDoc(){
        
        this.showSpinner = true;
        let dataObj = {
            boardName: this.response.boardName,
            lookupFieldName: JSON.parse(this.onbaseFieldLabel)[this.objectApiName].apiFieldName,
            lookupFieldId: this.recordId,
            onbasePayload : JSON.stringify(this.payLoad),
            documentName: JSON.parse(this.onbaseFieldLabel)[this.objectApiName].docName
        }
        createApplicationDocument({
            jsonData: JSON.stringify(dataObj)
        }).then((responseMap) => {
            this.appDocRecordId = responseMap.appDocId;
            this.displayModal = true;
        }).catch(error => {
            showAsyncErrorMessage(this, error)
        }).finally(() => {
            this.showSpinner = false;
        })
    }


    handleUploadFinished(event){
        this.showSpinner = true;
        showMessage(this, {
            title: "Warning",
            message: "Document has been uploaded and it is currently being scanned,do not refresh the page,or click on any button.",
            messageType: "warning",
            mode: "dismissable"
        });        this.displayModal = false;
        let dataObj = {
            appDocumentId : this.appDocRecordId,//event.detail.files[0].documentId,
            recordId: this.recordId,
            objectApiName: this.objectApiName,
            whereClause : JSON.parse(this.onbaseFieldLabel)[this.objectApiName].apiFieldName + ' = \'' + this.recordId + '\'',
            fromGenericCmp : true,
            uploadByInternalUser : true
        }
        setTimeout(() => {
            getFileScanResult({
                jsonData : JSON.stringify(dataObj)
            }).then(result => {
                this.processData(result);
                showMessage(this, {
                    title: "Success",
                    message: "Document has been uploaded successfully.",
                    messageType: "success",
                    mode: "dismissable"
                });
            }).catch(error => {
                showAsyncErrorMessage(this, error)
                this.showSpinner = false;
            })
        }, fileScanSetTimoutValue);
        
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

    handleClose() {
        if(!this.isDeleteModal){
            handleCancel({
                recordId : this.appDocRecordId
            }).then().catch(error =>{
                showAsyncErrorMessage(this,error);
            })
        }
        this.newFileAttachment = null;
        this.displayModal = false;
        this.isDeleteModal = false;
        this.deleteFileobj = null;
    }




    handleDeleteConfirmation(event) {
        this.isDeleteModal = true;
        this.modalHeading = 'Are you sure you want to delete this file ?';
        this.deleteFileobj = {
            appDocumentId : event.target.dataset.parentid,
            fileId : event.target.dataset.fileid,
            recordId: this.recordId,
            objectApiName: this.objectApiName,
            whereClause : JSON.parse(this.onbaseFieldLabel)[this.objectApiName].apiFieldName + ' = \'' + this.recordId + '\'',
            fromGenericCmp : true
        }
        this.displayModal = true;
    }

    handleDelete(){
        this.showSpinner = true;
        handleFileDelete({
            jsonData : JSON.stringify(this.deleteFileobj)
        }).then(result =>{
            this.handleClose();
            showMessage(this,{
                title: "Success",
                message: 'File has been deleted successfully.',
                messageType: "success",
                mode: "dismissable"
            })
            this.modalHeading ='Add file to upload';
            this.processData(result);
        }).catch(error => {
            showAsyncErrorMessage(this,error);
            this.showSpinner = false;
        })
    }
}