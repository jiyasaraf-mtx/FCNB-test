import { LightningElement, track, wire, api } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { OmniscriptBaseMixin } from "omnistudio/omniscriptBaseMixin";
import { OmniscriptActionCommonUtil } from "omnistudio/omniscriptActionUtils";
import { getNamespaceDotNotation } from "omnistudio/omniscriptInternalUtils";

export default class LpiFuneralEstablishmentAddMultipleBusiness extends OmniscriptBaseMixin(
	LightningElement
) {
	@api isReview = false;
	@track showSpinner = false;
	_ns = getNamespaceDotNotation();
	@track itemList = [
		{
			serialNumber: 0,
			memberCount: 1,
			id: "",
			isDisable: true,
			establishmentLicId: "",
			hideDelete: false,
			isChild: false,
			label: "Establishment - 1",
			establishmentLicNo: "",
			beginDate: null,
			relationshipAssociatedWithYou: true,
		},
	];
	@track booleanTrue = true;
	@track booleanFalse = false;
	@api parid;
	@api blid;
	@track isSaveAndExit = false;	
	@track isShowSucessPage = false;	
	@track isShowDetils = true;
	_actionUtil;
	inputData = {};
	connectedCallback() {
		this.getAllData();
	}
	handleChange(event) {
		let selectedRowSerial = event.target.dataset.parentid;
		let foundElement = this.itemList.find(function (element) {
			return element.serialNumber == selectedRowSerial;
		});
		if (foundElement) {
			if (event.target.type == "checkbox") {
				foundElement[event.target.name] = event.target.checked;
			} else {
				foundElement[event.target.name] = event.target.value;
			}
		}
	}
	getAllData() {
		this._actionUtil = new OmniscriptActionCommonUtil();
		this.showSpinner = true;
		this.inputData = {};
		this.inputData.parid = this.parid;
		let params = {
			input: this.inputData,
			sClassName: "MODPR_EstablishmentInformationController",
			sMethodName: "getBusinessRecords",
			options: "{}",
		};
		this._actionUtil
			.executeAction(params, null, this, null, null)
			.then((response) => {
				this.hasRecords = response.result?.getBusinessRecords?.length > 0;
				if (this.hasRecords) {
					this.itemList = JSON.parse(
						JSON.stringify(response.result.getBusinessRecords)
					);
				}
                setTimeout(() => {
                    this.showSpinner = false;
                }, 1000);
			})
			.catch((error) => {
				console.log("error->", error);
				const evt = new ShowToastEvent({
					title: "Error",
					message: error,
					variant: "Error",
				});
				this.dispatchEvent(evt);
				this.showSpinner = false;
			});
	}
	hasRecords = false;
	isInputValid() {
		let isAllValid = true;
		let isLicenseValid = true;
		let licenseIds = [];
		for (var temp of this.itemList) {
			if (!licenseIds.includes(temp.establishmentLicNo)) {
				licenseIds.push(temp.establishmentLicNo);
				if (temp.establishmentLicNo == null || temp.establishmentLicNo == "") {
					isAllValid = false;
					this.openAccordians(temp.label);
					break;
				}
			} else {
				isLicenseValid = false;
				const evt = new ShowToastEvent({
					title: "Error",
					message: "Please select different Establishment License Number.",
					variant: "Error",
				});
				this.dispatchEvent(evt);
				break;
			}
		}
		// if (!isAllValid) {
		// 	const evt = new ShowToastEvent({
		// 		title: "Error",
		// 		message: "Please fill all information.",
		// 		variant: "Error",
		// 	});
		// 	this.dispatchEvent(evt);
		// }

		return isAllValid && isLicenseValid;
	}

	async openAccordians(parentLabel){
		const activeOuterSections = this.template.querySelectorAll('.outerAccordion');
		console.log('str. charAt(str. length - 1) : ',parentLabel.charAt(parentLabel.length - 1));
		activeOuterSections[parentLabel.charAt(parentLabel.length - 1)-1].activeSectionName = [parentLabel];
		await Promise.resolve();
		this.focusChildInput();
	}

	focusChildInput(){
		const objChild = this.template.querySelectorAll('c-lpi-custom-lookup-establishment');
		for(var temp of objChild) {
			if(!temp.inputValid()) break;
		}
	}

	isInputFieldsValid() {
		var estNumber;
		let valid = [...this.template.querySelectorAll('lightning-input')].reduce(
			(validSoFar, input) => {
				if( input.type === 'date' ) {
					if( !input.checkValidity() ) {
						estNumber = Number(input.getAttribute('data-parentid')) + 1;
						const activeOuterSections = this.template.querySelectorAll('.outerAccordion');
						activeOuterSections[estNumber-1].activeSectionName = ['Establishment - '+estNumber];
						input.classList.add('slds-has-error');
					} else {
						input.classList.remove('slds-has-error');
					}
				}
				input.reportValidity();
				return validSoFar && input.checkValidity();
			}, true);

		setTimeout(() => {
			let allInput = this.template.querySelector(".slds-has-error");
	
			if (allInput) {
				allInput.scrollIntoView();
				allInput.focus();
			}
		}, 200);
		return valid;
	}

	@track isSaveAndExitOkClicked = false;
	handleSave(event) {
		this.isSaveAndExitOkClicked = false;	
        if(event.target.label == 'OK'){	
            this.isSaveAndExitOkClicked = true;	
        }
        if(this.itemList.length <1){
            const evt = new ShowToastEvent({
				title: "Error",
				message: "Please add at least one Establishment.",
				variant: "Error",
			});
			this.dispatchEvent(evt);
            return;
        }
		if (this.isInputValid() && this.isInputFieldsValid()) {
		    this.showSpinner = true;
			this.inputData = {};
			this.inputData.json = JSON.stringify(this.itemList);
			this.inputData.parid = this.parid;
			this.inputData.blid = this.blid;
			let params = {
				input: this.inputData,
				sClassName: "MODPR_EstablishmentInformationController",
				sMethodName: "saveBusinessRecord",
				options: "{}",
			};
			this._actionUtil
				.executeAction(params, null, this, null, null)
				.then((response) => {
					if(response.result.saveBusinessRecord == 'success'){
						if(!this.isSaveAndExitOkClicked){	
							this.omniNextStep();	
						}else{	
							this.isSaveAndExit = false;	
							this.isShowSucessPage = true;	
							this.isShowDetils = false;
						}
					}else{
						const evt = new ShowToastEvent({
							title: "Error",
							message: "Error in Saving",
							variant: "error"
						});
						this.dispatchEvent(evt);
					}
					this.showSpinner = false;
				})
				.catch((error) => {
					console.log("error->", error);
					const evt = new ShowToastEvent({
						title: "Error",
						message: error,
						variant: "error",
					});
					this.dispatchEvent(evt);
					this.showSpinner = false;
				});
		}
	}
	async handleAddRow() {
		if (this.itemList) {
			let nextIndex = this.itemList.length;
			var newItem = {
				serialNumber: 0,
				hideDelete: false,
				isChild: false,
				id: "",
				relationshipAssociatedWithYou: true,
				isDisable: true,
				establishmentLicId: "",
				beginDate: null,
				relationshipAssociatedWithYou: true,
			};
			newItem.serialNumber = nextIndex;
			newItem.memberCount = nextIndex + 1;
			newItem.label = "Establishment - " + newItem.memberCount;
			this.itemList.push(newItem);

			//To show focus on first element which is custom lookup cmp when Establishment added
			await Promise.resolve();
			const objChild = this.template.querySelectorAll('c-lpi-custom-lookup-establishment');
			for(var temp of objChild) {
				if(temp.parentId == nextIndex){
					setTimeout(() => {
						temp.inputValid();
					}, 500);
					break;
				}
			}
		}
	}

	handleDelete(event) {
		var selectedRowSerial = event.target.dataset.parentid;
		if (this.itemList && this.itemList.length >= 1) {
			this.showSpinner = true;
			var index = this.itemList.findIndex(function (o) {
				return o.serialNumber == selectedRowSerial;
			});
			if (index != -1) {
				let dataObj = this.itemList[index];
				if (dataObj.id == null || dataObj.id == undefined || dataObj.id == "") {
					this.itemList.splice(index, 1);
					this.reIndexItemList();
					const evt = new ShowToastEvent({
						title: "Removed Successfully",
						message: "Success",
						variant: "success",
					});
					this.dispatchEvent(evt);
				} else {
					this.inputData = {};
					this.inputData.recordId = dataObj.id;
					let params = {
						input: this.inputData,
						sClassName: "MODPR_EstablishmentInformationController",
						sMethodName: "deleteBusinessRecords",
						options: "{}",
					};
					this._actionUtil
						.executeAction(params, null, this, null, null)
						.then((response) => {
							if (response.result.deleteBusinessRecords == "success") {
								this.itemList.splice(index, 1);
								this.reIndexItemList();
								const evt = new ShowToastEvent({
									title: "Removed Successfully",
									message: "Success",
									variant: "success",
								});
								this.dispatchEvent(evt);
							}
						})
						.catch((error) => {
							console.log("error->", error);
							this.showSpinner = false;
						});
				}
			} else {
				this.showSpinner = false;
			}
		}
	}

	reIndexItemList() {
		let count = 0;
		for (var item of this.itemList) {
			item.serialNumber = count;
			item.memberCount = count + 1;
			item.label = "Establishment - " + item.memberCount;
			count++;
		}
		this.showSpinner = false;
	}

	lookupRecord(event) {
		try {
			let selectedRowSerial = event.detail.parentId;
			let foundElement = this.itemList.find(function (element) {
				return element.serialNumber == selectedRowSerial;
			});
			if (event.detail.isChild === false) {
				if (foundElement) {
					foundElement.establishmentLicNo = event.detail.selectedRecord?.Name;
					foundElement.establishmentLicId = event.detail.selectedRecord?.Id;
					foundElement.establishmentName = event.detail.selectedRecord?.Business_Name__c;
					foundElement.billingStreet = event.detail.selectedRecord?.BillingStreet;
					foundElement.billingCity = event.detail.selectedRecord?.BillingCity;
					foundElement.billingState = event.detail.selectedRecord?.BillingState;
					foundElement.billingPostalCode = event.detail.selectedRecord?.BillingPostalCode;
					foundElement.phone = event.detail.selectedRecord?.Phone;
					foundElement.relatedFrom = event.detail.selectedRecord?.orgId;
					foundElement.inchargeName = event.detail.selectedRecord?.inchargeName;
					foundElement.inchargeLicNumber = event.detail.selectedRecord?.inchargeLicNumber;
				}
			}
		} catch (error) {
			console.log("error", JSON.stringify(error));
		} finally {
			this.showSpinner = false;
		}
	}

	openModal() {	
        // to open modal set isModalOpen tarck value as true	
        this.isSaveAndExit = true;	
    }	
    closeModal() {	
        // to close modal set isModalOpen tarck value as false	
        this.isSaveAndExit = false;	
    }
}