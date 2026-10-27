/**
 * @author              Mahesh Reddy Chinthakunta
 * @description         Trigger on Case Object when the status field is changed
 * @param Update 
 * @return  `trigger LPI_`
 */
trigger LPI_CaseTrigger on Case (before Update,after insert,after update,before insert,after Delete,after Undelete) {
	LPI_TriggerConfiguration__mdt tcmdt = LPI_TriggerConfiguration__mdt.getInstance('Trigger_Configuration');
    if(tcmdt.Case__c ){
		  new LPI_CaseTriggerHandler().run();
    }
}