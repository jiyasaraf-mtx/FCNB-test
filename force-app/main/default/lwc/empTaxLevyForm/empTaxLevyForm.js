import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getFormContext from '@salesforce/apex/EMP_TaxLevyFormsCtrl.getFormContext';
import createDraftRecord from '@salesforce/apex/EMP_TaxLevyFormsCtrl.createDraftRecord';
import submitForm from '@salesforce/apex/EMP_TaxLevyFormsCtrl.submitForm';

const FORM_CONFIG = {
    PremiumTax: {
        title: 'Premium Tax Return',
        steps: ['Header', 'Premiums & levy', 'Record payment', 'Review & submit'],
        submitLabel: 'Submit to FCNB'
    },
    FireMarshal: {
        title: 'Fire Marshal Levy',
        steps: ['Assessment', 'Record payment', 'Review & submit'],
        submitLabel: 'Submit for approval'
    },
    VehicleLevy: {
        title: 'Vehicle Levy',
        steps: ['Assessment', 'Record payment', 'Review & submit'],
        submitLabel: 'Submit for approval'
    }
};

export default class EmpTaxLevyForm extends LightningElement {
    @api formType = 'PremiumTax';

    @track stepIndex = 0;
    @track isLoading = true;
    @track isSubmitting = false;
    @track context = {
        insurerName: '',
        parentLicence: '',
        paidTo: '',
        glAccount: '',
        expectedAmount: null,
        assessedAmount: null,
        assessedBy: '',
        sourceFilingRef: '',
        priorYearActual: null,
        periodOptions: [],
        paymentMethods: []
    };
    @track errorMessage = '';
    @track contextReady = false;

    // shared editable fields
    @track period = '';
    @track periodStart = '2026-04-01';
    @track periodEnd = '2026-06-30';
    @track contactFirstName = '';
    @track contactLastName = '';
    @track contactEmail = '';
    @track contactPhone = '';
    @track taxablePremiums = '1000000';
    @track exemptPremiums = '0';
    @track paymentDate = '';
    @track amountPaid = '';
    @track paymentMethod = 'EFT';
    @track remittanceReference = '';
    @track proofFileName = '';
    @track draftRecordId = null;
    @track isCreatingDraft = false;
    @track attestation = false;

    acceptedFormats = ['.pdf', '.png', '.jpg', '.jpeg'];

    connectedCallback() {
        const params = new URLSearchParams(window.location.search || '');
        const fromUrl = params.get('c__formType') || params.get('formType');
        if (fromUrl) {
            this.formType = fromUrl;
        }
        if (!this.paymentDate) {
            this.paymentDate = new Date().toISOString().slice(0, 10);
        }
    }

    @wire(getFormContext, { formType: '$resolvedFormType' })
    wiredContext({ data, error }) {
        if (data) {
            this.context = data;
            this.contextReady = true;
            this.isLoading = false;
            this.period = (data.periodOptions && data.periodOptions[0]) || '';
            this.contactFirstName = data.contactFirstName || '';
            this.contactLastName = data.contactLastName || '';
            this.contactEmail = data.contactEmail || '';
            this.contactPhone = data.contactPhone || '';
            if (this.isPremium) {
                this.amountPaid = this.calculatedLevyNumber.toFixed(2);
                this.remittanceReference = 'NB-PREM-2026-Q2-44102';
            } else if (this.isFire) {
                this.amountPaid = String(data.expectedAmount || 12500);
                this.remittanceReference = 'NB-FML-2026-8821';
            } else {
                this.amountPaid = '7500';
                this.remittanceReference = 'NB-VEH-2026-Q2-190';
            }
            this.errorMessage = '';
        } else if (error) {
            this.isLoading = false;
            this.contextReady = false;
            this.errorMessage = error?.body?.message || error.message || 'Unable to load form.';
        }
    }

    get hasContext() {
        return this.contextReady === true;
    }

    get insurerName() {
        return this.context?.insurerName || '';
    }

    get parentLicence() {
        return this.context?.parentLicence || '';
    }

