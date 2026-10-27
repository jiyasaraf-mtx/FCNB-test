/**
 * @author          : Saurabh singh
 * @description     : This class fetch and Save all the Details of Employee Information Details standardize
 */
global with sharing class LPI_EmployeeInformation implements Callable {

    public final static String FETCH_EMPLOYEE_INFORMATION_DETAILS = 'fetchEmployeeInformationDetails';
    public final static String LICENSE_DETAILS = 'licenseDetails';
    public final static String SAVE_EMPLOYEE_INFORMATION_DETAILS = 'saveEmployeeInformationDetails';
    public final static String FETCH_EMPLOYEE_INFORMATION_PAGE_RELOAD = 'fetchEmployeeInformationPageReload';
    public final static String FETCH_EMPLOYEE_INFORMATION_REVIEW = 'fetchEmployeeInformationForReview';
    public final static String DELETE_EMPLOYEE_INFORMATION = 'deleteEmployeeInformation';
    public final static String UPSERT_ACCOUNT_CONTACT_RELATION = 'upsertAccountContactRelation';
    public final static String ANSWER_YES = 'AnswerYes';
    public final static String PAR_ID = 'parId';
    public final static String ROLES = 'Roles';
    public final static String LICENSED_IN_MISSOURI = 'LicensedInMissouri';
    public final static String YES = 'Yes';
    public final static String NO = 'No';
    public final static String ANSWER_BLOCK = 'AnswerYes-Block';
    public final static String ERROR_MESSAGE_DATA_NOT_SAVED = 'The details you have entered is not saved, please delete the existing details and add the correct Employee Information Details';
    public final static String CANNOT_DELETE_ACTIVE_ACR = 'You can not delete active relationship without approval ,If you want to deactivate relationship edit the record and uncheck the checkbox';
    public final static String CANNOT_LINK_PERSON_INCHARGE = 'Since the licensee has already been designated as the person in charge in the preceding step, there is no need to add them again at this stage.';
    public final static String CLASS_NAME = 'LPI_EmployeeInformation';
    public final static String SAVE_EMPLOYEE_INFORMATION = 'saveEmployeeInformationIds';
    private final static String INDIVIDAUL_LICENSE_APPTYPE = 'Individual';
    private final static String BUSINESS_LICENSE_APPTYPE = 'Business';
    private final static String SCHOOL_OF_BARBERING_LICENSE = 'School of Barbering';
    private final static String SCHOOL_OF_COSMETOLOGY_LICENSE = 'School of Cosmetology';
    private final static String SCHOOL_OF_COSMETOLOGY_BARBER_LICENSE = 'School of Cosmetology & Barbering';
    private final static String SATELLITE_CLASSROOM = 'Satellite Classroom';
    private final static Set<String> SCHOOL_OF_COSMETOLOGY_BARBER_SET = new Set<String>{
        'Barber Instructor',
        'Cosmetology Instructor',
        'Cosmetology/Barber Instructor'
    };
    private final static String EMPLOYEE_ALREADY_LINKED = 'Employee already linked you cannot link already linked Employee, Please try to link other Employee';
    private final static String COSMETOLOGY_AND_BARBER_EXAMINERS = 'Cosmetology & Barber Examiners';
    

    global Object call(String action, Map<String, Object> args) {
        Map<String, Object> input = (Map<String, Object>) args.get('input');
        Map<String, Object> output = (Map<String, Object>) args.get('output');
        Map<String, Object> options = (Map<String, Object>) args.get('options');
        return invokeMethod(action, input, output, options);
    }

    /**
     * @author               : MTX Group Product Team
     * @param methodName     : Method Name
     * @param inputMap       : Input Parameter Passed from Omniscript
     * @param outMap         : Output Passed to Omniscript
     * @param options        : Extra Options passed from Omniscript
     * @last modified by     : MTX Group Product Team
     * @last modified date   : 16 Jan, 2023
     * @modified details     : Optimized Code
     * @return  `Boolean`
     */
    private Boolean invokeMethod(
        String methodName,
        Map<String, Object> inputMap,
        Map<String, Object> outMap,
        Map<String, Object> options
    ) {
        if (methodName == FETCH_EMPLOYEE_INFORMATION_DETAILS) {
            outMap.put(
                LICENSE_DETAILS,
                fetchEmployeeInformationDetails(inputMap, outMap, options)
            );
        } else if (methodName == SAVE_EMPLOYEE_INFORMATION_DETAILS) {
            saveEmployeeInformationDetails(inputMap, outMap, options);
        } else if (methodName == FETCH_EMPLOYEE_INFORMATION_PAGE_RELOAD) {
            fetchEmployeeInformationPageReload(inputMap, outMap, options);
        } else if (methodName == FETCH_EMPLOYEE_INFORMATION_REVIEW) {
            fetchEmployeeInformationForReview(inputMap, outMap);
        } else if (methodName == DELETE_EMPLOYEE_INFORMATION) {
            deleteEmployeeInformation(inputMap, outMap);
        } else if (methodName == SAVE_EMPLOYEE_INFORMATION) {
            saveEmployeeInformationIds(inputMap, outMap);
        }
        return true;
    }

    /**
     * @author          	: MTX Group Product Team
     * @param inputMap  	: Input value passed from OS
     * @param outMap    	: Output value passed from here to OS
     * @param options   	: Options value passed from OS
     * @description     	: This Method Will fetch Employee Information on the basis of Business License Number
     * @last modified by    : MTX Group Product Team
     * @last modified date  :
     * @modified details    :
     */
    private static List<Map<String, object>> fetchEmployeeInformationDetails(
        Map<String, Object> inputMap,
        Map<String, Object> outMap,
        Map<String, Object> options
    ) {
        List<Map<String, Object>> licenseList;
        try {
            licenseList = new List<Map<String, Object>>();
            String parId = (String) options.get('parId');
            String licenseNumber =
                '%' +
                (String) options.get(String.escapeSingleQuotes(ANSWER_YES)) +
                '%';
            String licenseType;
            if (String.isNotBlank(parId)) {
                List<PreliminaryApplicationRef> par = LPI_PreliminaryApplicationRefDAO.getPreliminaryApplicationRefByDymanicQuery(
                    'Regulatory_Authorization_Type__r.Name',
                    'Id = \'' +
                    String.escapeSingleQuotes(parId) +
                    '\'',
                    null,
                    null,
                    null
                );
                
                if (!par.isEmpty()) {
                        licenseType = par[0]
                            .Regulatory_Authorization_Type__r.Name;
                }
            }
            String fieldsToQuery = 'Id,RegulatoryAuthorizationType.Name,Name,Account.Name,Account.PersonOtherCity,Account.PersonOtherState,Account.PersonOtherPostalCode,Account.PersonOtherStreet,Account.PersonOtherCountry,AccountId,License_Number_With_Rat_Name__c';
            String whereClause =
                    'Name LIKE \'' +
                    String.escapeSingleQuotes(licenseNumber) +
                    '\'' +
                    ' AND (RegulatoryAuthorizationType.Authorisation_Type__c = \'' +
                    String.escapeSingleQuotes(INDIVIDAUL_LICENSE_APPTYPE) +
                    '\' OR RegulatoryAuthorizationType.Authorisation_Type__c = \'' +
                    String.escapeSingleQuotes(BUSINESS_LICENSE_APPTYPE) + 
                    '\')';
                
            LPI_BusinessLicenseDAO.LPI_BusinessLicenseWithoutSharingDAO businessLicense = new LPI_BusinessLicenseDAO.LPI_BusinessLicenseWithoutSharingDAO();
            for (
                BusinessLicense bl : businessLicense.getBusinessLicenseByDymanicQueryWithoutSecurity(
                    fieldsToQuery,
                    whereClause,
                    '100',
                    null,
                    null
                )
            ) {
                Map<String, String> licenseMap = new Map<String, String>();
                licenseMap.put('NameEmployeeInformation', bl.Name);
                licenseMap.put('LicenseName', bl.Name);
                licenseMap.put(
                    'EITypeAheadKey',
                    bl.License_Number_With_Rat_Name__c
                );
                licenseMap.put(
                    'LicenseType',
                    bl.RegulatoryAuthorizationType.Name
                );
                licenseMap.put('NameIfAnsweredYes', bl.Account.Name);
                licenseMap.put('City', bl.Account.PersonOtherCity);
                licenseMap.put(
                    'StreetAddress1',
                    (bl.Account.PersonOtherStreet != null)
                        ? bl.Account.PersonOtherStreet
                        : ''
                );
                licenseMap.put('StateEmployeeInformation', bl.Account.PersonOtherState);
                licenseMap.put('CityEmployeeInformation', bl.Account.PersonOtherCity);
                licenseMap.put('Country', bl.Account.PersonOtherCountry);
                licenseMap.put('Zip', bl.Account.PersonOtherPostalCode);
                licenseMap.put('Selected_BL_AccountId', bl.AccountId);
                licenseList.add(licenseMap);
            }
        } catch (Exception e) {
            LPI_ExceptionManager.logException(
                CLASS_NAME,
                FETCH_EMPLOYEE_INFORMATION_DETAILS,
                e
            );
            throw new LPI_Exception('Problem in Fetching the deails', e);
        }
        return licenseList;
    }

    /**
     * @author              : MTX Group Product Team
     * @param inputMap      : Input value passed from OS
     * @param outMap        : Output value passed from here to OS
     * @param options       : Options value passed from here to OS
     * @description         : This method will save the detail of Newly added Employee Information
     * @last modified by    : MTX Group Product Team
     * @last modified date  :
     * @modified details    :
     */
    private static void saveEmployeeInformationDetails(
        Map<String, Object> inputMap,
        Map<String, Object> outMap,
        Map<String, Object> options
    ) {
        try {
            String parId = (String) options.get(
                String.escapeSingleQuotes(PAR_ID)
            );
            String roles = (String) options.get(
                String.escapeSingleQuotes(ROLES)
            );

            Id businessAccountId;
            String relatedFromLicenseNumber;
            List<PreliminaryApplicationRef> par;
            if (String.isNotBlank(parId)) {
                par = LPI_PreliminaryApplicationRefDAO.getPreliminaryApplicationRefByDymanicQuery(
                    'BusinessAccountNameId, Business_License__c ,Board_Name__c',
                    'Id = \'' +
                    String.escapeSingleQuotes(parId) +
                    '\'',
                    null,
                    null,
                    null
                );
                if (!par.isEmpty()) {
                    businessAccountId = par[0].BusinessAccountNameId;
                    if (String.isNotBlank(par[0].Business_License__c)) {
                        relatedFromLicenseNumber = par[0].Business_License__c;
                    }
                }
            }
            String licensedInMissouri = (String) inputMap.get(
                String.escapeSingleQuotes(LICENSED_IN_MISSOURI)
            );
            Boolean activelyAssociated = (Boolean) inputMap.get(
                String.escapeSingleQuotes('EmployeeActivelyAssociated')
            );
            if (
                (licensedInMissouri != null &&
                licensedInMissouri.equalsIgnoreCase(YES)) ||
                par[0].Board_Name__c == COSMETOLOGY_AND_BARBER_EXAMINERS || par[0].Board_Name__c == 'Veterinary'
            ) {
                Map<String, Object> answerYesBlock = (Map<String, Object>) inputMap.get(
                    String.escapeSingleQuotes('AnswerYes-Block')
                );
                String title = (String) answerYesBlock?.get('Title1');
                String licenseNumber = (String) answerYesBlock
                    ?.get('LicenseName');

                String recordId = (String) inputMap.get(
                    String.escapeSingleQuotes('Id')
                );

                boolean flag = true;
                if (answerYesBlock == null && String.isNotBlank(recordId)) {
                    upsertAccountContactRelation(
                        recordId,
                        null,
                        null,
                        null,
                        null,
                        null,
                        activelyAssociated,
                        true,
                        relatedFromLicenseNumber
                    );
                } else {
                    String accountId = (String) answerYesBlock.get(
                        String.escapeSingleQuotes('Selected_BL_AccountId')
                    );

                    if (String.isNotEmpty(recordId)) {
                        LPI_BusinessRelationshipDAO.LPI_BusinessRelationshipsWithoutSharingDAO withoutSharingACR = new LPI_BusinessRelationshipDAO.LPI_BusinessRelationshipsWithoutSharingDAO();
                        List<Business_Relationships__c> acr = withoutSharingACR.getBusinessRelationshipsByDymanicQuery(
                            'Title__c,License_Number__c',
                            'Id =\'' +
                            recordId +
                            '\'',
                            null,
                            null,
                            null
                        );
                        Business_Relationships__c accConRelation = new Business_Relationships__c(
                            Id = recordId
                        );
                        if (
                            LPI_WithoutSharingUtility.checkACRAccess(recordId)
                        ) {
                            if (acr[0].Title__c != title) {
                                accConRelation.Title__c = title;
                                LPI_WithoutSharingUtility.updateSObject(
                                    accConRelation
                                );
                                outMap.put('title', accConRelation.Title__c);
                                flag = false;
                            } else if (
                                acr[0].License_Number__c != licenseNumber
                            ) {
                                LPI_WithoutSharingUtility.deleteSObject(
                                    accConRelation
                                );
                                outMap.put('Id', null);
                                flag = true;
                            }
                        } else {
                            throw new LPI_Exception(
                                'You do not have access to perform this operation'
                            );
                        }
                    } else {
                        List<Business_Relationships__c> EmployeeACR = queryAccountContactRelation(
                            accountId,
                            businessAccountId,
                            'Employee',
                            null
                        );
                        if (!EmployeeACR.isEmpty()) {
                            throw new LPI_Exception(EMPLOYEE_ALREADY_LINKED);
                        }
                        Map<String, String> accountKeyMappingMap = new Map<String, String>{
                            'LicensedInMissouri' => 'LicensedInMissouri__c'
                        };
                        Account acc = (Account) LPI_VlocityUtility.createSObject(
                            inputMap,
                            accountKeyMappingMap,
                            'Account'
                        );
                        acc.put('id', accountId);
                        acc = (account) LPI_WithoutSharingUtility.upsertSObject(
                            acc
                        );
                    }
                    if (String.isBlank(recordId)) {
                        if (
                            accountId != null &&
                            businessAccountId != null &&
                            flag
                        ) {
                            List<Business_Relationships__c> personInchargeACR = queryAccountContactRelation(
                                accountId,
                                businessAccountId,
                                'Designated Incharge',
                                null
                            );

                            if (!personInchargeACR.isEmpty()) {
                                throw new LPI_Exception(
                                    CANNOT_LINK_PERSON_INCHARGE
                                );
                            } else {
                                Business_Relationships__c updatedaccConRelation = upsertAccountContactRelation(
                                    null,
                                    accountId,
                                    businessAccountId,
                                    roles,
                                    answerYesBlock,
                                    null,
                                    activelyAssociated,
                                    false,
                                    relatedFromLicenseNumber
                                );
                                outMap.put('Id', updatedaccConRelation.Id);
                            }
                            List<Business_Relationships__c> acr = queryAccountContactRelation(
                                accountId,
                                businessAccountId,
                                roles,
                                null
                            );

                            outMap.put('NameEmployeeInformation', acr[0].Related_To__r.Name);
                            outMap.put('LicType', acr[0].License_Type__c);
                            outMap.put('title', acr[0].Title__c);
                        }
                    }
                }
            } else if (
                licensedInMissouri.equalsIgnoreCase(NO) &&
                par[0].Board_Name__c != COSMETOLOGY_AND_BARBER_EXAMINERS 
            ) {
                String recordId = (String) inputMap.get('Id');
                Map<String, Object> answerNo = (Map<String, Object>) inputMap.get(
                    'AnswerNo'
                );
                String country = (String) answerNo.get('CountryIfAnsweredNo');
                Business_Relationships__c accConRelation;
                Map<String, String> keyMaping = new Map<String, String>{
                    'EmployeeNoFirstName' => 'FirstName',
                    'EmployeeNoMiddleName' => 'MiddleName',
                    'EmployeeNoLastName' => 'LastName',
                    'EmailIfAnsweredNo' => 'PersonEmail',
                    'TelephoneIfAnsweredNo' => 'PersonHomePhone'
                };

                Account acc = (Account) LPI_VlocityUtility.createSObject(
                    answerNo,
                    keyMaping,
                    'Account'
                );
                Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
                    .get(LPI_LiteralConstant.ACCOUNT_PERSON_RECORDTYPE)
                    .getRecordTypeId();
                acc.put('RecordTypeId', accRecordTypeId);
                List<Datacloud.MatchRecord> alreadyPresentAcc = new List<Datacloud.MatchRecord>();
                alreadyPresentAcc = LPI_WithoutSharingUtility.getDuplicateRecords(
                    new List<Account>{ acc }
                );
                if (String.isNotBlank(recordId)) {
                    LPI_BusinessRelationshipDAO.LPI_BusinessRelationshipsWithoutSharingDAO acrWithoutSharing = new LPI_BusinessRelationshipDAO.LPI_BusinessRelationshipsWithoutSharingDAO();
                    List<Business_Relationships__c> acrList = acrWithoutSharing.getBusinessRelationshipsByDymanicQuery(
                        'Id,Related_To__c',
                        'Id = \'' +
                        recordId +
                        '\'',
                        null,
                        null,
                        null
                    );
                    LPI_AccountDAO.LPI_AccountWithoutSharingDAO withoutSharingAccountList = new LPI_AccountDAO.LPI_AccountWithoutSharingDAO();
                    List<Account> personAccountList = withoutSharingAccountList.getAccountByDymanicQuery(
                        'Id',
                        'Id = \'' +
                        acrList[0].Related_To__c +
                        '\'',
                        null,
                        null,
                        null
                    );

                    if (
                        alreadyPresentAcc.isEmpty() ||
                        personAccountList[0].Id ==
                        alreadyPresentAcc[0].getRecord().Id
                    ) {
                        accConRelation = upsertAccountContactRelation(
                            recordId,
                            null,
                            null,
                            null,
                            null,
                            answerNo,
                            activelyAssociated,
                            true,
                            relatedFromLicenseNumber
                        );
                        if (accConRelation != null) {
                            acc.put('Id', personAccountList[0].Id);
                            acc.put(
                                'LicensedInMissouri__c',
                                licensedInMissouri
                            );
                            LPI_WithoutSharingUtility.updateSObject(acc);
                        }

                        outMap.put('Id', accConRelation.Id);
                        if (acc.MiddleName != null) {
                            outMap.put(
                                'NameEmployeeInformation',
                                acc.FirstName +
                                ' ' +
                                acc.MiddleName +
                                ' ' +
                                acc.LastName
                            );
                        } else {
                            outMap.put(
                                'NameEmployeeInformation',
                                acc.FirstName +
                                ' ' +
                                acc.LastName
                            );
                        }
                        outMap.put('LicType', accConRelation.License_Type__c);
                        outMap.put('title', accConRelation.Title__c);
                    } else if (
                        !alreadyPresentAcc.isEmpty() &&
                        personAccountList[0].Id !=
                        alreadyPresentAcc[0].getRecord().Id
                    ) {
                        Boolean aCRAlreadyExist = false;
                        if (!alreadyPresentAcc.isEmpty()) {
                            List<Business_Relationships__c> accountContactRelationExist = queryAccountContactRelation(
                                alreadyPresentAcc[0].getRecord().Id,
                                businessAccountId,
                                null,
                                false
                            );
                            if (!accountContactRelationExist.isEmpty()) {
                                aCRAlreadyExist = true;
                                outMap.put(
                                    'LicType',
                                    ERROR_MESSAGE_DATA_NOT_SAVED
                                );
                                outMap.put('ACRAlreadyExist', aCRAlreadyExist);
                            }
                        }
                        if (aCRAlreadyExist == false) {
                            acc.put('Id', personAccountList[0].Id);
                            LPI_WithoutSharingUtility.updateSObject(acc);
                            accConRelation = upsertAccountContactRelation(
                                recordid,
                                null,
                                null,
                                null,
                                null,
                                answerNo,
                                activelyAssociated,
                                true,
                                relatedFromLicenseNumber
                            );
                        }
                    }
                } else {
                    if (!alreadyPresentAcc.isEmpty()) {
                        acc.id = alreadyPresentAcc[0].getrecord().id;
                    }
                    acc.put('RecordTypeId', accRecordTypeId);
                    acc.put('LicensedInMissouri__c', licensedInMissouri);
                    LPI_WithoutSharingUtility.upsertSObject(acc);
                    Boolean aCRAlreadyExist = false;
                    List<Business_Relationships__c> accountContactRelationExist = queryAccountContactRelation(
                        acc.id,
                        businessAccountId,
                        null,
                        null
                    );
                    if (!accountContactRelationExist.isEmpty()) {
                        aCRAlreadyExist = true;
                        outMap.put('LicType', ERROR_MESSAGE_DATA_NOT_SAVED);
                        outMap.put('ACRAlreadyExist', aCRAlreadyExist);
                    }
                    if (aCRAlreadyExist == false) {
                        accConRelation = upsertAccountContactRelation(
                            null,
                            acc.id,
                            businessAccountId,
                            roles,
                            null,
                            answerNo,
                            activelyAssociated,
                            false,
                            relatedFromLicenseNumber
                        );
                        outMap.put('Id', accConRelation.Id);
                        if (acc.MiddleName != null) {
                            outMap.put(
                                'NameEmployeeInformation',
                                acc.FirstName +
                                ' ' +
                                acc.MiddleName +
                                ' ' +
                                acc.LastName
                            );
                        } else {
                            outMap.put(
                                'NameEmployeeInformation',
                                acc.FirstName +
                                ' ' +
                                acc.LastName
                            );
                        }
                        outMap.put('LicType', accConRelation.License_Type__c);
                        outMap.put('title', accConRelation.Title__c);
                    }
                }
            }
        } catch (Exception e) {
            if (e.getMessage() == CANNOT_LINK_PERSON_INCHARGE) {
                throw new LPI_Exception(CANNOT_LINK_PERSON_INCHARGE, e);
            } else if (e.getMessage() == EMPLOYEE_ALREADY_LINKED) {
                throw new LPI_Exception(EMPLOYEE_ALREADY_LINKED, e);
            }
            LPI_ExceptionManager.logException(
                CLASS_NAME,
                SAVE_EMPLOYEE_INFORMATION_DETAILS,
                e
            );
            throw new LPI_Exception(
                'Problem in saving the the Employee Information details',
                e
            );
        }
    }

    /**
     * @author          	: MTX Group Product Team
     * @param inputMap  	: fetching all the input from Omniscript
     * @param outMap    	: Passing value to Omniscript
     * @description     	: This Method will delete ACR When user delete record from Portal
     * @last modified by    : MTX Group Product Team
     * @last modified date  :
     * @modified details    :
     */

    private static void deleteEmployeeInformation(
        Map<String, Object> inputMap,
        Map<String, Object> outMap
    ) {
        try {
            String recordId = (String) inputMap.get('Id');
            String errorMessage = (String) inputMap.get('LicType');
            Boolean aCRAlreadyExist = false;

            if (String.isNotBlank(recordId)) {
                LPI_BusinessRelationshipDAO.LPI_BusinessRelationshipsWithoutSharingDAO selectorInstance = new LPI_BusinessRelationshipDAO.LPI_BusinessRelationshipsWithoutSharingDAO();
                List<Business_Relationships__c> acrActiveList = selectorInstance.getBusinessRelationshipsByDymanicQuery(
                    'Id',
                    'Id = \'' +
                    recordId +
                    '\'' +
                    'AND IsActive__c = true',
                    null,
                    null,
                    null
                );
                List<Map<String, Object>> deleteActiveACRList = new List<Map<String, Object>>();
                if (!acrActiveList.isEmpty()) {
                    throw new LPI_Exception(CANNOT_DELETE_ACTIVE_ACR);
                } else if (
                    acrActiveList.isEmpty() && String.isNotBlank(recordId)
                ) {
                    Business_Relationships__c accConRelation = new Business_Relationships__c();
                    accConRelation.Id = recordId;
                    if (LPI_WithoutSharingUtility.checkACRAccess(recordId)) {
                        LPI_WithoutSharingUtility.deleteSObject(
                            accConRelation
                        );
                    } else {
                        throw new LPI_Exception(
                            'You do not access to perform this operation'
                        );
                    }
                }
                if (
                    errorMessage != null &&
                    errorMessage.equalsIgnoreCase(ERROR_MESSAGE_DATA_NOT_SAVED)
                ) {
                    outMap.put('ACRAlreadyExist', aCRAlreadyExist);
                }
            }
        } catch (Exception e) {
            if (e.getMessage() == CANNOT_DELETE_ACTIVE_ACR) {
                throw new LPI_Exception(CANNOT_DELETE_ACTIVE_ACR, e);
            }
            LPI_ExceptionManager.logException(
                CLASS_NAME,
                DELETE_EMPLOYEE_INFORMATION,
                e
            );
            throw new LPI_Exception(
                'Problem occured in deleting the record please contact admin',
                e
            );
        }
    }

    /**
     * @author              : MTX Group Product Team
     * @param inputMap      : Input value passed from OS
     * @param outMap        : Output value passed from here to OS
     * @param options       : Options value passed from here to OS
     * @description         : Fetching Employee information once page reload by user
     * @last modified by    : MTX Group Product Team
     * @last modified date  :
     * @modified details    :
     */
    private static List<Map<String, Object>> fetchEmployeeInformationPageReload(
        Map<String, Object> inputMap,
        Map<String, Object> outMap,
        Map<String, Object> options
    ) {
        List<Map<String, Object>> employeeInformationList;
        try {
            String parId = (String) options.get('parId');
            String roles = (String) inputMap.get('Roles');
            String selectedRole;
            Id businessAccountId;
            if (
                roles.equalsIgnoreCase(
                    LPI_LiteralConstant.FUNERAL_ESTABLISHMENT_EMPLOYEE
                )
            ) {
                selectedRole = LPI_LiteralConstant.FUNERAL_ESTABLISHMENT_EMPLOYEE;
            } else if (roles.equalsIgnoreCase(LPI_LiteralConstant.ROLE_EMPLOYEE)) {
                selectedRole = LPI_LiteralConstant.ROLE_EMPLOYEE;
            }

            List<PreliminaryApplicationRef> par = LPI_PreliminaryApplicationRefDAO.getPreliminaryApplicationRefByDymanicQuery(
                'BusinessAccountNameId,Board_Name__c',
                'Id = \'' +
                String.escapeSingleQuotes(parId) +
                '\'',
                null,
                null,
                null
            );
            if (!par.isEmpty()) {
                businessAccountId = par[0].BusinessAccountNameId;
            }
            LPI_BusinessRelationshipDAO.LPI_BusinessRelationshipsWithoutSharingDAO acrWithoutSharing = new LPI_BusinessRelationshipDAO.LPI_BusinessRelationshipsWithoutSharingDAO();
            employeeInformationList = new List<Map<String, Object>>();
            for (
                Business_Relationships__c acr : acrWithoutSharing.getBusinessRelationshipsByDymanicQuery(
                    'ID,Related_To__r.LicensedInMissouri__c,Title__c,License_Type__c,License_Number__c,If_Relationship_is_Associated_with_you__c,IsActive__c,Related_To__r.PersonOtherStreet,Related_To__r.Name,' +
                    'Related_To__r.FirstName,Related_To__r.MiddleName,Related_To__r.LastName,Related_To__r.PersonOtherCountry,Related_To__r.PersonOtherStateCode,Related_To__r.PersonOtherState,Related_To__r.PersonOtherPostalCode,' +
                    'Related_To__r.PersonOtherCity,Related_To__r.Other_State__c,Related_To__r.PersonOtherCountryCode,Related_To_License_Number__r.License_Number_With_Rat_Name__c, Related_To__r.PersonEmail, Related_To__r.PersonHomePhone',
                    'Related_From__c = \'' +
                    String.escapeSingleQuotes(businessAccountId) +
                    '\'' +
                    ' AND Roles__c = \'' +
                    String.escapeSingleQuotes(selectedRole) +
                    '\'' +
                    ' AND ((IsActive__c = FALSE AND Start_Date__c = null) OR (IsActive__c = TRUE AND EndDate__c = null))',
                    null,
                    null,
                    null
                )
            ) {
                if (
                    acr.Related_To__r.LicensedInMissouri__c == YES ||
                    par[0].Board_Name__c == COSMETOLOGY_AND_BARBER_EXAMINERS
                ) {
                    Map<String, Object> singleEmployeeInformation = new Map<String, Object>();
                    singleEmployeeInformation.put(
                        'State',
                        acr.Related_To__r.PersonOtherState
                    );
                    singleEmployeeInformation.put(
                        'StateReview',
                        acr.Related_To__r.PersonOtherState
                    );
                    singleEmployeeInformation.put(
                        'City',
                        acr.Related_To__r.PersonOtherCity
                    );
                    singleEmployeeInformation.put(
                        'Country',
                        acr.Related_To__r.PersonOtherCountry
                    );
                    singleEmployeeInformation.put(
                        'Zip',
                        acr.Related_To__r.PersonOtherPostalCode
                    );
                    singleEmployeeInformation.put(
                        'NameIfAnsweredYes',
                        acr.Related_To__r.Name
                    );
                    singleEmployeeInformation.put('Title1', acr.Title__c);
                    singleEmployeeInformation.put(
                        'Selected_BL_AccountId',
                        acr.Related_To__c
                    );
                    singleEmployeeInformation.put(
                        'AnswerYes',
                        acr.Related_To_License_Number__r.License_Number_With_Rat_Name__c
                    );
                    singleEmployeeInformation.put(
                        'LicenseName',
                        acr.License_Number__c
                    );
                    singleEmployeeInformation.put(
                        'LicenseType',
                        acr.License_Type__c
                    );
                    singleEmployeeInformation.put(
                        'StreetAddress1',
                        acr.Related_To__r.PersonOtherStreet
                    );
                    Map<String, Object> readOnlySingleEmployeeInformation = new Map<String, Object>();
                    readOnlySingleEmployeeInformation.put(
                        'StateReadOnly',
                        acr.Related_To__r.PersonOtherState
                    );
                    readOnlySingleEmployeeInformation.put(
                        'StreetAddressReadOnly',
                        acr.Related_To__r.PersonOtherStreet
                    );
                    readOnlySingleEmployeeInformation.put(
                        'CityReadOnly',
                        acr.Related_To__r.PersonOtherCity
                    );
                    readOnlySingleEmployeeInformation.put(
                        'CountryReadOnly',
                        acr.Related_To__r.PersonOtherCountry
                    );
                    readOnlySingleEmployeeInformation.put(
                        'ZipReadOnly',
                        acr.Related_To__r.PersonOtherPostalCode
                    );
                    readOnlySingleEmployeeInformation.put(
                        'NameReadOnly',
                        acr.Related_To__r.Name
                    );
                    readOnlySingleEmployeeInformation.put(
                        'TitleReadOnly',
                        acr.Title__c
                    );
                    readOnlySingleEmployeeInformation.put(
                        'LicenseNumberReadOnly',
                        acr.License_Number__c
                    );
                    readOnlySingleEmployeeInformation.put(
                        'LicenseTypeReadOnly',
                        acr.License_Type__c
                    );

                    Map<String, Object> internalSingleEmployeeInformation = new Map<String, Object>();
                    internalSingleEmployeeInformation.put(
                        'LicensedInMissouri',
                        acr.Related_To__r.LicensedInMissouri__c
                    );

                    internalSingleEmployeeInformation.put(
                        'EmployeeActivelyAssociated',
                        acr.If_Relationship_is_Associated_with_you__c
                    );
                    internalSingleEmployeeInformation.put(
                        'IsActive',
                        acr.IsActive__c
                    );
                    internalSingleEmployeeInformation.put('Id', acr.Id);
                    internalSingleEmployeeInformation.put(
                        'NameEmployeeInformation',
                        acr.Related_To__r.Name
                    );
                    internalSingleEmployeeInformation.put(
                        'LicType',
                        acr.License_Type__c
                    );
                    internalSingleEmployeeInformation.put(
                        'title',
                        acr.Title__c
                    );
                    internalSingleEmployeeInformation.put(
                        'AnswerYes-Block',
                        singleEmployeeInformation
                    );
                    internalSingleEmployeeInformation.put(
                        'ReadOnlyBlock',
                        readOnlySingleEmployeeInformation
                    );
                    internalSingleEmployeeInformation.put(
                        'ACRAlreadyExist',
                        false
                    );
                    internalSingleEmployeeInformation.put(
                        'linkingHimself',
                        false
                    );
                    internalSingleEmployeeInformation.put(
                        'PersonInchargeLinked',
                        false
                    );
                    employeeInformationList.add(
                        internalSingleEmployeeInformation
                    );
                } else if (acr.Related_To__r.LicensedInMissouri__c == NO) {
                    Map<String, Object> singleEmployeeInformationNo = new Map<String, Object>();
                    singleEmployeeInformationNo.put(
                        'EmailIfAnsweredNo',
                        acr.Related_To__r.PersonEmail
                    );
                    singleEmployeeInformationNo.put(
                        'TelephoneIfAnsweredNo',
                        acr.Related_To__r.PersonHomePhone
                    );
                    singleEmployeeInformationNo.put(
                        'EmployeeNoFirstName',
                        acr.Related_To__r.FirstName
                    );
                    singleEmployeeInformationNo.put(
                        'EmployeeNoMiddleName',
                        acr.Related_To__r.MiddleName
                    );
                    singleEmployeeInformationNo.put(
                        'EmployeeNoLastName',
                        acr.Related_To__r.LastName
                    );
                    singleEmployeeInformationNo.put(
                        'TitleIfAnsweredNo',
                        acr.Title__c
                    );
                    singleEmployeeInformationNo.put(
                        'Selected_BL_AccountId',
                        acr.Related_To__c
                    ); 
                    singleEmployeeInformationNo.put(
                        'LicenseNumberIfAnsweredNo',
                        acr.License_Number__c
                    );
                    singleEmployeeInformationNo.put(
                        'LicenseTypeIfAnsweredNo',
                        acr.License_Type__c
                    );
                    Map<String, Object> internalSingleEmployeeInformationNo = new Map<String, Object>();
                    internalSingleEmployeeInformationNo.put(
                        'LicensedInMissouri',
                        acr.Related_To__r.LicensedInMissouri__c
                    );
                    internalSingleEmployeeInformationNo.put(
                        'EmployeeActivelyAssociated',
                        acr.If_Relationship_is_Associated_with_you__c
                    );
                    internalSingleEmployeeInformationNo.put(
                        'IsActive',
                        acr.IsActive__c
                    );
                    internalSingleEmployeeInformationNo.put('Id', acr.Id);
                    internalSingleEmployeeInformationNo.put(
                        'NameEmployeeInformation',
                        acr.Related_To__r.Name
                    );
                    internalSingleEmployeeInformationNo.put(
                        'LicType',
                        acr.License_Type__c
                    );
                    internalSingleEmployeeInformationNo.put(
                        'title',
                        acr.Title__c
                    );
                    internalSingleEmployeeInformationNo.put(
                        'AnswerNo',
                        singleEmployeeInformationNo
                    );
                    internalSingleEmployeeInformationNo.put(
                        'ACRAlreadyExist',
                        false
                    );
                    internalSingleEmployeeInformationNo.put(
                        'linkingHimself',
                        false
                    );
                    internalSingleEmployeeInformationNo.put(
                        'PersonInchargeLinked',
                        false
                    );
                    employeeInformationList.add(
                        internalSingleEmployeeInformationNo
                    );
                }
            }
            if (!employeeInformationList.isEmpty()) {
                outMap.put(
                    'AddEmployeeInformationDetails',
                    employeeInformationList
                );
            }
        } catch (Exception e) {
            LPI_ExceptionManager.logException(
                CLASS_NAME,
                FETCH_EMPLOYEE_INFORMATION_PAGE_RELOAD,
                e
            );
            throw new LPI_Exception(
                'Problem in fetching the the Employee Information details',
                e
            );
        }

        return employeeInformationList;
    }
    /**
     * @author              : MTX Group Product Team
     * @param obj           : object
     * @description         : This Method will tell us weather deserialize object is Map or not
     * @last modified by    : MTX Group Product Team
     * @last modified date  :
     * @modified details    :
     */
    private static Boolean isMap(Object obj) {
        String str, firstCharacter, lastCharacter;
        if (obj != null) {
            str = String.valueOf(obj);
            firstCharacter = str.substring(0, 1);
            lastCharacter = str.substring(str.length() - 1, str.length());
        }

        return !(obj instanceof String) &&
            '{'.equals(firstCharacter) &&
            '}'.equals(lastCharacter);
    }

    /**
     * @author              : MTX Group Product Team
     * @param inputMap      : Input value passed from OS
     * @param outMap        : Output value passed from here to OS
     * @description         : Fetching Employee information For Review Page
     * @last modified by    : MTX Group Product Team
     * @last modified date  :
     * @modified details    :
     */
    public static List<Map<String, Object>> fetchEmployeeInformationForReview(
        Map<String, Object> inputMap,
        Map<String, Object> outMap
    ) {
        List<Map<String, Object>> employeeInformationList;
        try {
            String parId = (String) inputMap.get('parId');
            String parId_Support_Staff, whereClause;
            if (parId == null) {
                parId_Support_Staff = (String) inputMap.get(
                    'parIdSupportStaff'
                );
            }
            Sobject obj;
            List<PreliminaryApplicationRef> parList;
            if (String.isNotEmpty(parId)) {
                parList = LPI_PreliminaryApplicationRefDAO.getPreliminaryApplicationRefByDymanicQuery(
                    'Id, Employee_Information_ACR_Ids__c,Board_Name__c,Regulatory_Authorization_Type__r.Name',
                    'Id = \'' +
                    String.escapeSingleQuotes(parId) +
                    '\'',
                    null,
                    null,
                    null
                );
                if (!parList.isEmpty()) {
                    obj = parList[0];
                }
            }

            if (parList != null) {
                String employeeInformationAcrIds = parList[0]
                    .Employee_Information_ACR_Ids__c;

                List<String> allIds = new List<String>();
                if (!String.isBlank(employeeInformationAcrIds)) {
                    if (employeeInformationAcrIds.contains(',')) {
                        allIds = employeeInformationAcrIds.split(',');
                    } else {
                        allIds.add(employeeInformationAcrIds);
                    }
                }
                employeeInformationList = new List<Map<String, Object>>();
                if (!allIds.isEmpty()) {
                    LPI_BusinessRelationshipDAO.LPI_BusinessRelationshipsWithoutSharingDAO acrWithoutSharing = new LPI_BusinessRelationshipDAO.LPI_BusinessRelationshipsWithoutSharingDAO();
                    for (
                        Business_Relationships__c acr : acrWithoutSharing.getBusinessRelationshipsByDymanicQuery(
                            'ID,Related_To__r.LicensedInMissouri__c,Title__c,License_Type__c,License_Number__c,If_Relationship_is_Associated_with_you__c,Related_To__r.PersonOtherStreet,Related_To__r.Name,' +
                            'Related_To__r.PersonOtherCountry,Related_To__r.PersonOtherStateCode,Related_To__r.PersonOtherState,Related_To__r.PersonOtherPostalCode,Related_To__r.PersonOtherCity,' +
                            'Related_To__r.Other_State__c,Related_To__r.PersonOtherCountryCode,Related_To_License_Number__r.License_Number_With_Rat_Name__c, Related_To__r.PersonEmail, Related_To__r.PersonHomePhone, '+
                            'Related_To__r.FirstName, Related_To__r.MiddleName, Related_To__r.LastName',
                            'Id IN ' +
                            LPI_ServiceUtility.getStringValuesByList(allIds),
                            null,
                            null,
                            null
                        )
                    ) {
                        Map<String, Object> singleEmployeeInformation = new Map<String, Object>();
                        singleEmployeeInformation.put('licenseType',parList[0].Regulatory_Authorization_Type__r.Name);
                        if (
                            String.isNotBlank(
                                acr.Related_To__r.PersonOtherState
                            )
                        ) {
                            singleEmployeeInformation.put(
                                'State',
                                acr.Related_To__r.PersonOtherState
                            );
                        } else {
                            singleEmployeeInformation.put(
                                'State',
                                acr.Related_To__r.Other_State__c
                            );
                        }
                        singleEmployeeInformation.put(
                            'EmailIfAnsweredNo',
                            acr.Related_To__r.PersonEmail
                        );
                        singleEmployeeInformation.put(
                           'TelephoneIfAnsweredNo',
                            acr.Related_To__r.PersonHomePhone
                        );
                        singleEmployeeInformation.put(
                            'City',
                            acr.Related_To__r.PersonOtherCity
                        );
                        singleEmployeeInformation.put(
                            'Country',
                            acr.Related_To__r.PersonOtherCountry
                        );
                        singleEmployeeInformation.put(
                            'Zip',
                            acr.Related_To__r.PersonOtherPostalCode
                        );
                        singleEmployeeInformation.put(
                            'NameEmployeeInformation',
                            acr.Related_To__r.Name
                        );
                        singleEmployeeInformation.put(
                            'FirstName',
                            acr.Related_To__r.FirstName
                        );
                        singleEmployeeInformation.put(
                            'MiddleName',
                            acr.Related_To__r.MiddleName
                        );
                        singleEmployeeInformation.put(
                            'LastName',
                            acr.Related_To__r.LastName
                        );
                        singleEmployeeInformation.put('Title1', acr.Title__c);
                        if (
                            acr.Related_To__r.LicensedInMissouri__c == YES ||
                            parList[0].Board_Name__c ==
                            COSMETOLOGY_AND_BARBER_EXAMINERS
                        ) {
                            singleEmployeeInformation.put(
                                'LicenseNumber',
                                acr.Related_To_License_Number__r.License_Number_With_Rat_Name__c
                            );
                        } else {
                            singleEmployeeInformation.put(
                                'LicenseNumber',
                                acr.License_Number__c
                            );
                        }
                        singleEmployeeInformation.put(
                            'LicenseType',
                            acr.License_Type__c
                        );
                        singleEmployeeInformation.put(
                            'StreetAddress1',
                            acr.Related_To__r.PersonOtherStreet
                        );
                        if (
                            parList[0].Board_Name__c !=
                            COSMETOLOGY_AND_BARBER_EXAMINERS
                        ) {
                            singleEmployeeInformation.put(
                                'LicensedInMissouri',
                                acr.Related_To__r.LicensedInMissouri__c
                            );
                        }
                        singleEmployeeInformation.put(
                            'EmployeeActivelyAssociated',
                            acr.If_Relationship_is_Associated_with_you__c
                        );
                        singleEmployeeInformation.put(
                            'BoardName',
                            parList[0].Board_Name__c
                        );
                        employeeInformationList.add(singleEmployeeInformation);
                    }
                }
                if (!employeeInformationList.isEmpty()) {
                    outMap.put(
                        'AddEmployeeInformationDetails',
                        employeeInformationList
                    );
                }
            }
        } catch (Exception e) {
            LPI_ExceptionManager.logException(
                CLASS_NAME,
                FETCH_EMPLOYEE_INFORMATION_REVIEW,
                e
            );
            throw new LPI_Exception(
                'Problem in fetching the the Employee Information details',
                e
            );
        }
        return employeeInformationList;
    }

    /**
     * @author                     : MTX Group Product Team
     * @param id 				   : ACR ID id
     * @param AccountId 		   : Account Id
     * @param ContactId            : Contact Id
     * @param Options              : Options map data pass from OS to code
     * @param answerYesBlock 	   : access all element present in answerYesBlock
     * @param answerNo 			   : access all element present in answerNo
     * @param activelyAssociated   : Acr is actively associated or not checkbox(If_Relationship_is_Associated_with_you__c)
     * @param updateRecordIfExists : Check if ACR is already created then update that ACR
     * @return  `AccountContactRelation`
     * @description                : Fetching Employee information For Review Page
     * @last modified by           : MTX Group Product Team
     * @last modified date         :
     * @modified details           :
     */
    private static Business_Relationships__c upsertAccountContactRelation(
        String id,
        String accountId,
        Id businessAccountId,
        String roles,
        Map<String, Object> answerYesBlock,
        Map<String, Object> answerNo,
        boolean activelyAssociated,
        boolean updateRecordIfExists,
        String relatedFromLicenseNumber
    ) {
        Business_Relationships__c relationship = new Business_Relationships__c();
        try {
            String licenseNumber, licenseType, title;

            if (answerYesBlock != null) {
                licenseNumber = (String) answerYesBlock.get(
                    String.escapeSingleQuotes('LicenseName')
                );
                licenseType = (String) answerYesBlock.get(
                    String.escapeSingleQuotes('LicenseType')
                );
                title = (String) answerYesBlock.get(
                    String.escapeSingleQuotes('Title1')
                );
            }

            if (answerNo != null) {
                title = (String) answerNo.get('TitleIfAnsweredNo');
                licenseNumber = (String) answerNo.get(
                    'LicenseNumberIfAnsweredNo'
                );
                licenseType = (String) answerNo.get('LicenseTypeIfAnsweredNo');
            }

            if (updateRecordIfExists == true && id != null) {
                relationship.Id = id;
            }

            if (accountId != null) {
                relationship.Related_To__c = accountId;
            }
            if (businessAccountId != null) {
                relationship.Related_From__c = businessAccountId;
            }
            if (String.isNotBlank(roles)) {
                relationship.Roles__c = roles;
            }
            if (String.isNotBlank(licenseNumber)) {
                relationship.License_Number__c = licenseNumber;
                if (
                    licenseNumber.length() == 10 ||
                    licenseNumber.length() == 11
                ) {
                    String fieldsToQuerybl ='Id';
                    String whereClausebl = 'Name =\'' +licenseNumber+'\'';
                    List<BusinessLicense> blList = new LPI_BusinessLicenseDAO.LPI_BusinessLicenseWithoutSharingDAO().getBusinessLicenseByDymanicQueryWithoutSecurity(fieldsToQuerybl,whereClausebl,null,null,null);
                    relationship.Related_To_License_Number__c = blList[0].Id;
                }
            }
            if (String.isNotBlank(relatedFromLicenseNumber)) {
                relationship.Related_From_License_Number__c = relatedFromLicenseNumber;
            }
            if (String.isNotBlank(licenseType)) {
                relationship.License_Type__c = licenseType;
            }
            if (String.isNotBlank(title)) {
                relationship.Title__c = title;
            }
            if (activelyAssociated != null) {
                relationship.If_Relationship_is_Associated_with_you__c = activelyAssociated;
            }

            List<Business_Relationships__c> BRList = LPI_RelationshipService.findDuplicates(
                relationship
            );

            if (id == null && BRList.isEmpty()) {
                relationship = (Business_Relationships__c) LPI_WithoutSharingUtility.insertSObject(
                    relationship
                );
            } else {
                if (
                    id != null && LPI_WithoutSharingUtility.checkACRAccess(id)
                ) {
                    LPI_WithoutSharingUtility.updateSObject(relationship); 
                } else {
                    throw new LPI_Exception(
                        'You do not access to perform this operation'
                    );
                }
            }
        } catch (Exception e) {
            LPI_ExceptionManager.logException(
                CLASS_NAME,
                UPSERT_ACCOUNT_CONTACT_RELATION,
                e
            );
            throw new LPI_Exception(
                'Problem in fetching the the Employee Information details',
                e
            );
        }

        return relationship;
    }

    /**
     * @author 					   : MTX Group Product Team
     * @param accountId            : Account Id
     * @param contactId 		   : Contact Id
     * @param roles                : Role of ACR
     * @return  `list<AccountContactRelation>`
     * @description                : Fetching ACR on the basis of different filter
     * @last modified by           : MTX Group Product Team
     * @last modified date         :
     * @modified details           :
     */
    private static list<Business_Relationships__c> queryAccountContactRelation(
        String accountId,
        Id businessAccountId,
        String roles,
        boolean isActive
    ) {
        String whereClause, contactId;
        List<Account> acc;
        if (String.isNotBlank(accountId)) {
            LPI_AccountDAO.LPI_AccountWithoutSharingDAO accWithoutSharing = new LPI_AccountDAO.LPI_AccountWithoutSharingDAO();
            acc = accWithoutSharing.getAccountByDymanicQuery(
                'Id,PersonContactId',
                'Id = \'' +
                accountId +
                '\'',
                null,
                null,
                null
            );
        }
        if (accountId != null && businessAccountId != null) {
            whereClause =
                'Related_From__c =\'' +
                String.escapeSingleQuotes(businessAccountId) +
                '\'' +
                ' AND  Related_To__c = \'' +
                String.escapeSingleQuotes(accountId) +
                '\'';
        }
        if (String.isNotBlank(roles)) {
            whereClause =
                whereClause +
                ' AND Roles__c = \'' +
                String.escapeSingleQuotes(roles) +
                '\'';
        }
        if (isActive != null) {
            whereClause = whereClause + 'AND IsActive__c = false';
        }
        LPI_BusinessRelationshipDAO.LPI_BusinessRelationshipsWithoutSharingDAO relationshipWithoutSharing = new LPI_BusinessRelationshipDAO.LPI_BusinessRelationshipsWithoutSharingDAO();
        List<Business_Relationships__c> accountContactRelationExist = relationshipWithoutSharing.getBusinessRelationshipsByDymanicQuery(
            'Id,Related_To__r.Name,License_Type__c, Title__c',
            whereClause,
            null,
            null,
            null
        );
        return accountContactRelationExist;
    }

    /**
     * @author              : MTX Group Product Team
     * @param inputMap      : Input value passed from OS
     * @param outMap        : Output value passed from here to OS
     * @description         : Saving All ACR Id on PAR (Employee_Information_ACR_Ids__c) field
     * @last modified by    : MTX Group Product Team
     * @last modified date  :
     * @modified details    :
     */
    private static void saveEmployeeInformationIds(
        Map<String, Object> inputMap,
        Map<String, Object> outMap
    ) {
        try {
            String parId = (String) inputMap.get('parid');
            String acrIds = '';

            Map<String, Object> employeeInformation = (Map<String, Object>) inputMap.get(
                'EmployeeInformation'
            );
            List<Object> addEmployeeInformationDetails = new List<Object>();

            if (
                isMap(employeeInformation.get('AddEmployeeInformationDetails'))
            ) {
                addEmployeeInformationDetails.add(
                    (Object) employeeInformation.get(
                        'AddEmployeeInformationDetails'
                    )
                );
            } else {
                addEmployeeInformationDetails = (List<Object>) employeeInformation.get(
                    'AddEmployeeInformationDetails'
                );
            }

            if (addEmployeeInformationDetails != null) {
                for (Object data : addEmployeeInformationDetails) {
                    Map<String, Object> employeeData = (Map<String, Object>) data;
                    acrIds += (String) employeeData.get('Id') + ',';
                }

                PreliminaryApplicationRef par = new PreliminaryApplicationRef(
                    Id = parId
                );
                par.Employee_Information_ACR_Ids__c = acrIds.removeEnd(',');
                LPI_DML.doUpdate(par);
            }
        } catch (Exception e) {
            LPI_ExceptionManager.logException(
                CLASS_NAME,
                SAVE_EMPLOYEE_INFORMATION,
                e
            );
            throw new LPI_Exception(
                'Problem in Saving Employee Information details',
                e
            );
        }
    }
}