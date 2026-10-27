/**
 * @description       : 
 * @author            : Rajeev Roushan
 * @group             : 
 * @last modified on  : 04-26-2024
 * @last modified by  : Rajeev Roushan
**/
trigger LPI_BusinessLicenseTrigger on BusinessLicense (before insert, before update, after insert, after update) {
    LPI_TriggerConfiguration__mdt tcmdt = LPI_TriggerConfiguration__mdt.getInstance('Trigger_Configuration');
    if(tcmdt.BusinessLicense__c){
		  new LPI_BusinessLicenseTriggerHandler().run();
    }
}