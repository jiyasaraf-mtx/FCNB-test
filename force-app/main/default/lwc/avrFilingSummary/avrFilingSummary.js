import { LightningElement, api, track } from 'lwc';
import getFiling from '@salesforce/apex/AVR_FilingCtrl.getFiling';
import getCurrentLanguage from '@salesforce/apex/EMP_LanguageCtrl.getCurrentLanguage';
import getLabels from '@salesforce/apex/EMP_LanguageCtrl.getLabels';
import {
    PP_LABEL_API_NAMES,
    mapApiToCamel,
    readStoredLanguage
} from 'c/lpLanguageUtils';

/**
 * Read-only AVR Filing summary for Pension Portal View action.
 */
export default class AvrFilingSummary extends LightningElement {
    @api filingId;

    @track labels = {
        reviewSummary: 'Review & Summary',
        backToPensionFilings: 'Back to Pension Filings',
        filingId: 'Filing ID',
        filingHeader: 'Filing Header',
        planData: 'Plan Data',
        filingType: 'Filing type',
        reportingYear: 'Reporting Year',
        plan: 'Plan',
        planNumber: 'Plan number',
        firstName: 'First Name',
        lastName: 'Last Name',
        email: 'Email',
        phone: 'Phone',
        registrationNumber: 'Registration Number',
        valuationDate: 'Valuation Date',
        filingDueDate: 'Filing Due Date',
        actuaryName: 'Actuary Name',
        actuaryFirm: 'Actuary Firm',
        notes: 'Notes',
        status: 'Status',
        rmiStatus: 'RMI Status',
        attestation: 'Attestation',
        yes: 'Yes',
        no: 'No',
        loading: 'Loading...'
    };

    @track isLoading = true;
    @track errorMessage = '';
    @track filing = {};

    connectedCallback() {
        this.load();
    }

    renderedCallback() {
        if (this.filingId && this.filing?.id !== this.filingId && !this.isLoading) {
            this.load();
        }
    }

    get showContent() {
        return !this.isLoading && !this.errorMessage && this.filing?.id;
    }

    get statusClass() {
        const status = String(this.filing?.status || '').toLowerCase();
        if (status === 'accepted' || status === 'submitted') {
            return 'badge green';
        }
        if (status === 'draft' || status === 'more information required') {
            return 'badge amber';
        }
        return 'badge';
    }

    get attestationDisplay() {
        return this.filing?.attestationConfirmed ? this.labels.yes : this.labels.no;
    }

    dash(value) {
        if (value === null || value === undefined || value === '') {
            return '—';
        }
        return value;
    }

    async load() {
        if (!this.filingId) {
            this.errorMessage = 'Filing Id is required.';
            this.isLoading = false;
            return;
        }
        this.isLoading = true;
        this.errorMessage = '';
        try {
            await this.loadLabels();
            const dto = (await getFiling({ filingId: this.filingId })) || {};
            this.filing = {
                ...dto,
                nameDisplay: this.dash(dto.name),
                filingTypeDisplay: this.dash(dto.filingType),
                reportingYearDisplay: this.dash(dto.reportingYear),
                planNameDisplay: this.dash(dto.planName),
                planNumberDisplay: this.dash(dto.planRegistrationNumber),
                firstNameDisplay: this.dash(dto.firstName),
                lastNameDisplay: this.dash(dto.lastName),
                emailDisplay: this.dash(dto.email),
                phoneDisplay: this.dash(dto.phone),
                registrationNumberDisplay: this.dash(dto.registrationNumber),
                valuationDateDisplayValue: this.dash(dto.valuationDateDisplay),
                filingDueDateDisplayValue: this.dash(dto.filingDueDateDisplay),
                actuaryNameDisplay: this.dash(dto.actuaryName),
                actuaryFirmDisplay: this.dash(dto.actuaryFirm),
                notesDisplay: this.dash(dto.notes),
                statusDisplay: this.dash(dto.status),
                rmiStatusDisplay: this.dash(dto.rmiStatus)
            };
        } catch (e) {
            this.errorMessage =
                e?.body?.message || e.message || 'Unable to load filing summary.';
            this.filing = {};
        } finally {
            this.isLoading = false;
        }
    }

    async loadLabels() {
        try {
            const stored = readStoredLanguage();
            const language = stored || (await getCurrentLanguage());
            const apiMap = await getLabels({
                apiNames: PP_LABEL_API_NAMES,
                language
            });
            const camel = mapApiToCamel(apiMap);
            this.labels = {
                ...this.labels,
                reviewSummary: camel.ppReviewSummary || this.labels.reviewSummary,
                backToPensionFilings:
                    camel.ppBackToPensionFilings || this.labels.backToPensionFilings,
                filingId: camel.ppFilingId || this.labels.filingId,
                filingHeader: camel.ppFilingHeader || this.labels.filingHeader,
                planData: camel.ppPlanData || this.labels.planData,
                filingType: camel.ppFilingType || this.labels.filingType,
                reportingYear: camel.ppReportingYear || this.labels.reportingYear,
                plan: camel.ppPlan || this.labels.plan,
                planNumber: camel.ppPlanNumber || this.labels.planNumber,
                firstName: camel.ppFirstName || this.labels.firstName,
                lastName: camel.ppLastName || this.labels.lastName,
                email: camel.ppEmail || this.labels.email,
                phone: camel.ppPhone || this.labels.phone,
                registrationNumber:
                    camel.ppRegistrationNumber || this.labels.registrationNumber,
                valuationDate: camel.ppValuationDate || this.labels.valuationDate,
                filingDueDate: camel.ppFilingDueDate || this.labels.filingDueDate,
                actuaryName: camel.ppActuaryName || this.labels.actuaryName,
                actuaryFirm: camel.ppActuaryFirm || this.labels.actuaryFirm,
                notes: camel.ppNotes || this.labels.notes,
                status: camel.ppStatus || this.labels.status,
                rmiStatus: camel.ppRmiStatus || this.labels.rmiStatus,
                attestation: camel.ppAttestationLabel || this.labels.attestation,
                loading: camel.ppLoading || this.labels.loading
            };
        } catch (e) {
            // keep defaults
        }
    }

    handleBack() {
        this.dispatchEvent(
            new CustomEvent('back', {
                bubbles: true,
                composed: true
            })
        );
    }
}