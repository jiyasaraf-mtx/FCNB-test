/**
 * @description Handles IndividualApplicationChangeEvent (CDC) and creates portal notifications
 *              so Experience Cloud users can see status updates (empApi is not supported in communities).
 */
public without sharing class LPI_IAChangeEventHelper {

    private static final String CLASS_NAME = 'LPI_IAChangeEventHelper';
    private static final String NOTIFICATION_TITLE = 'Application Status Update';
    private static final Set<String> PORTAL_STATUS_SET = new Set<String>{
        LPI_LiteralConstant.IA_LICENSEISSUED_STATUS,
        LPI_LiteralConstant.IA_SUBMITTED_STATUS
    };

    public static void handleAfterInsert(List<IndividualApplicationChangeEvent> events) {
        if (events == null || events.isEmpty()) {
            return;
        }

        try {
            Map<Id, String> statusByAppId = new Map<Id, String>();

            for (IndividualApplicationChangeEvent evt : events) {
                EventBus.ChangeEventHeader header = evt.ChangeEventHeader;
                if (header == null || header.recordIds == null || header.recordIds.isEmpty()) {
                    continue;
                }

                String changeType = header.changeType;
                if (String.isNotBlank(changeType) && changeType.startsWith('GAP')) {
                    continue;
                }

                Boolean statusChanged = false;
                if (header.changedFields != null) {
                    for (String fieldName : header.changedFields) {
                        if (fieldName != null && fieldName.equalsIgnoreCase('Status')) {
                            statusChanged = true;
                            break;
                        }
                    }
                }

                // Status updates are the only events we notify on
                if (!statusChanged) {
                    continue;
                }

                for (String recordId : header.recordIds) {
                    statusByAppId.put((Id) recordId, evt.Status);
                }
            }

            if (statusByAppId.isEmpty()) {
                return;
            }

            createPortalNotifications(statusByAppId);
        } catch (Exception ex) {
            LPI_ExceptionManager.logException(CLASS_NAME, 'handleAfterInsert', ex);
        }
    }

    /**
     * @description Creates portal notifications from IndividualApplication after-update
     *              (reliable path — CDC is not always enabled / delivered).
     */
    public static void createFromStatusChanges(
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
                if (String.isBlank(app.Status) || !PORTAL_STATUS_SET.contains(app.Status)) {
                    continue;
                }
                statusByAppId.put(app.Id, app.Status);
            }
            if (!statusByAppId.isEmpty()) {
                createPortalNotifications(statusByAppId);
            }
        } catch (Exception ex) {
            LPI_ExceptionManager.logException(CLASS_NAME, 'createFromStatusChanges', ex);
        }
    }

    public static void createPortalNotifications(Map<Id, String> statusByAppId) {
        List<IndividualApplication> apps = [
            SELECT Id, Name, AccountId, Status
            FROM IndividualApplication
            WHERE Id IN :statusByAppId.keySet()
              AND AccountId != null
        ];
        if (apps.isEmpty()) {
            return;
        }

        Id portalRtId = Schema.SObjectType.Notification__c
            .getRecordTypeInfosByDeveloperName()
            .get(LPI_LiteralConstant.PORTAL_NOTIFICATION_RECORDTYPE_DEV_NAME)
            ?.getRecordTypeId();

        List<Notification__c> toInsert = new List<Notification__c>();
        for (IndividualApplication app : apps) {
            String newStatus = statusByAppId.containsKey(app.Id) && String.isNotBlank(statusByAppId.get(app.Id))
                ? statusByAppId.get(app.Id)
                : app.Status;
            if (String.isBlank(newStatus) || !PORTAL_STATUS_SET.contains(newStatus)) {
                continue;
            }

            Notification__c notif = new Notification__c();
            if (portalRtId != null) {
                notif.RecordTypeId = portalRtId;
            }
            notif.Account__c = app.AccountId;
            notif.Individual_Application__c = app.Id;
            notif.Title__c = NOTIFICATION_TITLE;
            notif.Subject__c = newStatus == LPI_LiteralConstant.IA_LICENSEISSUED_STATUS
                ? 'License Issued'
                : 'Application Submitted';
            notif.Description__c = app.Name + ' status changed to ' + newStatus + '.';
            notif.is_Read__c = false;
            notif.Is_Resolved__c = false;
            notif.Record_Id__c = app.Id;
            toInsert.add(notif);
        }

        if (!toInsert.isEmpty()) {
            insert toInsert;
        }
    }
}