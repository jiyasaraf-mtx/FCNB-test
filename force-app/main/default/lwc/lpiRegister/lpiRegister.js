import { LightningElement, track, wire } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import USER_ID from "@salesforce/user/Id";
import fetchRegistrationFormWrapper from "@salesforce/apex/LPI_RegisterController.fetchRegistrationFormWrapper";
import doFinishRegistration from "@salesforce/apex/LPI_RegisterController.doFinishRegistrationCapctcha";
import validateUserAndCreateUser from "@salesforce/apex/LPI_RegisterController.validateUserAndCreateUser";
import fetchCityCounty from "@salesforce/apex/LPI_RegisterController.getDataToPrepopulateBasedOnZipCode";
import getSecurityQuestions from "@salesforce/apex/LPI_FindUserName.getSecurityQuestions";
import resendOtp from "@salesforce/apex/LPI_RegisterController.resendOtp";
import { getPicklistValues, getObjectInfo } from "lightning/uiObjectInfoApi";
import ContactState from "@salesforce/schema/Account.PersonOtherStateCode";
import ContactCountry from "@salesforce/schema/Account.PersonOtherCountryCode";
// import addressInUSOrInternational from "@salesforce/schema/Account.Is_the_address_in_US_or_International__c";
// import identityType from "@salesforce/schema/Account.Identity_type__c";
import CONTACT_OBJECT from "@salesforce/schema/Contact";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import My_Resource from "@salesforce/resourceUrl/LPI_Design_old";
// import obtainSecurityCode from "@salesforce/apex/LPI_RegisterController.obtainSecurityCode";
// import createOTPForAccClaim from "@salesforce/apex/LPI_RegisterController.createOTPForAccClaim";
// import createUserForAccClaim from "@salesforce/apex/LPI_RegisterController.createUserForAccClaim";
import lpiResource from '@salesforce/resourceUrl/LPI_Design';
import getLabels from '@salesforce/apex/EMP_LanguageCtrl.getLabels';
import setLanguage from '@salesforce/apex/EMP_LanguageCtrl.setLanguage';
import {
	PUBLIC_PAGE_LABEL_API_NAMES,
	mapApiToCamel,
	readStoredLanguage,
	writeStoredLanguage
} from 'c/lpLanguageUtils';

export default class LpiRegister extends NavigationMixin(LightningElement) {

	logo = lpiResource + '/media/images/ibm-logo-white.svg';
	greenTick = My_Resource + "/icons/greenTick.svg";

	@track selectedLanguage = 'en_US';
	@track languageUpdating = false;
	@track labels = {
		regGoBackHome: 'Go back to Home',
		regGoBackSelection: 'Go Back To Selection',
		regTitle: 'Register for an Account',
		regAlready: 'Already Registered?',
		regLogin: 'Login',
		regSidebarIntro: 'The portal provides guidance across all regulated financial and consumer sectors in New Brunswick, connecting you directly to FCNB resources and rules.',
		regCopyright: '© Financial and Consumer Services Commission (FCNB)',
		regRequiredHint: 'Asterisk (*) indicates required field',
		regHaveLicenseHelp:
			'If you currently hold a license or registration with FCNB (or have previously applied) and do not have an active portal account, select "I Have a License/Registration". You will need to enter the security code issued by FCNB.',
		regNoLicenseHelp:
			'If you do not hold a license or registration with FCNB, select "I Don\'t Have a License/Registration".',
		regSelectOption: 'Select appropriate option',
		regHaveLicense: 'I Have a License',
		regDontHaveLicense: "I Don't Have a License",
		regFcnbLicenseNumber: 'FCNB License Number',
		regFcnbLicensePh: 'e.g. FCNB-123456',
		regDriversLicense: "Driver's License Number",
		regDriversPh: 'e.g. D1234-56789-01234',
		regFullLegalName: 'Full Legal Name',
		regFullLegalPh: 'Enter full legal name',
		regDob: 'Date of Birth',
		regDobPh: 'YYYY-MM-DD',
		regResidentialAddress: 'Residential Address',
		regCountry: 'Country',
		regSelectAnOption: 'Select an Option',
		regStreet: 'Street Address',
		regStreetPh: 'Enter Street Address',
		regPostal: 'Postal Code',
		regPostalPh: 'A1A 1A1',
		regProvince: 'Province',
		regProvincePh: 'Enter Province or State',
		regCity: 'City / Town',
		regCityPh: 'Enter City or Town',
		regCounty: 'County',
		regCountyPh: 'Enter County or District',
		regBasicContact: 'Basic Contact Details',
		regContactType: 'Contact Type',
		regFirstName: 'First Name',
		regFirstNamePh: 'Enter First Name',
		regMiddleName: 'Middle Name',
		regMiddleNamePh: 'Enter Middle Name',
		regLastName: 'Last Name',
		regLastNamePh: 'Enter Last Name',
		regTelephone: 'Telephone Number',
		regTelephonePh: 'Enter Telephone Number',
		regEmail: 'Email Address',
		regEmailPh: 'Enter Email Address',
		regSecurityTitle: 'Account Security Questions',
		regSecurityQ1: 'Security Question 1',
		regSecurityQ2: 'Security Question 2',
		regSecurityQ3: 'Security Question 3',
		regAnswer: 'Answer',
		regAnswerPh: 'Enter answer',
		regComplete: 'Complete Registration',
		language: 'Language',
		english: 'English',
		french: 'French'
	};

