/**
 * @description       : 
 * @author            : MTX Group Product Team
 * @group             : 
 * @last modified on  : 07-11-2024
 * @last modified by  : MTX Group Product Team
**/

public with sharing class LPI_ViewUplodDocContoller {
    private static final String IA_SOBJECT = 'IndividualApplication';
    private static final String REGISTRATION_FORM = 'Registration Form';
    private static final Set<String> APPLICATION_DOCUMENT_DEFICIENCY_STATUS_SET = new Set<String>{ 'Unsubmitted', 'Rejected' };

    /**
    * @description Used to fetch Application Document
    * @author MTX Group Product Team | 05-07-2024 
    * @param applicationId 
    * @param showDeficenyRec 
    * @return Map<String, String> 
    **/
    @AuraEnabled
    public static Map<String,String> getApplicationDocumentList(String applicationId,Boolean showDeficenyRec){
        try{
            if(String.valueOf(Id.valueOf(applicationId).getSObjectType()) == IA_SOBJECT && !showDeficenyRec){
                return getEmbalmersApplicationDocumentList(applicationId);
            }
            Map<String,String> responseMap = new Map<String,String>();
            Date todayDate = Date.today();
            responseMap.put('documentDate',todayDate.month() + '-' + todayDate.day() + '-' + todayDate.year());
            responseMap.put('twoByTwoPhotoRecommendation',System.Label.TwoByTwoPhotoRecommendations);
            Map<Id,Application_Document__c>  applicationDocumentList;
            if(String.isNotBlank(applicationId) && !(String.valueOf(Id.valueOf(applicationId).getSObjectType()) == IA_SOBJECT)){
                List<Deficiency__c> deficiencyList = new LPI_DeficiencyDAO.LPI_DeficiencyWithoutSharingDAO().getDeficiencyByDymanicQuery('Id,Board_Name__c,Business_License_Application__r.Pre_Licensure_Number__c,Individual_Application__r.Pre_Licensure_Number__c,Individual_Application__c,Business_License_Application__c,Business_License_Application__r.SavedApplicationRef.ApplicationType,Business_License_Application__r.SavedApplicationRef.Business_License__r.Legacy_License_Number__c,Business_License_Application__r.SavedApplicationRef.Business_License__r.Name,Business_License_Application__r.SavedApplicationRef.Contact__r.FirstName,Business_License_Application__r.SavedApplicationRef.Contact__r.MiddleName,Business_License_Application__r.SavedApplicationRef.Contact__r.LastName,Business_License_Application__r.SavedApplicationRef.Contact__r.Suffix,Business_License_Application__r.SavedApplicationRef.Regulatory_Authorization_Type__r.Profession_Code__c,Business_License_Application__r.SavedApplicationRef.Contact__r.Account.Social_Security_Number__c,Business_License_Application__r.SavedApplicationRef.Regulatory_Authorization_Type__r.IssuingDepartment.Name,Business_License_Application__r.SavedApplicationRef.Regulatory_Authorization_Type__r.Authorisation_Type__c,Individual_Application__r.SavedApplicationRef.ApplicationType,Individual_Application__r.SavedApplicationRef.Business_License__r.Legacy_License_Number__c,Individual_Application__r.SavedApplicationRef.Business_License__r.Name,Individual_Application__r.SavedApplicationRef.Contact__r.FirstName,Individual_Application__r.SavedApplicationRef.Contact__r.MiddleName,Individual_Application__r.SavedApplicationRef.Contact__r.LastName,Individual_Application__r.SavedApplicationRef.Contact__r.Suffix,Individual_Application__r.SavedApplicationRef.Regulatory_Authorization_Type__r.Profession_Code__c,Individual_Application__r.SavedApplicationRef.Contact__r.Account.Social_Security_Number__c,Individual_Application__r.SavedApplicationRef.Regulatory_Authorization_Type__r.IssuingDepartment.Name,Individual_Application__r.SavedApplicationRef.Regulatory_Authorization_Type__r.Authorisation_Type__c','Id = \''+String.escapeSingleQuotes(applicationId) + '\'',null,null,null);
                if(!deficiencyList.isEmpty()){
                    String numberValue = String.isNotBlank(deficiencyList[0].Business_License_Application__r.Pre_Licensure_Number__c) ?deficiencyList[0].Business_License_Application__r.Pre_Licensure_Number__c : deficiencyList[0].Individual_Application__r.Pre_Licensure_Number__c;
                    responseMap.put('numberValue',numberValue);
                    responseMap.put('description',numberValue?.abbreviate(30));
                    PreliminaryApplicationRef par = String.isNotBlank(deficiencyList[0].Business_License_Application__c) ? deficiencyList[0].Business_License_Application__r.SavedApplicationRef : deficiencyList[0].Individual_Application__r.SavedApplicationRef;
                    String flowName = 'License';
                    String fieldsToQuery = 'Id,Document_Name__c,File_Name__c,Uploaded_By_Internal_User__c,Onbase_Document_Id__c, Business_License_Application__c,Individual_Application__c,Preliminary_Application_Reference__r.Business_License__r.Pre_Licensure_Number__c,Board_Name__c, '+
                                    '(SELECT ContentDocument.Title, LinkedEntityId, ContentDocument.FileExtension, ContentDocumentId,ContentDocument.CreatedBy.Profile.Name, Id FROM ContentDocumentLinks LIMIT 50), '+
                                    'Is_Document_Required__c,Is_Applicant_Submission_Required__c,Is_Deficiency_Notice__c,CreatedBy.Profile.Name,(SELECT ID,Application_Document__c, File_Name__c,Onbase_Document_Id__c ,Uploaded_By_Internal_User__c FROM Application_Document__r WHERE CreatedBy.Profile.Name != \'' + LPI_LiteralConstant.Portal_Profile_Name + '\' OR (CreatedBy.Profile.Name = \'' + LPI_LiteralConstant.Portal_Profile_Name + '\' AND Status__c = \'' + LPI_LiteralConstant.IA_SUBMITTED_STATUS + '\')) ';
                    String whereCondition = '((Deficiency__c = \'' +String.escapeSingleQuotes(applicationId) + '\''+
                        +' AND Application_Document__c = NULL AND Is_Deficiency_Notice__c = ' + showDeficenyRec + ')';
                    if(String.isNotBlank(deficiencyList[0].Individual_Application__c)){
                        whereCondition += ' OR (Individual_Application__c = \'' + deficiencyList[0].Individual_Application__c + '\' AND (Status__c IN ' + LPI_ServiceUtility.getStringValuesByStringSet(APPLICATION_DOCUMENT_DEFICIENCY_STATUS_SET) + ' OR (Status__c=\'Submitted\' AND Is_Submitted_as_a_part_of_deficiency__c = true)) AND Is_Document_Required__c = true AND Deficiency__c = NULL))' ;
                    } else if (String.isNotBlank(deficiencyList[0].Business_License_Application__c)) {
                        whereCondition += ' OR (Business_License_Application__c = \'' + deficiencyList[0].Business_License_Application__c + '\' AND (Status__c IN ' + LPI_ServiceUtility.getStringValuesByStringSet(APPLICATION_DOCUMENT_DEFICIENCY_STATUS_SET) + ' OR (Status__c=\'Submitted\' AND Is_Submitted_as_a_part_of_deficiency__c = true)) AND Is_Document_Required__c = true AND Deficiency__c = NULL))' ;
                    }
                    whereCondition += ' AND (Is_Doc_Uploaded_by_Internal_User__c = true OR Is_System_Generated__c = true OR CreatedBy.Profile.Name != \'' + LPI_LiteralConstant.Portal_Profile_Name + '\' OR (CreatedBy.Profile.Name = \'' + LPI_LiteralConstant.Portal_Profile_Name + '\' AND Status__c = \'' + LPI_LiteralConstant.IA_SUBMITTED_STATUS + '\'))';
                    LPI_ApplicationDocumentDAO.LPI_ApplicationDocumentWithoutSharingDAO appDocObj =  new LPI_ApplicationDocumentDAO.LPI_ApplicationDocumentWithoutSharingDAO();
                    applicationDocumentList = new Map<Id, Application_Document__c>(appDocObj.getApplicantDocumentByDymanicQueryWithoutSecurityEnforced(fieldsToQuery,whereCondition,null,'Sequence__c','ASC'));
                }
            }
            if(applicationDocumentList.isEmpty()){
                return responseMap;
            }
            Map<Id,DocumentWrapper> idToDocumentMap = new Map<Id,DocumentWrapper>();
            idToDocumentMap = getAppDocsHelper(applicationDocumentList);
            responseMap.put('documents',JSON.serialize(idToDocumentMap.values()));
            return responseMap;
        }
        catch(Exception e){
            LPI_ExceptionManager.logException(
                'LPI_ViewUploadDocController',
                'getApplicationDocumentList',
                e
            );
        }
      return null;
    }

    /**
     * @author            : MTX Group Product Team
     * @description       : This Method is used to update application documents record
     * @Perameters        : String docId
    **/
    @AuraEnabled
    public static void updateApplicationDocumentRecord(String docId){
        try {
            LPI_DML.doUpdate(new Application_Document__c(Id=docId, Status__c = 'Submitted'));
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
       /**
     * @author            : MTX Group Product Team
     * @description       : This Method is used to update application documents record
     * @Perameters        : String docId
    **/
    @AuraEnabled
    public static void updateDeficiencyApplicationDocumentRecord(String docId){
        try {
            LPI_DML.doUpdate(new Application_Document__c(Id=docId, Status__c = 'Submitted',Is_Submitted_as_a_part_of_deficiency__c=true));
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }


    /**
     * @author            : MTX Group Product Team
     * @description       : This Method is used to get Registration form document for Embalmers form
     * @Parameters        : String applicationId
    **/
    private static Map<String,String> getEmbalmersApplicationDocumentList(String applicationId){
      try{
        if(String.isBlank(applicationId)){
            return null;
        }
        Map<String,String> responseMap = new Map<String,String>();
        Date todayDate = Date.today();
        String licenseName = '';
        responseMap.put('documentDate',todayDate.month() + '-' + todayDate.day() + '-' + todayDate.year());
        responseMap.put('twoByTwoPhotoRecommendation',System.Label.TwoByTwoPhotoRecommendations);
        List<IndividualApplication> iaList = new LPI_IndividualApplicationDAO.LPI_DAO_IndividualApptWithoutSecurity().getIndividualApplicationByDymanicQuery('Id, Board_Name__c, Pre_Licensure_Number__c, LicenseTypeId,SavedApplicationRef.ApplicationType,SavedApplicationRef.Business_License__r.Legacy_License_Number__c,SavedApplicationRef.Business_License__r.Name,SavedApplicationRef.Contact__r.FirstName,SavedApplicationRef.Contact__r.MiddleName,SavedApplicationRef.Contact__r.LastName,SavedApplicationRef.Contact__r.Suffix,SavedApplicationRef.Regulatory_Authorization_Type__r.Profession_Code__c,SavedApplicationRef.Contact__r.Account.Social_Security_Number__c,SavedApplicationRef.Regulatory_Authorization_Type__r.IssuingDepartment.Name,SavedApplicationRef.Regulatory_Authorization_Type__r.Authorisation_Type__c', 'Id = \'' + String.escapeSingleQuotes(applicationId) + '\'', null, null, null);
        if(!iaList.isEmpty()){
            String numberValue = iaList[0].Pre_Licensure_Number__c;
            licenseName = iaList[0].licenseTypeId;
            responseMap.put('numberValue', numberValue);
            responseMap.put('description', numberValue);
            String flowName = 'License';
        }
        String fieldsToQuery = 'Id,Document_Name__c,File_Name__c,Uploaded_By_Internal_User__c,Onbase_Document_Id__c, Business_License_Application__c,Individual_Application__c,Preliminary_Application_Reference__r.Business_License__r.Pre_Licensure_Number__c,Preliminary_Application_Reference__r.Pre_Licensure_Number__c,Board_Name__c, '+
                                '(SELECT ContentDocument.Title, LinkedEntityId, ContentDocument.FileExtension, ContentDocumentId,ContentDocument.CreatedBy.Profile.Name, Id FROM ContentDocumentLinks LIMIT 50), '+
                                'Is_Document_Required__c,Is_Applicant_Submission_Required__c,Is_Deficiency_Notice__c,CreatedBy.Profile.Name,(SELECT ID,Application_Document__c, File_Name__c,Onbase_Document_Id__c,Uploaded_By_Internal_User__c FROM Application_Document__r) ';
        String whereCondition = 'Individual_Application__c = \'' +String.escapeSingleQuotes(applicationId) + '\'' + 
            ' AND Type__c = \'' + REGISTRATION_FORM + '\'' + 
            'AND Sub_Type__c = \'' + REGISTRATION_FORM + '\'' + 
            ' AND Application_Document__c = NULL';                  
        LPI_ApplicationDocumentDAO.LPI_ApplicationDocumentWithoutSharingDAO appDocObj =  new LPI_ApplicationDocumentDAO.LPI_ApplicationDocumentWithoutSharingDAO();
        Map<Id,Application_Document__c>  applicationDocumentList = new Map<Id, Application_Document__c>(appDocObj.getApplicantDocumentByDymanicQueryWithoutSecurityEnforced(fieldsToQuery,whereCondition,null,'Sequence__c','ASC'));
        Map<Id,DocumentWrapper> idToDocumentMap = new Map<Id,DocumentWrapper>();
        if(applicationDocumentList.isEmpty()){
            fieldsToQuery = 'Id, Is_Document_Required__c, Name_of_Document__c, Sub_Type__c, Type__c';
            whereCondition = 'Type__c = \'' + REGISTRATION_FORM + '\'' + 
                'AND Sub_Type__c = \'' + REGISTRATION_FORM + '\'' + 
                'AND Regulatory_Authorization_Type__c = \'' + licenseName + '\'' ;
            LPI_RegulatoryAuthorizationContentDAO.LPI_RegAuthorizationContentWithoutSharingDAO racObj = new  LPI_RegulatoryAuthorizationContentDAO.LPI_RegAuthorizationContentWithoutSharingDAO();
            for(Regulatory_Authorization_Content__c rac : racObj.getRegAuthorizationContentByDymanicQuery(fieldsToQuery, whereCondition, null, null, null)){
                DocumentWrapper wrapper = new DocumentWrapper();
                wrapper.configuredDocumentRecord = rac;
                wrapper.cssString = 'slds-grid slds-wrap box-container-inner';
                LPI_Wrapper.FileWrapper fileWrapper = new LPI_Wrapper.FileWrapper();
                fileWrapper.fileName = rac.Name_of_Document__c;
                wrapper.showDocumentDelete = true;
                wrapper.files.add(fileWrapper);
                idToDocumentMap.put(rac.Id,wrapper);
            }
        }
        else{
            idToDocumentMap = getAppDocsHelper(applicationDocumentList);
        }
        responseMap.put('documents',JSON.serialize(idToDocumentMap.values()));
        return responseMap;
      }
      catch(Exception e){
        LPI_ExceptionManager.logException(
            'LPI_ViewUploadDocController',
            'getEmbalmersApplicationDocumentList',
            e
        );
      }
      return null;
    }

    /**
     * @author            : MTX Group Product Team
     * @description       : This Method is used to as helper to get documents list
     * @Parameters        : List<Application_Document__c>
    **/
    private static  Map<Id,DocumentWrapper> getAppDocsHelper(Map<Id, Application_Document__c> applicationDocumentList){
        try{
            Map<Id,DocumentWrapper> idToDocumentMap = new Map<Id,DocumentWrapper>();
            List<Application_Document__c> childAppDocList = new List<Application_Document__c> ();
            for(Application_Document__c appDocument : applicationDocumentList.values()){
                childAppDocList.addAll(appDocument.Application_Document__r);
                DocumentWrapper wrapper = new DocumentWrapper();
                wrapper.documentRecord = appDocument;
                if(wrapper.contentDocumentId != null){
                    wrapper.fileName = appDocument.Uploaded_By_Internal_User__c ? wrapper.contentVersionList[0].PathOnClient + '(Uploaded By MOPRO Staff)' : wrapper.contentVersionList[0].PathOnClient;
                    wrapper.cssString = 'slds-grid slds-wrap box-container-inner documentuploaded';
                } else{
                    wrapper.cssString = 'slds-grid slds-wrap box-container-inner';
                }
                if(appDocument.CreatedBy.Profile.Name == 'Portal User'){
                    wrapper.showDocumentDelete = true;
                }else{
                    wrapper.showDocumentDelete = false;
                }
                LPI_Wrapper.FileWrapper fileWrapper = new LPI_Wrapper.FileWrapper();
                if(String.isNotBlank(appDocument.Onbase_Document_Id__c)){
                    fileWrapper.fileName = appDocument.Uploaded_By_Internal_User__c ? appDocument.File_Name__c + '(Uploaded By MOPRO Staff)' : appDocument.File_Name__c ;
                    fileWrapper.uniqueId = appDocument.Onbase_Document_Id__c;
                    fileWrapper.parentRecId = appDocument.Id;
                    fileWrapper.showDelete = !appDocument.Uploaded_By_Internal_User__c;
                    wrapper.files.add(fileWrapper);
                }
                idToDocumentMap.put(appDocument.Id,wrapper);
            }
            for(Application_Document__c appDoc : childAppDocList){
                LPI_Wrapper.FileWrapper fileWrapper = new LPI_Wrapper.FileWrapper();
                fileWrapper.fileName = appDoc.Uploaded_By_Internal_User__c ? appDoc.File_Name__c + '(Uploaded By MOPRO Staff)' : appDoc.File_Name__c ;
                fileWrapper.uniqueId = appDoc.Onbase_Document_Id__c;
                fileWrapper.parentRecId = appDoc.Id;
                fileWrapper.showDelete = !appDoc.Uploaded_By_Internal_User__c;
                DocumentWrapper wrapper = idToDocumentMap.get(appDoc.Application_Document__c);
                wrapper.files.add(fileWrapper);
            }
            return idToDocumentMap;
        }
        catch(Exception e){
            LPI_ExceptionManager.logException(
                'LPI_ViewUploadDocController',
                'getAppDocsHelper',
                e
            );
        }
        return null;
    }

    /**
    * @description : Method to delete docs and return the remaning docs.
    * @author MTX Group Product Team | 01-05-2024 
    * @param jsonData 
    * @param applicationId 
    * @param showDeficenyRec 
    * @return Map<String, String> 
    **/
    @AuraEnabled
    public static Map<String,String> handleDeleteAndFetchDoc(String jsonData,String applicationId,Boolean showDeficenyRec){
        try {
            LPI_OnBaseIntegrationController.handleFileDelete(jsonData);
            if(String.isNotBlank(applicationId)){
                return getApplicationDocumentList(applicationId,showDeficenyRec);
            }
            return null;   
        } catch (Exception e) {
            LPI_ExceptionManager.logException(
                'LPI_ViewUploadDocController',
                'handleDeleteAndFetchDoc',
                e
            );
            throw new LPI_Exception(e.getMessage());
        }
    }

    /**
    * @description : Method to scan file and return the remaning docs.
    * @author MTX Group Product Team | 01-05-2024 
    * @param jsonData 
    * @param applicationId 
    * @param showDeficenyRec 
    * @return Map<String, String> 
    **/
    @AuraEnabled
    public static Map<String,String> handleScanAndReturnDocs(String jsonData,String applicationId,Boolean showDeficenyRec){
        
        LPI_OnBaseIntegrationController.ScanFileWrapper result = (LPI_OnBaseIntegrationController.ScanFileWrapper) JSON.deserialize(jsonData, LPI_OnBaseIntegrationController.ScanFileWrapper.class);
        LPI_OnBaseIntegrationController.bypassOnbase(jsonData);
        if(showDeficenyRec){
            updateDeficiencyApplicationDocumentRecord(result.recordId);
        }else{
            updateApplicationDocumentRecord(result.recordId);
        }
        return getApplicationDocumentList(applicationId,showDeficenyRec);
    }

    /**
    * @description :  Method to add new docs and return the all the docs.
    * @author MTX Group Product Team | 01-06-2024 
    * @param jsonData 
    * @param applicationId 
    * @param showDeficenyRec 
    * @return Map<String, String> 
    **/
    @AuraEnabled
    public static Map<String,String> handleSaveAndReturnDocs(Map<String,Object> inputMap,String applicationId,Boolean showDeficenyRec,String auditId){
        try {
            if( inputMap == NULL  || inputMap.get('appDocId') == NULL){
                throw new LPI_Exception('Unable to save the document');
            }
            String appDocId = (Id)inputMap.get('appDocId');
            Boolean setStatusToUploadToOnbase = (Boolean) inputMap.get('setStatusToUploadToOnbase');
            Application_Document__c appDoc = new Application_Document__c(Id = appDocId );
            if(inputMap.get('documentName') != NULL){
                appDoc.Document_Name__c = (String)inputMap.get('documentName');
            }
            if(inputMap.get('documentComment') != NULL){
                appDoc.Description__c = (String)inputMap.get('documentComment');
            }
            LPI_DML.doUpdate(appDoc);
            if(String.isNotBlank(auditId)){
                Map<String, Object> jsonDataMap = new Map<String, Object>{
                    'tcpId' => (String)inputMap.get('tcpId'),
                    'ceAudit' => (Boolean)inputMap.get('isCeAudit'),
                    'appDocId' => (String)inputMap.get('appDocIdSet'),
                    'fromCourseModal' => (Boolean)inputMap.get('fromCourseModal')
                };
                return LPI_AuditDocumentController.getApplicationDocumentList(auditId, jsonDataMap);
            }
            return getApplicationDocumentList(applicationId,showDeficenyRec); 
        } catch (Exception e) {
            LPI_ExceptionManager.logException(
                'LPI_ViewUploadDocController',
                'handleDeleteAndFetchDoc',
                e
            );
            throw new LPI_Exception(e.getMessage());
        }
    }
    
    /**
     * @author            : MTX Group Product Team
     * @description       : This Method is used to return Download Link.
     * @Perameters        : String contentDocRecordId
    **/
    @AuraEnabled
    public static String documentDownloadUrl(String contentDocRecordId) {
        return Url.getSalesforceBaseUrl().toExternalForm() + '/sfc/servlet.shepherd/document/download/' + contentDocRecordId;
    }

    /**
	 * @author                      : MTX Group Product Team
	 * @since                       : 3rd Nov, 2022
	 * @description                 : This method fetches the RegulatoryAuthorization content of registration Form and assigns it to application document fields
	 * @param iaId                  : Takes Id of IA
	 * @return                      : `void`
	 * @last modified by            : MTX Group Product Team
	 * @last modified date          : 7 Jan, 2023
	 * @modified details            : Optimized Code
	 */
    @AuraEnabled
    public static void createEfdAppDocument(String iaId){
        try{
            String whereCondition = 'Individual_Application__c = \'' +String.escapeSingleQuotes(iaId) + '\'' + 
                ' AND Type__c = \'' + REGISTRATION_FORM + '\'' + 
                'AND Sub_Type__c = \'' + REGISTRATION_FORM + '\'' + 
                ' AND Is_System_Generated__c = true';      
            List<Application_Document__c> appDocList = LPI_ApplicationDocumentDAO.getApplicantDocumentByDymanicQuery('Id', whereCondition, null, null, null);   
            if(!appDocList.isEmpty()){
                return;
            }    
            List<IndividualApplication> iaList = LPI_IndividualApplicationDAO.getIndividualApplicationByDymanicQuery('Id, licenseTypeId, Board_Name__c, savedApplicationRefId', 'Id = \'' + String.escapeSingleQuotes(iaId) + '\'', null, null, null);
            if(!iaList.isEmpty()){   
                String fieldsToQuery = 'Id, Is_Document_Required__c, Name_of_Document__c, Sub_Type__c, Type__c, Description__c, Help_Text__c, Related_Element_Name__c';
                whereCondition = 'Type__c = \'' + REGISTRATION_FORM + '\'' + 
                    'AND Sub_Type__c = \'' + REGISTRATION_FORM + '\'' + 
                    'AND Regulatory_Authorization_Type__c = \'' + iaList[0].licenseTypeId + '\'' ;
                LPI_RegulatoryAuthorizationContentDAO.LPI_RegAuthorizationContentWithoutSharingDAO racObj = new  LPI_RegulatoryAuthorizationContentDAO.LPI_RegAuthorizationContentWithoutSharingDAO();
                List<Application_Document__c> applicationDocumentList = new List<Application_Document__c>();
                for(Regulatory_Authorization_Content__c regAuthContentRec : racObj.getRegAuthorizationContentByDymanicQuery(fieldsToQuery, whereCondition, null, null, null)){
                    Application_Document__c newAppDocument = new Application_Document__c();
					newAppDocument.Description__c = regAuthContentRec.Description__c;
					newAppDocument.Document_Name__c = regAuthContentRec.Name_of_Document__c;
					newAppDocument.Is_Document_Required__c = regAuthContentRec.Is_Document_Required__c;
					newAppDocument.Related_Element_Name__c = regAuthContentRec.Related_Element_Name__c;
					newAppDocument.Type__c = regAuthContentRec.Type__c;
                    newAppDocument.Sub_Type__c = regAuthContentRec.Sub_Type__c;
					newAppDocument.Status__c = LPI_LiteralConstant.APPDOC_STATUS;
					newAppDocument.Board_Name__c = iaList[0].Board_Name__c;
					newAppDocument.Help_Text__c = regAuthContentRec.Help_Text__c;
					newAppDocument.Is_System_Generated__c = true;
					newAppDocument.Upload_To_Onbase__c = true;
                    newAppDocument.Individual_Application__c = iaId;
					applicationDocumentList.add(newAppDocument);
				}
				if (!applicationDocumentList.isEmpty()) {
					LPI_DML.doInsert(applicationDocumentList);
				}  
            }
        }catch(Exception e){
            LPI_ExceptionManager.logException('LPI_ViewUploadDocController', 'createEfdAppDocument',  e);
        }

    }
    
    public class DocumentWrapper{
        @AuraEnabled public Application_Document__c documentRecord;
        @AuraEnabled public String contentDocumentId;
        @AuraEnabled public List<ContentVersion> contentVersionList;
        @AuraEnabled public String fileName;
        @AuraEnabled public String cssString;
        @AuraEnabled public boolean showDocumentDelete;
        @AuraEnabled public String numberValue;
        @AuraEnabled public String description;
        @AuraEnabled public String documentDate;
        @AuraEnabled public string onbaseMetadata;
        @AuraEnabled public Regulatory_Authorization_Content__c configuredDocumentRecord;
        @AuraEnabled
        public List<LPI_Wrapper.FileWrapper> files = new List<LPI_Wrapper.FileWrapper>();
    }
}