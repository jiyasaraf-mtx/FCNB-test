/**
 * @author          : MTX Group Product Team
 * @description     : This Batch is created to insert the Audit_Detail__c records
 * @since           : 14 Sep, 2023
 * -------------------------------------------------------------------------------------------------------
 * Version      Date                Author                  Details
 *    1         14 Sep, 2023        MTX Group Product Team        Initial Development
 * -------------------------------------------------------------------------------------------------------
 */
public with sharing class LPI_AuditLicensesBatch implements Database.Batchable<LPI_AuditRandomSelectorController.BusinessLicenseDataWrapper>, Database.Stateful {
	private List<LPI_AuditRandomSelectorController.BusinessLicenseDataWrapper> blListToAudit;
	List<Notification__c> notificationsInserted = new List<Notification__c>();
	private static final String IN_PROGRESS_STATUS = 'In Progress';
	private static final String ACCOUNTANCY = 'Accountancy';
	private Integer noResponseNotificationPeriod;
	private Integer reminderNotificationPeriod;
	private Id auditRecordTypeId;
	private Id inspectorId;
	private List<Date> selectedAuditCycles;

	public LPI_AuditLicensesBatch(
		List<LPI_AuditRandomSelectorController.BusinessLicenseDataWrapper> blListToAudit,
		String auditType,
		Integer noResponseNotificationPeriod,
		Integer reminderNotificationPeriod,
		Id inspectorId,
		String selectedAuditYear
	) {
		this.auditRecordTypeId = Schema.SObjectType.Audit_Detail__c.getRecordTypeInfosByDeveloperName()
			.get(auditType)
			.getRecordTypeId();
		this.noResponseNotificationPeriod = noResponseNotificationPeriod;
		this.reminderNotificationPeriod = reminderNotificationPeriod;
		this.blListToAudit = blListToAudit;
		this.inspectorId = inspectorId;
		this.selectedAuditCycles = new List<Date>();
		if (String.isNotBlank(selectedAuditYear)) {
			for (String selectedYear : selectedAuditYear.split(',')) {
				this.selectedAuditCycles.add(Date.newInstance(Integer.valueOf(selectedYear), 12, 31));
			}
		}
	}

	// Start method
	public List<LPI_AuditRandomSelectorController.BusinessLicenseDataWrapper> start(Database.BatchableContext bc) {
		return this.blListToAudit;
	}

	// Execute method to process records
	public void execute(
		Database.BatchableContext bc,
		List<LPI_AuditRandomSelectorController.BusinessLicenseDataWrapper> blBatchList
	) {
		try {
			Set<Id> blIdSet = new Set<Id>();
			for (LPI_AuditRandomSelectorController.BusinessLicenseDataWrapper blData : blBatchList) {
				blIdSet.add(blData.Id);
			}

			String queryFields =
				'Id,PeriodStart,PeriodEnd,RegulatoryAuthorizationType.Renewal_Window_Period_Before_Expiry__c,' +
				'RegulatoryAuthorizationType.Expiry_Rule_Type__c,RegulatoryAuthorizationType.Expiration_Cycle__c,' +
				'RegulatoryAuthorizationType.Expiration_Fixed_Cycle_Difference__c,RegulatoryAuthorizationType.Expiration_Period__c,' +
				'RegulatoryAuthorizationType.Expiration_Day__c,RegulatoryAuthorizationType.Expiration_Month__c,' +
				'RegulatoryAuthorizationType.Open_for_Renewal__c,RegulatoryAuthorizationType.Late_Renewal_Allowed__c,' +
				'RegulatoryAuthorizationType.Extended_Expiry_Period__c,RegulatoryAuthorizationType.IssuingDepartment.Name,' +
				'RegulatoryAuthorizationType.Subsequent_Reinstatement_Period__c,Reinstatement_Count__c,RegulatoryAuthorizationType.Name';
			String whereClause = 'Id IN ' + LPI_ServiceUtility.getStringValuesBySet(blIdSet);
			LPI_BusinessLicenseDAO.LPI_BusinessLicenseWithoutSharingDAO blDaoRec = new LPI_BusinessLicenseDAO.LPI_BusinessLicenseWithoutSharingDAO();
			Map<Id, BusinessLicense> blMap = new Map<Id, BusinessLicense>(
				blDaoRec.getBusinessLicenseByDymanicQuery(queryFields, whereClause, null, null, null)
			);
			System.debug('BL MAP>>>>'+blMap);
			List<Audit_Detail__c> auditRecordListToUpdate = new List<Audit_Detail__c>();
			List<Audit_Detail__c> auditRecordListToInsert = new List<Audit_Detail__c>();

			//Iterate over the selected Licenses for Random Audits
			for (LPI_AuditRandomSelectorController.BusinessLicenseDataWrapper blData : blBatchList) {
				BusinessLicense bl = blMap.get(blData.Id);
				if (bl.RegulatoryAuthorizationType.IssuingDepartment.Name != ACCOUNTANCY) {
					this.selectedAuditCycles.clear();
					if(blData.PeriodEnd != null){
						this.selectedAuditCycles.add(
							Date.newInstance(blData.PeriodEnd.year(), blData.PeriodEnd.month(), blData.PeriodEnd.day())
						);
					}
				}
				for (Date selectedAuditDate : this.selectedAuditCycles) {
					Audit_Detail__c auditRecord = new Audit_Detail__c();
					Boolean auditRecordPresent = false;
					if (blData.auditDetailsMap.containsKey(selectedAuditDate.format())) {
						auditRecord.Id = blData.auditDetailsMap.get(selectedAuditDate.format()).Id;
						auditRecordPresent = true;
					}
					if (!auditRecordPresent) {
						auditRecord.Business_License__c = blData.Id;
						auditRecord.RecordTypeId = this.auditRecordTypeId;
						auditRecord.Current_Reporting_End_Date__c = selectedAuditDate;
						auditRecord.Current_Reporting_Start_Date__c = bl.RegulatoryAuthorizationType.IssuingDepartment.Name ==
							ACCOUNTANCY
							? Date.newInstance(selectedAuditDate.year(), 1, 1)
							: (Date) LPI_DocumentConfigGeneratorUtil.calculateExpiryRelatedDates(bl)
									.get('CurrentRenewCycleStartDate');
					}
					auditRecord.Audit_Start_Date__c = Date.today();
					auditRecord.Status__c = IN_PROGRESS_STATUS;
					auditRecord.Initial_Notification_Date__c = auditRecord.Audit_Start_Date__c;
					auditRecord.Subprofession__c = blData.selectedSubProfession;
					auditRecord.Reminder_Notification_Date__c = this.reminderNotificationPeriod == 0
						? null
						: auditRecord.Audit_Start_Date__c.addDays(this.reminderNotificationPeriod);
					auditRecord.No_Response_Notification_Date__c = this.noResponseNotificationPeriod == 0
						? null
						: auditRecord.Audit_Start_Date__c.addDays(this.noResponseNotificationPeriod);
					auditRecord.Inspector__c = this.inspectorId;

					if (auditRecord.Id == null) {
						auditRecordListToInsert.add(auditRecord);
					} else {
						auditRecordListToUpdate.add(auditRecord);
					}
				}
			}
			List<SObject> insertedUpdatedRecords = new List<SObject>();
			Set<Id> insertedUpdatedIds = new Set<Id>();
			if (!auditRecordListToInsert.isEmpty()) {
				insertedUpdatedRecords.addAll(LPI_DML.doInsert(auditRecordListToInsert));
			}
			if (!auditRecordListToUpdate.isEmpty()) {
				insertedUpdatedRecords.addAll(LPI_DML.doUpdate(auditRecordListToUpdate));
			}
			for (SObject audRec : insertedUpdatedRecords) {
				if (audRec.get('Id') != null) {
					insertedUpdatedIds.add((Id) audRec.get('Id'));
				}
			}
			if (!insertedUpdatedIds.isEmpty()) {
				notificationsInserted = LPI_AuditDetailTriggerHelper.handleAuditEmailNotification(
					insertedUpdatedIds,
					false
				);
			}
		} catch (Exception ex) {
			LPI_ExceptionManager.logException('LPI_AuditLicensesBatch', 'execute', ex);
			throw new AuraHandledException(ex.getMessage());
		}
	}

	// Finish method
	public void finish(Database.BatchableContext bc) {
		// Database.executebatch(new LPI_NotifEmailTriggerBatch(notificationsInserted), 100);
	}
}