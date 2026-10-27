/**
* @description       : Controller class to file complaints by logged in and guest user
* @author            : MTX Group Product Team
* @group             :
* @last modified on  : 06-04-2024
* @last modified by  : MTX Group Product Team
**/
public with sharing class LPI_ComplaintsController {
    
   
    public static final String INVALID_ERR_MSG = 'Invalid Data';
    public static final String RESPONDENT_EXCEEDED_ERR_MSG = 'You cannot add more that 10 respondents in a single complaint.';
    public static final String WITNESS_EXCEEDED_ERR_MSG = 'You cannot add more that 10 witnesses in a single complaint.';
    public static final String REPORTED_FUTURE_DATE_ERR_MSG = 'Reported Date Can\'t be a Future Date';
    
    
    public static final String ONLINE_PORTAL = 'Online Portal';
    public static final String COMPLAINT_STATUS_NEW = 'New';
    public static final String COMPLAINT_STATUS_SUBMITTED = 'Submitted';
    public static final String QUEUE_TYPE = 'Queue';
    public static final String COMPLAINTS_QUEUE = 'COSBAR Complaints';
    private static final String SUPPORT_STAFF_PROFILE = 'Support Staff';
    public static final String DRAFT_STATUS_TEXT = 'Draft';
    private static final String LOC_TEXT_OPEN = 'Open';
    private static final String COMPLAINT_FLOW_NAME ='complaint';
    private static final String CASH_RECIEVING_ROOM = 'Cash Receive Room';
    private static final String INTERNAL_STAFF_MEMBERS = 'Internal Staff Members';

    private static final Set<String> COMPLAINT_SECTION_EDITABLE_PROFILE_SET = new Set<String>{
        'Board Staff',
            'System Administrator',
            'Inspectors'
            };
    
    private static final String GENERIC_QUEUE = 'Generic Queue';
    private static final Set<String> OTHER_RELATED_QUEUES = new Set<String>{
        COMPLAINTS_QUEUE,
        INTERNAL_STAFF_MEMBERS,
        GENERIC_QUEUE
    };
    public static List<String> PROFESSIONS_TO_EXCLUDE = new List<String>{
        'Exempt'
    };
    public static final String CASE_OBJECT = 'Case';
    public static final String CASE_OBJECT_API_NAME = 'Case__c';
    private static final String PHARMACIST_TEXT = 'Pharmacist';
 
    /**
    * @author                      :MTX Group Product Team
    * @since                       : 10 May 2023
    * @description                 : Method is used to Get Current User Details.
    * @return                      : `LPI_Wrapper.ComplaintsWrapper`
    * @last modified by            : MTX Group Product Team
    * @last modified date          : 11 May 2023
    * @modified details            : Code Review Fixes
    */
    @AuraEnabled
    public static LPI_Wrapper.ComplaintsWrapper getCurrentUserDetails() {
        try {
            
            
            String fields = 'Id,Account.Social_Security_Number__c,Account.Date_of_Birth__c,Contact.FirstName, Contact.LastName, Contact.MiddleName, Account.PersonEmail,Account.PersonHomePhone, Account.Phone, Account.PersonOtherStreet, Account.PersonOtherStateCode,Account.PersonOtherCity, Account.PersonOtherPostalCode,Profile.Name';
            
            String whereClause = 'ID = \'' + UserInfo.getUserId() + '\'';
            List<User> userRecList = LPI_UserDao.getUserByDymanicQueryWithoutSecurityEnforced(
                fields,
                whereClause,
                null,
                null,
                null
            );
            User userRec = userRecList[0];
            LPI_Wrapper.ComplaintsWrapper wrapper = new LPI_Wrapper.ComplaintsWrapper();
            wrapper.firstName = userRec.Contact.FirstName;
            wrapper.lastName = userRec.Contact.LastName;
            wrapper.middleName = userRec.Contact.MiddleName;
            wrapper.telephone = userRec.Account.PersonHomePhone;
            wrapper.email = userRec.Account.PersonEmail;
            wrapper.cellPhone = userRec.Account.Phone;
           
            wrapper.ssn = userRec.Account.Social_Security_Number__c;
            wrapper.dob = userRec.Account.Date_of_Birth__c;            
            wrapper.complainantAddressData = new LPI_Wrapper.AddressWrapper();
            wrapper.complainantAddressData.streetOne = userRec.Account.PersonOtherStreet;
            wrapper.complainantAddressData.city = userRec.Account.PersonOtherCity;
            wrapper.complainantAddressData.state = userRec.Account.PersonOtherStateCode;
            wrapper.complainantAddressData.zipCode = userRec.Account.PersonOtherPostalCode;
            wrapper.isCompliantSectionEditable = COMPLAINT_SECTION_EDITABLE_PROFILE_SET.contains(userRec.Profile.Name);
            wrapper.isSupportStaff = userRec.Profile.Name ==SUPPORT_STAFF_PROFILE;
            return wrapper;
        } catch (Exception e) {
            LPI_ExceptionManager.logException(
                'LPI_ComplaintsController',
                'getCurrentUserDetails',
                e
            );
            throw new LPI_Exception(e.getMessage());
        }
    }
/**
* @author                      : MTX Group Product Team
* @since                       : 10 May 2023
* @description                 : Method is used to Get Profession Options
* @param professionType        : Getting Profession Options List based on professionType/Board.
* @return                      : `List<LPI_Wrapper.ProfessionOptionWrapper>`
* @last modified by            : MTX Group Product Team
* @last modified date          : 11 May 2023
* @modified details            : Code Review Fixes
*/
                @AuraEnabled(cacheable=true)
                public static List<LPI_Wrapper.ProfessionOptionWrapper> getProfessionOptions(String authType
                ) {
                    try {
                        List<LPI_Wrapper.ProfessionOptionWrapper> optionsList = new List<LPI_Wrapper.ProfessionOptionWrapper>();
                        Set<String> boardName = new Set<String>();
                       

                        String fields = 'Id,Name, Issuing_Department_Name__c,IssuingDepartmentId,Authorisation_Type__c';
                        String whereClause = 'Authorisation_Type__c = \'' +String.escapeSingleQuotes(authType)+ '\'';
                        whereClause += ' AND Issuing_Department_Name__c != null';
    
                        LPI_Wrapper.ProfessionOptionWrapper noneOption = new LPI_Wrapper.ProfessionOptionWrapper();
                        for(RegulatoryAuthorizationType reg : (new LPI_RegulatoryAuthorizationTypeDAO.LPI_RegulatoryAuthorizationTypeWithoutSharingDAO()).getRegAuthTypeWithoutSecurity(fields,whereClause,null,'Name','ASC')) {
                            if(!boardName.contains(reg.Issuing_Department_Name__c)){
                                boardName.add(reg.Issuing_Department_Name__c);
                                LPI_Wrapper.ProfessionOptionWrapper option = new LPI_Wrapper.ProfessionOptionWrapper();
                                option.label = reg.Issuing_Department_Name__c;
                                option.value = reg.Issuing_Department_Name__c;
                                option.uniqueKey = reg.IssuingDepartmentId;
                                option.boardName = reg.Issuing_Department_Name__c;
                                optionsList.add(option);
                            }
                         }
               
                        return optionsList;
                    } catch (Exception e) {
                        LPI_ExceptionManager.logException(
                            'LPI_ComplaintsController',
                            'getProfessionOptions',
                            e
                        );
                        throw new LPI_Exception(e.getMessage());
                    }
                }
/**
* @author                      : MTX Group Product Team
* @since                       : 8 Nov 2023
* @description                 : Method is used to Get Profession Options
* @param professionType        : Getting License Type Options List based on professionType/Board.
* @return                      : `List<LPI_Wrapper.ProfessionOptionWrapper>`
* @last modified by            : MTX Group Product Team
* @last modified date          : 11 May 2023
* @modified details            : Code Review Fixes
*/
@AuraEnabled(cacheable=true)
public static List<LPI_Wrapper.ProfessionOptionWrapper> getLicenseTypeOptions(
    String selectedBoardName,
    String authType
) {
    try {
        
        if(String.isBlank(selectedBoardName)) {
            throw new LPI_Exception('Could not find Suitable Board Name.');
        }
        List<LPI_Wrapper.ProfessionOptionWrapper> optionsList = new List<LPI_Wrapper.ProfessionOptionWrapper>();
        
        if(selectedBoardName.equals('Accountancy') && authType!=null && authType.equals('Business')) {
            LPI_Wrapper.ProfessionOptionWrapper option = new LPI_Wrapper.ProfessionOptionWrapper();
            option.label = 'CPA Firm';
            option.value = 'CPA Firm';
            option.boardName = 'Accountancy';
            optionsList.add(option);
        } else {
            String fields = 'Id,Name, Issuing_Department_Name__c,Authorisation_Type__c';
            String whereClause = 'Name NOT IN ' + LPI_ServiceUtility.getStringValuesByList(PROFESSIONS_TO_EXCLUDE) + ' AND Issuing_Department_Name__c = \'' + String.escapeSingleQuotes(selectedBoardName) + '\' AND Authorisation_Type__c = \'' +String.escapeSingleQuotes(authType)+ '\'';
    
            LPI_Wrapper.ProfessionOptionWrapper noneOption = new LPI_Wrapper.ProfessionOptionWrapper();
            for(RegulatoryAuthorizationType reg : (new LPI_RegulatoryAuthorizationTypeDAO.LPI_RegulatoryAuthorizationTypeWithoutSharingDAO()).getRegAuthTypeWithoutSecurity(fields,whereClause,null,'Name','ASC')) {
                LPI_Wrapper.ProfessionOptionWrapper option = new LPI_Wrapper.ProfessionOptionWrapper();
                    option.label = reg.Name;
                    option.value = reg.Name;
                    option.uniqueKey = reg.Id;
                    option.boardName = reg.Issuing_Department_Name__c;
                    optionsList.add(option);
            }
        }
        return optionsList;
    } catch (Exception e) {
        LPI_ExceptionManager.logException(
            'LPI_ComplaintsController',
            'getLicenseTypeOptions',
            e
        );
        throw new LPI_Exception(e.getMessage());
    }
}
    
    /**
* @author                      : MTX Group Product Team
* @since                       : 10 May 2023
* @description                 : Method is used to Get Business License Details
* @param jsonData              : Used to pass Serialized JSON Data
* @return                      : `List<LPI_Wrapper.RespondentWrapper>`
* @last modified by            : MTX Group Product Team
* @last modified date          : 11 May 2023
* @modified details            : Code Review Fixes
* @modified details            : Refactoring Code to Get the Details from Publicly Displayed Address.
*/
    @AuraEnabled
    public static List<LPI_Wrapper.RespondentWrapperNew> getBusinessLicenseDetails(
        String jsonData
    ) {
        try {
            if (String.isBlank(jsonData)) {
                return null;
            }
            Map<String,Object> wrapper = (Map<String,Object>) JSON.deserializeUntyped(jsonData);
            String profession = wrapper.containsKey('profession') ? (String)wrapper.get('profession') : '';
            String licenseType = wrapper.containsKey('licenseType') ? (String)wrapper.get('licenseType') : '';
            String authType = wrapper.containsKey('authType') ? (String)wrapper.get('authType') : '';
            List<String> selectedBusinessIdList = wrapper.containsKey('selectedBusinessIds') ? ((String)wrapper.get('selectedBusinessIds')).split(',') : new List<String>(); 
            String entityName = wrapper.containsKey('entityName') ? (String)wrapper.get('entityName'): '';
            if (
                String.isBlank(entityName) ||
                entityName.length() < 3 || entityName.containsIgnoreCase('%') || entityName.containsIgnoreCase('_')
            ) {
                return null;
            }

            entityName = '%' + entityName + '%';
            if(profession == 'Accountancy' && authType == 'Business') { 
                licenseType = null;
            }

            Map<String, LPI_Wrapper.RespondentWrapperNew> keyToWrapperMap = new Map<String, LPI_Wrapper.RespondentWrapperNew>();
            Set<String> locationIdSet = new Set<String>();
            String key;
            
            LPI_BusinessLicenseDAO.LPI_BusinessLicenseWithoutSharingDAO classObj = new LPI_BusinessLicenseDAO.LPI_BusinessLicenseWithoutSharingDAO();
            List<AuthApplicationPlace> appAuthList = new List<AuthApplicationPlace>();
            
            for (
                BusinessLicense blRec : classObj.getBusinessListByNameLicense(
                    entityName,
                    profession,
                    selectedBusinessIdList,
                    licenseType,
                    authType
                )
            ) {
                LPI_Wrapper.RespondentWrapperNew data = new LPI_Wrapper.RespondentWrapperNew();
                data.entityName = blRec.Business_Entity_Name__c;

                LPI_Wrapper.LicenseDetailsWrapper licenseDetails = new LPI_Wrapper.LicenseDetailsWrapper();
                licenseDetails.businessId = blRec.Id;
                licenseDetails.accountId = blRec.AccountId;
                licenseDetails.profession = blRec.RegulatoryAuthorizationType.Name;
                licenseDetails.authorizationType = blRec.RegulatoryAuthorizationType.Authorisation_Type__c;
                licenseDetails.licenseNum = String.isBlank(blRec.Legacy_License_Number__c) ?  blRec.Name : blRec.Legacy_License_Number__c; 
                licenseDetails.entityName = blRec.Business_Entity_Name__c;
                
                if(licenseDetails.authorizationType!=null && licenseDetails.authorizationType.equals(LPI_LiteralConstant.INDIVIDAULICENSE_APPTYPE)) {
                    data.firstName = blRec.First_Name__c;
                    data.middleName = blRec.Middle_Name__c;
                    data.lastName = blRec.Last_Name__c;
                }
                
                if(String.isNotBlank(blRec.AccountId)) {
                    LPI_Wrapper.AccountInfoWrapper accInfoObj = new LPI_Wrapper.AccountInfoWrapper();
                    accInfoObj.firstName = blRec.Account.FirstName;
                    accInfoObj.lastName = blRec.Account.LastName;
                    accInfoObj.middleName = blRec.Account.MiddleName;
                    accInfoObj.entityName = blRec.Account.Name;
                    accInfoObj.suffixName = blRec.Account.Suffix;
                    licenseDetails.licenseeAccountInfo = accInfoObj;
                    accInfoObj.dbaName = blRec.Account.Doing_Business_As_DBA_or_Trade_Name__c;
                    accInfoObj.corporateName = blRec.Account.Corporate_Name__c;
                }
                String AuthfieldstoQuery='Id,AuthorizationId,PlaceId';
                String AuthwhereClause ='AuthorizationId = \'' + String.escapeSingleQuotes(blRec.Id)+ '\'';
                
                LPI_AuthApplicationPlaceDAO.LPI_AuthApplicationPlaceWithoutSharingDAO AuthClassObj = new LPI_AuthApplicationPlaceDAO.LPI_AuthApplicationPlaceWithoutSharingDAO();
                for (
                    AuthApplicationPlace AuthAppRec : AuthClassObj.getAuthAppPlaceByDymQueryWithoutSecurity(
                    AuthfieldstoQuery,
                    AuthwhereClause,
                    null,
                    null,
                    null
                )
              ) {
                appAuthList.add(AuthAppRec);
              }
                data.licenseDetails = licenseDetails;
                keyToWrapperMap.put(blRec.Id, data);
            }
            Map<String,LPI_Wrapper.RespondentWrapperNew> mainWrapperMap = new Map<String,LPI_Wrapper.RespondentWrapperNew>();
            
            for(AuthApplicationPlace authPlaceRec: appAuthList) {
                
                key = authPlaceRec.PlaceId + '-' + authPlaceRec.AuthorizationId;
                 
                if(String.isBlank(authPlaceRec.AuthorizationId) || !keyToWrapperMap.containsKey(authPlaceRec.AuthorizationId)) {
                    continue;
                }
                 
                mainWrapperMap.put(key,keyToWrapperMap.get(authPlaceRec.AuthorizationId));
                locationIdSet.add(authPlaceRec.PlaceId);
            }
            
            
            if (locationIdSet.isEmpty()) {
                return keyToWrapperMap.values();
            }
            Map<String, LPI_Wrapper.AddressWrapper> keyToAddressMap = new Map<String, LPI_Wrapper.AddressWrapper>();
             
            LPI_AddressDAO.LPI_AddressDAOWithoutSharing addressClass = new LPI_AddressDAO.LPI_AddressDAOWithoutSharing();
            String fieldsToQuery = 'ID, Street, City, StateCode, PostalCode, Parent.LocationType, ParentId,Business_State__c,Parent.Consent_For__c,CountryCode,County__c,Parent.Status__c';
            String whereClause =
                'ParentId IN ' +
                LPI_ServiceUtility.getStringValuesByList(
                    new List<String>(locationIdSet)
                ) + ' AND Parent.Consent_For__c INCLUDES (\'Primary Contact Address\')'
                + ' AND Parent.Status__c = \''+ LOC_TEXT_OPEN+'\'';
            
            for (
                Schema.Address addressRecord : addressClass.getAddressWithoutSecurityEnforced(
                    fieldsToQuery,
                    whereClause,
                    '100',
                    null,
                    null
                )
            ) {
                LPI_Wrapper.AddressWrapper addressRecWrapper = new LPI_Wrapper.AddressWrapper();
                addressRecWrapper.streetOne = addressRecord.Street;
                addressRecWrapper.city = addressRecord.City;
                addressRecWrapper.state = addressRecord.StateCode;
                addressRecWrapper.otherState = String.isBlank(addressRecord.StateCode)?addressRecord.Business_State__c:null;
                addressRecWrapper.zipCode = addressRecord.PostalCode;
                addressRecWrapper.addressType = addressRecord.Parent.LocationType;
                addressRecWrapper.country = addressRecord.CountryCode;
                addressRecWrapper.isUs = addressRecWrapper.country == LPI_LiteralConstant.US_COUNTRY_CODE;
                addressRecWrapper.county = addressRecord.County__c;
                keyToAddressMap.put(addressRecord.ParentId, addressRecWrapper);
            }
             
            for (String keyString : mainWrapperMap.keySet()) {
                LPI_Wrapper.RespondentWrapperNew data = mainWrapperMap.get(
                    keyString
                );
                LPI_Wrapper.AddressWrapper addressRecWrapper = keyToAddressMap.get(
                    keyString.substringBefore('-')
                );
                if (
                    addressRecWrapper == null
                ) 
                {
                    continue;
                }
                data.addressData = addressRecWrapper; 
            }
            return keyToWrapperMap.values();
        } catch (Exception e) {
            LPI_ExceptionManager.logException(
                'LPI_ComplaintsController',
                'getBusinessLicenseDetails',
                e
            );
            throw new LPI_Exception(e.getMessage());
        }
    }
    
    /**  
    * @author                      : MTX Group Product Team
    * @since                       : 24 Oct 2023
    * @description                 : This Method is Used to Create Complaint Records per Respondent Created.
    * @return                      : `void`
    * @last modified by            : MTX Group Product Team
    * @last modified date          : 24 May 2023
    * @modified details            : Code Review Fixes
    */
    @AuraEnabled 
    public static LPI_Wrapper.ComplaintsWrapper createComplaintPerRespondent(String jsonData) {
        try {
             
            if (String.isBlank(jsonData)) {
                return null;
            }
            List<PublicComplaint> pcList = new List<PublicComplaint>();
            Map<String,String> boardNameToQueueIdMap = new Map<String,String>();

             
            LPI_Wrapper.ComplaintsWrapper wrapper = (LPI_Wrapper.ComplaintsWrapper) JSON.deserialize(
                jsonData,
                LPI_Wrapper.ComplaintsWrapper.class
            );
            wrapper  = wrapper.processJSONString(jsonData);

            if(wrapper!=null && wrapper.respondentData.isEmpty()) {
                throw new LPI_Exception('Respondents/Subjects cannot be Empty.');
            }
            else if (wrapper.respondentData != null && wrapper.respondentData.size() > 10) {
                 
                throw new LPI_Exception(
                    RESPONDENT_EXCEEDED_ERR_MSG
                );
            }
            system.debug('409@@');
            LPI_Wrapper.ComplaintsWrapper responseWrap = new LPI_Wrapper.ComplaintsWrapper();

            if (!LPI_RegisterController.isRecaptchaDisabled()) {
                responseWrap = validateRecaptcha(responseWrap, wrapper);
            }
            
             if (responseWrap.isCaptchaInvalid != null && responseWrap.isCaptchaInvalid) {
                 return responseWrap;
             } 

            Map<String,Object> uniqueKeyToDraftCompMap = new Map<String,Object>();

            if(String.isNotBlank(wrapper.uniqueKeyToDraftComp)) {
                uniqueKeyToDraftCompMap = (Map<String,Object>) JSON.deserializeUntyped(wrapper.uniqueKeyToDraftComp);
            }

            Set<String> boardNamesSet = new Set<String>();
            Set<String> boardNamesSetToQuery = new Set<String>();
            for(LPI_Wrapper.RespondentWrapperNew respondent : wrapper.respondentData) {
                String selectedBoard = respondent.professionDetails.profession; 
                if(String.isBlank(selectedBoard)) {
                    selectedBoard = 'Unknown';
                }
                boardNamesSet.add(selectedBoard.length() > 40 ? selectedBoard.substring(0,40).trim() : selectedBoard);
                boardNamesSetToQuery.add(selectedBoard);
            }
            Map<String,String> boardNameToboardIdMap = new Map<String,String>();
            
            if(!boardNamesSet.isEmpty()) {
                for(RegulatoryAuthority regAuthRec : new LPI_RegulatoryAuthorityDAO.LPI_RegulatoryAuthorityWithoutSharingDAO()
                                .getRegulatoryAuthorityByDymanicQueryWithoutSharing('Id,Name','Name  IN ' + LPI_ServiceUtility.getStringValuesByStringSet(boardNamesSetToQuery),null,null,null)) {
                        boardNameToboardIdMap.put(regAuthRec.Name,regAuthRec.Id);
                }
            }
            boardNameToQueueIdMap = getQueueIdByBoardNames(boardNamesSet);
            system.debug('445@@');
            Integer respCnt = 1;
            Map<Integer,PublicComplaint> respCounterToPublicComplaintMap = new Map<Integer,PublicComplaint>();
            Map<Integer,LPI_Wrapper.RespondentWrapperNew> respCounterToRespWrapperMap = new Map<Integer,LPI_Wrapper.RespondentWrapperNew>();
            List<Application_Document__c> appDocList = new List<Application_Document__c>();
             
            if(String.isNotBlank(wrapper.draftComplaintId)) {
                    LPI_PublicComplaintDao.LPI_PublicComplaintWithoutSharingDAO pcClass = new LPI_PublicComplaintDao.LPI_PublicComplaintWithoutSharingDAO();
                    String fields = 'ID, Name, Status,(Select Id,Public_Complaint__c from Application_Document__r)';
                    String whereClause = 'ID = \'' + String.escapeSingleQuotes(wrapper.draftComplaintId) + '\' AND Status = \''+DRAFT_STATUS_TEXT+'\' ';
                    if(String.isNotBlank(wrapper.uniqueId)){
                        whereClause += ' AND Request_Id__c = \'' + String.escapeSingleQuotes(wrapper.uniqueId)  + '\' ';
                    }
                    List<PublicComplaint> draftComplaintList = pcClass.getPublicComplaintByDymanicQueryWithoutSecurity(
                        fields,
                        whereClause,
                        null,
                        null,
                        null
                    );
                    if (draftComplaintList.isEmpty()) {
                        throw new LPI_Exception('Invalid Complaint Details');
                    }
                    appDocList.addAll(draftComplaintList[0].Application_Document__r);
            }
            Integer totalRespAdded = wrapper.respondentData.size();
            for(LPI_Wrapper.RespondentWrapperNew respondent : wrapper.respondentData) {
                PublicComplaint pc = new PublicComplaint();
                if(uniqueKeyToDraftCompMap!=null && uniqueKeyToDraftCompMap.containsKey(respondent.sNoDisplayVal)) {
                    pc.Id = (String)uniqueKeyToDraftCompMap.get(respondent.sNoDisplayVal);
                }    
                pc.Complaint_Details__c = wrapper.complaintDesc;
                pc.IncidentDate = Date.today();
                pc.Complaint_Channel__c = ONLINE_PORTAL;
                pc.Status = COMPLAINT_STATUS_SUBMITTED;
                pc.Contacted_Attorney__c = wrapper.contactedAttorney;
                pc.Lawsuit_Filed__c = wrapper.lawSuitFiled;
                if(wrapper.lawSuitFiled!=null && wrapper.lawSuitFiled?.equals('Yes')) {
                    pc.Lawsuit_Case_Number__c = wrapper.lawsuitcasenumber;
                    pc.Lawsuit_Jurisdiction__c = wrapper.lawsuitJury;
                }
                 
                pc.Complaint_Reported_to_Other_Agency__c = wrapper.complaintReported;
                
                pc.Authorization_Expiration_Date__c = wrapper.authExpirationDate;
                pc.Release_Authorization__c = wrapper.hipaaConsent==null?false:wrapper.hipaaConsent;
                pc.Coverage_Start_Date__c = wrapper.coverageStartDate;
                pc.Coverage_End_Date__c = wrapper.coverageEndDate;
                pc.Coverage_Options__c = wrapper.coverageOption;
                    
                 
                pc.Complainant_e_Signature__c = wrapper.complainantSignature;
                
                 
                pc.Contacted_Respondent__c = wrapper.contactedIndividualAboutComplaint;
                pc.Contacted_Date_Details__c = (String.isNotBlank(wrapper.contactedIndividualAboutCompDate) ? wrapper.contactedIndividualAboutCompDate :null);
                pc.Relationship_to_Respondent__c = wrapper.socialOrProfessionalRelation;
                pc.Relationship_Details__c = wrapper.explainSocProfRelation;
                pc.Willing_to_Testify__c =wrapper.testifyHearing;
                pc.Reported_Date__c = wrapper.reportedDate;
                pc.Is_Companion_Complaint__c = (totalRespAdded > 1);
                 System.debug('506@@');
                LPI_Wrapper.ProfessionDetailsWrapper profDetails = respondent.professionDetails;
                LPI_Wrapper.LicenseDetailsWrapper licenseDetails = respondent.licenseDetails;

                pc.License_Name__c = String.isNotBlank(profDetails.licenseTypeSelected) ? profDetails.licenseTypeSelected : licenseDetails.profession;
                pc.Is_Unknown_Profession__c = profDetails.knowsRespondentProfession!=null && profDetails.knowsRespondentProfession.equals('No') ;
                pc.License_Number__c = (licenseDetails!=null ? licenseDetails.licenseNumberText : null );
                pc.Other_License_State__c = (licenseDetails!=null ? licenseDetails.otherLicenseState : null );
                if(licenseDetails!=null){
                    if(String.isNotBlank(licenseDetails.licenseNum)){
                        pc.License_Number__c = licenseDetails.licenseNum;
                    }
                    else{
                        pc.License_Number__c = licenseDetails.licenseNumberText;
                    }
                }
                if(String.isNotBlank(profDetails.profession)) {
                                  
                    String selectedBoardSubStr = profDetails.profession.length() > 40 ? profDetails.profession.substring(0,40).trim() : profDetails.profession;
                    if(boardNameToQueueIdMap.containsKey(selectedBoardSubStr)) {
                        pc.Board_Name__c = ( boardNameToboardIdMap.containsKey(profDetails.profession)?boardNameToboardIdMap.get(profDetails.profession) : null );
                        pc.Board_Names_List__c = profDetails.profession;
                    }
                    pc.OwnerId = boardNameToQueueIdMap.containsKey(selectedBoardSubStr) ? boardNameToQueueIdMap.get(selectedBoardSubStr) : boardNameToQueueIdMap.get(INTERNAL_STAFF_MEMBERS);
                    populateBoardSpecificQuestions(pc,wrapper.boardSpecficQues,profDetails.profession);
                } else if(pc.Is_Unknown_Profession__c) {
                    pc.OwnerId = boardNameToQueueIdMap.get(GENERIC_QUEUE);
                } else {
                    pc.OwnerId = boardNameToQueueIdMap.get(INTERNAL_STAFF_MEMBERS);
                }
                respCounterToPublicComplaintMap.put(respCnt,pc);
                respCounterToRespWrapperMap.put(respCnt,respondent);
                respCnt++;
            }
            system.debug('respCnt++'+respCnt);
            if(!respCounterToPublicComplaintMap.isEmpty()) {
                LPI_WithoutSharingUtility.upsertSObjectList(respCounterToPublicComplaintMap.values());
                
                LPI_ComplaintParticipantController obj = new LPI_ComplaintParticipantController(respCounterToPublicComplaintMap.get(1).Id);
                
                obj.createCPNew(respCounterToPublicComplaintMap,respCounterToRespWrapperMap);

                if(!appDocList.isEmpty()) {
                        copyDocumentsFromDraftComplaint(respCounterToPublicComplaintMap,appDocList);
                }

                  System.debug('>>>>>>>>>>>551');
                obj.createComplaintParticipant(wrapper); 
                  System.debug('>>>>>>>>>>>554');
                cloneComplaintParticipantForRestComplaints(respCounterToPublicComplaintMap);
                creatingCompanionJunctionRecords(respCounterToPublicComplaintMap);
                fetchComplaintDetails(respCounterToPublicComplaintMap.values(),responseWrap);
             return responseWrap;
            }else{
                throw new LPI_Exception('Please try again ,not able to create a complaint record.');
            }
          
            
        }
        catch(Exception ex) {
            LPI_ExceptionManager.logException('LPI_ComplaintsController', 'createComplaintPerRespondent', ex);
            throw new LPI_Exception(ex.getMessage());
        }
    }   
    /**  
    * @author                      : MTX Group Product Team
    * @since                       : 24 Oct 2023
    * @description                 : This Method is Used to Create Companion Junction Object Records.
    * @return                      : `void`
    * @last modified by            : MTX Group Product Team
    * @last modified date          : 24 May 2023
    * @modified details            : Code Review Fixes
    */
    private static void creatingCompanionJunctionRecords(Map<Integer,PublicComplaint> respCounterToPublicComplaintMap) {
        try {
            List<Companion_Complaints_Cases__c> compComplaintCasesList = new List<Companion_Complaints_Cases__c>();
            Integer resp = 1;
            Integer n = respCounterToPublicComplaintMap.size();
            for(Integer i = resp; i <= n; i++) { 
                for(Integer j = i + 1; j <= n; j++) { 
                    
                    String publicComplaintId = respCounterToPublicComplaintMap.get(i).Id;
                    String companionComplaintId = respCounterToPublicComplaintMap.get(j).Id;
                    if(String.isNotBlank(publicComplaintId) && String.isNotBlank(companionComplaintId)) {
                        compComplaintCasesList.add(new Companion_Complaints_Cases__c(
                            Public_Complaint__c = publicComplaintId,
                            Companion_Complaint__c = companionComplaintId
                        ));
                    }
                }
            }
             
            if(!compComplaintCasesList.isEmpty()) {
                LPI_WithoutSharingUtility.insertSObjectList(compComplaintCasesList);
            }
        }
        catch(Exception ex) {
            LPI_ExceptionManager.logException('LPI_ComplaintsController', 'creatingCompanionJunctionRecords', ex);
            throw new LPI_Exception(ex.getMessage());
        }
    }
    private static final String ORG_RESP_CP_ROLE = 'Original Submitted Respondent';

    /**  
    * @author                      : MTX Group Product Team
    * @since                       : 24 Oct 2023
    * @description                 : This Method is Used to Clone Complaint Participant and other Related Records onto rest n-1 complaints created.
    * @return                      : `void`
    * @last modified by            : MTX Group Product Team
    * @last modified date          : 24 May 2023
    * @modified details            : Code Review Fixes
    */
    private static void cloneComplaintParticipantForRestComplaints(Map<Integer,PublicComplaint> respCounterToPublicComplaintMap) {
        try {
            PublicComplaint pcWhichHasCPRecords = respCounterToPublicComplaintMap.get(1);
            
             
            String fields = 'Id, Role, PublicComplaintId, ParticipantId, Status';
            String whereClause = ' PublicComplaintId = \'' + pcWhichHasCPRecords.Id + '\' AND Role!=\'' + LPI_LiteralConstant.RESPONDENT_TEXT + '\'';

            List<ComplaintParticipant> cpRecordsToClone = new  LPI_ComplaintParticipantDAO.LPI_ComplaintParticipantWithoutSharingDAO().fetchComplaintParticipantsRecordsWithoutSecurityEnforced(
                                                                fields,
                                                                whereClause,
                                                                null,null,null);

             

            fields = 'Id,Complaint_Number__c,Impact,Subject,Board_Name__c,EndDateTime,Status,Location__c,Priority,Urgency';
            whereClause = ' Complaint_Number__c = \'' + pcWhichHasCPRecords.Id + '\'';

            List<Incident> incidentRecords = new LPI_IncidentDao.LPI_IncidentWithoutSharingDAO().fetchIncidentsWithoutSecurityEnforced(fields,whereClause,null,null,null); 

            Integer respCounter = 2;  
            List<ComplaintParticipant> compParticipantCloned = new List<ComplaintParticipant>();
            List<Incident> incidentCpRecords = new List<Incident>();
            Set<Id> complaintIdSet = new Set<Id>();
            
            complaintIdSet.add(pcWhichHasCPRecords.Id);
            
            while(respCounterToPublicComplaintMap.containsKey(respCounter)) {

                String complaintId = respCounterToPublicComplaintMap.get(respCounter)?.Id;
                

                for(ComplaintParticipant cpRec : cpRecordsToClone) {

                    ComplaintParticipant cpRecClone = cpRec.clone(false,true,false,false);
                    cpRecClone.PublicComplaintId = complaintId;
                    compParticipantCloned.add(cpRecClone);
                }

                for(Incident incidentRec : incidentRecords) {
                    Incident incidentRecClone = incidentRec.clone(false,true,false,false);
                    incidentRecClone.Complaint_Number__c = complaintId;
                    incidentCpRecords.add(incidentRecClone);
                }

                respCounter++;
                complaintIdSet.add(complaintId);
            }

             
            fields = 'Id, Role, PublicComplaintId, ParticipantId, Status';
            whereClause = ' PublicComplaintId IN ' + LPI_ServiceUtility.getStringValuesBySet(complaintIdSet) + ' AND Role = \'' + LPI_LiteralConstant.RESPONDENT_TEXT + '\'';
            for(ComplaintParticipant cpRespondentRec : new  LPI_ComplaintParticipantDAO.LPI_ComplaintParticipantWithoutSharingDAO().fetchComplaintParticipantsRecordsWithoutSecurityEnforced(
                                                                fields,
                                                                whereClause,
                                                                null,null,null)) {
                 
                ComplaintParticipant cp = cpRespondentRec.clone(false,true,false,false);
                cp.Role = ORG_RESP_CP_ROLE;
                compParticipantCloned.add(cp);
            }
            
            if(!compParticipantCloned.isEmpty()) {
                LPI_WithoutSharingUtility.insertSObjectList(compParticipantCloned);
            }
            if(!incidentCpRecords.isEmpty()) {
                LPI_WithoutSharingUtility.insertSObjectList(incidentCpRecords);
            }
        }
        catch(Exception ex) {
            LPI_ExceptionManager.logException('LPI_ComplaintsController', 'cloneComplaintParticipantForRestComplaints', ex);
            throw new LPI_Exception(ex.getMessage());
        }
    }
    /**  
    * @author                      : MTX Group Product Team
    * @since                       : 24 Oct 2023
    * @description                 : This Method is Used to Copy Documents from first complaint to rest complaint.
    * @return                      : `void`
    * @last modified by            : MTX Group Product Team
    * @last modified date          : 24 May 2023
    * @modified details            : Code Review Fixes
    */
    private static void copyDocumentsFromDraftComplaint(Map<Integer,PublicComplaint> respCounterToPublicComplaintMap,List<Application_Document__c> appDocList) {
        try {
            List<Application_Document__c> appDocToCloneList = new List<Application_Document__c>();
             
            Integer cnt = 1;
            for(PublicComplaint pcRec : respCounterToPublicComplaintMap.values()) {
                if(cnt++ == 1) continue;
                for(Application_Document__c appDocRec : appDocList) {
                    Application_Document__c appDocRecCloned = appDocRec.clone(false,true,false,false);
                    appDocRecCloned.Public_Complaint__c = pcRec.Id;
                    appDocToCloneList.add(appDocRecCloned);
                }
            }
            if(!appDocToCloneList.isEmpty()) {
                LPI_WithoutSharingUtility.insertSObjectList(appDocToCloneList);
            }
        }
        catch(Exception ex) {
            LPI_ExceptionManager.logException('LPI_ComplaintsController', 'copyDocumentsFromDraftComplaint', ex);
            throw new LPI_Exception(ex.getMessage());
        }
    }
    /**  
    * @author                      : MTX Group Product Team
    * @since                       : 24 Oct 2023
    * @description                 : This Method is Used to Get Queue Ids from the Set of Board Names.
    * @return                      : `void`
    * @last modified by            : MTX Group Product Team
    * @last modified date          : 24 Oct 2023
    * @modified details            : Code Review Fixes
    */
    public static Map<String,String> getQueueIdByBoardNames(Set<String> boardNames) {
        try {
             
            Map<String,String> boardNameToQueueMap = new Map<String,String>();
             
            Map<String,String> otherQueueToQueueIdMap = new Map<String,String>();

            String groupFields ='Id,Name,Type';
            String groupWhereClause = 'Name IN ' +LPI_ServiceUtility.getStringValuesByStringSet(OTHER_RELATED_QUEUES)+ ' AND Type=\''+QUEUE_TYPE+'\'';
            
            for(Group q : (new LPI_GroupDAO.LPI_GroupWithoutSharingDAO()).getGroupByDymanicQueryWithoutSecurityEnforced(groupFields,groupWhereClause,null,null,null)) {
                otherQueueToQueueIdMap.put(q.Name,q.Id);
            }
            if(!boardNames.isEmpty()) {
                groupFields ='Id,Name,Type';
                groupWhereClause = 'Name IN ' +LPI_ServiceUtility.getStringValuesByStringSet(boardNames)+ ' AND Type=\''+QUEUE_TYPE+'\'';
                for(Group grpRec : (new LPI_GroupDAO.LPI_GroupWithoutSharingDAO()).getGroupByDymanicQueryWithoutSecurityEnforced(
                                                groupFields,groupWhereClause,
                                                null,null,null)) {
                        if(grpRec.Name.equals('Cosmetology & Barber Examiners')) {
                            boardNameToQueueMap.put(grpRec.Name,otherQueueToQueueIdMap.get(COMPLAINTS_QUEUE));
                        } else {
                            boardNameToQueueMap.put(grpRec.Name,grpRec.Id);                    
                        }
                    }
            }
            boardNameToQueueMap.putAll(otherQueueToQueueIdMap);

            return boardNameToQueueMap;
        }
        catch(Exception ex) {
            LPI_ExceptionManager.logException('LPI_ComplaintsController', 'getQueueIdByBoardNames', ex);
            throw new LPI_Exception(ex.getMessage());
        }
    }
    
    /**  
* @author                       : MTX Group Product Team
* @since                       : 26 Aug 2023
* @description                 : Method is Used to Populate Board Specific Questions.
* @param complaintId           : Complaint Record Created.
* @param responseWrap          : ComplaintWrapper.
* @return                      : `LPI_Wrapper.ComplaintsWrapper`
* @last modified by            : MTX Group Product Team
* @last modified date          : 11 May 2023
* @modified details            : Code Review Fixes
*/
    private static void populateBoardSpecificQuestions(PublicComplaint pc,LPI_Wrapper.BoardSpecificQuestions bsqWrapper,String boardName) {
        try {
            if(bsqWrapper == null || String.isBlank(boardName)) {
                return;
            }
        }
        catch(Exception ex) {
            LPI_ExceptionManager.logException('LPI_ComplaintsController', 'populateBoardSpecificQuestions', ex);
            throw new LPI_Exception(ex.getMessage()); 
        }
    }
    
    /**  
* @author                       : MTX Group Product Team
* @since                       : 10 May 2023
* @description                 : Method is Used to Fetch Public COmplaint Related Information.
* @param complaintId           : Complaint Record Created.
* @param responseWrap          : ComplaintWrapper.
* @return                      : `LPI_Wrapper.ComplaintsWrapper`
* @last modified by            : MTX Group Product Team
* @last modified date          : 11 May 2023
* @modified details            : Code Review Fixes
*/
    public static LPI_Wrapper.ComplaintsWrapper  fetchComplaintDetails(List<PublicComplaint> pcList,LPI_Wrapper.ComplaintsWrapper responseWrap) {
        try {
            if(pcList.isEmpty()) {
                return null;
            }
            Set<Id> publicComplaintIds = new Set<Id>();
            for(PublicComplaint pc : pcList) {
                publicComplaintIds.add(pc.Id);
            }
             
            LPI_PublicComplaintDao.LPI_PublicComplaintWithoutSharingDAO pcClass = new LPI_PublicComplaintDao.LPI_PublicComplaintWithoutSharingDAO();
            String fields = 'ID,Original_Submitted_Respondent__c, (SELECT ID,ParticipantId FROM PublicComplaintParticipants WHERE ROLE = \'' + LPI_LiteralConstant.RESPONDENT_TEXT + '\' ), Name, Board_Name__c, Board_Name__r.Name,Is_Unknown_Profession__c,License_Name__c';
            String whereClause = 'ID IN ' + LPI_ServiceUtility.getStringValuesBySet(publicComplaintIds);
            List<PublicComplaint> pcListToDisplay = pcClass.getPublicComplaintByDymanicQueryWithoutSecurity(
                fields,
                whereClause,
                null,
                null,
                null
            );
            if (!pcListToDisplay.isEmpty()) {
                List<LPI_Wrapper.RespondentWrapperNew> respDetails = new List<LPI_Wrapper.RespondentWrapperNew>();
                
                for(PublicComplaint pc : pcListToDisplay) {

                    LPI_Wrapper.RespondentWrapperNew respWrapperNewObj = new LPI_Wrapper.RespondentWrapperNew();
                    respWrapperNewObj.publicComplaintName = pc.Name;

                    LPI_Wrapper.ProfessionDetailsWrapper profWrapperObj = new LPI_Wrapper.ProfessionDetailsWrapper();
                    profWrapperObj.pcId = pc.ID;
                    profWrapperObj.profession = pc.Board_Name__r.Name;
                    profWrapperObj.knowsRespondentProfession = pc.Is_Unknown_Profession__c!=null && pc.Is_Unknown_Profession__c?'No':'Yes';
                    profWrapperObj.licenseTypeSelected = pc.License_Name__c;
                    respWrapperNewObj.professionDetails = profWrapperObj;
                    pc.AccountId = !pc.PublicComplaintParticipants.isEmpty() ?  pc.PublicComplaintParticipants[0].ParticipantId : null;
                    pc.Original_Submitted_Respondent__c = String.isBlank(pc.Original_Submitted_Respondent__c) ? pc.AccountId : null;
                    respDetails.add(respWrapperNewObj);
                }
                responseWrap.respondentData = respDetails;
                LPI_WithoutSharingUtility.upsertSObjectList(pcListToDisplay);
            }
           
            return responseWrap;
        }
        catch(Exception ex) {
            LPI_ExceptionManager.logException('LPI_ComplaintsController', 'fetchComplaintDetails', ex);
            throw new AuraHandledException('Something Went Wrong in Fetch Public Complaint Details ' + ex.getMessage());
        }
    }
    
    /**  
    * @author                      :  
    * @since                       : 20 June 2024
    * @description                 : Method to get the COmplaint Details.
    * @return                      : `Map`
    */
    @AuraEnabled
    public static Map<String,object> fetchOnlyComplaints(String accountId){
        try{
           
            Map<String,object> combinedDataMap = new Map<String,object>();
            Set<String> accountIdSet = new Set<String>();
            Map<Id,ComplaintWrapper> IdtoComplaintWrapper = new  Map<Id,ComplaintWrapper>();
                for(Business_Relationships__c br : LPI_BusinessRelationshipDAO.fetchBusinessRelationshipRecords('Related_From__c','Related_From__c != NULL AND Related_To__c = \''+String.escapeSingleQuotes(accountId )+ '\'',null,null,null)){
                    accountIdSet.add(br.Related_From__c);
                }
              
             
            if(!accountIdSet.IsEmpty()){
                LPI_PublicComplaintDao.LPI_PublicComplaintWithoutSharingDAO pcClass = new LPI_PublicComplaintDao.LPI_PublicComplaintWithoutSharingDAO();
                String fields = 'ID, Name, Board_Name__c, Status,IncidentDate, Board_Name__r.Name';
                String whereClause =' (' + 'AccountId IN  ' + LPI_ServiceUtility.getStringValuesByStringSet(accountIdSet) + ' )';
                List<PublicComplaint> pcList = pcClass.getPublicComplaintByDymanicQueryWithoutSecurity(
                    fields,
                    whereClause,
                    null,
                    null,
                    null
                );
                if(pcList.isEmpty()){
                    return null;
                }
                for(PublicComplaint complaintRec : pcList){
                 ComplaintWrapper ComplaintWrapperRec=new ComplaintWrapper();
                    ComplaintWrapperRec.ComplaintId = complaintRec.Id;
                    ComplaintWrapperRec.ComplaintNumber = complaintRec.Name;
                    ComplaintWrapperRec.SubmittedDate =  complaintRec.IncidentDate?.format();
                    ComplaintWrapperRec.ComplaintStatus = complaintRec.Status;
                    ComplaintWrapperRec.BoardName = complaintRec.Board_Name__r.Name;
                    IdtoComplaintWrapper.put(complaintRec.Id,ComplaintWrapperRec);
                }
                    combinedDataMap.put('ComplaintWrapList', IdtoComplaintWrapper.values());
                    return combinedDataMap;
            }
            return null;
        }
        catch (Exception e) {
            LPI_ExceptionManager.logException(
                'LPI_ComplaintsController',
                'fetchOnlyComplaints',
                e
            );
            throw new LPI_Exception(e.getMessage());
        }

    }

    /**  
    * @author                      : MTX Group Product Team
    * @since                       : 24 Oct 2023
    * @description                 : Overloaded Method to get the COmplaint Details.
    * @return                      : `void`
    * @last modified by            : MTX Group Product Team
    * @last modified date          : 24 Oct 2023
    * @modified details            : Code Review Fixes
    */
    public static LPI_Wrapper.ComplaintsWrapper  fetchComplaintDetails(String complaintId,LPI_Wrapper.ComplaintsWrapper responseWrap) {
        try {
            if(String.isBlank(complaintId)) {
                return null;
            }
            PublicComplaint pc;
             
            LPI_PublicComplaintDao.LPI_PublicComplaintWithoutSharingDAO pcClass = new LPI_PublicComplaintDao.LPI_PublicComplaintWithoutSharingDAO();
            String fields = 'ID, Name, Board_Name__c, Board_Name__r.Name';
            String whereClause = 'ID = \'' + String.escapeSingleQuotes(complaintId) + '\'';
            List<PublicComplaint> pcList = pcClass.getPublicComplaintByDymanicQueryWithoutSecurity(
                fields,
                whereClause,
                null,
                null,
                null
            );
            if (!pcList.isEmpty()) {
                pc = pcList[0];
            }
             
            responseWrap.complaintName = pc.Name;
            if(String.isNotBlank(pc.Board_Name__c)) {
                responseWrap.selectedBoardName = pc.Board_Name__r.Name;
            }
            return responseWrap;
        }
        catch(Exception ex) {
            LPI_ExceptionManager.logException('LPI_ComplaintsController', 'fetchComplaintDetails', ex);
            throw new AuraHandledException('Something Went Wrong in Fetch Public Complaint Details ' + ex.getMessage());
        }
    }

    /**  
* @author                      : MTX Group Product Team
* @since                       : 10 May 2023
* @description                 : Method is Used to Validate ReCaptcha
* @param responseWrap          : Complaint Record Created.
* @param wrapper               : Complaint Record Created.
* @return                      : `LPI_Wrapper.ComplaintsWrapper`
* @last modified by            : MTX Group Product Team
* @last modified date          : 11 May 2023
* @modified details            : Code Review Fixes
*/
    public static LPI_Wrapper.ComplaintsWrapper validateRecaptcha(
        LPI_Wrapper.ComplaintsWrapper responseWrap,
        LPI_Wrapper.ComplaintsWrapper wrapper
    ) {
        try {
            Boolean captchaValid = false;
            LPI_Wrapper.ComplaintsWrapper userDetails = getCurrentUserDetails();
            if (String.isNotBlank(wrapper.recaptchaResponse)) {
                if (wrapper.ctype == 'v3') {
                    LPI_RegisterController.RecaptchaResponseWrapper captchaWrpMap = (LPI_RegisterController.RecaptchaResponseWrapper) JSON.deserialize(
                        wrapper.recaptchaResponse,
                        LPI_RegisterController.RecaptchaResponseWrapper.class
                    );
                    Map<String, Object> txnMap = new Map<String, Object>();
                    txnMap = LPI_VerifyCaptcha.makeRequest(
                        captchaWrpMap.response,
                        captchaWrpMap.action,
                        false
                    );
                    captchaValid = (Boolean) txnMap.get('valid');
                    responseWrap.isV3Failed = !captchaValid;
                }
            }
            if (Test.isRunningTest() || userDetails.isCompliantSectionEditable) {
                captchaValid = true;
            }
            if (!captchaValid) {
                responseWrap.isCaptchaInvalid = true;
                responseWrap.isV3Failed = true;
            }
            return responseWrap;
        }
        catch(Exception ex) {
            LPI_ExceptionManager.logException('LPI_ComplaintsController', 'validateRecaptcha', ex);
            throw new AuraHandledException('Error Validating Captcha ' + ex.getMessage());
        }
    }
    

    public class ComplaintsDraftRecordDetailsWrapper {
        @AuraEnabled 
        public String selectedBoardName;
        @AuraEnabled 
        public String entityName;
        @AuraEnabled 
        public String authType;
        @AuraEnabled 
        public String firstName;
        @AuraEnabled 
        public String middleName;
        @AuraEnabled 
        public String lastName;
        @AuraEnabled 
        public String ssn;
        @AuraEnabled 
        public String suffixName;
        @AuraEnabled 
        public String licenseNum;
        @AuraEnabled 
        public String accountId;
        @AuraEnabled 
        public String licenseTypeName; 
    }

    /**  
    * @author                      : MTX Group Product Team
    * @since                       : 13 June 2023
    * @description                 : Method is Used to Create a Draft Public Complaint for Documents Upload, Which Internally Fetches all the required HEADERS and Metadata records for Onbase Integration.
    * @return                      : `String`
    * @last modified by            : MTX Group Product Team
    * @last modified date          : 13 June 2023
    * @modified details            : Code Review Fixes
    */
    @AuraEnabled
    public static Map<String,Object> createDraftPublicComplaint() {
        try {
            
            Map<String,Object> responseMap = new Map<String,Object>();
            Request reqInfo = Request.getCurrent();
            String currentRequestId = reqInfo.getRequestId();
            PublicComplaint pc = new PublicComplaint(
                Status = DRAFT_STATUS_TEXT,
                IncidentDate = System.today(),
                Complaint_Channel__c = ONLINE_PORTAL,
                Complaint_Details__c = 'THIS IS A DRAFT COMPLAINT',
                Request_Id__c = currentRequestId
            );
            
            String groupFields ='Id,Name,Type';
            String groupWhereClause = ' DeveloperName = \'' +LPI_LiteralConstant.INTERNAL_STAFF_MEMBERS_QUEUE_NAME +'\' AND Type = \'' +LPI_LiteralConstant.QUEUE_SOBJECT_API_NAME +'\'' ;
            List<Group> groupList = (new LPI_GroupDAO.LPI_GroupWithoutSharingDAO()).getGroupByDymanicQueryWithoutSecurityEnforced(groupFields,groupWhereClause,null,null,null);
            if(groupList.isEmpty()) {
                throw new LPI_Exception('Appropriate queue does not exist.');
            }
            pc.OwnerId = groupList[0].Id;
            pc = (PublicComplaint) LPI_WithoutSharingUtility.insertSObject(pc);
            responseMap.put('complaintDetails',pc.Id + '-currentRequestId'+currentRequestId);

            return responseMap;
        } catch (Exception ex) {
            LPI_ExceptionManager.logException('LPI_ComplaintsController', 'createDraftPublicComplaint', ex);
            throw new AuraHandledException(ex.getMessage());
        }
    }

    @AuraEnabled 
    public static void handleFileCancel(String jsonData) {
        try {
           if(String.isBlank(jsonData)){
                throw new LPI_Exception('Error cancelling document');
            }

            LPI_ComplaintsController.ComplaintsOnBaseFileWrapper mainWrapperObj = (LPI_ComplaintsController.ComplaintsOnBaseFileWrapper) JSON.deserializeStrict(
                jsonData, LPI_ComplaintsController.ComplaintsOnBaseFileWrapper.Class);
            
            if(String.isBlank(mainWrapperObj.appDocId) || String.isBlank(mainWrapperObj.requestId)) {
                throw new LPI_Exception('Invalid Details, Please try Again.');
            }
            String fields = 'Id,File_Name__c,Preliminary_Application_Reference__c,Board_Name__c,Document_Name__c,Is_System_Generated__c,Upload_To_Onbase__c,Public_Complaint__r.Request_Id__c,Case__r.Request_Id__c'; 
            String whereClause = 'ID =  \'' + String.escapeSingleQuotes((String)mainWrapperObj.appDocId) + '\'' + 
                                    ' AND ( Public_Complaint__r.Request_Id__c = \'' + String.escapeSingleQuotes((String)mainWrapperObj.requestId) + '\' OR Case__r.Request_Id__c = \'' + String.escapeSingleQuotes((String)mainWrapperObj.requestId) +'\' )';
            List<Application_Document__c> appDocList = new LPI_ApplicationDocumentDAO.LPI_ApplicationDocumentWithoutSharingDAO().getApplicantDocumentByDymanicQueryWithoutSecurityEnforced(fields,whereClause,null,null,null);
            if(appDocList.isEmpty()){
                throw new LPI_Exception('Error occured while canceling document'); 
            }
            LPI_WithoutSharingUtility.deleteSObject(appDocList[0]);
        } 
        catch (Exception e) {
            LPI_ExceptionManager.logException(
                'LPI_PharmacyReportingFormController',
                'handleCancel',
                e
            );
            throw new LPI_Exception(e.getMessage());
        }
    }

    @AuraEnabled 
    public static LPI_OnBaseIntegrationController.ResponseWrapper fileScanResult(String jsonData) {
        Map<String, Object> mainWrapperObj = (Map<String, Object>) JSON.deserializeUntyped(jsonData);
        if(String.isBLank((String)mainWrapperObj.get('appDocumentId')) || String.isBLank((String)mainWrapperObj.get('requestId'))){
            throw new LPI_Exception('Invalid Details'); 
        }
        String fields = 'Id, Public_Complaint__c, Case__c, Case__r.request_Id__c';
        String whereclause =  '(Public_Complaint__r.Request_Id__c = \'' + String.escapeSingleQuotes((String)mainWrapperObj.get('requestId')) +  '\'' + 
        ' OR Case__r.Request_Id__c = \'' + String.escapeSingleQuotes( (String)mainWrapperObj.get('requestId')) + '\'' + ')' +
        ' AND Id = \'' + String.escapeSingleQuotes((String)mainWrapperObj.get('appDocumentId')) + '\'';
        List<Application_Document__c> appDocRec = new LPI_ApplicationDocumentDAO.LPI_ApplicationDocumentWithoutSharingDAO().getApplicantDocumentByDymanicQueryWithoutSecurityEnforced(fields,whereClause,null,null,null);  
        if(!appDocRec.isEmpty()){
            mainWrapperObj.put('appDocumentId', appDocRec[0].Id);
            // Guest uploads do not return documentId and do not auto-create ContentDocumentLink.
            // Resolve the uploaded file and explicitly link it to the App Doc and Public Complaint.
            new GuestFileLinkHelper().linkUploadedFile(
                appDocRec[0],
                (String)mainWrapperObj.get('contentDocumentId'),
                (String)mainWrapperObj.get('contentVersionId')
            );
            return LPI_OnBaseIntegrationController.bypassOnbase(JSON.serialize(mainWrapperObj));
        }
        return null;
    }

    /**
     * @description Without-sharing helper so guest users can resolve ContentVersion and create ContentDocumentLinks.
     */
    private without sharing class GuestFileLinkHelper {
        public void linkUploadedFile(Application_Document__c appDoc, String contentDocumentId, String contentVersionId) {
            try {
                Id resolvedContentDocumentId = resolveContentDocumentId(appDoc.Id, contentDocumentId, contentVersionId);
                if (resolvedContentDocumentId == null) {
                    return;
                }

                Set<Id> linkedEntityIds = new Set<Id>{ appDoc.Id };
                if (appDoc.Public_Complaint__c != null) {
                    linkedEntityIds.add(appDoc.Public_Complaint__c);
                }
                if (appDoc.Case__c != null) {
                    linkedEntityIds.add(appDoc.Case__c);
                }

                Set<Id> alreadyLinkedEntityIds = new Set<Id>();
                for (ContentDocumentLink existingLink : [
                    SELECT LinkedEntityId
                    FROM ContentDocumentLink
                    WHERE ContentDocumentId = :resolvedContentDocumentId
                    AND LinkedEntityId IN :linkedEntityIds
                ]) {
                    alreadyLinkedEntityIds.add(existingLink.LinkedEntityId);
                }

                List<ContentDocumentLink> linksToInsert = new List<ContentDocumentLink>();
                for (Id linkedEntityId : linkedEntityIds) {
                    if (alreadyLinkedEntityIds.contains(linkedEntityId)) {
                        continue;
                    }
                    linksToInsert.add(new ContentDocumentLink(
                        ContentDocumentId = resolvedContentDocumentId,
                        LinkedEntityId = linkedEntityId,
                        ShareType = 'V',
                        Visibility = 'AllUsers'
                    ));
                }
                if (!linksToInsert.isEmpty()) {
                    insert linksToInsert;
                }
            } catch (Exception ex) {
                LPI_ExceptionManager.logException('LPI_ComplaintsController', 'linkUploadedFile', ex);
                throw new LPI_Exception(ex.getMessage());
            }
        }

        private Id resolveContentDocumentId(Id appDocId, String contentDocumentId, String contentVersionId) {
            if (String.isNotBlank(contentDocumentId)) {
                try {
                    return (Id)contentDocumentId;
                } catch (Exception e) {
                    // Fall through to ContentVersion resolution for guest uploads
                }
            }

            List<ContentVersion> contentVersions = new List<ContentVersion>();
            if (String.isNotBlank(contentVersionId)) {
                try {
                    Id cvId = (Id)contentVersionId;
                    contentVersions = [
                        SELECT ContentDocumentId
                        FROM ContentVersion
                        WHERE Id = :cvId
                        LIMIT 1
                    ];
                } catch (Exception e) {
                    // Invalid Id format; fall through to Guest_Record lookup
                }
            }

            if (contentVersions.isEmpty() && appDocId != null) {
                String appDocIdStr = String.valueOf(appDocId);
                String guestTokenPrefix = appDocIdStr + '-%';
                // Match exact App Doc Id or legacy composite value: appDocId-requestId
                contentVersions = [
                    SELECT ContentDocumentId
                    FROM ContentVersion
                    WHERE IsLatest = true
                    AND (
                        Guest_Record_fileupload__c = :appDocIdStr
                        OR Guest_Record_fileupload__c LIKE :guestTokenPrefix
                    )
                    ORDER BY CreatedDate DESC
                    LIMIT 1
                ];
            }

            return contentVersions.isEmpty() ? null : contentVersions[0].ContentDocumentId;
        }
    }

    /**  
    * @author                      : MTX Group Product Team
    * @since                       : 24 Oct 2023
    * @description                 : This method internaly calls createApplicationDocument to delegate application document creation logic.
    * @return                      : `void`
    * @last modified by            : MTX Group Product Team
    * @last modified date          : 24 Oct 2023
    * @modified details            : Code Review Fixes
    */
     @AuraEnabled 
    public static Map<String,Object> createApplicationDocument(String jsonData,String responseWrapperJsonData) {
        try {  
            
            LPI_OnBaseIntegrationController.OnbaseFileWrapper onbaseFileWrapperObj = (LPI_OnBaseIntegrationController.OnbaseFileWrapper) JSON.deserialize(jsonData, LPI_OnBaseIntegrationController.OnbaseFileWrapper.class);
            if(String.valueOf(((Id)onbaseFileWrapperObj.lookupFieldId).getSObjectType()) == CASE_OBJECT){
                Map<String,Object> responseObj = (Map<String,Object>)JSON.deserializeUntyped(responseWrapperJsonData);
                LPI_OnBaseIntegrationController.ResponseWrapper respObj = new LPI_OnBaseIntegrationController.ResponseWrapper();
                onbaseFileWrapperObj.lookupFieldName = CASE_OBJECT_API_NAME;
                if(responseObj != null && responseObj.get('licenseType') == PHARMACIST_TEXT){
                }
                onbaseFileWrapperObj.onbasePayload = LPI_VisitRegCodeViolationController.populatePayloadGeneric(respObj);
            }else{
                List<PublicComplaint> pcList = new LPI_PublicComplaintDao.LPI_PublicComplaintWithoutSharingDAO().getPublicComplaintByDymanicQueryWithoutSecurity('Id,Name,Board__c,Complaint_Details__c, (SELECT ID,Onbase_Payload__c FROM Application_Document__r LIMIT 1)','ID =\''+ String.escapeSingleQuotes(onbaseFileWrapperObj.lookupFieldId) + '\'',null,null,null);
                if(!pcList.isEmpty() && !pcList[0].Application_Document__r.isEmpty()) {
                    onbaseFileWrapperObj.onbasePayload = pcList[0].Application_Document__r[0].Onbase_Payload__c;
                } else {
                    ComplaintsDraftRecordDetailsWrapper mainWrapperObj = (ComplaintsDraftRecordDetailsWrapper) JSON.deserialize(responseWrapperJsonData, ComplaintsDraftRecordDetailsWrapper.class);
                    LPI_OnBaseIntegrationController.ResponseWrapper respObj = createResponsePayload(mainWrapperObj); 
                    respObj.description = pcList[0].Name;
                    respObj.numberValue = pcList[0].Name.substringAfter('PC-');
                    onbaseFileWrapperObj.onbasePayload = LPI_VisitRegCodeViolationController.populatePayloadGeneric(respObj);
                }
            }
            return LPI_VisitRegCodeViolationController.createApplicationDocument(JSON.serialize(onbaseFileWrapperObj));
        } 
        catch(Exception ex) {
            LPI_ExceptionManager.logException('LPI_ComplaintsController', 'createApplicationDocument', ex);
            throw new AuraHandledException(ex.getMessage());
        }
    }
      /**  
        * @author                      : MTX Group Product Team
        * @since                       : 24 Oct 2023
        * @description                 : This method Maps the Complaint Details we got from UI onto Response Wrapper, for creating payload.
        * @return                      : `void`
        * @last modified by            : MTX Group Product Team
        * @last modified date          : 24 Oct 2023
        * @modified details            : Code Review Fixes
    */
    private static LPI_OnBaseIntegrationController.ResponseWrapper createResponsePayload(ComplaintsDraftRecordDetailsWrapper mainWrapperObj) {
        try { 
            if(mainWrapperObj == null) {
                throw new LPI_Exception('Missing Complaint Information Details for Payload');
            }

            String selectedBoardName = String.isBlank(mainWrapperObj.selectedBoardName) ? 'Accountancy' : mainWrapperObj.selectedBoardName;
            
            LPI_OnBaseIntegrationController.ResponseWrapper wrapper = new LPI_OnBaseIntegrationController.ResponseWrapper();
            wrapper.boardName = selectedBoardName;
            wrapper.flowName = COMPLAINT_FLOW_NAME; 

            if(mainWrapperObj.authType == 'Individual') {
                wrapper.firstName = mainWrapperObj.firstName!=null && mainWrapperObj.firstName.length() > 40 ?  mainWrapperObj.firstName.substring(40) : mainWrapperObj.firstName == null ?'' : mainWrapperObj.firstName;
                wrapper.middleName = mainWrapperObj.middleName!=null && mainWrapperObj.middleName.length() > 20 ? mainWrapperObj.middleName.substring(20) : mainWrapperObj.middleName==null?'' : mainWrapperObj.middleName;
                wrapper.lastName = mainWrapperObj.lastName!=null && mainWrapperObj.lastName.length() > 40 ? mainWrapperObj.lastName.substring(20) : mainWrapperObj.lastName==null?'' : mainWrapperObj.lastName;
                wrapper.suffixName = mainWrapperObj.suffixName!=null && mainWrapperObj.suffixName.length() > 10 ? mainWrapperObj.suffixName.substring(20) : mainWrapperObj.suffixName==null?'' : mainWrapperObj.suffixName;
            } else {
                wrapper.entityName = mainWrapperObj.entityName!=null && mainWrapperObj.entityName.length() >70 ?  mainWrapperObj.entityName.substring(70) :  mainWrapperObj.entityName == null ? '' :mainWrapperObj.entityName;
            }
            if(String.isNotBlank(mainWrapperObj.licenseNum)) {
                wrapper.licenseNumber = mainWrapperObj.licenseNum.length() > 12 ? mainWrapperObj.licenseNum.substring(12) : mainWrapperObj.licenseNum; 
                List<BusinessLicense> blList =  new LPI_BusinessLicenseDAO.LPI_BusinessLicenseWithoutSharingDAO().getBusinessLicenseByDymanicQueryWithoutSecurity('id,Pre_Licensure_Number__c', 'Name = \''+String.escapeSingleQuotes(mainWrapperObj.licenseNum) + '\'',null,null,null);
                wrapper.preLicensureNumber = (!blList.isEmpty() ? blList[0].Pre_Licensure_Number__c?.abbreviate(10):'');
                wrapper.preLicenseNumber = wrapper.preLicensureNumber;
            }
            if(String.isNotBlank(mainWrapperObj.licenseTypeName)) {
                for(RegulatoryAuthorizationType rat : new LPI_RegulatoryAuthorizationTypeDAO.LPI_RegulatoryAuthorizationTypeWithoutSharingDAO().getRegAuthTypeWithoutSecurity('Profession_Code__c', 'Name = \'' + String.escapeSingleQuotes(mainWrapperObj.licenseTypeName) +'\'', null, null, null)) {
                    wrapper.profCode =rat.Profession_Code__c;
                }
            }

            
            if(String.isNotBlank(mainWrapperObj.accountId)) {
                List<Account> selectedAccDetailList = new LPI_AccountDAO.LPI_AccountWithoutSharingDAO().getAccountByDymanicQuery('Id,Social_Security_Number__c', 'Id = \'' + String.escapeSingleQuotes(mainWrapperObj.accountId) + '\'' , null, null, null);
                if(!selectedAccDetailList.isEmpty() && String.isNotBlank(selectedAccDetailList[0].Social_Security_Number__c)) {
                    wrapper.ssn = selectedAccDetailList[0].Social_Security_Number__c;
                }
            }

            wrapper.dateValue =   String.valueOf(Date.today().year() + '-'+String.valueOf(Date.today().month()).leftPad(2,'0')+'-'+String.valueOf(Date.today().day()).leftPad(2,'0'));
            wrapper.scanDate =  String.valueOf(Date.today().year() + '-'+String.valueOf(Date.today().month()).leftPad(2,'0')+'-'+String.valueOf(Date.today().day()).leftPad(2,'0'));
            Date todayDate = Date.today();
            wrapper.documentDate = String.format('{0}-{1}-{2}', new List<String>{
                todayDate.month() < 10 ? '0' + String.valueOf(todayDate.month()) : String.valueOf(todayDate.month()),
                todayDate.day() < 10 ? '0' + String.valueOf(todayDate.day()) : String.valueOf(todayDate.day()),
                String.valueOf(todayDate.year())
            });
            wrapper.twoByTwoPhotoRecommendation = System.Label.TwoByTwoPhotoRecommendations;


            return wrapper;
        } 
        catch(Exception ex) {
            LPI_ExceptionManager.logException('LPI_ComplaintsController', 'createResponsePayload', ex);
            throw new AuraHandledException(ex.getMessage());
        }
    }


    public class ComplaintsOnBaseFileWrapper {
        @AuraEnabled public String draftComplaintId; 
        @AuraEnabled public String requestId;
        @AuraEnabled public String appDocId;
    }
      /**  
    * @author                      : MTX Group Product Team
    * @since                       : 24 Oct 2023
    * @description                 : This Method is Used to Delete the Application Document Record uploaded by user.
    * @return                      : `void`
    * @last modified by            : MTX Group Product Team
    * @last modified date          : 24 May 2023
    * @modified details            : Code Review Fixes
    */
    @AuraEnabled
    public static void handleDeleteFile(String jsonData) {
        try {
            if(String.isBlank(jsonData)){
                throw new LPI_Exception('Invalid Details');
            }
            List<Application_Document__c> applicationDocList = new List<Application_Document__c>();
            List<String> documentIdList = new List<String>();
            ComplaintsOnBaseFileWrapper wrapper = (ComplaintsOnBaseFileWrapper)JSON.deserialize(jsonData,ComplaintsOnBaseFileWrapper.class);
            Map<String,Object> onbaseDocConfig = (Map<String,Object>) JSON.deserializeUntyped(System.Label.ComplaintDocumentName);
            String fields='Id,Document_Name__c,Public_Complaint__c,Public_Complaint__r.Request_Id__c,Onbase_Document_Id__c,(SELECT ID,ContentDocumentId FROM ContentDocumentLinks)';
            String whereClause = 
                    '(Public_Complaint__r.Request_Id__c = \'' + String.escapeSingleQuotes(wrapper.requestId) +  '\'' + 
                    ' OR Case__r.Request_Id__c = \'' + String.escapeSingleQuotes(wrapper.requestId) + '\'' + ')' +
                    ' AND Id = \'' + String.escapeSingleQuotes(wrapper.appDocId) + '\'';
            List<Application_Document__c> appDocRec = new LPI_ApplicationDocumentDAO.LPI_ApplicationDocumentWithoutSharingDAO().getApplicantDocumentByDymanicQueryWithoutSecurityEnforced(fields,whereClause,null,null,null);

            if(appDocRec.isEmpty()) {
                throw new LPI_Exception('No Document to Delete');
            }
            else if(String.isNotBlank(appDocRec[0].Onbase_Document_Id__c)) {
                LPI_Integration_Config__mdt onbaseConfig = LPI_Integration_Config__mdt.getInstance('Onbase');
                HttpRequest request = new HttpRequest();
                request.setMethod('DELETE');
                request.setEndpoint(onbaseConfig.Auth_End_Point__c+'/'+appDocRec[0].Onbase_Document_Id__c);
                request.setHeader('client_id', onbaseConfig.Client_Id__c);
                request.setHeader('client_secret', onbaseConfig.Private_Key__c);
                request.setHeader('X-Correlation-Id', onbaseConfig.X_Correlation_Id__c);
                Http httpReq = new Http();
                HTTPResponse response = httpReq.send(request);
            }
            if(!appDocRec[0]?.ContentDocumentLinks.isEmpty()) {
                List<ContentDocument> contentDocIdList = new List<ContentDocument>();
                for(ContentDocumentLink cdl : new LPI_ContentDocumentLinkDAO.LPI_ContentDocumentLinkWithoutSharingDAO().getContentDocumentLinkByDymanicQuery('Id,ContentDocumentId','LinkedEntityId = \''+String.escapeSingleQuotes(appDocRec[0].Id) + '\'',null,null,null)) {
                    contentDocIdList.add(new ContentDocument( Id = cdl.ContentDocumentId));
                } 
                LPI_WithoutSharingUtility.deleteSObjectRecord(contentDocIdList);
            }
           if(appDocRec!=null) {
            
            LPI_WithoutSharingUtility.deleteSObject(appDocRec);
            }

        } catch(Exception ex) {
            LPI_ExceptionManager.logException('LPI_ComplaintsController', 'handleDeleteFile', ex);
            throw new AuraHandledException(ex.getMessage());
        }
    }
    
    public class ComplaintWrapper{
        @AuraEnabled 
        public String ComplaintId;
        @AuraEnabled 
        public String ComplaintNumber;
        @AuraEnabled 
        public String SubmittedDate;
        @AuraEnabled 
        public String ComplaintStatus;
        @AuraEnabled 
        public String BoardName;
    }

}