import { LightningElement, track, wire } from 'lwc';
import { NavigationMixin, CurrentPageReference } from 'lightning/navigation';
import getAgentReviewApplication from '@salesforce/apex/EMP_SponsoringInsurerReviewCtrl.getAgentReviewApplication';
import saveAgentReviewDecision from '@salesforce/apex/EMP_SponsoringInsurerReviewCtrl.saveAgentReviewDecision';
import getCurrentLanguage from '@salesforce/apex/EMP_LanguageCtrl.getCurrentLanguage';
import getLabels from '@salesforce/apex/EMP_LanguageCtrl.getLabels';
import {
    LABEL_API_NAMES,
    mapApiToCamel,
    readStoredLanguage,
    writeStoredLanguage
} from 'c/arpLanguageUtils';

const STATUS_SUBMITTED = 'Submitted to Agent';
const STATUS_RMI = 'Agency Require More Info';
const STATUS_APPROVED = 'Submitted to FCNB';
const STATUS_DENIED = 'Agency Denied';

export default class ArpApplicationReview extends NavigationMixin(LightningElement) {
    @track applicationId;
    @track selectedApp = null;
    @track docsValue = 'complete';
    @track comments = '';
    @track modalComments = '';
    @track reviewFormData = null;
    @track reviewLabelData = null;
    @track reviewFormDataJson = null;
    @track reviewLabelDataJson = null;
    @track reviewSummaryKey = 0;
    @track alertMessage = '';
    @track alertType = '';
    @track showModal = false;
    @track modalTitle = '';
    @track modalText = '';
    @track pendingAction = null;
    @track isLoading = false;
    @track loadError = '';
    @track reviewerName = '';
    @track labels = {
        queueTitle: 'Agent Review Queue',
        detailTitle: 'Salesperson Application Review',
        returnMoreInfo: 'Return for More Information',
        approve: 'Approve',
        reject: 'Reject',
        applicantInformation: 'Applicant Information',
        applicationNumber: 'Application Number',
        applicantName: 'Applicant Name',
        dob: 'Date of Birth',
        email: 'Email',
        phone: 'Phone',
        licenceType: 'Licence Type',
        documentReview: 'Document Review',
        preview: 'Preview',
        download: 'Download',
        noDocumentsUploaded: 'No uploaded documents found for this application.',
        documentReviewResult: 'Document review result',
        documentsComplete: 'Documents complete',
        missingDocument: 'Missing / unclear document',
        reviewSummary: 'Review & Summary',
        reviewSummaryUnavailable:
            'Review & Summary data is not available for this application yet.',
        applicationSummary: 'Application Summary',
        submittedOn: 'Submitted On',
        transactionId: 'Transaction ID',
        currentStatus: 'Current Status',
        nextStage: 'Next Stage',
        nextStageValue: 'Submitted to FCNB / payment gate',
        agentDecision: 'Agent Decision',
        reasonRequested: 'Reason / Requested Items',
        commentsPlaceholder:
            'For RMI or rejection, state the reason. For approval, comments are optional.',
        approvalHint:
            'Approval moves the application to Submitted to FCNB.',
        clearChanges: 'Clear Changes',
        saveDecision: 'Save Decision',
        selectApplication: 'Select an application from the queue to review.',
        cancel: 'Cancel',
        confirm: 'Confirm',
        viewOnly: 'This application is view-only. Decision actions are not available.',
        completeDocReview: 'Complete the document review or return the application for more information.',
        approveTitle: 'Approve application',
        approveText: 'Approve this salesperson application and move it to Submitted to FCNB?',
        enterRmiReason: 'Enter the reason and requested items before returning the application.',
        rmiTitle: 'Return for More Information',
        rmiText:
            'Please state the reason or requested items for returning this application:',
        enterDenyReason: 'Enter the reason for denial before rejecting the application.',
        rejectTitle: 'Reject application',
        rejectText: 'Reject this application? It will be marked as Agency Denied and will not be deleted.',
        enterMissingItems: 'Enter the missing or unclear item(s) for the applicant.',
        saveRmiTitle: 'Save as Agency Require More Info',
        saveRmiText: 'Save the review as Agency Require More Info?',
        saveApprovalTitle: 'Save approval',
        saveApprovalText: 'Save the review and approve the application?',
        noDecisionRequired: 'No new decision is required for this record.',
        changesCleared: 'Unsaved changes were cleared.',
        selectFirst: 'Select an application first.',
        returnedMsg:
            '{0} was returned to the applicant for more information. After resubmission, the application returns to Agent Review.',
        approvedMsg:
            '{0} was approved by the Agent and moved to Submitted to FCNB. FCNB still waits for payment.',
        deniedMsg: '{0} was denied (Agency Denied). The application remains on file.',
        selectAnApplication: 'Select an application',
        loadingQueue: 'Loading application',
        somethingWentWrong: 'Something went wrong.',
        submittedToAgent: 'Submitted to Agent',
        agencyRequireMoreInfo: 'Agency Require More Info',
        submittedToFcnb: 'Submitted to FCNB',
        agencyDenied: 'Agency Denied'
    };

