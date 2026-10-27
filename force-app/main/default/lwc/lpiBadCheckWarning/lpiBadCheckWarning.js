import { LightningElement, api,track} from "lwc";
import getBadCheckDetails from "@salesforce/apex/LPI_ApplicationActionsController.getBadCheckDetails";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { NavigationMixin } from 'lightning/navigation';

export default class LpiBadCheckWarning extends NavigationMixin(LightningElement) {
	@api recordId;
	isBadCheckPresent = false;
    isModalOpen = false;
	badCheckList = [];
    showSpinner = false;

    @track columns = [
        {
            label: 'Transaction ID',
            fieldName: 'nameUrl',
            type: 'url',
            typeAttributes: {label: { fieldName: 'name' }, 
            target: '_blank'},
            sortable: true
        },
        {
            label: 'Application Id',
            fieldName: 'applicationUrl',
            type: 'url',
            typeAttributes: {label: { fieldName: 'applicationName' }, 
            target: '_blank'},
            sortable: true
        },
        {
            label: 'License',
            fieldName: 'licenseUrl',
            type: 'url',
            typeAttributes: {label: { fieldName: 'licenseNo' }, 
            target: '_blank'},
            sortable: true
        },
        {
            label: 'Check Number',
            fieldName: 'checkNumber',
            type: 'text',
            sortable: true
        },
        {
            label: 'Amount',
            fieldName: 'feeAmount',
            type: 'currency',
            typeAttributes: { maximumFractionDigits: '2', currencyCode: 'USD' },
            cellAttributes: { alignment: 'left' },
            sortable: true
        },
        { 
            type: "button", 
            label: 'Action',
            fixedWidth: 150,
            typeAttributes: {  
                label: 'Record Payment',  
                name: 'recordPayment',  
                title: 'Record Payment',  
                disabled: false,  
                value: 'recordPayment',  
                iconPosition: 'left' ,
                variant: 'brand',
                class: 'scaled-down'
            } 
        }
    ];

    @track actions = [
        { label: 'Record Payment', name: 'recordPayment' }
    ]

	connectedCallback() {
        this.showSpinner = true;
		getBadCheckDetails({ recordId: this.recordId })
			.then((result) => {
				this.badCheckList = result;
                this.isBadCheckPresent = this.badCheckList.length > 0;
                this.showSpinner = false;
                console.log('data ======> '+JSON.stringify(result));
			})
			.catch((error) => {
			
                this.showSpinner = false;
			});
	}

    callRowAction( event ) {  
        this.isModalOpen = false;
        const recId =  event.detail.row.feeId; 
        const actionName = event.detail.action.name;  
        const applicationId = event.detail.row.applicationId;  
        const accountId = event.detail.row.accountId;  
        const objectType = event.detail.row.objectType;  
        const licenseTypeId = event.detail.row.licenseTypeId;  
        if ( actionName === 'recordPayment' ) { 
            this[NavigationMixin.Navigate]({
                type: "standard__component",
                attributes: {
                    componentName: "c__lpiPendingPaymentComp"
                },
                state: {
                    c__applicationId: applicationId,
                    c__accId: accountId,
                    c__regTrxFeeId: recId,
                    c__objectType: objectType,
                    c__licenseTypeId: licenseTypeId,
                    c__isBadCheckPayment: "true"
                }
            });
        }        
  
    }

    handleClose(){
        this.isBadCheckPresent = false;
    }

    handleOpenModal(){
        this.isModalOpen = true;
    }
    handleCloseModal(){
        this.isModalOpen = false;
    }
}