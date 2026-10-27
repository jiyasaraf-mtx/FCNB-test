/**
 * @description       : 
 * @author            : Mohit Karani
 * @group             : 
 * @last modified on  : 07-13-2024
 * @last modified by  : Uzma Md
**/
public with sharing class LPI_UpdateCombinedNameOnAccountBatch implements Database.Batchable<sObject>{
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        String fieldsToQuery = ' SELECT Id,FirstName,MiddleName,LastName,RecordTypeId,Date_of_Birth_Present__c,Date_of_Birth__c FROM Account';
        String whereClause = ' WHERE RecordTypeId = \'' + LPI_LiteralConstant.PERSON_ACCOUNT_REC_TYPE_ID + '\' AND (Combined_Name__pc = NULL OR Date_of_Birth_Present__c = FALSE)' ;
        return Database.getQueryLocator(fieldsToQuery + whereClause);
    
    }

    public void execute(
        Database.BatchableContext bc,
        List<Account> accountList
    ) {
        
        // for(Account acc : accountList){
            
        //     //I-205362
			
        //     acc.Date_of_Birth_Present__c = (acc.Date_of_Birth__c != null);
            
        //     acc.FirstName =  (String.isNotBlank(acc.FirstName)?acc.FirstName.trim():acc.FirstName);
        //     acc.MiddleName = (String.isNotBlank(acc.MiddleName)?acc.MiddleName.trim():acc.MiddleName);
        //     acc.LastName =   acc.LastName.trim();

        //     acc.Combined_Name__pc = String.isNotBlank(acc.FirstName) &&
        //         String.isNotBlank(acc.MiddleName)
        //         ? acc.FirstName + ' ' + acc.MiddleName + ' ' + acc.LastName
        //         : String.isNotBlank(acc.FirstName)
        //               ? acc.FirstName + ' ' + acc.LastName
        //               : String.isNotBlank(acc.MiddleName)
        //                     ? acc.MiddleName + ' ' + acc.LastName
        //                     : acc.LastName;
        // }
        // LPI_DML.doUpdate(accountList);
    }

    
    public void finish(Database.BatchableContext bc) {

    }
}