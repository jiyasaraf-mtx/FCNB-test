/**
 * @description       : 
 * @author            : MTX Group Product Team
 * @group             : 
 * @last modified on  : 07-26-2024
 * @last modified by  : MTX Group Product Team
**/
public class RegulatoryCodeViolationTriggerHandler extends LPI_TriggerHandler  {
      /**
     * @author                      MTX Group Product Team
     * @description                 Triggering methods before inserting
     */
    public override void beforeInsert() {
        List<RegulatoryCodeViolation> recordsList = (List<RegulatoryCodeViolation>) Trigger.New;
        Map<Id,RegulatoryCodeViolation> recordsMap = (Map<Id, RegulatoryCodeViolation>) Trigger.oldMap;
        LPI_RegulatoryCodeViolationTriggerHelper.populatePublicCheckBoxBasedOnAction(recordsList, recordsMap);

        LPI_RegulatoryCodeViolationTriggerHelper.updateVisitContextIdOnRCV(recordsList);  

        LPI_RegulatoryCodeViolationTriggerHelper.updateBLFormCaseOrIns(recordsList);
        
    }

    public override void beforeUpdate() {
        List<RegulatoryCodeViolation> recordsList = (List<RegulatoryCodeViolation>) Trigger.New;
        Map<Id,RegulatoryCodeViolation> recordsMap = (Map<Id, RegulatoryCodeViolation>) Trigger.oldMap;
        LPI_RegulatoryCodeViolationTriggerHelper.populatePublicCheckBoxBasedOnAction(recordsList, recordsMap);
        LPI_RegulatoryCodeViolationTriggerHelper.updateBLFormCaseOrIns(recordsList);

    }
    
    /*
    @author : MTX Group Product Team
    @BuildDate : 2nd jun, 2023
    @description :This method contains methods which should invoke after insertion of RegulatoryCodeViolation record
    @params : List<RegulatoryCodeViolation> recordsList
    @return : void
    */
	public override void afterInsert() {
		List<RegulatoryCodeViolation> recordsList = (List<RegulatoryCodeViolation>) Trigger.New;

		LPI_RegulatoryCodeViolationTriggerHelper.updateBlJson(recordsList, null);
        
        LPI_RegulatoryCodeViolationTriggerHelper.countOfRCVOnAccount(
            recordsList,
            null
        );
        LPI_RegulatoryCodeViolationTriggerHelper.countOfRCVOnLicense(
            recordsList,
            null,
            'isInsert'
        );
	}
    
    /*
    @author : MTX Group Product Team
    @BuildDate : 2nd jun, 2023
    @description :This method contains methods which should invoke after updation of RegulatoryCodeViolation record
    @params :Map<Id, RegulatoryCodeViolation> mapOfOldRecords, List<RegulatoryCodeViolation> recordsList
    @return : void
    */
	public override void afterUpdate() {
		List<RegulatoryCodeViolation> recordsList = (List<RegulatoryCodeViolation>) Trigger.New;
		Map<Id, RegulatoryCodeViolation> mapOfOldRecords = (Map<Id, RegulatoryCodeViolation>) Trigger.oldMap;
        
        LPI_RegulatoryCodeViolationTriggerHelper.updateBlJson(
            recordsList,
            mapOfOldRecords
        );
        LPI_RegulatoryCodeViolationTriggerHelper.countOfRCVOnAccount(
            recordsList,
            mapOfOldRecords
        );
        LPI_RegulatoryCodeViolationTriggerHelper.countOfRCVOnLicense(
            recordsList,
            mapOfOldRecords,
            'isUpdate'
        );
    }

     /**
    * @description : Method to perform business logics after record is deleted.
    * @author: MTX Group Product Team
    **/
    public override void afterDelete() {
        List<RegulatoryCodeViolation> recordsList = (List<RegulatoryCodeViolation>) Trigger.Old;
        Map<Id,RegulatoryCodeViolation> recordsMap = (Map<Id, RegulatoryCodeViolation>) Trigger.oldMap;
        LPI_RegulatoryCodeViolationTriggerHelper.countOfRCVOnAccount(
            null,
            recordsMap
        );
        LPI_RegulatoryCodeViolationTriggerHelper.countOfRCVOnLicense(
            null,
            recordsMap,
            'isDelete'
        );
    }
    
    /**
    * @description : Method to perform business logics after record is undelete.
    * @author: MTX Group Product Team 
    **/
    public override void afterUnDelete() {
        List<RegulatoryCodeViolation> recordsList = (List<RegulatoryCodeViolation>) Trigger.New;
        LPI_RegulatoryCodeViolationTriggerHelper.countOfRCVOnAccount(
            recordsList,
            null
        );
        LPI_RegulatoryCodeViolationTriggerHelper.countOfRCVOnLicense(
            recordsList,
            null,
            'isUndelete'
        );
    }
}