    @track stateOptions = [];
    @track countryOptions = [];
    @track addressOptions = [];
    @track identityTypeOptions = [];
    @track dataObj = {};
    @track otpResent = false;
    @track resentCount = 0;
    @track buttonName = "";
    @track questions = [];
    @track selectedSecurityQuestions = {};
    @track selectOptions = [
        { label: "Individual / Individuel", value: "Individual" },
        { label: "Business / Entreprise", value: "Business" }
    ];
    @track selectedValue = '';
    @track formattedDate = '';

    registerSelection = "Individual";
    isSpanVisible = false;
    wrongSelect = false;
    initCall = true;
    isShowRegistrationForm = true;
    hasError = false;
    errorMessage = "";
    hasSuccess = false;
    showOtp = false;
    successMessage = "";
    showSpinner = false;
    cmpLoaded = false;
    emailMismatch = false;
    showIdentityType = false;
    showSSN = false;
    correctSsn;
    showSelection = true;

    urlLanguage = "en_US";

    todayDate;
    invalidName;
    recaptchaDiv;
    recaptchaDivStyle;
    token;
    otp;
    userEnteredOtp;
    @track securityQuestionAnswer = {};
    isUserLicensed;
    @track isUserLicensedOptions = [
        { label: 'I Have a License / J\'ai une licence', value: 'I Have a License' },
        { label: "I Don't Have a License / Je n'ai pas de licence", value: 'I Dont Have a License' }
    ];
    @track yesNoOptions = [
        { label: 'Yes / Oui', value: 'Yes' },
        { label: 'No / Non', value: 'No' }
    ];
    showNoLicenseRegistrationForm = false;
    isUserHavingSSN = false;
    showSSNQuestionResponse = false;
    @track showSecurityCodeEmailErrorMsg = false;
    showSecurityCodeEmailSuccessMsg = false;
    @track accClaimWrapObj = {};
    @track showSSNErrorToFocus = false;
    showLicenseQueResponse = false;

    @track demoLicenseFields = {
        fcnbLicenseNumber: '',
        driversLicenseNumber: '',
        fullLegalName: '',
        dateOfBirth: '',
        country: '',
        streetAddress: '',
        postalCode: '',
        provinceStateRegion: '',
        cityTown: '',
        countyDistrict: ''
    };

    // GET OBJECT INFO
    @wire(getObjectInfo, {
        objectApiName: CONTACT_OBJECT
    })
    objectInfo;

    @wire(getPicklistValues, {
        recordTypeId: "$objectInfo.data.defaultRecordTypeId",
        fieldApiName: identityType
    })
    wiredIdentityType({ error, data }) {
        try {
            this.showSpinner = true;
            if (data && data.values) {
                this.identityTypeOptions = data.values;
                this.showSpinner = false;
            } else if (error) {
                this.showSpinner = false;
                console.log(JSON.stringify(error));
            }
        } catch (e) {
            console.log("error wiredPicklistValues" + JSON.stringify(error));
        }
    }

    @wire(getPicklistValues, {
        recordTypeId: "$objectInfo.data.defaultRecordTypeId",
        fieldApiName: addressInUSOrInternational
    })
    wiredPicklistValuesAddressOptions({ error, data }) {
        try {
            this.showSpinner = true;
            if (data && data.values) {
                this.addressOptions = data.values;
                this.showSpinner = false;
            } else if (error) {
                this.showSpinner = false;
                console.log(JSON.stringify(error));
            }
        } catch (e) {
            console.log("error wiredPicklistValues" + JSON.stringify(error));
        }
    }

    @wire(getPicklistValues, {
        recordTypeId: "$objectInfo.data.defaultRecordTypeId",
        fieldApiName: ContactState
    })
    wiredPicklistValues({ error, data }) {
        try {
            this.showSpinner = true;
            if (data && data.values) {
                this.stateOptions = data.values;
                this.showSpinner = false;
            } else if (error) {
                this.showSpinner = false;
                console.log(JSON.stringify(error));
            }
        } catch (e) {
            console.log("error wiredPicklistValues" + JSON.stringify(error));
        }
    }

    @wire(getPicklistValues, {
        recordTypeId: "$objectInfo.data.defaultRecordTypeId",
        fieldApiName: ContactCountry
    })
    wiredCountryPicklistValues({ error, data }) {
        try {
            this.showSpinner = true;
            if (data && data.values) {
                this.countryOptions = data.values;
                this.showSpinner = false;
            } else if (error) {
                this.showSpinner = false;
                console.log(JSON.stringify(error));
            }
        } catch (e) {
            console.log("error wiredCountryPicklistValues" + JSON.stringify(error));
        }
    }

