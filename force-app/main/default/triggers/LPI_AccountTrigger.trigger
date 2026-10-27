/**
 * @author   : Piyush Sinha (MTX.Inc)
 * @since    : 29th dec, 2022
 * @description   : Trigger on Account object
 */

trigger LPI_AccountTrigger on Account(
    before insert,
    before update, 
    after update,
    after insert
) {
    LPI_TriggerConfiguration__mdt tcmdt = LPI_TriggerConfiguration__mdt.getInstance('Trigger_Configuration');
    system.debug('>>>>>>>'+tcmdt.Account__c);
    if(tcmdt.Account__c){
          new LPI_AccountTriggerHandler().run();
    }
}