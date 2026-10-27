import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getQueue from '@salesforce/apex/EMP_SponsoringInsurerReviewCtrl.getQueue';
import getCurrentLanguage from '@salesforce/apex/EMP_LanguageCtrl.getCurrentLanguage';
import getLabels from '@salesforce/apex/EMP_LanguageCtrl.getLabels';
import {
    LABEL_API_NAMES,
    mapApiToCamel,
    readStoredLanguage,
    writeStoredLanguage
} from 'c/empLanguageUtils';

const STATUS_SUBMITTED = 'Submitted to Insurer';
const STATUS_RMI = 'More Info Require';
const STATUS_APPROVED = 'Approved by Insurer';
const STATUS_REJECTED = 'Denied by Insurer';
const STATUS_INFO_SUBMITTED = 'Information Submitted';

const PENDING_REVIEW_STATUSES = new Set([STATUS_SUBMITTED, STATUS_RMI, STATUS_INFO_SUBMITTED]);
const APPLICATION_REVIEW_PAGE = 'Application_Review__c';
const PAGE_SIZE = 8;

export default class EmpSponsoringInsurerReview extends NavigationMixin(LightningElement) {
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
    @track activeTab = 'All';
    @track searchTerm = '';
    @track agencyFilter = '';
    @track alertMessage = '';
    @track alertType = '';
    @track showFilters = true;
    @track isLoading = false;
    @track insurerName = 'Sponsoring Insurer';
    @track currentPage = 1;
    @track labels = {
        sirTitle: 'Sponsoring Insurer Review',
        sirSubtitle: 'If RMI is used, resubmit goes back to the insurer before FCNB.',
        sirSubmittedToInsurer: 'Submitted to Insurer',
        sirInfoSubmitted: 'Information Submitted',
        sirOpenQueue: 'Open sponsorship queue',
        sirStatusPrefix: 'Status:',
        sirConfirmClass: 'Confirm class of insurance matches insurer licence',
        sirLifeCheck: 'Life / A&S check',
        sirMoreInfoRequire: 'More Info Require',
        sirReturnApplicant: 'Return to applicant',
        sirApprovedByInsurer: 'Approved by Insurer',
        sirApproveOnline: 'Approve sponsorship online',
        sirSubmittedFcnb: 'Submitted to FCNB',
        sirDeniedByInsurer: 'Denied by Insurer',
        sirRejectSponsorship: 'Reject sponsorship',
        sirRemainsOnFile: 'Remains on file. Not deleted.',
        sirFlowNote:
            'RMI / More Information path: Applicant edits and resubmits → application returns to the insurer for sponsorship review → then proceeds to FCNB.',
        sirQueueTitle: 'Insurer Review Queue',
        sirRefresh: 'Refresh',
        sirFilters: 'Filters',
        sirAll: 'All',
        sirRmi: 'RMI',
        sirApproved: 'Approved',
        sirSearchPlaceholder: 'Search applicant, agency ...',
        sirApplicationNumber: 'Application Number',
        sirApplicant: 'Applicant',
        licenceType: 'License Type',
        sirAgency: 'Agency',
        sirSubmitted: 'Submitted',
        status: 'Status',
        sirAction: 'Action',
        sirEmpty: 'No applications match the selected filter.',
        sirAllAgencies: 'All agencies',
        dashboard: 'Dashboard'
    };

    connectedCallback() {
        this.applyPageModeDefaults();
        this.loadTranslatedLabels().finally(() => this.loadQueue());
    }

    applyPageModeDefaults() {
        this.currentPage = 1;
        this.searchTerm = '';
        this.agencyFilter = '';
        this.activeTab = this._pageMode === 'queue' ? STATUS_SUBMITTED : 'All';
    }

