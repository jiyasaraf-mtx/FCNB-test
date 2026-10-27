/**
 * @author              : MTX Group Product Team
 * @since               : 22th June, 2023
 * @description         : This class contains the business logic to populate Unique key on Relationship Records
 * @history
 * -------------------------------------------------------------------------------------------------------
 * Version      Date                Author                          Details
 *    1         22th June, 2023     MTX Group Product Team          Initial Developement
 * -------------------------------------------------------------------------------------------------------
 */   
public with sharing class LPI_UpdateUniqueKeyOnRelationshipBatch implements Database.Batchable<sObject> {

    public Database.QueryLocator start(Database.BatchableContext BC) {
        String queryStr;
        /* queryStr = 'SELECT Id, Related_To__c, Related_From__c, EndDate__c, Related_From_License_Number__c, ' 
                + 'Roles__c, Parent_Relationship__c FROM Business_Relationships__c';*/
        return Database.getQueryLocator(queryStr);
     }

    /**
     * @author                      : MTX Group Product Team
     * @since                       : June 22, 2023
     * @description                 : This method is to populate Relationship_Matching_Principal__c as unique key for duplicate rule via Batch
     * @param recordList            : Takes List<Business_Relationships__c>
     * @param BC                    : `Database.BatchableContext`
     * @return                      : `void`
     * @last modified by            : MTX Group Product Team
     * @last modified on            : 07-26-2024
     */
     public void execute(Database.BatchableContext BC, List<Business_Relationships__c> recordList) {    
            /*for(Business_Relationships__c relationshipRec : recordList) {
                //Concatenating 4 fields Related_To__c, Start_Date__c, EndDate__c, and Parent_Relationship__c
                relationshipRec.Relationship_Matching_Principal__c = LPI_RelationshipService.generateMatchingKey(relationshipRec);
            }
            if(!recordList.isEmpty()) {
                List<Database.SaveResult> updatedRecords = Database.update(recordList,false);
            }*/
     }   

    public void finish(Database.BatchableContext BC){   
        // POST BATCH EXECUTION LOGIC  
    }
}