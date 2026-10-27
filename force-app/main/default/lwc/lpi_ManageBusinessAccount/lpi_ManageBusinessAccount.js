import { LightningElement, track, wire } from 'lwc';
import {NavigationMixin} from 'lightning/navigation';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import {getPicklistValues, getObjectInfo } from "lightning/uiObjectInfoApi";
import ADDRESS_OBJECT from '@salesforce/schema/Address';
import AddressState from '@salesforce/schema/Address.StateCode';
import AddressCountry from '@salesforce/schema/Address.CountryCode';
import {CurrentPageReference} from 'lightning/navigation';

//Resource
import My_Resource from "@salesforce/resourceUrl/LPI_Design";
//Apex
import getBusinessAccountData from '@salesforce/apex/LPI_ManageBusinessAccountController.getBusinessAccountData';
import saveBusinessAccountData from '@salesforce/apex/LPI_ManageBusinessAccountController.saveBusinessAccountData';

export default class Lpi_ManageBusinessAccount extends NavigationMixin(LightningElement) {
	greenTick = My_Resource + "/media/icons/greenTick.svg";
	@wire(CurrentPageReference)
    currentPageReference;
    @track stateOptions = [];
    @track countryOptions = [];
    @track dataObj = {};

    //ContactLists
	isCoorporatePopupOpen = false;
	@track corporateOfficerList = [];
	@track selectedCoorporateOfficerData = {
		addressData: {
			country: "US",
			state: "MO"
		}
	};
	@track selectedCorporateIndex = "";
	@track isContactUpdate = false;

	//Authorized Contact List
	isAuthContactPopupOpen = false;
	@track authContactList = [];
	@track selectedAuthContactData = {};
	@track selectedAuthContactIndex = "";
	@track preCorpRole;
	showSpinner = false;
	hasError = false;
	errorMessage = "";
	showOtp = false;
	todayDate;
    
	correctSsn;
	openConfirmationModal = false;
	otp;
	resentCount = 0;
	accountId;
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
	//58196
	showAuthContactEmailField = false;
	businessOutsideUSOptions = [
		{label : 'Yes', value: "Yes"},
		{label : 'No', value: "No"}
	]
    // GET OBJECT INFO
	@wire(getObjectInfo, {
        objectApiName: ADDRESS_OBJECT
    }) objectInfo;
	objectInfo;
	// GET PICKLIST VALUES OF COUNTRY FIELD
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
    
    get roleOptions() {
        return [
			{label: "Board Director", value: "Board Director"},
			{label: "CEO",value: "CEO"},
			{label: "CFO (Chief Financial Officer)", value: "CFO (Chief Financial Officer)"},
			{label: "Chairperson", value: "Chairperson"},
			{label: "COO", value: "COO"},
			{label: "Corporate Officer", value: "Corporate Officer"},
			{label: "Director", value: "Director"},
			{label: "Executive Vice President", value: "Executive Vice President"},
			{label: "President",value: "President"},
			{label: "Principal", value: "Principal"},
			{label: "Secretary", value: "Secretary"},
			{label: "Senior Vice President", value: "Senior Vice President"},
			{label: "Shareholder", value: "Shareholder"},
			{label: "Treasurer", value: "Treasurer"},
			{label: "Vice President", value: "Vice President"},
			{label: "Other", value: "Other"}
		];
    }
    connectedCallback(){
		if (`${this.currentPageReference.state.accId}` != 'undefined') {
            this.accountId = `${this.currentPageReference.state.accId}`;
			this.getBusinessAccInfo();
        }
        
    }

