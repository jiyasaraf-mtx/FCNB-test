/**
 * @description       : Trigger for InspectionAssessmentInd.
 * @author            : Mohit Karani
 * @group             : 
 * @last modified on  : 08-07-2023
 * @last modified by  : Mohit Karani
**/
trigger LPI_InspectionAssessmentIndTrigger on InspectionAssessmentInd (after insert) {
    LPI_TriggerConfiguration__mdt tcmdt = LPI_TriggerConfiguration__mdt.getInstance('Trigger_Configuration');
    if(tcmdt.InspectionAssessmentInd__c){
    	new LPI_InspectionAssessIndTriggerHandler().run();
    }
}