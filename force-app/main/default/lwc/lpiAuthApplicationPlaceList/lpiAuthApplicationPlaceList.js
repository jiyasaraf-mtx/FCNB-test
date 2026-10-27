import {
    LightningElement,
    api,
    track
} from 'lwc';
import getRelatedLocationList from '@salesforce/apex/LPI_AuthApplicationPlaceListController.getRelatedLocationList';
import {
    NavigationMixin
} from 'lightning/navigation';
import {
    showMessage
} from 'c/lpiUtil';
import {
    refreshApex
} from '@salesforce/apex';

export default class LpiAuthApplicationPlaceList extends NavigationMixin(LightningElement) {
    @track columns = [{
            label: 'Address',
            fieldName: 'addressName',
            type: 'text',
        },
        {
            label: 'Place',
            fieldName: 'placeName',
            type: 'text',
        },
        {
            label: 'Open Date',
            fieldName: 'openDate',
            type: 'date',
            typeAttributes: {
                year: 'numeric',
                month: 'numeric',
                day: 'numeric'
            }
        },
        {
            label: 'Close Date',
            fieldName: 'closeDate',
            type: 'date',
            typeAttributes: {
                year: 'numeric',
                month: 'numeric',
                day: 'numeric'
            }
        },
        {
            label: 'Status',
            fieldName: 'status',
            type: 'text'
        },
        {
            label: '',
            type: 'action',
            typeAttributes: {
                rowActions: [{
                    label: 'View/Edit',
                    name: 'edit'
                }, ],
            },
        },
    ];
    @track field1;
    @track field2;
    @track field3;
    @track field4;
    @track field5;
    @track field6;
    @track field7;
    @track field8;
    @track objectName;
    @api recordId; // The Id of the parent record
    @api limitValueRecords = false;
    @api showViewAll = false;
    @track relatedListData = [];
    @track isAccount = false;
    @track title = '';
    @track addAuthApp = false;
    @track addNewAssocLocRecord = false;
    @track openDeleteModal = false;
    @track currRecordId = '';
    @track showSpinner = false;
    @track locationModalHeading = '';
    @track deleteModalHeading = '';
    @track deleteModalContent = '';
    @track isEditAuthAppPlace = false;
    @track showTable = false;


    get showViewAllLink() {
        if(this.relatedListData.length>0 && !this.showViewAll){
            return true;
        }
        else{
            return false;
        }
    }

    connectedCallback() {
        this.fetchRelatedLocationList();
    }
    fetchRelatedLocationList() {
        this.showSpinner = true;
        getRelatedLocationList({
            recordId: this.recordId,
            isLimit: this.showViewAll
        }).then(result => {
            this.showSpinner = false;
            let locationWrap = result.locationWrapper;
            let data = locationWrap.authAppPlaceWrapperList;
            let objName = result.objName;
            if (objName === 'Account') {
                this.isAccount = true;
                this.columns.splice(this.columns.length - 1, 1);
            } else {
                this.isAccount = false;
            }

            if (locationWrap.isRecordMoreThanFive && this.showViewAll == false) {
                this.title = "Adddress (" + data.length + '+' + ")";
            } else {
                this.title = "Address (" + data.length + ")";
            }

            if (data.length > 0) {
                this.relatedListData = data;
            }
            this.showTable = true;
        }).catch(error => {
            this.showSpinner = false;
        })
    }

    handleRowAction(event) {
        const action = event.detail.action;
        const row = event.detail.row;

        if (action.name === 'edit') {
            this.currRecordId = row.authAppPlaceId;
            this.addNewAssocLocRecord = true;
            if (this.isAccount) {
                this.locationModalHeading = 'Edit Address';
            } else {
                this.locationModalHeading = 'Edit Address';
                this.isEditAuthAppPlace = true;
            }
        }
    }
    addNewAuthAppRecord() {
        this.addAuthApp = true;
        this.locationModalHeading = 'Add Address';
    }
    addNewAssociateLocation() {
        this.addNewAssocLocRecord = true;
        this.locationModalHeading = 'New Associated Location';
    }

    handleSubmit(event) {
        event.preventDefault(); // stop the form from submitting
        if (!this.checkValidityAuthValidate()) {
            showMessage(this, {
                title: "Error",
                message: "Please fill all the required fields",
                messageType: "Error",
                mode: "dismissable"
            });
        } else {
            const fields = event.detail.fields;
            this.template.querySelector('lightning-record-edit-form').submit(fields);
            this.addNewAssocLocRecord = false;
            this.showSpinner = true;
        }
    }
    handleError(event) {
        this.showSpinner = false;
        alert('error' + JSON.stringify(event.detail));
    }
    closeLocationModal() {
        const inputFields = this.template.querySelectorAll(
            'lightning-input-field'
        );
        if (inputFields) {
            inputFields.forEach(field => {
                field.reset();
            });
        }
        this.addNewAssocLocRecord = false;
    }
    handleSuccess() {
        //eval("$A.get('e.force:refreshView').fire();");
        showMessage(this, {
            title: "Success",
            message: "Association Record is created successfully",
            messageType: "Success",
            mode: "dismissable"
        });
        refreshApex(this.fetchRelatedLocationList());
    }

    checkValidityAuthValidate() {
        let valid = false;
        valid = [...this.template.querySelectorAll("lightning-input-field")].reduce((validSoFar, input) => {
            input.reportValidity();
            return validSoFar && input.reportValidity();
        }, true);
        return valid;
    }
    handleCloseAuthAppModal() {
        this.addAuthApp = false;
        this.isEditAuthAppPlace = false;
        this.addNewAssocLocRecord = false;
    }
    handleAuthAppPlaceSave() {
        this.addAuthApp = false;
        this.isEditAuthAppPlace = false;
        this.addNewAssocLocRecord = false;
        refreshApex(this.fetchRelatedLocationList());
    }
    viewLocations(event) {
        event.preventDefault();
        this.limitValueRecords = true;
        let showViewAll = event.target.dataset.viewall;
        let cmpDef = {
            componentDef: "c:lpiAuthApplicationPlaceList",
            attributes: {
                recordId: this.recordId,
                limitValueRecords: this.limitValueRecords,
                showViewAll: showViewAll
            }
        };
        let encodedDef = btoa(JSON.stringify(cmpDef));
        this[NavigationMixin.Navigate]({
            type: "standard__webPage",
            attributes: {
                url: "/one/one.app#" + encodedDef
            }
        });
    }
}