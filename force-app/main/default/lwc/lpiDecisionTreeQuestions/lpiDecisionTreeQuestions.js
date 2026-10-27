/**
 * @description       : Decision tree questions for Licensing Portal (EN/FR)
 * @author            : Abel David Solomon
 * @last modified on  : 09-16-2026
**/
import checkSystemValidation from '@salesforce/apex/LPI_DecisionTreeQuestionsController.checkSystemValidation';
import getQuestionDetails from '@salesforce/apex/LPI_DecisionTreeQuestionsController.getQuestionDetails';
import updateResponse from '@salesforce/apex/LPI_DecisionTreeQuestionsController.updateResponse';
import getLabels from '@salesforce/apex/EMP_LanguageCtrl.getLabels';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { LightningElement, track } from 'lwc';
import {
    DECISION_TREE_LABEL_API_NAMES,
    mapApiToCamel,
    readStoredLanguage,
    writeStoredLanguage
} from 'c/lpLanguageUtils';

export default class LpiDecisionTreeQuestions extends NavigationMixin(LightningElement) {
    showSpinner = false;
    showError = false;
    errorMessage = '';
    @track questionsData = [];
    @track updatedQuestionsData = [];
    @track professionId;
    @track allowLaunchFlow = false;
    redirectToLicensePage = false;
    redirectUrl = '';
    showBottomHelp = false;
    bottomHelpText = '';
    @track paramRedirectValue = {};
    openConfirmationModal = false;
    openDuplicateModal = false;
    selectedLanguage = 'en_US';
    traineeAppraiserLicense = [
        'State Licensed Appraiser Trainee',
        'State Certified Residential Appraiser Trainee',
        'State Certified General Appraiser Trainee'
    ];

    @track labels = {
        dtIntro:
            'Providing responses to the following questions will assist you in choosing the most suitable license or registration application for your needs.',
        asteriskRequired: 'Asterisk (*) indicates required field',
        dtExit: 'Exit',
        dtNext: 'Next',
        dtImportantReminder: 'Important Reminder',
        dtModalBody:
            "Your responses are crucial to initiate the application process. Once the process begins, you cannot modify your responses. You'll need to withdraw and start a new application if changes are needed.",
        dtModalConfirmHint: 'Select Confirm to proceed.',
        dtCancel: 'Cancel',
        dtConfirm: 'Confirm',
        dtClose: 'Close',
        dtCloseModal: 'Close Important Reminder modal',
        dtDuplicateTitle: 'Duplicate Application',
        dtDuplicateApp:
            'The same application has already been submitted or a draft application has been created. Go to My Applications section on Dashboard in order to access it.',
        dtSomethingWrong: 'Something went wrong. Please contact your administration.',
        dtWaitOpening: 'Wait Application is Opening !!'
    };

    connectedCallback() {
        this.showSpinner = true;
        const urlParams = new URLSearchParams(window.location.search);
        const paramValue = urlParams.get('profesionId');
        this.professionId = paramValue;
        this.initLanguageAndLoad();
    }

    async initLanguageAndLoad() {
        const stored = readStoredLanguage();
        this.selectedLanguage = stored === 'fr' ? 'fr' : 'en_US';
        writeStoredLanguage(this.selectedLanguage);
        try {
            const apiMap = await getLabels({
                apiNames: DECISION_TREE_LABEL_API_NAMES,
                language: this.selectedLanguage
            });
            this.labels = { ...this.labels, ...mapApiToCamel(apiMap) };
        } catch (e) {
            // keep English defaults
        }
        this.loadQuestions(this.professionId);
    }

    fillQuestionsData() {
        this.updatedQuestionsData = JSON.parse(JSON.stringify(this.questionsData));
        this.showSpinner = false;
    }

