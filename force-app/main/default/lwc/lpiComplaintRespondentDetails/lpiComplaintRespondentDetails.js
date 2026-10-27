import { LightningElement,api,track,wire } from 'lwc';
import {
    showAsyncErrorMessage,
    showMessage,
    formatPhoneNumber,
    checkLength
} from 'c/lpiUtil';
import {
    getPicklistValues,
    getObjectInfo
} from 'lightning/uiObjectInfoApi';

import CONTACT_OBJECT from '@salesforce/schema/Account';
import ADDRESS_OBJECT from '@salesforce/schema/Address';
import COUNTRY_CODE_FIELD from '@salesforce/schema/Address.CountryCode';

import ContactCountry from '@salesforce/schema/Account.PersonOtherCountryCode';
import ContactState from '@salesforce/schema/Account.PersonOtherStateCode';
import getProfessionOptions from '@salesforce/apex/LPI_ComplaintsController.getProfessionOptions';
import getLicenseTypeOptions from '@salesforce/apex/LPI_ComplaintsController.getLicenseTypeOptions';
import getBusinessLicenseDetails from '@salesforce/apex/LPI_ComplaintsController.getBusinessLicenseDetails';
import getCurrentLanguage from '@salesforce/apex/EMP_LanguageCtrl.getCurrentLanguage';
import getLabels from '@salesforce/apex/EMP_LanguageCtrl.getLabels';
import PublicComplaint_OBJECT from '@salesforce/schema/PublicComplaint'; 
import SUBJECT_FIELD from '@salesforce/schema/PublicComplaint.Subjects__c';
import {
    LABEL_API_NAMES,
    mapApiToCamel,
    readStoredLanguage,
    writeStoredLanguage
} from 'c/lpLanguageUtils';

const LICENSED_INDIVIDUAL_NEW = 'Licensed';
const UNLICENSED_INDIVIDUAL_NEW = 'Unlicensed';
const DEFAULT_BOARD_NAME = 'Financial and Consumer Services Commission of New Brunswick';

const ENTITY_TEXT = 'Entity';
const INDIVIDUAL_TEXT = 'Individual';
const CA_COUNTRY_CODE = 'CA';

export default class LpiComplaintRespondentDetails extends LightningElement {
    selectedValue = '';
    picklistOptions = [];
    @track selectedSubject = '';
    @track otherSubject = '';
    @track subjectOptions = [];
    static OTHER_SUBJECT_VALUE = 'Other';

    isModalOpen = false;
    showSpinner = false;
    @track disableLicenseType = true;
    @api selectedBusinessIds; // this is to ensure that we exclude those licenses which we already selected.
    showInitalDetails = false;
    isProfessionSelected = false;
    @track EntitySelection;
    knowsRespondentProfession = false;
    showRespondentDetails = false;
    isEdit = false;
    setIndex = -1;
    @track isLicenseSelected = false;
    @track professionRecords = [];
    @track licenseRecords = [];
    @track respondentDetails={
        professionDetails : {
            profession : ''
        },
        licenseDetails : {
            licenseeAccountInfo : {}
        },
        addressData  : {},
        employerInfo : {
            employerAddress : {}
        }
    }
    @track boxClass = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click';
    
    patternObj = {
        text: '^((?!(<)|(>)).)*$',
        digits: '^(\\([0-9]{3}\\) |[0-9]{3}-)[0-9]{3}-[0-9]{4}$',
        email: '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,10}',
        zipCode: '^[A-Za-z]\\d[A-Za-z][ -]?\\d[A-Za-z]\\d$',
        ssn: '^(?!.*(<|>))[0-9]*$'
    }
    @track entityIndividualOptions = [{
        'label': 'Business',
        'value': ENTITY_TEXT
    },
    {
        'label': INDIVIDUAL_TEXT,
        'value': INDIVIDUAL_TEXT
    }];

    @track licensedUnlicensedOptions = [{
        'label': 'Licensed',
        'value': LICENSED_INDIVIDUAL_NEW
    },
    {
        'label': 'Unlicensed',
        'value': UNLICENSED_INDIVIDUAL_NEW
    }];

