import { LightningElement, api, wire, track } from 'lwc';
import {
    showAsyncErrorMessage,
    formatPhoneNumber,
    checkLength,
    getMergedAddress
} from 'c/lpiUtil';
import {
    getPicklistValues,
    getObjectInfo
} from 'lightning/uiObjectInfoApi';
import ACCOUNT_OBJECT from '@salesforce/schema/Account';
import ContactState from '@salesforce/schema/Account.PersonOtherStateCode';
import getCurrentLanguage from '@salesforce/apex/EMP_LanguageCtrl.getCurrentLanguage';
import getLabels from '@salesforce/apex/EMP_LanguageCtrl.getLabels';
import {
    LABEL_API_NAMES,
    mapApiToCamel,
    readStoredLanguage,
    writeStoredLanguage
} from 'c/lpLanguageUtils';

export default class LpiFileCompliantAccordion extends LightningElement {

    @api userId;
    @api sectionName;
    @api isEntity = false;
    @api isLocation = false;
    @api fromIncident;

    @api
    set getBackMyFocus(value) {
        if(value) {
            setTimeout(()=>
                this.focusAddLocation()
            ,500);
        }
    }
    get getBackMyFocus() {
        return;
    }
    @api disableButton = false;
    @api patternObj;
    // individualOrBusinessAcc = false;
    isModalOpen = false;
    isUpdate = false;
    selectedIdxToUpdate=0;
    focus;
    focusIndex;

    @track record = {
        'addressData': {}
    };

    // Track the initiated element
    initiatedElement;

    entitySectionConfig = {
        // 'sectionName':'Other Entities',
        'uniqueName': 'Entity',
        'modalName': 'Add/Edit Other Entities'
    };

    incidentLocSectionConfig = {
        // 'sectionName':'Incident Location',
        'uniqueName': 'Location',
        'modalName': 'Add/Edit Incident Location'
    };

