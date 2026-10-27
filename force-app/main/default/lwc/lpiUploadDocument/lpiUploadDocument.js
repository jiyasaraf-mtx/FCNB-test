import {
    LightningElement,
    api,
    track,
    wire
} from 'lwc';
import {
    OmniscriptActionCommonUtil
} from "omnistudio/omniscriptActionUtils";
import {
    OmniscriptBaseMixin
} from 'omnistudio/omniscriptBaseMixin';
import {
    getNamespaceDotNotation
} from "omnistudio/omniscriptInternalUtils";
import {
    ShowToastEvent
} from 'lightning/platformShowToastEvent';
import {
    CurrentPageReference
} from 'lightning/navigation';
const RESIZING_FACTOR = 0.2;
const IMAGE_QUALITY = 0.7;
import Id from "@salesforce/user/Id";
import LPI_Onbase_App_Doc_Field_Mapping from '@salesforce/label/c.Onbase_App_Doc_Field_Mapping';
import LPI_DocumentFormats from '@salesforce/label/c.LPI_DocumentFormats';




export default class LpiUploadDocument extends OmniscriptBaseMixin(LightningElement) {


    @api recordId;
    @api objectApiName;
    @api isReview;
    @track reviewid;
    @api parentAttribute;
    @track appDocumentList = [];
    @track flowDocumentsList = [];
    @track lawfulPresenceDocumentsList = [];
    @track appConId;
    @track newAppDocId;
    @track addDocId;
    contentDocumentId;
    isOnbase;
    isChildDoc;
    @track callFromIntake = true;
    @track isfromAddDoc = false;
    @track intakeFileDelete = true;
    @track doNotDelete = false;
    @track isShowModal = false;
    @track newDocumentName;
    @track newDocumentDescription;
    @track fileData;
    @track intakeData;
    @track newContentDocumentId = new Array();
    @track newContentVersionId;
    @track fromhandleSave = true;
    @track showSpinner = false;
    @track omniJsonDataCustom = {
        parId: ''
    };
    @track isShowDeleteModal;
    @track isFromValid = false;
    @track isAppDocId;
    isdisplayed = true;
    fileScanSetTimoutValue = '';
    @track fileToUpload = {};
    additionalUploadDocTxt = 'Add additional relevant documents using the button to the right. Multiple documents related to the application may be uploaded.';
    twoByTwoWarning = 'Uploading a new document will automatically delete the previous document';
    twoByTwoPhotoRecommendation;
    isTwoByTwoPhoto;
    isOneByOnePhoto;
    otherDocument;
    @track documentsIdSet = [];
    docNamePoc;
    @track documentIdForFileUpload;
    documentName;
    activeElement;
    isShowUploadModal;
    isChildDoc;
    fromUploadButton = false;
    currentContentDocumentId;
    newfilename;
    header;
    userId = Id;
    appDocumentId;
    showRequiredText = false;

    @track documentNameSet = new Set([
        "Name Change Documentation",
        "Collaborative Practice Arrangement Form",
        "Collaborating Physician Certification of Controlled Substance Prescribing Authority Form",
        "2x2 Photo",
        "Postgraduate Reference Letter Form",
        "Copy of Diploma or Official Medical/Osteopathic School Transcripts",
        "Original/Official Translations",
        "Copy of International Medical License",
        "Birth Certificate/US Passport/Visa/Proof of Legal Resident Status",
        "Verification of Hospital Affiliation Form",
        "Verification of Licensure",
        "National Practitioner Data Bank Self-Query",
        "Birth Certificate",
        "Passport",
        "Certificate of Naturalization",
        "Visa (with/without Stamped Date of US Entry)",
        "US Permanent Resident Card",
        "I-94 (Arrival/Departure Record)",
        "I-20 (Certificate of Eligibility for Nonimmigrant (F-1) Student Status)",
        "I-797 form",
        "Proof of Name Change",
        "Malpractice Claim Form",
        "Certificate of State Board Registration",
        "Official Court Records/Documents",
        "Affidavit of assumption and Preneed list",
        "Personal Narrative about the incident",
        "Police Reports",
        "Certified Court Reports",
        "Probation/Parole Officer Reports",
        "All teaching materials",
        "Resume of education and professional work experience",
        "Quizzes/Examinations with answer keys",
        "Distance learning course (Access information)",
        "Driver's License",
        "test document"
      ]);