    @track yesNoOptions = [{
        'label': 'Yes',
        'value': 'Yes'
    }, {
        'label': 'No',
        'value': 'No'
    }];
    employmentStatusOptions = [
        {
            'label': 'Termination',
            'value': 'Termination'
        },
        {
            'label': 'Suspension',
            'value': 'Suspension'
        },
        {
            'label': 'Resignation in lieu of termination',
            'value': 'Resignation in lieu of termination'
        },
        {
            'label': 'Employed',
            'value': 'Employed'
        },
        {
            'label': 'Other',
            'value': 'Other'
        }
    ];

     @track labels={

        complaintSubjectOfComplaint:'Subject(s) of your Complaint',
        complaintAddSubject:'Add Subject',
        complaintSubjectLicenceInstructionPrefix:'Whether you’re getting a mortgage, buying insurance, making a purchase at your door or investing for your future, the professionals you deal with may need to be licensed or registered with the Commission. Visit our ',
        complaintCheckLicenceAndRegistration:'Check Licence and Registration',
        complaintSubjectLicenceInstructionSuffix:' page to learn more.',
        complaintAddEditSubject:'Add/Edit Subject',
        complaintAsterisk:'Asterisk',
        complaintAsteriskRequiredField:'indicates required field',
        complaintPleaseType:'Please type',
        complaintUnknown:'Unknown',
        complaintRequiredFieldsUnknown:'for required fields if you do not know the details.',
        complaintKnowRespondentBoard:'Do you know the Agency of the respondent you are complaining against?',
        complaintKnowRespondentBoardRequiredError:'Error: Do you know the Agency of the respondent you are complaining against is required.',
        complaintAddRespondentInformation:'Please add the information about the business or individual you are complaining against.',
        complaintBusinessIndividualRequiredError:'Error: Business or Individual is required.',
        complaintSelectBoard:'Agency Name',
        complaintChooseBoard:'Choose an Agency',
        complaintBoardRequiredError:'Error: Agency is required.',
        complaintSelectSubject:'Select Subject',
        complaintSelectSubjectPlaceholder:'Select a Subject',
        complaintOther:'Other',
        complaintOtherSubject:'Other Subject',
        complaintEnterOtherSubject:'Enter other subject',
        complaintOtherSubjectRequiredError:'Error: Other Subject is required.',
        complaintSelectProfession:'Select Industry',
        complaintChooseProfession:'Choose a Profession',
        complaintProfessionRequiredError:'Error: Profession is required.',
        complaintSubjectLicenseStatus:"Do you know the subject's license status?",
        complaintSubjectLicenseStatusRequiredError:"Error: Do you know the subject's license status?",
        complaintSubjectInformation:'Subject Information',
        complaintDbaName:'DBA Name',
        complaintEnterDbaName:'Enter DBA Name',
        complaintCorporateName:'Corporate Name',
        complaintEnterCorporateName:'Enter Corporate Name',
        complaintEntityName:'Entity Name',
        complaintEnterEntityName:'Enter Entity Name',
        complaintEntityNameRequiredError:'Error: Entity Name is required.',
        complaintFirstName:'First Name',
        complaintEnterFirstName:'Enter First Name',
        complaintMiddleName:'Middle Name',
        complaintEnterMiddleName:'Enter Middle Name',
        complaintLastName:'Last Name',
        complaintEnterLastName:'Enter Last Name',
        complaintTelephoneNumber:'Telephone Number',
        complaintEnterTelephoneNumber:'Enter Telephone Number',
        complaintTelephoneNumberRequiredError:'Error: Telephone Number is required.',
        complaintFirstNameRequiredError:'Error: First Name is required.',
        complaintLastNameRequiredError:'Error: Last Name is required.',
        complaintRespondentEmail:'Repondent Email',
        complaintEnterRespondentEmail:'Enter Repondent Email',
        complaintStreetAddress:'Street Address',
        complaintEnterStreetAddress:'Enter Street Address',
        complaintStreetAddressRequiredError:'Error: Street Address is required.',
        complaintCityTown:'City / Town',
        complaintEnterCityTown:'Enter City or Town',
        complaintCityRequiredError:'Error: City is required.',
        complaintCountry:'Country',
        complaintSelectCountry:'Select a country',
        complaintCountryRequiredError:'Error: Country is required.',
        complaintEntryDoesNotMatchPattern:'Your Entry does not match the pattern',
        complaintState:'State',
        complaintSelectState:'Select a State',
        complaintStateRequiredError:'Error: State is required.',
        complaintZipCode:'Zip Code',
        complaintEnterZipCode:'A1A 1A1',
        complaintZipCodeRequiredError:'Error: Zip Code is required.',
        complaintEnterProfession:'Enter Profession',
        complaintLicenseNumberOrName:'License number or name',
        complaintSearchByLicenseNumberOrName:'Search by License Number or Name',
        complaintZipCodePatternError:'Please enter a valid Canadian Postal Code (e.g. A1A 1A1).',
        complaintOtherLicenseNumber:'Other License Number',
        complaintEnterOtherLicenseNumber:'Enter other license number',
        complaintOtherLicenseNumberRequiredError:'Error: Other License Number is required.',
        complaintOtherLicenseState:'Other License State',
        complaintEnterOtherLicenseState:'Enter other License State',
        complaintOtherLicenseStateRequiredError:'Error: Other License State is required.',
        complaintCurrentEmployerInformation:'Current Employer Information',
        complaintEmployerNameIfKnown:'Name of Employer (if known)',
        complaintEnterEmployerNameIfKnown:'Enter Name of Employer (if known)',
        complaintEmployerNameRequiredError:'Error: Name of Employer is required.',
        complaintEmployerAddress:'Employer Address',
        complaintEmploymentStatus:'Employment Status',
        complaintSelectEmploymentStatus:'Select Employment Status',
        complaintEmploymentStatusRequiredError:'Error: Employment Status is required.',

        complaintEmailAddress:'Email Address',
        complaintEnterEmailAddress:'Enter Email Address',
        complaintCancel:'Cancel',
        complaintSave:'Save',
        complaintYes:'Yes',
        complaintNo:'No'


        




     }
      connectedCallback(){

         this.initLanguage();
     }
     // get subject picklistvalues
      @wire(getObjectInfo, { objectApiName: PublicComplaint_OBJECT })
    objectInfo;