    @wire(CurrentPageReference)
    wiredPageRef(pageRef) {
        if (!pageRef) {
            return;
        }
        const nextId =
            pageRef.state?.c__applicationId ||
            pageRef.state?.c__recordId ||
            pageRef.state?.c__ContextId ||
            null;
        if (nextId && nextId !== this.applicationId) {
            this.applicationId = nextId;
            this.loadApplication();
        }
    }

    connectedCallback() {
        this.initLanguage();
        if (this.applicationId) {
            this.loadApplication();
        }
    }

    async initLanguage() {
        try {
            const stored = readStoredLanguage();
            const language = stored || (await getCurrentLanguage()) || 'en_US';
            writeStoredLanguage(language === 'fr' ? 'fr' : 'en_US');
            const apiMap = await getLabels({
                apiNames: LABEL_API_NAMES,
                language: language === 'fr' ? 'fr' : 'en_US'
            });
            this.labels = { ...this.labels, ...mapApiToCamel(apiMap) };
            if (!this.labels.applicationNumber) {
                this.labels.applicationNumber = 'Application Number';
            }
        } catch (e) {
            // keep defaults
        }
    }

    get docsOptions() {
        return [
            { label: this.labels.documentsComplete, value: 'complete' },
            { label: this.labels.missingDocument, value: 'missing' }
        ];
    }

    get hasSelection() {
        return !!this.selectedApp;
    }

    get hasReviewSummary() {
        return !!(this.reviewFormDataJson && this.reviewLabelDataJson);
    }

    get detailCrumb() {
        return this.selectedApp?.applicantName || this.labels.selectAnApplication;
    }

    get statusChipClass() {
        return this.statusClass(this.selectedApp?.status);
    }

    get selectedStatusLabel() {
        return this.translateStatus(this.selectedApp?.status);
    }

    get showAlert() {
        return !!this.alertMessage;
    }

    get alertClass() {
        const map = { info: 'info', warn: 'warnA', success: 'successA', error: 'warnA' };
        return `alert show ${map[this.alertType] || 'info'}`;
    }

    get hasLoadError() {
        return !!this.loadError;
    }

    get canActOnSelection() {
        return this.selectedApp?.canDecide === true;
    }

    get actionsDisabled() {
        return !this.canActOnSelection;
    }

    get isRmiDisabled() {
        return this.actionsDisabled || this.selectedApp?.status === STATUS_RMI;
    }

    get isRmiModal() {
        return this.pendingAction === STATUS_RMI;
    }

    get modalConfirmLabel() {
        return this.isRmiModal ? this.labels.saveDecision || 'Save' : this.labels.confirm;
    }