    get nameFieldLabel() {
        return this.labels.complaintEntityName;
    }
    get phoneFieldLabel() {
        return this.labels.complaintEntity + ' '+this.labels.complaintTelephoneNumber;
    }
    get emailFieldLabel() {
        return this.labels.complaintEntity + ' '+this.labels.complaintEmailAddress;
    }
    get modalCloseAriaLabel() {
        return 'Close '+this.displayConfig.modalName + ' Modal';
    }
    get buttonLabel() {
        return (!this.fromIncident? this.labels.complaintAddOtherEntities: this.labels.complaintAddIncidentLocation);
    }
    @track labels={
        complaintAddOtherEntities:'Add Other Entities',
        complaintAddIncidentLocation:'Add Incident Location',
        complaintAddEditOtherEntities:'Add/Edit Other Entities',
        complaintAsterisk:'Asterisk',
        complaintAsteriskRequiredField:'indicates required field',
        complaintPleaseType:'Please type',
        complaintUnknown:'Unknown',
        complaintRequiredFieldsUnknown:'for required fields if you do not know the details.',
        complaintEntityName:'Entity Name',
        complaintEnterEntityName:'Enter Entity Name',
        complaintEntityNameRequiredError:'Error: Entity Name is required.',
        complaintEntityRepresentativeContacted:'Entity Representative Contacted',
        complaintEnterEntityRepresentativeContacted:'Enter Entity Representative Contacted',
        complaintEntityRepresentativeRequiredError:'Entity Representative is Required Field',
        complaintEntity:'Entity',
        complaintStreetAddress:'Street Address',
        complaintEnterStreetAddress:'Enter Street Address',
        complaintStreetAddressRequiredError:'Error: Street Address is required.',
        complaintCityTown:'City / Town',
        complaintEnterCityTown:'Enter City or Town',
        complaintCityRequiredError:'Error: City is required.',
        complaintState:'State',
        complaintSelectState:'Select a State',
        complaintStateRequiredError:'Error: State is required.',
        complaintZipCode:'Zip Code',
        complaintEnterZipCode:'Enter Zip Code',
        complaintZipCodeRequiredError:'Error: Zip Code is required.',
        complaintZipCodePatternError:'Zip Code should be five digits(XXXXX) or five digits + dash + 4 digits(XXXXX-XXXX).',
        complaintTelephoneNumber:'Telephone Number',
        complaintEnterTelephoneNumber:'Enter Telephone Number',
        complaintTelephoneNumberRequiredError:'Error: Telephone Number is required.',
        complaintEntryDoesNotMatchPattern:'Your Entry does not match the pattern',
        complaintEmailAddress:'Email Address',
        complaintEnterEmailAddress:'Enter Email Address',
        complaintCancel:'Cancel',
        complaintSave:'Save',
        
    }
    connectedCallback() {
        this.processData();
         this.initLanguage();
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

    processData() {
        if(this.isEntity) {
            this.displayConfig = {...this.entitySectionConfig};
            this.record.individualOrBusiness = 'Business'; //this.record.individualOrBusiness || 'Individual';
        } else if(this.isLocation){
            this.displayConfig = {...this.incidentLocSectionConfig};
        }
    }

    @api 
    recordToEdit(recordToEdit, selectedSectionName, idx) {
        if(!recordToEdit) return;

        this.record = {...recordToEdit};
        this.isUpdate = true;
        this.selectedIdxToUpdate = idx;
        this.isEntity = selectedSectionName==='Other Entities';
        this.isLocation = selectedSectionName==='Location';
        this.sectionName = selectedSectionName;
        this.processData();

        this.modalToggleController();
    }

    @wire(getObjectInfo, {
        objectApiName: ACCOUNT_OBJECT
    })
    objectInfo;

    @wire(getPicklistValues, {
        recordTypeId: '$objectInfo.data.defaultRecordTypeId',
        fieldApiName: ContactState
    })
    wiredPicklistValues({
        error,
        data
    }) {
        this.showSpinner = true;
        if (data && data.values) {
            this.stateOptions = data.values;
        } else if (error) {
            this.showSpinner = false;
            showAsyncErrorMessage(this, error);
        }
    }

    getMyFocus = false;
    modalToggleController(event) {
        if(event) {
            this.isEntity = (event.target.label === 'Add Other Entities');
            this.isLocation = (event.target.label === 'Add Incident Location');

            this.sectionName = this.isEntity ? 'Other Entities' : 'Location';
        }

        // Track the initiated element
        this.initiatedElement = event ? event.target : null;

        this.processData();
        this.isModalOpen = true;
        setTimeout(() => {
            this.focusFirstEle(this, null);
        }, 500);
    }

    handleModalClose() {
        this.isModalOpen = false;
        if (this.isUpdate) {
            this.dispatchEvent(new CustomEvent('focuseditbutton', {
                detail : {
                   isEdit : this.isUpdate,
                   info : this.sectionName,
                   index : this.selectedIdxToUpdate
                }
            }));   
        }
        else{
            var focusOnInitial = this.template.querySelector('.buttonFocusClass');
            if(focusOnInitial){
                setTimeout(()=>{
                    focusOnInitial.focus();
                },500);
            }
        }
        // setTimeout(() => {
        //     if (this.initiatedElement) {
        //         this.initiatedElement.focus(); // Set focus back to the initiated element
        //     }
        // }, 500);
        this.resetData();
        this.getMyFocus = false;

        
    }

    handleInputChange(event) {
        if(event.currentTarget.dataset.address) {
            this.record.addressData[event.currentTarget.name] = event.currentTarget.value;
            return;
        }
        this.record[event.currentTarget.name] = event.currentTarget.value;

        if (event.target.name === 'telephone' || event.target.name === 'telephoneHome') {
            event.currentTarget.setCustomValidity("");
            event.currentTarget.reportValidity("");
            this.record[event.currentTarget.name] = formatPhoneNumber(event.currentTarget.value);
            this.record[event.currentTarget.name] = this.record[event.currentTarget.name] ? this.record[event.currentTarget.name] : event.currentTarget.value;
        }
    }

    saveModalDetails() {   
        if(this.checkValidity()) {
            this.dispatchEvent(new CustomEvent('save', {
                detail: {
                    data: this.record,
                    otherInfo: {
                        sectionName: this.sectionName,
                        isUpdate: this.isUpdate,
                        updateIdx: this.selectedIdxToUpdate
                    }
                }
            }));
            this.handleModalClose();
            // this.isModalOpen = false;
            // this.resetData();
            // this.getMyFocus = false;
        }
    }

    resetData() {
        this.record = {
            'addressData': {}
        };
        this.isUpdate = false;
    }

    checkValidity() {
        this.focus = false;
        this.focusIndex = -1;
        let isAllValid = [...this.template.querySelectorAll('lightning-input, lightning-radio-group, lightning-textarea, lightning-combobox')].reduce((validSoFar, input) => {
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
            showAsyncErrorMessage(this, 'Please validate all the input fields.');
        }
        return isAllValid;
    }

    handleTabPress(event) {
        this.getMyFocus = false;
        this.template.querySelector('.getFocusHere').focus();
    }

    focusFirstEle(component, element) {
        const focusableElements = 'lightning-combobox, lightning-button-icon, button, lightning-helptext, lightning-input, lightning-button, lightning-radio-group';
        const modal = component.template.querySelector('.slds-modal');
        
        const firstFocusableElement = modal.querySelectorAll(focusableElements)[0];
        const focusableContent = modal.querySelectorAll(focusableElements);
        const lastFocusableElement = focusableContent[focusableContent.length - 1];
        if(element) {
            const focusableElement = modal.querySelectorAll(focusableElements)[element];
            focusableElement.focus();
        } else {
            firstFocusableElement.focus();
        }
        component.template.addEventListener('keydown', function(event) {
            let isTabPressed = event.key === 'Tab' || event.keyCode === 9;
            if (!isTabPressed) {
                return;
            }
            if (event.shiftKey) {       
                if (component.template.activeElement === firstFocusableElement) {
                    lastFocusableElement.focus(); 
                    event.stopPropagation();
                    event.preventDefault();
                }
            } else { 
                if (component.template.activeElement === lastFocusableElement) {  
                    firstFocusableElement.focus(); 
                    event.preventDefault();
                    event.stopPropagation();
                }
            }
        });
    }

    @api
    focusAddLocation() {
        if(this.displayConfig.uniqueName) {
            this.template.querySelector(`[data-id="${this.displayConfig.uniqueName}"]`).focus();
        }
    }
    
    handleFocusBackToModal(event) {
        if(event.code ==='Tab' || event.keyCode === 9) {
            this.getMyFocus = true;
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