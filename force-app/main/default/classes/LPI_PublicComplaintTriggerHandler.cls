/**
 * @description       : Trigger Handler for PublicComplaint.
 * @author            : MTX Group Product Team
 * @group             : 
 * @last modified on  : 07-26-2024
 * @last modified by  : MTX Group Product Team
**/

public without sharing class LPI_PublicComplaintTriggerHandler extends LPI_TriggerHandler {
	/**
	* @description This method contains methods which should invoke after insertion of public complaint record
	* @author MTX Group Product Team| 05-06-2024 
	**/
	public override void afterInsert() {
		List<PublicComplaint> recordsList = (List<PublicComplaint>) Trigger.New;
	}

	/**
	* @description This method contains methods which should invoke after updation of public complaint record
	* @author MTX Group Product Team| 05-06-2024 
	**/
	public override void afterUpdate() {
		List<PublicComplaint> recordsList = (List<PublicComplaint>) Trigger.New;
		Map<Id, PublicComplaint> mapOfOldRecords = (Map<Id, PublicComplaint>) Trigger.oldMap;
        
        LPI_PublicComplaintTriggerHelper.updateBlJson(
            recordsList,
            mapOfOldRecords
        );
    }

	/**
	* @description This method contains methods which should invoke before insertion of public complaint record
	* @author MTX Group Product Team | 05-06-2024 
	**/
	public override void beforeInsert() {
		List<PublicComplaint> recordsList = (List<PublicComplaint>) Trigger.New;
		Map<Id, PublicComplaint> mapOfOldRecords = (Map<Id, PublicComplaint>) Trigger.oldMap;
        
        LPI_PublicComplaintTriggerHelper.updateBoardName(
            recordsList,
            mapOfOldRecords
        );
    }

	/**
	* @description This method contains methods which should invoke before updation of public complaint record
	* @author MTX Group Product Team | 05-06-2024 
	**/
	public override void beforeUpdate() {
		List<PublicComplaint> recordsList = (List<PublicComplaint>) Trigger.New;
		Map<Id, PublicComplaint> mapOfOldRecords = (Map<Id, PublicComplaint>) Trigger.oldMap;
        
        LPI_PublicComplaintTriggerHelper.updateBoardName(
            recordsList,
            mapOfOldRecords
        );
    }

}