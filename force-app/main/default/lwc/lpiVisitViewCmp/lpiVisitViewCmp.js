import { LightningElement,api,track,wire} from 'lwc';
import PLACE_FIELD from '@salesforce/schema/Visit.PlaceId';
import STATUS_FIELD from '@salesforce/schema/Visit.Status__c';
import PRIORITY_FIELD from '@salesforce/schema/Visit.VisitPriority';
import VISIT_TYPE_FIELD from '@salesforce/schema/Visit.VisitTypeId';
import END_DATE_FIELD from '@salesforce/schema/Visit.Planned_End_Date__c';
import VISITOR_FIELD from '@salesforce/schema/Visit.VisitorId';
import CONTEXT_FIELD from '@salesforce/schema/Visit.ContextId';
import ACCOUNT_FIELD from '@salesforce/schema/Visit.AccountId';
import RECURRENCE_FIELD from '@salesforce/schema/Visit.Recurrence__c';
import INSPECTION_REASON_FIELD from '@salesforce/schema/Visit.Inspection_Reason__c';
import OWNER_FIELD from '@salesforce/schema/Visit.OwnerId';
import LICENSE_TYPE_FIELD from '@salesforce/schema/Visit.License_Type__c';
import ACTUAL_VISIT_END_TIME_FIELD from '@salesforce/schema/Visit.Actual_End_Date__c';
import ASSESSMENT_RESULT_FIELD from '@salesforce/schema/Visit.Final_Assessment_Result__c';
import BOARD_NAME from '@salesforce/schema/Visit.Board_Name__c'
import DATE_ASSIGNED_FIELD from '@salesforce/schema/Visit.Date_Assigned__c';
import REMEDIAL_ACTION_SENT from '@salesforce/schema/Visit.Remedial_Action_Sent__c';
import REMEDIAL_RESPONSE_DUE from '@salesforce/schema/Visit.Remedial_Response_Due__c';
import REMEDIAL_RESPONSE_RECEIVED from '@salesforce/schema/Visit.Remedial_response_received__c';
import CASE_NUMBER_FIELD from '@salesforce/schema/Case.Case_Number_HyperLink__c';
import NAME_OF_LICENSEE from '@salesforce/schema/Visit.Name_of_Licensee_Applicant_Representativ__c';
import TITLE from '@salesforce/schema/Visit.Title__c';
import LICENSEE_SIGNED_DATE from '@salesforce/schema/Visit.Licensee_Applicant_Rep_Signed_Date__c';
import INSPECTOR_SIGNED_DATE from '@salesforce/schema/Visit.Inspector_Signed_Date__c';
import ATTESTATION_CHECK from '@salesforce/schema/Visit.Attestation_by_Licensee_Applicant_Rep__c';
import checkContextIdCaseSobject from "@salesforce/apex/LPI_NewVisitRecord.checkContextIdCaseSobject";
import PIC_MIC_SIGNATURE from '@salesforce/schema/Visit.PIC_MIC_Signature__c';
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import TRIGGER_SITE_SURVEY_EMAIL_NOTIFICATION from '@salesforce/schema/Visit.Trigger_Site_Survey_Email_Notification__c';
import UNABLE_TO_INSPECT from '@salesforce/schema/Visit.Unable_to_Inspect__c';
import CLOSED_DATE from '@salesforce/schema/Visit.Closed_Date__c';
import COMMENTS from '@salesforce/schema/Visit.Comments__c';
import SUPERVISOR_REVIEW_FIELD from '@salesforce/schema/Visit.Supervisor_review__c';
const COSBAR_BOARD = 'Cosmetology & Barber Examiners';
import { loadStyle } from "lightning/platformResourceLoader";
import LPI_InternalCSS from "@salesforce/resourceUrl/LPI_Design";

const fields = [LICENSE_TYPE_FIELD];
export default class LpiVisitViewCmp extends LightningElement {
    @api objectApiName;
    startDate = DATE_ASSIGNED_FIELD;
    closedDate = CLOSED_DATE;
    placeField = PLACE_FIELD;
    contextField = CONTEXT_FIELD;
    caseNumberField = CASE_NUMBER_FIELD;
    nameOfLicensee = NAME_OF_LICENSEE;
    attestationCheckBox = ATTESTATION_CHECK;
    title = TITLE;
    boardName;
    inspectorSignedDate = INSPECTOR_SIGNED_DATE;
    licenseeSignedDate = LICENSEE_SIGNED_DATE;
    triggerSiteSurveyEmailNotificationField = TRIGGER_SITE_SURVEY_EMAIL_NOTIFICATION;
    isCaseObj = false;
    contextId = '';
    placeId = '';
    businessName;
    placeName;
    disciplineVal;
    dbaName;
    classification;
    lastInspectionDate;
    assessmentResultField = ASSESSMENT_RESULT_FIELD;
    comments = COMMENTS;
    
    @track remedialInfo = {
        remedialActionSent : REMEDIAL_ACTION_SENT,
        remedialDueResponse : REMEDIAL_RESPONSE_DUE,
        remedialResponseRecieved : REMEDIAL_RESPONSE_RECEIVED
    }
    @track fieldsList = [
        SUPERVISOR_REVIEW_FIELD,
        BOARD_NAME,
        LICENSE_TYPE_FIELD,
        STATUS_FIELD,
        PRIORITY_FIELD,
        VISIT_TYPE_FIELD,
        
        END_DATE_FIELD,
        
        ACTUAL_VISIT_END_TIME_FIELD,
        INSPECTION_REASON_FIELD,
        ACCOUNT_FIELD,
        RECURRENCE_FIELD,
        OWNER_FIELD,
        VISITOR_FIELD,

        PIC_MIC_SIGNATURE,
        UNABLE_TO_INSPECT
        // CLOSED_DATE
    ];   

    nursingSchoolLicenseTypes = ['Practical Nursing Program', 'Associate Degree Nursing Program','Baccalaureate Degree Nursing Program'];

    @api
    set recordId(value) {
        this._recordId = value;
        this.checkContextIdCaseSobject();
    }
    get recordId() {
        return this._recordId;
    }
    get showClosedDate() {
        return this.boardName !== COSBAR_BOARD;
    }
    get showRemedialFields() {
        return this.boardName !== COSBAR_BOARD;
    }

    @wire(getRecord, { recordId: "$_recordId", fields })
    visitRecord;
    get isNursingSchoolLicenseType() {
        return this.nursingSchoolLicenseTypes.includes(getFieldValue(this.visitRecord.data, LICENSE_TYPE_FIELD)) ? true : false;
    }  
    get placeIdLink() {
        return '/' + this.placeId;
    }
    get businessNameLink() {
        return '/' + this.contextId;
    }

    checkContextIdCaseSobject(){
        checkContextIdCaseSobject({recordId : this._recordId})    
        .then( result => {
            if(typeof result.isCaseObj != 'undefined'){
                console.log('1111');
                console.log('TEST >> ' + JSON.stringify(result));
                this.isCaseObj = result.isCaseObj == 'true' ? true : false;
                this.contextId = result.contextId;
                this.placeId = result.placeId;
                this.businessName = result.businessName;
                this.boardName = result.boardName;
                this.placeName = result.addressName;
                this.disciplineVal = result.disciplineVal;
                this.dbaName = result.dbaName;
                console.log('this.dbaName'+this.dbaName);
                this.classification = result.classification;
                this.lastInspectionDate = result.lastInspectionDate;
            }else{
                console.log('222');
            }
        });
    }
    handleLoad(event){

    }
    connectedCallback() {
        loadStyle(this, LPI_InternalCSS + "/styles/internal-main.css");
    }
}