import { LightningElement, api, track, wire } from "lwc";
import { OmniscriptBaseMixin } from "omnistudio/omniscriptBaseMixin";
import { OmniscriptActionCommonUtil } from "omnistudio/omniscriptActionUtils";

const DELAY = 300; // dealy apex callout timing in miliseconds

export default class LpiCustomLookupEstablishment extends OmniscriptBaseMixin(LightningElement) {
	// public properties with initial default values
	@track showSpinner = false;
	@api label="Establishment License Number";
	@api missingLabel = "Error: Establishment License Number is required.";
	@api placeholder="Search License here...";
	@api isSupervisorSearch= false;
	@api regAuthTypeName = '';
	@api
	get value() {
		return this.searchKey;
	}
	set value(value) {
		try {
			this.searchKey = value;
			if (value) {
				setTimeout(() => {
                    this.showSpinner = true;
					this.inputData["searchKey"] = value;
					this.inputData["isChild"] = this.isChild;
					this.inputData["isSupervisorSearch"] = this.isSupervisorSearch;
					this.inputData["regAuthTypeName"] = this.regAuthTypeName;
					let params = {
						input: this.inputData,
						sClassName: "MODPR_EstablishmentInformationController",
						sMethodName: "getEstablishmentInformation",
						options: "{}"
					};
					this._actionUtil
						.executeAction(params, null, this, null, null)
						.then((response) => {
							this.isSearchLoading = false;
							this.hasRecords = response.result.licData === 0 ? false : true;
							this.lstResult = JSON.parse(JSON.stringify(response.result.licData));
							if (this.hasRecords) {
								this.selectedRecord = this.lstResult[0];
								this.lookupUpdatehandler(this.selectedRecord); // update value on parent component as well from helper function
								this.handelSelectRecordHelper();
							}
                            this.showSpinner = false;
						})
						.catch((error) => {
							console.log("error->", error);
                            this.showSpinner = false;
						});
				}, 1000);
			}
		} catch (error) {
			console.log("error", JSON.stringify(error));
            this.showSpinner = false;
		} finally {
			this.showSpinner = false;
		}
	}
	@api datId = "";
	@api isEstablishment = false;
	@api isChild = false;
	@api parentId = "";
	@api childId = "";
	// private properties
	lstResult = []; // to store list of returned records
	hasRecords = true;
	searchKey = ""; // to store input field value
	isSearchLoading = false; // to control loading spinner
	delayTimeout;
	selectedRecord = {}; // to store selected lookup record in object formate

	_actionUtil;
	inputData = {};
	@track currentIndex = 0;
    liIndex;
    @track searchAriaLabel='Establishment License Number';
	get tabIndex(){
		return '-1';
	}
	// initial function to populate default selected lookup record if defaultRecordId provided
	connectedCallback() {
		this._actionUtil = new OmniscriptActionCommonUtil();
	}

	// update searchKey property on input field change
	handleKeyChange(event) {
		try {
			this.isSearchLoading = true;
			this.searchKey = event.target.value;
			this.inputData["searchKey"] = event.target.value;
			this.inputData["isChild"] = this.isChild;
			this.inputData["isSupervisorSearch"] = this.isSupervisorSearch;
			this.inputData["regAuthTypeName"] = this.regAuthTypeName;
			let params = {};
			params = {
				input: this.inputData,
				sClassName: "MODPR_EstablishmentInformationController",
				sMethodName: "getEstablishmentInformation",
				options: "{}"
			};
			this._actionUtil
				.executeAction(params, null, this, null, null)
				.then((response) => {
					this.isSearchLoading = false;
					this.hasRecords = response.result.licData === 0 ? false : true;
					this.lstResult = JSON.parse(JSON.stringify(response.result.licData));
				})
				.catch((error) => {
					console.log("error->", error);
				});
		} catch (error) {
			console.log("error", JSON.stringify(error));
		} finally {
			this.showSpinner = false;
		}
	}

	// method to toggle lookup result section on UI
	toggleResult(event) {
		const lookupInputContainer = this.template.querySelector(".lookupInputContainer");
		const clsList = lookupInputContainer.classList;
		const whichEvent = event.target.getAttribute("data-source");
		switch (whichEvent) {
			case "searchInputField":
				clsList.add("slds-is-open");
				break;
			case "lookupContainer":
				clsList.remove("slds-is-open");
				break;
		}
	}

	// method to update selected record from search result
	handelSelectedRecord(event) {
		var objId = event.target.getAttribute("data-recid"); // get selected record Id
		this.selectedRecord = this.lstResult.find((data) => data.Id === objId); // find selected record from list
		this.selectedRecord.uniqueId = this.datId;
		this.lookupUpdatehandler(this.selectedRecord); // update value on parent component as well from helper function
		this.handelSelectRecordHelper(); // helper function to show/hide lookup result container on UI
	}

	/*COMMON HELPER METHOD STARTED*/

	handelSelectRecordHelper() {
		this.template.querySelector(".lookupInputContainer").classList.remove("slds-is-open");

		const searchBoxWrapper = this.template.querySelector(".searchBoxWrapper");
		searchBoxWrapper.classList.remove("slds-show");
		searchBoxWrapper.classList.add("slds-hide");

		const pillDiv = this.template.querySelector(".pillDiv");
		pillDiv.classList.remove("slds-hide");
		pillDiv.classList.add("slds-show");
	}