    getBusinessAccInfo(){
		this.showSpinner = true;
        getBusinessAccountData({
            personAccId : this.accountId
        }).then(data => {
			console.log('JSON: ' + JSON.stringify(data));
			if(data != null){
				console.log('Entered IF>>');
				this.dataObj = data;
				console.log('111');
				//this.maskingEIN(data.employerIdentificationNum);
				console.log('222');
				this.authContactList = data.authContactListResp;
				console.log('Auth Contact>>'+this.authContactList);
				this.corporateOfficerList = data.corporateOfficerListResp;
				console.log('Corporate>>'+this.corporateOfficerList);
				const regex = /\d(?=\d{4})/gm;
				const subst = `X`;
				this.corporateOfficerList.forEach(element => {
				element.ssn = this.makeSSNMask(element.ssn.replace(regex, subst));
				});
			}
			this.showSpinner = false;
        }).catch(error => {
			console.log('Entered ERROR>>');
			console.log('ERROR: ' + JSON.stringify(error));
			this.showSpinner = false;
		})
    }

	get isBusinessAddressUS() {
		let temp = this.dataObj && this.dataObj.businessCountry === "US" ? true : false;
		return temp;
	}

	get isCoorporateAddressUS() {
		let temp =
			this.selectedCoorporateOfficerData.addressData &&
			this.selectedCoorporateOfficerData.addressData.country &&
			this.selectedCoorporateOfficerData.addressData.country === "US" ?
			true :
			false;
		if (!temp) {
			this.selectedCoorporateOfficerData.addressData.state = null;
		}
		return temp;
	}

	get displayCorporateOfficerList() {
		return this.corporateOfficerList && this.corporateOfficerList.length > 0;
	}

	get displayAuthContactList() {
		return this.authContactList && this.authContactList.length > 0;
	}

	get displayOwnerShipTable() {
		return this.ownerShipInfoList && this.ownerShipInfoList.length > 0;
	}
	get showBusinessIdentificationNum() {
		return this.dataObj && this.dataObj.businessOutsideUS == 'Yes';
	}

	handleInputs(event) {
		console.log('@@@ '+ JSON.stringify(this.authContactList[0]['email']));
		this.hideErrorMessage();
		this.hasError = false;
		this.dataObj[event.target.name] = event.target.value;
	}

	handleSaveManageBusinessAccountBtn(){
		this.dataObj.authContactListResp = this.authContactList;
		this.dataObj.corporateOfficerListResp = this.corporateOfficerList;
		this.hideErrorMessage();
		this.showSpinner = true;
		if (this.isValid()) {
			//Show error if there is no Corporate Officer or Authorized Contact details.
			if (this.corporateOfficerList.length === 0 || this.authContactList.length === 0) {
				window.scrollTo(0, 0);
				if (this.corporateOfficerList.length === 0 && this.authContactList.length === 0) {
					this.errorMessage = "Please provide Corporate Officer and Authorized Contact details.";
					setTimeout(() => {
						this.focusOnInitialButton('authContactFocusButton');
					}, 5000);
				} else if (this.authContactList.length === 0) {
					this.errorMessage = "Please provide Authorized Contact details.";
				} else if (this.corporateOfficerList.length === 0) {
					this.errorMessage = "Please provide Corporate Officer details.";
				} 
				this.hasError = true;
				this.showSpinner = false;
			}else{
				//Show error if user missde First Authorized Contact Email
				if(this.authContactList.length === 1 && this.authContactList[0]['email'] === undefined){
					window.scrollTo(0, 0);
					this.errorMessage = "Please provide Email for first Authorized Contact.";
					this.hasError = true;
					this.showSpinner = false;
				}else {
					//Save Details
					this.saveBusinessAccountChanges();
				}
			}
		}else{
			window.scrollTo(0, 0);
			let allInput = this.template.querySelector(".slds-has-error");
			if (allInput) {
				allInput.scrollIntoView();
				allInput.focus();
			}
			this.hasError = true;
			this.errorMessage = "Please review the errors.";
			this.showSpinner = false;
		}
	}
	saveBusinessAccountChanges(){
		saveBusinessAccountData({
			manageAccData: JSON.stringify(this.dataObj)
		}).then(data => {
			if(data){
				this.showSpinner = false;
				this.showToastMessage("Success!", 'Records updated successfully.', "success", "dismissible");
			} else{
				this.showSpinner = false;
				this.showToastMessage("Error!", 'Problem in Saving', "error", "dismissible");
			}
		}).catch(error => {
			this.showSpinner = false;
			this.showToastMessage("Error!", JSON.stringify(error), "error", "dismissible");
		})
	}
	addAuthContact() {
		this.selectedAuthContactData = {};
		this.isAuthContactPopupOpen = true;
		//Added for story S-58916 -- Start
		if(this.authContactList && this.authContactList.length < 1){
			this.showAuthContactEmailField = true;
		} else {
			this.showAuthContactEmailField = false;
		}
		//Added for story S-58916 -- End
		setTimeout(() => {
			this.focusFirstEle();
		}, 200);
	}