    get paidTo() {
        return this.context?.paidTo || '';
    }

    get glAccount() {
        return this.context?.glAccount || '';
    }

    get assessedBy() {
        return this.context?.assessedBy || '';
    }

    get sourceFilingRef() {
        return this.context?.sourceFilingRef || '';
    }

    get priorYearActualDisplay() {
        return this.context?.priorYearActual != null
            ? this.formatMoney(this.context.priorYearActual)
            : '';
    }

    get expectedAmountRaw() {
        return this.context?.expectedAmount != null ? this.context.expectedAmount : '';
    }

    get assessedAmountRaw() {
        return this.context?.assessedAmount != null ? this.context.assessedAmount : '';
    }

    get resolvedFormType() {
        return this.formType || 'PremiumTax';
    }

    get isPremium() {
        return this.resolvedFormType === 'PremiumTax';
    }

    get isFire() {
        return this.resolvedFormType === 'FireMarshal';
    }

    get isVehicle() {
        return this.resolvedFormType === 'VehicleLevy';
    }

    get config() {
        return FORM_CONFIG[this.resolvedFormType] || FORM_CONFIG.PremiumTax;
    }

    get formTitle() {
        return this.config.title;
    }

    get steps() {
        return (this.config.steps || []).map((label, index) => {
            const state =
                index < this.stepIndex ? 'done' : index === this.stepIndex ? 'on' : 'todo';
            return {
                key: `s-${index}`,
                index,
                number: index + 1,
                label: `${index + 1}. ${label}`,
                className: `step-item ${state}`
            };
        });
    }

    get maxStep() {
        return (this.config.steps || []).length - 1;
    }

    get isFirstStep() {
        return this.stepIndex === 0;
    }

    get isLastStep() {
        return this.stepIndex === this.maxStep;
    }

    get nextLabel() {
        return this.isLastStep ? this.config.submitLabel : 'Next';
    }

    get nextClass() {
        return this.isLastStep ? 'btn btn-success' : 'btn btn-brand';
    }

    get backClass() {
        return this.isFirstStep ? 'btn btn-ghost hidden-btn' : 'btn';
    }

    get periodOptions() {
        return (this.context?.periodOptions || []).map((value) => ({
            label: value,
            value
        }));
    }

    get paymentMethodOptions() {
        return (this.context?.paymentMethods || []).map((value) => ({
            label: value,
            value
        }));
    }

    get rateDisplay() {
        const rate = this.context?.rate || 0.02;
        return `${(rate * 100).toFixed(2)}%`;
    }

    get calculatedLevyNumber() {
        const taxable = Number(this.taxablePremiums || 0);
        const rate = this.context?.rate || 0.02;
        return taxable * rate;
    }

    get calculatedLevyDisplay() {
        return this.formatMoney(this.calculatedLevyNumber);
    }

    get amountDueDisplay() {
        return this.calculatedLevyNumber.toFixed(2);
    }

    get expectedAmountDisplay() {
        return this.formatMoney(this.context?.expectedAmount || 0);
    }

    get assessedAmountDisplay() {
        return this.formatMoney(this.context?.assessedAmount || 0);
    }

    get fireVarianceDisplay() {
        const paid = Number(this.amountPaid || 0);
        const expected = Number(this.context?.expectedAmount || 0);
        const v = paid - expected;
        if (v === 0) return '$0.00 (none)';
        return `${this.formatMoney(Math.abs(v))}${v < 0 ? ' under' : ' over'}`;
    }

    get fireMatchDisplay() {
        const paid = Number(this.amountPaid || 0);
        const expected = Number(this.context?.expectedAmount || 0);
        return paid === expected ? 'Matched' : 'Variance — exception / RMI';
    }

    get vehicleTrueUpBalance() {
        const paid = Number(this.amountPaid || 0);
        const assessed = Number(this.context?.assessedAmount || 0);
        const diff = assessed - paid;
        if (diff === 0) return '$0.00';
        return `${this.formatMoney(Math.abs(diff))} ${diff > 0 ? 'underpaid' : 'overpaid'}`;
    }

