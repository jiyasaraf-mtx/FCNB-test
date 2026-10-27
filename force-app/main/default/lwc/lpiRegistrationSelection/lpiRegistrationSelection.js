import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getLabels from '@salesforce/apex/EMP_LanguageCtrl.getLabels';
import My_Resource from '@salesforce/resourceUrl/LPI_Design_old';
import {
    PUBLIC_PAGE_LABEL_API_NAMES,
    mapApiToCamel,
    readStoredLanguage
} from 'c/lpLanguageUtils';

export default class LpiRegistrationSelection extends NavigationMixin(LightningElement) {
    userIcon = My_Resource + '/icons/user-icon.svg';
    briefcaseIcon = My_Resource + '/icons/briefcase-icon.svg';
    @api isRegistration;
    @api isForgotusername;

    @track labels = {
        regIndividual: 'Register for an Individual',
        regBusiness: 'Register for a Business',
        regOverview: 'Overview',
        regOverviewP1:
            "Businesses must create a Business Account to submit a license application directly or to authorize a third-party vendor/Authorized Agent to complete a license application on the business's behalf.",
        regOverviewNote:
            'Note: Temporary Vendors/Authorized Agents may provide application information, however, only a corporate officer, owner, partner, sole proprietor, or individual with designated power of attorney may officially attest to and submit the license application (proof of designated power of attorney must be submitted with the license application).',
        regThirdPartyTitle: 'Third-Party Licensing/Application Vendors',
        regThirdPartyP1:
            'A Business Account must first be created by the Business that will be applying for a license designating you as an Authorized Agent authorized to complete applications on the business\'s behalf. Third-party vendors/Authorized Agents will receive an e-mail after you are added to a Business Account by the applicable business. Follow the instructions in the e-mail to create an "Individual Account" to then submit a business application. You cannot submit a business license application until you have been officially designated by the business as an authorized agent.',
        regThirdPartyNote:
            'Note: Third-Party Vendors/Authorized Agents may provide application information, however, only a corporate officer, owner, partner, sole proprietor, or individual with designated power of attorney may officially attest to and electronically submit the license application (proof of designated power of attorney must be submitted with the license application).',
        regSoleTitle: 'Sole Proprietors',
        regSoleBody:
            "Sole proprietors can apply for a business license by either creating an Individual Account or a Business account. A business license application can be submitted via either account. To protect personal information (e.g., social security numbers), the Board recommends creating a business account if other parties will have access to the business' online license account.",
        regForgotChoice: 'Have you Registered as an Individual or as a Business?',
        regIndividualRegistration: 'Individual Registration',
        regBusinessRegistration: 'Business Registration',
        regBackTo: 'Back to',
        regLogin: 'Login'
    };

    connectedCallback() {
        const lang = readStoredLanguage() || 'en_US';
        const apiNames = PUBLIC_PAGE_LABEL_API_NAMES.filter((n) => n.startsWith('LP_Reg_'));
        getLabels({ apiNames, language: lang })
            .then((apiMap) => {
                this.labels = { ...this.labels, ...mapApiToCamel(apiMap) };
            })
            .catch(() => {
                // keep English defaults
            });
    }

    landOnIndividualRegisteration() {
        this.dispatchEvent(new CustomEvent('hideselection'));
    }

    landOnBusinessRegisteration() {
        this.navigateToViewObjectPage('business_registration__c');
    }

    navigateToViewObjectPage(pageName) {
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: pageName
            }
        });
    }

    openIndividualForgotUsername() {
        this.dispatchEvent(
            new CustomEvent('hideselection', {
                detail: { isIndividualForgotUsername: true, isBusinessForgotUsername: false }
            })
        );
    }

    openBusinessForgotUsername() {
        this.dispatchEvent(
            new CustomEvent('hideselection', {
                detail: { isBusinessForgotUsername: true, isIndividualForgotUsername: false }
            })
        );
    }

    renderedCallback() {
        this.setFocusOnRegisterMessage();
        this.setFocusOnFirstRadio();
    }

    setFocusOnRegisterMessage() {
        const registerMessage = this.template.querySelector('.mainTitleClass');
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        setTimeout(() => {
            if (registerMessage) {
                registerMessage.setAttribute('tabindex', '0');
                registerMessage.focus();
            }
        }, 3000);
    }

    setFocusOnFirstRadio() {
        const firstRadioClass = this.template.querySelector('.firstRadioClass');
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        setTimeout(() => {
            if (firstRadioClass) {
                firstRadioClass.setAttribute('tabindex', '0');
                firstRadioClass.focus();
            }
        }, 7000);
    }
}