import { LightningElement,track,wire } from 'lwc';
import fetchComplaints from '@salesforce/apex/LPI_ComplaintsController.fetchOnlyComplaints';
import AccountId from '@salesforce/schema/User.AccountId';
import Name from '@salesforce/schema/User.Name';
import userId from '@salesforce/user/Id';
import {
    showAsyncErrorMessage,
    showMessage
} from 'c/lpiUtil';
import {
    getRecord
} from 'lightning/uiRecordApi';


export default class LpiMyComplaints extends LightningElement {
    
    @track showSpinner = false;
    @track isComplaintDataLoaded = false;
    @track isComplaintAvailable = false;
    accId;
    portalUserName;
    @track complaintRecords = [];


    handleClickComplaints(){
        window.open('/s/complaint-form', '_self');
    }
    spinnerHandler(event){
        const spinner = event.detail.showSpinner;
        if(spinner == true){
            this.showSpinner = true;
        }else if(spinner == false){
            this.showSpinner = false;
        }
    }

    connectedCallback() {
        this.showSpinner = true;
    }

    @wire(getRecord, {
        recordId: userId,
        fields: [AccountId,Name]
    })
    userRecInfo({
        error,
        data
    }) {
        if (data) {
            console.log('enetered');
            this.accId = data.fields.AccountId.value;
            this.portalUserName = data.fields.Name.value;
            this.getAllMyComplaints();
        }
    }

    getAllMyComplaints() {
        this.showSpinner = true;
        fetchComplaints({
                accountId: this.accId
            })
            .then(rec => {
                this.getComplaintRecords(rec);
            })
            .catch(err => {
                this.showSpinner = false;
                showAsyncErrorMessage(this, err);
            })
    }

    getComplaintRecords(rec){
        if (!rec) {
            this.showSpinner = false;
            this.isComplaintDataLoaded = true;
            return;
        }
        if (rec.ComplaintWrapList.length > 0) {
            this.isComplaintAvailable = true;
            this.complaintRecords = rec.ComplaintWrapList.map(record => {
                return { ...record};
            });
            this.showSpinner = false;
        }
    }
}