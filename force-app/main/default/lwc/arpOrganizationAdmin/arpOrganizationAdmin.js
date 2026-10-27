import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getDashboard from '@salesforce/apex/ARP_OrganizationAdminCtrl.getDashboard';
import getOrganizationUsers from '@salesforce/apex/ARP_OrganizationAdminCtrl.getOrganizationUsers';
import getSponsoredAgents from '@salesforce/apex/ARP_OrganizationAdminCtrl.getSponsoredAgents';
import getBranches from '@salesforce/apex/ARP_OrganizationAdminCtrl.getBranches';
import getDelegationActivity from '@salesforce/apex/ARP_OrganizationAdminCtrl.getDelegationActivity';
import updateUserStatus from '@salesforce/apex/ARP_OrganizationAdminCtrl.updateUserStatus';
import updateOrganizationUser from '@salesforce/apex/ARP_OrganizationAdminCtrl.updateOrganizationUser';
import delegateAccess from '@salesforce/apex/ARP_OrganizationAdminCtrl.delegateAccess';
import revokeAccess from '@salesforce/apex/ARP_OrganizationAdminCtrl.revokeAccess';
import createBranch from '@salesforce/apex/ARP_OrganizationAdminCtrl.createBranch';
import deleteBranch from '@salesforce/apex/ARP_OrganizationAdminCtrl.deleteBranch';
import createSponsoredAgent from '@salesforce/apex/ARP_OrganizationAdminCtrl.createSponsoredAgent';
import getCurrentLanguage from '@salesforce/apex/EMP_LanguageCtrl.getCurrentLanguage';
import getLabels from '@salesforce/apex/EMP_LanguageCtrl.getLabels';
import {
    LABEL_API_NAMES,
    mapApiToCamel,
    readStoredLanguage,
    writeStoredLanguage
} from 'c/arpLanguageUtils';

export default class ArpOrganizationAdmin extends LightningElement {
    _pageMode = 'orgDashboard';

    @api
    get pageMode() {
        return this._pageMode;
    }
    set pageMode(value) {
        this._pageMode = value || 'orgDashboard';
        this.loadForPage();
    }

