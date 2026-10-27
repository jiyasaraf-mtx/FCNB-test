import {
    LightningElement,
    track,
    api
} from 'lwc';
import getAddressForAccount from '@salesforce/apex/LPI_CaseController.getAccountDetails';
import getPublicComplaintFromCase from '@salesforce/apex/LPI_CaseController.getPublicComplaintFromCase';
import getCaseParticipants from '@salesforce/apex/LPI_CaseParticipantController.getCaseParticipants';
import getIncidentDetails from '@salesforce/apex/LPI_CaseController.getIncidentDetailsFromCase';
import {
    showAsyncErrorMessage
} from 'c/lpiUtil';
export default class LpiCaseAddressInfo extends LightningElement {
    @api recordId;
    showSpinner;
    @track accountRec= {};
    @track publicComplaintRec = {};
    @track caseParticipantsRec = {};
    connectedCallback() {
        this.fetchAddresses();
        this.fetchPublicComplaint();
        this.fetchCaseParticipants();
        this.fetchCaseIncidentDetails();
    }

    addressTypeToAddressMap  = new Map();
    @track addressTypeToAddressList;
    @track caseIncidentDetailsList;
    fetchAddresses() {
        this.showSpinner = true;
        getAddressForAccount({
                recordId: this.recordId
            })
            .then(async result => {
                if (result) {
                    this.accountRec = result;
                    if(this.accountRec.addressRecords){
                        this.addressTypeToAddressList = [];
                        this.addressTypeToAddressMap = await this.createAddressTypeVsAddressMap();
                        for(let key of  this.addressTypeToAddressMap.keys()){
                            this.addressTypeToAddressList.push({
                                'addressType' : key,
                                'addressRecords' : this.addressTypeToAddressMap.get(key)
                            });
                        }
                    }

                }
            })
            .catch(error => {
                showAsyncErrorMessage(this, error);
            }).finally(() => {
                this.showSpinner = false
            })
    }

    async createAddressTypeVsAddressMap(){
        let addressTypeToAddressRecordMap = new Map();
        this.accountRec.addressRecords.forEach(address => {
            if(!addressTypeToAddressRecordMap.has(address.addressType)){
                addressTypeToAddressRecordMap.set(address.addressType,[]);
            }
            addressTypeToAddressRecordMap.get(address.addressType).push(address);
        });
        return addressTypeToAddressRecordMap;
    }
    fetchPublicComplaint() {
        this.showSpinner = true;
        getPublicComplaintFromCase({
                recordId: this.recordId
            }).then(result => {
                if (result != null) {
                    this.publicComplaintRec = result;
                    console.log('result--'+JSON.stringify(result));
                }
            }).catch(error => {
                showAsyncErrorMessage(this, error);
            }).finally(() => {
                this.showSpinner = false
            })
    }

    fetchCaseParticipants(){
        this.showSpinner = true;
        getCaseParticipants({
            recordId: this.recordId
        }).then(result => {
            if (result != null) {
                this.caseParticipantsRec = result;
            }
        }).catch(error => {
            showAsyncErrorMessage(this, error);
        }).finally(() => {
            this.showSpinner = false
        })
    }

    fetchCaseIncidentDetails(){
        this.showSpinner = true;
        getIncidentDetails({
            recordId: this.recordId
        }).then(result => {
            if(result != null){
                this.caseIncidentDetailsList = result;
            }
        }).catch(error => {
            showAsyncErrorMessage(this, error);
        }).finally(() => {
            this.showSpinner = false
        })
    }
}