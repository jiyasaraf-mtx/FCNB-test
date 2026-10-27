import {
	LightningElement,
	track,
	wire
} from "lwc";
import {
	NavigationMixin
} from "lightning/navigation";
import {
	ShowToastEvent
} from "lightning/platformShowToastEvent";
import {
	getPicklistValues,
	getObjectInfo
} from "lightning/uiObjectInfoApi";

//Apex Methods
import fetchRegistrationFormWrapper from "@salesforce/apex/LPI_RegisterController.fetchRegistrationFormWrapperForBusiness";
import doFinishRegistration from "@salesforce/apex/LPI_RegisterController.doFinishRegistrationCapctchaForBusiness";
import validateUserAndCreateUser from "@salesforce/apex/LPI_RegisterController.validateUserAndCreateUserForBusiness";
import resendOtp from "@salesforce/apex/LPI_RegisterController.resendOtp";
import fetchCityCounty from "@salesforce/apex/LPI_RegisterController.getDataToPrepopulateBasedOnZipCode";
import getSecurityQuestions from "@salesforce/apex/LPI_FindUserName.getSecurityQuestions";

//Object, Field and picklist
import ContactState from "@salesforce/schema/Account.PersonOtherStateCode";
import ContactCountry from "@salesforce/schema/Account.PersonOtherCountryCode";
import CONTACT_OBJECT from "@salesforce/schema/Contact";
import USER_ID from "@salesforce/user/Id";
import lpiResource from '@salesforce/resourceUrl/LPI_Design';
import getLabels from '@salesforce/apex/EMP_LanguageCtrl.getLabels';
import {
	PUBLIC_PAGE_LABEL_API_NAMES,
	mapApiToCamel,
	readStoredLanguage
} from 'c/lpLanguageUtils';


export default class LpiBusinessRegister extends NavigationMixin(LightningElement) {
	//Resource URL
	logo = lpiResource + '/media/images/ibm-logo-white.svg';
	userId = USER_ID;
	@track labels = {
		regGoBackSelection: 'Go Back To Selection',
		regAlready: 'Already Registered?',
		regLogin: 'Login',
		regSidebarIntro: 'The portal provides guidance across all regulated financial and consumer sectors in New Brunswick, connecting you directly to FCNB resources and rules.',
		regCopyright: '© Financial and Consumer Services Commission (FCNB)',
		regBusiness: 'Register for a Business'
	};

	@track stateOptions = [];
	@track coorporateIndex = null;
	@track countryOptions = [];
	@track dataObj = {};
	@track otpResent = false;
	@track resentCount = 0;
	@track buttonName = "";

