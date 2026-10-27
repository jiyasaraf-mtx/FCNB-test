import {
    LightningElement,
    track,
    api
} from 'lwc';
import getRecordDetail from "@salesforce/apex/LPI_NewVisitRecord.getRecordDetail";
import createVisitRecord from "@salesforce/apex/LPI_NewVisitRecord.createVisitRecord";
import getAddressDetail from "@salesforce/apex/LPI_NewVisitRecord.getAddressDetail";
import assignInspectorBasedOnZipcodeForPharmacy from "@salesforce/apex/LPI_NewVisitRecord.assignInspectorBasedOnZipcodeForPharmacy";
import getBoardNameFromLicenseType from "@salesforce/apex/LPI_NewVisitRecord.getBoardNameFromLicenseType";
import {
    CloseActionScreenEvent
} from 'lightning/actions';
import {
    showAsyncErrorMessage
} from 'c/lpiUtil';
import {
    ShowToastEvent
} from 'lightning/platformShowToastEvent';
import {
    NavigationMixin
} from 'lightning/navigation';
import userId from '@salesforce/user/Id';
import pharmacyInspectionsLicenseTypes from '@salesforce/label/c.Pharmacy_Inspections_Entity_License_Types';

const COMPLETED_TXT ='Completed';
const INCOMPLETE_TASKS_ERR_MSG = "One or more mandatory tasks are incomplete,Please finish all mandatory tasks before Marking it Completed.";
const ADDITIONAL_INSPECTION ='Additional Inspection';
const UNABLE_TO_INSPECT_COMPLETED_STATUS_ERR_MSG = 'Inspection cannot be marked Unable to Inspect along with Completed Status.';
const CLOSED_TXT = 'Closed';
const COSBAR_BOARD = 'Cosmetology & Barber Examiners';

export default class LpiNewVisitRecord extends NavigationMixin(LightningElement) {
    contextName = '';
    @api showHeader = "true";
    @api fromRelatedVisit;
    @api isAddtionalInspection;
    @track vistPriority = [];
    @track inspectionType = [];
    @track visitDiscipline = [];
    @track locationTypePicklist = [];
    @track resultOptions = [];
    @track recurrenceOptions = [];
    @track visitRec = {};
    @track stateOptions = [];
    @track addressRec;
    @track inspectionReason = [];
    @track visitStatus = [];
    @track inspectionFormOptions = [];
    @track showReccurance = false;
    showNewAddress = true;
    showAddressDisabled = false;
    showLocation = true;
    showPlaceLookup = true;
    _recordId;
    isVisitRecEdit;
    showSpinner;
    @api isAdhocCheckBox = false;
    otherObjQC;
    inspectionName;
    accName;
    loggedInUserId = userId;
    notInspectorProfile;
    boardStaffProfile;
    sysAdminProfile;
    roleName;
    displayCmp;
    boardName;
    hasIncompleteTasks = false;
    loggedInUserName = '';
    defaultAddressRecId;
    @track isAdhocVisit;
    @track subreasonVisible;
    @track subreasonValue = [];
    isFromVisitDetail;
    @track visitorId;
    @track pastSelectedDates = {

    }
    displayInspectorField;
    @track inspectionReasonsInitial = [];
    showInspectionFormQues;
    showInspFormForNursingRoutine;
    inspectionTypeListForFormSelection = ['Initial', 'Routine', 'Adhoc Inspection'];
    ratNameToSelectInspectionForms = ['Drug Outsourcer', 'Pharmacy','Practical Nursing Program', 'Associate Degree Nursing Program','Baccalaureate Degree Nursing Program'];
    nursingSchoolLicenseTypes = ['Practical Nursing Program', 'Associate Degree Nursing Program','Baccalaureate Degree Nursing Program'];
    ratInspectionTypeToOptionsMap = {
        'Drug Outsourcer': [{
            'label': 'Inspection Template',
            'value': 'Inspection Template'
        }],
        'Pharmacy-Initial': [{
            'label': 'Inspection Template',
            'value': 'Inspection Template'
        },
        {
            'label': 'Sterile Compounding Inspection Report',
            'value': 'Sterile Compounding Inspection Report'
        }],
        'Pharmacy-Routine': [{
            'label': 'Inspection Template',
            'value': 'Inspection Template'
        },{
            'label': 'Quality Assurance Template',
            'value': 'Quality Assurance Template'
        },
        {
            'label': 'Sterile Compounding Inspection Report',
            'value': 'Sterile Compounding Inspection Report'
        }],
        'Nursing-Site Survey': [{
            'label': 'Professional Template',
            'value': 'Professional Template'
        },
        {
            'label': 'Practical Template',
            'value': 'Practical Template'
        }]
    }
    statusMarkedCompleted = false;
    ratName;
    inspectionReasonToSort;
    inspectionTypeDependentValues;
    showDisciplineField = false;
    hideRemedialFields = false;
    isCaseContext = false;
    @track hideInspectionReason;
    requireLicenseTypeSelection = false;
    get recordId() {
        return this._recordId;
    }
    get dateAssignedRequired(){
        return this.visitRec.visitor;
    }
    @api
    set recordId(value) {
        this.isAddtionalInspection =  (this.isAddtionalInspection === "true" || this.isAddtionalInspection);
        this._recordId = value;
        this.showSpinner = true;
        this.getVisitRecordDetails();
    }

