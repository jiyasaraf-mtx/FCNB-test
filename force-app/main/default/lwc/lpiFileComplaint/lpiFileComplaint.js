/**
 * @                  : 
 * @author            : Abel David Solomon
 * @group             : 
 * @last modified on  : 07-25-2024
 * @last modified by  : Ayush Dev
**/
import USER_ID from '@salesforce/user/Id';
import isGuest from '@salesforce/user/isGuest';
import {
    addYears,
    checkLength,
    formatPhoneNumber,
    getMergedAddress,
    showAsyncErrorMessage,
    showMessage
} from 'c/lpiUtil';
import {
    NavigationMixin
} from 'lightning/navigation';
import {
    getObjectInfo,
    getPicklistValues
} from 'lightning/uiObjectInfoApi';
import {
    LightningElement,
    track,
    wire
} from 'lwc';
import {CurrentPageReference} from 'lightning/navigation';

import CONTACT_OBJECT from '@salesforce/schema/Account';
import ADDRESS_OBJECT from '@salesforce/schema/Address';
import COUNTRY_CODE_FIELD from '@salesforce/schema/Address.CountryCode';

import createPublicComplaint from '@salesforce/apex/LPI_ComplaintsController.createComplaintPerRespondent';
import getCurrentUserDetails from '@salesforce/apex/LPI_ComplaintsController.getCurrentUserDetails';
import handleDeleteFile from '@salesforce/apex/LPI_ComplaintsController.handleDeleteFile';
import BoardSpecificQuestionsApplicableBoards from '@salesforce/label/c.BoardSpecificQuestionsApplicableBoard';
import HIPAASectionApplicableBoards from '@salesforce/label/c.HIPAASectionApplicableBoards';
import My_Resource from '@salesforce/resourceUrl/LPI_Design';
import ContactState from '@salesforce/schema/Account.PersonOtherStateCode';
import getCurrentLanguage from '@salesforce/apex/EMP_LanguageCtrl.getCurrentLanguage';
import getLabels from '@salesforce/apex/EMP_LanguageCtrl.getLabels';
import {
    LABEL_API_NAMES,
    mapApiToCamel,
    readStoredLanguage,
    writeStoredLanguage
} from 'c/lpLanguageUtils';

import  CF_Header from '@salesforce/label/c.CF_Header';

import {
    loadStyle
} from "lightning/platformResourceLoader";

export default class LpiFileComplaint extends NavigationMixin(LightningElement) {
    @wire(CurrentPageReference)
    currentPageReference;
    SuccessImg = My_Resource + '/media/icons/succes-page.svg';
    userId = USER_ID;
    announceMsg;

   @track labels={
        complaintFormHeader:'File a Consumer Complaint',
        complaintInstructions1:'If you have concerns about the conduct of a person or company with whom you’ve had a transaction or experience, you can submit a formal complaint here. But first, you may want to try addressing the issue with the individual or the company representative directly—this is often all it takes to solve the situation.',
        complaintInstructions2:'If you’re not satisfied with the response received from this conversation, follow the organization’s formal internal complaint process. Formal complaints must usually be made in writing.',
        complaintInstructionsRemember:'When filing a formal complaint, remember to:',
        complaintInstructionsBullet1:'state the facts, why you think there is a problem and what you would like to happen',
        complaintInstructionsBullet2:'provide copies of all the available documentation such as brochures, account statements and copies of contracts and medical information, if appropriate. Keep the originals.',
        complaintInstructionsBullet3:'keep a record of whom you talked to and what was said.',
        complaintInstructionsBullet4:'ask for a final position letter that clearly states your insurer’s final decision regarding your complaint.',
        complaintAsterisk:'Asterisk',
        complaintAsteriskRequiredField:'indicates required field',
        complaintSubjects:'Subject(s) of your Complaint',
        complaintIncidentDetails:'Incident Details',
        complaintStartDate:'Start Date',
        complaintEndDate:'End Date',
        complaintIncidentWhen:'When did this Incident happen?',
        complaintIncidentWhere:'Where did this Incident happen?',
        complaintStreetAddress:'Street Address',
        complaintEnterStreetAddress:'Enter Street Address',
        complaintCityTown:'City / Town',
        complaintEnterCityTown:'Enter City or Town',
        complaintProvinceTerritory:'Province / Territory',
        complaintSelectProvince:'Select Province',
        complaintPostalCode:'Postal Code',
        complaintComplaintDetails:'Complaint Details',
        complaintFullDetailsInstructions:'Please provide the full details of your complaint. Note that this field has a limit of 65,000 characters. If your complaint details exceed this limit, provide a brief summary here and upload your complete documentation in the Document Uploads section below',
        complaintDescription:'Description',
        complaintEnterFullDetails:'Enter full details of your complaint...',
        complaintSubjectOfComplaint:'Subject(s) of your Complaint',
        complaintWitnessInformation:'Witness Information',
        complaintLegalRepresentation:'Legal Representation',
        complaintLegalCounselContacted:'Have you retained or contacted legal counsel regarding this matter?',
        complaintLegalActionInitiated:'Has legal action or court proceeding been initiated?',
        complaintOtherRegulatoryBodiesAgencies:'Other Regulatory Bodies & Agencies',
        complaintOtherReportingBodies:'Has this matter been reported to any other government department, regulatory agency, law enforcement, or dispute resolution body? If yes, specify the organization(s).',
        complaintAdditionalQuestions:'Additional Questions',
        complaintContactedBusinessDirectly:'Have you contacted the business, licensee, or individual directly regarding your dispute?',
        complaintRelationshipWithSubject:'Do you have a personal, employment, or business relationship with the subject of the complaint?',
        complaintWillingToTestify:'Should a formal hearing or proceeding be required, are you willing to testify under oath?',
        complaintDeclarationAttestation:'Declaration & Attestation',
        complaintDateFiled:'Date Filed',
        complaintCancel:'Cancel',
        complaintSaveAsDraft:'Save as Draft',
        complaintSubmitComplaint:'Submit Complaint',
        complaintDirectContactDates:'If yes, please provide the date(s) related to your direct contact.',
        complaintIfSoExplain:'If so, please explain',
        complaintEnterExplanation:'Enter Explanation',
        complaintSpecifyDatesTimeframe:'Specify date(s) or timeframe',
        complaintCourtFileDocketNumber:'Court File / Docket Number',
        complaintEnterFileNumber:'Enter File Number',
        complaintCourtJurisdictionJudicialDistrict:'Court Jurisdiction / Judicial District',
        complaintCourtJurisdictionExample:"e.g., Court of King's Bench of NB",
        complaintDateFormat:'YYYY-MM-DD',
        complaintAddEditWitness:'Add / Edit Witness',
        complaintFirstName:'First Name',
        complaintEnterFirstName:'Enter First Name',
        complaintMiddleName:'Middle Name',
        complaintEnterMiddleName:'Enter Middle Name',
        complaintLastName:'Last Name',
        complaintEnterLastName:'Enter Last Name',
        complaintTelephoneNumber:'Telephone Number',
        complaintEnterTelephoneNumber:'Enter Telephone Number',
        complaintCellPhoneNumber:'Cell Phone Number',
        complaintEnterCellPhoneNumber:'Enter Cell Phone Number',
        complaintEmailAddress:'Email Address',
        complaintEnterEmailAddress:'Enter Email Address',
        complaintStreetAddress:'Street Address',
        complaintEnterStreetAddress:'Enter Street Address',
        complaintCityTown:'City / Town',
        complaintEnterCityTown:'Enter City or Town',
        complaintAddWitness:'Add Witness',
        complaintActionNotAllowed:'You are not Allowed to Perform this Action. Please Contact your System Administrator.',
        complaintSeeMore:'See More',
        complaintSeeLess:'See Less',
        complaintDeclarationAttestationStatement:'We collect your personal information, including name, contact information, and address for the purpose of responding to your complaint. For more information about how your information is used, stored, and protected please refer to our Privacy Policy.',


    }

    yesNoOptions = [{
        'label': 'Yes',
        'value': 'Yes'
    }, {
        'label': 'No',
        'value': 'No'
    }];

    coverageOptions = [{
        'label': 'Covering all past, present, and future periods of health care',
        'value': 'Covering all past, present, and future periods of health care'
    }, {
        'label': 'Covering the period of health care from',
        'value': 'Covering the period of health care from'
    }];

    

    @track dataObj = {
        'complainantAddressData': {},
        'patientInfo' : {
            'complainantAddressData' : {}
        },
        'boardSpecficQues': {},
        'profession' : ''
    };
    @track respondentListToDisplay = [];
   
    patternObj = {
        text: '^((?!(<)|(>)).)*$',
        digits: '^(\\([0-9]{3}\\) |[0-9]{3}-)[0-9]{3}-[0-9]{4}$',
        email: '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,10}$',
        zipCode: '^[A-Za-z]\\d[A-Za-z][ -]?\\d[A-Za-z]\\d$',
        ssn: '^(?!.*(<|>))[0-9]*$'
    }
    @track boxClass = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click';
    @track respondentData = [];
    @track witnessData = [];
    // added 
    @track incidentRecList = [];
    @track entityList = [];

    @track attorneyInfo = {
        'addressData': {}
    }