    // showPreneedAgentLicenseText = false; //Added for I-255376
    showInstructionsText = false; //Added for I-253182
    showMTSCondintionalText = false;
    @track examModificationDocName = [];
    @track requiredTypeSet = [];
    test;
    @track isfirstDoc = true;
    @track isfileUploaded = false;
    onbaseFieldLabel = LPI_Onbase_App_Doc_Field_Mapping;
    @track newFileAttachment;
    @track onbaseMetadata;
    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.reviewid = currentPageReference.state?.c__parid;
        }
    }
    //isAthleticsIdCard = false;
    _actionUtil;
    _ns = getNamespaceDotNotation();
    get isRevirwPage() {
        return this.isReview === undefined ? false : true;
    }

    connectedCallback() {
        this._actionUtil = new OmniscriptActionCommonUtil();
        setTimeout(() => {
            if (this.template.querySelector('.btnUploadFocus') != null) {
                this.template.querySelector('.btnUploadFocus').focus()
            };
        }, 1000);

        if (this.isRevirwPage === false) {
            this.init();
        } else {
            const optionsdata = {
                parId: this.reviewid
            };
            this.omniJsonDataCustom = optionsdata;
            this.init();
        }

    }
    init() {
        const inputData = this.isRevirwPage ? JSON.stringify(this.omniJsonDataCustom) : JSON.stringify(this.omniJsonData);
        const params = {
            input: inputData,
            sClassName: 'LPI_GetApplicationDocumentController',
            sMethodName: 'getApplicationDocumentList',
            options: '{}',
        };
    
        this._actionUtil
            .executeAction(params, null, this, null, null)
            .then(response => {
                if (!response || !response.result) {
                    return;
                }
                const info = response.result.applicationDocumentInfo;
                this.showRequiredText = info?.issuingDepartment !== 'Healing Arts';
                this.showInstructionsText = info?.regulatoryAuthorizationType === 'true';
                this.showMTSCondintionalText = info?.Type__c === 'Apply Certificate of Medication';
                
                if (info?.twoByTwoPhotoRecommendation) {
                    try {
                        this.twoByTwoPhotoRecommendation = typeof info.twoByTwoPhotoRecommendation === 'string' 
                            ? JSON.parse(info.twoByTwoPhotoRecommendation) 
                            : info.twoByTwoPhotoRecommendation;
                        this.header = this.twoByTwoPhotoRecommendation?.with2x2header || '';
                    } catch(e) {
                        this.header = '';
                    }
                }
    
                this.appDocumentList = info?.documents ? JSON.parse(info.documents) : [];
                if (this.appDocumentList) {
                    this.appDocumentList = this.appDocumentList.map(document => {
                        let isCetificateNoTaxDoc = document.documentRecord?.Document_Name__c === 'Certificate of No Tax Due (If applicable; Available on Missouri Dept. of Revenue\'s website)';
                        return {
                            ...document,
                            isCetificateNoTaxDoc
                        };
                    });
                }
                this.handleAppDocumentList(this.appDocumentList, response);
            })
            .catch(error => {
                console.error('Error in init:', error);
                this.showMessage('Error occurred while Loading.', error?.message || error, 'error', 'pester');
            });
    }

    handleAppDocumentList(appDocumentList, response) {
        try {
            console.log('appDocumentList :>> ', JSON.stringify(appDocumentList));
            let examModificationDocName = [
                'Letter from the applicant requesting the modifications detailing the specific modifications and explaining the rationale for the modifications',
                'Letter from the candidate’s nursing education program indicating what modifications',
                'Documentation supporting the request for accommodation from a qualified professional with expertise in the areas of the diagnosed disability.'
            ];
            let requiredTypeSet = ['Renewal', 'Amendment', 'Inactivation', 'Reactivation', 'Reinstatement'];
            if (appDocumentList !== null && appDocumentList !== undefined) {
                this.documentsIdSet = [];
                appDocumentList.forEach(document => {
                    // document.docNamePoc = this.userId == '0053R000002SRa6QAG' && document.documentRecord.Document_Name__c == 'Passport';
                    let documentType = document.documentRecord.Is_Document_Required__c ? 'Required Document' : 'Optional Document';
                    document.documentRecord.uploadBtnLabel = 'Upload document for ' + document.documentRecord.Document_Name__c + ' ' + documentType;
                    if (document.documentRecord.ContentDocumentLinks && document.documentRecord.ContentDocumentLinks.records) {
                        document.documentRecord.ContentDocumentLinks.records.forEach(cv => {
                            cv.deleteAriaLabel = 'Delete ' + cv.ContentDocument.Title;
                            cv.downloadAriaLabel = 'Download ' + cv.ContentDocument.Title + ' Uploaded for ' + document.documentRecord.Document_Name__c + ' ' + documentType;
                            this.documentsIdSet.push(document.documentRecord.Id);
                        })
                        if (document.documentRecord.Document_Name__c && document.documentRecord.Document_Name__c == this.twoByTwoPhotoRecommendation.docName) {
                            this.isfirstDoc = false;
                        }
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
                    if (examModificationDocName.includes(document.documentRecord.Document_Name__c)) {
                        document.documentRecord.isExamModification = true;
                    } else if (requiredTypeSet.includes(document.documentRecord.Type__c)) {
                        //document.documentRecord.isRequiredType = true;
                        if (
                            response && response?.result?.applicationDocumentInfo?.issuingDepartment === 'Architects, Engineers, Land Surveryors, and Landscape Architects' &&
                            document.documentRecord.Type__c === 'Reinstatement'
                        ) {
                            document.documentRecord.isAPEPLSPLAReinstatement = true;
                            this.APEPLSPLAReinstatementLabel = response?.result?.applicationDocumentInfo?.authorisationType === 'Business' ? 'Re-authorization' : 'Re-licensure';
                        } else {

                            document.documentRecord.isRequiredType = true;
                        }
                    }
                    let rfaType = ['Funeral Director Apprentice', 'Embalmer Apprentice', 'Preneed Agent', 'Preneed Agent Funeral Director'];
                    if (rfaType.includes(document.documentRecord.Preliminary_Application_Reference__r.Regulatory_Authorization_Type__r.Name)) {
                        document.documentRecord.isRegType = true;
                    } else {
                        document.documentRecord.isRegType = false;
                    }
                })
                console.log('appDocumentList>'+JSON.stringify(appDocumentList));
                this.showSpinner = false;
            }
            this.splitAppDocumentList();
        } catch (error) { }

    }


    handleDownload(event) {
        this.showSpinner = true;
        this.showMessage('Info', 'Document will download shortly.', 'info', 'dismissable');


        let dataObj = {
            appDocId: event.target.dataset.parentrecid
        };
        let fromOnbase;

        let JSONData = this.isRevirwPage ? JSON.parse(JSON.stringify(this.omniJsonDataCustom)) : JSON.parse(JSON.stringify(this.omniJsonData));

        const params = {
            input: JSON.stringify(JSONData),
            sClassName: 'LPI_GetApplicationDocumentController',
            sMethodName: 'downloadFileFromSf',
            options: JSON.stringify(dataObj)
        }


        this._actionUtil
            .executeAction(params, null, this, null, null)
            .then((response) => {
                fromOnbase = response.result.outputData.fromOnbase;
                dataObj.contentDocId = response.result.outputData.contentDocId;

                let windowDoc = window.open(response.result.outputData.downloadUrl.toString(), '_blank');
                setTimeout(() => {
                    windowDoc.close();
                }, 2000)


            }).then(() => {
                if (fromOnbase) {
                    setTimeout(() => {
                        let wrapperObjForDelete = {

                            contentDocumentId: dataObj.contentDocId,
                            appDocId: dataObj.appDocId
                        }
                        const params = {
                            input: JSON.stringify(JSONData),
                            sClassName: 'LPI_GetApplicationDocumentController',
                            sMethodName: 'handleContentDocumentDelete',
                            options: JSON.stringify(wrapperObjForDelete),
                        };
                        this._actionUtil
                            .executeAction(params, null, this, null, null)
                            .then().catch(error => {
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
    get acceptedFormats() {
        return LPI_DocumentFormats.split(",");
    } 

    //acceptedFormats = ['.pdf', '.png', '.doc', '.docx', '.ppt', '.pptx', '.pdf', '.jpeg', '.jpg', '.png', '.heic', '.webp', '.bmp']


    handleUploadFinished() {
        this.showSpinner = true;
        this.isShowUploadModal = false;
        const optionsdata = {
            record: this.documentIdForFileUpload
        };
        const params = {
            input: JSON.stringify(this.omniJsonData),
            sClassName: 'LPI_GetApplicationDocumentController',
            sMethodName: 'updateStatus',
            options: JSON.stringify(optionsdata),
        };


        this._actionUtil
            .executeAction(params, null, this, null, null)
            .then(response => {
                if (!response) {
                    return;
                }
                this.appDocumentList = response.result && response.result.applicationDocumentInfo && response.result.applicationDocumentInfo.documents ? JSON.parse(response.result.applicationDocumentInfo.documents) : null;
                this.splitAppDocumentList();
                this.showSpinner = false;
                this.showMessage('Success', 'Document has been successfully uploaded.', 'success', 'dismissable');
                setTimeout(() => {
                    this.template.querySelector(`[data-docid="${this.documentIdForFileUpload}"]`)?.focus();
                }, 3000);
            })
            .catch(error => {
                this.showMessage('Error occured while Loading. ', error, 'error', 'pester');
                this.showSpinner = false;
            });
        this.showSpinner = false;
    }


    showMessage(title, message, variant, mode) {
        const toastEvt = new ShowToastEvent({
            title,
            message,
            variant,
            mode
        });
        setTimeout(() => {
            this.focusFirstEle()
        }, 100);
        this.dispatchEvent(toastEvt);
    }

    parentrecid;
    handleDelFile(event) {
        this.isShowDeleteModal = true;
        setTimeout(() => {
            this.focusFirstEle()
        }, 100);
        if (event.target.dataset.flow == "parent") {
            this.parentrecid = event.target.dataset.recid;
        }
        if (event.target.dataset.flow == "child") {
            this.parentrecid = event.target.dataset.parentrecid;
        }


    }
    handlecancel(event) {
        this.isShowDeleteModal = false;

    }
    handleFileDelete(event) {
        this.isShowDeleteModal = false;
        this.showSpinner = true;

        let wrapperObj = {
            jsonData: {
                appDocumentId: this.parentrecid,
                intakeFileDelete: this.intakeFileDelete,
                doNotDelete: this.isfromAddDoc ? true : false
            }
        }
        const params = {
            input: JSON.stringify(this.omniJsonData),
            sClassName: 'LPI_GetApplicationDocumentController',
            sMethodName: 'handleFileDelete',
            options: JSON.stringify(wrapperObj)
        };

        this._actionUtil
            .executeAction(params, null, this, null, null)
            .then(response => {
                if (!response) {
                    return;
                }

                if (this.fromAddDoc) {
                    this.currentContentDocumentId = '';
                }
                this.appDocumentList = response.result && response.result.outputData && response.result.outputData.documents ? JSON.parse(response.result.outputData.documents) : null;
                this.handleAppDocumentList(this.appDocumentList, null);
                this.showSpinner = false;
                this.showMessage('Success', 'Document has been successfully deleted.', 'success', 'dismissable');
                // this.splitAppDocumentList();
                setTimeout(() => {
                    this.template.querySelector(`[data-docid="${this.documentIdForFileUpload}"]`)?.focus();
                }, 3000);
                this.showSpinner = false;
                this.isfirstDoc = true;
                this.isfileUploaded = false;
                this.doNotDelete = false;
                this.isfromAddDoc = false;

            })
            .catch(error => {
                this.showMessage('Error occured while Deletion ', error, 'error', 'pester');
                this.showSpinner = false;
            });

    }

    addOtherDocuments() {
        this.isShowModal = true;
        setTimeout(() => {
            this.focusFirstEle()
        }, 100);
    }


    hideModalBox() {
        this.newFileAttachment = null;
        this.newDocumentDescription = '';
        this.newDocumentName = '';
        this.fromAddDoc = false;
        this.isShowModal = false;
        let wrapperObj = {

            recordId: this.addDocId,

        }

        const params = {
            input: JSON.stringify(this.omniJsonData),
            sClassName: 'LPI_GetApplicationDocumentController',
            sMethodName: 'handleCancel',
            options: JSON.stringify(wrapperObj)
        }


        this._actionUtil
            .executeAction(params, null, this, null, null)
            .then(response => {
                if (!response) {
                    return;
                }
                this.showSpinner = false;
                this.isShowUploadModal = false;
                this.isfileUploaded = false;
                this.newDocumentName = '';
                this.newDocumentDescription = '';
                this.contentDocumentId = '';

            })

            .catch(error => { });

        setTimeout(() => {
            this.template.querySelector('.btnAddDocFocus').focus();
        }, 1000);
    }


    handleNewDocumentNameChange(event) {
        this.newDocumentName = event.detail.value;
        this.isFromValid = !(this.isValid());
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


    originalImage;
    selectedImgType = 'image/jpeg';
    async uploadFileDoc(event) {
        if (!this.twoByTwoPhotoRecommendation) {
            return;
        }
        this.linkedEntityId = event.target.dataset.recordid;


        let file = event.target.files[0];

        if (!this.twoByTwoPhotoRecommendation.fileTypes.includes(file.type)) {
            this.showMessage('Error', 'Image of incorrect type.', 'error', 'pester');
            return;
        }
        if ((file.size / (1024 * 1024)).toFixed(2) > this.twoByTwoPhotoRecommendation.maxFileSize) {
            this.showMessage('Error', `File size should not exceed ${this.twoByTwoPhotoRecommendation.maxFileSize} MB.`, 'error', 'pester');
            return;
        }


        const imgToCompress = file;
        if (imgToCompress.size / 1e6 > 1) {
            this.originalImage = new Image();
            this.originalImage.name = imgToCompress.name;
            this.selectedImgType = imgToCompress.type;
            this.originalImage.onload = this.compressImageAndSave.bind(this);
            this.originalImage.src = await this.fileToDataUri(imgToCompress);
        } else {
            this.originalImage = new Image();
            this.originalImage.name = imgToCompress.name;
            this.selectedImgType = imgToCompress.type;
            const base64String = await this.fileToDataUri(imgToCompress);
            const base64StringAfterComma = base64String.replace(/^data:image\/(png|jpeg);base64,/, "");
            this.saveImage(base64StringAfterComma);
        }
        this.isfirstDoc = false;
        this.handleUploadFinished();
    }


    compressImageAndSave() {
        const canvas = document.createElement("canvas");
        const context = canvas.getContext("2d");
        const originalWidth = this.originalImage.width;
        const originalHeight = this.originalImage.height;
        const canvasWidth = originalWidth * RESIZING_FACTOR;
        const canvasHeight = originalHeight * RESIZING_FACTOR;
        canvas.width = canvasWidth;
        canvas.height = canvasHeight;
        context.drawImage(this.originalImage,
            0, 0,
            canvasWidth,
            canvasHeight
        );
        const base64String = canvas.toDataURL(this.selectedImgType, IMAGE_QUALITY).replace(/^data:image\/(png|jpeg);base64,/, "");
        this.saveImage(base64String);
    }


    saveImage(base64String) {
        this.showSpinner = true;
        this.fileToUpload = {
            'fileName': this.originalImage.name,
            'base64': base64String,
            'fileType': this.selectedImgType,
            'linkedEntityId': this.linkedEntityId
        }
        const optionsData = {
            fileData: JSON.stringify(this.fileToUpload)
        };
        const params = {
            input: JSON.stringify(this.omniJsonData),
            sClassName: 'LPI_GetApplicationDocumentController',
            sMethodName: 'handleUploadFileSalesforce',
            options: JSON.stringify(optionsData),
        };
        this._actionUtil
            .executeAction(params, null, this, null, null)
            .then(response => {
                this.isShowUploadModal = false;
                this.showMessage('Success', 'Document has been successfully uploaded.', 'success', 'dismissable');
                if (!response) {
                    return;
                }
                this.appDocumentList = response.result && response.result.outputData.documents ? JSON.parse(response.result.outputData.documents) : null;
                this.splitAppDocumentList();
            }).catch(error => {
                this.showMessage('Error occured while Loading. ', error, 'error', 'pester');
            }).finally(() => {
                this.showSpinner = false;
            })
    }


    fileToDataUri(field) {
        return new Promise((resolve) => {
            const reader = new FileReader();
            reader.addEventListener("load", () => {
                resolve(reader.result);
            });
            reader.readAsDataURL(field);
        });
    }

    isValid() {
        let isAllValid = [...this.template.querySelectorAll("lightning-input"),
        ...this.template.querySelectorAll("lightning-combobox"),
        ...this.template.querySelectorAll("lightning-radio-group"),
        ...this.template.querySelectorAll("lightning-input-rich-text"),
        ...this.template.querySelectorAll("lightning-textarea"),
        ...this.template.querySelectorAll("lightning-dual-listbox")
        ].reduce((validSoFar, input) => {
            input.reportValidity();
            if (input.checkValidity() == false) {
                input.focus();
            }
            return validSoFar && input.checkValidity();
        }, true);
        return isAllValid;
    }


    handleSaveNewDocument(event) {

        if (this.newDocumentName === undefined || this.newDocumentName === '') {
            this.isValid();
            this.showMessage('Error ', 'Please Specify Document Name', 'error', 'pester');
            return;
        }

        if (!this.contentDocumentId || !this.currentContentDocumentId) {
            this.showMessage('Error ', 'Please Upload the file', 'error', 'pester');
            this.setFocusOnUploadFileButton();
            return;
        }

        this.handleSaveFile(this.addDocId, this.newDocumentName, this.newDocumentDescription);
        this.showSpinner = true;
        this.isShowModal = false;
        this.isShowUploadModal = false;
        this.isfileUploaded = false;
    }
    setFocusOnUploadFileButton() {
        const setUploadBtnFocus = this.template.querySelector('.setUploadBtnFocus');
        if (setUploadBtnFocus) {
            setUploadBtnFocus.setAttribute('tabindex', '0');
            setUploadBtnFocus.focus();
        }
    }
    handleSaveFile(addDocId, newDocumentName, newDocumentDescription) {
        let wrapperObj = {
            jsonData: {
                contentDocumentId: this.contentDocumentId,
                recordId: this.recordId,
                appDocumentId: addDocId,
                newDocumentName: newDocumentName,
                newDocumentDescription: newDocumentDescription,
                fromhandleSave: this.fromhandleSave

            }
        }
        const params = {
            input: JSON.stringify(this.omniJsonData),
            sClassName: 'LPI_GetApplicationDocumentController',
            sMethodName: 'getFileScanResult',
            options: JSON.stringify(wrapperObj)
        };

        this._actionUtil
            .executeAction(params, null, this, null, null)
            .then(response => {
                if (!response) {

                    return;
                }
                this.showMessage('Success', 'Document has been successfully uploaded.', 'success', 'dismissable');
                this.showSpinner = false;
                this.isShowUploadModal = false;
                this.appDocumentList = response.result.outputData.documents ? JSON.parse(response.result.outputData.documents) : null;
                this.handleAppDocumentList(this.appDocumentList, null);
                this.newDocumentName = '';
                this.newDocumentDescription = '';
                this.contentDocumentId = '';
                this.fromAddDoc = false;
                this.isfromAddDoc = false;
                this.isfileUploaded = false;
                setTimeout(() => {
                    this.template.querySelector(`[data-docid="${this.addDocId}"]`)?.focus();
                }, 12000);


            })

            .catch(error => {
                showAsyncErrorMessage(this, error)
                this.showSpinner = false;
            });
    }

    handleKeyDown(event) {
        if (event.code === 'Enter') {
            this.handleDownload(event);

        }
    }

    doFileUpload(event) {
        this.isShowUploadModal = true;
        this.showSpinner = true;
        setTimeout(() => {
             this.focusFirstEle();
         }, 500);
        this.documentIdForFileUpload = event.currentTarget.dataset.docid;
        this.documentName = event.currentTarget.dataset.docname;
        //this.isTwoByTwoPhoto = (this.documentName === this.twoByTwoPhotoRecommendation.docName);
        this.isTwoByTwoPhoto = this.documentNameSet.has(this.documentName) ? true: false;
        this.isTwoByTwoPhoto =true;
        this.fromUploadButton = true;
        this.isOneByOnePhoto = (this.documentName === "Upload 1\" x 1\" jpeg photo");
        this.otherDocument = this.isOneByOnePhoto === this.isTwoByTwoPhoto;

        let appDocumentId = event.currentTarget.dataset.docid;
        this.isChildDoc = this.documentsIdSet.includes(appDocumentId);
        if (this.isChildDoc == true && !this.isTwoByTwoPhoto) {
            this.handleUploadFile(appDocumentId);
        }
        if (!this.isChildDoc || this.isTwoByTwoPhoto) {
            this.isAppDocId = true;
            this.showSpinner = false;
        }

    }


    handleUploadFile(appDocumentId) {
        let optionsData = {
            appDocumentId: appDocumentId,
            fileName: '',
            createNewRec: this.documentsIdSet.includes(appDocumentId),
            onbaseDocId: '',
            parId: this.reviewid,
            fromUploadDocument: true
        }

        const params = {
            input: JSON.stringify(this.omniJsonData),
            sClassName: 'LPI_GetApplicationDocumentController',
            sMethodName: 'createApplicationDocument',
            options: JSON.stringify(optionsData),
        };

        this._actionUtil
            .executeAction(params, null, this, null, null)
            .then(response => {
                if (!response) {
                    return;
                }
                this.newAppDocId = response.result.newappDoc;
                if (!this.documentsIdSet.includes(this.newAppDocId)) {
                    this.documentsIdSet.push(this.newAppDocId);
                }
                this.isAppDocId = true;
                this.showSpinner = false;

                //this.appDocumentList = response.result && response.result.newappDoc.documents ? JSON.parse(response.result.newappDoc.documents) : null;
                // setTimeout(() => {
                //    this.template.querySelector(`[data-docid="${this.documentIdForFileUpload}"]`)?.focus();
                //   }, 3000);

            })

            .catch(error => { });
    }


    fromAddDoc = false;

    addNewDoc(event) {
        this.showSpinner = true;
        this.isShowModal = true;
        this.fromAddDoc = true;
        this.isfromAddDoc = true;
        let wrapperObj = {
            json: {
                docname: '',
                docdesc: '',
                fileName: '',
                fromUploadDocument: true

            }
        }
        const params = {
            input: JSON.stringify(this.omniJsonData),
            sClassName: 'LPI_GetApplicationDocumentController',
            sMethodName: 'addNewDocument',
            options: JSON.stringify(wrapperObj),
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
                // setTimeout(() => {
                //     this.template.querySelector(`[data-docid="${this.documentIdForFileUpload}"]`)?.focus();
                // }, 3000);

            })

            .catch(error => { });
    }

    handleUploadFinishedTest(event) {
        this.showMessage('Warning', 'Document has been Uploaded and it is currently being scanned,do not refresh the page,or click on any button.', 'warning', 'dismissable');
        this.showSpinner = true;
        this.displayModal = false;
        this.newfilename = event.detail.files[0].name;

        this.contentDocumentId = event.detail.files[0].documentId;
        if (this.fromAddDoc) {
            this.currentContentDocumentId = event.detail.files[0].documentId;
        }
        let wrapperObj = {
            jsonData: {
                contentDocumentId: event.detail.files[0].documentId,
                recordId: this.recordId,
                newDocumentName: '',
                appDocumentId: this.documentIdForFileUpload,
                callFromIntake: this.callFromIntake,
                fromhandleSave: !this.fromAddDoc,
            }
        }
        const params = {
            input: JSON.stringify(this.omniJsonData),
            sClassName: 'LPI_GetApplicationDocumentController',
            sMethodName: 'getFileScanResult',
            options: JSON.stringify(wrapperObj)
        };
        setTimeout(() => {
            this._actionUtil
                .executeAction(params, null, this, null, null)
                .then(response => {
                    if (!response) {
                        return;
                    }
                    // this.appDocumentList = response.result.outputData.documents ? JSON.parse(response.result.outputData.documents) : null;  
                    this.appDocumentList = response.result && response.result.outputData && response.result.outputData.documents ? JSON.parse(response.result.outputData.documents) : null;
                    if (!this.fromAddDoc) {
                        this.currentContentDocumentId = '';
                        this.handleAppDocumentList(this.appDocumentList, null);
                    }
                    this.showMessage('Success', 'Document has been successfully uploaded.', 'success', 'dismissable');
                    this.showSpinner = false;
                    this.isAppDocId = false;

                    this.fileScanSetTimoutValue = response.result && response.result.outputData && response.result.outputData.fileScanTimeoutValue ? response.result.outputData.fileScanTimeoutValue : '17000';

                    if (this.fromAddDoc) {
                        this.isfileUploaded = true;
                    }
                    this.isShowUploadModal = false;
                    setTimeout(() => {
                        this.template.querySelector(`[data-docid="${this.documentIdForFileUpload}"]`)?.focus();
                    }, 3000);

                })

                .catch(error => {
                    showAsyncErrorMessage(this, error)
                    this.showSpinner = false;
                });
        }, this.fileScanSetTimoutValue);


    }


    handleCloseModal() {
        this.isShowUploadModal = false;
        this.init()
    }


    // Focus Leak Acessibiltiy Issue
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

    hideUploadModalBox() {
        this.isShowUploadModal = false;

        //this.fromUploadButton =false;
        let wrapperObj = {

            recordId: this.newAppDocId,

        }

        const params = {
            input: JSON.stringify(this.omniJsonData),
            sClassName: 'LPI_GetApplicationDocumentController',
            sMethodName: 'handleCancel',
            options: JSON.stringify(wrapperObj)
        }
        this._actionUtil
            .executeAction(params, null, this, null, null)
            .then(response => {
                if (!response) {
                    return;
                }
                this.newDocumentName = '';
                this.newDocumentDescription = '';
                this.contentDocumentId = '';

                this.showSpinner = false;
                this.isfileUploaded = false;
            })

            .catch(error => { });
    }

    //Added By GJ -- End here
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
    splitAppDocumentList() {
        let tempLawfulPresenceDocumentsList = [];
        let tempFlowDocumentList = [];
        if (this.appDocumentList !== null && this.appDocumentList !== undefined) {
            this.appDocumentList.forEach(document => {
                if (document.documentRecord.Is_Lawful_Presence_Document__c) {
                    tempLawfulPresenceDocumentsList = [...tempLawfulPresenceDocumentsList, document];
                } else {
                    tempFlowDocumentList = [...tempFlowDocumentList, document];
                }
            })
        }
        this.lawfulPresenceDocumentsList = tempLawfulPresenceDocumentsList;
        this.flowDocumentsList = tempFlowDocumentList;
        // let  dloadAriaLabel = 'Download ' + this.flowDocumentsList[0].documentRecord.File_Name__c +' Uploaded for '+ this.flowDocumentsList[0].documentRecord.Document_Name__c;
        // let  delAriaLabel = 'Delete ' + this.flowDocumentsList[0].documentRecord.File_Name__c +' for '+this.flowDocumentsList[0].documentRecord.Document_Name__c;

        // this.flowDocumentsList[0].files.push({
        //     "dloadAriaLabel":dloadAriaLabel,
        //     "delAriaLabel":delAriaLabel
        // });
        // // this.flowDocumentsList[0].files.delAriaLabel =delAriaLabel;
        // let docType = this.flowDocumentsList[0].documentRecord.Type__c;  
        // let docName=  this.flowDocumentsList[0].documentRecord.Document_Name__c;    
        //  if((docType == "MMA National ID Card" && docName =='Upload 1\" x 1\" jpeg photo') ||(docType == "Boxer\'s Federal ID Card" && docName =='2x2 Photo')){
        //     this.isAthleticsIdCard =true;
        //     this.flowDocumentsList[0].documentRecord['isAthleticsIdCard'] = this.isAthleticsIdCard;   
        // }        
    }

    handleEscCloseModal(event) {
		const ESC = 27;
		if (event.key === "Escape" || event.key === "Esc" || event.keyCode == ESC) {
			this.closeModel();
		}
	}
    handleEscAddModal(event) {
		const ESC = 27;
		if (event.key === "Escape" || event.key === "Esc" || event.keyCode == ESC) {
			this.hideModalBox();
		}
	}
    handleESCcancel(event) {
		const ESC = 27;
		if (event.key === "Escape" || event.key === "Esc" || event.keyCode == ESC) {
			this.handlecancel();
		}
	}

    closeModel(){
        this.isShowUploadModal = false;
    }

}