    connectedCallback() {
        this.isAdhocCheckBox = (this.isAdhocCheckBox === "true");
        this.isAddtionalInspection =  (this.isAddtionalInspection === "true" || this.isAddtionalInspection);
        
        // if (this.isAdhocCheckBox || this.isAddtionalInspection) {
        if (this.isAdhocCheckBox) {
            this.getVisitRecordDetails();
        }
    }
    
    get modalLabel() {
        return (this.isAddtionalInspection ? 'Create Additional Inspection' : 'Initiate Inspection');
    }
    
    get showHeaderUI() {
        return this.showHeader === "true";
    }
    get showAccLookup() {
        return this.isVisitRecEdit && !this.otherObjQC;
    }
    get isVisitOnEditMode() {
        return this.isVisitRecEdit; 
    }
    get showVisitComment(){
        return ((this.sysAdminProfile || this.boardStaffProfile || !this.notInspectorProfile) && (this.visitRec.vStatus != 'Planned' && this.visitRec.vStatus != 'InProgress'));
    }
    get disabledFields() {
        return (this.isFromVisitDetail && 
                this.loggedInUserId !== this.visitorId && 
                this.roleName != 'Inspector Supervisor' &&
                    !this.isAddtionalInspection && 
                    !this.boardStaffProfile && 
                    !this.sysAdminProfile);
    }
    get disableInspectionType() {
        return this.disabledFields || this.roleName === 'Inspector Supervisor';
    }

    get adhocInspector() {
        return this.visitorId === undefined ? this.loggedInUserId : this.visitorId;
    }
    get isInspectionMarkedCompleted() {
        return ((this.visitRec && this.visitRec.vStatus === COMPLETED_TXT )|| ((this.visitRec && this.visitRec['unableToInspect']) && this.visitRec.subReason === 'Voluntarily Closing'));
    }
    get isAdhocInspection() {
        return (this.isAdhocCheckBox || this.inspectionType ==='Adhoc Inspection');
    }
    get isNursingSchoolLicenseType(){
        return this.nursingSchoolLicenseTypes.includes(this.ratName) ? true : false;
    }

    get isBoardNursingLabel(){
        return (this.boardName === 'Nursing' && this.showInspectionFormQues) ? 'Inspection Criteria Template' : 'Inspection Forms'
    }
    get showInspectionClosedDate() {
        return !this.isAdhocVisit && this.visitRec && this.visitRec.vStatus === CLOSED_TXT && this.boardName !== COSBAR_BOARD;
    }
    get hideRemFields() {
        return this.hideRemedialFields || this.boardName === COSBAR_BOARD;
    }

    get makeResultReqd (){
        return this.visitRec && this.visitRec['unableToInspect'];
    }
    
