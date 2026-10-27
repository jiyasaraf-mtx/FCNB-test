import { LightningElement,wire, track } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import sendEmailNotificationOnDocSubmission from '@salesforce/apex/LPI_ApplicationDataEntry.sendEmailNotificationOnDocSubmission';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import {NavigationMixin} from 'lightning/navigation';
import {loadStyle} from "lightning/platformResourceLoader";
import My_Resource from '@salesforce/resourceUrl/LPI_Design';
import createEfdAppDocument from '@salesforce/apex/LPI_ViewUplodDocContoller.createEfdAppDocument';
export default class LpiFDEmbalmersSubmitForm extends NavigationMixin(LightningElement) {
    @wire(CurrentPageReference)
    currentPageReference;
    iaId;
    notificationId;
    @track valid = false;
    @track showSpinner = false;
    @track showFDRecords = true;
    connectedCallback() {
        loadStyle(this, My_Resource + "/styles/internal-main.css");
        this.showSpinner = true;
        this.iaId = this.currentPageReference.state.recordId;
        this.notificationId = this.currentPageReference.state.notificationId;
        createEfdAppDocument({
            iaId:this.iaId,
        }).then(result=>{
            this.showFDRecords = true;
            this.showSpinner = false;
        }).catch(error => {
            this.showSpinner = false; 
            const evt = new ShowToastEvent({
                title: 'Error',
                message: error.body.message,
                variant: 'error',
            });
            this.dispatchEvent(evt);
        });
    }
    
    handleSubmit(){
        const documnentComp =  this.template.querySelector('c-lpi-view-uploaded-documents');
        if(documnentComp.requiredDocumentsUploaded()){
            this.showSpinner = true;
            sendEmailNotificationOnDocSubmission({
                applicationId:this.iaId,
            }).then(result=>{
                this.showSpinner = false; 
                if(result == 'Success'){
                    const evt = new ShowToastEvent({
                        title: "Success",
                        message: "Registration Form Submitted Successfully",
                        variant: "success"
                    });
                    this.dispatchEvent(evt);
                    this[NavigationMixin.Navigate]({
                        type: 'standard__namedPage',
                        attributes: {
                            pageName: 'home'
                        },
                    });
                    this.showSpinner = false;
                }else{
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
        }else{
            const evt = new ShowToastEvent({
                title: 'Error',
                message: 'Please Upload the Document',
                variant: 'error',
            });
            this.dispatchEvent(evt);
        }
    }
}