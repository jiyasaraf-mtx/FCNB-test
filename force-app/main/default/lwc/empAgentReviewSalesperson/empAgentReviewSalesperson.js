import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getAgentReviewQueue from '@salesforce/apex/EMP_SponsoringInsurerReviewCtrl.getAgentReviewQueue';
import getCurrentLanguage from '@salesforce/apex/EMP_LanguageCtrl.getCurrentLanguage';
import getLabels from '@salesforce/apex/EMP_LanguageCtrl.getLabels';
import {
    LABEL_API_NAMES,
    mapApiToCamel,
    readStoredLanguage,
    writeStoredLanguage
} from 'c/arpLanguageUtils';

const STATUS_SUBMITTED = 'Submitted to Agent';
const STATUS_INFO_SUBMITTED = 'Information Submitted';
const STATUS_RMI = 'Agency Require More Info';
const STATUS_APPROVED = 'Submitted to FCNB';
const STATUS_DENIED = 'Agency Denied';
const PENDING_STATUSES = new Set([STATUS_SUBMITTED, STATUS_INFO_SUBMITTED, STATUS_RMI]);
const APPLICATION_REVIEW_PAGE = 'Application_Review__c';

export default class EmpAgentReviewSalesperson extends NavigationMixin(LightningElement) {
    @api showHeader = false;

    _pageMode = 'dashboard';

    @api
    get pageMode() {
        return this._pageMode;
    }
    set pageMode(value) {
        const next = value === 'queue' ? 'queue' : 'dashboard';
        if (next === this._pageMode) {
            return;
        }
        this._pageMode = next;
        this.applyPageModeDefaults();
    }

    @track applications = [];
    @track searchTerm = '';
    @track statusFilter = STATUS_SUBMITTED;
    @track showFilters = true;
    @track isLoading = false;
    @track loadError = '';
    @track labels = {
        language: 'Language',
        english: 'English',
        french: 'French',
        agentReview: 'Agent Review',
        subtitle:
            'Staff screens were not captured. This working prototype follows the documented status flow and inferred review controls.',
        demoBoundary:
            'Demo boundary: present these controls as the proposed Salesforce LPI implementation, not as a recreation of an officially captured FCNB staff screen.',
        emptyQueue: 'No Real Estate Salesperson applications are in the agent review queue.',
        submittedToAgent: 'Submitted to Agent',
        informationSubmitted: 'Information Submitted',
        infoResubmitted: 'Resubmitted by applicant',
        confirmEmployment: 'Confirm employment & representation',
        reviewNbreaCrc: 'Review NBREA & CRC',
        decision: 'Decision',
        step1Desc: 'Marie opens the salesperson application from the agent review queue.',
        step2Desc: "Verify the agent's employment and representation declaration.",
        step3Desc: 'Open the NBREA and Criminal Record Check files and complete the document review.',
        step4Desc:
            'Agency Require More Info: return to applicant. Approve: Submitted to FCNB. Reject: Agency Denied.',
        chipApplicantLicence: 'Applicant • Licence • Submitted date',
        approveControl: 'Approve control',
        documentList: 'Document list',
        agencyRequireMoreInfo: 'Agency Require More Info',
        submittedToFcnb: 'Submitted to FCNB',
        agencyDenied: 'Agency Denied',
        branchRmi: 'RMI → Applicant edits → Resubmits → Agent Review again',
        branchApprove: 'Approve → Submitted to FCNB → FCNB waits for payment',
        salespersonLicensing: 'Salesperson Licensing',
        queueTitle: 'Agent Review Queue',
        refresh: 'Refresh',
        filters: 'Filters',
        searchPlaceholder: 'Search applicant, agency or submitted date…',
        allStatuses: 'All statuses',
        applicationNumber: 'Application Number',
        applicant: 'Applicant',
        licence: 'Licence',
        agency: 'Agency',
        submitted: 'Submitted',
        status: 'Status',
        review: 'Review',
        view: 'View',
        showing: 'Showing {0} of {1} applications',
        selectApplication: 'Select an application from the queue to review.',
        queueRefreshed: 'Agent review queue refreshed.',
        loadingQueue: 'Loading agent review queue',
        somethingWentWrong: 'Something went wrong.',
        dashboard: 'Dashboard',
        clearFilter: 'Clear filter',
        pendingReview: 'Pending review',
        allApplications: 'All applications',
        statusSummary: 'Status summary',
        records: 'records',
        underReview: 'Under review',
        returnedToApplicant: 'Returned to applicant',
        sentToFcnb: 'Sent to FCNB',
        deniedByAgency: 'Denied by agency'
    };

