import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { LightningElement, api, track } from 'lwc';
import { OmniscriptActionCommonUtil } from "omnistudio/omniscriptActionUtils";
import { OmniscriptBaseMixin } from 'omnistudio/omniscriptBaseMixin';
import { getNamespaceDotNotation } from "omnistudio/omniscriptInternalUtils";
import lpiOwnershipInformationCmp from './lpiOwnershipInformationCmp.html';
import lpiOwnershipInformationCmp_ReadOnly from './lpiOwnershipInformationCmp_ReadOnly.html';

export default class LpiOwnershipInformationCmp extends OmniscriptBaseMixin(LightningElement) {

    _ns = getNamespaceDotNotation();
    inputData = {};
    @api parid;
    @api disableAll = false;
    @track showSpinner = false;
    @track regPattern = '^((?!(<\s*|\s*>)).)*$';
    @track messagePatternMismatch = "Invalid input. This field only accepts letters and numbers. Special characters are not allowed."
    @track stateOption = [];
    @track countryOptions = [];
    @track selectedCountyValue;
    @track selectedSearchResult;
    @track picklistOrdered;
    @track searchResults;
    uniqueDataId;
    @track ownershipInformationWrap = {};
    @track isTheOwnerLicensedInMOOption = [
        { label: "Yes", value: "Yes" },
        { label: "No", value: "No" }
    ];
    @track typeaheadLabel = 'Board License Number';
    @track typeaheadErrorMsg = 'Please enter correct Board License Number';
    @track radioLabel = 'Is the Entity Licensed in Missouri by the Board?';
    @track radioErrorMsg = 'Error: Is the Entity Licensed in Missouri by the Board? is required.';
    @track ownerRadioLabel = 'Is the Owner/Partner/Member licensed with the Board?';
    @track ownerErrorMsg = 'Error: Is the Owner/Partner/Member licensed with the Board? is required.';
    @track showDOB = false;
    @track hideLicensedWithBoardQue = false; //Added for I-246215
    @track showOwnerInfoSubText = false;
    tattoo_isTheOwnerLicensedInMO = 'Yes';

    connectedCallback() {
        this.fetchPicklistValues('Address', 'StateCode');
        this.fetchPicklistValues('Address', 'CountryCode');
        this.fetchPicklistValues('Case', 'County__c');
        this.loadOwnerShipInformation();
    }
    render() {
        return this.disableAll ? lpiOwnershipInformationCmp_ReadOnly : lpiOwnershipInformationCmp;
    }
    loadOwnerShipInformation() {
        this.showSpinner = true;
        this._actionUtil = new OmniscriptActionCommonUtil();
        this.inputData['parId'] = this.parid;
        const params = {
            input: this.inputData,
            sClassName: 'LPI_OwnershipInformationController',
            sMethodName: 'loadOwnerShipInformation',
            options: '{}',
        };
        this._actionUtil.executeAction(params, null, this, null, null)
            .then(response => {
                this.showSpinner = false;
                let result = response.result.ownershipInformationWrap;
                this.ownershipInformationWrap = result;
                if(result.boardName === 'Real Estate'){
                    this.typeaheadLabel = this.typeaheadLabel.replace('Board','State Commission');
                    this.radioLabel = this.radioLabel.replace('Board','State Commission');
                    this.ownerRadioLabel = this.ownerRadioLabel.replace('Board','State Commission');
                    this.ownerErrorMsg = this.ownerErrorMsg.replace('Board','State Commission');
                    this.radioErrorMsg = this.radioErrorMsg.replace('Board','State Commission');
                    this.typeaheadErrorMsg = this.typeaheadErrorMsg.replace('Board','State Commission');
                }
                if(result.boardName === 'Real Estate Appraisers' || result.boardName === 'Tattooing, Body Piercing & Branding'){
                    this.showDOB = true;
                    this.showOwnerInfoSubText = true;
                    this.hideLicensedWithBoardQue = result.boardName === 'Tattooing, Body Piercing & Branding' ? true : false; //Added for I-246215
                }
            }).catch(error => {
                this.showSpinner = false
                console.log('error->', error);
            });
    }

    /* get selectedValue() {
        return this.selectedSearchResult ? this.selectedSearchResult.label : null;
        // value={ownerData.county}
    } */