    getVisitRecordDetails() {
        this._recordId = this._recordId || null;
        this.showSpinner = true;
        getRecordDetail({
            recordId: this._recordId,
            isAdhocInspection: this.isAdhocCheckBox,
            isAddtionalInspection: this.isAddtionalInspection
        }).then(result => {
            if (result != null) {
                this.displayInspectorField = result.displayInspectorField;
                this.notInspectorProfile = (result.profileName != 'Inspectors');
                this.boardStaffProfile = (result.profileName == 'Board Staff');
                this.sysAdminProfile = (result.profileName == 'System Administrator');
                if(!this.boardStaffProfile && !this.sysAdminProfile && result.visitStatus){
                    result.visitStatus = result.visitStatus.filter( (option) => {
                        return option.label !== 'Closed';
                    });
                }
                if(!result.showVisit && result.visitStatus) { // remove in progress status if(this.sysAdminProfile || !this.notInspectorProfile || this.boardStaffProfile) {
                    result.visitStatus = result.visitStatus.filter(option=>{
                        return option.label != 'In Progress';
                    });
                    this.visitRec= {
                        ...this.visitRec,
                        vStatus : 'Planned'
                    };
                }
                this.inspectionReasonsInitial = result.inspectionReasonAll;
                this.subreasonValue = result.subreasonValue;
                this.isAdhocVisit = result.isAdhocVisit || this.isAdhocCheckBox;
                this.inspectionReasonToSort = result.inspectionReasonToSort;
                this.hideInspectionReason  = result.inspectionReasonToSort && (!result.visitRec || !result.visitRec.vInspectionType) && !this.isAdhocVisit;
                this.inspectionReason = !result.inspectionReasonToSort ? result.inspectionReason :  this.inspectionReason;
                this.inspectionTypeDependentValues = result.inspectionReason;
                if( this.isAdhocVisit && result.inspectionReason && result.inspectionReasonToSort){
                    JSON.parse(result.inspectionReason)['Adhoc Inspection'].toString().split(";").forEach(type =>{
                        this.inspectionReason.push({
                            'label' : type, 'value' : type
                        })
                    }); 
                }
                if(!this.isAdhocVisit && result.visitRec && result.visitRec.vInspectionType && result.inspectionReasonToSort && !this.hideInspectionReason && JSON.parse(result.inspectionReason)[result.inspectionType.find(opt => opt.recordId === result.visitRec.vInspectionType || opt.value === result.visitRec.vInspectionType).value]){
                    JSON.parse(result.inspectionReason)[result.inspectionType.find(opt => opt.recordId ===result.visitRec.vInspectionType || opt.value === result.visitRec.vInspectionType).value].toString().split(";").forEach(type =>{
                        this.inspectionReason.push({
                            'label' : type, 'value' : type
                        })
                    });

                   
                }
                else if(!this.isAdhocVisit && result.visitRec && result.visitRec.vInspectionType && result.inspectionReasonToSort && !this.hideInspectionReason && !JSON.parse(result.inspectionReason)[result.inspectionType.find(opt => opt.recordId === result.visitRec.vInspectionType || opt.value === result.visitRec.vInspectionType).value]){
                    this.inspectionReason = result.visitRec.vInspectionTyp != 'Initial' ? this.inspectionReasonsInitial.filter(option => option.label != 'Initial - Change of Ownership') : this.inspectionReasonsInitial;
                }

                
                this.ratName = result.ratName;
                this.loggedInUserName = result.userName;
                this.roleName = result.userRole;
                this.vistPriority = result.vistPriority;
                this.inspectionType = result.inspectionType;
                this.visitDiscipline = result.visitDiscipline;
                this.locationTypePicklist = result.locationType;
                this.stateOptions = result.stateOptions;
                this.resultOptions = result.optionsForResult;
                this.recurrenceOptions = result.recurrenceOptions;
                this.inspectionName = result.inspectionName;
                this.defaultAddressRecId = result.addressRecDefault;
                this.visitStatus = result.visitStatus;
                this.accName = result.accName;
                this.otherObjQC = result.otherRecQuickAction || false;
                this.isFromVisitDetail = result.fromVisitDetail;
                this.boardName = result.boardName;
                this.hasIncompleteTasks = result.hasIncompleteTasks;
                
                if(this.roleName === 'Inspector Supervisor' && !this.isFromVisitDetail) { 
                    // in case of new we are populating Inspection Type to Routine. then we are calling logic to fill in inspection form details.
                    this.visitRec.vInspectionType = 'Routine';
                    this.showReccurance = true;
                    if(!this.isAdhocVisit) {
                        let inspectionTypeSelected = this.inspectionType.find(inspection => inspection.value === 'Routine');
                        this.visitRec.visitTypeId = inspectionTypeSelected && inspectionTypeSelected.recordId ? inspectionTypeSelected.recordId : null;
                        
                        this.updateInspectionFormConfig(inspectionTypeSelected);
                    }
                }
                if (result.showCase) {
                    this.showDisciplineField = true;
                    this.visitRec['context'] = this._recordId;
                    this.contextName = result.contextName;
                    this.isCaseContext = true;
                    this.hideRemedialFields = true;
                    this.visitRec.vAccount = (!this.visitRec.vAccount && result.vAccount) ? result.vAccount : this.visitRec.vAccount;
                    this.visitRec.boardName = result.boardName;
                    this.visitRec.licenseTypeName = result.ratName;
                    this.requireLicenseTypeSelection = !!result.requireLicenseTypeSelection;
                } else if (result.showVisit) {
                    this.isVisitRecEdit = true;
    
                    if (result.visitRec) {
                        this.visitRec = JSON.parse(JSON.stringify(result.visitRec));
                        this.defaultAddressRecId = this.visitRec.addressLoc;
                        this.visitorId = this.visitRec.visitor;
                        let stringtoSearch = this.ratName !== 'Pharmacy' ? (this.nursingSchoolLicenseTypes.includes(this.ratName) ? 'Nursing' + '-' +this.visitRec.vInspectionType : this.ratName)  : this.ratName + '-'+this.visitRec.vInspectionType;
                        this.inspectionFormOptions = (this.ratInspectionTypeToOptionsMap[stringtoSearch]);
                        if(this.nursingSchoolLicenseTypes.includes(this.ratName)){
                            this.visitRec.inspectionFormsList = this.visitRec.inspectionForms ? this.visitRec.inspectionForms : [];
                        }else{
                            this.visitRec.inspectionFormsList = this.visitRec.inspectionForms ? this.visitRec.inspectionForms.split(';') : [];
                        }
                        this.showInspectionFormQues = !this.isVisitRecEdit && this.inspectionFormOptions && this.inspectionFormOptions.length > 0 && this.ratNameToSelectInspectionForms.includes(this.ratName) && (!this.nursingSchoolLicenseTypes.includes(this.ratName) && this.inspectionTypeListForFormSelection.includes(this.visitRec.vInspectionType) 
                            || (this.visitRec.vInspectionType === 'Other' && this.visitRec.inspectionReason === 'Follow-up'));
                        //this.isAddtionalInspection = (result.visitRec.vInspectionType === ADDITIONAL_INSPECTION);

                        this.showInspFormForNursingRoutine = !this.isVisitRecEdit && (this.nursingSchoolLicenseTypes.includes(this.ratName) && this.visitRec.vInspectionType === 'Site Survey')
                        // this.hideRemedialFields = this.visitRec.vInspectionType === 'Routine';
                        this.hideRemedialFields = false;
                    }
                    if (!this.isAdhocVisit && !this._recordId.startsWith('0Z5')) // setting context if its not adhoc visit and additional Inspection.
                        this.visitRec['context'] = (this.visitRec.context ? this.visitRec.context : this._recordId);

                    this.visitRec.licenseTypeName = this.isAdhocVisit ? result.licenseId : result.visitRec.licenseTypeName;
                    this.contextName = this.visitRec.contextName;
                    this.pastSelectedDates.vPlannedStartTime = this.visitRec.vPlannedStartTime;
                    this.pastSelectedDates.vPlannedEndTime = this.visitRec.vPlannedEndTime;
                    
                } else {
                    // setting context
                    this.hideRemedialFields = true; //this.visitRec.vInspectionType === 'Routine';
                    this.visitRec.vAccount = (!this.visitRec.vAccount && result.vAccount) ? result.vAccount : this.visitRec.vAccount;
                    this.visitRec['context'] = (this.visitRec.context ? this.visitRec.context : this._recordId);
                }

                if (this.isAddtionalInspection) {
                    this.visitRec.vPlannedEndTime = null;
                    this.visitRec.vPlannedStartTime = null;
                }
                this.showSpinner = false;
                setTimeout(() => {
                    this.displayCmp = true;
                }, "1000");


            }
        }).catch((error) => {
            this.showSpinner = false;
            this.showToast("Error", error, "error");
        })
    }


