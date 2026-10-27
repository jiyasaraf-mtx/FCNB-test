/**
 * @author      : MTX Group Product Team
 * @since       : 12 Sep, 2023
 * @description : This Class is a Helper class for LPI_AuditDetailTriggerHandler

 */
public with sharing class LPI_AuditDetailTriggerHelper {
	private static final String IN_PROGRESS_STATUS = 'In Progress';
	private static final String ADDITIONAL_INFO_STATUS = 'Additional Info Needed';
	private static final String PASS_STATUS = 'Pass';
	private static final String FAIL_STATUS = 'Fail';
	private static final String CHIROPRACTIC_EXAMINERS = 'Chiropractic Examiners';
	private static final Set<String> AUDIT_STATUS_SET = new Set<String>{ 'Additional Info Needed' };
	private static final Set<String> AUDIT_RESULT_SET = new Set<String>{ 'Fail, Fail with Grace and Cure, Pass with Grace and Cure, Fail with Cure' };
	private static final String LOCATION_TYPE_MAILING = 'Mailing';
	private static final String OBJECT_NAME = 'Audit_Detail__c';
	private static final String FINANCIAL_RECORD_TYPE = 'Financial Audit';
	public static final Set<String> RESULT_PASS_EMAIL_SET = new Set<String>{'CE_Resp_Care_Audit_Complete'};
    public static final String RESULT_PASS_EMAIL = 'CE_Resp_Care_Audit_Complete';
	public static final Set<String> RESULT_FAIL_EMAIL_SET = new Set<String>{'CE_Martial_Family_Non_Compliance'};
    public static final String RESULT_FAIL_EMAIL = 'CE_Martial_Family_Non_Compliance';
	public static final Set<String> ADDITIONAL_INFO_EMAIL_SET = new Set<String>{'CE_Hearing_Instrument_Audit_Info_Needed'};
    public static final String ADDITIONAL_INFO_EMAIL = 'CE_Hearing_Instrument_Audit_Info_Needed';
	public static final Set<String> IN_PROGRESS_EMAIL_SET = new Set<String>{'Accountancy_CE_Audit_Initial_Email'};
    public static final String IN_PROGRESS_EMAIL = 'Accountancy_CE_Audit_Initial_Email';



	/**
	 * @author                      : MTX Group Product Team
	 * @since                       : 12 Sep, 2023
	 * @description                 : This method will be send the email notification if audit record status is assigned.
	 * @param recordsList           : The list of audit detail records.
	 * @param mapOfOldRecords       : The map of old audit detail records.
	 * @return void
	 * @last modified by            : MTX Group Product Team
	 * @last modified date          : (Add if modified by you)
	 * @last modified details       : (Add if modified by you)
	 */
	public static void sendAuditlNotifications(
		List<Audit_Detail__c> recordsList,
		Map<Id, Audit_Detail__c> mapOfOldRecords
	) {
		try {
			List<Audit_Detail__c> auditRecordResultIds = new List<Audit_Detail__c>();
			List<Audit_Detail__c> auditRecordIds = new List<Audit_Detail__c>();
			List<Audit_Detail__c> auditResultChangeRecordIds = new List<Audit_Detail__c>();
			 
			for (Audit_Detail__c auditRecord : recordsList) {
				if (
					(
					(mapOfOldRecords != null &&
					mapOfOldRecords.get(auditRecord.Id).Status__c != auditRecord.Status__c)) &&
					auditRecord.Business_License__c != null &&
					!String.isBlank(auditRecord.Status__c) &&
					auditRecord.Status__c == IN_PROGRESS_STATUS
				) {
					auditRecordIds.add(auditRecord);
				}
				if (
					(
					(mapOfOldRecords != null &&
					mapOfOldRecords.get(auditRecord.Id).Status__c != auditRecord.Status__c)) &&
					auditRecord.Business_License__c != null &&
					!String.isBlank(auditRecord.Status__c) &&
					(auditRecord.Status__c == ADDITIONAL_INFO_STATUS || auditRecord.Status__c == IN_PROGRESS_STATUS)
				) {
					auditRecordIds.add(auditRecord);
				}
				 
			
            if (
				    (
					(mapOfOldRecords != null &&
					mapOfOldRecords.get(auditRecord.Id).Audit_Result__c != auditRecord.Audit_Result__c)) &&
					auditRecord.Business_License__c != null &&
					!String.isBlank(auditRecord.Audit_Result__c) && 
					(auditRecord.Audit_Result__c == PASS_STATUS || auditRecord.Audit_Result__c == FAIL_STATUS)
				) {
					auditRecordResultIds.add(auditRecord);
				}
			}
			if(!auditRecordIds.isEmpty()){
				createNotifications(auditRecordIds,false);
			}
			if(!auditRecordResultIds.isEmpty()){
				createNotifications(auditRecordResultIds,true);
			}
			 
		} catch (Exception ex) {
			LPI_ExceptionManager.logException('LPI_AuditDetailTriggerHelper', 'sendAuditlNotifications', ex);
			throw new AuraHandledException(ex.getMessage());
		}
	}

     /**
	 * @author                      : MTX Group Product Team
	 * @since                       : 20 May 2024
	 * @description                 : This method handles the email notifications for audit records.
	 * @param auditRecordIds        : A List of ids representing the audit records.
	 * @return notificationsInserted: A list of Notification__c records that were inserted.
	 * @last modified by            : MTX Group Product Team
	 * @last modified date          : (Add if modified by you)
	 * @last modified details       : (Add if modified by you)
	 */  
	public static void createNotifications(List<Audit_Detail__c> recordsList,Boolean doResultChange){
		try{
			String mdtDeveloperName;
            Set<Id> adIdSet = new Set<Id>();
            Map<String, String> replaceTextMap = new Map<String, String>();
            Map<String, String> devNameToTemplateNameMap = new Map<String, String>();
            Map<String,String> devNameToEmailBody = new Map<String,String>();
            Map<String,String> devNameToEmailSubject = new Map<String,String>();
            List<Notification_Message__mdt> notificationMessageList = new List<Notification_Message__mdt>();
            List<LPI_Wrapper.NotificationEmailWrapper> notificationEmailWrapperList = new List<LPI_Wrapper.NotificationEmailWrapper>();
            Set<Id> businessIds = new Set<Id>();
            
			for (Audit_Detail__c record : recordsList) {
                adIdSet.add(record.Id);
				businessIds.add(record.Business_License__c);
            }
            
            if (!adIdSet.isEmpty()) {
                String querryFields =
				'Id,Name,Licensee_Name__c,Business_License__r.Account.Name,Business_License__r.Account.PersonEmail,Business_License__r.AccountId,Business_License__r.Contact.AccountId,Status__c,RecordType.Name,Approved_CE_Hours__c,No_Response_Notification_Date__c,Business_License__r.RegulatoryAuthorizationType.Email_Specifications_Final__c,' +
				'Current_Reporting_Start_Date__c,Current_Reporting_End_Date__c, Comments__c, RecordType.DeveloperName, Board_Name__c, Current_Reporting_Start_Year__c, Current_Reporting_End_Year__c, Business_License__r.Name, Include_Comments_in_the_Email__c,Approved_NABP_CE_Hours__c,Reminder_Notification_Date__c,' +
				'Business_License__r.Account.PersonMailingStreet,Business_License__r.Account.PersonMailingCity,Business_License__r.Account.PersonMailingState,Business_License__r.Account.PersonMailingPostalCode,Business_License__r.Regulatory_Authorization_Type_Name__c,Initial_Notification_Date__c,Subprofession__c,Business_License__c,Audit_Result__c';
                String whereClauseToQuery = 'Id IN ' + LPI_ServiceUtility.getStringValuesBySet(adIdSet);
                for (Audit_Detail__c record : LPI_AuditDetailsDAO.getAuditDetailsByDymanicQuery(
					querryFields,
					whereClauseToQuery,
					null,
					null,
					null
				)){
                     
                    String emailBody;
					String Subject;
                    Map<Id, Schema.Address> addressMap = new Map<Id, Schema.Address>();
			       if(!businessIds.isEmpty()){
				   addressMap = LPI_ServiceUtility.getBusinessAddresses(businessIds,LOCATION_TYPE_MAILING);
			      }

				  String currentRenewalPeriod = (record.Current_Reporting_Start_Year__c != null &&
					            record.Current_Reporting_End_Year__c != null)
								? record.Current_Reporting_Start_Year__c +
								  '-' +
								  record.Current_Reporting_End_Year__c
								: '';
					String city = '';
					String state = '';
					String zip = '';
					String street = '';
					if (!addressMap.isEmpty() && addressMap.containsKey(record.Business_License__r.Id)) {
							Schema.Address address = addressMap.get(record.Business_License__r.Id);
							city = address.City != null ? address.City : '';
							state = address.State != null ? address.State : '';
							zip = address.PostalCode != null ? address.PostalCode : '';
							street = address.Street != null ? address.Street : '';
					}

					if( doResultChange == true){
                    if (record.Audit_Result__c == PASS_STATUS) {
                        mdtDeveloperName = RESULT_PASS_EMAIL;
                        notificationMessageList = LPI_CustomMetadataTypeDAO.getAllNotificationByDeveloperNames(RESULT_PASS_EMAIL_SET);
                        replaceTextMap = new Map<String, String> {
                            'Licensee_Name' => record.Licensee_Name__c,
                            'Board' => record.Board_Name__c
                        };
                    }
  
					
					if(record.Audit_Result__c == FAIL_STATUS){
   						mdtDeveloperName = RESULT_FAIL_EMAIL;
                        notificationMessageList = LPI_CustomMetadataTypeDAO.getAllNotificationByDeveloperNames(RESULT_FAIL_EMAIL_SET);
                        replaceTextMap = new Map<String, String> {
                            'Licensee_Name' => record.Licensee_Name__c,
							'Current_Renewal_Period' => currentRenewalPeriod,
							'Contact Email' => record.Business_License__r.Account.PersonEmail,
							 
							'Address' => Street+','+City+','+state+','+zip
							 

				         };
					}
				    }
					if(doResultChange == false){
					if (record.Status__c == ADDITIONAL_INFO_STATUS) {
                        mdtDeveloperName = ADDITIONAL_INFO_EMAIL;
                        notificationMessageList = LPI_CustomMetadataTypeDAO.getAllNotificationByDeveloperNames(ADDITIONAL_INFO_EMAIL_SET);
                        replaceTextMap = new Map<String, String> {
                            'Licensee_Name' => record.Licensee_Name__c,
                            'No_Response_Date' => getFormatedDate(record.No_Response_Notification_Date__c)
                        };
                    }
					if (record.Status__c == IN_PROGRESS_STATUS) {
                        mdtDeveloperName = IN_PROGRESS_EMAIL;
                        notificationMessageList = LPI_CustomMetadataTypeDAO.getAllNotificationByDeveloperNames(IN_PROGRESS_EMAIL_SET);
                        replaceTextMap = new Map<String, String> {
                            'Licensee_Name' => record.Licensee_Name__c,
                            'Current_Renewal_Period' => currentRenewalPeriod,
							'Current_Reporting_Start_Date' => getFormatedDate(record.Current_Reporting_Start_Date__c),
							'Current_Reporting_End_Date' => getFormatedDate(record.Current_Reporting_End_Date__c),
							'No_Response_Date' => getFormatedDate(record.No_Response_Notification_Date__c)
							 
                        };
                    }
				   }  
                    for (Notification_Message__mdt noti : notificationMessageList) {
                        devNameToTemplateNameMap.put(noti.DeveloperName, noti.Template_Name__c);
                        devNameToEmailBody.put(noti.DeveloperName, noti.Description__c);
                        devNameToEmailSubject.put(noti.DeveloperName, noti.Title__c);
                    }

                    emailBody = devNameToEmailBody.get(mdtDeveloperName);
					Subject = devNameToEmailSubject.get(mdtDeveloperName);

                    if (replaceTextMap != null) {
                        for (String key : replaceTextMap.keySet()) {
                            emailBody = emailBody.replaceAll('\\[' + key + '\\]', replaceTextMap.get(key));
							 
							
                        }
                    }

                    LPI_Wrapper.NotificationEmailWrapper notifcationWrapper = new LPI_Wrapper.NotificationEmailWrapper();
                    notifcationWrapper.templateName = devNameToTemplateNameMap.get(mdtDeveloperName);
                    
                    LPI_Wrapper.NotificationEmailWrapper notifcationWrapperApprove = new LPI_Wrapper.NotificationEmailWrapper();
                    notifcationWrapperApprove.templateName = devNameToTemplateNameMap.get(mdtDeveloperName);
                    notifcationWrapperApprove.subject = Subject;
                    notifcationWrapperApprove.replaceTextMap = replaceTextMap;
                   
                    notifcationWrapperApprove.recipientEmail = record.Business_License__r.Account.PersonEmail;
                    notifcationWrapperApprove.description = emailBody;
                    notifcationWrapperApprove.blId = record.Business_License__c;
                    notificationEmailWrapperList.add(notifcationWrapperApprove);
                }
            }
            if (!notificationEmailWrapperList.isEmpty()) {
                LPI_ServiceUtility.createNotificationRecords(
                    notificationEmailWrapperList
                );
            }
		}
		catch (Exception ex) {
			LPI_ExceptionManager.logException('LPI_AuditDetailTriggerHelper', 'createNotifications', ex);
			throw new AuraHandledException(ex.getMessage());
		}
	}





	/**
	 * @author                      : MTX Group Product Team
	 * @since                       : 23 Sep 2023
	 * @description                 : This method handles the email notifications for audit records.
	 * @param auditRecordIds        : A set of Ids representing the audit records.
	 * @return notificationsInserted: A list of Notification__c records that were inserted.
	 * @last modified by            : MTX Group Product Team
	 * @last modified date          : (Add if modified by you)
	 * @last modified details       : (Add if modified by you)
	 */
	public static List<Notification__c> handleAuditEmailNotification(Set<Id> auditRecordIds,Boolean doResultChange) {
		List<Notification__c> notificationsInserted = new List<Notification__c>();
		Map<String, Notification_Message__mdt> devNameToEmailNotifRecMap = new Map<String, Notification_Message__mdt>();
		if (!auditRecordIds.isEmpty()) {
			List<Audit_Detail__c> auditList = new List<Audit_Detail__c>();
			Map<String, Notification_Message__mdt> uniqueKeyToMetaDataMap = new Map<String, Notification_Message__mdt>();
			String querryFields =
				'Id,Name,Business_License__r.Account.Name,Business_License__r.Account.PersonEmail,Business_License__r.AccountId,Business_License__r.Contact.AccountId,Status__c,RecordType.Name,Approved_CE_Hours__c,No_Response_Notification_Date__c,Business_License__r.RegulatoryAuthorizationType.Email_Specifications_Final__c,' +
				'Current_Reporting_Start_Date__c,Current_Reporting_End_Date__c, Comments__c, RecordType.DeveloperName, Board_Name__c, Current_Reporting_Start_Year__c, Current_Reporting_End_Year__c, Business_License__r.Name, Include_Comments_in_the_Email__c,Approved_NABP_CE_Hours__c,Reminder_Notification_Date__c,' +
				'Business_License__r.Account.PersonMailingStreet,Business_License__r.Account.PersonMailingCity,Business_License__r.Account.PersonMailingState,Business_License__r.Account.PersonMailingPostalCode,Business_License__r.Regulatory_Authorization_Type_Name__c,Initial_Notification_Date__c,Subprofession__c,Business_License__c,Audit_Result__c';
			String whereClause = 'Id IN ' + LPI_ServiceUtility.getStringValuesBySet(auditRecordIds);
			Set<String> boardNameSet = new Set<String>();
			Set<String> auditTypeSet = new Set<String>();
			Set<String> auditStatusSet = new Set<String>();
			Set<String> ratSet = new Set<String>();
			Set<Id> businessIds = new Set<Id>();
			List<LPI_Wrapper.NotificationEmailWrapper> notificationEmailWrapperList = new List<LPI_Wrapper.NotificationEmailWrapper>();
			List<Notification__c> portalNotificationToInsert = new List<Notification__c>();
			List<String> uniqueList = new List<String>();
			uniqueList.add('AuditPortalNotification');
			Map<String, Portal_Notification_Message__mdt> portalNotificationMessageMap = LPI_ServiceUtility.fetchPortalNotificationMetaDataRecord(
				null,
				null,
				null,
				uniqueList
			);
			auditList = LPI_AuditDetailsDAO.getAuditDetailsByDymanicQuery(
				querryFields,
				whereClause,
				null,
				null,
				null
			);
			for (Audit_Detail__c auditRecord : auditList) {
				Decimal totalApprovedCeHours = (auditRecord.Approved_CE_Hours__c == null ? 0 : auditRecord.Approved_CE_Hours__c) 
					+ (auditRecord.Approved_NABP_CE_Hours__c == null ? 0 : auditRecord.Approved_NABP_CE_Hours__c);
				boardNameSet.add(auditRecord.Board_Name__c);
				auditTypeSet.add(auditRecord.RecordType.DeveloperName);
				if(doResultChange){
					auditStatusSet.add(auditRecord.Audit_Result__c);
				}else{
					auditStatusSet.add(auditRecord.Status__c);
				}
				businessIds.add(auditRecord.Business_License__r.Id);
			}
			Map<Id, Schema.Address> addressMap = new Map<Id, Schema.Address>();
			if(!businessIds.isEmpty()){
				addressMap = LPI_ServiceUtility.getBusinessAddresses(businessIds,LOCATION_TYPE_MAILING);
			}

			if (!boardNameSet.isEmpty() && !auditTypeSet.isEmpty() && !auditStatusSet.isEmpty()) {
				querryFields = 'Id,Template_Name__c,Email_CC_Addresses__c,Unique_Filter__c,Board_Name__c,Audit_Type__c,Audit_Status__c,Regulatory_Authorization_Type_Name__c,Subprofession__c';
				whereClause =
					 
					'Audit_Type__c IN ' +
					LPI_ServiceUtility.getStringValuesByStringSet(auditTypeSet) +
					' AND Audit_Status__c IN ' +
					LPI_ServiceUtility.getStringValuesByStringSet(auditStatusSet);

				for (
					SObject obj : LPI_CustomMetadataTypeDAO.getCustomMetaDataByDymanicQuery(
						querryFields,
						'Notification_Message__mdt',
						whereClause,
						null,
						null,
						null
					)
				) {
					Notification_Message__mdt notRec = (Notification_Message__mdt) obj;
					String key;
					if (String.isNotBlank(notRec.Regulatory_Authorization_Type_Name__c)) {
						key =
							notRec.Board_Name__c +
							'_' +
							notRec.Audit_Type__c +
							'_' +
							notRec.Audit_Status__c +
							'_' +
							notRec.Regulatory_Authorization_Type_Name__c;
						ratSet.add(notRec.Regulatory_Authorization_Type_Name__c);
					} 
					else if (
						String.isNotBlank(notRec.Subprofession__c) && notRec.Board_Name__c == CHIROPRACTIC_EXAMINERS
					) {
						key =
							notRec.Board_Name__c +
							'_' +
							notRec.Audit_Type__c +
							'_' +
							notRec.Audit_Status__c +
							'_' +
							notRec.Subprofession__c;
					}  
					else {
						key = notRec.Board_Name__c + '_' + notRec.Audit_Type__c + '_' + notRec.Audit_Status__c;
					}
					uniqueKeyToMetaDataMap.put(key, notRec);
					devNameToEmailNotifRecMap.put(key, notRec);
				}

				if (!uniqueKeyToMetaDataMap.isEmpty()) {
					for (Audit_Detail__c auditRecord : auditList) {
						Map<String, String> replaceTextMap = new Map<String, String>();
						String key;
						if (ratSet.contains(auditRecord.Business_License__r.Regulatory_Authorization_Type_Name__c)) {
							key =
								auditRecord.Board_Name__c +
								'_' +
								auditRecord.RecordType.DeveloperName +
								'_';
							key += doResultChange == true ? auditRecord.Audit_Result__c : auditRecord.Status__c;
							key += '_' + auditRecord.Business_License__r.Regulatory_Authorization_Type_Name__c;
						} 
						else if (
							String.isNotBlank(auditRecord.Subprofession__c) &&
							auditRecord.Board_Name__c == CHIROPRACTIC_EXAMINERS
						) {
							key =
								auditRecord.Board_Name__c +
								'_' +
								auditRecord.RecordType.DeveloperName +
								'_'; 
							key += doResultChange == true  ? auditRecord.Audit_Result__c : auditRecord.Status__c;
							key += '_' + auditRecord.Subprofession__c;
						}  
						else {
							key =
								auditRecord.Board_Name__c +
								'_' +
								auditRecord.RecordType.DeveloperName +
								'_';
							key+= doResultChange == true  ? auditRecord.Audit_Result__c : auditRecord.Status__c; 
						}
						if (uniqueKeyToMetaDataMap.containsKey(key)) {
							Notification_Message__mdt metaRec = uniqueKeyToMetaDataMap.get(key);
							LPI_Wrapper.NotificationEmailWrapper notifcationWrapper = new LPI_Wrapper.NotificationEmailWrapper();
							replaceTextMap.put('Licensee_Name', auditRecord.Business_License__r.Account.Name);
							replaceTextMap.put(
								'Current_Reporting_Start_Date',
								auditRecord.Current_Reporting_Start_Date__c == null
									? ''
									: getFormatedDate(auditRecord.Current_Reporting_Start_Date__c)
							);
							replaceTextMap.put(
								'Current_Reporting_End_Date',
								auditRecord.Current_Reporting_End_Date__c == null
									? ''
									: getFormatedDate(auditRecord.Current_Reporting_End_Date__c)
							);
							replaceTextMap.put('Portal_Link', System.Label.Site_Url);
							String currentRenewalPeriod = (auditRecord.Current_Reporting_Start_Year__c != null &&
								auditRecord.Current_Reporting_End_Year__c != null)
								? auditRecord.Current_Reporting_Start_Year__c +
								  '-' +
								  auditRecord.Current_Reporting_End_Year__c
								: '';
							replaceTextMap.put('Current_Renewal_Period', currentRenewalPeriod);
							replaceTextMap.put('Today_Date', getFormatedDate(Date.today()));
							replaceTextMap.put(
								'License_Number',
								auditRecord.Business_License__r.Name != null ? auditRecord.Business_License__r.Name : ''
							);
							replaceTextMap.put(
								'Prc_Entity_Name',
								auditRecord.Business_License__r.Account.Name != null
									? auditRecord.Business_License__r.Account.Name
									: ''
							);
							String city = '';
							String state = '';
							String zip = '';
							String street = '';
							if (!addressMap.isEmpty() && addressMap.containsKey(auditRecord.Business_License__r.Id)) {
								Schema.Address address = addressMap.get(auditRecord.Business_License__r.Id);
								city = address.City != null ? address.City : '';
								state = address.State != null ? address.State : '';
								zip = address.PostalCode != null ? address.PostalCode : '';
								street = address.Street != null ? address.Street : '';
							}
							replaceTextMap.put('Licensee_Mailing_Address', street);
							replaceTextMap.put('Licensee_City', city);
							replaceTextMap.put('Licensee_State', state);
							replaceTextMap.put('Licensee_Zip', zip);
							
							replaceTextMap.put(
								'CE_Hours',
								auditRecord.Approved_CE_Hours__c != null
									? String.valueOf(auditRecord.Approved_CE_Hours__c)
									: ''
							);
							replaceTextMap.put(
								'Current_Reporting_Start_Year',
								auditRecord.Current_Reporting_Start_Year__c != null
									? String.valueOf(auditRecord.Current_Reporting_Start_Year__c)
									: ''
							);
							replaceTextMap.put(
								'Reminder_Notification_Date',
								auditRecord.Reminder_Notification_Date__c != null
									? getFormatedDate(auditRecord.Reminder_Notification_Date__c)
									: ''
							);
							replaceTextMap.put(
								'Current_Reporting_End_Year',
								auditRecord.Current_Reporting_End_Year__c != null
									? String.valueOf(auditRecord.Current_Reporting_End_Year__c)
									: ''
							);
							replaceTextMap.put(
								'Date_Of_First_Notification',
								auditRecord.Initial_Notification_Date__c != null
									? getFormatedDate(auditRecord.Initial_Notification_Date__c)
									: ''
							);
							replaceTextMap.put(
								'Day_After_No_Response_Date',
								getFormatedDate(auditRecord.No_Response_Notification_Date__c.addDays(1))
							);
							replaceTextMap.put(
								'No_Response_Date',
								getFormatedDate(auditRecord.No_Response_Notification_Date__c)
							);
							replaceTextMap.put(
								'One_Month_From_Due_Date',
								getFormatedDate(auditRecord.No_Response_Notification_Date__c.addMonths(1))
							);
							Date postDueDate = auditRecord.No_Response_Notification_Date__c.addMonths(1);
							Datetime myDateTime = Date.newInstance(
								postDueDate.Year(),
								postDueDate.Month(),
								postDueDate.Day()
							);
							replaceTextMap.put(
								'Following_Month_From_Due_Date',
								String.valueOf(myDateTime.format('MMMM'))
							);
							replaceTextMap.put(
								'First_Year_Of_Current_Renewal_Period',
								String.valueOf(auditRecord.Current_Reporting_Start_Year__c)
							);
							replaceTextMap.put(
								'Last_Year_Of_Current_Renewal_Period',
								String.valueOf(auditRecord.Current_Reporting_End_Year__c)
							);

							Map<String, Object> boardSignatureMap = (Map<String, Object>) JSON.deserializeUntyped(
								String.valueOf(
									auditRecord.Business_License__r.RegulatoryAuthorizationType.Email_Specifications_Final__c
								)
							);
							replaceTextMap.put(
								'Board_Email_LPI',
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
							if (auditRecord.Include_Comments_in_the_Email__c) {
								replaceTextMap.put(
									'Comments',
									auditRecord.Comments__c != null ? auditRecord.Comments__c : ''
								);
							} else {
								replaceTextMap.put(
									'Comments',
									''
								);
							}
							Date currentReportingEndDate = auditRecord?.Current_Reporting_End_Date__c;
							if (currentReportingEndDate != null) {
								replaceTextMap.put(
									'One_Year_From_Current_Reporting_End_Year',
									getFormatedDate(currentReportingEndDate.addYears(1))
								);
							}
				

							replaceTextMap.put('MonthName', myDateTime.format('MMMM'));
							Date postCompletionDate = Date.today().addMonths(1);
							Datetime postCompletionDateTime = Date.newInstance(
								postCompletionDate.Year(),
								postCompletionDate.Month(),
								postCompletionDate.Day()
							);
							replaceTextMap.put('One_Month_From_Completed_Date', String.valueOf(postCompletionDateTime.format('MMMM')));

							 
						
							notifcationWrapper.accountId = auditRecord.Business_License__r.AccountId;
							notifcationWrapper.recipientEmail = auditRecord.Business_License__r.Account.PersonEmail;
							notifcationWrapper.templateName = uniqueKeyToMetaDataMap.get(key).Template_Name__c;
							notifcationWrapper.replaceTextMap = replaceTextMap;
						 
							notifcationWrapper.blId = auditRecord.Business_License__c;
							 
							notificationEmailWrapperList.add(notifcationWrapper);
							
						}
					}
				}
				for (Audit_Detail__c auditRecord : auditList) {
					if(auditRecord.Status__c == IN_PROGRESS_STATUS){
						Map<String, String> portalreplaceTextMap = new Map<String, String>();
						Map<String, String> urlParameter = new Map<String, String>();
						portalreplaceTextMap.put('[Audit_Type]',auditRecord.RecordType.Name);
						urlParameter.put('audId', auditRecord.Id);
						String portalKey = LPI_ServiceUtility.createKeyForMetaDataMap(
							null,
							null,
							null,
							'AuditPortalNotification'
						);
						Notification__c portalNoti = LPI_ServiceUtility.createPortalNotificationRecord(
							portalNotificationMessageMap.get(portalKey),
							true,
							portalreplaceTextMap,
							urlParameter,
							auditRecord.Business_License__r.Contact.AccountId
						);
						portalNoti.Business_License__c = auditRecord.Business_License__c;
						portalNotificationToInsert.add(portalNoti);
					}
				}
				if (!notificationEmailWrapperList.isEmpty()) {
					notificationsInserted.addAll(
						(List<Notification__c>) LPI_ServiceUtility.createNotificationRecords(
							notificationEmailWrapperList
						)
					);
				}
				if(!portalNotificationToInsert.isEmpty()){
					LPI_DML.doInsert(portalNotificationToInsert);
				}
			}
		}
		return notificationsInserted;
	}
	/**
	 * @author                      : MTX Group Product Team
	 * @since                       : 27 Sep 2023
	 * @param recordsList 		   : List of Audit_Detail__c records to populate reporting dates on.
	 * @description 				   : This method populates the No_Response_Notification_Date__c on the provided list of Audit_Detail__c records.
	 * 							   : If the status of an audit record needs to be updated (Fail or Additional Info Needed)
	 * @last modified by            : MTX Group Product Team
	 * @last modified date          : (Add if modified by you)
	 * @last modified details       : (Add if modified by you)
	 */
	public static void updateNoResponseNotiOnStatusChange(
		List<Audit_Detail__c> recordsList,
		Map<Id, Audit_Detail__c> mapOfOldRecords
	) {
		try {
			Set<Id> blIdSet = new Set<Id>();
			Map<Id, Integer> blIdNoResponseMap = new Map<Id, Integer>();
			for (Audit_Detail__c auditRecord : recordsList) {
				if (
					(mapOfOldRecords != null &&
					mapOfOldRecords.get(auditRecord.Id).Status__c != auditRecord.Status__c)
				) {
					blIdSet.add(auditRecord.Business_License__c);
				}
			}
			if (!blIdSet.isEmpty()) {
				String fieldToQuery = 'Id, RegulatoryAuthorizationType.IssuingDepartment.No_Response_Notification_Period__c';
				String whereClause = 'Id IN ' + LPI_ServiceUtility.getStringValuesBySet(blIdSet);
				for (
					BusinessLicense bl : LPI_BusinessLicenseDAO.fetchBusinessLicenseRecords(fieldToQuery, whereClause)
				) {
					blIdNoResponseMap.put(
						bl.Id,
						bl.RegulatoryAuthorizationType.IssuingDepartment.No_Response_Notification_Period__c != null
							? Integer.valueOf(
									bl.RegulatoryAuthorizationType.IssuingDepartment.No_Response_Notification_Period__c
							  )
							: 0
					);
				}

				for (Audit_Detail__c ad : recordsList) {
					if (
						(AUDIT_STATUS_SET.contains(ad.Status__c) ||
						AUDIT_RESULT_SET.contains(ad.Audit_Result__c)) &&
						blIdNoResponseMap.get(ad.Business_License__c) != 0 &&
						(mapOfOldRecords.get(ad.Id).Status__c != ad.Status__c ||
						mapOfOldRecords.get(ad.Id).Audit_Result__c != ad.Audit_Result__c)
					) {
						ad.No_Response_Notification_Date__c = Date.today().addDays(
							blIdNoResponseMap.get(ad.Business_License__c)
						);
					}
				}
			}
		} catch (Exception ex) {
			LPI_ExceptionManager.logException(
				'LPI_AuditDetailTriggerHelper',
				'updateNoResponseNotiOnStatusChange',
				ex
			);
			throw new AuraHandledException(ex.getMessage() + ' ' + ex.getStackTraceString());
		}
	}
	/**
	* @author                      : MTX Group Product Team
	* @since                       : 12 Oct, 2023
	* @description                 : This method will send the email notification if audit record status is assigned.
	* @param recordsList           : The list of audit detail records.
	* @param mapOfOldRecords       : The map of old audit detail records.
	* @return void
	* @last modified by            : MTX Group Product Team
	* @last modified date          : (Add if modified by you)
	* @last modified details       : (Add if modified by you)
	*/
    public static void populateAuditDates(
        List<Audit_Detail__c> recordsList,
        Map<Id, Audit_Detail__c> mapOfOldRecords
    ) {
        try {
            for (Audit_Detail__c auditRecord : recordsList) {
				String recName = Schema.getGlobalDescribe().get(OBJECT_NAME).getDescribe().getRecordTypeInfosById().get(auditRecord.RecordTypeId).getName();
				if(recName!=FINANCIAL_RECORD_TYPE){
					if(mapOfOldRecords == null){
						auditRecord.Audit_Start_Date__c = auditRecord.Initial_Notification_Date__c;
						auditRecord.Audit_End_Date__c = auditRecord.No_Response_Notification_Date__c;
					}else{
						if(mapOfOldRecords.get(auditRecord.Id).Initial_Notification_Date__c != auditRecord.Initial_Notification_Date__c){
							auditRecord.Audit_Start_Date__c = auditRecord.Initial_Notification_Date__c;
						}
						if(mapOfOldRecords.get(auditRecord.Id).No_Response_Notification_Date__c != auditRecord.No_Response_Notification_Date__c ){
							auditRecord.Audit_End_Date__c = auditRecord.No_Response_Notification_Date__c;
						}
					}
				}
			}
        } catch (Exception ex) {
            LPI_ExceptionManager.logException('LPI_AuditDetailTriggerHelper', 'updateAuditDates', ex);
            throw new AuraHandledException(ex.getMessage());
        }
	}


	public static String getFormatedDate(Date dt){
		DateTime myDate = DateTime.newInstance(dt.year(), dt.month(), dt.day());
		return myDate.format('MMMM dd, yyyy');
	}
}