    @track filesList=[];
    @track initCall = true;
    @track selectedBusinessIds = [];
    @track selectedRespondentData = {
        'addressData': {}
    };
    // One Employer Per Respondent
    @track employerInfo = {
        'employerAddress': {}
    }
    @track selectedWitnessData = {};
    @track deleteObject = {};
    @track removeProfessionAriaLabel = '';
    BSQApplicableBoardsList = BoardSpecificQuestionsApplicableBoards?.split('@')
    HIPAASectionApplicableBoardsList = HIPAASectionApplicableBoards?.split('@')
    isLicensed = true;
    complaintName;
    recaptchaDivStyle;
    v2RenderCalled;
    showSpinner;
    recaptchaDiv;
    stateOptions;
    submitDisabled;
    maxDateValue;
    defaultAuthExpiryDate;
    isModalOpen;
    openConfirmationModal;
    selectedIndex;
    modalHeading;
    modalHeader;
    isWitnessModalOpen;
    isInternalUser = false;
    isSupportStaff = false;
    countryOptions = [];
    draftPublicComplaintId;
    selectedEntityLocInfo ={};
    uniqueId;
    spinnerText;
    portalUser;
    @track errorMessageSR;
    @track errMsg = false;
    // get recaptchaDivTabIndex() {
    //     return this.v2RenderCalled ? 0 : -1;
    // }
    ShowMoreText = false;
    ShowLessText = true;

    get showIndividualComplaintDate() {
        return this.dataObj && this.dataObj.contactedIndividualAboutComplaint === 'Yes';
    }
    get showAddEntitySection() {
        return this.dataObj && this.dataObj.complaintReported === 'Yes';
    }
    get showExplainationForSocOrProfRelation() {
        return this.dataObj && this.dataObj.socialOrProfessionalRelation === 'Yes';
    }
    get disableIncidentButton() {
        return this.incidentRecList && this.incidentRecList.length == 1;
    }

    get dispalyFileTable() {
        return this.filesList && this.filesList.length > 0;
    }
    get dispalyRespondentTable() {
        return this.respondentListToDisplay && this.respondentListToDisplay.length>0;
    }
    get displayWitnessTable() {
        return this.witnessData && this.witnessData.length > 0;
    }
    get displayAttorneyTable() {
        return this.attorneyInfoList && this.attorneyInfoList.length > 0;
    }
    get displayEntityTable() {
        return this.entityList && this.entityList.length > 0 && this.showAddEntitySection;
    }
    get displayIncidentTable() {
        return this.incidentRecList && this.incidentRecList.length > 0;
    }
    get displayCoverageDates() {
        return this.dataObj && this.dataObj.coverageOption === 'Covering the period of health care from';
    }
    get isFieldReadOnly() {
        return (this.userId && !this.isInternalUser) || false;
    }
    get hasALawyer() {
        return this.dataObj && this.dataObj.contactedAttorney === 'Yes';
    }
    get showFileUploadSection() {
        return this.dataObj.agreeToUploadFiles && this.draftPublicComplaintId;
    }
    get disableFileUpload() {
        return this.filesList && this.filesList.length===this.totalFileLimit;
    }
    
    get selectedBoardName() { // displaying board name on basis of first record in list.
        return this.respondentListToDisplay.length > 0? this.respondentListToDisplay[0].professionDetails.profession:'';
    }
   
    get isHealingArts() {
        return this.selectedBoardName === 'Healing Arts';
    }
    get showHIPAASection() {
        return this.HIPAASectionApplicableBoardsList && this.HIPAASectionApplicableBoardsList.includes(this.selectedBoardName);
    }
    get showBSQSection() {
        return this.BSQApplicableBoardsList && this.BSQApplicableBoardsList.includes(this.selectedBoardName);
    }   

    get hasLawSuitFiled() {
        return this.dataObj?.lawSuitFiled === 'Yes';
    }
    // GET OBJECT INFO
    @wire(getObjectInfo, {
        objectApiName: CONTACT_OBJECT
    })
    objectInfo;

    // GET PICKLIST VALUES OF STATE FIELD
    @wire(getPicklistValues, {
        recordTypeId: '$objectInfo.data.defaultRecordTypeId',
        fieldApiName: ContactState
    })
    wiredPicklistValues({
        error,
        data
    }) {
        console.log("inside wired")
        this.showSpinner = true;
        if (data && data.values) {
            this.stateOptions = data.values;
            this.init()
        } else if (error) {
            this.showSpinner = false;
            showAsyncErrorMessage(this, error);
        }
    }

