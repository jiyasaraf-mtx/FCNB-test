import { LightningElement,api,track } from 'lwc';
import {
    formatPhoneNumber,
    checkLength
} from 'c/lpiUtil';
import getCurrentLanguage from '@salesforce/apex/EMP_LanguageCtrl.getCurrentLanguage';
import getLabels from '@salesforce/apex/EMP_LanguageCtrl.getLabels';
import {
    LABEL_API_NAMES,
    mapApiToCamel,
    readStoredLanguage,
    writeStoredLanguage
} from 'c/lpLanguageUtils';
export default class LpiPatientComplaintInfo extends LightningElement {
    @api userRole;
    @api sectionName;
    @api isFieldReadOnly = false;
    @api stateOptions;
    @api userId;
    @api resetData = false;

    @track dataObjWrapper={
        complainantAddressData: {}
    };
    @track labels={
        complaintFirstName:'First Name',
        complaintEnterFirstName:'Enter First Name',
        complaintMiddleName:'Middle Name',
        complaintEnterMiddleName:'Enter Middle Name',
        complaintLastName:'Last Name',
        complaintEnterLastName:'Enter Last Name',
        complaintEmailAddress:'Email Address',
        complaintEnterEmailAddress:'Enter Email Address',
        complaintTelephoneNumber:'Telephone Number',
        complaintEnterTelephoneNumber:'Enter Telephone Number',
        complaintCellPhoneNumber:'Cell Phone Number',
        complaintEnterCellPhoneNumber:'Enter Cell Phone Number',
        complaintStreetAddress:'Street Address',
        complaintEnterStreetAddress:'Enter Street Address',
        complaintCityTown:'City / Town',
        complaintEnterCityTown:'Enter City or Town',
        complaintState:'Province',
        complaintSelectState:'Select a Province',
        complaintZipCode:'Postal Code',
        complaintEnterZipCode:'A1A 1A1',
        complaintPatientInformationInstruction:'Please provide the Patient information below.',
        complaintYourInformation:'Your Information'



    }
    @api 
    get inputWrapper() {
        return this.dataObjWrapper;
    }
    set inputWrapper(value) {
        if(value) {
            this.dataObjWrapper = {...value};
        }
    }
    get isPatientInfo() {
        return this.sectionName ==='Patient';
    }
    get isComplainant() {
        return !this.isPatientInfo;
    }
    get setSectionLabel() {
        return this.isPatientInfo ? this.labels.complaintPatientInformationInstruction : this.labels.complaintYourInformation
    }

    connectedCallback() {
        this.initLanguage();
        this.isFieldReadOnly = this.sectionName ==='Patient' ? false : (this.userId ? true : false);

        const sectName = this.sectionName === 'Patient' ? 'Patient Information' : 'Your Information ';

        this.inputWrapper.firstNameAriaLabel = sectName + ' First Name';
        this.inputWrapper.middleNameAriaLabel = sectName + ' Middle Name';
        this.inputWrapper.lastNameAriaLabel = sectName + ' Last Name';
        this.inputWrapper.emailAriaLabel = sectName + ' Email Address';
        this.inputWrapper.telephoneAriaLabel = sectName + ' Telephone Number';
        this.inputWrapper.cellPhoneAriaLabel = sectName + ' Cell Phone Number';
        this.inputWrapper.streetAddressAriaLabel = sectName + ' Street Address';
        this.inputWrapper.cityAriaLabel = sectName + ' City';
        this.inputWrapper.stateAriaLabel = sectName + ' State';
        this.inputWrapper.zipCodeAriaLabel = sectName + ' Zip Code';
        this.inputWrapper.ssnAriaLabel = sectName + ' Social Security Number';
        this.inputWrapper.dobAriaLabel = sectName + ' Date of Birth';

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
    patternObj = {
        text: '^((?!(<)|(>)).)*$',
        digits: '^(\\([0-9]{3}\\) |[0-9]{3}-)[0-9]{3}-[0-9]{4}$',
        email: '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,10}$',
        zipCode: '^[A-Za-z]\\d[A-Za-z][ -]?\\d[A-Za-z]\\d$',
        ssn: '^(?!.*(<|>))[0-9]*$'
    }

    handleElementFocusChange(event) {
        event.currentTarget.setCustomValidity('');
        event.currentTarget.reportValidity();
        let today = new Date();

        if(event.currentTarget.name==='dob' && event.currentTarget.value!==null && new Date(event.currentTarget.value) > today) {
            event.currentTarget.setCustomValidity('Date of Birth can\'t be a Future Date.');
            event.currentTarget.reportValidity();
            return;
        } 
        const isAddress = event.currentTarget.dataset.address;
        this.dispatchEvent(new CustomEvent('focuschange',{
            detail : {
                sectionName : this.sectionName,
                name : event.currentTarget.name,
                value : event.currentTarget.value,
                isAddress : isAddress
            }
        }));
    }
    handleInputChange(event) {
        // this.inputWrapper[event.currentTarget.name] = event.currentTarget.value;
        if(event.currentTarget.name ==='telephone' || event.currentTarget.name ==='telephoneHome' || event.currentTarget.name === 'cellPhone') {
            this.inputWrapper[event.currentTarget.name] = formatPhoneNumber(event.currentTarget.value);
            this.inputWrapper[event.currentTarget.name] = this.inputWrapper[event.currentTarget.name] ? this.inputWrapper[event.currentTarget.name] : event.currentTarget.value;
        }
    }
    @api 
    checkValidity() {
        this.focus = false;
        this.focusIndex = -1;
        let isAllValid = [...this.template.querySelectorAll('lightning-input,lightning-radio-group,lightning-textarea,lightning-combobox')].reduce((validSoFar, input) => {
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
        return isAllValid;
    }



}