/**
 * @description Facade Apex controller for LpiHeaderAuraCmp (theme-compatible Aura header).
 *              Wraps notification, account-switch, language, and user-info methods used by the header.
 */
public without sharing class LpiHeaderAuraCtrl {

    private static final String CLASS_NAME = 'LpiHeaderAuraCtrl';

    @AuraEnabled
    public static Map<String, Object> getHeaderNotifications(String language) {
        return LPI_NotificationController.getHeaderNotifications(language);
    }

    @AuraEnabled
    public static void markHeaderNotificationsRead(List<Id> notificationIds) {
        LPI_NotificationController.markHeaderNotificationsRead(notificationIds);
    }

    @AuraEnabled
    public static Map<String, Object> getAcrRecords() {
        return LPI_FCDashboardProfileCompletion.getAcrRecords();
    }

    @AuraEnabled
    public static void updateAcrSelectedOnParentAccount(String accountId) {
        LPI_FCDashboardProfileCompletion.updateAcrSelectedOnParentAccount(accountId);
    }

    @AuraEnabled
    public static String setLanguage(String languageLocaleKey) {
        return EMP_LanguageCtrl.setLanguage(languageLocaleKey);
    }

    @AuraEnabled
    public static Map<String, String> getLabels(List<String> apiNames, String language) {
        return EMP_LanguageCtrl.getLabels(apiNames, language);
    }

    @AuraEnabled
    public static Map<String, String> getCurrentUserInfo() {
        try {
            User u = [
                SELECT Id, Name, SmallPhotoUrl
                FROM User
                WHERE Id = :UserInfo.getUserId()
                LIMIT 1
            ];
            return new Map<String, String>{
                'Name' => u.Name,
                'SmallPhotoUrl' => u.SmallPhotoUrl
            };
        } catch (Exception ex) {
            LPI_ExceptionManager.logException(CLASS_NAME, 'getCurrentUserInfo', ex);
            throw new AuraHandledException(ex.getMessage());
        }
    }
}