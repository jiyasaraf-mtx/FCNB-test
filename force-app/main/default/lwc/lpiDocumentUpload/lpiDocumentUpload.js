import { LightningElement,api,track,wire } from 'lwc';
import {OmniscriptActionCommonUtil} from "omnistudio/omniscriptActionUtils";
import {OmniscriptBaseMixin} from 'omnistudio/omniscriptBaseMixin';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import {CurrentPageReference} from 'lightning/navigation';

export default class LpiDocumentUpload extends OmniscriptBaseMixin(LightningElement) {
    @api recordId;
    @api isReview;
    @track isReviewPage;
    @track appDocumentList = [];
    @track flowDocumentsList = [];
    @track lawfulPresenceDocumentsList = [];
    @track additionalDocumentsList = [];
    @track showSpinner = false;
    @track showUploadModal = false;
    @track showDeleteModal = false;
    @track fileSectionName;
    @track deletingFileId;
    @track showAddDocUploadModal = false;
    @track isfileUploaded = false;
    @track addDocId;
    @track addDocName;
    @track addDocDesc;
    @track isfileUploaded=false;
    @track omniJsonDataCustom = {
        parId: ''
    };
    @track parIdfromURL;

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.parIdfromURL = currentPageReference.state?.c__parid;
        }
    }

    _actionUtil;

    connectedCallback() {
        this.showSpinner = true;
        this.isReviewPage = this.isReview ? true : false;
        this._actionUtil = new OmniscriptActionCommonUtil();
        setTimeout(() => {
            if (this.template.querySelector('.btnUploadFocus') != null) {
                this.template.querySelector('.btnUploadFocus').focus()
            };
        }, 1000);
        
        if(this.isReviewPage){
            const optionsdata = {
                parId: this.parIdfromURL
            };
            this.omniJsonDataCustom = optionsdata;
            console.log('## omniJsonDataCustom ',this.omniJsonDataCustom);
            this.init();
        }else{
            console.log('## omniJsonData ',this.omniJsonData);
            this.init();
        }
        console.log('##@@@ Comparison ',this.omniJsonData == null, ' @@@ Custom ',this.omniJsonDataCustom == null);

    }

    errorCallback(error) {
       console.log('##Error in Loading LWC. Contact System Admin!!!',error);
    }

    init() {
        console.log('Init Called');
        const inputData = JSON.stringify((this.omniJsonData != undefined  && this.omniJsonData != null ) ? this.omniJsonData : this.omniJsonDataCustom);
        console.log('Init >> ',JSON.stringify(inputData));
        const params = {
            input: inputData,
            sClassName: 'LPI_DocumentUploadController',
            sMethodName: 'getApplicationDocumentList',
            options: '{}',
        };

        this._actionUtil
            .executeAction(params, null, this, null, null)
            .then(response => {
                if (!response || !response.result || !response.result.applicationDocumentInfo) {
                    this.appDocumentList = [];
                    this.splitAppDocumentList();
                    return;
                }
                const info = response.result.applicationDocumentInfo;
                const docsPayload = info.documents;
                if (!docsPayload) {
                    this.appDocumentList = [];
                } else {
                    this.appDocumentList = typeof docsPayload === 'string'
                        ? JSON.parse(docsPayload)
                        : docsPayload;
                }
                if (!Array.isArray(this.appDocumentList)) {
                    this.appDocumentList = [];
                }
                this.splitAppDocumentList();
            })
            .catch(error => {
                console.log('##Action Util errro >> ',JSON.stringify(error));
                this.appDocumentList = [];
                this.splitAppDocumentList();
            })
            .finally(()=>{
                this.showSpinner = false;
            });
    }

    splitAppDocumentList() {
        let tempFlowDocumentList = [];
        let tempAdditionalDocumentsList = [];
        let tempLawfulPresenceDocumentsList = [];

        if (this.appDocumentList !== null && this.appDocumentList !== undefined) {
            this.appDocumentList.forEach(document => {
                let documentType = document.documentRecord.Is_Document_Required__c ? 'Required Document' : 'Optional Document';
                if (document.documentRecord.Is_Lawful_Presence_Document__c) {
                    tempLawfulPresenceDocumentsList = [...tempLawfulPresenceDocumentsList, document];
                }else if (document.documentRecord.Is_additional_document_by_portal_user__c){
                    tempAdditionalDocumentsList = [...tempAdditionalDocumentsList, document];
                }
                else {
                    tempFlowDocumentList = [...tempFlowDocumentList, document];
                }
                if (document.documentRecord.ContentDocumentLinks && document.documentRecord.ContentDocumentLinks.records) {
                    document.documentRecord.ContentDocumentLinks.records.forEach(cv => {
                        cv.deleteAriaLabel = 'Delete ' + cv.ContentDocument.Title;
                        cv.downloadAriaLabel = 'Download ' + cv.ContentDocument.Title + ' Uploaded for ' + document.documentRecord.Document_Name__c + ' ' + documentType;
                    })
                }
                if (document.files) {
                    document.files.forEach(file => {
                        if (file.uniqueId) {
                            this.documentsIdSet.push(document.documentRecord.Id);
                        }
                        file.deleteAriaLabel = 'Delete ' + file.fileName;
                        file.downloadAriaLabel = 'Download ' + file.fileName + ' Uploaded for ' + document.documentRecord.Document_Name__c + ' ' + documentType;
                    })
                }
            })
        }
        console.log('appDocumentList :>> ', JSON.stringify(this.appDocumentList));
        this.lawfulPresenceDocumentsList = tempLawfulPresenceDocumentsList;
        this.flowDocumentsList = tempFlowDocumentList;  
        this.additionalDocumentsList = tempAdditionalDocumentsList;
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

    get isAdditionalDocumentsPresent() {
        if (this.additionalDocumentsList.length > 0) {
            return true;
        } else {
            return false;
        }
    }

    showMessage(title, message, variant, mode) {
        const toastEvt = new ShowToastEvent({
            title,
            message,
            variant,
            mode
        });
        this.dispatchEvent(toastEvt);
    }
    

    handleUploadClick(event){
        this.showUploadModal = true;
        this.showSpinner = true;
        setTimeout(() => {
             this.focusFirstEle();
         }, 500);
        this.documentIdForFileUpload = event.currentTarget.dataset.docid;
        this.documentName = event.currentTarget.dataset.docname;
        this.showSpinner = false;
    }

    hideUploadModalBox(){
        this.showUploadModal = false;
				  setTimeout(() => {
							this.template.querySelector(`[data-docid="${this.documentIdForFileUpload}"]`)?.focus();
					}, 500);
    }

    handleUploadFinish(event){
        this.hideUploadModalBox();
        this.init();
        this.showMessage('File Uploaded','File successfully uploaded','Success','pester');
    }

    handleSaveNewDocument(event){
        this.showSpinner = true;
        this.displayModal = false;
        console.log('Saving new document');

        let jsonData = {
                appDocumentId: this.addDocId,
                docName: this.addDocName,
                docDesc: this.addDocDesc
        };

        const inputData = JSON.stringify(this.omniJsonData != undefined ? this.omniJsonData : this.omniJsonDataCustom);
        const params = {
            input: inputData,
            sClassName: 'LPI_DocumentUploadController',
            sMethodName: 'saveAdditionalDocument',
            options: JSON.stringify(jsonData)
        };

        this._actionUtil
            .executeAction(params, null, this, null, null)
            .then(response => {
                if (!response) {
                    return;
                }
                this.showMessage('Success', 'Document has been successfully uploaded.', 'success', 'dismissable');
                this.showSpinner = false;
                this.showAddDocUploadModal = false;
                setTimeout(() => {
                    this.template.querySelector(`[data-docid="${this.documentIdForFileUpload}"]`)?.focus();
                }, 1000);
            })
            .catch(error => {
                this.showMessage('Error', 'Error uploading document.', 'error', 'dismissable');
            })
            .finally(()=>{
                this.showSpinner = false;
                this.isfileUploaded = false;
                this.newfilename = null;
                this.init();
            });
    }

    handleAddDocUploadFinish(event){
        this.isfileUploaded = true;
        this.init();
        this.newfilename =  event.detail.files[0].name;
    }

    handleAddDocChange(event){
        console.log(event.target.name);
        console.log(event.target.value);
        if(event.target.name =='addDocName'){
            this.addDocName = event.target.value;
        } else if(event.target.name =='addDocDesc'){
            this.addDocDesc = event.target.value;
        }
    }

    handleDownload(event) {
        this.showSpinner = true;
        this.showMessage('Info', 'Document will download shortly.', 'info', 'dismissable');
        let dataObj = {
            documentId: event.target.dataset.parentrecid
        };
        console.log(event.target.dataset.parentrecid);

        const inputData = JSON.stringify(this.omniJsonData != undefined ? this.omniJsonData : this.omniJsonDataCustom);
        const params = {
            input: inputData,
            sClassName: 'LPI_DocumentUploadController',
            sMethodName: 'downloadFile',
            options: JSON.stringify(dataObj)
        };

        this._actionUtil
            .executeAction(params, null, this, null, null)
            .then((response) => {
                if (!response) {
                    return;
                }
                console.log(JSON.stringify(response));
                console.log(JSON.stringify(response.result.outputData.downloadUrl.toString()));
                let windowDoc = window.open(response.result.outputData.downloadUrl.toString(), '_blank');
                setTimeout(() => {
                    windowDoc.close();
                }, 1000)
            }).catch(error => {
                this.showMessage('Error', 'Error downloading the document.', 'error', 'dismissable');
            }).finally(() => {
                this.showSpinner = false;
            });
    }

    handleDelFile(event){
        this.showDeleteModal = true;
        setTimeout(() => {
            this.focusFirstEle()
        }, 100);

        this.deletingFileId = event.target.dataset.docid;
        this.fileSectionName = event.target.dataset.sectionname;
    }

    handleCancel(){
        this.showDeleteModal = false;
    }

    handleFileDelete(event){
        this.showDeleteModal = false;
        this.showSpinner = true;
       
        let jsonData = {
            documentId: this.deletingFileId,
            sectionName : this.fileSectionName
        }
        
        const inputData = JSON.stringify(this.omniJsonData != undefined ? this.omniJsonData : this.omniJsonDataCustom);
        const params = {
            input: inputData,
            sClassName: 'LPI_DocumentUploadController',
            sMethodName: 'handleFileDelete',
            options: JSON.stringify(jsonData)
        };

        this._actionUtil
            .executeAction(params, null, this, null, null)
            .then(response => {
                if (!response) {
                    return;
                }
                this.showSpinner = false;
                this.showMessage('Success', 'Document has been successfully deleted.', 'success', 'dismissable');
                this.init();
                setTimeout(() => {
                    this.template.querySelector(`[data-docid="${this.documentIdForFileUpload}"]`)?.focus();
                }, 3000);
                this.showSpinner = false;
            })
            .catch(error => {
                this.showMessage('Error occured while Deletion ', error, 'error', 'pester');
                this.showSpinner = false;
            });
    }

    addNewDoc(event) {
        this.showSpinner = true;
        this.showAddDocUploadModal = true;

        const inputData = JSON.stringify(this.omniJsonData != undefined ? this.omniJsonData : this.omniJsonDataCustom);
      
        const params = {
            input: inputData,
            sClassName: 'LPI_DocumentUploadController',
            sMethodName: 'createAdditionalDocument',
            options: '{}'
        };

        this._actionUtil
            .executeAction(params, null, this, null, null)
            .then(response => {
                if (!response) {
                    return;
                }
                this.addDocId = response.result.newAppDocId;
                this.showSpinner = false;

                setTimeout(() => {
                    this.focusFirstEle();
                }, 500);
            })
            .catch(error => {
                this.showMessage('Error occured while adding new document ', error, 'error', 'pester');
                this.showSpinner = false;
            });
    }

    hideAddModalBox(){
        this.showAddDocUploadModal = false;
				 setTimeout(() => {
						 this.template.querySelector('.btnAddDocFocus')?.focus();
				 }, 1000);
    }

    focusFirstEle() {
        const focusableElements = 'lightning-combobox, lightning-button-icon, button, lightning-helptext, lightning-input, lightning-button,lightning-file-upload';
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
		
    handleEscCloseModal(event) {
		const ESC = 27;
		if (event.key === "Escape" || event.key === "Esc" || event.keyCode == ESC) {
			this.hideUploadModalBox();
		}
	}
    
    handleEscAddModal(event) {
		const ESC = 27;
		if (event.key === "Escape" || event.key === "Esc" || event.keyCode == ESC) {
			this.hideAddModalBox();
		}
	}

    handleESCcancel(event) {
		const ESC = 27;
		if (event.key === "Escape" || event.key === "Esc" || event.keyCode == ESC) {
			this.handlecancel();
		}
	}
}