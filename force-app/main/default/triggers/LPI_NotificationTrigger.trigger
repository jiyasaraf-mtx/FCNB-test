/**
 * @description       : Trigger for Notification__c.
 * @author            : Vamsi Mudaliar
 * @group             :
 * @last modified on  : 04-24-2024
 * @last modified by  : Amit Agrawal
 **/
trigger LPI_NotificationTrigger on Notification__c(after insert, after update) {
    LPI_TriggerConfiguration__mdt tcmdt = LPI_TriggerConfiguration__mdt.getInstance(
        'Trigger_Configuration'
    );
    if (tcmdt.Notification__c) {
        new LPI_NotificationTriggerHandler().run();
    }
}