    closeQuickAction() {
        this.dispatchEvent(new CloseActionScreenEvent());
        this.dispatchEvent(new CustomEvent('close'));
    }

    closeAction() {
        this.closeQuickAction();
    }
    lookupRecord(event) {
        if (!event.detail || !event.target) {
            return;
        }
        if (event.detail.selectedRecord != null && event.detail.selectedRecord.Id) {
            this.visitRec[event.target.name] = event.detail.selectedRecord.Id;
            if (event.target.name == "addressLoc") {
                getAddressDetail({
                        recordId: event.detail.selectedRecord.Id
                    })
                    .then((result) => {
                        this.addressRec = JSON.parse(JSON.stringify(result));
                        this.showNewAddress = true;
                        this.showAddressDisabled = true;
                        if (!this.isFromVisitDetail) {
                            if (this.boardName == 'Pharmacy') {
                                this.assignInspectorBasedOnZipcodeForPharmacy(this.addressRec.PostalCode);
                            } else if (typeof this.visitRec['licenseTypeName'] != 'undefined' && pharmacyInspectionsLicenseTypes.includes(this.visitRec['licenseTypeName'])) {
                                this.assignInspectorBasedOnZipcodeForPharmacy(this.addressRec.PostalCode);
                            }
                        }
                    })
                    .catch((error) => {
                        this.showToast("Error", error, "error");
                    });
            } else if (event.target.name === 'licenseTypeName') {
                this.visitRec[event.target.name] = event.detail.selectedRecord.Name;
                this.ratName = event.detail.selectedRecord.Name;
                this.requireLicenseTypeSelection = false;
                let stringtoSearch = event.detail.selectedRecord.Name !== 'Pharmacy' ? event.detail.selectedRecord.Name : event.detail.selectedRecord.Name + '-Adhoc Inspection';
                this.inspectionFormOptions = (this.ratInspectionTypeToOptionsMap[stringtoSearch]);
                this.showInspectionFormQues = this.inspectionFormOptions && this.inspectionFormOptions.length > 0 && !this.isVisitRecEdit && this.ratNameToSelectInspectionForms.includes(event.detail.selectedRecord.Name) && (this.inspectionTypeListForFormSelection.includes('Adhoc Inspection'));
                this.visitRec.inspectionFormsList = (this.showInspectionFormQues) ? this.visitRec.inspectionFormsList : [];
                this.visitRec.inspectionForms = (this.showInspectionFormQues) ? this.inspectionForms : null;
                getBoardNameFromLicenseType({
                    licenseTypeName: event.detail.selectedRecord.Name
                }).then((boardName) => {
                    if (boardName) {
                        this.boardName = boardName;
                        this.visitRec.boardName = boardName;
                        let inputFields = this.template.querySelectorAll("c-custom-look-up");
                        inputFields.forEach((inputField) => {
                            if (inputField.name == 'visitor' && typeof inputField.clearCachedResults === 'function') {
                                inputField.clearCachedResults();
                            }
                        });
                    }
                }).catch((error) => {
                    showAsyncErrorMessage(this, error);
                });
                if (!this.isFromVisitDetail) {
                    if (pharmacyInspectionsLicenseTypes.includes(this.visitRec['licenseTypeName']) && typeof this.addressRec != 'undefined') {
                        this.assignInspectorBasedOnZipcodeForPharmacy(this.addressRec.PostalCode);
                    } else {
                        let inputFields = this.template.querySelectorAll("c-custom-look-up");
                        inputFields.forEach((inputField) => {
                            if (inputField.name == 'visitor') {
                                inputField.updateLookupName(this.loggedInUserName, this.loggedInUserId);
                            }
                        });
                    }
                }
            }
        }
    }


