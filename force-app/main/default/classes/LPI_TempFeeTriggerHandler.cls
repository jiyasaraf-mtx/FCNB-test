/**
 * @description       : This Class is the Handler class on Temp_Fee__c trigger 
 * @author            : MTX Group Product Team
 * @group             : 
 * @last modified on  : 07-26-2024
 * @last modified by  : MTX Group Product Team
**/

public class LPI_TempFeeTriggerHandler extends LPI_TriggerHandler {


    /**
    * @description This method contains method calling which should invoke after insertion of Temp_Fee__c records
    * @author MTX Group Product Team | 05-06-2024 
    **/
    public override void afterInsert() {
        List<Temp_Fee__c> recordsList = (List<Temp_Fee__c>) Trigger.New;
        
        LPI_ApexSharingUtility.manageRecordAccess(recordsList, NULL);
    }
    

    /**
    * @description This method contains method calling which  should invoke after update of Temp_Fee__c records
    * @author MTX Group Product Team | 05-06-2024 
    **/
    public override void afterUpdate() {
        List<Temp_Fee__c> recordsList = (List<Temp_Fee__c>) Trigger.New;
        Map<Id,Temp_Fee__c> oldMap = (Map<Id,Temp_Fee__c>) Trigger.OldMap;
        
        SharingLedger_SourceObjectTriggerHelper.detectAndProcessSharingDueToOwnerChange(recordsList,oldMap);

    }
    
}