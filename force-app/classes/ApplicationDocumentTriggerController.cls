public class ApplicationDocumentTriggerController {
    public static void updatestatusOnIA(List<Application_Document__c> appDocData){
        // Guard: this org may not have the Employer Portal user (e.g. FCNB Licensing).
        // A hard SOQL assignment previously rolled back ALL Application_Document inserts.
        List<User> employerPortalUsers = [
            SELECT Id, Name
            FROM User
            WHERE Name = 'Employer Portal user'
            LIMIT 1
        ];
        if (employerPortalUsers.isEmpty()) {
            return;
        }
        User user = employerPortalUsers[0];
        Set<String> setOfIndApp = new Set<String>();
        for (Application_Document__c appDoc : appDocData) {
            if (appDoc.OwnerId != null && user.Id == appDoc.OwnerId && appDoc.Type__c == 'Renewal') {
                setOfIndApp.add(appDoc.Individual_Application__c);
            }
        }

        if (setOfIndApp.size() > 0) {
            List<IndividualApplication> indiAppList = [
                SELECT Id, Name, Status
                FROM IndividualApplication
                WHERE Id IN :setOfIndApp AND Status = 'Additional Doc Upload'
            ];
            if (!indiAppList.isEmpty()) {
                for (IndividualApplication indApp : indiAppList) {
                    indApp.Status = 'Employer Review Completed';
                }
                update indiAppList;
            }
        }
    }
}