    handleDateValidation(event) {
        let plannedStartDate = this.refs.vPlannedStartTime;
        let plannedEndDate = this.refs.vPlannedEndTime;
        let actualEndDate = this.refs.vActualEndTime;
        let today = new Date();
        let options = {
            timeZone: 'America/Denver', // MDT timezone
            year: 'numeric', // four-digit year
            month: 'numeric', // full month name
            day: 'numeric', // day of the month
        };
        today = new Date(new Intl.DateTimeFormat("en-US", options).format(today));
        if (event) {
            this.visitRec[event.target.name] = event.target.value;

        }

        if (event && (event.target.name == 'vPlannedStartTime' || event.target.name == 'vPlannedEndTime')) {
            plannedStartDate && plannedStartDate.setCustomValidity('');
            plannedStartDate && plannedStartDate.reportValidity('');
            plannedEndDate && plannedEndDate.setCustomValidity('');
            plannedEndDate && plannedEndDate.reportValidity('');

        }

        if (event && (event.target.name == 'vPlannedStartTime' || event.target.name == 'vActualEndTime')) {
            actualEndDate && actualEndDate.setCustomValidity('');
            actualEndDate && actualEndDate.reportValidity('');
            plannedStartDate && plannedStartDate.setCustomValidity('');
            plannedStartDate && plannedStartDate.reportValidity('');
        }

        if (event && (event.target.name == 'vPlannedStartTime' || event.target.name == 'vPlannedEndTime')) {

            let date1 = event.target.name == 'vPlannedStartTime' ? 'Start Date' : 'Due Date';
            let ref = (date1 === 'Start Date' ? plannedStartDate : plannedEndDate);
            let date2 = (date1 == 'Start Date' ? 'Due Date' : 'Start Date');
            let symbol = date1 === 'Start Date' ? 'greater' : 'less';


            if (event.target.name == 'vPlannedStartTime' && plannedStartDate && plannedStartDate.value && ((!this.pastSelectedDates.vPlannedStartTime && new Date(plannedStartDate.value) < today) || (this.pastSelectedDates.vPlannedStartTime && new Date(plannedStartDate.value) < new Date(this.pastSelectedDates.vPlannedStartTime)))) {
                plannedStartDate.setCustomValidity('Start Date cannot be a Past Date.');
                plannedStartDate.reportValidity();
                // this.visitRec[event.target.name] = null;
            }
            if (event.target.name == 'vPlannedEndTime' && plannedEndDate && plannedEndDate.value && ((!this.pastSelectedDates.vPlannedEndTime && new Date(plannedEndDate.value) < today) || (this.pastSelectedDates.vPlannedEndTime && new Date(plannedEndDate.value) < new Date(this.pastSelectedDates.vPlannedEndTime)))) {
                plannedEndDate.setCustomValidity('Due Date cannot be a Past Date.');
                plannedEndDate.reportValidity();
                // this.visitRec[event.target.name] = null;
            }
            if (plannedStartDate && plannedStartDate.value &&
                plannedEndDate && plannedEndDate.value &&
                new Date(plannedEndDate.value) < new Date(plannedStartDate.value)) {

                ref.setCustomValidity(`${date1} cannot be ${symbol} than ${date2}.`);
                ref.reportValidity();

                // this.visitRec[event.target.name] = null;
            }

            if (event.target.name == 'vPlannedStartTime' && plannedStartDate && plannedStartDate.value &&
                actualEndDate && actualEndDate.value &&
                new Date(actualEndDate.value) < new Date(plannedStartDate.value)) {

                ref.setCustomValidity('Inspection Completed Date cannot be smaller than Start Date');
                ref.reportValidity();

                // this.visitRec[event.target.name] = null;
            }

        }
        if (event && (event.target.name == 'vActualEndTime')) {
            if (plannedStartDate && plannedStartDate.value &&
                actualEndDate && actualEndDate.value &&
                new Date(actualEndDate.value) < new Date(plannedStartDate.value)) {

                actualEndDate.setCustomValidity('Inspection Completed Date cannot be smaller than Start Date');
                actualEndDate.reportValidity();

                // this.visitRec[event.target.name] = null;
            }

        }

        if (!event && plannedStartDate && plannedStartDate.value && ((!this.pastSelectedDates.vPlannedStartTime && new Date(plannedStartDate.value) < today) || (this.pastSelectedDates.vPlannedStartTime && new Date(plannedStartDate.value) < new Date(this.pastSelectedDates.vPlannedStartTime)))) {
            plannedStartDate.setCustomValidity(' Start Date cannot be a Past Date.');
            plannedStartDate.reportValidity();
        }
        if (!event && plannedEndDate && plannedEndDate && plannedEndDate.value && ((!this.pastSelectedDates.vPlannedEndTime && new Date(plannedEndDate.value) < today) || (this.pastSelectedDates.vPlannedEndTime && new Date(plannedEndDate.value) < new Date(this.pastSelectedDates.vPlannedEndTime)))) {
            plannedEndDate.setCustomValidity('Due date cannot be a Past Date.');
            plannedEndDate.reportValidity();
        }
        if (!event && plannedStartDate && plannedStartDate.value && plannedEndDate && plannedEndDate.value && new Date(plannedEndDate.value) < new Date(plannedStartDate.value)) {
            plannedEndDate.setCustomValidity('Due date cannot be a smaller than Start Date.');
            plannedEndDate.reportValidity();
        }
        if (!event && plannedStartDate && plannedStartDate.value && actualEndDate && actualEndDate.value && new Date(actualEndDate.value) < new Date(plannedStartDate.value)) {
            actualEndDate.setCustomValidity('Inspection Completed Date cannot be smaller than Start Date');
            actualEndDate.reportValidity();
        }
    }

