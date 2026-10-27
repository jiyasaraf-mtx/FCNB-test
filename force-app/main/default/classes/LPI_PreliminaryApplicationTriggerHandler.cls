/*
Created By : MTX.Inc
This Class is the handler class on PAR trigger
*/
public with sharing class LPI_PreliminaryApplicationTriggerHandler extends LPI_TriggerHandler { 
	/**
	*   @author : MTX.Inc
	*   @since  : 3rd Nov, 2022
	*   @description : This method contains which should invoke before insertion of PAR records
	*   @params : List of PreliminaryApplicationRef
	*   @return : void
	*/
	public override void beforeInsert() {
		List<PreliminaryApplicationRef> recordsList = (List<PreliminaryApplicationRef>) Trigger.New;
		
		LPI_PARTriggerHelper.updateBoardName(recordsList, null);
	}
	
	/**
	*   @author : MTX.Inc
	*   @since  : 3rd Nov, 2022
	*   @description : This method contains which should invoke after insertion of PAR records
	*   @params : List of PreliminaryApplicationRef
	*   @return : void
	*/
	public override void afterInsert() {
		List<PreliminaryApplicationRef> recordsList = (List<PreliminaryApplicationRef>) Trigger.New;
		LPI_PARTriggerHelper.cloneRegulatoryAuthorizationContent(recordsList, null);
		
		LPI_ApexSharingUtility.manageRecordAccess(recordsList, null);
	}
	
	/**
	*   @author : MTX.Inc
	*   @since  : 3rd Nov, 2022
	*   @description : This method contains which should invoke before updation of PAR records
	*   @params : Map<Id, PreliminaryApplicationRef> mapOfOldRecords, List<PreliminaryApplicationRef> recordsList
	*   @return : void
	*/
	public override void beforeUpdate() {
		List<PreliminaryApplicationRef> recordsList = (List<PreliminaryApplicationRef>) Trigger.New;
		Map<Id, PreliminaryApplicationRef> mapOfOldRecords = (Map<Id, PreliminaryApplicationRef>) Trigger.oldMap;
		Map<Id, PreliminaryApplicationRef> mapOfNewRecords = (Map<Id, PreliminaryApplicationRef>) Trigger.newMap;
		LPI_PARTriggerHelper.updateBoardName(recordsList, mapOfOldRecords);
		//This should be last method of before update
		LPI_ApexSharingUtility.restrictFieldUpdate(
		(List<PreliminaryApplicationRef>) Trigger.New,
		(Map<Id, PreliminaryApplicationRef>) Trigger.oldMap,
		fieldNotTobeChangedMap,
		null
		);
	}
	
	/**
	*   @author : MTX.Inc
	*   @since  : 3rd Nov, 2022
	*   @description : This method contains which should invoke after updation of PAR records
	*   @params : Map<Id, PreliminaryApplicationRef> mapOfOldRecords, List<PreliminaryApplicationRef> recordsList
	*   @return : void
	*/
	public override void afterUpdate() {
		List<PreliminaryApplicationRef> recordsList = (List<PreliminaryApplicationRef>) Trigger.New;
		Map<Id, PreliminaryApplicationRef> mapOfOldRecords = (Map<Id, PreliminaryApplicationRef>) Trigger.oldMap;
		LPI_PARTriggerHelper.handleSubmittedPARAndCreateApplications(mapOfOldRecords, recordsList);
		System.debug('###CAlling cloneRegulatoryAuthorizationContent '+recordsList.size()+' >> '+recordsList+'>> mnap '+mapOfOldRecords);
		LPI_PARTriggerHelper.cloneRegulatoryAuthorizationContent(recordsList, mapOfOldRecords);
		LPI_PARTriggerHelper.updateNameOnIAIfUpdatedOnPar(recordsList, mapOfOldRecords);
		//method is called to delete related records of Profession counselor License Type
		//LPI_PARTriggerHelper.deleteRelateRecordsOfPCLicenseType(recordsList,mapOfOldRecords);
		LPI_PARTriggerHelper.updateAccountOnSaveAPI(recordsList,mapOfOldRecords);
		SharingLedger_SourceObjectTriggerHelper.detectAndProcessSharingDueToOwnerChange(recordsList, mapOfOldRecords);
	}
	
	//This map include field that should not be changed once record is created
	private static Map<String, String> fieldNotTobeChangedMap = new Map<String, String>{
		//API NAME
		//to be discussed    							  //LABEL
		'Regulatory_Authorization_Type__c' => 'Regulatory Authorization Type'
	};
}