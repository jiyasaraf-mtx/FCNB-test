import { LightningElement, track } from 'lwc';
import getFilings from '@salesforce/apex/EMP_FinancialFilingCtrl.getFilings';
import createFiling from '@salesforce/apex/EMP_FinancialFilingCtrl.createFiling';
import saveFiling from '@salesforce/apex/EMP_FinancialFilingCtrl.saveFiling';
import getFiles from '@salesforce/apex/EMP_FinancialFilingCtrl.getFiles';
import removeFile from '@salesforce/apex/EMP_FinancialFilingCtrl.removeFile';
import getPreviewUrl from '@salesforce/apex/EMP_FinancialFilingCtrl.getPreviewUrl';
import searchBusinessLicenses from '@salesforce/apex/EMP_FinancialFilingCtrl.searchBusinessLicenses';
import getCurrentLanguage from '@salesforce/apex/EMP_LanguageCtrl.getCurrentLanguage';
import getLabels from '@salesforce/apex/EMP_LanguageCtrl.getLabels';
import {
    LABEL_API_NAMES,
    mapApiToCamel,
    readStoredLanguage,
    writeStoredLanguage
} from 'c/empLanguageUtils';
import EP_Expand from '@salesforce/label/c.EP_Expand';
import EP_Collapse from '@salesforce/label/c.EP_Collapse';
import EP_All_Annual_Financial_Filings from '@salesforce/label/c.EP_All_Annual_Financial_Filings';
import EP_Showing_All_Filings from '@salesforce/label/c.EP_Showing_All_Filings';
import EP_Draft from '@salesforce/label/c.EP_Draft';
import EP_Submitted from '@salesforce/label/c.EP_Submitted';
import EP_Accepted from '@salesforce/label/c.EP_Accepted';
import EP_Rejected from '@salesforce/label/c.EP_Rejected';
import EP_Financial_Filing_Requirements from '@salesforce/label/c.EP_Financial_Filing_Requirements';
import EP_Annual_Financial_Filing_Requirements_For from '@salesforce/label/c.EP_Annual_Financial_Filing_Requirements_For';
import EP_Portal_Home from '@salesforce/label/c.EP_Portal_Home';
import EP_Filings from '@salesforce/label/c.EP_Filings';
import EP_Open_Filing from '@salesforce/label/c.EP_Open_Filing';
import EP_Add_Annual_Filing from '@salesforce/label/c.EP_Add_Annual_Filing';
import EP_Parent_Licence from '@salesforce/label/c.EP_Parent_Licence';
import EP_Filing_Type from '@salesforce/label/c.EP_Filing_Type';
import EP_Reporting_Year from '@salesforce/label/c.EP_Reporting_Year';
import EP_Due from '@salesforce/label/c.EP_Due';
import EP_Current_Filing from '@salesforce/label/c.EP_Current_Filing';
import EP_In_Progress from '@salesforce/label/c.EP_In_Progress';
import EP_Under_Review from '@salesforce/label/c.EP_Under_Review';
import EP_Completed from '@salesforce/label/c.EP_Completed';
import EP_Action_Required from '@salesforce/label/c.EP_Action_Required';
import EP_Clear_Filter from '@salesforce/label/c.EP_Clear_Filter';
import EP_Show_All from '@salesforce/label/c.EP_Show_All';
import EP_Filing_Transactions from '@salesforce/label/c.EP_Filing_Transactions';
import EP_Filer from '@salesforce/label/c.EP_Filer';
import EP_Due_Date from '@salesforce/label/c.EP_Due_Date';
import EP_Premiums_NB from '@salesforce/label/c.EP_Premiums_NB';
import EP_Edit_Draft from '@salesforce/label/c.EP_Edit_Draft';
import EP_View_Details from '@salesforce/label/c.EP_View_Details';
import EP_No_Filings_Under_Status from '@salesforce/label/c.EP_No_Filings_Under_Status';
import EP_What_Must_Be_Submitted from '@salesforce/label/c.EP_What_Must_Be_Submitted';
import EP_Filing_Requirements_Checklist from '@salesforce/label/c.EP_Filing_Requirements_Checklist';
import EP_Required from '@salesforce/label/c.EP_Required';
import EP_Optional from '@salesforce/label/c.EP_Optional';
import EP_Reporting_Period from '@salesforce/label/c.EP_Reporting_Period';
import EP_Checklist_Reporting_Period_Desc from '@salesforce/label/c.EP_Checklist_Reporting_Period_Desc';
import EP_Filer_Contact from '@salesforce/label/c.EP_Filer_Contact';
import EP_Checklist_Filer_Contact_Desc from '@salesforce/label/c.EP_Checklist_Filer_Contact_Desc';
import EP_Checklist_Financial_Amounts from '@salesforce/label/c.EP_Checklist_Financial_Amounts';
import EP_Checklist_Financial_Amounts_Desc from '@salesforce/label/c.EP_Checklist_Financial_Amounts_Desc';
import EP_Annual_Statements from '@salesforce/label/c.EP_Annual_Statements';
import EP_Checklist_Annual_Statements_Desc from '@salesforce/label/c.EP_Checklist_Annual_Statements_Desc';
import EP_Attestation from '@salesforce/label/c.EP_Attestation';
import EP_Checklist_Attestation_Desc from '@salesforce/label/c.EP_Checklist_Attestation_Desc';
import EP_Checklist_Certification from '@salesforce/label/c.EP_Checklist_Certification';
import EP_Checklist_Certification_Desc from '@salesforce/label/c.EP_Checklist_Certification_Desc';
import EP_Requirement_Profile from '@salesforce/label/c.EP_Requirement_Profile';
import EP_Filing_Setup from '@salesforce/label/c.EP_Filing_Setup';
import EP_Edit_Filing_Setup from '@salesforce/label/c.EP_Edit_Filing_Setup';
import EP_Filing_ID from '@salesforce/label/c.EP_Filing_ID';
import EP_Status from '@salesforce/label/c.EP_Status';
import EP_Licence_Type from '@salesforce/label/c.EP_Licence_Type';
import EP_Required_Financial_Values from '@salesforce/label/c.EP_Required_Financial_Values';
import EP_Field from '@salesforce/label/c.EP_Field';
import EP_Value from '@salesforce/label/c.EP_Value';
import EP_Total_Assets from '@salesforce/label/c.EP_Total_Assets';
import EP_Total_Liabilities from '@salesforce/label/c.EP_Total_Liabilities';
import EP_Written_Premiums_NB from '@salesforce/label/c.EP_Written_Premiums_NB';
import EP_Other_NB_Amounts from '@salesforce/label/c.EP_Other_NB_Amounts';
import EP_Yes from '@salesforce/label/c.EP_Yes';
import EP_No from '@salesforce/label/c.EP_No';
import EP_As_Configured from '@salesforce/label/c.EP_As_Configured';
import EP_Documents_Evidence from '@salesforce/label/c.EP_Documents_Evidence';
import EP_Upload_Document from '@salesforce/label/c.EP_Upload_Document';
import EP_Upload_Annual_Statements_Desc from '@salesforce/label/c.EP_Upload_Annual_Statements_Desc';
import EP_Create_Filing_First from '@salesforce/label/c.EP_Create_Filing_First';
import EP_Accepted_File_Types from '@salesforce/label/c.EP_Accepted_File_Types';
import EP_Uploaded_To_Files from '@salesforce/label/c.EP_Uploaded_To_Files';
import EP_Preview from '@salesforce/label/c.EP_Preview';
import EP_Remove from '@salesforce/label/c.EP_Remove';
import EP_Annual_Statements_Required from '@salesforce/label/c.EP_Annual_Statements_Required';
import EP_Upload_Evidence from '@salesforce/label/c.EP_Upload_Evidence';
import EP_Submission_Rule from '@salesforce/label/c.EP_Submission_Rule';
import EP_Staff_Ready_View from '@salesforce/label/c.EP_Staff_Ready_View';
import EP_Financial_Analysis from '@salesforce/label/c.EP_Financial_Analysis';
import EP_Open_Staff_Analysis from '@salesforce/label/c.EP_Open_Staff_Analysis';
import EP_NB_Written_Premiums from '@salesforce/label/c.EP_NB_Written_Premiums';
import EP_Review_Requirement from '@salesforce/label/c.EP_Review_Requirement';
import EP_Hero_Sub from '@salesforce/label/c.EP_Hero_Sub';
import EP_Annual_Financial_Filing from '@salesforce/label/c.EP_Annual_Financial_Filing';
import EP_Add_Annual_Filing_Help from '@salesforce/label/c.EP_Add_Annual_Filing_Help';
import EP_Create_Draft from '@salesforce/label/c.EP_Create_Draft';
import EP_Period_Start from '@salesforce/label/c.EP_Period_Start';
import EP_Period_End from '@salesforce/label/c.EP_Period_End';
import EP_Search_License_Placeholder from '@salesforce/label/c.EP_Search_License_Placeholder';
import EP_Search_By_License_Hint from '@salesforce/label/c.EP_Search_By_License_Hint';
import EP_No_Matching_Licenses from '@salesforce/label/c.EP_No_Matching_Licenses';
import EP_Select_Parent_Licence from '@salesforce/label/c.EP_Select_Parent_Licence';
import EP_Cancel from '@salesforce/label/c.EP_Cancel';
import EP_Edit_Filing_Setup_Help from '@salesforce/label/c.EP_Edit_Filing_Setup_Help';
import EP_Filer_Account from '@salesforce/label/c.EP_Filer_Account';
import EP_Filer_First_Name from '@salesforce/label/c.EP_Filer_First_Name';
import EP_Filer_Last_Name from '@salesforce/label/c.EP_Filer_Last_Name';
import EP_Filer_Email from '@salesforce/label/c.EP_Filer_Email';
import EP_Filer_Phone from '@salesforce/label/c.EP_Filer_Phone';
import EP_Save_Changes from '@salesforce/label/c.EP_Save_Changes';
import EP_Close from '@salesforce/label/c.EP_Close';
import EP_Filing_Header from '@salesforce/label/c.EP_Filing_Header';
import EP_Financials from '@salesforce/label/c.EP_Financials';
import EP_Documents from '@salesforce/label/c.EP_Documents';
import EP_Validation_Attestation from '@salesforce/label/c.EP_Validation_Attestation';
import EP_Submit from '@salesforce/label/c.EP_Submit';
import EP_Open_Filing_Wizard from '@salesforce/label/c.EP_Open_Filing_Wizard';
import EP_Continue_To_Submit from '@salesforce/label/c.EP_Continue_To_Submit';
import EP_Edit from '@salesforce/label/c.EP_Edit';
import EP_Evidence from '@salesforce/label/c.EP_Evidence';
import EP_Workflow from '@salesforce/label/c.EP_Workflow';
import EP_Description from '@salesforce/label/c.EP_Description';
import EP_Statements from '@salesforce/label/c.EP_Statements';
import EP_Assets from '@salesforce/label/c.EP_Assets';
import EP_Liabilities from '@salesforce/label/c.EP_Liabilities';
import EP_Editable_Draft from '@salesforce/label/c.EP_Editable_Draft';
import EP_Complete from '@salesforce/label/c.EP_Complete';
import EP_Not_Complete from '@salesforce/label/c.EP_Not_Complete';
import EP_Save_Draft from '@salesforce/label/c.EP_Save_Draft';
import EP_Save_And_Submit from '@salesforce/label/c.EP_Save_And_Submit';
import EP_Draft_Created from '@salesforce/label/c.EP_Draft_Created';
import EP_Setup_Updated from '@salesforce/label/c.EP_Setup_Updated';
import EP_No_Filing_Available from '@salesforce/label/c.EP_No_Filing_Available';
import EP_Staff_Analysis_Opened from '@salesforce/label/c.EP_Staff_Analysis_Opened';
import EP_Something_Went_Wrong from '@salesforce/label/c.EP_Something_Went_Wrong';
import EP_Upload_Before_Save from '@salesforce/label/c.EP_Upload_Before_Save';
import EP_Complete_Attestation from '@salesforce/label/c.EP_Complete_Attestation';
import EP_Upload_Before_Submit from '@salesforce/label/c.EP_Upload_Before_Submit';
import EP_No_Document_Attached from '@salesforce/label/c.EP_No_Document_Attached';
import EP_Statements_Removed from '@salesforce/label/c.EP_Statements_Removed';
import EP_Statements_Removed_Draft from '@salesforce/label/c.EP_Statements_Removed_Draft';
import EP_No_Document_To_Remove from '@salesforce/label/c.EP_No_Document_To_Remove';
import EP_Opening_Next_Step from '@salesforce/label/c.EP_Opening_Next_Step';
import EP_No_Filing_To_Edit from '@salesforce/label/c.EP_No_Filing_To_Edit';
import EP_Filing_Details from '@salesforce/label/c.EP_Filing_Details';
import EP_No_Document_Name from '@salesforce/label/c.EP_No_Document_Name';
import EP_Workflow_Draft from '@salesforce/label/c.EP_Workflow_Draft';
import EP_Workflow_Submitted from '@salesforce/label/c.EP_Workflow_Submitted';
import EP_Workflow_Accepted from '@salesforce/label/c.EP_Workflow_Accepted';
import EP_Workflow_Rejected from '@salesforce/label/c.EP_Workflow_Rejected';
import EP_Record_Singular from '@salesforce/label/c.EP_Record_Singular';
import EP_Record_Plural from '@salesforce/label/c.EP_Record_Plural';
import EP_Annual_Statements_Doc from '@salesforce/label/c.EP_Annual_Statements_Doc';
import EP_Upload_Or_Replace from '@salesforce/label/c.EP_Upload_Or_Replace';
import EP_Current_Filing_Evidence from '@salesforce/label/c.EP_Current_Filing_Evidence';
import EP_Required_Star from '@salesforce/label/c.EP_Required_Star';
import EP_Period from '@salesforce/label/c.EP_Period';
import EP_Header from '@salesforce/label/c.EP_Header';
import EP_Validation from '@salesforce/label/c.EP_Validation';
import EP_Attest_Confirm from '@salesforce/label/c.EP_Attest_Confirm';
import EP_NB_Premiums_Short from '@salesforce/label/c.EP_NB_Premiums_Short';
import EP_Email from '@salesforce/label/c.EP_Email';
import EP_Phone from '@salesforce/label/c.EP_Phone';
import EP_Request_Missing_Schedule from '@salesforce/label/c.EP_Request_Missing_Schedule';
import EP_Missing_Schedule_Submitted from '@salesforce/label/c.EP_Missing_Schedule_Submitted';
import EP_Missing_Schedule_Caption from '@salesforce/label/c.EP_Missing_Schedule_Caption';
import EP_Previously_Uploaded from '@salesforce/label/c.EP_Previously_Uploaded';
import EP_Download from '@salesforce/label/c.EP_Download';
import EP_Save_Updated_Filing from '@salesforce/label/c.EP_Save_Updated_Filing';
import EP_Edit_Missing_Schedule from '@salesforce/label/c.EP_Edit_Missing_Schedule';
import EP_Workflow_Request_Missing_Schedule from '@salesforce/label/c.EP_Workflow_Request_Missing_Schedule';
import EP_Workflow_Missing_Schedule_Submitted from '@salesforce/label/c.EP_Workflow_Missing_Schedule_Submitted';