	//ContactLists
	isCoorporatePopupOpen = false;
	@track coorporateOfficerList = [];
	@track selectedCoorporateOfficerData = {
		addressData: {
			country: "CA"
			//state: "MO"
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
	initCall = true;
	isShowRegistrationForm = true;
	hasError = false;
	errorMessage = "";
	hasSuccess = false;
	successMessage = "";
	showOtp = false;
	todayDate;

	emailMismatch = false;
	showIdentityType = false;
	showSSN = false;
	correctSsn;
	cmpLoaded = false;

	urlLanguage = "en_US";

	recaptchaDiv;
	recaptchaDivStyle;
	// v2RenderCalled;
	token;
	otp;
	openConfirmationModal = false;
	patternObj = {
		text: "^((?!(<)|(>)).)*$",
		digits: "^(\\([0-9]{3}\\) |[0-9]{3}-)[0-9]{3}-[0-9]{4}$",
		email: "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,10}$",
		zipCode: "^[0-9]{5}(?:-[0-9]{4})?$",
		zipCodeUS: "^[0-9]{5}?$",
		zipCodeNonUS: "^[a-zA-Z0-9]*$",
		ssn: "^[0-9X-]{1,}$",
		phone: "[0-9\(\)\-\s]*",
		name: "^[A-Za-z0-9 ]+$",
		dob: "^[A-Za-z0-9 ]+$"
	};
	//Added for S-56790 - Start
	@track questions = [];
	@track selectedSecurityQuestions = {};
	@track securityQuestionAnswer = {};
	@track maxErrorMessage = '';

	selectedValue = '';
	//Added for S-56790 - End
	//58196
	showAuthContactEmailField = false;
	businessOutsideUSOptions = [
		{ label: 'Yes', value: "Yes" },
		{ label: 'No', value: "No" }
	]
	// GET OBJECT INFO
	@wire(getObjectInfo, {
		objectApiName: CONTACT_OBJECT
	})
	objectInfo;

	// GET PICKLIST VALUES OF STATE FIELD
	@wire(getPicklistValues, {
		recordTypeId: "$objectInfo.data.defaultRecordTypeId",
		fieldApiName: ContactState
	})
	wiredPicklistValues({
		error,
		data
	}) {
		try {
			this.showSpinner = true;
			if (data && data.values) {
				this.stateOptions = data.values;
				this.showSpinner = false;
			} else if (error) {
				this.showSpinner = false;
			}
		} catch (e) {
			console.log("error wiredPicklistValues" + JSON.stringify(error));
		}
	}

	// GET PICKLIST VALUES OF COUNTRY FIELD
	@wire(getPicklistValues, {
		recordTypeId: "$objectInfo.data.defaultRecordTypeId",
		fieldApiName: ContactCountry
	})
	wiredCountryPicklistValues({
		error,
		data
	}) {
		try {
			this.showSpinner = true;
			if (data && data.values) {
				this.countryOptions = data.values;

				this.showSpinner = false;
			} else if (error) {
				this.showSpinner = false;
			}
		} catch (e) {
			console.log("error wiredCountryPicklistValues" + JSON.stringify(error));
		}
	}

	get roleOptions() {
		return [{
			label: "Board Director",
			value: "Board Director"
		},
		{
			label: "CEO",
			value: "CEO"
		},
		{
			label: "CFO (Chief Financial Officer)",
			value: "CFO (Chief Financial Officer)"
		},
		{
			label: "Chairperson",
			value: "Chairperson"
		},
		{
			label: "COO",
			value: "COO"
		},
		{
			label: "Corporate Officer",
			value: "Corporate Officer"
		},
		{
			label: "Director",
			value: "Director"
		},
		{
			label: "Executive Vice President",
			value: "Executive Vice President"
		},
		{
			label: "President",
			value: "President"
		},
		{
			label: "Principal",
			value: "Principal"
		},
		{
			label: "Secretary",
			value: "Secretary"
		},
		{
			label: "Senior Vice President",
			value: "Senior Vice President"
		},
		{
			label: "Shareholder",
			value: "Shareholder"
		},
		{
			label: "Treasurer",
			value: "Treasurer"
		},
		{
			label: "Vice President",
			value: "Vice President"
		},
		{
			label: "Other",
			value: "Other"
		}
		];
	}

	// get recaptchaDivTabIndex() {
	// 	return this.v2RenderCalled ? 0 : -1;
	// }

	get isBusinessAddressUS() {
		let temp = this.dataObj.businessAddress && this.dataObj.businessAddress.country === "CA" ? true : false;
		if (!temp) {
			this.dataObj.businessAddress.state = null;
		}
		return temp;
	}

	get isCoorporateAddressUS() {
		let temp =
			this.selectedCoorporateOfficerData.addressData &&
				this.selectedCoorporateOfficerData.addressData.country &&
				this.selectedCoorporateOfficerData.addressData.country === "CA" ?
				true :
				false;
		if (!temp) {
			this.selectedCoorporateOfficerData.addressData.state = null;
		}
		return temp;
	}

	get displayCoorporateOfficerList() {
		return this.coorporateOfficerList && this.coorporateOfficerList.length > 0;
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

	connectedCallback() {
		this.loadPublicPageLabels();
		this.securityQuestionGetter(); //Added for S-56790
		if (!this.userId) {
			this.setTodaysDate();
			this.checkAutomationAI();

			setTimeout(
				function () {
					document.dispatchEvent(new CustomEvent("checkAutomation"));
				}.bind(this),
				1000
			);
		}
	}

	loadPublicPageLabels() {
		const lang = readStoredLanguage() || 'en_US';
		const apiNames = PUBLIC_PAGE_LABEL_API_NAMES.filter((n) => n.startsWith('LP_Reg_'));
		getLabels({ apiNames, language: lang })
			.then((apiMap) => {
				this.labels = { ...this.labels, ...mapApiToCamel(apiMap) };
			})
			.catch(() => {
				// keep English defaults
			});
	}

	checkAutomationAI() {
		let _this = this;
		document.addEventListener("automationDetected", (event) => {
			if (!event.detail) {
				if (!_this.initCall) {
					if (this.buttonName === "Registor") {
						console.log('button clicked');
						_this.handleFinishRegistration();
					} else if (this.buttonName === "VerifyOTP") {
						_this.verifyOTP();
					}
				} else {
					_this.isShowRegistrationForm = true;
					_this.doInit();

					//reCaptcha
					_this._captchaResponse = _this.captchaResponse.bind(_this);
					document.addEventListener("grecaptchaVerified", this._captchaResponse);

					// // event for recaptcha v2
					// _this._captchaV2Response = _this.captchaV2Response.bind(_this);
					// document.addEventListener("grecaptchaV2VerifiedSubmit", _this._captchaV2Response);

					// // event for recaptcha v2 Expired
					// _this._captchaV2Expired = _this.captchaV2Expired.bind(_this);
					// document.addEventListener("grecaptchaV2ExpiredSubmit", _this._captchaV2Expired);
					//reCaptcha

					_this.initCall = false;
				}
			} else {
				_this.showSpinner = false;
				_this.errorMessage =
					"Seems like you are trying to use automated scripts to fill this form. Please fill this form manually.";
				_this.hasError = true;
				_this.isShowRegistrationForm = false;
				_this.cmpLoaded = true;
			}
		});
	}

	doInit() {
		this.hideErrorMessage();
		this.cmpLoaded = false;
		this.showSpinner = true;

		fetchRegistrationFormWrapper()
			.then((result) => {
				this.cmpLoaded = false;
				this.dataObj = result;
				if (this.dataObj.businessAddress.country === "") {
					this.dataObj.businessAddress.country = "US";
					//this.dataObj.businessAddress.state = "MO";
				}
				this.cmpLoaded = true;
				//focusing the first element - Added by Piyush Aneja
				// eslint-disable-next-line @lwc/lwc/no-async-operation
				setTimeout(() => {
					const registerMessage = this.template.querySelector(".validateFirst");
					if (registerMessage) {
						registerMessage.focus();
					}
				}, 3000);
				this.showSpinner = false;
			})
			.catch((error) => {
				if (Array.isArray(error.body)) {
					this.errorMessage = error.body.map((e) => e.message).join(", ");
				} else if (typeof error.body.message === "string") {
					this.errorMessage = error.body.message;
				}
				window.scrollTo(0, 0);
				this.hasError = true;
				this.showSpinner = false;
				this.cmpLoaded = true;
			});
	}

	addAuthContact() {
		this.selectedAuthContactData = {};
		console.log('Length >>>' + this.authContactList.length);
		try {
			if (this.authContactList.length < 3) {
				this.isAuthContactPopupOpen = true;
			} else if (this.authContactList.length >= 3) {
				throw new Error('You cannot add more than 3 authorized contacts.');
			}
			//Added for story S-58916 -- Start
			if (this.authContactList && this.authContactList.length < 1) {
				this.showAuthContactEmailField = true;
			} else {
				this.showAuthContactEmailField = false;
			}
			//Added for story S-58916 -- End
			setTimeout(() => {
				this.focusFirstEle();
			}, 200);
		} catch (error) {
			this.maxErrorMessage = error.message;
			console.error(error.message);
		}
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
			// this.focus = false;
			// this.focusIndex = -1;
			// let isAllValid = [...this.template.querySelectorAll('.authContactValidate')].reduce((validSoFar, input) => {
			// 	input.reportValidity();
			// 	let valid = input.checkValidity();
			// 	if (!valid && (!this.focus || this.focusIndex == -1 || this.focusIndex > parseInt(input.dataset.index))) {
			// 		input.focus();
			// 		this.focus = true;
			// 		this.focusIndex = input.dataset.index;
			// 	}
			// 	return validSoFar && valid;
			// });
		}
	}

	handleAuthContactEdit(event) {
		this.selectedAuthContactData = Object.assign({}, this.authContactList[event.currentTarget.dataset.index]);
		this.isContactUpdate = true;
		this.isAuthContactPopupOpen = true;
		//Added for story S-58916 -- Start
		if (this.selectedAuthContactData.index == 0) {
			this.showAuthContactEmailField = true;
		} else {
			this.showAuthContactEmailField = false;
		}
		console.log('## ' + this.selectedAuthContactData.index);
		//Added for story S-58916 -- End
	}

	handleAuthDelete(event) {
		this.modalHeading = "Are you sure you want to delete this Authorized Contact?";
		this.selectedAuthContactIndex = event.currentTarget.dataset.index;
		this.openConfirmationModal = true;
		setTimeout(() => {
			this.focusFirstEle();
		}, 200);
		console.log('$$ ' + selectedAuthContactIndex);
	}

	addCoorprateOfficer() {
		this.selectedCoorporateOfficerData = {
			addressData: {
				country: "CA"
				//state: "MO"
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
			if (this.coorporateIndex != null) {
				this.setFocusOnMenuButton(this.coorporateIndex);
			}
			else{
				this.focusOnInitialButton('corpOfficerFocusButton');
			}
			this.coorporateIndex = null;
		}, 500);
	}

	saveCoorporateOfficer() {
		if (this.checkValidityCoorporateValidate()) {
			let duplicateEmailAndRole, validEmailAndRole;
			validEmailAndRole = true;
			let corpRoleField = this.template.querySelector(".corporateValidateEmail");
			if (this.coorporateOfficerList.length > 0) {
				duplicateEmailAndRole = this.coorporateOfficerList.find(
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
			if (validEmailAndRole) {
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
					this.coorporateOfficerList[this.selectedCoorporateOfficerData.index] =
						this.selectedCoorporateOfficerData;
					this.preCorpRole = "";
					setTimeout(() => {
						this.setFocusOnMenuButton(this.coorporateIndex);
						this.coorporateIndex = null;
					}, 200);
					
				} else {
					this.isCoorporatePopupOpen = false;
					this.selectedCoorporateOfficerData.index = this.coorporateOfficerList.length;
					this.coorporateOfficerList.push(this.selectedCoorporateOfficerData);
					setTimeout(() => {
						this.focusOnInitialButton('corpOfficerFocusButton');
					}, 200);
				}
				
			}
		} else {
			// this.focus = false;
			// this.focusIndex = -1;
			// let isAllValid = [...this.template.querySelectorAll('.coorporateValidate')].reduce((validSoFar, input) => {
			// 	input.reportValidity();
			// 	let valid = input.checkValidity();
			// 	if (!valid && (!this.focus || this.focusIndex == -1 || this.focusIndex > parseInt(input.dataset.index))) {
			// 		input.focus();
			// 		this.focus = true;
			// 		this.focusIndex = input.dataset.index;
			// 	}
			// 	return validSoFar && valid;
			// });
		}
	}

	handleCoorporateEdit(event) {
		this.coorporateIndex = event.currentTarget.dataset.index;
		this.selectedCoorporateOfficerData = JSON.parse(
			JSON.stringify(this.coorporateOfficerList[event.currentTarget.dataset.index])
		);
		this.preCorpRole = this.selectedCoorporateOfficerData.role;
		this.isContactUpdate = true;
		this.isCoorporatePopupOpen = true;
		setTimeout(() => {
			this.focusFirstEle();
		}, 200);
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
		this.openConfirmationModal = false;
		if (this.modalHeading === "Are you sure you want to delete this Authorized Contact?") {
			setTimeout(() => {
				this.focusOnInitialButton('authContactFocusButton');
			}, 500);
		}
		if (this.modalHeading === "Are you sure you want to delete this Coorporate Officer Detail?") {
			setTimeout(() => {
				this.setFocusOnMenuButton(this.selectedCorporateIndex);
				this.selectedCorporateIndex = null;
				// this.focusOnInitialButton('corpOfficerFocusButton');
			}, 500);
		}
		this.selectedAuthContactIndex = null;
	}

	handleDeleteConfirmation() {
		let tempKey;
		let temparr = [];
		if (this.modalHeading === "Are you sure you want to delete this Coorporate Officer Detail?") {
			temparr = [...this.coorporateOfficerList];
			temparr.splice(Number(this.selectedCorporateIndex), 1);
			this.coorporateOfficerList = [...temparr];
			this.openConfirmationModal = false;
			this.tempKey = "Coorporate Officer Detail Deleted Successfully";
		} else if (this.modalHeading === "Are you sure you want to delete this Authorized Contact?") {
			temparr = [...this.authContactList];
			temparr.splice(Number(this.selectedAuthContactIndex), 1);
			this.authContactList = temparr.map((dataRow, index) => {
				return { ...dataRow, ...{ index: index } }
			})
			this.openConfirmationModal = false;
			this.tempKey = "Authorized Contact Deleted Successfully";
		}
		this.showToastMessage(
			"Success",
			this.tempKey,
			"success",
			"dismissible"
		);
		setTimeout(() => {
			this.focusOnInitialButton('corpOfficerFocusButton');
		}, 500);
	}

	handleInputs(event) {
		this.hideErrorMessage();
		this.hasError = false;
		if (event.target.type === "checkbox") {
			if (event.target.name.split(".").length > 1) {
				this.dataObj[event.target.name.split(".")[0]][event.target.name.split(".")[1]] = event.target.checked;
			} else {
				this.dataObj[event.target.name.split(".")[0]] = event.target.checked;
			}
		} else {
			if (event.target.name.split(".").length > 1) {
				this.dataObj[event.target.name.split(".")[0]][event.target.name.split(".")[1]] =
					event.target.value.trim();
			} else {
				this.dataObj[event.target.name.split(".")[0]] = event.target.value.trim();
			}
		}

		// setting text field as null when user select any other country, other than US
		if (event.target.name === "businessAddress.country" && this.dataObj.businessAddress.country === "CA") {
			this.dataObj.businessAddress.stateText = null;
			//this.dataObj.businessAddress.state = "MO";
		} else if (event.target.name === "businessAddress.country") {
			this.dataObj.businessAddress.state = null;
		}

		if (event.target.name == "businessAddress.zipcode" && event.target.value.length >= 5 && this.dataObj.businessAddress.country == "CA") {
			fetchCityCounty({ zipcode: event.target.value })
				.then((result) => {
					if (result) {
						this.dataObj.businessAddress.city = result.city;
						this.dataObj.businessAddress.county = result.county;
					}
				})
				.catch(error => {
					console.error("An unexpected error occurred:", JSON.stringify(error));
				});
		}
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
			this.selectedCoorporateOfficerData.addressData.country === "CA"
		) {
			this.selectedCoorporateOfficerData.addressData.stateText = null;
			//this.selectedCoorporateOfficerData.addressData.state = "MO";
		} else if (event.target.name === "addressData.country") {
			this.selectedCoorporateOfficerData.addressData.state = null;
		}

		if (event.target.name == "addressData.zipcode" && event.target.value.length >= 5 && this.selectedCoorporateOfficerData.addressData.country == "CA") {
			fetchCityCounty({ zipcode: event.target.value })
				.then((result) => {
					if (result) {
						this.selectedCoorporateOfficerData.addressData.city = result.city;
						this.selectedCoorporateOfficerData.addressData.county = result.county;
					}
				})
				.catch(error => {
					console.error("An unexpected error occurred:", JSON.stringify(error));
				});
		}
	}

	handleAuthInputs(event) {
		if (event.target.name.split(".").length > 1) {
			this.selectedAuthContactData[event.target.name.split(".")[0]][event.target.name.split(".")[1]] =
				event.target.value.trim();
		} else {
			this.selectedAuthContactData[event.target.name.split(".")[0]] = event.target.value.trim();
		}

		if (event.target.name === "addressData.country" && this.selectedAuthContactData.addressData.country === "CA") {
			this.selectedAuthContactData.addressData.stateText = null;
			//this.selectedAuthContactData.addressData.state = "MO";
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

	checkAutomationAndNext() {
		this.buttonName = "Registor";
		document.dispatchEvent(new CustomEvent("checkAutomation"));

	}

	// captchaV2Expired() {
	// 	this.token = undefined;
	// 	this;
	// 	this.v2Verified = false;
	// }

	// captchaV2Response(e) {
	// 	if (e.detail && JSON.stringify(e.detail)) {
	// 		this.token = e.detail.response;
	// 		this.hasError = false;
	// 		this.hideErrorMessage();
	// 	}
	// }

	captchaResponse(e) {
		if (e.detail && JSON.stringify(e.detail) && this.isValid()) {
			if (this.buttonName === "Registor") {
				this.doRegistration("v3", JSON.stringify(e.detail));
			} else if (this.buttonName === "VerifyOTP") {
				this.doOTPVerification("v3", JSON.stringify(e.detail));
			}
		}
		// else {
		// 	this.showSpinner = false;
		// 	if (!this.v2RenderCalled) {
		// 		this.v2RenderCalled = true;
		// 		document.dispatchEvent(
		// 			new CustomEvent("grecaptchaV2RenderSubmit", {
		// 				detail: {
		// 					element: this.recaptchaDiv
		// 				}
		// 			})
		// 		);

		// 		// setting this to display block for the scenario where the user comes from the previous page again
		// 		this.recaptchaDivStyle = "display: block";
		// 		this.callSetTimeOutOnRecaptcha();
		// 	}
		// }
	}

	disconnectedCallback() {
		document.removeEventListener("grecaptchaVerified", this._captchaResponse);
		// document.removeEventListener("grecaptchaV2VerifiedSubmit", this._captchaV2Response);
		// document.removeEventListener("grecaptchaV2ExpiredSubmit", this._captchaV2Expired);
		if (this.sessionTimeout) {
			clearTimeout(this.sessionTimeout);
		}
		if (this.innerTimeout) {
			clearTimeout(this.innerTimeout);
		}
	}

	// renderedCallback() {
	// 	this.recaptchaDiv = this.template.querySelector(".recaptchaCheckbox2");
	// }

	handleFinishRegistration() {
		this.hideErrorMessage();
		this.showSpinner = true;
		if (this.isValid()) {
			if (this.coorporateOfficerList.length === 0 || this.authContactList.length === 0) {
				window.scrollTo(0, 0);
				if (this.coorporateOfficerList.length === 0 && this.authContactList.length === 0) {
					this.errorMessage = "Please provide Corporate Officer and Authorized Contact details.";
					setTimeout(() => {
						this.focusOnInitialButton('authContactFocusButton');
					}, 5000);
				} else if (this.authContactList.length === 0) {
					this.errorMessage = "Please provide Authorized Contact details.";
				} else if (this.coorporateOfficerList.length === 0) {
					this.errorMessage = "Please provide Corporate Officer details.";
				}
				this.hasError = true;
				this.showSpinner = false;
			} else {
				this.showSpinner = true;
				// Added for S-58916
				if (this.authContactList.length === 1 && this.authContactList[0]['email'] === undefined) {
					window.scrollTo(0, 0);
					this.errorMessage = "Please provide Email for first Authorized Contact.";
					this.hasError = true;
					this.showSpinner = false;
				} else if (this.token && this.isValid()) {
					this.doRegistration("v2", this.token);
				} else {
					// enforcing v2 to be checked if it has been rendered on the screen
					// if (this.v2RenderCalled) {
					// 	this.showSpinner = true;
					// 	this.errorMessage = "Please complete the captcha to continue";
					// 	this.hasError = true;
					// 	this.showSpinner = false;
					// } else {
					document.dispatchEvent(new CustomEvent("grecaptchaExecute"));
					// }
				}
			}
		} else {
			//window.scrollTo(0, 0);
			//Added By Piyush Aneja as the focus as well as validation error is not coming on the first field
			let validateFirstElement = this.template.querySelector(".validateFirst");
			validateFirstElement.classList.add("slds-has-error");
			validateFirstElement.setCustomValidity("Error: Business Name is required.");
			validateFirstElement.reportValidity();
			//Ended By Piyush Aneja as the focus as well as validation error is not coming on the first field

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
	focusOnInitialButton(className) {
		var focusOnInitial = this.template.querySelector(`.${className}`);
		if (focusOnInitial) {
			focusOnInitial.focus();
		}
	}

	doRegistration(ctype, ctoken) {
		this.dataObj.coorporateOfficerList = this.coorporateOfficerList.slice();
		this.dataObj.authContactList = this.authContactList.slice();
		//Added for S-56790 - Start
		let finalSecurityQuesJson = {}
		finalSecurityQuesJson[this.selectedSecurityQuestions.Question1] =
			this.securityQuestionAnswer[this.selectedSecurityQuestions.Question1]
		finalSecurityQuesJson[this.selectedSecurityQuestions.Question2] =
			this.securityQuestionAnswer[this.selectedSecurityQuestions.Question2]
		finalSecurityQuesJson[this.selectedSecurityQuestions.Question3] =
			this.securityQuestionAnswer[this.selectedSecurityQuestions.Question3]
		this.dataObj['securityQuestionAnswer'] = JSON.stringify(finalSecurityQuesJson);
		let zeroCount = (this.dataObj.moStateRegistrationNumber.match(/0/g) || []).length;
		if (zeroCount == this.dataObj.moStateRegistrationNumber.length) {
			this.dataObj.moStateRegistrationNumber = null;
		}

		zeroCount = (this.dataObj.newEmployerIdentificationNum.match(/0/g) || []).length;
		if (zeroCount == this.dataObj.newEmployerIdentificationNum.length) {
			this.dataObj.newEmployerIdentificationNum = null;
			this.dataObj.employerIdentificationNum = null;
		}

		//Added for S-56790 - End
		doFinishRegistration({
			wrapperData: JSON.stringify(this.dataObj),
			recaptchaResponse: ctoken,
			ctype: ctype
		})
			.then((result) => {
				if (result != null) {
					if (result.isV3Failed) {
						// if (!this.v2RenderCalled) {
						// 	this.v2RenderCalled = true;
						// 	document.dispatchEvent(
						// 		new CustomEvent("grecaptchaV2RenderSubmit", {
						// 			detail: {
						// 				element: this.recaptchaDiv
						// 			}
						// 		})
						// 	);
						// 	// setting this to display block for the scenario where the user comes from the previous page again
						// 	this.recaptchaDivStyle = "display: block";
						// 	this.disabledSubmit = false;
						// 	this.callSetTimeOutOnRecaptcha();
						// }
						this.showSpinner = false;
					} else if (result.isCaptchaInvalid) {
						this.showSpinner = false;
						this.errorMessage =
							"Seems like you are trying to use automated scripts to fill this form. Please fill this form manually.";
						this.hasError = true;
					} else {
						this.recaptchaDivStyle = "display: none";
						this.token = undefined;
						// this.v2RenderCalled = false;
						window.scrollTo(0, 0);
						this.showOtp = true;
						this.isShowRegistrationForm = false;
						this.buttonName = "";
						this.showSpinner = false;

						document.dispatchEvent(new CustomEvent("grecaptchaReset"));
						document.dispatchEvent(new CustomEvent("grecaptchaExecute"));
					}
				}
				this.showSpinner = false;
			})
			.catch((error) => {
				var errorMessage;
				if (typeof error.body.message === "string") {
					errorMessage = error.body.message;
				}
				// if (!this.v2RenderCalled) {
				// 	this.v2RenderCalled = true;
				// 	document.dispatchEvent(
				// 		new CustomEvent("grecaptchaV2RenderSubmit", {
				// 			detail: {
				// 				element: this.recaptchaDiv
				// 			}
				// 		})
				// 	);

				// 	// setting this to display block for the scenario where the user comes from the previous page again
				// 	this.recaptchaDivStyle = "display: block";
				// 	this.callSetTimeOutOnRecaptcha();
				// }

				this.errorMessage = errorMessage;

				window.scrollTo(0, 0);
				this.hasError = true;
				document.dispatchEvent(new CustomEvent("grecaptchaReset"));
				// document.dispatchEvent(new CustomEvent("grecaptchaV2ResetSubmit"));
				this.recaptchaDivStyle = "display: none";
				this.token = undefined;
				// this.v2RenderCalled = false;
				this.showSpinner = false;
			});
	}

	doHandleAlreadyHaveAnAccount(event) {
		event.preventDefault();
		window.location = this.dataObj.siteBaseUrl + "/s/login";
	}

	handleOtp(event) {
		this.otp = event.target.value;
		this.hasError = false;
		this.hideErrorMessage();
	}

	verifyOTPHandler() {
		this.buttonName = "VerifyOTP";
		document.dispatchEvent(new CustomEvent("checkAutomation"));
	}

	verifyOTP() {
		if (this.otp === undefined || this.otp === null) {
			let valid = [...this.template.querySelectorAll("lightning-input")].reduce((validSoFar, input) => {
				input.reportValidity();
				return validSoFar && input.checkValidity();
			}, true);
			let allInput = this.template.querySelector(".slds-has-error");

			if (allInput) {
				allInput.scrollIntoView();
				allInput.focus();
			}
		} else {
			if (this.token) {
				this.showSpinner = true;
				this.doOTPVerification("v2", this.token);
			} else {
				// enforcing v2 to be checked if it has been rendered on the screen
				// if (this.v2RenderCalled) {
				// 	this.showSpinner = true;
				// 	this.errorMessage = "Please complete the captcha to continue";
				// 	this.hasError = true;
				// 	this.showSpinner = false;
				// } else {
				document.dispatchEvent(new CustomEvent("grecaptchaExecute"));
				// }
			}
		}
	}

	doOTPVerification(ctype, ctoken) {
		this.hideErrorMessage();
		this.hasError = false;
		this.showSpinner = true;
		validateUserAndCreateUser({
			otpValue: this.otp,
			wrapperJSON: JSON.stringify(this.dataObj),
			recaptchaResponse: ctoken,
			ctype: ctype
		})
			.then((result) => {
				this.showSpinner = false;
				if (result != null) {
					if (result.isV3Failed) {
						// if (!this.v2RenderCalled) {
						// 	this.v2RenderCalled = true;
						// 	document.dispatchEvent(
						// 		new CustomEvent("grecaptchaV2RenderSubmit", {
						// 			detail: {
						// 				element: this.recaptchaDiv
						// 			}
						// 		})
						// 	);
						// 	// setting this to display block for the scenario where the user comes from the previous page again
						// 	this.recaptchaDivStyle = "display: block";
						// 	this.disabledSubmit = false;
						// 	this.callSetTimeOutOnRecaptcha();
						// }
						this.showSpinner = false;
					} else if (result.isCaptchaInvalid) {
						this.showSpinner = false;
						this.errorMessage =
							"Seems like you are trying to use automated scripts to fill this form. Please fill this form manually.";
						this.hasError = true;
					} else {
						if (result.isSuccess) {
							let makeSuccessMessage = "";
							this.showOtp = false;
							makeSuccessMessage +=
								"<b>" +
								"Thank you for registering. An email has been sent to your provided email address. The email will contain your user ID. You must click on the link in the email to set your password and access your account." +
								"</b>";
							this.successMessage = makeSuccessMessage;
							this.hasSuccess = true;

							document.dispatchEvent(new CustomEvent("grecaptchaReset"));
							// document.dispatchEvent(new CustomEvent("grecaptchaV2ResetSubmit"));
							this.recaptchaDivStyle = "display: none";
							this.token = undefined;
							// this.v2RenderCalled = false;
						} else if (!result.isSuccess) {
							//this.showOtp = false;
							this.hasError = true;
							this.token = undefined;
							if (result.message != "") {
								this.errorMessage = "<b>" + result.message + "</b>";
							} else {
								this.errorMessage = "<b>" + "Entered OTP is Incorrect !!" + "</b>";
							}
							this.focusOnWrongOtp();
						}
						this.token = undefined;
						document.dispatchEvent(new CustomEvent("grecaptchaReset"));
						// document.dispatchEvent(new CustomEvent("grecaptchaV2ResetSubmit"));

						this.showSpinner = false;
					}
				}
			})
			.catch((error) => {
				var errorMessage;
				if (typeof error.body.message === "string") {
					errorMessage = error.body.message;
				}
				// if (!this.v2RenderCalled) {
				// 	this.v2RenderCalled = true;
				// 	document.dispatchEvent(
				// 		new CustomEvent("grecaptchaV2RenderSubmit", {
				// 			detail: {
				// 				element: this.recaptchaDiv
				// 			}
				// 		})
				// 	);

				// 	// setting this to display block for the scenario where the user comes from the previous page again
				// 	this.recaptchaDivStyle = "display: block";
				// 	this.callSetTimeOutOnRecaptcha();
				// }

				this.errorMessage = errorMessage;

				window.scrollTo(0, 0);
				this.hasError = true;
				document.dispatchEvent(new CustomEvent("grecaptchaReset"));
				// document.dispatchEvent(new CustomEvent("grecaptchaV2ResetSubmit"));
				this.recaptchaDivStyle = "display: none";
				this.token = undefined;
				// this.v2RenderCalled = false;
				this.showSpinner = false;
			});
	}

	resendOTPHandler() {
		this.hideErrorMessage();
		if (this.resentCount === 3) {
			this.showToastMessage(
				"",
				"You have exceeded the maximum otp limit. Please try after some time.",
				"error",
				"dismissable"
			);
		} else {
			this.showSpinner = true;
			resendOtp({
				emailValue: this.dataObj.businessEmail
			})
				.then((result) => {
					this.resentCount = this.resentCount + 1;
					this.showSpinner = false;
					if (result != null) {
						this.otpResent = true;
						this.showToastMessage(
							"",
							"A One-Time Password has been resent to the Business email address.",
							"success",
							"sticky"
						);
						this.showSpinner = false;
					}
				})
				.catch((error) => {
					var errorMessage;
					if (typeof error.body.message === "string") {
						errorMessage = error.body.message;
					}

					this.errorMessage = errorMessage;
					this.hasError = true;
					this.showSpinner = false;
				});
		}
	}

	focusOnWrongOtp() {
		let element;
		setTimeout(() => {
			element = this.template.querySelector(".focus-helper");
			if (element) {
				element.focus();
			}
		}, 1000);

		setTimeout(() => {
			if (element) {
				element.blur();
			}
		}, 3000);
	}

	hideErrorMessage() {
		this.hasError = false;
		this.errorMessage = "";
	}

	callSetTimeOutOnRecaptcha() {
		setTimeout(() => this.recaptchaDiv.focus(), 0);
	}

	//Masking the SSN Number
	/* 	maskingSSN(event) {
			this.correctSsn = event.target.value;
			let tmp = this.template.querySelector(".ssnValidity");
			tmp.setCustomValidity("");
	
			if (this.selectedCoorporateOfficerData.ssn != null) {
				const regex = /\d(?=\d{4})/gm;
				const subst = `X`;
				this.selectedCoorporateOfficerData.ssn = this.selectedCoorporateOfficerData.ssn.replace(regex, subst);
			}
			this.selectedCoorporateOfficerData.newssn = this.correctSsn;
	
			//  converting from XXXXX4234  -->  XXX-XX-4234
			let temp = this.selectedCoorporateOfficerData.ssn;
			let newTemp = "";
			let i = 0;
			do {
				if (i < temp.length) {
					newTemp = newTemp + temp.substring(i, i + 1);
					if (i == 2) {
						newTemp = newTemp + "-";
					}
					if (i == 4) {
						newTemp = newTemp + "-";s
					}
				}
				i = i + 1;
			} while (i < temp.length);
	
			// Again Changing the value on UI once User left that field
			this.selectedCoorporateOfficerData.ssn = newTemp;
			if (newTemp.length != 11) {
				tmp.setCustomValidity("Please enter correct SSN only!");
			}
			tmp.reportValidity();
		} */

	//Recovering masked SSN Number
	/* recorveringOrginalSSN() {
		this.selectedCoorporateOfficerData.ssn = this.selectedCoorporateOfficerData.newssn;
	} */
	//Recovering masked EIN Number
	recorveringOrginalEIN() {
		this.dataObj.employerIdentificationNum = this.dataObj.newEmployerIdentificationNum;
	}

	goBackToSelection() {
		this.navigateToRegistration();
	}

	//Navigating to login page
	navigateToRegistration() {
		// this[NavigationMixin.Navigate]({
		// 		type: "standard__webPage",
		// 		attributes: {
		// 			url: "/s/registration"
		// 		}
		// 	},
		// 	true
		// );
		this[NavigationMixin.Navigate]({
			type: "comm__namedPage",
			attributes: {
				name: "Registration__c"
			}
		},
			true
		);
	}

	//Navigating to login page
	navigateToLoginPage() {
		// this[NavigationMixin.Navigate]({
		// 		type: "standard__webPage",
		// 		attributes: {
		// 			url: "/license/s/login"
		// 		}
		// 	},
		// 	true
		// );
		this[NavigationMixin.Navigate]({
			type: "comm__namedPage",
			attributes: {
				name: "Login"
			}
		},
			true
		);
	}

	//show error
	showErrorToastAndConsole(error) {
		console.log("error :", JSON.stringify(error));
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
				"lightning-combobox, lightning-dual-listbox, lightning-textarea, lightning-radio-group, lightning-input"
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
		this.focus = false;
		this.focusIndex = -1;
		let isAllValid = [...this.template.querySelectorAll('.coorporateValidate')].reduce((validSoFar, input) => {
			console.log('input :>> ', input);
			input.reportValidity();
			let valid = input.checkValidity();
			if (!valid && (!this.focus || this.focusIndex == -1 || this.focusIndex > parseInt(input.dataset.index))) {
				input.focus();
				this.focus = true;
				this.focusIndex = input.dataset.index;
			}
			return validSoFar && valid;
		});
		return isAllValid;
		// let valid = false;

		// valid = [...this.template.querySelectorAll(".coorporateValidate")].reduce((validSoFar, input) => {
		// 	if (input.type === "date") {
		// 		if (!input.checkValidity()) {
		// 			input.classList.add("slds-has-error");
		// 		} else {
		// 			input.classList.remove("slds-has-error");
		// 		}
		// 	}
		// 	input.reportValidity();
		// 	return validSoFar && input.checkValidity();
		// }, true);
		// return valid;
	}

	checkValidityAuthValidate() {
		// let valid = false;
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
		});
		// this.focus = false;
		// this.focusIndex = -1;
		// valid = [...this.template.querySelectorAll(".authContactValidate")].reduce((validSoFar, input) => {
		// 	if (input.type === "date") {
		// 		if (!input.checkValidity()) {
		// 			input.classList.add("slds-has-error");
		// 		} else {
		// 			input.classList.remove("slds-has-error");
		// 		}
		// 	}
		// 	input.reportValidity();
		// 	let valid = input.checkValidity();
		// 	if (!valid && (!this.focus || this.focusIndex == -1 || this.focusIndex > parseInt(input.dataset.index))) {
		// 		input.focus();
		// 		this.focus = true;
		// 		this.focusIndex = input.dataset.index;
		// 	}
		// 	return validSoFar && input.checkValidity();
		// }, true);
		return isAllValid;
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
	maskingEIN(event) {
		this.correctEin = event.target.value;
		this.dataObj.newEmployerIdentificationNum = this.correctEin;
		//  converting from 123456789  -->  12-3456789
		let temp = this.dataObj.employerIdentificationNum;
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

		if (einRegex.test(this.dataObj.employerIdentificationNum)) { } else { }
	}

	formatPhoneNumber(event) {
		// Remove all non-digit characters
		let phoneNumber = event.target.value.replace(/\D/g, "");
		console.log('phoneNumber :>> ', phoneNumber);
		// Format the phone number as (XXX) XXX-XXXX
		let formattedPhoneNumber = phoneNumber.replace(/(\d{3})(\d{3})(\d{4})/, "($1) $2-$3");
		// Set the formatted phone number back to the input value
		event.target.value = formattedPhoneNumber;
	}

	recoverOrignalPhone(event) {
		let phoneNumber = event.target.value.replace(/\D/g, "");
		event.target.value = phoneNumber;
	}

	//Added for S-56790 - Start
	securityQuestionGetter() {
		this.showSpinner = true;
		getSecurityQuestions()
			.then((result) => {
				if (result.securityQuestionsList) {
					this.questions = result.securityQuestionsList
					console.log('questions', this.questions);
				}
				this.showSpinner = false;
			})
			.catch((error) => {
				this.showSpinner = false;
			});
	}

	handleQuestions(event) {
		let value = event.target.value;
		let name = event.target.name;
		if (name == 'Question1') {
			this.selectedSecurityQuestions[name] = value;
		} else if (name == 'Question2') {
			this.selectedSecurityQuestions[name] = value;
		} else if (name == 'Question3') {
			this.selectedSecurityQuestions[name] = value;
		} else if (name == 'que1Answer') {
			this.securityQuestionAnswer[this.selectedSecurityQuestions.Question1] = value;
		} else if (name == 'que2Answer') {
			this.securityQuestionAnswer[this.selectedSecurityQuestions.Question2] = value;
		} else if (name == 'que3Answer') {
			this.securityQuestionAnswer[this.selectedSecurityQuestions.Question3] = value;
		};
	}
	//get list values that are not selected in Q2 and Q3
	get getSecurityQues1Options() {
		return this.getQueList().filter(que =>
			que.value != this.selectedSecurityQuestions.Question2 &&
			que.value != this.selectedSecurityQuestions.Question3)
	}
	//get list values that are not selected in Q1 and Q3
	get getSecurityQues2Options() {
		return this.getQueList().filter(que => que.value != this.selectedSecurityQuestions.Question1 &&
			que.value != this.selectedSecurityQuestions.Question3)
	}
	//get list values that are not selected in Q1 and Q2
	get getSecurityQues3Options() {
		return this.getQueList().filter(que => que.value != this.selectedSecurityQuestions.Question1 &&
			que.value != this.selectedSecurityQuestions.Question2)
	}
	//get Security Questions List
	getQueList() {
		let securityQuesOptsList = [];
		this.questions.forEach(function (entry) {
			var newObj = {};
			newObj['label'] = entry.Question_Name__c;
			newObj['value'] = entry.DeveloperName;
			securityQuesOptsList.push(newObj);
		});
		return securityQuesOptsList;
	}
	//Added for S-56790 - End
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
			if (this.isAuthContactPopupOpen) {
				this.closeModelAuthContact();
			}
			if (this.isCoorporatePopupOpen) {
				this.closeModalcoorporate();
			}
		}
	}
	isInputFieldsValid() {
		let validLongText = [...this.template.querySelectorAll('.required-data')].reduce((validSoFar6, input) => {
			input.reportValidity();
			return validSoFar6 && input.checkValidity();
		}, true);

		setTimeout(() => {
			let allInput = this.template.querySelector(".slds-has-error");
			if (allInput) {
				allInput.focus();
			}
		}, 100);

		return validLongText;
	}
	setFocusOnMenuButton(selectedIndex){
        var focusOnInitial = this.template.querySelector(`lightning-button-menu[data-coorpindex='${selectedIndex}']`);
		console.log('focusOnInitial :>> ', focusOnInitial);
		console.log('selectedIndex :>> ', selectedIndex);
        if(focusOnInitial){
           focusOnInitial.focus();
        }
    }

	contactTypeOptions = [
        { label: 'Applicant', value: 'Applicant' },
        { label: 'Authorized Representative', value: 'Authorized Representative' }
    ];

	handleChange(event) {
        this.selectedValue = event.detail.value;
    }
}