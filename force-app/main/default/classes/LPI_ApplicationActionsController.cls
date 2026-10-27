/**
 * @author              : MTX Group Product Team
 * @since               : 22nd March, 2023
 * @description         : This Class Contains the Business Logic for Application License Actions
 
 */
public with sharing class LPI_ApplicationActionsController {
	public final static String APPLICATION_DETAIL_PAGE = 'Application Detail Page';
	private final static String RESUME_APPLICATION_LABEL = 'Resume Application';
	private final static String RESUME_APPLICATION_TYPE = 'ResumeApplication';
	private final static String MAKE_PAYMENT_LABEL = 'Complete Pending Payment';
	private final static String MAKE_PAYMENT_VALUE = 'MakePayment';
    private final static String MAKE_OVER_PAYMENT_LABEL = 'Overpayment';
    private final static String MAKE_OVER_PAYMENT_VALUE = 'Overpayment';
	private final static String CHENNEL_OFFLINE = 'Offline';
	
	private final static String SUBMIT_REGISTRATION_FORM = 'Submit Registration Form(s)';
	private final static String BAD_CHECK = 'Bad Check';
	private final static String REGISTRATION_FORM_NAVIGATION = 'submit-registration-form';
	private final static String STATUS_APPROVED = 'Approved';
	private static final String APEP_BOARD_BUSINESS_REINSTATEMENT = 'Re-authorization';
	private static final String APEP_BOARD_INDIVIDUAL_REINSTATEMENT = 'Re-licensure';
	private static final String REINSTATEMENT_APPLICATIONTYPE = 'Reinstatement';
	private final static String BUSINESS_LICENSE_APPLICATION_OBJECT = 'BusinessLicenseApplication';
	private final static String PORTAL_USER = 'Portal User';
    
    private final static String HEALING_ARTS_BOARD = 'Healing Arts';
    private final static String PROF_CORP_NAME_APPROVAL_AMENDMENT = 'Apply for Professional Corporation Name Approval';
    

	/**
	 * @author                      : MTX Group Product Team
	 * @since                       : 22nd March, 2023
	 * @description                 : This method is used to get the application(IA/BLA) and application actions data. This method is
	 *                                common for IA/BLA and logic is generic and can handle application actions for Internal/Portal
	 * @param  recordId             : Takes Id of PAR/IA/BLA
	 * @return                      : `DataWrapper`
	 * @last modified by            : MTX Group Product Team
	 * @last modified date          : (Add if modified by you)
	 * @last modified details       : (Add if modified by you)
	 */
	@AuraEnabled
	public static DataWrapper getApplicationData(Id recordId) {
		DataWrapper response;
		try {
			if (String.isNotBlank(recordId)) {
				String objectType = String.valueOf(recordId.getSObjectType());
				List<User> currentUser = LPI_UserDao.getCurrentUserRecord();
				List<SObject> lstApplication;
				Boolean isCRRHold = false;
				String fieldsToQuery =
					'Id, Name, AccountId, Status, Status__c, ApplicationType, Amendment_Type__c, Applicant_submission_Date__c,AppliedDate,' +
					'LicensePermitNameId, LicenseTypeId, LicenseType.Name, LicenseType.IssuingDepartment.Name, Is_Submitted_By_Internal_User__c,SavedApplicationRefId,' +
					'SavedApplicationRef.License_Questions__c,Payment_Pending__c, LicensePermitName.Bad_Check_Flag__c,' +
					'(SELECT Id FROM RegulatoryTrxnFees WHERE TotalFeeAmount >= 0 ORDER BY CreatedDate DESC LIMIT 1)';
				String condition = '';
				PreliminaryApplicationRef parRecord;
				if (objectType.equalsIgnoreCase(LPI_LiteralConstant.PAR_SOBJECT_API)) {
					String parFields = 'Id, ApplicationType';
					String parCondition = 'Id = ' + '\'' + String.escapeSingleQuotes(recordId) + '\'';
					List<PreliminaryApplicationRef> lastParRecord = LPI_PreliminaryApplicationRefDAO.getPreliminaryApplicationRefByDymanicQuery(
						parFields,
						parCondition,
						null,
						null,
						null
					);
					parRecord = lastParRecord[0];
					objectType = lastParRecord[0].ApplicationType;
					condition = 'SavedApplicationRefId = ' + '\'' + String.escapeSingleQuotes(recordId) + '\'';
				} else {
					condition = 'Id = ' + '\'' + String.escapeSingleQuotes(recordId) + '\'';
				}
				switch on objectType {
					when 'IndividualApplication' {
						fieldsToQuery += ', Practical_Exam_Eligibility__c , License_Type_Name__c';
						lstApplication = LPI_IndividualApplicationDAO.getIndividualApplicationByDymanicQuery(
							fieldsToQuery,
							condition,
							null,
							null,
							null
						);
						isCRRHold = ((IndividualApplication) lstApplication[0]).LicensePermitName.Bad_Check_Flag__c;
					}
					when 'BusinessLicenseApplication' {
						lstApplication = LPI_BusinessLicenseApplicationDAO.getBusinessLicenseApplicationByDymanicQuery(
							fieldsToQuery,
							condition,
							null,
							null,
							null
						);
						isCRRHold = ((BusinessLicenseApplication) lstApplication[0])
							.LicensePermitName.Bad_Check_Flag__c;
					}
				}
				if (!lstApplication.isEmpty()) {
					SObject applicationRecord = lstApplication[0];
					RegulatoryAuthorizationType ratConfig = (RegulatoryAuthorizationType) applicationRecord.getSObject(
						'LicenseType'
					);
					List<ButtonWrapper> buttonList = new List<ButtonWrapper>();
					
					if(!currentUser.isEmpty() && currentUser[0].Profile.Name == PORTAL_USER){
						buttonList = getButtonList(applicationRecord);
					}
					 
					if ((String) applicationRecord.get('Status') != LPI_LiteralConstant.BLA_DRAFT_STATUS) {
						buttonList.add(new ButtonWrapper('Download Application', 'downloadApplication', null));
					}

				 
					if (applicationRecord.getSObjects('RegulatoryTrxnFees') != null) {
						buttonList.add(new ButtonWrapper('Download Payment Receipt', 'downloadPayReceipt', null));
					}

					 
					if (
						(String) applicationRecord.get('Status') != LPI_LiteralConstant.BLA_DRAFT_STATUS &&
						!currentUser.isEmpty() &&
						currentUser[0].Profile.Name != 'Portal User'
					) {
						buttonList.add(
							new ButtonWrapper(
								'Download Application/Licensee Review Information',
								'downloadApplicationReviewInfo',
								null
							)
						);
					}
                    
					 
					buttonList.addAll(getPDFActionButton(applicationRecord, objectType));

					 
					buttonList.add(getResumeApplicationButton(applicationRecord));
                    
					
					if (((Boolean) applicationRecord.get('Payment_Pending__c')) && currentUser[0].Profile.Name != PORTAL_USER) {
						buttonList.add(getMakePaymentButton(applicationRecord, objectType));
					}

					 
					Set<String> viewVisitsRCVboardSet = new Set<String>(
						System.Label.Visit_RCV_Applicable_Board.split('@')
					);
					 
					Set<String> cosbarEligibleExamBoardSet = new Set<String>(
						System.Label.CosbarExamEligibleBoards.split('@')
					);
					

					if (
						!viewVisitsRCVboardSet.isEmpty() &&
						viewVisitsRCVboardSet.contains(ratConfig.IssuingDepartment.Name) &&
						objectType == 'BusinessLicenseApplication' &&
						LPI_WithoutSharingUtility.isPortalUser()
					) {
						buttonList.add(
							new ButtonWrapper(
								'View Inspections & Regulatory Code Violations',
								'View Inspections & Regulatory Code Violations',
								null
							)
						);
					}
					String licenseName = '';
					if (objectType == 'IndividualApplication') {
						licenseName = applicationRecord.get('License_Type_Name__c') == 'Embalmer Apprentice'
							? 'Embalmer'
							: 'Funeral Director';
					}

					

					response = new DataWrapper(applicationRecord, ratConfig, buttonList);
					response.applicationData.isCRRHold = isCRRHold;
					if (cosbarEligibleExamBoardSet.contains(ratConfig.name) && objectType == 'IndividualApplication') {
						response.applicationData.isExamEligible = true;
						 
						response.applicationData.practicalEligibleToTest = (String) applicationRecord.get(
							'Practical_Exam_Eligibility__c'
						);
					}
					 
					
				}
			}
		} catch (Exception e) {
			LPI_ExceptionManager.logException(recordId, getClassName(), 'getApplicationData', e);
			throw new LPI_Exception(e.getMessage());
		}
		return response;
	}

	/**
	 * @author                      : MTX Group Product Team
	 * @since                       : 22nd March, 2023
	 * @description                 : This method is a helper method that validate if the action is valid for current IA/BLA and
	 *                                returns the allowed action list
	 * @param application           : Takes IA/BLA as sObject (Dynamic)
	 * @param ratConfig             : Takes RAT Record of current IA/BLA record
	 * @return                      : `List<ButtonWrapper>` Return List of Elligible Action Buttons on the current IA/BLA
	 * @last modified by            : MTX Group Product Team
	 * @last modified date          : (Add if modified by you)
	 * @last modified details       : (Add if modified by you)
	 */
	private static List<ButtonWrapper> getButtonList(sObject application) {
		List<ButtonWrapper> buttonList = new List<ButtonWrapper>();
		List<User> u = LPI_UserDao.getCurrentUserRecord();
		Set<String> actionNameSet = new Set<String>{ 'PLS State Exam', 'PLS State Re-Exam' };
		Id regAuthId = (Id) application.get('LicenseTypeId');
		String appStatus = (String) application.get('Status');
		String applicationType = (String) application.get('ApplicationType');
		String applicationSubType = (String) application.get('Amendment_Type__c');
		String fieldsToQuery = 'Id, Action_Name__c, Application_Type__c, Application_Subtype__c,  Eligible_Application_Status__c, Eligible_Application_Type__c';
		String conditions =
			'Regulatory_Authorization_Type__c = \'' +
			String.escapeSingleQuotes(regAuthId) +
			'\' AND Action_Name__c != null';

		String conditionResult = getConditions(appStatus, applicationType, applicationSubType);
		if (String.isBlank(conditionResult)) {
			return buttonList;
		}
		conditions += conditionResult;

		List<Application_Flow_Config__c> lstAppFlowConfig = LPI_ApplicationFlowConfigDAO.getApplicationFlowConfigByDymanicQuery(
			fieldsToQuery,
			conditions,
			null,
			null,
			null
		);

		if (!lstAppFlowConfig.isEmpty()) {
			for (Application_Flow_Config__c appFlowConfig : lstAppFlowConfig) {
				ActionData actionData = new ActionData(
					appFlowConfig.Application_Type__c,
					appFlowConfig.Application_Subtype__c
				);
				if (
					actionNameSet.contains(appFlowConfig.Action_Name__c) &&
					(applicationType != 'New' ||
					(applicationType == 'New' &&
					!u.isEmpty() &&
					u[0].Profile.Name != 'Support Staff'))
				) {
					continue;
				}
				buttonList.add(
					new ButtonWrapper(
						appFlowConfig.Action_Name__c,
						appFlowConfig.Action_Name__c,
						JSON.serialize(actionData)
					)
				);
			}
		}
		return buttonList;
	}

	private static String getConditions(String status, String applicationType, String applicationSubType) {
		String appTypeINCLUDES;
		String statusINCLUDES;
		String appSubTypeINCLUDES;
		String conditions = '';

		if (String.isNotBlank(status)) {
			statusINCLUDES = 'INCLUDES(' + '\'' + String.escapeSingleQuotes(status) + '\')';
			conditions +=
				' AND (Eligible_Application_Status__c = null OR Eligible_Application_Status__c ' +
				statusINCLUDES +
				')';
		}
		if (String.isNotBlank(applicationType)) {
			appTypeINCLUDES = 'INCLUDES(' + '\'' + String.escapeSingleQuotes(applicationType) + '\')';
			conditions +=
				' AND (Eligible_Application_Type__c = null OR Eligible_Application_Type__c ' +
				appTypeINCLUDES +
				')';
		}
		if (String.isNotBlank(applicationSubType)) {
			appSubTypeINCLUDES = 'INCLUDES(' + '\'' + String.escapeSingleQuotes(applicationSubType) + '\')';
			conditions +=
				' AND (Eligible_Application_Sub_Type__c = null OR Eligible_Application_Sub_Type__c ' +
				appSubTypeINCLUDES +
				')';
		}

		return conditions;
	}

	/**
	 * @author                      : MTX Group Product Team
	 * @since                       : 23rd June, 2023
	 * @description                 : This method will give the list of Adobe Document Action button
	 * @param  appRecord            : Sobject
	 * @param objectType			: String
	 * @return                      : List<ButtonWrapper>
	 * @last modified by            : MTX Group Product Team
	 * @last modified date          : (Add if modified by you)
	 * @last modified details       : (Add if modified by you)
	 */
	private static List<ButtonWrapper> getPDFActionButton(Sobject appRecord, String objectType) {
		List<ButtonWrapper> buttonList = new List<ButtonWrapper>();
		String boardName = objectType == 'IndividualApplication'
			? ((IndividualApplication) appRecord).LicenseType.IssuingDepartment.Name
			: ((BusinessLicenseApplication) appRecord).LicenseType.IssuingDepartment.Name;
		String licenseType = objectType == 'IndividualApplication'
			? ((IndividualApplication) appRecord).LicenseType.Name
			: ((BusinessLicenseApplication) appRecord).LicenseType.Name;

		String licenseQuestions = objectType == 'IndividualApplication'
			? ((IndividualApplication) appRecord).SavedApplicationRef.License_Questions__c
			: ((BusinessLicenseApplication) appRecord).SavedApplicationRef.License_Questions__c;

		Map<String, Object> deserializedValueMap;
		if (String.isNotEmpty(licenseQuestions)) {
			deserializedValueMap = (Map<String, Object>) JSON.deserializeUntyped(String.valueOf(licenseQuestions));
		}
		 
		Map<String, Object> dataMap = new Map<String, Object>();
         
        if(
            boardName == HEALING_ARTS_BOARD &&
            objectType == 'IndividualApplication' &&
            appRecord.get('Amendment_Type__c') == PROF_CORP_NAME_APPROVAL_AMENDMENT
        ){
            dataMap.put('ApplicationType', (String) appRecord.get('Amendment_Type__c'));
            
        } else{
            dataMap.put('ApplicationType', (String) appRecord.get('ApplicationType'));
        }
		dataMap.put('AppliedDate', (Datetime) appRecord.get('AppliedDate'));
		if (deserializedValueMap != null) {
			dataMap.put('LicenseQuestion', deserializedValueMap);
		}
		 
		for (
			LPI_Document_Action_Config__mdt docActionConfig : LPI_ServiceUtility.getDocActionConfig(
				boardName,
				licenseType,
				(String) appRecord.get('Status'),
				APPLICATION_DETAIL_PAGE,
				dataMap
			)
		) {
			Map<String, String> pdfActionButtonData = new Map<String, String>();
			pdfActionButtonData.put(LPI_ApplicationViewController.TEMPLATE_NAME, docActionConfig.Template_Name__c);
			pdfActionButtonData.put(LPI_ApplicationViewController.ADOBE_PDF_MTD_NAME, docActionConfig.DeveloperName);
			buttonList.add(
				new ButtonWrapper(
					docActionConfig.Button_Label__c,
					LPI_ApplicationViewController.TYPE_ADOBE_PDF,
					JSON.serialize(pdfActionButtonData)
				)
			);
		}

		return buttonList;
	}

	/**
	 * @author                      : MTX Group Product Team
	 * @since                       : 26th July, 2023
	 * @description                 : This method will give the button for resume draft IA/BLA to Internal user
	 * @param  appRecord            : Sobject
	 * @return                      : ButtonWrapper
	 * @last modified by            : MTX Group Product Team
	 * @last modified date          : (Add if modified by you)
	 * @last modified details       : (Add if modified by you)
	 */
	private static ButtonWrapper getResumeApplicationButton(Sobject appRecord) {
		Boolean isSubmittedByInternalUser = (Boolean) appRecord.get('Is_Submitted_By_Internal_User__c');
		String status = (String) appRecord.get('Status');
		Boolean isPortalUser = LPI_WithoutSharingUtility.isPortalUser();
		if (!isPortalUser && isSubmittedByInternalUser && status == LPI_LiteralConstant.IA_DRAFT_STATUS) {
			String applicationType = (String) appRecord.get('ApplicationType');
			String applicationSubType = (String) appRecord.get('Amendment_Type__c');
			String licenseId = (String) appRecord.get('LicenseTypeId');
			String osType = '';
			String osSubType = '';
			String osLanguage = '';
			String fieldToQuery = 'Application_Flow__r.Type, Application_Flow__r.SubType, Application_Flow__r.Language, Application_Subtype__c';
			String whereClause =
				'Regulatory_Authorization_Type__c = \'' +
				licenseId +
				'\'' +
				' AND Application_Type__c = \'' +
				String.escapeSingleQuotes(applicationType) +
				'\'';
			List<Application_Flow_Config__c> appFlowConfigs = LPI_ApplicationFlowConfigDAO.getApplicationFlowConfigByDymanicQuery(
				fieldToQuery,
				whereClause,
				null,
				null,
				null
			);
			Application_Flow_Config__c appFlowConfigRecord = null;
			for (Application_Flow_Config__c appFlowCon : appFlowConfigs) {
				if (appFlowCon.Application_Subtype__c == applicationSubType) {
					appFlowConfigRecord = appFlowCon;
				}
			}
			if (
				appFlowConfigRecord == null &&
				appFlowConfigs.Size() == 1 &&
				applicationSubType != LPI_LiteralConstant.FEE_TYPE_AMENDMENT
			) {
				appFlowConfigRecord = appFlowConfigs[0];
			}
			if (appFlowConfigRecord != null) {
				osType = appFlowConfigRecord.Application_Flow__r.Type;
				osSubType = appFlowConfigRecord.Application_Flow__r.SubType;
				osLanguage = appFlowConfigRecord.Application_Flow__r.Language;
				Map<String, String> resumeApplicationButtonData = new Map<String, String>();
				resumeApplicationButtonData.put('osType', osType);
				resumeApplicationButtonData.put('osSubType', osSubType);
				resumeApplicationButtonData.put('osLanguage', osLanguage);
				return new ButtonWrapper(
					RESUME_APPLICATION_LABEL,
					RESUME_APPLICATION_TYPE,
					JSON.serialize(resumeApplicationButtonData)
				);
			}
		}
		return null;
	}

	/**
	 * @author                      : MTX Group Product Team
	 * @since                       : 29 Aug, 2023
	 * @description                 : This method will give the button for making pending payment on IA/BLA record page for Internal user
	 * @param  appRecord            : Sobject
	 * @return                      : ButtonWrapper
	 * @last modified by            : MTX Group Product Team
	 * @last modified date          : (Add if modified by you)
	 * @last modified details       : (Add if modified by you)
	 */
	private static ButtonWrapper getMakePaymentButton(Sobject appRecord, String objectType) {
		String applicationId = (String) appRecord.get('Id');
		String licenseTypeId = (String) appRecord.get('LicenseTypeId');
		String accId = (String) appRecord.get('AccountId');
		String applicationType = (String) appRecord.get('ApplicationType');
		String applicationSubType = (String) appRecord.get('Amendment_Type__c');
		Map<String, String> makePaymentButtonData = new Map<String, String>();
		makePaymentButtonData.put('applicationId', applicationId);
		makePaymentButtonData.put('licenseTypeId', licenseTypeId);
		makePaymentButtonData.put('accId', accId);
		makePaymentButtonData.put('objectType', objectType);
		makePaymentButtonData.put('applicationType', applicationType);
		makePaymentButtonData.put('applicationSubType', applicationSubType != null ? applicationSubType : '');
		makePaymentButtonData.put('recordId', applicationId);
		String unpaidRtfId = getLatestUnpaidRegTrxFeeId(applicationId);
		if (String.isNotBlank(unpaidRtfId)) {
			makePaymentButtonData.put('regTrxFeeId', unpaidRtfId);
		}
		return new ButtonWrapper(MAKE_PAYMENT_LABEL, MAKE_PAYMENT_VALUE, JSON.serialize(makePaymentButtonData));
	}

	/**
	 * @description Returns latest unpaid Regulatory Transaction Fee Id for Complete Pending Payment navigation
	 */
	private static String getLatestUnpaidRegTrxFeeId(String applicationId) {
		if (String.isBlank(applicationId)) {
			return null;
		}
		String whereClause =
			'ParentRecordId = \'' +
			String.escapeSingleQuotes(applicationId) +
			'\' AND (Status__c = \'' +
			LPI_LiteralConstant.IA_PAYMENT_PENDING_STATUS +
			'\' OR Status = \'Due\' OR Status = \'DUE\')';
		List<RegulatoryTrxnFee> rtfList = LPI_RegulatoryTrxnFeeDAO.getRegulatoryTrxnFeeByDymanicQuery(
			'Id',
			whereClause,
			'1',
			'CreatedDate',
			'DESC'
		);
		return rtfList.isEmpty() ? null : rtfList[0].Id;
	}

	/**
	 * @author                      : MTX Group Product Team
	 * @since                       : 29 August, 2023
	 * @description                 : This method is used to get the application actions data. This is specific for CRR user
	 * @param  recordId             : Takes Id of PAR/IA/BLA
	 * @return                      : `DataWrapper`
	 * @last modified by            : MTX Group Product Team
	 * @last modified date          : (Add if modified by you)
	 * @last modified details       : (Add if modified by you)
	 */
	@AuraEnabled
	public static DataWrapper getAppDataForCrr(Id recordId) {
		DataWrapper response;
		try {
			if (String.isNotBlank(recordId)) {
				String objectType = String.valueOf(recordId.getSObjectType());
				List<SObject> lstApplication;
				String fieldsToQuery =
					'Id, Name, AccountId, Status, ApplicationType, Amendment_Type__c, Applicant_submission_Date__c,AppliedDate,' +
					'LicensePermitNameId, LicenseTypeId, LicenseType.Name, LicenseType.IssuingDepartment.Name, Is_Submitted_By_Internal_User__c,SavedApplicationRefId,' +
					'SavedApplicationRef.License_Questions__c,Payment_Pending__c,Status__c';
				String condition = 'Id = ' + '\'' + String.escapeSingleQuotes(recordId) + '\'';
				switch on objectType {
					when 'IndividualApplication' {
						lstApplication = LPI_IndividualApplicationDAO.getIndividualApplicationByDymanicQuery(
							fieldsToQuery,
							condition,
							null,
							null,
							null
						);
					}
					when 'BusinessLicenseApplication' {
						lstApplication = LPI_BusinessLicenseApplicationDAO.getBusinessLicenseApplicationByDymanicQuery(
							fieldsToQuery,
							condition,
							null,
							null,
							null
						);
					}
				}
				if (!lstApplication.isEmpty()) {
					SObject applicationRecord = lstApplication[0];
					List<ButtonWrapper> buttonList = new List<ButtonWrapper>();
					RegulatoryAuthorizationType ratConfig = (RegulatoryAuthorizationType) applicationRecord.getSObject(
						'LicenseType'
					);
					 
					buttonList = getButtonList(applicationRecord);
					String ancillaryRAT;
					String regAuth = ratConfig.Name;
					 
					
                    if(!(Boolean) applicationRecord.get('Payment_Pending__c')){
                        Map<String, String> overPaymentButtonData = new Map<String, String>();
                        overPaymentButtonData.put('applicationId', (String) applicationRecord.get('Id'));
                        overPaymentButtonData.put('licenseTypeId', (String) applicationRecord.get('LicenseTypeId'));
                        overPaymentButtonData.put('accId', (String) applicationRecord.get('AccountId'));
                        overPaymentButtonData.put('objectType', objectType);
                        overPaymentButtonData.put('applicationType', (String) applicationRecord.get('ApplicationType'));
                        overPaymentButtonData.put('applicationSubType', (String) applicationRecord.get('Amendment_Type__c'));
                        buttonList.add(
                            new ButtonWrapper(
                                MAKE_OVER_PAYMENT_LABEL,
                                MAKE_OVER_PAYMENT_VALUE,
                                JSON.serialize(overPaymentButtonData)
                            )
                        );
                    }
					response = new DataWrapper(applicationRecord, ratConfig, buttonList);
				}
			}
		} catch (Exception e) {
			LPI_ExceptionManager.logException(recordId, getClassName(), 'getAppDataForCrr', e);
			throw new LPI_Exception(e.getMessage());
		}
		return response;
	}
	

	/**
	 * @author                      : MTX Group Product Team
	 * @since                       : 16th November, 2023
	 * @description                 : Method to return the list of Bad Check details
	 * @param  recordId             : Id of IA/BLA or Business License
	 * @return 						: List<BadCheckWrapper>
	 * @last modified by            : MTX Group Product Team
	 * @last modified date          : (Add if modified by you)
	 * @last modified details       : (Add if modified by you)
	 */
	@AuraEnabled
	public static List<BadCheckWrapper> getBadCheckDetails(Id recordId) {
		try {
            if(recordId == null){
                return null;
            }
			String objectType = String.valueOf(recordId.getSObjectType());
			Set<Id> applicationsIdSet = new Set<Id>();
			 
			List<BadCheckWrapper> resultList = new List<BadCheckWrapper>();

			 
			if (objectType == LPI_LiteralConstant.IA_SOBJECT_API || objectType == LPI_LiteralConstant.BLA_SOBJECT_API) {
				applicationsIdSet.add(recordId);
			}  
			else if (objectType == LPI_LiteralConstant.BUSINESSLICENSE_SOBJECT_API) {
				BusinessLicense blRecord = LPI_BusinessLicenseDAO.fetchBusinessLicenseRecords(
					'RegulatoryAuthorizationType.Authorisation_Type__c',
					'Id = \'' + recordId + '\''
				)[0];
				String fieldToQuery = 'Id';
				String whereClause = 'LicensePermitNameId = \'' + recordId + '\'';
				List<SObject> applicationList = blRecord.RegulatoryAuthorizationType.Authorisation_Type__c ==
				LPI_LiteralConstant.INDIVIDAULICENSE_APPTYPE
					? (List<SObject>) LPI_IndividualApplicationDAO.getIndividualApplicationByDymanicQuery(
							fieldToQuery,
							whereClause,
							null,
							null,
							null
					  )
					: (List<SObject>) LPI_BusinessLicenseApplicationDAO.getBusinessLicenseApplicationByDymanicQuery(
							fieldToQuery,
							whereClause,
							null,
							null,
							null
					  );
				for (SObject appRecord : applicationList) {
					applicationsIdSet.add((Id) appRecord.get('Id'));
				}
				applicationsIdSet.add(recordId);
			} 
		
			 
			if (!applicationsIdSet.isEmpty() || objectType == LPI_LiteralConstant.ACCOUNT_SOBJECT_API) {
				String fieldToQuery = 'Id, Name, Status__c, ParentRecordId, AccountId, Transaction_ID__c, TotalFeeAmount, '+
				'TYPEOF ParentRecord WHEN IndividualApplication THEN Name,LicenseTypeId,LicensePermitName.Name,LicensePermitNameId WHEN BusinessLicenseApplication THEN Name,LicenseTypeId,LicensePermitName.Name,LicensePermitNameId ' + 
				'WHEN BusinessLicense THEN Name,RegulatoryAuthorizationTypeId END';
				String whereClause = '';
				 
				if(objectType == LPI_LiteralConstant.ACCOUNT_SOBJECT_API){
					whereClause += 'AccountId = \'' + recordId + '\'';
				} else {
					whereClause += ' ParentRecordId IN ' + LPI_ServiceUtility.getStringValuesBySet(applicationsIdSet);
				}
				whereClause += ' AND Status__c = \'' + BAD_CHECK + '\' AND Fee_Against_Bad_Check__c	= null AND ParentRecord.Type IN ' + 
				LPI_ServiceUtility.getStringValuesByStringSet(new Set<String>{ 'IndividualApplication', 'BusinessLicenseApplication', 'BusinessLicense' });
				for (
					RegulatoryTrxnFee feeRecord : LPI_RegulatoryTrxnFeeDAO.getRTFByDymanicQueryWithoutSecurityEnforced(
						fieldToQuery,
						whereClause,
						null,
						null,
						null
					)
				) {
					BadCheckWrapper wrapper = new BadCheckWrapper();
					BusinessLicenseApplication objBLA;
					IndividualApplication objIA;
					BusinessLicense objBL;
					if (feeRecord.ParentRecord instanceof IndividualApplication) {
						objIA = (IndividualApplication) feeRecord.ParentRecord;
						wrapper.applicationName = objIA.Name;
						wrapper.licenseTypeId = objIA.LicenseTypeId;
						if(String.isNotBlank(objIA.LicensePermitNameId)){
							wrapper.licenseNo = objIA.LicensePermitName.Name;
							wrapper.licenseUrl = '/' + objIA.LicensePermitNameId;
						}
						wrapper.applicationUrl = '/' + feeRecord.ParentRecordId;
						wrapper.applicationId = feeRecord.ParentRecordId;
					} else if (feeRecord.ParentRecord instanceof BusinessLicenseApplication) {
						objBLA = (BusinessLicenseApplication) feeRecord.ParentRecord;
						wrapper.applicationName = objBLA.Name;
						wrapper.licenseTypeId = objBLA.LicenseTypeId;
						if(String.isNotBlank(objBLA.LicensePermitNameId)){
							wrapper.licenseNo = objBLA.LicensePermitName.Name;
							wrapper.licenseUrl = '/' + objBLA.LicensePermitNameId;
						}
						wrapper.applicationUrl = '/' + feeRecord.ParentRecordId;
						wrapper.applicationId = feeRecord.ParentRecordId;
					} else if (feeRecord.ParentRecord instanceof BusinessLicense) {
						objBL = (BusinessLicense) feeRecord.ParentRecord;
						wrapper.licenseNo = objBL.Name;
						wrapper.licenseTypeId = objBL.RegulatoryAuthorizationTypeId;
						wrapper.applicationId = feeRecord.ParentRecordId;
						wrapper.licenseUrl = '/' + feeRecord.ParentRecord;
					} else {
						continue;
					}
					
					wrapper.feeId = feeRecord.Id;
					wrapper.name = feeRecord.Name;
					wrapper.nameUrl = '/' + feeRecord.Id;
					wrapper.accountId = feeRecord.AccountId;
					wrapper.checkNumber = feeRecord.Transaction_ID__c;
					wrapper.status = feeRecord.Status__c;
					wrapper.feeAmount = feeRecord.TotalFeeAmount;
					wrapper.objectType = objectType;
					resultList.add(wrapper);
				}
			}
			return resultList;
		} catch (Exception e) {
			LPI_ExceptionManager.logException(getClassName(), 'getBadCheckDetails', e);
			throw new AuraHandledException(e.getMessage());
		}
	}

	/**
	 * @author                      : MTX Group Product Team
	 * @since                       : 22nd March, 2023
	 * @description                 : This method is a helper method and used to return the class name
	 * @param  recordId             : Takes Business License Application to be created
	 * @return                      : `String` Current Class Name
	 * @last modified by            : MTX Group Product Team
	 * @last modified date          : (Add if modified by you)
	 * @last modified details       : (Add if modified by you)
	 */
	private static String getClassName() {
		return 'LPI_ApplicationActionsController';
	}
    
	/**
	 * @author              : MTX Group Product Team
	 * @since               : 22nd March, 2023
	 * @description         : ApplicationData is a Wrapper Class to store the Application Data (IA/BLA)
	 */
	public class ApplicationData {
		@AuraEnabled
		public String applicationId;
		@AuraEnabled
		public String applicationName;
		@AuraEnabled
		public String licenceType;
		@AuraEnabled
		public String licenceTypeId;
		@AuraEnabled
		public String licenceId;
		@AuraEnabled
		public String submmittedDate;
		@AuraEnabled
		public String status;
		@AuraEnabled
		public String externalStatus;
		@AuraEnabled
		public String accountId;
		@AuraEnabled
		public String parId;
		@AuraEnabled
		public Boolean isCRRHold;
		@AuraEnabled
		public Boolean isExamEligible;
		@AuraEnabled
		public String writtenEligibleToTest;
		@AuraEnabled
		public String practicalEligibleToTest;
		@AuraEnabled
		public String applicationType;
		@AuraEnabled
		public String applicationSubType;
		@AuraEnabled
		public String EmbalmerFdLicenseId;
		@AuraEnabled
		public String primaryStateOfResidence;
	}

	
	public class ActionData {
		@AuraEnabled
		public String type;
		@AuraEnabled
		public String subType;
		public ActionData(String type, String subType) {
			this.type = type;
			this.subType = subType;
		}
	}

	
	public class ButtonWrapper {
		@AuraEnabled
		public String label;
		@AuraEnabled
		public String name;
		@AuraEnabled
		public String buttonData;

		public ButtonWrapper(String label, String name, String buttonData) {
			this.label = label;
			this.name = name;
			this.buttonData = buttonData;
		}
	}

	/**
	 * @author              : MTX Group Product Team
	 * @since               : 22nd March, 2023
	 * @description         : DataWrapper is a Wrapper Class that contains all the required data to show the
	 *                        application actions on the UI
	 */
	public class DataWrapper {
		@AuraEnabled
		public ApplicationData applicationData;
		@AuraEnabled
		public List<ButtonWrapper> buttonList;

		public DataWrapper(sObject application, RegulatoryAuthorizationType ratConfig, List<ButtonWrapper> buttonList) {
			this.applicationData = new ApplicationData();
			this.applicationData.applicationId = (String) application.get('Id');
			 
			this.applicationData.applicationName = (String) application.get('Name');
			this.applicationData.licenceId = (String) application.get('LicensePermitNameId');
			this.applicationData.licenceType = ratConfig.Name;
			this.applicationData.licenceTypeId = ratConfig.Id;
			this.applicationData.status = (String) application.get('Status');
			this.applicationData.externalStatus = (String) application.get('Status__c');
			this.applicationData.submmittedDate = application.get('Applicant_submission_Date__c') != null
				? ((Date) application.get('Applicant_submission_Date__c')).format()
				: null;
			this.applicationData.accountId = (String) application.get('AccountId');
			this.applicationData.parId = (String) application.get('SavedApplicationRefId');
			populateAppTypeAndSubType(application, ratConfig);
			this.buttonList = buttonList;
		}

		private void populateAppTypeAndSubType(sObject application, RegulatoryAuthorizationType ratConfig) {
			 
			List<Schema.PicklistEntry> values = PreliminaryApplicationRef.Amendment_Type__c.getDescribe()
				.getPicklistValues();
			Map<String, String> statusApiToLabelMap = new Map<String, String>();
			for (Schema.PicklistEntry sp : values) {
				 
				statusApiToLabelMap.put(sp.getValue(), sp.getLabel());
			}
			String typeValue = (String) application.get('ApplicationType');
			String subTypeValue = (String) application.get('Amendment_Type__c');
			Id applicationId = (Id) application.get('Id');
			String objectType = String.valueOf(applicationId.getSObjectType());
			String boardName = objectType == 'IndividualApplication'
				? ((IndividualApplication) application).LicenseType.IssuingDepartment.Name
				: ((BusinessLicenseApplication) application).LicenseType.IssuingDepartment.Name;

			this.applicationData.applicationType = statusApiToLabelMap.containsKey(typeValue)
				? statusApiToLabelMap.get(typeValue)
				: typeValue;
			this.applicationData.applicationSubType = statusApiToLabelMap.containsKey(subTypeValue)
				? statusApiToLabelMap.get(subTypeValue)
				: subTypeValue;

			this.applicationData.applicationSubType = LPI_ServiceUtility.getSubtypeLabelToShow(
				ratConfig.IssuingDepartment.Name,
				ratConfig.Name,
				this.applicationData.applicationSubType,
                this.applicationData.applicationType
			);
		}
	}

	public class BadCheckWrapper {
		@AuraEnabled
		public Id feeId { get; set; }
		@AuraEnabled
		public String name { get; set; }
		@AuraEnabled
		public String nameUrl { get; set; }
		@AuraEnabled
		public String applicationName;
		@AuraEnabled
		public String applicationId;
		@AuraEnabled
		public String accountId;
		@AuraEnabled
		public String checkNumber;
		@AuraEnabled
		public String status;
		@AuraEnabled
		public String objectType;
		@AuraEnabled
		public String licenseTypeId;
		@AuraEnabled
		public String licenseNo;
		@AuraEnabled
		public String applicationUrl;
		@AuraEnabled
		public String licenseUrl;
		@AuraEnabled
		public Decimal feeAmount;
	}
}