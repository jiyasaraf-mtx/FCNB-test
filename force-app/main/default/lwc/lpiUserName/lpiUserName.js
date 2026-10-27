import doFinishForgetUsernameCapctcha from '@salesforce/apex/LPI_FindUserName.doFinishForgetUsernameCapctcha';
import fetchAccountByUniqueIdentificationNumber from '@salesforce/apex/LPI_FindUserName.fetchAccountByUniqueIdentificationNumber';
import fetchForgetUsernameFormWrapper from '@salesforce/apex/LPI_FindUserName.fetchForgetUsernameFormWrapper';
import getSecurityQuestions from "@salesforce/apex/LPI_FindUserName.getSecurityQuestions";
import getTodayDate from '@salesforce/apex/LPI_FindUserName.getTodayDate';
import My_Resource from '@salesforce/resourceUrl/LPI_Design_old';
// import LP_Design from '@salesforce/resourceUrl/LP_Design';
import lpiResource from '@salesforce/resourceUrl/LPI_Design';
import {
    NavigationMixin
} from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'; //Added for S-56790
import {
    LightningElement,
    track
} from 'lwc';

export default class LpiUserName extends NavigationMixin(LightningElement) {
    logo = lpiResource + '/media/images/dpi_logo.svg';
    greenTick = My_Resource + '/icons/greenTick.svg';
    errorMsgIcon = My_Resource + '/icons/errorMsgIcon.svg';
    infoPage = true;
    errorPage = false;
    confirmationPage = false;
    successPage = false;
    v2RenderCalled;
    recaptchaDivStyle;
    token;
    invalidName;

    @track questions = [];
    @track dataObj = {};
    @track errorMessage = '';
    @track hasError = false;
    @track showSpinner = false;
    @track initCall = true;
    @track wrapObj = {};
    @track securityQuestionsAnswers = {};
    @track selectedSecurityQuestions = {};
    @track securityQuestionAnswer = {};
    today;
    get recaptchaDivTabIndex() {
        return this.v2RenderCalled ? 0 : -1;
    }
    //Added for S-56790 - Start
    showSelection = true;
    isIndividualForgotUsername = false;
    isBusinessForgotUsername = false;
    //Radio button values
    @track selectedOption = '';
    //flags to render UI
    @track showTextField1 = false;
    @track showTextField2 = false;
    @track showSecurityQuestion = false;
    @track showError = false;
    @track dynamicErrorText = '';
    //Input Fields Value

    @track securityQuestion1 = '';
    @track securityQuestion2 = '';
    @track securityQuestion3 = '';

    @track newEmployerIdentificationNumber = '';
    @track newSSN = '';




    individualForgotUsernameOption = [
        { label: 'SSN', value: 'SSN' },
        { label: 'Name & DOB', value: 'Non-SSN' },
    ];
    businessForgotUsernameOption = [
        { label: 'Owner\'s Social Security Number', value: 'Owner\'s Social Security Number' },
        { label: 'Employer Identification Number', value: 'Employer Identification Number' },
    ];
    handleRadioChange(event) {
        this.selectedOption = event.detail.value;
        if(event.detail.value == 'SSN' || event.detail.value == 'Owner\'s Social Security Number'){
            this.showTextField1 = true;
            this.showTextField2 = false;
        }
        if(event.detail.value == 'Non-SSN' || event.detail.value == 'Employer Identification Number'){
            this.showTextField1 = false;
            this.showTextField2 = true;
        }
        this.showError = false;
        this.selectedSecurityQuestions = {};
        this.showSecurityQuestion = false;
        this.dataObj.uniqueIdentificationNumber = '';
        this.firstName = '';
        this.lastName = '';
        this.dob = '';
        this.newEmployerIdentificationNumber = '';
        this.newSSN = '';
    }

    //Added for S-56790 - End
    hideErrorMessage() {
        this.hasError = false;
        this.errorMessage = '';
    }



