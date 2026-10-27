/**
 *
 * @author      : MTX Group Product Team
 * @description  : This class contains methods that executes automatically after performing CRUD operations on IndividualApplication records
 * @last modified by            : MTX Group Product Team
 * @last modified date          : 09 Mar, 2023
 * @last modified details       : Added changeBusinessLicenseStatusToRetired() after update
 */
public with sharing class LPI_IndividualAppTriggerHandler extends LPI_TriggerHandler {

	private static Map<String, String> fieldNotTobeChangedMap = new Map<String, String>{
		'Applicant_submission_Date__c' => 'Applicant submission Date',
		'AppliedDate' => 'Applied Date',
		'LicenseTypeId' => 'License Type Id'
	};
	
	/**
	* @description This Method will be called in before insert context of Individual Application Trigger
	* @author MTX Group Product Team
	**/
	public override void beforeInsert() {
		List<IndividualApplication> iaRecordList = (List<IndividualApplication>) Trigger.New;
		List<IndividualApplication> applicationByCRRTeam = new List<IndividualApplication>();
		List<IndividualApplication> applicationByStandFlow = new List<IndividualApplication>();

		for (IndividualApplication iaRecord : iaRecordList) {
			if (iaRecord.Is_Submitted_By_Internal_User__c) {
				applicationByCRRTeam.add(iaRecord);
			} else {
				applicationByStandFlow.add(iaRecord);
			}
		}
        if (!applicationByCRRTeam.isEmpty()) {
			LPI_IndividualAppTriggerHelper.beforeInsertForCRRApplications(applicationByCRRTeam);
		}
		if (!applicationByStandFlow.isEmpty()) {
			LPI_IndividualAppTriggerHelper.beforeInsertHelper(applicationByStandFlow);
		}
	}

	/**
	* @description This Method will be called in before update context of Individual Application Trigger
	* @author MTX Group Product Team
	**/
	public override void beforeUpdate() {
		List<IndividualApplication> iaRecordList = (List<IndividualApplication>) Trigger.New;
		List<IndividualApplication> applicationByCRRTeam = new List<IndividualApplication>();
		List<IndividualApplication> applicationByStandFlow = new List<IndividualApplication>();

		for (IndividualApplication iaRecord : iaRecordList) {
			if (iaRecord.Is_Submitted_By_Internal_User__c) {
				applicationByCRRTeam.add(iaRecord);
			} else {
				applicationByStandFlow.add(iaRecord);
			}
		}
		if (!applicationByCRRTeam.isEmpty()) {
			LPI_IndividualAppTriggerHelper.beforeUpdateForCRRApplications(
				applicationByCRRTeam,
				(Map<Id, IndividualApplication>) Trigger.oldMap
			);
		}
		if (!applicationByStandFlow.isEmpty()) {
			LPI_IndividualAppTriggerHelper.beforeUpdateHelper(
				applicationByStandFlow,
				(Map<Id, IndividualApplication>) Trigger.oldMap
			);
		}
		LPI_ApexSharingUtility.restrictFieldUpdate(
			(List<IndividualApplication>) Trigger.New,
			(Map<Id, IndividualApplication>) Trigger.oldMap,
			fieldNotTobeChangedMap,
			null
		);
	}

	/**
	* @description This Method will be called in after insert context of Individual Application Trigger
	* @author MTX Group Product Team
	**/
	public override void afterInsert() {
		List<IndividualApplication> iaRecordList = (List<IndividualApplication>) Trigger.New;
		List<IndividualApplication> applicationByCRRTeam = new List<IndividualApplication>();
		List<IndividualApplication> applicationByStandFlow = new List<IndividualApplication>();

		for (IndividualApplication iaRecord : iaRecordList) {
			if (iaRecord.Is_Submitted_By_Internal_User__c) {
				applicationByCRRTeam.add(iaRecord);
			} else {
				applicationByStandFlow.add(iaRecord);
			}
		}

		if (!applicationByCRRTeam.isEmpty()) {
			LPI_IndividualAppTriggerHelper.afterInsertForCRRApplications(
				applicationByCRRTeam,
				(Map<Id, IndividualApplication>) Trigger.oldMap
			);
		}
		if (!applicationByStandFlow.isEmpty()) {
			LPI_IndividualAppTriggerHelper.afterInsertHelper(
				applicationByStandFlow,
				(Map<Id, IndividualApplication>) Trigger.oldMap
			);
		}
	}

	/**
	* @description This Method will be called in after update context of Individual Application Trigger
	* @author MTX Group Product Team
	**/
	public override void afterUpdate() {
		List<IndividualApplication> iaRecordList = (List<IndividualApplication>) Trigger.New;
		Map<Id, IndividualApplication> iaOldMap = (Map<Id, IndividualApplication>)Trigger.oldMap;
		List<IndividualApplication> applicationByCRRTeam = new List<IndividualApplication>();
		List<IndividualApplication> applicationByStandFlow = new List<IndividualApplication>();

		// Portal header notifications for License Issued / Submitted (CDC backup path)
		LPI_IAChangeEventHelper.createFromStatusChanges(iaRecordList, iaOldMap);
		// Internal Lightning bell notifications for System Administrators
		LPI_InternalBellNotificationService.notifyAdminsOnStatusChange(iaRecordList, iaOldMap);

		for (IndividualApplication iaRecord : iaRecordList) {
			if (iaRecord.Is_Submitted_By_Internal_User__c) {
				applicationByCRRTeam.add(iaRecord);
			} else {
				applicationByStandFlow.add(iaRecord);
				if((iaRecord.Status == 'Additional Doc Upload' || iaRecord.Status == 'Employer Review Completed') &&
					iaOldMap.get(iaRecord.Id).Status != iaRecord.Status){
					LPI_NotificationCalloutHelper.sendIAEmail(iaRecord);
				}
			}
		}

		if (!applicationByCRRTeam.isEmpty()) {
			LPI_IndividualAppTriggerHelper.afterUpdateForCRRApplications(
				applicationByCRRTeam,
				(Map<Id, IndividualApplication>) Trigger.oldMap
			);
		}
		if (!applicationByStandFlow.isEmpty()) {
			LPI_IndividualAppTriggerHelper.afterUpdateHelper(
				applicationByStandFlow,
				(Map<Id, IndividualApplication>) Trigger.oldMap
			);
		}
	}
}