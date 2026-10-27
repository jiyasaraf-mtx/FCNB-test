import { LightningElement,wire } from 'lwc';
import My_Resource from '@salesforce/resourceUrl/LPI_Design';
import { CurrentPageReference } from 'lightning/navigation';
import { NavigationMixin } from "lightning/navigation";
import fetchSelectedApplicationRecords from '@salesforce/apex/EMP_DashbaordTableCtrl.fetchSelectedApplicationRecords';
export default class EmpPendingChecklistItem extends LightningElement { 



    // greenTick = My_Resource + '/media/icons/pendingClockIcon.svg';
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
      
            this.fetchSelectedApplicationRecord();

    }
    fetchSelectedApplicationRecord(){
        fetchSelectedApplicationRecords().then((result) => {
            this.showSpinner = false;
            this.applicationData = result;
            this.applicationNumber = this.currentPageReference.state.name

        
        }).catch((error)=>{
            console.log(error);
            this.showSpinner = false;
        })
    }
    backToApplication() {
        window.open('/employerportal/s/application','_self');
    }
       
}