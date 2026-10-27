/**
 * @                  : 
 * @author            : Abel David Solomon
 * @group             : 
 * @last modified on  : 07-30-2024
 * @last modified by  : Abel David Solomon
**/
import fetchAllApplicationRecords from '@salesforce/apex/LPI_DashbaordTableCtrl.fetchAllApplicationRecords';
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

export default class LpiAllApplicationDetailPage extends LightningElement {

    @track labels = {
        myApplications: 'My Applications',
        allApplications: 'All Applications',
        importantNotice: 'Important Notice',
        noticeApplication: '',
        applicationsWord: 'Applications',
        applicationNumber: 'Application Number',
        type: 'Type',
        submittedDate: 'Submitted Date',
        status: 'Status',
        action: 'Action',
        draft: 'Draft',
        submitted: 'Submitted',
        licenseIssued: 'License Issued',
        inProgress: 'In Progress',
        approved: 'Approved',
        requestForRefund: 'Request for Refund',
        resume: 'Resume',
        withdraw: 'Withdraw',
        reinitiatePayment: 'Reinitiate Payment',
        refundRequest: 'Refund Request',
        warning: 'Warning'
    };

    childCardTitle = 'My Applications';
    @track licensedata = false;
    @track applicationdata = true;
    @track paymentdata = false;
    @track recordsData = [];
    @track statusFilter = [];
    @track myApplicationColumns = [];
    currentFilter = 'All';
    showSpinner = false;
    isAllApplication = false;
    @api showApplications;
    @track statuswithIconSet = new Set(['Draft', 'Submitted', 'License Issued', 'In Progress', 'Approved', 'Request for Refund', 'My Applications']);

    connectedCallback() {
        this.showSpinner = true;
        if (this.showApplications == 'true') {
            this.isAllApplication = true;
            this.childCardTitle = this.labels.allApplications;
        } else {
            this.isAllApplication = false;
            this.childCardTitle = this.labels.myApplications;
        }
        this.initLanguage().then(() => {
            this.buildColumns();
            this.fetchAllApplicationRecords();
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
            if (this.isAllApplication) {
                this.childCardTitle = this.labels.allApplications;
            } else {
                this.childCardTitle = this.labels.myApplications;
            }
        } catch (e) {
            // keep defaults
        }
    }

    buildColumns() {
        this.myApplicationColumns = [
            { label: this.labels.applicationNumber, fieldName: 'ApplicationNumber' },
            { label: this.labels.type, fieldName: 'LicenseType' },
            { label: this.labels.submittedDate, fieldName: 'SubmittedDate' },
            { label: this.labels.status, fieldName: 'Status' },
            { label: this.labels.action, fieldName: 'Action' }
        ];
    }

    getStatusDisplayLabel(statusKey) {
        if (statusKey === 'All') {
            return this.isAllApplication ? this.labels.allApplications : this.labels.myApplications;
        }
        if (statusKey === 'My Applications') {
            return this.labels.myApplications;
        }
        return translateStatus(statusKey, this.labels);
    }

    fetchAllApplicationRecords() {
        fetchAllApplicationRecords({ showAllApplications: this.isAllApplication }).then((result) => {
            this.applicationCount = result.applicationCount;
            this.applicationResult = JSON.parse(JSON.stringify(result.applicationList));
            this.statusCountMap = JSON.parse(JSON.stringify(result.statusWithCount));
            this.statusFilter = [];
            this.getStatusFilterValues();
            this.updateActionMyApplicationPage();
        }).catch((error) => {
            console.log(error);
            this.showSpinner = false;
        });
    }

    getStatusFilterValues() {
        var obj = {};
        obj['label'] = this.getStatusDisplayLabel('All');
        obj['value'] = 'All';
        obj['Count'] = this.applicationCount;
        obj['class'] = 'slds-col dashboard-card active';
        obj['iconUrl'] = 'material-icon material-icon-All';
        this.statusFilter.push(obj);
        for (const [key, value] of Object.entries(this.statusCountMap)) {
            obj = {};
            obj['label'] = this.getStatusDisplayLabel(key);
            obj['value'] = key;
            obj['Count'] = value;
            obj['class'] = 'slds-col dashboard-card';
            obj['iconUrl'] = 'material-icon material-icon-' + (this.statuswithIconSet.has(key) ? obj['value'].replace(/ /g, '_') : 'Default');
            this.statusFilter.push(obj);
        }
    }

    updateActionMyApplicationPage() {
        var temp = JSON.parse(JSON.stringify(this.applicationResult));
        var updatedTemp = [];
        temp.forEach(item => {
            if (this.currentFilter == 'All' || item.status == this.currentFilter) {
                item['menuItems'] = [];
                const rawStatus = item.status;
                item.status = translateStatus(rawStatus, this.labels);
                if (rawStatus == 'Draft') {
                    item.menuItems.push({
                        label: this.labels.resume,
                        value: 'Resume',
                        openUrl: true,
                        url: item.resumeurl
                    });
                }
                if (item.showWithdrawn == 'true') {
                    item.menuItems.push({
                        label: this.labels.withdraw,
                        value: 'Withdraw',
                        openUrl: false,
                        url: ''
                    });
                }
                if (item.showreinstate == 'true') {
                    item.menuItems.push({
                        label: this.labels.reinitiatePayment,
                        value: 'Reinitiate Payment',
                        openUrl: true,
                        url: item.reinstatePaymentURL
                    });
                }
                if (rawStatus == 'Submitted' || rawStatus == 'In Progress') {
                    item.menuItems.push({
                        label: this.labels.refundRequest,
                        value: 'Refund Request',
                        openUrl: false,
                        url: ''
                    });
                }
                if (rawStatus == 'Request for Refund') {
                    item.menuItems = [];
                    item.showAction = false;
                    item.showEyeIcon = false;
                } else if (item.menuItems.length > 0) {
                    item.showAction = true;
                    item.applicaitonNoAndStausAriaLabel = 'show menu of application ' + item.name + ' with status ' + item.status;
                }
                if (rawStatus != 'Request for Refund' && item.showview == 'true') {
                    if (item.menuItems.length === 0) {
                        item.showAction = false;
                    }
                    item.showEyeIcon = item.url ? true : false;
                    item.viewUrl = item.url;
                    item.applicationNumberAriaLabel = 'View ' + item.name;
                }
                updatedTemp.push(item);
            }
        });
        this.recordsData = updatedTemp;
        this.showSpinner = false;
    }

    callFromChild(event) {
        if (event.detail.uniqueValue == 'Withdraw') {
            this.fetchAllApplicationRecords();
        }
        this.template.querySelector('c-lpi-dashboard-table-details').disabelSpinner();
    }

    getMyApplicationDetails(event) {
        this.showSpinner = true;
        this.currentFilter = event.target.dataset.id;
        this.updateActionMyApplicationPage();
        this.updateStatusFilterValues();
    }

    updateStatusFilterValues() {
        this.statusFilter.forEach(row => {
            if (row['value'] == this.currentFilter) {
                row['class'] = 'slds-col dashboard-card active';
                if (row['value'] == 'All') {
                    this.childCardTitle = this.getStatusDisplayLabel('All');
                } else {
                    this.childCardTitle = this.getStatusDisplayLabel(row['value']) + ' ' + this.labels.applicationsWord;
                }
            } else {
                row['class'] = 'slds-col dashboard-card';
            }
        });
    }

    handleKeyDown(event) {
        if (event.code === 'Enter' || event.keyCode === 13) {
            this.getMyApplicationDetails(event);
        }
    }
}