/**
 * @description       : Controller class contains method getting called from MODPR_NotificationTriggerHandler.
 * @author            : Vamsi Mudaliar
 * @group             :
 * @last modified on  : 07-12-2024
 * @last modified by  : Ayush Dev
 **/
public with sharing class LPI_NotificationTriggerHelper {
    /**
     * @author                      : Vamsi Mudaliar
     * @since                       : 11 June 2023
     * @description                 : Private Method which has logic of sending Email Notifications via AWS, providing necessary Params.
     * @return                      : `String`
     * @last modified by            : Ayush Dev
     * @last modified date          : 11 June 2023
     * @modified details            : Code Review Fixes
     */
    public static void sendEmailNotification(
        List<Notification__c> newList,
        Map<Id, Notification__c> oldMap
    ) {
        try {
            List<Notification__c> notificationList = new List<Notification__c>();
            for (Notification__c notifRec : newList) {
                if (
                    notifRec.Is_Attachments_Required__c || 
                    String.isBlank(notifRec.Template_Name__c) ||
                    String.isBlank(notifRec.Recipient_Email__c)
                ) {
                    continue;
                }
                notificationList.add(notifRec);
            }
            
            if(!notificationList.isEmpty()){
                    LPI_NotificationCalloutHelper.sendNotification(JSON.serialize(notificationList));
                }
        } catch (Exception ex) {
            LPI_ExceptionManager.logException(
                'LPI_NotificationTriggerHelper',
                'sendAWSEmailNotification',
                ex
            );
            throw new AuraHandledException(ex.getMessage());
        }
    }

    public static void sendEmailNotificationWithAttachment(
        List<Notification__c> newList,
        Map<Id, Notification__c> oldMap
    ) {
        try {
            List<Notification__c> notificationList = new List<Notification__c>();
            // Query Potential Notification Records - in New List.
            for (Notification__c notifRec : newList) {
                if (
                    notifRec.Is_Attachments_Required__c && notifRec.Send_Email__c && !String.isBlank(notifRec.Template_Name__c) &&
                    !String.isBlank(notifRec.Recipient_Email__c)){
                        notificationList.add(notifRec);
                }
                
            }
              if(!notificationList.isEmpty()){
            	LPI_NotificationCalloutHelper.sendNotificationWhenUpdate(JSON.serialize(notificationList));
              }
        } catch (Exception ex) {
            LPI_ExceptionManager.logException(
                'LPI_NotificationTriggerHelper',
                'sendAWSEmailNotification',
                ex
            );
            throw new AuraHandledException(ex.getMessage());
        }
    }
}