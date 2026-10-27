/**
 * @author              : MTX Group Product Team
 * @since               : June 9, 2023
 * @description         : This Class Contains the Logic to check Duplicate Relatioship Records
 * @history
 * -------------------------------------------------------------------------------------------------------
 * Version      Date                Author                  Details
 *    1         June 9, 2023    	MTX Group Product Team         Initial Developement
 * -------------------------------------------------------------------------------------------------------
 */
public without sharing class LPI_RelationshipService {
	private final static String PRIMARY_SUPERVISOR = 'Primary Supervisor';
	/**
	 * @author                      : MTX Group Product Team
	 * @since                       : June 9, 2023
	 * @description                 : This method return the list of all the duplicate records found for the provided records
	 * @param records               : Takes List of Business Relationship Records/SObjects
	 * @return                      : `List<SObject>`
	 * @last modified by            : MTX Group Product Team
	 * @last modified date          : (Add if modified by you)
	 * @modified details            : (Add if modified by you)
	 */
	public static List<SObject> findDuplicates(List<sObject> records) {
		List<SObject> duplicates = new List<SObject>();
		Savepoint sp = Database.setSavepoint();
		List<Database.SaveResult> saveResultList = Database.insert(records.deepClone(), false);
		for (Database.SaveResult saveResult : saveResultList) {
			if (!saveResult.isSuccess()) {
				for (Database.Error error : saveResult.getErrors()) {
					if (error instanceof Database.DuplicateError) {
						getDuplicateRecords(error, duplicates);
					}
				}
			}
		}
		Database.rollback(sp);
		return duplicates;
	}

	/**
	 * @author                      : MTX Group Product Team
	 * @since                       : June 9, 2023
	 * @description                 : This method return the `Map<Integer, List<sObject>>` where
	 *                                Key is the index of record, and
	 *                                Value as List of Duplicate Records for the perticular record
	 *                                e.g. {0 => [Dup Rec 1, Dup Rec 2 ...], 2=>[ Dup Rec 1...]...}
	 * @param records               : Takes List of Business Relationship Records/SObjects
	 * @param getMap                : Take as Boolean value (True/False)
	 * @return                      : `Map<Integer, List<sObject>>` Key is the index of record and
	 *                                Value as List of Duplicate Records for the perticular record
	 * @last modified by            : MTX Group Product Team
	 * @last modified date          : (Add if modified by you)
	 * @modified details            : (Add if modified by you)
	 */
	public static Map<Integer, List<sObject>> findDuplicateMap(List<sObject> records) {
		Map<Integer, List<sObject>> mapDuplicateRecordByIndex = new Map<Integer, List<sObject>>();
		Savepoint sp = Database.setSavepoint();
		List<Database.SaveResult> saveResultList = Database.insert(records.deepClone(), false);
		Integer recordIndex = 0;
		for (Database.SaveResult saveResult : saveResultList) {
			if (!saveResult.isSuccess()) {
				for (Database.Error error : saveResult.getErrors()) {
					if (error instanceof Database.DuplicateError) {
						List<SObject> duplicates = new List<SObject>();
						getDuplicateRecords(error, duplicates);
						mapDuplicateRecordByIndex.put(recordIndex, duplicates);
					}
				}
			}
			recordIndex++;
		}
		Database.rollback(sp);
		return mapDuplicateRecordByIndex;
	}

	/**
	 * @author                      : MTX Group Product Team
	 * @since                       : June 9, 2023
	 * @description                 : This method is to check the duplicate records for a single Relationship Record
	 * @param record                : Takes Single Business Relationship Record/SObject
	 * @return                      : `List<SObject>` return the list of all the duplicate records found for the provided record(Single)
	 * @last modified by            : MTX Group Product Team
	 * @last modified date          : (Add if modified by you)
	 * @modified details            : (Add if modified by you)
	 */
	public static List<SObject> findDuplicates(sObject record) {
		List<SObject> duplicates = new List<SObject>();
		Savepoint sp = Database.setSavepoint();
		Database.SaveResult saveResult = Database.insert(record.clone(true), false);
		if (!saveResult.isSuccess()) {
			for (Database.Error error : saveResult.getErrors()) {
				if (error instanceof Database.DuplicateError) {
					getDuplicateRecords(error, duplicates);
				}
			}
		}
		Database.rollback(sp);
		return duplicates;
	}

	/**
	 * @author                      : MTX Group Product Team
	 * @since                       : June 9, 2023
	 * @description                 : This method is a helper method and used to extract
	 *                                the duplicate records from the duplicate error object
	 * @param error                 : Takes Database.Error Object
	 * @param duplicateList         : Takes List of List<sObject> (Relationships Records)
	 * @return                      : `void`
	 * @last modified by            : MTX Group Product Team
	 * @last modified date          : (Add if modified by you)
	 * @modified details            : (Add if modified by you)
	 */
	private static void getDuplicateRecords(Database.Error error, List<sObject> duplicateList) {
		Database.DuplicateError duplicateError = (Database.DuplicateError) error;
		Datacloud.DuplicateResult duplicateResult = duplicateError.getDuplicateResult();
		Datacloud.MatchResult matchResult = duplicateResult.getMatchResults()[0];
		for (Datacloud.MatchRecord matchRecord : matchResult.getMatchRecords()) {
			duplicateList.add(matchRecord.getRecord());
		}
	}
	/**
	 * @author                      : MTX Group Product Team
	 * @since                       : June 12, 2023
	 * @description                 : This method is a helper method and used to get unique key after concatenating 4 fields
	 * @param record                : Takes List<Business_Relationships__c>
	 * @return                      : `String` returns unique key for Relationship_Matching_Principal__c field
	 * @last modified by            : MTX Group Product Team
	 * @last modified date          : (Add if modified by you)
	 * @modified details            : Added check for Primary Supervisor
	 */
	public static String generateMatchingKey(Business_Relationships__c relationshipRec) {
		String endDateStamp = relationshipRec.EndDate__c != null
			? String.valueOf(((Datetime) relationshipRec.EndDate__c).getTime() / 1000)
			: '';
		String key = relationshipRec.Related_To__c + endDateStamp + relationshipRec.Related_From__c;
		if (String.isNotBlank(relationshipRec.Parent_Relationship__c)) {
			key += relationshipRec.Parent_Relationship__c;
		}
		if (
			String.isNotBlank(relationshipRec.Related_From_License_Number__c) &&
			PRIMARY_SUPERVISOR.equalsIgnoreCase(relationshipRec.Roles__c)
		) {
			key += relationshipRec.Related_From_License_Number__c;
		}
		if(relationshipRec.isSet('Modify_Relationship_Matching_Principal__c') && 
			relationshipRec.isSet('Start_Date__c') &&
			relationshipRec.Modify_Relationship_Matching_Principal__c && 
			relationshipRec.Start_Date__c != null
		){
			key += relationshipRec.Start_Date__c;
		}
		return key;
	}

	/**
	 * @author                      : MTX Group Product Team
	 * @since                       : July 07, 2023
	 * @description                 : This method is a helper method to get  related Account records
	 * @param accountId             : Id
	 * @return                      : Set<Id> Set of Account Ids
	 * @last modified by            : MTX Group Product Team
	 * @last modified date          : (Add if modified by you)
	 * @modified details            : Added check for Primary Supervisor
	 */
	public static Set<Id> getRelatedAccountId(Id accountId) {
		try {
			set<Id> releatedAccountSet = new Set<Id>();
			if (accountId == null) {
				return releatedAccountSet;
			}
			LPI_AccountDAO.LPI_AccountWithoutSharingDAO accDAOWithoutStaring = new LPI_AccountDAO.LPI_AccountWithoutSharingDAO();
			String fieldToQuery = 'Id, Name, RecordTypeId, Person_Account_For_Business__c';
			String whereClause = 'Id = \'' + accountId + '\'';
			Account selectedAccount = accDAOWithoutStaring.getAccountByDymanicQuery(
				fieldToQuery,
				whereClause,
				'1',
				null,
				null
			)[0];
			releatedAccountSet.add(selectedAccount.Id);
			if (selectedAccount.RecordTypeId == LPI_LiteralConstant.PERSON_ACCOUNT_REC_TYPE_ID) {
				//If this Person Account is not Account for Business
				if (!selectedAccount.Person_Account_For_Business__c) {
					return releatedAccountSet;
				}
				fieldToQuery = 'Id, Related_From__c, Roles__c';
				whereClause = 'Related_To__c = \'' + accountId + '\'';
				LPI_BusinessRelationshipDAO.LPI_BusinessRelationshipsWithoutSharingDAO relationDAOWithoutSharing =
				new LPI_BusinessRelationshipDAO.LPI_BusinessRelationshipsWithoutSharingDAO();
				for (
					Business_Relationships__c relation : relationDAOWithoutSharing.getBusinessRelationshipsByDymanicQuery(
						fieldToQuery,
						whereClause,
						null,
						null,
						null
					)
				) {
					releatedAccountSet.add(relation.Related_From__c);
				}
			}
			fieldToQuery = 'Id, Name';
			whereClause = 'ParentId IN ' + LPI_ServiceUtility.getStringValuesBySet(releatedAccountSet);
			for (
				Account childEntityAcc : accDAOWithoutStaring.getAccountByDymanicQuery(
					fieldToQuery,
					whereClause,
					null,
					null,
					null
				)
			) {
				releatedAccountSet.add(childEntityAcc.Id);
			}
			return releatedAccountSet;
		} catch (Exception e) {
			LPI_ExceptionManager.logException('LPI_RelationshipService', 'getRelatedAccountId', e);
			throw new AuraHandledException(e.getMessage() + e.getLineNumber());
		}	
	}

	/**
	 * @author                      : MTX Group Product Team
	 * @since                       : Dec 14, 2023
	 * @description                 : This method is a helper method to get  related Account records
	 * @param accountId             : Id
	 * @return                      : Set<Id> Set of Account Ids
	 * @last modified by            : MTX Group Product Team
	 * @last modified date          : (Add if modified by you)
	 * @modified details            : 
	 */
	public static Set<Id> getRelatedAccountIdFromMultipleAccount(Set<Id> accountIdSet) {
		try {
			set<Id> releatedAccountSet = new Set<Id>();
			if (accountIdSet.isEmpty()) {
				return releatedAccountSet;
			}
			LPI_AccountDAO.LPI_AccountWithoutSharingDAO accDAOWithoutStaring = new LPI_AccountDAO.LPI_AccountWithoutSharingDAO();
			String fieldToQuery = 'Id, Name, RecordTypeId, Person_Account_For_Business__c';
			String whereClause = 'Id IN '+ LPI_ServiceUtility.getStringValuesBySet(accountIdSet);
			Set<Id> accountSet = new Set<Id>();
			for(Account selectedAccount : accDAOWithoutStaring.getAccountByDymanicQuery(
				fieldToQuery,whereClause,null,null,null)){
					releatedAccountSet.add(selectedAccount.Id);
					if (selectedAccount.RecordTypeId == LPI_LiteralConstant.PERSON_ACCOUNT_REC_TYPE_ID && selectedAccount.Person_Account_For_Business__c) {
						accountSet.add(selectedAccount.Id);
					}
			}
			if(!accountSet.isEmpty()){
				fieldToQuery = 'Id, Related_From__c, Roles__c';
				whereClause = 'Related_To__c IN '+ LPI_ServiceUtility.getStringValuesBySet(accountSet);
				LPI_BusinessRelationshipDAO.LPI_BusinessRelationshipsWithoutSharingDAO relationDAOWithoutSharing =
				new LPI_BusinessRelationshipDAO.LPI_BusinessRelationshipsWithoutSharingDAO();
				for (Business_Relationships__c relation : relationDAOWithoutSharing.getBusinessRelationshipsByDymanicQuery(
						fieldToQuery,whereClause,null,null,null)) {
					releatedAccountSet.add(relation.Related_From__c);
				}
			}
			fieldToQuery = 'Id, Name';
			whereClause = 'ParentId IN ' + LPI_ServiceUtility.getStringValuesBySet(releatedAccountSet);
			for (
				Account childEntityAcc : accDAOWithoutStaring.getAccountByDymanicQuery(
					fieldToQuery,
					whereClause,
					null,
					null,
					null
				)
			) {
				releatedAccountSet.add(childEntityAcc.Id);
			}
			return releatedAccountSet;
		} catch (Exception e) {
			LPI_ExceptionManager.logException('LPI_RelationshipService', 'getRelatedAccountIdFromMultipleAccount', e);
			throw new AuraHandledException(e.getMessage() + e.getLineNumber());
		}	
	}
}