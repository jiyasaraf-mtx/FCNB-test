/*
    @author: George Acker
    @description: helper for objects leveraging the sharing helper
        when the owner of a record changes, we need to process Sharing Ledger records for the old owner
        this is because Salesforce is quirky with apex sharing
            1. it doesn't support custom sharing reasons for standard objects
            2. if you try to insert a share record with 'Manual' as the reason, it throws an error if that user is the owner of the record
*/

public without sharing class SharingLedger_SourceObjectTriggerHelper
{
    public static void detectAndProcessSharingDueToOwnerChange(sObject[] records, Map<Id,sObject> oldMap)
    {
        Map<Id,Id> records_with_new_owners = new Map<Id,Id>();
        for (sObject record :records)
        {
            if (oldMap != NULL && (Id)oldMap.get(record.Id).get('OwnerId') != (Id) record.get('OwnerId'))
            {
                records_with_new_owners.put(record.Id, (Id) record.get('OwnerId'));
            }
        }
        if(!records_with_new_owners.isEmpty()){
            Sharing_Ledger__c[] records_to_process = [
                SELECT Id,Name,Source_Table__c,Source_Table_Id__c,Share_Table__c,Share_Table_Id__c,
                Access_Level__c,Share_Reason__c,User_or_Group_Id__c
                FROM Sharing_Ledger__c
                WHERE Share_Reason__c = :LPI_SharingLedger_Helper.ROW_CAUSE_MANUAL
                AND Source_Table_Id__c IN :records_with_new_owners.keySet()
            ];
            Sharing_Ledger__c[] records_needing_sharing = new Sharing_Ledger__c[]{};
                for(Sharing_Ledger__c record :records_to_process)
            {
                Id new_owner = (records_with_new_owners.get(record.Id));
                if (record.User_or_Group_Id__c != new_owner)
                    records_needing_sharing.add(record);
            }
            if(!records_needing_sharing.isEmpty()){
                LPI_SharingLedger_Helper.processSharing(records_needing_sharing, LPI_SharingLedger_Helper.DMLOperation.DML_Insert);
                update records_needing_sharing;
            } 
        }
    }
    
}