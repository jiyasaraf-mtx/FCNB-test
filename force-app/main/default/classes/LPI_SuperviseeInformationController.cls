/**
 * @description       : A Remote Class Used for Subordiante Controller Step
 * @author            : Kishore Reddy | 02-01-2023
 * @group             :
 * @last modified on  : 07-10-2024
 * @last modified by  : MTX Group Inc
 **/
global with sharing class LPI_SuperviseeInformationController implements Callable {

    // private final static String SUPERVISOR_PORTAL_NOTIFY = 'Supervisor_Approval_Notification';
    // private final static String NAVIGATE_TO_URL = 'Navigate to URL';
    // private final static String SUBMITTED_STATUS = 'Submitted';
    // private final static String PAR_OBJECT = 'PreliminaryApplicationRef';
    // private final static String EMAIL_KEY = 'RequestToSupevisor';
    // private final static String APPROVED_STATUS = 'Approved';
    // private final static String REJECTED_STATUS = 'Rejected';
    // private final static String REJECTED_REASON = 'rejectedReason';
    // private final static String STEPS_NAME_LIST = 'StepsObjApiMapToShare';
    // private final static String EDU_HISTORY_STEP = 'Education History';
    // private final static String LICENSURE_HIST_STEP = 'Licensure History';
    // private final static String PERSONAL_INFO_STEP = 'Personal Information';
    // private final static String PIC_NOTIFY_KEY = 'Person_In_Charge_Suprevision';
    // private final static String SEND_EMAIL_NOTIFICATION = 'sendEmailNotification';
    // private final static String LPI_SUPERVISEE_INFORMATION_CONTROLLER = 'LPI_SuperviseeInformationController';
    // private static String requestNoifyEmail = 'Notification_for_Request_to_Supevisor';
    // private final static String APPROVAL_NOTIFY_EMAIL = 'Supervisor_Approval_Request';
    // private final static String REJECT_NOTIFY_EMAIL = 'Supervisor_Rejected_Request';
    // private final static String RAGAUTH_NAME = 'regAuthTypeNamePcMft';
    // private final static String BOARD_EMAIL = 'boardEmail';
    // private final static String BOARD_PRO_BOX = 'boardPoBox';
    // private final static String MUL_SUPERVISOR_NOTIFY = 'Multiple_Supervisor_Request';
    // private static Boolean isStudentApproval = false;
    // private final static String SCHOOL_NOTIFY_KEY = 'School_Approval_Notification';
    // private final static String APP_REFERENCE_STEP = 'Applicant References';
    // private final static String APP_REFERENCE = 'Application Reference';
    // private final static String STUDENT_APPROVAL_NOTIFY_EMAIL = 'CosBar_Student_Request_School_Approved';
    // private final static String STUDENT_REJECT_NOTIFY_EMAIL = 'CosBar_Student_Request_School_Rejected';
    // private final static String PSYCHOLOGIST_SUPERVISOR_REJECT_NOTIFY_EMAIL = 'SCOP_Psychologist_Supervisor_Rejection';
    // private final static String MTS_SCHOOL_NOTIFY = 'MTS_School_Portal_Notification';
    // private final static String MTS_STUDENT_APPROVAL = 'mtsStudentApproval';
    // private final static String MTS_STUDENT_REVIEW_EMAIL = 'MTStudentReviewEmail';
    // private final static String MTS_STUDENT_APPROVE_EMAIL = 'MTStudentApprovalEmail';
    // private final static String MTS_STUDENT_REJECTED_EMAIL = 'MTStudentRejectionEmail';
    // private final static String HIS_TEMP_ATTESTATION_REQUEST = 'tempAttestationRequest'; //for S-62332
    // private final static String HIS_TEMP_BEHIS_ATTESTATION_NOTIFICATION = 'TempBEHISAttestationOfSupervisedExper';//for S-62332
    // private final static String HIS_TEMP_BEHIS_ATTESTATION_PORTAL_NOTIFICATION = 'AttestnPortalNotifiForSupervisorConsent';//for S-62332
    // private final static String PORTAL_USER_PRFL = 'Portal User';
    // private final static String USER_PROFILE = 'userProfile';
    // private final static String APPLICATION_TYPE_PORV_LICENSE_EXTENSION = 'Provisional License Extension';
    // private static Boolean IS_MTSTUDENT_APPLICATION = false;

    global Object call(String action, Map<String, Object> args) {
        Map<String, Object> input = (Map<String, Object>) args.get('input');
        Map<String, Object> output = (Map<String, Object>) args.get('output');
        Map<String, Object> options = (Map<String, Object>) args.get('options');
        return invokeMethod(action, input, output, options);
    }
    // /**
    //  * @author                      : Kishore
    //  * @since                       : 02-01-2023
    //  * @description                 : This method will compare method from Omniscript and execute only that specific method
    //  * @param inputMap		        : Map<String, Object> input map from OS
    //  * @param outMap 		        : Map<String, Object>
    //  * @param options 		        : Map<String, Object>
    //  * @return                      : Boolean
    //  * @last modified by            : Ayush Dev
    //  * @last modified date          :
    //  * @modified details            :
    //  */
    private Boolean invokeMethod(
        String methodName,
        Map<String, Object> inputMap,
        Map<String, Object> outMap,
        Map<String, Object> options
    ) {
        // Boolean result = false;
        // try {
        //     if (methodName == 'submitApprovalRequest') {
        //         return submitApprovalRequest(inputMap, outMap, options);
        //     } else if (methodName == 'fetchSupervisorApprovalDetails') {
        //         fetchSupervisorApprovalDetails(inputMap, outMap, options);
        //     } else if (methodName == 'updateSupervisorApprovalStatus') {
        //         inputMap.put('isSingleSupervisor', true);
        //         return updateSupervisorApprovalStatus(inputMap, outMap);
        //     } else if (methodName == 'findCurrentUser') {
        //         findCurrentUser(inputMap, outMap);
        //     }
        // } catch (Exception e) {
        //     result = false;
        //     LPI_ExceptionManager.logException(
        //         LPI_SUPERVISEE_INFORMATION_CONTROLLER,
        //         'invokeMethod',
        //         e
        //     );
        // }
        // return result;
        return null;
    }
    // /**
    //  * @author                      : Kishore
    //  * @since                       : 1st Map, 2023
    //  * @description                 : This method  is to used to create new ACR between Applicant and Supervisor
    //  * @story Number				: S-48340
    //  * @param recordsList           : Takes inputmap , outmap , options as map<String,String> from OS.
    //  * @return                      : `void`
    //  * @last modified by            : Ayush Dev
    //  * @last modified date          : (Add if modified by you)
    //  * @modified details            : (Add if modified by you)
    //  */
    // private static Boolean submitApprovalRequest(
    //     Map<String, Object> inputMap,
    //     Map<String, Object> outMap,
    //     Map<String, Object> options
    // ) {
    //     Boolean isSuccess = false;
    //     try {
    //         String parId = inputMap.containsKey('parId')
    //             ? (String) inputMap.get('parId')
    //             : null;
    //         String type = inputMap.containsKey('type')
    //             ? (String) inputMap.get('type')
    //             : null;
    //         if (parId != null) {
    //             inputMap.put('isSingleSupervisor', true);
    //             inputMap.put('isForSupervisorApproval', true);
    //             List<PreliminaryApplicationRef> parList;
    //             if(type == APPLICATION_TYPE_PORV_LICENSE_EXTENSION){
    //                 String fields =
    //                     'Id , Regulatory_Authorization_Type__r.Name,  BusinessAccountName.PersonEmail, Contact__c ,Contact__r.AccountId , Business_License__c, ' +
    //                     ' BusinessAccountNameId ,Approval_Supervisors_AcrIds__c, Board_Name__c, BusinessAccountName.Name,Supervisor_ACR_Id__c,' +
    //                     'Regulatory_Authorization_Type__c,SavedApplicationUrl,Regulatory_Authorization_Type__r.Email_Specifications_Final__c ,  Supervisor_Approval_Status__c ';
    //                 String whereClause =
    //                     ' Id =\'' +
    //                     String.escapeSingleQuotes(parId) +
    //                     '\'';
    //                 // fetching ContactId From PAR Object for Both support staff and portal user
    //                 parList = LPI_PreliminaryApplicationRefDAO.getPreliminaryApplicationRefByDymanicQuery(
    //                     fields,
    //                     whereClause,
    //                     '1',
    //                     null,
    //                     null
    //                 );
    //                 Boolean isInternalUser = inputMap.containsKey(USER_PROFILE) && (String) inputMap.get(USER_PROFILE) != PORTAL_USER_PRFL ? true : false;
    //                 if (isInternalUser) {
    //                     parList[0].Supervisor_Approval_Status__c = APPROVED_STATUS;
    //                     LPI_DML.doUpdate(parList[0]);

    //                     List<Business_Relationships__c> brUpdateList = new List<Business_Relationships__c>();
    //                     if(String.isNotBlank(parList[0].Approval_Supervisors_AcrIds__c)){
    //                         for (String brId : parList[0].Approval_Supervisors_AcrIds__c.split(',')) {
    //                             Business_Relationships__c br = new Business_Relationships__c();
    //                             br.Id = brId;
    //                             br.Supervisor_Approval_Status__c = APPROVED_STATUS;
    //                             brUpdateList.add(br);
    //                         }
    //                     }
    //                     if(!brUpdateList.isEmpty()){
    //                         LPI_WithoutSharingUtility.updateSObjectList(brUpdateList);
    //                     }
    //                 }
    //             }
    //             if(
    //                 type != APPLICATION_TYPE_PORV_LICENSE_EXTENSION ||
    //                 (
    //                     type == APPLICATION_TYPE_PORV_LICENSE_EXTENSION &&
    //                     !parList.isEmpty() &&
    //                     parList[0].Supervisor_Approval_Status__c == REJECTED_STATUS
    //                 )
    //             ){
    //                 //Calling MODPR_ApplicantSupervisorController to Save the Supervisor Information
    //                 parList = LPI_ApplicantSupervisorController.savePrimarySupervisorDetails(
    //                     inputMap
    //                 );
    //             }
    //             //Creating Notification on Supervisor Request
    //             if (!parList.isEmpty()) {
    //                 if (
    //                     inputMap.containsKey(USER_PROFILE) &&
    //                     (String) inputMap.get(USER_PROFILE) == PORTAL_USER_PRFL
    //                 ) {
    //                     isSuccess = createNotificationOnSubmission(
    //                         parList,
    //                         inputMap
    //                     );
    //                     outMap.put('isRequestSubmitedApproved', isSuccess);
    //                 } else {
    //                     outMap.put('isRequestSubmitedApproved', true);
    //                 }
    //             }
    //         }
    //     } catch (Exception e) {
    //         LPI_ExceptionManager.logException(
    //             LPI_SUPERVISEE_INFORMATION_CONTROLLER,
    //             'submitApprovalRequest',
    //             e
    //         );
    //     }
    //     return isSuccess;
    // }

    // /**
    //  * @author                      : Kishore
    //  * @since                       : 1st Map, 2023
    //  * @description                 : This method  is to used to create email and Portal Notification
    //  * @story Number				: S-48340
    //  * @param recordsList           : Takes List of Certification records
    //  * @return                      : `void`
    //  * @last modified by            : Ayush Dev
    //  * @last modified date          : (Add if modified by you)
    //  * @modified details            : (Add if modified by you)
    //  */
    // public static Boolean createNotificationOnSubmission(
    //     List<PreliminaryApplicationRef> parList,
    //     Map<String, Object> inputMap
    // ) {
    //     try {
    //         // Check if the parList list is not empty
    //         if (parList.isEmpty()) {
    //             return false;
    //         }
    //         String parId = (String) parList[0].Id;
    //         isStudentApproval = inputMap.containsKey('isStudentApproval')
    //             ? (Boolean) inputMap.get('isStudentApproval')
    //             : false;
    //         // Initialize necessary variables
    //         List<Notification__c> portalNotificationToInsert = new List<Notification__c>();
    //         Map<String, String> urlParameter = new Map<String, String>();
    //         List<PreliminaryApplicationRef> updateParList = new List<PreliminaryApplicationRef>();
    //         String acrId = '';
    //         // Initialize necessary variables
    //         List<LPI_Wrapper.NotificationEmailWrapper> notificationEmailWrapperList = new List<LPI_Wrapper.NotificationEmailWrapper>();
    //         Map<String, String> replaceTextMap = new Map<String, String>();
    //         if(inputMap.containsKey('mtStudentFlow') && (Boolean) inputMap.get('mtStudentFlow')){
    //             IS_MTSTUDENT_APPLICATION = true;
    //         }
    //         //Fetch Supervisor UserId to share PAR record with supervisor.
    //         Map<String, Object> strObjMap = fetchSupervisorUserDetails(
    //             parId,
    //             false,
    //             inputMap.containsKey('isSingleSupervisor')
    //         );
    //         List<User> usersList = strObjMap.containsKey('supervisorUserList')
    //             ? (List<User>) strObjMap.get('supervisorUserList')
    //             : new List<User>();
    //         Set<Id> brIdSet = strObjMap.containsKey('brIdSet')
    //             ? (Set<Id>) strObjMap.get('brIdSet')
    //             : new Set<Id>();
    //         List<Business_Relationships__c> businessRelationList = strObjMap.containsKey(
    //                 'businessRelationList'
    //             )
    //             ? (List<Business_Relationships__c>) strObjMap.get(
    //                   'businessRelationList'
    //               )
    //             : new List<Business_Relationships__c>();
    //         // Loop through each PreliminaryApplicationRef record
    //         PreliminaryApplicationRef par = parList[0];
    //         // Check if the regulatory authorization type is not null
    //         if (
    //             par.Regulatory_Authorization_Type__c != null &&
    //             par.BusinessAccountNameId != null
    //         ) {
    //             if (
    //                 parList[0]
    //                     .Regulatory_Authorization_Type__r.Email_Specifications_Final__c !=
    //                 null
    //             ) {
    //                 Map<String, Object> boardSignatureMap = (Map<String, Object>) JSON.deserializeUntyped(
    //                     String.valueOf(
    //                         parList[0]
    //                             .Regulatory_Authorization_Type__r.Email_Specifications_Final__c
    //                     )
    //                 );
    //                 replaceTextMap.put(
    //                     'Board_Email_MODPR',
    //                     String.isNotBlank(
    //                             (String) boardSignatureMap.get(BOARD_EMAIL)
    //                         )
    //                         ? (String) boardSignatureMap.get(BOARD_EMAIL)
    //                         : ''
    //                 );
    //                 replaceTextMap.put(
    //                     'Board_PO_box',
    //                     String.isNotBlank(
    //                             (String) boardSignatureMap.get(BOARD_PRO_BOX)
    //                         )
    //                         ? (String) boardSignatureMap.get(BOARD_PRO_BOX)
    //                         : ''
    //                 );
    //                 replaceTextMap.put(
    //                     'Board_Name',
    //                     String.isNotBlank(
    //                             (String) boardSignatureMap.get('boardName')
    //                         )
    //                         ? (String) boardSignatureMap.get('boardName')
    //                         : ''
    //                 );
    //             }

    //             // Setting Up replaceMap and Urlparameter for notifications
    //             if (
    //                 inputMap.containsKey(MTS_STUDENT_APPROVAL) &&
    //                 inputMap.containsKey('EmailName')
    //             ) {
    //                 replaceTextMap.put(
    //                     'School_Name',
    //                     (String) inputMap.get('EmailName')
    //                 );
    //                 replaceTextMap.put(
    //                     'Student_Name',
    //                     par.BusinessAccountName.Name
    //                 );
    //             }
    //             replaceTextMap.put(
    //                 'License_Type',
    //                 par.Regulatory_Authorization_Type__r.Name
    //             );
    //             replaceTextMap.put(
    //                 'Applicant_Name',
    //                 par.BusinessAccountName.Name
    //             );
    //             urlParameter.put('parId', String.valueOf(parId));
    //             urlParameter.put(
    //                 'ratName',
    //                 par.Regulatory_Authorization_Type__r.Name
    //             );
    //             urlParameter.put('type', NAVIGATE_TO_URL);
    //         }
    //         //Send portal notification to Supervisor by fetching the Account of supervisor from newly Created ACR.
    //         if (!usersList.isEmpty()) {
    //             // Fetch the notification metadata record
    //             Map<String, Notification_Message__mdt> notificationMessageMap = new Map<String, Notification_Message__mdt>();
    //             if (inputMap.containsKey(MTS_STUDENT_APPROVAL)) {
    //                 notificationMessageMap = LPI_TriggerServiceUtility.getMapOfNotificationByItsName(
    //                     new Set<String>{ MTS_STUDENT_REVIEW_EMAIL }
    //                 );
    //             }else if(inputMap.containsKey(HIS_TEMP_ATTESTATION_REQUEST)){//for S-62332
    //                 notificationMessageMap = LPI_TriggerServiceUtility.getMapOfNotificationByItsName(
    //                     new Set<String>{ HIS_TEMP_BEHIS_ATTESTATION_NOTIFICATION }
    //                 );
    //             } else {
    //                 notificationMessageMap = LPI_TriggerServiceUtility.getMapOfNotificationByItsName(
    //                     new Set<String>{ requestNoifyEmail }
    //                 );
    //             }
    //             for (
    //                 Business_Relationships__c brRecord : businessRelationList
    //             ) {
    //                 //Creating a Email Notification record.
    //                 if (
    //                     String.isNotBlank(
    //                         brRecord.Related_From__r.PersonEmail
    //                     ) ||
    //                     String.isNotBlank(brRecord.Related_To__r.PersonEmail)
    //                 ) {
    //                     // Create a notification record
    //                     LPI_Wrapper.NotificationEmailWrapper notifcationWrapper = new LPI_Wrapper.NotificationEmailWrapper();

    //                     if (isStudentApproval) {
    //                         notifcationWrapper.accountId = brRecord.Related_To__c;
    //                         notifcationWrapper.recipientEmail = brRecord.Related_To__r.PersonEmail;
    //                     } else {
    //                         notifcationWrapper.accountId = brRecord.Related_From__c;
    //                         notifcationWrapper.recipientEmail = brRecord.Related_From__r.PersonEmail;
    //                     }
    //                     if (inputMap.containsKey(MTS_STUDENT_APPROVAL)) {
    //                         replaceTextMap.put(
    //                             'Application_Link',
    //                             String.valueOf(par.SavedApplicationUrl) +
    //                             '&c__acrId=' +
    //                             String.valueOf(brRecord.Id)
    //                         );
    //                         if (
    //                             notificationMessageMap.containsKey(
    //                                 MTS_STUDENT_REVIEW_EMAIL
    //                             )
    //                         ) {
    //                             notifcationWrapper.templateName = notificationMessageMap.get(
    //                                     MTS_STUDENT_REVIEW_EMAIL
    //                                 )
    //                                 .Template_Name__c;
    //                         }
    //                     } else {
    //                         replaceTextMap.put(
    //                             'Portal_Link',
    //                             String.valueOf(par.SavedApplicationUrl) +
    //                             '&c__acrId=' +
    //                             String.valueOf(brRecord.Id) +
    //                             'License_Number'+
    //                             String.valueOf(brRecord.Related_To_License_Number__r.Name)//for S-62332
    //                         );
    //                         if (inputMap.containsKey('proofOfSupervision')) {
    //                             replaceTextMap.put(
    //                                 'Role_Name',
    //                                 'Person In Charge'
    //                             );
    //                         }
    //                         else{
    //                             replaceTextMap.put(
    //                                 'Role_Name',
    //                                 'Supervisor'
    //                             );
    //                         }
    //                         /*for S-62332 start*/
    //                         if (inputMap.containsKey(HIS_TEMP_ATTESTATION_REQUEST)) {
                            
    //                             if (
    //                                 notificationMessageMap.containsKey(
    //                                     HIS_TEMP_BEHIS_ATTESTATION_NOTIFICATION
    //                                 )
    //                             ) {
    //                                 notifcationWrapper.templateName = notificationMessageMap.get(
    //                                     HIS_TEMP_BEHIS_ATTESTATION_NOTIFICATION
    //                                     )
    //                                     .Template_Name__c;
    //                             }
    //                         }
    //                         if(!inputMap.containsKey(MTS_STUDENT_APPROVAL) && !inputMap.containsKey(HIS_TEMP_ATTESTATION_REQUEST)){ /*//for S-62332 end*/                          
    //                             notifcationWrapper.templateName = notificationMessageMap.get(
    //                                 requestNoifyEmail
    //                             )
    //                             .Template_Name__c;
    //                         }//for S-62332
    //                     }

    //                     notifcationWrapper.replaceTextMap = replaceTextMap;
    //                     notificationEmailWrapperList.add(notifcationWrapper);
    //                 }
    //             }
    //             // Check if there are notifications to insert
    //             if (!notificationEmailWrapperList.isEmpty()) {
    //                 LPI_ServiceUtility.createNotificationRecords(
    //                     notificationEmailWrapperList
    //                 );
    //             }
    //             List<Portal_Notification_Message__mdt> notiRec;
    //             if (inputMap.containsKey('proofOfSupervision')) {
    //                 notiRec = LPI_CustomMetadataTypeDAO.getAllPortalNotificationByDeveloperName(
    //                     PIC_NOTIFY_KEY
    //                 );
    //             } else if (isStudentApproval && !inputMap.containsKey(MTS_STUDENT_APPROVAL)) {
    //                 notiRec = LPI_CustomMetadataTypeDAO.getAllPortalNotificationByDeveloperName(
    //                     SCHOOL_NOTIFY_KEY
    //                 );
    //             }else if (inputMap.containsKey(MTS_STUDENT_APPROVAL)) {
    //                 notiRec = LPI_CustomMetadataTypeDAO.getAllPortalNotificationByDeveloperName(
    //                     MTS_SCHOOL_NOTIFY
    //                 );
    //             }else if(inputMap.containsKey(HIS_TEMP_ATTESTATION_REQUEST)){//for S-62332
    //                 notiRec = LPI_CustomMetadataTypeDAO.getAllPortalNotificationByDeveloperName(
    //                     HIS_TEMP_BEHIS_ATTESTATION_PORTAL_NOTIFICATION
    //                 );
    //             } else {
    //                 notiRec = LPI_CustomMetadataTypeDAO.getAllPortalNotificationByDeveloperName(
    //                     SUPERVISOR_PORTAL_NOTIFY
    //                 );
    //             }
    //             //Creating a Portal Notification record.
    //             for (
    //                 Business_Relationships__c brRecord : businessRelationList
    //             ) {
    //                 if (
    //                     brRecord.Related_From__c != null &&
    //                     brRecord.Related_To__c != null
    //                 ) {
    //                     String accountId;
    //                     if (isStudentApproval) {
    //                         accountId = brRecord.Related_To__c;
    //                     } else {
    //                         accountId = brRecord.Related_From__c;
    //                     }
    //                     urlParameter.put('acrId', brRecord.Id);
    //                     String parRecordId = brRecord.Id + '-' + parId;
    //                     Notification__c notification = LPI_ServiceUtility.createPortalNotificationRecord(
    //                         notiRec[0],
    //                         true,
    //                         replaceTextMap,
    //                         urlParameter,
    //                         accountId
    //                     );
    //                     notification.Record_Id__c = parRecordId;
    //                     notification.type__c = NAVIGATE_TO_URL;
    //                     portalNotificationToInsert.add(notification);
    //                 }
    //             }
    //         }
    //         // Check if there are portal notifications to insert
    //         if (!portalNotificationToInsert.isEmpty()) {
    //             //Update the PAR approval status to Submitted on sending notifications.
    //             PreliminaryApplicationRef newPar = new PreliminaryApplicationRef();
    //             newPar.Id = parId;
    //             newPar.Supervisor_Approval_Status__c = SUBMITTED_STATUS;
    //             updateParList.add(newPar);
    //             //Share the par record with Supervisor
    //             List<Sharing_Ledger__c> insertSharingLedgerList = new List<Sharing_Ledger__c>();
    //             if (!usersList.isEmpty()) {
    //                 List<String> stepsName;
    //                 //Fetching the step names for which we created Sharing records.
    //                 if (inputMap.containsKey(STEPS_NAME_LIST)) {
    //                     stepsName = String.valueOf(
    //                             inputMap.get(STEPS_NAME_LIST)
    //                         )
    //                         .split(',');
    //                 }
    //                 Map<String, Object> returnMap = getNewRecordsToShare(
    //                     parList,
    //                     usersList,
    //                     stepsName,
    //                     false
    //                 );
    //                 System.debug('returnMap ==>'+returnMap);
    //                 insertSharingLedgerList.addAll(
    //                     returnMap.containsKey('insertSharingLedgerList')
    //                         ? (List<Sharing_Ledger__c>) returnMap.get(
    //                               'insertSharingLedgerList'
    //                           )
    //                         : new List<Sharing_Ledger__c>()
    //                 );
    //             }
    //             //Insert Sharing_Ledger__c Records.
    //             if (!insertSharingLedgerList.isEmpty()) {
    //                 LPI_DML.doInsert(insertSharingLedgerList);
    //             }
    //             //Update par Supervisor Approval Status
    //             if (!updateParList.isEmpty()) {
    //                 LPI_DML.doUpdate(updateParList);
    //             }
    //             LPI_WithoutSharingUtility.insertSObjectList(
    //                 portalNotificationToInsert
    //             );
    //             List<Business_Relationships__c> updateBrList = new List<Business_Relationships__c>();
    //             //if(!isStudentApproval){
    //                 if (par.Approval_Supervisors_AcrIds__c != null) {
    //                     for (Id recId : brIdSet) {
    //                         Business_Relationships__c newBrRecord = new Business_Relationships__c(
    //                             Id = recId
    //                         );
    //                         newBrRecord.Supervisor_Approval_Status__c = SUBMITTED_STATUS;
    //                         updateBrList.add(newBrRecord);
    //                     }
    //                 }
    //             //}
    //             if (!updateBrList.isEmpty()) {
    //                 LPI_WithoutSharingUtility.updateSObjectList(updateBrList);
    //             }
    //             return true;
    //         }
    //     } catch (Exception ex) {
    //         // Log the Exception
    //         LPI_ExceptionManager.logException(
    //             LPI_SUPERVISEE_INFORMATION_CONTROLLER,
    //             'createNotificationOnSubmission',
    //             ex
    //         );
    //     }
    //     return false;
    // }
    // /**
    //  * @author                      : Kishore
    //  * @since                       : 1st Map, 2023
    //  * @description                 : This method  is to fetch supervisor ACR details
    //  * @story Number				: S-48340
    //  * @return                      : `void`
    //  * @last modified by            : Ayush Dev
    //  * @last modified date          : (Add if modified by you)
    //  * @modified details            : (Add if modified by you)
    //  */

    // public static void fetchSupervisorApprovalDetails(
    //     Map<String, Object> inputMap,
    //     Map<String, Object> outMap,
    //     Map<String, Object> options
    // ) {
    //     Id parId;
    //     List<Business_Relationships__c> businessRelationList = new List<Business_Relationships__c>();
    //     String supervisorAcrId;
    //     try {
    //         if (inputMap.containsKey('parId')) {
    //             parId = (Id) inputMap.get('parId');
    //             List<PreliminaryApplicationRef> parList;
    //             if (parId != null) {
    //                 String fields = ' Id, Approval_Supervisors_AcrIds__c, Supervisor_Approval_Response__c , Employee_Information_ACR_Ids__c';
    //                 String whereClause =
    //                     'Id= \'' +
    //                     String.escapeSingleQuotes(parId) +
    //                     '\'';
    //                 parList = LPI_PreliminaryApplicationRefDAO.getPreliminaryApplicationRefByDymanicQuery(
    //                     fields,
    //                     whereClause,
    //                     null,
    //                     null,
    //                     null
    //                 );
    //             }
    //             isStudentApproval = inputMap.containsKey('isStudentApproval');
    //             if (
    //                 !parList.isEmpty() &&
    //                 parList[0].Approval_Supervisors_AcrIds__c != null
    //             ) {
    //                 supervisorAcrId = isStudentApproval
    //                     ? parList[0].Employee_Information_ACR_Ids__c!=null
    //                     ? (String) parList[0].Employee_Information_ACR_Ids__c : null 
    //                     : (String) parList[0].Approval_Supervisors_AcrIds__c;
    //                 String responseJson = parList[0]
    //                     .Supervisor_Approval_Response__c;
    //                 if (!String.isBlank(responseJson)) {
    //                     Map<String, Object> deserializedMap = (Map<String, Object>) JSON.deserializeUntyped(
    //                         responseJson
    //                     );
    //                     outMap.put('SupervisorApproval', deserializedMap);
    //                 }
    //                 outMap.put('supervisorAcrId', supervisorAcrId);
    //                 String acrFields = 'Id , Supervisor_Approval_Status__c , Rejection_reason__c ';
    //                 String whereCaluse =
    //                     'Id= \'' +
    //                     String.escapeSingleQuotes(supervisorAcrId) +
    //                     '\'';
    //                 LPI_BusinessRelationshipDAO.LPI_BusinessRelationshipsWithoutSharingDAO withoutSharingQuery = new LPI_BusinessRelationshipDAO.LPI_BusinessRelationshipsWithoutSharingDAO();
    //                 businessRelationList = withoutSharingQuery.getBusinessRelationshipsByDymanicQuery(
    //                     acrFields,
    //                     whereCaluse,
    //                     null,
    //                     null,
    //                     null
    //                 );

    //                 if (
    //                     !businessRelationList.isEmpty() &&
    //                     businessRelationList[0].Supervisor_Approval_Status__c !=
    //                     null
    //                 ) {
    //                     String businessRelationStatus = businessRelationList[0]
    //                         .Supervisor_Approval_Status__c;
    //                     if (businessRelationStatus == APPROVED_STATUS) {
    //                         outMap.put('ApproveSuperviseApplicant', 'Yes');
    //                     } else if (businessRelationStatus == REJECTED_STATUS) {
    //                         outMap.put('ApproveSuperviseApplicant', 'No');
    //                         outMap.put(
    //                             'RejectionReason',
    //                             String.valueOf(
    //                                 businessRelationList[0].Rejection_reason__c
    //                             )
    //                         );
    //                     }
    //                 }
    //             }
    //         }
    //     } catch (Exception e) {
    //         LPI_ExceptionManager.logException(
    //             LPI_SUPERVISEE_INFORMATION_CONTROLLER,
    //             'fetchSupervisorApprovalDetails',
    //             e
    //         );
    //     }
    // }

    // /**
    //  * @author                      : Kishore
    //  * @since                       : 1st Map, 2023
    //  * @description                 : This method is to update supervisor ACR details and send Email notifications
    //  * @story Number				: S-48340
    //  * @return                      : `void`
    //  * @last modified by            : Ayush Dev
    //  * @last modified date          : (Add if modified by you)
    //  * @modified details            : (Add if modified by you)
    //  */

    // public static Boolean updateSupervisorApprovalStatus(
    //     Map<String, Object> inputMap,
    //     Map<String, Object> outMap
    // ) {
    //     List<User> userList = LPI_UserDao.getCurrentUserRecord();
    //     Id parId;
    //     String supervisorAcrId;
    //     String rejectionReason = '';
    //     try {
    //         if (
    //             inputMap.containsKey('parId') &&
    //             inputMap.containsKey('supervisorAcrId') &&
    //             !userList.isEmpty()
    //         ) {
    //             isStudentApproval = inputMap.containsKey('isStudentApproval');
    //             parId = (Id) inputMap.get('parId');
    //             List<PreliminaryApplicationRef> parList;
    //             if (parId != null) {
    //                 String fields =
    //                     ' Id, BusinessAccountNameId , Approval_Supervisors_AcrIds__c , Contact__c , Supervisor_Approval_Response__c , Supervisor_Approval_Status__c , Board_Name__c ,' +
    //                     'Regulatory_Authorization_Type__c, Regulatory_Authorization_Type__r.Name  , BusinessAccountName.Name, BusinessAccountName.PersonEmail ,' +
    //                     ' SavedApplicationUrl , Regulatory_Authorization_Type__r.Email_Specifications_Final__c , Employee_Information_ACR_Ids__c,Business_Name__c, Type__c';
    //                 String whereClause =
    //                     'Id= \'' +
    //                     String.escapeSingleQuotes(parId) +
    //                     '\'';
    //                 parList = LPI_PreliminaryApplicationRefDAO.getPreliminaryApplicationRefByDymanicQuery(
    //                     fields,
    //                     whereClause,
    //                     null,
    //                     null,
    //                     null
    //                 );
    //             }

    //             supervisorAcrId = (String) inputMap.get('supervisorAcrId');
    //             if (!parList.isEmpty() && String.isNotBlank(supervisorAcrId)) {
    //                 Business_Relationships__c newBusinessRelationRecord = new Business_Relationships__c(
    //                     Id = supervisorAcrId
    //                 );
    //                 PreliminaryApplicationRef updatePar = new PreliminaryApplicationRef(
    //                     Id = parId
    //                 );
    //                 String acrStatus;
    //                 if (inputMap.containsKey('status')) {
    //                     acrStatus = (String) inputMap.get('status');
    //                     newBusinessRelationRecord.Supervisor_Approval_Status__c = acrStatus;
    //                 }
    //                 if (inputMap.containsKey(REJECTED_REASON)) {
    //                     rejectionReason = (String) inputMap.get(
    //                         REJECTED_REASON
    //                     );
    //                     newBusinessRelationRecord.Rejection_reason__c = rejectionReason;
    //                 }
    //                 List<String> stepsName;
    //                 //Fetching the step names for which we created Sharing records.
    //                 if (inputMap.containsKey(STEPS_NAME_LIST)) {
    //                     stepsName = String.valueOf(
    //                             inputMap.get(STEPS_NAME_LIST)
    //                         )
    //                         .split(',');
    //                 }
    //                 String supervisorsIdsStr;
    //                 Map<String, Object> newSerializeMap = new Map<String, Object>();
    //                 List<String> supervisorAcrIdsList = LPI_SupervisorSharingUtility.getSupervisorAcrIds(
    //                     parList
    //                 );
    //                 if (acrStatus == REJECTED_STATUS) {
    //                     for (String id : supervisorAcrIdsList) {
    //                         if (id != supervisorAcrId) {
    //                             supervisorsIdsStr = String.isNotBlank(
    //                                     supervisorsIdsStr
    //                                 )
    //                                 ? supervisorsIdsStr + id + ','
    //                                 : id + ',';
    //                         }
    //                     }
    //                     if (isStudentApproval) {
    //                         updatePar.Supervisor_Approval_Status__c = null;
    //                     } 
    //                     //else {
    //                         if (
    //                             String.isBlank(supervisorsIdsStr) ||
    //                             supervisorsIdsStr == null
    //                         ) {
    //                             updatePar.Supervisor_Approval_Status__c = REJECTED_STATUS;
    //                         }
    //                         updatePar.Approval_Supervisors_AcrIds__c = supervisorsIdsStr;
    //                     //}
    //                     updatePar.Supervisor_Approval_Response__c = null;
    //                 } else {
    //                     //Start - Added by Adarsh Singh - S-47553 - For saving Supervision Details
    //                     if (
    //                         inputMap.containsKey('stepJson') &&
    //                         inputMap.containsKey('isRATSCOP') 
    //                     ) {
    //                         Map<String, Object> stepDataJson = (Map<String, Object>) inputMap.get(
    //                             'stepJson'
    //                         );
    //                         if(inputMap.containsKey('attestationDate')){
    //                             stepDataJson.put('AttDate',(String)inputMap.get('attestationDate'));
    //                         }
    //                         if(inputMap.containsKey('attestationSign')){
    //                             stepDataJson.put('AttSignature',(String)inputMap.get('attestationSign'));
    //                         }
    //                         updatePar.Supervisor_Approval_Response__c = JSON.serialize(
    //                             stepDataJson
    //                         );

    //                     }
    //                     //End - Added by Adarsh Singh - S-47553 - For saving Supervision Details
    //                     if (
    //                         inputMap.containsKey('isSingleSupervisor') &&
    //                         Boolean.valueOf(inputMap.get('isSingleSupervisor'))
    //                     ) {
    //                         updatePar.Supervisor_Approval_Status__c = APPROVED_STATUS;
    //                     }
    //                     if (isStudentApproval) {
    //                         updatePar.Supervisor_Approval_Status__c = APPROVED_STATUS;
    //                     }
    //                 }
    //                 if (updatePar != null && supervisorAcrId != null) {
    //                     //this method will send the approval/rejection mail to the applicant based on the status.
    //                     String acrFields = 'Id , Supervisor_Approval_Status__c, IsActive__c ';
    //                     String acrWhere =
    //                         'Id = \'' +
    //                         String.escapeSingleQuotes(supervisorAcrId) +
    //                         '\'';
    //                     List<Business_Relationships__c> brListToDelete = new List<Business_Relationships__c>();
    //                     List<Business_Relationships__c> brListToUpdate = new List<Business_Relationships__c>(); //Will close relationships, if the relation is already active and the Supervisor Rejects the relation.
    //                     LPI_BusinessRelationshipDAO.LPI_BusinessRelationshipsWithoutSharingDAO withoutSharingQuery = new LPI_BusinessRelationshipDAO.LPI_BusinessRelationshipsWithoutSharingDAO();
    //                     for (
    //                         Business_Relationships__c brRecord : withoutSharingQuery.getBusinessRelationshipsByDymanicQuery(
    //                             acrFields,
    //                             acrWhere,
    //                             '1',
    //                             null,
    //                             null
    //                         )
    //                     ) {
    //                         if (
    //                             brRecord.Supervisor_Approval_Status__c !=
    //                             acrStatus
    //                         ) {
    //                             sendEmailNotification(
    //                                 parId,
    //                                 acrStatus,
    //                                 rejectionReason,
    //                                 userList,
    //                                 parList,
    //                                 inputMap
    //                             );
    //                         }
    //                         if(!brRecord.IsActive__c){
    //                             brListToDelete.add(brRecord);
    //                         }else{
    //                             brRecord.IsActive__c = false;
    //                             brRecord.EndDate__c = Date.today();
    //                             brListToUpdate.add(brRecord);
    //                         }
    //                     }
    //                     //Updating ACR based on Supervisor Response.
    //                     if (acrStatus == REJECTED_STATUS && !isStudentApproval) {
    //                         //Deleting Inactive relationships, when rejected
    //                         if(!brListToDelete.isEmpty()){
    //                             LPI_WithoutSharingUtility.deleteSObject(
    //                                 brListToDelete
    //                             );
    //                         }
    //                         //Updating active relationships to Inactive, when rejected
    //                         if(!brListToUpdate.isEmpty()){
    //                             LPI_WithoutSharingUtility.updateSObjectList(
    //                                 brListToUpdate
    //                             );
    //                         }
    //                     } else {
    //                         LPI_WithoutSharingUtility.upsertSObject(
    //                             newBusinessRelationRecord
    //                         );
    //                     }
    //                     LPI_DML.doUpdate(updatePar);
    //                     //Delete the shared records to Supervisor
    //                     Boolean isDeleteSuccess = false;
    //                     if (
    //                         !isStudentApproval ||
    //                         (isStudentApproval &&
    //                         updatePar.Supervisor_Approval_Status__c !=
    //                         APPROVED_STATUS)
    //                     ) {
    //                         isDeleteSuccess = deleteSharedRecords(
    //                             parList,
    //                             stepsName,
    //                             true,
    //                             userList
    //                         );
    //                     }
    //                     if (
    //                         isDeleteSuccess ||
    //                         (isStudentApproval &&
    //                         updatePar.Supervisor_Approval_Status__c !=
    //                         APPROVED_STATUS)
    //                     ) {
    //                         //Deleting Portal Notification
    //                         List<Notification__c> portalRecToDeleteList = new List<Notification__c>();
    //                         if (isStudentApproval) {
    //                             String urlRecordId = inputMap.containsKey('urlRecordId') ? (String) inputMap.get('urlRecordId') + '-' + parId : null;
    //                             if(urlRecordId!=null){
    //                                 portalRecToDeleteList = deletePoratalNotification(
    //                                     new List<String>{urlRecordId}
    //                                 );
    //                             }
    //                         } else {
    //                             portalRecToDeleteList = deletePoratalNotification(
    //                                 new List<String>{
    //                                     supervisorAcrId +
    //                                     '-' +
    //                                     parId
    //                                 }
    //                             );
    //                         }
    //                         if (!portalRecToDeleteList.isEmpty()) {
    //                             LPI_WithoutSharingUtility.updateSObjectList(
    //                                 portalRecToDeleteList
    //                             );
    //                         }
    //                         outMap.put('isUpdateSuccess', true);
    //                         if (
    //                             LPI_SupervisorSharingUtility.checkForSupervisorResponse(
    //                                 parId
    //                             ) != 'Pending'
    //                         ) {
    //                             LPI_SupervisorSharingUtility.deleteSaveAndExitInstance(
    //                                 parId
    //                             );
    //                         }
    //                         return true;
    //                     }
    //                 }
    //             }
    //         }
    //     } catch (Exception e) {
    //         LPI_ExceptionManager.logException(
    //             LPI_SUPERVISEE_INFORMATION_CONTROLLER,
    //             'updateSupervisorApprovalStatus',
    //             e
    //         );
    //     }
    //     outMap.put('isUpdateSuccess', false);
    //     return false;
    // }
    // /**
    //  * @author                      : Kishore
    //  * @since                       : 1st Map, 2023
    //  * @description                 : This method will remove the access of the applicant data.
    //  * @story Number				: S-48340
    //  * @return                      : `void`
    //  * @last modified by            : Ayush Dev
    //  * @last modified date          : (Add if modified by you)
    //  * @modified details            : (Add if modified by you)
    //  */
    // private static Boolean deleteSharedRecords(
    //     List<PreliminaryApplicationRef> parList,
    //     List<String> stepsName,
    //     Boolean deleteAllRecords,
    //     List<User> userList
    // ) {
    //     try {
    //         if (!parList.isEmpty()) {
    //             Map<String, Object> strObjMap = new Map<String, Object>();
    //             if(isStudentApproval){
    //                 strObjMap = fetchSupervisorUserDetails(
    //                     parList[0].Id,
    //                     false,
    //                     false
    //                 );
    //             }else{
    //                 strObjMap = fetchSupervisorUserDetails(
    //                     parList[0].Id,
    //                     true,
    //                     false
    //                 );
    //             }
    //             List<User> supervisorUserList = strObjMap.containsKey(
    //                     'supervisorUserList'
    //                 )
    //                 ? (List<User>) strObjMap.get('supervisorUserList')
    //                 : new List<User>();
    //             Set<Id> sourceTableIdList = new Set<Id>();
    //             List<String> userIdList = new List<String>();
    //             if (!userList.isEmpty()) {
    //                 //Check if the current supervisor User has to respond for any other applicant's request.
    //                 //So that sharing records for that user will not be deleted.
    //                 for (User supervisorUser : supervisorUserList) {
    //                     userIdList.add(supervisorUser.Id);
    //                 }
    //                 if (userIdList.contains(userList[0].Id)) {
    //                     return true;
    //                 }
    //                 Map<String, Object> returnMap = getNewRecordsToShare(
    //                     parList,
    //                     userList,
    //                     stepsName,
    //                     true
    //                 );
    //                 sourceTableIdList = returnMap.containsKey(
    //                         'sourceTableIdList'
    //                     )
    //                     ? (Set<Id>) returnMap.get('sourceTableIdList')
    //                     : sourceTableIdList;
    //                 //Checking that all the shared records to be deleted.
    //                 if (!parList.isEmpty() && deleteAllRecords) {
    //                     sourceTableIdList.add((Id) parList[0].Id);
    //                     sourceTableIdList.add(
    //                         (Id) parList[0].BusinessAccountNameId
    //                     );
    //                 }
    //                 if (!sourceTableIdList.isEmpty()) {
    //                     String filterSharingLedger =
    //                         'Source_Table_Id__c IN ' +
    //                         LPI_ServiceUtility.getStringValuesBySet(
    //                             sourceTableIdList
    //                         );
    //                     if (isStudentApproval && !userIdList.isEmpty()) {
    //                         filterSharingLedger +=
    //                             ' AND User_or_Group_Id__c IN ' +
    //                             LPI_ServiceUtility.getStringValuesByList(
    //                                 userIdList
    //                             );
    //                     } else if (!userList.isEmpty()) {
    //                         filterSharingLedger +=
    //                             ' AND User_or_Group_Id__c = \'' +
    //                             String.escapeSingleQuotes(userList[0].Id) +
    //                             '\'';
    //                     }
    //                     String querySharingLedger = ' Id ';
    //                     //fetching shared records in without sharing because we don't have access to the records created by supervisor.
    //                     LPI_SharingLedgerDAO.LPI_SharingLedgerWithoutSharingDAO withoutSharingLedger = new LPI_SharingLedgerDAO.LPI_SharingLedgerWithoutSharingDAO();
    //                     List<Sharing_Ledger__c> lstObjects = withoutSharingLedger.getSharingLedgerByDymanicQuery(
    //                         querySharingLedger,
    //                         filterSharingLedger,
    //                         null,
    //                         null,
    //                         null
    //                     );
    //                     if (!lstObjects.isEmpty()) {
    //                         LPI_WithoutSharingUtility.deleteSObject(
    //                             lstObjects
    //                         );
    //                         return true;
    //                     }
    //                 }
    //             }
    //         }
    //     } catch (Exception e) {
    //         LPI_ExceptionManager.logException(
    //             LPI_SUPERVISEE_INFORMATION_CONTROLLER,
    //             'deleteSharedRecords',
    //             e
    //         );
    //     }
    //     return false;
    // }
    // /**
    //  * @author                      : Kishore
    //  * @since                       : 1st Map, 2023
    //  * @description                 : This method is to update supervisor ACR details and send Email notifications
    //  * @story Number				: S-48340
    //  * @return                      : `void`
    //  * @last modified by            : Ayush Dev
    //  * @last modified date          : (Add if modified by you)
    //  * @modified details            : (Add if modified by you)
    //  */

    // private static void sendEmailNotification(
    //     String parId,
    //     String status,
    //     String rejectionReason,
    //     List<User> userList,
    //     List<PreliminaryApplicationRef> parList,
    //     Map<String, Object> inputMap
    // ) {
    //     try {
    //         Map<String, String> replaceTextMap = new Map<String, String>();
    //         String unqFilter;
    //         List<LPI_Wrapper.NotificationEmailWrapper> notificationEmailWrapperList = new List<LPI_Wrapper.NotificationEmailWrapper>();
    //         if (!parList.isEmpty() && !userList.isEmpty()) {
                
                
    //                 if (
    //                     parList[0]
    //                         .Regulatory_Authorization_Type__r.Email_Specifications_Final__c !=
    //                     null
    //                 ) {
    //                     Map<String, Object> boardSignatureMap = (Map<String, Object>) JSON.deserializeUntyped(
    //                         String.valueOf(
    //                             parList[0]
    //                                 .Regulatory_Authorization_Type__r.Email_Specifications_Final__c
    //                         )
    //                     );
    //                     replaceTextMap.put(
    //                         'Board_Email_MODPR',
    //                         String.isNotBlank(
    //                                 (String) boardSignatureMap.get(BOARD_EMAIL)
    //                             )
    //                             ? (String) boardSignatureMap.get(BOARD_EMAIL)
    //                             : ''
    //                     );
    //                     replaceTextMap.put(
    //                         'Board_PO_box',
    //                         String.isNotBlank(
    //                                 (String) boardSignatureMap.get(
    //                                     BOARD_PRO_BOX
    //                                 )
    //                             )
    //                             ? (String) boardSignatureMap.get(BOARD_PRO_BOX)
    //                             : ''
    //                     );
    //                     replaceTextMap.put(
    //                         'Board_Name',
    //                         String.isNotBlank(
    //                                 (String) boardSignatureMap.get('boardName')
    //                             )
    //                             ? (String) boardSignatureMap.get('boardName')
    //                             : ''
    //                     );
    //                 }
    //                 replaceTextMap.put(
    //                     'Supervisor_Name',
    //                     userList[0].Account.Name
    //                 );
    //                 replaceTextMap.put('Rejection_Reason', rejectionReason);
    //                 replaceTextMap.put(
    //                     'Portal_Link',
    //                     System.Label.Site_Url
    //                 );
    //                 replaceTextMap.put(
    //                     'License_Type',
    //                     String.valueOf(
    //                         parList[0].Regulatory_Authorization_Type__r.Name
    //                     )
    //                 );
    //                 if (isStudentApproval) {
    //                     if (inputMap.containsKey(MTS_STUDENT_APPROVAL)) {
    //                         unqFilter = status == APPROVED_STATUS
    //                             ? MTS_STUDENT_APPROVE_EMAIL
    //                             : MTS_STUDENT_REJECTED_EMAIL;
    //                     } else {
    //                         replaceTextMap.put(
    //                             'School_Name',
    //                             parList[0].Business_Name__c
    //                         );
    //                         unqFilter = status == APPROVED_STATUS
    //                             ? STUDENT_APPROVAL_NOTIFY_EMAIL
    //                             : STUDENT_REJECT_NOTIFY_EMAIL;
    //                     }
    //                 } else {
    //                     unqFilter = status == APPROVED_STATUS
    //                         ? APPROVAL_NOTIFY_EMAIL
    //                         : REJECT_NOTIFY_EMAIL;
    //                 }
                

    //             // Fetch the notification metadata record
    //             Map<String, Notification_Message__mdt> notificationMessageMap = LPI_TriggerServiceUtility.getMapOfNotificationByItsName(
    //                 new Set<String>{ unqFilter }
    //             );
    //             if (parList[0].BusinessAccountNameId != null) {
    //                 // Create a notification record
    //                 LPI_Wrapper.NotificationEmailWrapper notifcationWrapper = new LPI_Wrapper.NotificationEmailWrapper();
    //                 notifcationWrapper.accountId = parList[0]
    //                     .BusinessAccountNameId;
                    
    //                     notifcationWrapper.recipientEmail = parList[0]
    //                         .BusinessAccountName.PersonEmail;
                    
    //                 notifcationWrapper.templateName = notificationMessageMap.get(
    //                         unqFilter
    //                     )
    //                     .Template_Name__c;
    //                 notifcationWrapper.replaceTextMap = replaceTextMap;
    //                 notificationEmailWrapperList.add(notifcationWrapper);
    //                 if (!notificationEmailWrapperList.isEmpty()) {
    //                     LPI_ServiceUtility.createNotificationRecords(
    //                         notificationEmailWrapperList
    //                     );
    //                 }
    //             }
    //         }
    //     } catch (DmlException e) {
    //         LPI_ExceptionManager.logException(
    //             LPI_SUPERVISEE_INFORMATION_CONTROLLER,
    //             SEND_EMAIL_NOTIFICATION,
    //             e
    //         );
    //     }
    // }

    // /**
    //  * @author                      : Kishore
    //  * @since                       : 1st Map, 2023
    //  * @description                 : This method is to update supervisor ACR details and send Email notifications
    //  * @story Number				: S-48340
    //  * @return                      : `void`
    //  * @last modified by            : Ayush Dev
    //  * @last modified date          : (Add if modified by you)
    //  * @modified details            : (Add if modified by you)
    //  */

    // private static void findCurrentUser(
    //     Map<String, Object> inputMap,
    //     Map<String, Object> outMap
    // ) {
    //     outMap.put('supervisorNotAllowed', false);
    //     try {
    //         List<User> userList = LPI_UserDao.getCurrentUserRecord();
    //         List<Sharing_Ledger__c> insertSharingLedgerList = new List<Sharing_Ledger__c>();
            
    //         if (!userList.isEmpty()) {
    //             String currentUserAccountId = userList[0].AccountId;
    //             if (inputMap.containsKey('parId')) {
    //                 List<String> stepsName;
    //                 if (inputMap.containsKey(STEPS_NAME_LIST)) {
    //                     stepsName = String.valueOf(
    //                             inputMap.get(STEPS_NAME_LIST)
    //                         )
    //                         .split(',');
    //                 }
    //                 Id parId = (Id) inputMap.get('parId');
    //                 PreliminaryApplicationRef updatePar = new PreliminaryApplicationRef(
    //                     Id = parId
    //                 );
    //                 String supervisorAcrId = inputMap.containsKey('urlRecordId')
    //                     ? (String) inputMap.get('urlRecordId')
    //                     : null;
    //                 if (String.isNotEmpty(supervisorAcrId)) {
    //                     List<Notification__c> portalNotifyList = deletePoratalNotification(
    //                         new List<String>{ supervisorAcrId + '-' + parId }
    //                     );
    //                     List<PreliminaryApplicationRef> parList;
    //                     if (parId != null && String.isNotEmpty(parId)) {
    //                         String fields = ' Id, BusinessAccountNameId , Regulatory_Authorization_Type__c , Contact__c , Approval_Supervisors_AcrIds__c , Is_Supervisor_User__c ';
    //                         String whereClause =
    //                             'Id= \'' +
    //                             String.escapeSingleQuotes(parId) +
    //                             '\'';
    //                         //querying in without sharing mode to retereive par records even the current supervisor/admin is not having access.
    //                         LPI_PreliminaryApplicationRefDAO.LPI_PreliminaryApplicationRefWithoutSharingDAO parWithoutSharing = new LPI_PreliminaryApplicationRefDAO.LPI_PreliminaryApplicationRefWithoutSharingDAO();
    //                         parList = parWithoutSharing.getPreliminaryApplicationRefByDymanicQuery(
    //                             fields,
    //                             whereClause,
    //                             null,
    //                             null,
    //                             null
    //                         );
    //                     }
    //                     if (!parList.isEmpty()) {
    //                         Boolean isSupervisorChecked = parList[0]
    //                             .Is_Supervisor_User__c;
    //                         List<String> supervisorIdsList = LPI_SupervisorSharingUtility.checkSharingAllowed(
    //                             parList
    //                         );
    //                         if (
    //                             supervisorIdsList.contains(supervisorAcrId) &&
    //                             !portalNotifyList.isEmpty()
    //                         ) {
    //                             outMap.put('supervisorAcrId', supervisorAcrId);
    //                             //checking if already logged In user is Supervior , If Yes updating Par and sharing the records.
    //                             if (!isSupervisorChecked) {
    //                                 updatePar.Is_Supervisor_User__c = true;
    //                                 Map<String, Object> returnMap = getNewRecordsToShare(
    //                                     parList,
    //                                     userList,
    //                                     stepsName,
    //                                     false
    //                                 );
    //                                 insertSharingLedgerList = returnMap.containsKey(
    //                                         'insertSharingLedgerList'
    //                                     )
    //                                     ? (List<Sharing_Ledger__c>) returnMap.get(
    //                                           'insertSharingLedgerList'
    //                                       )
    //                                     : insertSharingLedgerList;
    //                                 if (!insertSharingLedgerList.isEmpty()) {
    //                                     LPI_DML.doInsert(
    //                                         insertSharingLedgerList
    //                                     );
    //                                 }
    //                                 LPI_DML.doUpdate(updatePar);
    //                             }
                                
    //                         } else {
    //                             outMap.put('supervisorNotAllowed', true);
    //                         }
    //                     } else {
    //                         outMap.put('supervisorNotAllowed', true);
    //                     }
    //                 } else {
    //                     //checking if already logged In user is Applicant , If Yes updating Par record.
    //                     updatePar.Is_Supervisor_User__c = false;
    //                     LPI_DML.doUpdate(updatePar);
    //                 }
    //             }
    //         }
    //     } catch (Exception e) {
    //         LPI_ExceptionManager.logException(
    //             LPI_SUPERVISEE_INFORMATION_CONTROLLER,
    //             'findCurrentUser',
    //             e
    //         );
    //     }
    // }
    // /**
    //  * @author                      : Kishore
    //  * @since                       : 1st Map, 2023
    //  * @description                 : This method is to fetch the records which need to be shared
    //  * @story Number				: S-48340
    //  * @return                      : `void`
    //  * @last modified by            : Ayush Dev
    //  * @last modified date          : (Add if modified by you)
    //  * @modified details            : (Add if modified by you)
    //  */

    // private static List<Sharing_Ledger__c> fetchSharingRecords(
    //     List<PreliminaryApplicationRef> parList,
    //     List<User> userList,
    //     List<String> stepsName
    // ) {
    //     List<Sharing_Ledger__c> insertSharingLedgerList = new List<Sharing_Ledger__c>();
    //     try {
    //         if (
    //             !parList.isEmpty() &&
    //             !userList.isEmpty() &&
    //             stepsName != null
    //         ) {
    //             //Sharing Education Records based on stepNames list.
    //             if (stepsName.contains(EDU_HISTORY_STEP)) {
    //                 insertSharingLedgerList.addAll(
    //                     LPI_SupervisorSharingUtility.sharePersonEduToSupervisor(
    //                         parList[0].Contact__c,
    //                         'Higher Education',
    //                         userList
    //                     )
    //                 );
    //             }
    //             //Sharing Application Content Records based on stepNames list.
    //             if (stepsName.contains(LICENSURE_HIST_STEP)) {
    //                 insertSharingLedgerList.addAll(
    //                     LPI_SupervisorSharingUtility.shareAppContentToSupervisor(
    //                         parList[0].Id,
    //                         'Licensure In Other States',
    //                         userList
    //                     )
    //                 );
    //             }
    //             //Sharing Application Content Records based on stepNames list.
    //             if (stepsName.contains(APP_REFERENCE_STEP)) {
    //                 insertSharingLedgerList.addAll(
    //                     LPI_SupervisorSharingUtility.shareAppContentToSupervisor(
    //                         parList[0].Id,
    //                         APP_REFERENCE,
    //                         userList
    //                     )
    //                 );
    //             }
    //             if (stepsName.contains(PERSONAL_INFO_STEP)) {
    //                 insertSharingLedgerList.addAll(
    //                     LPI_SupervisorSharingUtility.shareLocationToSupervisor(
    //                         parList[0].Id,
    //                         userList
    //                     )
    //                 );
    //             }
    //             for (User supervisorUser : userList) {
    //                 insertSharingLedgerList.add(
    //                     LPI_ApexSharingUtility.createStaticLedgerRecord(
    //                         PAR_OBJECT,
    //                         (String) parList[0].Id,
    //                         supervisorUser.Id
    //                     )
    //                 );
    //                 insertSharingLedgerList.add(
    //                     LPI_SupervisorSharingUtility.shareAccountToSupervisor(
    //                         (String) parList[0].BusinessAccountNameId,
    //                         supervisorUser.Id
    //                     )
    //                 );
    //             }
    //             System.debug('insertSharingLedgerList Test ======> '+insertSharingLedgerList);
    //         }
    //     } catch (Exception e) {
    //         LPI_ExceptionManager.logException(
    //             LPI_SUPERVISEE_INFORMATION_CONTROLLER,
    //             'fetchSharingRecords',
    //             e
    //         );
    //     }
    //     return insertSharingLedgerList;
    // }
    // /**
    //  * @author                      : Kishore
    //  * @since                       : 1st Map, 2023
    //  * @description                 : This method is used to fetch Supervisor User details
    //  * @story Number				: S-48340
    //  * @return                      : `void`
    //  * @last modified by            : Ayush Dev
    //  * @last modified date          : (Add if modified by you)
    //  * @modified details            : (Add if modified by you)
    //  */

    // private static Map<String, Object> fetchSupervisorUserDetails(
    //     String parId,
    //     Boolean onlySubmittedRecs,
    //     Boolean isSingleSupervisor
    // ) {
    //     List<User> supervisorUserList = new List<User>();
    //     Set<Id> brIdSet = new Set<Id>();
    //     List<Business_Relationships__c> businessRelationList = new List<Business_Relationships__c>();
    //     Map<String, Object> returnMap = new Map<String, Object>();
    //     Map<String, Object> supervisorDetialsMap = new Map<String, Object>();
    //     try {
    //         if (!String.isBlank(parId)) {
    //             List<String> supervisorAcrIdList = LPI_SupervisorSharingUtility.fetchSupervisorAcrIds(
    //                 parId
    //             );
    //             List<String> brRelatedFromList = new List<String>();
    //             if (!supervisorAcrIdList.isEmpty()) {
    //                 String acrFields =
    //                     'Id , Related_To__c , Related_To__r.PersonEmail , Related_To__r.Name , ' +
    //                     'Related_From__c , Related_From__r.PersonEmail , Related_From__r.Name, Related_To_License_Number__r.Name';//added Related_To_License_Number__r for S-62332
    //                 String whereCaluse = '';
    //                 if (isSingleSupervisor) {
    //                     whereCaluse =
    //                         'Id IN ' +
    //                         LPI_ServiceUtility.getStringValuesByList(
    //                             supervisorAcrIdList
    //                         );
    //                 } else {
    //                     if (onlySubmittedRecs) {
    //                         whereCaluse =
    //                             'Id IN ' +
    //                             LPI_ServiceUtility.getStringValuesByList(
    //                                 supervisorAcrIdList
    //                             ) +
    //                             ' AND Supervisor_Approval_Status__c = \'' +
    //                             String.escapeSingleQuotes(SUBMITTED_STATUS) +
    //                             '\'';
    //                     } else if(isStudentApproval){
    //                         whereCaluse =
    //                             'Id IN ' +
    //                             LPI_ServiceUtility.getStringValuesByList(
    //                                 supervisorAcrIdList
    //                             );
    //                             if(!IS_MTSTUDENT_APPLICATION){
    //                                 whereCaluse +=
    //                                     ' AND Supervisor_Approval_Status__c = \'' +
    //                                     String.escapeSingleQuotes(APPROVED_STATUS) +
    //                                     '\'';
    //                             }
                                
    //                     } else {
    //                         whereCaluse =
    //                             'Id IN ' +
    //                             LPI_ServiceUtility.getStringValuesByList(
    //                                 supervisorAcrIdList
    //                             ) +
    //                             ' AND Supervisor_Approval_Status__c = NULL';
    //                     }
    //                 }
    //                 LPI_BusinessRelationshipDAO.LPI_BusinessRelationshipsWithoutSharingDAO withoutSharingQuery = new LPI_BusinessRelationshipDAO.LPI_BusinessRelationshipsWithoutSharingDAO();
    //                 for (
    //                     Business_Relationships__c rec : withoutSharingQuery.getBusinessRelationshipsByDymanicQuery(
    //                         acrFields,
    //                         whereCaluse,
    //                         null,
    //                         null,
    //                         null
    //                     )
    //                 ) {
    //                     if (isStudentApproval) {
    //                         brRelatedFromList.add(rec.Related_To__c);
    //                     } else {
    //                         brRelatedFromList.add(rec.Related_From__c);
    //                     }
    //                     brIdSet.add(rec.Id);
    //                     businessRelationList.add(rec);
    //                 }
    //                 if (!brRelatedFromList.isEmpty()) {
    //                     String userFields = 'Id,ContactId,Account.Name,Account.Phone,Account.PersonEmail,AccountId ';
    //                     String userwhereCaluse =
    //                         ' AccountId IN ' +
    //                         LPI_ServiceUtility.getStringValuesByList(
    //                             brRelatedFromList
    //                         );
    //                     LPI_UserDao.LPI_UserWithoutSharingDAO userWithoutsharing = new LPI_UserDao.LPI_UserWithoutSharingDAO();
    //                     supervisorUserList = userWithoutsharing.getUserByDymanicQuery(
    //                         userFields,
    //                         userwhereCaluse,
    //                         null,
    //                         null,
    //                         null
    //                     );
    //                 }
    //             }
    //         }
    //     } catch (Exception e) {
    //         LPI_ExceptionManager.logException(
    //             LPI_SUPERVISEE_INFORMATION_CONTROLLER,
    //             'fetchSupervisorUserDetails',
    //             e
    //         );
    //     }
    //     returnMap.put('supervisorUserList', supervisorUserList);
    //     returnMap.put('brIdSet', brIdSet);
    //     returnMap.put('businessRelationList', businessRelationList);
    //     return returnMap;
    // }

    // /**
    //  * @author                      : Kishore
    //  * @since                       : 1st Map, 2023
    //  * @description                 : This method is used to fetch the records Ids which are shared to Supervisors
    //  * @return                      : `void`
    //  * @last modified by            : Ayush Dev
    //  * @last modified date          : (Add if modified by you)
    //  * @modified details            : (Add if modified by you)
    //  */
    // private static Map<String, Object> getNewRecordsToShare(
    //     List<PreliminaryApplicationRef> parList,
    //     List<User> userList,
    //     List<String> stepsName,
    //     Boolean fetchOnlySourceTableIds
    // ) {
    //     Map<String, Object> returnMap = new Map<String, Object>();
    //     List<Sharing_Ledger__c> sharingLedgerList = fetchSharingRecords(
    //         parList,
    //         userList,
    //         stepsName
    //     );
    //     //fetching the Object records which we have shared to Supervisor.
    //     Set<Id> sourceTableIdList = new Set<Id>();
    //     Map<String, Sharing_Ledger__c> sourceIdSharingLedgerMap = new Map<String, Sharing_Ledger__c>();
    //     List<Sharing_Ledger__c> insertSharingLedgerList = new List<Sharing_Ledger__c>();
    //     for (Sharing_Ledger__c sharingRec : sharingLedgerList) {
    //         if(sharingRec.Source_Table_Id__c!=null){
    //             sourceTableIdList.add(sharingRec.Source_Table_Id__c);
    //             sourceIdSharingLedgerMap.put(
    //                 (String) sharingRec.Source_Table_Id__c + sharingRec.User_or_Group_Id__c,
    //                 sharingRec
    //             );
    //         }
    //     }
    //     if (!sourceTableIdList.isEmpty()) {
    //         if (fetchOnlySourceTableIds) {
    //             returnMap.put('sourceTableIdList', sourceTableIdList);
    //         } else {
    //             Set<Id> userIdSet = new Set<Id>();
    //             Set<Id> sharedRecordsIdSet = new Set<Id>();
    //             for (User rec : userList) {
    //                 userIdSet.add(rec.Id);
    //             }
    //             String queryUserRecordAccess;
    //             String filterSharingLedger =
    //                 'Source_Table_Id__c IN ' +
    //                 LPI_ServiceUtility.getStringValuesBySet(
    //                     sourceTableIdList
    //                 ) +
    //                 ' AND User_or_Group_Id__c IN ' +
    //                 LPI_ServiceUtility.getStringValuesBySet(userIdSet);
    //             String querySharingLedger = ' Id , Source_Table_Id__c , User_or_Group_Id__c ';
    //             //fetching shared records in without sharing because we don't have access to the records created by supervisor.
    //             LPI_SharingLedgerDAO.LPI_SharingLedgerWithoutSharingDAO withoutSharingLedger = new LPI_SharingLedgerDAO.LPI_SharingLedgerWithoutSharingDAO();
    //             for (
    //                 Sharing_Ledger__c ledgerRecord : withoutSharingLedger.getSharingLedgerByDymanicQuery(
    //                     querySharingLedger,
    //                     filterSharingLedger,
    //                     null,
    //                     null,
    //                     null
    //                 )
    //             ) {
    //                 String key = ledgerRecord.Source_Table_Id__c + ledgerRecord.User_or_Group_Id__c;
    //                 if(sourceIdSharingLedgerMap.containskey(key)){
    //                     sourceIdSharingLedgerMap.remove(key);
    //                 }
    //             }
    //             returnMap.put(
    //                 'insertSharingLedgerList',
    //                 sourceIdSharingLedgerMap.values()
    //             );
    //         }
    //     }
    //     return returnMap;
    // }
    // /**
    //  * @author                      : Kishore
    //  * @since                       : 6th july 2023
    //  * @description                 : This method is used to fetch the protal_notification records based on superviosrId List
    //  * @return                      : List<Notification__c>
    //  * @last modified by            : Ayush Dev
    //  * @last modified date          : (Add if modified by you)
    //  * @modified details            : (Add if modified by you)
    //  */
    // public static List<Notification__c> deletePoratalNotification(
    //     List<String> supervisorIdList
    // ) {
    //     if (supervisorIdList.isEmpty()) {
    //         return null;
    //     }
    //     String poratalNtfFields = 'Id , Record_Id__c , Is_Resolved__c ';
    //     String poratalNtfWhere =
    //         ' Record_Id__c IN ' +
    //         LPI_ServiceUtility.getStringValuesByList(supervisorIdList) +
    //         ' AND Is_Resolved__c = FALSE';
    //     List<Notification__c> portalRecToDeleteList = new List<Notification__c>();
    //     LPI_PortalNotificationDAO.LPI_PortalNotificationWithoutSharingDAO portalWithoutquery = new LPI_PortalNotificationDAO.LPI_PortalNotificationWithoutSharingDAO();
    //     for (
    //         Notification__c rec : portalWithoutquery.getPortalNotificationByDymanicQuery(
    //             poratalNtfFields,
    //             poratalNtfWhere,
    //             null,
    //             null,
    //             null
    //         )
    //     ) {
    //         Notification__c newRec = new Notification__c(
    //             Id = rec.Id,
    //             Is_Resolved__c = true
    //         );
    //         portalRecToDeleteList.add(newRec);
    //     }
    //     return portalRecToDeleteList;
    // }
}