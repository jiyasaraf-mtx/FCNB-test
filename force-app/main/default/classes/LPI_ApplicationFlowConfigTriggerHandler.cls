/**
 * @description       : Handler class for ApplicationFlow Config
 * @author            : MTX Group Product Team
 * @group             : 
 * @last modified on  : 07-26-2024
 * @last modified by  : MTX Group Product Team
**/
public with sharing class LPI_ApplicationFlowConfigTriggerHandler extends LPI_TriggerHandler {
    
    /**
    * @description 
    * @author MTX Group Product Team | 11-29-2022 
    **/
    public override void beforeInsert() {
        List<Application_Flow_Config__c> recordsList = (List<Application_Flow_Config__c>) Trigger.New;
        LPI_ApplicationFlowConfigTriggerHelper.populateApplicationURL(null,recordsList);

    }
    
    /**
    * @description 
    * @author MTX Group Product Team | 11-29-2022 
    **/
    public override void beforeUpdate() {
        List<Application_Flow_Config__c> recordsList = (List<Application_Flow_Config__c>) Trigger.New;
        Map<Id, Application_Flow_Config__c> mapOfOldRecords = (Map<Id, Application_Flow_Config__c>) Trigger.oldMap;
        LPI_ApplicationFlowConfigTriggerHelper.populateApplicationURL(mapOfOldRecords, recordsList);
        
    }
}