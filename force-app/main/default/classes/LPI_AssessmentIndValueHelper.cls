/**
 * @description       : Helper class for LPI_AssessmentIndValueHandler.
 * @author            : Mohit Karani
 * @group             : 
 * @last modified on  : 08-02-2023
 * @last modified by  : Mohit Karani
**/
public with sharing class LPI_AssessmentIndValueHelper {
   
    /**
    * @description : Method to update board name on AssessmentIndValue.
    * @author Mohit Karani | 08-02-2023 
    * @param newList 
    **/
    public static void updateBoardNameOnAssessmentIndValue(List<AssessmentIndValue> newList){
        try {
            Set<String> assessmentTaskIdSet = new Set<String>();
            List<AssessmentIndValue> assessmentIndValueListToProcess = new List<AssessmentIndValue> ();
            for(AssessmentIndValue assessmentIdValueRec : newList){
                if(String.isBlank(assessmentIdValueRec.SourceObjectId)){
                    continue;
                }
                assessmentTaskIdSet.add(assessmentIdValueRec.SourceObjectId);
                assessmentIndValueListToProcess.add(assessmentIdValueRec);
            }

            if(assessmentTaskIdSet.isEmpty()){
                return;
            }
            Map<Id,String> inspectionAssessmentIndIdToBoardName = new Map<Id,String>();
            String fieldsToQuery = 'Id,AssessmentTask.Board_Name__c';
            String whereClause = 'ID IN ' + LPI_ServiceUtility.getStringValuesByStringSet(assessmentTaskIdSet);
            for(InspectionAssessmentInd iaiRec :  LPI_InspectionAssessmentIndDAO.getInspectionAssessmentIndicatorByDymanicQuery(fieldsToQuery,whereClause,NULL,NULL,NULL)){
                inspectionAssessmentIndIdToBoardName.put(iaiRec.Id,iaiRec.AssessmentTask.Board_Name__c);
            }
            for(AssessmentIndValue assessmentIdValueRec : assessmentIndValueListToProcess){
                assessmentIdValueRec.Board_Name__c = inspectionAssessmentIndIdToBoardName.get(assessmentIdValueRec.SourceObjectId);
            }
        } catch (Exception e) {
            LPI_ExceptionManager.logException(
                'LPI_AssessmentIndValueHelper',
                'updateBoardNameOnAssessmentIndValue',
                e
            );
        } 
    }
}