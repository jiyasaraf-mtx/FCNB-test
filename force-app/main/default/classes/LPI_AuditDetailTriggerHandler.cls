/**
 * @author                      :  MTX Group Product Team
 * @since                       : 12 Sep, 2023
 * @description                 : Handler class for LPI_AuditDetailTrigger
 * @last modified by            : MTX Group Product Team
 * @last modified on            : 07-26-2024
 */
public with sharing class LPI_AuditDetailTriggerHandler extends LPI_TriggerHandler{

    /**
    * Author        :  MTX Group Product Team
    * BuildDate     : 18 Sep, 2023
    * Description   : This method will be called in before insert context of Audit_Detail__c Trigger
    * return : void
    */
    public override void beforeInsert() {
        List<Audit_Detail__c> recordsList = (List<Audit_Detail__c>) Trigger.New;
        LPI_AuditDetailTriggerHelper.populateAuditDates(recordsList,null);
    }

    /**
    * Author        :  MTX Group Product Team
    * BuildDate     : 12 Sep, 2023
    * Description   : This method will be called in after insert context of Audit_Detail__c Trigger
    * return : void
    */
    public override void afterInsert() {
    }

    /**
    * Author        :  MTX Group Product Team
    * BuildDate     : 12 Sep, 2023
    * Description   : This method will be called in after update context of Audit_Detail__c Trigger
    * return : void
    */
    public override void afterUpdate() {
        List<Audit_Detail__c> recordsList = (List<Audit_Detail__c>) Trigger.New;
        Map<Id, Audit_Detail__c> mapOfOldRecords = (Map<Id, Audit_Detail__c>) Trigger.oldMap;
        LPI_AuditDetailTriggerHelper.sendAuditlNotifications(recordsList,mapOfOldRecords);

    }

    /**
    * Author        : Piyush Aneja
    * BuildDate     : 27 Sep, 2023
    * Description   : This method will be called in before update context of Audit_Detail__c Trigger
    * return : void
    */
    public override void beforeUpdate() {
        List<Audit_Detail__c> recordsList = (List<Audit_Detail__c>) Trigger.New;
        Map<Id, Audit_Detail__c> mapOfOldRecords = (Map<Id, Audit_Detail__c>) Trigger.oldMap;
        LPI_AuditDetailTriggerHelper.updateNoResponseNotiOnStatusChange(recordsList,mapOfOldRecords);
        LPI_AuditDetailTriggerHelper.populateAuditDates(recordsList,mapOfOldRecords);
    }
}