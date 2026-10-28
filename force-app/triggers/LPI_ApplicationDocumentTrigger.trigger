/**
 * @author       : Hiten Aggarwal
 * @description  : This is trigger on Application_Document__c object
 * @since        : 09-Jan-2023
 */
trigger LPI_ApplicationDocumentTrigger on Application_Document__c (After Insert, After Update, Before Update, Before Insert) {
    LPI_TriggerConfiguration__mdt tcmdt = LPI_TriggerConfiguration__mdt.getInstance('Trigger_Configuration');
    if(tcmdt.ApplicationDocument__c){
        new LPI_ApplicationDocumentTriggerHandler().run();
    }
}