    connectedCallback() {
        this.applyPageModeDefaults();
        this.initLanguage().finally(() => this.loadQueue());
    }

    applyPageModeDefaults() {
        if (this._pageMode === 'queue') {
            this.statusFilter = '';
        } else {
            this.statusFilter = STATUS_SUBMITTED;
        }
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
        const selectedLanguage = lang === 'fr' ? 'fr' : 'en_US';
        writeStoredLanguage(selectedLanguage);
        await this.refreshLabels(selectedLanguage);
    }

    async refreshLabels(language) {
        try {
            const apiMap = await getLabels({ apiNames: LABEL_API_NAMES, language });
            this.labels = { ...this.labels, ...mapApiToCamel(apiMap) };
            if (!this.labels.applicationNumber) {
                this.labels.applicationNumber = 'Application Number';
            }
        } catch (e) {
            // keep English defaults
        }
    }

    get statusOptions() {
        if (this.isQueueMode) {
            return [
                { label: this.labels.pendingReview, value: '' },
                { label: this.translateStatus(STATUS_SUBMITTED), value: STATUS_SUBMITTED },
                { label: this.translateStatus(STATUS_INFO_SUBMITTED), value: STATUS_INFO_SUBMITTED },
                { label: this.translateStatus(STATUS_RMI), value: STATUS_RMI }
            ];
        }
        return [
            { label: this.labels.allStatuses, value: '' },
            { label: this.translateStatus(STATUS_SUBMITTED), value: STATUS_SUBMITTED },
            { label: this.translateStatus(STATUS_INFO_SUBMITTED), value: STATUS_INFO_SUBMITTED },
            { label: this.translateStatus(STATUS_RMI), value: STATUS_RMI },
            { label: this.translateStatus(STATUS_APPROVED), value: STATUS_APPROVED },
            { label: this.translateStatus(STATUS_DENIED), value: STATUS_DENIED }
        ];
    }

    get isQueueMode() {
        return this._pageMode === 'queue';
    }

    get isDashboardMode() {
        return !this.isQueueMode;
    }

    get filteredApplications() {
        const q = (this.searchTerm || '').trim().toLowerCase();
        return this.applications.filter((a) => {
            let statusOk = true;
            if (this.isQueueMode) {
                if (!PENDING_STATUSES.has(a.status)) {
                    statusOk = false;
                } else if (this.statusFilter) {
                    statusOk = a.status === this.statusFilter;
                }
            } else {
                statusOk = !this.statusFilter || a.status === this.statusFilter;
            }
            const searchOk =
                !q ||
                [
                    a.applicationNumber,
                    a.transactionId,
                    a.applicantName,
                    a.agency,
                    a.submittedOn,
                    a.licenceType,
                    a.email
                ]
                    .filter(Boolean)
                    .some((v) => v.toLowerCase().includes(q));
            return statusOk && searchOk;
        });
    }

    get countSubmitted() {
        return this.applications.filter((a) => a.status === STATUS_SUBMITTED).length;
    }

    get countInfoSubmitted() {
        return this.applications.filter((a) => a.status === STATUS_INFO_SUBMITTED).length;
    }

    get countRmi() {
        return this.applications.filter((a) => a.status === STATUS_RMI).length;
    }

    get countApproved() {
        return this.applications.filter((a) => a.status === STATUS_APPROVED).length;
    }

    get countDenied() {
        return this.applications.filter((a) => a.status === STATUS_DENIED).length;
    }

    get submittedCardClass() {
        return this.statusFilter === STATUS_SUBMITTED
            ? 'status-card submitted active'
            : 'status-card submitted';
    }

    get infoSubmittedCardClass() {
        return this.statusFilter === STATUS_INFO_SUBMITTED
            ? 'status-card info-submitted active'
            : 'status-card info-submitted';
    }

    get rmiCardClass() {
        return this.statusFilter === STATUS_RMI ? 'status-card rmi active' : 'status-card rmi';
    }

    get approvedCardClass() {
        return this.statusFilter === STATUS_APPROVED
            ? 'status-card approved active'
            : 'status-card approved';
    }

