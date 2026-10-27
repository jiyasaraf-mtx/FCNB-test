import {
    LightningElement,
    track,
    wire,
    api
} from 'lwc';
import {
    ShowToastEvent
} from 'lightning/platformShowToastEvent';
import {
    CurrentPageReference
} from 'lightning/navigation';
import {
    NavigationMixin
} from 'lightning/navigation';
import {
    getPicklistValues,
    getObjectInfo
} from 'lightning/uiObjectInfoApi';
import ADDRESS_OBJECT from '@salesforce/schema/Address';
import LOCATION_OBJECT from '@salesforce/schema/Location';
import AddressState from '@salesforce/schema/Address.StateCode';
import AddressCountry from '@salesforce/schema/Address.CountryCode';
import LocationType from '@salesforce/schema/Location.LocationType';
import Status__c from '@salesforce/schema/Location.Status__c';
import getMOCountyValues from '@salesforce/apex/LPI_ApplicationViewController.getMOCountyValues';
import saveBranchAddressDetails from '@salesforce/apex/LPI_ApplicationViewController.saveBranchAddressDetails';
import fetchAuthAppDetails from '@salesforce/apex/LPI_ApplicationViewController.fetchAuthAppDetails';
import editLocation from '@salesforce/apex/LPI_ApplicationViewController.editLocation';
import getAccountId from '@salesforce/apex/LPI_ApplicationViewController.getAccountId';
import isBLAuthorisationTypeBusiness from '@salesforce/apex/LPI_ApplicationViewController.isBLAuthorisationTypeBusiness'; //Added for I-273171

export default class LpiAddNewAddress extends NavigationMixin(LightningElement) {
    @wire(CurrentPageReference)
    currentPageReference;
    showAddAddressModal = false;
    @track addressDataObj = {
        country: 'US',
        state: 'MO',
        'isAddressUpdateOnAccount':false
    };
    @track today;
    @track stateOptions = [];
    @track countryOptions = [];
    @track locationTypeOptions = [];
    @track statusOptions = [];
    @track picklistOrdered;
    @track searchResults;
    @track selectedSearchResult = {};
    @track selectedCountyValue;
    @track showAuthAppPlaceModal = true;
    @track showSpinner = false;
    @track showConfirmationBox = false;
    @track showAddressModal = true;
    @track message = '';
    @api recordId;
    @api authAppId;
    @track closeDateAddressTypeList = ['Residence', 'Mailing', 'Business Address'];
    @api accId;
    @track isRecordReadOnly = false;
    @track readyOnlyOnCloseStatus = false;
    @track showDateAndStatusOnEdit = false;
    @track showBusinessName = false;
    @api isAccount = false;
    @api modalHeading;
    @track addressTypeLabel = 'Select the type of address.';
    patternObj = {
        text: "^((?!(<)|(>)).)*$",
        zipCode: "^[0-9]{5}(?:-[0-9]{4})?$",
        phone: '^(\\([0-9]{3}\\) |[0-9]{3}-)[0-9]{3}-[0-9]{4}$'
    };
    isBusinessTypeBL = false; //Added for I-273171
    // GET OBJECT INFO
    @wire(getObjectInfo, {
        objectApiName: ADDRESS_OBJECT
    }) objectInfo;
    @wire(getPicklistValues, {
        recordTypeId: '$objectInfo.data.defaultRecordTypeId',
        fieldApiName: AddressCountry
    })
    wiredCountryPicklistValues({
        error,
        data
    }) {
        if (data && data.values) {
            this.countryOptions = data.values;
        }
    }
    @wire(getPicklistValues, {
        recordTypeId: '$objectInfo.data.defaultRecordTypeId',
        fieldApiName: AddressState
    }) wiredStatePicklistValues({
        error,
        data
    }) {
        if (data && data.values) {
            this.stateOptions = data.values;
        }
    }
    @wire(getObjectInfo, {
        objectApiName: LOCATION_OBJECT
    }) objectInfo;
    @wire(getPicklistValues, {
        recordTypeId: '$objectInfo.data.defaultRecordTypeId',
        fieldApiName: LocationType
    })
    wiredLocationPicklistValues({
        error,
        data
    }) {
        if (data && data.values) {
            this.locationTypeOptions = data.values;
        }
    }

    @wire(getPicklistValues, {
        recordTypeId: '$objectInfo.data.defaultRecordTypeId',
        fieldApiName: Status__c
    })
    wiredStatusPicklistValues({
        error,
        data
    }) {
        if (data && data.values) {
            this.statusOptions = data.values;
        }
    }

    get isAddressCountryUS() {
        let temp = this.addressDataObj.country && this.addressDataObj.country === 'US' ? true : false;
        return temp;
    }
    get isStateMO() {
        let temp = this.addressDataObj.state && this.addressDataObj.state === 'MO' ? true : false;
        return temp;
    }

