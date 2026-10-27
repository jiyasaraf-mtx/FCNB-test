import { LightningElement, track } from 'lwc';
import lpiResource from '@salesforce/resourceUrl/LPI_Design';
import getCurrentLanguage from '@salesforce/apex/EMP_LanguageCtrl.getCurrentLanguage';
import getLabels from '@salesforce/apex/EMP_LanguageCtrl.getLabels';
import {
    LANDING_LABEL_API_NAMES,
    mapApiToCamel,
    readStoredLanguage,
    writeStoredLanguage
} from 'c/lpLanguageUtils';

export default class LpiLandingPage extends LightningElement {
    licensing = lpiResource + '/media/images/licensing.png';
    feeStructure = lpiResource + '/media/images/Professional-Standing.jpg';
    renewals = lpiResource + '/media/images/Recognition-of-Work.jpg';
    bannerTop = lpiResource + '/media/images/home-page-banner.svg';

    @track labels = {
        landingBannerTitle: 'Financial and Consumer Services of New Brunswick',
        landingBannerText:
            "Build confidence in New Brunswick's financial and consumer services with a modern online licensing and permitting platform (LPI). Designed to simplify regulatory processes, LPI provides a secure, streamlined way for businesses and professionals to apply for licences, registrations, permits, and regulatory filings. From application submission and document management to status tracking and regulatory compliance, LPI helps regulated sectors navigate their obligations efficiently while supporting FCNB's commitment to effective, practical, and responsive regulatory services.",
        landingPlatformServices: 'Platform Services',
        landingPlatformLink1: 'Know your License Details',
        landingPlatformLink2: 'Make Payment',
        landingPlatformLink3: 'Renew Application',
        landingPlatformLink4: 'License Lookup',
        landingPlatformLink5: 'File Complaint',
        landingPlatformLink6: 'Create New Ticket',
        landingPlatformLink7: 'Amend License',
        landingPlatformLink8: 'Print License/Permit',
        landingNewToLicensing: 'New to Licensing?',
        landingLearnHere: 'Learn here',
        landingRecentAnnouncements: 'Recent Announcements',
        landingReadAllAnnouncements: 'Read all recent announcements',
        landingPosted3Days: 'Posted 3days ago',
        landingPosted1Week: 'Posted 1week ago',
        landingPosted1Month: 'Posted 1month ago',
        landingAnn1Title: 'Online Portal for Mortgage Brokers & Insurance Licensing',
        landingAnn1Text:
            'Submit applications, track licensing statuses, and submit regulatory compliance filings directly through our unified portal.',
        landingAnn2Title: 'Consumer Alerts & Fraud Awareness Updates',
        landingAnn2Text:
            'Stay informed on recent investment red flags, financial scams, and key consumer protections across New Brunswick.',
        landingAnn3Title: 'Annual License Renewal & Compliance Deadlines',
        landingAnn3Text:
            'Review upcoming renewal timelines for Securities, Real Estate, Credit Unions, and Consumer Affairs licensees.',
        landingReadMore: 'Read more',
        landingFaqHeading: 'Frequently Asked Questions',
        landingFaqIntro:
            'Frequently Asked Questions (FAQs) offer quick answers to common queries. Our comprehensive FAQ section covers a range of topics related to our services.',
        landingLearnMore: 'Learn more',
        landingFaqQ1: 'How to Apply for a License or Registration',
        landingFaqQ2: 'How to Renew a License',
        landingFaqQ3: 'How to Make Regulatory Fee Payments',
        landingFaqQ4: 'How to Resume a Saved Application',
        landingFaqQ5: 'Filing Forms and Submissions Offline',
        landingFaqA1:
            'Applying for a license is a straightforward process that begins with gathering the necessary documents and information. Next, navigate to our online application portal and fill out the required forms accurately. Ensure you review all details carefully before submitting to avoid any delays. Lastly, follow any additional instructions provided to complete the application successfully.',
        landingContactUsFooter: 'Contact Us',
        landingTollFree: 'Toll-free:',
        landingLocal: 'Local:',
        landingAddress: '300-85 Charlotte Street, Saint John, NB E2L 2J2',
        landingRegulatedSectors: 'Regulated Sectors',
        landingInsurancePensions: 'Insurance & Pensions',
        landingSecuritiesInvestments: 'Securities & Investments',
        landingConsumerCreditUnions: 'Consumer Affairs & Credit Unions',
        landingMortgageRealEstate: 'Mortgage Brokers & Real Estate',
        landingFinancialInstitutions: 'Financial Institutions',
        landingConsumerProtection: 'Consumer Protection',
        landingFileAComplaint: 'File a Complaint',
        landingCheckRegistration: 'Check Registration Status',
        landingEnforcementWarnings: 'Enforcement & Warnings',
        landingUnclaimedProperty: 'Unclaimed Property',
        landingConsumerGuides: 'Consumer Guides',
        landingCommissionGovernance: 'Commission & Governance',
        landingAboutFcnb: 'About FCNB',
        landingLegislationRules: 'Legislation & Rules',
        landingDecisionsOrders: 'Decisions & Orders',
        landingCopyright: 'Copyright © Financial and Consumer Services Commission (FCNB)',
        landingPrivacyTerms: 'Privacy Policy | Terms of Use',
        landingBackToTop: 'Back to Top'
    };

