/**
 * @author       : MTX Group Product Team
 * @description  : This Class is the Handler class on Application_Content__c trigger 
 * @since        : 12-Jan-2023
 */
public class LPI_ApplicationContentTriggerHandler extends LPI_TriggerHandler {
    /**
    *   @author : MTX Group Product Team
    *   @since  : 09-Jan-2023
    *   @description : This method contains method calling which 
    *                  should invoke after insertion of Application_Content__c records
    */
    public override void afterInsert() {
        List<Application_Content__c> recordsList = (List<Application_Content__c>) Trigger.New;
        
        LPI_ApexSharingUtility.manageRecordAccess(recordsList, NULL);
    }

    /**
    *   @author : MTX Group Product Team
    *   @since  : 09-Jan-2023
    *   @description : This method contains method calling which 
    *                  should invoke before insertion of Application_Content__c records
    */
    public override void beforeInsert() {
        List<Application_Content__c> recordsList = (List<Application_Content__c>) Trigger.New;
        
        LPI_ApplicationContentTriggerHelper.updateBoardName(recordsList, NULL);
    }
    
    /**
    *   @author : MTX Group Product Team
    *   @since  : 09-Jan-2023
    *   @description : This method contains method calling which 
    *                  should invoke after update of Application_Content__c records
    */
    public override void afterUpdate() {
        List<Application_Content__c> recordsList = (List<Application_Content__c>) Trigger.New;
        Map<Id,Application_Content__c> oldMap = (Map<Id,Application_Content__c>) Trigger.OldMap;
        
        SharingLedger_SourceObjectTriggerHelper.detectAndProcessSharingDueToOwnerChange(recordsList,oldMap);

    }

    /**
    *   @author : MTX Group Product Team
    *   @since  : 09-Jan-2023
    *   @description : This method contains method calling which 
    *                  should invoke after before of Application_Content__c records
    */
    public override void beforeUpdate() {
        List<Application_Content__c> recordsList = (List<Application_Content__c>) Trigger.New;
        Map<Id,Application_Content__c> oldMap = (Map<Id,Application_Content__c>) Trigger.OldMap;
        
        LPI_ApplicationContentTriggerHelper.updateBoardName(recordsList, oldMap);
    }

}