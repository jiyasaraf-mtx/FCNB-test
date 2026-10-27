import { LightningElement, track, wire } from 'lwc';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getFilings from '@salesforce/apex/AVR_FilingCtrl.getFilings';
import submitRmiResponse from '@salesforce/apex/AVR_FilingCtrl.submitRmiResponse';
import getCurrentLanguage from '@salesforce/apex/EMP_LanguageCtrl.getCurrentLanguage';
import getLabels from '@salesforce/apex/EMP_LanguageCtrl.getLabels';
import {
    PP_LABEL_API_NAMES,
    mapApiToCamel,
    readStoredLanguage,
    resolveOmniLanguageCode
} from 'c/lpLanguageUtils';

const PAGE_KEY = 'avr_pension_page';
const EVENT_NAME = 'avrpensionnavigate';
/** Community page API name for /add-edit-avr-filing */
const AVR_FILING_PAGE = 'Add_Edit_AVR_Filing__c';

export default class AvrPensionFilings extends NavigationMixin(LightningElement) {
    @track labels = {
        pensionFilings: 'Pension Filings',
        portalHome: 'Portal Home',
        filings: 'Filings',
        avr: 'AVR',
        avrFiling: 'AVR Filing',
        reportingYear: 'Reporting Year',
        currentStatus: 'Current Status',
        filingDueDate: 'Filing Due Date',
        searchPlaceholder: 'Search filings',
        addAvr: 'Add AVR',
        plan: 'Plan',
        planNumber: 'Plan number',
        filingId: 'Filing ID',
        filingType: 'Filing type',
        status: 'Status',
        actions: 'Actions',
        edit: 'Edit',
        view: 'View',
        noFilings: 'No AVR filings found.',
        rmiTitle: 'RMI / Additional Schedule',
        rmiSubtitle:
            'Select an AVR filing to upload the requested RMI / Additional Schedule and resubmit.',
        rmiStatus: 'RMI Status',
        action: 'Action',
        emailNotifications: 'Email Notifications',
        emailSubtitle: 'Email templates associated with the AVR filing journey.',
        loading: 'Loading...',
        submitted: 'Submitted',
        comments: 'Comments',
        save: 'Save',
        cancel: 'Cancel',
        uploadDocuments: 'Upload documents',
        uploadOptional: 'Optional — attach additional documents if needed.',
        rmiModalTitle: 'Submit RMI / Additional Schedule',
        rmiSaveSuccess: 'RMI response submitted successfully.',
        rmiSaveError: 'Unable to submit RMI response.'
    };

    @track page = 'list';
    @track filings = [];
    @track filteredFilings = [];
    @track searchTerm = '';
    @track isLoading = true;
    @track errorMessage = '';
    @track metrics = {
        avrFilingCount: 0,
        reportingYearMetric: '—',
        currentStatusMetric: '—',
        filingDueDateMetric: '—'
    };
    @track accountName = '';
    @track showSuccess = false;
    @track successContextId = null;
    @track viewFilingId = null;
    @track showRmiModal = false;
    @track rmiSelectedFilingId = null;
    @track rmiSelectedFilingName = '';
    @track rmiComments = '';
    @track rmiUploadedFiles = [];
    @track rmiSaving = false;

    @wire(CurrentPageReference)
    wiredPageRef(pageRef) {
        if (!pageRef) {
            return;
        }
        const state = pageRef.state || {};
        const successFlag = String(state.c__avrSuccess || state.c__mode || '')
            .trim()
            .toLowerCase();
        this.showSuccess =
            successFlag === '1' ||
            successFlag === 'true' ||
            successFlag === 'success';
        this.successContextId =
            state.c__ContextId || state.ContextId || null;
    }

    connectedCallback() {
        this.page = this.readPage() || 'list';
        if (this.page === 'form' || this.page === 'view') {
            this.page = 'list';
        }
        this._onNav = (event) => {
            const next = event?.detail?.page;
            if (!next || next === 'form') {
                return;
            }
            this.page = next;
            this.viewFilingId = null;
            if (next === 'list') {
                this.refresh();
            }
        };
        window.addEventListener(EVENT_NAME, this._onNav);
        this.init();
    }

    disconnectedCallback() {
        window.removeEventListener(EVENT_NAME, this._onNav);
    }

    async init() {
        await this.loadLabels();
        await this.refresh();
    }

    get isList() {
        return !this.showSuccess && this.page === 'list';
    }

    get isView() {
        return !this.showSuccess && this.page === 'view' && !!this.viewFilingId;
    }

    get showPortalContent() {
        return !this.showSuccess;
    }
    get isRmi() {
        return !this.showSuccess && this.page === 'rmi';
    }
    get isEmails() {
        return !this.showSuccess && this.page === 'emails';
    }
    get breadcrumbPlan() {
        return this.accountName || this.labels.pensionFilings;
    }
    get hasFilings() {
        return this.filteredFilings && this.filteredFilings.length > 0;
    }
    get rmiFilings() {
        return (this.filings || []).filter(
            (f) => f.status === 'More Information Required'
        );
    }
    get hasRmiFilings() {
        return this.rmiFilings.length > 0;
    }
    get hasRmiUploadedFiles() {
        return this.rmiUploadedFiles && this.rmiUploadedFiles.length > 0;
    }
    get rmiModalFilingLabel() {
        return this.rmiSelectedFilingName
            ? `${this.labels.filingId}: ${this.rmiSelectedFilingName}`
            : '';
    }