    get isCA() {
        let temp = this.dataObj.country == "CA" ? true : false;
        if (!temp) {
            this.dataObj.state = null;
        }
        return temp;
    }

    get displayCaptchaMessage() {
        if (this.token != undefined && this.token != null && this.token != "") {
            return false;
        }
        return true;
    }

    hideselection() {
        this.showSelection = false;
        setTimeout(() => {
            this.setFocusOnFirstRadioButton();
        }, 2000);
    }

	goBackToSelection() {
		this.showSelection = true;
		this.showLicenseQueResponse = false;
		this.showSSNQuestionResponse = false;
	}

	get languageOptions() {
		return [
			{ label: this.labels.english || 'English', value: 'en_US' },
			{ label: this.labels.french || 'French', value: 'fr' }
		];
	}

	readUrlLanguage() {
		try {
			const params = new URL(window.location.href).searchParams;
			const lang = params.get('language') || params.get('lang');
			if (lang && lang.startsWith('fr')) {
				return 'fr';
			}
			if (lang === 'en_US' || lang === 'en') {
				return 'en_US';
			}
		} catch (e) {
			// ignore
		}
		return null;
	}

	loadPublicPageLabels() {
		const lang = this.selectedLanguage || readStoredLanguage() || 'en_US';
		const apiNames = PUBLIC_PAGE_LABEL_API_NAMES.filter((n) => n.startsWith('LP_Reg_'));
		getLabels({ apiNames, language: lang })
			.then((apiMap) => {
				this.labels = { ...this.labels, ...mapApiToCamel(apiMap) };
				this.isUserLicensedOptions = [
					{
						label: this.labels.regHaveLicense || 'I Have a License',
						value: 'I Have a License'
					},
					{
						label: this.labels.regDontHaveLicense || "I Don't Have a License",
						value: 'I Dont Have a License'
					}
				];
			})
			.catch(() => {
				// keep English defaults
			});
	}

	handleLanguageChange(event) {
		const next = event.detail.value;
		if (!next || next === this.selectedLanguage || this.languageUpdating) {
			return;
		}
		this.languageUpdating = true;
		writeStoredLanguage(next);
		setLanguage({ languageLocaleKey: next }).catch(() => {
			// Guest users may be blocked from User language update
		});
		this.selectedLanguage = next;
		try {
			const url = new URL(window.location.href);
			url.searchParams.set('language', next);
			window.location.href = url.toString();
		} catch (e) {
			window.location.reload();
		}
	}

	connectedCallback() {
		const stored = readStoredLanguage();
		const urlLang = this.readUrlLanguage();
		this.selectedLanguage = stored || urlLang || 'en_US';
		if (this.selectedLanguage === 'fr' || this.selectedLanguage === 'en_US') {
			writeStoredLanguage(this.selectedLanguage);
		}
		this.loadPublicPageLabels();
		let today = new Date();
		let dd = today.getDate();
		let mm = today.getMonth() + 1;
		let yyyy = today.getFullYear();

		if (dd < 10) dd = "0" + dd;
		if (mm < 10) mm = "0" + mm;
		this.todayDate = yyyy + "-" + mm + "-" + dd;
		if (!USER_ID) {
			this.securityQuestionGetter();
			let fullUrl = window.location.href;
			let newURL = new URL(fullUrl).searchParams;
			this.urlLanguage = newURL.get("language");
			this.checkAutomationAI();

			setTimeout(
				function () {
                    document.dispatchEvent(new CustomEvent("checkAutomation"));
                }.bind(this),
                1000
            );
        }
    }

    setFocusOnFirstRadioButton() {
        const registerMessage = this.template.querySelector('.focusOnFirstRadio');
        if (registerMessage) {
            registerMessage.focus();
        }       
    }

    securityQuestionGetter(){
        this.showSpinner = true;
        getSecurityQuestions()
        .then((result) => {
            if(result.securityQuestionsList){
                this.questions = result.securityQuestionsList;
            }
            this.showSpinner = false;
        })
        .catch(error => {
            this.showSpinner = false;
        });
    }
    
