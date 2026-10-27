public with sharing class EmpLoginController {
    public EmpLoginController() {

    }
    @AuraEnabled
    public static String authenticateUser(String username, String password) {
        try {
            // Use Site.login to authenticate the user
            String startUrl = ''; // You can specify a start URL if needed
            PageReference loginPage = Site.login(username, password, startUrl);
            System.debug('loginPage:- '+loginPage);

            if (loginPage != null) {
                // Authentication successful
                return loginPage.geturl();
            } else {
                // Authentication failed
                return 'Invalid username or password';
            }
        } catch (Exception e) {
            // Return error message
            return 'Error: ' + e.getMessage();
        }
    }
}