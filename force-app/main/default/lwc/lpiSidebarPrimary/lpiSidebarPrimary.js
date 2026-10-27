import { LightningElement, track, wire,api } from 'lwc';
import My_Resource from '@salesforce/resourceUrl/LPI_Design';
//import My_Resource from '@salesforce/resourceUrl/LP_Alpha_Design';
import fetchRegAuthTypeId from '@salesforce/apex/LPI_PreLicensurePetition.fetchRegAuthTypeId';
import { loadScript } from 'lightning/platformResourceLoader';
import { NavigationMixin, CurrentPageReference } from 'lightning/navigation';
import FORM_FACTOR from '@salesforce/client/formFactor';
import updateAcrSelectedOnParentAccount from '@salesforce/apex/LPI_FCDashboardProfileCompletion.updateAcrSelectedOnParentAccount';
import getAcrRecords from '@salesforce/apex/LPI_FCDashboardProfileCompletion.getAcrRecords';
import getPortalNotification from '@salesforce/apex/LPI_NeedYourAttention.getPortalNotification';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import getCurrentLanguage from '@salesforce/apex/EMP_LanguageCtrl.getCurrentLanguage';
import getLabels from '@salesforce/apex/EMP_LanguageCtrl.getLabels';
import {
    LABEL_API_NAMES,
    mapApiToCamel,
    readStoredLanguage,
    writeStoredLanguage,
    PP_LABEL_API_NAMES,
    resolveOmniLanguageCode
} from 'c/lpLanguageUtils';
import {
    LABEL_API_NAMES as ARP_LABEL_API_NAMES,
    mapApiToCamel as arpMapApiToCamel,
    readStoredLanguage as arpReadStoredLanguage,
    writeStoredLanguage as arpWriteStoredLanguage
} from 'c/arpLanguageUtils';
const ESC=27;
const INSURER_REVIEW_STORAGE_KEY = 'emp_insurer_review_page';
const INSURER_REVIEW_EVENT = 'empinsurernavigate';
const ARP_STORAGE_KEY = 'arp_review_page';
const ARP_EVENT_NAME = 'arpreviewnavigate';
const APPLICATION_REVIEW_PAGE = 'Application_Review__c';
const PENSION_STORAGE_KEY = 'avr_pension_page';
const PENSION_EVENT_NAME = 'avrpensionnavigate';
const AVR_FILING_PAGE = 'Add_Edit_AVR_Filing__c';

export default class LpiSidebarPrimary extends NavigationMixin(LightningElement) {

    @track labels = {
        menu: 'Menu',
        help: 'Help',
        dashboard: 'Dashboard',
        selectedAccount: 'Selected Account',
        pleaseSelectAccount: 'Please Select Account',
        new: 'New',
        myTasks: 'My Tasks',
        certifications: 'Licenses',
        myCertifications: 'My Licenses',
        renewCertificate: 'Renew License',
        others: 'Others',
        myApplications: 'My Applications',
        myPayments: 'My Payments',
        myComplaints: 'My Complaints',
        preLicensurePetition: 'Pre-licensure Petition',
        myTasksInfo: '',
        myTasksInfoBtnPrefix: 'My Tasks info button,',
        authEmployeeContact: 'Auth Employee/Auth Contact',
        authEmployeeInfo: '',
        menuOpened: 'Menu Opened',
        menuClosed: 'Menu Closed',
        selectAnAction: 'Select an Action',
        selectActionPrompt: 'Please select the option you want to proceed with',
        newCertification: 'New License',
        newCertificationDesc: 'Initiate the application process for acquiring a new License',
        preLicensePetitionDesc: 'Submit a pre-license petition',
        complaints: 'Complaints',
        complaintsDesc: 'File complaints or grievances related to licensing issues',
        closeSelectAction: 'Close Select an Action',
        cancel: 'Cancel',
        close: 'Close',
        insurerReviewQueue: 'Insurer Review Queue',
        financialFilings: 'Financial Filings',
        premTaxFillings: 'Premium Tax Filings',
        agentReview: 'Agent Review',
        //agentReviewQueue: 'Agent Review Queue',
        agentReviewApplication: 'Agent Review Application',
        orgDashboard: 'Dashboard',
        delegateAccess: 'Delegate Access',
        delegationActivity: 'Delegation Activity',
        organizationAccess: 'Organization Access',
        branchesLocations: 'Branches & Locations',
        sponsoredAgents: 'Sponsored Agents',
        portalPensionFilings: 'Portal Pension Filings',
        pensionFilings: 'Pension Filings',
        avrFiling: 'AVR Filing',
        rmiAdditionalSchedule: 'RMI / Additional Schedule',
        emailNotifications: 'Email Notifications'
    };

    /** Portal context from Experience Cloud URL path. */
    get portalContext() {
        const path =
            typeof window !== 'undefined' && window.location && window.location.pathname
                ? window.location.pathname
                : '';
        if (path.indexOf('/employerportal') !== -1) {
            return 'employer';
        }
        if (path.indexOf('/agentreviewportal') !== -1) {
            return 'agentReview';
        }
        if (path.indexOf('/pensionportal') !== -1) {
            return 'pension';
        }
        return 'licensing';
    }

    get isEmployerPortal() {
        return this.portalContext === 'employer';
    }

    get isAgentReviewPortal() {
        return this.portalContext === 'agentReview';
    }

    get isPensionPortal() {
        return this.portalContext === 'pension';
    }

    get isLicensingPortal() {
        return this.portalContext === 'licensing';
    }

    get showLpiChrome() {
        // All portals share Employer/Licensing sidebar chrome (colors + rail)
        return (
            this.isEmployerPortal ||
            this.isLicensingPortal ||
            this.isAgentReviewPortal ||
            this.isPensionPortal
        );
    }

    get needsExpandedMenuRail() {
        return this.isAgentReviewPortal || this.isPensionPortal || this.isEmployerPortal;
    }

    get showPermitAndLicensing() {
        return this.isLicensingPortal && this.showPermit;
    }

    get showCertificateAndLicensing() {
        return this.isLicensingPortal && this.showCertificate;
    }

    get showHelpAndLicensing() {
        return this.isLicensingPortal && this.showHelp;
    }

    get showSelectionModal() {
        return this.isLicensingPortal && this.openSelectionModal;
    }

