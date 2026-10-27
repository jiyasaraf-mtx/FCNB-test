import { LightningElement, api, track } from 'lwc';
import { OmniscriptBaseMixin } from 'omnistudio/omniscriptBaseMixin';
import getCurrentLanguage from '@salesforce/apex/EMP_LanguageCtrl.getCurrentLanguage';
import getLabels from '@salesforce/apex/EMP_LanguageCtrl.getLabels';
import {
    PP_LABEL_API_NAMES,
    mapApiToCamel,
    readStoredLanguage
} from 'c/lpLanguageUtils';

const DEFAULT_SKIP = new Set([
    'ContextId',
    'c__ContextId',
    'AVRFilingId',
    'FilingNumber',
    'Status',
    'ContactId',
    'AccountId',
    'PlanId',
    'Submitted',
    'timeStamp',
    'userId',
    'userProfile',
    'userName',
    'userCurrencyCode',
    'omniScriptId',
    'elementName',
    'ReviewSummary',
    'InitAVRFiling',
    'SaveAVRFiling',
    'SubmitAVRFiling',
    'SetPlanRegistrationFromLookup',
    'SetReviewSummaryValues',
    'labelData',
    'labels',
    'fieldLabels',
    'formData',
    'reviewData',
    'AttestationConfirmed'
]);

/** Omni element name -> Custom Label API (without requiring PP_ prefix in config). */
const FIELD_LABEL_API = {
    FilingType: 'PP_Filing_Type',
    ReportingYear: 'PP_Reporting_Year',
    PlanName: 'PP_Plan',
    PlanLookup: 'PP_Plan',
    PlanRegistrationNumber: 'PP_Plan_Registration_Number',
    PlanDataRegistrationNumber: 'PP_Plan_Registration_Number',
    RegistrationNumber: 'PP_Registration_Number',
    FirstName: 'PP_First_Name',
    LastName: 'PP_Last_Name',
    Email: 'PP_Email',
    Phone: 'PP_Phone',
    ValuationDate: 'PP_Valuation_Date',
    FilingDueDate: 'PP_Filing_Due_Date',
    ActuaryName: 'PP_Actuary_Name',
    ActuaryFirm: 'PP_Actuary_Firm',
    Notes: 'PP_Notes',
    FilingHeader: 'PP_Filing_Header',
    PlanData: 'PP_Plan_Data',
    Documents: 'PP_Documents',
    ReviewSummary: 'PP_Review_Summary'
};

const NESTED_DISPLAY_KEYS = ['PlanName', 'Name', 'label', 'title', 'Id', 'PlanRegistrationNumber'];

/**
 * Generic OmniScript Review & Summary.
 * Works with any OmniScript by reading step JSON from omniJsonData / jsonData.
 * Labels resolve via Custom Labels + portal language (EN/FR).
 */
export default class OmniReviewSummary extends OmniscriptBaseMixin(LightningElement) {
    /** Comma-separated step keys. Blank = auto-detect object steps. */
    @api sectionKeys = '';
    /** Extra root keys to skip when auto-detecting. */
    @api skipKeys = '';
    @api showDisclosure = false;
    @api requireAttestation = false;
    @api hideEmptyFields = false;
    /** Custom Label prefix used for fallback lookups (e.g. PP_). */
    @api labelPrefix = 'PP_';
    @api title = '';

    @track sections = [];
    @track isLoading = true;
    @track attestationConfirmed = false;
    @track showAttestationError = false;
    @track labels = {
        reviewSummary: 'Review & Summary',
        disclosure: 'Disclosure',
        disclosureText:
            'I confirm that the information provided in this filing is complete and accurate to the best of my knowledge.',
        attestation: 'I confirm the information above is accurate.',
        attestationRequired: 'Please confirm the attestation to continue.',
        loading: 'Loading...',
        noData: 'No data available to display.',
        yes: 'Yes',
        no: 'No',
        submit: 'Submit',
        back: 'Back'
    };

    _labelApiMap = {};
    _lastDataHash = '';
    _language = 'en_US';
    /** Once user checks attestation, do not let stale Omni JSON clear it. */
    _attestationTouched = false;
    _isSubmitting = false;

    connectedCallback() {
        // Boolean @api from Omni customAttributes often arrive as strings
        this.showDisclosure = this.toBool(this.showDisclosure, true);
        this.requireAttestation = this.toBool(this.requireAttestation, true);
        this.hideEmptyFields = this.toBool(this.hideEmptyFields, true);
        this.loadLanguageAndBuild();
    }

