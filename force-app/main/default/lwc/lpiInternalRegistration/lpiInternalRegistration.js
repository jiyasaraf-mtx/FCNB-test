import { LightningElement, api, wire } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getRegulatoryAuthorizationTypesByLicenses from "@salesforce/apex/LPI_InternalRegistration.getRegulatoryAuthorizationTypesByLicenses";
import getRegulatoryAuthorizationTypesByBoard from "@salesforce/apex/LPI_InternalRegistration.getRegulatoryAuthorizationTypesByBoard";
import getLicensesAtInitialLoad from "@salesforce/apex/LPI_InternalRegistration.getLicensesAtInitialLoad";
import getIsPortalUser from "@salesforce/apex/LPI_InternalRegistration.getIsPortalUser";
import checkApplyLicense from "@salesforce/apex/LPI_InternalRegistration.checkApplyLicense";
import { loadStyle } from "lightning/platformResourceLoader";
import lpiResource from '@salesforce/resourceUrl/LPI_Design';
import applyLicenseModalCss from '@salesforce/resourceUrl/LPI_ApplyLicenseModal';
export default class LpiInternalRegistration extends NavigationMixin(LightningElement) {
	@api recordId;
	searchLicenseKey = "";
	searchBoardKey = "";
	licensesList;
	spinner = false;
	isPortalUser;
	parId = "";
	licensesListSize;
	error = false;
	guidingText = "Know more";

	connectedCallback() {
		this.spinner = true;

		getIsPortalUser()
			.then((result) => {
				this.isPortalUser = result;
				this.spinner = false;
			})
			.catch((error) => {
				this.error = true;
				this.spinner = false;
			});

			//Loading CSS
			Promise.all([
				loadStyle(this, lpiResource + "/styles/internal-main.css"),
				loadStyle(this, applyLicenseModalCss)
			]).catch(() => {
				// Styles are non-blocking for modal functionality
			});
	}

	@wire(getLicensesAtInitialLoad, { accountId: "$recordId" })
	wiredLicenses({ error, data }) {
		if (data) {
			this.licensesList = data;
			console.log('licensesList :>> ', JSON.stringify(this.licensesList));
			this.licensesListSize = data.length;
			this.processRecords();
		} else if (error) {
			this.error = true;
		}
	}

	licenseKeyChange(event) {
		this.searchLicenseKey = event.target.value;
	}

	boardKeyChange(event) {
		this.searchBoardKey = event.target.value;
	}

	handleKeyUp(event) {
		let searchBy = event.target.name;
		const isEnterKey = event.keyCode === 13;
		if (isEnterKey) {
			if (searchBy === "licenseSearch") {
				this.handleLicenseSearch();
			} else {
				this.handleBoardSearch();
			}
		}
	}

	processRecords() {
		if (!this.licensesList || this.licensesList.length == 0) return;
		this.licensesList = this.licensesList.map((record) => {
			return { ...record, showAccordion: !record.description ? false : true };
		});
	}
	handleLicenseSearch() {
		this.spinner = true;
		getRegulatoryAuthorizationTypesByLicenses({ regAuthType: this.searchLicenseKey, accountId: this.recordId })
			.then((result) => {
				this.licensesList = result;
				this.licensesListSize = result.length;
				this.spinner = false;
				this.processRecords();
			})
			.catch((error) => {
				this.error = true;
				this.spinner = false;
			});
	}

	handleBoardSearch() {
		this.spinner = true;
		getRegulatoryAuthorizationTypesByBoard({ regAuth: this.searchBoardKey, accountId: this.recordId })
			.then((result) => {
				this.licensesList = result;
				this.licensesListSize = result.length;
				this.spinner = false;
				this.processRecords();
			})
			.catch((error) => {
				this.error = true;
				this.spinner = false;
			});
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

	navigateToPaymentPage(event) {
		this.spinner = true;
		event.preventDefault();
		let licenseId = event.target.dataset.licenseid;
		let licenseName = event.target.dataset.licensename;

		this[NavigationMixin.Navigate]({
			type: "standard__component",
			attributes: {
				componentName: "c__lpiPaymentComp"
			},
			state: {
				c__licenseTypeId: licenseId,
				c__recordId: this.recordId,
				c__defaultType: "New",
				c__licenseName: licenseName
			}
		});
	}
}