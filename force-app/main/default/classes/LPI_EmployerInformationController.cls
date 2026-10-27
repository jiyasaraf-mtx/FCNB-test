/**
 * @author          : MTX Group Product Team
 * @description     : This class fetch and Save all the Details Related to Employer Information Section(S-45353)
 */
global with sharing class LPI_EmployerInformationController implements Callable {
	 
	public final static String CLASS_NAME = 'LPI_EmployerInformationController';
	public final static String FETCH_ENTITY_LICENSE_NUMBER = 'fetchEntityLicenseNumber';
	public final static String SAVE_EMPLOYER_INFORMATION = 'saveEmployerInformation';
	public final static String FETCH_EMPLOYER_INFORMATION = 'fetchEmployerInformation';
	public final static String FETCH_EMPLOYER_INFORMATION_REVIEW = 'fetchEmployerInformationForReview';
	public final static String DELETE_EMPLOYER_INFORMATION = 'deleteEmployerInformation';
	private final static String UNITED_STATES = 'United States';

	/**
	 * @author                      : MTX Group Product Team
	 * @since                       : 02 Feb 2023
	 * @description                 : This method calls invoke method
	 * @param action                : String
	 * @param args			        : Map<String, Object>
	 * @return                      : Object
	 * @last modified by            : MTX Group Product Team
	 * @last modified date          :
	 * @modified details            :
	 */
	global Object call(String action, Map<String, Object> args) {
		Map<String, Object> input = (Map<String, Object>) args.get('input');
		Map<String, Object> output = (Map<String, Object>) args.get('output');
		Map<String, Object> options = (Map<String, Object>) args.get('options');
		return invokeMethod(action, input, output, options);
	}
	/**
	 * @author               : MTX Group Product Team
	 * @param methodName     : invokeMethod
	 * @param inputMap       : Input Parameter Passed from Omniscript
	 * @param outMap         : Output Passed to Omniscript
	 * @param options        : Extra Options passed from Omniscript
	 * @created date		 : 2 Feb, 2023
	 * @last modified by     : MTX Group Product Team
	 * @last modified date   :
	 * @modified details     :
	 * @return  `Boolean`
	 */
	private Boolean invokeMethod(
		String methodName,
		Map<String, Object> inputMap,
		Map<String, Object> outMap,
		Map<String, Object> options
	) {
		try {
			if (methodName.equals(FETCH_ENTITY_LICENSE_NUMBER)) {
				outMap.put('licenseRecords', fetchEmployerDetails(inputMap, options));
			}
			return true;
		} catch (Exception exp) {
			LPI_ExceptionManager.logException(CLASS_NAME, 'invokeMethod', exp);
			return false;
		}
	}
	/**
	 * @author                      : MTX Group Product Team
	 * @since                       : 07 Feb 2023
	 * @description                 : This method will fetch the Business Account details based on entity license number
	 * @param inputMap			   	: Map<String, Object>
	 * @return                      : `List<Map<String,String>>`
	 * @last modified by            : MTX Group Product Team
	 * @last modified date          :
	 * @modified details            :
	 */
	public static List<Map<String, object>> fetchEmployerDetails(
		Map<String, Object> inputMap,
		Map<String, Object> options
	) {
		List<Map<String, Object>> licenseList = new List<Map<String, Object>>();
		try {
			String entityLicenseNumber = '%' + (String) inputMap.get('SalesPersonLicenseNumber') + '%';
			String boardName = (String) options.get('boardName');
			Boolean forPreneedRat = (Boolean) options.get('forPreneed');
			String licenseEntityName = (String) inputMap.get('SalesPersonLicenseNumber');
			String blWhereClauseFields;
			String blQueryFields = 'Id,AccountId,Name,Account.BillingStateCode,Account.Name,Account.BillingStreet,Business_Entity_Name__c ,'+
			'Account.BillingCity,Account.BillingState,Account.BillingPostalCode,License_Number_With_Rat_Name__c,Account.Other_State__c,Account.BillingCountry';
			if(forPreneedRat)
			{
                String licenseType = (String) options.get('licenseType');
				blWhereClauseFields =
				'(Name LIKE \'' +
				String.escapeSingleQuotes(entityLicenseNumber) +
				'\' OR Business_Entity_Name__c LIKE \'' +
				String.escapeSingleQuotes(entityLicenseNumber) +
				'\')' +
				' AND RegulatoryAuthorizationType.Name = \'' +
				licenseType +
				'\'';
			}
			else {
				blWhereClauseFields =
				'Name LIKE \'' +
				String.escapeSingleQuotes(entityLicenseNumber) +
				'\'' +
				' AND RegulatoryAuthorizationType.IssuingDepartment.Name = \'' +
				boardName +
				'\'';
			}
			blWhereClauseFields +=
				' AND Account.RecordType.DeveloperName=\'' +
				LPI_LiteralConstant.ACCOUNT_BUSINESS_RECORDTYPE +
				'\' AND RegulatoryAuthorizationType.Authorisation_Type__c=\'' +
				LPI_LiteralConstant.ACCOUNT_BUSINESS_RECORDTYPE +
				'\'';
			LPI_BusinessLicenseDAO.LPI_BusinessLicenseWithoutSharingDAO bLListWithOutSharing = new LPI_BusinessLicenseDAO.LPI_BusinessLicenseWithoutSharingDAO();  
			for (
				BusinessLicense blList : bLListWithOutSharing.getBusinessLicenseByDymanicQuery(
					blQueryFields,
					blWhereClauseFields,
					null,
					null,
					null
				)
			) {
				Map<String, Object> licenseMap = new Map<String, Object>();
				licenseMap.put('licenseId', blList.Id);
				licenseMap.put('Name', blList.Name);
				if(forPreneedRat)
				{
					if(blList.License_Number_With_Rat_Name__c.contains(licenseEntityName))
					{
						licenseMap.put('TypeAheadKeyName', blList.License_Number_With_Rat_Name__c);
					} 
					if(String.isNotBlank(blList.Business_Entity_Name__c) && blList.Business_Entity_Name__c.contains(licenseEntityName)){
						licenseMap.put('TypeAheadKeyName', blList.Business_Entity_Name__c);
					}
				} else{
					licenseMap.put('TypeAheadKeyName', blList.License_Number_With_Rat_Name__c);
				}
				licenseMap.put('TypeAheadKeyName1', blList.License_Number_With_Rat_Name__c);
				licenseMap.put('SalesPersonNameOfCorporation', blList.Business_Entity_Name__c);
				licenseMap.put('SalesPersonStreetAddress', blList.Account.BillingStreet);
				licenseMap.put('SalesPersonCity', blList.Account.BillingCity);
				if (blList.Account.BillingCountry == UNITED_STATES) {
					licenseMap.put('SalesPersonState', blList.Account.BillingState);
				} else {
					licenseMap.put('SalesPersonState', blList.Account.Other_State__c);
				}
				licenseMap.put('SalesPersonStateCode', blList.Account.BillingStateCode);
				licenseMap.put('SalesPersonZipcode', blList.Account.BillingPostalCode);
				licenseMap.put('RFBusinessAccountId', blList.AccountId);
				licenseMap.put('BusinessAccountId', blList.AccountId);
				licenseMap.put('BusinessLicenseId', blList.Id);
				licenseMap.put('BLName', blList.Name);
				licenseList.add(licenseMap);
			}
		} catch (Exception e) {
			LPI_ExceptionManager.logException(CLASS_NAME, FETCH_ENTITY_LICENSE_NUMBER, e);
		}
		return licenseList;
	}
	
}