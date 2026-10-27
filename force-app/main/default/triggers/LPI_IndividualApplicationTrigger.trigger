/**
 * @description       : 
 * @author            : Amit Agrawal
 * @group             : 
 * @last modified on  : 04-17-2024
 * @last modified by  : Amit Agrawal
**/
trigger LPI_IndividualApplicationTrigger on IndividualApplication (before insert, before update, after insert, after update) {
    LPI_TriggerConfiguration__mdt tcmdt = LPI_TriggerConfiguration__mdt.getInstance('Trigger_Configuration');
    if(tcmdt.IndividualApplication__c ){
		  new LPI_IndividualAppTriggerHandler().run();
    }

}