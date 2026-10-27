import { api, track, LightningElement } from 'lwc';
import fetchLookupUserData from '@salesforce/apex/LPI_CustomLookup.fetchLookupUserData';
import fetchDefaultUserRecord from '@salesforce/apex/LPI_CustomLookup.fetchDefaultUserRecord';
import fetchInspectorSpecificToBoard from '@salesforce/apex/LPI_CustomLookup.fetchInspectorSpecificToBoard';
import geAddressRecordsForComplaintParticipants from '@salesforce/apex/LPI_IncidentController.geAddressRecordsForComplaintParticipants';
import fetchInstitutionDetails from '@salesforce/apex/LPI_CustomLookup.fetchInstitutionDetails';
import {
    showAsyncErrorMessage
} from 'c/lpiUtil';
export default class CustomLookUp extends LightningElement {

    @api label = 'Name Of The Approver';
    @api placeholder = 'Search User';
    @api iconName = 'standard:custom';
    @api sObjectApiName = 'User';
    @api searchRequired;
    @api minimumLengthRequired = "0";
    @api showAddOption;
    @api addLabel = "Add";
    @api fromIncident;
    @api publicComplaintId;
    @api fromTask
    @api fromVisit
    @api fromAdhocVisit;
    // Added by Vamsi Mudaliar - starts
    @api fromVisitUser;
    @api inspectionBoard;
    // Added by Vamsi Mudaliar - Ends 
    @api editremove;
    @api fromInstitution;
    // private properties 
    lstResult = []; // to store list of returned records   
    userRecList = [];
    hasRecords = true;
    searchKey = ''; // to store input field value    
    mainSearchKey = '';
    isSearchLoading = false; // to control loading spinner  
    showSpinner = false;
    delayTimeout;
    @track selectedRecord = {}; // to store selected lookup record in object formate 
    get showAddNewOption() {
        return this.showAddOption;
    }
    _defaultRecordId;
    @api
    clearCachedResults() {
        this.userRecList = [];
        this.lstResult = [];
        this.hasRecords = true;
    }
    @api
    set defaultRecordId(value) {
        this._defaultRecordId = value;
        if (!this.selectedRecord.Name && this._defaultRecordId != '' && this._defaultRecordId != undefined) {
            this.showSpinner = true;
            fetchDefaultUserRecord({
                    recordId: this._defaultRecordId,
                    'sObjectApiName': this.sObjectApiName
                })
                .then((result) => {
                    if (result != null) {
                        this.selectedRecord = result;
                        this.searchKey = 'test';
                        this.handelSelectRecordHelper(); // helper function to show/hide lookup result container on UI
                    }
                })
                .catch((error) => {
                    this.error = error;
                    this.selectedRecord = {};
                })
                .finally(() => {
                    this.showSpinner = false;
                });
        }
    }
    get defaultRecordId() {
        return this._defaultRecordId;
    }
    connectedCallback() {
        if (this.minimumLengthRequired == "0") {
            this.searchResult();
        }
    }
    searchResult() {
        this.showSpinner = true;
        if (this.fromIncident) {
            let jsonData = {
                publicComplaintId: this.publicComplaintId,
                searchKey: this.mainSearchKey
            }
            console.log('jsonData : ',JSON.stringify(jsonData));
            geAddressRecordsForComplaintParticipants({
                    jsonData: JSON.stringify(jsonData)
                })
                .then((result) => {
                    console.log('result : ',result);
                    if (result != null) {
                        this.hasRecords = result.length == 0 ? false : true;
                        this.lstResult = JSON.parse(JSON.stringify(result));
                        this.toggleResult('searchInputField');
                    }
                })
                .catch((error) => {
                    this.error = error;
                    showAsyncErrorMessage(this,error);
                    console.log('error: : ',JSON.stringify(error));
                })
                .finally(() => {
                    this.showSpinner = false;
                });
        } else if(this.fromInstitution){
            //get details from
            fetchInstitutionDetails({
                searchKey: this.mainSearchKey,
                searchById: false
            }).then((result) => {
                if (result != null) {
                    this.hasRecords = result.length == 0 ? false : true;
                    this.lstResult = JSON.parse(JSON.stringify(result));
                    this.toggleResult('searchInputField');
                }
            })
            .catch((error) => {
                this.error = error;
                showAsyncErrorMessage(this,error);

            })
            .finally(() => {
                this.showSpinner = false;
            });
        }
        else if(this.fromVisitUser) {
            // Call a Apex Method 
            if(!this.userRecList || this.userRecList.length === 0) {
                fetchInspectorSpecificToBoard({
                    searchKey : this.mainSearchKey,
                    boardName : this.inspectionBoard
                })            
                .then(result => {
                    if(result!=null) {
                        this.hasRecords = (result.length !== 0);
                        this.showSpinner = false;
                        this.userRecList = JSON.parse(JSON.stringify(result));
                        this.lstResult = [...this.userRecList.filter(rec=>{
                            return rec.Name && rec.Name.toLowerCase().includes(this.mainSearchKey?.toLowerCase());
                        })]
                        this.toggleResult('searchInputField');
                    }
                })
                .catch(err=>{
                    showAsyncErrorMessage(this,err);
                    this.showSpinner = false;
                })
            } else {
                const records = this.userRecList.filter(rec=> {
                    return rec.Name && rec.Name.toLowerCase().includes(this.mainSearchKey?.toLowerCase());
                })
                this.lstResult = [...records];
                this.toggleResult('searchInputField');

                this.showSpinner = false;
            }   
        }
        else {
            fetchLookupUserData({
                    searchKey: this.mainSearchKey,
                    sObjectApiName: this.sObjectApiName
                })
                .then((result) => {
                    if (result != null) {
                        this.hasRecords = result.length == 0 ? false : true;
                        this.lstResult = JSON.parse(JSON.stringify(result));
                        this.toggleResult('searchInputField');
                    }
                })
                .catch((error) => {
                    this.error = error;
                })
                .finally(() => {
                    this.showSpinner = false;
                });
        }
    }

