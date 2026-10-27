public with sharing class DocumentSearchController {

    @AuraEnabled(cacheable=true)
    public static FilterOptionsWrapper getFilterOptions() {
        FilterOptionsWrapper wrapper = new FilterOptionsWrapper();
        
        // Status picklist values from Application_Document__c
        wrapper.statusOptions = getPicklistValues('Application_Document__c', 'Status__c');
        
        // LicenseType picklist values from IndividualApplication
        wrapper.typeOptions = getPicklistValues('IndividualApplication', 'LicenseType'); 
        
        return wrapper;
    }

    @AuraEnabled
    public static List<Application_Document__c> searchDocuments(String category, String selectedType, String status, String searchKey) {
        String query = 'SELECT Id, Name, Document_Name__c, Status__c, Type__c, Sub_Type__c, ' +
                       'Individual_Application__c, Individual_Application__r.Name ' +
                       'FROM Application_Document__c WHERE Id != NULL';

        if (String.isNotBlank(category) && category == 'Application') {
            query += ' AND Individual_Application__c != NULL';
        }

        if (String.isNotBlank(selectedType)) {
            query += ' AND Individual_Application__r.LicenseType = :selectedType';
        }

        if (String.isNotBlank(status)) {
            query += ' AND Status__c = :status';
        }

        if (String.isNotBlank(searchKey)) {
            String key = '%' + String.escapeSingleQuotes(searchKey) + '%';
            query += ' AND (Individual_Application__r.Name LIKE :key OR Name LIKE :key OR Document_Name__c LIKE :key)';
        }

        query += ' ORDER BY CreatedDate DESC LIMIT 200';

        return Database.query(query);
    }

    private static List<Map<String, String>> getPicklistValues(String objectName, String fieldName) {
        List<Map<String, String>> options = new List<Map<String, String>>();
        Schema.SObjectType sObjectType = Schema.getGlobalDescribe().get(objectName);
        
        if (sObjectType != null) {
            Schema.DescribeSObjectResult describeResult = sObjectType.getDescribe();
            Map<String, Schema.SObjectField> fieldsMap = describeResult.fields.getMap();
            
            if (fieldsMap.containsKey(fieldName)) {
                List<Schema.PicklistEntry> picklistValues = fieldsMap.get(fieldName).getDescribe().getPicklistValues();
                for (Schema.PicklistEntry entry : picklistValues) {
                    if (entry.isActive()) {
                        Map<String, String> option = new Map<String, String>();
                        option.put('label', entry.getLabel());
                        option.put('value', entry.getValue());
                        options.add(option);
                    }
                }
            }
        }
        return options;
    }

    public class FilterOptionsWrapper {
        @AuraEnabled public List<Map<String, String>> statusOptions;
        @AuraEnabled public List<Map<String, String>> typeOptions;
    }
}