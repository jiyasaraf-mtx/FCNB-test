/**
 * @description Portal header notifications for Individual Application events.
 *              Shows Portal_Notification records plus Email_Notification records created on
 *              application submit (Receipt Confirmation) and License Issued.
 *              empApi is unsupported in Experience Cloud, so the header polls this Apex API.
 *              Titles and bodies resolve from Custom Labels for EN/FR.
 */
public without sharing class LPI_NotificationController {

    private static final String CLASS_NAME = 'LPI_NotificationController';
    private static final String CAT_LICENSE_ISSUED = 'LICENSE_ISSUED';
    private static final String CAT_APPLICATION_SUBMITTED = 'APPLICATION_SUBMITTED';
    private static final String CAT_ACTION_REQUIRED = 'ACTION_REQUIRED';
    private static final String CAT_DEFICIENCY = 'DEFICIENCY';
    private static final String CAT_STATUS_UPDATE = 'STATUS_UPDATE';
    private static final String CAT_FF_MISSING_SCHEDULE = 'FF_MISSING_SCHEDULE';
    private static final String FF_NOTIF_TITLE = 'financial filing update';
    private static final Integer BODY_PREVIEW_LENGTH = 100;
    private static final Integer HEADER_LIMIT = 20;
    private static final Integer DISPLAY_LIMIT = 10;

    /**
     * @description Returns recent portal / email notifications for the logged-in user's account(s).
     * @param language Optional portal language (en_US or fr). Falls back to user language.
     */
    @AuraEnabled
    public static Map<String, Object> getHeaderNotifications(String language) {
        Map<String, Object> result = new Map<String, Object>();
        List<Map<String, Object>> notifications = new List<Map<String, Object>>();
        Integer unreadCount = 0;
        String lang = resolveLanguage(language);
        Map<String, String> labels = loadNotificationLabels(lang);

        try {
            Set<Id> accountIds = getCurrentUserAccountIds();
            if (accountIds.isEmpty()) {
                result.put('notifications', notifications);
                result.put('unreadCount', 0);
                return result;
            }

            Id portalRtId = Schema.SObjectType.Notification__c
                .getRecordTypeInfosByDeveloperName()
                .get(LPI_LiteralConstant.PORTAL_NOTIFICATION_RECORDTYPE_DEV_NAME)
                ?.getRecordTypeId();
            Id emailRtId = Schema.SObjectType.Notification__c
                .getRecordTypeInfosByDeveloperName()
                .get(LPI_LiteralConstant.EMAIL_NOTIFICATION_RECORDTYPE_DEV_NAME)
                ?.getRecordTypeId();

            Set<Id> recordTypeIds = new Set<Id>();
            if (portalRtId != null) {
                recordTypeIds.add(portalRtId);
            }
            if (emailRtId != null) {
                recordTypeIds.add(emailRtId);
            }

            String soql =
                'SELECT Id, Title__c, Description__c, Subject__c, is_Read__c, CreatedDate, RecordTypeId, ' +
                'Record_Id__c, Individual_Application__c, Individual_Application__r.Name ' +
                'FROM Notification__c ' +
                'WHERE Account__c IN :accountIds ' +
                'AND Is_Resolved__c = false ' +
                'AND (Individual_Application__c != null OR Record_Id__c != null) ';
            if (!recordTypeIds.isEmpty()) {
                soql += 'AND RecordTypeId IN :recordTypeIds ';
            }
            soql += 'ORDER BY CreatedDate DESC LIMIT :HEADER_LIMIT';

            List<Notification__c> notifs = Database.query(soql);
            Map<Id, Financial_Filing__c> filingByRecordId = loadFinancialFilings(notifs);

            Set<String> dedupeKeys = new Set<String>();
            for (Notification__c notif : notifs) {
                if (!isHeaderEligible(notif, portalRtId, emailRtId)) {
                    continue;
                }

                String category = resolveCategory(notif);
                String dedupeSource = notif.Individual_Application__c != null
                    ? String.valueOf(notif.Individual_Application__c)
                    : String.valueOf(notif.Record_Id__c);
                String dedupeKey = dedupeSource + '|' + category;
                if (dedupeKeys.contains(dedupeKey)) {
                    continue;
                }
                dedupeKeys.add(dedupeKey);

                String title = resolveTitleLabel(category, labels);
                String body = resolveBody(notif, category, labels, filingByRecordId);
                Boolean isRead = notif.is_Read__c == true;
                if (!isRead) {
                    unreadCount++;
                }

                String appName = notif.Individual_Application__r != null
                    ? notif.Individual_Application__r.Name
                    : null;

                notifications.add(new Map<String, Object>{
                    'id' => notif.Id,
                    'title' => title,
                    'body' => body,
                    'category' => category,
                    'applicationName' => appName,
                    'date' => formatNotificationDate(notif.CreatedDate, lang),
                    'isRead' => isRead
                });

                if (notifications.size() >= DISPLAY_LIMIT) {
                    break;
                }
            }
        } catch (Exception ex) {
            LPI_ExceptionManager.logException(CLASS_NAME, 'getHeaderNotifications', ex);
        }

        result.put('notifications', notifications);
        result.put('unreadCount', unreadCount);
        return result;
    }

    /**
     * @description Marks header notifications as read for the logged-in user.
     */
    @AuraEnabled
    public static void markHeaderNotificationsRead(List<Id> notificationIds) {
        if (notificationIds == null || notificationIds.isEmpty()) {
            return;
        }
        try {
            Set<Id> accountIds = getCurrentUserAccountIds();
            if (accountIds.isEmpty()) {
                return;
            }

            List<Notification__c> toUpdate = [
                SELECT Id, is_Read__c
                FROM Notification__c
                WHERE Id IN :notificationIds
                  AND Account__c IN :accountIds
                  AND is_Read__c = false
            ];
            for (Notification__c notif : toUpdate) {
                notif.is_Read__c = true;
            }
            if (!toUpdate.isEmpty()) {
                LPI_WithoutSharingUtility.updateSObjectList(toUpdate);
            }
        } catch (Exception ex) {
            LPI_ExceptionManager.logException(CLASS_NAME, 'markHeaderNotificationsRead', ex);
            throw new AuraHandledException(ex.getMessage());
        }
    }

    private static Boolean isHeaderEligible(Notification__c notif, Id portalRtId, Id emailRtId) {
        Boolean hasLink = notif.Individual_Application__c != null
            || String.isNotBlank(notif.Record_Id__c);
        if (!hasLink) {
            return false;
        }
        if (portalRtId != null && notif.RecordTypeId == portalRtId) {
            return true;
        }
        if (emailRtId != null && notif.RecordTypeId == emailRtId) {
            return true;
        }
        return false;
    }

    private static String resolveCategory(Notification__c notif) {
        String subject = String.isNotBlank(notif.Subject__c)
            ? decodeHtmlEntities(notif.Subject__c.stripHtmlTags()).toLowerCase()
            : '';
        String title = String.isNotBlank(notif.Title__c) ? notif.Title__c.toLowerCase() : '';
        String combined = subject + ' ' + title;

        if (combined.contains('request missing schedule')
            || (title.contains(FF_NOTIF_TITLE) && subject.contains('missing schedule'))) {
            return CAT_FF_MISSING_SCHEDULE;
        }
        if (combined.contains('license') && (combined.contains('issued') || combined.contains('has been issued'))) {
            return CAT_LICENSE_ISSUED;
        }
        if (combined.contains('receipt confirmation') || combined.contains('application submitted')
            || combined.contains('submitted')) {
            return CAT_APPLICATION_SUBMITTED;
        }
        if (combined.contains('deficiency') || combined.contains('require more info')
            || combined.contains('additional information')) {
            return CAT_DEFICIENCY;
        }
        if (combined.contains('action pending') || combined.contains('action required')
            || combined.contains('student enrolment') || combined.contains('student enrollment')) {
            return CAT_ACTION_REQUIRED;
        }
        return CAT_STATUS_UPDATE;
    }

    private static String resolveTitleLabel(String category, Map<String, String> labels) {
        if (CAT_FF_MISSING_SCHEDULE.equals(category)) {
            return labels.get('EP_FF_Notif_Title');
        }
        if (CAT_LICENSE_ISSUED.equals(category)) {
            return labels.get('LP_License_Issued');
        }
        if (CAT_APPLICATION_SUBMITTED.equals(category)) {
            return labels.get('LP_Notif_Application_Submitted');
        }
        if (CAT_DEFICIENCY.equals(category)) {
            return labels.get('LP_Notif_Additional_Info');
        }
        if (CAT_ACTION_REQUIRED.equals(category)) {
            return labels.get('EP_Action_Required');
        }
        return labels.get('LP_Notif_Status_Update');
    }

    private static String resolveBody(
        Notification__c notif,
        String category,
        Map<String, String> labels,
        Map<Id, Financial_Filing__c> filingByRecordId
    ) {
        if (CAT_FF_MISSING_SCHEDULE.equals(category)) {
            return resolveFinancialFilingBody(notif, labels, filingByRecordId);
        }

        String appName = notif.Individual_Application__r != null
            ? notif.Individual_Application__r.Name
            : null;
        String appLabel = String.isNotBlank(appName) ? appName : labels.get('LP_Notif_Your_Application');

        if (CAT_LICENSE_ISSUED.equals(category)) {
            return formatTemplate(labels.get('LP_Notif_License_Issued_Body'), appLabel);
        }
        if (CAT_APPLICATION_SUBMITTED.equals(category)) {
            return formatTemplate(labels.get('LP_Notif_Application_Submitted_Body'), appLabel);
        }
        if (CAT_DEFICIENCY.equals(category)) {
            return formatTemplate(labels.get('LP_Notif_Deficiency_Body'), appLabel);
        }
        if (CAT_ACTION_REQUIRED.equals(category)) {
            return formatTemplate(labels.get('LP_Notif_Action_Required_Body'), appLabel);
        }

        String raw = String.isNotBlank(notif.Description__c)
            ? decodeHtmlEntities(notif.Description__c.stripHtmlTags()).replaceAll('\\s+', ' ').trim()
            : '';
        if (String.isNotBlank(raw) && raw.length() <= BODY_PREVIEW_LENGTH
            && !raw.toLowerCase().contains('congratulations')
            && !raw.toLowerCase().contains('dear ')) {
            return raw;
        }
        return formatTemplate(labels.get('LP_Notif_Status_Updated_Body'), appLabel);
    }

    private static String formatTemplate(String template, String value) {
        if (String.isBlank(template)) {
            return value;
        }
        return template.replace('{0}', value == null ? '' : value);
    }

    private static String formatTemplate(String template, String value0, String value1) {
        if (String.isBlank(template)) {
            return value0;
        }
        return template
            .replace('{0}', value0 == null ? '' : value0)
            .replace('{1}', value1 == null ? '' : value1);
    }

    private static Map<Id, Financial_Filing__c> loadFinancialFilings(List<Notification__c> notifs) {
        Map<Id, Financial_Filing__c> result = new Map<Id, Financial_Filing__c>();
        Set<Id> filingIds = new Set<Id>();
        for (Notification__c notif : notifs) {
            if (String.isNotBlank(notif.Record_Id__c) && CAT_FF_MISSING_SCHEDULE.equals(resolveCategory(notif))) {
                try {
                    filingIds.add((Id) notif.Record_Id__c);
                } catch (Exception ignored) {
                    // Record_Id__c is a free-text field; skip values that are not filing ids.
                }
            }
        }
        if (filingIds.isEmpty()) {
            return result;
        }
        for (Financial_Filing__c filing : [
            SELECT Id, Name, Reporting_Year__c
            FROM Financial_Filing__c
            WHERE Id IN :filingIds
        ]) {
            result.put(filing.Id, filing);
        }
        return result;
    }

    private static String resolveFinancialFilingBody(
        Notification__c notif,
        Map<String, String> labels,
        Map<Id, Financial_Filing__c> filingByRecordId
    ) {
        String filingNumber = '';
        String reportingYear = '';

        Financial_Filing__c filing = null;
        if (String.isNotBlank(notif.Record_Id__c)) {
            try {
                filing = filingByRecordId.get((Id) notif.Record_Id__c);
            } catch (Exception ignored) {
                filing = null;
            }
        }
        if (filing != null) {
            filingNumber = filing.Name;
            reportingYear = filing.Reporting_Year__c;
        } else if (String.isNotBlank(notif.Description__c)) {
            String raw = decodeHtmlEntities(notif.Description__c.stripHtmlTags()).trim();
            List<String> parts = raw.split('\\|');
            if (!parts.isEmpty()) {
                filingNumber = parts[0].trim();
            }
            if (parts.size() > 1) {
                reportingYear = parts[1].trim();
            }
        }

        return formatTemplate(labels.get('EP_FF_Notif_Body_Missing_Schedule'), filingNumber, reportingYear);
    }

    private static String formatNotificationDate(Datetime created, String language) {
        if (created == null) {
            return '';
        }
        try {
            String locale = (language != null && language.startsWith('fr')) ? 'fr_CA' : 'en_CA';
            return created.format('MMM d, h:mm a', locale);
        } catch (Exception e) {
            return created.format('MMM d, h:mm a');
        }
    }

    private static String resolveLanguage(String language) {
        if (String.isNotBlank(language) && language.startsWith('fr')) {
            return 'fr';
        }
        if (String.isBlank(language)) {
            try {
                String userLang = UserInfo.getLanguage();
                if (userLang != null && userLang.startsWith('fr')) {
                    return 'fr';
                }
            } catch (Exception e) {
                // fall through
            }
        }
        return 'en_US';
    }

    private static Map<String, String> loadNotificationLabels(String language) {
        List<String> apiNames = new List<String>{
            'LP_License_Issued',
            'LP_Notif_Application_Submitted',
            'LP_Notif_Additional_Info',
            'LP_Notif_Status_Update',
            'EP_Action_Required',
            'LP_Notif_License_Issued_Body',
            'LP_Notif_Application_Submitted_Body',
            'LP_Notif_Deficiency_Body',
            'LP_Notif_Action_Required_Body',
            'LP_Notif_Status_Updated_Body',
            'LP_Notif_Your_Application',
            'LP_Notif_Multiple_Updated',
            'LP_Notifications',
            'LP_No_Notifications',
            'EP_FF_Notif_Title',
            'EP_FF_Notif_Subject_Missing_Schedule',
            'EP_FF_Notif_Body_Missing_Schedule'
        };
        Map<String, String> result = new Map<String, String>();
        String lang = resolveLanguage(language);
        for (String apiName : apiNames) {
            try {
                result.put(apiName, System.Label.get('', apiName, lang));
            } catch (Exception e) {
                result.put(apiName, apiName);
            }
        }
        return result;
    }

    private static String decodeHtmlEntities(String value) {
        if (String.isBlank(value)) {
            return value;
        }
        return value
            .replace('&amp;', '&')
            .replace('&lt;', '<')
            .replace('&gt;', '>')
            .replace('&quot;', '"')
            .replace('&#39;', '\'');
    }

    private static Set<Id> getCurrentUserAccountIds() {
        Set<Id> accountIds = new Set<Id>();
        User currentUser = [
            SELECT Id, AccountId
            FROM User
            WHERE Id = :UserInfo.getUserId()
            LIMIT 1
        ];
        if (currentUser.AccountId == null) {
            return accountIds;
        }

        accountIds.add(currentUser.AccountId);
        List<Account> accounts = [
            SELECT Id, SelectedAccountId__c
            FROM Account
            WHERE Id = :currentUser.AccountId
            LIMIT 1
        ];
        if (!accounts.isEmpty() && accounts[0].SelectedAccountId__c != null) {
            accountIds.add(accounts[0].SelectedAccountId__c);
        }
        return accountIds;
    }
}