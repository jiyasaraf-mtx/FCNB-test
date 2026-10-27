import { LightningElement} from 'lwc';

export default class LpiAllDetailsPage extends LightningElement {
    showApplicationsPage  = false;
    showLicensesPage = true;
    showPaymentsPage = false;
    selectedOption = 'AllLicenses';

    allDetailsOptions = [
        { label: 'All Licenses', value: 'AllLicenses' },
        { label: 'All Applications', value: 'AllApplications' },
        { label: 'All Payments', value: 'AllPayments' } 
    ]

    onOptionChange(event){
        this.selectedOption = event.target.value;
        this.hideAllPages();
        if(this.selectedOption === 'AllApplications'){
            this.showApplicationsPage = true;
        }else if(this.selectedOption === 'AllLicenses'){
            this.showLicensesPage = true;
        }else if(this.selectedOption === 'AllPayments'){
            this.showPaymentsPage = true;
        }
    }
    
    hideAllPages(){
        this.showApplicationsPage = false;
        this.showLicensesPage = false;
        this.showPaymentsPage = false
    }
}