import fetchAllPaymentRecord from '@salesforce/apex/LPI_DashbaordTableCtrl.fetchAllPaymentRecord';
import getCurrentLanguage from '@salesforce/apex/EMP_LanguageCtrl.getCurrentLanguage';
import getLabels from '@salesforce/apex/EMP_LanguageCtrl.getLabels';
import { LightningElement, api, track } from 'lwc';
import {
    LABEL_API_NAMES,
    mapApiToCamel,
    readStoredLanguage,
    writeStoredLanguage
} from 'c/lpLanguageUtils';

export default class LpiAllPaymentDetailPage extends LightningElement {

    @track labels = {
        myPayments: 'My Payments',
        allPayments: 'All Payments',
        paymentsWord: 'Payments',
        importantNotice: 'Important Notice',
        noticePayment: '',
        paymentNumber: 'Payment Number',
        type: 'Type',
        paymentDate: 'Payment Date',
        amount: 'Amount',
        status: 'Status',
        action: 'Action',
        reInitiatePayment: 'Re-Initiate Payment',
        warning: 'Warning',
        approved: 'Approved'
    };

    childCardTitle = 'All Payments';
    @track licensedata = false;
    @track applicationdata = false;
    @track paymentdata = true;
    @track recordsData = [];
    @track statusFilter = [];
    @track myPaymentsColumns = [];
    currentFilter = 'All';
    showSpinner = false;
    isAllPayment = false;
    @api showPayments;

    connectedCallback() {
        this.showSpinner = true;
        if (this.showPayments == 'true') {
            this.isAllPayment = true;
            this.childCardTitle = this.labels.allPayments;
        } else {
            this.isAllPayment = false;
            this.childCardTitle = this.labels.myPayments;
        }
        this.initLanguage().then(() => {
            this.buildColumns();
            this.fetchPaymentRecord();
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
            this.childCardTitle = this.isAllPayment
                ? this.labels.allPayments
                : this.labels.myPayments;
        } catch (e) {
            // keep defaults
        }
    }

    buildColumns() {
        this.myPaymentsColumns = [
            { label: this.labels.paymentNumber, fieldName: 'PaymentNumber' },
            { label: this.labels.type, fieldName: 'LicenseTypeName' },
            { label: this.labels.paymentDate, fieldName: 'Transaction_Date__c' },
            { label: this.labels.amount, fieldName: 'TotalAmount' },
            { label: this.labels.status, fieldName: 'Status' },
            { label: this.labels.action, fieldName: 'Action' }
        ];
    }

    fetchPaymentRecord() {
        fetchAllPaymentRecord({ showAllPayments: this.isAllPayment }).then((result) => {
            this.paymentCount = result.paymentCount;
            this.paymentResult = JSON.parse(JSON.stringify(result.paymentList));
            this.statusCountMap = JSON.parse(JSON.stringify(result.statusWithCount));
            this.statusFilter = [];
            this.getStatusFilterValues();
            this.updateActionPaymentPage();
        }).catch((error) => {
            this.showSpinner = false;
            console.log(error);
        });
    }

    getStatusFilterValues() {
        var obj = {};
        if (this.isAllPayment) {
            obj['label'] = this.labels.allPayments;
        } else {
            obj['label'] = this.labels.myPayments;
        }
        obj['value'] = 'All';
        obj['Count'] = this.paymentCount;
        obj['class'] = 'slds-col dashboard-card active';
        this.statusFilter.push(obj);
        for (const [key, value] of Object.entries(this.statusCountMap)) {
            obj = {};
            obj['label'] = key;
            obj['value'] = key;
            obj['Count'] = value;
            obj['class'] = 'slds-col dashboard-card';
            this.statusFilter.push(obj);
        }
    }

    updateActionPaymentPage() {
        var temp = JSON.parse(JSON.stringify(this.paymentResult));
        var updatedTemp = [];
        temp.forEach(item => {
            if (this.currentFilter == 'All' || item.Status__c == this.currentFilter) {
                item['menuItems'] = [];
                if (item.Status__c == 'Paid' || item.Status__c == 'Approved') {
                    item.showEyeIcon = true;
                    item.paymentNumberAriaLabel = 'View ' + item.Name;
                }
                if (item.Status__c == 'Payment Pending' || item.Status__c == 'Canceled') {
                    item.menuItems.push({
                        label: this.labels.reInitiatePayment,
                        value: 'Re-Initiate Payment'
                    });
                }
                updatedTemp.push(item);
            }
        });
        this.recordsData = updatedTemp;
        this.showSpinner = false;
    }

    getMyPaymentDetails(event) {
        this.showSpinner = true;
        this.currentFilter = event.target.dataset.id;
        this.updateActionPaymentPage();
        this.updateStatusFilterValues();
    }

    updateStatusFilterValues() {
        this.statusFilter.forEach(row => {
            if (row['value'] == this.currentFilter) {
                row['class'] = 'slds-col dashboard-card active';
                if (row['value'] == 'All') {
                    this.childCardTitle = this.isAllPayment
                        ? this.labels.allPayments
                        : this.labels.myPayments;
                } else {
                    this.childCardTitle = row['label'] + ' ' + this.labels.paymentsWord;
                }
            } else {
                row['class'] = 'slds-col dashboard-card';
            }
        });
    }

    handleKeyDown(event) {
        if (event.code === 'Enter' || event.keyCode === 13) {
            this.getMyPaymentDetails(event);
        }
    }
}