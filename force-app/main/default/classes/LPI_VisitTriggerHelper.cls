/**
 * @description       : Helper class for VisitTriggerHandler.
 * @author            : MTX Group Product Team
 * @group             :
 * @last modified on  : 07-23-2024
 * @last modified by  : MTX Group Product Team
 **/

public with sharing class LPI_VisitTriggerHelper {

    public static final Map<String,String> CIU_BOARD_NAME_TO_QUEUE_NAME = new  Map<String,String>{
        'Embalmers & Funeral Directors' => 'Embalmers_FD_Inspectors_Queue'
    };
    
    public static final String CASE_SOBJECT = 'Case';
   
    private static final String USER_SOBJECT = 'User';
    public static final String CLOSED_STATUS = 'Closed';
    public static final List<String> REASON_LIST_TO_ADD_TASK = new List<String>{
        'Follow-up','Board Directed','Temp','Change of Location'
    };
    private static final String CLOSING_LETTER_REASON = 'Closing_Letter_For_Adming_Closing_Reason';
    private static final String OWNER_ROLE = 'Owner';
    private static final String UNAVAILABLE_EMAIL_INSPECTION = 'Unavailable_Email_Inspection';
	private static final String UNAVAILABLE_VALUE = 'Unavailable';
    private static final String VISIT_STATUS_INPROGRESS = 'InProgress';
    private static final String EVENT_STARTED = 'Started';
    private static final String EVENT_COMPLETED = 'Completed';
    private static final String INSPECTION_STARTED_EMAIL = 'Inspection_Started_For_Complaint';
    private static final String INSPECTION_COMPLETED_EMAIL = 'Inspection_Completed_For_Complaint';
    /** Final Action Plan Template for Case/Complaint Visits with no matching Inspection workflow. */
    private static final String UNLICENSED_COMPLAINT_APT_NAME = 'CA FCNB Complaint Ins APT latest';
    private static final String UNLICENSED_COMPLAINT_APT_NAME_LEGACY = 'CA FCNB Complaint Ins APT';
    private static final String APT_VERSION_STATUS_FINAL = 'Final';

 
    /**
    * @description : Method to handle validations on visit record.
    * @author MTX Group Product Team | 08-02-2023 
    * @param newList 
    * @param oldMap 
    **/
    public static void handleValidations(
        List<Visit> newList,
        Map<Id, Visit> oldMap
    ) {
        Map<Id, InspectionType> routineInspectionTypeMap = new Map<Id, InspectionType>(
            LPI_InspectionTypeDAO.getInspectionTypeRecords(
                'Id,Name',
                'Name = \'' +
                LPI_LiteralConstant.Inspection_Type_PRELIMINARY +
                '\'',
                null,
                null
            )
        );

        for (Visit visitRec : newList) {
            if (
                oldMap != null &&
                oldMap.get(visitRec.Id).Status__c ==
                CLOSED_STATUS
            ) {
                visitRec.addError(
                    'Record cannot be changed once the status is Closed.'
                );
            }
            
            if (
                visitRec.VisitTypeId != null && 
                routineInspectionTypeMap.containsKey(visitRec.VisitTypeId) 
                && (oldMap != null 
                && visitRec.PlannedVisitStartTime != oldMap.get(visitRec.Id).PlannedVisitStartTime
                && visitRec.PlannedVisitEndTime != oldMap.get(visitRec.Id).PlannedVisitEndTime)
            ) {
                Integer daysFromStart = (visitRec.PlannedVisitStartTime != null)
                    ? Integer.valueOf(
                          Date.today()
                              .daysBetween(
                                  visitRec.PlannedVisitStartTime.date()
                              )
                      )
                    : 0;
                Integer daysFromEnd = (visitRec.PlannedVisitEndTime != null)
                    ? Integer.valueOf(
                          Date.today()
                              .daysBetween(visitRec.PlannedVisitEndTime.date())
                      )
                    : 0;
                if ((daysFromStart > 14) || (daysFromEnd > 14)) {
                    visitRec.addError(
                        'The start or End dates should not exceed 14 days for preliminary inspections.'
                    );
                }
            }
        }
    }

    /**
     *   @author : MTX Group Product Team
     *   @since : 3rd Nov, 2022
     *   @description :This method is called after insert and it creates ActionPlan to Visit record after creation
     *   @param : List<Visit> visitRecords
     *   @return : void
     */
    public static void createActionPlansForVisit(List<Visit> visitRecords) {
        try {
            String fieldsToQuery;
            String whereClause;
            Map<String, String> inspectionAndBoardNameMap = new Map<String, String>();
            Map<String, List<String>> inspectionActionPlanTemplate = new Map<string, List<String>>();
            Map<String, String> inspectionActionPlanTemplateIdToName = new Map<String, String>();
            Map<Id, Id> actionPlantemplateVersionMap = new Map<Id, Id>();
            Map<String, String> inspectionNameMap = new Map<String, String>();
            List<ActionPlan> actionPlanListTobeAdded = new List<ActionPlan>();
            Set<String> ratIdSet = new Set<String>();
            Set<String> sobjectTypeToCreateActionPlans = new Set<String>{
                LPI_LiteralConstant.BUSINESSLICENSE_SOBJECT_API,
                LPI_LiteralConstant.BLA_SOBJECT_API,
                CASE_SOBJECT
            };
            Set<String> boardNamesToCreateActionPlan = new Set<String>{
                
                'Embalmers & Funeral Directors'
            };
            Set<String> boardNameSet = new Set<String>();
            Set<String> blIdSet = new Set<String>();
            Set<String> blaIdSet = new Set<String>();
            Map<Id, Id> visitIdToContextIdMap = new Map<Id, Id>();
            Set<String> visitTypeIdSet = new Set<String>();
            Set<String> licenseTypeNameSet = new Set<String>();
            Set<String> inspectionTemplateName = new Set<String>();
            List<Visit> unlicensedCaseComplaintVisits = new List<Visit>();
            for (Visit visit : visitRecords) {
                Boolean isCaseContext = String.isNotBlank(visit.ContextId)
                    && visit.ContextId.getSObjectType().getDescribe().getName() == CASE_SOBJECT;
                // Unlicensed complaint Cases have no License_Type; apply CA FCNB Complaint APT separately.
                if(isCaseContext && String.isBlank(visit.License_Type__c) && String.isNotBlank(visit.VisitTypeId)) {
                    unlicensedCaseComplaintVisits.add(visit);
                    continue;
                }
                // Case/complaint inspections create Action Plans from License Type + Visit Type workflow.
                // Do not block them on the Embalmers-only board allowlist used for BL/BLA scheduling.
                Boolean boardAllowed = boardNamesToCreateActionPlan.contains(visit.Board_Name__c)
                    || (isCaseContext && String.isNotBlank(visit.License_Type__c));
                if (
                    String.isBlank(visit.VisitTypeId) || ((String.isBlank(visit.ContextId) ||
                    !sobjectTypeToCreateActionPlans.contains(
                        visit.ContextId.getSObjectType().getDescribe().getName()))
                     && String.isBlank(visit.License_Type__c)) ||
                    !boardAllowed
                ) {
                    continue;
                }
                visitTypeIdSet.add(visit.VisitTypeId);
                
                if(String.isNotBlank(visit.License_Type__c)){
                    licenseTypeNameSet.add(visit.License_Type__c);
                }
                if(String.isNotBlank(visit.Inspection_Forms__c)){
                    inspectionTemplateName.addAll(visit.Inspection_Forms__c.split(';'));
                }

                if(String.isBlank(visit.ContextId)){
                    continue;
                }
                visitIdToContextIdMap.put(visit.Id, visit.ContextId);
                if (
                    visit.ContextId.getSObjectType().getDescribe().getName() ==
                    LPI_LiteralConstant.BLA_SOBJECT_API
                ) {
                    blaIdSet.add(visit.ContextId);
                }
                if (
                    visit.ContextId.getSObjectType().getDescribe().getName() ==
                    LPI_LiteralConstant.BUSINESSLICENSE_SOBJECT_API
                ) {
                    blIdSet.add(visit.ContextId);
                }
            }
            Map<Id, Id> contextIdToRatIdMap = new Map<Id, Id>();
            if (!blIdSet.isEmpty()) {
                fieldsToQuery = 'Id,RegulatoryAuthorizationTypeId';
                whereClause =
                    'ID IN  ' +
                    LPI_ServiceUtility.getStringValuesByStringSet(blIdSet);
                for (
                    BusinessLicense bl : LPI_BusinessLicenseDAO.fetchBusinessLicenseRecordsWithOrderByLimit(
                        fieldsToQuery,
                        whereClause,
                        null,
                        null
                    )
                ) {
                    contextIdToRatIdMap.put(
                        bl.Id,
                        bl.RegulatoryAuthorizationTypeId
                    );
                    ratIdSet.add(bl.RegulatoryAuthorizationTypeId);
                }
            }
            if (!blaIdSet.isEmpty()) {
                fieldsToQuery = 'Id,LicenseTypeId';
                whereClause =
                    'ID IN  ' +
                    LPI_ServiceUtility.getStringValuesByStringSet(blaIdSet);
                for (
                    BusinessLicenseApplication bla : LPI_BusinessLicenseApplicationDAO.getBusinessLicenseApplicationByDymanicQuery(
                        fieldsToQuery,
                        whereClause,
                        null,
                        null,
                        null
                    )
                ) {
                    contextIdToRatIdMap.put(bla.Id, bla.LicenseTypeId);
                    ratIdSet.add(bla.LicenseTypeId);
                }
            }
            // Unlicensed Case/Complaint Visits never populate visitTypeIdSet (they continue early).
            // Apply the configured Complaint Action Plan (all Assessment Tasks) before any early return.
            createUnlicensedComplaintActionPlans(unlicensedCaseComplaintVisits);
            if(visitTypeIdSet.isEmpty()){
                return;
            }
            fieldsToQuery = 'Id,Regulatory_Authorization_Type__r.Name, Inspection_Type__c, Inspection_Type__r.Name, Regulatory_Authorization_Type__c, Inspection_Action_Plan_Template__c,Inspection_Action_Plan_Template__r.Description';
            whereClause =
                'Inspection_Type__c IN ' +
                LPI_ServiceUtility.getStringValuesByStringSet(
                    visitTypeIdSet
                ) +
                ' AND RecordType.DeveloperName = \'' +
                LPI_LiteralConstant.INSPECTION_TEXT +
                '\' AND Inspection_Action_Plan_Template__c != NULL AND Inspection_Type__c != NULL AND ';
            if(!licenseTypeNameSet.isEmpty() && !ratIdSet.isEmpty()){
                whereClause += '(Regulatory_Authorization_Type__c IN' + LPI_ServiceUtility.getStringValuesByStringSet(ratIdSet)+ ' OR Regulatory_Authorization_Type__r.Name IN' +LPI_ServiceUtility.getStringValuesByStringSet(licenseTypeNameSet) + ')';
            }else if(!licenseTypeNameSet.isEmpty()) {
                whereClause += 'Regulatory_Authorization_Type__r.Name IN' +LPI_ServiceUtility.getStringValuesByStringSet(licenseTypeNameSet);
            }
            else if(!ratIdSet.isEmpty()) {
                whereClause += 'Regulatory_Authorization_Type__c IN' +LPI_ServiceUtility.getStringValuesByStringSet(ratIdSet);
            }

            if(!inspectionTemplateName.isEmpty()){
                whereClause += 'AND Inspection_Action_Plan_Template__r.Description IN' +LPI_ServiceUtility.getStringValuesByStringSet(inspectionTemplateName);
            }
            Map<String,String> ratNameToRatIdMap = new Map<String,String>();
            for (
                Regulatory_Auth_Type_WorkFlow__c rat : LPI_RegulatoryAuthTypeWorkFlowDAO.getRegAuthWorkflowRecs(
                    fieldsToQuery,
                    whereClause,
                    null,
                    null
                )
            ) {
                if(!inspectionActionPlanTemplate.containsKey( rat.Inspection_Type__c +'-'+rat.Regulatory_Authorization_Type__c)){
                    inspectionActionPlanTemplate.put(rat.Inspection_Type__c +'-'+rat.Regulatory_Authorization_Type__c,new List<String>());
                }
                inspectionActionPlanTemplate.get(rat.Inspection_Type__c +'-'+rat.Regulatory_Authorization_Type__c).add( rat.Inspection_Action_Plan_Template__c);
                inspectionNameMap.put(
                    rat.Inspection_Type__c,
                    rat.Inspection_Type__r.Name
                );
                inspectionActionPlanTemplateIdToName.put(rat.Inspection_Action_Plan_Template__c,rat.Inspection_Action_Plan_Template__r.Description);
                ratNameToRatIdMap.put(rat.Regulatory_Authorization_Type__r.Name,rat.Regulatory_Authorization_Type__c);
            }
            List<String> actionTemplateIdSet = new List<String>();
            for(String keystring : inspectionActionPlanTemplate.keySet()){
                actionTemplateIdSet.addAll(inspectionActionPlanTemplate.get(keystring));
            }
            // Case/Complaint Visits with License Type but no RAWF row must still get Complaint APT tasks.
            if (inspectionActionPlanTemplate.isEmpty()) {
                createUnlicensedComplaintActionPlans(
                    getCaseComplaintVisitsMissingActionPlans(visitRecords, new Set<Id>())
                );
                return;
            }
            fieldsToQuery = 'Id, Name, ActionPlanTemplateId';
            whereClause =
                'Status = \'' +
                String.escapeSingleQuotes(APT_VERSION_STATUS_FINAL) +
                '\' AND ActionPlanTemplateId IN ' +
                LPI_ServiceUtility.getStringValuesByList(
                    actionTemplateIdSet
                );
            for (
                ActionPlanTemplateVersion aptVersion : LPI_ActionPlanTemplateVersionDAO.getActionPlanTemplateVersion(
                    fieldsToQuery,
                    whereClause,
                    null,
                    null
                )
            ) {
                actionPlantemplateVersionMap.put(
                    aptVersion.ActionPlanTemplateId,
                    aptVersion.Id
                );
            }
            
            String searchTemplate;
            String ratId;
            Set<Id> visitsGettingActionPlans = new Set<Id>();
            Set<Id> allCandidateVisitIds = new Map<Id, Visit>(visitRecords).keySet();
            Set<Id> visitsAlreadyHavingPlans = new Set<Id>();
            for(ActionPlan existingPlan : [
                SELECT TargetId
                FROM ActionPlan
                WHERE TargetId IN :allCandidateVisitIds
            ]) {
                visitsAlreadyHavingPlans.add(existingPlan.TargetId);
            }
            for (Visit visit : visitRecords) {
                if(visitsAlreadyHavingPlans.contains(visit.Id)) {
                    visitsGettingActionPlans.add(visit.Id);
                    continue;
                }
                ratId = String.isNotBlank(visit.License_Type__c) ? ratNameToRatIdMap.get(visit.License_Type__c) : contextIdToRatIdMap.get(visitIdToContextIdMap.get(visit.Id));
                searchTemplate =
                    visit.VisitTypeId +
                    '-' +
                    ratId;
                if (!inspectionActionPlanTemplate.containsKey(searchTemplate) || inspectionActionPlanTemplate.get(searchTemplate) == null  ||  (inspectionNameMap.get(visit.VisitTypeId) == LPI_LiteralConstant.DELIVERY_METHOD_OTHER && !REASON_LIST_TO_ADD_TASK.contains(visit.Inspection_Reason__c))) {
                    continue;
                }
                for(String actiontemplateiD : inspectionActionPlanTemplate.get(searchTemplate)){
                    if(String.isNotBlank(visit.Inspection_Forms__c) && !visit.Inspection_Forms__c.split(';').contains(inspectionActionPlanTemplateIdToName.get(actiontemplateiD))){
                        continue;
                    }
                    Id aptVersionId = actionPlantemplateVersionMap.get(actiontemplateiD);
                    if(aptVersionId == null) {
                        continue;
                    }
                    DateTime dT = visit.PlannedVisitStartTime;
                    if(dT == null) {
                        continue;
                    }
                    Date actionPlanDate = date.newinstance(
                        dT.year(),
                        dT.month(),
                        dT.day()
                    );
                    ActionPlan aPlan = new ActionPlan();
                    aPlan.Name = inspectionActionPlanTemplateIdToName.get(actiontemplateId);
                    aPlan.ActionPlanTemplateVersionId = aptVersionId;
                    aPlan.TargetId = visit.Id;
                    aPlan.ActionPlanState = LPI_LiteralConstant.DD_NOT_STARTED_STATUS;
                    aPlan.StartDate = actionPlanDate;
                    aPlan.ActionPlanType = 'Retail';
                    aPlan.OwnerId = String.isNotBlank(visit.VisitorId) ? visit.VisitorId : UserInfo.getUserId();
                    actionPlanListTobeAdded.add(aPlan);
                    visitsGettingActionPlans.add(visit.Id);
                }
            }
            if(!actionPlanListTobeAdded.isEmpty()) {
                LPI_WithoutSharingUtility.insertSObjectList(actionPlanListTobeAdded);
                createMissingInspectionIndicatorsForVisits(visitsGettingActionPlans);
            }
            createUnlicensedComplaintActionPlans(
                getCaseComplaintVisitsMissingActionPlans(visitRecords, visitsGettingActionPlans)
            );
        } catch (Exception e) {
            LPI_ExceptionManager.logException(
                'VisitTriggerHelper',
                'createActionPlansForVisit',
                e
            );
        }
    }

    /**
     * When License Type / Visit Type is set after insert, create missing Action Plans for Case complaints.
     */
    public static void createActionPlansForVisitOnUpdate(List<Visit> newList, Map<Id, Visit> oldMap) {
        if(newList == null || newList.isEmpty() || oldMap == null) {
            return;
        }
        List<Visit> candidates = new List<Visit>();
        for(Visit visitRec : newList) {
            Visit oldRec = oldMap.get(visitRec.Id);
            if(oldRec == null) {
                continue;
            }
            Boolean isCaseContext = String.isNotBlank(visitRec.ContextId)
                && visitRec.ContextId.getSObjectType().getDescribe().getName() == CASE_SOBJECT;
            if(!isCaseContext || String.isBlank(visitRec.VisitTypeId)) {
                continue;
            }
            Boolean licenseTypeChanged = visitRec.License_Type__c != oldRec.License_Type__c;
            Boolean visitTypeChanged = visitRec.VisitTypeId != oldRec.VisitTypeId;
            if(!licenseTypeChanged && !visitTypeChanged) {
                continue;
            }
            candidates.add(visitRec);
        }
        if(candidates.isEmpty()) {
            return;
        }
        Set<Id> candidateIds = new Map<Id, Visit>(candidates).keySet();
        Set<Id> visitsWithActionPlans = new Set<Id>();
        for(ActionPlan existingPlan : [
            SELECT TargetId
            FROM ActionPlan
            WHERE TargetId IN :candidateIds
        ]) {
            visitsWithActionPlans.add(existingPlan.TargetId);
        }
        List<Visit> visitsNeedingPlans = new List<Visit>();
        for(Visit visitRec : candidates) {
            if(!visitsWithActionPlans.contains(visitRec.Id)) {
                visitsNeedingPlans.add(visitRec);
            }
        }
        if(!visitsNeedingPlans.isEmpty()) {
            createActionPlansForVisit(visitsNeedingPlans);
        }
    }

    /**
     * Case/Complaint Visits that did not receive an Action Plan from the RAWF path.
     */
    private static List<Visit> getCaseComplaintVisitsMissingActionPlans(
        List<Visit> visitRecords,
        Set<Id> visitsAlreadyGettingPlans
    ) {
        List<Visit> fallbackVisits = new List<Visit>();
        if(visitRecords == null || visitRecords.isEmpty()) {
            return fallbackVisits;
        }
        Set<Id> alreadyCovered = visitsAlreadyGettingPlans != null
            ? visitsAlreadyGettingPlans
            : new Set<Id>();
        for(Visit visitRec : visitRecords) {
            if(alreadyCovered.contains(visitRec.Id) || String.isBlank(visitRec.VisitTypeId)) {
                continue;
            }
            Boolean isCaseContext = String.isNotBlank(visitRec.ContextId)
                && visitRec.ContextId.getSObjectType().getDescribe().getName() == CASE_SOBJECT;
            if(isCaseContext) {
                fallbackVisits.add(visitRec);
            }
        }
        return fallbackVisits;
    }

    /**
     * Applies the Final CA FCNB Complaint Action Plan for Case/complaint Visits with no License Type
     * (or no matching Regulatory Auth Type Workflow).
     * The APT defines multiple Assessment Tasks (Complaint Details, Financial Services, Fraud, Party & Org).
     * Licensed complaint Visits continue to use Regulatory_Auth_Type_WorkFlow__c Action Plans when present.
     */
    private static void createUnlicensedComplaintActionPlans(List<Visit> visitRecords) {
        if(visitRecords == null || visitRecords.isEmpty()) {
            return;
        }
        try {
            Set<Id> visitTypeIds = new Set<Id>();
            for(Visit visitRec : visitRecords) {
                if(String.isNotBlank(visitRec.VisitTypeId)) {
                    visitTypeIds.add(visitRec.VisitTypeId);
                }
            }
            if(visitTypeIds.isEmpty()) {
                return;
            }
            Map<Id, String> visitTypeIdToName = new Map<Id, String>();
            for(InspectionType inspType : LPI_InspectionTypeDAO.getInspectionTypeRecords(
                'Id,Name',
                'Id IN ' + LPI_ServiceUtility.getStringValuesBySet(visitTypeIds),
                null,
                null
            )) {
                visitTypeIdToName.put(inspType.Id, inspType.Name);
            }
            List<ActionPlanTemplateVersion> aptVersions = LPI_ActionPlanTemplateVersionDAO.getActionPlanTemplateVersion(
                'Id, Name, ActionPlanTemplateId, ActionPlanTemplate.Name, ActionPlanTemplate.Description',
                'Status = \'' +
                    String.escapeSingleQuotes(APT_VERSION_STATUS_FINAL) +
                    '\' AND ActionPlanTemplate.Name = \'' +
                    String.escapeSingleQuotes(UNLICENSED_COMPLAINT_APT_NAME) +
                    '\'',
                '1',
                null
            );
            if(aptVersions.isEmpty()) {
                aptVersions = LPI_ActionPlanTemplateVersionDAO.getActionPlanTemplateVersion(
                    'Id, Name, ActionPlanTemplateId, ActionPlanTemplate.Name, ActionPlanTemplate.Description',
                    'Status = \'' +
                        String.escapeSingleQuotes(APT_VERSION_STATUS_FINAL) +
                        '\' AND ActionPlanTemplate.Name = \'' +
                        String.escapeSingleQuotes(UNLICENSED_COMPLAINT_APT_NAME_LEGACY) +
                        '\'',
                    '1',
                    null
                );
            }
            if(aptVersions.isEmpty()) {
                return;
            }
            Id aptVersionId = aptVersions[0].Id;
            String actionPlanName = String.isNotBlank(aptVersions[0].ActionPlanTemplate.Description)
                ? aptVersions[0].ActionPlanTemplate.Description
                : aptVersions[0].ActionPlanTemplate.Name;
            Set<Id> visitIds = new Map<Id, Visit>(visitRecords).keySet();
            Set<Id> visitsAlreadyHavingPlans = new Set<Id>();
            for(ActionPlan existingPlan : [
                SELECT TargetId
                FROM ActionPlan
                WHERE TargetId IN :visitIds
            ]) {
                visitsAlreadyHavingPlans.add(existingPlan.TargetId);
            }
            List<ActionPlan> actionPlansToInsert = new List<ActionPlan>();
            for(Visit visitRec : visitRecords) {
                if(visitsAlreadyHavingPlans.contains(visitRec.Id)) {
                    continue;
                }
                if(visitTypeIdToName.get(visitRec.VisitTypeId) != 'Complaint') {
                    continue;
                }
                Date actionPlanDate = visitRec.PlannedVisitStartTime != null
                    ? Date.newInstance(
                        visitRec.PlannedVisitStartTime.year(),
                        visitRec.PlannedVisitStartTime.month(),
                        visitRec.PlannedVisitStartTime.day()
                    )
                    : Date.today();
                ActionPlan aPlan = new ActionPlan();
                aPlan.Name = actionPlanName;
                aPlan.ActionPlanTemplateVersionId = aptVersionId;
                aPlan.TargetId = visitRec.Id;
                aPlan.ActionPlanState = LPI_LiteralConstant.DD_NOT_STARTED_STATUS;
                aPlan.StartDate = actionPlanDate;
                aPlan.ActionPlanType = 'Retail';
                aPlan.OwnerId = String.isNotBlank(visitRec.VisitorId)
                    ? visitRec.VisitorId
                    : UserInfo.getUserId();
                actionPlansToInsert.add(aPlan);
            }
            if(!actionPlansToInsert.isEmpty()) {
                LPI_WithoutSharingUtility.insertSObjectList(actionPlansToInsert);
                createMissingInspectionIndicatorsForVisits(
                    new Map<Id, Visit>(visitRecords).keySet()
                );
            }
        } catch (Exception e) {
            LPI_ExceptionManager.logException(
                'VisitTriggerHelper',
                'createUnlicensedComplaintActionPlans',
                e
            );
        }
    }

    /**
     * Action Plans create Assessment Tasks but may not create InspectionAssessmentInd rows.
     * Populate missing checklist indicators from AssessmentTaskIndDefinition.
     */
    private static void createMissingInspectionIndicatorsForVisits(Set<Id> visitIds) {
        if(visitIds == null || visitIds.isEmpty()) {
            return;
        }
        List<AssessmentTask> tasks = [
            SELECT Id, AssessmentTaskDefinitionId
            FROM AssessmentTask
            WHERE ParentId IN :visitIds
                AND TaskType = 'InspectionChecklist'
                AND AssessmentTaskDefinitionId != null
        ];
        if(tasks.isEmpty()) {
            return;
        }
        Set<Id> taskIds = new Map<Id, AssessmentTask>(tasks).keySet();
        Set<Id> tasksWithIndicators = new Set<Id>();
        for(AggregateResult ar : [
            SELECT AssessmentTaskId taskId
            FROM InspectionAssessmentInd
            WHERE AssessmentTaskId IN :taskIds
            GROUP BY AssessmentTaskId
        ]) {
            tasksWithIndicators.add((Id) ar.get('taskId'));
        }
        Set<Id> definitionIds = new Set<Id>();
        List<AssessmentTask> tasksNeedingIndicators = new List<AssessmentTask>();
        for(AssessmentTask taskRec : tasks) {
            if(!tasksWithIndicators.contains(taskRec.Id)) {
                tasksNeedingIndicators.add(taskRec);
                definitionIds.add(taskRec.AssessmentTaskDefinitionId);
            }
        }
        if(tasksNeedingIndicators.isEmpty() || definitionIds.isEmpty()) {
            return;
        }
        Map<Id, List<AssessmentTaskIndDefinition>> definitionToIndDefs =
            new Map<Id, List<AssessmentTaskIndDefinition>>();
        for(AssessmentTaskIndDefinition indDef :
            LPI_AssessmentTaskIndDefinitionDAO.getAssessmentTaskIndDefListByDynamicQuery(
                'Id,AssessmentTaskDefinitionId,AssessmentIndDefinitionId,DisplayOrder',
                'AssessmentTaskDefinitionId IN ' +
                    LPI_ServiceUtility.getStringValuesBySet(definitionIds),
                null,
                'DisplayOrder',
                'ASC'
            )
        ) {
            if(!definitionToIndDefs.containsKey(indDef.AssessmentTaskDefinitionId)) {
                definitionToIndDefs.put(
                    indDef.AssessmentTaskDefinitionId,
                    new List<AssessmentTaskIndDefinition>()
                );
            }
            definitionToIndDefs.get(indDef.AssessmentTaskDefinitionId).add(indDef);
        }
        List<InspectionAssessmentInd> indicatorsToInsert = new List<InspectionAssessmentInd>();
        for(AssessmentTask taskRec : tasksNeedingIndicators) {
            List<AssessmentTaskIndDefinition> indDefs =
                definitionToIndDefs.get(taskRec.AssessmentTaskDefinitionId);
            if(indDefs == null || indDefs.isEmpty()) {
                continue;
            }
            for(AssessmentTaskIndDefinition indDef : indDefs) {
                indicatorsToInsert.add(new InspectionAssessmentInd(
                    AssessmentTaskId = taskRec.Id,
                    AssessmentIndDefinitionId = indDef.AssessmentIndDefinitionId,
                    DisplayOrder = indDef.DisplayOrder
                ));
            }
        }
        if(!indicatorsToInsert.isEmpty()) {
            LPI_WithoutSharingUtility.insertSObjectList(indicatorsToInsert);
        }
    }


    /**
     * @author                      : MTX Group Product Team
     * @since                       : 28 Jul, 2023
     * @description                 : This method will update Visit ContextId's boardName on Visit record
     * @param recordsList           : Takes List of List<Visit>
     * @return                      : `void`
     * @last modified by            : MTX Group Product Team
     * @last modified date          :
     * @modified details            :
     */
    public static void updateBoardNameOnVisit(List<Visit> recordsList) {
        try {
            Set<Id> blaIdSet = new Set<Id>();
            Set<Id> blIdSet = new Set<Id>();
            Set<Id> caseIdSet = new Set<Id>();
            Map<Id, SObject> idToContextMap = new  Map<Id, SObject>();
            String fieldsToQuery;
            String whereClause;
            List<Visit> visitRecordsToProcess = new List<Visit>();
            List<Visit> adhocVisits = new List<Visit>();
            Set<String> licenseTypeSet = new Set<String>();
            for (Visit visit : recordsList) {
                if (String.isBlank(visit.ContextId) && String.isNotBlank(visit.License_Type__c)) {
                    adhocVisits.add(visit);
                    licenseTypeSet.add(visit.License_Type__c);
                    continue;
                }
                if(String.isBlank(visit.ContextId)){
                    continue;
                }
                if (visit.ContextId.getSObjectType().getDescribe().getName() ==
                    LPI_LiteralConstant.BLA_SOBJECT_API
                ) {
                    blaIdSet.add(visit.ContextId);
                    visitRecordsToProcess.add(visit);
                }
                else if (visit.ContextId.getSObjectType().getDescribe().getName() ==
                    LPI_LiteralConstant.BUSINESSLICENSE_SOBJECT_API
                ) {
                    blIdSet.add(visit.ContextId);
                    visitRecordsToProcess.add(visit);
                }
                else if (visit.ContextId.getSObjectType().getDescribe().getName() ==
                    CASE_SOBJECT
                ) {
                    caseIdSet.add(visit.ContextId);
                    visitRecordsToProcess.add(visit);
                }
            }
            if(licenseTypeSet.isEmpty() && blaIdSet.isEmpty() && blIdSet.isEmpty() && caseIdSet.isEmpty()){
                return;
            }
            if (!blIdSet.isEmpty()) {
                fieldsToQuery = 'Id,RegulatoryAuthorizationType.IssuingDepartment.Name,RegulatoryAuthorizationType.Name,Name';
                whereClause =
                    'ID IN  ' +
                    LPI_ServiceUtility.getStringValuesBySet(blIdSet);
                for (
                    BusinessLicense bl : LPI_BusinessLicenseDAO.fetchBusinessLicenseRecordsWithOrderByLimit(
                        fieldsToQuery,
                        whereClause,
                        null,
                        null
                    )
                ) {
                    idToContextMap.put(bl.Id,bl);
                }
            }
            if (!blaIdSet.isEmpty()) {
                fieldsToQuery = 'Id,Board_Name__c,LicenseType.Name,Name';
                whereClause =
                    'ID IN  ' +
                    LPI_ServiceUtility.getStringValuesBySet(blaIdSet);
                for (
                    BusinessLicenseApplication bla : LPI_BusinessLicenseApplicationDAO.getBusinessLicenseApplicationByDymanicQuery(
                        fieldsToQuery,
                        whereClause,
                        null,
                        null,
                        null
                    )
                ) {
                    idToContextMap.put(bla.Id,bla);
                }
            }
            if (!caseIdSet.isEmpty()) {
                fieldsToQuery = 'Id,Board_Name__c,License_Type__c,License_Number__c';
                whereClause =
                    'ID IN  ' +
                    LPI_ServiceUtility.getStringValuesBySet(caseIdSet);
                for (
                    Case caseRec : LPI_CaseDAO.getCaseRecords(
                        fieldsToQuery,
                        whereClause,
                        null,
                        null
                    )
                ) {
                    idToContextMap.put(caseRec.Id, caseRec);
                }
            }
            for (Visit visit : visitRecordstoProcess) {
                if (!idToContextMap.containsKey(visit.ContextId)) {
                    continue;
                   
                }if (
                    visit.ContextId.getSObjectType().getDescribe().getName() ==
                    LPI_LiteralConstant.BLA_SOBJECT_API
                ) {
                    visit.Board_Name__c = ((BusinessLicenseApplication)idToContextMap.get(
                        visit.ContextId
                    )).Board_Name__c;
                    visit.License_Type__c = ((BusinessLicenseApplication)idToContextMap.get(
                        visit.ContextId
                    )).LicenseType.Name;
                    visit.License_Application__c = ((BusinessLicenseApplication)idToContextMap.get(
                        visit.ContextId
                    )).Name;
                }
                else if (
                    visit.ContextId.getSObjectType().getDescribe().getName() ==
                    LPI_LiteralConstant.BUSINESSLICENSE_SOBJECT_API
                ) {
                    visit.Board_Name__c = ((BusinessLicense)idToContextMap.get(
                        visit.ContextId
                    )).RegulatoryAuthorizationType.IssuingDepartment.Name;
                    visit.License_Type__c = ((BusinessLicense)idToContextMap.get(
                        visit.ContextId
                    )).RegulatoryAuthorizationType.Name;
                    visit.License_Application__c = ((BusinessLicense)idToContextMap.get(
                        visit.ContextId
                    )).Name;
                }
                else if (
                    visit.ContextId.getSObjectType().getDescribe().getName() ==
                    CASE_SOBJECT
                ) {
                    Case caseRec = (Case)idToContextMap.get(visit.ContextId);
                    // Prefer values already set from the create modal (complaint may have blank Case board/license).
                    if(String.isBlank(visit.Board_Name__c)) {
                        visit.Board_Name__c = caseRec.Board_Name__c;
                    }
                    if(String.isBlank(visit.License_Type__c)) {
                        visit.License_Type__c = caseRec.License_Type__c;
                    }
                    visit.License_Application__c = caseRec.License_Number__c;
                    if(String.isNotBlank(visit.License_Type__c) && String.isBlank(visit.Board_Name__c)) {
                        licenseTypeSet.add(visit.License_Type__c);
                    }
                }
            }
            Map<String,String> licenseTypeToBoardName = new Map<String,String>();
            if(!licenseTypeSet.isEmpty()){
                fieldsToQuery = 'Id,Name,IssuingDepartment.Name';
                whereClause = 'NAME IN ' + LPI_ServiceUtility.getStringValuesByStringSet(licenseTypeSet);
                for(RegulatoryAuthorizationType ratRec : LPI_RegulatoryAuthorizationTypeDAO.getRegulatoryAuthorizationTypeByDymanicQuery(fieldsToQuery,whereClause,NULL,NULL,NULL)){
                    licenseTypeToBoardName.put(ratRec.Name,ratRec.IssuingDepartment.Name);
                }
            }
            for(Visit visitRec : adhocVisits){
                visitRec.Board_Name__c = licenseTypeToBoardName.get(visitRec.License_Type__c);
            }
            for(Visit visitRec : visitRecordsToProcess) {
                if(String.isBlank(visitRec.Board_Name__c) && String.isNotBlank(visitRec.License_Type__c)
                    && licenseTypeToBoardName.containsKey(visitRec.License_Type__c)) {
                    visitRec.Board_Name__c = licenseTypeToBoardName.get(visitRec.License_Type__c);
                }
            }

        } catch (Exception e) {
            LPI_ExceptionManager.logException(
                'VisitTriggerHelper',
                'updateBoardNameOnVisit',
                e
            );
        }
    }

    private static void populateMapDetails(Map<String,Set<Id>> mp,String key,Id currId) {
        Set<Id> v =  mp.containsKey(key) ? mp.get(key) : new Set<Id>();
        v.add(currId);
        mp.put(key,v);
    }
 
    private static final String VISIT_COMPLETED_STATUS = 'Completed';
    private static final String BUSINESS_LICENSE_SOBJECT = 'BusinessLicense';
    private static final String BLA_SOBJECT_NAME = 'BusinessLicenseApplication';

    public static void populateLastInspectionDateOnVisitContext(List<Visit> newList,Map<Id,Visit> oldMap) {

        Map<String,String> visitToContextMap = new Map<String,String>();
        Map<String,Boolean> contextToContainedMap = new Map<String,Boolean>();
        List<sObject> sObjectList = new List<sObject>();

        for(Visit visitRec : newList) {
            if(
                visitRec.Status__c == VISIT_COMPLETED_STATUS && 
                (oldMap==null || oldMap.get(visitRec.Id).Status__c!=visitRec.Status__c)
                ) {
                    String sObjectName = visitRec.ContextId?.getSObjectType().getDescribe().getName();
                    contextToContainedMap.put(sObjectName,true);
                    visitToContextMap.put(visitRec.Id,visitRec.ContextId);
                    if(sObjectName == BUSINESS_LICENSE_SOBJECT) {
                        sObjectList.add(new BusinessLicense(
                            Id = visitRec.ContextId,
                            Last_Inspection_Date__c = Date.today()
                        ));
                    }
                    if(sObjectName == BLA_SOBJECT_NAME) {
                        sObjectList.add(new BusinessLicenseApplication(
                            Id = visitRec.ContextId,
                            Last_Inspection_Date__c = Date.today()
                        ));
                    }
                    if(sObjectName == CASE_SOBJECT) {
                        sObjectList.add(new Case(
                            Id = visitRec.ContextId,
                            Last_Inspection_Date__c = Date.today()
                        ));
                    }
            }
        }
        if(!sObjectList.isEmpty()) {
            LPI_WithoutSharingUtility.updateSObjectList(sObjectList);
        }
    }


    /**
    * @description : Method to update Place and Entity Name 
    * @author MTX Group Product Team | 11-08-2023 
    * @param newlist 
    * @param oldMap 
    **/
    public static void updatePlaceAndEntityName(List<Visit> newList, Map<Id,Visit> oldMap) {
        try {
            String key;
            String sObjectName;
            String fields;
            String whereClause;
            Map<Id,sObject> contextIdToContextMap = new Map<Id,sObject>();
            Map<String,String> keyToIdMap = new Map<String,String>();
            Map<String,String> caseIdToBLIdMap = new Map<String,String>();
            Set<Id> visitIdSet = new Set<Id>();
            Set<Id> licenseIdSet = new Set<Id>();
            Boolean isBLA = false;
            Boolean isCase = false;
            Boolean isBL = false;
            Boolean isUser = false;
            Boolean isAddress = false;

            for(Visit visitRec : newList) {

                if(visitRec.PlaceId!=null && (oldMap == null || oldMap.get(visitRec.Id).PlaceId!=visitRec.PlaceId)) {
                    keyToIdMap.put(visitRec.Id+'-'+visitRec.PlaceId,visitRec.PlaceId);
                    isAddress = true;
                }
                if( visitRec.ContextId!=null && (oldMap == null || oldMap.get(visitRec.Id).ContextId!=visitRec.ContextId)) {
                    sObjectName = visitRec.ContextId.getSObjectType().getDescribe().getName();
                    isBLA = ( isBLA ? isBLA : sObjectName == LPI_LiteralConstant.BLA_SOBJECT_API);
                    isCase = (isCase ? isCase : sObjectName == CASE_SOBJECT);
                    isBL = (isBL ? isBL : sObjectName == LPI_LiteralConstant.BUSINESSLICENSE_SOBJECT_API);

                    keyToIdMap.put(visitRec.Id+'-'+visitRec.ContextId,visitRec.ContextId);

                    if(isBL) {
                        licenseIdSet.add(visitRec.ContextId);
                    }
                }
                if(visitRec.VisitorId!=null && (oldMap == null || oldMap.get(visitRec.Id).VisitorId!=visitRec.VisitorId)) {
                    sObjectName = visitRec.VisitorId.getSObjectType().getDescribe().getName();
                    if(sObjectName == USER_SOBJECT) {
                        isUser = true;
                        keyToIdMap.put(visitRec.Id,visitRec.VisitorId);
                    }
                }
                visitIdSet.add(visitRec.Id);
            }
            if(keyToIdMap.isEmpty()) {
                return;
            }
            if(isAddress) {
                fields = 'Id,ParentId,Parent.Name';
                whereClause = 'Id IN '+LPI_ServiceUtility.getStringValuesByList(keyToIdMap.values());
                for(Schema.Address addressRec : LPI_AddressDAO.getAddressByDymanicQuery(fields,whereClause,null,null,null)) {
                    contextIdToContextMap.put(addressRec.Id,addressRec);
                }
            } 
            if(isBLA) {
                fields = 'Id,Business_Name__c,Doing_Business_As_DBA_or_Trade_Name__c,LicensePermitName.Legacy_License_Number__c ,LicensePermitName.Name';
                whereClause = 'Id IN '+LPI_ServiceUtility.getStringValuesByList(keyToIdMap.values());
                for(BusinessLicenseApplication blaRec : LPI_BusinessLicenseApplicationDAO.getBusinessLicenseApplicationByDymanicQuery(fields,whereClause,null,null,null)) {
                    contextIdToContextMap.put(blaRec.Id,blaRec);
                }
            }
            if(isCase) {
                fields = 'Id,Business_License_Id__c';
                whereClause = 'Id IN '+LPI_ServiceUtility.getStringValuesByList(keyToIdMap.values());
                for(Case caseRec : LPI_CaseDAO.getCaseRecords(fields,whereClause,null,null)) {
                    if(String.isNotBlank(caseRec.Business_License_Id__c)) {
                        licenseIdSet.add(caseRec.Business_License_Id__c);
                        isBL = true;
                        caseIdToBLIdMap.put(caseRec.Id,caseRec.Business_License_Id__c);
                    }
                    contextIdToContextMap.put(caseRec.Id,caseRec);
                }
            }
            if(isBL) {
                fields = 'Id,Business_Entity_Name__c,Doing_Business_As_DBA_or_Trade_Name__c,Legacy_License_Number__c,Name';
                whereClause = 'Id IN '+LPI_ServiceUtility.getStringValuesBySet(licenseIdSet);
                for(BusinessLicense blRec : LPI_BusinessLicenseDAO.fetchBusinessLicenseRecords(fields,whereClause)) {
                    contextIdToContextMap.put(blRec.Id,blRec);
                }
            }
            if(isUser) {
                fields = 'Id,FirstName,MiddleName,LastName';
                whereClause = 'Id IN '+ LPI_ServiceUtility.getStringValuesByList(keyToIdMap.values());

                for(User userRec : new LPI_UserDao.LPI_UserWithoutSharingDAO().getUserByDymanicQuery(fields,whereClause,null,null,null)) {
                    contextIdToContextMap.put(userRec.Id,userRec);
                }
            }

            Map<Id,Visit> visitIdToVisitRecMap = new Map<Id,Visit>();

            for(String visitKey : keyToIdMap.keySet()) {

                String visitId = (visitKey.contains('-') ? visitKey.split('-')[0] : visitKey);
                Visit visitRec = (visitIdToVisitRecMap.containsKey(visitId) ? visitIdToVisitRecMap.get(visitId) : new Visit());
                
                visitRec.Id = visitId;
                String sObj = Id.valueOf(keyToIdMap.get(visitKey)).getSObjectType().getDescribe().getName();
                sObject recordVal = contextIdToContextMap.get(keyToIdMap.get(visitKey));
                if(sObj == 'Address') {
                    Schema.Address addressRec =  (Schema.Address) recordVal;
                    visitRec.Referred_Address__c = addressRec.Id;
                    visitRec.Location_Name__c = addressRec.Parent.Name;
                }
                else if(sObj == USER_SOBJECT) {
                    User userRec = (User) recordVal;
                    String inspectorNameFormed = (String.isNotBlank(userRec.FirstName)?userRec.FirstName:'') +
                    ' ' + (String.isNotBlank(userRec.MiddleName)?userRec.MiddleName:'') +
                    ' ' + (String.isNotBlank(userRec.LastName)?userRec.LastName:'');
                    visitRec.Inspector_Name__c = inspectorNameFormed;

                } else if(sObj == CASE_SOBJECT) {
                    if(caseIdToBLIdMap.containsKey(keyToIdMap.get(visitKey))) {
                        BusinessLicense blRec = (BusinessLicense) contextIdToContextMap.get(Id.valueOf(caseIdToBLIdMap.get(keyToIdMap.get(visitKey))));
                        visitRec.Business_Name__c = blRec.Business_Entity_Name__c;
                        visitRec.Doing_Business_As_DBA_or_Trade_Name__c = blRec.Doing_Business_As_DBA_or_Trade_Name__c;
                        
                        visitRec.License_Number__c = blRec.Legacy_License_Number__c != NULL ?blRec.Legacy_License_Number__c :blRec.Name;
                    }

                } else if(sObj == LPI_LiteralConstant.BLA_SOBJECT_API) {
                    BusinessLicenseApplication blaRec = (BusinessLicenseApplication) recordVal;
                    visitRec.Business_Name__c = blaRec.Business_Name__c;
                    visitRec.Doing_Business_As_DBA_or_Trade_Name__c = blaRec.Doing_Business_As_DBA_or_Trade_Name__c;
                   
                    visitRec.License_Number__c = blaRec.LicensePermitName.Legacy_License_Number__c != NULL ?  blaRec.LicensePermitName.Legacy_License_Number__c :blaRec.LicensePermitName.Name;
                } else if(sObj == LPI_LiteralConstant.BUSINESSLICENSE_SOBJECT_API) {
                    BusinessLicense blRec = (BusinessLicense) contextIdToContextMap.get(keyToIdMap.get(visitKey));
                    visitRec.Business_Name__c = blRec.Business_Entity_Name__c;
                    visitRec.Doing_Business_As_DBA_or_Trade_Name__c = blRec.Doing_Business_As_DBA_or_Trade_Name__c;
                    
                    visitRec.License_Number__c = blRec.Legacy_License_Number__c != NULL ?blRec.Legacy_License_Number__c :blRec.Name;
                }
                visitIdToVisitRecMap.put(visitId,visitRec);
            }

            if(!visitIdToVisitRecMap.isEmpty()) {
                LPI_TriggerHandler.bypass('VisitTriggerHandler');
                if (LPI_TriggerHandler.isBypassed('VisitTriggerHandler')) {
                    LPI_WithoutSharingUtility.updateSObjectList(visitIdToVisitRecMap.values());
                }
                LPI_TriggerHandler.clearBypass('VisitTriggerHandler');
            }

        }
        catch (Exception e) {
            LPI_ExceptionManager.logException(
                'VisitTriggerHelper',
                'updatePlaceAndEntityName',
                e
            );
        }
    }

    /**
    * @description : Update Status field on visit on update of Status__c.
    * @author MTX Group Product Team | 02-09-2024 
    * @param newList 
    * @param oldMap 
    **/
    public static void updateStatusField(List<Visit> newList,Map<Id,Visit> oldMap){
        try{
            Set<String> statusValuesToExcludeUpdate = new Set<String>{
                'Closed'
            };
            for(Visit visitRec : newList){
                if(!statusValuesToExcludeUpdate.contains(visitRec.Status__c) && visitRec.Status != visitRec.Status__c && (oldMap == NULL || oldMap.get(visitRec.Id).Status__c != visitRec.Status__c)){
                    visitRec.Status = visitRec.Status__c;
                }
                if((oldMap == NULL || oldMap.get(visitRec.Id).Status__c != visitRec.Status__c ) && visitRec.Status__c == VISIT_COMPLETED_STATUS){
                    visitRec.ActualVisitEndTime=datetime.now(); 
                }
            }
        }catch(Exception e){
            LPI_ExceptionManager.logException(
                'VisitTriggerHelper',
                'updateStatusField',
                e
            );
        }
        
    }
    /**
     * @author                      : MTX Group Product Team
     * @since                       : 06 Mar, 2024
     * @description                 : This method will send notifications to owners when visit sub reason updated to Adminstratively Closing
     * @param recordsList           : Takes List of List<Visit>
     * @param oldMap                : Takes Map of Map<Id, Visit>
     * @return                      : `void`
     * @last modified by            : MTX Group Product Team
     * @last modified date          :
     * @modified details            :
     */
    public static void sendEmailToOwnersForAdminClosingStatus(List<Visit> newList, Map<Id, Visit> oldMap){
        try{
            Map<Id, Visit> visitMap = new Map<Id, Visit>(newList);
            Set<Id> blIdSet = new Set<Id>();
            Set<Id> accIdSet = new Set<Id>();
            Set<Id> visitIdSet = new Set<Id>();
            Map<Id, Set<String>> blIdToAccIdMap = new Map<Id, Set<String>>();
            Map<Id, Id> locIdToBlIdMap = new Map<Id, Id>();
            Map<String, String> devNameToTemplateNameMap = new Map<String, String>();
            Map<Id, BusinessLicense> blIdtoBusinessLicenseMap = new Map<Id, BusinessLicense>();
            List<Notification__c> notificationsInserted = new List<Notification__c>();
            List<LPI_Wrapper.NotificationEmailWrapper> notificationEmailWrapperList = new List<LPI_Wrapper.NotificationEmailWrapper>();
            Map<String, Notification_Message__mdt> devNameToEmailNotifRecMap = new Map<String, Notification_Message__mdt>();
            
            for(Visit visRec : newList){
                if((oldMap == null || (oldMap != null && oldMap.get(visRec.Id).Sub_Reason__c != visRec.Sub_Reason__c)) && visRec.Sub_Reason__c == 'Administratively Closing'){
                    blIdSet.add(visRec.ContextId);
                    visitIdSet.add(visRec.Id);
                }
            }
            if(blIdSet.isEmpty()){
                return;
            }
            List<Notification_Message__mdt> notificationMessageList = LPI_CustomMetadataTypeDAO.getAllNotificationByDeveloperNames(
                new Set<String>{ CLOSING_LETTER_REASON }
            );
            for (Notification_Message__mdt noti : notificationMessageList) {
                devNameToTemplateNameMap.put(noti.DeveloperName, noti.Template_Name__c);
                devNameToEmailNotifRecMap.put(noti.DeveloperName, noti);
            }
            String fieldsToQuery = 'Id, Name, AccountId, RegulatoryAuthorizationType.Email_Specifications_Final__c, Account.Name';
            String whereClauseToQuery = 'Id IN ' + LPI_ServiceUtility.getStringValuesBySet(blIdSet);
            for(BusinessLicense blRec : new LPI_BusinessLicenseDAO.LPI_BusinessLicenseWithoutSharingDAO().getBusinessLicenseByDymanicQuery(fieldsToQuery, whereClauseToQuery, null, null, null)){
                accIdSet.add(blRec.AccountId);
                blIdtoBusinessLicenseMap.put(blRec.Id, blRec);
            }
            String busFieldsToQuery = 'Id, Related_To__c, Related_From__c, Related_To__r.PersonEmail, Related_To_License_Number__c,' +
            ' Related_From_License_Number__c, Related_To__r.Name, Related_From__r.Name, Related_From__r.Buisness_Email__c';
            String busWhereClauseToQuery =
                'Roles__c = \'' +
                OWNER_ROLE +
                '\' AND (Related_From__c IN ' +
                LPI_ServiceUtility.getStringValuesBySet(accIdSet) +
                ' OR Related_To__c IN ' +
                LPI_ServiceUtility.getStringValuesBySet(accIdSet) +
                ')';
            List<Business_Relationships__c> busRelList = new LPI_BusinessRelationshipDAO.LPI_BusinessRelationshipsWithoutSharingDAO()
                .getBusinessRelationshipsByDymanicQuery(busFieldsToQuery, busWhereClauseToQuery, null, null, null);
            for (Business_Relationships__c busRelRec : busRelList) {
                if (accIdSet.contains(busRelRec.Related_To__c)) {
                    if (
                        !blIdToAccIdMap.containsKey(busRelRec.Related_To_License_Number__c)
                    ) {
                        blIdToAccIdMap.put(
                            busRelRec.Related_To_License_Number__c,
                            new Set<String>()
                        );
                    }
                    blIdToAccIdMap.get(busRelRec.Related_To_License_Number__c).add(busRelRec.Related_From__r.Buisness_Email__c);
                } else if (accIdSet.contains(busRelRec.Related_From__c)) {
                    if (
                        !blIdToAccIdMap.containsKey(busRelRec.Related_From_License_Number__c)
                    ) {
                        blIdToAccIdMap.put(
                            busRelRec.Related_From_License_Number__c,
                            new Set<String>()
                        );
                    }
                    blIdToAccIdMap.get(busRelRec.Related_From_License_Number__c).add(busRelRec.Related_To__r.PersonEmail);
                }
            }
            
            String fields;
            String whereClause; 
            Map<Id, String> blToPrimaryAddMap =  getPrimaryAddressByLicenseId(blIdSet);
            String inspectionQueryFields = 'Id, ContextId, AccountId, Account.Name, Sub_Reason__c,' + 
            ' TYPEOF Visitor WHEN User THEN Email END';
            String inspectionWhereClause =
                'Id IN ' +
                LPI_ServiceUtility.getStringValuesBySet(visitIdSet);
            List<Visit> visitList = LPI_VisitControllerDAO.getVistListByDynamicQuery(
                new List<String>{ inspectionQueryFields },
                inspectionWhereClause,
                null,
                null,
                null
            );
            BusinessLicense blRec = new BusinessLicense();
            if(!blIdtoBusinessLicenseMap.isEmpty()){
                for(Visit visRec : visitList){
                    blRec = blIdtoBusinessLicenseMap.get(visRec.ContextId);
                    Map<String, String> replaceTextMap = new Map<String, String>();
                    Map<String, Object> boardSignatureMap = (Map<String, Object>) JSON.deserializeUntyped(
                        String.valueOf(blRec.RegulatoryAuthorizationType.Email_Specifications_Final__c)
                    );  
                    if(blIdToAccIdMap.get(visRec.ContextId) != null){
                        for(String emailId : blIdToAccIdMap.get(visRec.ContextId)){
                            replaceTextMap = new Map<String, String>{
                                'Board_Name' => String.isNotBlank((String) boardSignatureMap.get('boardName'))
                                    ? (String) boardSignatureMap.get('boardName')
                                    : '',
                                'Board_Email' => String.isNotBlank((String) boardSignatureMap.get('boardEmail'))
                                    ? (String) boardSignatureMap.get('boardEmail')
                                    : '',
                                'Board_PO_box' => String.isNotBlank((String) boardSignatureMap.get('boardPoBox'))
                                    ? (String) boardSignatureMap.get('boardPoBox')
                                    : '',
                                'Establishment_Name' => String.valueOf(visRec.Account.Name),
                                'License_Number' => blRec.Name,
                                'Business_Address' => blToPrimaryAddMap.get(visRec.ContextId)
                            };

                            String emailBody = devNameToEmailNotifRecMap.get(CLOSING_LETTER_REASON).Description__c;

                            if (replaceTextMap != null) {
                                for (String key : replaceTextMap.keySet()) {
                                    emailBody = emailBody.replaceAll('\\[' + key + '\\]', replaceTextMap.get(key));
                                }
                            }

                            LPI_Wrapper.NotificationEmailWrapper notifcationWrapper = new LPI_Wrapper.NotificationEmailWrapper();
                            notifcationWrapper.templateName = devNameToTemplateNameMap.get(CLOSING_LETTER_REASON);
                            notifcationWrapper.subject = devNameToEmailNotifRecMap.get(CLOSING_LETTER_REASON).Title__c;
                            notifcationWrapper.description = emailBody;

                            notifcationWrapper.replaceTextMap = replaceTextMap;
                            notifcationWrapper.accountId = visRec.AccountId;
                            notifcationWrapper.recipientEmail = emailId;
                            notifcationWrapper.ccAddresses = visRec.Visitor.Email;
                            notifcationWrapper.blId = visRec.ContextId;
                            notificationEmailWrapperList.add(notifcationWrapper);
                        }
                    }  
                }
            }
            if (!notificationEmailWrapperList.isEmpty()) {
                notificationsInserted.addAll(
                    (List<Notification__c>) LPI_ServiceUtility.createNotificationRecords(notificationEmailWrapperList)
                );
            }
        } catch(Exception e){
            LPI_ExceptionManager.logException(
                'VisitTriggerHelper',
                'sendEmailToOwnersForAdminClosingStatus',
                e
            );
        }
    }

    /**
    * @description : Send notification to owners on three consecutive unavaialble inspections.
    * @author MTX Group Product Team | 03-14-2024 
    * @param newList 
    * @param oldMap 
    **/
    public static void sendEmailOnUnavailableInspections(List<Visit> newList, Map<Id,Visit> oldMap){
        Set<Id> contextIds = new Set<Id>();
        Map<Id, Integer> idToCountMap = new Map<Id,Integer>();
        Map<Id,Visit> newMap = new Map<Id,Visit>(newList); 
        Map<Id,Id> blIdToInspectorId = new Map<Id,Id>();
        Map<String, Notification_Message__mdt> devNameToEmailNotifRecMap = new Map<String, Notification_Message__mdt>();
        for(Visit visitRec : newList){
            if(String.isNotBlank(visitRec.VisitorId) && String.isNotBlank(visitRec.ContextId) && String.valueOf((visitRec.ContextId).getSObjectType()) == 'Businesslicense' && visitRec.Final_Assessment_Result__c == UNAVAILABLE_VALUE &&(oldMap == NULL || visitRec.Final_Assessment_Result__c != oldMap.get(visitRec.Id).Final_Assessment_Result__c)){
                contextIds.add(visitRec.ContextId);
            }else{
                continue;
            }
            if(!idToCountMap.containsKey(visitRec.ContextId)){
                idToCountMap.put(visitRec.ContextId,0);
            }

            idToCountMap.put(visitRec.ContextId,idToCountMap.get(visitRec.ContextId) + 1);
            blIdToInspectorId.put(visitRec.ContextId,visitRec.VisitorId);
        }

        if(contextIds.isEmpty()){
            return;
        }
        String fields ='Id, ContextId, Final_Assessment_Result__c, Actual_Start_Date__c,' + ' TYPEOF Context when businesslicense THEN Id,AccountId,Account.Name,Name,RegulatoryAuthorizationType.IssuingDepartment.Phone__c,RegulatoryAuthorizationType.Email_Specifications_Final__c END';
        String whereClause =' ContextId IN ' +LPI_ServiceUtility.getStringValuesBySet(blIdToInspectorId.keySet()) +' AND ID NOT IN ' + LPI_ServiceUtility.getStringValuesBySet(newMap.keySet());
        Date todayDate = System.Label.LPI_CurrentDate == '0'? Date.today(): Date.valueOf(System.Label.LPI_CurrentDate);
        if(math.mod(todayDate.Year(),2) == 0){
            whereClause += ' AND Actual_Start_Date__c = THIS_YEAR';
        }else{
            whereClause += '  AND (Actual_Start_Date__c = THIS_YEAR OR Actual_Start_Date__c = LAST_YEAR)';
        }
        Map<Id,Id> contextIdToAccountIdMap = new Map<Id,Id>();
        Map<Id, BusinessLicense> blIdtoBusinessLicenseMap = new Map<Id, BusinessLicense>();
        for(Visit visitRec :  LPI_VisitControllerDAO.getVistListByDynamicQuery(new List<String>{ fields },whereClause,null,'Actual_Start_Date__c','DESC' )){
            if(!idToCountMap.containsKey(visitRec.ContextId)){
                continue;
            }
            if((visitRec.Final_Assessment_Result__c != UNAVAILABLE_VALUE && idToCountMap.get(visitRec.ContextId) <3) || (visitRec.Final_Assessment_Result__c == UNAVAILABLE_VALUE && idToCountMap.get(visitRec.ContextId) == 3)){
                idToCountMap.remove(visitRec.ContextId);
                contextIdToAccountIdMap.remove(visitRec.ContextId);
                blIdtoBusinessLicenseMap.remove(visitRec.ContextId);
                continue;
            }
            idToCountMap.put(visitRec.ContextId,idToCountMap.get(visitRec.ContextId) + 1);
            if(idToCountMap.get(visitRec.ContextId) > 2){
                BusinessLicense bl = visitRec.Context;
                contextIdToAccountIdMap.put(visitRec.ContextId,bl.AccountId);
                blIdtoBusinessLicenseMap.put(visitRec.ContextId,bl);
            }
        }
        if(contextIdToAccountIdMap.isEmpty()){
            return;
        }
		Map<Id, Set<String>> blIdToOwnerEmailMap = new Map<Id, Set<String>>();

        Map<Id,User> idToUserMap =  new Map<Id,User>(LPI_UserDao.getUserByDymanicQueryWithoutSecurityEnforced('Id,Email','ID IN '+ LPI_ServiceUtility.getStringValuesByList(blIdToInspectorId.values()),null,null,null));
       
        Map<String, String> blIdToAccIdMap = new Map<String, String>();
        fields ='Id, Related_To__c, Related_From__c, Related_To__r.PersonEmail, Related_To_License_Number__c, Ownership_Percent__c, Related_From_License_Number__c, Related_To__r.Name, Related_From__r.Name, Related_From__r.Buisness_Email__c';
		whereClause ='Roles__c = \'' +OWNER_ROLE +'\' AND (Related_From__c IN ' +LPI_ServiceUtility.getStringValuesByList(contextIdToAccountIdMap.values()) +' OR Related_To__c IN ' +LPI_ServiceUtility.getStringValuesByList(contextIdToAccountIdMap.values()) +') AND Ownership_Percent__c != null AND IsActive__c = true';
		List<Business_Relationships__c> busRelList = new LPI_BusinessRelationshipDAO.LPI_BusinessRelationshipsWithoutSharingDAO()
			.getBusinessRelationshipsByDymanicQuery(fields, whereClause, null, null, null);
		for (Business_Relationships__c busRelRec : busRelList) {
			if (contextIdToAccountIdMap.values().contains(busRelRec.Related_To__c)) {
				if (!blIdToAccIdMap.containsKey(busRelRec.Related_To_License_Number__c)) {
					blIdToAccIdMap.put(
						busRelRec.Related_To_License_Number__c,
						busRelRec.Related_From__r.Name + '-' + busRelRec.Ownership_Percent__c + '-' + busRelRec.Related_From__r.Buisness_Email__c
					);
					blIdToOwnerEmailMap.put(busRelRec.Related_To_License_Number__c, new Set<String>());
				}
				blIdToOwnerEmailMap.get(busRelRec.Related_To_License_Number__c).add(busRelRec.Related_From__r.Buisness_Email__c);
				if (
					Integer.valueOf(blIdToAccIdMap.get(busRelRec.Related_To_License_Number__c).split('-')[1]) <
					busRelRec.Ownership_Percent__c
				) {
					blIdToAccIdMap.put(
						busRelRec.Related_To_License_Number__c,
						busRelRec.Related_From__r.Name + '-' + busRelRec.Ownership_Percent__c + '-' + busRelRec.Related_From__r.Buisness_Email__c
					);
				} else {
					blIdToAccIdMap.put(
						busRelRec.Related_To_License_Number__c,
						blIdToAccIdMap.get(busRelRec.Related_To_License_Number__c)
					);
				}
			} else if (contextIdToAccountIdMap.values().contains(busRelRec.Related_From__c)) {
				if (!blIdToAccIdMap.containsKey(busRelRec.Related_From_License_Number__c)) {
					blIdToAccIdMap.put(
						busRelRec.Related_From_License_Number__c,
						busRelRec.Related_To__r.Name + '-' + busRelRec.Ownership_Percent__c + '-' + busRelRec.Related_To__r.PersonEmail
					);
					blIdToOwnerEmailMap.put(busRelRec.Related_From_License_Number__c, new Set<String>());
				}
				blIdToOwnerEmailMap.get(busRelRec.Related_From_License_Number__c).add(busRelRec.Related_To__r.PersonEmail);
				if (
					Integer.valueOf(blIdToAccIdMap.get(busRelRec.Related_From_License_Number__c).split('-')[1]) <
					busRelRec.Ownership_Percent__c
				) {
					blIdToAccIdMap.put(
						busRelRec.Related_From_License_Number__c,
						busRelRec.Related_To__r.Name + '-' + busRelRec.Ownership_Percent__c + '-' + busRelRec.Related_To__r.PersonEmail
					);
				} else {
					blIdToAccIdMap.put(
						busRelRec.Related_From_License_Number__c,
						blIdToAccIdMap.get(busRelRec.Related_From_License_Number__c)
					);
				}
			}
		}
        Map<Id, String> blToPrimaryAddMap =  getPrimaryAddressByLicenseId(contextIdToAccountIdMap.keySet());
		Map<String, String> devNameToTemplateNameMap = new Map<String, String>();
        List<LPI_Wrapper.NotificationEmailWrapper> notificationEmailWrapperList = new List<LPI_Wrapper.NotificationEmailWrapper>();
		List<Notification_Message__mdt> notificationMessageList = LPI_CustomMetadataTypeDAO.getAllNotificationByDeveloperNames(
			new Set<String>{ UNAVAILABLE_EMAIL_INSPECTION }
		);
		for (Notification_Message__mdt noti : notificationMessageList) {
			devNameToTemplateNameMap.put(noti.DeveloperName, noti.Template_Name__c);
            devNameToEmailNotifRecMap.put(noti.DeveloperName, noti);
		}
		for (String blId : blIdToAccIdMap.keySet()) {
			if (!blIdtoBusinessLicenseMap.containsKey(blId)) {
				continue;
			}
			BusinessLicense blRec = blIdtoBusinessLicenseMap.get(blId);
			Map<String, String> replaceTextMap = new Map<String, String>();
			Map<String, Object> boardSignatureMap = (Map<String, Object>) JSON.deserializeUntyped(
				String.valueOf(blRec.RegulatoryAuthorizationType.Email_Specifications_Final__c)
			);
			Set<String> inspecEmailList = new Set<String>();
			if(blIdToOwnerEmailMap.get(blId).remove(blIdToAccIdMap.get(blId).split('-')[2]) && !blIdToOwnerEmailMap.get(blId).isEmpty()){
				inspecEmailList.addAll(blIdToOwnerEmailMap.get(blId));
			}
            inspecEmailList.add(idToUserMap.get(blIdToInspectorId.get(blRec.Id)).Email);
			replaceTextMap = new Map<String, String>{
				'Board_PO_box' => String.isNotBlank((String) boardSignatureMap.get('boardPoBox'))
					? (String) boardSignatureMap.get('boardPoBox')
					: '',
				'Establishment_Name' => String.valueOf(blRec.Account.Name),
				'Owner_Name' => blIdToAccIdMap.get(blId).split('-')[0],
				'Business_Address' => blToPrimaryAddMap.get(blRec.Id),
				'Establishment_License_Number' => blRec.Name,
				'Inspector_Supervisor_Name' => System.Label.Unavailable_Inspector_Supervisor_Name,
				'Board_Phone_Number' => blRec.RegulatoryAuthorizationType.IssuingDepartment.Phone__c,
				'Inspector_Supervisor_Email' => String.isNotBlank((String) boardSignatureMap.get('boardEmail'))
					? (String) boardSignatureMap.get('boardEmail')
					: ''
			};

            String emailBody = devNameToEmailNotifRecMap.get(UNAVAILABLE_EMAIL_INSPECTION).Description__c;

            if (replaceTextMap != null) {
                for (String key : replaceTextMap.keySet()) {
                    emailBody = emailBody.replaceAll('\\[' + key + '\\]', replaceTextMap.get(key));
                }
            }

			LPI_Wrapper.NotificationEmailWrapper notifcationWrapper = new LPI_Wrapper.NotificationEmailWrapper();
			notifcationWrapper.templateName = devNameToTemplateNameMap.get(UNAVAILABLE_EMAIL_INSPECTION);

            notifcationWrapper.subject = devNameToEmailNotifRecMap.get(UNAVAILABLE_EMAIL_INSPECTION).Title__c;
            notifcationWrapper.description = emailBody;

			notifcationWrapper.replaceTextMap = replaceTextMap;
			notifcationWrapper.accountId = blRec.AccountId;
			notifcationWrapper.recipientEmail = blIdToAccIdMap.get(blId).split('-')[2];
			if (!inspecEmailList.isEmpty()) {
				notifcationWrapper.ccAddresses = String.join(new List<String>(inspecEmailList), ';');
			}
			notifcationWrapper.blId = blId;
			notificationEmailWrapperList.add(notifcationWrapper);
		}
		if (!notificationEmailWrapperList.isEmpty()) {
			LPI_ServiceUtility.createNotificationRecords(notificationEmailWrapperList);
		
		}
    }

    /**
     * @description Sends email notifications to the complainant when a complaint
     *              inspection (Visit with Case context) is started (InProgress) or completed.
     *              Uses Notification_Message__mdt templates and Notification__c so the
     *              existing notification trigger delivers the email.
     * @param newList Trigger.new Visit records
     * @param oldMap Trigger.oldMap (null on insert)
     */
    public static void createInspectionLifecycleNotifications(
        List<Visit> newList,
        Map<Id, Visit> oldMap
    ) {
        try {
            Map<Id, String> visitIdToEvent = new Map<Id, String>();
            for (Visit visitRec : newList) {
                String eventType;
                if (oldMap == null) {
                    if (visitRec.Status__c == VISIT_STATUS_INPROGRESS) {
                        eventType = EVENT_STARTED;
                    } else if (visitRec.Status__c == VISIT_COMPLETED_STATUS) {
                        eventType = EVENT_COMPLETED;
                    }
                } else {
                    Visit oldVisit = oldMap.get(visitRec.Id);
                    if (
                        oldVisit != null &&
                        oldVisit.Status__c != visitRec.Status__c
                    ) {
                        if (visitRec.Status__c == VISIT_STATUS_INPROGRESS) {
                            eventType = EVENT_STARTED;
                        } else if (visitRec.Status__c == VISIT_COMPLETED_STATUS) {
                            eventType = EVENT_COMPLETED;
                        }
                    }
                }
                if (String.isNotBlank(eventType)) {
                    visitIdToEvent.put(visitRec.Id, eventType);
                }
            }
            if (visitIdToEvent.isEmpty()) {
                return;
            }

            Map<String, Notification_Message__mdt> emailTemplateByDevName = new Map<String, Notification_Message__mdt>();
            for (
                Notification_Message__mdt noti : LPI_CustomMetadataTypeDAO.getAllNotificationByDeveloperNames(
                    new Set<String>{ INSPECTION_STARTED_EMAIL, INSPECTION_COMPLETED_EMAIL }
                )
            ) {
                emailTemplateByDevName.put(noti.DeveloperName, noti);
            }
            if (emailTemplateByDevName.isEmpty()) {
                return;
            }

            String inspectionQueryFields =
                'Id, Name, Status__c, AccountId, ContextId, ' +
                'TYPEOF Visitor WHEN User THEN Name, Email END, ' +
                'TYPEOF Context WHEN Case THEN Id, CaseNumber, ContactEmail, Contact.Name, AccountId END';
            String inspectionWhereClause =
                'Id IN ' +
                LPI_ServiceUtility.getStringValuesBySet(visitIdToEvent.keySet());
            List<Visit> visitList = LPI_VisitControllerDAO.getVistListByDynamicQuery(
                new List<String>{ inspectionQueryFields },
                inspectionWhereClause,
                null,
                null,
                null
            );
            if (visitList.isEmpty()) {
                return;
            }

            Set<Id> caseIdSet = new Set<Id>();
            for (Visit visitRec : visitList) {
                if (
                    visitRec.ContextId != null &&
                    String.valueOf(visitRec.ContextId.getSObjectType()) == CASE_SOBJECT
                ) {
                    caseIdSet.add(visitRec.ContextId);
                }
            }
            // Only complaint inspections (Case context linked to Public Complaint).
            if (caseIdSet.isEmpty()) {
                return;
            }

            Map<Id, ComplaintCase> caseIdToComplaintCase = new Map<Id, ComplaintCase>();
            for (
                ComplaintCase cs : new LPI_ComplaintCaseDao.LPI_ComplaintCaseWithoutSharingDAO()
                    .getCompCaseByDymanicQueryWithoutSecurityEnforced(
                        'CaseId, PublicComplaintId, PublicComplaint.Name, PublicComplaint.Email, ' +
                        'PublicComplaint.FirstName, PublicComplaint.LastName',
                        'CaseId IN ' +
                        LPI_ServiceUtility.getStringValuesBySet(caseIdSet) +
                        ' AND PublicComplaintId != null',
                        null,
                        null,
                        null
                    )
            ) {
                caseIdToComplaintCase.put(cs.CaseId, cs);
            }
            if (caseIdToComplaintCase.isEmpty()) {
                return;
            }

            List<LPI_Wrapper.NotificationEmailWrapper> notificationEmailWrapperList = new List<LPI_Wrapper.NotificationEmailWrapper>();
            for (Visit visitRec : visitList) {
                if (
                    !visitIdToEvent.containsKey(visitRec.Id) ||
                    visitRec.ContextId == null ||
                    !caseIdToComplaintCase.containsKey(visitRec.ContextId)
                ) {
                    continue;
                }

                ComplaintCase complaintCaseRec = caseIdToComplaintCase.get(visitRec.ContextId);
                PublicComplaint publicComplaint = complaintCaseRec.PublicComplaint;
                Case caseCtx = visitRec.Context != null ? (Case) visitRec.Context : null;

                String recipientEmail = publicComplaint != null ? publicComplaint.Email : null;
                if (String.isBlank(recipientEmail) && caseCtx != null) {
                    recipientEmail = caseCtx.ContactEmail;
                }
                if (String.isBlank(recipientEmail)) {
                    continue;
                }

                String eventType = visitIdToEvent.get(visitRec.Id);
                String mdtDevName = eventType == EVENT_STARTED
                    ? INSPECTION_STARTED_EMAIL
                    : INSPECTION_COMPLETED_EMAIL;
                if (!emailTemplateByDevName.containsKey(mdtDevName)) {
                    continue;
                }
                Notification_Message__mdt emailMdt = emailTemplateByDevName.get(mdtDevName);

                String complainantName = '';
                if (publicComplaint != null) {
                    if (
                        String.isNotBlank(publicComplaint.FirstName) ||
                        String.isNotBlank(publicComplaint.LastName)
                    ) {
                        complainantName = (
                            (String.isNotBlank(publicComplaint.FirstName)
                                ? publicComplaint.FirstName
                                : '') +
                            ' ' +
                            (String.isNotBlank(publicComplaint.LastName)
                                ? publicComplaint.LastName
                                : '')
                        ).trim();
                    }
                }
                if (
                    String.isBlank(complainantName) &&
                    caseCtx != null &&
                    caseCtx.Contact != null
                ) {
                    complainantName = caseCtx.Contact.Name;
                }
                if (String.isBlank(complainantName)) {
                    complainantName = 'Complainant';
                }

                String inspectorName = '';
                if (visitRec.Visitor != null) {
                    inspectorName = visitRec.Visitor.Name;
                }

                Map<String, String> replaceTextMap = new Map<String, String>{
                    'Complainant_Name' => complainantName,
                    'Complaint_Name' => publicComplaint != null &&
                        String.isNotBlank(publicComplaint.Name)
                        ? publicComplaint.Name
                        : '',
                    'Case_Number' => caseCtx != null &&
                        String.isNotBlank(caseCtx.CaseNumber)
                        ? caseCtx.CaseNumber
                        : '',
                    'Inspection_Name' => String.isNotBlank(visitRec.Name) ? visitRec.Name : '',
                    'Inspector_Name' => String.isNotBlank(inspectorName) ? inspectorName : ''
                };

                String emailSubject = emailMdt.Title__c;
                String emailBody = emailMdt.Description__c;
                for (String key : replaceTextMap.keySet()) {
                    String token = '\\[' + key + '\\]';
                    String value = replaceTextMap.get(key) != null
                        ? replaceTextMap.get(key)
                        : '';
                    emailSubject = emailSubject.replaceAll(token, value);
                    emailBody = emailBody.replaceAll(token, value);
                }

                LPI_Wrapper.NotificationEmailWrapper wrapper = new LPI_Wrapper.NotificationEmailWrapper();
                wrapper.visitId = visitRec.Id;
                wrapper.complaintId = complaintCaseRec.PublicComplaintId;
                wrapper.caseId = visitRec.ContextId;
                wrapper.accountId = visitRec.AccountId != null
                    ? visitRec.AccountId
                    : (caseCtx != null ? caseCtx.AccountId : null);
                wrapper.recipientEmail = recipientEmail;
                wrapper.templateName = emailMdt.Template_Name__c;
                wrapper.subject = emailSubject;
                wrapper.description = emailBody;
                wrapper.replaceTextMap = replaceTextMap;
                if (String.isNotBlank(emailMdt.Email_CC_Addresses__c)) {
                    wrapper.ccAddresses = emailMdt.Email_CC_Addresses__c;
                }
                notificationEmailWrapperList.add(wrapper);
            }

            if (!notificationEmailWrapperList.isEmpty()) {
                LPI_ServiceUtility.createNotificationRecords(notificationEmailWrapperList);
            }
        } catch (Exception e) {
            LPI_ExceptionManager.logException(
                'VisitTriggerHelper',
                'createInspectionLifecycleNotifications',
                e
            );
        }
    }

    /**
    * @description : Method to return business address related to business license
    * @author MTX Group Product Team | 03-14-2024 
    * @param blIdSet 
    * @return Map<Id, String> 
    **/
    public static Map<Id, String> getPrimaryAddressByLicenseId(Set<Id> blIdSet){
        Map<Id, Id> locIdToBlIdMap = new Map<Id, Id>();
        String fields = 'AuthorizationId, PlaceId';
        String whereClause = 'AuthorizationId IN' + LPI_ServiceUtility.getStringValuesBySet(blIdSet);
        for (
            AuthApplicationPlace aap : LPI_AuthApplicationPlaceDAO.getAuthApplicationPlaceByDymanicQuery(
                fields,
                whereClause,
                null,
                null,
                null
            )
        ) {
            locIdToBlIdMap.put(aap.PlaceId, aap.AuthorizationId);
        }
        if (locIdToBlIdMap.isEmpty()) {
            return null;
        }
        Map<Id, String> blToPrimaryAddMap = new Map<Id, String>();
        fields = 'ParentId,Parent.Status__c, Street, City, State, Country, PostalCode, LocationType, Parent.LocationType';
        whereClause = 'ParentId IN' + LPI_ServiceUtility.getStringValuesBySet(locIdToBlIdMap.keySet());
        for (Schema.Address adr : LPI_AddressDAO.getAddressByDymanicQuery(fields, whereClause, null, null, null)) {
            if(adr.Parent.Status__c != 'Open' || adr.Parent.LocationType != 'Business Address'){
                continue;
            }
            String businessAddress =
                adr.Street +
                ', ' +
                adr.City +
                ', ' +
                adr.State +
                ', ' +
                adr.Country +
                ', ' +
                adr.PostalCode;
            blToPrimaryAddMap.put(locIdToBlIdMap.get(adr.ParentId), businessAddress);
        
        }
        return blToPrimaryAddMap;
    }
}