    handleChange(event) {
        if (event.target.name === 'inspectionFormsList') {
            this.visitRec[event.target.name] = event.detail.value;
        }
        else if(event.currentTarget.name ==='attestation' || 
                event.currentTarget.name ==='triggerSiteSurveyEmailNotification' || 
                event.currentTarget.name === 'unableToInspect') {
            this.visitRec[event.currentTarget.name] = event.target.checked;
        } 
        else {
            this.visitRec[event.target.name] = event.target.value;
            let inspectionTypeSelected;
            if (event.target.name === 'vInspectionType') {
                inspectionTypeSelected = this.inspectionType.find(inspection => inspection.value === event.target.value);
                this.visitRec.visitTypeId = inspectionTypeSelected && inspectionTypeSelected.recordId ? inspectionTypeSelected.recordId : null;
                if (event.target.value === 'Routine') {
                    this.showReccurance = true;
                } else {
                    this.showReccurance = false;
                    this.visitRec.recurrence = '';
                }
                this.visitRec.inspectionFormsList = [];
                // PART 1
            }
            if (!this.isFromVisitDetail && event.target.name === 'zipCode' && event.target.value.length === 5) {
                if (this.boardName === 'Pharmacy' || pharmacyInspectionsLicenseTypes.includes(this.visitRec['licenseTypeName'])) {
                    this.assignInspectorBasedOnZipcodeForPharmacy(event.target.value);
                }
            }
            //Added By Nayana S-62855
            if( this.boardName === COSBAR_BOARD && event.target.name === 'inspectionReason'){
                if(event.target.value === 'Closing'){
                    this.subreasonVisible = true;
                }
                else {
                   this.subreasonVisible = false;
                }
            }
           // inspection config - PART 2
           this.updateInspectionFormConfig(inspectionTypeSelected?.value);
        }
    }

