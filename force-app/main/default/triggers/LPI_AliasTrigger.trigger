/**
 * @author       : Garvit Jian
 * @description  : This is trigger on Alias__c object
 * @since        : 20-Jun-2023
 */
trigger LPI_AliasTrigger on Alias__c (before insert, before update, After Insert, After Update) {
    LPI_TriggerConfiguration__mdt tcmdt = LPI_TriggerConfiguration__mdt.getInstance('Trigger_Configuration');
    if(tcmdt.Alias__c){
        new LPI_AliasTriggerHandler().run();
    }
}