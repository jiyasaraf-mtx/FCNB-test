import { LightningElement, wire, track } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getInstruction from '@salesforce/apex/LPI_InstructionController.getInstruction';

export default class LpiDisplayInstructions extends LightningElement {
    @wire(CurrentPageReference) pageRef;

    @track instruction = '';
    @track isLoading = true;

    @wire(getInstruction, { parId: '$parId' })
    wiredInstruction({ error, data }) {
        if (data) {
            this.instruction = data;
            this.isLoading = false;
        } else if (error) {
            this.handleError(error);
            this.isLoading = false;
        }
    }

    get parId() {
        return this.pageRef && this.pageRef.state.parid;
    }

    handleError(error) {
        const toastEvent = new ShowToastEvent({
            title: 'Error',
            message: 'An error occurred while retrieving instructions.',
            variant: 'error',
        });
        this.dispatchEvent(toastEvent);
        console.error('Error retrieving instructions:', error);
    }
}