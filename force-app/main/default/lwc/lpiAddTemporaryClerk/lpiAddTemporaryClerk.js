import { LightningElement, track } from 'lwc';
// import saveClerk from '@salesforce/apex/LPI_AddTemporaryClerkController.saveRecords';
// import updateClerk from '@salesforce/apex/LPI_AddTemporaryClerkController.updateClerk';
// import fetchClerks from '@salesforce/apex/LPI_AddTemporaryClerkController.fetchRecords';
// import deleteClerk from '@salesforce/apex/LPI_AddTemporaryClerkController.deleteClerk';
//import fetchGoogleData from '@salesforce/apex/LPI_AddTemporaryClerkController.fetchGoogleData';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';

export default class LpiAddTemporaryClerk extends LightningElement {

    showSpinner = false;
    errorMessage = '';
    hasError = false;

    @track selectedClerkId = '';
    @track modalHeading = '';
    @track openConfirmationModal = false;
    @track selectedData = {};
    @track dataObjList = {};
    @track editDataObjList = {};
    @track clerkList = [];
    @track isEditPopup = false;

    patternObj = {
        text: '^((?!(<)|(>)).)*$',
        digits: '^(\\([0-9]{3}\\) |[0-9]{3}-)[0-9]{3}-[0-9]{4}$',
        email: '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,10}$',
        zipCode: '^[0-9]{5}(?:-[0-9]{4})?$',
        zipCodeUS: '^[0-9]{5}?$',
        zipCodeNonUS: '^[a-zA-Z0-9]*$',
        ssn: '^[0-9X-]+$',
        phone: '[0-9]*',
        name: '^[A-Za-z0-9 ]+$',
        dob: '^[A-Za-z0-9 ]+$'
    }

    get roleOptions() {
        return [
            { label: 'Authorized Employee', value: 'Temporary Clerk' },
            { label: 'Authorized Contact', value: 'Authorized Contact' },
        ];
    }

    connectedCallback(){
        this.fetchClerks();
        
        this.showSpinner = true;
        /*fetchGoogleData({})
        .then((result) => {    
            this.showSpinner = false;
        }).catch((error) => {
            this.showSpinner = false;

        });*/
    }
    
    handleInputs(event) {
        this.hasError = false;
        this.dataObjList[event.target.name] = event.target.value.trim();
    }

    handleEditInputs(event) {
        this.hasError = false;
        this.selectedData[event.target.name] = event.target.value.trim();
    }

    handleSave(){
        this.showSpinner = true;
        if (this.isValid()) {
            saveClerk({
                clerkJson: JSON.stringify(this.dataObjList)
            }).then((result) => {
                this.showToastMessage('Success', 'Record created successfully', 'success');
                this.handleReset();
                this.fetchClerks();
                this.showSpinner = false;
            }).catch((error) => {
                var errorMessage;
                if (typeof error.body.message === 'string') {
                    errorMessage = error.body.message;
                }
    
                if(errorMessage.includes('DUPLICATES_DETECTED')){
                    this.errorMessage = 'Record exists with same email id';
                }
                else{
                    this.errorMessage = errorMessage;
                }
                this.hasError = true;
                this.showSpinner = false;
            });
                
        } else {
            //window.scrollTo(0, 0);
            let allInput = this.template.querySelector(".slds-has-error");
            if (allInput) {
                allInput.scrollIntoView();
                allInput.focus();
            }
            this.hasError = true;
            this.errorMessage = 'Please review the errors.';
            this.showSpinner = false;
        }
    }

