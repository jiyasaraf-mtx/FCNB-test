/**
 * @author                      : Nitesh Garg
 * @since                       : 
 * @description                 : Regulatory Transaction Handler
 * @last modified by            : Amit Agrawal
 * @last modified date          : 
 * @modified details            : 
 */
public with sharing class LPI_RegulatoryTrnxFeeTriggerHandler extends LPI_TriggerHandler{
    /**
    * Author : 
    * BuildDate : 08/29/2022 
    * Description : This Method will be called in before insert context of RegulatoryTrxnFee Trigger
    * return : void
    */
    public override void beforeInsert() {
        List<RegulatoryTrxnFee> recordsList = (List<RegulatoryTrxnFee>) Trigger.New;
        LPI_RegulatoryTrnxFeeTriggerHelper.sendPortalNotificationForPayment(recordsList,null);
    }
    
    /**
    * Author : Hiten
    * BuildDate : 09/02/2022 
    * Description : This Method will be called in after insert context of RegulatoryTrxnFee Trigger
    * return : void
    */
    public override void afterInsert() {
        List<RegulatoryTrxnFee> recordsList = (List<RegulatoryTrxnFee>) Trigger.New;
        LPI_ApexSharingUtility.manageRecordAccess(recordsList, NULL);
        LPI_RegulatoryTrxnFeeTgrHelper.markPaymentPendingCheckBoxTrueFalseOnApp(recordsList, NULL);
    }
    
    /**
    * Author : Hiten
    * BuildDate : 09/02/2022 
    * Description : This Method will be called in after insert context of RegulatoryTrxnFee Trigger
    * return : void
    */
    public override void beforeUpdate() {
        List<RegulatoryTrxnFee> recordsList = (List<RegulatoryTrxnFee>) Trigger.New;
        Map<Id, RegulatoryTrxnFee> mapOfOldRecords = (Map<Id, RegulatoryTrxnFee>) Trigger.oldMap;
        
        LPI_RegulatoryTrnxFeeTriggerHelper.updateBoardName(recordsList, mapOfOldRecords);
    }
    
    /**
    * Author : 
    * BuildDate : 08/29/2022 
    * Description : This Method will be called in after update context of RegulatoryTrxnFee Trigger
    * return : void
    */
    public override void afterUpdate() {
        List<RegulatoryTrxnFee> recordsList = (List<RegulatoryTrxnFee>) Trigger.New;
        Map<Id, RegulatoryTrxnFee> mapOfOldRecords = (Map<Id, RegulatoryTrxnFee>) Trigger.oldMap;
        LPI_RegulatoryTrxnFeeTgrHelper.markPaymentPendingCheckBoxTrueFalseOnApp(recordsList, mapOfOldRecords);
        LPI_RegulatoryTrnxFeeTriggerHelper.sendPortalNotificationForPayment(recordsList,mapOfOldRecords);
        SharingLedger_SourceObjectTriggerHelper.detectAndProcessSharingDueToOwnerChange(recordsList,mapOfOldRecords);
    }
    
    private static Map<String, String> fieldNotTobeChangedMap = new Map<String, String>{
        'ParentRecordId' => 'Parent Record'
	};
 
    private static Map<String, Map<String, Set<String>>> picklistToStatusToStatusChangeNotAllowedMap = new Map<String, Map<String, Set<String>>> {
        'Status__c' => new Map<String, Set<String>>{ 
            'Declined' => new Set<String>{
                'Approved', 'Paid', 'Pending'  
            },
            'Canceled' => new Set<String>{
                'Approved', 'Paid', 'Pending'   
            },
            'Failed' => new Set<String>{
                'Approved', 'Paid', 'Pending'   
            },
            'Approved' => new Set<String>{
                'Paid'  
            }
        }
	};     

}