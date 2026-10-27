import { LightningElement, api } from 'lwc';
import { NavigationMixin } from "lightning/navigation";
import isExecutiveDirectorUser from "@salesforce/apex/LPI_AuditRandomSelectorController.isExecutiveDirectorUser";
import {ShowToastEvent} from "lightning/platformShowToastEvent";

export default class LpiAuditRandomSelectorRedirect extends NavigationMixin(LightningElement) {
    @api recordId;
    isProcessing = false;

    @api invoke() {
        this.isProcessing = true;
        isExecutiveDirectorUser({issuingDepartmentId: this.boardId})
            .then((result)=>{
                if(result){
                    let cmpDef = {
                        componentDef: "c:lpiAuditRandomSelector",
                        attributes: {
                            boardId: this.recordId,
                        }
                    };
                    let encodedDef = btoa(JSON.stringify(cmpDef));
                    this[NavigationMixin.Navigate]({
                        type: "standard__webPage",
                        attributes: { url: "/one/one.app#" + encodedDef }
                    });
                } else{
                    this.showMessage('Access Denied','Sorry, You don\'t have Audit Access.','error');
                }
                this.isProcessing = false;
            })
            .catch((error)=>{
                this.showMessage('Error',JSON.stringify(error),'error');
                this.isProcessing = false;
            });
    }

    showMessage(title, message, variant) {
		const toastEvt = new ShowToastEvent({
			title,
			message,
			variant
		});
		this.dispatchEvent(toastEvt);
	}
}