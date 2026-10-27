/**
 *
 * @author  : MTX Group Product Team
 * @since   : 8 june 2023
 */
global with sharing class LPI_FetchPersonalInfoAddressType implements Callable {
	// ******************************** All Constant *******************************************
	public final static String CLASS_NAME = 'LPI_PersonalInfo';
	public final static String INVOKE_METHOD = 'InvokeMethod';
	public final static String RESIDENCE = 'Residence';
	public final static String MAILING = 'Mailing';
	public final static Map<String,String> addressApiNameMap = new Map<String,string>{
		'Residence' => 'residence address',
		'Mailing'=> 'mailing address',
		'Business Address'=> 'business address',
		'Branch'=> 'branch address',
		'Secondary Business Address'=> 'secondary business address',
		'Local Address'=> 'local address',
		'Other'=> 'other address'
		};
	public final static String PRIMARY_CONTACT_ADDRESS = 'Primary Contact Address';
	public final static String LICENSE_ADDRESS = 'License Address';
	public final static String PUBLICLY_DISPLAYED_ADDRESS ='Publicly Displayed Address';
	// *****************************************************************************************

	global Object call(String action, Map<String, Object> args) {
		Map<String, Object> input = (Map<String, Object>) args.get('input');
		Map<String, Object> output = (Map<String, Object>) args.get('output');
		Map<String, Object> options = (Map<String, Object>) args.get('options');
		return invokeMethod(action, input, output, options);
	}

	/**
	 * @author              : MTX Group Product Team
	 * @description         : This method will compare method from Omniscript and execute only that specific method
	 * @param methodName    : Method Name
	 * @param inputMap      : Input Fetching from OS
	 * @param outMap        : Output sending from apex to OS
	 * @param options       : Options Fetching from OS
	 * @return  `Boolean`
	 * @last modified by    : MTX Group Product Team
	 * @last modified date  :
	 * @modified details    :
	 */
	private Boolean invokeMethod(
		String methodName,
		Map<String, Object> inputMap,
		Map<String, Object> outMap,
		Map<String, Object> options
	) {
		try {
			if (methodName == 'fetchPrimaryContactAndLicenseAddress') {
				outMap.put('AddressTypeList', fetchPrimaryContactAndLicenseAddress(inputMap, outMap));
			}
		} catch (Exception e) {
			LPI_ExceptionManager.logException(CLASS_NAME, INVOKE_METHOD, e);
			throw new LPI_Exception('There is some problem in Fetching Details', e);
		}
		return true;
	}

	/**
	 * @author              : MTX Group Product Team
	 * @param inputMap      : Input value passed from OS
	 * @param outMap        : Output value passed from here to OS
	 * @description         : Saving SiteApprovalDetails in Account with recordType NON-MO and creating AccountContactRelation  -[S-43404] , [S-43400]
	 * @last modified by    : MTX Group Product Team
	 * @last modified date  :
	 * @modified details    :
	 */
	public static List<Map<String, Object>> fetchPrimaryContactAndLicenseAddress(
		Map<String, Object> inputMap,
		Map<String, Object> outMap
	) {
		Map<Id, Id> locationIds = new Map<Id, Id>();
		List<Schema.Location> updateLocationList = new List<Schema.Location>();
		String parId = (String) inputMap.get('parId');
		Boolean isSupervisorUser;
		String approvalSupervisorIds;
		List<PreliminaryApplicationRef> parList = LPI_PreliminaryApplicationRefDAO.getPreliminaryApplicationRefByDymanicQuery('Id ,Is_Supervisor_User__c,Approval_Supervisors_AcrIds__c,Primary_Contact_Address__c,License_Address__c,Publicly_Displayed_Address__c,Consent_for_Primary_Contact_Address__c,Board_Name__c,Regulatory_Authorization_Type__r.Name','Id = \'' + String.escapeSingleQuotes(parId) + '\'',null,null,null);
		if(!parList.isEmpty())
		{
			isSupervisorUser = parList[0].Is_Supervisor_User__c;
			approvalSupervisorIds = parList[0].Approval_Supervisors_AcrIds__c;
		}
		
		String fields = 'ID, Location__c,Location__r.LocationType';
		String whereClause = 'Preliminary_Application_Reference__c = \'' + String.escapeSingleQuotes(parId) + '\'';
		List<Temp_AuthApplicationPlace__c> temp_AAPList;

		if (isSupervisorUser && approvalSupervisorIds != null) {
			temp_AAPList = new LPI_TempAuthApplicationPlaceDAO.LPI_TempAuthApplicationPlaceWithoutSharingDAO()
				.getTempAuthApplicationPlaceByDymanicQuery(fields, whereClause, null, null, null);
		} else {
			temp_AAPList = [SELECT ID, Location__c,Location__r.LocationType FROM Temp_AuthApplicationPlace__c WHERE Preliminary_Application_Reference__c =: String.escapeSingleQuotes(parId)];
		}
				
		for (Temp_AuthApplicationPlace__c temp_AAP : temp_AAPList) {
			locationIds.put(temp_AAP.Location__c, temp_AAP.Id);
		}
		List<Map<String, Object>> result = new List<Map<String, Object>>();
		Map<String, Object> reviewResult = new Map<String, Object>();
		fields = 'ID,ParentId,Parent.LocationType,Parent.Name,StateCode,Business_State__c,CountryCode,City,County__c,PostalCode,State,Street,Country,Parent.Consent_For__c';
		whereClause = 'ParentId IN ' + LPI_ServiceUtility.getStringValuesBySet(locationIds.keySet());
		List<Schema.Address> addresses;
		if (isSupervisorUser && approvalSupervisorIds != null) {
			addresses = new LPI_AddressDAO.LPI_AddressDAOWithoutSharing()
				.getAddressByDymanicQuery(fields, whereClause, null, null, null);
		} else {
			
			addresses = LPI_AddressDAO.getAddressByDymanicQuery(fields, whereClause, null, null, null);
		}
		reviewResult.put('AddressTypePCA', parList[0].Primary_Contact_Address__c);
		reviewResult.put('AddressTypeLA', parList[0].License_Address__c);
		reviewResult.put('AddressTypePDA', parList[0].Publicly_Displayed_Address__c);
		if(parList[0].Primary_Contact_Address__c != RESIDENCE && parList[0].Primary_Contact_Address__c != MAILING && parList[0].Primary_Contact_Address__c != null)
		{
			reviewResult.put('AddressTypePCAcondition', true);
		}
		if(parList[0].License_Address__c != parList[0].Primary_Contact_Address__c && parList[0].License_Address__c != RESIDENCE && parList[0].License_Address__c != MAILING && parList[0].License_Address__c != null)
		{
			reviewResult.put('AddressTypeLAcondition', true);
		}
		if(parList[0].Publicly_Displayed_Address__c != parList[0].Primary_Contact_Address__c && parList[0].Publicly_Displayed_Address__c != parList[0].License_Address__c && parList[0].Publicly_Displayed_Address__c != RESIDENCE && parList[0].Publicly_Displayed_Address__c != MAILING && parList[0].Publicly_Displayed_Address__c != null)
		{
			reviewResult.put('AddressTypePDAcondition', true);
		}

		reviewResult.put('ConsentForPublicalyDisplayedAddress',parList[0].Consent_for_Primary_Contact_Address__c);
		reviewResult.put('ConsentDynamicvalue',addressApiNameMap.get(parList[0].Publicly_Displayed_Address__c));
		for (Schema.Address address : addresses) {
			if (
				(address.Parent.LocationType == 'Business Address' ||
				address.Parent.LocationType == 'Branch' ||
				address.Parent.LocationType == 'Secondary Business Address' ||
				address.Parent.LocationType == 'Local Address' ||
				address.Parent.LocationType == 'Other') 
			)
			{
			if(address.Parent.LocationType == parList[0].Primary_Contact_Address__c) 
			{
				reviewResult.put('ReviewPCACountry', address.Country);
				if (address.CountryCode == 'US') {
					reviewResult.put('PCAState', address.State);
				} else {
					reviewResult.put('PCAState', address.Business_State__c);
				}
				reviewResult.put('PCACity', address.City);
				reviewResult.put('PCAStreetAddress', address.Street);
				reviewResult.put('PCAZipCode', address.PostalCode);
				reviewResult.put('PCACounty', address.County__c);
				
			} else if (address.Parent.LocationType == parList[0].License_Address__c) {
				reviewResult.put('ReviewLaCountry', address.Country);
				if (address.CountryCode == 'US') {
					reviewResult.put('LAState', address.State);
				} else {
					reviewResult.put('LAState', address.Business_State__c);
				}
				reviewResult.put('LACity', address.City);
				reviewResult.put('LAStreetAddress', address.Street);
				reviewResult.put('LAZipCode', address.PostalCode);
				reviewResult.put('LACounty', address.County__c);
				
			}
			else if (address.Parent.LocationType ==  parList[0].Publicly_Displayed_Address__c) {
				reviewResult.put('ReviewPdaCountry', address.Country);
				if (address.CountryCode == 'US') {
					reviewResult.put('PDAState', address.State);
				} else {
					reviewResult.put('PDAState', address.Business_State__c);
				}
				reviewResult.put('PDACity', address.City);
				reviewResult.put('PDAStreetAddress', address.Street);
				reviewResult.put('PDAZipCode', address.PostalCode);
				reviewResult.put('PDACounty', address.County__c);
			}
		}
			reviewResult.put('BoardName',parList.isEmpty() ? null : parList[0].Board_Name__c);
			reviewResult.put('regAuthTypeName', parList[0].Regulatory_Authorization_Type__r.Name);
			result.add(reviewResult);
		}
		return result;
	}
}