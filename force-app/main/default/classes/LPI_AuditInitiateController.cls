/**
 * @author              : Sarabjeet Singh
 * @since               : 08th Feb, 2024
 * @description         : This class is used to Create Audit from the Bussiness Licenses.
 * @history
 * -------------------------------------------------------------------------------------------------------
 * Version      Date                Author                  Details
 *    1         8th Feb, 2024       Sarabjeet Singh       Initial Developement
 * -------------------------------------------------------------------------------------------------------
 */
public with sharing class LPI_AuditInitiateController {
	private static final String FINANCIAL_AUDIT_TYPE = 'Financial Audit';
	private static final String CE_AUDIT_TYPE = 'CE_Audit';
	private static final String MTAA = 'MTAA';
	private static final String INSURANCE_CONSULTANT = 'Insurance Consultant';
	private static final String MTAA_INSURANCE_CONSULTANT = 'MTAA + Insurance Consultant';
	private static final Set<String> INDIVIDUAL_AUDIT_SET = new Set<String>{
		'CE_Audit',
		'Insurance_Audit',
		'Certification_Audit'
	};
	private static final String INDIVIDUAL_LICENSE_TYPE = 'Individual';

	/**
	 * @author                      : Sarabjeet Singh
	 * @since                       : 8th Feb, 2023
	 * @description                 : Method to will fetch required Board [Regulatory Authority] data.
	 * @param                       : issuingDepartmentId [Regulatory Authority Id]
	 * @return                         : AuditDataWrapper
	 * @last modified by            : ChangeMeIn@UserSettingsUnder.SFDoc
	 * @last modified date          : (Add if modified by you)
	 * @last modified details       : (Add if modified by you)
	 */
	@AuraEnabled
	public static AuditDataWrapper fetchAuditData(String licenseId) {
		List<SelectOption> options = new List<SelectOption>();
		try {
			List<BusinessLicense> blList = LPI_BusinessLicenseDAO.fetchBusinessLicenseRecords(
				'Name,RegulatoryAuthorizationType.IssuingDepartment.Audit_Types__c,' +
					'RegulatoryAuthorizationType.IssuingDepartment.Reminder_Notification_Period__c,' +
					'RegulatoryAuthorizationType.IssuingDepartment.No_Response_Notification_Period__c,' +
					'RegulatoryAuthorizationType.IssuingDepartment.name,RegulatoryAuthorizationType.name,RegulatoryAuthorizationType.Authorisation_Type__c',
				'Id = \'' + String.escapeSingleQuotes(licenseId) + '\''
			);
			if (!blList.isEmpty()) {
				if (blList[0].RegulatoryAuthorizationType.IssuingDepartment.Audit_Types__c != null) {
					Map<String, String> auditTypePicklictValueMap = getAuditTypeFieldPickListLabelValueMap();
					for (
						String auditType : blList[0]
							.RegulatoryAuthorizationType.IssuingDepartment.Audit_Types__c.split(';')
					) {
						if (
							!INDIVIDUAL_AUDIT_SET.contains(auditType) ||
							blList[0].RegulatoryAuthorizationType.Authorisation_Type__c == INDIVIDUAL_LICENSE_TYPE
						) {
							String label = auditTypePicklictValueMap.get(auditType);
							options.add(new SelectOption(label, auditType));
						}
					}
				}
				AuditDataWrapper auditData = new AuditDataWrapper();
				auditData.boardName = blList[0]?.RegulatoryAuthorizationType?.IssuingDepartment.Name;
				auditData.noResponseNotificationPeriod = blList[0]
						?.RegulatoryAuthorizationType
						?.IssuingDepartment.No_Response_Notification_Period__c == null
					? 0
					: blList[0]?.RegulatoryAuthorizationType?.IssuingDepartment.No_Response_Notification_Period__c;
				auditData.reminderNotificationPeriod = blList[0]
						?.RegulatoryAuthorizationType
						?.IssuingDepartment.Reminder_Notification_Period__c == null
					? 0
					: blList[0]?.RegulatoryAuthorizationType?.IssuingDepartment.Reminder_Notification_Period__c;
				auditData.blId = blList[0].Id;
				auditData.auditTypes.addAll(options);
				return auditData;
			}
			return null;
		} catch (Exception e) {
			LPI_ExceptionManager.logException('LPI_AuditInitiateController', 'fetchAuditData', e);
			throw new AuraHandledException(e.getMessage());
		}
	}

	/**
	 * @author                      : Sarabjeet Singh
	 * @since                       : 8th Feb, 2023
	 * @description                 : Method to Save Audit Record
	 * @param                       : param received
	 * @return                      : AuditResultsWrapper
	 * @last modified by            : ChangeMeIn@UserSettingsUnder.SFDoc
	 * @last modified date          : (Add if modified by you)
	 * @last modified details       : (Add if modified by you)
	 */
	@AuraEnabled
	public static AuditResultsWrapper saveAuditData(
		String auditData,
		String auditType,
		String subProfession,
		String selectedYear
	) {
		try {
			String queryFields;
			String whereClause;
			Date startDate;
			List<BusinessLicense> blList = new List<BusinessLicense>();
			List<Audit_Detail__c> adtList = new List<Audit_Detail__c>();
			Audit_Detail__c atDetail = new Audit_Detail__c();
			Set<Id> auditIdSet = new Set<Id>();
			Audit_Detail__c audDetail = new Audit_Detail__c();
			String auditRecordTypeId = Schema.SObjectType.Audit_Detail__c.getRecordTypeInfosByDeveloperName()
				.get(auditType)
				.getRecordTypeId();

			queryFields = 'Id,Current_Reporting_Start_Date__c,Current_Reporting_End_Date__c';
			whereClause = 'Current_Reporting_Start_Date__c = ' + 'Current_Reporting_End_Date__c = ';

			AuditDataWrapper dataList = (AuditDataWrapper) System.JSON.deserializeStrict(auditData, AuditDataWrapper.class);
			AuditResultsWrapper auditResultList = new AuditResultsWrapper();

			queryFields =
				'Id,PeriodStart,PeriodEnd,RegulatoryAuthorizationType.Renewal_Window_Period_Before_Expiry__c,' +
				'RegulatoryAuthorizationType.Expiry_Rule_Type__c,RegulatoryAuthorizationType.Expiration_Cycle__c,' +
				'RegulatoryAuthorizationType.Expiration_Fixed_Cycle_Difference__c,RegulatoryAuthorizationType.Expiration_Period__c,' +
				'RegulatoryAuthorizationType.Expiration_Day__c,RegulatoryAuthorizationType.Expiration_Month__c,' +
				'RegulatoryAuthorizationType.Open_for_Renewal__c,RegulatoryAuthorizationType.Late_Renewal_Allowed__c,' +
				'RegulatoryAuthorizationType.Extended_Expiry_Period__c,RegulatoryAuthorizationType.Name,' +
				'RegulatoryAuthorizationType.Subsequent_Reinstatement_Period__c,Reinstatement_Count__c';

			whereClause = 'Id = \'' + dataList.blId + '\'';

			blList = LPI_BusinessLicenseDAO.fetchBusinessLicenseRecords(queryFields, whereClause);
			if (blList.size() > 0) {
				startDate = (Date) LPI_DocumentConfigGeneratorUtil.calculateExpiryRelatedDates(blList[0])
					.get('CurrentRenewCycleStartDate');
				atDetail.Current_Reporting_Start_Date__c = String.isNotBlank(selectedYear)
					? Date.newInstance(Integer.valueOf(selectedYear), 1, 1)
					: startDate;
				atDetail.Current_Reporting_End_Date__c = String.isNotBlank(selectedYear)
					? Date.newInstance(Integer.valueOf(selectedYear), 12, 31)
					: Date.valueOf(blList[0].periodEnd);

				if (auditType == CE_AUDIT_TYPE) {
					String fields = 'Id,Current_Reporting_Start_Date__c,Current_Reporting_End_Date__c,Status__c';
					String whereCon =
						'Current_Reporting_Start_Date__c = ' +
						String.valueOf(atDetail.Current_Reporting_Start_Date__c) +
						' AND Current_Reporting_End_Date__c = ' +
						String.valueOf(atDetail.Current_Reporting_End_Date__c) +
						' AND Business_License__c = \'' +
						dataList.blId +
						'\' AND RecordTypeId = \'' +
						auditRecordTypeId +
						'\'';
					adtList = LPI_AuditDetailsDAO.getAuditDetailsByDymanicQuery(fields, whereCon, null, null, null);
					if (adtList.size() > 0) {
						if (adtList[0].Status__c != 'In Progress') {
							adtList[0].Status__c = 'In Progress';
							audDetail = (Audit_Detail__c) LPI_DML.doUpdate(adtList[0]);
						} else {
							auditResultList.resultFound = true;
						}
						auditResultList.auditId = adtList[0].Id;
						return auditResultList;
					}
				}
			}
			atDetail.Audit_End_Date__c = Date.today() + (Integer) dataList.noResponseNotificationPeriod;
			atDetail.Audit_Start_Date__c = Date.today();
			atDetail.Business_License__c = dataList.blId;
			atDetail.Initial_Notification_Date__c = Date.today();
			atDetail.Inspector__c = UserInfo.getUserId();
			atDetail.No_Response_Notification_Date__c = Date.today() + (Integer) dataList.noResponseNotificationPeriod;
			atDetail.RecordTypeId = auditRecordTypeId;
			atDetail.Reminder_Notification_Date__c = Date.today() + (Integer) dataList.reminderNotificationPeriod;
			atDetail.Status__c = 'In Progress';
			atDetail.Subprofession__c = subProfession;
			audDetail = (Audit_Detail__c) LPI_DML.doInsert(atDetail);
			auditResultList.auditId = audDetail.Id;
			if (String.isNotBlank(audDetail.Id)) {
				auditIdSet.add(audDetail.Id);
				List<Notification__c> notificationsInserted = LPI_AuditDetailTriggerHelper.handleAuditEmailNotification(
					auditIdSet,
					false
				);
			}
			return auditResultList;
		} catch (Exception e) {
			LPI_ExceptionManager.logException('LPI_AuditInitiateController', 'saveAuditData', e);
			throw new AuraHandledException(e.getMessage());
		}
	}

	/**
	 * @author                      : Sarabjeet Singh
	 * @since                       : 8th Feb, 2023
	 * @description                 : Method to get the Audit Type field picklist map
	 * @param                       : None
	 * @return                      : Map<String, String>
	 * @last modified by            : ChangeMeIn@UserSettingsUnder.SFDoc
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

	@TestVisible
	private class SelectOption {
		@AuraEnabled
		public String label;
		@AuraEnabled
		public String value;

		@TestVisible
		private SelectOption(String label, String value) {
			this.label = label;
			this.value = value;
		}
	}

	@TestVisible
	private class AuditDataWrapper {
		@AuraEnabled
		public Decimal noResponseNotificationPeriod;
		@AuraEnabled
		public Decimal reminderNotificationPeriod;
		@AuraEnabled
		public List<SelectOption> auditTypes;
		@AuraEnabled
		public String boardName;
		@AuraEnabled
		public Boolean showSubProfession;
		@AuraEnabled
		public String blId;

		@TestVisible
		private AuditDataWrapper() {
			this.noResponseNotificationPeriod = 0;
			this.reminderNotificationPeriod = 0;
			this.auditTypes = new List<SelectOption>();
			this.boardName = '';
			this.showSubProfession = false;
		}
	}
	@TestVisible
	private class AuditResultsWrapper {
		@AuraEnabled
		public String auditId;
		@AuraEnabled
		public Boolean resultFound;

		@TestVisible
		private AuditResultsWrapper() {
			this.resultFound = false;
		}
	}
}