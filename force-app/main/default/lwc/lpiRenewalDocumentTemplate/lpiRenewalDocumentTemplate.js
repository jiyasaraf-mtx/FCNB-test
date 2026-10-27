/* eslint-disable no-mixed-spaces-and-tabs */
import getAdobeDocumentLink from "@salesforce/apex/LPI_DocumentConfigGenerator.getAdobeDocumentLink";
import getLicenseDetails from "@salesforce/apex/LPI_DocumentConfigGenerator.getLicenseDetails";
import getPostcardLicenseDetails from "@salesforce/apex/LPI_DocumentConfigGenerator.getPostcardLicenseDetails";
import loadPicklistValues from "@salesforce/apex/LPI_DocumentConfigGenerator.getRegAuthType";
import { showAsyncErrorMessage, showMessage, } from "c/lpiUtil";
import { LightningElement, api, track } from "lwc";
import { loadStyle } from 'lightning/platformResourceLoader';
import LPI_InternalCSS from "@salesforce/resourceUrl/LPI_Design";

const WALL_HANGING = "Wall Hangings";
const RENEWAL = "Renewal";
const REINSTATEMENT = "Reinstatement";
const POSTCARD = "Postcard";
const SENT_FOR_PRINTING = "Sent for Printing";
const WALL_HANGING_CONFIG_ERROR = 'Wall Hangings are not configured for this Board. Please contact Admin';

export default class LpiRenewalDocumentTemplate extends LightningElement {
	@api recordId;
	resultLength = 0;
	@track status;
	@track selectedLicense;
	@track showScreen1 = true;
	@track selectedOption = [];
	@track selectedValues = [];
	@track picklistOptions = [];
	@track multiSelectPicklistOptions = [];
	@track selectedMultiSelectOptions = [];
	@track showSpinner = false;
	@track searchTerm = "";
	@track sentPrintChk = false;
	@track showLicenseType = false;
	@track showRenewalCycle = false;
	@track showPostcardLicenseType = false;
	@track sentForPrintCheck = false;
	@track showIssueDateRange = false;
	@track regAuthId = '';
	selectedOptionValid = false;
	selectedCycleOptionValid = false;
	selectedTemplateValid = false;
	selectedValuesValid = false;
	isRetired = "";
	originalData = [];
	options = [];
	selectedTemplateOption;
	selectedCycleOption;
	selectedLicenseTypeOption;
	nursingStatus = false;
	selectedIssueDateFrom;
	selectedIssueDateTo;
	selectedIssueDateFilter;
	templateOptions = [
		{
			label: "Renewal",
			value: "Renewal"
		},
		{
			label: "Reinstatement",
			value: "Reinstatement"
		},
		{
			label: "Postcard",
			value: "Postcard"
		},
		{
			label: "Wall Hangings",
			value: "Wall Hangings"
		}
	];
	indicatorOption = [
		{
			label: "Sent for Printing",
			value: "Sent for Printing"
		},
		{
			label: "90-Days Processed",
			value: "90-Days Processed"
		},
		{
			label: "60-Days Processed",
			value: "60-Days Processed"
		},
		{
			label: "30-Days Processed",
			value: "30-Days Processed"
		}
	];
	renewalCycleOptions = [
		{
			label: "Current Renewal Cycle",
			value: "0"
		},
		{
			label: "Previous 1-year renewal",
			value: "1"
		},
		{
			label: "Previous 2-year renewal",
			value: "2"
		},
		{
			label: "Previous 3-year renewal",
			value: "3"
		},
		{
			label: "Previous 4-year renewal",
			value: "4"
		}
	];
	// datatable code
	@track data = [];
	@track filteredData = [];
	@track respData = [];

	@track selectedRows = [];

	columns = [
		{
			type: "checkbox",
			fieldName: "serialNo",
			label: "SNo."
		},
		{
			label: "License Number",
			fieldName: "Name",
			type: "text"
		},
		{
			label: "Licensee Name",
			fieldName: "LicenseeName",
			type: "text"
		},
		{
			label: "Expiry Date",
			fieldName: "PeriodEnd",
			type: "date"
		},
		{
			label: "Status",
			fieldName: "Status",
			type: "text"
		},
		{
			label: "Sent for Print?",
			fieldName: "sentForPrint",
			type: "Boolean"
		}
	];

