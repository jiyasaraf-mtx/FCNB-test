/**
 * @author       : MTX Group Product Team
 * @description  : This Class is the Handler class on InspectionAssessInd trigger
 * @since        : 09-Jan-2023
 */
public with sharing class LPI_InspectionAssessIndTriggerHandler extends LPI_TriggerHandler {
    
    /**
 * @author       : MTX Group Product Team
 * @description  : Method to run business logics after record insertion.
 * @since        : 09-Jan-2023
 */
    public override void afterInsert(){
        LPI_InspectionAssessIndTriggerHelper.deleteUnusedRecord((List<InspectionAssessmentInd>) Trigger.New);
        LPI_InspectionAssessIndTriggerHelper.updateBoardAndOwnerOnAssessmentTask((List<InspectionAssessmentInd>) Trigger.New);
    }
}