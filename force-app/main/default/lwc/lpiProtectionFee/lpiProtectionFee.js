import { LightningElement, track, wire } from 'lwc';
import saveRemittanceFee from '@salesforce/apex/LPI_DashbaordTableCtrl.saveRemittanceFee';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CurrentPageReference } from 'lightning/navigation';

export default class LpiProtectionFee extends NavigationMixin(LightningElement) {
    @track data = [
    ];

    @track columns = [
        { label: 'First Name', fieldName: 'FirstName' },
        { label: 'Last Name', fieldName: 'LastName' },
        {
            label: 'Start Date', fieldName: 'StartDate',
            type: "date-local",
            typeAttributes: {
                month: "2-digit",
                day: "2-digit"
            }
        },
        {
            label: 'End Date', fieldName: 'EndDate',
            type: "date-local",
            typeAttributes: {
                month: "2-digit",
                day: "2-digit"
            }
        }
    ];

    @track selectedRowsCount = 0;
    @track protectionFeeDetail = {
        'licenseId': null,
        'tuitionFee': 0.0,
        'totalTuitionFee': 0.0,
        'totalStudentRemittedFee': 0.0,
        'addressData': {}
    };
    @track programOptions = [
        {
            label: 'Program 1',
            value: 'Program 1'
        },
        {
            label: 'Program 2',
            value: 'Program 2'
        },
        {
            label: 'Program 3',
            value: 'Program 3'
        }
    ];
    patternObj = {
        text: '^((?!(<)|(>)).)*$',
        digits: '^(\\([0-9]{3}\\) |[0-9]{3}-)[0-9]{3}-[0-9]{4}$',
        email: '^([A-Za-z0-9_\-\.\+]+)@([A-Za-z0-9_\-\.]+)\.([A-Za-z]{2,10})$',
        zipCode: '^[0-9]{5}(?:-[0-9]{4})?$',
        zipCodeUS: '^[0-9]{5}?$',
        zipCodeNonUS: '^[a-zA-Z0-9]*$',
        ssn: '^(?!.*(<|>))[0-9]*$',
        phone: '[0-9]*',
        name: '^[A-Za-z0-9 ]+$',
        dob: '^[A-Za-z0-9 ]+$'
    }
    @track showSpinner = false;
    @track isModalOpen = false;
    @track newFirstName = '';
    @track newLastName = '';
    @track newStartDate = '';
    @track newEndDate = '';

    @wire(CurrentPageReference)
    currentPageReference;

    get showDataTable() {
        if (this.data.length == 0) {
            return false;
        }
        return true;
    }
    get totalTuitionFee() {
        return this.selectedRowsCount * this.protectionFeeDetail.tuitionFee;
    }

    get totalStudentRemittedFee() {
        return (this.selectedRowsCount * this.protectionFeeDetail.tuitionFee) * 0.01;
    }


    connectedCallback() {
        if (`${this.currentPageReference.state.blId}` != 'undefined') {
            this.protectionFeeDetail.licenseId = `${this.currentPageReference.state.blId}`;
        }
    }

    handleAuthInputs(event) {
        let name = event.target.name;
        let value = event.target.value;
        // if (name == 'program') {
        this.protectionFeeDetail[name] = value;
        // }
    }

    handleRowSelection(event) {
        const selectedRows = event.detail.selectedRows;
        this.selectedRowsCount = selectedRows.length;
    }
    handleAddressChange(event) {
        if (event.target.name === "Mailing-address") {
            let addressDetail = event.detail;
            this.protectionFeeDetail.addressData["city"] = addressDetail.city;
            this.protectionFeeDetail.addressData["state"] = addressDetail.province;
            this.protectionFeeDetail.addressData["street"] = addressDetail.street;
            this.protectionFeeDetail.addressData["country"] = addressDetail.country;
            this.protectionFeeDetail.addressData["zip"] = addressDetail.postalCode;
        }
    }
    // Save Account details using a wrapper class
    saveAccount() {
        if (this.protectionFeeDetail.licenseId == null) {
            this.showToast('Error', 'Error: License is missing!', 'error');
            return;
        }
        this.showSpinner = true;
        this.protectionFeeDetail.totalTuitionFee = this.totalTuitionFee;
        this.protectionFeeDetail.totalStudentRemittedFee = this.totalStudentRemittedFee;
        console.log('protectionFeeDetail :>> ', JSON.stringify(this.protectionFeeDetail));
        saveRemittanceFee({ wrapper: JSON.stringify(this.protectionFeeDetail) })
            .then(() => {
                this.showToast('Success', 'Student form successfully submitted!', 'success');
                this.showSpinner = false;
                window.open('/s/','_self');
            })
            .catch(error => {
                this.showSpinner = false;
                this.showToast('Error', 'Error: ' + error.body.message, 'error');
            });
    }
    // Show toast message
    showToast(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(evt);
    }
    handleAddRecord() {
        this.isModalOpen = true;
    }

    handleCloseModal() {
        this.isModalOpen = false;
        this.resetNewRecordFields();
    }

    handleInputChange(event) {
        const field = event.target.dataset.id;
        if (field === 'firstName') {
            this.newFirstName = event.target.value;
        } else if (field === 'lastName') {
            this.newLastName = event.target.value;
        } else if (field === 'startDate') {
            this.newStartDate = event.target.value;
        } else if (field === 'endDate') {
            this.newEndDate = event.target.value;
        }
    }

    handleSaveRecord() {
        const newRecord = {
            Id: String(this.data.length + 1).padStart(3, '0'),
            FirstName: this.newFirstName,
            LastName: this.newLastName,
            StartDate: this.newStartDate,
            EndDate: this.newEndDate
        };
        this.data = [...this.data, newRecord];
        this.isModalOpen = false;
        this.resetNewRecordFields();
    }

    resetNewRecordFields() {
        this.newFirstName = '';
        this.newLastName = '';
        this.newStartDate = '';
        this.newEndDate = '';
    }
}