/**
 * @author          : MTX Group Product Team
 * @Description     : fetching data from Omniscript and creating and fetching School Administrator Information [S-48232]
 * 
 */
global with sharing class LPI_SchoolAdministratorInfoController implements Callable {
	
	private final static String INDIVIDAULICENSE_APPTYPE = 'Individual';
	private final static String ACCOUNT_PERSON_RECORDTYPE = 'PersonAccount';
	private final static String OWNER = 'Owner';
	private final static String PERSON_INCHARGE = 'Designated Incharge';
	private final static String CLASS_NAME = 'LPI_SchoolAdministratorInfoController';
	private final static String LINK_ADMIN_OWNER_DETAILS = 'linkAdminOwnerDetails';
	
	private final static String FETCH_LICENSED_ADMINISTRATOR_DETAILS = 'fetchLicensedAdministratorDetails';
	private final static String FETCH_ADMINISTRATOR_USER_DETAILS = 'fetchAdministratorUserDetails';
	private final static Set<String> OWNER_PERSON_INCHARGE_SET = new Set<String>{ OWNER, PERSON_INCHARGE };
	private final static String REJECTION_METADATA_API_NAME = 'CosBar_School_Admin_Owner_Rejection';
	private final static String APPROVED_METADATA_API_NAME = 'CosBar_School_Admin_Owner_Approved';
	private final static String APPROVED_STATUS = 'Approved';
	private final static String REJECTED_STATUS = 'Rejected';
	private final static String REJECTED_REASON = 'rejectedReason';
	private final static String PAR_OBJECT = 'PreliminaryApplicationRef';
	
	private final static String PENDING_STATUS = 'Pending';
	private final static String UPDATE_SUPERVISOR_APPROVAL_STATUS = 'updateAdminOwnerApprovalStatus';
	private final static String SEND_EMAIL_NOTIFICATION = 'sendEmailNotification';
	private final static String CREATE_RELATIONSHIP_RECORD = 'createRelationshipRecord';
	public static final String ROLE_AUTHORIZED_CONTACT = 'Authorized Contact';
	
	private final static String OWNER_REJECTION_METADATA_API_NAME = 'CosBar_School_Owner_Rejection';
	public final static Set<String> COSBAR_SCHOOL_LICENSE_SET = new Set<String>{
		'School of Barbering',
		'School of Cosmetology',
		'School of Cosmetology & Barbering'
	};
	
	private final static String APPROVAL_INFO = 'Approval Information';
	 
	public final static Set<String> BARBER_EST_SET = new Set<String>{ 
		'Barber Establishment',
		'Cosmetology Establishment',
		'Beauty/Barber Establishment'
	};
	 
	public final static Set<String> TATTOOING_EST_SET = new Set<String>{ 
		'Tattooing Establishment',
		'Body Piercing Establishment',
		'Tattooing, Branding & Body Piercing Establishment',
		'Branding & Body Piercing Establishment',
		'Tattooing & Branding Establishment',
		'Tattooing & Body Piercing Establishment',
		'Branding Establishment'
	};
	private final static String NOTIFICATION_FOR_REQUEST_REJECTED = 'Notification_for_Request_Rejected';

	 
	/**
	 * @author                      : MTX Group Product Team
	 * @since                       : 23rd Jun, 2023
	 * @description                 : This method is used to call the invoke method
	 * @param action                : String
	 * @param args			        : Map<String, Object>
	 * @return                      : Object
	 * @last modified by            : MTX Group Product Team
	 * @last modified date          :
	 * @modified details            :
	 */
	global Object call(String action, Map<String, Object> args) {
		Map<String, Object> input = (Map<String, Object>) args.get(LPI_LiteralConstant.INPUT);
		Map<String, Object> output = (Map<String, Object>) args.get(LPI_LiteralConstant.OUTPUT);
		Map<String, Object> options = (Map<String, Object>) args.get(LPI_LiteralConstant.OPTIONS);
		return invokeMethod(action, input, output, options);
	}

	/**
	 * @author               		: MTX Group Product Team
	 * @param methodName     		: InvokeMethod
	 * @param inputMap       		: Input Parameter Passed from Omniscript
	 * @param outMap         		: Output Passed to Omniscript
	 * @param options        		: Extra Options passed from Omniscript
	 * @return  			 		: `Boolean`
	 * @last modified by     		: MTX Group Product Team
	 * @last modified date   		:
	 * @modified details     		:
	 */
	private Boolean invokeMethod(
		String methodName,
		Map<String, Object> inputMap,
		Map<String, Object> outMap,
		Map<String, Object> options
	) {
		Boolean result = true;
		try {
			if (methodName.equals(LINK_ADMIN_OWNER_DETAILS)) {
				linkAdminOwnerDetails(inputMap, outMap);
			} 
			  
			else if (methodName.equals(FETCH_LICENSED_ADMINISTRATOR_DETAILS)) {
				outMap.put('licenseRecords', fetchLicensedAdministratorDetails(inputMap, options));
			} 
			 
			else {
				result = false;
			}
		} catch (Exception e) {
			LPI_ExceptionManager.logException(CLASS_NAME, 'invokeMethod', e);
		}
		return result;
	}

	private static Map<String, String> keyMappingForAccount;

	/**
	 * @author                       : MTX Group Product Team
	 * @since                        : Jun 23, 2023
	 * @description                  : get searched License Number's Account [Administrator(Designate Incharge)] Details
	 * @param inputMap               : input map
	 * @param options                : options map
	 * @return                       : List<Map<String, object>>
	 */
	public static List<Map<String, object>> fetchLicensedAdministratorDetails(
		Map<String, Object> inputMap,
		Map<String, Object> options
	) {
		List<Map<String, Object>> licenseList = new List<Map<String, Object>>();
		try {
			List<PreliminaryApplicationRef> parList = new List<PreliminaryApplicationRef>();
			Set<Id> blIdSet = new Set<Id>();
			String adminLicenseNumber = '%' + (String) inputMap.get('AdministratorLicenseNumber') + '%';
			if (String.isNotBlank(adminLicenseNumber)) {
				String blFields =
					'Id, Name, License_Number_With_Rat_Name__c, Account.FirstName, Account.MiddleName, Account.PersonOtherStreet, Account.PersonOtherPostalCode,Account.Phone, Account.LastName, AccountId, Account.PersonHomePhone, Account.Fax ,' +
					'Account.PersonContactId, Account.Date_of_Birth__c, Account.PersonOtherCity,Account.PersonOtherCountry, Account.PersonOtherCountryCode, Account.PersonOtherStateCode, Account.PersonOtherState, Account.PersonEmail, Account.Social_Security_Number__c, Contact.AccountId,Contact.Account.Name';
				String blWhereClause =
					' Name LIKE \'' +
					String.escapeSingleQuotes(adminLicenseNumber) +
					'\'' +
					' AND RegulatoryAuthorizationType.Authorisation_Type__c= \'' +
					INDIVIDAULICENSE_APPTYPE +
					'\'' +
					' AND Account.RecordType.DeveloperName = \'' +
					ACCOUNT_PERSON_RECORDTYPE +
					'\'';
				LPI_BusinessLicenseDAO.LPI_BusinessLicenseWithoutSharingDAO bLListWithOutSharing = new LPI_BusinessLicenseDAO.LPI_BusinessLicenseWithoutSharingDAO();
			 
				for (
					BusinessLicense bl : bLListWithOutSharing.getBusinessLicenseByDymanicQuery(
						blFields,
						blWhereClause,
						'100',
						null,
						null
					)
				) {
					Map<String, Object> licenseMap = new Map<String, Object>();
					licenseMap.put('blId', bl.Id);
					licenseMap.put('Name', bl.Name);
					licenseMap.put('TypeAheadKeyName', bl.License_Number_With_Rat_Name__c);
					licenseMap.put('DesignatedInchargeFirstName', bl.Account.FirstName);
					licenseMap.put('DesignatedInchargeMiddleName', bl.Account.MiddleName);
					licenseMap.put('DesignatedInchargeLastName', bl.Account.LastName);
					licenseMap.put('DesignatedInchargeDOB', bl.Account.Date_of_Birth__c);
					licenseMap.put('DesignatedInchargePhoneNumber', bl.Account.PersonHomePhone);
					licenseMap.put('DesignatedInchargeEmail', bl.Account.PersonEmail);
					licenseMap.put('DesignatedInchargeSSN', bl.Account.Social_Security_Number__c);
					licenseMap.put('DesignatedInchargeMobileNumber', bl.Account.Phone);
					licenseMap.put('AccountId', bl.AccountId);
					licenseMap.put('DesignatedInchargeMailingStreetAddress', bl.Account.PersonOtherStreet);
					licenseMap.put('DesignatedInchargeMailingCity', bl.Account.PersonOtherCity);
					licenseMap.put('DesignatedInchargeMailingState', bl.Account.PersonOtherState);
					licenseMap.put('DesignatedInchargeMailingStateCode', bl.Account.PersonOtherStateCode);
					licenseMap.put('DesignatedInchargeMailingCountry', bl.Account.PersonOtherCountry);
					licenseMap.put('DesignatedInchargeMailingCountryCode', bl.Account.PersonOtherCountryCode);
					licenseMap.put('DesignatedInchargeMailingZipCode', bl.Account.PersonOtherPostalCode);
					licenseList.add(licenseMap);
				}
			}
		} catch (Exception e) {
			LPI_ExceptionManager.logException(CLASS_NAME, FETCH_LICENSED_ADMINISTRATOR_DETAILS, e);
		}
		return licenseList;
	}

	/**
	 * @author                    : MTX Group Product Team
	 * @description               : linking designated incharge to business account
	 * @param inputMap            : fetching all the input from Omniscript
	 * @since                     : 23 Jun 2023
	 * @return                    : `void`
	 * @last modified by          : MTX Group Product Team
	 * @last modified date        :
	 * @last modified details     :
	 */
	private static Boolean linkAdminOwnerDetails(Map<String, Object> inputMap, Map<String, Object> outMap) {
		Boolean isSuccess = false;
		String isNursing;
		try {
			String businessAccId = (String) inputMap.get('businessAccId');
			String parId = (String) inputMap.get('parId');
			String brId = (String) inputMap.get('brId');
			String parWhereClause;
			Account personAccount;
			List<PreliminaryApplicationRef> parList = new List<PreliminaryApplicationRef>();
			List<Business_Relationships__c> brList = new List<Business_Relationships__c>();
			List<Business_Relationships__c> relationshipToDeleteList = new List<Business_Relationships__c>();
			String licNumber;
			String blId;
			String blAccountId;
			String adminHireDate;
			String adminProgramLong;
			String adminHighDegree;
			String adminHighDegreeOther;
			String adminNonDegree;
			String adminNonDegreeOther;
			String adminOfficeTelephone;
			Map<String, Object> SchoolAdminInfoStep;
			Map<String, Object> SchoolAdminInfoBlock;
			String addAdmin;
			 
			if (!String.isEmpty(parId)) {
				String parfields =
					'Regulatory_Authorization_Type__r.Name,  BusinessAccountNameId, Regulatory_Authorization_Type__r.Email_Specifications_Final__c,' +
					'BusinessAccountName.Name, Regulatory_Authorization_Type__r.IssuingDepartment.Name,' +
					'Regulatory_Authorization_Type__c,SavedApplicationUrl, Board_Name__c, Contact__r.AccountId ';
				String parWhereCaluse = ' Id =\'' + String.escapeSingleQuotes(parId) + '\'';
				parList = LPI_PreliminaryApplicationRefDAO.getPreliminaryApplicationRefByDymanicQuery(
					parfields,
					parWhereCaluse,
					null,
					null,
					null
				);
			}
			 
			if (COSBAR_SCHOOL_LICENSE_SET.contains(parList[0].Regulatory_Authorization_Type__r.Name)) {
				SchoolAdminInfoStep = (Map<String, object>) inputMap.get('SchoolAdministratorInformation');
			}   
			else {
				SchoolAdminInfoStep = (Map<String, object>) inputMap.get(
					'ProgramAdministratorInformation'
				);
			}
			SchoolAdminInfoBlock = (Map<String, object>) SchoolAdminInfoStep.get('OwnerBlock');
			Map<String, Object> SchoolLicensedAdminInfo;
			String isLicensed;
			if(SchoolAdminInfoStep != null){
				addAdmin = (String) SchoolAdminInfoStep.get('SchoolApplicationAddAdmin');
			}
			if (SchoolAdminInfoBlock != null) {
				SchoolLicensedAdminInfo = (Map<String, object>) SchoolAdminInfoBlock.get(
					'AdministratorLicenseNumber-Block'
				);
				isNursing = (String) SchoolAdminInfoStep.get('IsProgramDirectorLicensed');
				isLicensed = COSBAR_SCHOOL_LICENSE_SET.contains(parList[0].Regulatory_Authorization_Type__r.Name)
					? (String) SchoolAdminInfoBlock.get('SchoolApplicationAdminIsLicensed')
					: (String) SchoolAdminInfoStep.get('SchoolApplicationAdminIsLicensed');
				adminHireDate = (String) SchoolAdminInfoBlock.get('ProgramAdministratorInfoHireDate');
				adminProgramLong = (String) SchoolAdminInfoBlock.get(
					'ProgramAdministratorInfoProgLong'
				);
				adminHighDegree = (String) SchoolAdminInfoBlock.get(
					'ProgramAdministratorInfoHighDegree'
				);
				adminHighDegreeOther = (String) SchoolAdminInfoBlock.get(
					'ProgramAdministratorInfoHighDegOther'
				);
				adminNonDegree = (String) SchoolAdminInfoBlock.get('ProgramAdministratorInfoNonDegree');
				adminNonDegreeOther = (String) SchoolAdminInfoBlock.get(
					'ProgramAdministratorInfoNonDegOther'
				);
			}
			else {
				isLicensed = (String) SchoolAdminInfoStep.get('SchoolApplicationAdminIsLicensed');
			}
			if (SchoolLicensedAdminInfo != null) {
				licNumber = (String) SchoolLicensedAdminInfo.get('Name');
				blId = (String) SchoolLicensedAdminInfo.get('blId');
				blAccountId = (String) SchoolLicensedAdminInfo.get('AccountId');
				adminOfficeTelephone = (String) SchoolLicensedAdminInfo.get('DesignatedInchargePhoneNumber');
			}
			if (String.isNotBlank(isLicensed) || String.isNotBlank(addAdmin)) {
				 
				if (String.isNotBlank(brId)) {
					LPI_BusinessRelationshipDAO.LPI_BusinessRelationshipsWithoutSharingDAO instance = new LPI_BusinessRelationshipDAO.LPI_BusinessRelationshipsWithoutSharingDAO();
					relationshipToDeleteList = instance.getBusinessRelationshipsByDymanicQuery(
						'Id, Is_Licensed_Entity__c, Related_To__c',
						'Id = \'' + brId + '\'',
						null,
						null,
						null
					);
				}
				 
				if (!relationshipToDeleteList.isEmpty()) {
					String unlicensedAccId;
					if(relationshipToDeleteList[0].Is_Licensed_Entity__c == LPI_LiteralConstant.LPI_NO)
					{
						unlicensedAccId = relationshipToDeleteList[0].Related_To__c;
					}
					LPI_WithoutSharingUtility.deleteSObject(relationshipToDeleteList[0]);
					if(String.isNotBlank(unlicensedAccId))
					{
						Account accToDel = new Account(Id = unlicensedAccId);
						LPI_WithoutSharingUtility.deleteSObject(accToDel);
					}
				}
				if (isLicensed == LPI_LiteralConstant.LPI_NO) {
					 
					if (COSBAR_SCHOOL_LICENSE_SET.contains(parList[0].Regulatory_Authorization_Type__r.Name)) {
						personAccount = upsertPersonAccount(SchoolAdminInfoBlock, businessAccId);
					}
				}
				 
				if (String.isNotBlank(isNursing)){
					if (isNursing == LPI_LiteralConstant.LPI_NO) {
						personAccount = upsertPersonAccountNursing(SchoolAdminInfoBlock, businessAccId);
					}
				}
				 
				if (personAccount != null || !String.isEmpty(blAccountId)) {
					if(COSBAR_SCHOOL_LICENSE_SET.contains(parList[0].Regulatory_Authorization_Type__r.Name)){
					brList = createRelationshipRecord(
						businessAccId,
						isLicensed == LPI_LiteralConstant.LPI_YES ? blAccountId : personAccount.Id,
						PERSON_INCHARGE,
						isLicensed == LPI_LiteralConstant.LPI_YES ? licNumber : null,
						isLicensed == LPI_LiteralConstant.LPI_YES ? LPI_LiteralConstant.LPI_YES : LPI_LiteralConstant.LPI_NO,
						isLicensed == LPI_LiteralConstant.LPI_YES ? blId : null
					);
					outMap.put('brId', brList[0]?.Id);
					}
					else {
						brList = createRelationshipRecord(
						businessAccId,
						isNursing == LPI_LiteralConstant.LPI_YES ? blAccountId : personAccount.Id,
						PERSON_INCHARGE,
						isNursing == LPI_LiteralConstant.LPI_YES ? licNumber : null,
						isNursing == LPI_LiteralConstant.LPI_YES ? LPI_LiteralConstant.LPI_YES : LPI_LiteralConstant.LPI_NO,
						isNursing == LPI_LiteralConstant.LPI_YES ? blId : null
					);
					outMap.put('brId', brList[0]?.Id);
					}
				}
			}
			 
			if (
				!parList.isEmpty() &&
				COSBAR_SCHOOL_LICENSE_SET.contains(parList[0].Regulatory_Authorization_Type__r.Name)
			) {
				List<PreliminaryApplicationRef> updateParList = new List<PreliminaryApplicationRef>();
				List<SObject> updateSobjList = new List<SObject>();
				 
				Map<String, Object> strObjMap = fetchAdministratorUserDetails(parList[0]);
				List<Business_Relationships__c> businessRelationList = strObjMap.containsKey('businessRelationList')
					? (List<Business_Relationships__c>) strObjMap.get('businessRelationList')
					: new List<Business_Relationships__c>();
				 
				if (!businessRelationList.isEmpty()) {
					String acrIds;
					Integer numOfRels = 0;
					for (Business_Relationships__c br : businessRelationList) {
						numOfRels += 1;
						if (numOfRels == 1) {
							acrIds = br.Id;
						} else {
							acrIds += ',' + br.Id;
						}
					}
					 
					PreliminaryApplicationRef newPar = new PreliminaryApplicationRef();
					newPar.Id = parId;
					newPar.Person_Incharge_Relation_Id__c = brList.isEmpty() ? null : brList[0].Id;
					newPar.Approval_Supervisors_AcrIds__c = acrIds;
				 
					updateSobjList.add(newPar);
				}
				 
				if (!updateSobjList.isEmpty()) {
					LPI_DML.doUpdate(updateSobjList);
				}
			}
			 
			if (!parList.isEmpty()) {
				PreliminaryApplicationRef par = new PreliminaryApplicationRef(Id = parList[0]?.Id);
				if(!COSBAR_SCHOOL_LICENSE_SET.contains(parList[0].Regulatory_Authorization_Type__r.Name))
				{
					 
					par.Person_Incharge_Relation_Id__c = brList.isEmpty() ? null : brList[0].Id;
					LPI_DML.doUpdate(par);
				}
				 
				if(!COSBAR_SCHOOL_LICENSE_SET.contains(parList[0].Regulatory_Authorization_Type__r.Name)
					&& String.isNotBlank(blAccountId) && String.isNotBlank(adminOfficeTelephone))
				{
					Account acc = new Account(Id = blAccountId);
					acc.PersonHomePhone = adminOfficeTelephone;
					LPI_WithoutSharingUtility.updateSObject(acc);  
				}
			}
		} catch (Exception e) {
			LPI_ExceptionManager.logException(CLASS_NAME, LINK_ADMIN_OWNER_DETAILS, e);
		}
		return isSuccess;
	}

	/**
	 * @author                      : MTX Group Product Team
	 * @since                       : 23 Jun 2023
	 * Description                  : upserting Person Account for CosBar School
	 * @param inputMap              : Input data passed from OmniScript
	 * @param return                : returning account
	 * @last modified by            : MTX Group Product Team
	 * @last modified date          :
	 * @last modified details       :
	 */

	private static Account upsertPersonAccount(Map<String, Object> inputMap, String accountId) {
		Account personAccount;
		try {
			Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
				.get(LPI_LiteralConstant.ACCOUNT_PERSON_RECORDTYPE)
				.getRecordTypeId();
			Map<String, object> unLicensedAdministratorInfo = (Map<String, object>) inputMap.get(
				'UnLicensedAdministratorDetails'
			);
			 
			if (!unLicensedAdministratorInfo.isEmpty()) {
				keyMappingForAccount = new Map<String, String>{
					'AdminEmail' => 'PersonEmail',
					'AdminTelephone' => 'PersonHomePhone',
					'AdminMobile' => 'Phone',
					'AdministratorFirstName' => 'FirstName',
					'AdministratorMiddleName' => 'MiddleName',
					'AdministratorLastName' => 'LastName',
					'AdminStreet' => 'PersonOtherStreet',
					'AdminCity' => 'PersonOtherCity',
					'AdminState' => 'PersonOtherStateCode',
					'AdminZipCode' => 'PersonOtherPostalCode',
					'AdminSSN' => 'Social_Security_Number__c',
					'AdminDOB' => 'Date_of_Birth__c'
				};
			}

			personAccount = (Account) LPI_VlocityUtility.createSObject(
				unLicensedAdministratorInfo,
				keyMappingForAccount,
				'Account'
			);
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
			personAccount.PersonOtherCountryCode = LPI_LiteralConstant.US_COUNTRY_CODE;

			 
			List<Datacloud.MatchRecord> existingAccountId = new List<Datacloud.MatchRecord>();
			existingAccountId = LPI_WithoutSharingUtility.getDuplicateRecordsService(
				new List<Account>{ personAccount }
			);
			 
			if (!existingAccountId.isEmpty()) {
				personAccount.Id = existingAccountId[0].getRecord().Id;
			}
			personAccount = (Account) LPI_WithoutSharingUtility.upsertSObject(personAccount);
		} catch (Exception e) {
			LPI_ExceptionManager.logException(CLASS_NAME, 'upsertPersonAccount', e);
		}
		return personAccount;
	}

		/**
	 * @author                      : MTX Group Product Team
	 * @since                       : 23 Nov 2023
	 * Description                  : upserting Person Account for Nursing
	 * @param inputMap              : Input data passed from OmniScript
	 * @param return                : returning account
	 * @last modified by            : MTX Group Product Team
	 * @last modified date          :
	 * @last modified details       :
	 */

	 private static Account upsertPersonAccountNursing(Map<String, Object> inputMap, String accountId){
		Account personAccount;
		try {
			Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
				.get(LPI_LiteralConstant.ACCOUNT_PERSON_RECORDTYPE)
				.getRecordTypeId();

			Map<String, object> unLicensedAdministratorInfo = (Map<String, object>) inputMap.get(
				'ProgramDirectorNonLicensedBlock'
			);

			Map<String, object> unLicensedAdministratorInfoNew = (Map<String, object>) inputMap.get(
				'ProgramDirectorNonLicensedBlockNew'
			);

			Map<String, object> unLicensedAdministratorInfoLWC = (Map<String, object>) inputMap.get(
				'ProgramDirectorCityCountyZip'
			);

			unLicensedAdministratorInfo.putAll(unLicensedAdministratorInfoNew);
			unLicensedAdministratorInfo.putAll(unLicensedAdministratorInfoLWC);

			 
			if (!unLicensedAdministratorInfo.isEmpty()
			) {
				keyMappingForAccount = new Map<String, String>{
					'ProgramDirectorEmail' => 'PersonEmail',
					'ProgramDirectorTelephone' => 'PersonHomePhone',
					'ProgramDirectorMobile' => 'Phone',
					'ProgramDirectorFirstName' => 'FirstName',
					'ProgramDirectorMiddleName' => 'MiddleName',
					'ProgramDirectorLastName' => 'LastName',
					'ProgramDirectorStreet' => 'PersonOtherStreet',
					'ProgramDirectorCity' => 'PersonOtherCity',
					'ProgramDirectorState' => 'PersonOtherStateCode',
					'ProgramDirectorZipcode' => 'PersonOtherPostalCode',
					'ProgramDirectorCounty' => 'County__c',
					'NcsbnIdNumber' => 'NCSBN_Candidate_ID__c'
				};
			}

			personAccount = (Account) LPI_VlocityUtility.createSObject(
				unLicensedAdministratorInfo,
				keyMappingForAccount,
				'Account'
			);
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
			personAccount.PersonOtherCountryCode = LPI_LiteralConstant.US_COUNTRY_CODE;

			 
			List<Datacloud.MatchRecord> existingAccountId = new List<Datacloud.MatchRecord>();
			existingAccountId = LPI_WithoutSharingUtility.getDuplicateRecordsService(
				new List<Account>{ personAccount }
			);
			 
			if (!existingAccountId.isEmpty()) {
				personAccount.Id = existingAccountId[0].getRecord().Id;
			} else {
				personAccount = (Account) LPI_WithoutSharingUtility.upsertSObject(personAccount);
			}
		}catch (Exception e){
			LPI_ExceptionManager.logException(CLASS_NAME, 'upsertPersonAccountNursing', e);
		}
		return personAccount;
	}

	 

	/**
	 * @author                       : Vamshi Kumar
	 * @since                        : June 23, 2023
	 * @description                  : create relationship record
	 * @param inputMap               : input map
	 * @param outMap                 : output map
	 * @return                       : void
	 */
	private static List<Business_Relationships__c> createRelationshipRecord(
		String accountId,
		String contactId,
		String role,
		String licenseNumOrSSN,
		String licensedInMissouri,
		Id businessLicenseId
	) {
		List<Business_Relationships__c> relationshipList = new List<Business_Relationships__c>();
		try {
			 
			if (String.isNotBlank(accountId) && String.isNotBlank(contactId) && String.isNotBlank(role)) {
				Business_Relationships__c relationshipToCreate = new Business_Relationships__c();
				relationshipToCreate.Related_From__c = accountId;
				relationshipToCreate.Related_To__c = contactId;
				relationshipToCreate.Related_To_License_Number__c = businessLicenseId;
				relationshipToCreate.Roles__c = role;
				relationshipToCreate.Start_Date__c = Date.today();
				relationshipToCreate.EndDate__c = null;
				relationshipToCreate.License_Number__c = licenseNumOrSSN;
				relationshipToCreate.Is_Licensed_Entity__c = licensedInMissouri;
				List<Business_Relationships__c> duplicates = (List<Business_Relationships__c>) LPI_RelationshipService.findDuplicates(
					relationshipToCreate
				);
				 
				if (!duplicates.isEmpty()) {
					relationshipToCreate.Id = duplicates[0].Id;
				}
				 
				relationshipToCreate = (Business_Relationships__c) LPI_WithoutSharingUtility.upsertSObject(
					relationshipToCreate
				);
				relationshipList.add(relationshipToCreate);
			}
		} catch (Exception e) {
			LPI_ExceptionManager.logException(CLASS_NAME, CREATE_RELATIONSHIP_RECORD, e);
		}
		return relationshipList;
	}
	/**
	 * @author                      : MTX Group Product Team
	 * @since                       : June 23, 2023
	 * @description                 : This method is used to fetch Administrator/Owner User details
	 * @story Number				: S-48232
	 * @return                      : `void`
	 * @last modified by            : MTX Group Product Team
	 * @last modified date          : (Add if modified by you)
	 * @modified details            : (Add if modified by you)
	 */
	private static Map<String, Object> fetchAdministratorUserDetails(PreliminaryApplicationRef par) {
		List<User> supervisorUserList = new List<User>();
		Set<Id> brIdSet = new Set<Id>();
		Set<Id> businessBrOwnerIdSet = new Set<Id>();
		List<Business_Relationships__c> businessRelationList = new List<Business_Relationships__c>();
		List<Business_Relationships__c> businessRelationRelatedToList = new List<Business_Relationships__c>();
		List<Business_Relationships__c> businessRelationRelatedFromList = new List<Business_Relationships__c>();
		Map<String, Object> returnMap = new Map<String, Object>();
		Map<String, Object> supervisorDetialsMap = new Map<String, Object>();
		try {
			if (par != null) {
				List<String> brRelatedToList = new List<String>();
				String acrFields = 'Id , Related_To__c , Related_From__r.Name,Related_From__r.Buisness_Email__c, Related_From__c,Related_to__r.IsPersonAccount, Related_To__r.PersonEmail , Related_To__r.Name, Roles__c';
				String whereCaluse =
					'(Related_From__c = \'' +
					String.escapeSingleQuotes(par.BusinessAccountNameId) +
					'\'' +
					' OR Related_To__c = \'' +
					String.escapeSingleQuotes(par.BusinessAccountNameId) +
					'\'' +
					') AND Roles__c IN ' +
					LPI_ServiceUtility.getStringValuesByStringSet(OWNER_PERSON_INCHARGE_SET);
				LPI_BusinessRelationshipDAO.LPI_BusinessRelationshipsWithoutSharingDAO withoutSharingQuery = new LPI_BusinessRelationshipDAO.LPI_BusinessRelationshipsWithoutSharingDAO();
				for (
					Business_Relationships__c rec : withoutSharingQuery.getBusinessRelationshipsByDymanicQuery(
						acrFields,
						whereCaluse,
						null,
						null,
						null
					)
				) {
					 
					if (
						rec.Related_From__c == par.BusinessAccountNameId &&
						rec.Related_To__c != par.Contact__r.AccountId
					) {
						businessRelationRelatedToList.add(rec);
						brIdSet.add(rec.Id);
					}
					 
					else {
						if (rec.Related_To__c == par.BusinessAccountNameId) {
							businessBrOwnerIdSet.add(rec.Related_From__c);
							brIdSet.add(rec.Id);
						}
					}
					businessRelationList.add(rec);
				}
				if (!businessBrOwnerIdSet.isEmpty()) {
					 
					for (
						Business_Relationships__c relation : withoutSharingQuery.getBusinessRelationshipsByDymanicQuery(
							'Id, IsActive__c, Related_To__c, Related_From__c, Related_to__r.IsPersonAccount, Related_to__r.Name, Related_From__r.PersonEmail, Related_To__r.Buisness_Email__c, Related_From__r.Name',
							'Related_From__c IN ' +
								LPI_ServiceUtility.getStringValuesBySet(businessBrOwnerIdSet) +
								' AND (Roles__c =\'' +
								ROLE_AUTHORIZED_CONTACT +
								'\'' +
								' OR Roles__c =\'' +
								PERSON_INCHARGE +
								'\')' +
								' AND Related_To__c !=\'' +
								par.Contact__r.AccountId +
								'\'',
							null,
							null,
							null
						)
					) {
						businessRelationRelatedFromList.add(relation);
						brRelatedToList.add(relation.Related_To__c);
					}
				}
				if (!brRelatedToList.isEmpty()) {
					String userFields = 'Id,ContactId,Account.Name,Account.Phone,Account.PersonEmail,AccountId ';
					String userwhereCaluse =
						' AccountId IN ' + LPI_ServiceUtility.getStringValuesByList(brRelatedToList);
					LPI_UserDao.LPI_UserWithoutSharingDAO userWithoutsharing = new LPI_UserDao.LPI_UserWithoutSharingDAO();
					supervisorUserList = userWithoutsharing.getUserByDymanicQuery(
						userFields,
						userwhereCaluse,
						null,
						null,
						null
					);
				}
			}
		} catch (Exception e) {
			LPI_ExceptionManager.logException(CLASS_NAME, FETCH_ADMINISTRATOR_USER_DETAILS, e);
		}
		returnMap.put('supervisorUserList', supervisorUserList);
		returnMap.put('brIdSet', brIdSet);
		returnMap.put('businessRelationList', businessRelationList);
		returnMap.put('businessRelationRelatedToList', businessRelationRelatedToList);
		returnMap.put('businessRelationRelatedFromList', businessRelationRelatedFromList);
		return returnMap;
	}
	/**
	 * @author                      : MTX Group Product Team
	 * @since                       : June 23, 2023
	 * @description                 : This method is used to update Administrator/Owner Approved or Rejected details and deleting Portal notification
	 * @story Number				: S-48232
	 * @return                      : `void`
	 * @last modified by            : MTX Group Product Team
	 * @last modified date          : (Add if modified by you)
	 * @modified details            : (Add if modified by you)
	 */
	public static Boolean updateAdminOwnerApprovalStatus(Map<String, Object> inputMap, Map<String, Object> outMap) {
		try {
			List<User> userList = LPI_UserDao.getCurrentUserRecord();
			Id parId;
			List<AccountContactRelation> acrList = new List<AccountContactRelation>();
			String supervisorAcrId;
			String rejectionReason = '';
			if (inputMap.containsKey('parId') && inputMap.containsKey('supervisorAcrId') && !userList.isEmpty()) {
				parId = (Id) inputMap.get('parId');
				List<PreliminaryApplicationRef> parList;
				 
				if (parId != null) {
					LPI_PreliminaryApplicationRefDAO.LPI_PreliminaryApplicationRefWithoutSharingDAO parWithoutSharing = new LPI_PreliminaryApplicationRefDAO.LPI_PreliminaryApplicationRefWithoutSharingDAO();
					String fields =
						' Id, BusinessAccountNameId ,Contact__r.AccountId,Contact__r.Account.PersonEmail, Board_Name__c,Approval_Supervisors_AcrIds__c , Contact__c  ,Regulatory_Authorization_Type__r.Email_Specifications_Final__c,' +
						'Regulatory_Authorization_Type__c, Regulatory_Authorization_Type__r.Name  , BusinessAccountName.Name, BusinessAccountName.PersonEmail, Regulatory_Authorization_Type__r.IssuingDepartment.Name, Steps_Name__c';  
					String whereClause = 'Id = \'' + String.escapeSingleQuotes(parId) + '\'';
					parList = parWithoutSharing.getPreliminaryApplicationRefByDymanicQuery(
						fields,
						whereClause,
						null,
						null,
						null
					);
				}
				supervisorAcrId = (String) inputMap.get('supervisorAcrId');
				 
				if (!parList.isEmpty() && String.isNotBlank(supervisorAcrId)) {
					Business_Relationships__c newBusinessRelationRecord = new Business_Relationships__c(
						Id = supervisorAcrId
					);
					PreliminaryApplicationRef updatePar = new PreliminaryApplicationRef(Id = parId);
					String acrStatus = (String) inputMap.get('status');
					if (inputMap.containsKey('status')) {
						newBusinessRelationRecord.Supervisor_Approval_Status__c = acrStatus;
					}
					if (inputMap.containsKey(REJECTED_REASON)) {
						rejectionReason = (String) inputMap.get(REJECTED_REASON);
						newBusinessRelationRecord.Rejection_reason__c = rejectionReason;
					}
					 
					Map<String, Object> newSerializeMap = new Map<String, Object>();
					List<String> supervisorAcrIdsList = LPI_SupervisorSharingUtility.fetchSupervisorAcrIds(parId);
					if (acrStatus == REJECTED_STATUS) {
					 
						Map<Id, Business_Relationships__c> relationMap;
						Map<String, Object> supervisorResponseMap = new Map<String, Object>();
						 
						if (supervisorAcrId != null) {
							String acrFields = 'Id , Roles__c, Related_From__c , Related_To__r.Name , License_Number__c ';
							String whereCaluse = 'Id = \'' + String.escapeSingleQuotes(supervisorAcrId) + '\'';
							LPI_BusinessRelationshipDAO.LPI_BusinessRelationshipsWithoutSharingDAO withoutSharingQuery = new LPI_BusinessRelationshipDAO.LPI_BusinessRelationshipsWithoutSharingDAO();
							relationMap = new Map<Id, Business_Relationships__c>(
								withoutSharingQuery.getBusinessRelationshipsByDymanicQuery(
									acrFields,
									whereCaluse,
									null,
									null,
									null
								)
							);
						}
						Map<String, Object> stepDataJson = inputMap.containsKey('stepJson') ? (Map<String, Object>) inputMap.get('stepJson') : null;
						if (relationMap.containsKey(supervisorAcrId)) {
							stepDataJson.put('SupervisorLNo.', relationMap.get(supervisorAcrId).License_Number__c);
							stepDataJson.put('SupervisorName', relationMap.get(supervisorAcrId).Related_To__r.Name);
							stepDataJson.put('acrRole', relationMap.get(supervisorAcrId).Roles__c);
							stepDataJson.put('ApprovalStatus', REJECTED_STATUS);
							stepDataJson.put('Date', Date.today());
						}
						supervisorResponseMap.put(supervisorAcrId, stepDataJson);

						 
					}
					 
					LPI_WithoutSharingUtility.updateSObjectRecord(newBusinessRelationRecord);
					if (updatePar != null) {
						 
						String acrRole = (String) inputMap.get('relationshipRole') != null
							? (String) inputMap.get('relationshipRole')
							: null;
						 
						if((!BARBER_EST_SET.contains(parList[0].Regulatory_Authorization_Type__r.Name) && !TATTOOING_EST_SET.contains(parList[0].Regulatory_Authorization_Type__r.Name) && acrStatus == APPROVED_STATUS) || acrStatus == REJECTED_STATUS){
							sendEmailNotification(parId, acrStatus, rejectionReason, userList, parList, acrRole);
						}
						updatePar.Is_Supervisor_User__c = false;
						 
						if(String.isNotBlank(parList[0].Steps_Name__c) && !parList[0].Steps_Name__c.contains(APPROVAL_INFO))
						{
							updatePar.Steps_Name__c = parList[0].Steps_Name__c + ';' + APPROVAL_INFO;
						}
						LPI_DML.doUpdate(updatePar);
						String poratalNtfFields = 'Id , Record_Id__c ';
						String poratalNtfWhere =
							' Record_Id__c= \'' +
							String.escapeSingleQuotes(supervisorAcrId + '-' + parId) +
							'\'';
						outMap.put('isUpdateSuccess', true);
						if (LPI_SupervisorSharingUtility.checkForSupervisorResponse(parId) != PENDING_STATUS) {
							LPI_SupervisorSharingUtility.deleteSaveAndExitInstance(parId);
						}
						return true;
					}
				}
			}
		} catch (Exception e) {
			LPI_ExceptionManager.logException(CLASS_NAME, UPDATE_SUPERVISOR_APPROVAL_STATUS, e);
		}
		outMap.put('isUpdateSuccess', false);
		return false;
	}
	
	/**
	 * @author                      : MTX Group Product Team
	 * @since                       : June 23, 2023
	 * @description                 : This method is to send Approved or Rejected Email notifications
	 * @story Number				: S-48340
	 * @return                      : `void`
	 * @last modified by            : MTX Group Product Team
	 * @last modified date          : (Add if modified by you)
	 * @modified details            : (Add if modified by you)
	 */

	private static void sendEmailNotification(
		String parId,
		String status,
		String rejectionReason,
		List<User> userList,
		List<PreliminaryApplicationRef> parList,
		String acrRole
	) {
		try {
			Map<String, String> replaceTextMap = new Map<String, String>();
			List<LPI_Wrapper.NotificationEmailWrapper> notificationEmailWrapperList = new List<LPI_Wrapper.NotificationEmailWrapper>();
			if (!parList.isEmpty() && !userList.isEmpty()) {
				Map<String, Object> boardSignatureMap = (Map<String, Object>) JSON.deserializeUntyped(
					String.valueOf(
						parList[0].Regulatory_Authorization_Type__r.Email_Specifications_Final__c
					)
				);
				replaceTextMap.put('Admin_Owner_Name', userList[0].Account.Name);
				if (status == REJECTED_STATUS) {
					replaceTextMap.put('Rejection_Reason', rejectionReason);
				}
				replaceTextMap.put('Establishment', parList[0].BusinessAccountName.Name); 
				replaceTextMap.put('Portal_Link', System.Label.Site_Url);
				replaceTextMap.put('License_Type', String.valueOf(parList[0].Regulatory_Authorization_Type__r.Name));
				replaceTextMap.put(
					'Board_Name',
					String.isNotBlank((String) boardSignatureMap.get('boardName'))
						? (String) boardSignatureMap.get('boardName')
						: ''
				);
				replaceTextMap.put(
					'Board_Email',
					String.isNotBlank((String) boardSignatureMap.get('boardEmail'))
						? (String) boardSignatureMap.get('boardEmail')
						: ''
				);
				replaceTextMap.put(
					'Board_PO_box',
					String.isNotBlank((String) boardSignatureMap.get('boardPoBox'))
						? (String) boardSignatureMap.get('boardPoBox')
						: ''
				);
				Set<String> notifyApiNameSet = new Set<String>();
				if (status == APPROVED_STATUS) {
					notifyApiNameSet.add(APPROVED_METADATA_API_NAME);
				} else {
					 
					if(TATTOOING_EST_SET.contains(parList[0].Regulatory_Authorization_Type__r.Name) || BARBER_EST_SET.contains(parList[0].Regulatory_Authorization_Type__r.Name)){
						notifyApiNameSet.add(NOTIFICATION_FOR_REQUEST_REJECTED);
					} else{
						notifyApiNameSet.add(
							acrRole == PERSON_INCHARGE ? REJECTION_METADATA_API_NAME : OWNER_REJECTION_METADATA_API_NAME
						);
					}	
				}
				List<Notification_Message__mdt> adminNotiRec = LPI_CustomMetadataTypeDAO.getAllNotificationByDeveloperNames(
					notifyApiNameSet
				);
				if (parList[0].Contact__c != null) {
					 
					LPI_Wrapper.NotificationEmailWrapper notifcationWrapper = new LPI_Wrapper.NotificationEmailWrapper();
					notifcationWrapper.accountId = parList[0].Contact__r.AccountId;
					notifcationWrapper.recipientEmail = parList[0].Contact__r.Account.PersonEmail;
					notifcationWrapper.templateName = adminNotiRec[0].Template_Name__c;
					notifcationWrapper.replaceTextMap = replaceTextMap;
					notificationEmailWrapperList.add(notifcationWrapper);
					if (!notificationEmailWrapperList.isEmpty()) {
						LPI_ServiceUtility.createNotificationRecords(notificationEmailWrapperList);
					}
				}
			}
		} catch (DmlException e) {
			LPI_ExceptionManager.logException(CLASS_NAME, SEND_EMAIL_NOTIFICATION, e);
		}
	}

}