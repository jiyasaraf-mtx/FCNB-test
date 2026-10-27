import { LightningElement, wire, track, api } from 'lwc';
import {
    formatPhoneNumber,
    showAsyncErrorMessage,
    showMessage,
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

export default class LpiComplaintAttorneyDetails extends LightningElement {
    @track attorneyInfo = {
        addressData: {}
    }
    @track isModalOpen = false;
    @api stateOptions;
    @api patternObj;
    isEdit = false;
    setIndex = -1;
    focusedElement;

    @track labels = {
        complaintAddAttorney:'Add Attorney',
        complaintAddEditAttorney:'Add/Edit Attorney',
        complaintAsterisk:'Asterisk',
        complaintAsteriskRequiredField:'indicates required field',
        complaintPleaseType:'Please type',
        complaintUnknown:'Unknown',
        complaintRequiredFieldsUnknown:'for required fields if you do not know the details.',
        complaintAttorneyFirstName:'Attorney First Name',
        complaintEnterAttorneyFirstName:'Enter Attorney First Name',
        complaintAttorneyFirstNameRequiredError:'Error: First Name is required.',
        complaintAttorneyMiddleName:'Attorney Middle Name',
        complaintEnterAttorneyMiddleName:'Enter Attorney Middle Name',
        complaintAttorneyLastName:'Attorney Last Name',
        complaintEnterAttorneyLastName:'Enter Attorney Last Name',
        complaintLastNameRequiredError:'Error: Last Name is required.',
        complaintAttorneyAddress:'Attorney Address',
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
        complaintEnterZipCode:'A1A 1A1',
        complaintZipCodeRequiredError:'Error: Zip Code is required.',
        complaintZipCodePatternError:'Please enter a valid Canadian Postal Code (e.g. A1A 1A1).',
        complaintAttorneyPhone:'Attorney Phone',
        complaintEnterAttorneyPhone:'Enter Attorney Phone',
        complaintEntryDoesNotMatchPattern:'Your Entry does not match the pattern',
        complaintPhoneNumberRequiredError:'Error: Phone Number is required.',
        complaintAttorneyEmail:'Attorney Email',
        complaintEnterAttorneyEmail:'Enter Attorney Email',
        complaintEmailRequiredError:'Error: Email is required.',
        complaintComments:'Comments',
        complaintEnterComments:'Enter Comments',
        complaintCancel:'Cancel',
        complaintSave:'Save',


        








    }

    connectedCallback(){

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

    handleAttorneyModalToggle(event) {
        if (!this.isModalOpen) {
            // Store the currently focused element before opening the modal
            this.focusedElement = this.template.activeElement;
        }
        if (this.isModalOpen == true) {
            this.dispatchEvent(new CustomEvent('focuseditbutton', {
                detail: {
                    isEdit: this.isEdit,
                    info: 'Attorney',
                    index: this.setIndex
                }
            }));
        }
        else {
            setTimeout(() => {
                this.focusFirstEle();
            }, 500);
        }
        this.isModalOpen = !this.isModalOpen;
        if (!this.isModalOpen && this.focusedElement) {
            // Set focus back to the initiating element after closing the modal
            this.focusedElement.focus();
        }
        if (!this.isModalOpen) {
            this.resetAttorneyDetails();
        }
    }

    resetAttorneyDetails() {
        this.attorneyInfo = {
            addressData: {}
        }
        this.isEdit = false;
        this.setIndex = -1;
    }

    handleEscKeyDown(event) {
        if (event.code === 'Escape' || event.keyCode === 27) {
            this.handleAttorneyModalToggle();
        }
    }

    @api
    setDataForEdit(recordToEdit, index) {
        this.attorneyInfo = { ...recordToEdit };
        this.isEdit = true;
        this.isModalOpen = true;
        setTimeout(() => {
            this.focusFirstEle();
        }, 500);
        this.setIndex = index;
    }

    saveAttorneyDetails(event) {
        if (this.checkValidity()) {
            let combinedName = this.attorneyInfo.middleName ?
                this.attorneyInfo.firstName + ' ' + this.attorneyInfo.middleName + ' ' + this.attorneyInfo.lastName :
                (this.attorneyInfo.firstName || '') + ' ' + (this.attorneyInfo.lastName || '');
            let newCombinedName = 'Actions button for ' + combinedName;
            let editName = 'Edit button for ' + combinedName;
            let deletName = 'Delete button for ' + combinedName;

            // Send This Attorney Detail to parent.
            this.dispatchEvent(new CustomEvent('save', {
                detail: {
                    attorneyInfo: {
                        ...this.attorneyInfo,
                        combinedName: combinedName,
                        newCombinedName: newCombinedName,
                        editName: editName,
                        deletName: deletName
                    },
                    isEdit: this.isEdit,
                    index: this.setIndex
                }
            }));

            showMessage(this, {
                title: "Success",
                message: `Attorney ${this.isEdit ? 'Updated' : 'Added'} Successfully.`,
                messageType: "success",
                mode: "dismissable"
            });

            this.handleAttorneyModalToggle();
        }
    }

    handleInputChange(event) {
        let isAddress = event.currentTarget.dataset.address;

        if (isAddress) {
            this.attorneyInfo.addressData[event.currentTarget.name] = event.currentTarget.value;
        } else {
            this.attorneyInfo[event.currentTarget.name] = event.currentTarget.value;
        }
        this.handleTelephoneFormat(event);
    }

    handleTelephoneFormat(event) {
        event.currentTarget.setCustomValidity("");
        event.currentTarget.reportValidity();

        if (event.target.name === 'attorneyPhone') {
            this.attorneyInfo[event.currentTarget.name] = formatPhoneNumber(event.currentTarget.value);
            this.attorneyInfo[event.currentTarget.name] = this.attorneyInfo[event.currentTarget.name] ? this.attorneyInfo[event.currentTarget.name] : event.currentTarget.value;
        }
    }

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
        this.template.querySelectorAll('.attorneyPhone').forEach(input => {
            if (input.value && !input.value.match(regex)) {
                isAllValid = false;
                input.setCustomValidity("Please enter a valid telephone number.");
                input.reportValidity();
            }
        });

        return isAllValid;
    }

    // Focus Leak Accessibility Issue 
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
    @api focusOnInitialButton(className) {
        var focusOnInitial = this.template.querySelector(`.${className}`);
        if (focusOnInitial) {
            focusOnInitial.focus();
        }
    }
}