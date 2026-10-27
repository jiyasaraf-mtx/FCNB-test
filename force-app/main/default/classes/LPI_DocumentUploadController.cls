global with sharing class LPI_DocumentUploadController implements Callable {
    
    private static final String SEQUENCE = 'Document_Name__c, Sequence__c';

    global Object call(String action, Map<String, Object> args) {
        Map<String, Object> input = (Map<String, Object>) args.get('input');
        Map<String, Object> output = (Map<String, Object>) args.get('output');
        Map<String, Object> options = (Map<String, Object>) args.get('options');
        return invokeMethod(action, input, output, options);
    }

    private Boolean invokeMethod(String methodName, Map<String, Object> inputMap, Map<String, Object> outMap, Map<String, Object> options) {
        Boolean result;
        try{
            if (methodName == 'getApplicationDocumentList') {
                outMap.put('applicationDocumentInfo', getApplicationDocumentList((String) inputMap.get('parId')));
            }
            
            if(methodName == 'downloadFile'){
                outMap.put('outputData',downloadFile((String)options.get('documentId')));
            }

            if(methodName == 'handleFileDelete'){
                outMap.put('outputData',handleFileDelete((String)options.get('documentId'),(String)options.get('sectionName')));
            }

            if(methodName == 'createAdditionalDocument'){
                outMap.put('newAppDocId', createAdditionalDocument((String) inputMap.get('parId')));
            }

            if(methodName == 'saveAdditionalDocument'){
                outMap.put('outputData', saveAdditionalDocument((String)options.get('appDocumentId'),(String)options.get('docName'),(String)options.get('docDesc')));
            }

            result = true;
        } catch (Exception ex) {
            result = false;
            LPI_ExceptionManager.logException('LPI_DocumentUploadController', 'invokeMethod', ex);
        }
        return result;
    }

    /**
    * @author            : Rajeev Roushan
    * @description       : This Method is used to return document list.
    * @Parameters        : String parId
    */
    @AuraEnabled
    public static Map<String,String> getApplicationDocumentList(String parId) {
        try {
            String parFields = 'Id,Type__c,Amendment_Type__c,Business_Name__c,ApplicationType,Name,Contact__r.FirstName,Contact__r.MiddleName,Contact__r.LastName, Is_Supervisor_User__c , Approval_Supervisors_AcrIds__c,Business_License__r.Pre_Licensure_Number__c,Board_Name__c,Regulatory_Authorization_Type__r.IssuingDepartment.Name,Regulatory_Authorization_Type__r.Authorisation_Type__c ,Regulatory_Authorization_Type__r.Profession_Code__c,Contact__r.Suffix,Contact__r.Account.Social_Security_Number__c,Business_License__r.Name,Business_License__r.Legacy_License_Number__c,Regulatory_Authorization_Type__r.Name,BusinessAccountNameId';
            String appDocumentQueryFields = ' Id,Type__c,Board_Name__c,File_Name__c,Onbase_Document_Id__c,Document_Name__c, Description__c ,Preliminary_Application_Reference__c, Business_License_Application__c, Is_Lawful_Presence_Document__c, Is_additional_document_by_portal_user__c, Preliminary_Application_Reference__r.Business_License__r.Pre_Licensure_Number__c,Preliminary_Application_Reference__r.Regulatory_Authorization_Type__r.Name,( SELECT ContentDocument.Title, LinkedEntityId, ContentDocument.FileExtension, ContentDocumentId, Id FROM ContentDocumentLinks Order by ContentDocument.CreatedDate DESC LIMIT 1), Is_Document_Required__c, Help_Text__c,Is_System_Generated__c,(SELECT ID,Application_Document__c, File_Name__c,Onbase_Document_Id__c FROM Application_Document__r) ';
            String appDocumentWhereClause;
            Map<String,String> responseMap = new Map<String,String>();

            Date todayDate = Date.today();
            responseMap.put('documentDate',todayDate.month() + '-' + todayDate.day() + '-' + todayDate.year());
            List<Application_Document__c> applicationDocumentList = new List<Application_Document__c>();
            if (String.isNotBlank(parId)) {
                String parWhere =
                    'Id = \'' +
                    String.escapeSingleQuotes(parId) +
                    '\'';
                List<PreliminaryApplicationRef> parList = LPI_PreliminaryApplicationRefDAO.getPreliminaryApplicationRefByDymanicQuery(
                    parFields,
                    parWhere,
                    '1',
                    null,
                    null
                );
                if (!parList.isEmpty()) {
                    system.debug('parList:- '+parList);
                    String issuingDeptName = (parList[0].Regulatory_Authorization_Type__r != null
                        && parList[0].Regulatory_Authorization_Type__r.IssuingDepartment != null)
                        ? parList[0].Regulatory_Authorization_Type__r.IssuingDepartment.Name
                        : null;
                    responseMap.put('issuingDepartment', issuingDeptName);
                    responseMap.put('authorisationType',parList[0].Regulatory_Authorization_Type__r.Authorisation_Type__c);
                    responseMap.put('licenseTypeName', parList[0].Regulatory_Authorization_Type__r.Name);
                    responseMap.put('Type__c',parList[0].Type__c);
                    appDocumentWhereClause =
                    '(Is_System_Generated__c = true OR(CreatedBy.Profile.Name != \'' + LPI_LiteralConstant.Portal_Profile_Name + '\' OR (CreatedBy.Profile.Name = \'' + LPI_LiteralConstant.Portal_Profile_Name + '\' AND Status__c = \'' + LPI_LiteralConstant.IA_SUBMITTED_STATUS + '\'))) AND Preliminary_Application_Reference__c = \'' +
                    String.escapeSingleQuotes(parId) +
                    '\' AND Application_Document__c = NULL' + 
                    ' AND (Is_Lawful_Presence_Document__c = false OR  (Is_Lawful_Presence_Document__c = true AND Is_Document_Required__c = true AND  Related_Element_Name__c != null)'+ 
                    ' Or ( Is_Lawful_Presence_Document__c = true AND Is_Document_Required__c = false AND  Related_Element_Name__c = null))';

                    applicationDocumentList = LPI_ApplicationDocumentDAO.getApplicantDocumentByDymanicQueryWithoutSecurity(
                        appDocumentQueryFields,
                        appDocumentWhereClause,
                        null,
                        SEQUENCE,
                        'Desc'
                    );

                    // Self-heal: RAT documents configured but never cloned onto this PAR
                    if (applicationDocumentList.isEmpty()) {
                        ensureApplicationDocumentsFromRAT(parList[0]);
                        applicationDocumentList = LPI_ApplicationDocumentDAO.getApplicantDocumentByDymanicQueryWithoutSecurity(
                            appDocumentQueryFields,
                            appDocumentWhereClause,
                            null,
                            SEQUENCE,
                            'Desc'
                        );
                    }
                }
            }

            if (applicationDocumentList == null) {
                applicationDocumentList = new List<Application_Document__c>();
            }

            if(!applicationDocumentList.isEmpty()) {
                system.debug('applicationDocumentList:- '+applicationDocumentList);
                Map<Id, Application_Document__c> applicationDocumentMap = new Map<Id, Application_Document__c>();
                for(Application_Document__c tempAppDoc :applicationDocumentList){
                    applicationDocumentMap.put(tempAppDoc.Id,tempAppDoc);
                }

                if (applicationDocumentMap.isEmpty()) {
                    responseMap.put('documents', '[]');
                    return responseMap;
                }

                String contentDocumentLinkQueryFields = ' ID, ContentDocumentId, LinkedEntityId ,ContentDocument.CreatedDate ';
                String contentDocumentLinkWhereClause = 'LinkedEntityId IN ' + LPI_ServiceUtility.getStringValuesByList(new List<Id>(applicationDocumentMap.keySet()));
                List<ContentDocumentLink> cdlist = LPI_ContentDocumentLinkDAO.getContentDocumentLinkByDymanicQuery(
                    contentDocumentLinkQueryFields,
                    contentDocumentLinkWhereClause,
                    null,
                    'ContentDocument.CreatedDate',
                    'DESC');
                Map<Id, Id> mapOfContentDocumentIdToLinkedEntitytId = new Map<Id, Id>();
                Map<Id, Id> mapOfApplicationDocumentIdToContentDocumentId = new Map<Id, Id>();

                List<ContentDocumentLink> contentDocumentLinkList = new List<ContentDocumentLink>();
                Map<String,ContentDocumentLink> mIdvsConDocLinkMap = new Map<String, ContentDocumentLink>();
                for(ContentDocumentLink cd : cdlist){
                    if(!mIdvsConDocLinkMap.containsKey(cd.LinkedEntityId)){
                        mIdvsConDocLinkMap.put(cd.LinkedEntityId,cd);
                    }
                }
                contentDocumentLinkList = mIdvsConDocLinkMap.values();
                for (ContentDocumentLink contentDocuLink : contentDocumentLinkList) {
                    if(!mapOfApplicationDocumentIdToContentDocumentId.containsKey(contentDocuLink.LinkedEntityId)){
                        // For each iteration, it is putting the LinkedEntityId as the key and the ContentDocumentId as the value in the map "mapOfApplicationDocumentIdToContentDocumentId"
                        mapOfApplicationDocumentIdToContentDocumentId.put(contentDocuLink.LinkedEntityId, contentDocuLink.ContentDocumentId);
                        
                        // For each iteration, it is putting the ContentDocumentId as the key and the LinkedEntityId as the value in the map "mapOfContentDocumentIdToLinkedEntitytId"
                        mapOfContentDocumentIdToLinkedEntitytId.put(contentDocuLink.ContentDocumentId, contentDocuLink.LinkedEntityId);
                    }
                }

                List<ContentVersion> contentVersionList = new  List<ContentVersion>();
                if(!mapOfContentDocumentIdToLinkedEntitytId.keySet().isEmpty()){
                    String contentVersionFields = ' ID, ContentDocumentId, ContentDocument.Title, ContentDocument.FileExtension, Title, VersionNumber, PathOnClient, CreatedDate ';
                    String contentVersionwhereClause = 'ContentDocumentId IN ' + LPI_ServiceUtility.getStringValuesBySet(mapOfContentDocumentIdToLinkedEntitytId.keySet());
                    contentVersionList = LPI_ContentVersionDAO.getContentVersionByDymanicQuery(
                        contentVersionFields,
                        contentVersionwhereClause,
                        null,
                        'VersionNumber',
                        'DESC'
                    );
                }

                Map<Id, List<ContentVersion>> mapOfContentDocumentIdToContentVersionList = new Map<Id, List<ContentVersion>>();
                for (ContentVersion conVersion : contentVersionList) {
                    // For each iteration, it checks if the map "mapOfContentDocumentIdToContentVersionList" contains the key "conVersion.contentDocumentId"
                    if (!mapOfContentDocumentIdToContentVersionList.containsKey(conVersion.contentDocumentId)) {
                        // If the key does not exist, it adds the key with a new List of "ContentVersion" objects as the value
                        mapOfContentDocumentIdToContentVersionList.put(conVersion.ContentDocumentId, new List<ContentVersion>());
                    }
                    // For each iteration, it adds the current "conVersion" object to the List of "ContentVersion" objects that is associated with the key "conVersion.ContentDocumentId"
                    mapOfContentDocumentIdToContentVersionList.get(conVersion.ContentDocumentId).add(conVersion);
                }

                Map<Id,DocumentWrapper> idToDocumentMap = new Map<Id,DocumentWrapper>();
                
                for (Application_Document__c appDocument : applicationDocumentMap.values()) {
                    DocumentWrapper wrapper = new DocumentWrapper();
                    wrapper.documentRecord = appDocument;
                    wrapper.contentDocumentId = mapOfApplicationDocumentIdToContentDocumentId.get(appDocument.Id);
                    wrapper.contentVersionList = mapOfContentDocumentIdToContentVersionList.get(mapOfApplicationDocumentIdToContentDocumentId.get(appDocument.Id));
                    if (wrapper.contentDocumentId != null) {
                        wrapper.fileName = wrapper.contentVersionList[0].PathOnClient;
                        wrapper.cssString = 'slds-grid slds-wrap box-container-inner documentuploaded';
                    } else {
                        wrapper.cssString = 'slds-grid slds-wrap box-container-inner';
                    }
                
                    if(!idToDocumentMap.containsKey(appDocument.Id)){
                        idToDocumentMap.put(appDocument.Id,wrapper);
                    }
                }
                responseMap.put('documents',JSON.serialize(idToDocumentMap.values()));
                return responseMap;
            }
            responseMap.put('documents', '[]');
            return responseMap;
        }catch (Exception ex) {
            LPI_ExceptionManager.logException('LPI_DocumentUploadController', 'getApplicationDocumentList', ex);
            throw new LPI_Exception(ex.getMessage());
        }
    }

    /**
     * Creates Application_Document__c rows from RAT Regulatory_Authorization_Content__c
     * when they were never cloned onto the PAR (common for portal-created applications).
     */
    @TestVisible
    private static void ensureApplicationDocumentsFromRAT(PreliminaryApplicationRef parRec) {
        if (parRec == null || parRec.Regulatory_Authorization_Type__c == null) {
            return;
        }
        try {
            List<Regulatory_Authorization_Content__c> lstRegAuthContent =
                LPI_RegulatoryAuthorizationContentDAO.getRegAuthContentByRATTypeAndRecordType(
                    new Set<Id>{ parRec.Regulatory_Authorization_Type__c },
                    LPI_LiteralConstant.DOCUMENT_RECORDTYPE_API
                );
            if (lstRegAuthContent.isEmpty()) {
                return;
            }
            List<Application_Document__c> applicationDocumentList = new List<Application_Document__c>();
            for (Regulatory_Authorization_Content__c regAuthContentRec : lstRegAuthContent) {
                Boolean typeMatches = regAuthContentRec.Type__c == parRec.Type__c;
                Boolean subTypeMatches =
                    (regAuthContentRec.Sub_Type__c == parRec.Amendment_Type__c) ||
                    (String.isBlank(regAuthContentRec.Sub_Type__c) && String.isBlank(parRec.Amendment_Type__c));
                if (!typeMatches || !subTypeMatches) {
                    continue;
                }
                Application_Document__c newAppDocument = new Application_Document__c();
                newAppDocument.Description__c = regAuthContentRec.Description__c;
                newAppDocument.Document_Name__c = regAuthContentRec.Name_of_Document__c;
                newAppDocument.Is_Document_Required__c = regAuthContentRec.Is_Document_Required__c;
                newAppDocument.Sequence__c = regAuthContentRec.Sequence_of_Document__c;
                newAppDocument.Related_Element_Name__c = regAuthContentRec.Related_Element_Name__c;
                newAppDocument.Type__c = regAuthContentRec.Type__c;
                newAppDocument.Sub_Type__c = regAuthContentRec.Sub_Type__c;
                newAppDocument.Status__c = LPI_LiteralConstant.APPDOC_STATUS;
                newAppDocument.Board_Name__c = parRec.Board_Name__c;
                newAppDocument.Help_Text__c = regAuthContentRec.Help_Text__c;
                newAppDocument.Preliminary_Application_Reference__c = parRec.Id;
                newAppDocument.Is_Lawful_Presence_Document__c = regAuthContentRec.Is_Lawful_Presence_Document__c;
                newAppDocument.Is_System_Generated__c = true;
                newAppDocument.Upload_To_Onbase__c = true;
                applicationDocumentList.add(newAppDocument);
            }
            if (!applicationDocumentList.isEmpty()) {
                LPI_WithoutSharingUtility.insertSObjectList(applicationDocumentList);
            }
        } catch (Exception ex) {
            LPI_ExceptionManager.logException('LPI_DocumentUploadController', 'ensureApplicationDocumentsFromRAT', ex);
        }
    }

    /**
    * @author            : Rajeev Roushan
    * @description       : This Method is used to return document download url.
    * @Parameters        : String documentID
    */
    @AuraEnabled
    public static Map<String,Object> downloadFile(String recordId){
        try{
            Map<String,Object> responseMap = new Map<String,Object>();
            if(String.isBlank(recordId)){throw new LPI_Exception('Error downloading document');}

            List<Application_Document__c> appDocList = LPI_ApplicationDocumentDAO.getApplicantDocumentByDymanicQuery('Id,File_Name__c,(SELECT ID,ContentDocumentId FROM ContentDocumentLinks)', 'Id = \''+String.escapeSingleQuotes(recordId) + '\'', null, null, null);
            if(appDocList.isEmpty()){
                throw new LPI_Exception('Error downloading document');
            }
            if(!appDocList[0].ContentDocumentLinks.isEmpty()){
                responseMap.put('downloadUrl', documentDownloadUrl(appDocList[0].ContentDocumentLinks[0].ContentDocumentId));
                responseMap.put('contentDocId',appDocList[0].ContentDocumentLinks[0].ContentDocumentId);
            }
            return responseMap;
        }catch (Exception e) {
            LPI_ExceptionManager.logException('LPI_DocumentUploadController','downloadFile',e);
            throw new LPI_Exception(e.getMessage());
        }
    }

    /**
    * @author            : Rajeev Roushan
    * @description       : This Method is used to return Download Link.
    * @Parameters        : String contentDocRecordId
    **/
    public static String documentDownloadUrl(String contentDocRecordId) {
        try{
            return System.Label.Site_URL + '/sfc/servlet.shepherd/document/download/' + contentDocRecordId;
        }catch (Exception ex) {
            LPI_ExceptionManager.logException('LPI_DocumentUploadController', 'documentDownloadUrl', ex);
            return null;
        }
    }

    /**
    * @author            : Rajeev Roushan
    * @description       : This Method is used to delete the documents.
    * @Parameters        : String contentDocRecordId
    **/
    @AuraEnabled
    public static Boolean handleFileDelete(String docId, String sectionName){
        try {
            if(!String.isBlank(docId)){
                String fields = 'Id';
                String whereClause = 'Id =\''+docId+'\'';
                List<ContentDocument> cdl = LPI_ContentDocumentDAO.getContentDocumentByDymanicQuery(fields,whereClause,null,null,null);
                System.debug('cdl' + cdl);
                LPI_DML.doDelete(cdl);
                return true;
            }
            return false;
        } catch (Exception e) {
            LPI_ExceptionManager.logException('LPI_OnBaseIntegrationController','handleFileDelete',e);
            throw new LPI_Exception(e.getMessage());
        }
    }

     /**
    * @author            : Rajeev Roushan
    * @description       : This Method is used to add an additional document for user to upload.
    * @Parameters        : String parId
    **/
    public static Id createAdditionalDocument(String parId) {
        try{
            String parToQuery =' ID, Name, Type__c, Amendment_Type__c ';   
            String parwhereClause = 'Id= \''+String.escapeSingleQuotes(parId)+'\'';
            List<PreliminaryApplicationRef> parlist = LPI_PreliminaryApplicationRefDAO.getPreliminaryApplicationRefByDymanicQuery(
                parToQuery,
                parwhereClause,
                null,
                null,
                null);
            String appDocumentQueryFields = ' Id ';
            String appDocumentWhereClause = 'Preliminary_Application_Reference__c = \''+String.escapeSingleQuotes(parId)+'\' AND Type__c INCLUDES (\'' +String.escapeSingleQuotes(parlist[0].Type__c)+'\')';
            List<Application_Document__c> docList = LPI_ApplicationDocumentDAO.getApplicantDocumentByDymanicQuery(
                appDocumentQueryFields,
                appDocumentWhereClause,
                null,
                null,
                null);
            Application_Document__c appDocument = new Application_Document__c();
            appDocument.Preliminary_Application_Reference__c = parId;
            appDocument.Type__c = parlist[0].Type__c;
            appDocument.Sub_Type__c = parlist[0].Amendment_Type__c;
            appDocument.Sequence__c = docList != null ? (docList.size() + 1) : 1;
            appDocument.Is_Manual_Document__c  = true;
            appDocument.Source_of_Document_Upload__c = Userinfo.getUserId();
            appDocument.Is_additional_document_by_portal_user__c = true;
            appDocument.Onbase_Payload__c = LPI_GetApplicationDocumentController.populatePayload(parId);
            appDocument = (Application_Document__c) LPI_WithoutSharingUtility.insertSObject(appDocument);
            return appDocument.Id;
        }catch (Exception ex) {
            LPI_ExceptionManager.logException('LPI_GetApplicationDocumentController', 'createNewDocument', ex);
            throw new LPI_Exception(ex.getMessage());
        }
    }

     /**
    * @author            : Rajeev Roushan
    * @description       : This Method is used to save additional document file details.
    * @Parameters        : String parId
    **/
    public static boolean saveAdditionalDocument(String appDocumentId,String docName, String docDesc) {
        try{
            if(!String.isBlank(appDocumentId)){
                Application_Document__c appDocument = new Application_Document__c();
                appDocument.Id = appDocumentId;
                appDocument.Document_Name__c = docName;
                appDocument.Description__c = docDesc;
                appDocument.Status__c = 'Submitted';
                LPI_WithoutSharingUtility.updateSObjectRecord(appDocument);
                return true;
            }
            return false;
        }catch (Exception ex) {
            LPI_ExceptionManager.logException('LPI_GetApplicationDocumentController', 'saveAdditionalDocument', ex);
            throw new LPI_Exception(ex.getMessage());
        }
    }
        
    public class DocumentWrapper {
        @AuraEnabled
        public Application_Document__c documentRecord;
        @AuraEnabled
        public String contentDocumentId;
        @AuraEnabled
        public List<ContentVersion> contentVersionList;
        @AuraEnabled
        public String fileName;
        @AuraEnabled
        public String cssString;
        @AuraEnabled public string twoByTwoPhotoRecommendation;
        @AuraEnabled public Boolean hideUpload;
       // @AuraEnabled public string numberValue;
        @AuraEnabled public string description;
        @AuraEnabled public string documentDate;
        @AuraEnabled public string comment;
        @AuraEnabled public string docLinkName;
        public List<LPI_Wrapper.FileWrapper> files = new List<LPI_Wrapper.FileWrapper>();
    }
}