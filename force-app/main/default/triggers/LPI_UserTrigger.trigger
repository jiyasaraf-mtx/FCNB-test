/**
 * @author       : Hiten Aggarwal
 * @description  : This is trigger on User object
 * @since        : 09-Jan-2023
 */
trigger LPI_UserTrigger on User (before insert,after insert, after update, before update) {
    LPI_TriggerConfiguration__mdt tcmdt = LPI_TriggerConfiguration__mdt.getInstance('Trigger_Configuration');
    if(tcmdt.User__c){
        new LPI_UserTriggerHandler().run();
    }
}