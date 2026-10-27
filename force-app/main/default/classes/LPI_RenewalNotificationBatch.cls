/**
 * @author                      : Nitesh Garg
 * @since                       : 21-10-2022
 * @description                 : Batch Class Used to send Email Renewal Notification(Scheduled at every night)
 * @last modified by            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @last modified date          : 
 * @modified details            : 
 */
global with sharing class LPI_RenewalNotificationBatch implements Database.Batchable<sObject>, Schedulable, Database.Stateful {
    
    global Set<String> metaDataAPINameSet;
    global  List<Notification_Message__mdt> notificationMessageList;
    List<Notification__c> notificationsInserted = new List<Notification__c>();
    // Added by kirti S-55383,55380
	Set<String> restrictNotificationlicenseSubStatusSet = new Set<String>{
        'Non-Renew',
        'Non-Practicing'
    };
    // Ended by kirti S-55383,55380
    private static final Set<Integer> FEB_END_DAYS_SET = new Set<Integer>{
		28,
		29
	};
	
    /**
     * @author                      : Nitesh Garg
     * @since                       : 
     * @description                 : Constructor to initialize/Assign notificationMessageList
     */
    global LPI_RenewalNotificationBatch(){
            metaDataAPINameSet = new Set<String>{LPI_LiteralConstant.MetaData_Renewal_Is_Due_Reminder_90_60_30,
            LPI_LiteralConstant.MetaData_License_Expired_Notification,
            LPI_LiteralConstant.MetaData_License_Is_In_Renewal_Notification,
            LPI_LiteralConstant.MetaData_License_Renewal_Elapsed_Notification
          };
          notificationMessageList = LPI_CustomMetadataTypeDAO.getAllNotificationByDeveloperNames(
          							metaDataAPINameSet);
    }
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator('Select Id,RegulatoryAuthorizationType.Email_Specifications_Final__c,RegulatoryAuthorizationType.Authorisation_Type__c,RegulatoryAuthorizationType.IssuingDepartment.Renewal_Notification_Periods__c,PeriodEnd,RegulatoryAuthorizationType.Late_Renewal_Allowed__c,Contact.Name,Contact.Email,Name,Contact.AccountId,AccountId,Board_Name__c, Number_of_Renewal_Notifications_sent__c from BusinessLicense WHERE RegulatoryAuthorizationTypeId != null ' + 
                                        'AND PeriodEnd != null AND (PeriodEnd = NEXT_90_DAYS or PeriodEnd <= TODAY ) AND (Status =\'Active\' OR Status =\'Inactive\') AND License_Sub_status__c NOT IN '+LPI_ServiceUtility.getStringValuesByStringSet(restrictNotificationlicenseSubStatusSet));
    }
    /**
     * @author                      : Nitesh Garg
     * @since                       : 
     * @description                 : Execute Method
     * @return                      : 
     * @last modified by            : ChangeMeIn@UserSettingsUnder.SFDoc
     * @last modified date          : 
     * @modified details            : 
     */
    global void execute(Database.BatchableContext bc, List<BusinessLicense> businessLicenseRecordsList) {
        //List<Notification__c> notificationToInsert = new  List<Notification__c>();
        List<LPI_Wrapper.NotificationEmailWrapper> notificationEmailWrapperList = new List<LPI_Wrapper.NotificationEmailWrapper>();   
        Map<String,String> replaceTextMap = new Map<String,String>();
        Map<String,Notification_Message__mdt> notificationMessageMap = new Map<String,Notification_Message__mdt>();
        String metaDataApiName;
        String metaDataApiNameWithInLateRenewal;
        Date dueDate = Date.Today();
        //Start - Added by Nitish (T-55874)
        List<BusinessLicense> blListToUpdate = new List<BusinessLicense>();
        //End - Added by Nitish (T-55874)
        if(!businessLicenseRecordsList.isEmpty()){
            //Creating Map for Notification List
            for(Notification_Message__mdt notiRec : notificationMessageList){
                notificationMessageMap.put(notiRec.DeveloperName,notiRec);
            }
            Map<String,BusinessLicense> accountIdToBlMap = new Map<String,BusinessLicense>();
            Map<Id,Map<String,String>> blIdToAccountEmailMap = new Map<Id,Map<String,String>>();
            for(BusinessLicense bLRec : businessLicenseRecordsList){
                if(bLRec.RegulatoryAuthorizationType.Authorisation_Type__c == LPI_LiteralConstant.BUSINESSLICENSE_APPTYPE && String.isNotBlank(bLRec.AccountId)){
                    accountIdToBlMap.put(bLRec.AccountId,bLRec);
                }
            }
            if(!accountIdToBlMap.isEmpty()){
                blIdToAccountEmailMap =  LPI_ServiceUtility.getAccountForBusinessNotification(accountIdToBlMap,true);
            } 
            //Travesing the businessLicenseRecordsList to send notification 
            for(BusinessLicense bLRec : businessLicenseRecordsList){
                if(bLRec.PeriodEnd != null)  {
                    metaDataApiName = '';
                    metaDataApiNameWithInLateRenewal = '';
                    Date periodEndDate = date.newinstance(bLRec.PeriodEnd.year(), bLRec.PeriodEnd.month(), bLRec.PeriodEnd.day());
                    Integer noOfDays = dueDate.daysBetween(periodEndDate);
                    
                        replaceTextMap = new Map<String,String>();
                        replaceTextMap.put('Portal_Link',System.Label.Site_Url);
                        replaceTextMap.put('Licensee_Number',bLRec.Name);
                        //replaceTextMap.put('Remaining_Days',(String)dueDate.daysBetween(periodEndDate));
                        Map<String, Object> boardSignatureMap = String.isNotBlank(bLRec.RegulatoryAuthorizationType.Email_Specifications_Final__c) ?
                        (Map<String, Object>) JSON.deserializeUntyped(
							String.valueOf(bLRec.RegulatoryAuthorizationType.Email_Specifications_Final__c)
						) : new Map<String, Object>();
                        replaceTextMap.put('Board_Name',String.isNotBlank((String) boardSignatureMap.get('boardName'))? (String) boardSignatureMap.get('boardName'): '');
                        replaceTextMap.put('Board_Email_MODPR',String.isNotBlank((String) boardSignatureMap.get('boardEmail'))? (String) boardSignatureMap.get('boardEmail'): '');
                        replaceTextMap.put('Board_Email_MO_DPR',String.isNotBlank((String) boardSignatureMap.get('boardEmail'))? (String) boardSignatureMap.get('boardEmail'): '');
                        replaceTextMap.put('Board_PO_box',String.isNotBlank((String) boardSignatureMap.get('boardPoBox'))? (String) boardSignatureMap.get('boardPoBox'): '');
                        
                        
                        
                        if(noOfDays == -1){//Check for Expire license
                            metaDataApiName = LPI_LiteralConstant.MetaData_License_Expired_Notification;
                            replaceTextMap.put('Expiry_Date', bLRec.PeriodEnd?.format('MM/DD/YYYY'));
                            if(bLRec.RegulatoryAuthorizationType.Late_Renewal_Allowed__c != null && bLRec.RegulatoryAuthorizationType.Late_Renewal_Allowed__c != 0){
                                Date lateRenewalAllowedDate = periodEndDate.addMonths(Integer.valueOf(bLRec.RegulatoryAuthorizationType.Late_Renewal_Allowed__c));
                                if((periodEndDate.month() == 2 && FEB_END_DAYS_SET.contains(periodEndDate.day())) || periodEndDate.day() == date.daysInMonth(periodEndDate.year(),periodEndDate.month())){
                                    lateRenewalAllowedDate = lateRenewalAllowedDate.addMonths(1).toStartOfMonth().addDays(-1);
                                }
                                noOfDays = dueDate.daysBetween(lateRenewalAllowedDate); //they have late renewal months days to renew (for this first adding those months and then calculating days between)
                                metaDataApiNameWithInLateRenewal = LPI_LiteralConstant.MetaData_License_Is_In_Renewal_Notification;
                            }
                        }else if(noOfDays < -1 && (bLRec.RegulatoryAuthorizationType.Late_Renewal_Allowed__c != null && bLRec.RegulatoryAuthorizationType.Late_Renewal_Allowed__c != 0)){//Check for period is in late renewal
                            //Change of addDays to addMonths
                            Date lateRenewalAllowedDate = periodEndDate.addMonths(Integer.valueOf(bLRec.RegulatoryAuthorizationType.Late_Renewal_Allowed__c));
                                noOfDays = dueDate.daysBetween(lateRenewalAllowedDate);
                                if((periodEndDate.month() == 2 && FEB_END_DAYS_SET.contains(periodEndDate.day())) || periodEndDate.day() == date.daysInMonth(periodEndDate.year(),periodEndDate.month())){
                                    lateRenewalAllowedDate = lateRenewalAllowedDate.addMonths(1).toStartOfMonth().addDays(-1);
                                }
                                if(noOfDays == -1){
                                    metaDataApiName = LPI_LiteralConstant.MetaData_License_Renewal_Elapsed_Notification;
                                }else{
                                    metaDataApiName = '';
                                }
                        }else{
                            if(String.isNotBlank(bLRec.RegulatoryAuthorizationType.IssuingDepartment.Renewal_Notification_Periods__c)){
                                List<String> daysList = bLRec.RegulatoryAuthorizationType.IssuingDepartment.Renewal_Notification_Periods__c.split(',');
                                if(daysList.contains(String.valueOf(noOfDays))){
                                    replaceTextMap.put('Expiry_Date',String.valueOf(noOfDays));
                                    metaDataApiName = LPI_LiteralConstant.MetaData_Renewal_Is_Due_Reminder_90_60_30;
                                }else{
                                    metaDataApiName = '';
                                }
                            }else{
                                metaDataApiName = '';
                            }
                        }
                        
                        if(metaDataApiName != null && metaDataApiName != ''){
                            String emailBody = notificationMessageMap.get(metaDataApiName).Description__c;
					        String Subject = notificationMessageMap.get(metaDataApiName).Title__c;

                           if (replaceTextMap != null) {
                            for (String key : replaceTextMap.keySet()) {
                            emailBody = emailBody.replaceAll('\\[' + key + '\\]', replaceTextMap.get(key));
							Subject =Subject.replaceAll('\\[' + key + '\\]', replaceTextMap.get(key));
							
                              }
                         }
                            if(bLRec.RegulatoryAuthorizationType.Authorisation_Type__c == LPI_LiteralConstant.INDIVIDAULICENSE_APPTYPE){
                                LPI_Wrapper.NotificationEmailWrapper notifcationWrapper = new LPI_Wrapper.NotificationEmailWrapper();
                                notifcationWrapper.accountId = bLRec.Contact.AccountId;
                                notifcationWrapper.recipientEmail = bLRec.Contact.Email;
                                notifcationWrapper.blId = bLRec.Id;
                                notifcationWrapper.templateName = notificationMessageMap.get(metaDataApiName).Template_Name__c;
                                notifcationWrapper.Description = emailBody;
                                notifcationWrapper.Subject = Subject;
                                notifcationWrapper.replaceTextMap = replaceTextMap;
                                notificationEmailWrapperList.add(notifcationWrapper);
                            }else{
                                if(bLRec.RegulatoryAuthorizationType.Authorisation_Type__c == LPI_LiteralConstant.BUSINESSLICENSE_APPTYPE &&
                                blIdToAccountEmailMap.containsKey((String)bLRec.Id)){
                                    for(String accouId : blIdToAccountEmailMap.get((String)bLRec.Id).keySet()){
                                        if (notificationMessageMap.get(metaDataApiName) != null) {
                                            // Create a notification record
                                            LPI_Wrapper.NotificationEmailWrapper notifcationWrapper = new LPI_Wrapper.NotificationEmailWrapper();
                                            notifcationWrapper.accountId = accouId;
                                            notifcationWrapper.recipientEmail = blIdToAccountEmailMap.get((String)bLRec.Id).get(accouId);
                                            notifcationWrapper.blId = bLRec.Id;
                                            notifcationWrapper.Description = emailBody;
                                            notifcationWrapper.Subject = Subject;
                                            notifcationWrapper.templateName = notificationMessageMap.get(metaDataApiName).Template_Name__c;
                                            notifcationWrapper.replaceTextMap = replaceTextMap;
                                            notificationEmailWrapperList.add(notifcationWrapper);
                                        }
                                    }
                                }
                            }
                            //Start - Added by Nitish (T-55874)
                            BusinessLicense bl = new BusinessLicense();
                            bl.Id = bLRec.Id;
                            bl.Number_of_Renewal_Notifications_sent__c = bLRec.Number_of_Renewal_Notifications_sent__c > 0 ? bLRec.Number_of_Renewal_Notifications_sent__c + 1 : 1;
                            blListToUpdate.add(bl);
                            //End - Added by Nitish (T-55874)
                        }
                        //Added this if as we need to create 2 notifications records when license is expired (Expired one, Late Renewal Period)
                        if(metaDataApiNameWithInLateRenewal != null && metaDataApiNameWithInLateRenewal != ''){
                            String emailBody = notificationMessageMap.get(metaDataApiNameWithInLateRenewal).Description__c;
					    String Subject = notificationMessageMap.get(metaDataApiNameWithInLateRenewal).Title__c;

                    if (replaceTextMap != null) {
                        for (String key : replaceTextMap.keySet()) {
                            emailBody = emailBody.replaceAll('\\[' + key + '\\]', replaceTextMap.get(key));
							Subject =Subject.replaceAll('\\[' + key + '\\]', replaceTextMap.get(key));
							
                        }
                    }
                            Map<String, String> replaceTextMapforLateRenewalPeriod = new Map<String, String>();
                            replaceTextMapforLateRenewalPeriod.putAll(replaceTextMap);
                            replaceTextMapforLateRenewalPeriod.put('Expiry_Date',String.valueOf(noOfDays));
                            if(bLRec.RegulatoryAuthorizationType.Authorisation_Type__c == LPI_LiteralConstant.INDIVIDAULICENSE_APPTYPE){
                                LPI_Wrapper.NotificationEmailWrapper notifcationWrapper = new LPI_Wrapper.NotificationEmailWrapper();
                                notifcationWrapper.accountId = bLRec.Contact.AccountId;
                                notifcationWrapper.recipientEmail = bLRec.Contact.Email;
                                notifcationWrapper.blId = bLRec.Id;
                                notifcationWrapper.Description = emailBody;
                                notifcationWrapper.Subject = Subject;
                                notifcationWrapper.templateName = notificationMessageMap.get(metaDataApiNameWithInLateRenewal).Template_Name__c;
                                notifcationWrapper.replaceTextMap = replaceTextMapforLateRenewalPeriod;
                                notificationEmailWrapperList.add(notifcationWrapper);
                            }else{
                                if(bLRec.RegulatoryAuthorizationType.Authorisation_Type__c == LPI_LiteralConstant.BUSINESSLICENSE_APPTYPE &&
                                blIdToAccountEmailMap.containsKey((String)bLRec.Id)){
                                    for(String accouId : blIdToAccountEmailMap.get((String)bLRec.Id).keySet()){
                                        if (notificationMessageMap.get(metaDataApiName) != null) {
                                            LPI_Wrapper.NotificationEmailWrapper notifcationWrapper = new LPI_Wrapper.NotificationEmailWrapper();
                                            notifcationWrapper.accountId = accouId;
                                            notifcationWrapper.recipientEmail = blIdToAccountEmailMap.get((String)bLRec.Id).get(accouId);
                                            notifcationWrapper.blId = bLRec.Id;
                                            notifcationWrapper.Description = emailBody;
                                            notifcationWrapper.Subject = Subject;
                                            notifcationWrapper.templateName = notificationMessageMap.get(metaDataApiNameWithInLateRenewal).Template_Name__c;
                                            notifcationWrapper.replaceTextMap = replaceTextMapforLateRenewalPeriod;
                                            notificationEmailWrapperList.add(notifcationWrapper);
                                        }
                                    }
                                }
                            }
                        } 
                    }
            }
        }
        /* if (notificationToInsert <> null && !notificationToInsert.isEmpty()) {
            Database.insert(notificationToInsert);
        } */
        if (!notificationEmailWrapperList.isEmpty()) {
            notificationsInserted.addAll((List<Notification__c>)LPI_ServiceUtility.createNotificationRecords(notificationEmailWrapperList));
        }
        //Start - Added by Nitish (T-55874)
        if(!blListToUpdate.isEmpty()){
            LPI_DML.doUpdate(blListToUpdate);
        }
        //End - Added by Nitish (T-55874)
    }
    global void finish(Database.BatchableContext bc) {
        Database.executebatch(new LPI_NotifEmailTriggerBatch(notificationsInserted),100);
    }
    global void execute(SchedulableContext SC) {
        // LPI_dailyRunningBatch batchable = new LPI_dailyRunningBatch();
        // database.executebatch(batchable);
    }
}