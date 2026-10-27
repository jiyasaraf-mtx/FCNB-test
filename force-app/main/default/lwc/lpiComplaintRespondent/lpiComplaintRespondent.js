import { track, LightningElement, wire, api } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import { showAsyncErrorMessage, showMessage, checkLength, formatPhoneNumber, getMergedAddress } from 'c/lpiUtil';
import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';
import CONTACT_OBJECT from '@salesforce/schema/Account';
import ContactState from '@salesforce/schema/Account.PersonOtherStateCode';
import ADDRESS_OBJECT from '@salesforce/schema/Address';
import COUNTRY_CODE_FIELD from '@salesforce/schema/Address.CountryCode';
import getBusinessLicenseDetails from '@salesforce/apex/LPI_ComplaintsController.getBusinessLicenseDetails';
import addNewComplaintParticipant from '@salesforce/apex/LPI_ComplaintParticipantController.addNewComplaintParticipant';
import getAddressDetails from '@salesforce/apex/LPI_AddressUtility.getAddressDetails';
import { CurrentPageReference } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';


export default class IsRespondentLicensed extends LightningElement {
    selectedOption = null;
    showRadio = false;
    isNewRecord = false;
    selectedRecordId;
    @track addressData = {
        streetOne: '',
        city: '',
        state: '',
        zipCode: '',
        country: '',
        county: '',
    };
    showAddressData = false;
    showAddressDetails = false;
    showSpinner = false;
    @track attorneyInfo = {
        'addressData': {}
    }
    @track entitiesData = {
        'addressData': {}
    }
    @api recordId;
    @wire(CurrentPageReference) pageRef;
    @track employerInfo = {
        'employerAddress': {},
    };
    @track selectedRespondentData = {
        'addressData': {}
    };
     @track address={

     };

    @track isUs;
    @track selectedWitnessData = [];
    @track selectedEmployerData = [];

    authTypeOptions = [{
        'label': 'Individual',
        'value': 'Individual'
    }, {
        'label': 'Business',
        'value': 'Business'
    }];

    newOrExisting = [{
        'label': 'Create New Record',
        'value': 'Create New Record'
    }, {
        'label': 'Choose from an Existing Record',
        'value': 'Choose from an Existing Record'
    }];

    @track selectedBusinessIds = [];
    @track witnessData = {
        'addressData': {}
    };
    @track employerData = {
        'addressData': {}
    }
    @track boxClass = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus';
    @track stateOptions;
    @track countrycodeOptions;
    @track isLicensed = true;
    @track dataObj = {
        'licensedUnlicensed': 'Yes',
        'profession': ''
    };
    @track radioValue = 'Yes';
    licensedUnlicensedOptions = [{
        'label': 'Yes',
        'value': 'Yes',
    },
    {
        'label': 'No',
        'value': 'No',
    },
    ];
    employmentStatusOptions = [{
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
        'label': 'Other',
        'value': 'Other'
    }
    ];

    patternObj = {
        text: '^((?!(<)|(>)).)*$',
        digits: '^(\\([0-9]{3}\\) |[0-9]{3}-)[0-9]{3}-[0-9]{4}$',
        email: '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,10}$',
        zipCode: '^[A-Za-z]\\d[A-Za-z][ -]?\\d[A-Za-z]\\d$',
        ssn: '^(?!.*(<|>))[0-9]*$'
    }
    get options() {
        return [
      
            { label: 'Employer', value: 'Employer' },
            { label: 'Other Entity', value: 'Other Entity' },
            { label: 'Witness', value: 'Witness' },
           // { label: 'Attorney', value: 'Attorney' } ,
            {label: 'Attorney - Complainant', value:'Attorney Complainant' },
            {label: 'Attorney - Respondent', value:'Attorney Respondent'},
            {label: 'Attorney - LPI', value:'Attorney LPI'},
            {label:'Attorney - Other', value:'Attorney Other'}

        ];
    }
    get isBusinessProfession() {
        return (this.dataObj && this.dataObj.professionAuthType === 'Business');
    }
   get realRespondent() {
        return this.selectedOption === 'respondent';
    }
    get isRespondent() {
        return this.selectedOption === 'respondent' && this.radioValue === 'No';
    }
  