	columnsForWallHanging = [
		{
			type: "checkbox",
			fieldName: "serialNo",
			label: "SNo."
		},
		{
			label: "License Number",
			fieldName: "Name",
			type: "text"
		},
		{
			label: "Licensee Name",
			fieldName: "LicenseeName",
			type: "text"
		},
		{
			label: "Issuance Date",
			fieldName: "PeriodStart",
			type: "date"
		},
		{
			label: "Status",
			fieldName: "Status",
			type: "text"
		},
		{
			label: "Print Indicator",
			fieldName: "Wall_Hanging_Print_Indicator__c",
			type: "text"
		}
	];

	get columnList() {
		return this.selectedTemplateOption === WALL_HANGING ? this.columnsForWallHanging : this.columns;
	}

	get showIssuanceDateFilter() {
		return this.selectedTemplateOption === WALL_HANGING;
	}

	get isButtonDisabled() {
		return this.selectedRows.length === 0;
	}

	get showTable() {
		return this.data.length > 0;
	}

	handleTemplateChange(event) {
		this.selectedTemplateOption = event.detail.value;
		this.selectedTemplateValid = event.detail.value !== "";
		// show licenseType as per TemplateName
		if (this.selectedTemplateOption === RENEWAL) {
			this.showLicenseType = true;
			this.showRenewalCycle = true;
			this.showPostcardLicenseType = false;
			this.showIssueDateRange = false;
		} else if (this.selectedTemplateOption === REINSTATEMENT) {
			this.showLicenseType = true;
			this.showRenewalCycle = false;
			this.showPostcardLicenseType = false;
			this.showIssueDateRange = false;
		} else if (this.selectedTemplateOption === WALL_HANGING) {
			this.showRenewalCycle = this.showPostcardLicenseType = false;
			this.showLicenseType = this.showIssueDateRange = true;
		} else {
			this.showLicenseType = false;
			this.showRenewalCycle = false;
			this.showIssueDateRange = false;
			this.showPostcardLicenseType = true; //to show postcard filters
		}
	}
	handlePostcardSentForPrint(event) {
		this.sentForPrintCheck = event.detail.checked;
		if (this.sentForPrintcheck) {
			this.fetchPostcardLicenseDetails();
		} else {
			this.showPostcardSecondScreen();
		}
	}
	handleRenewalCycle(event) {
		this.selectedCycleOption = event.detail.value;
		this.selectedCycleOptionValid = event.detail.value !== "";
	}
	connectedCallback() {
		this.loadData();
		this.loadData1(); //multiselect
		loadStyle(this, LPI_InternalCSS + "/styles/internal-main.css")
	}
	//multiselect
	handleMultiselectChange(event) {
		this.selectedValues = event.detail.value;
		this.selectedValuesValid = event.detail.value !== "";
	}
	handlePicklistChange(event) {
		this.selectedOption = event.detail.value;
		this.selectedOptionValid = event.detail.value !== "";
		this.selectedLicense = this.picklistOptions.find((option) => option.value === this.selectedOption);
		if (this.selectedLicense) {
			this.regAuthId = this.selectedLicense.value;
			// Set the label (license name) as the selectedOption
			if (
				this.selectedLicense.label === "Licensed Practical Nurse" ||
				this.selectedLicense.label === "Registered Nurse"
			) {
				this.nursingStatus = true;
			}
		}
	}

	// Function to validate selected fields based on the chosen template option
	validateFields() {
		if (this.selectedTemplateOption === RENEWAL) {
			return this.selectedOptionValid && this.selectedCycleOption;
		} else if (this.selectedTemplateOption === REINSTATEMENT) {
			return this.selectedOptionValid;
		} else if (this.selectedTemplateOption === POSTCARD) {
			return this.selectedValuesValid;
		} else if (this.selectedTemplateOption === WALL_HANGING) {
			return this.selectedOptionValid;
		}
		return false; // Return false if selectedTemplateOption is null
	}