    search(event) {
        this.uniqueDataId = event.target.dataset.id;
        const input = event.detail.value.toLowerCase();
        if (input.length >= 1) {
            const result = this.picklistOrdered.filter((picklistOption) =>
                picklistOption.label.toLowerCase().includes(input)
            );
            this.searchResults = result;
        } else {
            this.ownershipInformationWrap.ownerInformation[this.uniqueDataId].county = null;
            this.clearSearchResults()
        }
    }

    selectSearchResult(event) {
        const selectedValue = event.currentTarget.dataset.name;
        this.selectedSearchResult = this.picklistOrdered.find(
            (picklistOption) => picklistOption.label === selectedValue
        );
        this.selectedCountyValue = selectedValue;
        this.ownershipInformationWrap.ownerInformation[this.uniqueDataId].county = this.selectedCountyValue;
        this.clearSearchResults();
    }
    clearSearchResults() {
        this.searchResults = null;
    }
    
    handleChange(event) {
        var keyVal = event.target.dataset.id;
        var fieldName = event.target.dataset.name;
        var value = event.target.value.trim();
        if (fieldName === 'isTheOwnerLicensedInMOName' + keyVal || fieldName === 'isTheBusinessLicensedInMOName' + keyVal || fieldName === 'isTheOwnerBusinessEntityName' + keyVal) {
            if (this.ownershipInformationWrap.ownerInformation[keyVal].relationShipId !== '') {
                this.inputData['relationShipId'] = this.ownershipInformationWrap.ownerInformation[keyVal].relationShipId;
                this.deleteRelationshipData(this.inputData, false);
            }
            if (fieldName !== 'isTheOwnerBusinessEntityName' + keyVal) {
                this.ownershipInformationWrap.ownerInformation[keyVal].isTheOwnerLicensedInMO = value;
                this.ownershipInformationWrap.ownerInformation[keyVal].showLookUpLicense = value === 'No' ? false : true;
                this.ownershipInformationWrap.ownerInformation[keyVal].showOwnerShipSection = true;
                this.ownershipInformationWrap.ownerInformation[keyVal].isPartialDisable = value === 'No' ? false : true;
                this.ownershipInformationWrap.ownerInformation[keyVal].isPartialRequired = value === 'No' ? true : false;
            } else {
                this.ownershipInformationWrap.ownerInformation[keyVal].isBusinessEntityData = value;
                //Added condition for Tattoo board for I-246215 ----start----
                if(this.ownershipInformationWrap.boardName === 'Tattooing, Body Piercing & Branding'){
                        this.ownershipInformationWrap.ownerInformation[keyVal].isTheOwnerLicensedInMO = 'Yes';
                        this.ownershipInformationWrap.ownerInformation[keyVal].showLookUpLicense = true;
                        this.ownershipInformationWrap.ownerInformation[keyVal].showOwnerShipSection = true;
                        this.ownershipInformationWrap.ownerInformation[keyVal].isPartialDisable = true;
                        this.ownershipInformationWrap.ownerInformation[keyVal].isPartialRequired = true;
                        //added to check if its business entity or no 
                        if(this.ownershipInformationWrap.ownerInformation[keyVal].isBusinessEntityData === 'Yes'){
                            this.ownershipInformationWrap.ownerInformation[keyVal].isBusinessOwner = true;
                            this.ownershipInformationWrap.ownerInformation[keyVal].isIndividualOwner = false;
                        }else{
                            this.ownershipInformationWrap.ownerInformation[keyVal].isBusinessOwner = false;
                            this.ownershipInformationWrap.ownerInformation[keyVal].isIndividualOwner = true;
                        }
                }else{
                    this.ownershipInformationWrap.ownerInformation[keyVal].isTheOwnerLicensedInMO = '';
                    this.ownershipInformationWrap.ownerInformation[keyVal].showLookUpLicense = false;
                    this.ownershipInformationWrap.ownerInformation[keyVal].showOwnerShipSection = false;
                    this.ownershipInformationWrap.ownerInformation[keyVal].isPartialDisable = false;
                    this.ownershipInformationWrap.ownerInformation[keyVal].isPartialRequired = false;
                    this.ownershipInformationWrap.ownerInformation[keyVal].isBusinessOwner = value === 'No' ? false : true;
                    this.ownershipInformationWrap.ownerInformation[keyVal].isIndividualOwner = value === 'No' ? true : false;
                }
                //-----end-----
                /*this.ownershipInformationWrap.ownerInformation[keyVal].isTheOwnerLicensedInMO = '';
                this.ownershipInformationWrap.ownerInformation[keyVal].showLookUpLicense = false;
                this.ownershipInformationWrap.ownerInformation[keyVal].showOwnerShipSection = false;
                this.ownershipInformationWrap.ownerInformation[keyVal].isPartialDisable = false;
                this.ownershipInformationWrap.ownerInformation[keyVal].isPartialRequired = false;
                this.ownershipInformationWrap.ownerInformation[keyVal].isBusinessOwner = value === 'No' ? false : true;
                this.ownershipInformationWrap.ownerInformation[keyVal].isIndividualOwner = value === 'No' ? true : false;*/
                if (this.ownershipInformationWrap.isCorporateOwnerShipType && value === 'Yes') {
                    this.ownershipInformationWrap.ownerInformation[keyVal].isTheOwnerLicensedInMO = 'No';
                    this.ownershipInformationWrap.ownerInformation[keyVal].showOwnerShipSection = true;
                    this.ownershipInformationWrap.ownerInformation[keyVal].isPartialRequired = true;
                }
            }
            this.ownershipInformationWrap.ownerInformation[keyVal].licenseNumber = '';
            this.ownershipInformationWrap.ownerInformation[keyVal].businessLicenseId = '';
            this.ownershipInformationWrap.ownerInformation[keyVal].businessName = '';
            this.ownershipInformationWrap.ownerInformation[keyVal].businessEmail = '';
            this.ownershipInformationWrap.ownerInformation[keyVal].busienssPhone = '';
            this.ownershipInformationWrap.ownerInformation[keyVal].busienssAccountId = '';
            this.ownershipInformationWrap.ownerInformation[keyVal].firstName = '';
            this.ownershipInformationWrap.ownerInformation[keyVal].lastName = '';
            this.ownershipInformationWrap.ownerInformation[keyVal].middleName = '';
            this.ownershipInformationWrap.ownerInformation[keyVal].title = '';
            this.ownershipInformationWrap.ownerInformation[keyVal].birthdate = null;
            this.ownershipInformationWrap.ownerInformation[keyVal].ownershipPercent = null;
            this.ownershipInformationWrap.ownerInformation[keyVal].SSN = '';
            this.ownershipInformationWrap.ownerInformation[keyVal].email = '';
            this.ownershipInformationWrap.ownerInformation[keyVal].personAccountId = '';
            this.ownershipInformationWrap.ownerInformation[keyVal].country = '';
            this.ownershipInformationWrap.ownerInformation[keyVal].streetAddress1 = '';
            this.ownershipInformationWrap.ownerInformation[keyVal].city = '';
            this.ownershipInformationWrap.ownerInformation[keyVal].state = '';
            this.ownershipInformationWrap.ownerInformation[keyVal].stateText = '';
            this.ownershipInformationWrap.ownerInformation[keyVal].zipCode = '';
            this.ownershipInformationWrap.ownerInformation[keyVal].county = '';
            this.ownershipInformationWrap.ownerInformation[keyVal].searchedKey = '';
            this.ownershipInformationWrap.ownerInformation[keyVal].relationShipId = '';
            this.ownershipInformationWrap.ownerInformation[keyVal].isUsState = false;
            this.ownershipInformationWrap.ownerInformation[keyVal].isStateMO = false;

        } else if (fieldName === 'country') {
            this.ownershipInformationWrap.ownerInformation[keyVal][fieldName] = value;
            this.ownershipInformationWrap.ownerInformation[keyVal].isUsState = value === 'US' ? true : false;
        } else if (fieldName === 'state') {
            this.ownershipInformationWrap.ownerInformation[keyVal][fieldName] = value;
            this.ownershipInformationWrap.ownerInformation[keyVal].isStateMO = value === 'MO' ? true : false;
        }
        else {
            if (fieldName !== 'isTheOwnerLicensedInMOName' + keyVal && fieldName !== 'isTheBusinessLicensedInMOName' + keyVal && fieldName !== 'isTheOwnerBusinessEntityName' + keyVal)
                this.ownershipInformationWrap.ownerInformation[keyVal][fieldName] = value;
        }



        if (fieldName === 'SSN') {
            // if (value.length === 9) {
            //     // let isDuplicateSSN = false;
            //     // this.showSpinner = true;
            //     // this._actionUtil = new OmniscriptActionCommonUtil();
            //     // this.inputData['ssnNumber'] = value;
            //     // const params = {
            //     //     input: this.inputData,
            //     //     sClassName: 'LPI_OwnershipInformationController',
            //     //     sMethodName: 'checkDuplicateSSN',
            //     //     options: '{}',
            //     // };
            //     // this._actionUtil.executeAction(params, null, this, null, null)
            //     //     .then(response => {
            //     //         this.showSpinner = false;
            //     //         let result = response.result.isDuplicateSSN;
            //     //         isDuplicateSSN = result;
            //     //         if (isDuplicateSSN) {
            //     //             event.target.setCustomValidity("Duplicate SSN found! Please enter correct one");
            //     //         } else {
            //     //             event.target.setCustomValidity("");
            //     //         }
            //     //         event.target.reportValidity();
            //     //     }).catch(error => {
            //     //         this.showSpinner = false
            //     //         console.log('error->', error);
            //     //     });

            //     let foundDuplicateName = this.ownershipInformationWrap.ownerInformation.find((nnn, index) => {
            //         return this.ownershipInformationWrap.ownerInformation.find((x, ind) => x.SSN === nnn.SSN && index !== ind)
            //     });
            //     if (foundDuplicateName) {
            //         event.target.setCustomValidity("Duplicate SSN found! Please enter correct one");
            //     } else {
            //         event.target.setCustomValidity("");
            //     }
            // } else {
            //     event.target.setCustomValidity("");
            // }
            // event.target.reportValidity();
        }
        if (fieldName === 'ownershipPercent') {
            if (value.length === 0)
                this.ownershipInformationWrap.ownerInformation[keyVal][fieldName] = null;
        }
    }

