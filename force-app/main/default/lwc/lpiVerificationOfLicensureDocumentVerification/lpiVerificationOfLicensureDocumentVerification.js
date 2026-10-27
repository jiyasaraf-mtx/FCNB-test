import { LightningElement, track, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getAdobeDocumentLink from '@salesforce/apex/LPI_ApplicationViewController.getAdobeDocumentLink';
import fetchIaVerificationData from '@salesforce/apex/LPI_ApplicationViewController.fetchIaVerificationData';
import updateIaVerificationData from '@salesforce/apex/LPI_ApplicationViewController.updateIaVerificationData';

// Static Constants Declaration
const ADOBE_MDT_NAME = 'adobePdfMtdName';

export default class LpiVerificationOfLicensureDocumentVerification extends NavigationMixin(LightningElement) {
    @api applicationId;
    @api licensureVerificationButtonJSON;
    @track requestData = {};
    @track institutionRec = {};
    showSpinner = false;
    showDisabledFields = false;
    @track requestTypeOptions = [];

    connectedCallback() {
        this.showSpinner = true;
        fetchIaVerificationData({ recordId: this.applicationId })
            .then((result) => {
                if (result) {
                    this.requestData = JSON.parse(JSON.stringify(result));
                    if (this.requestData.institutionId) {
                        this.template.querySelector("c-custom-look-up").handleSelectedRecordFromParent(this.requestData.institutionId);
                    }
                    this.requestTypeOptions = result.requestTypePicklistDataList;
                }
            })
            .catch((error) => {
                this.showMessage('Error', 'Something went wrong!', 'error' + error);
            })
            .finally(() => {
                this.showSpinner = false;
            })
    }

    // main mentod for document genration and updating the input data on the IA record
    handleLicensureVerificationGenerate() {
        // save the details and then call getAdobeDocumentLink
        this.showSpinner = true;
        let inputFields = this.template.querySelectorAll("c-custom-look-up");
        let result = true;
        inputFields.forEach((inputField) => {
            if (!inputField.checkValidation()) {
                result = false;
            }
        });
        result = this.checkValidation() && result;
        if (!result) {
            this.showSpinner = false;
            this.showMessage("Error", 'Please validate all the input fields.', "error");
        } else {
            this.requestData.applicationId = this.applicationId;
            // this.showDisabledFields = false;
            // this.institutionRec = {};

            updateIaVerificationData({ verificationData: JSON.stringify(this.requestData) })
                .then(() => {
                    getAdobeDocumentLink({ recordId: this.applicationId, mdtName: this.licensureVerificationButtonJSON[ADOBE_MDT_NAME] })
                        .then((docResult) => {
                            if (docResult !== null && docResult !== "") {
                                let redirectionUrl = this.convertBase64ToURL(docResult);
                                this[NavigationMixin.Navigate]({
                                    type: 'standard__webPage',
                                    attributes: {
                                        url: redirectionUrl
                                    }
                                });
                            } else {
                                this.showMessage('Error', 'Something went wrong!', 'error');
                            }
                        })
                        .catch((error) => {
                            this.showMessage('Error', 'Something went wrong!', 'error' + error);
                        })
                        .finally(() => {
                            this.showSpinner = false;
                            this.closeModalEvent();
                        });
                })
                .catch((error) => {
                    this.showSpinner = false;
                    this.showMessage('Error', JSON.stringify(error), 'error');
                });


        }
    }

    // for closing the License verification modal and setting the input data blank
    closeLicensureVerificationModal() {
        this.closeModalEvent();
        this.institutionRec = {};
        this.requestData = {};
    }

    // for validating the input fields
    checkValidation() {
        let valid = false;
        valid = [...this.template.querySelectorAll('lightning-input,lightning-combobox')].reduce(
            (validSoFar, input) => {
                input.reportValidity();
                return validSoFar && input.checkValidity();
            },
            true
        );
        return valid;
    }

    // for handling the input fields change
    handleChange(event) {
        if (event.target.type === "checkbox") {
            this.requestData[event.currentTarget.name] = event.target.checked;
        } else {
            this.requestData[event.target.name] = event.detail.value;
        }
    }

    lookupRecord(event) {
        if (!event.detail || !event.target) {
            return;
        }
        if (event.detail.selectedRecord != null && event.detail.selectedRecord.Id) {
            this.requestData[event.target.name] = event.detail.selectedRecord.Id;
            this.institutionRec = event.detail.selectedRecord;
            this.showDisabledFields = true;
        }
    }

    // event to close the License Verification modal
    closeModalEvent() {
        const closeEvent = new CustomEvent('closemodal');
        this.dispatchEvent(closeEvent);
    }

    // for handling the removel of Institute from the custom typeahead
    handleRemoveInstitution() {
        this.institutionRec = {};
        this.showDisabledFields = false;
    }

    convertBase64ToURL(base64String) {
        // Convert the Base64 string to a Blob
        const byteCharacters = atob(base64String);
        const byteNumbers = new Array(byteCharacters.length);
        for (let i = 0; i < byteCharacters.length; i++) {
            byteNumbers[i] = byteCharacters.charCodeAt(i);
        }
        const byteArray = new Uint8Array(byteNumbers);
        const pdfBlob = new Blob([byteArray], { type: 'application/pdf' });

        // Create a blob URL for the PDF
        const pdfUrl = URL.createObjectURL(pdfBlob);
        return pdfUrl;
    }

    // generic methot to show toast messages
    showMessage(title, message, variant) {
        const toastEvt = new ShowToastEvent({
            title,
            message,
            variant
        });
        this.dispatchEvent(toastEvt);
    }
}