    get selectedValue() {
        return this.selectedSearchResult ? this.selectedSearchResult.label : null;
    }
    //Added for I-273171
    get isFieldRequired() {
        return this.isBusinessTypeBL && !this.isAddressCountryUS ? false : true;
    }

    async connectedCallback() {
        if (this.authAppId) {
            this.showSpinner = true;
            this.isRecordReadOnly = true;
            this.showDateAndStatusOnEdit = true;
            this.addressTypeLabel = 'Address Type';
            this.message = 'This action will modify the details in the address record. Please confirm your changes before saving.';
        }
        await getMOCountyValues().then((result) => {
            this.picklistOrdered = result.map(({
                value: label,
                key: value
            }) => ({
                label,
                value
            }))
            this.picklistOrdered = this.picklistOrdered.sort((a, b) => {
                if (a.label < b.label) {
                    return -1
                }
            })
        })
        if (this.authAppId) {
            await fetchAuthAppDetails({
                recordId: this.authAppId,
                locationType : this.addressDataObj.addressType
            }).then(result => {
                this.addressDataObj = {
                    ...this.addressDataObj,
                    ...result
                };
                this.selectedSearchResult['label'] = this.addressDataOb?.countyLookup;
                if (this.addressDataObj.status == 'Closed') {
                    this.readyOnlyOnCloseStatus = true;
                }
                if (this.addressDataObj.addressType == 'Business Address') {
                    this.showBusinessName = true;
                }
            }).catch(error => {
                this.showMessage('Error', error?.body?.message, 'error');
            })
        }
        if (!this.isAccount) {
            await getAccountId({
                blId: this.recordId
            }).then(result => {
                this.accId = result;
            }).catch(error => {
                this.showMessage('Error', error?.body?.message, 'error');
            })
        }
        //Added for I-273171 -- Start
        await isBLAuthorisationTypeBusiness({
            blId: this.recordId
        }).then(result => {
            this.isBusinessTypeBL = result;
        }).catch(error => {
            this.showMessage('Error', error?.body?.message, 'error');
        })
        //Added for I-273171 -- End
        this.showSpinner = false;
    }

    handleCancel() {
        this.addressDataObj = {};
        const customEvent = new CustomEvent('close');
        this.dispatchEvent(customEvent);
    }
    handleAddressInputChanges(event) {
        this.addressDataObj[event.target.name] = event.target.value;
        if(event.target.name === 'isAddressUpdateOnAccount'){
            this.addressDataObj[event.target.name] = event.target.checked;
        }
        if(event.target.name === 'addressType'){
            if(this.closeDateAddressTypeList.includes(event.target.value)){
                this.fetchOpenAddressDetails(this.recordId, event.target.value);
            }
            else{
                this.addressDataObj = {};
                this.addressDataObj.addressType = event.target.value;
                this.addressDataObj.isAddressUpdateOnAccount = false;
            }
        }
        this.addressDataObj.state =
            this.addressDataObj.state && this.isAddressCountryUS ? this.addressDataObj.state : null;
        if (event.target.name === 'telephoneNum') {
            var numbers = event.target.value.replace(/\D+/g, "");
            let teleValue = "";
            for (var i = 0; i < numbers.length; i++) {
                if (i == 0) {
                    teleValue += '(' + numbers[i];
                } else if (i == 3) {
                    teleValue += ') ' + numbers[i];
                } else if (i == 6) {
                    teleValue += '-' + numbers[i];
                } else {
                    teleValue += '' + numbers[i];
                }
            }
            this.addressDataObj[event.target.name] = teleValue;
        }
        if (event.target.name === 'addressType') {
            if (event.target.value == 'Business Address') {
                this.showBusinessName = true;
            } else {
                this.showBusinessName = false;
            }
        }
    }

    formatDate(isoDate) {
        const options = {
            year: 'numeric',
            month: '2-digit',
            day: '2-digit'
        };
        return new Date(isoDate).toLocaleDateString(undefined, options);
    }

    isInputValid() {
        let isValid = true;
        let inputFields = this.template.querySelectorAll('.validate');
        inputFields.forEach(inputField => {
            if (!inputField.checkValidity()) {
                inputField.reportValidity();
                isValid = false;
            }
        });
        return isValid;
    }

    search(event) {
        const input = event.detail.value.toLowerCase();
        if (input.length >= 1) {
            const result = this.picklistOrdered.filter((picklistOption) =>
                picklistOption.label.toLowerCase().includes(input)
            );
            this.addressDataObj.countyLookup = event.target.value;
            this.searchResults = result;
        } else {
            this.clearSearchResults()
        }
    }
    selectSearchResult(event) {
        const selectedValue = event.currentTarget.dataset.name;
        this.selectedSearchResult = this.picklistOrdered.find(
            (picklistOption) => picklistOption.label === selectedValue
        );
        this.selectedCountyValue = selectedValue;
        this.addressDataObj.countyLookup = this.selectedCountyValue;
        this.clearSearchResults();
    }
    clearSearchResults() {
        this.searchResults = null;
    }