    lookupRecord(event) {
        const keyVal = event.detail.selectedRecord.uniqueId;
        if ((this.ownershipInformationWrap.ownerInformation[keyVal].isBusinessEntityData === 'Yes' &&
            this.ownershipInformationWrap.ownerInformation[keyVal].businessAccountId !== event.detail.selectedRecord.businessAccountId) ||
            (!this.ownershipInformationWrap.ownerInformation[keyVal].isBusinessEntityData === 'No' &&
                this.ownershipInformationWrap.ownerInformation[keyVal].personAccountId !== event.detail.selectedRecord.personAccountId)) {
            this.inputData['relationShipId'] = this.ownershipInformationWrap.ownerInformation[keyVal].relationShipId;
            this.deleteRelationshipData(this.inputData, false);
        }
        this.ownershipInformationWrap.ownerInformation[keyVal].uniqueId = keyVal;
        this.ownershipInformationWrap.ownerInformation[keyVal].licenseNumber = event.detail.selectedRecord.licenseNumber;
        this.ownershipInformationWrap.ownerInformation[keyVal].businessLicenseId = event.detail.selectedRecord.businessLicenseId;
        this.ownershipInformationWrap.ownerInformation[keyVal].businessName = event.detail.selectedRecord.businessName;
        this.ownershipInformationWrap.ownerInformation[keyVal].businessEmail = event.detail.selectedRecord.businessEmail;
        this.ownershipInformationWrap.ownerInformation[keyVal].busienssPhone = event.detail.selectedRecord.busienssPhone;
        this.ownershipInformationWrap.ownerInformation[keyVal].busienssAccountId = event.detail.selectedRecord.busienssAccountId;
        this.ownershipInformationWrap.ownerInformation[keyVal].firstName = event.detail.selectedRecord.firstName;
        this.ownershipInformationWrap.ownerInformation[keyVal].lastName = event.detail.selectedRecord.lastName;
        this.ownershipInformationWrap.ownerInformation[keyVal].middleName = event.detail.selectedRecord.middleName;
        this.ownershipInformationWrap.ownerInformation[keyVal].title = event.detail.selectedRecord.title;
        this.ownershipInformationWrap.ownerInformation[keyVal].birthdate = event.detail.selectedRecord.birthdate;
        this.ownershipInformationWrap.ownerInformation[keyVal].ownershipPercent = event.detail.selectedRecord.ownershipPercent;
        this.ownershipInformationWrap.ownerInformation[keyVal].SSN = event.detail.selectedRecord.SSN;
        this.ownershipInformationWrap.ownerInformation[keyVal].email = event.detail.selectedRecord.email;
        this.ownershipInformationWrap.ownerInformation[keyVal].personAccountId = event.detail.selectedRecord.personAccountId;
        this.ownershipInformationWrap.ownerInformation[keyVal].country = event.detail.selectedRecord.country;
        this.ownershipInformationWrap.ownerInformation[keyVal].streetAddress1 = event.detail.selectedRecord.streetAddress1;
        this.ownershipInformationWrap.ownerInformation[keyVal].city = event.detail.selectedRecord.city;
        this.ownershipInformationWrap.ownerInformation[keyVal].state = event.detail.selectedRecord.state;
        this.ownershipInformationWrap.ownerInformation[keyVal].stateText = event.detail.selectedRecord.stateText;
        this.ownershipInformationWrap.ownerInformation[keyVal].zipCode = event.detail.selectedRecord.zipCode;
        this.ownershipInformationWrap.ownerInformation[keyVal].county = event.detail.selectedRecord.county;
        this.ownershipInformationWrap.ownerInformation[keyVal].isUsState = event.detail.selectedRecord.isUsState;
        this.ownershipInformationWrap.ownerInformation[keyVal].searchedKey = event.detail.selectedRecord.searchedKey;
    }
    deleteSection(event) {
        var keyVal = event.target.dataset.id;
        if (this.ownershipInformationWrap.ownerInformation[keyVal].relationShipId !== '') {
            this.inputData['relationShipId'] = this.ownershipInformationWrap.ownerInformation[keyVal].relationShipId;
            this.deleteRelationshipData(this.inputData, true);
        }else{
            this.showToast('Ownership record deleted Successfully.', 'Success', 'success');
        }
        this.ownershipInformationWrap.ownerInformation.splice(keyVal, 1);
        let ownerData = this.ownershipInformationWrap.ownerInformation;
        for (let i = 0; i < ownerData.length; i++) {
            ownerData[i].uniqueId = i;
            ownerData[i].ownershipInformationTitle = 'Ownership Information ' + (i + 1);
            ownerData[i].showDelete = i > 0 ? true : false;
            ownerData[i].isTheOwnerLicensedInMOName = 'isTheOwnerLicensedInMOName' + i;
            ownerData[i].isTheOwnerBusinessEntityName = 'isTheOwnerBusinessEntityName' + i;
            ownerData[i].isTheBusinessLicensedInMOName = 'isTheBusinessLicensedInMOName' + i;
        }
        this.ownershipInformationWrap.ownerInformation = ownerData;
        this.focusOnAdditionalButton();
  }
    focusOnAdditionalButton() {
        console.log('called focusOnAdditionalButton');
        const addAdditionalOwnerBtn = this.template.querySelector(".addAdditionalOwnerBtn");
        if (addAdditionalOwnerBtn) {
            // eslint-disable-next-line @lwc/lwc/no-async-operation
            setTimeout(() => {
                console.log('focussed focusOnAdditionalButton');
                addAdditionalOwnerBtn.focus();
            }, 300);
        }
    }
    deleteRelationshipData(paramData, showT) {
        this.showSpinner = true;
        this._actionUtil = new OmniscriptActionCommonUtil();
        const params = {
            input: paramData,
            sClassName: 'LPI_OwnershipInformationController',
            sMethodName: 'deleteRelationShipData',
            options: '{}',
        };
        this._actionUtil.executeAction(params, null, this, null, null)
            .then(response => {

                this.showSpinner = false;
                if (response.error) {
                    if (showT)
                        this.showToast(response.error, 'Error', 'error');
                } else {
                    if (showT)
                        this.showToast('Ownership record deleted Successfully.', 'Success', 'success');
                }
            }).catch(error => {
                if (showT)
                    this.showToast(error, 'Error', 'error');
                this.showSpinner = false
            });
    }
    nextButton() {
        this._actionUtil = new OmniscriptActionCommonUtil();
        if (this.checkRepeatBlockValidity()) {
            this.showSpinner = true;
            this._actionUtil = new OmniscriptActionCommonUtil();
            this.inputData['parId'] = this.parid;
            this.inputData['ownershipInformationWrap'] = JSON.stringify(this.ownershipInformationWrap);
            let percentage = 0;
            const params = {
                input: this.inputData,
                sClassName: 'LPI_OwnershipInformationController',
                sMethodName: 'saveOwnerShipnformation',
                options: '{}',
            };
            //added for I-246216 ---start---
            if(this.ownershipInformationWrap.boardName === 'Tattooing, Body Piercing & Branding' || this.ownershipInformationWrap.boardName === 'Real Estate Appraisers'){
                for(let i = 0; i< this.ownershipInformationWrap.ownerInformation.length; i++){
                    percentage += parseFloat(this.ownershipInformationWrap.ownerInformation[i].ownershipPercent);
                }
                if (percentage != 100) {
                    this.showSpinner = false;
                    this.showToast('The total ownership percentage should equal 100%.', 'Error', 'error');
                    return; // Stop further execution
                }
            }
            //----end-----
                this._actionUtil.executeAction(params, null, this, null, null)
                .then(response => {
                    this.showSpinner = false;
                    if (response.error) {
                        this.showToast(response.error, 'Error', 'error');
                    } else {
                        this.showToast('Ownership Data Saved Successfully.', 'Success', 'success');
                        //this.omniUpdateDataJson({'ownershipType' : this.ownershipInformationWrap.ownershipType});
                        this.omniNextStep();
                    }
                }).catch(error => {
                    console.log('errrrr---->' + JSON.stringify(error));
                    this.showSpinner = false
                    this.showToast(error, 'Error', 'error');
                });
        }
    }



