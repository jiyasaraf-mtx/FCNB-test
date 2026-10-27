/**
 * @description Trigger on Financial_Filing__c.
 *              - Portal notification when status changes to Request Missing Schedule.
 *              - Employer Portal email when status changes to Request Missing Schedule or Accepted.
 *              - Internal System Administrator bell notification when status changes to
 *                Missing Schedule Submitted.
 */
trigger EMP_FinancialFilingTrigger on Financial_Filing__c (after update) {
    if (Trigger.isAfter && Trigger.isUpdate) {
        EMP_FinancialFilingTriggerHelper.handleAfterUpdate(Trigger.new, Trigger.oldMap);
    }
}