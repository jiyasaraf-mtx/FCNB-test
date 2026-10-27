/**
* @author      : MTX Group Product Team
* @since       : 11 Nov, 2022
* @description : This Class Contains the Business Logic for Creating Business Account
*/

global with sharing class LPI_CreateBusinessAccount implements Callable {
    static final string LOCATION_TYPE_BUSINESS_ADDRESS = 'Business Address';
    static final string LOCATION_TYPE_MAILING = 'Mailing';
    static final string PAR_TYPE_NEW = 'New';
    static final string PAR_TYPE_CHANGE_OF_OWNERSHIP = 'Change of Ownership';
    static final String OBJECT_ACCOUNT = 'Account';
    final static String CANNOT_ADD_DUPLICATE_ADDRESS = 'Address already exists';
    public final static String SUBTYPE_ADDING_CO_OWNER = 'Adding a Co-Owner';
    public final static String EIN_ZERO_NUM = '000000000';
    static final Set<String> notAllowOwnerShipType = new Set<String>{'Certificate of Authority - Corporation', 'Certificate of Authority - LLC', 'NFP Corporation Permit', 'FQHC Registration'};
        
        private static final Set<String> ASSOCIATE_ROLE_SET = new Set<String>{
            'Temporary Clerk',
                'License Service Provider'
                };
                    static final String ADDRESS_TYPE_WAREHOUSE = 'Warehouse Address';
    static final String ADDRESS_TYPE_SECONDARY = 'Secondary Business Address';
    static final String ADDRESS_TYPE_BRANCH = 'Branch';
    static final String ADDRESS_TYPE_OTHER = 'Other';
    static final Set<String> PCA_ADDRESS_TYPE_SET = new Set<String>{ADDRESS_TYPE_WAREHOUSE,
        ADDRESS_TYPE_SECONDARY, ADDRESS_TYPE_BRANCH,
        ADDRESS_TYPE_OTHER};
            private static final String HOW_ARE_YOU_ASSOCIATED = 'HowAreYouAssociatedToThisEntity';
    private static final String HOW_ARE_YOU_ASSOCIATE_RO = 'HowAreYouAssociatedToThisEntityReadOnly';
    global Object call(String action, Map<String, Object> args) {
        Map<String, Object> input = (Map<String, Object>) args.get('input');
        Map<String, Object> output = (Map<String, Object>) args.get('output');
        Map<String, Object> options = (Map<String, Object>) args.get('options');
        return invokeMethod(action, input, output, options);
    }
    
    /**
* @author           MTX Group Product Team
* @updated           Rachna Jadam
* @description       This method will compare method from Omniscript and execute only that specific method
* @return  `Boolean`
*/
    global Boolean invokeMethod(
        String methodName,
        Map<String, Object> inputMap,
        Map<String, Object> outMap,
        Map<String, Object> options
    ) {
        Boolean result = true;
        try {
            
            switch on methodName {
                when 'createBusinessAccount' {
                    createBusinessAccount(inputMap, outMap, options);
                }
                when 'fetchBusinessInformation' {
                    fetchBusinessInformation(inputMap, outMap);
                }
                when 'businessInfoAddressValidation' {
                    businessInfoAddressValidation(inputMap, outMap);
                }
                when 'validationForAddressTypeField' {
                    validationForAddressTypeField(inputMap,outMap);
                }
                when else {
                    result = false;
                }
            }
        } catch (Exception e) {
            result = false;
        }
        return result;
    }
    /**
* @author          :MTX Group Product Team
* @description 	: This method is Used to Create Business Account
* @param inputMap  : fetching all the input from Omniscript
* @param outMap    : Passing value to Omniscript
* @param options   : Passing Options to Omniscript if needed
*/
    private static void createBusinessAccount(
        Map<String, Object> inputMap,
        Map<String, Object> outMap,
        Map<String, Object> options
    ) {
        try {
            Map<String, object> businessAccountStepInfo = 
                (Map<String, object>) inputMap.get('BusinessAccount');
            Map<String, object> businessAccEditableFieldsBlockInfo = 
                (Map<String, object>) businessAccountStepInfo.get('BusinessAccountEditableFieldsBlock');
            Map<String, object> businessAccMailingAddressBlock = 
                (Map<String, object>) businessAccountStepInfo.get('BusinessAccountMailingAddressEditFieldsBlock');
            Map<String, object> relationshipDataBLK = 
                (Map<String, object>) businessAccountStepInfo.get('RelationshipDataBLK');
            String businlocId = '';
            String mailingLocId = '';
            String addressId = '';
            String mailingAddressId = '';
            String name = (String) businessAccEditableFieldsBlockInfo.get('BusinessName');
            String country = (String) businessAccEditableFieldsBlockInfo.get('BusinessCountryC');
            String howAreYouAssociatedToThisEntity  ='';
            if(relationshipDataBLK != NUll && relationshipDataBLK.containsKey('HowAreYouAssociatedToThisEntity')){
                howAreYouAssociatedToThisEntity = (String) relationshipDataBLK.get(
                    'HowAreYouAssociatedToThisEntity'
                );
            }
            String businessAccId = (String) inputMap.get('businessAccId');
            String businessAccBusinessLocId = (String) inputMap.get('businessAccBusinessLocId');
            String businessAccMailingLocId = (String) inputMap.get('businessAccMailingLocId');
            String aapMailingId = (String) inputMap.get('aapMailingId');
            String aapBusinessId = (String) inputMap.get('aapBusinessId');
            Map<String, object> businessInfoAddressTypePCABlockInfo = 
                (Map<String, object>) businessAccountStepInfo.get('BusinessInfoAddressTypePCABlock');
            String businessInfoAddressTypePCA = '';
            Map<String, object> addressTypePCAElementName = businessInfoAddressTypePCABlockInfo !=null ? (Map<String, object>) businessInfoAddressTypePCABlockInfo.get(
                'AddressTypePCAElementName'
            ) : null;
            if(addressTypePCAElementName != null)
            {
                businessInfoAddressTypePCA = (String) addressTypePCAElementName.get('AddressTypePCA');
            }
            String businessAccPcaLocId = (String) inputMap.get('businessAccPcaLocId');
            String pcaTempAuthId = (String) inputMap.get('pcaTempAuthId');
            String pcaAscLocationId = (String) inputMap.get('pcaAscLocationId');
            String businessAccPcaAddressId = (String) inputMap.get('businessAccPcaAddressId');
            String pcaLocId = '';
            String pcaAddressId = '';
            String businessAccMailingAddressId = (String) inputMap.get('businessAccMailingAddressId');
            String businessAccBusinessLocIdForAscLoc = (String) inputMap.get('businessAccBusinessLocId');
            Map<String, Object> businessAccBusinessAddressSubBlock = businessAccEditableFieldsBlockInfo != null ?
                (Map<String, object>) businessAccEditableFieldsBlockInfo.get('BusinessInfoBusinessAddressSubBlock') : null;
            Map<String, Object> businessAccMailingAddressSubBlock = businessAccMailingAddressBlock != null ?
                (Map<String, object>) businessAccMailingAddressBlock.get('BusinessInfoMailingAddressSubBlock') : null;
            Account businessAccDetails = createBusinessAccountRecord(inputMap);
            outMap.put('isError',false);
            if(businessAccDetails == null){
                outMap.put('isError',true);
            }else{
                Boolean isDuplicateApplication = LPI_ApplicationFlowUtility.checkExistingBusinessApplicationWithAddress(
                    businessAccDetails,(String) inputMap.get('parId'));
                outMap.put('isDuplicate',false);
                if(isDuplicateApplication){
                    outMap.put('isDuplicate',true);
                }else{
                    String businessAccountToCreateId = '';
                    Map<String, String> keyMappingBusinessAddress = new Map<String, String>();
                    keyMappingBusinessAddress.put('BusinessStreetAddress', 'Street');
                    keyMappingBusinessAddress.put('BusinessCity', 'City');
                    keyMappingBusinessAddress.put('BusinessZipcode', 'PostalCode');
                    keyMappingBusinessAddress.put('BusinessCounty', 'County__c');
                    keyMappingBusinessAddress.put('BusinessCountryC', 'CountryCode');
                    keyMappingBusinessAddress.put('BusinessStateIfCountryIsNotUS', 'Business_State__c');
                    keyMappingBusinessAddress.put('BusinessAddState', 'StateCode');
                    businlocId = LPI_AddressUtility.createLocationAndAddress(businessAccDetails.Id, 
                                                                             LOCATION_TYPE_BUSINESS_ADDRESS,
                                                                             name,
                                                                             keyMappingBusinessAddress,
                                                                             businessAccBusinessAddressSubBlock
                                                                            );
                    updateConsentFor(businlocId, businessInfoAddressTypePCA, LOCATION_TYPE_BUSINESS_ADDRESS, LOCATION_TYPE_BUSINESS_ADDRESS);
                    Map<String, String> keyMappingMailingAddress = new Map<String, String>();
                    if ((boolean)businessAccEditableFieldsBlockInfo.get('IsMailingAddressIsSameAsMyCurrentAddress')) {
                        keyMappingMailingAddress = keyMappingBusinessAddress;
                        businessAccMailingAddressSubBlock = businessAccBusinessAddressSubBlock;
                    } else {
                        keyMappingMailingAddress.put('MailingStreetAddress', 'Street');
                        keyMappingMailingAddress.put('MailingCity', 'City');
                        keyMappingMailingAddress.put('MailingZipCode', 'PostalCode');
                        keyMappingMailingAddress.put('MailingCounty', 'County__c');
                        keyMappingMailingAddress.put('MailingStateIfCountryIsNotUS', 'Business_State__c');
                        keyMappingMailingAddress.put('MailingState', 'StateCode');
                        keyMappingMailingAddress.put('MailingCountry', 'CountryCode');
                    }
                    mailingLocId = LPI_WithoutSharingUtility.upsertSObject(LPI_AddressUtility.createLocationRecord(
                        businessAccMailingLocId, name, LOCATION_TYPE_MAILING, null
                    ))?.Id;
                    updateConsentFor(mailingLocId, businessInfoAddressTypePCA, LOCATION_TYPE_BUSINESS_ADDRESS, LOCATION_TYPE_MAILING);
                    Schema.Address malingAddressRec = (Schema.Address)LPI_VlocityUtility.createSObject(businessAccMailingAddressSubBlock, keyMappingMailingAddress, 'Address');
                    businessAccMailingAddressId = createBusinessAccAddress(malingAddressRec, mailingLocId, businessAccMailingAddressId, LOCATION_TYPE_MAILING);
                    
                    if(String.isNotBlank(businessAccDetails.Id)){
                        businessAccBusinessLocIdForAscLoc = businlocId;
                    }
                   
                    businessAccDetails = (Account) LPI_WithoutSharingUtility.upsertSObject(businessAccDetails);
                    businessAccountToCreateId = businessAccDetails.Id;
                    
                    
                    if(businessAccountToCreateId != businessAccId){
                        deletePcaTempAuthAndAscLocation(aapBusinessId, '', outMap, 'aapBusinessId', '');
                        aapBusinessId = NULL;
                    }
                   
                    if(mailingLocId != businessAccMailingLocId){
                        createPcaTempAuth(aapMailingId, mailingLocId, (String) inputMap.get('parId'), outMap, 'aapMailingId');
                    }
                   
                    if(businlocId != businessAccBusinessLocId){
                        createPcaTempAuth(aapBusinessId, businlocId, (String) inputMap.get('parId'), outMap, 'aapBusinessId');
                    }
                    if(businessInfoAddressTypePCA == LOCATION_TYPE_BUSINESS_ADDRESS){
                        deletePcaTempAuthAndAscLocation(pcaTempAuthId,businessAccPcaLocId,outMap, 'pcaTempAuthId', 'pcaAscLocationId');
                    }else if(businessInfoAddressTypePCA == LOCATION_TYPE_MAILING){
                        deletePcaTempAuthAndAscLocation(pcaTempAuthId,businessAccPcaLocId,outMap, 'pcaTempAuthId', 'pcaAscLocationId');
                    } else if(businessInfoAddressTypePCABlockInfo != NULL){
                        Map<String, object> primaryContactAddressBlock =
                            (Map<String, object>) businessInfoAddressTypePCABlockInfo.get('PCAAddressBlock');
                      
                        Map<String, String> keyMappingPrimaryContactAddress = new Map<String, String>();
                        keyMappingPrimaryContactAddress.put('PCAStreetAddress', 'Street');
                        keyMappingPrimaryContactAddress.put('PCACity', 'City');
                        keyMappingPrimaryContactAddress.put('PCAZipCode', 'PostalCode');
                        keyMappingPrimaryContactAddress.put('PCACountry', 'CountryCode');
                        keyMappingPrimaryContactAddress.put('PCAStateText', 'Business_State__c');
                        keyMappingPrimaryContactAddress.put('PCAState', 'StateCode');
                        keyMappingPrimaryContactAddress.put('PCACounty', 'County__c');
                       
                        pcaLocId = LPI_WithoutSharingUtility.upsertSObject(LPI_AddressUtility.createLocationRecord(
                            businessAccPcaLocId, name, businessInfoAddressTypePCA, null
                        ))?.Id;
                        updateConsentFor(pcaLocId, businessInfoAddressTypePCA, LOCATION_TYPE_BUSINESS_ADDRESS, businessInfoAddressTypePCA);
                        Schema.Address pcaAddressRec = (Schema.Address)LPI_VlocityUtility.createSObject(primaryContactAddressBlock, keyMappingPrimaryContactAddress, 'Address');
                        pcaAddressId = createBusinessAccAddress(pcaAddressRec, pcaLocId, businessAccPcaAddressId, businessInfoAddressTypePCA);
                        createPcaTempAuth(pcaTempAuthId, pcaLocId, (String) inputMap.get('parId'), outMap, 'pcaTempAuthId');
                        createPcaAscLocation(pcaAscLocationId, businessAccountToCreateId, businessAccId, pcaLocId, outMap, 'pcaAscLocationId');
                    }
                    
                   
                    LPI_AddressUtility.upsertAssociationLocRecord(businessAccountToCreateId,businessAccBusinessLocIdForAscLoc,businlocId);
                    
                    LPI_AddressUtility.upsertAssociationLocRecord(businessAccountToCreateId,businessAccMailingLocId,mailingLocId);
                    
                    handleHowYouAreAssociatedWithThisEntityQuestion(inputMap, businessAccountToCreateId,false);
                    
                    String fieldsToQueryPARForEmail = 'Id, How_are_you_associated_to_this_entity__c ';
                    String whereClauseQueryPARForEmail =
                        'How_are_you_associated_to_this_entity__c = NULL AND Id = \'' +
                        String.escapeSingleQuotes((String) inputMap.get('parId')) +
                        '\'';
                    List<PreliminaryApplicationRef> parRecordsList = LPI_PreliminaryApplicationRefDAO.getPreliminaryApplicationRefByDymanicQuery(
                        fieldsToQueryPARForEmail,
                        whereClauseQueryPARForEmail,
                        null,
                        null,
                        null
                    );
                    
                    
                    PreliminaryApplicationRef par = new PreliminaryApplicationRef();
                    par.Id = (String) inputMap.get('parId');
                    par.BusinessAccountNameId = businessAccountToCreateId;
                    par.Business_Name__c = name;
                    par.How_are_you_associated_to_this_entity__c = howAreYouAssociatedToThisEntity;
                    par.Doing_Business_As_DBA_or_Trade_Name__c = (String) businessAccEditableFieldsBlockInfo.get('FictitiousName');
                    par.Primary_Contact_Address__c = businessInfoAddressTypePCA;
                    par.License_Address__c = LOCATION_TYPE_BUSINESS_ADDRESS;
                    
                    LPI_WithoutSharingUtility.updateSObject(par);
                    if(!parRecordsList.isEmpty()){
                        if(howAreYouAssociatedToThisEntity == 'License Service Provider'){
                            emailToAuthContact(businessAccDetails);
                        }
                    }
                    
                   
                    outMap.put('businessAccId', businessAccountToCreateId);
                    outMap.put('businessAccBusinessLocId', businlocId);
                    outMap.put('businessAccMailingLocId', mailingLocId);
                    outMap.put('businessAccMailingAddressId', businessAccMailingAddressId);
                    outMap.put('businessAccPcaLocId', pcaLocId);
                    outMap.put('businessAccPcaAddressId', pcaAddressId);
                    outMap.put('businessAccBusinessLocIdForAscLoc', businlocId);
                }
            }
        } catch (Exception exp) {
            LPI_ExceptionManager.logException('LPI_CreateBusinessAccount', 'CreateBusinessAccount', exp);
            outMap.put('isError',true);
        }
    }
    
    /**
* @author            MTX Group Product Team
* @updated           
* @description       This method send email to auth contact if license service provider starts a applications
* @return  `Boolean`
*/
    public static void emailToAuthContact(account businessAccDetails){
        List<Notification_Message__mdt> notificationMessageList = new List<Notification_Message__mdt>();
        Map<String, Notification_Message__mdt> devNameToEmailNotifRecMap = new Map<String, Notification_Message__mdt>();
        LPI_AccountDAO.LPI_AccountWithoutSharingDAO accObj = new LPI_AccountDAO.LPI_AccountWithoutSharingDAO();
        List<Account> accRecord = accObj.getAccountByDymanicQuery(
            'Id, ParentId, Parent.Name' ,
            'Id =\'' + businessAccDetails.Id + '\'',
            null,
            null,
            null
        );
        
        if(!accRecord.isEmpty()){
            String fieldToQuery = 'Id, Roles__c, Related_To__c, Related_To__r.PersonEmail,Related_To__r.Name, Related_From__r.Name';
            String whereClause = '';
            if(accRecord[0].ParentId != NULL){
                whereClause  = ' Related_From__c = \'' + accRecord[0].ParentId + '\'';
            }else{
                whereClause  = ' Related_From__c = \'' + accRecord[0].Id + '\'';
            }
            whereClause = whereClause + ' AND Roles__c = \'' + 'Authorized Contact' + '\'';
            whereClause = whereClause + ' AND IsActive__c = true';
            LPI_BusinessRelationshipDAO.LPI_BusinessRelationshipsWithoutSharingDAO relationDAOWithoutSharing =
                new LPI_BusinessRelationshipDAO.LPI_BusinessRelationshipsWithoutSharingDAO();
            List<Business_Relationships__c> brList = relationDAOWithoutSharing.getBusinessRelationshipsByDymanicQuery(
                fieldToQuery,whereClause,null,null,null
            );
            
            notificationMessageList = LPI_CustomMetadataTypeDAO.getAllNotificationByDeveloperNames(new Set<String>{'NewAppStartNotice'});
            for (Notification_Message__mdt noti : notificationMessageList) {
                devNameToEmailNotifRecMap.put(noti.DeveloperName,noti);
            }
            
            if(!brList.isEmpty()){
                User usrData = LPI_WithoutSharingUtility.getUserRecordDetailWithoutSharing(Userinfo.getUserId());
                Map<String, String> replaceMap = new Map<String, String>();
                replaceMap.put('name', usrData.Name);
                List<LPI_Wrapper.NotificationEmailWrapper> notificationEmailWrapperList = new List<LPI_Wrapper.NotificationEmailWrapper>();
                for(Business_Relationships__c br : brList){
                    LPI_Wrapper.NotificationEmailWrapper notifcationWrapper = new LPI_Wrapper.NotificationEmailWrapper();
                    notifcationWrapper.subject = devNameToEmailNotifRecMap.get('NewAppStartNotice').Title__c;
                    notifcationWrapper.description = devNameToEmailNotifRecMap.get('NewAppStartNotice').Description__c;
                    
                    notifcationWrapper.accountId = br.Related_To__c;
                    notifcationWrapper.recipientEmail = br.Related_To__r.PersonEmail;
                    notifcationWrapper.templateName = 'NewAppStartNotice';
                    notifcationWrapper.replaceTextMap = replaceMap;
                    notificationEmailWrapperList.add(notifcationWrapper);
                }
                if (!notificationEmailWrapperList.isEmpty()) {
                    LPI_ServiceUtility.createNotificationRecords(notificationEmailWrapperList);
                }
            }
        }
    }
    
    /**
* @author               		: MTX Group Product Team
* @description       	 		: This method is used to fetch all the fields of Business Information step
* @param inputMap              : Input data passed from OmniScript
* @param outMap                : Output data passed to OmniScript
* @return                      : `void`
* @last modified by     		: MTX Group Product Team
* @last modified date   		: March 4, 2024
* @modified details     		: Code Beautification for better understanding
*/
    public static void fetchBusinessInformation(Map<String, Object> inputMap, Map<String, Object> outMap) {
        Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get(LPI_LiteralConstant.ACCOUNT_BUSINESS_RECORDTYPE).getRecordTypeId();
        try {
            Id parId = (Id) inputMap.get('parId');
            String calledFrom = (String) inputMap.get('iscallingfromos');
            outMap.put('currentUserIsPortalUser', LPI_WithoutSharingUtility.isPortalUser());
            List<Id> locationIdList = new List<Id>();
            List<PreliminaryApplicationRef> parList = new List<PreliminaryApplicationRef>();
            String addressFields = 'Id, StateCode, Street, ParentId, City, State, PostalCode, Country, CountryCode, '
                + 'Business_State__c, LocationType, County__c, Parent.License_Number__c';
            if (String.isNotBlank(parId)) {
                String whereClause = 'Id = \'' + String.escapeSingleQuotes(parId) + '\'';
                
                parList = new LPI_PreliminaryApplicationRefDAO.LPI_PreliminaryApplicationRefWithoutSharingDAO()
                    .getPreliminaryApplicationRefByDymanicQuery(
                        'Id, Type__c, Amendment_Type__c, BusinessAccountNameId, Business_License__c, How_are_you_associated_to_this_entity__c, ' 
                        + 'Regulatory_Authorization_Type__r.IssuingDepartment.Name, Regulatory_Authorization_Type__r.Name, ' 
                        + 'Contact__r.Account.Person_Account_For_Business__c, Business_License__r.Is_Migrated_Data__c, ' 
                        + 'BusinessAccountName.Id, BusinessAccountName.Name, BusinessAccountName.Other_Entity_Type__c, ' 
                        + 'BusinessAccountName.Entity_type__c, BusinessAccountName.County__c, ' 
                        + 'BusinessAccountName.Doing_Business_As_DBA_or_Trade_Name__c, BusinessAccountName.Buisness_Email__c, ' 
                        + 'BusinessAccountName.Federal_Employer_ID_Number_EIN__c, BusinessAccountName.Phone, BusinessAccountName.Fax, ' 
                        + 'BusinessAccountName.BillingStateCode, BusinessAccountName.BillingStreet, BusinessAccountName.BillingCity, ' 
                        + 'BusinessAccountName.BillingState, BusinessAccountName.IsMailingAddress_same_as_current_Address__c, ' 
                        + 'BusinessAccountName.Other_State__c, BusinessAccountName.Mailing_County__c, ' 
                        + 'BusinessAccountName.State_of_Incorporation__c, BusinessAccountName.How_are_you_associated_to_this_entity__c, ' 
                        + 'BusinessAccountName.MO_State_Tax_ID_Number__c, BusinessAccountName.Website, ' 
                        + 'BusinessAccountName.Date_of_Incorporation__c, BusinessAccountName.BillingPostalCode, ' 
                        + 'BusinessAccountName.BillingCountryCode, BusinessAccountName.BillingCountry, BusinessAccountName.RecordTypeId, ' 
                        + 'BusinessAccountName.MO_State_Registration_Number__c, Primary_Contact_Address__c, ' 
                        + 'Business_License__r.Business_Entity_Name__c', whereClause, null, null, null);
            }
          
            if (!parList.isEmpty()) {
                outMap.put('parId', parList[0].Id);
                outMap.put('type', parList[0].Type__c);
                outMap.put('regAuthTypeName',  parList[0].Regulatory_Authorization_Type__r.Name);
                outMap.put('amendmentType', parList[0].Amendment_Type__c);
                outMap.put('boardName', parList[0].Regulatory_Authorization_Type__r.IssuingDepartment.Name);
                String blId = parList.get(0).Business_License__c;
                outMap.put('IsEditableForMigratedData', parList[0].Business_License__r.Is_Migrated_Data__c);
                Boolean showBusinessNameOnAcc = false;
                if ((parList[0].Type__c == PAR_TYPE_NEW && parList[0].Amendment_Type__c != SUBTYPE_ADDING_CO_OWNER) 
                    || parList[0].Type__c == PAR_TYPE_CHANGE_OF_OWNERSHIP) {
                        showBusinessNameOnAcc = true;
                        for (Temp_AuthApplicationPlace__c tempAuthRec : LPI_TempAuthApplicationPlaceDAO.getTempAuthApplicationPlaceByDymanicQuery(
                            'Id, Location__r.LocationType, Location__r.Id, Location__r.License_Number__c', 
                            'Preliminary_Application_Reference__c = \'' + parList[0].Id + '\'' 
                            + ' AND Location__r.License_Number__c = NULL', null, null, null)) {
                               
                                if (tempAuthRec.Location__r.LocationType == LOCATION_TYPE_MAILING) {
                                    outMap.put('aapMailingId', tempAuthRec.Id);
                                    locationIdList.add(tempAuthRec.Location__r.Id);
                                }
                                
                                else if (tempAuthRec.Location__r.LocationType == LOCATION_TYPE_BUSINESS_ADDRESS) {
                                    outMap.put('aapBusinessId', tempAuthRec.Id);
                                    locationIdList.add(tempAuthRec.Location__r.Id);
                                }
                                else if (PCA_ADDRESS_TYPE_SET.contains(tempAuthRec.Location__r.LocationType)) {
                                    outMap.put('pcaTempAuthId', tempAuthRec.Id);
                                    outMap.put('businessAccPcaLocId', tempAuthRec.Location__r.Id);
                                    locationIdList.add(tempAuthRec.Location__r.Id);
                                } 
                            }
                    } 
                else {
                    
                    LPI_AuthApplicationPlaceDAO.LPI_AuthApplicationPlaceWithoutSharingDAO authAppObj = 
                        new LPI_AuthApplicationPlaceDAO.LPI_AuthApplicationPlaceWithoutSharingDAO();
                    for (AuthApplicationPlace authAppRec : authAppObj.getAuthApplicationPlaceByDymanicQuery(
                        'PlaceId, AuthorizationId', 
                        'AuthorizationId = \'' + String.escapeSingleQuotes(parList[0].Business_License__c) + '\'', 
                        null, null, null)) {
                            locationIdList.add(authAppRec.PlaceId);
                        }
                }
                if (!locationIdList.isEmpty()) {
                    for (Schema.Address addressRec : LPI_AddressDAO.getAddressByDymanicQuery(addressFields, 
                                                                                             'ParentId IN ' + LPI_ServiceUtility.getStringValuesByList(locationIdList), null, null, null)) {
                                                                                                 if (addressRec.LocationType == LOCATION_TYPE_MAILING) {
                                                                                                     outMap.put('MailingStreetAddress', addressRec.Street);
                                                                                                     outMap.put('MailingStreetAddressReadOnly', addressRec.Street);
                                                                                                     outMap.put('MailingCity', addressRec.City);
                                                                                                     outMap.put('MailingCityReadOnly', addressRec.City);
                                                                                                     outMap.put('MailingState', addressRec.StateCode);
                                                                                                     outMap.put('MailingStateReadOnly', addressRec.StateCode);
                                                                                                     outMap.put('MailingStateIfCountryIsNotUS', addressRec.Business_State__c);
                                                                                                     outMap.put('MailingStateIfCountryIsNotUSReadOnly', addressRec.Business_State__c);
                                                                                                     outMap.put('MailingStateName', addressRec.State);
                                                                                                     outMap.put('MailingZipCode', addressRec.PostalCode);
                                                                                                     outMap.put('MailingZipCodeReadOnly', addressRec.PostalCode);
                                                                                                     outMap.put('MailingCountry', addressRec.CountryCode);
                                                                                                     outMap.put('MailingCountryName', addressRec.Country);
                                                                                                     outMap.put('MailingCountryReadOnly', addressRec.CountryCode);
                                                                                                     outMap.put('MailingCounty', addressRec.County__c);
                                                                                                     outMap.put('MailingCountyReadOnly', addressRec.County__c);
                                                                                                     outMap.put('businessAccMailingLocId', addressRec.ParentId);
                                                                                                     outMap.put('businessAccMailingAddressId', addressRec.Id);
                                                                                                     outMap.put('MailingCityIfNotUS', addressRec.City);
                                                                                                     outMap.put('MailingZipCodeIfNotUS', addressRec.PostalCode);
                                                                                                     outMap.put('MailingCountyIfNotUS', addressRec.County__c);
                                                                                                 }
                                                                                                 else if (PCA_ADDRESS_TYPE_SET.contains(addressRec.LocationType) && addressRec.Parent.License_Number__c == null) {
                                                                                                     outMap.put('PCAStreetAddress', addressRec.Street);
                                                                                                     outMap.put('PCACity', addressRec.City);
                                                                                                     outMap.put('PCAZipCode', addressRec.PostalCode);
                                                                                                     outMap.put('PCACountry', addressRec.CountryCode);
                                                                                                     outMap.put('PCACountryName', addressRec.Country);
                                                                                                     outMap.put('PCAStateText', addressRec.Business_State__c);
                                                                                                     outMap.put('PCAState', addressRec.StateCode);
                                                                                                     outMap.put('PCAStateName', addressRec.State);
                                                                                                     outMap.put('PCAStreetAddressReadOnly', addressRec.Street);
                                                                                                     outMap.put('PCACityReadOnly', addressRec.City);
                                                                                                     outMap.put('PCAZipCodeReadOnly', addressRec.PostalCode);
                                                                                                     outMap.put('PCACountryReadOnly', addressRec.CountryCode);
                                                                                                     outMap.put('PCAStateTextReadOnly', addressRec.Business_State__c);
                                                                                                     outMap.put('PCAStateReadOnly', addressRec.StateCode);
                                                                                                     outMap.put('PCACounty', addressRec.County__c);
                                                                                                     outMap.put('PCACountyReadOnly', addressRec.County__c);
                                                                                                     outMap.put('businessAccPcaAddressId', addressRec.Id);
                                                                                                     outMap.put('PCACityIfNotUS', addressRec.City);
                                                                                                     outMap.put('PCAZipCodeIfNotUs', addressRec.PostalCode);
                                                                                                     outMap.put('PCACountyIfNotUS', addressRec.County__c);
                                                                                                 }
                                                                                             }
                }
                if (PCA_ADDRESS_TYPE_SET.contains(parList[0].Primary_Contact_Address__c)) {
                    for (AssociatedLocation ascL : new LPI_AssociatedLocationDAO.LPI_AssociatedLocationWithoutSharingDAO()
                         .getAssociatedLocationByDymanicQuery('Id, Location.LocationType', 
                                                              'ParentRecordId = \'' + parList[0].BusinessAccountNameId + '\'' 
                                                              + ' AND Location.LocationType IN ' + LPI_ServiceUtility.getStringValuesByStringSet(PCA_ADDRESS_TYPE_SET) 
                                                              + ' AND Location.License_Number__c = NULL', '1', null, null)) {
                                                                  outMap.put('pcaAscLocationId', ascL.Id);
                                                              }
                }
                if (parList[0].BusinessAccountName.RecordTypeId == accRecordTypeId) {
                    outMap.put('BusinessName', showBusinessNameOnAcc ? parList[0].BusinessAccountName.Name : 
                               parList[0].Business_License__r.Business_Entity_Name__c);
                    outMap.put('BusinessCounty', parList[0].BusinessAccountName.County__c);
                    outMap.put('FictitiousName', parList[0].BusinessAccountName.Doing_Business_As_DBA_or_Trade_Name__c);
                    outMap.put('BusinessEmail', parList[0].BusinessAccountName.Buisness_Email__c);
                    outMap.put('FEIN', parList[0].BusinessAccountName.Federal_Employer_ID_Number_EIN__c);
                    outMap.put('BusinessFaxNumber', parList[0].BusinessAccountName.Fax);
                    outMap.put('BusinessPhoneNumber', parList[0].BusinessAccountName.Phone);
                    outMap.put('IsMailingAddressIsSameAsMyCurrentAddress', 
                               parList[0].BusinessAccountName.IsMailingAddress_same_as_current_Address__c);
                    outMap.put('IsMailingAddressIsSameAsMyCurrentAddressReadOnly', 
                               parList[0].BusinessAccountName.IsMailingAddress_same_as_current_Address__c);
                    outMap.put('HowAreYouAssociatedToThisEntity', parList[0].How_are_you_associated_to_this_entity__c);
                    outMap.put('HowAreYouAssociatedToThisEntityReadOnly', parList[0].How_are_you_associated_to_this_entity__c);
                    outMap.put('StateofIncorporation', parList[0].BusinessAccountName.State_of_Incorporation__c);
                    outMap.put('MOStateTaxIDNumber', parList[0].BusinessAccountName.MO_State_Tax_ID_Number__c);
                    outMap.put('DateofIncorporation', parList[0].BusinessAccountName.Date_of_Incorporation__c);
                    outMap.put('BusinessWebsite', parList[0].BusinessAccountName.Website);
                    outMap.put('MOStateRegistrationNumber', parList[0].BusinessAccountName.MO_State_Registration_Number__c);
                   
                    outMap.put('BusinessNameReadOnly', parList[0].Business_License__r.Business_Entity_Name__c);
                    outMap.put('BusinessCountyReadOnly', parList[0].BusinessAccountName.County__c);
                    outMap.put('FictitiousNameReadOnly', parList[0].BusinessAccountName.Doing_Business_As_DBA_or_Trade_Name__c);
                    outMap.put('BusinessEmailReadOnly', parList[0].BusinessAccountName.Buisness_Email__c);
                    outMap.put('FEINReadOnly', parList[0].BusinessAccountName.Federal_Employer_ID_Number_EIN__c);
                    outMap.put('BusinessFaxNumberReadOnly', parList[0].BusinessAccountName.Fax);
                    outMap.put('BusinessPhoneNumberReadOnly', parList[0].BusinessAccountName.Phone);
                    outMap.put('StateofIncorporationReadOnly', parList[0].BusinessAccountName.State_of_Incorporation__c);
                    outMap.put('MOStateTaxIDNumberReadOnly', parList[0].BusinessAccountName.MO_State_Tax_ID_Number__c);
                    outMap.put('DateofIncorporationReadOnly', parList[0].BusinessAccountName.Date_of_Incorporation__c);
                    outMap.put('BusinessWebsiteReadOnly', parList[0].BusinessAccountName.Website);
                    outMap.put('BusinessStreetAddressReadOnly', parList[0].BusinessAccountName.BillingStreet);
                    outMap.put('BusinessCityReadOnly', parList[0].BusinessAccountName.BillingCity);
                    outMap.put('BusinessZipcodeReadOnly', parList[0].BusinessAccountName.BillingPostalCode);
                    outMap.put('MOStateRegistrationNumberRO',parList[0].BusinessAccountName.MO_State_Registration_Number__c);
                    
                    outMap.put('BusinessStreetAddress', parList[0].BusinessAccountName.BillingStreet);
                    outMap.put('BusinessCity', parList[0].BusinessAccountName.BillingCity);
                    outMap.put('BusinessAddState', parList[0].BusinessAccountName.BillingStateCode);
                    outMap.put('BusinessAddStateReadOnly', parList[0].BusinessAccountName.BillingStateCode);
                    outMap.put('BusinessStateIfCountryIsNotUS', parList[0].BusinessAccountName.Other_State__c);
                    outMap.put('BusinessStateIfCountryIsNotUSReadOnly', parList[0].BusinessAccountName.Other_State__c);
                    outMap.put('BusinessState', parList[0].BusinessAccountName.BillingState);
                    outMap.put('BusinessZipcode', parList[0].BusinessAccountName.BillingPostalCode);
                    outMap.put('BusinessCountryReadOnly', parList[0].BusinessAccountName.BillingCountryCode);
                    outMap.put('BusinessCountryC', parList[0].BusinessAccountName.BillingCountryCode);
                    outMap.put('BusinessCountry', parList[0].BusinessAccountName.BillingCountry);
                    outMap.put('BusinessInfoAddressTypePCA', parList[0].Primary_Contact_Address__c);
                    outMap.put('BusinessInfoAddressTypeLA', 'Business Address');
                  
                    outMap.put('businessAccId', parList[0].BusinessAccountName.Id);
                    
                    outMap.put('OwnerShipTypeAll', parList[0].BusinessAccountName.Entity_type__c);
                   
                    outMap.put('OwnerShipFormulaCheck', parList[0].BusinessAccountName.Entity_type__c);
                    outMap.put('OwnershipType', parList[0].BusinessAccountName.Entity_type__c);
                    outMap.put('OtherOwnershipType', parList[0].BusinessAccountName.Other_Entity_Type__c);
                    outMap.put('OtherOwnershipTypeRO', parList[0].BusinessAccountName.Other_Entity_Type__c);
                   
                    if (String.isNotBlank(calledFrom)) {
                        LPI_CreateSchoolAccount.updateHowAreYouAssociatedToThisEntity(parList[0], outMap);
                    } 
                    else {
                        String personRole = parList[0].How_are_you_associated_to_this_entity__c;
                        outMap.put(HOW_ARE_YOU_ASSOCIATED, personRole);
                        outMap.put(HOW_ARE_YOU_ASSOCIATE_RO, personRole);	
                    }
                    outMap.put('BusinessZipCodeIfNotUS', parList[0].BusinessAccountName.BillingPostalCode);
                    outMap.put('BusinessCountyIfNotUS', parList[0].BusinessAccountName.County__c);
                    outMap.put('BusinessCityIfNotUS', parList[0].BusinessAccountName.BillingCity);
                }
                outMap.put('OwnerShipTypeBoardName', 'Other');
                outMap.put('hideIdentifyYourRole', false);
                outMap.put('isPersonAccountForBuzz', parList[0].Contact__r.Account.Person_Account_For_Business__c);
                outMap.put('hideOwnerShipType', notAllowOwnerShipType.contains((String) outMap.get('regAuthTypeName')) ? true : false);
                outMap.put('showBusinessNameOnAcc', showBusinessNameOnAcc);
              
            }
        }
        catch (Exception exp) {
            LPI_ExceptionManager.logException('LPI_CreateBusinessAccount', 'fetchBusinessInformation', exp);
            throw new LPI_Exception('Facing Issue in Fetch Business Information', exp);
        }
    }
    
    /**
* @author          : MTX Group Product Team
* @description     : This method is used to Create Business Account Record
* @param inputMap  : fetching all the input from Omniscript
* @param outMap    : Passing value to Omniscript
* @param options   : Passing Options to Omniscript if needed
*/
    private static Account createBusinessAccountRecord(
        Map<String, Object> inputMap
    ) {
        try {
            Map<String, object> businessAccountStepInfo =
                (Map<String, object>) inputMap.get('BusinessAccount');
            Map<String, object> businessAccEditableFieldsBlockInfo = 
                (Map<String, object>) businessAccountStepInfo.get('BusinessAccountEditableFieldsBlock');
            String moStateRegistrationNumber = (String) businessAccEditableFieldsBlockInfo.get('MOStateRegistrationNumber');
            String federalEIN  = (String) businessAccEditableFieldsBlockInfo.get('FEIN');
            Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
                .get(LPI_LiteralConstant.ACCOUNT_BUSINESS_RECORDTYPE)
                .getRecordTypeId();
            Map<String, Object> businessAccBusinessAddressSubBlock = businessAccEditableFieldsBlockInfo != null ?
                (Map<String, object>) businessAccEditableFieldsBlockInfo.get('BusinessInfoBusinessAddressSubBlock') : null;
            String country = businessAccBusinessAddressSubBlock!= null ? (String) businessAccBusinessAddressSubBlock.get('BusinessCountryC') : null;
            Map<String, String> accountKeyMappingMap = new Map<String, String>{
                'BusinessName' => 'Name',
                    'FictitiousName' => 'Doing_Business_As_DBA_or_Trade_Name__c',
                    'DateofIncorporation' => 'Date_of_Incorporation__c',
                    'StateofIncorporation' => 'State_of_Incorporation__c',
                    'MOStateTaxIDNumber' => 'MO_State_Tax_ID_Number__c',
                    'BusinessPhoneNumber' => 'Phone',
                    'BusinessFaxNumber' => 'Fax',
                    'BusinessWebsite' => 'Website',
                    'MailingCounty' => 'Mailing_County__c',
                    'IsMailingAddressIsSameAsMyCurrentAddress' => 'IsMailingAddress_same_as_current_Address__c',
                    'BusinessEmail' => 'Buisness_Email__c'
                    };
                        if(String.isNotBlank(moStateRegistrationNumber)){
                            Integer zeroCount = (moStateRegistrationNumber.split('0', -1).size() - 1);
                            if(moStateRegistrationNumber.length() == zeroCount){
                                businessAccEditableFieldsBlockInfo.put('MOStateZero','');
                                accountKeyMappingMap.put('MOStateZero', 'MO_State_Registration_Number__c');
                            }else{
                                accountKeyMappingMap.put('MOStateRegistrationNumber', 'MO_State_Registration_Number__c');
                            }
                        }
            if(federalEIN == EIN_ZERO_NUM){
                businessAccEditableFieldsBlockInfo.put('FEINZero','');
                accountKeyMappingMap.put('FEINZero', 'Federal_Employer_ID_Number_EIN__c');
            }else{
                accountKeyMappingMap.put('FEIN', 'Federal_Employer_ID_Number_EIN__c');
            }
            Account businessAccDetails = (Account) LPI_VlocityUtility.createSObject(
                businessAccEditableFieldsBlockInfo,
                accountKeyMappingMap,
                OBJECT_ACCOUNT
            );
            businessAccDetails.put('RecordTypeId', accRecordTypeId);
            if(businessAccBusinessAddressSubBlock != null){
                businessAccDetails.put('BillingCity', businessAccBusinessAddressSubBlock.get('BusinessCity'));
                businessAccDetails.put('BillingStreet', businessAccBusinessAddressSubBlock.get('BusinessStreetAddress'));
                businessAccDetails.put('BillingPostalCode', businessAccBusinessAddressSubBlock.get('BusinessZipcode'));
                businessAccDetails.put('BillingCountryCode', businessAccBusinessAddressSubBlock.get('BusinessCountryC'));
                businessAccDetails.put('County__c', businessAccBusinessAddressSubBlock.get('BusinessCounty'));
                if (country != 'US') {
                    businessAccDetails.put('Other_State__c', businessAccBusinessAddressSubBlock.get('BusinessStateIfCountryIsNotUS'));
                }else{
                    businessAccDetails.put('BillingStateCode', businessAccBusinessAddressSubBlock.get('BusinessAddState'));
                }
            }
            Map<String, Object> relationShipBlk = (Map<String, object>) businessAccountStepInfo.get('RelationshipDataBLK');
            if(relationShipBlk != NULL){
                if(relationShipBlk.containsKey('HowAreYouAssociatedToThisEntity')){
                    businessAccDetails.put('How_are_you_associated_to_this_entity__c', (String)relationShipBlk.get('HowAreYouAssociatedToThisEntity'));
                }
                businessAccDetails.put('Entity_type__c', (String)relationShipBlk.get('FRML_OwnershipType'));
                businessAccDetails.put('Ownership_Type_Controller__c', (String)relationShipBlk.get('OwnerShipTypeBoardName'));
                businessAccDetails.put('Other_Entity_Type__c', (String)businessAccDetails.get('Entity_type__c')=='Other'?relationShipBlk.get('OtherOwnershipType'):'');
            }
           
            List<Datacloud.MatchRecord> existingAccountId = new List<Datacloud.MatchRecord>();
            existingAccountId = LPI_WithoutSharingUtility.getDuplicateRecords(new List<Account>{businessAccDetails});
            if (!existingAccountId.isEmpty()) {
                businessAccDetails.Id = existingAccountId[0].getRecord().Id;
            }
            string nameMatch = (LPI_VlocityUtility.updateStringToCamelCase(businessAccDetails.Name)).split(' ')[0] + '%';
            String fieldToQuery = 'Id, Name';
            String whereClause = 'ParentId = NULL'+
                ' AND RecordTypeId = \'' + accRecordTypeId + '\'';
            
            if(businessAccDetails.Id != NULL){
                whereClause += ' AND Id != \'' + businessAccDetails.Id + '\'';
            }
            
            if(String.isNotBlank(businessAccDetails.MO_State_Registration_Number__c) || String.isNotBlank(businessAccDetails.Federal_Employer_ID_Number_EIN__c)){
                whereClause += ' AND (';
                Boolean addOr = false;
                if(String.isNotBlank(businessAccDetails.MO_State_Registration_Number__c)){
                    whereClause += ' MO_State_Registration_Number__c = \'' + businessAccDetails.MO_State_Registration_Number__c + '\'';
                    addOr = true;
                }
                if(String.isNotBlank(businessAccDetails.Federal_Employer_ID_Number_EIN__c)){
                    if(addOr){
                        whereClause += ' OR Federal_Employer_ID_Number_EIN__c = \'' + businessAccDetails.Federal_Employer_ID_Number_EIN__c + '\' ';
                    }else{
                        whereClause += ' Federal_Employer_ID_Number_EIN__c = \'' + businessAccDetails.Federal_Employer_ID_Number_EIN__c + '\' ';
                    }
                }
                whereClause += ' ) ';
            }else{
                whereClause += ' AND ( Name Like \'' + nameMatch + '\''
                    + 'OR ( Name = \'' + businessAccDetails.Name + '\' ) )';
            }
            
            LPI_AccountDAO.LPI_AccountWithoutSharingDAO accDAOWithoutSharing = new LPI_AccountDAO.LPI_AccountWithoutSharingDAO();
            List<Account> parentAccount = accDAOWithoutSharing.getAccountByDymanicQuery(fieldToQuery,whereClause,null,null,null);
           
            if(!parentAccount.isEmpty()){
                businessAccDetails.ParentId = parentAccount[0].Id;
            }
            return businessAccDetails;
        } catch (Exception exp) {
            LPI_ExceptionManager.logException('LPI_CreateBusinessAccount', 'createBusinessAccountRecord', exp);
            return null;
        }
    }
    
    /**
* @author          :MTX Group Product Team
* @since           : 02 Mar 2023
* @description     : This method is used to Relate user with account
based on How You Are Associated With This Entity Question
* @param inputMap  : fetching all the input from Omniscript
* @param createdBusinessAccId  : passing business Acc Id
* @param isAccUpdateReq : Passing boolean value to update acc in the readonly mode
*/
    private static void handleHowYouAreAssociatedWithThisEntityQuestion(Map<String, Object> inputMap, 
                                                                        String createdBusinessAccId,
                                                                        boolean isAccUpdateReq
                                                                       ){
                                                                           Map<String, object> businessAccountStepInfo = 
                                                                               (Map<String, object>) inputMap.get('BusinessAccount');
                                                                           Map<String, Object> relationShipBlk = (Map<String, object>) businessAccountStepInfo.get('RelationshipDataBLK');
                                                                           String howAreYouAssociatedToThisEntity = '';
                                                                           if(relationShipBlk != NULL && relationShipBlk.containsKey('HowAreYouAssociatedToThisEntity')){
                                                                               howAreYouAssociatedToThisEntity = (String) relationShipBlk.get(
                                                                                   'HowAreYouAssociatedToThisEntity'
                                                                               );
                                                                           }
                                                                           String businessAccId = (String) inputMap.get('businessAccId');
                                                                           String businessAccountId ='';
                                                                           
                                                                           String fieldsToQueryPARForACR = 'Id, Contact__r.AccountId, Board_Name__c ';
                                                                           String whereClauseForPARfields =
                                                                               'Id = \'' +
                                                                               String.escapeSingleQuotes((String) inputMap.get('parId')) +
                                                                               '\'';
                                                                           List<PreliminaryApplicationRef> parRecordsList = LPI_PreliminaryApplicationRefDAO.getPreliminaryApplicationRefByDymanicQuery(
                                                                               fieldsToQueryPARForACR,
                                                                               whereClauseForPARfields,
                                                                               null,
                                                                               null,
                                                                               null
                                                                           );
                                                                           if(createdBusinessAccId != null){
                                                                               businessAccountId = createdBusinessAccId;
                                                                           } else if(businessAccId != null){
                                                                               businessAccountId = businessAccId;
                                                                           }
                                                                           if (!parRecordsList.isEmpty() && 
                                                                               String.isNotEmpty(parRecordsList[0].Contact__r.AccountId) &&
                                                                               String.isNotEmpty(howAreYouAssociatedToThisEntity) &&
                                                                               String.isNotEmpty(businessAccountId)) {
                                                                                   LPI_CreateSchoolAccount.upsertACRRecord(parRecordsList[0].Id, businessAccountId, howAreYouAssociatedToThisEntity);
                                                                               }
                                                                          
                                                                           if(isAccUpdateReq && String.isNotEmpty(businessAccountId)){
                                                                               Account businAcc = new Account(Id = businessAccountId, 
                                                                                                              How_are_you_associated_to_this_entity__c =
                                                                                                              howAreYouAssociatedToThisEntity
                                                                                                             );
                                                                               LPI_WithoutSharingUtility.updateSObject(businAcc);
                                                                           }
                                                                       }
    
    /**
* @author          : MTX Group Product Team
* @since           : 12 Jun 2023
* @description     : Method is used to delete temp Auth for Primary Contact Address
* @param tempAuthPcaId : Temp Auth Application Place Id
* @param outMap : Pass values to Omniscript
*/
    public static void deletePcaTempAuthAndAscLocation(String tempAuthPcaId,String pcaAscLocationId,Map<String, Object> outMap, String outMapKey, String ascLocOutMapKey){
        List<SObject> listToDelPcaTempAuthAndAscLocation = new List<SObject>();
       
        if(String.isNotBlank(tempAuthPcaId)){
            listToDelPcaTempAuthAndAscLocation.add(new Temp_AuthApplicationPlace__c(Id = tempAuthPcaId));
            outMap.put(outMapKey, null);
        }
        if(String.isNotBlank(pcaAscLocationId)){
            listToDelPcaTempAuthAndAscLocation.add(new Schema.Location(Id = pcaAscLocationId));
            outMap.put(ascLocOutMapKey,null);
            outMap.put('businessAccPcaLocId', null);
            outMap.put('businessAccPcaAddressId', null);
        }
       
        if(!listToDelPcaTempAuthAndAscLocation.isEmpty()){
            LPI_WithoutSharingUtility.deleteSObject(listToDelPcaTempAuthAndAscLocation);
        }
    }
    /**
* @author          : 
* @since           : 13 Jun 2023
* @description     : Method is used to create Associated Location for Primary Contact Address
* @param pcaAscLocationId :Associated Location Id
* @param accId : Account Id
* @param businessAccIdOs : Account Id from OS
* @param locId : Location Id
* @param outMap : Pass values to Omniscript
*/
    public static void createPcaAscLocation(String pcaAscLocationId,
                                            String accId,String businessAccIdOs,
                                            String locId, Map<String, Object> outMap,
                                            String outMapKey){
                                                AssociatedLocation ascLocationPca = new AssociatedLocation();
                                               
                                                if(
                                                    String.isNotBlank(pcaAscLocationId) &&
                                                    String.isNotBlank(accId) && 
                                                    String.isNotBlank(businessAccIdOs) &&
                                                    String.isNotBlank(locId)&& (businessAccIdOs == accId)){
                                                        
                                                        ascLocationPca.Id = pcaAscLocationId;
                                                        ascLocationPca.LocationId = locId;
                                                        ascLocationPca = (AssociatedLocation)LPI_DML.doUpdate(ascLocationPca);
                                                        outMap.put(outMapKey, ascLocationPca.Id);
                                                    }else if(String.isNotBlank(accId) && String.isNotBlank(locId)){
                                                        ascLocationPca.ParentRecordId = accId;
                                                        ascLocationPca.LocationId = locId;
                                                        ascLocationPca = (AssociatedLocation)LPI_DML.doInsert(ascLocationPca);
                                                        outMap.put(outMapKey, ascLocationPca.Id);
                                                    }
                                            }
    /**
* @author          :MTX Group Product Team
* @since           : 13 Jun 2023
* @description     : Method is used to create temp Auth for Primary Contact Address
* @param tempAuthPcaId : Temp Auth Application Place Id
* @param pacLocationId : Location Id
* @param parId : PAR Id
* @param outMap : Pass values to Omniscript
*/
    public static void createPcaTempAuth(String tempAuthPcaId,
                                         String pacLocationId,
                                         String parId,
                                         Map<String, Object> outMap,
                                         String outMapKey){
                                             Temp_AuthApplicationPlace__c pcaAAP = new Temp_AuthApplicationPlace__c();
                                             if (String.isNotBlank(tempAuthPcaId)) {
                                                 pcaAAP.Id = tempAuthPcaId;
                                             }
                                             pcaAAP.Location__c = pacLocationId;
                                             pcaAAP.Preliminary_Application_Reference__c = parId;
                                             pcaAAP = (Temp_AuthApplicationPlace__c) LPI_DML.doUpsert(pcaAAP);
                                             outMap.put(outMapKey, pcaAAP.id);
                                         }
    
    /**
* @author          : MTX Group Product Team
* @since           : 04 Jul 2023
* @description     : Method is used to insert or update Address
* @param addRec : Address Record
* @param addressLocationId : Location Id
* @param addressId : Address Id
* @param locType : Location Type
*/
    public static String createBusinessAccAddress(Schema.Address addRec,
                                                  String addressLocationId,
                                                  String addressId,
                                                  String locType){
                                                      String addressIdToReturn ='';
                                                      if(String.isNotBlank(addressLocationId) && String.isBlank(addressId)){
                                                          addRec.parentId = addressLocationId;
                                                          addRec.locationType = locType;
                                                          addressIdToReturn = LPI_WithoutSharingUtility.insertSObject(addRec)?.Id;
                                                      }else if(String.isNotBlank(addressId)){
                                                          addRec.Id = addressId;
                                                          addressIdToReturn = LPI_WithoutSharingUtility.updateSObject(addRec)?.Id;
                                                      }
                                                      return addressIdToReturn;
                                                  }
    /**
* @author          : MTX Group Product Team
* @since           : 24 Jul 2023
* @description     : Method is used to update the consent for picklist field in location obj
*/
    public static void updateConsentFor(String locationId, String addressTypePCA, String addressTypeLA, String locationType) 
    {
        if(String.isBlank(locationId)){
            return;
        }
        Schema.Location locToUpdateConsentFor = new Schema.Location(Id = locationId);
        if(addressTypePCA == locationType && addressTypeLA == locationType)
        {
            locToUpdateConsentFor.Consent_For__c = 'Primary Contact Address;License Address';
        }
        else if(addressTypePCA == locationType)
        {
            locToUpdateConsentFor.Consent_For__c = 'Primary Contact Address';
        }
        else if(addressTypeLA == locationType)
        {
            locToUpdateConsentFor.Consent_For__c = 'License Address';
        }
        else{
            locToUpdateConsentFor.Consent_For__c = null;
        }
        LPI_DML.doUpdate(locToUpdateConsentFor);
    }
    /**
* @author          : MTX Group Product Team
* @since           : 12 Sep 2023
* @description     : Method is used for Address Validation in Business Information
*/
    private static void businessInfoAddressValidation(Map<String, Object> inputMap, Map<String, Object> outMap) 
    {
        try{
            Map<String, object> businessAccountStepInfo = 
                (Map<String, object>) inputMap.get('BusinessAccount');
            Map<String, object> businessAccEditableFieldsBlockInfo =  businessAccountStepInfo != null ?
                (Map<String, object>) businessAccountStepInfo.get('BusinessAccountEditableFieldsBlock') : null;
            Map<String, object> businessAccMailingAddressBlock =  businessAccountStepInfo != null ?
                (Map<String, object>) businessAccountStepInfo.get('BusinessAccountMailingAddressEditFieldsBlock') : null;
            Map<String, object> businessInfoAddressTypePCABlockInfo = businessAccountStepInfo != null ?
                (Map<String, object>) businessAccountStepInfo.get('BusinessInfoAddressTypePCABlock') : null;
            Map<String, Object> businessAccBusinessAddressSubBlock = businessAccEditableFieldsBlockInfo != null ?
                (Map<String, object>) businessAccEditableFieldsBlockInfo.get('BusinessInfoBusinessAddressSubBlock') : null;
            Map<String, Object> businessAccMailingAddressSubBlock = businessAccMailingAddressBlock != null ?
                (Map<String, object>) businessAccMailingAddressBlock.get('BusinessInfoMailingAddressSubBlock') : null;
            String businessInfoAddressTypePCA = '';
            Map<String, object> addressTypePCAElementName = businessInfoAddressTypePCABlockInfo != null ? (Map<String, object>) businessInfoAddressTypePCABlockInfo.get(
                'AddressTypePCAElementName'
            ) : null;
            if(addressTypePCAElementName != null)
            {
                businessInfoAddressTypePCA = (String) addressTypePCAElementName.get('AddressTypePCA');
            }
            boolean result = true;
            LPI_GoogleIntegration.AddressValidationResultWrapper resultWrap = new LPI_GoogleIntegration.AddressValidationResultWrapper();
            outMap.put('errorInAddress',false);
            outMap.put('addressErrorMessage','');
            outMap.put('addressErrorMessageForPIPFI','');
            if(businessAccBusinessAddressSubBlock != NULL){
                resultWrap = LPI_GoogleIntegration.checkAddressValidation(
                    (String) businessAccBusinessAddressSubBlock.get('BusinessCountryC'),
                    (String) businessAccBusinessAddressSubBlock.get('BusinessCity'),
                    new List<String>{
                        (String) businessAccBusinessAddressSubBlock.get('BusinessStreetAddress') + ',' +
                            (String) businessAccBusinessAddressSubBlock.get('BusinessCity') + ',' +
                            (String) businessAccBusinessAddressSubBlock.get('BusinessCountryC') + ',' +
                            (String) businessAccBusinessAddressSubBlock.get('BusinessZipcode'),
                            (String) businessAccBusinessAddressSubBlock.get('BusinessZipcode')
                            }
                );
                
                if(resultWrap.addressValid || resultWrap.skipValidation){
                    outMap.put('BusinessAddressLong', resultWrap.longitude);
                    outMap.put('BusinessAddressLat',resultWrap.latitude);
                }else{
                    result = false;
                    outMap.put('errorInAddress',true);
                    outMap.put('addressErrorMessage','Business Address Validation Failed. Please Provide a Correct Address.');
                    outMap.put('addressErrorMessageForPIPFI','Business Physical Office Address Validation Failed. Please Provide a Correct Address.');
                    outMap.put('isBusinessAddressInvalid',true);
                    outMap.put('ErrType','BusinessAddressError');
                }
            }
            if(result && businessAccMailingAddressSubBlock != NULL && 
               !(boolean)businessAccEditableFieldsBlockInfo.get('IsMailingAddressIsSameAsMyCurrentAddress')){
                   resultWrap = LPI_GoogleIntegration.checkAddressValidation(
                       (String) businessAccMailingAddressSubBlock.get('MailingCountry'),
                       (String) businessAccMailingAddressSubBlock.get('MailingCity'),
                       new List<String>{(String) businessAccMailingAddressSubBlock.get('MailingStreetAddress')+ ',' +
                           (String) businessAccMailingAddressSubBlock.get('MailingCity') + ',' +
                           (String) businessAccMailingAddressSubBlock.get('MailingCountry') + ',' +
                           (String) businessAccMailingAddressSubBlock.get('MailingZipCode'),
                           (String) businessAccMailingAddressSubBlock.get('MailingZipCode')
                           }
                   );
                  
                   if(resultWrap.addressValid || resultWrap.skipValidation){
                       outMap.put('BusinessInfoMailingAddressLong', resultWrap.longitude);
                       outMap.put('BusinessInfoMailingAddressLat',resultWrap.latitude);
                   }else{
                       result = false;
                       outMap.put('errorInAddress',true);
                       outMap.put('addressErrorMessage','Mailing Address Validation Failed. Please Provide a Correct Address.');
                       outMap.put('isMailingAddressInvalid',true);
                       outMap.put('ErrType','MailingAddressError');
                   }
               }
            if(result && businessInfoAddressTypePCABlockInfo != NULL
               && businessInfoAddressTypePCA != LOCATION_TYPE_BUSINESS_ADDRESS 
               && businessInfoAddressTypePCA != LOCATION_TYPE_MAILING){
                   Map<String, object> primaryContactAddressBlock =
                       (Map<String, object>) businessInfoAddressTypePCABlockInfo.get('PCAAddressBlock');
                   resultWrap = LPI_GoogleIntegration.checkAddressValidation(
                       (String) primaryContactAddressBlock.get('PCACountry'),
                       (String) primaryContactAddressBlock.get('PCACity'),
                       new List<String>{(String) primaryContactAddressBlock.get('PCAStreetAddress')+ ',' +
                           (String) primaryContactAddressBlock.get('PCACity') + ',' +
                           (String) primaryContactAddressBlock.get('PCACountry') + ',' +
                           (String) primaryContactAddressBlock.get('PCAZipCode'),
                           (String) primaryContactAddressBlock.get('PCAZipCode')
                           }
                   );
                   
                   if(resultWrap.addressValid || resultWrap.skipValidation){
                       outMap.put('BusinessInfoPCAAddressLong', resultWrap.longitude);
                       outMap.put('BusinessInfoPCAAddressLat',resultWrap.latitude);
                   }else{
                       result = false;
                       outMap.put('errorInAddress',true);
                       outMap.put('addressErrorMessage','Primary Contact Address Validation Failed. Please Provide a Correct Address.');
                       outMap.put('isBusinessInfoPCAAddressInvalid',true);
                       outMap.put('ErrType','PrimaryContactAddressError');
                   }
               }
        }catch(Exception exp){
            LPI_ExceptionManager.logException('LPI_CreateBusinessAccount', 'businessInfoAddressValidation', exp);
        }
    }
    /**
* @author          					: MTX Group Product Team
* @since 								: 21 Dec 2023
* @description     					: This method is used to check whether user enteres value in Address Type field or not
* @param inputMap						: Map<String, Object>
* @param outMap					    : Map<String, Object>
* @last modified by					: MTX Group Product Team
* @last modified date					: (Add if modified by you)
* @last modified details				: (Add if modified by you)
*/
    private static void validationForAddressTypeField(Map<String,Object> inputMap, Map<String,Object> outMap) {
        try {
            Map<String, object> businessInformation;
            String addressTypePCAElementNameLWC;
            if(inputMap.containsKey('NewLocationInformation'))
            {
                businessInformation = (Map<String, object>) inputMap.get('NewLocationInformation');
                addressTypePCAElementNameLWC = 'AddressTypePCAElementNameCOL';
            }
            else
            {
                businessInformation = (Map<String, object>) inputMap.get('BusinessAccount');
                addressTypePCAElementNameLWC = 'AddressTypePCAElementName';
            }
            Map<String, object> primaryContactAddressBlock = businessInformation != null ? (Map<String, object>) businessInformation.get('BusinessInfoAddressTypePCABlock') : null;
            string addressTypePCA;
            Map<String, object> addressTypePCAElementName;
            if(primaryContactAddressBlock != null && primaryContactAddressBlock.containsKey(addressTypePCAElementNameLWC)){
                addressTypePCAElementName = (Map<String, object>) primaryContactAddressBlock.get(addressTypePCAElementNameLWC);
                addressTypePCA = addressTypePCAElementName != null ? (String) addressTypePCAElementName.get('AddressTypePCA') : null;
                if(addressTypePCA != null){
                    outMap.put('ErrorInPCAField', false);
                }
            }else{
                outMap.put('ErrorInPCAField', true);
            }
        } catch (Exception e) {
            LPI_ExceptionManager.logException('LPI_CreateBusinessAccount', 'validatioForAddressTypeField', e);
        }
    }
}