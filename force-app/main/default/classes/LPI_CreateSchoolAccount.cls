/**
 * @author      : MTX Group Product Team
 * @since       :
 * @description : This Class is  create and fectch fetching data from Omniscript creating/fetching data related to the School
 */
global with sharing class LPI_CreateSchoolAccount implements Callable {

	private static final String CLASS_NAME = 'LPI_CreateSchoolAccount';
	private static final String METHOD_INVOKE_METHOD = 'invokeMethod';
	private static final String METHOD_CREATE_SCHOOL_ACCOUNT = 'createSchoolAccount';
	private static final String METHOD_FETCH_SCHOOL_INFO = 'fetchSchoolInformation';
	private static final String METHOD_UPDATE_HOW_ARE_YOU_ASSOCIATED = 'updateHowAreYouAssociated';
	private static final String SCHOOL_NAME = 'SchoolName';
	private static final String SCHOOL_NAME_RO = 'SchoolNameRO';
	private static final String SCHOOL_EMAIL = 'SchoolEmail';
	private static final String SCHOOL_EMAIL_RO = 'SchoolEmailRO';
	private static final String SCHOOL_FAX_NUMBER = 'SchoolFaxNumber';
	private static final String SCHOOL_FAX_NUMBER_RO = 'SchoolFaxNumberRO';
	private static final String SCHOOL_STATE = 'SchoolState';
	private static final String SCHOOL_STATE_FOR_NON_US_COUNTRY = 'SchoolStateForNonUSCountry';
	private static final String SCHOOL_STATE_FOR_NON_US_COUNTRY_RO = 'SchoolStateForNonUSCountryRO';
	private static final String SCHOOL_STATE_RO = 'SchoolStateRO';
	private static final String SCHOOL_CITY = 'SchoolCity';
	private static final String SCHOOL_CITY_RO = 'SchoolCityRO';
	private static final String SCHOOL_ZIP_CODE = 'SchoolZipcode';
	private static final String SCHOOL_ZIP_CODE_RO = 'SchoolZipcodeRO';
	private static final String SCHOOL_TELEPHONE = 'SchoolTelephone';
	private static final String SCHOOL_TELEPHONE_RO = 'SchoolTelephoneRO';
	private static final String SCHOOL_STREET = 'SchoolStreetAddress1';
	private static final String SCHOOL_STREET_RO = 'SchoolStreetAddress1RO';
	private static final String SCHOOL_TYPE_OF_ORG = 'STypeOfOrg';
	private static final String SCHOOL_TYPE_OF_ORG_RO = 'STypeOfOrg';
	private static final String SCHOOL_WEBSITE = 'SchoolWebsite';
	private static final String SCHOOL_WEBSITE_RO = 'SchoolWebsiteRO';
	private static final String SCHOOL_COUNTRY_CODE = 'SchoolCountry';
	private static final String SCHOOL_COUNTRY = 'SchoolCountryRO';
	private static final String HOW_ARE_YOU_ASSOCIATED = 'HowAreYouAssociatedToThisEntity';
	private static final String IS_READ_ONLY_STEP = 'isReadOnlyStep';
	private static final String PAR_ID = 'parid';
	private static final String PAR_NOT_FOUND = 'PAR record is not created for the flow';
	private static final String BUSINESS_ACCOUNT = 'BusinessAccount';
	private static final String TEMP_AUTH_APP_PLACE_ID = 'tempAuthAppPlaceId';
	private static final String BUSINESS_ACC_ID = 'businessAccId';
	private static final String SOBJECT_ADDRESS = 'Address';
	private static final String SOBJECT_ACCOUNT = 'Account';
	private static final String ID_FIELD = 'Id';
	
	private static final String TRC_PARTICIPANTS_ID = 'TrcParticipantId';
	private static final String DELET_FAIL = 'There is some error in delete';
	
	private static final String ACCOUNT_MAPPING_ERROR = 'There is some issue during account mapping';
	private static final String IS_ERROR = 'isError';
	private static final String IS_DUPLICATE = 'isDuplicate';
	private static final String COUNTRY_CODE = 'CountryCode';
	private static final String US_COUNTRY_CODE = 'US';
	private static final String ANNUAL_REPORT_SURVEY = 'Annual Report Survey';
	private static final String ASSOCIATED_TO_ENTITY_RO = 'HowAreYouAssociatedToThisEntityRO';
	
	private static final String DRAFT = 'Draft';
	private static final String CONVERTED = 'Converted';
	private static final String NEW_STATUS = 'New';
	private static final String REJECTED = 'Rejected';
	private static final String PERSON_INCHARGE = 'Designated Incharge';
	private static final String OWNER = 'Owner';
	private final static String BOTH = 'Owner + Designated Incharge';
	public final static List<String> APPLICATION_STATUS = new List<String>{
		'Draft',
		'Rejected',
		'Approved',
		'License Issued'
	};
	
	private static final List<String> LIST_OF_ACCOUNT_FIELDS = new List<String>{
		'Id',
		'Name',
		'BillingStateCode',
		'BillingCity',
		'BillingPostalCode',
		'BillingStreet',
		'BillingState',
		'Buisness_Email__c',
		'Phone',
		'Fax',
		'BillingCountry',
		'Website',
		'How_are_you_associated_to_this_entity__c',
		'Other_State__c',
		'BillingCountryCode',
		'Entity_type__c',
		'Other_Entity_Type__c',
		'Type_of_Organization__c',
		'County__c'
	};

	private static final Map<String, String> KEY_MAPING_FOR_ACCOUNT = new Map<String, String>{
		SCHOOL_EMAIL => 'Buisness_Email__c',
		SCHOOL_TELEPHONE => 'Phone',
		SCHOOL_FAX_NUMBER => 'Fax',
		SCHOOL_CITY => 'BillingCity',
		SCHOOL_STREET => 'BillingStreet',
		SCHOOL_ZIP_CODE => 'BillingPostalCode',
		SCHOOL_WEBSITE => 'Website',
		SCHOOL_COUNTRY_CODE => 'BillingCountryCode',
		SCHOOL_TYPE_OF_ORG => 'Type_of_Organization__c',
		'County' => 'County__c'
	};
	private static final Map<String, String> KEY_MAPING_FOR_ADDRESS = new Map<String, String>{
		SCHOOL_STREET => 'Street',
		SCHOOL_CITY => 'City',
		SCHOOL_ZIP_CODE => 'PostalCode',
		SCHOOL_COUNTRY_CODE => COUNTRY_CODE,
		'County' => 'County__c'
	};

	
	private static final String BUSINESS_LOCATION_ID = 'schoolBusinessLocationId';
	private static final String BUSINESS_LOCATION_ADDRESS_ID = 'schoolBusinessLocAddressId';
	private static final String SATELLITE_CLASSROOM = 'Satellite Classroom';
	static final Set<String> notAllowAllOwnerShip = new Set<String>{
		'Barber Establishment',
		'Cosmetology Establishment',
		'Beauty/Barber Establishment',
		'School of Barbering',
		'School of Cosmetology',
		'School of Cosmetology & Barbering'
	};
	private static final String SCHOOL_INFO = 'SchoolInformation';
	private static final Set<String> ASSOCIATE_ROLE_SET = new Set<String>{
		'Temporary Clerk',
		'License Service Provider',
		'Not Applicable'
	};
	private static final String HOW_ARE_YOU_ASSOCIATE_RO = 'HowAreYouAssociatedToThisEntityReadOnly';
	
	global Object call(String action, Map<String, Object> args) {
		Map<String, Object> input = (Map<String, Object>) args.get(LPI_LiteralConstant.INPUT);
		Map<String, Object> output = (Map<String, Object>) args.get(LPI_LiteralConstant.OUTPUT);
		Map<String, Object> options = (Map<String, Object>) args.get(LPI_LiteralConstant.OPTIONS);
		return invokeMethod(action, input, output, options);
	}

	/**
	 * @author          :  MTX Group Product Team
	 * @description     : This method will compare method from Omniscript and execute only that specific method
	 * @return          : `Boolean`
	 */
	private Boolean invokeMethod(
		String methodName,
		Map<String, Object> inputMap,
		Map<String, Object> outMap,
		Map<String, Object> options
	) {
		Boolean result = true;
		try {
			if (METHOD_CREATE_SCHOOL_ACCOUNT.equalsIgnoreCase(methodName)) {
				createSchoolAccount(inputMap, outMap, options);
			} else if (METHOD_FETCH_SCHOOL_INFO.equalsIgnoreCase(methodName)) {
				fetchSchoolInformation(inputMap, outMap);
			}
			
		} catch (Exception exceptionInstance) {
			LPI_ExceptionManager.logException(CLASS_NAME, METHOD_INVOKE_METHOD, exceptionInstance);
			return false;
		}
		return result;
	}

	/**
	 * @author                      : MTX Group Product Team
	 * @description                 : This method is Used to Create School Account
	 * @param inputMap              : fetching all the input from Omniscript
	 * @param outMap                : Passing value to Omniscript
	 * @param options               : Passing Options to Omniscript if needed
	 * @last modified by            : MTX Group Product Team
	 * @last modified date          : 19 Jan 2023
	 * @last modified details       : Changed DML statement and move queries to DAO classes
	 */
	private static void createSchoolAccount(
		Map<String, Object> inputMap,
		Map<String, Object> outMap,
		Map<String, Object> options
	) {
		try {
			outMap.put(IS_ERROR, false);
			Map<String, object> stepConInfo = (Map<String, object>) inputMap.get(SCHOOL_INFO);
			String businlocId = '';
			String accId = '';
			String name = (String) stepConInfo.get(SCHOOL_NAME);
			String businessAccAddressId;
			String tempAuthAppPlaceId = (String) inputMap.get(TEMP_AUTH_APP_PLACE_ID);
			String parId = (String) inputMap.get(PAR_ID);
			Map<String, Object> relationShipBlk = (Map<String, object>) stepConInfo.get('RelationshipDataBLK');
			String role = relationShipBlk != null && relationShipBlk.containsKey(HOW_ARE_YOU_ASSOCIATED)
				? (String) relationShipBlk.get(HOW_ARE_YOU_ASSOCIATED)
				: null;
			if (
				(String.isBlank(role) &&
				inputMap.containsKey('CEProviderHowAreYouAssociated') &&
				Boolean.valueOf(String.valueOf(inputMap.get('CEProviderHowAreYouAssociated'))))
			) {
				role = relationShipBlk != null && relationShipBlk.containsKey('HowAreYouAssociatedToThisEntityCE')
					? (String) relationShipBlk.get('HowAreYouAssociatedToThisEntityCE')
					: null;
			}
			Boolean isExternalUser = false;
			isExternalUser = Boolean.valueOf(inputMap.get('isExternalUser'));
			String aapBusinessId = (String) inputMap.get('aapBusinessId');
			String schoolBusinessLocationId = (String) inputMap.get(BUSINESS_LOCATION_ID);
			String schoolBusinessLocAddressId = (String) inputMap.get(BUSINESS_LOCATION_ADDRESS_ID);
			if (String.isEmpty(parId)) {
				LPI_ExceptionManager.logException(
					CLASS_NAME,
					METHOD_CREATE_SCHOOL_ACCOUNT,
					PAR_NOT_FOUND,
					PAR_NOT_FOUND,
					null,
					null
				);
				return;
			}
			String licenseType;
			String businessAccountId;
			List<PreliminaryApplicationRef> parList = LPI_PreliminaryApplicationRefDAO.getPARRecordsByID(
				new Set<Id>{ parId }
			);
			if (!parList.isEmpty()) {
				licenseType = parList[0].Regulatory_Authorization_Type__r.Name;
				businessAccountId = parList[0].BusinessAccountNameId;
			}
            if (stepConInfo.containsKey('DBCityCountyZip')) {
				Map<String, Object> rSSchoolCityZipCodeCountyBlk = (Map<String, Object>) stepConInfo.get('DBCityCountyZip');
				String zipcode = (String) rSSchoolCityZipCodeCountyBlk?.get('SchoolOldZipCode');
				String city = (String) rSSchoolCityZipCodeCountyBlk?.get('SchoolOldCity');
				String state = (String) rSSchoolCityZipCodeCountyBlk?.get('SchoolEditableState');
				String usState = (String) rSSchoolCityZipCodeCountyBlk?.get('SchoolEditableStateUS');
				String country = (String) rSSchoolCityZipCodeCountyBlk?.get('SchoolEditableCountry');
				String street = (String) rSSchoolCityZipCodeCountyBlk?.get('SchoolStreetAddress');
				String county = (String) rSSchoolCityZipCodeCountyBlk?.get('SchoolOldCounty');
				
				stepConInfo.put('SchoolStreetAddress1', street);
				stepConInfo.put('SchoolCountry', country);
				stepConInfo.put('SchoolState', usState);
				stepConInfo.put('SchoolStateForNonUSCountry', state);
				stepConInfo.put('SchoolCity', city);
				stepConInfo.put('SchoolZipcode', zipcode);
				stepConInfo.put('County', county);
			}
			Account schoolAccount = createSchoolAccountRecord(stepConInfo, isExternalUser, licenseType, parId);
			if (schoolAccount == null) {
				LPI_ExceptionManager.logException(
					CLASS_NAME,
					METHOD_CREATE_SCHOOL_ACCOUNT,
					ACCOUNT_MAPPING_ERROR,
					ACCOUNT_MAPPING_ERROR,
					null,
					null
				);
				outMap.put(IS_ERROR, true);
				return;
			}	
			Boolean isDuplicateApplication = false;
			isDuplicateApplication = LPI_ApplicationFlowUtility.checkExistingBusinessApplicationWithAddress(
				schoolAccount,
				parId
			);
			if (isDuplicateApplication) {
				outMap.put(IS_DUPLICATE, true);
			} else {
				outMap.put(IS_DUPLICATE, false);
				if (US_COUNTRY_CODE.equalsIgnoreCase((String) stepConInfo.get(SCHOOL_COUNTRY_CODE))) {
					KEY_MAPING_FOR_ADDRESS.put(SCHOOL_STATE, 'StateCode');
				} else {
					KEY_MAPING_FOR_ADDRESS.put(SCHOOL_STATE_FOR_NON_US_COUNTRY, 'Business_State__c');
				}
				businlocId = LPI_WithoutSharingUtility.upsertSObject(
						LPI_AddressUtility.createLocationRecord(
							schoolBusinessLocationId,
							name,
							LPI_LiteralConstant.LOCATION_TYPE_BUSINESS_ADDRESS,
							null
						)
					)
					?.Id;
				Schema.Address businessAddressRec = (Schema.Address) LPI_VlocityUtility.createSObject(
					stepConInfo,
					KEY_MAPING_FOR_ADDRESS,
					'Address'
				);
				schoolBusinessLocAddressId = LPI_CreateBusinessAccount.createBusinessAccAddress(
					businessAddressRec,
					businlocId,
					schoolBusinessLocAddressId,
					LPI_LiteralConstant.LOCATION_TYPE_BUSINESS_ADDRESS
				);
				schoolAccount.Ownership_Type_Controller__c = 'Other';
				 
				schoolAccount = (Account) LPI_WithoutSharingUtility.upsertSObject(schoolAccount);
				accId = schoolAccount.Id;

				 
				List<Temp_AuthApplicationPlace__c> listOfTempPlace = LPI_TempAuthApplicationPlaceDAO.getTempAuthAppPlacesByPARId(
					new Set<Id>{ parId }
				);
				String tempAuthApplicationPlaceId;
				if (!listOfTempPlace.isEmpty()) {
					tempAuthApplicationPlaceId = listOfTempPlace[0].Id;
				}
				tempAuthAppPlaceId = LPI_AddressUtility.createTempAuthPlaceRecord(
					tempAuthApplicationPlaceId,
					businlocId,
					parId
				);

				 
				LPI_AddressUtility.upsertAssociationLocRecord(accId, schoolBusinessLocationId, businlocId);
				if (isExternalUser) {
					upsertACRRecord(parId, accId, role);
				}
				 
				PreliminaryApplicationRef par = new PreliminaryApplicationRef();
				par.Id = parId;
				par.BusinessAccountNameId = accId;
				par.Business_Name__c = name;
				par.How_are_you_associated_to_this_entity__c = role;
				LPI_DML.doUpdate(par);

				List<BusinessLicenseApplication> blaList = LPI_BusinessLicenseApplicationDAO.getBusinessLicenseApplicationByDymanicQuery(
					'Id',
					'SavedApplicationRefId =\'' + parId + '\'',
					null,
					null,
					null
				);
				if (!blaList.isEmpty()) {
					BusinessLicenseApplication bla = new BusinessLicenseApplication(Id = blaList[0].Id);
					bla.AccountId = accId;
					LPI_DML.doUpdate(bla);
				}

				outMap.put(BUSINESS_ACC_ID, accId);
				outMap.put(BUSINESS_LOCATION_ID, businlocId);
				outMap.put(TEMP_AUTH_APP_PLACE_ID, tempAuthAppPlaceId);
				outMap.put('aapBusinessId', aapBusinessId);
				outMap.put(BUSINESS_LOCATION_ADDRESS_ID, schoolBusinessLocAddressId);
			}
		} catch (Exception exceptionInstance) {
			LPI_ExceptionManager.logException(CLASS_NAME, METHOD_CREATE_SCHOOL_ACCOUNT, exceptionInstance);
			outMap.put(IS_ERROR, true);
		}
	}

	/**
	 * @author               : MTX Group Product Team
	 * @description          : This method will create/update the Business Relationships record
	 * @param parId          : PAR record Id
	 * @param accountId      : School account id
	 * @last modified by     : MTX Group Product Team
	 * @last modified date   : 20 June 2023
	 * @param role           : Business Relationships role
	 */
	public static void upsertACRRecord(String parId, String accountId, String role) {
		try {
			if (String.isNotBlank(role) && String.isNotBlank(accountId) && String.isNotBlank(parId)) {
				String fieldsToQueryPARForACR = 'Id, Contact__r.AccountId, Business_Info_Relation_Id__c, How_are_you_associated_to_this_entity__c';
				String whereClauseForPARfields = 'Id = \'' + String.escapeSingleQuotes(parId) + '\'';
				List<PreliminaryApplicationRef> parRecordsList = LPI_PreliminaryApplicationRefDAO.getPreliminaryApplicationRefByDymanicQuery(
					fieldsToQueryPARForACR,
					whereClauseForPARfields,
					'1',
					null,
					null
				);
				if (!parRecordsList.isEmpty()) {
					List<User> listOfUser = LPI_UserDao.getCurrentUserRecord();
					if (listOfUser.isEmpty()) {
						return;
					}
					List<Business_Relationships__c> deleteBusinessRelationList = new List<Business_Relationships__c>();
					List<Business_Relationships__c> insertBusinessRelationList = new List<Business_Relationships__c>();
					List<String> insertedRolesList = role.split(' \\+ ');
					LPI_BusinessRelationshipDAO.LPI_BusinessRelationshipsWithoutSharingDAO acrDAOInstance = new LPI_BusinessRelationshipDAO.LPI_BusinessRelationshipsWithoutSharingDAO();
					String fieldsToQueryACRs = 'Id, Roles__c, IsActive__c, Start_Date__c, EndDate__c';
					String whereClauseForACRs =
						'Related_From__c = \'' +
						String.escapeSingleQuotes(accountId) +
						'\'' +
						' AND ' +
						'Related_To__c = \'' +
						listOfUser[0].AccountId +
						'\'' +
						' AND Roles__c IN ' +
						LPI_ServiceUtility.getStringValuesByStringSet(ASSOCIATE_ROLE_SET) +
						' AND EndDate__c = NULL';
					List<Business_Relationships__c> acrRecList = acrDAOInstance.getBusinessRelationshipsByDymanicQuery(
						fieldsToQueryACRs,
						whereClauseForACRs,
						'2',
						null,
						null
					);

					for (Business_Relationships__c br : acrRecList) {
						if (insertedRolesList.contains(br.Roles__c)) {
							insertedRolesList.remove(insertedRolesList.indexOf(br.Roles__c));
						} else {
							deleteBusinessRelationList.add(br);
						}
					}
					for (String tempRole : insertedRolesList) {
						Business_Relationships__c acrToCreate = new Business_Relationships__c();
						acrToCreate.Roles__c = tempRole;
						acrToCreate.IsActive__c = false;
						acrToCreate.Start_Date__c = System.today();
						acrToCreate.Related_From__c = accountId;
						acrToCreate.Related_To__c = parRecordsList[0].Contact__r.AccountId;
						insertBusinessRelationList.add(acrToCreate);
					}
					List<Business_Relationships__c> brInsertList = new List<Business_Relationships__c>();
					if (
						!insertBusinessRelationList.isEmpty() &&
						LPI_RelationshipService.findDuplicates(insertBusinessRelationList).isEmpty()
					) {
						brInsertList = (List<Business_Relationships__c>) LPI_WithoutSharingUtility.insertSObjectList(
							insertBusinessRelationList
						);
					}
					if (!deleteBusinessRelationList.isEmpty()) {
						for (Business_Relationships__c br : deleteBusinessRelationList) {
							parRecordsList[0].Business_Info_Relation_Id__c = null;
						}
						LPI_WithoutSharingUtility.deleteSObject(deleteBusinessRelationList);
					}
					if (!brInsertList.IsEmpty()) {
						for (Business_Relationships__c br : brInsertList) {
							parRecordsList[0].Business_Info_Relation_Id__c = br.Id;
						}
					}

					if (!brInsertList.IsEmpty() || !deleteBusinessRelationList.isEmpty()) {
						LPI_DML.doUpdate(parRecordsList[0]);
					}
				}
			}
		} catch (Exception exceptionInstance) {
			LPI_ExceptionManager.logException(CLASS_NAME, 'upsertACRRecord', exceptionInstance);
		}
	}

	/**
	 * @author               : MTX Group Product Team
	 * @description          : This method will check duplicate account and create Account instance
	 * @param stepConInfo    : Input map for Account field mapping
	 * @param isExternalUser : Is Portal/External user
	 */
	private static Account createSchoolAccountRecord(
		Map<String, Object> stepConInfo,
		Boolean isExternalUser,
		String licenseType,
		String parId
	) {
		try {
			Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
				.get(LPI_LiteralConstant.ACCOUNT_BUSINESS_RECORDTYPE)
				.getRecordTypeId();
			 
			Map<String, Object> relationShipBlk = (Map<String, object>) stepConInfo.get('RelationshipDataBLK');
			String howAreYouAssociated = relationShipBlk != null && relationShipBlk.containsKey(HOW_ARE_YOU_ASSOCIATED)
				? (String) relationShipBlk.get(HOW_ARE_YOU_ASSOCIATED)
				: null;

			String name = (String) stepConInfo.get(SCHOOL_NAME);
			if (US_COUNTRY_CODE.equalsIgnoreCase((String) stepConInfo.get(SCHOOL_COUNTRY_CODE))) {
				KEY_MAPING_FOR_ACCOUNT.put(SCHOOL_STATE, 'BillingStateCode');
			} else {
				KEY_MAPING_FOR_ACCOUNT.put(SCHOOL_STATE_FOR_NON_US_COUNTRY, 'Other_State__c');
			}
			 
			Account schoolAccountRecord = (Account) LPI_VlocityUtility.createSObject(
				stepConInfo,
				KEY_MAPING_FOR_ACCOUNT,
				SOBJECT_ACCOUNT
			);
			List<User> userList = LPI_UserDao.getUserByDymanicQueryWithoutSecurityEnforced(
				'Id,Profile.Name',
				'Id=\'' + UserInfo.getUserId() + '\'',
				null,
				null,
				null
			);

			List<PreliminaryApplicationRef> parList = LPI_PreliminaryApplicationRefDAO.getPreliminaryApplicationRefByDymanicQuery(
				'Id,BusinessAccountNameId,BusinessAccountName.Name',
				'Id =\'' + parId + '\'',
				null,
				null,
				null
			);
			if (!parList.isEmpty()) {
				schoolAccountRecord.put('Name', name);
			}

			if (userList[0].Profile.Name == 'Portal User') {
				schoolAccountRecord.put('Name', name);
			}

			schoolAccountRecord.put('RecordTypeId', accRecordTypeId);
			if (isExternalUser) {
				schoolAccountRecord.put('How_are_you_associated_to_this_entity__c', howAreYouAssociated);
			}
			if (relationShipBlk != null && relationShipBlk.get('FRML_OwnershipType') != null) {
				schoolAccountRecord.put('Entity_type__c', (String) relationShipBlk.get('FRML_OwnershipType'));
				schoolAccountRecord.put(
					'Other_Entity_Type__c',
					(String) schoolAccountRecord.get('Entity_type__c') == 'Other'
						? relationShipBlk.get('OtherOwnershipType')
						: ''
				);
			}
			List<Datacloud.MatchRecord> existingAccountId = new List<Datacloud.MatchRecord>();
			existingAccountId = LPI_WithoutSharingUtility.getDuplicateRecordsService(
				new List<Account>{ schoolAccountRecord }
			);
			if (!existingAccountId.isEmpty()) {
				schoolAccountRecord.Id = existingAccountId[0].getRecord().Id;
			}

			return schoolAccountRecord;
		} catch (Exception exp) {
			LPI_ExceptionManager.logException(CLASS_NAME, 'createSchoolAccountRecord', exp);
			return null;
		}
	}

	/**
	 * @author          : MTX Group Product Team
	 * @description     : This method is Used to Create School Account
	 * @param inputMap  : fetching all the input from Omniscript
	 * @param outMap    : Passing value to Omniscript
	 */
	public static void fetchSchoolInformation(Map<String, Object> inputMap, Map<String, Object> outMap) {
		try {
			String calledFrom = (String) inputMap.get('iscallingfromos');
			Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
				.get(LPI_LiteralConstant.ACCOUNT_BUSINESS_RECORDTYPE)
				.getRecordTypeId();
			Boolean isReadOnlyStep = (Boolean) inputMap.get(IS_READ_ONLY_STEP);
			String parId = (String) inputMap.get(PAR_ID);
			Boolean isPortalUser = false;
			if (inputMap.containsKey('isPortalUser')) {
				isPortalUser = (Boolean) inputMap.containsKey('isPortalUser');
			}
			List<PreliminaryApplicationRef> parList;
			if (String.isNotEmpty(parId)) {
				parList = LPI_PreliminaryApplicationRefDAO.getPARRecordsByID(new Set<Id>{ parId });
			}
			if (parList == null || parList?.isEmpty()) {
				LPI_ExceptionManager.logException(
					CLASS_NAME,
					METHOD_FETCH_SCHOOL_INFO,
					PAR_NOT_FOUND,
					PAR_NOT_FOUND,
					null,
					null
				);
				return;
			}
			List<Temp_AuthApplicationPlace__c> listOfTempPlace = LPI_TempAuthApplicationPlaceDAO.getTempAuthAppPlacesByPARId(
				new Set<Id>{ parId }
			);
			String tempAuthApplicationPlaceId;
			if (!listOfTempPlace.isEmpty()) {
				outMap.put(BUSINESS_LOCATION_ID, listOfTempPlace[0].Location__c);
				for (
					Schema.Address addressRec : LPI_AddressDAO.getAddressByDymanicQuery(
						'Id',
						'ParentId =\'' + String.escapeSingleQuotes(listOfTempPlace[0].Location__c) + '\'',
						null,
						null,
						null
					)
				) {
					outMap.put(BUSINESS_LOCATION_ADDRESS_ID, addressRec.Id);
				}
			}
			String licenseNameRAT = parList[0].Regulatory_Authorization_Type__r.Name;
			outMap.put('showAllOwnerShipType', notAllowAllOwnerShip.contains((String) licenseNameRAT) ? false : true);
			String queryBusinessAccountId = '';
			 
				queryBusinessAccountId = parList[0].BusinessAccountNameId;
			 
			for (
				Account schoolAcc : LPI_AccountDAO.getAccountListByDynamicQuery(
					LIST_OF_ACCOUNT_FIELDS,
					'Id = \'' + queryBusinessAccountId + '\'AND RecordTypeId = \'' + accRecordTypeId + '\'',
					null,
					null,
					null
				)
			) {
				String licenseName = parList[0].Regulatory_Authorization_Type__r.Name;
				String type = parList[0].Type__c;
				String accountName = schoolAcc.Name;
				String name;
				if (isReadOnlyStep == null || !isReadOnlyStep) {
					if (String.isNotBlank(name)) {
						outMap.put(SCHOOL_NAME, name);
					} else {
						outMap.put(SCHOOL_NAME, schoolAcc.Name);
					}
					outMap.put(SCHOOL_TYPE_OF_ORG, schoolAcc.Type_of_Organization__c);
					outMap.put(SCHOOL_EMAIL, schoolAcc.Buisness_Email__c);
					outMap.put(SCHOOL_FAX_NUMBER, schoolAcc.Fax);
					outMap.put(SCHOOL_STATE, schoolAcc.BillingStateCode);
					outMap.put(SCHOOL_STATE_FOR_NON_US_COUNTRY, schoolAcc.Other_State__c);
					outMap.put(SCHOOL_CITY, schoolAcc.BillingCity);
					outMap.put(SCHOOL_ZIP_CODE, schoolAcc.BillingPostalCode);
					outMap.put(SCHOOL_TELEPHONE, schoolAcc.Phone);
					outMap.put(SCHOOL_STREET, schoolAcc.BillingStreet);
					outMap.put('SchoolStreetAddress', schoolAcc.BillingStreet);
					outMap.put('County', schoolAcc.County__c);
					outMap.put('SchoolEditableStateUS',schoolAcc.BillingStateCode);
					outMap.put(SCHOOL_WEBSITE, schoolAcc.Website);
					outMap.put(SCHOOL_COUNTRY_CODE, schoolAcc.BillingCountryCode);
					outMap.put('OwnerShipTypeAll', schoolAcc.Entity_type__c);
					outMap.put('OwnerShipTypeFew', schoolAcc.Entity_type__c);
					outMap.put('OwnerShipFormulaCheck', schoolAcc.Entity_type__c);
					outMap.put('OwnershipType', schoolAcc.Entity_type__c);
					outMap.put('OtherOwnershipType', schoolAcc.Other_Entity_Type__c);
					outMap.put('OtherOwnershipTypeRO', schoolAcc.Other_Entity_Type__c);
				} else if (isReadOnlyStep) {
					if (String.isNotBlank(name)) {
						outMap.put(SCHOOL_NAME_RO, name);
					} else {
						outMap.put(SCHOOL_NAME_RO, schoolAcc.Name);
					}
					outMap.put(SCHOOL_TYPE_OF_ORG_RO, schoolAcc.Type_of_Organization__c);
					outMap.put(SCHOOL_EMAIL_RO, schoolAcc.Buisness_Email__c);
					outMap.put(SCHOOL_FAX_NUMBER_RO, schoolAcc.Fax);
					outMap.put(SCHOOL_CITY_RO, schoolAcc.BillingCity);
					outMap.put(SCHOOL_ZIP_CODE_RO, schoolAcc.BillingPostalCode);
					outMap.put(SCHOOL_TELEPHONE_RO, schoolAcc.Phone);
					outMap.put(SCHOOL_STREET_RO, schoolAcc.BillingStreet);
					outMap.put(SCHOOL_WEBSITE_RO, schoolAcc.Website);
				}
				outMap.put(HOW_ARE_YOU_ASSOCIATED, schoolAcc.How_are_you_associated_to_this_entity__c);
				outMap.put(SCHOOL_COUNTRY, schoolAcc.BillingCountry);
				outMap.put(BUSINESS_ACC_ID, schoolAcc.Id);
				outMap.put(ASSOCIATED_TO_ENTITY_RO, schoolAcc.How_are_you_associated_to_this_entity__c);
				if (US_COUNTRY_CODE.equalsIgnoreCase(schoolAcc.BillingCountryCode)) {
					if (type == ANNUAL_REPORT_SURVEY) {
						outMap.put(SCHOOL_STATE_RO, schoolAcc.BillingState);
						outMap.put(ASSOCIATED_TO_ENTITY_RO, schoolAcc.How_are_you_associated_to_this_entity__c);
					} else {
						outMap.put(SCHOOL_STATE_RO, schoolAcc.BillingState);
					}
				} else {
					if (type == ANNUAL_REPORT_SURVEY) {
						outMap.put(SCHOOL_STATE_RO, schoolAcc.Other_State__c);
						outMap.put(ASSOCIATED_TO_ENTITY_RO, schoolAcc.How_are_you_associated_to_this_entity__c);
					} else {
						outMap.put('SchoolStateForNonUSCountryRO', schoolAcc.Other_State__c);
						outMap.put(SCHOOL_STATE_RO, schoolAcc.Other_State__c);
					}
				}
			}
			if (parList[0].BusinessAccountName.RecordTypeId == accRecordTypeId && String.isNotBlank(calledFrom)) {
				updateHowAreYouAssociatedToThisEntity(parList[0], outMap);
			} else if (parList[0].BusinessAccountName.RecordTypeId == accRecordTypeId) {
				String personRole = parList[0].How_are_you_associated_to_this_entity__c;
				outMap.put(HOW_ARE_YOU_ASSOCIATED, personRole);
				outMap.put(HOW_ARE_YOU_ASSOCIATE_RO, personRole);
			}
		} catch (Exception exceptionInstance) {
			LPI_ExceptionManager.logException(CLASS_NAME, METHOD_FETCH_SCHOOL_INFO, exceptionInstance);
		}
	}

	/**
	 * @author          : MTX Group Product Team
	 * @description     : This method will update How you are assocaiated value by login user Business Relationships role
	 * @param inputMap  : fetching all the input from Omniscript
	 * @param outMap    : Passing value to Omniscript
	 * @last modified by    : MTX Group Product Team
	 * @last modified date  : 20 June 2023
	 */
	public static void updateHowAreYouAssociatedToThisEntity(
		PreliminaryApplicationRef parRecord,
		Map<String, Object> outMap
	) {
		List<User> listOfUser = LPI_UserDao.getCurrentUserRecord();
		if (listOfUser.isEmpty()) {
			return;
		}
		Boolean isExternalUser = listOfUser[0].IsPortalEnabled;
		Id brId;
		if (isExternalUser) {
			LPI_BusinessRelationshipDAO.LPI_BusinessRelationshipsWithoutSharingDAO acrDAOInstance = new LPI_BusinessRelationshipDAO.LPI_BusinessRelationshipsWithoutSharingDAO();
			String whereClauseForACRs =
				'Related_From__c = \'' +
				parRecord.BusinessAccountNameId +
				'\'' +
				' AND ' +
				'Related_To__c = \'' +
				listOfUser[0].AccountId +
				'\'';

			List<Business_Relationships__c> acrRecList = acrDAOInstance.getBusinessRelationshipsByDymanicQuery(
				'Roles__c',
				whereClauseForACRs,
				'2',
				null,
				null
			);
			String personRole;
			if (!acrRecList?.isEmpty()) {
				Set<String> existingRolesSet = new Set<String>();
				for (Business_Relationships__c br : acrRecList) {
					existingRolesSet.add(br.Roles__c);
				}
				if (existingRolesSet.contains('Temporary Clerk')) {
					personRole = 'Temporary Clerk';
				} else if (existingRolesSet.contains('License Service Provider')) {
					personRole = 'License Service Provider';
				} else {
					personRole = 'Not Applicable';
				}

				if (String.isNotBlank(personRole) && parRecord.How_are_you_associated_to_this_entity__c != personRole) {
					LPI_DML.doUpdate(
						new PreliminaryApplicationRef(
							Id = parRecord.Id,
							How_are_you_associated_to_this_entity__c = personRole
						)
					);
				}
			} else {
				personRole = 'Not Applicable';
				LPI_DML.doUpdate(
					new PreliminaryApplicationRef(
						Id = parRecord.Id,
						How_are_you_associated_to_this_entity__c = personRole
					)
				);
			}
			outMap.put('isExternalUser', isExternalUser);
			outMap.put(HOW_ARE_YOU_ASSOCIATED, personRole);
			outMap.put('HowAreYouAssociatedToThisEntityRO', personRole);
			outMap.put('HowAreYouAssociatedToThisEntityReadOnly', personRole);
		}
	}
	
}