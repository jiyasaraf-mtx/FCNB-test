/**
 * @author                      : Nitesh Garg
 * @since                       : 
 * @description                 : Regulatory Transaction Fee Trigger
 * @last modified by            : MTX Group Inc.
 * @last modified date          : 
 * @modified details            : 
 */
trigger LPI_RegulatoryTransactionFeeTrigger on RegulatoryTrxnFee (before insert,after update,after insert,before update) {
	LPI_TriggerConfiguration__mdt tcmdt = LPI_TriggerConfiguration__mdt.getInstance('Trigger_Configuration'); 
    if(tcmdt.RegulatoryTrxnFee__c){
        new LPI_RegulatoryTrnxFeeTriggerHandler().run();
    }
}