    renderedCallback() {
        const data = this.resolveOmniData();
        if (!data) {
            return;
        }
        const hash = JSON.stringify(data);
        if (hash !== this._lastDataHash) {
            this._lastDataHash = hash;
            this.buildSections(data);
            // Only hydrate attestation from Omni when user has not interacted yet,
            // or when Omni already has a confirmed true value.
            if (!this._attestationTouched) {
                this.syncAttestationFromData(data);
            } else if (this.readAttestationFromData(data)) {
                this.attestationConfirmed = true;
            }
        }
    }

    get hasTitle() {
        return !!(this.title && String(this.title).trim()) || !!this.labels.reviewSummary;
    }

    get displayTitle() {
        return (this.title && String(this.title).trim()) || this.labels.reviewSummary;
    }

    get showContent() {
        return !this.isLoading;
    }

    get hasSections() {
        return this.sections && this.sections.length > 0;
    }

    get htmlLang() {
        return this._language && this._language.startsWith('fr') ? 'fr' : 'en';
    }

    get isSubmitting() {
        return this._isSubmitting === true;
    }

    async loadLanguageAndBuild() {
        this.isLoading = true;
        try {
            const stored = readStoredLanguage();
            this._language = stored || (await getCurrentLanguage()) || 'en_US';
            const apiNames = Array.from(
                new Set([
                    ...PP_LABEL_API_NAMES,
                    'PP_Review_Summary',
                    'PP_Disclosure',
                    'PP_Disclosure_Text',
                    'PP_Attestation_Label',
                    'PP_Required',
                    'PP_Loading',
                    'EP_Yes',
                    'Yes',
                    'No'
                ])
            );
            const apiMap = await getLabels({
                labelApiNames: apiNames,
                language: this._language
            });
            this._labelApiMap = apiMap || {};
            const camel = mapApiToCamel(apiMap);
            this.labels = {
                ...this.labels,
                reviewSummary: camel.ppReviewSummary || this.labels.reviewSummary,
                disclosure: camel.ppDisclosure || this.labels.disclosure,
                disclosureText: camel.ppDisclosureText || this.labels.disclosureText,
                attestation: camel.ppAttestationLabel || this.labels.attestation,
                attestationRequired:
                    camel.ppRequired || this.labels.attestationRequired,
                loading: camel.ppLoading || this.labels.loading,
                yes: camel.epYes || camel.yes || this.labels.yes,
                no: camel.no || this.labels.no,
                submit: camel.ppSubmit || this.labels.submit,
                back: camel.ppBack || this.labels.back
            };
        } catch (e) {
            // Keep English defaults
        }

        const data = this.resolveOmniData();
        if (data) {
            this._lastDataHash = JSON.stringify(data);
            this.buildSections(data);
            this.syncAttestationFromData(data);
        }
        this.isLoading = false;
    }

    resolveOmniData() {
        // OmniStudio may expose data on several mixin properties
        return (
            this.omniJsonData ||
            this.jsonData ||
            (this.omniJsonDataStr ? this.safeParse(this.omniJsonDataStr) : null)
        );
    }

    readAttestationFromData(data) {
        if (!data) {
            return false;
        }
        const review = data.ReviewSummary || {};
        return (
            data.AttestationConfirmed === true ||
            data.AttestationConfirmed === 'true' ||
            review.AttestationConfirmed === true ||
            review.AttestationConfirmed === 'true' ||
            (review.DisclosureBlock &&
                (review.DisclosureBlock.AttestationConfirmed === true ||
                    review.DisclosureBlock.AttestationConfirmed === 'true'))
        );
    }

    syncAttestationFromData(data) {
        this.attestationConfirmed = this.readAttestationFromData(data);
    }

    buildSections(data) {
        const skip = new Set(DEFAULT_SKIP);
        this.parseList(this.skipKeys).forEach((k) => skip.add(k));

        let keys = this.parseList(this.sectionKeys);
        if (keys.length === 0) {
            keys = Object.keys(data || {}).filter((key) => {
                if (skip.has(key) || key.startsWith('c__')) {
                    return false;
                }
                const val = data[key];
                return this.isPlainObject(val) || Array.isArray(val);
            });
        }

        const built = [];
        keys.forEach((key, index) => {
            const value = data[key];
            if (value === undefined || value === null) {
                return;
            }
            const fields = this.flattenToFields(key, value);
            const filtered = this.hideEmptyFields
                ? fields.filter((f) => f.displayValue !== '—')
                : fields;
            if (filtered.length === 0) {
                return;
            }
            built.push({
                id: key,
                title: this.resolveLabel(key, this.prettify(key)),
                contentId: `omni-review-${key}-${index}`,
                isExpanded: true,
                chevronIcon: 'utility:chevrondown',
                fields: filtered
            });
        });
        this.sections = built;
    }

