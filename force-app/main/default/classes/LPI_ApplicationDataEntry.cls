/**
 * @author          : Ambati Sukanya
 * @description     : This class is a remote class which is used in OS for getting data and deleting PAR record
 * * @history
 * -------------------------------------------------------------------------------------------------------
 * Version      Date                Author                  Details
 *    1         11th Dec, 2022  	Ambati Sukanya          Initial Developement
 *    2         01-27-2023      	Ambati Sukanya          Refactored code as per code review comments
 * 	  3         14 Jun, 2023      	Chanda Rithvik          Updated getApplicationInstructionsData for ASBOG
 * 	  4         07 July,2023      	Adarsh Singh            Updated getApplicationInstructionsData for COSBAR
 * 
 * -------------------------------------------------------------------------------------------------------
 */
global with sharing class LPI_ApplicationDataEntry implements Callable {
	/*************************************** ALL CONSTANTS ************************************************/
	/*private final static String DELETE_PAR_RECORD = 'deleteParRecord';
    private final static String DELETE_IA_RECORD = 'deleteIARecord';
	private final static String GET_APPLICATION_INSTRUCTION_DATA = 'getApplicationInstructionsData';*/
    private final static String FD_AFFIDAVIT_OF_WORK_METADATA = 'FD_Affidavit_of_Work';
    private final static String REGISTRATION_FORM_NAVIGATION = 'submit-registration-form';
	/*************************************** ALL CONSTANTS END ********************************************/

	/**
	 * @author                      : Ambati Sukanya
	 * @since                       :
	 * @description                 : This method calls invoke method
	 * @param action                : String
	 * @param args			        : Map<String, Object>
	 * @return                      : Object
	 * @last modified by            : Uzma Md
	 * @last modified date          :
	 * @modified details            :
	 */
	global Object call(String action, Map<String, Object> args) {
		Map<String, Object> input = (Map<String, Object>) args.get('input');
		Map<String, Object> output = (Map<String, Object>) args.get('output');
		Map<String, Object> options = (Map<String, Object>) args.get('options');
		return invokeMethod(action, input, output, options);
	}
	/**
	 * @description         :   This method invokes methods which are used as remote methods in 
     *                          PHPharmacistInternApplicationCategory flexcard and related review flexcard 
	 * @author              :   Ambati Sukanya|11th Dec, 2022
	 * @param methodName 	:	String method name
	 * @param inputMap		:	Map<String, Object> input map from OS
	 * @param outMap 		: 	Map<String, Object>
	 * @param options 		:	Map<String, Object>
	 **/

	private Boolean invokeMethod(
		String methodName,
		Map<String, Object> inputMap,
		Map<String, Object> outMap,
		Map<String, Object> options
	) {
		Boolean result = true;
		try {
			/*if (methodName == DELETE_PAR_RECORD) {
				deleteParRecord((String) inputMap.get('parid'));
            }else if(methodName == DELETE_IA_RECORD){
                deleteIARecord((String) inputMap.get('parid'));
            }else if (methodName == GET_APPLICATION_INSTRUCTION_DATA) {
				outMap.put('appdata', getApplicationInstructionsData((String) inputMap.get('parid')));
			}*/
		} catch (Exception e) {
			result = false;
			LPI_ExceptionManager.logException('LPI_ApplicationDataEntry', 'invokeMethod', e);
		}
		return result;
	}
	/**
	 * @description    : This method deletes par record
	 * @author         : Ambati Sukanya | 11th Dec, 2022
	 * @param inputMap : fetching all the input from Omniscript
	 * @param outMap   : Passing value to Omniscript 
	 * @param options  : Map<String, Object>
	 **/
	/*public static void deleteParRecord(String parid) {
        try {
			if (String.isNotBlank(parid)) {
				List<PreliminaryApplicationRef> prelimanaryApplicationList = LPI_PreliminaryApplicationRefDAO.getPreliminaryApplicationRefByDymanicQuery(
					'Id', ' Id =\'' + String.escapeSingleQuotes(parid) + '\'', null, null, null
				);
				
				if(!prelimanaryApplicationList.isEmpty()){
					//Deleting records
					LPI_WithoutSharingUtility.deleteSObject(prelimanaryApplicationList);
				}
			}
        } catch (Exception e) {
			LPI_ExceptionManager.logException('LPI_ApplicationDataEntry', 'deleteParRecord', e);
        }
    }/*
    /**
	 * @description    : This method deletes IA record
	 * @author         : Ramadevi Medoji | 23rd Nov, 2023
	 * @param inputMap : fetching all the input from Omniscript
	 * @param outMap   : Passing value to Omniscript 
	 * @param options  : Map<String, Object>
	 **/
	/*public static void deleteIARecord(String parid) {
        try {
			if (String.isNotBlank(parid)) {
                String iAFields = 'Id, SavedApplicationRefId';
				List<IndividualApplication> individualApplicationList = LPI_IndividualApplicationDAO.getIndividualApplicationByDymanicQuery(
					iAFields, ' SavedApplicationRefId =\'' + String.escapeSingleQuotes(parid) + '\'', null, null, null
				);
				if(!individualApplicationList.isEmpty()){
					LPI_WithoutSharingUtility.deleteSObject(individualApplicationList);
				}
			}
        } catch (Exception e) {
			LPI_ExceptionManager.logException('LPI_ApplicationDataEntry', 'deleteIARecord', e);
        }
    }/*
	
	/*
    @author :  Ambati Sukanya
    @BuildDate  : 11th Dec, 2022
    @description : This method fetches and returns fields of PAR required for Pharmacy Intern license
    @params : String parid
    @return : List<Map<String,String>>
	*/
	/*public static List<Map<String, String>> getApplicationInstructionsData(String parid) {
		List<Map<String, String>> appData = new List<Map<String, String>>();
		try {
			String parFields = 'Id,'
                + 'Regulatory_Authorization_Type__r.Name,'
                + 'Currently_Hold_an_Active_License__c, Currently_Licensed_and_Seeking_for_PG__c,'
                + 'Currently_Hold_Operator_License__c,Amendment_Type__c';
			List<PreliminaryApplicationRef> parList = new List<PreliminaryApplicationRef>();
			//checking if parid is not empty to use in query
			if (!String.isEmpty(parid)) {
				String whereClause = 'Id = \'' + String.escapeSingleQuotes(parid) + '\'';
				parList = LPI_PreliminaryApplicationRefDAO.getPreliminaryApplicationRefByDymanicQuery(
					parFields,
					whereClause,
					null,
					null,
					null
				);
			}
			//checking if the returned list is not empty to iterate over it
			if (!parList.isEmpty()) {
				//iterating over parList to add the data into map
				for (PreliminaryApplicationRef par : parList) {
					Map<String, String> data = new Map<String, String>();
					// data.put(
					// 	'Graduated_From_ACPE_Accredited_College__c',
					// 	'' + par.Graduated_From_Accredited_College__c
					// );
					//Commenting this line as this field is deleted
					//data.put('Missouri_Application_On_File_With_Board__c', '' + par.Application_On_File_With_Board__c);
					//data.put('Hold_a_Certification_From_Board__c', '' + par.Hold_a_Certification_From_Board__c);
					data.put('regAuthTypeName', '' + par.Regulatory_Authorization_Type__r.Name);
					data.put('Currently_Hold_an_Active_License__c', '' + par.Currently_Hold_an_Active_License__c);
                    data.put(
						'Currently_Licensed_and_Seeking_for_PG__c',
						'' + par.Currently_Licensed_and_Seeking_for_PG__c
					);
                    //data.put('NABP_e_Profile_ID__c', par.NABP_e_Profile_ID__c);
                    //data.put('Have_You_Passed_NBCE_Exam__c', '' + par.Have_You_Passed_NBCE_Exam__c);
					//data.put( 'Have_You_Taken_ASBOG_Exam__c', '' + par.Have_You_Taken_ASBOG_Exam__c);
					data.put( 'Currently_Hold_Operator_License__c', '' + par.Currently_Hold_Operator_License__c);
					data.put( 'Amendment_Type__c', '' + par.Amendment_Type__c);
					appData.add(data);
				}
			}
		} catch (Exception e) {
			LPI_ExceptionManager.logException('LPI_ApplicationDataEntry', 'getApplicationInstructionsData', e);
		}
		return appData;
	}/*
    /**
	 * @author                      : Ambati Sukanya
	 * @since                       :
	 * @description                 : This method is used to resolve portal notifications and send emails
	 * @param action                : String
	 * @param args			        : Map<String, Object>
	 * @return                      : Object
	 * @last modified by            : Uzma Md
	 * @last modified date          :
	 * @modified details            :
	 */
    @AuraEnabled
    public static String sendEmailNotificationOnDocSubmission(String applicationId){
        try{
            if(String.isNotBlank(applicationId)){
                List<LPI_Wrapper.NotificationEmailWrapper> notificationEmailWrapperList = new List<LPI_Wrapper.NotificationEmailWrapper>();
                Map<String, Notification_Message__mdt> notificationMessageMap;
                List<Notification__c> listOfPortalNotification = new List<Notification__c>();
                Notification__c portalNotification;
                Map<String, String> replaceTextMap = new Map<String, String>();
                String fields = 'Id, Is_Resolved__c, Button_Label__c';
				String whereClause =
					'Individual_Application__c = ' +
					'\'' +
					String.escapeSingleQuotes(applicationId) +
					'\'' +
					' AND Navigate_Component_API_Name__c = ' +
					'\'' +
					REGISTRATION_FORM_NAVIGATION +
					'\'' + 
                    ' AND Is_Resolved__c = false';
					LPI_PortalNotificationDAO.LPI_PortalNotificationWithoutSharingDAO portalQueryDAO = new LPI_PortalNotificationDAO.LPI_PortalNotificationWithoutSharingDAO();
				List<Notification__c> portalRecList = portalQueryDAO.getPortalNotificationByDymanicQuery(
					fields,
					whereClause,
					null,
					'CreatedDate',
					'DESC'
				);
				if (!portalRecList.isEmpty()) {
                    List<Notification__c> updatePortalNotificationsList = new List<Notification__c>();
					for(Notification__c notiRec : portalRecList){
                        Notification__c portNotiRec = new Notification__c();
                        portNotiRec.Id = notiRec.Id;
                        portNotiRec.Is_Resolved__c = true;
                        updatePortalNotificationsList.add(portNotiRec);
                    }
                    if(!updatePortalNotificationsList.isEmpty()){
                        LPI_DML.doUpdate(updatePortalNotificationsList);
                    }
				}
                notificationMessageMap = LPI_TriggerServiceUtility.getMapOfNotificationByItsName(
					new Set<String>{FD_AFFIDAVIT_OF_WORK_METADATA}
				);
                List<Portal_Notification_Message__mdt> portalNotiRec = LPI_CustomMetadataTypeDAO.getAllPortalNotificationByDeveloperNames(new Set<String> {FD_AFFIDAVIT_OF_WORK_METADATA});
                fields = 'Id,OwnerId, Account.Name, LicenseType.Name, Name,License_Type_Name__c, Owner.Email,Account.PersonEmail,Board_Name__c';
                whereClause = 'Id = ' + '\'' + String.escapeSingleQuotes(applicationId) + '\'';
                LPI_IndividualApplicationDAO.LPI_DAO_IndividualApptWithoutSecurity indRef = new  LPI_IndividualApplicationDAO.LPI_DAO_IndividualApptWithoutSecurity();
				List<IndividualApplication> recList = indRef.getIndividualApplicationByDymanicQuery(
                    fields,
                    whereClause,
                    null,
                    null,
                    null
                );
				replaceTextMap = new Map<String, String>{
					'Applicant_Name' => recList[0].Account.Name,
					'license_Type' => recList[0].LicenseType.Name == 'Embalmer Apprentice' ? 'Embalmer' : 'Funeral Director'
				};
				//if owner of application is user
				if(recList[0].OwnerId.getsobjecttype() == Schema.User.getSObjectType())
				{
					LPI_Wrapper.NotificationEmailWrapper notifcationWrapper = new LPI_Wrapper.NotificationEmailWrapper();
					notifcationWrapper.accountId = recList[0].AccountId;
					notifcationWrapper.recipientEmail = recList[0].Owner.Email;
					notifcationWrapper.senderEmail = recList[0].Account.PersonEmail;
					notifcationWrapper.templateName = notificationMessageMap.get(FD_AFFIDAVIT_OF_WORK_METADATA).Template_Name__c;
					notifcationWrapper.replaceTextMap = replaceTextMap;
					notifcationWrapper.iaId = recList[0].Id;
					notificationEmailWrapperList.add(notifcationWrapper);

					//creating portal Notification 
					if(!portalNotiRec.isEmpty()){
						portalNotification = LPI_ServiceUtility.createBellNotificationRecord(portalNotiRec[0],
							true, new Map<String, String>{'[Application_Number]' => recList[0].Name}, recList[0].OwnerId, recList[0].Id);
						listOfPortalNotification.add(portalNotification);
					} 
				}
				//owner of application is queue
				else{
					//Storing userids in the queue
					Set<Id> userIdSet = new Set<Id>();
					for(GroupMember grpMem : LPI_GroupMemberDAO.getGroupMembersByGroupNames(new Set<String>{recList[0].Board_Name__c}))
					{
						String str = String.valueOf(grpMem.UserOrGroupId);
						if (str.startsWith('005')) {
							userIdSet.add(grpMem.UserOrGroupId);
						}
					}
					//sending notifications to the users in the queue
					if(!userIdSet.isEmpty())
					{
						for(User usr : new LPI_UserDao.LPI_UserWithoutSharingDAO().getUserByDymanicQuery(
							'Id, AccountId,Email',
							'Id IN '+ LPI_ServiceUtility.getStringValuesBySet(userIdSet),
							null,null,null))
						{
							LPI_Wrapper.NotificationEmailWrapper notifcationWrapper = new LPI_Wrapper.NotificationEmailWrapper();
							notifcationWrapper.accountId = recList[0].AccountId;
							notifcationWrapper.recipientEmail = usr.Email;
							notifcationWrapper.senderEmail = recList[0].Account.PersonEmail;
							notifcationWrapper.templateName = notificationMessageMap.get(FD_AFFIDAVIT_OF_WORK_METADATA).Template_Name__c;
							notifcationWrapper.replaceTextMap = replaceTextMap;
							notifcationWrapper.iaId = recList[0].Id;
							notificationEmailWrapperList.add(notifcationWrapper);

							//creating portal Notification 
							if(!portalNotiRec.isEmpty()){
								portalNotification = LPI_ServiceUtility.createBellNotificationRecord(portalNotiRec[0],
									true, new Map<String, String>{'[Application_Number]' => recList[0].Name}, usr.Id, recList[0].Id);
								listOfPortalNotification.add(portalNotification);
							} 
						}
					}
				}
				if (!notificationEmailWrapperList.isEmpty()) {
					LPI_ServiceUtility.createNotificationRecords(notificationEmailWrapperList);
				}
                if(!listOfPortalNotification.isEmpty()){
                    LPI_WithoutSharingUtility.insertSObjectRecord(listOfPortalNotification);
                }
                return 'Success';
            }
        }catch(Exception e){
            LPI_ExceptionManager.logException('LPI_ApplicationDataEntry', 'sendEmailNotificationOnDocSubmission', e);
        }
        return null;
    }
}