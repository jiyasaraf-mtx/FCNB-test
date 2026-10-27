/**
 * @author                      : MTX Group Product Team
 * @since                       : 11/18/2022
 * @description                 : Class used for notification section on portal
 * @last modified by            : MTX Group Product Team
 * @last modified date          : 09-09-2026
 * @modified details            : Added RMI IndividualApplication fetching and submission logic
 */
public with sharing class LPI_NeedYourAttention {
    private static final String ROLE_PRIMARY_SUPERVISOR = 'Primary Supervisor';
    private static final String ROLE_OWNER = 'Owner';
    
    /**
     * @author                      : MTX Group Product Team
     * @since                       : 11/18/2022
     * @description                 : fetch Portal Notifications and RMI Applications
     * @return                      : List<Notification__c>
     */
    @AuraEnabled
    public static List<Notification__c> getPortalNotification(String accId, String language) {
        try {
            Set<Id> accountIdsSet = new Set<Id>();
            if (String.isNotBlank(accId) && accId.startsWith('001')) {
                accountIdsSet.add((Id) accId);
            } else {
                List<User> u = LPI_UserDao.getCurrentUserRecord();
                if (u.size() > 0 && u[0].AccountId != null) {
                    accountIdsSet.add(u[0].AccountId);
                } 
            }

            List<Notification__c> resultList = new List<Notification__c>();

            if (!accountIdsSet.isEmpty()) {
                // 1. Fetch regular notifications
                List<Notification__c> portalNotifs = LPI_PortalNotificationDAO.getAllPortalNotificationByAccountId(accountIdsSet);
                if (portalNotifs != null && !portalNotifs.isEmpty()) {
                    resultList.addAll(portalNotifs);
                }

                // 2. Fetch IndividualApplication records requiring more info
                List<IndividualApplication> rmiApps = [
                    SELECT Id, Name, Status, Insurer_Comments__c, Real_Estate_Salesperson_Comments__c, License_Type_Name__c
                    FROM IndividualApplication
                    WHERE AccountId IN :accountIdsSet
                      AND Status IN ('Agency Require More Info', 'More Info Require')
                    ORDER BY LastModifiedDate DESC
                ];

                for (IndividualApplication app : rmiApps) {
                    // In-memory Notification__c only — never assign IndividualApplication Id
                    // onto Notification__c.Id (causes "Invalid id value for this SObject type").
                    Notification__c notif = new Notification__c();

                    String comments = (app.License_Type_Name__c == 'Individual Insurance Agent')
                        ? app.Insurer_Comments__c
                        : app.Real_Estate_Salesperson_Comments__c;

                    if (String.isBlank(comments)) {
                        comments = 'No comments provided.';
                    }

                    // Stamp English; display-time translator supplies FR when requested.
                    notif.Description__c = '<b>Application Number: ' + app.Name + '</b><br/>Comments: ' + comments;
                    notif.Button_Label__c = 'Add More Info';
                    notif.Type__c = 'RMI_Application';
                    notif.Icon_Name__c = 'warning.svg';
                    notif.Side_Color__c = '#ff9800';

                    Map<String, Object> paramMap = new Map<String, Object>{
                        'appId' => String.valueOf(app.Id),
                        'appNumber' => app.Name,
                        'comments' => comments,
                        'licenseType' => app.License_Type_Name__c
                    };
                    notif.Url_Param_Json__c = JSON.serialize(paramMap);

                    resultList.add(notif);
                }
            }

            return LPI_PortalNotificationTranslator.translate(resultList, language);
        } catch (Exception e) {
            LPI_ExceptionManager.logException(
                'LPI_NeedYourAttention',
                'getPortalNotification',
                e
            );
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * @description Submit applicant comments and additional documents for an RMI application
     * @param applicationId
     * @param applicantComments
     * @param contentDocumentIds
     */
    @AuraEnabled
    public static void submitMoreInfo(String applicationId, String applicantComments, List<String> contentDocumentIds) {
        try {
            if (String.isBlank(applicationId)) {
                throw new AuraHandledException('Application ID is required.');
            }

            List<IndividualApplication> apps = [
                SELECT Id, Status, License_Type_Name__c, Description
                FROM IndividualApplication
                WHERE Id = :applicationId
                LIMIT 1
            ];

            if (apps.isEmpty()) {
                throw new AuraHandledException('Application record not found.');
            }

            IndividualApplication ia = apps[0];
            // Update status for both Real Estate Salesperson and Individual Insurance Agent
            ia.Status = 'Information Submitted';

            if (String.isNotBlank(applicantComments)) {
                String timestamp = String.valueOf(Datetime.now().format('dd MMM yyyy HH:mm'));
                String formattedComment = '[' + timestamp + '] Applicant Response: ' + applicantComments;
                ia.Description = String.isBlank(ia.Description) ? formattedComment : ia.Description + '\n' + formattedComment;
            }

            update ia;

            // Create Application_Document__c records and link ContentDocumentLinks if documents were uploaded
            if (contentDocumentIds != null && !contentDocumentIds.isEmpty()) {
                List<Application_Document__c> appDocsToInsert = new List<Application_Document__c>();
                for (String docId : contentDocumentIds) {
                    Application_Document__c appDoc = new Application_Document__c();
                    appDoc.Individual_Application__c = applicationId;
                    appDoc.Document_Name__c = 'Additional Information Document';
                    appDoc.Status__c = 'Submitted';
                    appDocsToInsert.add(appDoc);
                }
                insert appDocsToInsert;

                List<ContentDocumentLink> cdlsToInsert = new List<ContentDocumentLink>();
                for (Integer i = 0; i < appDocsToInsert.size(); i++) {
                    ContentDocumentLink cdl = new ContentDocumentLink();
                    cdl.ContentDocumentId = contentDocumentIds[i];
                    cdl.LinkedEntityId = appDocsToInsert[i].Id;
                    cdl.ShareType = 'V';
                    cdl.Visibility = 'AllUsers';
                    cdlsToInsert.add(cdl);
                }
                insert cdlsToInsert;
            }
        } catch (Exception e) {
            LPI_ExceptionManager.logException(
                'LPI_NeedYourAttention',
                'submitMoreInfo',
                e
            );
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * @author                      : MTX Group Product Team
     * @since                       : September 7, 2023
     * @description                 : Sends Email Notifications to Applicant by Primary Supervisor(s)
     */
    private static void sendNotificationsToApplicantBasedOnStatusBySupervisor(IndividualApplication iaRec) {
        try {
            Id acrAccId;
            List<String> regAuthNameList = new List<String>();
            List<String> typeList = new List<String>();
            List<String> subTypeList = new List<String>();
            List<LPI_Wrapper.NotificationEmailWrapper> notificationEmailWrapperList = new List<LPI_Wrapper.NotificationEmailWrapper>();
            String fields = 'Id, License_Type_Name__c, LicenseType.Name, ApplicationType, Amendment_Type__c, Supervisor_ACR_Id__c, ' 
                                + 'LicenseType.Email_Specifications_Final__c';
            String whereClauseVar = 'Id = \'' + String.escapeSingleQuotes(iaRec.Id) + '\'' 
                                        + ' AND ApplicationType = \'New\' AND Supervisor_ACR_Id__c != null';
            List<IndividualApplication> iaRecList = new LPI_IndividualApplicationDAO.LPI_DAO_IndividualApptWithoutSecurity().
                                                    getIndividualApplicationByDymanicQuery(fields, whereClauseVar, '1', null, null);
            if (!iaRecList.isEmpty()) {
                Map<Id, IndividualApplication> mapOfAppWithACRId = new Map<Id, IndividualApplication>();
                Map<String, Object> boardSignatureMap = new Map<String, Object>();
                Map<String, String> replaceTextMap = new Map<String, String>();
                boardSignatureMap = (Map<String, Object>) JSON.deserializeUntyped(
                                            String.valueOf(iaRecList[0].LicenseType.Email_Specifications_Final__c));
                acrAccId = iaRecList[0].Supervisor_ACR_Id__c;
                mapOfAppWithACRId.put(iaRecList[0].Supervisor_ACR_Id__c, iaRecList[0]);
                regAuthNameList.add(iaRecList[0].License_Type_Name__c);
                typeList.add(iaRecList[0].ApplicationType);
                subTypeList.add(iaRecList[0].Amendment_Type__c);
                String uniqueKey = '';
                List<String> uniqueList = new List<String>();
                replaceTextMap.put('Portal_Link', System.Label.Site_Url);
                replaceTextMap.put('Board_Email', String.isNotBlank((String)boardSignatureMap.get('boardEmail')) ? 
                                                                                (String)boardSignatureMap.get('boardEmail') : '');
                replaceTextMap.put('Board_PO_box', String.isNotBlank((String)boardSignatureMap.get('boardPoBox')) ? 
                                                                                (String)boardSignatureMap.get('boardPoBox') : '');
                replaceTextMap.put('Board_Name', String.isNotBlank((String) boardSignatureMap.get('boardName')) ? 
                                                                                (String) boardSignatureMap.get('boardName') : '');
                Map<String, String> urlParameter = new Map<String, String>();
                Map<String, Notification_Message__mdt> notificationMessageMap = new Map<String, Notification_Message__mdt>();
                String key = '';
                if (!regAuthNameList.isEmpty() && !typeList.isEmpty() && !subTypeList.isEmpty()) {
                    notificationMessageMap = LPI_ServiceUtility.fetchNotificationMetaDataRecord(regAuthNameList, typeList, 
                                                                                                    subTypeList, uniqueList);
                }
                List<Business_Relationships__c> acrConList = new List<Business_Relationships__c>();
                fields = 'Id, Related_To__c, Related_To__r.PersonEmail, Related_From__r.Name';
                String whereClause = 'Id = \'' + String.escapeSingleQuotes(acrAccId) + '\''
                                        + ' AND  Roles__c = \'' + ROLE_PRIMARY_SUPERVISOR + '\'';
                LPI_BusinessRelationshipDAO.LPI_BusinessRelationshipsWithoutSharingDAO getAcrDetails = 
                    new LPI_BusinessRelationshipDAO.LPI_BusinessRelationshipsWithoutSharingDAO();
                IndividualApplication app;
                for (Business_Relationships__c acr : getAcrDetails.getBusinessRelationshipsByDymanicQuery(fields, whereClause, '1', 
                                                                                                                null, null)) {
                    if (acr.Related_To__c != null && acr.Related_To__r.PersonEmail != null) {
                        app = mapOfAppWithACRId.get(acr.Id);
                        key = LPI_ServiceUtility.createKeyForMetaDataMap(app.LicenseType.Name, app.ApplicationType, 
                                                                                    app.Amendment_Type__c, uniqueKey);
                        replaceTextMap.put('License_Type', app.LicenseType.Name);
                        replaceTextMap.put('Supervisor_Name', acr.Related_From__r.Name);
                        urlParameter.put('Id', app.Id);
                        String emailBody = notificationMessageMap.get(key).Description__c;

                        if (replaceTextMap != null) {
                            for (String key1 : replaceTextMap.keySet()) {
                                emailBody = emailBody.replaceAll('\\[' + key1 + '\\]', replaceTextMap.get(key1));
                            }
                        }

                        if (notificationMessageMap.containsKey(key)) {
                            LPI_Wrapper.NotificationEmailWrapper notifcationWrapper = new LPI_Wrapper.NotificationEmailWrapper();
                            notifcationWrapper.templateName = notificationMessageMap.get(key).Template_Name__c;
                            notifcationWrapper.subject = notificationMessageMap.get(key).Title__c;
                            notifcationWrapper.description = emailBody;
                            notifcationWrapper.accountId = acr.Related_To__c;
                            notifcationWrapper.recipientEmail = acr.Related_To__r.PersonEmail;
                            notifcationWrapper.replaceTextMap = replaceTextMap;
                            notificationEmailWrapperList.add(notifcationWrapper);
                        }
                    }
                }
                if (!notificationEmailWrapperList.isEmpty()) {
                    LPI_ServiceUtility.createNotificationRecords(notificationEmailWrapperList);
                }
            }
        } 
        catch (Exception ex) {
            LPI_ExceptionManager.logException('LPI_NeedYourAttention', 'sendNotificationsToApplicantBasedOnStatusBySupervisor', ex);
        }
    }

    /**
    * @description Create PAR Record
    */
    @AuraEnabled
    public static string createPARRecord(Map<String, Object> inputMap) {
        String notificationId = (String) inputMap.get('notificationId');
        try {
            Map<String, Object> resultMap = LPI_ApplicationFlowUtility.createPARRecord(
                inputMap,
                null
            );
            if (notificationId != null) {
                updatePortalNotiifcationWithResolved(notificationId);
            }
            if (resultMap != null) {
                return resultMap.containsKey('parRec')
                    ? ((PreliminaryApplicationRef) resultMap.get('parRec'))
                          .SavedApplicationUrl
                    : 'Error';
            } else {
                return 'Error';
            }
        } catch (Exception e) {
            LPI_ExceptionManager.logException(
                'LPI_NeedYourAttention',
                'createPARRecord',
                e
            );
            throw new AuraHandledException(e.getMessage() + e.getLineNumber());
        }
    }

    /**
     * @description Updates Amendment approval date on Application record
     */
    @AuraEnabled
    public static String approveAmendment(Map<String, Object> inputMap) {
        try {
            String applicationId = (String) inputMap.get('Id');
            String notificationId = (String) inputMap.get('notificationId');
            IndividualApplication application = new LPI_IndividualApplicationDAO.LPI_DAO_IndividualApptWithoutSecurity()
                .getindividualApplicationDetails(applicationId);
            IndividualApplication updatedApplication;

            if (
                LPI_LiteralConstant.PAR_AMENDMENT_SUBTYPE_STATUS_CHANGE.endsWithIgnoreCase(
                    application.Amendment_Type__c
                ) &&
                (LPI_LiteralConstant.BROKER_SALESPERSON.endsWithIgnoreCase(
                    application.SavedApplicationRef.Change_Status_to__c
                ) ||
                LPI_LiteralConstant.SALESPERSON.endsWithIgnoreCase(
                    application.SavedApplicationRef.Change_Status_to__c
                ))
            ) {
                updatedApplication = new IndividualApplication();
                updatedApplication.Id = application.Id;
                
                updatedApplication.ApprovedDate = DateTime.parse(
                    System.Now().format()
                );
                if (
                    LPI_LiteralConstant.PROF_CORP_BROKER_SALESPERSON.equalsIgnoreCase(
                        application.LicenseType.Name
                    ) ||
                    LPI_LiteralConstant.PROF_CORP_SALESPERSON.equalsIgnoreCase(
                        application.LicenseType.Name
                    )
                ) {
                    updatedApplication.Status = LPI_LiteralConstant.IA_APPROVED_STATUS;
                }
            }
            if (
                LPI_LiteralConstant.PAR_AMENDMENT_SUBTYPE_STATUS_CHANGE.endsWithIgnoreCase(
                    application.Amendment_Type__c
                ) &&
                (LPI_LiteralConstant.BROKER_ASSOCIATE.endsWithIgnoreCase(
                    application.SavedApplicationRef.Change_Status_to__c
                ) ||
                LPI_LiteralConstant.BROKER_OFFICER.endsWithIgnoreCase(
                    application.SavedApplicationRef.Change_Status_to__c
                ) ||
                LPI_LiteralConstant.BROKER_PARTNER.endsWithIgnoreCase(
                    application.SavedApplicationRef.Change_Status_to__c
                ))
            ) {
                updatedApplication = new IndividualApplication();
                updatedApplication.Id = application.Id;
               
                updatedApplication.ApprovedDate = DateTime.parse(
                    System.Now().format()
                );
            }
            if (updatedApplication != null) {
                LPI_WithoutSharingUtility.updateSObjectRecord(
                    updatedApplication
                );
            }
            if (!String.isEmpty(notificationId)) {
                updatePortalNotiifcationWithResolved(notificationId);
            }
            return application.SavedApplicationRef.SavedApplicationUrl;
        } catch (Exception e) {
            LPI_ExceptionManager.logException(
                'LPI_NeedYourAttention',
                'approveAmendment',
                e
            );
            throw new AuraHandledException(e.getMessage());
        }
    }

    private static void updatePortalNotiifcationWithResolved(Id portId) {
        LPI_DML.doUpdate(
            new Notification__c(Id = portId, Is_Resolved__c = true)
        );
    }

    @AuraEnabled
    public static void acknowlegePortalNotifcation(String notificationId) {
        try {
            if (!String.isEmpty(notificationId)) {
                updatePortalNotiifcationWithResolved(notificationId);
            }
        } catch (Exception e) {
            LPI_ExceptionManager.logException(
                'LPI_NeedYourAttention',
                'acknowlegePortalNotifcation',
                e
            );
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static String getURLtoNavigate(Map<String, Object> inputMap) {
        String parId;
        String returnUrl = 'Error';
        try {
            if (inputMap.containsKey('parId')) {
                parId = (String) inputMap.get('parId');
            }
            if (parId != null) {
                String fields = ' Id, SavedApplicationUrl ';
                String whereClause =
                    'Id= \'' +
                    String.escapeSingleQuotes(parId) +
                    '\'';
                LPI_PreliminaryApplicationRefDAO.LPI_PreliminaryApplicationRefWithoutSharingDAO newParSharing = new LPI_PreliminaryApplicationRefDAO.LPI_PreliminaryApplicationRefWithoutSharingDAO();
                List<PreliminaryApplicationRef> parList = newParSharing.getPreliminaryApplicationRefByDymanicQuery(
                    fields,
                    whereClause,
                    null,
                    null,
                    null
                );
                if (
                    !parList.isEmpty() &&
                    parList[0].SavedApplicationUrl != null &&
                    inputMap.containsKey('acrId')
                ) {
                    returnUrl =
                        String.valueOf(parList[0].SavedApplicationUrl) +
                        '&c__acrId=' +
                        String.valueOf(inputMap.get('acrId'));
                }
            }
            return returnUrl;
        } catch (Exception e) {
            LPI_ExceptionManager.logException(
                'LPI_NeedYourAttention',
                'getURLtoNavigate',
                e
            );
            throw new AuraHandledException(e.getMessage());
        }
    }
}