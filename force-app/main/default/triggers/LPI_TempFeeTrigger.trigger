/**
 * @author       : Hiten Aggarwal
 * @description  : This is trigger on Temp_Fee__c object
 * @since        : 09-Jan-2023
 */
trigger LPI_TempFeeTrigger on Temp_Fee__c (After Insert, After Update) {
    LPI_TriggerConfiguration__mdt tcmdt = LPI_TriggerConfiguration__mdt.getInstance('Trigger_Configuration');
    if(tcmdt.TempFee__c){
        new LPI_TempFeeTriggerHandler().run();
    }
}