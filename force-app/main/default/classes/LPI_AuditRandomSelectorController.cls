/**
 * @author              : MTX Group Product Team
 * @since               : 11th Sep, 2023
 * @description         : This class is used to Random Audit the Bussiness Licenses.
 */
public with sharing class LPI_AuditRandomSelectorController {
	private static final Set<String> COMPLAINT_STATUS_SET = new Set<String>{
		'Submitted',
		'In Review',
		'New',
		'Draft',
		'Opened'
	};
	private static final String FINANCIAL_AUDIT_TYPE = 'Financial Audit';
	private static final String EXECUTIVE_DIRECTOR_PERMISSION_SET = 'Executive_Director';
	private static final String SYSTEM_ADMIN_PROFILE = 'System Administrator';
	private static final String EXECUTIVE_DIRECTOR_PERMISSION_ROLE = 'Executive Director';
	private static final String CE_AUDIT_TYPE = 'CE_Audit';
	private static final String INDIVIDUAL_LICENSE_TYPE = 'Individual';
	private static final Set<String> INDIVIDUAL_AUDIT_SET = new Set<String>{
		'CE_Audit',
		'Insurance_Audit',
		'Certification_Audit'
	};
	 
	private static final String MTAA = 'MTAA';
	private static final String INSURANCE_CONSULTANT = 'Insurance Consultant';
	private static final String MTAA_INSURANCE_CONSULTANT = 'MTAA + Insurance Consultant';
	 

	 
	private static final Set<String> RAT_EXCEPTIONS_SET = new Set<String>{
		'Temp. Pharmacist',
		'Temp. Pharmacy',
		'Temporary Drug Distributor',
		'CPA-Certificate Holder',
		'CPA Provisional License',
		'Psychologist - Temporary'
	};
	 

	private static final String PROBATION = 'Probation';
	private static final String SUSPENSTION = 'Suspension';
	private static final String OPEN_COMPLAINTS = 'Open Complaints';
	private static final Set<String> BL_EXCLUDED_STATUS = new Set<String>{ 'Void', 'Expired' };

	/**
	 * @author                      :  MTX Group Product Team
	 * @since                       : 11th Sep, 2023
	 * @description                 : Method to check if user have access to perform audit or not,
	 * @param                       : None
	 * @return 	                    : boolean
	 * @last modified by            :  MTX Group Product Team
	 * @last modified date          : (Add if modified by you)
	 * @last modified details       : (Add if modified by you)
	 */
	@AuraEnabled
	public static Boolean isExecutiveDirectorUser() {
		try {
			User userDetails = [
				SELECT Id, Name, Email, Profile.Name, UserRole.Name, Access_to_Audit_Process__c
				FROM User
				WHERE Id = :userinfo.getUserId()
			];
			return userDetails.UserRole.Name == EXECUTIVE_DIRECTOR_PERMISSION_ROLE ||
				userDetails.Access_to_Audit_Process__c ||
				userDetails.Profile.Name == SYSTEM_ADMIN_PROFILE;
		} catch (Exception e) {
			LPI_ExceptionManager.logException('LPI_AuditRandomSelectorController', 'isExecutiveDirectorUser', e);
			throw new AuraHandledException(e.getMessage());
		}
	}
	/**
	 * @author                      : MTX Group Product Team
	 * @since                       : 11th Sep, 2023
	 * @description                 : Method to will fetch all RAT records date related to Board
	 * @param 					   : issuingDepartmentId[Regulatory Authority Id]
	 * @return 	                   : List<SelectOption>
	 * @last modified by            : MTX Group Product Team
	 * @last modified date          : (Add if modified by you)
	 * @last modified details       : (Add if modified by you)
	 */
	@AuraEnabled
	public static List<SelectOption> fetchProfessions(String issuingDepartmentId, String auditType) {
		List<SelectOption> options = new List<SelectOption>();
		try {
			String whereClause = 'IssuingDepartmentId = \'' + String.escapeSingleQuotes(issuingDepartmentId) + '\'';
			if (INDIVIDUAL_AUDIT_SET.contains(auditType)) {
				whereClause = whereClause + ' AND Authorisation_Type__c = \'' + INDIVIDUAL_LICENSE_TYPE + '\'';
			}
			if (auditType == CE_AUDIT_TYPE) {
				whereClause += ' AND Expiry_Rule_Type__c !=\'No Expiry\' AND Expiry_Rule_Type__c!=null';
			}
			for (
				RegulatoryAuthorizationType ra : LPI_RegulatoryAuthorizationTypeDAO.getRegulatoryAuthorizationTypeByDymanicQuery(
					'Name,Minimum_CE_Hours_for_Audit__c,Audit_Configuration__c',
					whereClause,
					null,
					'Name',
					null
				)
			) {
				 
				if (!RAT_EXCEPTIONS_SET.contains(ra.Name)) {
					String ceHours = ra.Minimum_CE_Hours_for_Audit__c != null
						? String.valueOf(ra.Minimum_CE_Hours_for_Audit__c)
						: '';
					String auditConfig = ra.Audit_Configuration__c != null
						? String.valueOf(ra.Audit_Configuration__c)
						: '';
					options.add(new SelectOption(ra.Name, ra.Name + '-##-' + ceHours + '-##-' + auditConfig));
				}
			}
			return options;
		} catch (Exception e) {
			LPI_ExceptionManager.logException('LPI_AuditRandomSelectorController', 'fetchProfessions', e);
			throw new AuraHandledException(e.getMessage());
		}
	}

	/**
	 * @author                      : MTX Group Product Team
	 * @since                       : 11th Sep, 2023
	 * @description                 : Method to will fetch required Board [Regulatory Authority] data.
	 * @param                       : issuingDepartmentId [Regulatory Authority Id]
	 * @return 	                    : AuditDataWrapper
	 * @last modified by            : MTX Group Product Team
	 * @last modified date          : (Add if modified by you)
	 * @last modified details       : (Add if modified by you)
	 */
	@AuraEnabled
	public static AuditDataWrapper fetchAuditData(String issuingDepartmentId) {
		List<SelectOption> options = new List<SelectOption>();
		try {
			List<RegulatoryAuthority> raList = LPI_RegulatoryAuthorityDAO.getRegulatoryAuthorityByDymanicQuery(
				'Audit_Types__c,Reminder_Notification_Period__c,No_Response_Notification_Period__c,name',
				'Id = \'' + String.escapeSingleQuotes(issuingDepartmentId) + '\'',
				null,
				null,
				null
			);
			if (!raList.isEmpty()) {
				if (raList[0].Audit_Types__c != null) {
					Map<String, String> auditTypePicklictValueMap = getAuditTypeFieldPickListLabelValueMap();
					for (String auditType : raList[0].Audit_Types__c.split(';')) {
						String label = auditTypePicklictValueMap.get(auditType);
						if (label != FINANCIAL_AUDIT_TYPE) {
							options.add(new SelectOption(label, auditType));
						}
					}
				}
				AuditDataWrapper auditData = new AuditDataWrapper();
				auditData.boardName = raList[0].Name;
				auditData.noResponseNotificationPeriod = raList[0].No_Response_Notification_Period__c == null
					? 0
					: raList[0].No_Response_Notification_Period__c;
				auditData.reminderNotificationPeriod = raList[0].Reminder_Notification_Period__c == null
					? 0
					: raList[0].Reminder_Notification_Period__c;
				auditData.auditTypes.addAll(options);
				return auditData;
			}
			return null;
		} catch (Exception e) {
			LPI_ExceptionManager.logException('LPI_AuditRandomSelectorController', 'fetchAuditData', e);
			throw new AuraHandledException(e.getMessage());
		}
	}

	/**
	 * @author                      : MTX Group Product Team
	 * @since                       : 11th Sep, 2023
	 * @description                 : Method to will fetch Business Licenses based on the given input filter parameters.
	 * @param                       : filters [String JSON]
	 * @return 	                    : List<BusinessLicenseDataWrapper>
	 * @last modified by            : MTX Group Product Team
	 * @last modified date          : (Add if modified by you)
	 * @last modified details       : (Add if modified by you)
	 */
	@AuraEnabled
	public static List<BusinessLicenseDataWrapper> getFilteredLicenseRecords(
		String filters,
		List<String> discActionList
	) {
		try {
			Map<String, object> queryParams = (Map<String, object>) JSON.deserializeUntyped(filters);
			String auditType = queryParams.containsKey('auditType') ? (String) queryParams.get('auditType') : '';
			String blQueryFields =
				'Name,PeriodStart,PeriodEnd,Last_Audit_Cycle_End_Date__c,RegulatoryAuthorizationTypeId,RegulatoryAuthorizationType.Expiry_Rule_Type__c,' +
				'RegulatoryAuthorizationType.Expiration_Cycle__c,Regulatory_Authorization_Type_Name__c,RegulatoryAuthorizationType.Expiration_Month__c, ' +
				'Business_Entity_Name__c,Disciplinary_Status__c,RegulatoryAuthorizationType.Expiration_Day__c,RegulatoryAuthorizationType.IssuingDepartment.Name,' +
				'RegulatoryAuthorizationType.Expiration_Fixed_Cycle_Difference__c,RegulatoryAuthorizationType.Expiration_Period__c,' +
				'(SELECT Id FROM Business_Complaints__r WHERE Public_Complaint__r.Status IN ' +
				LPI_ServiceUtility.getStringValuesByStringSet(COMPLAINT_STATUS_SET) +
				' LIMIT 1)';

			 
			if (auditType == CE_AUDIT_TYPE) {
				blQueryFields +=
					',(SELECT Id,Business_License__c,Audit_Start_Date__c,RecordType.DeveloperName,' +
					'Status__c,Initial_Notification_Date__c,Current_Reporting_End_Date__c,Reminder_Notification_Date__c,' +
					'No_Response_Notification_Date__c,Approved_CE_Hours__c FROM Audit_Details__r WHERE RecordType.DeveloperName = \'' +
					auditType +
					'\')';
			}

			String blWhereClause = '';
			blWhereClause =
				'Regulatory_Authorization_Type_Name__c = \'' +
				(String) queryParams.get('selectedProfession') +
				'\'';

			String selectedIssueDateFrom = queryParams.containsKey('selectedIssueDateFrom')
				? (String) queryParams.get('selectedIssueDateFrom')
				: '';
			String selectedIssueDateTo = queryParams.containsKey('selectedIssueDateTo')
				? (String) queryParams.get('selectedIssueDateTo')
				: '';
			String selectedExpDate = queryParams.containsKey('selectedExpDate')
				? (String) queryParams.get('selectedExpDate')
				: '';
			Decimal minimumCeHours = queryParams.containsKey('minimumCeHours') &&
				String.isNotBlank((String) queryParams.get('minimumCeHours'))
				? Decimal.valueOf((String) queryParams.get('minimumCeHours'))
				: 0;
			Boolean isApplicableforActiveLicense = queryParams.containsKey('isApplicableforActiveLicense')
				? (Boolean) queryParams.get('isApplicableforActiveLicense')
				: false;
			Boolean lastAuditCheck = queryParams.containsKey('lastAuditCheck')
				? (Boolean) queryParams.get('lastAuditCheck')
				: false;
			Boolean firstRenewalCheck = queryParams.containsKey('firstRenewalCheck')
				? (Boolean) queryParams.get('firstRenewalCheck')
				: false;

			 
			if (String.isNotBlank(selectedIssueDateFrom)) {
				Date filterDate = Date.valueOf(selectedIssueDateFrom);
				DateTime selectedIssueDateFromTime = DateTime.newInstance(
					filterDate.year(),
					filterDate.month(),
					filterDate.day(),
					0,
					0,
					0
				);
				blWhereClause =
					blWhereClause +
					' AND PeriodStart >= ' +
					selectedIssueDateFromTime.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'');
			}

			 
			if (String.isNotBlank(selectedIssueDateTo)) {
				Date filterDate = Date.valueOf(selectedIssueDateTo);
				DateTime selectedIssueDateToTime = DateTime.newInstance(
					filterDate.year(),
					filterDate.month(),
					filterDate.day(),
					0,
					0,
					0
				);
				blWhereClause =
					blWhereClause +
					' AND PeriodStart < ' +
					selectedIssueDateToTime.addDays(1).formatGmt('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'');
			}

			 
			if (String.isNotBlank(selectedExpDate)) {
				Date filterDate = Date.valueOf(selectedExpDate);
				DateTime selectedExpDateTime = DateTime.newInstance(
					filterDate.year(),
					filterDate.month(),
					filterDate.day(),
					0,
					0,
					0
				);

				blWhereClause =
					blWhereClause +
					' AND PeriodEnd >= ' +
					selectedExpDateTime.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'') +
					' AND PeriodEnd < ' +
					selectedExpDateTime.addDays(1).formatGmt('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'');
			}

			 
			blWhereClause +=
				' AND Status NOT IN ' + LPI_ServiceUtility.getStringValuesByStringSet(BL_EXCLUDED_STATUS);

			 
			if (isApplicableforActiveLicense) {
				blWhereClause = blWhereClause + ' AND Status = \'Active\'';
			}

			 
			if (firstRenewalCheck && auditType == CE_AUDIT_TYPE) {
				blWhereClause = blWhereClause + ' AND Renewal_date__c != null';
			}  

			 
			List<BusinessLicenseDataWrapper> blDataList = new List<BusinessLicenseDataWrapper>();

			 
			LPI_BusinessLicenseDAO.LPI_BusinessLicenseWithoutSharingDAO blDao = new LPI_BusinessLicenseDAO.LPI_BusinessLicenseWithoutSharingDAO();
			Map<Id, BusinessLicense> blMap = new Map<Id, BusinessLicense>(
				blDao.getBusinessLicenseByDymanicQuery(
					blQueryFields,
					blWhereClause,
					null,
					null,
					null
				)
			);
			String selectedSubProfession = queryParams.containsKey('selectedSubProfession')
				? (String) queryParams.get('selectedSubProfession')
				: null;
			Map<Id, Boolean> isMTAABusinessLicenseMap = new Map<Id, Boolean>();
			Map<Id, Boolean> isInsuranceConsultBusinessLicenseMap = new Map<Id, Boolean>();

			 
			if (selectedSubProfession != null && !blMap.isEmpty()) {
				String fields = 'Id, Title__c, Business_License__c';
				String whereClause =
					'Business_License__c IN ' + LPI_ServiceUtility.getStringValuesBySet(blMap.keySet());

				for (
					BoardCertification certificationRecords : LPI_CertificationDAO.getCertificationByDymanicQuery(
						fields,
						whereClause,
						null,
						null,
						null
					)
				) {
					if (selectedSubProfession.contains(MTAA) && certificationRecords.Title__c == MTAA) {
						isMTAABusinessLicenseMap.put(certificationRecords?.Business_License__c, true);
					} else if (
						selectedSubProfession.contains(INSURANCE_CONSULTANT) &&
						certificationRecords.Title__c == INSURANCE_CONSULTANT
					) {
						isInsuranceConsultBusinessLicenseMap.put(certificationRecords?.Business_License__c, true);
					}
				}
			}  
			for (Id bl : blMap.keySet()) {
				Boolean isComplaintEligible =
					discActionList.contains(OPEN_COMPLAINTS) && !blMap.get(bl).Business_Complaints__r.isEmpty();
				Boolean isProbationEligible =
					discActionList.contains(PROBATION) && blMap.get(bl).Disciplinary_Status__c == PROBATION;
				Boolean isSuspendedEligible =
					discActionList.contains(SUSPENSTION) && blMap.get(bl).Disciplinary_Status__c == SUSPENSTION;

				 
				if (discActionList.isEmpty() || isComplaintEligible || isProbationEligible || isSuspendedEligible) {
					if (selectedSubProfession == MTAA && !isMTAABusinessLicenseMap.containsKey(bl)) {
						continue;
					} else if (
						selectedSubProfession == INSURANCE_CONSULTANT &&
						!isInsuranceConsultBusinessLicenseMap.containsKey(bl)
					) {
						continue;
					} else if (
						selectedSubProfession == MTAA_INSURANCE_CONSULTANT &&
						!(isMTAABusinessLicenseMap.containsKey(bl) &&
						isInsuranceConsultBusinessLicenseMap.containsKey(bl))
					) {
						continue;
					}

					Map<String,Audit_Detail__c> ceAuditDetailsMap = new Map<String,Audit_Detail__c>();
					Boolean isCEHoursEligible = true;
					if (auditType == CE_AUDIT_TYPE) {
						Datetime lastExpiryDateTime = LPI_DocumentConfigGenerator.getPrevCycleExpiryDates(
							blMap.get(bl),
							1
						);
						Date lastExpiryDate = lastExpiryDateTime != null
							? Date.newInstance(
									lastExpiryDateTime.year(),
									lastExpiryDateTime.month(),
									lastExpiryDateTime.day()
							  )
							: null;
						 
						if (
							lastAuditCheck &&
							lastExpiryDate != null &&
							blMap.get(bl).Last_Audit_Cycle_End_Date__c == lastExpiryDate
						) {
							continue;
						}

						 
						for (Audit_Detail__c ad : blMap.get(bl).Audit_Details__r) {
							if (ad.Current_Reporting_End_Date__c == null) {
								continue;
							}
							if (
								blMap.get(bl).RegulatoryAuthorizationType.IssuingDepartment.Name == 'Accountancy' &&
								ad.Current_Reporting_End_Date__c.Year() <= System.today().year() &&
								ad.Current_Reporting_End_Date__c.Year() > System.today().year() - 5
							) {
								ceAuditDetailsMap.put(ad.Current_Reporting_End_Date__c.format(),ad);
							} else if (ad.Current_Reporting_End_Date__c.Year() == blMap.get(bl).PeriodEnd.Year()) {
								isCEHoursEligible =
									minimumCeHours <= 0 ||
									(ad.Approved_CE_Hours__c != null &&
									ad.Approved_CE_Hours__c >= minimumCeHours);
								ceAuditDetailsMap.put(ad.Current_Reporting_End_Date__c.format(),ad);
							}
						}
					}

					if (auditType != CE_AUDIT_TYPE || isCEHoursEligible) {
						BusinessLicenseDataWrapper blData = new BusinessLicenseDataWrapper();
						blData.Id = bl;
						blData.Name = blMap.get(bl).Name;
						blData.PeriodStart = blMap.get(bl).PeriodStart;
						blData.PeriodEnd = blMap.get(bl).PeriodEnd;
						blData.auditDetailsMap = ceAuditDetailsMap;
						blData.selectedSubProfession = selectedSubProfession;
						blData.BlUrl = '/' + bl;
						blData.EntityName = blMap.get(bl).Business_Entity_Name__c;
						blDataList.add(blData);
					}
				}
			}

			return blDataList;
		} catch (Exception e) {
			LPI_ExceptionManager.logException('LPI_AuditRandomSelectorController', 'getFilteredLicenseRecords', e);
			throw new AuraHandledException(e.getMessage());
		}
	}

	/**
	 * @author                      : MTX Group Product Team
	 * @since                       : 11th Sep, 2023
	 * @description                 : Method to fetch the random records for audit
	 * @param                       : inputData String
	 * @param                       : auditSize Integer
	 * @return 	                    : List<BusinessLicenseDataWrapper>
	 * @last modified by            : MTX Group Product Team
	 * @last modified date          : (Add if modified by you)
	 * @last modified details       : (Add if modified by you)
	 */
	@AuraEnabled
	public static List<BusinessLicenseDataWrapper> getRandomRecords(String inputData, Integer auditSize) {
		try {
			List<BusinessLicenseDataWrapper> dataList = (List<BusinessLicenseDataWrapper>) System.JSON.deserializeStrict(
				inputData,
				List<BusinessLicenseDataWrapper>.class
			);
			return getRandomElements(dataList, auditSize);
		} catch (Exception e) {
			LPI_ExceptionManager.logException('LPI_AuditRandomSelectorController', 'getRandomRecords', e);
			throw new AuraHandledException(e.getMessage());
		}
	}

	/**
	 * @author                      : MTX Group Product Team
	 * @since                       : 15th Sep, 2023
	 * @description                 : Method to will call the batch class to create/update the Audit Details records
	 * @param                       : blListToAudit String
	 * @param                       : auditType String
	 * @param                       : noResponseNotificationPeriod Integer
	 * @param                       : reminderNotificationPeriod Integer
	 * @return 	                    : Boolean
	 * @last modified by            : MTX Group Product Team
	 * @last modified date          : (Add if modified by you)
	 * @last modified details       : (Add if modified by you)
	 */
	@AuraEnabled
	public static Boolean auditLicenses(
		String blListToAudit,
		String auditType,
		Integer noResponseNotificationPeriod,
		Integer reminderNotificationPeriod,
		String selectedAuditYear
	) {
		try {
			List<BusinessLicenseDataWrapper> dataList = (List<BusinessLicenseDataWrapper>) System.JSON.deserializeStrict(
				blListToAudit,
				List<BusinessLicenseDataWrapper>.class
			);
			if (!dataList.isEmpty()) {
				Database.executebatch(
					new LPI_AuditLicensesBatch(
						dataList,
						auditType,
						noResponseNotificationPeriod,
						reminderNotificationPeriod,
						UserInfo.getUserId(),
						selectedAuditYear
					)
				);
				return true;
			}
			return false;
		} catch (Exception e) {
			LPI_ExceptionManager.logException('LPI_AuditRandomSelectorController', 'auditLicenses', e);
			throw new AuraHandledException(e.getMessage());
		}
	}

	/**
	 * @author                      : MTX Group Product Team
	 * @since                       : 12th Sep, 2023
	 * @description                 : Random Element Generator
	 * @param  inputList            : List<BusinessLicenseDataWrapper>
	 * @param  n                    : Integer
	 * @return 	                    : List<BusinessLicenseDataWrapper>
	 * @last modified by            : MTX Group Product Team
	 * @last modified date          : (Add if modified by you)
	 * @last modified details       : (Add if modified by you)
	 */
	public static List<BusinessLicenseDataWrapper> getRandomElements(
		List<BusinessLicenseDataWrapper> inputList,
		Integer n
	) {
		List<BusinessLicenseDataWrapper> randomElements = new List<BusinessLicenseDataWrapper>();

		if (n >= inputList.size()) {
			return inputList;
		}

		List<BusinessLicenseDataWrapper> shuffledList = new List<BusinessLicenseDataWrapper>(inputList);
		for (Integer i = shuffledList.size() - 1; i > 0; i--) {
			Integer j = (Integer) Math.floor(Math.random() * (i + 1));
			BusinessLicenseDataWrapper temp = shuffledList[i];
			shuffledList[i] = shuffledList[j];
			shuffledList[j] = temp;
		}

		for (Integer i = 0; i < n; i++) {
			randomElements.add(shuffledList[i]);
		}

		return randomElements;
	}

	/**
	 * @author                      : MTX Group Product Team
	 * @since                       : 11th Sep, 2023
	 * @description                 : Method to get the Audit Type field picklist map
	 * @param  			            : None
	 * @return 	                    : Map<String, String>
	 * @last modified by            : MTX Group Product Team
	 * @last modified date          : (Add if modified by you)
	 * @last modified details       : (Add if modified by you)
	 */
	private static Map<String, String> getAuditTypeFieldPickListLabelValueMap() {
		Schema.SObjectType sObjectType = Schema.getGlobalDescribe().get('RegulatoryAuthority');
		Schema.DescribeSObjectResult sObjectData = sObjectType.getDescribe();
		Map<String, Schema.SObjectField> fields = sObjectData.fields.getMap();
		Map<String, String> valueToLabelMap = new Map<String, String>();
		for (Schema.PicklistEntry pickListVal : fields.get('Audit_Types__c').getDescribe().getPicklistValues()) {
			valueToLabelMap.put(pickListVal.getValue(), pickListVal.getLabel());
		}
		return valueToLabelMap;
	}

	private class SelectOption {
		@AuraEnabled
		public String label;
		@AuraEnabled
		public String value;

		private SelectOption(String label, String value) {
			this.label = label;
			this.value = value;
		}
	}

	public class BusinessLicenseDataWrapper {
		@AuraEnabled
		public String Id;
		@AuraEnabled
		public String Name;
		@AuraEnabled
		public String BlUrl;
		@AuraEnabled
		public Datetime PeriodStart;
		@AuraEnabled
		public Datetime PeriodEnd;
		@AuraEnabled
		public String EntityName;
		@AuraEnabled
		public Map<String,Audit_Detail__c> auditDetailsMap;
		@AuraEnabled
		public String selectedSubProfession;
		public BusinessLicenseDataWrapper() {
			this.Id = '';
			this.Name = '';
			this.BlUrl = '';
			this.EntityName = '';
			this.PeriodStart = Date.newInstance(0, 0, 0);
			this.PeriodEnd = Date.newInstance(0, 0, 0);
			this.auditDetailsMap = new Map<String,Audit_Detail__c>();
			this.selectedSubProfession = '';
		}
	}
	@testVisible
	private class AuditDataWrapper {
		@AuraEnabled
		public Decimal noResponseNotificationPeriod;
		@AuraEnabled
		public Decimal reminderNotificationPeriod;
		@AuraEnabled
		public List<SelectOption> auditTypes;
		 
		@AuraEnabled
		public String boardName;
		private AuditDataWrapper() {
			this.noResponseNotificationPeriod = 0;
			this.reminderNotificationPeriod = 0;
			this.auditTypes = new List<SelectOption>();
			this.boardName = '';
		}
	}
}