    get deniedCardClass() {
        return this.statusFilter === STATUS_DENIED
            ? 'status-card denied active'
            : 'status-card denied';
    }

    get statusFilterText() {
        if (this.isQueueMode && !this.statusFilter) {
            const n = this.filteredApplications.length;
            return `${this.labels.pendingReview}: ${n} ${this.labels.records}`;
        }
        if (!this.statusFilter) {
            return `${this.labels.allApplications}: ${this.applications.length} ${this.labels.records}`;
        }
        const n = this.filteredApplications.length;
        return `${this.translateStatus(this.statusFilter)}: ${n} ${this.labels.records}`;
    }

    get queueTitleLabel() {
        return this.isQueueMode ? this.labels.queueTitle : this.labels.dashboard;
    }

    get tableRows() {
        return this.filteredApplications.map((a) => ({
            ...a,
            applicationNumber: a.applicationNumber || a.transactionId || '',
            statusClass: this.statusClass(a.status),
            statusLabel: this.translateStatus(a.status),
            actionLabel:
                a.status === STATUS_SUBMITTED ||
                a.status === STATUS_INFO_SUBMITTED ||
                a.status === STATUS_RMI
                    ? this.labels.review
                    : this.labels.view
        }));
    }

    get showingLabel() {
        return (this.labels.showing || '')
            .replace('{0}', String(this.filteredApplications.length))
            .replace('{1}', String(this.applications.length));
    }

    get toolbarClass() {
        return this.showFilters ? 'toolbar' : 'toolbar hidden';
    }

    get emptyStateClass() {
        return this.filteredApplications.length ? 'empty' : 'empty show';
    }

    get hasLoadError() {
        return !!this.loadError;
    }

    get isEmptyQueue() {
        return !this.isLoading && !this.loadError && this.applications.length === 0;
    }

    translateStatus(status) {
        const map = {
            [STATUS_SUBMITTED]: this.labels.submittedToAgent,
            [STATUS_INFO_SUBMITTED]: this.labels.informationSubmitted,
            [STATUS_RMI]: this.labels.agencyRequireMoreInfo,
            [STATUS_APPROVED]: this.labels.submittedToFcnb,
            [STATUS_DENIED]: this.labels.agencyDenied
        };
        return map[status] || status || '';
    }

    statusClass(status) {
        if (status === STATUS_APPROVED) return 'mini chip-green';
        if (status === STATUS_RMI) return 'mini chip-orange';
        if (status === STATUS_DENIED) return 'mini chip-red';
        if (status === STATUS_INFO_SUBMITTED) return 'mini chip-blue';
        return 'mini chip-blue';
    }

    async loadQueue() {
        this.isLoading = true;
        this.loadError = '';
        try {
            const result = await getAgentReviewQueue();
            this.applications = result?.applications || [];
        } catch (error) {
            this.loadError = this.reduceError(error);
            this.applications = [];
        } finally {
            this.isLoading = false;
        }
    }

    handleSearch(event) {
        this.searchTerm = event.target.value;
    }

    handleStatusFilter(event) {
        this.statusFilter = event.detail.value;
    }

    handleStatusTile(event) {
        if (event.type === 'keydown' && event.key !== 'Enter' && event.key !== ' ') {
            return;
        }
        if (event.type === 'keydown') {
            event.preventDefault();
        }
        const status = event.currentTarget.dataset.status;
        if (!status) {
            return;
        }
        if (this.isQueueMode && !PENDING_STATUSES.has(status)) {
            return;
        }
        this.statusFilter = status;
    }

    handleClearStatusFilter() {
        this.statusFilter = this.isQueueMode ? '' : STATUS_SUBMITTED;
    }

    handleRowAction(event) {
        const applicationId = event.currentTarget.dataset.id;
        if (!applicationId) {
            return;
        }
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: { name: APPLICATION_REVIEW_PAGE },
            state: {
                c__applicationId: applicationId
            }
        });
    }

    handleRefresh() {
        this.loadQueue().then(() => {
            if (!this.loadError) {
                // lightweight feedback via title refresh only
            }
        });
    }

    handleToggleFilters() {
        this.showFilters = !this.showFilters;
    }

    reduceError(error) {
        return (
            error?.body?.message ||
            error?.body?.pageErrors?.[0]?.message ||
            error?.message ||
            this.labels.somethingWentWrong
        );
    }
}