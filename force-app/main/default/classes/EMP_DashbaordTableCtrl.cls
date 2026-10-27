public with sharing class EMP_DashbaordTableCtrl {

    @AuraEnabled(cacheable=true)
    public static List<IndividualApplication> fetchSelectedApplicationRecords(){
        try {
            List<IndividualApplication> selectedAppRecords = [SELECT Id, Name, Status,Applicant_submission_Date__c,Admin_Action_Status__c,License_Type_Name__c,Applicant_Full_Name__c,ApplicationType
                                                              FROM IndividualApplication 
                                                              WHERE status = 'Additional Doc Upload'];
            if(selectedAppRecords.size() > 0 ){
                return selectedAppRecords;
            }
            return null;
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}