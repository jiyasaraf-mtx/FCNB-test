import createAppDoc from '@salesforce/apex/LPI_ComplaintsController.createApplicationDocument';
import createDraftPublicComplaint from '@salesforce/apex/LPI_ComplaintsController.createDraftPublicComplaint';
import fileScanResult from '@salesforce/apex/LPI_ComplaintsController.fileScanResult';
import handleFileCancel from '@salesforce/apex/LPI_ComplaintsController.handleFileCancel';
import LPI_ComplaintDocumentName from '@salesforce/label/c.ComplaintDocumentName'; // 'COMPLAINT DOCUMENT'
import LPI_ComplaintsDocument from '@salesforce/label/c.ComplaintsDocument';
import fileScanSetTimoutValue from '@salesforce/label/c.Upload_File_Scan_Timeout_Value';
import {
    showAsyncErrorMessage,
    showMessage
} from 'c/lpiUtil';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { LightningElement, api, track } from 'lwc';
const ESC = 27;
export default class LpiComplaintsFileUpload extends LightningElement {

    @api isInternalUser = false;
    @api selectedBoardName;
    @api complaintDetails;
    @api isPortalUser = false;
    @track fileLimitExceeded = false;
    spinnerText = 'Please wait';
    showSpinner;
    fileLimitDescMsg = 'You can upload up to 5 attachments per Respondent. Uploaded files must have a limit of less than 5MB. Documents larger than 5MB will need to be submitted via email to the respective agency.';
    fileFormatDescMsg = `The online complaint form only accepts the following file types: `;

    _agreeToUploadFiles;
    draftPublicComplaintId;
    uniqueId;
    totalFileLimit = JSON.parse(LPI_ComplaintsDocument).maxFiles;
    acceptedFormats = JSON.parse(LPI_ComplaintsDocument).fileTypes;
    displayModal=false;
    modalContent;
    payLoad;
    response;
    newFileAttachment;
    twoByTwoPhotoRecommendation;
    selectedRespondentName;

    @track selectedRespondentVal = {};


    modalHeading = 'Are you sure you want to upload the below file? Please note the file cannot be deleted once you click on upload.'
    respondentToDraftComplaintIdMap = {};
    @track currentAppDocId = '';
    @track selectedDraftComplaintId = '';
    @track selectedRequestId = '';

    showFileUploadSection = false;

    get showUploadSection() {
        return !this.isInternalUser && this.respondentList?.length > 0;
    }

    @api 
    get maxFileLimitReached() {
        return this.fileLimitExceeded;
    }
    set maxFileLimitReached(value) {
        console.log('HELLO WE HAVE RECIEVED THE VALUE >> ' + value);
        this.fileLimitExceeded = !!value;
    }

    // get showUploadFileOption() {
    //     return this.showUploadSection;// && this.currentAppDocId!='';
    // }

    _licensedRespondentOptions = [];
    connectedCallback() {
        console.log('Accepted formats >> ' + JSON.stringify(this.acceptedFormats));
    }
    @api 
    set respondentList(value) {
        this._licensedRespondentOptions = [...value] || [];
    }
    get respondentList() {
        return this._licensedRespondentOptions;
    }

    @api
    set agreeToUploadFiles(value) {
        this._agreeToUploadFiles = value;
        this.template.querySelector('.wantToUploadDocs').checked = value;
    }
    get agreeToUploadFiles() {
        return this._agreeToUploadFiles;
    }

