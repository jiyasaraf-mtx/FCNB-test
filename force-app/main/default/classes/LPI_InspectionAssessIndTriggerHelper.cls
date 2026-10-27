/**
 * @description       : Helper class for LPI_InspectionAssessIndTriggerHandler
 * @author            : MTX Group Product Team
 * @group             : 
 * @last modified on  : 07-26-2024
 * @last modified by  : MTX Group Product Team
**/
public with sharing class LPI_InspectionAssessIndTriggerHelper {
    
    /**
    * @description : Method to update board and owner name on assessment task records.
    * @author MTX Group Product Team
    * @param newList 
    **/
    public static void updateBoardAndOwnerOnAssessmentTask(List<InspectionAssessmentInd> newList){
        try{
            Set<String> assessmentTaskIdSet = new Set<String>();
            for(InspectionAssessmentInd ini : newList){
                assessmentTaskIdSet.add(ini.AssessmentTaskId);
            }
            map<id,id> idtoidmap = new map<id,id>();
            list<AssessmentTask> atlist = new list<AssessmentTask>();
            for(AssessmentTask at : LPI_AssessmentTaskDAO.getAssessmentTaskListByDynamicQuery('Name,Parent.VisitorId,Parent.Board_Name__c', 'ID IN ' + LPI_ServiceUtility.getStringValuesByStringSet(assessmentTaskIdSet),null,null,null)){
                at.OwnerId =  String.isNotBlank(at.Parent.VisitorId) ? at.Parent.VisitorId : UserInfo.getUserId();
                at.Board_Name__c = at.Parent.Board_Name__c;
                at.Name = String.isNotBlank(at.Name) ? at.Name.toUpperCase() : at.Name;
                atlist.add(at);
            }
            LPI_DML.doUpdate(atlist);
        }catch(Exception e){
            LPI_ExceptionManager.logException(
                'LPI_InspectionAssessIndTriggerHelper',
                'updateBoardAndOwnerOnAssessmentTask',
                e
            );
        }
 
    }

    /**
    * @description : Methof to delete unwanted InspectionAssessmentIndicator records created by salesforce.
    * @author MTX Group Product Team
    * @param newList 
    **/
    public static void deleteUnusedRecord(List<InspectionAssessmentInd> newList){
        List<InspectionAssessmentInd> listToDelete = new List<InspectionAssessmentInd>();
        Set<String> assessmentTaskDefinitionIdSet = new Set<String>();
        Set<String> inspectionAssessmentIndIdSet = new Set<String>();
        Map<String,InspectionAssessmentInd> stringToIaiMap = new Map<String,InspectionAssessmentInd>();
        for(InspectionAssessmentInd iai : newList){
            if(stringToIaiMap.containsKey(iai.AssessmentIndDefinitionId+'-'+iai.AssessmentTaskId)){
                listToDelete.add(iai);
                continue;
            }
            stringToIaiMap.put(iai.AssessmentIndDefinitionId+'-'+iai.AssessmentTaskId,iai);
            assessmentTaskDefinitionIdSet.add(iai.AssessmentTaskId);
            inspectionAssessmentIndIdSet.add(iai.Id);
        }

        if(inspectionAssessmentIndIdSet.isEmpty()){
            return;
        }
        for(InspectionAssessmentInd iai : LPI_InspectionAssessmentIndDAO.getInspectionAssessmentIndicatorByDymanicQuery('Id,AssessmentIndDefinitionId,AssessmentTaskId','ID NOT IN '+ LPI_ServiceUtility.getStringValuesByStringSet(inspectionAssessmentIndIdSet)+ ' AND AssessmentTaskId IN ' + LPI_ServiceUtility.getStringValuesByStringSet(assessmentTaskDefinitionIdSet),NULL,NULL,NULL)){
            if(stringToIaiMap.containsKey(iai.AssessmentIndDefinitionId+'-'+iai.AssessmentTaskId)){
                listToDelete.add(stringToIaiMap.get(iai.AssessmentIndDefinitionId+'-'+iai.AssessmentTaskId));
            }

        }
        LPI_DML.doDelete(listToDelete);
    }
}