const ACCEPTED = '.pdf,.doc,.docx,.xls,.xlsx,.csv,.png,.jpg,.jpeg,.gif,.bmp,.webp,.heic';
const STATUS_REQUEST_MISSING = 'Request Missing Schedule';
const STATUS_MISSING_SUBMITTED = 'Missing Schedule Submitted';

export default class EmpFinancialFilings extends LightningElement {
    @track labels = {
        expand: EP_Expand,
        collapse: EP_Collapse,
        allAnnualFinancialFilings: EP_All_Annual_Financial_Filings,
        showingAllFilings: EP_Showing_All_Filings,
        draft: EP_Draft,
        submitted: EP_Submitted,
        accepted: EP_Accepted,
        rejected: EP_Rejected,
        requestMissingSchedule: EP_Request_Missing_Schedule,
        missingScheduleSubmitted: EP_Missing_Schedule_Submitted,
        missingScheduleCaption: EP_Missing_Schedule_Caption,
        previouslyUploaded: EP_Previously_Uploaded,
        download: EP_Download,
        saveUpdatedFiling: EP_Save_Updated_Filing,
        editMissingSchedule: EP_Edit_Missing_Schedule,
        workflowRequestMissingSchedule: EP_Workflow_Request_Missing_Schedule,
        workflowMissingScheduleSubmitted: EP_Workflow_Missing_Schedule_Submitted,
        financialFilingRequirements: EP_Financial_Filing_Requirements,
        annualFinancialFilingRequirementsFor: EP_Annual_Financial_Filing_Requirements_For,
        portalHome: EP_Portal_Home,
        filings: EP_Filings,
        openFiling: EP_Open_Filing,
        addAnnualFiling: EP_Add_Annual_Filing,
        parentLicence: EP_Parent_Licence,
        filingType: EP_Filing_Type,
        reportingYear: EP_Reporting_Year,
        due: EP_Due,
        currentFiling: EP_Current_Filing,
        inProgress: EP_In_Progress,
        underReview: EP_Under_Review,
        completed: EP_Completed,
        actionRequired: EP_Action_Required,
        clearFilter: EP_Clear_Filter,
        showAll: EP_Show_All,
        filingTransactions: EP_Filing_Transactions,
        filer: EP_Filer,
        dueDate: EP_Due_Date,
        premiumsNb: EP_Premiums_NB,
        editDraft: EP_Edit_Draft,
        viewDetails: EP_View_Details,
        noFilingsUnderStatus: EP_No_Filings_Under_Status,
        whatMustBeSubmitted: EP_What_Must_Be_Submitted,
        filingRequirementsChecklist: EP_Filing_Requirements_Checklist,
        required: EP_Required,
        optional: EP_Optional,
        reportingPeriod: EP_Reporting_Period,
        checklistReportingPeriodDesc: EP_Checklist_Reporting_Period_Desc,
        filerContact: EP_Filer_Contact,
        checklistFilerContactDesc: EP_Checklist_Filer_Contact_Desc,
        checklistFinancialAmounts: EP_Checklist_Financial_Amounts,
        checklistFinancialAmountsDesc: EP_Checklist_Financial_Amounts_Desc,
        annualStatements: EP_Annual_Statements,
        checklistAnnualStatementsDesc: EP_Checklist_Annual_Statements_Desc,
        attestation: EP_Attestation,
        checklistAttestationDesc: EP_Checklist_Attestation_Desc,
        checklistCertification: EP_Checklist_Certification,
        checklistCertificationDesc: EP_Checklist_Certification_Desc,
        requirementProfile: EP_Requirement_Profile,
        filingSetup: EP_Filing_Setup,
        editFilingSetup: EP_Edit_Filing_Setup,
        filingId: EP_Filing_ID,
        status: EP_Status,
        licenceType: EP_Licence_Type,
        requiredFinancialValues: EP_Required_Financial_Values,
        field: EP_Field,
        value: EP_Value,
        totalAssets: EP_Total_Assets,
        totalLiabilities: EP_Total_Liabilities,
        writtenPremiumsNb: EP_Written_Premiums_NB,
        otherNbAmounts: EP_Other_NB_Amounts,
        yes: EP_Yes,
        no: EP_No,
        asConfigured: EP_As_Configured,
        documentsEvidence: EP_Documents_Evidence,
        uploadDocument: EP_Upload_Document,
        uploadAnnualStatementsDesc: EP_Upload_Annual_Statements_Desc,
        createFilingFirst: EP_Create_Filing_First,
        acceptedFileTypes: EP_Accepted_File_Types,
        uploadedToFiles: EP_Uploaded_To_Files,
        preview: EP_Preview,
        remove: EP_Remove,
        annualStatementsRequired: EP_Annual_Statements_Required,
        uploadEvidence: EP_Upload_Evidence,
        submissionRule: EP_Submission_Rule,
        staffReadyView: EP_Staff_Ready_View,
        financialAnalysis: EP_Financial_Analysis,
        openStaffAnalysis: EP_Open_Staff_Analysis,
        nbWrittenPremiums: EP_NB_Written_Premiums,
        reviewRequirement: EP_Review_Requirement,
        heroSub: EP_Hero_Sub,
        annualFinancialFiling: EP_Annual_Financial_Filing,
        addAnnualFilingHelp: EP_Add_Annual_Filing_Help,
        createDraft: EP_Create_Draft,
        periodStart: EP_Period_Start,
        periodEnd: EP_Period_End,
        searchLicensePlaceholder: EP_Search_License_Placeholder,
        searchByLicenseHint: EP_Search_By_License_Hint,
        noMatchingLicenses: EP_No_Matching_Licenses,
        selectParentLicence: EP_Select_Parent_Licence,
        cancel: EP_Cancel,
        editFilingSetupHelp: EP_Edit_Filing_Setup_Help,
        filerAccount: EP_Filer_Account,
        filerFirstName: EP_Filer_First_Name,
        filerLastName: EP_Filer_Last_Name,
        filerEmail: EP_Filer_Email,
        filerPhone: EP_Filer_Phone,
        saveChanges: EP_Save_Changes,
        close: EP_Close,
        filingHeader: EP_Filing_Header,
        financials: EP_Financials,
        documents: EP_Documents,
        validationAttestation: EP_Validation_Attestation,
        submit: EP_Submit,
        openFilingWizard: EP_Open_Filing_Wizard,
        continueToSubmit: EP_Continue_To_Submit,
        edit: EP_Edit,
        evidence: EP_Evidence,
        workflow: EP_Workflow,
        description: EP_Description,
        statements: EP_Statements,
        assets: EP_Assets,
        liabilities: EP_Liabilities,
        editableDraft: EP_Editable_Draft,
        complete: EP_Complete,
        notComplete: EP_Not_Complete,
        saveDraft: EP_Save_Draft,
        saveAndSubmit: EP_Save_And_Submit,
        draftCreated: EP_Draft_Created,
        setupUpdated: EP_Setup_Updated,
        noFilingAvailable: EP_No_Filing_Available,
        staffAnalysisOpened: EP_Staff_Analysis_Opened,
        somethingWentWrong: EP_Something_Went_Wrong,
        uploadBeforeSave: EP_Upload_Before_Save,
        completeAttestation: EP_Complete_Attestation,
        uploadBeforeSubmit: EP_Upload_Before_Submit,
        noDocumentAttached: EP_No_Document_Attached,
        statementsRemoved: EP_Statements_Removed,
        statementsRemovedDraft: EP_Statements_Removed_Draft,
        noDocumentToRemove: EP_No_Document_To_Remove,
        openingNextStep: EP_Opening_Next_Step,
        noFilingToEdit: EP_No_Filing_To_Edit,
        filingDetails: EP_Filing_Details,
        noDocumentName: EP_No_Document_Name,
        workflowDraft: EP_Workflow_Draft,
        workflowSubmitted: EP_Workflow_Submitted,
        workflowAccepted: EP_Workflow_Accepted,
        workflowRejected: EP_Workflow_Rejected,
        recordSingular: EP_Record_Singular,
        recordPlural: EP_Record_Plural,
        annualStatementsDoc: EP_Annual_Statements_Doc,
        uploadOrReplace: EP_Upload_Or_Replace,
        currentFilingEvidence: EP_Current_Filing_Evidence,
        requiredStar: EP_Required_Star,
        period: EP_Period,
        header: EP_Header,
        validation: EP_Validation,
        attestConfirm: EP_Attest_Confirm,
        nbPremiumsShort: EP_NB_Premiums_Short,
        email: EP_Email,
        phone: EP_Phone
    };