	// send selected lookup record to parent component using custom event
	lookupUpdatehandler(value) {
		const oEvent = new CustomEvent("lookupupdate", {
			detail: {
				selectedRecord: value,
				isChild: this.isChild,
				parentId: this.parentId,
				childId: this.childId
			}
		});
		this.dispatchEvent(oEvent);
	}

	@api
	inputValid(){
		let valid = [...this.template.querySelectorAll(".combobox_input")].reduce(
			(validSoFar, input) => {
				input.reportValidity();
				return validSoFar && input.checkValidity();
			}, true);

		let allInput = this.template.querySelector(".slds-has-error");
		if (allInput) {
			allInput.scrollIntoView();
			allInput.focus();
		}
		return valid;
	}

    handleKeyDownFocus(event) {
        
        let keyCode = event.keyCode;
        const curr = event.target;

        if( curr.tagName === 'LI' ) {

            if( keyCode === 40 ) {
                const next = curr.nextSibling;

                if( next && next.tagName == 'LI' ) {
                    next.focus();
                    // this.displayOptions[next.dataset.index].ariaSelected = true;
                    event.preventDefault();
                }
                

            } else if( keyCode === 38 ) {
                const prev = curr.previousSibling;
                if( prev && prev.tagName === 'LI' ) {
                    prev.focus();
                    // this.displayOptions[prev.dataset.index].ariaSelected = true;
                } else {
                    this.template.querySelector('.combobox_input').focus();
                }
                event.preventDefault();
            }
        }
    }

    handleKeyPressOnLI(event) {
        let keyCode = event.keyCode;

        if( keyCode === 13 ) {
            this.template.querySelectorAll('').forEach((elem,index) => {
                if(index ===  parseInt(event.target.dataset.index)){
                    elem.handlePredictionSelect();
                }else{
                    event.preventDefault();
                }
                
            });
            
        } 
    }

    changeAriaLabel(e){
        this.noRecordsMsg = false;
        if(e.keyCode == 40){
            var listItems = this.template.querySelectorAll('.li-ariafocus');
            
            if(this.lstResult.length>this.currentIndex){
                this.currentIndex ++;
                if(this.liIndex != undefined){
                    this.liIndex = 0;
                }else{
                    this.liIndex++;
                }
                
            } else{
                listItems[this.lstResult.length-1].classList.remove("slds-has-focus");
                
                this.currentIndex = 1;
                if(this.liIndex != undefined){
                    this.liIndex = 0;
                }else{
                    this.liIndex++;
                }
            }
            this.searchAriaLabel = this.lstResult[this.currentIndex-1].Name + ' You are currently on an option, please press ENTER to select this option.';
            listItems[this.currentIndex-1].classList.add("slds-has-focus");
            
            if(listItems[this.currentIndex-2]){
                listItems[this.currentIndex-2].classList.remove("slds-has-focus");
            }
            
        }
        else if(e.keyCode == 38){
            var listItems = this.template.querySelectorAll('.li-ariafocus');
            
            if(this.currentIndex != 1 && this.currentIndex != 0 ){
                this.currentIndex --;
                if(this.liIndex != undefined){
                    this.liIndex = this.lstResult.length;
                }else{
                    this.liIndex--;
                }
            } else{
                listItems[0].classList.remove("slds-has-focus");
                this.currentIndex = this.lstResult.length;
                if(this.liIndex != undefined){
                    this.liIndex = this.lstResult.length;
                }else{
                    this.liIndex--;
                }
            }
            this.searchAriaLabel = this.lstResult[this.currentIndex-1].Name + ' You are currently on an option, please press ENTER to select this option.';
            listItems[this.currentIndex-1].classList.add("slds-has-focus");
            if(listItems[this.currentIndex]){
                listItems[this.currentIndex].classList.remove("slds-has-focus");
            }
        } 
        else if(e.keyCode == 13){
            
            this.searchAriaLabel = 'Selected value '+this.lstResult[this.currentIndex-1].Name;
            var listItems = this.template.querySelectorAll('.li-ariafocus');
            var objId =  this.lstResult[this.currentIndex-1].Id;//listItems[0].Id;// get selected record Id 
            this.selectedRecord = this.lstResult[this.currentIndex-1];//this.lstResult.find(data => data.Id === objId); // find selected record from list 
            this.selectedRecord.uniqueId = this.datId;
            this.lookupUpdatehandler(this.selectedRecord);
            this.handelSelectRecordHelper();
        }
		else if(e.keyCode == 9){
			this.searchAriaLabel = 'Establishment License Number';
		}
        else{
            setTimeout(() => {
                this.currentIndex = 0;
                this.liIndex = undefined;
                if(this.lstResult && this.lstResult.length > 0 ){
                    this.searchAriaLabel =this.lstResult.length + ' results found';
                } else{
                    this.searchAriaLabel ='No results found';
                }
            }, 1000);
        }
    }

    preventFocusLosing(event) {
        // Stops the Typeahead input element from losing focus so that a user can use the scroll bar in the list
        event.preventDefault();
    }
}