    async loadTranslatedLabels() {
        const stored = readStoredLanguage();
        let lang = stored;
        if (!lang) {
            try {
                lang = await getCurrentLanguage();
            } catch (e) {
                lang = 'en_US';
            }
        }
        lang = lang === 'fr' ? 'fr' : 'en_US';
        writeStoredLanguage(lang);
        try {
            const apiMap = await getLabels({ apiNames: LABEL_API_NAMES, language: lang });
            this.labels = { ...this.labels, ...mapApiToCamel(apiMap) };
            if (!this.labels.sirApplicationNumber) {
                this.labels.sirApplicationNumber = 'Application Number';
            }
            if (this.labels.licenceType === 'Licence Type') {
                this.labels.licenceType = 'License Type';
            }
        } catch (e) {
            // keep defaults
        }
    }

    get isQueueMode() {
        return this._pageMode === 'queue';
    }

    get isDashboardMode() {
        return !this.isQueueMode;
    }

    get showPageIntro() {
        return this.showHeader && this.isDashboardMode;
    }

    get modeApplications() {
        if (this.isQueueMode) {
            return this.applications.filter(
                (a) =>
                    a.canDecide === true ||
                    a.status === STATUS_SUBMITTED ||
                    PENDING_REVIEW_STATUSES.has(a.status)
            );
        }
        return this.applications;
    }

    get tiles() {
        const source = this.modeApplications;
        const tileList = [
            // {
            //     key: 'All',
            //     label: this.labels.sirAll,
            //     count: source.length,
            //     icon: '≡',
            //     caption: 'All applications',
            //     className: this.activeTab === 'All' ? 'status-card all active' : 'status-card all'
            // },
            {
                key: STATUS_SUBMITTED,
                label: this.labels.sirSubmittedToInsurer,
                count: this.countFor(STATUS_SUBMITTED),
                icon: '1',
                caption: 'Under review',
                className: this.activeTab === STATUS_SUBMITTED ? 'status-card submitted active' : 'status-card submitted'
            },
            {
                key: STATUS_INFO_SUBMITTED,
                label: this.labels.sirInfoSubmitted,
                count: this.countFor(STATUS_INFO_SUBMITTED),
                icon: 'ℹ',
                caption: 'Resubmitted info',
                className: this.activeTab === STATUS_INFO_SUBMITTED ? 'status-card info active' : 'status-card info'
            },
            {
                key: STATUS_RMI,
                label: this.labels.sirMoreInfoRequire,
                count: this.countFor(STATUS_RMI),
                icon: '↩',
                caption: 'Returned to applicant',
                className: this.activeTab === STATUS_RMI ? 'status-card rmi active' : 'status-card rmi'
            }
        ];

        if (this.isDashboardMode) {
            tileList.push(
                {
                    key: STATUS_APPROVED,
                    label: this.labels.sirApprovedByInsurer,
                    count: this.countFor(STATUS_APPROVED),
                    icon: '✓',
                    caption: 'Sent to FCNB',
                    className: this.activeTab === STATUS_APPROVED ? 'status-card approved active' : 'status-card approved'
                },
                {
                    key: STATUS_REJECTED,
                    label: this.labels.sirDeniedByInsurer,
                    count: this.countFor(STATUS_REJECTED),
                    icon: '×',
                    caption: 'Denied by insurer',
                    className: this.activeTab === STATUS_REJECTED ? 'status-card denied active' : 'status-card denied'
                }
            );
        }

        return tileList;
    }

    get agencyOptions() {
        const agencies = [...new Set(this.modeApplications.map((a) => a.agency).filter(Boolean))].sort();
        return [{ label: this.labels.sirAllAgencies, value: '' }, ...agencies.map((a) => ({ label: a, value: a }))];
    }

    get filteredApplications() {
        const q = (this.searchTerm || '').trim().toLowerCase();
        return this.modeApplications.filter((a) => {
            const tabOk = this.activeTab === 'All' || a.status === this.activeTab;
            const searchOk =
                !q ||
                [a.applicantName, a.agency, a.licenceType, a.applicationNumber, a.email]
                    .filter(Boolean)
                    .some((v) => v.toLowerCase().includes(q));
            const agencyOk = !this.agencyFilter || a.agency === this.agencyFilter;
            return tabOk && searchOk && agencyOk;
        });
    }

