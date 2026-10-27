/**
 * @description       : 
 * @author            : Vamsi Mudaliar
 * @group             : 
 * @last modified on  : 05-15-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
trigger RegulatoryCodeViolationTrigger on RegulatoryCodeViolation (before insert,before update,after insert,after update,after delete,after undelete) {
    LPI_TriggerConfiguration__mdt tcmdt = LPI_TriggerConfiguration__mdt.getInstance('Trigger_Configuration');
    if(tcmdt.RegulatoryCodeViolation__c){
          new RegulatoryCodeViolationTriggerHandler().run();
    }
}