import { LightningElement,api,track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
export default class LpiApplicationViewItem extends NavigationMixin(LightningElement) {
    @api section;
    @api isPortal;
    @track isOpen = true;
 
   handleToggleAccordionClick(event){
       this.isOpen = !this.isOpen;
   }
   get className(){
       return this.isOpen ? 'slds-accordion__section slds-is-open' : 'slds-accordion__section';
   }
   get hasChildSection(){
    return this.section?.childSectionList?.length > 0;
}

   get icon(){
       return this.isOpen ? 'utility:chevrondown' : 'utility:chevronup';
   }
   navigateToRecordViewPage(event) {
    this[NavigationMixin.GenerateUrl]({
        type: "standard__recordPage",
        attributes: {
            recordId: event.target.dataset.id,
            actionName: 'view'
        }
    }).then(url => {
        window.open(url, "_blank");
    });
}
handleChildButtton(event){
    let data;
    if(event.target.dataset.id !== null && event.target.dataset.id !== undefined){
        data = JSON.parse(event.target.dataset.id);
        const eventParent = new CustomEvent("childbuttonclick",
        {
            detail : data
        });
        this.dispatchEvent(eventParent);
    }
}

}