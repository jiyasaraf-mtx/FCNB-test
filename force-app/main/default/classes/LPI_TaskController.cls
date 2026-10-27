/**
 * @description       :
 * @author            : MTX Group Product Team
 * @group             :
 * @last modified on  : 07-24-2024
 * @last modified by  : MTX Group Product Team
 **/
public with sharing class LPI_TaskController {
    
    public static final string TASK_API_NAME = 'Task';
     
    public static final String TASK_COMPLAINT_REC_TYPE_ID = Schema.SObjectType.Task
        ?.getRecordTypeInfosByDeveloperName()
        ?.get('Task_Complaint')
        ?.getRecordTypeId();
    
    private static final String MONTHLY = 'Monthly';
    private static final String WEEKLY = 'Weekly';
    private static final String SEMI_ANNUALLY = 'Semi-Annually';
    private static final String ANNUALLY = 'Annually';
    private static final String QUARTERLY = 'Quarterly';
    private static final String DAILY = 'Daily';
    private static final String COMPLAINANT = 'Complainant';
    private static final String RESPONDENT = 'Respondent';

    @AuraEnabled
    public static LPI_Wrapper.TaskWrapper getTaskDetails(Id recordId) {
        try {
            if (String.isBlank(recordId)) {
                return null;
            }
            Boolean isTaskId = (String.valueOf(recordId.getsobjecttype()) ==
            TASK_API_NAME);
            String fields;
            String whereClause;
            String boardName;
            String caseId;
            List<Task> taskList = new List<Task>();
            if (isTaskId) {
                fields = 'Id,WhatId,RecordTypeId,Action__c,Related_to_Name__c,Related_To__c';
                whereClause =
                    'Id = \'' +
                    String.escapeSingleQuotes(recordId) +
                    '\'';
                taskList = LPI_TaskDao.getTaskByDymanicQuery(
                    fields,
                    whereClause,
                    null,
                    null,
                    null
                );

                caseId = !taskList.isEmpty() ? taskList[0].WhatId : null;
            }
            if (
                !taskList.isEmpty() &&
                taskList[0].RecordTypeId != TASK_COMPLAINT_REC_TYPE_ID
            ) {
                return null;
            }
            caseId = String.isBlank(caseId) ? recordId : caseId;
            fields = 'Id,Board_Name__c,Account.Name,(SELECT ID,Participant.Name,Role,Status FROM CaseParticipantCase WHERE Status=\'Active\' AND Role=\'Complainant\')';
            whereClause =
                'Id = \'' +
                String.escapeSingleQuotes(caseId) +
                '\'';
            List<Case> caseList = new LPI_CaseDAO.LPI_CaseWithoutSharingDAO().getCaseRecordsWithoutSharing(
                fields,
                whereClause,
                null,
                null
            );
            boardName = !caseList.isEmpty()
                ? caseList[0].Board_Name__c
                : null;
            if (String.isBlank(boardName)) {
                return null;
            }
            LPI_Wrapper.TaskWrapper wrapper = new LPI_Wrapper.TaskWrapper();
            wrapper.actionOptions = getActionValuesByBoard(boardName);
            wrapper.boardName = boardName;
            for (
                LPI_NewVisitRecord.SelectOptionWrapper optionWrapper : LPI_NewVisitRecord.fetchPicklist(
                    'Task',
                    'Related_To__c',
                    false
                )
            ) {
                wrapper.relatedToOptions.add(optionWrapper);
            }
            for (
                LPI_NewVisitRecord.SelectOptionWrapper optionWrapper : LPI_NewVisitRecord.fetchPicklist(
                    'Task',
                    'Status',
                    false
                )
            ) {
                wrapper.activityStatusOptions.add(optionWrapper);
            }
            populateRelatedToAccountNameOnTaskWrapper(caseList,wrapper);  

            wrapper.caseId = caseId;
            wrapper.taskId = isTaskId ? recordId : null;
            if(!taskList.isEmpty()) {
                wrapper.relatedTo = taskList[0]?.Related_To__c;
                wrapper.relatedToCompName = taskList[0]?.Related_To__c == COMPLAINANT ? taskList[0].Related_to_Name__c : (wrapper.relatedToCompName!=null ? wrapper.relatedToCompName : '');
                wrapper.relatedToRespName = taskList[0]?.Related_To__c == RESPONDENT ? taskList[0].Related_to_Name__c :  (wrapper.relatedToRespName!=null ? wrapper.relatedToRespName : '');
                wrapper.action = taskList[0].Action__c;
            }
            return wrapper;
        } catch (Exception ex) {
            LPI_ExceptionManager.logException(
                'LPI_TaskController',
                'getTaskDetails',
                ex
            );
            throw new LPI_Exception(ex.getMessage());
        }
    }

    private static void populateRelatedToAccountNameOnTaskWrapper(List<Case> caseList, LPI_Wrapper.TaskWrapper wrapper) {
        wrapper.relatedToCompName = !caseList.isEmpty() && !caseList[0]?.CaseParticipantCase.isEmpty() ?  caseList[0]?.CaseParticipantCase[0]?.Participant.Name: '';
        wrapper.relatedToRespName = !caseList.isEmpty() ? caseList[0].Account.Name : '';
    }


    @AuraEnabled
    public static String saveTaskDetails(String jsonData) {
        try {
            if (String.isBlank(jsonData)) {
                return null;
            }
            List<LPI_Wrapper.NotificationEmailWrapper> notificationEmailWrapperList = new List<LPI_Wrapper.NotificationEmailWrapper>();
            List<Notification__c> portalNotificationList = new List<Notification__c>();
            Map<String, String> portalreplaceTextMap = new Map<String, String>();
            Map<String, String> replaceTextMap = new Map<String, String>();
            Map<String, Notification_Message__mdt> notificationMessageMap = LPI_TriggerServiceUtility.getMapOfNotificationByItsName(
                new Set<String>{ 'New_Task_Record_Creation_Email' }
            );
			Map<String, Portal_Notification_Message__mdt> portalNotificationMessageMap = LPI_ServiceUtility.fetchPortalNotificationMetaDataRecord(
				null,
				null,
				null,
				new List<String>{ 'assignedTaskPortal' }
			);

            LPI_Wrapper.TaskWrapper wrapper = (LPI_Wrapper.TaskWrapper) JSON.deserialize(
                jsonData,
                LPI_Wrapper.TaskWrapper.class
            );
            Task taskRec = new Task();
            taskRec.Action__c = wrapper.action == 'None'  ? null : wrapper.action;
            taskRec.Status = wrapper.activityStatus;
            taskRec.OwnerId = wrapper.assignedUserId;
            taskRec.WhatId = wrapper.caseId;
            taskRec.Description = wrapper.comments;
            taskRec.ActivityDate = wrapper.dueDate;
            taskRec.RecordTypeId = TASK_COMPLAINT_REC_TYPE_ID;
            taskRec.Subject = wrapper.subject;
            taskRec.Related_To__c = wrapper.relatedTo;
            taskRec.Related_to_Name__c = wrapper.relatedToName;
            taskRec.Board_Name__c = wrapper.boardName;
            Insert taskRec;
             
            if (taskRec.Id != null) {
                String fields = 'Id,Subject,AccountId,Account.Name,Priority,Owner.Email,CreatedBy.Name,Typeof What when case then Case_Number__c end';
                String whereClause =
                    'Id = \'' +
                    String.escapeSingleQuotes(taskRec.Id) +
                    '\'';
                List<Task> taskList = LPI_TaskDao.getTaskByDymanicQuery(
                    fields,
                    whereClause,
                    null,
                    null,
                    null
                );
                if(!taskList.isEmpty()){
                    replaceTextMap.put('TaskDesc',taskList[0].Subject);
                    replaceTextMap.put('TaskPriority',taskList[0].Priority);
                    replaceTextMap.put('TaskCreater',taskList[0].CreatedBy.Name);
                    replaceTextMap.put('recordId',taskList[0].Id);
                    replaceTextMap.put('OrgDomainUrl',URL.getOrgDomainUrl().toExternalForm());
                    if(taskList[0].What instanceof Case) {
                        Case caseRec = (Case) taskList[0].What;
                        replaceTextMap.put('CaseNumber',caseRec.Case_Number__c);
                        portalreplaceTextMap.put('[Case_Number]', caseRec.Case_Number__c);
                    }

                    String emailBody = notificationMessageMap.get('New_Task_Record_Creation_Email').Description__c;

                    if (replaceTextMap != null) {
                        for (String key : replaceTextMap.keySet()) {
                            emailBody = emailBody.replaceAll('\\[' + key + '\\]', replaceTextMap.get(key));
                        }
                    }
                    LPI_Wrapper.NotificationEmailWrapper notifcationWrapper = new LPI_Wrapper.NotificationEmailWrapper();
                    notifcationWrapper.accountId = taskList[0].AccountId;
                    notifcationWrapper.recipientEmail = taskList[0].Owner.Email;
                    notifcationWrapper.caseId = taskList[0].WhatId;
                    notifcationWrapper.subject = notificationMessageMap.get('New_Task_Record_Creation_Email').Title__c;
                    notifcationWrapper.description = emailBody;
                    notifcationWrapper.templateName = notificationMessageMap.get(
                            'New_Task_Record_Creation_Email'
                        )
                        .Template_Name__c;
                    notifcationWrapper.replaceTextMap = replaceTextMap;
                    notificationEmailWrapperList.add(notifcationWrapper);
                    portalreplaceTextMap.put('[Assigned_Task_Portal_User]', taskList[0].Account.Name);
                    portalreplaceTextMap.put('[Task_Description]', 'Audit');
                    Notification__c portalNoti = LPI_ServiceUtility.createPortalNotificationRecord(
                        portalNotificationMessageMap.get('Notification_for_a_Assigned_Task'),
                        true,
                        portalreplaceTextMap,
                        null,
                        taskList[0].AccountId
                    );
                    if(portalNoti!=null){
                    portalNotificationList.add(portalNoti);
                    }
                   
                }
                
                 
                if (!notificationEmailWrapperList.isEmpty()) {
                    LPI_ServiceUtility.createNotificationRecords(
                        notificationEmailWrapperList
                    );
                }
                if(!portalNotificationList.isEmpty()){
                     
					LPI_DML.doInsert(portalNotificationList);
				}
            }


           
            return 'true';
        } catch (Exception ex) {
            LPI_ExceptionManager.logException(
                'LPI_TaskController',
                'getTaskDetails',
                ex
            );
            throw new LPI_Exception(ex.getMessage());
        }
    }


	 

    
    public static List<LPI_NewVisitRecord.SelectOptionWrapper> getActionValuesByBoard(
        String boardName
    ) {
        try {
            String fields = 'Action_Values__c';
            String customMetaDataName = 'LPI_BoardToActionConfiguration__mdt';
            String whereClause = 'Board_Name__c = \'' + boardName + '\'';
            List<LPI_BoardToActionConfiguration__mdt> metadataList = LPI_CustomMetadataTypeDAO.getCustomMetaDataByDymanicQuery(
                fields,
                customMetaDataName,
                whereClause,
                null,
                null,
                null
            );
            if (
                metadataList.isEmpty() ||
                String.isBlank(metadataList[0].Action_Values__c)
            ) {
                return null;
            }
            List<LPI_NewVisitRecord.SelectOptionWrapper> optionsList = new List<LPI_NewVisitRecord.SelectOptionWrapper>();
            optionsList.add(
                new LPI_NewVisitRecord.SelectOptionWrapper('None', 'None')
            );
            for (String action : metadataList[0].Action_Values__c.split(';')) {
                optionsList.add(
                    new LPI_NewVisitRecord.SelectOptionWrapper(
                        action,
                        action,
                        action
                    )
                );
            }
            
            return optionsList;
        } catch (Exception ex) {
            LPI_ExceptionManager.logException(
                'LPI_TaskController',
                'getActionValuesByBoard',
                ex
            );
            throw new LPI_Exception(ex.getMessage());
        }
    }

    
    /** 
     * @author                      : MTX Group Product Team
     * @since                       : 22nd Aug, 2023   
     * @description                 : This method is used to create Violation Enforcement Action related tasks
     * @param jsonData              : String  
     * @return                      : String 
     * @last modified by            : MTX Group Product Team
     * @last modified date          :  
     * @modified details            :  
     */
    @AuraEnabled
    public static String createVeaTaskRecord(String jsonData) {
       try {
            if (String.isBlank(jsonData)) {
                return null;
            }
            LPI_Wrapper.ViolationEnforcementActionWrapper wrapper = (LPI_Wrapper.ViolationEnforcementActionWrapper) JSON.deserializeStrict(
                jsonData,
                LPI_Wrapper.ViolationEnforcementActionWrapper.class
            );
            if(String.isBlank(wrapper.startDate) || String.isBlank(wrapper.endDate) || String.isBlank(wrapper.frequency)){
                return 'false';
            }
            List<Task> tasksToInsertList = new List<Task>();
            String frequency = wrapper.frequency;
            Date dueDate = (frequency == DAILY || Date.valueOf(wrapper.endDate) == Date.valueOf(wrapper.startDate)) ? 
                Date.valueOf(wrapper.startDate).addDays(-1) : Date.valueOf(wrapper.startDate);
            Date startDate = Date.valueOf(wrapper.startDate);
            while(dueDate < Date.valueOf(wrapper.endDate)){
                if(frequency == MONTHLY){
                    Integer numberOfDays = Date.daysInMonth(startDate.year(), startDate.month());
                    dueDate = Date.newInstance(startDate.year(), startDate.month(), numberOfDays);
                }else if(frequency == WEEKLY){
                    dueDate = startDate.toStartofWeek().addDays(7);
                }else if(frequency == ANNUALLY){
                    dueDate = Date.newInstance(startDate.year(), 12, 31);    
                }else if(frequency == QUARTERLY){
                    Integer period = (startDate.month()-1)/ 3 + 1;
                    Integer endMonth = period * 3 ;
                    dueDate = Date.newInstance(startDate.Year(),endMonth, Date.daysInMonth(startDate.year(), endMonth));
                }else if(frequency == SEMI_ANNUALLY){
                    Integer semiAnnualPeriod = (startDate.month() <= 6) ? 1 : 2;
                    Integer lastMonthofPeriod = (semiAnnualPeriod == 1) ? 6 : 12;
                    dueDate = Date.newInstance(startDate.year(), lastMonthofPeriod, Date.daysInMonth(startDate.year(), lastMonthofPeriod));
                }else if(frequency == DAILY){
                    dueDate = startDate;
                }else{
                    break;
                }
                dueDate = Date.valueOf(wrapper.endDate) < dueDate ? Date.valueOf(wrapper.endDate) : dueDate;
                Task taskRec = new Task();
                taskRec.OwnerId = UserInfo.getUserId();
                taskRec.WhatId = wrapper.id;
                taskRec.RecordTypeId = TASK_COMPLAINT_REC_TYPE_ID;
                taskRec.Subject = wrapper.type + '-' + frequency + '-' + dueDate.format(); 
                taskRec.ActivityDate = dueDate;
                tasksToInsertList.add(taskRec);
                startDate = dueDate.addDays(1);
                
            }
            List<Notification__c> portalNotificationList = new List<Notification__c>();
            Map<String, String> portalreplaceTextMap = new Map<String, String>();
            Portal_Notification_Message__mdt metaDataRecForPortal = LPI_CustomMetadataTypeDAO.getAllPortalNotificationByDeveloperNames(
				new Set<String>{ 'Notification_for_a_Assigned_Task' }
			)
			?.get(0);

            Set<Id> taskIdSet = new Set<Id>();
            if(!tasksToInsertList.isEmpty()){
                Database.DMLOptions dmlOptions = new Database.DMLOptions();
                dmlOptions.EmailHeader.triggerUserEmail = true;
                Database.insert(tasksToInsertList, dmlOptions, AccessLevel.USER_MODE);
                for (Task task : tasksToInsertList) {
                    taskIdSet.add(task.Id);
                }
            }
           
            if (taskIdSet != null && !(taskIdSet.isEmpty())) {
                String fields = 'Id,Board_Name__c,Status, ActivityDate,Subject,Account.OwnerId,AccountId,Account.Buisness_Email__c,Account.IsPersonAccount,Account.PersonEmail,Account.Name,Description,Action__c,TYPEOF What WHEN ViolationEnforcementAction THEN Violation.Case__r.Case_Number__c ,Violation.Case__r.License_Type__c,Violation.Case__r.Account.Name END ';
                String whereClause =
                    'Id IN ' +
                    LPI_ServiceUtility.getStringValuesBySet(taskIdSet);
                List<Task> taskList = LPI_TaskDao.getTaskByDymanicQuery(
                    fields,
                    whereClause,
                    null,
                    null,
                    null
                );
                 
                if(!taskList.isEmpty()){
                    for (Task taskinfo : taskList) {
                        if(taskinfo.What instanceof ViolationEnforcementAction) {
                            ViolationEnforcementAction caseRec = (ViolationEnforcementAction) taskinfo.What;
                            portalreplaceTextMap.put('[Case_Number]', caseRec?.Violation.Case__r.Case_Number__c);
                        }
                        portalreplaceTextMap.put('[Assigned_Task_Portal_User]', taskinfo.Account.Name);
                        portalreplaceTextMap.put('[Task_Description]', 'Task');
                        Notification__c portalNoti = LPI_ServiceUtility.createPortalNotificationRecord(
                            metaDataRecForPortal,
                            true,
                            portalreplaceTextMap,
                            null,
                            taskinfo.AccountId
                        );
                        portalNotificationList.add(portalNoti);
                    }
                }
                if(!portalNotificationList.isEmpty()){
					LPI_DML.doInsert(portalNotificationList);
				}
            }


            return 'true';
        }
        catch (Exception ex) {
                LPI_ExceptionManager.logException(
                    'LPI_TaskController',
                    'createVeaTaskRecord',
                    ex
                );
                throw new LPI_Exception(ex.getMessage());
            }      
    }
}