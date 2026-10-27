import { LightningElement, wire } from 'lwc';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import hasInstruction from '@salesforce/apex/LPI_InstructionController.hasInstruction';
import getLicenseNumber from '@salesforce/apex/LPI_licenseNumber.getLicenseNumberAndSubType';

export default class LpiInstructionLink extends  NavigationMixin(LightningElement) {
    parId = null;
    showInstruction = false;
    blId = null;
    type = null;
    licenseNumber = null;
    subType = null;
    isTypeRenewalOrAmend = false;

    @wire(CurrentPageReference)
    getPageReferenceParameters(currentPageReference) {
       if (currentPageReference) {
            let states = currentPageReference.state;
            let contextId = states.ContextId;
            this.parId = states.c__parid; 
            this.blId = states.blId;
            this.type = states.type;
            console.log('this.blId->',this.blId);
            console.log('this.type->',this.type);
            console.log('=== [LPI_DEBUG] Page Reference States ===', JSON.parse(JSON.stringify(states)));
            console.log('=== [LPI_DEBUG] Resolved parId:', this.parId);
            console.log('=== [LPI_DEBUG] Resolved blId:', this.blId);
            console.log('=== [LPI_DEBUG] Resolved type:', this.type);
            if(this.parId != null && contextId != null){
                this.hasInstruction();
            }else{
                this.showInstruction = false;
            }
            if(this.type === 'renewal' || this.type === 'amendment'){
                this.isTypeRenewalOrAmend = true;
            }
            console.log('=== [LPI_DEBUG] isTypeRenewalOrAmend:', this.isTypeRenewalOrAmend);
            this.fetchLicenseNumberAndSubType();
       }
    }

    fetchLicenseNumberAndSubType(){
        const inputMap = {
            'blId': this.blId,
            'c__blId': this.blId,
            'c__parid': this.parId
        }
        console.log('=== [LPI_DEBUG] Calling getLicenseNumber with inputMap:', JSON.parse(JSON.stringify(inputMap)));
        getLicenseNumber({ inputMap })
            .then(result => {
                console.log('=== [LPI_DEBUG] Apex getLicenseNumber Result ===', result);
                this.licenseNumber = result.licenseNumber;
                this.subType = result.appSubType;
                console.log('License Number:', this.licenseNumber);
                console.log('Application SubType:', this.subType);
            }).catch(error => {
                console.error('=== [LPI_DEBUG] Error in fetchLicenseNumberAndSubType ===', error);
            });
    }

    hasInstruction(){
        hasInstruction({'parId' : this.parId}).then((result)=>{
            if(result === true){
                this.showInstruction = true;
            }
        }).catch((_)=>{
            this.showInstruction = false;
        })
    }

    handleLinkClick() {
        const url = `instructions?parid=${this.parId}`;
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: url,
                target: '_blank' // Open in a new tab
            }
        });
    }

}