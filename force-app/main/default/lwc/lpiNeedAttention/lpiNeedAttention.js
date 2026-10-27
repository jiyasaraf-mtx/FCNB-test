import { LightningElement, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getPortalNotification from '@salesforce/apex/LPI_NeedYourAttention.getPortalNotification';
import My_Resource from '@salesforce/resourceUrl/LPI_Design';
import createPARRecord from '@salesforce/apex/LPI_NeedYourAttention.createPARRecord';
import setActionAllowedValidation from '@salesforce/apex/LPI_ApplicationFlowUtility.setActionAllowedValidation';
import approveAmendment from '@salesforce/apex/LPI_NeedYourAttention.approveAmendment';
import acknowlegePortalNotifcation from '@salesforce/apex/LPI_NeedYourAttention.acknowlegePortalNotifcation';
import getURLtoNavigate from '@salesforce/apex/LPI_NeedYourAttention.getURLtoNavigate';
import submitMoreInfo from '@salesforce/apex/LPI_NeedYourAttention.submitMoreInfo';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getAcrRecords from '@salesforce/apex/LPI_FCDashboardProfileCompletion.getAcrRecords';
import updateAcrSelectedOnParentAccount from '@salesforce/apex/LPI_FCDashboardProfileCompletion.updateAcrSelectedOnParentAccount';
import fetchBLBadCheck from '@salesforce/apex/LPI_ApplicationFlowUtility.fetchBLBadCheck';
import getCurrentLanguage from '@salesforce/apex/EMP_LanguageCtrl.getCurrentLanguage';
import getLabels from '@salesforce/apex/EMP_LanguageCtrl.getLabels';
import {
    LABEL_API_NAMES,
    mapApiToCamel,
    readStoredLanguage,
    writeStoredLanguage,
    withOmniLanguage
} from 'c/lpLanguageUtils';

export default class LpiNeedAttention extends NavigationMixin(LightningElement) {
    @track labels = {
        importantInformation: 'Important Information',
        importantInformationText: 'To access your Business license applications or Business Licenses, you\'ll need to switch to the account associated with the Business Name you provided during your application. You can find the account-switching option at the top of the page. Click "Select Account" and choose your business account (License) from the dropdown options.',
        needYourAttention: 'Need Your Attention',
        acknowledge: 'Acknowledge',
        closePrefix: 'Close'
    };
    @track notificationList = [];
    showSpinner = false;
    openModal = false;
    modalBody;
    modalParam;
    modalParam1;
    openBusinessModal = false;
    selectedAccountId = '';
    psersonalAccountDetail;
    selectedType = '';
    showBusinessAccountList = false;
    showNotification = false;
    showInstructionText = true;
    closeinsText = '';

    // Add More Info Modal properties
    @track openRmiModal = false;
    @track selectedRmiAppId = '';
    @track selectedRmiAppNumber = '';
    @track selectedRmiComments = '';
    @track applicantRmiComments = '';
    @track uploadedFiles = [];
    @track uploadedDocumentIds = [];
    acceptedFormats = ['.pdf', '.png', '.jpg', '.jpeg', '.doc', '.docx'];

    get insText() {
        return this.labels.importantInformationText;
    } 
    get selectedAccountList() {
        return [
            { label: 'Personal Account', value: 'Personal Information' },
            { label: 'Business Account', value: 'Business Account' }
        ];
    }
    get hasUploadedFiles() {
        return this.uploadedFiles && this.uploadedFiles.length > 0;
    }

    handleChangeAccount(event) {
        this.selectedType = event.target.value;
        if (this.selectedType == 'Business Account') {
            this.showBusinessAccountList = true;
            this.selectedAccountId = '';
        } else {
            this.showBusinessAccountList = false;
            this.selectedAccountId = this.psersonalAccountDetail.Id;
        }
    }

    connectedCallback() {
        this.initLanguage();
        this.selectBusinessAccount();
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
        this.closeinsText = this.labels.closePrefix + ' ' + this.insText;
    }

    selectBusinessAccount() {
        getAcrRecords({})
            .then((result) => {
                if (result.accList) {
                    this.psersonalAccountDetail = result.accList[0];
                    this.acrList = result.accList;
                    this.acrList.shift();
                    this.acrList.shift();
                }
                if (result.accInfo) {
                    this.getPortalNotification(result.accInfo);
                    this.openBusinessModal = false;
                } else {
                    // Safety net only — Apex should already default person account
                    this.openBusinessModal = false;
                    this.selectedAccountId = this.psersonalAccountDetail?.Id;
                    if (this.selectedAccountId) {
                        updateAcrSelectedOnParentAccount({
                            accountId: this.selectedAccountId
                        })
                            .then(() => {
                                this.getPortalNotification({
                                    Id: this.selectedAccountId
                                });
                            })
                            .catch((error) => {
                                this.showMessage(
                                    'Error',
                                    error?.body?.message,
                                    'error'
                                );
                            });
                    }
                }
            })
            .catch((error) => {
                this.showMessage('Error', error?.body?.message, 'error');
            });
    }

    handleBusinessChange(event) {
        this.selectedAccountId = event.target.value;
    }

    handleConfirm() {
        try {
            if (
                this.selectedAccountId &&
                this.selectedAccountId !== '' &&
                this.selectedAccountId !== undefined
            ) {
                updateAcrSelectedOnParentAccount({
                    accountId: this.selectedAccountId
                })
                    .then(() => {
                        location.reload();
                    })
                    .catch((error) => {
                        this.showMessage(
                            'Error',
                            error?.body?.message,
                            'error'
                        );
                    });
            } else {
                this.checkvalidity();
                const evt = new ShowToastEvent({
                    title: 'Error',
                    message: 'Please select Required Field!!',
                    variant: 'error'
                });
                this.dispatchEvent(evt);
            }
        } catch (error) {
            this.showMessage('Error', error?.body?.message, 'error');
        }
    }

    getPortalNotification(accountInfo) {
        getPortalNotification({
            accId: accountInfo.Id
        })
            .then((result) => {
                this.showNotification = false;
                const data = JSON.parse(JSON.stringify(result));
                if (data != null) {
                    let temArr = [];
                    data.forEach(function (arrayItem, index) {
                        // Filter out notifications that don't have a Button_Label__c (Acknowledge notifications)
                        if (arrayItem.Button_Label__c) {
                            // RMI cards are in-memory Notification__c without Id — derive a stable key
                            if (!arrayItem.Id && arrayItem.Url_Param_Json__c) {
                                try {
                                    const params = JSON.parse(arrayItem.Url_Param_Json__c);
                                    arrayItem.Id = params.appId || `rmi-${index}`;
                                } catch (e) {
                                    arrayItem.Id = `rmi-${index}`;
                                }
                            }
                            arrayItem['iconUrl'] =
                                My_Resource + '/media/icons/' + arrayItem['Icon_Name__c'];
                            arrayItem['cardBorderStyle'] =
                                'border-left: 0.25rem solid ' +
                                arrayItem['Side_Color__c'] +
                                ';';
                            temArr.push(arrayItem);
                        }
                    });
                    this.notificationList = temArr;
                }
                if (this.notificationList.length > 0) {
                    this.showNotification = true;
                }
                this.showSpinner = false;
            })
            .catch((error) => {
                this.showMessage('Error', error?.body?.message, 'error');
            });
    }

    handleButton(event) {
        this.showSpinner = true;
        let data;
        const componentName = event.target.dataset.name;
        const navigationType = event.target.dataset.field;
        const notiDesc = event.target.dataset.desc;
        const notiDet = event.target.dataset.det;
        const notiType = event.target.dataset.type;
        const buttonLabel = event.target.dataset.button;

        if (
            event.target.dataset.id !== null &&
            event.target.dataset.id !== undefined
        ) {
            data = JSON.parse(event.target.dataset.id);
            data['notificationId'] = notiDet;
        } else {
            data = { notificationId: notiDet };
        }

        // Handle "Add More Info" button click for RMI Applications
        if (buttonLabel === 'Add More Info' || notiType === 'RMI_Application') {
            this.selectedRmiAppId = data.appId || notiDet;
            this.selectedRmiAppNumber = data.appNumber || '';
            this.selectedRmiComments = data.comments || '';
            this.applicantRmiComments = '';
            this.uploadedFiles = [];
            this.uploadedDocumentIds = [];
            this.openRmiModal = true;
            this.showSpinner = false;
            return;
        }

        let attributeObj;
        if (navigationType === 'standard__component') {
            attributeObj = {
                componentName: 'omnistudio__vlocityLWCOmniWrapper'
            };
        } else if (navigationType === 'comm__namedPage') {
            attributeObj = { pageName: componentName };
        } else {
            const notiTypeSet = new Set(["Renewal","New","Routine Survey","PLS State Exam","PLS State Re-Exam"]);
            const amendmentTypeSet = new Set(["Apply for Professional Corporation"]);
            if (
                notiTypeSet.has(notiType) || 
                (data['amendmentType'] !== null && data['amendmentType'] !== undefined && amendmentTypeSet.has(data['amendmentType']))
            ) {
                this.createApplicationRecord(data);
            } else if (notiType == 'Amendment') {
                approveAmendment({ inputMap: data })
                    .then(() => {
                        window.location.reload();
                        this.showSpinner = false;
                    })
                    .catch((error) => {
                        this.showSpinner = false;
                        this.showMessage(
                            'Error',
                            error?.body?.message,
                            'error'
                        );
                    });
            } else if (notiType == 'Navigate to URL') {
                getURLtoNavigate({ inputMap: data }).then((result) => {
                    if (result == 'Error') {
                        this.showMessage(
                            'Error',
                            'Something went wrong!',
                            'error'
                        );
                    } else {
                        window.open(withOmniLanguage(result), '_self');
                    }
                });
            } else {
                this.openModal = true;
                setTimeout(() => {
                    this.focusFirstEle();
                }, 500);
                this.modalBody = notiDesc;
                this.modalParam = notiDet;
                this.modalParam1 = data;
            }
        }
        this.showSpinner = false;
        if (attributeObj != null) {
            this[NavigationMixin.Navigate]({
                type: navigationType,
                attributes: attributeObj,
                state: data
            });
            if(buttonLabel == 'Apply for Embalmer license' || buttonLabel == 'Apply for FD license'){
                acknowlegePortalNotifcation({ notificationId: notiDet })
                .then(() => {
                    this.showSpinner = false;
                })
                .catch((error) => {
                    this.showSpinner = false;
                    this.showMessage('Error', error?.body?.message, 'error');
                });
            }
            this.showSpinner = false;
        }
    }

    // Handlers for Add More Info Modal
    handleCloseRmiModal() {
        this.openRmiModal = false;
        this.selectedRmiAppId = '';
        this.selectedRmiAppNumber = '';
        this.selectedRmiComments = '';
        this.applicantRmiComments = '';
        this.uploadedFiles = [];
        this.uploadedDocumentIds = [];
    }

    handleApplicantRmiCommentsChange(event) {
        this.applicantRmiComments = event.target.value;
    }

    handleFileUploadFinished(event) {
        const files = event.detail.files;
        if (files && files.length > 0) {
            this.uploadedFiles = [...this.uploadedFiles, ...files];
            files.forEach((file) => {
                this.uploadedDocumentIds.push(file.documentId);
            });
        }
    }

    handleSubmitRmi() {
        if (!this.selectedRmiAppId) {
            this.showMessage('Error', 'Application ID is missing.', 'error');
            return;
        }
        this.showSpinner = true;
        submitMoreInfo({
            applicationId: this.selectedRmiAppId,
            applicantComments: this.applicantRmiComments,
            contentDocumentIds: this.uploadedDocumentIds
        })
            .then(() => {
                this.showSpinner = false;
                this.showMessage('Success', 'Information submitted successfully.', 'success');
                this.handleCloseRmiModal();
                window.location.reload();
            })
            .catch((error) => {
                this.showSpinner = false;
                this.showMessage('Error', error?.body?.message || 'Failed to submit information.', 'error');
            });
    }

    handleCloseModal() {
        this.openModal = false;
        this.template.querySelector(`[data-det="${this.modalParam}"]`).focus();
    }

    handleEscCloseModal(event) {
        const ESC = 27;
        if (event.key === "Escape" || event.key === "Esc" || event.keyCode == ESC) {
            this.openModal = false;
            this.template.querySelector(`[data-det="${this.modalParam}"]`).focus();
        }
    }

    handleRight() {
        this.showSpinner = true;
        this.handleDenyApproveDesignatorBroker('Approved');
    }
    handleWrong() {
        this.showSpinner = true;
        this.handleDenyApproveDesignatorBroker('Rejected');
    }
    handleDenyApproveDesignatorBroker(status) {
        denyOrApproveRequestForDesignatedBroker({
            notificationId: this.modalParam,
            individualApplicationId: this.modalParam1.Id,
            status: status
        })
            .then((result) => {
                if (result === 'Success') {
                    this.showMessage(
                        'Success',
                        status + ' Successfully',
                        'success'
                    );
                } else {
                    this.showMessage('Error', result, 'error');
                }
                this.openModal = false;
                this.modalBody = '';
                this.modalParam = '';
                window.location.reload();
            })
            .catch((error) => {
                this.showMessage('Error', error?.body?.message, 'error');
            });
    }

    showMessage(title, message, variant) {
        const toastEvt = new ShowToastEvent({
            title,
            message,
            variant
        });
        this.dispatchEvent(toastEvt);
    }

    createApplicationRecord(data) {
        fetchBLBadCheck({
            inputMap: data
        }).then(badCheck => {
            if(badCheck){
                this.showMessage('Error', 'We regret to inform you that your License has been put on hold, therefore you will be unable to submit any new applications at this time. Please contact the board for further information.','error');
                this.showSpinner = false;
            } else {
                setActionAllowedValidation({
                    inputMap: data
                })
                    .then((res) => {
                        if (res) {
                            createPARRecord({
                                inputMap: data
                            })
                                .then((result) => {
                                    if (result == 'Error') {
                                        this.showMessage(
                                            'Error',
                                            'Something went wrong!',
                                            'error'
                                        );
                                    } else {
                                        window.open(withOmniLanguage(result), '_self');
                                    }
                                    this.showSpinner = false;
                                })
                                .catch((error) => {
                                    this.showSpinner = false;
                                    this.showMessage(
                                        'Error',
                                        error?.body?.message,
                                        'error'
                                    );
                                });
                        } else {
                            this.showSpinner = false;
                            this.showMessage(
                                'Info',
                                'The same application has been already submitted. Go to My Applications sections on the dashboard in order to access it.',
                                'info'
                            );
                        }
                    })
                    .catch((error) => {
                        this.showSpinner = false;
                        this.showMessage('Error', error?.body?.message, 'error');
                    });
        }})
        .catch(error => {
            this.showMessage('Error', error?.body?.message, 'error');
            this.showSpinner = false;
        });
    }

    handleAcknowledge(event) {
        this.showSpinner = true;
        const notiId = event.target.dataset.id;
        acknowlegePortalNotifcation({ notificationId: notiId })
            .then(() => {
                window.location.reload();
                this.showSpinner = false;
            })
            .catch((error) => {
                this.showSpinner = false;
                this.showMessage('Error', error?.body?.message, 'error');
            });
    }

    checkvalidity() {
        let validRadio = [
            ...this.template.querySelectorAll('lightning-radio-group')
        ].reduce((validSoFar2, input) => {
            input.reportValidity();
            return validSoFar2 && input.checkValidity();
        }, true);

        let allInput = this.template.querySelector('.slds-has-error');

        if (allInput) {
            allInput.scrollIntoView();
            allInput.focus();
        }

        return validRadio;
    }

    focusFirstEle() {
        const focusableElements = 'lightning-combobox, lightning-button-icon, button, lightning-helptext, lightning-input, lightning-button, lightning-radio-group';
        const modal = this.template.querySelector('.slds-modal');
        if (!modal) return;
        const firstFocusableElement = modal.querySelectorAll(focusableElements)[0];
        const focusableContent = modal.querySelectorAll(focusableElements);
        const lastFocusableElement = focusableContent[focusableContent.length - 1];
        if (firstFocusableElement) {
            firstFocusableElement.focus();
        }
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
            } else {
                if (this.activeElement === lastFocusableElement) {
                    firstFocusableElement.focus();
                    event.preventDefault();
                    event.stopPropagation();
                }
            }
        });
    }

    handleShowInstructionText(){
        this.showInstructionText = false;
    }
}