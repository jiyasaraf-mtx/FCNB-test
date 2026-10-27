import { LightningElement, wire, track } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import submitDeficiencyResponse from '@salesforce/apex/LPI_DeficiencyResponseCtrl.submitDeficiencyResponse';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import getNotificationRecord from '@salesforce/apex/LPI_DeficiencyResponseCtrl.getNotificationRecord';
import getDueDiligenceDetails from '@salesforce/apex/LPI_DeficiencyResponseCtrl.getDueDiligenceDetails';


export default class LpiDeficiencyResponse extends NavigationMixin(LightningElement) {
    @wire(CurrentPageReference)
    currentPageReference;
    deficiencyComment;
    recordId;
    appId;
    showDeficiencyRecor;
    notificationId;
    showSpinner = false;
    notiDesc;
    dueDiligenceDetails;
    applicationNumber;
    deficiencyReviewReason;
    @track regTransactionFeeItemList = [];
    connectedCallback() {
        this.showSpinner = true;
        this.recordId = this.currentPageReference.state.Id;
        this.appId = this.currentPageReference.state.appId;
        this.notificationId = this.currentPageReference.state.notificationId;
        this.showDeficiencyRecor = true;
        getNotificationRecord({
            notiId: this.notificationId
        })
            .then(result => {
                this.notiDesc = result;
            })
            .catch(error => {
                const evt = new ShowToastEvent({
                    title: 'Error',
                    message: error.body.message,
                    variant: 'error',
                });
                this.dispatchEvent(evt);

            });
        this.fetchDueDiligenceDetails();

    }

    fetchDueDiligenceDetails() {
        getDueDiligenceDetails({
            deficencyId: this.recordId
        }).then(result => {
            this.showSpinner = false;
            this.dueDiligenceDetails = result.listOfDueDiligenceItems;
            this.applicationNumber = result.applicationNumber;
            this.deficiencyReviewReason = result.deficiencyReviewReason;
            this.regTransactionFeeItemList = result.regTransactionFeeItemList;
        }).catch(error => {
            this.showSpinner = false;
            const evt = new ShowToastEvent({
                title: 'Error',
                message: error.body.message,
                variant: 'error',
            });
            this.dispatchEvent(evt);
        })
    }

    get feeRecordExist(){
        return this.regTransactionFeeItemList != null && this.regTransactionFeeItemList.length > 0;
    }

    handleChange(event) {
        this.deficiencyComment = event.target.value;
    }
    validateFields() {
        let isAllValid;
        isAllValid = [...this.template.querySelectorAll('lightning-combobox')]
            .reduce((validSoFar, inputCmp) => {
                inputCmp.reportValidity();
                return validSoFar && inputCmp.checkValidity();
            }, true);

        isAllValid &= [...this.template.querySelectorAll('lightning-input')].reduce((validSoFar, input) => {
            input.reportValidity();
            return validSoFar && input.checkValidity();
        }, true);
        isAllValid &= [...this.template.querySelectorAll('lightning-radio-group')].reduce((validSoFar, input) => {
            input.reportValidity();
            return validSoFar && input.checkValidity();
        }, true);
        isAllValid &= [...this.template.querySelectorAll('lightning-textarea')].reduce((validSoFar, input) => {
            input.reportValidity();
            return validSoFar && input.checkValidity();
        }, true);
        return isAllValid;
    }
    handleSubmit() {
        let valid = this.validateFields();
        if (valid) {
            const documnentComp =  this.template.querySelector('c-lpi-view-uploaded-documents');
            // Rajeev Bypass for IA DIAL KT Session
            // if (documnentComp.requiredDocumentsUploaded()) {
                this.showSpinner = true;
                submitDeficiencyResponse({
                    comment: this.deficiencyComment,
                    applicationId: this.recordId,
                    notiId: this.notificationId,
                    iaId: this.appId
                }).then(result => {
                    this.showSpinner = false;
                    if (result == 'Success') {
                        // if(this.feeRecordExist){
                        //     this.showSpinner = true;
                        //     const redirectUrl = '/license/apex/LPI_DeficiencyJetPayRedirectPage?deficiencyId='+this.recordId;
                        //     window.open(redirectUrl,"_self")
                        // }else{
                        //     const evt = new ShowToastEvent({
                        //         title: "Success",
                        //         message: "Response Submitted Successfully",
                        //         variant: "success"
                        //     });
                        //     this.dispatchEvent(evt);
                        //     this[NavigationMixin.Navigate]({
                        //         type: 'standard__namedPage',
                        //         attributes: {
                        //             pageName: 'home'
                        //         },
                        //     });
                        // }
                        const evt = new ShowToastEvent({
                            title: "Success",
                            message: "Response Submitted Successfully",
                            variant: "success"
                        });
                        this.dispatchEvent(evt);
                        this[NavigationMixin.Navigate]({
                            type: 'standard__namedPage',
                            attributes: {
                                pageName: 'home'
                            },
                        });
                    } else {
                        const evt = new ShowToastEvent({
                            title: 'Error',
                            message: result,
                            variant: 'error',
                        });
                        this.dispatchEvent(evt);
                    }
                }).catch(error => {
                    this.showSpinner = false;
                    const evt = new ShowToastEvent({
                        title: 'Error',
                        message: error.body.message,
                        variant: 'error',
                    });
                    this.dispatchEvent(evt);

                });
            // } else {
            //     const evt = new ShowToastEvent({
            //         title: 'Error',
            //         message: 'Please upload the required documents',
            //         variant: 'error',
            //     });
            //     this.dispatchEvent(evt);
            // }
        }
    }
}