    // update searchKey property on input field change  
    handleKeyChange(event) {
        // Debouncing this method: Do not update the reactive property as long as this function is
        // being called within a delay of DELAY. This is to avoid a very large number of Apex method calls.
        const searchKeyVar = event.target.value;
        this.searchKey = searchKeyVar;
        var l = parseInt(this.minimumLengthRequired);
        let searchInput = this.refs.searchRef;
        if(searchInput){
            searchInput.setCustomValidity('');
            searchInput.reportValidity();
        }
        if (this.minimumLengthRequired == "0" || searchKeyVar.length >= l) {
            this.isSearchLoading = true;
            window.clearTimeout(this.delayTimeout);
            this.mainSearchKey = searchKeyVar;
            this.searchResult();
        } else {
            if (this.mainSearchKey != '') {
                this.mainSearchKey = '';
                this.isSearchLoading = false;
                this.lstResult = [];
            }

        }

    }

    mouseLeftEvent(event){
        this.toggleResult(event.target.getAttribute('data-source'));
    }

    // method to toggle lookup result section on UI 
    toggleResult(targetName) {
        const lookupInputContainer = this.template.querySelector('.lookupInputContainer');
        const clsList = lookupInputContainer.classList;
        switch (targetName) {
            case 'searchInputField':
                clsList.add('slds-is-open');
                break;
            case 'lookupContainer':
                clsList.remove('slds-is-open');
                break;
        }
    }
    // method to clear selected lookup record  
    handleRemove() {
        this.searchKey = '';
        this.mainSearchKey = '';
        this.selectedRecord = {};
        this.isSearchLoading = false;
        this.lookupUpdatehandler(null); // update value on parent component as well from helper function 

        // remove selected pill and display input field again 
        const searchBoxWrapper = this.template.querySelector('.searchBoxWrapper');
        searchBoxWrapper.classList.remove('slds-hide');
        searchBoxWrapper.classList.add('slds-show');
        const pillDiv = this.template.querySelector('.pillDiv');
        pillDiv.classList.remove('slds-show');
        pillDiv.classList.add('slds-hide');
        const oEvent = new CustomEvent('lookupremove', {});
        this.dispatchEvent(oEvent);
    }
    // method to update selected record from search result 
    handelSelectedRecord(event) {
        var objId = event.target.getAttribute('data-recid'); // get selected record Id 
        this.selectedRecord = this.lstResult.find(data => data.Id === objId); // find selected record from list 
        this.lookupUpdatehandler(this.selectedRecord); // update value on parent component as well from helper function 
        this.handelSelectRecordHelper(); // helper function to show/hide lookup result container on UI
    }