    @track sectionClass1 = 'slds-accordion__section custom-accordion slds-is-open';
    @track sectionClass2 = 'slds-accordion__section custom-accordion';
    @track sectionClass3 = 'slds-accordion__section custom-accordion';
    @track sectionClass4 = 'slds-accordion__section custom-accordion';
    @track sectionClass5 = 'slds-accordion__section custom-accordion';

    connectedCallback() {
        this.initLanguage();
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
        lang = lang === 'fr' ? 'fr' : 'en_US';
        writeStoredLanguage(lang);
        try {
            const apiMap = await getLabels({
                apiNames: LANDING_LABEL_API_NAMES,
                language: lang
            });
            this.labels = { ...this.labels, ...mapApiToCamel(apiMap) };
        } catch (e) {
            // keep defaults
        }
    }

    handleAccordianClick(event) {
        let name = event.currentTarget.dataset.name;
        let accordionStatus = this.template.querySelector(`[data-name="apply"]`);

        if (name === 'apply') {
            if (this.sectionClass1 == 'slds-accordion__section custom-accordion') {
                this.sectionClass1 = 'slds-accordion__section custom-accordion slds-is-open';
                this.sectionClass2 = 'slds-accordion__section custom-accordion';
                this.sectionClass3 = 'slds-accordion__section custom-accordion';
                this.sectionClass4 = 'slds-accordion__section custom-accordion';
                this.sectionClass5 = 'slds-accordion__section custom-accordion';
                accordionStatus.setAttribute('aria-expanded', true);
            } else {
                this.sectionClass1 = 'slds-accordion__section custom-accordion';
                accordionStatus.setAttribute('aria-expanded', false);
            }
        }
        if (name === 'Renew') {
            if (this.sectionClass2 == 'slds-accordion__section custom-accordion') {
                this.sectionClass2 = 'slds-accordion__section custom-accordion slds-is-open';
                this.sectionClass3 = 'slds-accordion__section custom-accordion';
                this.sectionClass4 = 'slds-accordion__section custom-accordion';
                this.sectionClass5 = 'slds-accordion__section custom-accordion';
                this.sectionClass1 = 'slds-accordion__section custom-accordion';
                accordionStatus.setAttribute('aria-expanded', true);
            } else {
                this.sectionClass2 = 'slds-accordion__section custom-accordion';
                accordionStatus.setAttribute('aria-expanded', false);
            }
        }
        if (name === 'payment') {
            if (this.sectionClass3 == 'slds-accordion__section custom-accordion') {
                this.sectionClass3 = 'slds-accordion__section custom-accordion slds-is-open';
                this.sectionClass1 = 'slds-accordion__section custom-accordion';
                this.sectionClass2 = 'slds-accordion__section custom-accordion';
                this.sectionClass4 = 'slds-accordion__section custom-accordion';
                this.sectionClass5 = 'slds-accordion__section custom-accordion';
                accordionStatus.setAttribute('aria-expanded', true);
            } else {
                this.sectionClass3 = 'slds-accordion__section custom-accordion';
                accordionStatus.setAttribute('aria-expanded', false);
            }
        }
        if (name === 'Resume') {
            if (this.sectionClass4 == 'slds-accordion__section custom-accordion') {
                this.sectionClass4 = 'slds-accordion__section custom-accordion slds-is-open';
                this.sectionClass1 = 'slds-accordion__section custom-accordion';
                this.sectionClass2 = 'slds-accordion__section custom-accordion';
                this.sectionClass3 = 'slds-accordion__section custom-accordion';
                this.sectionClass5 = 'slds-accordion__section custom-accordion';
                accordionStatus.setAttribute('aria-expanded', true);
            } else {
                this.sectionClass4 = 'slds-accordion__section custom-accordion';
                accordionStatus.setAttribute('aria-expanded', false);
            }
        }
        if (name === 'Offline') {
            if (this.sectionClass5 == 'slds-accordion__section custom-accordion') {
                this.sectionClass5 = 'slds-accordion__section custom-accordion slds-is-open';
                this.sectionClass1 = 'slds-accordion__section custom-accordion';
                this.sectionClass2 = 'slds-accordion__section custom-accordion';
                this.sectionClass3 = 'slds-accordion__section custom-accordion';
                this.sectionClass4 = 'slds-accordion__section custom-accordion';
                accordionStatus.setAttribute('aria-expanded', true);
            } else {
                this.sectionClass5 = 'slds-accordion__section custom-accordion';
                accordionStatus.setAttribute('aria-expanded', false);
            }
        }
    }

    topFunction() {
        const scrollOptions = {
            left: 0,
            top: 0,
            behavior: 'smooth'
        };
        window.scrollTo(scrollOptions);
    }
}