    @track filings = [];
    @track filteredFilings = [];
    @track currentFiling = null;
    @track statusFilter = '';
    @track checklistCollapsed = false;
    @track toastMessage = '';
    @track toastClass = 'toast info hidden';
    @track isLoading = true;
    @track accountName = 'Employer Account';
    @track parentLicence = '';
    @track licenceType = 'Insurance Company';
    @track filingType = 'Annual Financial Filing';
    @track countDraft = 0;
    @track countSubmitted = 0;
    @track countAccepted = 0;
    @track countRejected = 0;
    @track countRequestMissingSchedule = 0;
    @track countMissingScheduleSubmitted = 0;
    @track previousFiles = [];
    @track editSessionHasNewUpload = false;

    @track showAddModal = false;
    @track showEditModal = false;
    @track showOpenModal = false;
    @track showDetailModal = false;
    @track detailMode = 'view';
    @track selectedFiling = null;
    @track dropzoneClass = 'dropzone';
    @track editDropzoneClass = 'edit-dropzone';

    @track licenceSuggestions = [];
    @track showAddLicenceSuggestions = false;
    @track showEditLicenceSuggestions = false;

    newYear = '2025';
    newStart = '2025-01-01';
    newEnd = '2025-12-31';
    newParentLicence = '';
    newBusinessLicenseId = null;

