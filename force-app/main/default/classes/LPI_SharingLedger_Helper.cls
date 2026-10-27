/*
    @author: George Acker
    @description: helper for the Sharing_Ledger__c object
        processes DML operations on the corresponding share table based on entries in the Sharing_Ledger__c table
        suppose there are multiple reasons to share an Account record with a user or group
            you can insert multiple records into the Sharing_Ledger__c table and it will manage insert/update in AccountShare for you
            you can delete records as reasons to share are no longer applicable and it will manage update/delete in AccountShare for you
            you can update record access level as needed and it will manage update in AccountShare for you
*/

public inherited sharing class LPI_SharingLedger_Helper
{
    public static final Decimal ACCESS_LEVEL_READ = 1;
    public static final Decimal ACCESS_LEVEL_EDIT = 2;
    public static final String ACCESS_LEVEL_TEXT_READ = 'Read';
    public static final String ACCESS_LEVEL_TEXT_EDIT = 'Edit';
    public static final String ROW_CAUSE_MANUAL = 'Manual';
    private final static String PARENT_ID = 'ParentId';
    private final static String ACCESS_LEVEL = 'AccessLevel';
    public enum DMLOperation {DML_INSERT, DML_UPDATE, DML_DELETE}
    
    public static String[] uneditable_fields
    {
        get
        {
            if(uneditable_fields == null)
            {
                uneditable_fields = new String[]
                {
                    'User_Or_Group_Id__c',
                    'Source_Table__c',
                    'Source_Table_Id__c',
                    'Share_Table__c',
                    'Share_Reason__c'
                };
            }
            return uneditable_fields;
        }
        set;
    }
    
    private static Set<String> managedPackageStandardObject = new Set<String>{
        'PreliminaryApplicationRef',
        'BusinessLicenseApplication',
        'Location',
        'RegulatoryTrxnFee',
        'AuthApplicationPlace',
        'TrainingCourseParticipant',
        'PersonEducation',
        'PersonExamination',
        'TrnCourse',
        'IndividualApplication',
        'AssociatedLocation'
    };
    
    public static Map<String,ObjectMetadataDefinition> map_object_name_to_field_api_names
    {
        get
        {
            if (map_object_name_to_field_api_names == null)
            {
                map_object_name_to_field_api_names = new Map<String,ObjectMetadataDefinition>();
            }
            return map_object_name_to_field_api_names;
        }
        set;
    }
    
    public static String getRowCauseFromShareReason(String share_reason)
    {
        return share_reason;
    }
    
    public static String errorMessageUneditableField(String field_name)
    {
        return field_name + ' is not an editable field';
    }
    
    public static Decimal translateAccessLevel(String access)
    {
        if (access == ACCESS_LEVEL_TEXT_READ)
            return ACCESS_LEVEL_READ;
        else if (access == ACCESS_LEVEL_TEXT_EDIT)
            return ACCESS_LEVEL_EDIT;
        return null;
    }
    
    public static String translateAccessLevel(Decimal access)
    {
        if (access == ACCESS_LEVEL_READ)
            return ACCESS_LEVEL_TEXT_READ;
        else if (access == ACCESS_LEVEL_EDIT)
            return ACCESS_LEVEL_TEXT_EDIT;
        return null;
    }
    
    public static void processSharing(Sharing_Ledger__c[] records, DMLOperation operation)
    {
        Map<String,GroupedLedger> grouped_records = parseLedgersIntoGroups(records);
        // SOQL & DML within loop because we have to.  Different objects are being queried and written to.

        for (String object_name :grouped_records.keySet())
        {
            GroupedLedger grouped_record = grouped_records.get(object_name);
            Map<Id,Id> owner_id_mapping = ownerIdMappings(grouped_record, object_name);
            Sharing_Ledger__c[] ledgers_to_take_action_on = new Sharing_Ledger__c[]{};
            for (Sharing_Ledger__c ledger_record :grouped_record.records)
            {
                if (ledger_record.user_or_group_id__c != owner_id_mapping.get(ledger_record.source_table_id__c) 
                    || ledger_record.share_reason__c != ROW_CAUSE_MANUAL)
                    ledgers_to_take_action_on.add(ledger_record);
            }
            LPI_Utility_MapChain existing_ledger_summaries = existingLedgerSummary(grouped_record);

            ObjectMetadataDefinition field_definitions 
                = map_object_name_to_field_api_names.containsKey(object_name) ?
                map_object_name_to_field_api_names.get(object_name) : new ObjectMetadataDefinition(object_name);

            sObject[] records_to_insert = new sObject[]{};
            sObject[] records_to_update = new sObject[]{};
            sObject[] records_to_delete = new sObject[]{};
            LPI_Utility_MapChain grouped_share_records = new LPI_Utility_MapChain();

            for (Sharing_Ledger__c ledger_record :ledgers_to_take_action_on)
            {
                AggregateResult existing_access = (AggregateResult) existing_ledger_summaries.getData(
                    new String[]{ledger_record.user_or_group_id__c, ledger_record.source_table_id__c}
                );
                sObject share_record = (sObject) grouped_share_records.getData(
                    new String[]{ledger_record.user_or_group_id__c, ledger_record.source_table_id__c}
                );
                
                if (existing_access == null)
                {
                    if (share_record == null)
                    {
                        share_record = instantiateShareRecord(
                            field_definitions, ledger_record.source_table_id__c, ledger_record.user_or_group_id__c, 
                            translateAccessLevel(ledger_record.access_level__c),
                            getRowCauseFromShareReason(ledger_record.share_reason__c),
                            operation == DMLOperation.DML_Insert ? null : ledger_record.share_table_id__c
                        );
                        grouped_share_records.putData(
                            new String[]{ledger_record.user_or_group_id__c, ledger_record.source_table_id__c},
                            share_record
                        );

                        if (operation == DMLOperation.DML_Insert)
                            records_to_insert.add(share_record);
                        else if (operation == DMLOperation.DML_Update)
                            records_to_update.add(share_record);
                        else if (operation == DMLOperation.DML_Delete)
                            records_to_delete.add(share_record);
                    }
                    else
                    {
                        processMultipleShareRecords(field_definitions, operation, share_record, ledger_record);
                    }
                }
                else 
                {
                    if (operation == DMLOperation.DML_Insert)
                        ledger_record.share_table_id__c = (String) existing_access.get('share_table_id');
                    if (share_record == null)
                    {
                        if (((Decimal) existing_access.get('access_level')) == ACCESS_LEVEL_READ)
                        {
                            String access_level = operation == DMLOperation.DML_Delete ?
                                ACCESS_LEVEL_TEXT_READ :
                                translateAccessLevel(ledger_record.access_level__c);
                            records_to_update.add(instantiateShareRecord(
                                field_definitions, ledger_record.source_table_id__c, ledger_record.user_or_group_id__c, 
                                access_level, getRowCauseFromShareReason(ledger_record.share_reason__c), ledger_record.share_table_id__c
                            ));
                        }
                    }
                    else
                    {
                        processMultipleShareRecords(field_definitions, operation, share_record, ledger_record);
                    }
                }
            }

            if (records_to_insert.size() > 0)
            {
                insert records_to_insert;
                
                for (sObject inserted_record :records_to_insert)
                {
                    for (Sharing_Ledger__c ledger_record :(Sharing_Ledger__c[]) grouped_record.ledgerByUserAndRecordId.getData(new String[]
                        {(String) inserted_record.get(field_definitions.share_table_user_or_group_id_api_name),
                        (String) inserted_record.get(field_definitions.share_table_parent_id_api_name)}
                    ))
                    {
                        ledger_record.share_table_id__c = inserted_record.Id;
                    }
                }
            }
            if (records_to_update.size() > 0)
                update records_to_update;
            if (records_to_delete.size() > 0)
                delete records_to_delete;
        }
    }
    
    private static void processMultipleShareRecords(ObjectMetadataDefinition field_definitions, DMLOperation operation, sObject share_record, Sharing_Ledger__c ledger_record)
    {
        if (operation == DMLOperation.DML_Insert || operation == DMLOperation.DML_Update)
        {
            share_record.put(
                field_definitions.share_table_access_level_api_name,
                translateAccessLevel(
                    Math.max(
                        translateAccessLevel(
                            (String) share_record.get(field_definitions.share_table_access_level_api_name)
                        ),
                        ledger_record.access_level__c
                    )
                )
            );
        }
    }
    
    private static sObject instantiateShareRecord(ObjectMetadataDefinition field_definitions, String parent_id, String user_or_group_id, String access_level, String reason, String existing_share_table_id)
    {
        Schema.SObjectType share_object_type = LPI_UtilityDescribe.globalDescribe.get(
            LPI_UtilityDescribe.getSharingObjectName(field_definitions.source_table_api_name)
        );
        sObject share_record;
        if (existing_share_table_id == null)
        {
            share_record = share_object_type.newSObject();
            share_record.put(field_definitions.share_table_parent_id_api_name, parent_id);
            share_record.put(field_definitions.share_table_user_or_group_id_api_name, user_or_group_id);
            share_record.put(field_definitions.share_table_row_cause_api_name, reason);
        }
        else
            share_record = share_object_type.newSObject(existing_share_table_id);

        share_record.put(field_definitions.share_table_access_level_api_name, access_level);
        if (field_definitions.source_table_api_name == 'Account')
        {
            //share_record.put('ContactAccessLevel',access_level);
            share_record.put('CaseAccessLevel',access_level);
            share_record.put('OpportunityAccessLevel',access_level);
        }
        return share_record;
    }
    
    private static Map<String,GroupedLedger> parseLedgersIntoGroups(Sharing_Ledger__c[] records)
    {
        Map<String,GroupedLedger> grouped_ledgers = new Map<String,GroupedLedger>();
        for (Sharing_Ledger__c record :records)
        {
            if (!grouped_ledgers.containsKey(record.source_table__c))
                grouped_ledgers.put(record.source_table__c,new GroupedLedger());
            grouped_ledgers.get(record.source_table__c).addRecord(record);
        }
        return grouped_ledgers;
    }
    
    private static LPI_Utility_MapChain existingLedgerSummary(GroupedLedger grouped_ledger)
    {
        LPI_Utility_MapChain existing_ledger_summaries = new LPI_Utility_MapChain();
        for (AggregateResult existing_record_summary :
            [SELECT User_or_Group_Id__c user_or_group_id, Source_Table_Id__c source_table_id,
            Share_Table_Id__c share_table_id, MAX(Access_Level__c) access_level
            FROM Sharing_Ledger__c
            WHERE User_or_Group_Id__c IN :grouped_ledger.userOrGroupIds
            AND Source_Table_Id__c IN :grouped_ledger.sourceRecordIds
            AND Id NOT IN :grouped_ledger.records
            GROUP BY User_or_Group_Id__c,Source_Table_Id__c,Share_Table_Id__c])
        {
            existing_ledger_summaries.putData(
                new String[]{
                    (String) existing_record_summary.get('user_or_group_id'), 
                    (String) existing_record_summary.get('source_table_id')
                },
                (AggregateResult) existing_record_summary
            );
        }
        
        return existing_ledger_summaries;
    }
    
    private static Map<Id,Id> ownerIdMappings(GroupedLedger grouped_ledger, String object_name)
    {
        Map<Id,Id> owner_id_mappings = new Map<Id,Id>();
        Set<Id> record_ids = grouped_ledger.sourceRecordIds;
        for (sObject record :Database.Query('SELECT Id,OwnerId FROM ' + String.escapeSingleQuotes(object_name) + ' WHERE Id IN :record_ids'))
        {
            owner_id_mappings.put(record.Id, (Id) record.get('OwnerId'));
        }
        return owner_id_mappings;
    }
    
    private class GroupedLedger
    {
        public Set<Id> userOrGroupIds;
        public Set<Id> sourceRecordIds;
        public LPI_Utility_MapChain ledgerByUserAndRecordId;
        public Sharing_Ledger__c[] records;
    
        public GroupedLedger()
        {
            userOrGroupIds = new Set<Id>();
            sourceRecordIds = new Set<Id>();
            ledgerByUserAndRecordId = new LPI_Utility_MapChain();
            records = new Sharing_Ledger__c[]{};
        }
        
        public void addRecord(Sharing_Ledger__c record)
        {
            userOrGroupIds.add(record.User_Or_Group_Id__c);
            sourceRecordIds.add(record.Source_Table_Id__c);
            Sharing_Ledger__c[] grouped_records = (Sharing_Ledger__c[]) ledgerByUserAndRecordId.getData(new String[]{record.User_Or_Group_Id__c, record.Source_Table_Id__c});
            if (grouped_records == null)
                grouped_records = new Sharing_Ledger__c[]{};
            grouped_records.add(record);
            ledgerByUserAndRecordId.putData(new String[]{record.User_Or_Group_Id__c, record.Source_Table_Id__c}, grouped_records);
            records.add(record);
        }
    }
    
    public class ObjectMetadataDefinition
    {
        public String source_table_api_name;
        public String share_table_parent_id_api_name;
        public String share_table_access_level_api_name;
        public String share_table_user_or_group_id_api_name;
        public String share_table_row_cause_api_name;
        
        public ObjectMetadataDefinition(String source_table){
            SObjectType objectType = LPI_UtilityDescribe.globalDescribe.get(source_table);
            this.share_table_parent_id_api_name = PARENT_ID;
            this.share_table_access_level_api_name = ACCESS_LEVEL;
            if (!(objectType != null && objectType.getDescribe().isCustom())) {
                if (!managedPackageStandardObject.contains(source_table)) {
                    this.share_table_parent_id_api_name = source_table + 'Id';
                    this.share_table_access_level_api_name = source_table + ACCESS_LEVEL;
                }
            }
            this.share_table_user_or_group_id_api_name = 'UserOrGroupId';
            this.share_table_row_cause_api_name = 'RowCause';
            this.source_table_api_name = source_table;
        }
    }
}