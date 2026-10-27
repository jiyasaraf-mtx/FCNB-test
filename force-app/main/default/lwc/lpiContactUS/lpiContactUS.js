import { LightningElement, track } from 'lwc';
import lpiResource from '@salesforce/resourceUrl/LPI_Design';

export default class LpiContactUS extends LightningElement {
    licensing = lpiResource + '/media/images/licensing.png';
    feeStructure = lpiResource + '/media/images/fee-structure.png';
    renewals = lpiResource + '/media/images/renewals.png';

    @track sectionClass1 = 'slds-accordion__section custom-accordion slds-is-open';
    @track sectionClass2 = 'slds-accordion__section custom-accordion';
    @track sectionClass3 = 'slds-accordion__section custom-accordion';
    @track sectionClass4 = 'slds-accordion__section custom-accordion';
    @track sectionClass5 = 'slds-accordion__section custom-accordion';
    
    handleAccordianClick(event){
        let name = event.currentTarget.dataset.name;
        let accordionStatus = this.template.querySelector(`[data-name="apply"]`);
        // let btnStatus = this.template.querySelector(`[data-name="btn Candidate Information"]`);

        // console.log('name handleAccordianClick:>> ', name);
        // console.log(this.btnLabel);
        if (name === 'apply') {
            if (this.sectionClass1 == 'slds-accordion__section custom-accordion') {
                this.sectionClass1 = 'slds-accordion__section custom-accordion slds-is-open';
                 this.sectionClass2 = 'slds-accordion__section custom-accordion';
                 this.sectionClass3 = 'slds-accordion__section custom-accordion';
                 this.sectionClass4 = 'slds-accordion__section custom-accordion';
                 this.sectionClass5 = 'slds-accordion__section custom-accordion';
                // this.btnLabel = 'Hide Details';
                accordionStatus.setAttribute('aria-expanded',true);
            } else {
                this.sectionClass1 = 'slds-accordion__section custom-accordion';
                // this.btnLabel = 'Show Details';
                accordionStatus.setAttribute('aria-expanded',false);
            }
        }
        if (name === 'Renew') {
            if (this.sectionClass2 == 'slds-accordion__section custom-accordion') {
                this.sectionClass2 = 'slds-accordion__section custom-accordion slds-is-open';
                this.sectionClass3 = 'slds-accordion__section custom-accordion';
                this.sectionClass4 = 'slds-accordion__section custom-accordion';
                this.sectionClass5 = 'slds-accordion__section custom-accordion';
                // this.btnLabel = 'Hide Details';
                this.sectionClass1 = 'slds-accordion__section custom-accordion';
                accordionStatus.setAttribute('aria-expanded',true);
            } else {
                this.sectionClass2 = 'slds-accordion__section custom-accordion';
                // this.btnLabel = 'Show Details';
                accordionStatus.setAttribute('aria-expanded',false);
            }
        }
        if (name === 'payment') {
            if (this.sectionClass3 == 'slds-accordion__section custom-accordion') {
                this.sectionClass3 = 'slds-accordion__section custom-accordion slds-is-open';
                this.sectionClass1 = 'slds-accordion__section custom-accordion';
                this.sectionClass2 = 'slds-accordion__section custom-accordion';
                this.sectionClass4 = 'slds-accordion__section custom-accordion';
                this.sectionClass5 = 'slds-accordion__section custom-accordion';
                accordionStatus.setAttribute('aria-expanded',true);
            } else {
                this.sectionClass3 = 'slds-accordion__section custom-accordion';
                // this.btnLabel = 'Show Details';
                accordionStatus.setAttribute('aria-expanded',false);
            }
        }
        if (name === 'Resume') {
            if (this.sectionClass4 == 'slds-accordion__section custom-accordion') {
                this.sectionClass4 = 'slds-accordion__section custom-accordion slds-is-open';
                // this.btnLabel = 'Hide Details';
                this.sectionClass1 = 'slds-accordion__section custom-accordion';
                this.sectionClass2 = 'slds-accordion__section custom-accordion';
                this.sectionClass3 = 'slds-accordion__section custom-accordion';
                this.sectionClass5 = 'slds-accordion__section custom-accordion';
                accordionStatus.setAttribute('aria-expanded',true);
            } else {
                this.sectionClass4 = 'slds-accordion__section custom-accordion';
                // this.btnLabel = 'Show Details';
                accordionStatus.setAttribute('aria-expanded',false);
            }
        }
        if (name === 'Offline') {
            if (this.sectionClass5 == 'slds-accordion__section custom-accordion') {
                this.sectionClass5 = 'slds-accordion__section custom-accordion slds-is-open';
                // this.btnLabel = 'Hide Details';
                this.sectionClass1 = 'slds-accordion__section custom-accordion';
                this.sectionClass2 = 'slds-accordion__section custom-accordion';
                this.sectionClass3 = 'slds-accordion__section custom-accordion';
                this.sectionClass4 = 'slds-accordion__section custom-accordion';
                accordionStatus.setAttribute('aria-expanded',true);
            } else {
                this.sectionClass5 = 'slds-accordion__section custom-accordion';
                // this.btnLabel = 'Show Details';
                accordionStatus.setAttribute('aria-expanded',false);
            }
        }
    }
}