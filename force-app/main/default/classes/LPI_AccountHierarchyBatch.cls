/**
 * @description       : 
 * @author            : MTX Group Inc
 * @group             : 
 * @last modified on  : 05-30-2024
 * @last modified by  : MTX Group Inc
**/
public without sharing class LPI_AccountHierarchyBatch implements Database.Batchable<sObject> {
    // Set<Id> accountIdSet = new Set<Id>();
    // //Set<String> roleSet = new Set<String> ();
    // set<String> roleSet = new Set<String>{
    //     'Temporary Clerk', 'Authorized Contact'
    // };
    
    // public LPI_AccountHierarchyBatch(Set<Id> accountIdSet){
    //     this.accountIdSet = accountIdSet;
    // }
    
    public Database.QueryLocator start(Database.BatchableContext context) {
        // String query = '';
        // Set<Id> accountIdSet = this.accountIdSet;
        // if(this.accountIdSet != null && !this.accountIdSet.isEmpty() ){
        //     query = 'SELECT Id,Name,MO_State_Registration_Number__c, Federal_Employer_ID_Number_EIN__c FROM Account WHERE Id IN: accountIdSet';
        // }else{
        //     query = 'SELECT Id,Name,MO_State_Registration_Number__c, Federal_Employer_ID_Number_EIN__c FROM Account';
        // }
       
        // return Database.getQueryLocator(query);
        return null;
    }
    
    public void execute(Database.BatchableContext context, List<Account> scope) {
        // try{
        //     Map<String, List<Account>> einNumberToAccountsMap = new Map<String, List<Account>>();
        //     Map<String, List<Account>> moStateNumberToAccountsMap = new Map<String, List<Account>>();
        //     Map<String, List<Account>> nameToAccountsMap = new Map<String, List<Account>>();
            
        //     for (Account acc : scope) {
        //         if(acc.Federal_Employer_ID_Number_EIN__c != NULL && acc.Federal_Employer_ID_Number_EIN__c != ''){
        //             if (!einNumberToAccountsMap.containsKey(acc.Federal_Employer_ID_Number_EIN__c)) {
        //                 einNumberToAccountsMap.put(acc.Federal_Employer_ID_Number_EIN__c, new List<Account>());
        //             }
        //             einNumberToAccountsMap.get(acc.Federal_Employer_ID_Number_EIN__c).add(acc);
        //         }else if(acc.MO_State_Registration_Number__c  != NULL && acc.MO_State_Registration_Number__c  != ''){
        //             if (!moStateNumberToAccountsMap.containsKey(acc.MO_State_Registration_Number__c)) {
        //                 moStateNumberToAccountsMap.put(acc.MO_State_Registration_Number__c, new List<Account>());
        //             }
        //             moStateNumberToAccountsMap.get(acc.MO_State_Registration_Number__c).add(acc);
        //         }else{
        //             String accountName = acc.Name.split(' ')[0];
        //             if (!nameToAccountsMap.containsKey(accountName)) {
        //                 nameToAccountsMap.put(accountName, new List<Account>());
        //             }
        //             nameToAccountsMap.get(accountName).add(acc);
        //         }
        //     }
             
        //     Map<Id,List<Business_Relationships__c>> businessAccountToBRMap = new Map<Id,List<Business_Relationships__c>> ();
            
        //     for(Business_Relationships__c brRecord : [
        //         SELECT Id, Related_To__c, Related_From__c 
        //         FROM Business_Relationships__c
        //         WHERE Roles__c IN: roleSet
        //         AND Related_From__c IN: scope
        //     ]){
        //         if(!businessAccountToBRMap.containsKey(brRecord.Related_From__c)){
        //             businessAccountToBRMap.put(brRecord.Related_From__c,new List<Business_Relationships__c>());
        //         }
        //         businessAccountToBRMap.get(brRecord.Related_From__c).add(brRecord);
        //     }
            
        //     Map<String, Account> oldEinNumberToAccountsMap = new Map<String, Account>();
        //     Map<String, Account> oldMoStateNumberToAccountsMap = new Map<String, Account>();
        //     Map<String, Account> oldNameToAccountsMap = new Map<String, Account>();
            
        //     for(Account acc : [
        //         SELECT Id, Federal_Employer_ID_Number_EIN__c 
        //         FROM Account
        //         WHERE Federal_Employer_ID_Number_EIN__c IN: einNumberToAccountsMap.KeySet()
        //         AND Is_Parent_Business_Account__c = true
        //     ]){
        //         oldEinNumberToAccountsMap.put(acc.Federal_Employer_ID_Number_EIN__c, acc);
        //     }
            
        //     for(Account acc : [
        //         SELECT Id, MO_State_Registration_Number__c 
        //         FROM Account
        //         WHERE MO_State_Registration_Number__c IN: moStateNumberToAccountsMap.KeySet()
        //         AND Is_Parent_Business_Account__c = true
        //     ]){
        //         oldMoStateNumberToAccountsMap.put(acc.MO_State_Registration_Number__c, acc);
        //     }
            
        //     for(Account acc : [
        //         SELECT Id, Name 
        //         FROM Account
        //         WHERE Name IN: nameToAccountsMap.KeySet()
        //         AND Is_Parent_Business_Account__c = true
        //     ]){
        //         oldNameToAccountsMap.put(acc.Name, acc);
        //     }
            
        //     Map<String,Account> hirerchyTypeToParentAccountMap = new Map<String,Account>();
        //     Map<String,List<Account>> einNumberToChildAccountList = new Map<String,List<Account>>();
        //     Map<String,List<Account>> moStateNumberToChildAccountList = new Map<String,List<Account>>();
        //     Map<String,List<Account>> nameToChildAccountList = new Map<String,List<Account>>();
        //     List<Account> childAccountUpdateList = new List<Account>();
        //     List<Business_Relationships__c> brUpdateList = new List<Business_Relationships__c>();
            
        //     for (Account acc : scope) {
        //         String accountName = acc.Name.split(' ')[0];
                    
        //         if(acc.Federal_Employer_ID_Number_EIN__c != NULL && acc.Federal_Employer_ID_Number_EIN__c != ''){
        //             if(oldEinNumberToAccountsMap.containsKey(acc.Federal_Employer_ID_Number_EIN__c)){
        //                 acc.ParentId = oldEinNumberToAccountsMap.get(acc.Federal_Employer_ID_Number_EIN__c).Id;
        //                 acc.Hierarchy_Method_Used__c  = 'Federal Employer ID Number EIN';
        //                 childAccountUpdateList.add(acc);
        //                 if(businessAccountToBRMap.containsKey(acc.Id)){
        //                     for(Business_Relationships__c brRecord : businessAccountToBRMap.get(acc.Id)){
        //                         brRecord.Related_From__c = oldEinNumberToAccountsMap.get(acc.Federal_Employer_ID_Number_EIN__c).Id;
        //                         brUpdateList.add(brRecord);
        //                     }
        //                 }
                        
        //             }else{
        //                 Account parentAccount;
        //                 if(!hirerchyTypeToParentAccountMap.containsKey(acc.Federal_Employer_ID_Number_EIN__c)){
        //                     parentAccount = new Account(
        //                         Name = accountName, 
        //                         Is_Parent_Business_Account__c = true, 
        //                         Federal_Employer_ID_Number_EIN__c = acc.Federal_Employer_ID_Number_EIN__c
        //                     );
        //                     hirerchyTypeToParentAccountMap.put(acc.Federal_Employer_ID_Number_EIN__c , parentAccount);
        //                 }
        //                 acc.Hierarchy_Method_Used__c  = 'Federal Employer ID Number EIN';
        //                 if(einNumberToChildAccountList.isEmpty()){
        //                     einNumberToChildAccountList.put(acc.Federal_Employer_ID_Number_EIN__c, new List<Account>());
        //                 }
        //                 einNumberToChildAccountList.get(acc.Federal_Employer_ID_Number_EIN__c).add(acc);
        //             }
        //         }else if(acc.MO_State_Registration_Number__c != NULL && acc.MO_State_Registration_Number__c != ''){
        //             if(oldMoStateNumberToAccountsMap.containsKey(acc.MO_State_Registration_Number__c)){
        //                 acc.ParentId = oldMoStateNumberToAccountsMap.get(acc.MO_State_Registration_Number__c).Id;
        //                 acc.Hierarchy_Method_Used__c  = 'Missouri Secretary of State Registration Number';
        //                 childAccountUpdateList.add(acc);
        //                 if(businessAccountToBRMap.containsKey(acc.Id)){
        //                     for(Business_Relationships__c brRecord : businessAccountToBRMap.get(acc.Id)){
        //                         brRecord.Related_From__c = oldEinNumberToAccountsMap.get(acc.Federal_Employer_ID_Number_EIN__c).Id;
        //                         brUpdateList.add(brRecord);
        //                     }
        //                 }
        //             }
        //             else{
        //                 Account parentAccount;
        //                 if(!hirerchyTypeToParentAccountMap.containsKey(acc.MO_State_Registration_Number__c)){
        //                     parentAccount = new Account(
        //                         Name = accountName, 
        //                         Is_Parent_Business_Account__c = true, 
        //                         MO_State_Registration_Number__c = acc.MO_State_Registration_Number__c
        //                     );
        //                     hirerchyTypeToParentAccountMap.put(acc.MO_State_Registration_Number__c , parentAccount);
        //                 }
        //                 acc.Hierarchy_Method_Used__c  = 'Missouri Secretary of State Registration Number';
        //                 if(moStateNumberToChildAccountList.isEmpty()){
        //                     moStateNumberToChildAccountList.put(acc.MO_State_Registration_Number__c, new List<Account>());
        //                 }
        //                 moStateNumberToChildAccountList.get(acc.MO_State_Registration_Number__c).add(acc);
        //             } 
        //         }else{
        //             if(oldNameToAccountsMap.containsKey(accountName)){
        //                 acc.ParentId = oldNameToAccountsMap.get(accountName).Id;
        //                 acc.Hierarchy_Method_Used__c  = 'Name';
        //                 childAccountUpdateList.add(acc);
        //                 if(businessAccountToBRMap.containsKey(acc.Id)){
        //                     for(Business_Relationships__c brRecord : businessAccountToBRMap.get(acc.Id)){
        //                         brRecord.Related_From__c = oldEinNumberToAccountsMap.get(acc.Federal_Employer_ID_Number_EIN__c).Id;
        //                         brUpdateList.add(brRecord);
        //                     }
        //                 }
        //             }
        //             else{
        //                 Account parentAccount;
        //                 if(!hirerchyTypeToParentAccountMap.containsKey(accountName)){
        //                     parentAccount = new Account(Name = accountName, Is_Parent_Business_Account__c = true);
        //                     hirerchyTypeToParentAccountMap.put(accountName , parentAccount);
        //                 }
        //                 acc.Hierarchy_Method_Used__c  = 'Name';
        //                 if(nameToChildAccountList.isEmpty()){
        //                     nameToChildAccountList.put(accountName, new List<Account>());
        //                 }
        //                 nameToChildAccountList.get(accountName).add(acc);
        //             }                
        //         }
        //     }
            
        //     if(!hirerchyTypeToParentAccountMap.isEmpty()){
        //         Insert hirerchyTypeToParentAccountMap.values();
        //     }
            
        //     for(String method : hirerchyTypeToParentAccountMap.keySet()){
        //         Id parentId = hirerchyTypeToParentAccountMap.get(method).Id;
        //         if(einNumberToChildAccountList.containsKey(method)){
        //             for(Account acc : einNumberToChildAccountList.get(method)){
        //                 acc.ParentId = parentId;
        //                 childAccountUpdateList.add(acc);
        //                 if(businessAccountToBRMap.containsKey(acc.Id)){
        //                     for(Business_Relationships__c brRecord : businessAccountToBRMap.get(acc.Id)){
        //                         brRecord.Related_From__c = parentId;
        //                         brUpdateList.add(brRecord);
        //                     }
        //                 }
        //             }
        //         }
    
        //         if(moStateNumberToChildAccountList.containsKey(method)){
        //             for(Account acc : moStateNumberToChildAccountList.get(method)){
        //                 acc.ParentId = parentId;
        //                 childAccountUpdateList.add(acc);
        //                 if(businessAccountToBRMap.containsKey(acc.Id)){
        //                     for(Business_Relationships__c brRecord : businessAccountToBRMap.get(acc.Id)){
        //                         brRecord.Related_From__c = parentId;
        //                         brUpdateList.add(brRecord);
        //                     }
        //                 }
        //             }
        //         }
    
                
        //         if(nameToChildAccountList.containsKey(method)){
        //             for(Account acc : nameToChildAccountList.get(method)){
        //                 acc.ParentId = parentId;
        //                 childAccountUpdateList.add(acc);
        //                 if(businessAccountToBRMap.containsKey(acc.Id)){
        //                     for(Business_Relationships__c brRecord : businessAccountToBRMap.get(acc.Id)){
        //                         brRecord.Related_From__c = parentId;
        //                         brUpdateList.add(brRecord);
        //                     }
        //                 }
        //             }
        //         }
                
        //     }
            
        //     if(!childAccountUpdateList.isEmpty() && !Test.isRunningTest()){
        //         Update childAccountUpdateList;
        //     }
            
        //     if(!brUpdateList.isEmpty()){
        //         Update brUpdateList;
        //     }    
        // }
        // catch (Exception ex) {
        //     LPI_ExceptionManager.logException('LPI_AccountHierarchyBatch', 'execute', ex);
        // }
    }
    
    public void finish(Database.BatchableContext context) {
        // Optional: Add any additional logic you want to perform after the batch finishes
    }
}