    handleUpdate(){
        this.showSpinner = true;
        if (this.isEditValid()) {
            updateClerk({
                clerkJson: JSON.stringify(this.selectedData)
            }).then((result) => {
                this.showToastMessage('Success', 'Record updated successfully', 'success');
                this.isEditPopup = false;
                this.fetchClerks();
                this.showSpinner = false;
            }).catch((error) => {
                var errorMessage;
                if (typeof error.body.message === 'string') {
                    errorMessage = error.body.message;
                }
    
                if(errorMessage.includes('DUPLICATES_DETECTED')){
                    this.errorMessage = 'Record exists with same email id';
                }
                else{
                    this.errorMessage = errorMessage;
                }
                this.hasError = true;
                this.showSpinner = false;
            });
                
        } else {
            //window.scrollTo(0, 0);
            let allInput = this.template.querySelector(".slds-has-error");
            if (allInput) {
                allInput.scrollIntoView();
                allInput.focus();
            }
            this.hasError = true;
            this.errorMessage = 'Please review the errors.';
            this.showSpinner = false;
        }
    }

    fetchClerks(){
        this.showSpinner = true;
        fetchClerks({})
        .then((result) => {    
            this.clerkList = result;
            this.showSpinner = false;

        }).catch((error) => {
            var errorMessage;
            if (typeof error.body.message === 'string') {
                errorMessage = error.body.message;
            }

            this.errorMessage = errorMessage;
            this.hasError = true;
            this.showSpinner = false;

        });

    }

    handleEdit(event){
        this.selectedData = Object.assign({}, this.clerkList[event.currentTarget.dataset.index]);
        this.selectedData.sfId = event.currentTarget.dataset.sfid;
        this.isEditPopup = true;
    }

    handleDelete(event){
        this.modalHeading = 'Are you sure you want to delete this Clerk?';
        this.selectedClerkId = event.target.dataset.sfid;
        this.openConfirmationModal = true;
    }

    handleCancelConfirmation(){
        this.selectedClerkId = null
        this.openConfirmationModal = false;   
    }

    handleDeleteConfirmation(){
       this.showSpinner = true;
       deleteClerk({
        clerkId : this.selectedClerkId
        })
        .then((result) => {    
            this.openConfirmationModal = false;
            this.selectedClerkId = null;
            this.fetchClerks();
            this.showSpinner = false;
        }).catch((error) => {
            var errorMessage;
            if (typeof error.body.message === 'string') {
                errorMessage = error.body.message;
            }

            this.errorMessage = errorMessage;
            this.hasError = true;
            this.showSpinner = false;
        });


    }

    closeEditModal(){
        this.isEditPopup = false;
    }

    updateTemporaryClerk(){
        this.isEditPopup = false;
    }

    isValid() {
		let valid = false;

        valid = [...this.template.querySelectorAll('lightning-combobox, lightning-dual-listbox, lightning-textarea, lightning-radio-group, lightning-input')].reduce(
            (validSoFar, input) => {
                if( input.type === 'date' ) {
                    if( !input.checkValidity() ) {
                        input.classList.add('slds-has-error');

                    } else {
                        input.classList.remove('slds-has-error');
                    }
                }
                input.reportValidity();
                return validSoFar && input.checkValidity();
            },
            true
        );
        return valid;
	}

    //for showing toast message
    showToastMessage(title, message, variant, mode) {
        const event = new ShowToastEvent({
        "title": title,
        "message": message,
        "variant": variant,
        "mode": mode
        });
        this.dispatchEvent(event);
    }

    isEditValid(){
        let valid = false;

        valid = [...this.template.querySelectorAll('.editClerkValidate')].reduce(
            (validSoFar, input) => {
                if( input.type === 'date' ) {
                    if( !input.checkValidity() ) {
                        input.classList.add('slds-has-error');

                    } else {
                        input.classList.remove('slds-has-error');
                    }
                }
                input.reportValidity();
                return validSoFar && input.checkValidity();
            },
            true
        );
        return valid;
    }

    handleReset(){
        this.template.querySelectorAll('lightning-input , lightning-combobox ').forEach(element => {
          if(element.type === 'checkbox' || element.type === 'checkbox-button'){
            element.checked = false;
          }else{
            element.value = null;
          }      
        });
      }
}