    loadQuestions(profId) {
        this.showError = false;
        this.errorMessage = '';
        this.openDuplicateModal = false;
        this.showBottomHelp = false;
        this.bottomHelpText = '';
        getQuestionDetails({ professionId: profId, language: this.selectedLanguage })
            .then((result) => {
                if (result != null) {
                    if (result.showError) {
                        this.showError = true;
                        this.showSpinner = false;
                        this.errorMessage = result.errorMessage;
                    } else if (result.openFLow) {
                        this.showSpinner = false;
                        if (result.responseValue == 'Duplicate') {
                            this.showDuplicateModal();
                        } else if (result.responseValue == 'Error') {
                            this.showError = true;
                            this.errorMessage = this.labels.dtSomethingWrong;
                        } else {
                            this.showError = true;
                            this.errorMessage = this.labels.dtWaitOpening;
                            window.open(result.responseValue + '&type=New', '_self');
                        }
                    } else {
                        if (result.professionName == 'Preneed Provider') {
                            this.showBottomHelp = true;
                            this.bottomHelpText =
                                'If you are an endowed care cemetery operating under Chapter 214 RSMo, please contact the State Board of Embalmers and Funeral Directors.';
                        }
                        this.questionsData = JSON.parse(JSON.stringify(result.questionsList));
                        this.fillQuestionsData();
                    }
                }
            })
            .catch((error) => {
                this.showToast('Error', error?.body?.message, 'error');
            })
            .finally(() => {
                this.showSpinner = false;
            });
    }

    showDuplicateModal() {
        this.openConfirmationModal = false;
        this.openDuplicateModal = true;
        this.showSpinner = false;
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        setTimeout(() => {
            this.focusFirstEle();
        }, 500);
    }

