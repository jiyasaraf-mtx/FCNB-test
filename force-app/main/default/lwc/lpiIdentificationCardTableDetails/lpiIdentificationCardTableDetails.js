import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import fetchIdentificationCardInfo from '@salesforce/apex/LPI_IdentificationCardInfoController.fetchIdentificationCardInfo';
import createPARRecord from '@salesforce/apex/LPI_NeedYourAttention.createPARRecord';
import setActionAllowedValidation from '@salesforce/apex/LPI_ApplicationFlowUtility.setActionAllowedValidation';

export default class LpiIdentificationCardTableDetails extends LightningElement {
    columns = [
        { label: 'ID Card Number', fieldName: 'IDCardNumber' },
        { label: 'ID Type', fieldName: 'IDType' },
        { label: 'Issuance Date', fieldName: 'IssuanceDate' },
        { label: 'Expiry Date',fieldName:'ExpiryDate'},
        { label: 'Actions', fieldName:'Actions'}
    ]
    @track idCardModalDetails = {
        'showModal' : false
    };
    @track recordsdata = [];
    @track hasIcCardData = false;
    isPortal = true;

    connectedCallback() {
        this.callParentSpinnerMethod(true);
        this.fetchIdentificationCardInfo();
    }

    fetchIdentificationCardInfo(){
        fetchIdentificationCardInfo({icId : null, isPortalUser :true})
        .then(result => {
            this.hasIcCardData =  result.length > 0 ? true : false;
            this.recordsdata = result;
            this.callParentSpinnerMethod(false);
        })
        .catch(error => {
            this.showMessage('Error', error?.body?.message, 'error');
            this.callParentSpinnerMethod(false);
        });
    }

    showMessage(title, message, variant) {
        const toastEvt = new ShowToastEvent({
            title,
            message,
            variant
        });
        this.dispatchEvent(toastEvt);
    }

    showModalBox(){
        this.idCardModalDetails.showModal = true;
    }

    hideModalBox(){
        this.idCardModalDetails.showModal = false;
    }

    handleClickEvent(event){
        const actionName = event.target.value;
        const icId = event.target.dataset.icid;
        if(actionName === 'View'){
            this.recordsdata.forEach((item)=>{
                if(item.icId === icId){
                    this.idCardModalDetails['contestantName'] = item.contestantName;
                    this.idCardModalDetails['idDateIssued'] = item.issuanceDate;
                    this.idCardModalDetails['expiryDate'] = item.expiryDate;
                    this.idCardModalDetails['idIssuingCommission'] = item.issuingCommission;
                    this.idCardModalDetails['idType'] = item.type;
                    if(item.type == 'MMA'){
                        this.idCardModalDetails['nationalIDNumber'] = item.cardNumber;
                        this.idCardModalDetails['federalIDNumber'] = null;
                    }else if(item.type == 'Boxing'){
                        this.idCardModalDetails['federalIDNumber'] = item.cardNumber;
                        this.idCardModalDetails['nationalIDNumber'] = null;
                    }
                }
            });
            this.showModalBox();
        }else if (actionName === 'Renew'){
            this.handleRenewal(event);
        }
    }

    createDataForRenewal(event){
        let data = {};
        let dataSet = event.target.dataset;
        data['regAuthId'] = dataSet.regauthid;
        data['type'] = dataSet.type;
        data['amendmentType'] = dataSet.subtype;
        data['subType'] = dataSet.subtype;
        data['identificationCardId'] = dataSet.icid;
        data['blId'] = null;
        data['changeStatusAmendmentSubType'] = null;
        data['additionalLicenseType'] = null;
        return data;
    }

    handleRenewal(event){
        this.callParentSpinnerMethod(true);
        let data = this.createDataForRenewal(event);
        setActionAllowedValidation({
            inputMap: data
        })
        .then(result => {
            if (result) {
                createPARRecord({
                        inputMap: data
                    })
                    .then(result => {
                        this.callParentSpinnerMethod(false);
                        result = result + '&blId='+null+'&type='+data.type.toLowerCase()+'&portalUser='+this.isPortal;
                        window.open(result, '_self');
                    })
                    .catch(error => {
                        this.showMessage('Error', error?.body?.message, 'error');
                        this.callParentSpinnerMethod(false);
                    });
            } else {
                this.showMessage('Info', 'The same application has already been submitted or a draft application has been created. Go to My Applications section on Dashboard in order to access it.','info');
                this.callParentSpinnerMethod(false);
            }
        })
        .catch(error => {
            this.showMessage('Error', error?.body?.message, 'error');
            this.callParentSpinnerMethod(false);
        });
    }


    callParentSpinnerMethod(showSpinner){
        // Fire an event to notify the parent to call its method
        const callParentMethodEvent = new CustomEvent('spinnerhandlerfromchild', {
            detail: { showSpinner }
        });
        this.dispatchEvent(callParentMethodEvent);
    }


}