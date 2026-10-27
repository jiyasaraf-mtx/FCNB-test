/**
 * @description       : Helper class for Push Notification.
 * @author            : Lokendra Singh Jhala
 * @group             :
 * @last modified on  : 05-16-2024
 * @last modified by  : Ayush Dev
 **/
 
 public with sharing class PushTriggerHelper {
   
    /**
     *   @author : Lokendra Singh Jhala
     *   @since : 05-03-2023
     *   @description :This method is sending the push notification to inspector on new visit assignment 
     *   @param : Map<Id, Visit> oldVisitRecords,List<Visit> newVisitRecords
     *   @return : void
     */
    public static void sendNotificationOnVisitAssignment(
        Map<Id, Visit> oldVisitRecords,
        List<Visit> newVisitRecords
    ) {
        //S-48380 - Start
        try {
            //Fetching the record type for Portal Notification record type.
            Id MobileNotificationRecordTypeId = Schema.SObjectType.Notification__c.getRecordTypeInfosByName().get('Mobile Notification').getRecordTypeId();
            List<Notification__c> portalNoticicationInsertList = new List<Notification__c>();
            List<Visit> visitRecList = new List<Visit>();
            Map<Id, String> visitAccountMap = new Map<Id, String>();
            String whereClause;
            // Get all contextIDs
            Set<Id> accountIds = new Set<Id>();
            Set<Id> visitTypeIds = new Set<Id>();
            Map<Id, InspectionType> visitTypeMap = new Map<Id, InspectionType>();
            
            for (Visit visit : newVisitRecords) {
                if(visit.visitTypeId != null){
                    visitTypeIds.add(visit.visitTypeId);
                }
                if(String.isBlank(visit.accountId)){
                    continue;
                }
                accountIds.add(visit.accountId);
            }

            if (!visitTypeIds.isEmpty()) {
                InspectionType[] allVisitTypes = LPI_VisitControllerRestResource.getAllVisitType(visitTypeIds);
                for (InspectionType vTypes : allVisitTypes) {
                    visitTypeMap.put(vTypes.Id, vTypes);
                }
            }


            List<String> fieldsToQuery = new List<String>();
            //getAccountListByDynamicQuery
            if (!accountIds.isEmpty()) {
                //Query Accounts Name
                fieldsToQuery.add('Id');
                fieldsToQuery.add('Name');
                whereClause ='Id IN ' +
                    LPI_ServiceUtility.getStringValuesBySet(accountIds);         
                for (
                    Account account : LPI_AccountDAO.getAccountListByDynamicQuery(
                        fieldsToQuery,
                        whereClause,
                        null,
                        null,
                        null
                    )
                ){
                    visitAccountMap.put(account.Id, account.Name);
                }
            }
            for (Visit visit : newVisitRecords) {

                String visitor = !oldVisitRecords.isEmpty() ? oldVisitRecords.get(visit.Id).VisitorId :null;
                InspectionType objType = visitTypeMap.get(visit.visitTypeId);
                //Enable the notification for routine
                if (
                    visit.VisitorId != null &&
                    visitor != visit.VisitorId && (objType != null) &&
                    (visit.Status__c != LPI_LiteralConstant.Inspection_Status_COMPLETED) && (visit.Status__c != 'Abandoned')
                ) {
                        Map<String, String> data = new Map<String,String>(); 
                        data.put('type','visit_assignment');
                        data.put('visitId',visit.Id);
                        String accountName = String.isBlank(visit.AccountId) ? '' : '('+visitAccountMap.get(visit.AccountId)+')';
                        String description = 'New Inspection '+ visit.Name + accountName +' Assigned! Click here to view details and start the inspection process.';

                        Map<String, String> dataOld = new Map<String,String>(); 
                        dataOld.put('type','visit_assignment');
                        dataOld.put('visitId',visit.Id);
    
                        String descriptionOld = 'Inspection '+ visit.Name + accountName +' has been  unassigned from you! Please re-sync the inspection from the sync tab';

                        sendPushNotification(
                            description, 
                            data, 
                            visit.VisitorId
                            );
                        // Sned Notification when visit unassign from one user to other this notification for old assign visitor
                        sendPushNotification(
                           descriptionOld, 
                           dataOld, 
                           visitor
                           );    

                           
                        //Insert into Portal Notification object. Notification__c
                        if (MobileNotificationRecordTypeId != null){
                            Notification__c notificationObj = new Notification__c();
                            notificationObj.RecordTypeId = MobileNotificationRecordTypeId;
                            notificationObj.Description__c = description;
                            notificationObj.Url_Param_Json__c = JSON.serialize(data);
                            notificationObj.User__c = visit.VisitorId;
                            // notificationObj.Name = 'Inspection Notification';
                            portalNoticicationInsertList.add(notificationObj);


                            Notification__c notificationObjOld = new Notification__c();
                            notificationObjOld.RecordTypeId = MobileNotificationRecordTypeId;
                            notificationObjOld.Description__c = descriptionOld;
                            notificationObjOld.Url_Param_Json__c = JSON.serialize(dataOld);
                            notificationObjOld.User__c = visitor;
                            // notificationObjOld.Name = 'Inspection Notification';
                            portalNoticicationInsertList.add(notificationObjOld);
                        }
                    }
                }
                //Insert all Portal Notifications
                insert portalNoticicationInsertList;
            
        } catch (Exception e) {
            LPI_ExceptionManager.logException(
                'PushTriggerHelper',
                'sendNotificationOnVisitAssignment',
                e
            );
        }
        //S-48380 - End
    }





      /**
     *   @author : Lokendra Singh Jhala
     *   @since : 05-03-2023
     *   @description :This method is sending the push notification to inspector on new visit assignment 
     *   @param : List<Visit> newVisitRecords
     *   @return : void
     */
    public static void sendNotificationOnVisitNote(
        List<ContentDocumentLink> newVisitNotesRecords
    ) {          
        
        //S-48380 - Start
        //Fetching the record type for Portal Notification record type.
        Id MobileNotificationRecordTypeId = Schema.SObjectType.Notification__c.getRecordTypeInfosByName().get('Mobile Notification').getRecordTypeId();
        List<Notification__c> portalNoticicationInsertList = new List<Notification__c>();
        String whereClause,fields;
        try {
            Set<String> contentDocIdSet = new Set<String>();
            Map<String, String> contentDocumentIdtoLinkedEntityId = new Map<String, String>();
            for (ContentDocumentLink cdl : newVisitNotesRecords) {
                // If file is not attached with a RegulatoryAuthorizationType/RegulatoryAuthority record then skip;
                if (cdl.LinkedEntityId.getSObjectType().getDescribe().getName()!= 'Visit') {
                    continue;
                }

                contentDocumentIdtoLinkedEntityId.put(
                    cdl.ContentDocumentId,
                    cdl.LinkedEntityId
                );
            }
            // If no document matches criteria then return
            if (contentDocumentIdtoLinkedEntityId.isEmpty()) {
                return;
            }
            
            fields = 'ID,Title,ContentDocumentId,FileType,CreatedById';
            whereClause =
                'ContentDocumentId IN ' +
                LPI_ServiceUtility.getStringValuesByList(
                    new List<String>(contentDocumentIdtoLinkedEntityId.keySet())
                );
           Map<String, String> contentDocumentIdtoUserId = new Map<String, String>();
            // Fetch content version records by ContentDocumentId to create ContentDistribution records.
            for (
                ContentVersion cv : LPI_ContentVersionDAO.getContentVersionByDymanicQuery(
                    fields,
                    whereClause,
                    null,
                    null,
                    null
                )
            ) {
                contentDocumentIdtoUserId.put(
                    cv.ContentDocumentId,
                    cv.CreatedById
                );
            }

            Map<String, String> linkedEntityIdtoUserId = new Map<String, String>();

            Map<String, Visit> linkedEntityIdtoVisit = new Map<String, Visit>();

            List<String> fieldsToQuery = new List<String>();
           
                //Query Accounts Name
                fieldsToQuery.add('Id');
                fieldsToQuery.add('VisitorId');
                fieldsToQuery.add('Name');
                fieldsToQuery.add('Account.Name');
                whereClause ='Id IN ' + LPI_ServiceUtility.getStringValuesByList(
                    new List<String>(contentDocumentIdtoLinkedEntityId.values())
                ) + 'AND Status__c NOT IN (\'Completed\', \'Abandoned\')';         
                for (
                    Visit visit : LPI_VisitControllerDAO.getVistListByDynamicQuery(
                        fieldsToQuery,
                        whereClause,
                        null,
                        null,
                        null
                    )
                ){
                    linkedEntityIdtoUserId.put(visit.Id, visit.VisitorId);
                    linkedEntityIdtoVisit.put(visit.Id,visit);
                }


                for (String contentKey : contentDocumentIdtoLinkedEntityId.keySet()){

                    if(linkedEntityIdtoUserId.containsKey(contentDocumentIdtoLinkedEntityId.get(contentKey)) && contentDocumentIdtoUserId.containsKey(contentKey)){
                   if(linkedEntityIdtoUserId.get(contentDocumentIdtoLinkedEntityId.get(contentKey)) != contentDocumentIdtoUserId.get(contentKey) ){

                        Map<String, String> data = new Map<String,String>(); 
                        data.put('type','new_note');
                        data.put('visitId',contentDocumentIdtoLinkedEntityId.get(contentKey));
                        data.put('noteId',contentKey);

                        Visit visit = linkedEntityIdtoVisit.get(contentDocumentIdtoLinkedEntityId.get(contentKey));
                        String accountName = String.isBlank(visit.Account.Name) ? '' : '(' + visit.Account.Name + ')';
                        String description = 'New note has been added to the Inspection '+ visit.Name + accountName + '. Click here to view details';
                        
                        sendPushNotification(
                            description, 
                            data, 
                            linkedEntityIdtoUserId.get(contentDocumentIdtoLinkedEntityId.get(contentKey))
                            );

                        //Insert into Portal Notification object. Notification__c
                        if (MobileNotificationRecordTypeId != null){
                            Notification__c notificationObj = new Notification__c();
                            notificationObj.RecordTypeId = MobileNotificationRecordTypeId;
                            notificationObj.Description__c = description;
                            notificationObj.Url_Param_Json__c = JSON.serialize(data);
                            notificationObj.User__c = linkedEntityIdtoUserId.get(contentDocumentIdtoLinkedEntityId.get(contentKey));
                            // notificationObj.Name = 'Visit Notes Notification';
                            portalNoticicationInsertList.add(notificationObj);
                            }
                        }
                    }
                 }
                 //Insert all Portal Notifications
                insert portalNoticicationInsertList;
              } catch (Exception e) {
                            LPI_ExceptionManager.logException(
                                'PushTriggerHelper',
                                'sendNotificationOnVisitNote',
                                e
                            );
                        }
        //S-48380 - End
    }

    /**
     * @author                   Umangshu Chouhan
     * @since                    05-31-2023
     * @description              This method will send push notification to the iOS users using MOPRO_iOS connected app.
     * @param :                  String notificationText
     * @param :                  Map<String, String> data
     * @param :                  Id userId
     */
     public static void sendPushNotification(String notificationText, Map<String, String> data, Id userId) { 
        try {
            // Instantiating a notification
            Messaging.PushNotification msg = new Messaging.PushNotification();
            Map<String, Object> payload = 
                Messaging.PushNotificationPayload.apple(
                    notificationText, '', null, data);

            //now append 'content-available' parameter to aps        
            Map<String, Object> aps = (Map<String, Object>)payload.get('aps');
            aps.put('content-available', 1);  

            // Adding the assembled payload to the notification
            msg.setPayload(payload);
        
            // Adding recipient users to list
            Set<String> users = new Set<String>();
            users.add(userId);
    
            // Sending the notification to the specified app and users.
            // Here we specify the API name of the connected app.  
            msg.send('MOPRO_iOS', users);   
        } catch (Exception e) {
            throw e;
        }
    }
}