    readPage() {
        try {
            return window.sessionStorage.getItem(PAGE_KEY);
        } catch (e) {
            return null;
        }
    }

    navigateToAvrOmni(contextId) {
        const state = {
            c__language: resolveOmniLanguageCode()
        };
        if (contextId) {
            state.c__ContextId = contextId;
        }
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: { name: AVR_FILING_PAGE },
            state
        });
    }

    async loadLabels() {
        try {
            const stored = readStoredLanguage();
            const language = stored || (await getCurrentLanguage());
            const apiMap = await getLabels({
                apiNames: PP_LABEL_API_NAMES,
                language
            });
            this.labels = { ...this.labels, ...mapApiToCamel(apiMap) };
        } catch (e) {
            // keep defaults
        }
    }

    async refresh() {
        this.isLoading = true;
        this.errorMessage = '';
        try {
            const result = await getFilings();
            this.accountName = result.accountName || '';
            this.metrics = {
                avrFilingCount: result.avrFilingCount || 0,
                reportingYearMetric: result.reportingYearMetric || '—',
                currentStatusMetric: result.currentStatusMetric || '—',
                filingDueDateMetric: result.filingDueDateMetric || '—'
            };
            this.filings = (result.filings || []).map((f) => ({
                ...f,
                statusClass: this.statusBadgeClass(f.status),
                showEdit: this.isDraftStatus(f.status),
                showView: !this.isDraftStatus(f.status)
            }));
            this.applyFilter();
        } catch (e) {
            this.errorMessage = e?.body?.message || e.message || 'Unable to load filings.';
            this.filings = [];
            this.filteredFilings = [];
        } finally {
            this.isLoading = false;
        }
    }

    statusBadgeClass(status) {
        if (
            status === 'Accepted' ||
            status === 'Submitted' ||
            status === 'RMI Submitted'
        ) {
            return 'badge green';
        }
        if (status === 'More Information Required' || status === 'Draft') {
            return 'badge amber';
        }
        return 'badge';
    }

    isDraftStatus(status) {
        return String(status || '').trim().toLowerCase() === 'draft';
    }

    applyFilter() {
        const term = (this.searchTerm || '').trim().toLowerCase();
        if (!term) {
            this.filteredFilings = [...this.filings];
            return;
        }
        this.filteredFilings = this.filings.filter((f) => {
            const hay = [
                f.planName,
                f.planRegistrationNumber,
                f.name,
                f.filingType,
                f.reportingYear,
                f.status
            ]
                .filter(Boolean)
                .join(' ')
                .toLowerCase();
            return hay.includes(term);
        });
    }

    handleSearch(event) {
        this.searchTerm = event.target.value;
        this.applyFilter();
    }

    handleAddAvr() {
        this.navigateToAvrOmni(null);
    }

    handleEdit(event) {
        const id = event.currentTarget.dataset.id;
        this.navigateToAvrOmni(id);
    }

    handleView(event) {
        const id = event.currentTarget.dataset.id;
        if (!id) {
            return;
        }
        this.viewFilingId = id;
        this.page = 'view';
        try {
            window.sessionStorage.setItem(PAGE_KEY, 'view');
        } catch (e) {
            // ignore
        }
    }

    handleViewBack() {
        this.viewFilingId = null;
        this.page = 'list';
        try {
            window.sessionStorage.setItem(PAGE_KEY, 'list');
        } catch (e) {
            // ignore
        }
        this.refresh();
    }

    handleRmiAction(event) {
        const id = event.currentTarget.dataset.id;
        const name = event.currentTarget.dataset.name || '';
        if (!id) {
            return;
        }
        this.rmiSelectedFilingId = id;
        this.rmiSelectedFilingName = name;
        this.rmiComments = '';
        this.rmiUploadedFiles = [];
        this.rmiSaving = false;
        this.showRmiModal = true;
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        window.setTimeout(() => {
            const dialog = this.template.querySelector('.rmi-modal-container');
            if (dialog) {
                dialog.focus();
            }
        }, 0);
    }

    handleRmiCommentsChange(event) {
        this.rmiComments = event.target.value;
    }

    handleRmiUploadFinished(event) {
        const files = event.detail?.files || [];
        this.rmiUploadedFiles = [
            ...this.rmiUploadedFiles,
            ...files.map((f) => ({
                documentId: f.documentId,
                name: f.name
            }))
        ];
    }

    handleRmiCancel() {
        this.showRmiModal = false;
        this.rmiSelectedFilingId = null;
        this.rmiSelectedFilingName = '';
        this.rmiComments = '';
        this.rmiUploadedFiles = [];
        this.rmiSaving = false;
    }

    stopPropagation(event) {
        event.stopPropagation();
    }

    handleRmiModalKeydown(event) {
        if (event.key === 'Escape') {
            event.preventDefault();
            this.handleRmiCancel();
        }
    }

    async handleRmiSave() {
        if (!this.rmiSelectedFilingId || this.rmiSaving) {
            return;
        }
        this.rmiSaving = true;
        try {
            await submitRmiResponse({
                filingId: this.rmiSelectedFilingId,
                comments: this.rmiComments || ''
            });
            this.toast(
                this.labels.rmiTitle,
                this.labels.rmiSaveSuccess,
                'success'
            );
            this.handleRmiCancel();
            await this.refresh();
        } catch (e) {
            this.toast(
                this.labels.rmiTitle,
                e?.body?.message || e.message || this.labels.rmiSaveError,
                'error'
            );
        } finally {
            this.rmiSaving = false;
        }
    }

    toast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }
}