	// Event handler for handleNoEmail
	handleNoEmail(event) {
		this.noEmailChecked = event.target.checked;
		this.showScreen1 = false;
		this.fetchPostcardLicenseDetails();
	}

	showSecondScreen() {
		if (this.validateFields()) {
			this.showScreen1 = false;
			this.showSpinner = true;
			const dateRange = {
				issuanceDateFrom: this.selectedIssueDateFrom,
				issuanceDateTo: this.selectedIssueDateTo
			};
			this.retrieveLicenseDetails(dateRange);
		} else {
			showAsyncErrorMessage(this, "Required Field Missing");
		}
	}

	retrieveLicenseDetails(dateRange) {
		this.showSpinner = true;
		getLicenseDetails({
			regAuthTypeId: this.selectedOption,
			type: this.selectedTemplateOption,
			issueDateRange: dateRange,
			selectedIndicator: this.sentPrintChk
		})
			.then((result) => {
				if (!result) {
					showAsyncErrorMessage(this, "No data found");
				} else {
					this.resultLength = result.length;
					this.originalData = result.map((element, index) => {
						element.serialNo = index + 1;
						element.sentForPrint = element.Renewal_Document_Print_Indicator__c === SENT_FOR_PRINTING;
						element.LicenseeName = element.RegulatoryAuthorizationType.Authorisation_Type__c === "Business"
							? (element.Business_Entity_Name__c || "")
							: (element.Account && element.Account.Name ? element.Account.Name : "");

						element.Status = element.Status || "";
						if (element.Status === "Expired") {
							element.Status = "Expired/Lapsed";
						}

						return element;
					});
					this.data = [...this.originalData];
				}
			})
			.catch((error) => {
				showAsyncErrorMessage(this, error);
			})
			.finally(() => {
				this.showSpinner = false;
			});
	}


	// Event handler for showPostcardSecondScreen
	showPostcardSecondScreen() {
		if (this.validateFields()) {
			this.showScreen1 = false;
			//this.sentForPrintCheck  = false;
			this.fetchPostcardLicenseDetails();
		} else {
			showAsyncErrorMessage(this, "Required Field Missing");
		}
	}

	// Function to fetch postcard license details
	fetchPostcardLicenseDetails() {
		this.showSpinner = true;
		getPostcardLicenseDetails({
			regAuthTypeIds: this.selectedValues,
			type: this.selectedTemplateOption,
			selectedIndicator: this.sentForPrintCheck,
			dontNeedEmail: this.noEmailChecked
		})
			.then((result) => {
				if (!result) {
					showAsyncErrorMessage(this, "No data found");
					// eslint-disable-next-line no-unused-vars
					let showTable = this.showTable;
				} else {
					// Set the resultLength property
					// eslint-disable-next-line @lwc/lwc/no-api-reassignments
					this.resultLength = result.length;
					this.originalData = JSON.parse(JSON.stringify(result));
					let count = 1;
					this.originalData.forEach((element) => {
						element.serialNo = count;
						//element.sentForPrint = element.Postcard_Document_Print_Indicator__c === SENT_FOR_PRINTING;
						if (element.RegulatoryAuthorizationType.Authorisation_Type__c === "Business") {
							element.LicenseeName = element.Business_Entity_Name__c
								? element.Business_Entity_Name__c
								: "";
						} else {
							element.LicenseeName = element.Account && element.Account.Name ? element.Account.Name : "";
						}

						element.Status = element.Status ? element.Status : "";

						if (element.Status === "Expired") {
							element.Status = "Expired/Lapsed";
						}
						count++;
					});
					this.data = [...this.originalData];
					// eslint-disable-next-line no-unused-vars
					let showTable = this.showTable;
				}
			})
			.catch((error) => {
				showAsyncErrorMessage(this, error);
			})
			.finally(() => {
				this.showSpinner = false;
			});
	}

	showFirstScreen() {
		this.showScreen1 = true;
		this.resetVariables();
	}

	resetVariables() {
		this.sentForPrintCheck = false;
		this.selectedIssueDateFilter = null;
		this.sentPrintChk = false;
	}