	closeModelAuthContact() {
		this.isAuthContactPopupOpen = false;
		setTimeout(() => {
			this.focusOnInitialButton('authContactFocusButton');
		}, 500);
	}

	saveAuthContact() {
		var msg;
		if (this.isContactUpdate) {
			msg = "Authorized Contact has been updated successfully";
			this.isContactUpdate = false;
		} else {
			msg = "Authorized Contact has been added successfully";
		}
		if (this.checkValidityAuthValidate()) {
			this.showToastMessage(
				"Success",
				msg,
				"success",
				"dismissible"
			);
			if (
				this.selectedAuthContactData.index !== undefined &&
				this.selectedAuthContactData.index !== "" &&
				this.selectedAuthContactData.index !== null
			) {
				this.isAuthContactPopupOpen = false;
				this.authContactList[this.selectedAuthContactData.index] = this.selectedAuthContactData;
			} else {
				this.isAuthContactPopupOpen = false;
				this.selectedAuthContactData.index = this.authContactList.length;
				this.authContactList.push(this.selectedAuthContactData);
			}
		} else {
			this.focus = false;
			this.focusIndex = -1;
			let isAllValid = [...this.template.querySelectorAll('.authContactValidate')].reduce((validSoFar, input) => {
				input.reportValidity();
				let valid = input.checkValidity();
				if (!valid && (!this.focus || this.focusIndex == -1 || this.focusIndex > parseInt(input.dataset.index))) {
					input.focus();
					this.focus = true;
					this.focusIndex = input.dataset.index;
				}
				return validSoFar && valid;
			}, true);
		}
	}

	handleAuthContactEdit(event) {
		this.selectedAuthContactData = Object.assign({}, this.authContactList[event.currentTarget.dataset.index]);
		this.isContactUpdate = true;
		this.isAuthContactPopupOpen = true;
		//Added for story S-58916 -- Start
		if(this.selectedAuthContactData.index == 0){
			this.showAuthContactEmailField = true;
		} else {
			this.showAuthContactEmailField = false;
		}
		console.log('## '+this.selectedAuthContactData.index);
		//Added for story S-58916 -- End
	}

	handleAuthDelete(event) {
		this.modalHeading = "Are you sure you want to delete this Authorized Contact?";
		this.selectedAuthContactIndex = event.currentTarget.dataset.index;
		this.openConfirmationModal = true;
		setTimeout(() => {
			this.focusFirstEle();
		}, 200);
	}

	addCoorprateOfficer() {
		this.selectedCoorporateOfficerData = {
			addressData: {
				country: "US",
				state: "MO"
			}
		};
		this.isCoorporatePopupOpen = true;
		setTimeout(() => {
			this.focusFirstEle();
		}, 200);
	}

	closeModalcoorporate() {
		this.isCoorporatePopupOpen = false;
		this.isAuthContactPopupOpen = false;
		setTimeout(() => {
			this.focusOnInitialButton('corpOfficerFocusButton');
		}, 500);
	}

