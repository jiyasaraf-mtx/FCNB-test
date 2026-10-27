import { LightningElement, api, track, wire } from 'lwc';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import getSuccessDetails from '@salesforce/apex/LPI_PortalSuccessCtrl.getSuccessDetails';
import getCurrentLanguage from '@salesforce/apex/EMP_LanguageCtrl.getCurrentLanguage';
import getLabels from '@salesforce/apex/EMP_LanguageCtrl.getLabels';
import {
    PP_LABEL_API_NAMES,
    mapApiToCamel,
    readStoredLanguage
} from 'c/lpLanguageUtils';

/**
 * Generic success page for non-Licensing portals
 * (Employer, Agency Review, AVR Pension).
 * Content is driven by c__Flow + c__ContextId (and optional URL fallbacks).
 * Licensing Portal success page is intentionally out of scope.
 */
export default class LpiPortalSuccess extends NavigationMixin(LightningElement) {
    /** Optional override when not using URL params. */
    @api recordId;
    /** Optional flow key: PremiumTax | AvrFiling | AgentReview | FinancialFiling | Generic */
    @api defaultFlow;

    @track isLoading = true;
    @track errorMessage = '';
    @track title = 'Submission successful';
    @track body = 'Your submission was received successfully.';
    @track idLabel = 'Reference ID';
    @track ctaLabel = 'Back to Home';
    @track nextStepsTitle = 'Next Steps';
    @track nextSteps = [];
    @track recordNumber = '';
    @track status = '';
    @track loadingLabel = 'Loading...';

    contextId;
    flowKey;
    navigatePage = 'Home';
    _loadedKey;

    @wire(CurrentPageReference)
    wiredPageRef(pageRef) {
        if (!pageRef) {
            return;
        }
        const state = pageRef.state || {};
        this.contextId =
            this.recordId ||
            state.c__ContextId ||
            state.ContextId ||
            state.c__filingId ||
            state.c__taxReturnId ||
            null;
        this.flowKey =
            this.defaultFlow ||
            state.c__Flow ||
            state.c__flow ||
            this.inferFlowFromPath() ||
            null;
        if (state.c__FilingNumber) {
            this.recordNumber = state.c__FilingNumber;
        }
        if (state.c__Status) {
            this.status = state.c__Status;
        }
        this.loadOnce();
    }

    connectedCallback() {
        if (this.recordId) {
            this.contextId = this.recordId;
        }
        if (this.defaultFlow && !this.flowKey) {
            this.flowKey = this.defaultFlow;
        }
        if (!this.flowKey) {
            this.flowKey = this.inferFlowFromPath();
        }
        this.loadOnce();
    }

    inferFlowFromPath() {
        const path =
            typeof window !== 'undefined' && window.location
                ? window.location.pathname || ''
                : '';
        if (path.indexOf('/pensionportal') !== -1) {
            return 'AvrFiling';
        }
        if (path.indexOf('/agentreviewportal') !== -1) {
            return 'AgentReview';
        }
        if (path.indexOf('/employerportal') !== -1) {
            return 'PremiumTax';
        }
        return 'Generic';
    }

    loadOnce() {
        const key = `${this.flowKey || ''}|${this.contextId || ''}|${this.recordNumber || ''}`;
        if (this._loadedKey === key && !this.isLoading) {
            return;
        }
        this._loadedKey = key;
        this.load();
    }

    get displayRecordNumber() {
        return this.recordNumber || '—';
    }

    get displayStatus() {
        return this.status || '—';
    }

    get nextStepItems() {
        return (this.nextSteps || []).map((text, index) => ({
            key: `step-${index}`,
            text
        }));
    }

    async load() {
        this.isLoading = true;
        this.errorMessage = '';
        try {
            const dto = await getSuccessDetails({
                flowKey: this.flowKey,
                contextId: this.contextId || null
            });
            if (dto) {
                this.flowKey = dto.flowKey || this.flowKey;
                this.title = dto.title || this.title;
                this.body = dto.body || this.body;
                this.idLabel = dto.idLabel || this.idLabel;
                this.ctaLabel = dto.ctaLabel || this.ctaLabel;
                this.navigatePage = dto.navigatePage || 'Home';
                this.nextSteps = dto.nextSteps || [];
                this.recordNumber = dto.recordNumber || this.recordNumber || '';
                this.status = dto.status || this.status || 'Submitted';
            }
            if (this.flowKey === 'AvrFiling') {
                await this.applyPensionLabels();
            }
        } catch (e) {
            if (!this.recordNumber) {
                this.errorMessage =
                    e?.body?.message || e.message || 'Unable to load success details.';
            }
            if (!this.nextSteps.length) {
                this.nextSteps = [
                    'Please keep this reference for your records.',
                    'You will be notified if more information is required.',
                    'You can return to the portal home anytime.'
                ];
            }
        } finally {
            this.isLoading = false;
        }
    }

    async applyPensionLabels() {
        try {
            const stored = readStoredLanguage();
            const language = stored || (await getCurrentLanguage());
            const apiMap = await getLabels({
                apiNames: PP_LABEL_API_NAMES,
                language
            });
            const camel = mapApiToCamel(apiMap);
            this.title = camel.filingSubmittedTitle || this.title;
            this.body = camel.filingSubmittedBody || this.body;
            this.idLabel = camel.filingId || this.idLabel;
            this.ctaLabel = camel.backToPensionFilings || this.ctaLabel;
            this.nextStepsTitle = camel.nextSteps || this.nextStepsTitle;
            const steps = [];
            if (camel.nextSteps1) steps.push(camel.nextSteps1);
            if (camel.nextSteps2) steps.push(camel.nextSteps2);
            if (camel.nextSteps3) steps.push(camel.nextSteps3);
            if (steps.length) {
                this.nextSteps = steps;
            }
        } catch (e) {
            // keep Apex defaults
        }
    }

    handleBack() {
        window.location.href = '/employerportal/s/premium-tax-return';
        // this[NavigationMixin.Navigate]({
        //     type: 'comm__namedPage',
        //     attributes: { name: this.navigatePage || 'Premium_Tax_Return__c' }
        // });
    }
}