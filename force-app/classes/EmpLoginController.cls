public without sharing class EmpLoginController {
    public EmpLoginController() {
    }

    /**
     * Authenticates a community user and optionally syncs LanguageLocaleKey from the
     * Guest portal preference (e.g. French selected before login) onto that User.
     * @param username Portal username / email
     * @param password Password
     * @param languageLocaleKey Optional en_US or fr from Guest localStorage / login picker
     */
    @AuraEnabled
    public static String authenticateUser(String username, String password, String languageLocaleKey) {
        try {
            String lang = null;
            if (String.isNotBlank(languageLocaleKey)) {
                if (languageLocaleKey.startsWith('fr')) {
                    lang = 'fr';
                } else if (languageLocaleKey == 'en_US' || languageLocaleKey.startsWith('en')) {
                    lang = 'en_US';
                }
            }

            // Apply Guest language choice onto the User before Site.login redirect
            if (String.isNotBlank(username) && lang != null) {
                EMP_LanguageCtrl.setLanguageForUsername(username, lang);
            }

            String startUrl = '';
            if (lang != null) {
                startUrl = '/s/?language=' + EncodingUtil.urlEncode(lang, 'UTF-8');
            }
            PageReference loginPage = Site.login(username, password, startUrl);
            System.debug('loginPage:- ' + loginPage);

            if (loginPage != null) {
                return loginPage.getUrl();
            }
            return 'Invalid username or password';
        } catch (Exception e) {
            return 'Error: ' + e.getMessage();
        }
    }
}
