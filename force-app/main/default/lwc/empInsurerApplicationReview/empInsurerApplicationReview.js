import { LightningElement, track, wire } from 'lwc';
import { NavigationMixin, CurrentPageReference } from 'lightning/navigation';
import getInsurerReviewApplication from '@salesforce/apex/EMP_SponsoringInsurerReviewCtrl.getInsurerReviewApplication';
import saveDecision from '@salesforce/apex/EMP_SponsoringInsurerReviewCtrl.saveDecision';
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

export default class EmpInsurerApplicationReview extends NavigationMixin(LightningElement) {
    @track applicationId;
    @track selectedApp = null;
    @track decisionValue = '';
    @track comments = '';
    @track modalComments = '';
    @track reviewFormDataJson = null;
    @track reviewLabelDataJson = null;
    @track reviewSummaryKey = 0;
    @track alertMessage = '';
    @track alertType = '';
    @track showModal = false;
    @track modalTitle = '';
    @track modalText = '';
    @track pendingStatus = null;
    @track isLoading = false;
    @track loadError = '';
    @track labels = {
        sirQueueTitle: 'Insurer Review Queue',
        sirDetailTitle: 'Application Detail – Insurer Review',
        sirReturnRmi: 'Return for More Information',
        sirApproveSponsorship: 'Approve Sponsorship',
        sirReject: 'Reject',
        sirApplicantInfo: 'Applicant Information',
        sirApplicationNumber: 'Application Number',
        sirApplicantName: 'Applicant Name',
        sirDob: 'Date of Birth',
        sirCipr: 'CIPR Number',
        email: 'Email',
        phone: 'Phone',
        documentReview: 'Document Review',
        download: 'Download',
        noDocumentsUploaded: 'No uploaded documents found for this application.',
        reviewSummary: 'Review & Summary',
        reviewSummaryUnavailable:
            'Review & Summary data is not available for this application yet.',
        sirInsurerDecision: 'Insurer Decision',
        sirComments: 'Comments (optional)',
        sirAppInfo: 'Application Information',
        licenceType: 'License Type',
        sirTerm: 'Term',
        sirAgencyFirm: 'Agency / Firm',
        sirSupervisor: 'Supervisor',
        sirSubmittedOn: 'Submitted On',
        sirTransactionId: 'Transaction ID',
        sirCurrentStatus: 'Current Status',
        cancel: 'Cancel',
        save: 'Save',
        sirSelectApp: 'Select an application from the queue to review.',
        sirConfirm: 'Confirm',
        sirSelectDecision: '-- Select Decision --',
        sirRejectSponsorship: 'Reject sponsorship',
        sirSubmittedToInsurer: 'Submitted to Insurer',
        sirInfoSubmitted: 'Information Submitted',
        sirMoreInfoRequire: 'More Info Require',
        sirApprovedByInsurer: 'Approved by Insurer',
        sirDeniedByInsurer: 'Denied by Insurer',
        selectAnApplication: 'Select an application',
        somethingWentWrong: 'Something went wrong.',
        viewOnly: 'This application is view-only. Decision actions are not available.',
        selectFirst: 'Select an application first.'
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

    get decisionOptions() {
        return [
            { label: this.labels.sirSelectDecision, value: '' },
            { label: this.labels.sirApproveSponsorship, value: STATUS_APPROVED },
            { label: this.labels.sirReturnRmi, value: STATUS_RMI },
            { label: this.labels.sirRejectSponsorship, value: STATUS_REJECTED }
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

    get showAlert() {
        return !!this.alertMessage;
    }

    get alertClass() {
        return `alert show ${this.alertType || 'info'}`;
    }

    get hasLoadError() {
        return !!this.loadError;
    }

    get actionsDisabled() {
        if (!this.selectedApp) {
            return true;
        }
        const status = this.selectedApp.status;
        return (
            status === STATUS_APPROVED ||
            status === 'Approved' ||
            status === STATUS_REJECTED ||
            status === 'Denied' ||
            status === 'Rejected'
        );
    }

    get canActOnSelection() {
        return !this.actionsDisabled;
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

    get selectedStatusLabel() {
        return this.translateStatus(this.selectedApp?.status);
    }

    get isRmiModal() {
        return this.pendingStatus === STATUS_RMI;
    }

    get modalConfirmButtonLabel() {
        return this.isRmiModal ? this.labels.save : this.labels.sirConfirm;
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

    statusClass(status) {
        if (status === STATUS_APPROVED || status === 'Approved') return 'mini-chip chip-green';
        if (status === STATUS_RMI) return 'mini-chip chip-orange';
        if (status === STATUS_REJECTED || status === 'Denied' || status === 'Rejected') return 'mini-chip chip-red';
        if (status === STATUS_INFO_SUBMITTED) return 'mini-chip chip-blue';
        return 'mini-chip chip-blue';
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
            const result = await getInsurerReviewApplication({ applicationId: this.applicationId });
            const app = result?.applications?.[0] || null;
            if (!app) {
                this.selectedApp = null;
                this.clearReviewSummaryData();
                this.loadError = this.labels.sirSelectApp;
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
        const formRaw = app?.reviewFormDataJson || app?.ReviewFormDataJson;
        const labelRaw = app?.reviewLabelDataJson || app?.ReviewLabelDataJson;
        this.reviewFormDataJson = typeof formRaw === 'string' ? formRaw : this.stringifyMaybe(formRaw);
        this.reviewLabelDataJson = typeof labelRaw === 'string' ? labelRaw : this.stringifyMaybe(labelRaw);
        this.reviewSummaryKey += 1;
    }

    clearReviewSummaryData() {
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

    applyDetail(app) {
        this.decisionValue =
            app.status === STATUS_SUBMITTED || app.status === STATUS_INFO_SUBMITTED
                ? ''
                : app.insurerDecision || app.status || '';
        this.comments = app.comments || '';
        this.clearAlert();
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

    handleBack() {
        try {
            window.sessionStorage.setItem('emp_insurer_review_page', 'queue');
        } catch (e) {
            // ignore
        }
        window.dispatchEvent(
            new CustomEvent('empinsurernavigate', {
                detail: { page: 'queue' },
                bubbles: true,
                composed: true
            })
        );
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: { name: 'Home' }
        });
    }

    handleDecisionChange(event) {
        this.decisionValue = event.detail.value;
    }

    handleCommentsChange(event) {
        this.comments = event.target.value;
    }

    handleModalCommentsChange(event) {
        this.modalComments = event.target.value;
    }

    handleApprove() {
        if (this.actionsDisabled) {
            this.showAlertBanner('info', this.labels.viewOnly);
            return;
        }
        this.openConfirm(
            'Approve sponsorship',
            'Approve this sponsorship and allow the application to proceed to FCNB review?',
            STATUS_APPROVED
        );
    }

    handleReturn() {
        if (this.actionsDisabled) {
            this.showAlertBanner('info', this.labels.viewOnly);
            return;
        }
        this.modalComments = this.comments || '';
        this.openConfirm(
            'Return for More Information',
            'Please enter the comments or reasons for returning this application for more information:',
            STATUS_RMI
        );
    }

    handleReject() {
        if (this.actionsDisabled) {
            this.showAlertBanner('info', this.labels.viewOnly);
            return;
        }
        this.openConfirm(
            'Deny by insurer',
            'Mark this application as Denied by Insurer? The application will remain on file and will not be deleted.',
            STATUS_REJECTED
        );
    }

    handleSave() {
        if (this.actionsDisabled) {
            this.showAlertBanner('info', this.labels.viewOnly);
            return;
        }
        if (!this.decisionValue) {
            this.showAlertBanner('warn', 'Select an insurer decision before saving.');
            return;
        }
        const name = this.selectedApp?.applicantName || 'this applicant';
        this.openConfirm('Save insurer decision', `Save “${this.decisionValue}” for ${name}?`, 'save');
    }

    handleCancel() {
        if (this.selectedApp) {
            this.applyDetail(this.selectedApp);
            this.showAlertBanner('info', 'Unsaved changes were cleared.');
        }
    }

    openConfirm(title, text, action) {
        if (!this.applicationId) {
            this.showAlertBanner('warn', this.labels.selectFirst);
            return;
        }
        this.modalTitle = title;
        this.modalText = text;
        this.pendingStatus = action;
        this.showModal = true;
    }

    closeModal() {
        this.showModal = false;
        this.pendingStatus = null;
        this.modalComments = '';
    }

    handleModalCancel() {
        this.closeModal();
    }

    async handleModalConfirm() {
        const action = this.pendingStatus;
        if (action === STATUS_RMI) {
            this.comments = this.modalComments;
        }
        this.closeModal();
        const status = action === 'save' ? this.decisionValue : action;
        await this.performDecision(status);
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
            const updated = await saveDecision({
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
            let msg = '';
            let type = 'success';
            if (status === STATUS_RMI) {
                msg = `${updated.applicantName} has been returned to the applicant for more information. On resubmission, the application returns to the insurer before FCNB.`;
                type = 'warn';
            } else if (status === STATUS_APPROVED) {
                msg = `Sponsorship approved for ${updated.applicantName}. The application can proceed to FCNB review.`;
            } else if (status === STATUS_REJECTED) {
                msg = `${updated.applicantName} was Denied by Insurer. The application remains on file and is not deleted.`;
                type = 'error';
            }
            this.showAlertBanner(type, msg);
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