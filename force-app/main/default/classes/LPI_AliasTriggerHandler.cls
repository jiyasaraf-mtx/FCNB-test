/**
 * @author       : MTX Group Product Team
 * @description  : This Class is the Handler class on Alias__c trigger 
 * @since        : 20-Jun-2023
 */
public class LPI_AliasTriggerHandler extends LPI_TriggerHandler {

    /**
    *   @author 	 : MTX Group Product Team
 	* 	@since       : 20-Jun-2023
    *   @description : This method contains method calling which 
    *                  should invoke after insertion of Alias__c records
    */
    public override void afterInsert() {
        List <Alias__c> recordsList = (List <Alias__c>)Trigger.New;
        LPI_ApexSharingUtility.manageRecordAccess(recordsList, NULL);
    }
    
    /**
    *   @author 	 : MTX Group Product Team
 	* 	@since       : 20-Jun-2023
    *   @description : This method contains method calling which 
    *                  should invoke after update of Alias__c records
    */
    public override void afterUpdate() {
        List<Alias__c> recordsList = (List<Alias__c>) Trigger.New;
        Map<Id,Alias__c> oldMap = (Map<Id,Alias__c>) Trigger.oldMap;
        SharingLedger_SourceObjectTriggerHelper.detectAndProcessSharingDueToOwnerChange(recordsList,oldMap);
    }
}