    @wire(getPicklistValues, {
        recordTypeId: '$objectInfo.data.defaultRecordTypeId',
        fieldApiName: SUBJECT_FIELD
    })
    wiredSubjectPicklistValues({ error, data }) {
        if (data && data.values) {
            const options = [...data.values];
            const hasOther = options.some(
                (opt) => opt.value === LpiComplaintRespondentDetails.OTHER_SUBJECT_VALUE
            );
            if (!hasOther) {
                options.push({
                    label: this.labels?.complaintOther || 'Other',
                    value: LpiComplaintRespondentDetails.OTHER_SUBJECT_VALUE
                });
            }
            this.subjectOptions = options;
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
        fieldApiName: COUNTRY_CODE_FIELD
    })
    countryPicklistValues({
        error,
        data
    }) {
        console.log('data',data);
        if (data && data.values) {
            this.countryOptions = data.values;
            const index = this.countryOptions.findIndex(opt => opt.value === 'CA');
            if (index !== -1) {
                // Create a new array with the modified order
                this.countryOptions = [
                    this.countryOptions[index],
                    ...this.countryOptions.slice(0, index),
                    ...this.countryOptions.slice(index + 1)
                ];
            }
        } else if (error) {
            showAsyncErrorMessage(this, error);
        }
    }

    // GET OBJECT INFO
    @wire(getObjectInfo, {
        objectApiName: CONTACT_OBJECT
    })
    contactObjectInfo;

    // GET PICKLIST VALUES OF STATE FIELD
    @wire(getPicklistValues, {
        recordTypeId: '$contactObjectInfo.data.defaultRecordTypeId',
        fieldApiName: ContactState
    })
    wiredPicklistValues({
        error,
        data
    }) {
        if (data && data.values) {
            this.stateOptions = data.values;
        } else if (error) {
            this.showSpinner = false;
            showAsyncErrorMessage(this, error);
        }
    }

