/**
 *
 * @author              : MTX Group Product Team
 * @description         : This class is used to fetch details for pharmacy license and return it to the OS
 * @last modified by    : MTX Group Product Team
 * @last modified date  : 3-02-2023
 */
global with sharing class LPI_FetchDetailsForPharmacy implements Callable {
	 
	public final static String CLASS_NAME = 'LPI_FetchDetailsForPharmacy';
	public final static String GET_VIEW_CONTACT_PERSON = 'getViewContactPerson';
	public final static String GET_VIEW_APPLICATION_QUESTIONS = 'getViewApplicationQuestions';
	public final static String FETCH_FACILITY_LICENSE_NUMBER = 'fetchFacilityLicenseNumber';
	public final static String FETCH_LICENSE_DETAILS = 'fetchLicenseDetails';
	private final static String UNITED_STATES = 'United States';
	 

	global Object call(String action, Map<String, Object> args) {
		Map<String, Object> input = (Map<String, Object>) args.get('input');
		Map<String, Object> output = (Map<String, Object>) args.get('output');
		Map<String, Object> options = (Map<String, Object>) args.get('options');
		return invokeMethod(action, input, output, options);
	}

	/**
	 * @author             : MTX Group Product Team
	 * @description        : This method will compare method from Omniscript and execute only that specific method
	 * @last modified by   : MTX Group Product Team
	 * @last modified date : 3-02-2023
	 * @return  `Boolean`
	 */

	private Boolean invokeMethod(
		String methodName,
		Map<String, Object> inputMap,
		Map<String, Object> outMap,
		Map<String, Object> options
	) {
		Boolean result = true;
		try {
			 
			if (methodName == GET_VIEW_APPLICATION_QUESTIONS) {
				outMap.put('questions', getViewApplicationQuestions(inputMap));
			} 
			 
			else if (methodName == FETCH_LICENSE_DETAILS) {
				fetchLicenseDetails(options, outMap);
			} 
			 
		} catch (Exception e) {
			LPI_ExceptionManager.logException(CLASS_NAME, 'invokeMethod', e);
		}
		return result;
	}

	

	/**
	 * @author 				 : MTX Group Product Team
	 * @description          : method is used to Fetch details for pharmacy License Question on the basis of Classification field (par.classification__c)
	 * @return 				 : Map<String, String>
	 * @last modified by     : MTX Group Product Team
	 * @last modified date   : 30 Jan 2023
	 * @modified details     : Shifting Query to DAO CLass
	 */
	public static Map<String, Object> getViewApplicationQuestions(Map<String, Object> inputMap) {
		Map<String, Object> questionDetails = new Map<String, Object>();
		try {
			Id recoId = (String) inputMap.get('parid');
			boolean displayOnlyClassQ = false;
			boolean displayOnlyClassR = false;
			String parFields = 'Id, License_Questions__c, Amendment_Type__c, Regulatory_Authorization_Type__r.Name';
			String parWhereClause = 'Id = \'' + String.escapeSingleQuotes(recoId) + '\'';
			List<PreliminaryApplicationRef> parList = LPI_PreliminaryApplicationRefDAO.getPreliminaryApplicationRefByDymanicQuery(
				parFields,
				parWhereClause,
				null,
				null,
				null
			);
			if (!parList.isEmpty()) {
				questionDetails.put('amendmentType', parList[0].Amendment_Type__c);
				questionDetails.put('licenseType', parList[0].Regulatory_Authorization_Type__r.Name);
			}
			if (!parList.isEmpty()) {
				Map<String, Object> deserializedLicenseQuestions;
				if (!String.isBlank((String) parList[0].get('License_Questions__c'))) {
					deserializedLicenseQuestions = (Map<String, Object>) JSON.deserializeUntyped(
						String.valueOf(parList[0].get('License_Questions__c'))
					);
					for (String values : deserializedLicenseQuestions.keySet()) {
						questionDetails.put(
							values,
							deserializedLicenseQuestions.get(values) != null
								? String.valueOf(deserializedLicenseQuestions.get(values))
								: null
						);
						if (values == 'EmbalmersApplicationLicenseQuestionsContainer') {
							Object questionValue = ((Map<String, Object>)deserializedLicenseQuestions.get('EmbalmersApplicationLicenseQuestionsContainer'))
															.get('EFDEmbalmersApplicationLicenseQuestionsHasYourLicenseEverBeenDisciplined');
							questionDetails.put('EmbalmersApplicationLicenseQuestionsContainer',new Map<String,String>{
								'EFDEmbalmersApplicationLicenseQuestionsHasYourLicenseEverBeenDisciplined' => questionValue != null ? String.valueOf(questionValue) : null
							});
						}
					}
				}
			}
			if (!parList.isEmpty()) {
				 
				questionDetails.put('displayOnlyClassQ', displayOnlyClassQ);
				questionDetails.put('displayOnlyClassR', displayOnlyClassR);
			}
		} catch (Exception e) {
			LPI_ExceptionManager.logException(CLASS_NAME, GET_VIEW_APPLICATION_QUESTIONS, e);
		}
		return questionDetails;
	}

	 
	/**
	 * @author              : MTX Group Product Team
	 * @param inputMap      : Input value passed from OS
	 * @param outMap        : Output value passed from here to OS
	 * @description 		   : This method is used to fetch Intern Information
	 * @last modified by    : MTX Group Product Team
	 * @last modified date  : 03 Feb 2023
	 * @modified details    : Shifting Query to DAO CLass and implemented Exception Log
	 * @return  `List<Map<String, Object>>`
	 */
	public static List<Map<String, Object>> fetchLicenseDetails(
		Map<String, Object> inputMap,
		Map<String, Object> outMap
	) {
		try {
			List<Map<String, Object>> responseData = new List<Map<String, Object>>();
			String searchKey = '%' + (String) inputMap.get('InternLicenseNumber') + '%';
			String parQueryString = 'id,name,License_Number_With_Rat_Name__c,first_name__c,middle_name__c,last_name__c,regulatoryauthorizationtype.authorisation_type__c,account.recordtype.developername';
			String parWhereClause =
				'Name LIKE \'' +
				String.escapeSingleQuotes(searchKey) +
				'\'' +
				' AND Account.RecordType.DeveloperName =\'' +
				LPI_LiteralConstant.ACCOUNT_PERSON_RECORDTYPE +
				'\'' +
				' AND RegulatoryAuthorizationType.Authorisation_Type__c =\'' +
				LPI_LiteralConstant.CONTACT_INDIVIDUAL_RECORDTYPE +
				'\'';
			for (
				BusinessLicense bl : LPI_BusinessLicenseDAO.fetchBusinessLicenseRecords(
					parQueryString,
					parWhereClause
				)
			) {
				Map<String, Object> blData = new Map<String, Object>();
				String MiddleName = String.isNotBlank(bl.Middle_Name__c) ? bl.Middle_Name__c + ' ' : '';
				String FirstName = String.isNotBlank(bl.First_name__c) ? bl.First_name__c + ' ' : '';
				String LastName = String.isNotBlank(bl.Last_Name__c) ? bl.Last_Name__c : '';
				blData.put('PHInternFullName', FirstName + MiddleName + LastName);
				blData.put('PHBIId', bl.Id);
				blData.put('Name', bl.Name);
				blData.put('InternLNWithRAT', bl.License_Number_With_Rat_Name__c);
				responseData.add(blData);
			}
			outMap.put('responseData', responseData);
			return responseData;
		} catch (Exception ex) {
			LPI_ExceptionManager.logException('LPI_FetchDetailsForPharmacy', 'fetchLicenseDetails', ex);
		}
		return null;
	}

	 
}