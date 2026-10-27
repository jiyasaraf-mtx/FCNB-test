/**
 * @description       : 
 * @author            : MTX Group Product Team
 * @group             : 
 * @last modified on  : 07-13-2024
 * @last modified by  : MTX Group Product Team
**/
public with sharing class LPI_VisitRegCodeViolationController {
    private static final String BUSINESSLICENSE_TEXT = 'BusinessLicense';
    private static final String BUSINESSLICENSEAPPLICATION_TEXT = 'BusinessLicenseApplication';
    private static final String ASSESSMENT_TASK_DEF_TO_CREATE_TXT = 'TO BE COMPLETED BY PHARMACIST-IN-CHARGE';
    private static final String INSPECTION_CHECKLIST_TASKTYPE = 'InspectionChecklist';
    private static final String NOT_STARTED_TXT = 'NotStarted';
    private static final String QUALITY_ASSURANCE_TEMPLATE = 'Quality Assurance Template';
    private static final String PHARMACY_LICENSE_TYPE = 'Pharmacy';
    private static final String COMPLETED_TEXT = 'Completed';
    private static final String PUBLIC_COMPLAINT_SOBJECT = 'PublicComplaint';


    

    /**
     * @author                      : MTX Group Product Team
     * @since                       : 6 Oct 2023
     * @description                 : Method is used to Send Portal Notification to the Associated Contact.
     * @param jsonData              : Used to pass Serialized JSON Data
     * @return                      : `List<Visit>`
     * @last modified by            : MTX Group Product Team
     * @last modified date          : 6 Oct 2023
     * @modified details            : Code Review Fixes
     * @modified details            : Refactoring Code 
     */
    @AuraEnabled 
    public static List<Visit> sendInspectionPortalNotification(String jsonData) {
        try {
            InspectionPortalNotifWrapper wrapperObj = (InspectionPortalNotifWrapper) JSON.deserializeStrict(jsonData, InspectionPortalNotifWrapper.class);
            List<String> fieldsToQuery = new List<String>{
                'Id','Name','VisitType.Name,Actual_Start_Date__c,Actual_End_Date__c,ContextId,Board_Name__c',
                '(SELECT ID,Name,SequenceNumber,TaskType,Status,Board_Name__c FROM AssessmentTasks ORDER BY SequenceNumber DESC LIMIT 1)',
                'TYPEOF Context WHEN BusinessLicense THEN Id, Name,RegulatoryAuthorizationType.Name,Contact.AccountId WHEN BusinessLicenseApplication THEN Id,Name,Applicant.AccountId WHEN Case THEN Id, CaseNumber, License_Number_Custom__c, License_Number_Custom__r.AccountId, License_Number_Custom__r.Name END',
                'VisitorId,Visitor.FirstName,Visitor.MiddleName,Visitor.LastName'
            };
            String whereClause = 'Id = \'' + String.escapeSingleQuotes(wrapperObj.recordId) + '\' AND ContextId!=NULL';
            
            List<Visit> visRecList =  new LPI_VisitControllerDAO.LPI_VisitControllerWithoutSharingDAO().getVisitListByDynamicQueryWithoutSharing(fieldsToQuery,whereClause,null,null,null);
            if(visRecList.isEmpty()) {
                return null;
            }
            Boolean isCreationValid =  wrapperObj.notifType?.equals('qualAssuranceReport');
            if(isCreationValid){
                String fields = 'AssessmentTaskDefinitionId, AssessmentIndDefinitionId,AssessmentIndDefinition.Name,AssessmentIndDefinition.DataType,AssessmentIndDefinition.Description,AssessmentIndDefinition.Question_Text__c,DisplayOrder';
                List<AssessmentTaskIndDefinition> astDefList = LPI_AssessmentTaskIndDefinitionDAO.getAssessmentTaskIndDefListByDynamicQuery(fields,'AssessmentTaskDefinition.Name = \''+ASSESSMENT_TASK_DEF_TO_CREATE_TXT+'\'',null,null,null);
                if(astDefList.isEmpty()) {
                    throw new LPI_Exception('Configuration Missing - '+ ASSESSMENT_TASK_DEF_TO_CREATE_TXT);
                }
                String sectionId = astDefList[0]?.AssessmentTaskDefinitionId;
                if(!visRecList[0].AssessmentTasks.isEmpty()) {
                    for(AssessmentTask astRec : visRecList[0].AssessmentTasks) {
                        if(astRec.Name?.equals(ASSESSMENT_TASK_DEF_TO_CREATE_TXT)) {
                            isCreationValid = false; 
                            break;
                        }
                    }
                }
                if(isCreationValid) {
                    createInspectionAssessmentInd(createAssessmentTask(visRecList,sectionId),astDefList);
                }
            }            
            sendPortalNotifHelper(wrapperObj.notifType,visRecList);
            return visRecList;
        }
        catch(Exception ex) {
            LPI_ExceptionManager.logException('LPI_VisitRegCodeViolationController', 'sendInspectionPortalNotification', ex);
            throw new LPI_Exception(ex.getMessage());
        }
    }
    
    /**
     * @author                      : MTX Group Product Team
     * @since                       : 6 Oct 2023
     * @description                 : Helper Method to Create Assessment Task.
     * @param jsonData              : Used to pass Serialized JSON Data
     * @return                      : `List<AssessmentTask>`
     * @last modified by            : MTX Group Product Team
     * @last modified date          : 6 Oct 2023
     * @modified details            : Code Review Fixes
     * @modified details            : Refactoring Code 
     */
    private static List<AssessmentTask> createAssessmentTask(List<Visit> visRecList,String assessmentTaskDefId) {
        try {
            List<AssessmentTask> astList = new List<AssessmentTask>();

            Integer seqNumber = visRecList[0].AssessmentTasks.isEmpty() ? 0 : visRecList[0].AssessmentTasks[0].SequenceNumber;            
            astList.add(new AssessmentTask(
                Board_Name__c = visRecList[0].Board_Name__c,
                SequenceNumber = seqNumber + 1,
                TaskType = INSPECTION_CHECKLIST_TASKTYPE,
                Status = NOT_STARTED_TXT,
                Name = ASSESSMENT_TASK_DEF_TO_CREATE_TXT,
                AssessmentTaskDefinitionId = assessmentTaskDefId,
                ParentId = visRecList[0].Id
            ));
            if(!astList.isEmpty()) {
                astList = (List<AssessmentTask>)LPI_DML.doInsert(astList);
            }
            return astList;
        } catch(Exception ex) {
            LPI_ExceptionManager.logException('LPI_VisitRegCodeViolationController', 'createAssessmentTask', ex);
            throw new LPI_Exception(ex.getMessage());
        }
    }
     /**
     * @author                      : MTX Group Product Team
     * @since                       : 6 Oct 2023
     * @description                 : Helper Method to Create Inspection Assessment Ind Details.
     * @param assessmentTaskList    : Assessment Task List Records.
     * @param astDefList            : AssessmentTaskIndDefinition List Records.
     * @return                      : `void`
     * @last modified by            : MTX Group Product Team
     * @last modified date          : 6 Oct 2023
     * @modified details            : Code Review Fixes
     * @modified details            : Refactoring Code 
     */
    private static void createInspectionAssessmentInd(List<AssessmentTask> assessmentTaskList,List<AssessmentTaskIndDefinition> astDefList) {
        try {
            if(assessmentTaskList.isEmpty() || astDefList.isEmpty()) {
                return;
            }
            Map<Id,Id> sectionIdToTaskIdMap = new Map<Id,Id>();
            for(AssessmentTask newTasks:assessmentTaskList) {
                sectionIdToTaskIdMap.put(newTasks.AssessmentTaskDefinitionId,newTasks.Id);
            }
            List<InspectionAssessmentInd> inspectionAssessmentIndList = new List<InspectionAssessmentInd>();
            for(AssessmentTaskIndDefinition astIndDefRec : astDefList) {
                if(sectionIdToTaskIdMap.containsKey(astIndDefRec.AssessmentTaskDefinitionId)) {
                    inspectionAssessmentIndList.add(new InspectionAssessmentInd(
                        AssessmentTaskId = sectionIdToTaskIdMap.get(astIndDefRec.AssessmentTaskDefinitionId),
                        DisplayOrder = astIndDefRec.DisplayOrder,
                        AssessmentIndDefinitionId = astIndDefRec.AssessmentIndDefinitionId
                    ));
                }
            }
            if(!inspectionAssessmentIndList.isEmpty()) {
                LPI_DML.doInsert(inspectionAssessmentIndList);
            }
        }
        catch(Exception ex) {
            LPI_ExceptionManager.logException('LPI_VisitRegCodeViolationController', 'createInspectionAssessmentInd', ex);
            throw new LPI_Exception(ex.getMessage());
        }
    }
   /**
     * @author                      : MTX Group Product Team
     * @since                       : 6 Oct 2023
     * @description                 : Helper Method to Send PortalNotification based on Configuration.
     * @param notifType             : Tells us which Notification Type User is willing to send.
     * @param visRecList            : Visit Record List.
     * @return                      : `void`
     * @last modified by            : MTX Group Product Team
     * @last modified date          : 6 Oct 2023
     * @modified details            : Code Review Fixes
     * @modified details            : Refactoring Code 
    */
    private static void sendPortalNotifHelper(String notifType,List<Visit> visRecList) {
        try {
            BusinessLicense bl;
            BusinessLicenseApplication bla;
            Case caseRec;
            Map<String,String> portalNotifiNameMap = new Map<String,String>{
                'inspectionRCV' => 'RCVComplianceNotice',
                'qualAssuranceReport' => 'QualityAssuranceReportMsg'
            };

            if(!portalNotifiNameMap.containsKey(notifType)) {
                throw new LPI_Exception('Invalid Option Selected');
            }

            List<Notification__c> portalNotificationToInsert = new List<Notification__c>();
            List<Portal_Notification_Message__mdt> portalNotiRec = LPI_CustomMetadataTypeDAO.getAllPortalNotificationByDeveloperNames(
                    new Set<String>{portalNotifiNameMap.get(notifType)}
            );
            if(portalNotiRec.isEmpty()) {
                    throw new LPI_Exception('Cannot Find Suitable Configuration.');
            }
            String urlRecordId = visRecList[0].ContextId;
            if(visRecList[0].Context instanceof Case) {
                // Inspection-violations portal page expects the Visit Id for Case-context inspections.
                urlRecordId = visRecList[0].Id;
            }
            Notification__c portalRec = LPI_ServiceUtility.createPortalNotificationRecord(
                portalNotiRec[0],
                false,
                null,
                new Map<String,String>{
                    'recordId' => urlRecordId
                },
                null 
            );
            portalRec.Inspection__c = visRecList[0].Id;
            if(visRecList[0].Context instanceof BusinessLicense) {
                    bl = (BusinessLicense) visRecList[0].Context;
                    portalRec.Business_License__c = bl.Id;
                    portalRec.Account__c = bl.Contact.AccountId;

            } else if(visRecList[0].Context instanceof BusinessLicenseApplication) {
                    bla = (BusinessLicenseApplication) visRecList[0].Context;
                    portalRec.Business_License_Application__c = bla.Id;
                    portalRec.Account__c = bla.Applicant.AccountId;
            } else if(visRecList[0].Context instanceof Case) {
                    caseRec = (Case) visRecList[0].Context;
                    portalRec.Case__c = caseRec.Id;
                    if(caseRec.License_Number_Custom__c == null) {
                        throw new LPI_Exception('Cannot find Business License on the related Case.');
                    }
                    portalRec.Business_License__c = caseRec.License_Number_Custom__c;
                    portalRec.Account__c = caseRec.License_Number_Custom__r != null
                        ? caseRec.License_Number_Custom__r.AccountId
                        : null;
            } else {
                throw new LPI_Exception('Unsupported Inspection Context. Expected Business License, Application, or Case.');
            }
            if(String.isBlank(portalRec.Account__c)) {
                    throw new LPI_Exception('Cannot Find Suitable Account');
            }
            portalNotificationToInsert.add(
                    portalRec
            );
            if(!portalNotificationToInsert.isEmpty()) {
                LPI_DML.doInsert(portalNotificationToInsert);
            }   

        } catch(Exception ex) {
            LPI_ExceptionManager.logException('LPI_VisitRegCodeViolationController', 'sendPortalNotifHelper', ex);
            throw new LPI_Exception(ex.getMessage());
        }
    }

    /**
     * @author                      : MTX Group Product Team
     * @since                       : 6 Oct 2023
     * @description                 : Helper Method to Fetch Inspection Details for Internal.
     * @param recordId              : Used to pass recordId
     * @return                      : `Map<String,Object>`
     * @last modified by            : MTX Group Product Team
     * @last modified date          : 6 Oct 2023
     * @modified details            : Code Review Fixes
     * @modified details            : Refactoring Code 
    */
    @AuraEnabled
    public static Map<String,Object> fetchInspectionDetailsInternal(String recordId) {
        try {
            if(String.isBlank(recordId)) {
                throw new LPI_Exception('Empty RecordId Found, Could not Fetch Details');
            }
            Map<String,Object> outMap = new Map<String,Object>();
            VisitWrapper visitWrapperObj = new VisitWrapper();
            List<String> fieldsToQuery = new List<String>{
                'Id','Name','Inspection_Forms__c','License_Type__c'
            };
            String whereClause = 'Id = \'' + String.escapeSingleQuotes(recordId) + '\'';
            for(Visit visitRec : new LPI_VisitControllerDAO.LPI_VisitControllerWithoutSharingDAO().getVisitListByDynamicQueryWithoutSharing(fieldsToQuery,whereClause,null,null,null)) {
                visitWrapperObj.visitId = visitRec.Id;
                visitWrapperObj.qualAssuranceApplicable = (visitRec.Inspection_Forms__c!=null ? (new Set<String>(visitRec.Inspection_Forms__c.split(';'))).contains(QUALITY_ASSURANCE_TEMPLATE) : false);
            }
            outMap.put('inspectionDetails',visitWrapperObj);
            return outMap;
        }
        catch(Exception ex) {
            LPI_ExceptionManager.logException('LPI_VisitRegCodeViolationController', 'fetchInspectionDetailsInternal', ex);
            throw new LPI_Exception(ex.getMessage());
        }
    }

    /**
     * @author                      : MTX Group Product Team
     * @since                       : 6 Oct 2023
     * @description                 : Helper Method to Fetch Visits Along with Related Violations.
     * @param recordId              : Used to pass RecordId.
     * @return                      : `Map<String,Object>`
     * @last modified by            : MTX Group Product Team
     * @last modified date          : 6 Oct 2023
     * @modified details            : Code Review Fixes
     * @modified details            : Refactoring Code 
    */
    @AuraEnabled 
    public static Map<String,Object> fetchVisitsViolationRecords(String recordId) {
        try {
            
            if(String.isBlank(recordId)) {
                return null;
            }
            String objectType = String.valueOf(Id.valueOf(recordId)?.getSObjectType());
            
            Map<String,Object> outMap = new Map<String,Object>();
            List<sObject> recordList = new List<sObject>(); 
           
            List<BusinessLicenseApplication> blaRecList = new List<BusinessLicenseApplication>();
            if(objectType == BUSINESSLICENSE_TEXT) {
                List<BusinessLicense> blRecList =new LPI_BusinessLicenseDAO.LPI_BusinessLicenseWithoutSharingDAO().getBusinessLicenseByDymanicQueryWithoutSecurity('Id,Name,Business_Entity_Name__c','Id =\''+String.escapeSingleQuotes(recordId)+'\'',null,null,null);
                
                outMap.put('title',blRecList[0]?.Name + '  -  '+ blRecList[0]?.Business_Entity_Name__c);
                recordList = blRecList;
            } 
            else if(objectType == BUSINESSLICENSEAPPLICATION_TEXT) {
                blaRecList = LPI_BusinessLicenseApplicationDAO.getBusinessLicenseApplicationByDymanicQuery('Id,Name,Business_Name__c','Id =\''+String.escapeSingleQuotes(recordId)+'\'',null,null,null);                    
                outMap.put('title',blaRecList[0]?.Name + '  -  '+ blaRecList[0]?.Business_Name__c);
                recordList = blaRecList;
            }
            
            if(recordList.isEmpty()) {
                throw new LPI_Exception('No Record Found, Or You do not have access to this record.');
            }
            List<String> fieldsToQuery = new List<String>{
                'Id','Name','VisitType.Name,Actual_Start_Date__c,Actual_End_Date__c,PIC_MIC_Signature__c,ContextId',
                '(SELECT Id,Start_Date__c,DateResolved,Name,Status,Licensee_Comments__c,Supervisor_Board_Staff_Comments__c,InspectionAssmntInd.Comments__c,RegulatoryCodeId,RegulatoryCode.Name,RegulatoryCode.Regulatory_Code_Description__c,ViolationType.Name FROM RegCodeInspection)',
                '(SELECT Id FROM AssessmentTasks WHERE Name = \'' + ASSESSMENT_TASK_DEF_TO_CREATE_TXT +'\')',
                'VisitorId,Visitor.FirstName,Visitor.MiddleName,Visitor.LastName'
            };
            String whereClause = 'ContextId = \'' + String.escapeSingleQuotes(recordId) + '\' AND VisitorId!=NULL AND Status__c=\''+ COMPLETED_TEXT +'\'';
            List<String> assessmentTaskIdList = new List<String>();

            Map<Id,VisitWrapper> visitIdToVisitWrapper = new Map<Id,VisitWrapper>();

            for(Visit visitRec : new LPI_VisitControllerDAO.LPI_VisitControllerWithoutSharingDAO().getVisitListByDynamicQueryWithoutSharing(fieldsToQuery,whereClause,null,'Name','DESC')) {
                List<RegulatoryCodeViolationWrapper> rcvList = new List<RegulatoryCodeViolationWrapper>();
                for(RegulatoryCodeViolation rcvRec : visitRec.RegCodeInspection) {
                    rcvList.add(new RegulatoryCodeViolationWrapper(
                        rcvRec.Id,
                        rcvRec.Name,
                        null,
                        rcvRec.ViolationType.Name,
                        (rcvRec.Start_Date__c!=null?rcvRec.Start_Date__c.format():null),
                        (rcvRec.DateResolved!=null?Date.newInstance(rcvRec.DateResolved.year(),rcvRec.DateResolved.month(),rcvRec.DateResolved.day()).format():null),
                        rcvRec.InspectionAssmntInd.Comments__c,
                        rcvRec.Licensee_Comments__c,
                        rcvRec.Supervisor_Board_Staff_Comments__c,
                        rcvRec.RegulatoryCode.Name,
                        rcvRec.RegulatoryCode.Regulatory_Code_Description__c
                    ));
                }
                VisitWrapper visitWrapObj = new VisitWrapper(
                    visitRec.Id,
                    null,
                    visitRec.Name,
                    visitRec.VisitType.Name,
                    rcvList,
                    (visitRec.Actual_End_Date__c!=null?visitRec.Actual_End_Date__c.format():null),
                    (visitRec.Actual_Start_Date__c!=null?visitRec.Actual_Start_Date__c.format():null),
                    (String.isNotBlank(visitRec.Visitor.FirstName)?visitRec.Visitor.FirstName:'') +
                    ' ' + (String.isNotBlank(visitRec.Visitor.MiddleName)?visitRec.Visitor.MiddleName:'') +
                    ' ' + (String.isNotBlank(visitRec.Visitor.LastName)?visitRec.Visitor.LastName:''),
                    visitRec.PIC_MIC_Signature__c
                );
                visitWrapObj.assessmentTaskId = (!visitRec.AssessmentTasks.isEmpty() ?visitRec.AssessmentTasks[0].Id: null);
                if(String.isNotBlank(visitWrapObj.assessmentTaskId)) {
                    assessmentTaskIdList.add(visitWrapObj.assessmentTaskId);
                }
                visitIdToVisitWrapper.put(visitRec.Id,visitWrapObj);
            }
            Map<Id,List<LPI_Wrapper.AssessmentTaskWrapper>> resultMap = LPI_AssessmentTaskController.getInspectionQuestionsList(assessmentTaskIdList);
            if(resultMap != null && !resultMap.isEmpty()) {
                for(Id visitId : resultMap.keySet()) {
                    if(visitIdToVisitWrapper.containsKey(visitId)) {
                        visitIdToVisitWrapper.get(visitId).inspectionAssessmentQuestions = resultMap.get(visitId);
                    }
                }
            }
            outMap.put('inspectionList',visitIdToVisitWrapper.values());
            return outMap;
        }
        catch(Exception ex) {
            LPI_ExceptionManager.logException('LPI_VisitRegCodeViolationController', 'fetchVisitsViolationRecords', ex);
            throw new LPI_Exception(ex.getMessage());
        }
    }
    /**
     * @author                      : MTX Group Product Team
     * @since                       : 18 Oct 2023
     * @description                 : Helper Method to fetch Task records for logged user
     * @param recordId              : Used to pass RecordId.
     * @return                      : `List<Task>`
     * @last modified by            : MTX Group Product Team
     * @last modified date          : 04-01-2023
     * @modified details            : 
     * @modified details            : 
    */
    @AuraEnabled
    public static Map<String,Map<Id,Object>> fetchTaskRecords(String accountId) {
        try{
            Map<String,Map<Id,Object>> combinedDataMap = new Map<String,Map<Id,Object>>();
            Set<String> accountIdSet = new Set<String>();
            for(Business_Relationships__c br : LPI_BusinessRelationshipDAO.fetchBusinessRelationshipRecords('Related_From__c','Related_From__c != NULL AND Related_To__c = \''+String.escapeSingleQuotes(accountId )+ '\'',null,null,null)){
                accountIdSet.add(br.Related_From__c);
            }
            LPI_ViolationEnforcementActionDAO.LPI_DAO_ViolationEnfActionWithoutSecurity violationObj = new LPI_ViolationEnforcementActionDAO.LPI_DAO_ViolationEnfActionWithoutSecurity();
            String whereClause ='Violation.Board_Name__c != null AND (Violation.Case__r.AccountId = \''+ String.escapeSingleQuotes(accountId)+  '\'';
            whereClause = accountIdSet.isEmpty() ? whereClause   + ' )' : whereClause +' OR Violation.Inspection.AccountId IN  ' + LPI_ServiceUtility.getStringValuesByStringSet(accountIdSet) + ' )';
            List<ViolationEnforcementAction> violationEnforcementActionList = violationObj.fetchViolationEnforcementActionRecords(
                'id,Violation.Board_Name__c,Violation.Case__r.AccountId,Violation.Case__r.Subject,Violation.Case__c,Violation.Case__r.Account.Social_Security_Number__c,Violation.Case__r.Business_License_Id__c,Violation.Case__r.Case_Number__c,Violation.Case__r.Account.IsPersonAccount,Violation.Case__r.Account.Name,Violation.Case__r.Account.FirstName,Violation.Case__r.Account.LastName,Violation.Case__r.Account.MiddleName,Violation.Case__r.Account.Suffix,Violation.Inspection.Name,Violation.InspectionId',
                whereClause,
                null,null
            );
            if(violationEnforcementActionList.isEmpty()){
                return null;
            }
            Set<Id> caseIdSet = new Set<Id>();
            Set<Id> caseBusinessIdSet = new Set<Id>();
            Set<Id> inspectionIdSet = new Set<Id>();
            Map<Id,ViolationEnforcementAction> vEAMap = new Map<Id,ViolationEnforcementAction>();
            Set<String> boardNameSet = new Set<String>();
            for(ViolationEnforcementAction veaRec : violationEnforcementActionList){
                boardNameSet.add(veaRec.Violation.Board_Name__c);
                vEAMap.put(veaRec.Id,veaRec);
                if(String.isNotBlank(veaRec.Violation.Case__r.Business_License_Id__c)){
                    caseBusinessIdSet.add(veaRec.Violation.Case__r.Business_License_Id__c);
                }
                if(String.isNotBlank(veaRec.Violation.InspectionId)){
                    inspectionIdSet.add(veaRec.Violation.InspectionId);
                }
                if(String.isNotBlank(veaRec.Violation.Case__c)){
                    caseIdSet.add(veaRec.Violation.Case__c);
                }
            }
            Map<Id,ComplaintCase> caseIdToComplaintCase = new Map<Id,ComplaintCase>();
            if(!caseIdSet.isEmpty()){
                for(ComplaintCase cs : new LPI_ComplaintCaseDao.LPI_ComplaintCaseWithoutSharingDAO().getCompCaseByDymanicQueryWithoutSecurityEnforced('PublicComplaintId,PublicComplaint.Name,PublicComplaint.Complaint_Details__c,CaseId','CaseId IN ' +LPI_ServiceUtility.getStringValuesBySet(caseIdSet), null,null,null )){
                    caseIdToComplaintCase.put(cs.CaseId,cs);
                }
            }
            Map<Id,Visit> inspectionMap = new Map<Id,Visit>();
            if(!inspectionIdSet.isEmpty()){
                for(Visit v : new LPI_VisitControllerDAO.LPI_VisitControllerWithoutSharingDAO().getVisitListByDynamicQueryWithoutSharing(new List<String>{'Id,Inspection_ID__c,Business_Name__c,'
                +'Name,AccountId,ContextId,Actual_Start_Date__c,VisitType.Name,Board_Name__c,'
                +'TYPEOF Context WHEN BusinessLicense THEN Name,Account.Name,Legacy_License_Number__c,RegulatoryAuthorizationType.Profession_Code__c,contact.Account.firstName,contact.Account.LastName,contact.Account.MiddleName,contact.Account.Suffix,contact.Account.Social_Security_Number__c'
                +' WHEN BusinessLicenseApplication THEN Name,LicenseType.Profession_Code__c,Applicant.Account.FirstName,Applicant.Account.LastName,Applicant.Account.MiddleName,Applicant.Account.Suffix,Applicant.Account.Social_Security_Number__c'
                +' When Case THEN Account.Name,Business_License_Id__c,Account.IsPersonAccount,Account.FirstName,Account.LastName,Account.MiddleName,Account.Suffix,Account.Social_Security_Number__c,Case_Number__c,License_Number__c END'},'Id IN '+LPI_ServiceUtility.getStringValuesBySet(inspectionIdSet),null,null,null)){
                    inspectionMap.put(v.id,v);
                    if(v.Context instanceof Case){
                        Case c = v.Context;
                        if(String.isNotBlank(c.Business_License_Id__c)){
                            caseBusinessIdSet.add(c.Business_License_Id__c);
                        }
                    }
                }
            }
            Map<Id,BusinessLicense> bLMap = new Map<Id,BusinessLicense>();
            if(!caseBusinessIdSet.isEmpty()){
                for(BusinessLicense bl : new LPI_BusinessLicenseDAO.LPI_BusinessLicenseWithoutSharingDAO().getBusinessLicenseByDymanicQueryWithoutSecurity('Name,Business_Entity_Name__c,Business_Name__c,Pre_Licensure_Number__c,Legacy_License_Number__c,RegulatoryAuthorizationType.Profession_Code__c,RegulatoryAuthorizationType.Authorisation_Type__c,ContactId,Contact.Account.FirstName,contact.Account.LastName,contact.Account.Suffix,contact.Account.MiddleName,contact.Account.Social_Security_Number__c','Id IN '+LPI_ServiceUtility.getStringValuesBySet(caseBusinessIdSet),null,null,null)){
                    bLMap.put(bl.Id,bl);
                }
            }
            Date todayDate = Date.today();
            LPI_TaskDao.LPI_DAO_TaskWithoutSecurity taskDAOInstance = new LPI_TaskDao.LPI_DAO_TaskWithoutSecurity();
            Map<Id,TaskWrapper> idToTaskWrapper = new  Map<Id,TaskWrapper>();
            for(Task taskRecord : taskDAOInstance.fetchTaskRecords('Id,OwnerId,Owner.FirstName,Owner.LastName,subject,Action__c,ActivityDate,Status,Results__c,Date_Received__c,WhatId',
            'WhatId IN '+LPI_ServiceUtility.getStringValuesBySet(vEAMap.keySet()),
            null,
            'ActivityDate ASC'
            ))
            {
                TaskWrapper taskWrapperRec = new TaskWrapper();
                taskWrapperRec.documentDate = String.valueOf(String.valueOf(Date.today().month()).leftPad(2, '0') + '-' +String.valueOf(Date.today().day()).leftPad(2, '0')+ '-' + Date.today().year());
                
                if(String.isNotBlank(vEAMap.get(taskRecord.WhatId).Violation.Case__c) && caseIdToComplaintCase.containsKey(vEAMap.get(taskRecord.WhatId).Violation.Case__c )){
                    taskWrapperRec.description = String.isNotBlank(vEAMap.get(taskRecord.WhatId).Violation.Case__r.Account.Name) ? vEAMap.get(taskRecord.WhatId).Violation.Case__r.Account.Name.abbreviate(30) : '';
                    taskWrapperRec.numberValue = String.isNotBlank(vEAMap.get(taskRecord.WhatId).Violation.Case__r.Case_Number__c) ? vEAMap.get(taskRecord.WhatId).Violation.Case__r.Case_Number__c.abbreviate(10) : '';
                    taskWrapperRec.dateValue =  String.valueOf(Date.today().year() + '-' +String.valueOf(Date.today().month()).leftPad(2, '0') + '-' +String.valueOf(Date.today().day()).leftPad(2, '0'));
                    taskWrapperRec.scanDate =  String.valueOf(Date.today().year() + '-' +String.valueOf(Date.today().month()).leftPad(2, '0') + '-' +String.valueOf(Date.today().day()).leftPad(2, '0'));

                    Boolean accountDetailPoplated = false; 
                    if(vEAMap.get(taskRecord.WhatId).Violation.Case__r.Account.IsPersonAccount){
                        taskWrapperRec.entityName =  vEAMap.get(taskRecord.WhatId).Violation.Case__r.Account.IsPersonAccount ? 
                        vEAMap.get(taskRecord.WhatId).Violation.Case__r.Account.Name.length() > 70 ? vEAMap.get(taskRecord.WhatId).Violation.Case__r.Account.Name.substring(0,70) : vEAMap.get(taskRecord.WhatId).Violation.Case__r.Account.Name
                            : '' ;

                        Account accRec = vEAMap.get(taskRecord.WhatId).Violation.Case__r.Account;
                        accountDetailPoplated = true; 
                        populateAccountDetails(accRec, taskWrapperRec);
                    }

                    if(String.isNotBlank(vEAMap.get(taskRecord.WhatId).Violation.Case__r.Business_License_Id__c)){
                        BusinessLicense bl = bLMap.get(vEAMap.get(taskRecord.WhatId).Violation.Case__r.Business_License_Id__c);
                        taskWrapperRec.profCode = bl.RegulatoryAuthorizationType.Profession_Code__c;
                        taskWrapperRec.preLicenseNumber = String.isNotBlank(bl.Pre_Licensure_Number__c) ? bl.Pre_Licensure_Number__c.abbreviate(10) : '';
                        taskWrapperRec.licenseNumber = String.isNotBlank(bl.Legacy_License_Number__c) ? bl.Legacy_License_Number__c.abbreviate(12) : bl.Name;
                        taskWrapperRec.entityName = bl.RegulatoryAuthorizationType.Authorisation_Type__c == 'Business' ? bl.Business_Entity_Name__c.length () > 70 ? bl.Business_Entity_Name__c.substring(0,70) :  bl.Business_Entity_Name__c :  '';
                        if(bl.contact.Account != null && !accountDetailPoplated){
                            populateAccountDetails(bl.contact.Account, taskWrapperRec);
                        }
                    }
                
                    taskWrapperRec.flowName = 'complaint';
                }
                if(String.isNotBlank(vEAMap.get(taskRecord.WhatId).Violation.Case__c)){
                    taskWrapperRec.caseSubject = vEAMap.get(taskRecord.WhatId).Violation.Case__r.subject;
                }
                taskWrapperRec.boardName = vEAMap.get(taskRecord.WhatId).Violation.Board_Name__c.toLowerCase();
                idToTaskWrapper.put(taskRecord.Id,taskWrapperRec);
            }
            combinedDataMap.put('taskWrapList', idToTaskWrapper);
            return combinedDataMap;
        }catch (Exception e) {
            LPI_ExceptionManager.logException(
                'LPI_VisitRegCodeViolationController',
                'fetchTaskRecords',
                e
            );
            throw new LPI_Exception(e.getMessage());
        }
    }

    /**
    * @description 
    * @author MTX Group Product Team | 05-07-2024 
    * @param acc 
    * @param wrapper 
    **/
    public static void populateAccountDetails(Account acc,TaskWrapper wrapper){
        wrapper.firstName = acc.firstName;
        wrapper.lastName = acc.lastName;
        wrapper.middleName = acc.middleName;
        wrapper.suffixName = acc.suffix;
        wrapper.ssn = acc.Social_Security_Number__c;
    }

    /**
         * @author                      : MTX Group Product Team
         * @since                       : 08 Feb 2024
         * @description                 : Helper Method to fetch only Task records for logged user
         * @param recordId              : AccountId from current logged in user
         * @return                      : Map<String,object>
         * @last modified by            : MTX Group Product Team
         * @last modified date          : 09 Feb 2024
         * @modified details            : 
         * @modified details            : 
    */
    @AuraEnabled
    public static Map<String,object> fetchOnlyTaskRecords(String accountId) {
        try{
            Map<String,object> combinedDataMap = new Map<String,object>();
            Set<String> accountIdSet = new Set<String>();
            for(Business_Relationships__c br : LPI_BusinessRelationshipDAO.fetchBusinessRelationshipRecords('Related_From__c','Related_From__c != NULL AND Related_To__c = \''+String.escapeSingleQuotes(accountId )+ '\'',null,null,null)){
                accountIdSet.add(br.Related_From__c);
            }
            LPI_ViolationEnforcementActionDAO.LPI_DAO_ViolationEnfActionWithoutSecurity violationObj = new LPI_ViolationEnforcementActionDAO.LPI_DAO_ViolationEnfActionWithoutSecurity();
            String whereClause ='Violation.Board_Name__c != null AND (Violation.Case__r.AccountId = \''+ String.escapeSingleQuotes(accountId)+  '\'';
            whereClause = accountIdSet.isEmpty() ? whereClause   + ' )' : whereClause +' OR Violation.Inspection.AccountId IN  ' + LPI_ServiceUtility.getStringValuesByStringSet(accountIdSet) + ' )';
            List<ViolationEnforcementAction> violationEnforcementActionList = violationObj.fetchViolationEnforcementActionRecords(
                'id,Violation.Board_Name__c,Violation.Case__r.AccountId,Violation.Case__r.Subject,Violation.Case__c,Violation.Case__r.Account.Social_Security_Number__c,Violation.Case__r.Business_License_Id__c,Violation.Case__r.Case_Number__c,Violation.Case__r.Account.IsPersonAccount,Violation.Case__r.Account.Name,Violation.Case__r.Account.FirstName,Violation.Case__r.Account.LastName,Violation.Case__r.Account.MiddleName,Violation.Case__r.Account.Suffix,Violation.Inspection.Name,Violation.InspectionId',
                whereClause,
                null,null
            );
            if(violationEnforcementActionList.isEmpty()){
                return null;
            }
            Map<Id,ViolationEnforcementAction> vEAMap = new Map<Id,ViolationEnforcementAction>();
            for(ViolationEnforcementAction veaRec : violationEnforcementActionList){
                vEAMap.put(veaRec.Id,veaRec);
            }

            LPI_TaskDao.LPI_DAO_TaskWithoutSecurity taskDAOInstance = new LPI_TaskDao.LPI_DAO_TaskWithoutSecurity();
            Map<Id,TaskWrapper> idToTaskWrapper = new  Map<Id,TaskWrapper>();
            for(Task taskRecord : taskDAOInstance.fetchTaskRecords('Id,OwnerId,Owner.FirstName,Owner.LastName,subject,Action__c,ActivityDate,Status,Results__c,Date_Received__c,WhatId',
            'WhatId IN '+LPI_ServiceUtility.getStringValuesBySet(vEAMap.keySet()),
            null,
            'ActivityDate ASC'
            ))
            {
                TaskWrapper taskWrapperRec = new TaskWrapper();
                taskWrapperRec.taskId = taskRecord.Id;
                taskWrapperRec.taskDueDate =  taskRecord.ActivityDate?.format();
                taskWrapperRec.taskSubject = taskRecord.subject;
                taskWrapperRec.taskReceivedDate = taskRecord.Date_Received__c?.format();
                taskWrapperRec.taskResult = taskRecord.Results__c;
                taskWrapperRec.taskStatus = taskRecord.Status;
                taskWrapperRec.ownerId = taskRecord.OwnerId;
                taskWrapperRec.actionActivity = taskRecord.Action__c;
                taskWrapperRec.ownerName = taskRecord.Owner.FirstName +' '+ taskRecord.Owner.LastName;
                taskWrapperRec.documentDate = String.valueOf(String.valueOf(Date.today().month()).leftPad(2, '0') + '-' +String.valueOf(Date.today().day()).leftPad(2, '0')+ '-' + Date.today().year());
                
                if(String.isNotBlank(vEAMap.get(taskRecord.WhatId).Violation.Case__c)){
                    taskWrapperRec.caseSubject = vEAMap.get(taskRecord.WhatId).Violation.Case__r.subject;
                }
                taskWrapperRec.boardName = vEAMap.get(taskRecord.WhatId).Violation.Board_Name__c.toLowerCase();
                idToTaskWrapper.put(taskRecord.Id,taskWrapperRec);
            }
            if(!idToTaskWrapper.isEmpty()){
                for(Application_Document__c appDoc : LPI_ApplicationDocumentDAO.getApplicantDocumentByDymanicQuery('Id,File_Name__c,Onbase_Document_Id__c,Task_Id__c','Task_Id__c IN ' + LPI_ServiceUtility.getStringValuesBySet(idToTaskWrapper.keySet()),NULL,NULL,NULL)){
                    LPI_Wrapper.FileWrapper file = new  LPI_Wrapper.FileWrapper ();
                    file.fileName = appDoc.File_Name__c;
                    file.fileId = appDoc.Onbase_Document_Id__c;
                    file.parentRecId = appDoc.Id;
                    idToTaskWrapper.get(appDoc.Task_Id__c).filesList.add(file);
                }

            }
            combinedDataMap.put('taskWrapList', idToTaskWrapper.values());
            combinedDataMap.put('twoByTwoPhotoRecommendation',System.Label.TwoByTwoPhotoRecommendations);
            return combinedDataMap;
        
        }catch (Exception e) {
            LPI_ExceptionManager.logException(
                'LPI_VisitRegCodeViolationController',
                'fetchOnlyTaskRecords',
                e
            );
            throw new LPI_Exception(e.getMessage());
        }
    }

    /**  
    * @author                      : MTX Group Product Team
    * @since                       : 09 Feb 2024
    * @description                 : This method internaly calls createApplicationDocument to delegate application document creation logic.
    * @return                      : `void`
    * @last modified by            : MTX Group Product Team
    * @last modified date          : 09 Feb 2024
    * @modified details            : 
    */
    @AuraEnabled 
    public static Map<String,Object> createApplicationDocumentForTask(String accountId,String jsonData) {
        try {  
            LPI_OnBaseIntegrationController.OnbaseFileWrapper onbaseFileWrapperObj = (LPI_OnBaseIntegrationController.OnbaseFileWrapper) JSON.deserializeStrict(jsonData, LPI_OnBaseIntegrationController.OnbaseFileWrapper.class);
            List<Application_Document__c> appDocList = LPI_ApplicationDocumentDAO.getApplicantDocumentByDymanicQueryWithoutSecurity('ID,Onbase_Payload__c','Task_Id__c =\''+ String.escapeSingleQuotes(onbaseFileWrapperObj.lookupFieldId) + '\'','1',null,null);
            Id lookupFieldId = Id.valueOf(onbaseFileWrapperObj.lookupFieldId);
            if(!appDocList.isEmpty() && appDocList[0].Onbase_Payload__c != null) {
                onbaseFileWrapperObj.onbasePayload = appDocList[0].Onbase_Payload__c;
            } else {
                Map<String,Map<Id,Object>> mapOfOnBaseResponse = fetchTaskRecords(accountId);
                Map<Id,Object> taskWrapperRec = mapOfOnBaseResponse.get('taskWrapList');
                TaskWrapper wrapperRec = (TaskWrapper)taskWrapperRec.get(onbaseFileWrapperObj.lookupFieldId);
                LPI_OnBaseIntegrationController.ResponseWrapper respWrapper = new LPI_OnBaseIntegrationController.ResponseWrapper();
                respWrapper.documentDate = wrapperRec.documentDate;
                respWrapper.numberValue = wrapperRec.numberValue;
                respWrapper.description = wrapperRec.description;
                respWrapper.entityName = wrapperRec.entityName;
                respWrapper.dateValue = wrapperRec.dateValue;
                respWrapper.scanDate = wrapperRec.scanDate;
                respWrapper.inspectionDate = wrapperRec.inspectionDate;
                respWrapper.profCode = wrapperRec.profCode;
                respWrapper.licenseNumber = wrapperRec.licenseNumber;
                respWrapper.accountName = wrapperRec.accountName;
                respWrapper.programType = wrapperRec.programType;
                respWrapper.providerCode = wrapperRec.providerCode;
                respWrapper.dateValue = wrapperRec.dateValue;
                respWrapper.scanDate = wrapperRec.scanDate;
                respWrapper.flowName = wrapperRec.flowName;
                respWrapper.firstName = wrapperRec.firstName;
                respWrapper.lastName = wrapperRec.lastName;
                respWrapper.middleName = wrapperRec.middleName;
                respWrapper.suffixName = wrapperRec.suffixName;
                respWrapper.ssn = wrapperRec.ssn;
                respWrapper.boardName = wrapperRec.boardName;
                onbaseFileWrapperObj.onbasePayload = LPI_VisitRegCodeViolationController.populatePayloadGeneric(respWrapper);
            }
            return createApplicationDocument(JSON.serialize(onbaseFileWrapperObj));
        } 
        catch(Exception ex) {
            LPI_ExceptionManager.logException('LPI_VisitRegCodeViolationController', 'createApplicationDocumentForTask', ex);
            throw new AuraHandledException(ex.getMessage());
        }
    }

    /**
    * @description : Wrapper Class 
    * @author MTX Group Product Team | 02-08-2024 
    **/
    public class MainWrapper {
        String documentTypeId;
        String documentDate;
        KeyCollectionWrapper keywordCollection;
        public MainWrapper(){}
        public MainWrapper(String dti,KeyCollectionWrapper kc) {
            keywordCollection = kc;
            documentTypeId = dti;
           
        }
    }
    public class KeyCollectionWrapper {
        List<ItemWrapper> items;
        public KeyCollectionWrapper(List<ItemWrapper> itemList) {
            items =  itemList;
        }
    }

    public class ItemWrapper {
        List<KeyWordItemWrapper> keywords;
        public ItemWrapper(List<KeyWordItemWrapper> kwItemList) {
            this.keywords = kwItemList;
        }
    }
    public class KeyWordItemWrapper {
        public String typeId;
        List<Map<String,String>> values;
    }

     /**
    * @description : Generic Method to create payload. based on metadata and responseWrapper.
    * @author MTX Group Product Team | 02-08-2024
    * @param LPI_OnBaseIntegrationController.ResponseWrapper 
    **/
    public static String populatePayloadGeneric(LPI_OnBaseIntegrationController.ResponseWrapper wrapper) {
        try{
            if(wrapper == null || String.isBlank(wrapper.flowName) || String.isBlank(wrapper.boardName)) {
                throw new LPI_Exception('No Configuration Exists.');
            }
            Map<String,Object> responseValuesMap = (Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(wrapper));
            Map<String,Object> onbaseMetadataMap = new Map<String,Object>();
            MainWrapper resultJsonData = new MainWrapper();
            
            for(LPI_Onbase_Configuration__mdt onbaseConfig  : LPI_OnBaseIntegrationController.getOnbaseConfigMetadata(new List<String>{
                wrapper.boardName
            },new List<String>{
                wrapper.flowName
            })){
                onbaseMetadataMap = (Map<String,Object>)JSON.deserializeUntyped(onbaseConfig.Payload__c);
                break;
            }
            if(onbaseMetadataMap == null) {
                throw new LPI_Exception('No Metadata Configuration Exists with this Combination!');
            }
            if(onbaseMetadataMap.containsKey('keywordCollection')) {
                Map<String,Object> kwCollectionMap = (Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(onbaseMetadataMap.get('keywordCollection')));

                List<Object> itemsList = (List<Object>) kwCollectionMap.get('items');
                if(itemsList.isEmpty()) {
                    throw new LPI_Exception('Incorrect Metadata.');
                }
                Map<String,Object> kwl = (Map<String,Object>)itemsList[0];
                List<Object> keywordList = kwl.containsKey('keywords') ? (List<Object>)kwl.get('keywords'): new List<Object>();
                List<KeyWordItemWrapper> kwValList = new List<KeyWordItemWrapper>();
                for(Object keyWord : keywordList) {
                    KeyWordItemWrapper kwVal = (KeyWordItemWrapper) JSON.deserialize(JSON.serialize(keyWord), KeyWordItemWrapper.class);
                    if(kwVal!=null && !kwVal.values.isEmpty() && kwVal.values[0].containsKey('value')) {
                            String paramValue = kwVal.values[0].get('value');
                            kwVal.values[0].put('value', responseValuesMap.containsKey(paramValue) ? (String)responseValuesMap.get(paramValue) : '');
                    }     
                    kwValList.add(kwVal);       
                }
                ItemWrapper itemWrapper = new ItemWrapper(kwValList);
                KeyCollectionWrapper kcWrapper = new KeyCollectionWrapper(new List<ItemWrapper>{itemWrapper});
                resultJsonData = new MainWrapper((String)onbaseMetadataMap.get('documentTypeId'),kcWrapper);
                Date todayDate = Date.today();
                resultJsonData.documentDate =  String.format('{0}-{1}-{2}', new List<String>{
                    todayDate.month() < 10 ? '0' + String.valueOf(todayDate.month()) : String.valueOf(todayDate.month()),
                    todayDate.day() < 10 ? '0' + String.valueOf(todayDate.day()) : String.valueOf(todayDate.day()),
                    String.valueOf(todayDate.year())
                });
            }
            return JSON.serialize(resultJsonData);
        }
        catch(Exception ex) {
            LPI_ExceptionManager.logException('LPI_VisitRegCodeViolationController', 'populatePayloadGeneric', ex);
            throw new LPI_Exception(ex.getMessage());
        }
    }

    /**
    * @description : Method to create application document.
    * @author MTX Group Product Team | 10-23-2023 
    * @param jsonData 
    **/
    @AuraEnabled
    public static Map<String,Object> createApplicationDocument(String jsonData) {
        if(String.isBlank(jsonData)){
            return null;
        }
        Map<String,Object> responseMap = new  Map<String,Object> ();
        Request reqInfo = Request.getCurrent();
        String currentRequestId = reqInfo.getRequestId();
        Id inspectorId;
        LPI_OnBaseIntegrationController.OnbaseFileWrapper response = (LPI_OnBaseIntegrationController.OnbaseFileWrapper)JSON.deserializeStrict(jsonData, LPI_OnBaseIntegrationController.OnbaseFileWrapper.class);
        if(response.lookupFieldName=='Inspection_Assessment_Indicator__c'){
        inspectorId = [SELECT AssessmentTask.ParentId FROM InspectionAssessmentInd WHERE Id =: response.lookupFieldId].AssessmentTask.ParentId;
        }
        Application_Document__c appDoc = new Application_Document__c();
        appDoc.File_Name__c = response.fileName;
        appDoc.Document_Name__c = response.documentName;
        appDoc.Board_Name__c = response.boardName;
        appDoc.Upload_To_Onbase__c	= true;
        appDoc.Onbase_Payload__c = response.onbasePayload;
        appDoc.Request_Id__c = currentRequestId;
        if(inspectorId!=null){
        appDoc.Inspection__c = inspectorId;
        }
        appDoc.put(response.lookupFieldName,response.lookupFieldId);

        appDoc =  (Application_Document__c)LPI_WithoutSharingUtility.insertSObject(appDoc);
        responseMap.put('appDocId',appDoc.Id);
        responseMap.put('currentRequestId',currentRequestId);
        return responseMap;
    }

    /**
    * @description : Method to scan files and return the app doc list.
    * @author MTX Group Product Team | 02-01-2024 
    * @param jsonData 
    * @param recordId 
    * @return Map<String, object> 
    **/
    @AuraEnabled
    public static Map<String,object> getFileScanResult(String jsonData,String notiJsonData,String accountId){
        try {
            LPI_OnBaseIntegrationController.bypassOnbase(jsonData);

            LPI_OnBaseIntegrationController.OnbaseFileWrapper response = (LPI_OnBaseIntegrationController.OnbaseFileWrapper)JSON.deserializeStrict(notiJsonData, LPI_OnBaseIntegrationController.OnbaseFileWrapper.class);

            if(response.isSendNotification != null && response.isSendNotification && String.isNotBlank(notiJsonData)){
                List<Notification__c> portalNotificationToInsert = new List<Notification__c>();
                List<Portal_Notification_Message__mdt> notiRec = LPI_CustomMetadataTypeDAO.getAllPortalNotificationByDeveloperName(
                    'Task_File_Upload_Notification'
                );
                Map<String, String> replaceBellTextMap = new Map<String, String>{
                    '[Case_Number]' => String.isNotBlank(response.caseNumber) ? response.caseNumber : '',
                    '[Portal_User]' => String.isNotBlank(response.portalUserName) ? response.portalUserName : '',
                    '[Task_Activity]' => String.isNotBlank(response.activeActivity) ? response.activeActivity : '',
                    '[Task_Status]' => String.isNotBlank(response.status) ? response.status : '',
                    '[Activity_Due]' => String.isNotBlank(response.dueDate) ? response.dueDate : '',
                    '[Case_Subject]' => String.isNotBlank(response.caseSubject) ? response.caseSubject : '',
                    '[Assigned_To_User]' => String.isNotBlank(response.ownerName) ? response.ownerName : ''
                };
                if(!notiRec.isEmpty()) {
                    portalNotificationToInsert.add(
                        LPI_ServiceUtility.createBellNotificationRecord(
                        notiRec[0],
                        true,
                        replaceBellTextMap,
                        response.ownerId,
                        response.lookupFieldId
                        )   
                    );
                }
                if (!portalNotificationToInsert.isEmpty()) {
                    LPI_WithoutSharingUtility.insertSObjectList(portalNotificationToInsert);
                }
            }

            return fetchOnlyTaskRecords(accountId);
        } catch (Exception e) {
            LPI_ExceptionManager.logException(
                'ApplicationDocumentReviewController',
                'scanFileAndReturnDocs',
                e
            );
            throw new LPI_Exception(e.getMessage());
        }
    }

    public class CommentsWrapper {
        @AuraEnabled
       public List<RegulatoryCodeViolationWrapper> licenseeCommentsDataList;
        @AuraEnabled
       public List<VisitWrapper> picCommentsDataList; 
    }

    /**
     * @author                      : MTX Group Product Team
     * @since                       : 6 Oct 2023
     * @description                 : Method to Save Comments submitted by Portal user for Visits RCV records.
     * @param commentsWrapper       : JSON seralised String
     * @return                      : `Boolean`
     * @last modified by            : MTX Group Product Team
     * @last modified date          : 6 Oct 2023
     * @modified details            : Code Review Fixes
     * @modified details            : Refactoring Code 
    */
    @AuraEnabled 
    public static Boolean saveComments(String commentsWrapper) {
        try {
            if(String.isBlank(commentsWrapper)) {
                return false;
            }
            CommentsWrapper commentsWrapperObj = (CommentsWrapper)JSON.deserializeStrict(commentsWrapper,CommentsWrapper.class);
            List<Visit> inspectionsToUpdate = new List<Visit>();
            List<RegulatoryCodeViolation> rcvListToUpdate = new List<RegulatoryCodeViolation>();
            if(!commentsWrapperObj.picCommentsDataList?.isEmpty()) {
                for(VisitWrapper commentRec : commentsWrapperObj.picCommentsDataList) {
                    inspectionsToUpdate.add(new Visit(
                        Id = commentRec.visitId,
                        PIC_MIC_Signature__c = commentRec.comments
                    ));
                }
            } 
            if(!commentsWrapperObj.licenseeCommentsDataList?.isEmpty()){
                for(RegulatoryCodeViolationWrapper commentRec : commentsWrapperObj.licenseeCommentsDataList) {
                    rcvListToUpdate.add(new RegulatoryCodeViolation(
                        Id = commentRec.rcvId,
                        Licensee_Comments__c = commentRec.comments
                    ));
                }
           }
           if(!inspectionsToUpdate.isEmpty()) {
                LPI_TriggerHandler.bypass('VisitTriggerHandler');
                if (LPI_TriggerHandler.isBypassed('VisitTriggerHandler')) {
                    inspectionsToUpdate = LPI_WithoutSharingUtility.updateSObjectList(inspectionsToUpdate);
                    LPI_TriggerHandler.clearBypass('VisitTriggerHandler');
                }
            }
            if(!rcvListToUpdate.isEmpty()) {
                rcvListToUpdate = LPI_WithoutSharingUtility.updateSObjectList(rcvListToUpdate);
            }
            return (!inspectionsToUpdate.isEmpty() || !rcvListToUpdate.isEmpty());
        }
        catch(Exception ex) {
            LPI_ExceptionManager.logException('LPI_VisitRegCodeViolationController', 'saveInspectionRCVComments', ex);
            throw new LPI_Exception(ex.getMessage());
        }
    }

    /**
    * @description Method to save replies of inspection questions from portal.
    * @author MTX Group Product Team | 05-07-2024 
    * @param jsonData 
    **/
    @AuraEnabled
    public static void handleSaveInspectionQues(String jsonData){
        try{
            LPI_AssessmentTaskController.handleSaveInspectionQues(jsonData);
        }
        catch(Exception ex) {
            LPI_ExceptionManager.logException('LPI_VisitRegCodeViolationController', 'handleSaveInspectionQues', ex);
            throw new LPI_Exception(ex.getMessage());
        }
       
    }

    public class VisitWrapper {
        @AuraEnabled
        public String visitId;
        @AuraEnabled
        public String idx;
        @AuraEnabled 
        public String visitName;
        @AuraEnabled 
        public String inspectionType;
        @AuraEnabled
        public List<RegulatoryCodeViolationWrapper> regCodeViolationList;
        @AuraEnabled 
        public String inspectionCompletedDate; 
        @AuraEnabled 
        public String inspectionStartDate;
        @AuraEnabled 
        public String inspectorName;
        @AuraEnabled 
        public String comments;
        @AuraEnabled 
        public Boolean qualAssuranceApplicable;
        @AuraEnabled 
        public String assessmentTaskId;
        @AuraEnabled 
        public List<LPI_Wrapper.AssessmentTaskWrapper> inspectionAssessmentQuestions;

        public VisitWrapper(){}
        public VisitWrapper(String visitId,String idx,String visitName,String inspectionType, 
                            List<RegulatoryCodeViolationWrapper> regCodeViolationList,String inspectionCompletedDate,String inspectionStartDate,String inspectorName,String comments) {
            this.visitId = visitId;
            this.idx=idx;
            this.visitName = visitName;
            this.inspectionType = inspectionType;
            this.regCodeViolationList = regCodeViolationList;
            this.inspectionCompletedDate = inspectionCompletedDate;
            this.inspectionStartDate = inspectionStartDate;
            this.inspectorName = inspectorName;
            this.comments = comments;
        }
    }

    public class RegulatoryCodeViolationWrapper {
        @AuraEnabled 
        public String rcvId;
        @AuraEnabled 
        public String rcvName;
        @AuraEnabled 
        public String visitId;
        @AuraEnabled 
        public String rcvType;
        @AuraEnabled 
        public String rcvStartDate;
        @AuraEnabled 
        public String rcvEndDate;
        @AuraEnabled 
        public String comments;
        @AuraEnabled 
        public String licenseeComments;
        @AuraEnabled 
        public String boardStaffComments;
        @AuraEnabled 
        public String regulatoryCode;
        @AuraEnabled 
        public String regulatoryCodeDesc;

        public RegulatoryCodeViolationWrapper() {}

        public RegulatoryCodeViolationWrapper(String rcvId,String rcvName,String visitId,String rcvType,
                                            String rcvStartDate,String rcvEndDate,String comments,String licenseeComments,
                                            String boardStaffComments, String regulatoryCode,String regulatoryCodeDesc) {
            this.rcvId = rcvId;
            this.rcvName = rcvName;
            this.visitId = visitId;
            this.rcvType = rcvType;
            this.rcvStartDate = rcvStartDate;
            this.rcvEndDate = rcvEndDate;
            this.comments = comments;
            this.licenseeComments = licenseeComments;
            this.boardStaffComments = boardStaffComments;
            this.regulatoryCode = regulatoryCode;
            this.regulatoryCodeDesc = regulatoryCodeDesc;
        }
    }

    public class TaskWrapper{
        @AuraEnabled 
        public String taskId;
        @AuraEnabled 
        public String taskDueDate;
        @AuraEnabled 
        public String taskSubject;
        @AuraEnabled 
        public String taskReceivedDate;
        @AuraEnabled 
        public String taskResult;
        @AuraEnabled 
        public String taskStatus;
        @AuraEnabled 
        public String description;
        @AuraEnabled 
        public String numberValue;
        @AuraEnabled 
        public String boardName;
        @AuraEnabled 
        public String documentDate;
        @AuraEnabled 
        public String flowName;
        @AuraEnabled 
        public String ownerName;
        @AuraEnabled 
        public String ownerId;
        @AuraEnabled 
        public String actionActivity;
        @AuraEnabled 
        public String caseSubject;
        @AuraEnabled 
        public String firstName;
        @AuraEnabled 
        public String middleName;
        @AuraEnabled 
        public String lastName;
        @AuraEnabled 
        public String suffixName;
        @AuraEnabled 
        public String entityName;
        @AuraEnabled 
        public String licenseNumber;
        @AuraEnabled 
        public String preLicenseNumber;
        @AuraEnabled 
        public String profCode;
        @AuraEnabled 
        public String ssn;
        @AuraEnabled 
        public String dateValue;
        @AuraEnabled 
        public String scanDate;
        @AuraEnabled
        public String inspectionDate;
        @AuraEnabled
        public String accountName;
        @AuraEnabled
        public String programType;
        @AuraEnabled
        public String providerCode;
        @AuraEnabled
        public List<LPI_Wrapper.FileWrapper> filesList = new List<LPI_Wrapper.FileWrapper>();

    }

    public class InspectionPortalNotifWrapper {
        @AuraEnabled
       public Id recordId;
        @AuraEnabled
       public String notifType; 
    }
}