    @track companyName = 'Organization';
    @track portalUsers = 0;
    @track activeUsers = 0;
    @track branchCount = 0;
    @track sponsoredCount = 0;
    @track recentDelegations = [];
    @track users = [];
    @track filteredUsers = [];
    @track activities = [];
    @track branches = [];
    @track sponsoredAgents = [];
    @track searchTerm = '';
    @track statusFilter = 'all';
    @track isLoading = false;
    @track showDelegateModal = false;
    @track showSuccessModal = false;
    @track showBranchModal = false;
    @track showSponsorModal = false;
    @track showPermissionsModal = false;
    @track showRemoveBranchModal = false;
    @track showViewModal = false;
    @track fromUser = null;
    @track toUserId = '';
    @track reason = '';
    @track successFrom = '';
    @track successTo = '';
    @track viewUser = null;
    @track permissionsUser = null;
    @track draftPermissions = [];
    @track branchToRemove = null;
    @track branchName = '';
    @track branchAddress = '';
    @track branchDescription = '';
    @track sponsorFirstName = '';
    @track sponsorLastName = '';
    @track sponsorEmail = '';
    @track sponsorBranchId = '';
    @track formError = '';
    @track isSaving = false;
    @track labels = {
        loading: 'Loading',
        loadingQueue: 'Loading agent review queue',
        orgDashboardTitle: 'Organization Dashboard',
        delegateAccess: 'Delegate Access',
        delegationActivity: 'Delegation Activity',
        organizationAccess: 'Organization Access',
        branchesLocations: 'Branches & Locations',
        sponsoredAgents: 'Sponsored Agents',
        orgDashboardSubtitle:
            'Manage external portal access, delegated users, locations and reviewer permissions.',
        delegateSubtitle: 'Transfer reviewer access between active salespersons within your company.',
        activitySubtitle: 'Audit trail of access transfers completed by company administrators.',
        organizationSubtitle:
            'A single view of administrator, salesperson, delegated and sponsored access.',
        branchesSubtitle: 'Manage where organization users and sponsored agents operate.',
        sponsoredSubtitle: 'View agents sponsored by the organization and their portal relationship.',
        accessOverview: 'Access overview',
        clickCardExplore: 'Click a card to explore',
        adminAccessTitle: 'Administrator access',
        adminAccessDesc: 'Manage organization users, delegation, branches and permissions.',
        delegatedAccessTitle: 'Delegated access',
        delegatedAccessDesc: 'Transfer reviewer access between active salespersons.',
        sponsoredTileDesc: 'Review sponsored agents and the organization relationship.',
        recentDelegation: 'Recent delegation',
        quickActions: 'Quick actions',
        delegateAccessHint: 'Transfer a review role to another active salesperson.',
        reviewOrgAccess: 'Review organization access',
        reviewOrgAccessHint: 'See who has own vs delegated access.',
        searchSalespersonPlaceholder: 'Search salesperson, email or license…',
        salesperson: 'Salesperson',
        company: 'Company',
        accessType: 'Access type',
        lastActivity: 'Last activity',
        usingDelegatedAccess: 'Using delegated access',
        delegatedOut: 'Delegated out',
        ownAccess: 'Own access',
        revokeAccess: 'Revoke Access',
        unavailable: 'Unavailable',
        showingSalespeople: 'Showing {0} of {1} salespeople',
        delegateInactiveHint: 'Delegating access automatically makes the original holder inactive.',
        dateTime: 'Date & time',
        delegatedFrom: 'Delegated from',
        delegatedTo: 'Delegated to',
        reason: 'Reason',
        usersAccessRelationships: 'Users & access relationships',
        usersAdminSummary: '{0} users · {1} administrator',
        user: 'User',
        role: 'Role',
        accessSource: 'Access source',
        branch: 'Branch',
        taskPermissions: 'Task permissions',
        usingAccessOf: "Using {0}'s access",
        delegatedToPerson: 'Delegated to {0}',
        addBranch: '+ Add branch',
        addSponsoredAgent: '+ Add sponsored agent',
        removeBranch: 'Remove',
        confirmRemoveBranch: 'Remove this branch? Assigned users will be unassigned.',
        removeBranchTitle: 'Remove branch',
        removeBranchConfirm: 'Remove',
        branchRemoved: 'Branch removed.',
        usersCount: '{0} users',
        agent: 'Agent',
        sponsoredBy: 'Sponsored by',
        permissions: 'Permissions',
        managePermissions: 'Manage Permissions',
        managePermissionsTitle: 'Manage permissions',
        managePermissionsHelp: 'Select the permissions this user should have.',
        noPermissionsSelected: 'Select at least one permission, or clear all to remove access.',
        sponsoredAgentLabel: 'Sponsored agent',
        organizationUserLabel: 'Organization user',
        delegateReviewerAccess: 'Delegate reviewer access',
        currentAccessHolder: '1 · Current access holder',
        delegateAccessTo: '2 · Delegate access to',
        reasonOptional: 'Reason (optional)',
        important: 'Important',
        delegateImportantText:
            'After confirmation, the original access holder will be marked Inactive. The receiving salesperson will remain Active and will show delegated access.',
        confirmDelegation: 'Confirm delegation',
        accessDelegatedSuccess: 'Access delegated successfully',
        accessRelationshipUpdated: 'The access relationship has been updated across the portal.',
        originalUser: 'Original user',
        receivingUser: 'Receiving user',
        statusInactive: 'Status: Inactive',
        statusActiveDelegated: 'Status: Active · Delegated access',
        done: 'Done',
        delegationDetails: 'Delegation details',
        delegatedToColon: 'Delegated to:',
        currentStatusColon: 'Current status:',
        branchName: 'Branch name',
        address: 'Address',
        branchNamePlaceholder: 'e.g. Northside Branch',
        streetAddress: 'Street address',
        optionalDescription: 'Optional description',
        branchNameRequired: 'Branch name is required.',
        selectBranch: 'Please select a branch.',
        namesRequired: 'First name and last name are required.',
        statusUpdated: 'Status updated.',
        accessRevoked: 'Access revoked. User is Active with Own access.',
        selectSalespersonReceive: 'Select a salesperson to receive access.',
        orgUserUpdated: 'Organization user updated.',
        permissionsUpdated: 'Permissions updated.',
        branchCreated: 'Branch created.',
        sponsoredAgentAdded: 'Sponsored agent added.',
        active: 'Active',
        inactive: 'Inactive',
        suspended: 'Suspended',
        roleCompanyAdministrator: 'Company Administrator',
        roleSalesperson: 'Salesperson',
        roleSponsoredAgent: 'Sponsored Agent',
        roleReviewer: 'Reviewer',
        roleReadOnly: 'Read Only',
        permEditPersonalProfile: 'Edit Personal Profile',
        permManageCredentialsLicensing: 'Manage Credentials & Licensing',
        permViewSponsorshipStatus: 'View Sponsorship Status',
        permInitiateNewApplications: 'Initiate New Applications',
        permUploadTransactionDocuments: 'Upload Transaction Documents',
        permTrackSubmissionProgress: 'Track Submission Progress',
        permManageClientPortfolios: 'Manage Client Portfolios',
        permRequestSupervisorSignOff: 'Request Supervisor Sign-off',
        success: 'Success',
        error: 'Error',
        saved: 'Saved',
        saving: 'Saving…',
        noLicense: 'No license',
        from: 'From',
        to: 'To',
        companyAdministration: 'Company Administration',
        organization: 'Organization',
        allStatuses: 'All statuses',
        licence: 'Licence',
        view: 'View',
        cancel: 'Cancel',
        save: 'Save',
        close: 'Close',
        search: 'Search',
        status: 'Status',
        email: 'Email',
        firstName: 'First Name',
        lastName: 'Last Name',
        description: 'Description',
        documents: 'Documents',
        action: 'Action',
        confirm: 'Confirm',
        dashboard: 'Dashboard',
        somethingWentWrong: 'Something went wrong.'
    };

