/**
 * @description       : Handler for LPI_AssessmentIndValueTrigger
 * @author            : MTX Group Product Team
 * @group             : 
 * @last modified on  : 07-26-2024
**/
public with sharing class LPI_AssessmentIndValueHandler extends LPI_TriggerHandler {
     /**
    * @description : Method to perform Business logics before a record is inserted.
    * @author MTX Group Product Team | 08-02-2023 
    **/
    public override void beforeInsert() {
        List<AssessmentIndValue> recordsList = (List<AssessmentIndValue>) Trigger.New;
        LPI_AssessmentIndValueHelper.updateBoardNameOnAssessmentIndValue(recordsList);
    }
}