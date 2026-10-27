import { LightningElement, track, wire } from 'lwc';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getRefundRequestDetails from '@salesforce/apex/LPI_RefundRequestController.getRefundRequestDetails';
import submitRefundRequest from '@salesforce/apex/LPI_RefundRequestController.submitRefundRequest';

export default class LpiRefundPage extends NavigationMixin(LightningElement) {
    @track recordId = '';
    @track showSpinner = false;
    @track errorMessage = '';

    @track applicantName = '';
    @track email = '';
    @track phone = '';
    @track dateOfBirth = null;
    @track streetAddress = '';
    @track city = '';
    @track state = '';
    @track zipCode = '';

    @track applicationNumber = '';
    @track stateOrBoard = '';
    @track licenseType = '';
    @track paymentTransactionId = '';

    @track reasonChangeOfPlan = false;
    @track reasonDuplicatePayment = false;
    @track reasonDeceased = false;
    @track reasonOther = false;
    @track otherReasonText = '';

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            const nextId =
                currentPageReference.state?.c__recordId ||
                currentPageReference.state?.recordId ||
                '';
            if (nextId && nextId !== this.recordId) {
                this.recordId = nextId;
                this.loadRefundDetails();
            } else if (!nextId) {
                this.errorMessage = 'Application Id is missing. Please open Refund Request from My Applications.';
            }
        }
    }

    get showOtherText() {
        return this.reasonOther;
    }

    get hasError() {
        return !!this.errorMessage;
    }

    loadRefundDetails() {
        this.showSpinner = true;
        this.errorMessage = '';
        getRefundRequestDetails({ applicationId: this.recordId })
            .then((result) => {
                this.applicantName = result.applicantName || '';
                this.email = result.email || '';
                this.phone = result.phone || '';
                this.dateOfBirth = result.dateOfBirth || null;
                this.streetAddress = result.streetAddress || '';
                this.city = result.city || '';
                this.state = result.state || '';
                this.zipCode = result.zipCode || '';
                this.applicationNumber = result.applicationNumber || '';
                this.stateOrBoard = result.stateOrBoard || '';
                this.licenseType = result.licenseType || '';
                this.paymentTransactionId = result.paymentTransactionId || '';
            })
            .catch((error) => {
                this.errorMessage =
                    error?.body?.message ||
                    error?.message ||
                    'Unable to load refund request details.';
            })
            .finally(() => {
                this.showSpinner = false;
            });
    }

    handleReasonChange(event) {
        const field = event.target.dataset.field;
        const checked = event.target.checked;
        if (field === 'changeOfPlan') {
            this.reasonChangeOfPlan = checked;
        } else if (field === 'duplicatePayment') {
            this.reasonDuplicatePayment = checked;
        } else if (field === 'deceased') {
            this.reasonDeceased = checked;
        } else if (field === 'other') {
            this.reasonOther = checked;
            if (!checked) {
                this.otherReasonText = '';
            }
        }
    }

    handleOtherReasonChange(event) {
        this.otherReasonText = event.target.value;
    }

    handleBack() {
        window.open('/s/', '_self');
    }

    handleSubmit() {
        const hasReason =
            this.reasonChangeOfPlan ||
            this.reasonDuplicatePayment ||
            this.reasonDeceased ||
            this.reasonOther;

        if (!hasReason) {
            this.showToast('Error', 'Please select at least one reason for the refund request.', 'error');
            return;
        }

        if (this.reasonOther && !this.otherReasonText?.trim()) {
            this.showToast('Error', 'Please provide details for Other reason.', 'error');
            return;
        }

        // Values must match Refund_Request__c.Reason_for_Refund_Request__c picklist API names
        const selectedReasons = [];
        if (this.reasonChangeOfPlan) selectedReasons.push('Change of Plan');
        if (this.reasonDuplicatePayment) {
            selectedReasons.push('Double or Duplicate Payment – Include proof of payment');
        }
        if (this.reasonDeceased) {
            selectedReasons.push('Deceased – Must provide death certificate');
        }
        if (this.reasonOther) selectedReasons.push('Other');

        this.showSpinner = true;
        submitRefundRequest({
            applicationId: this.recordId,
            selectedReasons: selectedReasons.join('; '),
            otherReasonDetails: this.reasonOther ? this.otherReasonText : ''
        })
            .then(() => {
                this.showToast(
                    'Success',
                    'Your refund request has been submitted successfully.',
                    'success'
                );
                setTimeout(() => {
                    this.handleBack();
                }, 1500);
            })
            .catch((error) => {
                const msg =
                    error?.body?.message ||
                    error?.message ||
                    'An error occurred while submitting the refund request.';
                this.showToast('Error', msg, 'error');
            })
            .finally(() => {
                this.showSpinner = false;
            });
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }
}