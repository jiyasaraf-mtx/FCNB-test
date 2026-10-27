/**
 * Employer Portal language + translated Custom Labels.
 * Uses System.Label.get(language) so FR strings work even when
 * community users cannot persist User.LanguageLocaleKey.
 */
public without sharing class EMP_LanguageCtrl {
    private static final Set<String> SUPPORTED = new Set<String>{ 'en_US', 'fr' };

    @AuraEnabled
    public static String getCurrentLanguage() {
        User u = [
            SELECT LanguageLocaleKey
            FROM User
            WHERE Id = :UserInfo.getUserId()
            LIMIT 1
        ];
        String lang = u.LanguageLocaleKey;
        if (lang != null && lang.startsWith('fr')) {
            return 'fr';
        }
        return 'en_US';
    }

    @AuraEnabled
    public static String setLanguage(String languageLocaleKey) {
        if (String.isBlank(languageLocaleKey) || !SUPPORTED.contains(languageLocaleKey)) {
            throw new AuraHandledException('Unsupported language: ' + languageLocaleKey);
        }
        try {
            update new User(
                Id = UserInfo.getUserId(),
                LanguageLocaleKey = languageLocaleKey
            );
        } catch (Exception e) {
            // Community users may be blocked from updating User language.
            // Client still applies translations via getLabels + localStorage.
            System.debug(LoggingLevel.WARN, 'EMP_LanguageCtrl.setLanguage User update skipped: ' + e.getMessage());
        }
        return languageLocaleKey;
    }

    /**
     * Returns Custom Label values for the requested language (en_US or fr).
     */
    @AuraEnabled
    public static Map<String, String> getLabels(List<String> apiNames, String language) {
        String lang = (String.isNotBlank(language) && language.startsWith('fr')) ? 'fr' : 'en_US';
        Map<String, String> result = new Map<String, String>();
        if (apiNames == null) {
            return result;
        }
        for (String apiName : apiNames) {
            if (String.isBlank(apiName)) {
                continue;
            }
            try {
                result.put(apiName, System.Label.get('', apiName, lang));
            } catch (Exception e) {
                result.put(apiName, apiName);
            }
        }
        return result;
    }
}