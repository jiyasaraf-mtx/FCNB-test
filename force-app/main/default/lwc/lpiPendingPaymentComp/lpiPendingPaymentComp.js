import { LightningElement, api, track, wire } from 'lwc';
import { NavigationMixin, CurrentPageReference } from 'lightning/navigation';
import { loadStyle } from 'lightning/platformResourceLoader';
import LPI_InternalCSS from '@salesforce/resourceUrl/LPI_Design';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import fetchUnderpaymentFees from '@salesforce/apex/LPI_InternalPaymentController.fetchUnderpaymentFees';
import fetchAdditionalFeeTypeFromRat from '@salesforce/apex/LPI_InternalPaymentController.fetchAdditionalFeeTypeFromRat';
import fetchProcess from '@salesforce/apex/LPI_InternalPaymentController.fetchProcess';
import fetchPaymentType from '@salesforce/apex/LPI_InternalPaymentController.fetchPaymentType';
import savePendingPaymentData from '@salesforce/apex/LPI_InternalPaymentController.savePendingPaymentData';
import getLicenseDetail from '@salesforce/apex/LPI_InternalPaymentController.getLicenseDetail';
import fetchApplicationIdForNav from "@salesforce/apex/LPI_InternalPaymentController.fetchApplicationIdForNav";
import getApplicationData from '@salesforce/apex/LPI_ApplicationActionsController.getApplicationData';
import allowResume from '@salesforce/apex/LPI_ApplicationViewController.allowResume';
import { buildOmniLwcName, resolveOmniLanguageCode } from 'c/lpLanguageUtils';

