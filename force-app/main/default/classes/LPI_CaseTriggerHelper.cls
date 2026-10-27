/**
 * @description       : Helper class for LPI_CaseTriggerHandler
 * @author            : MTX Group Product Team
 * @group             :
 * @last modified on  : 06-07-2024
 * @last modified by  : MTX Group Product Team
 **/
public with sharing class LPI_CaseTriggerHelper { 
    
    private static final String CASE_STAGE_NEW = 'New';
    private static final String CASE_STAGE_INVES_COMP = 'Investigation Complete';
    private static final String CASE_STAGE_RET_FURTHER_INVES = 'Returned for Further Investigation';
    public static final String CASE_CLOSED_STATUS = 'Closed';

    private static final Set<String> CASE_ELIGIBLE_STAGES_FOR_EMAIL = new Set<String>{
        CASE_STAGE_NEW,
        CASE_STAGE_INVES_COMP,
        CASE_STAGE_RET_FURTHER_INVES
    };
    
	
    /**
     *
     * @param newList               fetching Case records from the beforeUpdate() method
     * @param oldMap                fetching Case records from the beforeUpdate() method
     */
    public static void updateDateEmailSent(
        List<case> newList,
        Map<Id, Case> oldMap
    ) {
        try {
            
            if (newList != null) {
                
                for (Case cas : newList) {
                    if (
                        cas.Status != oldMap.get(cas.Id).Status &&
                        cas.Status == 'Required Information'
                    ) {
                        cas.Date_Email_Sent__c = Date.today();
                    }
                }
            }
        } catch (Exception e) {
            LPI_ExceptionManager.logException(
                'LPI_CaseTriggerHelper',
                'updateDateEmailSent',
                e
            );
        }
    }

    /**
     *
     * @param newList               fetching Case records from the beforeUpdate() method
     * @param oldMap                fetching Case records from the beforeUpdate() method
     */
    public static void updateDateReceived(
        List<case> newList,
        Map<Id, Case> oldMap
    ) {
        try {
            
            if (newList != null) {
                
                for (Case cas : newList) {
                    if (
                        cas.Received_Information_From_Complainant__c !=
                        oldMap.get(cas.Id)
                            .Received_Information_From_Complainant__c &&
                        cas.Received_Information_From_Complainant__c
                    ) {
                        cas.Date_Email_Recieved__c = Date.today();
                    }
                }
            }
        } catch (Exception e) {
            LPI_ExceptionManager.logException(
                'LPI_CaseTriggerHelper',
                'updateDateReceived',
                e
            );
        }
    }

    /**
     *   @author                             : MTX Group Product Team
     *   @since                              : 1 June, 2023
     *   @description                        : This method will send Email Notifications based on Case Status Change.
     *   @param newList                      : Contains List of New Case Records
     *   @param oldMap                       : Contains Map of Old Case Records.
     *   @return                             : `void`
     */
    public static void sendCaseNotificationOnStageChanges(
        List<Case> newList,
        Map<Id, Case> oldMap
    ) {
        try {
            List<Case> stageChangeCaseRecordList = new List<Case>();
            Map<String, Notification_Message__mdt> stageToMetaDataRecordMap = new Map<String, Notification_Message__mdt>();
            Map<String, String> replaceTextMap;
            Set<String> uniqueStageKey = new Set<String>();
            Set<Id> ownerIdSet = new Set<Id>();
            Map<Id, User> ownerIdToUserInfoMap = new Map<Id, User>();
            Map<String, Notification_Message__mdt> devNameToEmailNotifRecMap = new Map<String, Notification_Message__mdt>();

            

            for (Case caseRec : newList) {                
                if (
                    String.isBlank(caseRec.Stage__c) ||
                    String.isBlank(caseRec.OwnerId) ||
                    (oldMap != null &&
                    caseRec.OwnerId == oldMap.get(caseRec.Id).OwnerId) ||
                    !CASE_ELIGIBLE_STAGES_FOR_EMAIL.contains(caseRec.Stage__c)
                    || ((String)caseRec.OwnerId).startsWith('00G')
                ) {
                    continue;
                }

                stageChangeCaseRecordList.add(caseRec);
                uniqueStageKey.add('Case-' + caseRec.Stage__c);
                ownerIdSet.add(caseRec.OwnerId);    
                if (oldMap != null) {
                    ownerIdSet.add(oldMap.get(caseRec.Id).OwnerId);
                }
            }
            
            if (stageChangeCaseRecordList.isEmpty()) {
                return;
            }
            
            
            for (
                User userRec : LPI_UserDao.getUserByDymanicQuery(
                    'Id,Name,Email,AccountId',
                    'isActive = true AND Id IN ' +
                    LPI_ServiceUtility.getStringValuesBySet(ownerIdSet),
                    null,
                    null,
                    null
                )
            ) {
                ownerIdToUserInfoMap.put(userRec.Id, userRec);
            }          

             
            String fieldsToQuery = 'Id,Unique_Filter__c,Title__c,Template_Name__c,Description__c,DeveloperName';
            String customMetaDataName = 'Notification_Message__mdt';
            String whereClause  = 'Unique_Filter__c != null AND Unique_Filter__c IN ' +
                LPI_ServiceUtility.getStringValuesByStringSet(uniqueStageKey);
            List<Notification_Message__mdt> notificationMetadataList = (List<Notification_Message__mdt>)new LPI_CustomMetadataTypeDAO.LPI_CustomMetadataTypeWithoutSharingDAO().getCustomMetaByDymQueryWithoutSec(
                fieldsToQuery,
                customMetaDataName,
                whereClause,
                null,
                null,
                null
            );
            for (
                Notification_Message__mdt notificationRec : notificationMetadataList
            ) {
                stageToMetaDataRecordMap.put(
                    notificationRec.Unique_Filter__c?.substringAfter('Case-'),
                    notificationRec
                );
                devNameToEmailNotifRecMap.put(notificationRec.DeveloperName,notificationRec);
            }

            
            User currentOwnerInfo;
            String emailTemplateName;
            User previousOwnerInfo;
            Map<String, String> replaceMap;
            String emailBody;
            String emailTemplateSubject;
            String emailTemplateBody;
		    String Subject;
            List<LPI_Wrapper.NotificationEmailWrapper> notificationEmailWrapperList = new List<LPI_Wrapper.NotificationEmailWrapper>();
            for (Case caseRec : stageChangeCaseRecordList) {
                if (!stageToMetaDataRecordMap.containsKey(caseRec.Stage__c)) {
                    continue;
                } else if (String.isBlank(caseRec.AccountId)) {
                    throw new LPI_Exception(
                        'Couldn\'t Find Account Id On Case'
                    );
                } else if (!ownerIdToUserInfoMap.containsKey(caseRec.OwnerId)) {
                    throw new LPI_Exception(
                        'Couldn\'t fetch Current Owner Details, Please check if He/She is an Active User'
                    );
                }

                currentOwnerInfo = ownerIdToUserInfoMap.get(caseRec.OwnerId);
                
                emailTemplateName = stageToMetaDataRecordMap.get(
                        caseRec.Stage__c
                    )
                    ?.Template_Name__c;
                  emailTemplateBody=stageToMetaDataRecordMap.get(
                    caseRec.Stage__c
                )
                ?.Description__c;
                  emailTemplateSubject=stageToMetaDataRecordMap.get(
                    caseRec.Stage__c
                )
                ?.Title__c;
                if (
                    caseRec.Stage__c == CASE_STAGE_INVES_COMP &&
                    previousOwnerInfo != null
                ) {
                    replaceMap = new Map<String, String>{
                        'Assigned_Investigator_User' => previousOwnerInfo.Name,
                        'Case_Owner_User' => currentOwnerInfo.Name,
                        'Case_Number' => caseRec.Case_Number__c,
                        'Case_Title' => caseRec.Subject,
                        'Case_Stage' => caseRec.Stage__c
                    };
                } else {
                    replaceMap = new Map<String, String>{
                        'Assigned_Investigator_User' => currentOwnerInfo.Name,
                        'Case_Number' => caseRec.Case_Number__c,
                        'Case_Title' => String.isBlank(caseRec.Subject) ? '' : caseRec.Subject,
                        'Case_Stage' => caseRec.Stage__c
                    };
                }

                

                emailBody = emailTemplateBody;
                Subject = emailTemplateSubject;

                if (replaceMap != null) {
                    for (String key : replaceMap.keySet()) {
                        emailBody = emailBody.replaceAll('\\[' + key + '\\]', replaceMap.get(key));
                        Subject =Subject.replaceAll('\\[' + key + '\\]', replaceMap.get(key));
                        
                    }
                }

                LPI_Wrapper.NotificationEmailWrapper notifcationWrapper = new LPI_Wrapper.NotificationEmailWrapper();
                notifcationWrapper.accountId = currentOwnerInfo.AccountId;
                notifcationWrapper.recipientEmail = currentOwnerInfo.Email;
                notifcationWrapper.templateName = emailTemplateName;
                notifcationWrapper.replaceTextMap = replaceMap;
                notifcationWrapper.subject = Subject;
                notifcationWrapper.description = emailBody;
                notifcationWrapper.caseId = caseRec.Id;
                notificationEmailWrapperList.add(notifcationWrapper);
            }
            if (!notificationEmailWrapperList.isEmpty()) {
                LPI_ServiceUtility.createNotificationRecords(notificationEmailWrapperList);
            }
        }  
         catch (Exception ex) {
            LPI_ExceptionManager.logException(
                'LPI_CaseTriggerHelper',
                'sendCaseNotificationOnStatusChanges',
                ex
            );
            throw new LPI_Exception(ex.getMessage());
        }
    }

    /**
    * @description : Method to update Closed_Date__c on Case when the Case has been Closed.
    * @author MTX Group Product Team | 07-13-2023 
    * @param newList 
    * @param oldMap 
    **/
    public static void updateClosedDate(List<Case> newList,Map<Id, Case> oldMap){
        for(Case caseRec : newList){
            if(caseRec.RecordTypeId != LPI_CreateCaseAndComplaintCase.CASE_COMPLAINT_RECORD_TYPE_ID || caseRec.Status == oldMap.get(caseRec.Id).Status  || (caseRec.Status != CASE_CLOSED_STATUS && oldMap.get(caseRec.Id).Status != CASE_CLOSED_STATUS)){
                continue;
            }
            caseRec.Closed_Date__c = caseRec.Status == CASE_CLOSED_STATUS ? Date.today() : null;
        }

    }
    


    /**
     *   @author                             : Vamshi Kumar
     *   @since                              : 25 August, 2023
     *   @description                        : This method will update name of Case record.
     *   @param newList                      : Contains List of New Case Records
     *   @return                             : `void`
     */
     public static void updateCaseNameWithCounter(List<Case> newList) {
        try {
            String fields = 'Case_Counter__c';
            String whereClause = 'Case_Counter__c != null AND Business_License_Counter__c != null';
            List<In_App_Checklist_Settings__c> appcheckCustomSettingList = LPI_CustomMetadataTypeDAO.dynamicGetAppChecklistSettingBusinessLicenseNumber(fields,whereClause,'In_App_Checklist_Settings__c');
            if(!appcheckCustomSettingList.isEmpty()){
                In_App_Checklist_Settings__c appcheckCustomSetting = appcheckCustomSettingList[0];
                Integer caseNameCounter = Integer.valueOf(appcheckCustomSetting.Case_Counter__c);
                if(caseNameCounter != null)
                {
                    for(Case caseRec : newList)
                    {
                        caseRec.Case_Number__c = String.valueOf(Date.today().year()) + '-' + String.valueOf(caseNameCounter).leftPad(6, '0');
                        caseNameCounter += 1;
                    }
                     
                    appcheckCustomSetting.Case_Counter__c = caseNameCounter;
                    LPI_WithoutSharingUtility.updateAppChecklistCustomSetting(appcheckCustomSetting);
                }
            }
        } catch (Exception ex) {
            LPI_ExceptionManager.logException(
            'LPI_CaseTriggerHelper',
            'updateCaseNameWithCounter',
            ex
            );
            throw new LPI_Exception(ex.getMessage());
        }
    }

    /**
     *   @author                         : MTX Group Product Team
     *   @since                          : 16 Feb, 2024
     *   @description                    : this method count the cases on Account
     *   @param newCasesList             : Contains List of New Case Records
     *   @param oldCasesMap              : Contains List of Old Case Records
     */
    public static void countOfCasesOnAccount(List<Case> newCasesList, List<Case> oldCasesList)
    {
        try{
            set<id> accIds= new set<id>();
            if(newCasesList != null){
                for(Case c : newCasesList){
                    if(c.AccountId!=null){
                        accids.add(c.accountid);
                    }
                }      
            }
            
            if(oldCasesList != null){
                for(Case c : oldCasesList){
                    if(c.AccountId!=null){
                        accids.add(c.accountid);
                    }
                }
            }
            
            if(accids.isEmpty()){
                return;
            }
            String fieldsToQuery ='Id,Open_Case_Counter__c,(SELECT Id from Cases Where Status != \'Closed\' And Status != \'Draft\') ';
            String whereClause =  'Id IN '+ LPI_ServiceUtility.getStringValuesBySet(accids);
            List<Account> accList = new LPI_AccountDAO.LPI_AccountWithoutSharingDAO().getAccountByDymanicQuery(fieldsToQuery,whereClause,null,null,null);
            if(accList!=null){
                for(Account acc : accList){
                    acc.Open_Case_Counter__c = acc.Cases.size();
                } 
            }
            
            if (!accList.isEmpty()) {
                LPI_TriggerHandler.bypass('LPI_AccountTriggerHandler');
                if (LPI_TriggerHandler.isBypassed('LPI_AccountTriggerHandler')) {
                    LPI_WithoutSharingUtility.updateSObjectList(accList);
                }
                LPI_TriggerHandler.clearBypass('LPI_AccountTriggerHandler');
            }

        } catch (Exception e) {
            LPI_ExceptionManager.logException(
                'LPI_CaseTriggerHelper',
                'countOfCasesOnAccount',
                e
            );
        }
    }

    /**
     *   @author                         : MTX Group Product Team
     *   @since                          : 19 Feb, 2024
     *   @description                    : this method count the cases on license
     *   @param newCasesList             : Contains List of New Case Records
     *   @param oldCasesMap              : Contains Map of Old Case Records
     *   @param triggerContextType       : Context of Trigger
     */
    public static void countOfCasesOnLicenses(List<Case> newCasesList, Map<Id,Case> oldCasesMap,String triggerContextType)
    {
        try{
            Set<String> statusSet = new Set<String>{'Draft', 'Closed'};
            Set<Id> licIdSet = new Set<Id>();
            Map<Id, Integer> licenseCounterMap = new Map<Id, Integer>();

            if(newCasesList != null){
                for (Case c : newCasesList) {
                    if (triggerContextType == 'isInsert' || triggerContextType == 'isUndelete') {
                        if(statusSet.contains(c.Status)){
                            continue;
                        }
                        if (c.Business_License_Id__c != null) {
                            updateOpenCaseCountOnLic(c.Business_License_Id__c, licenseCounterMap, licIdSet, 1);
                        }
                    } else if (triggerContextType == 'isUpdate') { 
                        if(c.Business_License_Id__c != null && oldCasesMap != null && oldCasesMap.get(c.Id).Business_License_Id__c != null){
                            if(oldCasesMap.get(c.Id).Business_License_Id__c != c.Business_License_Id__c){
                                if(!statusSet.contains(c.status)){
                                    updateOpenCaseCountOnLic(c.Business_License_Id__c, licenseCounterMap, licIdSet, 1);
                                }
                                if(!statusSet.contains(oldCasesMap.get(c.Id).status)){
                                    updateOpenCaseCountOnLic(oldCasesMap.get(c.Id).Business_License_Id__c, licenseCounterMap, licIdSet, -1);
                                }
                            }else{
                                if(oldCasesMap.get(c.Id).status != c.status){
                                    if(statusSet.contains(oldCasesMap.get(c.Id).status) && !statusSet.contains(c.status)){
                                        updateOpenCaseCountOnLic(c.Business_License_Id__c, licenseCounterMap, licIdSet, 1);
                                    }
                                    if(!statusSet.contains(oldCasesMap.get(c.Id).status) && statusSet.contains(c.status)){
                                        updateOpenCaseCountOnLic(oldCasesMap.get(c.Id).Business_License_Id__c, licenseCounterMap, licIdSet, -1);
                                    }
                                }
                            }
                        }
                        else if(c.Business_License_Id__c == null && oldCasesMap.get(c.Id).Business_License_Id__c != null){
                            if(!statusSet.contains(oldCasesMap.get(c.Id).status)){
                                updateOpenCaseCountOnLic(oldCasesMap.get(c.Id).Business_License_Id__c, licenseCounterMap, licIdSet, -1);
                            }
                        }else if(c.Business_License_Id__c != null && oldCasesMap.get(c.Id).Business_License_Id__c == null){
                            if(!statusSet.contains(c.status)){
                                updateOpenCaseCountOnLic(c.Business_License_Id__c, licenseCounterMap, licIdSet, 1);
                            }
                        }
                    } 
                }
            } 
            if (triggerContextType == 'isDelete' && oldCasesMap != null) {
                for (Case c : oldCasesMap.values()) {
                    if(statusSet.contains(c.Status)){
                        continue;
                    }
                    if (c.Business_License_Id__c != null) {
                        updateOpenCaseCountOnLic(c.Business_License_Id__c, licenseCounterMap, licIdSet, -1);
                    }
                }
            }

            Map<Id,Decimal> caseCountOnLicense = new Map<Id,Decimal>();
            List<BusinessLicense> updatedBLList = new List<BusinessLicense>();

            if(licIdSet.isEmpty()){
                return;
            }
            
            LPI_BusinessLicenseDAO.LPI_BusinessLicenseWithoutSharingDAO businessLicenseDao = new LPI_BusinessLicenseDAO.LPI_BusinessLicenseWithoutSharingDAO();
            List<BusinessLicense> businessLicList = businessLicenseDao.getBusinessLicenseByDymanicQueryWithoutSecurity(
                'id,Open_Case_Counter__c',
                'Id IN '+ LPI_ServiceUtility.getStringValuesBySet(licIdSet),
                null,
                null,
                null
            );

            for (BusinessLicense bl : businessLicList) {
                Integer counter = licenseCounterMap.get(bl.Id);
                if (counter != null) {
                    bl.Open_Case_Counter__c = (bl.Open_Case_Counter__c != null ? bl.Open_Case_Counter__c : 0) + counter;
                    caseCountOnLicense.put(bl.Id,bl.Open_Case_Counter__c);
                    updatedBLList.add(bl);
                }
            }
            
            List<Case> caseList = new List<Case>();
            if(newCasesList != null){
                for(Case c : newCasesList){
                    if(c.Business_License_Id__c != null && caseCountOnLicense.get(c.Business_License_Id__c) != null && !statusSet.contains(c.Status)){
                        if(triggerContextType == 'isUpdate'){
                            c.Case_License_Counter_Check__c = caseCountOnLicense.get(c.Business_License_Id__c) > 1;
                        }else{
                            caseList.add(new Case(Id = c.id,Case_License_Counter_Check__c = caseCountOnLicense.get(c.Business_License_Id__c) > 1 ));
                        }
                    }
                    if((c.Business_License_Id__c == null || statusSet.contains(c.Status)) && triggerContextType == 'isUpdate'){
                        c.Case_License_Counter_Check__c = false;
                    }
                }
            }

            if (!updatedBLList.isEmpty()) {
                LPI_TriggerHandler.bypass('LPI_BusinessLicenseTriggerHandler');
                if (LPI_TriggerHandler.isBypassed('LPI_BusinessLicenseTriggerHandler')) {
                    LPI_WithoutSharingUtility.updateSObjectList(updatedBLList);
                }
                LPI_TriggerHandler.clearBypass('LPI_BusinessLicenseTriggerHandler');
            }
            
            if(!caseList.isEmpty()){
                LPI_TriggerHandler.bypass('LPI_CaseTriggerHandler');
                if (LPI_TriggerHandler.isBypassed('LPI_CaseTriggerHandler')) {
                    LPI_WithoutSharingUtility.updateSObjectList(caseList);
                }
                LPI_TriggerHandler.clearBypass('LPI_CaseTriggerHandler');
            }
            
        } catch (Exception e) {
            LPI_ExceptionManager.logException(
                'LPI_CaseTriggerHelper',
                'countOfCasesOnLicenses',
                e
            );
        }
    }

    private static void updateOpenCaseCountOnLic(Id licenseId, Map<Id, Integer> licenseCounterMap, Set<Id> licIdSet, Integer countChange) {
        licIdSet.add(licenseId);
        if (licenseCounterMap.containsKey(licenseId)) {
            licenseCounterMap.put(licenseId, licenseCounterMap.get(licenseId) + countChange);
        } else {
            licenseCounterMap.put(licenseId, countChange);
        }
    }


    /**
    * @description : Method to send notification to respondent when new cased created, if there is a open case avaiable already.
    * @author MTX Group Product Team | 02-20-2024 
    * @param caselist 
    * @return void 
    **/
    public static void sendNotificationForRespondent(List<Case> newCasesList){
        try {
                Set<Id> accIds = new Set<Id>();
                for(Case c : newCasesList){
                    if(c.AccountId != null){
                        accIds.add(c.AccountId);
                    }
                }
                if(accIds.isEmpty()){
                    return;
                }

                List<Account> accList = LPI_AccountDAO.getAccountListByDynamicQuery( 
                    new List<String>{'Id','Name'},
                    'Open_Case_Counter__c > 1 AND Id IN '+ LPI_ServiceUtility.getStringValuesBySet(accIds) , null, null, null
                );

                Map<Id, Account> accMap = new Map<Id, Account>();
                for (Account acc : accList) {
                    accMap.put(acc.id, acc);
                }

                List<Case> caseList = new List<Case>();
                List<Notification__c> portalNotificationToInsert = new List<Notification__c>();
                for(Case c : newCasesList)
                {
                    if(accMap.get(c.AccountId) != null){
                        List<Portal_Notification_Message__mdt> notiRec = LPI_CustomMetadataTypeDAO.getAllPortalNotificationByDeveloperName(
                            'New_Case_Notification_For_Respondent'
                        );

                        
                        Map<String, String> replaceBellTextMap = new Map<String, String>{
                            '[Case_Number]' => c.Case_Number__c != null ? c.Case_Number__c : '',
                            '[Case_Account_Name]' => accMap.get(c.AccountId).Name != null ? accMap.get(c.AccountId).Name : '',
                            '[CreatedDate]' => c.CreatedDate != null ? c.CreatedDate?.format() : '',
                            '[Case_Subject]' => c.Subject != null ? c.Subject : '',
                            '[Case_BaordName]' => c.Board_Name__c != null ? c.Board_Name__c : ''
                        };

                        if(!notiRec.isEmpty()) {
                            portalNotificationToInsert.add(
                                LPI_ServiceUtility.createBellNotificationRecord(
                                notiRec[0],
                                true,
                                replaceBellTextMap,
                                c.OwnerId,
                                c.Id
                                )   
                            );
                        }
                    }
                    caseList.add(new Case(Id = c.Id,Priority = 'High'));
                }

                
                if (!portalNotificationToInsert.isEmpty()) {
                    LPI_WithoutSharingUtility.insertSObjectList(portalNotificationToInsert);
                }
                if(!caseList.isEmpty()){
                    LPI_TriggerHandler.bypass('LPI_CaseTriggerHandler');
                    if (LPI_TriggerHandler.isBypassed('LPI_CaseTriggerHandler')) {
                        LPI_WithoutSharingUtility.updateSObjectList(caseList);
                    }
                    LPI_TriggerHandler.clearBypass('LPI_CaseTriggerHandler');
                }
        } catch (Exception e) {
            LPI_ExceptionManager.logException(
                'LPI_CaseTriggerHelper',
                'sendNotificationForRespondent',
                e
            );
            throw new LPI_Exception(e.getMessage());
        }
    }

    /**
     *   @author                         : MTX Group Product Team
     *   @since                          : 1 March, 2024
     *   @description                    : this method count the cases on license
     *   @param newCasesMap              : Contains Map of New Case Records
     *   @param oldCasesMap              : Contains Map of Old Case Records
     */
    public static void toTriggerRcvTrigger(Map<Id,Case> newCaseMap,Map<Id,Case> oldCaseMap){
        
        List<RegulatoryCodeViolation> rcvList = new List<RegulatoryCodeViolation>();
        if(newCaseMap != null){
            Boolean processRecords = false;
            Set<Id> caseIdSet = new Set<Id>();
            for(Case caseRec : newCaseMap.values()){
                if(caseRec.Is_Discipline_Reporting_Action__c && (oldCaseMap == NULL || (oldCaseMap != NULL && oldCaseMap.get(caseRec.Id).Status == 'Draft' && caseRec.Status == 'New'))){
                    continue;
                }

                caseIdSet.add(caseRec.Id);
            }
            if(caseIdSet.isEmpty()){
                return;
            }
            String fields = 'id,Case__c ';
            String whereClause = 'case__c IN '+LPI_ServiceUtility.getStringValuesBySet(caseIdSet);

            rcvList = LPI_RegulatoryCodeViolationDAO.getRegulatoryCodeViolationListByDynamicQuery(fields,whereClause,null,null,null);
            for(RegulatoryCodeViolation rcv : rcvList){
                rcv.BL_From_Case__c = newCaseMap.get(rcv.case__c).Business_License_Id__c;
            }
        }else if(newCaseMap == null){
            String fields = 'id,Case__c ';
            String whereClause = 'case__c IN '+LPI_ServiceUtility.getStringValuesBySet(oldCaseMap.keySet());

            rcvList = LPI_RegulatoryCodeViolationDAO.getRegulatoryCodeViolationListByDynamicQuery(fields,whereClause,null,null,null);
            for(RegulatoryCodeViolation rcv : rcvList){
                rcv.BL_From_Case__c = '';
            }
        }

        if(!rcvList.isEmpty()){
            LPI_DML.doUpdate(rcvList);
        }
    }
   
}