    flattenToFields(sectionKey, value, prefix = '') {
        const fields = [];
        if (Array.isArray(value)) {
            if (value.length === 0) {
                return fields;
            }
            // File uploads / lists: show count or titles
            const titles = value
                .map((item) => {
                    if (typeof item === 'string') {
                        return item;
                    }
                    if (this.isPlainObject(item)) {
                        return (
                            item.filename ||
                            item.fileName ||
                            item.title ||
                            item.Name ||
                            item.label ||
                            null
                        );
                    }
                    return null;
                })
                .filter(Boolean);
            fields.push({
                id: `${sectionKey}${prefix}_list`,
                label: this.resolveLabel(sectionKey, this.prettify(sectionKey)),
                displayValue: titles.length
                    ? titles.join(', ')
                    : String(value.length),
                spanClass: 'span-12'
            });
            return fields;
        }

        if (!this.isPlainObject(value)) {
            fields.push({
                id: `${sectionKey}${prefix}`,
                label: this.resolveLabel(sectionKey, this.prettify(sectionKey)),
                displayValue: this.formatValue(sectionKey, value),
                spanClass: 'span-6'
            });
            return fields;
        }

        Object.keys(value).forEach((childKey) => {
            if (childKey.startsWith('_')) {
                return;
            }
            const childVal = value[childKey];
            if (this.isPlainObject(childVal)) {
                // Prefer human display fields from nested typeaheads
                const display = this.pickNestedDisplay(childVal);
                if (display) {
                    fields.push({
                        id: `${sectionKey}_${childKey}`,
                        label: this.resolveLabel(childKey, this.prettify(childKey)),
                        displayValue: display,
                        spanClass: 'span-6'
                    });
                } else {
                    fields.push(
                        ...this.flattenToFields(childKey, childVal, `_${childKey}`)
                    );
                }
            } else if (Array.isArray(childVal)) {
                fields.push(...this.flattenToFields(childKey, childVal, `_${childKey}`));
            } else {
                fields.push({
                    id: `${sectionKey}_${childKey}`,
                    label: this.resolveLabel(childKey, this.prettify(childKey)),
                    displayValue: this.formatValue(childKey, childVal),
                    spanClass:
                        childKey.toLowerCase().includes('note') ||
                        childKey.toLowerCase().includes('comment')
                            ? 'span-12'
                            : 'span-6'
                });
            }
        });
        return fields;
    }

    pickNestedDisplay(obj) {
        for (const key of NESTED_DISPLAY_KEYS) {
            if (obj[key] !== undefined && obj[key] !== null && obj[key] !== '') {
                return String(obj[key]);
            }
        }
        return null;
    }

    resolveLabel(key, fallback) {
        const api =
            FIELD_LABEL_API[key] ||
            `${this.labelPrefix || 'PP_'}${this.toSnake(key)}`;
        if (this._labelApiMap[api]) {
            return this._labelApiMap[api];
        }
        // camel map fallback
        const camel = mapApiToCamel({ [api]: this._labelApiMap[api] });
        const camelKey = Object.keys(camel)[0];
        if (camelKey && camel[camelKey]) {
            return camel[camelKey];
        }
        return fallback;
    }

    formatValue(key, value) {
        if (value === null || value === undefined || value === '') {
            return '—';
        }
        if (typeof value === 'boolean') {
            return value ? this.labels.yes : this.labels.no;
        }
        const keyLower = String(key).toLowerCase();
        if (keyLower.includes('date')) {
            return this.formatDate(value);
        }
        return String(value);
    }

    formatDate(value) {
        try {
            let date;
            if (typeof value === 'string' && /^\d{4}-\d{2}-\d{2}/.test(value)) {
                const [y, m, d] = value.substring(0, 10).split('-').map(Number);
                date = new Date(y, m - 1, d);
            } else {
                date = new Date(value);
            }
            if (isNaN(date.getTime())) {
                return String(value);
            }
            const locale = this.htmlLang === 'fr' ? 'fr-CA' : 'en-CA';
            return date.toLocaleDateString(locale, {
                year: 'numeric',
                month: 'long',
                day: 'numeric'
            });
        } catch (e) {
            return String(value);
        }
    }

    handleAttestationChange(event) {
        this._attestationTouched = true;
        this.attestationConfirmed = event.target.checked === true;
        this.showAttestationError = false;
        this.applyAttestationToOmni();
    }