    connectedCallback() {
        this.initLanguage().then(() => this.loadForPage());
    }

    async initLanguage() {
        try {
            const stored = readStoredLanguage();
            const language = stored || (await getCurrentLanguage()) || 'en_US';
            const normalized = language === 'fr' ? 'fr' : 'en_US';
            writeStoredLanguage(normalized);
            const apiMap = await getLabels({
                apiNames: LABEL_API_NAMES,
                language: normalized
            });
            this.labels = { ...this.labels, ...mapApiToCamel(apiMap) };
            if (!this.labels.loading) {
                this.labels.loading = 'Loading';
            }
        } catch (e) {
            // keep English defaults
        }
    }

    get roleOptions() {
        const L = this.labels;
        return [
            { label: L.roleCompanyAdministrator, value: 'Company Administrator' },
            { label: L.roleSalesperson, value: 'Salesperson' },
            { label: L.roleSponsoredAgent, value: 'Sponsored Agent' },
            { label: L.roleReviewer, value: 'Reviewer' },
            { label: L.roleReadOnly, value: 'Read Only' }
        ];
    }

    get statusOptions() {
        const L = this.labels;
        return [
            { label: L.active, value: 'Active' },
            { label: L.inactive, value: 'Inactive' },
            { label: L.suspended, value: 'Suspended' }
        ];
    }

    get permissionOptions() {
        const L = this.labels;
        return [
            { label: L.permEditPersonalProfile, value: 'Edit Personal Profile' },
            { label: L.permManageCredentialsLicensing, value: 'Manage Credentials & Licensing' },
            { label: L.permViewSponsorshipStatus, value: 'View Sponsorship Status' },
            { label: L.permInitiateNewApplications, value: 'Initiate New Applications' },
            { label: L.permUploadTransactionDocuments, value: 'Upload Transaction Documents' },
            { label: L.permTrackSubmissionProgress, value: 'Track Submission Progress' },
            { label: L.permManageClientPortfolios, value: 'Manage Client Portfolios' },
            { label: L.permRequestSupervisorSignOff, value: 'Request Supervisor Sign-off' }
        ];
    }

    get permissionEditorOptions() {
        const selected = new Set(this.draftPermissions || []);
        return this.permissionOptions.map((opt) => ({
            ...opt,
            checked: selected.has(opt.value),
            inputId: `perm-${String(opt.value).replace(/[^a-zA-Z0-9]/g, '-')}`
        }));
    }

    get savePermissionsLabel() {
        return this.isSaving ? this.labels.saving : this.labels.save;
    }

    get removeBranchConfirmLabel() {
        return this.isSaving ? this.labels.saving : this.labels.removeBranchConfirm;
    }

    get showBusyOverlay() {
        return this.isLoading || this.isSaving;
    }

