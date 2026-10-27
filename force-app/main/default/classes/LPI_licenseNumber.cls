/**
 *
 * @author              : MTX Group Product Team
 * @description         : This class will fetch license Number
 * @lastModifiedBy      : MTX Group Product Team
 * @lastModifiedDate    : January 22, 2023
 */
global with sharing class LPI_licenseNumber implements Callable {
    private static final String APEP_BOARD_BUSINESS_REINSTATEMENT = 'Re-authorization';
    private static final String APEP_BOARD_INDIVIDUAL_REINSTATEMENT = 'Re-licensure';
	private static final String REINSTATEMENT_APPLICATIONTYPE = 'Reinstatement';
	private static final String AUTHORISATION_TYPE_BUSINESS = 'Business';

	global Object call(String action, Map<String, Object> args) {
		Map<String, Object> input = (Map<String, Object>) args.get('input');
		Map<String, Object> output = (Map<String, Object>) args.get('output');
		Map<String, Object> options = (Map<String, Object>) args.get('options');
		return invokeMethod(action, input, output, options);
	}

	/**
	 * @author             : MTX Group Product Team
	 * @param methodName   : method name
	 * @param inputMap     : input data from flexcard
	 * @param outMap       : Output data for flexcard
	 * @param options      : Options data for flexcard
	 * @return  `Boolean`
	 */
	private static Boolean invokeMethod(String methodName,Map<String, Object> inputMap,
		Map<String, Object> outMap,Map<String, Object> options) {
			if (methodName == 'getLicenseNumber') {
				getLicenseNumber(inputMap, outMap);
			}
			return true;
        }

	/**
	 * @author              : MTX Group Product Team
	 * @param inputMap      : input data from flexcard
	 * @param outMap        : Output data for flexcard
	 * @lastModifiedBy      : Kriti Gupta
	 * @lastModifiedDate    : October 15, 2023
	 */
	public static void getLicenseNumber(Map<String, Object> inputMap, Map<String, Object> outMap) {
		System.debug('=== [LPI_DEBUG] LPI_licenseNumber.getLicenseNumber Started ===');
   		System.debug('=== [LPI_DEBUG] inputMap: ' + JSON.serialize(inputMap));
		String blId;
		if ((String) inputMap.get('c__parid') != null && (String) inputMap.get('c__parid') != '{Params.c__parid}') {
			System.debug('=== [LPI_DEBUG] Processing via parId:');
			String parId = (String) inputMap.get('c__parid');
			String fieldToQuery = 'Id, Business_License__r.Name,Business_License__r.Legacy_License_Number__c,toLabel(Amendment_Type__c),' +
			'Regulatory_Authorization_Type__r.IssuingDepartment.Name,Type__c,Regulatory_Authorization_Type__r.Authorisation_Type__c,Regulatory_Authorization_Type__r.Name';
			List<PreliminaryApplicationRef> parList = new List<PreliminaryApplicationRef>();
			LPI_PreliminaryApplicationRefDAO.LPI_PreliminaryApplicationRefWithoutSharingDAO withoutshare = new LPI_PreliminaryApplicationRefDAO.LPI_PreliminaryApplicationRefWithoutSharingDAO();
			parList = withoutshare.getPreliminaryApplicationRefByDymanicQuery(
															fieldToQuery,
                                                            'Id = \'' + String.escapeSingleQuotes(parId) + '\'',
															'1',
															null,null);
			if(!parList.isEmpty()){
				if(parList[0].Business_License__r.Legacy_License_Number__c!=null){
					outMap.put('licenseNumber', parList[0].Business_License__r.Legacy_License_Number__c);
				}else{
					outMap.put('licenseNumber', parList[0].Business_License__r.Name);
				}

				String subTypeToShow =  LPI_ServiceUtility.getSubtypeLabelToShow(
						parList[0].Regulatory_Authorization_Type__r.IssuingDepartment.Name,
						parList[0].Regulatory_Authorization_Type__r.Name,
						parList[0].Amendment_Type__c,
						parList[0].Type__c						
					);
				outMap.put('appSubType', subTypeToShow);
				outMap.put('appType', parList[0].Type__c);
				outMap.put('showType',(parList[0].Type__c == APEP_BOARD_BUSINESS_REINSTATEMENT || parList[0].Type__c == APEP_BOARD_INDIVIDUAL_REINSTATEMENT) ? true : false);
                System.debug('=== [LPI_DEBUG] Output Map populated via PAR: ' + JSON.serialize(outMap));			
			}															
		} else if ((String) inputMap.get('blId') != null) {
			blId = (String) inputMap.get('blId');
		} else if ((String) inputMap.get('c__blId') != null && (String) inputMap.get('c__blId') != '{Params.c__blId}') {
			blId = (String) inputMap.get('c__blId');
		}
		System.debug('=== [LPI_DEBUG] Resolved blId: ' + blId);
		if(blId!=null){
			list<BusinessLicense> blList = LPI_BusinessLicenseDAO.fetchBusinessLicenseRecordsWithOrderByLimit(
					'Id, Name, Legacy_License_Number__c',
					'Id =\'' + String.escapeSingleQuotes(blId) + '\'',
					'1',
					null);
			if(!blList.isEmpty()){
				if(blList[0].Legacy_License_Number__c!=null){
					outMap.put('licenseNumber', blList[0].Legacy_License_Number__c);
				}else{
					outMap.put('licenseNumber', blList[0].Name);
				}
				System.debug('=== [LPI_DEBUG] Output Map populated via BusinessLicense: ' + JSON.serialize(outMap));
			}else{
				System.debug('=== [LPI_DEBUG] No BusinessLicense record found for blId: ' + blId);
			}
		}
	}

	@AuraEnabled(cacheable=true)
    public static Map<String, Object> getLicenseNumberAndSubType(Map<String, Object> inputMap) {
        Map<String, Object> outMap = new Map<String, Object>();
        getLicenseNumber(inputMap, outMap);
        return outMap;
    }
}