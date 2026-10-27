/**
 * @description       : This class is a remote class which is used as controller for Applicant Supervisor Section
 * @author            : MTX Group Product Team|02-01-2023
 * @group             :
 * @last modified on  : 07-24-2024
 * @last modified by  : MTX Group Product Team
 **/
global with sharing class LPI_ApplicantSupervisorController implements Callable {
  
    private final static String RESIDENCE = 'Residence';
    private final static String CLASS_NAME = 'LPI_ApplicantSupervisorController';
    private final static String FETCH_SUPERVISOR_DETAILS = 'fetchSupervisorDetails';
    private final static String FETCH_PRIMARY_SUPERVISOR_ACR = 'fetchPrimarySupervisorACR';
    private final static String SAVE_PRIMARY_SUPERVISOR_DETAILS = 'savePrimarySupervisorDetails';
    private final static String INVOKE_METHOD = 'invokeMethod';
    private final static String NAME_LABEL = 'Name';
    private final static String BL_DATA_HELPER = 'blDataHelper';
    private final static String FETCH_ACR_HELPER = 'fetchACRHelper';
    private final static String INDIVIDAULICENSE_APPTYPE = 'Individual';
    private final static String BUSINESSLICENSE_APPTYPE = 'Business';
    private final static String LOCATION_STATUS_OPEN = 'Open';
    private final static String BUSINESSLICENSE_STATUS_ACTIVE = 'Active';
    private final static String SUBMITTED_STATUS = 'Submitted';
    private final static String UNITED_STATES = 'United States';
    private final static String SUPERVISOR_LICENSE_NUMBER = 'supervisorLicenseNumber';
    private final static String SECONDARY_SUPERVISOR_LICENSE_NUMBER = 'secondarySupervisorLicenseNumber';
    private final static String SECONDARY_SUPERVISOR_LICENSE_NAME = 'SecondarySupervisorLicName';
    private final static String PORTAL_USER_PRFL = 'Portal User';
    private final static String APPROVED_STATUS = 'Approved';
    private final static String USER_PROFILE = 'userProfile';
    private final static String COSBAR_BOARD_NAME = 'Cosmetology & Barber Examiners';
    private final static String TEMP_PERMIT_BEHIS_LICENSE = 'Temp Permit - BEHIS';
    private final static String APPLICATION_TYPE_PORV_LICENSE_EXTENSION = 'Provisional License Extension';
    /**
     * @author                      : MTX Group Product Team
     * @since                       : 02-01-2023
     * @description                 : This method calls invoke method
     * @param action                : String
     * @param args			        : Map<String, Object>
     * @return                      : Object
     * @last modified by            : MTX Group Product Team
     * @last modified date          :
     * @modified details            :
     */
    global Object call(String action, Map<String, Object> args) {
        Map<String, Object> input = (Map<String, Object>) args.get('input');
        Map<String, Object> output = (Map<String, Object>) args.get('output');
        Map<String, Object> options = (Map<String, Object>) args.get('options');
        return invokeMethod(action, input, output, options);
    }
    /**
     * @author                      : MTX Group Product Team
     * @since                       : 02-01-2023
     * @description                 :  This method will compare method from Omniscript and execute only that specific method
     * @param inputMap		        : Map<String, Object> input map from OS
     * @param outMap 		        : Map<String, Object>
     * @param options 		        : Map<String, Object>
     * @return                      : Boolean
     * @last modified by            : MTX Group Product Team
     * @last modified date          :
     * @modified details            :
     */
    private Boolean invokeMethod(
        String methodName,
        Map<String, Object> inputMap,
        Map<String, Object> outMap,
        Map<String, Object> options
    ) {
        Boolean result = true;
        try {
            switch  on methodName{
                when 'fetchSupervisorDetails'{
                    outMap.put('supervisorDetails', fetchSupervisorDetails(inputMap));
                }
                when 'fetchPrimarySupervisorACR'{
                    outMap.put('supervisorDetailsOnReload', fetchPrimarySupervisorACR(inputMap));
                }
                when 'savePrimarySupervisorDetails'{
                    savePrimarySupervisorDetails(inputMap);
                }
                when else{
                    result = false; 
                }
            }
        } catch (Exception e) {
            result = false;
            LPI_ExceptionManager.logException(CLASS_NAME, INVOKE_METHOD, e);
        }
        return result;
    }
    /**
     * @author                      : MTX Group Product Team
     * @since                       : 02-01-2023
     * @description                 :  This method will fetch businessLicenses with the name entered and related details
     * @param inputMap		        : Map<String, Object> input map from OS
     * @param outMap 		        : Map<String, Object>
     * @param options 		        : Map<String, Object>
     * @return                      : Boolean
     * @last modified by            : MTX Group Product Team
     * @last modified date          :
     * @modified details            :
     */
    private static List<Map<String, Object>> fetchSupervisorDetails(
        Map<String, Object> inputMap
    ) {
        List<Map<String, Object>> licenseMap = new List<Map<String, Object>>();
        try {
            String fields;
            String whereClause;
            String licenseNumber;
            String entityLicenseNumber1 = (String) inputMap.get(
                SUPERVISOR_LICENSE_NUMBER
            );
            String entityLicenseNumber2 = (String) inputMap.get(
                SECONDARY_SUPERVISOR_LICENSE_NUMBER
            );
            String boardName = (String) inputMap.get('boardName');
            String role;
            String conId;
            if (!String.isEmpty(entityLicenseNumber1)) {
                licenseNumber = '%' + entityLicenseNumber1 + '%';
                role = LPI_LiteralConstant.ROLE_PRIMARY_SUPERVISOR;
            } else if (!String.isEmpty(entityLicenseNumber2)) {
                licenseNumber = '%' + entityLicenseNumber2 + '%';
                role = 'typeAheadSecondarySupervisor';
            }
            if (!String.isEmpty(licenseNumber) && licenseNumber.length() >= 4) {
                List<BusinessLicense> blList = new List<BusinessLicense>();
                String blFields = 'Id,Name,License_Number_With_Rat_Name__c,  First_Name__c,Last_Name__c,Middle_Name__c,Account.Phone,Account.PersonEmail,Regulatory_Authorization_Type_Name__c';
                whereClause =
                    ' Name LIKE \'' +
                    String.escapeSingleQuotes(licenseNumber) +
                    '\' AND RegulatoryAuthorizationType.Authorisation_Type__c= \'' +
                    String.escapeSingleQuotes(INDIVIDAULICENSE_APPTYPE) +
                    '\'';
                if(boardName != COSBAR_BOARD_NAME){
                    whereClause += ' AND Approved_Supervisor__c = true';
                }
                blList = new LPI_BusinessLicenseDAO.LPI_BusinessLicenseWithoutSharingDAO().getBusinessLicenseByDymanicQuery(
                    blFields,
                    whereClause,
                    '100',
                    null,
                    null
                );
                System.debug('-->'+blList);
                if (!blList.isEmpty()) {
                    licenseMap.addAll(blDataHelper(
                        blList,
                        new Map<String, Map<String, Object>>(),
                        role
                    ));
                }
            }
        } catch (Exception e) {
            LPI_ExceptionManager.logException(
                CLASS_NAME,
                FETCH_SUPERVISOR_DETAILS,
                e
            );
        }
        return licenseMap;
    }
    /**
     * @author                      : MTX Group Product Team
     * @since                       : 02-01-2023
     * @description                 :  This method will create ACRS for primary supervisor role and stored related fields
     * @param inputMap		        : Map<String, Object> input map from OS
     * @return                      : void
     * @last modified by            : MTX Group Product Team
     * @last modified date          :
     * @modified details            :
     */
    public static List<PreliminaryApplicationRef> savePrimarySupervisorDetails(
        Map<String, Object> inputMap
    ) {
        PreliminaryApplicationRef par = new PreliminaryApplicationRef();
        List<PreliminaryApplicationRef> parList = new List<PreliminaryApplicationRef>();
        try {
            String parId = (String) inputMap.get('parId');
            Map<String, Object> stepData;
            if (String.isBlank(parId)) {
                parId = (String) stepData.get('parIdFromula');
            }
            Set<Id> parConIds = new Set<Id>();
            String fields;
            String whereClause;
            String conId;
            String licensedInMissouri;
            String primarySupervisorId, licenseId;
            if (String.isNotBlank(parId)) {
                fields =
                    'Id , Regulatory_Authorization_Type__r.Name,  BusinessAccountName.PersonEmail, Contact__c ,Contact__r.AccountId , Business_License__c, ' +
                    ' BusinessAccountNameId ,Approval_Supervisors_AcrIds__c, Board_Name__c, BusinessAccountName.Name,Supervisor_ACR_Id__c,' +
                    'Regulatory_Authorization_Type__c,SavedApplicationUrl,Regulatory_Authorization_Type__r.Email_Specifications_Final__c';
                whereClause =
                    ' Id =\'' +
                    String.escapeSingleQuotes(parId) +
                    '\'';
                parList = LPI_PreliminaryApplicationRefDAO.getPreliminaryApplicationRefByDymanicQuery(
                    fields,
                    whereClause,
                    '1',
                    null,
                    null
                );
                if (parList.isEmpty()) {
                    return null;
                }

                par = parList[0];
                if (parList[0].Contact__c != null) {
                    parConIds.add(parList[0].Contact__r.AccountId);
                    conId = parList[0].Contact__r.AccountId;
                    primarySupervisorId = parList[0].Supervisor_ACR_Id__c;
                    licenseId = parList[0].Business_License__c;
                }
            }
            String boardCertification, bl, establishmentBl;
            if (inputMap.containsKey('ApprenticeshipData')) {
                Map<String, Object> supervisorInformation = (Map<String, Object>) inputMap.get(
                    'SupervisorInformation'
                );
                Map<String, Object> licenseNumberBlock = (Map<String, Object>) supervisorInformation.get(
                    'LicenseNumber-Block'
                );
                Map<String, Object> establishmentLicenseNumberBlock = (Map<String, Object>) supervisorInformation.get(
                    'EstablishmentLicenseNumber-Block'
                );
                bl = (String) licenseNumberBlock.get('Name');
                establishmentBl = (String) establishmentLicenseNumberBlock.get(
                    'EstablishmentLicenseName'
                ); 
                linkingEstablishmentBL(establishmentBl, parId, bl);
            } else if (inputMap.containsKey('proofOfSupervision')) {
                Map<String, Object> typeAheadMap;
                if (inputMap.containsKey('PersonInChargeAgencyInfo')) {
                    Map<String, Object> stepDataMap = (Map<String, Object>) inputMap.get(
                        'PersonInChargeAgencyInfo'
                    );
                    typeAheadMap = (Map<String, Object>) stepDataMap.get(
                        'AgencyLicenseNumberTypeAhead-Block'
                    );
                    bl = (String) typeAheadMap.get('PICLicenseNumber');
                }
            } else {
                if (
                    inputMap.containsKey(
                        'SupervisorColaboratingProfessional'
                    ) && 
                    inputMap.get('SupervisorColaboratingProfessional') != null
                ) {
                    stepData = (Map<String, Object>) inputMap.get(
                        'SupervisorColaboratingProfessional'
                    );
                }
                if(
                    inputMap.containsKey('SuperviseeInformation') &&
                    inputMap.get('SuperviseeInformation') != null
                ){
                    stepData = (Map<String, Object>) inputMap.get('SuperviseeInformation');
                }
                if(stepData != null){
                    if((String) stepData.get('IsTheSupervisorLicensedinMissouri') !=null){
                        licensedInMissouri =  (String) stepData.get('IsTheSupervisorLicensedinMissouri');
                    }
                    Map<String, Object> primarySupervisorBlock = (Map<String, Object>) stepData.get(
                        'primarySupervisorBlock'
                    );
                    Map<String, Object> licenseNumberBlock = (Map<String, Object>) primarySupervisorBlock.get(
                        'supervisorLicenseNumber-Block'
                    );
                    bl = (String) licenseNumberBlock.get(NAME_LABEL);
                    boardCertification = licenseNumberBlock.containsKey('supervisorSpecialityCertification') ? (String) licenseNumberBlock.get(
                        'supervisorSpecialityCertification'
                    ) : null;
                }
            }
            List<BusinessLicense> blList = new List<BusinessLicense>();
            LPI_BusinessLicenseDAO.LPI_BusinessLicenseWithoutSharingDAO withoutSharingBL = new LPI_BusinessLicenseDAO.LPI_BusinessLicenseWithoutSharingDAO();
            if (!String.isEmpty(bl)) {
                String blFields = 'Id,AccountId,Name';
                whereClause =
                    ' Name =\'' +
                    String.escapeSingleQuotes(bl) +
                    '\'' +
                    ' AND RegulatoryAuthorizationType.Authorisation_Type__c= \'' +
                    String.escapeSingleQuotes(INDIVIDAULICENSE_APPTYPE) +
                    '\'';
                blList = withoutSharingBL.getBusinessLicenseByDymanicQuery(
                        blFields,
                        whereClause,
                        null,
                        null,
                        null
                    );
                
            }

            if (!blList.isEmpty() && !String.isEmpty(blList[0].AccountId)) {
                List<Business_Relationships__c> acrList = new List<Business_Relationships__c>();
                if (!parConIds.isEmpty()) {
                    SObject acrInstance;
                    Business_Relationships__c acr = new Business_Relationships__c();
                    acr.Related_From__c = blList[0].AccountId;
                    acr.Related_To__c = conId;
                    acr.Roles__c = LPI_LiteralConstant.ROLE_PRIMARY_SUPERVISOR;
                    acr.Supervisor_License_Number__c = blList[0].Name;
                    acr.Speciality_Or_Board_Certification__c = boardCertification;
                    acr.Related_From_License_Number__c = blList[0].Id;
                    Boolean isInternalUser = inputMap.containsKey(USER_PROFILE) && (String) inputMap.get(USER_PROFILE) != PORTAL_USER_PRFL ? true : false;
                    if (
                        inputMap.containsKey('isForSupervisorApproval') &&
                        isInternalUser
                    ) {
                        acr.Supervisor_Approval_Status__c = APPROVED_STATUS;
                    }
                    if (String.isNotBlank(licenseId)) {
                        acr.Related_To_License_Number__c = licenseId;
                    }
                    if (establishmentBl != null) {
                        acr.Entity_License_Number__c = establishmentBl;
                    }
                    if(String.isNotBlank(licensedInMissouri)){
                        acr.Is_Licensed_Entity__c = licensedInMissouri;
                    }
                    acrList = LPI_RelationshipService.findDuplicates(acr);
                    if (acrList.isEmpty()) {
                        acr.IsActive__c = false;
                        acrInstance = LPI_WithoutSharingUtility.insertSObject(
                            acr
                        );
                    } else {
                        acr.Id = acrList[0].Id;
                        acrInstance = LPI_WithoutSharingUtility.updateSObject(
                            acr
                        );
                    }
                    if (inputMap.containsKey('isForSupervisorApproval')) {
                        parList[0]
                            .Approval_Supervisors_AcrIds__c = acrInstance.Id;
                    } else {
                        if (
                            String.isNotBlank(acrInstance.Id) &&
                            String.isNotBlank(primarySupervisorId) &&
                            (acrInstance.Id != primarySupervisorId)
                        ) {
                            fields = 'Id';
                            whereClause =
                                'Id = \'' +
                                String.escapeSingleQuotes(primarySupervisorId) +
                                '\'' +
                                'AND Roles__c = \'' +
                                String.escapeSingleQuotes(
                                    LPI_LiteralConstant.ROLE_PRIMARY_SUPERVISOR
                                ) +
                                '\'' +
                                'AND IsActive__c = false';
                            List<Business_Relationships__c> deleteAcrList = LPI_BusinessRelationshipDAO.fetchBusinessRelationshipRecords(
                                fields,
                                whereClause
                            );
                            if (!deleteAcrList.isEmpty()) {
                                LPI_WithoutSharingUtility.deleteSObject(
                                    deleteAcrList
                                );
                            }
                        }
                        parList[0].Supervisor_ACR_Id__c = acrInstance.Id;
                    }
                }
                LPI_DML.doUpdate(parList[0]);
            }
        } catch (Exception exp) {
            LPI_ExceptionManager.logException(
                CLASS_NAME,
                SAVE_PRIMARY_SUPERVISOR_DETAILS,
                exp
            );
        }
        return parList;
    }

    private static List<Map<String, Object>> blDataHelper(
        List<BusinessLicense> blList,
        Map<String, Map<String, Object>> accIdToDataMap,
        String fetchType
    ) {
        Set<Id> locationIdSet = new Set<Id>();
        set<Id> blIdSet = new Set<Id>();
        Map<String, Map<String, Object>> blIdToDataMap = new Map<String, Map<String, Object>>();
        Map<String, Map<String, Object>> locIdToDataMap = new Map<String, Map<String, Object>>();
        List<Map<String, Object>> multipleSupervisorDetails = new List<Map<String, Object>>();
        String fields, whereClause;
        try {
            Integer noOfRec = 1;
            Map<String, List<Map<String, Object>>> accIdToFetchDataMap = new Map<String, List<Map<String, Object>>>();
            for (BusinessLicense bl : blList) {
                Map<String, Object> dataMap = new Map<String, Object>();
                if (!accIdToDataMap.isEmpty()) {
                    dataMap = accIdToDataMap.get(bl.AccountId) != null ? accIdToDataMap.get(bl.AccountId) : new Map<String, Object>();
                } else {
                    dataMap = new Map<String, Object>();
                }

                if (
                    fetchType == LPI_LiteralConstant.ROLE_SECONDARY_SUPERVISOR ||
                    fetchType == 'typeAheadSecondarySupervisor'
                ) {
                    dataMap.put(
                        'secondarySupervisorFirstName',
                        bl.First_Name__c
                    );
                    dataMap.put('secondarySupervisorLastName', bl.Last_Name__c);
                    dataMap.put(
                        'secondarySupervisorMiddleName',
                        bl.Middle_Name__c
                    );
                    dataMap.put(
                        SECONDARY_SUPERVISOR_LICENSE_NUMBER,
                        bl.License_Number_With_Rat_Name__c
                    );
                    dataMap.put('noOfRec', 'Secondary Supervisor ' + noOfRec);
                    dataMap.put(SECONDARY_SUPERVISOR_LICENSE_NAME, bl.Name);
                    dataMap.put(
                        'TypeAheadKeyName',
                        bl.License_Number_With_Rat_Name__c
                    );
                    dataMap.put('blId', bl.Id);
                    noOfRec = noOfRec - 1;
                } else if (fetchType == LPI_LiteralConstant.ROLE_PRIMARY_SUPERVISOR) {
                    dataMap.put(
                        SUPERVISOR_LICENSE_NUMBER,
                        bl.License_Number_With_Rat_Name__c
                    );
                    dataMap.put('blId', bl?.Id);
                    dataMap.put(NAME_LABEL, bl.Name);
                    dataMap.put(
                        'TypeAheadKeyName',
                        bl.License_Number_With_Rat_Name__c
                    );
                    dataMap.put('SupervisorFirstName', bl.First_Name__c);
                    dataMap.put('supervisorLastName', bl.Last_Name__c);
                    dataMap.put('supervisorMiddleName', bl.Middle_Name__c);
                    dataMap.put(
                        'supervisorLicenseType',
                        bl.Regulatory_Authorization_Type_Name__c
                    );
                }
                blIdToDataMap.put(bl.Id, dataMap);
                blIdSet.add(bl.Id);
                if (accIdToDataMap.isEmpty() && !String.isEmpty(bl.AccountId)) {
                    if (!accIdToFetchDataMap.containsKey(bl.AccountId)) {
                        accIdToFetchDataMap.put(
                            bl.AccountId,
                            new List<Map<String, Object>>()
                        );
                    }
                    accIdToFetchDataMap.get(bl.AccountId).add(dataMap);
                }
            }
            String acFields = 'Id,Phone,PersonEmail';
            String acWhereClause;
            if (!accIdToFetchDataMap.isEmpty()) {
                acWhereClause =
                    'Id IN ' +
                    LPI_ServiceUtility.getStringValuesByStringSet(
                        accIdToFetchDataMap.keySet()
                    );
            } else if (!accIdToDataMap.isEmpty()) {
                acWhereClause =
                    'Id IN ' +
                    LPI_ServiceUtility.getStringValuesByStringSet(
                        accIDToDataMap.keySet()
                    );
            }
            if (!String.isEmpty(acWhereClause)) {
                LPI_AccountDAO.LPI_AccountWithoutSharingDAO accObj = new LPI_AccountDAO.LPI_AccountWithoutSharingDAO();
                List<Account> accList = accObj.getAccountByDymanicQuery(
                    acFields,
                    acWhereClause,
                    null,
                    null,
                    null
                );
                if (!accList.isEmpty()) {
                    for (Account acc : accList) {
                        List<Map<String, Object>> dataMapList = new List<Map<String, Object>>();
                        if (!accIdToDataMap.isEmpty()) {
                            dataMapList.add(accIdToDataMap.get(acc.Id));
                        } else if (!accIdToFetchDataMap.isEmpty()) {
                            dataMapList = accIdToFetchDataMap.get(acc.Id);
                        }
                        for (Map<String, Object> dataMap : dataMapList) {
                            dataMap.put('supervisorPhone', acc.Phone);
                            dataMap.put('supervisorEmail', acc.PersonEmail);
                            dataMap.put('secondarySupervisorPhone', acc.Phone);
                            dataMap.put(
                                'secondarySupervisorEmail',
                                acc.PersonEmail
                            );
                        }
                    }
                }
            }
            if (!blIdSet.isEmpty()) {
                fields = 'Id, AuthorizationId, PlaceId';
                whereClause =
                    ' AuthorizationId IN ' +
                    LPI_ServiceUtility.getStringValuesBySet(blIdSet);
                LPI_AuthApplicationPlaceDAO.LPI_AuthApplicationPlaceWithoutSharingDAO aapObj = new LPI_AuthApplicationPlaceDAO.LPI_AuthApplicationPlaceWithoutSharingDAO();
                Set<Id> blIdWithLocationSet = new Set<Id>();
                for (
                    AuthApplicationPlace aap : aapObj.getAuthApplicationPlaceByDymanicQuery(
                        fields,
                        whereClause,
                        null,
                        null,
                        null
                    )
                ) {
                    locationIdSet.add(aap.PlaceId);
                    locIdToDataMap.put(
                        aap.PlaceId,
                        blIdToDataMap.get(aap.AuthorizationId)
                    );
                    blIdWithLocationSet.add(aap.AuthorizationId);
                }
                for(Id blId : blIdSet){
                    if(!blIdWithLocationSet.contains(blId)){
                        multipleSupervisorDetails.add(blIdToDataMap.get(blId));
                    }
                }
            }
            if (!locationIdSet.isEmpty()) {
                fields = 'ID,ParentId,Parent.Status__c,Parent.LocationType,Parent.Name,StateCode,City,County__c,PostalCode,State,Street,Country, Business_State__c';
                whereClause =
                    ' ParentId IN ' +
                    LPI_ServiceUtility.getStringValuesBySet(locationIdSet);
                LPI_AddressDAO.LPI_AddressDAOWithoutSharing addrObj = new LPI_AddressDAO.LPI_AddressDAOWithoutSharing();

                List<Schema.Address> addresses = addrObj.getAddressByDymanicQuery(
                    fields,
                    whereClause,
                    null,
                    null,
                    null
                );
                for (Schema.Address address : addresses) {
                    if (
                        address.Parent.LocationType == RESIDENCE &&
                        address.Parent.Status__c == LOCATION_STATUS_OPEN
                    ) {
                        Map<String, Object> dataMap = locIdToDataMap.get(
                            address.ParentId
                        );
                        if (fetchType == LPI_LiteralConstant.ROLE_PRIMARY_SUPERVISOR) {
                            dataMap.put(
                                'supervisorStreetAddress',
                                address.Street
                            );
                            dataMap.put('supervisorCity', address.City);
                            if (address.Country == UNITED_STATES) {
                                dataMap.put('supervisorState', address.State);
                            } else {
                                dataMap.put(
                                    'supervisorState',
                                    address.Business_State__c
                                );
                            }
                            dataMap.put('supervisorZip', address.PostalCode);
                            multipleSupervisorDetails.add(dataMap);
                        } else if (
                            fetchType == LPI_LiteralConstant.ROLE_SECONDARY_SUPERVISOR ||
                            fetchType == 'typeAheadSecondarySupervisor'
                        ) {
                            dataMap.put(
                                'secondarySupervisorStreetAddress',
                                address.Street
                            );
                            dataMap.put(
                                'secondarySupervisorCity',
                                address.City
                            );
                            dataMap.put(
                                'secondarySupervisorZip',
                                address.PostalCode
                            );
                            if (address.Country == UNITED_STATES) {
                                dataMap.put(
                                    'secondarySupervisorState',
                                    address.State
                                );
                            } else {
                                dataMap.put(
                                    'secondarySupervisorState',
                                    address.Business_State__c
                                );
                            }
                            if (fetchType == LPI_LiteralConstant.ROLE_SECONDARY_SUPERVISOR) {
                                Map<String, Object> tempblockMap = new Map<String, Object>();
                                tempblockMap.put(
                                    'secondarySupervisorLicenseNumber-Block',
                                    dataMap
                                );
                                multipleSupervisorDetails.add(tempblockMap);
                            } else {
                                multipleSupervisorDetails.add(dataMap);
                            }
                        }
                    }
                }
            }
            if(multipleSupervisorDetails.isEmpty()){
                multipleSupervisorDetails.addAll(blIdToDataMap.values());
            }
        } catch (Exception exp) {
            LPI_ExceptionManager.logException(
                CLASS_NAME,
                BL_DATA_HELPER,
                exp
            );
        }
        return multipleSupervisorDetails;
    }

    /**
     * @author                      : MTX Group Product Team
     * @since                       : 02-01-2023
     * @description                 : This method is the helper method to fetch ACRS
     * @param inputMap		        : Map<String, Object> input map from OS
     * @return                      : Map<String,String>
     * @last modified by            : MTX Group Product Team
     * @last modified date          :
     * @modified details            :
     */
    private static List<Map<String, Object>> fetchACRHelper(
        String role,
        Map<String, Object> inputMap
    ) {
        String parId = (String) inputMap.get('parId');
        String clauseType = (String) inputMap.get('readOnly');
        String clauseTypeFromOS = (String) inputMap.get('readOnlyFromOS');
        Set<Id> parConIds = new Set<Id>();
        String fields;
        String whereClause;
        List<Map<String, Object>> data = new List<Map<String, String>>();
        try {
            String supervisedBySecondarySupervisor;
            List<String> queryIdsList = new List<String>();
            if (String.isNotBlank(parId)) {
                fields = 'Contact__c,Contact__r.AccountId,Employee_Information_ACR_Ids__c,Supervisor_ACR_Id__c , Approval_Supervisors_AcrIds__c , Type__c'; 
                whereClause =
                    ' Id =\'' +
                    String.escapeSingleQuotes(parId) +
                    '\'';
                List<PreliminaryApplicationRef> par = new LPI_PreliminaryApplicationRefDAO.LPI_PreliminaryApplicationRefWithoutSharingDAO().getPreliminaryApplicationRefByDymanicQuery(
                    fields,
                    whereClause,
                    null,
                    null,
                    null
                );
                if (!par.isEmpty()) {
                    if (par[0].Contact__c != null) {
                        parConIds.add(par[0].Contact__r.AccountId);
                    }
                    if (!parConIds.isEmpty()) {
                        if (clauseType == 'Yes') {
                            whereClause =
                                ' Related_To__c IN ' +
                                LPI_ServiceUtility.getStringValuesBySet(
                                    parConIds
                                ) +
                                ' AND Roles__c IN ' +
                                LPI_ServiceUtility.getStringValuesByStringSet(
                                    new Set<String>{ LPI_LiteralConstant.ROLE_PRIMARY_SUPERVISOR }
                                ) +
                                ' AND IsActive__c = true';
                        } else if (clauseType == 'approvalSupervisor' || par[0].Type__c == APPLICATION_TYPE_PORV_LICENSE_EXTENSION) {
                            if (
                                !String.isEmpty(
                                    par[0].Approval_Supervisors_AcrIds__c
                                ) && role == LPI_LiteralConstant.ROLE_PRIMARY_SUPERVISOR
                            ) {
                                queryIdsList.add(
                                    par[0].Approval_Supervisors_AcrIds__c
                                );
                                whereClause =
                                    ' Id IN ' +
                                    LPI_ServiceUtility.getStringValuesByList(
                                        new List<String>(queryIdsList)
                                    );
                            }
                        } else {
                            if (
                                !String.isEmpty(par[0].Supervisor_ACR_Id__c) &&
                                role == LPI_LiteralConstant.ROLE_PRIMARY_SUPERVISOR
                            ) {
                                queryIdsList.add(par[0].Supervisor_ACR_Id__c);
                                whereClause =
                                    ' Id IN ' +
                                    LPI_ServiceUtility.getStringValuesByList(
                                        new List<String>(queryIdsList)
                                    );
                            } else if (
                                role == LPI_LiteralConstant.ROLE_PRIMARY_SUPERVISOR &&
                                clauseTypeFromOS != 'Yes'
                            ) {
                                whereClause =
                                    ' Related_To__c IN ' +
                                    LPI_ServiceUtility.getStringValuesBySet(
                                        parConIds
                                    ) +
                                    ' AND Roles__c IN ' +
                                    LPI_ServiceUtility.getStringValuesByStringSet(
                                        new Set<String>{
                                            LPI_LiteralConstant.ROLE_PRIMARY_SUPERVISOR
                                        }
                                    ) +
                                    ' AND IsActive__c = true';
                            }
                            if (
                                !String.isEmpty(
                                    par[0].Employee_Information_ACR_Ids__c
                                ) && role == LPI_LiteralConstant.ROLE_SECONDARY_SUPERVISOR
                            ) {
                                queryIdsList = par[0]
                                    .Employee_Information_ACR_Ids__c.split(',');
                                whereClause =
                                    ' Id IN ' +
                                    LPI_ServiceUtility.getStringValuesByList(
                                        new List<String>(queryIdsList)
                                    );
                            } else if (role == LPI_LiteralConstant.ROLE_SECONDARY_SUPERVISOR) {
                                whereClause =
                                    ' Related_To__c IN ' +
                                    LPI_ServiceUtility.getStringValuesBySet(
                                        parConIds
                                    ) +
                                    ' AND ROles__c IN ' +
                                    LPI_ServiceUtility.getStringValuesByStringSet(
                                        new Set<String>{
                                            LPI_LiteralConstant.ROLE_SECONDARY_SUPERVISOR
                                        }
                                    ) +
                                    ' AND IsActive__c = true';
                            }
                        }
                    }
                }
            }
            if (!String.isEmpty(whereClause)) {
                fields = 'Id,Related_To__c,Related_From__c,Supervisor_License_Number__c,IsActive__c,Speciality_Or_Board_Certification__c,Is_Licensed_Entity__c'; //updated by Manish Is_Licensed_Entity__c
                Set<Id> blIdSet = new Set<Id>();
                Set<String> blNameSet = new Set<String>();
                Map<String, Map<String, Object>> accIdToDataMap = new Map<String, Map<String, Object>>();
                Integer count = 0;
                LPI_BusinessRelationshipDAO.LPI_BusinessRelationshipsWithoutSharingDAO withoutSharing = new LPI_BusinessRelationshipDAO.LPI_BusinessRelationshipsWithoutSharingDAO();
                for (
                    Business_Relationships__c acr : withoutSharing.getBusinessRelationshipsByDymanicQuery(
                        fields,
                        whereClause,
                        null,
                        null,
                        null
                    )
                ) {
                    Map<String, Object> supervisorData = new Map<String, Object>();
                    if (acr.Is_Licensed_Entity__c != null) {
                        supervisorData.put(
                            'IsTheSupervisorLicensedinMissouri',
                            acr.Is_Licensed_Entity__c
                        );
                    }
                    if (role == LPI_LiteralConstant.ROLE_PRIMARY_SUPERVISOR) {
                        supervisorData.put(
                            'supervisorSpecialityCertification',
                            acr.Speciality_Or_Board_Certification__c
                        );
                    } else if (role == LPI_LiteralConstant.ROLE_SECONDARY_SUPERVISOR) {
                        count += 1;
                    }
                    supervisorData.put('acrId', acr.Id);
                    if (!String.isEmpty(acr.Supervisor_License_Number__c)) {
                        blNameSet.add(acr.Supervisor_License_Number__c);
                    }
                    accIdToDataMap.put(acr.Related_From__c, supervisorData);
                }
                List<BusinessLicense> blList = new List<BusinessLicense>();
                if (!blNameSet.isEmpty()) {
                    String blFields =
                        'Id,Name,First_Name__c,Last_Name__c,Middle_Name__c,Account.Phone,Account.PersonEmail,' +
                        'Regulatory_Authorization_Type_Name__c, License_Number_With_Rat_Name__c ';
                    whereClause =
                        ' Name IN ' +
                        LPI_ServiceUtility.getStringValuesByStringSet(
                            blNameSet
                        );
                    blList = new LPI_BusinessLicenseDAO.LPI_BusinessLicenseWithoutSharingDAO()
                        .getBusinessLicenseByDymanicQuery(
                            blFields,
                            whereClause,
                            null,
                            null,
                            null
                        );
                }
                if (!blList.isEmpty()) {
                    data = blDataHelper(blList, accIdToDataMap, role);
                }
                if (
                    count >= 1 &&
                    !String.isEmpty(parId) &&
                    String.isBlank(supervisedBySecondarySupervisor)
                ) {
                    PreliminaryApplicationRef par = new PreliminaryApplicationRef();
                    par.Id = parId;
                    LPI_DML.doUpdate(par);
                }
            }
        } catch (Exception e) {
            LPI_ExceptionManager.logException(
                CLASS_NAME,
                FETCH_ACR_HELPER,
                e
            );
        }
        return data;
    }
    /**
     * @author                      : MTX Group Product Team
     * @since                       : 02-01-2023
     * @description                 : This method will call fetchAcrHelper method for primary supervisor
     * @param inputMap		        : Map<String, Object> input map from OS
     * @return                      : Map<String,String>
     * @last modified by            : MTX Group Product Team
     * @last modified date          :
     * @modified details            :
     */

    public static Map<String, Object> fetchPrimarySupervisorACR(
        Map<String, Object> inputMap
    ) {
        List<Map<String, Object>> dataMapList = new List<Map<String, Object>>();
        try {
            dataMapList = fetchACRHelper(LPI_LiteralConstant.ROLE_PRIMARY_SUPERVISOR, inputMap);
        } catch (Exception e) {
            LPI_ExceptionManager.logException(
                CLASS_NAME,
                FETCH_PRIMARY_SUPERVISOR_ACR,
                e
            );
        }
        if (!dataMapList.isEmpty()) {
            return dataMapList[0];
        }
        return null;
    }

    /**
     * @author                      : MTX Group Product Team
     * @since                       : 12/07/2023
     * @description                 : This method is use to create Business Relationship for apprentenship supervisor
     * @param inputMap		        : Map<String, Object> input map from OS
     * @return                      : Map<String,String>
     * @last modified by            : MTX Group Product Team
     * @last modified date          :
     * @modified details            :
     */
    private static void linkingEstablishmentBL(
        String establishmentBl,
        String parId,
        String bl
    ) {
        SObject acrInstance;
        try {
            List<BusinessLicense> blList = new List<BusinessLicense>();
            List<BusinessLicense> establishmentBlList = new List<BusinessLicense>();
            String blFields, whereClause, fields;

            if (!String.isEmpty(establishmentBl)) {
                blFields = 'Id,AccountId,Name';
                whereClause =
                    ' Name =\'' +
                    String.escapeSingleQuotes(establishmentBl) +
                    '\'' +
                    ' AND RegulatoryAuthorizationType.Authorisation_Type__c= \'' +
                    String.escapeSingleQuotes(BUSINESSLICENSE_APPTYPE) +
                    '\'';
                establishmentBlList = LPI_BusinessLicenseDAO.fetchBusinessLicenseRecords(
                    blFields,
                    whereClause
                );
            }
            if (!String.isEmpty(bl)) {
                blFields = 'Id,AccountId,Name';
                whereClause =
                    ' Name =\'' +
                    String.escapeSingleQuotes(bl) +
                    '\'' +
                    ' AND RegulatoryAuthorizationType.Authorisation_Type__c= \'' +
                    String.escapeSingleQuotes(INDIVIDAULICENSE_APPTYPE) +
                    '\'';
                blList = LPI_BusinessLicenseDAO.fetchBusinessLicenseRecords(
                    blFields,
                    whereClause
                );
            }
            if (
                !blList.isEmpty() &&
                !String.isEmpty(blList[0].AccountId) &&
                !establishmentBlList.isEmpty() &&
                !String.isEmpty(establishmentBlList[0].AccountId)
            ) {
                List<Business_Relationships__c> relationshipList = new List<Business_Relationships__c>();
                fields = 'Id, Related_To__c, Related_From__c, Supervisor_License_Number__c, IsActive__c, Roles__c';
                whereClause =
                    ' Related_To__c = \'' +
                    String.escapeSingleQuotes(blList[0].AccountId) +
                    '\'' +
                    ' AND Related_From__c = ' +
                    '\'' +
                    String.escapeSingleQuotes(
                        establishmentBlList[0].AccountId
                    ) +
                    '\'';
                relationshipList = LPI_BusinessRelationshipDAO.fetchBusinessRelationshipRecords(
                    fields,
                    whereClause
                );

                Business_Relationships__c relation = new Business_Relationships__c();
                relation.Related_From__c = establishmentBlList[0].AccountId;
                relation.Related_To__c = blList[0].AccountId;
                relation.IsActive__c = false;
                relation.Related_From_License_Number__c = establishmentBlList[0]
                    .Id;
                relation.Related_To_License_Number__c = blList[0].Id;

                if (relationshipList.isEmpty()) {
                    acrInstance = LPI_WithoutSharingUtility.insertSObject(
                        relation
                    );
                } else {
                    relation.Id = relationshipList[0].Id;
                    if (relationshipList[0].IsActive__c) {
                        relation.IsActive__c = true;
                    }
                    acrInstance = LPI_WithoutSharingUtility.updateSObject(
                        relation
                    );
                }
            }
        } catch (Exception exp) {
            LPI_ExceptionManager.logException(
                CLASS_NAME,
                SAVE_PRIMARY_SUPERVISOR_DETAILS,
                exp
            );
        }
    }

}