    @track insurerReviewPage = 'dashboard';
    @track arpActivePage = 'dashboard';
    @track pensionActivePage = 'list';

    license = My_Resource + '/media/icons/license.svg';
    permit = My_Resource + '/media/icons/permit.svg';
    certificate = My_Resource + '/media/icons/certificate.svg';
    label = My_Resource + '/media/icons/label.svg';
    register = My_Resource + '/media/icons/registration.svg';
    //submenu icons
    homeIcon = My_Resource + '/media/icons/home.svg';
    apps = My_Resource + '/media/icons/apps.svg';
    notificaitonIcon = My_Resource + '/media/icons/notification.svg';
    mylicense = My_Resource + '/media/icons/mylicense.svg';
    renewlicense = My_Resource + '/media/icons/renewlicense.svg';
    amendment = My_Resource + '/media/icons/amendment.svg';
    application = My_Resource + '/media/icons/application.svg';
    payment = My_Resource + '/media/icons/payment.svg';
    laws = My_Resource + '/media/icons/laws.svg';
    laws_blue = My_Resource + '/media/icons/laws_blue.svg';
    complaints = My_Resource + '/media/icons/complaints.svg';
    complaints_blue = My_Resource + '/media/icons/complaints_blue.svg';
    feedback = My_Resource + '/media/icons/feedback.svg';
    feedback_blue = My_Resource + '/media/icons/feedback_blue.svg';
    faq = My_Resource + '/media/icons/faq.svg';
    faq_blue = My_Resource + '/media/icons/faq_blue.svg';
    myaccount_grey = My_Resource + '/media/icons/myaccount_grey.svg';
    myaccount_blue = My_Resource + '/media/icons/myaccount_blue.svg';
    license_grey = My_Resource + '/media/icons/license_grey.svg';
    license_blue = My_Resource + '/media/icons/license_blue.svg';
    address_grey = My_Resource + '/media/icons/address_grey.svg';
    address_blue = My_Resource + '/media/icons/address_blue.svg';
    business_grey = My_Resource + '/media/icons/business_grey.svg';
    business_blue = My_Resource + '/media/icons/business_blue.svg';
    Address_Book_grey = My_Resource + '/media/icons/Address-Book_grey.svg';
    Address_Book_blue = My_Resource + '/media/icons/Address-Book_blue.svg';
    Business_Info_grey = My_Resource + '/media/icons/Business-Info_grey.svg';
    Business_Info_blue = My_Resource + '/media/icons/Business-Info_blue.svg';
    Documents_grey = My_Resource + '/media/icons/Documents_grey.svg';
    Documents_blue = My_Resource + '/media/icons/Documents_blue.svg';
    setting_grey = My_Resource + '/media/icons/settings_grey.svg';
    setting_blue = My_Resource + '/media/icons/settings_blue.svg';
    mycomplaints = My_Resource + '/media/icons/complaints.svg';
    myTask = My_Resource + '/media/icons/myTask.svg';
    selectedAccountName = 'Please Select Account';
    selectedAccountId = '';
    showSelectedAccount = false;
    openSelectionModal = false;
  
    @track showLicense = true;
    @track showPermit = false;
    @track showCertificate = false;
    @track showLabel = false;
    @track showRegister = false;
    @track showUser = false;
    @track showHelp = false;
    isBusinessAccount = false;
    notificationCount = 0;
    isMainBusinessAccount = false;
    taskmsg = '';
    myTaskInfoBtnAriaLabel = '';
    // @track showSidebar = true;
    // renderedCallback(){
    //     // console.log('true',window.location.pathname);
    //     if(window.location.pathname == '/license/s/login/'){
    //         // console.log('false');
    //         this.showSidebar = false;
    //     }
    // }


    @track pageName;
    @track selectedTab;

    @wire(CurrentPageReference)
    getpageRef(pageRef) {
        if (!pageRef) {
            return;
        }
        this.pageName = pageRef.attributes.name;
        if (this.isEmployerPortal) {
            if (this.pageName === APPLICATION_REVIEW_PAGE) {
                this.insurerReviewPage = 'queue';
                return;
            }
            if (this.pageName === 'Home' || this.pageName === 'home') {
                this.insurerReviewPage = this.readInsurerReviewPage() || 'dashboard';
            }
            return;
        }
        if (this.isAgentReviewPortal) {
            if (this.pageName === APPLICATION_REVIEW_PAGE) {
                this.arpActivePage = 'dashboard';
                return;
            }
            if (this.pageName === 'Home' || this.pageName === 'home') {
                const stored = this.readArpPage();
                this.arpActivePage = stored === 'queue' ? 'dashboard' : (stored || 'dashboard');
            }
            return;
        }
        if (this.isPensionPortal) {
            if (this.pageName === AVR_FILING_PAGE) {
                this.pensionActivePage = 'form';
                this.writePensionPage('form');
                return;
            }
            if (this.pageName === 'Home' || this.pageName === 'home') {
                const stored = this.readPensionPage();
                this.pensionActivePage = stored && stored !== 'form' ? stored : 'list';
            }
        }
    }

