import { LightningElement, track, wire, api } from 'lwc';
import fetchRecords from '@salesforce/apex/LPIInspectionsCorrectiveActionController.fetchInspectionViolationRecords';
import checkUserType from '@salesforce/apex/LPIInspectionsCorrectiveActionController.getUserType';
import fetchVisitRecords from '@salesforce/apex/LPIInspectionsCorrectiveActionController.fetchVisitList';
import updateRCV from '@salesforce/apex/LPIInspectionsCorrectiveActionController.updateRCV';
import { CurrentPageReference } from 'lightning/navigation';
import { updateRecord } from 'lightning/uiRecordApi';


export default class LPI_InspectionsCorrectiveActions extends LightningElement {

    @api recordId;

    @track records = [];
    @track draftValues = [];
    @track saveDraftValues = [];
    @track columns = [];

    hasRecords = false;
    isPortalUser = false;
    showSpinner = true;

    columns = [
        { label: 'Regulatory Code', fieldName: 'RegulatoryCodeName' },
        { label: 'Violation Type', fieldName: 'ViolationTypeName' },
        { label: 'Status', fieldName: 'Status', editable: true},
        { label: 'Board Staff Comment', fieldName: 'Supervisor_Board_Staff_Comments__c', editable: true},
        { label: 'Licensee Comment', fieldName: 'Licensee_Comments__c', editable: false }
    ];
    portalColumns = [
        { label: 'Regulatory Code', fieldName: 'RegulatoryCodeName' },
        { label: 'Inspection', fieldName: 'InspectionName' },
        { label: 'Violation Type', fieldName: 'ViolationTypeName' },
        { label: 'Status', fieldName: 'Status', editable: false},
        { label: 'Board Staff Comment', fieldName: 'Supervisor_Board_Staff_Comments__c', editable: false},
        { label: 'Licensee Comment', fieldName: 'Licensee_Comments__c', editable: true }
    ]


    connectedCallback() {
        console.log('### Record Id: API' + this.recordId);
        const isPortalUser = this.userCheck();
        console.log('isPortalUser>>>'+isPortalUser);
        // this.columns = [
        //     { label: 'Regulatory Code', fieldName: 'RegulatoryCodeName' },
        //     { label: 'Violation Type', fieldName: 'ViolationTypeName' },
        //     { label: 'Status', fieldName: 'Status', ...(isPortalUser ? {} : { editable: true }) },
        //     { label: 'Board Staff Comment', fieldName: 'Supervisor_Board_Staff_Comments__c', ...(isPortalUser ? {} : { editable: true }) },
        //     { label: 'Licensee Comment', fieldName: 'LicenseeComment', editable: isPortalUser }
        // ];
        
        
    }

    getPortalRCVVisits(){
        this.showSpinner = true;
        fetchVisitRecords()
            .then(result => {
                console.log('Result>>>'+JSON.stringify(result));
                this.hasRecords = true;
                this.records = result.map((record, index) => ({
                    ...record,
                    serialNumber: index + 1,
                    RegulatoryCodeName: record.RegulatoryCode ? record.RegulatoryCode.Name : '',
                    ViolationTypeName: record.ViolationType ? record.ViolationType.Name : '',
                    InspectionName: record.Inspection ? record.Inspection.Name : ''
                }));
                console.log('records....'+this.records);
                this.showSpinner = false;
            })
            .catch(err => {
                this.showSpinner = false;
            })
    }

    getAssociatedRCVVisits() {
        this.showSpinner = true;
        fetchRecords({ inspectionId: this.recordId })
            .then(result => {
                this.hasRecords = true;
                this.records = result.map((record, index) => ({
                    ...record,
                    serialNumber: index + 1,
                    RegulatoryCodeName: record.RegulatoryCode ? record.RegulatoryCode.Name : '',
                    ViolationTypeName: record.ViolationType ? record.ViolationType.Name : '',
                    LicenseeComment:record.ViolationType ? record.Licensee_Comments__c : ''
                }));
                this.showSpinner = false;
            })
            .catch(err => {
                this.showSpinner = false;
            })
    }

    userCheck() {
        checkUserType()
            .then(result => {
                console.log('## Portal User>>' + result);
                if(result === false && this.recordId){
                    console.log('Inside If');
                    this.getAssociatedRCVVisits();
                }else if(result === true){
                    console.log('Inside else');
                    this.isPortalUser = true;
                    this.getPortalRCVVisits();
                }
                return result;
            })
            .catch(error => {
                console.error('## Error fetching user type:', error);
                return false;
            });
        return false;
    }

    handleSave(event) {
        let draftValues = event.detail.draftValues;
        const recordInputs = event.detail.draftValues.slice().map(draft => {
            const fields = Object.assign({}, draft);
            return { fields };
        });
        const promises = recordInputs.map(recordInput => updateRecord(recordInput));
        Promise.all(promises).then(() => {
            this.saveDraftValues = [];
            this.getAssociatedVisits();
            window.location.reload();
        }).
            catch(error => {
                console.error('## Error saving:', error);
            });
    }
    handlePortalSave(event) {
        event.preventDefault();
        console.log('Entered>>');
        this.showSpinner = true;
        const draftValues = event.detail.draftValues;
        console.log('Draft Values'+JSON.stringify(draftValues));
        updateRCV({ records: draftValues })
            .then(() => {
                console.log('LINE 139');
                this.draftValues = [];
                this.getPortalRCVVisits();
                window.location.reload();
            })
            .catch(error => {
                console.log('LINE 145');
                this.showToast('Error', 'An error occurred while updating records.', 'error');
                console.error('## Error updating records:', error);
            })
            .finally(() => {
                this.showSpinner = false;
            });
    }
}