    get isNotUnknownProfession() {
        return true;
    }
    get isLicensed() {
        return this.respondentDetails.professionDetails.licensedUnlicensed === LICENSED_INDIVIDUAL_NEW;
    }
    get isIndividualUnlicensed(){
        return this.respondentDetails.professionDetails.licensedUnlicensed === UNLICENSED_INDIVIDUAL_NEW && !this.isBusinessEntity;
    }
    get isFromLicenseSearch() {
        return this.isLicensed && this.isLicenseSelected;
    }
    get isBusinessEntity() {
        return (this.respondentDetails.licenseDetails.authorizationType === 'Business' || this.respondentDetails.professionDetails.entityOrIndividual === ENTITY_TEXT);
    }
    get showOtherStateField() {
        return this.respondentDetails.addressData.otherState || (!this.isLicensed && this.respondentDetails.addressData.country !== CA_COUNTRY_CODE);
    }
    get showCurrentEmployerSection() {
        return this.respondentDetails.professionDetails.entityOrIndividual === INDIVIDUAL_TEXT && !this.isLicenseSelected;
    }
    get authorizationType() {
        return this.respondentDetails.professionDetails.entityOrIndividual === 'Entity' ||  this.respondentDetails.professionDetails.entityOrIndividual == 'Business' ? 'Business' : 'Individual';
    }
    get disableLicenseSearch() {
        return this.disableLicenseType ; // disabling license search if board is not selected.
    }
    get isCosbarBoardSelected() {
        return this.isLicenseSelected;
    }

    // License status shows after Business/Individual is answered (and user knows the board)
    get showLicenseStatusQuestion() {
        return this.knowsRespondentProfession
            && !!this.respondentDetails?.professionDetails?.entityOrIndividual;
    }

    // Agency / Industry / Subject show only after Business/Individual AND license status are answered
    get showAgencyIndustrySection() {
        return this.knowsRespondentProfession
            && !!this.respondentDetails?.professionDetails?.entityOrIndividual
            && !!this.respondentDetails?.professionDetails?.licensedUnlicensed;
    }

    get showOtherSubjectInput() {
        return this.selectedSubject === LpiComplaintRespondentDetails.OTHER_SUBJECT_VALUE;
    }

    @api
    setDataForEdit(recordToEdit,index) {
        this.respondentDetails = {...recordToEdit};
        this.selectedSubject = recordToEdit?.selectedSubject || '';
        this.otherSubject = recordToEdit?.otherSubject || '';
        this.isEdit = true;
        this.isModalOpen = true;
        setTimeout(()=>{
            this.focusFirstEle()
        },500);
        this.setIndex = index;
        // we have few boolean parameters to set to make other sub sections visible. 
        // step - 1 
        this.knowsRespondentProfession = this.respondentDetails.professionDetails.knowsRespondentProfession === 'Yes';
        // step - 2
        if(this.respondentDetails.professionDetails.knowsRespondentProfession!==null) {
            this.showInitalDetails = true;
        }
        this.isLicenseSelected = this.isLicensed && (this.respondentDetails.licenseDetails.licenseNum);
        this.isProfessionSelected = this.knowsRespondentProfession && this.respondentDetails.professionDetails.profession;

        if(this.isProfessionSelected) {
            this.getProfessions();
            this.fetchLicenseTypeOptions();
        }
        // step - 3
        if(this.respondentDetails.professionDetails.entityOrIndividual || this.respondentDetails.professionDetails.licensedUnlicensed) {
            this.showRespondentDetails = true;
        }
    }

    typingTimer;
    emptyProfession = false;

    getProfessions() {
            this.showSpinner = true;
            if(this.respondentDetails.professionDetails.entityOrIndividual == ENTITY_TEXT){
                  this.EntitySelection='Business';
        
            }
            else{
                this.EntitySelection='Individual'
            }
            console.log('entered');
            getProfessionOptions({
                authType : this.EntitySelection
            }).then(result => {
                console.log('Result>>>'+JSON.stringify(result));
                this.professionRecords = [...result];
                this.applyDefaultBoardSelection();
                this.showSpinner = false;
                this.EntitySelection='';
            }).catch(error => {
                showAsyncErrorMessage(this, error);
                this.showSpinner = false;
            })
    }

