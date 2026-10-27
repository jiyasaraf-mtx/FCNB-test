import { LightningElement, track, api } from "lwc";
import getAppDataForCrr from "@salesforce/apex/LPI_ApplicationActionsController.getAppDataForCrr";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { NavigationMixin } from "lightning/navigation";
import { loadStyle } from "lightning/platformResourceLoader";
import lpiTheme from "@salesforce/resourceUrl/LPI_Design";
const BUTTON_TYPE = new Set(["downloadPayReceipt","downloadApplication","ResumeApplication"]);


export default class LpiCrrApplicationActions extends NavigationMixin(LightningElement) {
	@api recordId;
	@track buttons = [];
	showButtons = true;
	showSpinner = false;
	regId;
	accId;
	applicationId;
	type = "";
	subtype = "";
	isSupportStaff;
@track applicationRecord;
	connectedCallback() {
		this.showSpinner = true;
		loadStyle(this, lpiTheme + "/styles/internal-main.css");
		getAppDataForCrr({ recordId: this.recordId})
			.then((result) => {
				if (result) {
                    this.accId = result.applicationData.accountId;
                    this.regId = result.applicationData.licenceTypeId;
					this.applicationId = result.applicationData.applicationId;
this.applicationRecord = result.applicationData;
					if (result.buttonList.length > 0) {
                        //Filtering Ancillary Applications
						result.buttonList.forEach((element) => {
							console.log("test");
                            if(!BUTTON_TYPE.has(element.name)){
                                this.buttons.push(element);
                            }
						});
					}
					if (this.buttons.length > 0) {
						this.showButtons = true;
					} else {
						this.showButtons = false;
					}
					this.showSpinner = false;
				}
			})
			.catch((error) => {
				const event = new ShowToastEvent({
					title: "Error",
					message: "Something went wrong! " + JSON.stringify(error),
					variant: "error"
				});
				this.dispatchEvent(event);
				this.showSpinner = false;
			});
	}

	handleMakePayment(event){
		if(event.target.label === 'Overpayment'){
			this.navigateToOverPaymentPage(event);
		}
		else{
			this.navigateToPaymentPage(event)
		}
	}

	navigateToPaymentPage(event) {
		this.showSpinner = true;
		event.preventDefault();
		let index = event.target.dataset.id;
		let buttonDetail = JSON.parse(this.buttons[index].buttonData);
		//Getting Ancillary Application Type & Subtype
		this.type = buttonDetail.type;
		this.subtype = buttonDetail.subType;
		//Navigating to the Payment Page
		this[NavigationMixin.Navigate]({
			type: "standard__component",
			attributes: {
				componentName: "c__lpiPaymentComp"
			},
			state: {
				c__recordId: this.accId,
				c__licenseTypeId: this.regId,
				c__defaultType: this.type,
				c__defaultSubType: this.subtype,
				c__applicationId: this.applicationId
			}
		});
	}
navigateToOverPaymentPage(event){
		this[NavigationMixin.Navigate]({
			type: "standard__component",
			attributes: {
				componentName: "c__lpiPendingPaymentComp"
			},
			state: {
				c__applicationId: this.applicationId,
				c__licenseTypeId: this.regId,
				c__accId: this.accId,
				c__isBadCheckPayment: "false",
				c__isOverPayment: "true",
				c__objectType: "IndividualApplication",
				c__applicationType: this.applicationRecord.applicationType,
				c__applicationSubType: this.applicationRecord.applicationSubType
			}
		});
	}
}