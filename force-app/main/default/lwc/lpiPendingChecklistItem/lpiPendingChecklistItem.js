import { LightningElement,wire } from 'lwc';
import My_Resource from '@salesforce/resourceUrl/LPI_Design';
import { CurrentPageReference } from 'lightning/navigation';
import getPendingChecklistItem from '@salesforce/apex/LPI_PendingChecklistItemCtrl.getPendingChecklistItem';
import { NavigationMixin } from "lightning/navigation";

export default class LpiPendingChecklistItem extends NavigationMixin(LightningElement) {
    greenTick = My_Resource + '/media/icons/pendingClockIcon.svg';
    showList = false;
    applicationNumber = '';
    @wire(CurrentPageReference)
    currentPageReference;

    pendingChecklistItem = [];
    title = 'Pending Checklist Items';
    isOpen = false;
 
    handleToggleAccordionClick(event){
        this.isOpen = !this.isOpen;
    }
    get icon(){
        return this.isOpen ? 'utility:chevrondown' : 'utility:chevronright';
    }
    get className(){
        return this.isOpen ? 'slds-accordion__section slds-is-open' : 'slds-accordion__section';
    }
    connectedCallback(){
        getPendingChecklistItem({parId:this.currentPageReference.state.c__parid})
            .then(result => {
                this.applicationNumber = result.applicationNumber;
                this.pendingChecklistItem = JSON.parse(result.pendingDueDigilenceList);
                this.showList= true;
                if(this.pendingChecklistItem.length==0){
                    this.showList= false;
                }
            })
            .catch(error => {
                console.log('Error'+error?.body?.message);
            });
    }
    backToApplication(){
        console.log('Hello');
        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                pageName: 'my-applications'
            },
        });
    }
}