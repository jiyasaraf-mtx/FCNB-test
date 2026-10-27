import getMyAllLicenseDetails from '@salesforce/apex/LPI_DashbaordTableCtrl.getMyAllLicenseDetails';
import getCurrentLanguage from '@salesforce/apex/EMP_LanguageCtrl.getCurrentLanguage';
import getLabels from '@salesforce/apex/EMP_LanguageCtrl.getLabels';
import { LightningElement, api, track } from 'lwc';
import {
    LABEL_API_NAMES,
    mapApiToCamel,
    translateStatus,
    readStoredLanguage,
    writeStoredLanguage
} from 'c/lpLanguageUtils';

export default class LpiAllLicenseDetailPage extends LightningElement {

    @track labels = {
        myCertifications: 'My Licenses',
        allCertifications: 'All Licenses',
        myLicenses: 'My Licenses',
        allLicenses: 'All Licenses',
        licensesWord: 'Licenses',
        importantNotice: 'Important Notice',
        noticeLicense: '',
        certificateNumber: 'License Number',
        licenceType: 'License Type',
        issuanceDate: 'Issuance Date',
        expirationDate: 'Expiration Date',
        status: 'Status',
        actions: 'Action(s)',
        searchLicenseTypePlaceholder: 'Search using license number or license type..',
        warning: 'Warning',
        active: 'Active',
        draft: 'Draft'
    };

    childCardTitle = 'My Licenses';
    @track licensedata = true;
    @track applicationdata = false;
    @track paymentdata = false;
    @track recordsData = [];
    @track mainData = [];
    @track statusFilter = [];
    @track myLicenseColumns = [];
    currentFilter = 'All';
    showSpinner = false;
    isAllLicense = false;
    isSearched = false;
    @api showLicenses;
    @track otherStatus = new Set(['Revoked', 'Draft']);

    handleSearch(event) {
        let value = event.target.value.toLowerCase();
        if (value.length >= 3) {
            this.isSearched = true;
            this.showSpinner = true;
            let filteredRecords = this.mainData.filter(record => (record.name.includes(value) || record.licenseType.toLowerCase().includes(value)));
            this.recordsData = filteredRecords;
            // eslint-disable-next-line @lwc/lwc/no-async-operation
            setTimeout(() => {
                this.showSpinner = false;
            }, 1000);
        } else if (this.isSearched) {
            this.recordsData = this.mainData;
            this.isSearched = false;
        }
    }

    connectedCallback() {
        this.showSpinner = true;
        if (this.showLicenses == 'true') {
            this.isAllLicense = true;
            this.childCardTitle = this.labels.allCertifications;
        } else {
            this.isAllLicense = false;
            this.childCardTitle = this.labels.myCertifications;
        }
        this.initLanguage().then(() => {
            this.buildColumns();
            this.getMyAllLicenseDetails();
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
            this.childCardTitle = this.isAllLicense
                ? this.labels.allCertifications
                : this.labels.myCertifications;
        } catch (e) {
            // keep defaults
        }
    }

    buildColumns() {
        this.myLicenseColumns = [
            { label: this.labels.certificateNumber, fieldName: 'LicenseNumber' },
            { label: this.labels.licenceType, fieldName: 'LicenseType' },
            { label: this.labels.issuanceDate, fieldName: 'IssuanceDate' },
            { label: this.labels.expirationDate, fieldName: 'ExpirationDate' },
            { label: this.labels.status, fieldName: 'Status' },
            { label: this.labels.actions, fieldName: 'Action' }
        ];
    }

    getStatusDisplayLabel(statusKey) {
        if (statusKey === 'All') {
            return this.isAllLicense ? this.labels.allLicenses : this.labels.myLicenses;
        }
        return translateStatus(statusKey, this.labels);
    }

    getMyAllLicenseDetails() {
        getMyAllLicenseDetails({ showAllLicenses: this.isAllLicense }).then((result) => {
            this.licenseCount = result.licenseCount;
            this.licenseResult = JSON.parse(JSON.stringify(result.licenseList));
            this.statusCountMap = JSON.parse(JSON.stringify(result.statusWithCount));
            this.statusFilter = [];
            this.getStatusFilterValues();
            this.updateActionMyLicensePage();
        }).catch((error) => {
            console.log(error);
            this.showSpinner = false;
        });
    }

    getStatusFilterValues() {
        var obj = {};
        obj['label'] = this.getStatusDisplayLabel('All');
        obj['value'] = 'All';
        obj['Count'] = this.licenseCount;
        obj['class'] = 'slds-col dashboard-card active';
        obj['iconUrl'] = 'material-icon material-icon-All';
        this.statusFilter.push(obj);
        for (const [key, value] of Object.entries(this.statusCountMap)) {
            obj = {};
            obj['label'] = this.getStatusDisplayLabel(key);
            obj['value'] = key;
            obj['Count'] = value;
            obj['class'] = 'slds-col dashboard-card';
            obj['iconUrl'] = this.otherStatus.has(key)
                ? 'material-icon material-icon-Default'
                : 'material-icon material-icon-' + obj['value'];
            this.statusFilter.push(obj);
        }
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
                if (item['Re-licensureAllowed'] == 'true') {
                    item.menuItems.push({ label: 'Re-licensure', value: 'Re-licensure', type: 'Re-licensure' });
                }
                if (item['Re-authorizationAllowed'] == 'true') {
                    item.menuItems.push({ label: 'Re-authorize', value: 'Re-authorize', type: 'Re-authorization' });
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
                item.menuItems.push({ label: 'Manage Account', value: '', type: 'Manage Account' });

                if (item.menuItems.length > 0) {
                    item.showAction = true;
                }
                item.licenseNumberAriaLabel = 'View ' + item.name;
                updatedTemp.push(item);
            }
        });
        this.recordsData = updatedTemp;
        this.mainData = updatedTemp;
        this.showSpinner = false;
    }

    callFromChild(event) {
        if (event.detail.uniqueValue == 'Withdraw') {
            this.fetchApplicationRecords();
        }
        this.template.querySelector('c-lpi-dashboard-table-details').disabelSpinner();
    }

    getMyLicenseDetails(event) {
        this.showSpinner = true;
        this.currentFilter = event.target.dataset.id;
        this.updateActionMyLicensePage();
        this.updateStatusFilterValues();
    }

    updateStatusFilterValues() {
        this.statusFilter.forEach(row => {
            if (row['value'] == this.currentFilter) {
                row['class'] = 'slds-col dashboard-card active';
                if (row['value'] == 'All') {
                    this.childCardTitle = this.getStatusDisplayLabel('All');
                } else {
                    this.childCardTitle = this.getStatusDisplayLabel(row['value']) + ' ' + this.labels.licensesWord;
                }
            } else {
                row['class'] = 'slds-col dashboard-card';
            }
        });
    }

    spinnerHandler(event) {
        const spinner = event.detail.showSpinner;
        if (spinner == true) {
            this.showSpinner = true;
        } else if (spinner == false) {
            this.showSpinner = false;
        }
    }

    handleKeyDown(event) {
        if (event.code === 'Enter' || event.keyCode === 13) {
            this.getMyLicenseDetails(event);
        }
    }
}