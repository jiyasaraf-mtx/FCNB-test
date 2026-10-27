/**
 * @description       : Helper class for LPI_AssessmentTaskTriggerHandler.
 * @author            : MTX Group Product Team
 * @group             :
 * @last modified on  : 07-26-2024
 * @last modified by  : MTX Group Product Team
 **/
public with sharing class LPI_AssessmentTaskTriggerHelper {

    public static final Set<String> VIOLATION_VALUES_SET = new Set<String>{
        'Violation','No','Fail','Not Completed'
    };
    public static final String OTHER_VIOLATION_QUES = 'Are there any other violations?';
    public static final Set<String> OTHER_VIOLATION_QUES_ANS_SET = new Set<String>{
        'Yes','Violation'
    };


    /**
     * @description : Method to update board name on assessment task.
     * @author MTX Group Product Team
     * @param newList
     **/
    public static void createViolationRecords(
        List<AssessmentTask> newList,
        Map<Id, AssessmentTask> oldMap
    ) {
        try {
            Set<Id> assessmentTaskIdSet = new Set<Id>();
            for (AssessmentTask rec : newList) {
                if (
                    rec.Status != LPI_LiteralConstant.Inspection_Status_COMPLETED ||
                    rec.Status == oldMap.get(rec.Id).Status
                ) {
                    continue;
                }
                assessmentTaskIdSet.add(rec.Id);
            }
            if(assessmentTaskIdSet.isEmpty()){
                return;
            }
            String fields = 'Id,Result,AssessmentTaskId,AssessmentIndDefinition.Question_Text__c,AssessmentIndDefinitionId,AssessmentTask.ParentId,(SELECT ID ,SourceObjectId,AssessmentIndDefinedValue.value,AssessmentIndDefinedValue.AssessmentIndicatorDefinitionId FROM SourceObjects)';
            String whereClause = ' AssessmentTaskId IN  ' + LPI_ServiceUtility.getStringValuesBySet(assessmentTaskIdSet) + ' AND  AssessmentIndDefinition.Does_Not_Account_For_Violation__c = FALSE';
            List<AssessmentIndValue> aivList = new List<AssessmentIndValue>();
            Map<Id,InspectionAssessmentInd> idToIaiMap = new Map<Id,InspectionAssessmentInd>(LPI_InspectionAssessmentIndDAO.getInspectionAssessmentIndicatorByDymanicQuery(fields,whereClause,NULL,NULL,NULL));
            for(InspectionAssessmentInd iai : idToIaiMap.values()){
                if(iai.SourceObjects.isEmpty()){
                    continue;
                }
                aivList.addAll(iai.SourceObjects);
            }
            if(aivList.isEmpty()){
                return;
            }
            Set<Id> inspectionAssessmentIndSetToCreateViolation = new Set<Id>();
            Set<Id> inspectionAssessmentIndSetToDeleteViolation = new Set<Id>();
            Set<Id> assessmentIndDefinitionIdSet = new Set<Id>();
            for(AssessmentIndValue aiv : aivList){
                if((VIOLATION_VALUES_SET.contains(aiv.AssessmentIndDefinedValue.value)  && idToIaiMap.get(aiv.SourceObjectId).AssessmentIndDefinition.Question_Text__c != OTHER_VIOLATION_QUES )|| (idToIaiMap.get(aiv.SourceObjectId).AssessmentIndDefinition.Question_Text__c == OTHER_VIOLATION_QUES && OTHER_VIOLATION_QUES_ANS_SET.contains(aiv.AssessmentIndDefinedValue.value))){
                    inspectionAssessmentIndSetToCreateViolation.add(aiv.SourceObjectId);
                    assessmentIndDefinitionIdSet.add(aiv.AssessmentIndDefinedValue.AssessmentIndicatorDefinitionId);
                }else{
                    inspectionAssessmentIndSetToDeleteViolation.add(aiv.SourceObjectId);
                }
            }
            if(inspectionAssessmentIndSetToCreateViolation.isEmpty() && inspectionAssessmentIndSetToDeleteViolation.isEmpty()){
                return;
            }
            if(!inspectionAssessmentIndSetToDeleteViolation.isEmpty()){
                fields = 'Id';
                whereClause = 'InspectionAssmntIndId IN ' + LPI_ServiceUtility.getStringValuesBySet(inspectionAssessmentIndSetToDeleteViolation);
                List<RegulatoryCodeViolation> rcvListToDelete =  LPI_RegulatoryCodeViolationDAO.getRegulatoryCodeViolationListByDynamicQuery(fields,whereClause,null,null,null);
                if(!rcvListToDelete.isEmpty()){
                    LPI_WithoutSharingUtility.deleteSObjectRecord(rcvListToDelete);
                }
            }
            if(inspectionAssessmentIndSetToCreateViolation.isEmpty()){
                return; 
            }
            Map<Id,Id> assessmentIndDefToViolationTypeAssessmentIndDef = new Map<Id,Id>();
            if(assessmentIndDefinitionIdSet.isEmpty()){
                return;
            }
            fields = 'AssessmentIndDefinitionId,ViolationTypeId ';
            whereClause = 'AssessmentIndDefinitionId != null AND ViolationTypeId != NULL AND AssessmentIndDefinitionId IN ' + LPI_ServiceUtility.getStringValuesBySet(assessmentIndDefinitionIdSet);
            for(ViolationTypeAssessmentInd vtai : LPI_ViolationTypeAssessmentIndDAO.getViolationTypeAssessmentIndByDymanicQuery(fields,whereClause,null,null,null)){
                assessmentIndDefToViolationTypeAssessmentIndDef.put(vtai.AssessmentIndDefinitionId,vtai.ViolationTypeId);
            }
            Map<Id,Id> assessmentIndDefToRegCodeAssessmentIndDef = new Map<Id,Id>();
            fields = 'AssessmentIndDefinitionId,RegulatoryCodeId';
            whereClause = 'AssessmentIndDefinitionId != null AND RegulatoryCodeId != NULL AND  AssessmentIndDefinitionId IN ' + LPI_ServiceUtility.getStringValuesBySet(assessmentIndDefinitionIdSet);
            for(RegulatoryCodeAssessmentInd rcai : LPI_RegulatoryCodeAssessmentIndDAO.getRegulatoryCodeAssessmentIndByDymanicQuery(fields,whereClause,null,null,null)){
                assessmentIndDefToRegCodeAssessmentIndDef.put(rcai.AssessmentIndDefinitionId,rcai.RegulatoryCodeId);
            }
            List<RegulatoryCodeViolation> rcvListToInsert = new List<RegulatoryCodeViolation>();
            for(Id recordId : inspectionAssessmentIndSetToCreateViolation){
                RegulatoryCodeViolation rcv = new RegulatoryCodeViolation();
                rcv.DateCreated = Date.today();
                rcv.InspectionAssmntIndId = recordId;
                rcv.InspectionId = idToIaiMap.get(recordId).AssessmentTask.ParentId;
                rcv.Status = LPI_LiteralConstant.VISIT_CORRECTIVE_ACTION_STATUS_OPEN;
                rcv.ResponseId = recordId;
                rcv.Start_Date__c = Date.today();
                rcv.ResponseContextId = idToIaiMap.get(recordId).AssessmentTask.ParentId;
                rcv.ViolationTypeId = assessmentIndDefToViolationTypeAssessmentIndDef.get(idToIaiMap.get(recordId).AssessmentIndDefinitionId);
                rcv.RegulatoryCodeId = assessmentIndDefToRegCodeAssessmentIndDef.get(idToIaiMap.get(recordId).AssessmentIndDefinitionId);
                rcvListToInsert.add(rcv);
            }
           
            LPI_DML.doInsert(rcvListToInsert);


        } catch (Exception e) {
            LPI_ExceptionManager.logException(
                'LPI_AssessmentTaskTriggerHelper',
                'createViolationRecords',
                e
            );
        }
    }
}