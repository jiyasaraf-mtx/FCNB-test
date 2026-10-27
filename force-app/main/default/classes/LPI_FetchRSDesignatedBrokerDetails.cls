/**
 *
 * @author          : Mahesh Reddy Chinthakunta
 * @Description     : This class will fetch Designated Broker Details
 * @history
 * -------------------------------------------------------------------------------------------------------
 * Version      Date                Author                            Details
 *    1         2 Nov, 2022        Mahesh Reddy Chinthakunta         Developement
 * -------------------------------------------------------------------------------------------------------
 */
global with sharing class LPI_FetchRSDesignatedBrokerDetails 
						//implements Callable 
						{
			public void method1(){
			}
	// *************************************** ALL CONSTANTS ************************************************
	// public final static String FETCH_ENTITY_LICENSE_NUMBER = 'fetchEntityLicenseNumber';
	// //public final static String UPSERT_EMPLOYER_INFORMATION_DETAILS = 'upsertEmployerInformationDetails';
	// public final static String FETCH_DESIGNATED_BROKER_DETAILS = 'FetchDesignatedBrokerDetails';
	// public final static String CLASS_NAME = 'LPI_FetchRSDesignatedBrokerDetails';
	// public final static String INVOKE_METHOD = 'invokeMethod';
	// private final static String UNITED_STATES = 'United States';
	// public final static String APPROVED_STATUS = 'Approved';
	// private final static String CHANGE_OF_CURRENT_EMPLOYMENT_NAME_ADDRESS_PHONE = 'Change of Current Employment Name/Address/Phone';
	// private final static Map<String, String> keyMappingEmpHis = new Map<String, String>{
	// 	'Name' => 'Employer_License_Number__c',
	// 	'SalesPersonAccountName' => 'Name_of_the_Employer__c',
	// 	'SalesPersonPhone' => 'Phone__c',
	// 	'SalesPersonStreetAddress' => 'Street_Address__c',
	// 	'SalesPersonCity' => 'City__c',
	// 	'SalesPersonZipcode' => 'Zip_Code__c',
	// 	'SalesPersonCounty' => 'County__c',
	// 	'SalesPersonState' => 'State__c',
	// 	'SalesPersonCountry' => 'Country__c',
	// 	'SalesPersonEmail' => 'Current_Employer_Email__c',
	// 	'BrokerEmailAddress' => 'Supervisor_Email__c',
	// 	'SalesPersonBrokerName' => 'Immediate_Supervisor_s_Name__c',
	// 	'EmploymentStartDate' => 'Start_date__c',
	// 	'EmploymentType' => 'Type_of_Employment__c',
	// 	'JobTitle' => 'Job_Title_Position_held__c',
	// 	'CurrentLicensePosted' => 'Current_License_Posted__c',
	// 	'CurrentLicensePostedYear' => 'Current_License_Posted_Year__c'
	// };
	// public final static String CHANGE_OF_CUR_EMP_Name = 'Change of Current Employment Name/Address/Phone';
	// private final static String INTERPRETER = 'Interpreter';
	// private final static String TYPE_NEW = 'New';
	// private final static String CERTIFICATION_OF_IDENTIFICATION = 'Request for Certificate of Identification';
	// private final static String UNEMPLOYED = 'Unemployed';
	// private final static Set<String> boardNameSet = new Set<String>{
	// 	'Respiratory Care',
	// 	'Social Workers',
	// 	'Occupational Therapy',
	// 	'Real Estate Appraisers',
	// 	'Accountancy',
	// 	'Athlete Agents',
	// 	'Dental',
	// 	'Optometry',
	// 	'Podiatry',
	// 	'Electrical Contractors',
	// 	'Chiropractic Examiners',
	// 	'Psychologists'
	// };
	// //private final static String COPY_CURRENT_EMPLOYMENT_ADDRESS_IN_LICENSE_ADDRESS = 'CopyCurrentEmploymentAddressInLicenseAddress';
	// private final static Set<String> REAL_ESTATE_RAT_NAME_SET = new Set<String>{
	// 	'Salesperson',
	// 	'Broker Salesperson',
	// 	'Prof. Corp. Salesperson',
	// 	'Assistant Behavior Analyst'
	// };
	// public final static String PROVISIONAL_LICENSE_RAT = 'CPA Provisional License';
	// // ******************************************************************************************************

	// /**
	//  * @author                      : Mahesh Reddy Chinthakunta
	//  * @since                       :
	//  * @description                 : This method calls invoke method
	//  * @param action                : String
	//  * @param args			        : Map<String, Object>
	//  * @return                      : Object
	//  * @last modified by            : MTX Group Inc
	//  * @last modified date          : 03 Feb 2023
	//  * @modified details            :
	//  */
	// global Object call(String action, Map<String, Object> args) {
	// 	Map<String, Object> input = (Map<String, Object>) args.get('input');
	// 	Map<String, Object> output = (Map<String, Object>) args.get('output');
	// 	Map<String, Object> options = (Map<String, Object>) args.get('options');
	// 	return invokeMethod(action, input, output, options);
	// }

	// /**
	//  * @author                      : Mahesh Reddy Chinthakunta
	//  * @since                       : 03 Oct 2022
	//  * @description                 : This method will compare method from Omniscript and execute only that specific method
	//  * @param methodName            : String
	//  * @param inputMap			    : Map<String, Object>
	//  * @param outMap			    : Map<String, Object>
	//  * @param options			    : Map<String, Object>
	//  * @return                      : `Boolean`
	//  * @last modified by            : MTX Group Inc
	//  * @last modified date          : March 20, 2023
	//  * @modified details            : Removed `outMap` and `options` parameters from `upsertEmployerInformationDetails` method as they were not required
	//  */
	// private Boolean invokeMethod(
	// 	String methodName,
	// 	Map<String, Object> inputMap,
	// 	Map<String, Object> outMap,
	// 	Map<String, Object> options
	// ) {
	// 	Boolean result = true;
	// 	try {
	// 		if (methodName.equals(FETCH_ENTITY_LICENSE_NUMBER)) {
	// 			outMap.put('licenseRecords', fetchDesignatedBrokerDetails(inputMap));
	// 		} 
	// 		// else if (methodName.equals(UPSERT_EMPLOYER_INFORMATION_DETAILS)) {
	// 		// 	upsertEmployerInformationDetails(inputMap, outMap);
	// 		// } 
	// 		else if (methodName == FETCH_DESIGNATED_BROKER_DETAILS) {
	// 			FetchDesignatedBrokerDetails(inputMap, outMap);
	// 		}
	// 		//else if (methodName == COPY_CURRENT_EMPLOYMENT_ADDRESS_IN_LICENSE_ADDRESS ) {
	// 		//	CopyCurrentEmploymentAddressInLicenseAddress(inputMap, outMap);
	// 		//}
	// 	} catch (Exception e) {
	// 		LPI_ExceptionManager.logException(CLASS_NAME, INVOKE_METHOD, e);
	// 		result = false;
	// 	}
	// 	return result;
	// }
	// /**
	//  * @author                      : Mahesh Reddy Chinthakunta
	//  * @since                       : 02 Nov 2022
	//  * @description                 : This method will fetch the designated broker details based on entity license number
	//  * @param inputMap			   : Map<String, Object>
	//  * @return                      : `List<Map<String,String>>`
	//  * @last modified by            : MTX Group Inc
	//  * @last modified date          : 03 Feb 2023
	//  * @modified details            :
	//  */
	// public static List<Map<String, object>> fetchDesignatedBrokerDetails(Map<String, Object> inputMap) {
	// 	List<Map<String, Object>> licenseList = new List<Map<String, Object>>();
	// 	try {
	// 		String entityLicenseNumber = '%' + (String) inputMap.get('SalesPersonLicenseNumber') + '%';
	// 		String boardName = (String) inputMap.get('boardName');
	// 		String ratName = inputMap.containskey('regAuthTypeName') ? (String) inputMap.get('regAuthTypeName') : null;
	// 		Map<String, BusinessLicense> blIdtoBlRecordMap = new Map<String, BusinessLicense>();
	// 		Set<Id> accId = new Set<Id>();
	// 		String blQueryFields = 'Id, AccountId, Name, Account.Name, Account.BillingStreet, Business_Entity_Name__c, Legacy_License_Number__c,' +
	// 		' Account.BillingCity, Account.BillingState, Account.BillingPostalCode, Account.Phone, Account.PersonEmail, Account.BillingCountry,' +
	// 		' Account.County__c, Account.Buisness_Email__c, Account.Other_State__c, RegulatoryAuthorizationType.Issuing_Department_Name__c,' +
	// 		' Account.PersonOtherCity, Account.PersonOtherState, Account.PersonOtherCountry, Account.PersonOtherStreet, Account.PersonOtherPostalCode, Account.RecordType.DeveloperName ';
	// 		// Added By Mahesh I-253506
	// 		String blWhereClauseFields =
	// 			'(Business_Entity_Name__c LIKE \'' +
	// 			String.escapeSingleQuotes(entityLicenseNumber) +
	// 			'\' OR Name LIKE \'' +
	// 			String.escapeSingleQuotes(entityLicenseNumber) +
	// 			'\') AND RegulatoryAuthorizationType.Issuing_Department_Name__c = \'' +
	// 			boardName +
	// 			'\''; // Added By Mahesh I-239178
	// 		if(!REAL_ESTATE_RAT_NAME_SET.contains(ratName)){
	// 			blWhereClauseFields += 
	// 			' AND Account.RecordType.DeveloperName = \'' +
	// 			LPI_LiteralConstant.ACCOUNT_BUSINESS_RECORDTYPE +
	// 			'\' AND RegulatoryAuthorizationType.Authorisation_Type__c = \'' +
	// 			LPI_LiteralConstant.ACCOUNT_BUSINESS_RECORDTYPE +
	// 			'\'';
	// 		}
	// 		LPI_BusinessLicenseDAO.LPI_BusinessLicenseWithoutSharingDAO bLListWithOutSharing = new LPI_BusinessLicenseDAO.LPI_BusinessLicenseWithoutSharingDAO();
	// 		List<BusinessLicense> businessLicenseList = bLListWithOutSharing.getBusinessLicenseByDymanicQuery(
	// 			blQueryFields,
	// 			blWhereClauseFields,
	// 			'10',
	// 			null,
	// 			null
	// 		);
	// 		for (BusinessLicense blList : businessLicenseList) {
	// 			Map<String, Object> licenseMap = new Map<String, Object>();
	// 			licenseMap.put('Name', blList.Name);
	// 			if(blList.Legacy_License_Number__c != null){
	// 				licenseMap.put('TypeAheadkeyName', blList.Business_Entity_Name__c + '-' + blList.Legacy_License_Number__c);
	// 			} else{
	// 				licenseMap.put('TypeAheadkeyName', blList.Business_Entity_Name__c + '-' + blList.Name);
	// 			}
	// 			licenseMap.put('SalesPersonAccountName', blList.Account?.Name);
	// 			if(REAL_ESTATE_RAT_NAME_SET.contains(ratName)){
	// 				licenseMap.put('SalesPersonStreetAddress', blList?.Account?.PersonOtherStreet);
	// 				licenseMap.put('SalesPersonCity', blList.Account.PersonOtherCity);
	// 				licenseMap.put('SalesPersonCountry', blList.Account.PersonOtherCountry);
	// 				if (blList.Account.PersonOtherCountry == UNITED_STATES) {
	// 					licenseMap.put('SalesPersonState', blList.Account.PersonOtherState);
	// 				} else {
	// 					licenseMap.put('SalesPersonState', blList.Account.Other_State__c);
	// 				}
	// 				licenseMap.put('SalesPersonZipcode', blList.Account.PersonOtherPostalCode);
	// 				licenseMap.put('SalesPersonEmail', blList.Account.PersonEmail);
	// 			} else{
	// 				licenseMap.put('SalesPersonStreetAddress', blList?.Account?.BillingStreet);
	// 				licenseMap.put('SalesPersonCity', blList.Account.BillingCity);
	// 				licenseMap.put('SalesPersonCountry', blList.Account.BillingCountry);
	// 				if (blList.Account.BillingCountry == UNITED_STATES) {
	// 					licenseMap.put('SalesPersonState', blList.Account.BillingState);
	// 				} else {
	// 					licenseMap.put('SalesPersonState', blList.Account.Other_State__c);
	// 				}
	// 				licenseMap.put('SalesPersonZipcode', blList.Account.BillingPostalCode);
	// 				licenseMap.put('SalesPersonEmail', blList.Account.Buisness_Email__c);
	// 			}
	// 			licenseMap.put('SalesPersonPhone', blList.Account.Phone);
	// 			licenseMap.put('BusinessAccountId', blList.AccountId);
	// 			licenseMap.put('SalesPersonCounty', blList.Account.County__c);
	// 			licenseMap.put('BusinessLicenseId', blList.Id);
	// 			licenseList.add(licenseMap);
	// 		}
	// 		if(!accId.isEmpty()){
	// 			Map<Id, Business_Relationships__c> accIdtoAccConRecord = new Map<Id, Business_Relationships__c>();
	// 			String accConQueryFields = 'Id, Related_From__c, Related_From__r.Name, Related_From__r.BillingStreet, Related_From__r.BillingCity, Related_From__r.BillingState, Related_From__r.BillingPostalCode, Related_From__r.Phone, Related_To__r.Name, Related_To__r.PersonEmail, Related_From__r.BillingCountry, Related_From__r.County__c, Related_From__r.Buisness_Email__c, Related_From__r.Other_State__c';
	// 			String accConWhereClauseFields =
	// 				'IsActive__c = true AND Roles__c IN ' +
	// 				LPI_ServiceUtility.getStringValuesByStringSet(LPI_LiteralConstant.ROLE_INCHARGE_SET);
	// 			if (!accId.isEmpty()) {
	// 				accConWhereClauseFields +=
	// 					' AND Related_From__c IN ' + LPI_ServiceUtility.getStringValuesBySet(accId);
	// 			}
	// 			LPI_BusinessRelationshipDAO.LPI_BusinessRelationshipsWithoutSharingDAO accConRelWithOutSharing = new LPI_BusinessRelationshipDAO.LPI_BusinessRelationshipsWithoutSharingDAO();
	// 			List<Business_Relationships__c> accConRel = accConRelWithOutSharing.getBusinessRelationshipsByDymanicQuery(
	// 				accConQueryFields,
	// 				accConWhereClauseFields,
	// 				null,
	// 				null,
	// 				null
	// 			);
	// 			for (Business_Relationships__c accCon : accConRel) {
	// 				accIdtoAccConRecord.put(accCon.Related_From__c, accCon);
	// 			}
	// 			for (String acc : blIdtoBlRecordMap.keySet()) {
	// 				List<String> accIdBLId = acc.split('-');
	// 				Business_Relationships__c accConRecord = accIdtoAccConRecord.get(accIdBLId[0]);
	// 				if (accConRecord != null) {
	// 					Map<String, Object> licenseMap = new Map<String, Object>();
	// 					licenseMap.put('Name', blIdtoBlRecordMap.get(acc).Name);
	// 					if(blIdtoBlRecordMap.get(acc).Legacy_License_Number__c != null){
	// 						licenseMap.put('TypeAheadkeyName', blIdtoBlRecordMap.get(acc).Business_Entity_Name__c + '-' + blIdtoBlRecordMap.get(acc).Legacy_License_Number__c);
	// 					} else{
	// 						licenseMap.put('TypeAheadkeyName', blIdtoBlRecordMap.get(acc).Business_Entity_Name__c + '-' + blIdtoBlRecordMap.get(acc).Name);
	// 					}
	// 					licenseMap.put('SalesPersonAccountName', accConRecord.Related_From__r.Name);
	// 					licenseMap.put('SalesPersonStreetAddress', accConRecord?.Related_From__r?.BillingStreet);
	// 					licenseMap.put('SalesPersonCity', accConRecord.Related_From__r.BillingCity);
	// 					licenseMap.put('SalesPersonCountry', accConRecord.Related_From__r.BillingCountry);
	// 					if (accConRecord.Related_From__r.BillingCountry == UNITED_STATES) {
	// 						licenseMap.put('SalesPersonState', accConRecord.Related_From__r.BillingState);
	// 					} else {
	// 						licenseMap.put('SalesPersonState', accConRecord.Related_From__r.Other_State__c);
	// 					}
	// 					licenseMap.put('SalesPersonZipcode', accConRecord.Related_From__r.BillingPostalCode);
	// 					licenseMap.put('SalesPersonPhone', accConRecord.Related_From__r.Phone);
	// 					licenseMap.put('SalesPersonBrokerName', accConRecord.Related_To__r.Name);
	// 					licenseMap.put('BrokerEmailAddress', accConRecord.Related_To__r.PersonEmail);
	// 					licenseMap.put('BusinessAccountId', accConRecord.Related_From__c);
	// 					licenseMap.put('SalesPersonCounty', accConRecord.Related_From__r.County__c);
	// 					licenseMap.put('SalesPersonEmail', accConRecord.Related_From__r.Buisness_Email__c);
	// 					licenseMap.put('BusinessLicenseId', accIdBLId[1]);
	// 					licenseList.add(licenseMap);
	// 				}
	// 			}
	// 		}
	// 	} catch (Exception e) {
	// 		LPI_ExceptionManager.logException(CLASS_NAME, FETCH_ENTITY_LICENSE_NUMBER, e);
	// 	}
	// 	return licenseList;
	// }
	// /**
	//  * @author                      : Aditya Chaturvedi
	//  * @since                       :
	//  * @description                 : This method will uspert Employer Information details
	//  * @param inputMap			   : Map<String, Object>
	//  * @return                      : `void`
	//  * @last modified by            : MTX Group Inc
	//  * @last modified date          : March 20, 2023
	//  * @modified details            : Removed `outMap` and `options` parameters as they were not required
	//  */
	// // public static void upsertEmployerInformationDetails(Map<String, Object> inputMap, Map<String, Object> outMap) {
	// // 	try {
	// // 		Map<String, Object> designatedBrokerMap = (Map<String, Object>) inputMap.get(
	// // 			'SalesPersonDesignatedBroker'
	// // 		);
	// // 		Map<String, Object> designatedBrokerBlock = (Map<String, Object>) designatedBrokerMap.get(
	// // 			'SalesPersonLicenseNumber-Block'
	// // 		);
	// // 		Map<String, Object> currentEmploymentDetailsBlock = (Map<String, Object>) designatedBrokerMap.get(
	// // 			'CurrentEmploymentDetails'
	// // 		);
	// // 		if (currentEmploymentDetailsBlock == null) {
	// // 			currentEmploymentDetailsBlock = new Map<String, Object>();
	// // 		}
	// // 		String businessAccountId = (String) inputMap.get('BusinessAccountId');
	// // 		String parId = (String) inputMap.get('parid');
	// // 		String brIdNoToDelete = String.valueOf(inputMap.get('brIdNo')) != null
	// // 			? String.valueOf(inputMap.get('brIdNo'))
	// // 			: null;
	// // 		String brIdYesToUpdate = (String) inputMap.get('brIdYes') != null ? (String) inputMap.get('brIdYes') : null;
	// // 		String brId = '';
	// // 		String parQueryFields = 'Id, Contact__c, Entity_License_Number__c, Employment_History_Ids__c, Contact__r.AccountId, Are_you_currently_Employed__c, BusinessAccountNameId,Is_Your_Employer_Licensed__c,Regulatory_Authorization_Type__r.Name,Regulatory_Authorization_Type__r.IssuingDepartment.Name';
	// // 		String parWhereClause = '';
	// // 		List<PreliminaryApplicationRef> par;
	// // 		List<Business_Relationships__c> accConRel = new List<Business_Relationships__c>();
	// // 		if (!String.isEmpty(parId)) {
	// // 			parWhereClause += 'Id = \'' + String.escapeSingleQuotes(parId) + '\'';
	// // 			par = LPI_PreliminaryApplicationRefDAO.getPreliminaryApplicationRefByDymanicQuery(
	// // 				parQueryFields,
	// // 				parWhereClause,
	// // 				null,
	// // 				null,
	// // 				null
	// // 			);
	// // 		}
	// // 		if (!par.isEmpty()) {
	// // 			if (String.isNotBlank(brIdNoToDelete)) {
	// // 				Business_Relationships__c relationshipRec = new Business_Relationships__c(Id = brIdNoToDelete);
	// // 				LPI_WithoutSharingUtility.deleteSObject(relationshipRec); 
	// // 				outMap.put('brIdNo', '');
	// // 			}
	// // 		}	
	// // 	} catch (Exception e) {
	// // 		LPI_ExceptionManager.logException(CLASS_NAME, UPSERT_EMPLOYER_INFORMATION_DETAILS, e);
	// // 	}
	// // }

	// /**
	//  * @author                      : Saurabh singh
	//  * @since                       :
	//  * @description                 : This method will fetch all the input from Omniscript
	//  * @param inputMap			    : Map<String, Object>
	//  * @param outMap			    : Map<String, Object>
	//  * @return                      : `void`
	//  * @last modified by            : MTX Group Inc
	//  * @last modified date          : 21 Mar 2023
	//  * @modified details            :
	//  */
	// public static void FetchDesignatedBrokerDetails(Map<String, Object> inputMap, Map<String, Object> outMap) {
	// 	try {
	// 		String parId = inputMap.get('parid') != null ? (String) inputMap.get('parid') : (String) inputMap.get('parId');
	// 		String parQueryFields = 'Id, Are_you_currently_Employed__c, Entity_License_Number__c, Business_License__c, Contact__c, Is_Your_Employer_Licensed__c, Type__c, Regulatory_Authorization_Type__r.Name, BusinessAccountNameId, Currently_Not_Employed_Reason__c,';
	// 		parQueryFields += 'Employee_Information_ACR_Ids__c,Is_Supervisor_User__c, Approval_Supervisors_AcrIds__c, Amendment_Type__c, Employment_Status__c, Regulatory_Authorization_Type__r.IssuingDepartment.Name';
	// 		String parWhereClause = '';
	// 		List<PreliminaryApplicationRef> par = new List<PreliminaryApplicationRef>();
	// 		List<BusinessLicense> olddBL = new List<BusinessLicense>();
	// 		List<BusinessLicense> bl = new List<BusinessLicense>();

	// 		if (!String.isEmpty(parId)) {
	// 			parWhereClause += 'Id = \'' + String.escapeSingleQuotes(parId) + '\'';
	// 			par = LPI_PreliminaryApplicationRefDAO.getPreliminaryApplicationRefByDymanicQuery(
	// 				parQueryFields,
	// 				parWhereClause,
	// 				null,
	// 				null,
	// 				null
	// 			);
	// 		}

	// 		Boolean isSupervisorUser = false;
	// 		String approvalSupervisorIds;
	// 		if (!par.isEmpty()) {
	// 			isSupervisorUser = par[0]?.Is_Supervisor_User__c;
	// 			approvalSupervisorIds = par[0]?.Approval_Supervisors_AcrIds__c;
	// 		}
	// 		if (par.isEmpty()) {
	// 			return;
	// 		}
	// 		if(par[0]?.Are_you_currently_Employed__c == 'No'){
	// 			outMap.put('AreYouCurrentlyEmployedNo',par[0]?.Currently_Not_Employed_Reason__c);
	// 		}
	// 		outMap.put('regAuthTypeName', par[0]?.Regulatory_Authorization_Type__r?.Name);
	// 		outMap.put('boardName', par[0]?.Regulatory_Authorization_Type__r?.IssuingDepartment.Name);
	// 		if (!olddBL.isEmpty() && olddBL[0].Is_Migrated_Data__c) {
	// 			String accConQueryFields =
	// 				'Id, Related_From__c, Related_From__r.Name, Related_From__r.BillingStreet, Related_From__r.BillingCity, ' +
	// 				'Related_From__r.BillingState, Related_From__r.BillingPostalCode, Related_From__r.Phone, Related_To__r.Name, Related_To__r.PersonEmail,' +
	// 				' Related_From__r.BillingCountry, Related_From__r.County__c, Related_From__r.Buisness_Email__c, Related_From__r.Other_State__c, Roles__c,' +
	// 				'Related_To__c, Start_Date__c, Employment_Type__c, Job_Title_Position_held__c , Related_From_License_Number__c';
	// 			String accConWhereClauseFields =
	// 				'Related_To__c = \'' +
	// 				String.escapeSingleQuotes(par[0].BusinessAccountNameId) +
	// 				'\' AND Roles__c = \'' +
	// 				String.escapeSingleQuotes(LPI_LiteralConstant.ROLE_EMPLOYEE) +
	// 				'\' AND IsActive__c = true';
	// 			List<Business_Relationships__c> blRealtionList = new LPI_BusinessRelationshipDAO.LPI_BusinessRelationshipsWithoutSharingDAO()
	// 				.getBusinessRelationshipsByDymanicQuery(
	// 					accConQueryFields,
	// 					accConWhereClauseFields,
	// 					'1',
	// 					null,
	// 					null
	// 				);
	// 			if (!blRealtionList.isEmpty()) {
	// 				outMap.put('AreYouCurrentlyEmployed', 'Yes');
	// 				outMap.put('AreYouCurrentlyEmployeed', 'Yes');
	// 				if (String.isEmpty(blRealtionList[0].Related_From_License_Number__c)) {
	// 					outMap.put('ULCEIEmployerLicensed', LPI_LiteralConstant.LPI_NO);
	// 					par[0].Is_Your_Employer_Licensed__c = 'No';
	// 				} else {
	// 					outMap.put('ULCEIEmployerLicensed', LPI_LiteralConstant.LPI_YES);
	// 					par[0].Is_Your_Employer_Licensed__c = 'Yes';
	// 				}
	// 				par[0].Are_you_Currently_Employed__c = 'Yes';
	// 				par[0].Entity_License_Number__c = blRealtionList[0].Id;
	// 			} else {
	// 				outMap.put('AreYouCurrentlyEmployed', 'No');
	// 				outMap.put('AreYouCurrentlyEmployeed', 'No');
	// 				par[0].Are_you_Currently_Employed__c = 'No';
	// 			}
	// 			LPI_DML.doUpdate(par);
	// 		} else {
	// 			if (!olddBL.isEmpty()) {
	// 				if (olddBL[0].Are_you_Currently_Employeed__c != null) {
	// 					outMap.put('AreYouCurrentlyEmployed', olddBL[0].Are_you_Currently_Employeed__c);
	// 					outMap.put('AreYouCurrentlyEmployeed', olddBL[0].Are_you_Currently_Employeed__c);
	// 				}
	// 				if (olddBL[0].Entity_License_Number__c instanceof Id) {
	// 					outMap.put('ULCEIEmployerLicensed', LPI_LiteralConstant.LPI_NO);
	// 				} else if (
	// 					!String.isEmpty(olddBL[0]?.Entity_License_Number__c) &&
	// 					olddBL[0].Are_you_Currently_Employeed__c == LPI_LiteralConstant.LPI_YES
	// 				) {
	// 					outMap.put('ULCEIEmployerLicensed', LPI_LiteralConstant.LPI_YES);
	// 				}
	// 			} else {
	// 				if (par[0].Are_you_Currently_Employed__c != null) {
	// 					outMap.put('AreYouCurrentlyEmployed', par[0].Are_you_Currently_Employed__c);
	// 					outMap.put('AreYouCurrentlyEmployeed', par[0].Are_you_Currently_Employed__c);
	// 				} else if (par[0].Type__c == LPI_LiteralConstant.BLA_AMENDMENT_APPLICATIONTYPE) {
	// 					if (par[0].Is_Your_Employer_Licensed__c != null) {
	// 						outMap.put('ULCEIEmployerLicensed', par[0].Is_Your_Employer_Licensed__c);
	// 					}
	// 					outMap.put('subType', par[0].Amendment_Type__c);
	// 					outMap.put('parType', LPI_LiteralConstant.BLA_AMENDMENT_APPLICATIONTYPE);
	// 				}
	// 				if (par[0].Are_you_Currently_Employed__c == 'Yes') {
	// 					if (par[0].Is_Your_Employer_Licensed__c != null) {
	// 						outMap.put('ULCEIEmployerLicensed', par[0].Is_Your_Employer_Licensed__c);
	// 					}
	// 				}
	// 				if (String.isNotBlank(par[0].Employment_Status__c)) {
	// 					if (par[0].Employment_Status__c != UNEMPLOYED) {
	// 						outMap.put('ULCEIEmployerLicensed', par[0].Is_Your_Employer_Licensed__c);
	// 					}
	// 					outMap.put('EmploymentType', par[0].Employment_Status__c);
	// 					outMap.put('EmploymentTypeQ', par[0].Employment_Status__c);
	// 				}
	// 			}
	// 		}
	// 		String empFields = 'Id, Supervisor_Email__c, Immediate_Supervisor_s_Name__c, Current_License_Posted__c, Current_License_Posted_Year__c';
	// 		String empWhereClause;
	// 		if (String.isEmpty(par[0].Entity_License_Number__c) && String.isNotEmpty(par[0].Business_License__c)) {
	// 			empWhereClause =
	// 				'Business_License__c = \'' +
	// 				String.escapeSingleQuotes(par[0].Business_License__c) +
	// 				'\'';
	// 		} else {
	// 			empWhereClause =
	// 				'Preliminary_Application_Reference__c = \'' +
	// 				String.escapeSingleQuotes(parId) +
	// 				'\'';
	// 		}
	// 		List<PersonEmployment> empList = new List<PersonEmployment>();
	// 		if (isSupervisorUser && approvalSupervisorIds != null) {
	// 			LPI_PersonEmploymentDAO.LPI_EmploymentHistoryWithoutSharingDAO empWithoutSharing = new LPI_PersonEmploymentDAO.LPI_EmploymentHistoryWithoutSharingDAO();
	// 			empList = empWithoutSharing.getEmploymentHistoryByDymanicQuery(
	// 				empFields,
	// 				empWhereClause,
	// 				null,
	// 				null,
	// 				null
	// 			);
	// 		} else {
	// 			empList = new LPI_PersonEmploymentDAO.LPI_EmploymentHistoryWithoutSharingDAO()
	// 				.getEmploymentHistoryByDymanicQuery(empFields, empWhereClause, null, null, null);
	// 		}
	// 		if (
	// 			(String.isEmpty(par[0].Is_Your_Employer_Licensed__c) || par[0].Is_Your_Employer_Licensed__c == 'Yes') &&
	// 			(!boardNameSet.contains(par[0].Regulatory_Authorization_Type__r.IssuingDepartment.Name) || par[0].Regulatory_Authorization_Type__r.Name == PROVISIONAL_LICENSE_RAT)
	// 		) {
	// 			String isreadonlymodestr = (String) inputMap.get('isreadonlymode');
	// 			Boolean isReadOnlyMode = inputMap.containskey('isReadOnlyMode') &&
	// 				inputMap.get('isReadOnlyMode') != null
	// 				? (Boolean) inputMap.get('isReadOnlyMode')
	// 				: false;
	// 			String blQueryFields = 'Id, AccountId, Name, Business_Entity_Name__c, Legacy_License_Number__c, Account.Name,' +
	// 			' Account.BillingStreet, Account.BillingCity, Account.BillingState, Account.BillingPostalCode, Account.Phone,' +
	// 			' Account.PersonEmail, Account.BillingCountry, Account.County__c, Account.Buisness_Email__c, Account.Other_State__c,' + 
	// 			' Account.PersonOtherCity, Account.PersonOtherState, Account.PersonOtherCountry, Account.PersonOtherStreet, Account.PersonOtherPostalCode, Account.RecordType.DeveloperName';
	// 			String blWhereClauseFields;
	// 			if (String.isNotEmpty(par[0].Entity_License_Number__c)) {
	// 				blWhereClauseFields =
	// 					' Name = \'' +
	// 					String.escapeSingleQuotes(par[0].Entity_License_Number__c) +
	// 					'\'';
	// 			}
	// 			if(!REAL_ESTATE_RAT_NAME_SET.contains(par[0]?.Regulatory_Authorization_Type__r?.Name) && String.isNotEmpty(par[0].Entity_License_Number__c)){
	// 				blWhereClauseFields +=
	// 				' AND Account.RecordType.DeveloperName = \'' +
	// 				LPI_LiteralConstant.ACCOUNT_BUSINESS_RECORDTYPE +
	// 				'\' AND RegulatoryAuthorizationType.Authorisation_Type__c = \'' +
	// 				LPI_LiteralConstant.ACCOUNT_BUSINESS_RECORDTYPE +
	// 				'\'';
	// 			}
	// 			if(String.isNotBlank(blWhereClauseFields)){
	// 				bl = new LPI_BusinessLicenseDAO.LPI_BusinessLicenseWithoutSharingDAO()
	// 				.getBusinessLicenseByDymanicQuery(blQueryFields, blWhereClauseFields, null, null, null);
	// 			}
	// 			if (!bl.isEmpty()) {
	// 				Business_Relationships__c designatedACR, currentUserACR;
	// 				//Querying Business_Relationships__c records
	// 				String accConQueryFields = 'Id, Related_From__c, Related_From__r.Name, Related_From__r.BillingStreet,' + 
	// 				' Related_From__r.BillingCity, Related_From__r.BillingState, Related_From__r.BillingPostalCode, Related_From__r.Phone,' + 
	// 				' Related_To__r.Name, Related_To__r.PersonEmail, Related_From__r.BillingCountry, Related_From__r.County__c,' + 
	// 				' Related_From__r.Buisness_Email__c, Related_From__r.Other_State__c, Roles__c, Related_To__c, Start_Date__c,' + 
	// 				' Employment_Type__c, Job_Title_Position_held__c,IsActive__c';
	// 				String accConWhereClauseFields = '';
	// 				if (String.isNotEmpty(bl[0].AccountId)) {
	// 					accConWhereClauseFields +=
	// 						'Related_From__c =\'' +
	// 						String.escapeSingleQuotes(bl[0].AccountId) +
	// 						'\'';
	// 				}
	// 				accConWhereClauseFields +=
	// 					' AND (Related_To__c = \'' +
	// 					String.escapeSingleQuotes(par[0].BusinessAccountNameId) +
	// 					'\' OR (Roles__c IN ' +
	// 					LPI_ServiceUtility.getStringValuesByStringSet(LPI_LiteralConstant.ROLE_INCHARGE_SET) +
	// 					' AND IsActive__c = true)' +
	// 					')';
	// 				List<Business_Relationships__c> accConRel = new LPI_BusinessRelationshipDAO.LPI_BusinessRelationshipsWithoutSharingDAO()
	// 					.getBusinessRelationshipsByDymanicQuery(
	// 						accConQueryFields,
	// 						accConWhereClauseFields,
	// 						null,
	// 						null,
	// 						null
	// 					);
	// 				for (Business_Relationships__c acr : accConRel) {
	// 					if (
	// 						acr.Related_To__c == par[0].BusinessAccountNameId &&
	// 						currentUserACR == null &&
	// 						acr.Related_From__c == bl[0].AccountId
	// 					) {
	// 						if (String.valueOf(acr.Roles__c) == 'Employee') {
	// 							currentUserACR = acr;
	// 						}
	// 					}
	// 					if (LPI_LiteralConstant.ROLE_INCHARGE_SET.contains(acr.Roles__c) && designatedACR == null && acr.IsActive__c) {
	// 						designatedACR = acr;
	// 					}
	// 				}
	// 				if (isReadOnlyMode) {
	// 					if(bl[0].Legacy_License_Number__c != null){
	// 						outMap.put('SalesPersonLicenseNumber_RO', bl[0].Business_Entity_Name__c + '-' + bl[0].Legacy_License_Number__c); 
	// 					} else{
	// 						outMap.put('SalesPersonLicenseNumber_RO', bl[0].Business_Entity_Name__c + '-' + bl[0].Name); 
	// 					}
	// 					outMap.put('Name', bl[0].Name);
	// 				}
	// 				Map<String, Object> rsDesignatedBrokerBlock = new Map<String, Object>();
	// 				Map<String, Object> designatedBrokerBlock = new Map<String, Object>();
	// 				designatedBrokerBlock.put('SalesPersonAccountName', bl[0].Account.Name);
	// 				rsDesignatedBrokerBlock.put('SalesPersonLicenseNumber-Block', designatedBrokerBlock);
	// 				outMap.put('SalesPersonDesignatedBroker', rsDesignatedBrokerBlock);
	// 				outMap.put('SalesPersonAccountName', bl[0].Account.Name);
	// 				if(REAL_ESTATE_RAT_NAME_SET.contains(par[0]?.Regulatory_Authorization_Type__r?.Name)){
	// 					outMap.put('SalesPersonStreetAddress', bl[0].Account.PersonOtherStreet);
	// 					outMap.put('SalesPersonCity', bl[0].Account.PersonOtherCity);
	// 					outMap.put('SalesPersonCountry', bl[0].Account.PersonOtherCountry);
	// 					if (bl[0].Account.PersonOtherCountry == UNITED_STATES) {
	// 						outMap.put('SalesPersonState', bl[0].Account.PersonOtherState);
	// 					} else {
	// 						outMap.put('SalesPersonState', bl[0].Account.Other_State__c);
	// 					}
	// 					outMap.put('SalesPersonZipcode', bl[0].Account.PersonOtherPostalCode);
	// 					outMap.put('SalesPersonEmail', bl[0].Account.PersonEmail); 
	// 				} else{
	// 					outMap.put('SalesPersonStreetAddress', bl[0].Account.BillingStreet);
	// 					outMap.put('SalesPersonCity', bl[0].Account.BillingCity);
	// 					outMap.put('SalesPersonCountry', bl[0].Account.BillingCountry);
	// 					if (bl[0].Account.BillingCountry == UNITED_STATES) {
	// 						outMap.put('SalesPersonState', bl[0].Account.BillingState);
	// 					} else {
	// 						outMap.put('SalesPersonState', bl[0].Account.Other_State__c);
	// 					}
	// 					outMap.put('SalesPersonZipcode', bl[0].Account.BillingPostalCode);
	// 					outMap.put('SalesPersonEmail', bl[0].Account.Buisness_Email__c);
	// 				}
	// 				outMap.put('SalesPersonPhone', bl[0].Account.Phone);
	// 				outMap.put('SalesPersonNameOfNewCorporation', bl[0].Account.Name);
	// 				outMap.put('SalesPersonCounty', bl[0].Account.County__c);
	// 				if (currentUserACR != null) {
	// 					outMap.put('EmploymentStartDate', currentUserACR.Start_Date__c);
	// 					outMap.put('EmploymentType', currentUserACR.Employment_Type__c);
	// 					outMap.put('EmploymentTypeQ', currentUserACR.Employment_Type__c);
	// 					outMap.put('JobTitle', currentUserACR.Job_Title_Position_held__c);
	// 					outMap.put('brIdYes', currentUserACR.Id);
	// 				}
	// 				if (empList != null && !empList.isEmpty()) {
	// 					outMap.put('CurrentLicensePosted', empList[0]?.Current_License_Posted__c);
	// 					outMap.put('CurrentLicensePostedYear', empList[0]?.Current_License_Posted_Year__c);
	// 				}
	// 				if(bl[0].Legacy_License_Number__c != null){
	// 					outMap.put('SalesPersonLicenseNumber', bl[0].Business_Entity_Name__c + '-' + bl[0].Legacy_License_Number__c); //changed mapping
	// 				} else{
	// 					outMap.put('SalesPersonLicenseNumber', bl[0].Business_Entity_Name__c + '-' + bl[0].Name);
	// 				}
	// 				outMap.put('EmployerEntityName', bl[0].Business_Entity_Name__c ); 
	// 				outMap.put('Name', bl[0].Name);
	// 				outMap.put('BusinessAccountId', bl[0].AccountId);
	// 				outMap.put('LicenseNumber', bl[0].Name);
	// 			}
	// 		}
	// 		else if (
	// 			par[0].Is_Your_Employer_Licensed__c == 'No' ||
	// 			(par[0].Are_you_Currently_Employed__c == 'Yes' &&
	// 			boardNameSet.contains(par[0].Regulatory_Authorization_Type__r.IssuingDepartment.Name) && par[0].Regulatory_Authorization_Type__r.Name != PROVISIONAL_LICENSE_RAT) ||
	// 			par[0].Amendment_Type__c == CHANGE_OF_CURRENT_EMPLOYMENT_NAME_ADDRESS_PHONE
	// 		) {
	// 			List<Business_Relationships__c> accConList = new List<Business_Relationships__c>();
	// 			List<Account> acc = new List<Account>();
	// 			String accConQueryFields = 'Id, Related_To__c, Related_From__c, Start_Date__c, Employment_Type__c, Job_Title_Position_held__c';
	// 			String accConWhereClauseFields;
	// 			if(String.isNotBlank(par[0].Entity_License_Number__c)){
	// 				accConWhereClauseFields =
	// 				'Id =\'' +
	// 				String.escapeSingleQuotes(par[0].Entity_License_Number__c) +
	// 				'\'';
	// 			}
	// 			if(String.isNotBlank(accConWhereClauseFields)){
	// 				if (isSupervisorUser && approvalSupervisorIds != null) {
	// 					LPI_BusinessRelationshipDAO.LPI_BusinessRelationshipsWithoutSharingDAO acrWithoutSharing = new LPI_BusinessRelationshipDAO.LPI_BusinessRelationshipsWithoutSharingDAO();
	// 					accConList = acrWithoutSharing.getBusinessRelationshipsByDymanicQuery(
	// 						accConQueryFields,
	// 						accConWhereClauseFields,
	// 						null,
	// 						null,
	// 						null
	// 					);
	// 				} else {
	// 					accConList = new LPI_BusinessRelationshipDAO.LPI_BusinessRelationshipsWithoutSharingDAO()
	// 						.getBusinessRelationshipsByDymanicQuery(
	// 							accConQueryFields,
	// 							accConWhereClauseFields,
	// 							null,
	// 							null,
	// 							null
	// 						);
	// 				}
	// 			}
	// 			if (!accConList.isEmpty()) {
	// 				String personAccWhereClauseFields =
	// 					'Id =\'' +
	// 					String.escapeSingleQuotes(accConList[0].Related_From__c) +
	// 					'\'';
	// 				if (isSupervisorUser && approvalSupervisorIds != null) {
	// 					String accFields = 'Id, Name, Phone, BillingStreet, BillingCity, BillingPostalCode, County__c, BillingState, BillingCountry, BillingCountryCode, Other_State__c, BillingStateCode, Buisness_Email__c, Firm_permit_number__c';
	// 					LPI_AccountDAO.LPI_AccountWithoutSharingDAO accountWithSharing = new LPI_AccountDAO.LPI_AccountWithoutSharingDAO();
	// 					acc = accountWithSharing.getAccountByDymanicQuery(
	// 						accFields,
	// 						personAccWhereClauseFields,
	// 						null,
	// 						null,
	// 						null
	// 					);
	// 				} else {
	// 					acc = new LPI_AccountDAO.LPI_AccountWithoutSharingDAO()
	// 						.getAccountByDymanicQuery(
	// 							'Id, Name, Phone, BillingStreet, BillingCity, BillingPostalCode, County__c, BillingState, BillingCountry, BillingCountryCode, Other_State__c, BillingStateCode, Buisness_Email__c,Firm_permit_number__c',
	// 							personAccWhereClauseFields,
	// 							null,
	// 							null,
	// 							null
	// 						);
	// 				}
	// 				if (!acc.isEmpty()) {
	// 					outMap.put('ULCEIName', acc[0].Name);
	// 					outMap.put('ULCEIStreetAddress', acc[0].BillingStreet);
	// 					outMap.put('ULCEICity', acc[0].BillingCity);
	// 					outMap.put('ULCEIZipcode', acc[0].BillingPostalCode);
	// 					if (UNITED_STATES.equalsIgnoreCase(acc[0].BillingCountry)) {
	// 						outMap.put('ULCEIState', acc[0].BillingStateCode);
	// 						outMap.put('ULCEIStateFC', acc[0].BillingState);
	// 					} else {
	// 						outMap.put('ULCEIStateText', acc[0].Other_State__c);
	// 					}
	// 					outMap.put('ULCEIPhone', acc[0].Phone);
	// 					outMap.put('ULCEIEmail', acc[0].Buisness_Email__c);
	// 					outMap.put('ULCEICounty', acc[0].County__c);
	// 					outMap.put('ULCEICountry', acc[0].BillingCountryCode);
	// 					outMap.put('ULCEICountryFC', acc[0].BillingCountry);
	// 					outMap.put('ULCEIEmploymentStartDate', accConList[0].Start_Date__c);
	// 					outMap.put('ULCEIEmploymentType', accConList[0].Employment_Type__c);
	// 					outMap.put('ULCEIJobTitle', accConList[0].Job_Title_Position_held__c);
	// 					if(acc[0].Firm_permit_number__c != null){
	// 						outMap.put('Firmpermitnumber', acc[0].Firm_permit_number__c);
	// 					}
	// 					if (!empList.isEmpty()) {
	// 						outMap.put('ULCEIPersonInChargeName', empList[0]?.Immediate_Supervisor_s_Name__c);
	// 						outMap.put('ULCEIPersonInChargeEmailAddress', empList[0]?.Supervisor_Email__c);
	// 					}
	// 					outMap.put('busAccountId', acc[0].Id);
	// 					outMap.put('brIdNo', accConList[0].Id);
	// 				}
	// 			}
	// 		}
	// 	} catch (Exception e) {
	// 		LPI_ExceptionManager.logException(CLASS_NAME, FETCH_DESIGNATED_BROKER_DETAILS, e);
	// 	}
	// }
	// /**
	//  * @author                      : Saurabh singh
	//  * @since                       : 20 Dec 2023
	//  * @description                 : This method will Copy the adddress of Current Employment Step and create new Temp AAP record of License Address for PI Step usage.
	//  * @param inputMap			    : Map<String, Object>
	//  * @param outMap			    : Map<String, Object>
	//  * @return                      : `void`
	//  * @last modified by            : MTX Group Inc
	//  * @last modified date          : 
	//  * @modified details            :
	//  */
	// /*public static void CopyCurrentEmploymentAddressInLicenseAddress(Map<String, Object> inputMap, Map<String, Object> outMap) {
	// 	try {
	// 		String parId = inputMap.get('parid') != null ? (String) inputMap.get('parid') : (String) inputMap.get('parId');
	// 		Boolean flag = true;
	// 		Set<Id> locIdSet = new Set<Id>();
	// 		for (
	// 			Temp_AuthApplicationPlace__c tempAap : new LPI_TempAuthApplicationPlaceDAO.LPI_TempAuthApplicationPlaceWithoutSharingDAO()
	// 				.getTempAuthApplicationPlaceByDymanicQuery(
	// 					'Id,Location__c,Location__r.Consent_For__c',
	// 					'Preliminary_Application_Reference__c = \'' + String.escapeSingleQuotes(parId) + '\'',
	// 					null,
	// 					null,
	// 					null
	// 				)
	// 		) {
	// 			if(tempAap.Location__r.Consent_For__c == 'License Address')
	// 			{
	// 				locIdSet.add(tempAap.Location__c);
	// 				flag = false;
	// 			}
	// 		}

	// 		List<PersonEmployment> employmentHistory = LPI_PersonEmploymentDAO.getEmploymentHistoryByDymanicQuery('Id,EmployerStateStreet,EmployerCity,EmployerState,EmployerCountry,EmployerPostalCode,County__c','Preliminary_Application_Reference__c=\''+String.escapeSingleQuotes(parId)+'\'',null,null,null);
	// 		List<PreliminaryApplicationRef> parList = LPI_PreliminaryApplicationRefDAO.getPreliminaryApplicationRefByDymanicQuery('Id,BusinessAccountName.Name,BusinessAccountNameId','Id = \'' + String.escapeSingleQuotes(parId) + '\'',null,null,null);
			
	// 		if(!employmentHistory.isEmpty() && !parList.isEmpty() && flag == true)
	// 		{
	// 			Schema.Location locationRec = new Schema.Location();
	// 			locationRec.Name = parList[0].BusinessAccountName.Name + '-' + 'Business Address';
	// 			locationRec.LocationType = 'Business Address';
	// 			locationRec.Status__c = 'Closed';
	// 			locationRec.OpenDate = System.today();
	// 			locationRec.Consent_For__c = 'License Address';
	// 			LPI_WithoutSharingUtility.insertSObject(locationRec);
	// 			Schema.Address address = new Schema.Address();
	// 			address.LocationType = 'Business Address';
	// 			address.Street = employmentHistory[0].EmployerStreet;
	// 			address.City = employmentHistory[0].EmployerCity;
	// 			address.Country = employmentHistory[0].EmployerCountry;
	// 			address.PostalCode = employmentHistory[0].EmployerPostalCode;
	// 			if(employmentHistory[0].EmployerCountry =='United States')
	// 			{
	// 				address.State = employmentHistory[0].EmployerState;
	// 				address.Business_State__c = null;
	// 			}
	// 			else
	// 			{
	// 				address.State = null;
	// 				address.Business_State__c = employmentHistory[0].EmployerState;
	// 			}
	// 			address.County__c = employmentHistory[0].EmployerCountry;
	// 			address.ParentId = locationRec.Id;
	// 			LPI_WithoutSharingUtility.insertSObject(address);

	// 			AssociatedLocation al = new AssociatedLocation();
	// 			al.ParentRecordId = parList[0].BusinessAccountNameId;
	// 			al.LocationId = locationRec.Id;
	// 			LPI_WithoutSharingUtility.insertSObject(al);
				
	// 			Temp_AuthApplicationPlace__c tempAAP = new Temp_AuthApplicationPlace__c();
	// 			tempAAP.Location__c = locationRec.Id;
	// 			tempAAP.Preliminary_Application_Reference__c = parId;
	// 			LPI_WithoutSharingUtility.insertSObject(tempAAP);
	// 			PreliminaryApplicationRef par = new PreliminaryApplicationRef(Id = parList[0].Id);
	// 			par.License_Address__c = 'Business Address';
	// 			LPI_TriggerHandler.bypass('PreliminaryApplicationTriggerHandler');
	// 			if (LPI_TriggerHandler.isBypassed('PreliminaryApplicationTriggerHandler')) {
	// 				LPI_DML.doUpdate(par);
	// 			}
	// 			LPI_TriggerHandler.clearBypass('PreliminaryApplicationTriggerHandler');
	// 		}
	// 		else if(flag == false)
	// 		{
	// 			List<Schema.Address> addresses = LPI_AddressDAO.getAddressByDymanicQuery('Id', 'ParentId IN ' + LPI_ServiceUtility.getStringValuesBySet(locIdSet), null, null, null);
	// 			if(!addresses.isEmpty())
	// 			{
	// 				Schema.Address UpdateAddress = new Schema.Address();
	// 				UpdateAddress.Id = addresses[0].Id;
	// 				UpdateAddress.Street = employmentHistory[0].EmployerStreet;
	// 				UpdateAddress.City = employmentHistory[0].EmployerCity;
	// 				UpdateAddress.Country = employmentHistory[0].EmployerCountry;
	// 				UpdateAddress.PostalCode = employmentHistory[0].EmployerPostalCode;
	// 				if(employmentHistory[0].EmployerCountry =='United States')
	// 				{
	// 					UpdateAddress.State = employmentHistory[0].EmployerState;
	// 					UpdateAddress.Business_State__c = null;
	// 				}else{
	// 					UpdateAddress.State = null;
	// 					UpdateAddress.Business_State__c = employmentHistory[0].EmployerState;
	// 				}
	// 				UpdateAddress.County__c = employmentHistory[0].EmployerCountry;
	// 				LPI_WithoutSharingUtility.updateSObject(UpdateAddress);
	// 			}
	// 		}

	// 	} catch (Exception e) {
	// 		LPI_ExceptionManager.logException(CLASS_NAME, COPY_CURRENT_EMPLOYMENT_ADDRESS_IN_LICENSE_ADDRESS, e);
	// 	}
	// }*/
}