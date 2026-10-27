/**
 * @author   : MTX.Inc
 * @since    : 3rd nov, 2022
 * @description   : Trigger on BusinessLicenseApplicationTrigger object
 */ 
trigger LPI_BusinessLicenseApplicationTrigger on BusinessLicenseApplication (before insert, before update, after insert, after update) {
    LPI_TriggerConfiguration__mdt tcmdt = LPI_TriggerConfiguration__mdt.getInstance('Trigger_Configuration');
    if(tcmdt.BusinessLicenseApplication__c){
		  new LPI_BusinessLicenceAppTriggerHandler().run();
    }
}