    // This function handles the change event when the user selects a different option in a dropdown menu.
    handleChange(event) {
        this.selectedOption = event.detail.value;
        this.showRespondentFields = false;
        this.showWitnessFields = false;
        this.showAttorneyFields = false;
        this.showAttorneyLPIFields = false;
        this.showOtherEntityFields = false;
        this.showEmployerFields = false;
        this.addressData = {};
        console.log('this.selectedOption ==='+this.selectedOption);
        //this.removeValidityResp();
        if (this.selectedOption === 'respondent') {
            this.showRespondentFields = true;
            this.dataObj.licensedUnlicensed = this.radioValue;
            this.addressText = 'Respondent Address';
            this.witnessData = {};
            this.attorneyInfo = {};
            this.entitiesData = {};
            this.employerData ={};
            if (this.radioValue === 'Yes') {
                this.isLicensed = true;
            } else { this.isLicensed = false; }
            this.selectedRespondentData = {
                authorizationType: this.dataObj.professionAuthType
            };
        } else if (this.selectedOption === 'Witness') {
            this.showWitnessFields = true;
            this.addressText = 'Witness Address';
            this.selectedRespondentData = {};
            this.attorneyInfo = {};
            this.entitiesData = {};
            this.employerData ={};
           this.isLicensed = false;
            this.addressData.isUs = true;
            this.showAddressData = false;
            this.showAddressDetails = true;
        } else if (this.selectedOption === 'Attorney Complainant'|| this.selectedOption === 'Attorney Respondent'||this.selectedOption === 'Attorney Other')
         {
            this.showAttorneyFields = true;
            this.addressText = 'Attorney Address';
            this.selectedRespondentData = {};
            this.witnessData = {};
            this.entitiesData = {};
            this.employerData ={};
            this.isLicensed = false;
            this.addressData.isUs = true;
            this.showAddressData = false;
            this.showAddressDetails = true;
        }else if (this.selectedOption === 'Attorney LPI') {
            this.showAttorneyLPIFields = true;
           this.addressText = 'Attorney Address';
            this.selectedRespondentData = {};
            this.witnessData = {};
            this.entitiesData = {};
            this.employerData ={};
            this.isLicensed = false;
            this.addressData.isUs = true;
            this.showAddressData = false;
            this.showAddressDetails = true;

        }
        else if (this.selectedOption === 'Other Entity') {
            this.showOtherEntityFields = true;
            this.addressText = 'Entity Address';
            this.selectedRespondentData = {};
            this.witnessData = {};
            this.attorneyInfo = {};
            this.employerData ={};
            this.isLicensed = false;
            this.addressData.isUs = true;
             this.showAddressData = true;
             this.showAddressDetails = false;
             
        }
        else if (this.selectedOption === 'Employer') {
            this.showEmployerFields = true;
            this.addressText = 'Employer Address';
            this.selectedRespondentData = {};
            this.witnessData = {};
            this.attorneyInfo = {};
            this.entitiesData = {};
            this.isLicensed = false;
            this.addressData.isUs = true;
            this.showAddressData = true;
            this.showAddressDetails = false;
        }
    }
    // This function handles the change event when the user selects a different value from a radio button.
    handleLicenseChange(event) {
        this.radioValue = event.target.value;
        if (this.selectedOption === 'respondent' && this.radioValue === 'Yes') {
            this.isLicensed = true;
            this.dataObj.licensedUnlicensed = 'Yes';
            this.selectedRespondentData = {
                authorizationType: this.dataObj.professionAuthType
            };
        } else {
            this.isLicensed = false;
            this.addressData = {};
            this.dataObj.licensedUnlicensed = 'No';
            this.selectedRespondentData = {
                authorizationType: ''
            };
        }
    }
    
