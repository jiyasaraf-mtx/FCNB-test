/**
 *
 * @author          : MTX Group Product Team
 * @Description     : This class contains methods related to Documents
 */
public with sharing class LPI_ApplicationDocumentDeficiencyCtrl {
    private final static string IA_SOBJECT_API = 'IndividualApplication';
    private final static string BLA_SOBJECT_API = 'BusinessLicenseApplication';
    private final static string SUCCESS = 'Success';
    private final static string ERROR = 'Error';
    private final static string IA_AWAITING_RESPONSE_STATUS = 'Awaiting Response';
    private final static string ERROR_REASON = 'ErrorReason';
    private final static string ERROR_DATA = 'ErrorData';
    private final static string DUPLICATE_NAME_FOUND_EEEOR = 'DuplicateNameFoundError';
    private final static String STATUS_NOTICE_ISSUED = 'Notice Issued';
    private final static String OTHER_VALUE = 'Other';

    /**
     *   @author                 : MTX Group Product Team
     *   @since                  : 3 Sep, 2023
     *   @description            : This method will create Apllication document for Deficiency
     *   @param applicationId    : Application id
     *   @param inputData        : It contains data for Apllication document and Deficiency in string format
     *   @return String
     */
    @AuraEnabled
    public static Map<String, String> createApplicationDocumentsForDeficiency(String applicationId, String inputData) {
        Map<String, String> returnMap = new Map<String, String>();
        
            DeficiencyDataWrapper data = (DeficiencyDataWrapper) JSON.deserializeStrict(
                inputData,
                DeficiencyDataWrapper.class
            );
            if (
                String.isNotBlank(applicationId)
            ) {
                Map<String,String> responseMap = LPI_ApplicationDocumentReviewController.getApplicationDocuments(applicationId);
                String appDocData = responseMap != null ? responseMap.get('documents') : null;
                String sObjectName = LPI_ApplicationDocumentReviewController.getSObjectNameById(applicationId);
                String queryFields = 'LicenseTypeId, Name, SavedApplicationRefId, AccountId, SavedApplicationRef.BusinessAccountNameId';
                Set<String> docNameSet = new Set<String>();
                String whereClause = 'Id =\'' + applicationId + '\'';
                String accountId;
                Map<Id, SObject> mapOfRecords = new Map<Id, SObject>();
                SObject iaOrBla;
                Id parId = null;
                if (String.isNotBlank(appDocData)) {
                    List<LPI_ApplicationDocumentReviewController.DocumentWrapper> docWrapper = (List<LPI_ApplicationDocumentReviewController.DocumentWrapper>) JSON.deserializeStrict(
                        appDocData,
                        List<LPI_ApplicationDocumentReviewController.DocumentWrapper>.class
                    );
                    for (LPI_ApplicationDocumentReviewController.DocumentWrapper tempDoc : docWrapper) {
                        docNameSet.add(tempDoc.documentName);
                    }
                    for (String docName : data.newDocNameList) {
                        if (docNameSet.contains(docName)) {
                            returnMap.put(ERROR_REASON, DUPLICATE_NAME_FOUND_EEEOR);
                            returnMap.put(ERROR_DATA, JSON.serialize(docNameSet));
                            return returnMap;
                        }
                    }
                }
                Deficiency__c defObj = new Deficiency__c();
                if(String.isNotBlank(data.dueDate)){
                    defObj.Due_Date__c = Date.valueOf(data.dueDate);
                }
                defObj.Deficiency_Reason__c = data.deficiencyComments;
                defObj.Deficiency_Raised_on_Date__c = Date.today();
                if (IA_SOBJECT_API.equalsIgnoreCase(sObjectName)) {
                    defObj.Individual_Application__c = applicationId;
                    queryFields += ', License_Type_Name__c, Board_Name__c , ApplicationType, Channel__c, SavedApplicationRef.ApplicationName, Amendment_Type__c';
                    mapOfRecords = new Map<Id, SObject>(
                        new LPI_IndividualApplicationDAO.LPI_DAO_IndividualApptWithoutSecurity()
                            .getIndividualApplicationByDymanicQuery(queryFields, whereClause, '1', null, null)
                    );
                    if (mapOfRecords.containsKey(applicationId)) {
                        parId = ((IndividualApplication) mapOfRecords.get(applicationId))?.SavedApplicationRefId;
                    }
                    defObj.Board_Name__c = ((IndividualApplication) mapOfRecords.get(applicationId)).Board_Name__c;
                    defObj.Status__c = STATUS_NOTICE_ISSUED;
                    IndividualApplication ia = new IndividualApplication();
                    ia.id = applicationId;
                    ia.Status = IA_AWAITING_RESPONSE_STATUS;
                    iaOrBla = ia;
                    accountId = ((IndividualApplication) mapOfRecords.get(applicationId))?.SavedApplicationRef?.BusinessAccountNameId;
                } else if (BLA_SOBJECT_API.equalsIgnoreCase(sObjectName)) {
                    defObj.Business_License_Application__c = applicationId;
                    queryFields += ', ApplicantId, Licence_Type_Name__c, Board_Name__c , ApplicationType, Channel__c, SavedApplicationRef.ApplicationName, Amendment_Type__c';
                    mapOfRecords = new Map<Id, SObject>(
                        new LPI_BusinessLicenseApplicationDAO.LPI_DAO_BusinessLiceWithoutSecurity()
                            .getBusinessLicenseApplicationByDymanicQuery(queryFields, whereClause, '1', null, null)
                    );
                    if (mapOfRecords.containsKey(applicationId)) {
                        parId = ((BusinessLicenseApplication) mapOfRecords.get(applicationId))?.SavedApplicationRefId;
                    }
                    defObj.Board_Name__c = ((BusinessLicenseApplication) mapOfRecords.get(applicationId)).Board_Name__c;
                    defObj.Status__c = STATUS_NOTICE_ISSUED;
                    BusinessLicenseApplication bla = new BusinessLicenseApplication();
                    bla.id = applicationId;
                    bla.Status = IA_AWAITING_RESPONSE_STATUS;
                    iaOrBla = bla;
                    accountId = ((BusinessLicenseApplication) mapOfRecords.get(applicationId))?.SavedApplicationRef?.BusinessAccountNameId;
                }
                defObj = (Deficiency__c) LPI_DML.doInsert(defObj);
                DataWrapper addData = new DataWrapper(data.additionalFeeDetailList,applicationId,defObj.Id,sObjectName,iaOrBla.Id,accountId);
                handleAdditionalFee(addData);
                
                if (!data.documentItems.isEmpty() && parId != null) {
                    Map<String, Application_Document__c> docNameToAppDocIdMap = createApplicationDocument(
                        data.documentItems,
                        applicationId,
                        defObj.Id,
                        sObjectName,
                        parId
                    );
                     
                }
                if (mapOfRecords != null && !mapOfRecords.isEmpty()) {
                    LPI_ServiceUtility.triggerDeficiencyEmail(mapOfRecords, sObjectName, defObj);
                    LPI_DML.doUpdate(iaOrBla);
                } else {
                    returnMap.put(ERROR_REASON, 'Application Not Found');
                    return returnMap;
                }
                returnMap.put(ERROR_REASON, SUCCESS);
                return returnMap;
            }
            throw new AuraHandledException('Required Field Missing');
        
    }

    /**
     *   @author                 : MTX Group Product Team
     *   @since                  : 21 feb, 2024
     *   @description            : This method will create Fees Record with check list Items
     *   @param additionalFeeDetailList   : It contains Details of fee line Items
     *   @param applicationId    : It contains ia or bla record Id
     *   @param defId            : Deficiency Id
     *   @return void
     */
    private static void handleAdditionalFee(DataWrapper addData){
        if(addData.additionalFeeDetailList != null && !addData.additionalFeeDetailList.isEmpty() && 
            String.isNotBlank(addData.applicationId) && String.isNotBlank(addData.defId) && 
            String.isNotBlank(addData.sObjectName) && String.isNotBlank(addData.iaOrBlaId)){
            List<RegulatoryTrxnFeeItem> regTrxFeeItemList = new List<RegulatoryTrxnFeeItem>();
            List<Due_Diligence__c> dueDiligenceList = new List<Due_Diligence__c>();
            RegulatoryTrxnFee rtf = new RegulatoryTrxnFee();
            rtf.ParentRecordId = addData.applicationId;
            rtf.Deficiency__c = addData.defId;
            rtf.Status__c = 'Pending';
            rtf.Status = 'Draft';
            rtf.AccountId = addData.accountId;
            rtf.Transaction_ID__c = LPI_PostSubmitController.generateRandomNumber(15);
            rtf = (RegulatoryTrxnFee) LPI_DML.doInsert(rtf);
            if(String.isNotBlank(rtf.Id)){
                for(AdditionalFeeDataWrapper addFeeData : addData.additionalFeeDetailList){
                    if(String.isNotBlank(addFeeData.feeDescription) &&
                    String.isNotBlank(addFeeData.feeName) && 
                    String.isNotBlank(addFeeData.feeObjectCode) &&
                    addFeeData.feeAmount != null){
                        RegulatoryTrxnFeeItem rtfi = new RegulatoryTrxnFeeItem();
                        rtfi.FeeAmount = addFeeData.feeAmount;
                        rtfi.Actual_Asked_Amount__c = addFeeData.feeAmount;
                        rtfi.Comments = addFeeData.feeDescription;
                        rtfi.RegulatoryTrxnFeeId = rtf.Id;
                        rtfi.Name = addFeeData.feeName;
                        rtfi.Object_Code__c = addFeeData.feeObjectCode;
                        regTrxFeeItemList.add(rtfi);
                        Due_Diligence__c dueDiligence = new Due_Diligence__c();
                        dueDiligence.Checklist_Name__c = 'Additional Fee - '+addFeeData.feeName;
                        dueDiligence.Status__c = 'Not Started';
                        dueDiligence.DefeciencyId__c = addData.defId;
                        if (IA_SOBJECT_API.equalsIgnoreCase(addData.sObjectName)) {
                            dueDiligence.Individual_Application__c = addData.iaOrBlaId;
                        }else if(BLA_SOBJECT_API.equalsIgnoreCase(addData.sObjectName)) {
                            dueDiligence.Application__c = addData.iaOrBlaId;
                        }
                        dueDiligenceList.add(dueDiligence);
                    }
                }
            }
            if(!regTrxFeeItemList.isEmpty()){
                LPI_DML.doInsert(regTrxFeeItemList);
            }
            if(!dueDiligenceList.isEmpty()){
                LPI_DML.doInsert(dueDiligenceList);
            }
        }
    }

    /**
     *   @author                 : MTX Group Product Team
     *   @since                  : 3 Sep, 2023
     *   @description            : This method will create Apllication document
     *   @param docList          : It contains data for Apllication document
     *   @param applicationId    : It contatins ia/bla Id
     *   @param deficiencyId     : It conatins id of deficiency record
     *   @param sObjectName      : It contains apiName for ia/bla
     *   @param parId            : It contains PreliminaryApplicationRef record Id
     *   @return String
     */
    private static Map<String, Application_Document__c> createApplicationDocument(
        List<DocumentItemsWrapper> docList,
        String applicationId,
        String deficiencyId,
        String sObjectName,
        Id parId
    ) {
        List<Application_Document__c> appDocumentList = new List<Application_Document__c>();
        Map<String, Application_Document__c> docNameToAppDocIdMap = new Map<String, Application_Document__c>();
        if (String.isNotBlank(deficiencyId)) {
            String appType = LPI_ApplicationDocumentReviewController.getApplicationType(applicationId);
            for (DocumentItemsWrapper doc : docList) {
                Application_Document__c appDocument = new Application_Document__c();
                appDocument.Document_Name__c = doc.documentName == OTHER_VALUE ? doc.specifyName : doc.documentName;
                appDocument.Status__c = 'Unsubmitted';
                appDocument.Comments__c = doc.documentDescription;
                appDocument.Is_Document_Required__c = Boolean.valueOf(doc.isRequired);
                appDocument.Type__c = appType;
                appDocument.Is_Deficiency_Notice__c = true;
                appDocument.Is_Doc_Uploaded_by_Internal_User__c = true;
                appDocument.Is_Applicant_Submission_Required__c = Boolean.valueOf(doc.isSubmissionRequired);
                appDocument.Deficiency__c = deficiencyId;
                appDocument.Preliminary_Application_Reference__c = parId;
                appDocument.Uploaded_By_Internal_User__c = (doc.fileData != null && !doc.fileData.isEmpty()) || (doc.childAppDocIds != NULL && !doc.childAppDocIds.isEmpty());
                appDocument.Id = String.isNotBlank(doc.parentDocId) ? doc.parentDocId : null ;
                appDocument.Upload_To_Onbase__c = true;
                if (IA_SOBJECT_API.equalsIgnoreCase(sObjectName)) {
                    appDocument.Individual_Application__c = applicationId;
                } else if (BLA_SOBJECT_API.equalsIgnoreCase(sObjectName)) {
                    appDocument.Business_License_Application__c = applicationId;
                }
                appDocumentList.add(appDocument);
                if(doc.childAppDocIds != NULL && !doc.childAppDocIds.isEmpty()){
                    for(String childAppDocId : doc.childAppDocIds){
                        Application_Document__c appDocumentClone = appDocument.clone(false, true, false, false);
                        appDocumentClone.Application_Document__c = appDocument.Id;
                        appDocumentClone.Id = childAppDocId;
                        appDocumentList.add(appDocumentClone);
                    }
                }
            }
            if (!appDocumentList.isEmpty()) {
                appDocumentList = (List<Application_Document__c>) LPI_DML.doUpsert(appDocumentList);
                for (Application_Document__c appDoc : appDocumentList) {
                    docNameToAppDocIdMap.put(appDoc.Document_Name__c, appDoc);
                }
            }
        }
        return docNameToAppDocIdMap;
    }

   

    public static void populateOnbasePayload(PreliminaryApplicationRef par,Map < String, Object > responseMap){
        String dateValue = Date.today().year() + '-' +  String.valueOf(Date.today().month()).leftPad(2,'0') + '-' +  String.valueOf(Date.today().day()).leftPad(2,'0');
        responseMap.put('licenseNumber',String.isNotBlank(par.Business_License__r.Legacy_License_Number__c) ?par.Business_License__r.Legacy_License_Number__c : par.Business_License__r.Name);
        responseMap.put('firstName',String.isNotBlank(par.Contact__r.FirstName)? (par.Contact__r.FirstName)?.abbreviate(40):NULL);
        responseMap.put('middleName', String.isNotBlank((par.Contact__r.MiddleName))?((par.Contact__r.MiddleName)?.abbreviate(20)):NULL);
        responseMap.put('lastName',String.isNotBlank(par.Contact__r.LastName)?(par.Contact__r.LastName)?.abbreviate(40):NULL);
        responseMap.put('suffixName',String.isNotBlank(par.Contact__r.Suffix)?((par.Contact__r.Suffix)?.abbreviate(10)):NULL);
        responseMap.put('entityName',String.isNotBlank(par.ApplicationType == 'BusinessLicencseApplication'? 'par.Business_Name__c' : '')?((par.ApplicationType == 'BusinessLicencseApplication'? 'par.Business_Name__c' : '')?.abbreviate(70)):NULL);
        responseMap.put('profCode',String.isNotBlank(par.Regulatory_Authorization_Type__r.Profession_Code__c) ? ((par.Regulatory_Authorization_Type__r.Profession_Code__c)?.abbreviate(4)): NULL);
        responseMap.put('ssn',String.isNotBlank (par.Contact__r.Account.Social_Security_Number__c)?((par.Contact__r.Account.Social_Security_Number__c)?.abbreviate(9)): NULL);
        responseMap.put('dateValue',dateValue);
        responseMap.put('scanDate',dateValue);
        responseMap.put('issuingDepartment',par.Regulatory_Authorization_Type__r.IssuingDepartment.Name);
        responseMap.put('authorisationType',par.Regulatory_Authorization_Type__r.Authorisation_Type__c);
    }

    /**
     *   @author                         : MTX Group Product Team
     *   @since                          : 20 Oct, 2023
     *   @description                    : This method witll check weather the channel is online or Offline
     *   @param applicationId            : Ia/Bla Id
     *   @return String
     */
    @AuraEnabled
    public static Map<String, Object> checkChannelStatusValue(Id applicationId) {
        try {
            boolean channel = false;
            List<String> boardNameList = new List<String>();
            Map<String, Object> resultMap = new Map<String, Object>();
            String boardName;
            String description;
            String numberValue;
            PreliminaryApplicationRef par = new PreliminaryApplicationRef();
            LPI_OnBaseIntegrationController.ResponseWrapper responseWrapper = new LPI_OnBaseIntegrationController.ResponseWrapper();
            Map<String,String> feeNameWithObjectCode = new Map<String,String>();
            String docWhereClause;
            if (applicationId.getSObjectType() == Schema.BusinessLicenseApplication.getSObjectType()) {
                List<BusinessLicenseApplication> blaList = LPI_BusinessLicenseApplicationDAO.getBusinessLicenseApplicationByDymanicQuery(
                    'Id,Channel__c,ApplicationType,Board_Name__c,Pre_Licensure_Number__c,SavedApplicationRef.ApplicationType,SavedApplicationRef.Business_License__r.Legacy_License_Number__c,SavedApplicationRef.Business_License__r.Name,SavedApplicationRef.Contact__r.FirstName,SavedApplicationRef.Contact__r.MiddleName,SavedApplicationRef.Contact__r.LastName,SavedApplicationRef.Contact__r.Suffix,SavedApplicationRef.Regulatory_Authorization_Type__r.Profession_Code__c,SavedApplicationRef.Contact__r.Account.Social_Security_Number__c,SavedApplicationRef.Regulatory_Authorization_Type__r.IssuingDepartment.Name,SavedApplicationRef.Regulatory_Authorization_Type__r.Authorisation_Type__c,LicenseTypeId,Amendment_Type__c',
                    'Id =\'' + applicationId + '\'',
                    null,
                    null,
                    null
                );
                if(!blaList.isEmpty()){
                    docWhereClause = 'Business_License_Application__c = \'' + applicationId + '\' AND Type__c = \'' + blaList[0].ApplicationType + '\'';
                    boardName = blaList[0].Board_Name__c;
                    boardNameList.add(boardName);
                    description = boardName;
                    numberValue = blaList[0].Pre_Licensure_Number__c;
                    if (
                        !blaList.isEmpty() &&
                        blaList[0].Channel__c != null &&
                        blaList[0].ApplicationType == 'Renewal' &&
                        blaList[0].Channel__c == 'Offline'
                    ) {
                        channel = true;
                    }
                    par = blaList[0].SavedApplicationRef;
                    feeNameWithObjectCode = getFeeNameWithObjectCode(blaList[0].LicenseTypeId, blaList[0].ApplicationType, blaList[0].Amendment_Type__c);
                }   
            } else if (applicationId.getSObjectType() == Schema.IndividualApplication.getSObjectType()) {
                List<IndividualApplication> iaList = LPI_IndividualApplicationDAO.getIndividualApplicationByDymanicQuery(
                    'Id,Channel__c,ApplicationType,Board_Name__c,Pre_Licensure_Number__c,SavedApplicationRef.ApplicationType,SavedApplicationRef.Business_License__r.Legacy_License_Number__c,SavedApplicationRef.Business_License__r.Name,SavedApplicationRef.Contact__r.FirstName,SavedApplicationRef.Contact__r.MiddleName,SavedApplicationRef.Contact__r.LastName,SavedApplicationRef.Contact__r.Suffix,SavedApplicationRef.Regulatory_Authorization_Type__r.Profession_Code__c,SavedApplicationRef.Contact__r.Account.Social_Security_Number__c,SavedApplicationRef.Regulatory_Authorization_Type__r.IssuingDepartment.Name,SavedApplicationRef.Regulatory_Authorization_Type__r.Authorisation_Type__c,LicenseTypeId,Amendment_Type__c',
                    'Id =\'' + applicationId + '\'',
                    null,
                    null,
                    null
                );
                if(!iaList.isEmpty()){
                    docWhereClause = 'Individual_Application__c = \'' + applicationId + '\' AND Type__c = \'' + iaList[0].ApplicationType + '\'';
                    par = iaList[0].SavedApplicationRef;
                    boardName = iaList[0].Board_Name__c;
                    description = boardName;
                    numberValue = iaList[0].Pre_Licensure_Number__c;
                    boardNameList.add(boardName);
                    if (
                        !iaList.isEmpty() &&
                        iaList[0].Channel__c != null &&
                        iaList[0].ApplicationType == 'Renewal' &&
                        iaList[0].Channel__c == 'Offline'
                    ) {
                        channel = true;
                    }
                    feeNameWithObjectCode = getFeeNameWithObjectCode(iaList[0].LicenseTypeId, iaList[0].ApplicationType, iaList[0].Amendment_Type__c);
                }
            }
            resultMap.put('channel', channel);
            resultMap.put('description', numberValue?.abbreviate(30));
            resultMap.put('numberValue', numberValue);
            resultMap.put('boardName', boardName);
            resultMap.put('feeNameWithObjectCode', feeNameWithObjectCode);
            populateOnbasePayload(par,resultMap);
            Date todayDate = Date.today();
            resultMap.put('documentDate', todayDate.month() + '-' + todayDate.day() + '-' + todayDate.year());

            for (
                LPI_Onbase_Configuration__mdt onbaseConfig : LPI_OnBaseIntegrationController.getOnbaseConfigMetadata(
                    boardNameList,
                    new List<String>{ 'LICENSE' }
                )
            ) {
                responseWrapper.onbaseConfig.put(
                    onbaseConfig.Board_Name__c + '-' + onbaseConfig.Flow_Name__c,
                    onbaseConfig.Payload__c
                );
            }
            resultMap.put('onbase', JSON.serialize(responseWrapper));
             
            Map<String,SelectOption> docNameOptionsMap = new Map<String,SelectOption>();
            if(String.isNotBlank(docWhereClause)){
                for(Application_Document__c ad : LPI_ApplicationDocumentDAO.getApplicantDocumentByDymanicQuery('Document_Name__c',docWhereClause,null,null,null)){
                    SelectOption option = new SelectOption(ad.Document_Name__c, ad.Document_Name__c);
                    docNameOptionsMap.put(ad.Document_Name__c,option);
                }
            }
            SelectOption otherOption = new SelectOption('Other', 'Other');
            docNameOptionsMap.put('Other',otherOption);
            resultMap.put('docNameOptions', JSON.serialize(docNameOptionsMap.values()));
            resultMap.put('twoByTwoPhotoRecommendation',System.Label.TwoByTwoPhotoRecommendations);
            return resultMap;
        } catch (Exception e) {
            LPI_ExceptionManager.logException(
                'LPI_ApplicationDocumentDeficiencyCtrl',
                'checkChannelStatusValue',
                e
            );
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     *   @author                 : MTX Group Product Team
     *   @since                  : 23 feb, 2023
     *   @description            : This method fetch the fee name with there object code.
     *   @param ratId            : regulatory authorization Id.
     *   @param type             : This is the ia or bla type.
     *   @param subType          : This is the ia or bla sub_Type.
     *   @return Map<String,String> : returning fees Data Map with there name and there corresponding object code.
     */
    private static Map<String,String> getFeeNameWithObjectCode(String ratId, String type, String subType){
        Map<String,String> feeNameWithObjectCodeMap = new Map<String,String>();
        Set<String> objectCodeSet = new Set<String>();
        if(String.isNotBlank(ratId) && String.isNotBlank(type) && String.isNotBlank(subType)){
            String fieldsToQuery = 'Name, Object_Code__c';
            String whereClause = 'Regulatory_Authorization_Type__c = \'' + ratId + 
                                '\' AND ((Fee_Type__c = \'' + type +'\' AND Fee_Sub_Type__c = \''+subType+'\') OR ' +
                                 '(Fee_Type__c = \'Additional Fee\' AND Fee_Sub_Type__c = \'Additional Fee\'))';
            for(Fees__c fee : LPI_FeesDAO.getFeesByDymanicQuery(fieldsToQuery, whereClause, null, null, null)) {
                if(!objectCodeSet.contains(fee.Object_Code__c)){
                    feeNameWithObjectCodeMap.put(fee.Name,fee.Object_Code__c);
                }
            }
        }
        return feeNameWithObjectCodeMap;
    }

    class DeficiencyDataWrapper {
        public String dueDate;
        public String deficiencyComments;
        public List<DocumentItemsWrapper> documentItems;
        public List<String> newDocNameList;
        public List<AdditionalFeeDataWrapper> additionalFeeDetailList;
    }
    class DocumentItemsWrapper {
        public String key;
        public String documentName;
        public String specifyName;
        public String documentDescription;
        public String isRequired;
        public String isSubmissionRequired;
        public String parentDocId;
        public Boolean showOtherDocNameInput;
        public List<String> childAppDocIds;
        public List<FileDataWrapper> fileData;
    }
    class AdditionalFeeDataWrapper{
        public String key;
        public String feeName;
        public String feeDescription;
        public String feeObjectCode;
        public Decimal feeAmount;
    }

    class FileDataWrapper {
        public String fileName;
        public String fileContent;
        public string documentId;
        public string parentRecId;
    }

    public class SelectOption {
        @AuraEnabled
        public String label;
        @AuraEnabled
        public String value;

        public SelectOption(String label, String value) {
            this.label = label;
            this.value = value;
        }
    }

    public class DataWrapper{
        public List<AdditionalFeeDataWrapper> additionalFeeDetailList; 
        public String applicationId;
        public String defId;
        public String sObjectName;
        public String iaOrBlaId;
        public String accountId;

        DataWrapper(List<AdditionalFeeDataWrapper> additionalFeeDetailList,
        String applicationId,
        String defId,
        String sObjectName,
        String iaOrBlaId,
        String accountId){
            this.additionalFeeDetailList = additionalFeeDetailList;
            this.applicationId = applicationId;
            this.defId = defId;
            this.sObjectName = sObjectName;
            this.iaOrBlaId = iaOrBlaId;
            this.accountId = accountId;
        }
    }

}