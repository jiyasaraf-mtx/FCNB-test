import fetchSelectedApplicationRecords from '@salesforce/apex/EMP_DashbaordTableCtrl.fetchSelectedApplicationRecords';
import fetchAllApplicationRecords from '@salesforce/apex/LPI_DashbaordTableCtrl.fetchAllApplicationRecords';

import { LightningElement, api, track } from 'lwc';
export default class EmpAllApplicationDetailPage extends LightningElement {
    childCardTitle = 'Applications';
    @track licensedata=false;
    @track applicationdata=true;
    @track paymentdata=false;
    @track recordsData = [];
    @track appCount;
    @track statusFilter = [];
    currentFilter = 'All';
    showSpinner = false;
    isAllApplication = false;
    @api showApplications;
		@track statuswithIconSet = new Set(['Draft', 'Submitted', 'License Issued', 'In Progress', 'Approved','My Applications']);

    // myApplicationColumns = [
    //     { label: 'License Type', fieldName: 'LicenseType' },
    //     { label: 'Application Type', fieldName: 'ApplicationType' },
    //     { label: 'Sub Type', fieldName: 'SubType' },
    //     { label: 'Application Number', fieldName: 'ApplicationNumber' },
    //     {label : 'Applicant/Business Name' , fieldName : 'ApplicantBusinessName'},
    //     {label:'Submitted Date', fieldName:'SubmittedDate'},
    //     {label:'Status',fieldName:'Status'},
    //     {label: 'Action', fieldName:'Action'}
    // ]
    myApplicationColumns = [
        { label: 'Application Number', fieldName: 'ApplicationNumber' },
        { label: 'Type', fieldName: 'LicenseType' },
        {label:'Submitted Date', fieldName:'SubmittedDate'},
        {label:'Status',fieldName:'Status'},
        {label: 'Action', fieldName:'Action'}
    ]
    connectedCallback(){
        this.showSpinner = true;
        if(this.showApplications == 'true'){
            this.isAllApplication = true;
            this.childCardTitle = 'All Applications';
        }else{
            this.isAllApplication = false;
            this.childCardTitle = 'Applications';
        }
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
    getStatusFilterValues(){
        var obj = {};
        if(this.isAllApplication){
            obj['label'] = 'All Applications';
        }else{
            obj['label'] = 'My Applications';
        }
        obj['value'] = 'All';
        obj['Count'] = this.applicationCount;
        obj['class'] = 'slds-col dashboard-card active';
        obj['iconUrl'] = 'material-icon material-icon-All';
        this.statusFilter.push(obj);
        for(const [key, value] of Object.entries(this.statusCountMap)) {
            obj = {};
            obj['label'] = key;
            obj['value'] = key;
            obj['Count'] = value;
            obj['class'] = 'slds-col dashboard-card';
						console.log('')
						console.log('$$$',key,' using icon --> ','material-icon material-icon-' + (this.statuswithIconSet.has(key) ? obj['value'].replace(" ", "_") : 'Default'));
						obj['iconUrl'] = 'material-icon material-icon-' + (this.statuswithIconSet.has(key) ? obj['value'].replace(" ", "_") : 'Default');
            // obj['iconUrl'] = LP_Design + '/images/cards/'+obj['value'].replace(" ", "_")+'.svg';
            this.statusFilter.push(obj);
        }
    }
    updateActionMyApplicationPage(){
        var temp = JSON.parse(JSON.stringify(this.applicationResult));
        var updatedTemp = [];
        temp.forEach( item=>{
            if(this.currentFilter == 'All' || item.status == this.currentFilter){
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
                    item.applicaitonNoAndStausAriaLabel = "show menu of application " + item.name + " with status " + item.status; 
                }
                if(item.showview == 'true'){
                    item.showAction=false;
                    item.showEyeIcon=item.url?true:false;
                    item.viewUrl = item.url;
                    item.applicationNumberAriaLabel = "View " + item.name;

                }
                updatedTemp.push(item);

            }
        });
        this.recordsData = updatedTemp;
        this.showSpinner = false;
    }
    callFromChild(event){
        if(event.detail.uniqueValue == 'Withdraw'){
            this.fetchAllApplicationRecords();
        }
        this.template.querySelector("c-lpi-dashboard-table-details").disabelSpinner();
    }
    getMyApplicationDetails(event){
        this.showSpinner = true;
        this.currentFilter = event.target.dataset.id;
        this.updateActionMyApplicationPage();
        this.updateStatusFilterValues();
    }
    updateStatusFilterValues(){
        this.statusFilter.forEach(row=>{
            if(row['value'] == this.currentFilter){
                row['class'] = 'slds-col dashboard-card active';
                if(row['label'] == 'My Applications' || row['label'] == 'All Applications'){
                    this.childCardTitle = row['label'];
                }else{
                    this.childCardTitle = row['label'] + ' Applications';
                }
                
            }else{
                row['class'] = 'slds-col dashboard-card';
            }
        })
    }
    handleKeyDown(event){
        if(event.code === 'Enter' || event.keyCode === 13){
            this.getMyApplicationDetails(event);
        }
    }
}