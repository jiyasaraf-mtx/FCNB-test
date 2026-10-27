/**
 * @description       : Controlller class to add methods to excute after CRUD on Notification__c.
 * @author            : MTX Group Product Team
 * @group             : 
 * @last modified on  : 07-26-2024
 * @last modified by  : MTX Group Product Team
**/
public with sharing class LPI_NotificationTriggerHandler extends LPI_TriggerHandler{
    /**
         * @author                      :MTX Group Product Team
         * @since                       : 11 June 2023
         * @description                 : Contains Methods to Be Triggered in After Insert Context
         * @return                      : `void`
         * @last modified by            : MTX Group Product Team
         * @last modified date          : 11 June 2023
     */
    public override void afterInsert() {
        List<Notification__c> recordsList = (List<Notification__c>) Trigger.New;
        Map<Id, Notification__c> recordsMap = (Map<Id, Notification__c>) Trigger.oldMap;
        if(!System.isBatch()){
            LPI_NotificationTriggerHelper.sendEmailNotification(recordsList, recordsMap);
        }
    }
    public override void afterUpdate() {
        List<Notification__c> recordsList = (List<Notification__c>) Trigger.New;
        Map<Id, Notification__c> recordsMap = (Map<Id, Notification__c>) Trigger.oldMap;
            LPI_NotificationTriggerHelper.sendEmailNotificationWithAttachment(recordsList, recordsMap);
    }
}