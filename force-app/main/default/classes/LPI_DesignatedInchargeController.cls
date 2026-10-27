/**
 * @author      : MTX Group Product Team
 * @since       : 3 Feb, 2023
 * @description : This Class Contains methods which are used designated incharge intake flows
 */
global with sharing class LPI_DesignatedInchargeController implements Callable {
	private final static String INDIVIDAULICENSE_APPTYPE = 'Business';
	private final static String ACCOUNT_PERSON_RECORDTYPE = 'PersonAccount';
	private final static String PERSON_INCHARGE = 'Designated Incharge';
	private final static String PERSON_INCHARGE_ADDRESS = 'Person In Charge Address';
	private final static String LOCATION_STATUS_OPEN = 'Open';
	private final static String CHANGE_OF_OWNERSHIP = 'Change of Ownership';
	private final static String NEW_TYPE = 'New';
	private final static String YES = 'Yes';
	private final static String NO = 'No';
	private final static String ACTIVE = 'Active';
	private final static String EFD_BOARD = 'Embalmers & Funeral Directors';
	private final static Set<String> RS_ADMINISTRATOR_RAT = new Set<String>{
		'Real Estate School'
	};
	
	private static RelationshipDataWraapper relData;

	/**
	 * @description This Method is Used to Internally call the invokeMethod.
	 * @author MTX Group Product Team | 01-31-2023
	 * @param action
	 * @param args
	 * @return Object
	 **/
	global Object call(String action, Map<String, Object> args) {
		Map<String, Object> input = (Map<String, Object>) args.get('input');
        Map<String, Object> output = (Map<String, Object>) args.get('output');
        Map<String, Object> options = (Map<String, Object>) args.get('options');
		return invokeMethod(action, input, output, options);
	}

	/**
	 * @author               : MTX Group Product Team
	 * @description       	 : This Method is used to invoke methods from a omnistudio components.
	 * @param methodName     : Method Name
	 * @param inputMap       : Input Parameter Passed from Omniscript
	 * @param outMap         : Output Passed to Omniscript
	 * @param options        : Extra Options passed from Omniscript
	 * @last modified by     : MTX Group Product Team
	 * @last modified date   : 3 Feb,2023
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
			if (methodName.equals('linkDesignatedOwnerDetails')) {
				linkDesignatedOwnerDetails(inputMap, outMap);
			} else if (methodName.equals('fetchRSBDesignatedBrokerName')) {
				fetchRSBDesignatedBrokerName(inputMap, outMap);
			} else if ('getDesignatedInchargeDetails'.equalsIgnoreCase(methodName)) {
				getDesignatedInchargeDetails(inputMap, outMap);
			} else if (methodName.equals('fetchDesignatedInchargeLicNoDetails')) {
				outMap.put('LicNo-Block', fetchDesignatedInchargeLicNoDetails(inputMap));
			} else if (methodName.equals('linkPersonInchargeDetails')) {
				linkPersonInchargeDetails(inputMap, outMap);
			}else if (methodName.equals('fetchPICDetailsFC')) {
				fetchPICDetailsFC(inputMap, outMap);
			}else if (methodName.equals('fetchPICDRDetails')) {
				fetchPICDRDetails(inputMap, outMap);
			}else {
				result = false;
			}
		} catch (Exception e) {
			LPI_ExceptionManager.logException('LPI_DesignatedInchargeController', 'invokeMethod', e);
			throw new AuraHandledException(e.getMessage());
		}
		return result;
	}

	private static Map<String, String> keyMappingForAccount;

	/**
	 * @author                    : MTX Group Product Team
	 * @description               : linking designated incharge to business account
	 * @param inputMap            : fetching all the input from Omniscript
	 * @param outMap              : Passing value to Omniscript
	 * @since                     : 17 Nov 2022
	 * @return                    : `void`
	 * @last modified by          : MTX Group Product Team
	 * @last modified date        : 27th June 2023
	 */
	private static void linkDesignatedOwnerDetails(Map<String, Object> inputMap, Map<String, Object> outMap) {
		try {
			Id businessAccId = (Id) inputMap.get('businessAccId');
			Id parId = (Id) inputMap.get('parId');
			if(parId!=null || String.isNotBlank(businessAccId)){
				List<PreliminaryApplicationRef>	parRecords = LPI_PreliminaryApplicationRefDAO.getPreliminaryApplicationRefByDymanicQuery(
					'Id, Contact__c, How_are_you_associated_to_this_entity__c, Business_License__c, Board_Name__c,Contact__r.AccountId',
					'Id =\'' + parId + '\'',
					'1',
					null,null
				);
				Map<String, object> rsSchoolDetailsStepInfo = (Map<String, object>) inputMap.get('SchoolAdministratorInformation');
				if (rsSchoolDetailsStepInfo!=null && !rsSchoolDetailsStepInfo?.isEmpty()) {
					
					Map<String, object> adminDetails = (Map<String, object>) rsSchoolDetailsStepInfo.get('OwnerBlock');
					LPI_GoogleIntegration.AddressValidationResultWrapper resultWrap = new LPI_GoogleIntegration.AddressValidationResultWrapper();
					outMap.put('errorInAddress',false);
					outMap.put('addressErrorMessage','');
					if(adminDetails != NULL){
						resultWrap = LPI_GoogleIntegration.checkAddressValidation(
							'US', (String) adminDetails.get('AdminCity'),
							new List<String>{
								(String) adminDetails.get('AdminStreet') + ',' +
								(String) adminDetails.get('AdminCity') + ',' + 'US, ' + 
								(String) adminDetails.get('AdminZipCode'),
								(String) adminDetails.get('AdminZipCode')
							}
						);
						
						if(resultWrap.addressValid || resultWrap.skipValidation){
							outMap.put('BusinessAddressLong', resultWrap.longitude);
							outMap.put('BusinessAddressLat',resultWrap.latitude);
						}else{
							outMap.put('errorInAddress',true);
							outMap.put('addressErrorMessage','Administrator Address Validation Failed. Please Provide a Correct Address.');
							return;
						}
					}
				
					Account personAccount = upsertPersonAccount(inputMap, outMap, businessAccId);
					relData = new RelationshipDataWraapper(businessAccId,
														personAccount.Id,
														PERSON_INCHARGE,
														null,null,
														parRecords[0].Business_License__c,
														parRecords[0].Board_Name__c,
														null,null); 
					if (personAccount != null) {
						createRelationshipRecord(
							relData,
							null,
							outMap,
							inputMap
						);
					}
				}
			}
		} catch (Exception e) {
			LPI_ExceptionManager.logException('LPI_ExceptionManager', 'linkDesignatedOwnerDetails', e);
			throw new LPI_Exception(e.getMessage());
		}
	}

	/**
	 * @author                    : MTX Group Product Team
	 * @description               : This method is used to Fetch Designated Broker Details
	 * @param inputMap            : fetching all the input from Omniscript
	 * @param outMap              : Passing value to Omniscript
	 * @since                     : 17 Nov 2022
	 * @return                    : `void`
	 * @last modified date        : MTX Group Product Team
	 * @last modified date        : 27th June 2023
	 */
	public static void fetchRSBDesignatedBrokerName(Map<String, Object> inputMap, Map<String, Object> outMap) {
		try {
			Id parId = (Id) inputMap.get('parId');
			if(parId!=null){
				list<PreliminaryApplicationRef> parList = LPI_PreliminaryApplicationRefDAO.getPreliminaryApplicationRefByDymanicQuery(
					'Id, BusinessAccountNameId, Type__c, Business_License__c,Regulatory_Authorization_Type__c,Regulatory_Authorization_Type__r.Name,' +
					'How_are_you_associated_to_this_entity__c,Regulatory_Authorization_Type__r.IssuingDepartment.Name, Board_Name__c,'+
					'Business_License__r.Is_Migrated_Data__c',
					'Id =\'' + parId + '\'',
					'1',
					null,null
				);
				if(!parList.isEmpty()){
					outMap.put('parType',parList[0].Type__c);
					Boolean isReadOnlyStep = (Boolean) inputMap.get('isReadOnlyStep');
					
					LPI_BusinessRelationshipDAO.LPI_BusinessRelationshipsWithoutSharingDAO acrQuery = new LPI_BusinessRelationshipDAO.LPI_BusinessRelationshipsWithoutSharingDAO();
					List<Business_Relationships__c> acrList = acrQuery.getBusinessRelationshipsByDymanicQuery(
						'Id, Related_To__r.Name,License_Number__c, Related_To__r.Date_of_Birth__c, Is_Licensed_Entity__c,' +
						' Related_To__r.FirstName, Related_To__r.LastName, Related_To__r.MiddleName,Related_To__r.Fax,Employment_Status__c,' +
						' Related_To__r.PersonOtherCity, Related_To__r.Phone, Related_To__r.PersonOtherStateCode,Related_To_License_Number__r.License_Number_With_Rat_Name__c,' +
						' Related_To__r.PersonHomePhone, Related_To__r.PersonOtherStreet,Related_To__r.PersonOtherPostalCode,Related_To__r.PersonBirthdate,' +
						' Related_To__r.PersonEmail, Related_To__r.PersonContactId, Related_To__c, Related_To__r.PersonOtherState, Related_To__r.Social_Security_Number__c,' +
						' Highest_level_of_school_completed__c, Date_of_Completion__c, School__c, School_City__c, School_State__c, School_Country__c,'+
						' Related_To_License_Number__r.Business_Entity_Name__c, Related_To_License_Number__r.Legacy_License_Number__c,Related_To_License_Number__r.Name, Related_To_License_Number__r.Issuing_Department_Name__c, Person_Incharge_Email__c,Related_To__r.County__c',
						' Related_From__c =\'' + parList[0].BusinessAccountNameId +
						'\' AND Roles__c = \'' + PERSON_INCHARGE + '\' AND EndDate__c =null',
						null,null,null
						);
					if(!acrList.isEmpty()){
						if(acrList[0].Is_Licensed_Entity__c!=null){
							outMap.put('IsThePersonInChargeLicensedinMissouri', acrList[0].Is_Licensed_Entity__c);
							outMap.put('IsThePersonInChargeLicensedinMissouriRO', acrList[0].Is_Licensed_Entity__c);
							outMap.put('IsThePersonInChargeLicensedinMissouriPIPFI', acrList[0].Is_Licensed_Entity__c);
							outMap.put('IsThePersonInChargeLicensedinMissouriROPIPFI', acrList[0].Is_Licensed_Entity__c);
							outMap.put('IsThePersonInChargeLicensedinMissouriRORealEstate', acrList[0].Is_Licensed_Entity__c);
							outMap.put('IsThePersonInChargeLicensedinMissouriRealEstate', acrList[0].Is_Licensed_Entity__c);			
						}
						if(acrList[0].Employment_Status__c!=null){
							outMap.put('EmploymentStatusCorporation', acrList[0].Employment_Status__c);
							outMap.put('EmploymentStatusLLC', acrList[0].Employment_Status__c);
						}
						
						if (acrList[0].Is_Licensed_Entity__c == 'Yes' && 
						(parList[0].Type__c=='New' || parList[0].Type__c==CHANGE_OF_OWNERSHIP || parList[0].Business_License__r.Is_Migrated_Data__c==true)) {
							outMap.put('DesignatedInchargeFirstName', acrList[0].Related_To__r.FirstName);
							outMap.put('DesignatedInchargeMiddleName', acrList[0].Related_To__r.MiddleName);
							outMap.put('DesignatedInchargeLastName', acrList[0].Related_To__r.LastName);
							outMap.put('DesignatedInchargePhoneNumber', acrList[0].Related_To__r.Phone);
							
								outMap.put('DesignatedInchargeEmail', acrList[0].Related_To__r.PersonEmail);

							
							if(parList[0].How_are_you_associated_to_this_entity__c == 'Temporary Clerk'){
								outMap.put('DesignatedInchargeSSN','*********');
							}else{
								outMap.put('DesignatedInchargeSSN', acrList[0].Related_To__r.Social_Security_Number__c);
							}
							
							outMap.put('DesignatedInchargeFaxNumber', acrList[0].Related_To__r.Fax);
							
							outMap.put('RelationRecordId', acrList[0].Id);
							if(parList[0].Regulatory_Authorization_Type__r.IssuingDepartment.Name == EFD_BOARD){
								outMap.put('LicNo', acrList[0].Related_To_License_Number__r.Legacy_License_Number__c!=null ? acrList[0].Related_To_License_Number__r.Business_Entity_Name__c + ' - ' + acrList[0].Related_To_License_Number__r.Legacy_License_Number__c + ' - ' + acrList[0].Related_To_License_Number__r.Issuing_Department_Name__c:
								acrList[0].Related_To_License_Number__r.Business_Entity_Name__c + '-' + acrList[0].Related_To_License_Number__r.License_Number_With_Rat_Name__c);
							}
							else{
								outMap.put('LicNo', acrList[0].Related_To_License_Number__r.License_Number_With_Rat_Name__c);
							}
							outMap.put('Name', acrList[0].License_Number__c);
							Schema.Address tempAddress = fetchAddress(parList[0].Id, PERSON_INCHARGE_ADDRESS);
							if (tempAddress != null) {
								outMap.put('LocationId', tempAddress.ParentId);
								outMap.put('DesignatedInchargeMailingStreetAddress', tempAddress.Street);
								outMap.put('DesignatedInchargeMailingCity', tempAddress.City);
								outMap.put('DesignatedInchargeMailingCountry', tempAddress.Country);
								outMap.put('DesignatedInchargeMailingCounty', tempAddress.County__c);
								outMap.put('DesignatedInchargeMailingZipCode', tempAddress.PostalCode);
								if (tempAddress.CountryCode == 'US') {
									outMap.put('DesignatedInchargeMailingState', tempAddress.State);
								} else {
									outMap.put('DesignatedInchargeMailingState', tempAddress.Business_State__c);
								}
							}
						}
						
						else if (acrList[0].Is_Licensed_Entity__c == 'No' && 
								(parList[0].Type__c=='New' || parList[0].Type__c==CHANGE_OF_OWNERSHIP || parList[0].Business_License__r.Is_Migrated_Data__c==true)) {
							outMap.put('NonLicensedPICFirstName', acrList[0].Related_To__r.FirstName);
							outMap.put('NonLicensedPICMiddleName', acrList[0].Related_To__r.MiddleName);
							outMap.put('NonLicensedPICLastName', acrList[0].Related_To__r.LastName);
							outMap.put('NonLicensedPICPhoneNumber', acrList[0].Related_To__r.Phone);
							outMap.put('NonLicensedPICEmail', acrList[0].Related_To__r.PersonEmail);
							outMap.put('NonLicensedPICSSN', acrList[0].Related_To__r.Social_Security_Number__c);
							outMap.put('NonLicensedPICFaxNumber', acrList[0].Related_To__r.Fax);
							outMap.put('NonLicensedPICDoB', acrList[0].Related_To__r.Date_of_Birth__c);
							outMap.put('PersonAccountIdPIC',acrList[0].Related_To__c);
							outMap.put('RelationRecordId', acrList[0].Id);
							outMap.put('NonLicensedPICLicenseNumber', acrList[0].License_Number__c);
							outMap.put('ApplicantDesignatedInchargeLicenseNumber', acrList[0].License_Number__c);
							Schema.Address tempAddress = fetchAddress(parList[0].Id, PERSON_INCHARGE_ADDRESS);
							if (tempAddress != null) {
								outMap.put('LocationId', tempAddress.ParentId);
								outMap.put('NonLicensedPICCity', tempAddress.City);
								outMap.put('NonLicensedPICStreetAddress', tempAddress.Street);
								outMap.put('NonLicensedPICCountry', tempAddress.CountryCode);
								outMap.put('NonLicensedPICCountryFC', tempAddress.Country);
								outMap.put('NonLicensedPICUSZipCode', tempAddress.PostalCode);
								outMap.put('NonLicensedPICCounty', tempAddress.County__c);
								if (tempAddress.CountryCode == 'US') {
									outMap.put('NonLicensedPICUSState', tempAddress.StateCode);
									outMap.put('NonLicensedPICUSStateFC', tempAddress.State);
								} else {
									outMap.put('NonLicensedPICNonUSState', tempAddress.Business_State__c);
								}
							}
						}
						
						else if (isReadOnlyStep != null && isReadOnlyStep && parList[0].Type__c!=NEW_TYPE) {
							outMap.put('DesignatedBrokerNameRO', acrList[0].Related_To__r.Name);
							outMap.put('DesignatedBrokerFirstNameRO', acrList[0].Related_To__r.FirstName);
							outMap.put('DesignatedBrokerMiddleNameRO', acrList[0].Related_To__r.MiddleName);
							outMap.put('DesignatedBrokerLastNameRO', acrList[0].Related_To__r.LastName);
							outMap.put('ApplicantDesignatedInchargePhoneNumberRO', acrList[0].Related_To__r.Phone);
							outMap.put('ApplicantDesignatedInchargePhoneRO', acrList[0].Related_To__r.PersonHomePhone);
							outMap.put('HomeAddressStreetRO', acrList[0].Related_To__r.PersonOtherStreet);
							outMap.put('HomeAddressCityRO', acrList[0].Related_To__r.PersonOtherCity);
							outMap.put('HomeAddressStateRO', acrList[0].Related_To__r.PersonOtherState);
							outMap.put('HomeAddressZipcodeRO', acrList[0].Related_To__r.PersonOtherPostalCode);
							outMap.put('AdministratorEmailRO', acrList[0].Related_To__r.PersonEmail);
						}
						
						else if(RS_ADMINISTRATOR_RAT.contains(parList[0].Regulatory_Authorization_Type__r.Name)){
							outMap.put('DesignatedInchargeFirstName', acrList[0].Related_To__r.FirstName);
							outMap.put('DesignatedInchargeMiddleName', acrList[0].Related_To__r.MiddleName);
							outMap.put('DesignatedInchargeLastName', acrList[0].Related_To__r.LastName);
							outMap.put('AdministratorEmail', acrList[0].Related_To__r.PersonEmail);
							outMap.put('HomeAddressZipcode', acrList[0].Related_To__r.PersonOtherPostalCode);
							outMap.put('HomeAddressCounty', acrList[0].Related_To__r.County__c);
							outMap.put('HomeAddressState', acrList[0].Related_To__r.PersonOtherState);
							outMap.put('HomeAddressCity', acrList[0].Related_To__r.PersonOtherCity);
							outMap.put('HomeAddressStreet', acrList[0].Related_To__r.PersonOtherStreet);
							outMap.put('DesignatedInchargePhoneNumber', acrList[0].Related_To__r.Phone);
							outMap.put('ApplicantDesignatedInchargePhone', acrList[0].Related_To__r.PersonHomePhone);
						}
						
						else if(parList[0].Type__c!=NEW_TYPE){
							if(acrList[0].Is_Licensed_Entity__c == YES){
								if(parList[0].Regulatory_Authorization_Type__r.IssuingDepartment.Name == EFD_BOARD){
									outMap.put('ROLicNo', acrList[0].Related_To_License_Number__r.Legacy_License_Number__c!=null ? acrList[0].Related_To_License_Number__r.Business_Entity_Name__c + ' - ' + acrList[0].Related_To_License_Number__r.Legacy_License_Number__c + ' - ' + acrList[0].Related_To_License_Number__r.Issuing_Department_Name__c:
									acrList[0].Related_To_License_Number__r.Business_Entity_Name__c + '-' + acrList[0].Related_To_License_Number__r.License_Number_With_Rat_Name__c);
								}
								else{
									outMap.put('ROLicNo', acrList[0].Related_To_License_Number__r.License_Number_With_Rat_Name__c);
								}
							}else if(acrList[0].Is_Licensed_Entity__c == NO){
								outMap.put('ROLicNo',acrList[0].License_Number__c);
							}
							outMap.put('DesignatedInchargeFirstNameRO', acrList[0].Related_To__r.FirstName);
							outMap.put('DesignatedInchargeMiddleNameRO', acrList[0].Related_To__r.MiddleName);
							outMap.put('DesignatedInchargeLastNameRO', acrList[0].Related_To__r.LastName);
							outMap.put('DesignatedInchargeDOBRO', acrList[0].Related_To__r.Date_of_Birth__c);
							outMap.put('DesignatedInchargeSSNRO', acrList[0].Related_To__r.Social_Security_Number__c);
							outMap.put('DesignatedInchargePhoneNumberRO', acrList[0].Related_To__r.Phone);
							outMap.put('DesignatedInchargeFaxNumberRO', acrList[0].Related_To__r.Fax);
							outMap.put('DesignatedInchargeEmailRO', acrList[0].Related_To__r.PersonEmail);
							Schema.Address tempBlAddress = fetchBlAddress(parList[0].Business_License__c, PERSON_INCHARGE_ADDRESS);
							if (tempBlAddress != null) {
								outMap.put('DesignatedInchargeCityRO', tempBlAddress.City);
								outMap.put('DesignatedInchargeStreetAddressRO', tempBlAddress.Street);
								outMap.put('DesignatedInchargeCountryRO', tempBlAddress.Country);
								outMap.put('DesignatedInchargeZipCodeRO', tempBlAddress.PostalCode);
								outMap.put('DesignatedInchargeCountyRO', tempBlAddress.County__c);
								if (tempBlAddress.Country == 'United States') {
									outMap.put('DesignatedInchargeStateRO', tempBlAddress.State);
								} else {
									outMap.put('DesignatedInchargeStateRO', tempBlAddress.Business_State__c);
								}
							}
						}
						
					}
				}
			}
		} catch (Exception e) {
			LPI_ExceptionManager.logException('LPI_ExceptionManager','fetchRSBDesignatedBrokerName',e);
			throw new LPI_Exception(e.getMessage());
		}
	}

	/**
	 * @author                      : MTX Group Product Team
	 * @since                       : 18 Jan 2023
	 * Description                  : upserting Person Account for  School
	 * @param inputMap              : Input data passed from OmniScript
	 * @param return                : returning list of account
	 * @last modified by            : MTX Group Product Team
	 * @last modified date          : 03 Feb 2023
	 * @last modified details       : Beautified the code with proper indentation
	 */
	public static Account upsertPersonAccount(Map<String, Object> inputMap, Map<String, Object> outMap, String accountId) {
		List<Account> accountReturnList = new List<Account>();
		Map<String, object> adminDetails = new Map<String, object>();

		Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
			.get(ACCOUNT_PERSON_RECORDTYPE)
			.getRecordTypeId();

		Map<String, object> designatedBrokerDetailsStepInfo = (Map<String, object>) inputMap.get('SchoolAdministratorInformation');
		Map<String, object> picDetailsStepInfo = (Map<String, object>) inputMap.get('DesignatedBrokerDetails');
		Map<String, object> picAmendmentDetailsStepInfo = (Map<String, object>) inputMap.get('DesignatedInchargeInformation');
		if (picDetailsStepInfo!=null && !picDetailsStepInfo.isEmpty()) {
			adminDetails = (Map<String, object>) picDetailsStepInfo.get('NonLicensedPICDetails');
			if (adminDetails!=null && !adminDetails.isEmpty()) {
			keyMappingForAccount = new Map<String, String>{
					'NonLicensedPICEmail' => 'PersonEmail',
					'NonLicensedPICFirstName' => 'FirstName',
					'NonLicensedPICMiddleName' => 'MiddleName',
					'NonLicensedPICLastName' => 'LastName',
					'NonLicensedPICDoB' => 'Date_of_Birth__c',
					'NonLicensedPICPhoneNumber' => 'Phone',
					'NonLicensedPICFaxNumber' => 'Fax'
				};
			}
		} else if (designatedBrokerDetailsStepInfo!=null && !designatedBrokerDetailsStepInfo?.isEmpty()) {
			adminDetails = (Map<String, object>) designatedBrokerDetailsStepInfo.get('OwnerBlock');
			if (adminDetails!=null && !adminDetails.isEmpty()) {
				keyMappingForAccount = new Map<String, String>{
					'AdminEmail' => 'PersonEmail',
					'AdminTelephone' => 'PersonHomePhone',
					'AdminMobile' => 'Phone',
					'AdministratorFirstName' => 'FirstName',
					'AdministratorMiddleName' => 'MiddleName',
					'AdministratorLastName' => 'LastName'
				};
			}
		} else if (picAmendmentDetailsStepInfo!=null && !picAmendmentDetailsStepInfo?.isEmpty()) {
			adminDetails = (Map<String, object>) picAmendmentDetailsStepInfo.get('NewDesignatedInchargeUnlicensed');
			if (adminDetails!=null && !adminDetails.isEmpty()) {
				keyMappingForAccount = new Map<String, String>{
					'UnlicensedNewDesignatedInchargeEmail' => 'PersonEmail',
					'UnlicensedNewDesignatedInchargeFirstName' => 'FirstName',
					'UnlicensedNewDesignatedInchargeMiddleName' => 'MiddleName',
					'UnlicensedNewDesignatedInchargeLastName' => 'LastName',
					'UnlicensedNewDesignatedInchargeDoB' => 'Date_of_Birth__c',
					'UnlicensedNewDesignatedInchargePhoneNumber' => 'Phone'
				};
			}
		}
		if(adminDetails==null || adminDetails.isEmpty()){
			return null;
		}
		List<String> accountFieldsToQuery = new List<String>{
			'Id',
			'PersonContactId',
			'Name',
			'PersonOtherStateCode',
			'PersonOtherCity',
			'PersonOtherPostalCode',
			'PersonOtherStreet',
			'PersonEmail',
			'PersonBirthdate',
			'PersonHomePhone',
			'Phone',
			'Date_of_Birth__c',
			'Social_Security_Number__c'
		};
		Account personAccount = (Account) LPI_VlocityUtility.createSObject(adminDetails,keyMappingForAccount,'Account');
		personAccount.FirstName = String.isNotBlank(personAccount.FirstName)
			? personAccount.FirstName.trim()
			: personAccount.FirstName;
		personAccount.LastName = String.isNotBlank(personAccount.LastName)
			? personAccount.lastName.trim()
			: personAccount.LastName;
		personAccount.MiddleName = String.isNotBlank(personAccount.MiddleName)
			? personAccount.MiddleName.trim()
			: personAccount.MiddleName;
		personAccount.Combined_Name__pc = String.isNotBlank(personAccount.FirstName) &&
			String.isNotBlank(personAccount.MiddleName)
			? personAccount.FirstName + ' ' + personAccount.MiddleName + ' ' + personAccount.LastName
			: String.isNotBlank(personAccount.FirstName)
					? personAccount.FirstName + ' ' + personAccount.LastName
					: String.isNotBlank(personAccount.MiddleName)
							? personAccount.MiddleName + ' ' + personAccount.LastName
							: personAccount.LastName;
		personAccount.RecordTypeId = accRecordTypeId;
		if (designatedBrokerDetailsStepInfo != null && !designatedBrokerDetailsStepInfo?.isEmpty()) {
			adminDetails = (Map<String, object>) designatedBrokerDetailsStepInfo.get('OwnerBlock');			
			Map<String, object> zipCityCountyMap = (Map<String, object>) adminDetails.get('AdminInfoCityCountyZip');
			personAccount.PersonOtherStreet = (String)zipCityCountyMap?.get('AdminStreet');
			personAccount.PersonOtherStateCode = (String) zipCityCountyMap?.get('AdminState');
			personAccount.PersonOtherPostalCode = (String) zipCityCountyMap?.get('AdminZipCode');
			personAccount.PersonOtherCity = (String) zipCityCountyMap?.get('AdminCity');
			personAccount.County__c = (String) zipCityCountyMap?.get('AdminCounty');
			personAccount.PersonOtherCountryCode = 'US';

		}
		
		List<Datacloud.MatchRecord> existingAccountId = new List<Datacloud.MatchRecord>();
		existingAccountId = LPI_WithoutSharingUtility.getDuplicateRecordsService(new List<Account>{ personAccount });
		
		if (!existingAccountId.isEmpty()) {
			personAccount.Id = existingAccountId[0].getRecord().Id;
		}
		LPI_WithoutSharingUtility.upsertSObject(personAccount);
		accountReturnList = new LPI_AccountDAO.LPI_AccountWithoutSharingDAO()
			.getAccountByDymanicQuery(
				String.join(accountFieldsToQuery, ','),
				'Id = \'' + String.escapeSingleQuotes(personAccount.Id) + '\'',
				'1',
				null,null
			);
		String accId = accountReturnList[0].Id;
		outMap.put('PersonAccountIdPIC',accId);
		outMap.put('PersonAccountSSN',personAccount.Social_Security_Number__c);
		return accountReturnList[0];
	}

	/**
	 * @author                       : MTX Group Product Team
	 * @since                        : Dec 20, 2022
	 * @description                  : get Designate Incharge Details
	 * @param inputMap               : input map
	 * @param outMap                 : output map
	 * @return                       : void
	 */
	private static Map<String, Object> getDesignatedInchargeDetails(
		Map<String, Object> inputMap,
		Map<String, Object> outMap
	) {
		List<Business_Relationships__c> listOfACR = new List<Business_Relationships__c>();
		List<PreliminaryApplicationRef> parList = new List<PreliminaryApplicationRef>();
		Id parid = String.isNotBlank((String) inputMap.get('parId')) ? (Id) inputMap.get('parId') : null;
		if (parid != null) {
			parList = LPI_PreliminaryApplicationRefDAO.getPreliminaryApplicationRefByDymanicQuery(
				'Id, BusinessAccountNameId',
				'Id = \'' + parid + '\'',
				'1',
				null,null
			);
			if (!parList.isEmpty() && String.isNotBlank(parList.get(0).BusinessAccountNameId)) {
				String relatedFromAccountId = parList.get(0).BusinessAccountNameId;
				Map<String, String> businessAccountMap = new Map<String, String>();
				
				LPI_BusinessRelationshipDAO.LPI_BusinessRelationshipsWithoutSharingDAO instance = new LPI_BusinessRelationshipDAO.LPI_BusinessRelationshipsWithoutSharingDAO();
				listOfACR = instance.getBusinessRelationshipsByDymanicQuery(
					'Id, Related_To__c, Related_To__r.Name, Related_To__r.PersonHomePhone,' +
					' Related_To__r.Phone, Related_To__r.PersonOtherStreet, Related_To__r.PersonOtherCity,' +
					' Related_To__r.PersonOtherStateCode, Related_To__r.PersonOtherPostalCode,' +
					' Related_To__r.PersonEmail, Related_To__r.FirstName, Related_To__r.MiddleName, Related_To__r.LastName, Related_To__r.County__c',
					'Related_From__c = \'' + relatedFromAccountId + '\'' +
					' AND Roles__c = \'' + PERSON_INCHARGE + '\'' + 
					' AND EndDate__c = null',
					null,null,null
				);
				if (!listOfACR.isEmpty()) {
					Account acc = listOfACR[0].Related_To__r;
					businessAccountMap.put('AdministratorName', acc?.Name);
					businessAccountMap.put('AdminTelephone', acc?.PersonHomePhone);
					businessAccountMap.put('AdminMobile', acc?.Phone);
					businessAccountMap.put('AdminStreet', acc?.PersonOtherStreet);
					businessAccountMap.put('AdminCity', acc?.PersonOtherCity);
					businessAccountMap.put('AdminState', acc?.PersonOtherStateCode);
					businessAccountMap.put('AdminZipCode', acc?.PersonOtherPostalCode);
					businessAccountMap.put('AdminCounty', acc?.County__c);
					businessAccountMap.put('AdminEmail', acc?.PersonEmail);
					businessAccountMap.put('AdministratorFirstName', acc?.FirstName);
					businessAccountMap.put('AdministratorMiddleName', acc?.MiddleName);
					businessAccountMap.put('AdministratorLastName', acc?.LastName);
					outMap.put('SchoolAdministratorInformation', businessAccountMap);
					outMap.put('RelationRecordId', acc.Id);
				}
			}
		}
		return outMap;
	}

	/**
	 * @author                       : MTX Group Product Team
	 * @since                        : Mar 06, 2023
	 * @description                  : get Designate Incharge License Number Details
	 * @param inputMap               : input map
	 * @param outMap                 : output map
	 * @return                       : void
	 */
	public static List<Map<String, object>> fetchDesignatedInchargeLicNoDetails(Map<String, Object> inputMap) {
		List<Map<String, Object>> licenseList = new List<Map<String, Object>>();
            try {
                Id parId = (Id) inputMap.get('parid');
				if(parId!=null){
					String entityLicenseNumber = '%' + (String) inputMap.get('LicNo') + '%';
					if(entityLicenseNumber != null || entityLicenseNumber?.length()<=4) {
						String regAuthTypeName = inputMap.containsKey('regAuthTypeName') ? (String) inputMap.get('regAuthTypeName') : '';
						String boardName = inputMap.containsKey('boardName') ? (String) inputMap.get('boardName') : '';
						List<PreliminaryApplicationRef> parList = LPI_PreliminaryApplicationRefDAO.getPreliminaryApplicationRefByDymanicQuery(
							'Id, Contact__r.AccountId,How_are_you_associated_to_this_entity__c,Regulatory_Authorization_Type__r.IssuingDepartmentId, Regulatory_Authorization_Type__r.IssuingDepartment.Name',
							'Id = \'' + parId + '\'',
							'1',
							null,null
							);
						if (!parList.isEmpty()) {
							String blFields =
								'Id, Name, First_Name__c, Last_Name__c, Middle_Name__c, AccountId, Account.Phone, Account.Fax, License_Number_With_Rat_Name__c, Business_Entity_Name__c,' +
								'Account.PersonContactId, Account.Date_of_Birth__c, Account.PersonEmail, Account.Social_Security_Number__c,Account.Name, Primary_Contact_Address__c,Legacy_License_Number__c, Issuing_Department_Name__c';
							String blWhereClause =
								' RegulatoryAuthorizationType.Authorisation_Type__c= \'' + INDIVIDAULICENSE_APPTYPE + '\'' +
								' AND Status = \'' + ACTIVE + '\'' +
								' AND RegulatoryAuthorizationType.IssuingDepartmentId = \'' + parList[0].Regulatory_Authorization_Type__r.IssuingDepartmentId + '\'';
							if(parList[0].Regulatory_Authorization_Type__r.IssuingDepartment.Name == EFD_BOARD){ 
								blWhereClause = blWhereClause + ' AND ( Business_Entity_Name__c LIKE \'' + String.escapeSingleQuotes(entityLicenseNumber) + '\'' +
																' OR Name LIKE \'' + String.escapeSingleQuotes(entityLicenseNumber)+ '\')';
							}else{
								blWhereClause = blWhereClause + ' AND Name LIKE \'' + String.escapeSingleQuotes(entityLicenseNumber) + '\'';
							}
							
							Map<Id,String> blIdToPrimaryContactAddressMap = new Map<Id,String>();
							LPI_BusinessLicenseDAO.LPI_BusinessLicenseWithoutSharingDAO bLListWithOutSharing = new LPI_BusinessLicenseDAO.LPI_BusinessLicenseWithoutSharingDAO();
							List<BusinessLicense> blList = bLListWithOutSharing.getBusinessLicenseByDymanicQuery(blFields, blWhereClause, '10', null, null);
							for(BusinessLicense tempBl : blList){
								blIdToPrimaryContactAddressMap.put(tempBl.Id,tempBl.Primary_Contact_Address__c);
							}
							Map <Id,Schema.Address> blIdToAddressMap = getAddress(blIdToPrimaryContactAddressMap);
							Map<String, Object> licenseMap = new Map<String, Object>();
							for (BusinessLicense bl : blList) {
								
								
								licenseMap.put('LicNoblId', bl.Id);
								licenseMap.put('Name', bl.Name);
								if(parList[0].Regulatory_Authorization_Type__r.IssuingDepartment.Name == EFD_BOARD){
									licenseMap.put('TypeaheadKeyName', bl.Legacy_License_Number__c!=null ? bl.Business_Entity_Name__c + '-' + bl.Legacy_License_Number__c + '-' + bl.Issuing_Department_Name__c:
									bl.Business_Entity_Name__c + '-' + bl.License_Number_With_Rat_Name__c);
								}
								else{
									licenseMap.put('TypeaheadKeyName', bl.License_Number_With_Rat_Name__c);
								}
								licenseMap.put('DesignatedInchargeFirstName', bl.First_Name__c);
								licenseMap.put('DesignatedInchargeMiddleName', bl.Middle_Name__c);
								licenseMap.put('DesignatedInchargeLastName', bl.Last_Name__c);
								
								licenseMap.put('DesignatedInchargePhoneNumber', bl.Account.Phone);
								licenseMap.put('PersonAccountContactName', bl.Account.Name);
								licenseMap.put('DesignatedInchargeEmail', bl.Account.PersonEmail);
								
								if(bl.Account.Social_Security_Number__c != NULL && 
									parList[0].How_are_you_associated_to_this_entity__c == 'Temporary Clerk'){
									licenseMap.put('DesignatedInchargeSSN', '*********');
								}else{
									licenseMap.put('DesignatedInchargeSSN', bl.Account.Social_Security_Number__c);
								}
								
								licenseMap.put('DesignatedInchargeFaxNumber', bl.Account.Fax);
								licenseMap.put('AccountId', bl.AccountId);		
								if(blIdToAddressMap.containsKey(bl.Id)){
									licenseMap.put('DesignatedInchargeMailingStreetAddress',blIdToAddressMap.get(bl.Id).Street);
									licenseMap.put('DesignatedInchargeMailingCity',blIdToAddressMap.get(bl.Id).City);
									licenseMap.put('DesignatedInchargeMailingCountry',blIdToAddressMap.get(bl.Id).Country);
									if(blIdToAddressMap.get(bl.Id).Country == 'United States'){
										licenseMap.put('DesignatedInchargeMailingState',blIdToAddressMap.get(bl.Id).State);
										licenseMap.put('DesignatedInchargeMailingStateCode',blIdToAddressMap.get(bl.Id).StateCode);
									}else{
										licenseMap.put('DesignatedInchargeMailingState',blIdToAddressMap.get(bl.Id).Business_State__c);
									}
									licenseMap.put('DesignatedInchargeMailingCountryCode',blIdToAddressMap.get(bl.Id).CountryCode);
									licenseMap.put('DesignatedInchargeMailingCounty',blIdToAddressMap.get(bl.Id).County__c);
									licenseMap.put('DesignatedInchargeMailingZipCode',blIdToAddressMap.get(bl.Id).PostalCode);
									licenseMap.put('DesignatedInchargeMailingId',blIdToAddressMap.get(bl.Id).Id);
								}	
								licenseList.add(licenseMap);
							}							
						}
					}
				}
            } catch (Exception e) {
                LPI_ExceptionManager.logException('LPI_ExceptionManager','fetchDesignatedInchargeLicNoDetails',e);
                throw new LPI_Exception(e.getMessage());
            }
            return licenseList;
	}

	/**
	 * @author                       : MTX Group Product Team
	 * @since                        : June 12, 2023
	 * @description                  : link Designated Incharge Details
	 * @param inputMap               : input map
	 * @param outMap                 : output map
	 * @return                       : void
	 */
	private static void linkPersonInchargeDetails(Map<String, Object> inputMap, Map<String, Object> outMap) {
		try {
			Id parId = (Id) inputMap.get('parId');
			if(parId==null){
				return;
			}
			Id designatedOwnerAccountId;
			String designatedOwnerAccountName = '';
			String licensedInMissouri = YES;
			String designatedOwnerLicenseNum;
			String designatedOwnerLicenseNumberId;
			String ssn = '';
			String employmentStatus = '';
			Boolean zipLengthCheck = false;
			List<PreliminaryApplicationRef> parRecords = LPI_PreliminaryApplicationRefDAO.getPreliminaryApplicationRefByDymanicQuery(
				'Id, How_are_you_associated_to_this_entity__c, Business_License__c, Board_Name__c, Contact__r.AccountId, Contact__r.Account.Name,' +
				' BusinessAccountNameId, Regulatory_Authorization_Type__r.Name',
				'Id =\'' + parId + '\'',
				'1',
				null,null
			);
			Map<String, object> schoolBlockInfo = new Map<String, object>();
			Map<String, object> designatedBrokerDetailsStepInfo = (Map<String, object>) inputMap.get('DesignatedBrokerDetails');
			if(!designatedBrokerDetailsStepInfo.isEmpty() && designatedBrokerDetailsStepInfo!=null){
				
				if(String.isNotBlank((String) designatedBrokerDetailsStepInfo.get('NeedPIC'))){
					String picVal = (String) designatedBrokerDetailsStepInfo.get('NeedPIC');
					upsertNeedPICInformation(parId,picVal);
				}
				if(String.isNotBlank((String) designatedBrokerDetailsStepInfo.get('IsThePersonInChargeLicensedinMissouri'))){
					licensedInMissouri = (String) designatedBrokerDetailsStepInfo.get('IsThePersonInChargeLicensedinMissouri');
				}else if(String.isNotBlank((String) designatedBrokerDetailsStepInfo.get('IsThePersonInChargeLicensedinMissouriPIPFI'))){
					licensedInMissouri = (String) designatedBrokerDetailsStepInfo.get('IsThePersonInChargeLicensedinMissouriPIPFI');
				} else if(String.isNotBlank((String) designatedBrokerDetailsStepInfo.get('IsThePersonInChargeLicensedinMissouriRO'))){
					licensedInMissouri = (String) designatedBrokerDetailsStepInfo.get('IsThePersonInChargeLicensedinMissouriRO');
				}else if(String.isNotBlank((String) designatedBrokerDetailsStepInfo.get('IsThePersonInChargeLicensedinMissouriROPIPFI'))){
					licensedInMissouri = (String) designatedBrokerDetailsStepInfo.get('IsThePersonInChargeLicensedinMissouriROPIPFI');
				}else if(String.isNotBlank((String) designatedBrokerDetailsStepInfo.get('IsThePersonInChargeLicensedinMissouriRealEstate'))){
					licensedInMissouri = (String) designatedBrokerDetailsStepInfo.get('IsThePersonInChargeLicensedinMissouriRealEstate');
				}else if(String.isNotBlank((String) designatedBrokerDetailsStepInfo.get('IsThePersonInChargeLicensedinMissouriRORealEstate'))){
					licensedInMissouri = (String) designatedBrokerDetailsStepInfo.get('IsThePersonInChargeLicensedinMissouriRORealEstate');
				}
				Map<String, object> mailingAddressBlockInfo = (Map<String, object>) designatedBrokerDetailsStepInfo.get('PICMailingAddressInfoBlock');
				if(mailingAddressBlockInfo!=null && !mailingAddressBlockInfo.isEmpty()){
					String mailingCountry = (String) mailingAddressBlockInfo.get('NonLicensedPICCountry');
					String mailingZipCode = (String) mailingAddressBlockInfo.get('NonLicensedPICUSZipCode');
					outMap.put('zipLengthCheck',false);
					if(mailingCountry=='US'){
						Integer zipLength = mailingZipCode.length();
						if(zipLength!=5){
							outMap.put('zipLengthCheck',true);
							return;
						}
					}
			    }
				Map<String, object> employmentStatusBlock = (Map<String, object>) designatedBrokerDetailsStepInfo.get('PICEmploymentStatusAPEPLSPLA');
				if(employmentStatusBlock!=null && !employmentStatusBlock.isEmpty()){
					if((String) employmentStatusBlock.get('EmploymentStatusCorporation') != null){
						employmentStatus = (String) employmentStatusBlock.get('EmploymentStatusCorporation');
					}else{
						employmentStatus = (String) employmentStatusBlock.get('EmploymentStatusLLC');
					}
				}
				
				Map<String, object> licenseNumberBlock = (Map<String, object>) designatedBrokerDetailsStepInfo.get('LicNo-Block');
				Map<String, object> nonlicensdNumberBlock = (Map<String, object>) designatedBrokerDetailsStepInfo.get('NonLicensedPICDetails');
				Map<String, object> personInchargelicensdNumberBlock = (Map<String, object>) designatedBrokerDetailsStepInfo.get('IfApplicantIsDesignatedInchargeDetailsBlock');
				if (licenseNumberBlock != null) {
					designatedOwnerAccountId = (String) licenseNumberBlock.get('AccountId');
					designatedOwnerLicenseNum = (String) licenseNumberBlock.get('Name');
					designatedOwnerAccountName = (String) licenseNumberBlock.get('PersonAccountContactName');
					designatedOwnerLicenseNumberId = (String)licenseNumberBlock.get('LicNoblId');
				} else if (nonlicensdNumberBlock != null) {
					designatedOwnerLicenseNum = (String) nonlicensdNumberBlock.get('NonLicensedPICLicenseNumber');
					ssn = (String) nonlicensdNumberBlock.get('NonLicensedPICSSN');
				} else if (personInchargelicensdNumberBlock != null) {
					designatedOwnerLicenseNum = (String) personInchargelicensdNumberBlock.get('ApplicantDesignatedInchargeLicenseNumber');
				}
			
			}

			if (
				!parRecords.isEmpty() && 
				(licensedInMissouri == YES || licensedInMissouri == null)
			) {
				relData = new RelationshipDataWraapper(parRecords[0].BusinessAccountNameId,
														designatedOwnerAccountId,
														PERSON_INCHARGE,
														designatedOwnerLicenseNum,
														designatedOwnerLicenseNumberId,
														parRecords[0].Business_License__c,
														parRecords[0].Board_Name__c,
														licensedInMissouri,
														employmentStatus); 
				createRelationshipRecord(
					relData,
					schoolBlockInfo,
					outMap,
					inputMap
				);
				createLocationRecord(designatedOwnerAccountId,designatedOwnerAccountName, licensedInMissouri, inputMap, outMap);
			} else if (
				!parRecords.isEmpty() &&
				licensedInMissouri == NO
			) {
				Account personAccount = upsertPersonAccount(inputMap,outMap, parRecords[0].BusinessAccountNameId);
				if(String.isNotBlank(ssn)){
					Boolean ssnDuplicate = checkDuplicateSSN(personAccount.Id,inputMap,outMap);
					if(ssnDuplicate == true ){
						return;
					}
				}
				relData = new RelationshipDataWraapper(parRecords[0].BusinessAccountNameId,
														personAccount.Id,
														PERSON_INCHARGE,
														designatedOwnerLicenseNum,
														null,
														parRecords[0].Business_License__c,
														parRecords[0].Board_Name__c,
														licensedInMissouri,
														employmentStatus);
				if (personAccount != null ) {
					createRelationshipRecord(
						relData,
						schoolBlockInfo,
						outMap,
						inputMap
					);
					createLocationRecord(personAccount.Id, personAccount.Name, licensedInMissouri, inputMap, outMap);
				}
			}
		} catch (Exception ex) {
			LPI_ExceptionManager.logException('LPI_ExceptionManager', 'linkPersonInchargeDetails', ex);
		}
	}

	/**
	 * @author                       : MTX Group Product Team
	 * @since                        : June 12, 2023
	 * @description                  : create relationship record
	 * @param inputMap               : input map
	 * @param outMap                 : output map
	 * @return                       : void
	 */
	private static void createRelationshipRecord(
		RelationshipDataWraapper relationshipData,
		Map<String, Object> schoolBlockInfoMap,
		Map<String, Object> outMap,
		Map<String, Object> inputMap
	) {
		if (relationshipData.accountId!=null && relationshipData.contactId!=null && String.isNotBlank(relationshipData.role)) {
			String relRecordId = (String) inputMap.get('RelationRecordId');
			List<Business_Relationships__c> relationshipList = new List<Business_Relationships__c>();
			Business_Relationships__c relationshipToCreate = new Business_Relationships__c();
			relationshipToCreate.Related_From__c = relationshipData.accountId;
			relationshipToCreate.Related_To__c = relationshipData.contactId;
			relationshipToCreate.Roles__c = relationshipData.role;
			relationshipToCreate.Start_Date__c = Date.today();
			relationshipToCreate.EndDate__c = null;
			relationshipToCreate.License_Number__c = relationshipData.LicenseNumOrSSN;
			relationshipToCreate.Is_Licensed_Entity__c = relationshipData.licensedInMissouri;
            relationshipToCreate.Related_To_License_Number__c = relationshipData.licenseNumId;
			relationshipToCreate.Employment_Status__c = relationshipData.employmentStatus;
			
			if(relationshipData.relatedFromBusinessLicenseId!=null){
				relationshipToCreate.Related_From_License_Number__c = relationshipData.relatedFromBusinessLicenseId;
			}
			
			List<Business_Relationships__c> duplicates = (List<Business_Relationships__c>) LPI_RelationshipService.findDuplicates(
				relationshipToCreate
			);
			if(relRecordId!=null){
				LPI_BusinessRelationshipDAO.LPI_BusinessRelationshipsWithoutSharingDAO instance = new LPI_BusinessRelationshipDAO.LPI_BusinessRelationshipsWithoutSharingDAO();
				relationshipList = instance.getBusinessRelationshipsByDymanicQuery(
					'Id',
					'Id = \'' + relRecordId + '\'',
					'1',
					null,null);
			}
			if (!relationshipList.isEmpty() && duplicates.isEmpty()) {
				relationshipToCreate.Id = relRecordId;
			} else if (!duplicates.isEmpty()) {
				relationshipToCreate.Id = duplicates[0].Id;
			}
			relationshipToCreate = (Business_Relationships__c) LPI_WithoutSharingUtility.upsertSObject(relationshipToCreate);
			outMap.put('RelationRecordId', relationshipToCreate.Id);

			Id parId = (Id)inputMap.get('parId');
            if(parId==null || String.isBlank(relationshipToCreate.Id)) {
                return;
            }
            PreliminaryApplicationRef par = new PreliminaryApplicationRef(
                Id = parId,
                Person_Incharge_Relation_Id__c = relationshipToCreate.Id    
            );
            LPI_DML.doUpdate(par);
		}
	}

	/**
	 * @author                       : MTX Group Product Team
	 * @since                        : June 12, 2023
	 * @description                  : create location record for account
	 * @param inputMap               : input map
	 * @param outMap                 : output map
	 * @return                       : void
	 */
	private static void createLocationRecord(
		Id accountId,
		String accountName,
		String licensedInMissouri,
		Map<String, Object> inputMap,
		Map<String, Object> outMap
	) {
		Id parId = (Id) inputMap.get('parId');
		if(parId==null || accountId==null){
			return;
		}
		Map<String, object> designatedBrokerDetailsStepInfo = (Map<String, object>) inputMap.get('DesignatedBrokerDetails');
		if(designatedBrokerDetailsStepInfo == null && designatedBrokerDetailsStepInfo.isEmpty()){
			return;
		}
		Map<String, object> addressValueMapping = new Map<String, object>();
		Map<String, String> addressKeyMapping;
		String isLicensedinMissuori = licensedInMissouri;
		
		if(isLicensedinMissuori == NO){
			
			Map<String, Object> mailingAddressBlock = (Map<String, Object>) designatedBrokerDetailsStepInfo.get('PICMailingAddressInfoBlock');
			
			Map<String, Object> lwcZipCityCountyMap = (Map<String, Object>) mailingAddressBlock?.get('DBCityCountyZip');

			addressValueMapping.put('NonLicensedPICStreetAddress', lwcZipCityCountyMap?.get('NonLicensedPICStreetAddress') );
			addressValueMapping.put('NonLicensedPICCity',lwcZipCityCountyMap?.get('NonLicensedPICCity') );
			addressValueMapping.put('NonLicensedPICUSState',lwcZipCityCountyMap?.get('NonLicensedPICUSState') );
			addressValueMapping.put('NonLicensedPICNonUSState', lwcZipCityCountyMap?.get('NonLicensedPICNonUSState') );
			addressValueMapping.put('NonLicensedPICUSZipCode',lwcZipCityCountyMap?.get('NonLicensedPICUSZipCode') );
			addressValueMapping.put('NonLicensedPICCountry',lwcZipCityCountyMap?.get('NonLicensedPICCountry') );
			addressValueMapping.put('NonLicensedPICCounty',lwcZipCityCountyMap?.get('NonLicensedPICCounty') );

			addressKeyMapping = new Map<String, String>{
				'NonLicensedPICStreetAddress' => 'Street',
				'NonLicensedPICCity' => 'City',
				'NonLicensedPICUSState' => 'StateCode',
				'NonLicensedPICNonUSState' => 'Business_State__c',
				'NonLicensedPICUSZipCode' => 'PostalCode',
				'NonLicensedPICCountry' => 'CountryCode',
				'NonLicensedPICCounty' => 'County__c'
			};
			
		}else if(isLicensedinMissuori == YES){
			addressValueMapping = (Map<String, object>) designatedBrokerDetailsStepInfo.get('LicNo-Block');
			addressKeyMapping = new Map<String, String>{
				'DesignatedInchargeMailingStreetAddress' => 'Street',
				'DesignatedInchargeMailingCity' => 'City',
				'DesignatedInchargeMailingZipCode' => 'PostalCode',
				'DesignatedInchargeMailingCountryCode' => 'CountryCode',
				'DesignatedInchargeMailingCounty' => 'County__c'
			};
			if((String)addressValueMapping.get('DesignatedInchargeMailingCountryCode') == 'US'){
				addressKeyMapping.put('DesignatedInchargeMailingStateCode','StateCode');
			}else{
				addressKeyMapping.put('DesignatedInchargeMailingState','Business_State__c');
			}
		}
		if(String.isBlank(accountName)){
			return;
		}
		String locationId = LPI_AddressUtility.createLocationAndAddress(
			accountId,
			PERSON_INCHARGE_ADDRESS,
			accountName,
			addressKeyMapping,
			addressValueMapping
		);
		if(locationId==null){
			return;
		}
		outMap.put('LocationId', locationId);

		LPI_TempAuthApplicationPlaceDAO.LPI_TempAuthApplicationPlaceWithoutSharingDAO tAAP = new LPI_TempAuthApplicationPlaceDAO.LPI_TempAuthApplicationPlaceWithoutSharingDAO();
		List<Temp_AuthApplicationPlace__c> tempAAP = tAAP.getTempAuthApplicationPlaceByDymanicQuery(
			'Id, Location__r.LocationType',
			' Preliminary_Application_Reference__c = \'' + parId +'\'' +
			' AND Location__r.LocationType = \'' + PERSON_INCHARGE_ADDRESS + '\'',
			null, null, null
		);
		Temp_AuthApplicationPlace__c tempAuthRec = new Temp_AuthApplicationPlace__c();
		if (!tempAAP.isEmpty()) {
			tempAuthRec.Id = tempAAP[0].Id;
		}
		tempAuthRec.Location__c = locationId;
		tempAuthRec.Preliminary_Application_Reference__c = parId;
		LPI_WithoutSharingUtility.upsertSObject(tempAuthRec);
	}

	/**
	 * @author                       : MTX Group Product Team
	 * @since                        : June 12, 2023
	 * @description                  : fetch address records
	 * @param inputMap               : input map
	 * @param outMap                 : output map
	 * @return                       : void
	 */
	public static Schema.Address fetchAddress(String parId, String locationType) {
		LPI_TempAuthApplicationPlaceDAO.LPI_TempAuthApplicationPlaceWithoutSharingDAO tAAP = new LPI_TempAuthApplicationPlaceDAO.LPI_TempAuthApplicationPlaceWithoutSharingDAO();
		List<Temp_AuthApplicationPlace__c> tempAAP = tAAP.getTempAuthApplicationPlaceByDymanicQuery(
			'Id, Location__c',
			' Preliminary_Application_Reference__c = \'' + parId + '\'' +
			' AND Location__r.LocationType = \'' + locationType + '\'',
			'1',
			null,null
		);
		if (!tempAAP.isEmpty()) {
			
			LPI_AddressDAO.LPI_AddressDAOWithoutSharing addressObj = new LPI_AddressDAO.LPI_AddressDAOWithoutSharing();
			for (Schema.Address address : addressObj.getAddressByDymanicQuery(
				'ID,ParentId,LocationType,Parent.Name,StateCode,City,County__c,PostalCode,State,Street,Country,CountryCode,Business_State__c',
				'ParentId = \'' + tempAAP[0].Location__c + '\'',
				'1',
				null,null
			)
			) {
				return address;
			}
		}
		return null;
	}

	/**
	 * @author                       : MTX Group Product Team
	 * @since                        : June 12, 2023
	 * @description                  : fetch address records from Business License
	 * @param inputMap               : input map
	 * @param outMap                 : output map
	 * @return                       : void
	 */
	public static Schema.Address fetchBlAddress(String blId, String locationType) {
		Schema.Address address = null;
		if(String.isNotBlank(blId) && String.isNotBlank(locationType)){
			Set<Id> locIdSet = new Set<Id>();
			
			LPI_AuthApplicationPlaceDAO.LPI_AuthApplicationPlaceWithoutSharingDAO aapObj = new LPI_AuthApplicationPlaceDAO.LPI_AuthApplicationPlaceWithoutSharingDAO();
			List<AuthApplicationPlace> tempAAP = aapObj.getAuthApplicationPlaceByDymanicQuery(
				'Id, AuthorizationId, PlaceId',
				' AuthorizationId = \'' + blId + '\'',
				null,'CreatedDate','DESC'
			);
			for(AuthApplicationPlace aap :tempAAP){
				locIdSet.add(aap.PlaceId);
			}
			if(!locIdSet.isEmpty()){
				
				LPI_AddressDAO.LPI_AddressDAOWithoutSharing addressObj = new LPI_AddressDAO.LPI_AddressDAOWithoutSharing();
				List<Schema.Address> addressList = addressObj.getAddressByDymanicQuery(
					'ID,ParentId,LocationType,Parent.Name,StateCode,City,County__c,PostalCode,State,Street,Country,CountryCode,Business_State__c',
					'ParentId IN ' + LPI_ServiceUtility.getStringValuesBySet(locIdSet) + 
					' AND Parent.LocationType =\'' + locationType + '\'',
					'1',
					'CreatedDate','DESC'
				);
				if(!addressList.isEmpty()){
					address = addressList[0];
				}
			}
		}
		return address;
	}

	/**
	 * @author                       : MTX Group Product Team
	 * @since                        : June 16, 2023
	 * @description                  : Method to check if SSN is valid or not
	 * @param inputMap               : input map
	 * @param outMap                 : output map
	 * @return                       : void
	 */
	public static Boolean checkDuplicateSSN(Id personAccountId, Map<String, Object> inputMap, Map<String, Object> outMap) {
		Boolean isDuplicate = false;
		outMap.put('isDuplicate', false);
		String ssnNumber ='';

		Map<String, Object> designatedCPDetailsStepInfo = (Map<String, Object>) inputMap.get('DesignatedBrokerDetails');
		Map<String, Object> designatedPICAmendmentDetailsStepInfo = (Map<String, Object>) inputMap.get('DesignatedInchargeInformation');
		if(designatedCPDetailsStepInfo!=null && !designatedCPDetailsStepInfo.isEmpty()){
			Map<String, Object> personalInfoBlockDetails = (Map<String, Object>) designatedCPDetailsStepInfo.get('NonLicensedPICDetails');
			if(personalInfoBlockDetails!=null && !personalInfoBlockDetails.isEmpty()){
				ssnNumber = (String) personalInfoBlockDetails.get('NonLicensedPICSSN');
			}
		} else if(designatedPICAmendmentDetailsStepInfo!=null && !designatedPICAmendmentDetailsStepInfo.isEmpty()){
			Map<String, Object> personalInfoBlockDetails = (Map<String, Object>) designatedPICAmendmentDetailsStepInfo.get('NewDesignatedInchargeUnlicensed');
			if(personalInfoBlockDetails!=null && !personalInfoBlockDetails.isEmpty()){
				ssnNumber = (String) personalInfoBlockDetails.get('UnlicensedNewDesignatedInchargeSSN');
			}
		}
		String accountWhereClause = 'Social_Security_Number__c = \'' + String.escapeSingleQuotes(ssnNumber) + '\'';
		
		LPI_AccountDAO.LPI_AccountWithoutSharingDAO accObj = new LPI_AccountDAO.LPI_AccountWithoutSharingDAO();
		List<Account> accountsWithSSNList = accObj.getAccountByDymanicQuery(
			'Id,Social_Security_Number__c',
			accountWhereClause,
			null,null,null
		);
		if (!accountsWithSSNList.isEmpty() && accountsWithSSNList[0].Id != personAccountId) {
			isDuplicate = true;
			outMap.put('isDuplicate', true);
		}
		if(isDuplicate == false){
			Account personAccount = new Account();
			personAccount.Id = personAccountId;
			personAccount.Social_Security_Number__c = ssnNumber;
			LPI_WithoutSharingUtility.upsertSObject(personAccount);
		}
		return isDuplicate;
	}

	/**
	 * @author                       : MTX Group Product Team
	 * @since                        : June 27, 2023
	 * @description                  : Method to fetch mailing address
	 * @param inputMap               : input map
	 * @param outMap                 : output map
	 * @return                       : void
	 */
	public static Map<Id,Schema.address> getAddress(Map<Id,String> blIdToAddMap){
        Map<Id,Schema.address>  blIdToAddressMap = new Map<Id,Schema.address>();
        Map<Id,Id> locIdToAuthIdMap = new Map<Id,Id>();
        Map<Id,AuthApplicationPlace>  authIdToAuthDataMap = new Map<Id,AuthApplicationPlace>();
        Map<Id,Map<String,Schema.address>> blIdToAddTypeToAddMap = new Map<Id,Map<String,Schema.address>>();

        if(!blIdToAddMap.isEmpty()){
           
            LPI_AuthApplicationPlaceDAO.LPI_AuthApplicationPlaceWithoutSharingDAO aapObj = new LPI_AuthApplicationPlaceDAO.LPI_AuthApplicationPlaceWithoutSharingDAO();
            for (
                AuthApplicationPlace aap : aapObj.getAuthApplicationPlaceByDymanicQuery(
                    'Id, AuthorizationId, Authorization.Name, PlaceId',
                    ' AuthorizationId IN ' + LPI_ServiceUtility.getStringValuesBySet(blIdToAddMap.keySet()),
                    null,null,null
                )
            ) {
                locIdToAuthIdMap.put(aap.PlaceId,aap.Id);
                authIdToAuthDataMap.put(aap.Id,aap);
            }
            if(!locIdToAuthIdMap.isEmpty()){
                
                List<Schema.Address> addresses = (new LPI_AddressDAO.LPI_AddressDAOWithoutSharing())
                    .getAddressByDymanicQuery(
                        'ID,ParentId,LocationType,StateCode,City,County__c,PostalCode,State,Street,CountryCode,Country,Business_State__c', 
                        'ParentId IN ' + LPI_ServiceUtility.getStringValuesBySet(locIdToAuthIdMap.keySet()) +
                        ' AND Parent.Status__c = \'' + LOCATION_STATUS_OPEN + '\'', 
                        null, null, null
                );
                for(Schema.Address tempAdd : addresses){
                    if(locIdToAuthIdMap.containsKey(tempAdd.ParentId)){
                        String authId = locIdToAuthIdMap.get(tempAdd.ParentId);
                        if(authIdToAuthDataMap.containsKey(authId)){
                            String tempBlId = authIdToAuthDataMap.get(authId).AuthorizationId;
                            if(blIdToAddTypeToAddMap.containsKey(tempBlId)){
                                blIdToAddTypeToAddMap.get(tempBlId).put(tempAdd.LocationType,tempAdd);
                            }else{
                                blIdToAddTypeToAddMap.put(tempBlId,new Map<String,Schema.address>{tempAdd.LocationType => tempAdd});
                            }
                        }
                    }
                }
                for(Id blId : blIdToAddMap.keySet()){
                    if(blIdToAddTypeToAddMap.containsKey(blId)){
                        Map<String,Schema.address> AddTypeToAddMap = blIdToAddTypeToAddMap.get(blId);
                        if(AddTypeToAddMap.containsKey('Mailing')){
                            blIdToAddressMap.put(blId, AddTypeToAddMap.get('Mailing'));
                        }else{
                            String primaryType = blIdToAddMap.get(blId);
                            if(String.isNotBlank(primaryType) && AddTypeToAddMap.containsKey(primaryType)){
                                blIdToAddressMap.put(blId, AddTypeToAddMap.get(primaryType));
                            }
                        }
                    }
                }
            }
        }
        return blIdToAddressMap;
    }

	/**
	 * @author                       : MTX Group Product Team
	 * @since                        : June 27, 2023
	 * @description                  : Method to fetch PIC details in FC
	 * @param inputMap               : input map
	 * @param outMap                 : output map
	 * @return                       : void
	 */
	public static void fetchPICDetailsFC(Map<String, Object> inputMap, Map<String, Object> outMap) {
		try {
			Id parId = (Id) inputMap.get('parId');
			Id blId = (Id) inputMap.get('blId');
			if(parId!=null){
				Schema.Address tempAddress = new Schema.Address();
				String hasPIC = null;
				list<PreliminaryApplicationRef> parList = LPI_PreliminaryApplicationRefDAO.getPreliminaryApplicationRefByDymanicQuery(
					'Id, BusinessAccountNameId, Type__c, Business_License__c, Business_License__r.Is_Migrated_Data__c,'+
					'Regulatory_Authorization_Type__r.IssuingDepartment.Name, How_are_you_associated_to_this_entity__c,'+
					'Person_Incharge_Relation_Id__c,Do_you_need_PIC__c, Board_Name__c',
					'Id =\'' + parId + '\'',
					'1',
					null,null
				);
				if(parList[0].Do_you_need_PIC__c!=null){
					hasPIC = parList[0].Do_you_need_PIC__c;
				}else if (blId!=null){
					list<BusinessLicense> blList = LPI_BusinessLicenseDAO.fetchBusinessLicenseRecordsWithOrderByLimit(
						'Id, Do_you_need_PIC__c',
						'Id =\'' + blId + '\'',
						'1',
						null);
					if(!blList.isEmpty() && blList[0].Do_you_need_PIC__c!=null){
						hasPIC = blList[0].Do_you_need_PIC__c;
					}
				}
				if(!parList.isEmpty()){
					Boolean picFlag = false;
					outMap.put('NeedPIC', hasPIC);
					
					LPI_BusinessRelationshipDAO.LPI_BusinessRelationshipsWithoutSharingDAO acrQuery = new LPI_BusinessRelationshipDAO.LPI_BusinessRelationshipsWithoutSharingDAO();
					for (Business_Relationships__c acr : acrQuery.getBusinessRelationshipsByDymanicQuery(
						'Id,License_Number__c, Related_To__r.Date_of_Birth__c, Is_Licensed_Entity__c, Related_To_License_Number__r.License_Number_With_Rat_Name__c,' +
						' Related_To__r.FirstName, Related_To__r.LastName, Related_To__r.MiddleName,Related_To__r.Fax, Employment_Status__c,' +
						' Related_To__r.Phone, Related_To__r.PersonEmail, Related_To__r.Social_Security_Number__c,'+
						' Highest_level_of_school_completed__c, School_Country__c, Date_of_Completion__c, School__c, School_City__c, School_State__c,'+
						' Related_To_License_Number__r.Business_Entity_Name__c, Related_To_License_Number__r.Legacy_License_Number__c,Related_To_License_Number__r.Name, Related_To_License_Number__r.Issuing_Department_Name__c, Person_Incharge_Email__c',
						
						' Related_From__c =\'' + parList[0].BusinessAccountNameId +
						'\' AND Roles__c = \'' + PERSON_INCHARGE + '\' AND EndDate__c =null',
						'1',
						null,null
					)
					) {
						picFlag = true;
						outMap.put('IsThePersonInChargeLicensedinMissouri', acr.Is_Licensed_Entity__c);
						outMap.put('IsThePersonInChargeLicensedinMissouriPIPFI', acr.Is_Licensed_Entity__c);
						outMap.put('IsThePersonInChargeLicensedinMissouriRealEstate', acr.Is_Licensed_Entity__c);
						outMap.put('EmploymentStatusCorporation', acr.Employment_Status__c);
						outMap.put('EmploymentStatusLLC', acr.Employment_Status__c);
						outMap.put('IsThePersonInChargeLicensedinMissouriRO', acr.Is_Licensed_Entity__c);
						outMap.put('IsThePersonInChargeLicensedinMissouriROPIPFI', acr.Is_Licensed_Entity__c);
						outMap.put('IsThePersonInChargeLicensedinMissouriRORealEstate', acr.Is_Licensed_Entity__c);
						outMap.put('DesignatedInchargeFirstName', acr.Related_To__r.FirstName);
						outMap.put('DesignatedInchargeMiddleName', acr.Related_To__r.MiddleName);
						outMap.put('DesignatedInchargeLastName', acr.Related_To__r.LastName);
						outMap.put('DesignatedInchargePhoneNumber', acr.Related_To__r.Phone);
						
							outMap.put('DesignatedInchargeEmail', acr.Related_To__r.PersonEmail);
						
					
					
						if(acr.Related_To__r.Social_Security_Number__c != NULL
								&& parList[0].How_are_you_associated_to_this_entity__c == 'Temporary Clerk' 
								&& LPI_WithoutSharingUtility.isPortalUser()){
							outMap.put('DesignatedInchargeSSN', '•••••••••');
						}else{
							outMap.put('DesignatedInchargeSSN', acr.Related_To__r.Social_Security_Number__c);
						}
						
						outMap.put('DesignatedInchargeFaxNumber', acr.Related_To__r.Fax);
						outMap.put('DesignatedInchargeDOB', acr.Related_To__r.Date_of_Birth__c);
						outMap.put('HighestLevelofSchoolCompleted', acr.Highest_level_of_school_completed__c);
						outMap.put('PICSchoolName', acr.School__c);
						outMap.put('PICSchoolCity', acr.School_City__c);
						outMap.put('PICSchoolCountry', acr.School_Country__c);
						outMap.put('PICSchoolState', acr.School_State__c);
						outMap.put('PICSchoolDateOfCompletion', acr.Date_of_Completion__c);
						outMap.put('boardName', parList[0].Regulatory_Authorization_Type__r.IssuingDepartment.Name);
						outMap.put('howAreYouAssociated',parList[0].How_are_you_associated_to_this_entity__c);
						if(acr.Is_Licensed_Entity__c == 'Yes'){
							if(parList[0].Regulatory_Authorization_Type__r.IssuingDepartment.Name == EFD_BOARD){
								outMap.put('LicNo', acr.Related_To_License_Number__r.Legacy_License_Number__c!=null ?  acr.Related_To_License_Number__r.Business_Entity_Name__c + ' - ' + acr.Related_To_License_Number__r.Legacy_License_Number__c + ' - ' + acr.Related_To_License_Number__r.Issuing_Department_Name__c:
								acr.Related_To_License_Number__r.Business_Entity_Name__c + '-' + acr.Related_To_License_Number__r.License_Number_With_Rat_Name__c);
							}
							else{
								outMap.put('LicNo', acr.Related_To_License_Number__r.License_Number_With_Rat_Name__c);
							}
						}else if(acr.Is_Licensed_Entity__c == 'No'){
							outMap.put('LicNo', acr.License_Number__c);
						}
					}
					if(parList[0].Type__c !=NEW_TYPE && parList[0].Type__c !=CHANGE_OF_OWNERSHIP && parList[0].Business_License__r.Is_Migrated_Data__c == false){
						tempAddress = fetchBlAddress(parList[0].Business_License__c, PERSON_INCHARGE_ADDRESS);
					}else{
						tempAddress = fetchAddress(parList[0].Id, PERSON_INCHARGE_ADDRESS);
					}
					if(tempAddress!=null){
							outMap.put('DesignatedInchargeCity', tempAddress.City);
							outMap.put('DesignatedInchargeStreetAddress', tempAddress.Street);
							outMap.put('DesignatedInchargeCountryFC', tempAddress.Country);
							outMap.put('DesignatedInchargeUSZipCode', tempAddress.PostalCode);
							outMap.put('DesignatedInchargeCounty', tempAddress.County__c);
							if (tempAddress.CountryCode == 'US') {
								outMap.put('DesignatedInchargeUSStateFC', tempAddress.State);
							} else {
								outMap.put('DesignatedInchargeUSStateFC', tempAddress.Business_State__c);
							}
						
					}
					outMap.put('flag',picFlag);
				}
			}
		}catch (Exception ex) {
			LPI_ExceptionManager.logException('LPI_ExceptionManager', 'fetchPICDetailsFC', ex);
		}
	}

	/**
	 * @author                       : MTX Group Product Team
	 * @since                        : June 27, 2023
	 * @description                  : Method to fetch DR details and method calls for PIC step
	 * @param inputMap               : input map
	 * @param outMap                 : output map
	 * @return                       : void
	 */
	public static void fetchPICDRDetails(Map<String, Object> inputMap, Map<String, Object> outMap){
		try{
			Id parId = (Id) inputMap.get('parId');
			if(parId != null){
				String blId = (String) inputMap.get('blId');
				
				if(blId!=null){
					list<BusinessLicense> blList = LPI_BusinessLicenseDAO.fetchBusinessLicenseRecordsWithOrderByLimit(
						'Id, Is_Migrated_Data__c, Do_you_need_PIC__c',
						'Id =\'' + blId + '\'',
						'1',
						null);
					if(!blList.isEmpty()){
						outMap.put('IsEditableForMigratedData',blList[0].Is_Migrated_Data__c);
						outMap.put('NeedPIC',blList[0].Do_you_need_PIC__c);
					}
				}
				
				list<PreliminaryApplicationRef> parList = LPI_PreliminaryApplicationRefDAO.getPreliminaryApplicationRefByDymanicQuery(
					'Id,How_are_you_associated_to_this_entity__c,Regulatory_Authorization_Type__r.IssuingDepartment.Name,Regulatory_Authorization_Type__r.Name,Do_you_need_PIC__c',
					'Id =\'' + parId + '\'',
					'1',
					null,null);
				if(!parList.isEmpty()){
					outMap.put('boardName',parList[0].Regulatory_Authorization_Type__r.IssuingDepartment.Name);
					outMap.put('ratName',parList[0].Regulatory_Authorization_Type__r.Name);
					outMap.put('howAreYouAssociated',parList[0].How_are_you_associated_to_this_entity__c);
					outMap.put('NeedPIC',parList[0].Do_you_need_PIC__c);
					fetchRSBDesignatedBrokerName(inputMap, outMap);
				}
			}
        }catch (Exception ex) {
			LPI_ExceptionManager.logException('LPI_ExceptionManager', 'fetchPICDRDetails', ex);
		}
    }

	private static void upsertNeedPICInformation(Id parid, String picVal) {
        try {
            if (parid != null && String.isNotBlank(picVal)) {
				PreliminaryApplicationRef par = new PreliminaryApplicationRef();
					par.Id = parid;
					par.Do_you_need_PIC__c =  picVal;
				if(picVal == 'No'){
					List<PreliminaryApplicationRef> parList = LPI_PreliminaryApplicationRefDAO.getPreliminaryApplicationRefByDymanicQuery(
					'Id, Person_Incharge_Relation_Id__c',
					'Id = \'' + parid + '\'', 
					'1', 
					null, null);
					if (!parList.isEmpty() && parList[0].Person_Incharge_Relation_Id__c!=null) {
						par.Person_Incharge_Relation_Id__c = null;
						LPI_BusinessRelationshipDAO.LPI_BusinessRelationshipsWithoutSharingDAO acrQuery = new LPI_BusinessRelationshipDAO.LPI_BusinessRelationshipsWithoutSharingDAO();
						List<Business_Relationships__c> acr = acrQuery.getBusinessRelationshipsByDymanicQuery(
							'Id',
							' Id =\'' + parList[0].Person_Incharge_Relation_Id__c +'\'',
							'1',
							null,null
						);
						if(!acr.isEmpty()){
							LPI_WithoutSharingUtility.deleteSObject(acr);
						}
					}
				}
				LPI_DML.doUpdate(par);
			}
        } catch (Exception e) {
            LPI_ExceptionManager.logException('LPI_ExceptionManager', 'upsertNeedPICInformation', e);
        }
    }

	class RelationshipDataWraapper{
		public Id accountId;
		public Id contactId;
		public String role;
		public String LicenseNumOrSSN;
		public Id licenseNumId;
		public Id relatedFromBusinessLicenseId;
		public String boardName;
		public String licensedInMissouri;
		public String employmentStatus;

		RelationshipDataWraapper(Id accountId, Id contactId, String role, String LicenseNumOrSSN, 
		                         Id licenseNumId,  Id relatedFromBusinessLicenseId, String boardName, 
								 String licensedInMissouri, String employmentStatus){
			this.accountId = accountId;
			this.contactId = contactId;
			this.role = role;
			this.LicenseNumOrSSN = LicenseNumOrSSN;
			this.licenseNumId = licenseNumId;
			this.relatedFromBusinessLicenseId = relatedFromBusinessLicenseId;
			this.boardName = boardName;
			this.licensedInMissouri = licensedInMissouri;
			this.employmentStatus = employmentStatus;
		}
	}

}