    showToast(msg, title, varient) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: msg,
                variant: varient
            })
        );
    }
    addOwnerShipSection() {
        let uniqueId = this.ownershipInformationWrap.ownerInformation.length;

        let ownershipInformationTitle = 'Ownership Information ' + (this.ownershipInformationWrap.ownerInformation.length + 1);
        let showDelete = this.ownershipInformationWrap.ownerInformation.length > 0 ? true : false;
        let infoSection = {
            "businessLicenseId": '',
            "uniqueId": uniqueId,
            "showDelete": showDelete,
            "ownershipInformationTitle": ownershipInformationTitle,
            "isTheOwnerBusinessEntityName": 'isTheOwnerBusinessEntityName' + uniqueId,
            "isBusinessEntityData": '',
            "isBusinessOwner": false,
            "isIndividualOwner": false,
            "isTheBusinessLicensedInMOName": 'isTheBusinessLicensedInMOName' + uniqueId,
            "isTheOwnerLicensedInMO": '',
            "showOwnerShipSection": false,
            "showLookUpLicense": false,
            "licenseNumber": '',
            "isPartialDisable": false,
            "isPartialRequired": true,
            "businessName": '',
            "businessEmail": '',
            "busienssPhone": '',
            "ownershipPercent": null,
            "businessAccountId": '',
            "country": '',
            "streetAddress1": '',
            "city": '',
            "isUsState": false,
            "state": '',
            "stateText": '',
            "zipCode": '',
            "county": '',
            "isTheOwnerLicensedInMOName": 'isTheOwnerLicensedInMOName' + uniqueId,
            "firstName": '',
            "middleName": '',
            "lastName": '',
            "email": '',
            "SSN": '',
            "title": '',
            "birthdate": null,
            "personAccountId": '',
            "relationShipId": '',
            "countryValue": '',
            "stateValue": '',
            "searchedKey": '',
            "isCorporateOwnerShip": this.ownershipInformationWrap.isCorporateOwnerShipType
        };
        this.ownershipInformationWrap.ownerInformation.push(infoSection);
        this.ownershipInformationWrap.activeSections.push(ownershipInformationTitle);
        setTimeout(() => {
            const newAccordionElement = this.template.querySelector(`[data-id='${uniqueId}']`);
            newAccordionElement.setAttribute('tabindex', '0');
            newAccordionElement.focus();
            newAccordionElement.scrollIntoView({ behavior: 'smooth', block: 'start' });
        }, 200);
    }

    validateRequiredFields() {
        this.focus = false;
        this.focusIndex = -1;
        const isInputsCorrect = [
            ...this.template.querySelectorAll('lightning-input'),
            ...this.template.querySelectorAll('lightning-combobox'),
            ...this.template.querySelectorAll('lightning-radio-group')

        ].reduce((validSoFar, inputField) => {
            inputField.reportValidity();
            let valid = inputField.checkValidity();
            // valid = inputField.disabled ? true : valid;
            if (!valid && (!this.focus || this.focusIndex == -1 || this.focusIndex > parseInt(inputField.dataset.index))) {
                inputField.focus();
                this.focus = true;
                this.focusIndex = inputField.dataset.index;
            }
            return validSoFar && valid;

        }, true);
            let allInput = this.template.querySelector(".slds-has-error");
            if (allInput) {
                allInput.scrollIntoView();
                allInput.focus();
            }
        return isInputsCorrect; 
    }
    // cg added
    focusChildInput() {
        const objChild = this.template.querySelectorAll('c-lpi-custom-lookup-cmp');
        let isValid = true;

        for (var temp of objChild) {

            if (!temp.inputValid()) {
                isValid = false;
                break;
            }

        }
        return isValid;
    }


    fetchPicklistValues(objectAPIName, fieldAPIName) {
        this._actionUtil = new OmniscriptActionCommonUtil();
        this.inputData['objectName'] = objectAPIName;
        this.inputData['fieldName'] = fieldAPIName;

        const params = {
            input: this.inputData,
            sClassName: 'LPI_OwnershipInformationController',
            sMethodName: 'fetchPicklist',
            options: '{}',
        };

        this._actionUtil.executeAction(params, null, this, null, null)
            .then(response => {
                if (fieldAPIName === 'StateCode') {
                    this.stateOption = response.result.picklistValues;
                } else if (fieldAPIName === 'CountryCode') {
                    this.countryOptions = response.result.picklistValues;
                } else if (fieldAPIName === 'County__c') {
                    this.picklistOrdered = response.result.picklistValues
                }
            })
            .catch(error => {
                console.log('error->', error);
            });
    }

    async openAccordions() {
        if (this.template.querySelector('lightning-accordion') !== null) {
            this.template.querySelector('lightning-accordion').activeSectionName = '';
            this.template.querySelector('lightning-accordion').activeSectionName = this.ownershipInformationWrap.activeSections;
        }

        await Promise.resolve();
    }
    checkRepeatBlockValidity() {
        this.openAccordions();
        let isInputsCorrect = true;
        for (let obj of this.ownershipInformationWrap.ownerInformation) {
            if (obj.isBusinessEntityData != null && obj.isBusinessEntityData === 'Yes') {
                if (obj.isTheOwnerLicensedInMO === '') {
                    this.validateRequiredFields();
                    isInputsCorrect = false;
                }
                else if (obj.isTheOwnerLicensedInMO === 'Yes' && obj.licenseNumber === '') {
                    isInputsCorrect = this.validateRequiredFields();
                    this.focusChildInput();
                }
                else if (obj.isTheOwnerLicensedInMO === 'No') {
                    isInputsCorrect = this.validateRequiredFields();
                } else if (!this.validateRequiredFields()) {
                    isInputsCorrect = false;
                }
            } else {
                if (obj.isTheOwnerLicensedInMO === '') {
                    this.validateRequiredFields();
                    isInputsCorrect = false;
                    break;
                }
                else if (obj.isTheOwnerLicensedInMO === 'Yes' && obj.licenseNumber === '') {
                    this.focusChildInput();
                    isInputsCorrect = false;
                    break;
                }
                else if (obj.isTheOwnerLicensedInMO === 'Yes' && obj.title.length === 0) {
                    this.validateRequiredFields();
                    isInputsCorrect = false;
                    break;
                }
                else if (obj.isTheOwnerLicensedInMO === 'No') {
                    isInputsCorrect = this.validateRequiredFields();
                    break;
                } else if (!this.validateRequiredFields()) {
                    isInputsCorrect = false;
                    break;
                }
            }
        }
        return isInputsCorrect;
    }
}