    // This function is used to get details about a business license by passing in a search term.
    getBusinessDetails(searchTerm) {
        getBusinessLicenseDetails({
            jsonData: JSON.stringify({
                'entityName': searchTerm,
                'selectedBusinessIds': [],
                'profession': this.dataObj.profession
            })
        }).then(result => {
            if (!result || result.length === 0) {
                showMessage(this, {
                    title: "Warning",
                    message: "No License found.Please update the search criteria.",
                    messageType: "warning",
                    mode: "dismissable"
                });
                this.selectedRespondentData.records = [];
                this.dataObj.records = [];
            } else {
                this.selectedRespondentData.records = result;
                this.dataObj.records = result;
            }
        }).catch(error => {
            this.showSpinner = true;
            showAsyncErrorMessage(this, error);
        }).finally(() => {
            this.showSpinner = true;
        })
    }

    // Function to handle changes in the business license input field.
    handleChangeBusinessLicense(event) {
        if (!event.currentTarget.value) {
            return;
        }
        this.selectedRespondentData.searchTerm = event.currentTarget.value;
        this.showSpinner = false;
        this.getBusinessDetails(event.currentTarget.value);
    }

    // Function to open on click.
    handleClick() {
        this.boxClass = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus slds-is-open';
    }

    // GET CONTACT_OBJECT INFO for state picklist values
    @wire(getObjectInfo, {
        objectApiName: CONTACT_OBJECT
    })
    objectInfo;
    @wire(getPicklistValues, {
        recordTypeId: '$objectInfo.data.defaultRecordTypeId',
        fieldApiName: ContactState,
    })
    wiredPicklistValues({ error, data }) {
        this.showSpinner = true;
        if (data && data.values) {
            this.stateOptions = data.values;
        } else if (error) {
            this.showSpinner = false;
            showAsyncErrorMessage(this, error);
        }
    }

    // GET ADDRESS_OBJECT INFO
    @wire(getObjectInfo, {
        objectApiName: ADDRESS_OBJECT
    })
    objectCountryInfo;
    @wire(getPicklistValues, {
        recordTypeId: '$objectCountryInfo.data.defaultRecordTypeId',
        fieldApiName: COUNTRY_CODE_FIELD,
    })
    countryPicklistValues({ error, data }) {
        this.showSpinner = true;
        if (data && data.values) {
            this.countrycodeOptions = data.values;
        } else if (error) {
            this.showSpinner = false;
            showAsyncErrorMessage(this, error);
        }
    }

    // Function to reset selected respondent data and remove a pill from the pill container.
    handleRemovePill(event) {
        this.selectedRespondentData = {};
        this.addressData = {};
        this.selectedRespondentData.isValueSelected = false;
        this.selectedRespondentData.records = [];
        this.selectedBusinessIds.splice(event.currentTarget.dataset.index, 1);
    }