    updateInspectionFormConfig(inspectionTypeSelected) {

        let stringtoSearch = this.ratName !== 'Pharmacy' ? (this.nursingSchoolLicenseTypes.includes(this.ratName) ? 'Nursing' + '-'+this.visitRec.vInspectionType : this.ratName)  : this.ratName + '-'+this.visitRec.vInspectionType;
        this.inspectionFormOptions = (this.ratInspectionTypeToOptionsMap[stringtoSearch]);
        if(this.inspectionReasonToSort && inspectionTypeSelected && JSON.parse(this.inspectionTypeDependentValues)[inspectionTypeSelected]) {
            this.inspectionReason = [];
            this.visitRec.inspectionReason = null;
            JSON.parse(this.inspectionTypeDependentValues)[inspectionTypeSelected].toString().split(";").forEach(type =>{
                this.inspectionReason.push({
                    'label' : type, 'value' : type
                })
            });
        }else if(this.inspectionReasonToSort &&  inspectionTypeSelected && !JSON.parse(this.inspectionTypeDependentValues)[inspectionTypeSelected]){

            this.inspectionReason = inspectionTypeSelected != 'Initial' ? this.inspectionReasonsInitial.filter(option => option.label != 'Initial - Change of Ownership') : this.inspectionReasonsInitial;

        }
        this.hideInspectionReason = false;

        // PART 2
        this.showInspectionFormQues = !this.isVisitRecEdit && this.ratNameToSelectInspectionForms.includes(this.ratName) && ((!this.nursingSchoolLicenseTypes.includes(this.ratName) && this.inspectionTypeListForFormSelection.includes(this.visitRec.vInspectionType)) 
        || (this.visitRec.vInspectionType === 'Other' && this.visitRec.inspectionReason === 'Follow-up'));

        this.showInspFormForNursingRoutine = !this.isVisitRecEdit && (this.nursingSchoolLicenseTypes.includes(this.ratName) && this.visitRec.vInspectionType === 'Site Survey');
        if(this.showInspFormForNursingRoutine) {
            // this.visitRec.inspectionFormsList = this.visitRec.inspectionFormsList != null ? this.visitRec.inspectionFormsList : null;
            this.visitRec.inspectionForms = this.inspectionForms || '';
        }
        if(this.showInspectionFormQues) {
            this.visitRec.inspectionForms = this.inspectionForms || '';
        }
        this.visitRec.inspectionFormsList = this.visitRec.inspectionFormsList != null ? this.visitRec.inspectionFormsList : [];
       
    }

    assignInspectorBasedOnZipcodeForPharmacy(zipCode) {
        assignInspectorBasedOnZipcodeForPharmacy({
                zipCode: zipCode
            })
            .then((result) => {
                if (typeof result.Id != 'undefined') {
                    this.visitRec['visitor'] = result.Id;
                    let inputFields = this.template.querySelectorAll("c-custom-look-up");
                    inputFields.forEach((inputField) => {
                        if (inputField.name == 'visitor') {
                            inputField.updateLookupName(result.Name, result.Id);
                        }
                    });
                } else {
                    let inputFields = this.template.querySelectorAll("c-custom-look-up");
                    inputFields.forEach((inputField) => {
                        if (inputField.name == 'visitor') {
                            if (this.isAdhocVisit == true) {
                                inputField.updateLookupName(this.loggedInUserName, this.loggedInUserId);
                            } else {
                                inputField.removeLookup();
                            }
                        }
                    });
                }
            })
            .catch((error) => {
                this.showSpinner = false;
                this.showToast("Error", error, "error");
            });
    }

