/**
 * @description       : 
 * @author            : Mohit Karani
 * @group             : 
 * @last modified on  : 08-02-2023
 * @last modified by  : Mohit Karani
**/
trigger LPI_AssessmentIndValueTrigger on AssessmentIndValue (before insert) {
    LPI_TriggerConfiguration__mdt tcmdt = LPI_TriggerConfiguration__mdt.getInstance('Trigger_Configuration');
    if(tcmdt.AssessmentIndValue__c){
    	new LPI_AssessmentIndValueHandler().run();
    }
}