    get permissionsUserRoleLabel() {
        if (!this.permissionsUser) {
            return '';
        }
        return this.permissionsUser.isSponsored
            ? this.labels.sponsoredAgentLabel
            : this.labels.organizationUserLabel;
    }

    get branchToRemoveName() {
        return this.branchToRemove?.name || '';
    }

    get statusFilterOptions() {
        const L = this.labels;
        return [
            { label: L.allStatuses, value: 'all' },
            { label: L.active, value: 'Active' },
            { label: L.inactive, value: 'Inactive' },
            { label: L.suspended, value: 'Suspended' }
        ];
    }

    get isOrgDashboard() {
        return this._pageMode === 'orgDashboard';
    }
    get isDelegate() {
        return this._pageMode === 'delegate';
    }
    get isActivity() {
        return this._pageMode === 'activity';
    }
    get isOrganization() {
        return this._pageMode === 'organization';
    }
    get isBranches() {
        return this._pageMode === 'branches';
    }
    get isSponsored() {
        return this._pageMode === 'sponsored';
    }

    get crumbLabel() {
        const L = this.labels;
        const map = {
            orgDashboard: L.dashboard,
            delegate: L.delegateAccess,
            activity: L.delegationActivity,
            organization: L.organizationAccess,
            branches: L.branchesLocations,
            sponsored: L.sponsoredAgents
        };
        return `${L.companyAdministration} / ${map[this._pageMode] || L.dashboard}`;
    }

    get pageTitle() {
        const L = this.labels;
        const map = {
            orgDashboard: L.orgDashboardTitle,
            delegate: L.delegateAccess,
            activity: L.delegationActivity,
            organization: L.organizationAccess,
            branches: L.branchesLocations,
            sponsored: L.sponsoredAgents
        };
        return map[this._pageMode] || L.organization;
    }

    get pageSubtitle() {
        const L = this.labels;
        const map = {
            orgDashboard: L.orgDashboardSubtitle,
            delegate: L.delegateSubtitle,
            activity: L.activitySubtitle,
            organization: L.organizationSubtitle,
            branches: L.branchesSubtitle,
            sponsored: L.sponsoredSubtitle
        };
        return map[this._pageMode] || '';
    }

    get peopleCountLabel() {
        return (this.labels.showingSalespeople || '')
            .replace('{0}', String(this.filteredUsers.length))
            .replace('{1}', String(this.users.length));
    }

    get toUserOptions() {
        if (!this.fromUser) {
            return [];
        }
        const noLicense = this.labels.noLicense;
        return this.users
            .filter(
                (u) =>
                    u.id !== this.fromUser.id &&
                    u.status === 'Active' &&
                    u.accessType === 'Own Access' &&
                    !u.isSponsored
            )
            .map((u) => ({
                label: `${u.personName} — ${u.license || noLicense}`,
                value: u.id
            }));
    }

    get branchOptions() {
        return this.branches.map((b) => ({
            label: b.name,
            value: b.id,
            selected: b.id === this.sponsorBranchId
        }));
    }

    get saveBranchLabel() {
        return this.isSaving ? this.labels.saving : this.labels.save;
    }

    get saveSponsorLabel() {
        return this.isSaving ? this.labels.saving : this.labels.save;
    }

    get orgUserSummary() {
        const list = this.organizationUsers;
        const admins = list.filter((u) => u.role === 'Company Administrator').length;
        return (this.labels.usersAdminSummary || '')
            .replace('{0}', String(list.length))
            .replace('{1}', String(admins || 0));
    }

    get organizationUsers() {
        return (this.users || []).filter((u) => !u.isSponsored);
    }

    get spinnerAltText() {
        return this.labels.loading || this.labels.loadingQueue || 'Loading';
    }

    loadForPage() {
        if (this.isOrgDashboard) {
            this.loadDashboard();
        } else if (this.isDelegate || this.isOrganization) {
            this.loadUsers();
            if (this.isOrganization) {
                this.loadBranches();
            }
        } else if (this.isActivity) {
            this.loadActivities();
        } else if (this.isBranches) {
            this.loadBranches();
        } else if (this.isSponsored) {
            this.loadSponsored();
            this.loadBranches();
        }
    }

