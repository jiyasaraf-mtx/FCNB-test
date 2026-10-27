/**
 * @author                      : MTX Group Product Team
 * @since                       :
 * @description                 : Audit Detail View Page Controller
 * @last modified by            :MTX Group Product Team
 * @last modified date          :
 * @modified details            :
 */
public with sharing class LPI_AuditDetailController {
	public static final String CLASS_NAME = 'LPI_AuditDetailController';
	public static final String PROFILE_PORTAL_USER = 'Portal User';
	private static final String STATUS_ADDITIONAL_INFO = 'Additional Info Needed';
	private static final Set<String> AUDIT_RECORD_TYPE_SET = new Set<String>{
		'Certification_Audit',
		'CE_Audit',
		'Insurance_Audit'
	};
	private static final String CE_AUDIT = 'CE_Audit';
	private static final Set<String> APPROVED_TCP_STATUS = new Set<String>{ 'Approved' };
	private static final STRING STATUS_COMPLETED = 'Completed';
	private static final Set<String> AUDIT_DETAIL_STATUS = new Set<String>{ 'Additional Info Needed', 'In Progress' };
	public static final string COURSE_SUB_AREA = 'Course Subject Area';

	/**
	 * @author                      : MTX Group Product Team
	 * @since                       : 8 Oct 2023
	 * @description                 : This method will fetch audit related data
	 * @param audId                 : Audit Detail Record Id
	 * @return                      : AuditDataWrapper
	 * @last modified by            : MTX Group Product Team
	 * @last modified date          :
	 * @modified details            :
	 */
	@AuraEnabled
	public static AuditDataWrapper getAuditData(String audId, String notificationId) {
		try {
			List<Audit_Detail__c> auditDetailsList = LPI_AuditDetailsDAO.getAuditDetailsByDymanicQuery(
				'Id, No_Response_Notification_Date__c,Cure_Hours__c,Cure_Hours_Year__c,Grace_Period__c,Status__c,Extension_Date__c',
				'Id = \'' + String.escapeSingleQuotes(audId) + '\'',
				null,
				null,
				null
			);
			if (!auditDetailsList.isEmpty()) {
				Date endDate = (auditDetailsList[0].Grace_Period__c && auditDetailsList[0].Extension_Date__c != null)
					? auditDetailsList[0].Extension_Date__c
					: (auditDetailsList[0].No_Response_Notification_Date__c == null
							? Date.today()
							: auditDetailsList[0].No_Response_Notification_Date__c);
				Boolean isAllowed = endDate >= Date.today() &&
					AUDIT_DETAIL_STATUS.contains(auditDetailsList[0].Status__c)
					? true
					: false;
				if (!isAllowed && notificationId != null) {
					deletePortalNotification(notificationId);
				}
				AuditDataWrapper auditData = new AuditDataWrapper(isAllowed, auditDetailsList[0].Grace_Period__c);
				return auditData;
			}
			return null;
		} catch (Exception e) {
			LPI_ExceptionManager.logException(CLASS_NAME, 'getAuditData', e);
			throw new AuraHandledException(e.getMessage());
		}
	}
	/**
	 * @author                      : MTX Group Product Team
	 * @since                       : 8 Oct 2023
	 * @description                 : This method will delete Portal Notification
	 * @param notificationId        : Portal Notification Record Id
	 * @last modified by            : MTX Group Product Team
	 * @last modified date          :
	 * @modified details            :
	 */
	private static void deletePortalNotification(String notificationId) {
		try {
			if (String.isNotBlank(notificationId)) {
				Notification__c pn = new Notification__c();
				pn.Id = notificationId;
				LPI_WithoutSharingUtility.deleteSObject(pn);
			}
		} catch (Exception e) {
			LPI_ExceptionManager.logException(CLASS_NAME, 'deletePortalNotification', e);
			throw new AuraHandledException(e.getMessage());
		}
	}

	/**
	 * @author                      : MTX Group Product Team
	 * @since                       : 14 Sep 2023
	 * @description                 : This method will fetch TrainingCourseParticipant records which are linked to Audit Detail record
	 *                                 
	 * @param audId                 : Audit Detail Record Id
	 * @return                      : `List<AuditDetailWrapper>`
	 * @last modified by            : MTX Group Product Team
	 * @last modified date          :
	 * @modified details            :
	 */
	@AuraEnabled(cacheable=true)
	public static List<AuditDetailWrapper> getTrainingCourseParticiantRecords(String audId) {
		List<AuditDetailWrapper> auditDetailWrapperList = new List<AuditDetailWrapper>();
		try {
			if (String.isBlank(audId)) {
				return null;
			}

			 
			String fieldToQuery =
				'Id, Business_License__c, Name, Audit_End_Date__c, Audit_Start_Date__c, Audit_Type__c, ' +
				'RecordType.DeveloperName, Business_License__r.Id, Business_License__r.Board_Name__c,Cure_Hours__c,Cure_Hours_Year__c,Grace_Period__c';
			String whereClause = 'Id = \'' + String.escapeSingleQuotes(audId) + '\'';

			List<Audit_Detail__c> auditDetailsList = LPI_AuditDetailsDAO.getAuditDetailsByDymanicQuery(
				fieldToQuery,
				whereClause,
				null,
				null,
				null
			);
			if (!auditDetailsList.isEmpty()) {
				if (auditDetailsList[0].RecordType.DeveloperName == CE_AUDIT) {
					fieldToQuery =
						'Id, Title__c, TotalHours, EndDate, Notes__c, Audit_Detail__c, ' +
						'Audit_Detail__r.RecordType.DeveloperName, Business_License__c, Business_License__r.Board_Name__c,' +
						'Year_CE_Hours_associated_with__c, Category__c,VerificationStatus,';

					fieldToQuery +=
						'(Select Id,Training_Course_Participant__c,Subject__c,Reported_Hours__c From Application_Contents__r WHERE Section_Header__c = \'' +
						COURSE_SUB_AREA +
						'\')';

					whereClause =
						'Business_License__c = \'' +
						String.escapeSingleQuotes(auditDetailsList[0].Business_License__c) +
						'\'' +
						' AND Audit_Detail__c = \'' +
						String.escapeSingleQuotes(audId) +
						'\'';

					List<TrainingCourseParticipant> tcpList = LPI_TrainingCourseParticipantDAO.getTrainingCourseParticipantByDymanicQuery(
						fieldToQuery,
						whereClause,
						null,
						null,
						null
					);
					if (!tcpList.isEmpty()) {
						for (TrainingCourseParticipant tcpRec : tcpList) {
							AuditDetailWrapper auditDetailWrapperItem = new AuditDetailWrapper(
								tcpRec.Title__c,
								(Integer) tcpRec.TotalHours,
								tcpRec.Notes__c,
								Date.valueOf(tcpRec.EndDate),
								tcpRec.Audit_Detail__c,
								tcpRec.Id,
								tcpRec.Audit_Detail__r.RecordType.DeveloperName,
								tcpRec.Business_License__r.Board_Name__c,
								!APPROVED_TCP_STATUS.contains(tcpRec.VerificationStatus),
								tcpRec.Business_License__c,
								tcpRec.Year_CE_Hours_associated_with__c,
								null,
								null,
								null,
								tcpRec.Category__c
							);
							for (Application_Content__c ac : tcpRec.Application_Contents__r) {
								auditDetailWrapperItem.subjectAreaList.add(
									new SubjectAreaWrapper(null,ac.Reported_Hours__c, ac.Id)
								);
							}
							auditDetailWrapperList.add(auditDetailWrapperItem);
						}
					} else {
						auditDetailWrapperList.add(
							new AuditDetailWrapper(
								auditDetailsList[0].Id,
								auditDetailsList[0].RecordType.DeveloperName,
								auditDetailsList[0].Business_License__r.Id,
								auditDetailsList[0].Business_License__r.Board_Name__c
							)
						);
					}
				} else if (auditDetailsList[0].RecordType.DeveloperName != CE_AUDIT) {
					auditDetailWrapperList.add(
						new AuditDetailWrapper(
							auditDetailsList[0].Id,
							auditDetailsList[0].RecordType.DeveloperName,
							auditDetailsList[0].Business_License__r.Id,
							auditDetailsList[0].Business_License__r.Board_Name__c
						)
					);
				}
			}
		} catch (Exception e) {
			LPI_ExceptionManager.logException(CLASS_NAME, 'getTrainingCourseParticiantRecords', e);
			throw new AuraHandledException(e.getMessage());
		}
		return auditDetailWrapperList;
	}
	/**
	 * @author                      : MTX Group Product Team
	 * @since                       : 15 Sep 2023
	 * @description                 : This method will create TrainingCourseParticipant records and link with audit detail record
	 *                                S-55551
	 * @param audId                 : Audit Detail Record Id
	 * @param courseData            : String
	 * @return                      : `Map<String, Object>`
	 * @last modified by            :  
	 * @last modified date          :
	 * @modified details            :
	 */
	@AuraEnabled
	public static AuditDetailWrapper createTrainingCourseParticiantRecords(String audId, String courseData, List<String> appRecordIdList) {
		try {
			if (String.isBlank(audId)) {
				return null;
			}
			List<Audit_Detail__c> auditDetailsList = LPI_AuditDetailsDAO.getAuditDetailsByDymanicQuery(
				'Id, Business_License__c, Name, Audit_End_Date__c, Audit_Start_Date__c, Audit_Type__c, Business_License__r.PeriodEnd',
				'Id = \'' + String.escapeSingleQuotes(audId) + '\'',
				null,
				null,
				null
			);
			AuditDetailWrapper tcpRecordWrapper = (AuditDetailWrapper) JSON.deserializeStrict(
				courseData,
				AuditDetailWrapper.class
			);

			TrainingCourseParticipant tcpRecord = new TrainingCourseParticipant();
			if (tcpRecordWrapper.courseId != null) {
				tcpRecord.Id = tcpRecordWrapper.courseId;
			}
			tcpRecord.Title__c = tcpRecordWrapper.course;
			tcpRecord.Notes__c = tcpRecordWrapper.notes;
			tcpRecord.TotalHours = tcpRecordWrapper.hours;
			tcpRecord.EndDate = tcpRecordWrapper.endDate;
			tcpRecord.Year_CE_Hours_associated_with__c = tcpRecordWrapper.yearCEHours;
			tcpRecord.Category__c = tcpRecordWrapper.courseCategory;
			tcpRecord.Audit_Detail__c = audId;
			tcpRecord.Business_License__c = auditDetailsList[0].Business_License__c;
			tcpRecordWrapper.courseId = LPI_DML.doUpsert(tcpRecord).Id;
			tcpRecordWrapper.editRequired = true;
			List<Application_Document__c> updateAppDocList = new List<Application_Document__c>();
			for(String appDocId : appRecordIdList){
				Application_Document__c appDoc = new Application_Document__c(Id = appDocId, Status__c = LPI_LiteralConstant.APPDOC_STATUS_SUBMITTED, Source_of_Document_Upload__c = Userinfo.getUserId(), Training_Course_Participant__c = tcpRecordWrapper.courseId);
				updateAppDocList.add(appDoc);
			}
			if(!updateAppDocList.isEmpty()){
				LPI_DML.doUpdate(updateAppDocList);
			}
			Set<Id> appContentIds = new Set<Id>();
			if (tcpRecordWrapper.subjectAreaList != null && !tcpRecordWrapper.subjectAreaList.isEmpty()) {
				List<Application_Content__c> appContentToUpsert = new List<Application_Content__c>();
				for (SubjectAreaWrapper subAreaWrapper : tcpRecordWrapper.subjectAreaList) {
					Application_Content__c appContent = new Application_Content__c(Id = subAreaWrapper.subjectAreaId);
					if (String.isNotBlank(subAreaWrapper.subjectAreaId)) {
						appContentIds.add((Id) subAreaWrapper.subjectAreaId);
					}
					appContent.Training_Course_Participant__c = (Id) tcpRecordWrapper.courseId;
					 
					appContent.Reported_Hours__c = subAreaWrapper.reportedHours;
					appContent.Section_Header__c = COURSE_SUB_AREA;
					appContentToUpsert.add(appContent);
				}
				 
				if (!appContentIds.isEmpty()) {
					String fieldToQuery = 'Id';
					String whereClause =
						'Training_Course_Participant__c = \'' +
						tcpRecordWrapper.courseId +
						'\'' +
						' AND Id Not IN ' +
						LPI_ServiceUtility.getStringValuesBySet(appContentIds) +
						' AND Section_Header__c = \'' +
						COURSE_SUB_AREA +
						'\'';
					List<Application_Content__c> appContentToBeDeleted = LPI_ApplicationContentDAO.getApplicationContentByDymanicQuery(
						fieldToQuery,
						whereClause,
						null,
						null,
						null
					);
					if (!appContentToBeDeleted.isEmpty()) {
						LPI_DML.doDelete(appContentToBeDeleted);
					}
				}

				if (!appContentToUpsert.isEmpty()) {
					List<Application_Content__c> upsertedSubjects = (List<Application_Content__c>) LPI_DML.doUpsert(
						appContentToUpsert
					);
					for (integer i = 0; i < upsertedSubjects.size(); i++) {
						tcpRecordWrapper.subjectAreaList[i].subjectAreaId = upsertedSubjects[i].Id;
					}
				}
			}
			return tcpRecordWrapper;
		} catch (Exception e) {
			LPI_ExceptionManager.logException(CLASS_NAME, 'createTrainingCourseParticiantRecords', e);
			throw new AuraHandledException(e.getMessage());
		}
	}
	/**
	 * @author                      : MTX Group Product Team
	 * @since                       : 15 Sep 2023
	 * @description                 : This method will delete TrainingCourseParticipant records
	 *                                S-55551
	 * @param courseId              : TrainingCourseParticipant record Id
	 * @return                      : `Boolean`
	 * @last modified by            : MTX Group Product Team
	 * @last modified date          :
	 * @modified details            :
	 */
	@AuraEnabled
	public static Boolean deleteTrainingCourseParticiantRecords(String courseId) {
		Boolean isDelete = false;
		try {
			List<TrainingCourseParticipant> tcpList = LPI_TrainingCourseParticipantDAO.getTrainingCourseParticipantByDymanicQuery(
				'Id',
				'Id = \'' + String.escapeSingleQuotes(courseId) + '\'',
				null,
				null,
				null
			);
			if (!tcpList.isEmpty()) {
				LPI_WithoutSharingUtility.deleteSObject(tcpList[0]);
				isDelete = true;
			}
		} catch (Exception e) {
			LPI_ExceptionManager.logException(CLASS_NAME, 'deleteTrainingCourseParticiantRecords', e);
			throw new AuraHandledException(e.getMessage());
		}
		return isDelete;
	}
	/**
	 * @author                      : MTX Group Product Team
	 * @since                       : 16 Sep 2023
	 * @description                 : This method will create certification record and link audit detail record
	 *                                S-55551
	 * @param audId                 : Audit Detail Record Id
	 * @param certificationRecData  : String
	 * @return                      : `String`
	 * @last modified by            : MTX Group Product Team
	 * @last modified date          :
	 * @modified details            :
	 */
	@AuraEnabled
	public static String createCertificationRecord(
		String audId,
		String blId,
		String notificationId,
		String certificationRecData
	) {
		String certiRecId = '';
		try {
			if (String.isBlank(audId)) {
				return null;
			}
			CertificationWrapper certificationRecordWrapper = (CertificationWrapper) JSON.deserializeStrict(
				certificationRecData,
				CertificationWrapper.class
			);
			BoardCertification certiRec = new BoardCertification();
			certiRec.Title__c = certificationRecordWrapper.name;
			certiRec.Name = certificationRecordWrapper.name;
			certiRec.Issuing_Agency__c = certificationRecordWrapper.authority;
			certiRec.Effective_Date__c = certificationRecordWrapper.startDate;
			certiRec.ExpirationDate = certificationRecordWrapper.endDate;
			certiRec.Audit_Detail__c = audId;
			certiRec.Business_License__c = blId != null ? blId : null;
			certiRecId = (LPI_DML.doUpsert(certiRec)).Id;
			updateAuditStatus(audId, notificationId, null);
		} catch (Exception e) {
			LPI_ExceptionManager.logException(CLASS_NAME, 'createCertificationRecord', e);
			throw new AuraHandledException(e.getMessage());
		}
		return certiRecId;
	}

	/**
	 * @author                      : MTX Group Product Team
	 * @since                       : 16 Sep 2023
	 * @description                 : This method will create insurance record and link audit detail record
	 *                                 
	 * @param audId                 : Audit Detail Record Id
	 * @param insuranceRecData      : String
	 * @return                      : `String`
	 * @last modified by            : MTX Group Product Team
	 * @last modified date          :
	 * @modified details            :
	 */
	@AuraEnabled
	public static String createInsuranceRecord(
		String audId,
		String blId,
		String notificationId,
		String insuranceRecData
	) {
		String insuranceRecId = '';
		try {
			if (String.isBlank(audId)) {
				return null;
			}
			InsuranceWrapper insuranceRecordWrapper = (InsuranceWrapper) JSON.deserializeStrict(
				insuranceRecData,
				InsuranceWrapper.class
			);
			Insurance__c insuranceRec = new Insurance__c();
			 
			insuranceRec.Policy_Number__c = insuranceRecordWrapper.insuranceNumber;
			insuranceRec.Audit_Detail__c = audId;
			insuranceRec.Business_License__c = blId != null ? blId : null;
			insuranceRecId = ((Insurance__c) LPI_WithoutSharingUtility.insertSObject(insuranceRec)).Id;
			updateAuditStatus(audId, notificationId, null);
		} catch (Exception e) {
			LPI_ExceptionManager.logException(CLASS_NAME, 'createInsuranceRecord', e);
			throw new AuraHandledException(e.getMessage());
		}
		return insuranceRecId;
	}
	/**
	 * @author                      :  
	 * @since                       : 16 Sep 2023
	 * @description                 : This method will update Audit Detail record status to completed once application is submitted
	 *                                S-55551
	 * @param audId                 : Audit Detail Record Id
	 * @return                      : `Boolean`
	 * @last modified by            :  
	 * @last modified date          :
	 * @modified details            :
	 */
	@AuraEnabled
	public static Boolean updateAuditStatus(String audId, String notificationId, String auditDataString) {
		Boolean isSuccess = false;
		try {
			if (audId != null) {
				List<Audit_Detail__c> auditDetailsList = LPI_AuditDetailsDAO.getAuditDetailsByDymanicQuery(
					'Id, Business_License__c, Name, Audit_End_Date__c, Audit_Start_Date__c, Audit_Type__c, Business_License__r.PeriodEnd',
					'Id = \'' + String.escapeSingleQuotes(audId) + '\'',
					null,
					null,
					null
				);
				if (!auditDetailsList.isEmpty()) {
					Audit_Detail__c audDetailRec = new Audit_Detail__c();
					audDetailRec.Id = audId;
					audDetailRec.Status__c = STATUS_COMPLETED;
					if (!String.isBlank(auditDataString)) {
						AuditDataWrapper auditData = (AuditDataWrapper) JSON.deserializeStrict(
							auditDataString,
							AuditDataWrapper.class
						);
						audDetailRec.Grace_Period__c = auditData.gracePeriod;
					}
					LPI_DML.doUpdate(audDetailRec);
					isSuccess = true;
				}
				if (String.isNotBlank(notificationId)) {
					deletePortalNotification(notificationId);
				}
			}
		} catch (Exception e) {
			throw new AuraHandledException(e.getMessage());
		}
		return isSuccess;
	}
	/**
	 * @author                      :  
	 * @since                       : 19th Sep 2023
	 * @description                 : Wrapper class used to show CE Audit Details data based on Story S-55551
	 * @last modified by            :  
	 * @last modified date          :
	 * @modified details            :
	 */
	public class AuditDetailWrapper {
		@AuraEnabled
		public String course;
		@AuraEnabled
		public Decimal hours;
		@AuraEnabled
		public String notes;
		@AuraEnabled
		public Date endDate;
		@AuraEnabled
		public String audId;
		@AuraEnabled
		public String courseId;
		@AuraEnabled
		public String audRecTypeName;
		@AuraEnabled
		public String boardName;
		@AuraEnabled
		public Boolean editRequired;
		@AuraEnabled
		public String blId;
		@AuraEnabled
		public String yearCEHours;
		@AuraEnabled
		public Boolean cureHours;
		@AuraEnabled
		public Integer yearCure;
		@AuraEnabled
		public Boolean gracePeriod;
		@AuraEnabled
		public String courseCategory;
		@AuraEnabled
		public String editButtonAriaLabel;
		@AuraEnabled
		public String deleteButtonAriaLabel;
		@AuraEnabled
		public List<SubjectAreaWrapper> subjectAreaList;
		@AuraEnabled
		public String index;
		public AuditDetailWrapper(
			String course,
			Integer hours,
			String notes,
			Date endDate,
			String audId,
			String courseId,
			String audRecTypeName,
			String boardName,
			Boolean editRequired,
			String blId,
			String yearCEHours,
			Boolean cureHours,
			Integer yearCure,
			Boolean gracePeriod,
			String courseCategory
		) {
			this.course = course;
			this.hours = hours;
			this.notes = notes;
			this.endDate = endDate;
			this.audId = audId;
			this.courseId = courseId;
			this.audRecTypeName = audRecTypeName;
			this.boardName = boardName;
			this.editRequired = editRequired;
			this.blId = blId;
			this.yearCEHours = yearCEHours;
			this.cureHours = cureHours;
			this.yearCure = yearCure;
			this.gracePeriod = gracePeriod;
			this.courseCategory = courseCategory;
			this.subjectAreaList = new List<subjectAreaWrapper>();
		}
		public AuditDetailWrapper(String audId, String audRecTypeName, String blId, String boardName) {
			this.audId = audId;
			this.audRecTypeName = audRecTypeName;
			this.blId = blId;
			this.boardName = boardName;
		}
	}

	public class SubjectAreaWrapper {
		@AuraEnabled
		public String subjectArea;
		@AuraEnabled
		public Decimal reportedHours;
		@AuraEnabled
		public String subjectAreaId;
		 
		@AuraEnabled
		public String index;
		@AuraEnabled public Boolean showAddButton;
		

		public SubjectAreaWrapper(String subjectArea, Decimal reportedHours, String subjectAreaId) {
			this.subjectArea = subjectArea;
			this.reportedHours = reportedHours;
			this.subjectAreaId = subjectAreaId;
		}
	}
	/**
	 * @author                      : MTX Group Product Team
	 * @since                       : 22nd Sep 2023
	 * @description                 : InsuranceWrapper
	 * @last modified by            : MTX Group Product Team
	 * @last modified date          :
	 * @modified details            :
	 */
	public class InsuranceWrapper {
		@AuraEnabled
		public String name;
		@AuraEnabled
		public String insuranceNumber;
		public InsuranceWrapper(String companyName, String insuranceNumber) {
			this.name = companyName;
			this.insuranceNumber = insuranceNumber;
		}
	}
	/**
	 * @author                      : MTX Group Product Team
	 * @since                       : 22nd Sep 2023
	 * @description                 : CertificationWrapper
	 * @last modified by            : MTX Group Product Team
	 * @last modified date          :
	 * @modified details            :
	 */
	public class CertificationWrapper {
		@AuraEnabled
		public String name;
		@AuraEnabled
		public String authority;
		@AuraEnabled
		public Date startDate;
		@AuraEnabled
		public Date endDate;
		public CertificationWrapper(String name, String authority, Date startDate, Date endDate) {
			this.name = name;
			this.authority = authority;
			this.startDate = startDate;
			this.endDate = endDate;
		}
	}

	/**
	 * @author                      : MTX Group Product Team
	 * @since                       : 10 Oct, 2023
	 * @description                 : Audit Data
	 * @last modified by            : MTX Group Product Team
	 * @last modified date          :
	 * @modified details            :
	 */
	public class AuditDataWrapper {
		@AuraEnabled
		public Boolean isAllowed;
		@AuraEnabled
		public Boolean gracePeriod;
		public AuditDataWrapper(Boolean isAllowed, Boolean gracePeriod) {
			this.isAllowed = isAllowed;
			this.gracePeriod = gracePeriod;
		}
	}
}