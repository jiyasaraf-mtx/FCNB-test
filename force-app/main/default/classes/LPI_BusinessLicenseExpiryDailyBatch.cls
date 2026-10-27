/**
 * @author          : Dhanashree Chougule
 * @description     : This is a Daily batch class for updating the status as per Expiry Date, Late Renewal, Reinstatement Period, Reactivation Period crossing.
 * * @history
 * -------------------------------------------------------------------------------------------------------
 * Version      Date                Author                  Details
 *    1         11 Nov, 2022        Dhanashree Chougule     Initial Developement
 *    2         Dec 27, 2022        Milanjeet Singh         Added Logic to Expire the Courses under Real School Licenses
 *    3         Feb 8, 2023         Nitish Gundedi          Updated logic based on Status after late renewal
 * 	  4         Feb 15, 2023        Nitish Gundedi          Updated logic for Reinstatement based on Reinstatement period/Subsequnt Reinstatement Period.
 * 	  5         July 07, 2023       Nitish Gundedi          Added Logic for Certification of Identification Expiry Notification after crossing expiry date.
 * 	  6         July 09, 2023       Nitish Gundedi          Added Logic for Cosbar Reactivation applicable Licenses, Temp Military Licenses to update status to void after expiry if it is in Inactive.
 * -------------------------------------------------------------------------------------------------------
 */