    loadDashboard() {
        this.isLoading = true;
        getDashboard()
            .then((data) => {
                this.companyName = data.companyName || this.labels.organization;
                this.portalUsers = data.portalUsers || 0;
                this.activeUsers = data.activeUsers || 0;
                this.branchCount = data.branchCount || 0;
                this.sponsoredCount = data.sponsoredCount || 0;
                this.recentDelegations = this.decorateActivities(data.recentDelegations || []);
                this.users = this.decorateUsers(data.users || []);
            })
            .catch((e) => this.toastError(e))
            .finally(() => {
                this.isLoading = false;
            });
    }

    loadUsers() {
        this.isLoading = true;
        Promise.all([getOrganizationUsers(), getDashboard()])
            .then(([users, dash]) => {
                this.companyName = dash?.companyName || this.companyName || this.labels.organization;
                this.users = this.decorateUsers(users || []);
                this.applyPeopleFilter();
            })
            .catch((e) => this.toastError(e))
            .finally(() => {
                this.isLoading = false;
            });
    }

    loadActivities() {
        this.isLoading = true;
        Promise.all([getDelegationActivity(), getDashboard()])
            .then(([activities, dash]) => {
                this.companyName = dash?.companyName || this.companyName || this.labels.organization;
                this.activities = this.decorateActivities(activities || []);
            })
            .catch((e) => this.toastError(e))
            .finally(() => {
                this.isLoading = false;
            });
    }

    loadBranches() {
        this.reloadBranches().catch(() => {});
    }

    loadSponsored() {
        this.isLoading = true;
        Promise.all([this.reloadSponsored(), getDashboard()])
            .then(([, dash]) => {
                this.companyName = dash?.companyName || this.companyName || this.labels.organization;
            })
            .catch((e) => this.toastError(e))
            .finally(() => {
                this.isLoading = false;
            });
    }

    translateStatus(status) {
        const map = {
            Active: this.labels.active,
            Inactive: this.labels.inactive,
            Suspended: this.labels.suspended
        };
        return map[status] || status;
    }

    translateRole(role) {
        const map = {
            'Company Administrator': this.labels.roleCompanyAdministrator,
            Salesperson: this.labels.roleSalesperson,
            'Sponsored Agent': this.labels.roleSponsoredAgent,
            Reviewer: this.labels.roleReviewer,
            'Read Only': this.labels.roleReadOnly
        };
        return map[role] || role;
    }

    translatePermission(permission) {
        const map = {
            'Edit Personal Profile': this.labels.permEditPersonalProfile,
            'Manage Credentials & Licensing': this.labels.permManageCredentialsLicensing,
            'View Sponsorship Status': this.labels.permViewSponsorshipStatus,
            'Initiate New Applications': this.labels.permInitiateNewApplications,
            'Upload Transaction Documents': this.labels.permUploadTransactionDocuments,
            'Track Submission Progress': this.labels.permTrackSubmissionProgress,
            'Manage Client Portfolios': this.labels.permManageClientPortfolios,
            'Request Supervisor Sign-off': this.labels.permRequestSupervisorSignOff
        };
        return map[permission] || permission;
    }

    translateAccessType(accessType) {
        const map = {
            'Own Access': this.labels.ownAccess,
            'Using Delegated Access': this.labels.usingDelegatedAccess,
            'Delegated Out': this.labels.delegatedOut
        };
        return map[accessType] || accessType;
    }

    decorateActivities(list) {
        return (list || []).map((a) => ({
            ...a,
            statusLabel: this.translateStatus(a.status)
        }));
    }

    decorateUsers(list) {
        const L = this.labels;
        return (list || []).map((u) => {
            const accessType = u.accessType || 'Own Access';
            const status = u.status || 'Active';
            const initials = (u.personName || '')
                .split(' ')
                .map((p) => p.charAt(0))
                .join('')
                .slice(0, 2)
                .toUpperCase();
            return {
                ...u,
                initials,
                isOwn: accessType === 'Own Access',
                isDelegated: accessType === 'Using Delegated Access',
                isDelegatedOut: accessType === 'Delegated Out',
                canDelegate: status === 'Active' && accessType === 'Own Access' && !u.isSponsored,
                statusClass: `status-select ${String(status).toLowerCase()}`,
                statusBadgeClass: `status ${String(status).toLowerCase()}`,
                accessTypeLabel: this.translateAccessType(accessType),
                statusLabel: this.translateStatus(status),
                roleLabel: this.translateRole(u.role),
                usingAccessLabel: (L.usingAccessOf || '').replace('{0}', u.accessFrom || ''),
                delegatedToLabel: (L.delegatedToPerson || '').replace(
                    '{0}',
                    u.delegationTarget || ''
                ),
                permissionChips: (u.permissions || []).map((p, idx) => ({
                    key: `${u.id}-${idx}`,
                    value: p,
                    label: this.translatePermission(p)
                }))
            };
        });
    }

