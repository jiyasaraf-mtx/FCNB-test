/**
 * @description       : Handler class for LPI_AssessmentTaskTrigger.
 * @author            : MTX Group Product Team
 * @group             : 
 * @last modified on  : 07-26-2024
**/
public with sharing class LPI_AssessmentTaskTriggerHandler extends LPI_TriggerHandler {
    
    /**
    * @description : Method to perform Business logics before a record is inserted.
    * @author MTX Group Product Team | 08-02-2023 
    **/
    public override void afterUpdate(){
        LPI_AssessmentTaskTriggerHelper.createViolationRecords((List<AssessmentTask>) Trigger.new,(Map<Id,AssessmentTask>) Trigger.oldMap);
    }
}