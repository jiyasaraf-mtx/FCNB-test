import fetchSelectedApplicationRecords from '@salesforce/apex/EMP_DashbaordTableCtrl.fetchSelectedApplicationRecords';
import fetchApplicationRecords from '@salesforce/apex/LPI_DashbaordTableCtrl.fetchApplicationRecords';
import fetchPaymentRecord from '@salesforce/apex/LPI_DashbaordTableCtrl.fetchPaymentRecord';
import getMyLicenseDetails from '@salesforce/apex/LPI_DashbaordTableCtrl.getMyLicenseDetails';
// import LP_Design from '@salesforce/resourceUrl/LP_Design';
import { NavigationMixin } from 'lightning/navigation';
import { LightningElement, track } from 'lwc';
export default class EmpDashboardDetailContainer extends LightningElement {
    @track licenseCount;
    @track appCount;
    @track paymentCount;
    @track Columns=[];
    @track licenseResult = [];
    @track applicationResult=[];
    @track paymentResult=[];
    @track recordsData=[];
    showSpinner=false;
    childCardTitle = 'My Licenses';
    viewAllButtonAriaLabel = 'View All';
    licenseClass = 'slds-col dashboard-card slds-large-size--2-of-12 slds-medium-size--2-of-12 slds-size--12-of-12';
    applicationClass = 'slds-col dashboard-card slds-large-size--2-of-12 slds-medium-size--2-of-12 slds-size--12-of-12';
    paymentClass = 'slds-col dashboard-card slds-large-size--2-of-12 slds-medium-size--2-of-12 slds-size--12-of-12';
    
    @track licensedata=true;
    @track applicationdata=false;
    @track paymentdata=false;

    // myLicense = LP_Design + '/images/all_licenses.svg';
    // myApplications = LP_Design + '/images/all_application.svg';
    // myPayments = LP_Design + '/images/all_payments.svg';

    myLicenseColumns = [
        { label: 'License Number', fieldName: 'LicenseNumber' },
        { label: 'Type', fieldName: 'LicenseType' },
        { label: 'Issuance Date', fieldName: 'IssuanceDate' },
        {label:'Expiration Date', fieldName:'ExpirationDate'},
        {label:'Status',fieldName:'Status'},
        {label: 'Action(s)', fieldName:'Action'} //changed the label as per I-241404
    ]
    // MyApplicationColumns = [
    //     { label: 'License Type', fieldName: 'LicenseType' },
    //     { label: 'Application Type', fieldName: 'ApplicationType' },
    //     { label: 'Sub Type', fieldName: 'SubType' },
    //     { label: 'Application Number', fieldName: 'ApplicationNumber' },
    //     { label: 'Applicant/Business Name', fieldName: 'ApplicantBusinessName' },
    //     {label:'Submitted Date', fieldName:'SubmittedDate'},
    //     {label:'Status',fieldName:'Status'},
    //     {label: 'Action', fieldName:'Action'}
    // ]
    MyApplicationColumns = [
        { label: 'Application Number', fieldName: 'ApplicationNumber' },
        { label: 'Type', fieldName: 'LicenseType' },
        {label:'Submitted Date', fieldName:'SubmittedDate'},
        {label:'Status',fieldName:'Status'},
        {label: 'Action', fieldName:'Action'}
    ]
    // MyPaymentsColumns = [
    //     { label: 'Payment Number', fieldName: 'PaymentNumber' },
    //     { label: 'Payment Date', fieldName: 'Transaction_Date__c' },
    //     { label: 'Total Amount', fieldName: 'TotalAmount' },
    //     { label: 'Application Number', fieldName: 'ApplicationNumber' },
    //     { label: 'License Type', fieldName: 'LicenseTypeName' },
    //     { label: 'Application Sub Type', fieldName: 'SubType' },
    //     {label:'Status',fieldName:'Status'},
    //     {label: 'Action', fieldName:'Action'}
    // ]
    MyPaymentsColumns = [
        { label: 'Payment Number', fieldName: 'PaymentNumber' },
        { label: 'Type', fieldName: 'LicenseTypeName' },
        { label: 'Payment Date', fieldName: 'Transaction_Date__c' },
        { label: 'Amount', fieldName: 'TotalAmount' },
        {label:'Status',fieldName:'Status'},
        {label: 'Action', fieldName:'Action'}
    ]