    editYear = '';
    editStart = '';
    editEnd = '';
    editDue = '';
    editFirst = '';
    editLast = '';
    editEmail = '';
    editPhone = '';
    editParentLicence = '';
    editBusinessLicenseId = null;

    draftYear = '';
    draftDue = '';
    draftStart = '';
    draftEnd = '';
    draftFirst = '';
    draftLast = '';
    draftEmail = '';
    draftPhone = '';
    draftAssets = '';
    draftLiabilities = '';
    draftPremiums = '';
    draftAttestation = 'Complete';

    acceptedFormats = ACCEPTED;
    toastTimer;
    licenceSearchTimer;

    connectedCallback() {
        this.loadTranslatedLabels().finally(() => this.loadData());
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
        const apiNames = LABEL_API_NAMES.filter((n) => !n.startsWith('EP_SIR_'));
        try {
            const apiMap = await getLabels({ apiNames, language: lang });
            this.labels = { ...this.labels, ...mapApiToCamel(apiMap) };
        } catch (e) {
            // keep imported English defaults
        }
    }

    get hasLicenceSuggestions() {
        return this.licenceSuggestions && this.licenceSuggestions.length > 0;
    }

    translateStatus(status) {
        const map = {
            Draft: this.labels?.draft || 'Draft',
            Submitted: this.labels?.submitted || 'Submitted',
            Accepted: this.labels?.accepted || 'Accepted',
            Rejected: this.labels?.rejected || 'Rejected',
            [STATUS_REQUEST_MISSING]: this.labels?.requestMissingSchedule || STATUS_REQUEST_MISSING,
            [STATUS_MISSING_SUBMITTED]: this.labels?.missingScheduleSubmitted || STATUS_MISSING_SUBMITTED
        };
        return map[status] || status || '';
    }

    get toggleLabel() {
        return this.checklistCollapsed ? this.labels.expand : this.labels.collapse;
    }

    get checklistBodyClass() {
        return this.checklistCollapsed ? 'body hidden' : 'body';
    }

    get applicationsTitle() {
        return this.statusFilter ? `${this.translateStatus(this.statusFilter)} ${this.labels.filings}` : this.labels.allAnnualFinancialFilings;
    }

    get statusFilterText() {
        if (!this.statusFilter) {
            return this.labels.showingAllFilings;
        }
        const n = this.filteredFilings.length;
        return `${this.translateStatus(this.statusFilter)} ${this.labels.filings}: ${n} ${n === 1 ? this.labels.recordSingular : this.labels.recordPlural}`;
    }

    get hasFilings() {
        return this.filteredFilings && this.filteredFilings.length > 0;
    }

    get emptyAppsClass() {
        return this.hasFilings ? 'empty-apps hidden' : 'empty-apps';
    }

    get heroTitle() {
        const year = this.currentFiling?.reportingYear || '2025';
        return `${this.labels.annualFinancialFiling} — ${year}`;
    }

    get filingTypeLabel() {
        if (!this.filingType || this.filingType === 'Annual Financial Filing') {
            return this.labels.annualFinancialFiling;
        }
        return this.filingType;
    }

    get heroCurrentId() {
        return this.currentFiling?.name || '—';
    }

    get heroDue() {
        return this.currentFiling?.dueDateLabel || '31 Mar 2026';
    }

    get heroYear() {
        return this.currentFiling?.reportingYear || '2025';
    }

    get setupStatus() {
        return this.translateStatus(this.currentFiling?.status || 'Draft');
    }

    get setupFilingId() {
        return this.currentFiling?.name || '—';
    }

    get setupAssets() {
        return this.formatMoney(this.currentFiling?.totalAssets);
    }

    get setupLiabilities() {
        return this.formatMoney(this.currentFiling?.totalLiabilities);
    }

    get setupPremiums() {
        return this.formatMoney(this.currentFiling?.nbWrittenPremiums);
    }

    get metricAssets() {
        return this.formatCompact(this.currentFiling?.totalAssets);
    }

    get metricLiabilities() {
        return this.formatCompact(this.currentFiling?.totalLiabilities);
    }

    get metricPremiums() {
        return this.formatCompact(this.currentFiling?.nbWrittenPremiums);
    }

    get assetsBarStyle() {
        return `width:${this.barWidth(this.currentFiling?.totalAssets, 150000000)}%`;
    }

    get liabilitiesBarStyle() {
        return `width:${this.barWidth(this.currentFiling?.totalLiabilities, 150000000)}%`;
    }

    get premiumsBarStyle() {
        return `width:${this.barWidth(this.currentFiling?.nbWrittenPremiums, 15000000)}%`;
    }

    get hasUploadedDoc() {
        return !!(this.currentFiling && this.currentFiling.contentDocumentId);
    }

    get uploadedDocumentName() {
        return this.currentFiling?.documentName || '';
    }

    get uploadedDocClass() {
        return this.hasUploadedDoc ? 'uploaded-doc' : 'uploaded-doc hidden';
    }

    get sampleDocClass() {
        return this.hasUploadedDoc ? 'sample-doc hidden' : 'sample-doc';
    }

    get hasSelectedFiling() {
        return !!this.selectedFiling;
    }