    applyPeopleFilter() {
        const q = (this.searchTerm || '').toLowerCase();
        const f = this.statusFilter || 'all';
        this.filteredUsers = this.users.filter((u) => {
            if (u.isSponsored) {
                return false;
            }
            const statusOk = f === 'all' || u.status === f;
            const text = `${u.personName || ''} ${u.emailAddress || ''} ${u.license || ''}`.toLowerCase();
            return statusOk && (!q || text.includes(q));
        });
    }

    handleSearch(event) {
        this.searchTerm = event.target.value;
        this.applyPeopleFilter();
    }

    handleStatusFilter(event) {
        this.statusFilter = event.detail.value;
        this.applyPeopleFilter();
    }

    handleStatusChange(event) {
        const id = event.target.dataset.id;
        const status = event.target.value;
        updateUserStatus({ organizationUserId: id, status })
            .then(() => {
                this.showToast(this.labels.success, this.labels.statusUpdated, 'success');
                this.loadUsers();
            })
            .catch((e) => this.toastError(e));
    }

    handleStatusComboChange(event) {
        const id = event.target.dataset.id;
        const status = event.detail.value;
        updateUserStatus({ organizationUserId: id, status })
            .then(() => {
                this.showToast(this.labels.success, this.labels.statusUpdated, 'success');
                this.loadUsers();
            })
            .catch((e) => this.toastError(e));
    }

    handleOpenDelegate(event) {
        const id = event.currentTarget.dataset.id;
        this.fromUser = this.users.find((u) => u.id === id);
        this.toUserId = '';
        this.reason = '';
        this.showDelegateModal = true;
    }

    handleCloseDelegate() {
        this.showDelegateModal = false;
    }

    handleToUserChange(event) {
        this.toUserId = event.detail.value;
    }

    handleReasonChange(event) {
        this.reason = event.target.value;
    }

    handleConfirmDelegate() {
        if (!this.fromUser || !this.toUserId) {
            this.showToast(this.labels.error, this.labels.selectSalespersonReceive, 'error');
            return;
        }
        delegateAccess({
            fromOrganizationUserId: this.fromUser.id,
            toOrganizationUserId: this.toUserId,
            reason: this.reason
        })
            .then((res) => {
                this.showDelegateModal = false;
                this.successFrom = res.fromName;
                this.successTo = res.toName;
                this.showSuccessModal = true;
                this.loadUsers();
            })
            .catch((e) => this.toastError(e));
    }

    handleCloseSuccess() {
        this.showSuccessModal = false;
    }

    handleViewDelegation(event) {
        const id = event.currentTarget.dataset.id;
        this.viewUser = this.users.find((u) => u.id === id);
        this.showViewModal = true;
    }

    handleRevokeAccess(event) {
        const id = event.currentTarget.dataset.id;
        if (!id) {
            return;
        }
        revokeAccess({ organizationUserId: id })
            .then(() => {
                this.showToast(this.labels.success, this.labels.accessRevoked, 'success');
                this.loadUsers();
            })
            .catch((e) => this.toastError(e));
    }

    handleCloseView() {
        this.showViewModal = false;
    }

    handleOrgFieldChange(event) {
        const id = event.target.dataset.id;
        const field = event.target.dataset.field;
        const value = event.detail ? event.detail.value : event.target.value;
        const user = this.users.find((u) => u.id === id);
        if (!user) {
            return;
        }
        const payload = {
            organizationUserId: id,
            role: user.role,
            status: user.status,
            branchId: user.branchId,
            taskPermissions: (user.permissions || []).join(';')
        };
        if (field === 'role') payload.role = value;
        if (field === 'status') payload.status = value;
        if (field === 'branch') payload.branchId = value;
        updateOrganizationUser(payload)
            .then(() => {
                this.showToast(this.labels.saved, this.labels.orgUserUpdated, 'success');
                this.loadUsers();
            })
            .catch((e) => this.toastError(e));
    }