    @api
    handleSelectedRecordFromParent(objId){
        this.showSpinner = true;
        //this.fetchInstitutionDetails(objId,true);

        fetchInstitutionDetails({
            searchKey: objId,
            searchById: true
        }).then((result) => {
            if (result != null) {
                this.hasRecords = result.length == 0 ? false : true;
                this.lstResult = JSON.parse(JSON.stringify(result));
                this.selectedRecord = this.lstResult.find(data => data.Id === objId); // find selected record from list 
                this.lookupUpdatehandler(this.selectedRecord);
                this.handelSelectRecordHelper();
            }
        })
        .catch((error) => {
            this.error = error;
            showAsyncErrorMessage(this,error);
        })
        .finally(() => {
            this.showSpinner = false;
        });
    }
    
    /*COMMON HELPER METHOD STARTED*/
    handelSelectRecordHelper() {
        let searchInput = this.refs.searchRef;
        if(searchInput){
            searchInput.setCustomValidity('');
            searchInput.reportValidity();
        }
        this.template.querySelector('.lookupInputContainer').classList.remove('slds-is-open');
        const searchBoxWrapper = this.template.querySelector('.searchBoxWrapper');
        searchBoxWrapper.classList.remove('slds-show');
        searchBoxWrapper.classList.add('slds-hide');
        const pillDiv = this.template.querySelector('.pillDiv');
        pillDiv.classList.remove('slds-hide');
        pillDiv.classList.add('slds-show');
        if ((this.fromIncident || this.fromTask || this.fromVisit || this.fromAdhocVisit || this.fromInstitution) && this.selectedRecord) {
            const oEvent = new CustomEvent('lookupupdate', {
                'detail': {
                    selectedRecord: this.selectedRecord
                }
            });
            this.dispatchEvent(oEvent);
        }
    }
    // send selected lookup record to parent component using custom event
    lookupUpdatehandler(value) {
        const oEvent = new CustomEvent('lookupupdate', {
            'detail': {
                selectedRecord: value
            }
        });
        if (!this.searchKey && value) {
            this.searchKey = value.Name;
        }
        this.dispatchEvent(oEvent);
    }
    lookupAddRecordSelection(event) {
        const oEvent = new CustomEvent('lookupaddrecord', {
            'detail': {
                selectedRecord: event.target.dataset.id
            }
        });
        this.dispatchEvent(oEvent);
        this.handelSelectRecordHelper();
    }
    @api
    checkValidation() {
        let valid = false;
        valid = [...this.template.querySelectorAll('lightning-input')].reduce(
            (validSoFar, input) => {

                if (!input.checkValidity()) {
                    input.classList.add('slds-has-error');
                } else {
                    input.classList.remove('slds-has-error');
                }
                input.reportValidity();
                return validSoFar && input.checkValidity();
            },
            true
        );
        let searchInput = this.refs.searchRef;
        if (searchInput && (!this.selectedRecord || !this.selectedRecord.Name)) {
            searchInput.setCustomValidity('Complete this field.');
            searchInput.reportValidity();
        }
        valid = this.searchRequired ? valid && this.selectedRecord && this.selectedRecord.Name : true;
        return valid;
    }

    //Added as the name is not reflecting after updating the Id in parent.
    @api
    updateLookupName(lookupName, lookupId) {
        this.selectedRecord.Name = lookupName;
        this.selectedRecord.Id = lookupId;
        this.lookupUpdatehandler(this.selectedRecord);
        this.template.querySelector('.lookupInputContainer').classList.remove('slds-is-open');
        const searchBoxWrapper = this.template.querySelector('.searchBoxWrapper');
        searchBoxWrapper.classList.remove('slds-show');
        searchBoxWrapper.classList.add('slds-hide');
        const pillDiv = this.template.querySelector('.pillDiv');
        pillDiv.classList.remove('slds-hide');
        pillDiv.classList.add('slds-show');
    }
    //Used to remove lookup when required from parent
    @api
    removeLookup() {
        this.searchKey = '';
        this.mainSearchKey = '';
        this.selectedRecord = {};;
        this.lookupUpdatehandler(null);
        const searchBoxWrapper = this.template.querySelector('.searchBoxWrapper');
        searchBoxWrapper.classList.remove('slds-hide');
        searchBoxWrapper.classList.add('slds-show');
        const pillDiv = this.template.querySelector('.pillDiv');
        pillDiv.classList.remove('slds-show');
        pillDiv.classList.add('slds-hide');
        const oEvent = new CustomEvent('lookupremove', {});
        this.dispatchEvent(oEvent);
    }
}