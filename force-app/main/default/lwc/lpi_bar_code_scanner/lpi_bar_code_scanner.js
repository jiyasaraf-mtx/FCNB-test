import { LightningElement, wire } from 'lwc';
import { CurrentPageReference } from "lightning/navigation";
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getLicenseIdFromNumber from '@salesforce/apex/LPI_BarcodeScanner.getLicenseIdFromNumber';

export default class Modpr_bar_code_scanner extends NavigationMixin(LightningElement) {
    @wire(CurrentPageReference) pageRef;

    showScan = true;
    showError = false;
    startScan = false;
    showSpinner = false;
    searchBox = false;
    showFilters = false;
    breadLabel = 'Document Scanning';
    decodedData;
   
    hasAccess = true;
    errorMessage = '';

    connectedCallback() {
        try{
            window.addEventListener('keydown', this.listenForMessage);
        }catch(error) {
            //this.hasAccess = false;
            this.showSpinner = false;
            console.log("Error: " + error);
        };
    }

    
    disconnectedCallback() {
        //unregisterAllListeners(this);
        window.removeEventListener('keydown', this.listenForMessage);
    }

    listenForMessage(message) {
        this.decodedData = message;
    }

    handleBeginScanClick() {
        this.showError = false;
        this.startScan = true;
    }

    handleStopScan() {
        this.startScan = false;
    }

    handleChange(event) {
        if (event.target.type === 'text') {
            event.target.value = typeof event.target.value === 'string' ?  event.target.value?.toUpperCase() : event.target.value;
        }
        this.decodedData = event.target.value;
    }

    handleButtonClick() {
        if(this.isValid()){
            this.navigateToUserDetails();
        }else {
            //window.scrollTo(0, 0);
            let allInput = this.template.querySelector(".slds-has-error");
            if (allInput) {
                allInput.scrollIntoView();
                allInput.focus();
            }
            this.showSpinner = false;
        }
    }

    handleCloseScanner(event) {
        this.decodedData = event;
        this.startScan = false;

        if (event !== null) {
            this.navigateToUserDetails();
        } else {
            this.showError = true;
            this.showFilters = true;
        }
    }

    navigateToUserDetails() {
        // Get the voter Id from Voter number and encrypt the Id
        this.showSpinner = true;
        getLicenseIdFromNumber({
            licenseNumber: this.decodedData
        }).then(resp => {
            if(resp != null && resp != undefined && resp != ''){
                window.open(resp);

            }else{
                this.showToastMessage('License Number does not exists.');
            }
            this.showSpinner = false;
        }).catch(err => {
            console.error(err);
            this.showError = true;
            this.showFilters = true;
            this.showScan = false;
        }).finally(() => {
            this.showSpinner = false;
        });
    }

    showToastMessage(messageStr) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Error!',
                type: 'error',
                message: messageStr,
                variant: 'error'
            })
        );
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


    openSearchBox() {
        this.searchBox = true;
    }

    closeSearch() {
        this.searchBox = false;
    }
    
}