    handlePermissionChange(event) {
        const id = event.target.dataset.id;
        const values = event.detail.value || [];
        const user = this.users.find((u) => u.id === id);
        if (!user) {
            return;
        }
        updateOrganizationUser({
            organizationUserId: id,
            role: user.role,
            status: user.status,
            branchId: user.branchId,
            taskPermissions: values.join(';')
        })
            .then(() => {
                this.showToast(this.labels.saved, this.labels.permissionsUpdated, 'success');
                this.loadUsers();
            })
            .catch((e) => this.toastError(e));
    }

    handleOpenPermissionsModal(event) {
        const id = event.currentTarget.dataset.id;
        const agent =
            this.sponsoredAgents.find((u) => u.id === id) ||
            this.users.find((u) => u.id === id);
        if (!agent) {
            return;
        }
        this.permissionsUser = agent;
        this.draftPermissions = [...(agent.permissions || [])];
        this.formError = '';
        this.showPermissionsModal = true;
    }

    handleClosePermissionsModal() {
        if (this.isSaving) {
            return;
        }
        this.showPermissionsModal = false;
        this.permissionsUser = null;
        this.draftPermissions = [];
        this.formError = '';
    }

    handlePermissionToggle(event) {
        const value = event.target.value;
        const checked = event.target.checked;
        const next = new Set(this.draftPermissions || []);
        if (checked) {
            next.add(value);
        } else {
            next.delete(value);
        }
        this.draftPermissions = [...next];
    }

    handleSavePermissions() {
        if (!this.permissionsUser) {
            return;
        }
        this.formError = '';
        this.isSaving = true;
        updateOrganizationUser({
            organizationUserId: this.permissionsUser.id,
            role: this.permissionsUser.role,
            status: this.permissionsUser.status,
            branchId: this.permissionsUser.branchId,
            taskPermissions: (this.draftPermissions || []).join(';')
        })
            .then(() => {
                this.showPermissionsModal = false;
                this.permissionsUser = null;
                this.draftPermissions = [];
                this.showToast(this.labels.saved, this.labels.permissionsUpdated, 'success');
                if (this.isSponsored) {
                    return this.reloadSponsored();
                }
                return this.loadUsers();
            })
            .catch((e) => {
                this.formError = this.errorMessage(e);
                this.toastError(e);
            })
            .finally(() => {
                this.isSaving = false;
            });
    }

    handleOpenBranchModal() {
        this.branchName = '';
        this.branchAddress = '';
        this.branchDescription = '';
        this.formError = '';
        this.showBranchModal = true;
    }

    handleCloseBranchModal() {
        if (this.isSaving) {
            return;
        }
        this.showBranchModal = false;
        this.formError = '';
    }

    handleBranchField(event) {
        const field = event.target.dataset.field;
        const value = event.detail && event.detail.value !== undefined ? event.detail.value : event.target.value;
        this[field] = value;
    }

    handleSaveBranch() {
        this.formError = '';
        if (!this.branchName || !this.branchName.trim()) {
            this.formError = this.labels.branchNameRequired;
            return;
        }
        this.isSaving = true;
        createBranch({
            name: this.branchName.trim(),
            address: (this.branchAddress || '').trim(),
            description: (this.branchDescription || '').trim()
        })
            .then(() => {
                this.showBranchModal = false;
                this.showToast(this.labels.success, this.labels.branchCreated, 'success');
                return this.reloadBranches();
            })
            .catch((e) => {
                this.formError = this.errorMessage(e);
                this.toastError(e);
            })
            .finally(() => {
                this.isSaving = false;
            });
    }

    handleRemoveBranch(event) {
        const id = event.currentTarget.dataset.id;
        if (!id) {
            return;
        }
        const branch = (this.branches || []).find((b) => b.id === id);
        if (!branch) {
            return;
        }
        this.branchToRemove = branch;
        this.formError = '';
        this.showRemoveBranchModal = true;
    }

    handleCloseRemoveBranchModal() {
        if (this.isSaving) {
            return;
        }
        this.showRemoveBranchModal = false;
        this.branchToRemove = null;
        this.formError = '';
    }

