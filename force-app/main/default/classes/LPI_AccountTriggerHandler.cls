/**
 * @author       :  MTX Group Product Team
 * @BuildDate    : 29th dec, 2022
 * @description  : This class contains methods that executes automatically after performing CRUD operations on Account records
 */
public with sharing class LPI_AccountTriggerHandler extends LPI_TriggerHandler {
   
    /**
    * @description : Method to perform business logics before record insertion.
    * @author  MTX Group Product Team | 02-03-2023 
    **/
    public override void beforeInsert() {
        List<Account> newlist = (List<Account>) Trigger.New;
        Map<Id, Account> oldMap = (Map<Id, Account>) Trigger.oldMap;
        LPI_AccountTriggerHelper.updateCombinedNameForPersonAccount(newlist,oldMap);
    }

   /**
    * @description : Method to perform business logics after record insertion.
    * @author 
    **/
   public override void afterInsert() {
        List<Account> newlist = (List<Account>) Trigger.New;
        
        LPI_AccountTriggerHelper.manageAccessForParentAccount(newlist, null);
        LPI_AccountTriggerHelper.updatingBLStatusByDateOfDeath(newlist, null);
    }

    /**
    * @description : Method to perform business logics before record updation.
    * @author  MTX Group Product Team| 02-03-2023 
    **/
   public override void beforeUpdate() {
        List<Account> newlist = (List<Account>) Trigger.New;
        Map<Id, Account> oldMap = (Map<Id, Account>) Trigger.oldMap;
        LPI_AccountTriggerHelper.checkSSNDuplicate(newlist,oldMap);
        LPI_AccountTriggerHelper.updateCombinedNameForPersonAccount(newlist,oldMap);
    }

    /**
    * @description : Method to perform business logics after record updation.
    * @author  MTX Group Product Team  | 02-03-2023 
    **/
   public override void afterUpdate() {
        List<Account> newlist = (List<Account>) Trigger.New;
        Map<Id, Account> oldMap = (Map<Id, Account>) Trigger.oldMap;
        LPI_AccountTriggerHelper.manageAccessForParentAccount(newlist,oldMap);
         LPI_AccountTriggerHelper.deleteBusinessRelationships(newlist, oldMap);
         SharingLedger_SourceObjectTriggerHelper.detectAndProcessSharingDueToOwnerChange(newlist,oldMap);
         LPI_AccountTriggerHelper.updatingBLStatusByDateOfDeath(newlist, oldMap);
    }

}