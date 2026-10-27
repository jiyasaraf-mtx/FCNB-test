import { LightningElement, api } from 'lwc';
import createNotification from '@salesforce/apex/LPI_ProLandSurveyController.createNotification';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class LpiProLandSurveyStateExam extends LightningElement {
    @api recordId;
    @api buttonName;

    connectedCallback(){
        createNotification({'iaId' : this.recordId, 'buttonName':this.buttonName}).then(result => {
            if(result === 'success'){
                this.showMessage('Success', 'Notification for PLS Missouri State Specific Exam has been successfully sent to the applicant.', 'success');
            }else{
                this.showMessage('Error', 'Something Went Wrong !', 'error');
            }   
        }).catch(error => {
            this.showMessage('Error', 'Something Went Wrong !', 'error');
        }).finally((_)=>{
            const closeModalEvent = new CustomEvent("modalclose");
            this.dispatchEvent(closeModalEvent);
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
}