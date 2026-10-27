/**
 * @description       : Batch Class to Delete Draft complaints along with the files uploaded.
 * @author            : Mohit Karani
 * @group             : 
 * @last modified on  : 05-30-2024
 * @last modified by  : MTX Group Inc
**/
public with sharing class LPI_PublicComplaintCleanupBatch implements Database.Batchable<sObject>, Schedulable, Database.Stateful {

    Set<Id> publicComplaintIdSet = new Set<Id>();

    public LPI_PublicComplaintCleanupBatch(){}

    public LPI_PublicComplaintCleanupBatch(
        
        Set<Id> publicComplaintId
    ) {
        publicComplaintIdSet = publicComplaintId;
    }
   
    /**
    * @description : Method to fetch Complaint records.
    * @author Mohit Karani | 06-19-2023 
    * @param bc 
    * @return List<PublicComplaint> 
    **/
    public Database.QueryLocator start(Database.BatchableContext bc) {
        String fieldsToQuery = 'SELECT Id,CreatedDate,(SELECT ID,ContentDocumentId FROM ContentDocumentLinks),(SELECT ID,Onbase_Document_Id__c,Onbase_Upload_Status__c FROM Application_Document__r ) FROM PublicComplaint ';
        String whereClause = 'WHERE Status = \'' + LPI_ComplaintsController.DRAFT_STATUS_TEXT + '\'' ;
        whereClause = publicComplaintIdSet.isEmpty() ? whereClause : whereClause + ' AND ID IN ' + LPI_ServiceUtility.getStringValuesBySet(publicComplaintIdSet) +'AND CreatedDate < TODAY';
        return Database.getQueryLocator(fieldsToQuery + whereClause);
    }

    /**
    * @description : Method to do processing on the records fetched.
    * @author Mohit Karani | 06-19-2023 
    * @param bc 
    * @param publicComplaintList 
    **/
    public void execute(
        Database.BatchableContext bc,
        List<PublicComplaint> publicComplaintList
    ) {
        List<SObject> listToDelete = new List<SObject> ();
        List<SObject> listToUpdate = new List<SObject> (); 
        List<ContentDocumentLink> cdlList = new List<ContentDocumentLink>();
        List<Application_Document__c> appdocList = new List<Application_Document__c>();

        for(PublicComplaint pc : publicComplaintList){
            listToDelete.add(pc);
            cdlList.addAll(pc.ContentDocumentLinks);
            appdocList.addAll(pc.Application_Document__r);
        }
        ContentDocument cd;
        Map<Id,ContentDocument> idToCdMap = new Map<Id,ContentDocument>();
        for(ContentDocumentLink cdl : cdlList){
            if(idToCdMap.containsKey(cdl.ContentDocumentId)){
                continue;
            }
            cd = new ContentDocument();
            cd.Id = cdl.ContentDocumentId;
            idToCdMap.put(cd.Id,cd);
        }
        for(Application_Document__c app:appdocList){
                if(app.Onbase_Upload_Status__c != 'Uploaded to Onbase'){
                    listToDelete.add(app); 
                }
                else if(app.Onbase_Upload_Status__c == 'Uploaded to Onbase'){
 			             app.Onbase_Upload_Status__c = 'Delete from onbase';
                        listToUpdate.add(app); 
                }        
        }

        listToDelete.addAll(idToCdMap.values());
        LPI_DML.doDelete(listToDelete);
        LPI_DML.doUpdate(listToUpdate);
    }

    /**
    * @description : Finish method to compute end result.
    * @author Mohit Karani | 06-19-2023 
    * @param bc 
    **/
    public void finish(Database.BatchableContext bc) {

    }

    /**
    * @description : Execute method for SchedulableContext.
    * @author Mohit Karani | 06-19-2023 
    * @param sc 
    **/
    public void execute(SchedulableContext sc) {
        LPI_PublicComplaintCleanupBatch b = new LPI_PublicComplaintCleanupBatch ();
        database.executebatch(b);
    }
}