    connectedCallback() {
        if (this.isAgentReviewPortal) {
            this.arpActivePage = this.readArpPage() || 'dashboard';
            this._onArpNav = (event) => {
                if (event?.detail?.page) {
                    this.arpActivePage = event.detail.page;
                }
            };
            window.addEventListener(ARP_EVENT_NAME, this._onArpNav);
            this.initArpLanguage();
            this.showLicense = true;
            this.isMainBusinessAccount = true;
            return;
        }

        if (this.isPensionPortal) {
            this.pensionActivePage = this.readPensionPage() || 'list';
            this._onPensionNav = (event) => {
                if (event?.detail?.page) {
                    this.pensionActivePage = event.detail.page;
                }
            };
            window.addEventListener(PENSION_EVENT_NAME, this._onPensionNav);
            this.initPensionLanguage();
            this.showLicense = true;
            this.isMainBusinessAccount = true;
            return;
        }

        if (this.isEmployerPortal) {
            this.insurerReviewPage = this.readInsurerReviewPage() || 'dashboard';
            this._onInsurerNav = (event) => {
                if (event?.detail?.page) {
                    this.insurerReviewPage = event.detail.page;
                }
            };
            window.addEventListener(INSURER_REVIEW_EVENT, this._onInsurerNav);
            this.initEmployerLanguage();
            this.showLicense = true;
            this.getAcrRecords();
            return;
        }

        // Licensing Portal (unchanged)
        this.initLanguage();
        if (this.pageName === 'Home' || this.pageName === 'Dashboard__c' || this.pageName == 'My_Licenses__c' 
            || this.pageName == 'Renew_License__c' || this.pageName == 'My_Applications__c' 
            || this.pageName == 'My_Payments__c' || this.pageName == 'My_Business_List__c' || this.pageName == 'My_Complaints__c' || this.pageName == 'My_Tasks__c') {
            this.showLicenseFunction();
        }
        this.getAcrRecords();
        this.getTotalPortalNotification();
        this.step1CSS;
        this.step7CSS;
        this.step6CSS;
        if (this.pageName == 'Dashboard__c') {
            this.showLicense = true;
            this.showUser = false;
            this.showHelp = false;
        }
        else if (this.pageName == 'My_Account__c') {
            this.showLicense = false;
            this.showUser = true;
            this.showHelp = false;
        }
        else if (this.pageName == 'My_Licenses__c') {
            this.showLicense = true;
            this.showUser = false;
            this.showHelp = false;
        }
        if (this.pageName == 'Renew_License__c') {
            this.showLicense = true;
            this.showUser = false;
            this.showHelp = false;
        }
        else if (this.pageName == 'Amendments__c') {
            this.showLicense = true;
            this.showUser = false;
            this.showHelp = false;
        }
        else if (this.pageName == 'My_Applications__c') {
            this.showLicense = true;
            this.showUser = false;
            this.showHelp = false;
        }
        else if (this.pageName == 'My_Payments__c') {
            this.showLicense = true;
            this.showUser = false;
            this.showHelp = false;
        }
        else if (this.pageName == 'Document_Vault__c') {
            this.showLicense = true;
            this.showUser = false;
            this.showHelp = false;
        }
        else if (this.pageName == 'Frequently_Asked_Questions__c') {
            this.showLicense = false;
            this.showUser = false;
            this.showHelp = true;
        }
        else if (this.pageName == 'My_Address_List__c') {
            this.showLicense = false;
            this.showUser = true;
            this.showHelp = false;
        }
        else if (this.pageName == 'My_Business_List__c') {
            this.showLicense = true;
            this.showUser = true;
            this.showHelp = false;
        }
        else if (this.pageName == 'Business_Information__c') {
            this.showLicense = false;
            this.showUser = true;
            this.showHelp = false;
        }
        else if (this.pageName == 'Address_Book__c') {
            this.showLicense = false;
            this.showUser = true;
            this.showHelp = false;
        }
        else if (this.pageName == 'Documents__c') {
            this.showLicense = false;
            this.showUser = true;
            this.showHelp = false;
        }

    }
    getTotalPortalNotification(){
        getPortalNotification({
            accId: null
        })
        .then(result => {
            const data = JSON.parse(JSON.stringify(result));
            this.notificationCount = data.length;
        })
        .catch(error => {
            this.error = error;
        });
    }
    getAcrRecords(){
        getAcrRecords({})
        .then(result => {
            if (result.accList) {
                this.acrList = result.accList;
            }
            if (result.accInfo) {
                this.accountData = result.accInfo;
                if (this.accountData ?.Name) {
                    this.selectedAccountName = this.accountData.Name
                }
                if (this.accountData ?.Id) {
                    this.selectedAccountId = this.accountData.Id;
                    if(this.acrList.length > 0){
                        this.acrList.forEach((item)=>{
                            if(item.Id === this.selectedAccountId){
                                item.showIcon = true;
                            }else{
                                item.showIcon = false;
                            }
                        })
                        //console.log('acrList'+JSON.stringify(this.acrList));
                    }
                }
                if(result.businessAccount == true){
                    this.isBusinessAccount = true;
                }else{
                    this.isBusinessAccount = false;
                }
                if(result.businessAccount == true || (this.acrList != undefined && this.acrList.length == 1)){
                    this.isMainBusinessAccount = true;
                }else{
                    this.isMainBusinessAccount = false;
                }
            } else {
                this.selectedAccountId = '';
                this.selectedAccountName = this.labels.pleaseSelectAccount;
            }
        })
        .catch(error => {
            this.error = error;
        });
    }

