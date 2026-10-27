/**
* @author            : MTX Group Inc
* @description       : Standard Class for Personal Information
* @last modified on  : 07-24-2024
* @last modified by  : MTX Group Inc
**/
global with sharing class LPI_PersonalInfo implements Callable {
    // ************************************************************************************ ALL CONSTANTS *******************************************************************
    public final static String CLASS_NAME = 'LPI_PersonalInfo';
    public final static String RESIDENCE = 'Residence';
    public final static String MAILING = 'Mailing';
    public final static String PRIMARY_CONTACT_ADDRESS = 'Primary Contact Address';
    public final static String LICENSE_ADDRESS = 'License Address';
    public final static String PUBLICLY_DISPLAYED_ADDRESS = 'Publicly Displayed Address';
    public static final Set<String> APPLICABLE_IA_STATUS = new Set<String>{ 'Approved', 'License Issued', 'Rejected' };
        private static final String BOXER_FEDERAL_ID_CARD = 'Boxer\'s Federal ID Card';
    private static final Set<String> MAILING_ADDRESS_SAME_AS_RESIDENCE_BOARD_SET = new Set<String>{
        'Dietitians',
            'Interior Design',
            'Hearing Instrument Specialists',
            'Veterinary'
            };
                public static final Set<String> SET_OF_IDENTIFICATION_CARDS = new Set<String>{
                    'Boxer\'' + 's Federal ID Card',
                        'MMA National ID Card'
                        };
                            public final static Set<String> ATHLETICS_CONTESTANT_SET = new Set<String>{
                                'Boxing Contestant',
                                    'Martial Arts Amateur Contestant',
                                    'Martial Arts Contestant'
                                    };
                                        public final static String PERSON_ADDITIONAL_INFO = 'Person Additional Information';
    
    public final static List<String> ALL_ADDRESS_LIST = new List<String>{
        'Residence',
            'Mailing',
            'Business Address',
            'Branch',
            'Secondary Business Address',
            'Local Address',
            'Other'
            };
                public final static String OPEN = 'Open';
    private static final String UNITED_STATES = 'UNITED STATES';
    private static final String FOREIGN = 'Foreign';
    private static final String NATURALIZATION = 'Naturalization';
    private static final String VISA_PERMIT = 'Visa with stamped date of US entry';
    private static final String RESIDENT_CARD = 'US Permanent Resident Card';
    private static final String STUDENT_VISA = 'F-1 Student Visa';
    private static final String RESIDENT_CARD_EXPIRED = 'Permanent Resident Card Expired - Extension Granted';
    private static final String HB_VISA = 'H1B Visa';
    private static final Set<String> US_RESIDENTS_SET = new Set<String>{ RESIDENT_CARD, RESIDENT_CARD_EXPIRED };
    private static final Set<String> VISA_PERMIT_SET = new Set<String>{ VISA_PERMIT, HB_VISA };
    private static final String SAVE_CITIZENSHIP_DETAILS = 'saveCitizenshipDetails';
    private static final String CHECK_VALID_SSN_NUMBER_DETAILS = 'checkValidSSNNumberOnPersonalInfo';
    private static final String SUBMITTED = 'Submitted';
    private static final String WASHINGTON_STATE_CODE = 'DC';
    private static final String WASHINGTON_STATE_VALUE = 'Washington, D.C.';
    
    // ***************************************************************************************************************************************************************************
    global Object call(String action, Map<String, Object> args) {
        Map<String, Object> input = (Map<String, Object>) args.get('input');
        Map<String, Object> output = (Map<String, Object>) args.get('output');
        Map<String, Object> options = (Map<String, Object>) args.get('options');
        return invokeMethod(action, input, output, options);
    }
    
    private Boolean invokeMethod(
        String methodName,
        Map<String, Object> inputMap,
        Map<String, Object> outMap,
        Map<String, Object> options
    ) {
        if (methodName == 'FetchPersonalInfo') {
            fetchPersonalInfo(inputMap, outMap);
        } else if (methodName == 'SavePersonalInfo') {
            savePersonalInfo(inputMap, outMap);
            lawfulPresenceDocConfiguration(
                (String) inputMap.get('parid'),
                (String) options.get('DocumentRequiredJSON')
            );
        } else if (methodName == 'fetchAppContentRecordAndIdentificationCardDetails') {
            fetchAppContentRecordAndIdentificationCardDetails(inputMap, outMap);
        } else if (methodName == 'CheckAddressValidation') {
            CheckAddressValidation(inputMap, outMap);
        }
        else if(methodName =='validationForAddressTypeField')
        {
            validationForAddressTypeField(inputMap,outMap);
        }
        else if(methodName =='lawfulPresenceDocConfiguration')
        {
            lawfulPresenceDocConfiguration(
                (String) inputMap.get('parid'),
                (String) options.get('DocumentRequiredJSON')
            );
        }
        
        return true;
    }
    
    /**
* @author               		: MTX Group Inc
* @description       	 		: This method is used to fetch all the fields of Personal Information step
* @param inputMap              : Input data passed from OmniScript
* @param outMap                : Output data passed to OmniScript
* @return                      : `void`
* @last modified by     		: MTX Group Inc
* @last modified date   		: March 4, 2024
* @modified details     		: Code Beautification for better understanding
*/
    public static void fetchPersonalInfo(Map<String, Object> inputMap, Map<String, Object> outMap) {
        try {
            String fields;
            String whereClause;
            String parId = (String) inputMap.get('parid');
            Map<Id, Id> locationIds = new Map<Id, Id>();
            fields =
                'Id, Old_Application_Id__c, Approval_Supervisors_AcrIds__c ,Is_Supervisor_User__c, ' 
                + 'Other_Names__c, LastName__c, MaidenName__c, BusinessAccountNameId, MiddleName__c, BusinessAccountName.Name, ' 
                + 'FirstName__c, Type__c, Regulatory_Authorization_Type__r.Name, Amendment_Type__c, ' 
                + 'Status__c, Consent_for_Primary_Contact_Address__c, BusinessAccountName.Other_Names__c, ' 
                + 'BusinessAccountName.LastName, BusinessAccountName.Maiden_Name__c, BusinessAccountName.MiddleName, ' 
                + 'BusinessAccountName.HaveYouAnotherName__c, BusinessAccountName.FirstName, BusinessAccountName.Other_Language__c, ' 
                + 'BusinessAccountName.Other_Race__c, BusinessAccountName.Place_Of_Birth__c, BusinessAccountName.Other_Citizenship__c, ' 
                + 'BusinessAccountName.Date_of_Birth__c, BusinessAccountName.Language__c, BusinessAccountName.Suffix, ' 
                + 'BusinessAccountName.Age__c, BusinessAccountName.IsMailingAddress_same_as_current_Address__c, ' 
                + 'BusinessAccountName.PersonEmail, BusinessAccountName.Gender__c, BusinessAccountName.Citizenship__c, ' 
                + 'BusinessAccountName.PersonHomePhone, BusinessAccountName.Social_Security_Number__c, ' 
                + 'BusinessAccountName.Race__c, BusinessAccountName.Fax, Business_License__r.Is_Migrated_Data__c, ' 
                + 'BusinessAccountName.Phone, Regulatory_Authorization_Type__r.Amendment_Type__c, ' 
                + 'Regulatory_Authorization_Type__r.IssuingDepartment.Name, Primary_Contact_Address__c, License_Address__c, ' 
                + 'Publicly_Displayed_Address__c, BusinessAccountName.Proof_of_work_permit_in_United_States__c, ' 
                + 'BusinessAccountName.Proof_of_Citizenship__c, BusinessAccountName.USCIS_Number__c, ' 
                + 'BusinessAccountName.Naturalization_Number__c, BusinessAccountName.VISA_Number__c, ' 
                + 'BusinessAccountName.US_Permanent_Resident_Card_Number__c, BusinessAccountName.Passport_Number__c, ' 
                + 'BusinessAccountName.SEVIS_ID__c, BusinessAccountName.Nationality__c, Citizenship__c,BusinessAccountName.Other_Nationality__c, ' 
                + 'BusinessAccountName.I_94_Number__c, BusinessAccountName.Citizenship_Number__c, BusinessAccountName.H1B_Visa_Number__c, ' 
                + 'BusinessAccountName.Passport_Country__c, Contact__r.AccountId, USCIS_Number__c, SEVIS_ID__c, ' 
                + 'US_Permanent_Resident_Card_Number__c, Passport_Number__c, VISA_Number__c, ' 
                + 'Naturalization_Number__c, Proof_of_Citizenship__c, Proof_of_work_permit_in_United_States__c, H1B_Visa_Number__c, ' 
                + 'Board_Name__c';
            whereClause = 'Id = \'' + String.escapeSingleQuotes(parId) + '\'';
            List<PreliminaryApplicationRef> parList = LPI_PreliminaryApplicationRefDAO.getPreliminaryApplicationRefByDymanicQuery(
                fields, whereClause, null, null, null);
            if (!parList.isEmpty()) {
                outMap.put('isSupervisorUser', parList[0].Is_Supervisor_User__c);
                outMap.put('parType', parList[0].Type__c);
                outMap.put('type', parList[0].Type__c);
                outMap.put('todaysDate', Date.Today());
                outMap.put('status', parList[0].Status__c);
                outMap.put('regAuthTypeName', parList[0].Regulatory_Authorization_Type__r.Name);
                outMap.put('ListOfAnotherNames', parList[0].Other_Names__c);
                outMap.put('parId', parList[0].Id);
                outMap.put('ConsentCheckboxForMainPIStep', parList[0].Consent_for_Primary_Contact_Address__c);
                outMap.put('subTypeCategory', parList[0].Amendment_Type__c);
                outMap.put('ConMiddleName', String.isBlank(parList[0].MiddleName__c) ? parList[0].BusinessAccountName.MiddleName : 
                           parList[0].MiddleName__c);
                outMap.put('LastName', String.isBlank(parList[0].LastName__c) ? parList[0].BusinessAccountName.LastName : 
                           parList[0].LastName__c);
                outMap.put('FirstName', String.isBlank(parList[0].FirstName__c) ? parList[0].BusinessAccountName.FirstName : 
                           parList[0].FirstName__c);
                outMap.put('MaidenName', String.isBlank(parList[0].MaidenName__c) ? parList[0].BusinessAccountName.Maiden_Name__c : 
                           parList[0].MaidenName__c);
                if (parList[0].Type__c == 'Amendment' && (parList[0].Amendment_Type__c == 'Change of Name and/or Residence Address'
                                                          || parList[0].Amendment_Type__c == 'Change of Name')) {
                                                              outMap.put('ConMiddleNameRO', parList[0].MiddleName__c);
                                                          } 
                else {
                    outMap.put('ConMiddleNameRO', String.isBlank(parList[0].MiddleName__c) ? parList[0].BusinessAccountName.MiddleName : 
                               parList[0].MiddleName__c);
                }
                outMap.put('LastNameRO', String.isBlank(parList[0].LastName__c) ? parList[0].BusinessAccountName.LastName : 
                           parList[0].LastName__c);
                outMap.put('FirstNameRO', String.isBlank(parList[0].FirstName__c) ? parList[0].BusinessAccountName.FirstName : 
                           parList[0].FirstName__c);
                if (parList[0].Type__c == 'Amendment' && (parList[0].Amendment_Type__c == 'Change of Name and/or Residence Address'
                                                          || parList[0].Amendment_Type__c == 'Change of Name')) {
                                                              outMap.put('MaidenNameRO', parList[0].MaidenName__c);
                                                          } 
                else {
                    outMap.put('MaidenNameRO', String.isBlank(parList[0].MaidenName__c) ? 
                               parList[0].BusinessAccountName.Maiden_Name__c : parList[0].MaidenName__c);
                }
                outMap.put('ListOfAnotherNamesForRenewal', String.isBlank(parList[0].Other_Names__c) ? 
                           parList[0].BusinessAccountName.Other_Names__c : parList[0].Other_Names__c);
                outMap.put('BoardName', parList[0].Regulatory_Authorization_Type__r.IssuingDepartment.Name);
                outMap.put('Suffix', parList[0].BusinessAccountName.Suffix);
                outMap.put('SuffixRO', parList[0].BusinessAccountName.Suffix);
                outMap.put('SocialSecurityNumberRO', parList[0].BusinessAccountName.Social_Security_Number__c);
                List<IndividualApplication> iaApplication = LPI_IndividualApplicationDAO.getIndividualApplicationByDymanicQuery(
                    'Id', 'AccountId = \'' + parList[0].BusinessAccountNameId + '\'' + ' AND Status = \'' + SUBMITTED + '\'',
                    null, null, null);
                List<BusinessLicenseApplication> bLAApplication = LPI_BusinessLicenseApplicationDAO.getBusinessLicenseApplicationByDymanicQuery(
                    'Id', 'Applicant.AccountId = \'' + parList[0].BusinessAccountNameId + '\'' + ' AND Status = \'' + SUBMITTED + '\'',
                    null, null, null);
                List<BusinessLicense> businessLicense = LPI_BusinessLicenseDAO.fetchBusinessLicenseRecords(
                    'Id', 'Contact.AccountId = \'' + parList[0].BusinessAccountNameId + '\'');
                if (iaApplication.isEmpty() && bLAApplication.isEmpty() && businessLicense.isEmpty()) {
                    outMap.put('showSSNIfNoApplicationSubmittedFromAccount', true);
                    outMap.put('UpdateSSNIfNoApplicationSubmittedFromAccount', parList[0].BusinessAccountName.Social_Security_Number__c);
                } 
                else {
                    outMap.put('showSSNIfNoApplicationSubmittedFromAccount', false);
                }
                outMap.put('UpdateSSNIfNoApplicationSubmittedFromAccountRO', parList[0].BusinessAccountName.Social_Security_Number__c);
                outMap.put('UpdateSSNIfNoApplicationSubmittedFromAccountROBlock', parList[0].BusinessAccountName.Social_Security_Number__c);
                outMap.put('SocialSecurityNumberROBlock', parList[0].BusinessAccountName.Social_Security_Number__c);
                outMap.put('SocialSecurityNumberEditForRenewal', parList[0].BusinessAccountName.Social_Security_Number__c);
                outMap.put('SocialSecurityNumberEditForRenewalROBlock', parList[0].BusinessAccountName.Social_Security_Number__c);
                outMap.put('SocialSecurityNumberROForRenewal', parList[0].BusinessAccountName.Social_Security_Number__c);
                outMap.put('SocialSecurityNumberROForRenewalShowEditFalse', parList[0].BusinessAccountName.Social_Security_Number__c);
                if (parList[0].BusinessAccountName.Social_Security_Number__c != null) {
                    outMap.put('ShowTextBoxReadOnlyInRenewal', true);
                } 
                else {
                    outMap.put('ShowTextBoxReadOnlyInRenewal', false);
                }
                outMap.put('Race', parList[0].BusinessAccountName.Race__c);
                outMap.put('RaceRO', parList[0].BusinessAccountName.Race__c);
                outMap.put('PlaceOfBirth', parList[0].BusinessAccountName.Place_Of_Birth__c);
                outMap.put('PlaceOfBirthRO', parList[0].BusinessAccountName.Place_Of_Birth__c);
                outMap.put('TelephoneNumber', parList[0].BusinessAccountName.PersonHomePhone);
                outMap.put('TelephoneNumberRO', parList[0].BusinessAccountName.PersonHomePhone);
                outMap.put('E-mailAddress', parList[0].BusinessAccountName.PersonEmail);
                outMap.put('E-mailAddressRO', parList[0].BusinessAccountName.PersonEmail);
                outMap.put('OtherRaceReadOnly', parList[0].BusinessAccountName.Other_Race__c);
                outMap.put('OtherRace', parList[0].BusinessAccountName.Other_Race__c);
                outMap.put('OtherRaceRO', parList[0].BusinessAccountName.Other_Race__c);
                outMap.put('ListOfAnotherNames', parList[0].BusinessAccountName.Other_Names__c);
                outMap.put('ForeignLanguage', parList[0].BusinessAccountName.Other_Language__c);
                outMap.put('ForeignLanguageRO', parList[0].BusinessAccountName.Other_Language__c);
                outMap.put('ForeignLanguageReadOnly', parList[0].BusinessAccountName.Other_Language__c);
                outMap.put('ForeignCitizenshipReadOnly', parList[0].BusinessAccountName.Other_Citizenship__c);
                outMap.put('ForeignCitizenship', parList[0].BusinessAccountName.Other_Citizenship__c);
                outMap.put('ForeignCitizenshipRO', parList[0].BusinessAccountName.Other_Citizenship__c);
                outMap.put('language', parList[0].BusinessAccountName.Language__c);
                outMap.put('Nationality', parList[0].BusinessAccountName.Nationality__c);
                outMap.put('NationalityRO', parList[0].BusinessAccountName.Nationality__c);
                outMap.put('OtherNationality', parList[0].BusinessAccountName.Other_Nationality__c);
                outMap.put('OtherNationalityRO', parList[0].BusinessAccountName.Other_Nationality__c);
                outMap.put('languageRO', parList[0].BusinessAccountName.Language__c);
                outMap.put('MailingAddressSameAsCurrentAddress1', 
                           parList[0].BusinessAccountName.IsMailingAddress_same_as_current_Address__c);
                outMap.put('MailingAddressSameAsCurrentAddress2', 
                           parList[0].BusinessAccountName.IsMailingAddress_same_as_current_Address__c);
                outMap.put('MailingAddressSameAsCurrentAddressRO1', 
                           parList[0].BusinessAccountName.IsMailingAddress_same_as_current_Address__c);
                outMap.put('MailingAddressSameAsCurrentAddressRO2', 
                           parList[0].BusinessAccountName.IsMailingAddress_same_as_current_Address__c);
                outMap.put('MailingAddressSameAsCurrentAddressRO', 
                           parList[0].BusinessAccountName.IsMailingAddress_same_as_current_Address__c);
                outMap.put('accountId', parList[0].BusinessAccountNameId);
                inputMap.put('accountId', parList[0].BusinessAccountNameId);
                LPI_AliasController.getAliasData(inputMap, outMap);
                outMap.put('Gender', parList[0].BusinessAccountName.Gender__c);
                outMap.put('GenderRO', parList[0].BusinessAccountName.Gender__c);
                outMap.put('DateofBirth', parList[0].BusinessAccountName.Date_of_Birth__c);
                outMap.put('DateofBirthRO', parList[0].BusinessAccountName.Date_of_Birth__c);
                outMap.put('Age', parList[0].BusinessAccountName.Age__c);
                outMap.put('IsMigratedData', parList[0].Business_License__r.Is_Migrated_Data__c);
                outMap.put('FaxNumber', parList[0].BusinessAccountName.Fax);
                outMap.put('FaxNumberRO', parList[0].BusinessAccountName.Fax);
                outMap.put('CellPhone', parList[0].BusinessAccountName.Phone);
                outMap.put('CellPhoneRO', parList[0].BusinessAccountName.Phone);
                outMap.put('AccMiddleNameRO', parList[0].BusinessAccountName.MiddleName);
                outMap.put('AccMaidenNameRO', parList[0].BusinessAccountName.Maiden_Name__c);
                outMap.put('AccOtherNameRO', parList[0].BusinessAccountName.Other_Names__c);
                outMap.put('AccountNameRO', parList[0].BusinessAccountName.Name);
                outMap.put('callDisciplineApi',
                           (parList[0].Amendment_Type__c == 'Endorsement' || parList[0].Amendment_Type__c == 'Reinstatement' ||
                            parList[0].Amendment_Type__c == 'Renewal' || 
                            parList[0].Amendment_Type__c == 'Change of Name and/or Residence Address') &&
                           (parList[0].Regulatory_Authorization_Type__r.Name == 'Registered Nurse' || 
                            parList[0].Regulatory_Authorization_Type__r.Name == 'Licensed Practical Nurse'));
                String proofOfWorkPermit = String.isNotBlank(parList[0].Proof_of_work_permit_in_United_States__c) ? 
                    parList[0].Proof_of_work_permit_in_United_States__c : 
                parList[0].BusinessAccountName.Proof_of_work_permit_in_United_States__c;
                String proofOfCitizenship = String.isNotBlank(parList[0].Proof_of_Citizenship__c) ? 
                    parList[0].Proof_of_Citizenship__c : parList[0].BusinessAccountName.Proof_of_Citizenship__c;
               
                String uscisNumber = String.isNotBlank(parList[0].USCIS_Number__c) ? 
                    parList[0].USCIS_Number__c : parList[0].BusinessAccountName.USCIS_Number__c;
               
                String naturalizationNumber = String.isNotBlank(parList[0].Naturalization_Number__c) ? 
                    parList[0].Naturalization_Number__c : parList[0].BusinessAccountName.Naturalization_Number__c;
               
                String sevisId = String.isNotBlank(parList[0].SEVIS_ID__c) ? 
                    parList[0].SEVIS_ID__c : parList[0].BusinessAccountName.SEVIS_ID__c;
            
                String usResidentCardNumber = String.isNotBlank(parList[0].US_Permanent_Resident_Card_Number__c) ? 
                    parList[0].US_Permanent_Resident_Card_Number__c : 
                parList[0].BusinessAccountName.US_Permanent_Resident_Card_Number__c;
               
                String passportNumber = String.isNotBlank(parList[0].Passport_Number__c) ? 
                    parList[0].Passport_Number__c : parList[0].BusinessAccountName.Passport_Number__c;
                
                String visaNumber = String.isNotBlank(parList[0].VISA_Number__c) ? 
                    parList[0].VISA_Number__c : parList[0].BusinessAccountName.VISA_Number__c;
               
                String hbVisaNumber = String.isNotBlank(parList[0].H1B_Visa_Number__c) ? 
                    parList[0].H1B_Visa_Number__c : parList[0].BusinessAccountName.H1B_Visa_Number__c;
                
                outMap.put('ProofOfCitizenshipIfForeignRO', proofOfWorkPermit);
                outMap.put('ProofOfCitizenshipIfForeignRO', proofOfWorkPermit);
                outMap.put('ProofOfCitizenshipIfUSRO', proofOfCitizenship);
               
                outMap.put('CitizinshipStatus', parList[0].BusinessAccountName.Citizenship__c);
                outMap.put('ProofOfCitizenshipIfForeign', proofOfWorkPermit);
                outMap.put('ProofOfCitizenshipIfUS', proofOfCitizenship);
                
                outMap.put('ProofOfCitizenshipIfForeignRONew', parList[0].BusinessAccountName.Proof_of_work_permit_in_United_States__c);
                outMap.put('ProofOfCitizenshipIfUSRONew', parList[0].BusinessAccountName.Proof_of_Citizenship__c);
                String citizenShip = String.isNotBlank(parList[0].Citizenship__c) ? 
                    parList[0].Citizenship__c : parList[0].BusinessAccountName.Citizenship__c;
                outMap.put('CitizinshipStatusRONew', citizenShip);
                outMap.put('CitizinshipStatus', citizenShip);
                outMap.put('CitizinshipStatusRO', citizenShip);
               
                if (NATURALIZATION.equalsIgnoreCase(proofOfCitizenship)) {
                    outMap.put('UCSICNumberRO', uscisNumber);
                    outMap.put('NaturalizationNumberRO', naturalizationNumber);
                   
                    outMap.put('UCSICNumber', uscisNumber);
                    outMap.put('NaturalizationNumber', naturalizationNumber);
                    
                    outMap.put('UCSICNumberRONew', uscisNumber);
                    outMap.put('NaturalizationNumberRONew', naturalizationNumber);
                   
                } 
                fields = 'Id, Status, SavedApplicationRefId';
                whereClause = 'SavedApplicationRefId = \'' + String.escapeSingleQuotes(parId) + '\'';
                List<IndividualApplication> iaList = LPI_IndividualApplicationDAO.getIndividualApplicationByDymanicQuery(
                    fields, whereClause, null, null, null);
                if (!iaList.isEmpty()) {
                    outMap.put('IAStatus', iaList[0].Status);
                }
                fetchAddresses(parId, parList, inputMap, outMap);
                Boolean isAdditionalInfoOS = inputMap.containsKey('isPersonInfoWithAddInfo') ? 
                    Boolean.valueOf(inputMap.get('isPersonInfoWithAddInfo')) : false;
                if (isAdditionalInfoOS) {
                    fetchAppContentRecordAndIdentificationCardDetails(inputMap, outMap);
                }
               
                outMap.put('hideEditButtonForSchool', false);
                List<User> usrList = LPI_UserDao.getCurrentUserRecord();
                if (!usrList.isEmpty()) {
                    if (usrList[0].AccountId != parList[0].BusinessAccountNameId) {
                        outMap.put('hideEditButtonForSchool', true);
                    }
                }
               
                if (MAILING_ADDRESS_SAME_AS_RESIDENCE_BOARD_SET.contains(parList[0].Board_Name__c)) {
                    outMap.put('MailingAddressSameAsCurrentAddress', true);
                }
               
            }
        } 
        catch (Exception e) {
            LPI_ExceptionManager.logException(CLASS_NAME, 'fetchPersonalInfo', e);
            throw new LPI_Exception('Facing Issue in Fetching Personal Details', e);
        }
    }
    
    private static void fetchAddresses(
        Id parId,
        List<PreliminaryApplicationRef> parList,
        Map<String, Object> inputMap,
        Map<String, Object> outMap
    ) {
       
        try {
            String blId = (String) inputMap.get('blId');
            Set<Id> locationIdSet = new Set<Id>();
            Set<Id> newlocationIdSet = new Set<Id>();
            List<Schema.location> newlyInsertedLoc = new List<Schema.location>();
            List<Schema.Address> newlyInsertedAdd = new List<Schema.Address>();
            String fields, primaryContactAddress, licenseAddress, publicDisplayedAddress;
            boolean consentOfPrimaryContactAddress;
            String whereClause;
            Map<Id, Id> locationIds = new Map<Id, Id>();
            Boolean isSupervisorUser = parList[0].Is_Supervisor_User__c;
            String approvalSupervisorIds = parList[0].Approval_Supervisors_AcrIds__c;
            primaryContactAddress = parList[0].Primary_Contact_Address__c;
            licenseAddress = parList[0].License_Address__c;
            publicDisplayedAddress = parList[0].Publicly_Displayed_Address__c;
            consentOfPrimaryContactAddress = parList[0].Consent_for_Primary_Contact_Address__c;
            boolean createDuplicate = false;
            if (parList[0].Type__c != 'New') {
                createDuplicate = true;
                
                if (String.isNotBlank(blId)) {
                    fields = 'Id, AuthorizationId, PlaceId,TYPEOF Place WHEN Location Then LocationType,Status__c END';
                    whereClause =
                        'AuthorizationId = \'' +
                        String.escapeSingleQuotes(blId) +
                        '\' AND Place.Type =\'Location\'';
                    
                    for (
                        AuthApplicationPlace aap : new LPI_AuthApplicationPlaceDAO.LPI_AuthApplicationPlaceWithoutSharingDAO()
                        .getAuthAppPlaceByDymQueryWithoutSecurity(fields, whereClause, null, null, null)
                    ) {
                        if (aap.Place instanceof Schema.Location) {
                            System.debug('AAAAPPPP>>'+aap);
                            Schema.Location loc = aap.Place;
                            if (ALL_ADDRESS_LIST.contains(loc.LocationType) && loc.Status__c == OPEN) {
                                locationIdSet.add(aap.PlaceId);
                            }
                        }
                    }
                    System.debug('locationIdSet>>'+locationIdSet);
                    
                    List<BusinessLicense> blList = new LPI_BusinessLicenseDAO.LPI_BusinessLicenseWithoutSharingDAO()
                        .getBusinessLicenseByDymanicQuery(
                            'Id,Primary_Contact_Address__c,License_Address__c,Publicly_Displayed_Address__c,Consent_for_Primary_Contact_Address__c',
                            'Id = \'' + blId + '\'',
                            null,
                            null,
                            null
                        );
                    if (blList.size() > 0) {
                        primaryContactAddress = blList[0].Primary_Contact_Address__c;
                        licenseAddress = blList[0].License_Address__c;
                        publicDisplayedAddress = blList[0].Publicly_Displayed_Address__c;
                        consentOfPrimaryContactAddress = blList[0].Consent_for_Primary_Contact_Address__c;
                    }
                } else {
                   
                    if (String.isNotBlank(parList[0].Old_Application_Id__c)) {
                        Id applicationId = (Id) parList[0].Old_Application_Id__c;
                        fields = 'Id, RgltyAuthApplicationId, PlaceId,TYPEOF Place WHEN Location Then Id,LocationType,Status__c END';
                        whereClause =
                            'RgltyAuthApplicationId = \'' +
                            String.escapeSingleQuotes(parList[0].Old_Application_Id__c) +
                            '\' AND Place.Type =\'Location\'';
                        for (
                            AuthApplicationPlace aap : new LPI_AuthApplicationPlaceDAO.LPI_AuthApplicationPlaceWithoutSharingDAO()
                            .getAuthAppPlaceByDymQueryWithoutSecurity(fields, whereClause, null, null, null)
                        ) {
                            if (aap.Place instanceof Schema.Location) {
                                Schema.Location loc = aap.Place;
                                
                                if (ALL_ADDRESS_LIST.contains(loc.LocationType)) {
                                    locationIdSet.add(aap.PlaceId);
                                }
                            }
                        }
                      
                        if (applicationId.getSObjectType() == Schema.BusinessLicenseApplication.getSObjectType()) {
                            List<BusinessLicenseApplication> blaList = LPI_BusinessLicenseApplicationDAO.getBusinessLicenseApplicationByDymanicQuery(
                                'Consent_for_Primary_Contact_Address__c,License_Address__c,Primary_Contact_Address__c,Publicly_Displayed_Address__c',
                                'Id =\'' + applicationId + '\'',
                                null,
                                null,
                                null
                            );
                            primaryContactAddress = blaList[0].Primary_Contact_Address__c;
                            licenseAddress = blaList[0].License_Address__c;
                            publicDisplayedAddress = blaList[0].Publicly_Displayed_Address__c;
                            consentOfPrimaryContactAddress = blaList[0].Consent_for_Primary_Contact_Address__c;
                            outMap.put(
                                'ConsentCheckboxForMainPIStep',
                                blaList[0].Consent_for_Primary_Contact_Address__c
                            );
                        } else if (applicationId.getSObjectType() == Schema.IndividualApplication.getSObjectType()) {
                            List<IndividualApplication> iaList = LPI_IndividualApplicationDAO.getIndividualApplicationByDymanicQuery(
                                'Consent_for_Primary_Contact_Address__c,License_Address__c,Primary_Contact_Address__c,Publicly_Displayed_Address__c',
                                'Id =\'' + applicationId + '\'',
                                null,
                                null,
                                null
                            );
                            primaryContactAddress = iaList[0].Primary_Contact_Address__c;
                            licenseAddress = iaList[0].License_Address__c;
                            publicDisplayedAddress = iaList[0].Publicly_Displayed_Address__c;
                            consentOfPrimaryContactAddress = iaList[0].Consent_for_Primary_Contact_Address__c;
                            outMap.put(
                                'ConsentCheckboxForMainPIStep',
                                iaList[0].Consent_for_Primary_Contact_Address__c
                            );
                        }
                    }
                }
                PreliminaryApplicationRef par = new PreliminaryApplicationRef(Id = parId);
                par.Primary_Contact_Address__c = primaryContactAddress;
                par.License_Address__c = licenseAddress;
                par.Publicly_Displayed_Address__c = publicDisplayedAddress;
                if (consentOfPrimaryContactAddress != null) {
                    par.Consent_for_Primary_Contact_Address__c = consentOfPrimaryContactAddress;
                }
                if (!inputMap.containsKey('byPassForPDF')) {
                    LPI_DML.doUpdate(par);
                }
            }
           
            fields = 'ID, Location__c,Location__r.LocationType';
            whereClause = 'Preliminary_Application_Reference__c = \'' + String.escapeSingleQuotes(parId) + '\'';
            List<Temp_AuthApplicationPlace__c> temp_AAPList;
            if (isSupervisorUser && approvalSupervisorIds != null) {
                temp_AAPList = new LPI_TempAuthApplicationPlaceDAO.LPI_TempAuthApplicationPlaceWithoutSharingDAO()
                    .getTempAuthApplicationPlaceByDymanicQuery(fields, whereClause, null, null, null);
            } else {
                temp_AAPList = LPI_TempAuthApplicationPlaceDAO.getTempAuthApplicationPlaceByDymanicQuery(
                    fields,
                    whereClause,
                    null,
                    null,
                    null
                );
            }
            Boolean isMigratedData = (Boolean) outMap.get('IsMigratedData');
            if (isMigratedData == true) {
                if (!temp_AAPList.isEmpty()) {
                    for (Temp_AuthApplicationPlace__c temp_AAP : temp_AAPList) {
                        if (
                            parList[0].Type__c != 'New' && ALL_ADDRESS_LIST.contains(temp_AAP.Location__r.LocationType)
                        ) {
                            createDuplicate = false;
                        }
                    }
                }
               
                if (createDuplicate && !locationIdSet.isEmpty()) {
                    Map<String, Id> keyToNewLocId = new Map<String, Id>();
                    List<Schema.location> insertedLoc = new List<Schema.location>();
                    for (
                        Schema.location loc : new LPI_LocationDAO.LPI_LocationWithoutSharingDAO()
                        .getLocationByDymanicQuery(
                            'Id,locationType,Name,Consent_For__c',
                            'Id IN' + LPI_ServiceUtility.getStringValuesBySet(locationIdSet),
                            null,
                            null,
                            null
                        )
                    ) {
                        Schema.location newloc = new Schema.location();
                        newloc.Name = loc.Name;
                        newloc.LocationType = loc.locationType;
                        newloc.Status__c = 'Closed';
                        newloc.OpenDate = System.today();
                        newloc.Consent_For__c = loc.Consent_For__c;
                        newlyInsertedLoc.add(newloc);
                    }
                    if (!newlyInsertedLoc.isEmpty()) {
                        insertedLoc = LPI_WithoutSharingUtility.insertSObjectList(newlyInsertedLoc);
                        for (Schema.location loc : insertedLoc) {
                            keyToNewLocId.put(loc.Name + '_' + loc.locationType + '_' + loc.Consent_For__c, loc.Id);
                            newlocationIdSet.add(loc.Id);
                        }
                    }
                    for (
                        Schema.Address add : new LPI_AddressDAO.LPI_AddressDAOWithoutSharing()
                        .getAddressByDymanicQuery(
                            'Id,locationType,parent.locationType,parent.Name,Street,City,State,Country,County__c,PostalCode,Business_State__c,parent.Consent_For__c',
                            'ParentId IN' + LPI_ServiceUtility.getStringValuesBySet(locationIdSet),
                            null,
                            null,
                            null
                        )
                    ) {
                        Schema.Address newAdd = new Schema.Address();
                        newAdd.ParentId = keyToNewLocId.get(
                            add.parent.Name + '_' + add.parent.locationType + '_' + add.parent.Consent_For__c
                        );
                        newAdd.Street = add.Street;
                        newAdd.City = add.City;
                        newAdd.State = add.State;
                        newAdd.Business_State__c = add.Business_State__c;
                        newAdd.PostalCode = add.PostalCode;
                        newAdd.Country = add.Country;
                        newAdd.LocationType = add.locationType;
                        newAdd.County__c = add.County__c;
                        newlyInsertedAdd.add(newAdd);
                    }
                    List<Schema.Address> insertedAdd = new List<Schema.Address>();
                    if (!newlyInsertedAdd.isEmpty()) {
                        insertedAdd = LPI_WithoutSharingUtility.insertSObjectList(newlyInsertedAdd);
                    }
                    
                    List<Temp_AuthApplicationPlace__c> insertAapList = new List<Temp_AuthApplicationPlace__c>();
                    for (Id locId : newlocationIdSet) {
                        Temp_AuthApplicationPlace__c aap = new Temp_AuthApplicationPlace__c();
                        aap.Preliminary_Application_Reference__c = parId;
                        aap.Location__c = locId;
                        insertAapList.add(aap);
                    }
                    
                   
                    if (!insertAapList.isEmpty()) {
                        LPI_WithoutSharingUtility.insertSObjectList(insertAapList);
                    }
                }
            } else {
                for (Temp_AuthApplicationPlace__c temp_AAP : temp_AAPList) {
                    if (
                        parList[0].Type__c != 'New' &&
                        ALL_ADDRESS_LIST.contains(temp_AAP.Location__r.LocationType) &&
                        locationIdSet.contains(temp_AAP.Location__c)
                    ) {
                        createDuplicate = false;
                        break;
                    }
                }
                
                if (createDuplicate && !locationIdSet.isEmpty()) {
                    List<Temp_AuthApplicationPlace__c> insertAapList = new List<Temp_AuthApplicationPlace__c>();
                    for (Id locId : locationIdSet) {
                        Temp_AuthApplicationPlace__c aap = new Temp_AuthApplicationPlace__c();
                        aap.Preliminary_Application_Reference__c = parId;
                        aap.Location__c = locId;
                        insertAapList.add(aap);
                    }
                   
                    if (!insertAapList.isEmpty()) {
                        LPI_WithoutSharingUtility.insertSObjectList(insertAapList);
                    }
                }
            }
            
           
            for (
                Temp_AuthApplicationPlace__c tempAap : new LPI_TempAuthApplicationPlaceDAO.LPI_TempAuthApplicationPlaceWithoutSharingDAO()
                .getTempAuthApplicationPlaceByDymanicQuery(
                    'Id,Location__c',
                    'Preliminary_Application_Reference__c = \'' + String.escapeSingleQuotes(parId) + '\'',
                    null,
                    null,
                    null
                )
            ) {
                locationIds.put(tempAap.Location__c, tempAap.Id);
            }
            
           
            if (!locationIds.keySet().isEmpty()) {
                List<Schema.Address> addresses;
                fields = 'ID,ParentId,Parent.LocationType,Parent.Name,StateCode,Business_State__c,CountryCode,City,County__c,PostalCode,State,Street,Country,Parent.Consent_For__c';
                
                whereClause = 'ParentId IN ' + LPI_ServiceUtility.getStringValuesBySet(locationIds.keySet());
                if (isSupervisorUser && approvalSupervisorIds != null) {
                    addresses = new LPI_AddressDAO.LPI_AddressDAOWithoutSharing()
                        .getAddressByDymanicQuery(fields, whereClause, null, null, null);
                } else {
                    addresses = LPI_AddressDAO.getAddressByDymanicQuery(fields, whereClause, null, null, null);
                }
                
               
                if (string.isNotBlank(licenseAddress)) {
                    outMap.put('AddressTypeLA', licenseAddress);
                }
                if (string.isNotBlank(primaryContactAddress)) {
                    outMap.put('AddressTypePCA', primaryContactAddress);
                }
                if (string.isNotBlank(publicDisplayedAddress)) {
                    outMap.put('AddressTypePDA', publicDisplayedAddress);
                }
                outMap.put('ConsentCheckboxForMainPIStep', consentOfPrimaryContactAddress);
                if(addresses.size()>0){
                    for (Schema.Address address : addresses) {
                        if (address.Parent.LocationType == RESIDENCE) {
                            outMap.put('residence_Temp_AAP_Id', locationIds.get(address.ParentId));
                            outMap.put('residenceLocationId', address.ParentId);
                            outMap.put('residenceAddressId', address.Id);
                            outMap.put('StreetAddress', address.Street);
                            outMap.put('StreetAddressRO', address.Street);
                            outMap.put('ResCountry', address.CountryCode);
                            outMap.put('ResCountryRO', address.CountryCode);
                            outMap.put('ReviewCountry', address.Country);
                            if (address.CountryCode == 'US') {
                                outMap.put('State', address.StateCode);
                                outMap.put('statePicklistEdit', address.StateCode);
                                outMap.put('statePicklistEditRO', address.StateCode);
                                outMap.put('StateTextReadOnlyForUs', address.StateCode);
                                if (address.StateCode == WASHINGTON_STATE_CODE) {
                                    outMap.put('ReviewState', WASHINGTON_STATE_VALUE);
                                } 
                                else {
                                    outMap.put('ReviewState', address.State);
                                }
                            } else {
                                outMap.put('StateTextReadOnly', address.Business_State__c);
                                outMap.put('StateTextEdit', address.Business_State__c);
                                outMap.put('StateTextEditRO', address.Business_State__c);
                                outMap.put('StateTextReadOnlyForNonUs', address.Business_State__c);
                            }
                            outMap.put('City', address.City);
                            outMap.put('CityRO', address.City);
                            outMap.put('ZipCode', address.PostalCode);
                            outMap.put('ZipCodeRO', address.PostalCode);
                            outMap.put('County', address.County__c);
                            outMap.put('CountyRO', address.County__c);
                            
                        } else if (address.Parent.LocationType == MAILING) {
                            outMap.put('mailing_Temp_AAP_Id', locationIds.get(address.ParentId));
                            outMap.put('MailinglocationId', address.ParentId);
                            outMap.put('MailingaddressId', address.Id);
                            outMap.put('MailingCountry', address.CountryCode);
                            outMap.put('ReviewMailingCountry', address.Country);
                            
                            if (address.CountryCode == 'US') {
                                outMap.put('MailingState', address.StateCode);
                                outMap.put('MailingStateRO', address.StateCode);
                            } else {
                                outMap.put('MailingStateText', address.Business_State__c);
                                outMap.put('MailingStateTextRO', address.Business_State__c);
                            }
                            outMap.put('MailingCity', address.City);
                            outMap.put('MailingCityRO', address.City);
                            outMap.put('MailingStreet', address.Street);
                            outMap.put('MailingStreetRO', address.Street);
                            outMap.put('MailingZipCode', address.PostalCode);
                            outMap.put('MailingZipCodeRO', address.PostalCode);
                            outMap.put('MailingCountryRO', address.CountryCode);
                            outMap.put('MailingCounty', address.County__c);
                            outMap.put('MailingCountyRO', address.County__c);
                        }
                        if (
                            (address.Parent.LocationType == 'Business Address' ||
                             address.Parent.LocationType == 'Branch' ||
                             address.Parent.LocationType == 'Secondary Business Address' ||
                             address.Parent.LocationType == 'Local Address' ||
                             address.Parent.LocationType == 'Other')
                        ) {
                            if (address.Parent.LocationType == primaryContactAddress) {
                                outMap.put('PCA_AAP_Id', locationIds.get(address.ParentId));
                                outMap.put('pcaLocationId', address.ParentId);
                                outMap.put('pcaAddressId', address.Id);
                                outMap.put('PCACountry', address.CountryCode);
                                outMap.put('ReviewPCACountry', address.Country);
                                
                                if (address.CountryCode == 'US') {
                                    outMap.put('PCAState', address.StateCode);
                                    outMap.put('PCAStateRO', address.StateCode);
                                } else {
                                    outMap.put('PCAStateText', address.Business_State__c);
                                    outMap.put('PCAStateTextRO', address.Business_State__c);
                                }
                                outMap.put('PCACity', address.City);
                                outMap.put('PCACityRO', address.City);
                                outMap.put('PCAStreetAddress', address.Street);
                                outMap.put('PCAStreetAddressRO', address.Street);
                                outMap.put('PCAZipCode', address.PostalCode);
                                outMap.put('PCAZipCodeRO', address.PostalCode);
                                outMap.put('PCACountryRO', address.CountryCode);
                                outMap.put('PCACounty', address.County__c);
                                outMap.put('PCACountyRO', address.County__c);
                            } else if (address.Parent.LocationType == licenseAddress) {
                                outMap.put('LA_AAP_Id', locationIds.get(address.ParentId));
                                outMap.put('laLocationId', address.ParentId);
                                outMap.put('laAddressId', address.Id);
                                outMap.put('LACountry', address.CountryCode);
                                outMap.put('ReviewLaCountry', address.Country);
                                
                                if (address.CountryCode == 'US') {
                                    outMap.put('LAState', address.StateCode);
                                    outMap.put('LAStateRO', address.StateCode);
                                } else {
                                    outMap.put('LAStateText', address.Business_State__c);
                                    outMap.put('LAStateTextRO', address.Business_State__c);
                                }
                                outMap.put('LACity', address.City);
                                outMap.put('LACityRO', address.City);
                                outMap.put('LAStreetAddress', address.Street);
                                outMap.put('LAStreetAddressRO', address.Street);
                                outMap.put('LAZipCode', address.PostalCode);
                                outMap.put('LAZipCodeRO', address.PostalCode);
                                outMap.put('LACountryRO', address.CountryCode);
                                outMap.put('LACounty', address.County__c);
                                outMap.put('LACountyRO', address.County__c);
                            } else if (address.Parent.LocationType == publicDisplayedAddress) {
                                outMap.put('PDA_AAP_Id', locationIds.get(address.ParentId));
                                outMap.put('pdaLocationId', address.ParentId);
                                outMap.put('pdaAddressId', address.Id);
                                outMap.put('PDACountry', address.CountryCode);
                                outMap.put('ReviewLaCountry', address.Country);
                                
                                if (address.CountryCode == 'US') {
                                    outMap.put('PDAState', address.StateCode);
                                    outMap.put('PDAStateRO', address.StateCode);
                                } else {
                                    outMap.put('PDAStateText', address.Business_State__c);
                                    outMap.put('PDAStateTextRO', address.Business_State__c);
                                }
                                outMap.put('PDACity', address.City);
                                outMap.put('PDACityRO', address.City);
                                outMap.put('PDAStreetAddress', address.Street);
                                outMap.put('PDAStreetAddressRO', address.Street);
                                outMap.put('PDAZipCode', address.PostalCode);
                                outMap.put('PDAZipCodeRO', address.PostalCode);
                                outMap.put('PDACountryRO', address.CountryCode);
                                outMap.put('PDACounty', address.County__c);
                                outMap.put('PDACountyRO', address.County__c);
                            }
                        }
                    }
                }else{
                    populateDefaultAddress(outMap);
                }
            }else{
                populateDefaultAddress(outMap);
            }
            System.debug('Output Map>>>>'+outMap);
        } catch (Exception e) {
            LPI_ExceptionManager.logException(CLASS_NAME, 'fetchAddresses', e);
            throw new LPI_Exception('Facing Issue in Fetching Address Details', e);
        }
    }
    
    private static Map<String, Object> populateDefaultAddress( Map<String, Object> outMap){
       
        String defaultStreet = '1234 James St';
        String defaultCity = 'Springfield';
        String defaultStateCode = 'MO';
        String defaultState = 'Missouri';
        String defaultPostalCode = '65804';
        String defaultCountryCode = 'US';
        String defaultCountry = 'United States';
        String defaultCounty = 'Greene County';
        
       
        outMap.put('residence_Temp_AAP_Id', 'default_residence_Temp_AAP_Id');
        outMap.put('residenceLocationId', 'default_residenceLocationId');
        outMap.put('residenceAddressId', 'default_residenceAddressId');
        outMap.put('StreetAddress', defaultStreet);
        outMap.put('StreetAddressRO', defaultStreet);
        outMap.put('ResCountry', defaultCountryCode);
        outMap.put('ResCountryRO', defaultCountryCode);
        outMap.put('ReviewCountry', defaultCountry);
        outMap.put('State', defaultStateCode);
        outMap.put('statePicklistEdit', defaultStateCode);
        outMap.put('statePicklistEditRO', defaultStateCode);
        outMap.put('StateTextReadOnlyForUs', defaultStateCode);
        outMap.put('ReviewState', defaultState);
        outMap.put('StateTextReadOnly', defaultState);
        outMap.put('StateTextEdit', defaultState);
        outMap.put('StateTextEditRO', defaultState);
        outMap.put('StateTextReadOnlyForNonUs', defaultState);
        outMap.put('City', defaultCity);
        outMap.put('CityRO', defaultCity);
        outMap.put('ZipCode', defaultPostalCode);
        outMap.put('ZipCodeRO', defaultPostalCode);
        outMap.put('County', defaultCounty);
        outMap.put('CountyRO', defaultCounty);
        outMap.put('mailing_Temp_AAP_Id', 'default_mailing_Temp_AAP_Id');
        outMap.put('MailinglocationId', 'default_MailinglocationId');
        outMap.put('MailingaddressId', 'default_MailingaddressId');
        outMap.put('MailingCountry', defaultCountryCode);
        outMap.put('ReviewMailingCountry', defaultCountry);
        outMap.put('MailingState', defaultStateCode);
        outMap.put('MailingStateRO', defaultStateCode);
        outMap.put('MailingStateText', defaultState);
        outMap.put('MailingStateTextRO', defaultState);
        outMap.put('MailingCity', defaultCity);
        outMap.put('MailingCityRO', defaultCity);
        outMap.put('MailingStreet', defaultStreet);
        outMap.put('MailingStreetRO', defaultStreet);
        outMap.put('MailingZipCode', defaultPostalCode);
        outMap.put('MailingZipCodeRO', defaultPostalCode);
        outMap.put('MailingCountryRO', defaultCountryCode);
        outMap.put('MailingCounty', defaultCounty);
        outMap.put('MailingCountyRO', defaultCounty);
        outMap.put('PCA_AAP_Id', 'default_PCA_AAP_Id');
        outMap.put('pcaLocationId', 'default_pcaLocationId');
        outMap.put('pcaAddressId', 'default_pcaAddressId');
        outMap.put('PCACountry', defaultCountryCode);
        outMap.put('ReviewPCACountry', defaultCountry);
        outMap.put('PCAState', defaultStateCode);
        outMap.put('PCAStateRO', defaultStateCode);
        outMap.put('PCAStateText', defaultState);
        outMap.put('PCAStateTextRO', defaultState);
        outMap.put('PCACity', defaultCity);
        outMap.put('PCACityRO', defaultCity);
        outMap.put('PCAStreetAddress', defaultStreet);
        outMap.put('PCAStreetAddressRO', defaultStreet);
        outMap.put('PCAZipCode', defaultPostalCode);
        outMap.put('PCAZipCodeRO', defaultPostalCode);
        outMap.put('PCACountryRO', defaultCountryCode);
        outMap.put('PCACounty', defaultCounty);
        outMap.put('PCACountyRO', defaultCounty);
        outMap.put('LA_AAP_Id', 'default_LA_AAP_Id');
        outMap.put('laLocationId', 'default_laLocationId');
        outMap.put('laAddressId', 'default_laAddressId');
        outMap.put('LACountry', defaultCountryCode);
        outMap.put('ReviewLaCountry', defaultCountry);
        outMap.put('LAState', defaultStateCode);
        outMap.put('LAStateRO', defaultStateCode);
        outMap.put('LAStateText', defaultState);
        outMap.put('LAStateTextRO', defaultState);
        outMap.put('LACity', defaultCity);
        outMap.put('LACityRO', defaultCity);
        outMap.put('LAStreetAddress', defaultStreet);
        outMap.put('LAStreetAddressRO', defaultStreet);
        outMap.put('LAZipCode', defaultPostalCode);
        outMap.put('LAZipCodeRO', defaultPostalCode);
        outMap.put('LACountryRO', defaultCountryCode);
        outMap.put('LACounty', defaultCounty);
        outMap.put('LACountyRO', defaultCounty);
        outMap.put('PDA_AAP_Id', 'default_PDA_AAP_Id');
        outMap.put('pdaLocationId', 'default_pdaLocationId');
        outMap.put('pdaAddressId', 'default_pdaAddressId');
        outMap.put('PDACountry', defaultCountryCode);
        outMap.put('ReviewLaCountry', defaultCountry);
        outMap.put('PDAState', defaultStateCode);
        outMap.put('PDAStateRO', defaultStateCode);
        outMap.put('PDAStateText', defaultState);
        outMap.put('PDAStateTextRO', defaultState);
        outMap.put('PDACity', defaultCity);
        outMap.put('PDACityRO', defaultCity);
        outMap.put('PDAStreetAddress', defaultStreet);
        outMap.put('PDAStreetAddressRO', defaultStreet);
        outMap.put('PDAZipCode', defaultPostalCode);
        outMap.put('PDAZipCodeRO', defaultPostalCode);
        outMap.put('PDACountryRO', defaultCountryCode);
        outMap.put('PDACounty', defaultCounty);
        outMap.put('PDACountyRO', defaultCounty);  
        return outMap;
    }

    /**
* @description This method saves personal information by updating or creating records based on the provided input map, including handling address records and sending notifications if the status is 'Converted'. It also processes additional information if specified, logging any exceptions encountered.
* @author MTX Group Inc | 06-13-2024 
* @param inputMap 
* @param outMap 
**/

    private static void savePersonalInfo(Map<String, Object> inputMap, Map<String, Object> outMap) {
        try {
            Id parId = (Id) inputMap.get('parid');
            String status = (String) inputMap.get('status');
            String boardName = (String) inputMap.get('BoardName');
            String accountId = (String) inputMap.get('accountId');
            Boolean showEdit = (Boolean) inputMap.get('showEdit');
            String parType = (String) inputMap.get('type');
            String AmendmentType = (String) inputMap.get('AmendmentType');
            Boolean isMigratedData = (Boolean) inputMap.get('IsMigratedData');
            if (status == 'Converted') {
                sendPortalNotification(inputMap);
            }
            
            updatePersonalInfoData(parId, accountId, inputMap, outMap);
            if (
                parType == 'New' ||
                isMigratedData == true ||
                ((SET_OF_IDENTIFICATION_CARDS.contains(AmendmentType))) ||
                parType == 'Pre-licensure Petition'
            ) {
                saveAddresses(parId, accountId, inputMap, outMap);
            }
            Boolean isAdditionalInfoOS = inputMap.containsKey('isPersonInfoWithAddInfo')
                ? Boolean.valueOf(inputMap.get('isPersonInfoWithAddInfo'))
                : false;
            if (isAdditionalInfoOS) {
                updateAppContentRecord(inputMap, outMap, parId);
            }
        } catch (exception ex) {
            LPI_ExceptionManager.logException(CLASS_NAME, 'savePersonalInfo', ex);
        }
    }
    
    private static void sendPortalNotification(Map<String, Object> inputMap) {
        try {
            Id parId = (Id) inputMap.get('parid');
            Map<String, object> personalInformation = (Map<String, object>) inputMap.get('PersonalInformation');
            Boolean isResidenceChanged = (Boolean) personalInformation.get('IsResidanceChanged');
            Boolean isMailingChanged = (Boolean) personalInformation.get('isMailingChanged');
            
            Map<String, Portal_Notification_Message__mdt> portalNotificationMessageMap = new Map<String, Portal_Notification_Message__mdt>();
            Map<String, String> replaceTextMap = new Map<String, String>();
            List<Notification__c> portalNotificationToInsert = new List<Notification__c>();
           
            if ((isMailingChanged || isResidenceChanged) && parId != null) {
                List<IndividualApplication> iaApplication = LPI_IndividualApplicationDAO.getILABySavedAppRefId(
                    new Set<Id>{ parId }
                );
               
                for (
                    Portal_Notification_Message__mdt notiRec : LPI_CustomMetadataTypeDAO.getAllPortalNotificationByDeveloperNames(
                        new Set<String>{ 'Bell_Notification_If_Address_Changed' }
                    )
                ) {
                    portalNotificationMessageMap.put(notiRec.DeveloperName, notiRec);
                }
                
                if (
                    !iaApplication.isEmpty() &&
                    String.isBlank(iaApplication[0].LicensePermitNameId) &&
                    (!APPLICABLE_IA_STATUS.contains(iaApplication[0].Status))
                ) {
                   
                    replaceTextMap.put('[Application_Name]', iaApplication[0].Name);
                    if (isMailingChanged) {
                        replaceTextMap.put('[Address_Type]', 'Mailing');
                    } else if (isResidenceChanged) {
                        replaceTextMap.put('[Address_Type]', 'Residence');
                    }
                    
                    if (isResidenceChanged && isMailingChanged) {
                        replaceTextMap.put('[Address_Type]', 'Residence and Mailing');
                    }
                   
                    portalNotificationToInsert.add(
                        LPI_ServiceUtility.createBellNotificationRecord(
                            portalNotificationMessageMap.get('Bell_Notification_If_Address_Changed'),
                            true,
                            replaceTextMap,
                            iaApplication[0].OwnerId,
                            iaApplication[0].Id
                        )
                    );
                }
            }
            if (!portalNotificationToInsert.isEmpty()) {
                LPI_WithoutSharingUtility.insertSObjectList(portalNotificationToInsert);
            }
        } catch (exception ex) {
            LPI_ExceptionManager.logException(CLASS_NAME, 'sendPortalNotification', ex);
        }
    }
    
    private static void updatePersonalInfoData(
        Id parId,
        String accountId,
        Map<String, Object> inputMap,
        Map<String, Object> outMap
    ) {
        try {
            String boardName = (String) inputMap.get('BoardName');
            String parType = (String) inputMap.get('parType');
            String regAuthTypeName = (String) inputMap.get('regAuthTypeName');
            String accMiddleNameRo = (String) inputMap.get('AccMiddleNameRO');
            String accMaidenNameRO = (String) inputMap.get('AccMaidenNameRO');
            String accAnotherNameRO = (String) inputMap.get('AccAnotherNameRO');
            String accOtherNameRO = (String) inputMap.get('AccOtherNameRO');
            boolean ShowTextBoxReadOnlyInRenewal = (boolean) inputMap.get('ShowTextBoxReadOnlyInRenewal');
            Map<String, object> personalInformation = (Map<String, object>) inputMap.get('PersonalInformation');
            Boolean formulaToCheckRAandMA = (Boolean) personalInformation.get('FormulaToCheckRAandMA');
            Map<String, object> accountInfo = (Map<String, object>) personalInformation.get('NameEditBlock');
            
            PreliminaryApplicationRef par = new PreliminaryApplicationRef();
            par.Id = parId;
            String conMiddleName;
            String maidenName;
            String firstName;
            String lastName;
            String suffix;
            Boolean mailingAddressSameAsCurrentAddress;
            Map<String, object> residanceEditBlockRO = (Map<String, object>) personalInformation.get(
                'ReadBlockDetails'
            );
            outMap.put('isPersonInfoSSNDuplicate', false);
            if (accountInfo == null) {
                Map<String, Object> NameReadBlock = (Map<String, Object>) personalInformation.get('NameReadBlock');
                if (NameReadBlock != null) {
                    mailingAddressSameAsCurrentAddress = (Boolean) residanceEditBlockRO.get(
                        'MailingAddressSameAsCurrentAddressRO'
                    );
                    conMiddleName = (String) NameReadBlock.get('ConMiddleNameRO');
                    maidenName = (String) NameReadBlock.get('MaidenNameRO');
                    firstName = (String) NameReadBlock.get('FirstNameRO');
                    lastName = (String) NameReadBlock.get('LastNameRO');
                    suffix = (String) NameReadBlock.get('SuffixRO');
                }
                if (!((Boolean) inputMap.get('isNewApplication') || (Boolean) inputMap.get('isAncilary'))) {
                    Account acc = new Account();
                    acc.Id = accountId;
                    if (residanceEditBlockRO != null) {
                        acc.Citizenship__c = (String) residanceEditBlockRO.get('CitizinshipStatusRO');
                        par.Citizenship__c = (String) residanceEditBlockRO.get('CitizinshipStatusRO');
                        
                        String UpdateSsn;
                        if (ShowTextBoxReadOnlyInRenewal) {
                            UpdateSsn = (String) residanceEditBlockRO.get(
                                'SocialSecurityNumberROForRenewalShowEditFalse'
                            );
                        } else {
                            UpdateSsn = (String) residanceEditBlockRO.get('SocialSecurityNumberEditForRenewalROBlock');
                        }
                        
                        if (parType == 'Renewal' && String.isNotBlank(UpdateSsn) && String.isNotBlank(accountId)) {
                            checkValidSSNNumberOnPersonalInfo(UpdateSsn, accountId, acc, outMap);
                        }
                        
                    }
                    saveCitizenshipDetails(
                        personalInformation,
                        parId,
                        par,
                        (Boolean) inputMap.get('isNewApplication'),
                        (Boolean) inputMap.get('IsMigratedData')
                    );
                    LPI_WithoutSharingUtility.updateSObject(acc);
                } else {
                    conMiddleName = (String) accountInfo.get('ConMiddleName');
                    maidenName = (String) accountInfo.get('MaidenName');
                    firstName = (String) accountInfo.get('FirstName');
                    lastName = (String) accountInfo.get('LastName');
                    suffix = (String) accountInfo.get('Suffix');
                    String listAnotherNames,
                    socialSecurityNumberEditForRenewal,
                    socialSecurityNumberRO,
                    otherName,
                    UpdateSSNIfNoApplicationSubmittedFromAccount,
                    UpdateSSNIfNoApplicationSubmittedFromAccountRO,
                    socialSecurityNumberROForRenewal;
                    Map<String, object> editBlockDetails;
                    if (personalInformation.get('EditBlockDetails') != null) {
                     editBlockDetails = (Map<String, object>) personalInformation.get('EditBlockDetails');
                        listAnotherNames = (String) editBlockDetails.get('ListOfAnotherNames');
                        socialSecurityNumberEditForRenewal = (String) editBlockDetails.get(
                            'SocialSecurityNumberEditForRenewal'
                        );
                        socialSecurityNumberRO = (String) editBlockDetails.get('SocialSecurityNumberRO');
                        UpdateSSNIfNoApplicationSubmittedFromAccount = (String) editBlockDetails.get(
                            'UpdateSSNIfNoApplicationSubmittedFromAccount'
                        );
                        UpdateSSNIfNoApplicationSubmittedFromAccountRO = (String) editBlockDetails.get(
                            'UpdateSSNIfNoApplicationSubmittedFromAccountRO'
                        );
                        socialSecurityNumberROForRenewal = (String) editBlockDetails.get(
                            'SocialSecurityNumberROForRenewal'
                        );
                        otherName = (String) editBlockDetails.get('AnotherName');
                    }
                    Map<String, object> residanceAddressEditBlock = (Map<String, object>) personalInformation.get(
                        'ResidanceAddressEditBlock'
                    );
                    mailingAddressSameAsCurrentAddress = (Boolean) residanceAddressEditBlock.get(
                        'MailingAddressSameAsCurrentAddress'
                    );
               
                    par.Other_Names__c = listAnotherNames;
                
                    Map<String, String> acckeyMaping = new Map<String, String>{
                        'Age' => 'Age__c',
                            'CellPhone' => 'Phone',
                            'CitizinshipStatus' => 'Citizenship__c',
                            'DateofBirth' => 'Date_of_Birth__c',
                            'FaxNumber' => 'Fax',
                            'TelephoneNumber' => 'PersonHomePhone',
                            'ForeignCitizenship' => 'Other_Citizenship__c',
                            'E-mailAddress' => 'PersonEmail'
                            };
                            if (boardName == 'Nursing') {
                                acckeyMaping.put('Gender', 'Gender__c');
                                acckeyMaping.put('PlaceOfBirth', 'Place_of_Birth__c');
                                acckeyMaping.put('Race', 'Race__c');
                                acckeyMaping.put('OtherRace', 'Other_Race__c');
                                acckeyMaping.put('language', 'Language__c');
                                acckeyMaping.put('ForeignLanguage', 'Other_Language__c');
                                acckeyMaping.put('Nationality', 'Nationality__c');
                                acckeyMaping.put('OtherNationality', 'Other_Nationality__c');
                            }
                    Account acc;
                    if (editBlockDetails != null) {
                        acc = (Account) LPI_VlocityUtility.createSObject(editBlockDetails, acckeyMaping, 'Account');
                        acc.put('IsMailingAddress_same_as_current_Address__c', mailingAddressSameAsCurrentAddress);
                        acc.put('Suffix', suffix);
                        acc.put('Id', accountId);
                        if (String.isBlank(accMiddleNameRo)) {
                            acc.put('MiddleName', conMiddleName);
                        }
                        if (String.isBlank(accMaidenNameRO)) {
                            acc.put('Maiden_Name__c', maidenName);
                        }
                    
                        if (String.isBlank(accOtherNameRO)) {
                            acc.put('Other_Names__c', listAnotherNames);
                        }
                        if (
                            parType.equals('Renewal') &&
                            String.isNotBlank(socialSecurityNumberEditForRenewal) &&
                            String.isNotBlank(accountId)
                        ) {
                            checkValidSSNNumberOnPersonalInfo(socialSecurityNumberEditForRenewal, accountId, acc, outMap);
                        } else {
                            if (parType == 'New') {
                                List<IndividualApplication> iAapplication = LPI_IndividualApplicationDAO.getIndividualApplicationByDymanicQuery(
                                    'Id',
                                    'AccountId = \'' + accountId + '\'' + ' AND Status =\'' + SUBMITTED + '\'',
                                    null,
                                    null,
                                    null
                                );
                                List<BusinessLicenseApplication> bLAApplication = LPI_BusinessLicenseApplicationDAO.getBusinessLicenseApplicationByDymanicQuery(
                                    'Id',
                                    'Applicant.AccountId= \'' + accountId + '\'' + ' AND Status =\'' + SUBMITTED + '\'',
                                    null,
                                    null,
                                    null
                                );
                                List<BusinessLicense> businessLicense = LPI_BusinessLicenseDAO.fetchBusinessLicenseRecords(
                                    'Id',
                                    'Contact.AccountId =\'' + accountId + '\''
                                );
                                if (iAapplication.isEmpty() && bLAApplication.isEmpty() && businessLicense.isEmpty()) {
                                    checkValidSSNNumberOnPersonalInfo(
                                        UpdateSSNIfNoApplicationSubmittedFromAccount,
                                        accountId,
                                        acc,
                                        outMap
                                    );
                                } else if (
                                parType.equals('Renewal') &&
                                (Boolean) inputMap.get('IsMigratedData') &&
                                String.isNotBlank(socialSecurityNumberROForRenewal)
                                ) {
                                acc.put('Social_Security_Number__c', socialSecurityNumberROForRenewal);
                            } else {
                                    acc.put('Social_Security_Number__c', socialSecurityNumberRO);
                                }
                        }
                    }
                        saveCitizenshipDetails(
                            personalInformation,
                            parId,
                            par,
                            (Boolean) inputMap.get('isNewApplication'),
                            (Boolean) inputMap.get('IsMigratedData')
                        );
                        LPI_WithoutSharingUtility.updateSObject(acc); 
                }
                
                Map<String, object> primaryStateOfResidenceBlock = (Map<String, object>) personalInformation.get('PrimaryStateOfResidenceBlock'); 
                }
                par.MiddleName__c = conMiddleName;
                par.FirstName__c = firstName;
                par.LastName__c = lastName;
                par.MaidenName__c = maidenName;
                LPI_DML.doUpdate(par);
            } 
        }catch (exception ex) {
            LPI_ExceptionManager.logException(CLASS_NAME, 'updatePersonalInfoData', ex);     
        } 
    }
   
    
    private static void CheckAddressValidation(Map<String, Object> inputMap, Map<String, Object> outMap) {
        try {
            Map<String, object> personalInformation = (Map<String, object>) inputMap.get('PersonalInformation');
            String regAuthTypeName = (String) inputMap.get('regAuthTypeName');
            String labelForMailingAddress = personalInformation.containsKey('labelForMailingAddress')
                ? (String) personalInformation.get('labelForMailingAddress')
                : '';
            String boardName = (String)inputMap.get('BoardName');
            Map<String, object> residanceEditBlock = new Map<String, Object>();
            boolean mailingAddressSameAsCurrentAddress = true;
            boolean result = true;
            LPI_GoogleIntegration.AddressValidationResultWrapper resultWrap = new LPI_GoogleIntegration.AddressValidationResultWrapper();
            residanceEditBlock = (Map<String, object>) personalInformation.get('ResidanceAddressEditBlock');
            outMap.put('ErrorInAddress', false);
            outMap.put('AddressErrorMessage', '');
            if (residanceEditBlock != null) {
                if (labelForMailingAddress == 'Business Mailing Address') {
                    mailingAddressSameAsCurrentAddress = (Boolean) residanceEditBlock.get(
                        'MailingAddressSameAsCurrentAddress2'
                    );
                } else {
                    mailingAddressSameAsCurrentAddress = (Boolean) residanceEditBlock.get(
                        'MailingAddressSameAsCurrentAddress'
                    );
                }
                
                resultWrap = LPI_GoogleIntegration.checkAddressValidation(
                    (String) residanceEditBlock.get('ResCountry'),
                    (String) residanceEditBlock.get('City'),
                    new List<String>{
                        (String) residanceEditBlock.get('StreetAddress') + ',' +
                            (String) residanceEditBlock.get('City') + ',' +
                            (String) residanceEditBlock.get('ResCountry') + ',' +
                            (String) residanceEditBlock.get('ZipCode'),
                            (String) residanceEditBlock.get('ZipCode')
                            }
                );
                
                if (resultWrap.addressValid || resultWrap.skipValidation) {
                    outMap.put('ResidenceLong', resultWrap.longitude);
                    outMap.put('ResidenceLat', resultWrap.latitude);
                } else {
                    result = false;
                    outMap.put('ErrorInAddress', true);
                    outMap.put('ErrType','ResidenceAddressError');
                    outMap.put(
                        'AddressErrorMessage',
                        'Residence Address Validation Failed. Please Provide a Correct Address.'
                    );
                    outMap.put('isResidenceAddressInvalid', true);
                }
            }
            Map<String, object> mailingMainBlock = (Map<String, object>) personalInformation.get('MailingAddressBlock');
            
            Map<String, object> primaryContactAddressBlock = new Map<String, object>();
            Map<String, object> licenseAddressBlock = new Map<String, object>();
            Map<String, object> publiclyDisplayedAddressBlock = new Map<String, object>();
            String addressTypePCA, addressTypeLA, addressTypePDA;
                        licenseAddressBlock = (Map<String, object>) personalInformation.get('LicenseAddressBlock');
						if(licenseAddressBlock != null){
								Map<String, object> addressTypeLAElementName = (Map<String, object>) licenseAddressBlock.get(
								'AddressTypeLAElementName'
							);
							if(addressTypeLAElementName != null)
							{
								addressTypeLA = (String) addressTypeLAElementName.get('AddressTypeLA');
							}
						}
                  
                        publiclyDisplayedAddressBlock = (Map<String, object>) personalInformation.get(
                            'PubliclyDisplayedAddressBlock'
                        );
						if(publiclyDisplayedAddressBlock != null){
							Map<String, object> addressTypePDAElementName = (Map<String, object>) publiclyDisplayedAddressBlock.get(
							'AddressTypePDAElementName'
						);
						if(addressTypePDAElementName != null)
						{
							addressTypePDA = (String) addressTypePDAElementName.get('AddressTypePDA');	
						}
						}
            
            if (result && !mailingAddressSameAsCurrentAddress) {
                Map<String, object> mailingEditBlock = new Map<String, object>();
                if (mailingMainBlock != null) {
                    mailingEditBlock = (Map<String, object>) mailingMainBlock.get('MailingAddrEditBlock');
                    if (mailingEditBlock != null) {
                        resultWrap = LPI_GoogleIntegration.checkAddressValidation(
                            (String) mailingEditBlock.get('MailingCountry'),
                            (String) mailingEditBlock.get('MailingCity'),
                            new List<String>{
                                (String) mailingEditBlock.get('MailingStreet') + ',' +
                                    (String) mailingEditBlock.get('MailingCity') + ',' +
                                    (String) mailingEditBlock.get('MailingCountry') + ',' +
                                    (String) mailingEditBlock.get('MailingZipCode'),
                                    (String) mailingEditBlock.get('MailingZipCode')
                                    }
                        );
                       
                        if (resultWrap.addressValid || resultWrap.skipValidation) {
                            outMap.put('MailingLong', resultWrap.longitude);
                            outMap.put('MailingLat', resultWrap.latitude);
                        } else {
                            result = false;
                            outMap.put('ErrorInAddress', true);
                            outMap.put('ErrType','MailingAddressError');
                            outMap.put(
                                'AddressErrorMessage',
                                'Mailing Address Validation Failed. Please Provide a Correct Address.'
                            );
                            outMap.put('isMailingAddressInvalid', true);
                        }
                    }
                }
            }
            
          
                if (
                    result &&
                    primaryContactAddressBlock.containsKey('PCAAddressBlock') &&
                    addressTypePCA != 'Residence' &&
                    addressTypePCA != 'Mailing'
                ) {
                    Map<String, object> pcaAddressBlock = (Map<String, object>) primaryContactAddressBlock.get(
                        'PCAAddressBlock'
                    );
                    if (pcaAddressBlock != null) {
                        resultWrap = LPI_GoogleIntegration.checkAddressValidation(
                            (String) pcaAddressBlock.get('PCACountry'),
                            (String) pcaAddressBlock.get('PCACity'),
                            new List<String>{
                                (String) pcaAddressBlock.get('PCAStreetAddress') + ',' +
                                    (String) pcaAddressBlock.get('PCACity') + ',' +
                                    (String) pcaAddressBlock.get('PCACountry') + ',' +
                                    (String) pcaAddressBlock.get('PCAZipCode'),
                                    (String) pcaAddressBlock.get('PCAZipCode')
                                    }
                        );
                       
                        if (resultWrap.addressValid || resultWrap.skipValidation) {
                            outMap.put('PcaLong', resultWrap.longitude);
                            outMap.put('PcaLat', resultWrap.latitude);
                        } else {
                            result = false;
                            outMap.put('ErrorInAddress', true);
                            outMap.put('ErrType','PrimaryContactAddressError');
                            outMap.put(
                                'AddressErrorMessage',
                                'Primary Contact Address Validation Failed. Please Provide a Correct Address.'
                            );
                            outMap.put('isPersonalInfoPCAInvalid', true);
                        }
                    }
                }
                if (
                    
                    result &&
                    licenseAddressBlock.containsKey('LAAddressBlock') &&
                    addressTypeLA != 'Residence' &&
                    addressTypeLA != 'Mailing'
                   ) {
                       Map<String, object> laAddressBlock = (Map<String, object>) licenseAddressBlock.get(
                           'LAAddressBlock'
                       );
                       if (laAddressBlock != null) {
                           resultWrap = LPI_GoogleIntegration.checkAddressValidation(
                               (String) laAddressBlock.get('LACountry'),
                               (String) laAddressBlock.get('LACity'),
                               new List<String>{
                                   (String) laAddressBlock.get('LAStreetAddress') + ',' +
                                       (String) laAddressBlock.get('LACity') + ',' +
                                       (String) laAddressBlock.get('LACountry') + ',' +
                                       (String) laAddressBlock.get('LAZipCode'),
                                       (String) laAddressBlock.get('LAZipCode')
                                       }
                           );
                          
                           if (resultWrap.addressValid || resultWrap.skipValidation) {
                               outMap.put('LaLong', resultWrap.longitude);
                               outMap.put('LaLat', resultWrap.latitude);
                           } else {
                               result = false;
                               outMap.put('ErrorInAddress', true);
                               outMap.put('ErrType','LicenseAddressValidationError');
                               outMap.put(
                                   'AddressErrorMessage',
                                   'License Address Validation Failed. Please Provide a Correct Address.'
                               );
                               outMap.put('isPersonalInfoLicenseAddressInvalid', true);
                           }
                       }
                   }
                if (
                   
                    result &&
                    (addressTypePDA != addressTypeLA) &&
                    (addressTypePDA != addressTypePCA) &&
                    (addressTypePDA != RESIDENCE) &&
                    (addressTypePDA != MAILING)
                ) {
                    if (publiclyDisplayedAddressBlock.containsKey('PDAAddressBlock')) {
                        Map<String, object> pdaAddressBlock = (Map<String, object>) publiclyDisplayedAddressBlock.get(
                            'PDAAddressBlock'
                        );
                        if (pdaAddressBlock != null) {
                            resultWrap = LPI_GoogleIntegration.checkAddressValidation(
                                (String) pdaAddressBlock.get('PDACountry'),
                                (String) pdaAddressBlock.get('PDACity'),
                                new List<String>{
                                    (String) pdaAddressBlock.get('PDAStreetAddress') + ',' +
                                        (String) pdaAddressBlock.get('PDACity') + ',' +
                                        (String) pdaAddressBlock.get('PDACountry') + ',' +
                                        (String) pdaAddressBlock.get('PDAZipCode'),
                                        (String) pdaAddressBlock.get('PDAZipCode')
                                        }
                            );
                           
                            if (resultWrap.addressValid || resultWrap.skipValidation) {
                                outMap.put('PdaLong', resultWrap.longitude);
                                outMap.put('PdaLat', resultWrap.latitude);
                            } else {
                                result = false;
                                outMap.put('ErrorInAddress', true);
                                outMap.put('ErrType','PublicDisplayAddressError');
                                outMap.put(
                                    'AddressErrorMessage',
                                    'Public Display Address Validation Failed. Please Provide a Correct Address.'
                                );
                                outMap.put('isPersonalInfoPDAInvalid', true);
                            }
                        }
                    }
                }
           
        } catch (Exception e) {
            LPI_ExceptionManager.logException(CLASS_NAME, 'CheckAddressValidation', e);
            throw new LPI_Exception('Problem in saving the the Personal Information details', e);
        }
    }
    private static void saveAddresses(
        Id parId,
        String accountId,
        Map<String, Object> inputMap,
        Map<String, Object> outMap
    ) {
        try {
            System.debug('Save Address>>>>'+inputMap);
            String regAuthTypeName = (String) inputMap.get('regAuthTypeName');
            String boardName = (String)inputMap.get('BoardName');
            List<Schema.location> locationUpdateList = new List<Schema.location>();
            List<Schema.Address> addressUpdateList = new List<Schema.Address>();
            
            List<Schema.location> locationInsertList = new List<Schema.location>();
            Map<String, Schema.Address> addressInsertMap = new Map<String, Schema.Address>();
            
            List<Temp_AuthApplicationPlace__c> tempAapInsertList = new List<Temp_AuthApplicationPlace__c>();
            Map<String, Id> combinekeyofLocWithLocId = new Map<String, Id>();
            
            Boolean isMigratedData = (Boolean) inputMap.get('IsMigratedData');
            
           
            String resLocationId = (String) inputMap.get('residenceLocationId');
            String resAddressId = (String) inputMap.get('residenceAddressId');
            String accName = (String) inputMap.get('AccountNameRO');
            
           
            String mailingLocationId = (String) inputMap.get('MailinglocationId');
            String mailingAddressId = (String) inputMap.get('MailingaddressId') ;
            String mailing_Temp_AAP_Id = (String) inputMap.get('mailing_Temp_AAP_Id');
            
            
           
            String pcaLocationId = (String) inputMap.get('pcaLocationId');
            String pcaAddressId = (String) inputMap.get('pcaAddressId');
            String pca_Temp_AAP_Id = (String) inputMap.get('PCA_AAP_Id');
            
            
            String laLocationId = (String) inputMap.get('laLocationId');
            String laAddressId = (String) inputMap.get('laAddressId');
            String la_Temp_AAP_Id = (String) inputMap.get('LA_AAP_Id');			
            
            
            String pdaLocationId = (String) inputMap.get('pdaLocationId');
            String pdaAddressId = (String) inputMap.get('pdaAddressId');
            String pda_Temp_AAP_Id = (String) inputMap.get('PDA_AAP_Id');
            
            
            Map<String, object> personalInformation = (Map<String, object>) inputMap.get('PersonalInformation');
            String labelForMailingAddress = personalInformation.containsKey('labelForMailingAddress')
                ? (String) personalInformation.get('labelForMailingAddress')
                : '';
            Map<String, object> residanceEditBlock = new Map<String, Object>();
            Map<String, object> residanceEditBlockRO = new Map<String, Object>();
            String street;
            String city;
            String statePicklistEdit;
            String stateTextEdit;
            String zipCode;
            String country,county;
            boolean mailingAddressSameAsCurrentAddress;
            residanceEditBlock = (Map<String, object>) personalInformation.get('ResidanceAddressEditBlock');
            if (residanceEditBlock != null) {
                if (labelForMailingAddress == 'Business Mailing Address') {
                    mailingAddressSameAsCurrentAddress = (Boolean) residanceEditBlock.get(
                        'MailingAddressSameAsCurrentAddress2'
                    );
                } else {
                    mailingAddressSameAsCurrentAddress = (Boolean) residanceEditBlock.get(
                        'MailingAddressSameAsCurrentAddress'
                    );
                }
                
                if(residanceEditBlock.containsKey('IndResCountyCityZipLwc')){
                    Map<String, object> resCountyCityZipLwcBlock = (Map<String, object>) residanceEditBlock.get('IndResCountyCityZipLwc');
                    county = (String) resCountyCityZipLwcBlock.get('County');
                    zipCode = (String) resCountyCityZipLwcBlock.get('ZipCode');
                    city = (String) resCountyCityZipLwcBlock.get('City');	
                    street = resCountyCityZipLwcBlock.containsKey('StreetAddress')
                        ? (String) resCountyCityZipLwcBlock.get('StreetAddress')
                        : '';
                    statePicklistEdit = (String) resCountyCityZipLwcBlock.get('statePicklistEdit');
                    stateTextEdit = (String) resCountyCityZipLwcBlock.get('StateTextEdit');
                    country = (String) resCountyCityZipLwcBlock.get('ResCountry');
                }
            } else {
                residanceEditBlockRO = (Map<String, object>) personalInformation.get('ReadBlockDetails');
                if (labelForMailingAddress == 'Business Mailing Address') {
                    mailingAddressSameAsCurrentAddress = (Boolean) residanceEditBlockRO.get(
                        'MailingAddressSameAsCurrentAddressRO2'
                    );
                } else {
                    mailingAddressSameAsCurrentAddress = (Boolean) residanceEditBlockRO.get(
                        'MailingAddressSameAsCurrentAddressRO'
                    );
                }
                street = residanceEditBlockRO.containsKey('StreetAddressRO')
                    ? (String) residanceEditBlockRO.get('StreetAddressRO')
                    : '';
                city = (String) residanceEditBlockRO.get('CityRO');
                statePicklistEdit = (String) residanceEditBlockRO.get('State');
                stateTextEdit = (String) residanceEditBlockRO.get('StateTextReadOnly');
                zipCode = (String) residanceEditBlockRO.get('ZipCodeRO');
                country = (String) residanceEditBlockRO.get('ResCountryRO');
                county = (String) residanceEditBlock.get('CountyRO');
            }
            Map<String, object> mailingMainBlock = (Map<String, object>) personalInformation.get('MailingAddressBlock');
            
            Map<String, object> primaryContactAddressBlock = new Map<String, object>();
            Map<String, object> licenseAddressBlock = new Map<String, object>();
            Map<String, object> publiclyDisplayedAddressBlock = new Map<String, object>();
            String addressTypePCA, addressTypeLA, addressTypePDA;
            
                        licenseAddressBlock = (Map<String, object>) personalInformation.get('LicenseAddressBlock');
                        Map<String, object> addressTypeLAElementName = (Map<String, object>) licenseAddressBlock.get(
                            'AddressTypeLAElementName'
                        );
                        addressTypeLA = (String) addressTypeLAElementName.get('AddressTypeLA');
            
                        publiclyDisplayedAddressBlock = (Map<String, object>) personalInformation.get(
                            'PubliclyDisplayedAddressBlock'
                        );
                        Map<String, object> addressTypePDAElementName = (Map<String, object>) publiclyDisplayedAddressBlock.get(
                            'AddressTypePDAElementName'
                        );
                        addressTypePDA = (String) addressTypePDAElementName.get('AddressTypePDA');
                    
                    PreliminaryApplicationRef updateAddressFields = new PreliminaryApplicationRef();
                    updateAddressFields.Id = parId;
                    updateAddressFields.Primary_Contact_Address__c = addressTypePCA;
                    updateAddressFields.License_Address__c = addressTypeLA;
                    updateAddressFields.Publicly_Displayed_Address__c = addressTypePDA;
                    LPI_TriggerHandler.bypass('PreliminaryApplicationTriggerHandler');
                    if (LPI_TriggerHandler.isBypassed('PreliminaryApplicationTriggerHandler')) {
                        LPI_DML.doUpdate(updateAddressFields);
                    }
                    LPI_TriggerHandler.clearBypass('PreliminaryApplicationTriggerHandler');
                    
                    Map<String, Schema.Location> typeWithLocation = new Map<String, Schema.Location>();
                    
                    
                    List<Id> allLocationIdList = new List<Id>();				
                    List<Temp_AuthApplicationPlace__c> allTempAuthList = new List<Temp_AuthApplicationPlace__c>();
                    List<Schema.Location> allLocationList = new List<Schema.Location>();
                    List<Schema.Address> allAddressList = new List<Schema.Address>();
                    List<AssociatedLocation> allAssLocList = new List<AssociatedLocation>();
                    
                    allTempAuthList = LPI_TempAuthApplicationPlaceDAO.getTempAuthApplicationPlaceByDymanicQuery('Id,Location__c',
                                                                                                                'Preliminary_Application_Reference__c = \''+parId+'\''+' AND Location__r.LocationType != \''+RESIDENCE+'\''+' AND Location__r.LocationType != \''+MAILING+'\'',
                                                                                                                null,null,null);
                    if(!allTempAuthList.isEmpty()){
                        for(Temp_AuthApplicationPlace__c temp : allTempAuthList)
                        {
                            allLocationIdList.add(temp.Location__c);
                            allLocationList.add(new Schema.Location(Id = temp.Location__c) );
                        }
                        
                        if(!allLocationIdList.isEmpty())
                        {
                            allAddressList = LPI_AddressDAO.getAddressByDymanicQuery('Id', 'ParentId IN ' + LPI_ServiceUtility.getStringValuesByList(allLocationIdList), null, null, null);							
                        }
                    }
                    
                    if(!allLocationIdList.isEmpty() && String.isNotBlank(accountId))
                    {
                        allAssLocList = LPI_AssociatedLocationDAO.getAssociatedLocationListByDynamicQuery(new List<String>{ 'Id' },'ParentRecordId = \'' +String.escapeSingleQuotes(accountId) +'\'' +' AND LocationId IN '+LPI_ServiceUtility.getStringValuesByList(allLocationIdList),null,null,null);	
                    }
                    if (
                        !allAddressList.isEmpty() &&
                        !allLocationList.isEmpty() &&
                        !allTempAuthList.isEmpty() &&
                        !allAssLocList.isEmpty()
                    ) {
                        LPI_WithoutSharingUtility.deleteSObject(allAddressList);
                        LPI_WithoutSharingUtility.deleteSObject(allAssLocList);
                        LPI_WithoutSharingUtility.deleteSObject(allLocationList);
                        LPI_WithoutSharingUtility.deleteSObject(allTempAuthList);
                        pca_Temp_AAP_Id = null; pcaAddressId = null; pcaLocationId = null;
                        la_Temp_AAP_Id = null; laAddressId = null; laLocationId = null;
                        pda_Temp_AAP_Id = null; pdaAddressId = null; pdaLocationId = null;
                    }
                
            if (String.isNotBlank(resLocationId) && String.isNotBlank(accName)) {
                Schema.Location residenceLoc = new Schema.Location();
                residenceLoc = createReferenceLocation(accName, 'Residence', null, inputMap, 'Residence');
                residenceLoc.id = resLocationId;
                updateConsentFor(residenceLoc, addressTypePCA, addressTypeLA, addressTypePDA, RESIDENCE);
                locationUpdateList.add(residenceLoc);
            }
            
            if (String.isNotBlank(resAddressId)) {
                Schema.Address residenceAddress = new Schema.Address();
                residenceAddress = createReferenceAddress(
                    street,
                    city,
                    country,
                    zipCode,
                    'Residence',
                    statePicklistEdit,
                    stateTextEdit,
                    county
                );
                residenceAddress.id = resAddressId;
                addressUpdateList.add(residenceAddress);
            }
            
           
            if (isMigratedData = true) {
                Schema.Location residenceLoc = new Schema.Location();
                residenceLoc = createReferenceLocation(accName, 'Residence', null, inputMap, 'Residence');
                if (String.isBlank(resLocationId) && String.isNotBlank(accName)) {
                    updateConsentFor(residenceLoc, addressTypePCA, addressTypeLA, addressTypePDA, RESIDENCE);
                    locationInsertList.add(residenceLoc);
                }
                
              
                if (String.isBlank(resAddressId)) {
                    Schema.Address residenceAddress = new Schema.Address();
                    residenceAddress = createReferenceAddress(
                        street,
                        city,
                        country,
                        zipCode,
                        'Residence',
                        statePicklistEdit,
                        stateTextEdit,
                        county
                    );
                    addressInsertMap.put(
                        residenceLoc.Name + '**' + residenceLoc.locationType + '**' + residenceLoc.Consent_For__c,
                        residenceAddress
                    );
                }
            }
            Schema.Address mailingAddress = new Schema.Address();
            if (mailingAddressSameAsCurrentAddress == true) {
                mailingAddress = createReferenceAddress(
                    street,
                    city,
                    country,
                    zipCode,
                    'Mailing',
                    statePicklistEdit,
                    stateTextEdit,
                    county
                );
                outMap.put('MailingStreet', street);
                outMap.put('MailingCity', city);
                outMap.put('MailingState', statePicklistEdit);
                outMap.put('MailingStateText', stateTextEdit);
                outMap.put('MailingCountry', country);
                outMap.put('MailingZipCode', zipCode);
                outMap.put('MailingCounty', county);
            } else {
                String mailingStreet;
                String mailingCity;
                String mailingState;
                String mailingStateText;
                String mailingCountry;
                String mailingZipCode,mailingCounty;
                if (mailingMainBlock != null) {
                    Map<String, object> indMailingCountyCityZipLwc = (Map<String, object>) mailingMainBlock.get('IndMailingCountyCityZipLwc');					
                    if ( indMailingCountyCityZipLwc != null) {
                        mailingStreet = (String) indMailingCountyCityZipLwc.get('MailingStreet');						
                        mailingState = (String) indMailingCountyCityZipLwc.get('MailingState');
                        mailingStateText = (String) indMailingCountyCityZipLwc.get('MailingStateText');
                        mailingCountry = (String) indMailingCountyCityZipLwc.get('MailingCountry');
                        mailingCity = (String) indMailingCountyCityZipLwc.get('MailingCity');
                        mailingZipCode = (String) indMailingCountyCityZipLwc.get('MailingZipCode');
                        mailingCounty = (String) indMailingCountyCityZipLwc.get('MailingCounty');
                        mailingAddress = createReferenceAddress(
                            mailingStreet,
                            mailingCity,
                            mailingCountry,
                            mailingZipCode,
                            'Mailing',
                            mailingState,
                            mailingStateText,
                            mailingCounty
                        );
                    }
                }
            }
            Schema.Location mailingLoc = new Schema.Location();
            mailingLoc = createReferenceLocation(accName, 'Mailing', null, inputMap, 'Mailing');
            updateConsentFor(mailingLoc, addressTypePCA, addressTypeLA, addressTypePDA, MAILING);
            
            if (String.isBlank(mailingLocationId) && String.isBlank(mailingAddressId)) {
              
                locationInsertList.add(mailingLoc);
               
            
                addressInsertMap.put(
                    mailingLoc.Name + '**' + mailingLoc.locationType + '**' + mailingLoc.Consent_For__c,
                    mailingAddress
                );
            } else {
               
                mailingLoc.id = mailingLocationId;
                locationUpdateList.add(mailingLoc);

                mailingAddress.id = mailingAddressId;
                addressUpdateList.add(mailingAddress);
            }
            
                    Map<String, object> indPCACountyCityZipLwc;
                    String pcaStreetAddress, pcaCity, pcaCountry, pcaState, pcaStateText, pcaZipCode,pcaCounty;
                    
                    if (
                        primaryContactAddressBlock.containsKey('IndPCACountyCityZipLwc') &&
                        addressTypePCA != 'Residence' &&
                        addressTypePCA != 'Mailing'
                    ) {
                        indPCACountyCityZipLwc = (Map<String, object>) primaryContactAddressBlock.get('IndPCACountyCityZipLwc');
                        if (indPCACountyCityZipLwc != null) {
                            pcaStreetAddress = (String) indPCACountyCityZipLwc.get('PCAStreetAddress');
                            pcaCity = (String) indPCACountyCityZipLwc.get('PCACity');
                            pcaCountry = (String) indPCACountyCityZipLwc.get('PCACountry');
                            pcaState = (String) indPCACountyCityZipLwc.get('PCAState');
                            pcaStateText = (String) indPCACountyCityZipLwc.get('PCAStateText');
                            pcaZipCode = (String) indPCACountyCityZipLwc.get('PCAZipCode');
                            pcaCounty = (String) indPCACountyCityZipLwc.get('PCACounty');
                        }
                    }
                    if (
                        primaryContactAddressBlock.containsKey('PCAAddressBlockReadOnly') &&
                        addressTypePCA != 'Residence' &&
                        addressTypePCA != 'Mailing'
                    ) {
                        Map<String, object> pcaAddressBlockReadOnly = (Map<String, object>) primaryContactAddressBlock.get(
                            'PCAAddressBlockReadOnly'
                        );
                        if (pcaAddressBlockReadOnly != null) {
                            pcaStreetAddress = (String) pcaAddressBlockReadOnly.get('PCAStreetAddressRO');
                            pcaCity = (String) pcaAddressBlockReadOnly.get('PCACityRO');
                            pcaCountry = (String) pcaAddressBlockReadOnly.get('PCACountryRO');
                            pcaState = (String) pcaAddressBlockReadOnly.get('PCAStateRO');
                            pcaStateText = (String) pcaAddressBlockReadOnly.get('PCAStateTextRO');
                            pcaZipCode = (String) pcaAddressBlockReadOnly.get('PCAZipCodeRO');
                            pcaCounty = (String) pcaAddressBlockReadOnly.get('PCACountyRO');
                        }
                    }
                    Schema.Location primaryContactAddressLoc = new Schema.Location();
                    primaryContactAddressLoc = createReferenceLocation(
                        accName,
                        addressTypePCA,
                        PRIMARY_CONTACT_ADDRESS,
                        inputMap,
                        'Pca'
                    );
                    if (addressTypePCA != RESIDENCE && addressTypePCA != MAILING) {
                        
                        if (addressTypePCA == addressTypeLA && addressTypePCA == addressTypePDA) {
                            primaryContactAddressLoc.Consent_For__c = 'Primary Contact Address;License Address;Publicly Displayed Address';
                        } else if (addressTypePCA == addressTypeLA) {
                            primaryContactAddressLoc.Consent_For__c = 'Primary Contact Address;License Address';
                        } else if (addressTypePCA == addressTypePDA) {
                            primaryContactAddressLoc.Consent_For__c = 'Primary Contact Address;Publicly Displayed Address';
                        }
                        
                        Schema.Address primaryContactAddress = new Schema.Address();
                        primaryContactAddress = createReferenceAddress(
                            pcaStreetAddress,
                            pcaCity,
                            pcaCountry,
                            pcaZipCode,
                            addressTypePCA,
                            pcaState,
                            pcaStateText,
                            pcaCounty
                        );
                        if (indPCACountyCityZipLwc != null && String.isBlank(pcaLocationId) && String.isBlank(pcaAddressId)) {
                           
                            addressInsertMap.put(
                                primaryContactAddressLoc.Name +
                                '**' +
                                primaryContactAddressLoc.LocationType +
                                '**' +
                                primaryContactAddressLoc.Consent_For__c,
                                primaryContactAddress
                            );
                        } else if (String.isNotBlank(pcaAddressId)) {
                            
                            primaryContactAddress.id = pcaAddressId;
                            addressUpdateList.add(primaryContactAddress);
                        }
                    }
                    
                    
                    
                    Map<String, object> indLACountyCityZipLwc;
                    String laStreetAddress, laCity, laState, laStateText, laCountry, laZipCode,laCounty;
                
                        if (
                            licenseAddressBlock.containsKey('IndLACountyCityZipLwc') &&
                            addressTypeLA != 'Residence' &&
                            addressTypeLA != 'Mailing'
                        ) {
                            indLACountyCityZipLwc = (Map<String, object>) licenseAddressBlock.get('IndLACountyCityZipLwc');
                            if (indLACountyCityZipLwc != null) {
                                laStreetAddress = (String) indLACountyCityZipLwc.get('LAStreetAddress');
                                laCity = (String) indLACountyCityZipLwc.get('LACity');
                                laState = (String) indLACountyCityZipLwc.get('LAState');
                                laStateText = (String) indLACountyCityZipLwc.get('LAStateText');
                                laCountry = (String) indLACountyCityZipLwc.get('LACountry');
                                laZipCode = (String) indLACountyCityZipLwc.get('LAZipCode');
                                laCounty = (String) indLACountyCityZipLwc.get('LACounty');
                            }
                        }
                        if (
                            licenseAddressBlock.containsKey('LAAddressBlockReadOnly') &&
                            addressTypeLA != 'Residence' &&
                            addressTypeLA != 'Mailing'
                        ) {
                            Map<String, object> laAddressBlockReadOnly = (Map<String, object>) licenseAddressBlock.get(
                                'LAAddressBlockReadOnly'
                            );
                            
                            if (laAddressBlockReadOnly != null) {
                                laStreetAddress = (String) laAddressBlockReadOnly.get('LAStreetAddressRO');
                                laCity = (String) laAddressBlockReadOnly.get('LACityRO');
                                laState = (String) laAddressBlockReadOnly.get('LAStateRO');
                                laStateText = (String) laAddressBlockReadOnly.get('LAStateTextRO');
                                laCountry = (String) laAddressBlockReadOnly.get('LACountryRO');
                                laZipCode = (String) laAddressBlockReadOnly.get('LAZipCodeRO');
                                laCounty = (String) laAddressBlockReadOnly.get('LACountyRO');
                            }
                        }
                        Schema.Location licenseAddressLoc = new Schema.Location();
                        licenseAddressLoc = createReferenceLocation(accName, addressTypeLA, LICENSE_ADDRESS, inputMap, 'La');
                        if (addressTypeLA != RESIDENCE && addressTypeLA != MAILING && addressTypeLA != addressTypePCA) {
                            if (addressTypeLA == addressTypePCA && addressTypeLA == addressTypePDA) {
                                licenseAddressLoc.Consent_For__c = 'Primary Contact Address;License Address;Publicly Displayed Address';
                            } else if (addressTypeLA == addressTypePCA) {
                                licenseAddressLoc.Consent_For__c = 'License Address;Primary Contact Address';
                            } else if (addressTypeLA == addressTypePDA) {
                                licenseAddressLoc.Consent_For__c = 'License Address;Publicly Displayed Address';
                            }
                            
                           
                            if (String.isNotBlank(laLocationId)) {
                               
                                licenseAddressLoc.id = laLocationId;
                                locationUpdateList.add(licenseAddressLoc);
                            } else {
                                
                                locationInsertList.add(licenseAddressLoc);
                            }
                            
                            
                            Schema.Address licenseAddress = new Schema.Address();
                            licenseAddress = createReferenceAddress(
                                laStreetAddress,
                                laCity,
                                laCountry,
                                laZipCode,
                                addressTypeLA,
                                laState,
                                laStateText,
                                laCounty
                            );
                            
                            if (indLACountyCityZipLwc != null && String.isBlank(laLocationId) && String.isBlank(laAddressId)) {
                                
                                addressInsertMap.put(
                                    licenseAddressLoc.Name +
                                    '**' +
                                    licenseAddressLoc.locationType +
                                    '**' +
                                    licenseAddressLoc.Consent_For__c,
                                    licenseAddress
                                );
                            } else if (String.isNotBlank(laAddressId)) {
                                
                                licenseAddress.id = laAddressId;
                                addressUpdateList.add(licenseAddress);
                            }
                        }
                    // ******************* Linking publicaly Displayed Address *******************
                    if (
                        
                        (addressTypePDA != addressTypeLA) &&
                        (addressTypePDA != addressTypePCA) &&
                        (addressTypePDA != RESIDENCE) &&
                        (addressTypePDA != MAILING)
                    ) {
                        Map<String, object> indPDACountyCityZipLwc;
                        String pdaStreetAddress, pdaCity, pdaState, pdaStateText, pdaCountry, pdaZipCode,pdaCounty;
                        if (publiclyDisplayedAddressBlock.containsKey('IndPDACountyCityZipLwc')) {
                            indPDACountyCityZipLwc = (Map<String, object>) publiclyDisplayedAddressBlock.get('IndPDACountyCityZipLwc');
                            if (indPDACountyCityZipLwc != null) {
                                pdaStreetAddress = (String) indPDACountyCityZipLwc.get('PDAStreetAddress');
                                pdaCity = (String) indPDACountyCityZipLwc.get('PDACity');
                                pdaState = (String) indPDACountyCityZipLwc.get('PDAState');
                                pdaStateText = (String) indPDACountyCityZipLwc.get('PDAStateText');
                                pdaCountry = (String) indPDACountyCityZipLwc.get('PDACountry');
                                pdaZipCode = (String) indPDACountyCityZipLwc.get('PDAZipCode');
                                pdaCounty = (String) indPDACountyCityZipLwc.get('PDACounty');
                            }
                        }
                        if (publiclyDisplayedAddressBlock.containsKey('PDAAddressBlockReadOnly')) {
                            Map<String, object> pdaAddressBlockReadOnly = (Map<String, object>) publiclyDisplayedAddressBlock.get(
                                'PDAAddressBlockReadOnly'
                            );
                            
                            if (pdaAddressBlockReadOnly != null) {
                                pdaStreetAddress = (String) pdaAddressBlockReadOnly.get('PDAStreetAddressRO');
                                pdaCity = (String) pdaAddressBlockReadOnly.get('PDACityRO');
                                pdaState = (String) pdaAddressBlockReadOnly.get('PDAStateRO');
                                pdaStateText = (String) pdaAddressBlockReadOnly.get('PDAStateTextRO');
                                pdaCountry = (String) pdaAddressBlockReadOnly.get('PDACountryRO');
                                pdaZipCode = (String) pdaAddressBlockReadOnly.get('PDAZipCodeRO');
                                pdaCounty = (String) pdaAddressBlockReadOnly.get('PDACountyRO');
                            }
                        }
                        
                        Schema.Location publiclyDisplayedAddressLoc = new Schema.Location();
                        publiclyDisplayedAddressLoc = createReferenceLocation(
                            accName,
                            addressTypePDA,
                            PUBLICLY_DISPLAYED_ADDRESS,
                            inputMap,
                            'Pda'
                        );
                        if (addressTypePDA == addressTypePCA && addressTypePDA == addressTypeLA) {
                            publiclyDisplayedAddressLoc.Consent_For__c = 'Primary Contact Address;License Address;Publicly Displayed Address';
                        } else if (addressTypePDA == addressTypePCA) {
                            publiclyDisplayedAddressLoc.Consent_For__c = 'Publicly Displayed Address;Primary Contact Address';
                        } else if (addressTypePDA == addressTypeLA) {
                            publiclyDisplayedAddressLoc.Consent_For__c = 'Publicly Displayed Address;License Address';
                        }
                        
                        if (String.isNotBlank(pdaLocationId)) {
                            
                            publiclyDisplayedAddressLoc.id = pdaLocationId;
                            locationUpdateList.add(publiclyDisplayedAddressLoc);
                        } else {
                           
                            locationInsertList.add(publiclyDisplayedAddressLoc);
                        }
                        
                       
                        Schema.Address publiclyDisplayedAddress = new Schema.Address();
                        publiclyDisplayedAddress = createReferenceAddress(
                            pdaStreetAddress,
                            pdaCity,
                            pdaCountry,
                            pdaZipCode,
                            addressTypePDA,
                            pdaState,
                            pdaStateText,
                            pdaCounty
                        );
                        
                        if (indPDACountyCityZipLwc != null && String.isBlank(pdaLocationId) && String.isBlank(pdaAddressId)) {
                           
                            addressInsertMap.put(
                                publiclyDisplayedAddressLoc.Name +
                                '**' +
                                publiclyDisplayedAddressLoc.LocationType +
                                '**' +
                                publiclyDisplayedAddressLoc.Consent_For__c,
                                publiclyDisplayedAddress
                            );
                        } else if (String.isNotBlank(pdaAddressId)) {
                           
                            publiclyDisplayedAddress.id = pdaAddressId;
                            addressUpdateList.add(publiclyDisplayedAddress);
                        }
                    }
               
            
            List<Schema.Address> addressList = new List<Schema.Address>();
            List<Temp_AuthApplicationPlace__c> tempAAPList = new List<Temp_AuthApplicationPlace__c>();
            List<AssociatedLocation> associatedLocationList = new List<AssociatedLocation>();
			
            if (!locationInsertList.isEmpty() && !addressInsertMap.isEmpty()) {
               
                List<Schema.location> insertedLocList = LPI_WithoutSharingUtility.insertSObjectList(
                    locationInsertList
                );
                
                for (Schema.location loc : insertedLocList) {
                    if (loc.LocationType != 'Residence' && loc.LocationType != 'Mailing' ) {
                        if (loc.Consent_For__c == 'primary Contact Address;License Address;publicly displayed address') {
                            if(addressTypePCA == loc.LocationType  ){
                                outMap.put('pcaLocationId', loc.Id);
                            }
                            if(addressTypeLA == loc.LocationType  ){
                                outMap.put('laLocationId', loc.Id);
                            }
                            if(addressTypePDA == loc.LocationType ){
                                outMap.put('pdaLocationId', loc.Id);
                            }
                        } else if (loc.Consent_For__c == 'primary Contact Address;License Address') {
                            if(addressTypePCA == loc.LocationType ){
                                outMap.put('pcaLocationId', loc.Id);
                            }
                            if(addressTypeLA == loc.LocationType  ){
                                outMap.put('laLocationId', loc.Id);
                            }
                        }
                        else if (loc.Consent_For__c == 'License Address;publicly displayed address') {
                            if(addressTypeLA == loc.LocationType ){
                                outMap.put('laLocationId', loc.Id);
                            }
                            if(addressTypePDA == loc.LocationType ){
                                outMap.put('pdaLocationId', loc.Id);
                            }
                        }
                        else if (loc.Consent_For__c == 'primary Contact Address;publicly displayed address') {
                            if(addressTypePCA == loc.LocationType  ){
                                outMap.put('pcaLocationId', loc.Id);
                            }
                            if(addressTypePDA == loc.LocationType ){
                                outMap.put('pdaLocationId', loc.Id);
                            }
                        }
                        else if (loc.Consent_For__c == 'primary Contact Address' && addressTypePCA != RESIDENCE && addressTypePCA != MAILING) {
                            if(addressTypePCA == loc.LocationType ){
                                outMap.put('pcaLocationId', loc.Id);
                            }
                        } else if (loc.Consent_For__c == 'License Address' && addressTypeLA != RESIDENCE && addressTypeLA != MAILING) {
                            if(addressTypeLA == loc.LocationType ){
                                outMap.put('laLocationId', loc.Id);
                            }
                        } else if (loc.Consent_For__c == 'publicly displayed address' && addressTypePDA != RESIDENCE && addressTypePDA != MAILING) {
                            if(addressTypePDA == loc.LocationType ){
                                outMap.put('pdaLocationId', loc.Id);
                            }
                        }
                    }
                    
                    if (loc.LocationType == 'Residence') {
                        outMap.put('residenceLocationId', loc.Id);
                    }
                    if (loc.LocationType == 'Mailing') {
                        outMap.put('MailinglocationId', loc.Id);
                    }
                    Schema.address address = addressInsertMap.get(
                        loc.Name + '**' + loc.locationType + '**' + loc.Consent_For__c
                    );
                    address.ParentId = loc.Id;
                    addressList.add(address);
                    
                    Temp_AuthApplicationPlace__c tempAAP = new Temp_AuthApplicationPlace__c();
                    tempAAP.Location__c = loc.Id;
                    tempAAP.Preliminary_Application_Reference__c = parId;
                    tempAAPList.add(tempAAP);
                    
                    associatedLocationList.add(createReferenceAssLocation(accountId, loc.Id));
                }
                List<Schema.Address> insertedAddressList = LPI_WithoutSharingUtility.insertSObjectList(addressList);
                Set<Id> insertedAddressIds = new Set<Id>();
                for (Schema.Address address : insertedAddressList) {
                    insertedAddressIds.add(address.Id);
                    
                }
                
                List<Schema.Address> addressesListWithAllValues = new LPI_AddressDAO.LPI_AddressDAOWithoutSharing().getAddressByDymanicQuery('ID,ParentId,Parent.LocationType,Parent.Consent_For__c',
                                                                                                                                             'Id IN ' + LPI_ServiceUtility.getStringValuesBySet(insertedAddressIds),
                                                                                                                                             null,
                                                                                                                                             null, 
                                                                                                                                             null);
                for (Schema.Address address : addressesListWithAllValues) {
                    if (address.parent.LocationType != 'Residence' && address.parent.LocationType != 'Mailing' ) {
                        if (address.parent.Consent_For__c =='primary Contact Address;License Address;publicly displayed address') 
                        {
                            if(addressTypePCA == address.parent.LocationType ){
                                outMap.put('pcaAddressId', address.Id);
                            }
                            if(addressTypeLA == address.parent.LocationType ){
                                outMap.put('laAddressId', address.Id);
                            }
                            if(addressTypePDA == address.parent.LocationType ){
                                outMap.put('pdaAddressId', address.Id);
                            }
                        } else if (address.parent.Consent_For__c == 'primary Contact Address;License Address') {
                            if(addressTypePCA == address.parent.LocationType ){
                                outMap.put('pcaAddressId', address.Id);
                            }
                            if(addressTypeLA == address.parent.LocationType ){
                                outMap.put('laAddressId', address.Id);
                            }
                        } else if (address.parent.Consent_For__c == 'License Address;publicly displayed address') {
                            if(addressTypeLA == address.parent.LocationType ){
                                outMap.put('laAddressId', address.Id);
                            }
                            if(addressTypePDA == address.parent.LocationType ){
                                outMap.put('pdaAddressId', address.Id);
                            }
                        } 
                        else if (address.parent.Consent_For__c == 'primary Contact Address;publicly displayed address') {
                            if(addressTypePCA == address.parent.LocationType ){
                                outMap.put('pcaAddressId', address.Id);
                            }
                            if(addressTypePDA == address.parent.LocationType ){
                                outMap.put('pdaAddressId', address.Id);
                            }
                        } 
                        else if (address.parent.Consent_For__c == 'primary Contact Address'  && addressTypePCA != RESIDENCE && addressTypePCA != MAILING) {
                            if(addressTypePCA == address.parent.LocationType ){
                                outMap.put('pcaAddressId', address.Id);
                            }
                        } else if (address.parent.Consent_For__c == 'License Address' && addressTypeLA != RESIDENCE && addressTypeLA != MAILING) {
                            if(addressTypeLA == address.parent.LocationType ){
                                outMap.put('laAddressId', address.Id);
                            }
                        } else if (address.parent.Consent_For__c == 'publicly displayed address' && addressTypePDA != RESIDENCE && addressTypePDA != MAILING) {
                            if(addressTypePDA == address.parent.LocationType ){
                                outMap.put('pdaAddressId', address.Id);
                            }
                        }
                    }
                    
                    if (address.parent.LocationType == 'Residence') {
                        outMap.put('residenceAddressId', address.Id);
                    }
                    if (address.parent.LocationType == 'Mailing') {						
                        outMap.put('MailingaddressId', address.Id);
                    }
                }
                
                
               
                List<Temp_AuthApplicationPlace__c> insertedTempAAPList = LPI_WithoutSharingUtility.insertSObjectList(
                    tempAAPList
                );
                Set<Id> insertedTempAAPIds = new Set<Id>();
                for (Temp_AuthApplicationPlace__c tempAAP : insertedTempAAPList) {
                    insertedTempAAPIds.add(tempAAP.Id);
                }
                List<Temp_AuthApplicationPlace__c> tempAapWithAllValues = new LPI_TempAuthApplicationPlaceDAO.LPI_TempAuthApplicationPlaceWithoutSharingDAO()
                    .getTempAuthApplicationPlaceByDymanicQuery(
                        'Id,Location__c,Location__r.Consent_For__c,Location__r.LocationType',
                        'Id IN '+ LPI_ServiceUtility.getStringValuesBySet(insertedTempAAPIds),
                        null,
                        null,
                        null
                    );
                for (Temp_AuthApplicationPlace__c tempAAP : tempAapWithAllValues) {
                    if (tempAAP.Location__r.LocationType != 'Residence' && tempAAP.Location__r.LocationType != 'Mailing' ) 
                    {
                        if (tempAAP.Location__r.Consent_For__c =='primary Contact Address;License Address;publicly displayed address') 
                        {
                            if(addressTypePCA == tempAAP.Location__r.LocationType ){
                                outMap.put('PCA_AAP_Id', tempAAP.Id);
                            }
                            if(addressTypeLA == tempAAP.Location__r.LocationType ){
                                outMap.put('LA_AAP_Id', tempAAP.Id);
                            }
                            if(addressTypePDA == tempAAP.Location__r.LocationType ){
                                outMap.put('PDA_AAP_Id', tempAAP.Id);
                            }
                        } else if (tempAAP.Location__r.Consent_For__c == 'primary Contact Address;License Address') {
                            if(addressTypePCA == tempAAP.Location__r.LocationType ){
                                outMap.put('PCA_AAP_Id', tempAAP.Id);
                            }
                            if(addressTypeLA == tempAAP.Location__r.LocationType ){
                                outMap.put('LA_AAP_Id', tempAAP.Id);
                            }
                        } 
                        else if (tempAAP.Location__r.Consent_For__c == 'License Address;publicly displayed address') {
                            if(addressTypeLA == tempAAP.Location__r.LocationType ){
                                outMap.put('LA_AAP_Id', tempAAP.Id);
                            }
                            if(addressTypePDA == tempAAP.Location__r.LocationType ){
                                outMap.put('PDA_AAP_Id', tempAAP.Id);
                            }
                        }
                        else if (tempAAP.Location__r.Consent_For__c == 'primary Contact Address;publicly displayed address') {
                            if(addressTypePCA == tempAAP.Location__r.LocationType ){
                                outMap.put('PCA_AAP_Id', tempAAP.Id);
                            }
                            if(addressTypePDA == tempAAP.Location__r.LocationType ){
                                outMap.put('PDA_AAP_Id', tempAAP.Id);
                            }
                        }
                        else if (tempAAP.Location__r.Consent_For__c == 'primary Contact Address' && addressTypePCA != RESIDENCE && addressTypePCA != MAILING) {
                            if(addressTypePCA == tempAAP.Location__r.LocationType ){
                                outMap.put('PCA_AAP_Id', tempAAP.Id);
                            }
                        } else if (tempAAP.Location__r.Consent_For__c == 'License Address' && addressTypeLA != RESIDENCE && addressTypeLA != MAILING) {
                            if(addressTypeLA == tempAAP.Location__r.LocationType ){
                                outMap.put('LA_AAP_Id', tempAAP.Id);
                            }
                        } else if (tempAAP.Location__r.Consent_For__c == 'publicly displayed address' && addressTypePDA != RESIDENCE && addressTypePDA != MAILING) {
                            if(addressTypePDA == tempAAP.Location__r.LocationType ){
                                outMap.put('PDA_AAP_Id', tempAAP.Id);
                            }
                        }
                    }
                    
                    if (tempAAP.Location__r.LocationType == 'Residence') {
                        outMap.put('residence_Temp_AAP_Id', tempAAP.Id);
                    }
                    if (tempAAP.Location__r.LocationType == 'Mailing') {
                        outMap.put('mailing_Temp_AAP_Id', tempAAP.Id);
                    }
                }
                
               
                if (!associatedLocationList.isEmpty()) {
                    LPI_WithoutSharingUtility.insertSObjectList(associatedLocationList);
                }
            }
            
            if (!locationUpdateList.isEmpty() && !addressUpdateList.isEmpty()) {
                Set<Schema.location>locationUpdateSet =  new Set<Schema.Location>(locationUpdateList);
                LPI_WithoutSharingUtility.updateSObjectList(new List<Schema.location>(locationUpdateSet));
                
                Set<Schema.Address>addressUpdateSet =  new Set<Schema.Address>(addressUpdateList);
                LPI_WithoutSharingUtility.updateSObjectList(new List<Schema.Address>(addressUpdateSet));
            }
        } catch (Exception e) {
            LPI_ExceptionManager.logException(CLASS_NAME, 'saveAddresses', e);
            throw new LPI_Exception('Problem in Updating location or Address', e);
        }
    }
    
    private static void updateConsentFor(
        Schema.location location,
        String addressTypePCA,
        String addressTypeLA,
        String addressTypePDA,
        String locationType
    ) {
        if (addressTypePCA == locationType && addressTypeLA == locationType && addressTypePDA == locationType) {
            location.Consent_For__c = 'Primary Contact Address;License Address;Publicly Displayed Address';
        } else if (addressTypePCA == locationType && addressTypeLA == locationType) {
            location.Consent_For__c = 'Primary Contact Address;License Address';
        } else if (addressTypeLA == locationType && addressTypePDA == locationType) {
            location.Consent_For__c = 'License Address;Publicly Displayed Address';
        } else if (addressTypePCA == locationType && addressTypePDA == locationType) {
            location.Consent_For__c = 'Primary Contact Address;Publicly Displayed Address';
        } else if (addressTypePCA == locationType) {
            location.Consent_For__c = 'Primary Contact Address';
        } else if (addressTypeLA == locationType) {
            location.Consent_For__c = 'License Address';
        } else if (addressTypePDA == locationType) {
            location.Consent_For__c = 'Publicly Displayed Address';
        } else {
            location.Consent_For__c = null;
        }
    }
    
    private static Schema.Address createReferenceAddress(
        String street,
        String city,
        String country,
        String zipCode,
        String locationType,
        String statePicklistEdit,
        String stateTextEdit,
        String county
    ) {
        Schema.Address address = new Schema.Address();
        address.LocationType = locationType;
        address.Street = Street;
        address.City = city;
        address.CountryCode = country;
        address.PostalCode = zipCode;
        address.County__c = county;
        
        if (country == 'US') {
            address.Business_State__c = '';
            if (String.isNotBlank(statePicklistEdit)) {
                address.StateCode = statePicklistEdit;
            }
        } else {
            address.StateCode = '';
            address.Business_State__c = stateTextEdit;
        }
        return address;
    }
    
    private static Schema.Location createReferenceLocation(
        String accName,
        String locationType,
        String addressType,
        Map<String, Object> inputMap,
        String preffix
    ) {
        Schema.Location locationRec = new Schema.Location();
        locationRec.Name = accName + '-' + locationType;
        locationRec.LocationType = locationType;
        locationRec.Status__c = 'Closed';
        locationRec.OpenDate = System.today();
        locationRec.Latitude = inputMap.containsKey(preffix + 'Lat') ? (Decimal) inputMap.get(preffix + 'Lat') : null;
        locationRec.Longitude = inputMap.containsKey(preffix + 'Long')
            ? (Decimal) inputMap.get(preffix + 'Long')
            : null;
        if (String.isNotBlank(addressType)) {
            locationRec.Consent_For__c = addressType;
        }
        return locationRec;
    }
    
    private static AssociatedLocation createReferenceAssLocation(String accId, String locationId) {
        AssociatedLocation al = new AssociatedLocation();
        al.ParentRecordId = accId;
        al.LocationId = locationId;
        return al;
    }
    
   
    
    /**
* @author          		: MTX Group Inc
* @since 					: 10 May, 2023
* @description     		: This method is Used to fetch Application_Content__c record for Additional Information section in Personal Information
* @param inputMap 			: fetching all the input from Omniscript
* @param outMap			: Passing value to Omniscript
* @param parid				: PreliminaryApplicationRef Id
* @last modified by		: MTX Group Inc
* @last modified date		: (Add if modified by you)
* @last modified details	: (Add if modified by you)
*/
    
    private static void fetchAppContentRecordAndIdentificationCardDetails(
        Map<String, Object> inputMap,
        Map<String, Object> outMap
    ) {
        try {
            String parid = (String) inputMap.get('parid');
            String blId = (String) inputMap.get('blId');
            String accountId = (String) inputMap.get('accountId');
            if (parid == null) {
                return;
            }
            String fields =
                'Id, Feet__c, Inches__c, Hair_Color__c, Eye_Color__c, Stance__c,' +
                'Distinguishing_Characteristics__c, Lost__c, Draws__c,' +
                'Last_Bout__c, Result__c,' +
                'Medical_School_Name__c,' +
                'Graduated_Year__c, Degree__c, Preliminary_Application_Reference__r.Business_License__c,' +
                'Preliminary_Application_Reference__r.Amendment_Type__c,' +
                'Preliminary_Application_Reference__r.Regulatory_Authorization_Type__r.Name';
            String whereCondition =
                'Preliminary_Application_Reference__c = \'' +
                String.escapeSingleQuotes(parid) +
                '\' AND Section_Header__c = \'' +
                String.escapeSingleQuotes(PERSON_ADDITIONAL_INFO) +
                '\'';
            List<Application_Content__c> appContentList = LPI_ApplicationContentDAO.getApplicationContentByDymanicQuery(
                fields,
                whereCondition,
                '1',
                null,
                null
            );
            Application_Content__c appContent;
            if (appContentList.isEmpty() && String.isNotBlank(blId)) {
                appContent = LPI_ApplicationFlowUtility.createApplicationContentRecord(
                    String.escapeSingleQuotes(blId),
                    String.escapeSingleQuotes(parid)
                );
            } else if (!appContentList.isEmpty()) {
                appContent = appContentList[0];
            } else if (appContentList.isEmpty()) {
                appContent = createApplicationContentRecord(accountId, parid);
            }
            outMap.put('AppConId', appContent.Id);
            outMap.put('ATTFeet', appContent.Feet__c);
            outMap.put('ATTFeetNotReq', appContent.Feet__c);
            outMap.put('ATTInches', appContent.Inches__c);
            outMap.put('ATTInchesNotReq', appContent.Inches__c);
            
            outMap.put('InvestigatorHairColor', appContent.Hair_Color__c);
            outMap.put('ATTHairColor', appContent.Hair_Color__c);
            outMap.put('InvestigatorEyeColor', appContent.Eye_Color__c);
            outMap.put('ATTEyeColor', appContent.Eye_Color__c);
            outMap.put('ATTStance', appContent.Stance__c);
            outMap.put('ATTDistinguishingCharacteristics', appContent.Distinguishing_Characteristics__c);
            outMap.put('ATTHairColorNotReq', appContent.Hair_Color__c);
            outMap.put('ATTEyeColorNotReq', appContent.Eye_Color__c);
            outMap.put('ATTStanceNotReq', appContent.Stance__c);
            outMap.put('ATTDistinguishingCharacteristicsNotReq', appContent.Distinguishing_Characteristics__c);
            
            outMap.put('ATTAmateurResultLost', String.valueOf(appContent.Lost__c));
            outMap.put('ATTAmateurResultDraws', String.valueOf(appContent.Draws__c));
           
            outMap.put('ATTAmateurResultLostNotReq', String.valueOf(appContent.Lost__c));
            outMap.put('ATTAmateurResultDrawsNotReq', String.valueOf(appContent.Draws__c));
            
            outMap.put('ATTLastBoutDate', appContent.Last_Bout__c);
            outMap.put('ATTResult', appContent.Result__c);
           
            outMap.put('ATTNameofMedicalSchool', appContent.Medical_School_Name__c);
            outMap.put('ATTYearGraduated', appContent.Graduated_Year__c);
            outMap.put('ATTMedicalDegree', appContent.Degree__c);
            outMap.put('licensePermitNameId', appContent.Preliminary_Application_Reference__r.Business_License__c);
            outMap.put('parSubType', appContent.Preliminary_Application_Reference__r.Amendment_Type__c);
            outMap.put(
                'isContestant',
                ATHLETICS_CONTESTANT_SET.contains(
                    appContent.Preliminary_Application_Reference__r.Regulatory_Authorization_Type__r.Name
                ) &&
                !SET_OF_IDENTIFICATION_CARDS.contains(appContent.Preliminary_Application_Reference__r.Amendment_Type__c)
            );
            if (String.isNotBlank(accountId)) {
                List<String> fieldsOfIdCardList = new List<String>{
                    'Id',
                        'Federal_ID_Number__c',
                        'National_ID_Number__c'
                        };
                            String whereConditionOfIdCard = 'Contestant_Name__c = \'' + String.escapeSingleQuotes(accountId) + '\'';
               
            }
            for (String key : outMap.keySet()) {
                if (String.isBlank(String.valueOf(outMap.get(key)))) {
                    outMap.remove(key);
                }
            }
        } catch (Exception e) {
            LPI_ExceptionManager.logException(CLASS_NAME, 'fetchAppContentRecordAndIdentificationCardDetails', e);
        }
    }
    
    /**
* @author          		: MTX Group Inc
* @since 					: 10 May, 2023
* @description     		: This method is Used to upserting Application_Content__c record for Additional Information section in Personal Information
* @param inputMap 			: fetching all the input from Omniscript
* @param outMap			: Passing value to Omniscript
* @param parid				: PreliminaryApplicationRef Id
* @last modified by		:MTX Group Inc
* @last modified date		: (Add if modified by you)
* @last modified details	: (Add if modified by you)
*/
    private static void updateAppContentRecord(Map<String, Object> inputMap, Map<String, Object> outMap, String parid) {
        try {
            Map<String, object> personalInformation = (Map<String, object>) inputMap.get('PersonalInformation');
            Map<String, Object> heightWeightInfo = (Map<String, object>) personalInformation.get(
                'HeightWeightAdditionalInfoBlock'
            );
            String fields = 'Id, Section_Header__c, Preliminary_Application_Reference__c,Preliminary_Application_Reference__r.Amendment_Type__c';
            String whereCondition =
                'Preliminary_Application_Reference__c = \'' +
                String.escapeSingleQuotes(parid) +
                '\' AND Section_Header__c = \'' +
                PERSON_ADDITIONAL_INFO +
                '\'';
            List<Application_Content__c> appContentList = LPI_ApplicationContentDAO.getApplicationContentByDymanicQuery(
                fields,
                whereCondition,
                '1',
                null,
                null
            );
            String boardName = (String) inputMap.get('BoardName');
            String parType = (String) inputMap.get('parType');
            String AmendmentType = '';
            Application_Content__c appContent = new Application_Content__c();
            if (!appContentList.isEmpty()) {
                appContent.Id = appContentList[0].Id;
                AmendmentType = appContentList[0].Preliminary_Application_Reference__r.Amendment_Type__c;
            }
            
            appContent.Preliminary_Application_Reference__c = parid;
            appContent.Section_Header__c = PERSON_ADDITIONAL_INFO;
            Boolean isContestant = (Boolean) personalInformation.get('isContestant');
            if (!isContestant && boardName == 'Athletics') {
                Map<String, Object> heightWeightInfoNotReq = (Map<String, object>) heightWeightInfo.get(
                    'HeightWeightAdditionalInfoBlockCondIfNotReq'
                );
                if (heightWeightInfoNotReq != null) {
                    appContent.Feet__c = (String) heightWeightInfoNotReq.get('ATTFeetNotReq');
                    appContent.Inches__c = (String) heightWeightInfoNotReq.get('ATTInchesNotReq');
                    
                }
            } else {
                Map<String, Object> heightWeightInfoReq = (Map<String, object>) heightWeightInfo.get(
                    'HeightWeightAdditionalInfoBlockCondIfRequired'
                );
                if (heightWeightInfoReq != null) {
                    appContent.Feet__c = (String) heightWeightInfoReq.get('ATTFeet');
                    appContent.Inches__c = (String) heightWeightInfoReq.get('ATTInches');
                   
                }
            }
            if (boardName != 'Athletics') {
                Map<String, Object> PFIAdditionalInfoBlock = (Map<String, object>) personalInformation.get(
                    'PFIAdditionalInfoBlock'
                );
                if (PFIAdditionalInfoBlock != null) {
                    appContent.Hair_Color__c = (String) PFIAdditionalInfoBlock.get('InvestigatorHairColor');
                    appContent.Eye_Color__c = (String) PFIAdditionalInfoBlock.get('InvestigatorEyeColor');
                }
            } else {
                Map<String, Object> AthleticBoardBlock = (Map<String, object>) personalInformation.get(
                    'AthleticBoardBlock'
                );
                if (AthleticBoardBlock == null) {
                    return;
                } else if (isContestant) {
                    Map<String, Object> otherCharacteristicsReq = (Map<String, object>) AthleticBoardBlock.get(
                        'ATTOtherCharacteristicsAdditonalInfoReq'
                    );
                    if (otherCharacteristicsReq != null) {
                        appContent.Stance__c = (String) otherCharacteristicsReq.get('ATTStance');
                        appContent.Hair_Color__c = (String) otherCharacteristicsReq.get('ATTHairColor');
                        appContent.Eye_Color__c = (String) otherCharacteristicsReq.get('ATTEyeColor');
                        appContent.Distinguishing_Characteristics__c = (String) otherCharacteristicsReq.get(
                            'ATTDistinguishingCharacteristics'
                        );
                    }
                    
                    Map<String, Object> amateurResultReq = (Map<String, object>) AthleticBoardBlock.get(
                        'AmateurResultCondIfReq'
                    );
                    if (amateurResultReq != null) {
                        
                        appContent.Lost__c = String.isNotBlank((String) amateurResultReq.get('ATTAmateurResultLost')) ? Integer.valueOf(
                            (String) amateurResultReq.get('ATTAmateurResultLost')
                        ): null;
                        appContent.Draws__c = String.isNotBlank((String) amateurResultReq.get('ATTAmateurResultDraws')) ? Integer.valueOf(
                            (String) amateurResultReq.get('ATTAmateurResultDraws')
                        ) : null;
                       
                        if (String.isNotBlank((String) amateurResultReq.get('YearsOfExperience'))) {
                           
                        }
                    }
                    
                    Map<String, Object> emergencyDetailsMap = (Map<String, object>) AthleticBoardBlock.get(
                        'AthleticsBoardOptionalElementsBlock'
                    );
                   
                } else {
                    Map<String, Object> otherCharacteristicsReq = (Map<String, object>) AthleticBoardBlock.get(
                        'ATTOtherCharacteristicsAdditonalInfoNotReq'
                    );
                    if (otherCharacteristicsReq != null) {
                        appContent.Stance__c = (String) otherCharacteristicsReq.get('ATTStanceNotReq');
                        appContent.Hair_Color__c = (String) otherCharacteristicsReq.get('ATTHairColorNotReq');
                        appContent.Eye_Color__c = (String) otherCharacteristicsReq.get('ATTEyeColorNotReq');
                        appContent.Distinguishing_Characteristics__c = (String) otherCharacteristicsReq.get(
                            'ATTDistinguishingCharacteristicsNotReq'
                        );
                    }
                    
                    Map<String, Object> amateurResultNotReq = (Map<String, object>) AthleticBoardBlock.get(
                        'AmateurResultCondNotReq'
                    );
                    if (amateurResultNotReq != null) {
                        if (amateurResultNotReq.get('ATTAmateurResultWonNotReq') != null) {
                           
                        }
                        if (amateurResultNotReq.get('ATTAmateurResultLostNotReq') != null) {
                            appContent.Lost__c = Integer.valueOf(
                                (String) amateurResultNotReq.get('ATTAmateurResultLostNotReq')
                            );
                        }
                        if (amateurResultNotReq.get('ATTAmateurResultDrawsNotReq') != null) {
                            appContent.Draws__c = Integer.valueOf(
                                (String) amateurResultNotReq.get('ATTAmateurResultDrawsNotReq')
                            );
                        }
                    }
                }
                if (
                    inputMap.get('regAuthTypeName') == 'Boxing Contestant' ||
                    (String.isNotBlank(AmendmentType) && AmendmentType.equalsIgnoreCase(BOXER_FEDERAL_ID_CARD))
                ) {
                    Map<String, Object> boxerDetailsMap = (Map<String, object>) AthleticBoardBlock.get(
                        'ATTBoxerDetailsBlock'
                    );
                    appContent.Last_Bout__c = String.isNotBlank((String) boxerDetailsMap.get('ATTLastBoutDate')) ? Date.valueOf((String) boxerDetailsMap.get('ATTLastBoutDate')) : null;
                    appContent.Result__c = (String) boxerDetailsMap.get('ATTResult');
                } else if (inputMap.get('regAuthTypeName') == 'Athletic-Physician') {
                    Map<String, Object> ATTPhysiciansDetailsBlock = (Map<String, object>) AthleticBoardBlock.get(
                        'ATTPhysiciansDetailsBlock'
                    );
                   
                        appContent.Medical_School_Name__c = null;
                        appContent.Graduated_Year__c = null;
                        appContent.Degree__c = null;
                }
            }
            appContent = (Application_Content__c) LPI_DML.doUpsert(appContent);
            outMap.put('AppConId', appContent.Id);
        } catch (Exception e) {
            LPI_ExceptionManager.logException(CLASS_NAME, 'updateAppContentRecord', e);
        }
    }
    /**
* @author          					: MTX Group Inc
* @since 								: 19 July, 2023
* @description     					: This method is Used to update the Account fields based on citizenship value
* @param personalInformation 			: Map<String, Object> step data
* @param accountId						: String
* @param acc							: Account
* @last modified by					: MTX Group Inc
* @last modified date					: (Add if modified by you)
* @last modified details				: (Add if modified by you)
*/
    private static void saveCitizenshipDetails(
        Map<String, Object> personalInformation,
        String accountId,
        PreliminaryApplicationRef acc,
        Boolean isNewApplication,
        Boolean isMigratedData
    ) {
        try {
            Map<String, Object> editBlockDetails = new Map<String, Object>();
            String citizenShip;
            String proofOfCitizenship;
            String proofOfWorkPermit;
            if (!personalInformation.isEmpty() && (isNewApplication != null)) {
                Boolean isEdit = isNewApplication
                    ? isNewApplication
                    : personalInformation.get('EditBlockDetails') != null ? true : false;
               
                editBlockDetails = isNewApplication
                    ? (Map<String, Object>) personalInformation.get('EditBlockDetails')
                    : ((isMigratedData != null && isMigratedData) &&
                       personalInformation.get('EditBlockDetails') != null)
                ? (Map<String, Object>) personalInformation.get('EditBlockDetails')
                    : (Map<String, Object>) personalInformation.get('ReadBlockDetails');
                if (editBlockDetails != null) {
                   
                    citizenShip = isEdit
                        ? (String) editBlockDetails.get('CitizinshipStatus')
                        : (String) editBlockDetails.get('CitizinshipStatusRO');
                    proofOfCitizenship = isEdit
                        ? (String) editBlockDetails.get('ProofOfCitizenshipIfUS')
                        : (String) editBlockDetails.get('ProofOfCitizenshipIfUSRO');
                    proofOfWorkPermit = isEdit
                        ? (String) editBlockDetails.get('ProofOfCitizenshipIfForeign')
                        : (String) editBlockDetails.get('ProofOfCitizenshipIfForeignRO');
                    Map<String, Object> childBlockDetails = new Map<String, Object>();
                   
                    acc.Citizenship__c = citizenShip;
                    if (citizenShip == UNITED_STATES) {
                        if (proofOfCitizenship.equalsIgnoreCase(NATURALIZATION)) {
                            childBlockDetails = isEdit
                                ? (Map<String, Object>) editBlockDetails.get('POCIfNaturalizationBlock')
                                : (Map<String, Object>) editBlockDetails.get('POCIfNaturalizationBlockRO');
                            if (isEdit) {
                                acc.Naturalization_Number__c = (String) childBlockDetails.get('NaturalizationNumber');
                                
                                acc.USCIS_Number__c = (String) childBlockDetails.get('UCSICNumber');
                            } else {
                                acc.Naturalization_Number__c = (String) childBlockDetails.get('NaturalizationNumberRO');
                               
                                acc.USCIS_Number__c = (String) childBlockDetails.get('UCSICNumberRO');
                            }
                        }
                        acc.Proof_of_Citizenship__c = proofOfCitizenship;
                       
                        acc.Proof_of_work_permit_in_United_States__c = '';
                        acc.H1B_Visa_Number__c = '';
                        acc.VISA_Number__c = '';
                        acc.US_Permanent_Resident_Card_Number__c = '';
                        acc.SEVIS_ID__c = '';
                       
                        acc.Passport_Number__c = '';
                    }
                   
                    else if (citizenShip == FOREIGN) {
                        
                        if (String.isNotBlank(proofOfWorkPermit)) {
                            if (VISA_PERMIT_SET.contains(proofOfWorkPermit)) {
                                childBlockDetails = isEdit
                                    ? (Map<String, Object>) editBlockDetails.get('VisaBlock')
                                    : (Map<String, Object>) editBlockDetails.get('VisaBlockRO');
                                if (isEdit) {
                                    acc.H1B_Visa_Number__c = (String) childBlockDetails.get('H1BVisaNumber');
                                    acc.VISA_Number__c = (String) childBlockDetails.get('VISANumber');
                                   
                                    acc.Passport_Number__c = (String) childBlockDetails.get('PassportNumber');
                                } else {
                                    acc.H1B_Visa_Number__c = (String) childBlockDetails.get('H1BVisaNumberRO');
                                    acc.VISA_Number__c = (String) childBlockDetails.get('VISANumberRO');
                                   
                                    acc.Passport_Number__c = (String) childBlockDetails.get('PassportNumberRO');
                                }
                                acc.US_Permanent_Resident_Card_Number__c = '';
                                acc.USCIS_Number__c = '';
                                acc.SEVIS_ID__c = '';
                               
                            } else if (US_RESIDENTS_SET.contains(proofOfWorkPermit)) {
                                childBlockDetails = isEdit
                                    ? (Map<String, Object>) editBlockDetails.get('ResidentBlock')
                                    : (Map<String, Object>) editBlockDetails.get('ResidentBlockRO');
                                if (isEdit) {
                                    acc.US_Permanent_Resident_Card_Number__c = (String) childBlockDetails.get(
                                        'USResidentCardNumber'
                                    );
                                    acc.USCIS_Number__c = (String) childBlockDetails.get('USCISNumber');
                                } else {
                                    acc.US_Permanent_Resident_Card_Number__c = (String) childBlockDetails.get(
                                        'USResidentCardNumberRO'
                                    );
                                    acc.USCIS_Number__c = (String) childBlockDetails.get('USCISNumberRO');
                                }
                                acc.SEVIS_ID__c = '';
                               
                                acc.Passport_Number__c = '';
                                acc.H1B_Visa_Number__c = '';
                                acc.VISA_Number__c = '';
                            } else if (STUDENT_VISA.equalsIgnoreCase(proofOfWorkPermit)) {
                                childBlockDetails = isEdit
                                    ? (Map<String, Object>) editBlockDetails.get('StudentVisaBlock')
                                    : (Map<String, Object>) editBlockDetails.get('PermanentResidentCardRO');
                                if (isEdit) {
                                    acc.SEVIS_ID__c = (String) childBlockDetails.get('StudentSevisID');
                                   
                                    acc.Passport_Number__c = (String) childBlockDetails.get('StudentPassportNumber');
                                  
                                } else {
                                    acc.SEVIS_ID__c = (String) childBlockDetails.get('StudentSevisIDRO');
                                   
                                    acc.Passport_Number__c = (String) childBlockDetails.get('StudentPassportNumberRO');
                                   
                                }
                                acc.H1B_Visa_Number__c = '';
                                acc.VISA_Number__c = '';
                                acc.US_Permanent_Resident_Card_Number__c = '';
                                acc.USCIS_Number__c = '';
                            }
                            acc.Proof_of_work_permit_in_United_States__c = proofOfWorkPermit;
                            acc.Proof_of_Citizenship__c = '';
                            acc.Naturalization_Number__c = '';
                           
                        }
                       
                        else {
                            acc.Proof_of_work_permit_in_United_States__c = '';
                            acc.H1B_Visa_Number__c = '';
                            acc.VISA_Number__c = '';
                            acc.US_Permanent_Resident_Card_Number__c = '';
                            acc.SEVIS_ID__c = '';
                           
                            acc.Passport_Number__c = '';
                            acc.USCIS_Number__c = '';
                        }
                    }
                   
                    acc.Id = accountId;
                    LPI_WithoutSharingUtility.updateSObject(acc);
                }
            }
        } catch (Exception e) {
            LPI_ExceptionManager.logException(CLASS_NAME, SAVE_CITIZENSHIP_DETAILS, e);
        }
    }
    
    /**
* @author          					: MTX Group Inc
* @since 								: 28 July, 2023
* @description     					: This method is Used to Check valid SSN Number
* @param socialSecurityNumber 			: String
* @param accountId						: String
* @param acc						    : Account
* @param outMap					    : Map<String, Object>
* @last modified by					: MTX Group Inc
* @last modified date					: (Add if modified by you)
* @last modified details				: (Add if modified by you)
*/
    
    private static void checkValidSSNNumberOnPersonalInfo(
        String socialSecurityNumber,
        String accountId,
        Account acc,
        Map<String, Object> outMap
    ) {
        try {
            LPI_AccountDAO.LPI_AccountWithoutSharingDAO accObj = new LPI_AccountDAO.LPI_AccountWithoutSharingDAO();
            List<Account> accList = accObj.getAccountByDymanicQuery(
                'Id,Social_Security_Number__c',
                'Social_Security_Number__c =\'' +
                String.escapeSingleQuotes(socialSecurityNumber) +
                '\'' +
                ' AND Id != \'' +
                String.escapeSingleQuotes(accountId) +
                '\'',
                null,
                null,
                null
            );
            if (!accList.isEmpty()) {
                outMap.put('isPersonInfoSSNDuplicate', true);
                return;
            }
            acc.Social_Security_Number__c = socialSecurityNumber;
        } catch (Exception e) {
            LPI_ExceptionManager.logException(CLASS_NAME, CHECK_VALID_SSN_NUMBER_DETAILS, e);
        }
    }
    
    /**
* @author          					: MTX Group Inc
* @since 								: 08 Aug, 2023
* @description     					: This method is Used to Check valid SSN Number
* @param accountId						: String
* @param outMap					    : Map<String, Object>
* @last modified by					: MTX Group Inc
* @last modified date					: (Add if modified by you)
* @last modified details				: (Add if modified by you)
*/
    @TestVisible
    private static Application_Content__c createApplicationContentRecord(String accountId, String parId) {
        try {
           
            String fields = 'Id, Feet__c, Inches__c, Hair_Color__c, Eye_Color__c, Stance__c, Distinguishing_Characteristics__c';
            String whereClause = 'Id = \'' + String.escapeSingleQuotes(accountId) + '\'';
            List<Account> accList = (List<Account>) (new LPI_AccountDAO.LPI_AccountWithoutSharingDAO())
                .getAccountByDymanicQuery(fields, whereClause, '1', null, null);
            Application_Content__c appContent = new Application_Content__c();
            if (!accList.isEmpty()) {
                Account acc = accList[0];
                appContent.Section_Header__c = PERSON_ADDITIONAL_INFO;
                appContent.Preliminary_Application_Reference__c = parId;
                appContent.Feet__c = acc.Feet__c;
                appContent.Inches__c = acc.Inches__c;
               
                appContent.Hair_Color__c = acc.Hair_Color__c;
                appContent.Eye_Color__c = acc.Eye_Color__c;
                appContent.Stance__c = acc.Stance__c;
                appContent.Distinguishing_Characteristics__c = acc.Distinguishing_Characteristics__c;
                
                LPI_DML.doUpsert(appContent);
            }
            return appContent;
        } catch (Exception e) {
            LPI_ExceptionManager.logException(CLASS_NAME, 'createApplicationContentRecord', e);
            return null;
        }
    }
    
    /**
* @author          					: MTX Group Inc
* @since 								: 16 Oct, 2023
* @description     					: This method is update lawful presence documents
* @param accountId						: String
* @param outMap					    : Map<String, Object>
* @last modified by					:MTX Group Inc

* @last modified date					: (Add if modified by you)
* @last modified details				: (Add if modified by you)
*/
    public static void lawfulPresenceDocConfiguration(String parId, String DocumentRequiredJSON) {
        try {
            if (String.isNotBlank(parId)) {
                String fields = ' BusinessAccountName.Citizenship__c, Proof_of_work_permit_in_United_States__c, BusinessAccountName.Proof_of_work_permit_in_United_States__c, Proof_of_Citizenship__c, BusinessAccountName.Proof_of_Citizenship__c, Type__c';
                String whereClause = 'Id = \'' + String.escapeSingleQuotes(parId) + '\'';
                List<PreliminaryApplicationRef> parList = LPI_PreliminaryApplicationRefDAO.getPreliminaryApplicationRefByDymanicQuery(
                    fields,
                    whereClause,
                    null,
                    null,
                    null
                );
                if (String.isNotBlank(DocumentRequiredJSON) && !parList.isEmpty()) {
                    Map<String, Object> docDataJson = (Map<String, Object>) JSON.deserializeUntyped(
                        DocumentRequiredJSON
                    );		
                    for (String key : docDataJson.keySet()) {
                        if ((Boolean) docDataJson.get(key) && key != 'MakeRequiredWhenFirstNameChange') {
                            
                        }
                    }	
                    LPI_UpdateDocumentData.updateApplicationDocument(parId, JSON.serialize(docDataJson));
                }
            }
        } catch (Exception e) {
            LPI_ExceptionManager.logException(CLASS_NAME, 'lawfulPresenceDocConfiguration', e);
        }
    }
    
    /**
* @author          					: MTX Group Inc
* @since 								: 22 Nov 2023
* @description     					: This method is used to check whether user enteres value in Address Type field or not
* @param inputMap						: Map<String, Object>
* @param outMap					    : Map<String, Object>
* @last modified by					: MTX Group Inc
* @last modified date					: (Add if modified by you)
* @last modified details				: (Add if modified by you)
*/
    public static void validationForAddressTypeField(Map<String,Object> inputMap, Map<String,Object> outMap) {
        try {
            Id parId = (Id) inputMap.get('parid');
            String boardName = (String)inputMap.get('BoardName');
            if(String.isNotBlank(parId))
            {
                PreliminaryApplicationRef par = new PreliminaryApplicationRef(id = parId) ;
                Map<String, object> personalInformation = (Map<String, object>) inputMap.get('PersonalInformation');
                Map<String, object> primaryContactAddressBlock = (Map<String, object>) personalInformation.get('PrimaryContactAddressBlock');
                string addressTypePCA;
                Map<String, object> addressTypePCAElementName;
                if(primaryContactAddressBlock != null && primaryContactAddressBlock.containsKey('AddressTypePCAElementName')){
                    addressTypePCAElementName = (Map<String, object>) primaryContactAddressBlock.get('AddressTypePCAElementName');
                    addressTypePCA = (String) addressTypePCAElementName.get('AddressTypePCA');
                    if(addressTypePCA != null)
                    {
                        outMap.put('ErrorInPCAField', false);
                        par.Primary_Contact_Address__c = addressTypePCA;
                        
                    }
                }else{
                    
                    outMap.put('ErrorInPCAField', true);
                }
                
                
             
                    Map<String, object> licenseAddressBlock = (Map<String, object>) personalInformation.get('LicenseAddressBlock');
                    string addressTypeLA;
                    Map<String, object> addressTypeLAElementName;
                    if(licenseAddressBlock != null && licenseAddressBlock.containsKey('AddressTypeLAElementName')){
                        addressTypeLAElementName = (Map<String, object>) licenseAddressBlock.get('AddressTypeLAElementName');
                        addressTypelA = (String) addressTypeLAElementName.get('AddressTypeLA');
                        if(addressTypeLA != null)
                        {
                            outMap.put('ErrorInLAField', false);
                            par.License_Address__c = addressTypeLA;
                            
                        }
                    }else{					
                        outMap.put('ErrorInLAField', true);
                    }  
                
                Map<String, object> publiclyDisplayedAddressBlock = (Map<String, object>) personalInformation.get('PubliclyDisplayedAddressBlock');
                string addressTypePDA;
                Map<String, object> addressTypePDAElementName;
                String regAuthTypeName = (String)inputMap.get('regAuthTypeName');
               
                    if(publiclyDisplayedAddressBlock != null &&  publiclyDisplayedAddressBlock.containsKey('AddressTypePDAElementName')){
                        addressTypePDAElementName = (Map<String, object>) publiclyDisplayedAddressBlock.get('AddressTypePDAElementName');
                        addressTypePDA = (String) addressTypePDAElementName.get('AddressTypePDA');
                        if(addressTypePDA != null)
                        {
                            outMap.put('ErrorInPDAField', false);					
                            par.Publicly_Displayed_Address__c = addressTypePDA;
                            
                        }
                    }else{
                        outMap.put('ErrorInPDAField', true);
                    }
               
                LPI_DML.doUpdate(par);
            }
        } catch (Exception e) {
            LPI_ExceptionManager.logException(CLASS_NAME, 'validatioForAddressTypeField', e);
        }
    }
    
    
}