    handleConfirmRemoveBranch() {
        if (!this.branchToRemove?.id) {
            return;
        }
        this.formError = '';
        this.isSaving = true;
        deleteBranch({ branchId: this.branchToRemove.id })
            .then(() => {
                this.showRemoveBranchModal = false;
                this.branchToRemove = null;
                this.showToast(this.labels.success, this.labels.branchRemoved, 'success');
                return Promise.all([this.reloadBranches(), getDashboard()]).then(([_, dash]) => {
                    if (dash) {
                        this.branchCount = dash.branchCount || 0;
                    }
                });
            })
            .catch((e) => {
                this.formError = this.errorMessage(e);
                this.toastError(e);
            })
            .finally(() => {
                this.isSaving = false;
            });
    }

    handleOpenSponsorModal() {
        this.formError = '';
        this.sponsorFirstName = '';
        this.sponsorLastName = '';
        this.sponsorEmail = '';
        this.reloadBranches().then(() => {
            this.sponsorBranchId = this.branches.length ? this.branches[0].id : '';
            this.showSponsorModal = true;
        });
    }

    handleCloseSponsorModal() {
        if (this.isSaving) {
            return;
        }
        this.showSponsorModal = false;
        this.formError = '';
    }

    handleSponsorField(event) {
        const field = event.target.dataset.field;
        const value = event.detail && event.detail.value !== undefined ? event.detail.value : event.target.value;
        this[field] = value;
    }

    handleSaveSponsor() {
        this.formError = '';
        if (
            !this.sponsorFirstName ||
            !this.sponsorFirstName.trim() ||
            !this.sponsorLastName ||
            !this.sponsorLastName.trim()
        ) {
            this.formError = this.labels.namesRequired;
            return;
        }
        if (!this.sponsorBranchId) {
            this.formError = this.labels.selectBranch;
            return;
        }
        this.isSaving = true;
        createSponsoredAgent({
            firstName: this.sponsorFirstName.trim(),
            lastName: this.sponsorLastName.trim(),
            email: (this.sponsorEmail || '').trim(),
            branchId: this.sponsorBranchId,
            taskPermissions:
                'Edit Personal Profile;View Sponsorship Status;Initiate New Applications;Upload Transaction Documents'
        })
            .then(() => {
                this.showSponsorModal = false;
                this.showToast(this.labels.success, this.labels.sponsoredAgentAdded, 'success');
                return this.reloadSponsored();
            })
            .catch((e) => {
                this.formError = this.errorMessage(e);
                this.toastError(e);
            })
            .finally(() => {
                this.isSaving = false;
            });
    }

    reloadBranches() {
        return getBranches()
            .then((data) => {
                this.branches = (data || []).map((b) => ({
                    ...b,
                    userLabel: (this.labels.usersCount || '').replace(
                        '{0}',
                        String(b.userCount || 0)
                    )
                }));
            })
            .catch((e) => this.toastError(e));
    }

    reloadSponsored() {
        return getSponsoredAgents()
            .then((data) => {
                this.sponsoredAgents = this.decorateUsers(data || []);
            })
            .catch((e) => this.toastError(e));
    }

    handleGoDelegate() {
        this.dispatchEvent(
            new CustomEvent('arpnavigate', {
                detail: { page: 'delegate' },
                bubbles: true,
                composed: true
            })
        );
    }

    handleGoOrganization() {
        this.dispatchEvent(
            new CustomEvent('arpnavigate', {
                detail: { page: 'organization' },
                bubbles: true,
                composed: true
            })
        );
    }

    handleGoSponsored() {
        this.dispatchEvent(
            new CustomEvent('arpnavigate', {
                detail: { page: 'sponsored' },
                bubbles: true,
                composed: true
            })
        );
    }

    errorMessage(error) {
        if (error?.body?.pageErrors?.length) {
            return error.body.pageErrors[0].message;
        }
        const fieldErrors = error?.body?.fieldErrors;
        if (fieldErrors) {
            const firstField = Object.keys(fieldErrors)[0];
            if (firstField && fieldErrors[firstField]?.length) {
                return fieldErrors[firstField][0].message;
            }
        }
        return error?.body?.message || error?.message || this.labels.somethingWentWrong;
    }

    toastError(error) {
        this.showToast(this.labels.error, this.errorMessage(error), 'error');
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }
}