    @api 
    updateRespondentDraftComplaintMap(uniqueKey) {
        if(!this.respondentToDraftComplaintIdMap) return;

        let mpToSend = {};
        for(const objKey in this.respondentToDraftComplaintIdMap) {
           mpToSend[objKey] = this.respondentToDraftComplaintIdMap[objKey].complaintDetails?.split('-currentRequestId')[0]
        }

        if(this.respondentToDraftComplaintIdMap.hasOwnProperty(uniqueKey)) {
            delete this.respondentToDraftComplaintIdMap[uniqueKey];
        }
        if(mpToSend && mpToSend.hasOwnProperty(uniqueKey)) {
            // mpToSend[uniqueKey + '#$'] = mpToSend[uniqueKey]; // appending #$ means to track this appDoc this key needs to be marked as Delete from OnBase 
            delete mpToSend[uniqueKey];
        }
        this.selectedRespondentName = null;

        // below code shifts index by -1.  
        for(let e in mpToSend) {
            let r = Number(e);
            if(r > Number(uniqueKey)) {
                mpToSend[ (r - 1).toString().padStart(2, '0') ] = mpToSend[e];
                delete mpToSend[e];
            }
        }

        this.dispatchEvent(new CustomEvent('draftcomplaintcreate',{
            detail : {
               uniqueKeyToDraftCompMap : JSON.stringify(mpToSend)
            }
        }));
        
        // shift the indices. of the records whose unique is > than the passed value. 
        // as they will be affected. 
        for (const key in this.respondentToDraftComplaintIdMap) {
            let v = Number(key);
            if(v > Number(uniqueKey)) {
                this.respondentToDraftComplaintIdMap[ (v - 1).toString().padStart(2, '0') ] = this.respondentToDraftComplaintIdMap[key];
                delete this.respondentToDraftComplaintIdMap[key];
            }
        }
        this.respondentToDraftComplaintIdMap = {...this.respondentToDraftComplaintIdMap};
    }

    connectedCallback() {
        this.fileFormatDescMsg = this.fileFormatDescMsg + ' ' + this.acceptedFormats?.join(', ') + 
            ' If you have a file of a different format that you feel is pertinent to your complaint, please mention that in the Comments section.'
    }


    @track contactDetails = {};

    handleRespondentSelect(event) {
        
        if(event.currentTarget.name == 'licensedRespondent') {
            this.selectedRespondentName = event.target.options.find(opt => opt.value === event.detail.value).label;
             console.log('Test 1 >> ' + this.selectedRespondentName);
             console.log('JSON.parse >> ' + event.currentTarget.value );
            let objRec = JSON.parse(event.currentTarget.value);
             console.log('JSON.parse AFTER >> ' + JSON.stringify(objRec));
            this.contactDetails = {...objRec};

            if(!this.respondentToDraftComplaintIdMap.hasOwnProperty(objRec.uniqueKey)) {

                this.createDraftRecords(objRec);
            } else {
                // set the correct app doc Id. 
                this.currentAppDocId = this.respondentToDraftComplaintIdMap[objRec.uniqueKey]?.appDocId;
                this.selectedDraftComplaintId = this.respondentToDraftComplaintIdMap[objRec.uniqueKey].complaintDetails?.split('-currentRequestId')[0];
                this.selectedRequestId = this.respondentToDraftComplaintIdMap[objRec.uniqueKey].complaintDetails?.split('-currentRequestId')[1];

                this.dispatchEvent(new CustomEvent('validatefilecount',{
                    detail : {
                       draftCompId : this.selectedDraftComplaintId
                    }
                }))

                 // this._processOnbaseConfiguration(this.respondentToDraftComplaintIdMap[objRec.uniqueKey]?.onbaseConfiguration,true); // payload wont be updated again.
            }


        }

    }

