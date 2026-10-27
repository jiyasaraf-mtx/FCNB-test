/**
 * @description       : 
 * @author            : MTX Group Product Team
 * @group             : 
 * @last modified on  : 07-26-2024
 * @last modified by  : MTX Group Product Team
**/
public with sharing class LPI_BusinessLicenceAppTriggerHandler extends LPI_TriggerHandler {

	private static Map<String, String> fieldNotTobeChangedMap = new Map<String, String>{
		'Applicant_submission_Date__c' => 'Applicant submission Date',
		'AppliedDate' => 'Applied Date',
		'RecordTypeId' => 'Record Type'
	};

    /**
    * @description 
    * @author MTX Group Product Team
    **/
    public override void beforeInsert() {
		List<BusinessLicenseApplication> blaRecordList = (List<BusinessLicenseApplication>) Trigger.New;
		List<BusinessLicenseApplication> applicationByCRRTeam = new List<BusinessLicenseApplication>();
		List<BusinessLicenseApplication> applicationByStandFlow = new List<BusinessLicenseApplication>();

		for (BusinessLicenseApplication blaRecord : blaRecordList) {
			if (blaRecord.Is_Submitted_By_Internal_User__c) {
				applicationByCRRTeam.add(blaRecord);
			} else {
				applicationByStandFlow.add(blaRecord);
			}
		}

		if (!applicationByCRRTeam.isEmpty()) {
			LPI_BusinessLicenceAppTriggerHelper.beforeInsertForCRRApplications(applicationByCRRTeam);
		}
		if (!applicationByStandFlow.isEmpty()) {
			LPI_BusinessLicenceAppTriggerHelper.beforeInsertHelper(applicationByStandFlow);
		}
	}

    /**
    * @description This method contains methods which should invoke before updation of BLA record
    * @author MTX Group Product Team
    **/
    public override void beforeUpdate() {
        List<BusinessLicenseApplication> blaRecordList = (List<BusinessLicenseApplication>) Trigger.New;
        List<BusinessLicenseApplication> applicationByCRRTeam = new List<BusinessLicenseApplication>();
        List<BusinessLicenseApplication> applicationByStandFlow = new List<BusinessLicenseApplication>();
        
        for (BusinessLicenseApplication blaRecord : blaRecordList) {
            if (blaRecord.Is_Submitted_By_Internal_User__c) {
                applicationByCRRTeam.add(blaRecord);
            } else {
                applicationByStandFlow.add(blaRecord);
            }
        }
        
        if (!applicationByCRRTeam.isEmpty()) {
            LPI_BusinessLicenceAppTriggerHelper.beforeUpdateForCRRApplications(
                applicationByCRRTeam,
                (Map<Id, BusinessLicenseApplication>) Trigger.oldMap
            );
        }
        if (!applicationByStandFlow.isEmpty()) {
            LPI_BusinessLicenceAppTriggerHelper.beforeUpdateHelper(
                applicationByStandFlow,
                (Map<Id, BusinessLicenseApplication>) Trigger.oldMap
            );
        }
		LPI_ApexSharingUtility.restrictFieldUpdate(
			(List<BusinessLicenseApplication>) Trigger.New,
			(Map<Id, BusinessLicenseApplication>) Trigger.oldMap,
			fieldNotTobeChangedMap,
			null
		);
    }

	/**
	* @description This method contains methods which should invoke after insertion of BLA record
	* @author MTX Group Product Team
	**/
	public override void afterInsert() {
		List<BusinessLicenseApplication> blaRecordList = (List<BusinessLicenseApplication>) Trigger.New;
		List<BusinessLicenseApplication> applicationByCRRTeam = new List<BusinessLicenseApplication>();
		List<BusinessLicenseApplication> applicationByStandFlow = new List<BusinessLicenseApplication>();

		for (BusinessLicenseApplication blaRecord : blaRecordList) {
			if (blaRecord.Is_Submitted_By_Internal_User__c) {
				applicationByCRRTeam.add(blaRecord);
			} else {
				applicationByStandFlow.add(blaRecord);
			}
		}

		if (!applicationByCRRTeam.isEmpty()) {
			LPI_BusinessLicenceAppTriggerHelper.afterInsertForCRRApplications(
				applicationByCRRTeam,
				(Map<Id, BusinessLicenseApplication>) Trigger.newMap
			);
		}
		if (!applicationByStandFlow.isEmpty()) {
			LPI_BusinessLicenceAppTriggerHelper.afterInsertHelper(
				applicationByStandFlow,
				(Map<Id, BusinessLicenseApplication>) Trigger.newMap
			);
		}
	}

	/**
	* @description This method contains methods which should invoke after updation of BLA record
	* @author MTX Group Product Team
	**/
	public override void afterUpdate() {
		List<BusinessLicenseApplication> blaRecordList = (List<BusinessLicenseApplication>) Trigger.New;
		List<BusinessLicenseApplication> applicationByCRRTeam = new List<BusinessLicenseApplication>();
		List<BusinessLicenseApplication> applicationByStandFlow = new List<BusinessLicenseApplication>();

		for (BusinessLicenseApplication blaRecord : blaRecordList) {
			if (blaRecord.Is_Submitted_By_Internal_User__c) {
				applicationByCRRTeam.add(blaRecord);
			} else {
				applicationByStandFlow.add(blaRecord);
			}
		}

		if (!applicationByCRRTeam.isEmpty()) {
			LPI_BusinessLicenceAppTriggerHelper.afterUpdateForCRRApplications(
				applicationByCRRTeam,
				(Map<Id, BusinessLicenseApplication>) Trigger.oldMap,
				(Map<Id, BusinessLicenseApplication>) Trigger.newMap
			);
		}
		if (!applicationByStandFlow.isEmpty()) {
		LPI_BusinessLicenceAppTriggerHelper.afterUpdateHelper(
		     applicationByStandFlow,
		      (Map<Id, BusinessLicenseApplication>) Trigger.oldMap,
		      (Map<Id, BusinessLicenseApplication>) Trigger.newMap
		  	);
		 }
	}
}