	saveCoorporateOfficer() {
		if (this.checkValidityCoorporateValidate()) {
			let duplicateEmailAndRole, validEmailAndRole;
			validEmailAndRole = true;
			let corpRoleField = this.template.querySelector(".corporateValidateEmail");
			if (this.corporateOfficerList.length > 0) {
				duplicateEmailAndRole = this.corporateOfficerList.find(
					(eachCorporateOfficer) =>
					eachCorporateOfficer.role === this.selectedCoorporateOfficerData.role
				);
			}
			if (duplicateEmailAndRole !== undefined && duplicateEmailAndRole !== null &&
				(this.preCorpRole === undefined || (this.preCorpRole !== undefined && corpRoleField.value !== this.preCorpRole))) {
				this.isCoorporatePopupOpen = true;
				this.showToastMessage(
					"Error!",
					"Record already exists with this Email and Role. Please select unique.",
					"error",
					"dismissable"
				);
				validEmailAndRole = false;
			}
			if(validEmailAndRole){
				var msg;
				if (this.isContactUpdate) {
					msg = "Corporate Officer has been updated successfully";
					this.isContactUpdate = false;
				} else {
					msg = "Corporate Officer has been added successfully";
				}
				this.showToastMessage(
					"Success",
					msg,
					"success",
					"dismissible"
				);
				if (
					this.selectedCoorporateOfficerData.index !== undefined &&
					this.selectedCoorporateOfficerData.index !== "" &&
					this.selectedCoorporateOfficerData.index !== null
				) {
					this.isCoorporatePopupOpen = false;
					this.corporateOfficerList[this.selectedCoorporateOfficerData.index] =
						this.selectedCoorporateOfficerData;
					this.preCorpRole = "";
				} else {
					this.isCoorporatePopupOpen = false;
					this.selectedCoorporateOfficerData.index = this.corporateOfficerList.length;
					this.corporateOfficerList.push(this.selectedCoorporateOfficerData);
				}
			}
		} else {
			this.focus = false;
			this.focusIndex = -1;
			let isAllValid = [...this.template.querySelectorAll('.coorporateValidate')].reduce((validSoFar, input) => {
				input.reportValidity();
				let valid = input.checkValidity();
				if (!valid && (!this.focus || this.focusIndex == -1 || this.focusIndex > parseInt(input.dataset.index))) {
					input.focus();
					this.focus = true;
					this.focusIndex = input.dataset.index;
				}
				return validSoFar && valid;
			}, true);
		}
	}

	handleCoorporateEdit(event) {
		this.selectedCoorporateOfficerData = JSON.parse(
			JSON.stringify(this.corporateOfficerList[event.currentTarget.dataset.index])
		);
		this.preCorpRole = this.selectedCoorporateOfficerData.role;
		this.isContactUpdate = true;
		this.isCoorporatePopupOpen = true;
	}

	handleCoorporateDelete(event) {
		this.modalHeading = "Are you sure you want to delete this Coorporate Officer Detail?";
		this.selectedCorporateIndex = event.target.dataset.index;
		this.openConfirmationModal = true;
		setTimeout(() => {
			this.focusFirstEle();
		}, 200);
	}
	handleCancelConfirmation() {
		this.selectedCorporateIndex = null;
		this.selectedAuthContactIndex = null;
		this.openConfirmationModal = false;
		if (this.modalHeading === "Are you sure you want to delete this Authorized Contact?") {
			setTimeout(() => {
				this.focusOnInitialButton('authDeleteCancelFocus');
			}, 500);
		}
		if (this.modalHeading === "Are you sure you want to delete this Coorporate Officer Detail?") {
			setTimeout(() => {
				this.focusOnInitialButton('corpDeleteCancelFocus');
			}, 500);
		}

	}

