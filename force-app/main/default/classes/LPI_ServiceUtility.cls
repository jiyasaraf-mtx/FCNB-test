/**
 * @description       : Utility Class
 * @author            : MTX Group Inc
 * @last modified on  : 07-18-2024
 * @last modified by  : MTX Group Inc
 **/
public without sharing class LPI_ServiceUtility {
	public final static String TYPE_ALL = 'ALL';
	public static final String EXPIRATION_DAY = '31';
	public static final String EXPIRATION_MONTH = '12-December';
	private static final String DEFICIENCY_NOTIFICATION_EMAIL = 'Deficiency_Notification_Email';
	private static final String DEFICIENCY_NOTIFICATION_EMAIL_OFFLINE = 'Deficiency_Notification_Email_Offline';
	private static final String DEFICIENCY_NOTICE = 'Deficiency_Notice';
	private static final String UNSUBMITTED = 'Unsubmitted';
	private static final String PHARMACY_BOARD_NAME = 'Pharmacy';
	private static final String ROLE_AUTHORISED_CONTACT = 'Authorized Contact';
	private static final String UNITED_STATES = 'United States';
	private final static STRING RECORD_TYPE_CE_AUDIT = 'CE_Audit';
	private static final Set<String> APPLICATION_DOCUMENT_DEFICIENCY_STATUS_SET = new Set<String>{ 'Unsubmitted', 'Rejected' };
	private final static STRING BOARD_EMAIL_LABEL = 'boardEmail';

	/**
	 *   @author                             : MTX Group Inc
	 *   @since                              : 25 Oct, 2022
	 *   @description                        : This method will create Notification record
	 *   @param metaDataRec                  : Notification metadata record
	 *   @param emailTemplateName            : email template name
	 *   @param hasReplacebleText            : Do we have any replacable text in email body
	 *   @param replaceTextMap               : map of replacable text and value
	 *   @param salutation                   : Email salutation
	 *   @param emailAddress                 : Recipient email address
	 *   @param signature                    : Email Signature
	 *   @return Notification__c             : Notification record
	 */
	public static Notification__c createSingleNotificationRecord(
		Notification_Message__mdt metaDataRec,
		String emailTemplateName,
		Boolean hasReplacebleText,
		Map<String, String> replaceTextMap,
		String salutation,
		String emailAddress,
		String signature,
		Id accountId
	) {
		String titleDescript;
		String descriptionDescript;
		if (metaDataRec != null) {
			Notification__c notificationRec = new Notification__c();
			titleDescript = metaDataRec.Title__c;
			descriptionDescript = metaDataRec.Description__c;
			if (hasReplacebleText && replaceTextMap.size() > 0) {
				for (String replacebleText : replaceTextMap.keySet()) {
					if (descriptionDescript.contains(replacebleText)) {
						descriptionDescript = descriptionDescript.replace(
							replacebleText,
							replaceTextMap.get(replacebleText)
						);
					}
					if (titleDescript.contains(replacebleText)) {
						titleDescript = titleDescript.replace(replacebleText, replaceTextMap.get(replacebleText));
					}
				}
			}
			notificationRec.Salutation_Name__c = salutation;
			notificationRec.Body__c = descriptionDescript;
			notificationRec.Subject__c = titleDescript;
			notificationRec.Signature__c = signature;
			notificationRec.Recipient_Email__c = emailAddress;
			notificationRec.Description__c = 'Email Template - ' + emailTemplateName;
			notificationRec.Account__c = accountId;
			return notificationRec;
		} else {
			return null;
		}
	}

	/**
	 *   @author                             : MTX Group Inc
	 *   @since                              : 11 June, 2023
	 *   @description                        : This method will create Notification record
	 *   @param notifEmailWrapper            : List<NotificationEmailWrapper>
	 *   @return List<Notification__c>       : Notification record
	 */
	public static List<Notification__c> createNotificationRecords(
		List<LPI_Wrapper.NotificationEmailWrapper> notifcationEmailWrapperList
	) {
		try {
			if (notifcationEmailWrapperList.isEmpty()) {
				return null;
			}
			
			List<Notification__c> notificationRecList = new List<Notification__c>();
			List<Notification__c> notificationRecWithNoSenderEmailList = new List<Notification__c>();
			Notification_Message__mdt notificationMessage = Notification_Message__mdt.getInstance(
				'Email_Replaceable_Characters'
			);
			
			Map<String, Object> replacableCharacterConfigMap = (Map<String, Object>) JSON.deserializeUntyped(
				notificationMessage.Description__c
			);
			

			Set<String> iaIdSet = new Set<String>();
			Set<String> blaIdSet = new Set<String>();
			Set<String> blIdSet = new Set<String>();
			Set<String> caseIdSet = new Set<String>();
			Set<String> inspectionIdSet = new Set<String>();
			Set<String> complaintIdSet = new Set<String>();

			for (LPI_Wrapper.NotificationEmailWrapper notificationwrapper : notifcationEmailWrapperList) {
				Notification__c newNotifRec = new Notification__c();
				if ( notificationwrapper.recordType != null) {
					newNotifRec.recordTypeId = notificationwrapper.recordType;
				}
				newNotifRec.Replaceable_Text__c = notificationwrapper.replaceTextMap != null &&
					!notificationwrapper.replaceTextMap.keySet().isEmpty()
					? JSON.serialize(notificationwrapper.replaceTextMap)
					: null;
				if (String.isNotBlank(newNotifRec.Replaceable_Text__c)) {
					newNotifRec.Replaceable_Text__c = replaceCharactersInString(
						newNotifRec.Replaceable_Text__c,
						replacableCharacterConfigMap
					);
				}

				newNotifRec.Description__c = notificationwrapper.description;
				newNotifRec.Subject__c = notificationwrapper.subject;

				
				if(notificationwrapper.replaceTextMap != null && notificationwrapper.replaceTextMap.containsKey('Board_Email')){
					newNotifRec.Sender_Email__c = notificationwrapper.replaceTextMap.get('Board_Email');
				} else if(notificationwrapper.replaceTextMap != null && notificationwrapper.replaceTextMap.containsKey('Board_Email_MO_DPR')){
					newNotifRec.Sender_Email__c = notificationwrapper.replaceTextMap.get('Board_Email_MO_DPR');
				} else if(notificationwrapper.replaceTextMap != null && notificationwrapper.replaceTextMap.containsKey('Board_Email_MODPR')){
					newNotifRec.Sender_Email__c = notificationwrapper.replaceTextMap.get('Board_Email_MODPR');
				}

				
				newNotifRec.Recipient_Email__c = notificationwrapper.recipientEmail; 
				newNotifRec.Template_Name__c = notificationwrapper.templateName;
				if(notificationwrapper.attachmentRequired == 'true'){
					newNotifRec.Send_Email__c = false;
				 	newNotifRec.Is_Attachments_Required__c = true;
					newNotifRec.PDF_Attachment_Name__c = notificationwrapper.pdfAttachmentName;
				}
				
				newNotifRec.Account__c = notificationwrapper.accountId;
				newNotifRec.CC_Addresses__c = notificationwrapper.ccAddresses;

				if (String.isNotEmpty(notificationwrapper.iaId)) {
					newNotifRec.Individual_Application__c = notificationwrapper.iaId;
					if(String.isBlank(newNotifRec.Sender_Email__c)){
						iaIdSet.add(notificationwrapper.iaId);
						notificationRecWithNoSenderEmailList.add(newNotifRec);
					}
				} else if (String.isNotEmpty(notificationwrapper.blaId)) {
					newNotifRec.Business_License_Application__c = notificationwrapper.blaId;
					if(String.isBlank(newNotifRec.Sender_Email__c)){
						blaIdSet.add(notificationwrapper.blaId);
						notificationRecWithNoSenderEmailList.add(newNotifRec);
					}
				} else if (String.isNotEmpty(notificationwrapper.blId)) {
					newNotifRec.Business_License__c = notificationwrapper.blId;
					if(String.isBlank(newNotifRec.Sender_Email__c)){
						blIdSet.add(notificationwrapper.blId);
						notificationRecWithNoSenderEmailList.add(newNotifRec);
					}
				} else if(String.isNotEmpty(notificationwrapper.caseId)) {
					newNotifRec.Case__c = notificationwrapper.caseId;
					if(String.isBlank(newNotifRec.Sender_Email__c)){
						caseIdSet.add(notificationwrapper.caseId);
						notificationRecWithNoSenderEmailList.add(newNotifRec);
					}
				}
				// Inspection and Public Complaint can both be set (e.g. complaint inspections).
				if(String.isNotEmpty(notificationwrapper.visitId)) {
					newNotifRec.Inspection__c = notificationwrapper.visitId;
					if(String.isBlank(newNotifRec.Sender_Email__c)){
						inspectionIdSet.add(notificationwrapper.visitId);
						notificationRecWithNoSenderEmailList.add(newNotifRec);
					}
				}
				if(String.isNotEmpty(notificationwrapper.complaintId)) {
					newNotifRec.Public_Complaint__c = notificationwrapper.complaintId;
					if(String.isBlank(newNotifRec.Sender_Email__c)){
						complaintIdSet.add(notificationwrapper.complaintId);
						notificationRecWithNoSenderEmailList.add(newNotifRec);
					}
				}
				notificationRecList.add(newNotifRec);
			}

			

			Map<Id,String> recIdToEmailOrNameMap = new Map<Id,String>();
			Map<String,String> ratNameToEmailMap = new Map<String,String>();
			Set<String> ratNameSet = new Set<String>();
			Map<String,Object> ratEmailDataMap = new Map<String,Object>();
			
			
			if(!iaIdSet.isEmpty()){
				for(IndividualApplication ia: LPI_IndividualApplicationDAO.getIndividualApplicationByDymanicQuery('Id,LicenseType.Email_Specifications_Final__c','Id IN ' + getStringValuesByStringSet(iaIdSet),null,null,null)){
					ratEmailDataMap = (Map<String,Object>) json.deserializeUntyped(ia.LicenseType.Email_Specifications_Final__c);
					recIdToEmailOrNameMap.put(ia.Id,String.valueOf(ratEmailDataMap.get(BOARD_EMAIL_LABEL)));
				}
			}

			
			if(!blaIdSet.isEmpty()){
				for(BusinessLicenseApplication bla: LPI_BusinessLicenseApplicationDAO.getBusinessLicenseApplicationByDymanicQuery('Id,LicenseType.Email_Specifications_Final__c','Id IN ' + getStringValuesByStringSet(blaIdSet),null,null,null)){
					ratEmailDataMap = (Map<String,Object>) json.deserializeUntyped(bla.LicenseType.Email_Specifications_Final__c);
					recIdToEmailOrNameMap.put(bla.Id,String.valueOf(ratEmailDataMap.get(BOARD_EMAIL_LABEL)));
				}
			}

			
			
			if(!blIdSet.isEmpty()){
				for(BusinessLicense bl: LPI_BusinessLicenseDAO.fetchBusinessLicenseRecords('Id,RegulatoryAuthorizationType.Email_Specifications_Final__c','Id IN ' + getStringValuesByStringSet(blIdSet))){
					ratEmailDataMap = (Map<String,Object>) json.deserializeUntyped(bl.RegulatoryAuthorizationType.Email_Specifications_Final__c);
					recIdToEmailOrNameMap.put(bl.Id,String.valueOf(ratEmailDataMap.get(BOARD_EMAIL_LABEL)));
				}
			}

			
			if(!complaintIdSet.isEmpty()){
				for(PublicComplaint pc: LPI_PublicComplaintDao.fetchPublicComplaintRecords('Id,License_Name__c','Id IN ' + getStringValuesByStringSet(complaintIdSet),null,null)){
					if(String.isNotBlank(pc.License_Name__c)){
						ratNameSet.add(pc.License_Name__c);
						recIdToEmailOrNameMap.put(pc.Id,pc.License_Name__c);
					}
				}
			}


			
			if(!caseIdSet.isEmpty()){
				for(Case ca: LPI_CaseDAO.getCaseRecords('Id,License_Type__c','Id IN ' + getStringValuesByStringSet(caseIdSet),null,null)){
					if(String.isNotBlank(ca.License_Type__c)){
						ratNameSet.add(ca.License_Type__c);
						recIdToEmailOrNameMap.put(ca.Id,ca.License_Type__c);
					}
				}
			}
			
			
			if(!inspectionIdSet.isEmpty()){
				for(Visit ins: LPI_VisitControllerDAO.getVistListByDynamicQuery(new List<String>{'Id','License_Type__c'},'Id IN ' + getStringValuesByStringSet(inspectionIdSet),null,null,null)){
					if(String.isNotBlank(ins.License_Type__c)){
						ratNameSet.add(ins.License_Type__c);
						recIdToEmailOrNameMap.put(ins.Id,ins.License_Type__c);
					}
				}
			}

			
			if(!ratNameSet.isEmpty()){
				for(RegulatoryAuthorizationType rat: LPI_RegulatoryAuthorizationTypeDAO.getRegulatoryAuthorizationTypeByDymanicQuery('Name,Email_Specifications_Final__c','Name IN ' + getStringValuesByStringSet(ratNameSet),null,null,null)){
					ratEmailDataMap = (Map<String,Object>) json.deserializeUntyped(rat.Email_Specifications_Final__c);
					ratNameToEmailMap.put(rat.Name,String.valueOf(ratEmailDataMap.get(BOARD_EMAIL_LABEL)));
				}
			}
			
			for(Notification__c newNotifRec: notificationRecWithNoSenderEmailList){
				
				if(newNotifRec.Individual_Application__c != null && recIdToEmailOrNameMap.containsKey(newNotifRec.Individual_Application__c)){
					newNotifRec.Sender_Email__c = recIdToEmailOrNameMap.get(newNotifRec.Individual_Application__c);
				} else if(newNotifRec.Business_License_Application__c != null && recIdToEmailOrNameMap.containsKey(newNotifRec.Business_License_Application__c)){
					newNotifRec.Sender_Email__c = recIdToEmailOrNameMap.get(newNotifRec.Business_License_Application__c);
				} else if(newNotifRec.Business_License__c != null && recIdToEmailOrNameMap.containsKey(newNotifRec.Business_License__c)){
					newNotifRec.Sender_Email__c = recIdToEmailOrNameMap.get(newNotifRec.Business_License__c);
				} else if(newNotifRec.Public_Complaint__c != null && recIdToEmailOrNameMap.containsKey(newNotifRec.Public_Complaint__c)){
					
					newNotifRec.Sender_Email__c = ratNameToEmailMap.get(recIdToEmailOrNameMap.get(newNotifRec.Public_Complaint__c));
				} else if(newNotifRec.Case__c != null && recIdToEmailOrNameMap.containsKey(newNotifRec.Case__c)){
					
					newNotifRec.Sender_Email__c = ratNameToEmailMap.get(recIdToEmailOrNameMap.get(newNotifRec.Case__c));
				} else if(newNotifRec.Inspection__c != null && recIdToEmailOrNameMap.containsKey(newNotifRec.Inspection__c)){
					
					newNotifRec.Sender_Email__c = ratNameToEmailMap.get(recIdToEmailOrNameMap.get(newNotifRec.Inspection__c));
				}
				
			}
			System.debug('notificationRecList>>>>'+notificationRecList);
			return LPI_WithoutSharingUtility.insertSObjectList(notificationRecList);
		} catch (Exception ex) {
			LPI_ExceptionManager.logException('LPI_ServiceUtility', 'createNotificationRecords', ex);
			throw new AuraHandledException(ex.getMessage() + 'stack trace ' +ex.getStackTraceString());
		}
	}

	/**
	 * @description : Method to replace characters in a string with their character code.
	 * @author MTX Group Inc | 06-28-2023
	 * @param stringToUpdate
	 * @param charactersReplaceMap
	 * @return String
	 **/
	public static String replaceCharactersInString(String stringToUpdate, Map<String, Object> charactersReplaceMap) {
		for (String keyString : charactersReplaceMap.keySet()) {
			if (!stringToUpdate.contains(keyString)) {
				continue;
			}
			stringToUpdate = stringToUpdate.replace(keyString, String.valueOf(charactersReplaceMap.get(keyString)));
		}
		return stringToUpdate;
	}

	

	/**
	 *   @author                             : MTX Group Inc
	 *   @since                              : 07-12-2022
	 *   @description                        : This method will create Bell Notification record
	 *   @param metaDataRec                  : Portal Notification metadata record
	 *   @param hasReplacebleText            : Do we have any replacable text in message body
	 *   @param replaceTextMap               : map of replacable text and value
	 *   @param User                    : User Id to which we have to send notification
	 *  @param recordId                    : record id
	 *   @return Notification__c      : Portal Notification record
	 */
	public static Notification__c createBellNotificationRecord(
		Portal_Notification_Message__mdt metaDataRec,
		Boolean hasReplacebleText,
		Map<String, String> replaceTextMap,
		Id userId,
		Id recordId
	) {
		String descriptionDescript;
		String titleDescript;
		if (metaDataRec != null) {
			Notification__c portalNotificationRec = new Notification__c();
			descriptionDescript = metaDataRec.Description__c;
			titleDescript = metaDataRec.Title__c;
			if (hasReplacebleText && replaceTextMap.size() > 0) {
				for (String replacebleText : replaceTextMap.keySet()) {
					if (descriptionDescript.contains(replacebleText)) {
						descriptionDescript = descriptionDescript.replace(
							replacebleText,
							replaceTextMap.get(replacebleText)
						);
					}
					if (titleDescript.contains(replacebleText)) {
						titleDescript = titleDescript.replace(replacebleText, replaceTextMap.get(replacebleText));
					}
				}
			}
			portalNotificationRec.RecordTypeId = LPI_LiteralConstant.PORTAL_NOTIFICATION_RECORDTYPE_ID;
			portalNotificationRec.Title__c = titleDescript;
			portalNotificationRec.Description__c = descriptionDescript;
			portalNotificationRec.User__c = userId;
			portalNotificationRec.Record_Id__c = recordId;
			return portalNotificationRec;
		} else {
			return null;
		}
	}

	/**
	 *   @author                             : MTX Group Inc
	 *   @since                              : 30-10-2022
	 *   @description                        : This method will create Portal Notification record
	 *   @param metaDataRec                  : Portal Notification metadata record
	 *   @param hasReplacebleText            : Do we have any replacable text in message body
	 *   @param replaceTextMap               : map of replacable text and value
	 *   @param urlParams                    : map of url parameter text and value
	 *   @param accountId                    : Account id
	 *   @return Notification__c      : Portal Notification record
	 */
	public static Notification__c createPortalNotificationRecord(
		Portal_Notification_Message__mdt metaDataRec,
		Boolean hasReplacebleText,
		Map<String, String> replaceTextMap,
		Map<String, String> urlParams,
		Id accountId
	) {
		String descriptionDescript;
		if (metaDataRec != null) {
			Notification__c portalNotificationRec = new Notification__c();
			descriptionDescript = metaDataRec.Description__c;
			
			if (hasReplacebleText && replaceTextMap.size() > 0) {
				for (String replacebleText : replaceTextMap.keySet()) {
					if (descriptionDescript.contains(replacebleText)) {
						descriptionDescript = descriptionDescript.replace(
							replacebleText,
							replaceTextMap.get(replacebleText)
						);
						
					}
				}
			}
			portalNotificationRec.RecordTypeId = LPI_LiteralConstant.PORTAL_NOTIFICATION_RECORDTYPE_ID;
			portalNotificationRec.Side_Color__c = metaDataRec.Side_Color__c;
			portalNotificationRec.Icon_Name__c = metaDataRec.Icon_Name__c;
			portalNotificationRec.Description__c = descriptionDescript;
			portalNotificationRec.Button_Label__c = metaDataRec.Button_Label__c;
			portalNotificationRec.Navigate_Component_API_Name__c = metaDataRec.Navigate_Component_API_Name__c;
			portalNotificationRec.Account__c = accountId;
			portalNotificationRec.Navigation_Type__c = metaDataRec.Navigation_Type__c;

			if (urlParams == null) {
				urlParams = new Map<String, String>();
			}
			if (
				metaDataRec.Navigation_Type__c != null &&
				metaDataRec.Navigation_Type__c == LPI_LiteralConstant.Standard_Navigation
			) {
				urlParams.put('c__target', 'c:' + metaDataRec.Navigate_Component_API_Name__c);
				urlParams.put('c__layout', 'lightning');
				urlParams.put('c__tabIcon', 'custom:custom18');
				urlParams.put('c__tabLabel', metaDataRec.Navigation_Tab_Label__c);
			}
			if (urlParams.size() > 0) {
				portalNotificationRec.Url_Param_Json__c = JSON.serialize(urlParams);
			}

			return portalNotificationRec;
		} else {
			return null;
		}
	}

	/**
	 *   @author                             : MTX Group Inc
	 *   @since                              : 05 July, 2023
	 *   @description                        : This method will create Notification record including attachements and due diligence detils
	 *   @param metaDataRec                  : Notification metadata record
	 *   @param emailTemplateName            : email template name
	 *   @param hasReplacebleText            : Do we have any replacable text in email body
	 *   @param replaceTextMap               : map of replacable text and value
	 *   @param salutation                   : Email salutation
	 *   @param emailAddress                 : Recipient email address
	 *   @param signature                    : Email Signature
	 *   @param isIsAttachmentsRequired      : Do we have any attachment for the mail
	 *   @param RelatedRecordId              : Records ids forom which we are goin to get attachments
	 *   @return Notification__c             : Notification record
	 */
	private static Notification__c createSingleNotificationRecordWithAttachmentsAndDueDiligenceDetails(
		DueDiligenceNotificationWrapper dueDiligenceNotiData
	) {
		Notification__c notification = createSingleNotificationRecord(
			dueDiligenceNotiData.metaDataRec,
			dueDiligenceNotiData.emailTemplateName,
			dueDiligenceNotiData.hasReplacebleText,
			dueDiligenceNotiData.replaceTextMap,
			dueDiligenceNotiData.salutation,
			dueDiligenceNotiData.emailAddress,
			dueDiligenceNotiData.signature,
			dueDiligenceNotiData.accountId
		);

		if (dueDiligenceNotiData.applicationId != null) {
			notification.Application_Id__c = dueDiligenceNotiData.applicationId;
		}
		notification.Is_Attachments_Required__c = dueDiligenceNotiData.isIsAttachmentsRequired;
		notification.Related_Record_Id__c = dueDiligenceNotiData.relatedRecordIds;
		notification.Individual_Application__c = dueDiligenceNotiData.defObj.Individual_Application__c;
		notification.Business_License_Application__c = dueDiligenceNotiData.defObj.Business_License_Application__c;
		return notification;
	}

	/**
	 *   @author                             : MTX Group Inc
	 *   @since                              : 15 Nov, 2022
	 *   @description                        : This method will create Notification record including attachements detils
	 *   @param metaDataRec                  : Notification metadata record
	 *   @param emailTemplateName            : email template name
	 *   @param hasReplacebleText            : Do we have any replacable text in email body
	 *   @param replaceTextMap               : map of replacable text and value
	 *   @param salutation                   : Email salutation
	 *   @param emailAddress                 : Recipient email address
	 *   @param signature                    : Email Signature
	 *   @param isIsAttachmentsRequired      : Do we have any attachment for the mail
	 *   @param RelatedRecordId              : Records ids forom which we are goin to get attachments
	 *   @return Notification__c             : Notification record
	 */
	public static Notification__c createSingleNotificationRecordWithAttachmentsDetails(
		Notification_Message__mdt metaDataRec,
		String emailTemplateName,
		Boolean hasReplacebleText,
		Map<String, String> replaceTextMap,
		String salutation,
		String emailAddress,
		String signature,
		Boolean isIsAttachmentsRequired,
		String relatedRecordIds,
		Id accountId
	) {
		Notification__c notification = createSingleNotificationRecord(
			metaDataRec,
			emailTemplateName,
			hasReplacebleText,
			replaceTextMap,
			salutation,
			emailAddress,
			signature,
			accountId
		);
		notification.Is_Attachments_Required__c = isIsAttachmentsRequired;
		notification.Related_Record_Id__c = relatedRecordIds;
		return notification;
	}

	

	/**
	 *   @author              : MTX Group Inc
	 *   @since               : 16 Nov, 2022
	 *   @description         : This method will be use to get record Ids from a list of records
	 *   @param listOfRecords : list of records
	 *   @return Set<Id>      : Set of record Ids
	 */
	public static Set<Id> pluckIds(List<SObject> listOfRecords) {
		return (new Map<Id, SObject>(listOfRecords))?.keySet();
	}

	/**
	 *   @author              : MTX Group Inc
	 *   @since               : 16 Nov, 2022
	 *   @description         : This method will create Notification__c and Notification__c
	 *                          records for Deficiency notice
	 *   @param mapOfRecords  : map of application records
	 *   @param objectAPIName : Application object name
	 *   @return void
	 */
	public static void triggerDeficiencyEmail(
		Map<Id, SObject> mapOfRecords,
		String objectAPIName,
		Deficiency__c defObj
	) {
		
			if (!mapOfRecords.isEmpty() && String.isNotBlank(objectAPIName) && String.isNotBlank(defObj.Id)) {
				Id accountOrContactId;
				Id ratId;
				String recipientEmailId;
				String applicantAccountId;
				String emailSpecification = '';
				Set<Id> docIdSet = new Set<Id>();
				for (String key : mapOfRecords.keySet()) {
					if (LPI_LiteralConstant.IA_SOBJECT_API.equalsIgnoreCase(objectAPIName)) {
						accountOrContactId = ((IndividualApplication) mapOfRecords.get(key))?.AccountId;
					} else if (LPI_LiteralConstant.BLA_SOBJECT_API.equalsIgnoreCase(objectAPIName)) {
						accountOrContactId = ((BusinessLicenseApplication) mapOfRecords.get(key))?.ApplicantId;
					}
					ratId = (Id) mapOfRecords.get(key).get('LicenseTypeId');
				}
				if (String.isNotBlank(ratId)) {
					List<RegulatoryAuthorizationType> ratList = new List<RegulatoryAuthorizationType>();
					ratList = LPI_RegulatoryAuthorizationTypeDAO.getRegulatoryAuthorizationTypeByDymanicQuery(
						'Id, Email_Specifications_Final__c, IssuingDepartment.Name',
						'Id = \'' + ratId + '\'',
						null,
						null,
						null
					);
					if (!ratList.isEmpty()) {
						emailSpecification = ratList[0].Email_Specifications_Final__c != null
							? String.valueOf(ratList[0].Email_Specifications_Final__c)
							: '';
					}
				}
				if (String.isNotBlank(accountOrContactId)) {
					List<String> fieldsOnAccountList = new List<String>{ 'Id, PersonEmail' };
					List<Account> accList = LPI_AccountDAO.getAccountListByDynamicQuery(
						fieldsOnAccountList,
						'Id = \'' + accountOrContactId + '\' OR PersonContactId = \'' + accountOrContactId + '\'',
						1,
						null,
						null
					);
					if (!accList.isEmpty()) {
						recipientEmailId = accList[0].PersonEmail;
						applicantAccountId = accList[0].Id;
					}
				}
				String fieldsOnAppDocument = 'Id, Business_License_Application__c, Individual_Application__c';
				String whereClauseOnAppDocument =
					'Deficiency__c = \'' +
					defObj.Id +
					'\' AND Is_Deficiency_Notice__c = true AND Status__c  = \'' +
					UNSUBMITTED +
					'\'';
				List<Application_Document__c> listOfApplicationDocument = LPI_ApplicationDocumentDAO.getApplicantDocumentByDymanicQuery(
					fieldsOnAppDocument,
					whereClauseOnAppDocument,
					null,
					null,
					null
				);
				for (Application_Document__c document : listOfApplicationDocument) {
					docIdSet.add(document.Id);
				}
				createNotificationRecords(
					mapOfRecords,
					objectAPIName,
					recipientEmailId,
					docIdSet,
					emailSpecification,
					defObj,
					applicantAccountId
				);
			} else {
				throw new LPI_Exception('Application or objectApiName or deficency id is missing');
			}
		
	}

	/**
	 *   @author                                : MTX Group Inc
	 *   @since                                 : 16 Nov, 2022
	 *   @description                           : This method will create Notification__c
	 *                                            and Notification__c
	 *                                            records for Deficiency notice
	 *   @param mapOfRecords                    : map of application records
	 *   @param objectAPIName                   : Application object name
	 *   @param recipientEmailId                : recipientEmailId for Ia apllication only
	 *   @param docIdSet                        : Application Document Id set
	 *   @param emailSpecification              : emailSpecification of RAT
	 *   @param defObj                          : Deficiency object
	 *   @return void
	 */
	private static void createNotificationRecords(
		Map<Id, SObject> mapOfRecords,
		String objectAPIName,
		String recipientEmailId,
		Set<Id> docIdSet,
		String emailSpecification,
		Deficiency__c defObj,
		String applicantAccountId
	) {
		Map<String, List<String>> iaIdToApplicationDocMap = new Map<String, List<String>>();
		Map<String, String> iaIdToStringMap = new Map<String, String>();
		Map<String, List<String>> iaIdToDueDiligenceMap = new Map<String, List<String>>();
		Map<String, String> iaIdToDueDiligenceStringMap = new Map<String, String>();
		String applicationIds = getStringValuesBySet(mapOfRecords.keyset());
		String AdditionalFeeDatahtml = '';
	
		String fieldsToQuery = 'ID,Checklist_Name__c,Comment__c,Application__c, Individual_Application__c';
		String whereClause =
			'(Application__c IN ' +
			applicationIds +
			' OR Individual_Application__c IN ' +
			applicationIds +
			' ) AND Status__c = \'' +
			String.escapeSingleQuotes('Missing') +
			'\'';

		String orderBy = 'Sequence__c';
		List<Due_Diligence__c> dueDiligenceList = LPI_DueDiligenceDAO.getDueDiligenceByDymanicQuery(
			fieldsToQuery,
			whereClause,
			null,
			orderBy,
			null
		);

		for (Due_Diligence__c dueDiligence : dueDiligenceList) {
			String htmltagDD;
			if (String.isNotBlank(dueDiligence.Checklist_Name__c)) {
				htmltagDD = '<li style="font-weight:bold">' + dueDiligence.Checklist_Name__c;
			}
			if (String.isNotBlank(dueDiligence.Comment__c)) {
				htmltagDD += '<ol style="list-style-type: lower-alpha font-weight:bold"><li style="font-weight:bold">' + dueDiligence.Comment__c + '</li></ol></li>';
			}
			String applicationId = dueDiligence.Application__c != null
				? dueDiligence.Application__c
				: dueDiligence.Individual_Application__c;
			if (!iaIdToDueDiligenceMap.containsKey(applicationId)) {
				iaIdToDueDiligenceMap.put(applicationId, new List<String>());
			}
			iaIdToDueDiligenceMap.get(applicationId).add(htmltagDD);
		}

		String fieldsToQueryDoc = 'ID,Document_Name__c,Status__c,Comments__c,Business_License_Application__c, Individual_Application__c';
		String whereClauseDoc =
			'(Deficiency__c = \'' +
			defObj.Id +
			'\' AND Is_Deficiency_Notice__c = true AND Is_Applicant_Submission_Required__c  = true AND Application_Document__c = NULL)';

		if(String.isNotBlank(defObj.Individual_Application__c)){
			whereClauseDoc += ' OR (Individual_Application__c = \'' + defObj.Individual_Application__c + '\' AND Status__c  IN '+ LPI_ServiceUtility.getStringValuesByStringSet(APPLICATION_DOCUMENT_DEFICIENCY_STATUS_SET) +' AND Is_Document_Required__c = true AND Deficiency__c = NULL)' ;
		} else if (String.isNotBlank(defObj.Business_License_Application__c)) {
			whereClauseDoc += ' OR (Business_License_Application__c = \'' + defObj.Business_License_Application__c + '\' AND Status__c  IN '+LPI_ServiceUtility.getStringValuesByStringSet(APPLICATION_DOCUMENT_DEFICIENCY_STATUS_SET)  +' AND Is_Document_Required__c = true AND Deficiency__c = NULL)' ;
		}

		List<Application_Document__c> applicationDocList = LPI_ApplicationDocumentDAO.getApplicantDocumentByDymanicQuery(
			fieldsToQueryDoc,
			whereClauseDoc,
			null,
			'Sequence__c',
			'ASC'
		);

		for (Application_Document__c applicationDoc : applicationDocList) {
			String htmltag;
			if (String.isNotBlank(applicationDoc.Document_Name__c)) {
				htmltag = '<li style="font-weight:bold">' + applicationDoc.Document_Name__c +'</li>';
			}
			String applicationId = applicationDoc.Business_License_Application__c != null
				? applicationDoc.Business_License_Application__c
				: applicationDoc.Individual_Application__c;
			if (!iaIdToApplicationDocMap.containsKey(applicationId)) {
				iaIdToApplicationDocMap.put(applicationId, new List<String>());
			}
			iaIdToApplicationDocMap.get(applicationId).add(htmltag);
		}
		for(RegulatoryTrxnFeeItem regTranFeeItem : LPI_RegulatoryTrxnFeeItemDAO.getRegulatoryTrxnFeeItemByDynamicQuery('Id,FeeAmount,Comments',
                                                    'RegulatoryTrxnFee.Deficiency__c = \''+String.escapeSingleQuotes(defObj.Id)+'\''+
                                                    'AND RegulatoryTrxnFee.status__c =\'Pending\'',null,null,null)){
			AdditionalFeeDatahtml += '<li style="font-weight:bold"> $'+ String.valueOf(regTranFeeItem.FeeAmount)+' for '+regTranFeeItem.Comments+'</li>';											
        }
		if(String.isNotBlank(AdditionalFeeDatahtml)){
			AdditionalFeeDatahtml = '<p> Submit additional fee as required <ol>'+ AdditionalFeeDatahtml+'</ol></p>';
		}
		Notification_Message__mdt metaDataRecOffline  = LPI_CustomMetadataTypeDAO.getAllNotificationByDeveloperNames(
			new Set<String>{ DEFICIENCY_NOTIFICATION_EMAIL_OFFLINE }
			)
			?.get(0);
		
		Notification_Message__mdt metaDataRecOnline = LPI_CustomMetadataTypeDAO.getAllNotificationByDeveloperNames(
				new Set<String>{ DEFICIENCY_NOTIFICATION_EMAIL }
			)
			?.get(0);

		Portal_Notification_Message__mdt metaDataRecForPortal = LPI_CustomMetadataTypeDAO.getAllPortalNotificationByDeveloperNames(
				new Set<String>{ DEFICIENCY_NOTICE }
			)
			?.get(0);
		List<Notification__c> listOfNotification = new List<Notification__c>();
		List<Notification__c> listOfPortalNotification = new List<Notification__c>();
		Map<String, String> mapOfReplacableText = new Map<String, String>{
			'[Portal_Link]' => System.Label.Site_Url
		};
		mapOfReplacableText.put('[FeeData]',AdditionalFeeDatahtml);
		for (String key : mapOfRecords.keySet()) {
			Map<Id, Map<String, String>> appIdToAccountEmailMap = new Map<Id, Map<String, String>>();
			String accountId;
			SObject currentObject = mapOfRecords.get(key);
			Map<String, Object> boardSignatureMap = (Map<String, Object>) JSON.deserializeUntyped(emailSpecification);
			mapOfReplacableText.put('[Application_Number]', String.valueOf(currentObject.get('Name')));
			if (((String) boardSignatureMap.get('boardName')).contains('Missouri State Board of ')) {
				mapOfReplacableText.put(
					'[Board_Name]',
					((String) boardSignatureMap.get('boardName')).substringAfter('Missouri ')
				);
			} else {
				mapOfReplacableText.put(
					'[Board_Name]',
					String.isNotBlank((String) boardSignatureMap.get('boardName'))
						? (String) boardSignatureMap.get('boardName')
						: ''
				);
			}
			mapOfReplacableText.put(
				'[Board_Email]',
				String.isNotBlank((String) boardSignatureMap.get('boardEmail'))
					? (String) boardSignatureMap.get('boardEmail')
					: ''
			);
			mapOfReplacableText.put(
				'[Board_PO_box]',
				String.isNotBlank((String) boardSignatureMap.get('boardPoBox'))
					? (String) boardSignatureMap.get('boardPoBox')+'<br/>'
					: ''
			);
			mapOfReplacableText.put(
				'[Due_Date]',
				defObj.Due_Date__c != null ? '<p><b>Please ensure the requested information is submitted on or before ' + 
				String.valueOf(defObj.Due_Date__c.format())+'</b></p>': ' '
			);
			if (LPI_LiteralConstant.BLA_SOBJECT_API.equalsIgnoreCase(objectAPIName)) {
				BusinessLicenseApplication bla = ((BusinessLicenseApplication) mapOfRecords.get(key));
				mapOfReplacableText.put('[Salutation]', 'Licensee');
				mapOfReplacableText.put('[Deficiency_Reason]', defObj?.Deficiency_Reason__c);
				mapOfReplacableText.put('[License_Type]', bla?.Licence_Type_Name__c);
				mapOfReplacableText.put('[Application_Type]', bla?.ApplicationType);
				String applicationName = bla.ApplicationType == 'Amendment' ?  
				getPicklistLabel(LPI_LiteralConstant.BLA_SOBJECT_API,'Amendment_Type__c',bla.Amendment_Type__c) : 
				getPicklistLabel(LPI_LiteralConstant.BLA_SOBJECT_API,'ApplicationType',bla.ApplicationType);
				mapOfReplacableText.put('[Application_Name]', (applicationName.endsWithIgnoreCase('application') ? 
										applicationName.substring(0, applicationName.length() - 11) : applicationName) +' application');
				accountId = bla.AccountId;
				if (String.isNotBlank(accountId)) {
					Map<String, BusinessLicenseApplication> accountIdToBlaMap = new Map<String, BusinessLicenseApplication>();
					accountIdToBlaMap.put(accountId, bla);
					appIdToAccountEmailMap = getAccountForBusinessNotification(accountIdToBlaMap, true);
					if (
						appIdToAccountEmailMap.containsKey(key) &&
						String.isNotBlank(recipientEmailId) &&
						String.isNotBlank(applicantAccountId)
					) {
						appIdToAccountEmailMap.get(key).put(applicantAccountId, recipientEmailId);
					}
				} else {
					throw new LPI_Exception('accountId is blank');
				}
			} else if (LPI_LiteralConstant.IA_SOBJECT_API.equalsIgnoreCase(objectAPIName)) {
				IndividualApplication individualApp = ((IndividualApplication) mapOfRecords.get(key));
				mapOfReplacableText.put('[Salutation]', 'Applicant');
				mapOfReplacableText.put('[Deficiency_Reason]', defObj?.Deficiency_Reason__c);
				mapOfReplacableText.put('[License_Type]', individualApp?.License_Type_Name__c);
				mapOfReplacableText.put('[Application_Type]', individualApp?.ApplicationType);
				String applicationName = individualApp.ApplicationType == 'Amendment' ?  
				getPicklistLabel(LPI_LiteralConstant.IA_SOBJECT_API,'Amendment_Type__c',individualApp.Amendment_Type__c) : 
				getPicklistLabel(LPI_LiteralConstant.IA_SOBJECT_API,'ApplicationType',individualApp.ApplicationType);
				mapOfReplacableText.put('[Application_Name]', (applicationName.endsWithIgnoreCase('application') ? 
										applicationName.substring(0, applicationName.length() - 11) : applicationName) +' application');
				accountId = individualApp?.AccountId;
				if (String.isNotBlank(accountId)) {
					Map<String, String> accountIdToEmailMap = new Map<String, String>();
					accountIdToEmailMap.put(accountId, recipientEmailId);
					appIdToAccountEmailMap.put(key, accountIdToEmailMap);
				} else {
					throw new LPI_Exception('accountId is blank');
				}
			}
			String commentDD = '<ol>';
			if (!iaIdToDueDiligenceMap.isEmpty()) {
				commentDD += String.join(iaIdToDueDiligenceMap.get(key), ' ');
			}
			if(String.isNotBlank(defObj?.Deficiency_Reason__c)){
				commentDD += '<li style="font-weight:bold">' + defObj?.Deficiency_Reason__c + '</li>';
			}
			commentDD += '</ol>';
			iaIdToDueDiligenceStringMap.put(key, commentDD);
			mapOfReplacableText.put(
				'[Due_Diligence]',
				!iaIdToDueDiligenceStringMap.isEmpty() ? iaIdToDueDiligenceStringMap.get(key) : ''
			);
			String comment = '<ol>';
			if (!iaIdToApplicationDocMap.isEmpty()) {
				comment += String.join(iaIdToApplicationDocMap.get(key), ' ') + '</ol>';
				iaIdToStringMap.put(key, comment);
			}
			mapOfReplacableText.put(
				'[Application_Documents]',
				!iaIdToStringMap.isEmpty() ? iaIdToStringMap.get(key) : ''
			);
			String relatedRecordIds = '';
			if (!docIdSet.isEmpty()) {
				List<Id> listOfRecordsIds = new List<Id>(docIdSet);
				relatedRecordIds = String.join(listOfRecordsIds, ';');
			}

			for (String appId : appIdToAccountEmailMap.keySet()) {
				Map<String, String> accIdToEmailIdMap = appIdToAccountEmailMap.get(appId);
				SObject app = mapOfRecords.get(appId);
				Notification_Message__mdt metaDataRec;
				if(app.get('Channel__c')== 'Offline'){
					metaDataRec = metaDataRecOffline;
				}else{
					metaDataRec = metaDataRecOnline;
				}
				for (String accId : accIdToEmailIdMap.keySet()) {
					String emailId = accIdToEmailIdMap.get(accId);
					if (String.isEmpty(emailId)) {
						throw new LPI_Exception('emailId is blank');
					}
					DueDiligenceNotificationWrapper dueDiligenceNotiData = new DueDiligenceNotificationWrapper();
					dueDiligenceNotiData.metaDataRec = metaDataRec;
					dueDiligenceNotiData.emailTemplateName = null;
					dueDiligenceNotiData.hasReplacebleText = true;
					dueDiligenceNotiData.replaceTextMap = mapOfReplacableText;
					dueDiligenceNotiData.salutation = null;
					dueDiligenceNotiData.emailAddress = emailId;
					dueDiligenceNotiData.signature = null;
					dueDiligenceNotiData.isIsAttachmentsRequired = true;
					dueDiligenceNotiData.relatedRecordIds = relatedRecordIds;
					dueDiligenceNotiData.accountId = (Id) accId;
					dueDiligenceNotiData.applicationId = appId;
					dueDiligenceNotiData.defObj = defObj;

					listOfNotification.add(
						createSingleNotificationRecordWithAttachmentsAndDueDiligenceDetails(
							dueDiligenceNotiData
						)
					);
					Notification__c notification = createPortalNotificationRecord(
						metaDataRecForPortal,
						true,
						mapOfReplacableText,
						new Map<String, String>{
							'Id' => defObj.Id,
							'SObjectAPIName' => 'Deficiency__c',
							'appId' => key
						},
						(Id) accId
					);
					notification.Record_Id__c = defObj.Id;
					notification.Business_License_Application__c = defObj.Business_License_Application__c;
					notification.Individual_Application__c = defObj.Individual_Application__c;
					listOfPortalNotification.add(notification);
				}
			}
		}
		if (!listOfNotification.isEmpty()) {
			LPI_WithoutSharingUtility.insertSObjectList(listOfNotification);
		}
		if (!listOfPortalNotification.isEmpty()) {
			LPI_DML.doInsert(listOfPortalNotification);
		}
	}

	/**
	 *   @author                 : MTX Group Inc
	 *   @since                  : 15 feb, 2024
	 *   @description            : This method will return the label of picklist corresponding to there value
	 *   @param objectApiName    : objectApiName
	 * 	 @param fieldApiName     : fieldApiName
	 * 	 @param picklistValue    : picklistValue
	 *   @return void
	 */
	private static String getPicklistLabel(String objectApiName, String fieldApiName, String picklistValue) {
		String label = '';
		
		Schema.DescribeSObjectResult describeResult = Schema.getGlobalDescribe().get(objectApiName).getDescribe();
		
		Schema.DescribeFieldResult fieldDescribeResult = describeResult.fields.getMap().get(fieldApiName).getDescribe();
		
		List<Schema.PicklistEntry> picklistValues = fieldDescribeResult.getPicklistValues();
		
		for(Schema.PicklistEntry entry : picklistValues) {
			if(entry.getValue() == picklistValue) {
				label = entry.getLabel();
				break;
			}
		}
        return label;
	}

	

	/**
	 *   @author                  : MTX Group Inc
	 *   @since                   : 18 Nov, 2022
	 *   @description             : This method will used to get object name
	 *   @param     :                Id recordId
	 *   @return
	 */
	public static String getSObjectNameById(Id recordId) {
		return recordId.getSObjectType().getDescribe().getName();
	}

	/**
	 *   @author                  : MTX Group Inc
	 *   @since                   : 18 Nov, 2022
	 *   @description             : This method will used to get application type
	 *   @param     :                Id recordId
	 *   @return
	 */
	public static String getApplicationType(Id recordId) {
		String objectName = getSObjectNameById(recordId);
		String query = 'SELECT ID , ApplicationType FROM ' + objectName + ' WHERE Id = :recordId';
		Sobject sobj = Database.query(query);
		return String.valueOf(sobj.get('ApplicationType'));
	}

	/**
	 *   @author        : MTX Group Inc
	 *   @since         : 16 Nov, 2022
	 *   @description   : This is a wrapper class to store Email request details
	 */
	public class Request {
		@InvocableVariable(label='To Address' required=true)
		public String toAddress;

		@InvocableVariable(label='Related Record Id' required=false)
		public String relatedRecordId;

		@InvocableVariable(label='Send Attachment' required=true)
		public Boolean sendAttachment;

		@InvocableVariable(label='Email Subject' required=true)
		public String emailSubject;

		@InvocableVariable(label='Email Body' required=true)
		public String emailBody;

		@InvocableVariable(label='Template Name' required=false)
		public String templateName;

		@InvocableVariable(label='Notification Id' required=false)
		public String notificationId;

		@InvocableVariable(label='Individual Application Id' required=false)
		public String relatedIaId;

		@InvocableVariable(label='Business License Application Id' required=false)
		public String relatedBlaId;
	}

	/**
	 *   @author                  : MTX Group Inc
	 *   @since                   : 3 Jan, 2023
	 *   @description             : This method will used to fetchPortalNotificationMetaDataRecord
	 *   @param     :                List of strings of regAuthList,typeList,subTypeList,uniqueList
	 *   @return
	 */
	public static Map<String, Portal_Notification_Message__mdt> fetchPortalNotificationMetaDataRecord(
		List<String> regAuthList,
		List<String> typeList,
		List<String> subTypeList,
		List<String> uniqueList
	) {
		Map<String, Portal_Notification_Message__mdt> mapOfPortalNotificationRec = new Map<String, Portal_Notification_Message__mdt>();
		String key = '';
		List<Portal_Notification_Message__mdt> notiRecList = new List<Portal_Notification_Message__mdt>();
		String query =
			'SELECT Id,Regulatory_Authorization_Type_Name__c,Application_Subtype__c,Application_Type__c,DeveloperName, Button_Label__c, Description__c, Icon_Name__c, Unique_Filter__c, ' +
			' Navigate_Component_API_Name__c, Navigation_Tab_Label__c, Navigation_Type__c, Side_Color__c,Title__c ' +
			' FROM Portal_Notification_Message__mdt WHERE ' +
			' DeveloperName != null ';
		query += regAuthList != null ? ' AND Regulatory_Authorization_Type_Name__c IN:regAuthList ' : '';
		query += typeList != null ? ' AND Application_Type__c IN:typeList ' : '';
		query += subTypeList != null ? ' AND Application_Subtype__c IN:subTypeList ' : '';
		query += uniqueList != null ? ' AND Unique_Filter__c IN:uniqueList ' : '';
		notiRecList = Database.query(query);

		for (Portal_Notification_Message__mdt notiRec : notiRecList) {
			key = createKeyForMetaDataMap(
				notiRec?.Regulatory_Authorization_Type_Name__c,
				notiRec?.Application_Type__c,
				notiRec?.Application_Subtype__c,
				notiRec?.Unique_Filter__c
			);
			mapOfPortalNotificationRec.put(key, notiRec);
		}
		return mapOfPortalNotificationRec;
	}
	/**
	 *   @author                  : MTX Group Inc
	 *   @since                   : 3 Jan, 2023
	 *   @description             : This method will used to fetchNotificationMetaDataRecord
	 *   @param     :                List of strings of regAuthList,typeList,subTypeList,uniqueList
	 *   @return
	 */
	public static Map<String, Notification_Message__mdt> fetchNotificationMetaDataRecord(
		List<String> regAuthList,
		List<String> typeList,
		List<String> subTypeList,
		List<String> uniqueList
	) {
		Map<String, Notification_Message__mdt> mapOfNotificationRec = new Map<String, Notification_Message__mdt>();
		String key = '';
		List<Notification_Message__mdt> notiRecList = new List<Notification_Message__mdt>();
		String query =
			'SELECT Regulatory_Authorization_Type_Name__c,Application_Subtype__c,Application_Type__c, ' +
			' Id, DeveloperName, Description__c, Title__c, Unique_Filter__c, Template_Name__c, Email_CC_Addresses__c ' +
			' FROM Notification_Message__mdt WHERE ' +
			' DeveloperName != null ';
		query += regAuthList != null ? ' AND Regulatory_Authorization_Type_Name__c IN:regAuthList ' : '';
		query += typeList != null ? ' AND Application_Type__c IN:typeList ' : '';
		query += subTypeList != null ? ' AND Application_Subtype__c IN:subTypeList ' : '';
		query += uniqueList != null ? ' AND Unique_Filter__c IN:uniqueList ' : '';
		notiRecList = Database.query(query);
		for (Notification_Message__mdt notiRec : notiRecList) {
			key = createKeyForMetaDataMap(
				notiRec?.Regulatory_Authorization_Type_Name__c,
				notiRec?.Application_Type__c,
				notiRec?.Application_Subtype__c,
				notiRec?.Unique_Filter__c
			);
			mapOfNotificationRec.put(key, notiRec);
		}
		return mapOfNotificationRec;
	}
	/**
	 *   @author                  : MTX Group Inc
	 *   @since                   : 3 Jan, 2023
	 *   @description             : This method will used to create key for metadata record map
	 *   @param     :                strings of regAuthList,typeList,subTypeList,uniqueList
	 *   @return
	 */
	public static String createKeyForMetaDataMap(String regAuthName, String type, String subType, String uniqueFilter) {
		String key = '';
		key = regAuthName != null ? regAuthName : '';
		key += type != null ? type : '';
		key += subType != null ? subType : '';
		key += uniqueFilter != null ? uniqueFilter : '';
		return key;
	}

	/**
	 * @description : Method to get a Map Where you will get all the eligible License status confiured for a application type
	 * @author MTX Group Inc | 01-06-2023
	 * @param reguAuthId
	 * @param type
	 * @param subType
	 * @param oldBLID
	 * @return String
	 **/
	public static Map<Id, Map<String, Set<String>>> getRATToEligibleStatusMap(List<BusinessLicense> blList) {
		Map<Id, Map<String, Set<String>>> ratToEligibleStatusMap = new Map<Id, Map<String, Set<String>>>();
		for (BusinessLicense bl : blList) {
			ratToEligibleStatusMap.put(bl.RegulatoryAuthorizationTypeId, new Map<String, Set<String>>());
		}
		for (Application_Flow_Config__c appFlowConfig : [
			SELECT Id, Name, Application_Type__c, Eligible_License_Status__c, Regulatory_Authorization_Type__c
			FROM Application_Flow_Config__c
			WHERE Regulatory_Authorization_Type__c IN :ratToEligibleStatusMap.keySet()
			WITH SECURITY_ENFORCED
		]) {
			if (
				ratToEligibleStatusMap.containsKey(appFlowConfig.Regulatory_Authorization_Type__c) &&
				appFlowConfig.Eligible_License_Status__c != null
			) {
				if (
					!ratToEligibleStatusMap.get(appFlowConfig.Regulatory_Authorization_Type__c)
						.containsKey(appFlowConfig.Application_Type__c)
				) {
					ratToEligibleStatusMap.get(appFlowConfig.Regulatory_Authorization_Type__c)
						.put(appFlowConfig.Application_Type__c, new Set<String>());
				}
				for (String licStatus : appFlowConfig.Eligible_License_Status__c.split(';')) {
					ratToEligibleStatusMap.get(appFlowConfig.Regulatory_Authorization_Type__c)
						.get(appFlowConfig.Application_Type__c)
						.add(licStatus);
				}
			}
		}
		return ratToEligibleStatusMap;
	}

	/**
	 * @description : To check what operations are allowable on the License
	 * @author MTX Group Inc | 01-06-2023
	 * @param ratToEligibleStatusMap
	 * @param blStatus
	 * @return Map<String, Boolean>
	 **/
	public static Map<String, Boolean> getIsActionAllowedMap(
		Map<String, Set<String>> ratToEligibleStatusMap,
		String blStatus
	) {
		Map<String, Boolean> isActionAllowedMap = new Map<String, Boolean>();

		for (String type : ratToEligibleStatusMap.keySet()) {
			if (ratToEligibleStatusMap.get(type).contains(blStatus)) {
				isActionAllowedMap.put(type + 'Allowed', true);
			} else {
				isActionAllowedMap.put(type + 'Allowed', false);
			}
		}

		return isActionAllowedMap;
	}

	/**
	 * @description To Get the next BL status mapping on application Approval
	 * @authorMTX Group Inc | 01-09-2023
	 * @param applicationList
	 * @return Map<String, String>
	 **/
	public static Map<String, String> getNextStatusForBL(List<Sobject> applicationList) {
		Map<Id, Map<String, String>> ratToApplicationStatusConfigMap = new Map<Id, Map<String, String>>();
		Set<String> oldBLIDSet = new Set<String>();
		Map<Id, BusinessLicense> idToBLMap = new Map<Id, BusinessLicense>();
		Map<String, String> nextStatusMap = new Map<String, String>();

		for (Sobject app : applicationList) {
			ratToApplicationStatusConfigMap.put((String) app.get('LicenseTypeId'), new Map<String, String>());
			oldBLIDSet.add((String) app.get('LicensePermitNameId'));
		}

		if (!ratToApplicationStatusConfigMap.isEmpty()) {
			idToBLMap = new Map<Id, BusinessLicense>([SELECT Id, Status FROM BusinessLicense WHERE Id IN :oldBLIDSet]);
			for (Application_Flow_Config__c appFlowConfig : [
				SELECT
					Id,
					Name,
					Application_Type__c,
					Eligible_License_Status__c,
					Application_Subtype__c,
					Regulatory_Authorization_Type__c,
					License_Status_Mapping__c
				FROM Application_Flow_Config__c
				WHERE Regulatory_Authorization_Type__c IN :ratToApplicationStatusConfigMap.keySet()
				WITH SECURITY_ENFORCED
			]) {
				String applicationTypeKey = appFlowConfig.Application_Type__c;
				applicationTypeKey += appFlowConfig.Application_Subtype__c != null
					? appFlowConfig.Application_Subtype__c
					: '';
				ratToApplicationStatusConfigMap.get(appFlowConfig.Regulatory_Authorization_Type__c)
					.put(applicationTypeKey, appFlowConfig.License_Status_Mapping__c);
			}

			for (Sobject app : applicationList) {
				String licenseTypeId = (String) app.get('LicenseTypeId');
				String permitNameId = (String) app.get('LicensePermitNameId');
				if (idToBLMap.containsKey(permitNameId) && ratToApplicationStatusConfigMap.containsKey(licenseTypeId)) {
					String appType = (String) app.get('ApplicationType');
					appType += (String) app.get('Amendment_Type__c') != null
						? (String) app.get('Amendment_Type__c')
						: '';
					if (ratToApplicationStatusConfigMap.get(licenseTypeId).containsKey(appType)) {
						String statusMappingString = ratToApplicationStatusConfigMap.get(licenseTypeId).get(appType);
						String nextStatus = '';
						String currStatus = idToBLMap.get(permitNameId).status;
						if (!String.isBlank(statusMappingString) && currStatus != null) {
							Map<String, Object> statusMap = (Map<String, Object>) JSON.deserializeUntyped(
								statusMappingString
							);
							if (statusMap.containsKey(currStatus))
								nextStatus = (String) statusMap.get(currStatus);
						}
						nextStatusMap.put(permitNameId, nextStatus);
					}
				}
			}
		}
		return nextStatusMap;
	}

	public static String getStringValuesByList(List<Object> objList) {
		String value;
		if (objList != null && !objList.isEmpty()) {
			value = '(';
			for (Integer i = 0; i < objList.size(); i++) {
				if (objList[i] == null) {
					continue;
				}
				String temp = String.escapeSingleQuotes(String.valueOf(objList[i]));

				value += '\'' + temp + '\'';
				if (i != objList.size() - 1) {
					value += ',';
				}
			}
			value += ')';
		} else {
			value = null;
		}
		return value;
	}

	/**
	 * @description To pass List of Ids to getStringValuesByList() by taking set of Ids.
	 * @author MTX Group Inc | 01-24-2023
	 * @param Set<Id> idSet
	 * @return String
	 **/
	public static String getStringValuesBySet(Set<Id> idSet) {
		List<Id> objectList = new List<Id>();
		objectList.addAll(idSet);
		return getStringValuesByList(objectList);
	}
	/**
	 * @description To pass List of Ids to getStringValuesByList() by taking set of Strings.
	 * @author MTX Group Inc | 01-31-2023
	 * @param Set<Id> idSet
	 * @return String
	 **/
	public static String getStringValuesByStringSet(Set<String> idSet) {
		List<String> objectList = new List<String>();
		objectList.addAll(idSet);
		return getStringValuesByList(objectList);
	}

	/**
	 * @description : Method to return the duplicate records according to the duplicate rules defined, for the passsed SObject list.
	 * @author MTX Group Inc | 02-01-2023
	 * @param sObjectList
	 * @return List<Datacloud.MatchRecord>
	 **/
	public static List<Datacloud.MatchRecord> getDuplicateRecordsService(List<SObject> sObjectList) {
		try {
			//system.assert(false,'1266 service uitili');
			for (SObject record : sObjectList) {
				if (record.getSObjectType().getDescribe().getName() != 'Account') {
					continue;
				}
				Account acc = (Account) record; 
				if (
					
					String.isNotblank(acc.Combined_Name__pc) ||
					acc.RecordTypeId != LPI_LiteralConstant.PERSON_ACCOUNT_REC_TYPE_ID
				) {
					//system.assert(false,acc);
					continue;
				}
				
				acc.Combined_Name__pc = String.isNotBlank(acc.FirstName) && String.isNotBlank(acc.MiddleName)
					? acc.FirstName + ' ' + acc.MiddleName + ' ' + acc.LastName
					: String.isNotBlank(acc.FirstName)
							? acc.FirstName + ' ' + acc.LastName
							: String.isNotBlank(acc.MiddleName) ? acc.MiddleName + ' ' + acc.LastName : acc.LastName; 
							//system.assert(false,acc);
			}
			
			List<Datacloud.MatchRecord> matchRecordList = new List<Datacloud.MatchRecord>();
			Datacloud.FindDuplicatesResult[] results = Datacloud.FindDuplicates.findDuplicates(sObjectList);
			for (Datacloud.FindDuplicatesResult findDupeResult : results) {
				for (Datacloud.DuplicateResult dupeResult : findDupeResult.getDuplicateResults()) {
					for (Datacloud.MatchResult matchResult : dupeResult.getMatchResults()) {
						matchRecordList.addAll(matchResult.getMatchRecords());
					}
				}
			}
			return matchRecordList;
		} catch (Exception e) {
			LPI_ExceptionManager.logException('LPI_ServiceUtility', 'getDuplicateRecordsService', e);
			String detail =
				(e instanceof DmlException)
					? ((DmlException) e).getDmlMessage(0)
					: e.getMessage();
			if (String.isBlank(detail) || detail == 'Script-thrown exception') {
				detail = e.getTypeName() + ' at line ' + e.getLineNumber();
			}
			throw new LPI_Exception('Duplicate account check failed: ' + detail);
		}
	}

	/**
	 * @author          : MTX Group Inc
	 * @param records   : This method to get expiration date - Last Modified Garvot
	 * @lastmodified    : Garvit Jain - 25-Nov-2022 - During renewal exiry date population.
	 * @return          : `Datetime`
	 */
	public static Datetime getExpirationDate(RegulatoryAuthorizationType regAuth) {
		Datetime periodEnd;
		if (regAuth.Expiry_Rule_Type__c == LPI_LiteralConstant.EXPIRY_RULE_TYPE_DAY_MONTH_CYCLE) {
			if (
				regAuth.Expiration_Day__c != null &&
				regAuth.Expiration_Month__c != null &&
				regAuth.Expiration_Cycle__c != null
			) {
				Integer endMonth = Integer.valueOf(regAuth.Expiration_Month__c.substring(0, 2));
				
				if (
					(Math.mod(Date.today().year(), 2) == 0 &&
					regAuth.Expiration_Cycle__c == LPI_LiteralConstant.Expiration_Cycle_EVEN) ||
					(Math.mod(Date.today().year(), 2) == 1 &&
					regAuth.Expiration_Cycle__c == LPI_LiteralConstant.Expiration_Cycle_ODD)
				) {
					Date expiryTemp = Date.newinstance(
						Date.today().year(),
						endMonth,
						Integer.valueOf(regAuth.Expiration_Day__c)
					);
					DateTime expiryDate;

					if (regAuth.Open_for_Renewal__c != null && regAuth.Open_for_Renewal__c != 0) {
						Date dateBeforeRenewalExpiry = getTempExpAftercheckingMonthEndAndNextCycle(regAuth, expiryTemp);
						
						if (Date.today() >= dateBeforeRenewalExpiry) {
							expiryDate = Datetime.newinstance(
								Date.today().year() + 2,
								endMonth,
								Integer.valueOf(regAuth.Expiration_Day__c),
								0,
								0,
								0
							);
						} else {
							expiryDate = Datetime.newinstance(
								Date.today().year(),
								endMonth,
								Integer.valueOf(regAuth.Expiration_Day__c),
								0,
								0,
								0
							);
						}
					} else {
						expiryDate = Datetime.newinstance(
							Date.today().year(),
							endMonth,
							Integer.valueOf(regAuth.Expiration_Day__c),
							0,
							0,
							0
						);
					}

				
					if (expiryDate.date() < Date.today()) {
						periodEnd = expiryDate.addYears(2);
					} else {
						periodEnd = expiryDate;
					}
				} else if (
					(Math.mod(Date.today().year(), 2) == 0 &&
					regAuth.Expiration_Cycle__c == LPI_LiteralConstant.Expiration_Cycle_ODD) ||
					(Math.mod(Date.today().year(), 2) == 1 &&
					regAuth.Expiration_Cycle__c == LPI_LiteralConstant.Expiration_Cycle_EVEN)
				) {
					
					Date expiryTemp = Date.newinstance(
						Date.today().year() + 1,
						endMonth,
						Integer.valueOf(regAuth.Expiration_Day__c)
					);

					if (regAuth.Open_for_Renewal__c != null && regAuth.Open_for_Renewal__c != 0) {
						Date dateBeforeRenewalExpiry = getTempExpAftercheckingMonthEndAndNextCycle(regAuth, expiryTemp);
					
						if (Date.today() >= dateBeforeRenewalExpiry) {
							periodEnd = Datetime.newinstance(
								Date.today().year() + 3,
								endMonth,
								Integer.valueOf(regAuth.Expiration_Day__c),
								0,
								0,
								0
							);
						} else {
							periodEnd = Datetime.newinstance(
								Date.today().year() + 1,
								endMonth,
								Integer.valueOf(regAuth.Expiration_Day__c),
								0,
								0,
								0
							);
						}
					} else {
						periodEnd = Datetime.newinstance(
							Date.today().year() + 1,
							endMonth,
							Integer.valueOf(regAuth.Expiration_Day__c),
							0,
							0,
							0
						);
					}
				} else if (regAuth.Expiration_Cycle__c == LPI_LiteralConstant.Expiration_Cycle_ANNUAL) {
					Date expiryTemp = Date.newinstance(
						Date.today().year() + 1,
						endMonth,
						Integer.valueOf(regAuth.Expiration_Day__c)
					);

				
					if (expiryTemp > Date.today().addMonths(12)) {
						expiryTemp = Date.newinstance(
							Date.today().year(),
							endMonth,
							Integer.valueOf(regAuth.Expiration_Day__c)
						);
					}

					if (regAuth.Open_for_Renewal__c != null && regAuth.Open_for_Renewal__c != 0) {
						Date dateBeforeRenewalExpiry = getTempExpAftercheckingMonthEndAndNextCycle(regAuth, expiryTemp);
						
						if (Date.today() >= dateBeforeRenewalExpiry) {
							periodEnd = Datetime.newinstance(
								expiryTemp.year() + 1,
								endMonth,
								Integer.valueOf(regAuth.Expiration_Day__c),
								0,
								0,
								0
							);
						} else {
							periodEnd = Datetime.newinstance(
								expiryTemp.year(),
								endMonth,
								Integer.valueOf(regAuth.Expiration_Day__c),
								0,
								0,
								0
							);
						}
					} else {
						periodEnd = Datetime.newinstance(
							expiryTemp.year(),
							endMonth,
							Integer.valueOf(regAuth.Expiration_Day__c),
							0,
							0,
							0
						);
					}
				} else if (regAuth.Expiration_Cycle__c == LPI_LiteralConstant.Expiration_Cycle_BIENNIAL) {
					Date expiryTemp = Date.newinstance(
						Date.today().year(),
						endMonth,
						Integer.valueOf(regAuth.Expiration_Day__c)
					);

					
					if (expiryTemp < Date.today()) {
						expiryTemp = Date.newinstance(
							Date.today().year() + 2,
							endMonth,
							Integer.valueOf(regAuth.Expiration_Day__c)
						);
					}

					if (regAuth.Open_for_Renewal__c != null && regAuth.Open_for_Renewal__c != 0) {
						Date dateBeforeRenewalExpiry = getTempExpAftercheckingMonthEndAndNextCycle(regAuth, expiryTemp);
						
						if (Date.today() >= dateBeforeRenewalExpiry) {
							periodEnd = Datetime.newinstance(
								expiryTemp.year() + 2,
								endMonth,
								Integer.valueOf(regAuth.Expiration_Day__c),
								0,
								0,
								0
							);
						} else {
							periodEnd = Datetime.newinstance(
								expiryTemp.year(),
								endMonth,
								Integer.valueOf(regAuth.Expiration_Day__c),
								0,
								0,
								0
							);
						}
					} else {
						periodEnd = Datetime.newinstance(
							expiryTemp.year(),
							endMonth,
							Integer.valueOf(regAuth.Expiration_Day__c),
							0,
							0,
							0
						);
					}
				} else if (regAuth.Expiration_Cycle__c == LPI_LiteralConstant.EXPIRATION_CYCLE_FIXED_CYCLE) {
				
					Integer fixedCycleStartYear = (Integer) regAuth.Expiration_Fixed_Cycle_Start_Year__c;
					Integer currentYear = Date.today().year();
					Integer fixedCycleDifference = (Integer) regAuth.Expiration_Fixed_Cycle_Difference__c;
					Decimal noOfFixedCycleDifferenceYears = (currentYear - fixedCycleStartYear) / fixedCycleDifference;
					Decimal fixedCycleActualStartYear =
						fixedCycleStartYear + (noOfFixedCycleDifferenceYears * fixedCycleDifference);

					Date expiryTemp = Date.newinstance(
						fixedCycleActualStartYear.intValue(),
						endMonth,
						Integer.valueOf(regAuth.Expiration_Day__c)
					);

				
					if (expiryTemp < Date.Today()) {
						expiryTemp = Date.newinstance(
							(Integer) (fixedCycleActualStartYear.intValue() + fixedCycleDifference),
							endMonth,
							Integer.valueOf(regAuth.Expiration_Day__c)
						);
					}

					if (regAuth.Open_for_Renewal__c != null && regAuth.Open_for_Renewal__c != 0) {
						Date dateBeforeRenewalExpiry = getTempExpAftercheckingMonthEndAndNextCycle(regAuth, expiryTemp);
					
						if (Date.today() >= dateBeforeRenewalExpiry) {
							periodEnd = Datetime.newinstance(
								expiryTemp.year() + (Integer) regAuth.Expiration_Fixed_Cycle_Difference__c,
								endMonth,
								Integer.valueOf(regAuth.Expiration_Day__c),
								0,
								0,
								0
							);
						} else {
							periodEnd = Datetime.newinstance(
								expiryTemp.year(),
								endMonth,
								Integer.valueOf(regAuth.Expiration_Day__c),
								0,
								0,
								0
							);
						}
					} else {
						periodEnd = Datetime.newinstance(
							expiryTemp.year(),
							endMonth,
							Integer.valueOf(regAuth.Expiration_Day__c),
							0,
							0,
							0
						);
					}
				} else if (regAuth.Expiration_Cycle__c == LPI_LiteralConstant.EXPIRATION_CYCLE_FIVE_YEARS) {
					periodEnd = getExpiryDateFromExpirationCycle(regAuth, 5);
				} else if (regAuth.Expiration_Cycle__c == LPI_LiteralConstant.EXPIRATION_CYCLE_TWO_YEARS) {
					periodEnd = getExpiryDateFromExpirationCycle(regAuth, 2);
				}
			}
		} else if (regAuth.Expiry_Rule_Type__c == LPI_LiteralConstant.EXPIRY_RULE_TYPE_PERIOD) {
			if (regAuth.Expiration_Period__c != null) {
			
				if (regAuth.Expiration_Period__c.contains(LPI_LiteralConstant.EXPIRATION_PERIOD_CONTAINS_DAYS)) {
					periodEnd = datetime.now()
						.addDays(
							Integer.valueOf(
								regAuth.Expiration_Period__c.remove(LPI_LiteralConstant.EXPIRATION_PERIOD_CONTAINS_DAYS)
							)
						);
				} else {
				
					periodEnd = datetime.now().addMonths(Integer.valueOf(regAuth.Expiration_Period__c));
				}
				
				if (
					regAuth.Expiration_Day__c != null &&
					regAuth.Expiration_Day__c == LPI_LiteralConstant.EXPIRATION_DAY_DAY_OF_ISSUANCE_MINUS_1 &&
					regAuth.Expiration_Month__c != null &&
					regAuth.Expiration_Month__c == LPI_LiteralConstant.EXPIRATION_MONTH_MONTH_OF_ISSUANCE
				) {
					periodEnd = periodEnd.addDays(-1);
				}
			}
		} else if (regAuth.Expiry_Rule_Type__c == LPI_LiteralConstant.EXPIRY_RULE_TYPE_NO_EXPIRY) {
			periodEnd = null;
		}
		if (periodEnd != null) {
			periodEnd = Datetime.newinstance(periodEnd.year(), periodEnd.month(), periodEnd.day(), 23, 59, 59);
		}
		return periodEnd;
	}

	/**
	 * @author                      :MTX Group Inc
	 * @since                       : 18th Aug 2023
	 * @description                 : This method used to check if the Expiry Date on RAT is End date of the month and calculate temp Expiry
	 * 								  whether consider next cycle or not (S-54535)
	 * @param regAuth               : RegAuthType
	 * @param expiryTemp     		: Temp Expiry Date before considering condition for Next Expiry
	 * @retun                       : 'Date'
	 * @last modified by            : MTX Group Inc
	 * @last modified date          :
	 * @modified details            :
	 */
	public static Date getTempExpAftercheckingMonthEndAndNextCycle(
		RegulatoryAuthorizationType regAuth,
		Date expiryTemp
	) {
		Integer ratMonth = Integer.valueOf(regAuth.Expiration_Month__c.substring(0, 2));
		Date dateBeforeRenewalExpiry = expiryTemp.addMonths(
			-Integer.valueOf(
				regAuth.Renewal_Window_Period_Before_Expiry__c != null
					? regAuth.Renewal_Window_Period_Before_Expiry__c
					: 0
			)
		);
		
		if (
			ratMonth == 2 ||
			Integer.valueOf(regAuth.Expiration_Day__c) == date.daysInMonth(Date.today().year(), ratMonth)
		) {
			dateBeforeRenewalExpiry = dateBeforeRenewalExpiry.addMonths(1).toStartofMonth();
		}
		return dateBeforeRenewalExpiry;
	}
	
	@TestVisible
	private static Map<String, Map<String, Id>> RECORDTYPE_ID_BY_NAME_BY_SOBJECT;

	/**
	 * @author                      :MTX Group Inc
	 * @since                       : 03 Jan 2023
	 * @description                 : This method calls invoke method
	 * @param sObjectApiName        : Api name of SObject
	 * @param recordTypeName        : Developer Name of RecordType
	 * @retun                       : 'recordTypeId'
	 * @last modified by            : MTX Group Inc
	 * @last modified date          :
	 * @modified details            :
	 */
	public static Id getRecordTypeIdWithName(String sObjectApiName, String recordTypeName) {
		Id recordTypeId = null;
		if (String.isBlank(sObjectApiName)) {
			sObjectApiName = '';
		}
		if (String.isBlank(recordTypeName)) {
			recordTypeName = '';
		}
		sObjectApiName = sObjectApiName.toLowerCase();
		recordTypeName = recordTypeName.toLowerCase();
		if (RECORDTYPE_ID_BY_NAME_BY_SOBJECT == null) {
			RECORDTYPE_ID_BY_NAME_BY_SOBJECT = new Map<String, Map<String, Id>>();
		}
		if (RECORDTYPE_ID_BY_NAME_BY_SOBJECT.get(sObjectApiName) == null) {
			Map<String, Schema.SObjectType> sObjectTypeByName = Schema.getGlobalDescribe();
			Schema.SObjectType sObjType = sObjectTypeByName.get(sObjectApiName);
			if (sObjType != null) {
				Map<String, Id> recordTypeIdByName = new Map<String, Id>();
				for (Schema.RecordTypeInfo r : sObjType.getDescribe().getRecordTypeInfos()) {
					recordTypeIdByName.put(r.getDeveloperName().toLowerCase(), r.getRecordTypeId());
				}
				RECORDTYPE_ID_BY_NAME_BY_SOBJECT.put(sObjectApiName, recordTypeIdByName);
			}
		}
		if (RECORDTYPE_ID_BY_NAME_BY_SOBJECT.get(sObjectApiName) != null) {
			return RECORDTYPE_ID_BY_NAME_BY_SOBJECT.get(sObjectApiName).get(recordTypeName);
		}
		return recordTypeId;
	}

	/**
	 * @author                      : MTX Group Inc
	 * @since                       : Feb 13, 2023
	 * @description                 : This method is used to populate the expiration fields from the other configured fields in case of
	 *                                renewals so that the existing logic can be reuse for expiry date calculations
	 * @param  ruleType             : expiry rule type
	 * @param  day                  : expiry day
	 * @param  month                : expiry month
	 * @param  cycle                : expiry cycle
	 * @param  period               : expiry period
	 * @param  renewalWindow        : renewal Window
	 * @param  openForRenewal       : open For Renewal
	 * @return                      : returns RegulatoryAuthorizationType Record
	 * @last modified by            : MTX Group Inc
	 * @last modified date          :
	 */
	public static RegulatoryAuthorizationType getRegAuthTypeToCalculateExpiryDate(
		String ruleType,
		String day,
		String month,
		String cycle,
		String period,
		Integer renewalWindowBeforeExpiry,
		Integer openForRenewal
	) {
		RegulatoryAuthorizationType regAuthRecord = new RegulatoryAuthorizationType();
		regAuthRecord.Expiry_Rule_Type__c = ruleType;
		regAuthRecord.Expiration_Day__c = day;
		regAuthRecord.Expiration_Month__c = month;
		regAuthRecord.Expiration_Cycle__c = cycle;
		regAuthRecord.Expiration_Period__c = period;
		regAuthRecord.Renewal_Window_Period_Before_Expiry__c = renewalWindowBeforeExpiry;
		regAuthRecord.Open_for_Renewal__c = openForRenewal;
		return regAuthRecord;
	}

	/**
	 * @author                      : MTX Group Inc
	 * @since                       : 16 Feb 2023
	 * @description                 : This method used to calculate expiration period incase of 'n' years from approval
	 * @param regAuth               : RegAuthType
	 * @param yearsFromApproval     : No of years from approval
	 * @retun                       : 'Datetime'
	 * @last modified by            : MTX Group Inc
	 * @last modified date          :
	 * @modified details            :
	 */
	public static Datetime getExpiryDateFromExpirationCycle(
		RegulatoryAuthorizationType regAuth,
		Integer yearsFromApproval
	) {
		DateTime periodEnd;
		Integer endMonth = Integer.valueOf(regAuth.Expiration_Month__c.substring(0, 2));

		
		Date expiryTemp = Date.newinstance(
			Date.today().year() + yearsFromApproval,
			endMonth,
			Integer.valueOf(regAuth.Expiration_Day__c)
		);

		
		if (regAuth.Open_for_Renewal__c != null && regAuth.Open_for_Renewal__c != 0) {
			Date dateBeforeRenewalExpiry = expiryTemp.addMonths(
				-Integer.valueOf(
					regAuth.Renewal_Window_Period_Before_Expiry__c != null
						? regAuth.Renewal_Window_Period_Before_Expiry__c
						: 0
				)
			);
			
			if (Date.today() >= dateBeforeRenewalExpiry) {
				periodEnd = Datetime.newinstance(
					expiryTemp.year() + yearsFromApproval,
					endMonth,
					Integer.valueOf(regAuth.Expiration_Day__c),
					0,
					0,
					0
				);
			} else {
				periodEnd = Datetime.newinstance(
					expiryTemp.year(),
					endMonth,
					Integer.valueOf(regAuth.Expiration_Day__c),
					0,
					0,
					0
				);
			}
		} else {
			periodEnd = Datetime.newinstance(
				expiryTemp.year(),
				endMonth,
				Integer.valueOf(regAuth.Expiration_Day__c),
				0,
				0,
				0
			);
		}
		return periodEnd;
	}

	/**
	 * @author                      : MTX Group Inc
	 * @since                       : 13 Mar 2023
	 * @description                 : This method used to calculate expiration date incase of Nursing Schools and Approval Status is full approval
	 * @retun                       : 'Datetime'
	 * @last modified by            : MTX Group Inc
	 * @last modified date          :
	 * @modified details            :
	 */
	public static Datetime calculateExpiryDateInternalForNursingSchools() {
		DateTime expirationDate;
		RegulatoryAuthorizationType tempRegAuth = getRegAuthTypeToCalculateExpiryDate(
			LPI_LiteralConstant.EXPIRY_RULE_TYPE_DAY_MONTH_CYCLE,
			EXPIRATION_DAY,
			EXPIRATION_MONTH,
			LPI_LiteralConstant.EXPIRATION_CYCLE_FIVE_YEARS,
			null,
			null,
			null
		);
		return getExpirationDate(tempRegAuth);
	}

	/**
	 * @author                      : MTX Group Inc
	 * @since                       : 13 Mar 2023
	 * @description                 : check for special char in string
	 * @retun                       : 'Boolean'
	 */
	public static boolean checkForSpecialCharInString(String stringValue) {
		Pattern namePattern = Pattern.compile('^[A-Za-z0-9- ]+$');
		Matcher nameMatcher = namePattern.matcher(stringValue);
		if (nameMatcher.matches()) {
			return true;
		}
		return false;
	}
	/**
	 * @author                      : MTX Group Inc
	 * @since                       : 8 Apr 2023
	 * @description                 : get masked data
	 * @retun                       : string
	 */
	public static String getMaskedData(String stringValue) {
		if (String.isNotBlank(stringValue)) {
			String output = '';
			if (stringValue.length() > 4) {
				String lastString = stringValue.right(4);
				String leftString = stringValue.left(stringValue.length() - 4);
				leftString = leftString.replaceAll('[a-z]', 'X');
				leftString = leftString.replaceAll('[0-9]', 'X');
				leftString = leftString.replaceAll('[A-Z]', 'X');
				return leftString + lastString;
			} else {
				return stringValue;
			}
		}
		return null;
	}

	public static Date getRequiredDate(Date dt, Integer mnths) {
		if (dt == null) {
			return dt;
		}
		return dt.addMonths(mnths);
	}

	public static void populateSubjectReportDates(PersonEducation peRecord, Date effectiveDate, Integer monthsToAdd) {
		if (peRecord == null || effectiveDate == null || monthsToAdd == null) {
			return;
		}
		peRecord.StartDate = DateTime.newInstance(
			effectiveDate.year(),
			effectiveDate.month(),
			effectiveDate.day(),
			0,
			0,
			0
		); 
		Date nwDt = effectiveDate.addMonths(monthsToAdd).toStartofMonth().addDays(-1); 
		peRecord.CompletionDate = DateTime.newInstance(nwDt.year(), nwDt.month(), nwDt.day(), 0, 0, 0);
	}

	/**
	 * @description : Method to return the duplicate records by email matching, for the passsed Account list.
	 * @author MTX Group Inc | 08-08-2023
	 * @param accountList
	 * @return List<Account>
	 **/
	public static List<Account> getDuplicateRecordsByEmail(List<Account> accountList) {
		try {
			Map<Id, String> accountToEmailMap = new Map<Id, String>();
			for (Account acc : accountList) {
				if (
					String.isNotblank(acc.PersonEmail) && acc.RecordTypeId == LPI_LiteralConstant.PERSON_ACCOUNT_REC_TYPE_ID
				) {
					accountToEmailMap.put(acc.Id, acc.PersonEmail);
				}
			}
			List<Account> accRecord = new List<Account>();
			if (!accountToEmailMap.isEmpty()) {
				String accFields = 'Id, PersonEmail, Name, Social_Security_Number__c ';
				String accWhere = 'PersonEmail IN ' + getStringValuesByList(accountToEmailMap.values());
				LPI_AccountDAO.LPI_AccountWithoutSharingDAO accObj = new LPI_AccountDAO.LPI_AccountWithoutSharingDAO();
				accRecord = accObj.getAccountByDymanicQuery(accFields, accWhere, null, null, null);
			}
			return accRecord;
		} catch (Exception e) {
			LPI_ExceptionManager.logException('LPI_ServiceUtility', 'getDuplicateRecordsByEmail', e);
			throw new AuraHandledException(e.getMessage() + e.getLineNumber());
		}
	}

	/**
	 * @description : Method to return the duplicate records by email matching, for the passsed Account list.
	 * @author MTX Group Inc | 08-08-2023
	 * @param accountList
	 * @return List<Account>
	 **/
	public static List<Account> getDuplicateRecordsBySSN(List<Account> accountList) {
		try {
			Map<Id, String> accountToSSNMap = new Map<Id, String>();
			for (Account acc : accountList) {
				if (
					String.isNotblank(acc.Social_Security_Number__c) &&
					acc.RecordTypeId == LPI_LiteralConstant.PERSON_ACCOUNT_REC_TYPE_ID
				) {
					accountToSSNMap.put(acc.Id, acc.Social_Security_Number__c);
				}
			}
			List<Account> accRecord = new List<Account>();
			if (!accountToSSNMap.isEmpty()) {
				String accFields = 'Id, PersonEmail, Name, Social_Security_Number__c ';
				String accWhere = 'Social_Security_Number__c IN ' + getStringValuesByList(accountToSSNMap.values());
				LPI_AccountDAO.LPI_AccountWithoutSharingDAO accObj = new LPI_AccountDAO.LPI_AccountWithoutSharingDAO();
				accRecord = accObj.getAccountByDymanicQuery(accFields, accWhere, null, null, null);
			}
			return accRecord;
		} catch (Exception e) {
			LPI_ExceptionManager.logException('LPI_ServiceUtility', 'getDuplicateRecordsBySSN', e);
			throw new AuraHandledException(e.getMessage() + e.getLineNumber());
		}
	}

	/**
	 * @author                          :MTX Group Inc
	 * @since                           : 12 sep 2023
	 * @description                     : getiing Accoun tFor Business Notification
	 * @param accountIdToBlaMap         : account Id to bl/Bla
	 * @param includeAuthorizedConRole  : include Authorized Contact
	 * @retun                           : getting account and email map associated to that bla or bl
	 * @last modified by                : MTX Group Inc
	 */
	public static Map<Id, Map<String, String>> getAccountForBusinessNotification(
		Map<String, SObject> accountIdToBlaMap,
		Boolean includeAuthorizedConRole
	) {
		try {
			List<String> rolesInclude = new List<String>{
				LPI_LiteralConstant.ROLE_OWNER,
				LPI_LiteralConstant.ROLE_DESIGNATED_INCHARGE
			};
			Map<Id, Map<String, String>> blaIdToAccountMap = new Map<Id, Map<String, String>>();
			if (includeAuthorizedConRole) {
				rolesInclude.add(ROLE_AUTHORISED_CONTACT);
			}
			if (!accountIdToBlaMap.isEmpty()) {
				List<Account> accontData = new LPI_AccountDAO.LPI_AccountWithoutSharingDAO()
					.getAccountByDymanicQuery(
						'Id,ParentId,Parent.Buisness_Email__c,Buisness_Email__c',
						' Id IN ' + getStringValuesByStringSet(accountIdToBlaMap.keySet()),
						null,
						null,
						null
					);
				for (Account acc : accontData) {
					String blaId = (String) accountIdToBlaMap.get(acc.Id).get('Id');
					if (!blaIdToAccountMap.containsKey(blaId)) {
						blaIdToAccountMap.put(blaId, new Map<String, String>());
					}
					if (String.isNotEmpty(acc.Buisness_Email__c)) {
						blaIdToAccountMap.get(blaId).put(acc.Id, acc.Buisness_Email__c);
					}
					if (
						acc.ParentId != null &&
						!blaIdToAccountMap.get(blaId).containsKey(acc.ParentId) &&
						acc.Parent.Buisness_Email__c != null
					) {
						accountIdToBlaMap.put(acc.ParentId, accountIdToBlaMap.get(acc.Id));
						blaIdToAccountMap.get(blaId).put(acc.ParentId, acc.Parent.Buisness_Email__c);
					}
				}
				for (
					Business_Relationships__c brRec : new LPI_BusinessRelationshipDAO.LPI_BusinessRelationshipsWithoutSharingDAO()
						.getBusinessRelationshipsByDymanicQuery(
							'Id,IsActive__c,Related_To__c,Related_From__c,Related_To__r.PersonEmail,Related_From__r.ParentId,Related_From__r.Parent.PersonEmail,Roles__c,Related_From__r.Buisness_Email__c',
							'Roles__c IN ' +
								getStringValuesByList(rolesInclude) +
								' AND (Related_From__c IN ' +
								getStringValuesByStringSet(accountIdToBlaMap.keySet()) +
								' OR Related_To__c IN ' +
								getStringValuesByStringSet(accountIdToBlaMap.keySet()) +
								')',
							null,
							null,
							null
						)
				) {
					String blaId;
					String boardName;
					if (accountIdToBlaMap.containsKey(brRec.Related_From__c)) {
						blaId = (String) accountIdToBlaMap.get(brRec.Related_From__c).get('Id');
						boardName = (String) accountIdToBlaMap.get(brRec.Related_From__c).get('Board_Name__c');
					} else {
						if (accountIdToBlaMap.containsKey(brRec.Related_To__c)) {
							blaId = (String) accountIdToBlaMap.get(brRec.Related_To__c).get('Id');
							boardName = (String) accountIdToBlaMap.get(brRec.Related_To__c).get('Board_Name__c');
						}
					}
					if (
						PHARMACY_BOARD_NAME.equalsIgnoreCase(boardName) &&
						brRec.Roles__c == LPI_LiteralConstant.ROLE_DESIGNATED_INCHARGE
					) {
						continue;
					}
					if (String.isNotEmpty(blaId)) {
						if (!blaIdToAccountMap.containsKey(blaId)) {
							blaIdToAccountMap.put(blaId, new Map<String, String>());
						}
						if (String.isNotEmpty(brRec.Related_To__r.PersonEmail)) {
							blaIdToAccountMap.get(blaId).put(brRec.Related_To__c, brRec.Related_To__r.PersonEmail);
						}
						if (String.isNotEmpty(brRec.Related_From__r.Buisness_Email__c)) {
							blaIdToAccountMap.get(blaId)
								.put(brRec.Related_From__c, brRec.Related_From__r.Buisness_Email__c);
						}
					}
				}
			}
			return blaIdToAccountMap;
		} catch (Exception e) {
			LPI_ExceptionManager.logException('LPI_ServiceUtility', 'getAccountForBusinessNotification', e);
			throw new AuraHandledException(e.getMessage());
		}
	}

	/**
	 * @author                      : MTX Group Inc
	 * @since                       : 22 Sep 2023
	 * @description                 : This method retrieves Mailing addresses for given business IDs.
	 * @param businessIds           : Set of business IDs for which mailing addresses need to be retrieved.
	 * @return                      : A map containing the mailing addresses (Address) associated with the business IDs (Id).
	 * @last modified by            : MTX Group Inc
	 * @last modified date          : (Add if modified by you)
	 * @last modified details       : (Add if modified by you)
	 */
	public static Map<Id, Schema.Address> getBusinessAddresses(Set<Id> businessIds, String LocationType) {
		try {
			Map<Id, Id> locIdToBlIdMap = new Map<Id, Id>();
			Map<Id, Schema.Address> blToAddrMap = new Map<Id, Schema.Address>();
			String fieldsToQuery = 'AuthorizationId,PlaceId,TYPEOF Place WHEN Location THEN LocationType END';
			String whereClause = 'AuthorizationId IN' + LPI_ServiceUtility.getStringValuesBySet(businessIds);

			
			for (
				AuthApplicationPlace aap : LPI_AuthApplicationPlaceDAO.getAuthApplicationPlaceByDymanicQuery(
					fieldsToQuery,
					whereClause,
					null,
					null,
					null
				)
			) {
				locIdToBlIdMap.put(aap.PlaceId, aap.AuthorizationId);
			}

			
			if (!locIdToBlIdMap.isEmpty()) {
				
				fieldsToQuery = 'ParentId,Street, city,state,country,PostalCode,LocationType,Address,Business_State__c';

				 
				whereClause =
					'Parent.Status__c = \'Open\' AND Parent.OpenDate != null AND Parent.CloseDate = null AND ParentId IN' +
					LPI_ServiceUtility.getStringValuesBySet(locIdToBlIdMap.keySet()) +
					' AND LocationType = \'' +
					LocationType +
					'\'';
				 
				LPI_AddressDAO.LPI_AddressDAOWithoutSharing addWithoutSharing = new LPI_AddressDAO.LPI_AddressDAOWithoutSharing();
				for (
					Schema.Address adr : addWithoutSharing.getAddressByDymanicQuery(
						fieldsToQuery,
						whereClause,
						null,
						null,
						null
					)
				) {
					if (
						String.isNotBlank(adr.city) &&
						(String.isNotBlank(adr.state) || String.isNotBlank(adr.Business_State__c)) &&
						String.isNotBlank(adr.postalcode) &&
						String.isNotBlank(adr.street)
					) {
						Id businessLicenseId = locIdToBlIdMap.get(adr.ParentId);
						Schema.Address address = new Schema.Address();
						address.Street = adr.street;
						address.PostalCode = adr.postalcode;
						address.City = adr.city;
						address.Country = adr.country;
						if (adr.Country == UNITED_STATES) {
							address.State = adr.state;
						} else {
							address.State = adr.Business_State__c;
						}
						blToAddrMap.put(businessLicenseId, address);
					}
				}
			}
			 
			return blToAddrMap;
		} catch (Exception ex) {
			LPI_ExceptionManager.logException('LPI_ServiceUtility', 'getBusinessAddresses', ex);
			throw new AuraHandledException(ex.getMessage());
		}
	}

	/**
	 * @author                      : MTX Group Inc
	 * @since                       : 28 Dec 2023
	 * @description                 : This method will give the overriden subtype value for any subtype
	 * @param boardName             : String (Name of the board)
	 * @param licenseTypeName       : String (Name of the license type)
	 * @param genricSubtypeLabel    : String (Subtype label)
	 * @return                      : String (Overriden subtype label if any otherwise same value as genricSubtypeLabel)
	 * @last modified by            : MTX Group Inc
	 * @last modified date          : (Add if modified by you)
	 * @last modified details       : (Add if modified by you)
	 */
	public static String getSubtypeLabelToShow(String boardName, String licenseTypeName, String genricSubtypeLabel, String type) {
		boardName = boardName.replaceAll('\'', '');
		licenseTypeName = licenseTypeName.replaceAll('\'', '');
		genricSubtypeLabel = genricSubtypeLabel.replaceAll('\'', '');
		type = type.replaceAll('\'', '');
		String fieldsToQuery = 'Overriden_Subtype__c';
		String whereClause =
			'Board_Name__c = \'' +
			boardName +
			'\'' +
			' AND License_Type__c = \'' +
			licenseTypeName +
			'\'' +
			' AND Generic_Subtype__c = \'' +
			genricSubtypeLabel + '\'' +
			' AND Type__c = \'' +
			type +
			'\'';

		List<Application_SubType_Override_Metadata__mdt> mdtList = LPI_AppSubtypeOverrideMdtDAO.getAppSubtypeOverrideByDymanicQuery(
			fieldsToQuery,
			whereClause,
			null,
			null,
			null
		);
		if (!mdtList.isEmpty()) {
			return mdtList[0].Overriden_Subtype__c + ' ( ' + genricSubtypeLabel + ' )';
		}
		return genricSubtypeLabel;
	}

	/**
	 * @author                      : MTX Group Inc
	 * @since                       : 28 Dec 2023
	 * @description                 : This method will give the overriden subtype value for any subtype
	 * @param licenseType            : Set<String>
	 * @return                      : Map<String, String>
	 * @last modified by            : MTX Group Inc
	 * @last modified date          : (Add if modified by you)
	 * @last modified details       : (Add if modified by you)
	 */
	public static Map<String, String> getSubTypeLabelToShowMap(Set<String> licenseType) {
		Map<String, String> resultMap = new Map<String, String>();
		String fieldsToQuery = 'License_Type__c,Generic_Subtype__c,Overriden_Subtype__c,Type__c';
		String whereClause = 'License_Type__c IN ' + LPI_ServiceUtility.getStringValuesByStringSet(licenseType);
		for (
			Application_SubType_Override_Metadata__mdt mdtRecord : LPI_AppSubtypeOverrideMdtDAO.getAppSubtypeOverrideByDymanicQuery(
				fieldsToQuery,
				whereClause,
				null,
				null,
				null
			)
		) {
			String key = mdtRecord.License_Type__c + ' ' + mdtRecord.Type__c + ' ' + mdtRecord.Generic_Subtype__c;
			resultMap.put(key, mdtRecord.Overriden_Subtype__c + ' ( ' + mdtRecord.Generic_Subtype__c + ' )');
		}
		return resultMap;
	}

	/**
	 * @author                      : MTX Group Inc
	 * @since                       : 02 Jan 2024
	 * @description                 : This method will give the all renewal period list after the licnese issue
	 * @param businessLicenseIds    : Set<Id>
	 * @return                      : Map<Id,List<RenewalPeriod>>
	 * @last modified by            : MTX Group Inc
	 * @last modified date          : (Add if modified by you)
	 * @last modified details       : (Add if modified by you)
	 */
	public static Map<Id, List<RenewalPeriod>> getLicenseCycles(Set<Id> businessLicenseIds) {
		if (businessLicenseIds.isEmpty()) {
			return null;
		}
		Map<Id, List<RenewalPeriod>> blIdToPeriodListMap = new Map<Id, List<RenewalPeriod>>();
		String queryFields =
			'Id,PeriodStart,PeriodEnd,RegulatoryAuthorizationType.Renewal_Window_Period_Before_Expiry__c,' +
			'RegulatoryAuthorizationType.Expiry_Rule_Type__c,RegulatoryAuthorizationType.Expiration_Cycle__c,' +
			'RegulatoryAuthorizationType.Expiration_Fixed_Cycle_Difference__c,RegulatoryAuthorizationType.Expiration_Period__c,' +
			'RegulatoryAuthorizationType.Expiration_Day__c,RegulatoryAuthorizationType.Expiration_Month__c,' +
			'RegulatoryAuthorizationType.Open_for_Renewal__c,RegulatoryAuthorizationType.Late_Renewal_Allowed__c,' +
			'RegulatoryAuthorizationType.Extended_Expiry_Period__c,' +
			'RegulatoryAuthorizationType.Subsequent_Reinstatement_Period__c,Reinstatement_Count__c,';

		queryFields +=
			'(Select Id,Current_Reporting_Start_Date__c,Current_Reporting_End_Date__c From Audit_Details__r WHERE ' +
			'RecordType.DeveloperName = \'' +
			RECORD_TYPE_CE_AUDIT +
			'\'' +
			' Order by Current_Reporting_End_Date__c DESC)';
		String whereClause = 'Id IN ' + LPI_ServiceUtility.getStringValuesBySet(businessLicenseIds);

		
		for (BusinessLicense bl : LPI_BusinessLicenseDAO.fetchBusinessLicenseRecords(queryFields, whereClause)) {
			
			if (!blIdToPeriodListMap.containsKey(bl.Id)) {
				blIdToPeriodListMap.put(bl.Id, new List<RenewalPeriod>());
			}
			
			Date startDate = (Date) LPI_DocumentConfigGeneratorUtil.calculateExpiryRelatedDates(bl)
				.get('CurrentRenewCycleStartDate');
			Date endDate = Date.newInstance(bl.PeriodEnd.year(), bl.PeriodEnd.month(), bl.PeriodEnd.day());
			Date issuanceDate = Date.newInstance(bl.PeriodStart.year(), bl.PeriodStart.month(), bl.PeriodStart.day());
			Integer auditDetailsSize = bl.Audit_Details__r.size();
			Integer currAuditIndex = 0;
			
			do {
				
				if (
					currAuditIndex < auditDetailsSize &&
					bl.Audit_Details__r[currAuditIndex].Current_Reporting_Start_Date__c == startDate &&
					bl.Audit_Details__r[currAuditIndex].Current_Reporting_End_Date__c == endDate
				) {
					blIdToPeriodListMap.get(bl.Id)
						.add(new RenewalPeriod(startDate, endDate, bl.Audit_Details__r[currAuditIndex]));
					currAuditIndex++;
				} 
				
				else {
					blIdToPeriodListMap.get(bl.Id).add(new RenewalPeriod(startDate, endDate, null));
				}

				
				endDate = startDate.addDays(-1);
				bl.periodEnd = Datetime.newInstance(endDate.year(), endDate.month(), endDate.day());
				startDate = (Date) LPI_DocumentConfigGeneratorUtil.calculateExpiryRelatedDates(bl)
					.get('CurrentRenewCycleStartDate');

			} while (startDate > issuanceDate);
		}

		return blIdToPeriodListMap;
	}

	/**
     * @author                      : MTX Group Inc
     * @since                       : January 18, 2024
     * @description                 : This method converts a given string to Title Case where the first letter of every word is capitalised and the rest are small
     * @param sentence              : It contains the string or sentence or phrase which needs to be converted to Title Case
     * @return                      : `String` (Title Case string or sentence or phrase)
     * @last modified by            : MTX Group Inc
     * @last modified date          : {Add if modified by you}
     * @last modified details       : {Add if modified by you}
     */
	public static String toTitleCase(String sentence) {
		String titlePhrase = '';
		
		Set<String> forceLower = new Set<String>{'of', 'the', 'for', 'and', 'a', 'to', 'at' ,'an', 'but', 'if', 'or', 'nor', 'and/or'};
		if (String.isNotBlank(sentence)) {
			String[] splitPhrase = sentence.trim().split(' ');
			for (Integer i = 0; i < splitPhrase.size(); i++) {
				if (!forceLower.contains(splitPhrase[i].toLowerCase()) || i == 0 || i == (splitPhrase.size()-1)) {
					titlePhrase += (splitPhrase[i].substring(0,1).toUpperCase()) + (splitPhrase[i].substring(1).toLowerCase()) + ' ';
				}
				else {
					titlePhrase += splitPhrase[i].toLowerCase() + ' ';
				}
			}
		}
		return titlePhrase.trim();
	}

	/**
	 * @author                      :MTX Group Inc
	 * @since                       : 23rd June, 2023
	 * @description                 : This method will give the list of Configuration record for Adobe Document
	 * @param  boardName            : String
	 * @param  licenseType          : String
	 * @param  status            	: String
	 * @param  whereToShow          : String
	 * @return                      : List<LPI_Document_Action_Config__mdt>
	 * @last modified by            : MTX Group Inc
	 * @last modified date          : (Add if modified by you)
	 * @last modified details       : (Add if modified by you)
	 */
	public static List<LPI_Document_Action_Config__mdt> getDocActionConfig(
		String boardName,
		String licenseType,
		String status,
		String whereToShow,
		Map<String, Object> dataMap
	) {
		String fieldToQuery =
			'DeveloperName, Board_Name__c,License_Type_Name__c,Eligible_Status__c,Template_Name__c,Button_Label__c,' +
			'Days_From_Submission__c,License_Question_Condition__c,Application_Type__c,Applicable_BL_Status__c,Configured_In_Salesforce_Only__c';
		String whereClause = 'Where_To_Show__c = \'' + whereToShow + '\'';

		Boolean isPortalUser = LPI_WithoutSharingUtility.isPortalUser();

		if (isPortalUser) {
			whereClause += ' AND Show_To_Portal_User__c = true';
		}

		String whereClauseForRenewalForm =
			whereClause +
			' AND Is_Renewal_Form__c = true AND Board_Name__c = \'' +
			boardName +
			'\' AND License_Type_Name__c = \'' +
			String.escapeSingleQuotes(licenseType) +
			'\'' +
			' AND (Applicable_BL_Status__c = null OR Applicable_BL_Status__c = \'' +
			status +
			'\')';
		String whereClauseForReinstatementForm =
			whereClause +
			' AND Is_Reinstatement_Form__c = true AND Board_Name__c = \'' +
			boardName +
			'\' AND License_Type_Name__c = \'' +
			String.escapeSingleQuotes(licenseType) +
			'\'' +
			' AND (Applicable_BL_Status__c = null OR Applicable_BL_Status__c = \'' +
			status +
			'\')';
		String whereClauseForOthers =
			whereClause + ' AND Is_Renewal_Form__c = false AND Is_Reinstatement_Form__c = false';

		List<LPI_Document_Action_Config__mdt> metdataList = new List<LPI_Document_Action_Config__mdt>();

		
		List<LPI_Document_Action_Config__mdt> renewalFormMetadataList = LPI_DocumentActionConfigDAO.getDocumentActionConfigByDymanicQuery(
			fieldToQuery,
			whereClauseForRenewalForm,
			'1',
			'Applicable_BL_Status__c',
			'ASC NULLS Last'
		);
		
		List<LPI_Document_Action_Config__mdt> reinstatementFormMetadataList = LPI_DocumentActionConfigDAO.getDocumentActionConfigByDymanicQuery(
			fieldToQuery,
			whereClauseForReinstatementForm,
			'1',
			'Applicable_BL_Status__c',
			'ASC NULLS Last'
		);

		
		List<LPI_Document_Action_Config__mdt> otherMetadataList = LPI_DocumentActionConfigDAO.getDocumentActionConfigByDymanicQuery(
			fieldToQuery,
			whereClauseForOthers,
			null,
			null,
			null
		);

		
		if (!renewalFormMetadataList.isEmpty()) {
			if (dataMap.containsKey('isRenewalEligible') && dataMap.get('isRenewalEligible') == true) {
				metdataList.add(renewalFormMetadataList[0]);
			}
		}

		if (!reinstatementFormMetadataList.isEmpty()) {
			if (dataMap.containsKey('isReinstatementEligible') && dataMap.get('isReinstatementEligible') == true) {
				metdataList.add(reinstatementFormMetadataList[0]);
			}
		}
		
		for (LPI_Document_Action_Config__mdt docActionConfig : otherMetadataList) {
			Set<String> eligibleStatusSet = new Set<String>(docActionConfig.Eligible_Status__c.split(';'));
			Set<String> eligibleBoardSet = new Set<String>(docActionConfig.Board_Name__c.split(';'));
			Set<String> eligibleLicenseSet = new Set<String>(docActionConfig.License_Type_Name__c.split(';'));

			
			Boolean showButton =
				(eligibleStatusSet.contains(TYPE_ALL) || eligibleStatusSet.contains(status)) &&
				(eligibleBoardSet.contains(TYPE_ALL) || eligibleBoardSet.contains(boardName)) &&
				(eligibleLicenseSet.contains(TYPE_ALL) || eligibleLicenseSet.contains(licenseType));

			
			if (docActionConfig.Days_From_Submission__c != null && dataMap.containsKey('AppliedDate')) {
				DateTime appliedDate = (DateTime) dataMap.get('AppliedDate');
				DateTime lastDate = appliedDate.addDays((Integer) docActionConfig.Days_From_Submission__c);
				showButton = showButton && (System.now() <= lastDate);
			}

			
			if (docActionConfig.License_Question_Condition__c != null && dataMap.containsKey('LicenseQuestion')) {
				Map<String, Object> applicationQuestions = (Map<String, Object>) dataMap.get('LicenseQuestion');
				List<String> condition = docActionConfig.License_Question_Condition__c.split(':');
				if (
					applicationQuestions.containsKey(condition[0]) &&
					String.valueOf(applicationQuestions.get(condition[0])) != condition[1]
				) {
					showButton = false;
				}
			}

			
			if (
				whereToShow == LPI_ApplicationActionsController.APPLICATION_DETAIL_PAGE &&
				docActionConfig.Application_Type__c != null &&
				dataMap.containsKey('ApplicationType')
			) {
				String appType = String.valueOf(dataMap.get('ApplicationType'));
				showButton = showButton && (appType == docActionConfig.Application_Type__c);
			}

			
			if (showButton) {
				metdataList.add(docActionConfig);
			}
		}

		return metdataList;
	}

	/**
	 * @author                      : MTX Group Inc
	 * @since                       : 02 Jan, 2024
	 * @description                 : Wrapper class for Renewal Period
	 * @last modified by            : MTX Group Inc
	 * @last modified date          : (Add if modified by you)
	 * @last modified details       : (Add if modified by you)
	 */
	public class RenewalPeriod {
		public Date startDate;
		public Date endDate;
		public Audit_Detail__c auditRecord;
		public RenewalPeriod(Date startDate, Date endDate, Audit_Detail__c auditRecord) {
			this.startDate = startDate;
			this.endDate = endDate;
			this.auditRecord = auditRecord;
		}
	}


	public class DueDiligenceNotificationWrapper {
		Notification_Message__mdt metaDataRec;
		String emailTemplateName;
		Boolean hasReplacebleText;
		Map<String, String> replaceTextMap;
		String salutation;
		String emailAddress;
		String signature;
		Boolean isIsAttachmentsRequired;
		String relatedRecordIds;
		Id accountId;
		Id applicationId;
		Deficiency__c defObj;
	}
}