/**
 * @description       : This MODPR_InternalRegistration class is used by ModprInternalRegistration lwc for the internal intake flow functionality
 * @author            : Mohit Karani
 * @group             :
 * @last modified on  : 06-18-2024
 * @last modified by  : Ayush Dev
 **/

public with sharing class LPI_InternalRegistration {
	static final Map<String, String> ACCOUNT_REC_TYPE_TO_ACCOUNT_TYPE_MAP = new Map<String, String>{
		LPI_LiteralConstant.ACCOUNT_PERSON_RECORDTYPE => LPI_LiteralConstant.INDIVIDAULICENSE_APPTYPE,
		LPI_LiteralConstant.BUSINESSLICENSE_APPTYPE => LPI_LiteralConstant.BUSINESSLICENSE_APPTYPE
	};
    //Set of RATs for which multiple applications allowed irrespective of applications or license status.
    private final static Set<String> setActionAllowedValidationExceptionRatSet = new Set<String>{
        'Temporary Real Estate Appraiser'
    };
	/**
	 * @author                   Chanda Rithvik
	 * @description              This Method will invoke from the ModprInternalRegistration lwc
	 * @param  input             It takes the input account Id
	 * @return                   It returns the list of regulatory authorization types(License)
	 */

	@AuraEnabled(cacheable=true)
	public static List<RegAuthTypeWrapper> getLicensesAtInitialLoad(String accountId) {
		try {
			return getRegAuthTypes(accountId, null, null);
		} catch (Exception e) {
			LPI_ExceptionManager.logException('LPI_InternalRegistration', 'getLicensesAtInitialLoad', e);
			throw new AuraHandledException(e.getMessage());
		}
	}

	/**
	 * @author                   Chanda Rithvik
	 * @description              This Method will invoke from the ModprInternalRegistration lwc
	 * @param  input             It takes the input of regulatory authorization type(License) of string and account Id
	 * @return                   It returns the list of regulatory authorization types(License) matching with the input string
	 * @last modified By         Milanjeet Singh
	 * @last modified details    Updated logic to fetch Application Flow Configs for Licenses
	 * @last modified date       Dec 27, 2022
	 */
	@AuraEnabled
	public static List<RegAuthTypeWrapper> getRegulatoryAuthorizationTypesByLicenses(
		String regAuthType,
		String accountId
	) {
		try {
			regAuthType = String.isNotBlank(regAuthType) ? String.escapeSingleQuotes(regAuthType) + '%' : null;
			return getRegAuthTypes(accountId, regAuthType, 'Name');
		} catch (Exception e) {
			LPI_ExceptionManager.logException(
				'LPI_InternalRegistration',
				'getRegulatoryAuthorizationTypesByLicenses',
				e
			);
			throw new AuraHandledException(e.getMessage());
		}
	}
	/**
	 * @author                   Chanda Rithvik
	 * @description              This Method will invoke from the ModprInternalRegistration lwc
	 * @param  input             It takes the input of Regulatory Authority(Board) of string and account Id
	 * @return                   It returns the list of Regulatory Authority(Board) matching with the input string
	 * @last modified By         Milanjeet Singh
	 * @last modified details    Updated logic to fetch Application Flow Configs for Licenses
	 * @last modified date       Dec 27, 2022
	 */
	@AuraEnabled
	public static List<RegAuthTypeWrapper> getRegulatoryAuthorizationTypesByBoard(String regAuth, String accountId) {
		try {
			regAuth = String.isNotBlank(regAuth) ? String.escapeSingleQuotes(regAuth) + '%' : null;

			return getRegAuthTypes(accountId, regAuth, 'IssuingDepartment.Name');
		} catch (Exception e) {
			LPI_ExceptionManager.logException(
				'LPI_InternalRegistration',
				'getRegulatoryAuthorizationTypesByBoard',
				e
			);
			throw new AuraHandledException(e.getMessage());
		}
	}

	/**
	 * @author                   Chanda Rithvik
	 * @description              This Method will invoke from the ModprInternalRegistration lwc
	 * @param  input             It doesn't takes any input
	 * @return                   It returns the boolean value that current user is portal user or not
	 */

	@AuraEnabled
	public static Boolean getIsPortalUser() {
		try {
			String fields = 'IsPortalEnabled';
			String whereClause = 'Id = \'' + UserInfo.getUserId() + '\'';
			List<User> userList = LPI_UserDao.getUserByDymanicQueryWithoutSecurityEnforced(
				fields,
				whereClause,
				null,
				null,
				null
			);
			if (userList.isEmpty()) {
				return null;
			}
			return userList[0].IsPortalEnabled;
		} catch (Exception e) {
			LPI_ExceptionManager.logException('LPI_InternalRegistration', 'getIsPortalUser', e);
			throw new AuraHandledException(e.getMessage());
		}
	}

	  /**
     * @author                   Chanda Rithvik
     * @description              This Method will invoke from the ModprInternalRegistration lwc
     * @param  input             It takes account and license ids as string
     * @return                   It creates Preliminary Application Reference and returns the Id of Preliminary Application Reference
     */

	 @AuraEnabled
	 public static String createPAR(String paramsMap) {
		 try {
			Map<String, Object> inputMap = (Map<String, Object>) JSON.deserializeUntyped(paramsMap);
			if ((inputMap.containsKey('accountId') && ((String) inputMap.get('accountId') == null)) || 
				(inputMap.containsKey('licenseId') && ((String) inputMap.get('licenseId') == null))) {
				return null;
			}
			Map<String, Object> resultMap = LPI_ApplicationFlowUtility.createPARRecord(
				new Map<String, Object>{
					'accountId' => (String) inputMap.get('accountId'),
					'regAuthId' => (String) inputMap.get('licenseId'),
					'amendmentType' => (String) inputMap.get('subtype'),
					'type' => (String) inputMap.get('type'),
					'changeStatusAmendmentSubType' => (String) inputMap.get('changeStatusAmendmentSubType'),
					'additionalLicenseType' => (String) inputMap.get('additionalLicenseType'),
					'blId' => (String) inputMap.get('blId'),
					'identificationCardId' => (String) inputMap.get('icId'),
					'applicationId' => (String) inputMap.get('applicationId')
				},
				null
			);
			if (resultMap != null) {
				return resultMap.containsKey('parRec')
					? ((PreliminaryApplicationRef) resultMap.get('parRec')).Id
					: null;
			} else {
				return null;
			}
		 } catch (Exception e) {
			LPI_ExceptionManager.logException('LPI_InternalRegistration', 'createPAR', e);
			 throw new AuraHandledException(e.getMessage());
		 }
	 }
 
	/**
	 * @author            : Nitesh Garg
	 * @description       : This Method is used to check user can apply for license or not for new application from internal
	 * @Perameters        : String regAuthId,String accountId
	 **/
	@AuraEnabled
	public static String checkApplyLicense(String regAuthId, String accountId, String type, String subtype, String blId,String icId) {
		try {
			Map<String, Object> inputMap = new Map<String, Object>();
			inputMap.put('regAuthId', regAuthId);
			inputMap.put('accountId', accountId);
			inputMap.put('type', type);
			inputMap.put('amendmentType', subtype);
			inputMap.put('blId', blId);
            inputMap.put('identificationCardId', icId);
            List<RegulatoryAuthorizationType> ratList;
            if(String.isNotBlank(regAuthId)){
                ratList = LPI_RegulatoryAuthorizationTypeDAO.getRegulatoryAuthorizationTypeByDymanicQuery(
                    'Name', 
                    'Id = \'' + regAuthId + '\'', 
                    null, 
                    null, 
                    null
                );
            }
            //By passing validation for applying new applications for applicable license types
            Boolean result = !ratList.isEmpty() && setActionAllowedValidationExceptionRatSet.contains(ratList[0].Name) ? true : LPI_ApplicationFlowUtility.setActionAllowedValidation(inputMap);
			if (result) {
				return 'false';
			}
			return 'true';
		} catch (Exception e) {
			LPI_ExceptionManager.logException('LPI_InternalRegistration', 'checkApplyLicense', e);
			throw new AuraHandledException(e.getMessage());
		}
	}

	/**
	 * @description : Get RegulatoryAuthorizationType records by different conditions.
	 * @author Mohit Karani | 01-30-2023
	 * @param accountId
	 * @param searchKey
	 * @param searchByParam
	 * @return List<RegAuthTypeWrapper>
	 **/
	public static List<RegAuthTypeWrapper> getRegAuthTypes(String accountId, String searchKey, String searchByParam) {
		try {
			if (String.isBlank(accountId)) {
				return null;
			}
			String accountType;
			String fields;
			String whereClause;

			Account acc = getAccountById(accountId);
			// return if no account exist
			if (acc == null) {
				return null;
			}
			List<RegAuthTypeWrapper> authTypeWrapperList = new List<RegAuthTypeWrapper>();
			accountType = ACCOUNT_REC_TYPE_TO_ACCOUNT_TYPE_MAP.get(acc.RecordType.DeveloperName);
			// return if no accountType
			if (String.isBlank(accountType)) {
				return null;
			}
			fields = 'Id,Name,Authorisation_Type__c,IssuingDepartment.Name,New_Application_Allowed__c,Description,Tag__c,';
			fields += '(SELECT Id, Application_Flow__r.Type, Application_Flow__r.SubType, Application_Flow__r.Language';
			fields += ' FROM Application_Flow_Configurations__r WHERE Application_Type__c = \'New\')';
			whereClause = ' Authorisation_Type__c = \'' + accountType + '\' AND New_Application_Allowed__c = TRUE  AND Hide_from_CRR__c = false';
			// if searchKey present then add search key in the query.

			if (String.isNotBlank(searchKey) && String.isNotBlank(searchByParam)) {
                if(searchByParam == 'Name'){
                    whereClause += ' AND (' + searchByParam + ' LIKE \'' + searchKey + '\' OR Tag__c LIKE \'' + searchKey + '\')';
                }else{
                    whereClause += ' AND ' + searchByParam + ' LIKE \'' + searchKey + '\'';
                }
			}

			for (
				RegulatoryAuthorizationType authType : LPI_RegulatoryAuthorizationTypeDAO.getRegulatoryAuthorizationTypeByDymanicQuery(
					fields,
					whereClause,
					null,
					'Name',
					'ASC'
				)
			) {
                RegAuthTypeWrapper regAuthWrapper = new RegAuthTypeWrapper(authType);
                if(String.isNotBlank(authType.Tag__c)){
                    regAuthWrapper.searchName = authType.Tag__c;
                }
				authTypeWrapperList.add(regAuthWrapper);
			}

			return authTypeWrapperList;
		} catch (Exception e) {
			LPI_ExceptionManager.logException('LPI_InternalRegistration', 'getRegAuthTypes', e);
			throw new AuraHandledException(e.getMessage());
		}
	}

	/**
	 * @description : Get account by id.
	 * @author Mohit Karani | 01-30-2023
	 * @param accountId
	 * @return Account
	 **/
	public static Account getAccountById(Id accountId) {
		try {
			String fields;
			String whereClause;
			fields = 'Id,Name, PersonContactId, RecordType.DeveloperName, PersonOtherStreet, PersonOtherState, PersonOtherPostalCode, PersonOtherCity';
			whereClause = 'Id = \'' + String.escapeSingleQuotes(accountId) + '\'';
			List<Account> accList = LPI_AccountDAO.getAccountListByDynamicQuery(
				fields.split(','),
				whereClause,
				null,
				null,
				null
			);
			// return null if no account found.
			if (accList.isEmpty()) {
				return null;
			}
			return accList[0];
		} catch (Exception e) {
			LPI_ExceptionManager.logException('LPI_InternalRegistration', 'getAccountById', e);
			throw new AuraHandledException(e.getMessage());
		}
	}


	public class RegAuthTypeWrapper {
		@AuraEnabled
		public String Id;
		@AuraEnabled
		public String Name;
		@AuraEnabled
		public String authType;
		@AuraEnabled
		public String issuingDepartmentName;
		@AuraEnabled
		public String appFlowType;
		@AuraEnabled
		public String appFlowSubtype;
		@AuraEnabled
		public String appFlowLanguage;
		@AuraEnabled
		public String description;		
        @AuraEnabled
		public String searchName;

		public RegAuthTypeWrapper(RegulatoryAuthorizationType authType) {
			this.Id = authType.Id;
			this.Name = authType.Name;
			this.authType = authType.Authorisation_Type__c;
			this.issuingDepartmentName = authType.IssuingDepartment.Name;
			this.description = authType.Description;
			if (!authType.Application_Flow_Configurations__r.isEmpty()) {
				this.appFlowType = authType.Application_Flow_Configurations__r[0].Application_Flow__r.Type;
				this.appFlowSubtype = authType.Application_Flow_Configurations__r[0].Application_Flow__r.SubType;
				this.appFlowLanguage = authType.Application_Flow_Configurations__r[0].Application_Flow__r.Language;
			}
            this.searchName = authType.Name;
		}
	}
}