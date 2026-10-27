/**
 * @author       : Hiten Aggarwal
 * @description  : This Class is the Handler class on Application_Document__c trigger 
 * @since        : 12-Jan-2023
 */
public class LPI_ApplicationDocumentTriggerHandler extends LPI_TriggerHandler {
    /**
    *   @author : MTX.Inc
    *   @since  : 09-Jan-2023
    *   @description : This method contains method calling which 
    *                  should invoke after insertion of Application_Document__c records
    */
    public override void afterInsert() {
        List<Application_Document__c> recordsList = (List<Application_Document__c>) Trigger.New;
        LPI_ApexSharingUtility.manageRecordAccess(recordsList, NULL);
        ApplicationDocumentTriggerController.updatestatusOnIA(Trigger.New);
    }

    /**
    *   @author : MTX.Inc
    *   @since  : 09-Jan-2023
    *   @description : This method contains method calling which 
    *                  should invoke before insertion of Application_Document__c records
    */
    public override void beforeInsert() {
        List<Application_Document__c> recordsList = (List<Application_Document__c>) Trigger.New;
        LPI_ApplicationDocumentTriggerHelper.updateBoardName(recordsList, NULL);
    }
    
    
    /**
    *   @author : MTX.Inc
    *   @since  : 09-Jan-2023
    *   @description : This method contains method calling which 
    *                  should invoke after update of Application_Document__c records
    */
    public override void afterUpdate() {
        List<Application_Document__c> recordsList = (List<Application_Document__c>) Trigger.New;
        Map<Id,Application_Document__c> oldMap = (Map<Id,Application_Document__c>) Trigger.OldMap;
        LPI_ApplicationDocumentTriggerHelper.updateChildAppDocOnStatusApprove(recordsList, oldMap);
        SharingLedger_SourceObjectTriggerHelper.detectAndProcessSharingDueToOwnerChange(recordsList,oldMap);
		
    }


    /**
    *   @author : MTX.Inc
    *   @since  : 09-Jan-2023
    *   @description : This method contains method calling which 
    *                  should invoke after before of Application_Document__c records
    */
    public override void beforeUpdate() {
        List<Application_Document__c> recordsList = (List<Application_Document__c>) Trigger.New;
        Map<Id,Application_Document__c> oldMap = (Map<Id,Application_Document__c>) Trigger.OldMap;
        
        LPI_ApplicationDocumentTriggerHelper.updateBoardName(recordsList, oldMap);
        
        //This should be last method of before update
        LPI_ApexSharingUtility.restrictFieldUpdate(
            recordsList, oldMap, fieldNotTobeChangedMap, picklistToStatusToStatusChangeNotAllowedMap
        );
    }

	//This map include field that should not be changed once record is created
    private static Map<String, String> fieldNotTobeChangedMap = new Map<String, String>{
        'Preliminary_Application_Reference__c' => 'Preliminary Application Reference',
        'Sub_Type__c' => 'Sub Type',   
        'Type__c' => 'Type',
        'Is_Applicant_Submission_Required__c' => 'Submission Required'
	};
        
    //This map includ picklist field
    private static Map<String, Map<String, Set<String>>> picklistToStatusToStatusChangeNotAllowedMap = new Map<String, Map<String, Set<String>>> {
        'Status__c' => new Map<String, Set<String>>{ 
            'Unsubmitted' => new Set<String>{
                'Approved'  
            },
            'Submitted' => new Set<String>{
                'Approved'  
            },
            'Rejected' => new Set<String>{
                'Approved'
            },
            'Notice' => new Set<String>{
                'Approved'  
            }
        }
	};      
    
}