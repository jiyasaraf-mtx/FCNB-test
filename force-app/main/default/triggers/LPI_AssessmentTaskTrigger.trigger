/**
 * @description       : Trigger for AssessmentTask.
 * @author            : Mohit Karani
 * @group             : 
 * @last modified on  : 08-22-2023
 * @last modified by  : Mohit Karani
**/
trigger LPI_AssessmentTaskTrigger on AssessmentTask (after update) {
    LPI_TriggerConfiguration__mdt tcmdt = LPI_TriggerConfiguration__mdt.getInstance('Trigger_Configuration');
    if(tcmdt.AssessmentTask__c){
    	new LPI_AssessmentTaskTriggerHandler().run();
    }
}