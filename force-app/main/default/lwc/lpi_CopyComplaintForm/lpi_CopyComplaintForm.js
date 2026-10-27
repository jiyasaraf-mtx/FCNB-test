import { LightningElement,api } from 'lwc';

export default class Lpi_CopyComplaintForm extends LightningElement {
    @api recordId;
    @api invoke() {
        // Construct the URL for the Visualforce page
        const vfPageUrl = '/apex/LPI_CopyComplaintRespondent?recordId='+this.recordId;

        // Open the Visualforce page in a new browser tab or window
        window.open(vfPageUrl, '_blank');
    }
}