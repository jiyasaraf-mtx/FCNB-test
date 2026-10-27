import { LightningElement,api } from 'lwc';
export default class Lpi_ViolationLetterForm extends LightningElement {
     @api recordId;
    @api invoke() {
        // Construct the URL for the Visualforce page
        const vfPageUrl = '/apex/LPI_ViolationLetter?recordId='+this.recordId;

        // Open the Visualforce page in a new browser tab or window
        window.open(vfPageUrl, '_blank');
    }
}