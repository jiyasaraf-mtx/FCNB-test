import { LightningElement, track, wire } from 'lwc';
import getRTFData from '@salesforce/apex/LPI_PaymentController.getRTFData';
import { CurrentPageReference } from 'lightning/navigation';
import {NavigationMixin} from 'lightning/navigation';

const DOWNLOAD_PAYMENT_RECEIPT_URL = '/apex/LPI_PaymentReceiptPDFPage?targetId=';
export default class LpiPaymentDetailPage extends NavigationMixin(LightningElement) {
    @track trxnid = '';
    @track trxnData = [];
    showDownloadButton = false;
    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.trxnid = currentPageReference.state?.trxnid;
        }
    }

    connectedCallback() {
        getRTFData({ rtfId: this.trxnid })
            .then(result => {
                this.trxnData = result;
                this.trxnData.forEach((field)=>{
                    if(field.key === 'paymentAmount' && field.value !== '$0'){
                        this.showDownloadButton = true;
                    }
                });
            }).catch(error => {
                console.log(error);
                this.error = error;
            });
    }

    /**
     * This method is to handle the actions clicked
     * @param {*} event 
     */
    handleAction(event) {
        window.open(`${DOWNLOAD_PAYMENT_RECEIPT_URL + this.trxnid}`, "_self");
    }

    handleClickBackDashbaord(){
        // console.log('Back Dashbaord');
        window.open('/s/my-payments','_self') ;
    }
}