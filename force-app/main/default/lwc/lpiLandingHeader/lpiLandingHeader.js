import { LightningElement, track, wire } from 'lwc';
import LP_Design from '@salesforce/resourceUrl/LPI_Design';
import { NavigationMixin, CurrentPageReference } from 'lightning/navigation';
import getCurrentLanguage from '@salesforce/apex/EMP_LanguageCtrl.getCurrentLanguage';
import setLanguage from '@salesforce/apex/EMP_LanguageCtrl.setLanguage';
import getLabels from '@salesforce/apex/EMP_LanguageCtrl.getLabels';
import {
    LANDING_LABEL_API_NAMES,
    mapApiToCamel,
    readStoredLanguage,
    writeStoredLanguage
} from 'c/lpLanguageUtils';

export default class LpiLandingHeader extends NavigationMixin(LightningElement) {
    alpha_logo = LP_Design + '/media/images/logo_2.png';
    showMenuItems = false;
    @track pageName;
    @track selectedLanguage = 'en_US';
    @track languageUpdating = false;
    @track labels = {
        language: 'Language',
        english: 'English',
        french: 'French',
        landingHome: 'Home',
        landingFileAComplaint: 'File a Complaint',
        landingServices: 'Services',
        landingContactUs: 'Contact Us',
        landingFaq: 'FAQ',
        landingRegister: 'Register',
        landingLogin: 'Login',
        landingKnowLicenseDetails: 'Know your License Details',
        landingMakePayment: 'Make Payment',
        landingRenewApplication: 'Renew Application',
        landingAmendLicense: 'Amend License',
        landingPrintLicensePermit: 'Print License/Permit',
        landingSearchForLicenses: 'Search for Licenses'
    };

    @wire(CurrentPageReference)
    getpageRef(pageRef) {
        this.pageName = pageRef.attributes.name;
    }

    connectedCallback() {
        this.initLanguage();
    }

    get languageOptions() {
        return [
            { label: this.labels.english || 'English', value: 'en_US' },
            { label: this.labels.french || 'French', value: 'fr' }
        ];
    }

    initLanguage() {
        const stored = readStoredLanguage();
        const applyLang = (resolvedLang) => {
            this.selectedLanguage = resolvedLang === 'fr' ? 'fr' : 'en_US';
            this.loadLabels(this.selectedLanguage);
        };
        if (stored === 'fr' || stored === 'en_US') {
            applyLang(stored);
            return;
        }
        getCurrentLanguage()
            .then((serverLang) => {
                const resolved = serverLang === 'fr' ? 'fr' : 'en_US';
                writeStoredLanguage(resolved);
                applyLang(resolved);
            })
            .catch(() => {
                applyLang('en_US');
            });
    }

    loadLabels(lang) {
        getLabels({ apiNames: LANDING_LABEL_API_NAMES, language: lang })
            .then((apiMap) => {
                this.labels = { ...this.labels, ...mapApiToCamel(apiMap) };
            })
            .catch(() => {
                // keep defaults
            });
    }

    handleLanguageChange(event) {
        const next = event.detail.value;
        if (!next || next === this.selectedLanguage || this.languageUpdating) {
            return;
        }
        this.languageUpdating = true;
        writeStoredLanguage(next);
        setLanguage({ languageLocaleKey: next })
            .catch(() => {
                // Guest/community users may be blocked from User language update
            })
            .finally(() => {
                this.selectedLanguage = next;
                // eslint-disable-next-line @lwc/lwc/no-async-operation
                setTimeout(() => {
                    window.location.reload();
                }, 250);
            });
    }

    handleLogin() {
        window.open('/s/login', '_self');
    }

    showMenu(event) {
        if (event.keyCode && event.keyCode === 13) {
            let target = event.target;
            target.classList.toggle('change');
            this.showMenuItems = !this.showMenuItems;
        } else if (!event.keyCode) {
            let target = event.target;
            target.classList.toggle('change');
            this.showMenuItems = !this.showMenuItems;
        }
    }

    handleToggle() {
        this.template.querySelector('.hamburger').classList.toggle('change');
        this.showMenuItems = !this.showMenuItems;
    }

    handleClick() {
        window.location.replace('/s/complaint-form');
    }
    handleRegister() {
        window.location.replace('/s/registration');
    }
    handleClickTechnicianForm() {
        window.location.replace('/s/pharmacy-technician-discipline-form');
    }
    handleClickPharmacistForm() {
        window.location.replace('/s/pharmacist-disciplinary-action-report');
    }
    handleClickDisciplineForm() {
        window.location.replace('/s/pharmacy-reporting-form');
    }

    handleHome() {
        window.open('/s', '_self');
    }
    HandleLicensesSearch() {
        window.open('/s/global-search', '_self');
    }
    HandleKnowLicensesSearch() {
        window.open('/s/license-search', '_self');
    }

    get homeActive() {
        if (this.pageName == 'Home') {
            return 'active home-btn';
        }
        return 'home-btn';
    }
    get complaintActive() {
        if (this.pageName == 'complaint_form__c') {
            return 'active btn-file';
        }
        return 'btn-file';
    }
    get licensesSearch() {
        if (this.pageName == 'Global_Search__c') {
            return 'active btn-search';
        }
        return 'btn-search';
    }
    get KnowLicensesSearch() {
        if (this.pageName == 'License_Search_Page__c') {
            return 'active btn-license';
        }
        return 'btn-license';
    }
    get contactActive() {
        if (this.pageName == 'contactus__c') {
            return 'active contact-btn';
        }
        return 'contact-btn';
    }
    get servicesActive() {
        if (this.pageName == 'Global_Search__c' || this.pageName == 'License_Search_Page__c') {
            return 'active services-btn';
        }
        return 'services-btn';
    }
}