    get vehicleTrueUpTreatment() {
        const paid = Number(this.amountPaid || 0);
        const assessed = Number(this.context?.assessedAmount || 0);
        const diff = assessed - paid;
        if (diff === 0) return 'No true-up required';
        if (diff > 0) return `Add ${this.formatMoney(diff)} to next quarterly invoice`;
        return `Credit ${this.formatMoney(Math.abs(diff))} on next quarterly invoice`;
    }

    get showPremiumStep1() {
        return this.isPremium && this.stepIndex === 0;
    }
    get showPremiumStep2() {
        return this.isPremium && this.stepIndex === 1;
    }
    get showPremiumStep3() {
        return this.isPremium && this.stepIndex === 2;
    }
    get showPremiumStep4() {
        return this.isPremium && this.stepIndex === 3;
    }
    get showFireStep1() {
        return this.isFire && this.stepIndex === 0;
    }
    get showFireStep2() {
        return this.isFire && this.stepIndex === 1;
    }
    get showFireStep3() {
        return this.isFire && this.stepIndex === 2;
    }
    get showVehicleStep1() {
        return this.isVehicle && this.stepIndex === 0;
    }
    get showVehicleStep2() {
        return this.isVehicle && this.stepIndex === 1;
    }
    get showVehicleStep3() {
        return this.isVehicle && this.stepIndex === 2;
    }

    get hasDraftRecord() {
        return !!this.draftRecordId;
    }

    get proofFileLabel() {
        return this.proofFileName || '';
    }

    get isPaymentStep() {
        return (
            (this.isPremium && this.stepIndex === 2) ||
            (this.isFire && this.stepIndex === 1) ||
            (this.isVehicle && this.stepIndex === 1)
        );
    }

    get reviewRows() {
        if (this.isPremium) {
            return [
                { key: 'period', label: 'Period', value: this.period },
                { key: 'taxable', label: 'Taxable premiums', value: this.formatMoney(this.taxablePremiums) },
                { key: 'levy', label: 'Calculated levy', value: this.calculatedLevyDisplay },
                { key: 'paidTo', label: 'Paid to', value: this.context?.paidTo },
                { key: 'paid', label: 'Amount paid', value: this.formatMoney(this.amountPaid) },
                { key: 'payDate', label: 'Payment date', value: this.paymentDate },
                { key: 'method', label: 'Method', value: this.paymentMethod },
                { key: 'remit', label: 'Remittance #', value: this.remittanceReference },
                { key: 'proof', label: 'Proof', value: this.proofFileName || 'Missing — please attach receipt' }
            ];
        }
        if (this.isFire) {
            return [
                { key: 'period', label: 'Period', value: this.period },
                { key: 'expected', label: 'Expected (FCNB calc)', value: this.expectedAmountDisplay },
                { key: 'paid', label: 'Amount paid', value: this.formatMoney(this.amountPaid) },
                { key: 'var', label: 'Variance', value: this.fireVarianceDisplay },
                { key: 'match', label: 'Match', value: this.fireMatchDisplay },
                { key: 'method', label: 'Method', value: this.paymentMethod },
                { key: 'remit', label: 'Remittance #', value: this.remittanceReference },
                { key: 'proof', label: 'Proof', value: this.proofFileName || 'Missing — please attach receipt' }
            ];
        }
        return [
            { key: 'period', label: 'Assessment period', value: this.period },
            { key: 'assessed', label: 'Amount assessed', value: this.assessedAmountDisplay },
            { key: 'paid', label: 'Amount paid', value: this.formatMoney(this.amountPaid) },
            { key: 'trueup', label: 'True-up balance', value: this.vehicleTrueUpBalance },
            { key: 'treatment', label: 'True-up treatment', value: this.vehicleTrueUpTreatment },
            { key: 'method', label: 'Method', value: this.paymentMethod },
            { key: 'remit', label: 'Remittance #', value: this.remittanceReference },
            { key: 'proof', label: 'Proof', value: this.proofFileName || 'Missing — please attach receipt' }
        ];
    }

