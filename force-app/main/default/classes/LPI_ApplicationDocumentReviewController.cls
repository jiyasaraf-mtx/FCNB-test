/**
 *
 * @author          : MTX Group Product Team
 * @Description     : This class contains methods related to Documents
 */
public with sharing class LPI_ApplicationDocumentReviewController {
    private static final String REGISTRATION_FORM = 'Registration Form';

    public static void populateOnbasePayload(PreliminaryApplicationRef par,Map < String, String > responseMap){
        String dateValue = Date.today().year() + '-' +  String.valueOf(Date.today().month()).leftPad(2,'0') + '-' +  String.valueOf(Date.today().day()).leftPad(2,'0');
        responseMap.put('licenseNumber',String.isNotBlank(par.Business_License__r.Legacy_License_Number__c) ?par.Business_License__r.Legacy_License_Number__c : par.Business_License__r.Name);
        responseMap.put('firstName',String.isNotBlank(par.Contact__r.FirstName)? (par.Contact__r.FirstName).abbreviate(40):NULL);
        responseMap.put('middleName', String.isNotBlank((par.Contact__r.MiddleName))?((par.Contact__r.MiddleName).abbreviate(20)):NULL);
        responseMap.put('lastName',String.isNotBlank(par.Contact__r.LastName)?(par.Contact__r.LastName).abbreviate(40):NULL);
        responseMap.put('suffixName',String.isNotBlank(par.Contact__r.Suffix)?((par.Contact__r.Suffix).abbreviate(10)):NULL);
        responseMap.put('entityName',String.isNotBlank(par.ApplicationType == 'BusinessLicencseApplication'? 'par.Business_Name__c' : '')?((par.ApplicationType == 'BusinessLicencseApplication'? 'par.Business_Name__c' : '').abbreviate(70)):NULL);
        responseMap.put('profCode',String.isNotBlank(par.Regulatory_Authorization_Type__r.Profession_Code__c) ? ((par.Regulatory_Authorization_Type__r.Profession_Code__c).abbreviate(4)): NULL);
        responseMap.put('ssn',String.isNotBlank (par.Contact__r.Account.Social_Security_Number__c)?((par.Contact__r.Account.Social_Security_Number__c).abbreviate(9)): NULL);
        responseMap.put('dateValue',dateValue);
        responseMap.put('scanDate',dateValue);
        responseMap.put('issuingDepartment',par.Regulatory_Authorization_Type__r.IssuingDepartment.Name);
        responseMap.put('authorisationType',par.Regulatory_Authorization_Type__r.Authorisation_Type__c);
    }
    
    /**
     * @author                      : MTX Group Product Team
     * @since                       : 09-27-2022
     * @description                 : This method return the List of Application_Document__c
     * @param  applicationId        : Application Id
     * @last modified by            : Amit Agrawal
     * @last modified date          : 29 Aug , 2023
     * @last modified details       : added a new variable in document wrapper
     */
    @AuraEnabled
    public static Map < String, String > getApplicationDocuments(String applicationId) {
        Map < String, String > responseMap = new Map < String, String > ();
        try {
            if (!String.isBlank(applicationId)) {
                String boardName;
                Date todayDate = Date.today();
                String applicationType = getApplicationType(applicationId);
                String objectName = getSObjectNameById(applicationId);
                responseMap.put('documentDate', todayDate.month() + '-' + todayDate.day() + '-' + todayDate.year());
                responseMap.put('twoByTwoPhotoRecommendation', System.Label.TwoByTwoPhotoRecommendations);
                if (objectName == 'IndividualApplication') {
                    List < IndividualApplication > iaList = LPI_IndividualApplicationDAO.getIndividualApplicationByDymanicQuery('SavedApplicationRef.ApplicationType,SavedApplicationRef.Business_License__r.Legacy_License_Number__c,SavedApplicationRef.Business_License__r.Name,SavedApplicationRef.Contact__r.FirstName,SavedApplicationRef.Contact__r.MiddleName,SavedApplicationRef.Contact__r.LastName,SavedApplicationRef.Contact__r.Suffix,SavedApplicationRef.Regulatory_Authorization_Type__r.Profession_Code__c,SavedApplicationRef.Contact__r.Account.Social_Security_Number__c,SavedApplicationRef.Regulatory_Authorization_Type__r.IssuingDepartment.Name,SavedApplicationRef.Regulatory_Authorization_Type__r.Authorisation_Type__c,Board_Name__c,Pre_Licensure_Number__c', 'Id = \'' + String.escapeSingleQuotes(applicationId) + '\'', null, null, null);
                    if (!iaList.isEmpty()) {
                        responseMap.put('numberValue', iaList[0].Pre_Licensure_Number__c);
                        responseMap.put('description', iaList[0].Pre_Licensure_Number__c);
                        boardName = iaList[0].Board_Name__c;
                        populateOnbasePayload(iaList[0].SavedApplicationRef,responseMap);
                    }
                } else if (objectName == 'BusinessLicenseApplication') {
                    List < BusinessLicenseApplication > blList = LPI_BusinessLicenseApplicationDAO.getBusinessLicenseApplicationByDymanicQuery('SavedApplicationRef.ApplicationType,SavedApplicationRef.Business_License__r.Legacy_License_Number__c,SavedApplicationRef.Business_License__r.Name,SavedApplicationRef.Contact__r.FirstName,SavedApplicationRef.Contact__r.MiddleName,SavedApplicationRef.Contact__r.LastName,SavedApplicationRef.Contact__r.Suffix,SavedApplicationRef.Regulatory_Authorization_Type__r.Profession_Code__c,SavedApplicationRef.Contact__r.Account.Social_Security_Number__c,SavedApplicationRef.Regulatory_Authorization_Type__r.IssuingDepartment.Name,SavedApplicationRef.Regulatory_Authorization_Type__r.Authorisation_Type__c,Board_Name__c,Pre_Licensure_Number__c', 'Id = \'' + String.escapeSingleQuotes(applicationId) + '\'', null, null, null);
                    if (!blList.isEmpty()) {
                        responseMap.put('numberValue', blList[0].Pre_Licensure_Number__c);
                        responseMap.put('description', blList[0].Pre_Licensure_Number__c);
                        boardName = blList[0].Board_Name__c;
                        populateOnbasePayload(blList[0].SavedApplicationRef,responseMap);
                    }
                }
    
                String flowName = 'License';
                String stringToQuery = 'ID,File_Name__c,Onbase_Document_Id__c,Is_Doc_Uploaded_by_Internal_User__c,Document_Name__c,Business_License_Application__r.SavedApplicationRefId, Individual_Application__r.SavedApplicationRefId,Is_Document_Required__c,Description__c,Comments__c,Status__c, Is_Lawful_Presence_Document__c, Source_of_Document_Upload__r.Name,(SELECT ID,Application_Document__c, File_Name__c,Onbase_Document_Id__c FROM Application_Document__r where  (Is_Doc_Uploaded_by_Internal_User__c = true OR Is_System_Generated__c = true  OR   Status__c = \'' + LPI_LiteralConstant.IA_SUBMITTED_STATUS + '\' ))';
                    String whereClause =
                    'Application_Document__c = NULL AND (Business_License_Application__c = \'' +
                    String.escapeSingleQuotes(applicationId) +
                    '\' OR Individual_Application__c = \'' +
                    String.escapeSingleQuotes(applicationId) +
                    '\') AND (Type__c INCLUDES (\'' +
                    String.escapeSingleQuotes(applicationType)+
                    '\') OR  CreatedBy.Profile.Name = \'Integration User\')';
                   
                    String sortingByFields = 'Document_Name__c, Sequence__c';
                    whereClause +=  ' AND (Is_Doc_Uploaded_by_Internal_User__c = true OR Is_System_Generated__c = true  OR   Status__c = \'' + LPI_LiteralConstant.IA_SUBMITTED_STATUS + '\' )';
                Map < Id, Application_Document__c > documentsList = new Map < Id, Application_Document__c > (
                    LPI_ApplicationDocumentDAO.getApplicantDocumentByDymanicQueryWithoutSecurity(
                        stringToQuery,
                        whereClause,
                        null,
                        sortingByFields,
                        'Desc'
                    )
                );
                system.debug('documentsList:- '+documentsList);
                if (
                    documentsList != null &&
                    documentsList.values().size() == 0
                ) {
                    return responseMap;
                }

                Map < Id, Map < Id, String >> mapOfLinkedEntityToContentDocument = getMapOfLinkedEntityToContentDocument(
                    documentsList.keySet()
                );
                Map < Id, DocumentWrapper > idToDocumentMap = new Map < Id, DocumentWrapper > ();
                List < Application_Document__c > childAppDocList = new List < Application_Document__c > ();
                for (
                    Application_Document__c document: documentsList.values()
                ) {
                    childAppDocList.addALL(document.Application_Document__r);
                    DocumentWrapper wrapper = new DocumentWrapper();
                    wrapper.documentId = document.Id;
                    wrapper.documentName = document.Document_Name__c;
                    wrapper.comments = document.Comments__c;
                    wrapper.status = document.Status__c;
                    wrapper.isDocumentRequired = document.Is_Document_Required__c;
                    wrapper.documentMode = document.Is_Document_Required__c ?
                    LPI_LiteralConstant.DOCUMENT_REQUIRED :
                    LPI_LiteralConstant.DOCUMENT_OPTIONAL;
                    wrapper.contentDocumentId = mapOfLinkedEntityToContentDocument.containsKey(
                            document.Id
                        ) ?
                        mapOfLinkedEntityToContentDocument.get(document.Id) :
                        null;
                    wrapper.showView = wrapper.contentDocumentId != null ?
                        true :
                        false;
                    wrapper.isLawfulPresentDocument = document.Is_Lawful_Presence_Document__c;
                    wrapper.sourceOfDocUploadName = String.isNotBlank(document.Source_of_Document_Upload__c) ?
                        document.Source_of_Document_Upload__r.Name :
                        '';
                        LPI_Wrapper.FileWrapper fileWrapper = new LPI_Wrapper.FileWrapper();
                    if (String.isNotBlank(document.Onbase_Document_Id__c)) {
                        fileWrapper.fileName = document.File_Name__c;
                        fileWrapper.uniqueId = document.Onbase_Document_Id__c;
                        fileWrapper.parentRecId = document.Id;
                        wrapper.files.add(fileWrapper);
                    }
                    idToDocumentMap.put(document.Id, wrapper);
                }
                system.debug('responseMap1:- '+responseMap);
                for (Application_Document__c appDoc: childAppDocList) {
                    LPI_Wrapper.FileWrapper fileWrapperChild = new LPI_Wrapper.FileWrapper();
                    fileWrapperChild.fileName = appDoc.File_Name__c;
                    fileWrapperChild.uniqueId = appDoc.Onbase_Document_Id__c;
                    fileWrapperChild.parentRecId = appDoc.Id;
                    DocumentWrapper wrapper = idToDocumentMap.get(appDoc.Application_Document__c);
                    wrapper.files.add(fileWrapperChild);
                }
                responseMap.put('documents', JSON.serialize(idToDocumentMap.values()));
                system.debug('responseMap2:- '+responseMap);
                return responseMap;
            } 
            return responseMap;
        }catch (Exception e) {
            LPI_ExceptionManager.logException(
                'LPI_ApplicationDocumentReviewController',
                'getApplicationDocuments',
                e
            );
            return responseMap;
        }
    }

    /**
     * @author                      : MTX Group Product Team
     * @since                       : 09-27-2022
     * @description                 : This method is used for updating documents
     * @param  applicationId        : Application Id
     * @param  wrapperStr           : WrapperList
     * @last modified by            : Amit Agrawal
     * @last modified date          : (Add if modified by you)
     * @last modified details       : (Add if modified by you)
     */
    @AuraEnabled
    public static String updateDocuments(
        String wrapperStr,
        String applicationId
    ) {
        try {
            if (!String.isBlank(wrapperStr) && !String.isBlank(applicationId)) {
                List<SavingDocumentWrapper> wrapperList = (List<SavingDocumentWrapper>) JSON.deserialize(
                    wrapperStr,
                    List<SavingDocumentWrapper>.class
                );
                List<Application_Document__c> docList = new List<Application_Document__c>();
                for (SavingDocumentWrapper wrapper : wrapperList) {
                    Application_Document__c doc = new Application_Document__c();
                    doc.Id = wrapper.documentId;
                    doc.Status__c = wrapper.status;
                    doc.Comments__c = wrapper.comments;
                    doc.Is_Document_Required__c = wrapper.documentMode == LPI_LiteralConstant.DOCUMENT_REQUIRED ? true : false;
                    docList.add(doc);
                }
                if (docList.size() > 0) {
                    LPI_DML.doUpdate(docList);
                }
                Map<String,String> responseMap = getApplicationDocuments(applicationId);
                return  responseMap != NULL ? responseMap.get('documents') : null;
            }
        } catch (Exception e) {
            LPI_ExceptionManager.logException(
                'LPI_ApplicationDocumentReviewController',
                'updateDocuments',
                e
            );
        }
        return null;
    }

   
    /**
     *   @author                 : MTX Group Product Team
     *   @since                  : 16 Nov, 2022
     *   @description            : This method will create Apllication document record
     *   @param applicationId    : Application id
     *   @param inputMap         : Map if input values
     *   @return String
     */
    @AuraEnabled
    public static String createApplicationDocuments(
        String applicationId,
        Map<String, Object> inputMap,String deficiencyId
    ) {
        try {
            String documentName = (String) inputMap.get('documentName');
            String documentStatus = (String) inputMap.get('documentStatus');
            Boolean fromUploadDocument = (Boolean) inputMap.get('fromUploadDocument');
            Boolean isAdditionalRec = (Boolean) inputMap.get('isAdditionalRec');
            documentName = String.isNotBlank(documentName) ? String.escapeSingleQuotes(documentName) : null;
            documentStatus = String.escapeSingleQuotes(documentStatus);
            if (
                String.isEmpty(documentStatus)
            ) {
                return LPI_LiteralConstant.NULL_VALUES;
            }
            if (String.isNotBlank(documentName) && checkDuplicateValueForAppName(documentName, applicationId)) {
                return LPI_LiteralConstant.DUPLICATE_NAME;
            }
            Application_Document__c appDocument = new Application_Document__c(
                Document_Name__c = documentName,
                Status__c = documentStatus,
                Comments__c = (String) inputMap.get('documentComment'),
                Is_Document_Required__c = Boolean.valueOf(
                    inputMap.get('isRequired')
                ),
                Type__c = getApplicationType(applicationId),
                Deficiency__c = deficiencyId,
                Is_Deficiency_Notice__c = Boolean.valueOf(
                    inputMap.get('isAttachment')
                ),
                Is_Applicant_Submission_Required__c = Boolean.valueOf(
                    inputMap.get('isSubmissionRequired')
                ),
                File_Name__c = String.valueOf(
                    inputMap.get('fileName')
                )
            );
           if(fromUploadDocument != NULL && fromUploadDocument){
               
                String objectName = getSObjectNameById(applicationId);
                String query =
                'SELECT ID ,SavedApplicationRefId FROM ' +
                objectName +
                ' WHERE Id = :applicationId WITH SECURITY_ENFORCED ';
             Sobject sobj = Database.query(String.escapeSingleQuotes(query));
             string parId =   String.valueOf(sobj.get('SavedApplicationRefId')) ;
            } 
            if(isAdditionalRec != NULL && isAdditionalRec){
                appDocument.Is_additional_document_by_portal_user__c = true;
            }
           appDocument.Source_of_Document_Upload__c =  Userinfo.getUserId();
            
            if(inputMap.containsKey('embalmerFdDoc') && Boolean.valueOf(inputMap.get('embalmerFdDoc'))){
                appDocument.Type__c = REGISTRATION_FORM;
                appDocument.Sub_Type__c = REGISTRATION_FORM;
            }
            String sObjectName = getSObjectNameById(applicationId);
            if (LPI_LiteralConstant.IA_SOBJECT_API.equalsIgnoreCase(sObjectName)) {
                appDocument.Individual_Application__c = applicationId;
            } else if (
                LPI_LiteralConstant.BLA_SOBJECT_API.equalsIgnoreCase(sObjectName)
            ) {
                appDocument.Business_License_Application__c = applicationId;
               }
            appDocument = (Application_Document__c)LPI_WithoutSharingUtility.insertSObject(appDocument);
            return appDocument.Id;
        } catch (Exception ex) {
            LPI_ExceptionManager.logException(
                'LPI_ApplicationDocumentReviewController',
                'createApplicationDocuments',
                ex
            );
        }
        return null;
    }

    /**
     *   @author                       : MTX Group Product Team
     *   @since                        : 14 Nov, 2022
     *   @description                  : This method will return Map of
     *                                   LinkedEntity and map of content document with title
     *   @param setOfLinkedEntityId    : Set of LinkedEntityId
     *   @return Map<Id, Map<Id, String>>
     */
    private static Map<Id, Map<Id, String>> getMapOfLinkedEntityToContentDocument(
        Set<Id> setOfLinkedEntityId
    ) {
        try {
            if (setOfLinkedEntityId == null) {
                return null;
            }
            String queryString = LPI_ServiceUtility.getStringValuesByList(
                new List<Id>(setOfLinkedEntityId)
            );
            String stringToQuery = 'Id,ContentDocumentId,ContentDocument.Title,LinkedEntityId,ContentDocument.FileExtension';
            String whereClause = 'LinkedEntityId IN ' + queryString;
            LIST<ContentDocumentLink> listOfContentDoc = LPI_ContentDocumentLinkDAO.getContentDocumentLinkByDymanicQuery(
                stringToQuery,
                whereClause,
                null,
                null,
                null
            );
            Map<Id, Map<Id, String>> mapOfLinkedEntityToContentDocument = new Map<Id, Map<Id, String>>();
            for (ContentDocumentLink contentDocument : listOfContentDoc) {
                if (
                    mapOfLinkedEntityToContentDocument.containsKey(
                        contentDocument.LinkedEntityId
                    )
                ) {
                    mapOfLinkedEntityToContentDocument.get(
                            contentDocument.LinkedEntityId
                        )
                        .put(
                            contentDocument.ContentDocumentId,
                            contentDocument.ContentDocument.Title+'.'+ contentDocument.ContentDocument.FileExtension
                          );
                } else {
                    mapOfLinkedEntityToContentDocument.put(
                        contentDocument.LinkedEntityId,
                        new Map<Id, String>{
                            contentDocument.contentDocumentId => contentDocument.ContentDocument.Title +'.'+contentDocument.ContentDocument.FileExtension
                        }
                    );
                }
            }
            return mapOfLinkedEntityToContentDocument;
        } catch (Exception ex) {
            LPI_ExceptionManager.logException(
                'LPI_ApplicationDocumentReviewController',
                'getMapOfLinkedEntityToContentDocument',
                ex
            );
        }
        return null;
    }

    /**
     *   @author         : MTX Group Product Team
     *   @since          : 14 Nov, 2022
     *   @description    : This method will check duplicate value for application document name
     *   @param name     : Application document name
     *   @param appId    : Application id
     *   @return Boolean
     */
    private static Boolean checkDuplicateValueForAppName(
        String name,
        String appId
    ) {
        String stringToQuery = 'Id';
        String whereClause =
            '(Business_License_Application__c = \'' +
            String.escapeSingleQuotes(appId) + '\' OR Individual_Application__c =\''+String.escapeSingleQuotes(appId)+
            '\' ) AND Document_Name__c = \'' +
            String.escapeSingleQuotes(name) +
            '\' ';
        return LPI_ApplicationDocumentDAO.getApplicantDocumentByDymanicQuery(
                    stringToQuery,
                    whereClause,
                    null,
                    null,
                    null
                )
                ?.size() > 0;
    }

    /**
     *   @author            : MTX Group Product Team
     *   @since             : 14 Nov, 2022
     *   @description       : This method will return application type
     *   @param recordId    : Application id
     *   @return String
     */
    public static String getApplicationType(Id recordId) {
        String objectName = getSObjectNameById(recordId);
        String query =
            'SELECT ID , ApplicationType FROM ' +
            objectName +
            ' WHERE Id = :recordId WITH SECURITY_ENFORCED ';
        Sobject sobj = Database.query(String.escapeSingleQuotes(query));
        return String.valueOf(sobj.get('ApplicationType'));
    }

    /**
     *   @author            : MTX Group Product Team
     *   @since             : 14 Nov, 2022
     *   @description       : This method will return SObject name by record id
     *   @param recordId    : record id
     *   @return String
     */
    public static String getSObjectNameById(Id recordId) {
        return String.valueOf(recordId.getSObjectType());
    }

    /**
    * @description : Method to scan files and return the app doc list.
    * @author MTX Group Product Team | 01-01-2024 
    * @param jsonData 
    * @param recordId 
    * @return Map<String, String> 
    **/
    @AuraEnabled
    public static Map<String,String> scanFileAndReturnDocs(String jsonData,String recordId){
        try {
          	LPI_OnBaseIntegrationController.bypassOnbase(jsonData);
            return getApplicationDocuments(recordId);
        } catch (Exception e) {
            LPI_ExceptionManager.logException(
                'LPI_ApplicationDocumentReviewController',
                'scanFileAndReturnDocs',
                e
            );
            throw new LPI_Exception(e.getMessage());
        }
    }

    /**
    * @description : Method to delete file and return the documents left.
    * @author MTX Group Product Team | 01-02-2024 
    * @param jsonData 
    * @param recordId 
    * @return Map<String, String> 
    **/
    @AuraEnabled
    public static Map<String,String> handleFileDelete(String jsonData,String recordId){
        try {
            LPI_OnBaseIntegrationController.handleFileDelete(jsonData);
            return getApplicationDocuments(recordId);
        } catch (Exception e) {
            LPI_ExceptionManager.logException(
                'LPI_ApplicationDocumentReviewController',
                'handleFileDelete',
                e
            );
            throw new LPI_Exception(e.getMessage());
        }
    }

    public class DocumentWrapper {
        public String documentId;
        public String documentName;
        public String comments;
        public String status;
        public map<Id, string> contentDocumentId;
        public String documentMode;
        public Boolean showView;
        public Boolean isLawfulPresentDocument;
        public String sourceOfDocUploadName;
        public Boolean isDocumentRequired;
        @AuraEnabled
        public List<LPI_Wrapper.FileWrapper> files = new List<LPI_Wrapper.FileWrapper>();
    }
    public class SavingDocumentWrapper {
        public String documentId;
        public String documentName;
        public String comments;
        public String status;
        public List<Map<String, string>> contentDocumentId;
        public String documentMode;
        public Boolean showView;
        
    }
    public class FileDataWP {
        public String fileName;
        public String fileContent;
    }
}