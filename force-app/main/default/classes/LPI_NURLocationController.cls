/**
 * @author          : Pranaya Etta
 * @description     : This class is responsible for managing the practice locations of dental services.It has methods to upsert, fetch and delete practice locations.
 * * @history
 * -------------------------------------------------------------------------------------------------------
 * Version      Date                Author                  Details
 *    1         14 Mar, 2023        	Pranaya Etta     		Initial Developement
 * -------------------------------------------------------------------------------------------------------
 */
global with sharing class LPI_NURLocationController implements Callable {
	// private static final String SAVE_SPONSORING_LOCATION_DETAILS = 'saveSponsoringLocationsInformation';
	// private static final String FETCH_SPONSORING_LOCATION_DETAILS = 'fetchSponsoringInformation';
	// // private static final String SAVE_PRIMARY_PROGRAM_LOCATION_DETAILS = 'savePrimaryProgramInformation';
    // // private static final String SAVE_RS_PRIMARY_PROGRAM_LOCATION_DETAILS = 'saveRSPrimaryProgramInformation';
	// // private static final String FETCH_PRIMARY_PROGRAM_LOCATION_DETAILS = 'fetchPrimaryProgramInformation';
	// // private static final String UPSERT_SATELLITE_LOCATION_DETAILS = 'upsertSatelliteLocationsInformation';
	// // private static final String FETCH_SATELLITE_LOCATION_DETAILS = 'fetchSatelliteInformation';
	// // private static final String DELETE_SATELLITE_LOCATION_DETAILS = 'deleteSatelliteInformation';
	// // private static final String DELETE_ALL_SATELLITE_LOCATIONS = 'deleteSatelliteInformationNO';
	// //private static final String SATELLITE_LOCATION = 'Satellite Program Location';
	// private static final String SPONSORING_LOCATION = 'Sponsoring Institute Location';
	// private static final String PROGRAM_LOCATION = 'Primary Program Location';
	// private static final String BUSINESS_ADDRESS = 'Business Address';
	// private static final String CANNOT_ADD_DUPLICATE_ADDRESS = 'Address already exists';
    // private static final String CANNOT_DELETE_EXISTING_ADDRESS = 'Cannot delete existing address';
	// private static final String CLASS_NAME = 'LPI_NURLocationController';
	// private static final String SPONSOR_NAME_RO = 'SponsorNameRO';
	// private static final String SPONSOR_STREET_RO = 'SponsorStreetAddressRO';
	// private static final String SPONSOR_CITY_RO = 'SponsorCityRO';
	// private static final String SPONSOR_COUNTRY_RO = 'SponsorCountryRO';
	// private static final String SPONSOR_STATE_RO = 'SponsorStateRO';
	// private static final String SPONSOR_STATE_FOR_NON_US_COUNTRY_RO = 'SponsorStateForNonUSCountryRO';
	// private static final String SPONSOR_ZIP_CODE_RO = 'SponsorZipcodeRO';
	// private static final String SPONSOR_NAME = 'SponsorName';
	// private static final String SPONSOR_STREET = 'SponsorStreetAddress';
	// private static final String SPONSOR_CITY = 'SponsorCity';
	// private static final String SPONSOR_COUNTRY = 'SponsorCountry';
	// private static final String SPONSOR_STATE = 'SponsorStateCode';
	// private static final String SPONSOR_STATE_FOR_NON_US_COUNTRY = 'SponsorStateForNonUSCountry';
	// private static final String SPONSOR_ZIP_CODE = 'SponsorZipcode';
	// private static final String SPONSOR_ZIP_CODE_F = 'SponsorZipcodeF';
	// private static final String SPONSOR_ZIP_CODE_US = 'SponsorZipcodeUS';
	// private static final String SPONSOR_ZIP_CODE_NON_US = 'SponsorZipcodeNonUS';
	// private static final String SPONSOR_ZIP_CODE_RO1 = 'SponsorZipcodeRO1';
	// private static final String PROGRAM_NAME_RO = 'ProgramNameRO';
	// private static final String PROGRAM_STREET_RO = 'ProgramStreetAddressRO';
	// private static final String PROGRAM_CITY_RO = 'ProgramCityRO';
	// private static final String PROGRAM_COUNTRY_RO = 'ProgramCountryRO';
	// private static final String PROGRAM_STATE_RO = 'ProgramStateRO';
	// private static final String PROGRAM_STATE_FOR_NON_US_COUNTRY_RO = 'ProgramStateForNonUSCountryRO';
	// private static final String PROGRAM_ZIP_CODE_RO = 'ProgramZipcodeRO';
	// private static final String PROGRAM_NAME = 'ProgramName';
	// private static final String PROGRAM_STREET = 'ProgramStreetAddress';
	// private static final String PROGRAM_CITY = 'ProgramCity';
	// private static final String PROGRAM_COUNTRY = 'ProgramCountry';
	// private static final String PROGRAM_STATE = 'ProgramStateCode';
	// private static final String PROGRAM_STATE_FOR_NON_US_COUNTRY = 'ProgramStateForNonUSCountry';
	// private static final String PROGRAM_ZIP_CODE = 'ProgramZipcode';
	// private static final String US_COUNTRY_CODE = 'US';
	// private static final String APPLICATION_TYPE_NEW = 'New';
	// private static final String APPLICATION_TYPE_RENEWAL = 'Renewal';
	// private static final String PAR_ID = 'parId';
	// private static final String TEMP_AUTH_ID = 'tempAuthId';
	// private static final String LOCATION_ID = 'checksponsorlocId';
	// private static final String PROGRAM_LOCATION_ID = 'checkProgramLocId';
	// private static final String YES = 'Yes';
	// private static final String NO = 'No';
	// private static final List<String> LIST_OF_TEMP_AUTH_FIELDS = new List<String>{
	// 	'ID',
	// 	'Location__c',
	// 	'Location__r.Status__c',
	// 	'Location__r.CloseDate',
	// 	'Location__r.LocationType'
	// };

	global Object call(String action, Map<String, Object> args) {
		Map<String, Object> input = (Map<String, Object>) args.get('input');
		Map<String, Object> output = (Map<String, Object>) args.get('output');
		Map<String, Object> options = (Map<String, Object>) args.get('options');

		return invokeMethod(action, input, output, options);
	}

	/**
	 * @author            : Pranaya Etta
	 * @lastModifiedBy    : Pranaya Etta
	 * @param methodName  : The name of the method to be executed.
	 * @param inputMap    : Input Parameter Passed from Omniscript
	 * @param outMap      : Output Passed to Omniscript
	 * @param options     : Extra Options passed from Omniscript
	 * @return Boolean    : Returns true if the method is successfully executed, else false.
	 */
	private Boolean invokeMethod(
		String methodName,
		Map<String, Object> inputMap,
		Map<String, Object> outMap,
		Map<String, Object> options
	) {
		// if (methodName == SAVE_SPONSORING_LOCATION_DETAILS) {
		// 	saveSponsoringLocationsInformation(inputMap, outMap, options);
		// } 
        // else if (methodName == FETCH_SPONSORING_LOCATION_DETAILS) {
		// 	fetchSponsoringInformation(inputMap, outMap, options);
		// } 
        // else if (methodName == SAVE_PRIMARY_PROGRAM_LOCATION_DETAILS) {
		// 	savePrimaryProgramInformation(inputMap, outMap, options);
		// } 
        // else if (methodName == FETCH_PRIMARY_PROGRAM_LOCATION_DETAILS) {
		// 	fetchPrimaryProgramInformation(inputMap, outMap, options);
		// } 
        // else if (methodName == UPSERT_SATELLITE_LOCATION_DETAILS) {
		// 	upsertSatelliteLocationsInformation(inputMap, outMap, options);
		// } 
        // else if (methodName == FETCH_SATELLITE_LOCATION_DETAILS) {
		// 	fetchSatelliteInformation(inputMap, outMap, options);
		// } 
        // else if (methodName == DELETE_SATELLITE_LOCATION_DETAILS) {
		// 	deleteSatelliteInformation(inputMap, outMap, options);
		// } 
        // else if (methodName == DELETE_ALL_SATELLITE_LOCATIONS) {
		// 	deleteSatelliteInformationNO(inputMap, outMap, options);
		// } 
        // else if (methodName == SAVE_RS_PRIMARY_PROGRAM_LOCATION_DETAILS) {
		// 	saveRSPrimaryProgramInformation(inputMap, outMap, options);
		// }
		return null;
	}

	/**
	 * @description       : This method is responsible for creating sponsoring locations.
	 * @author            : Pranaya Etta
	 * @lastModifiedBy    : Pranaya Etta
	 * @param inputMap    : fetching all the input from Omniscript
	 * @param outMap      : Passing value to Omniscript
	 * @param options     : Passing Options to Omniscript if needed
	 */
	// private static void saveSponsoringLocationsInformation(
	// 	Map<String, Object> inputMap,
	// 	Map<String, Object> outMap,
	// 	Map<String, Object> options
	// ) {
	// 	try {
	// 		String parId = (String) inputMap.get(PAR_ID);
	// 		String type = (String) inputMap.get('type');
	// 		String name, nameRO, countryRO, country, sponsoringSameAsSchool,institutionalOwnership;
	// 		Map<String, Object> sponsorBlock, sponsorBlockRO;
	// 		Map<String, Object> stepInfo = (Map<String, Object>) inputMap.get(
	// 			String.escapeSingleQuotes('SponsoringInformation')
	// 		);
	// 		if (!stepInfo.isEmpty()) {
	// 			sponsoringSameAsSchool = (String) stepInfo.get('SponsoringSameAsSchool');
    //             institutionalOwnership = (String) stepInfo.get('InstitutionalOwnership');
	// 			sponsorBlock = (Map<String, Object>) stepInfo.get(String.escapeSingleQuotes('SponsoringInfoBlock'));
				
	// 			sponsorBlockRO = (Map<String, Object>) stepInfo.get(
	// 				String.escapeSingleQuotes('SponsoringInfoReadOnlyBlock')
	// 			);
	// 			/*
	// 			if (sponsorBlockRO != null && !sponsorBlockRO.isEmpty()) {
	// 				nameRO = (String) sponsorBlockRO.get(SPONSOR_NAME_RO);
	// 				countryRO = (String) sponsorBlockRO.get(SPONSOR_COUNTRY_RO);
	// 				if(String.valueOf(sponsorBlockRO.get(SPONSOR_ZIP_CODE_RO)).contains('-')){
	// 					sponsorBlockRO.put(SPONSOR_ZIP_CODE_RO,String.valueOf(sponsorBlockRO.get(SPONSOR_ZIP_CODE_RO)).remove('-'));
	// 				}
	// 			}
	// 			if (sponsorBlock != null && !sponsorBlock.isEmpty()) {
	// 				name = (String) sponsorBlock.get(SPONSOR_NAME);
	// 				country = (String) sponsorBlock.get(SPONSOR_COUNTRY);
	// 				if(String.valueOf(sponsorBlock.get(SPONSOR_ZIP_CODE_F)).contains('-')){
	// 					sponsorBlock.put(SPONSOR_ZIP_CODE_F,String.valueOf(sponsorBlock.get(SPONSOR_ZIP_CODE_F)).remove('-'));
	// 				}
	// 			}*/
	// 		}
	// 		// Updating SponsoringSameAsSchool in PAR (Added by saurabh)
	// 		if(String.isNotBlank(parId))
	// 		{
	// 			PreliminaryApplicationRef par = new PreliminaryApplicationRef(Id = parId);
	// 			//par.Sponsoring_Same_As_School__c = sponsoringSameAsSchool;
    //             //par.Institutional_Ownership__c = institutionalOwnership;
	// 			LPI_DML.doUpdate(par);
	// 		}

	// 		String accId = (String) inputMap.get('businessAccId');
	// 		String locationId = '';
    //         String checkLocId;
	// 		String tempAuthId = (String) inputMap.get(TEMP_AUTH_ID);
    //         if(inputMap.get(LOCATION_ID)!=null){
	// 			checkLocId = (String) inputMap.get(LOCATION_ID);
    //         }

	// 		// inserting school location,address with type Sponsoring
	// 		if (String.isNotBlank(sponsoringSameAsSchool) && sponsoringSameAsSchool.equals(YES)) {
	// 			Map<String, String> keyMappingAdd = new Map<String, String>{
	// 				SPONSOR_STREET_RO => 'Street',
	// 				SPONSOR_CITY_RO => 'City',
	// 				SPONSOR_ZIP_CODE_RO => 'PostalCode',
	// 				SPONSOR_COUNTRY_RO => 'CountryCode'
	// 			};
	// 			//checking if country is US
	// 			if (US_COUNTRY_CODE.equals(countryRO)) {
	// 				keyMappingAdd.put(SPONSOR_STATE_RO, 'StateCode');
	// 			} else {
	// 				keyMappingAdd.put(SPONSOR_STATE_FOR_NON_US_COUNTRY_RO, 'Business_State__c');
	// 			}
	// 			locationId = LPI_AddressUtility.createLocationAndAddress(
	// 				accId,
	// 				SPONSORING_LOCATION,
	// 				nameRO,
	// 				keyMappingAdd,
	// 				sponsorBlockRO
	// 			);
	// 		}
	// 		// inserting new location,address with type Sponsoring if user selects No OR type=amendment
	// 		else if (
	// 			String.isNotBlank(sponsoringSameAsSchool) && sponsoringSameAsSchool.equals(NO) ||
	// 			!APPLICATION_TYPE_NEW.equals(type)
	// 		) {
	// 			Map<String, String> keyMappingAdd = new Map<String, String>{
	// 				SPONSOR_STREET => 'Street',
	// 				SPONSOR_CITY => 'City',
	// 				SPONSOR_ZIP_CODE_F => 'PostalCode',
	// 				SPONSOR_COUNTRY => 'CountryCode'
	// 			};
	// 			//checking if country is US
	// 			if (US_COUNTRY_CODE.equals(country)) {
	// 				keyMappingAdd.put(SPONSOR_STATE, 'StateCode');
	// 			} else {
	// 				keyMappingAdd.put(SPONSOR_STATE_FOR_NON_US_COUNTRY, 'Business_State__c');
	// 			}
	// 			locationId = LPI_AddressUtility.createLocationAndAddress(
	// 				accId,
	// 				SPONSORING_LOCATION,
	// 				name,
	// 				keyMappingAdd,
	// 				sponsorBlock
	// 			);
	// 			//updating location name if user modifies only name
	// 			if (locationId.equals(checkLocId)) {
    //                 locationId = updateLocationName(locationId,SPONSORING_LOCATION,name);
	// 			}
	// 		}
	// 		//Create Temp authorization place
    //         String tempAuthApplicationPlaceId = checkForTempAuth(parId,SPONSORING_LOCATION);
	// 		tempAuthId = LPI_AddressUtility.createTempAuthPlaceRecord(tempAuthApplicationPlaceId, locationId, parId);
	// 		//System.assert(false,'**'+checkLocId+'&&'+locationId);
	// 		//inserting AssociatedLocation
	// 		LPI_AddressUtility.upsertAssociationLocRecord(accId, checkLocId, locationId);
	// 		outMap.put(TEMP_AUTH_ID, tempAuthId);
	// 		outMap.put(LOCATION_ID, locationId);
	// 	} catch (Exception e) {
	// 		LPI_ExceptionManager.logException(CLASS_NAME, SAVE_SPONSORING_LOCATION_DETAILS, e);
	// 		throw new LPI_Exception('Problem in Saving the sponsoring location details', e);
	// 	}
	// }
	// /**
	//  * @description       : This method is responsible for fetching sponsoring locations
	//  * @author            : Pranaya Etta
	//  * @lastModifiedBy    : Pranaya Etta
	//  * @param inputMap    : fetching all the input from Omniscript
	//  * @param outMap      : Passing value to Omniscript
	//  * @param options     : Passing Options to Omniscript if needed
	//  */
	// public static void fetchSponsoringInformation(
	// 	Map<String, Object> inputMap,
	// 	Map<String, Object> outMap,
	// 	Map<String, Object> options
	// ) {
	// 	try {
	// 		String parId = (String) inputMap.get(PAR_ID);
	// 		String blId = (String) inputMap.get('blId');
	// 		String type = (String) inputMap.get('type');
	// 		String sponsoringSameAsSchool,institutionalOwnership;

	// 		Set<Id> locationIds = new Set<Id>();
	// 		Map<Object, Object> mapOfTempIdLocId = new Map<Object, Object>();
	// 		if (String.isNotBlank(parId) || (String.isBlank(blId) && !APPLICATION_TYPE_NEW.equals(type))) {
	// 			//fetching par field for condition
	// 			String parFields = 'Id, Business_License__c ';
	// 			String parWhereClause = 'Id =\'' + String.escapeSingleQuotes(parId) + '\'';
	// 			List<PreliminaryApplicationRef> parList = LPI_PreliminaryApplicationRefDAO.getPreliminaryApplicationRefByDymanicQuery(
	// 				parFields,
	// 				parWhereClause,
	// 				null,
	// 				null,
	// 				null
	// 			);
	// 			if (!parList.isEmpty()) {
	// 				blId = parList[0]?.Business_License__c; //For renewal and amendment case
	// 				//sponsoringSameAsSchool = parList[0]?.Sponsoring_Same_As_School__c;
    //                // institutionalOwnership = parList[0]?.Institutional_Ownership__c;
    //                 if(String.isNotBlank(sponsoringSameAsSchool)){
    //                 	outMap.put('SponsoringSameAsSchool', sponsoringSameAsSchool); // For Main OS
    //                 }
    //                 if(String.isNotBlank(institutionalOwnership)){
    //                 	outMap.put('InstitutionalOwnership', institutionalOwnership); // For Main OS
    //                 }
	// 			}
	// 			outMap.put('SponsoringAsSchool', sponsoringSameAsSchool); //For review page
    //             outMap.put('InstitutionalOwnershipReview', institutionalOwnership);

	// 			//get existing locations from BL
	// 			locationIds = getExistingLocationsFromBL(blId,SPONSORING_LOCATION);
	// 			//querying temp auth of locType:Business or Sponsoring
	// 			String tempAuthPlaceWhereClause =
	// 				'Preliminary_Application_Reference__c =\'' +
	// 				String.escapeSingleQuotes(parId) +
	// 				'\'' +
	// 				' AND (Location__r.LocationType =\'' +
	// 				BUSINESS_ADDRESS +
	// 				'\'' +
	// 				' OR Location__r.LocationType =\'' +
	// 				SPONSORING_LOCATION +
	// 				'\'' +
	// 				')';
	// 			List<Temp_AuthApplicationPlace__c> tempAAP = LPI_TempAuthApplicationPlaceDAO.getTempAuthApplicationPlaceByDymanicQuery(
	// 				LIST_OF_TEMP_AUTH_FIELDS,
	// 				tempAuthPlaceWhereClause,
	// 				null,
	// 				null,
	// 				null
	// 			);
	// 			for (Temp_AuthApplicationPlace__c temp_AAP : tempAAP) {
	// 				locationIds.add(temp_AAP.Location__c);
	// 				//storing tempAuthIds in a map
	// 				mapOfTempIdLocId.put(temp_AAP.Location__c, temp_AAP.Id);
	// 			}
	// 			//if user selects Yes,fetching school(business) address
	// 			List<Schema.Address> addressList = getAddressList(locationIds, BUSINESS_ADDRESS);
	// 			// Checking whether the address List is empty or not
	// 			if (!addressList.isEmpty() && addressList[0].Parent.LocationType == BUSINESS_ADDRESS) {
	// 				Schema.Address addr = addressList[0];
	// 				List<String> name = addr.Parent.Name.split(' - ');
	// 				outMap.put(SPONSOR_NAME_RO, name[0]);
	// 				outMap.put(SPONSOR_STREET_RO, addr.Street);
	// 				outMap.put(SPONSOR_CITY_RO, addr.City);
	// 				outMap.put(SPONSOR_ZIP_CODE_RO, addr.PostalCode);
	// 				outMap.put(SPONSOR_COUNTRY_RO, addr.CountryCode);
	// 				if (US_COUNTRY_CODE.equals(addr.CountryCode)) {
	// 					outMap.put(SPONSOR_STATE_RO, addr.StateCode);
	// 					outMap.put('StateForReviewRO', addr.State);
	// 				} else {
	// 					outMap.put(SPONSOR_STATE_FOR_NON_US_COUNTRY_RO, addr.Business_State__c);
	// 				}

	// 				outMap.put('CountryForReviewRO', addr.Country);
	// 				outMap.put(TEMP_AUTH_ID, mapOfTempIdLocId.get(addr.ParentId));
	// 				//only sending tempAuthId to outMap,not location of Business Address because AssociatedLocation is getting updated instead of inserting
	// 				//outMap.put(LOCATION_ID, addr.ParentId);
	// 			}
	// 			//if user selects No OR Application type=renewal or amendment , fetching Sponsoring address
	// 			if (
	// 				(String.isNotBlank(sponsoringSameAsSchool) && sponsoringSameAsSchool.equals(NO)) ||
	// 				!APPLICATION_TYPE_NEW.equals(type)
	// 			) {
	// 				addressList = getAddressList(locationIds, SPONSORING_LOCATION);
	// 				// Checking whether the address List is empty or not
	// 				if (!addressList.isEmpty()) {
	// 					//New : we get one address which user enters by selecting No
	// 					//Renewal : we get one existing address
	// 					//Amendment : we get multiple addresses after user changes details(existing one and newly added one),
	// 					//so selecting newly added address based on status and closedate
	// 					//this happens when user goes previous->next and for review page(here we need newly added address)
	// 					Schema.Address addr;
	// 					if (addressList.size() == 1) {
	// 						addr = addressList[0];
	// 					} else {
	// 						for (Schema.Address address : addressList) {
	// 							if (
	// 								address.Parent.Status__c == LPI_LiteralConstant.LOCATION_STATUS_CLOSED &&
	// 								address.Parent.CloseDate == null
	// 							) {
	// 								addr = address;
	// 							}
	// 						}
	// 					}
	// 					List<String> name = addr.Parent.Name.split(' - ');
	// 					outMap.put(SPONSOR_NAME, name[0]);
	// 					outMap.put(SPONSOR_STREET, addr.Street);
	// 					outMap.put(SPONSOR_CITY, addr.City);
	// 					outMap.put(SPONSOR_ZIP_CODE_US, addr.PostalCode);
	// 					/*
	// 					if(addr.CountryCode == US_COUNTRY_CODE && addr.PostalCode.length()>5){
	// 						outMap.put(SPONSOR_ZIP_CODE_US, addr.PostalCode.substring(0, 5) + '-' + addr.PostalCode.substring(5));
	// 						outMap.put(SPONSOR_ZIP_CODE, addr.PostalCode.substring(0, 5) + '-' + addr.PostalCode.substring(5));
	// 					} else{
	// 						outMap.put(SPONSOR_ZIP_CODE, addr.PostalCode);
	// 					}*/
	// 					outMap.put(SPONSOR_ZIP_CODE, addr.PostalCode);
	// 					outMap.put(SPONSOR_ZIP_CODE_NON_US, addr.PostalCode);
	// 					outMap.put(SPONSOR_ZIP_CODE_RO1, addr.PostalCode);
	// 					outMap.put(SPONSOR_COUNTRY, addr.CountryCode);
	// 					if (US_COUNTRY_CODE.equals(addr.CountryCode)) {
	// 						outMap.put(SPONSOR_STATE, addr.StateCode);
	// 						outMap.put('StateForReview', addr.State);
	// 						outMap.put('SponsorStateReadOnly', addr.State);
	// 					} else {
	// 						outMap.put(SPONSOR_STATE_FOR_NON_US_COUNTRY, addr.Business_State__c);
	// 						outMap.put('SponsorStateReadOnly', addr.Business_State__c);
	// 					}
	// 					outMap.put('CountryForReview', addr.Country);
	// 					outMap.put(TEMP_AUTH_ID, mapOfTempIdLocId.get(addr.ParentId));
	// 					outMap.put(LOCATION_ID, addr.ParentId);
	// 				}
	// 			}
	// 		}
	// 	} catch (Exception e) {
	// 		LPI_ExceptionManager.logException(CLASS_NAME, FETCH_SPONSORING_LOCATION_DETAILS, e);
	// 		throw new LPI_Exception('Problem in Fetching the sponsoring location details', e);
	// 	}
	// }
	// /**
	//  * @description       : This method is responsible for creating primary program locations.
	//  * @author            : Pranaya Etta
	//  * @lastModifiedBy    : Pranaya Etta
	//  * @param inputMap    : fetching all the input from Omniscript
	//  * @param outMap      : Passing value to Omniscript
	//  * @param options     : Passing Options to Omniscript if needed
	//  */
	// // private static void savePrimaryProgramInformation(
	// // 	Map<String, Object> inputMap,
	// // 	Map<String, Object> outMap,
	// // 	Map<String, Object> options
	// // ) {
	// // 	try {
	// // 		String parId = (String) inputMap.get(PAR_ID);
	// // 		String name, nameRO, countryRO, country, primaryProgramSameAsSchool;
    // //         Boolean ProgramAddressFromNew,ProgramAddressNotInUse;
    // //         Date ProgramEndDate;
	// // 		Map<String, Object> programBlock, programBlockRO;
	// // 		Map<String, Object> stepInfo = (Map<String, Object>) inputMap.get(
	// // 			String.escapeSingleQuotes('ProgramInformation')
	// // 		);
	// // 		if (!stepInfo.isEmpty()) {
	// // 			primaryProgramSameAsSchool = (String) stepInfo.get('PrimaryProgramSameAsSchool');
	// // 			programBlock = (Map<String, Object>) stepInfo.get(String.escapeSingleQuotes('PrimaryProgramInfoBlock'));
	// // 			programBlockRO = (Map<String, Object>) stepInfo.get(
	// // 				String.escapeSingleQuotes('PrimaryProgramInfoReadOnlyBlock')
	// // 			);
	// // 			if (programBlockRO != null && !programBlockRO.isEmpty()) {
	// // 				nameRO = (String) programBlockRO.get(PROGRAM_NAME_RO);
	// // 				countryRO = (String) programBlockRO.get(PROGRAM_COUNTRY_RO);
	// // 			}
	// // 			if (programBlock != null && !programBlock.isEmpty()) {
	// // 				name = (String) programBlock.get(PROGRAM_NAME);
	// // 				country = (String) programBlock.get(PROGRAM_COUNTRY);
    // //                 ProgramAddressFromNew = (Boolean) inputMap.get(String.escapeSingleQuotes('ProgramAddressFromNew'));
	// // 				ProgramAddressNotInUse = (Boolean) programBlock.get(String.escapeSingleQuotes('ProgramAddressNotInUse'));
    // //                 if(programBlock.get('ProgramEndDate')!=null){
    // //                     ProgramEndDate = Date.valueOf((String) programBlock.get('ProgramEndDate'));
    // //                 }
	// // 			}
	// // 		}

	// // 		String accId = (String) inputMap.get('businessAccId');
	// // 		String locationId = '';
    // //         String checkProgramLocId;
	// // 		String tempAuthId = (String) inputMap.get(TEMP_AUTH_ID);
    // //         if(inputMap.get(PROGRAM_LOCATION_ID) != null){
	// // 			checkProgramLocId = (String) inputMap.get(PROGRAM_LOCATION_ID);
    // //         }

	// // 		//if user selects address not in use for existing address in routine survey case,then storing that value and closedate
	// // 		// on location object to change it's status
	// // 		if (ProgramAddressFromNew!=null && ProgramAddressFromNew==true) {
	// // 			Schema.Location locationRec = new Schema.Location();
	// // 			locationRec.Id = checkProgramLocId;
	// // 			locationRec.Address_Not_In_Use__c = ProgramAddressNotInUse;
    // //             locationRec.CloseDate = ProgramEndDate;
	// // 			LPI_DML.doUpdate(locationRec);
	// // 			return;
	// // 		}

	// // 		// inserting school location,address with type Primary Program
	// // 		if (String.isNotBlank(primaryProgramSameAsSchool) && primaryProgramSameAsSchool.equals(YES)) {
	// // 			Map<String, String> keyMappingAdd = new Map<String, String>{
	// // 				PROGRAM_STREET_RO => 'Street',
	// // 				PROGRAM_CITY_RO => 'City',
	// // 				PROGRAM_ZIP_CODE_RO => 'PostalCode',
	// // 				PROGRAM_COUNTRY_RO => 'CountryCode'
	// // 			};
	// // 			//checking if country is US
	// // 			if (US_COUNTRY_CODE.equals(countryRO)) {
	// // 				keyMappingAdd.put(PROGRAM_STATE_RO, 'StateCode');
	// // 			} else {
	// // 				keyMappingAdd.put(PROGRAM_STATE_FOR_NON_US_COUNTRY_RO, 'Business_State__c');
	// // 			}
	// // 			locationId = LPI_AddressUtility.createLocationAndAddress(
	// // 				accId,
	// // 				PROGRAM_LOCATION,
	// // 				nameRO,
	// // 				keyMappingAdd,
	// // 				programBlockRO
	// // 			);
	// // 		}
	// // 		// inserting new location,address with type Primary Program
	// // 		else if ((String.isNotBlank(primaryProgramSameAsSchool) && primaryProgramSameAsSchool.equals(NO))) {
	// // 			Map<String, String> keyMappingAdd = new Map<String, String>{
	// // 				PROGRAM_STREET => 'Street',
	// // 				PROGRAM_CITY => 'City',
	// // 				PROGRAM_ZIP_CODE => 'PostalCode',
	// // 				PROGRAM_COUNTRY => 'CountryCode'
	// // 			};
	// // 			//checking if country is US
	// // 			if (US_COUNTRY_CODE.equals(country)) {
	// // 				keyMappingAdd.put(PROGRAM_STATE, 'StateCode');
	// // 			} else {
	// // 				keyMappingAdd.put(PROGRAM_STATE_FOR_NON_US_COUNTRY, 'Business_State__c');
	// // 			}
	// // 			locationId = LPI_AddressUtility.createLocationAndAddress(
	// // 				accId,
	// // 				PROGRAM_LOCATION,
	// // 				name,
	// // 				keyMappingAdd,
	// // 				programBlock
	// // 			);
	// // 			//updating location name if user modifies only name
	// // 			if (locationId.equals(checkProgramLocId)) {
    // //                 locationId = updateLocationName(locationId,PROGRAM_LOCATION,name);
	// // 			}
	// // 		}
	// // 		//Create Temp authorization place
    // //         String tempAuthApplicationPlaceId = checkForTempAuth(parId,PROGRAM_LOCATION);
	// // 		tempAuthId = LPI_AddressUtility.createTempAuthPlaceRecord(tempAuthApplicationPlaceId, locationId, parId);
            
	// // 		//inserting AssociatedLocation
	// // 		LPI_AddressUtility.upsertAssociationLocRecord(accId, checkProgramLocId, locationId);
	// // 		outMap.put(TEMP_AUTH_ID, tempAuthId);
	// // 		outMap.put(PROGRAM_LOCATION_ID, locationId);
	// // 	} catch (Exception e) {
	// // 		LPI_ExceptionManager.logException(CLASS_NAME, SAVE_PRIMARY_PROGRAM_LOCATION_DETAILS, e);
	// // 		throw new LPI_Exception('Problem in Saving the primary program location details', e);
	// // 	}
	// // }
    // /**
	//  * @description       : This method is responsible for creating new primary program locations in case of Routine Survey.
	//  * @author            : Pranaya Etta
	//  * @lastModifiedBy    : Pranaya Etta
	//  * @param inputMap    : fetching all the input from Omniscript
	//  * @param outMap      : Passing value to Omniscript
	//  * @param options     : Passing Options to Omniscript if needed
	//  */
	// // private static void saveRSPrimaryProgramInformation(
	// // 	Map<String, Object> inputMap,
	// // 	Map<String, Object> outMap,
	// // 	Map<String, Object> options
    // // ) {
    // //     try{
    // //         String parId = (String) inputMap.get(PAR_ID);
	// // 		String name, country;
	// // 		Map<String, Object> rsProgramBlock;
	// // 		Map<String, Object> stepInfo = (Map<String, Object>) inputMap.get(
	// // 			String.escapeSingleQuotes('ProgramInformation')
	// // 		);
	// // 		if (!stepInfo.isEmpty()) {
	// // 			rsProgramBlock = (Map<String, Object>) stepInfo.get(String.escapeSingleQuotes('RoutineSurveyProgramInfoBlock'));
	// // 			if (rsProgramBlock != null && !rsProgramBlock.isEmpty()) {
	// // 				name = (String) rsProgramBlock.get('ProgramName');
	// // 				country = (String) rsProgramBlock.get('ProgramCountry');
	// // 			}
	// // 		}
	// // 		String accId = (String) inputMap.get('businessAccId');
	// // 		String locationId = '';
	// // 		String tempAuthId = (String) inputMap.get('tempAuthId');
	// // 		String programLocId = (String) inputMap.get('programLocId');
    // //         Map<String, String> keyMappingAdd = new Map<String, String>{
	// // 				'ProgramStreetAddress' => 'Street',
	// // 				'ProgramCity' => 'City',
	// // 				'ProgramZipcode' => 'PostalCode',
	// // 				'ProgramCountry' => 'CountryCode'
	// // 			};
    // //                 //checking if country is US
    // //                 if (US_COUNTRY_CODE.equals(country)) {
    // //                     keyMappingAdd.put('ProgramStateCode', 'StateCode');
    // //                 } else {
    // //                     keyMappingAdd.put('ProgramStateForNonUSCountry', 'Business_State__c');
    // //                 }
    // //         locationId = LPI_AddressUtility.createLocationAndAddress(
    // //             accId,
    // //             PROGRAM_LOCATION,
    // //             name,
    // //             keyMappingAdd,
    // //             rsProgramBlock
    // //         );
    // //         //updating location name if user modifies only name
    // //         if (locationId.equals(programLocId)) {
    // //             locationId = updateLocationName(locationId,PROGRAM_LOCATION,name);
    // //         }
    // //         //Create Temp authorization place
    // //         String tempAuthApplicationPlaceId = checkForTempAuth(parId,PROGRAM_LOCATION);
	// // 		tempAuthId = LPI_AddressUtility.createTempAuthPlaceRecord(tempAuthApplicationPlaceId, locationId, parId);
            
	// // 		//inserting AssociatedLocation
	// // 		LPI_AddressUtility.upsertAssociationLocRecord(accId, programLocId, locationId);
	// // 		outMap.put('tempAuthId', tempAuthId);
	// // 		outMap.put('programLocId', locationId);

            
    // //     } catch (Exception e) {
	// // 		LPI_ExceptionManager.logException(CLASS_NAME, SAVE_RS_PRIMARY_PROGRAM_LOCATION_DETAILS, e);
	// // 		throw new LPI_Exception('Problem in Saving the primary program location details for Routine Survey', e);
	// // 	}
    // // }
	// /**
	//  * @description       : This method is responsible for fetching primary program locations
	//  * @author            : Pranaya Etta
	//  * @lastModifiedBy    : Pranaya Etta
	//  * @param inputMap    : fetching all the input from Omniscript
	//  * @param outMap      : Passing value to Omniscript
	//  * @param options     : Passing Options to Omniscript if needed
	//  */
	// // public static void fetchPrimaryProgramInformation(
	// // 	Map<String, Object> inputMap,
	// // 	Map<String, Object> outMap,
	// // 	Map<String, Object> options
	// // ) {
	// // 	try {
	// // 		String parId = (String) inputMap.get(PAR_ID);
    // //         String blId = (String) inputMap.get('blId');
	// // 		String type = (String) inputMap.get('type');
    // //         String primaryProgramSameAsSchool;
    // //         Set<Id> locationIds = new Set<Id>();
	// // 		Map<Object, Object> mapOfTempIdLocId = new Map<Object, Object>();
    // //         //for application details section
	// // 		if (String.isNotBlank(parId) || (String.isBlank(blId) && !APPLICATION_TYPE_NEW.equals(type))) {
	// // 			String parFields = 'Id,Business_License__c';
	// // 			String parWhereClause = 'Id =\'' + String.escapeSingleQuotes(parId) + '\'';
	// // 			List<PreliminaryApplicationRef> parList = LPI_PreliminaryApplicationRefDAO.getPreliminaryApplicationRefByDymanicQuery(
	// // 				parFields,
	// // 				parWhereClause,
	// // 				null,
	// // 				null,
	// // 				null
	// // 			);
	// // 			if (!parList.isEmpty()) {
	// // 				blId = parList[0]?.Business_License__c; //For routine survey type case
	// // 				//primaryProgramSameAsSchool = parList[0]?.Primary_Program_Same_As_School__c;
	// // 			}
	// // 			outMap.put('PrimaryProgramAsSchool', primaryProgramSameAsSchool); //For review page
	// // 			//get existing locations from BL
	// // 			locationIds = getExistingLocationsFromBL(blId,PROGRAM_LOCATION);
	// // 			//querying temp auth of locType:Business or Primary Program
	// // 			String tempAuthPlaceWhereClause =
	// // 				'Preliminary_Application_Reference__c =\'' +
	// // 				String.escapeSingleQuotes(parId) +
	// // 				'\'' +
	// // 				' AND (Location__r.LocationType =\'' +
	// // 				BUSINESS_ADDRESS +
	// // 				'\'' +
	// // 				' OR Location__r.LocationType =\'' +
	// // 				PROGRAM_LOCATION +
	// // 				'\'' +
	// // 				')';
	// // 			List<Temp_AuthApplicationPlace__c> tempAAP = LPI_TempAuthApplicationPlaceDAO.getTempAuthApplicationPlaceByDymanicQuery(
	// // 				LIST_OF_TEMP_AUTH_FIELDS,
	// // 				tempAuthPlaceWhereClause,
	// // 				null,
	// // 				null,
	// // 				null
	// // 			);
	// // 			for (Temp_AuthApplicationPlace__c temp_AAP : tempAAP) {
	// // 				locationIds.add(temp_AAP.Location__c);
	// // 				//storing tempAuthIds in a map
	// // 				mapOfTempIdLocId.put(temp_AAP.Location__c, temp_AAP.Id);
	// // 			}
	// // 			//if user selects Yes,fetching school(business) address
	// // 			List<Schema.Address> addressList = getAddressList(locationIds, BUSINESS_ADDRESS);
	// // 			// Checking whether the address List is empty or not
	// // 			if (!addressList.isEmpty() && addressList[0].Parent.LocationType == BUSINESS_ADDRESS) {
	// // 				Schema.Address addr = addressList[0];
	// // 				List<String> name = addr.Parent.Name.split(' - ');
	// // 				outMap.put(PROGRAM_NAME_RO, name[0]);
	// // 				outMap.put(PROGRAM_STREET_RO, addr.Street);
	// // 				outMap.put(PROGRAM_CITY_RO, addr.City);
	// // 				outMap.put(PROGRAM_ZIP_CODE_RO, addr.PostalCode);
	// // 				outMap.put(PROGRAM_COUNTRY_RO, addr.CountryCode);
	// // 				if (US_COUNTRY_CODE.equals(addr.CountryCode)) {
	// // 					outMap.put(PROGRAM_STATE_RO, addr.StateCode);
	// // 					outMap.put('StateForReviewRO', addr.State);
	// // 				} else {
	// // 					outMap.put(PROGRAM_STATE_FOR_NON_US_COUNTRY_RO, addr.Business_State__c);
	// // 				}
	// // 				outMap.put('CountryForReviewRO', addr.Country);
	// // 				outMap.put(TEMP_AUTH_ID, mapOfTempIdLocId.get(addr.ParentId));
    // //                 //only sending tempAuthId to outMap,not location of Business Address because AssociatedLocation is getting updated instead of inserting
	// // 				//outMap.put(PROGRAM_LOCATION_ID, addr.ParentId);
	// // 			}
	// // 			//if user selects No , fetching Primary Program address
	// // 			if ((String.isNotBlank(primaryProgramSameAsSchool) && primaryProgramSameAsSchool.equals(NO)) || !APPLICATION_TYPE_NEW.equals(type)) {
	// // 				addressList = getAddressList(locationIds, PROGRAM_LOCATION);
	// // 				// Checking whether the address List is empty or not
	// // 				if (!addressList.isEmpty()) {
    // //                     //New : we get one address which user enters by selecting No
	// // 					//Routine Survey : we get one existing address if address not in use is false
	// // 					//Routine Survey : we get multiple addresses if address not in use is true and user enter
	// // 					//new location details(existing one and newly added one),
	// // 					//so selecting existing address based on Address_Not_In_Use__c
	// // 					Schema.Address addr,addrRS;
	// // 					if (addressList.size() == 1) {
	// // 						addr = addressList[0];
	// // 					} else {
	// // 						for (Schema.Address address : addressList) {
	// // 							if (address.Parent.Address_Not_In_Use__c == true && address.Parent.Status__c == LPI_LiteralConstant.LOCATION_STATUS_OPEN) {
	// // 								addr = address;
	// // 							}
    // //                             else{
    // //                                 addrRS = address;//for new location
    // //                             }
	// // 						}
	// // 					}
	// // 					List<String> name = addr.Parent.Name.split(' - ');
	// // 					outMap.put(PROGRAM_NAME, name[0]);
	// // 					outMap.put(PROGRAM_STREET, addr.Street);
	// // 					outMap.put(PROGRAM_CITY, addr.City);
	// // 					outMap.put(PROGRAM_ZIP_CODE, addr.PostalCode);
	// // 					outMap.put('ProgramZipcodeReadOnly', addr.PostalCode);
	// // 					outMap.put('ProgramZipcodeUS', addr.PostalCode);
	// // 					outMap.put('ProgramZipcodeNonUS', addr.PostalCode);
	// // 					outMap.put(PROGRAM_COUNTRY, addr.CountryCode);
	// // 					if (US_COUNTRY_CODE.equals(addr.CountryCode)) {
	// // 						outMap.put(PROGRAM_STATE, addr.StateCode);
	// // 						outMap.put('StateForReview', addr.State);
    // //                         outMap.put('ProgramStateReadOnly', addr.State);
	// // 					} else {
	// // 						outMap.put(PROGRAM_STATE_FOR_NON_US_COUNTRY, addr.Business_State__c);
    // //                         outMap.put('ProgramStateReadOnly', addr.Business_State__c);
	// // 					}
	// // 					outMap.put('CountryForReview', addr.Country);
	// // 					outMap.put(TEMP_AUTH_ID, mapOfTempIdLocId.get(addr.ParentId));
	// // 					outMap.put(PROGRAM_LOCATION_ID, addr.ParentId);
    // //                     outMap.put('ProgramAddressFromNew', mapOfTempIdLocId.containsKey(addr.ParentId) ? false : true);
    // //                     outMap.put('ProgramAddressNotInUse', addr.Parent.Address_Not_In_Use__c);
    // //                     outMap.put('ProgramEndDate', addr.Parent.CloseDate);
                        
    // //                     //fetching newly added address based on address not in use and type conditions
    // //                     if(addrRS!=null && addr.Parent.Address_Not_In_Use__c && !APPLICATION_TYPE_NEW.equals(type)){
    // //                         List<String> nameRS = addrRS.Parent.Name.split(' - ');
    // //                         outMap.put('ProgramName', nameRS[0]);
    // //                         outMap.put('ProgramStreetAddress', addrRS.Street);
    // //                         outMap.put('ProgramCity', addrRS.City);
    // //                         outMap.put('ProgramZipcode', addrRS.PostalCode);
	// // 						outMap.put('ProgramZipcodeUS', addrRS.PostalCode);
	// // 						outMap.put('ProgramZipcodeNonUS', addrRS.PostalCode);
    // //                         outMap.put('ProgramCountry', addrRS.CountryCode);
    // //                         if (US_COUNTRY_CODE.equals(addrRS.CountryCode)) {
    // //                             outMap.put('ProgramStateCode', addrRS.StateCode);
    // //                             outMap.put('StateForReview', addrRS.State);
    // //                         } else {
    // //                             outMap.put('ProgramStateForNonUSCountry', addrRS.Business_State__c);
    // //                         }
    // //                         outMap.put('CountryForReview', addrRS.Country);
    // //                         outMap.put('tempAuthId', mapOfTempIdLocId.get(addrRS.ParentId));
    // //                         outMap.put('programLocId', addrRS.ParentId);
    // //                     }
	// // 				}
	// // 			}
	// // 		}
	// // 	} catch (Exception e) {
	// // 		LPI_ExceptionManager.logException(CLASS_NAME, FETCH_PRIMARY_PROGRAM_LOCATION_DETAILS, e);
	// // 		throw new LPI_Exception('Problem in Fetching the primary program location details', e);
	// // 	}
	// // }
	// /**
	//  * @description       : This method is responsible for creating or updating satellite locations.
	//  * @author            : Pranaya Etta
	//  * @lastModifiedBy    : Pranaya Etta
	//  * @param inputMap    : fetching all the input from Omniscript
	//  * @param outMap      : Passing value to Omniscript
	//  * @param options     : Passing Options to Omniscript if needed
	//  */

	// // private static void upsertSatelliteLocationsInformation(
	// // 	Map<String, Object> inputMap,
	// // 	Map<String, Object> outMap,
	// // 	Map<String, Object> options
	// // ) {
	// // 	try {
	// // 		String parId = (String) options.get(PAR_ID);
    // //         String blId = (String) options.get('blId');
    // //         String type = (String) options.get('type');
	// // 		String locationId = '';

	// // 		String tempAuthId = (String) inputMap.get(TEMP_AUTH_ID);
	// // 		String pracLocId = (String) inputMap.get('Id');
	// // 		String name, country, accId;
    // //         Date EndDate;
	// // 		name = (String) inputMap.get('SatelliteName');
	// // 		country = (String) inputMap.get('SatelliteCountry');
            
    // //         Boolean AddressFromNew = (Boolean) inputMap.get(String.escapeSingleQuotes('AddressFromNew'));
	// // 		Boolean AddressNotInUse = (Boolean) inputMap.get(String.escapeSingleQuotes('AddressNotInUse'));
    // //         if(inputMap.get('SatelliteEndDate')!=null){
    // //             EndDate = Date.valueOf((String) inputMap.get('SatelliteEndDate'));
    // //         }

	// // 		//if user selects address not in use for existing address in routine survey case,then storing that value and closedate
	// // 		// on location object to change it's status
	// // 		if (AddressFromNew != null && AddressFromNew == true) {
	// // 			Schema.Location locationRec = new Schema.Location();
	// // 			locationRec.Id = pracLocId;
	// // 			locationRec.Address_Not_In_Use__c = AddressNotInUse;
    // //             locationRec.CloseDate = EndDate;
	// // 			LPI_DML.doUpdate(locationRec);
	// // 			return;
	// // 		}

	// // 		// fetching accountId From PAR Object
	// // 		if (String.isNotBlank(parId)) {
	// // 			List<PreliminaryApplicationRef> par = LPI_PreliminaryApplicationRefDAO.getPreliminaryApplicationRefByDymanicQuery(
	// // 				'BusinessAccountNameId',
	// // 				'Id = \'' + String.escapeSingleQuotes(parId) + '\'',
	// // 				null,
	// // 				null,
	// // 				null
	// // 			);
	// // 			if (!par.isEmpty()) {
	// // 				accId = par[0].BusinessAccountNameId;
	// // 			}
	// // 		}
	// // 		// New Address Mapping
	// // 		Map<String, String> keyMappingAdd = new Map<String, String>{
	// // 			'SatelliteStreetAddress' => 'Street',
	// // 			'SatelliteCity' => 'City',
	// // 			'SatelliteCountry' => 'CountryCode',
	// // 			'SatelliteZipCode' => 'PostalCode'
	// // 		};
	// // 		if (US_COUNTRY_CODE.equals(country)) {
	// // 			keyMappingAdd.put('SatelliteStateCode', 'StateCode');
	// // 		} else {
	// // 			keyMappingAdd.put('SatelliteStateForNonUSCountry', 'Business_State__c');
	// // 		}
	// // 		//inserting location,address
	// // 		locationId = LPI_AddressUtility.createLocationAndAddress(
	// // 			accId,
	// // 			SATELLITE_LOCATION,
	// // 			name,
	// // 			keyMappingAdd,
	// // 			inputMap
	// // 		);
	// // 		//updating location name if user modifies only name
	// // 		if (locationId.equals(pracLocId)) {
    // //             locationId = updateLocationName(locationId,SATELLITE_LOCATION,name);
	// // 			return;
	// // 		}
    // //         //In case of Routine Survey,if user tries to add new location with 
    // //         //existing open location details,throwing exception of Address Already exists
    // //         Set<Id> locationIdsFromBL = new Set<Id>();
    // //         if(!APPLICATION_TYPE_NEW.equals(type)){
    // //             locationIdsFromBL = getExistingLocationsFromBL(blId,SATELLITE_LOCATION);
    // //             if(!locationIdsFromBL.isEmpty() && locationIdsFromBL.contains(locationId)){
    // //                 throw new LPI_Exception(CANNOT_ADD_DUPLICATE_ADDRESS);
    // //             }
    // //         }
	// // 		//inserting tempAuth
	// // 		tempAuthId = LPI_AddressUtility.createTempAuthPlaceRecord(tempAuthId, locationId, parId);
	// // 		if (CANNOT_ADD_DUPLICATE_ADDRESS.equals(tempAuthId)) {
	// // 			throw new LPI_Exception(CANNOT_ADD_DUPLICATE_ADDRESS);
	// // 		}

	// // 		//inserting AssociatedLocation
	// // 		LPI_AddressUtility.upsertAssociationLocRecord(accId, pracLocId, locationId);

	// // 		//sending created Location,Temp_AuthApplicationPlace__c Ids and AddressFromNew value to outmap
	// // 		outMap.put(TEMP_AUTH_ID, tempAuthId);
	// // 		outMap.put('Id', locationId);
    // //         outMap.put('AddressFromNew', false); //in case of adding new locations,this value needs to be false
	// // 	} catch (Exception e) {
	// // 		if (e.getMessage() == CANNOT_ADD_DUPLICATE_ADDRESS) {
	// // 			throw new LPI_Exception(CANNOT_ADD_DUPLICATE_ADDRESS, e);
	// // 		}
	// // 		LPI_ExceptionManager.logException(CLASS_NAME, UPSERT_SATELLITE_LOCATION_DETAILS, e);
	// // 		throw new LPI_Exception('Problem in Saving the satellite location deails', e);
	// // 	}
	// // }
	// /**
	//  * @description       : This method is responsible for fetching satellite locations
	//  * @author            : Pranaya Etta
	//  * @lastModifiedBy    : Pranaya Etta
	//  * @param inputMap    : fetching all the input from Omniscript
	//  * @param outMap      : Passing value to Omniscript
	//  * @param options     : Passing Options to Omniscript if needed
	//  */
	// // public static void fetchSatelliteInformation(
	// // 	Map<String, Object> inputMap,
	// // 	Map<String, Object> outMap,
	// // 	Map<String, Object> options
	// // ) {
	// // 	try {
	// // 		// Fetching PAR Id from OS
	// // 		String parId = (String) inputMap.get(PAR_ID);
    // //         String blId = (String) inputMap.get('blId');
	// // 		String type = (String) inputMap.get('type');
    // //         String satelliteAtDiffLoc;
    // //         //for application details section
    // //         if (String.isNotBlank(parId) || (String.isBlank(blId) && !APPLICATION_TYPE_NEW.equals(type))) {
    // //             String parFields = 'Id,Business_License__c';
    // //             String parWhereClause = 'Id =\'' + String.escapeSingleQuotes(parId) + '\'';
    // //             List<PreliminaryApplicationRef> parList = LPI_PreliminaryApplicationRefDAO.getPreliminaryApplicationRefByDymanicQuery(
    // //                 parFields,
    // //                 parWhereClause,
    // //                 null,
    // //                 null,
    // //                 null
    // //             );
    // //             if (!parList.isEmpty()) {
    // //                 blId = parList[0]?.Business_License__c;
    // //                 //satelliteAtDiffLoc = parList[0]?.Satellite_Sites_At_Different_Locations__c;
    // //                 if(String.isNotBlank(satelliteAtDiffLoc)){
    // //                 	outMap.put('SatelliteSitesAtDifferentLoc', satelliteAtDiffLoc); // For Main OS
    // //                 }
    // //             }
                
    // //             Set<Id> locationIds = new Set<Id>();
    // //             Map<Object, Object> mapOfTempIdLocId = new Map<Object, Object>();
    // //             List<Map<String, Object>> locationListMap = new List<Map<String, Object>>();
    // //             Integer noOfRecords = 0;
    // //             // querying Temp AuthPlace Record of LocationType: SatelliteLocation
    // //             String tempAuthPlaceWhereClause =
    // //                 'Preliminary_Application_Reference__c =\'' +
    // //                 String.escapeSingleQuotes(parId) +
    // //                 '\'' +
    // //                 ' AND Location__r.LocationType=\'' +
    // //                 SATELLITE_LOCATION +
    // //                 '\'';
    // //             List<Temp_AuthApplicationPlace__c> tempAAP = LPI_TempAuthApplicationPlaceDAO.getTempAuthApplicationPlaceByDymanicQuery(
    // //                 LIST_OF_TEMP_AUTH_FIELDS,
    // //                 tempAuthPlaceWhereClause,
    // //                 null,
    // //                 null,
    // //                 null
    // //             );
    // //             //get existing locations
    // //             locationIds = getExistingLocationsFromBL(blId,SATELLITE_LOCATION);
    // //             // Loop iterating over list of Temp_AuthApplicationPlace__c records and storing locations to set
    // //             for (Temp_AuthApplicationPlace__c temp_AAP : tempAAP) {
    // //                 locationIds.add(temp_AAP.Location__c);
    // //                 //storing tempAuthIds in a map
    // //                 mapOfTempIdLocId.put(temp_AAP.Location__c, temp_AAP.Id);
    // //             }
    // //             List<Schema.Address> addressList = getAddressList(locationIds, SATELLITE_LOCATION);
    // //             // Checking whether the address List is empty or not
    // //             if ((String.isNotBlank(satelliteAtDiffLoc) && satelliteAtDiffLoc.equals(YES)) || !APPLICATION_TYPE_NEW.equals(type)) {
    // //                 if (!addressList.isEmpty()) {
    // //                     //Fetching the saved detail of Satellite Location and passing those to OS
    // //                     for (Schema.Address addr : addressList) {
    // //                         //Storing Satellite Location details in map
    // //                         Map<String, Object> addressMap = new Map<String, Object>();
    // //                         noOfRecords = noOfRecords + 1;
    // //                         List<String> name = addr.Parent.Name.split(' - ');
    // //                         addressMap.put('SatelliteName', name[0]);
    // //                         addressMap.put('SatelliteStreetAddress', addr.Street);
    // //                         addressMap.put('SatelliteCity', addr.City);
    // //                         addressMap.put('SatelliteZipCode', addr.PostalCode);
	// // 						addressMap.put('SatelliteZipCodeRO', addr.PostalCode);
	// // 						addressMap.put('SatelliteZipCodeUS', addr.PostalCode);
	// // 						addressMap.put('SatelliteZipCodeNonUS', addr.PostalCode);
    // //                         addressMap.put('SatelliteCountry', addr.CountryCode);
    // //                         if (US_COUNTRY_CODE.equalsIgnoreCase(addr.CountryCode)) {
    // //                             addressMap.put('SatelliteStateCode', addr.StateCode);
    // //                             addressMap.put('StateForReview', addr.State);
    // //                             addressMap.put('SatelliteStateReadOnly', addr.State);
    // //                         } else {
    // //                             addressMap.put('SatelliteStateForNonUSCountry', addr.Business_State__c);
    // //                             addressMap.put('SatelliteStateReadOnly', addr.Business_State__c);
    // //                         }
    // //                         addressMap.put('CountryForReview', addr.Country);
    // //                         addressMap.put('Id', addr.ParentId);
    // //                         addressMap.put(TEMP_AUTH_ID, mapOfTempIdLocId.get(addr.ParentId));
    // //                         addressMap.put('NoOfRecords', 'Satellite Location ' + String.ValueOf(noOfRecords));
    // //                         addressMap.put('AddressFromNew', mapOfTempIdLocId.containsKey(addr.ParentId) ? false : true);
    // //                         addressMap.put('AddressNotInUse', addr.Parent.Address_Not_In_Use__c);
    // //                         addressMap.put('SatelliteEndDate', addr.Parent.CloseDate);
    // //                         locationListMap.add(addressMap);
    // //                     }
    // //                 }
    // //                 //Sending Satellite Location Details to OS
    // //                 if (
    // //                     !locationListMap.isEmpty()
    // //                 ) {
    // //                     outMap.put('AddSatelliteLocationDetails', locationListMap);
    // //                 }
    // //             }
    // //         }
	// // 	} catch (Exception e) {
	// // 		LPI_ExceptionManager.logException(CLASS_NAME, FETCH_SATELLITE_LOCATION_DETAILS, e);
	// // 		throw new LPI_Exception('Problem in Fetching the Satellite location details', e);
	// // 	}
	// // }
	// /**
	//  * @description       : This method is responsible for deleting satellite locations for No condition.
	//  * @author            : Pranaya Etta
	//  * @lastModifiedBy    : Pranaya Etta
	//  * @param inputMap    : fetching all the input from Omniscript
	//  * @param outMap      : Passing value to Omniscript
	//  * @param options     : Passing Options to Omniscript if needed
	//  */
	// // private static void deleteSatelliteInformationNO(
	// // 	Map<String, Object> inputMap,
	// // 	Map<String, Object> outMap,
	// // 	Map<String, Object> options
	// // ) {
	// // 	try {
	// // 		String parId = (String) inputMap.get(PAR_ID);
	// // 		Set<Id> locationIds = new Set<Id>();
	// // 		if (String.isNotBlank(parId)) {
	// // 			//querying all tempAuths of locType: Satellite
	// // 			String tempAuthPlaceWhereClause =
	// // 				'Preliminary_Application_Reference__c =\'' +
	// // 				String.escapeSingleQuotes(parId) +
	// // 				'\'' +
	// // 				' AND Location__r.LocationType =\'' +
	// // 				SATELLITE_LOCATION +
	// // 				'\'' +
	// // 				' AND Location__r.Status__c=\'' +
	// // 				LPI_LiteralConstant.LOCATION_STATUS_CLOSED +
	// // 				'\'' +
	// // 				' AND Location__r.CloseDate=NULL';
	// // 			List<Temp_AuthApplicationPlace__c> tempAAPList = LPI_TempAuthApplicationPlaceDAO.getTempAuthApplicationPlaceByDymanicQuery(
	// // 				LIST_OF_TEMP_AUTH_FIELDS,
	// // 				tempAuthPlaceWhereClause,
	// // 				null,
	// // 				null,
	// // 				null
	// // 			);
	// // 			// Loop iterating over list of Temp_AuthApplicationPlace__c records and storing locations to set
	// // 			for (Temp_AuthApplicationPlace__c temp_AAP : tempAAPList) {
	// // 				locationIds.add(temp_AAP.Location__c);
	// // 			}
	// // 			// delete Temp_AuthApplicationPlace
	// // 			if (!tempAAPList.isEmpty()) {
	// // 				LPI_WithoutSharingUtility.deleteSObject(tempAAPList);
	// // 			}
	// // 			if (!locationIds.isEmpty()) {
	// // 				//querying AssociatedLocation linked to locationId
	// // 				String assLocWhereClause =
	// // 					'LocationId IN ' + LPI_ServiceUtility.getStringValuesByList(new List<Id>(locationIds));
	// // 				List<AssociatedLocation> assLocList = LPI_AssociatedLocationDAO.getAssociatedLocationListByDynamicQuery(
	// // 					new List<String>{ 'Id', 'LocationId' },
	// // 					assLocWhereClause,
	// // 					null,
	// // 					null,
	// // 					null
	// // 				);
	// // 				//delete associatedLocation
	// // 				if (!assLocList.isEmpty()) {
	// // 					LPI_WithoutSharingUtility.deleteSObject(assLocList);
	// // 				}
	// // 				// delete location linked to Temp_AuthApplicationPlace and when location get deleted then Address also get deleted automatically
	// // 				List<Schema.Location> locationList = LPI_LocationDAO.getLocationByDymanicQuery(
	// // 					'Id',
	// // 					'Id IN ' + LPI_ServiceUtility.getStringValuesByList(new List<Id>(locationIds)),
	// // 					null,
	// // 					null,
	// // 					null
	// // 				);
	// // 				if (!locationList.isEmpty()) {
	// // 					LPI_WithoutSharingUtility.deleteSObject(locationList);
	// // 				}
	// // 			}
	// // 		}
	// // 	} catch (Exception e) {
	// // 		LPI_ExceptionManager.logException(CLASS_NAME, DELETE_ALL_SATELLITE_LOCATIONS, e);
	// // 		throw new LPI_Exception('Problem occured in deleting the records please contact admin', e);
	// // 	}
	// // }

	// /**
	//  * @description       : This method is responsible for deleting satellite locations.
	//  * @author            : Pranaya Etta
	//  * @lastModifiedBy    : Pranaya Etta
	//  * @param inputMap    : fetching all the input from Omniscript
	//  * @param outMap      : Passing value to Omniscript
	//  * @param options     : Passing Options to Omniscript if needed
	//  */

	// // private static void deleteSatelliteInformation(
	// // 	Map<String, Object> inputMap,
	// // 	Map<String, Object> outMap,
	// // 	Map<String, Object> options
	// // ) {
	// // 	try {
	// // 		String recordId = (String) inputMap.get('Id'); //location Id from OS
	// // 		String tempAuthId = (String) inputMap.get(TEMP_AUTH_ID);
    // //         Boolean addressFromNew = (Boolean) inputMap.get('AddressFromNew');
	// // 		//checking locationId is not blank
	// // 		if (!String.isBlank(recordId)) {
    // //             //if the selected location is from new intake,then throwing exception to not delete
	// // 			if (addressFromNew == true) {
	// // 				throw new LPI_Exception(CANNOT_DELETE_EXISTING_ADDRESS);
	// // 			}
                
	// // 			// querying Temp AuthPlace Record.
	// // 			String locQueryFields = 'ID,Status__c,CloseDate,LocationType';
	// // 			String locWhereClause =
	// // 				'Id =\'' +
	// // 				String.escapeSingleQuotes(recordId) +
	// // 				'\'' +
	// // 				' AND LocationType=\'' +
	// // 				SATELLITE_LOCATION +
	// // 				'\'' +
	// // 				' AND Status__c=\'' +
	// // 				LPI_LiteralConstant.LOCATION_STATUS_CLOSED +
	// // 				'\'' +
	// // 				' AND CloseDate=NULL';
	// // 			List<Schema.Location> locationList = LPI_LocationDAO.getLocationByDymanicQuery(
	// // 				locQueryFields,
	// // 				locWhereClause,
	// // 				null,
	// // 				null,
	// // 				null
	// // 			);
	// // 			if (!locationList.isEmpty()) {
	// // 				//querying AssociatedLocation linked to locationId
	// // 				String assLocWhereClause = 'LocationId =\'' + String.escapeSingleQuotes(recordId) + '\'';
	// // 				List<AssociatedLocation> assLocList = LPI_AssociatedLocationDAO.getAssociatedLocationListByDynamicQuery(
	// // 					new List<String>{ 'Id', 'LocationId' },
	// // 					assLocWhereClause,
	// // 					null,
	// // 					null,
	// // 					null
	// // 				);

	// // 				// delete Temp_AuthApplicationPlace
	// // 				Temp_AuthApplicationPlace__c deleteTaap = new Temp_AuthApplicationPlace__c();
	// // 				deleteTaap.Id = tempAuthId;
	// // 				LPI_WithoutSharingUtility.deleteSObject(deleteTaap);

	// // 				//delete associatedLocation
	// // 				AssociatedLocation deleteAsscLoc = new AssociatedLocation();
	// // 				if (!assLocList.isEmpty()) {
	// // 					deleteAsscLoc.Id = assLocList[0].Id;
	// // 				}
	// // 				LPI_WithoutSharingUtility.deleteSObject(deleteAsscLoc);

	// // 				// delete location linked to Temp_AuthApplicationPlace and when location get deleted then Address also get deleted automatically
	// // 				Schema.Location deleteLoc = new Schema.Location();
	// // 				deleteLoc.Id = recordId;
	// // 				LPI_WithoutSharingUtility.deleteSObject(deleteLoc);
	// // 			}
	// // 		}
	// // 	} catch (Exception e) {
    // //         if (e.getMessage() == CANNOT_DELETE_EXISTING_ADDRESS) {
	// // 			throw new LPI_Exception(CANNOT_DELETE_EXISTING_ADDRESS, e);
	// // 		}
	// // 		LPI_ExceptionManager.logException(CLASS_NAME, DELETE_SATELLITE_LOCATION_DETAILS, e);
	// // 		throw new LPI_Exception('Problem occured in deleting the record please contact admin', e);
	// // 	}
	// // }
	// /**
	//  * @description        : This method is responsible for fetching address list of given locationType
	//  * @author             : Pranaya Etta
	//  * @lastModifiedBy     : Pranaya Etta
	//  * @param locationIds  : locationIds from fetch method
	//  * @param locationType : locationType from fetch method
	//  */
	// private static List<Schema.Address> getAddressList(Set<Id> locationIds, String locationType) {
	// 	List<Schema.Address> addressList = new List<Schema.Address>();
	// 	// Checking whether the locationIds set is empty or not
	// 	if (!locationIds.isEmpty()) {
	// 		//querying address associated with location and of type: locationType
	// 		String addressQueryFields = 'Id,Parent.Name,Parent.Status__c,Parent.CloseDate,Parent.OpenDate,Street,Business_State__c, ParentId,CountryCode,Country,State,City,StateCode, PostalCode,Parent.LocationType,Parent.Address_Not_In_Use__c';
	// 		String addressWhereClause =
	// 			'ParentId IN ' +
	// 			LPI_ServiceUtility.getStringValuesByList(new List<Id>(locationIds)) +
	// 			' AND Parent.LocationType=\'' +
	// 			locationType +
	// 			'\'';
	// 		LPI_AddressDAO.LPI_AddressDAOWithoutSharing addressQuery = new LPI_AddressDAO.LPI_AddressDAOWithoutSharing();
	// 		addressList = addressQuery.getAddressByDymanicQuery(
	// 			addressQueryFields,
	// 			addressWhereClause,
	// 			null,
	// 			null,
	// 			null
	// 		);
	// 	}
	// 	return addressList;
	// }
	// /**
	//  * @description       : This method is responsible for fetching existing sponsoring locations from BusinessLicense
	//  * @author            : Pranaya Etta
	//  * @lastModifiedBy    : Pranaya Etta
	//  * @param blId        : blId from fetch method
	//  */
	// private static Set<Id> getExistingLocationsFromBL(String blId, String locationType) {
	// 	try {
	// 		Set<Id> locationIds = new Set<Id>();
	// 		Set<Id> blPlaceIds = new Set<Id>();
	// 		if (String.isNotBlank(blId)) {
	// 			//querying AuthApplicationPlace to get existing locations for renewal case
	// 			String authFields = 'Id,PlaceId';
	// 			String authWhere = 'AuthorizationId =\'' + String.escapeSingleQuotes(blId) + '\'';
	// 			List<AuthApplicationPlace> authPlaceList = LPI_AuthApplicationPlaceDAO.getAuthApplicationPlaceByDymanicQuery(
	// 				authFields,
	// 				authWhere,
	// 				null,
	// 				null,
	// 				null
	// 			);
	// 			if (!authPlaceList.isEmpty()) {
	// 				for (AuthApplicationPlace auth_AP : authPlaceList) {
	// 					blPlaceIds.add(auth_AP.PlaceId);
	// 				}
	// 				if (!blPlaceIds.isEmpty()) {
	// 					//querying existing location with status=open
	// 					String locFields = 'Id,Status__c,LocationType';
	// 					String locWhere =
	// 						'Id IN ' +
	// 						LPI_ServiceUtility.getStringValuesByList(new List<Id>(blPlaceIds)) +
	// 						' AND Status__c=\'' +
	// 						LPI_LiteralConstant.LOCATION_STATUS_OPEN +
	// 						'\'' +
	// 						' AND LocationType=\'' +
	// 						locationType +
	// 						'\'';
	// 					List<Schema.Location> locList = LPI_LocationDAO.getLocationByDymanicQuery(
	// 						locFields,
	// 						locWhere,
	// 						null,
	// 						null,
	// 						null
	// 					);
	// 					if (!locList.isEmpty()) {
	// 						for (Schema.Location loc : locList) {
	// 							locationIds.add(loc.Id);
	// 						}
	// 					}
	// 				}
	// 			}
	// 		}
	// 		return locationIds;
	// 	} catch (Exception e) {
	// 		LPI_ExceptionManager.logException(CLASS_NAME, FETCH_SPONSORING_LOCATION_DETAILS, e);
	// 		throw new LPI_Exception('Problem occured in fetching', e);
	// 	}
	// }
    // /**
	//  * @description       : This method is responsible for updating location name
	//  * @author            : Pranaya Etta
	//  */
	// private static String updateLocationName(String locationId, String locationType,String name) {
    //     try {
    //         Schema.Location locationRec = new Schema.Location();
    //         locationRec.Id = locationId;
    //         locationRec.Name = name + ' - ' + locationType;
    //         locationId = ((Schema.Location) LPI_DML.doUpdate(locationRec)).Id;
    //         return locationId;
    //     } catch (Exception e) {
	// 		LPI_ExceptionManager.logException(CLASS_NAME, SAVE_SPONSORING_LOCATION_DETAILS, e);
	// 		throw new LPI_Exception('Problem in Saving the sponsoring location details', e);
	// 	}
    // }
    // /**
	//  * @description       : This method is responsible for checking tempAuth
	//  * @author            : Pranaya Etta
	//  */
	// private static String checkForTempAuth(String parId, String locationType) {
    //     try {
    //         String tempAuthApplicationPlaceId;
    //         if(String.isNotBlank(parId)){
    //             String tempAuthPlaceQueryFields = 'ID,Location__r.LocationType';
    //             String tempAuthPlaceWhereClause =
    //                 'Preliminary_Application_Reference__c =\'' +
    //                 String.escapeSingleQuotes(parId) +
    //                 '\'' +
    //                 ' AND Location__r.LocationType =\'' +
    //                 locationType +
    //                 '\'';
    //             List<Temp_AuthApplicationPlace__c> listOfTempPlace = LPI_TempAuthApplicationPlaceDAO.getTempAuthApplicationPlaceByDymanicQuery(
    //                 tempAuthPlaceQueryFields,
    //                 tempAuthPlaceWhereClause,
    //                 null,
    //                 null,
    //                 null
    //             );
    //             if (!listOfTempPlace.isEmpty()) {
    //                 tempAuthApplicationPlaceId = listOfTempPlace[0].Id;
    //             }
    //         }
    //         return tempAuthApplicationPlaceId;
    //     } catch (Exception e) {
	// 		LPI_ExceptionManager.logException(CLASS_NAME, SAVE_SPONSORING_LOCATION_DETAILS, e);
	// 		throw new LPI_Exception('Problem in Saving the sponsoring location details', e);
	// 	}
    // }
}