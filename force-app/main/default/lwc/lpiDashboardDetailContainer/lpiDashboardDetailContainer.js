import fetchApplicationRecords from '@salesforce/apex/LPI_DashbaordTableCtrl.fetchApplicationRecords';
import fetchPaymentRecord from '@salesforce/apex/LPI_DashbaordTableCtrl.fetchPaymentRecord';
import getMyLicenseDetails from '@salesforce/apex/LPI_DashbaordTableCtrl.getMyLicenseDetails';
import { NavigationMixin } from 'lightning/navigation';
import { LightningElement, track } from 'lwc';
import getCurrentLanguage from '@salesforce/apex/EMP_LanguageCtrl.getCurrentLanguage';
import getLabels from '@salesforce/apex/EMP_LanguageCtrl.getLabels';
import {
    LABEL_API_NAMES,
    mapApiToCamel,
    translateStatus,
    readStoredLanguage,
    writeStoredLanguage
} from 'c/lpLanguageUtils';

export default class LpiDashboardDetailContainer extends NavigationMixin(LightningElement) {
    @track labels = {
        myCertifications: 'My Licenses',
        myApplications: 'My Applications',
        myPayments: 'My Payments',
        myPayment: 'My Payment',
        importantNotice: 'Important Notice',
        noticeLicense: '',
        noticeApplication: '',
        noticePayment: '',
        viewAll: 'View All',
        viewAllCertificationsAria: 'View All Button for My Licenses',
        viewAllApplicationsAria: 'View All Button for My Applications',
        viewAllPaymentsAria: 'View All Button for My Payments',
        certificateNumber: 'License Number',
        type: 'Type',
        issuanceDate: 'Issuance Date',
        expirationDate: 'Expiration Date',
        submittedDate: 'Submitted Date',
        actions: 'Action(s)',
        action: 'Action',
        paymentNumber: 'Payment Number',
        paymentDate: 'Payment Date',
        amount: 'Amount',
        draft: 'Draft',
        submitted: 'Submitted',
        resume: 'Resume',
        withdraw: 'Withdraw',
        reinitiatePayment: 'Reinitiate Payment',
        reInitiatePayment: 'Re-Initiate Payment',
        refundRequest: 'Refund Request',
        requestForRefund: 'Request for Refund',
        active: 'Active',
        status: 'Status',
        applicationNumber: 'Application Number',
        warning: 'Warning'
    };

    @track licenseCount;
    @track appCount;
    @track paymentCount;
    @track Columns = [];
    @track licenseResult = [];
    @track applicationResult = [];
    @track paymentResult = [];
    @track recordsData = [];
    showSpinner = false;
    childCardTitle = 'My Licenses';
    viewAllButtonAriaLabel = 'View All';
    licenseClass = 'slds-col dashboard-card slds-large-size--2-of-12 slds-medium-size--2-of-12 slds-size--12-of-12';
    applicationClass = 'slds-col dashboard-card slds-large-size--2-of-12 slds-medium-size--2-of-12 slds-size--12-of-12';
    paymentClass = 'slds-col dashboard-card slds-large-size--2-of-12 slds-medium-size--2-of-12 slds-size--12-of-12';

    @track licensedata = true;
    @track applicationdata = false;
    @track paymentdata = false;

