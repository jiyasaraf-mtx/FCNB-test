/**
 * @author              : MTX Group Product Team
 * @since               : 13th Feb, 2023
 * @description         : This Class will be used to get the globle describe methods
 * @history
 * -------------------------------------------------------------------------------------------------------
 * Version      Date                Author                  Details
 *    1         13th Feb, 2023      MTX Group Product Team        	Initial Developement
 * -------------------------------------------------------------------------------------------------------
 */
public class LPI_UtilityDescribe {

    /**
     * **********************
     *  RECORDTYPE UTILITIES
     * **********************
     */
    @TestVisible
    private static Map<String, Map<String, Id>> RECORDTYPE_ID_BY_NAME_BY_SOBJECT;
    
    // property to get globalDescribe once and persist
    public static Map<String, Schema.SObjectType> globalDescribe{
        get{
            if (globalDescribe == NULL){
                globalDescribe = Schema.getGlobalDescribe();
            }
            return globalDescribe;
        }
        set;
    }
    
    // method that takes an sObject API name and returns the corresponding share sObject API name
    public static String getSharingObjectName(String sObjectType){
        if (sObjectType.endsWith('__c'))
            return sObjectType.replace('__c','__share');
        else
            return sObjectType + 'Share';
    }
    
    // method that takes a field relationship name and returns the API name of the ID field
    public static String getIdFieldNameFromRelationship(String fld)
    {
        if (fld.right(3) == '__r')
            return fld.replace('__r','__c');
        else
            return fld + 'Id';
    }
    
    public static Schema.sObjectField getSObjectFieldType(String fldExpression)
    {
        String[] pieces = fldExpression.split('\\.');
        Schema.sObjectType objType = globalDescribe.get(pieces[0]);
        if (objType == null)
            return null;
        for (integer i=1; i<pieces.size()-1; i++)
        {
            String fldExp = getIdFieldNameFromRelationship(pieces[i]);
            Schema.sObjectField fldType = objType.getDescribe().fields.getMap().get(fldExp);
            if (fldType == null)
                return null;
            objType = fldType.getDescribe().getReferenceTo()[0];
        }
        Schema.sObjectField fldType = objType.getDescribe().fields.getMap().get(pieces[pieces.size()-1]);
        return fldType;
    }
    
    public static Boolean isFieldAccessible(String fldExpression){
        Schema.sObjectField fld = getSObjectFieldType(fldExpression);
        return fld?.getDescribe().isAccessible();
    }
    
    /**
     * @author                      : MTX Group Product Team
     * @since                       : 13th Feb, 2023
     * @description                 : This method calls invoke method
     * @param sObjectApiName        : Api name of SObject
     * @param recordTypeName        : Developer Name of RecordType
     * @retun                       : 'recordTypeId'
     * @last modified by            : MTX Group Product Team
     * @last modified date          :
     * @modified details            :
     */
    public static Id getRecordTypeIdWithName(String sObjectApiName, String recordTypeName) {
        Id recordTypeId = null;
        if(String.isBlank(sObjectApiName)) {
            sObjectApiName = '';
        }
        if(String.isBlank(recordTypeName)) {
            recordTypeName = '';
        }
        sObjectApiName = sObjectApiName.toLowerCase();
        recordTypeName = recordTypeName.toLowerCase();
        if(RECORDTYPE_ID_BY_NAME_BY_SOBJECT == null) {
            RECORDTYPE_ID_BY_NAME_BY_SOBJECT = new Map<String, Map<String,Id>>();
        }
        if(RECORDTYPE_ID_BY_NAME_BY_SOBJECT.get(sObjectApiName) == null) {
            Map<String, Schema.SObjectType> sObjectTypeByName = Schema.getGlobalDescribe();
	        Schema.SObjectType sObjType = sObjectTypeByName.get(sObjectApiName);
            if(sObjType != null) {
                Map<String, Id> recordTypeIdByName = new Map<String, Id>();
                for(Schema.RecordTypeInfo r : sObjType.getDescribe().getRecordTypeInfos()) {
                    recordTypeIdByName.put(r.getDeveloperName().toLowerCase(), r.getRecordTypeId());
                }
                RECORDTYPE_ID_BY_NAME_BY_SOBJECT.put(sObjectApiName, recordTypeIdByName);
            }
        }
        if(RECORDTYPE_ID_BY_NAME_BY_SOBJECT.get(sObjectApiName) != null) {
            return RECORDTYPE_ID_BY_NAME_BY_SOBJECT.get(sObjectApiName).get(recordTypeName);
        }
        return recordTypeId;
    }
    
    /**
     * @author                      : MTX Group Product Team
     * @since                       : 13th Feb, 2023
     * @description                 : This method gets field set by object and field
     * @param sObjectApiName        : Api name of SObject, FieldSet
     * @retun                       : 'List<Schema.FieldSetMember>'
     */
    public static List<Schema.FieldSetMember> getFieldSetByName(String fieldSetName, String sObjectName){                
        Schema.FieldSet fieldSetObj = 
            globalDescribe.get(
                sObjectName
            ).getDescribe().FieldSets.getMap()?.get(fieldSetName);
          
        return fieldSetObj?.getFields();
    }  
}