    // GET OBJECT INFO FOR ADDRESS
    @wire(getObjectInfo, {
        objectApiName: ADDRESS_OBJECT
    })
    objectCountryInfo;
    @wire(getPicklistValues, {
        recordTypeId: '$objectCountryInfo.data.defaultRecordTypeId',
        fieldApiName: COUNTRY_CODE_FIELD,
    })
    countryPicklistValues({
        error,
        data
    }) {
        if (data && data.values) {
            this.countryOptions = data.values;
        } else if (error) {
            this.showSpinner = false;
            showAsyncErrorMessage(this, error);
        }
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
             console.log(
            'FINAL HEADER >>> ',
            this.labels.complaintFormHeader
        );
        } catch (e) {
            // keep defaults
        }
    }


    init() {
        this.showSpinner = true;
        let today = new Date();
        this.maxDateValue = today.getFullYear() + '-' + (today.getMonth() + 1) + '-' + today.getDate().toString().padStart(2,'0');
        this.dataObj.incidentDate = today.getFullYear() + '-' + String(today.getMonth() + 1).padStart(2, '0') + '-' + String(today.getDate()).padStart(2, '0');
        this.dataObj.reportedDate = today.getFullYear() + '-' + String(today.getMonth() + 1).padStart(2, '0') + '-' + String(today.getDate()).padStart(2, '0');
        // setting Default Date to One Year from Todays Date.
        let oneYrAfter = addYears(today, 1);
        this.defaultAuthExpiryDate = oneYrAfter.getFullYear() + '-' + (oneYrAfter.getMonth() + 1) + '-' + oneYrAfter.getDate();
        this.dataObj.authExpirationDate = this.defaultAuthExpiryDate;
        if (isGuest) {
            this.showSpinner = false;
            this.portalUser = false;
            this.checkAutomationAI();
            setTimeout(
                function () {
                    document.dispatchEvent(new CustomEvent('checkAutomation'));
                }.bind(this),
                1000
            );
        } else if (this.userId) {
            this.getUserDetails();
        } else {
            this.showSpinner = false;
            this.portalUser = false;
            this.checkAutomationAI();
            setTimeout(
                function () {
                    document.dispatchEvent(new CustomEvent('checkAutomation'));
                }.bind(this),
                1000
            );
        }
    }

    renderedCallback() {
        this.recaptchaDiv = this.template.querySelector('.recaptchaCheckbox2');
    }
    getUserDetails() {
        getCurrentUserDetails().then(result => {
            this.dataObj = result;
            let today = new Date();
            this.isInternalUser = result ? result.isCompliantSectionEditable : false;
            this.isSupportStaff = result.isSupportStaff;
            // Guest users must use the Guest_Record_fileupload__c path; treat only authenticated community users as portal users
            this.portalUser = !isGuest && !this.isInternalUser && !this.isSupportStaff;
            if (this.isSupportStaff) {
                return;
            }
            this.dataObj.authExpirationDate = this.defaultAuthExpiryDate;
            this.dataObj.telephone = this.dataObj.telephone ? formatPhoneNumber(this.dataObj.telephone) : this.dataObj.telephone;
            this.dataObj.cellPhone = this.dataObj.cellPhone ? formatPhoneNumber(this.dataObj.cellPhone) : this.dataObj.cellPhone;
            this.dataObj.incidentDate = today.getFullYear() + '-' + String(today.getMonth() + 1).padStart(2, '0') + '-' + String(today.getDate()).padStart(2, '0');
            this.dataObj.reportedDate = today.getFullYear() + '-' + String(today.getMonth() + 1).padStart(2, '0') + '-' + String(today.getDate()).padStart(2, '0');

            // Initallising Rest of the OBJ.
            this.dataObj.patientInfo = {
                complainantAddressData : {}
            }
            this.dataObj.boardSpecficQues = {}
            this.dataObj.profession = '';
            this.checkAutomationAI();
            setTimeout(
                function () {
                    document.dispatchEvent(new CustomEvent('checkAutomation'));
                }.bind(this),
                1000
            );
        }).catch(error => {
            showAsyncErrorMessage(this, error);
        }).finally(this.showSpinner = false);
    }



    checkAutomationAI() {
        
        let _this = this;
        document.addEventListener('automationDetected', (event) => {
            if (!event.detail) {
                if (!_this.initCall) {
                    _this.handleSubmit();
                } else {
                    //reCaptcha
                    _this._captchaResponse = _this.captchaResponse.bind(_this);
                    document.addEventListener(
                        'grecaptchaVerified',
                        _this._captchaResponse
                    );
                    _this.initCall = false;
                }
            }
        });
    }

    connectedCallback() {
        this.initLanguage();
        // console.log(this.currentPageReference);
        if(this.currentPageReference.attributes.name != 'complaint_form__c'){
            loadStyle(this, My_Resource + "/styles/internal-main.css");
        }
    }

    disconnectedCallback() {
        document.removeEventListener(
            'grecaptchaVerified',
            this._captchaResponse
        );
        if (this.sessionTimeout) {
            clearTimeout(this.sessionTimeout);
        }
        if (this.innerTimeout) {
            clearTimeout(this.innerTimeout);
        }
    }

    checkAutomationAndNext() {
        console.log('OUTPUT : ','checkAutomationAndNext');
        window.scrollTo({
            left: 0,
            top: 0,
            behavior: 'smooth'
        });
        document.dispatchEvent(new CustomEvent('checkAutomation'));
    }

    captchaResponse(e) {
        console.log('Entered Line 367');
        if (e.detail && JSON.stringify(e.detail)) {

            if (this.checkValidity()) {
                
                this.doSubmit('v3', JSON.stringify(e.detail));
            }
        } 
    }

    handleTelephoneFormat(event) {
        event.currentTarget.setCustomValidity("");
        event.currentTarget.reportValidity();
        const isEmployerField = event.currentTarget.dataset.employer;

        if (isEmployerField && event.target.name === 'telephone') {
            this.employerInfo[event.currentTarget.name] = formatPhoneNumber(event.currentTarget.value);
            this.employerInfo[event.currentTarget.name] = this.employerInfo[event.currentTarget.name] ? this.employerInfo[event.currentTarget.name] : event.currentTarget.value;
        } else if (event.target.name === 'telephone' || event.target.name === 'telephoneHome' || event.target.name === 'cellPhone') {
            this.dataObj[event.currentTarget.name] = formatPhoneNumber(event.currentTarget.value);
            this.dataObj[event.currentTarget.name] = this.dataObj[event.currentTarget.name] ? this.dataObj[event.currentTarget.name] : event.currentTarget.value;
        } 
    }

    handleUploadClicked = false;

    handleInputChange(event) {
        const isAddressField = event.currentTarget.dataset.address;
       
        if (isAddressField) {
            this.dataObj.complainantAddressData[event.currentTarget.name] = event.currentTarget.value;
            return;
        }

        if (this.dataObj.complaintReported === 'Yes' &&
            event.target.name === 'complaintReported' &&
            event.target.value === 'No' && this.entityList.length > 0) {
            this.modalHeading = 'Choosing No, Would Delete all the Other Entity Records Added, Are you sure you want to select It ?';
            this.modalHeader = 'Record';
            this.openConfirmationModal = true;
            this.deleteObject.isOtherEntitiesDelete = true;
            setTimeout(() => {
                this.focusFirstEle();
            }, 500);
        }

        this.dataObj[event.currentTarget.name] = event.currentTarget.value;
        this.dataObj.isPatient = event.currentTarget.name === 'isPatientYesNo' ? event.currentTarget.value === 'No' :  this.dataObj.isPatient
        if (event.currentTarget.type == 'checkbox') {     
                this.dataObj[event.currentTarget.name] = event.currentTarget.checked;
        }

        this.handleTelephoneFormat(event);
        if (this.dataObj.agreeToUploadFiles && !this.handleUploadClicked) {
            this.handleUploadClicked = true;
            this.createDraftPublicComplaint();
        }
    }

    handleDateValidation(event) {
        let incidentDatesInFuture;
        this.dataObj[event.currentTarget.name] = event.currentTarget.value;
        const sectionName = event.currentTarget.dataset.sectionName;
        const isStartDate = event.currentTarget.dataset.isStartDate;
        let date1, date2;
        // if(!this.dataObj.incidentStartDate && this.dataObj.incidentEndDate && event.currentTarget.name == 'incidentEndDate' && !event.currentTarget.value){
        //     this.template.querySelector("[data-id=incidentStartDate").setCustomValidity('');
        // }
        this.template.querySelector(`[data-id=${event.currentTarget.name}]`).setCustomValidity('');
        let errorMessage = '';

        if (sectionName === 'Coverage' && this.dataObj.coverageEndDate && this.dataObj.coverageStartDate) {

            date1 = new Date(this.dataObj.coverageStartDate);
            date2 = new Date(this.dataObj.coverageEndDate);

        } else if (sectionName === 'Incident' && this.dataObj.incidentStartDate && this.dataObj.incidentEndDate) {

            date1 = new Date(this.dataObj.incidentStartDate);
            date2 = new Date(this.dataObj.incidentEndDate);
            if (date1 > new Date()) {
                //errorMessage = `${sectionName} must be ${formatDate(new Date(this.maxDateValue))} or earlier`;
                incidentDatesInFuture = true;
                errorMessage = "Incident start date can\'t be a Future Date.";
                this.dataObj[event.currentTarget.name] = null;
                this.template.querySelector(`[data-id=${event.currentTarget.name}]`).value = null;
                event.currentTarget.setCustomValidity(errorMessage);
            }
            else if (date2 > new Date()) {
                incidentDatesInFuture = true;
                //errorMessage = `${sectionName} must be ${formatDate(new Date(this.maxDateValue))} or earlier`;
                errorMessage =  "Incident end date can\'t be a Future Date.";
                this.dataObj[event.currentTarget.name] = null;
                this.template.querySelector(`[data-id=${event.currentTarget.name}]`).value = null;
                event.currentTarget.setCustomValidity(errorMessage);
            }
        }else if (sectionName === 'Incident' && this.dataObj.incidentStartDate && new Date(this.dataObj.incidentStartDate) > new Date()) {
            //errorMessage = `${sectionName} must be ${formatDate(new Date(this.maxDateValue))} or earlier`;
            incidentDatesInFuture = true;
            errorMessage =  "Incident start date can\'t be a Future Date.";
            this.dataObj[event.currentTarget.name] = null;
            this.template.querySelector(`[data-id=${event.currentTarget.name}]`).value = null;
            event.currentTarget.setCustomValidity(errorMessage);
            
        }
        else if (sectionName === 'Incident' && this.dataObj.incidentEndDate && new Date(this.dataObj.incidentEndDate) > new Date()) {
            //errorMessage = `${sectionName} must be ${formatDate(new Date(this.maxDateValue))} or earlier`;
            incidentDatesInFuture = true;
            errorMessage =  "Incident end date can\'t be a Future Date.";
            this.dataObj[event.currentTarget.name] = null;
            this.template.querySelector(`[data-id=${event.currentTarget.name}]`).value = null;
            event.currentTarget.setCustomValidity(errorMessage);
            
        } 
        else if (sectionName === 'Reported Date' && this.dataObj.reportedDate) {

            date1 = new Date(this.dataObj.reportedDate);
         
            if (this.dataObj.reportedDate != this.maxDateValue && !this.isInternalUser) {
                //errorMessage = `${sectionName} must be ${formatDate(new Date(this.maxDateValue))} or earlier`;
                errorMessage = `${sectionName} needs to be current date only.`;
                this.dataObj[event.currentTarget.name] = null;
                this.template.querySelector(`[data-id=${event.currentTarget.name}]`).value = null;
                event.currentTarget.setCustomValidity(errorMessage);
            }
            else if((this.dataObj.incidentStartDate && date1 < new Date(this.dataObj.incidentStartDate) || this.dataObj.incidentEndDate && date1 < new Date(this.dataObj.incidentEndDate))){
                errorMessage = `${sectionName} cannot be smaller than incident start date or end date`;
                this.dataObj[event.currentTarget.name] = null;
                this.template.querySelector(`[data-id=${event.currentTarget.name}]`).value = null;
                
                event.currentTarget.setCustomValidity(errorMessage);
            }
        } 
        else if (sectionName === 'Contacted Date' && this.dataObj.contactedIndividualAboutCompDate) {

            date1 = new Date(this.dataObj.contactedIndividualAboutCompDate);
            if (date1 > new Date()) {
                // errorMessage = `${sectionName} must be ${formatDate(new Date(this.maxDateValue))} or earlier`;
                errorMessage = `${sectionName} can\'t be a Future Date.`;
                this.dataObj[event.currentTarget.name] = null;
                this.template.querySelector(`[data-id=${event.currentTarget.name}]`).value = null;
                event.currentTarget.setCustomValidity(errorMessage);
            }
        } else if (sectionName === 'Date of Birth' && this.dataObj.dob) {
            date1 = new Date(this.dataObj.dob);
            if (date1 > new Date()) {
                // errorMessage = `${sectionName} must be ${formatDate(new Date(this.maxDateValue))} or earlier`;
                errorMessage = `${sectionName} can\'t be a Future Date.`;
                this.dataObj[event.currentTarget.name] = null;
                this.template.querySelector(`[data-id=${event.currentTarget.name}]`).value = null;
                event.currentTarget.setCustomValidity(errorMessage);
            }
        } else if (sectionName === 'Authorization Expiration Date' && this.dataObj.authExpirationDate) {
            date1 = new Date(this.dataObj.authExpirationDate);
            if (date1 > new Date(this.defaultAuthExpiryDate)) {
                // errorMessage = `${sectionName} must be ${formatDate(new Date(this.defaultAuthExpiryDate))} or earlier`;
                errorMessage = `${sectionName} must be One Year from Today\'s Date or Earlier.`;
                this.dataObj[event.currentTarget.name] = null;
                this.template.querySelector(`[data-id=${event.currentTarget.name}]`).value = null;
                event.currentTarget.setCustomValidity(errorMessage);
            }
        }

        if (!incidentDatesInFuture && date1 && date2 && date1 > date2) {
            errorMessage = (isStartDate ?
                `${sectionName} Start Date cannot be greater than ${sectionName} End Date` :
                `${sectionName} End Date cannot be less than ${sectionName} Start Date`)
                //this.errorMessageSR = errorMessage;
                console.log('errMsg outside if >>>',this.errMsg);
                if(errorMessage != null){
                    this.errMsg=true;
                    //this.template.querySelector('#coverageStartDateError').focus();
                    console.log('errMsg inside if >>>',this.errMsg);
                }else{
                    this.errMsg=false;
                    console.log('errMsg inside else >>>',this.errMsg);
                }
            this.dataObj[event.currentTarget.name] = null;
            this.template.querySelector(`[data-id=${event.currentTarget.name}]`).value = null;

            event.currentTarget.setCustomValidity(errorMessage);
        
        }
        event.currentTarget.reportValidity();
    }

    handleWitnessData(event) {
        if (event.currentTarget.dataset.address) {
            this.selectedWitnessData['addressData'][event.currentTarget.name] = event.currentTarget.value;
            return;
        }
        this.selectedWitnessData[event.currentTarget.name] = event.currentTarget.value;
        if (event.target.name === 'telephone' || event.target.name ==='cellPhone') {
            event.currentTarget.setCustomValidity("");
            event.currentTarget.reportValidity();
            this.selectedWitnessData[event.currentTarget.name] = formatPhoneNumber(event.currentTarget.value);
            this.selectedWitnessData[event.currentTarget.name] = this.selectedWitnessData[event.currentTarget.name] ? this.selectedWitnessData[event.currentTarget.name] : event.currentTarget.value;

        }
    }

    handleAdditionalWitness() {
        this.selectedWitnessData = {
            'addressData': {}
        };
        this.isWitnessModalOpen = true;
        setTimeout(() => {
            this.focusFirstEle();
        }, 500);
    }

    handleClick() {
        this.boxClass = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-is-open';
    }

    handleSubmit() {
        this.submitDisabled = true;

        if (this.checkValidity()) {
            if (this.token) {
                this.showSpinner = true;
                this.doSubmit('v3', this.token);
            } 
            else {
                document.dispatchEvent(new CustomEvent('grecaptchaExecute'));
            }
        } else {
            this.submitDisabled = false;
        }

    }

    handleSubmitInternalUser(eve) {
        if (this.checkValidity()) {
            this.doSubmit(null, null);
        }
    }
    displayComplaintDetails = false;
    displayCompResultList = [];

    doSubmit(ctype, ctoken) {
        console.log('Entered Do Submit');
        if (ctype && ctoken) {
            this.dataObj.ctype = ctype;
            this.dataObj.recaptchaResponse = ctoken;
        }

        this.respondentListToDisplay.forEach(respondent => {
            respondent.telephone = respondent.telephone ? respondent.telephone.replace(/[^\d]/g, "") : respondent.telephone;
            if(respondent.employerInfo) {
                respondent.employerInfo.telephone = respondent.employerInfo.telephone ? respondent.employerInfo.telephone.replace(/[^\d]/g, "") : respondent.employerInfo.telephone;
            }
        });
        this.witnessData.forEach(witness => {
            witness.telephone = witness.telephone ? witness.telephone.replace(/[^\d]/g, "") : witness.telephone;
            witness.cellPhone = witness.cellPhone ? witness.cellPhone.replace(/[^\d]/g, "") : witness.cellPhone;
        });
        this.dataObj.telephone = this.dataObj.telephone ? this.dataObj.telephone.replace(/[^\d]/g, "") : this.dataObj.telephone;
        this.dataObj.cellPhone = this.dataObj.cellPhone ? this.dataObj.cellPhone.replace(/[^\d]/g, "") : this.dataObj.cellPhone;

        this.dataObj.telephoneHome = this.dataObj.telephoneHome ? this.dataObj.telephoneHome.replace(/[^\d]/g, "") : this.dataObj.telephoneHome;
        this.dataObj.witnessData = this.witnessData;
        this.dataObj.respondentData = this.respondentListToDisplay;
        if (this.dataObj.incidentStartDate === '')
            this.dataObj.incidentStartDate = null;
        if (this.dataObj.incidentEndDate === '')
            this.dataObj.incidentEndDate = null;
        if (this.dataObj.dob === '')
            this.dataObj.dob = null;
        if(this.dataObj.authExpirationDate === '') 
            this.dataObj.authExpirationDate = null; 
        // adding two new Lists.
        if(this.entityList && this.entityList.length > 0) {
            this.entityList.forEach(entityRec => {
                entityRec.telephone = entityRec.telephone ? entityRec.telephone.replace(/[^\d]/g, "") : entityRec.telephone; 
            })
        }
        if(this.attorneyInfoList && this.attorneyInfoList.length > 0) {
            this.attorneyInfoList.forEach(attorney => {
                attorney.attorneyPhone = attorney.attorneyPhone ? attorney.attorneyPhone.replace(/[^\d]/g, "") : attorney.attorneyPhone; 
            })
        }
        
        this.dataObj.entitiesData = this.entityList;
        this.dataObj.incidentList = this.incidentRecList;
        // this.attorneyInfo.attorneyPhone = this.attorneyInfo.attorneyPhone ? this.attorneyInfo.attorneyPhone.replace(/[^\d]/g, "") : this.attorneyInfo.attorneyPhone;
        this.dataObj.attorneyInfo = this.attorneyInfoList;
        this.dataObj.filesList = this.filesList;
        this.dataObj.draftComplaintId =  this.draftPublicComplaintId;
        this.dataObj.uniqueId = this.uniqueId;
        this.showSpinner = true;
        this.spinnerText = 'Please Wait, While we Submit your Complaint Details.'
        console.log('DATA OBJECT >>  ' + JSON.stringify(this.dataObj));
        debugger;
        createPublicComplaint({
            jsonData: JSON.stringify(this.dataObj)
        }).then(result => {
            console.log('createPublicComplaints RESULT: '+JSON.stringify(result));
            this.showSpinner = false;
            if (result) {
                this.displayComplaintDetails = true;
                this.isSupportStaff = false;
                this.complaintName = result.respondentData.length ? result.respondentData[0].publicComplaintName : null;
                this.displayCompResultList = result.respondentData?.map((rec,idx)=>{
                    return {...rec,sNoValue : String(idx+1).padStart(2,'0')}
                });
                console.log('displayCompResultList'+JSON.stringify(this.displayCompResultList)+this.displayCompResultList);
                // Resetting Phone Number Format. Since we need to proceed with captcha
                this.template.querySelectorAll('.phoneNumberField').forEach(input => {

                    input.setCustomValidity('');
                    input.reportValidity();
                    input.value = formatPhoneNumber(input.value);
                });
                // DISABLING CAPTCHA FOR SOMETIME.
                this.initCall = true;
                 if (result.isV3Failed) {

                     this.showSpinner = false;
                 } else if (result.isCaptchaInvalid) {
                    this.showSpinner = false;
                    this.errorMessage =
                        'Seems like you are trying to use automated scripts to fill this form. Please fill this form manually.';
                    this.hasError = true;
                } else {
                    this.submitDisabled = false;
                    document.dispatchEvent(new CustomEvent('grecaptchaReset'));
                    this.recaptchaDivStyle = 'display: none';
                    this.token = undefined;
                }

            }
        }).
        catch(error => {
            console.log('createPublicComplaints ERROR: '+JSON.stringify(error));
            this.respondentListToDisplay.forEach(respondent => {
                respondent.telephone = respondent.telephone ? formatPhoneNumber(respondent.telephone) : respondent.telephone;
                if(respondent.employerInfo) {
                    respondent.employerInfo.telephone = respondent.employerInfo.telephone ? formatPhoneNumber(respondent.employerInfo.telephone) : respondent.employerInfo.telephone;
                }
            });
            this.witnessData.forEach(witness => {
                witness.telephone = witness.telephone ? formatPhoneNumber(witness.telephone) : witness.telephone;
                witness.cellPhone = witness.cellPhone ? formatPhoneNumber(witness.cellPhone) : witness.cellPhone;
            });
            if(this.entityList && this.entityList.length > 0) {
                this.entityList.forEach(entityRec => {
                    entityRec.telephone = entityRec.telephone ? formatPhoneNumber(entityRec.telephone) : entityRec.telephone; 
                })
            }
            if(this.attorneyInfoList && this.attorneyInfoList.length > 0) {
                this.attorneyInfoList.forEach(attorney => {
                    attorney.attorneyPhone = attorney.attorneyPhone ? formatPhoneNumber(attorney.attorneyPhone) : attorney.attorneyPhone; 
                })
            }
            // this.attorneyInfo.attorneyPhone = this.attorneyInfo.attorneyPhone ? formatPhoneNumber(this.attorneyInfo.attorneyPhone) : this.attorneyInfo.attorneyPhone;
            //this.dataObj.attorneyInfo = {...this.attorneyInfo};
            this.dataObj.telephone = this.dataObj.telephone ? formatPhoneNumber(this.dataObj.telephone) : this.dataObj.telephone;
            this.dataObj.cellPhone = this.dataObj.cellPhone ? formatPhoneNumber(this.dataObj.cellPhone) : this.dataObj.cellPhone;

            this.template.querySelectorAll('.phoneNumberField').forEach(input => {
                input.setCustomValidity('');
                input.reportValidity();
            });

            this.submitDisabled = false;
            showAsyncErrorMessage(this, error.body.message);
            if (!this.isInternalUser) {
               
                document.dispatchEvent(new CustomEvent('grecaptchaReset'));
                this.recaptchaDivStyle = 'display: none';
                this.token = undefined;
            }
        }).finally(() => {
            this.showSpinner = false;
            this.spinnerText='';
        })
    }

    // getBackMyFocus = false
    handleDeleteConfirmation() {
        if (this.deleteObject.isFileDelete) {

            if(!this.filesList || this.filesList.length === 0) {
                    showMessage(this, {
                        title: "Info",
                        message: "There are no Files to Delete.",
                        messageType: "info",
                        mode: "dismissable"
                    });
                    this.openConfirmationModal = false;
                    // this.template.querySelector('');

                    // return;
            }

            let jsonToPass = {
                appDocId : this.selectedAppDocId,
                requestId : this.selectedRequestId
            }   
            

            // let jsonDataToPass = {
            //     draftComplaintId : this.draftPublicComplaintId,
            //     fileDetails : this.filesList
            // }
            this.showSpinner = true;
            handleDeleteFile({
                jsonData : JSON.stringify(jsonToPass)
            })
            .then(res=> {

                showMessage(this, {
                    title: "Success",
                    message:` File Deleted Successfully.`,
                    messageType: "success",
                    mode: "dismissable"
                });
                this.showSpinner = false;
                this.selectedFileIndex && this.filesList.splice(this.selectedFileIndex,1);
                this.filesList && this.filesList.forEach((resp, idx) => {
                    resp.sNoValue = (idx + 1).toString().padStart(2, '0');
                });
                
                if(this.draftComplaintToFilesUploadedCountMap.hasOwnProperty(this.selectedDraftCompId) && 
                    this.draftComplaintToFilesUploadedCountMap[this.selectedDraftCompId] > 0) {
                        
                    if(this.draftComplaintToFilesUploadedCountMap[this.selectedDraftCompId] == 5) {
                        this.template.querySelector('c-lpi-complaints-file-upload').maxFileLimitReached = false;
                    } 
                  
                    this.draftComplaintToFilesUploadedCountMap[this.selectedDraftCompId] -= 1;
                    this.draftComplaintToFilesUploadedCountMap = {...this.draftComplaintToFilesUploadedCountMap};
                    console.log('REDUCING BY one >> ' + JSON.stringify(this.draftComplaintToFilesUploadedCountMap));
                }
                // this.template.querySelector('c-modpr-complaints-file-upload').agreeToUploadFiles = false;
            })
            .catch(error => {
                showAsyncErrorMessage(this, error);
                this.showSpinner = false;
            });

        } else if (this.deleteObject.isRespondentDelete) {
            if(this.respondentListToDisplay[this.selectedIndex]) {
                let businesslicenseIndex = this.selectedBusinessIds.indexOf(this.respondentListToDisplay[this.selectedIndex].licenseDetails.businessId);
                businesslicenseIndex && this.selectedBusinessIds.splice(businesslicenseIndex,1);
            }
            const deletedRespLabel = (this.licensedRespondentForDocUpload.filter(rec=>{
                return Number(+this.selectedIndex + 1).toString().padStart(2,'0') == rec.uniqueKey
            })[0] || {}).label || '';

            this.licensedRespondentForDocUpload = [...this.licensedRespondentForDocUpload.filter(rec=>{
                return Number(rec.uniqueKey) != this.selectedIndex + 1;
            })
            .map(rec=> { 
                let originalVal = rec.uniqueKey;
              
                rec.uniqueKey = (Number(rec.uniqueKey) > (+this.selectedIndex + 1) ? (Number(rec.uniqueKey) - 1).toString().padStart(2, '0') : rec.uniqueKey); // if 1 is deleted then 2,3,4.. record indices will be affected
                
                if(originalVal != rec.uniqueKey) { 
                    rec.value = JSON.stringify({
                        ...JSON.parse(rec.value),
                        uniqueKey : rec.uniqueKey
                    });
                }
                
                return rec;
            })];
            this.filesList = [...this.filesList.filter(rec=>{
                return rec.submittedAgainst != deletedRespLabel
            })];
            this.template.querySelector('c-lpi-complaints-file-upload')?.updateRespondentDraftComplaintMap( Number(+this.selectedIndex + 1).toString().padStart(2,'0'));
            this.respondentListToDisplay.splice(this.selectedIndex, 1);
            this.respondentListToDisplay.forEach((resp, idx) => {
                resp.sNoDisplayVal = (idx + 1).toString().padStart(2, '0');
            });
            if(this.selectedIndex == 0) {
                this.dataObj.coverageOption = null;
                this.dataObj.coverageStartDate = null;
                this.dataObj.coverageEndDate = null;
                this.dataObj.authExpirationDate = null;
                this.dataObj.hipaaConsent = false;
                this.dataObj.complainantSignature = null;
                this.dataObj.patientInfo = {
                    complainantAddressData : {}
                }
                this.dataObj.boardSpecficQues = {} 
                this.resetPatientSectionData = true;
                this.dataObj.isPatientYesNo = null;
                this.dataObj.isPatient = false;
            }
            showMessage(this, {
                title: "Success",
                message: "Respondent deleted successfully.",
                messageType: "success",
                mode: "dismissable"
            });

            setTimeout(() => {
                this.template.querySelector('c-lpi-complaint-respondent-details').focusOnInitialButton('initialButton');
                // this.focusOnInitialButton('initialButton');
            }, 500);
        
        } else if (this.deleteObject.isWitnessDelete) {
            this.witnessData.splice(this.selectedIndex, 1);
            this.witnessData.forEach((witness, idx) => {
                witness.sNoValue = (idx + 1).toString().padStart(2, '0');
            });
            showMessage(this, {
                title: "Success",
                message: "Witness has been deleted successfully.",
                messageType: "success",
                mode: "dismissable"
            });
        } 
        else if(this.deleteObject.isAttorneyDelete) {
            this.attorneyInfoList.splice(this.selectedIndex, 1);
            this.attorneyInfoList.forEach((attorney, idx) => {
                attorney.sNoDisplayVal = (idx + 1).toString().padStart(2, '0');
            });
            showMessage(this, {
                title: "Success",
                message: "Attorney has been deleted successfully.",
                messageType: "success",
                mode: "dismissable"
            });
            setTimeout(() => {
                this.template.querySelector('c-lpi-complaint-attorney-details').focusOnInitialButton('initialButton');
            }, 500);
        }
        else if (this.deleteObject.isOtherEntitiesDelete) {
            this.entityList = [];
            this.modalHeading = null;
            setTimeout(() => {
                this.template.querySelector('c-lpi-file-compliant-accordion').focusOnInitialButton('buttonFocusClass');
            }, 500);
        } else if(this.deleteObject.entityRecordDelete) {

            if(this.selectedEntityLocInfo) {
                this.entityList && this.entityList.splice(this.selectedEntityLocInfo.index, 1);
                this.entityList = this.entityList.map((rec, idx) => {
                    return {
                        ...rec,
                        sNo: (idx + 1).toString().padStart(2, '0')
                    }
                })
                setTimeout(()=> {
                    showMessage(this, {
                        title: "Success",
                        message: `${this.selectedEntityLocInfo.sectionName} Deleted Successfully`,
                        messageType: "success",
                        mode: "dismissable"
                    });
                    this.template.querySelectorAll('c-lpi-file-compliant-accordion').forEach((rec,idx)=>{
                    idx===1 && rec.focusAddLocation()
                    })
                },300);
            }

        }
        else if(this.deleteObject.locationRecordDelete) {

            if(this.selectedEntityLocInfo) {

                this.incidentRecList && this.incidentRecList.splice(this.selectedEntityLocInfo.index, 1);
                this.incidentRecList = this.incidentRecList.map((rec, idx) => {
                    return {
                        ...rec,
                        sNo: (idx + 1).toString().padStart(2, '0')
                    }
                })

                showMessage(this, {
                    title: "Success",
                    message: `${this.selectedEntityLocInfo.sectionName} Deleted Successfully`,
                    messageType: "success",
                    mode: "dismissable"
                });
                setTimeout(()=> {
                    this.template.querySelectorAll('c-lpi-file-compliant-accordion').forEach((rec,idx)=>{
                    idx===0 && rec.focusAddLocation()
                    })
                },300);
            }
        }
        this.openConfirmationModal = false;
        this.deleteObject = {};
        this.selectedIndex = null
    }
    handleCancelConfirmation() {
        this.openConfirmationModal = false;
        if(this.deleteObject.isFileDelete) {
            this.selectedRequestId = '';
            this.selectedAppDocId = '';
        }
        if(this.deleteObject.locationRecordDelete || this.deleteObject.entityRecordDelete) {
            this.selectedEntityLocInfo = null;
            // this.focusOnInitialButton(this.deleteObject.locationRecordDelete? 'actionBtnFocus' : 'actionBtnEntityFocus');
        }
        console.log('modalHeader :>> ', this.modalHeader);
        console.log('selectedIndex :>> ', this.selectedIndex);
        if(this.modalHeader == 'Respondent'){
            this.setFocusOnMenuButton(this.selectedIndex);
        }
        if(this.modalHeader == 'Attorney'){
            this.setFocusOnMenuButtonAttorney(this.selectedIndex);
        }
        if(this.modalHeader == 'Record'){
            this.setFocusOnMenuButtonOther(this.selectedIndex);
        }
        this.selectedIndex = null;
    }

    checkValidity() {
        this.focus = false;
        this.focusIndex = -1;
        let isAllValid = [...this.template.querySelectorAll('lightning-input,lightning-radio-group,lightning-textarea,lightning-combobox')].reduce((validSoFar, input) => {
            input.reportValidity();
            let valid = input.checkValidity() && checkLength(input);
            valid = input.disabled ? true : valid;
            // if (!valid && (!this.focus || this.focusIndex == -1 || this.focusIndex > parseInt(input.dataset.index))) {
            //     input.focus();
            //     this.focus = true;
            //     this.focusIndex = input.dataset.index;
            // }
            return validSoFar && valid;
        }, true);

        let regex = '^(\\([0-9]{3}\\) |[0-9]{3}-)[0-9]{3}-[0-9]{4}$';
        this.template.querySelectorAll('.phoneNumberField').forEach(input => {
            if (input.value && !input.value.match(regex)) {
                isAllValid = false;
                input.setCustomValidity("Please enter a valid telephone number.");
                input.reportValidity();
            }
        });
        if(this.template.querySelector('c-lpi-board-specific-complaint-ques')) {
            isAllValid =this.template.querySelector('c-lpi-board-specific-complaint-ques').checkValidity() && isAllValid;
        }
        if(this.template.querySelectorAll('c-lpi-patient-complaint-info')) {
            this.template.querySelectorAll('c-lpi-patient-complaint-info').forEach(rec=>{
                isAllValid = rec.checkValidity() && isAllValid;
            });
        }
        let incidentDateFieldError;
        if(!this.dataObj.incidentStartDate && this.dataObj.incidentEndDate){
            incidentDateFieldError = true;
            let field = this.template.querySelector("[data-id=incidentStartDate]");
            field.setCustomValidity('Start Date needs to be provided if you are adding the end date.');
            field.reportValidity();
            isAllValid = false;
        }
        if(this.dataObj.incidentStartDate && this.dataObj.reportedDate && this.dataObj.incidentStartDate > this.dataObj.reportedDate){
            let field = this.template.querySelector("[data-id=reportedDate]");
            field.setCustomValidity('Reported Date cannot be smaller than incident start date..');
            field.reportValidity();
            isAllValid = false;
        }
        if(this.dataObj.incidentEndDate && this.dataObj.reportedDate && this.dataObj.incidentEndDate > this.dataObj.reportedDate){
            let field = this.template.querySelector("[data-id=reportedDate]");
            field.setCustomValidity('Reported Date cannot be smaller than incident end date..');
            field.reportValidity();
            isAllValid = false;
        }
        if (!isAllValid) {
          //  showAsyncErrorMessage(this, 'Please validate all the input fields.')
       var allInput = this.template.querySelector(".slds-has-error");
        if (allInput) {
        allInput.scrollIntoView();
        allInput.focus();
        }
            // Added by Piyush aneja because of I-184089 Issue
            // if (this.respondentListToDisplay.length === 0) {
            //     // If the condition is true, execute this block
            //     // eslint-disable-next-line @lwc/lwc/no-async-operation
            //     // setTimeout(() => {
            //     //     const childLWC = this.template.querySelector('c-lpi-complaint-respondent-details');
            //     //     if (childLWC) {
            //     //         // Assuming focusOnButton is a method inside c-modpr-complaint-respondent-details
            //     //         childLWC.focusOnButton();
            //     //     }
            //     // }, 2000);
            // } else {
            //     // If the condition is false, execute this block
            //     // eslint-disable-next-line @lwc/lwc/no-async-operation
            //     setTimeout(() => {
            //         this.addFocus();
            //     }, 2000);
            // }
            
        }
       
        if (isAllValid && this.respondentListToDisplay.length === 0) {
            isAllValid = false;
            showAsyncErrorMessage(this,
                'Please add atleast one subject.'
                );
                // 'Please add atleast one respondent.'
            setTimeout(() => {
                this.focusFirstEle();
            }, 500);
            setTimeout(() => {
                this.template.querySelector('c-lpi-complaint-respondent-details').focusOnInitialButton('initialButton');

                // this.focusOnInitialButton('initialButton');
            }, 5000);
        }
        return isAllValid;
    }

    navigateHome() {
        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                pageName: 'home'
            },
        });
    }

    addFocus(){
        this.focus = false;
        this.focusIndex = -1;
        let isAllValid = [...this.template.querySelectorAll('lightning-input,lightning-radio-group,lightning-textarea,lightning-combobox')].reduce((validSoFar, input) => {
            input.reportValidity();
            let valid = input.checkValidity() && checkLength(input);
            valid = input.disabled ? true : valid;
            if (!valid && (!this.focus || this.focusIndex == -1 || this.focusIndex > parseInt(input.dataset.index))) {
                    input.focus();
                    console.log('focus-->', input);
                    this.focus = true;
                    this.focusIndex = input.dataset.index;
            }
            return validSoFar && valid;
        }, true);
    }


    @track licensedRespondentForDocUpload = []; 

    saveRespondentDetailsNew(event) {
        
        const {respondentDetails,isEdit,index} = event.detail;
        let recordsCnt = this.respondentListToDisplay.length;

        if(respondentDetails.professionDetails.knowsRespondentProfession && 
                respondentDetails.professionDetails.licensedUnlicensed && !this.selectedBusinessIds.includes(respondentDetails.licenseDetails.businessId)) {
            this.selectedBusinessIds.push(respondentDetails.licenseDetails.businessId);
        }

        if(isEdit) {
            // get the sNo.
           let idx =  index || 0;
            // push it to businessLicenseIds
            let changedToLicensed = false;
            if(!this.checkLicensedRespondent(this.respondentListToDisplay[idx]) && this.checkLicensedRespondent(respondentDetails)) {
                // this respondent became a licensed one on editing. 
                changedToLicensed = true;
            }
            let numToDisplay = (Number(idx) + 1 || recordsCnt).toString().padStart(2, '0');
           this.respondentListToDisplay[idx] = {
                ...respondentDetails,
                sNoDisplayVal : numToDisplay
           }

           let valueJson = {
                uniqueKey : numToDisplay, // this will be used to identify the particular record on selecting respondent in upload component.
                ...this.extractDetailsFromRespondentForDocUploadParams(respondentDetails) // extracting required name, ssn fields from the json.
            }
            const labelVal = respondentDetails?.combinedName + ' - ' + respondentDetails?.professionDetails?.profession;

           this.licensedRespondentForDocUpload = [...this.licensedRespondentForDocUpload.filter(rec=> {
                if(Number(rec.uniqueKey) == idx + 1) {
                    // we need to omit this record.
                    if(!this.checkLicensedRespondent(respondentDetails)){
                        return false;
                    }
                }
                return true;
           })
           .map(rec=> {
                if(Number(rec.uniqueKey) == idx + 1) {
                    rec.label = labelVal;
                    rec.uniqueKey = numToDisplay;
                    rec.value =  JSON.stringify(valueJson) //respondentDetails?.professionDetails?.profession + '#@#' + rec.uniqueKey;
                }
                return rec;
           })];

           if(changedToLicensed) {
                this.licensedRespondentForDocUpload.push({
                    label : labelVal,
                    uniqueKey : numToDisplay,
                    value: JSON.stringify(valueJson)
                });
                this.licensedRespondentForDocUpload = [...this.licensedRespondentForDocUpload];
           }

        } else {

            let displayNo = (recordsCnt+1).toString().padStart(2, '0');
            this.respondentListToDisplay.push({
                ...respondentDetails,
                sNo : recordsCnt, // represents index.
                sNoDisplayVal : displayNo, // represents sNo display value 
                addressValue : getMergedAddress(respondentDetails.addressData)
            });
            // while inserting keep track of the respondents which have board name / Profession with them. 

            if(this.checkLicensedRespondent(respondentDetails)) {
                // label and value to show this as options in fileupload component.
                let valueJson = {
                    uniqueKey : displayNo, // this will be used to identify the particular record on selecting respondent in upload component.
                    ...this.extractDetailsFromRespondentForDocUploadParams(respondentDetails)
                }
                this.licensedRespondentForDocUpload.push({
                    label : respondentDetails?.combinedName + ' - ' + respondentDetails?.professionDetails?.profession,
                    uniqueKey : displayNo,
                    value: JSON.stringify(valueJson)   //respondentDetails?.professionDetails?.profession + '#@#' + displayNo
                });
                this.licensedRespondentForDocUpload = [...this.licensedRespondentForDocUpload];
            }
        }

        console.log('LIST NOW IS >> ' + JSON.stringify(this.licensedRespondentForDocUpload));
    }

    extractDetailsFromRespondentForDocUploadParams(respondentDetails) {

        // here check if the respondent is a licensed respondent if yes send the accountInfo params. 
        // else send first name middle name and last name from respondentdetails json. 
        let jsonPassing = {
            boardName : respondentDetails.professionDetails?.profession,
            authType : respondentDetails.professionDetails?.entityOrIndividual,
            selectedBoardName : respondentDetails.professionDetails?.profession
        };
        if(respondentDetails.professionDetails?.licensedUnlicensed === 'Licensed') {
            jsonPassing = {
                ...jsonPassing,
                ...respondentDetails.licenseDetails?.licenseeAccountInfo,
                licenseNum : respondentDetails.licenseDetails?.licenseNum,
                accountId : respondentDetails.licenseDetails.accountId,
                licenseTypeName : respondentDetails.licenseDetails.profession
            }
        } else {
            jsonPassing = {
                ...jsonPassing,
                firstName : respondentDetails.firstName,
                lastName : respondentDetails.lastName,
                middleName : respondentDetails.middleName,
                entityName : respondentDetails.entityName
            }
        }

        return jsonPassing;
    }

    checkLicensedRespondent(respondentDetails) {
        return respondentDetails?.professionDetails?.knowsRespondentProfession === 'Yes' && respondentDetails?.professionDetails.profession;
    }


    focusOnInitialButton(className){
        var focusOnInitial = this.template.querySelector(`.${className}`);
            if(focusOnInitial){
               focusOnInitial.focus();
        }
    }


    saveWitnessDetails() {
        if (this.checkValidityRespWitness()) {
            this.showSpinner = true;
            let stateLabel = this.selectedWitnessData.addressData.state ? this.stateOptions.find(opt => opt.value === this.selectedWitnessData.addressData.state).label : null;
            this.selectedWitnessData.addressData.stateLabel = stateLabel;
            this.selectedWitnessData.entityName = this.selectedWitnessData.middleName && checkLength(this.selectedWitnessData.middleName) ? this.selectedWitnessData.firstName + ' ' + this.selectedWitnessData.middleName + ' ' + this.selectedWitnessData.lastName : this.selectedWitnessData.firstName + ' ' + this.selectedWitnessData.lastName
            this.selectedWitnessData.witnessActionAriaLabel = 'Show Actions for ' + this.selectedWitnessData.entityName + ' Witness';
            this.selectedWitnessData.witnessActionEditLabel = 'Edit Action for ' + this.selectedWitnessData.entityName + ' Witness';
            this.selectedWitnessData.witnessActionDeleteLabel = 'Delete Action for ' + this.selectedWitnessData.entityName + ' Witness';
            this.selectedWitnessData.addressValue = getMergedAddress(this.selectedWitnessData.addressData);
            if (this.selectedIndex) {
                this.witnessData[this.selectedIndex] = this.selectedWitnessData;
            } else {
                this.selectedWitnessData.sNoValue = (this.witnessData.length + 1).toString().padStart(2, '0');
                this.witnessData.push(this.selectedWitnessData);
            }
            
            this.showSpinner = false;
            this.selectedIndex = null;
            // showMessage(this, {
            //     title: "Success",
            //     message: `${this.selectedWitnessData.entityName} has been added as a witness.`,
            //     messageType: "success",
            //     mode: "dismissable"
            // });
            setTimeout(()=>{
                this.focusOnInitialButton('witnessBtnFocus')
                showMessage(this, {
                    title: "Success",
                    message: `${this.selectedWitnessData.entityName} has been added as a witness.`,
                    messageType: "success",
                    mode: "dismissable"
                });
            },500);
            this.isWitnessModalOpen = false;
        }
    }

    checkValidityRespWitness() {
        this.focus = false;
        this.focusIndex = -1;
        let isAllValid = [...this.template.querySelectorAll('.respondentWitness')].reduce((validSoFar, input) => {
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
        let regex = '^(\\([0-9]{3}\\) |[0-9]{3}-)[0-9]{3}-[0-9]{4}$';
        this.template.querySelectorAll('.phoneNumberField').forEach(input => {
            if (input.value && !input.value.match(regex)) {
                isAllValid = false;
                input.setCustomValidity("Please enter a valid telephone number.");
                input.reportValidity();
            }
        })
        return isAllValid;
    }

    handleRespEditNew(event) {
        let idxToPass = event.currentTarget.dataset.index;
        let respondentDataToEdit = JSON.parse(JSON.stringify(this.respondentListToDisplay[idxToPass]));
        this.template.querySelector('c-lpi-complaint-respondent-details').setDataForEdit(respondentDataToEdit,idxToPass);
        // setTimeout(()=>{
        //     this.template.querySelector('.initial').focus();
        // },1000);
    } 

    handleRespDelete(event) {
        this.modalHeading = 'Are you sure you want to delete this respondent? Please note that by deleting this respondent, the files uploaded against them (if present) will also be deleted.';
        this.modalHeader = 'Respondent';
        this.deleteObject.isRespondentDelete = true;
        this.selectedIndex = event.currentTarget.dataset.index;
        this.openConfirmationModal = true;
        // setTimeout(() => {
        //     this.template.querySelector('c-lpi-complaint-respondent-details').focusOnInitialButton('initialButton');
        //     // this.focusOnInitialButton('initialButton');
        // }, 0);

        setTimeout(() => {
            this.focusFirstEle();
        }, 500);
    }

    handleWitnessEdit(event) {
        this.selectedWitnessData = JSON.parse(JSON.stringify(this.witnessData[event.currentTarget.dataset.index]));
        this.selectedIndex = event.currentTarget.dataset.index;
        this.isWitnessModalOpen = true;
        setTimeout(() => {
            this.focusFirstEle();
        }, 500);
    }

    handleWitnessDelete(event) {
        this.modalHeading = 'Are you sure you want to delete this witness?';
        this.modalHeader = 'Witness';
        this.deleteObject.isWitnessDelete = true;
        this.selectedIndex = event.currentTarget.dataset.index;
        this.openConfirmationModal = true;
        setTimeout(() => {
            this.focusFirstEle();
        }, 500);
    }
    closeModalWitness() {
        this.isWitnessModalOpen = false;
        this.selectedIndex = null;
        this.selectedWitnessData = {};
        this.focusOnInitialButton('witnessBtnFocus');
    }

    handleAccModalData(event) {
        const {
            data,
            otherInfo
        } = event.detail;
        if (data.addressData) {
            data.addressValue = getMergedAddress(data.addressData);
        }
        if (otherInfo.sectionName === 'Other Entities') {
            // updating Adding/Updating Based on the Flag.
            if (data.individualOrBusiness === 'Individual') {
                data.combinedName = (!data.middleName ? data.firstName + ' ' + data.lastName : data.firstName + ' ' + data.middleName + ' ' + data.lastName);
            }
            if (otherInfo.isUpdate) {
                this.entityList[otherInfo.updateIdx] = {
                    ...data
                };
            } else {
                this.entityList.push(data);
            }
            // populating Index.
            this.entityList = this.entityList.map((rec, idx) => {
                return {
                    ...rec,
                    sNo: (idx + 1).toString().padStart(2, '0'),
                    actionAriaLabel : 'Show Actions for '+rec.entityName + ' Other Entities'
                }
            })
            setTimeout(()=> {
                this.template.querySelectorAll('c-lpi-file-compliant-accordion').forEach((rec,idx)=>{
                idx===1 && rec.focusAddLocation()
                })
                showMessage(this, {
                    title: "Success",
                    message: `${otherInfo.sectionName} Record Added Successfully`,
                    messageType: "success",
                    mode: "dismissable"
                });
            },300);
        } else if (otherInfo.sectionName === 'Location') {
            // updating Adding/Updating Based on the Flag.
            if (otherInfo.isUpdate) {
                this.incidentRecList[otherInfo.updateIdx] = {
                    ...data
                };
            } else {
                this.incidentRecList.push(data);
            }
            // populating Index.
            this.incidentRecList = this.incidentRecList.map((rec, idx) => {
                return {
                    ...rec,
                    sNo: (idx + 1).toString().padStart(2, '0'),
                    actionAriaLabel : 'Show Actions for '+rec.entityName + ' Location'
                }
            })
            setTimeout(()=>{ this.focusOnInitialButton('actionBtnFocus')
            showMessage(this, {
                title: "Success",
                message: `${otherInfo.sectionName} Record Added Successfully`,
                messageType: "success",
                mode: "dismissable"
            });
            console.log('Hi');
            },500);
        }
        // showMessage(this, {
        //     title: "Success",
        //     message: `${otherInfo.sectionName} Record Added Successfully`,
        //     messageType: "success",
        //     mode: "dismissable"
        // });
    }

    handleFocusRetainOnCancel(event) {

        // We need to bring focus on Action button when we press can 
        const sectionName = event.detail.sectionName;
        if(sectionName ==='Other Entities') {
            setTimeout(()=> {
                this.template.querySelectorAll('c-lpi-file-compliant-accordion').forEach((rec,idx)=>{
                idx===1 && rec.focusAddLocation()
                })
            },300);
            // this.focusOnInitialButton('otherEntityActionBtn');
        } else {
            if(this.incidentRecList!=null && this.incidentRecList.length>0){
                this.focusOnInitialButton('actionBtnFocus');
            } else {
                // give focus on location button.
                setTimeout(()=> {
                    this.template.querySelectorAll('c-lpi-file-compliant-accordion').forEach((rec,idx)=>{
                    idx===0 && rec.focusAddLocation()
                    })
                },300);
            }
        }
    }
    handleEditAction(event) {
        const sectionName = event.currentTarget.dataset.sectionName;
        const recIdx = event.currentTarget.dataset.index;
        let selectedRecord = {};
        let selectedSectionName = "";
        if (sectionName === 'Entity') {
            selectedRecord = this.entityList[recIdx];
            selectedSectionName = 'Other Entities';
        } else if (sectionName === 'Location') {
            selectedRecord = this.incidentRecList[recIdx];
            selectedSectionName = 'Location';
        }
        // setting the value of child from parent.
        this.template.querySelector('c-lpi-file-compliant-accordion').recordToEdit(selectedRecord, selectedSectionName, recIdx);
    }

    handleDeleteAction(event) {
        const sectionName = event.currentTarget.dataset.sectionName;
        this.selectedEntityLocInfo = null;
        this.modalHeading = 'Are you sure you want to Delete this Record?';
        this.modalHeader = 'Record';
        this.deleteObject.entityRecordDelete = (sectionName === 'Entity');
        this.deleteObject.locationRecordDelete = (sectionName === 'Location');
        this.selectedIndex = event.currentTarget.dataset.index;
        this.selectedEntityLocInfo = {
            sectionName : sectionName,
            index : event.currentTarget.dataset.index
        }
        this.openConfirmationModal = true;
        // this.getBackMyFocus = true;

        setTimeout(() => {
            this.focusFirstEle();
        }, 500);
        console.log('selectedIndex :>> ', this.selectedIndex);
    }   

    handleChildFieldChange(event) {
        if(event.detail) {
            const {sectionName,name,value,isAddress} = event.detail;

            if(sectionName === 'Patient') {
                if(isAddress) {
                    this.dataObj.patientInfo.complainantAddressData[name] = value;
                } else {
                    this.dataObj.patientInfo[name] = value;
                }

            } else if(sectionName ==='Complainant') {
                if(isAddress) { 
                    this.dataObj.complainantAddressData[name] = value;
                } else {
                    this.dataObj[name] = value ;
                }
            } else if(sectionName ==='Board Specific Questions'){
                this.dataObj.boardSpecficQues[name] = value;
            }            
        }
    }

    // Focus Leak Acessibiltiy Issue 
    focusFirstEle() {
        const focusableElements = 'lightning-combobox, lightning-button-icon, button, lightning-helptext, lightning-input, lightning-button, lightning-radio-group';
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

    @track draftComplaintToFilesUploadedCountMap = {};


    handleFileUploadCntrl(event) {
        this.filesList = this.filesList ? this.filesList : [];
        const FILE_LIMIT  = 5;

        let totalFilesUploaded = this.filesList.length + 1;
        let {uploadedFile,...otherData} = event.detail;

        if(uploadedFile) {

            if(this.draftComplaintToFilesUploadedCountMap.hasOwnProperty(uploadedFile.draftComplaintId)) { // { draftComplaintId : countofFilesUploaded }

                if(this.draftComplaintToFilesUploadedCountMap[uploadedFile.draftComplaintId] < FILE_LIMIT) {

                    this.filesList.push({
                        ...uploadedFile,
                        sNoValue : String(totalFilesUploaded).padStart(2, '0')
                    });
                    this.draftComplaintToFilesUploadedCountMap[uploadedFile.draftComplaintId] += 1; // increase file upload count. 

                    if(this.draftComplaintToFilesUploadedCountMap[uploadedFile.draftComplaintId] === FILE_LIMIT) {
                        this.template.querySelector('c-lpi-complaints-file-upload').maxFileLimitReached = true;
                    }  
                }
            } else {
                this.draftComplaintToFilesUploadedCountMap[uploadedFile.draftComplaintId] = 1;
                this.filesList.push({
                    ...uploadedFile,
                    sNoValue : String(totalFilesUploaded).padStart(2, '0')
                });
            }
            console.log('TEST DRAFT COMPLAINT >> ' + this.selectedDraftCompId);
            console.log('MAP VALUE NOW FOR FILE UPLOAD >> ' + JSON.stringify(this.draftComplaintToFilesUploadedCountMap));
            // if(this.filesList?.length < FILE_LIMIT) { 
            //     this.filesList.push({
            //         ...uploadedFile,
            //         sNoValue : String(totalFilesUploaded).padStart(2, '0')
            //     });
            //     if(this.filesList?.length === FILE_LIMIT) {
            //         this.template.querySelector('c-modpr-complaints-file-upload').maxFileLimitReached = true;
            //     }  
            // }
        }
    }


    handleUploadEligiblity(event) {
        const {draftCompId} = event.detail;
        let invalidUpload = false;

        if(this.draftComplaintToFilesUploadedCountMap.hasOwnProperty(draftCompId) && this.draftComplaintToFilesUploadedCountMap[draftCompId] >= 5) {
            invalidUpload = true;
        }
        console.log('INSIDE UPLOAD ELIGIBLITY RETURNED >> ' + invalidUpload);
        
        this.template.querySelector('c-lpi-complaints-file-upload').maxFileLimitReached = invalidUpload;
    }


    handleFileDeleteConfirmation(event) {
        let {draftComplaintId} = event.detail;
        this.draftPublicComplaintId = draftComplaintId;
        this.modalHeading = 'UnSelecting This Option, would result in deletion of all the files you have uploaded, Are you sure you want to delete them ?';
        this.deleteObject.isFileDelete = true;
        this.openConfirmationModal = true;
        setTimeout(() => {
            this.focusFirstEle();
        }, 500);
    }

    handleDraftComplaintCreation(event) {
        const { uniqueKeyToDraftCompMap } = event.detail;
        this.dataObj.uniqueKeyToDraftComp = uniqueKeyToDraftCompMap;
    }

 
    setDraftComplaint(event) {
        let {draftComplaintId} = event.detail;
        this.draftPublicComplaintId = draftComplaintId;
    }
    
    handleEscKeyDown(event) {
        if (event.code === 'Escape' || event.keyCode === 27) {
            this.closeModalWitness();
            this.handleCancelConfirmation();
        }
    }

    @track selectedAppDocId = '';
    @track selectedRequestId = '';
    @track selectedDraftCompId = '';

    selectedFileIndex = '';

    handleFileDelete(event) {
        this.openConfirmationModal = true;
        this.deleteObject.isFileDelete = true;
        this.modalHeading = 'Are you sure you want to delete this file?';
        this.modalHeader = 'File?';
        this.selectedAppDocId = event.currentTarget.dataset.appDocId;
        this.selectedRequestId = event.currentTarget.dataset.requestId;
        this.selectedFileIndex = event.currentTarget.dataset.selectedIndex;
        this.selectedDraftCompId = event.currentTarget.dataset.draftCompId;
        setTimeout(() => {
            this.focusFirstEle();
        }, 500);
    }

    attorneyInfoList = []; // contains List of Attorneys'

    // Attorney Part  - Vamsi 

    handleAttorneyDetailsEdit(event) {
        let idxToPass = event.currentTarget.dataset.index;
        let attorneyToEdit = JSON.parse(JSON.stringify(this.attorneyInfoList[idxToPass]));
        console.log('ATTORNEY TO EDIT >> ' + JSON.stringify(attorneyToEdit));
        this.template.querySelector('c-lpi-complaint-attorney-details').setDataForEdit(attorneyToEdit,idxToPass);
    } 

    handleAttorneyDetailsDelete(event) {
        this.modalHeading = 'Are you sure you want to delete this Attorney?';
        this.modalHeader = 'Attorney';
        this.deleteObject.isAttorneyDelete = true;
        this.selectedIndex = event.currentTarget.dataset.index;
        this.openConfirmationModal = true;
        setTimeout(()=>{this.template.querySelector('.initial2').focus();},1000);
        setTimeout(() => {
            this.focusFirstEle();
        }, 500);
    }

    handleAttorneySave(event) {
             
        const {attorneyInfo,isEdit,index} = event.detail;
        let recordsCnt = this.attorneyInfoList.length;
        console.log('JSON >>  ' + JSON.stringify(event.detail));
        if(isEdit) {
            // get the sNo.
            console.log('IS EDIT ACTIVATED >> ' + JSON.stringify(this.attorneyInfo));
            console.log('INDEX >>  ' + index);
           let idx =  index || 0;
           let numToDisplay = (Number(idx) + 1 || recordsCnt).toString().padStart(2, '0');
           this.attorneyInfoList[idx] = {
                ...attorneyInfo,
                sNoDisplayVal : numToDisplay,
                addressValue : getMergedAddress(attorneyInfo.addressData)
           }
        } else {

            let displayNo = (recordsCnt+1).toString().padStart(2, '0');
            this.attorneyInfoList.push({
                ...attorneyInfo,
                sNo : recordsCnt, // represents index.
                sNoDisplayVal : displayNo, // represents sNo display value 
                addressValue : getMergedAddress(attorneyInfo.addressData)
            });
        }        
        this.attorneyInfoList = [...this.attorneyInfoList];
    }
    // Attorney Part Ends - Vamsi

    //Download Public Complaint PDF - Ankit
    handleDownloadPC(event){
        // Construct the URL for the Visualforce page
        const vfPageUrl = '/apex/LpiComplaintsFromPage?recordId='+event.target.dataset.pcid;

        // Open the Visualforce page in a new browser tab or window
        window.open(vfPageUrl, '_blank');
    }
    ShowMore(){
        this.ShowMoreText = true;
        this.ShowLessText = false;
    }
    ShowLess(){
        this.ShowMoreText = false;
        this.ShowLessText = true;
    }

    focusOnMenuButton(event){
        const {isEdit,index,info} = event.detail;
        console.log('index :>> ', index);
        console.log('isEdit :>> ', isEdit);
        console.log('info :>> ', info);
        if (isEdit) {
            if (info == 'Attorney') {
                setTimeout(()=>{
                    this.setFocusOnMenuButtonAttorney(index);
                },500);
            }
            if (info == 'Subject') {
                setTimeout(()=>{
                    this.setFocusOnMenuButton(index);
                },500);
            }
            if (info == 'Other Entities') {
                setTimeout(()=>{
                    this.setFocusOnMenuButtonOther(index);
                },500);
            }
        }
    }
    setFocusOnMenuButton(selectedIndex){
        var focusOnInitial = this.template.querySelector(`lightning-button-menu[data-subjectindex='${selectedIndex}']`);
        if(focusOnInitial){
           focusOnInitial.focus();
        }
    }
    setFocusOnMenuButtonAttorney(selectedIndex){
        var focusOnInitial = this.template.querySelector(`lightning-button-menu[data-attorneyindex='${selectedIndex}']`);
        if(focusOnInitial){
           focusOnInitial.focus();
        }
    }
    setFocusOnMenuButtonOther(selectedIndex){
        var focusOnInitial = this.template.querySelector(`lightning-button-menu[data-otherindex='${selectedIndex}']`);
        if(focusOnInitial){
           focusOnInitial.focus();
        }
    }
}