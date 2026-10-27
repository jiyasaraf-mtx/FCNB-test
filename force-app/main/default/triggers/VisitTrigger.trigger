/**
 * @author   : MTX.Inc
 * @since    : 3rd nov, 2022
 * @description   : Trigger on Visit object
 */
trigger VisitTrigger on Visit (before insert, before update, after insert, after update) {
    LPI_TriggerConfiguration__mdt tcmdt = LPI_TriggerConfiguration__mdt.getInstance('Trigger_Configuration');
    if(tcmdt.Visit__c){
    	new LPI_VisitTriggerHandler().run();
    }
}