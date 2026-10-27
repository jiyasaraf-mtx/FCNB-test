/**
 * @author          : Sarabjeet singh
 * @description     : This class Deletes Insurance Information Record For Preneed Seller License.
 * * @history
 * -------------------------------------------------------------------------------------------------------
 * Version      Date                Author                  Details
 *    1         25 Jan, 2023        Sarabjeet Singh         Initial Developement
 * -------------------------------------------------------------------------------------------------------
 */
global with sharing class LPI_PreneedInsuranceInformation implements Callable {
    
    global Object call(String action, Map<String, Object> args) {
        Map<String, Object> input = (Map<String, Object>) args.get('input');
        Map<String, Object> output = (Map<String, Object>) args.get('output');
        Map<String, Object> options = (Map<String, Object>) args.get('options');
        return invokeMethod(action, input, output, options);
    }

    public final static String DELETE_INSURANCE_INFORMATION_RECORD = 'deleteInsuranceInformationRecord';
     /**
	 * @author               : Sarabjeet Singh
	 * @param methodName     : invokeMethod
	 * @param inputMap       : Input Parameter Passed from Omniscript
	 * @param outMap         : Output Passed to Omniscript
	 * @param options        : Extra Options passed from Omniscript
	 * @last modified by     : Uzma Md
	 * @last modified date   : 25 Jan, 2023
	 * @return  `Boolean`
	 */
    private Boolean invokeMethod(
        String methodName,
		Map<String, Object> inputMap,
		Map<String, Object> outMap,
		Map<String, Object> options
	) {
        try{
		if (methodName == DELETE_INSURANCE_INFORMATION_RECORD) {
			deleteInsuranceInformationRecord(inputMap, outMap);
        }
        // else if (methodName == 'fetchDesignatedBrokerDetails') {
		// 	fetchDesignatedBrokerDetails(inputMap);
        // }
        return true;
        }	catch (Exception exp) {
			LPI_ExceptionManager.logException(
				'LPI_PreneedInsuranceInformation',
				'invokeMethod',
				exp
			);
            return false;
        }
    }

    /**
	 * @description This Method Deletes the Insurance Information Record For Preneed Seller License.
	 * @author Sarabjeet Singh | 06-01-2023
	 * @param inputMap fetching all the input from Omniscript
	 * @param outMap Passing value to Omniscript
	 * @last modified by   : Uzma Md
	 * @last modified date : 25 Jan, 2023
	 **/
	public static void deleteInsuranceInformationRecord(Map<String, Object> inputMap, Map<String, Object> outMap) {
		try {
			List<Application_Content__c> deleteAppContentIds = new List<Application_Content__c>();
			Map<String, object> InsuranceStepInfo = (Map<String, object>) inputMap.get('InsuranceInformationStep');
            String parId = (String) inputMap.get('parId');
           	String fields,whereClause;
            List<Application_Content__c> appContentList = new List<Application_Content__c>();
            fields = 'Id, Preliminary_Application_Reference__c';
            if(String.isNotEmpty(parId)){
                whereClause = 'Preliminary_Application_Reference__c =\''+String.escapeSingleQuotes(parId)+'\'';
                // Querying on PAR to get all related records
                appContentList = LPI_ApplicationContentDAO.getApplicationContentByDymanicQuery(
                        fields,
                        whereClause,
                        null,
                        null,
                        null);
            }
            List<String> appContentIdsFromOsList = (List<String>) JSON.deserialize(
                    JSON.serialize(InsuranceStepInfo.get('appContentIds')),
                    List<String>.class
                );

            System.debug('app content Ids'+JSON.serialize(InsuranceStepInfo.get('appContentIds')));
			// Iterating through all the records related to PAR and comparing it with records on Omniscript
			for (Application_Content__c appCon : appContentList) {
				// Adding those records in a list which are not found on omniscript
				if (appContentIdsFromOsList == null || (appContentIdsFromOsList != null && !appContentIdsFromOsList.contains(appCon.Id))) {
					deleteAppContentIds.add(appCon);             
				}
			}
			if (!deleteAppContentIds.isEmpty()) {
				LPI_DML.doDelete(deleteAppContentIds);
			}
		} catch (Exception exp) {
			LPI_ExceptionManager.logException(
				'LPI_PreneedInsuranceInformation',
				'deleteInsuranceInformationRecord',
				exp
			);
        }
	}
    
    //   public static List<Map<String, object>> fetchDesignatedBrokerDetails(Map<String, Object> inputMap) {
    //     List<Map<String, Object>> licenseList = new List<Map<String, Object>>();
    //     try{
    //         String UNITED_STATES = 'United States';
    //         String entityLicenseNumber = '%' + (String) inputMap.get('SalesPersonLicenseNumber') + '%';
    //         Map<String, BusinessLicense> blIdtoBlRecordMap = new Map<String, BusinessLicense>();
    //         Set<Id> accId = new Set<Id>();
    //         // Querying Business License Records
    //         String blQueryFields = 'Id, AccountId, Name,License_Number_With_Rat_Name__c';
    //         String blWhereClauseFields = 'Name LIKE \'' + String.escapeSingleQuotes(entityLicenseNumber) + '\' AND Account.RecordType.DeveloperName=\'' + LPI_LiteralConstant.ACCOUNT_BUSINESS_RECORDTYPE + '\' AND RegulatoryAuthorizationType.Authorisation_Type__c = \'' + LPI_LiteralConstant.ACCOUNT_BUSINESS_RECORDTYPE + '\'';
    //         LPI_BusinessLicenseDAO.LPI_BusinessLicenseWithoutSharingDAO bLListWithOutSharing = new LPI_BusinessLicenseDAO.LPI_BusinessLicenseWithoutSharingDAO();
    //         List<BusinessLicense> businessLicenseList = bLListWithOutSharing.getBusinessLicenseByDymanicQuery(blQueryFields,blWhereClauseFields, null, null, null);
    //         // Loop Iterating over business license records
    //         for (BusinessLicense blList : businessLicenseList) {
    //             blIdtoBlRecordMap.put(blList.AccountId + '-' + blList.Id, blList);
    //             accId.add(blList.AccountId);
    //         }
    //         Map<Id, Business_Relationships__c> accIdtoAccConRecord = new Map<Id, Business_Relationships__c>();
    //         // Querying AccountContactRelationship Records
    //         String accConQueryFields = 'Id, Related_From__c, Related_From__r.Name, Related_From__r.BillingStreet, Related_From__r.BillingCity, Related_From__r.BillingState, Related_From__r.BillingPostalCode, Related_From__r.Phone, Related_To__r.Name, Related_To__r.PersonEmail, Related_From__r.BillingCountry, Related_From__r.County__c, Related_From__r.Buisness_Email__c, Related_From__r.Other_State__c';
    //         String accConWhereClauseFields = 'IsActive__c = true AND Roles__c IN ' + LPI_ServiceUtility.getStringValuesByStringSet(LPI_LiteralConstant.ROLE_INCHARGE_SET);
    //         // Checking whether accId set is empty or not 
    //         If(!accId.isEmpty()){
    //             accConWhereClauseFields += ' AND Related_From__c IN ' + LPI_ServiceUtility.getStringValuesBySet(accId);
    //         }
    //         LPI_BusinessRelationshipDAO.LPI_BusinessRelationshipsWithoutSharingDAO accConRelWithOutSharing = new LPI_BusinessRelationshipDAO.LPI_BusinessRelationshipsWithoutSharingDAO();
    //         List<Business_Relationships__c> accConRel = accConRelWithOutSharing.getBusinessRelationshipsByDymanicQuery(accConQueryFields,accConWhereClauseFields,null,null,null);
    //         // Loop Iterating over AccountContactRelationship records
    //         for (Business_Relationships__c accCon : accConRel) {
    //             accIdtoAccConRecord.put(accCon.Related_From__c, accCon);
    //         }
    //         // Loop iterating over blIdtoBlRecordMap keys 
    //         for (String acc : blIdtoBlRecordMap.keySet()) {
    //             List<String> accIdBLId = acc.split('-');
    //             Business_Relationships__c accConRecord = accIdtoAccConRecord.get(accIdBLId[0]);
    //             If(accConRecord !=null){
    //                 Map<String, Object> licenseMap = new Map<String, Object>();
    //                 licenseMap.put('Name', blIdtoBlRecordMap.get(acc).Name);
    //                 licenseMap.put('TypeAheadkeyName', blIdtoBlRecordMap.get(acc).License_Number_With_Rat_Name__c);
    //                 licenseMap.put('SalesPersonNameOfCorporation', accConRecord.Related_From__r.Name);
    //                 licenseMap.put('SalesPersonStreetAddress', accConRecord?.Related_From__r?.BillingStreet);
    //                 licenseMap.put('SalesPersonCity', accConRecord.Related_From__r.BillingCity);
    //                 licenseMap.put('SalesPersonCountry', accConRecord.Related_From__r.BillingCountry);
    //                 if(accConRecord.Related_From__r.BillingCountry == UNITED_STATES){
    //                     licenseMap.put('SalesPersonState', accConRecord.Related_From__r.BillingState);
    //                 } else{
    //                     licenseMap.put('SalesPersonState', accConRecord.Related_From__r.Other_State__c);
    //                 }
    //                 licenseMap.put('SalesPersonZipcode', accConRecord.Related_From__r.BillingPostalCode);
    //                 licenseMap.put('SalesPersonPhone', accConRecord.Related_From__r.Phone);
    //                 licenseMap.put('SalesPersonBrokerName', accConRecord.Related_To__r.Name);
    //                 licenseMap.put('BrokerEmailAddress', accConRecord.Related_To__r.PersonEmail);
    //                 licenseMap.put('BusinessAccountId', accConRecord.Related_From__c);
    //                 licenseMap.put('SalesPersonCounty', accConRecord.Related_From__r.County__c);
    //                 licenseMap.put('SalesPersonEmail', accConRecord.Related_From__r.Buisness_Email__c);
    //                 licenseMap.put('BusinessLicenseId', accIdBLId[1]);       
    //                 licenseList.add(licenseMap);             
    //             }          
    //         }
    //     } catch(Exception e){
    //         LPI_ExceptionManager.logException(
    //             'CLASS_NAME',
    //             'FETCH_ENTITY_LICENSE_NUMBER',
    //             e
    //         );
    //     }
       
    //     return licenseList;
    // }
}