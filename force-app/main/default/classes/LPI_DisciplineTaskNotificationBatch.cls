/**
 * @author            : Nayana Gupta
 * @description       : This Batch class will create portal notification and send Notification Email for Discipline Requirement Task.
 *                      i)  when the due date for the task is passed by one day
 *                      ii)  when  there is an assigned upcoming task in next 15 days 
 * @since             : 13 May 2024
 * @last modified on  : 05-30-2024
 * @last modified by  : MTX Group Inc
 */


public with sharing class LPI_DisciplineTaskNotificationBatch implements Database.Batchable<sObject>,Schedulable,Database.Stateful {
    // List<Notification__c> portalNotificationToInsert = new List<Notification__c>();
    // List<Notification__c> notificationsInserted = new List<Notification__c>();
    // List<string> uniquefilterList = new List <String> {'pastDueTask','upcomingTask'};
    // List<string> uniquefilterListPortal = new List <String> {'pastDueTaskPortal','upcomingTaskPortal'};
    // public Map<String, Notification_Message__mdt> notificationMessageMap =  LPI_ServiceUtility.fetchNotificationMetaDataRecord(null,null,null,uniquefilterList);   
    // public Map<String, Portal_Notification_Message__mdt> notificationMessageMapPortal =  LPI_ServiceUtility.fetchPortalNotificationMetaDataRecord(null,null,null,uniquefilterListPortal);
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        // String query = 'SELECT Id,Board_Name__c,Status, ActivityDate,Subject,Account.OwnerId,AccountId,Account.Buisness_Email__c,Account.IsPersonAccount,Account.PersonEmail,Account.Name,	Description,Is_Disciplined_Task__c,Action__c,TYPEOF What WHEN ViolationEnforcementAction THEN Violation.Case__r.Case_Number__c ,Violation.Case__r.License_Type__c,Violation.Case__r.Account.Name END FROM Task WHERE Status = \'Open\' and Is_Disciplined_Task__c= true' ;
        // return Database.getQueryLocator(query);
        return null;
    }
    public void execute(Database.BatchableContext bc,List<Task> taskList) {
        // List<LPI_Wrapper.NotificationEmailWrapper> notificationEmailWrapperList = new List<LPI_Wrapper.NotificationEmailWrapper>();
        // List<Task> taskListToItterate = new List<Task>();
        // set<string> lType = new set<String>();
        // Map<String, String> replaceTextMap ;
        // Map<String, String> urlParams;
        // Integer daysDiff;
        // string accName;
        // string caseNumber;
        // string licenseType;
        // Map<String, Object> boardEmail;
        // string senderEmail;
        // Integer daysDifference;
        // Date today = Date.today();
       
       
            // for (Task taskRecord : taskList) {
            //     if(taskRecord.ActivityDate != null){
            //     daysDifference = today.daysBetween(Date.newinstance(taskRecord.ActivityDate.year(),  taskRecord.ActivityDate.month(),  taskRecord.ActivityDate.day()));}
            //     if((daysDifference != -1 && daysDifference != 15) ||  !(taskRecord.What instanceof ViolationEnforcementAction)){
            //           continue;
            //      }   
            //       ViolationEnforcementAction vc = taskRecord.What;
            //         licenseType = vc?.Violation.Case__r.License_Type__c;
            //         if(String.isNotBlank(licenseType)){
            //             lType.add(licenseType);
            //         }
            //         taskListToItterate.add(taskRecord);
            // }

            // if(lType.isEmpty() || taskListToItterate.isEmpty()){
            //     return;
            // }
            // Map<string,String> ratMap = new Map<String, String>();
            // string fields = 'Id,Name,Email_Specifications_Final__c';
            // string whereClause =  'Name IN' + LPI_ServiceUtility.getStringValuesByStringSet(lType);
            // List<RegulatoryAuthorizationType> regAuth =LPI_RegulatoryAuthorizationTypeDAO.getRegulatoryAuthorizationTypeByDymanicQuery(fields, whereClause, null, null, null);
            // for(RegulatoryAuthorizationType ratRec :regAuth){
            //     boardEmail = String.isNotBlank(ratRec.Email_Specifications_Final__c) ?
            //     (Map<String, Object>) JSON.deserializeUntyped(
            //         String.valueOf(ratRec.Email_Specifications_Final__c)
            //     ) : new Map<String, Object>();
            //     senderEmail = (String)boardEmail .get('boardEmail');
            //     ratMap.put(ratRec.Name,senderEmail);
            // }
                     
            // for (Task taskRec : taskListToItterate) {
            //         daysDiff = today.daysBetween(Date.newinstance(taskRec.ActivityDate.year(),  taskRec.ActivityDate.month(),  taskRec.ActivityDate.day()));
            //         replaceTextMap = new Map<String, String>();
            //         urlParams = new Map<String, String>();
            //         Notification__c portalNotification;
                    
                    // replaceTextMap.put('TaskActivityDue',taskRec.ActivityDate != null ? ' ' + 
                    //                String.valueOf(DateTime.newInstance(taskRec.ActivityDate.year(),
                    //                taskRec.ActivityDate.month(), 
                    //                taskRec.ActivityDate.day()).format('MM/dd/yyyy')) : ' ' );
                    // replaceTextMap.put('TaskStatus',taskRec.Status);
                    // replaceTextMap.put('TaskComments', String.isNotBlank(taskRec.Description) ? taskRec.Description:'');
                    // replaceTextMap.put('TaskDescription',String.isNotBlank(taskRec.Subject) ? taskRec.Subject : '');
                       
                    //     ViolationEnforcementAction vc = taskrec.What;
                    //     caseNumber = vc?.Violation.Case__r.Case_Number__c;
                    //     replaceTextMap.put('CaseNumber',caseNumber);
                    //     replaceTextMap.put('Case Number',caseNumber);
                    //     accName = vc?. Violation.Case__r.Account.Name;
                    //     replaceTextMap.put('AssignedTaskPortalUser',String.isNotBlank(accName) ? accName:'');
                    //     replaceTextMap.put('AssignedPortalTaskUser',String.isNotBlank(accName) ? accName:'');
                    //     licenseType = vc?.Violation.Case__r.License_Type__c;
                    //     string board_Email = ratMap.get(licenseType);   
                    //     replaceTextMap.put('Board_Email',board_Email);
                            
                    //      Map<String, String> replaceBellTextMap = new Map<String, String>{
                    //     '[Task_Description]' => String.isNotBlank(taskRec.Subject) ? taskRec.Subject : '',
                    //     '[Case_Number]' => String.isNotBlank(caseNumber) ? caseNumber : '',
                    //     '[Assigned_Task_Portal_User]' => String.isNotBlank(accName) ? accName: '',
                    //     '[Task_Activity_Due]' =>  String.valueOf(DateTime.newInstance(taskRec.ActivityDate.year(),
                    //                         taskRec.ActivityDate.month(), 
            //                                     taskRec.ActivityDate.day()).format('MM/dd/yyyy'))
            //             };

            //         urlParams.put('taskId',taskRec.Id);
            //         LPI_Wrapper.NotificationEmailWrapper notifcationWrapper = new LPI_Wrapper.NotificationEmailWrapper();
            //         notifcationWrapper.accountId = taskRec.AccountId;
            //         notifcationWrapper.taskId = taskRec.Id;
            //         notifcationWrapper.recipientEmail = taskRec.Account.IsPersonAccount?taskRec.Account.PersonEmail: taskRec.Account.Buisness_Email__c;
               
            //         if(daysDiff == -1){
            //             List<Portal_Notification_Message__mdt> notiRec = LPI_CustomMetadataTypeDAO.getAllPortalNotificationByDeveloperName(
            //                 'Notification_for_Past_Due_Task_VEA');
            //             notifcationWrapper.templateName = notificationMessageMap.get('pastDueTask')?.Template_Name__c;
            //             portalNotification =  LPI_ServiceUtility.createPortalNotificationRecord(
            //                 notiRec[0],
            //                 true,
            //                 replaceBellTextMap,
            //                 urlParams,
            //                 taskRec.AccountId
            //                 );  
            //            if (portalNotification != null) {
            //                 //portalNotification.Task_Id__c = taskRec.Id;
            //                 portalNotificationToInsert.add(portalNotification);
            //             }
            //         }
                   
            //         if(daysDiff == 15){
            //             List<Portal_Notification_Message__mdt> notiRecp = LPI_CustomMetadataTypeDAO.getAllPortalNotificationByDeveloperName(
            //                 'Notification_for_Upcoming_VEA_Task');
            //                 notifcationWrapper.templateName = notificationMessageMap.get('upcomingTask')?.Template_Name__c;
            //                 portalNotification =  LPI_ServiceUtility.createPortalNotificationRecord(
            //                     notiRecp[0],
            //                     true,
            //                     replaceBellTextMap,
            //                     urlParams,
            //                     taskRec.AccountId
            //                 ); 
            //                 if (portalNotification != null) {
            //                     //portalNotification.Task_Id__c = taskRec.Id;
            //                     portalNotificationToInsert.add(portalNotification);
            //                 }
            //         }
            //         notifcationWrapper.replaceTextMap = replaceTextMap;
            //         notifcationWrapper.senderEmail = senderEmail;
            //         notificationEmailWrapperList.add(notifcationWrapper);
            // }

            // if (!notificationEmailWrapperList.isEmpty()) {
            //     notificationsInserted.addAll((List<Notification__c>)LPI_ServiceUtility.createNotificationRecords(notificationEmailWrapperList));
            // }

            // if (!portalNotificationToInsert.isEmpty()) {
            //     LPI_WithoutSharingUtility.insertSObjectList(portalNotificationToInsert);
            // }
    }

    public void finish(Database.BatchableContext bc){
       // Database.executebatch(new LPI_NotifEmailTriggerBatch(notificationsInserted),100);
        
    }

    public void execute(SchedulableContext SC) {
      //  Database.executebatch(new LPI_DisciplineTaskNotificationBatch ());
       
    }


}