global with sharing class LPI_BusinessLicenseExpiryDailyBatch implements Database.Batchable<sObject>, Schedulable, Database.Stateful {
	//List of Notifications created, Passing this list to Notification batch which sends the Notifications
    private List<Notification__c> certIdentificationNotificationsInserted = new List<Notification__c>();
	//Set of licenses which are eligible for Certification Identification Expiry Notification
	private final Set<String> CERT_IDENTIFICATION_ELIGIBLE_SET = new Set<String>{
		'Class CA - Hairdressing and Manicuring',
		'Class CH - Hairdresser',
		'Class E - Estheticians',
		'Class MO - Manicurist',
		'Cosmetology Instructor',
		'Cosmetologist/All-Barber',
		'Cosmetologist/Hair-Barber',
		'Cosmetology/Barber Instructor'
	};
	//Set of licenses which have Reactivation applications
	private final Set<String> COSBAR_REACTIVATION_ALLOWED_SET = new Set<String>{
		'Barber',
		'Barber Instructor',
		'Class CA - Hairdressing and Manicuring',
		'Class CH - Hairdresser',
		'Class E - Estheticians',
		'Class MO - Manicurist',
		'Cosmetology Instructor',
		'Cosmetologist/All-Barber',
		'Cosmetologist/Hair-Barber',
		'Cosmetology/Barber Instructor'
	};
	private final static String BL_STATUS_VOID = 'Void';
	private final static String YES = 'Yes';
	private final static Set<String> COS_BAR_TEMP_MILITARY_LICENSE_TYPES = new Set<String>{
        'Barber',
        'Barber Instructor',
		'Class CA - Hairdressing and Manicuring',
		'Class CH - Hairdresser',
		'Class E - Estheticians',
		'Class MO - Manicurist',
		'Cosmetology Instructor'
	};
    private final static String CLASSIFICATION_MILITARY = 'Military';
	//Start - Added by Nitish (S-55383, S-55380)
	private final static Set<String> RENEW_NOT_ALLOWED_SUB_STATUS = new Set<String>{
		'Non-Renew',
		'Non-Practicing'
	};
    //End - Added by Nitish (S-55383, S-55380)
	private final static String LAWFUL_EXPIRED_SUB_STATUS = 'Lawful Presence Expired';
	private final static String CITIZENSHIP_FOREIGN = 'FOREIGN';
	private final static String APEPLSPA_BOARD_NAME = 'Architects, Engineers, Land Surveryors, and Landscape Architects';
	global Database.QueryLocator start(Database.BatchableContext bc) {
		String query = 'Select Id, PeriodEnd,Reinstatement_Count__c, Inactivation_Date__c, RegulatoryAuthorizationType.Name, RegulatoryAuthorizationType.IssuingDepartment.Name,'+
					' AccountId, RegulatoryAuthorizationType.Late_Renewal_Allowed__c,Contact.Name,Contact.Email,Name,Status,RegulatoryAuthorizationType.Status_After_Expiry__c, Account.PersonEmail,'+
					' RegulatoryAuthorizationType.Status_After_Late_Renewal__c,RegulatoryAuthorizationType.Status_After_Reinstatement__c,RegulatoryAuthorizationType.Extended_Expiry_Period__c,'+
					' RegulatoryAuthorizationType.Subsequent_Reinstatement_Period__c,RegulatoryAuthorizationType.Status_After_Inactivation__c, RegulatoryAuthorizationType.Reactivation_Period__c,'+
					' RegulatoryAuthorizationType.Reinstatement_by_Exam_Period__c, Account.LawfulPresenceExpirationDate__c, RegulatoryAuthorizationType.Email_Specifications_Final__c,'+
					' Certificate_of_Identification_Issued__c, License_Sub_status__c, Account.Citizenship__c from BusinessLicense ';
		query =
			query +
			'WHERE RegulatoryAuthorizationTypeId != null AND PeriodEnd != null AND Status != \'' + BL_STATUS_VOID + '\'' + 'AND (((PeriodEnd <= TODAY OR (RegulatoryAuthorizationType.Reactivation_Period__c != null' +
			' AND Status = \'' +
            LPI_LiteralConstant.BUSINESSLICENSE_STATUS_INACTIVE +
			'\'' +
            ' AND Inactivation_Date__c != null)) AND (NOT(RegulatoryAuthorizationType.IssuingDepartment.Name = \'' +
            LPI_LiteralConstant.LICENSE_TYPE_NURSING +
            '\'' +
            ' AND (Status = \'' +
            LPI_LiteralConstant.BUSINESSLICENSE_STATUS_INACTIVE +
            '\'' +
            ' OR Status = \''+
            LPI_LiteralConstant.BL_STATUS_RETIRED +
            '\')))) OR (Account.Citizenship__c = \'' + CITIZENSHIP_FOREIGN + '\'' + ' AND Account.LawfulPresenceExpirationDate__c != null AND Account.LawfulPresenceExpirationDate__c = YESTERDAY))';
		return Database.getQueryLocator(query);
	}

	global void execute(Database.BatchableContext bc, List<BusinessLicense> businessLicenseRecordsList) {
		List<BusinessLicense> blUpdateList = new List<BusinessLicense>();
		List<BusinessLicense> certIdentificationNotificationList = new List<BusinessLicense>();
		List<sObject> lstRecordsToUpdate = new List<sObject>();
		for (BusinessLicense bl : businessLicenseRecordsList) {
			Date expiryDate = Date.newInstance(bl.PeriodEnd.year(), bl.PeriodEnd.month(), bl.PeriodEnd.day());
			if (
				bl.Account.Citizenship__c == CITIZENSHIP_FOREIGN &&
				bl.Account.LawfulPresenceExpirationDate__c != null &&
				bl.Account.LawfulPresenceExpirationDate__c <= expiryDate &&
				!(bl.RegulatoryAuthorizationType.IssuingDepartment.Name == APEPLSPA_BOARD_NAME && 
			     RENEW_NOT_ALLOWED_SUB_STATUS.contains(bl.License_Sub_status__c))
			) {
				bl.Status = LPI_LiteralConstant.Business_License_Status_EXPIRED;
				bl.License_Sub_status__c = LAWFUL_EXPIRED_SUB_STATUS;
				blUpdateList.add(bl);
			} else if (
				bl.Status == LPI_LiteralConstant.STATUS_INACTIVE &&
				bl.Inactivation_Date__c != null &&
                (
                    bl.RegulatoryAuthorizationType.Reactivation_Period__c != null ||
                    COSBAR_REACTIVATION_ALLOWED_SET.contains(bl.RegulatoryAuthorizationType.Name)
                )
			) {
				if(bl.RegulatoryAuthorizationType.Reactivation_Period__c != null){
					Date extendedInactivationDate = bl.Inactivation_Date__c.addMonths(
						Integer.valueOf(bl.RegulatoryAuthorizationType.Reactivation_Period__c)
					);
					//If Inactivation Date is 31st Jan 2023, and period is 5 years, it should set to void on 
					if (extendedInactivationDate == Date.today() && String.isNotBlank(bl.RegulatoryAuthorizationType.Status_After_Inactivation__c)) {
						bl.Status = bl.RegulatoryAuthorizationType.Status_After_Inactivation__c;
						blUpdateList.add(bl);
					}
				}else if(
					//If Cosbar Reactivation applicable license and Expiry Date is passed when license is in Inactive
					COSBAR_REACTIVATION_ALLOWED_SET.contains(bl.RegulatoryAuthorizationType.Name) &&
					expiryDate.addDays(1) == Date.today() && 
					String.isNotBlank(bl.RegulatoryAuthorizationType.Status_After_Inactivation__c)
				){
					bl.Status = bl.RegulatoryAuthorizationType.Status_After_Inactivation__c;
					blUpdateList.add(bl);
				}
			} else {
				Date actualExpiryDate;
                
				//If license does not expire on Expiry date. Expires after Late Renewal period
				if (
					(bl.RegulatoryAuthorizationType.Late_Renewal_Allowed__c != null &&
					bl.RegulatoryAuthorizationType.Late_Renewal_Allowed__c != 0)
				) {
					actualExpiryDate = expiryDate;
					//Checking if it is expiring on expiry date.
					if (actualExpiryDate.addDays(1) == Date.today() && String.isNotBlank(bl.RegulatoryAuthorizationType.Status_After_Expiry__c)) {
						//Start - Added by Nitish (S-55383, S-55380)
						if(
							String.isNotBlank(bl.License_Sub_status__c) && 
							RENEW_NOT_ALLOWED_SUB_STATUS.contains(bl.License_Sub_status__c)
						){
							bl.Status = BL_STATUS_VOID;
						}
						//End - Added by Nitish (S-55383, S-55380)
						else{
							bl.Status = bl.RegulatoryAuthorizationType.Status_After_Expiry__c;
						}
					}
					actualExpiryDate = expiryDate.addMonths(
						Integer.valueOf(bl.RegulatoryAuthorizationType.Late_Renewal_Allowed__c)
					);
					//Checking if it is expiring on late renewal completion. (Expiry date+ laterenewal)
					if (actualExpiryDate.addDays(1) == Date.today() && String.isNotBlank(bl.RegulatoryAuthorizationType.Status_After_Late_Renewal__c)) {
						bl.Status = bl.RegulatoryAuthorizationType.Status_After_Late_Renewal__c;
					} else {
						//if not expiring on late renewal, it means expiring on expiry date
						actualExpiryDate = expiryDate;
					}
				} else {
					//If license expires on Expiry date
					actualExpiryDate = expiryDate;
					if (actualExpiryDate.addDays(1) == Date.today() && String.isNotBlank(bl.RegulatoryAuthorizationType.Status_After_Expiry__c)) {
						if(COS_BAR_TEMP_MILITARY_LICENSE_TYPES.contains(bl.RegulatoryAuthorizationType.Name) /*&& bl.Classification__c == CLASSIFICATION_MILITARY*/){
							bl.Status = BL_STATUS_VOID;
						}else{
							bl.Status = bl.RegulatoryAuthorizationType.Status_After_Expiry__c;
						}
						//for Certification Identification Licenses, Late Renewal is null, So Added here to check if the license is expiring, Adding in Notification list to send notifications.
						if(CERT_IDENTIFICATION_ELIGIBLE_SET.contains(bl.RegulatoryAuthorizationType.Name) && bl.Certificate_of_Identification_Issued__c == YES){
							certIdentificationNotificationList.add(bl);
						}
					}
				}

				//If yesterday was the expiry date based on above logic
				if (actualExpiryDate.addDays(1) == Date.today()) {
					blUpdateList.add(bl);
				} else if (
					//Else If Expiry date is passed and yesterday was the date when Extended period as well is passed
					actualExpiryDate < Date.today() &&
					String.isNotBlank(bl.RegulatoryAuthorizationType.Status_After_Reinstatement__c) &&
					bl.Status != bl.RegulatoryAuthorizationType.Status_After_Reinstatement__c &&
					bl.RegulatoryAuthorizationType.Extended_Expiry_Period__c != null &&
					bl.RegulatoryAuthorizationType.Extended_Expiry_Period__c != 0
				) {
					Date extendedExpiryDate = actualExpiryDate; //Added as actualExpiry As it will give error if not enter any of if/else.
					//Incase of Direct Status after Expiry
					if (
						(bl.RegulatoryAuthorizationType.Late_Renewal_Allowed__c == null ||
						bl.RegulatoryAuthorizationType.Late_Renewal_Allowed__c == 0) &&
						String.isNotBlank(bl.RegulatoryAuthorizationType.Status_After_Expiry__c) &&
						bl.Status == bl.RegulatoryAuthorizationType.Status_After_Expiry__c &&
						bl.RegulatoryAuthorizationType.Status_After_Expiry__c !=
						bl.RegulatoryAuthorizationType.Status_After_Reinstatement__c
					) {
						extendedExpiryDate = actualExpiryDate.addMonths(
							Integer.valueOf(bl.RegulatoryAuthorizationType.Extended_Expiry_Period__c)
						);
					} else if (
						//Incase of Direct Status after Renewal
						(bl.RegulatoryAuthorizationType.Late_Renewal_Allowed__c != null &&
						bl.RegulatoryAuthorizationType.Late_Renewal_Allowed__c != 0) &&
						String.isNotBlank(bl.RegulatoryAuthorizationType.Status_After_Late_Renewal__c) &&
						bl.Status == bl.RegulatoryAuthorizationType.Status_After_Late_Renewal__c &&
						bl.RegulatoryAuthorizationType.Status_After_Late_Renewal__c !=
						bl.RegulatoryAuthorizationType.Status_After_Reinstatement__c
					) {
						//Incase of reinstatement period is different for first time and subsequent times.
						if (
							bl.Reinstatement_Count__c != null &&
							bl.Reinstatement_Count__c >= 1 &&
							bl.RegulatoryAuthorizationType.Subsequent_Reinstatement_Period__c != null &&
							bl.RegulatoryAuthorizationType.Subsequent_Reinstatement_Period__c != 0
						) {
							extendedExpiryDate = actualExpiryDate.addMonths(
								Integer.valueOf(bl.RegulatoryAuthorizationType.Late_Renewal_Allowed__c) +
								Integer.valueOf(bl.RegulatoryAuthorizationType.Subsequent_Reinstatement_Period__c)
							);
						} else {
							extendedExpiryDate = actualExpiryDate.addMonths(
								Integer.valueOf(bl.RegulatoryAuthorizationType.Late_Renewal_Allowed__c) +
								Integer.valueOf(bl.RegulatoryAuthorizationType.Extended_Expiry_Period__c)
							);
						}
					}
					// Checking if yesterday was the day when when Extended period as well is passed and assigning status to configured Status after Resinstatement
					if (extendedExpiryDate.addDays(1) == Date.today()) {
						bl.Status = bl.RegulatoryAuthorizationType.Status_After_Reinstatement__c;
						blUpdateList.add(bl);
					}
				} else if(
                    
					//Specific to Licenses Where Reinstatement By Exam is configured. (there is only Reinstatement period, no late renewal)
					actualExpiryDate < Date.today() &&
					bl.Status != BL_STATUS_VOID &&
					bl.RegulatoryAuthorizationType.Extended_Expiry_Period__c != null &&
					bl.RegulatoryAuthorizationType.Reinstatement_by_Exam_Period__c != null &&
					bl.RegulatoryAuthorizationType.Reinstatement_by_Exam_Period__c != 0
				){
					Date reinstateByExamDate = actualExpiryDate;
					reinstateByExamDate = actualExpiryDate.addMonths(
						Integer.valueOf(bl.RegulatoryAuthorizationType.Extended_Expiry_Period__c) +
						Integer.valueOf(bl.RegulatoryAuthorizationType.Reinstatement_by_Exam_Period__c)
					);
					// Checking if yesterday was the day when when Reinstatement by Exam period as well is passed and assigning status 'Void'
					if (reinstateByExamDate.addDays(1) == Date.today()) {
						bl.Status = BL_STATUS_VOID;
						blUpdateList.add(bl);
					}
				}
			}
		}
		if (!blUpdateList.isEmpty()) {
			lstRecordsToUpdate.addAll(blUpdateList);
		}
		if (!lstRecordsToUpdate.isEmpty()) {
			LPI_DML.doUpdate(lstRecordsToUpdate);
		}
		//Checking if Certification Identification Notification list is not empty and calling email notification insertion method.
		if(!certIdentificationNotificationList.isEmpty()){
			insertCertIndentificationExpiredNotification(certIdentificationNotificationList, certIdentificationNotificationsInserted);
		}
	}

	global void finish(Database.BatchableContext bc) {
		// if(!certIdentificationNotificationsInserted.isEmpty()){
		// 	Database.executebatch(new LPI_NotifEmailTriggerBatch(certIdentificationNotificationsInserted),100);
		// }
	}

	global void execute(SchedulableContext sc) {
		Database.executebatch(new LPI_BusinessLicenseExpiryDailyBatch());
	}

	/**
	 * @author                      : Nitish Gundedi
	 * @since                       : July 07th, 2023
	 * @description                 : This method will insert Notification records for Certification Identification Expiry Notifications for Eligible licenses
	 * @param blList        	    : List of Business Licenses which are eligible to send Certification Identification Expiry Notification
	 * @param certIdentificationNotificationsInserted
	 * 							 	: List of Certification Identification Expiry Notifications which needs to be inserted
	 * @retun                       : 'void'
	 * @last modified by            : MTX Group Inc
	 * @last modified date          :
	 * @modified details            :
	 */
	private static void insertCertIndentificationExpiredNotification(List<BusinessLicense> blList,List<Notification__c> certIdentificationNotificationsInserted){
		//Custom metadata Notification record details to pass template name
		List<Notification_Message__mdt> notificationMessageList = LPI_CustomMetadataTypeDAO.getAllNotificationByDeveloperNames(new Set<String>{'CosBar_Certificate_Identification_Expiry'});
		List<LPI_Wrapper.NotificationEmailWrapper> notificationEmailWrapperList = new List<LPI_Wrapper.NotificationEmailWrapper>();
		//Map to replace variables in template
        Map<String, String> replaceTextMap;
		for(BusinessLicense license : blList){
			replaceTextMap = new Map<String, String>();
            Map<String, Object> boardSignatureMap = new Map<String, Object>();
            if(String.isNotBlank(license.RegulatoryAuthorizationType.Email_Specifications_Final__c)){
                boardSignatureMap = (Map<String, Object>) JSON.deserializeUntyped(
                    String.valueOf(license.RegulatoryAuthorizationType.Email_Specifications_Final__c)
                );
                replaceTextMap.put('Board_Email_MODPR', String.isNotBlank((String)boardSignatureMap.get('boardEmail')) ? (String)boardSignatureMap.get('boardEmail') : '');
                replaceTextMap.put('Board_PO_box', String.isNotBlank((String)boardSignatureMap.get('boardPoBox')) ? (String)boardSignatureMap.get('boardPoBox') : '');
				replaceTextMap.put('Board_Name', String.isNotBlank((String) boardSignatureMap.get('boardName'))
					? (String) boardSignatureMap.get('boardName')
					: '');
            }
            replaceTextMap.put('Licensee_Number', license.Name);
            replaceTextMap.put('License_Expiration_Date', license.PeriodEnd != null ? String.valueOf(license.PeriodEnd.format('MM/dd/yyyy')) : '');
            replaceTextMap.put('Portal_Link', System.Label.Site_Url);

            LPI_Wrapper.NotificationEmailWrapper notifcationWrapper = new LPI_Wrapper.NotificationEmailWrapper();
            notifcationWrapper.accountId = license.AccountId;
            notifcationWrapper.recipientEmail = license.Account.PersonEmail;
            notifcationWrapper.templateName = notificationMessageList[0].Template_Name__c;
            notifcationWrapper.replaceTextMap = replaceTextMap;
			notifcationWrapper.blId = license.Id;
            notificationEmailWrapperList.add(notifcationWrapper);
		}
        if (!notificationEmailWrapperList.isEmpty()) {
			//inserting Notification records here.
            certIdentificationNotificationsInserted.addAll((List<Notification__c>)LPI_ServiceUtility.createNotificationRecords(notificationEmailWrapperList));
        }
	}
}