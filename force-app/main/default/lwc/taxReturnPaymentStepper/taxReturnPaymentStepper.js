import { LightningElement, api } from 'lwc';
import { OmniscriptBaseMixin } from 'omnistudio/omniscriptBaseMixin';

const DEFAULT_PAYEE = 'The Financial and Consumer Services Commission';
const DEFAULT_PAYMENT_STATUS = 'Not Paid';
const DEFAULT_TAX_TYPE = 'Premium Tax';

/**
 * Premium Tax Return — Fees & Payment summary panel for FCNB_Premium Tax Return.
 * Reads Applicant / Period / Return ID / Levy from OmniScript JSON dynamically.
 */
export default class TaxReturnPaymentStepper extends OmniscriptBaseMixin(LightningElement) {
    /** Optional payee override from OmniScript Custom LWC properties. */
    @api payeeName;

    /** Optional notice text override. */
    @api paymentNotice;

    get omniData() {
        return this.omniJsonData || {};
    }

    get returnDetails() {
        const data = this.omniData;
        return (data.Return && data.Return.ReturnDetails) || data.ReturnDetails || {};
    }

    get premiumsLevy() {
        const data = this.omniData;
        return data.Premiums_Levy || {};
    }

    get levyBlock() {
        return this.premiumsLevy.Levy || {};
    }

    get premiumsBlock() {
        return this.premiumsLevy.Premiums || {};
    }

    get feesPayment() {
        return this.omniData.Fees_Payment || {};
    }

    get summaryBlock() {
        return this.feesPayment.Summary || {};
    }

    get applicantName() {
        return (
            this.firstValue(this.omniData.ApplicantName) ||
            this.resolveLookupName(this.returnDetails.Applicant) ||
            this.resolveLookupName(this.omniData.Applicant) ||
            this.firstValue(this.omniData.AccountName, this.omniData.BusinessName) ||
            ''
        );
    }

    get taxType() {
        return (
            this.firstValue(
                this.returnDetails.TaxType,
                this.omniData.TaxType,
                this.summaryBlock.TaxType
            ) || DEFAULT_TAX_TYPE
        );
    }

    get reportingPeriod() {
        return (
            this.firstValue(
                this.returnDetails.ReportingPeriod,
                this.omniData.ReportingPeriod,
                this.summaryBlock.ReportingPeriod
            ) || ''
        );
    }

    get contextValue() {
        const fromSummary = this.firstValue(
            this.summaryBlock.Context,
            this.summaryBlock.Formula1,
            this.feesPayment.Context
        );
        if (fromSummary && !String(fromSummary).includes('%')) {
            return fromSummary;
        }

        const parts = [this.taxType];
        if (this.applicantName) {
            parts.push(this.applicantName);
        }
        if (this.reportingPeriod) {
            parts.push(this.reportingPeriod);
        }
        return parts.filter(Boolean).join(' - ') || '—';
    }

    get returnIdValue() {
        return (
            this.firstValue(
                this.returnDetails.ReturnIdDisplay,
                this.omniData.ReturnId,
                this.omniData.FilingNumber,
                this.omniData.ReturnIdDisplay,
                this.summaryBlock['Return ID'],
                this.omniData.Id,
                this.omniData.ContextId
            ) || '—'
        );
    }

    get paymentStatusValue() {
        return (
            this.firstValue(
                this.summaryBlock['Payment Status'],
                this.feesPayment['Payment Status'],
                this.omniData.PaymentStatus,
                this.omniData.FilingStatus,
                this.omniData.Status,
                this.returnDetails.FilingStatus
            ) || DEFAULT_PAYMENT_STATUS
        );
    }

    get amountDueRaw() {
        return this.firstValue(
            this.levyBlock.PTR_LV_Calculated_Levy,
            this.premiumsLevy.PTR_LV_Calculated_Levy,
            this.findInTree(this.omniData, 'PTR_LV_Calculated_Levy'),
            this.summaryBlock['Amount Due'],
            this.feesPayment['Amount Due'],
            this.omniData.CalculatedLevy,
            this.omniData.PTR_LV_Calculated_Levy,
            this.omniData.AmountDue
        );
    }

    get amountDueValue() {
        const raw = this.amountDueRaw;
        if (raw === null || raw === undefined || raw === '') {
            const premiums = this.toNumber(
                this.firstValue(
                    this.premiumsBlock.TaxablePremiumsNB,
                    this.omniData.TaxablePremiumsNB,
                    this.findInTree(this.omniData, 'TaxablePremiumsNB')
                )
            );
            const rate = this.toNumber(
                this.firstValue(
                    this.levyBlock.PTR_LV_Rate,
                    this.omniData.PTR_LV_Rate,
                    this.findInTree(this.omniData, 'PTR_LV_Rate')
                )
            );
            if (premiums != null && rate != null) {
                return this.formatMoney((premiums * rate) / 100);
            }
            return '—';
        }
        return this.formatMoney(raw);
    }

    get payeeValue() {
        return this.firstValue(this.payeeName, this.omniData.Payee, DEFAULT_PAYEE);
    }

    get noticeText() {
        return (
            this.paymentNotice ||
            'This demonstration uses a staged mock gateway only. Do not enter live card information.'
        );
    }

    resolveLookupName(value) {
        if (value === undefined || value === null || value === '') {
            return null;
        }
        if (typeof value === 'string' || typeof value === 'number') {
            const s = String(value).trim();
            // Lookup may store User Id — ignore bare Salesforce Ids
            if (/^[a-zA-Z0-9]{15}$|^[a-zA-Z0-9]{18}$/.test(s)) {
                return null;
            }
            return s;
        }
        if (typeof value === 'object') {
            return (
                this.firstValue(value.Name, value.name, value.label, value.Title) || null
            );
        }
        return null;
    }

    firstValue(...values) {
        for (const v of values) {
            if (v !== undefined && v !== null && String(v).trim() !== '') {
                return v;
            }
        }
        return null;
    }

    findInTree(node, key, depth = 0) {
        if (!node || typeof node !== 'object' || depth > 6) {
            return null;
        }
        if (Object.prototype.hasOwnProperty.call(node, key) && node[key] != null && node[key] !== '') {
            return node[key];
        }
        for (const child of Object.values(node)) {
            if (child && typeof child === 'object' && !Array.isArray(child)) {
                const found = this.findInTree(child, key, depth + 1);
                if (found !== null && found !== undefined && found !== '') {
                    return found;
                }
            }
        }
        return null;
    }

    toNumber(value) {
        if (value === undefined || value === null || value === '') {
            return null;
        }
        const n = Number(String(value).replace(/[^0-9.-]/g, ''));
        return Number.isFinite(n) ? n : null;
    }

    formatMoney(value) {
        const n = this.toNumber(value);
        if (n === null) {
            return String(value);
        }
        try {
            return new Intl.NumberFormat('en-CA', {
                style: 'currency',
                currency: 'CAD'
            }).format(n);
        } catch (e) {
            return `$${n.toFixed(2)}`;
        }
    }
}