/**
* @description       : This class is used to retrive existing application document recod or document record with that it is also used to create documents.
* @author            : Garvit Jain
**/
global with sharing class LPI_GetApplicationDocumentController implements Callable {
    private static final String SEQUENCE = 'Document_Name__c, Sequence__c';
    public static final String PHOTOGRAPH_TEXT = 'Photograph';
    
    /**
* @description This Method is Used to Internally call the invokeMethod. 
* @author Vamsi Mudaliar | 01-31-2023 
* @param action 
* @param args 
* @return Object 
**/
    global Object call(String action, Map<String, Object> args) {
        Map<String, Object> input = (Map<String, Object>) args.get('input');
        Map<String, Object> output = (Map<String, Object>) args.get('output');
        Map<String, Object> options = (Map<String, Object>) args.get('options');
        return invokeMethod(action, input, output, options);
    }
    
    /**
* @author            : Garvit Jain
* @description       : This Method is used to invoke methods from a omnistudio components.
* @Perameters        : String methodName, Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options
**/
    private Boolean invokeMethod(String methodName, Map<String, Object> inputMap, Map<String, Object> outMap, Map<String, Object> options) {
        Boolean result;
        try{
            if (methodName == 'getApplicationDocumentList') {
                outMap.put('applicationDocumentInfo', getApplicationDocumentList((String) inputMap.get('parId')));
            }
            else if (methodName == 'updateStatus') {
                updateStatus((String) options.get('record'));
                outMap.put('applicationDocumentInfo', getApplicationDocumentList((String) inputMap.get('parId')));
            }else if (methodName == 'deletefile') {
                deleteContentFile((List<Object>) options.get('documentid'), (String) options.get('record'));
                outMap.put('applicationDocumentInfo', getApplicationDocumentList((String) inputMap.get('parId')));
            }else if (methodName == 'addNewDocument') {
                outMap.put('newAppDocId', createNewDocument((JSON.serialize(options.get('jsonData.docname'))), 
                                                            (JSON.serialize(options.get('jsonData.docdesc'))),
                                                            (JSON.serialize(options.get('jsonData.onbaseDocId'))), 
                                                            (JSON.serialize(options.get('jsonData.fileName'))), 
                                                            (String) inputMap.get('parId'))); 
                outMap.put( 
                    'outputData',
                    getApplicationDocumentList((String) inputMap.get('parId'))
                ); 
                
            }else if (methodName == 'documentDownloadUrl') {
                String data = documentDownloadUrl((String) inputMap.get('contentDocumentId'));
                outMap.put('contentDocURL', data);
            } else if (methodName == 'handleUploadFileSalesforce') {
                handleUploadFileSalesforce((String) options.get('fileData'));
                
                outMap.put(
                    'outputData',
                    getApplicationDocumentList((String) inputMap.get('parId'))
                );
            }
            else if (methodName == 'createApplicationDocument') {
                createApplicationDocument(options);
                outmap.put('newappDoc',options.get('newid'));
            }
            else if (methodName == 'getFileScanResult') {
                
                ScanFileWrapper resultfromUpload = (ScanFileWrapper) JSON.deserialize(JSON.serialize(options.get('jsonData')), ScanFileWrapper.class);
                resultfromUpload.payLoad = populatePayload((String) inputMap.get('parId'));
                LPI_OnBaseIntegrationController.bypassOnbase(JSON.serialize(resultfromUpload));
                outMap.put(
                    'outputData',
                    getApplicationDocumentList((String) inputMap.get('parId'))
                );
            }
            else if (methodName == 'handleFileDelete') {
                LPI_OnBaseIntegrationController.handleFileDelete(JSON.serialize(options.get('jsonData')));
                outMap.put('outputData',getApplicationDocumentList((String) inputMap.get('parId')));
            }
            else if (methodName == 'handleCancel') {
                outMap.put(
                    'outputData',
                    getApplicationDocumentList((String) inputMap.get('parId'))
                );
            }
            else if (methodName == 'downloadFileFromSf') {
                outMap.put('outputData',LPI_OnBaseIntegrationController.downloadFileFromSf(((string)options.get('appDocId'))));
            }
            else if (methodName == 'handleContentDocumentDelete') {
            }
            
            
            result = true;
        } catch (Exception ex) {
            result = false;
            LPI_ExceptionManager.logException('LPI_GetApplicationDocumentController', 'invokeMethod', ex);
        }
        return result;
    }
    
    /**
* @description : Method to upload file to Salesforce.
* @author Mohit Karani | 06-23-2023 
* @param jsonData 
**/
    @AuraEnabled
    public static void handleUploadFileSalesforce(
        String jsonData
    ) {
        try {
            if (String.isBlank(jsonData)) {
                throw new LPI_Exception('Invalid File');
            }
            LPI_Wrapper.FileWrapper wrapper = (LPI_Wrapper.FileWrapper) JSON.deserialize(
                jsonData,
                LPI_Wrapper.FileWrapper.class
            );
            List<ContentVersion> cvList = new List<ContentVersion>();
            ContentVersion cvToCreate = createContentVersion(wrapper);
            cvToCreate.Content_Type__c = PHOTOGRAPH_TEXT;
            cvList.add(cvToCreate);
            if (!cvList.isEmpty()) {
                String cvId;
                Set<String> cvIdSet = new Set<String>();
                List<ContentDocumentLink> cdlList = new List<ContentDocumentLink>();
                cvList = (List<ContentVersion>) LPI_DML.doInsert(cvList);
                for (ContentVersion cv : cvList) {
                    cvId = cv.Id;
                    cvIdSet.add(cv.Id);
                }
                // Querying ContentVersion againg to get the ContentDocumentId of the uploaded docs.
                LPI_ContentVersionDAO.LPI_ContentVersionWithoutSharingDAO cvClass = new LPI_ContentVersionDAO.LPI_ContentVersionWithoutSharingDAO();
                String fields = 'ID, ContentDocumentId';
                String whereClause =
                    'ID IN ' +
                    LPI_ServiceUtility.getStringValuesByList(
                        new List<String>(cvIdSet)
                    );
                Set<Id> appDocumentIdSet = new Set<Id>();
                for (
                    ContentVersion cv : cvClass.getContentVersionByDymanicQuery(
                        fields,
                        whereClause,
                        null,
                        null,
                        null
                    )
                ) {
                    ContentDocumentLink cdlink = new ContentDocumentLink();
                    cdlink.ContentDocumentId = cv.ContentDocumentId;
                    cdlink.LinkedEntityId = wrapper.linkedEntityId;
                    cdlink.ShareType = 'I';
                    cdlink.Visibility = 'AllUsers';
                    cdlList.add(cdlink);
                    appDocumentIdSet.add(wrapper.linkedEntityId);
                    
                }
                if(cvToCreate.Content_Type__c == PHOTOGRAPH_TEXT){
                    List<ContentDocument> contentDocToDelete = new List<ContentDocument>();
                    for(ContentVersion cv : cvClass.getContentVersionByDymanicQuery('Id,ContentDocumentId','Content_Type__c = \''+PHOTOGRAPH_TEXT+ '\' AND Id !=  \'' + cvId + '\'',null,null,null)){
                        contentDocToDelete.add(new ContentDocument(Id = cv.ContentDocumentId));
                    }
                }
                LPI_DML.doInsert(cdlList);
                List<Application_Document__c> appDocListToUpdate = new List<Application_Document__c>();
                for (Id recordId : appDocumentIdSet) {
                    appDocListToUpdate.add(
                        new Application_Document__c(
                            Id = recordId,
                            Status__c = LPI_LiteralConstant.APPDOC_STATUS_SUBMITTED,
                            Source_of_Document_Upload__c = Userinfo.getUserId()
                        )
                    );
                }
                LPI_DML.doUpdate(appDocListToUpdate);
            }
        } catch (Exception ex) {
            LPI_ExceptionManager.logException(
                'LPI_GetApplicationDocumentController',
                'handleUploadFileSalesforce',
                ex
            );
            throw new LPI_Exception('Invalid File');
        }
    }
    
    /**
* @description : Method to create ContnetVersion using FileData.
* @author Mohit Karani | 01-13-2023
* @param file
* @return ContentVersion
**/
    public static ContentVersion createContentVersion(
        LPI_Wrapper.FileWrapper file
    ) {
        ContentVersion cv = new ContentVersion();
        cv.Title = file.fileName.substringBeforeLast('.');
        cv.PathOnClient = file.fileName;
        cv.VersionData = EncodingUtil.base64Decode(file.base64);
        return cv;
    }
    /**
* @author            : Garvit Jain
* @description       : This Method is used to return Download Link.
* @Perameters        : String contentDocRecordId
**/
    public static String documentDownloadUrl(String contentDocRecordId) {
        try{
            return Url.getSalesforceBaseUrl().toExternalForm() + '/sfc/servlet.shepherd/document/download/' + contentDocRecordId;
        }catch (Exception ex) {
            LPI_ExceptionManager.logException('LPI_GetApplicationDocumentController', 'documentDownloadUrl', ex);
            return null;
        }
    }
    /**
* @author            :Nayana Gupta
* @description       : This Method is used to  populate Paylod.
* @Perameters        : String parId
*/
    
    public static string  populatePayload(String parId) {
        String parFields = 'Id,Type__c,Business_Name__c,ApplicationType,Name,Contact__r.FirstName,Contact__r.MiddleName,Contact__r.LastName, Is_Supervisor_User__c , Approval_Supervisors_AcrIds__c,Business_License__r.Pre_Licensure_Number__c,Board_Name__c,Regulatory_Authorization_Type__r.IssuingDepartment.Name,Regulatory_Authorization_Type__r.Authorisation_Type__c ,Regulatory_Authorization_Type__r.Profession_Code__c,Contact__r.Suffix,Contact__r.Account.Social_Security_Number__c,Business_License__r.Name,Business_License__r.Legacy_License_Number__c,Regulatory_Authorization_Type__r.Name';
        LPI_OnBaseIntegrationController.ResponseWrapper wrapper = new LPI_OnBaseIntegrationController.ResponseWrapper();
        String flowName = 'License';
        
        
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
            //String numberValue = String.isNotBlank(parList[0].Business_License__r.Promo_Id__c) ?parList[0].Business_License__r.Promo_Id__c : String.isNotBlank(parList[0].Business_License__r.Pre_Licensure_Number__c) ?parList[0].Business_License__r.Pre_Licensure_Number__c : null;
            String dateValue = Date.today().year() + '-' +  String.valueOf(Date.today().month()).leftPad(2,'0') + '-' +  String.valueOf(Date.today().day()).leftPad(2,'0');
            wrapper.numberValue = ''; //numberValue;
           // wrapper.description =  String.isNotBlank(numberValue)?(numberValue.abbreviate(30)): NULL;
            wrapper.licenseNumber =String.isNotBlank(parList[0].Business_License__r.Legacy_License_Number__c) ?parList[0].Business_License__r.Legacy_License_Number__c : parList[0].Business_License__r.Name;
            wrapper.firstName = String.isNotBlank(parList[0].Contact__r.FirstName)? (parList[0].Contact__r.FirstName).abbreviate(40):NULL;
            wrapper.middleName = String.isNotBlank((parList[0].Contact__r.MiddleName))?((parList[0].Contact__r.MiddleName).abbreviate(20)):NULL;
            wrapper.lastName =String.isNotBlank(parList[0].Contact__r.LastName)?(parList[0].Contact__r.LastName).abbreviate(40):NULL;
            wrapper.suffixName =String.isNotBlank(parList[0].Contact__r.Suffix)?((parList[0].Contact__r.Suffix).abbreviate(10)):NULL;
            wrapper.entityName =String.isNotBlank(parList[0].ApplicationType == 'BusinessLicencseApplication'? 'parList[0].Business_Name__c' : '')?((parList[0].ApplicationType == 'BusinessLicencseApplication'? 'parList[0].Business_Name__c' : '').abbreviate(70)):NULL;
            wrapper.profCode =String.isNotBlank(parList[0].Regulatory_Authorization_Type__r.Profession_Code__c) ? ((parList[0].Regulatory_Authorization_Type__r.Profession_Code__c).abbreviate(4)): NULL;
            wrapper.ssn =String.isNotBlank (parList[0].Contact__r.Account.Social_Security_Number__c)?((parList[0].Contact__r.Account.Social_Security_Number__c).abbreviate(9)): NULL;
            wrapper.dateValue = dateValue;
            wrapper.scanDate = dateValue;
            wrapper.boardName = parList[0].Board_Name__c;
            wrapper.flowName =flowName;
            
        }
        string payload = LPI_VisitRegCodeViolationController.populatePayloadGeneric(wrapper);
        return payload;
        
        
    }
    
    /**
* @author            : Garvit Jain
* @description       : This Method is used to return document list.
* @Perameters        : String parId
*/
    @AuraEnabled
    public static Map<String,String> getApplicationDocumentList(String parId) {
        try {
            String parFields = 'Id,Type__c,Business_Name__c,ApplicationType,Name,Contact__r.FirstName,Contact__r.MiddleName,Contact__r.LastName, Is_Supervisor_User__c , Approval_Supervisors_AcrIds__c,Business_License__r.Pre_Licensure_Number__c,Board_Name__c,Regulatory_Authorization_Type__r.IssuingDepartment.Name,Regulatory_Authorization_Type__r.Authorisation_Type__c ,Regulatory_Authorization_Type__r.Profession_Code__c,Contact__r.Suffix,Contact__r.Account.Social_Security_Number__c,Business_License__r.Name,Business_License__r.Legacy_License_Number__c,Regulatory_Authorization_Type__r.Name';
            String appDocumentQueryFields = ' Id,Type__c,Board_Name__c,File_Name__c,Onbase_Document_Id__c,Document_Name__c, Description__c ,Preliminary_Application_Reference__c, Business_License_Application__c, Is_Lawful_Presence_Document__c, Preliminary_Application_Reference__r.Business_License__r.Pre_Licensure_Number__c,Preliminary_Application_Reference__r.Regulatory_Authorization_Type__r.Name,( SELECT ContentDocument.Title, LinkedEntityId, ContentDocument.FileExtension, ContentDocumentId, Id FROM ContentDocumentLinks Order by ContentDocument.CreatedDate DESC LIMIT 1), Is_Document_Required__c, Help_Text__c,Is_System_Generated__c,(SELECT ID,Application_Document__c, File_Name__c,Onbase_Document_Id__c FROM Application_Document__r) ';
            String appDocumentWhereClause;
            Set<String> regulatoryAuthorizationTypesSet = new Set<String>{
                'Boxing Contestant', 
                    'Martial Arts Contestant', 
                    'Martial Arts Amateur Contestant', 
                    'MMA National Identification Card',
                    'Interim Teacher’s Certificate Application'
                    };
                        Map<String,String> responseMap = new Map<String,String>();
            Date todayDate = Date.today();
            responseMap.put('documentDate',todayDate.month() + '-' + todayDate.day() + '-' + todayDate.year());
            responseMap.put('twoByTwoPhotoRecommendation',System.Label.TwoByTwoPhotoRecommendations);
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
                    //String numberValue = String.isNotBlank(parList[0].Business_License__r.Promo_Id__c) ?parList[0].Business_License__r.Promo_Id__c : String.isNotBlank(parList[0].Business_License__r.Pre_Licensure_Number__c) ?parList[0].Business_License__r.Pre_Licensure_Number__c : null;
                    String showInstructionForAthleticsRAT = String.valueOf(regulatoryAuthorizationTypesSet.contains(parList[0].Regulatory_Authorization_Type__r.Name));//Added for I-253182
                    responseMap.put('issuingDepartment',parList[0].Regulatory_Authorization_Type__r.IssuingDepartment.Name);
                    responseMap.put('authorisationType',parList[0].Regulatory_Authorization_Type__r.Authorisation_Type__c);
                    responseMap.put('regulatoryAuthorizationType',showInstructionForAthleticsRAT);//Added for I-253182
                    responseMap.put('licenseTypeName', parList[0].Regulatory_Authorization_Type__r.Name);
                    
                    responseMap.put('Type__c',parList[0].Type__c);
                    String flowName = 'License';
                    
                    appDocumentWhereClause =
                        '(Is_System_Generated__c = true OR(CreatedBy.Profile.Name != \'' + LPI_LiteralConstant.Portal_Profile_Name + '\' OR (CreatedBy.Profile.Name = \'' + LPI_LiteralConstant.Portal_Profile_Name + '\' AND Status__c = \'' + LPI_LiteralConstant.IA_SUBMITTED_STATUS + '\'))) AND Preliminary_Application_Reference__c = \'' +
                        String.escapeSingleQuotes(parId) +
                        '\' AND Application_Document__c = NULL' + 
                        ' AND (Is_Lawful_Presence_Document__c = false OR  (Is_Lawful_Presence_Document__c = true AND Is_Document_Required__c = true AND  Related_Element_Name__c != null)'+ 
                        ' Or ( Is_Lawful_Presence_Document__c = true AND Is_Document_Required__c = false AND  Related_Element_Name__c = null))';
                    if (
                        parList[0].Is_Supervisor_User__c &&
                        parList[0].Approval_Supervisors_AcrIds__c != null
                    ) {
                    } else {
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
            
            Map<Id, Application_Document__c> applicationDocumentMap = new Map<Id, Application_Document__c>();
            for(Application_Document__c tempAppDoc :applicationDocumentList){
                applicationDocumentMap.put(tempAppDoc.Id,tempAppDoc);
            }
            if (applicationDocumentMap.isEmpty()) {
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
            // This code is looping through the list "contentVersionList"
            for (ContentVersion conVersion : contentVersionList) {
                // For each iteration, it checks if the map "mapOfContentDocumentIdToContentVersionList" contains the key "conVersion.contentDocumentId"
                if (!mapOfContentDocumentIdToContentVersionList.containsKey(conVersion.contentDocumentId)) {
                    // If the key does not exist, it adds the key with a new List of "ContentVersion" objects as the value
                    mapOfContentDocumentIdToContentVersionList.put(conVersion.ContentDocumentId, new List<ContentVersion>());
                }
                // For each iteration, it adds the current "conVersion" object to the List of "ContentVersion" objects that is associated with the key "conVersion.ContentDocumentId"
                mapOfContentDocumentIdToContentVersionList.get(conVersion.ContentDocumentId).add(conVersion);
            }

            // This code is looping through the values of the Map "applicationDocumentMap"
            Map<String,Object> twoByTwoPhotoDocMap = (Map<String,Object>)JSON.deserializeUntyped(System.Label.TwoByTwoPhotoRecommendations);
            Map<Id,DocumentWrapper> idToDocumentMap = new Map<Id,DocumentWrapper>();
            
            List<Application_Document__c> childAppDocList = new List<Application_Document__c> ();
            
            for (
                Application_Document__c appDocument : applicationDocumentMap.values()
            ) {
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
                wrapper.hideUpload =  (appDocument.Document_Name__c == twoByTwoPhotoDocMap.get('docName') && !appDocument.ContentDocumentLinks.isEmpty());
                if(!idToDocumentMap.containsKey(appDocument.Id)){
                    idToDocumentMap.put(appDocument.Id,wrapper);
                }
            }
            responseMap.put('documents',JSON.serialize(idToDocumentMap.values()));
            return responseMap;
        }catch (Exception ex) {
            LPI_ExceptionManager.logException('LPI_GetApplicationDocumentController', 'getApplicationDocumentList', ex);
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
        @AuraEnabled public string numberValue;
        @AuraEnabled public string description;
        @AuraEnabled public string onbaseMetadata;
        @AuraEnabled public string documentDate;
        @AuraEnabled public string comment;
        @AuraEnabled public string docLinkName;
        public List<LPI_Wrapper.FileWrapper> files = new List<LPI_Wrapper.FileWrapper>();
    }
    
    /**
* @author            : Garvit Jain
* @description       : This Method is used to delete documents and to update the status.
* @Perameters        : String documentRecordId,String record
**/
    public static void deleteContentFile(
        List<Object> documentRecordId,
        String record
    ) {
        try {
            List<ContentDocument> cdToBeDeleted = new List<ContentDocument>();
            for (Object conDoc : documentRecordId) {
                cdToBeDeleted.add(new ContentDocument(Id = (Id) conDoc));
                
            }
            if(cdToBeDeleted.size()>0){
                LPI_DML.doDelete(cdToBeDeleted);
                if (String.isNotBlank(record)) {
                    String contentDocumentLinkQueryFields = ' ID, ContentDocumentId, LinkedEntityId ';
                    String contentDocumentLinkWhereClause =
                        'LinkedEntityId IN ' +
                        LPI_ServiceUtility.getStringValuesByList(
                            new List<Id>(new Set<Id>{ record })
                        );
                    List<ContentDocumentLink> contentDocumentLinkList = LPI_ContentDocumentLinkDAO.getContentDocumentLinkByDymanicQuery(
                        contentDocumentLinkQueryFields,
                        contentDocumentLinkWhereClause,
                        null,
                        null,
                        null
                    );
                    
                    if (contentDocumentLinkList.size() == 0) {
                        String appDocumentQueryFields = ' Id, Is_Manual_Document__c  ';
                        String appDocumentWhereClause = 'Is_Manual_Document__c = TRUE AND ID IN ' +LPI_ServiceUtility.getStringValuesByList(new List<Id>(new Set<Id>{ record }));
                        
                        List<Application_Document__c> docList = LPI_ApplicationDocumentDAO.getApplicantDocumentByDymanicQuery(
                            appDocumentQueryFields,
                            appDocumentWhereClause,
                            null,
                            null,
                            null
                        );
                        if(docList.size()>0 && docList[0].Is_Manual_Document__c){
                            LPI_WithoutSharingUtility.deleteSObject(docList);
                        } else {
                            LPI_DML.doUpdate(
                                new Application_Document__c(
                                    Id = record,
                                    Status__c = LPI_LiteralConstant.APPDOC_STATUS,
                                    Source_of_Document_Upload__c = null
                                )
                            );
                        }
                    }
                }
            }
        } catch (Exception ex) {
            LPI_ExceptionManager.logException(
                'LPI_GetApplicationDocumentController',
                'deleteContentFile',
                ex
            );
        }
    }
    
    /**
* @author            : Garvit Jain
* @description       : This Method is used to update the status of Application Document.
* @Perameters        : String record
**/
    public static void updateStatus(String record) {
        try{
            LPI_DML.doUpdate(new Application_Document__c(Id = record, Status__c = LPI_LiteralConstant.APPDOC_STATUS_SUBMITTED, Source_of_Document_Upload__c = Userinfo.getUserId()));
        }
        catch (Exception ex) {
            LPI_ExceptionManager.logException('LPI_GetApplicationDocumentController', 'updateStatus', ex);
        }
    }
    
    /**
* @author            : Garvit Jain
* @description       : This Method is used to create new document.
* @Perameters        : String docName, String docDesc, String conVersion, String conDocument, String parId
**/
    public static Id createNewDocument(String docName, String docDesc,String onbaseDocId,String fileName ,String parId) {
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
            appDocument.Document_Name__c = docName;
            appDocument.Description__c = docDesc;
            appDocument.Type__c = parlist[0].Type__c;
            appDocument.Sub_Type__c = parlist[0].Amendment_Type__c;
            appDocument.Sequence__c = docList != null ? (docList.size() + 1) : 1;
            appDocument.Is_Manual_Document__c  = True;
            appDocument.Source_of_Document_Upload__c = Userinfo.getUserId();
            appDocument.File_Name__c = fileName;
            appDocument.Upload_To_Onbase__c = true;
            appDocument.Is_additional_document_by_portal_user__c	 = true;
            appDocument.Onbase_Payload__c = LPI_GetApplicationDocumentController.populatePayload(parId);
            appDocument = (Application_Document__c) LPI_WithoutSharingUtility.insertSObject(appDocument);
            return appDocument.Id;
        }catch (Exception ex) {
            LPI_ExceptionManager.logException('LPI_GetApplicationDocumentController', 'createNewDocument', ex);
            throw new LPI_Exception(ex.getMessage());
        }
    }
    
    /**
* @description : Method to add application documents for Onbase.
* @author Mohit Karani | 10-26-2023 
* @param options 
**/
    @AuraEnabled
    public static Map<String,Object> createApplicationDocument(  Map<String, Object> options){
        try{
            Map<String,Object> response = new  Map<String,Object>();
            String appDocumentId = (String) options.get('appDocumentId');
            String fileName = (String) options.get('fileName');
            Boolean createNewRec = (Boolean) options.get('createNewRec');
            Boolean isAdditionalRec = (Boolean) options.get('isAdditionalRec');
            String onbaseDocId = (String) options.get('onbaseDocId');
            String parId = (String) options.get('parId');
            Boolean fromUploadDocument = (Boolean) options.get('fromUploadDocument');
            String contentDocumentId = (String)options.get('contentDocumentId');
            String applicationId = (String) options.get('applicationId');
            Boolean fromDeficiency = (Boolean) options.get('fromDeficiency');
            
            Application_Document__c appDoc = new Application_Document__c();
            List<SObject> appList = new List<SObject>();
            Boolean queryWithoutSharing = false;
            String fields = 'Id,Sub_Type__c,Type__c,Business_License_Application__c,Document_Name__c,Individual_Application__c,Preliminary_Application_Reference__c,Board_Name__c,Is_Manual_Document__c,Individual_Application__r.SavedApplicationRefId,Business_License_Application__r.SavedApplicationRefId';
            if(createNewRec != NULL && createNewRec && String.isNotBlank(appDocumentId)){
                if(String.isNotBlank(applicationId) && fromDeficiency != NULL  && fromDeficiency){
                    String sobjectName;
                    if(sobjectName == 'IndividualApplication'){
                        appList = LPI_IndividualApplicationDAO.getIndividualApplicationByDymanicQuery('Id','Id = \''+String.escapeSingleQuotes(applicationId) + '\'',null,null,null);
                        
                    }else if(sobjectName == 'BusinessLicenseApplication'){
                        appList = LPI_BusinessLicenseApplicationDAO.getBusinessLicenseApplicationByDymanicQuery('Id','Id = \''+String.escapeSingleQuotes(applicationId) + '\'',null,null,null);
                    }
                    if(appList.isEmpty()){
                        throw new LPI_Exception('Unable to uplaod the file.');
                    }
                    queryWithoutSharing = true;
                }
                if(!queryWithoutSharing){
                    for(Application_Document__c appDocParent : LPI_ApplicationDocumentDAO.getApplicantDocumentByDymanicQuery(fields, 'Id = \''+String.escapeSingleQuotes(appDocumentId) + '\'',null,null,null)){
                        parId = String.isNotBlank(appDocParent.Preliminary_Application_Reference__c)? appDocParent.Preliminary_Application_Reference__c : String.isNotBlank(appDocParent.Individual_Application__r.SavedApplicationRefId) ? appDocParent.Individual_Application__r.SavedApplicationRefId : appDocParent.Business_License_Application__r.SavedApplicationRefId;
                        appDoc = appDocParent.clone(false,true,false,false);
                    }
                }
                
            }
            appDoc.Id = createNewRec != NULL && createNewRec ? null : appDocumentId;
            appDoc.Application_Document__c = createNewRec != NULL && createNewRec ? appDocumentId : null;
            appDoc.Upload_To_Onbase__c = True;
            appDoc.File_Name__c = fileName;
            appDoc.Latest_Document_Id__c =contentDocumentId;
            if(fromUploadDocument != NULL && fromUploadDocument){
                if(String.isBlank(parId)){
                    if(queryWithoutSharing){
                    }else{
                        for(Application_Document__c appDocParent : LPI_ApplicationDocumentDAO.getApplicantDocumentByDymanicQuery(fields, 'Id = \''+String.escapeSingleQuotes(appDocumentId) + '\'',null,null,null)){
                            parId = String.isNotBlank(appDocParent.Individual_Application__r.SavedApplicationRefId) ? appDocParent.Individual_Application__r.SavedApplicationRefId : appDocParent.Business_License_Application__r.SavedApplicationRefId;
                            
                        }
                    }
                }
                if(String.isBlank(parId)){
                    throw new LPI_Exception('Unable to uplaod the file.');
                }
                appDoc.Onbase_Payload__c = LPI_GetApplicationDocumentController.populatePayload(parId);
                
            } 
            if(isAdditionalRec != NULL && isAdditionalRec){
                appDoc.Is_additional_document_by_portal_user__c	 = true;
            }
            if(options.containskey('embalmerFdDoc') && (Boolean)options.get('embalmerFdDoc')){
                appDoc.Individual_Application__c = (Id)options.get('appRecordId');
                appDoc.Type__c = (String)options.get('type');
                appDoc.Sub_Type__c =(String) options.get('subType');
                appDoc.Document_Name__c = (String) options.get('docName');
                appDoc.Is_Document_Required__c = true;
            }
            appDoc = (Application_Document__c)LPI_WithoutSharingUtility.upsertSObject(appDoc);
            options.put('newid',appDoc.Id);
            response.put('newid',appDoc.Id);
            return response; 
        }
        catch(Exception e){
            LPI_ExceptionManager.logException('LPI_GetApplicationDocumentController', 'createApplicationDocument', e);
            return null;
            
        }
    }
    public class ScanFileWrapper{
        @AuraEnabled public string contentDocumentId;
        @AuraEnabled public string recordId;
        @AuraEnabled public string objectApiName;
        @AuraEnabled public string whereClause;
        @AuraEnabled public string appDocumentId;
        @AuraEnabled public Boolean fromGenericCmp;
        @AuraEnabled public string payLoad;
        @AuraEnabled public string fileId;
        @AuraEnabled public string newDocumentName;
        @AuraEnabled public string newDocumentDescription;
        @AuraEnabled public Boolean intakeFileDelete;
        @AuraEnabled public Boolean doNotDelete;
        @AuraEnabled public Boolean markUnsubmitted;
        @AuraEnabled public Boolean fromDeficiencyResponse;
        @AuraEnabled public Boolean fromhandleSave;
        @AuraEnabled public Boolean fromDeficiency;
        @AuraEnabled public Boolean isAdditionalRec;
        @AuraEnabled public Boolean uploadByInternalUser;
        @AuraEnabled public Boolean isSubmittedAsPartOfDeficiency;
        
    }
    
}