    connectedCallback(){
        this.showSpinner = true;
        this.fetchSelectedApplicationRecord();
    }
    fetchSelectedApplicationRecord(){
        fetchSelectedApplicationRecords().then((result) => {
            this.showSpinner = false;
            console.log(' hhhhhhhhh: ', JSON.stringify(result));
            console.log('OUTPUT : ',result);
            this.applicationData = result;
            this.appCount = result.length;

        
        }).catch((error)=>{
            console.log(error);
            this.showSpinner = false;
        })
    }
    getMyLicenseDetails(){
        getMyLicenseDetails({}).then((result)=>{
            this.licenseCount=result.licenseCount;
            this.appCount = result.applicationCount;
            this.paymentCount = result.paymentCount;
            this.licenseResult = JSON.parse(JSON.stringify(result.licenseList));
            this.updateActionMyLicensePage();
            console.log('test');
        }).catch((error)=>{
            console.log(error);
        })
    }
    updateActionMyLicensePage(){
        var temp = JSON.parse(JSON.stringify(this.licenseResult));
        console.log('tempList ==> '+JSON.stringify(this.licenseResult));
        temp.forEach( item=>{
            item['menuItems']=[];
            let renewObj = {};
            if(item.RenewalAllowed == 'true'){
                if (item.licenseType === 'Temp Permit - BEHIS') {
                    renewObj = {
                        label: 'Extension',
                        value: 'Renew',
                        type : 'Renewal'
                    };
                }
                else {
                    renewObj = {
                        label: 'Renew',
                        value: 'Renew',
                        type : 'Renewal'
                    };
                }
                item.menuItems.push(renewObj);
            }   
            if(item.ReinstatementAllowed == 'true'){
                let reinstateObj = {
                    label: 'Reinstate',
                    value: 'Reinstate',
                    type : 'Reinstatement'
                };
                item.menuItems.push(reinstateObj);
            }
            if(item['Re-licensureAllowed'] == 'true'){
                let reinstateObj = {
                    label: 'Re-licensure',
                    value: 'Re-licensure',
                    type : 'Re-licensure'
                };
                item.menuItems.push(reinstateObj);
            }
            if(item['Re-authorizationAllowed'] == 'true'){
                let reinstateObj = {
                    label: 'Re-authorize',
                    value: 'Re-authorize',
                    type : 'Re-authorization'
                };
                item.menuItems.push(reinstateObj);
            }
            if(item.AmendmentAllowed == 'true'){
                let amendmentObj = {
                    label: 'Amend',
                    value: 'Amend',
                    type : 'Amendment'
                };
                item.menuItems.push(amendmentObj);
            }
            if(item.InactivationAllowed == 'true'){
                let inactivationObj = {
                    label: 'Inactivate',
                    value: 'Inactivate',
                    type : 'Inactivation'
                };
                item.menuItems.push(inactivationObj);
            }
            if(item.ReactivationAllowed == 'true'){
                let reactivationObj = {
                    label: 'Reactivate',
                    value: 'Reactivate',
                    type : 'Reactivation'
                };
                item.menuItems.push(reactivationObj);
            }
            if(item.RetiredAllowed == 'true'){
                let retiredObj = {
                    label: 'Retired',
                    value: 'Retired',
                    type : 'Retired'
                };
                item.menuItems.push(retiredObj);
            }
            if(item['Annual Report SurveyAllowed'] == 'true'){
                let annualObj = {
                    label: 'Annual Report Survey',
                    value: 'Annual Report Survey',
                    type : 'Annual Report Survey'
                };
                item.menuItems.push(annualObj);
            }
            if(item['Reinstatement by ExamAllowed'] == 'true'){
                let examObj = {
                    label: 'Reinstatement by Exam',
                    value: 'Reinstatement by Exam',
                    type : 'Reinstatement By Exam'
                };
                item.menuItems.push(examObj);
            }
            let manageAccountObj = {
                label: 'Manage Account',
                value: '',
                type : 'Manage Account'
            };
            item.menuItems.push(manageAccountObj);

            if(item.menuItems.length > 0){
                item.showAction=true;
            }
            if(item.licenseeModification == 'true'){
                item.licenseeModification = true;
            }else{
                item.licenseeModification = false;
            }
            item.licenseNumberAriaLabel = "View " + item.name;
        });
        this.recordsData = temp;
        this.onClickLicenceMethod();
    }
    onClickLicenceMethod(){ 
        this.licensedata=true;
        this.childCardTitle = 'My Licenses';
        this.viewAllButtonAriaLabel = 'View All Button for My Licenses';
        this.licenseClass = 'slds-col dashboard-card active slds-large-size--2-of-12 slds-medium-size--2-of-12 slds-size--12-of-12';
        this.applicationClass = 'slds-col dashboard-card slds-large-size--2-of-12 slds-medium-size--2-of-12 slds-size--12-of-12';
        this.paymentClass = 'slds-col dashboard-card slds-large-size--2-of-12 slds-medium-size--2-of-12 slds-size--12-of-12';
        this.applicationdata=false;
        this.paymentdata=false;
        this.Columns=null;
        this.Columns=this.myLicenseColumns;
        this.showSpinner = false;
    }
    fetchApplicationRecords(){
        window.open('/employerportal/s/application', '_self');

    }
    updateActionMyApplicationPage(){
        var temp = JSON.parse(JSON.stringify(this.applicationResult));
        temp.forEach( item=>{
            item['menuItems']=[];
            if(item.status == 'Draft'){
                let resumeObj = {
                    label: 'Resume',
                    value: 'Resume',
                    openUrl : true,
                    url : item.resumeurl
                };
                item.menuItems.push(resumeObj);
            }
            if(item.showWithdrawn == 'true'){
                let withDrawObj = {
                    label: 'Withdraw',
                    value: 'Withdraw',
                    openUrl : false,
                    url : ''
                };
                item.menuItems.push(withDrawObj);
            }
            if(item.showreinstate == 'true'){
                let reinstateObj = {
                    label: 'Reinitiate Payment',
                    value: 'Reinitiate Payment',
                    openUrl : true,
                    url : item.reinstatePaymentURL
                };
                item.menuItems.push(reinstateObj);
            }
            if(item.menuItems.length > 0){
                item.showAction=true;
            }
            if(item.showview == 'true'){
                item.showAction=false;
                item.showEyeIcon=item.url?true:false;
                item.applicationNumberAriaLabel = "View " + item.name;
                item.viewUrl = item.url;
            }
        });
        this.recordsData = temp;
        this.onClickAppMethod();
    }
    onClickAppMethod(){
        this.licensedata=false;
        this.applicationdata=true;
        this.childCardTitle = 'My Applications';
        this.viewAllButtonAriaLabel = 'View All Button for My Applications';
        this.applicationClass = 'slds-col dashboard-card active slds-large-size--2-of-12 slds-medium-size--2-of-12 slds-size--12-of-12';
        this.licenseClass = 'slds-col dashboard-card slds-large-size--2-of-12 slds-medium-size--2-of-12 slds-size--12-of-12';
        this.paymentClass = 'slds-col dashboard-card slds-large-size--2-of-12 slds-medium-size--2-of-12 slds-size--12-of-12';
        this.paymentdata=false;
        this.Columns=null;
        this.Columns=this.MyApplicationColumns;
        this.showSpinner = false;
    }
    fetchPaymentRecord(){
        this.showSpinner = true;
        fetchPaymentRecord({}).then((result)=>{
            this.paymentResult = JSON.parse(JSON.stringify(result.paymentList));
            this.updateActionPaymentPage();
        }).catch((error)=>{
            console.log(error);
        })
    }
    updateActionPaymentPage(){
        var temp = JSON.parse(JSON.stringify(this.paymentResult));
        temp.forEach( item=>{
            item['menuItems']=[];
            if(item.Status__c == 'Paid' || item.Status__c == 'Approved'){
                item.showEyeIcon = true;
                item.paymentNumberAriaLabel = "View " + item.Name;
            }
            if(item.Status__c == 'Payment Pending' || item.Status__c == 'Canceled'){
                let reinitiateObj = {
                    label: 'Re-Initiate Payment',
                    value: 'Re-Initiate Payment'
                };
                item.menuItems.push(reinitiateObj);
            }
        });
        this.recordsData = temp;
        this.onClickpaymentMethod();
    }
    onClickpaymentMethod(event){
        this.licensedata=false;
        this.applicationdata=false;
        this.paymentdata=true;
        this.childCardTitle = 'My Payment';
        this.viewAllButtonAriaLabel = 'View All Button for My Payments';
        this.paymentClass = 'slds-col dashboard-card active slds-large-size--2-of-12 slds-medium-size--2-of-12 slds-size--12-of-12';
        this.licenseClass = 'slds-col dashboard-card slds-large-size--2-of-12 slds-medium-size--2-of-12 slds-size--12-of-12';
        this.applicationClass = 'slds-col dashboard-card slds-large-size--2-of-12 slds-medium-size--2-of-12 slds-size--12-of-12';
        this.Columns=null;
        this.Columns=this.MyPaymentsColumns;
        this.showSpinner = false;
    }
    callFromChild(event){
        if(event.detail.uniqueValue == 'Withdraw'){
            this.fetchApplicationRecords();
        }
        this.template.querySelector("c-lpi-dashboard-table-details").disabelSpinner();
    }
    handleViewAll(){
        var pageName;
        if(this.licensedata){
            pageName = 'My_Licenses__c';
        }else if(this.applicationdata){
            pageName = 'My_Applications__c';
        }else{
            pageName = 'My_Payments__c';
        }
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: pageName
            }
        });
    }

    spinnerHandler(event){
        const spinner = event.detail.showSpinner;
        if(spinner == true){
            this.showSpinner = true;
        }else if(spinner == false){
            this.showSpinner = false;
        }
    }

    get showSection() {
        return (this.applicationdata || this.licensedata || this.paymentdata) && this.recordsData.length > 0
    }
    //start-Added for I-257472
    handleKeyDown(event){
        if(event.code === 'Enter' || event.keyCode === 13){
            this.getMyLicenseDetails();
        }
    }
    handleKeyDown1(event){
        if(event.code === 'Enter' || event.keyCode === 13){
            this.fetchApplicationRecords();
        }
    }
    handleKeyDown2(event){
        if(event.code === 'Enter' || event.keyCode === 13){
            this.fetchPaymentRecord();
        }
    }
}