/**
 * @description Sends Salesforce Lightning bell (Custom) notifications to System Administrators
 *              when Individual Application status changes to insurer / FCNB review statuses,
 *              and when Financial Filing status changes to Missing Schedule Submitted.
 *              Uses existing Custom Notification Type: Application_Notification.
 */
public without sharing class LPI_InternalBellNotificationService {

    private static final String CLASS_NAME = 'LPI_InternalBellNotificationService';
    private static final String CUSTOM_NOTIF_TYPE_DEV_NAME = 'Application_Notification';
    private static final String ADMIN_PROFILE_NAME = 'System Administrator';
    private static final String FF_STATUS_MISSING_SUBMITTED = 'Missing Schedule Submitted';
    private static final String FF_NOTIF_TITLE = 'Financial Filing Update';

    private static final Set<String> ADMIN_NOTIFY_STATUSES = new Set<String>{
        'Submitted to Insurer',
        'Information Received',
        'Information Submitted', // org picklist equivalent used by insurer flow
        'Approved by Insurer',
        'Submitted to FCNB'
    };

    /**
     * @description Entry point from IndividualApplication after-update.
     */
    public static void notifyAdminsOnStatusChange(
        List<IndividualApplication> newList,
        Map<Id, IndividualApplication> oldMap
    ) {
        if (newList == null || newList.isEmpty() || oldMap == null) {
            return;
        }

        try {
            Map<Id, String> statusByAppId = new Map<Id, String>();
            for (IndividualApplication app : newList) {
                IndividualApplication oldApp = oldMap.get(app.Id);
                if (oldApp == null || app.Status == oldApp.Status) {
                    continue;
                }
                if (String.isBlank(app.Status) || !ADMIN_NOTIFY_STATUSES.contains(app.Status)) {
                    continue;
                }
                statusByAppId.put(app.Id, app.Status);
            }
            if (statusByAppId.isEmpty()) {
                return;
            }

            Set<String> recipientIds = getSystemAdminUserIds();
            if (recipientIds.isEmpty()) {
                return;
            }

            Id notificationTypeId = getCustomNotificationTypeId();
            if (notificationTypeId == null) {
                return;
            }

            Map<Id, IndividualApplication> appsById = new Map<Id, IndividualApplication>([
                SELECT Id, Name, Status, License_Type_Name__c
                FROM IndividualApplication
                WHERE Id IN :statusByAppId.keySet()
            ]);

            for (Id appId : statusByAppId.keySet()) {
                IndividualApplication app = appsById.get(appId);
                if (app == null) {
                    continue;
                }
                String newStatus = statusByAppId.get(appId);
                sendCustomNotification(notificationTypeId, recipientIds, app, newStatus);
            }
        } catch (Exception ex) {
            LPI_ExceptionManager.logException(CLASS_NAME, 'notifyAdminsOnStatusChange', ex);
        }
    }

    /**
     * @description Entry point from Financial_Filing__c after-update. Notifies System Administrators
     *              with generic filing details when status changes to Missing Schedule Submitted.
     */
    public static void notifyAdminsOnFinancialFilingStatusChange(
        List<Financial_Filing__c> newList,
        Map<Id, Financial_Filing__c> oldMap
    ) {
        if (newList == null || newList.isEmpty() || oldMap == null) {
            return;
        }

        try {
            List<Financial_Filing__c> filingsToNotify = new List<Financial_Filing__c>();
            for (Financial_Filing__c filing : newList) {
                Financial_Filing__c oldFiling = oldMap.get(filing.Id);
                String oldStatus = oldFiling != null ? oldFiling.Status__c : null;
                if (filing.Status__c == FF_STATUS_MISSING_SUBMITTED
                    && oldStatus != FF_STATUS_MISSING_SUBMITTED) {
                    filingsToNotify.add(filing);
                }
            }
            if (filingsToNotify.isEmpty()) {
                return;
            }

            Set<String> recipientIds = getSystemAdminUserIds();
            if (recipientIds.isEmpty()) {
                return;
            }

            Id notificationTypeId = getCustomNotificationTypeId();
            if (notificationTypeId == null) {
                return;
            }

            for (Financial_Filing__c filing : filingsToNotify) {
                sendFinancialFilingNotification(notificationTypeId, recipientIds, filing);
            }
        } catch (Exception ex) {
            LPI_ExceptionManager.logException(
                CLASS_NAME,
                'notifyAdminsOnFinancialFilingStatusChange',
                ex
            );
        }
    }

    private static void sendCustomNotification(
        Id notificationTypeId,
        Set<String> recipientIds,
        IndividualApplication app,
        String newStatus
    ) {
        String title = 'Application Status Update';
        String body = buildBody(app, newStatus);

        Messaging.CustomNotification notification = new Messaging.CustomNotification();
        notification.setTitle(title);
        notification.setBody(body);
        notification.setNotificationTypeId(notificationTypeId);
        notification.setTargetId(app.Id);
        notification.send(recipientIds);
    }

    private static void sendFinancialFilingNotification(
        Id notificationTypeId,
        Set<String> recipientIds,
        Financial_Filing__c filing
    ) {
        Messaging.CustomNotification notification = new Messaging.CustomNotification();
        notification.setTitle(FF_NOTIF_TITLE);
        notification.setBody(buildFinancialFilingBody(filing));
        notification.setNotificationTypeId(notificationTypeId);
        notification.setTargetId(filing.Id);
        notification.send(recipientIds);
    }

    private static String buildBody(IndividualApplication app, String newStatus) {
        String appName = String.isNotBlank(app.Name) ? app.Name : 'Application';
        String licenseType = String.isNotBlank(app.License_Type_Name__c)
            ? ' (' + app.License_Type_Name__c + ')'
            : '';
        return appName + licenseType + ' status changed to ' + newStatus + '.';
    }

    private static String buildFinancialFilingBody(Financial_Filing__c filing) {
        String filingNumber = String.isNotBlank(filing.Name) ? filing.Name : 'Financial Filing';
        String reportingYear = String.isNotBlank(filing.Reporting_Year__c)
            ? filing.Reporting_Year__c
            : '';
        String yearPart = String.isNotBlank(reportingYear) ? ' (' + reportingYear + ')' : '';
        return filingNumber + yearPart + ' status changed to ' + FF_STATUS_MISSING_SUBMITTED + '.';
    }

    private static Id getCustomNotificationTypeId() {
        List<CustomNotificationType> types = [
            SELECT Id
            FROM CustomNotificationType
            WHERE DeveloperName = :CUSTOM_NOTIF_TYPE_DEV_NAME
            LIMIT 1
        ];
        return types.isEmpty() ? null : types[0].Id;
    }

    private static Set<String> getSystemAdminUserIds() {
        Set<String> userIds = new Set<String>();
        for (User adminUser : [
            SELECT Id
            FROM User
            WHERE IsActive = true
              AND Profile.Name = :ADMIN_PROFILE_NAME
        ]) {
            userIds.add(adminUser.Id);
        }
        return userIds;
    }
}