    @api handleCreateNewVisit() {
        this.handleDateValidation(null);
        let inputFields = this.template.querySelectorAll("c-custom-look-up");
        let result = true;
        inputFields.forEach((inputField) => {
            if (!inputField.checkValidation()) {
                result = false;
            }
        });
        result = this.checkValidation() && result;
        if (!result) {
            this.showToast("Error", 'Please validate all the input fields.', "error");
        } else {

            if(this.hasIncompleteTasks && this.visitRec.vStatus === COMPLETED_TXT) {
                this.showToast("Error",INCOMPLETE_TASKS_ERR_MSG,"error");
                return;
            }
            if(this.visitRec.unableToInspect && this.visitRec.vStatus ===  COMPLETED_TXT) {
                this.showToast('Error',UNABLE_TO_INSPECT_COMPLETED_STATUS_ERR_MSG,"error");
                return;
            }
            this.visitRec.isAdhocVisit = this.isAdhocVisit;
            this.visitRec.additionalInspection = this.isAddtionalInspection;
            if(this.isAddtionalInspection) {
                this.visitRec.visitId = null;
            } 
            this.visitRec.visitTypeId = this.visitRec.visitTypeId || this.inspectionType;
            if(this.nursingSchoolLicenseTypes.includes(this.ratName) && this.visitRec.vInspectionType === 'Site Survey'){
                this.visitRec.inspectionForms = this.visitRec.inspectionFormsList ? this.visitRec.inspectionFormsList : null;
            }else{
                this.visitRec.inspectionForms = this.visitRec.inspectionFormsList ? this.visitRec.inspectionFormsList.join(';') : null;
            }
            this.showSpinner = true;
            createVisitRecord({
                    jsonWrapper: JSON.stringify(this.visitRec)
                })
                .then((result) => {
                    this.showSpinner = false;
                    if (this.visitRec.visitId != null || this.isAddtionalInspection) {

                        if (this.isAddtionalInspection) {
                            this.showInspectionSuccessToast(result, true);
                            this.dispatchEvent(new CustomEvent('close', {}));
                            this._recordId = result.visitId;
                            this.navigateToVisitRecord();
                        } else {
                            this.showToast("Success", 'Inspection Record Updated !!', "success");
                            let ev = new CustomEvent('closeeditpopup', {});
                            this.dispatchEvent(ev);
                        }

                    } else {
                        this.showInspectionSuccessToast(result, false);
                        if (this._recordId) {
                            this._recordId = result.visitId;
                            this.closeQuickAction();
                        } else {
                            // navigate to the Record page.
                            this._recordId = result.visitId;
                            this.dispatchEvent(new CustomEvent('close', {}));
                            this.dispatchEvent(new CustomEvent('recordsave', {})); // for adhoc visit. 
                            this.dispatchEvent(new CustomEvent('closeeditpopup',{}));
                        }
                    }
                })
                .catch((error) => {
                    this.showSpinner = false;
                    showAsyncErrorMessage(this,error);
                });
        }

    }
    checkValidation() {
        let valid = false;
        valid = [...this.template.querySelectorAll('lightning-input,lightning-combobox,lightning-textarea,lightning-dual-listbox')].reduce(
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
        // commenting && !this.comparePlannedDateWithCurrentDate(this.visitRec.vPlannedStartTime)
        if (!this.isVisitRecEdit && this._recordId && !this.otherObjQC) {
            valid = false;
        }
        return valid;
    }
    showToast(title, msg, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: msg,
            variant: variant,
            mode: 'dismissable'
        });
        this.dispatchEvent(event);
    }

    showInspectionSuccessToast(result, isAdditional) {
        const visitName = result?.visitName || result?.visitId;
        const visitId = result?.visitId;
        const prefix = isAdditional ? 'Additional Inspection Record Created' : 'Inspection Record Created';
        if (visitId && visitName) {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Success',
                message: '{0}: {1}',
                messageData: [
                    prefix,
                    {
                        url: '/' + visitId,
                        label: visitName
                    }
                ],
                variant: 'success',
                mode: 'sticky'
            }));
            return;
        }
        this.showToast('Success', prefix + ' !!', 'success');
    }
    lookupAddRecord(event) {
        if (event.detail.selectedRecord != null && event.detail.selectedRecord == 'addRecord') {
            this.showNewAddress = false;
            this.visitRec.addressLoc = null;
        }
    }
    handleRemoveAddress() {
        this.showAddressDisabled = false;
    }
    
    handleRemoveSelection(event) {
        this.visitRec[event.target.name] = null;
        if (event.target.name === 'licenseTypeName' && this.isCaseContext) {
            this.requireLicenseTypeSelection = true;
            this.ratName = null;
            this.boardName = null;
            this.visitRec.boardName = null;
        }
    }

    handleShowLookup() {
        this.showAddressDisabled = false;
        this.showNewAddress = true;
    }
    navigateToVisitRecord() {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this._recordId,
                objectApiName: 'Visit',
                actionName: 'view'
            },
        });
    }

}