	handleRowSelection(event) {
		this.selectedRows = event.detail.selectedRows;
	}
	loadData() {
		loadPicklistValues({
			recordId: this.recordId
		})
			.then((result) => {
				if (!result) {
					showAsyncErrorMessage(this, "No data found");
				} else {
					this.picklistOptions = JSON.parse(JSON.stringify(result));
				}
			})
			.catch((error) => {
				showAsyncErrorMessage(this, error);
			})
			.finally(() => {
				this.showSpinner = false;
			});
	}
	//multi select options
	loadData1() {
		loadPicklistValues({
			recordId: this.recordId
		})
			.then((result) => {
				if (!result) {
					showAsyncErrorMessage(this, "No data found");
				} else {
					this.multiSelectPicklistOptions = JSON.parse(JSON.stringify(result));
					this.options = this.multiSelectPicklistOptions.map((option) => ({
						label: option.label,
						value: option.value
					}));
				}
			})
			.catch((error) => {
				showAsyncErrorMessage(this, error);
			})
			.finally(() => {
				this.showSpinner = false;
			});
	}

	getBulkLicenseDetailsJson() {
		try {
			let blIdList = [];
			this.selectedRows.forEach((element) => {
				blIdList.push(element.Id);
			});

			if (this.isRetired) {
				this.status = "Retired";
			} else {
				this.status = "";
			}

			this.prepareJson(blIdList);
		} catch (error) {
			showAsyncErrorMessage(this, error);
		}
	}

	prepareJson(blIdList) {
		try {
			this.showSpinner = true; // Show spinner immediately before the API call

			let licenseTypeName = this.selectedTemplateOption === "Postcard" ? null : this.selectedLicense.label;
			// this is coming as empty so breaking the download , we need to make it null
			if(this.selectedTemplateOption === "Postcard"){
				this.regAuthId = null;
			}
			// Call the Apex method
			getAdobeDocumentLink({
				recordId: blIdList,
				licenseTypeName: licenseTypeName,
				cycle: this.selectedCycleOption,
				status: this.status,
				type: this.selectedTemplateOption,
				regAuthId: this.regAuthId
			})
				.then((result) => {
					// eslint-disable-next-line @lwc/lwc/no-async-operation
					setTimeout(() => {
						if (result === null) {
							// Code to run when result is null
							if (blIdList.length > 1) {
								showMessage(this, {
									title: "Success",
									message: "Success: The selected application(s) have been successfully sent for printing!",
									messageType: "success",
									mode: "dismissable"
								});
							} else {
								showMessage(this, {
									title: "Success",
									message: "Success: The selected application has been successfully sent for printing!",
									messageType: "success",
									mode: "dismissable"
								});
							}
							if (this.selectedTemplateOption !== 'Postcard') {
								if (this.sentPrintChk === false) {
									this.showSecondScreen();
								}
							}
							if (this.selectedTemplateOption === "Postcard") {
								this.fetchPostcardLicenseDetails();
								this.showPostcardSecondScreen();
							}
							this.showSpinner = false; // Hide spinner after API call resolves
						} else {
							// Code to run when result is not null 
							window.open(result, '_blank'); // Open the link in a new tab
							this.showSpinner = false; // Hide spinner after API call resolves
						}
					}, 5000); // 5 seconds delay
				})
				.catch((error) => {
					showAsyncErrorMessage(this, error?.body?.message);
					if (error?.body?.message === WALL_HANGING_CONFIG_ERROR) {
						this.showSpinner = false;
						return;
					}
					if (blIdList.length > 1) {
						showAsyncErrorMessage(this, 'Error: Failed to send application(s) for printing. Please try again after some time!');

					} else {
						showAsyncErrorMessage(this, 'Error: Failed to send the application for printing. Please try again after some time!');
					}
					this.showSpinner = false; // Hide spinner after API call rejects
				});
		} catch (error) {
			showAsyncErrorMessage(this, error);
		}
	}