    handleFieldChange(event) {
        const field = event.target.dataset.field;
        const type = event.target.type;
        let value = event.target.value;
        if (type === 'checkbox') {
            value = event.target.checked;
        }
        this[field] = value;
        if (field === 'taxablePremiums' && this.isPremium) {
            this.amountPaid = this.calculatedLevyNumber.toFixed(2);
        }
    }

    handleUploadFinished(event) {
        const uploaded = event.detail.files || [];
        if (uploaded.length) {
            this.proofFileName = uploaded.map((f) => f.name).join(', ');
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: `${uploaded.length} file(s) uploaded.`,
                    variant: 'success'
                })
            );
        }
    }

    ensureDraftRecord() {
        if (this.draftRecordId || this.isCreatingDraft) {
            return Promise.resolve(this.draftRecordId);
        }
        this.isCreatingDraft = true;
        return createDraftRecord({ formType: this.resolvedFormType })
            .then((result) => {
                this.draftRecordId = result.recordId;
                this.isCreatingDraft = false;
                return this.draftRecordId;
            })
            .catch((error) => {
                this.isCreatingDraft = false;
                this.toast(error?.body?.message || error.message || 'Unable to prepare record for file upload.');
                return null;
            });
    }

    handleBack() {
        if (this.stepIndex > 0) {
            this.stepIndex -= 1;
        }
    }

    handleNext() {
        if (!this.validateCurrentStep()) {
            return;
        }
        if (this.isLastStep) {
            this.submit();
            return;
        }
        this.stepIndex += 1;
        if (this.isPaymentStep) {
            this.ensureDraftRecord();
        }
    }

    validateCurrentStep() {
        if (this.isPremium && this.stepIndex === 0) {
            if (!this.period || !this.contactFirstName || !this.contactLastName || !this.contactEmail || !this.contactPhone) {
                this.toast('Complete all required header fields.');
                return false;
            }
        }
        if (this.isPremium && this.stepIndex === 1) {
            if (this.taxablePremiums === '' || this.taxablePremiums === null) {
                this.toast('Enter taxable premiums.');
                return false;
            }
        }
        if (
            (this.isPremium && this.stepIndex === 2) ||
            (this.isFire && this.stepIndex === 1) ||
            (this.isVehicle && this.stepIndex === 1)
        ) {
            if (!this.paymentDate || !this.amountPaid || !this.paymentMethod || !this.remittanceReference) {
                this.toast('Complete all required payment fields.');
                return false;
            }
            if (!this.proofFileName) {
                this.toast('Upload proof of payment (receipt) before continuing.');
                return false;
            }
        }
        if (this.isLastStep && !this.attestation) {
            this.toast('Check the attestation to submit.');
            return false;
        }
        return true;
    }

    submit() {
        this.isSubmitting = true;
        const values = {
            period: this.period,
            periodStart: this.periodStart,
            periodEnd: this.periodEnd,
            contactFirstName: this.contactFirstName,
            contactLastName: this.contactLastName,
            contactEmail: this.contactEmail,
            contactPhone: this.contactPhone,
            taxablePremiums: this.taxablePremiums,
            exemptPremiums: this.exemptPremiums,
            paymentDate: this.paymentDate,
            amountPaid: this.amountPaid,
            paymentMethod: this.paymentMethod,
            remittanceReference: this.remittanceReference,
            proofFileName: this.proofFileName,
            attestation: this.attestation,
            recordId: this.draftRecordId
        };

        submitForm({
            request: {
                formType: this.resolvedFormType,
                values
            }
        })
            .then((result) => {
                this.isSubmitting = false;
                window.open(result.successUrl, '_self');
            })
            .catch((error) => {
                this.isSubmitting = false;
                this.toast(error?.body?.message || error.message || 'Submit failed.');
            });
    }

    formatMoney(value) {
        const n = Number(value || 0);
        return `$${n.toLocaleString('en-CA', {
            minimumFractionDigits: 2,
            maximumFractionDigits: 2
        })}`;
    }

    toast(message) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Validation',
                message,
                variant: 'error'
            })
        );
    }
}