    // ...contactDetails
    createDraftRecords({uniqueKey})  {

        this.showSpinner = true;
        this.spinnerText = 'Please wait';
        this.currentAppDocId = '';
        this.selectedDraftComplaintId = '';
        this.selectedRequestId = '';
        this.showFileUploadSection = false;
        // console.log('CONTACT DETAILS >> ' + JSON.stringify(contactDetails));
        createDraftPublicComplaint({
            // jsonData : JSON.stringify({
            //     ...contactDetails
            // })
        })
        .then(rec=>{
            this.showSpinner =false;
            // this._processOnbaseConfiguration(rec.onbaseConfiguration);

            this.respondentToDraftComplaintIdMap[uniqueKey] = rec; // caching results.
            this.showFileUploadSection = true;
            // this.currentAppDocId = rec.appDocId;
            this.selectedDraftComplaintId = rec.complaintDetails?.split('-currentRequestId')[0];
            this.selectedRequestId  = rec.complaintDetails?.split('-currentRequestId')[1];
            let mpToSend = {};
            for(const objKey in this.respondentToDraftComplaintIdMap) {
               mpToSend[objKey] = this.respondentToDraftComplaintIdMap[objKey].complaintDetails?.split('-currentRequestId')[0]
            }
            this.dispatchEvent(new CustomEvent('draftcomplaintcreate',{
                detail : {
                   uniqueKeyToDraftCompMap : JSON.stringify(mpToSend),
                }
            }));
            this.dispatchEvent(new CustomEvent('validatefilecount',{
                detail : {
                   draftCompId : this.selectedDraftComplaintId
                }
            }))
        })
        .catch(err=>{
            showAsyncErrorMessage(this,err);
            this.showSpinner = false;
        })

    }

    // _processOnbaseConfiguration(onbaseConfiguration,isPayLoadUpdated = false) {
    //     console.log('In Process On Base Config>>'+onbaseConfiguration);
    //     this.response = onbaseConfiguration;
    //     this.twoByTwoPhotoRecommendation = JSON.parse(onbaseConfiguration.twoByTwoPhotoRecommendation);
    //     this.payLoad = onbaseConfiguration.onbaseConfig && onbaseConfiguration.onbaseConfig.payload ? JSON.parse(onbaseConfiguration.onbaseConfig.payload) : null; 
    //     if (this.payLoad && this.payLoad.keywordCollection && this.payLoad.keywordCollection.items && !isPayLoadUpdated) { // if payload is not updated then update it. 
    //         this.payLoad.keywordCollection.items.forEach(item => {
    //             item.keywords.forEach(keyWord => {
    //                 keyWord.values.forEach(keyValue => {
    //                     keyValue.value = onbaseConfiguration[keyValue.value]
    //                 })
    //             })
    //         })
    //         this.payLoad.documentDate = onbaseConfiguration.documentDate
    //     }   
    //     console.log('Payload>>'+this.payload);
    // }

    openfileUpload(event) {
        if (!this.twoByTwoPhotoRecommendation.acceptedOtherFormats.includes(event.target.files[0].name.split('.').pop().toLowerCase())) {
            showMessage(this, {
                title: "Error",
                message: "Document/File format is not acceptable. Please upload a file of accepted type.",
                messageType: "error",
                mode: "dismissable"
            });
            return;
        }
        if ((event.target.files[0].size / (1024 * 1024)).toFixed(2) > this.twoByTwoPhotoRecommendation.maxFileSizeOther) {
            showMessage(this, {
                title: "Error",
                message: `File size should not exceed ${this.twoByTwoPhotoRecommendation.maxFileSizeOther} MB.`,
                messageType: "error",
                mode: "dismissable"
            });
            return;
        }
        this.newFileAttachment = new File([event.target.files[0]], event.target.files[0].name.split(".")[0]+'.'+event.target.files[0].name.split('.').pop().toLowerCase(), {type: event.target.files[0].type});;
        this.modalContent = this.newFileAttachment.name; // get the file name.
        this.displayModal = true;
    }

