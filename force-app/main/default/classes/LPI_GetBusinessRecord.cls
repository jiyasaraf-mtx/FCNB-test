/**
 * @description       : This class Fetch all the Associated Business
 * @author            : Ayush Dev
 * @group             : 
 * @last modified on  : 07-12-2024
 * @last modified by  : MTX Group Inc
**/

global without sharing class LPI_GetBusinessRecord implements Callable {
	global Object call(String action, Map<String, Object> args) {
		Map<String, Object> input = (Map<String, Object>) args.get('input');
		Map<String, Object> output = (Map<String, Object>) args.get('output');
		Map<String, Object> options = (Map<String, Object>) args.get('options');
		return invokeMethod(action, input, output, options);
	}
	/**
	 * @author                : Saurabh Singh
	 * @param methodName      : method name to Execute
	 * @param inputMap        : Fetch input detail from OS
	 * @param outMap          : Send  output detail to OS
	 * @param options         : Send  options detail to OS
	 * @return                : `Boolean`
	 */
	private Boolean InvokeMethod(
		String methodName,
		Map<String, Object> inputMap,
		Map<String, Object> outMap,
		Map<String, Object> options
	) {
		// Boolean result = false;
		// try {
		// 	if (methodName == 'fetchBusinessRecords') {
		// 		outMap.put('BusinessRecords', fetchBusinessRecords((String) options.get('userrecid')));
		// 		result = true;
		// 	}
		// } catch (Exception ex) {
		// 	LPI_ExceptionManager.logException('LPI_GetBusinessRecord', 'InvokeMethod', ex);
		// }
		return null;
	}

	/**
	 * @author                      : Saurabh Singh
	 * @since                       :
	 * @description                 : This method fetches the Business Records
	 * @param userId                : portal User Id
	 * @return                      : List<Map<String, String>>
	 * @last modified by            : MTX Group Inc
	 * @last modified date          : 27 Jan, 2023
	 * @modified details            : Optimized Code
	 */
	// public static List<Map<String, Object>> fetchBusinessRecords(String userId) {
	// 	try {
	// 		String userQuery = 'ContactId';
	// 		String whereClause = 'Id = \'' + String.escapeSingleQuotes(userId) + '\'';
	// 		List<User> userList = LPI_UserDao.getUserByDymanicQuery(userQuery, whereClause, null, null, null);
	// 		Id conId;
	// 		if (!userList.isEmpty()) {
	// 			LPI_AccountDAO.LPI_AccountWithoutSharingDAO accountWithoutSharing = new LPI_AccountDAO.LPI_AccountWithoutSharingDAO();
	// 			List<Account> acc =  accountWithoutSharing.getAccountByDymanicQuery('Id','PersonContactId = \''+userList[0].ContactId+'\'',null,null,null);
	// 			conId = acc[0].Id;
	// 		}
	// 		Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
	// 			.get(LPI_LiteralConstant.ACCOUNT_BUSINESS_RECORDTYPE)
	// 			.getRecordTypeId();
	// 		Integer i = 1;
	// 		List<Map<String, Object>> testmap = new List<Map<String, Object>>();
	// 		String accountContactRelationQuery = 'Id, Related_From__c, Related_From__r.Name, Related_From__r.BillingStreet, Related_From__r.BillingCity,  Related_From__r.BillingState, Related_From__r.BillingCountry, Related_From__r.BillingPostalCode, IsActive__c, Roles__c';
	// 		String accountContactRelationQueryCondition =
	// 			'Related_To__c = \'' +
	// 			String.escapeSingleQuotes(conId) +
	// 			'\' AND Related_From__r.RecordTypeId = \'' +
	// 			String.escapeSingleQuotes(accRecordTypeId) +
	// 			'\'';
	// 		List<Business_Relationships__c> accountContactList = new LPI_BusinessRelationshipDAO.LPI_BusinessRelationshipsWithoutSharingDAO()
	// 			.getBusinessRelationshipsByDymanicQuery(
	// 				accountContactRelationQuery,
	// 				accountContactRelationQueryCondition,
	// 				null,
	// 				null,
	// 				null
	// 			);
	// 		Set<Id> accountIds = new Set<Id>();
	// 		for (Business_Relationships__c accCon : accountContactList) {
	// 			accountIds.add(accCon.Related_From__c);
	// 		}
	// 		Map<Id, List<BusinessLicense>> accIdBLMap = new Map<Id, List<BusinessLicense>>();
	// 		if (!accountIds.isEmpty()) {
	// 			String businessLicenseQuery = 'Id, Name, RegulatoryAuthorizationTypeId, RegulatoryAuthorizationType.Amendment_Type__c, AccountId';
	// 			String accountIdSet = LPI_ServiceUtility.getStringValuesByList(new List<Id>(accountIds));
	// 			String businessLicenseQueryCondition = 'AccountId IN ' + accountIdSet;
	// 			List<BusinessLicense> businessLicenseList = LPI_BusinessLicenseDAO.fetchBusinessLicenseRecords(
	// 				businessLicenseQuery,
	// 				businessLicenseQueryCondition
	// 			);
	// 			for (BusinessLicense blData : businessLicenseList) {
	// 				if (!accIdBLMap.containsKey(blData.AccountId)) {
	// 					accIdBLMap.put(blData.AccountId, new List<BusinessLicense>());
	// 					accIdBLMap.get(blData.AccountId).add(blData);
	// 				}
	// 			}
	// 		}
	// 		for (Business_Relationships__c accCon : accountContactList) {
	// 			Map<String, Object> mapOfInfo = new Map<String, Object>();
	// 			mapOfInfo.put('sno', '' + i);
	// 			mapOfInfo.put('BusinessName', accCon.Related_From__r.Name);
	// 			mapOfInfo.put('Role', accCon.Roles__c.replace('Designated Incharge', 'Person In Charge'));
	// 			mapOfInfo.put('BusinessAccountId', accCon.Related_From__c);
	// 			mapOfInfo.put(
	// 				'regAuthId',
	// 				(accCon.Roles__c.contains('Designated Incharge') &&
	// 					accIdBLMap.containsKey(accCon.Related_From__c) &&
	// 					accIdBLMap.get(accCon.Related_From__c).size() > 0)
	// 					? '' + accIdBLMap.get(accCon.Related_From__c)[0].RegulatoryAuthorizationTypeId
	// 					: null
	// 			);
	// 			mapOfInfo.put(
	// 				'blid',
	// 				(accCon.Roles__c.contains('Designated Incharge') &&
	// 					accIdBLMap.containsKey(accCon.Related_From__c) &&
	// 					accIdBLMap.get(accCon.Related_From__c).size() > 0)
	// 					? '' + accIdBLMap.get(accCon.Related_From__c)[0].Id
	// 					: null
	// 			);

	// 			String street = String.isNotBlank(accCon.Related_From__r.BillingStreet)
	// 				? accCon.Related_From__r.BillingStreet + ', '
	// 				: '';
	// 			String city = String.isNotBlank(accCon.Related_From__r.BillingCity) ? accCon.Related_From__r.BillingCity + ', ' : '';
	// 			String state = String.isNotBlank(accCon.Related_From__r.BillingState) ? accCon.Related_From__r.BillingState + ', ' : '';
	// 			String country = String.isNotBlank(accCon.Related_From__r.BillingCountry)
	// 				? accCon.Related_From__r.BillingCountry + ', '
	// 				: '';
	// 			String postalCode = String.isNotBlank(accCon.Related_From__r.BillingPostalCode)
	// 				? accCon.Related_From__r.BillingPostalCode
	// 				: '';
	// 			mapOfInfo.put('BusinessAddress', street + city + state + country + postalCode);
	// 			mapOfInfo.put(
	// 				'isChangeOfPersonInCharge',
	// 				(accIdBLMap.containsKey(accCon.Related_From__c) &&
	// 					accIdBLMap.get(accCon.Related_From__c).size() > 0 &&
	// 					String.isNotEmpty(
	// 						accIdBLMap.get(accCon.Related_From__c)[0].RegulatoryAuthorizationType.Amendment_Type__c
	// 					) &&
	// 					(accIdBLMap.get(accCon.Related_From__c)[0]
	// 						.RegulatoryAuthorizationType.Amendment_Type__c.contains('Change of Designated Incharge') || 
	// 					accIdBLMap.get(accCon.Related_From__c)[0]
	// 						.RegulatoryAuthorizationType.Amendment_Type__c.contains('Change of Administrator')))
	// 					? true
	// 					: false
	// 			);
	// 			mapOfInfo.put('Status', accCon.IsActive__c == true ? 'Active' : 'Inactive');
				
	// 			i += 1;
	// 			testmap.add(mapOfInfo);
	// 		}
	// 		return testmap;
	// 	} catch (exception ex) {
	// 		LPI_ExceptionManager.logException('LPI_GetBusinessRecord', 'fetchBusinessRecords', ex);
	// 	}
	// 	return null;
	// }
}