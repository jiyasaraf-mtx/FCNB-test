import { LightningElement, track, wire, api } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { OmniscriptBaseMixin } from "omnistudio/omniscriptBaseMixin";
import { OmniscriptActionCommonUtil } from "omnistudio/omniscriptActionUtils";
import { getNamespaceDotNotation } from "omnistudio/omniscriptInternalUtils";

export default class LpiAddMulitpleLocation extends OmniscriptBaseMixin(LightningElement) {
	@api parid;
	@api blid;
	@api regauthtypename;
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
			embalmerDetailList: [],
			establishmentLicNo: "",
			relationshipAssociatedWithYou: true
		}
	];
	@track booleanTrue = true;
	@track booleanFalse = false;
	hasRecords = false;
	@track displayEmbalmerSection = false;
	_actionUtil;
	inputData = {};
	currentLoggedInContact;
	get isEmbalmerPracticum(){
		return this.regauthtypename == 'Embalmer Practicum' ? true : false;
	}
	connectedCallback() {
		this.getCurrentUser();
		this.getAllData();
	}
	getCurrentUser(){
		this._actionUtil = new OmniscriptActionCommonUtil();
		this.inputData = {};
		this.inputData.parid = this.parid;
		let params = {
			input: this.inputData,
			sClassName: "MODPR_EstablishmentInformationController",
			sMethodName: "fetchApplyingContact",
			options: "{}"
		};
		this._actionUtil
			.executeAction(params, null, this, null, null)
			.then((response) => {
				if(response.result.fetchApplyingContact != null){
					this.currentLoggedInContact = response.result.fetchApplyingContact;
				}
			})
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
			sMethodName: "getRecords",
			options: "{}"
		};
		this._actionUtil
			.executeAction(params, null, this, null, null)
			.then((response) => {
				this.hasRecords = response.result?.getRecords?.length > 0;
				if (this.hasRecords) {
					this.itemList = JSON.parse(JSON.stringify(response.result.getRecords));
					for (var temp of this.itemList) {
						temp.childElementIdList = [];
						if (temp.embalmerDetailList) {
							temp.embalmerDetailList = this.reIndexChild(temp.embalmerDetailList);
							for (var childTemp of temp.embalmerDetailList) {
								if (childTemp.id != "" && childTemp.id != undefined && childTemp != null) {
									temp.childElementIdList.push(childTemp.id);
								}
							}
						}
					}
				}
			})
			.catch((error) => {
				console.log("error->", error);
				const evt = new ShowToastEvent({
					title: "Error",
					message: error,
					variant: "Error"
				});
				this.dispatchEvent(evt);
				this.showSpinner = false;
			});
		let params1 = {
			input: this.inputData,
			sClassName: "MODPR_EstablishmentInformationController",
			sMethodName: "displayEmbalmerSection",
			options: "{}"
		};
		this._actionUtil
			.executeAction(params1, null, this, null, null)
			.then((response) => {
				this.displayEmbalmerSection = response.result?.displayEmbalmerSection;
				this.showSpinner = false;
			})
			.catch((error) => {
				console.log("error->", error);
				const evt = new ShowToastEvent({
					title: "Error",
					message: error,
					variant: "Error"
				});
				this.dispatchEvent(evt);
                setTimeout(() => {
                    this.showSpinner = false;
                }, 2000);
			});
	}

	isInputValid() {
		let isAllValid = true;
		let isLicenseValid = true;
		let licenseIds = [];
		for (var temp of this.itemList) {
			if (!licenseIds.includes(temp.establishmentLicNo)) {
				licenseIds.push(temp.establishmentLicNo);
				if (temp.establishmentLicNo == null || temp.establishmentLicNo == "") {
					isAllValid = false;
					this.openAccordians(temp.label,'');
					break;
				}
				let childElementIdList = [];
				if (temp.embalmerDetailList) {
					for (var childTemp of temp.embalmerDetailList) {
						if(childTemp.contactId != this.currentLoggedInContact){
							if (!childElementIdList.includes(childTemp.embalmerLicNo)) {
								childElementIdList.push(childTemp.embalmerLicNo);
								if (childTemp.embalmerLicNo == null || childTemp.embalmerLicNo == "") {
									isAllValid = false;
									this.openAccordians(temp.label, childTemp.label);
									break;
								 }
							}else{
								isLicenseValid = false;
								const evt = new ShowToastEvent({
									title: "Error",
									message: "Please select different Supervisor License Numbers for same Establishment.",
									variant: "Error"
								});
								this.dispatchEvent(evt);
								break;
							}
						}else{
							isLicenseValid = false;
							const evt = new ShowToastEvent({
								title: "Error",
								message: "Please do not select your own embalmer.",
								variant: "Error"
							});
							this.dispatchEvent(evt);
							break;
						}
					}
				}
			} else {
				isLicenseValid = false;
				const evt = new ShowToastEvent({
					title: "Error",
					message: "Please select different Establishment License Number.",
					variant: "Error"
				});
				this.dispatchEvent(evt);
				break;
			}
		}
		// if (!isAllValid) {
		// 	const evt = new ShowToastEvent({
		// 		title: "Error",
		// 		message: "Please fill all information.",
		// 		variant: "Error"
		// 	});
		// 	this.dispatchEvent(evt);
		// }
		return isAllValid && isLicenseValid;
	}

	async openAccordians(parentLabel, ChildLabel){
		const activeOuterSections = this.template.querySelectorAll('.outerAccordion');
		const activeInnerSections = this.template.querySelectorAll('.innerAccordion');
		console.log('str. charAt(str. length - 1) : ',parentLabel.charAt(parentLabel.length - 1));
		console.log('str. charAt(str. length - 1) : ',ChildLabel.charAt(ChildLabel.length - 1));
		if(ChildLabel.length === 0){
			activeOuterSections[parentLabel.charAt(parentLabel.length - 1)-1].activeSectionName = [parentLabel];
		}else{
			activeOuterSections[parentLabel.charAt(parentLabel.length - 1)-1].activeSectionName = [parentLabel];
			activeInnerSections[ChildLabel.charAt(ChildLabel.length - 1)-1].activeSectionName = [ChildLabel];
		}
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

	handleSave() {
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
			this.inputData.parid = this.parid;
			this.inputData.blid = this.blid;
			this.inputData.json = JSON.stringify(this.itemList);
			let params = {
				input: this.inputData,
				sClassName: "MODPR_EstablishmentInformationController",
				sMethodName: "saveRecord",
				options: "{}"
			};
			this._actionUtil
				.executeAction(params, null, this, null, null)
				.then((response) => {
					if(response.result.saveRecord == 'success'){
						this.omniNextStep();
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
						variant: "error"
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
				embalmerDetailList: []
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

	async addChildSection(event) {
		let selectedRowSerial = event.target.dataset.parentid;
		let foundElement = this.itemList.find(function (element) {
			return element.serialNumber == selectedRowSerial;
		});
		if (foundElement) {
			let nextIndex = foundElement.embalmerDetailList.length;
			var newItem = {
				embalmerLicNo: "",
				isChild: true,
				id: "",
				embalmerLicId: ""
			};
			newItem.memberCount = nextIndex + 1;
			newItem.serialNumber = nextIndex;
			newItem.label = "Supervisor - " + newItem.memberCount;
			newItem.hideDelete = false;
			foundElement.embalmerDetailList.push(newItem);

			//To show focus on first element which is custom lookup cmp when Embalmer added
			await Promise.resolve();
			this.openAccordians(foundElement.label, newItem.label);
			const objChild = this.template.querySelectorAll('c-lpi-custom-lookup-establishment');
			for(var temp of objChild) {
				if(temp.childId.length != 0 &&  temp.parentId == foundElement.serialNumber && temp.childId == nextIndex){
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
						variant: "success"
					});
					this.dispatchEvent(evt);
				} else {
					this.inputData = {};
					this.inputData.recordId = dataObj.id;
					this.inputData.estLicNumber = dataObj.establishmentLicNo;
					this.inputData.childElementIdList = dataObj.childElementIdList;
					let params = {
						input: this.inputData,
						sClassName: "MODPR_EstablishmentInformationController",
						sMethodName: "deleteRecords",
						options: "{}"
					};
					this._actionUtil
						.executeAction(params, null, this, null, null)
						.then((response) => {
							if (response.result.deleteRecords == "success") {
								this.itemList.splice(index, 1);
								this.reIndexItemList();
								const evt = new ShowToastEvent({
									title: "Removed Successfully",
									message: "Success",
									variant: "success"
								});
								this.dispatchEvent(evt);
							}
						})
						.catch((error) => {
							console.log("error->", error);
							const evt = new ShowToastEvent({
								title: "Error",
								message: error,
								variant: "error"
							});
							this.dispatchEvent(evt);
                            this.showSpinner = false;
						});
				}
			}else{
                this.showSpinner = false;
            }
		}
		
	}
	deleteChildData(event) {
		var selectedRowSerial = event.target.dataset.parentid;
		var selectedChildRowSerial = event.target.dataset.id;
		let foundElement = this.itemList.find(function (element) {
			return element.serialNumber == selectedRowSerial;
		});
		if (foundElement) {
            this.showSpinner = true;
			var index = foundElement.embalmerDetailList.findIndex(function (o) {
				return o.serialNumber == selectedChildRowSerial;
			});
			if (index != -1) {
				let dataObj = foundElement.embalmerDetailList[index];
				if (dataObj.id == null || dataObj.id == undefined || dataObj.id == "") {
					foundElement.embalmerDetailList.splice(index, 1);
					foundElement.embalmerDetailList = this.reIndexChild(foundElement.embalmerDetailList);
					const evt = new ShowToastEvent({
						title: "Removed Successfully",
						message: "Success",
						variant: "success"
					});
					this.dispatchEvent(evt);
				} else {
					this.inputData = {};
					this.inputData.recordId = dataObj.id;
					this.inputData.estLicNumber = foundElement.establishmentLicNo;
					let params = {
						input: this.inputData,
						sClassName: "MODPR_EstablishmentInformationController",
						sMethodName: "deleteRecords",
						options: "{}"
					};
					this._actionUtil
						.executeAction(params, null, this, null, null)
						.then((response) => {
							if (response.result.deleteRecords == "success") {
								foundElement.embalmerDetailList.splice(index, 1);
								foundElement.embalmerDetailList = this.reIndexChild(foundElement.embalmerDetailList);
								const evt = new ShowToastEvent({
									title: "Removed Successfully",
									message: "Success",
									variant: "success"
								});
								this.dispatchEvent(evt);
							}
						})
						.catch((error) => {
							console.log("error->", error);
                            this.showSpinner = false;
						});
				}
			}else{
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
	reIndexChild(list) {
		let count = 0;
		for (var item of list) {
			item.serialNumber = count;
			item.memberCount = count + 1;
			item.label = "Supervisor - " + item.memberCount;
			count++;
		}
		this.showSpinner = false;
		return list;
	}

	lookupRecord(event) {
		try {
			let selectedRowSerial = event.detail.parentId;
			let selectedChildRowSerial = event.detail.childId;
			let foundElement = this.itemList.find(function (element) {
				return element.serialNumber == selectedRowSerial;
			});
			let foundElementChild = foundElement.embalmerDetailList.find(function (element) {
				return element.serialNumber == selectedChildRowSerial;
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
					foundElement.orgId = event.detail.selectedRecord?.orgId;
					foundElement.inchargeName = event.detail.selectedRecord?.inchargeName;
					foundElement.inchargeLicNumber = event.detail.selectedRecord?.inchargeLicNumber;
				}
			} else if (event.detail.isChild === true) {
				if (foundElementChild) {
					foundElementChild.embalmerLicNo = event.detail.selectedRecord?.Name;
					foundElementChild.embalmerLicId = event.detail.selectedRecord?.Id;
					foundElementChild.embalmerName = event.detail.selectedRecord?.Business_Name__c;
					foundElementChild.contactId = event.detail.selectedRecord?.contactId;
				}
			}
		} catch (error) {
			console.log("error", JSON.stringify(error));
		} finally {
			this.showSpinner = false;
		}
	}
}