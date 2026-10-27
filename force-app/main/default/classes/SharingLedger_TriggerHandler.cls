/*
    @author: George Acker
    @description: trigger handler for the Sharing_Ledger__c object
        inserts/updates/deletes records in the corresponding __share table based on inputs
*/

public without sharing class SharingLedger_TriggerHandler
{
    
    public static void beforeInsert(Sharing_Ledger__c[] records)
    {
        for (Sharing_Ledger__c record : records)
        {
            record.User_or_Group_Id__c = Id.valueOf(record.User_or_Group_Id__c);
            record.Source_Table_Id__c = Id.valueOf(record.Source_Table_Id__c);
            record.Share_Table__c = LPI_UtilityDescribe.getSharingObjectName(record.Source_Table__c);
        }
        LPI_SharingLedger_Helper.processSharing(records, LPI_SharingLedger_Helper.DMLOperation.DML_INSERT);
    }
    
    public static void beforeUpdate(Sharing_Ledger__c[] records, Map<Id,Sharing_Ledger__c> oldMap)
    {
        Sharing_Ledger__c[] records_with_access_changes = new Sharing_Ledger__c[]{};
        for (Sharing_Ledger__c record : records)
        {
            Sharing_Ledger__c old_record = oldMap.get(record.Id);
            preventUpdatesToFieldsThatShouldNotChange(record, old_record);
            if (old_record.access_level__c != record.access_level__c)
                records_with_access_changes.add(record);
        }
        LPI_SharingLedger_Helper.processSharing(records_with_access_changes, LPI_SharingLedger_Helper.DMLOperation.DML_UPDATE);
        
    }
    
    public static void beforeDelete(Sharing_Ledger__c[] records)
    {
       LPI_SharingLedger_Helper.processSharing(records, LPI_SharingLedger_Helper.DMLOperation.DML_DELETE);
    }
    
    private static void preventUpdatesToFieldsThatShouldNotChange(Sharing_Ledger__c record, Sharing_Ledger__c old_record)
    {
        for (String field_name :LPI_SharingLedger_Helper.uneditable_fields)
        {
            if (record.get(field_name) != old_record.get(field_name))
                record.addError(LPI_SharingLedger_Helper.errorMessageUneditableField(field_name));
        }
    }
}