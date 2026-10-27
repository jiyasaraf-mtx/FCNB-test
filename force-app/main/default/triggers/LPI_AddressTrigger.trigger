/**
 * @author       : Neeraj Mani Sai
 * @description  : This is trigger on Address object
 * @since        : 13 Sep, 2023
 */
trigger LPI_AddressTrigger on Address (
    after insert,
    before update
) {
    LPI_TriggerConfiguration__mdt tcmdt = LPI_TriggerConfiguration__mdt.getInstance('Trigger_Configuration'); 
    if(tcmdt.Address__c){
        new LPI_AddressTriggerHandler().run();
    }
}