    handleClickBack() {
        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                pageName: 'recommended-profession'
            }
        });
    }

    async handleChange(event) {
        this.showSpinner = true;
        this.redirectToLicensePage = false;
        this.redirectUrl = '';
        this.showError = false;
        this.errorMessage = '';
        var result = await this.updateQuestionResponse(event);
        if (result) {
            await this.loadUpdatedQuestions();
            this.showSpinner = false;
        }
        setTimeout(() => {
            this.template.querySelector('.focus-helper')?.focus();
        }, 2500);
    }

    updateQuestionResponse(event) {
        this.updatedQuestionsData.forEach((element) => {
            if (event.target.name == element.name) {
                element.userResponse = event.target.value;
                if (
                    element.checkSystemValidation &&
                    element.systemValidMatchValue.length !== 0 &&
                    element.systemValidMatchValue == event.target.value
                ) {
                    checkSystemValidation({ questionId: element.id })
                        .then((result) => {
                            this.updatedQuestionsData.forEach((innerElement) => {
                                if (
                                    innerElement.questionDependentOn == element.id &&
                                    innerElement.questionCondition == element.userResponse &&
                                    !innerElement.showQuestion
                                ) {
                                    innerElement.userResponse = result;
                                    if (innerElement.errorMessageMatchingCondition == result) {
                                        this.showError = true;
                                        this.errorMessage = innerElement.errorMessage;
                                    }
                                }
                            });
                        })
                        .catch((error) => {
                            this.showToast('Error', error?.body?.message, 'error');
                        });
                }
                if (element.errorMessageMatchingCondition == element.userResponse) {
                    this.showError = true;
                    this.errorMessage = element.errorMessage;
                }
            }
        });
        return new Promise((resolve) => {
            setTimeout(() => {
                resolve(true);
            }, 1000);
        });
    }

    loadUpdatedQuestions() {
        try {
            this.updatedQuestionsData.forEach((element) => {
                this.updatedQuestionsData.forEach((innerElement) => {
                    if (
                        innerElement.questionDependentOn == element.id &&
                        innerElement.questionCondition == element.userResponse
                    ) {
                        innerElement.questionConditionMeet = true;
                    }
                    if (
                        innerElement.questionDependentOn == element.id &&
                        innerElement.questionCondition != element.userResponse
                    ) {
                        innerElement.questionConditionMeet = false;
                        innerElement.userResponse = '';
                    }
                });
            });
        } catch (e) {
            // ignore
        }
    }

    handleClick() {
        let valid = this.validateFields();
        if (valid) {
            this.showSpinner = true;
            if (this.redirectToLicensePage) {
                this[NavigationMixin.Navigate]({
                    type: 'standard__namedPage',
                    attributes: {
                        pageName: this.redirectUrl
                    },
                    state: {
                        blNumber: this.paramRedirectValue
                    }
                });
            } else {
                this.showSpinner = false;
                this.openConfirmationModal = true;
                setTimeout(() => {
                    this.focusFirstEle();
                }, 500);
            }
        }
        this.focus = false;
        this.focusIndex = -1;
        let isAllValid = [
            ...this.template.querySelectorAll(
                'lightning-input,lightning-textarea,lightning-radio-group,lightning-combobox'
            )
        ].reduce((validSoFar, input) => {
            input.reportValidity();
            let fieldValid = input.checkValidity();
            fieldValid = input.disabled ? true : fieldValid;
            if (
                !fieldValid &&
                (!this.focus || this.focusIndex == -1 || this.focusIndex > parseInt(input.dataset.index))
            ) {
                input.focus();
                this.focus = true;
                this.focusIndex = input.dataset.index;
            }
            return validSoFar && fieldValid;
        }, true);

        return isAllValid;
    }

    showToast(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: variant
            })
        );
    }

    validateFields() {
        let isAllValid = [...this.template.querySelectorAll('lightning-combobox')].reduce(
            (validSoFar, inputCmp) => {
                inputCmp.reportValidity();
                return validSoFar && inputCmp.checkValidity();
            },
            true
        );
        isAllValid &= [...this.template.querySelectorAll('lightning-input')].reduce((validSoFar, input) => {
            input.reportValidity();
            return validSoFar && input.checkValidity();
        }, true);
        isAllValid &= [...this.template.querySelectorAll('lightning-radio-group')].reduce(
            (validSoFar, input) => {
                input.reportValidity();
                return validSoFar && input.checkValidity();
            },
            true
        );
        return isAllValid;
    }

    handleInputChange(event) {
        this.redirectToLicensePage = true;
        var val = event.target.dataset.option;
        this.redirectUrl = val;
        this.paramRedirectValue = event.target.value;
    }

    handleCancelConfirmation() {
        this.openConfirmationModal = false;
        this.newApplicationUrl = null;
        this.setFocusOnNextButton();
    }

    handleCloseDuplicateModal() {
        this.openDuplicateModal = false;
    }

    setFocusOnNextButton() {
        const focusOnNext = this.template.querySelector('.focusOnNext');
        if (focusOnNext) {
            focusOnNext.focus();
        }
    }

    handleOkConfirmation() {
        this.openConfirmationModal = false;
        this.showSpinner = true;
        var responseData = [];
        this.updatedQuestionsData.forEach((element) => {
            if (
                element.userResponse != '' &&
                element.questionConditionMeet &&
                (element.allowLaunchFlow || element.saveUserResponse)
            ) {
                responseData.push(element);
            }
        });
        if (responseData.length > 0) {
            updateResponse({ responseData: JSON.stringify(responseData) })
                .then((result) => {
                    this.showSpinner = false;
                    if (result == 'Duplicate') {
                        this.showDuplicateModal();
                    } else if (result == 'Error') {
                        this.showToast('Error', this.labels.dtSomethingWrong, 'error');
                    } else {
                        result = result + '&type=New';
                        window.open(result, '_self');
                    }
                })
                .catch((error) => {
                    this.showSpinner = false;
                    this.showToast('Error', error?.body?.message, 'error');
                });
        }
    }

    handleEscKeyDown(event) {
        if (event.code === 'Escape' || event.keyCode === 27) {
            if (this.openDuplicateModal) {
                this.handleCloseDuplicateModal();
            } else {
                this.handleCancelConfirmation();
            }
        }
    }

    focusFirstEle() {
        const focusableElements =
            'lightning-combobox, lightning-button-icon, button, lightning-helptext, lightning-input, lightning-button, lightning-radio-group';
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
                    event.stopPropagation();
                    event.preventDefault();
                }
            } else if (this.activeElement === lastFocusableElement) {
                firstFocusableElement.focus();
                event.preventDefault();
                event.stopPropagation();
            }
        });
    }
}