	handleSearchChange(event) {
		this.searchTerm = event.target.value;
		this.filterData();
	}
	handleFilterNursing(event) {
		this.isRetired = event.detail.checked;
		this.filterData();
	}
	filterData() {
		if (this.sentPrintChk && this.searchTerm != "" && this.isRetired) {
			this.filteredData = this.originalData.filter((record) => {
				return record.Name.toLowerCase().includes(this.searchTerm);
			});
			this.respData = this.filteredData.filter((record) => {
				return record.sentForPrint == true;
			});
			this.data = this.respData.filter((record) => {
				return record.Status.toLowerCase().includes("retired");
			});
		} else if (this.sentPrintChk && this.searchTerm != "" && !this.isRetired) {
			this.filteredData = this.originalData.filter((record) => {
				return record.Name.toLowerCase().includes(this.searchTerm);
			});
			this.data = this.filteredData.filter((record) => {
				return record.sentForPrint == true;
			});
		} else if (this.sentPrintChk && this.searchTerm == "" && !this.isRetired) {
			this.data = this.originalData.filter((record) => {
				return record.sentForPrint == true;
			});
		} else if (this.sentPrintChk && this.searchTerm == "" && this.isRetired) {
			this.filteredData = this.originalData.filter((record) => {
				return record.sentForPrint == true;
			});
			this.data = this.filteredData.filter((record) => {
				return record.Status.toLowerCase().includes("retired");
			});
		} else if (!this.sentPrintChk && this.searchTerm != "" && this.isRetired) {
			this.filteredData = this.originalData.filter((record) => {
				return record.Name.toLowerCase().includes(this.searchTerm);
			});
			this.data = this.filteredData.filter((record) => {
				return record.Status.toLowerCase().includes("retired");
			});
		} else if (!this.sentPrintChk && this.searchTerm == "" && this.isRetired) {
			this.data = this.originalData.filter((record) => {
				return record.Status.toLowerCase().includes("retired");
			});
		} else if (!this.sentPrintChk && this.searchTerm != "" && !this.isRetired) {
			this.data = this.originalData.filter((record) => {
				return record.Name.toLowerCase().includes(this.searchTerm);
			});
		} else if (this.sentPrintChk && this.searchTerm == "" && !this.isRetired) {
			this.data = this.originalData.filter((record) => {
				return record.sentForPrint == true;
			});
		} else {
			// If the search term is empty, reset the data to the original data
			this.data = [...this.originalData];
		}

		//Filter records for wall hangings issue date filter
		if (this.selectedTemplateOption === WALL_HANGING && this.selectedIssueDateFilter) {
			this.data = this.data.filter((record) => {
				let periodDate = new Date(record.PeriodStart);
				let selectedDate = new Date(this.selectedIssueDateFilter);
				let isDateMatched =
					periodDate.getDate() === selectedDate.getDate() &&
					periodDate.getMonth() === selectedDate.getMonth() &&
					periodDate.getFullYear() === selectedDate.getFullYear();
				return isDateMatched;
			});
		}
	}
	handleFilterSentForPrint(event) {
		this.sentPrintChk = event.detail.checked;
		this.filterData();
		const dateRange = {
			issuanceDateFrom: this.selectedIssueDateFrom,
			issuanceDateTo: this.selectedIssueDateTo
		};
		if (this.sentPrintChk) {
			this.retrieveLicenseDetails(dateRange);
		} else {
			this.showSecondScreen();
		}
	}

	handleIssuanceDateChange(event) {
		if (event.target.name === "issuanceDateFrom") {
			this.selectedIssueDateFrom = event.target.value;
		} else if (event.target.name === "issuanceDateTo") {
			this.selectedIssueDateTo = event.target.value;
		} else if (event.target.name === "issuanceDateFilter") {
			this.selectedIssueDateFilter = event.target.value;
			this.data = this.originalData;
			if (this.searchTerm) {
				this.data = this.data.filter((record) => {
					return record.Name.toLowerCase().includes(this.searchTerm);
				});
			}
			if (this.selectedIssueDateFilter) {
				this.data = this.data.filter((record) => {
					let periodDate = new Date(record.PeriodStart);
					let selectedDate = new Date(this.selectedIssueDateFilter);
					let isDateMatched =
						periodDate.getDate() === selectedDate.getDate() &&
						periodDate.getMonth() === selectedDate.getMonth() &&
						periodDate.getFullYear() === selectedDate.getFullYear();
					return isDateMatched;
				});
			}
		}
	}
}