export default class LpiPendingPaymentComp extends NavigationMixin(
    LightningElement
) {
    showSpinner = false;
    openAddFeeModal = false;
    feeAmount;
    rowId;
    showReadonlyText;
    objectCode;
    @track feeList = [];
    @track underPaymentFeeList = [];
	@api recordId;
    @api applicationId;
    @api licenseTypeId;
    @api applicationType;
    @api applicationSubType;
    @api accId;
    @api objectType;
    @api isBadCheckPayment;
    @api regTrxFeeId;
    @api isOverPayment = false;
    boardName;
    totalFeeAmount = 0;
    pendingAmount = 0;
    remainingAmount = 0;
    feeTypeOptions = [];
    orignalFeeTypeOptions = [];
    dataObj = {};
    @track paymentTypeOptions = [];
    @track processTypeOptions = [];
    paidBySomeoneOtherCondition = false;
    isDisabled = true;
    checkNumberRequired = true;
    isUnderPaymentModalOpen = false;
    licenseNumber;
    licenseeName;
    redirectURL;
    @track process = 'CRR';
    _hasInitialized = false;

    get getTotalFeeAmount() {
        var formattedNumber = this.totalFeeAmount.toFixed(2);
        return formattedNumber;
    }

    @wire(CurrentPageReference)
    handlePageRef(pageRef) {
        if (!pageRef) {
            return;
        }
        this.applyPageState(pageRef.state);
        this.tryInitialize();
    }

    applyPageState(state) {
        if (!state) {
            return;
        }
        this.recordId = this.getStateValue(state, 'c__recordId', this.recordId);
        this.applicationId = this.getStateValue(state, 'c__applicationId', this.applicationId);
        this.licenseTypeId = this.getStateValue(state, 'c__licenseTypeId', this.licenseTypeId);
        this.applicationType = this.getStateValue(state, 'c__applicationType', this.applicationType);
        this.applicationSubType = this.getStateValue(state, 'c__applicationSubType', this.applicationSubType);
        this.accId = this.getStateValue(state, 'c__accId', this.accId);
        this.objectType = this.getStateValue(state, 'c__objectType', this.objectType);
        this.regTrxFeeId = this.getStateValue(state, 'c__regTrxFeeId', this.regTrxFeeId);
        this.isBadCheckPayment = this.getBooleanState(state, 'c__isBadCheckPayment', this.isBadCheckPayment);
        this.isOverPayment = this.getBooleanState(state, 'c__isOverPayment', this.isOverPayment);
    }

    getStateValue(state, key, fallback) {
        const value = state[key];
        return value !== undefined && value !== null && value !== '' ? value : fallback;
    }

    getBooleanState(state, key, fallback) {
        const value = state[key];
        if (value === undefined || value === null || value === '') {
            return fallback;
        }
        return value === true || value === 'true';
    }

    tryInitialize() {
        if (!this._hasInitialized && this.applicationId) {
            this._hasInitialized = true;
            this.initializePendingPaymentPage();
        }
    }

    connectedCallback() {
        loadStyle(this, LPI_InternalCSS + "/styles/internal-main.css");
        this.tryInitialize();
    }

    initializePendingPaymentPage() {
        this.showSpinner = true;
        let redirectURL = {
            type: 'standard__recordPage',
            attributes: {
                recordId: this.applicationId,
                objectApiName: this.objectType,
                actionName: 'view'
            }
        };
        this[NavigationMixin.GenerateUrl](redirectURL).then((url) => {
            this.redirectURL = url;
        });

        // Fetch Fee Type Options for Adding Additional Fee
        fetchAdditionalFeeTypeFromRat({
            ratId: this.licenseTypeId
        })
            .then((result) => {
                this.orignalFeeTypeOptions = result;
                let i;
                for (i = 0; i < result.length; i++) {
                    if (result[i].Name !== 'Underpayment') {
                        const option = {
                            label: result[i].Name,
                            value: result[i].Name
                        };
                        this.feeTypeOptions = [...this.feeTypeOptions, option];
                    }
                }
                if (this.isOverPayment) {
                    let overPaymentList = this.orignalFeeTypeOptions.filter(
                        (element) => element.Name == 'Overpayment'
                    );
                    if (overPaymentList.length > 0) {
                        this.feeList = overPaymentList;
                        this.feeList = [
                            { ...this.feeList[0], Id: 1, disableMenu: false }
                        ];
                    } else {
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Error',
                                message:
                                    'Overpayment fee is not configured on this Regulatory Authorization Type. Add an Additional Fee named Overpayment on the RAT.',
                                variant: 'error'
                            })
                        );
                    }
                }
            })
            .catch((error) => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message:
                            'Problem in fetching fee type! ' +
                            JSON.stringify(error),
                        variant: 'error'
                    })
                );
            });

        // Fetch Payment Type Options for Payment Information
        fetchPaymentType()
            .then((result) => {
                this.paymentTypeOptions = result;
            })
            .catch((error) => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message:
                            'Problem in fetching payment type! ' +
                            JSON.stringify(error),
                        variant: 'error'
                    })
                );
            });

        // Fetch Process Options for Payment Information
        fetchProcess()
            .then((result) => {
                this.processTypeOptions = result;
            })
            .catch((error) => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message:
                            'Problem in fetching process! ' +
                            JSON.stringify(error),
                        variant: 'error'
                    })
                );
            });

        if (this.applicationId !== null && this.applicationId !== undefined) {
            getLicenseDetail({
                recordId: this.applicationId
            })
                .then((result) => {
                    this.licenseNumber = result.licenseNumber;
                    this.licenseeName = result.licenseeName;
                    this.boardName = result.boardName;
                })
                .catch((error) => {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message:
                                'Problem in fetching License Details! ' +
                                JSON.stringify(error),
                            variant: 'error'
                        })
                    );
                });
        }
        if (!this.isOverPayment) {
            this.fetchPendingAmount();
        } else {
            this.showSpinner = false;
        }
    }

    get showLicenseDetails() {
        return this.licenseNumber !== null && this.licenseNumber !== undefined;
    }

    fetchPendingAmount() {
        fetchUnderpaymentFees({
            applicationId: this.applicationId,
            regTrxFeeId: this.regTrxFeeId,
            fetchBadCheckFee: this.isBadCheckPayment
        })
            .then((result) => {
                let sum = 0;
                this.feeList = JSON.parse(JSON.stringify(result));
                this.feeList.forEach((row) => {
                    sum += row.Amount;
                });
                this.totalFeeAmount = sum;
                this.pendingAmount = sum;
                this.remainingAmount = this.totalFeeAmount;
                this.showSpinner = false;
            })
            .catch((error) => {
                this.showSpinner = false;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message:
                            'Problem in fetching fee data! ' +
                            JSON.stringify(error),
                        variant: 'error'
                    })
                );
            });
    }

    handleAmountChange(event) {
        this.feeAmount = Number(event.target.value);
        if (
            ((!this.showReadonlyText &&
                this.additionalFeeTypeName === 'Underpayment') ||
                (this.showReadonlyText &&
                    this.readOnlyText === 'Underpayment')) &&
            this.feeAmount > 0
        ) {
            this.feeAmount = -this.feeAmount;
        }
    }

    openAddFeeModalWindow() {
        this.openAddFeeModal = true;
        this.showReadonlyText = false;
        this.feeAmount = 0;
        this.rowId = null;
    }

    closeAddFeeModalWindow() {
        this.openAddFeeModal = false;
    }

    handleAdditionalFeeTypeChange(event) {
        let updatedList = this.orignalFeeTypeOptions.filter(
            (element) => element.Name === event.target.value
        );
        if (updatedList.length > 0) {
            this.feeAmount = updatedList[0].Amount;
            this.objectCode = updatedList[0].objectCode;
        }

        this.additionalFeeTypeName = event.target.value;
        if (this.feeAmount === 0) {
            this.isDisabled = false;
        } else {
            this.isDisabled = true;
        }

        //Setting the min amount and max amount that anyone can enter
        if (this.additionalFeeTypeName !== 'Underpayment') {
            this.minAmountToBeEntered = 0;
            this.maxAmountToBeEntered = 999999;
        } else {
            this.minAmountToBeEntered = '';
            this.maxAmountToBeEntered = '';
        }
    }

    saveAddFeeDetails() {
        let targetFeeAmount = this.template.querySelector('.targetFeeAmount');
        let feeTypePicklist = this.template.querySelector('.targetFeeType');
        //If Amount is not valid
        if (!targetFeeAmount.reportValidity()) {
            return;
        }
        //if FeeType is not valid
        if (
            feeTypePicklist !== null &&
            feeTypePicklist !== undefined &&
            !feeTypePicklist.reportValidity()
        ) {
            return;
        }

        //For New Record creation
        if (this.rowId == null) {
            let data = {
                Amount: this.feeAmount,
                disableMenu: true,
                Id: this.feeList.length,
                Name: this.additionalFeeTypeName,
                objectCode: this.objectCode
            };

            this.feeList.push(data);
            this.totalFeeAmount = 0;
            for (let i = 0; i < this.feeList.length; i++) {
                this.totalFeeAmount += this.feeList[i].Amount;
            }
        }
        //For Record Edit
        else {
            this.totalFeeAmount = 0;
            this.feeList[this.rowId].Amount = this.feeAmount;
            for (let i = 0; i < this.feeList.length; i++) {
                this.totalFeeAmount += this.feeList[i].Amount;
            }
        }

        if (this.dataObj.amountTendered != null) {
            this.remainingAmount =
                this.totalFeeAmount - this.dataObj.amountTendered;
        } else {
            this.remainingAmount = this.totalFeeAmount;
        }
        this.openAddFeeModal = false;
    }

    deleteFeeDetails(event) {
        var selectedRowId = event.target.dataset.id;
        this.totalFeeAmount =
            this.totalFeeAmount - this.feeList[selectedRowId].Amount;
        this.feeList.splice(selectedRowId, 1);
        let newFeeList = this.feeList;

        for (let i = 0; i < newFeeList.length; i++) {
            newFeeList[i].Id = i;
        }
        this.feeList = newFeeList;
        // Updating Pending Amount
        if (this.dataObj.amountTendered != null) {
            this.remainingAmount =
                this.totalFeeAmount - this.dataObj.amountTendered;
        } else {
            this.remainingAmount = this.totalFeeAmount;
        }
    }

    editFeeDetails(event) {
        this.rowId = event.target.dataset.id;
        this.openAddFeeModal = true;

        this.showReadonlyText = true;
        this.feeAmount = this.feeList[this.rowId].Amount;
        this.readOnlyText = this.feeList[this.rowId].Name;
        this.isDisabled = false;

        //Setting the min amount and max amount that anyone can enter
        if (this.readOnlyText === 'Underpayment') {
            this.minAmountToBeEntered = '';
            this.maxAmountToBeEntered = 0;
        } else {
            this.minAmountToBeEntered = 0;
            this.maxAmountToBeEntered = '';
        }
    }

    handleChange(event) {
        if (event.target.name === 'paymentType') {
            if (event.target.value === 'Cash') {
                this.checkNumberRequired = false;
            } else {
                this.checkNumberRequired = true;
            }
        }
        if (event.target.name === 'paidBySomeoneOther') {
            this.dataObj.paidBySomeoneOther = event.target.checked;
            if (this.dataObj.paidBySomeoneOther === true) {
                this.paidBySomeoneOtherCondition = true;
            } else {
                this.paidBySomeoneOtherCondition = false;
                this.dataObj.payerName = null;
                this.dataObj.payerPhone = null;
            }
        } else {
            const rawValue = event.target.value;
            this.dataObj[event.target.name] = typeof rawValue === 'string' ? rawValue.trim() : rawValue;
            if (event.target.name === 'amountTendered') {
                if (this.isOverPayment) {
                    if (this.feeList && this.feeList.length > 0) {
                        this.feeList[0].Amount = Number(event.target.value);
                        this.totalFeeAmount = Number(this.feeList[0].Amount);
                    }
                } else {
                    this.remainingAmount =
                        this.totalFeeAmount - Number(this.dataObj.amountTendered);
                }
            }
        }
    }

    isInputValid() {
        let isValid = true;
        let inputFields = this.template.querySelectorAll('.validate');
        inputFields.forEach((inputField) => {
            if (!inputField.checkValidity()) {
                inputField.reportValidity();
                isValid = false;
            }
        });
        return isValid;
    }

    closeUnderPaymentModal() {
        this.isUnderPaymentModalOpen = false;
        this.showSpinner = false;
    }

    handleSubmit() {
        if (this.isInputValid()) {
            this.showSpinner = true;

            if (
                this.remainingAmount < 0 ||
                this.dataObj.amountTendered === 0 ||
                this.totalFeeAmount === 0 ||
                this.pendingAmount > this.totalFeeAmount
            ) {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Problem',
                        message: 'Balance out the Fees, discrepancy found!',
                        variant: 'error'
                    })
                );
                this.showSpinner = false;
            } else {
                this.underPaymentFeeList = [];
                this.feeList.forEach((element) => {
                    element.actualAskedAmount = element.Amount;
                    let clonedElement = Object.assign({}, element);
                    clonedElement.pendingPaymentAmount = 0;
                    this.underPaymentFeeList.push(clonedElement);
                });
                if (this.remainingAmount !== 0 && !this.isBadCheckPayment) {
                    this.isUnderPaymentModalOpen = true;
                    let leftAmount = -this.remainingAmount;
                    this.underPaymentFeeList.every(function (element) {
                        element.Amount = element.Amount + leftAmount;
                        if (element.Amount < 0) {
                            leftAmount = element.Amount;
                            element.Amount = 0;
                            element.pendingPaymentAmount =
                                element.actualAskedAmount - element.Amount;
                            return true;
                        } else {
                            element.pendingPaymentAmount =
                                element.actualAskedAmount - element.Amount;
                            return false;
                        }
                    });
                    this.showSpinner = false;
                    //this.feeList[0].Amount = this.feeList[0].Amount - this.remainingAmount;
                } else {
                    if (this.isBadCheckPayment && this.remainingAmount !== 0) {
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Problem',
                                message:
                                    'Balance out the Fees, make sure remaining amout is $0!',
                                variant: 'error'
                            })
                        );
                        this.showSpinner = false;
                        return;
                    }
                    this.saveDataInDatabase(this.feeList);
                }
            }
        }
    }

    handleUnderPaymentConform() {
        this.showSpinner = true;
        this.saveDataInDatabase(this.underPaymentFeeList);
    }

    saveDataInDatabase(feeList) {
        savePendingPaymentData({
            feeList: JSON.stringify(feeList),
            paymentInformation: JSON.stringify(this.dataObj),
            applicationId: this.applicationId,
            accountId: this.accId,
            remainingAmount: this.remainingAmount,
            isBadCheckPayment: this.isBadCheckPayment,
            boardName: this.boardName,
            badCheckRegTrxFeeId: this.regTrxFeeId
        })
            .then((result) => {
                this.hasError = false;
                if (result) {
                    if (
                        (this.objectType === 'Account' ||
                            this.objectType === 'BusinessLicense') &&
                        (this.isBadCheckPayment || this.isOverPayment)
                    ) {
                        this[NavigationMixin.Navigate]({
                            type: 'standard__recordPage',
                            attributes: {
                                recordId: result,
                                objectApiName: 'RegulatoryTrxnFee',
                                actionName: 'view'
                            }
                        });
                    } else {
                        window.open(this.redirectURL, '_self');
                    }
                    // fetchApplicationIdForNav({
                    //     licenseTypeId: this.licenseTypeId,
                    //     accId: this.accId,
                    //     applicationType: this.applicationType,
                    //     applicationSubType: this.applicationSubType
                    // })
                    //     .then((resultNew) => {
                    //         this.handleNavigation(resultNew);
                    //     })
                    //     .catch((errorNew) => {
                    //         if (typeof errorNew.body.message === "string") {
                    //             this.dispatchEvent(
                    //                 new ShowToastEvent({
                    //                     title: "Error",
                    //                     message: errorNew.body.message,
                    //                     variant: "error"
                    //                 })
                    //             );
                    //         }
                    //     }).finally(() => {
                    //         this.showSpinner = false;
                    //     });
                }
            })
            .catch((error) => {
                this.showSpinner = false;
                if (typeof error.body.message === 'string') {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: error.body.message,
                            variant: 'error'
                        })
                    );
                }
            });
    }
    handleNavigation(resultNew) {
        if (resultNew) {
            this.handleLoad(resultNew);

        } else {
            if (this.blId) {
                this.navigateToBlRecordPage();
            } else {
                this.navigateToViewAccountPage();
            }
        }
    }
    handleLoad(resultNew) {
        let resultArr = resultNew.split('-');
        getApplicationData({ recordId: resultArr[1] })
            .then((response) => {
                this.applicationData = response.applicationData;
                this.buttonList = response.buttonList;
                this.handleResumeApplication(this.buttonList[1], resultArr);
            })
            .catch((error) => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: "Error",
                        message: error,
                        variant: "error"
                    })
                );
            })
            .finally(() => {
            })
    }
    navigateToBlRecordPage() {
        this[NavigationMixin.Navigate]({
            type: "standard__recordPage",
            attributes: {
                recordId: this.blId,
                objectApiName: "BusinessLicense",
                actionName: "view"
            }
        });
    }
    navigateToViewAccountPage() {
        this[NavigationMixin.Navigate]({
            type: "standard__recordPage",
            attributes: {
                recordId: this.recordId,
                objectApiName: "Account",
                actionName: "view"
            }
        });
    }
    handleResumeApplication(buttonDetail, applicationData) {
        if (applicationData == undefined) {
            return;
        }
        this.showSpinner = true;
        allowResume({ applicationId: applicationData[1] })
            .then((result) => {
                if (result) {
                    const buttonJSON = JSON.parse(buttonDetail.buttonData);
                    let type = buttonJSON['osType'];
                    let subtype = buttonJSON['osSubType'];
                    let language = buttonJSON['osLanguage'];
                    let omniScriptName = buildOmniLwcName(type, subtype, language);
                    this[NavigationMixin.Navigate]({
                        type: "standard__component",
                        attributes: {
                            componentName: "omnistudio__vlocityLWCOmniWrapper"
                        },
                        state: {
                            c__target: "c:" + omniScriptName,
                            c__layout: "lightning",
                            c__tabIcon: "custom:custom18",
                            c__tabLabel: "Apply for license",
                            c__accountId: this.applicationData.accountId,
                            c__ContextId: this.applicationData.licenceTypeId,
                            c__portalUser: "false",
                            c__parid: this.applicationData.parId,
                            c__blId: this.applicationData.licenceId,
                            c__language: resolveOmniLanguageCode()
                        }
                    });
                } else {
                    this[NavigationMixin.Navigate]({
                        type: "standard__recordPage",
                        attributes: {
                            recordId: applicationData[1],
                            objectApiName: applicationData[0],
                            actionName: "view"
                        }
                    });
                }
            })
            .catch((error) => {
                const event = new ShowToastEvent({
                    title: 'Error',
                    message: 'Something went wrong! ' + error,
                    variant: 'error',
                });
                this.dispatchEvent(event);
            }).finally(() => {
                this.showSpinner = false;
            });
    }
}