    handleAddressContinueButton() {
        if (this.isInputValid()) {
            this.showSpinner = true;
            if (this.isStateMO && (this.selectedCountyValue == undefined ||
                    this.addressDataObj.countyLookup != this.selectedCountyValue) && !this.isRecordReadOnly) {
                this.showSpinner = false;
                this.showMessage('Error', 'Please select valid County', 'error');
            } else {
                if (!this.authAppId) {
                    let addressList = this.addressDataObj.addressType.split(' ');
                    if (this.closeDateAddressTypeList.includes(this.addressDataObj.addressType)) {
                        if(addressList[addressList.length-1] == 'Address'){
                            this.message = 'Note: If a similar \'' +this.addressDataObj.addressType +'\' already exists in the system, it will be closed with the current date as the closing date. Please confirm.';
                        }else{
                            this.message = 'Note: If a similar \'' +this.addressDataObj.addressType+ ' Address' +'\' already exists in the system, it will be closed with the current date as the closing date. Please confirm.';
                        }
                    } else {
                        if(addressList[addressList.length-1] == 'Address'){
                            this.message = 'This action will create a new address record of the type \''+ this.addressDataObj.addressType +'\' and associate it with this license. Please confirm your changes before saving.';
                        }else{
                            this.message = 'This action will create a new address record of the type \''+ this.addressDataObj.addressType +' Address'+'\' and associate it with this license. Please confirm your changes before saving.';
                        }
                    }

                }
                this.showSpinner = false;
                this.showAddressModal = false;
                this.showConfirmationBox = true;
            }
        }

    }

    showMessage(title, message, variant) {
        const toastEvt = new ShowToastEvent({
            title,
            message,
            variant,
        });
        this.dispatchEvent(toastEvt);
    }
    closeConfirmationModal() {
        this.showConfirmationBox = false;
        this.showAddressModal = true;
    }

    handleSave() {
        if (this.authAppId != null && this.authAppId != '') {
            this.editLocation();
        } else {
            this.saveAuthAppPlace();
        }
    }

    editLocation() {
        this.showSpinner = true;
        editLocation({
            recordId: this.authAppId,
            branchDataObj: JSON.stringify(this.addressDataObj)
        }).then(result => {
            this.showSpinner = false;
            this.showMessage('Success', 'Your Address details have been updated in our records', 'success');
            this.showConfirmationBox = false;
            this.showAddressModal = false;
            const customEvent = new CustomEvent('save');
            this.dispatchEvent(customEvent);
        }).catch(error => {
            this.showSpinner = false;
            this.showConfirmationBox = false;
            this.showAddressModal = true;
            const toastEvt = new ShowToastEvent({
                'title': error?.body?.message,
                'message': '',
                'variant': 'error',
                'mode': 'sticky'
            });
            this.dispatchEvent(toastEvt);
        })
    }

    saveAuthAppPlace() {
        this.addressDataObj.telephoneNum = this.addressDataObj.telephoneNum ?
            this.addressDataObj.telephoneNum.replace(/[^\d]/g, "") :
            this.addressDataObj.telephoneNum;
        this.showSpinner = true;
        this.showConfirmationBox = false;
        saveBranchAddressDetails({
            blId: this.recordId,
            accId: this.accId,
            branchDataObj: JSON.stringify(this.addressDataObj),
            locationType: this.addressDataObj.addressType
        }).then(result => {
            this.showSpinner = false;
            this.showMessage('Success', 'Your Address details have been updated in our records', 'success');
            this.showConfirmationBox = false;
            this.showAddressModal = false;
            const customEvent = new CustomEvent('save');
            this.dispatchEvent(customEvent);
        }).catch(error => {
            this.showSpinner = false;
            this.showMessage('Error', error?.body?.message, 'error');
        })
    }
    fetchOpenAddressDetails(recordId, locationType){
        this.showSpinner = true;
        fetchAuthAppDetails({
            recordId : recordId,
            locationType : locationType
        }).then(result => {
            console.error('result'+JSON.stringify(result));
            this.addressDataObj = result;
            this.addressDataObj.isAddressUpdateOnAccount = false;
            this.selectedSearchResult['label'] = this.addressDataObj?.countyLookup;
            this.selectedCountyValue = this.addressDataObj?.countyLookup;
            if (this.addressDataObj.addressType == 'Business Address') {
                this.showBusinessName = true;
            }
            this.addressDataObj.addressType = locationType;
            this.showSpinner = false;
        }).catch(error => {
            this.showSpinner = false;
            this.showMessage('Error', error?.body?.message, 'error');
        })
    }
}