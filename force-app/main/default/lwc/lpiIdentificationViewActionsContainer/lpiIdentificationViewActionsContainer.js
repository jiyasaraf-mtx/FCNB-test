import { LightningElement,track,api } from 'lwc';
import createPARRecord from '@salesforce/apex/LPI_NeedYourAttention.createPARRecord'
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import setActionAllowedValidation from '@salesforce/apex/LPI_ApplicationFlowUtility.setActionAllowedValidation'
import fetchIdentificationCardInfo from '@salesforce/apex/LPI_IdentificationCardInfoController.fetchIdentificationCardInfo'
import {NavigationMixin} from 'lightning/navigation';
export default class LpiIdentificationViewActionsContainer extends NavigationMixin (LightningElement) {
    @api recordId;
    @track result = {};
    @track showSpinner = false;
    @track isPortal = false;
    @track accId;
    @track busLicenseId = null;
    connectedCallback() {
        this.showSpinner = true;
        fetchIdentificationCardInfo({
            icId: this.recordId,
            isPortalUser: this.isPortal
        }).then(data =>{
            this.showSpinner = false;
            if(data.length > 0){
               this.result = data[0];
            }   
        }).catch(error => {
            this.showMessage('Error', error?.body?.message, 'error');
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
    
    handleIcCardRenewal(){
        this.showSpinner = true;
        let data = {};
        data['regAuthId'] = this.result?.regAuthId;
        data['type'] =  this.result?.applicationType;
        data['amendmentType'] =  this.result?.applicationSubType;
        data['subType'] =  this.result?.applicationSubType;
        data['blId'] = null;
        data['changeStatusAmendmentSubType'] = null;
        data['additionalLicenseType'] = null;
        data['accountId'] = this.result?.accountId;
        data['identificationCardId'] = this.recordId;
        this.accId = this.result?.accountId;
        this.handleAction(data);
    }
    
    handleAction(data){
        this.showSpinner = true;
        setActionAllowedValidation({
            inputMap: data
        })
        .then(result => {
            if (result) {
                createPARRecord({
                    inputMap: data
                })
                .then(result => {
                    result = result + '&blId='+null+'&type='+ this.result.applicationType.toLowerCase()+'&portalUser='+this.isPortal;
                    this.showSpinner = false;
                    
                    const myUrlSplit = result.split("&");
                    let target = '';
                    let c__ContextId = '';
                    let c__parid = '';
                    let lateRenewal = '';
                    let c__type = '';
                    myUrlSplit.forEach(element => {
                        let paramSplit = element.split("=");
                        if (paramSplit[0] == 'c__target') {
                            target = paramSplit[1];
                        } else if (paramSplit[0] == 'ContextId') {
                            c__ContextId = paramSplit[1];
                        } else if (paramSplit[0] == 'c__parid') {
                            c__parid = paramSplit[1];
                        }else if (paramSplit[0] == 'lateRenewal') {
                            lateRenewal = paramSplit[1];
                        }else if (paramSplit[0] == 'type') {
                            c__type = paramSplit[1];
                        }
                    });
                    this[NavigationMixin.Navigate]({
                        type: 'standard__component',
                        attributes: {
                            componentName: 'omnistudio__vlocityLWCOmniWrapper'
                        },
                        state: {
                            c__target: target,
                            c__layout: 'lightning',
                            c__tabIcon: 'custom:custom18',
                            c__tabLabel: 'Apply for license',
                            c__ContextId: c__ContextId,
                            c__parid: c__parid,
                            c__blId : this.busLicenseId,
                            c__type : c__type,
                            c__lateRenewal : lateRenewal,
                            c__portalUser : this.isPortal,
                            c__accountId : this.accId
                        }
                    })
                    
                })
                .catch(error => {
                    this.showMessage('Error', error?.body?.message, 'error');
                    this.showSpinner = false;
                });
            } else {
                this.showMessage('Info', 'The same application has already been submitted or a draft application has been created. Please check the associated applications to the Account.','info');
                this.showSpinner = false;
            }
        })
        .catch(error => {
            this.showMessage('Error', error?.body?.message, 'error');
            this.showSpinner = false;
        }); 
    }

    navigateToPaymentPage(){
        this.showSpinner = true;
        this[NavigationMixin.Navigate]({
            type: "standard__component",
            attributes: {
                componentName: "c__lpiPaymentComp"
            },
            state: {
                c__licenseTypeId: this.result?.regAuthId,
                c__recordId: this.result?.accountId,
                c__defaultType: this.result?.applicationType,
                c__defaultSubType: this.result?.applicationSubType,
                c__identificationCardId: this.recordId,
                c__licenseName: this.result?.regAuthTypeName
            }
        });
    }
}