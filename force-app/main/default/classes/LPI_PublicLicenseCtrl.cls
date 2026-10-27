public without sharing class LPI_PublicLicenseCtrl {
    public static final String CLASS_NAME = 'LPI_PublicLicenseCtrl';

    @AuraEnabled
    public static List<HeadingFieldValueWrapper> getApplicationData(String blId,String raId) {
        try {
            List<HeadingFieldValueWrapper> applicationViewList = new List<HeadingFieldValueWrapper>();
            List<License_Search_Configuration__c>  configList = [SELECT Id,Business_License_Object_Fields__c,Status__c from License_Search_Configuration__c WHERE Id = 'a0v3R000000Jy16QAC'];
            if(!configList.isEmpty()){
                Map<String,String> fieldValueMap = (Map<String,String>)JSON.deserialize(configList[0].Business_License_Object_Fields__c,Map<String,String>.Class);
                String fields = String.join(new List<String>(fieldValueMap.keySet()), ',' );
                String query = 'SELECT '+ fields +' FROM BusinessLicense ';
                query += ' WHERE Id = \'' + String.escapeSingleQuotes(blId) + '\'';
                List<BusinessLicense> blRecordList = Database.query(query);
                if (!blRecordList.isEmpty()) {
                    BusinessLicense blRecord = blRecordList[0];
                    applicationViewList.add(getLicenseDetail(blRecord,fieldValueMap));
                    applicationViewList.add(getLicenseDetail(blRecord,fieldValueMap));
                    applicationViewList.add(getLicenseDetail(blRecord,fieldValueMap));
                    return applicationViewList;
                }
            }
            return null;
        } catch (Exception e) {
            LPI_ExceptionManager.logException(CLASS_NAME,'getApplicationData',e);
            throw new AuraHandledException(e.getMessage());
        }
    }
    public static HeadingFieldValueWrapper getLicenseDetail(BusinessLicense blRecord,Map<String,String> fieldValueMap) {
        try {
            HeadingFieldValueWrapper headingFields = new HeadingFieldValueWrapper();
            List<FieldValueWrapper> fieldValues = new List<FieldValueWrapper>();
            for(String key : fieldValueMap.keySet()){
                String typeValue = LPI_UtilityDescribe.globalDescribe.get('BusinessLicense')
					.getDescribe()
					.fields.getMap()
					.get((String) key)
					.getDescribe()
					.getType()
					.name();
                if(typeValue == 'Datetime'){
                    DateTime dt = DateTime.valueOf(string.valueOf(blRecord.get(key)));
                    fieldValues.add(new FieldValueWrapper(fieldValueMap.get(key),string.valueOf(dt.format('MM/dd/yyyy')),true));
                }else{
                    fieldValues.add(new FieldValueWrapper(fieldValueMap.get(key),string.valueOf(blRecord.get(key)),true));
                } 
            }
            return new HeadingFieldValueWrapper('License',fieldValues);
        } catch (Exception e) {
            LPI_ExceptionManager.logException(CLASS_NAME,'getLicenseDetail',e);
            throw new AuraHandledException(e.getMessage());
        }
    }
    public class FieldValueWrapper {
        @AuraEnabled public String label;
        @AuraEnabled public String value;
        @AuraEnabled public Boolean isCoverCompleteWidth;
        public FieldValueWrapper() {
        }
        public FieldValueWrapper(String label, String value,Boolean isCoverCompleteWidth) {
            this.label = label;
            this.value = value;
            this.isCoverCompleteWidth = isCoverCompleteWidth;
        }
    }

    public class HeadingFieldValueWrapper {
        @AuraEnabled public String headingName;
        @AuraEnabled public List<FieldValueWrapper> headingFieldValue;
        public HeadingFieldValueWrapper(){

        }
        public HeadingFieldValueWrapper(
            String headingName,
            List<FieldValueWrapper> headingFieldValue
        ) {
            this.headingName = headingName;
            this.headingFieldValue = headingFieldValue;
        }
    }
}