	handleDeleteConfirmation() {
		let tempKey;
		let temparr = [];
		if (this.modalHeading === "Are you sure you want to delete this Coorporate Officer Detail?") {
			console.log('corp' + this.cancelIscorp);
			temparr = [...this.coorporateOfficerList];
			temparr.splice(Number(this.selectedCorporateIndex), 1);
			this.coorporateOfficerList = [...temparr];
			this.openConfirmationModal = false;
			this.tempKey = "Coorporate Officer Detail Deleted Successfully";
		} else if (this.modalHeading === "Are you sure you want to delete this Authorized Contact?") {
			console.log('corp' + this.cancelIscorp);
			temparr = [...this.authContactList];
			temparr.splice(Number(this.selectedAuthContactIndex), 1);
			//Added for S-58916 -- Start
			this.authContactList  = temparr.map((dataRow, index)=>{
				return{...dataRow, ...{index : index}}
			})
			//Added for S-58916 -- End
			this.openConfirmationModal = false;
			this.tempKey = "Authorized Contact Deleted Successfully";
		}
		console.log('@@' + this.tempKey);
		this.showToastMessage(
			"Success",
			this.tempKey,
			"success",
			"dismissible"
		);
	}

	handleCoorporateInputs(event) {
		if (event.target.name.split(".").length > 1) {
			this.selectedCoorporateOfficerData[event.target.name.split(".")[0]][event.target.name.split(".")[1]] =
				event.target.value.trim();
		} else {
			this.selectedCoorporateOfficerData[event.target.name.split(".")[0]] = event.target.value.trim();
		}

		if (
			event.target.name === "addressData.country" &&
			this.selectedCoorporateOfficerData.addressData.country === "US"
		) {
			this.selectedCoorporateOfficerData.addressData.stateText = null;
			this.selectedCoorporateOfficerData.addressData.state = "MO";
		} else if (event.target.name === "addressData.country") {
			this.selectedCoorporateOfficerData.addressData.state = null;
		}
	}

	handleAuthInputs(event) {
		if (event.target.name.split(".").length > 1) {
			this.selectedAuthContactData[event.target.name.split(".")[0]][event.target.name.split(".")[1]] =
				event.target.value.trim();
		} else {
			this.selectedAuthContactData[event.target.name.split(".")[0]] = event.target.value.trim();
		}

		if (event.target.name === "addressData.country" && this.selectedAuthContactData.addressData.country === "US") {
			this.selectedAuthContactData.addressData.stateText = null;
			this.selectedAuthContactData.addressData.state = "MO";
		} else if (event.target.name === "addressData.country") {
			this.selectedAuthContactData.addressData.state = null;
		}
		// Added for Accessibily issue
		this.selectedAuthContactData.editButtonAriaLabel = 'Edit ' +
			this.selectedAuthContactData.firstName +
			(this.selectedAuthContactData.middleName ? ' ' + this.selectedAuthContactData.middleName : '') +
			' ' +
			this.selectedAuthContactData.lastName +
			' Authorized Contact';
		this.selectedAuthContactData.deleteButtonAriaLabel = 'Delete ' +
			this.selectedAuthContactData.firstName +
			(this.selectedAuthContactData.middleName ? ' ' + this.selectedAuthContactData.middleName : '') +
			' ' +
			this.selectedAuthContactData.lastName +
			' Authorized Contact';
	}

	focusOnInitialButton(className) {
		var focusOnInitial = this.template.querySelector(`.${className}`);
		if (focusOnInitial) {
			focusOnInitial.focus();
		}
	}


	hideErrorMessage() {
		this.hasError = false;
		this.errorMessage = "";
	}

	//show error
	showErrorToastAndConsole(error) {
		if (error && error.body && error.body.pageErrors && error.body.pageErrors[0].message) {
			this.showToastMessage(
				"Error!",
				error.body.pageErrors[0].statusCode + " : " + error.body.pageErrors[0].message,
				"error",
				"dismissible"
			);
		} else {
			this.showToastMessage("Error!", JSON.stringify(error), "error", "dismissible");
		}
	}