    get pagedApplications() {
        const start = (this.currentPage - 1) * PAGE_SIZE;
        return this.filteredApplications.slice(start, start + PAGE_SIZE).map((a) => ({
            ...a,
            statusClass: this.statusClass(a.status),
            statusLabel: this.translateStatus(a.status),
            actionLabel: a.canDecide ? 'Review' : 'View'
        }));
    }

    get totalPages() {
        return Math.max(1, Math.ceil(this.filteredApplications.length / PAGE_SIZE));
    }

    get pageNumbers() {
        const pages = [];
        for (let i = 1; i <= this.totalPages; i++) {
            pages.push({
                number: i,
                active: i === this.currentPage,
                className: i === this.currentPage ? 'page active' : 'page'
            });
        }
        return pages;
    }

    get showingLabel() {
        return `Showing ${this.filteredApplications.length} of ${this.modeApplications.length} entries`;
    }

    get showAlert() {
        return !!this.alertMessage;
    }

    get alertClass() {
        return `alert show ${this.alertType || 'info'}`;
    }

    get filterToolsClass() {
        return this.showFilters ? 'queue-tools' : 'queue-tools hidden';
    }

    get emptyStateClass() {
        return this.filteredApplications.length ? 'empty' : 'empty show';
    }

    countFor(status) {
        return this.modeApplications.filter((a) => a.status === status).length;
    }

    statusClass(status) {
        if (status === STATUS_APPROVED) return 'mini-chip chip-green';
        if (status === STATUS_RMI) return 'mini-chip chip-orange';
        if (status === STATUS_REJECTED) return 'mini-chip chip-red';
        if (status === STATUS_INFO_SUBMITTED) return 'mini-chip chip-blue';
        return 'mini-chip chip-blue';
    }

    translateStatus(status) {
        const map = {
            [STATUS_SUBMITTED]: this.labels.sirSubmittedToInsurer,
            [STATUS_INFO_SUBMITTED]: this.labels.sirInfoSubmitted,
            [STATUS_RMI]: this.labels.sirMoreInfoRequire,
            [STATUS_APPROVED]: this.labels.sirApprovedByInsurer,
            [STATUS_REJECTED]: this.labels.sirDeniedByInsurer
        };
        return map[status] || status || '';
    }

    async loadQueue() {
        this.isLoading = true;
        try {
            const result = await getQueue();
            this.applications = result?.applications || [];
            this.insurerName = result?.insurerName || 'Sponsoring Insurer';
            if (this.currentPage > this.totalPages) {
                this.currentPage = 1;
            }
        } catch (error) {
            this.showAlertBanner('error', this.reduceError(error));
        } finally {
            this.isLoading = false;
        }
    }

    handleTileClick(event) {
        if (event.type === 'keydown' && event.key !== 'Enter' && event.key !== ' ') {
            return;
        }
        if (event.type === 'keydown') {
            event.preventDefault();
        }
        const selectedTab = event.currentTarget.dataset.tab;
        if (selectedTab) {
            this.activeTab = selectedTab;
            this.currentPage = 1;
        }
    }

    handleSearch(event) {
        this.searchTerm = event.target.value;
        this.currentPage = 1;
    }

    handleAgencyFilter(event) {
        this.agencyFilter = event.detail.value;
        this.currentPage = 1;
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
            this.showAlertBanner('info', 'Queue refreshed.');
        });
    }

    handleToggleFilters() {
        this.showFilters = !this.showFilters;
    }

    handlePrevPage() {
        if (this.currentPage > 1) {
            this.currentPage -= 1;
        }
    }

    handleNextPage() {
        if (this.currentPage < this.totalPages) {
            this.currentPage += 1;
        }
    }

    handlePageClick(event) {
        this.currentPage = Number(event.currentTarget.dataset.page);
    }

    showAlertBanner(type, message) {
        this.alertType = type;
        this.alertMessage = message;
    }

    reduceError(error) {
        return (
            error?.body?.message ||
            error?.body?.pageErrors?.[0]?.message ||
            error?.message ||
            'Something went wrong.'
        );
    }
}