    get selectedDocumentName() {
        return this.selectedFiling?.documentName || '';
    }

    get hasSelectedDocument() {
        return !!(
            this.selectedFiling?.contentDocumentId &&
            this.selectedDocumentName &&
            String(this.selectedDocumentName).trim()
        );
    }

    /**
     * Preview/Remove row shows only after a file exists with a real name.
     * For Request Missing Schedule, existing files stay in "Previously uploaded";
     * this row appears only after a new upload in the current edit session.
     */
    get showCurrentEditDocument() {
        if (!this.hasSelectedDocument) {
            return false;
        }
        if (this.selectedIsRequestMissing) {
            return this.editSessionHasNewUpload;
        }
        return true;
    }

    get selectedIsDraft() {
        return !!this.selectedFiling?.isDraft;
    }

    get selectedIsEditable() {
        return !!this.selectedFiling?.isEditable;
    }

    get selectedIsRequestMissing() {
        return !!this.selectedFiling?.isRequestMissingSchedule;
    }

    get isDraftAttestationComplete() {
        return this.normalizeAttestation(this.draftAttestation) === 'Complete';
    }

    get isDraftAttestationNotComplete() {
        return !this.isDraftAttestationComplete;
    }

    get hasPreviousFiles() {
        return Array.isArray(this.previousFiles) && this.previousFiles.length > 0;
    }

    get editModalTitle() {
        if (this.selectedIsRequestMissing) {
            return `${this.labels.editMissingSchedule || this.labels.edit} — ${this.selectedFiling?.name || ''}`;
        }
        return `Edit Draft — ${this.selectedFiling?.name || ''}`;
    }

    get selectedFilingId() {
        return this.selectedFiling?.id || '';
    }

    get selectedReportingYear() {
        return this.selectedFiling?.reportingYear || '';
    }

    get selectedPeriodLabel() {
        return this.selectedFiling?.periodLabel || '';
    }

    get selectedDueDateLabel() {
        return this.selectedFiling?.dueDateLabel || '';
    }

    get selectedParentLicence() {
        return this.selectedFiling?.parentLicence || '';
    }

    get selectedFilerName() {
        return this.selectedFiling?.filerName || '';
    }

    get selectedFilerEmail() {
        return this.selectedFiling?.filerEmail || '';
    }

    get selectedFilerPhone() {
        return this.selectedFiling?.filerPhone || '';
    }

    get selectedAssetsLabel() {
        return this.selectedFiling?.assetsLabel || '';
    }

    get selectedLiabilitiesLabel() {
        return this.selectedFiling?.liabilitiesLabel || '';
    }

    get selectedPremiumsLabel() {
        return this.selectedFiling?.premiumsLabel || '';
    }

    get selectedAttestation() {
        return this.selectedFiling?.attestation || '';
    }

    get selectedDescription() {
        return this.selectedFiling?.description || '';
    }

    get uploadRecordId() {
        return this.currentFiling?.id;
    }

    get editUploadRecordId() {
        return this.selectedFiling?.id;
    }

    get detailTitle() {
        if (!this.selectedFiling) {
            return this.labels.filingDetails;
        }
        if (this.detailMode === 'edit') {
            return `Edit Draft — ${this.selectedFiling.name}`;
        }
        return `${this.selectedFiling.name} — ${this.selectedFiling.status}`;
    }

    get isDetailEdit() {
        return this.detailMode === 'edit' && !!this.selectedFiling;
    }

    get isDetailView() {
        return this.detailMode === 'view' && !!this.selectedFiling;
    }

    get openYear() {
        return this.currentFiling?.reportingYear || '';
    }

    get openPeriod() {
        return this.currentFiling?.periodLabel || '';
    }

    get openDue() {
        return this.currentFiling?.dueDateLabel || '';
    }

    get openFiler() {
        return this.currentFiling?.filerName || '';
    }

    get openAssets() {
        return this.formatMoney(this.currentFiling?.totalAssets);
    }

    get openLiabilities() {
        return this.formatMoney(this.currentFiling?.totalLiabilities);
    }

    get openPremiums() {
        return this.formatMoney(this.currentFiling?.nbWrittenPremiums);
    }

    get openDocName() {
        return this.currentFiling?.documentName || this.labels.noDocumentName;
    }

    get draftCardClass() {
        return this.statusFilter === 'Draft' ? 'status-card draft active' : 'status-card draft';
    }

    get submittedCardClass() {
        return this.statusFilter === 'Submitted' ? 'status-card submitted active' : 'status-card submitted';
    }

    get acceptedCardClass() {
        return this.statusFilter === 'Accepted' ? 'status-card accepted active' : 'status-card accepted';
    }

    get rejectedCardClass() {
        return this.statusFilter === 'Rejected' ? 'status-card rejected active' : 'status-card rejected';
    }

    get requestMissingCardClass() {
        return this.statusFilter === STATUS_REQUEST_MISSING
            ? 'status-card missing-schedule active'
            : 'status-card missing-schedule';
    }

    get missingSubmittedCardClass() {
        return this.statusFilter === STATUS_MISSING_SUBMITTED
            ? 'status-card missing-submitted active'
            : 'status-card missing-submitted';
    }

    get yearOptions() {
        return [
            { label: '2025', value: '2025' },
            { label: '2026', value: '2026' },
            { label: '2027', value: '2027' }
        ];
    }

    get attestationOptions() {
        return [
            { label: this.labels.complete, value: 'Complete' },
            { label: this.labels.notComplete, value: 'Not Complete' }
        ];
    }

    get workflowMessage() {
        const f = this.selectedFiling;
        if (!f) {
            return '';
        }
        if (f.status === 'Submitted') {
            return this.labels.workflowSubmitted;
        }
        if (f.status === 'Accepted') {
            return this.labels.workflowAccepted;
        }
        if (f.status === 'Rejected') {
            return this.labels.workflowRejected;
        }
        if (f.status === STATUS_REQUEST_MISSING) {
            return this.labels.workflowRequestMissingSchedule;
        }
        if (f.status === STATUS_MISSING_SUBMITTED) {
            return this.labels.workflowMissingScheduleSubmitted;
        }
        return this.labels.workflowDraft;
    }

    async loadData() {
        this.isLoading = true;
        try {
            const result = await getFilings();
            this.accountName = result.accountName || this.accountName;
            this.parentLicence = result.parentLicence || this.parentLicence;
            this.licenceType = result.licenceType || this.licenceType;
            this.filingType = result.filingType || this.filingType;
            this.countDraft = result.countDraft || 0;
            this.countSubmitted = result.countSubmitted || 0;
            this.countAccepted = result.countAccepted || 0;
            this.countRejected = result.countRejected || 0;
            this.countRequestMissingSchedule = result.countRequestMissingSchedule || 0;
            this.countMissingScheduleSubmitted = result.countMissingScheduleSubmitted || 0;
            this.filings = (result.filings || []).map((f) => this.decorateFiling(f));
            this.currentFiling = result.currentFiling
                ? this.decorateFiling(result.currentFiling)
                : this.filings[0] || null;
            if (this.currentFiling?.parentLicence) {
                this.parentLicence = this.currentFiling.parentLicence;
            } else if (result.parentLicence) {
                this.parentLicence = result.parentLicence;
            }
            this.applyFilter();
        } catch (e) {
            this.showToast(this.errorMessage(e), 'info');
        } finally {
            this.isLoading = false;
        }
    }

