/**
 * @description       : 
 * @author            : MTX Group Inc.
 * @group             : 
 * @last modified on  : 04-23-2024
 * @last modified by  : MTX Group Inc.
**/
public with sharing class LPI_TrainingCourseParticipantTrgHelper {
	private final static STRING STATUS_COMPLETED = 'Completed';
	private final static STRING STATUS_IN_PROGRESS = 'In Progress';
	private final static STRING RECORD_TYPE_CE_AUDIT = 'CE_Audit';
	private final static STRING COURSE_TYPE_CORE = 'Core';
	private final static STRING COURSE_TYPE_WAIVER = 'Waiver';

	public static String getClassName() {
		return 'LPI_TrainingCourseParticipantTrgHelper';
	}

	/**
	 * @author                      : Rahul Ameta
	 * @since                       : 02 Jan 2024
	 * @description                 : This method will update the Audit Details Lookup on TCP
	 *                                S-59905
	 * @param recordsList           : It contains list of TrainingCourseParticipant records
	 * @param oldMap                 : It contains Map<Id, TrainingCourseParticipant> records
	 * @return                      : `void`
	 * @last modified by            :
	 * @last modified date          :
	 * @modified details            :
	 */
	public static void linkTCPWithAuditDetailsRecord(
		List<TrainingCourseParticipant> recordsList,
		Map<Id, TrainingCourseParticipant> oldMap
	) {
		try {
			//Iterate over the recordList to get - recordToBeLinked
			List<TrainingCourseParticipant> recordToBeLinked = new List<TrainingCourseParticipant>();
			Set<Id> businessLicenseIds = new Set<Id>();
			for (TrainingCourseParticipant tcpRec : recordsList) {
				if (
					((oldMap == null && tcpRec.Unique_Identifier__c != null) ||
					(oldMap != null &&
					tcpRec.Business_License__c != oldMap.get(tcpRec.Id).Business_License__c)) &&
					tcpRec.Business_License__c != null &&
					tcpRec.Audit_Detail__c == null
				) {
					recordToBeLinked.add(tcpRec);
					businessLicenseIds.add(tcpRec.Business_License__c);
				}
			}

			//If we found any record to be linked
			if (!recordToBeLinked.isEmpty()) {
				Id auditRecordTypeId = Schema.SObjectType.Audit_Detail__c.getRecordTypeInfosByDeveloperName()
					.get(RECORD_TYPE_CE_AUDIT)
					.getRecordTypeId();
				//Get the renewal cycles for business licenses
				Map<Id, List<LPI_ServiceUtility.RenewalPeriod>> blIdToPeriodListMap = LPI_ServiceUtility.getLicenseCycles(
					businessLicenseIds
				);
				Map<String, LPI_ServiceUtility.RenewalPeriod> tcpIdToNewPeriodMap = new Map<String, LPI_ServiceUtility.RenewalPeriod>();
				List<Audit_Detail__c> auditDetailsToInsert = new List<Audit_Detail__c>();

				for (TrainingCourseParticipant tcpRecord : recordToBeLinked) {
					Date courseDate = tcpRecord.StartDate != null
						? date.newinstance(
								tcpRecord.StartDate.year(),
								tcpRecord.StartDate.month(),
								tcpRecord.StartDate.day()
						  )
						: System.today();

					Boolean isCycleFound = false;
					List<LPI_ServiceUtility.RenewalPeriod> periodList = blIdToPeriodListMap.get(
						tcpRecord.Business_License__c
					);
					Integer periodListLastIndex = periodList.size() - 1;
					Integer currIndex = 0;
					String tcpRecordKey = oldMap == null ? tcpRecord.Unique_Identifier__c : tcpRecord.Id;
					//Iterate over the Period list map for linked business License
					for (LPI_ServiceUtility.RenewalPeriod period : periodList) {
						//If we found the cycle for course
						if (
							(courseDate >= period.startDate && courseDate <= period.endDate) ||
							(currIndex == periodListLastIndex &&
							courseDate < period.startDate)
						) {
							isCycleFound = true;
							if (period.auditRecord != null && period.auditRecord.Id != null) {
								tcpRecord.Audit_Detail__c = period.auditRecord.Id;
							} else if (period.auditRecord != null && period.auditRecord.Id == null) {
								tcpIdToNewPeriodMap.put(tcpRecordKey, period);
							} else {
								period.auditRecord = new Audit_Detail__c();
								period.auditRecord.RecordTypeId = auditRecordTypeId;
								period.auditRecord.Business_License__c = tcpRecord.Business_License__c;
								period.auditRecord.Current_Reporting_Start_Date__c = period.startDate;
								period.auditRecord.Current_Reporting_End_Date__c = period.endDate;
								tcpIdToNewPeriodMap.put(tcpRecordKey, period);
								auditDetailsToInsert.add(period.auditRecord);
							}
							break;
						}
						currIndex++;
					}

					//If the added Course is in future cycle
					if (!isCycleFound) {
						tcpRecord.addError('You can\'t add this course before renewal');
					}
				}

				//Insert the new audit details record
				if (!auditDetailsToInsert.isEmpty()) {
					LPI_WithoutSharingUtility.insertSObjectList(auditDetailsToInsert);
				}

				//Link the TCP with the newly created Audit Detail records
				for (TrainingCourseParticipant tcpRecord : recordToBeLinked) {
					if (tcpRecord.Audit_Detail__c == null) {
						String tcpRecordKey = oldMap == null ? tcpRecord.Unique_Identifier__c : tcpRecord.Id;
						tcpRecord.Audit_Detail__c = tcpIdToNewPeriodMap.get(tcpRecordKey).auditRecord.Id;
					}
				}
			}
		} catch (Exception e) {
			LPI_ExceptionManager.logException(getClassName(), 'linkTCPWithAuditDetailsRecord', e);
		}
	}

	/**
	 * @author                      : Rahul Ameta
	 * @since                       : 19 Dec 2023
	 * @description                 : This method will update the approved hours on Audit Details record
	 *                                S-59905
	 * @param recordsList           : It contains list of TrainingCourseParticipant records
	 * @param oldMap                 : It contains Map<Id, TrainingCourseParticipant> records
	 * @return                      : `void`
	 * @last modified by            :
	 * @last modified date          :
	 * @modified details            :
	 */
	public static void updateApprovedHoursOnAuditDetails(
		List<TrainingCourseParticipant> recordsList,
		Map<Id, TrainingCourseParticipant> oldMap
	) {
		try {
			Map<Id, List<TrainingCourseParticipant>> auditDetailIdToTCPList = new Map<Id, List<TrainingCourseParticipant>>();
			for (TrainingCourseParticipant tcpRec : recordsList) {
				if (
					(Trigger.isUndelete ||
					Trigger.isDelete ||
					oldMap.get(tcpRec.Id).Approved_Hours__c != tcpRec.Approved_Hours__c ||
					oldMap.get(tcpRec.Id).Course_Type__c != tcpRec.Course_Type__c) && tcpRec.Audit_Detail__c != null
				) {
					if (!auditDetailIdToTCPList.containsKey(tcpRec.Audit_Detail__c)) {
						auditDetailIdToTCPList.put(tcpRec.Audit_Detail__c, new List<TrainingCourseParticipant>());
					}
					auditDetailIdToTCPList.get(tcpRec.Audit_Detail__c).add(tcpRec);
				}
			}

			if (!auditDetailIdToTCPList.isEmpty()) {
				//Query on Audit details record to get the current approved Hours
				String fieldsToQuery = 'Id,Name,Approved_CE_Hours__c,Approved_Core_Hours__c,Approved_Waiver_Hours__c,Approved_NABP_CE_Hours__c';
				String whereClause =
					'Id IN ' + LPI_ServiceUtility.getStringValuesBySet(auditDetailIdToTCPList.keySet());
				List<Audit_Detail__c> auditDetailsList = LPI_AuditDetailsDAO.getAuditDetailsByDymanicQuery(
					fieldsToQuery,
					whereClause,
					null,
					null,
					null
				);

				for (Audit_Detail__c auditDetail : auditDetailsList) {
					for (TrainingCourseParticipant tcp : auditDetailIdToTCPList.get(auditDetail.Id)) {
						String oldCourseType = oldMap.get(tcp.Id).Course_Type__c;
						Decimal oldApprovedHours = oldMap.get(tcp.Id).Approved_Hours__c != null
							? oldMap.get(tcp.Id).Approved_Hours__c
							: 0;
						String newCourseType = tcp.Course_Type__c;
						Decimal newApprovedHours = tcp.Approved_Hours__c != null ? tcp.Approved_Hours__c : 0;

						if (auditDetail.Approved_CE_Hours__c == null) {
							auditDetail.Approved_CE_Hours__c = 0;
						}
						if (auditDetail.Approved_Core_Hours__c == null) {
							auditDetail.Approved_Core_Hours__c = 0;
						}
						if (auditDetail.Approved_Waiver_Hours__c == null) {
							auditDetail.Approved_Waiver_Hours__c = 0;
						}
						if (auditDetail.Approved_NABP_CE_Hours__c == null) {
							auditDetail.Approved_NABP_CE_Hours__c = 0;
						}

						if (!Trigger.isDelete) {
							auditDetail.Approved_CE_Hours__c += newApprovedHours;
							if (newCourseType == COURSE_TYPE_CORE) {
								auditDetail.Approved_Core_Hours__c += newApprovedHours;
							} else if (newCourseType == COURSE_TYPE_WAIVER) {
								auditDetail.Approved_Waiver_Hours__c += newApprovedHours;
							}
							if (tcp.Unique_Identifier__c != null) {
								auditDetail.Approved_NABP_CE_Hours__c += newApprovedHours;
							}
						}
						if (!Trigger.isUndelete) {
							auditDetail.Approved_CE_Hours__c -= oldApprovedHours;
							if (oldCourseType == COURSE_TYPE_CORE) {
								auditDetail.Approved_Core_Hours__c -= oldApprovedHours;
							} else if (oldCourseType == COURSE_TYPE_WAIVER) {
								auditDetail.Approved_Waiver_Hours__c -= oldApprovedHours;
							}
							if (tcp.Unique_Identifier__c != null) {
								auditDetail.Approved_NABP_CE_Hours__c -= oldApprovedHours;
							}
						}
					}
				}

				if (!auditDetailsList.isEmpty()) {
					LPI_WithoutSharingUtility.updateSObjectList(auditDetailsList);
				}
			}
		} catch (Exception e) {
			LPI_ExceptionManager.logException(getClassName(), 'updateApprovedHoursOnAuditDetails', e);
		}
	}

	/**
	 * @author                      : Rahul Ameta
	 * @since                       : 21 Dec 2023
	 * @description                 : This method will update the Submitted NABP Hours on Audit Details record
	 *                                S-59905
	 * @param recordsList           : It contains list of TrainingCourseParticipant records
	 * @param oldMap                : It contains Map<Id, TrainingCourseParticipant> records
	 * @return                      : `void`
	 * @last modified by            :
	 * @last modified date          :
	 * @modified details            :
	 */
	public static void updateSubmittedHoursOnAuditDetails(
		List<TrainingCourseParticipant> recordsList,
		Map<Id, TrainingCourseParticipant> oldMap
	) {
		try {
			Map<Id, List<TrainingCourseParticipant>> auditDetailIdToTCPList = new Map<Id, List<TrainingCourseParticipant>>();

			for (TrainingCourseParticipant tcpRec : recordsList) {
				if (
					(Trigger.isUndelete ||
					Trigger.isDelete ||
					oldMap == null ||
					oldMap.get(tcpRec.Id).TotalHours != tcpRec.TotalHours) &&
					tcpRec.Unique_Identifier__c != null &&
					tcpRec.Audit_Detail__c != null
				) {
					if (!auditDetailIdToTCPList.containsKey(tcpRec.Audit_Detail__c)) {
						auditDetailIdToTCPList.put(tcpRec.Audit_Detail__c, new List<TrainingCourseParticipant>());
					}
					auditDetailIdToTCPList.get(tcpRec.Audit_Detail__c).add(tcpRec);
				}
			}

			if (!auditDetailIdToTCPList.isEmpty()) {
				//Query on Audit details record to get the current approved Hours
				String fieldsToQuery = 'Id,Name,Submitted_NABP_CE_Hours__c';
				String whereClause =
					'Id IN ' + LPI_ServiceUtility.getStringValuesBySet(auditDetailIdToTCPList.keySet());
				List<Audit_Detail__c> auditDetailsList = LPI_AuditDetailsDAO.getAuditDetailsByDymanicQuery(
					fieldsToQuery,
					whereClause,
					null,
					null,
					null
				);

				for (Audit_Detail__c auditDetail : auditDetailsList) {
					for (TrainingCourseParticipant tcp : auditDetailIdToTCPList.get(auditDetail.Id)) {
						Decimal oldSubmittedHours = oldMap != null ? oldMap.get(tcp.Id).TotalHours : 0;
						Decimal newSubmittedHours = Trigger.isDelete ? 0 : tcp.TotalHours;
						oldSubmittedHours = oldSubmittedHours != null ? oldSubmittedHours : 0;
						newSubmittedHours = newSubmittedHours != null ? newSubmittedHours : 0;
						if (auditDetail.Submitted_NABP_CE_Hours__c == null) {
							auditDetail.Submitted_NABP_CE_Hours__c = 0;
						}
						auditDetail.Submitted_NABP_CE_Hours__c -= oldSubmittedHours;
						auditDetail.Submitted_NABP_CE_Hours__c += newSubmittedHours;
					}
				}

				if (!auditDetailsList.isEmpty()) {
					LPI_WithoutSharingUtility.updateSObjectList(auditDetailsList);
				}
			}
		} catch (Exception e) {
			LPI_ExceptionManager.logException(getClassName(), 'updateSubmittedHoursOnAuditDetails', e);
		}
	}

	/**
	 * @author                      : Rahul Ameta
	 * @since                       : 02 Jan 2024
	 * @description                 : This method will update the Submitted NABP Hours on Audit Details record on delinking
	 *                                S-59905
	 * @param recordsList           : It contains list of TrainingCourseParticipant records
	 * @param oldMap                : It contains Map<Id, TrainingCourseParticipant> records
	 * @return                      : `void`
	 * @last modified by            :
	 * @last modified date          :
	 * @modified details            :
	 */
	public static void updateAuditDetailOnDeLinking(
		List<TrainingCourseParticipant> recordsList,
		Map<Id, TrainingCourseParticipant> oldMap
	) {
		try {
			Set<Id> auditDetailIds = new Set<Id>();
			List<TrainingCourseParticipant> deLinkedTCPRecord = new List<TrainingCourseParticipant>();

			for (TrainingCourseParticipant tcpRec : recordsList) {
				if (
					oldMap != null &&
					oldMap.get(tcpRec.Id).Audit_Detail__c != tcpRec.Audit_Detail__c &&
					tcpRec.Unique_Identifier__c != null
				) {
					if (oldMap.get(tcpRec.Id).Audit_Detail__c != null) {
						auditDetailIds.add(oldMap.get(tcpRec.Id).Audit_Detail__c);
					}
					if (tcpRec.Audit_Detail__c != null) {
						auditDetailIds.add(tcpRec.Audit_Detail__c);
					}
					deLinkedTCPRecord.add(tcpRec);
				}
			}

			if (!deLinkedTCPRecord.isEmpty()) {
				String fieldsToQuery = 'Approved_NABP_CE_Hours__c,Submitted_NABP_CE_Hours__c';
				String whereClause = 'Id IN ' + LPI_ServiceUtility.getStringValuesBySet(auditDetailIds);
				Map<Id, Audit_Detail__c> auditDetailsMap = new Map<Id, Audit_Detail__c>(
					LPI_AuditDetailsDAO.getAuditDetailsByDymanicQuery(fieldsToQuery, whereClause, null, null, null)
				);

				for (TrainingCourseParticipant tcpRec : deLinkedTCPRecord) {
					Decimal oldTotalHours = oldMap.get(tcpRec.Id).TotalHours != null
						? oldMap.get(tcpRec.Id).TotalHours
						: 0;
					Decimal newTotalHours = tcpRec.TotalHours != null ? tcpRec.TotalHours : 0;
					Audit_Detail__c oldAuditRecord = oldMap.get(tcpRec.Id).Audit_Detail__c != null
						? auditDetailsMap.get(oldMap.get(tcpRec.Id).Audit_Detail__c)
						: null;
					Audit_Detail__c newAuditRecord = tcpRec.Audit_Detail__c != null
						? auditDetailsMap.get(tcpRec.Audit_Detail__c)
						: null;
					if (oldAuditRecord != null) {
						oldAuditRecord.Submitted_NABP_CE_Hours__c -= oldTotalHours;
					}
					if (newAuditRecord != null) {
						newAuditRecord.Submitted_NABP_CE_Hours__c += newTotalHours;
					}
				}

				if (!auditDetailsMap.isEmpty()) {
					LPI_WithoutSharingUtility.updateSObjectList(auditDetailsMap.values());
				}
			}
		} catch (Exception e) {
			LPI_ExceptionManager.logException(getClassName(), 'updateAuditDetailOnDeLinking', e);
		}
	}

	/**
	 * @author                      : Rahul Ameta
	 * @since                       : 18 Dec 2023
	 * @description                 : This method will Delete the related Application Content Record
	 * @param oldList                : It contains List of old records
	 * @return                      : `void`
	 * @last modified by            :
	 * @last modified date          :
	 * @modified details            :
	 */
	public static void deleteRelatedAppContentRecord(List<TrainingCourseParticipant> oldList) {
		try {
			Set<Id> deletedTCPIds = new Set<Id>();
			for (TrainingCourseParticipant tcp : oldList) {
				deletedTCPIds.add(tcp.Id);
			}
			//Get the Related Application Content Record for the deleted records
			if (!deletedTCPIds.isEmpty()) {
				String fieldToQuery = 'Id';
				String whereClause =
					'Training_Course_Participant__c IN ' +
					LPI_ServiceUtility.getStringValuesBySet(deletedTCPIds) +
					' AND Section_Header__c = \'' +
					LPI_AuditDetailController.COURSE_SUB_AREA +
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
		} catch (Exception e) {
			LPI_ExceptionManager.logException(getClassName(), 'deleteRelatedAppContentRecord', e);
		}
	}

	/**
	 * @author                      : Rahul Ameta
	 * @since                       : 22 Dec 2023
	 * @description                 : This method will update course type of TCP records
	 * @param recordList			: new record list
	 * @param oldMap                : It contains  old Map
	 * @return                      : `void`
	 * @last modified by            :
	 * @last modified date          :
	 * @modified details            :
	 */
	public static void updateCourseTypeOnTCPRecord(
		List<TrainingCourseParticipant> recordsList,
		Map<Id, TrainingCourseParticipant> oldMap
	) {
		try {
			Set<Id> courseOfferingIds = new Set<Id>();
			for (TrainingCourseParticipant tcpRec : recordsList) {
				if (
					(oldMap == null || oldMap.get(tcpRec.Id).CourseOfferingId != tcpRec.CourseOfferingId) &&
					tcpRec.CourseOfferingId != null
				) {
					courseOfferingIds.add(tcpRec.CourseOfferingId);
				}
			}
			if (!courseOfferingIds.isEmpty()) {
				//Get the course Offering records
				Map<Id, CourseOffering> courseOfferingMap = new Map<Id, CourseOffering>(
					LPI_CourseOfferingDAO.getCourseOfferingByDymanicQuery(
						'Id,CourseName.Type__c,CourseName.Delivery_Method__c',
						'Id IN ' + LPI_ServiceUtility.getStringValuesBySet(courseOfferingIds),
						null,
						null,
						null
					)
				);
				for (TrainingCourseParticipant tcpRec : recordsList) {
					if (
						(oldMap == null || oldMap.get(tcpRec.Id).CourseOfferingId != tcpRec.CourseOfferingId) &&
						tcpRec.CourseOfferingId != null
					) {
						if (courseOfferingMap.containsKey(tcpRec.CourseOfferingId)) {
							tcpRec.Course_Type__c = courseOfferingMap.get(tcpRec.CourseOfferingId).CourseName.Type__c;
							if (
								courseOfferingMap.get(tcpRec.CourseOfferingId).CourseName.Delivery_Method__c != null &&
								!courseOfferingMap.get(tcpRec.CourseOfferingId)
									.CourseName.Delivery_Method__c.contains(';')
							) {
								tcpRec.Delivery_Method__c = courseOfferingMap.get(tcpRec.CourseOfferingId)
									.CourseName.Delivery_Method__c;
							}
						}
					}
				}
			}
		} catch (Exception e) {
			LPI_ExceptionManager.logException(getClassName(), 'updateCourseTypeOnTCPRecord', e);
		}
	}
}