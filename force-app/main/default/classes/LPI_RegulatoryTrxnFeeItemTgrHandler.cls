/**
 * @description       : This Class is the Handler class on RegulatoryTrxnFeeItem trigger 
 * @author            : MTX Group Product Team
 * @group             : 
 * @last modified on  : 07-26-2024
 * @last modified by  : MTX Group Product Team
**/

public class LPI_RegulatoryTrxnFeeItemTgrHandler extends LPI_TriggerHandler {
    private static Map<String, String> fieldNotTobeChangedMap = new Map<String, String>{
        'FeeAmount' => 'Fee Amount'
	}; 

	/**
    *   @author : MTX Group Product Team
    *   @since  : 09-Jan-2023
    *   @description : This method contains method calling which 
    *                  should invoke after before of Application_Document__c records
    */
    public override void beforeUpdate() {
        List<RegulatoryTrxnFeeItem> recordsList = (List<RegulatoryTrxnFeeItem>) Trigger.New;
        Map<Id,RegulatoryTrxnFeeItem> oldMap = (Map<Id,RegulatoryTrxnFeeItem>) Trigger.OldMap;
                
        LPI_ApexSharingUtility.restrictFieldUpdate(
            recordsList, oldMap, fieldNotTobeChangedMap, null
        );
    }
}