    get documentRows() {
        const docs = this.selectedApp?.documents || [];
        return docs.map((doc, index) => ({
            ...doc,
            key: doc.key || doc.contentDocumentId || `${doc.label || 'doc'}-${index}`
        }));
    }

    get hasDocuments() {
        return this.documentRows.length > 0;
    }

    translateStatus(status) {
        const map = {
            [STATUS_SUBMITTED]: this.labels.submittedToAgent,
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
        return 'mini chip-blue';
    }

    async loadApplication() {
        if (!this.applicationId) {
            this.selectedApp = null;
            this.clearReviewSummaryData();
            return;
        }
        this.isLoading = true;
        this.loadError = '';
        try {
            const result = await getAgentReviewApplication({ applicationId: this.applicationId });
            this.reviewerName = result?.reviewerName || '';
            const app = result?.applications?.[0] || null;
            if (!app) {
                this.selectedApp = null;
                this.clearReviewSummaryData();
                this.loadError = this.labels.selectApplication;
                return;
            }
            this.selectedApp = {
                ...app,
                applicationNumber: app.applicationNumber || app.transactionId || ''
            };
            this.setReviewSummaryData(app);
            this.applyDetail(this.selectedApp);
        } catch (error) {
            this.loadError = this.reduceError(error);
            this.selectedApp = null;
            this.clearReviewSummaryData();
        } finally {
            this.isLoading = false;
        }
    }

    setReviewSummaryData(app) {
        const formRaw =
            app?.reviewFormDataJson ||
            app?.ReviewFormDataJson ||
            app?.review_form_data_json;
        const labelRaw =
            app?.reviewLabelDataJson ||
            app?.ReviewLabelDataJson ||
            app?.review_label_data_json;
        this.reviewFormData = this.parseJsonMaybe(formRaw);
        this.reviewLabelData = this.parseJsonMaybe(labelRaw);
        this.reviewFormDataJson = typeof formRaw === 'string' ? formRaw : this.stringifyMaybe(this.reviewFormData);
        this.reviewLabelDataJson = typeof labelRaw === 'string' ? labelRaw : this.stringifyMaybe(this.reviewLabelData);
        this.reviewSummaryKey += 1;
    }

    clearReviewSummaryData() {
        this.reviewFormData = null;
        this.reviewLabelData = null;
        this.reviewFormDataJson = null;
        this.reviewLabelDataJson = null;
        this.reviewSummaryKey += 1;
    }

    stringifyMaybe(value) {
        if (!value) {
            return null;
        }
        try {
            return typeof value === 'string' ? value : JSON.stringify(value);
        } catch (e) {
            return null;
        }
    }

    parseJsonMaybe(value) {
        if (!value) {
            return null;
        }
        if (typeof value === 'object') {
            return value;
        }
        try {
            return JSON.parse(value);
        } catch (e) {
            return null;
        }
    }

    applyDetail(app) {
        this.docsValue = 'complete';
        this.comments = app.comments || '';
        this.clearAlert();
    }

    handleBack() {
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: { name: 'Home' }
        });
    }

    handleDocsChange(event) {
        this.docsValue = event.detail.value;
    }

    handleDocumentAction(event) {
        const url = event.currentTarget?.dataset?.url;
        const contentId = event.currentTarget?.dataset?.contentId;
        if (url) {
            window.open(url, '_blank');
            return;
        }
        if (contentId) {
            window.open('/sfc/servlet.shepherd/document/download/' + contentId, '_blank');
        }
    }

    handleCommentsChange(event) {
        this.comments = event.target.value;
    }

    handleModalCommentsChange(event) {
        this.modalComments = event.target.value;
    }

    handleApproveTop() {
        if (!this.canActOnSelection) {
            this.showAlertBanner('info', this.labels.viewOnly);
            return;
        }
        if (this.docsValue !== 'complete') {
            this.showAlertBanner('warn', this.labels.completeDocReview);
            return;
        }
        this.openConfirm(this.labels.approveTitle, this.labels.approveText, STATUS_APPROVED);
    }

    handleRmiTop() {
        if (!this.canActOnSelection) {
            this.showAlertBanner('info', this.labels.viewOnly);
            return;
        }
        if (this.selectedApp?.status === STATUS_RMI) {
            return;
        }
        this.modalComments = this.comments || '';
        this.openConfirm(this.labels.rmiTitle, this.labels.rmiText, STATUS_RMI);
    }

    handleRejectTop() {
        if (!this.canActOnSelection) {
            this.showAlertBanner('info', this.labels.viewOnly);
            return;
        }
        if (!this.comments.trim()) {
            this.showAlertBanner('warn', this.labels.enterDenyReason);
            return;
        }
        this.openConfirm(this.labels.rejectTitle, this.labels.rejectText, STATUS_DENIED);
    }

    handleSave() {
        if (!this.canActOnSelection) {
            this.showAlertBanner('info', this.labels.viewOnly);
            return;
        }
        if (this.docsValue === 'missing') {
            if (!this.comments.trim()) {
                this.showAlertBanner('warn', this.labels.enterMissingItems);
                return;
            }
            this.openConfirm(this.labels.saveRmiTitle, this.labels.saveRmiText, STATUS_RMI);
            return;
        }
        if (this.selectedApp?.status === STATUS_SUBMITTED) {
            this.openConfirm(this.labels.saveApprovalTitle, this.labels.saveApprovalText, STATUS_APPROVED);
            return;
        }
        this.showAlertBanner('info', this.labels.noDecisionRequired);
    }

    handleClear() {
        if (this.selectedApp) {
            this.applyDetail(this.selectedApp);
            this.showAlertBanner('info', this.labels.changesCleared);
        }
    }

    openConfirm(title, text, action) {
        if (!this.applicationId) {
            this.showAlertBanner('warn', this.labels.selectFirst);
            return;
        }
        this.modalTitle = title;
        this.modalText = text;
        this.pendingAction = action;
        this.showModal = true;
    }

    closeModal() {
        this.showModal = false;
        this.pendingAction = null;
        this.modalComments = '';
    }

    handleModalCancel() {
        this.closeModal();
    }

    async handleModalConfirm() {
        const action = this.pendingAction;
        if (action === STATUS_RMI) {
            this.comments = this.modalComments;
        }
        this.closeModal();
        await this.performDecision(action);
    }

    handleModalBackdrop(event) {
        if (event.target === event.currentTarget) {
            this.closeModal();
        }
    }

    handleModalKeydown(event) {
        if (event.key === 'Escape') {
            this.closeModal();
        }
    }

    async performDecision(status) {
        if (!this.applicationId || !status) {
            return;
        }
        this.isLoading = true;
        try {
            const updated = await saveAgentReviewDecision({
                applicationId: this.applicationId,
                decisionStatus: status,
                comments: this.comments
            });
            this.selectedApp = {
                ...updated,
                applicationNumber: updated.applicationNumber || updated.transactionId || ''
            };
            this.setReviewSummaryData(updated);
            this.applyDetail(this.selectedApp);
            if (status === STATUS_RMI) {
                this.showAlertBanner(
                    'warn',
                    (this.labels.returnedMsg || '').replace('{0}', updated.applicantName || '')
                );
            } else if (status === STATUS_APPROVED) {
                this.showAlertBanner(
                    'success',
                    (this.labels.approvedMsg || '').replace('{0}', updated.applicantName || '')
                );
            } else if (status === STATUS_DENIED) {
                this.showAlertBanner(
                    'error',
                    (this.labels.deniedMsg || '').replace('{0}', updated.applicantName || '')
                );
            }
        } catch (error) {
            this.showAlertBanner('error', this.reduceError(error));
        } finally {
            this.isLoading = false;
        }
    }

    clearAlert() {
        this.alertMessage = '';
        this.alertType = '';
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
            this.labels.somethingWentWrong
        );
    }
}