    isAllValid() {
        const allValid = [
            ...this.template.querySelectorAll('lightning-input')
        ].reduce((validSoFar, inputCmp) => {
            if( inputCmp.type === 'date' ) {
                if( !inputCmp.checkValidity() ) {
                    inputCmp.classList.add('slds-has-error');

                } else {
                    inputCmp.classList.remove('slds-has-error');
                }
            }
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);
        var allInput = this.template.querySelector('.slds-has-error');
        if (allInput) {
            allInput.focus();
        }
        return allValid;
    }

    handleInputs(event) {
        this.hideErrorMessage();
        this.errorPage = false;
        this.dataObj.uniqueIdentificationNumber = event.target.value;
        if(event.target.name == 'ssn'){
            this.dataObj.identificationType = 'ssn';
        } 
        if(event.target.name == 'firstName') {
            this.dataObj.identificationType = 'nonssn';
            this.dataObj.firstName = event.target.value;
        }
        if(event.target.name == 'lastName') {
            this.dataObj.identificationType = 'nonssn';
            this.dataObj.lastName = event.target.value;
        }
        if(event.target.name == 'birthdate') {
            this.dataObj.identificationType = 'nonssn';
            this.dataObj.dateOfBirth = event.target.value;
        }
        if(event.target.name == 'ownerSSN'){
            this.dataObj.identificationType = 'ownerSSN';
        } 
        if(event.target.name == 'employerIdentificationNum'){
            this.dataObj.identificationType = 'EIN'; 
        }
        if(this.isIndividualForgotUsername){
            this.dataObj.isIndividualForgotUsername = true;
        } else{
            this.dataObj.isIndividualForgotUsername = false;
        }
    }

    connectedCallback() {
        this.securityQuestionGetter();
        getTodayDate().then((result) => {
            this.today = result;
        });
        this.checkAutomationAI();

        setTimeout(
            function () {
                document.dispatchEvent(new CustomEvent('checkAutomation'));
            }.bind(this),
            1000
        );
    }

    checkAutomationAndNext() {
        document.dispatchEvent(new CustomEvent('checkAutomation'));
    }

    checkAutomationAI() {
        let _this = this;
        document.addEventListener('automationDetected', (event) => {
            if (!event.detail) {
                if (!_this.initCall) {
                    _this.handleForgetUsername();
                } else {
                    _this.doInit();
                    //reCaptcha
                    _this._captchaResponse = _this.captchaResponse.bind(_this);
                    document.addEventListener(
                        'grecaptchaVerified',
                        this._captchaResponse
                    );

                    // event for recaptcha v2
                    _this._captchaV2Response =
                        _this.captchaV2Response.bind(_this);
                    document.addEventListener(
                        'grecaptchaV2VerifiedSubmit',
                        _this._captchaV2Response
                    );

                    // event for recaptcha v2 Expired
                    _this._captchaV2Expired =
                        _this.captchaV2Expired.bind(_this);
                    document.addEventListener(
                        'grecaptchaV2ExpiredSubmit',
                        _this._captchaV2Expired
                    );
                    //reCaptcha

                    _this.initCall = false;
                }
            } else {
                _this.showSpinner = false;
                _this.errorMessage = 'Error in recapctha';
                _this.hasError = true;
            }
        });
    }

    doInit() {
        this.hideErrorMessage();
        this.showSpinner = true;

        fetchForgetUsernameFormWrapper({})
            .then((result) => {
                this.dataObj = result;
                this.showSpinner = false;
                setTimeout(() => {
                    let element =this.template.querySelector('.focus_helper_title');
                    if (element) {
                        element.focus();
                    }
                }, 1000); 
    
            })
            .catch((error) => {
                if (Array.isArray(error.body)) {
                    this.errorMessage = error.body
                        .map((e) => e.message)
                        .join(', ');
                } else if (typeof error.body.message === 'string') {
                    this.errorMessage = error.body.message;
                }
                window.scrollTo(0, 0);
                this.showSpinner = false;
                this.hasError = true;
            });
    }

    captchaV2Expired(e) {
        this.token = undefined;
        this.v2Verified = false;
    }

    captchaV2Response(e) {
        if (e.detail && JSON.stringify(e.detail)) {
            this.token = e.detail.response;
        }
    }

    captchaResponse(e) {
        if (e.detail && JSON.stringify(e.detail)) {
            this.doforgetUsername('v3', JSON.stringify(e.detail));
        } else {
            this.showSpinner = false;
            if (!this.v2RenderCalled) {
                this.v2RenderCalled = true;
                document.dispatchEvent(
                    new CustomEvent('grecaptchaV2RenderSubmit', {
                        detail: {
                            element: this.recaptchaDiv
                        }
                    })
                );

                // setting this to display block for the scenario where the user comes from the previous page again
                this.recaptchaDivStyle = 'display: block';
                setTimeout(() => this.recaptchaDiv.focus(), 0);
            }
        }
    }

    handleForgetUsername(event) {
        //this.hideErrorMessage();
        this.showSpinner = true;

        let valid = this.isAllValid();
        if (valid) {
            if (this.invalidName === true) {
                window.scrollTo(0, 0);
                this.hasError = true;
                this.errorMessage = 'Please enter a valid name.';
                this.showSpinner = false;
            } else {
                this.showSpinner = true;

                if (this.token) {
                    this.showSpinner = true;
                    this.doforgetUsername('v2', this.token);
                } else {
                    // enforcing v2 to be checked if it has been rendered on the screen
                    if (this.v2RenderCalled) {
                        this.showSpinner = true;
                        this.errorMessage = this.labels.RC_MSG_1;
                        this.hasError = true;
                        this.showSpinner = false;
                    } else {
                        document.dispatchEvent(new Event('grecaptchaExecute'));
                    }
                }
            }
        } else {
            window.scrollTo(0, 0);
            this.hasError = true;
            //this.errorMessage = 'Error occur in handleForgetUsername method'
            this.showSpinner = false;
        }
    }

    doforgetUsername(ctype, ctoken) {
        let finalSecurityQuesJson = {}
		finalSecurityQuesJson[this.selectedSecurityQuestions.Question1] =
			this.securityQuestionAnswer[this.selectedSecurityQuestions.Question1]
		finalSecurityQuesJson[this.selectedSecurityQuestions.Question2] =
			this.securityQuestionAnswer[this.selectedSecurityQuestions.Question2]
		finalSecurityQuesJson[this.selectedSecurityQuestions.Question3] =
			this.securityQuestionAnswer[this.selectedSecurityQuestions.Question3]
		this.dataObj['securityQuestionAnswer'] = JSON.stringify(finalSecurityQuesJson);
        //Added for S-56790 - Start
        this.dataObj.isIndividualForgotUsername = this.isIndividualForgotUsername;
        this.dataObj.isBusinessForgotUsername = this.isBusinessForgotUsername;
        //Added for S-56790 - End
        doFinishForgetUsernameCapctcha({
                wrapperData: JSON.stringify(this.dataObj),
                recaptchaResponse: ctoken,
                ctype: ctype
            })
            .then((result) => {
                this.wrapObj = result;
                if (this.wrapObj.userExists) {
                    if (result != null) {
                        if (result.isV3Failed) {
                            if (!this.v2RenderCalled) {
                                this.v2RenderCalled = true;
                                document.dispatchEvent(
                                    new CustomEvent(
                                        'grecaptchaV2RenderSubmit', {
                                            detail: {
                                                element: this.recaptchaDiv
                                            }
                                        }
                                    )
                                );
                                // setting this to display block for the scenario where the user comes from the previous page again
                                this.recaptchaDivStyle = 'display: block';
                                this.disabledSubmit = false;
                                setTimeout(() => this.recaptchaDiv.focus(), 0);
                            }
                            this.showSpinner = false;
                        } else if (result.isCaptchaInvalid) {
                            this.showSpinner = false;
                            this.errorPage = false;
                            this.hasError = true;
                        } else {
                            document.dispatchEvent(
                                new Event('grecaptchaReset')
                            );
                            document.dispatchEvent(
                                new CustomEvent('grecaptchaV2ResetSubmit')
                            );
                            this.recaptchaDivStyle = 'display: none';
                            this.token = undefined;
                            this.v2RenderCalled = false;
                            window.scrollTo(0, 0);

                            this.successPage = true;
                            this.confirmationPage = true;
                            this.infoPage = true;
                            this.showSpinner = false;
                            this.showMessage('success', 'Username Successfully Sent', 'success')//Added for S-56790
                        }
                    }
                } else {
                    this.showSpinner = false;
                    this.errorPage = true;
                    this.confirmationPage = true;
                    let element;
                    setTimeout(() => {
                        element = this.template.querySelector(".focus-helper");
                        if (element) {
                            element.focus();
                        }

                    }, 1000);
                    setTimeout(() => {
                        element = this.template.querySelector(".firstNameClass");
                        if (element) {
                            element.focus();
                        }
                    }, 5000);
                }
            })
            .catch((error) => {
                var errorMessage;
                if (typeof error.body.message === 'string') {
                    errorMessage = error.body.message;
                }
                if (!this.v2RenderCalled) {
                    this.v2RenderCalled = true;
                    document.dispatchEvent(
                        new CustomEvent('grecaptchaV2RenderSubmit', {
                            detail: {
                                element: this.recaptchaDiv
                            }
                        })
                    );
                    // setting this to display block for the scenario where the user comes from the previous page again
                    this.recaptchaDivStyle = 'display: block';
                    setTimeout(() => this.recaptchaDiv.focus(), 0);
                }

                this.errorMessage = errorMessage;

                window.scrollTo(0, 0);
                this.hasError = true;
                document.dispatchEvent(new Event('grecaptchaReset'));
                document.dispatchEvent(
                    new CustomEvent('grecaptchaV2ResetSubmit')
                );
                this.recaptchaDivStyle = 'display: none';
                this.token = undefined;
                this.v2RenderCalled = false;
                this.showSpinner = false;
            }).finally(() => {
                this.showSpinner = false;

            })
    }

    disconnectedCallback() {
        document.removeEventListener(
            'grecaptchaVerified',
            this._captchaResponse
        );
        document.removeEventListener(
            'grecaptchaV2VerifiedSubmit',
            this._captchaV2Response
        );
        document.removeEventListener(
            'grecaptchaV2ExpiredSubmit',
            this._captchaV2Expired
        );
        if (this.sessionTimeout) {
            clearTimeout(this.sessionTimeout);
        }
        if (this.innerTimeout) {
            clearTimeout(this.innerTimeout);
        }
    }

    renderedCallback() {
        this.recaptchaDiv = this.template.querySelector('.recaptchaCheckbox2'); 
    }

    handleClick() {
        window.open("/license/s/", "_self");
    }
    securityQuestionGetter(){
		this.showSpinner = true;
		getSecurityQuestions()
		.then((result) => {
			if(result.securityQuestionsList){
                this.questions = result.securityQuestionsList
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
		if(name == 'Question1'){
			this.selectedSecurityQuestions[name] = value;
		} else if(name == 'Question2'){
			this.selectedSecurityQuestions[name] = value;
		} else if(name == 'Question3'){
			this.selectedSecurityQuestions[name] = value;
		} else if(name == 'que1Answer'){
			this.securityQuestionAnswer[this.selectedSecurityQuestions.Question1] = value;
		} else if(name == 'que2Answer'){
			this.securityQuestionAnswer[this.selectedSecurityQuestions.Question2] = value;
		} else if(name == 'que3Answer'){
			this.securityQuestionAnswer[this.selectedSecurityQuestions.Question3] = value;
		};
		
	}
	//get list values that are not selected in Q2 and Q3
	get getSecurityQues1Options(){
		return this.getQueList().filter(que => 
			que.value != this.selectedSecurityQuestions.Question2 
			&& que.value != this.selectedSecurityQuestions.Question3)
	}
	//get list values that are not selected in Q1 and Q3
	 get getSecurityQues2Options(){
		return this.getQueList().filter(que => que.value != this.selectedSecurityQuestions.Question1 
			&& que.value != this.selectedSecurityQuestions.Question3)
	}
	//get list values that are not selected in Q1 and Q2
	get getSecurityQues3Options(){
		return this.getQueList().filter(que => que.value != this.selectedSecurityQuestions.Question1 
			&& que.value != this.selectedSecurityQuestions.Question2)
	}
	//get Security Questions List
	getQueList(){
		let securityQuesOptsList = [];
		this.questions.forEach(function(entry){
			var newObj = {};
			newObj['label'] = entry.Question_Name__c;
			newObj['value'] = entry.DeveloperName;
			securityQuesOptsList.push(newObj);
		});
		return securityQuesOptsList;
	}
    //Added for S-56790 - Start
    hideselection(event) {
        this.isIndividualForgotUsername = event.detail.isIndividualForgotUsername;
        this.isBusinessForgotUsername = event.detail.isBusinessForgotUsername;
		this.showSelection = false;
	}
	goBackToSelection() {
		this.showSelection = true;
        this.selectedSecurityQuestions = {};
        this.showSecurityQuestion = false;
        this.showTextField1 = false;
        this.showTextField2 = false;
        this.showError = false;
        this.newEmployerIdentificationNumber = '';
        this.newSSN = '';
        this.selectedOption = '';
	}
    get showGoBackToSelection(){
        return this.successPage != true && this.errorPage != true
    }
    showMessage(title,message, variant) {
        const toastEvt = new ShowToastEvent({
            title,
            message,
            variant
        });
        this.dispatchEvent(toastEvt);
    }
    //Added for S-56790 - End


    handleValidate(){
        //this.showSpinner = true;
		fetchAccountByUniqueIdentificationNumber({wrapperJSON: JSON.stringify(this.dataObj)})
		.then((result) => {
			if(result.length != 0 && result[0] != 'multiple'){
                this.showSecurityQuestion = true;
                this.showError = false;
                this.selectedSecurityQuestions['Question1'] = result[0];
                this.selectedSecurityQuestions['Question2'] = result[1];
                this.selectedSecurityQuestions['Question3'] = result[2];
                this.securityQuestion1 = result[0];
                this.securityQuestion2 = result[1];
                this.securityQuestion3 = result[2];
			} else if(result.length != 0 && result[0] == 'multiple'){
                this.showSecurityQuestion = false;
                this.showError = true;
                this.dynamicErrorText = 'Error: Duplicate User found!. Please contact the Missouri Division of Professional Registration at  ';
            } else{
                this.showSecurityQuestion = false;
                this.showError = true;
                if(this.isIndividualForgotUsername){
                    this.dynamicErrorText = 'Error: Please enter a valid Social Security Number/Name & Date of Birth. The provided value does not match our records. If you need assistance, contact the Missouri Division of Professional Registration ';
                }
                else{
                    this.dynamicErrorText = 'Error: Please enter a valid Owner\'s Social Security Number/Employer Identification Number. The provided value does not match our records. If you need assistance, contact the Missouri Division of Professional Registration ';
                }
            }
			this.showSpinner = false;
		})
		.catch((error) => {
			this.showSpinner = false;
		}).finally(() => {
            this.showSpinner = false;
            this.setFocusOnValidSSNErrorMessage();
             //Focus on the radio button after the screen reader speak the error message
            // eslint-disable-next-line @lwc/lwc/no-async-operation
            new Promise(resolve => setTimeout(resolve, 20000)).then(() => {
                this.focusOnButton();
            });
        });
    }
    // Fixed I-256012 - By piyush aneja
    setFocusOnValidSSNErrorMessage() {
        const dynamicText = this.template.querySelector('.dynamicErrorTextClass');
        if (dynamicText) {
            dynamicText.setAttribute('tabindex', '0');
            dynamicText.focus();
        }
    }

    focusOnButton() {
        let targetElement;

        if (this.selectedOption === 'SSN') {
            targetElement = this.template.querySelector('.validateSSN');
        } else if (this.selectedOption === 'Non-SSN') {
            targetElement = this.template.querySelector('.forgotFirstNameClass');
        } else {
            targetElement = this.template.querySelector('.forgotRadioButtonClass');
        }

        if (targetElement) {
            targetElement.focus();
        }
    }

    //Masking the SSN Number
    maskingSSN(event) {
        this.correctSsn = event.target.value;
        this.newSSN = this.dataObj.uniqueIdentificationNumber;
        if(this.newSSN != null){
            const regex = /\d(?=\d{4})/gm;
            const subst = `X`;
            this.newSSN = this.newSSN.replace(regex, subst);
        }
        
        //  converting from XXXXX4234  -->  XXX-XX-4234
        let temp =  this.dataObj.uniqueIdentificationNumber;
        let newTemp='';
        let i = 0;
        do {
            if (i < temp.length) 
            {
                newTemp = newTemp + temp.substring(i, i + 1); 
                if (i == 2) {
                    newTemp = newTemp + '-';
                }
                if (i == 4) {
                    newTemp = newTemp + '-';
                }
            }
            i = i + 1;
        } while (i < temp.length);

        // Again Changing the value on UI once User left that field
        this.newSSN = newTemp;
    }

    //Masking the EIN Number
	maskingEIN(event) {
		this.newEmployerIdentificationNumber = this.dataObj.uniqueIdentificationNumber;
		//  converting from 123456789  -->  12-3456789
		let temp = this.newEmployerIdentificationNumber;
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
		this.newEmployerIdentificationNumber = newTemp;
	}

    //Recovering masked SSN Number
    recorveringOrginalSSN(){
        this.newSSN = this.dataObj.uniqueIdentificationNumber;
    }

    //Recovering masked EIN Number
	recorveringOrginalEIN() {
		this.newEmployerIdentificationNumber = this.dataObj.uniqueIdentificationNumber;
	}
    
    // Added by saurabh against issue I-253828
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

}