    decorateFiling(f) {
        const status = f.status || 'Draft';
        return {
            ...f,
            chipClass: `chip ${this.statusKey(status)}`,
            isDraft: status === 'Draft',
            isRequestMissingSchedule: status === STATUS_REQUEST_MISSING,
            isEditable: status === 'Draft' || status === STATUS_REQUEST_MISSING,
            statusLabel: this.translateStatus(status),
            assetsLabel: this.formatMoney(f.totalAssets),
            premiumsLabel: this.formatMoney(f.nbWrittenPremiums),
            liabilitiesLabel: this.formatMoney(f.totalLiabilities)
        };
    }

    statusKey(s) {
        if (s === 'Accepted') return 'green';
        if (s === 'Rejected' || s === STATUS_REQUEST_MISSING) return 'red';
        if (s === 'Submitted' || s === STATUS_MISSING_SUBMITTED) return 'blue';
        return 'orange';
    }

    applyFilter() {
        this.filteredFilings = this.statusFilter
            ? this.filings.filter((f) => f.status === this.statusFilter)
            : [...this.filings];
    }

    formatMoney(n) {
        if (n === null || n === undefined || n === '') {
            return '—';
        }
        return (
            '$' +
            Number(n).toLocaleString('en-CA', {
                maximumFractionDigits: 0
            })
        );
    }

    formatCompact(n) {
        if (n === null || n === undefined || n === '') {
            return '—';
        }
        const val = Number(n);
        if (val >= 1000000) {
            return `$${(val / 1000000).toFixed(1)}M`;
        }
        return this.formatMoney(val);
    }

    barWidth(value, max) {
        const v = Number(value || 0);
        const m = Number(max || 1);
        return Math.max(4, Math.min(100, Math.round((v / m) * 100)));
    }

    toIsoDate(d) {
        if (!d) return '';
        if (typeof d === 'string') {
            return d.substring(0, 10);
        }
        const dt = new Date(d);
        if (Number.isNaN(dt.getTime())) {
            return '';
        }
        const mm = String(dt.getUTCMonth() + 1).padStart(2, '0');
        const dd = String(dt.getUTCDate()).padStart(2, '0');
        return `${dt.getUTCFullYear()}-${mm}-${dd}`;
    }

    showToast(msg, type = 'info') {
        this.toastMessage = msg;
        this.toastClass = `toast show ${type}`;
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        clearTimeout(this.toastTimer);
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        this.toastTimer = setTimeout(() => {
            this.toastClass = 'toast info hidden';
        }, 3200);
    }

    errorMessage(e) {
        return e?.body?.message || e?.message || this.labels.somethingWentWrong;
    }

    handleToggleChecklist() {
        this.checklistCollapsed = !this.checklistCollapsed;
    }

    handleStatusFilter(event) {
        const status = event.currentTarget.dataset.status;
        this.statusFilter = status;
        this.applyFilter();
        this.showToast(
            `${status}: ${this.filings.filter((f) => f.status === status).length} filing(s) shown below.`,
            'info'
        );
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        setTimeout(() => {
            const panel = this.template.querySelector('[data-id="applicationsPanel"]');
            if (panel) {
                panel.scrollIntoView({ behavior: 'smooth', block: 'start' });
            }
        }, 50);
    }

    handleClearFilter() {
        this.statusFilter = '';
        this.applyFilter();
    }

    handleOpenAdd() {
        this.newYear = '2025';
        this.newStart = '2025-01-01';
        this.newEnd = '2025-12-31';
        this.newParentLicence = '';
        this.newBusinessLicenseId = null;
        this.licenceSuggestions = [];
        this.showAddLicenceSuggestions = false;
        this.showAddModal = true;
    }

    handleCloseAdd() {
        this.showAddModal = false;
        this.showAddLicenceSuggestions = false;
    }

    handleAddLicenceSearch(event) {
        this.newParentLicence = event.target.value;
        this.newBusinessLicenseId = null;
        this.debounceLicenceSearch(this.newParentLicence, 'add');
    }

    handleAddLicenceFocus() {
        this.showAddLicenceSuggestions = true;
        this.runLicenceSearch(this.newParentLicence, 'add');
    }

    handleEditLicenceSearch(event) {
        this.editParentLicence = event.target.value;
        this.editBusinessLicenseId = null;
        this.debounceLicenceSearch(this.editParentLicence, 'edit');
    }

    handleEditLicenceFocus() {
        this.showEditLicenceSuggestions = true;
        this.runLicenceSearch(this.editParentLicence, 'edit');
    }

    handleLicenceBlur() {
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        setTimeout(() => {
            this.showAddLicenceSuggestions = false;
            this.showEditLicenceSuggestions = false;
        }, 150);
    }

    handleLicenceSelect(event) {
        const id = event.currentTarget.dataset.id;
        const name = event.currentTarget.dataset.name;
        const context = event.currentTarget.dataset.context;
        if (context === 'edit') {
            this.editParentLicence = name;
            this.editBusinessLicenseId = id;
            this.showEditLicenceSuggestions = false;
        } else {
            this.newParentLicence = name;
            this.newBusinessLicenseId = id;
            this.showAddLicenceSuggestions = false;
        }
        this.licenceSuggestions = [];
    }

    debounceLicenceSearch(term, context) {
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        clearTimeout(this.licenceSearchTimer);
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        this.licenceSearchTimer = setTimeout(() => {
            this.runLicenceSearch(term, context);
        }, 250);
    }

    async runLicenceSearch(term, context) {
        try {
            const results = await searchBusinessLicenses({ searchTerm: term || '' });
            this.licenceSuggestions = results || [];
            if (context === 'edit') {
                this.showEditLicenceSuggestions = true;
            } else {
                this.showAddLicenceSuggestions = true;
            }
        } catch (e) {
            this.licenceSuggestions = [];
            this.showToast(this.errorMessage(e), 'info');
        }
    }

    handleNewYear(event) {
        this.newYear = event.target.value;
        const y = Number(this.newYear) || 2025;
        this.newStart = `${y}-01-01`;
        this.newEnd = `${y}-12-31`;
    }

    handleNewStart(event) {
        this.newStart = event.target.value;
    }

    handleNewEnd(event) {
        this.newEnd = event.target.value;
    }

    async handleCreateDraft() {
        if (!this.newParentLicence || !this.newParentLicence.trim()) {
            this.showToast(this.labels.selectParentLicence, 'info');
            return;
        }
        try {
            const created = await createFiling({
                reportingYear: this.newYear,
                periodStart: this.newStart,
                periodEnd: this.newEnd,
                parentLicence: this.newParentLicence.trim(),
                businessLicenseId: this.newBusinessLicenseId
            });
            this.showAddModal = false;
            this.showToast(this.labels.draftCreated.replace('{0}', created?.name || '').replace('{1}', this.newYear), 'success');
            await this.loadData();
        } catch (e) {
            this.showToast(this.errorMessage(e), 'info');
        }
    }

    handleOpenFiling() {
        if (!this.currentFiling) {
            this.showToast(this.labels.noFilingAvailable, 'info');
            return;
        }
        this.selectedFiling = this.currentFiling;
        this.detailMode = 'view';
        this.showDetailModal = true;
    }

    handleOpenWizard() {
        if (!this.currentFiling) {
            this.showToast(this.labels.noFilingAvailable, 'info');
            return;
        }
        this.showOpenModal = true;
    }

    handleCloseOpen() {
        this.showOpenModal = false;
    }

    handleOpenContinue() {
        this.showOpenModal = false;
        this.showToast(this.labels.openingNextStep, 'success');
    }

    handleOpenEditFromWizard() {
        this.showOpenModal = false;
        this.openEditSetup();
    }

