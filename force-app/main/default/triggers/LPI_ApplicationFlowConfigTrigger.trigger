/**
 * @description       : 
 * @author            : Amit Agrawal
 * @group             : 
 * @last modified on  : 04-11-2024
 * @last modified by  : Amit Agrawal
**/
trigger LPI_ApplicationFlowConfigTrigger on Application_Flow_Config__c (before insert, before update) {
    LPI_TriggerConfiguration__mdt tcmdt = LPI_TriggerConfiguration__mdt.getInstance('Trigger_Configuration');
    if(tcmdt.ApplicationFlowConfig__c ){
		new LPI_ApplicationFlowConfigTriggerHandler().run();
    }
}