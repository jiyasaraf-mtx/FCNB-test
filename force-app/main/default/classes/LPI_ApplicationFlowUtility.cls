/**
 * @description       : Utility Class for Application Flows
 * @author            : MTX Group Product Team
 * @group             :
 * @last modified on  : 07-24-2024
 * @last modified by  : MTX Group Product Team
 **/
public with sharing class LPI_ApplicationFlowUtility {
    private static final String PAR_ID = 'parid';
    private static final String REG_AUTH_ID = 'regAuthId';
    private static final String TYPE_STR = 'type';
    private static final String AMENDMENT_TYPE = 'amendmentType';
    private static final String BL_ID = 'blId';
    private static final String CHANGE_STATUE_AMENDMENT_SUB_TYPE = 'changeStatusAmendmentSubType';
    private static final String ADDITIONAL_LICENSE_TYPE = 'additionalLicenseType';
    private static final String COURSE_ID = 'courseId';
    private static final String IDENTIFICATION_ID = 'identificationId';
    private static final String CLASS_NAME = 'LPI_ApplicationFlowUtility';
    private static final String METHOD_CREATE_PAR_RECORD = 'createPARRecord';
    private static final String BLA_ERROR = 'blaError';
    private static final String ACTIVE_STATUS = 'Active';
    private static final String STATUS_EXPIRED = 'Expired';
    private static final String TYPE_NEW = 'New';
    private static final String TYPE_AMENDMENT = 'Amendment';
    private static final String APEP_BOARD_BUSINESS_REINSTATEMENT = 'Re-authorization';
    private static final String APEP_BOARD_INDIVIDUAL_REINSTATEMENT = 'Re-licensure';
    private static final String REINSTATEMENT_TYPE = 'Reinstatement';
    private static final List<String> LIST_OF_APP_FLOW_CONFIG_FIELDS = new List<String>{
        'Id',
        'Name',
        'Application_URL__c',
        'Application_Subtype__c',
        'Application_Type__c',
        'Action_Name__c'
    };
    private static final String FLOW_NOT_CONFIGURED = 'Flow not configured';
    private static final String FLOW_NOT_CONFIGURED_MESSAGE = 'Application flow is not configured for the given conditions: ';
    private static final List<String> LIST_OF_BL_FIELDS = new List<String>{
        'Id',
        'First_Name__c',
        'Last_Name__c',
        'Middle_Name__c',
        'Maiden_Name__c',
        'AccountId',
        'Contact.AccountId',
        'ContactId',
        'Consent_for_Primary_Contact_Address__c',
        'PeriodEnd',
        'Primary_Contact_Address__c',
        'License_Address__c',
        'Publicly_Displayed_Address__c',
        'Pre_Licensure_Number__c',
        'Regulatory_Authorization_Type_Name__c',
        'Status',
        'Business_Name__c',
        'Is_Migrated_Data__c'
    };
    private static final List<String> LIST_OF_ADDRESS_FIELDS = new List<String>{ 'Id', 'parentId' };
    private static final String INTAKE_LINK = 'intakeLink';
    private static final String PAR_TRIGGER_HANDLER = 'PreliminaryApplicationTriggerHandler';
    private static final String DRAFT = 'Draft';
    private static final String REJECTED = 'Rejected';
    private static final String SUBMITTED = 'Submitted';
    private static final List<String> LIST_OF_PAR_STATUS = new List<String>{ 'Converted', 'Draft' };
    private static final List<String> LIST_OF_BLA_STATUS = new List<String>{ 'License Issued', 'Rejected' };
    private static final String CHANNEL_ONLINE = 'Online';
    private static final String CHANNEL_OFFLINE = 'Offline';
    public final static String PERSON_ADDITIONAL_INFO = 'Person Additional Information';
    public final static String AMENDMENT = 'Amendment';
    private final static Set<String> RAT_EXCEPTIONS = new Set<String>{
        'Embalmer',
        'Funeral Director'
    };
    private final static String REVOKED_STATUS = 'Revoked';
    private final static String EXAMINATION_AMENDMENT_TYPE = 'Examination';
    private final static Set<String> SET_ACTION_VALIDATION_BYPASS_APPLICATION_TYPE_SET = new Set<String>{
        'Change of Ownership',
        'Request for certification of licensure',
        'Request for certification and/or verification of licensure',
        'Apply for Approval of CE Program',
        'Online Notification of Intent to Administer/Immunize'
    };
    /**
     * @author                         :
     * @since                          :
     * @description                    : This method is used for creating PAR record onclick Apply Online on portal
     * @last modified by               : MTX Group Product Team
     * @last modified date             : 21 March, 2023
     * @last modified details          : Added Logic to Maintain Relationship between PAR and IA/BLA
     *                                   for Ancillary Applications through Application Actions
     */
    public static Map<String, Object> createPARRecord(Map<String, Object> inputMap, Map<String, Object> outMap) {
        System.debug('=== [createPARRecord] STARTED ===');
        String regAuthId = (String) inputMap.get(REG_AUTH_ID);
        String applicationType = (String) inputMap.get(TYPE_STR);
        String amendmentType = ((String) inputMap.get(AMENDMENT_TYPE) != null
            ? (String) inputMap.get(AMENDMENT_TYPE)
            : null);
        String oldBlId = ((String) inputMap.get(BL_ID) != null ? (String) inputMap.get(BL_ID) : null);
        String blId = (String) inputMap.get(BL_ID);
        boolean  createParRef =  inputMap.containsKey('createParRef') ? (boolean) inputMap.get('createParRef') : false;
        String parDetails = inputMap.containsKey('parDetail') ? JSON.serialize(inputMap.get('parDetail')) : '';
        String changeStatusAmendmentSubType = (String) inputMap.get(CHANGE_STATUE_AMENDMENT_SUB_TYPE);
        String additionalLicenseType = (String) inputMap.get(ADDITIONAL_LICENSE_TYPE);
        String courseId = ((String) inputMap.get(COURSE_ID) != null ? (String) inputMap.get(COURSE_ID) : null);
        String identificationId = ((String) inputMap.get(IDENTIFICATION_ID) != null
            ? (String) inputMap.get(IDENTIFICATION_ID)
            : null);
        String identificationCardId = ((String) inputMap.get('identificationCardId') != null
            ? (String) inputMap.get('identificationCardId')
            : null);
        String accountId = ((String) inputMap.get('accountId') != null ? (String) inputMap.get('accountId') : null);
         
        String applicationId = ((String) inputMap.get('applicationId') != null
            ? (String) inputMap.get('applicationId')
            : null);
        String revokedLicenseId = inputMap.containsKey('revokedLicenseId') ? (String) inputMap.get('revokedLicenseId') : null;
        String primaryState = inputMap.containsKey('primaryStateOfResidence') ? (String) inputMap.get('primaryStateOfResidence') : null;
        System.debug('=== PAR Parsed Input: regAuthId=' + regAuthId + ' | appType=' + applicationType + ' | amendType=' + amendmentType + ' | blId=' + oldBlId);
        try {
            String contactId;
            List<User> u = LPI_UserDao.getCurrentUserRecord();
            System.debug('=== CHECKPOINT 1: User Query Executed. User Count = ' + u.size());
            if (accountId != null  && u[0].Profile.Name != 'Portal User') {             
                if(applicationType == 'Business License'){
                    contactId = null;
                }else{
                    List<Account> accList = LPI_AccountDAO.getAccountListByDynamicQuery(new List<String>{'Id','PersonContactId'}, 'Id =\''+String.escapeSingleQuotes(accountId)+'\'',null,null,null);
                    contactId = accList[0].PersonContactId;
                }
            } else {
                if (u.size() == 0) {
                    System.debug('=== [FAIL POINT 1] User Not Found / Session Expired! ===');
                    LPI_ExceptionManager.logException(
                        CLASS_NAME,
                        METHOD_CREATE_PAR_RECORD,
                        'User Not Found!!',
                        'User Session Expired',
                        null,
                        null
                    );
                    return null;
                }
                accountId = u[0].AccountId;
                contactId = u[0].ContactId;
            }
            System.debug('=== Resolved Context: AccountId=' + accountId + ' | ContactId=' + contactId);

            // Fetch Account details to get First/Last Name for PAR
            String portalUserFirstName;
            String portalUserLastName;
            if (String.isNotBlank(accountId)) {
                List<Account> portalUserAccount = LPI_AccountDAO.getAccountListByDynamicQuery(
                    new List<String>{'Id', 'FirstName', 'LastName'},
                    'Id = \'' + String.escapeSingleQuotes(accountId) + '\'',
                    1,
                    null,
                    null
                );
                if (!portalUserAccount.isEmpty()) {
                    portalUserFirstName = portalUserAccount[0].FirstName;
                    portalUserLastName = portalUserAccount[0].LastName;
                }
            }

            List<RegulatoryAuthorizationType> regAuthList = LPI_RegulatoryAuthorizationTypeDAO.getRATTypeByID(
                new Set<Id>{ regAuthId }
            );
            System.debug('=== CHECKPOINT 2: RAT Query Executed. Found Count = ' + regAuthList.size());
            if (regAuthList.size() == 0) {
                System.debug('=== [FAIL POINT 2] No RAT Record Found for regAuthId: ' + regAuthId + ' ===');
                LPI_ExceptionManager.logException(
                    CLASS_NAME,
                    METHOD_CREATE_PAR_RECORD,
                    'No Licesne Found!!',
                    'No RAT Found',
                    null,
                    null
                );
                return null;
            }
            RegulatoryAuthorizationType regAuth = regAuthList[0];

             
            applicationType = String.isBlank(applicationType)
                ? LPI_LiteralConstant.IA_NEW_APPLICATIONTYPE
                : applicationType;

             
            String whereClauseForAppFlowConfig =
                ' Regulatory_Authorization_Type__c = \'' +
                String.escapeSingleQuotes(regAuthId) +
                '\' AND Application_Type__c = \'' +
                String.escapeSingleQuotes(applicationType) +
                '\' ';
            
            if (String.isNotBlank(amendmentType) && applicationType == AMENDMENT ) {
                whereClauseForAppFlowConfig += ' AND Application_Subtype__c = \'' + String.escapeSingleQuotes(amendmentType) + '\'';
            }
            System.debug('=== CHECKPOINT 3: App Flow Config Query Where Clause: ' + whereClauseForAppFlowConfig);
            List<Application_Flow_Config__c> listOfAppFlowConfig = LPI_ApplicationFlowConfigDAO.getApplicationFlowConfigByDymanicQuery(
                String.join(LIST_OF_APP_FLOW_CONFIG_FIELDS, ','),
                whereClauseForAppFlowConfig,
                '1',
                null,
                null
            );
            System.debug('=== CHECKPOINT 3 Result: App Flow Config Count = ' + listOfAppFlowConfig.size());
            Application_Flow_Config__c appFlowConfig = null;
            for(Application_Flow_Config__c appConfig : listOfAppFlowConfig){
                if(appConfig.Application_Subtype__c == amendmentType){
                    appFlowConfig = appConfig;
                    break;
                }
            }
            if(appFlowConfig == null && !listOfAppFlowConfig.isEmpty()){
                appFlowConfig = listOfAppFlowConfig[0];
            }

            if (listOfAppFlowConfig.isEmpty()) {
                System.debug('=== [FAIL POINT 3] No Application Flow Config found for: ' + whereClauseForAppFlowConfig + ' ===');
                LPI_ExceptionManager.logException(
                    CLASS_NAME,
                    METHOD_CREATE_PAR_RECORD,
                    FLOW_NOT_CONFIGURED,
                    FLOW_NOT_CONFIGURED_MESSAGE + whereClauseForAppFlowConfig,
                    null,
                    null
                );
                return null;
            }
            System.debug('=== Matched Flow Config ID: ' + appFlowConfig?.Id + ' | Target URL: ' + appFlowConfig?.Application_URL__c);
            
            Request reqInfo = Request.getCurrent();
            String currentRequestId = reqInfo.getRequestId();
            PreliminaryApplicationRef newPar;
            if(createParRef){
                newPar =  (PreliminaryApplicationRef) JSON.deserialize(parDetails, PreliminaryApplicationRef.class);
            }else{
                newPar = new PreliminaryApplicationRef();
            }
            
            newPar.Regulatory_Authorization_Type__c = regAuthId;
            
            newPar.BusinessAccountNameId = accountId;
            // Portal applicant's Account — copied to IA.Business_Account__c on convert
            newPar.Business_Account__c = accountId;
            newPar.Contact__c = contactId;
            newPar.ApplicationType = regAuth?.Authorisation_Type__c == LPI_LiteralConstant.CONTACT_INDIVIDUAL_RECORDTYPE
                ? LPI_LiteralConstant.IA_SOBJECT_API
                : LPI_LiteralConstant.BLA_SOBJECT_API;
            newPar.Status__c = LPI_LiteralConstant.PAR_DRAFT_STATUS;
            newPar.SavedApplicationUrl = appFlowConfig?.Application_URL__c;
            newPar.Course_ID__c = courseId;
            newPar.App_Flow_Config_Id__c = appFlowConfig?.Id;
            
             
            newPar.Old_Application_Id__c = applicationId;
            newPar.Channel__c = LPI_WithoutSharingUtility.isPortalUser() ? CHANNEL_ONLINE : CHANNEL_OFFLINE;
            Schema.Address addressFromBL = null;
            String existingResLocationId = null;
            if (
                String.isNotEmpty(oldBlId) &&
                appFlowConfig?.Application_Type__c != LPI_LiteralConstant.BLA_NEW_APPLICATIONTYPE
            ) {
                System.debug('=== CHECKPOINT 4: Querying Old Business License ID: ' + oldBlId);
                String whereClause = 'Id = \'' + String.escapeSingleQuotes(oldBlId) + '\'';
                List<BusinessLicense> license = new LPI_BusinessLicenseDAO.LPI_BusinessLicenseWithoutSharingDAO()
                    .getBusinessLicenseByDymanicQueryWithoutSecurity(
                        String.join(LIST_OF_BL_FIELDS, ','),
                        whereClause,
                        null,
                        null,
                        null
                    );
                if (!license.isEmpty()) {
                    System.debug('=== BL Hydration: Found License Record ===');
                    newPar.Is_Migrated_Data__c = license[0].Is_Migrated_Data__c;
                    newPar.BusinessAccountNameId = license[0].AccountId;
                    newPar.FirstName__c = license[0].First_Name__c;
                    newPar.LastName__c = license[0].Last_Name__c;
                    newPar.MiddleName__c = license[0].Middle_Name__c;
                    newPar.MaidenName__c = license[0].Maiden_Name__c;
                    newPar.Business_Name__c = license[0].Business_Name__c;

                    newPar.Primary_Contact_Address__c = license[0].Primary_Contact_Address__c;
                    newPar.License_Address__c = license[0].License_Address__c;
                    newPar.Publicly_Displayed_Address__c = license[0].Publicly_Displayed_Address__c;
                     
                    newPar.Consent_for_Primary_Contact_Address__c = license[0].Consent_for_Primary_Contact_Address__c;
                    Date expiryDate = license[0].PeriodEnd != null? Date.valueOf(license[0].PeriodEnd): null;
                    if(expiryDate != null){
                        newPar.Exp_date__c = expiryDate;
                    }
                    if (accountId == null) {
                        accountId = license[0].Contact.AccountId;
                        newPar.Contact__c = license[0].ContactId;
                    }
                    if (
                        applicationType == LPI_LiteralConstant.BLA_RENEWAL_APPLICATIONTYPE &&
                        license[0].PeriodEnd != null &&
                        license[0].PeriodEnd.Date() < System.today()
                    ) {
                        newPar.Late_Renewal__c = true;
                    }
                    
                } 
                newPar.Business_License__c = oldBlId;
                Set<Id> setOfLocationIdForBL = new Set<Id>();
                for (
                    AuthApplicationPlace authPlace : LPI_AuthApplicationPlaceDAO.getAuthApplicationPlaceByAuthorizationIds(
                        new Set<Id>{ oldBlId }
                    )
                ) {
                    setOfLocationIdForBL.add(authPlace.PlaceId);
                }
                if (!setOfLocationIdForBL.isEmpty()) {
                    List<Schema.Location> listOfLocation = LPI_LocationDAO.getLocationByIDsAndLocationType(
                        setOfLocationIdForBL,
                        new Set<String>{ LPI_LiteralConstant.LOCATION_TYPE_RESIDENCE }
                    );
                    if (!listOfLocation.isEmpty()) {
                        existingResLocationId = listOfLocation?.get(0)?.Id;
                    }
                }
                
            }
            newPar.ApplicationName = applicationType + ' Application';
            newPar.Type__c = applicationType;
            if(String.isEmpty(newPar.Amendment_Type__c)){
                if(amendmentType == APEP_BOARD_BUSINESS_REINSTATEMENT || amendmentType == APEP_BOARD_INDIVIDUAL_REINSTATEMENT){
                    newPar.Amendment_Type__c = REINSTATEMENT_TYPE;
                } else {
                    newPar.Amendment_Type__c = amendmentType != null ? amendmentType : appFlowConfig?.Application_Subtype__c;
                }
            }
            newPar.Change_Status_to__c = changeStatusAmendmentSubType;

            // Set First/Last Name if not already populated
            if (String.isBlank(newPar.FirstName__c) && String.isNotBlank(portalUserFirstName)) {
                newPar.FirstName__c = portalUserFirstName;
            }
            if (String.isBlank(newPar.LastName__c) && String.isNotBlank(portalUserLastName)) {
                newPar.LastName__c = portalUserLastName;
            }
            System.debug('=== CHECKPOINT 5: Inserting PAR Record... ===');
            newPar = (PreliminaryApplicationRef) LPI_WithoutSharingUtility.insertSObject(newPar);
            System.debug('=== PAR Insert Success. New PAR ID: ' + newPar.Id);
            if (
                regAuth?.Authorisation_Type__c == LPI_LiteralConstant.INDIVIDAULICENSE_APPTYPE &&
                (newPar.Type__c == 'New' ||
                newPar.Amendment_Type__c == 'Boxer\'s Federal ID Card' ||
                newPar.Amendment_Type__c == 'MMA National ID Card' ||
                newPar.Type__c == 'Pre-licensure Petition')
            ) {
                System.debug('=== CHECKPOINT 6: Creating Location / Address structures for Individual License ===');
                Account acc;
                
                List<Account> listOfAccount = LPI_AccountDAO.getAccountByIDs(new Set<String>{ accountId });
                if (listOfAccount.isEmpty()) {
                    System.debug('=== [FAIL POINT 6] Account not found for ID: ' + accountId + ' ===');
                    LPI_ExceptionManager.logException(
                        CLASS_NAME,
                        METHOD_CREATE_PAR_RECORD,
                        'No Account Found',
                        'No Account Found with Id ' + accountId,
                        null,
                        null
                    );
                } else {
                    acc = listOfAccount[0];
                    Schema.Location residenceLoc;
                    if (existingResLocationId == null) {
                        residenceLoc = new Schema.Location();
                        residenceLoc.Name = acc?.Name + '-' + LPI_LiteralConstant.LOCATION_TYPE_RESIDENCE;
                        residenceLoc.LocationType = LPI_LiteralConstant.LOCATION_TYPE_RESIDENCE;
                        residenceLoc.Status__c = LPI_LiteralConstant.LOCATION_STATUS_OPEN;
                        residenceLoc.OpenDate = System.today();
                        residenceLoc = (Schema.Location) LPI_DML.doInsert(residenceLoc);

                        
                        AssociatedLocation acl = new AssociatedLocation();
                        acl.ParentRecordId = accountId;
                        acl.LocationId = residenceLoc.id;
                        LPI_WithoutSharingUtility.insertSObject(acl);

                        Schema.Address residenceAddress = new Schema.Address();
                        residenceAddress.LocationType = LPI_LiteralConstant.LOCATION_TYPE_RESIDENCE;
                        residenceAddress.ParentId = residenceLoc.id;
                        residenceAddress.Street = acc?.PersonOtherStreet;
                        residenceAddress.City = acc?.PersonOtherCity;
                        if (acc?.PersonOtherStateCode != null) {
                            residenceAddress.StateCode = acc?.PersonOtherStateCode;
                        }
                        if (acc?.Other_State__c != null) {
                            residenceAddress.Business_State__c = acc?.Other_State__c;
                        }
                        residenceAddress.CountryCode = acc?.PersonOtherCountryCode;
                        residenceAddress.PostalCode = acc?.PersonOtherPostalCode;
                        residenceAddress.County__c = acc?.County__c;
                         
                        LPI_WithoutSharingUtility.insertSObject(residenceAddress);
                    }
                     
                    Temp_AuthApplicationPlace__c aap = new Temp_AuthApplicationPlace__c();
                    aap.Preliminary_Application_Reference__c = newPar.Id;
                    if (existingResLocationId != null) {
                        aap.Location__c = existingResLocationId;
                    } 
                    else if (residenceLoc != null) {
                        aap.Location__c = residenceLoc.id;
                    }
                    LPI_DML.doInsert(aap);
                }
            }
            outMap?.put(LPI_LiteralConstant.PAR_ID, newPar.Id);
            PreliminaryApplicationRef updatePar = new PreliminaryApplicationRef();
            updatePar.id = newPar.Id;
            String applicationURL = appFlowConfig.Application_URL__c;
            // Prefer multi-language Real Estate Salesperson OmniScript LWC over English.
            if (String.isNotBlank(applicationURL)) {
                applicationURL = applicationURL
                    .replace('c:fCNBRealStateEnglish', 'c:fCNBRealStateMultiLanguage')
                    .replace('c:fCNBRealStateMulti-Language', 'c:fCNBRealStateMultiLanguage');
                String omniLang = UserInfo.getLanguage();
                omniLang = (omniLang != null && omniLang.startsWith('fr')) ? 'fr' : 'en_US';
                if (!applicationURL.containsIgnoreCase('c__language=')) {
                    applicationURL += '&c__language=' + omniLang;
                }
            }
            // Generate the raw URL
            String fullUrl = applicationURL + LPI_LiteralConstant.PRE_APPLICATION_INTAKEFORM_URL_VARIABLENAME + newPar.Id;

            // Dynamically sanitize, strip unnecessary parameters, and cap length at 255
            String sanitizedUrl = formatAndTrimUrl(fullUrl);

            outMap?.put(INTAKE_LINK, sanitizedUrl);
            updatePar.SavedApplicationUrl = sanitizedUrl;

            System.debug('=== CHECKPOINT 7: Final Sanitized SavedApplicationUrl: ' + updatePar.SavedApplicationUrl);
                LPI_TriggerHandler.bypass(PAR_TRIGGER_HANDLER);
            if (LPI_TriggerHandler.isBypassed(PAR_TRIGGER_HANDLER)) {
                LPI_DML.doUpdate(updatePar);
                System.debug('=== PAR Updated Successfully ===');
            }
            LPI_TriggerHandler.clearBypass(PAR_TRIGGER_HANDLER);
            return new Map<String, Object>{ 'parRec' => updatePar };
        } catch (Exception e) {
             System.debug('=== [EXCEPTIONAL FAIL POINT IN createPARRecord] ===');
             System.debug('Message: ' + e.getMessage());
             System.debug('Line: ' + e.getLineNumber());
             System.debug('StackTrace: ' + e.getStackTraceString());
            outMap?.put(BLA_ERROR, e.getStackTraceString());
            LPI_ExceptionManager.logException(CLASS_NAME, METHOD_CREATE_PAR_RECORD, e);
            return null;
        }
    }
         /**
         * Dynamically sanitizes and trims URLs to ensure they fit within the 255-character limit
         * of the PreliminaryApplicationRef.SavedApplicationUrl field.
         */
        public static String formatAndTrimUrl(String rawUrl) {
            if (String.isBlank(rawUrl)) {
                return rawUrl;
            }

            String cleanedUrl = rawUrl;

            // 1. Convert absolute URL (https://domain.com/s/...) to a relative URL (/s/...)
            if (cleanedUrl.startsWithIgnoreCase('http://') || cleanedUrl.startsWithIgnoreCase('https://')) {
                try {
                    Url parsedUrl = new Url(cleanedUrl);
                    cleanedUrl = parsedUrl.getPath() + (String.isNotBlank(parsedUrl.getQuery()) ? '?' + parsedUrl.getQuery() : '');
                } catch (Exception e) {
                    cleanedUrl = cleanedUrl.replaceFirst('^https?://[^/]+', '');
                }
            }

            // 2. Fix double slashes (e.g. //s/ -> /s/)
            while (cleanedUrl.startsWith('//')) {
                cleanedUrl = cleanedUrl.substring(1);
            }

            // 3. Dynamically strip non-essential UI parameters (c__layout, c__tabIcon) using Regex
            cleanedUrl = cleanedUrl.replaceAll('(?i)[&?]c__layout=[^&]*', '');
            cleanedUrl = cleanedUrl.replaceAll('(?i)[&?]c__tabIcon=[^&]*', '');

            // 4. Fix query parameter string if leading '?' was removed during parameter stripping
            if (!cleanedUrl.contains('?') && cleanedUrl.contains('&')) {
                cleanedUrl = cleanedUrl.replaceFirst('&', '?');
            }

            // 5. Safety fallback truncation if still over 255 characters
            if (cleanedUrl.length() > 255) {
                cleanedUrl = cleanedUrl.substring(0, 255);
            }

            return cleanedUrl;
        }



    /**
     * @author                         : MTX Group Product Team
     * @since                          : 3 Nov, 2022
     * @description                    : This method is used for validating if action is allowed based
     *                                   on existing applications
     * @param inputMap                 : Map Of input param
     * @param outMap                   : Map Of output param
     * @param options                  : Map Of options
     * @return                         : Boolean
     * @last modified by               : MTX Group Product Team
     * @last modified date             : 17 Jan, 2023
     * @last modified details          : Move queries to respective DAO classes, replace DML statement to
     *                                   LPI_DML methods and removed static Strings
     */
    @AuraEnabled
    public static Boolean setActionAllowedValidation(Map<String, Object> inputMap) {
        try {
            String applicationType = (String) inputMap.get('type');
            if (applicationType != null) {
                applicationType = applicationType.capitalize();
            }
            String blId = (String) inputMap.get('blId');
            String subtype = (String) inputMap.get('amendmentType');
            String courseId = (String) inputMap.get('courseId');
            String regAuthId = (String) inputMap.get('regAuthId');
            String accountId = (String) inputMap.get('accountId');
            String identificationCardId = (String) inputMap.get('identificationCardId');
            
            String oldApplicationId = (String) inputMap.get('applicationId');
            Boolean isActionAllowed = false;
            String accountRecordType = '';
            List<PreliminaryApplicationRef> parRecList = new List<PreliminaryApplicationRef>();
            List<String> statusAllowed = new List<String>{
                LPI_LiteralConstant.BLA_WITHDRAWN_STATUS,
                LPI_LiteralConstant.IA_REJECTED_STATUS,
                STATUS_EXPIRED
            };
            
            applicationType = String.isBlank(applicationType)
            ? LPI_LiteralConstant.IA_NEW_APPLICATIONTYPE
            : applicationType;

            
            if(String.isNotBlank(applicationType) && SET_ACTION_VALIDATION_BYPASS_APPLICATION_TYPE_SET.contains(applicationType)){
                return true;
            }
            
            Integer geologistAppCount = 0;
            String whereCondition =
            ' Regulatory_Authorization_Type__c = ' +
            '\'' +
            String.escapeSingleQuotes(regAuthId) +
            '\'' +
            ' AND Type__c = ' +
            '\'' +
            String.escapeSingleQuotes(applicationType) +
            '\'';
            
            if (applicationType != LPI_LiteralConstant.IA_NEW_APPLICATIONTYPE && blId != null && String.isNotBlank(blId)) {
                whereCondition += ' AND Business_License__c = ' + '\'' + String.escapeSingleQuotes(blId) + '\'';
            }
             
            if (String.isNotBlank(oldApplicationId)) {
                whereCondition +=
                    ' AND Old_Application_Id__c = ' +
                    '\'' +
                    String.escapeSingleQuotes(oldApplicationId) +
                    '\'';
            }
             
                if (accountId == null) {
                    List<User> u = LPI_UserDao.getCurrentUserRecord();
                    if (u.size() == 0) {
                        LPI_ExceptionManager.logException(
                            CLASS_NAME,
                            'setActionAllowedValidation',
                            'User Not Found!!',
                            'User Session Expired',
                            null,
                            null
                        );
                        return false;
                    }
                    accountId = u[0].AccountId;
                }
            if (String.isNotBlank(accountId)) {
                List<Account> accList = LPI_AccountDAO.getAccountListByDynamicQuery(
                     new List<String>{'Id','RecordType.DeveloperName'},
                    'Id = \'' + String.escapeSingleQuotes(accountId) + '\'',
                    1,
                    null,
                    null
                );
                if(!accList.isEmpty() && accList[0].RecordType.DeveloperName == LPI_LiteralConstant.ACCOUNT_BUSINESS_RECORDTYPE){
                    accountRecordType =  LPI_LiteralConstant.ACCOUNT_BUSINESS_RECORDTYPE;
                    whereCondition += ' AND BusinessAccountNameId = ' + '\'' + String.escapeSingleQuotes(accountId) + '\'';
                }else{
                    accountRecordType =  LPI_LiteralConstant.ACCOUNT_PERSON_RECORDTYPE;
                whereCondition += ' AND Contact__r.AccountId = ' + '\'' + String.escapeSingleQuotes(accountId) + '\'';
                }
            }
             
            if (applicationType == TYPE_AMENDMENT && String.isNotBlank(subtype)) {
                whereCondition += ' AND Amendment_Type__c = ' + '\'' + String.escapeSingleQuotes(subtype) + '\'';
            }
             
            if (String.isNotBlank(courseId)) {
                whereCondition += ' AND Course_ID__c = ' + '\'' + String.escapeSingleQuotes(courseId) + '\'';
            }
             
            parRecList = LPI_PreliminaryApplicationRefDAO.getPreliminaryApplicationRefByDymanicQuery(
                'Id, Status__c,Regulatory_Authorization_Type__c,Regulatory_Authorization_Type__r.Name,ApplicationType, Amendment_Type__c,Channel__c,' +
                    '(SELECT Status, ApplicationType, Amendment_Type__c FROM IndividualApplicationAppRef WHERE Status != ' +
                    '\'' +
                    DRAFT +
                    '\'),' +
                    '(SELECT Status FROM BusinessLicenseApplicationSavedRef WHERE Status !=' +
                    '\'' +
                    DRAFT +
                    '\') ',
                whereCondition,
                '1',
                'CreatedDate',
                'desc'
            );
            if (
                parRecList.isEmpty() ||
                (!parRecList.isEmpty() &&
                parRecList[0].ApplicationType == LPI_LiteralConstant.BLA_SOBJECT_API &&
                applicationType == LPI_LiteralConstant.IA_NEW_APPLICATIONTYPE &&
                parRecList[0].Channel__c != CHANNEL_OFFLINE)
                ) {
                    isActionAllowed = parRecList.isEmpty() ? true : accountRecordType != LPI_LiteralConstant.ACCOUNT_BUSINESS_RECORDTYPE;
                } else {
                    isActionAllowed = true;
                }
                return isActionAllowed;
            } catch (Exception e) {
            LPI_ExceptionManager.logException('LPI_ApplicationViewController', 'setActionAllowedValidation', e);
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    /**
     * @author          : MTX Group Product Team
     * @description     : This method is Used to check address duplicate
     * @param inputMap  : fetching all the input from Omniscript
     * @param outMap    : Passing value to Omniscript
     * @param options   : Passing Options to Omniscript if needed
     */
    public static boolean checkExistingBusinessApplicationWithAddress(Account businessAccDetails, String parId) {
        try {
            boolean result = false;
            List<String> statusAllowed = new List<String>{
                LPI_LiteralConstant.BLA_WITHDRAWN_STATUS,
                LPI_LiteralConstant.IA_REJECTED_STATUS
            };
            String fieldsToQueryAcc = '';
            String whereClauseForAcc = '';
            if (businessAccDetails != null && businessAccDetails.Id == null) {
                result = false;
            } else {
                fieldsToQueryAcc = 'Id,Name,Regulatory_Authorization_Type__c,Contact__r.AccountId,Type__c, Amendment_Type__c,Regulatory_Authorization_Type__r.Name';
                whereClauseForAcc = ' Id = \'' + parId + '\'';
                List<PreliminaryApplicationRef> parList = new LPI_PreliminaryApplicationRefDAO.LPI_PreliminaryApplicationRefWithoutSharingDAO()
                    .getPreliminaryApplicationRefByDymanicQuery(fieldsToQueryAcc, whereClauseForAcc, null, null, null);
                if (parList.isEmpty() || parList?.get(0)?.Regulatory_Authorization_Type__c == null) {
                    LPI_ExceptionManager.logException(
                        'LPI_ApplicationFlowUtility',
                        'checkExistingBusinessApplicationWithAddress',
                        'Application Not Found',
                        'Application Not Found',
                        null,
                        null
                    );
                    result = true;
                } else {
                    whereClauseForAcc = '';
                    if (String.isNotBlank(parList[0].Contact__r.AccountId)){
                        whereClauseForAcc = ' Contact__r.AccountId = \'' + parList[0].Contact__r.AccountId + '\' AND ';
                    }
                    whereClauseForAcc += ' BusinessAccountNameId = \'' + businessAccDetails.Id + '\'' +
                    ' AND Regulatory_Authorization_Type__c = \'' + parList[0].Regulatory_Authorization_Type__c + '\'' +
                    ' AND Id != \'' + parList[0].Id + '\'';
                     
                    List<PreliminaryApplicationRef> parListNew = new LPI_PreliminaryApplicationRefDAO.LPI_PreliminaryApplicationRefWithoutSharingDAO()
                        .getPreliminaryApplicationRefByDymanicQuery(
                            'Id, Status__c, ApplicationType,(SELECT Status FROM BusinessLicenseApplicationSavedRef)',
                            whereClauseForAcc,
                            '1',
                            'CreatedDate',
                            'desc'
                        );
                    if (parListNew.isEmpty()) {
                        result = false;
                    } else {
                        if (!statusAllowed.contains(parListNew[0].Status__c)) {
                            result = false;
                            if (parListNew[0].BusinessLicenseApplicationSavedRef.size() > 0) {
                                if (
                                    !statusAllowed.contains(parListNew[0].BusinessLicenseApplicationSavedRef[0].Status)
                                ) {
                                    List<Businesslicense> businessLicenseList = fetchVoidBusinessLicense(
                                        parList[0].Regulatory_Authorization_Type__c,
                                        parList[0].Contact__r.AccountId
                                    );
                                    result = true;
                                    if (!businessLicenseList.isEmpty() && businessLicenseList[0].Status == LPI_LiteralConstant.Business_License_Status_VOID) {
                                        result = false;
                                    }
                                }
                            } else {
                                result = true;
                            }
                        } else {
                            result = false;
                        }
                    }
                    
                }
            }
            return result;
        } catch (Exception exp) {
            LPI_ExceptionManager.logException(
                'LPI_ApplicationFlowUtility',
                'checkExistingBusinessApplicationWithAddress',
                exp
            );
            return true;
        }
    }
    /**
     * @author          : MTX Group Product Team
     * @description     : This method is Used to fetch Void licenses
     */
    public static List<BusinessLicense> fetchVoidBusinessLicense(String regAuthId, String accountId) {
        String fieldsToQuery = 'Id,Status,Regulatory_Authorization_Type_Name__c';
        String whereClause =' RegulatoryAuthorizationTypeId = \'' + regAuthId + '\'';
        if (accountId != null) {
            whereClause = whereClause + ' AND Contact.AccountId  = \'' + accountId + '\'';
        }
         
        return new LPI_BusinessLicenseDAO.LPI_BusinessLicenseWithoutSharingDAO()
            .getBusinessLicenseByDymanicQuery(fieldsToQuery, whereClause, '1', 'CreatedDate', 'desc');
    }
    /**
     * @author                  : MTX Group Product Team
     * @since                   : 10 May, 2023
     * @description             : This method is Used to create Application_Content__c record from BL for Athletics & Private Investigator Board for flows which are not New
     * @param blId              : BusinessLicense Id
     * @param parId             : PreliminaryApplicationRef Id
     * @last modified by        : MTX Group Product Team
     * @last modified date      : (Add if modified by you)
     * @last modified details   : (Add if modified by you)
     */
    public static Application_Content__c createApplicationContentRecord(String blId, String parId) {
        try{
            String fields = 'Account.Feet__c, Account.Inches__c, Account.Weight__c, Account.Hair_Color__c, Account.Eye_Color__c,'
            +'Missouri_License_Number__c';
            String whereCondition = 'Id = \'' +
                            String.escapeSingleQuotes(blId)
                            + '\'';
            List<BusinessLicense> blList = LPI_BusinessLicenseDAO.fetchBusinessLicenseRecords(
                                fields,
                                whereCondition
                            );
            Application_Content__c appContent = new Application_Content__c();
            if( ! blList.isEmpty() ){
                BusinessLicense bl = blList[0];
                appContent.Section_Header__c = PERSON_ADDITIONAL_INFO;
                appContent.Preliminary_Application_Reference__c = parId;
                appContent.Feet__c = bl.Account.Feet__c;
                appContent.Inches__c = bl.Account.Inches__c;
                appContent.Eye_Color__c = bl.Account.Eye_Color__c;
                LPI_DML.doUpsert(appContent);
            }
            return appContent;
        } catch( Exception e){
            LPI_ExceptionManager.logException(CLASS_NAME, 'createApplicationContentRecord', e);
            return null;
        }
    }
    /**
     * @author          :  MTX Group Product Team
     * @description     : This Method is used to fetch the Bad Check Flag from Business Licesne
     */
    @AuraEnabled
    public static Boolean fetchBLBadCheck(Map<String, Object> inputMap) {

        String blId = (String) inputMap.get('blId');
        Boolean badCheck = false;
        if(!String.isEmpty(blId)){
            String fieldsToQuery = 'Id,Bad_Check_Flag__c';
            String whereClause =' Id = \'' + blId + '\'';
             
            List<BusinessLicense> blList = new List<BusinessLicense>();
             
            LPI_BusinessLicenseDAO.LPI_BusinessLicenseWithoutSharingDAO withoutSharingBL = 
                    new LPI_BusinessLicenseDAO.LPI_BusinessLicenseWithoutSharingDAO();
            blList = withoutSharingBL.getBusinessLicenseByDymanicQuery(fieldsToQuery,whereClause,null, null, null);
            badCheck =  (blList[0].Bad_Check_Flag__c != null) ? blList[0].Bad_Check_Flag__c : false;
        }
        return badCheck;
    }
}