    @track menuAriaLabel = '';

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
        lang = lang === 'fr' ? 'fr' : 'en_US';
        writeStoredLanguage(lang);
        try {
            const apiMap = await getLabels({
                apiNames: LABEL_API_NAMES,
                language: lang
            });
            this.labels = { ...this.labels, ...mapApiToCamel(apiMap) };
            this.taskmsg = this.labels.myTasksInfo;
            this.myTaskInfoBtnAriaLabel = this.labels.myTasksInfoBtnPrefix + ' ' + this.taskmsg;
            if (!this.selectedAccountId) {
                this.selectedAccountName = this.labels.pleaseSelectAccount;
            }
        } catch (e) {
            this.taskmsg = this.labels.myTasksInfo || '';
            this.myTaskInfoBtnAriaLabel = this.labels.myTasksInfoBtnPrefix + ' ' + this.taskmsg;
        }
    }

    async initEmployerLanguage() {
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
            const apiMap = await getLabels({
                apiNames: [
                    'EP_Menu',
                    'EP_Help',
                    'EP_Dashboard',
                    'EP_SIR_Queue_Title',
                    'EP_Financial_Filings',
                    'EP_Selected_Account',
                    'EP_Please_Select_Account',
                    'EP_Cancel',
                    'EP_Close'
                ],
                language: lang
            });
            this.labels = { ...this.labels, ...mapApiToCamel(apiMap) };
            if (this.labels.sirQueueTitle) {
                this.labels.insurerReviewQueue = this.labels.sirQueueTitle;
            }
            if (!this.selectedAccountId) {
                this.selectedAccountName = this.labels.pleaseSelectAccount;
            }
        } catch (e) {
            // keep defaults
        }
    }

    async initArpLanguage() {
        try {
            const stored = arpReadStoredLanguage();
            const language = stored || (await getCurrentLanguage()) || 'en_US';
            const normalized = language === 'fr' ? 'fr' : 'en_US';
            arpWriteStoredLanguage(normalized);
            const apiMap = await getLabels({
                apiNames: ARP_LABEL_API_NAMES,
                language: normalized
            });
            const camel = arpMapApiToCamel(apiMap);
            this.labels = {
                ...this.labels,
                agentReview: camel.agentReview || this.labels.agentReview,
                agentReviewApplication: camel.agentReview || this.labels.agentReviewApplication,
                orgDashboard:
                    camel.dashboard || camel.orgDashboardTitle || this.labels.orgDashboard,
                dashboard: camel.dashboard || this.labels.dashboard,
                delegateAccess: camel.delegateAccess || this.labels.delegateAccess,
                delegationActivity: camel.delegationActivity || this.labels.delegationActivity,
                organizationAccess: camel.organizationAccess || this.labels.organizationAccess,
                branchesLocations: camel.branchesLocations || this.labels.branchesLocations,
                sponsoredAgents: camel.sponsoredAgents || this.labels.sponsoredAgents
            };
        } catch (e) {
            // Keep English defaults
        }
    }

    async initPensionLanguage() {
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
                portalPensionFilings: camel.portalPensionFilings || this.labels.portalPensionFilings,
                pensionFilings: camel.pensionFilings || this.labels.pensionFilings,
                avrFiling: camel.avrFiling || camel.addEditAvr || this.labels.avrFiling,
                rmiAdditionalSchedule: camel.rmiAdditionalSchedule || this.labels.rmiAdditionalSchedule,
                emailNotifications: camel.emailNotifications || this.labels.emailNotifications
            };
        } catch (e) {
            // Keep English defaults
        }
    }

    renderedCallback() {
        if (this.needsExpandedMenuRail && !this._arpLayoutApplied) {
            this.openEmployerStyleSidebar();
            this._arpLayoutApplied = true;
        }
    }

    disconnectedCallback() {
        if (this._onInsurerNav) {
            window.removeEventListener(INSURER_REVIEW_EVENT, this._onInsurerNav);
        }
        if (this._onArpNav) {
            window.removeEventListener(ARP_EVENT_NAME, this._onArpNav);
        }
        if (this._onPensionNav) {
            window.removeEventListener(PENSION_EVENT_NAME, this._onPensionNav);
        }
        this.clearEmployerStyleSidebar();
    }

    /**
     * Open the shared Employer/Licensing sidebar rail so portal tabs are visible.
     * Uses the same open/close classes (and colors) as Employer — no custom theme CSS.
     */
    openEmployerStyleSidebar() {
        if (typeof document === 'undefined') {
            return;
        }
        const host = this.template && this.template.host;
        const rail =
            (host && host.closest && host.closest('.nav-sidebar')) ||
            document.querySelector('.nav-sidebar');
        if (rail) {
            rail.classList.remove('close');
            rail.classList.add('open');
            this._arpRailEl = rail;
        }
        const main = document.getElementById('main-content');
        if (main) {
            main.classList.add('open-sidebar', 'license');
            main.classList.remove('help', 'user');
            this._arpMainEl = main;
        }
    }

    clearEmployerStyleSidebar() {
        this._arpLayoutApplied = false;
        if (this._arpRailEl) {
            this._arpRailEl.classList.remove('open');
            this._arpRailEl.classList.add('close');
            this._arpRailEl = null;
        }
        if (this._arpMainEl) {
            this._arpMainEl.classList.remove('open-sidebar');
            this._arpMainEl = null;
        }
    }

    // Kept for older call sites / safety — delegates to Employer-style open
    applyArpSidebarLayout() {
        this.openEmployerStyleSidebar();
    }

    clearArpSidebarLayout() {
        this.clearEmployerStyleSidebar();
    }

    showLicenseFunction() {

        // this.showPermit = false;
        // this.showCertificate = false;
        // this.showUser = false;
        // this.showLabel = false;
        // this.showRegister = false;
        // this.showHelp = false;
        // if(this.showLicense  == true){
        //     this.showLicense = false;
        //     let sidebar = document.querySelector(".nav-sidebar");
        //     sidebar.classList.toggle("close");
        //     //return;
        // } else{
        //     this.showLicense = true;
        //     let sidebar = document.querySelector(".nav-sidebar");
        //     sidebar.classList.toggle("open");
        // }

        this.showPermit = false;
        this.showCertificate = false;
        this.showLabel = false;
        this.showRegister = false;
        this.showUser = false;
        this.showHelp = false;
        this.showLicense = true;

        let sidebar = document.querySelector(".nav-sidebar");
        // Check if the "open" class is present in the sidebar element
        const isMenuOpen = sidebar.classList.contains("open");
        if (isMenuOpen) {
            this.menuAriaLabel = this.labels.menuClosed;
        } else {
            this.menuAriaLabel = this.labels.menuOpened;
        }
        const sidebarWrapper = document.querySelector(".main-content");
        //console.log(JSON.stringify(sidebarWrapper));
        if (sidebarWrapper) {
            sidebarWrapper.classList.add('license');
            if (sidebarWrapper.classList.contains('help') || sidebarWrapper.classList.contains('user')) {
                sidebarWrapper.classList.add('open-sidebar');
                sidebar.classList.add("open");
            }
            else {
                switch(FORM_FACTOR) {
                    case 'Large':
                        sidebarWrapper.classList.toggle('open-sidebar');
                        sidebar.classList.toggle("open");
                        break;
                    case 'Medium':
                        sidebar.classList.toggle("close");
                        break;
                    case 'Small':
                        sidebar.classList.toggle("close");
                        break;
                    default:
                        sidebarWrapper.classList.toggle('open-sidebar');
                        sidebar.classList.toggle("open");
                }
                
            }


        }
        if (sidebarWrapper.classList.contains('help') || sidebarWrapper.classList.contains('user')) {
            sidebar.classList.remove("close");
            sidebarWrapper.classList.remove('help');
            sidebarWrapper.classList.remove('user');
        }
        else {
            sidebar.classList.toggle("close");
            sidebarWrapper.classList.remove('help');
            sidebarWrapper.classList.remove('user');

        }


    }

    get step1CSS() {
        //alert(this.pageName);
        if (this.showLicense == true && (this.pageName == 'Dashboard__c' || this.pageName == 'My_Licenses__c' || this.pageName == 'Renew_License__c' || this.pageName == 'Amendments__c' || this.pageName == 'My_Applications__c' || this.pageName == 'My_Payments__c' || this.pageName == 'Document_Vault__c' || this.pageName == 'My_Complaints__c' || this.pageName == 'My_Tasks__c')) {
            //alert('1-1'+this.pageName);
            return 'active-child';
        }
        else if (this.showLicense == true) {
            //alert('1-2'+this.pageName);
            return 'active-child';
        }
        else if (this.showLicense == false) {
            //alert('1-3'+this.pageName);
            return '';
        }
    }

    get step2CSS() {
        if (this.showPermit == true) {
            return 'active-child';
        }
        else if (this.showPermit == false) {
            return '';
        }
    }

    get step3CSS() {
        if (this.showCertificate == true) {
            return 'active-child';
        }
        else if (this.showCertificate == false) {
            return '';
        }
    }

    get step4CSS() {
        if (this.showLabel == true) {
            return 'active-child';
        }
        else if (this.showLabel == false) {
            return '';
        }
    }

    get step5CSS() {
        if (this.showRegister == true) {
            return 'active-child';
        }
        else if (this.showRegister == false) {
            return '';
        }
    }

    get step6CSS() {
        //alert(this.pageName);
        if (this.showHelp == true && (this.pageName == 'Frequently_Asked_Questions__c')) {
            //alert('6-1'+this.pageName);
            return 'active-child';
        }
        else if (this.showHelp == true) {
            // alert('6-2'+this.pageName);
            return 'active-child';
        }
        else if (this.showHelp == false) {
            // alert('6-3'+this.pageName);
            return '';
        }
    }

    get step7CSS() {
        // alert(this.pageName);
        if (this.showUser == true && (this.pageName == 'My_Account__c' || this.pageName == 'My_Address_List__c' || this.pageName == 'My_Business_List__c' || this.pageName == 'Business_Information__c' || this.pageName == 'Address_Book__c' || this.pageName == 'Documents__c')) {
            // alert('7-1'+this.pageName);
            return 'active-child';
        }
        else if (this.showUser == true) {
            // alert('7-2'+this.pageName);
            return 'active-child';
        }
        else if (this.showUser == false) {
            // alert('7-3'+this.pageName);
            return '';
        }
    }


    showPermitFunction() {

        // this.showLicense = false;
        // this.showCertificate = false;
        // this.showUser = false;
        // this.showLabel = false;
        // this.showRegister = false;
        // this.showHelp = false;
        // if(this.showPermit  == true){
        //     this.showPermit = false;
        //     let sidebar = document.querySelector(".nav-sidebar");
        //     sidebar.classList.toggle("close");
        //     //return;
        // } else{
        //     this.showPermit = true;
        //     let sidebar = document.querySelector(".nav-sidebar");
        //     sidebar.classList.toggle("open");
        // }

        this.showLicense = false;
        this.showCertificate = false;
        this.showLabel = false;
        this.showRegister = false;
        this.showUser = false;
        this.showPermit = true;

        let sidebar = document.querySelector(".nav-sidebar");
        const sidebarWrapper = document.querySelector(".main-content");
        //console.log(JSON.stringify(sidebarWrapper));
        if (sidebarWrapper) {
            sidebarWrapper.classList.toggle('open-sidebar');
            sidebar.classList.toggle("open");

        }
        sidebar.classList.toggle("close");

    }

    showCertificateFunction() {

        // this.showLicense = false;
        // this.showPermit = false;
        // this.showUser = false;
        // this.showLabel = false;
        // this.showRegister = false;
        // this.showHelp = false;
        // if(this.showCertificate  == true){
        //     this.showCertificate = false;
        //     let sidebar = document.querySelector(".nav-sidebar");
        //     sidebar.classList.toggle("close");
        //     //return;
        // } else{
        //     this.showCertificate = true;
        //     let sidebar = document.querySelector(".nav-sidebar");
        //     sidebar.classList.toggle("open");
        // }

        this.showLicense = false;
        this.showPermit = false;
        this.showLabel = false;
        this.showRegister = false;
        this.showUser = false;
        this.showHelp = false;
        this.showCertificate = true;

        let sidebar = document.querySelector(".nav-sidebar");
        const sidebarWrapper = document.querySelector(".main-content");
        //console.log(JSON.stringify(sidebarWrapper));
        if (sidebarWrapper) {
            sidebarWrapper.classList.toggle('open-sidebar');
            sidebar.classList.toggle("open");
        }
        sidebar.classList.toggle("close");
    }

    showUserFunction() {
        // this.showLicense = false;
        // this.showPermit = false;
        // this.showCertificate = false;
        // this.showLabel = false;
        // this.showRegister = false;
        // this.showHelp = false;
        // if(this.showUser  == true){
        //     this.showUser = false;
        //     let sidebar = document.querySelector(".nav-sidebar");
        //     sidebar.classList.toggle("close");
        //     //return;
        // } else{
        //     this.showUser = true;
        //     let sidebar = document.querySelector(".nav-sidebar");
        //     sidebar.classList.toggle("open");
        // }

        this.showLicense = false;
        this.showPermit = false;
        this.showCertificate = false;
        this.showLabel = false;
        this.showRegister = false;
        this.showHelp = false;
        this.showUser = true;

        let sidebar = document.querySelector(".nav-sidebar");
        const sidebarWrapper = document.querySelector(".main-content");
        //console.log(JSON.stringify(sidebarWrapper));
        if (sidebarWrapper) {
            sidebarWrapper.classList.add('user');
            if (sidebarWrapper.classList.contains('help') || sidebarWrapper.classList.contains('license')) {
                sidebarWrapper.classList.add('open-sidebar');
                sidebar.classList.add("open");


            }
            else {
                sidebarWrapper.classList.toggle('open-sidebar');
                sidebar.classList.toggle("open");
            }


        }
        if (sidebarWrapper.classList.contains('help') || sidebarWrapper.classList.contains('license')) {
            sidebar.classList.remove("close");
            sidebarWrapper.classList.remove('help');
            sidebarWrapper.classList.remove('license');
        }
        else {
            sidebar.classList.toggle("close");
            sidebarWrapper.classList.remove('help');
            sidebarWrapper.classList.remove('license');

        }

    }
    showHelpFunction() {

        // this.showPermit = false;
        // this.showCertificate = false;
        // this.showUser = false;
        // this.showLabel = false;
        // this.showRegister = false;
        // this.showLicense = false;
        // if(this.showHelp  == true){
        //     this.showHelp = false;
        //     let sidebar = document.querySelector(".nav-sidebar");
        //     sidebar.classList.toggle("close");
        //     //return;
        // } else{
        //     this.showHelp = true;
        //     let sidebar = document.querySelector(".nav-sidebar");
        //     sidebar.classList.toggle("open");
        // }

        this.showHelp = true;
        this.showUser = false;
        this.showLicense = false;
        this.showPermit = false;
        this.showCertificate = false;
        this.showLabel = false;
        this.showRegister = false;

        let sidebar = document.querySelector(".nav-sidebar");
        const sidebarWrapper = document.querySelector(".main-content");
        //console.log(JSON.stringify(sidebarWrapper));
        if (sidebarWrapper) {
            sidebarWrapper.classList.add('help');
            if (sidebarWrapper.classList.contains('user') || sidebarWrapper.classList.contains('license')) {
                sidebarWrapper.classList.add('open-sidebar');
                sidebar.classList.add("open");
            }
            else {
                sidebarWrapper.classList.toggle('open-sidebar');
                sidebar.classList.toggle("open");
            }


        }

        if (sidebarWrapper.classList.contains('help') || sidebarWrapper.classList.contains('license')) {
            sidebar.classList.remove("close");
            sidebarWrapper.classList.remove('user');
            sidebarWrapper.classList.remove('license');
        }
        else {
            sidebar.classList.toggle("close");
            sidebarWrapper.classList.remove('user');
            sidebarWrapper.classList.remove('license');
        }


    }


    showLabelFunction() {

        // this.showPermit = false;
        // this.showCertificate = false;
        // this.showUser = false;
        // this.showHelp = false;
        // this.showRegister = false;
        // this.showLicense = false;
        // if(this.showLabel  == true){
        //     this.showLabel = false;
        //     let sidebar = document.querySelector(".nav-sidebar");
        //     sidebar.classList.toggle("close");
        //     //return;
        // } else{
        //     this.showLabel = true;
        //     let sidebar = document.querySelector(".nav-sidebar");
        //     sidebar.classList.toggle("open");
        // }

        this.showLicense = false;
        this.showPermit = false;
        this.showCertificate = false;
        this.showLabel = true;
        this.showRegister = false;
        this.showUser = false;

        let sidebar = document.querySelector(".nav-sidebar");
        const sidebarWrapper = document.querySelector(".main-content");
        //console.log(JSON.stringify(sidebarWrapper));
        if (sidebarWrapper) {
            sidebarWrapper.classList.toggle('open-sidebar');
        }
        sidebar.classList.toggle("close");
    }

    showRegisterFunction() {


        // this.showPermit = false;
        // this.showCertificate = false;
        // this.showUser = false;
        // this.showHelp = false;
        // this.showLabel = false;
        // this.showLicense = false;
        // if(this.showRegister  == true){
        //     this.showRegister = false;
        //     let sidebar = document.querySelector(".nav-sidebar");
        //     sidebar.classList.toggle("close");
        //     //return;
        // } else{
        //     this.showRegister = true;
        //     let sidebar = document.querySelector(".nav-sidebar");
        //     sidebar.classList.toggle("open");
        // }

        this.showLicense = false;
        this.showPermit = false;
        this.showCertificate = false;
        this.showLabel = false;
        this.showRegister = true;
        this.showUser = false;

        let sidebar = document.querySelector(".nav-sidebar");
        const sidebarWrapper = document.querySelector(".main-content");
        //console.log(JSON.stringify(sidebarWrapper));
        if (sidebarWrapper) {
            sidebarWrapper.classList.toggle('open-sidebar');
        }
        sidebar.classList.toggle("close");
    }
    // @track permitValues = {
    //     "Permit": ["A","B","C","D"],
    //     "License": ["B","A","D","D"]
    // };

    // @track list = [];

    // handleClick(event){
    //     var value = event.target.dataset.id;
    //     console.log(value);
    //     this.list = this.permitValues[value];
    //     console.log(this.list);
    // }

    handleHomePage(){
        if (this.isEmployerPortal) {
            this.navigateInsurerReviewMode('dashboard');
            return;
        }
        window.open('/s/', '_self');
    }

    handleInsurerReviewQueue() {
        this.navigateInsurerReviewMode('queue');
    }

    navigateInsurerReviewMode(page) {
        this.insurerReviewPage = page;
        this.writeInsurerReviewPage(page);
        window.dispatchEvent(
            new CustomEvent(INSURER_REVIEW_EVENT, {
                detail: { page },
                bubbles: true,
                composed: true
            })
        );
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: { name: 'Home' }
        });
    }

    readInsurerReviewPage() {
        try {
            return window.sessionStorage.getItem(INSURER_REVIEW_STORAGE_KEY);
        } catch (e) {
            return null;
        }
    }

    writeInsurerReviewPage(page) {
        try {
            window.sessionStorage.setItem(INSURER_REVIEW_STORAGE_KEY, page);
        } catch (e) {
            // ignore
        }
    }

    handlepremTaxFillings() {
        window.open('/employerportal/s/premium-tax-return', '_self');
    }

    get premTaxFillingsActive() {
        if (
            typeof window !== 'undefined' &&
            window.location &&
            window.location.pathname &&
            (window.location.pathname.indexOf('/premium-tax-return') !== -1 ||
                window.location.pathname.indexOf('/premium-tax-application') !== -1 ||
                window.location.pathname.indexOf('/fire-marshal-levy') !== -1 ||
                window.location.pathname.indexOf('/vehicle-levy') !== -1)
        ) {
            return 'active d-flex';
        }
        return 'd-flex';
    }

    handleFinancialFilings() {
        window.open('/employerportal/s/financial-filings', '_self');
    }

    get financialFilingsActive() {
        if (
            typeof window !== 'undefined' &&
            window.location &&
            window.location.pathname &&
            window.location.pathname.indexOf('/financial-filings') !== -1
        ) {
            return 'active d-flex';
        }
        return 'd-flex';
    }

    get insurerReviewQueueActive() {
        if (this.pageName === APPLICATION_REVIEW_PAGE) {
            return 'active d-flex';
        }
        if ((this.pageName == 'Home' || this.pageName == 'home') && this.insurerReviewPage === 'queue') {
            return 'active d-flex';
        }
        return 'd-flex';
    }

    handleArpNav(event) {
        event.preventDefault();
        const page = event.currentTarget.dataset.page;
        if (!page) {
            return;
        }
        this.arpActivePage = page;
        this.writeArpPage(page);
        window.dispatchEvent(
            new CustomEvent(ARP_EVENT_NAME, {
                detail: { page },
                bubbles: true,
                composed: true
            })
        );
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: { name: 'Home' }
        });
    }

    readArpPage() {
        try {
            return window.sessionStorage.getItem(ARP_STORAGE_KEY);
        } catch (e) {
            return null;
        }
    }

    writeArpPage(page) {
        try {
            window.sessionStorage.setItem(ARP_STORAGE_KEY, page);
        } catch (e) {
            // ignore
        }
    }

    get arpDashboardActiveClass() {
        return this.arpActivePage === 'dashboard' ? 'active d-flex' : 'd-flex';
    }

    get arpOrgDashboardActiveClass() {
        return this.arpActivePage === 'orgDashboard' ? 'active d-flex' : 'd-flex';
    }

    get arpDelegateActiveClass() {
        return this.arpActivePage === 'delegate' ? 'active d-flex' : 'd-flex';
    }

    get arpActivityActiveClass() {
        return this.arpActivePage === 'activity' ? 'active d-flex' : 'd-flex';
    }

    get arpOrganizationActiveClass() {
        return this.arpActivePage === 'organization' ? 'active d-flex' : 'd-flex';
    }

    get arpBranchesActiveClass() {
        return this.arpActivePage === 'branches' ? 'active d-flex' : 'd-flex';
    }

    get arpSponsoredActiveClass() {
        return this.arpActivePage === 'sponsored' ? 'active d-flex' : 'd-flex';
    }

    handlePensionNav(event) {
        event.preventDefault();
        const page = event.currentTarget.dataset.page;
        if (!page) {
            return;
        }
        this.pensionActivePage = page;
        this.writePensionPage(page);

        if (page === 'form') {
            this.navigateToAvrOmni();
            return;
        }

        window.dispatchEvent(
            new CustomEvent(PENSION_EVENT_NAME, {
                detail: { page },
                bubbles: true,
                composed: true
            })
        );

        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: { name: 'Home' }
        });
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

    readPensionPage() {
        try {
            return window.sessionStorage.getItem(PENSION_STORAGE_KEY);
        } catch (e) {
            return null;
        }
    }

    writePensionPage(page) {
        try {
            window.sessionStorage.setItem(PENSION_STORAGE_KEY, page);
        } catch (e) {
            // ignore
        }
    }

    get pensionListActiveClass() {
        return this.pensionActivePage === 'list' ? 'active d-flex' : 'd-flex';
    }

    get pensionFormActiveClass() {
        return this.pensionActivePage === 'form' ? 'active d-flex' : 'd-flex';
    }

    get pensionRmiActiveClass() {
        return this.pensionActivePage === 'rmi' ? 'active d-flex' : 'd-flex';
    }

    get pensionEmailsActiveClass() {
        return this.pensionActivePage === 'emails' ? 'active d-flex' : 'd-flex';
    }

    handleApplyLicense() {
        window.open('/s/recommended-licenses', '_self');
    }
    handleAssociateBusinessAccount() {
        window.open('/s/associate-business-account', '_self');
    }
    handleAddTemporaryClerk() {
        window.open('/s/add-temporary-clerk', '_self');
    }
    handleDashboard() {
        this.activeRenew = false;
        window.open('/s/dashboard', '_self');
    }
    handleAmendment() {
        window.open('/s/amendments', '_self')
    }
    handleMyLicense() {
        window.open('/s/my-licenses', '_self');
    }
    handleAllLicense(){
        window.open('/s/all-licenses', '_self');
    }
    handleApplication() {
        window.open('/s/my-applications', '_self');
    }
    /* handleAllApplication(){
        window.open('/license/s/all-applications', '_self');
    } */
    //Added for issue I-244820 - start
    handleAll(){
        window.open('/s/all-details', '_self');
    }
    //Added for issue I-244820 - End
    handlePayment() {
        window.open('/s/my-payments', '_self');
    }
    handleMyComplaints() {
        window.open('/s/my-complaints', '_self');
    }
    handleAllPayment() {
        window.open('/s/all-payments', '_self');
    }
    handleTransfer() {
        window.open('/s/transfer-license', '_self');
    }
    handleAccount() {
        window.open('/s/profile-details', '_self');
    }
    handleMyLicenses() {
        window.open('/s/license-listing', '_self');
    }
    handleMyAddress() {
        window.open('/s/address-listing', '_self');
    }
    handleMyBusiness() {
        window.open('/s/my-business-list', '_self');
    }
    handleBusinessInformation() {
        window.open('/s/business-information', '_self');
    }
    handleAddressBook() {
        window.open('/s/address-book', '_self');
    }
    handleDocuments() {
        window.open('/s/documents', '_self');
    }
    // handleAccountSettings() {
    //     window.open('/license/s/settings', '_self');
    // }
    // handleComplaints() {
    //     window.open('/license/s/file-a-complaint', '_self');
    // }
    handleComplaints() {
        window.open('/s/complaint-form', '_self');
    }
    
    // handleCertificates() {
    //     window.open('/license/s/frequently-asked-questions', '_self');
    // }
    // handleFeedback() {
    //     window.open('/license/s/frequently-asked-questions', '_self');
    // }
    handleRenewLicense(event) {
        this.activeRenew = true;
        window.open('/s/renew-license', '_self');
    }
    handleProfile() {
        window.open('/s/my-profile', '_self');
    }
    handleMyTasks() {
        window.open('/s/my-tasks', '_self');
    }
    /* navigateToPage(event) {
        console.log(event.target.dataset.navigatepage);
        this.selectedTab = event.target.dataset.navigatepage;
    } */
    handlePreLicensurePetition() {
        fetchRegAuthTypeId().then(result => {
            if(result){
                window.open('/s/pre-licensure-petition?c__regAuthId='+result+'&c__type=Pre-licensure Petition', '_self');
            } 
        }).catch(error => {
            console.error("errorMessage"+error.body.message);
        });  
    }
    get documentVault() {
        if (this.pageName == 'Document_Vault__c') {
            return 'active d-flex';
        }
        else {
            return 'd-flex';
        }
    }

    get renewActive() {
        if (this.pageName == 'Renew_License__c') {
            return 'active d-flex';
        }
        else {
            return 'd-flex';
        }
    }
    get taskActive() {
        if (this.pageName == 'My_Tasks__c') {
            return 'active d-flex';
        }
        else {
            return 'd-flex';
        }
    }

    get dashboardActive() {
        if (this.isEmployerPortal) {
            if (
                typeof window !== 'undefined' &&
                window.location &&
                window.location.pathname &&
                (window.location.pathname.indexOf('/financial-filings') !== -1 ||
                    window.location.pathname.indexOf('/premium-tax-return') !== -1 ||
                    window.location.pathname.indexOf('/premium-tax-application') !== -1 ||
                    window.location.pathname.indexOf('/application-review') !== -1)
            ) {
                return 'd-flex';
            }
            if ((this.pageName == 'Home' || this.pageName == 'home') && this.insurerReviewPage !== 'queue') {
                return 'active d-flex';
            }
            return 'd-flex';
        }
        if (this.pageName == 'Home') {
            return 'active d-flex';
        }
        else {
            return 'd-flex';
        }
    }
    get myLicensesActive() {
        if (this.pageName == 'My_Licenses__c') {
            return 'active d-flex';
        }
        else {
            return 'd-flex';
        }
    }

    get allLicensesActive() {
        if (this.pageName == 'All_Licenses__c') {
            return 'active d-flex';
        }
        else {
            return 'd-flex';
        }
    }

    get amendmentActive() {
        if (this.pageName == 'Amendments__c') {
            return 'active d-flex';
        }
        else {
            return 'd-flex';
        }
    }
    get myApplicationActive() {
        if (this.pageName == 'My_Applications__c') {
            return 'active d-flex';
        }
        else {
            return 'd-flex';
        }
    }
    get allApplicationActive() {
        if (this.pageName == 'All_Applications__c') {
            return 'active d-flex';
        }
        else {
            return 'd-flex';
        }
    }
    get myPayemntActive() {
        if (this.pageName == 'My_Payments__c') {
            return 'active d-flex';
        }
        else {
            return 'd-flex';
        }
    }
    get myComplaintsActive() {
        if (this.pageName == 'My_Complaints__c') {
            return 'active d-flex';
        }
        else {
            return 'd-flex';
        }
    }
    get allPayemntActive() {
        if (this.pageName == 'All_Payments__c') {
            return 'active d-flex';
        }
        else {
            return 'd-flex';
        }
    }
    get faqsActive() {
        if (this.pageName == 'Frequently_Asked_Questions__c') {
            return 'active d-flex';
        }
        else {
            return 'd-flex';
        }
    }
    get myAccountActive() {
        if (this.pageName == 'My_Account__c') {
            return 'active d-flex';
        }
        else {
            return 'd-flex';
        }
    }

    get addressActive() {
        if (this.pageName == 'My_Address_List__c') {
            return 'active d-flex';
        }
        else {
            return 'd-flex';
        }
    }

    get myBusinessActive() {
        if (this.pageName == 'My_Business_List__c') {
            return 'active d-flex';
        }
        else {
            return 'd-flex';
        }
    }

    get businessInfoActive() {
        if (this.pageName == 'Business_Information__c') {
            return 'active d-flex';
        }
        else {
            return 'd-flex';
        }
    }

    get addresssBookActive() {
        if (this.pageName == 'Address_Book__c') {
            return 'active d-flex';
        }
        else {
            return 'd-flex';
        }
    }

    get documentActive() {

        if (this.pageName == 'Documents__c') {
            return 'active d-flex';
        }
        else {
            return 'd-flex';
        }
    }
    handleChange(event) {
        try {
            const currentUrl = window.location.href;
            const myArray = currentUrl.split(/[/?]+/);
            if(myArray.includes('renew-license-details'))
            {
                this.showMessage('Error', 'You cannot change the account on this page. Please navigate to the home or dashboard page to switch accounts.', 'error');
            } else {
                if (this.selectedAccountId !== event.detail.value) {
                    this.selectedAccountId = event.detail.value;
                    let obj = this.acrList.find(o => o.Id == this.selectedAccountId);
                    if (obj) {
                        this.selectedAccountName = obj.Name;
                    }
                    if (this.selectedAccountId) {
                        updateAcrSelectedOnParentAccount({
                                accountId: this.selectedAccountId
                            })
                            .then(result => {
                                location.reload();
                            })
                            .catch(error => {
                            });
                    }
                }
            }
        } catch (error) {

        }
    }
    handleProfessionPage(){
        window.open('/s/recommended-profession', '_self');
    }
    showMessage(title,message, variant) {
        const toastEvt = new ShowToastEvent({
            title,
            message,
            variant
        });
        this.dispatchEvent(toastEvt);
    }

    handleNewLicense(){
        window.open('/s/recommended-profession', '_self');
    }
    handlePreLicensePetition(){
        window.open('/s/pre-licensure-petition', '_self');
    }
    handleComplaints(){
        window.open('/s/my-complaints', '_self');
    }
    handleAction(){
        this.openSelectionModal = true;
        setTimeout(() => {
			this.focusFirstEle();
		}, 200);
    }
    closeSelectionModal(){
        this.openSelectionModal = false;
    }
    escCloseModal(event){
        if (event.keyCode === ESC) {
            this.closeSelectionModal();
        }
    }


    focusFirstEle() {
		const focusableElements = 'lightning-combobox, lightning-button-icon, button, lightning-helptext, lightning-input, lightning-button';
		const modal = this.template.querySelector('.slds-modal');
		const firstFocusableElement = modal.querySelectorAll(focusableElements)[0];
		const focusableContent = modal.querySelectorAll(focusableElements);
		const lastFocusableElement = focusableContent[focusableContent.length - 1];
		firstFocusableElement.focus();
		this.template.addEventListener('keydown', function (event) {
			let isTabPressed = event.key === 'Tab' || event.keyCode === 9;
			if (!isTabPressed) {
				return;
			}
			if (event.shiftKey) {
				if (this.activeElement === firstFocusableElement) {
					lastFocusableElement.focus();
					event.stopPropagation()
					event.preventDefault();
				}
			} else {
				if (this.activeElement === lastFocusableElement) {
					firstFocusableElement.focus();
					event.preventDefault();
					event.stopPropagation()
				}
			}
		});
	}
}