    applyDefaultBoardSelection() {
        if (this.respondentDetails.professionDetails.profession) {
            return;
        }
        const defaultBoard = (this.professionRecords || []).find(
            option => option.value === DEFAULT_BOARD_NAME || option.label === DEFAULT_BOARD_NAME
        );
        if (!defaultBoard) {
            return;
        }
        this.respondentDetails = {
            ...this.respondentDetails,
            professionDetails: {
                ...this.respondentDetails.professionDetails,
                profession: defaultBoard.value
            }
        };
        this.fetchLicenseTypeOptions();
    }
    
     // Added by Piyush aneja because of I-184089 Issue
    @api focusOnButton(){
        var focusOnInitial = this.template.querySelector('.initialButton');
            if(focusOnInitial){
               focusOnInitial.focus();
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

    handleInputChange(event) {
        if (event.target.name === 'subject' || event.currentTarget.name === 'subject') {
            this.selectedSubject = event.detail?.value ?? event.currentTarget.value;
            if (this.selectedSubject !== LpiComplaintRespondentDetails.OTHER_SUBJECT_VALUE) {
                this.otherSubject = '';
            }
            return;
        }
        if (event.target.name === 'otherSubject' || event.currentTarget.name === 'otherSubject') {
            this.otherSubject = event.detail?.value ?? event.currentTarget.value;
            return;
        }
        const professionSectionData = event.currentTarget.dataset.profession;
        const addressData = event.currentTarget.dataset.address;
        const employerData = event.currentTarget.dataset.employer;
        const license = event.currentTarget.dataset.license;
        if(professionSectionData) {

            if(event.currentTarget.name === 'knowsRespondentProfession') {
                delete this.respondentDetails.professionDetails.licensedUnlicensed;
                delete this.respondentDetails.professionDetails.entityOrIndividual;
                this.showRespondentDetails = false;
                // if(event.currentTarget.value === 'Yes') {
                //     this.getProfessions();
                // }
            }

            if(event.currentTarget.name === 'entityOrIndividual') {
                delete this.respondentDetails.professionDetails.licensedUnlicensed;
            }
           
            this.respondentDetails.professionDetails[event.currentTarget.name] = event.currentTarget.value;

            if(this.knowsRespondentProfession && event.currentTarget.name ==='entityOrIndividual' && this.respondentDetails.professionDetails.entityOrIndividual)
                {
                    this.getProfessions();
                }

            if((event.currentTarget.name === 'profession' && this.respondentDetails.professionDetails.profession) ||
                (this.knowsRespondentProfession && event.currentTarget.name ==='entityOrIndividual' && this.respondentDetails.professionDetails.profession)) {
                this.fetchLicenseTypeOptions();
            }
            // if(event.currentTarget.name === 'licenseTypeSelected' && this.respondentDetails.professionDetails.licenseTypeSelected) {
                
            // }
            this.knowsRespondentProfession = this.respondentDetails.professionDetails.knowsRespondentProfession ==='Yes';
            this.showInitalDetails = this.showInitalDetails || event.currentTarget.name === 'knowsRespondentProfession';
            
            if(event.currentTarget.name ==='entityOrIndividual' || event.currentTarget.name === 'licensedUnlicensed' || event.currentTarget.name == 'profession' || event.currentTarget.name == 'licenseTypeSelected') {
                this.showRespondentDetails = true;
                this.respondentDetails = {
                    professionDetails : {...this.respondentDetails.professionDetails},
                    licenseDetails : {}, // ...this.respondentDetails.licenseDetails
                    addressData : {},
                    employerInfo : {
                        employerAddress : {}
                    }
                }
                this.licenseRecords = [];
                this.isLicenseSelected = false; // since we are changing the Step 2 Fields.
                if(event.currentTarget.value === UNLICENSED_INDIVIDUAL_NEW || (!this.knowsRespondentProfession && this.respondentDetails.professionDetails.entityOrIndividual !=='Business')) {
                    this.respondentDetails.addressData.country = 'CA';
                    //this.respondentDetails.addressData.state = 'MO';
                } 
                
            } 
        } 
        else if(employerData && addressData) {
            this.respondentDetails.employerInfo.employerAddress[event.currentTarget.name] = event.currentTarget.value;
        } else if(employerData) {
            this.respondentDetails.employerInfo[event.currentTarget.name] = event.currentTarget.value;
        }
        else if(addressData) {
            this.respondentDetails.addressData[event.currentTarget.name] = event.currentTarget.value;
        }
        else if(license){
            this.respondentDetails.licenseDetails[event.currentTarget.name] = event.currentTarget.value;
        } 
        else {
            this.respondentDetails[event.currentTarget.name] = event.currentTarget.value;
        }
        this.handleTelephoneFormat(event);
    }

    fetchLicenseTypeOptions() {
        if(!this.respondentDetails.professionDetails.entityOrIndividual) {
            showMessage(this, {
                title: "Warning",
                message: "Please Select the Information about the Business or Individual you are Complaining Against.",
                messageType: "warning",
                mode: "dismissable"
            });
            return;
        }
        this.showSpinner = true;
        this.disableLicenseType = false;
        getLicenseTypeOptions({
            selectedBoardName : this.respondentDetails.professionDetails.profession,
            authType : this.authorizationType
        }).then(result => {
                this.disableLicenseType = (!result || result.length === 0);
                this.licenseTypeOptions = [...result];
                this.showSpinner = false;
        }).catch(error => {
            showAsyncErrorMessage(this, error);
            this.showSpinner = false;
        })
    }

    handleRemovePill(event) {
        let licenseRec = {
            ...this.respondentDetails.licenseDetails,
            isPrimary : event.currentTarget.dataset.index == 0,
            searchTerm : '',
        };
        this.respondentDetails.licenseDetails = licenseRec;
        this.respondentDetails = {
            professionDetails : {...this.respondentDetails.professionDetails},
            licenseDetails : {...this.licenseRec},
            addressData : {},
            employerInfo : {
                employerAddress:{}
            }
        }
        this.isLicenseSelected = false;
        this.licenseRecords = [];
        showMessage(this, {
            title: "Success",
            message: "Selected License has been removed.",
            messageType: "success",
            mode: "dismissable"
        });
        // this.selectedBusinessIds.splice(event.currentTarget.dataset.index, 1);
    }

    handleChangeBusinessLicense(event) {
        if (!event.currentTarget.value) {
            this.licenseRecords = [];
            this.respondentDetails.licenseDetails.searchTerm = '';
            return;
        }
        this.respondentDetails.licenseDetails.searchTerm = event.currentTarget.value;
        this.getBusinessDetails(event.currentTarget.value);
    }

    blTypingTimer;
    getBusinessDetails(searchTerm) {

        if (!this.respondentDetails.professionDetails.profession) {
            showMessage(this, {
                title: "Info",
                message: "Please Select a Suitable Agency, to Search Licenses/Names",
                messageType: "info",
                mode: "dismissable"
            });
            return;
        }
        else if (!this.respondentDetails.professionDetails.entityOrIndividual) {
            showMessage(this, {
                title: "Info",
                message: "Please add the information about the business or individual you are complaining against.",
                messageType: "info",
                mode: "dismissable"
            });
            return;
        }
        else if(searchTerm === '%' || searchTerm === '_'){
            showAsyncErrorMessage(this,`${searchTerm} is not a valid character to search with.`);
            return;
        } 
        else if (searchTerm && searchTerm.length < 3) {
            return;
        }
        clearTimeout(this.blTypingTimer);
        this.blTypingTimer = setTimeout(() => {
            this.showSpinner = true;
            this.refs.licenseSearchLookup.blur();

            getBusinessLicenseDetails({
                jsonData: JSON.stringify({
                    'entityName': searchTerm,
                    'selectedBusinessIds': this.selectedBusinessIds.toString(),
                    'profession': this.respondentDetails.professionDetails.profession, //,
                    'licenseType' : this.respondentDetails.professionDetails.licenseTypeSelected,
                    'authType' : this.authorizationType
                })
            }).then(result => {
                this.refs.licenseSearchLookup.focus();

                if (!result || result.length === 0) {
                    showMessage(this, {
                        title: "Info",
                        message: "No License found.Please update the search criteria.",
                        messageType: "info",
                        mode: "dismissable"
                    });
                    this.respondentDetails.licenseDetails.searchTerm = '';
                    this.licenseRecords = [];
                } else {
                    this.licenseRecords = result.map(rec=>{
                        return {
                            ...rec,
                            hasDBAName : rec.licenseDetails && !!rec.licenseDetails?.licenseeAccountInfo?.dbaName,
                            hasCorporateName :  !!rec?.licenseDetails?.licenseeAccountInfo.corporateName,
                            hasAddress : rec.addressData && true,
                            hasCounty : rec.addressData && !!rec.addressData.county
                        }
                    });
                    console.log('LICENSE RECORDS >> ' + JSON.stringify(this.licenseRecords));
                }
            }).catch(error => {
                showAsyncErrorMessage(this, error);
            }).finally(() => {
                this.showSpinner = false;
            })
        }, 1000);
    }

    handeBusinessSelect(event) {
        let {
            entityName, firstName, middleName, lastName, email, telephone, licenseDetails, ...addressDetails
        } = this.licenseRecords?.filter(resp => event.currentTarget.dataset.id === resp.licenseDetails.businessId)[0];

        console.log('TEST ABC >> ' + JSON.stringify(this.licenseRecords?.filter(resp => event.currentTarget.dataset.id === resp.licenseDetails.businessId)[0]));
        this.respondentDetails.licenseDetails = {
            ...this.respondentDetails.licenseDetails,
            licenseeAccountInfo : {
                ...licenseDetails?.licenseeAccountInfo
            },
            isPrimary : event.currentTarget.dataset.index === 0,
            searchTerm : event.target.value,
            entityName : licenseDetails.entityName,
            businessId : licenseDetails.businessId,
            licenseNum : licenseDetails.licenseNum,
            authorizationType : licenseDetails.authorizationType,
            profession : licenseDetails.profession,
            accountId : licenseDetails.accountId,
            pillName : licenseDetails.licenseNum +' - ' + (licenseDetails.entityName || '')
        }
        console.log('this.respondentDetails.licenseDetails >> ' + JSON.stringify(this.respondentDetails.licenseDetails));

        this.respondentDetails = {
            ...this.respondentDetails,
            hasDBAName : !!this.respondentDetails.licenseDetails?.licenseeAccountInfo?.dbaName,
            hasCorporateName :  !!this.respondentDetails?.licenseDetails?.licenseeAccountInfo?.corporateName,
            firstName : firstName,
            middleName : middleName,
            lastName : lastName,
            email : email,
            entityName : entityName,
            telephone : telephone ? formatPhoneNumber(telephone) : telephone
        }

        if(addressDetails.addressData) {
            this.respondentDetails.addressData = {
                ...this.respondentDetails.addressData,
                streetOne : addressDetails.addressData.streetOne,
                country : addressDetails.addressData.country,
                state : addressDetails.addressData.state,
                otherState : addressDetails.addressData.otherState,
                city : addressDetails.addressData.city,
                zipCode : addressDetails.addressData.zipCode,
                county : addressDetails.addressData.county
            }
        } else {
            this.respondentDetails.addressData = {};
        }
        console.log('SELECTED ADDRESS DATA >>  ' + JSON.stringify(this.respondentDetails));
        this.isLicenseSelected = true;
        this.boxClass = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click';
        // this.selectedBusinessIds.push(event.currentTarget.dataset.id);
    }

    resetModalDetails() {
        this.respondentDetails={
            professionDetails : {
                profession : ''
            },
            licenseDetails : {   
            },
            addressData : {},
            employerInfo : {
                employerAddress : {}
            }
        }
        this.licenseRecords = [];
        // this.professionRecords = [];
        this.isLicenseSelected = false;
        this.isProfessionSelected = false;
        this.showInitalDetails = false;
        this.showRespondentDetails = false;
        this.setIndex = -1;
        this.disableLicenseType = true;
        this.isEdit = false;
        this.selectedSubject = '';
        this.otherSubject = '';
    }

    handleTelephoneFormat(event) {
        event.currentTarget.setCustomValidity("");
        event.currentTarget.reportValidity();
        const employerData = event.currentTarget.dataset.employer;

       if(employerData && event.currentTarget.name == 'telephone') {
            this.respondentDetails.employerInfo[event.currentTarget.name] = formatPhoneNumber(event.currentTarget.value);
            this.respondentDetails.employerInfo[event.currentTarget.name] = this.respondentDetails.employerInfo[event.currentTarget.name] ? this.respondentDetails.employerInfo[event.currentTarget.name] : event.currentTarget.value;
       }
       else if (event.target.name === 'telephone' || event.target.name === 'telephoneHome') {
            this.respondentDetails[event.currentTarget.name] = formatPhoneNumber(event.currentTarget.value);
            this.respondentDetails[event.currentTarget.name] = this.respondentDetails[event.currentTarget.name] ? this.respondentDetails[event.currentTarget.name] : event.currentTarget.value;
       } 
    }

    saveRespondentDetails() {

        if(!this.checkValidity()) {
            return;
        }
        let combinedName = this.respondentDetails.entityName ?
        this.respondentDetails.entityName :
        (this.respondentDetails.middleName ?
            this.respondentDetails.firstName + ' ' + this.respondentDetails.middleName + ' ' + this.respondentDetails.lastName :
            (this.respondentDetails.firstName || '') + ' ' + (this.respondentDetails.lastName || ''));
        let newCombinedName = 'Actions button for' + combinedName;   
        let editName ='Edit button for' + combinedName;
        let deletName= 'Delete button for ' + combinedName;
        console.log('RESPONDENT DETAILS >> ' + JSON.stringify(this.respondentDetails));
        this.dispatchEvent(new CustomEvent('save', {
            detail : {
                respondentDetails : {
                    ...this.respondentDetails,
                    selectedSubject : this.selectedSubject,
                    otherSubject : this.showOtherSubjectInput ? this.otherSubject : '',
                    combinedName : combinedName,
                    newCombinedName : newCombinedName,
                    editName : editName,
                    deletName : deletName
                },
               isEdit : this.isEdit,
               index : this.setIndex
            }
        }));
        this.closeModalRespondent();
        showMessage(this, {
            title: "Success",
            message: `Respondent ${this.isEdit?'Updated':'Added'} Successfully.`,
            messageType: "success",
            mode: "dismissable"
        });
    }

    handleAdditionalResp(event) {
        this.isModalOpen = true;
        setTimeout(()=>{
            this.focusFirstEle()
        },500);
    }
    closeModalRespondent(event) {
        this.isModalOpen = false;
        if (this.isEdit) {
            this.dispatchEvent(new CustomEvent('focuseditbutton', {
                detail : {
                   isEdit : this.isEdit,
                   info : 'Subject',
                   index : this.setIndex
                }
            }));
        }
        else{
            var focusOnInitial = this.template.querySelector('.initialButton');
            if(focusOnInitial){
                setTimeout(()=>{
                    focusOnInitial.focus();
                },500);
            }
        }
        this.resetModalDetails();
    }

    checkValidity() {
        this.focus = false;
        this.focusIndex = -1;
        let isAllValid = [...this.template.querySelectorAll('lightning-input,lightning-radio-group,lightning-combobox')].reduce((validSoFar, input) => {
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
        });
        if (!isAllValid) {
            showAsyncErrorMessage(this, 'Please validate all the input fields.')
        }
        return isAllValid;
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

    handleEscKeyDown(event) {
        if (event.code === 'Escape' || event.keyCode === 27) {
            this.closeModalRespondent();
        }
    }

    @api focusOnInitialButton(className){
        var focusOnInitial = this.template.querySelector(`.${className}`);
        console.log('focusOnInitial :>> ', JSON.stringify(focusOnInitial));
            if(focusOnInitial){
                console.log('inn :>> ');
               focusOnInitial.focus();
        }
    }


}