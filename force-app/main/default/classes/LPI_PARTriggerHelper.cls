/**
 * @author              : MTX Group Product Team
 * @since               : 6th Jan, 2023
 * @description         : This Class Contains the Business Logic on PreliminaryApplicationRef(PAR) Trigger
 */
public with sharing class LPI_PARTriggerHelper { 
    
    public static final String RESIDENCE_ADDRESS = 'Residence';
    public static final String STATUS_CLOSED = 'Closed';
    public static final String TYPE_NEW = 'New';
    public static final String H1B_VISA = 'H1B Visa';
    public static final String FOREIGN = 'FOREIGN';
    public static final String UNITED_STATES = 'UNITED STATES';
    public static final Set<String> PROOF_OF_CITIZENSHIP_SET = new Set<String>{ 'Passport', 'Birth Certificate' };
    public static final Set<String> APPLICABLE_TYPES_SET = new Set<String>{
        'New',
        'Renewal',
        'Reinstatement',
        'Reinstatement by Exam',
        'Re-licensure',
        'Re-authorization'
    };
    public static final String IA_CONVERTED_STATUS = 'Converted';
    public static final String TYPE_AMENDMENT = 'Amendment';
    
    private static String getClassName() {
        return 'LPI_PARTriggerHelper';
    }

    
    private static final String API_TRIGGERED_VALUE_NO = 'No';
    private static final String VALUE_NA = 'NA';
    private static final String VALUE_YES = 'Yes';
    private static final String HB_VISA = 'H1B Visa';
    
    private static final Set<String> VISA_PERMIT_SET = new Set<String>{ 'Visa with stamped date of US entry', HB_VISA };
    private static final Set<String> US_RESIDENTS_SET = new Set<String>{ 'US Permanent Resident Card', 'Permanent Resident Card Expired - Extension Granted' };
    private static final String STUDENT_VISA = 'F-1 Student Visa';
    
    private static final String VALUE_NA_NON_RESIDENT = 'NA - Non Resident';

    
    public static final String UPDATE_LAWFUL_PRESENCE_AMENDMENT = 'Update Lawful Presence';
    public static final String REQUEST_FOR_DUPLICATE_LICENSE = 'Request for Duplicate License';
    

    /**
     * @author                      : MTX Group Product Team
     * @since                       : 3rd Nov, 2022
     * @description                 : This method fetches the RegulatoryAuthorization content and assigns it to application document fields
     * @param recordsList           : Takes New List of List<PreliminaryApplicationRef> (PAR Records)
     * @param mapOfOldRecords       : Takes Old Map of PreliminaryApplicationRef records
     * @return                      : `void`
     * @last modified by            : Uzma Md
     * @last modified date          : 7 Jan, 2023
     * @modified details            : Optimized Code
     */
    public static void cloneRegulatoryAuthorizationContent(
        List<PreliminaryApplicationRef> recordsList,
        Map<Id, PreliminaryApplicationRef> mapOfOldRecords
    ) {
        try {
            Set<Id> setOfRegAuthId = new Set<Id>();
            Map<Id, PreliminaryApplicationRef> mapOfPreAppToRegAuth = new Map<Id, PreliminaryApplicationRef>();
            List<Application_Document__c> applicationDocumentList = new List<Application_Document__c>();
            Set<Id> setPARId = new Set<Id>();
            
            for (PreliminaryApplicationRef objPreApp : recordsList) {
                if (
                    mapOfOldRecords == null ||
                    mapOfOldRecords.get(objPreApp.Id).Amendment_Type__c != objPreApp.Amendment_Type__c ||
                    mapOfOldRecords.get(objPreApp.Id).Type__c != objPreApp.Type__c
                ) {
                    setOfRegAuthId.add(objPreApp.Regulatory_Authorization_Type__c);
                    mapOfPreAppToRegAuth.put(objPreApp.Regulatory_Authorization_Type__c, objPreApp);
                    setPARId.add(objPreApp.Id);
                }
            }
            if (!setPARId.isEmpty()) {
                
                List<Application_Document__c> lstApplicationDocumentToDelete = LPI_ApplicationDocumentDAO.getApplicationContentByPARId(
                    setPARId
                );
                if (!lstApplicationDocumentToDelete.isEmpty()) {
                    LPI_WithoutSharingUtility.deleteSObject(lstApplicationDocumentToDelete);
                }
            }
            if (!setOfRegAuthId.isEmpty()) {
                
                List<Regulatory_Authorization_Content__c> lstRegAuthContent = LPI_RegulatoryAuthorizationContentDAO.getRegAuthContentByRATTypeAndRecordType(
                    setOfRegAuthId,
                    LPI_LiteralConstant.DOCUMENT_RECORDTYPE_API
                );
                if (!lstRegAuthContent.isEmpty()) {
                    for (Regulatory_Authorization_Content__c regAuthContentRec : lstRegAuthContent) {
                        if (
                            regAuthContentRec.Type__c ==
                            mapOfPreAppToRegAuth.get(regAuthContentRec.Regulatory_Authorization_Type__c).Type__c &&
                            (
                                regAuthContentRec.Sub_Type__c ==
                                mapOfPreAppToRegAuth.get(regAuthContentRec.Regulatory_Authorization_Type__c)
                                    .Amendment_Type__c
                                ||
                                (
                                    String.isBlank(regAuthContentRec.Sub_Type__c) &&
                                    String.isBlank(
                                        mapOfPreAppToRegAuth.get(regAuthContentRec.Regulatory_Authorization_Type__c)
                                            .Amendment_Type__c
                                    )
                                )
                            )
                        ) {
                            Application_Document__c newAppDocument = new Application_Document__c();
                            newAppDocument.Description__c = regAuthContentRec.Description__c;
                            newAppDocument.Document_Name__c = regAuthContentRec.Name_of_Document__c;
                            newAppDocument.Is_Document_Required__c = regAuthContentRec.Is_Document_Required__c;
                            newAppDocument.Sequence__c = regAuthContentRec.Sequence_of_Document__c;
                            newAppDocument.Related_Element_Name__c = regAuthContentRec.Related_Element_Name__c;
                            newAppDocument.Type__c = regAuthContentRec.Type__c;
                            newAppDocument.Sub_Type__c = regAuthContentRec.Sub_Type__c;
                            newAppDocument.Status__c = LPI_LiteralConstant.APPDOC_STATUS;
                            newAppDocument.Board_Name__c = mapOfPreAppToRegAuth.get(regAuthContentRec.Regulatory_Authorization_Type__c)
                                .Board_Name__c;
                            
                            newAppDocument.Help_Text__c = regAuthContentRec.Help_Text__c;
                           
                            newAppDocument.Preliminary_Application_Reference__c = mapOfPreAppToRegAuth.get(
                                    regAuthContentRec.Regulatory_Authorization_Type__c
                                )
                                .Id;
                           
                            newAppDocument.Is_Lawful_Presence_Document__c = regAuthContentRec.Is_Lawful_Presence_Document__c;
                            newAppDocument.Is_System_Generated__c = true;
                            newAppDocument.Upload_To_Onbase__c = true;
                            
                            if(regAuthContentRec.Is_Lawful_Presence_Document__c){
                                newAppDocument.Account__c = mapOfPreAppToRegAuth.get(
                                    regAuthContentRec.Regulatory_Authorization_Type__c
                                )
                                .BusinessAccountNameId;
                            }
                            
                            applicationDocumentList.add(newAppDocument);
                        }
                    }
                    if (!applicationDocumentList.isEmpty()) {
                        LPI_DML.doInsert(applicationDocumentList);
                    }
                }
            }
        } catch (Exception exp) {
            LPI_ExceptionManager.logException(getClassName(), 'cloneRegulatoryAuthorizationContent', exp);
        }
    }

    /**
     * @author                      : MTX Group Product Team
     * @since                       : 9 Jan, 2023
     * @description                 : This method creates Business license or Induvidial application on sucessfull payment (When PAR is Submitted)
     * @param mapOfOldRecords       : Takes Old Map of PreliminaryApplicationRef records
     * @param recordsList           : Takes New List of List<PreliminaryApplicationRef> (PAR Records)
     * @return                      : `void`
     * @last modified by            : Uzma Md
     * @last modified date          : 18 Jan, 2023
     * @modified details            : added new temp fee map
     */
    public static void handleSubmittedPARAndCreateApplications(
        Map<Id, PreliminaryApplicationRef> mapOfOldRecords,
        List<PreliminaryApplicationRef> recordsList
    ) {
        try {
            Map<Id, PreliminaryApplicationRef> mapNewRecords = new Map<Id, PreliminaryApplicationRef>(recordsList);
            Set<Id> setPARId = new Set<Id>();
            Set<Id> ratIdSet = new Set<Id>();
            Set<Id> parIdsForIA = new Set<Id>();
            Set<Id> parIdsForBLA = new Set<Id>();

            
            for (PreliminaryApplicationRef parDetails : recordsList) {
                if (
                    (mapOfOldRecords.get(parDetails.Id).IsSubmitted != parDetails.IsSubmitted &&
                    parDetails.IsSubmitted &&
                    mapOfOldRecords.get(parDetails.Id).Status__c != parDetails.Status__c &&
                    parDetails.Status__c == LPI_LiteralConstant.PAR_CONVERTED_STATUS) ||
                    (mapOfOldRecords.get(parDetails.Id).Is_Submitted_By_Internal_User__c !=
                    parDetails.Is_Submitted_By_Internal_User__c && parDetails.Is_Submitted_By_Internal_User__c)
                ) { 
                    ratIdSet.add(parDetails.Regulatory_Authorization_Type__c);
                    setPARId.add(parDetails.id);
                    if (parDetails.ApplicationType == LPI_LiteralConstant.IA_SOBJECT_API) {
                        parIdsForIA.add(parDetails.Id);
                    } else if (parDetails.ApplicationType == LPI_LiteralConstant.BLA_SOBJECT_API) {
                        parIdsForBLA.add(parDetails.Id);
                    }
                }
            }

            
            if (!ratIdSet.isEmpty() && !setPARId.isEmpty()) {
                Map<Id, List<Fees__c>> ratIdWithFees = new Map<Id, List<Fees__c>>();
                Map<Id, String> regAuthMap = new Map<Id, String>();
                Map<Id, String> regAuthMapCategory = new Map<Id, String>();
                List<SObject> lstApplicationToInsert = new List<SObject>();
                Map<Id, List<Temp_Fee__c>> parIdWithTempFees = new Map<Id, List<Temp_Fee__c>>();
                Map<Id, Id> parIdToIAIdMap = new Map<Id, Id>();
                Map<Id, Id> parIdToBLAIdMap = new Map<Id, Id>();

                
                populateParToApplicationIdMap(parIdsForIA, parIdsForBLA, parIdToIAIdMap, parIdToBLAIdMap);
                
                prepareFeesRegAuthAndRegAuthCategoryMaps(
                    ratIdSet,
                    ratIdWithFees,
                    regAuthMap,
                    regAuthMapCategory,
                    setPARId,
                    parIdWithTempFees
                );
               
                List<PreliminaryApplicationRef> lstSubmittedPARRecords = LPI_PreliminaryApplicationRefDAO.getPARRecordsByID(
                    setPARId
                );
               
                Map<Id, QueueIdAndNamePair> mapParToQueue = getRSGroupMapForPAR(lstSubmittedPARRecords);
                
                Map<Id, Id> mapParIdToRecordTypeId = getRecordTypeMapForPAR(lstSubmittedPARRecords, regAuthMap);
                
                for (Id parId : setPARId) {
                    PreliminaryApplicationRef parDetails = mapNewRecords.get(parId);
                    
                    SObject newApplication;
                    
                    if (
                        regAuthMap.get(parDetails.Regulatory_Authorization_Type__c) ==
                        LPI_LiteralConstant.INDIVIDAULICENSE_APPTYPE 
                    ) {
                        newApplication = new IndividualApplication();
                        newApplication.Id = parIdToIAIdMap.containsKey(parDetails.Id)
                            ? parIdToIAIdMap.get(parDetails.Id)
                            : null;
                    } else if (
                        regAuthMap.get(parDetails.Regulatory_Authorization_Type__c) ==
                        LPI_LiteralConstant.BUSINESSLICENSE_APPTYPE 
                    ) {
                        newApplication = new BusinessLicenseApplication();
                        newApplication.Id = parIdToBLAIdMap.containsKey(parDetails.Id)
                            ? parIdToBLAIdMap.get(parDetails.Id)
                            : null;
                    }
                    if (newApplication != null) {
                        
                        mapApplicationFieldsFromPARDetails(
                            newApplication,
                            parDetails,
                            regAuthMapCategory,
                            ratIdWithFees,
                            mapParToQueue,
                            mapParIdToRecordTypeId,
                            parIdWithTempFees
                        );
                        lstApplicationToInsert.add(newApplication);
                    }
                }
                if (!lstApplicationToInsert.isEmpty()) {
                    List<SObject> insertApplicationList = LPI_WithoutSharingUtility.upsertSObjectList(
                        lstApplicationToInsert
                    );
                    updateIAAndBLAOnApplicationDocument(insertApplicationList);
                }
            }
        } catch (Exception exp) {
            LPI_ExceptionManager.logException(getClassName(), 'handleSubmittedPARAndCreateApplications', exp);
        }
    }

    /**
     * @author                      : MTX Group Product Team
     * @since                       : 11 Jan, 2023
     * @description                 : This method is a helper method and used to handle field mapping of IA/BLA
     *                                from the Submitted PAR record
     * @param  lstNewBLARecords     : Takes Business License Application Record
     * @return                      : `void`
     * @last modified by            : Uzma Md
     * @last modified date          : 18 Jan, 2023
     * @last modified details       : added new temp fee map
     */
    private static void mapApplicationFieldsFromPARDetails(
        SObject applicationRec,
        PreliminaryApplicationRef parDetails,
        Map<Id, String> regAuthMapCategory,
        Map<Id, List<Fees__c>> ratIdWithFees,
        Map<Id,QueueIdAndNamePair> mapParToQueue,
        Map<Id, Id> mapParIdToRecordTypeId,
        Map<Id, List<Temp_Fee__c>> parIdWithTempFees
    ) {
        
        String applicationType = String.valueOf(applicationRec.getSObjectType());
        switch on applicationType {
            when 'IndividualApplication' {
               
                mapIAFieldsFromPAR((IndividualApplication) applicationRec, parDetails);
            }
            when 'BusinessLicenseApplication' {
                
                mapBLAFieldsFromPAR((BusinessLicenseApplication) applicationRec, parDetails);
            }
        }
        
        if (mapParIdToRecordTypeId.containsKey(parDetails.Id)) {
            applicationRec.put('RecordTypeId', mapParIdToRecordTypeId.get(parDetails.Id));
        }
        if (mapParToQueue.containsKey(parDetails.Id)) {
            QueueIdAndNamePair obj = mapParToQueue.get(parDetails.Id);
            if(obj != null){
                applicationRec.put('OwnerId', obj.queueId);
                applicationRec.put('QueueId__c',obj.queueId); 
                applicationRec.put('Sub_Owner_Name__c', obj.queueName);
            }
        }
        
        mapOtherRequiredCommonFields(applicationRec, parDetails, regAuthMapCategory, ratIdWithFees, parIdWithTempFees);
    }

    /**
     * @author                      : MTX Group Product Team
     * @since                       : 11 Jan, 2023
     * @description                 : This method is a helper method and used map the fields from Submitted PAR Record to BLA record
     * @param  iaRecord             : Takes Individual Application to be created
     * @param  parDetails           : Takes Submitted PAR Record
     * @return                      : `void`
     * @last modified by            : Uzma Md
     * @last modified date          : 10 Feb 2023
     * @last modified details       : Updated Retirement Date from PAR to IA Record
     */
    private static void mapIAFieldsFromPAR(IndividualApplication iaRecord, PreliminaryApplicationRef parDetails) {
       
        iaRecord.First_Name__c = parDetails.FirstName__c;
        iaRecord.Last_Name__c = parDetails.LastName__c;
        iaRecord.Middle_Name__c = parDetails.MiddleName__c;
        iaRecord.Maiden_Name__c = parDetails.MaidenName__c;
        
        iaRecord.Tax_Compliance__c = parDetails.Tax_Compliance__c;
       
        iaRecord.Info_About_Military_Related_Services__c = parDetails.Info_About_Military_Related_Services__c;
        iaRecord.Served_In_US_Armed_Force__c = parDetails.Served_In_US_Armed_Force__c;

        
        iaRecord.Hold_Active_License__c = parDetails.Hold_Active_License__c;
        
        if (
            parDetails.Board_Name__c == LPI_LiteralConstant.Healing_Arts_RecordType &&
            (parDetails.Amendment_Type__c == LPI_LiteralConstant.PHYSICIAN_LIMITED_WITH_MISSOURI_LICENSE ||
            parDetails.Amendment_Type__c == LPI_LiteralConstant.PAR_SOBJECT_TYPE_REINSTATEMENT)
        ) {
           
            iaRecord.Profession__c = parDetails.Profession__c;
            
        }
        
        iaRecord.Consent_for_Primary_Contact_Address__c = parDetails.Consent_for_Primary_Contact_Address__c;
        // Prefer PAR.Business_Account__c; fall back to applicant Account (portal user)
        iaRecord.Business_Account__c = String.isNotBlank(parDetails.Business_Account__c)
            ? parDetails.Business_Account__c
            : parDetails.BusinessAccountNameId;
        
        iaRecord.Supervisor_ACR_Id__c = parDetails.Supervisor_ACR_Id__c;

        

        
        iaRecord.Approval_Supervisors_AcrIds__c = parDetails.Approval_Supervisors_AcrIds__c;
        

        
        iaRecord.Primary_Contact_Address__c = parDetails.Primary_Contact_Address__c;
        iaRecord.License_Address__c = parDetails.License_Address__c;
        iaRecord.Publicly_Displayed_Address__c = parDetails.Publicly_Displayed_Address__c;
        
        iaRecord.Currently_Holding_Active_License_Number__c = parDetails.Currently_Holding_Active_License_Number__c;
        
        iaRecord.Channel__c = parDetails.Channel__c;
        
        iaRecord.Period_of_employment_begins__c = parDetails.Period_of_employment_begins__c;
        iaRecord.Employment_Start_Date__c = parDetails.Employment_Start_Date__c;
       
        iaRecord.Name_of_the_Professional_Corporation__c = parDetails.Name_of_the_Professional_Corporation__c;


    }

    /**
     * @author                      : MTX Group Product Team
     * @since                       : 11 Jan, 2023
     * @description                 : This method is a helper method and used map the fields from Submitted PAR Record to BLA record
     * @param  blaRecord            : Takes Business License Application to be created
     * @param  parDetails           : Takes Submitted PAR Record
     * @return                      : `void`
     * @last modified by            : Uzma Md
     * @last modified date          : (Add if modified by you)
     * @last modified details       : (Add if modified by you)
     */
    private static void mapBLAFieldsFromPAR(
        BusinessLicenseApplication blaRecord,
        PreliminaryApplicationRef parDetails
    ) {
        blaRecord.ApplicantId = parDetails.Contact__c;
        blaRecord.Business_Name__c = parDetails.Business_Name__c;
        blaRecord.Amendment_Request_Type__c = parDetails.Amendment_Request_Type__c;
        blaRecord.Doing_Business_As_DBA_or_Trade_Name__c = parDetails.Doing_Business_As_DBA_or_Trade_Name__c;
        blaRecord.Course_ID__c = parDetails.Course_ID__c;
        blaRecord.Board_Name__c = parDetails.Board_Name__c;
        blaRecord.Amendment_Type__c = parDetails.Amendment_Type__c;
       
        blaRecord.New_Designated_in_charge_License_Number__c = parDetails.New_Designated_in_charge_License_Number__c;
       
        blaRecord.Served_In_US_Armed_Force__c = parDetails.Served_In_US_Armed_Force__c;
        blaRecord.Info_About_Military_Related_Services__c = parDetails.Info_About_Military_Related_Services__c;
       
        blaRecord.Profession__c = parDetails.Profession__c;
        blaRecord.Consent_for_Primary_Contact_Address__c = parDetails.Consent_for_Primary_Contact_Address__c;
        
        blaRecord.Primary_Contact_Address__c = parDetails.Primary_Contact_Address__c;
        blaRecord.License_Address__c = parDetails.License_Address__c;
        
        blaRecord.Channel__c = parDetails.Channel__c;
        
        blaRecord.Do_you_need_PIC__c = parDetails.Do_you_need_PIC__c;
        
    }

    /**
     * @author                      : MTX Group Product Team
     * @since                       : 11 Jan, 2023
     * @description                 : This method is a helper method and used map the fields from Submitted PAR Record to IA/BLA records
     * @param  applicationRec       : Takes SObject as it can be IA/BLA record
     * @param  parDetails           : Takes Submitted PAR Record
     * @param  regAuthMapCategory   : Takes regAuthMapCategory Mapping to Map Category on IA/BLA record
     * @param  ratIdWithFees        : Takes ratIdWithFees Mapping to Map Fee Details on IA/BLA record
     * @return                      : `void`
     * @last modified by            : Uzma Md
     * @last modified date          : 18 Jan, 2023
     * @last modified details       : added new temp fee logic
     */
    private static void mapOtherRequiredCommonFields(
        SObject applicationRec,
        PreliminaryApplicationRef parDetails,
        Map<Id, String> regAuthMapCategory,
        Map<Id, List<Fees__c>> ratIdWithFees,
        Map<Id, List<Temp_Fee__c>> parIdWithTempFees
    ) {
        
        
        applicationRec.put('SavedApplicationRefId', parDetails.Id);
        
        applicationRec.put('Applicant_Full_Name__c', parDetails.FullName__c);
        applicationRec.put('Applicant_Signature__c', parDetails.Applicant_Signature__c);
        
        applicationRec.put('Amendment_Type__c', parDetails.Amendment_Type__c);
        applicationRec.put('License_Questions__c', parDetails.License_Questions__c);
        
        applicationRec.put('AccountId', parDetails.BusinessAccountNameId);
        if(String.isNotBlank(parDetails.Transaction_Suitability_Questions__c) && parDetails.Transaction_Suitability_Questions__c!='' || parDetails.Transaction_Suitability_Questions__c!=null){
            applicationRec.put('Transaction_Suitability_Questions__c', parDetails.Transaction_Suitability_Questions__c);
        }
        
        DateTime currentTime = Datetime.now();
        applicationRec.put('AppliedDate', currentTime);
        Date todayDate = Date.newInstance(currentTime.year(),currentTime.month(),currentTime.day());
        applicationRec.put('Applicant_submission_Date__c',todayDate);

        applicationRec.put('Category', regAuthMapCategory.get(parDetails.Regulatory_Authorization_Type__c));
        
        if (parDetails.Is_Submitted_By_Internal_User__c && String.isBlank((String) applicationRec.get('Id'))) {
            applicationRec.put('Status', LPI_LiteralConstant.IA_DRAFT_STATUS);
        } else {
            applicationRec.put('Status', LPI_LiteralConstant.IA_SUBMITTED_STATUS);
        }
        applicationRec.put('LicenseTypeId', parDetails.Regulatory_Authorization_Type__c);
        
        List<RegulatoryAuthorizationType> reguAuth = [SELECT Id,Name FROM RegulatoryAuthorizationType WHERE Id =:parDetails.Regulatory_Authorization_Type__c LIMIT 1];
        if(!reguAuth.isEmpty() && reguAuth[0].Name == 'Educator License'){
            applicationRec.put('RecordTypeId', Schema.getGlobalDescribe().get('IndividualApplication').getDescribe().getRecordTypeInfosByName().get('Educator').getRecordTypeId());
        }
        
        applicationRec.put('ApplicationType', parDetails.Type__c);
        if (parDetails.Business_License__c != null && parDetails.Type__c != LPI_LiteralConstant.BLA_CHANGE_OF_OWNERSHIP) {
            applicationRec.put('LicensePermitNameId', parDetails.Business_License__c);
        }
        
        applicationRec.put('Certification_Email__c', parDetails.Certification_Email__c);
        applicationRec.put('Fax_Number__c', parDetails.Fax_Number__c);
       
        applicationRec.put('Is_Submitted_By_Internal_User__c', parDetails.Is_Submitted_By_Internal_User__c);
        applicationRec.put('Late_Renewal__c', parDetails.Late_Renewal__c);
    }

    /**
     * @author                      : MTX Group Product Team
     * @since                       : 11 Jan, 2023
     * @description                 : This method is a helper method and used to prepare the mapping for PAR
     * @param  lstPARRecords        : Takes List of Submitted PAR records
     * @return                      : returns Map<Id, Id> 'Key' as PAR Id and 'Value' as Group/Queue ID to assign owner to IA/BLA records
     * @last modified by            : Uzma Md
     * @last modified date          : (Add if modified by you)
     * @last modified details       : (Add if modified by you)
     */
     private static Map<Id, QueueIdAndNamePair> getRSGroupMapForPAR(List<PreliminaryApplicationRef> lstPARRecords) {
        Set<String> typeSet = new Set<String>();
        Set<String> subTypeSet = new Set<String>();
        Set<String>licenseTypeNameSet = new Set<String>();
        Set<String> uniqueFilterSet = new Set<String>();
        Map<String,String> keyToQueueMap = new Map<String,String>();
        Set<String> boardNameSet = new Set<String>();
        for(PreliminaryApplicationRef par: lstPARRecords){
            typeSet.add(par.Type__c);
            subTypeSet.add(par.Amendment_Type__c);
            licenseTypeNameSet.add(par.Regulatory_Authorization_Type__r.Name);
            String key = par.Type__c + '-' + par.Amendment_Type__c + '-' + par.Regulatory_Authorization_Type__r.Name;
            if(par.Amendment_Type__c == UPDATE_LAWFUL_PRESENCE_AMENDMENT){
                licenseTypeNameSet.add(par.Board_Name__c);
                key = par.Type__c + '-' + par.Amendment_Type__c + '-' + par.Board_Name__c;
            }
        
        }
        if(!typeSet.isEmpty() && !subTypeSet.isEmpty() && !licenseTypeNameSet.isEmpty()){
            String customMetaDataFields = 'DeveloperName, Label, License_Type__c, Type__c, Sub_Type__c, Queue_Name__c, Unique_Filter__c';
            String whereClause =  'License_Type__c IN '+LPI_ServiceUtility.getStringValuesByStringSet(licenseTypeNameSet) + 
            ' AND Type__c IN '+LPI_ServiceUtility.getStringValuesByStringSet(typeSet) +
            ' AND Sub_Type__c IN '+ LPI_ServiceUtility.getStringValuesByStringSet(subTypeSet);
            
            List<LPI_QueueMapping__mdt> queueMappingCustomMetaDataList = (List<LPI_QueueMapping__mdt>)LPI_CustomMetadataTypeDAO.getCustomMetaDataByDymanicQuery(customMetaDataFields, 'LPI_QueueMapping__mdt', whereClause, null, null, null);
            
            for(LPI_QueueMapping__mdt queueMetaData : queueMappingCustomMetaDataList){
                String key = combineTypeSubTypeAndRegAuthType(queueMetaData.Type__c, queueMetaData.Sub_Type__c, queueMetaData.License_Type__c);
                if(String.isNotBlank(queueMetaData.Unique_Filter__c)){
                    key += '-' + queueMetaData.Unique_Filter__c;
                }
                keyToQueueMap.put(key,queueMetaData.Queue_Name__c);
            }
            
            Map<Id, QueueIdAndNamePair> mapParToQueue = new Map<Id,QueueIdAndNamePair>();
            Map<String, Set<Id>> mapIssueDeptToId = new Map<String, Set<Id>>();
            for (PreliminaryApplicationRef parRecord : lstPARRecords) {
                String key = combineTypeSubTypeAndRegAuthType(parRecord.Type__c, parRecord.Amendment_Type__c, parRecord.Regulatory_Authorization_Type__r.Name);
                if(parRecord.Amendment_Type__c == UPDATE_LAWFUL_PRESENCE_AMENDMENT){
                    key = parRecord.Type__c + '-' + parRecord.Amendment_Type__c + '-' + parRecord.Board_Name__c;
                }
                
                
                String boardName = '';
                if(keyToQueueMap.containsKey(key)){
                    boardName = keyToQueueMap.get(key);
                }
                else{
                    boardName = parRecord.Regulatory_Authorization_Type__r?.IssuingDepartment?.Name.length() > 40
                    ? parRecord.Regulatory_Authorization_Type__r?.IssuingDepartment?.Name.substring(0, 40)
                    : parRecord.Regulatory_Authorization_Type__r?.IssuingDepartment?.Name;
                }
                if (!mapIssueDeptToId.containsKey(boardName)) {
                    mapIssueDeptToId.put(boardName, new Set<Id>());
                }
                mapIssueDeptToId.get(boardName).add(parRecord.Id);
            }
            if (!mapIssueDeptToId.isEmpty()) {
                List<Group> lstQueue = [
                SELECT ID, Name
                FROM Group
                WHERE Type = :LPI_LiteralConstant.QUEUE_SOBJECT_API_NAME AND Name IN :mapIssueDeptToId.keySet()
                WITH SECURITY_ENFORCED
                ];
                if (!lstQueue.isEmpty()) {
                    for (Group groupRec : lstQueue) {
                        for (Id id : mapIssueDeptToId.get(groupRec.Name)) {
                            QueueIdAndNamePair obj = new QueueIdAndNamePair();
                            obj.queueId = groupRec.Id;
                            obj.queueName = groupRec.Name;
                            mapParToQueue.put(id, obj);
                        }
                    }
                }
            }
            return mapParToQueue;
        }
        return null;
    }

    /**
     * @author                      : MTX Group Product Team
     * @since                       : 20 Sept, 2023
     * @description                 : This method is Combine Type, SubType and License Type
     * @param  lstPARRecords        : Take Type, SubType, RegAuthType
     * @return                      : returns key (Combination of Type, SubType and License Type)
     * @last modified by            : Uzma Md
     * @last modified date          : (Add if modified by you)
     * @last modified details       : (Add if modified by you)
     */
    private Static String combineTypeSubTypeAndRegAuthType(String type, String subType, String regAuthType) {
        return type + '-' + subType + '-' + regAuthType;
    }
        

    
    private static Map<Id, Id> getRecordTypeMapForPAR(
        List<PreliminaryApplicationRef> lstPARRecords,
        Map<Id, String> regAuthMap
    ) {
        Map<Id, Id> mapParIdToRecordTypeId = new Map<Id, Id>();
        Map<String, Schema.RecordTypeInfo> mapIARecordTypeInfo = Schema.SObjectType.IndividualApplication.getRecordTypeInfosByDeveloperName();
        Map<String, Schema.RecordTypeInfo> mapBLARecordTypeInfo = Schema.SObjectType.BusinessLicenseApplication.getRecordTypeInfosByDeveloperName();
        Map<String, Map<String, String>> mapMetadaConfigs = new Map<String, Map<String, String>>();
        for (
            LPI_Profession_LicenseType_Mapping__mdt profLicTypeMappingRec : LPI_CustomMetadataTypeDAO.getAllMODPRProfessionLicenseType()
        ) {
            String key;
            if (String.isNotBlank(profLicTypeMappingRec.Related_License__c)) {
                key = 'Other';
                if (String.isNotBlank(profLicTypeMappingRec.Board_Name__c)) {
                    key = profLicTypeMappingRec.Board_Name__c;
                }
            }
            if (String.isNotBlank(key)) {
                Map<String, String> mapLicenseToRecordTypeDevName = new Map<String, String>();
                for (String licenceType : profLicTypeMappingRec.Related_License__c.split('@')) {
                    mapLicenseToRecordTypeDevName.put(licenceType, profLicTypeMappingRec.DeveloperName);
                }
                if (!mapMetadaConfigs.containsKey(key)) {
                    mapMetadaConfigs.put(key, new Map<String, String>());
                }
                mapMetadaConfigs.get(key).putAll(mapLicenseToRecordTypeDevName);
            }
        }
        
        if (!mapMetadaConfigs.isEmpty()) {
            for (PreliminaryApplicationRef parRecord : lstPARRecords) {
                String configKey;
                if (
                    mapMetadaConfigs.containsKey(parRecord.Board_Name__c) &&
                    mapMetadaConfigs.get(parRecord.Board_Name__c)
                        .containsKey(parRecord.Regulatory_Authorization_Type__r.Name)
                ) {
                    configKey = parRecord.Board_Name__c;
                } else if (mapMetadaConfigs.get('Other').containsKey(parRecord.Regulatory_Authorization_Type__r.Name)) {
                    configKey = 'Other';
                }
                if (string.isNotBlank(configKey)) {
                    Map<String, String> mapLicenseTypeToRecordTypeAPIName = mapMetadaConfigs.get(configKey);
                    Id recordTypeId;
                    
                    if (
                        regAuthMap.get(parRecord.Regulatory_Authorization_Type__c) ==
                        LPI_LiteralConstant.INDIVIDAULICENSE_APPTYPE
                    ) {
                        recordTypeId = mapIARecordTypeInfo.get(
                                mapLicenseTypeToRecordTypeAPIName.get(parRecord.Regulatory_Authorization_Type__r.Name)
                            )
                            .getRecordTypeId();
                    } else if (
                        regAuthMap.get(parRecord.Regulatory_Authorization_Type__c) ==
                        LPI_LiteralConstant.BUSINESSLICENSE_APPTYPE
                    ) {
                        recordTypeId = mapBLARecordTypeInfo.get(
                                mapLicenseTypeToRecordTypeAPIName.get(parRecord.Regulatory_Authorization_Type__r.Name)
                            )
                            .getRecordTypeId();
                    }
                    mapParIdToRecordTypeId.put(parRecord.Id, recordTypeId);
                }
            }
        }
        return mapParIdToRecordTypeId;
    }

    /**
     * @author                      : MTX Group Product Team
     * @since                       : 12 Jan, 2023
     * @description                 : This method is a helper method and used to prepare ratIdWithFees, regAuthMap and regAuthMapCategory
     * @param  lstNewBLARecords     : Takes Set<Id> ratIdSet, Map<Id, List<Fees__c>> ratIdWithFees, Map<Id, String> regAuthMap, and
     *                                Map<Id, String> regAuthMapCategory
     * @return                      : `void`
     * @last modified by            : Uzma Md
     * @last modified date          : (Add if modified by you)
     * @last modified details       : (Add if modified by you)
     */
    private static void prepareFeesRegAuthAndRegAuthCategoryMaps(
        Set<Id> ratIdSet,
        Map<Id, List<Fees__c>> ratIdWithFees,
        Map<Id, String> regAuthMap,
        Map<Id, String> regAuthMapCategory,
        Set<Id> setPARId,
        Map<Id, List<Temp_Fee__c>> parIdWithTempFees
    ) {
        for (Fees__c fee : LPI_FeesDAO.getFeesDetailsByRATTypeId(ratIdSet)) {
            if (!ratIdWithFees.containsKey(fee.Regulatory_Authorization_Type__c)) {
                ratIdWithFees.put(fee.Regulatory_Authorization_Type__c, new List<Fees__c>());
            }
            ratIdWithFees.get(fee.Regulatory_Authorization_Type__c).add(fee);
        }
        for (Temp_Fee__c tempFee : LPI_FeesDAO.getTempFeesDetailsByParId(setPARId)) {
            if (!parIdWithTempFees.containsKey(tempFee.PreliminaryApplicationReference__c)) {
                parIdWithTempFees.put(tempFee.PreliminaryApplicationReference__c, new List<Temp_Fee__c>());
            }
            parIdWithTempFees.get(tempFee.PreliminaryApplicationReference__c).add(tempFee);
        }
        for (RegulatoryAuthorizationType regAuth : LPI_RegulatoryAuthorizationTypeDAO.getRATTypeByID(ratIdSet)) {
            regAuthMap.put(regAuth.Id, regAuth.Authorisation_Type__c);
            regAuthMapCategory.put(regAuth.Id, regAuth.RegulatoryAuthCategory);
        }
    }


    /**
     * @author                      : MTX Group Product Team
     * @since                       : Dec 20, 2022
     * @description                 : This method update board name on IA
     */
    public static void updateBoardName(
        List<PreliminaryApplicationRef> newList,
        Map<Id, PreliminaryApplicationRef> oldMap
    ) {
        Map<PreliminaryApplicationRef, Id> parToLicenseTypeNameMap = new Map<PreliminaryApplicationRef, Id>();
        for (PreliminaryApplicationRef parRecord : newList) {
            if (
                (oldMap == null ||
                oldMap.get(parRecord.Id).Regulatory_Authorization_Type__c !=
                parRecord.Regulatory_Authorization_Type__c) && parRecord.Regulatory_Authorization_Type__c != null
            ) {
                parToLicenseTypeNameMap.put(parRecord, parRecord.Regulatory_Authorization_Type__c);
            }
        }
        if (!parToLicenseTypeNameMap.isEmpty()) {
            Map<Id, String> ratToBoardNameMap = new Map<Id, String>();
            Set<Id> ratIdSet = new Set<Id>(parToLicenseTypeNameMap.values());

            for (
                RegulatoryAuthorizationType ratRecord : LPI_RegulatoryAuthorizationTypeDAO.getRATTypeByID(ratIdSet)
            ) {
                ratToBoardNameMap.put(ratRecord.Id, ratRecord.IssuingDepartment.Name);
            }
            if (!ratToBoardNameMap.isEmpty()) {
                for (PreliminaryApplicationRef parRecord : parToLicenseTypeNameMap.keySet()) {
                    if (ratToBoardNameMap.containsKey(parRecord.Regulatory_Authorization_Type__c)) {
                        parRecord.Board_Name__c = ratToBoardNameMap.get(parRecord.Regulatory_Authorization_Type__c);
                    }
                }
            }
        }
    }
    
    /**
     * @author                      : MTX Group Product Team
     * @since                       : Feb 21 , 2023
     * @description                 :
     */
    public static void updateIAAndBLAOnApplicationDocument(List<SObject> applicationList) {
        Map<Id, Id> mapOfParToApplicationId = new Map<Id, Id>();
        for (SObject record : applicationList) {
            mapOfParToApplicationId.put((Id) record.get('SavedApplicationRefId'), (Id) record.get('Id'));
        }
        if (!mapOfParToApplicationId.isEmpty()) {
            List<Application_Document__c> lstAppDocumentsToUpdate = new List<Application_Document__c>();
            String sObjName = '';
            for (
                Application_Document__c appDocument : LPI_ApplicationDocumentDAO.getApplicationContentByPARId(
                    mapOfParToApplicationId.keySet()
                )
            ) {
                sObjName = mapOfParToApplicationId.get(appDocument.Preliminary_Application_Reference__c)
                    .getSObjectType()
                    .getDescribe()
                    .getName();
                if (sObjName == LPI_LiteralConstant.IA_SOBJECT_API) {
                    lstAppDocumentsToUpdate.add(
                        new Application_Document__c(
                            Id = appDocument.Id,
                            Individual_Application__c = mapOfParToApplicationId.get(
                                appDocument.Preliminary_Application_Reference__c
                            )
                        )
                    );
                } else if (sObjName == LPI_LiteralConstant.BLA_SOBJECT_API) {
                    lstAppDocumentsToUpdate.add(
                        new Application_Document__c(
                            Id = appDocument.Id,
                            Business_License_Application__c = mapOfParToApplicationId.get(
                                appDocument.Preliminary_Application_Reference__c
                            )
                        )
                    );
                }
            }
            if (!lstAppDocumentsToUpdate.isEmpty()) {
                LPI_WithoutSharingUtility.updateSObjectRecord(lstAppDocumentsToUpdate);
            }
        }
    }

    /**
     * @author                : MTX Group Product Team
     * @param recordsList     : New Par Record
     * @param mapOfOldRecords : Old Par Records
     * @description           : This method will Update the Name on IA of If It's Updated on PAR
     */
    public static void updateNameOnIAIfUpdatedOnPar(
        List<PreliminaryApplicationRef> recordsList,
        Map<Id, PreliminaryApplicationRef> mapOfOldRecords
    ) {
        try {
            List<IndividualApplication> updateIA = new List<IndividualApplication>();
            Set<Id> setUpdatedPARId = new Set<Id>();
            Set<Id> iaIds = new Set<Id>();

            for (PreliminaryApplicationRef updatedParRecord : recordsList) {
                if (
                    updatedParRecord.FirstName__c != mapOfOldRecords.get(updatedParRecord.Id).FirstName__c ||
                    updatedParRecord.MiddleName__c != mapOfOldRecords.get(updatedParRecord.Id).MiddleName__c ||
                    updatedParRecord.LastName__c != mapOfOldRecords.get(updatedParRecord.Id).LastName__c
                ) {
                    setUpdatedPARId.add(updatedParRecord.Id);
                }
            }
           
            if (!setUpdatedPARId.isEmpty()) {
                for (
                    IndividualApplication iaRecord : LPI_IndividualApplicationDAO.getILABySavedAppRefId(
                        setUpdatedPARId
                    )
                ) {
                    IndividualApplication updatedId = new IndividualApplication(Id = iaRecord.Id);
                    updatedId.First_Name__c = iaRecord.SavedApplicationRef.FirstName__c;
                    updatedId.Middle_Name__c = iaRecord.SavedApplicationRef.MiddleName__c;
                    updatedId.Last_Name__c = iaRecord.SavedApplicationRef.LastName__c;
                    updateIA.add(updatedId);
                }

                if (!updateIA.isEmpty()) {
                    LPI_DML.doUpdate(updateIA);
                }
            }
        } catch (Exception ex) {
            LPI_ExceptionManager.logException(getClassName(), 'updateNameOnIAIfUpdatedOnPar', ex);
        }
    }

    
    /*
     * @author                      : MTX Group Product Team
     * @since                       : 25 June, 2023
     * @description                 : This method is used to call saveAPI for lawful presence
     * @param listOfNewApplication  : New Par Record
     * @return                      : Void
     * @last modified by            : Uzma Md
     * @last modified date          : (Add if modified by you)
     * @last modified details       : (Add if modified by you)
     */
    public static void updateAccountOnSaveAPI(
        List<PreliminaryApplicationRef> listOfNewApplication,
        Map<Id, PreliminaryApplicationRef> mapOfOldRecords
    ) {
        try {
            Set<Id> parIdSetForAddress = new Set<Id>();
            Set<Id> updateAccountIdSet = new Set<Id>();
            Set<Id> parIdSet = new Set<Id>();
            Set<Id> parIdSetForApi = new Set<Id>();
            Set<Id> parIdSetForApiNotTriggered = new Set<Id>();
            Set<Id> accountIdSet = new Set<Id>();
            
            Map<Id, Account> accIdToAccMap = new Map<Id, Account>();
            for (PreliminaryApplicationRef parRecord : listOfNewApplication) {
                if (
                     
                    mapOfOldRecords.get(parRecord.Id).Status__c != parRecord.Status__c &&
                    parRecord.Status__c == IA_CONVERTED_STATUS &&
                    String.isNotBlank(parRecord.BusinessAccountNameId)
                ) {
                    parIdSet.add(parRecord.Id);
                }
            }
            if (!parIdSet.isEmpty()) {
                String parFields =
                    'BusinessAccountName.Id, BusinessAccountName.Citizenship__c, BusinessAccountName.Proof_of_work_permit_in_United_States__c, ' +
                    'BusinessAccountName.Proof_of_Citizenship__c, BusinessAccountName.PersonOtherCountry, ' +
                    'USCIS_Number__c, SEVIS_ID__c, US_Permanent_Resident_Card_Number__c, Passport_Number__c, VISA_Number__c, Naturalization_Number__c, ' +
                    'Proof_of_Citizenship__c, Proof_of_work_permit_in_United_States__c, H1B_Visa_Number__c,Type__c, Amendment_Type__c';
                String parIdClause =
                    'Id IN ' + LPI_ServiceUtility.getStringValuesBySet(parIdSet);
                List<PreliminaryApplicationRef> parList = LPI_PreliminaryApplicationRefDAO.getPreliminaryApplicationRefByDymanicQuery(
                    parFields,
                    parIdClause,
                    null,
                    null,
                    null
                );
                if (!parList.isEmpty()) {
                    for (PreliminaryApplicationRef par : parList) {
                         
                        if (
                            (((
                            par.Proof_of_work_permit_in_United_States__c != H1B_VISA) ||
                            (
                            !PROOF_OF_CITIZENSHIP_SET.contains(par.Proof_of_Citizenship__c))))
                        ) {
                            if(APPLICABLE_TYPES_SET.contains(par.Type__c)){
                                 
                                parIdSetForAddress.add(par.Id); 
                            }else if(par.Amendment_Type__c == UPDATE_LAWFUL_PRESENCE_AMENDMENT){
                                parIdSetForApi.add(par.Id);
                            }
                        }else{
                            parIdSetForApiNotTriggered.add(par.Id);
                        }
                        Account acc = new Account();
                        
                        acc.Id = par.BusinessAccountNameId;
                        if(String.isNotBlank(par.Proof_of_work_permit_in_United_States__c)){
                            acc.Proof_of_work_permit_in_United_States__c = par.Proof_of_work_permit_in_United_States__c;
                            if(VISA_PERMIT_SET.contains(par.Proof_of_work_permit_in_United_States__c)){
                                if(par.Proof_of_work_permit_in_United_States__c == HB_VISA){
                                    acc.H1B_Visa_Number__c = par.H1B_Visa_Number__c;
                                    acc.LawfulPresence__c = VALUE_YES;
                                    acc.Is_the_address_in_US_or_International__c = API_TRIGGERED_VALUE_NO;
                                }else{
                                    acc.VISA_Number__c = par.VISA_Number__c;
                                }
                                 
                                acc.Passport_Number__c = par.Passport_Number__c;
                            }
                            else if(US_RESIDENTS_SET.contains(par.Proof_of_work_permit_in_United_States__c)){
                                acc.US_Permanent_Resident_Card_Number__c = par.US_Permanent_Resident_Card_Number__c;
                                acc.USCIS_Number__c = par.USCIS_Number__c;
                            }else if (par.Proof_of_work_permit_in_United_States__c == STUDENT_VISA) {
                                acc.SEVIS_ID__c = par.SEVIS_ID__c;
                                
                                acc.Passport_Number__c = par.Passport_Number__c;
                                 
                            }
                        }else if(String.isNotBlank(par.Proof_of_Citizenship__c)){
                            acc.Proof_of_Citizenship__c = par.Proof_of_Citizenship__c;
                            if(PROOF_OF_CITIZENSHIP_SET.contains(par.Proof_of_Citizenship__c)){
                                acc.LawfulPresence__c = VALUE_NA;
                                acc.Is_the_address_in_US_or_International__c = VALUE_YES;
                            }else{
                                acc.Naturalization_Number__c = par.Naturalization_Number__c;
                                
                                acc.USCIS_Number__c = par.USCIS_Number__c;
                            }
                        }
                         
                        accIdToAccMap.put(par.BusinessAccountNameId, acc);
                    }
                }
            }
            
            if (!parIdSetForAddress.isEmpty()) {
                Map<String, String> locationIdToParIdMap = new Map<String, String>();
                Map<String, String> locationIdToAccountIdMap = new Map<String, String>();
                String tempAuthPlaceWhereClause =
                    'Preliminary_Application_Reference__c IN ' +
                    LPI_ServiceUtility.getStringValuesBySet(parIdSetForAddress);
                
                List<Temp_AuthApplicationPlace__c> tempAAP = LPI_TempAuthApplicationPlaceDAO.getTempAuthApplicationPlaceByDymanicQuery(
                    'Id, Location__c, Preliminary_Application_Reference__c, Preliminary_Application_Reference__r.BusinessAccountNameId',
                    tempAuthPlaceWhereClause,
                    null,
                    null,
                    null
                );
                 
                for (Temp_AuthApplicationPlace__c temp : tempAAP) {
                    locationIdToParIdMap.put(temp.Location__c, temp.Preliminary_Application_Reference__c);
                    locationIdToAccountIdMap.put(
                        temp.Location__c,
                        temp.Preliminary_Application_Reference__r.BusinessAccountNameId
                    );
                }
                if (!locationIdToParIdMap.isEmpty()) {
                    
                    for(Id parId : parIdSetForAddress){
                        if(!locationIdToParIdMap.values().contains(parId)){
                            parIdSetForApiNotTriggered.add(parId);
                        }
                    }
                    String addressQueryFields = 'Id, Country, ParentId';
                    String addressWhereClause =
                        'ParentId IN ' +
                        LPI_ServiceUtility.getStringValuesByStringSet(locationIdToParIdMap.keySet()) +
                        ' AND Parent.LocationType = \'' +
                        RESIDENCE_ADDRESS +
                        '\'';
                     
                    LPI_AddressDAO.LPI_AddressDAOWithoutSharing addressQuery = new LPI_AddressDAO.LPI_AddressDAOWithoutSharing();
                    List<Schema.Address> addressList = addressQuery.getAddressByDymanicQuery(
                        addressQueryFields,
                        addressWhereClause,
                        null,
                        null,
                        null
                    );
                    
                    if (!addressList.isEmpty()) {
                        for (Schema.Address addr : addressList) {
                            if (addr.Country == UNITED_STATES) {
                                 
                                parIdSetForApi.add(locationIdToParIdMap.get(addr.parentId));                               
                            } else {
                                 
                                updateAccountIdSet.add(locationIdToAccountIdMap.get(addr.parentId));
                                parIdSetForApiNotTriggered.add(locationIdToParIdMap.get(addr.parentId));
                            }
                        }
                    }
                }
                
                else{
                    parIdSetForApiNotTriggered.addAll(parIdSetForAddress);  
                }
            }
            
            if (!updateAccountIdSet.isEmpty()) {
                for (Id accId : updateAccountIdSet) {
                    Account acc;
                    if(accIdToAccMap.containsKey(accId)){
                        acc = accIdToAccMap.get(accId);
                    }else{
                        acc = new Account();
                        acc.Id = accId;
                    }
                    acc.LawfulPresence__c = VALUE_NA_NON_RESIDENT;
                    acc.Is_the_address_in_US_or_International__c = API_TRIGGERED_VALUE_NO;
                    accIdToAccMap.put(accId, acc);
                    
                }
            }
            if (!accIdToAccMap.isEmpty()) {
                LPI_WithoutSharingUtility.updateSObjectList(accIdToAccMap.values());
            }
            if(!parIdSetForApiNotTriggered.isEmpty()){
                String ilaFields = 'ID,SavedApplicationRefId';
                
                LPI_IndividualApplicationDAO.LPI_DAO_IndividualApptWithoutSecurity ind = new LPI_IndividualApplicationDAO.LPI_DAO_IndividualApptWithoutSecurity();
                String whereClause = 'SavedApplicationRefId IN ' + LPI_ServiceUtility.getStringValuesBySet(parIdSetForApiNotTriggered);
                List<IndividualApplication> ilaList = ind.getIndividualApplicationByDymanicQuery(
                    ilaFields,
                    whereClause,
                    null,
                    null,
                    null
                );
                List<IndividualApplication> updateIaList = new List<IndividualApplication>();
                if(!ilaList.isEmpty()){
                    for(IndividualApplication ia : ilaList){
                        IndividualApplication newIA = new IndividualApplication();
                        newIA.Id = ia.Id;
                        newIA.Is_API_Triggered__c = API_TRIGGERED_VALUE_NO;
                        updateIaList.add(newIA);
                   }
                   if(!updateIaList.isEmpty()){
                       LPI_WithoutSharingUtility.updateSObjectList(updateIaList);
                   }
               }
            }
            
            if (!parIdSetForApi.isEmpty()) {
                 
            }
        } catch (Exception ex) {
            LPI_ExceptionManager.logException(getClassName(), 'updateAccountOnSaveAPI', ex);
        }
    }


    /*
     * @author                      : MTX Group Product Team
     * @since                       : 24 July, 2023
     * @description                 : This method is used to get the IA and BLA Id for PAR records
     * @param parIdsForIA           : Set<Id>
     * @param parIdsForBLA          : Set<Id>
     * @param parIdToIAIdMap        : Map<Id,Id>
     * @param parIdToBLAIdMap       : Map<Id,Id>
     * @return                      : Void
     * @last modified by            : Uzma Md
     * @last modified date          : (Add if modified by you)
     * @last modified details       : (Add if modified by you)
     */
    private static void populateParToApplicationIdMap(
        Set<Id> parIdsForIA,
        Set<Id> parIdsForBLA,
        Map<Id, Id> parIdToIAIdMap,
        Map<Id, Id> parIdToBLAIdMap
    ) {
        String fieldToQuery = 'Id,Name,SavedApplicationRefId';
        String whereClause = '';
        if (!parIdsForIA.isEmpty()) {
            whereClause = 'SavedApplicationRefId IN ' + LPI_ServiceUtility.getStringValuesBySet(parIdsForIA);
            for (
                IndividualApplication ia : LPI_IndividualApplicationDAO.getIndividualApplicationByDymanicQuery(
                    fieldToQuery,
                    whereClause,
                    null,
                    null,
                    null
                )
            ) {
                parIdToIAIdMap.put(ia.SavedApplicationRefId, ia.Id);
            }
        }
        if (!parIdsForBLA.isEmpty()) {
            whereClause = 'SavedApplicationRefId IN ' + LPI_ServiceUtility.getStringValuesBySet(parIdsForBLA);
            for (
                BusinessLicenseApplication bla : LPI_BusinessLicenseApplicationDAO.getBusinessLicenseApplicationByDymanicQuery(
                    fieldToQuery,
                    whereClause,
                    null,
                    null,
                    null
                )
            ) {
                parIdToBLAIdMap.put(bla.SavedApplicationRefId, bla.Id);
            }
        }
    }

    private class QueueIdAndNamePair{
        public Id queueId;
        public String queueName;
    }
}