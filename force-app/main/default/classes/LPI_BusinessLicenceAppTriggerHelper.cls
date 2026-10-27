/**
 * @description       : 
 * @author            : MTX Group Product Team
 * @group             : 
 * @last modified on  : 07-25-2024
 * @last modified by  : Uzma Md
**/
public with sharing class LPI_BusinessLicenceAppTriggerHelper {
	
	public final static String APPROVAL_TYPE_FULL_APPROVAL = 'Full Approval';
	
	public final static String SPONSORING_LOCATION = 'Sponsoring Institute Location';
	public final static String AMENDMENT_TYPE_CHANGE_IN_SPONSORSHIP = 'Change in Sponsorship';
	
	public static final String CONTINUING_EDUCATION_PROVIDER = 'Continuing Education Provider';
	public static final String AMENDMENT_TYPE_CONTINUING_EDUCATION = 'Continuing Education'; 
	private static final String AMENDMENT_SUBTYPE_CHANGE_OF_MAILING_ADDRESS = 'Change of Mailing Address';	
	
	private static final String BL_STATUS_CLOSED = 'Closed';
	private static final String APPLICATION_TYPE = 'New';
	private static final String APPROVED = 'Approved';
    private final static String APPLICATION_FOR_PERMIT = 'Application for Permit';

	public static final Set<String> APPLICATION_SUBMISSION_EMAIL_SET = new Set<String>{'Application_Submission_Email'};
    public static final String APPLICATION_SUBMISSION_EMAIL = 'Application_Submission_Email';

	public static final Set<String> BUSINESS_LICENSE_ISSUED_EMAIL_SET = new Set<String>{'Business_License_Issued'};
    public static final String BUSINESS_LICENSE_ISSUED_EMAIL = 'Business_License_Issued';
	public static final Set<String> BUSINESS_LICENSE_APPROVED_EMAIL_SET = new Set<String>{'Business_License_Approval'};
    public static final String BUSINESS_LICENSE_APPROVED_EMAIL = 'Business_License_Approval';
	public static final Set<String> DEFICIENCY_NOTIFICATION_EMAIL_SET = new Set<String>{'Deficiency_Notification_Email_Offline'};
    public static final String DEFICIENCY_NOTIFICATION_EMAIL = 'Deficiency_Notification_Email_Offline';
	public static final String BUSINESS_LICENSE_REJECTED_EMAIL = 'Business_License_Rejected';
	public static final Set<String> BUSINESS_LICENSE_REJECTED_EMAIL_SET = new Set<String>{'Business_License_Rejected'};
	public static final Set<String> COURSE_APPROVAL_LICENSE_SET = new Set<String>{
		'Continuing Education Provider'
	};
	public static final Set<String> COURSE_APPROVAL_APPLICATIONTYPE_SET = new Set<String>{
		'New',
		'Previously Approved Application',
		'Renewal'
	};
	private final static String CANCELED_STATUS = 'Canceled';
	private final static String CLOSED_STATUS = 'Closed';
	public final static String EMPLOYEE = 'Employee';
	
	public final static String NEW_TYPE_AND_SUBTYPE = 'New';
	
	public final static Set<String> AMENDMENT_TYPE_SET_FOR_AMENDMENTS = new Set<String>{
		'Facility change of location application',
		'Change in Sponsorship',
		'Change of Mailing Address'
	};
	
	public final static String CHANGE_OF_STATUS_APP_TYPE = 'Change of Status';
	public final static String CHANGE_OF_STATUS_REJECTION = 'Change_Of_Status_Rejection';
	public static final String FIELD_TRIP_NOTIFICATION_TEMPLATE = 'Field_Trip_Approval_Letter';
	
	public final static String EMBALMERS_AND_FUNERAL_BOARD_NAME = 'Embalmers & Funeral Directors';
	private final static Set<String> EMBALMERS_BUSINESS_LICENSES = new Set<String>{
		'Preneed Seller'
	};
	private final static Set<String> APPLICATION_TYPES = new Set<String>{
		'New',
        'Amendment'
	};
	
	private final static String LICENSE_ISSUED_STATUS = 'License Issued';
	private final static Set<String> TEMP_LICENSES_SET = new Set<String>{
		'Drug Distributor',
		'Pharmacy'
	};
	
	private final static String OWNER = 'Owner';
	
	
	private static String getClassName() {
		return 'LPI_BusinessLicenceAppTriggerHelper';
	}
		/**
     * @author                      : MTX Group Product Team
     * @since                       : July 28, 2023
     * @description                 : This method is after Update helper method for CRR Applications
     * @param recordsList           : It contains List of Application records
	 * @param mapOfOldRecords       : It contains old Map of records
	 * @param mapOfNewRecords       : It contains old Map of records
     * @return                      : void
     * @last modified by            : Uzma Md
     * @last modified date          :
     * @last modified details       :
     * @story Numbers               : 
     */
	public static void afterUpdateForCRRApplications(
		List<BusinessLicenseApplication> recordsList,
		Map<Id, BusinessLicenseApplication> mapOfOldRecords,
		Map<Id, BusinessLicenseApplication> mapOfNewRecords
	){

		try{
			Map<Id, Id> parIdWithIaIds = new Map<Id, Id>();
			List<BusinessLicenseApplication> designatedBrokerIAList = new List<BusinessLicenseApplication>();
			Set<Id> changeOfStatusBLAIdsSet = new Set<Id>();
			Set<Id> cosBarLetterOfRefBLAIdsSet = new Set<Id>();
			List<BusinessLicenseApplication> boutAgreementAfterSubmitBLAList = new List<BusinessLicenseApplication>();
			
			List<BusinessLicenseApplication> submittedApplicationList = new List<BusinessLicenseApplication>();
			List<BusinessLicenseApplication> updateCriminalBGCDateList = new List<BusinessLicenseApplication>();
			
			Set<Id> submittedAppPARIds = new Set<Id>();
			List<Sharing_Ledger__c> shareBLAOnInsertList = new List<Sharing_Ledger__c>();
			for (BusinessLicenseApplication blaRecord : recordsList) {
				if(mapOfOldRecords.get(blaRecord.Id).status != blaRecord.status &&
					blaRecord.status == LPI_LiteralConstant.IA_SUBMITTED_STATUS
				){
					submittedApplicationList.add(blaRecord);

					if (String.isNotBlank(blaRecord.Workflow__c)) {
						parIdWithIaIds.put(blaRecord.SavedApplicationRefId, blaRecord.Id);
					}

					if (
						blaRecord.Former_Designated_in_charge_License_Num__c != null &&
						blaRecord.New_Designated_in_charge_License_Number__c != null
					){
						designatedBrokerIAList.add(blaRecord);
					}

					if(
						blaRecord.ApplicationType == CHANGE_OF_STATUS_APP_TYPE
					){
						changeOfStatusBLAIdsSet.add(blaRecord.Id);
					}

					if (
						blaRecord.ApplicationType == LPI_LiteralConstant.IA_BOUT_AGREEMENT_APPLICATIONTYPE &&
						blaRecord.Amendment_Type__c == LPI_LiteralConstant.IA_BOUT_AGREEMENT_APPLICATIONTYPE
					) {
						boutAgreementAfterSubmitBLAList.add(blaRecord);
					}

					

					if(blaRecord.Board_Name__c.equalsIgnoreCase(EMBALMERS_AND_FUNERAL_BOARD_NAME) &&
						(blaRecord.ApplicationType == NEW_TYPE_AND_SUBTYPE ||
						blaRecord.ApplicationType == LPI_LiteralConstant.BLA_AMENDMENT_APPLICATIONTYPE)
					){
						updateCriminalBGCDateList.add(blaRecord);
					}
					
					shareBLAOnInsertList.add(LPI_ApexSharingUtility.createStaticLedgerRecord('BusinessLicenseApplication',blaRecord.Id,blaRecord.CreatedById));
				}
			}

			if (!parIdWithIaIds.isEmpty()) {
				LPI_TriggerServiceUtility.createAuthApplicationPlace(parIdWithIaIds);	
				LPI_TriggerServiceUtility.createApplicationContentRecord(parIdWithIaIds);
			}
			
			if (!shareBLAOnInsertList.isEmpty()) {
				LPI_WithoutSharingUtility.insertSObjectList(shareBLAOnInsertList);
			}
			afterUpdateHelper(recordsList, mapOfOldRecords, mapOfOldRecords);

		}catch(Exception e){
			LPI_ExceptionManager.logException(getClassName(), 'afterUpdateForCRRApplications', e);
		}
	}
    
/**
*   @author : MTX Group Product Team
*   @since :
*   @description : This method is used to to filter out the records and call respective method.
*/
    public static void beforeInsertHelper(List<BusinessLicenseApplication> newList) {
		
        List<BusinessLicenseApplication> iaHavingLicenseTypeList = new List<BusinessLicenseApplication>();
        List<BusinessLicenseApplication> priorityApplicationList = new List<BusinessLicenseApplication>();
        for (BusinessLicenseApplication newRecord : newList) {
            if (String.isNotBlank(newRecord.LicenseTypeId)) {
                iaHavingLicenseTypeList.add(newRecord);
            }
            if ((newRecord.Status__c == LPI_LiteralConstant.IA_SUBMITTED_STATUS) || (newRecord.Status__c == LPI_LiteralConstant.IA_PAYMENT_PENDING_STATUS && newRecord.Payment_Pending__c != false)) {
                priorityApplicationList.add(newRecord);
            }
        }
            if (!iaHavingLicenseTypeList.isEmpty()) {
              updatePreRequiredFields(iaHavingLicenseTypeList);
             }
			if (!priorityApplicationList.isEmpty()) {
				LPI_ApplicationPriority.updatePriorityApplication(priorityApplicationList);
			}
        
    }

		/**
     * @author                      : MTX Group Product Team
     * @since                       : July 28, 2023
     * @description                 : This method is before Insert helper method for CRR Applications
     * @param recordsList           : It contains List of Application records
     * @return                      : void
     * @last modified by            : Uzma Md
     * @last modified date          :
     * @last modified details       :
     * @story Numbers               : 
     */
	public static void beforeInsertForCRRApplications(List<BusinessLicenseApplication> newList){
		try{
			List<BusinessLicenseApplication> iaHavingLicenseTypeList = new List<BusinessLicenseApplication>();
			for (BusinessLicenseApplication newRecord : newList) {
				if (String.isNotBlank(newRecord.LicenseTypeId)) {
					iaHavingLicenseTypeList.add(newRecord);
				}
			}

			if (!iaHavingLicenseTypeList.isEmpty()) {
				updatePreRequiredFields(iaHavingLicenseTypeList);
			}
		}catch(Exception e){
			LPI_ExceptionManager.logException(getClassName(), 'beforeInsertForCRRApplications', e);
		}
	}

		/**
     * @author                      : MTX Group Product Team
     * @since                       : July 28, 2023
     * @description                 : This method is after Insert helper method for CRR Applications
     * @param recordsList           : It contains List of Application records
	 * @param mapOfOldRecords       : It contains old Map of records
     * @return                      : void
     * @last modified by            : Uzma Md
     * @last modified date          :
     * @last modified details       :
     * @story Numbers               : 
     */
	public static void afterInsertForCRRApplications(
		List<BusinessLicenseApplication> newList,
		Map<Id, BusinessLicenseApplication> mapOfOldRecords
	){

		try{
			List<BusinessLicenseApplication> isWorkflowIAList = new List<BusinessLicenseApplication>();
			Map<Id, Id> parIdWithIaIds = new Map<Id, Id>();
			for (BusinessLicenseApplication newRecord : newList) {
				if (String.isNotBlank(newRecord.Workflow__c)) {
					isWorkflowIAList.add(newRecord);
				}
				if (String.isNotBlank(newRecord.SavedApplicationRefId)) {
					parIdWithIaIds.put(newRecord.SavedApplicationRefId, newRecord.Id);
				}
			}

			if (!isWorkflowIAList.isEmpty()) {
				createDueDiligence(isWorkflowIAList);
			}

			if(!parIdWithIaIds.isEmpty()){
				LPI_TriggerServiceUtility.createRegulatoryTrxnFeeAndFeeItemRec(parIdWithIaIds);
			}
		}catch(Exception e){
			LPI_ExceptionManager.logException(getClassName(), 'afterInsertForCRRApplications', e);
		}
	}
		/**
	 * @author                      : MTX Group Product Team
	 * @since                       : Feb 22, 2023
	 * @description                 : This method is used to update field based on status before update.
	 */
	public static void updateFieldsBasedOnStatus(
		List<BusinessLicenseApplication> newList,
		Map<Id, BusinessLicenseApplication> mapOfOldRecords
	) {
		try {
			for (BusinessLicenseApplication bla : newList) {
				if (
					bla.OwnerId != mapOfOldRecords.get(bla.Id).OwnerId &&
					bla.Status == LPI_LiteralConstant.BLA_SUBMITTED_STATUS
				) {
					if (
						String.valueOf(bla.OwnerId).subString(0, 3) == '005' &&
						String.valueOf(mapOfOldRecords.get(bla.Id).OwnerId).subString(0, 3) == '00G'
					) {
						bla.Status__c = LPI_LiteralConstant.BLA_IN_PROGRESS_STATUS;
						bla.Status = LPI_LiteralConstant.BLA_UNDER_REVIEW_STATUS;
					}
				} else if (
					bla.Status__c != mapOfOldRecords.get(bla.Id).Status__c &&
					bla.Status__c == LPI_LiteralConstant.BLA_IN_PROGRESS_STATUS
				) {
					bla.Application_In_Process_Date__c = Date.today();
				} else if (
					mapOfOldRecords.get(bla.Id).Status != LPI_LiteralConstant.BLA_APPROVED_STATUS &&
					bla.Status == LPI_LiteralConstant.BLA_APPROVED_STATUS
				) {
					bla.ApprovedDate = System.Now();
				} else if (
					mapOfOldRecords.get(bla.Id).Status != LPI_LiteralConstant.BLA_REJECTED_STATUS &&
					bla.Status == LPI_LiteralConstant.BLA_REJECTED_STATUS
				) {
					bla.ApprovedDate = System.Now();
				} 
				else if(
					bla.Status != mapOfOldRecords.get(bla.Id).Status &&
					bla.Status == CANCELED_STATUS
				){
					bla.Status__c = CLOSED_STATUS;
				}
			}
		} catch (Exception ex) {
			LPI_ExceptionManager.logException(getClassName(), 'updateFieldsBasedOnStatus', ex);
		}
	}
		/**
	 *   @author : MTX Group Product Team
	 *   @since :
	 *   @description : This method is used to to filter out the records and call respective method.
	 */
	public static void beforeUpdateHelper(
		List<BusinessLicenseApplication> newList,
		Map<Id, BusinessLicenseApplication> mapOfOldRecords
	) {
		updateFieldsBasedOnStatus(newList, mapOfOldRecords);
		List<BusinessLicenseApplication> ownerUpdateList = new List<BusinessLicenseApplication>();
		List<BusinessLicenseApplication> priorityApplicationList = new List<BusinessLicenseApplication>();
		List<BusinessLicenseApplication> restrictApprovalList = new List<BusinessLicenseApplication>();		
		
		for (BusinessLicenseApplication newRecord : newList) {
			if (mapOfOldRecords.get(newRecord.Id).OwnerId != newRecord.OwnerId) {
				ownerUpdateList.add(newRecord);
			}
			if (
				(newRecord.Status__c == LPI_LiteralConstant.IA_SUBMITTED_STATUS &&
				(mapOfOldRecords.get(newRecord.Id).Status__c != newRecord.Status__c
				|| mapOfOldRecords.get(newRecord.Id).Payment_Pending__c != newRecord.Payment_Pending__c)
				)
				|| (newRecord.Status__c == LPI_LiteralConstant.IA_PAYMENT_PENDING_STATUS && mapOfOldRecords.get(newRecord.Id).Payment_Pending__c
				!= newRecord.Payment_Pending__c)
			)
			{
				priorityApplicationList.add(newRecord);
			}
			
		}	
		if (!priorityApplicationList.isEmpty()) {
			LPI_ApplicationPriority.updatePriorityApplication(priorityApplicationList);
		}
	}

		/**
     * @author                      : MTX Group Product Team
     * @since                       : July 28, 2023
     * @description                 : This method is after Before Update helper method for CRR Applications
     * @param recordsList           : It contains List of Application records
	 * @param mapOfOldRecords       : It contains old Map of records
     * @return                      : void
     * @last modified by            : Uzma Md
     * @last modified date          :
     * @last modified details       :
     * @story Numbers               : 
     */
	public static void beforeUpdateForCRRApplications(
		List<BusinessLicenseApplication> recordsList,
		Map<Id, BusinessLicenseApplication> mapOfOldRecords
	){

		try{
			beforeUpdateHelper(recordsList,mapOfOldRecords);
		}catch(Exception e){
			LPI_ExceptionManager.logException(getClassName(), 'beforeUpdateForCRRApplications', e);
		}

	}
	public static void updatePreRequiredFields(List<BusinessLicenseApplication> blaRecords) {
		
		try {
			Map<BusinessLicenseApplication, Id> blaToLicenseTypeNameMap = new Map<BusinessLicenseApplication, Id>();
			for (BusinessLicenseApplication baRecord : blaRecords) {
				blaToLicenseTypeNameMap.put(baRecord, baRecord.LicenseTypeId);
			}
			if (!blaToLicenseTypeNameMap.isEmpty()) {
				Set<Id> ratIdSet = new Set<Id>(blaToLicenseTypeNameMap.values());
				Map<Id, String> ratToBoardNameMap = new Map<Id, String>();
				Map<String, Regulatory_Auth_Type_WorkFlow__c> mapOfRegWorkflow = new Map<String, Regulatory_Auth_Type_WorkFlow__c>();
				for (
					Regulatory_Auth_Type_WorkFlow__c regW : LPI_RegulatoryAuthTypeWorkFlowDAO.getRATWorkflowByRATIdAndRecordTypeDevName(
						ratIdSet,
						'Workflow'
					)
				) {
					mapOfRegWorkflow.put(
						regW.Regulatory_Authorization_Type__c + '-' + regW.Type__c + '-' + regW.Sub_Type__c,
						regW
					);
				}
				for (
					RegulatoryAuthorizationType ratRecord : LPI_RegulatoryAuthorizationTypeDAO.getRATTypeByID(
						ratIdSet
					)
				) {
					ratToBoardNameMap.put(ratRecord.Id, ratRecord.IssuingDepartment.Name);
				}
				for (BusinessLicenseApplication bla : blaToLicenseTypeNameMap.keySet()) {
					if (
						mapOfRegWorkflow.get(
							bla.LicenseTypeId + '-' + bla.ApplicationType + '-' + bla.Amendment_Type__c
						) != null
					) {
						bla.Workflow__c = mapOfRegWorkflow.get(
								bla.LicenseTypeId + '-' + bla.ApplicationType + '-' + bla.Amendment_Type__c
							)
							.Workflow__c;
					}
					if (ratToBoardNameMap.containsKey(bla.LicenseTypeId)) {
						bla.Board_Name__c = ratToBoardNameMap.get(bla.LicenseTypeId);
					}
				}
			}
		} catch (Exception e) {
			LPI_ExceptionManager.logException(getClassName(), 'updatePreRequiredFields', e);
		}
	}
    public static void afterInsertHelper(
		List<BusinessLicenseApplication> newList,
		Map<Id, BusinessLicenseApplication> mapOfNewRecords
	) {
		List<BusinessLicenseApplication> isWorkflowIAList = new List<BusinessLicenseApplication>();
		List<BusinessLicenseApplication> submittedBLAList = new List<BusinessLicenseApplication>();
		List<BusinessLicenseApplication> channelofflineBLAList = new List<BusinessLicenseApplication>();
		List<BusinessLicenseApplication> isParPresentIAList = new List<BusinessLicenseApplication>();
		List<Sharing_Ledger__c> shareBLAOnInsertList = new List<Sharing_Ledger__c>();	
		LPI_ApexSharingUtility.manageRecordAccess(newList, null);
        for (BusinessLicenseApplication newRecord : newList) {
			if (String.isNotBlank(newRecord.Workflow__c)) {
				isWorkflowIAList.add(newRecord);
			}
			if (String.isNotBlank(newRecord.SavedApplicationRefId)) {
				isParPresentIAList.add(newRecord);
			}
			submittedBLAList.add(newRecord);
			
			shareBLAOnInsertList.add(LPI_ApexSharingUtility.createStaticLedgerRecord('BusinessLicenseApplication',newRecord.Id,newRecord.CreatedById));
		}

		if (!isParPresentIAList.isEmpty()) {
			createObjectRecordsOnAfterInsert(isParPresentIAList);
			
		}
		if (!isWorkflowIAList.isEmpty()) {
			createDueDiligence(isWorkflowIAList);
		}
		
		if (!shareBLAOnInsertList.isEmpty()) {
			LPI_WithoutSharingUtility.insertSObjectList(shareBLAOnInsertList);
		}	
		if(!submittedBLAList.isEmpty()){
			createNotifications(submittedBLAList,true);
		}
	}

	

    public static void afterUpdateHelper(
		List<BusinessLicenseApplication> newList,
		Map<Id, BusinessLicenseApplication> mapOfOldRecords,
		Map<Id, BusinessLicenseApplication> mapOfNewRecords
	) {
        List<BusinessLicenseApplication> afterLicenseIssuedList = new List<BusinessLicenseApplication>();
		List<BusinessLicenseApplication> afterSubmissionBLAList = new List<BusinessLicenseApplication>();
		List<BusinessLicenseApplication> afterLicenseIssueStatusList = new List<BusinessLicenseApplication>();
		List<BusinessLicenseApplication> afterLicenseIssueStatusforRenewalList = new List<BusinessLicenseApplication>();
		List<BusinessLicenseApplication> havingCourseIdList = new List<BusinessLicenseApplication>();
		List<BusinessLicenseApplication> havingBLIdList = new List<BusinessLicenseApplication>();
		List<BusinessLicenseApplication> eventPermitBLAList = new List<BusinessLicenseApplication>();
		List<BusinessLicenseApplication> brokerageBLAList = new List<BusinessLicenseApplication>();
		List<BusinessLicenseApplication> faclityChangeBlaList = new List<BusinessLicenseApplication>();
		List<BusinessLicenseApplication> afterApprovedRejectedBLAList = new List<BusinessLicenseApplication>();
		List<BusinessLicenseApplication> afterRejectedBLAList = new List<BusinessLicenseApplication>();
		List<BusinessLicenseApplication> channelofflineBLAList = new List<BusinessLicenseApplication>();
		Set<Id> sBLAIds = new Set<Id>();
		
        for (BusinessLicenseApplication newRecord : newList) {
			sBLAIds.add(newRecord.Id);
            if(!newRecord.Licence_Type_Name__c.equalsIgnoreCase(CONTINUING_EDUCATION_PROVIDER) &&
		       (!(TEMP_LICENSES_SET.contains(newRecord.Licence_Type_Name__c) &&
				newRecord.Issue_Temp_License__c))
		    ){
				afterLicenseIssuedList.add(newRecord);
		    }
			
			if (newRecord.Status != mapOfOldRecords.get(newRecord.Id).Status && newRecord.Status == LPI_LiteralConstant.BLA_SUBMITTED_STATUS) {
                afterSubmissionBLAList.add(newRecord);
            }

			if(
				newRecord.Status != mapOfOldRecords.get(newRecord.Id).Status &&
				newRecord.Status == LPI_LiteralConstant.IA_LICENSEISSUED_STATUS
			) {
				if ('Application for Permit'.equalsIgnoreCase(newRecord.ApplicationType)) {
					eventPermitBLAList.add(newRecord);
				} else {
					havingBLIdList.add(newRecord);
				}
			}

			if(newRecord.Status != mapOfOldRecords.get(newRecord.Id).Status && newRecord.Status == LPI_LiteralConstant.BLA_LICENSEISSUED_STATUS){
				afterLicenseIssueStatusList.add(newRecord);
			}
			 if (
				(mapOfOldRecords.get(newRecord.Id).Status != newRecord.Status && 
				mapOfOldRecords.get(newRecord.Id).Status == LPI_LiteralConstant.BLA_SUBMITTED_STATUS  &&
				newRecord.Status == LPI_LiteralConstant.BLA_APPROVED_STATUS) ||
				(newRecord.Status != mapOfOldRecords.get(newRecord.Id).Status &&
				newRecord.Status == LPI_LiteralConstant.BLA_REJECTED_STATUS)
			) {
				afterApprovedRejectedBLAList.add(newRecord);
			}

			if (
						newRecord.Amendment_Type__c.equalsIgnoreCase(
							LPI_LiteralConstant.BLA_CHANGE_OF_CORPORATION_ASSOCIATION_PARTNERSHIP
						) ||
						newRecord.Amendment_Type__c.equalsIgnoreCase(
							LPI_LiteralConstant.BLA_CHANGE_OF_FICTITIOUS_NAME_OR_TRADE_NAME
						)
					) {
						brokerageBLAList.add(newRecord);
					}

			if ( newRecord.Amendment_Type__c == LPI_LiteralConstant.BLA_AMENDMENT_TYPE_COURSE_RENEWAL
					||
					newRecord.ApplicationType == LPI_LiteralConstant.BLA_AMENDMENT_TYPE_APPLY_FOR_COURSE_APPROVAL
				) {
					havingCourseIdList.add(newRecord);
				}
			if (
				newRecord.ApplicationType == LPI_LiteralConstant.BLA_AMENDMENT_APPLICATIONTYPE &&
				AMENDMENT_TYPE_SET_FOR_AMENDMENTS.contains( newRecord.Amendment_Type__c )
			) {
				faclityChangeBlaList.add(newRecord);
			}
			if((newRecord.Status != mapOfOldRecords.get(newRecord.Id).Status && newRecord.Status == LPI_LiteralConstant.BLA_LICENSEISSUED_STATUS) && newRecord.ApplicationType == LPI_LiteralConstant.BLA_RENEWAL_APPLICATIONTYPE){
				afterLicenseIssueStatusforRenewalList.add(newRecord);
			}
			
        }
        if (!afterLicenseIssueStatusList.isEmpty()) {
			createBusinessLicenseOnLicenseIssued(afterLicenseIssueStatusList);
		}
        if (!afterLicenseIssueStatusforRenewalList.isEmpty()) {
			updateBLOnBLALicenseIssued(afterLicenseIssueStatusforRenewalList);
		}
		

		if(!afterLicenseIssueStatusList.isEmpty()){
			createNotifications(afterLicenseIssueStatusList,true);
		}
        if(!afterApprovedRejectedBLAList.isEmpty()){
			createNotifications(afterApprovedRejectedBLAList,true);
		}
		if(!afterSubmissionBLAList.isEmpty()){
			createNotifications(afterSubmissionBLAList,true);
		}

		if (!brokerageBLAList.isEmpty()) {
			updateBrokerageNameAmendment(brokerageBLAList);
		}
		
		if (!faclityChangeBlaList.isEmpty()) {
			performAmendmentOnBusinessLicenseAndAccount(faclityChangeBlaList);
		}
		
		if (!havingBLIdList.isEmpty()) {
			updateBusinessLicenseStatusOnLicenseIssued(havingBLIdList);
			updateExpiryDateOnBL(havingBLIdList);
			String fields = 'Id, LicensePermitNameId,Amendment_Type__c,AccountId,SavedApplicationRefId,LicenseTypeId,Course_ID__c,ApplicationType';
			String whereClause = 'Id IN ' +LPI_ServiceUtility.getStringValuesBySet(sBLAIds);
			
			updateBlOnAuthApplicationPlace(LPI_BusinessLicenseApplicationDAO.getBusinessLicenseApplicationByDymanicQuery(fields,whereClause,null,null,null));
			approveCourseForSchool(LPI_BusinessLicenseApplicationDAO.getBusinessLicenseApplicationByDymanicQuery(fields,whereClause,null,null,null));
		}

		if (!havingCourseIdList.isEmpty()) {
			approveCourseForSchool(havingCourseIdList);
		}
    }

	/**
	 * @author                      : MTX Group Product Team
	 * @since                       : November 16, 2022
	 * @description                 : This method updates the Status field of Business License object
	 */
	public static void updateBusinessLicenseStatusOnLicenseIssued(List<BusinessLicenseApplication> recordsList) {
		try {
			LPI_TriggerServiceUtility.updateBusinessLicenseStatusOnApproval(recordsList);
		} catch (Exception ex) {
			LPI_ExceptionManager.logException(getClassName(), 'updateBusinessLicenseStatusOnApproval', ex);
		}
	}

	/**
	 * @author                      :
	 * @since                       :
	 * @description                 : This method used to update expiry date on BL
	 */
	public static void updateExpiryDateOnBL(List<BusinessLicenseApplication> recordsList) {
		try {
			LPI_TriggerServiceUtility.updateExpiryDateOnBL(recordsList);
		} catch (Exception ex) {
			LPI_ExceptionManager.logException(getClassName(), 'updateExpiryDateOnBL', ex);
		}
	}

   /**
	 * @author                      : MTX Group Product Team
	 * @since                       : 29 May 2024
	 * @description                 : This method updated the business licesne records related to Business License Application records.
	 */

    public static void updateBLOnBLALicenseIssued(List<BusinessLicenseApplication> recordsList){
		try{
			Map<Id, BusinessLicenseApplication> blIdToBLAMap = new Map<Id, BusinessLicenseApplication>();
			Set<Id> setRATId = new Set<Id>(); 
			Set<Id> setPARId = new Set<Id>(); 
            Map<Id, Id> blaAccountIdToBlId = new Map<Id, Id>();
			Map<Id, RegulatoryAuthorizationType> mapRATConfigs = new Map<Id, RegulatoryAuthorizationType>();
			List<RegulatoryAuthorizationType> ratList = new List<RegulatoryAuthorizationType>();
			Map<String, RegulatoryAuthorizationType> ratNameToRatMap = new Map<String, RegulatoryAuthorizationType>();
			for (BusinessLicenseApplication objIA : recordsList) {
				blIdToBLAMap.put(objIA.LicensePermitNameId, objIA);
				blaAccountIdToBlId.put(objIA.AccountId, objIA.LicensePermitNameId);
				setRATId.add(objIA.LicenseTypeId);
                setPARId.add(objIA.SavedApplicationRefId);
				
			}
			if (!setRATId.isEmpty()) {
				String fieldsToQuery =
					'Id,Name,Open_for_Renewal__c,Renewal_Window_Period_Before_Expiry__c,Expiration_Day__c,' +
					'Expiration_Month__c,Expiration_Cycle__c,Expiration_Period__c,Expiration_Date__c,' +
					'Expiry_Rule_Type__c,ID_Card_Expiration_Period__c,Expiration_Fixed_Cycle_Start_Year__c,' +
					'Expiration_Fixed_Cycle_Difference__c,Renewal_Expiration_Day__c,Renewal_Expiration_Month__c,' +
					'Renewal_Expiration_Cycle__c,Renewal_Expiration_Period__c,Renewal_Expiry_Rule_Type__c,IssuingDepartment.Name';
				String whereClause = 'Id IN ' + LPI_ServiceUtility.getStringValuesBySet(setRATId) ;
				ratList = LPI_RegulatoryAuthorizationTypeDAO.getRegulatoryAuthorizationTypeByDymanicQuery(
					fieldsToQuery,
					whereClause,
					null,
					null,
					null
				);
				for(RegulatoryAuthorizationType rat : ratList){
					mapRATConfigs.put(rat.Id, rat);
					ratNameToRatMap.put(rat.Name, rat);
				}
			}
            if(!blIdToBLAMap.isEmpty()){
				List<BusinessLicense> updateBlList = new List<BusinessLicense>();
				for (
					BusinessLicense bl : LPI_BusinessLicenseDAO.fetchBusinessLicenseRecords(
						'Id, Currently_Hold_an_Active_License__c,'+
						'Status, Are_you_Currently_Employeed__c,'+
						'PeriodEnd,Regulatory_Authorization_Type_Name__c, Certificate_of_Identification_Issued__c, RegulatoryAuthorizationType.IssuingDepartment.Name',
						'Id IN ' + LPI_ServiceUtility.getStringValuesBySet(blIdToBLAMap.keySet())
					)
				) {
					
             
					BusinessLicense blRec = new BusinessLicense();
					blRec.Id = bl.Id;
					blRec.PeriodStart = DateTime.parse(System.Now().format());
					blRec.PeriodEnd = LPI_ServiceUtility.getExpirationDate(ratNameToRatMap.get(bl.Regulatory_Authorization_Type_Name__c));
					blRec.Status = 'Active';
					updateBlList.add(blRec);
					
				}
				if (updateBlList.size() > 0) {
					LPI_WithoutSharingUtility.updateSObjectList(updateBlList);
				}
			
			} 
		    }    catch (Exception ex) {
				LPI_ExceptionManager.logException(getClassName(), 'updateBLOnIALicenseIssued', ex);
			}
		
	}


     /**
	 * @author                      : MTX Group Product Team
	 * @since                       : 17 May 2024
	 * @description                 : This method handles the email notifications for Business License Application records.
	 */


	public static void createNotifications(List<BusinessLicenseApplication> recordsList, Boolean statusChange){
        try {
            String mdtDeveloperName;
            Set<Id> blaIdSet = new Set<Id>();
            Map<String, String> replaceTextMap = new Map<String, String>();
            Map<String, String> devNameToTemplateNameMap = new Map<String, String>();
            Map<String,String> devNameToEmailBody = new Map<String,String>();
            Map<String,String> devNameToEmailSubject = new Map<String,String>();
			Map<String,String> devNameToAttachmentRequired = new Map<String,String>();
            Map<String,String> devNameToPDFAttachmentName = new Map<String,String>();
            List<Notification_Message__mdt> notificationMessageList = new List<Notification_Message__mdt>();
            List<LPI_Wrapper.NotificationEmailWrapper> notificationEmailWrapperList = new List<LPI_Wrapper.NotificationEmailWrapper>();

            for (BusinessLicenseApplication record : recordsList) {
                blaIdSet.add(record.Id);
            }
            
            if (!blaIdSet.isEmpty()) {
                String fieldsToQuery = 'Id, Name, AccountId,Rejection_Reason__c, LicenseType.IssuingDepartment.Name,ApplicationType,Board_Name__c, Account.Name,Account.Salutation, LicenseType.Email_Specifications_Final__c,' +
                'Applicant_submission_Date__c, LicenseTypeId, Status,Channel__c ,Account.Buisness_Email__c, LicenseType.Name';
                String whereClauseToQuery = 'Id IN ' + LPI_ServiceUtility.getStringValuesBySet(blaIdSet);
                for (BusinessLicenseApplication record : LPI_BusinessLicenseApplicationDAO.getBusinessLicenseApplicationByDymanicQuery(fieldsToQuery,whereClauseToQuery,null,null,null)){
                    Map<String, Object> boardSignatureMap = (Map<String, Object>) JSON.deserializeUntyped(String.valueOf(record.LicenseType.Email_Specifications_Final__c));
                    String emailBody;
					String Subject;
                  if(statusChange == true){
                    if (record.Status == LPI_LiteralConstant.BLA_SUBMITTED_STATUS) {
                        mdtDeveloperName = APPLICATION_SUBMISSION_EMAIL;
                        notificationMessageList = LPI_CustomMetadataTypeDAO.getAllNotificationByDeveloperNames(APPLICATION_SUBMISSION_EMAIL_SET);
                        replaceTextMap = new Map<String, String> {
                            'Name' => record.Account.Name,
                            'License_Type' => record.LicenseType.Name,
                            'Portal_Link' => LPI_LiteralConstant.LPI_PORTAL_LINK,
                            'Application_Number' => record.Name
                        };
                    }

					if(record.Status == LPI_LiteralConstant.BLA_LICENSEISSUED_STATUS){
   						mdtDeveloperName = BUSINESS_LICENSE_ISSUED_EMAIL;
                        notificationMessageList = LPI_CustomMetadataTypeDAO.getAllNotificationByDeveloperNames(BUSINESS_LICENSE_ISSUED_EMAIL_SET);
                        replaceTextMap = new Map<String, String> {
                            'Name' => record.Account.Name,
                            'License_Type_Name' => record.LicenseType.Name,
                            'Portal_Link' => LPI_LiteralConstant.LPI_PORTAL_LINK,
                            'Application_Number' => record.Name
                        };
					}
                    

				 if(record.Status == LPI_LiteralConstant.BLA_APPROVED_STATUS){
					    mdtDeveloperName = BUSINESS_LICENSE_APPROVED_EMAIL;
						notificationMessageList = LPI_CustomMetadataTypeDAO.getAllNotificationByDeveloperNames(BUSINESS_LICENSE_APPROVED_EMAIL_SET);
						replaceTextMap = new Map<String, String> {
						'Application_Type' => record.ApplicationType,
						'License_Type_Name' => record.LicenseType.Name,
						'Application_Number' => record.Name
						
					};
			      }
				
					if(record.Status == LPI_LiteralConstant.BLA_REJECTED_STATUS){
						mdtDeveloperName = BUSINESS_LICENSE_REJECTED_EMAIL;
						notificationMessageList = LPI_CustomMetadataTypeDAO.getAllNotificationByDeveloperNames(BUSINESS_LICENSE_REJECTED_EMAIL_SET);
						replaceTextMap = new Map<String, String> {
						'Rejected_Reason' => record.Rejection_Reason__c,
						'License_Type_Name' => record.LicenseType.Name
						
					};
			      }
				}
				
                    for (Notification_Message__mdt noti : notificationMessageList) {
                        devNameToTemplateNameMap.put(noti.DeveloperName, noti.Template_Name__c);
                        devNameToEmailBody.put(noti.DeveloperName, noti.Description__c);
                        devNameToEmailSubject.put(noti.DeveloperName, noti.Title__c);
						devNameToAttachmentRequired.put(noti.DeveloperName, String.valueOf(noti.Attachment_Required__c));
                        devNameToPDFAttachmentName.put(noti.DeveloperName, noti.PDF_Attachment_Name__c);
                    }

                    emailBody = devNameToEmailBody.get(mdtDeveloperName);
					Subject = devNameToEmailSubject.get(mdtDeveloperName);

                    if (replaceTextMap != null) {
                        for (String key : replaceTextMap.keySet()) {
                            emailBody = emailBody.replaceAll('\\[' + key + '\\]', replaceTextMap.get(key));
							Subject =Subject.replaceAll('\\[' + key + '\\]', replaceTextMap.get(key));
							
                        }
                    }

                    LPI_Wrapper.NotificationEmailWrapper notifcationWrapper = new LPI_Wrapper.NotificationEmailWrapper();
                    notifcationWrapper.templateName = devNameToTemplateNameMap.get(mdtDeveloperName);
                    
                    LPI_Wrapper.NotificationEmailWrapper notifcationWrapperApprove = new LPI_Wrapper.NotificationEmailWrapper();
                    notifcationWrapperApprove.templateName = devNameToTemplateNameMap.get(mdtDeveloperName);
					notifcationWrapperApprove.attachmentRequired = devNameToAttachmentRequired.get(mdtDeveloperName);
                    notifcationWrapperApprove.pdfAttachmentName = devNameToPDFAttachmentName.get(mdtDeveloperName);
                    notifcationWrapperApprove.subject = Subject;
                    notifcationWrapperApprove.replaceTextMap = replaceTextMap;
                    notifcationWrapperApprove.accountId = record.AccountId;
                    notifcationWrapperApprove.recipientEmail = record.Account.Buisness_Email__c;
                    notifcationWrapperApprove.description = emailBody;
                    notifcationWrapperApprove.blaId = record.Id;
                    notificationEmailWrapperList.add(notifcationWrapperApprove);
                }
            }

			
			List<Notification__c> createdNotificationList= new List<Notification__c>();
            if (!notificationEmailWrapperList.isEmpty()) {
                createdNotificationList = LPI_ServiceUtility.createNotificationRecords(
                    notificationEmailWrapperList
                );
            }
			
			for(Notification__c ntf : createdNotificationList){
                if(ntf.Is_Attachments_Required__c == true){
                    
                    LPI_GeneratePDF.generatePDF(ntf.Business_License_Application__c,ntf.Id);
                }
            }
        } catch (Exception e) {
            LPI_ExceptionManager.logException(
                'LPI_BusinessLicenceAppTriggerHelper',
                'createNotifications',
                e
            );
        }
	}
    
    /**
	 * @author                      :
	 * @since                       :
	 * @description                 : This method used to create Business Licesne Refernce
	 */
    private static BusinessLicense getMappedBLRecord(
		BusinessLicenseApplication objBLA,
		Integer counter,
		RegulatoryAuthorizationType regAuth
	) {
		BusinessLicense blRec = LPI_TriggerServiceUtility.getMappedCommonBLRecord(objBLA, counter, regAuth);
		blRec.ContactId = objBLA.ApplicantId;
		blRec.BusinessTypeId = objBLA.BusinessTypeId;
		
		blRec.Business_Name__c = objBLA.Business_Name__c;
		blRec.Doing_Business_As_DBA_or_Trade_Name__c = objBLA.Doing_Business_As_DBA_or_Trade_Name__c;
		
		
		blRec.Profession__c = objBLA.Profession__c;
		
		blRec.Primary_Contact_Address__c = objBLA.Primary_Contact_Address__c;
		blRec.License_Address__c = objBLA.License_Address__c;
		
		blRec.Served_In_US_Armed_Force__c = objBLA.Served_In_US_Armed_Force__c;
		blRec.Info_About_Military_Related_Services__c = objBLA.Info_About_Military_Related_Services__c;
        
		if(String.isBlank(objBLA.LicensePermitNameId))
		{
			blRec.Pre_Licensure_Number__c = objBLA.Pre_Licensure_Number__c;
		}
        
		blRec.Do_you_need_PIC__c = objBLA.Do_you_need_PIC__c;
		return blRec;        
	}
    /**
	 * @author                : MTX Group Product Team
	 * @since                 : 21 April,2023
	 * @description           : This method is used to create Business Licesne Refernce for renewal application
	 */ 
    private static BusinessLicense getMappedBLRecordRenewal(BusinessLicenseApplication objBLA) {
		BusinessLicense blRec = new BusinessLicense();
		blRec.Id = objBLA.LicensePermitNameId;
		
		return blRec;
	}

    /**
	 *   @author : MTX Group Product Team
	 *   @since : 2nd Nov, 2022
	 *   @description : This method creates business license on License Issued
	 */
    public static void createBusinessLicenseOnLicenseIssued(List<BusinessLicenseApplication> recordsList) {
		try {
			Set<Id> rugAuthSet = new Set<Id>();
            Map<Id, Id> mapOfBLAIdToBLId = new Map<Id, Id>();
			Map<Id, RegulatoryAuthorizationType> mapOfRegAuth = new Map<Id, RegulatoryAuthorizationType>();
			List<BusinessLicense> bLRecordList = new List<BusinessLicense>();
			List<BusinessLicenseApplication> updateBLAList = new List<BusinessLicenseApplication>();
			List<RegulatoryAuthorizationType> listRATToBeUpdate = new List<RegulatoryAuthorizationType>();
			Map<Id, Integer> mapOfRatIdWithLicenseNumber = new Map<Id, Integer>();
			Set<String> previousBusinessLicenceNumberSet = new Set<String>();
			Set<Id> setOfBLAIdsToUpdateRelatedFromLicenseNumber = new Set<Id>();
			Set<Id> setOfAccountToUpdateRelatedFromLicenseNumber = new Set<Id>();
			Set<Id> pharmacyChangeofOwnershipLicenseSet = new Set<Id>();

			for (BusinessLicenseApplication objBLA : recordsList) {
				rugAuthSet.add(objBLA.LicenseTypeId);
			}
			if (!rugAuthSet.isEmpty()) {
				for (
					RegulatoryAuthorizationType ratRec : LPI_RegulatoryAuthorizationTypeDAO.getRATTypeByID(rugAuthSet)
				) {
					mapOfRegAuth.put(ratRec.Id, ratRec);
				}
				List<In_App_Checklist_Settings__c> appcheckCustomSettingList;
				In_App_Checklist_Settings__c appcheckCustomSetting;
				String fields = 'Business_License_Counter__c';
				String whereClause = 'Business_License_Counter__c != null';
				appcheckCustomSettingList = LPI_CustomMetadataTypeDAO.dynamicGetAppChecklistSettingBusinessLicenseNumber(fields,whereClause,'In_App_Checklist_Settings__c');
				if(!appcheckCustomSettingList.isEmpty())
				{
					appcheckCustomSetting = appcheckCustomSettingList[0];
				}
                Integer blNameCounter;
				if(appcheckCustomSetting != null){
					blNameCounter = Integer.valueOf(appcheckCustomSetting.Business_License_Counter__c);
				}
				Map<String, String> blNameWithBlaId = new Map<String, String>();
				Set<Id> parIdSet = new Set<Id>();
				for (BusinessLicenseApplication objBLA : recordsList) {
					RegulatoryAuthorizationType regAuth = mapOfRegAuth.get(objBLA.LicenseTypeId);

					if (
						objBLA.ApplicationType == LPI_LiteralConstant.BLA_NEW_APPLICATIONTYPE ||
						objBLA.ApplicationType == LPI_LiteralConstant.BLA_CHANGE_OF_OWNERSHIP
					) {
						BusinessLicense blRec = getMappedBLRecord(
							objBLA,
							blNameCounter,
							objBLA.Issue_Temp_License__c && objBLA.LicensePermitNameId == null && objBLA.Temporary_License_Number__c == null && regAuth.Temporary_License_Type__c != null
							? regAuth.Temporary_License_Type__r
							: regAuth
						);
						
						setOfBLAIdsToUpdateRelatedFromLicenseNumber.add(objBLA.Id);
						setOfAccountToUpdateRelatedFromLicenseNumber.add(objBLA.AccountId);
						Integer ratLicenseNumber;
						if (regAuth.License_Number_Format__c == null) {
							blNameCounter = blNameCounter + 1;
						} else {
							if (mapOfRatIdWithLicenseNumber.containsKey(regAuth.Id)) {
								ratLicenseNumber = mapOfRatIdWithLicenseNumber.get(regAuth.Id) + 1;
								mapOfRatIdWithLicenseNumber.put(regAuth.Id, ratLicenseNumber);
							} else {
								ratLicenseNumber = Integer.valueOf(regAuth.License_Number_Format__c) + 1;
								mapOfRatIdWithLicenseNumber.put(regAuth.Id, ratLicenseNumber);
							}
						}
						blNameWithBlaId.put(blRec.Name, objBLA.Id);
						bLRecordList.add(blRec);
					} else if (objBLA.ApplicationType == LPI_LiteralConstant.BLA_RENEWAL_APPLICATIONTYPE) {
						BusinessLicense blRec = getMappedBLRecordRenewal(objBLA);
						if (objBLA.SavedApplicationRefId != null && objBLA.Is_Auto_Approval_Allowed__c) {
							parIdSet.add(objBLA.SavedApplicationRefId);
						}
						bLRecordList.add(blRec);
					}
				}
				for (String key : mapOfRatIdWithLicenseNumber.keySet()) {
					listRATToBeUpdate.add(
						new RegulatoryAuthorizationType(
							Id = key,
							License_Number_Format__c = mapOfRatIdWithLicenseNumber.get(key)
						)
					);
				}
				if (!previousBusinessLicenceNumberSet.isEmpty()) {
					for (
						BusinessLicense bl : LPI_BusinessLicenseDAO.fetchBusinessLicenseRecords(
							'Id,Name,Status,Regulatory_Authorization_Type_Name__c',
							'Name IN ' +
								LPI_ServiceUtility.getStringValuesByStringSet(previousBusinessLicenceNumberSet) +
								' AND Status != \'Closed\''
						)
					) {
						bl.Status = 'Closed';
						bLRecordList.add(bl);
					}
				}
				if (!listRATToBeUpdate.isEmpty()) {
					LPI_DML.doUpdate(listRATToBeUpdate);
				}
				appcheckCustomSetting.Business_License_Counter__c = blNameCounter;
				LPI_WithoutSharingUtility.updateAppChecklistCustomSetting(appcheckCustomSetting);
				if (!bLRecordList.isEmpty()) {
					List<BusinessLicense> blRecordInsertedList = (List<BusinessLicense>) LPI_WithoutSharingUtility.upsertSObjectList(
						bLRecordList
					);
					
					for (BusinessLicense blRecord : blRecordInsertedList) {
						if (!previousBusinessLicenceNumberSet.contains(blRecord.Id)) {
							mapOfBLAIdToBLId.put(blNameWithBlaId.get(blRecord.Name), blRecord.Id);
						}
					}
					for (BusinessLicenseApplication objBla : recordsList) {
						if (mapOfBLAIdToBLId.containsKey(objBla.Id)) {
							updateBLAList.add(
								new BusinessLicenseApplication(
									Id = objBla.Id,
									LicensePermitNameId = mapOfBLAIdToBLId.get(objBla.Id)
								)
								);
							}
						}
					}
					if (!updateBLAList.isEmpty()) {
						LPI_TriggerHandler.bypass('LPI_BusinessLicenceAppTriggerHandler');
						if (LPI_TriggerHandler.isBypassed('LPI_BusinessLicenceAppTriggerHandler')) {
							LPI_DML.doUpdate(updateBLAList);
						}
						LPI_TriggerHandler.clearBypass('LPI_BusinessLicenceAppTriggerHandler');
						List<BusinessLicenseApplication> latestBlaRecord = LPI_BusinessLicenseApplicationDAO.getBLAById(
							mapOfBLAIdToBLId.keySet()
						);
			   }
			}
		} catch (Exception ex) {
			LPI_ExceptionManager.logException(getClassName(), 'createBusinessLicenseOnLicenseIssued', ex);
		}
	}
    /**
	 *   @author : MTX Group Product Team
	 *   @since : 2nd Nov, 2022
	 *   @description : this method is called before insert and this method updates prerequired fields like ownerId,licenseTypeId and account ID in bla record
	 */
	public static void createDueDiligence(List<BusinessLicenseApplication> recordsList) {
		try {
			LPI_TriggerServiceUtility.createDueDiligenceRecord(recordsList);
		} catch (Exception e) {
			LPI_ExceptionManager.logException('LPI_BusinessLicenceAppTriggerHelper', 'createDueDiligence', e);
			throw new AuraHandledException(e.getMessage() + e.getLineNumber());
		}
	}

	/**
	 * @author                       : MTX Group Product Team
	 * @description                  : Update Course information on BLA and update accountId on Training course object
	 */
	public static void approveCourseForSchool(List<BusinessLicenseApplication> recordsList) {
		try {
			Set<Id> licensePermitIdSet = new Set<Id>();
			Set<Id> setRegAuthId = new Set<Id>();
			Set<Id> parIdSet = new Set<Id>();
			Map<Id, RegulatoryAuthorizationType> mapOfRegAuth = new Map<Id, RegulatoryAuthorizationType>();
			Map<Id, BusinessLicense> blMap = new Map<Id, BusinessLicense>();
			Set<Id> previousCourseIdSet = new Set<Id>();
			for (BusinessLicenseApplication application : recordsList) {
				
				licensePermitIdSet.add(application.LicensePermitNameId);
				setRegAuthId.add(application.LicenseTypeId);
				parIdSet.add(application.SavedApplicationRefId);
				if (application.Course_ID__c != null) {
					previousCourseIdSet.addAll((List<Id>) application.Course_ID__c.split(';'));
				}
			}
			if (!licensePermitIdSet.isEmpty() && !setRegAuthId.isEmpty() && !parIdSet.isEmpty()) {
				for (
					RegulatoryAuthorizationType ratRec : LPI_RegulatoryAuthorizationTypeDAO.getRATTypeByID(
						setRegAuthId
					)
				) {
					mapOfRegAuth.put(ratRec.Id, ratRec);
				}
				for (
					BusinessLicense blRec : LPI_BusinessLicenseDAO.fetchBusinessLicenseRecords(
						'Id, Name',
						'Id IN ' + LPI_ServiceUtility.getStringValuesBySet(licensePermitIdSet)
					)
				) {
					blMap.put(blRec.Id, blRec);
				}
				Map<String, String> parToSchoolMap = new Map<String, String>();
				for (BusinessLicenseApplication application : recordsList) {
					
					parToSchoolMap.put(
						application.SavedApplicationRefId,
						blMap.get(application.LicensePermitNameId).Name
					);
				}
				List<In_App_Checklist_Settings__c> appcheckCustomSettingList;
				In_App_Checklist_Settings__c appcheckCustomSetting;
				String fields = 'Course_Counter__c';
				String whereClause = 'Course_Counter__c != null AND Business_License_Counter__c != null';
				appcheckCustomSettingList = LPI_CustomMetadataTypeDAO.dynamicGetAppChecklistSettingBusinessLicenseNumber(fields,whereClause,'In_App_Checklist_Settings__c');
				if(!appcheckCustomSettingList.isEmpty())
				{
					appcheckCustomSetting = appcheckCustomSettingList[0];
				}
				Integer courseCounter = Integer.valueOf(appcheckCustomSetting.Course_Counter__c);
				if (courseCounter == null) {
					courseCounter = 0;
				}
				List<TrnCourse> courseList = new List<TrnCourse>();
				String whereCondition;
				if (parIdSet.size() > 0) {
					whereCondition =
						'Preliminary_Application_Reference__c IN ' +
						LPI_ServiceUtility.getStringValuesBySet(parIdSet);
					if (previousCourseIdSet.size() > 0) {
						whereCondition =
							whereCondition +
							'OR Id IN ' +
							LPI_ServiceUtility.getStringValuesBySet(previousCourseIdSet);
					}
				} else if (previousCourseIdSet.size() > 0) {
					whereCondition = 'Id IN ' + LPI_ServiceUtility.getStringValuesBySet(previousCourseIdSet);
				}
				courseList = LPI_TrnCourseDAO.getTrnCourseByDymanicQuery(
					'Id, Preliminary_Application_Reference__c',
					whereCondition,
					null,
					null,
					null
				);
				if (courseList.size() > 0) {
					Map<Id, List<TrnCourse>> parIdToCourseMap = new Map<Id, List<TrnCourse>>();
					for (TrnCourse course : courseList) {
						if (parIdToCourseMap.containsKey(course.Preliminary_Application_Reference__c)) {
							List<TrnCourse> updateCourseList = parIdToCourseMap.get(
								course.Preliminary_Application_Reference__c
							);
							updateCourseList.add(course);
							parIdToCourseMap.put(course.Preliminary_Application_Reference__c, updateCourseList);
						} else {
							List<TrnCourse> newCourseList = new List<TrnCourse>();
							newCourseList.add(course);
							parIdToCourseMap.put(course.Preliminary_Application_Reference__c, newCourseList);
						}
					}
					List<TrnCourse> courseUpdateList = new List<TrnCourse>();
					for (BusinessLicenseApplication tempBLARec : recordsList) {
						if (tempBLARec.Amendment_Type__c == LPI_LiteralConstant.BLA_AMENDMENT_TYPE_COURSE_RENEWAL) {
							TrnCourse courseToUpdate = new TrnCourse();
							courseToUpdate.Id = tempBLARec.Course_Id__c;
							courseToUpdate.Status = LPI_LiteralConstant.STATUS_ACTIVE;
							courseToUpdate.Expiry_Date__c = Date.valueOf(
								LPI_TriggerServiceUtility.validateAndGetExpiryDate(
									tempBLARec,
									mapOfRegAuth.get(tempBLARec.LicenseTypeId),
									null
								)
							);
							courseUpdateList.add(courseToUpdate);
						} else {
							for (TrnCourse currentCourse : parIdToCourseMap.get(tempBLARec.SavedApplicationRefId)) {
								TrnCourse courseToUpdate = new TrnCourse();
								courseToUpdate.Id = currentCourse.Id;

								courseToUpdate.Account__c = tempBLARec.AccountId;
								courseToUpdate.Course_ID__c =
									String.valueOf((parToSchoolMap.get(tempBLARec.SavedApplicationRefId)).substring(0, 4))
										.leftPad(5, '0') + String.valueOf(courseCounter).leftPad(5, '0');
								courseCounter += 1;
								courseToUpdate.Status = LPI_LiteralConstant.STATUS_ACTIVE;
								courseToUpdate.Expiry_Date__c = Date.valueOf(
									LPI_TriggerServiceUtility.validateAndGetExpiryDate(
										tempBLARec,
										mapOfRegAuth.get(tempBLARec.LicenseTypeId),
										null
									)
								);
								courseUpdateList.add(courseToUpdate);
							}
						}
					}
					if (courseUpdateList.size() > 0) {
						LPI_DML.doUpdate(courseUpdateList);
					}
					if( courseCounter != Integer.valueOf(appcheckCustomSetting.Course_Counter__c)){
						LPI_WithoutSharingUtility.updateCourseCounterCustomSetting(courseCounter);
					}
				}
			}
		} catch (Exception ex) {
			LPI_ExceptionManager.logException(getClassName(), 'approveCourseForSchool', ex);
		}
	}

	public static void performAmendmentOnBusinessLicenseAndAccount(List<BusinessLicenseApplication> recordsList) {
		try {
			List<Schema.Location> locationTobeUpdatedClosed = new List<Schema.Location>();
			Map<Id, BusinessLicenseApplication> mapOfBlaIdtoBlaMap = new Map<Id, BusinessLicenseApplication>();
			Map<Id, Schema.Location> blToLocRecMap = new Map<Id, Schema.Location>();
			List<Schema.Location> newLocUpdateList = new List<Schema.Location>();
			List<AssociatedLocation> associatedLocList = new List<AssociatedLocation>();
			List<Account> accList = new List<Account>();
			for (BusinessLicenseApplication bla : recordsList) {
				mapOfBlaIdtoBlaMap.put(bla.Id, bla);
			}
			if (!mapOfBlaIdtoBlaMap.isEmpty()) {
				Map<Id, Id> locIdToBlaId = new Map<Id, Id>();
				Map<Id, AuthApplicationPlace> locIdToAapRecMap = new Map<Id, AuthApplicationPlace>();
				for (
					AuthApplicationPlace aap : LPI_AuthApplicationPlaceDAO.getAuthApplicationPlaceByDymanicQuery(
						'Id, RgltyAuthApplicationId,PlaceId',
						'RgltyAuthApplicationId IN ' +
						LPI_ServiceUtility.getStringValuesBySet(mapOfBlaIdtoBlaMap.keySet()),
						null,
						null,
						null
					)
				) {
					locIdToAapRecMap.put(aap.PlaceId, aap);
				}
				if (!locIdToAapRecMap.isEmpty()) {
					for (
						Schema.Location locRec : LPI_LocationDAO.getLocationByDymanicQuery(
							'Id, Business_Phone__c, LocationType,(SELECT ID, City, CountryCode, PostalCode, StateCode, Street, County__c, Business_State__c FROM Addresses)',
							'Id IN ' +
								LPI_ServiceUtility.getStringValuesBySet(locIdToAapRecMap.keySet()) +
								' AND Status__c = \'' +
								LPI_LiteralConstant.LOCATION_STATUS_CLOSED +
								'\'' +
								' AND (LocationType = \'' +
								LPI_LiteralConstant.LOCATION_TYPE_BUSINESS_ADDRESS +
								'\'' +
								' OR LocationType = \'' +
								LPI_LiteralConstant.MAILING +
								'\'' +
								' OR LocationType = \'' +
								SPONSORING_LOCATION +
								'\')',
							null,
							null,
							null
						)
					) {
						Id accountId = mapOfBlaIdtoBlaMap.get(locIdToAapRecMap.get(locRec.Id).RgltyAuthApplicationId)
							.AccountId;
						if (!locRec.Addresses.isEmpty()) {
							blToLocRecMap.put(
								mapOfBlaIdtoBlaMap.get(locIdToAapRecMap.get(locRec.Id).RgltyAuthApplicationId)
									.LicensePermitNameId,
								locRec
							);
							Account acc = new Account();
							acc.id = accountId;
							if (locRec.LocationType.equalsIgnoreCase(LPI_LiteralConstant.LOCATION_TYPE_BUSINESS_ADDRESS)) {
								acc.BillingCity = locRec.Addresses[0].City;
								acc.BillingCountryCode = locRec.Addresses[0].CountryCode;
								acc.BillingStreet = locRec.Addresses[0].street;
								acc.BillingStateCode = locRec.Addresses[0].statecode;
								acc.BillingPostalCode = locRec.Addresses[0].PostalCode;
								acc.Phone = locRec.Business_Phone__c;
								acc.Fax = mapOfBlaIdtoBlaMap.get(locIdToAapRecMap.get(locRec.Id).RgltyAuthApplicationId)
									.Fax_Number__c;
							} else if (locRec.LocationType.equalsIgnoreCase(LPI_LiteralConstant.MAILING)) {
								acc.ShippingCity = locRec.Addresses[0].City;
								acc.ShippingCountryCode = locRec.Addresses[0].CountryCode;
								acc.ShippingStreet = locRec.Addresses[0].street;
								acc.ShippingStateCode = locRec.Addresses[0].statecode;
								acc.ShippingPostalCode = locRec.Addresses[0].PostalCode;
								acc.County__c = locRec.Addresses[0].County__c;
							}
							accList.add(acc);
						}
						locRec.Status__c = LPI_LiteralConstant.LOCATION_STATUS_OPEN;
						locRec.OpenDate = System.today();
						newLocUpdateList.add(locRec);
						if (locRec.LocationType != SPONSORING_LOCATION) {
							associatedLocList.add(createAssociatedLocation(accountId, locRec.Id));
						}
					}
					Map<Id, String> blToLocName = new Map<Id, String>();
					Map<Id, Id> locIdToBlIdMap = new Map<Id, Id>();
					if (!blToLocRecMap.isEmpty()) {
						
						Set<Id> setOfLocationIdForBL = new Set<Id>();
						for (
							AuthApplicationPlace authPlace : LPI_AuthApplicationPlaceDAO.getAuthApplicationPlaceByAuthorizationIds(
								blToLocRecMap.keySet()
							)
						) {
							locIdToBlIdMap.put(authPlace.PlaceId, authPlace.AuthorizationId);
						}
						for (
							Schema.Location loc : LPI_LocationDAO.getLocationByDymanicQuery(
								'Id, Name, Status__c, CloseDate,LocationType',
								'Id IN ' +
									LPI_ServiceUtility.getStringValuesBySet(locIdToBlIdMap.keySet()) +
									' AND Status__c = \'' +
									LPI_LiteralConstant.LOCATION_STATUS_OPEN +
									'\'',
								null,
								null,
								null
							)
						) {
							if (
								blToLocRecMap.containsKey(locIdToBlIdMap.get(loc.Id)) &&
								blToLocRecMap.get(locIdToBlIdMap.get(loc.Id))
									.LocationType.equalsIgnoreCase(loc.LocationType)
							) {
								loc.Status__c = LPI_LiteralConstant.LOCATION_STATUS_CLOSED;
								loc.CloseDate = System.today();
								locationTobeUpdatedClosed.add(loc);
							}
						}
						if (!accList.isEmpty()) {
							LPI_DML.doUpdate(accList);
						}
						if (!locationTobeUpdatedClosed.isEmpty()) {
							LPI_DML.doUpdate(locationTobeUpdatedClosed);
						}
						if (!newLocUpdateList.isEmpty()) {
							LPI_DML.doUpdate(newLocUpdateList);
						}
						if (!associatedLocList.isEmpty()) {
							LPI_DML.doInsert(associatedLocList);
						}
					}
				}
			}
		} catch (Exception e) {
			LPI_ExceptionManager.logException(getClassName(), 'performAmendmentOnBusinessLicenseAndAccount', e);
		}
	}

	private static AssociatedLocation createAssociatedLocation(String parentId, String locId) {
		AssociatedLocation assLocation = new AssociatedLocation();
		assLocation.LocationId = locId;
		assLocation.ParentRecordId = parentId;
		return assLocation;
	}

	public static void updateBrokerageNameAmendment(List<BusinessLicenseApplication> recordsList) {
		try {
			List<BusinessLicense> blUpdateList = new List<BusinessLicense>();
			List<Account> accUpdateList = new List<Account>();
			Map<String, BusinessLicenseApplication> blTOBLAMap = new Map<String, BusinessLicenseApplication>();
			Boolean flag = false;
			for (BusinessLicenseApplication objBLA : recordsList) {
				flag = false;
				BusinessLicense blRec = new BusinessLicense();
				blRec.Id = objBLA.LicensePermitNameId;
				Account businessAcct = new Account();
				businessAcct.Id = objBLA.AccountId;
				if (
					objBLA.Amendment_Type__c.equalsIgnoreCase(
						LPI_LiteralConstant.BLA_CHANGE_OF_CORPORATION_ASSOCIATION_PARTNERSHIP
					)
				) {
					flag = true;
					if(String.isNotBlank(objBLA.Business_Name__c)){
						blRec.Business_Name__c = objBLA.Business_Name__c;
						businessAcct.Name = objBLA.Business_Name__c;
					}
					
				} else if (
					objBLA.Amendment_Type__c.equalsIgnoreCase(
						LPI_LiteralConstant.BLA_CHANGE_OF_FICTITIOUS_NAME_OR_TRADE_NAME
					)
				) {
					if (objBLA.Amendment_Request_Type__c.equalsIgnoreCase(LPI_LiteralConstant.AMENDMENT_REQUEST_TYPE_NEW)) {
						flag = true;
						blRec.Doing_Business_As_DBA_or_Trade_Name__c = objBLA.Doing_Business_As_DBA_or_Trade_Name__c;
						businessAcct.Doing_Business_As_DBA_or_Trade_Name__c = objBLA.Doing_Business_As_DBA_or_Trade_Name__c;
					} else if (
						objBLA.Amendment_Request_Type__c.equalsIgnoreCase(LPI_LiteralConstant.AMENDMENT_REQUEST_TYPE_CANCEL)
					) {
						flag = true;
						blRec.Doing_Business_As_DBA_or_Trade_Name__c = null;
						businessAcct.Doing_Business_As_DBA_or_Trade_Name__c = null;
					} else if (
						objBLA.Amendment_Request_Type__c.equalsIgnoreCase(LPI_LiteralConstant.AMENDMENT_REQUEST_TYPE_RENEW)
					) {
						flag = false;
						blRec.Renew_Date_of_Fictitious_Name__c = System.today();
						blUpdateList.add(blRec);
					}
				}
				if (flag) {
					blUpdateList.add(blRec);
					accUpdateList.add(businessAcct);
				}
			}
			if (!blUpdateList.isEmpty()) {
				LPI_DML.doUpdate(blUpdateList);
			}
			if (!accUpdateList.isEmpty()) {
				LPI_DML.doUpdate(accUpdateList);
			}
		} catch (Exception ex) {
			LPI_ExceptionManager.logException(getClassName(), 'updateBrokerageNameAmendment', ex);
		}
	}

	public static void createObjectRecordsOnAfterInsert(List<BusinessLicenseApplication> recordsList) {
		try {
			List<RegulatoryTrxnFee> trxnFeeList = new List<RegulatoryTrxnFee>();
			List<RegulatoryTrxnFeeItem> trxnFeeItemList = new List<RegulatoryTrxnFeeItem>();
			Map<Id, Id> parIdWithIaIds = new Map<Id, Id>();
			Map<Id, List<Temp_Fee__c>> iaIdsWithListTempFee = new Map<Id, List<Temp_Fee__c>>();
			for (BusinessLicenseApplication blaRecord : recordsList) {
				parIdWithIaIds.put(blaRecord.SavedApplicationRefId, blaRecord.Id);
				
			}
			
			if (!parIdWithIaIds.isEmpty()) {
				
				LPI_TriggerServiceUtility.createRegulatoryTrxnFeeAndFeeItemRec(parIdWithIaIds);
				LPI_TriggerServiceUtility.createAuthApplicationPlace(parIdWithIaIds);
				LPI_TriggerServiceUtility.createApplicationContentRecord(parIdWithIaIds);
			}
		} catch (Exception ex) {
			LPI_ExceptionManager.logException(getClassName(), 'afterInsertFunctioanlity', ex);
		}
	}

	public static void updateBlOnAuthApplicationPlace(List<BusinessLicenseApplication> recordList) {
		try {
			LPI_TriggerServiceUtility.updateAuthApplicationPlace(recordList);
		} catch (Exception ex) {
			LPI_ExceptionManager.logException(getClassName(), 'updateBlOnAuthApplicationPlace', ex);
		}
	}
}