    connectedCallback() {
        this.showSpinner = true;
        this.initLanguage().then(() => {
            this.getMyLicenseDetails();
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
        } catch (e) {
            // keep defaults
        }
    }

    buildLicenseColumns() {
        return [
            { label: this.labels.certificateNumber, fieldName: 'LicenseNumber' },
            { label: this.labels.type, fieldName: 'LicenseType' },
            { label: this.labels.issuanceDate, fieldName: 'IssuanceDate' },
            { label: this.labels.expirationDate, fieldName: 'ExpirationDate' },
            { label: this.labels.status, fieldName: 'Status' },
            { label: this.labels.actions, fieldName: 'Action' }
        ];
    }

    buildApplicationColumns() {
        return [
            { label: this.labels.applicationNumber, fieldName: 'ApplicationNumber' },
            { label: this.labels.type, fieldName: 'LicenseType' },
            { label: this.labels.submittedDate, fieldName: 'SubmittedDate' },
            { label: this.labels.status, fieldName: 'Status' },
            { label: this.labels.action, fieldName: 'Action' }
        ];
    }

    buildPaymentColumns() {
        return [
            { label: this.labels.paymentNumber, fieldName: 'PaymentNumber' },
            { label: this.labels.type, fieldName: 'LicenseTypeName' },
            { label: this.labels.paymentDate, fieldName: 'Transaction_Date__c' },
            { label: this.labels.amount, fieldName: 'TotalAmount' },
            { label: this.labels.status, fieldName: 'Status' },
            { label: this.labels.action, fieldName: 'Action' }
        ];
    }

    getMyLicenseDetails() {
        getMyLicenseDetails({}).then((result) => {
            this.licenseCount = result.licenseCount;
            this.appCount = result.applicationCount;
            this.paymentCount = result.paymentCount;
            this.licenseResult = JSON.parse(JSON.stringify(result.licenseList));
            this.updateActionMyLicensePage();
        }).catch((error) => {
            console.log(error);
        });
    }

    updateActionMyLicensePage() {
        var temp = JSON.parse(JSON.stringify(this.licenseResult));
        temp.forEach(item => {
            item['menuItems'] = [];
            item.status = translateStatus(item.status, this.labels);
            let renewObj = {};
            if (item.RenewalAllowed == 'true') {
                renewObj = {
                    label: item.licenseType === 'Temp Permit - BEHIS' ? 'Extension' : 'Renew',
                    value: 'Renew',
                    type: 'Renewal'
                };
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
            // item.menuItems.push({ label: 'Student forms', value: 'Student forms', type: 'Student forms' });
            if (item.menuItems.length > 0) {
                item.showAction = true;
            }
            item.licenseeModification = item.licenseeModification == 'true';
            item.licenseNumberAriaLabel = 'View ' + item.name;
        });
        this.recordsData = temp;
        this.onClickLicenceMethod();
    }

    onClickLicenceMethod() {
        this.licensedata = true;
        this.childCardTitle = this.labels.myCertifications;
        this.viewAllButtonAriaLabel = this.labels.viewAllCertificationsAria;
        this.licenseClass = 'slds-col dashboard-card active slds-large-size--2-of-12 slds-medium-size--2-of-12 slds-size--12-of-12';
        this.applicationClass = 'slds-col dashboard-card slds-large-size--2-of-12 slds-medium-size--2-of-12 slds-size--12-of-12';
        this.paymentClass = 'slds-col dashboard-card slds-large-size--2-of-12 slds-medium-size--2-of-12 slds-size--12-of-12';
        this.applicationdata = false;
        this.paymentdata = false;
        this.Columns = this.buildLicenseColumns();
        this.showSpinner = false;
    }

    fetchApplicationRecords() {
        this.showSpinner = true;
        fetchApplicationRecords({}).then((result) => {
            this.applicationResult = JSON.parse(JSON.stringify(result.applicationList));
            this.updateActionMyApplicationPage();
        }).catch((error) => {
            console.log(error);
        });
    }

    updateActionMyApplicationPage() {
        var temp = JSON.parse(JSON.stringify(this.applicationResult));
        temp.forEach(item => {
            item['menuItems'] = [];
            const rawStatus = item.status;
            item.status = translateStatus(rawStatus, this.labels);
            if (rawStatus === 'Draft') {
                item.menuItems.push({ label: this.labels.resume, value: 'Resume', openUrl: true, url: item.resumeurl });
            }
            if (item.showWithdrawn == 'true') {
                item.menuItems.push({ label: this.labels.withdraw, value: 'Withdraw', openUrl: false, url: '' });
            }
            if (item.showreinstate == 'true') {
                item.menuItems.push({ label: this.labels.reinitiatePayment, value: 'Reinitiate Payment', openUrl: true, url: item.reinstatePaymentURL });
            }
            if (rawStatus === 'Submitted' || rawStatus === 'In Progress') {
                item.menuItems.push({
                    label: this.labels.refundRequest,
                    value: 'Refund Request',
                    openUrl: false,
                    url: ''
                });
            }
            if (rawStatus === 'Request for Refund') {
                item.menuItems = [];
                item.showAction = false;
                item.showEyeIcon = false;
            } else if (item.menuItems.length > 0) {
                item.showAction = true;
                item.applicaitonNoAndStausAriaLabel =
                    'show menu of application ' + item.name + ' with status ' + item.status;
            }
            if (rawStatus !== 'Request for Refund' && item.showview == 'true') {
                if (item.menuItems.length === 0) {
                    item.showAction = false;
                }
                item.showEyeIcon = item.url ? true : false;
                item.applicationNumberAriaLabel = 'View ' + item.name;
                item.viewUrl = item.url;
            }
        });
        this.recordsData = temp;
        this.onClickAppMethod();
    }

    onClickAppMethod() {
        this.licensedata = false;
        this.applicationdata = true;
        this.childCardTitle = this.labels.myApplications;
        this.viewAllButtonAriaLabel = this.labels.viewAllApplicationsAria;
        this.applicationClass = 'slds-col dashboard-card active slds-large-size--2-of-12 slds-medium-size--2-of-12 slds-size--12-of-12';
        this.licenseClass = 'slds-col dashboard-card slds-large-size--2-of-12 slds-medium-size--2-of-12 slds-size--12-of-12';
        this.paymentClass = 'slds-col dashboard-card slds-large-size--2-of-12 slds-medium-size--2-of-12 slds-size--12-of-12';
        this.paymentdata = false;
        this.Columns = this.buildApplicationColumns();
        this.showSpinner = false;
    }

    fetchPaymentRecord() {
        this.showSpinner = true;
        fetchPaymentRecord({}).then((result) => {
            this.paymentResult = JSON.parse(JSON.stringify(result.paymentList));
            this.updateActionPaymentPage();
        }).catch((error) => {
            console.log(error);
        });
    }

    updateActionPaymentPage() {
        var temp = JSON.parse(JSON.stringify(this.paymentResult));
        temp.forEach(item => {
            item['menuItems'] = [];
            item.status = translateStatus(item.status, this.labels);
            if (item.Status__c == 'Paid' || item.Status__c == 'Approved') {
                item.showEyeIcon = true;
                item.paymentNumberAriaLabel = 'View ' + item.Name;
            }
            if (item.Status__c == 'Payment Pending' || item.Status__c == 'Canceled') {
                item.menuItems.push({ label: this.labels.reInitiatePayment, value: 'Re-Initiate Payment' });
            }
        });
        this.recordsData = temp;
        this.onClickpaymentMethod();
    }

    onClickpaymentMethod() {
        this.licensedata = false;
        this.applicationdata = false;
        this.paymentdata = true;
        this.childCardTitle = this.labels.myPayment;
        this.viewAllButtonAriaLabel = this.labels.viewAllPaymentsAria;
        this.paymentClass = 'slds-col dashboard-card active slds-large-size--2-of-12 slds-medium-size--2-of-12 slds-size--12-of-12';
        this.licenseClass = 'slds-col dashboard-card slds-large-size--2-of-12 slds-medium-size--2-of-12 slds-size--12-of-12';
        this.applicationClass = 'slds-col dashboard-card slds-large-size--2-of-12 slds-medium-size--2-of-12 slds-size--12-of-12';
        this.Columns = this.buildPaymentColumns();
        this.showSpinner = false;
    }

    callFromChild(event) {
        if (event.detail.uniqueValue == 'Withdraw') {
            this.fetchApplicationRecords();
        }
        this.template.querySelector('c-lpi-dashboard-table-details').disabelSpinner();
    }

    handleViewAll() {
        var pageName;
        if (this.licensedata) {
            pageName = 'My_Licenses__c';
        } else if (this.applicationdata) {
            pageName = 'My_Applications__c';
        } else {
            pageName = 'My_Payments__c';
        }
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: pageName
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

    get showSection() {
        return (this.applicationdata || this.licensedata || this.paymentdata) && this.recordsData.length > 0;
    }

    handleKeyDown(event) {
        if (event.code === 'Enter' || event.keyCode === 13) {
            this.getMyLicenseDetails();
        }
    }
    handleKeyDown1(event) {
        if (event.code === 'Enter' || event.keyCode === 13) {
            this.fetchApplicationRecords();
        }
    }
    handleKeyDown2(event) {
        if (event.code === 'Enter' || event.keyCode === 13) {
            this.fetchPaymentRecord();
        }
    }
}