    openEditSetup() {
        const f = this.currentFiling;
        if (!f) {
            this.showToast(this.labels.noFilingToEdit, 'info');
            return;
        }
        this.editYear = f.reportingYear || '';
        this.editStart = this.toIsoDate(f.periodStart);
        this.editEnd = this.toIsoDate(f.periodEnd);
        this.editDue = this.toIsoDate(f.dueDate);
        this.editFirst = f.filerFirstName || '';
        this.editLast = f.filerLastName || '';
        this.editEmail = f.filerEmail || '';
        this.editPhone = f.filerPhone || '';
        this.editParentLicence = f.parentLicence || this.parentLicence || '';
        this.editBusinessLicenseId = f.businessLicenseId || null;
        this.licenceSuggestions = [];
        this.showEditLicenceSuggestions = false;
        this.showEditModal = true;
    }

    handleEditSetup() {
        this.openEditSetup();
    }

    handleCloseEdit() {
        this.showEditModal = false;
        this.showEditLicenceSuggestions = false;
    }

    handleEditField(event) {
        const field = event.target.dataset.field;
        this[field] = event.target.value;
    }

    async handleSaveSetup() {
        if (!this.currentFiling?.id) {
            return;
        }
        if (!this.editParentLicence || !this.editParentLicence.trim()) {
            this.showToast(this.labels.selectParentLicence, 'info');
            return;
        }
        try {
            await saveFiling({
                payloadJson: JSON.stringify({
                    id: this.currentFiling.id,
                    reportingYear: this.editYear,
                    periodStart: this.editStart,
                    periodEnd: this.editEnd,
                    dueDate: this.editDue,
                    filerFirstName: this.editFirst,
                    filerLastName: this.editLast,
                    filerEmail: this.editEmail,
                    filerPhone: this.editPhone,
                    parentLicence: this.editParentLicence.trim(),
                    businessLicenseId: this.editBusinessLicenseId,
                    status: 'Draft'
                })
            });
            this.showEditModal = false;
            this.showToast(this.labels.setupUpdated, 'success');
            await this.loadData();
        } catch (e) {
            this.showToast(this.errorMessage(e), 'info');
        }
    }

    handleStaffView() {
        this.showToast(this.labels.staffAnalysisOpened, 'info');
    }

    handleViewDetails(event) {
        const id = event.currentTarget.dataset.id;
        const f = this.filings.find((x) => x.id === id);
        if (!f) return;
        this.selectedFiling = f;
        this.detailMode = 'view';
        this.showDetailModal = true;
    }

    handleEditDraft(event) {
        const id = event.currentTarget.dataset.id;
        const f = this.filings.find((x) => x.id === id);
        if (!f || !f.isEditable) return;
        this.selectedFiling = f;
        this.detailMode = 'edit';
        this.editSessionHasNewUpload = false;
        this.draftYear = f.reportingYear || '';
        this.draftDue = this.toIsoDate(f.dueDate);
        this.draftStart = this.toIsoDate(f.periodStart);
        this.draftEnd = this.toIsoDate(f.periodEnd);
        this.draftFirst = f.filerFirstName || '';
        this.draftLast = f.filerLastName || '';
        this.draftEmail = f.filerEmail || '';
        this.draftPhone = f.filerPhone || '';
        this.draftAssets = f.totalAssets != null ? String(f.totalAssets) : '';
        this.draftLiabilities = f.totalLiabilities != null ? String(f.totalLiabilities) : '';
        this.draftPremiums = f.nbWrittenPremiums != null ? String(f.nbWrittenPremiums) : '';
        this.draftAttestation = this.normalizeAttestation(f.attestation);
        this.previousFiles = [];
        this.showDetailModal = true;
        this.loadPreviousFiles(f.id);
    }

    normalizeAttestation(value) {
        const raw = (value == null ? '' : String(value)).trim().toLowerCase();
        if (raw === 'complete' || raw === 'completed' || raw === 'complet') {
            return 'Complete';
        }
        return 'Not Complete';
    }

    syncDraftAttestationFromDom() {
        const selectEl = this.template.querySelector('select[data-field="draftAttestation"]');
        if (selectEl && selectEl.value) {
            this.draftAttestation = this.normalizeAttestation(selectEl.value);
        } else {
            this.draftAttestation = this.normalizeAttestation(this.draftAttestation);
        }
    }

    async loadPreviousFiles(filingId) {
        if (!filingId) {
            this.previousFiles = [];
            return;
        }
        try {
            const files = await getFiles({ filingId });
            this.previousFiles = (files || [])
                .filter((file) => file && file.contentDocumentId)
                .map((file, idx) => {
                    const title = (file.title || '').trim();
                    const extension = (file.extension || '').trim();
                    let displayName = title;
                    if (!displayName) {
                        displayName = extension ? `Document.${extension}` : `Document ${idx + 1}`;
                    } else if (extension && !title.toLowerCase().endsWith('.' + extension.toLowerCase())) {
                        displayName = `${title}.${extension}`;
                    }
                    return {
                        ...file,
                        key: file.contentDocumentId || `file-${idx}`,
                        displayName,
                        downloadUrl: this.buildFileDownloadUrl(file.contentDocumentId, file.contentVersionId)
                    };
                });
        } catch (e) {
            this.previousFiles = [];
        }
    }

    buildFileDownloadUrl(contentDocumentId, contentVersionId) {
        if (!contentDocumentId && !contentVersionId) {
            return null;
        }
        let sitePrefix = '';
        try {
            const path = window.location.pathname || '';
            const sIdx = path.indexOf('/s/');
            if (sIdx > 0) {
                sitePrefix = path.substring(0, sIdx);
            }
        } catch (e) {
            sitePrefix = '';
        }
        if (contentVersionId) {
            return `${sitePrefix}/sfc/servlet.shepherd/version/download/${contentVersionId}`;
        }
        return `${sitePrefix}/sfc/servlet.shepherd/document/download/${contentDocumentId}`;
    }

    handleDownloadPrevious(event) {
        event.preventDefault();
        event.stopPropagation();
        const docId = event.currentTarget.dataset.docId;
        const versionId = event.currentTarget.dataset.versionId;
        const url = this.buildFileDownloadUrl(docId, versionId);
        if (!url) {
            this.showToast(this.labels.noDocumentAttached, 'info');
            return;
        }
        // Force a download navigation in Experience Cloud (window.open can be blocked/ignored).
        const anchor = document.createElement('a');
        anchor.href = url;
        anchor.target = '_blank';
        anchor.rel = 'noopener noreferrer';
        anchor.download = '';
        document.body.appendChild(anchor);
        anchor.click();
        document.body.removeChild(anchor);
    }

    handleCloseDetail() {
        this.showDetailModal = false;
        this.selectedFiling = null;
        this.detailMode = 'view';
        this.editSessionHasNewUpload = false;
        this.previousFiles = [];
    }

    handleDraftField(event) {
        const field = event.target.dataset.field;
        if (!field) {
            return;
        }
        const value = event.target.value;
        this[field] = field === 'draftAttestation' ? this.normalizeAttestation(value) : value;
    }

    async handleSaveDraft() {
        if (!this.selectedFiling?.id) return;
        this.syncDraftAttestationFromDom();
        if (this.selectedIsRequestMissing) {
            await this.handleSaveMissingSchedule();
            return;
        }
        if (!this.selectedFiling.contentDocumentId && !this.selectedFiling.documentName && !this.hasPreviousFiles) {
            this.showToast(this.labels.uploadBeforeSave, 'info');
            return;
        }
        try {
            await saveFiling({
                payloadJson: JSON.stringify({
                    id: this.selectedFiling.id,
                    reportingYear: this.draftYear,
                    periodStart: this.draftStart,
                    periodEnd: this.draftEnd,
                    dueDate: this.draftDue,
                    filerFirstName: this.draftFirst,
                    filerLastName: this.draftLast,
                    filerEmail: this.draftEmail,
                    filerPhone: this.draftPhone,
                    totalAssets: this.draftAssets,
                    totalLiabilities: this.draftLiabilities,
                    nbWrittenPremiums: this.draftPremiums,
                    attestation: this.normalizeAttestation(this.draftAttestation),
                    status: 'Draft',
                    language: readStoredLanguage() || 'en_US'
                })
            });
            this.showDetailModal = false;
            this.showToast(`${this.selectedFiling.name} — ${this.labels.draft}`, 'success');
            await this.loadData();
        } catch (e) {
            this.showToast(this.errorMessage(e), 'info');
        }
    }

