import { LightningElement, wire, track, api } from "lwc";
import getApplicationData from "@salesforce/apex/LPI_ApplicationViewController.getApplicationData";
import { CurrentPageReference } from "lightning/navigation";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { NavigationMixin } from "lightning/navigation";
import { loadStyle } from "lightning/platformResourceLoader";
import lpiTheme from "@salesforce/resourceUrl/LPI_Design";

const BUTTON_TYPE_WEB_LINK = "weblink";
const TYPE_ADOBE_PDF = "AdobePDF";

export default class LpiCrrLicenseActions extends NavigationMixin(LightningElement) {
	@wire(CurrentPageReference)
	currentPageReference;
	@api recordId;
	@track buttonData = [];
	@track dataList = [];
	showButtons = false;
	showSpinner = false;
	showModal = false;
	regId;
	accId;
	busLicenseId;
	@track extraUrlParams;
	type = "";
	subtype = "";
	showChildOfchild = false;
	childValue = "";
	@track childValueMap = {};
	modalHeaderTitle = "";
	childHeadingValue = "";
	@track childButtonList = [];
	@track childofChildList = {};
	@track childOfchildOption = [];

	connectedCallback() {
		this.showSpinner = true;
		loadStyle(this, lpiTheme + "/styles/internal-main.css");
		this.recordId = this.currentPageReference.state.recordId;
		getApplicationData({ blId: this.recordId, blNumber: null,isCCRActions: true })
			.then((result) => {
				if (result) {
					this.regId = result.regId;
					this.accId = result.accId;
					this.busLicenseId = result.blId;
					this.dataList = JSON.parse(JSON.stringify(result.dataList));
					this.buttonData = JSON.parse(JSON.stringify(result.buttonList));
					if (this.buttonData.length > 0) {
						let buttonList = [];
						this.buttonData.forEach((element) => {
							console.log(element.buttonLable);
							 //I-265171 - added by Adarsh
							 element.buttonLable = this.titleCase(element.buttonLable);
							 console.log(element.buttonLable);
							if (result.licenseType === 'Temp Permit - BEHIS' && element.buttonLable === 'Renew') {
								element.buttonLable = 'Extension';
							}
							if (element.buttonName !== TYPE_ADOBE_PDF && element.buttonName !== BUTTON_TYPE_WEB_LINK) {
								buttonList.push(element);
							}
						});
						this.buttonData = buttonList;
					}
					if (this.buttonData.length > 0) {
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

	navigateToPaymentPage(event) {
		this.showSpinner = true;
		
		event.preventDefault();
		
		if(event.target.label == 'Overpayment'){
			this.handleMakePayment();
		}
		else{
		this.getTypeSubtype(event);
		}
	}

	getTypeSubtype(event) {
		//this.showSpinner = true;
		this.extraUrlParams = event.target.dataset.name;
		if (this.type !== "") {
			if (this.subtype === "" || (this.showChildOfchild && this.childValue === "")) {
				this.showSpinner = false;
				this.showMessage("Error", "Select Required Value!", "");
			} else {
				this.getButtonProperties();
			}
		} else {
			let index = event.target.dataset.id;
			let buttonDetail = this.buttonData[index];
			this.type = buttonDetail.buttonName;
			if (buttonDetail.hasChild) {
				this.showSpinner = false;
				this.showModal = true;
				this.showChildOfchild = false;
				this.childValue = "";
				this.childValueMap = {};
				this.modalHeaderTitle = "Select " + this.type + " Type";
				let tempArr = [];
				this.childHeadingValue = "";
				let tempData = {};
				buttonDetail.childButton.forEach(function (arrayItem) {
					tempArr.push({
						label: arrayItem.buttonLable == 'Change of Interim Designated Incharge'? 'Designate Interim Person In Charge (PIC)' : arrayItem.buttonLable,
						value: arrayItem.buttonName
					});
					if (arrayItem.hasChild) {
						let tempArr1 = [];
						arrayItem.childButton.forEach(function (arrayItem1) {
							tempArr1.push({
								label: arrayItem1.buttonLable,
								value: arrayItem1.buttonName
							});
						});
						tempData[arrayItem.buttonName] = {
							listOfChildItem: tempArr1,
							headingLabel: arrayItem.headingLabel
						};
					}
				});
				this.childButtonList = tempArr;
				this.childofChildList = tempData;
			} else {
				this.getButtonProperties();
			}
		}
	}

	getButtonProperties() {
		let data;
		if (this.subtype === "") {
			this.subtype = this.type;
			this.subtype = this.type === "Re-authorization" || this.type === "Re-licensure" ? "Reinstatement" : this.type;
		}

		let licenseId = this.regId;
		let changeStatusAmendmentSubTypeValue =
			this.childValueMap["Change status to other status"] !== undefined
				? this.childValueMap["Change status to other status"]
				: null;
		let additionalLicenseTypeValue =
			this.childValueMap["Obtain Additional License"] !== undefined
				? this.childValueMap["Obtain Additional License"]
				: null;

		this[NavigationMixin.Navigate]({
			type: "standard__component",
			attributes: {
				componentName: "c__lpiPaymentComp"
			},
			state: {
				c__licenseTypeId: licenseId,
				c__recordId: this.accId,
				c__defaultType: this.type,
				c__defaultSubType: this.subtype,
				c__blId: this.busLicenseId,
				c__changeStatusAmendmentSubType: changeStatusAmendmentSubTypeValue,
				c__additionalLicenseType: additionalLicenseTypeValue
			}
		});
	}

	handleChangeSubType(event) {
		this.subtype = event.target.value;
		if (this.childofChildList[this.subtype] !== undefined) {
			this.childValue = "";
			this.showChildOfchild = true;
			this.childOfchildOption = this.childofChildList[this.subtype].listOfChildItem;
			this.childHeadingValue = this.childofChildList[this.subtype].headingLabel;
		} else {
			this.childValue = "";
			this.showChildOfchild = false;
		}
	}

	handleChildChangeType(event) {
		this.childValue = event.target.value;
		let tempChild = {};
		tempChild[this.subtype] = event.target.value;
		this.childValueMap = tempChild;
	}

	showMessage(that, title, message, variant, mode) {
		const toastEvt = new ShowToastEvent({
			title,
			message,
			variant,
			mode
		});
		this.dispatchEvent(toastEvt);
	}

	handlePreviousClick() {
		this.type = "";
		this.subtype = "";
		this.showModal = false;
	}
	handleMakePayment(){
		this[NavigationMixin.Navigate]({
			type: "standard__component",
			attributes: {
				componentName: "c__lpiPendingPaymentComp"
			},
			state: {
				c__applicationId: this.busLicenseId,
				c__licenseTypeId: this.regId,
				c__accId: this.accId,
				c__isBadCheckPayment: "false",
				c__isOverPayment: "true",
				c__objectType: "BusinessLicense"
			}
		});
	}

	//I-265171 - added by Adarsh
    titleCase(str) {
        var splitStr = str.split(' ');
        for (var i = 0; i < splitStr.length; i++) {
            if(splitStr[i].length >3){
                splitStr[i] = splitStr[i].charAt(0).toUpperCase() + splitStr[i].substring(1);  
            }
               
        }
        return splitStr.join(' '); 
     }
}