    openfileUploadNew(event) {
        const [ fileDetails] = event.detail.files;
        this.showSpinner = true;
        this.spinnerText = 'Document Upload in Progress';
        setTimeout(() => {
            fileScanResult({
                jsonData : JSON.stringify({
                    // Guest uploads return contentVersionId (not documentId)
                    contentDocumentId: fileDetails.documentId,
                    contentVersionId: fileDetails.contentVersionId,
                    recordId: this.selectedDraftComplaintId,
                    appDocumentId: this.currentAppDocId,
                    newDocumentName : fileDetails.name,
                    payLoad : JSON.stringify(this.payLoad),
                    requestId : this.selectedRequestId
                })
            })
            .then(result=> {
                this.showSpinner = false;
                // Sending this file to parent for displaying.
                this.displayModal = false;
                
                this.dispatchEvent(new ShowToastEvent({
                    title: "Success",
                    message: "Document Uploaded Successfully",
                    variant: "success"
                }));
                setTimeout(()=>{this.template.querySelector('.complaintFileFocus').focus();},1000);
                this.template.querySelector('.complaintFileFocus').focus();
                const fileExt = fileDetails.name?.slice(((fileDetails.name?.lastIndexOf(".") - 1) >>> 0) + 2); 
                this.dispatchEvent(new CustomEvent('fileupload',{
                    detail : {
                        uploadedFile : {
                            fileName : fileDetails.name,
                            fileType : '.' + fileExt,
                            fileStatus: 'Submitted',
                            submittedAgainst : this.selectedRespondentName,
                            appDocId : this.currentAppDocId,
                            requestId : this.selectedRequestId,
                            draftComplaintId : this.selectedDraftComplaintId // this property will be used to track the count of files uploaded against this draft complaint.
                        }
                    }
                }));
            })
            .catch(err=>{
                showAsyncErrorMessage(this,err);
                this.showSpinner = false;
            })
        }, fileScanSetTimoutValue);
    }


    appDocAndRequestId;

    handleShowUploadModal(event) {
        this.displayModal = true;
        this.showSpinner = true;
        this.spinnerText = 'Please wait';
        setTimeout(() => {
            this.focusFirstEle();
        }, 200);
        console.log('Hello>>');
       // console.log('Param 1>>'+JSON.parse(LPI_ComplaintDocumentName).complaintDoctName);
        console.log('Param 2>>'+this.selectedBoardName);
        console.log('Param 3>>'+JSON.stringify(this.payLoad));
        console.log('Param 4>>'+this.selectedDraftComplaintId);

        // call create AppDoc. 
        createAppDoc({
            jsonData : JSON.stringify({
                fileName: 'DRAFT APPLICATION DOC RECORD',
                documentName:'Complaint Document', //JSON.parse(LPI_ComplaintDocumentName).complaintDoctName,
                boardName: this.selectedBoardName,
                lookupFieldName: 'Public_Complaint__c',
                onbasePayload : JSON.stringify(this.payLoad),
                lookupFieldId: this.selectedDraftComplaintId
            }), 
            responseWrapperJsonData : JSON.stringify(this.contactDetails || {})
        })
        .then(res=> {
            this.currentAppDocId = res.appDocId;
            // Guest_Record_fileupload__c must be a valid record Id for linking automation/Apex resolution
            this.appDocAndRequestId = res.appDocId;
            console.log('CURRENT APP DOC ID FOR GUEST UPLOAD >> ' + this.appDocAndRequestId);
            this.showSpinner = false;
        })
        .catch(err=>{
            showAsyncErrorMessage(this,err);
            this.showSpinner = false;
        })

    }
    escCloseModal(event) {
        if (event.keyCode === ESC) {
            this.handleClose();
        }
    }
    handleClose() {
        this.newFileAttachment = null;
        this.displayModal = false;

          // this.template.querySelector('c-modpr-complaints-file-upload').agreeToUploadFiles = true;
          this.showSpinner = true;
          this.spinnerText = 'Please wait';
          handleFileCancel({
              jsonData : JSON.stringify({
                requestId : this.selectedRequestId,
                appDocId : this.currentAppDocId
            })
        })
          .then(rec=> {
              this.showSpinner = false;
          })
          .catch(err=>{
              showAsyncErrorMessage(this,err);
              this.showSpinner = false;
          })   
    }

    /* Modal Focus Function */
    focusFirstEle() {
        const focusableElements = 'lightning-combobox, lightning-button-icon, button, input, lightning-textarea, lightning-helptext, lightning-input, lightning-button';
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

}