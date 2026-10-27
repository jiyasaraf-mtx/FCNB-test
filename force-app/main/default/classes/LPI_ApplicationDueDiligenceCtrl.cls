/**
 * @author              : MTX.Inc
 * @since               : 3rd Nov, 2022
 * @description         : This is controller class for mtxLpi_ApplicationDueDiligence lwc component.
 * @history
 * -------------------------------------------------------------------------------------------------------
 * Version      Date                Author                  Details
 *    1         3rd Nov, 2022       MTX.Inc                 Initial Developement
 *    2         24 Jan, 2023        Pranaya Etta            Used DAO classes for queries
 *    3         01 Feb, 2023        Dhanashree Chougule     Updated missing comments
 *    4         07 Feb, 2023        Nitish Gundedi          Updated dueDiligenceAfterApproved query and return types
 * -------------------------------------------------------------------------------------------------------
 */
public with sharing class LPI_ApplicationDueDiligenceCtrl {
	public static final String PROFILE_SUPPORT_STAFF = 'Support Staff';

	/**
	* @description This method is used to fetch the DueDiligence records to use in LWC Component and it is avaliable for BLA and IA
	* @author Ayush Dev | 05-06-2024 
	* @param recordId 
	* @return string 
	**/
	@AuraEnabled
	public static string getDueDiligenceList(Id recordId) {
		try {
			String objectName = recordId.getSObjectType().getDescribe().getName();
			String applicationStatus,applicationType;
			String queueId;
			Boolean isUserInGroup;
			Id loggedInUserId = UserInfo.getUserId();
			if (objectName == LPI_LiteralConstant.BLA_SOBJECT_API) {
				String blaFields = 'ID,Status,ApplicationType,OwnerId';
				String whereClause = 'Id = \'' + String.escapeSingleQuotes(recordId) + '\'';
				List<BusinessLicenseApplication> bla = LPI_BusinessLicenseApplicationDAO.getBusinessLicenseApplicationByDymanicQuery(
					blaFields,
					whereClause,
					'1',
					null,
					null
				);
				applicationStatus = bla[0]?.Status;
				applicationType = bla[0]?.ApplicationType;
				queueId = bla[0]?.OwnerId;
			} else if (objectName == LPI_LiteralConstant.IA_SOBJECT_API) {
				String ilaFields = 'ID,Status,ApplicationType,OwnerId';
				String whereClause = 'Id = \'' + String.escapeSingleQuotes(recordId) + '\'';
				List<IndividualApplication> ila = LPI_IndividualApplicationDAO.getIndividualApplicationByDymanicQuery(
					ilaFields,
					whereClause,
					'1',
					null,
					null
				);
				applicationStatus = ila[0]?.Status;
				applicationType = ila[0]?.ApplicationType;
				queueId = ila[0]?.OwnerId;
			}
			if (queueId != null) {
				isUserInGroup = [SELECT COUNT() FROM GroupMember WHERE UserOrGroupId = :loggedInUserId AND GroupId = :queueId] > 0;
				Set<String> setOfEDApproversGroups = new Set<String>{'Accountancy_EDs','Acupuncture_EDs','APEPLSPLA_EDs','Athlete_Agents_EDs','Athletics_EDs','Behavior_Analyst_Advisory_Board_EDs','Board_of_Geologist_Registration_EDs','Chiropractic_Examiners_EDs','Cosmetology_Barber_Examiners_EDs','Dental_EDs','Dietitians_EDs','Electrical_Contractors_EDs','Embalmers_Funeral_Directors_EDs','Endowed_Care_Cemeteries_EDs','Healing_Arts_EDs','Hearing_Instrument_Specialists_EDs','Interior_Design_EDs','Investigator_Board_EDs','Marital_Family_Therapists_EDs','Massage_Therapists_EDs','Medical_Inspection_EDs','Nursing_EDs','Occupational_Therapy_EDs','Optometry_EDs','Pharmacy_EDs','Podiatrists_EDs','Professional_Counselors_EDs','Real_Estate_Appraisers_EDs','Real_Estate_EDs','Respiratory_Care_EDs','Social_Workers_EDs','State_Committee_of_Interpreters_EDs','State_Committe_of_Psychologists_EDs','Tattooing_Body_Piercing_Branding_EDs','Veterinary_EDs'};//for I-248143
				List<GroupMember> groupMemberships = [SELECT Id, GroupId FROM GroupMember WHERE UserOrGroupId = :queueId];//for I-248143
				Set<Id> groupIdsSet = new Set<Id>();
				Set<Id> memberIdSet = new Set<Id>();
				for(GroupMember member : [SELECT UserOrGroupId FROM GroupMember WHERE GroupId = :queueId] ){
					if(member.UserOrGroupId == loggedInUserId){
						isUserInGroup = true;
						break;
					}
					memberIdSet.add(member.UserOrGroupId);
				}
				if(!isUserInGroup){
					for(GroupMember member : [SELECT UserOrGroupId FROM GroupMember WHERE GroupId IN: memberIdSet]){
						if(member.UserOrGroupId == loggedInUserId){
							isUserInGroup = true;
							break;
						}
					}
				}
				for (GroupMember membership : groupMemberships) {
					groupIdsSet.add(membership.GroupId);
				}
				List<Group> groupsList = [SELECT Id, DeveloperName FROM Group WHERE Id IN :groupIdsSet];
				for (Group groupInfo : groupsList) {
					if (setOfEDApproversGroups.contains(groupInfo.DeveloperName)) {
						isUserInGroup = true;
					}
				}
		    }
			List<DueDiligenceWrapper> wrapperList = new List<DueDiligenceWrapper>();
			if(applicationStatus != LPI_LiteralConstant.IA_DRAFT_STATUS)
			{
				String fieldsToQuery = 'ID,Completed_By__c,Completed_by__r.Name,Application_Status__c,Checklist_Name__c,Ad_hoc_Checklist_Item__c,Automated__c,Comment__c,Internal_Comments__c,Completion_Date__c,Enable_Not_Applicable__c,Help_Text__c,Sequence__c,Status__c,Unique_API_Name__c,Video_Link__c,Responsible_Party__c,Responsible_Party__r.Name,Due_Diligence_Line_Item__c,Next_Application_Status__c,Application__r.Status,Individual_Application__r.Status,Application__r.ApplicationType,Individual_Application__r.ApplicationType';
				String whereClause =
					'Application__c = \'' +
					String.escapeSingleQuotes(recordId) +
					'\'' +
					' OR Individual_Application__c = \'' +
					String.escapeSingleQuotes(recordId) +
					'\'';
				String orderBy = 'Sequence__c';
				List<Due_Diligence__c> dueDiligenceList = LPI_DueDiligenceDAO.getDueDiligenceByDymanicQuery(
					fieldsToQuery,
					whereClause,
					null,
					orderBy,
					null
				);
				List<User> currentUserList = LPI_UserDao.getCurrentUserRecord();
				String profile;
				if(!currentUserList.isEmpty()){
					profile = currentUserList[0].Profile.Name;
					for (Due_Diligence__c dd : dueDiligenceList) {
						DueDiligenceWrapper wrapper = new DueDiligenceWrapper();
						wrapper.Id = dd.Id;
						wrapper.Status = dd.Status__c;
						wrapper.Comment = dd.Comment__c;
						wrapper.internalComment = dd.Internal_Comments__c;
						wrapper.IsCommentRequired = dd.Status__c == 'Missing' ? true : false;
						wrapper.CheckListName = dd.Checklist_Name__c;
						wrapper.HelpText = dd.Help_Text__c;
						wrapper.ResponsiblePartyId = dd.Responsible_Party__c;
						wrapper.ResponsiblePartyName = dd.Responsible_Party__r.Name;
						wrapper.CompletionDate = dd.Completion_Date__c;
						wrapper.EnableNotApplicable = dd.Enable_Not_Applicable__c;
						wrapper.ApplicationStatus = dd.Application_Status__c;
						wrapper.CompletedByName = dd.Completed_by__r.Name;
						wrapper.CompletedBy = dd.Completed_By__c;
						if(dd.Individual_Application__c != null){
							wrapper.IndividualApplication = dd.Individual_Application__c;
							wrapper.IAStatus = dd.Individual_Application__r.Status;
							if(dd.Individual_Application__r.ApplicationType == LPI_LiteralConstant.BLA_RENEWAL_APPLICATIONTYPE && profile == PROFILE_SUPPORT_STAFF){
								wrapper.isSupportStaff = true;
								wrapper.ResponsiblePartySS = currentUserList[0].Id;
							}
						}
						else{
							wrapper.BusinessApplication = dd.Application__c;
							wrapper.BLAStatus = dd.Application__r.Status;
							if(dd.Application__r.ApplicationType == LPI_LiteralConstant.BLA_RENEWAL_APPLICATIONTYPE && profile == PROFILE_SUPPORT_STAFF){
								wrapper.isSupportStaff = true;
								wrapper.ResponsiblePartySS = currentUserList[0].Id;
							}
						}
						wrapper.isChanged = false;
						wrapper.isQueueMember = isUserInGroup;
						wrapperList.add(wrapper);
					}
				}
			}
			return JSON.serialize(wrapperList);
		} catch (Exception e) {
			LPI_ExceptionManager.logException('ApplicationDueDiligenceCtrl', 'getDueDiligenceList', e);
			throw new AuraHandledException(e.getMessage() + e.getLineNumber());
		}
	}

	/**
	* @description This method is updating the Completed_By__c and Completion_Date__c field values when Status value is Completed
	* @author Ayush Dev | 05-06-2024 
	* @param record 
	* @param applicationId 
	* @return boolean 
	**/
	@AuraEnabled
	public static boolean updateDueDiligence(String record, String applicationId) {
		try {
			List<DueDiligenceWrapper> ddList = (List<DueDiligenceWrapper>) JSON.deserializeStrict(record, List<DueDiligenceWrapper>.class);
			List<Due_Diligence__c> ddListToUpdate = new List<Due_Diligence__c>();
			for(DueDiligenceWrapper dd : ddList){
				Due_Diligence__c ddRec = new Due_Diligence__c();
				ddRec.Id = dd.Id;
				ddRec.Status__c = dd.Status;
				ddRec.Comment__c = dd.Comment;
				ddRec.Internal_Comments__c = dd.internalComment;
				if (dd.Status == LPI_LiteralConstant.Inspection_Status_COMPLETED) {
					ddRec.Completed_By__c = Userinfo.getUserId();
					ddRec.Responsible_Party__c = Userinfo.getUserId();//for I-240575
					ddRec.Completion_Date__c = System.now();
				} else {
					ddRec.Completed_By__c = null;
					ddRec.Completion_Date__c = null;
				}
				ddListToUpdate.add(ddRec);
			}
			if(!ddListToUpdate.isEmpty()){
				LPI_DML.doUpdate(ddListToUpdate);
			}
			return true;
		} catch (Exception e) {
			LPI_ExceptionManager.logException('ApplicationDueDiligenceCtrl', 'updateDueDiligence', e);
			throw new AuraHandledException(e.getMessage() + e.getLineNumber());
		}
	}

	/**
	* @description This method has the functionality of DueDiligence when the BLA or IA status value is approved or Licence Issued
	* @author Ayush Dev | 05-06-2024 
	* @param recordId 
	* @return List<Due_Diligence__c> 
	**/
	@AuraEnabled
	public static List<Due_Diligence__c> dueDiligenceAfterApproved(Id recordId) {
		try {
			String objectName = recordId.getSObjectType().getDescribe().getName();
			List<Due_Diligence__c> dueDiligenceList;
			String applicationStatus;
			if (objectName == LPI_LiteralConstant.BLA_SOBJECT_API) {
				String blaFields = 'ID,Status';
				String whereClause = 'Id = \'' + String.escapeSingleQuotes(recordId) + '\'';
				List<BusinessLicenseApplication> bla = LPI_BusinessLicenseApplicationDAO.getBusinessLicenseApplicationByDymanicQuery(
					blaFields,
					whereClause,
					'1',
					null,
					null
				);
				applicationStatus = bla[0]?.Status;
			}
			if (objectName == LPI_LiteralConstant.IA_SOBJECT_API) {
				String ilaFields = 'ID,Status';
				String whereClause = 'Id = \'' + String.escapeSingleQuotes(recordId) + '\'';
				List<IndividualApplication> ila = LPI_IndividualApplicationDAO.getIndividualApplicationByDymanicQuery(
					ilaFields,
					whereClause,
					'1',
					null,
					null
				);
				applicationStatus = ila[0]?.Status;
			}
			if (applicationStatus == LPI_LiteralConstant.IA_LICENSEISSUED_STATUS) {
				String fieldsToQuery = 'ID,Completed_By__c,Completed_by__r.Name,Application_Status__c,Checklist_Name__c,Ad_hoc_Checklist_Item__c,Automated__c,Comment__c,Internal_Comments__c,Completion_Date__c,Enable_Not_Applicable__c,Help_Text__c,Sequence__c,Status__c,Unique_API_Name__c,Video_Link__c,Responsible_Party__c,Responsible_Party__r.Name,Due_Diligence_Line_Item__c,Next_Application_Status__c,Application__r.Status,Individual_Application__r.Status,Application__c,Individual_Application__c';
				String whereClause =
					'(Application__c = \'' +
					String.escapeSingleQuotes(recordId) +
					'\'' +
					' OR Individual_Application__c = \'' +
					String.escapeSingleQuotes(recordId) +
					'\')';
				String orderBy = 'Application_Status__c DESC, Sequence__c ASC';
				dueDiligenceList = LPI_DueDiligenceDAO.getDueDiligenceByDymanicQuery(
					fieldsToQuery,
					whereClause,
					null,
					orderBy,
					null
				);
			}
			return dueDiligenceList;
		} catch (Exception e) {
			LPI_ExceptionManager.logException('ApplicationDueDiligenceCtrl', 'dueDiligenceAfterApproved', e);
			throw new AuraHandledException(e.getMessage() + e.getLineNumber());
		}
	}
	public class DueDiligenceWrapper {
        public String Id;
        public String Status;
        public String Comment;
		public boolean IsCommentRequired;
		public String CheckListName;
		public String HelpText;
        public String ResponsiblePartyId;
		public String IndividualApplication;
        public String BusinessApplication;
        public String BLAStatus;
        public String IAStatus;
        public DateTime CompletionDate;
		public Boolean EnableNotApplicable;
		public String ApplicationStatus;
		public String ResponsiblePartyName;
		public String CompletedByName;
		public String CompletedBy;
		public boolean isChanged;
		public boolean isSupportStaff;
		public String ResponsiblePartySS;
		public boolean isQueueMember;
		public String internalComment;
	}

}