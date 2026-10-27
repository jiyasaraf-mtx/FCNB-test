import { LightningElement, track } from 'lwc';
import getMyAllRenewLicenseDetails from '@salesforce/apex/LPI_DashbaordTableCtrl.getMyAllRenewLicenseDetails';
import getCurrentLanguage from '@salesforce/apex/EMP_LanguageCtrl.getCurrentLanguage';
import getLabels from '@salesforce/apex/EMP_LanguageCtrl.getLabels';
import { NavigationMixin } from 'lightning/navigation';
import {
    LABEL_API_NAMES,
    mapApiToCamel,
    translateStatus,
    readStoredLanguage,
    writeStoredLanguage
} from 'c/lpLanguageUtils';

export default class LpiRenewLicensePage extends NavigationMixin(LightningElement) {
    @track labels = {
        renewCertificate: 'Renew License',
        importantNotice: 'Important Notice',
        noticeLicense: '',
        licenseNumber: 'License Number',
        licenceType: 'License Type',
        issuanceDate: 'Issuance Date',
        expirationDate: 'Expiration Date',
        status: 'Status',
        action: 'Action',
        searchLicenseTypePlaceholder: 'Search using license number or license type..',
        noRenewalLicenses: "You currently don't have any licenses available for renewal.",
        visitMyLicenses: 'Visit My Licenses page to view your current licenses for renewal',
        warning: 'Warning',
        active: 'Active'
    };

    @track childCardTitle = 'Renew License';
    showRenewLicenses = false;
    @track licensedata = true;
    @track applicationdata = false;
    @track paymentdata = false;
    @track recordsData = [];
    @track statusFilter = [];
    @track myLicenseColumns = [];
    currentFilter = 'All';
    showSpinner = false;

    connectedCallback() {
        this.showSpinner = true;
        this.initLanguage().then(() => {
            this.buildColumns();
            this.getMyAllRenewLicenseDetails();
        });
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
                apiNames: LABEL_API_NAMES,
                language: lang
            });
            this.labels = { ...this.labels, ...mapApiToCamel(apiMap) };
            this.childCardTitle = this.labels.renewCertificate;
        } catch (e) {
            // keep defaults
        }
    }

    buildColumns() {
        this.myLicenseColumns = [
            { label: this.labels.licenseNumber, fieldName: 'LicenseNumber' },
            { label: this.labels.licenceType, fieldName: 'LicenseType' },
            { label: this.labels.issuanceDate, fieldName: 'IssuanceDate' },
            { label: this.labels.expirationDate, fieldName: 'ExpirationDate' },
            { label: this.labels.status, fieldName: 'Status' },
            { label: this.labels.action, fieldName: 'Action' }
        ];
    }

    getMyAllRenewLicenseDetails() {
        getMyAllRenewLicenseDetails({}).then((result) => {
            this.licenseCount = result.licenseCount;
            this.licenseResult = JSON.parse(JSON.stringify(result.licenseList));
            this.showRenewLicenses = false;
            if (this.licenseResult.length > 0) {
                this.showRenewLicenses = true;
            }
            this.updateActionMyLicensePage();
        }).catch((error) => {
            console.log(error);
            this.showSpinner = false;
        });
    }

    updateActionMyLicensePage() {
        var temp = JSON.parse(JSON.stringify(this.licenseResult));
        var updatedTemp = [];
        temp.forEach(item => {
            if (this.currentFilter == 'All' || item.status == this.currentFilter) {
                item['menuItems'] = [];
                item.status = translateStatus(item.status, this.labels);
                let renewObj = {};
                if (item.RenewalAllowed == 'true') {
                    if (item.licenseType === 'Temp Permit - BEHIS') {
                        renewObj = {
                            label: 'Extension',
                            value: 'Renew',
                            type: 'Renewal'
                        };
                    } else {
                        renewObj = {
                            label: 'Renew',
                            value: 'Renew',
                            type: 'Renewal'
                        };
                    }
                    item.menuItems.push(renewObj);
                }
                if (item.ReinstatementAllowed == 'true') {
                    item.menuItems.push({ label: 'Reinstate', value: 'Reinstate', type: 'Reinstatement' });
                }
                if (item.AmendmentAllowed == 'true') {
                    item.menuItems.push({ label: 'Amend', value: 'Amend', type: 'Amendment' });
                }
                if (item.InactivationAllowed == 'true') {
                    item.menuItems.push({ label: 'Inactivate', value: 'Inactivate', type: 'Inactivation' });
                }
                if (item.ReactivationAllowed == 'true') {
                    item.menuItems.push({ label: 'Reactivate', value: 'Reactivate', type: 'Reactivation' });
                }
                if (item.RetiredAllowed == 'true') {
                    item.menuItems.push({ label: 'Retired', value: 'Retired', type: 'Retired' });
                }
                if (item['Annual Report SurveyAllowed'] == 'true') {
                    item.menuItems.push({ label: 'Annual Report Survey', value: 'Annual Report Survey', type: 'Annual Report Survey' });
                }
                if (item['Reinstatement by ExamAllowed'] == 'true') {
                    item.menuItems.push({ label: 'Reinstatement by Exam', value: 'Reinstatement by Exam', type: 'Reinstatement By Exam' });
                }
                if (item.menuItems.length > 0) {
                    item.showAction = true;
                }
                item.licenseNumberAriaLabel = 'View ' + item.name;
                updatedTemp.push(item);
            }
        });
        this.recordsData = updatedTemp;
        this.showSpinner = false;
    }

    callFromChild() {
        this.template.querySelector('c-modpr-dashboard-table-details').disabelSpinner();
    }

    openMyLicensePage() {
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: 'My_Licenses__c'
            }
        });
    }
}