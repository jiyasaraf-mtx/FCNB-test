/**
 * @description Helper for EMP_FinancialFilingTrigger.
 *              - Creates portal notifications when status becomes Request Missing Schedule.
 *              - Sends Employer Portal emails when status becomes Request Missing Schedule or Accepted.
 *              - Notifies System Administrators (Lightning bell) when status becomes
 *                Missing Schedule Submitted.
 */
public without sharing class EMP_FinancialFilingTriggerHelper {
    private static final String CLASS_NAME = 'EMP_FinancialFilingTriggerHelper';
    private static final String STATUS_REQUEST_MISSING = 'Request Missing Schedule';
    private static final String NOTIF_TITLE = 'Financial Filing Update';
    private static final String NOTIF_SUBJECT = 'Request Missing Schedule';

    /**
     * @description Handles after-update side effects for Financial_Filing__c status changes.
     */
    public static void handleAfterUpdate(
        List<Financial_Filing__c> newRecords,
        Map<Id, Financial_Filing__c> oldMap
    ) {
        createPortalNotificationsForRequestMissing(newRecords, oldMap);
        EMP_FinancialFilingEmailService.sendEmailsOnStatusChange(newRecords, oldMap);
        LPI_InternalBellNotificationService.notifyAdminsOnFinancialFilingStatusChange(
            newRecords,
            oldMap
        );
    }

    /**
     * @description Creates a Portal_Notification for each filing whose Status__c has just
     *              changed to Request Missing Schedule.
     */
    private static void createPortalNotificationsForRequestMissing(
        List<Financial_Filing__c> newRecords,
        Map<Id, Financial_Filing__c> oldMap
    ) {
        try {
            Id portalRtId = Schema.SObjectType.Notification__c
                .getRecordTypeInfosByDeveloperName()
                .get(LPI_LiteralConstant.PORTAL_NOTIFICATION_RECORDTYPE_DEV_NAME)
                ?.getRecordTypeId();

            List<Notification__c> toInsert = new List<Notification__c>();
            for (Financial_Filing__c filing : newRecords) {
                Financial_Filing__c oldFiling = oldMap != null ? oldMap.get(filing.Id) : null;
                String oldStatus = oldFiling != null ? oldFiling.Status__c : null;
                if (filing.Status__c == STATUS_REQUEST_MISSING && oldStatus != STATUS_REQUEST_MISSING) {
                    Notification__c notif = new Notification__c(
                        Account__c = filing.Account__c,
                        Record_Id__c = filing.Id,
                        Title__c = NOTIF_TITLE,
                        Subject__c = NOTIF_SUBJECT,
                        Description__c = buildDescription(filing),
                        is_Read__c = false,
                        Is_Resolved__c = false
                    );
                    if (portalRtId != null) {
                        notif.RecordTypeId = portalRtId;
                    }
                    toInsert.add(notif);
                }
            }

            if (!toInsert.isEmpty()) {
                insert toInsert;
            }
        } catch (Exception ex) {
            LPI_ExceptionManager.logException(CLASS_NAME, 'createPortalNotificationsForRequestMissing', ex);
        }
    }

    /**
     * @description Stores the filing number and reporting year so the notification body can be
     *              formatted per-language when the portal reads the notification.
     */
    private static String buildDescription(Financial_Filing__c filing) {
        String filingNumber = filing.Name != null ? filing.Name : '';
        String reportingYear = filing.Reporting_Year__c != null ? filing.Reporting_Year__c : '';
        return filingNumber + '|' + reportingYear;
    }
}