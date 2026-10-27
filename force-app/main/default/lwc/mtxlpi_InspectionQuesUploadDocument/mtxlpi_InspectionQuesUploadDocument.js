import { LightningElement, api, track,wire } from 'lwc';
import { OmniscriptActionCommonUtil } from "omnistudio/omniscriptActionUtils";
import { OmniscriptBaseMixin } from 'omnistudio/omniscriptBaseMixin';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getNamespaceDotNotation } from "omnistudio/omniscriptInternalUtils";
import {getRecord} from 'lightning/uiRecordApi';

export default class Mtxlpi_InspectionQuesUploadDocument extends OmniscriptBaseMixin(LightningElement) {

    @track recordId;
    @track status;
    @track documentList = [];
    @track urlInternal;
    @track profileName;
    @track prfName;
    @track showSpinner = false;
    @track deleteContentDocumentRecId;
    @track isShowConfirmDeleteModal;

    get documentData() {
        if (this.documentList.length > 0) {
            return true;
        }
        else {
            return false;
        }
    }

    get disableUpload() {
        if (this.status == 'Open' || this.status == null) {
            return false;
        }
        return true;
    }

    connectedCallback() {
      
        this._actionUtil = new OmniscriptActionCommonUtil();
        this.prfName = this.omniJsonData.userProfile;
        if (this.omniJsonData.status != null) {
            this.status = this.omniJsonData.status;
        }
        if (this.omniJsonData.regCodeViolationId != null) {
            this.recordId = this.omniJsonData.regCodeViolationId;
            this.urlInternal = false;
        }
        else {
            this.recordId = this.omniJsonData.inspectAssesId;
            this.urlInternal = true;
        }
        this.init();

    }

    init() {
        const params = {
            input: JSON.stringify(this.omniJsonData),
            // sClassName: 'LPI_InspectionUploadDocController',
            // sMethodName: 'getInspectionUploadedDocumentList',
            options: '{}',
        };

        this._actionUtil
            .executeAction(params, null, this, null, null)
            .then(response => {
                //this.documentList = JSON.parse(response.result.documentList);
                this.documentList = JSON.parse(response.result.documentList).map(obj => (
                    {
                        ...obj,
                        ariaLabelForDownload: 'Download '+ obj.contentDocumentTitle,
                        ariaLabelForDelete: 'Delete '+ obj.contentDocumentTitle,
                    })
                );
            })
            .catch(error => {
                this.showMessage('Error occured while Loading. ', error.body.message, 'error', 'pester');
            });
    }

    getBaseUrl() {
        let baseUrl = 'https://' + location.host + '/';
        return baseUrl;
    }

    handleDownload(event) {
        let contentId = event.target.dataset.contentid;
        const sitePrefix = this.getBaseUrl();
        if (this.prfName == 'Portal User') {
            window.open('/demo/sfc/servlet.shepherd/document/download/' + contentId, '_blank');
        }
        else {
            window.open(sitePrefix + '/sfc/servlet.shepherd/document/download/' + contentId);
        }

    }

    handleUploadFinished() {
        this.init();
        this.showToast("Success", "File uploaded successfully", "success");
    }

    handleDeleteConfirmationModal(event){
        this.deleteContentDocumentRecId = event.target.dataset.id;
        this.isShowConfirmDeleteModal = true;
    }

    handleFileDelete(event) {
        this.showSpinner = true;
        const deleteContentDocumentId = this.deleteContentDocumentRecId;
        const optionsdata = {
            contentDocumentId: deleteContentDocumentId
        };
        const params = {
            input: JSON.stringify(this.omniJsonData),
            // sClassName: 'LPI_InspectionUploadDocController',
            // sMethodName: 'deleteContentFile',
            options: JSON.stringify(optionsdata),
        };

        this._actionUtil
            .executeAction(params, null, this, null, null)
            .then(response => {
                this.init();
                this.showSpinner = false;
                this.isShowConfirmDeleteModal = false;
                this.showToast("Success", "File deleted successfully", "error");
            })
            .catch(error => {
                this.showMessage('Error occured while Loading. ', error.body.message, 'error', 'pester');
                this.showSpinner = false;
            });
    }

    hideConfirmDeleteModalBox(event){
        this.isShowConfirmDeleteModal = false;
    }

    showToast(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }

}