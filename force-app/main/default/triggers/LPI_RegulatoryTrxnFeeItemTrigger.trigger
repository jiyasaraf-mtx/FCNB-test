/**
 * @author       : Hiten Aggarwal
 * @description  : This is trigger on RegulatoryTrxnFeeItem object
 * @since        : 20-Mar-2023
 */
trigger LPI_RegulatoryTrxnFeeItemTrigger on RegulatoryTrxnFeeItem (Before Update) {
    LPI_TriggerConfiguration__mdt tcmdt = LPI_TriggerConfiguration__mdt.getInstance('Trigger_Configuration');
    if(tcmdt.RegulatoryTrxnFeeItem__C){
        new LPI_RegulatoryTrxnFeeItemTgrHandler().run();
    }
}