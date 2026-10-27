import { LightningElement, track } from 'lwc';
import { OmniscriptBaseMixin } from 'omnistudio/omniscriptBaseMixin';

const RECEIPT_PREFIX = 'RCPT-';

export default class TaxPaymentLWC extends OmniscriptBaseMixin(LightningElement) {
    @track showGateway = false;
    @track gatewayStep = 1; // 1 authorize, 2 spinner, 3 success
    @track isPaid = false;
    @track receiptId = '';

    _authTimer;

    disconnectedCallback() {
        if (this._authTimer) {
            clearTimeout(this._authTimer);
        }
    }

    get omniData() {
        return this.omniJsonData || {};
    }

    get returnDetails() {
        return this.omniData?.Return?.ReturnDetails || {};
    }

    get contextText() {
        const taxType = this.returnDetails.TaxType || this.omniData.TaxType || 'Premium Tax';
        const applicant =
            this.omniData.ApplicantName ||
            this.returnDetails.ApplicantName ||
            '';
        const period =
            this.returnDetails.ReportingPeriod || this.omniData.ReportingPeriod || '';
        return [taxType, applicant, period].filter(Boolean).join(' - ');
    }

    get returnId() {
        return (
            this.omniData.ReturnId ||
            this.returnDetails.ReturnIdDisplay ||
            this.omniData.FilingNumber ||
            'N/A'
        );
    }

    get paymentStatus() {
        if (this.isPaid) {
            return 'Paid after stub';
        }
        return (
            this.omniData.PaymentStatus ||
            this.omniData.FilingStatus ||
            this.returnDetails.FilingStatus ||
            'Not Paid'
        );
    }

    get amountNumber() {
        const raw =
            this.omniData?.Premiums_Levy?.Levy?.PTR_LV_Calculated_Levy ??
            this.omniData?.PTR_LV_Calculated_Levy ??
            this.omniData?.CalculatedLevy;
        const n = Number(raw);
        return Number.isFinite(n) ? n : 0;
    }

    get currencyCode() {
        return this.omniData.userCurrencyCode || 'CAD';
    }

    get amountDue() {
        return this.formatMoney(this.amountNumber);
    }

    get gatewayAmount() {
        return `${this.formatMoney(this.amountNumber)} ${this.currencyCode}`;
    }

    get showPayButton() {
        return !this.isPaid;
    }

    get showGatewayStep1() {
        return this.showGateway && this.gatewayStep === 1;
    }

    get showGatewayStep2() {
        return this.showGateway && this.gatewayStep === 2;
    }

    get showGatewayStep3() {
        return this.showGateway && this.gatewayStep === 3;
    }

    get showPaymentResult() {
        return this.isPaid;
    }

    formatMoney(amount) {
        try {
            return new Intl.NumberFormat('en-CA', {
                style: 'currency',
                currency: this.currencyCode
            }).format(Number(amount) || 0);
        } catch (e) {
            return `$${(Number(amount) || 0).toFixed(2)}`;
        }
    }

    handlePayClick() {
        if (this.isPaid) {
            return;
        }
        this.showGateway = true;
        this.gatewayStep = 1;
    }

    handleCancelGateway() {
        if (this.isPaid) {
            return;
        }
        if (this._authTimer) {
            clearTimeout(this._authTimer);
            this._authTimer = null;
        }
        this.showGateway = false;
        this.gatewayStep = 1;
    }

    handleAuthorize() {
        this.gatewayStep = 2;
        if (this._authTimer) {
            clearTimeout(this._authTimer);
        }
        this._authTimer = setTimeout(() => {
            this.gatewayStep = 3;
            this._authTimer = null;
        }, 1000);
    }

    handleCompleteStubPayment() {
        const suffix =
            String(this.returnId).replace(/\D/g, '').slice(-5) ||
            String(Date.now()).slice(-5);
        this.receiptId = `${RECEIPT_PREFIX}${suffix}`;
        this.isPaid = true;
        this.showGateway = false;
        this.gatewayStep = 1;

        if (typeof this.omniApplyCallResp === 'function') {
            this.omniApplyCallResp({
                PaymentStatus: 'Paid after stub',
                FilingStatus: 'Paid',
                ReceiptId: this.receiptId,
                PaymentCompleted: true
            });
        }
    }
}