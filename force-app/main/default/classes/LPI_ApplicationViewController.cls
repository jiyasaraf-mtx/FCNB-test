/**
 * @author                      : MTX Group Inc
 * @since                       :
 * @description                 : Business Licesne View Page Controller
 * @last modified by            : Uzma Md
 * @last modified date          : 24 july, 2023
 * @modified details            : updated getPersonalInformation method
 */
public with sharing class LPI_ApplicationViewController {
	public static final String CLASS_NAME = 'LPI_ApplicationViewController';
	public static final String EXAMINATION_INFORMATION = 'Examination Information';
	public static final String INDIVIDUAL_BUSINESS_INFORMATION = 'Individual Business Information';
	public static final String PERSONAL_INFORMATION = 'Personal Information';
	public static final String CURRENT_EMPLOYMENT_INFORMATION = 'Current Employment Information';
	public static final String EMPLOYMENT_HISTORY = 'Employment History';
	public static final String MILITARY_QUESTIONS = 'Military Questions';
	public static final String EDUCATION_HISTORY = 'Education History';
	public static final String SCHOOL_INFORMATION = 'School Information';
	public static final String POST_GRADUATION_INFORMATION = 'Post Graduate Program Information';
	public static final String BUSINESS_INFORMATION = 'Business Information';
	public static final String BUSINESS_RELATIONSHIP = 'Relationship';
	public static final String LICENSE_DETAIL = 'License Details';
	public static final String COURSE_INFORMATION = 'Course Information';
	public static final String ALIAS_DETAIL = 'Alias Name(s)';
	public static final String PERSONAL_ADDITIONAL_INFORMATION = 'Personal Additional Information';
	public static final String ADDITIONAL_INFORMATION = 'Additional Information';
	public static final String RESIDENCE_ADDRESS = 'Residence Address';
	public static final String MAILING_ADDRESS = 'Mailing Address';
	public static final String PRIMARY_CONTACT_ADDRESS = 'Primary Contact Address';
	public static final String LICENSE_ADDRESS = 'License Address';
	public static final String PUBLICLY_DISPLAYED_ADDRESS = 'Publicly Displayed Address';
	public static final String DESIGNATED_INCHARGE_INFORMATION = 'Person In Charge Information';
	public static final String OWNERSHIP_INFORMATION = 'Ownership Information';
	public static final String CORPORATE_OFFICER_LIST = 'Corporate Officers';
	public final static String FACULTY_INFORMATION = 'Faculty Information';
	public final static String ANNUAL_REPORT_SURVEY = 'Annual Report Survey';
	public final static String GET_ENOTIFY_SUCCESS_FLAG = 'validateLicenseFromENotifyService';
	public final static String PROFESSIONAL_CORPORATION = 'Professional Corporation';
	public static final String TEMP_BEHIS_RAT = 'Temp Permit - BEHIS';
	public static final String APPROVED_STATUS = 'Approved';
	public static final String LICENSE_ISSUE_STATUS = 'License Issued';
	private final static String UNITED_STATES = 'United States';
	public static final String LICENSE_DETAIL_PAGE = 'License Detail Page';
	public static final String MENTOR = 'Mentor';
	public static final String PAID_STATUS = 'Paid';
	private static final String RESIDENCE = 'Residence';
	private static final String MAILING = 'Mailing';
	private static final String BUSINESS_ADDRESS = 'Business Address';
	private static final String LOCATION_STATUS = 'Open';
	private static final String BAD_CHECK_STATUS = 'Bad Check';
	public static final Set<String> ALLOW_CLOSE_LOCATION_TYPE_SET = new Set<String>{
		'Residence',
		'Mailing',
		'Business Address'
	};
	private static final String YES = 'Yes';
	private static final String NO = 'No';
	public static final Set<String> PROFILES_EXTRACT = new Set<String>{ 'Inspectors' };
	public static final String PROFILE_PORTAL_USER = 'Portal User';
	public static final String TEMPLATE_NAME = 'templateName';
	public static final String ADOBE_PDF_MTD_NAME = 'adobePdfMtdName';
	public static final String TYPE_ADOBE_PDF = 'AdobePDF';
	public static final String REINSTATEMENT_BY_EXAM = 'Reinstatement by Exam';
	private static final String OVER_PAYMENT = 'Overpayment';
	public final static Map<String, String> addressApiNameMap = new Map<String, string>{
		'Residence' => 'Residence Address',
		'Mailing' => 'Mailing Address',
		'Business Address' => 'Business Address',
		'Branch' => 'Branch Address',
		'Secondary Business Address' => 'Secondary Business Address',
		'Local Address' => 'Local Address',
		'Other' => 'Other Address',
		'Warehouse Address' => 'Warehouse Address'
	};
	private static final String SATELLITE_CLASSROOM = 'Satellite Classroom';
	private static final String HB_VISA = 'H1B Visa';
	private static final String STUDENT_VISA = 'F-1 Student Visa';
	private static final String VISA_PERMIT = 'Visa with stamped date of US entry';
	private static final String RESIDENT_CARD = 'US Permanent Resident Card';
	private static final String RESIDENT_CARD_EXPIRED = 'Permanent Resident Card Expired - Extension Granted';
	private static final String NATURALIZATION = 'Naturalization';
	private static final String FOREIGN = 'FOREIGN';
	private static final Set<String> US_RESIDENTS_SET = new Set<String>{ RESIDENT_CARD, RESIDENT_CARD_EXPIRED };
	private static final Set<String> VISA_PERMIT_SET = new Set<String>{ VISA_PERMIT, HB_VISA };
	private static final String LOCATION_TYPE_BRANCH = 'Branch';
	private static final String DOWNLOAD_THE_LICENSE_LABEL = 'Download a copy of my License';
	private static final String AUTHORISATION_TYPE_INDIVIDUAL = 'Individual';
	private static final String AUTHORISATION_TYPE_BUSINESS = 'Business';
	private static final String ROUTINE_SURVEY = 'Routine Survey';
	private static final String SITE_SURVEY_INSPECTION = 'Site Survey';
	private static final String ROUTINE_SURVEY_BUTTON_LABEL = 'Submit Site Survey Form';
	private static final Set<String> AUDIT_DETAIL_STATUS = new Set<String>{ 'Additional Info Needed', 'In Progress' };
	private static final Set<String> AUDIT_RECORD_TYPE_SET = new Set<String>{
		'Certification_Audit',
		'CE_Audit',
		'Insurance_Audit',
		'CDR_Audit'
	};

	private static final Map<String, String> AUDIT_BUTTON_LABEL_MAP = new Map<String, String>{
		'Certification_Audit' => 'Complete Certification Audit',
		'CE_Audit' => 'Complete CE Audit',
		'Insurance_Audit' => 'Complete Insurance Audit',
		'CDR_Audit' => 'Complete CDR Audit'
	};
	private final static String EXPIRED_STATUS = 'Expired';
	private final static String INACTIVE_STATUS = 'Inactive';
	private final static String PROFILE_SUPPORT_STAFF = 'Support Staff';
    public static final Set<String> PROF_CORP_NAME_APPROVAL_SET = new Set<String>{
		'Assistant Physician'
	};
	public static final String PROFESSIONAL_CORPORATION_NAME_APPROVAL = 'Apply for Professional Corporation Name Approval';
	public static final String PROFESSIONAL_CORPORATION_TYPE = 'Apply for Professional Corporation';

	/**
	 * @author                      : MTX Group Inc
	 * @since                       :
	 * @description                 : fetch Appication Data
	 * @return                      : DataWrapper
	 * @last modified by            : Uzma Md
	 * @last modified date          :
	 * @modified details            :
	 */
	@AuraEnabled
	public static DataWrapper getApplicationData(String blId, String blNumber, Boolean isCCRActions) {
		try {
			List<ApplicationViewWrapper> applicationViewList = new List<ApplicationViewWrapper>();
			List<String> locationIdList = new List<String>();
			Map<String, List<Schema.Location>> locationTypeToLocationMap = new Map<String, List<Schema.Location>>();
			List<Account> accRecordList = new List<Account>();
			Set<String> sectionList = new Set<String>();
			Id selectedAccountId;
			String profileName;
			List<User> u = LPI_UserDao.getCurrentUserRecord();
			if (!u.isEmpty()) {
				selectedAccountId = u[0].Account.SelectedAccountId__c;
				profileName = u[0].Profile.Name;
			}
			String qyeryFields =
				'Id,Name,Legacy_License_Number__c,RegulatoryAuthorizationTypeId,RegulatoryAuthorizationType.License_Actions__c,' +
				'RegulatoryAuthorizationType.Section_Names__c,RegulatoryAuthorizationType.Inactivation_Allowed__c,RegulatoryAuthorizationType.Reactivation_Allowed__c,' +
				'RegulatoryAuthorizationType.Extended_Expiry_Period__c,' +
				'RegulatoryAuthorizationType.Reinstatement_Allowed__c,RegulatoryAuthorizationType.Renewal_Required__c,' +
				'RegulatoryAuthorizationType.Renwal_Eligible__c,RegulatoryAuthorizationType.Open_for_Renewal__c,' +
				'RegulatoryAuthorizationType.Late_Renewal_Allowed__c,RegulatoryAuthorizationType.Amendment_Type__c,' +
				'RegulatoryAuthorizationType.ID_Card_Open_for_Renewal__c,RegulatoryAuthorizationType.Eligible_License_Type_Change__c,' +
				'RegulatoryAuthorizationType.Eligible_Additional_License_Type__c,RegulatoryAuthorizationType.name,PeriodEnd,Renewal_date__c, Status,PeriodStart,' +
				'AccountId,First_Name__c,Last_Name__c,Middle_Name__c,Account.Buisness_Email__c,Account.BillingCity, Account.BillingPostalCode, Account.BillingState,' +
				'Account.BillingStreet,Account.Date_of_Birth__c,Account.Entity_type__c,Account.Name,Account.Fictitious_Name__c, Account.Date_of_Incorporation__c, Account.Doing_Business_As_DBA_or_Trade_Name__c,' +
				'Account.State_of_Incorporation__c,Account.MO_State_Tax_ID_Number__c,Account.Fax, Account.Phone, Account.Website,Account.Federal_Employer_ID_Number_EIN__c,' +
				'Account.How_are_you_associated_to_this_entity__c,Account.MO_State_Registration_Number__c,' +
				'ContactId,contact.AccountId,contact.Account.FirstName,contact.Account.LastName, contact.Account.MiddleName,' +
				'contact.Account.Maiden_Name__c,contact.Account.Suffix,contact.Account.HaveYouAnotherName__c,contact.Account.Other_Names__c, contact.Account.PersonEmail,' +
				'contact.Account.Social_Security_Number__c, contact.Account.Date_of_Birth__c,contact.Account.Age__c,contact.Account.Gender__c,contact.Account.Place_of_Birth__c,' +
				'contact.Account.Phone, contact.Account.Fax,contact.Account.PersonHomePhone,' +
				'contact.Account.Race__c, contact.Account.Language__c,contact.Account.Citizenship__c,' +
				'Are_you_Currently_Employeed__c,Info_About_Military_Related_Services__c,Served_In_US_Armed_Force__c,' +
				'Is_Apply_for_ICE_credit__c,(SELECT Id,PlaceId FROM ApplAuthorization),' +
				'License_Sub_status__c, ' +
				'RegulatoryAuthorizationType.Subsequent_Reinstatement_Period__c,Reinstatement_Count__c, Inactivation_Date__c, RegulatoryAuthorizationType.Reactivation_Period__c,' +
				'Maiden_Name__c,Regulatory_Authorization_Type_Name__c, Approved_Supervisor__c,' +
				'RegulatoryAuthorizationType.IssuingDepartment.Name,Certificate_of_Identification_Issued__c,RegulatoryAuthorizationType.Reinstatement_by_Exam_Period__c,' +
				'RegulatoryAuthorizationType.Authorisation_Type__c,Primary_Contact_Address__c,License_Address__c,Publicly_Displayed_Address__c,' +
				'Account.Parent.Name, Account.Parent.Phone, Account.Parent.Fax, Account.Parent.Buisness_Email__c, Account.Parent.BillingStreet, Account.Parent.BillingCity,' +
				'Account.Parent.BillingState, Account.Parent.BillingPostalCode,Account.Parent.BillingCountryCode, Account.Parent.Other_State__c,' +
				'Account.Parent.BillingCountry, Account.BillingCountry, Account.BillingCountryCode, Account.Other_State__c,' +
				'Account.Proof_of_work_permit_in_United_States__c,Board_Name__c,Account.Proof_of_Citizenship__c, Account.Citizenship__c,Account.ParentId,Business_Entity_Name__c,' ;
			qyeryFields +=
                '(SELECT Status FROM IndividualApplicationPermit WHERE ' +
				'(ApplicationType = \'' +
				String.escapeSingleQuotes('Renewal') +
				'\'';
            qyeryFields +=
				' AND ( Status = \'' +
				APPROVED_STATUS +
				'\'' +
				' OR Status = \'' +
				LICENSE_ISSUE_STATUS +
				'\' )';
            qyeryFields += ' AND LicenseType.Name = \'' + String.escapeSingleQuotes(TEMP_BEHIS_RAT) + '\') OR (';
            qyeryFields += 'LicenseType.Name IN ' + LPI_ServiceUtility.getStringValuesByStringSet(PROF_CORP_NAME_APPROVAL_SET);
            qyeryFields += ' AND ApplicationType = \'' + String.escapeSingleQuotes('Amendment') + '\'';
            qyeryFields += ' AND Amendment_Type__c = \'' + String.escapeSingleQuotes(PROFESSIONAL_CORPORATION_NAME_APPROVAL) + '\'';
            qyeryFields += ' AND Status = \'' + APPROVED_STATUS + '\'';
            qyeryFields += '))';
			List<BusinessLicense> blRecordList = (new LPI_BusinessLicenseDAO.LPI_BusinessLicenseWithoutSharingDAO())
				.getBusinessLicenseByDymanicQuery(
					qyeryFields,
					String.isEmpty(blId)
						? 'Name = ' + '\'' + String.escapeSingleQuotes(blNumber) + '\''
						: 'Id = ' + '\'' + String.escapeSingleQuotes(blId) + '\'',
					null,
					null,
					null
				);
			if (!blRecordList.isEmpty()) {
				BusinessLicense blRecord = blRecordList[0];
				if (blRecord.AccountId != null) {
					if (profileName == PROFILE_PORTAL_USER) {
						Set<Id> accIdSet = LPI_DashbaordTableCtrl.getRelatedAccIdsSet();
						if (!accIdSet.isEmpty()) {
							Set<Id> checkAccessId = LPI_RelationshipService.getRelatedAccountIdFromMultipleAccount(
								accIdSet
							);
							if (!checkAccessId.contains(blRecord.AccountId)) {
								return null;
							}
						}
					}
					accRecordList = LPI_AccountDAO.getAccountListByDynamicQuery(
						new List<String>{
							'Id',
							'(SELECT Id,Name,Immediate_Supervisor_s_Name__c,' +
							'Supervisor_s_Phone_number__c,EmployerCity,Position,' +
							'StartDate,EndDate, EmployerState FROM PersonEmploymentDetails)',
							'(Select Id, Name, Course_Type__c, Course__c,Course_ID__c,Expiry_Date__c,Delivery_Method__c ' +
							' FROM Training_Courses__r)'
						},
						'Id = ' +
							'\'' +
							String.escapeSingleQuotes(blRecord.AccountId) +
							'\'',
						null,
						null,
						null
					);
				}

				if (blRecord.RegulatoryAuthorizationType.Section_Names__c != null) {
					for (String sectionName : blRecord.RegulatoryAuthorizationType.Section_Names__c.split(';')) {
						sectionList.add(sectionName);
					}
				}
				if (!sectionList.isEmpty()) {
					
					if (blRecord != null && blRecord.ApplAuthorization.size() > 0) {
						for (AuthApplicationPlace place : blRecord.ApplAuthorization) {
							locationIdList.add(place.PlaceId);
						}
						locationTypeToLocationMap = getLocationMap(locationIdList);
					}
					
					if (sectionList.contains(LICENSE_DETAIL)) {
						applicationViewList.add(getLicenseDetail(blRecord));
					}
					
					if (sectionList.contains(PERSONAL_INFORMATION)) {
						applicationViewList.add(getPersonalInformation(blRecord, locationTypeToLocationMap));
					}
					
					if (sectionList.contains(PERSONAL_ADDITIONAL_INFORMATION)) {
						applicationViewList.add(getPersonalAdditionalInformation(blRecord));
					}
					
					if (
						sectionList.contains(INDIVIDUAL_BUSINESS_INFORMATION) &&
						locationTypeToLocationMap.containsKey(LPI_LiteralConstant.LOCATION_TYPE_BUSINESS_ADDRESS)
					) {
						applicationViewList.add(
							getIndividualBusinessInformation(
								locationTypeToLocationMap.get(LPI_LiteralConstant.LOCATION_TYPE_BUSINESS_ADDRESS)
							)
						);
					}
					
					if (sectionList.contains(BUSINESS_INFORMATION)) {
						applicationViewList.add(getBusinessInformation(blRecord, locationTypeToLocationMap));
					}
					
					if (sectionList.contains(BUSINESS_RELATIONSHIP)) {
						applicationViewList.add(getBusinessRelationship(blRecord));
					}
					
					if (sectionList.contains(SCHOOL_INFORMATION)) {
						applicationViewList.add(getSchoolDetail(blRecord));
					}
					
					if (
						sectionList.contains(COURSE_INFORMATION) &&
						(!accRecordList.isEmpty() && accRecordList[0].Training_Courses__r.size() > 0)
					) {
						applicationViewList.add(getCourseDetail(accRecordList[0].Training_Courses__r));
					}

					
					if (sectionList.contains(EXAMINATION_INFORMATION)) {
						applicationViewList.add(getExaminationInformation(blRecord));
					}
					
					if (sectionList.contains(CURRENT_EMPLOYMENT_INFORMATION)) {
						applicationViewList.add(getCurrentEmploymentInformation(blRecord));
					}
					
					if (
						sectionList.contains(EMPLOYMENT_HISTORY) &&
						(!accRecordList.isEmpty() && accRecordList[0].PersonEmploymentDetails.size() > 0)
					) {
						applicationViewList.add(getEmploymentHistory(accRecordList[0].PersonEmploymentDetails));
					}
					
					if (sectionList.contains(MILITARY_QUESTIONS)) {
						applicationViewList.add(getMilitaryQuestions(blRecord));
					}
					
					if (sectionList.contains(EDUCATION_HISTORY)) {
						applicationViewList.add(getEducationHistory(blRecord.ContactId, false));
					}
					
					if (sectionList.contains(POST_GRADUATION_INFORMATION)) {
						applicationViewList.add(getEducationHistory(blRecord.ContactId, true));
					}
					
					if (sectionList.contains(FACULTY_INFORMATION)) {
						applicationViewList.add(getFacultyInformation(blRecord));
					}
				}
				if (!PROFILES_EXTRACT.contains(profileName)) {
					return new DataWrapper(
						blRecord.RegulatoryAuthorizationTypeId,
						blRecord.AccountId,
						blRecord.Id,
						applicationViewList,
						getButtonList(blRecord, isCCRActions),
						blRecord.RegulatoryAuthorizationType.IssuingDepartment.Name,
						blRecord.RegulatoryAuthorizationType.Name
					);
				} else {
					return new DataWrapper(
						blRecord.RegulatoryAuthorizationTypeId,
						blRecord.AccountId,
						blRecord.Id,
						applicationViewList,
						new List<ButtonWrapper>(),
						blRecord.RegulatoryAuthorizationType.IssuingDepartment.Name,
						blRecord.RegulatoryAuthorizationType.Name
					);
				}
			} else {
				return null; 
			}
		} catch (Exception e) {
			LPI_ExceptionManager.logException(CLASS_NAME, 'getApplicationData', e);
			throw new AuraHandledException(e.getMessage());
		}
	}
	/**
	 * @author                      : MTX Group Inc
	 * @since                       :
	 * @description                 : fetch Button list we have to show on UI
	 * @return                      : List<ButtonWrapper>
	 * @last modified by            : Uzma Md
	 * @last modified date          :
	 * @modified details            :
	 */
	public static List<ButtonWrapper> getButtonList(BusinessLicense blRecord, Boolean isCRRActions) {
		try {
			Map<Id, String> blIdToRoutineVisitNotSubmittedValueMap = new Map<Id, String>();
			Map<String, String> labelValueMap = new Map<String, String>();
			Boolean isRenewalEligible = false;
			Boolean isReinstatementEligible = false;
			Boolean isReactivationEligible = false;
			Schema.DescribeFieldResult fieldLabelResult = RegulatoryAuthorizationType.License_Actions__c.getDescribe();
			List<Schema.PicklistEntry> pickListValues = fieldLabelResult.getPicklistValues();
			for (Schema.PicklistEntry value : pickListValues) {
				labelValueMap.put(value.getValue(), value.getLabel());
			}
			
			LPI_VisitControllerDAO.LPI_VisitControllerWithoutSharingDAO visitObj = new LPI_VisitControllerDAO.LPI_VisitControllerWithoutSharingDAO();
			List<ButtonWrapper> buttonList = new List<ButtonWrapper>();
			Boolean portalUser = LPI_WithoutSharingUtility.isPortalUser();
			
			Map<String, Boolean> isActionAllowedMap = getIsActionAllowedMap(
				blRecord.RegulatoryAuthorizationTypeId,
				blRecord.status,
				isCRRActions
			);
			
			if (
				isActionAllowedMap.containsKey('Renewal') &&
				isActionAllowedMap.get('Renewal') &&
				LPI_BusinessLicenseUtility.checkForRenewal(blRecord)
			) {
				isRenewalEligible = true;
			}
			
			if (
				isActionAllowedMap.containsKey(LPI_LiteralConstant.PAR_SOBJECT_TYPE_REACTIVATION) &&
				isActionAllowedMap.get(LPI_LiteralConstant.PAR_SOBJECT_TYPE_REACTIVATION) &&
				LPI_BusinessLicenseUtility.checkForReactivation(blRecord)
			) {
				isReactivationEligible = true;
				
			}
			
			String reinstatemenmtKey = '';
			String reinstatemenmtType = '';
			reinstatemenmtKey = reinstatemenmtType = LPI_LiteralConstant.PAR_SOBJECT_TYPE_REINSTATEMENT;
			
			if (
				isActionAllowedMap.containsKey(reinstatemenmtKey) &&
				(isActionAllowedMap.get(reinstatemenmtKey) ||
				(isActionAllowedMap.containsKey(reinstatemenmtKey + LPI_LiteralConstant.LATE_REINSTATEMENT) &&
				isActionAllowedMap.get(reinstatemenmtKey + LPI_LiteralConstant.LATE_REINSTATEMENT))) &&
				LPI_BusinessLicenseUtility.checkForReinstatement(blRecord)
			) {
				isReinstatementEligible = true;
			}
			if (isCRRActions || portalUser) {
				if (
					isActionAllowedMap.containsKey(LPI_LiteralConstant.PAR_SOBJECT_TYPE_INACTIVATION) &&
					isActionAllowedMap.get(LPI_LiteralConstant.PAR_SOBJECT_TYPE_INACTIVATION)
				) {
					buttonList.add(
						new ButtonWrapper(
							LPI_LiteralConstant.PAR_SOBJECT_TYPE_INACTIVATION,
							LPI_LiteralConstant.PAR_SOBJECT_TYPE_INACTIVATION,
							'',
							false,
							null
						)
					);
				}
				
				if (isReactivationEligible) {
					buttonList.add(
						new ButtonWrapper(
							LPI_LiteralConstant.PAR_SOBJECT_TYPE_REACTIVATION,
							LPI_LiteralConstant.PAR_SOBJECT_TYPE_REACTIVATION,
							'',
							false,
							null
						)
					);
				}
				if (
					isActionAllowedMap.containsKey(LPI_LiteralConstant.BL_STATUS_RETIRED) &&
					isActionAllowedMap.get(LPI_LiteralConstant.BL_STATUS_RETIRED)
				) {
					buttonList.add(
						new ButtonWrapper(
							LPI_LiteralConstant.BL_STATUS_RETIRED,
							LPI_LiteralConstant.BL_STATUS_RETIRED,
							'',
							false,
							null
						)
					);
				}
				
				if (isReinstatementEligible) {
					Map<String, String> dataMap = new Map<String, String>();
					dataMap.put(reinstatemenmtType, 'true');
					buttonList.add(
						new ButtonWrapper(reinstatemenmtType, reinstatemenmtType, JSON.serialize(dataMap), false, null)
					);
				}
		
				if (
					isActionAllowedMap.containsKey('Renewal') &&
					isActionAllowedMap.get('Renewal') &&
					LPI_BusinessLicenseUtility.checkForRenewal(blRecord)
				) {
					Map<String, String> dataMap = new Map<String, String>();
					if (blRecord.PeriodEnd.Date() < System.today()) {
						dataMap.put('lateRenewal', 'true');
					} else {
						dataMap.put('lateRenewal', 'false');
					}
					buttonList.add(new ButtonWrapper('Renew', 'Renewal', JSON.serialize(dataMap), false, null));
				}
				if (
					LPI_BusinessLicenseUtility.checkForRenewal(blRecord) &&
					isActionAllowedMap.containsKey(ANNUAL_REPORT_SURVEY) &&
					isActionAllowedMap.get(ANNUAL_REPORT_SURVEY)
				) {
					buttonList.add(new ButtonWrapper(ANNUAL_REPORT_SURVEY, ANNUAL_REPORT_SURVEY, '', false, null));
				}
				if (
					LPI_BusinessLicenseUtility.checkForReinstatementByExam(blRecord) &&
					isActionAllowedMap.containsKey(REINSTATEMENT_BY_EXAM) &&
					isActionAllowedMap.get(REINSTATEMENT_BY_EXAM)
				) {
					buttonList.add(new ButtonWrapper(REINSTATEMENT_BY_EXAM, REINSTATEMENT_BY_EXAM, '', false, null));
				}
				if (blRecord.RegulatoryAuthorizationType.Amendment_Type__c != null) {
					List<ButtonWrapper> childButtonList = new List<ButtonWrapper>();
					List<Schema.PicklistEntry> fieldResult = RegulatoryAuthorizationType.Eligible_License_Type_Change__c.getDescribe()
						.getPicklistValues();
					Map<String, String> apiNameToLabelMap = new Map<String, String>();
					for (Schema.PicklistEntry pickListVal : fieldResult) {
						apiNameToLabelMap.put(pickListVal.getValue(), pickListVal.getLabel());
					}
					List<Schema.PicklistEntry> amendmentTypeFieldResult = RegulatoryAuthorizationType.Amendment_Type__c.getDescribe()
						.getPicklistValues();
					for (Schema.PicklistEntry pickListVal : amendmentTypeFieldResult) {
						apiNameToLabelMap.put(pickListVal.getValue(), pickListVal.getLabel());
					}
					for (String actions : blRecord.RegulatoryAuthorizationType.Amendment_Type__c.split(';')) {
						List<ButtonWrapper> childOfChildButtonList = new List<ButtonWrapper>();
						if (
							isActionAllowedMap.containsKey('Amendment' + actions) &&
							isActionAllowedMap.get('Amendment' + actions)
						) {
							if (
								actions == 'Change status to other status' &&
								blRecord.RegulatoryAuthorizationType.Eligible_License_Type_Change__c != null
							) {
								for (
									String childAction : blRecord.RegulatoryAuthorizationType.Eligible_License_Type_Change__c.split(
										';'
									)
								) {
									childOfChildButtonList.add(
										new ButtonWrapper(
											apiNameToLabelMap.containsKey(childAction)
												? apiNameToLabelMap.get(childAction)
												: childAction,
											childAction,
											'',
											false,
											null
										)
									);
								}
								childButtonList.add(
									new ButtonWrapper(
										actions,
										actions,
										'',
										true,
										childOfChildButtonList,
										'Change status to'
									)
								);
							} else {
								if (
									actions == 'Obtain Additional License' &&
									blRecord.RegulatoryAuthorizationType.Eligible_Additional_License_Type__c != null
								) {
									for (
										String childAction : blRecord.RegulatoryAuthorizationType.Eligible_Additional_License_Type__c.split(
											';'
										)
									) {
										childOfChildButtonList.add(
											new ButtonWrapper(
												apiNameToLabelMap.containsKey(childAction)
													? apiNameToLabelMap.get(childAction)
													: childAction,
												childAction,
												'',
												false,
												null
											)
										);
									}
									childButtonList.add(
										new ButtonWrapper(
											actions,
											actions,
											'',
											true,
											childOfChildButtonList,
											'Select License Type'
										)
									);
								} else if(
                                    actions != PROFESSIONAL_CORPORATION_TYPE ||
                                    (
                                        actions == PROFESSIONAL_CORPORATION_TYPE &&
                                        blRecord.IndividualApplicationPermit.size() > 0
                                    )
                                ){
									childButtonList.add(
										new ButtonWrapper(
											apiNameToLabelMap.containsKey(actions)
												? apiNameToLabelMap.get(actions)
												: actions,
											actions,
											'',
											false,
											null
										)
									);
								}
							}
						}
					}
					if (!childButtonList.isEmpty()) {
						String amendLabel = 'Amend';
						buttonList.add(new ButtonWrapper(amendLabel, 'Amendment', '', true, childButtonList));
					}
				}
				if (blRecord.RegulatoryAuthorizationType.License_Actions__c != null) {
					for (String actions : blRecord.RegulatoryAuthorizationType.License_Actions__c.split(';')) {
						if (isActionAllowedMap.containsKey(actions) && isActionAllowedMap.get(actions)) {
							switch on actions {
								
								when 'Apply for Non-preapproved Course Credit' {
									if (blRecord.Is_Apply_for_ICE_credit__c) {
										buttonList.add(new ButtonWrapper(actions, actions, '', false, null));
									}
								}
								when 'Professional Corporation' {
									if (portalUser == false) {
										buttonList.add(new ButtonWrapper(actions, actions, '', false, null));
									}
								}
								
								when 'Verification of Post Degree Supervised Counseling Experience' {
									if (blRecord.Approved_Supervisor__c) {
										
										buttonList.add(new ButtonWrapper(actions, actions, '', false, null));
									}
								}
								when 'Annual Registry Report' {
									Date annStartDate = Date.newInstance(Date.Today().year(), 1, 1);
									Date annEndDate = Date.newInstance(Date.Today().year(), 1, 31);
									if (Date.Today() >= AnnStartDate && Date.Today() <= AnnEndDate) {
										
										buttonList.add(new ButtonWrapper(actions, actions, '', false, null));
									}
								}
								when 'Request for Certificate of Identification' {
									if (blRecord.Certificate_of_Identification_Issued__c == NO) {
										buttonList.add(new ButtonWrapper(actions, actions, '', false, null));
									}
								}
								when 'Mentor' {
									if (portalUser == false) {
										buttonList.add(new ButtonWrapper(actions, actions, '', false, null));
									}
								}
								when 'Routine Survey' {
									
									if (blIdToRoutineVisitNotSubmittedValueMap.get(blRecord.Id) == 'No') {
										buttonList.add(
											new ButtonWrapper(ROUTINE_SURVEY_BUTTON_LABEL, actions, '', false, null)
										);
									}
								}
								when else {
									buttonList.add(
										new ButtonWrapper(
											labelValueMap.containsKey(actions) ? labelValueMap.get(actions) : actions,
											actions,
											'',
											false,
											null
										)
									);
								}
							}
						}
					}
				}
			}
			
			if(isCRRActions){
				buttonList.add(new ButtonWrapper(OVER_PAYMENT, OVER_PAYMENT, null, false, null));
			}
			buttonList.addAll(getAuditButton(blRecord.Id));
			buttonList.addAll(getPDFActionButton(blRecord, isRenewalEligible, isReinstatementEligible));

			return buttonList;
		} catch (Exception e) {
			LPI_ExceptionManager.logException(CLASS_NAME, 'getButtonList', e);
			throw new AuraHandledException(e.getMessage());
		}
	}

	/**
	 * @author                      : MTX Group Inc
	 * @since                       :
	 * @description                 : fetch getBusinessRelationship
	 * @return                      : ApplicationViewWrapper
	 * @last modified by            : Uzma Md
	 * @last modified date          :
	 * @modified details            :
	 */
	public static ApplicationViewWrapper getBusinessRelationship(BusinessLicense blRecord) {
		try {
			List<FieldHeadingWrapper> fieldHeadingWrapperList = new List<FieldHeadingWrapper>();
			LPI_BusinessRelationshipDAO.LPI_BusinessRelationshipsWithoutSharingDAO withoutSharingQuery = new LPI_BusinessRelationshipDAO.LPI_BusinessRelationshipsWithoutSharingDAO();
			List<Business_Relationships__c> listOfACR = withoutSharingQuery.getBusinessRelationshipsByDymanicQuery(
				'Id,Related_To__c,Related_From__c,Related_To__r.Name,Related_From__r.Name,Roles__c,Start_Date__c, EndDate__c, IsActive__c,Related_From_License_Number__r.Name,Related_To_License_Number__r.Name,Related_To_License_Number__r.RegulatoryAuthorizationType.Name,Related_From_License_Number__r.RegulatoryAuthorizationType.Name',
				' ( Related_From_License_Number__c = ' +
					'\'' +
					String.escapeSingleQuotes(blRecord.Id) +
					'\'' +
					' OR Related_To_License_Number__c = ' +
					'\'' +
					String.escapeSingleQuotes(blRecord.Id) +
					'\'' +
					' ) AND IsActive__c = true AND ( EndDate__c = null OR EndDate__c >= TODAY)',
				null,
				null,
				null
			);
			if (!listOfACR.isEmpty()) {
				for (Business_Relationships__c bRRecord : listOfACR) {
					List<FieldValueWrapper> fieldValues = new List<FieldValueWrapper>();
					fieldValues.add(
						new FieldValueWrapper('Related To', bRRecord.Related_To__r.Name, true, bRRecord.Related_To__c)
					);
					fieldValues.add(
						new FieldValueWrapper(
							'Related To License Number',
							bRRecord.Related_To_License_Number__r.Name,
							true,
							bRRecord.Related_To_License_Number__c
						)
					);
					fieldValues.add(
						new FieldValueWrapper(
							'Related To License Type',
							bRRecord.Related_To_License_Number__r.RegulatoryAuthorizationType.Name,
							false,
							null
						)
					);
					fieldValues.add(
						new FieldValueWrapper(
							'Related From',
							bRRecord.Related_From__r.Name,
							true,
							bRRecord.Related_From__c
						)
					);
					fieldValues.add(
						new FieldValueWrapper(
							'Related From License Number',
							bRRecord.Related_From_License_Number__r.Name,
							true,
							bRRecord.Related_From_License_Number__c
						)
					);
					fieldValues.add(
						new FieldValueWrapper(
							'Related From License Type',
							bRRecord.Related_From_License_Number__r.RegulatoryAuthorizationType.Name,
							false,
							null
						)
					);
					fieldValues.add(new FieldValueWrapper('Role', bRRecord.Roles__c, false, null));
					fieldValues.add(
						new FieldValueWrapper(
							'Start Date',
							convertDateFormat(String.valueOf(bRRecord.Start_Date__c?.format())),
							false,
							null
						)
					);
					fieldValues.add(
						new FieldValueWrapper(
							'End Date',
							convertDateFormat(String.valueOf(bRRecord.EndDate__c?.format())),
							false,
							null
						)
					);
					fieldHeadingWrapperList.add(new FieldHeadingWrapper(fieldValues, false, null));
				}
				return new ApplicationViewWrapper('Active Relationships', fieldHeadingWrapperList, false, null);
			} else {
				List<FieldValueWrapper> fieldValues = new List<FieldValueWrapper>();
				fieldValues.add(new FieldValueWrapper(null, 'No active relationships associated', false, null));
				fieldHeadingWrapperList.add(new FieldHeadingWrapper(fieldValues, false, null));
				return new ApplicationViewWrapper('Active Relationships', fieldHeadingWrapperList, false, null);
			}
		} catch (Exception e) {
			LPI_ExceptionManager.logException(CLASS_NAME, 'getBusinessRelationship', e);
			throw new AuraHandledException(e.getMessage());
		}
	}

	/**
	 * @author                      : MTX Group Inc
	 * @since                       :
	 * @description                 : fetch PersonalAdditionalInformation
	 * @return                      : ApplicationViewWrapper
	 * @last modified by            : Uzma Md
	 * @last modified date          :
	 * @modified details            :
	 */
	public static ApplicationViewWrapper getPersonalAdditionalInformation(BusinessLicense blRecord) {
		try {
			List<FieldHeadingWrapper> fieldHeadingWrapperList = new List<FieldHeadingWrapper>();
			List<FieldValueWrapper> fieldValues = new List<FieldValueWrapper>();
			
			List<HeadingFieldValueWrapper> headingFieldValueList = new List<HeadingFieldValueWrapper>();
			
			List<FieldValueWrapper> amateurFieldValues = new List<FieldValueWrapper>();
			
			headingFieldValueList.add(new HeadingFieldValueWrapper('Amateur Result', amateurFieldValues));

			fieldHeadingWrapperList.add(new FieldHeadingWrapper(fieldValues, true, headingFieldValueList));
			return new ApplicationViewWrapper(ADDITIONAL_INFORMATION, fieldHeadingWrapperList, false, null);
		} catch (Exception e) {
			LPI_ExceptionManager.logException(CLASS_NAME, 'getPersonalAdditionalInformation', e);
			throw new AuraHandledException(e.getMessage());
		}
	}
	/**
	 * @author                      : MTX Group Inc
	 * @since                       :
	 * @description                 : fetch CourseDetail
	 * @return                      : ApplicationViewWrapper
	 * @last modified by            : Uzma Md
	 * @last modified date          :
	 * @modified details            :
	 */
	public static ApplicationViewWrapper getCourseDetail(List<TrnCourse> courseDetailList) {
		try {
			List<FieldHeadingWrapper> fieldHeadingWrapperList = new List<FieldHeadingWrapper>();
			Date expiryDate;
			for (TrnCourse course : courseDetailList) {
				List<FieldValueWrapper> fieldValues = new List<FieldValueWrapper>();
				fieldValues.add(new FieldValueWrapper('Course Id', course.Course_ID__c));
				fieldValues.add(new FieldValueWrapper('Course Title', course.Name, true, course.Id));
				fieldValues.add(new FieldValueWrapper('Course Type', course.Course_Type__c));
				fieldValues.add(new FieldValueWrapper('Course', course.Course__c));
				fieldValues.add(
					new FieldValueWrapper(
						'Expiry Date',
						convertDateFormat(String.valueOf(course.Expiry_Date__c?.format()))
					)
				);
				fieldValues.add(new FieldValueWrapper('Delivery Method', course.Delivery_Method__c));
				Map<String, String> dataMap = new Map<String, String>();
				dataMap.put('type', 'Renewal');
				dataMap.put('amendmentType', 'Course Renewal');
				dataMap.put('courseId', course.Id);
				ButtonWrapper bW = new ButtonWrapper('Renew Course', 'Renewal', JSON.serialize(dataMap), false, null);
				if (course.Expiry_Date__c != null) {
					expiryDate = date.newinstance(
						course.Expiry_Date__c.year(),
						course.Expiry_Date__c.month(),
						course.Expiry_Date__c.day()
					);
					if (expiryDate >= System.today()) {
						fieldHeadingWrapperList.add(new FieldHeadingWrapper(fieldValues, true, bW, false, null));
					}
				} else {
					fieldHeadingWrapperList.add(new FieldHeadingWrapper(fieldValues, true, bW, false, null));
				}
			}
			return new ApplicationViewWrapper(COURSE_INFORMATION, fieldHeadingWrapperList, false, null);
		} catch (Exception e) {
			LPI_ExceptionManager.logException(CLASS_NAME, 'getCourseDetail', e);
			throw new AuraHandledException(e.getMessage());
		}
	}
	/**
	 * @author                      : MTX Group Inc
	 * @since                       :
	 * @description                 : fetch alias details
	 * @return                      : List<Alias__c>
	 */
	public static List<Alias__c> getAliasList(BusinessLicense blRecord) {
		try {
			List<FieldHeadingWrapper> fieldHeadingWrapperList = new List<FieldHeadingWrapper>();
			List<Alias__c> aliasDetailList = new List<Alias__c>();
			if (blRecord.AccountId != null) {
				aliasDetailList = [
					SELECT Id, Name, Alias_From_Date__c, Alias_Thru_Date__c, Alias_Type__c
					FROM Alias__c
					WHERE Account__c = :blRecord.AccountId
					WITH SECURITY_ENFORCED
				];
			}
			return aliasDetailList;
		} catch (Exception e) {
			LPI_ExceptionManager.logException(CLASS_NAME, 'getAliasList', e);
			throw new AuraHandledException(e.getMessage());
		}
	}

	/**
	 * @author                      : MTX Group Inc
	 * @since                       :
	 * @description                 : fetch SchoolDetail
	 * @return                      : ApplicationViewWrapper
	 * @last modified by            : Uzma Md
	 * @last modified date          :
	 * @modified details            :
	 */
	public static ApplicationViewWrapper getSchoolDetail(BusinessLicense blRecord) {
		try {
			if (blRecord.Regulatory_Authorization_Type_Name__c == SATELLITE_CLASSROOM) {
				List<FieldHeadingWrapper> fieldHeadingWrapperList = new List<FieldHeadingWrapper>();
				List<FieldValueWrapper> fieldValues = new List<FieldValueWrapper>();
				fieldValues.add(new FieldValueWrapper('School Name', blRecord.Account.Parent.Name));
				fieldValues.add(new FieldValueWrapper('School Telephone number', blRecord.Account.Parent.Phone));
				fieldValues.add(new FieldValueWrapper('School Fax Number', blRecord.Account.Parent.Fax));
				fieldValues.add(new FieldValueWrapper('E-mail address', blRecord.Account.Parent.Buisness_Email__c));
				List<HeadingFieldValueWrapper> headingFieldValueList = new List<HeadingFieldValueWrapper>();
				List<FieldValueWrapper> addressFieldValues = new List<FieldValueWrapper>();
				addressFieldValues.add(new FieldValueWrapper('Street Address', blRecord.Account.Parent.BillingStreet));
				addressFieldValues.add(new FieldValueWrapper('City', blRecord.Account.Parent.BillingCity));
				addressFieldValues.add(new FieldValueWrapper('Country', blRecord.Account.Parent.BillingCountry));
				if (blRecord.Account.Parent.BillingCountryCode == 'US') {
					addressFieldValues.add(new FieldValueWrapper('State', blRecord.Account.Parent.BillingState));
				} else {
					addressFieldValues.add(new FieldValueWrapper('State', blRecord.Account.Parent.Other_State__c));
				}
				addressFieldValues.add(new FieldValueWrapper('Zip Code', blRecord.Account.Parent.BillingPostalCode));
				headingFieldValueList.add(new HeadingFieldValueWrapper('School Address', addressFieldValues));
				fieldHeadingWrapperList.add(new FieldHeadingWrapper(fieldValues, true, headingFieldValueList));
				List<ApplicationViewWrapper> childSectionList = new List<ApplicationViewWrapper>();
				ApplicationViewWrapper childDataReference;
				childDataReference = getOwnerInformation(blRecord);
				if (childDataReference != null) {
					childSectionList.add(childDataReference);
				}
				childDataReference = getCorporateOfficerInformation(blRecord);
				if (childDataReference != null) {
					childSectionList.add(childDataReference);
				}
				return new ApplicationViewWrapper(SCHOOL_INFORMATION, fieldHeadingWrapperList, false, childSectionList);
			} else {
				List<FieldHeadingWrapper> fieldHeadingWrapperList = new List<FieldHeadingWrapper>();
				List<FieldValueWrapper> fieldValues = new List<FieldValueWrapper>();
				fieldValues.add(new FieldValueWrapper('School Name', blRecord.Account.Name));
				fieldValues.add(new FieldValueWrapper('School Telephone number', blRecord.Account.Phone));
				fieldValues.add(new FieldValueWrapper('School Fax Number', blRecord.Account.Fax));
				fieldValues.add(new FieldValueWrapper('E-mail address', blRecord.Account.Buisness_Email__c));
				List<HeadingFieldValueWrapper> headingFieldValueList = new List<HeadingFieldValueWrapper>();
				List<FieldValueWrapper> addressFieldValues = new List<FieldValueWrapper>();
				addressFieldValues.add(new FieldValueWrapper('Street Address', blRecord.Account.BillingStreet));
				addressFieldValues.add(new FieldValueWrapper('City', blRecord.Account.BillingCity));
				addressFieldValues.add(new FieldValueWrapper('Country', blRecord.Account.BillingCountry));
				if (blRecord.Account.BillingCountryCode == 'US') {
					addressFieldValues.add(new FieldValueWrapper('State', blRecord.Account.BillingState));
				} else {
					addressFieldValues.add(new FieldValueWrapper('State', blRecord.Account.Other_State__c));
				}
				addressFieldValues.add(new FieldValueWrapper('Zip Code', blRecord.Account.BillingPostalCode));
				headingFieldValueList.add(new HeadingFieldValueWrapper('School Address', addressFieldValues));
				fieldHeadingWrapperList.add(new FieldHeadingWrapper(fieldValues, true, headingFieldValueList));
				List<ApplicationViewWrapper> childSectionList = new List<ApplicationViewWrapper>();
				ApplicationViewWrapper childDataReference;
				childDataReference = getOwnerInformation(blRecord);
				if (childDataReference != null) {
					childSectionList.add(childDataReference);
				}
				childDataReference = getCorporateOfficerInformation(blRecord);
				if (childDataReference != null) {
					childSectionList.add(childDataReference);
				}

				return new ApplicationViewWrapper(SCHOOL_INFORMATION, fieldHeadingWrapperList, false, childSectionList);
			}
		} catch (Exception e) {
			LPI_ExceptionManager.logException(CLASS_NAME, 'getSchoolDetail', e);
			throw new AuraHandledException(e.getMessage());
		}
	}
	/**
	 * @author                      : MTX Group Inc
	 * @since                       :
	 * @description                 : fetch getLicenseDetail
	 * @return                      : ApplicationViewWrapper
	 * @last modified by            : Uzma Md
	 * @last modified date          :
	 * @modified details            :
	 */
	public static ApplicationViewWrapper getLicenseDetail(BusinessLicense blRecord) {
		try {
			List<FieldHeadingWrapper> fieldHeadingWrapperList = new List<FieldHeadingWrapper>();
			List<FieldValueWrapper> fieldValues = new List<FieldValueWrapper>();
			fieldValues.add(new FieldValueWrapper('License Type', blRecord.RegulatoryAuthorizationType.name));
			fieldValues.add(
				new FieldValueWrapper(
					'License Number',
					String.isNotBlank(blRecord.Legacy_License_Number__c)
						? blRecord.Legacy_License_Number__c
						: null
				)
			);
			fieldValues.add(
				new FieldValueWrapper('Issuance date', String.valueof(blRecord.PeriodStart?.format('MM/dd/yyyy')))
			);
			fieldValues.add(
				new FieldValueWrapper('Expiration date', string.valueOf(blRecord.PeriodEnd?.format('MM/dd/yyyy')))
			);
			fieldValues.add(new FieldValueWrapper('Status', blRecord.Status));
			fieldHeadingWrapperList.add(new FieldHeadingWrapper(fieldValues, false, null));
			return new ApplicationViewWrapper(LICENSE_DETAIL, fieldHeadingWrapperList, false, null);
		} catch (Exception e) {
			LPI_ExceptionManager.logException(CLASS_NAME, 'getLicenseDetail', e);
			throw new AuraHandledException(e.getMessage());
		}
	}
	/**
	 * @author                      : MTX Group Inc
	 * @since                       :
	 * @description                 : fetch getBusinessInformation
	 * @return                      : ApplicationViewWrapper
	 * @last modified by            : Uzma Md
	 * @last modified date          : 7 Jul 2023
	 * @modified details            : Added Primary Contact and License Address Details.
	 */
	public static ApplicationViewWrapper getBusinessInformation(
		BusinessLicense blRecord,
		Map<String, List<Schema.Location>> locationMap
	) {
		try {
			ApplicationViewWrapper childDataReference;
			List<FieldHeadingWrapper> fieldHeadingWrapperList;
			List<FieldHeadingWrapper> parentFieldHeadingWrapperList;
			if (blRecord.ContactId != null) {
				parentFieldHeadingWrapperList = new List<FieldHeadingWrapper>();
				List<FieldValueWrapper> fieldValues = new List<FieldValueWrapper>();
				fieldValues.add(
					new FieldValueWrapper(
						'Business/Agency Name',
						blRecord.Business_Entity_Name__c,
						true,
						blRecord.AccountId
					)
				);
				
				fieldValues.add(new FieldValueWrapper('Email Address', blRecord.Account.Buisness_Email__c));
				parentFieldHeadingWrapperList.add(new FieldHeadingWrapper(fieldValues, false, null));
			}
			List<ApplicationViewWrapper> childSectionList = new List<ApplicationViewWrapper>();

			if (
				locationMap.containsKey(LPI_LiteralConstant.LOCATION_TYPE_BUSINESS_ADDRESS) &&
				!locationMap.get(LPI_LiteralConstant.LOCATION_TYPE_BUSINESS_ADDRESS).isEmpty() &&
				!locationMap.get(LPI_LiteralConstant.LOCATION_TYPE_BUSINESS_ADDRESS)[0].Addresses.isEmpty()
			) {
				fieldHeadingWrapperList = new List<FieldHeadingWrapper>();
				fieldHeadingWrapperList.add(
					new FieldHeadingWrapper(
						getAddressFieldValueMap(
							locationMap.get(LPI_LiteralConstant.LOCATION_TYPE_BUSINESS_ADDRESS)[0].Addresses[0]
						),
						false,
						null
					)
				);
				childSectionList.add(
					new ApplicationViewWrapper(
						LPI_LiteralConstant.LOCATION_TYPE_BUSINESS_ADDRESS,
						fieldHeadingWrapperList,
						false,
						null
					)
				);
			}
			if (
				locationMap.containsKey(LPI_LiteralConstant.LOCATION_TYPE_MAILING) &&
				!locationMap.get(LPI_LiteralConstant.LOCATION_TYPE_MAILING).isEmpty() &&
				!locationMap.get(LPI_LiteralConstant.LOCATION_TYPE_MAILING)[0].Addresses.isEmpty()
			) {
				fieldHeadingWrapperList = new List<FieldHeadingWrapper>();
				fieldHeadingWrapperList.add(
					new FieldHeadingWrapper(
						getAddressFieldValueMap(locationMap.get(LPI_LiteralConstant.LOCATION_TYPE_MAILING)[0].Addresses[0]),
						false,
						null
					)
				);
				childSectionList.add(new ApplicationViewWrapper(MAILING_ADDRESS, fieldHeadingWrapperList, false, null));
			}
			List<FieldValueWrapper> fieldValues;
			if (blRecord.Primary_Contact_Address__c != null) {
				fieldHeadingWrapperList = new List<FieldHeadingWrapper>();
				fieldValues = new List<FieldValueWrapper>();
				fieldValues.add(
					new FieldValueWrapper('Address Type', addressApiNameMap.get(blRecord.Primary_Contact_Address__c))
				);
				fieldHeadingWrapperList.add(new FieldHeadingWrapper(fieldValues, true, null));
				
				if (
					locationMap.containsKey('Branch') ||
					locationMap.containsKey('Secondary Business Address') ||
					locationMap.containsKey('Warehouse Address') ||
					locationMap.containsKey('Other')
				) {
					if (
						locationMap.containsKey(blRecord.Primary_Contact_Address__c) &&
						!locationMap.get(blRecord.Primary_Contact_Address__c).isEmpty() &&
						!locationMap.get(blRecord.Primary_Contact_Address__c)[0].Addresses.isEmpty()
					) {
						fieldHeadingWrapperList.add(
							new FieldHeadingWrapper(
								getAddressFieldValueMap(
									locationMap.get(blRecord.Primary_Contact_Address__c)[0].Addresses[0]
								),
								false,
								null
							)
						);
					}
				}

				childSectionList.add(
					new ApplicationViewWrapper(PRIMARY_CONTACT_ADDRESS, fieldHeadingWrapperList, false, null)
				);
			}
			
			return new ApplicationViewWrapper(
				BUSINESS_INFORMATION,
				parentFieldHeadingWrapperList,
				true,
				childSectionList
			);
		} catch (Exception e) {
			LPI_ExceptionManager.logException(CLASS_NAME, 'getBusinessInformation', e);
			throw new AuraHandledException(e.getMessage());
		}
	}
	/**
	 * @author                      : MTX Group Inc
	 * @since                       :
	 * @description                 : fetch getDesignatedInchargeInformation
	 * @return                      : ApplicationViewWrapper
	 * @last modified by            : Uzma Md
	 * @last modified date          :
	 * @modified details            :
	 */
	public static ApplicationViewWrapper getDesignatedInchargeInformation(BusinessLicense blRecord) {
		try {
			List<FieldHeadingWrapper> fieldHeadingWrapperList = new List<FieldHeadingWrapper>();
			LPI_BusinessRelationshipDAO.LPI_BusinessRelationshipsWithoutSharingDAO withoutSharingQuery = new LPI_BusinessRelationshipDAO.LPI_BusinessRelationshipsWithoutSharingDAO();
			List<Business_Relationships__c> listOfACR = withoutSharingQuery.getBusinessRelationshipsByDymanicQuery(
				'Id, License_Number__c,Related_To__c ,Related_To__r.Name,Related_To__r.Phone,Related_To__r.PersonEmail',
				' Related_From__c = ' +
					'\'' +
					String.escapeSingleQuotes(blRecord.AccountId) +
					'\'' +
					' AND (Roles__c = ' +
					'\'' +
					String.escapeSingleQuotes(LPI_LiteralConstant.ROLE_DESIGNATED_INCHARGE) +
					'\'' +
					' OR Roles__c = ' +
					'\'' +
					String.escapeSingleQuotes(LPI_LiteralConstant.ROLE_DESIGNATED_INCHARGE_AND_OWNER) +
					'\'' +
					' ) AND IsActive__c = true AND EndDate__c = null ',
				'1',
				null,
				null
			);
			if (!listOfACR.isEmpty()) {
				List<FieldValueWrapper> fieldValues = new List<FieldValueWrapper>();
				fieldValues.add(
					new FieldValueWrapper('Name', listOfACR[0].Related_To__r.Name, true, listOfACR[0].Related_To__c)
				);
				fieldValues.add(
					new FieldValueWrapper('License Number', listOfACR[0]?.License_Number__c?.split('-')[0], false, null)
				);
				fieldValues.add(new FieldValueWrapper('Phone Number', listOfACR[0]?.Related_To__r.Phone, false, null));
				fieldValues.add(new FieldValueWrapper('Email', listOfACR[0]?.Related_To__r.PersonEmail, false, null));
				Schema.Address tempAddress = LPI_DesignatedInchargeController.fetchBlAddress(
					blRecord.Id,
					'Person In Charge Address'
				);
				if (tempAddress != null) {
					fieldValues.add(new FieldValueWrapper('Street Address', tempAddress.Street, false, null));
					fieldValues.add(new FieldValueWrapper('City', tempAddress.City, false, null));
					if (tempAddress.CountryCode == 'US') {
						fieldValues.add(new FieldValueWrapper('State', tempAddress.State, false, null));
					} else {
						fieldValues.add(new FieldValueWrapper('State', tempAddress.Business_State__c, false, null));
					}
					fieldValues.add(new FieldValueWrapper('Zip Code', tempAddress.PostalCode, false, null));
					fieldValues.add(new FieldValueWrapper('Country', tempAddress.Country, false, null));
					fieldValues.add(new FieldValueWrapper('County', tempAddress.County__c, false, null));
				}
				fieldHeadingWrapperList.add(new FieldHeadingWrapper(fieldValues, false, null));
				return new ApplicationViewWrapper(
					DESIGNATED_INCHARGE_INFORMATION,
					fieldHeadingWrapperList,
					false,
					null
				);
			} else {
				return null;
			}
		} catch (Exception e) {
			LPI_ExceptionManager.logException(CLASS_NAME, 'getDesignatedInchargeInformation', e);
			throw new AuraHandledException(e.getMessage());
		}
	}

	/**
	 * @author                      : MTX Group Inc
	 * @since                       :
	 * @description                 : fetch getCorporateOfficerInformation
	 * @return                      : ApplicationViewWrapper
	 * @last modified by            : Uzma Md
	 * @last modified date          :
	 * @modified details            :
	 */
	public static ApplicationViewWrapper getCorporateOfficerInformation(BusinessLicense blRecord) {
		try {
			if (
				String.isBlank(blRecord.Account.Entity_type__c) &&
				blRecord.Regulatory_Authorization_Type_Name__c != SATELLITE_CLASSROOM
			) {
				return null;
			}
			List<FieldHeadingWrapper> fieldHeadingWrapperList = new List<FieldHeadingWrapper>();
			List<HeadingFieldValueWrapper> headingFieldValueList = new List<HeadingFieldValueWrapper>();
			String queryBusinessAccountId = '';
			
			queryBusinessAccountId = String.isNotBlank(blRecord.Account.ParentId)
				? blRecord.Account.ParentId
				: blRecord.AccountId;
			
			Set<String> corporatorsRoleList = new Set<String>{
				'Board Director',
				'CEO',
				'Chairperson',
				'Corporate Officer',
				'Director',
				'Partner',
				'President',
				'Secretary',
				'Senior Vice President',
				'Shareholder',
				'Treasurer',
				'Vice President',
				'Operating Manager',
				'Manager',
				'Principal',
				'CFO (Chief Financial Officer)',
				'Executive Vice President',
				'Controlling Person',
				'COO'
			};

			String businessRelationShipWhereClouse =
				'Related_From__c =\'' +
				queryBusinessAccountId +
				'\' AND IsActive__c = true AND EndDate__c = NULL AND Roles__c IN  ' +
				LPI_ServiceUtility.getStringValuesByStringSet(corporatorsRoleList);
			List<Business_Relationships__c> relDataList = new LPI_BusinessRelationshipDAO.LPI_BusinessRelationshipsWithoutSharingDAO()
				.getBusinessRelationshipsByDymanicQuery(
					'Id, License_Number__c, Ownership_Percent__c, IsActive__c, License_Type__c,  Is_the_Owner_a_Business_Entity__c, Is_Licensed_Entity__c, Roles__c, Related_From__c, Related_To__c, Related_To__r.PersonEmail, Related_To__r.Name,Related_To__r.FirstName, Related_To__r.LastName, Related_To__r.MiddleName, Related_To__r.PersonOtherCity, Related_To__r.PersonOtherState, Related_To__r.PersonOtherPostalCode,Related_To__r.PersonOtherCountryCode, Related_To__r.PersonOtherStreet, Related_To__r.PersonOtherCountry, Related_To__r.Other_State__c, Related_To__r.County__c,  Related_To__r.Social_Security_Number__c, Related_To__r.Date_of_Birth__c',
					businessRelationShipWhereClouse,
					null,
					null,
					null
				);

			for (Business_Relationships__c acrRec : relDataList) {
				List<FieldValueWrapper> childFieldValues = new List<FieldValueWrapper>();

				childFieldValues.add(new FieldValueWrapper('Role/Title', acrRec.Roles__c));
				childFieldValues.add(
					new FieldValueWrapper(
						'Corporate Officer Name',
						acrRec.Related_To__r.Name,
						true,
						acrRec.Related_To__c
					)
				);
				String streetAdd = String.isNotEmpty(acrRec.Related_To__r.PersonOtherStreet)
					? acrRec.Related_To__r.PersonOtherStreet + ', '
					: '';
				String state = String.isNotEmpty(acrRec.Related_To__r.PersonOtherState) &&
					acrRec.Related_To__r.PersonOtherCountryCode == 'US'
					? acrRec.Related_To__r.PersonOtherState + ', '
					: String.isNotEmpty(acrRec.Related_To__r.Other_State__c)
							? acrRec.Related_To__r.Other_State__c + ', '
							: '';
				String city = String.isNotEmpty(acrRec.Related_To__r.PersonOtherCity)
					? acrRec.Related_To__r.PersonOtherCity + ', '
					: '';
				String zipCode = String.isNotEmpty(acrRec.Related_To__r.PersonOtherPostalCode)
					? acrRec.Related_To__r.PersonOtherPostalCode
					: '';
				String country = String.isNotEmpty(acrRec.Related_To__r.PersonOtherCountry)
					? acrRec.Related_To__r.PersonOtherCountry + ', '
					: '';
				String county = String.isNotEmpty(acrRec.Related_To__r.County__c)
					? acrRec.Related_To__r.County__c + ', '
					: '';

				childFieldValues.add(
					new FieldValueWrapper('Mailing Address', streetAdd + city + county + state + country + zipCode)
				);
				fieldHeadingWrapperList.add(new FieldHeadingWrapper(childFieldValues, false, null));
			}

			return new ApplicationViewWrapper(CORPORATE_OFFICER_LIST, fieldHeadingWrapperList, false, null);
		} catch (Exception e) {
			LPI_ExceptionManager.logException(CLASS_NAME, 'getCorporateOfficerInformation', e);
			throw new AuraHandledException(e.getMessage());
		}
	}
	/**
	 * @author                      : MTX Group Inc
	 * @since                       :
	 * @description                 : fetch getOwnerInformation
	 * @return                      : ApplicationViewWrapper
	 * @last modified by            : Uzma Md
	 * @last modified date          :
	 * @modified details            :
	 */
	public static ApplicationViewWrapper getOwnerInformation(BusinessLicense blRecord) {
		try {
			if (
				String.isBlank(blRecord.Account.Entity_type__c) &&
				blRecord.Regulatory_Authorization_Type_Name__c != SATELLITE_CLASSROOM
			) {
				return null;
			}
			String queryBusinessAccountId = '';
			List<FieldHeadingWrapper> fieldHeadingWrapperList = new List<FieldHeadingWrapper>();
			List<HeadingFieldValueWrapper> headingFieldValueList = new List<HeadingFieldValueWrapper>();
			
			queryBusinessAccountId = blRecord.AccountId;
			
			String businessRelationShipWhereClouse =
				'(Related_From__c =\'' +
				queryBusinessAccountId +
				'\' OR  Related_To__c=\'' +
				queryBusinessAccountId +
				'\')  AND Roles__c=\'' +
				LPI_LiteralConstant.ROLE_OWNER +
				'\' AND IsActive__c = true AND EndDate__c = NULL';
			LPI_BusinessRelationshipDAO.LPI_BusinessRelationshipsWithoutSharingDAO withoutSharingQuery = new LPI_BusinessRelationshipDAO.LPI_BusinessRelationshipsWithoutSharingDAO();
			List<Business_Relationships__c> listOfACR = withoutSharingQuery.getBusinessRelationshipsByDymanicQuery(
				'Id, License_Number__c, Ownership_Percent__c, Roles__c, ' +
					'Related_To_License_Number__r.License_Number_With_Rat_Name__c, Related_From_License_Number__r.License_Number_With_Rat_Name__c,' +
					' IsActive__c, Is_the_Owner_a_Business_Entity__c, Is_Licensed_Entity__c, Related_From__c, Related_To__c, ' +
					'Related_From__r.Name, Related_From__r.BillingStreet, Related_From__r.BillingCountry, Related_From__r.BillingCountryCode, Related_From__r.BillingCity, Related_From__r.BillingState, Related_From__r.BillingPostalCode, Related_From__r.County__c, Related_From__r.Other_State__c, ' +
					'Related_To__r.Name, Related_To__r.PersonOtherCity, Related_To__r.PersonOtherCountryCode, Related_To__r.Other_State__c, Related_To__r.County__c, Related_To__r.PersonOtherState, Related_To__r.PersonOtherCountry, Related_To__r.PersonOtherPostalCode, Related_To__r.PersonOtherStreet ',
				businessRelationShipWhereClouse,
				null,
				null,
				null
			);
			for (Business_Relationships__c acrRec : listOfACR) {
				List<FieldValueWrapper> childFieldValues = new List<FieldValueWrapper>();
				if (acrRec.Is_the_Owner_a_Business_Entity__c == 'Yes') {
					childFieldValues.add(
						new FieldValueWrapper(
							'Business Name',
							acrRec.Related_From__r.Name,
							true,
							acrRec.Related_From__c
						)
					);

					childFieldValues.add(
						new FieldValueWrapper(
							'Employer Board License Number',
							acrRec.Related_From_License_Number__r.License_Number_With_Rat_Name__c
						)
					);

					String streetAdd = String.isNotEmpty(acrRec.Related_From__r.BillingStreet)
						? acrRec.Related_From__r.BillingStreet + ', '
						: '';
					String state = String.isNotEmpty(acrRec.Related_From__r.BillingState) &&
						acrRec.Related_From__r.BillingCountryCode == 'US'
						? acrRec.Related_From__r.BillingState + ', '
						: String.isNotEmpty(acrRec.Related_From__r.Other_State__c)
								? acrRec.Related_From__r.Other_State__c + ', '
								: '';
					String city = String.isNotEmpty(acrRec.Related_From__r.BillingCity)
						? acrRec.Related_From__r.BillingCity + ', '
						: '';
					String zipCode = String.isNotEmpty(acrRec.Related_From__r.BillingPostalCode)
						? acrRec.Related_From__r.BillingPostalCode
						: '';
					String country = String.isNotEmpty(acrRec.Related_From__r.BillingCountry)
						? acrRec.Related_From__r.BillingCountry + ', '
						: '';
					String county = String.isNotEmpty(acrRec.Related_From__r.County__c)
						? acrRec.Related_From__r.County__c + ', '
						: '';

					childFieldValues.add(
						new FieldValueWrapper('Business Address', streetAdd + city + county + state + country + zipCode)
					);

					childFieldValues.add(
						new FieldValueWrapper('Ownership Percentage', String.valueOf(acrRec.Ownership_Percent__c) + '%')
					);
					fieldHeadingWrapperList.add(new FieldHeadingWrapper(childFieldValues, false, null));
				} else {
					childFieldValues.add(
						new FieldValueWrapper('Name', acrRec.Related_To__r.Name, true, acrRec.Related_To__c)
					);
					childFieldValues.add(
						new FieldValueWrapper(
							'License Number',
							acrRec.Related_To_License_Number__r.License_Number_With_Rat_Name__c
						)
					);
					String streetAdd = String.isNotEmpty(acrRec.Related_To__r.PersonOtherStreet)
						? acrRec.Related_To__r.PersonOtherStreet + ', '
						: '';
					String state = String.isNotEmpty(acrRec.Related_To__r.PersonOtherState) &&
						acrRec.Related_To__r.PersonOtherCountryCode != 'US'
						? acrRec.Related_To__r.PersonOtherState + ', '
						: String.isNotEmpty(acrRec.Related_To__r.Other_State__c)
								? acrRec.Related_To__r.Other_State__c + ', '
								: '';
					String city = String.isNotEmpty(acrRec.Related_To__r.PersonOtherCity)
						? acrRec.Related_To__r.PersonOtherCity + ', '
						: '';
					String zipCode = String.isNotEmpty(acrRec.Related_To__r.PersonOtherPostalCode)
						? acrRec.Related_To__r.PersonOtherPostalCode
						: '';
					String country = String.isNotEmpty(acrRec.Related_To__r.PersonOtherCountry)
						? acrRec.Related_To__r.PersonOtherCountry + ', '
						: '';
					String county = String.isNotEmpty(acrRec.Related_To__r.County__c)
						? acrRec.Related_To__r.County__c + ', '
						: '';

					childFieldValues.add(
						new FieldValueWrapper(
							'Residence Address',
							streetAdd + city + county + state + country + zipCode
						)
					);
					childFieldValues.add(
						new FieldValueWrapper('Ownership Percentage', String.valueOf(acrRec.Ownership_Percent__c) + '%')
					);
					fieldHeadingWrapperList.add(new FieldHeadingWrapper(childFieldValues, false, null));
				}
			}

			return new ApplicationViewWrapper(OWNERSHIP_INFORMATION, fieldHeadingWrapperList, false, null);
		} catch (Exception e) {
			LPI_ExceptionManager.logException(CLASS_NAME, 'getOwnerInformation', e);
			throw new AuraHandledException(e.getMessage());
		}
	}
	/**
	 * @author                      : MTX Group Inc
	 * @since                       :
	 * @description                 : fetch getExaminationInformation
	 * @return                      : ApplicationViewWrapper
	 * @last modified by            : Uzma Md
	 * @last modified date          :
	 * @modified details            :
	 */
	public static ApplicationViewWrapper getExaminationInformation(BusinessLicense blRecord) {
		try {
			List<FieldHeadingWrapper> fieldHeadingWrapperList = new List<FieldHeadingWrapper>();
			List<FieldValueWrapper> fieldValueList = new List<FieldValueWrapper>();
			
			fieldHeadingWrapperList.add(new FieldHeadingWrapper(fieldValueList, false, null));
			return new ApplicationViewWrapper(EXAMINATION_INFORMATION, fieldHeadingWrapperList, false, null);
		} catch (Exception e) {
			LPI_ExceptionManager.logException(CLASS_NAME, 'getExaminationInformation', e);
			throw new AuraHandledException(e.getMessage());
		}
	}
	/**
	 * @author                      : MTX Group Inc
	 * @since                       :
	 * @description                 : fetch getIndividualBusinessInformation
	 * @return                      : ApplicationViewWrapper
	 * @last modified by            : Uzma Md
	 * @last modified date          :
	 * @modified details            :
	 */
	public static ApplicationViewWrapper getIndividualBusinessInformation(List<Schema.Location> locationList) {
		try {
			List<FieldHeadingWrapper> fieldHeadingWrapperList = new List<FieldHeadingWrapper>();
			for (Schema.Location location : locationList) {
				List<FieldValueWrapper> fieldValues = new List<FieldValueWrapper>();
				fieldValues.add(new FieldValueWrapper('Business Name', location.Name));
				fieldValues.add(new FieldValueWrapper('Fictitious Name', location.Fictitious_Name__c));
				fieldValues.add(new FieldValueWrapper('Business Phone', location.Business_Phone__c));
				fieldValues.add(new FieldValueWrapper('Website', location.Business_Website__c));
				fieldValues.add(new FieldValueWrapper('Email', location.Firm_Email__c));
				List<HeadingFieldValueWrapper> headingFieldValueList = new List<HeadingFieldValueWrapper>();
				for (Schema.Address address : location.Addresses) {
					headingFieldValueList.add(
						new HeadingFieldValueWrapper(
							LPI_LiteralConstant.LOCATION_TYPE_BUSINESS_ADDRESS,
							getAddressFieldValueMap(address)
						)
					);
				}
				fieldHeadingWrapperList.add(new FieldHeadingWrapper(fieldValues, true, headingFieldValueList));
			}
			return new ApplicationViewWrapper(INDIVIDUAL_BUSINESS_INFORMATION, fieldHeadingWrapperList, false, null);
		} catch (Exception e) {
			LPI_ExceptionManager.logException(CLASS_NAME, 'getIndividualBusinessInformation', e);
			throw new AuraHandledException(e.getMessage());
		}
	}
	/**
	 * @author                      : MTX Group Inc
	 * @since                       :
	 * @description                 : fetch getPersonalInformation
	 * @return                      : ApplicationViewWrapper
	 * @last modified by            : Uzma Md
	 * @last modified date          : 24 july, 2023
	 * @modified details            : Added New fields
	 */
	public static ApplicationViewWrapper getPersonalInformation(
		BusinessLicense blRecord,
		Map<String, List<Schema.Location>> locationMap
	) {
		try {
			List<FieldHeadingWrapper> fieldHeadingWrapperList;
			List<FieldHeadingWrapper> parentFieldHeadingWrapperList;
			if (blRecord.ContactId != null) {
				parentFieldHeadingWrapperList = new List<FieldHeadingWrapper>();
				List<FieldValueWrapper> fieldValues = new List<FieldValueWrapper>();
				fieldValues.add(
					new FieldValueWrapper(
						'First Name',
						blRecord.First_Name__c != null ? blRecord.First_Name__c : blRecord.contact.Account.FirstName,
						true,
						blRecord.contact.AccountId
					)
				);
				fieldValues.add(
					new FieldValueWrapper(
						'Middle Name',
						blRecord.Middle_Name__c != null ? blRecord.Middle_Name__c : blRecord.contact.Account.MiddleName
					)
				);
				fieldValues.add(
					new FieldValueWrapper(
						'Last Name',
						blRecord.Last_Name__c != null ? blRecord.Last_Name__c : blRecord.contact.Account.LastName
					)
				);
				fieldValues.add(new FieldValueWrapper('Suffix', blRecord.contact.Account.Suffix));
				fieldValues.add(
					new FieldValueWrapper(
						'Maiden Name',
						blRecord.Maiden_Name__c != null
							? blRecord.Maiden_Name__c
							: blRecord.contact.Account.Maiden_Name__c
					)
				);
				fieldValues.add(new FieldValueWrapper('Email', blRecord.contact.Account.PersonEmail));
				fieldValues.add(
					new FieldValueWrapper(
						'Social Security Number',
						LPI_ServiceUtility.getMaskedData(blRecord.contact.Account.Social_Security_Number__c)
					)
				);
				fieldValues.add(
					new FieldValueWrapper(
						'Date Of Birth',
						convertDateFormat(String.valueOf(blRecord.contact.Account.Date_of_Birth__c?.format()))
					)
				);
				fieldValues.add(new FieldValueWrapper('Age', String.valueOf(blRecord.contact.Account.Age__c)));
				fieldValues.add(new FieldValueWrapper('Gender', blRecord.contact.Account.Gender__c));
				fieldValues.add(new FieldValueWrapper('Place Of Birth', blRecord.contact.Account.Place_of_Birth__c));
				fieldValues.add(new FieldValueWrapper('Telephone Number', blRecord.contact.Account.PersonHomePhone));
				fieldValues.add(new FieldValueWrapper('Cell phone Number', blRecord.contact.Account.Phone));
				fieldValues.add(new FieldValueWrapper('Fax Number', blRecord.contact.Account.Fax));
				fieldValues.add(new FieldValueWrapper('Race', blRecord.contact.Account.Race__c));
				fieldValues.add(new FieldValueWrapper('Language', blRecord.contact.Account.Language__c));
				fieldValues.add(new FieldValueWrapper('Citizenship', blRecord.contact.Account.Citizenship__c));
				if (blRecord.Account.Citizenship__c == UNITED_STATES) {
					fieldValues.add(
						new FieldValueWrapper('Proof of Citizenship', blRecord.Account.Proof_of_Citizenship__c)
					);
					if (blRecord.Account.Proof_of_Citizenship__c == NATURALIZATION) {
						fieldValues.add(new FieldValueWrapper('USCIS Number', blRecord.Account.USCIS_Number__c));
						fieldValues.add(
							new FieldValueWrapper('Naturalization Number', blRecord.Account.Naturalization_Number__c)
						);
						fieldValues.add(
							new FieldValueWrapper('Citizenship Number', blRecord.Account.Citizenship_Number__c)
						);
					}
				}
				if (
					blRecord.Account.Citizenship__c == FOREIGN &&
					locationMap.containsKey(LPI_LiteralConstant.LOCATION_TYPE_RESIDENCE) &&
					!locationMap.get(LPI_LiteralConstant.LOCATION_TYPE_RESIDENCE).isEmpty() &&
					!locationMap.get(LPI_LiteralConstant.LOCATION_TYPE_RESIDENCE)[0].Addresses.isEmpty() &&
					locationMap.get(LPI_LiteralConstant.LOCATION_TYPE_RESIDENCE)[0]?.Addresses[0]?.Country == UNITED_STATES
				) {
					fieldValues.add(
						new FieldValueWrapper(
							'Evidence of Lawful Presence',
							blRecord.Account.Proof_of_work_permit_in_United_States__c
						)
					);
					if (VISA_PERMIT_SET.contains(blRecord.Account.Proof_of_work_permit_in_United_States__c)) {
						if (blRecord.Account.Proof_of_work_permit_in_United_States__c == VISA_PERMIT) {
							fieldValues.add(new FieldValueWrapper('VISA Number', blRecord.Account.VISA_Number__c));
						} else if (blRecord.Account.Proof_of_work_permit_in_United_States__c == HB_VISA) {
							fieldValues.add(
								new FieldValueWrapper('H1B VISA Number', blRecord.Account.H1B_Visa_Number__c)
							);
						}
						fieldValues.add(
							new FieldValueWrapper('Passport Country', blRecord.Account.Passport_Country__c)
						);
						fieldValues.add(new FieldValueWrapper('Passport Number', blRecord.Account.Passport_Number__c));
					} else if (blRecord.Account.Proof_of_work_permit_in_United_States__c == STUDENT_VISA) {
						fieldValues.add(
							new FieldValueWrapper('Passport Country', blRecord.Account.Passport_Country__c)
						);
						fieldValues.add(new FieldValueWrapper('Passport Number', blRecord.Account.Passport_Number__c));
						fieldValues.add(new FieldValueWrapper('SEVIS ID', blRecord.Account.SEVIS_ID__c));
						fieldValues.add(new FieldValueWrapper('I-94 Number', blRecord.Account.I_94_Number__c));
					} else if (US_RESIDENTS_SET.contains(blRecord.Account.Proof_of_work_permit_in_United_States__c)) {
						fieldValues.add(
							new FieldValueWrapper(
								'US Permanent Resident Card Number',
								blRecord.Account.US_Permanent_Resident_Card_Number__c
							)
						);
						fieldValues.add(new FieldValueWrapper('USCIS Number', blRecord.Account.USCIS_Number__c));
					}
				}
				parentFieldHeadingWrapperList.add(new FieldHeadingWrapper(fieldValues, false, null));
			}
			List<ApplicationViewWrapper> childSectionList = new List<ApplicationViewWrapper>();

			List<Alias__c> aliasList = getAliasList(blRecord);
			if (aliasList.size() > 0) {
				fieldHeadingWrapperList = new List<FieldHeadingWrapper>();
				for (Alias__c alias : aliasList) {
					List<FieldValueWrapper> fieldValues = new List<FieldValueWrapper>();
					fieldValues.add(new FieldValueWrapper('Alias Name', alias.name));
					fieldValues.add(new FieldValueWrapper('Alias Type', alias.Alias_Type__c));
					fieldValues.add(
						new FieldValueWrapper(
							'Alias From Date',
							convertDateFormat(String.valueOf(alias.Alias_From_Date__c?.format()))
						)
					);
					fieldValues.add(
						new FieldValueWrapper(
							'Alias Thru Date',
							convertDateFormat(String.valueOf(alias.Alias_Thru_Date__c?.format()))
						)
					);

					fieldHeadingWrapperList.add(new FieldHeadingWrapper(fieldValues, true, null));
				}
				childSectionList.add(new ApplicationViewWrapper(ALIAS_DETAIL, fieldHeadingWrapperList, false, null));
			}
			
			if (
				locationMap.containsKey(LPI_LiteralConstant.LOCATION_TYPE_RESIDENCE) &&
				!locationMap.get(LPI_LiteralConstant.LOCATION_TYPE_RESIDENCE).isEmpty() &&
				!locationMap.get(LPI_LiteralConstant.LOCATION_TYPE_RESIDENCE)[0].Addresses.isEmpty()
			) {
				fieldHeadingWrapperList = new List<FieldHeadingWrapper>();
				fieldHeadingWrapperList.add(
					new FieldHeadingWrapper(
						getAddressFieldValueMap(
							locationMap.get(LPI_LiteralConstant.LOCATION_TYPE_RESIDENCE)[0].Addresses[0]
						),
						false,
						null
					)
				);
				childSectionList.add(
					new ApplicationViewWrapper(RESIDENCE_ADDRESS, fieldHeadingWrapperList, false, null)
				);
			}
			
			if (
				locationMap.containsKey(LPI_LiteralConstant.LOCATION_TYPE_MAILING) &&
				!locationMap.get(LPI_LiteralConstant.LOCATION_TYPE_MAILING).isEmpty() &&
				!locationMap.get(LPI_LiteralConstant.LOCATION_TYPE_MAILING)[0].Addresses.isEmpty()
			) {
				fieldHeadingWrapperList = new List<FieldHeadingWrapper>();
				fieldHeadingWrapperList.add(
					new FieldHeadingWrapper(
						getAddressFieldValueMap(locationMap.get(LPI_LiteralConstant.LOCATION_TYPE_MAILING)[0].Addresses[0]),
						false,
						null
					)
				);
				childSectionList.add(new ApplicationViewWrapper(MAILING_ADDRESS, fieldHeadingWrapperList, false, null));
			}
			
			List<FieldValueWrapper> fieldValues;
			if (blRecord.Primary_Contact_Address__c != null) {
				fieldHeadingWrapperList = new List<FieldHeadingWrapper>();
				fieldValues = new List<FieldValueWrapper>();
				fieldValues.add(new FieldValueWrapper('Address Type', blRecord.Primary_Contact_Address__c));
				fieldHeadingWrapperList.add(new FieldHeadingWrapper(fieldValues, true, null));

				
				if (
					locationMap.containsKey('Business Address') ||
					locationMap.containsKey('Branch') ||
					locationMap.containsKey('Secondary Business Address') ||
					locationMap.containsKey('Local Address') ||
					locationMap.containsKey('Other')
				) {
					if (
						locationMap.containsKey(blRecord.Primary_Contact_Address__c) &&
						!locationMap.get(blRecord.Primary_Contact_Address__c).isEmpty() &&
						!locationMap.get(blRecord.Primary_Contact_Address__c)[0].Addresses.isEmpty()
					) {
						fieldHeadingWrapperList.add(
							new FieldHeadingWrapper(
								getAddressFieldValueMap(
									locationMap.get(blRecord.Primary_Contact_Address__c)[0].Addresses[0]
								),
								false,
								null
							)
						);
					}
				}
				childSectionList.add(
					new ApplicationViewWrapper(PRIMARY_CONTACT_ADDRESS, fieldHeadingWrapperList, false, null)
				);
			}
			
			if (blRecord.License_Address__c != null) {
				fieldHeadingWrapperList = new List<FieldHeadingWrapper>();
				fieldValues = new List<FieldValueWrapper>();
				fieldValues.add(new FieldValueWrapper('Address Type', blRecord.License_Address__c));
				fieldHeadingWrapperList.add(new FieldHeadingWrapper(fieldValues, true, null));

				
				if (
					locationMap.containsKey('Business Address') ||
					locationMap.containsKey('Branch') ||
					locationMap.containsKey('Secondary Business Address') ||
					locationMap.containsKey('Local Address') ||
					locationMap.containsKey('Other')
				) {
					if (
						locationMap.containsKey(blRecord.License_Address__c) &&
						!locationMap.get(blRecord.License_Address__c).isEmpty() &&
						!locationMap.get(blRecord.License_Address__c)[0].Addresses.isEmpty()
					) {
						fieldHeadingWrapperList.add(
							new FieldHeadingWrapper(
								getAddressFieldValueMap(locationMap.get(blRecord.License_Address__c)[0].Addresses[0]),
								false,
								null
							)
						);
					}
				}
				childSectionList.add(new ApplicationViewWrapper(LICENSE_ADDRESS, fieldHeadingWrapperList, false, null));
			}
			
			if (blRecord.Publicly_Displayed_Address__c != null) {
				fieldHeadingWrapperList = new List<FieldHeadingWrapper>();
				fieldValues = new List<FieldValueWrapper>();
				fieldValues.add(new FieldValueWrapper('Address Type', blRecord.Publicly_Displayed_Address__c));
				fieldHeadingWrapperList.add(new FieldHeadingWrapper(fieldValues, true, null));

				
				if (
					(locationMap.containsKey('Business Address') ||
					locationMap.containsKey('Branch') ||
					locationMap.containsKey('Secondary Business Address') ||
					locationMap.containsKey('Local Address') ||
					locationMap.containsKey('Other')) &&
					(blRecord.Publicly_Displayed_Address__c != blRecord.Primary_Contact_Address__c &&
					blRecord.Publicly_Displayed_Address__c != blRecord.License_Address__c)
				) {
					if (
						locationMap.containsKey(blRecord.Publicly_Displayed_Address__c) &&
						!locationMap.get(blRecord.Publicly_Displayed_Address__c).isEmpty() &&
						!locationMap.get(blRecord.Publicly_Displayed_Address__c)[0].Addresses.isEmpty()
					) {
						fieldHeadingWrapperList.add(
							new FieldHeadingWrapper(
								getAddressFieldValueMap(
									locationMap.get(blRecord.Publicly_Displayed_Address__c)[0].Addresses[0]
								),
								false,
								null
							)
						);
					}
				}
				childSectionList.add(
					new ApplicationViewWrapper(PUBLICLY_DISPLAYED_ADDRESS, fieldHeadingWrapperList, false, null)
				);
			}
			if (locationMap.containsKey(LOCATION_TYPE_BRANCH)) {
				Integer branchAddCount = 1;
				for (Schema.Location branchAddressLoc : locationMap.get(LOCATION_TYPE_BRANCH)) {
					if (!branchAddressLoc.Addresses.isEmpty()) {
						fieldHeadingWrapperList = new List<FieldHeadingWrapper>();
						fieldHeadingWrapperList.add(
							new FieldHeadingWrapper(getAddressFieldValueMap(branchAddressLoc.Addresses), false, null)
						);
						childSectionList.add(
							new ApplicationViewWrapper(
								'Branch Address ' + String.valueOf('0' + branchAddCount).right(2),
								fieldHeadingWrapperList,
								false,
								null
							)
						);
						branchAddCount = branchAddCount + 1;
					}
				}
			}
			return new ApplicationViewWrapper(
				PERSONAL_INFORMATION,
				parentFieldHeadingWrapperList,
				true,
				childSectionList
			);
		} catch (Exception e) {
			LPI_ExceptionManager.logException(CLASS_NAME, 'getPersonalInformation', e);
			throw new AuraHandledException(e.getMessage());
		}
	}
	/**
	 * @author                      : MTX Group Inc
	 * @since                       :
	 * @description                 : fetch getCurrentEmploymentInformation
	 * @return                      : ApplicationViewWrapper
	 * @last modified by            : Uzma Md
	 * @last modified date          : 18 December 2023
	 * @modified details            : 
	 */
	public static ApplicationViewWrapper getCurrentEmploymentInformation(BusinessLicense blRecord) {
		try {
			List<FieldHeadingWrapper> fieldHeadingWrapperList = new List<FieldHeadingWrapper>();
			List<String> accRoleList = new List<String>{
				LPI_LiteralConstant.ROLE_DESIGNATED_INCHARGE,
				LPI_LiteralConstant.ROLE_DESIGNATED_INCHARGE_AND_OWNER
			};
			List<FieldValueWrapper> fieldValues = new List<FieldValueWrapper>();
			List<HeadingFieldValueWrapper> headingFieldValueList = new List<HeadingFieldValueWrapper>();
			List<FieldValueWrapper> childFieldValues = new List<FieldValueWrapper>();
			if (blRecord.Are_you_Currently_Employeed__c == 'Yes') {
				String empFields = 'Id, Supervisor_Email__c, Immediate_Supervisor_s_Name__c, Current_License_Posted__c, Current_License_Posted_Year__c';
				String empWhereClause = 'Business_License__c = \'' + String.escapeSingleQuotes(blRecord.Id) + '\'';
				List<PersonEmployment> empList = (new LPI_PersonEmploymentDAO.LPI_EmploymentHistoryWithoutSharingDAO())
					.getEmploymentHistoryByDymanicQuery(empFields, empWhereClause, null, null, null);
				 
			} else {
				fieldHeadingWrapperList.add(new FieldHeadingWrapper(fieldValues, false, null));
			}

			return new ApplicationViewWrapper(
				CURRENT_EMPLOYMENT_INFORMATION ,
				fieldHeadingWrapperList,
				false,
				null
			);
		} catch (Exception e) {
			LPI_ExceptionManager.logException(CLASS_NAME, 'getCurrentEmploymentInformation', e);
			throw new AuraHandledException(e.getMessage());
		}
	}
	/**
	 * @author                      : MTX Group Inc
	 * @since                       :
	 * @description                 : fetch getEmploymentHistory
	 * @return                      : ApplicationViewWrapper
	 * @last modified by            : Uzma Md
	 * @last modified date          :
	 * @modified details            :
	 */
	public static ApplicationViewWrapper getEmploymentHistory(List<PersonEmployment> employmentList) {
		try {
			List<FieldHeadingWrapper> fieldHeadingWrapperList = new List<FieldHeadingWrapper>();
			for (PersonEmployment employment : employmentList) {
				List<FieldValueWrapper> fieldValues = new List<FieldValueWrapper>();
				fieldValues.add(new FieldValueWrapper('Name of the Employer', employment.Name));
				fieldValues.add(
					new FieldValueWrapper(
						'Start date',
						convertDateFormat(String.valueOf(employment.StartDate?.format()))
					)
				);
				fieldValues.add(
					new FieldValueWrapper(
						'End Date',
						convertDateFormat(String.valueOf(employment.EndDate?.format()))
					)
				);
				fieldValues.add(new FieldValueWrapper('City', employment.EmployerCity));
				fieldValues.add(new FieldValueWrapper('State', employment.EmployerState));
				fieldValues.add(new FieldValueWrapper('Job Title/Position', employment.Position));
				fieldValues.add(
					new FieldValueWrapper('Immediate Supervisors Name', employment.Immediate_Supervisor_s_Name__c)
				);
				fieldValues.add(
					new FieldValueWrapper('Supervisors Phone number', employment.Supervisor_s_Phone_number__c)
				);
				fieldHeadingWrapperList.add(new FieldHeadingWrapper(fieldValues, false, null));
			}
			return new ApplicationViewWrapper(EMPLOYMENT_HISTORY, fieldHeadingWrapperList, false, null);
		} catch (Exception e) {
			LPI_ExceptionManager.logException(CLASS_NAME, 'getCurrentEmploymentInformation', e);
			throw new AuraHandledException(e.getMessage());
		}
	}
	/**
	 * @author                      :MTX Group Inc
	 * @since                       :
	 * @description                 : fetch getMilitaryQuestions
	 * @return                      : ApplicationViewWrapper
	 * @last modified by            : Uzma Md
	 * @last modified date          :
	 * @modified details            :
	 */
	public static ApplicationViewWrapper getMilitaryQuestions(BusinessLicense blRecord) {
		try {
			List<FieldHeadingWrapper> fieldHeadingWrapperList = new List<FieldHeadingWrapper>();
			List<FieldValueWrapper> fieldValues = new List<FieldValueWrapper>();
			fieldValues.add(
				new FieldValueWrapper(
					'Have you or an immediate family member ever served in the U.S. Armed Forces?',
					blRecord.Info_About_Military_Related_Services__c
				)
			);
			if (blRecord.Info_About_Military_Related_Services__c == 'Yes') {
				fieldValues.add(
					new FieldValueWrapper(
						'Would you like information about military-related services in Missouri?',
						blRecord.Served_In_US_Armed_Force__c
					)
				);
			}
			fieldHeadingWrapperList.add(new FieldHeadingWrapper(fieldValues, false, null));
			return new ApplicationViewWrapper(MILITARY_QUESTIONS, fieldHeadingWrapperList, false, null);
		} catch (Exception e) {
			LPI_ExceptionManager.logException(CLASS_NAME, 'getMilitaryQuestions', e);
			throw new AuraHandledException(e.getMessage());
		}
	}
	/**
	 * @author                      : MTX Group Inc
	 * @since                       :
	 * @description                 : fetch getEducationHistory
	 * @return                      : ApplicationViewWrapper
	 * @last modified by            : Uzma Md
	 * @last modified date          :
	 * @modified details            :
	 */
	public static ApplicationViewWrapper getEducationHistory(Id contactId, boolean isPostEducation) {
		try {
			List<FieldHeadingWrapper> fieldHeadingWrapperList = new List<FieldHeadingWrapper>();
			List<PersonEducation> educationList = LPI_PersonEducationDAO.getPersonEducationByDymanicQuery(
				'Id,StartDate, City__c, Name, GraduationDate,IdentifierIssuer, CompletionDate,Website_Name__c,Location__c',
				' ContactId = ' +
					'\'' +
					String.escapeSingleQuotes(contactId) +
					'\'' +
					' AND Not_Education_History_Record__c = ' +
					isPostEducation,
				null,
				null,
				null
			);
			for (PersonEducation education : educationList) {
				if (isPostEducation) {
					List<FieldValueWrapper> fieldValues = new List<FieldValueWrapper>();
					fieldValues.add(new FieldValueWrapper('Name Of Program Website', education.Website_Name__c));
					fieldValues.add(
						new FieldValueWrapper(
							'Program Start Date',
							String.valueOf(education.StartDate?.format('MM/dd/yyyy'))
						)
					);
					fieldValues.add(
						new FieldValueWrapper(
							'Program End Date',
							String.valueOf(education.CompletionDate?.format('MM/dd/yyyy'))
						)
					);
					fieldValues.add(new FieldValueWrapper('Program Name', education.Name));
					fieldHeadingWrapperList.add(new FieldHeadingWrapper(fieldValues, false, null));
				} else {
					List<FieldValueWrapper> fieldValues = new List<FieldValueWrapper>();
					fieldValues.add(new FieldValueWrapper('Name of the School', education.IdentifierIssuer));
					fieldValues.add(new FieldValueWrapper('City', education.City__c));
					fieldValues.add(
						new FieldValueWrapper('Start Date', String.valueOf(education.StartDate?.format('MM/dd/yyyy')))
					);
					fieldValues.add(
						new FieldValueWrapper(
							'End Date',
							String.valueOf(education.CompletionDate?.format('MM/dd/yyyy'))
						)
					);
					fieldValues.add(new FieldValueWrapper('Degree', education.Name));
					fieldValues.add(new FieldValueWrapper('Graduation Date', String.valueOf(education.GraduationDate)));
					fieldHeadingWrapperList.add(new FieldHeadingWrapper(fieldValues, false, null));
				}
			}
			if (isPostEducation) {
				return new ApplicationViewWrapper(POST_GRADUATION_INFORMATION, fieldHeadingWrapperList, false, null);
			}
			return new ApplicationViewWrapper(EDUCATION_HISTORY, fieldHeadingWrapperList, false, null);
		} catch (Exception e) {
			LPI_ExceptionManager.logException(CLASS_NAME, 'getEducationHistory', e);
			throw new AuraHandledException(e.getMessage());
		}
	}
	/**
	 * @author                      : MTX Group Inc
	 * @since                       :
	 * @description                 : fetch getLocationMap
	 * @return                      : Map<String,List<Schema.Location>>
	 * @last modified by            : Uzma Md
	 * @last modified date          :
	 * @modified details            :
	 */
	public static Map<String, List<Schema.Location>> getLocationMap(List<String> locationIdList) {
		try {
			Map<String, List<Schema.Location>> locationTypeToLocationMap = new Map<String, List<Schema.Location>>();
			String fieldsToQuery =
				'ID, Name,LocationType, Fictitious_Name__c, Business_Phone__c,Firm_Email__c,Business_Website__c,' +
				'(SELECT Id, city,country,postalCode,state,street, LocationType ,CountryCode,County__c,Business_State__c, Parent.Business_Phone__c FROM Addresses)';
			String whereClause =
				'Id IN ' +
				LPI_ServiceUtility.getStringValuesByList(locationIdList) +
				' AND Status__c = ' +
				'\'' +
				String.escapeSingleQuotes(LPI_LiteralConstant.LOCATION_STATUS_OPEN) +
				'\'';
			for (
				Schema.Location loctionList : LPI_LocationDAO.getLocationByDymanicQuery(
					fieldsToQuery,
					whereClause,
					null,
					null,
					null
				)
			) {
				if (!locationTypeToLocationMap.containsKey(loctionList.LocationType)) {
					locationTypeToLocationMap.put(loctionList.LocationType, new List<Schema.Location>());
				}
				locationTypeToLocationMap.get(loctionList.LocationType).add(loctionList);
			}
			return locationTypeToLocationMap;
		} catch (Exception e) {
			LPI_ExceptionManager.logException(CLASS_NAME, 'getLocationMap', e);
			throw new AuraHandledException(e.getMessage());
		}
	}
	/**
	 * @author                      :MTX Group Inc
	 * @since                       :
	 * @description                 : fetch getAddressFieldValueMap
	 * @return                      : List<FieldValueWrapper>
	 * @last modified by            : Uzma Md
	 * @last modified date          : 5 july 2023
	 * @modified details            : removed addressFieldValues.add(new FieldValueWrapper('County', address.County__c))
	 */
	public static List<FieldValueWrapper> getAddressFieldValueMap(Schema.Address address) {
		try {
			List<FieldValueWrapper> addressFieldValues = new List<FieldValueWrapper>();
			addressFieldValues.add(new FieldValueWrapper('Street Address', address.street));
			addressFieldValues.add(new FieldValueWrapper('City', address.city));
			if (address.CountryCode == 'US') {
				addressFieldValues.add(new FieldValueWrapper('State', address.State));
			} else {
				addressFieldValues.add(new FieldValueWrapper('State', address.Business_State__c));
			}

			addressFieldValues.add(new FieldValueWrapper('Zip Code', address.postalCode));
			addressFieldValues.add(new FieldValueWrapper('Country', address.Country));
			if (address.LocationType == LOCATION_TYPE_BRANCH) {
				addressFieldValues.add(new FieldValueWrapper('County', address.County__c));
				addressFieldValues.add(new FieldValueWrapper('Telephone Number', address.Parent.Business_Phone__c));
			}
			return addressFieldValues;
		} catch (Exception e) {
			LPI_ExceptionManager.logException(CLASS_NAME, 'getAddressFieldValueMap', e);
			throw new AuraHandledException(e.getMessage());
		}
	}
	

	/**
	 * @description : To get the list of actions that we can show on the BL page
	 * @author MTX Group Inc | 01-06-2023
	 * @param regAuthId
	 * @param blStatus
	 * @return Map<String, Boolean>
	 **/
	public static Map<String, Boolean> getIsActionAllowedMap(String regAuthId, String blStatus, Boolean isCRRActions) {
		try {
			Map<String, Boolean> isActionAllowedMap = new Map<String, Boolean>();
			LPI_UserDao.LPI_UserWithoutSharingDAO userWithoutSharingSelector = new LPI_UserDao.LPI_UserWithoutSharingDAO();
			List<User> usrList = userWithoutSharingSelector.getUserByDymanicQuery(
				'Id, Name, Profile.Name',
				'Id = \'' + UserInfo.getUserId() + '\'',
				null,
				null,
				null
			);
			String profileName = !usrList.isEmpty() ? usrList[0].Profile.Name : '';

			for (
				Application_Flow_Config__c appFlowConfig : LPI_ApplicationFlowConfigDAO.getApplicationFlowConfigByRat(
					new Set<Id>{ regAuthId }
				)
			) {
				String key = (appFlowConfig.Application_Type__c == appFlowConfig.Application_Subtype__c)
					? appFlowConfig.Application_Type__c
					: appFlowConfig.Application_Type__c + appFlowConfig.Application_Subtype__c;
				if (
					(isCRRActions && profileName == PROFILE_SUPPORT_STAFF) ||
					(appFlowConfig.Eligible_License_Status__c != null &&
					appFlowConfig.Eligible_License_Status__c.contains(blStatus))
				) {
					isActionAllowedMap.put(key, true);
				} else {
					isActionAllowedMap.put(key, false);
				}
			}
			System.debug('====>'+isActionAllowedMap);
			return isActionAllowedMap;
		} catch (Exception e) {
			LPI_ExceptionManager.logException(CLASS_NAME, 'getIsActionAllowedMap', e);
			throw new AuraHandledException(e.getMessage());
		}
	}

	/**
	 * @author                      : MTX Group Inc
	 * @since                       : 15th Feb 2023
	 * @description                 : fetch faculty information for business License incase of Nursing Schools and show on portal on License detail page
	 * @param blRecord              : Business License record
	 * @return                      : ApplicationViewWrapper
	 * @last modified by            : Uzma Md
	 * @last modified date          :
	 * @modified details            :
	 */
	public static ApplicationViewWrapper getFacultyInformation(BusinessLicense blRecord) {
		try {
			Map<Id, Business_Relationships__c> personAccountIdToACR = new Map<Id, Business_Relationships__c>();
			Map<Id, List<PersonEmployment>> personAccountIdToEmploymentHistoryMap = new Map<Id, List<PersonEmployment>>();
			List<FieldHeadingWrapper> fieldHeadingWrapperList = new List<FieldHeadingWrapper>();
			LPI_BusinessRelationshipDAO.LPI_BusinessRelationshipsWithoutSharingDAO daoInnerObj = new LPI_BusinessRelationshipDAO.LPI_BusinessRelationshipsWithoutSharingDAO();
			List<Business_Relationships__c> listOfACR = daoInnerObj.getBusinessRelationshipsByDymanicQuery(
				'Id, Related_To__c, Related_To__r.FirstName, Related_To__r.LastName, Related_To__r.MiddleName, Related_To__r.Date_of_Birth__c, License_Number__c ',
				' Related_From__c = ' +
					'\'' +
					String.escapeSingleQuotes(blRecord.AccountId) +
					'\'' +
					' AND Roles__c = ' +
					'\'' +
					String.escapeSingleQuotes(LPI_LiteralConstant.ROLE_EMPLOYEE) +
					'\'' +
					'AND IsActive__c = true AND EndDate__c = null ',
				null,
				null,
				null
			);
			if (!listOfACR.isEmpty()) {
				for (Business_Relationships__c acr : listOfACR) {
					personAccountIdToACR.put(acr.Related_To__c, acr);
				}
				
				LPI_PersonEmploymentDAO.LPI_EmploymentHistoryWithoutSharingDAO empInnerObj = new LPI_PersonEmploymentDAO.LPI_EmploymentHistoryWithoutSharingDAO();
				List<PersonEmployment> listOfEmployementHistory = empInnerObj.getEmploymentHistoryByDymanicQuery(
					'Id, RelatedPersonId, Position, StartDate , Type_of_Employment__c, Name_of_Courses_Teaching__c, Nursing_license_ever_been_disciplined__c, Employer_License_Number__c',
					'RelatedPersonId IN ' +
					LPI_ServiceUtility.getStringValuesBySet(personAccountIdToACR.keySet()) +
						' AND Employer_License_Number__c = ' +
						'\'' +
						String.escapeSingleQuotes(blRecord.Name) +
						'\'',
					null,
					null,
					null
				);
				
				for (PersonEmployment empHis : listOfEmployementHistory) {
					if (personAccountIdToEmploymentHistoryMap.containsKey(empHis.RelatedPersonId)) {
						personAccountIdToEmploymentHistoryMap.get(empHis.RelatedPersonId).add(empHis);
					} else {
						personAccountIdToEmploymentHistoryMap.put(
							empHis.RelatedPersonId,
							new List<PersonEmployment>{ empHis }
						);
					}
				}
				
				for (Id personAccountId : personAccountIdToEmploymentHistoryMap.keySet()) {
					if (!personAccountIdToEmploymentHistoryMap.get(personAccountId).isEmpty()) {
						List<FieldValueWrapper> fieldValues = new List<FieldValueWrapper>();
						Business_Relationships__c acr = personAccountIdToACR.get(personAccountId);
						fieldValues.add(new FieldValueWrapper('License Number', acr.License_Number__c));
						fieldValues.add(new FieldValueWrapper('First Name', acr.Related_To__r.FirstName));
						fieldValues.add(new FieldValueWrapper('Middle Name', acr.Related_To__r.MiddleName));
						fieldValues.add(new FieldValueWrapper('Last Name', acr.Related_To__r.LastName));
						fieldValues.add(
							new FieldValueWrapper(
								'Date of Birth',
								convertDateFormat(String.valueOf(acr.Related_To__r.Date_of_Birth__c?.format()))
							)
						);
						fieldValues.add(new FieldValueWrapper('License Type', 'Registered Nurse'));
						PersonEmployment empHis = personAccountIdToEmploymentHistoryMap.get(personAccountId)[0];
						fieldValues.add(new FieldValueWrapper('Title of Position', empHis.Position));
						fieldValues.add(
							new FieldValueWrapper(
								'Date of Employment',
								convertDateFormat(String.valueOf(empHis.StartDate?.format()))
							)
						);
						fieldValues.add(new FieldValueWrapper('Type of Employment', empHis.Type_of_Employment__c));
						fieldValues.add(
							new FieldValueWrapper('Name of Courses Teaching', empHis.Name_of_Courses_Teaching__c)
						);
						fieldValues.add(
							new FieldValueWrapper(
								'Is or has Nursing license ever been disciplined?',
								empHis.Nursing_license_ever_been_disciplined__c
							)
						);
						fieldHeadingWrapperList.add(new FieldHeadingWrapper(fieldValues, false, null));
					}
				}
			}
			return new ApplicationViewWrapper(FACULTY_INFORMATION, fieldHeadingWrapperList, false, null);
		} catch (Exception e) {
			LPI_ExceptionManager.logException(CLASS_NAME, 'getFacultyInformation', e);
			throw new AuraHandledException(e.getMessage());
		}
	}
	/**
	 * @author                      : MTX Group Inc
	 * @since                       : 24 Mar 2023
	 * @description                 : This method will return the success flag for enotify requirement
	 * @param blId                  : String
	 * @return                      : `Map<String, Object>`
	 * @last modified by            : Uzma Md
	 * @last modified date          : 27th July,  2023
	 * @modified details            : Development Changes - Ability to update e-notify messages
	 */
	@AuraEnabled
	public static Map<String, Object> validateLicenseFromENotifyService(String blId) {
		Map<String, Object> mapResponse = new Map<String, Object>();
		try {
			String blQueryFields = 'Id, Name, Account.PersonEmail, RegulatoryAuthorizationType.Name, PeriodEnd, Status, Legacy_License_Number__c';
			String blWhereClauseFields = 'Id = \'' + String.escapeSingleQuotes(blId) + '\'';
			List<BusinessLicense> blList = LPI_BusinessLicenseDAO.fetchBusinessLicenseRecordsWithOrderByLimit(
				blQueryFields,
				blWhereClauseFields,
				null,
				null
			);
			mapResponse.put('isValidated', false);
		} catch (Exception e) {
			LPI_ExceptionManager.logException(CLASS_NAME, GET_ENOTIFY_SUCCESS_FLAG, e);
			throw new AuraHandledException(e.getMessage());
		}
		return mapResponse;
	}
	/**
	 * @author                      : MTX Group Inc
	 * @since                       :
	 * @description                 : get date format in MM/dd/YYYY
	 * @last modified by            : Uzma Md
	 * @last modified date          :
	 * @modified details            :
	 */
	public static string convertDateFormat(String dateValue) {
		String resDate;
		if (String.isNotBlank(dateValue)) {
			List<String> res = dateValue.split('/', 3);
			if (!res.isEmpty() && res[0].length() == 1) {
				res[0] = '0' + res[0];
			}
			if (!res.isEmpty() && res[1].length() == 1) {
				res[1] = '0' + res[1];
			}
			resDate = res[0] + '/' + res[1] + '/' + res[2];
		}
		return resDate;
	}

	/**
	 * @author                      : MTX Group Inc
	 * @since                       : 21 June, 2023
	 * @description                 : Return the list of ButtonWrapper for PDF actions
	 * @last modified by            : Uzma Md
	 * @last modified date          :
	 * @modified details            :
	 */
	private static List<ButtonWrapper> getPDFActionButton(
		BusinessLicense blRecord,
		Boolean isRenewalEligible,
		Boolean isReinstatementEligible
	) {
		List<ButtonWrapper> buttonList = new List<ButtonWrapper>();
		Map<String, Object> dataMap = new Map<String, Object>();
		dataMap.put('isRenewalEligible', isRenewalEligible);
		dataMap.put('isReinstatementEligible', isReinstatementEligible);
		for (
			LPI_Document_Action_Config__mdt docActionConfig : LPI_ServiceUtility.getDocActionConfig(
				blRecord.RegulatoryAuthorizationType.IssuingDepartment.Name,
				blRecord.RegulatoryAuthorizationType.name,
				blRecord.Status,
				LICENSE_DETAIL_PAGE,
				dataMap
			)
		) {
			Map<String, String> pdfActionButtonData = new Map<String, String>();
			pdfActionButtonData.put(TEMPLATE_NAME, docActionConfig.Template_Name__c);
			pdfActionButtonData.put(ADOBE_PDF_MTD_NAME, docActionConfig.DeveloperName);
			pdfActionButtonData.put(
				'isSalesforceConfigured',
				String.valueOf(docActionConfig.Configured_In_Salesforce_Only__c)
			);
			buttonList.add(
				new ButtonWrapper(
					docActionConfig.Button_Label__c,
					TYPE_ADOBE_PDF,
					JSON.serialize(pdfActionButtonData),
					false,
					null
				)
			);
		}
		return buttonList;
	}

	/**
	 * @author                      : MTX Group Inc
	 * @since                       : 21 June, 2023
	 * @param recordId				: String (This can be either a BLId/parId)
	 * @param mdtName		 	    : String (Template Name Confiured in the metadata for action that user has clicked)
	 * @description                 : return the URL of Adobe document
	 * @last modified by            : Uzma Md
	 * @last modified date          :
	 * @modified details            :
	 */
	 @AuraEnabled
	public static string getAdobeDocumentLink(String recordId, String mdtName, String buttonLabel) {
		return 'null';
	}

	/**
	 * @author                      : MTX Group Inc
	 * @since                       : 8 Jul 2023
	 * @description                 : This method returns the student individual App list for the school Licenses
	 * @last modified by            : Uzma Md
	 * @last modified date          :
	 * @modified details            :
	 */
	@AuraEnabled(cacheable=true)
	public static List<IndividualApplication> getSchoolRelatedStudentApplications(String blId, String blNumber) {
		List<IndividualApplication> schoolRelatedStudentIaList = new List<IndividualApplication>();
		try {
			
			List<BusinessLicense> blRecordList = LPI_BusinessLicenseDAO.fetchBusinessLicenseRecords(
				'Id, AccountId',
				String.isEmpty(blId)
					? 'Name = ' + '\'' + String.escapeSingleQuotes(blNumber) + '\''
					: 'Id = ' + '\'' + String.escapeSingleQuotes(blId) + '\''
			);
			Set<String> relAccIdsSet = new Set<String>();
			Map<String, String> brIdToRelLicenseFromIdMap = new Map<String, String>();
			
			if (!blRecordList.isEmpty()) {
				
				for (
					Business_Relationships__c br : new LPI_BusinessRelationshipDAO.LPI_BusinessRelationshipsWithoutSharingDAO()
						.getBusinessRelationshipsByDymanicQuery(
							'Roles__c, Related_To__c, Related_From_License_Number__c',
							'Related_From__c = \'' +
								blRecordList[0].AccountId +
								'\'' +
								' AND Roles__c = \'' +
								'Student' +
								'\'' +
								' AND Related_From_License_Number__c = \'' +
								blRecordList[0].Id +
								'\'',
							null,
							null,
							null
						)
				) {
					
					brIdToRelLicenseFromIdMap.put(br.Id, br.Related_From_License_Number__c);
					relAccIdsSet.add(br.Related_To__c);
				}
			}
		} catch (Exception e) {
			LPI_ExceptionManager.logException(CLASS_NAME, 'getSchoolRelatedStudentApplications', e);
		}
		return schoolRelatedStudentIaList;
	}

	/**
	 * @author                      : MTX Group Inc
	 * @since                       : 31 July, 2023
	 * @param applicationId			: String (This can be either a BLA/IA Id)
	 * @description                 : return true or false based on the RegulatoryTrxnFee is paid or not
	 * @last modified by            : Uzma Md
	 * @last modified date          :
	 * @modified details            :
	 */
	@AuraEnabled
	public static boolean allowResume(String applicationId) {
		try {
			String fieldsToQuerry = 'Id,Status__c,Fee_Against_Bad_Check__c';
			String whereClause =
				'ParentRecordId = \'' +
				String.escapeSingleQuotes(applicationId) +
				'\' AND Status__c != \'' +
				PAID_STATUS +
				'\'';
			List<RegulatoryTrxnFee> regTrxnFeeList = LPI_RegulatoryTrxnFeeDAO.getRegulatoryTrxnFeeByDymanicQuery(
				fieldsToQuerry,
				whereClause,
				null,
				null,
				null
			);
			if (regTrxnFeeList.isEmpty()) {
				return true;
			}
			for (RegulatoryTrxnFee rtf : regTrxnFeeList) {
				if (
					(rtf.Status__c == BAD_CHECK_STATUS && rtf.Fee_Against_Bad_Check__c == null) ||
					rtf.Status__c != BAD_CHECK_STATUS
				) {
					return false;
				}
			}
			return true;
		} catch (Exception e) {
			LPI_ExceptionManager.logException(CLASS_NAME, 'allowResume', e);
			throw new AuraHandledException(e.getMessage());
		}
	}
	@AuraEnabled(cacheable=true)
	public static List<BranchDataWrapper> getBranchAddressDetails(String blId) {
		List<BranchDataWrapper> branchDataWrapperList = new List<BranchDataWrapper>();
		try {
			Set<Id> locationIdsSet = new Set<Id>();
			String addressFields =
				'Id,StateCode,Street,ParentId,City,State,PostalCode,country,CountryCode,' +
				'Business_State__c,County__c,Parent.Business_Phone__c, Parent.CloseDate, Parent.Status__c';
			if (String.isNotBlank(blId)) {
				for (
					AuthApplicationPlace authAppRec : LPI_AuthApplicationPlaceDAO.getAuthApplicationPlaceByDymanicQuery(
						'PlaceId, AuthorizationId',
						'AuthorizationId = \'' + String.escapeSingleQuotes(blId) + '\'',
						null,
						null,
						null
					)
				) {
					locationIdsSet.add(authAppRec.PlaceId);
				}
				if (!locationIdsSet.isEmpty()) {
					for (
						Schema.Address addressRec : LPI_AddressDAO.getAddressByDymanicQuery(
							addressFields,
							' LocationType =\'' +
								LOCATION_TYPE_BRANCH +
								'\'' +
								' AND ParentId IN ' +
								LPI_ServiceUtility.getStringValuesBySet(locationIdsSet),
							null,
							null,
							null
						)
					) {
						if (
							addressRec.Parent.CloseDate == null &&
							addressRec.Parent.Status__c == LPI_LiteralConstant.LOCATION_STATUS_OPEN
						) {
							BranchDataWrapper brnchWrapRec = new BranchDataWrapper(addressRec);
							branchDataWrapperList.add(brnchWrapRec);
						}
					}
				}
			}
		} catch (Exception e) {
			LPI_ExceptionManager.logException(CLASS_NAME, 'getBranchAddressDetails', e);
		}
		return branchDataWrapperList;
	}
	@AuraEnabled
	public static Boolean saveBranchAddressDetails(
		String blId,
		String accId,
		String branchDataObj,
		String locationType
	) {
		try {
			if (String.isBlank(blId) && String.isBlank(accId)) {
				return null;
			}
			

			List<SObject> listToInsert = new List<SObject>();
			Boolean isPersonAccount = false;
			String applicationFields = 'Id, Account.Name, Account.IsPersonAccount, LicensePermitName.Business_Entity_Name__c';
			String applicationWhereClause =
				'LicensePermitNameId =\'' +
				blId +
				'\'' +
				' AND ApplicationType = \'' +
				'New' +
				'\'';
			List<IndividualApplication> blRelIARecList = LPI_IndividualApplicationDAO.getIndividualApplicationByDymanicQuery(
				applicationFields,
				applicationWhereClause,
				'1',
				null,
				null
			);
			List<BusinessLicenseApplication> blRelBLARecList = LPI_BusinessLicenseApplicationDAO.getBusinessLicenseApplicationByDymanicQuery(
				applicationFields,
				applicationWhereClause,
				'1',
				null,
				null
			);
			if (!blRelIARecList.isEmpty() || !blRelBLARecList.isEmpty()) {
				BranchDataWrapper branchWrapRecord = (BranchDataWrapper) JSON.deserializeStrict(
					branchDataObj,
					BranchDataWrapper.class
				);
				if (ALLOW_CLOSE_LOCATION_TYPE_SET.contains(locationType)) {
					String locationIdsString = JSON.serialize(getAllLocationIdsRelatedToBL(blId, locationType, null));
					if (String.isNotBlank(locationIdsString)) {
						removeExistingAddress(locationIdsString);
					}
				}
				
				Schema.Location branchLoc = new Schema.Location();
				if (!blRelIARecList.isEmpty()) {
					branchLoc.Name = blRelIARecList[0].LicensePermitName.Business_Entity_Name__c + ' - ' + locationType;
					isPersonAccount = true;
				} else {
					if (!blRelBLARecList.isEmpty()) {
						branchLoc.Name =
							blRelBLARecList[0].LicensePermitName.Business_Entity_Name__c +
							' - ' +
							locationType;
					}
				}
				branchLoc.LocationType = locationType;
				branchLoc.Business_Phone__c = branchWrapRecord.telephoneNum;
				branchLoc.Status__c = LPI_LiteralConstant.LOCATION_STATUS_OPEN;
				branchLoc.OpenDate = System.today();
				String branchLocId = LPI_DML.doInsert(branchLoc)?.Id;
				
				if (String.isNotBlank(branchLocId)) {
					
					Schema.Address branchAddressRec = new Schema.Address();
					branchAddressRec.ParentId = branchLocId;
					branchAddressRec.LocationType = locationType;
					branchAddressRec.Street = branchWrapRecord.streetAddress;
					branchAddressRec.CountryCode = branchWrapRecord.country;
					if (branchWrapRecord.country == 'US') {
						branchAddressRec.StateCode = branchWrapRecord.state;
					} else {
						branchAddressRec.Business_State__c = branchWrapRecord.stateText;
					}
					if (branchWrapRecord.state == 'MO') {
						branchAddressRec.County__c = branchWrapRecord.countyLookup;
					} else {
						branchAddressRec.County__c = branchWrapRecord.county;
					}
					branchAddressRec.postalCode = branchWrapRecord.zipCode;

					branchAddressRec.City = branchWrapRecord.city;
					listToInsert.add(branchAddressRec);
					
					AuthApplicationPlace aap = new AuthApplicationPlace(placeId = branchLocId, AuthorizationId = blId);
					if (!blRelIARecList.isEmpty()) {
						aap.RgltyAuthApplicationId = blRelIARecList[0].Id;
					} else {
						aap.RgltyAuthApplicationId = blRelBLARecList[0].Id;
					}
					
					AssociatedLocation ascLoc = new AssociatedLocation(
						ParentRecordId = accId,
						LocationId = branchLocId
					);

					listToInsert.add(aap);
					listToInsert.add(ascLoc);

					if (!listToInsert.isEmpty()) {
						LPI_DML.doInsert(listToInsert);
					}
					if (
						((locationType == RESIDENCE || locationType == BUSINESS_ADDRESS) &&
						(branchWrapRecord.isAddressUpdateOnAccount))
					) {
						updateAddressOnAccount(accId, branchAddressRec, isPersonAccount, branchWrapRecord.telephoneNum);
					}
				}
			}
		} catch (Exception e) {
			LPI_ExceptionManager.logException(CLASS_NAME, 'saveBranchAddressDetails', e);
			throw new AuraHandledException(e.getMessage());
		}
		return true;
	}
	@AuraEnabled
	public static Boolean removeExistingAddress(String branchAddressList) {
		try {
			List<SObject> locListToUpdate = new List<SObject>();
			Set<String> locIdsList = (Set<String>) JSON.deserializeStrict(branchAddressList, Set<String>.class);
			for (String locId : locIdsList) {
				Schema.Location locToRemove = new Schema.Location(
					Id = locId,
					Status__c = LPI_LiteralConstant.LOCATION_STATUS_CLOSED,
					CloseDate = System.today()
				);
				locListToUpdate.add(locToRemove);
			}
			if (!locListToUpdate.isEmpty()) {
				LPI_DML.doUpdate(locListToUpdate);
			}
		} catch (Exception e) {
			LPI_ExceptionManager.logException(CLASS_NAME, 'removeExistingAddress', e);
			throw new AuraHandledException(e.getMessage());
		}
		return true;
	}
	@AuraEnabled
	public static List<countyPicklistWrapper> getMOCountyValues(String countySearchText) {
		List<countyPicklistWrapper> opts = new List<countyPicklistWrapper>();
		try {
			Schema.SObjectType s = Schema.getGlobalDescribe().get('Case');
			Schema.DescribeSObjectResult r = s.getDescribe();
			Map<String, Schema.SObjectField> fields = r.fields.getMap();
			Schema.DescribeFieldResult fieldResult = fields.get('County__c').getDescribe();
			List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();

			for (Schema.PicklistEntry pickListVal : ple) {
				countyPicklistWrapper wrapper = new countyPicklistWrapper();
				wrapper.label = pickListVal.getLabel();
				wrapper.value = pickListVal.getValue();
				opts.add(wrapper);
			}
		} catch (Exception e) {
			LPI_ExceptionManager.logException(CLASS_NAME, 'getMOCountyValues', e);
			throw new AuraHandledException(e.getMessage());
		}
		return opts;
	}
	/**
	 * @author                      : MTX Group Inc
	 * @since                       : 11 Sep 2023
	 * @description                 : This method returns map if the business license has Audit Details with status as Assigned
	 * @param blId                  : Business License Record Id
	 * @return                      : `Map<String, String>`
	 * @last modified by            : Uzma Md
	 * @last modified date          :
	 * @modified details            :
	 */
	public static List<ButtonWrapper> getAuditButton(String blId) {
		List<ButtonWrapper> auditbuttonWrapperList = new List<ButtonWrapper>();
		try {
			if (LPI_WithoutSharingUtility.isPortalUser()) {
				String whereClause =
					'Business_License__c = \'' +
					String.escapeSingleQuotes(blId) +
					'\' AND Status__c  IN ' +
					LPI_ServiceUtility.getStringValuesByStringSet(AUDIT_DETAIL_STATUS) +
					' AND RecordType.DeveloperName IN ' +
					LPI_ServiceUtility.getStringValuesByStringSet(AUDIT_RECORD_TYPE_SET) +
					' AND (No_Response_Notification_Date__c >= TODAY OR No_Response_Notification_Date__c = null OR Extension_Date__c >= TODAY)';

				List<Audit_Detail__c> auditDetailsList = LPI_AuditDetailsDAO.getAuditDetailsByDymanicQuery(
					'Id, Business_License__c, Name, RecordType.DeveloperName, No_Response_Notification_Date__c, Extension_Date__c, Grace_Period__c',
					whereClause,
					null,
					null,
					null
				);

				Set<String> auditTypeSet = new Set<String>();

				for (Audit_Detail__c audDetail : auditDetailsList) {
					if (!auditTypeSet.contains(audDetail.RecordType.DeveloperName)) {
						Map<String, String> auditDetailMap = new Map<String, String>();
						auditDetailMap.put('audId', audDetail.Id);
						Date endDate = (auditDetailsList[0].Grace_Period__c &&
							auditDetailsList[0].Extension_Date__c != null)
							? auditDetailsList[0].Extension_Date__c
							: (auditDetailsList[0].No_Response_Notification_Date__c == null
									? Date.today()
									: auditDetailsList[0].No_Response_Notification_Date__c);
						if (endDate >= Date.today()) {
							auditbuttonWrapperList.add(
								new ButtonWrapper(
									AUDIT_BUTTON_LABEL_MAP.get(audDetail.RecordType.DeveloperName),
									'AuditButton',
									JSON.serialize(auditDetailMap),
									false,
									null
								)
							);
							auditTypeSet.add(audDetail.RecordType.DeveloperName);
						}
					}
				}
			}
		} catch (Exception e) {
			LPI_ExceptionManager.logException(CLASS_NAME, 'getAuditButton', e);
			throw new AuraHandledException(e.getMessage());
		}
		return auditbuttonWrapperList;
	}

	/**
	 * @author                      : MTX Group Inc
	 * @since                       : 22 Sep 2023
	 * @description                 : This mehod is used to return account Id
	 * @param blId                  : Business License Record Id
	 * @return                      : Id
	 * @last modified by            : Uzma Md
	 * @last modified date          :
	 * @modified details            :
	 */

	@AuraEnabled(cacheable=true)
	public static Id getAccountId(Id blId) {
		try {
			if (String.isNotBlank(blId)) {
				List<BusinessLicense> businessLicenseList = (List<BusinessLicense>) LPI_BusinessLicenseDAO.fetchBusinessLicenseRecords(
					'Id,AccountId',
					'Id = \'' + String.escapeSingleQuotes(blId) + '\''
				);
				if (!businessLicenseList.isEmpty()) {
					return businessLicenseList[0].AccountId;
				}
			}
		} catch (Exception e) {
			throw new AuraHandledException(e.getMessage());
		}
		return null;
	}

	/**
	 * @author                      : MTX Group Inc
	 * @since                       :
	 * @description                 : fetch Appication Data
	 * @return                      : DataWrapper
	 * @last modified by            : Uzma Md
	 * @last modified date          :
	 * @modified details            :
	 */
	@AuraEnabled(cacheable=true)
	public static boolean checkLicenseeModification(String blId) {
		try {
			List<BusinessLicense> blList = new LPI_BusinessLicenseDAO.LPI_BusinessLicenseWithoutSharingDAO().getBusinessLicenseByDymanicQueryWithoutSecurity(
				'Id,Licensee_Modification_Reason__c',
				'Id = \'' + String.escapeSingleQuotes(blId) + '\'',
				null,null,null
			);
			if (blList[0].Licensee_Modification_Reason__c == 'Contact ED') {
				return true;
			}
			return false;
		} catch (Exception e) {
			LPI_ExceptionManager.logException(CLASS_NAME, 'checkLicenseeModification', e);
			throw new AuraHandledException(e.getMessage());
		}
	}

	/**
	 * @author                      : MTX Group Inc
	 * @since                       :
	 * @description                 : get All Location Ids related to Business License on basis of License Type
	 * @return                      : Set<Id>
	 * @last modified by            : Uzma Md
	 * @last modified date          :
	 * @modified details            :
	 */

	private static Set<Id> getAllLocationIdsRelatedToBL(Id blId, String locationType, Id currAuthAppId) {
		try {
			Set<Id> locationIdsSet = new Set<Id>();
			Set<Id> newLocationIdSet = new Set<Id>();
			String whereCondition = 'AuthorizationId = \'' + String.escapeSingleQuotes(blId) + '\'';
			if (String.isNotBlank(currAuthAppId)) {
				whereCondition += ' AND Id != \'' + String.escapeSingleQuotes(currAuthAppId) + '\'';
			}

			if (String.isNotBlank(blId)) {
				for (
					AuthApplicationPlace authAppRec : LPI_AuthApplicationPlaceDAO.getAuthApplicationPlaceByDymanicQuery(
						'PlaceId, AuthorizationId',
						whereCondition,
						null,
						null,
						null
					)
				) {
					locationIdsSet.add(authAppRec.PlaceId);
				}
				if (!locationIdsSet.isEmpty() && String.isNotBlank(locationType)) {
					for (
						Schema.Location loc : LPI_LocationDAO.getLocationByDymanicQuery(
							'Id, LocationType ',
							' LocationType = ' +
								'\'' +
								locationType +
								'\'' +
								' AND Status__c = ' +
								'\'' +
								LOCATION_STATUS +
								'\'' +
								' AND  Id IN ' +
								LPI_ServiceUtility.getStringValuesBySet(locationIdsSet),
							null,
							null,
							null
						)
					) {
						newLocationIdSet.add(loc.Id);
					}
				}
			}
			return newLocationIdSet;
		} catch (Exception e) {
			LPI_ExceptionManager.logException(CLASS_NAME, 'getAllLocationIdsRelatedToBL', e);
			throw new AuraHandledException(e.getMessage());
		}
	}

	/**
	 * @author                      : MTX Group Inc
	 * @since                       :
	 * @description                 : Update Address on Account
	 * @return                      : void
	 * @last modified by            : Uzma Md
	 * @last modified date          :
	 * @modified details            :
	 */

	private static void updateAddressOnAccount(
		Id accId,
		Schema.Address addressRec,
		Boolean IsPersonAccount,
		String telephoneNum
	) {
		if (String.isNotBlank(accId) && addressRec != null) {
			Account acc = new Account();
			acc.Id = accId;
			if (addressRec.LocationType == RESIDENCE && IsPersonAccount) {
				acc.PersonOtherCity = addressRec.City;
				acc.PersonOtherStreet = addressRec.Street;
				acc.PersonOtherPostalCode = addressRec.PostalCode;
				acc.PersonOtherCountryCode = addressRec.CountryCode;
				acc.PersonHomePhone = telephoneNum;
				acc.County__c = addressRec.County__c;
				if (addressRec.CountryCode == 'US') {
					acc.PersonOtherStateCode = addressRec.StateCode;
					acc.Other_State__c = null;
				} else {
					acc.Other_State__c = addressRec.Business_State__c;
					acc.PersonOtherState = null;
				}
			} else if (addressRec.LocationType == BUSINESS_ADDRESS && !IsPersonAccount) {
				acc.BillingCity = addressRec.City;
				acc.BillingStreet = addressRec.Street;
				acc.BillingPostalCode = addressRec.PostalCode;
				acc.BillingCountryCode = addressRec.CountryCode;
				acc.Other_Phone__c = telephoneNum;
				acc.County__c = addressRec.County__c;
				if (addressRec.CountryCode == 'US') {
					acc.BillingStateCode = addressRec.StateCode;
					acc.Other_State__c = null;
				} else {
					acc.Other_State__c = addressRec.Business_State__c;
					acc.BillingState = null;
				}
			}
			if (String.isNotBlank(acc.Id)) {
				LPI_WithoutSharingUtility.updateSObjectRecord(acc);
			}
		}
	}

	/**
	 * @author                      : MTX Group Inc
	 * @since                       :
	 * @description                 : fetch Verification of licensure Data on IA
	 * @last modified by            : Uzma Md
	 * @last modified date          :
	 * @modified details            :
	 */
	@AuraEnabled
	public static LicenseVerificationWrapper fetchIaVerificationData(String recordId) {
		try {
			String fieldToQuery = 'Institution_Name__r.Institution_Name__c,Disciplinary_Charges_Imposed__c';
			List<IndividualApplication> iaList = LPI_IndividualApplicationDAO.getIndividualApplicationByDymanicQuery(
				fieldToQuery,
				'Id = \'' + String.escapeSingleQuotes(recordId) + '\'',
				null,
				null,
				null
			);
			LicenseVerificationWrapper verificationData = new LicenseVerificationWrapper();
			if (!iaList.isEmpty()) {
				
				
				verificationData.disciplinaryActionImposed = iaList[0].Disciplinary_Charges_Imposed__c;
			}
			Schema.SObjectType sObjectType = Schema.getGlobalDescribe().get('IndividualApplication');
			Schema.DescribeSObjectResult sObjectData = sObjectType.getDescribe();
			Map<String, Schema.SObjectField> fields = sObjectData.fields.getMap();
			// for (
			// 	Schema.PicklistEntry pickListVal : fields.get('Verification_Type__c').getDescribe().getPicklistValues()
			// ) {
			// 	StateOptionsWrapper picklistData = new StateOptionsWrapper();
			// 	picklistData.label = pickListVal.getLabel();
			// 	picklistData.value = pickListVal.getValue();
			// 	verificationData.requestTypePicklistDataList.add(picklistData);
			// }
			return verificationData;
		} catch (Exception e) {
			LPI_ExceptionManager.logException(CLASS_NAME, 'fetchIaVerificationData', e);
			throw new AuraHandledException(e.getMessage());
		}
	}

	/**
	 * @author                      : MTX Group Inc
	 * @since                       :
	 * @description                 : update Verification of licensure Data on IA
	 * @last modified by            : Uzma Md
	 * @last modified date          :
	 * @modified details            :
	 */
	@AuraEnabled
	public static void updateIaVerificationData(String verificationData) {
		try {
			Map<String, object> verificationDataMap = (Map<String, object>) JSON.deserializeUntyped(verificationData);
			IndividualApplication ia = new IndividualApplication();
			ia.Id = (String) verificationDataMap.get('applicationId');
			
			//ia.Verification_Type__c = (String) verificationDataMap.get('requestType');
			ia.License_is_in_Good_Standing__c = (Boolean) verificationDataMap.get('licenseGoodStanding');
			ia.Disciplinary_Charges_Imposed__c = (Boolean) verificationDataMap.get('disciplinaryActionImposed');
			LPI_DML.doUpdate(ia);
		} catch (Exception e) {
			LPI_ExceptionManager.logException(CLASS_NAME, 'updateIaVerificationData', e);
			throw new AuraHandledException(e.getMessage());
		}
	}

	

	/**
	 * @author                      : MTX Group Inc
	 * @since                       :
	 * @description                 : Wrapper class used to store field label and values
	 * @last modified by            : Uzma Md
	 * @last modified date          :
	 * @modified details            :
	 */
	public class FieldValueWrapper {
		@AuraEnabled
		public String label;
		@AuraEnabled
		public String value;
		@AuraEnabled
		public boolean isLookup;
		@AuraEnabled
		public String lookupId;
		@AuraEnabled
		public Boolean isCoverCompleteWidth;
		public FieldValueWrapper() {
		}
		public FieldValueWrapper(String label, String value) {
			this.label = label;
			this.value = value;
			this.isLookup = false;
			this.isCoverCompleteWidth = false;
		}
		public FieldValueWrapper(String label, String value, boolean isCoverCompleteWidth) {
			this.label = label;
			this.value = value;
			this.isLookup = false;
			this.isCoverCompleteWidth = isCoverCompleteWidth;
		}
		public FieldValueWrapper(String label, String value, boolean isLookup, String lookupId) {
			this.label = label;
			this.value = value;
			this.isLookup = isLookup;
			this.lookupId = lookupId;
			this.isCoverCompleteWidth = false;
		}
	}
	/**
	 * @author                      : MTX Group Inc
	 * @since                       :
	 * @description                 : Wrapper class used to store if we have any heading in the view page
	 * @last modified by            : Uzma Md
	 * @last modified date          :
	 * @modified details            :
	 */
	public class HeadingFieldValueWrapper {
		@AuraEnabled
		public String headingName;
		@AuraEnabled
		public List<FieldValueWrapper> headingFieldValue;

		public HeadingFieldValueWrapper(String headingName, List<FieldValueWrapper> headingFieldValue) {
			this.headingName = headingName;
			this.headingFieldValue = headingFieldValue;
		}
	}
	/**
	 * @author                      :MTX Group Inc
	 * @since                       :
	 * @description                 : Wrapper class
	 * @last modified by            : Uzma Md
	 * @last modified date          :
	 * @modified details            :
	 */
	public class FieldHeadingWrapper {
		@AuraEnabled
		public List<FieldValueWrapper> fieldValueList;
		@AuraEnabled
		public boolean showAnyButton;
		@AuraEnabled
		public ButtonWrapper buttonDetail;
		@AuraEnabled
		public boolean showHeadingList;
		@AuraEnabled
		public boolean showErrorMessage;
		@AuraEnabled
		public String errorMessage;
		@AuraEnabled
		public List<HeadingFieldValueWrapper> headingFieldValueList;

		public FieldHeadingWrapper(
			List<FieldValueWrapper> fieldValueList,
			boolean showHeadingList,
			List<HeadingFieldValueWrapper> headingFieldValueList
		) {
			this.fieldValueList = fieldValueList;
			this.showHeadingList = showHeadingList;
			this.headingFieldValueList = headingFieldValueList;
			this.showErrorMessage = false;
		}
		public FieldHeadingWrapper(
			List<FieldValueWrapper> fieldValueList,
			boolean showAnyButton,
			ButtonWrapper buttonDetail,
			boolean showHeadingList,
			List<HeadingFieldValueWrapper> headingFieldValueList
		) {
			this.fieldValueList = fieldValueList;
			this.showAnyButton = showAnyButton;
			this.buttonDetail = buttonDetail;
			this.showHeadingList = showHeadingList;
			this.showErrorMessage = false;
			this.headingFieldValueList = headingFieldValueList;
		}
		public FieldHeadingWrapper(
			List<FieldValueWrapper> fieldValueList,
			boolean showAnyButton,
			ButtonWrapper buttonDetail,
			boolean showHeadingList,
			List<HeadingFieldValueWrapper> headingFieldValueList,
			boolean showErrorMessage,
			String errorMessage
		) {
			this.fieldValueList = fieldValueList;
			this.showAnyButton = showAnyButton;
			this.buttonDetail = buttonDetail;
			this.showHeadingList = showHeadingList;
			this.showErrorMessage = showErrorMessage;
			this.errorMessage = errorMessage;
			this.headingFieldValueList = headingFieldValueList;
		}
	}
	/**
	 * @author                      : MTX Group Inc
	 * @since                       :
	 * @description                 : Main Wrapper class used to store Single Section  data
	 * @last modified by            : Uzma Md
	 * @last modified date          :
	 * @modified details            :
	 */
	public class ApplicationViewWrapper {
		@AuraEnabled
		public String sectionName;
		@AuraEnabled
		public List<FieldHeadingWrapper> fieldHeadingWrapper;
		@AuraEnabled
		public boolean isChildSection;
		@AuraEnabled
		public List<ApplicationViewWrapper> childSectionList;

		public ApplicationViewWrapper(
			String sectionName,
			List<FieldHeadingWrapper> fieldHeadingWrapper,
			boolean isChildSection,
			List<ApplicationViewWrapper> childSectionList
		) {
			this.sectionName = sectionName;
			this.fieldHeadingWrapper = fieldHeadingWrapper;
			this.isChildSection = isChildSection;
			this.childSectionList = childSectionList;
		}
	}
	/**
	 * @author                      : MTX Group Inc
	 * @since                       :
	 * @description                 : fetch Authorization app detail according to Auth App Place record id
	 * @last modified by            : Uzma Md
	 * @last modified date          :
	 * @modified details            :
	 */
	@AuraEnabled
	public static BranchDataWrapper fetchAuthAppDetails(Id recordId, String locationType) {
		try {
			Set<Id> locationIdsSet = new Set<Id>();
			Set<Id> newLocationIdSet = new Set<Id>();
			Schema.SObjectType objectType = recordId.getSObjectType();
			String objectApiName = objectType.getDescribe().getName();
			BranchDataWrapper branchAddressWrapRec = new BranchDataWrapper();
			if (String.isNotBlank(recordId)) {
				AuthApplicationPlace authAppPlaceObj = new AuthApplicationPlace();
				String whereClause = '';
				if(objectApiName == 'AuthApplicationPlace'){
					whereClause += 'Id = \'' + String.escapeSingleQuotes(recordId) + '\'';
				}
				else if(objectApiName == 'BusinessLicense'){
					whereClause += 'AuthorizationId = \'' + String.escapeSingleQuotes(recordId) + '\'';
				}
				for (
					AuthApplicationPlace authAppRec : LPI_AuthApplicationPlaceDAO.getAuthApplicationPlaceByDymanicQuery(
						'Id, PlaceId, AuthorizationId,Authorization.Business_Entity_Name__c,Authorization.Account.Name,Authorization.Account.PersonHomePhone, Authorization.Account.Other_Phone__c, Authorization.Account.IsPersonAccount',
						whereClause,
						null,
						null,
						null
					)
				) {
					authAppPlaceObj = authAppRec;
					locationIdsSet.add(authAppRec.PlaceId);
				}
				if (!locationIdsSet.isEmpty()) {
					String locationWhereClause = 'ParentId IN ' + LPI_ServiceUtility.getStringValuesBySet(locationIdsSet);
					if(objectApiName == 'BusinessLicense'){
						locationWhereClause += ' AND LocationType = '+ '\''+ locationType + '\'' + ' AND Parent.Status__c = '+ '\'' + LOCATION_STATUS +'\'';
					}
					for (
						Schema.Address add : (new LPI_AddressDAO.LPI_AddressDAOWithoutSharing()).getAddressByDymanicQuery(
							'Id, LocationType, Street, CountryCode, StateCode, Business_State__c, County__c, postalCode, City, ParentId, ' +
							'Parent.OpenDate,Parent.CloseDate, Parent.Status__c, Parent.Name, Parent.Business_Phone__c',
							locationWhereClause,
							'1',
							'CreatedDate',
							'DESC'
						)
					) {
						branchAddressWrapRec.addressType = add.LocationType;
						locationType = add.LocationType;
						branchAddressWrapRec.streetAddress = add.Street;
						branchAddressWrapRec.city = add.City;
						if (add.CountryCode == 'US') {
							branchAddressWrapRec.state = add.StateCode;
							branchAddressWrapRec.stateText = '';
						} else {
							branchAddressWrapRec.stateText = add.Business_State__c;
							branchAddressWrapRec.state = '';
						}
						branchAddressWrapRec.zipCode = add.postalCode;
						branchAddressWrapRec.country = add.CountryCode;
						branchAddressWrapRec.openDate = add.Parent.OpenDate;
						branchAddressWrapRec.closeDate = add.Parent.CloseDate;
						branchAddressWrapRec.status = add.Parent.Status__c;
						branchAddressWrapRec.telephoneNum = add.Parent.Business_Phone__c;
						if (add.StateCode == 'MO') {
							branchAddressWrapRec.countyLookup = add.County__c;
							branchAddressWrapRec.county = '';
						} else {
							branchAddressWrapRec.county = add.County__c;
							branchAddressWrapRec.countyLookup = '';
						}
						if(String.isBlank(branchAddressWrapRec.telephoneNum)){
							if (authAppPlaceObj.Authorization.Account.IsPersonAccount && String.isBlank(branchAddressWrapRec.telephoneNum)) {
								branchAddressWrapRec.telephoneNum = authAppPlaceObj.Authorization.Account.PersonHomePhone;
							} else {
								branchAddressWrapRec.telephoneNum = authAppPlaceObj.Authorization.Account.Other_Phone__c;
							}
						}
					}
				}
				if(locationType == 'Business Address'){
					if(String.isNotBlank(authAppPlaceObj?.Authorization?.Business_Entity_Name__c)){
						branchAddressWrapRec.businessName = authAppPlaceObj?.Authorization?.Business_Entity_Name__c;
					}
					else{
						branchAddressWrapRec.businessName = authAppPlaceObj?.Authorization?.Account.Name;
					}
				}
				return branchAddressWrapRec;
			}
			return null;
		} catch (Exception e) {
			LPI_ExceptionManager.logException(CLASS_NAME, 'fetchAuthAppDetails', e);
			throw new AuraHandledException(e.getMessage());
		}
	}
	/**
	 * @author                      : MTX Group Inc
	 * @since                       :
	 * @description                 : method is used to edit the location detail according to auth app id
	 * @last modified by            : Uzma Md
	 * @last modified date          :
	 * @modified details            :
	 */
	@AuraEnabled
	public static Void editLocation(Id recordId, String branchDataObj) {
		try {
			Set<Id> locationIdsSet = new Set<Id>();
			BranchDataWrapper branchWrapRecord = (BranchDataWrapper) JSON.deserializeStrict(
				branchDataObj,
				BranchDataWrapper.class
			);
			if (String.isNotBlank(recordId)) {
				List<AuthApplicationPlace> authAppPlaceList = LPI_AuthApplicationPlaceDAO.getAuthApplicationPlaceByDymanicQuery(
					'Id, PlaceId, AuthorizationId',
					'Id = \'' + String.escapeSingleQuotes(recordId) + '\'',
					null,
					null,
					null
				);
				if (!authAppPlaceList.isEmpty()) {
					if (
						branchWrapRecord.status == 'Closed' &&
						ALLOW_CLOSE_LOCATION_TYPE_SET.contains(branchWrapRecord.addressType)
					) {
						Set<Id> locationIds = getAllLocationIdsRelatedToBL(
							authAppPlaceList[0].AuthorizationId,
							branchWrapRecord.addressType,
							authAppPlaceList[0].Id
						);
						if (locationIds.isEmpty()) {
							throw new LPI_Exception(
								'To close this address, there needs to be one address with an \'Open\' status of the same address type.'
							);
						}
					}
					for (AuthApplicationPlace authAppRec : authAppPlaceList) {
						locationIdsSet.add(authAppRec.PlaceId);
					}
				}
			}
			for (Id locationId : locationIdsSet) {
				Schema.Location branchLoc = new Schema.Location();
				branchLoc.Id = locationId;
				branchLoc.OpenDate = branchWrapRecord.openDate;
				branchLoc.CloseDate = branchWrapRecord.closeDate;
				branchLoc.Status__c = branchWrapRecord.status;
				LPI_DML.doUpdate(branchLoc);
			}
		} catch (Exception e) {
			LPI_ExceptionManager.logException(CLASS_NAME, 'editLocation', e);
			throw new AuraHandledException(e.getMessage());
		}
	}

	/**
	 * @author                      : MTX Group Inc
	 * @since                       :
	 * @description                 : Wrapper class used to store Button property which we have to show in the ui
	 * @last modified by            : Uzma Md
	 * @last modified date          :
	 * @modified details            :
	 */
	public class ButtonWrapper {
		@AuraEnabled
		public String buttonLable;
		@AuraEnabled
		public String buttonName;
		@AuraEnabled
		public String buttonJSONData;
		@AuraEnabled
		public boolean hasChild;
		@AuraEnabled
		public String headingLabel;
		@AuraEnabled
		public List<ButtonWrapper> childButton;
		public ButtonWrapper(
			String buttonLable,
			String buttonName,
			String buttonJSONData,
			boolean hasChild,
			List<ButtonWrapper> childButton
		) {
			this.buttonLable = buttonLable;
			this.buttonName = buttonName;
			this.buttonJSONData = buttonJSONData;
			this.hasChild = hasChild;
			this.childButton = childButton;
		}
		public ButtonWrapper(
			String buttonLable,
			String buttonName,
			String buttonJSONData,
			boolean hasChild,
			List<ButtonWrapper> childButton,
			String headingLabel
		) {
			this.buttonLable = buttonLable;
			this.buttonName = buttonName;
			this.buttonJSONData = buttonJSONData;
			this.hasChild = hasChild;
			this.childButton = childButton;
			this.headingLabel = headingLabel;
		}
	}
	/**
	 * @author                      : MTX Group Inc
	 * @since                       :
	 * @description                 : Main Wrapper class used to store Business License data
	 * @last modified by            : Uzma Md
	 * @last modified date          :
	 * @modified details            :
	 */
	public class DataWrapper {
		@AuraEnabled
		public string accId;
		@AuraEnabled
		public string regId;
		@AuraEnabled
		public string blId;
		@AuraEnabled
		public List<ApplicationViewWrapper> dataList;
		@AuraEnabled
		public List<ButtonWrapper> buttonList;
		@AuraEnabled
		public string boardName;
		@AuraEnabled
		public String licenseType;
		public DataWrapper(
			String regId,
			String accId,
			String blId,
			List<ApplicationViewWrapper> dataList,
			List<ButtonWrapper> buttonList,
			String boardName,
			String licenseType
		) {
			this.accId = accId;
			this.regId = regId;
			this.blId = blId;
			this.dataList = dataList;
			this.buttonList = buttonList;
			this.boardName = boardName;
			this.licenseType = licenseType;
		}
	}

	/**
	 * @author                      : MTX Group Inc
	 * @since                       :
	 * @description                 : Wrapper class used to show Branch Address data
	 * @last modified by            : Uzma Md
	 * @last modified date          :
	 * @modified details            :
	 */
	public class BranchDataWrapper {
		@AuraEnabled
		public string branchAddId;
		@AuraEnabled
		public string label;
		@AuraEnabled
		public string streetAddress;
		@AuraEnabled
		public string country;
		@AuraEnabled
		public string city;
		@AuraEnabled
		public string state;
		@AuraEnabled
		public string stateText;
		@AuraEnabled
		public string zipCode;
		@AuraEnabled
		public string county;
		@AuraEnabled
		public string telephoneNum;
		@AuraEnabled
		public string countyLookup;
		@AuraEnabled
		public date openDate;
		@AuraEnabled
		public date closeDate;
		@AuraEnabled
		public String status;
		@AuraEnabled
		public String addressType;
		@AuraEnabled
		public String businessName;
		@AuraEnabled
		public Boolean isAddressUpdateOnAccount;

		public BranchDataWrapper(Schema.Address branchAddress) {
			this.branchAddId = branchAddress.ParentId;
			this.streetAddress = branchAddress.Street;
			this.country = branchAddress.Country;
			this.city = branchAddress.City;
			this.state = branchAddress.State;
			this.stateText = branchAddress.Business_State__c;
			this.zipCode = branchAddress.PostalCode;
			this.county = branchAddress.County__c;
			this.telephoneNum = branchAddress.Parent.Business_Phone__c;
		}
		public BranchDataWrapper() {
		}
	}
	/**
	 * @author                      :MTX Group Inc
	 * @since                       :
	 * @description                 : Wrapper class used for county values
	 * @last modified by            : Uzma Md
	 * @last modified date          :
	 * @modified details            :
	 */
	public class countyPicklistWrapper {
		@AuraEnabled
		public String label { get; set; }
		@AuraEnabled
		public String value { get; set; }

		public countyPicklistWrapper() {
			this.label = '';
			this.value = '';
		}
	}

	/**
	 * @author                      : MTX Group Inc
	 * @since                       :
	 * @description                 : Wrapper class used for License Verification
	 * @last modified by            : Uzma Md
	 * @last modified date          :
	 * @modified details            :
	 */
	public class LicenseVerificationWrapper {
		@AuraEnabled
		public String institutionId;
		@AuraEnabled
		public String institutionName;
		@AuraEnabled
		public String requestType;
		@AuraEnabled
		public Boolean licenseGoodStanding;
		@AuraEnabled
		public Boolean disciplinaryActionImposed;
		@AuraEnabled
		public List<StateOptionsWrapper> requestTypePicklistDataList;

		public LicenseVerificationWrapper() {
			this.institutionId = '';
			this.institutionName = '';
			this.requestType = '';
			this.licenseGoodStanding = false;
			this.licenseGoodStanding = false;
			this.requestTypePicklistDataList = new List<StateOptionsWrapper>();
		}
	}
	public class StateOptionsWrapper {
		@AuraEnabled
		public String label;
		@AuraEnabled
		public String value;
	}
	/**
	 * @author                      :MTX Group Inc
	 * @description                 : Returns true if the Business License is Business Type 
	 * @last modified by            : Uzma Md
	 * @last modified date          : 
	 * @param blId 
	 * @return  `Boolean`
	 * @exception 
	 */
	@AuraEnabled(cacheable=true)
	public static Boolean isBLAuthorisationTypeBusiness(Id blId) {
		Boolean result = false;
		try {
			if (String.isNotBlank(blId)) {
				List<BusinessLicense> businessLicenseList = (List<BusinessLicense>) LPI_BusinessLicenseDAO.fetchBusinessLicenseRecords(
					'Id,RegulatoryAuthorizationType.Authorisation_Type__c',
					'Id = \'' + String.escapeSingleQuotes(blId) + '\''
				);
				if (!businessLicenseList.isEmpty() && businessLicenseList[0].RegulatoryAuthorizationType.Authorisation_Type__c == AUTHORISATION_TYPE_BUSINESS) {
					return true;
				}
			}
		} catch (Exception e) {
			throw new AuraHandledException(e.getMessage());
		}
		return result;
	}
}