    // Function to dispatch a closeActionScreenEvent when closing the screen.
    closeAction() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    // Function to handle selection of a business from the drop-down list.
    handeBusinessSelect(event) {
        // Filter records for the selected business ID and update selectedRespondentData properties accordingly.
        this.selectedRespondentData = this.selectedRespondentData.records.filter(resp => event.currentTarget.dataset.id === resp.businessId)[0];
        this.selectedRespondentData.searchTerm = event.target.value;
        this.selectedRespondentData.isValueSelected = true;
        this.addressData = this.selectedRespondentData.addressData ? this.selectedRespondentData.addressData : {};
        this.selectedRespondentData.telephone = this.selectedRespondentData.telephone ? formatPhoneNumber(this.selectedRespondentData.telephone) : this.selectedRespondentData.telephone;
        this.boxClass = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus';
        this.selectedBusinessIds.push(event.currentTarget.dataset.id);
    }
    // This function checks the validity of respondent inputs and returns a boolean value indicating whether all inputs are valid or not.
    checkValidityResp() {
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
            // Return the accumulated validation result so far
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

    // handle country change event
    handleCountryChange(event) {
        this.addressData.country = event.detail.value;
        if (event.detail.value === "US") {
            this.addressData.isUs = true;
            this.isUs = true;
        } else {
            this.addressData.isUs = false;
            this.isUs = false;
        }
    }

    handleAddressChange(event) {
        // handle onchange for all fields
        const { name, value } = event.target;
        this.addressData = { ...this.addressData, [name]: value };
    }
    // This function handles the format of telephone numbers
    handleTelephoneFormat(event) {
        event.currentTarget.setCustomValidity("");
        event.currentTarget.reportValidity("");

        const isEmployerField = event.currentTarget.dataset.employer;
        if (isEmployerField && event.target.name === 'telephone') {
            this.employerInfo[event.currentTarget.name] = formatPhoneNumber(event.currentTarget.value);
            this.employerInfo[event.currentTarget.name] = this.employerInfo[event.currentTarget.name] ? this.employerInfo[event.currentTarget.name] : event.currentTarget.value;
        }
        else if (event.target.name === 'telephone' || event.target.name === 'telephoneHome') {
            this.dataObj[event.currentTarget.name] = formatPhoneNumber(event.currentTarget.value);
            this.dataObj[event.currentTarget.name] = this.dataObj[event.currentTarget.name] ? this.dataObj[event.currentTarget.name] : event.currentTarget.value;
        } else if (event.target.name === 'attorneyPhone') {
            this.attorneyInfo[event.currentTarget.name] = formatPhoneNumber(event.currentTarget.value);
            this.attorneyInfo[event.currentTarget.name] = this.attorneyInfo[event.currentTarget.name] ? this.attorneyInfo[event.currentTarget.name] : event.currentTarget.value;
        }
    }

    handleRespChange(event) {
        const isEmployerField = event.currentTarget.dataset.employer;
        const isAddress = event.currentTarget.dataset.address;
        if (isEmployerField && isAddress) {
            this.employerInfo.employerAddress[event.currentTarget.name] = event.currentTarget.value;
            return;
        } else if (isEmployerField) {
            this.employerInfo[event.currentTarget.name] = event.currentTarget.value;
            this.handleTelephoneFormat(event);
            return;
        } else if (isAddress) {
            this.addressData[event.currentTarget.name] = event.currentTarget.value;
            return;
        }
        // this.dataObj.professionAuthType = this.selectedRespondentData.authorizationType;
        if (event.currentTarget.name === 'licensedUnlicensed') {
            // restoring sNo
            let itemNo;
            if (this.selectedRespondentData.sNoVal) {
                itemNo = this.selectedRespondentData.sNoVal
            }
            // we will be reseting the value with the Corresponding Profession AuthType.
            this.selectedRespondentData = {
                authorizationType: this.dataObj.professionAuthType,
                addressData: {}
            };
            if (itemNo) {
                this.selectedRespondentData.sNoVal = itemNo;
            }
        }
        this.selectedRespondentData[event.currentTarget.name] = event.currentTarget.value;
        this.isLicensed = (this.selectedRespondentData.licensedUnlicensed === 'Yes');
        if (event.target.name === 'telephone') {
            event.currentTarget.setCustomValidity('');
            event.currentTarget.reportValidity('');
            this.selectedRespondentData[event.currentTarget.name] = formatPhoneNumber(event.currentTarget.value);
            this.selectedRespondentData[event.currentTarget.name] = this.selectedRespondentData[event.currentTarget.name] ? this.selectedRespondentData[event.currentTarget.name] : event.currentTarget.value;
        }
    }
    //This function is called when a witness data (such as name, address etc.) is changed or updated.
    handleWitnessData(event) {
       
        const { name, value } = event.target;
        this.witnessData = { ...this.witnessData, [name]: value };
        this.witnessData[event.currentTarget.name] = event.currentTarget.value;

        if (event.target.name === 'telephone') {
            event.currentTarget.setCustomValidity("");
            event.currentTarget.reportValidity("");
            this.witnessData[event.currentTarget.name] = formatPhoneNumber(event.currentTarget.value);
            this.witnessData[event.currentTarget.name] = this.witnessData[event.currentTarget.name] ? this.witnessData[event.currentTarget.name] : event.currentTarget.value;

        }
        if(event.currentTarget.value == 'Create New Record'){
            this.address ={};
            this.addressData ={};
           }
    }
    handleRadioChange(event){
        if(event.currentTarget.value == 'Create New Record'){
            this.address ={};
            this.addressData ={};
            this.address.Name = '';
            this.isNewRecord = true;
           }
          else if(event.currentTarget.value == 'Choose from an Existing Record'){
           this.isNewRecord = false;
     }
    }
    handleEmployerData(event){
     const { name, value } = event.target;
        this.employerData = { ...this.employerData, [name]: value };
        this.employerData[event.currentTarget.name] = event.currentTarget.value;

        if (event.target.name === 'telephone') {
            event.currentTarget.setCustomValidity("");
            event.currentTarget.reportValidity("");
            this.entitiesData[event.currentTarget.name] = formatPhoneNumber(event.currentTarget.value);
            this.entitiesData[event.currentTarget.name] = this.entitiesData[event.currentTarget.name] ? this.entitiesData[event.currentTarget.name] : event.currentTarget.value;

        }
        
       if(event.currentTarget.value == 'Create New Record'){
        this.address ={};
        this.addressData ={};
        this.address.Name  = '';
        this.employerData.entityName = '';
       }
     }
    
    targetObjects = [

        {
              label: 'Account',
              value: 'Account'
          }
      ];
      selectedTarget = 'Account';
      currentSelectedRecordId = null;
  
      get showTargetSelector() {
        return this.currentSelectedRecordId === null;
    }

    filterBusinessAcc = {
        criteria: [{
                fieldPath: 'RecordType.Name',
                operator: 'eq',
                value: 'Business'
        }]
    };
    filterPersonAcc = {
        criteria: [{
                fieldPath: 'RecordType.Name',
                operator: 'eq',
                value: 'Person Account'
        }]
    };
    handleTargetSelection(event) {
        event.stopPropagation();
        this.selectedTarget = event.target.value;
        this.refs.recordPicker.clearSelection();
    }
   
    handleBusinessAccRecord(event) {
        this.currentSelectedRecordId = event.detail.recordId;
      if( this.currentSelectedRecordId != null){
       getAddressDetails({ accountID: this.currentSelectedRecordId  })
            .then(result => {
                this.address = result[0];
                this.addressData.streetOne = result[0].BillingStreet;
                this.addressData.city =  result[0].BillingCity;
                this.addressData.state =  result[0].BillingStateCode;
                this.addressData.zipCode =  result[0].BillingPostalCode;
                this.addressData.country =  result[0].BillingCountryCode;
                this.addressData.county = result[0].County__c;
                this.employerData.entityName =  result[0].Name;
                this.entitiesData.entityName =  result[0].Name;
             })
            .catch(error => { 
                this.error = error;
               
            });

        }

     else  if( this.currentSelectedRecordId == null){
        this.address ={};
        this.addressData ={};
     }       
    }
    handlePersonAccRecord(event) {
        this.currentSelectedRecordId = event.detail.recordId;
        if( this.currentSelectedRecordId != null){
       
       getAddressDetails({ accountID: this.currentSelectedRecordId  })
            .then(result => {
               this.address = result[0];
              this.addressData.streetOne = result[0].PersonOtherStreet;
               this.addressData.city =  result[0].PersonOtherCity;
               this.addressData.state =  result[0].PersonOtherStateCode;
               this.addressData.zipCode =  result[0].PersonOtherPostalCode;
               this.addressData.country =  result[0].PersonOtherCountryCode;
               this.addressData.county = result[0].County__c;
               this.witnessData.firstName =  result[0].FirstName;
               this.witnessData.lastName =  result[0].LastName;
               this.witnessData.middleName =  result[0].MiddleName;
               this.witnessData.email =  result[0].PersonEmail;
               this.witnessData.telephone = result[0].PersonHomePhone;
               this.attorneyInfo.firstName =  result[0].FirstName;
               this.attorneyInfo.middleName =  result[0].MiddleName;
               this.attorneyInfo.lastName =  result[0].LastName;
               this.attorneyInfo.attorneyEmail = result[0].PersonEmail;
               this.attorneyInfo.attorneyPhone = result[0].PersonHomePhone;

            })
            .catch(error => { 
                this.error = error;
               
            });

        }

     else  if( this.currentSelectedRecordId == null){
        this.address ={};
        this.addressData ={};
         }       
    }

    
   
    
   
    targetAtorneyObjects = [

        {
              label: 'Account',
              value: 'Account'
          },
         
      ];
      selectedAttorneyTarget = 'Account';
      currentSelectedAttRecordId = null;
  
   
      filterAttorneyRec = {
        criteria: [{
            fieldPath: 'RecordType.Name',
            operator: 'eq',
            value: 'Person Account'
        },
        {
            fieldPath: 'Is_MO_Attorney__c',
            operator: 'eq',
            value: true
        }
    ],
    filterLogic: '1 AND 2'
    };


    get showAttorneyTargetSelector() {
        return this.currentSelectedAttRecordId === null;
    }
      

    handleTargetAttorneySelection(event) {
        event.stopPropagation();
        this.selectedAttorneyTarget = event.target.value;
        console.log('target--'+this.selectedAttorneyTarget);
        this.refs.recordPicker.clearSelection();
    }
    handleAttorneyRecords(event) {
        this.currentSelectedAttRecordId = event.detail.recordId;
        if( this.currentSelectedAttRecordId != null){
             getAddressDetails({ accountID: this.currentSelectedAttRecordId  })
            .then(result => {
               this.address = result[0];
              this.addressData.streetOne = result[0].PersonOtherStreet;
               this.addressData.city =  result[0].PersonOtherCity;
               this.addressData.state =  result[0].PersonOtherStateCode;
               this.addressData.zipCode =  result[0].PersonOtherPostalCode;
               this.addressData.country =  result[0].PersonOtherCountryCode;
               this.addressData.county = result[0].County__c;
               this.witnessData.telephone = result[0].PersonHomePhone;
               this.attorneyInfo.firstName =  result[0].FirstName;
               this.attorneyInfo.middleName =  result[0].MiddleName;
               this.attorneyInfo.lastName =  result[0].LastName;
               this.attorneyInfo.attorneyEmail = result[0].PersonEmail;
               this.attorneyInfo.attorneyPhone = result[0].PersonHomePhone;

            })
            .catch(error => { 
                this.error = error;
               
            });
           
      

        }

        else  if( this.currentSelectedAttRecordId == null){
        this.address ={};
        this.addressData ={};
         }       
    }
   
  

    handleInputChange(event) {
        const isAddressField = event.currentTarget.dataset.address;
        const isAttorneyField = event.currentTarget.dataset.attorney;
        if (isAttorneyField && isAddressField) {
            this.attorneyInfo.addressData[event.currentTarget.name] = event.currentTarget.value;
            return;
        } else if (isAttorneyField) {
            this.attorneyInfo[event.currentTarget.name] = event.currentTarget.value;
            this.handleTelephoneFormat(event);
            return;
        } else if (isAddressField) {
            this.dataObj.complainantAddressData[event.currentTarget.name] = event.currentTarget.value;
            return;
        }
        if(event.currentTarget.value == 'Create New Record'){
            this.address ={};
            this.addressData ={};
        }
        this.dataObj[event.currentTarget.name] = event.currentTarget.value;

        this.isLicensed = (this.dataObj.licensedUnlicensed === 'Yes');
        if (event.currentTarget.name === 'licensedUnlicensed') {
            this.selectedRespondentData = {
                'addressData': {}
            };
        }
        if (event.currentTarget.type == 'checkbox') {
            this.dataObj[event.currentTarget.name] = event.currentTarget.checked;
        }
        if (this.dataObj.incidentDate) {
            event.currentTarget.setCustomValidity('Incident Date Cant be a Future Date');
        }
        this.handleTelephoneFormat(event);
    }

    handleOtherEntityChange(event) {
        
        
        const { name, value } = event.target;
        this.entitiesData = { ...this.entitiesData, [name]: value };
        this.entitiesData[event.currentTarget.name] = event.currentTarget.value;
        if (event.target.name === 'telephone') {
            event.currentTarget.setCustomValidity("");
            event.currentTarget.reportValidity("");
            this.entitiesData[event.currentTarget.name] = formatPhoneNumber(event.currentTarget.value);
            this.entitiesData[event.currentTarget.name] = this.entitiesData[event.currentTarget.name] ? this.entitiesData[event.currentTarget.name] : event.currentTarget.value;

        }
        if(event.currentTarget.value == 'Create New Record'){
            this.address ={};
            this.addressData ={};
           }
    }

    handleSave() {
        const isAllValid = this.checkValidityResp();
        if (!isAllValid) {
            const event = new ShowToastEvent({
                title: 'Error!',
                message: 'Please validate all the input fields.',
                variant: 'error'
            });
            this.dispatchEvent(event);
            return;
        }
        this.sectionName = this.selectedOption;
        if (this.selectedOption === 'respondent') {
            this.dataObj.licensedUnlicensed = this.radioValue;
            if (this.addressData.country === 'US') {
                delete this.addressData.otherState;
            } else {
                this.addressData.otherState = this.addressData.state;
                delete this.addressData.state;
            }
            this.selectedRespondentData.authorizationType = this.dataObj.authType;
            this.selectedRespondentData.addressValue = getMergedAddress(this.addressData);
            this.selectedRespondentData.addressData = this.addressData;
            const respondentData = this.selectedRespondentData;
            this.dataObj.respondentData = [respondentData];
            if (this.dataObj.licensedUnlicensed === 'No' && this.dataObj.authType === 'Individual') {
                respondentData.employerInfo = this.employerInfo;
            }
            if (this.dataObj.licensedUnlicensed === 'Yes') {
                this.dataObj.licensedUnlicensed = 'Complaint against a Licensed Individual/Facility';
            } else if (this.dataObj.licensedUnlicensed === 'No') {
                this.dataObj.licensedUnlicensed = 'Complaint against a Unlicensed Individual/Facility';
            }
            respondentData.licensedUnlicensed = this.dataObj.licensedUnlicensed;
            if (respondentData.records) {
                delete respondentData.records;
            }
            if (this.dataObj.records) {
                delete this.dataObj.records;
            }

        } else if (this.selectedOption === 'Witness') {
          
            this.witnessData.telephone = this.witnessData.telephone ? this.witnessData.telephone.replace(/[^\d]/g, "") : this.witnessData.telephone;
            this.dataObj.witnessData = [this.witnessData];
            this.dataObj.witnessData[0].addressData = this.addressData;


        }else if (this.selectedOption === 'Attorney' ||this.selectedOption === 'Attorney Complainant'|| this.selectedOption === 'Attorney Respondent'|| this.selectedOption === 'Attorney LPI'||this.selectedOption === 'Attorney Other'){
       
            this.attorneyInfo.attorneyPhone = this.attorneyInfo.attorneyPhone ? this.attorneyInfo.attorneyPhone.replace(/[^\d]/g, "") : this.attorneyInfo.attorneyPhone;
            this.dataObj.attorneyInfo = [this.attorneyInfo];
            this.dataObj.attorneyInfo[0].addressData = this.addressData;

        } else if (this.selectedOption === 'Other Entity') {
            this.entitiesData.telephone = this.entitiesData.telephone ? this.entitiesData.telephone.replace(/[^\d]/g, "") : this.entitiesData.telephone;
            this.dataObj.entitiesData = [this.entitiesData];
            this.dataObj.entitiesData[0].addressData = this.addressData;

        }else if (this.selectedOption === 'Employer') {
           this.dataObj.employerData = [this.employerData];
          this.dataObj.employerData[0].addressData = this.addressData;
       }

       console.log('data---'+JSON.stringify(this.dataObj));
       console.log('recordId--'+this.recordId );
       console.log('sectionName---'+ this.sectionName);

         this.showSpinner = true;
        let params = { jsonData: JSON.stringify(this.dataObj), caseId: this.recordId, sectionName: this.sectionName };
         addNewComplaintParticipant(params)
            .then(result => {
                this.dispatchEvent(new CloseActionScreenEvent());
                console.log('resultId---'+JSON.stringify(result));
                if (result === 'Success') {
                    const event = new ShowToastEvent({
                        title: 'Success!',
                        message: 'Record has been added successfully',
                        variant: 'success',
                    });
                    this.dispatchEvent(event);
                } else if (result === 'Error') {
                    const event = new ShowToastEvent({
                        title: 'Error!',
                        message: 'Failed to save record.',
                        variant: 'error',
                    });
                    this.dispatchEvent(event);
                }
            })
            .catch(error => {
                const event = new ShowToastEvent({
                    title: 'Error!',
                    message: error.body.message,
                    variant: 'error',
                });
                this.dispatchEvent(event);
            }).finally(this.showSpinner = false);
    }
}