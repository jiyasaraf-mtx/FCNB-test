/**
 * @author      : MTX Group Product Team
 * @description : This class will save mailing address and Residence Address in Location and Address Object
 */
global with sharing class LPI_SaveAddressDetails implements Callable {
	
	private final static String SAVE_RESIDENCE_ADDRESS_FOR_AMENDMENT = 'saveResidenceAddressForAmendment';
	private final static String CLASS_NAME = 'LPI_SaveAddressDetails';
	private final static String COUNTRY_US = 'US';
	
	private final static String COUNTY = 'CountyEdit';
	private final static String STREET_ADDRESS = 'StreetAddressEdit';
	private final static String CITY = 'CityEdit';
	private final static String STATE = 'StateEdit';
	private final static String ZIP_CODE = 'ZipcodeEdit';
	private final static String COUNTRY = 'CountryEdit';
	private final static String STATE_TEXT = 'StateTextEdit';
	private final static String PAR_NOT_FOUND = 'PAR record is not created for the flow';
    private final static String PAR_STATUS_DRAFT = 'Draft';
    private final static String PAR_STATUS_CONVERTED = 'Converted';
	private final static String ANOTHER_NAME = 'AnotherName';
	private final static String LIST_OF_ANOTHER_NAMES = 'ListOfAnotherNames';
	private static final String PAR_ID = 'parid';
	private static final String PERSONAL_INFO_NAME_AMENDMENT = 'PersonalInformationNameAmendment';
	private static final String LOCATION_TYPE_RESIDENCE = 'Residence';
	private final static String LOCATION_STATUS_CLOSED = 'Closed';
	private static final String MAILING_ADDRESS_DETAILS_AMENDMENT_STEP='MailingAddressDetails';
	private static final String NEW_MAILING_ADDRESS_BLOCK='NewMailingAddress';
	private static final String CHECK_ADDRESS_VALIDATION='checkAddressValidationForAmendment';
	

	global Object call(String action, Map<String, Object> args) {
		Map<String, Object> input = (Map<String, Object>) args.get('input');
		Map<String, Object> output = (Map<String, Object>) args.get('output');
		Map<String, Object> options = (Map<String, Object>) args.get('options');
		return invokeMethod(action, input, output, options);
	}

	/**
	 * @author               : MTX Group Product Team
	 * @param methodName     : Method Name
	 * @param inputMap       : Input Parameter Passed from Omniscript
	 * @param outMap         : Output Passed to Omniscript
	 * @param options        : Extra Options passed from Omniscript
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
		if (methodName == SAVE_RESIDENCE_ADDRESS_FOR_AMENDMENT) {
			saveResidenceAddressForAmendment(inputMap, outMap);
		}
		else if (methodName == CHECK_ADDRESS_VALIDATION) {
			checkAddressValidationForAmendment(inputMap, outMap);
		}
		return true;
	}


	/**
	 * @author               : MTX Group Product Team
	 * @description 		 : This method is use to save new admendment Residence Address
	 * @param inputMap       : Input Parameter Passed from Omniscript
	 * @param outMap         : Output Passed to Omniscript
	 * @last modified by     : MTX Group Product Team
	 * @last modified date   :
	 * @modified details     :
	 * @return  `Boolean`
	 */
	private static void saveResidenceAddressForAmendment(Map<String, Object> inputMap, Map<String, Object> outMap) {
		try {
			Id parId = (Id) inputMap.get(PAR_ID);
			if (String.isNotBlank(parId) && inputMap.containsKey(PERSONAL_INFO_NAME_AMENDMENT)){
				LPI_PreliminaryApplicationRefDAO.LPI_PreliminaryApplicationRefWithoutSharingDAO parDao = 
				new LPI_PreliminaryApplicationRefDAO.LPI_PreliminaryApplicationRefWithoutSharingDAO();
				String fieldToQuery = 'Id, BusinessAccountName.Name, Business_License__c';
				String whereClause = 'Id = \'' + String.escapeSingleQuotes(parId) + '\'';
				List<PreliminaryApplicationRef> parList = parDao.getPreliminaryApplicationRefByDymanicQuery(
					fieldToQuery,
					whereClause,
					'1',
					null,
					null
				);
				Map<String, object> personalInformation = (Map<String, object>) inputMap.get(PERSONAL_INFO_NAME_AMENDMENT);
				Map<String, object> residenceAddressEditOnlyBlock = (Map<String, object>) personalInformation?.get('ResidenceAddressEditOnlyBlock');				
				Map<String, object> IndResCountyCityZipLwc = (Map<String, object>) residenceAddressEditOnlyBlock?.get('IndResCountyCityZipLwc');
				if(!parList.isEmpty() && String.isNotBlank(parList[0].BusinessAccountName.Name) && 
					String.isNotBlank(parList[0].Business_License__c) && !personalInformation.isEmpty()){
						String blId = parList[0].Business_License__c;
						Set<Id> locIdSet = new Set<Id>();
						String individualLocationId;
						String tempAuthApplicationPlaceId;
						String placeId;
						List<Schema.Address> addresseList = new List<Schema.Address>();
						List<SObject> upsertSobjList = new List<SObject>();
						 
						String County = (String) IndResCountyCityZipLwc.get(COUNTY);
						String City = (String) IndResCountyCityZipLwc.get(CITY);
						String ZipCode = (String) IndResCountyCityZipLwc.get(ZIP_CODE);
						String State = (String) IndResCountyCityZipLwc.get(STATE);
						String Street = (String) IndResCountyCityZipLwc.get(STREET_ADDRESS);
						String country = (String) IndResCountyCityZipLwc.get(COUNTRY);
						String stateText = (String) IndResCountyCityZipLwc.get(STATE_TEXT);
						String anotherName = (String) personalInformation.get(ANOTHER_NAME);
						String otherName  = (String) personalInformation.get(LIST_OF_ANOTHER_NAMES);

						 
						Map<String, object> primaryStateOfResidenceBlock = (Map<String, object>) personalInformation.get('PrimaryStateOfResidenceBlock');
						
						 
						parList[0].Other_Names__c = otherName;
						upsertSobjList.add(parList[0]);	
						 
						fieldToQuery = 'ID,Location__c, Location__r.LocationType';
						whereClause = 'Preliminary_Application_Reference__c = \'' +
								String.escapeSingleQuotes(parId) +
								'\' AND Location__r.LocationType =\'' +
								LOCATION_TYPE_RESIDENCE +
								'\'';
						
						List<Temp_AuthApplicationPlace__c> tempAuthList = LPI_TempAuthApplicationPlaceDAO.getTempAuthApplicationPlaceByDymanicQuery(
							fieldToQuery,
							whereClause,
							'1',
							null,
							null
						);
						
						if(!tempAuthList.isEmpty() && String.isNotBlank(tempAuthList[0].Location__c)){
							placeId = tempAuthList[0].Location__c;
							tempAuthApplicationPlaceId = tempAuthList[0].Id;

							String addressQueryFields = 'ID, ParentId, Parent.LocationType, Street,'+
							 'CountryCode, City,PostalCode,StateCode, Business_State__c,County__c  ';
							String addressWhereClause = 'ParentId = \'' + placeId + '\'';
							addresseList = (new LPI_AddressDAO.LPI_AddressDAOWithoutSharing())
							.getAddressByDymanicQuery(addressQueryFields, addressWhereClause, '1', null, null);

							 
							if(!addresseList.isEmpty() && 
							addresseList[0].Street == Street && 
							addresseList[0].CountryCode == country &&
							addresseList[0].City == City &&
							addresseList[0].PostalCode == ZipCode &&
							addresseList[0].County__c == County &&
							((country == COUNTRY_US && addresseList[0].StateCode == State) ||
							(country != COUNTRY_US && addresseList[0].Business_State__c == stateText))
							){
								return;
							}
						}
						fieldToQuery = 'Id, PlaceId';
						whereClause = ' AuthorizationId IN ' +
						LPI_ServiceUtility.getStringValuesBySet(new Set<Id>{ blId });

						LPI_AuthApplicationPlaceDAO.LPI_AuthApplicationPlaceWithoutSharingDAO aapDAO = new LPI_AuthApplicationPlaceDAO.LPI_AuthApplicationPlaceWithoutSharingDAO();
						for (
							AuthApplicationPlace authPlace : aapDAO.getAuthApplicationPlaceByDymanicQuery(
								fieldToQuery,
								whereClause,
								null,
								null,
								null
							)
						) {
							locIdSet.add(authPlace.PlaceId);
						}

						Schema.Address address = new Schema.Address();
						 
						if(tempAuthList.isEmpty() || 
							(!tempAuthList.isEmpty() && 
							String.isNotBlank(placeId) &&
							locIdSet.contains(placeId))
						){

							
							 
							Schema.Location loc = new Schema.Location();
							loc.Name = parList[0].BusinessAccountName.Name + '-Residence';
							loc.LocationType = LOCATION_TYPE_RESIDENCE;
							loc.Status__c = LOCATION_STATUS_CLOSED;
							loc = ((Schema.Location) LPI_DML.doInsert(loc));
							address.ParentId = loc.id;
							individualLocationId = loc.id;
						}else if(String.isNotBlank(placeId)){
							 
							if(!addresseList.isEmpty()){
								address.Id = addresseList[0].Id;
							}
							individualLocationId = placeId;
						}
						if(String.isNotBlank(individualLocationId)){
							address.Street = Street;
							address.CountryCode = country;
							address.City = City;
							address.PostalCode = ZipCode;
							address.LocationType = LOCATION_TYPE_RESIDENCE;
							if (country == COUNTRY_US) {
								address.StateCode = State;
								address.Business_State__c = null;
							} else {
								address.Business_State__c = stateText;
								address.StateCode = null;
							}
							address.County__c = County;
							 
							LPI_WithoutSharingUtility.upsertSObjectList(new List<Schema.Address>{ address });

							Temp_AuthApplicationPlace__c aap = new Temp_AuthApplicationPlace__c();
							aap.Location__c = individualLocationId;
							aap.Preliminary_Application_Reference__c = parId;
							if (String.isNotBlank(tempAuthApplicationPlaceId)) {
								aap.Id = tempAuthApplicationPlaceId;
							}
							upsertSobjList.add(aap);  
						}
						if(!upsertSobjList.isEmpty()){
							LPI_DML.doUpsert(upsertSobjList);
						}  
					}
				}
		} catch (Exception ex) {
			LPI_ExceptionManager.logException('LPI_SaveAddressDetails', SAVE_RESIDENCE_ADDRESS_FOR_AMENDMENT, ex);
		}
	}


	

	/**
	 * @author               : MTX Group Product Team
	 * @description 		 : This method is used for address validation using google api for amendment
	 * @param inputMap       : Input Parameter Passed from Omniscript
	 * @param outMap         : Output Passed to Omniscript
	 * Since                 : 12 Oct 2023
	 * @last modified by     : MTX Group Product Team
	 * @last modified date   :
	 */
	public static void checkAddressValidationForAmendment(Map<String, Object> inputMap, Map<String, Object> outMap){
		try{
			LPI_GoogleIntegration.AddressValidationResultWrapper resultWrap = new LPI_GoogleIntegration.AddressValidationResultWrapper();
			Map<String, object> personalInformation = (Map<String, object>) inputMap.get(PERSONAL_INFO_NAME_AMENDMENT);
			Map<String, object> residenceAddressEditOnlyBlock = (Map<String, object>) personalInformation?.get('ResidenceAddressEditOnlyBlock');				
			Map<String, object> personalInformationAmendmentInfo = (Map<String, object>) residenceAddressEditOnlyBlock?.get('IndResCountyCityZipLwc');
			Map<String, object> mailingAddressAmendmentInfo = (Map<String, object>) inputMap.get(MAILING_ADDRESS_DETAILS_AMENDMENT_STEP);
			Map<String, object> newMailingAddressBlockInfo = new  Map<String, Object>();
			Map<String, object>  newMailingAddressBlock = new Map<String, Object>();
			Map<String, object>  newMailingAddressStepBlock = new Map<String, Object>();
			if(mailingAddressAmendmentInfo != null){
				newMailingAddressBlockInfo = (Map<String, object>) mailingAddressAmendmentInfo.get('NewMailingAddress');
				newMailingAddressBlock = (Map<String, object>) mailingAddressAmendmentInfo?.get(NEW_MAILING_ADDRESS_BLOCK);
				newMailingAddressStepBlock = (Map<String, object>) newMailingAddressBlock?.get('IndMailingCountyCityZipLwc');
			}
			outMap.put('ErrorInAddress', false);
			outMap.put('AddressErrorMessage', '');
			outMap.put('ErrorInMailingAddress', false);
			outMap.put('MailingAddressErrorMessage', '');
			if (personalInformationAmendmentInfo != null) {
				resultWrap = LPI_GoogleIntegration.checkAddressValidation(
					(String) personalInformationAmendmentInfo.get(COUNTRY),
					(String) personalInformationAmendmentInfo.get(CITY),
					new List<String>{
						(String) personalInformationAmendmentInfo.get(STREET_ADDRESS) + ',' +
						(String) personalInformationAmendmentInfo.get(CITY) + ',' +
						(String) personalInformationAmendmentInfo.get(COUNTRY) + ',' +
						(String) personalInformationAmendmentInfo.get(ZIP_CODE), 
						(String) personalInformationAmendmentInfo.get(ZIP_CODE)
					}
				);
				 
				if(resultWrap.addressValid || resultWrap.skipValidation) {
					outMap.put('ResidenceLong', resultWrap.longitude);
					outMap.put('ResidenceLat', resultWrap.latitude);
				} else {
					outMap.put('ErrorInAddress', true);
					outMap.put('AddressErrorMessage', 'Residence Address Validation Failed. Please Provide a Correct Address.');
				}
			}
			if (newMailingAddressStepBlock != null) {
				resultWrap = LPI_GoogleIntegration.checkAddressValidation(
					(String) newMailingAddressStepBlock.get('MailingCountryNew'),
					(String) newMailingAddressStepBlock.get('MailingCityNew'),
					new List<String>{
						(String) newMailingAddressStepBlock.get('MailingStreetNew') + ',' +
						(String) newMailingAddressStepBlock.get('MailingCityNew') + ',' +
						(String) newMailingAddressStepBlock.get('MailingCountryNew') + ',' +
						(String) newMailingAddressStepBlock.get('MailingZipCodeNew'), 
						(String) newMailingAddressStepBlock.get('MailingZipCodeNew')
					}
				);
				 
				if(resultWrap.addressValid || resultWrap.skipValidation) {
					outMap.put('MailingLong', resultWrap.longitude);
					outMap.put('MailingLat', resultWrap.latitude);
				} else {
					outMap.put('ErrorInMailingAddress', true);
					outMap.put('MailingAddressErrorMessage', 'Mailing Address Validation Failed. Please Provide a Correct Address.');
				}
			}
		} catch(Exception ex){
			LPI_ExceptionManager.logException('LPI_SaveAddressDetails', 'checkAddressValidationForAmendment', ex);
		}
	}
}