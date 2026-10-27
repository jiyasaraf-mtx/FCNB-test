import {LightningElement,track,wire,api} from 'lwc';
import {NavigationMixin} from 'lightning/navigation';
import {CurrentPageReference} from 'lightning/navigation';
import getApplicationData from '@salesforce/apex/LPI_PublicLicenseCtrl.getApplicationData';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';

export default class LpipublicLicensePage extends NavigationMixin(LightningElement) {

    @wire(CurrentPageReference)
    currentPageReference;

    recordId = '';
    raId = '';
    showErrorForNoLicense = false;
    showSpinner = false;

    @track jsonData = [];

    
    connectedCallback() {
        this.showSpinner = true;
        if (`${this.currentPageReference.state.blId}` != 'undefined' && `${this.currentPageReference.state.raId}` != 'undefined') {
            this.recordId = `${this.currentPageReference.state.blId}`;
            this.raId = `${this.currentPageReference.state.raId}`;
        }
        this.getApplicationData();
    }
    getApplicationData() {
        getApplicationData({ blId: this.recordId,raId : this.raId})
        .then((result) => {
            if(result !== null){
                this.jsonData = JSON.parse(JSON.stringify(result));
            }else{
                this.showErrorForNoLicense = true;
            }
            this.showSpinner = false;
        })
        .catch((error) => {
            this.showMessage('Error',error?.body?.message, 'error');
            this.showSpinner = false;
        });
    }
    showMessage(title,message, variant) {
        const toastEvt = new ShowToastEvent({
            title,
            message,
            variant
        });
        this.dispatchEvent(toastEvt);
    }
    handleBackToLicenseSearch(event){
        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                pageName: 'license-search-page'
            },
        });
    }
}