	//for showing toast message
	showToastMessage(title, message, variant, mode) {
		const event = new ShowToastEvent({
			title: title,
			message: message,
			variant: variant,
			mode: mode
		});
		this.dispatchEvent(event);
	}

	isValid() {
		let valid = false;

		valid = [
			...this.template.querySelectorAll(
				"lightning-combobox, lightning-input"
			)
		].reduce((validSoFar, input) => {
			if (input.type === "date") {
				if (!input.checkValidity()) {
					input.classList.add("slds-has-error");
				} else {
					input.classList.remove("slds-has-error");
				}
			}
			input.reportValidity();
			return validSoFar && input.checkValidity();
		});
		return valid;
	}

	checkValidityCoorporateValidate() {
		let valid = false;

		valid = [...this.template.querySelectorAll(".coorporateValidate")].reduce((validSoFar, input) => {
			if (input.type === "date") {
				if (!input.checkValidity()) {
					input.classList.add("slds-has-error");
				} else {
					input.classList.remove("slds-has-error");
				}
			}
			input.reportValidity();
			return validSoFar && input.checkValidity();
		}, true);
		return valid;
	}

	checkValidityAuthValidate() {
		let valid = false;

		valid = [...this.template.querySelectorAll(".authContactValidate")].reduce((validSoFar, input) => {
			if (input.type === "date") {
				if (!input.checkValidity()) {
					input.classList.add("slds-has-error");
				} else {
					input.classList.remove("slds-has-error");
				}
			}
			input.reportValidity();
			return validSoFar && input.checkValidity();
		});
		return valid;
	}

	setTodaysDate() {
		let today = new Date();
		let dd = today.getDate();
		let mm = today.getMonth() + 1; //As January is 0.
		let yyyy = today.getFullYear();

		if (dd < 10) dd = "0" + dd;
		if (mm < 10) mm = "0" + mm;
		this.todayDate = mm + "/" + dd + "/" + yyyy;
	}

	//Masking the EIN Number
	maskingEIN(einResp) {
		console.log('ENtered Maasking SSn>>');
		//  converting from 123456789  -->  12-3456789
		let temp = einResp;
		let newTemp = "";
		let i = 0;
		do {
			if (i < temp.length) {
				newTemp = newTemp + temp.substring(i, i + 1);
				if (i == 1) {
					newTemp = newTemp + "-";
				}
			}
			i = i + 1;
		} while (i < temp.length);

		// Again Changing the value on UI once User left that field
		this.dataObj.employerIdentificationNum = newTemp;
		let einPattern = /^\d{2}-\d{7}$/;
		let einRegex = new RegExp(einPattern);

		if (einRegex.test(this.dataObj.employerIdentificationNum)) {} else {}
	}

	formatPhoneNumber(event) {
		// Remove all non-digit characters
		let phoneNumber = event.target.value.replace(/\D/g, "");
		// Format the phone number as (XXX) XXX-XXXX
		let formattedPhoneNumber = phoneNumber.replace(/(\d{3})(\d{3})(\d{4})/, "($1) $2-$3");
		// Set the formatted phone number back to the input value
		event.target.value = formattedPhoneNumber;
	}

	recoverOrignalPhone(event) {
		let phoneNumber = event.target.value.replace(/\D/g, "");
		event.target.value = phoneNumber;
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
	handleEscKeyDown(event) {
		if (event.code === 'Escape' || event.keyCode === 27) {
			this.openConfirmationModal = false;
			//Added for S-57276
			this.handleCancelConfirmation();
			if(this.isAuthContactPopupOpen) {
			   this.closeModelAuthContact();
			}
			if(this.isCoorporatePopupOpen) {
				this.closeModalcoorporate();
			}
		}
	}
	//Navigating to Dashboard page
	navigateToDashboardPage() {
		this[NavigationMixin.Navigate]({
				type: "standard__webPage",
				attributes: {
					url: "/license/s/"
				}
			},
			true
		);
	}
}