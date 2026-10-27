import { LightningElement, track, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import saveInstitutionAccount from '@salesforce/apex/LPI_DashbaordTableCtrl.saveInstitutionAccount';
import { getPicklistValues, getObjectInfo } from "lightning/uiObjectInfoApi";
import AddressState from '@salesforce/schema/Address.StateCode';
import AddressCountry from '@salesforce/schema/Address.CountryCode';
import ADDRESS_OBJECT from '@salesforce/schema/Address';
import getCurrentLanguage from '@salesforce/apex/EMP_LanguageCtrl.getCurrentLanguage';
import getLabels from '@salesforce/apex/EMP_LanguageCtrl.getLabels';
import {
    LABEL_API_NAMES,
    mapApiToCamel,
    readStoredLanguage,
    writeStoredLanguage
} from 'c/lpLanguageUtils';

export default class LpiInstituteProfile extends LightningElement {
    @track labels = {
        createInstitutionProfile: 'Create Institution Profile'
    };
    showSpinner = false;
    @track isModalOpen = false;
    @track accountWrapper = {
        'accountName': '',
        'accountPhone': '',
        'accountEmail': '',
        'accountWebsite': '',
        'accountFax': '',
        'addressStreetData': {},
        'addressData': {}
    };
    @track countryOptions = [];
    @track stateOptions = [];
    patternObj = {
        text: '^((?!(<)|(>)).)*$',
        digits: '^(\\([0-9]{3}\\) |[0-9]{3}-)[0-9]{3}-[0-9]{4}$',
        email: '^([A-Za-z0-9_\-\.\+]+)@([A-Za-z0-9_\-\.]+)\.([A-Za-z]{2,10})$',
        zipCode: '^[0-9]{5}(?:-[0-9]{4})?$',
        zipCodeUS: '^[0-9]{5}?$',
        zipCodeNonUS: '^[a-zA-Z0-9]*$',
        ssn: '^(?!.*(<|>))[0-9]*$',
        phone: '[0-9]*',
        name: '^[A-Za-z0-9 ]+$',
        dob: '^[A-Za-z0-9 ]+$'
    }
    @wire(getObjectInfo, {
        objectApiName: ADDRESS_OBJECT
    }) objectInfo;
    objectInfo;

    @wire(getPicklistValues, {
        recordTypeId: '$objectInfo.data.defaultRecordTypeId',
        fieldApiName: AddressState
    }) wiredStatePicklistValues({
        error,
        data
    }) {
        if (data && data.values) {
            this.stateOptions = data.values;
        }
    }
    @wire(getPicklistValues, {
        recordTypeId: '$objectInfo.data.defaultRecordTypeId',
        fieldApiName: AddressCountry
    })
    wiredCountryPicklistValues({
        error,
        data
    }) {
        if (data && data.values) {
            this.countryOptions = data.values;
        }
    }
    get isMailingAddressUS() {
        let temp =
            this.accountWrapper.addressData &&
                this.accountWrapper.addressData.country &&
                this.accountWrapper.addressData.country === "US" ?
                true :
                false;
        if (!temp) {
            this.accountWrapper.addressData.state = null;
        }
        return temp;
    }
    connectedCallback() {
        this.clearFields();
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
        } catch (e) {
            // keep defaults
        }
    }


    // Open modal
    openModal() {
        this.isModalOpen = true;
        setTimeout(() => {
			this.focusFirstEle();
		}, 200);
    }

    // Close modal
    closeModal() {
        this.isModalOpen = false;
    }
    handleAuthInputs(event) {
        let value = event.target.value;
        let name = event.target.name;
        this.accountWrapper[name] = value
    }
    handleAddressChange(event) {
        console.log('event.target.name :>> ', event.target.name);
        console.log('event.target.value :>> ', event.detail);
        if (event.target.name === "Street-address") {
            let addressDetail = event.detail;
            this.accountWrapper.addressStreetData["city"] = addressDetail.city;
            this.accountWrapper.addressStreetData["state"] = addressDetail.province;
            this.accountWrapper.addressStreetData["street"] = addressDetail.street;
            this.accountWrapper.addressStreetData["country"] = addressDetail.country;
            this.accountWrapper.addressStreetData["zip"] = addressDetail.postalCode;
        }
        else if (event.target.name === "Mailing-address") {
            let addressDetail = event.detail;
            this.accountWrapper.addressData["city"] = addressDetail.city;
            this.accountWrapper.addressData["state"] = addressDetail.province;
            this.accountWrapper.addressData["street"] = addressDetail.street;
            this.accountWrapper.addressData["country"] = addressDetail.country;
            this.accountWrapper.addressData["zip"] = addressDetail.postalCode;
        }
    }

    // Handle input changes
    handleInputChange(event) {
        let value = event.target.value;
        let name = event.target.name;
        if (event.target.name.split(".").length > 1) {
            this.accountWrapper[event.target.name.split(".")[0]][event.target.name.split(".")[1]] =
                event.target.value.trim();
        } else {
            this.accountWrapper[event.target.name.split(".")[0]] = event.target.value.trim();
        }

        if (
            event.target.name === "addressData.country" &&
            this.accountWrapper.addressData.country === "US"
        ) {
            this.accountWrapper.addressData.stateText = null;
            this.accountWrapper.addressData.state = "MO";
        } else if (event.target.name === "addressData.country") {
            this.accountWrapper.addressData.state = null;
        }
    }

    // Save Account details using a wrapper class
    saveAccount() {
        this.showSpinner = true;
        console.log('accountWrapper :>> ', JSON.stringify(this.accountWrapper));
        saveInstitutionAccount({ wrapper: JSON.stringify(this.accountWrapper) })
            .then(() => {
                this.showToast('Success', 'Account created successfully!', 'success');
                this.closeModal();
                this.clearFields();
                this.showSpinner = false;
            })
            .catch(error => {
                this.showSpinner = false;
                this.showToast('Error', 'Error creating account: ' + error.body.message, 'error');
            });
    }

    // Clear the input fields
    clearFields() {
        this.accountWrapper = {
            'accountName': '',
            'accountPhone': '',
            'accountEmail': '',
            'accountWebsite': '',
            'accountFax': '',
            'addressStreetData': {},
            'addressData': {}
        }
    }

    // Show toast message
    showToast(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(evt);
    }

    focusFirstEle() {
		const focusableElements = 'lightning-combobox, lightning-button-icon, button, lightning-helptext, lightning-input, lightning-button';
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