    async handleSaveMissingSchedule() {
        if (!this.selectedFiling?.id) return;
        this.syncDraftAttestationFromDom();
        const hasDoc =
            this.hasPreviousFiles ||
            this.selectedFiling.contentDocumentId ||
            this.selectedFiling.documentName;
        if (!hasDoc) {
            this.showToast(this.labels.uploadBeforeSave, 'info');
            return;
        }
        try {
            await saveFiling({
                payloadJson: JSON.stringify({
                    id: this.selectedFiling.id,
                    reportingYear: this.draftYear,
                    periodStart: this.draftStart,
                    periodEnd: this.draftEnd,
                    dueDate: this.draftDue,
                    filerFirstName: this.draftFirst,
                    filerLastName: this.draftLast,
                    filerEmail: this.draftEmail,
                    filerPhone: this.draftPhone,
                    totalAssets: this.draftAssets,
                    totalLiabilities: this.draftLiabilities,
                    nbWrittenPremiums: this.draftPremiums,
                    attestation: this.normalizeAttestation(this.draftAttestation) || 'Complete',
                    status: STATUS_MISSING_SUBMITTED,
                    language: readStoredLanguage() || 'en_US'
                })
            });
            this.showDetailModal = false;
            this.showToast(
                `${this.selectedFiling.name} — ${this.labels.missingScheduleSubmitted}`,
                'success'
            );
            await this.loadData();
        } catch (e) {
            this.showToast(this.errorMessage(e), 'info');
        }
    }

    async handleSubmitDraft() {
        if (!this.selectedFiling?.id) return;
        this.syncDraftAttestationFromDom();
        if (this.selectedIsRequestMissing) {
            await this.handleSaveMissingSchedule();
            return;
        }
        if (this.normalizeAttestation(this.draftAttestation) !== 'Complete') {
            this.showToast(this.labels.completeAttestation, 'info');
            return;
        }
        if (!this.selectedFiling.contentDocumentId && !this.selectedFiling.documentName && !this.hasPreviousFiles) {
            this.showToast(this.labels.uploadBeforeSubmit, 'info');
            return;
        }
        try {
            await saveFiling({
                payloadJson: JSON.stringify({
                    id: this.selectedFiling.id,
                    reportingYear: this.draftYear,
                    periodStart: this.draftStart,
                    periodEnd: this.draftEnd,
                    dueDate: this.draftDue,
                    filerFirstName: this.draftFirst,
                    filerLastName: this.draftLast,
                    filerEmail: this.draftEmail,
                    filerPhone: this.draftPhone,
                    totalAssets: this.draftAssets,
                    totalLiabilities: this.draftLiabilities,
                    nbWrittenPremiums: this.draftPremiums,
                    attestation: 'Complete',
                    status: 'Submitted',
                    language: readStoredLanguage() || 'en_US'
                })
            });
            this.showDetailModal = false;
            this.showToast(
                `${this.selectedFiling.name} — ${this.labels.submitted}`,
                'success'
            );
            await this.loadData();
        } catch (e) {
            this.showToast(this.errorMessage(e), 'info');
        }
    }

    handleUploadFinished(event) {
        const uploaded = event.detail.files || [];
        const name = uploaded[0]?.name || 'Document';
        this.showToast(`${name} — ${this.labels.uploadedToFiles}`, 'success');
        this.loadData();
    }

    handleEditUploadFinished(event) {
        const uploaded = event.detail.files || [];
        const name = uploaded[0]?.name || 'Document';
        if (this.selectedFiling) {
            this.selectedFiling = {
                ...this.selectedFiling,
                documentName: name,
                contentDocumentId: uploaded[0]?.documentId
            };
            this.editSessionHasNewUpload = true;
            this.loadPreviousFiles(this.selectedFiling.id);
        }
        const saveHint = this.selectedIsRequestMissing
            ? this.labels.saveUpdatedFiling
            : `${this.labels.saveDraft} / ${this.labels.saveAndSubmit}`;
        this.showToast(
            `${name} — ${this.labels.uploadedToFiles}. ${saveHint}`,
            'success'
        );
    }

    async handlePreviewUploaded() {
        const docId = this.currentFiling?.contentDocumentId;
        if (!docId) {
            this.showToast(this.labels.noDocumentAttached, 'info');
            return;
        }
        try {
            const url = await getPreviewUrl({ contentDocumentId: docId });
            if (url) {
                window.open(url, '_blank');
            } else {
                this.showToast(`${this.labels.preview}: ${this.currentFiling.documentName}`, 'info');
            }
        } catch (e) {
            this.showToast(this.errorMessage(e), 'info');
        }
    }

    async handleRemoveUploaded() {
        const docId = this.currentFiling?.contentDocumentId;
        const filingId = this.currentFiling?.id;
        if (!docId || !filingId) return;
        try {
            await removeFile({ contentDocumentId: docId, filingId });
            this.showToast(this.labels.statementsRemoved, 'info');
            await this.loadData();
        } catch (e) {
            this.showToast(this.errorMessage(e), 'info');
        }
    }

    async handlePreviewEditDoc() {
        const docId = this.selectedFiling?.contentDocumentId;
        if (!docId) {
            this.showToast(this.labels.noDocumentAttached, 'info');
            return;
        }
        try {
            let versionId = this.selectedFiling?.contentVersionId;
            if (!versionId) {
                const urlFromApex = await getPreviewUrl({ contentDocumentId: docId });
                if (urlFromApex) {
                    window.location.assign(urlFromApex.indexOf('/sfc/') === 0
                        ? this.buildFileDownloadUrl(docId, null)
                        : urlFromApex);
                    return;
                }
            }
            const url = this.buildFileDownloadUrl(docId, versionId);
            if (url) {
                window.location.assign(url);
            }
        } catch (e) {
            this.showToast(this.errorMessage(e), 'info');
        }
    }

    async handleRemoveEditDoc() {
        const docId = this.selectedFiling?.contentDocumentId;
        const filingId = this.selectedFiling?.id;
        if (!docId || !filingId) {
            this.showToast(this.labels.noDocumentToRemove, 'info');
            return;
        }
        try {
            await removeFile({ contentDocumentId: docId, filingId });
            this.selectedFiling = {
                ...this.selectedFiling,
                documentName: null,
                contentDocumentId: null
            };
            this.editSessionHasNewUpload = false;
            await this.loadPreviousFiles(filingId);
            this.showToast(this.labels.statementsRemovedDraft, 'info');
        } catch (e) {
            this.showToast(this.errorMessage(e), 'info');
        }
    }

    handleModalBackdrop(event) {
        if (event.target === event.currentTarget) {
            this.showAddModal = false;
            this.showEditModal = false;
            this.showOpenModal = false;
            this.showDetailModal = false;
        }
    }

    handleOpenFilingWizardFromHero() {
        if (!this.currentFiling) {
            this.showToast(this.labels.noFilingAvailable, 'info');
            return;
        }
        this.showOpenModal = true;
    }
}