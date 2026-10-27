/**
 * @author       : Hiten Aggarwal
 * @description  : This is trigger on Application_Content__c object
 * @since        : 09-Jan-2023
 */
trigger LPI_ApplicationContentTrigger on Application_Content__c (After Insert, After Update, Before Insert, Before Update) {
    LPI_TriggerConfiguration__mdt tcmdt = LPI_TriggerConfiguration__mdt.getInstance('Trigger_Configuration');
    if(tcmdt.ApplicationContent__c){
        new LPI_ApplicationContentTriggerHandler().run();
    }
}