    applyAttestationToOmni() {
        if (typeof this.omniApplyCallResp === 'function') {
            this.omniApplyCallResp({
                AttestationConfirmed: this.attestationConfirmed,
                ReviewSummary: {
                    AttestationConfirmed: this.attestationConfirmed
                }
            });
        }
    }

    /**
     * OmniScript step validation hook.
     * Always push attestation into Omni JSON before returning so Save/Submit
     * see the value on the first Submit click (avoids double-click).
     */
    @api
    checkValidity() {
        if (!this.showDisclosure || !this.requireAttestation) {
            this.applyAttestationToOmni();
            return true;
        }
        // Prefer live checkbox state in case track lag vs DOM
        const input = this.template.querySelector('[data-id="attestation"]');
        if (input && typeof input.checked === 'boolean') {
            this.attestationConfirmed = input.checked === true;
            this._attestationTouched = true;
        }
        const ok = this.attestationConfirmed === true;
        this.showAttestationError = !ok;
        this.applyAttestationToOmni();
        if (!ok && input) {
            input.reportValidity();
            input.focus();
        }
        return ok;
    }

    @api
    reportValidity() {
        return this.checkValidity();
    }

    /**
     * In-LWC Back — keep Back + Submit on one row (Back first).
     */
    handleBackClick() {
        if (this._isSubmitting) {
            return;
        }
        if (typeof this.omniPrevStep === 'function') {
            this.omniPrevStep();
        }
    }

    /**
     * In-LWC Submit — Omni Next on Custom LWC steps often needs 2 clicks.
     * Push attestation, then advance the OmniScript once.
     */
    handleSubmitClick() {
        if (this._isSubmitting) {
            return;
        }
        if (!this.checkValidity()) {
            return;
        }
        this._isSubmitting = true;
        this.applyAttestationToOmni();
        // Allow Omni JSON merge to flush before advancing
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        window.setTimeout(() => {
            try {
                if (typeof this.omniNextStep === 'function') {
                    this.omniNextStep();
                } else if (typeof this.omniApplyCallResp === 'function') {
                    // Fallback: re-apply and try next via pubsub
                    this.applyAttestationToOmni();
                    if (typeof this.omniNextStep === 'function') {
                        this.omniNextStep();
                    }
                }
            } finally {
                // Re-enable if navigation did not leave the step (validation/error)
                // eslint-disable-next-line @lwc/lwc/no-async-operation
                window.setTimeout(() => {
                    this._isSubmitting = false;
                }, 1500);
            }
        }, 50);
    }

    handleSectionToggle(event) {
        this.toggleSection(event.currentTarget.dataset.sectionId);
    }

    handleSectionKeydown(event) {
        if (event.key === 'Enter' || event.key === ' ') {
            event.preventDefault();
            this.toggleSection(event.currentTarget.dataset.sectionId);
        }
    }

    toggleSection(sectionId) {
        this.sections = this.sections.map((section) => {
            if (section.id !== sectionId) {
                return section;
            }
            const isExpanded = !section.isExpanded;
            return {
                ...section,
                isExpanded,
                chevronIcon: isExpanded
                    ? 'utility:chevrondown'
                    : 'utility:chevronright'
            };
        });
    }

    parseList(value) {
        if (!value) {
            return [];
        }
        if (Array.isArray(value)) {
            return value.map((v) => String(v).trim()).filter(Boolean);
        }
        return String(value)
            .split(',')
            .map((v) => v.trim())
            .filter(Boolean);
    }

    toBool(value, defaultValue) {
        if (value === undefined || value === null || value === '') {
            return defaultValue;
        }
        if (typeof value === 'boolean') {
            return value;
        }
        const s = String(value).toLowerCase();
        if (s === 'true' || s === '1' || s === 'yes') {
            return true;
        }
        if (s === 'false' || s === '0' || s === 'no') {
            return false;
        }
        return defaultValue;
    }

    isPlainObject(value) {
        return value !== null && typeof value === 'object' && !Array.isArray(value);
    }

    prettify(key) {
        return String(key)
            .replace(/([a-z])([A-Z])/g, '$1 $2')
            .replace(/[_-]+/g, ' ')
            .replace(/\b\w/g, (c) => c.toUpperCase())
            .trim();
    }

    toSnake(key) {
        return String(key)
            .replace(/([a-z0-9])([A-Z])/g, '$1_$2')
            .replace(/[-\s]+/g, '_')
            .toUpperCase();
    }

    safeParse(value) {
        try {
            return JSON.parse(value);
        } catch (e) {
            return null;
        }
    }
}