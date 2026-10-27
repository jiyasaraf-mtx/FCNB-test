/**
 * @description       : This MODPR_WithoutSharingUtility class is used by MODPR_InternalRegistration for the internal intake flow functionality
 * @author            : Chanda Rithvik
 **/

public without sharing class LPI_WithoutSharingUtility {
	/**
	 * @author                   Chanda Rithvik
	 * @description              This Method will invoke from the MODPR_WithoutSharingUtility Apex class
	 * @return                   It returns the boolean value which indicates portal user or not
	 */

	public static Boolean isPortalUser() {
		return [SELECT IsPortalEnabled FROM User WHERE Id = :UserInfo.getUserId()][0].IsPortalEnabled;
	}
	/**
	 * @author                   Chanda Rithvik
	 * @description              This Method will invoke from the MODPR_WithoutSharingUtility Apex class
	 * @param  input    		 It takes the input of accountId of string
	 * @return                   It returns the contact Id
	 */
	// public static String getContactIdFromACR(String accountId) {
	// 	return [SELECT ContactId, AccountId FROM AccountContactRelation WHERE AccountId = :accountId][0].ContactId;
	// }

	/**
	 * @author                   Chanda Rithvik
	 * @description              This Method will invoke from the MODPR_WithoutSharingUtility Apex class
	 * @param  input    		 It takes the input of accountId of string
	 * @return                   It returns the Account object
	 */
	public static Account getAccount(String accountId) {
		return [
			SELECT
				Id,
				Name,
				PersonContactId,
				RecordType.DeveloperName,
				PersonOtherStreet,
				PersonOtherState,
				PersonOtherPostalCode,
				PersonOtherCity
			FROM Account
			WHERE Id = :accountId
		];
	}

	/**
	 * @author                   Dhanashree Chougule
	 * @description              This Method will invoke from the MODPR_WithoutSharingUtility Apex class
	 * @param  input    		 It takes the input of blNameCounter of Integer
	 * @return                   It returns void
	 */
	public static void updateAppChecklistCustomSetting(In_App_Checklist_Settings__c appcheckCustomSetting) {
		try 
		{
			update appcheckCustomSetting;
		} catch (Exception e) {
			LPI_ExceptionManager.logException('LPI_WithoutSharingUtility', 'updateAppChecklistCustomSetting', e);
		}
	}

	//  ---------------------------------Added From Base Org ------------------------------------------------------------------

	/**
	* @description 
	* @author Ayush Dev | 05-07-2024 
	* @param recordId 
	* @return PublicComplaint 
	**/
	// public static PublicComplaint getPublicComplaintDetails(String recordId) {
	// 	return [SELECT ID, Name FROM PublicComplaint WHERE Id = :recordId];
	// }

	/**
	* @description 
	* @author Ayush Dev | 05-07-2024 
	* @param ddList 
	**/
	// public static void createDueDiligenceWithoutSharing(List<Due_Diligence__c> ddList) {
	// 	try {
	// 		insert ddList;
	// 	} catch (Exception e) {
	// 		LPI_ExceptionManager.logException('LPI_WithoutSharingUtility', 'createDueDiligenceWithoutSharing', e);
	// 	}
	// }

	/**
	* @description 
	* @author Ayush Dev | 05-07-2024 
	* @param userId 
	* @return User 
	**/
	public static User getUserRecordDetailWithoutSharing(String userId) {
		return [
			SELECT ID, ContactId, AccountId, Name, UserType, MediumPhotoUrl, Country, FullPhotoUrl, SmallPhotoUrl
			FROM User
			WHERE Id = :userId
		];
	}


	/**
	* @description This method is get content workspace
	* @author Ayush Dev | 05-07-2024 
	* @return String 
	**/
	// public static String getContentWorkspace() {
	// 	return JSON.serialize([SELECT id FROM ContentWorkspace WHERE Name = :LPI_LiteralConstant.DOCGEN_TEMPLATE_LIBRARY]);
	// }


	/**
	* @description This method is insert contentWorkspaceDoc
	* @author Ayush Dev | 05-07-2024 
	* @param files 
	**/
	// @future
	// public static void addFiles(String files) {
	// 	insert (List<ContentWorkspaceDoc>) JSON.deserialize(files, List<ContentWorkspaceDoc>.class);
	// }

	/**
	* @description This method is insert List of Sobject
	* @author Ayush Dev | 05-07-2024 
	* @param insertList 
	* @return SObjectAccessDecision 
	**/
	public static SObjectAccessDecision insertSObjectRecord(List<SObject> insertList) {
		try {
		if (!insertList.isEmpty() && !insertList[0].getSObjectType().getDescribe().isCreateable()) {
			throw new AuraHandledException(
				'Insufficient create access. ( Object: ' + insertList[0].getSObjectType() + ' )'
			);
		}
		SObjectAccessDecision securityDecision = LPI_DmlActionUtility.getAccessibleData(
			insertList[0].getSObjectType().getDescribe().getName(),
			insertList,
			'insert',
			true
		);
		insert securityDecision.getRecords();
		return securityDecision;
		} catch (Exception e) {
            throw new AuraHandledException('Error: ' + e.getMessage());
        }
	}

	/**
	* @description This method is insert Sobject
	* @author Ayush Dev | 05-07-2024 
	* @param insertRec 
	**/
	public static void insertSObjectRecord(SObject insertRec) {
		try {
			if (!insertRec.getSObjectType().getDescribe().isCreateable()) {
				throw new LPI_Exception('Insufficient create access. ( Object: ' + insertRec.getSObjectType() + ' )');
			}
			SObjectAccessDecision securityDecision = LPI_DmlActionUtility.getAccessibleData(
				insertRec.getSObjectType().getDescribe().getName(),
				new List<SObject>{ insertRec },
				'insert',
				true
			);
			insert securityDecision.getRecords();
		} catch (Exception e) {
			throw new AuraHandledException('Error: ' + e.getMessage());
		}
	}

	/**
	* @description This method is upsert Sobject
	* @author Ayush Dev | 05-07-2024 
	* @param updateRecList 
	* @return SObjectAccessDecision 
	**/
	public static SObjectAccessDecision upsertSObjectRecord(List<SObject> updateRecList) {
		try {
			if (
				!updateRecList.isEmpty() &&
				!updateRecList[0].getSObjectType().getDescribe().isUpdateable() &&
				!updateRecList[0].getSObjectType().getDescribe().isCreateable()
			) {
				throw new AuraHandledException(
					'Insufficient update access. ( Object: ' + updateRecList[0].getSObjectType() + ' )'
				);
			}
			SObjectAccessDecision securityDecision = LPI_DmlActionUtility.getAccessibleData(
				updateRecList[0].getSObjectType().getDescribe().getName(),
				updateRecList,
				'upsert',
				true
			);
			upsert securityDecision.getRecords();
			return securityDecision;
		} catch (Exception e) {
			throw new AuraHandledException('Error: ' + e.getMessage());
		}
	}

	/**
	* @description This method is upsert Sobject
	* @author Ayush Dev | 05-07-2024 
	* @param updateRecList 
	* @return SObjectAccessDecision 
	**/
	public static SObjectAccessDecision upsertSObjectRecord(SObject updateRecList) {
		try {
			if (
				!updateRecList.getSObjectType().getDescribe().isUpdateable() &&
				!updateRecList.getSObjectType().getDescribe().isCreateable()
			) {
				throw new AuraHandledException(
					'Insufficient update access. ( Object: ' + updateRecList.getSObjectType() + ' )'
				);
			}
			SObjectAccessDecision securityDecision = LPI_DmlActionUtility.getAccessibleData(
				updateRecList.getSObjectType().getDescribe().getName(),
				new List<SObject>{ updateRecList },
				'upsert',
				true
			);
			upsert securityDecision.getRecords();
			return securityDecision;
		} catch (Exception e) {
			throw new AuraHandledException('Error: ' + e.getMessage());
		}
	}

	/**
	* @description 
	* @author Ayush Dev | 05-07-2024 
	* @param updateRec 
	**/
	public static void updateSObjectRecord(SObject updateRec) {
		try {
			if (!updateRec.getSObjectType().getDescribe().isUpdateable()) {
				throw new LPI_Exception('Insufficient update access. ( Object: ' + updateRec.getSObjectType() + ' )');
			}
			SObjectAccessDecision securityDecision = LPI_DmlActionUtility.getAccessibleData(
				updateRec.getSObjectType().getDescribe().getName(),
				new List<SObject>{ updateRec },
				'update',
				true
			);
			update securityDecision.getRecords();
		} catch (Exception e) {
			LPI_ExceptionManager.logException('LPI_WithoutSharingUtility', 'updateSObjectRecord', e);
			throw new AuraHandledException('Error: ' + e.getMessage());
		}
	}
	/*
	@author : Nitesh garg
	@BuildDate :  11/18/2022
	@description : This method is update List of Sobject
	@params : 
	@return : Void
	*/
	public static void updateSObjectRecord(List<SObject> updateRecList) {
		try {
			if (!updateRecList.isEmpty() && !updateRecList[0].getSObjectType().getDescribe().isUpdateable()) {
				throw new AuraHandledException(
					'Insufficient update access. ( Object: ' + updateRecList[0].getSObjectType() + ' )'
				);
			}
			SObjectAccessDecision securityDecision = LPI_DmlActionUtility.getAccessibleData(
				updateRecList[0].getSObjectType().getDescribe().getName(),
				updateRecList,
				'update',
				true
			);
			update securityDecision.getRecords();
		} catch (Exception e) {
			throw new AuraHandledException('Error: ' + e.getMessage());
		}
	}
	/*
    @author : Nitesh garg
    @BuildDate :  11/18/2022
    @description : This method is delete Sobject
    @params : 
    @return : Void
    */
	public static void deleteSObjectRecord(SObject deleteRec) {
		try {
			if (!deleteRec.getSObjectType().getDescribe().isDeletable()) {
				throw new AuraHandledException(
					'Insufficient delete access. ( Object: ' + deleteRec.getSObjectType() + ' )'
				);
			}
			delete deleteRec;
		} catch (Exception e) {
			throw new AuraHandledException('Error: ' + e.getMessage());
		}
	}
	/*
    @author : Nitesh garg
    @BuildDate :  11/23/2022
    @description : This method is delete List of Sobject
    @params : 
    @return : Void
    */
	public static void deleteSObjectRecord(List<SObject> deleteRecList) {
		try {
			if (!deleteRecList.isEmpty() && !deleteRecList[0].getSObjectType().getDescribe().isDeletable()) {
			throw new AuraHandledException(
					'Insufficient delete access. ( Object: ' + deleteRecList[0].getSObjectType() + ' )'
				);
			}
			delete deleteRecList;
		} catch (Exception e) {
			LPI_ExceptionManager.logException('LPI_WithoutSharingUtility', 'deleteSObjectRecord', e);
			throw new AuraHandledException('Error: ' + e.getMessage());
		}
	}
	/**
	 * @author          : Saurabh singh
	 * @param deleteRec
	 * @exception
	 * @description     : This Method use to Delete sObject in only without sharing mode
	 * @return          : Void
	 */
	public static void deleteSObject(SObject deleteRec) {
		try {
			delete deleteRec;
		} catch (Exception e) {
			throw new AuraHandledException('Error: ' + e.getMessage());
		}
	}
	/**
	 * @author          : Mahesh Reddy Chinthakunta
	 * @param deleteRec
	 * @exception
	 * @description     : This Method use to Delete list of sObjects in only without sharing mode
	 * @return          : Void
	 */
	public static void deleteSObject(List<SObject> deleteRec) {
		try {
			delete deleteRec;
		} catch (Exception e) {
			LPI_ExceptionManager.logException('deleteSObject', 'deleteSObject', e);
			throw new AuraHandledException('Error: ' + e.getMessage());
		}
	}

	/**
	 * @author          : Garvit Jain
	 * @param blIdToFormerLicenseNumber
	 * @exception
	 * @description     : This Method use to return List<BusinessLicenseApplication>
	 * @return          : List<BusinessLicenseApplication>
	 */
	// public static List<BusinessLicenseApplication> getBlaRecord(Map<Id, String> blIdToFormerLicenseNumber) {
	// 	return [
	// 		SELECT
	// 			Id,
	// 			Account.Name,
	// 			LicenseType.Name,
	// 			LicensePermitName.Name,
	// 			SavedApplicationRefId,
	// 			ApplicationType,
	// 			Amendment_Type__c,
	// 			Former_Designated_in_charge_License_Num__c,
	// 			New_Designated_in_charge_License_Number__c,
	// 			LicenseType.IssuingDepartment.OnBase_Mapping_Specs__c,
	// 			LicenseType.IssuingDepartment.Name,
	// 			LicenseType.Email_Specifications_Final__c
	// 		FROM BusinessLicenseApplication
	// 		WHERE Id IN :blIdToFormerLicenseNumber.keyset()
	// 		WITH SECURITY_ENFORCED
	// 	];
	// }
	/**
	 * @author          : Neeraj Avadhanam
	 * @param blIdsSet
	 * @exception
	 * @description     : This Method use to return List<BusinessLicense> used to get the license account details
	 * @return          : List<BusinessLicense>
	 */
	// public static List<BusinessLicense> getBusinessLicenseRecord(set<String> blIdsSet) {
	// 	return [SELECT Id, Account.Name, AccountId FROM BusinessLicense WHERE Id IN :blIdsSet WITH SECURITY_ENFORCED];
	// }
	/**
	 * @author          : Neeraj Avadhanam
	 * @param blIdsSet
	 * @exception
	 * @description     : This Method use to return List<Schema.Location> used to get the location details
	 * @return          : List<Schema.Location>
	 */
	// public static List<Schema.Location> getLocationData(set<String> locIds) {
	// 	return [
	// 		SELECT Id, LocationType
	// 		FROM Location
	// 		WHERE Id IN :locIds AND LocationType = 'Branch'
	// 		WITH SECURITY_ENFORCED
	// 	];
	// }
	/**
	 * @author          : Neeraj Avadhanam
	 * @param blIdsSet
	 * @exception
	 * @description     : This Method use to return List<BusinessLicenseApplication> used to get the par from BLA to create AuthAppPlaces
	 * @return          : List<BusinessLicenseApplication>
	 */
	// public static List<BusinessLicenseApplication> getPARFromBLA(set<Id> paridSet) {
	// 	return [
	// 		SELECT ID, SavedApplicationRefId
	// 		FROM BusinessLicenseApplication
	// 		WHERE SavedApplicationRefId IN :paridSet
	// 		WITH SECURITY_ENFORCED
	// 	];
	// }

	/**
	 * @author                   Neeraj Kumar
	 * @description              This Method will invoke from the MODPR_WithoutSharingUtility Apex class
	 * @param  input    		 It takes the input of blNameCounter of Integer
	 * @return                   It returns void
	 */
	public static void updateCourseCounterCustomSetting(Integer courseCounter) {
		In_App_Checklist_Settings__c appcheckCustomSetting = In_App_Checklist_Settings__c.getOrgDefaults();
		appcheckCustomSetting.Course_Counter__c = courseCounter;
		update appcheckCustomSetting;
	}
	/**
	 * @author                   Mahesh Reddy Chinthakunta
	 * @description              This Method will fetch business license application record with status as Payment Pending,Submitted,Approved, Rejected ,License Issued(In with sharing mode we are not getting bla records with status as Payment Pending and Submitted)
	 * @param  blaIdsList        Set<Id>
	 * @param  type    		     String
	 * @param  blaStatusList     List<String>
	 * @return                   `List<BusinessLicenseApplication>`
	 */
	// public static List<BusinessLicenseApplication> getBLARecordStatus(
	// 	Set<Id> blaIdsList,
	// 	String type,
	// 	Id blId,
	// 	List<String> blaStatusList
	// ) {
	// 	List<BusinessLicenseApplication> blaList = [
	// 		SELECT Id, Name
	// 		FROM BusinessLicenseApplication
	// 		WHERE
	// 			LicensePermitNameId = :blId
	// 			AND ApplicationType = :type
	// 			AND Status NOT IN :blaStatusList
	// 			AND SavedApplicationRefId IN :blaIdsList
	// 	];
	// 	return blaList;
	// }

	/**
	 * @author                       : Nitesh garg
	 * @BuildDate                    :  11/18/2022
	 * @description                  : This method is insert Sobject
	 * @param insertRec              :
	 * @last modified by             : Uzma Md
	 * @last modified date           : 31 Jan 2023
	 * @return                       : Void
	 */
	public static SObjectAccessDecision insertSObjectRecordWithoutCheckingCreateAccess(SObject insertRec) {
		try {
			SObjectAccessDecision securityDecision = LPI_DmlActionUtility.getAccessibleData(
				insertRec.getSObjectType().getDescribe().getName(),
				new List<SObject>{ insertRec },
				'insert',
				true
			);
			insert securityDecision.getRecords();
			return securityDecision;
		} catch (Exception e) {
			throw new AuraHandledException('Error: ' + e.getMessage());
		}
	}

	/**
	 * @author                       : Rachna Jadam
	 * @since                        : Jan 10, 2023
	 * @description                  : This Method use to Upsert sObject in without sharing mode
	 * @param sObjectRecord          : sObject Record to be upsert
	 * @return                       : sObject
	 */
	public static sObject upsertSObject(sObject sObjectRecord) {
		try {
			upsert sObjectRecord;
			return sObjectRecord;
		} catch (Exception exceptionInstance) {
			LPI_ExceptionManager.logException('LPI_WithoutSharingUtility', 'upsertSObject', exceptionInstance);
		}
		return sObjectRecord;
	}

	/**
	 * @author                       : Rachna Jadam
	 * @since                        : Jan 10, 2023
	 * @description                  : This Method use to Upsert sObject in without sharing mode
	 * @param sObjectRecord          : sObject Record to be upsert
	 * @return                       : sObject
	 */
	public static sObject insertSObject(sObject sObjectRecord) {
		try {
			insert sObjectRecord;
			return sObjectRecord;
		} catch (Exception exceptionInstance) {
			LPI_ExceptionManager.logException('LPI_WithoutSharingUtility', 'insertSObject', exceptionInstance);
			throw new AuraHandledException('Error: ' + exceptionInstance.getMessage());
		}
	}

	public static List<sObject> insertSObjectList(List<sObject> sObjectRecordList) {
		try {
			insert sObjectRecordList;
			return sObjectRecordList;
		} catch (Exception e) {
			LPI_ExceptionManager.logException('LPI_WithoutSharingUtility', 'insertSObjectList', e);
		}
		return sObjectRecordList;
	}

	/**
	 * @description : Method to upsert sObject list in system context.
	 * @author Kishore Reddy | 03-13-2023
	 * @param List<sObject> sObjList
	 **/
	public static List<sObject> updateSObjectList(List<sObject> sObjectRecordList) {
		try {
			update sObjectRecordList;
		} catch (Exception e) {
			LPI_ExceptionManager.logException('LPI_WithoutSharingUtility', 'updateSObjectList', e);
		}
		return sObjectRecordList;
	}

	/**
	 * @description : Method to upsert sObject list in system context.
	 * @author Mohit Karani | 01-11-2023
	 * @param List<sObject> sObjList
	 **/
	public static List<sObject> upsertSObjectList(List<sObject> sObjList) {
		try {
			upsert sObjList;
			return sObjList;
		} catch (Exception exceptionInstance) {
			LPI_ExceptionManager.logException('LPI_WithoutSharingUtility', 'upsertSObjectList', exceptionInstance);
			throw new AuraHandledException('Error: ' + exceptionInstance.getMessage());
		}
	}

	/**
	 * @description : fetch userType.
	 * @return string
	 * @author | 25-01-2023
	 **/
	@AuraEnabled
	public static String getUserName() {
		try {
			return userinfo.getUserType();
		} catch (Exception e) {
			LPI_ExceptionManager.logException('LPI_WithoutSharingUtility', 'getUserName', e);
			throw new AuraHandledException('Error: ' + e.getMessage());
		}
	}

	/**
	 * @author                       : Ayush Yadav
	 * @since                        : Jan 27, 2023
	 * @description                  : This Method returns the User by Username
	 * @param emailWithsuffix        : Username
	 * @return                       : List<User>
	 */
	public static List<User> getUserByUsername(String emailWithsuffix) {
		return [SELECT Id, Name, Username FROM User WHERE Username = :emailWithsuffix];
	}

	/**
	 * @author                       : Ayush Yadav
	 * @since                        : Jan 27, 2023
	 * @description                  : This Method returns the User by Username
	 * @param emailWithsuffix        : Username
	 * @return                       : List<User>
	 */
	public static List<User> getUserByEmail(String email) {
		return [SELECT Id, Name, Username FROM User WHERE Email = :email];
	}

	/**
	 * @author                       : Ayush Yadav
	 * @since                        : Jan 27, 2023
	 * @description                  : This Method returns the User by Username
	 * @param emailWithsuffix        : Username
	 * @return                       : List<User>
	 */
	public static List<User> getUserByEmail(Set<String> emailSet) {
		return [SELECT Id, Name, Username FROM User WHERE Email IN: emailSet];
	}


	/**
	 * @author                       : Ayush Yadav
	 * @since                        : Jan 27, 2023
	 * @description                  : This Method returns the OTP record by OTP value
	 * @param otpValue               : OTP value
	 * @return                       : List<OTP__c>
	 */
	public static List<OTP__c> getOtpRecordByEmail(String emailValue) {
		return [
			SELECT
				ID,
				CreatedDate,
				Is_Email_Sent__c,
				First_Name__c,
				Last_Name__c,
				Email__c,
				Type__c,
				OTP_Sent_Count__c,
				OTP_Value__c,
				Is_Expired__c
			FROM OTP__c
			WHERE Email__c = :emailValue AND Is_Expired__c = FALSE
			FOR UPDATE
		];
	}

	/**
	 * @description : Get duplicate records for the records passed in the list.
	 * @author Mohit Karani | 02-02-2023
	 * @param accList
	 * @return List<Datacloud.MatchRecord>
	 **/
	public static List<Datacloud.MatchRecord> getDuplicateRecords(List<Account> accList) {
		return LPI_ServiceUtility.getDuplicateRecordsService(accList);
	}

	/**
	 * @author                       : Saurabh
	 * @since                        : Feb 14, 2023
	 * @description                  : This Method use to Upsert sObject in without sharing mode
	 * @param sObjectRecord          : sObject Record to be upsert
	 * @return                       : sObject
	 */
	public static sObject updateSObject(sObject sObjectRecord) {
		try {
			update sObjectRecord;
			return sObjectRecord;
		} catch (Exception e) {
			LPI_ExceptionManager.logException('LPI_WithoutSharingUtility', 'sObjectRecord', e);
			throw new LPI_Exception('Error: ' + e.getMessage());
		}
	}

	/**
	* @description 
	* @author Ayush Dev | 05-07-2024 
	* @param sObjectList 
	* @return List<Datacloud.MatchRecord> 
	**/
	public static List<Datacloud.MatchRecord> getDuplicateRecordsService(List<SObject> sObjectList) {
		return LPI_ServiceUtility.getDuplicateRecordsService(sObjectList);
	}

	public static List<Map<String, Object>> fetchPersonalInfoWithoutSharing(String parId) {
		String DRName = 'exportPersonalInfo';
		Map<String, Object> myTransformData = new Map<String, Object>{ 'getParId' => parId };
		omnistudio.DRProcessResult result = omnistudio.DRGlobal.process(myTransformData, DRName);
		List<Map<String, Object>> myTransformResult = (List<Map<String, Object>>) result.toJsonList();
		return myTransformResult;
	}

	/**
	 * @author              : Rahul Ameta
	 * @since               : May 22, 2023
	 * @param relationId	        : String
	 * @description         : To check access for ACR
	 * @last modified by    : Uzma Md
	 * @last modified date  :
	 * @modified details    :
	 */
	public static Boolean checkACRAccess(String relationId) {
		String currUserId = UserInfo.getUserId();
		LPI_UserDao.LPI_UserWithoutSharingDAO userWithoutSharingSelector = new LPI_UserDao.LPI_UserWithoutSharingDAO();
		List<User> usrList = userWithoutSharingSelector.getUserByDymanicQuery(
			'Id, Name, Profile.Name, ContactId , Contact.AccountId , CreatedById',
			'Id = \'' + currUserId + '\'',
			null,
			null,
			null
		);
		User currentUser = usrList.isEmpty() ? null : usrList[0];
		if (currentUser != null && currentUser.Profile.Name == LPI_LiteralConstant.Portal_Profile_Name) {
			LPI_BusinessRelationshipDAO.LPI_BusinessRelationshipsWithoutSharingDAO selectorInstance = new LPI_BusinessRelationshipDAO.LPI_BusinessRelationshipsWithoutSharingDAO();
			List<Business_Relationships__c> relationList = selectorInstance.getBusinessRelationshipsByDymanicQuery(
				'Id, Related_From__c, Related_To__c, CreatedById',
				'Id = \'' + relationId + '\'',
				null,
				null,
				null
			);
			Business_Relationships__c relationToCheckAccess = relationList.isEmpty() ? null : relationList[0];
			if (relationToCheckAccess != null && relationToCheckAccess.Related_To__c == currentUser.Contact.AccountId) {
				return true;
			}
			else if (relationToCheckAccess.CreatedById == currentUser.Id) {
				return true;
			}
			else {
				Set<String> roleSet = new Set<String>{
					LPI_LiteralConstant.ROLE_DESIGNATED_INCHARGE,
					LPI_LiteralConstant.ROLE_OWNER,
					LPI_LiteralConstant.ROLE_DESIGNATED_INCHARGE_AND_OWNER
				};
				List<Business_Relationships__c> acrWithEntity = selectorInstance.getBusinessRelationshipsByDymanicQuery(
					'Id, Related_From__c,Related_To__c,Roles__c',
					'Related_From__c = \'' +
						relationToCheckAccess.Related_From__c +
						'\'' +
						' AND Related_To__c = \'' +
						currentUser.Contact.AccountId +
						'\''+' AND Roles__c IN '+LPI_ServiceUtility.getStringValuesByStringSet(roleSet),
					null,
					null,
					null
				);
				if (!acrWithEntity.isEmpty() && roleSet.contains(acrWithEntity[0].Roles__c)) {
					return true;
				}
			}
			return false;
		}
		return true; 
	}
}