    checkAutomationAI() {
        let _this = this;
        document.addEventListener("automationDetected", (event) => {
            if (!event.detail) {
                if (!_this.initCall) {
                    if (this.buttonName === "Registor") {
                        _this.handleFinishRegistration();
                    } else if (this.buttonName === "VerifyOTP") {
                        _this.verifyOTP();
                    } else if(this.buttonName === "Account Claim Register"){
                        _this.handleAccClaimRegistration();
                    } else if(this.buttonName === "VerifyOTPForAccClaimButton"){
                        _this.doVerifyOTPAccClaim();
                    }
                } else {
                    _this.isShowRegistrationForm = true;
                    _this.doInit();
                    _this._captchaResponse = _this.captchaResponse.bind(_this);
                    document.addEventListener("grecaptchaVerified", this._captchaResponse);
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

    checkAutomationAndNext() {
        this.buttonName = "Registor";
        document.dispatchEvent(new CustomEvent("checkAutomation"));
        let valid = [
            ...this.template.querySelectorAll("lightning-radio-group"),
            ...this.template.querySelectorAll("lightning-input"),
            ...this.template.querySelectorAll("lightning-checkbox-group"),
            ...this.template.querySelectorAll("lightning-combobox"),
        ].reduce((validSoFar, input) => {
            if( input.type === 'date' ) {
                if( !input.checkValidity() ) {
                    input.classList.add('slds-has-error');
                } else {
                    input.classList.remove('slds-has-error');
                }
            }
            input.reportValidity();
            return validSoFar && input.checkValidity();
        }, true);

        var allInput = this.template.querySelector(".slds-has-error");
        if (allInput) {
            allInput.scrollIntoView();
            allInput.focus();
        }
    }

    checkAutomationAndNextAccClaim() {
        this.buttonName = "Account Claim Register";
        document.dispatchEvent(new CustomEvent("checkAutomation"));
        let valid = [
            ...this.template.querySelectorAll("lightning-radio-group"),
            ...this.template.querySelectorAll("lightning-input"),
            ...this.template.querySelectorAll("lightning-checkbox-group"),
            ...this.template.querySelectorAll("lightning-combobox"),
        ].reduce((validSoFar, input) => {
            if( input.type === 'date' ) {
                if( !input.checkValidity() ) {
                    input.classList.add('slds-has-error');
                } else {
                    input.classList.remove('slds-has-error');
                }
            }
            input.reportValidity();
            return validSoFar && input.checkValidity();
        }, true);

        var allInput = this.template.querySelector(".slds-has-error");
        if (allInput) {
            allInput.scrollIntoView();
            allInput.focus();
        }
    } 

    captchaResponse(e) {
        if (e.detail && JSON.stringify(e.detail)) {
            if (this.buttonName === "Registor") {
                this.doRegistration("v3", JSON.stringify(e.detail));
            } else if (this.buttonName === "VerifyOTP") {
                this.doOTPVerification("v3", JSON.stringify(e.detail));
            } else if (this.buttonName === "VerifyOTPForAccClaimButton"){
                this.verifyOTPForAccClaimAndCreateUser("v3", JSON.stringify(e.detail));
            }
        } 
    }

    disconnectedCallback() {
        document.removeEventListener("grecaptchaVerified", this._captchaResponse);
        if (this.sessionTimeout) {
            clearTimeout(this.sessionTimeout);
        }
        if (this.innerTimeout) {
            clearTimeout(this.innerTimeout);
        }
    }

    doInit() {
        this.hideErrorMessage();
        this.cmpLoaded = false;
        this.showSpinner = true;

        fetchRegistrationFormWrapper()
            .then((result) => {
                this.cmpLoaded = false;
                this.dataObj = result;
                this.dataObj.language = this.urlLanguage;

                if (this.dataObj.country == "") {
                    this.dataObj.country = "CA";
                }

                this.cmpLoaded = true;
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

    handleInputs(event) {
        this.hideErrorMessage();
        this.hasError = false;
        this.dataObj[event.target.name] = event.target.value.trim();
        if (event.target.name == "country" && this.dataObj.country == "CA") {
            this.dataObj.stateText = null;
        } else if(event.target.name == "country"){
            this.dataObj.state = null;
        }
        if (this.dataObj.addressInUSOrInternational == "Yes" && this.dataObj.addressInUSOrInternational != "") {
            this.showIdentityType = false;
            this.showSSN = true;
            this.dataObj.identityType = "";
            this.dataObj.identityNumber = "";
        }
        if (this.dataObj.addressInUSOrInternational == "No" && this.dataObj.addressInUSOrInternational != "") {
            this.showSSN = false;
            this.showIdentityType = true;
            this.dataObj.ssn = "";
            this.selectedValue = event.detail.value;
        }
        if(event.target.name == "zipcode" && event.target.value.length >= 5 && this.dataObj.country == "CA")
        {
            fetchCityCounty({zipcode : event.target.value})
            .then((result) => {
                if(result){
                    this.dataObj.city = result.city;
                    this.dataObj.county = result.county;
                }
            })
            .catch(error => {
                console.error("An unexpected error occurred:", JSON.stringify(error));
            });
        }
    }

    handleDobError(){
        const dobcmp = this.template.querySelector('[data-id="birthdate"]');
        dobcmp.setCustomValidity(''); 
        const chckvalididty = dobcmp.validity;
        if (!chckvalididty.valid) {
            const today = new Date();
            const year = today.getFullYear();
            const month = String(today.getMonth() + 1).padStart(2, '0'); 
            const day = String(today.getDate()).padStart(2, '0');
            let currentDate = `${year}-${month}-${day}`;
            if(dobcmp.value != null &&  dobcmp.value > currentDate)
            {
                dobcmp.setCustomValidity('Error: Selected date is greater than today date');
            }else{
                dobcmp.setCustomValidity('Error: Your entry does not match the allowed format MM/DD/YYYY');
            }   
        }
        dobcmp.reportValidity();
    }

    handleForeignInputsChange(event) {
        this.hideErrorMessage();
        this.hasError = false;
        this.dataObj[event.target.name] = event.target.value.trim();
    }

    formatPhoneNumber(event) {
        let phoneNumber = event.target.value.replace(/\D/g, "");
        let formattedPhoneNumber = phoneNumber.replace(/(\d{3})(\d{3})(\d{4})/, "($1) $2-$3");
        event.target.value = formattedPhoneNumber;
    }

    recoverOrignalPhone(event) {
        let phoneNumber = event.target.value.replace(/\D/g, "");
        event.target.value = phoneNumber;
    }

    maskingSSN(event) {
        this.correctSsn = event.target.value;
        if (this.dataObj.ssn != null) {
            const regex = /\d(?=\d{4})/gm;
            const subst = `X`;
            this.dataObj.ssn = this.dataObj.ssn.replace(regex, subst);
        }
        this.dataObj.newssn = this.correctSsn;

        let temp = this.dataObj.ssn;
        let newTemp = "";
        let i = 0;
        do {
            if (i < temp.length) {
                newTemp = newTemp + temp.substring(i, i + 1);
                if (i == 2) {
                    newTemp = newTemp + "-";
                }
                if (i == 4) {
                    newTemp = newTemp + "-";
                }
            }
            i = i + 1;
        } while (i < temp.length);

        this.dataObj.ssn = newTemp;
    }

    recorveringOrginalSSN() {
        this.dataObj.ssn = this.dataObj.newssn;
    }

    handleFinishRegistration() {
        this.hideErrorMessage();
        this.showSpinner = true;
        let valid = false;
        if(this.showSSN){
            let validateSSN = this.template.querySelector(".validateSSN");
            let ssnValue = validateSSN.value;
            if(ssnValue !== undefined && ssnValue.length !== 11) {
                validateSSN.setCustomValidity("Error: SSN is required.");
                validateSSN.reportValidity();
            } else {
                validateSSN.setCustomValidity("");
                validateSSN.reportValidity();
            }
        }
        valid = [...this.template.querySelectorAll("lightning-input,lightning-combobox,lightning-radio-group")].reduce(
            (validSoFar, input) => {
                input.reportValidity();
                return validSoFar && input.checkValidity();
            }
        );
        if (valid) {
            if (this.emailMismatch === true) {
                window.scrollTo(0, 0);
                this.hasError = true;
                this.errorMessage = "Email doesn't match";
                this.showSpinner = false;
            } else if (this.invalidName === true) {
                window.scrollTo(0, 0);
                this.hasError = true;
                this.errorMessage = "Please enter a valid name.";
                this.showSpinner = false;
            } else {
                this.showSpinner = true;
                if (this.token) {
                    this.showSpinner = true;
                    this.doRegistration("v2", this.token);
                } else {
                    document.dispatchEvent(new CustomEvent("grecaptchaExecute"));
                }
            }
        } else {
            let allInput = this.template.querySelector(".slds-has-error");
            if (allInput != null && allInput) {
                allInput.scrollIntoView();
                allInput.focus();
            }
            this.hasError = true;
            this.errorMessage = "Please review the errors.";
            this.showSpinner = false;
        }
    }

    doRegistration(ctype, ctoken) {
        let finalSecurityQuesJson = {};
        finalSecurityQuesJson[this.selectedSecurityQuestions.Question1] = this.securityQuestionAnswer[
            this.selectedSecurityQuestions.Question1
        ];
        finalSecurityQuesJson[this.selectedSecurityQuestions.Question2] = this.securityQuestionAnswer[
            this.selectedSecurityQuestions.Question2
        ];
        finalSecurityQuesJson[this.selectedSecurityQuestions.Question3] = this.securityQuestionAnswer[
            this.selectedSecurityQuestions.Question3
        ];
        this.dataObj["securityQuestionAnswer"] = JSON.stringify(finalSecurityQuesJson);
        doFinishRegistration({
            wrapperData: JSON.stringify(this.dataObj),
            recaptchaResponse: ctoken,
            ctype: ctype
        })
            .then(result => {
                if (result != null) {
                    if (result.isV3Failed) {
                        this.showSpinner = false;
                    } else if (result.isCaptchaInvalid) {
                        this.showSpinner = false;
                        this.errorMessage =
                            "Seems like you are trying to use automated scripts to fill this form. Please fill this form manually.";
                        this.hasError = true;
                    } else {
                        this.recaptchaDivStyle = "display: none";
                        this.token = undefined;
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
            .catch(error => {
                var errorMessage;
                if (typeof error.body.message === "string") {
                    errorMessage = error.body.message;
                }
                this.errorMessage = errorMessage;
                window.scrollTo(0, 0);
                this.hasError = true;
                document.dispatchEvent(new CustomEvent("grecaptchaReset"));
                this.recaptchaDivStyle = "display: none";
                this.token = undefined;
                this.v2RenderCalled = false;
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
    verifyOTPForAccClaimHandler() {
        this.buttonName = "VerifyOTPForAccClaimButton";
        document.dispatchEvent(new CustomEvent("checkAutomation"));
    }

    verifyOTP() {
        if (this.otp === undefined || this.otp === null) {
            let valid = [...this.template.querySelectorAll("lightning-input")].reduce((validSoFar, input) => {
                input.reportValidity();
                return validSoFar && input.checkValidity();
            }, false);
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
                if (this.v2RenderCalled) {
                    this.showSpinner = true;
                    this.errorMessage = "Please complete the captcha to continue";
                    this.hasError = true;
                    this.showSpinner = false;
                } else {
                    document.dispatchEvent(new CustomEvent("grecaptchaExecute"));
                }
            }
        }
    }

    doOTPVerification(ctype, ctoken) {
        this.hideErrorMessage();
        this.hasError = false;
        validateUserAndCreateUser({
            otpValue: this.otp,
            wrapperJSON: JSON.stringify(this.dataObj),
            recaptchaResponse: ctoken,
            ctype: ctype
        })
            .then(result => {
                this.showSpinner = false;
                if (result != null) {
                    if (result.isV3Failed) {
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
                                "Thank you for registering. An email has been sent to your provided email address. The email will contain your user ID. You must click on the link in the email to set your password and access your account.";
                            this.successMessage = makeSuccessMessage;
                            this.hasSuccess = true;

                            document.dispatchEvent(new CustomEvent("grecaptchaReset"));
                            this.recaptchaDivStyle = "display: none";
                            this.token = undefined;
                        } else if (!result.isSuccess) {
                            this.hasError = true;
                            this.token = undefined;
                            let errorMessage = "Entered OTP is Incorrect !!";
                            this.errorMessage = errorMessage;
                            this.focusOnWrongOtp();
                        }
                        this.token = undefined;
                        document.dispatchEvent(new CustomEvent("grecaptchaReset"));
                        this.showSpinner = false;
                    }
                }
            })
            .catch(error => {
                var errorMessage;
                if (typeof error.body.message === "string") {
                    errorMessage = error.body.message;
                }
                this.errorMessage = errorMessage;
                window.scrollTo(0, 0);
                this.hasError = true;
                document.dispatchEvent(new CustomEvent("grecaptchaReset"));
                this.recaptchaDivStyle = "display: none";
                this.token = undefined;
                this.v2RenderCalled = false;
                this.showSpinner = false;
            });
    }

    resendOTPHandler() {
        this.hideErrorMessage();
        if (this.resentCount === 3) {
            const evt = new ShowToastEvent({
                title: "Toast Error",
                message: "You have exceeded the maximum otp limit. Please try after some time.",
                variant: "error",
                mode: "dismissable"
            });
            this.dispatchEvent(evt);
        } else {
            this.showSpinner = true;
            resendOtp({
                emailValue: this.isUserHavingSSN && this.accClaimWrapObj && this.accClaimWrapObj.email ? this.accClaimWrapObj.email : this.dataObj.email
            })
                .then(result => {
                    this.resentCount = this.resentCount + 1;
                    this.showSpinner = false;
                    if (result != null) {
                        this.otpResent = true;
                        const evt = new ShowToastEvent({
                            title: "Toast Success",
                            message: "A One-Time Password has been resent to the registered email address.",
                            variant: "success",
                            mode: "sticky"
                        });
                        this.dispatchEvent(evt);
                        this.showSpinner = false;
                    }
                })
                .catch(error => {
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

    navigateToLoginPage() {
		window.open("/s/", "_self");
        // this[NavigationMixin.Navigate](
        //     {
        //         type: "standard__webPage",
        //         attributes: {
        //             url: "/s/"
        //         }
        //     },
        //     true
        // );
    }

    handleQuestions(event) {
        let value = event.target.value;
        let name = event.target.name;
        if (name == "Question1") {
            this.selectedSecurityQuestions[name] = value;
        } else if (name == "Question2") {
            this.selectedSecurityQuestions[name] = value;
        } else if (name == "Question3") {
            this.selectedSecurityQuestions[name] = value;
        } else if (name == "que1Answer") {
            this.securityQuestionAnswer[this.selectedSecurityQuestions.Question1] = value;
        } else if (name == "que2Answer") {
            this.securityQuestionAnswer[this.selectedSecurityQuestions.Question2] = value;
        } else if (name == "que3Answer") {
            this.securityQuestionAnswer[this.selectedSecurityQuestions.Question3] = value;
        }
    }

    get getSecurityQues1Options() {
        return this.getQueList().filter(
            que =>
                que.value != this.selectedSecurityQuestions.Question2 &&
                que.value != this.selectedSecurityQuestions.Question3
        );
    }

    get getSecurityQues2Options() {
        return this.getQueList().filter(
            que =>
                que.value != this.selectedSecurityQuestions.Question1 &&
                que.value != this.selectedSecurityQuestions.Question3
        );
    }

    get getSecurityQues3Options() {
        return this.getQueList().filter(
            que =>
                que.value != this.selectedSecurityQuestions.Question1 &&
                que.value != this.selectedSecurityQuestions.Question2
        );
    }

    getQueList() {
        let securityQuesOptsList = [];
        this.questions.forEach(function(entry) {
            var newObj = {};
            newObj["label"] = entry.Question_Name__c;
            newObj["value"] = entry.DeveloperName;
            securityQuesOptsList.push(newObj);
        });
        return securityQuesOptsList;
    }
    
    getRadioGroupSelectedLabel() {
        const radioGroup = this.template.querySelector('lightning-radio-group');
        return radioGroup.label;
    }
    
    handleIsUserLicensedQuestions(event){
        this.hasError = false;
        let selectedLabel = event.target.label;
        let usrValue = event.target.value;
        this.showNoLicenseRegistrationForm = true;
        let selectedRadioGroupLabel = this.getRadioGroupSelectedLabel();

        if(selectedLabel === selectedRadioGroupLabel && usrValue == 'I Have a License'){
            this.dataObj = {};
            this.hideSecurityCodeEmailMessages();
            this.isUserLicensed = true;
            this.showLicenseQueResponse = true;
            this.demoLicenseFields = {
                fcnbLicenseNumber: '',
                driversLicenseNumber: '',
                fullLegalName: '',
                dateOfBirth: '',
                country: '',
                streetAddress: '',
                postalCode: '',
                provinceStateRegion: '',
                cityTown: '',
                countyDistrict: ''
            };
        } else if(selectedLabel === selectedRadioGroupLabel){
            this.dataObj = {};
            this.dataObj["country"] = "US";
            this.dataObj["state"] = "MO";
            this.hideSecurityCodeEmailMessages();
            this.showSSNQuestionResponse = false;
            this.isUserLicensed = false;
            this.showLicenseQueResponse = true;
        }

        if(selectedLabel == 'Do you have a social security number?' && usrValue == 'Yes'){
            this.dataObj = {};
            this.hideSecurityCodeEmailMessages();
            this.showSSNQuestionResponse = true;
            this.isUserHavingSSN = true;
        } else if(selectedLabel == 'Do you have a social security number?'){
            this.dataObj = {};
            this.hideSecurityCodeEmailMessages();
            this.showSSNQuestionResponse = true;
            this.isUserHavingSSN = false;
            this.showSSNErrorToFocus = true;
        }

        if(selectedLabel == 'Security Code'){
            this.usrSecurityCode = usrValue;
        }
    }

    handleDemoLicenseInputs(event) {
        const fieldName = event.target.name;
        this.demoLicenseFields = {
            ...this.demoLicenseFields,
            [fieldName]: event.target.value
        };
    }

    handleDemoValidateLicense() {
        console.log('Demo Validate clicked', JSON.stringify(this.demoLicenseFields));
    }

    getRadioGroupValue() {
        if (!this.showSecurityCodeEmailSuccessMsg) {
            const radioGroup = this.template.querySelector('.ssnQuestion');
            if (radioGroup) {
                return radioGroup.value;
            }
        }
        return null;
    }

    renderedCallback() {
        const radioGroupValue = this.getRadioGroupValue();
        if (this.showSSNErrorToFocus && radioGroupValue === 'No') {
            this.setFocusOnNoSSNErrorMessage();
        }
    }
    
    setFocusOnNoSSNErrorMessage() {
        const errorToast = this.template.querySelector('.noSSNErrorMessage');
        if (errorToast) {
            errorToast.setAttribute('tabindex', '0');
            errorToast.focus();
        }
    }
 
    handleObtainSecurityCode(){
        this.hasError = false;
        this.accClaimWrapObj.ssn = this.dataObj.newssn;
        this.accClaimWrapObj.email = this.isUserHavingSSN && this.accClaimWrapObj && this.accClaimWrapObj.email ? this.accClaimWrapObj.email : this.dataObj.email;
        this.accClaimWrapObj.birthdate = this.dataObj.birthdate;
        this.accClaimWrapObj.isUserHavingSSN = this.isUserHavingSSN;
        
        if(this.isAllInputValid()){
            this.showSpinner = true;
            obtainSecurityCode({
                accClaimDataObj : JSON.stringify(this.accClaimWrapObj)
            }).then(result => {
                this.accClaimWrapObj = result;
                this.showSecurityCodeEmailSuccessMsg = result.isAccFoundAndEmailSent;
                this.showSecurityCodeEmailErrorMsg = false;
                if(!result.isAccFoundAndEmailSent){
                    this.showSecurityCodeEmailErrorMsg = true;
                }
                this.showSpinner = false;
            }).catch(error => {
                this.errorMessage = JSON.stringify(error.body.message);
                this.showSpinner = false;
            }).finally(() => {
                if (this.showSecurityCodeEmailErrorMsg) {
                    this.setFocusOnErrorMessage();
                }
            });
        } else {
            let allInput = this.template.querySelector(".slds-has-error");
            if (allInput) {
                allInput.scrollIntoView();
                allInput.focus();
            } 
        }
    }

    setFocusOnErrorMessage() {
        const errorToast = this.template.querySelector('.obtainSecurityCodeError');
        if (errorToast) {
            errorToast.setAttribute('tabindex', '0');
            errorToast.focus();
        }
    }
    
    handleAccClaimRegistration(){
        if(this.usrSecurityCode !== this.accClaimWrapObj.securityCode){
            this.hasError = true;
            this.errorMessage = 'Security Code is Invalid.';
            const scrollTarget = this.template.querySelector('.scrollTarget');
            scrollTarget.scrollIntoView({ behavior: 'smooth' });
        } else {
            this.hideErrorMessage();
            if (this.isAllInputValid()) {
                createOTPForAccClaim({
                    accClaimDataObj : JSON.stringify(this.accClaimWrapObj)
                }).then(result => {
                    // Success handling
                }).catch(error => {
                    this.hasError = true;
                    this.errorMessage = JSON.stringify(error.body.message);
                });
                this.showOtp = true;
                this.isShowRegistrationForm = false;
            } else {
                window.scrollTo(0, 0);
                let allInput = this.template.querySelector(".slds-has-error");
                if (allInput != null && allInput) {
                    allInput.scrollIntoView();
                    allInput.focus();
                }
                this.hasError = true;
                this.errorMessage = "Please review the errors.";
                this.showSpinner = false;
            }
        }
    }

    doVerifyOTPAccClaim() {
        if (this.otp === undefined || this.otp === null) {
            let valid = [...this.template.querySelectorAll("lightning-input")].reduce((validSoFar, input) => {
                input.reportValidity();
                return validSoFar && input.checkValidity();
            }, false);
            let allInput = this.template.querySelector(".slds-has-error");

            if (allInput) {
                allInput.scrollIntoView();
                allInput.focus();
            }
        } else {
            if (this.token) {
                this.showSpinner = true;
                this.verifyOTPForAccClaimAndCreateUser("v2", this.token);
            } else {
                if (this.v2RenderCalled) {
                    this.showSpinner = true;
                    this.errorMessage = "Please complete the captcha to continue";
                    this.hasError = true;
                    this.showSpinner = false;
                } else {
                    document.dispatchEvent(new CustomEvent("grecaptchaExecute"));
                }
            }
        }
    }

    verifyOTPForAccClaimAndCreateUser(ctype, ctoken){
        this.showSpinner = true;
        let finalSecurityQuesJson = {};
        finalSecurityQuesJson[this.selectedSecurityQuestions.Question1] =
            this.securityQuestionAnswer[this.selectedSecurityQuestions.Question1];
        finalSecurityQuesJson[this.selectedSecurityQuestions.Question2] =
            this.securityQuestionAnswer[this.selectedSecurityQuestions.Question2];
        finalSecurityQuesJson[this.selectedSecurityQuestions.Question3] =
            this.securityQuestionAnswer[this.selectedSecurityQuestions.Question3];
        this.accClaimWrapObj['securityQuestionAnswer'] = JSON.stringify(finalSecurityQuesJson);

        createUserForAccClaim({
            otpValue : this.otp,
            wrapperJSON : JSON.stringify(this.accClaimWrapObj),
            recaptchaResponse : ctoken,
            ctype : ctype
        }).then(result => {
            if(result != null){
                if(result.isCaptchaInvalid) {
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
                        this.token = undefined;
                        this.showSpinner = false;
                    } else if(!result.isSuccess){
                        this.hasError = true;
                        let errorMessage = "";
                        if(result.message == null || result.message == ''){
                            errorMessage = 'There is problem in Registering';
                        } else {
                            errorMessage += "<b>" + result.message + "</b>";
                        }
                        this.errorMessage = errorMessage;
                        this.focusOnWrongOtp();
                        this.showSpinner = false;
                    }
                    this.token = undefined;
                    document.dispatchEvent(new CustomEvent("grecaptchaReset"));
                    this.showSpinner = false;
                }
            }
        }).catch(error => {
            this.showSpinner = false;
            this.errorMessage = JSON.stringify(error.body.message);
            window.scrollTo(0, 0);
            this.hasError = true;
            document.dispatchEvent(new CustomEvent("grecaptchaReset"));
            this.token = undefined;
        });
    }

    hideSecurityCodeEmailMessages(){
        this.showSecurityCodeEmailSuccessMsg = false;
        this.showSecurityCodeEmailErrorMsg = false;
    }

    isAllInputValid(){
        let valid = false;
        valid = [...this.template.querySelectorAll("lightning-input,lightning-combobox,lightning-radio-group")].reduce(
            (validSoFar, input) => {
                if (input.type === "date") {
                    if (!input.checkValidity()) {
                        input.classList.add("slds-has-error");
                    } else {
                        input.classList.remove("slds-has-error");
                    }
                }
                input.reportValidity();
                return validSoFar && input.checkValidity();
            }
        );
        return valid;
    } 

    contactTypeOptions = [
        { label: 'Applicant / Demandeur', value: 'Applicant' },
        { label: 'Authorized Representative / Représentant autorisé', value: 'Authorized Representative' }
    ];

    handleChange(event) {
        this.selectedValue = event.detail.value;
    }
}