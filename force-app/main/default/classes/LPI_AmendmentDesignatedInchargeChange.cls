/**
 * @author      : Mohit Karani
 * @since       : 31 Jan, 2023
 * @description : This Class Contains methods which are used for Amendment of Designated Incharge
 */
global with sharing class LPI_AmendmentDesignatedInchargeChange implements Callable {
    global Object call(String action, Map<String, Object> args) {
        Map<String, Object> input = (Map<String, Object>) args.get('input');
        Map<String, Object> output = (Map<String, Object>) args.get('output');
        Map<String, Object> options = (Map<String, Object>) args.get('options');
        return invokeMethod(action, input, output, options);
    }

    /**
     * @author              : MTX Group Product Team
     * @description         : This method will compare method from Omniscript and execute only that specific method
     * @return              : `Boolean`
     */
    private Boolean invokeMethod(
        String methodName,
        Map<String, Object> inputMap,
        Map<String, Object> outMap,
        Map<String, Object> options
    ) {
        Boolean result = true;
        try {
            if (methodName.equals('saveChangeOfInChargeInformation')) {
                saveChangeOfInChargeInformation(inputMap, options, outMap);
            } else if (methodName.equals('fetchReviewInformation')) {
                fetchReviewInformation(inputMap, outMap);
            } 
            
            else if (methodName.equals('getExistingDesignatedAdminDetails')) {
                getExistingDesignatedAdminDetails(inputMap, outMap);
            } 
           
            else if (methodName.equals('fetchLicenseDetails')) {
                outMap.put('licenseRecords', fetchLicenseDetails(options));
            }
        } catch (Exception e) {
            LPI_ExceptionManager.logException(
                'LPI_AmendmentDesignatedInchargeChange',
                'invokeMethod',
                e
            );
            result = false;
        }
        return result;
    }

    public final static String DESIGNATED_INCHARGE = 'Designated Incharge';
    public final static String CONVERTED = 'Converted';
    private final static String PERSON_INCHARGE_ADDRESS = 'Person In Charge Address';
    private final static String YES = 'Yes';
    private final static String NO = 'No';
    private final static String ACTIVE = 'Active';
    

    /**
     * @author                      : MTX Group Product Team
     * @since                       : 14 Feb 2023
     * @description                 : This method will fetch the License details from license number
     * @param options               : Map<String, Object>
     * @return                      : `List<Map<String,String>>`
     * @last modified by            : MTX Group Product Team
     * @last modified date          :
     * @modified details            :
     */
    public static List<Map<String, object>> fetchLicenseDetails(
        Map<String, Object> options
    ) {
        List<Map<String, Object>> licenseList = new List<Map<String, Object>>();
        try {
            String licenseNumber ='%' + (String) options.get('LicenseNumber') + '%';
            String formerLicenseNumber =(String) options.get('formerLicenseNum');
            if(licenseNumber?.length()<=5) {
                return null;
            }
            
            String blQueryFields = 'Id,Name, First_Name__c, Last_Name__c, Middle_Name__c,License_Number_With_Rat_Name__c, Primary_Contact_Address__c, Account.Phone,'+
                                   'Account.Date_of_Birth__c, Account.PersonEmail, Account.Social_Security_Number__c,Account.Name';

            String blWhereClauseFields = 
                ' Name LIKE \'' + String.escapeSingleQuotes(licenseNumber) +
                '\' AND Status = \'' + ACTIVE + 
                '\' AND RegulatoryAuthorizationType.Authorisation_Type__c=\'' + LPI_LiteralConstant.INDIVIDAULICENSE_APPTYPE +
                '\' AND Account.RecordType.DeveloperName=\'' + LPI_LiteralConstant.ACCOUNT_PERSON_RECORDTYPE + '\'';

            if(String.isNotBlank(formerLicenseNumber)){
                blWhereClauseFields = blWhereClauseFields + ' AND License_Number_With_Rat_Name__c !=\''  + String.escapeSingleQuotes(formerLicenseNumber) + '\'';
            }
            
            LPI_BusinessLicenseDAO.LPI_BusinessLicenseWithoutSharingDAO bLListWithOutSharing = new LPI_BusinessLicenseDAO.LPI_BusinessLicenseWithoutSharingDAO();
            List<BusinessLicense> businessLicenseList = bLListWithOutSharing.getBusinessLicenseByDymanicQuery(
                blQueryFields,
                blWhereClauseFields,
                '10',
                null,
                null
            );
            Map<Id,String> blIdToPrimaryContactAddressMap = new Map<Id,String>();
            for(BusinessLicense tempBl : businessLicenseList){
                blIdToPrimaryContactAddressMap.put(tempBl.Id,tempBl.Primary_Contact_Address__c);
            }
            Map <Id,Schema.Address> blIdToAddressMap = LPI_DesignatedInchargeController.getAddress(blIdToPrimaryContactAddressMap);
             
            for (BusinessLicense blData : businessLicenseList) {
                Map<String, Object> licenseMap = new Map<String, Object>();
                licenseMap.put('Name', blData.Name);
                licenseMap.put('TypeAheadkeyName', blData.License_Number_With_Rat_Name__c); 
                licenseMap.put('NewDesignatedInchargeLicenseName', blData.Name);
                licenseMap.put('NewDesignatedInchargeFirstName',blData.First_Name__c);
                licenseMap.put('NewDesignatedInchargeMiddleName',blData.Middle_Name__c);
                licenseMap.put('NewDesignatedInchargeLastName',blData.Last_Name__c);
                licenseMap.put('NewDesignatedInchargePhoneNumber', blData.Account.Phone);
                licenseMap.put('PersonAccountContactName', blData.Account.Name);
                licenseMap.put('NewDesignatedInchargeEmail', blData.Account.PersonEmail);
                if(blIdToAddressMap != null && !blIdToAddressMap.isEmpty()){
                    if(blIdToAddressMap.containsKey(blData.Id)){
                        licenseMap.put('NewDesignatedInchargeStreetAddress',blIdToAddressMap.get(blData.Id).Street);
                        licenseMap.put('NewDesignatedInchargeCity',blIdToAddressMap.get(blData.Id).City);
                        licenseMap.put('NewDesignatedInchargeCountry',blIdToAddressMap.get(blData.Id).Country);
                        if(blIdToAddressMap.get(blData.Id).CountryCode == 'US'){
                            licenseMap.put('NewDesignatedInchargeState',blIdToAddressMap.get(blData.Id).State);
                            licenseMap.put('NewDesignatedInchargeStateCode',blIdToAddressMap.get(blData.Id).StateCode);
                        }else{
                            licenseMap.put('NewDesignatedInchargeState',blIdToAddressMap.get(blData.Id).Business_State__c);
                        }
                        licenseMap.put('NewDesignatedInchargeCounty',blIdToAddressMap.get(blData.Id).County__c);
                        licenseMap.put('NewDesignatedInchargeZipCode',blIdToAddressMap.get(blData.Id).PostalCode);
                        licenseMap.put('NewDesignatedInchargeId',blIdToAddressMap.get(blData.Id).Id);
                    }
                } 
                licenseList.add(licenseMap);
            }
        } catch (Exception e) {
            LPI_ExceptionManager.logException(
                'LPI_AmendmentDesignatedInchargeChange',
                'fetchLicenseDetails',
                e
            );
        }
        return licenseList;
    }

    private static Map<String, String> keyMappingForAccount;

    /**
     * @author            : MTX Group Product Team
     * @description       : This method is used to save the Change of person incharge info on PAR
     * @param  inputMap   : data we are fetching from the Vlocity component
     * @return            : `List<Map<String,String>>`
     */
    public static void saveChangeOfInChargeInformation(
        Map<String, Object> inputMap,
        Map<String, Object> options,
        Map<String, Object> outMap
    ) {
        try {
            String parId = (String) inputMap.get('parId');
            String blId = (String) inputMap.get('blId');
            if(options==null || options.isEmpty()){
                return;
            }
            Map<String, object> designatedBrokerDetailsStepInfo = (Map<String, object>) inputMap.get('DesignatedInchargeInformation');
            if(designatedBrokerDetailsStepInfo == null || designatedBrokerDetailsStepInfo.isEmpty()){
                return;
            }

            if (String.isNotEmpty(blId) && String.isNotEmpty(parId)) {
                List<PreliminaryApplicationRef> parList = LPI_PreliminaryApplicationRefDAO.getPreliminaryApplicationRefByDymanicQuery(
                    'Id,New_Designated_in_charge_License_Number__c, Regulatory_Authorization_Type__r.IssuingDepartment.Name,'+
                    'BusinessAccountNameId,License_Questions__c, Person_Incharge_Relation_Id__c',
                    'Id = \'' + String.escapeSingleQuotes(parId) + '\'',
                    '1',
                    null,null
                );
                String ssn = '';
                Boolean zipLengthCheck = false;
                if (!parList.isEmpty()) {
                    Id newPICId = null;
                    String newLicNumber = null;
                    Map<String, object> newPICLicenseInfo = (Map<String, object>) designatedBrokerDetailsStepInfo.get('NewDesignatedInchargeLicenseNumber-Block');
                    if(newPICLicenseInfo != null && !newPICLicenseInfo.isEmpty()){
                        newLicNumber = (String) newPICLicenseInfo.get('Name');
                    }
                    Business_Relationships__c acrToBeInserted = new Business_Relationships__c();
                    acrToBeInserted.Related_From__c = parList[0].BusinessAccountNameId;
                    acrToBeInserted.Roles__c = LPI_LiteralConstant.ROLE_DESIGNATED_INCHARGE;
                    acrToBeInserted.Related_From_License_Number__c = blId;
                    acrToBeInserted.IsActive__c = false;
                    acrToBeInserted.Start_Date__c = System.today();
                    acrToBeInserted.Is_Licensed_Entity__c = (String) designatedBrokerDetailsStepInfo.get('IsTheNewPICLicensedInMissouri');
                    if(newLicNumber!=null){
                        LPI_BusinessLicenseDAO.LPI_BusinessLicenseWithoutSharingDAO bLListWithOutSharing = new LPI_BusinessLicenseDAO.LPI_BusinessLicenseWithoutSharingDAO();
                        List<BusinessLicense> blNew = bLListWithOutSharing.getBusinessLicenseByDymanicQuery(
                            'Id, Name, ContactId, AccountId , Contact.AccountId, Account.Name, First_Name__c, Middle_Name__c, Last_Name__c',
                            'Name = \'' + String.escapeSingleQuotes(newLicNumber) + '\'',
                            '1', null, null
                        );
                        if (!blNew.isEmpty()) {
                            acrToBeInserted.Related_To__c = blNew[0].AccountId;
                            acrToBeInserted.Related_To_License_Number__c = blNew[0].Id;
                            acrToBeInserted.License_Number__c = blNew[0].Name;
                            createLocationRecord(blNew[0].AccountId,blNew[0].Account.Name, inputMap, outMap);
                        }
                    }
                    Map<String, object> amendmentPICDetailsStepInfo = (Map<String, object>) designatedBrokerDetailsStepInfo.get('NewDesignatedInchargeUnlicensed');                    
                    if(amendmentPICDetailsStepInfo != null && !amendmentPICDetailsStepInfo.isEmpty()){
                        Account personAccount = LPI_DesignatedInchargeController.upsertPersonAccount(inputMap,outMap, parList[0].BusinessAccountNameId);
                        ssn = (String) amendmentPICDetailsStepInfo.get('UnlicensedNewDesignatedInchargeSSN');
                        if(String.isNotBlank(ssn)){
                            Boolean ssnDuplicate = LPI_DesignatedInchargeController.checkDuplicateSSN(personAccount.Id,inputMap,outMap);
                            if(ssnDuplicate == true ){
                                return;
                            }
                        }
                        String mailingCountry = (String) amendmentPICDetailsStepInfo.get('UnlicensedNewDesignatedInchargeCountry');
                        String mailingZipCode = (String) amendmentPICDetailsStepInfo.get('UnlicensedNewDesignatedInchargeZipCode');
                        outMap.put('zipLengthCheck',false);
                        if(mailingCountry=='US'){
                            Integer zipLength = mailingZipCode.length();
                            if(zipLength!=5){
                                outMap.put('zipLengthCheck',true);
                                return;
                            }
                        }
                        if (personAccount != null ) {
                            acrToBeInserted.Related_To__c = personAccount.Id;
                            acrToBeInserted.Related_To_License_Number__c = null;
                            acrToBeInserted.License_Number__c = (String) amendmentPICDetailsStepInfo.get('UnlicensedNewDesignatedInchargeLicenseNumber');
                        }
                        createLocationRecord(personAccount.Id, personAccount.Name, inputMap, outMap);
                    }
                    List<Business_Relationships__c> duplicates = (List<Business_Relationships__c>) LPI_RelationshipService.findDuplicates(acrToBeInserted);
                    if (!duplicates.isEmpty()) {
                        acrToBeInserted.Id = duplicates[0].Id;
                    }
                    acrToBeInserted = (Business_Relationships__c)LPI_WithoutSharingUtility.upsertSObject(acrToBeInserted);
                    newPICId = acrToBeInserted.Id;
                    
                    if(newPICId!=null){
                        parList[0].Person_Incharge_Relation_Id__c = newPICId;
                        parList[0].New_Designated_in_charge_License_Number__c = newPICId;
                    }
                    LPI_DML.doUpdate(parList);
                }
            }
        } catch (Exception e) {
            LPI_ExceptionManager.logException('LPI_AmendmentDesignatedInchargeChange','saveChangeOfInChargeInformation',e);
            throw new AuraHandledException(e.getMessage());
        }
    }

   

    /**
     * @author              : MTX Group Product Team
     * @description         : This method is used to display prev associated admin and new associated admin
     * @param  inputMap     : fetching all the input from Omniscript
     * @return              : `List<Map<String,String>>`
     * @since               : 22 Dec 2022
     * @last modified by    : MTX Group Product Team
     * @last modified date  : 20 June 2023
     * @last modified details: Beautified the code with proper indentation
     */

    public static void getExistingDesignatedAdminDetails(
        Map<String, Object> inputMap,
        Map<String, Object> outMap
    ) {
        try {
            if (String.isNotBlank((String) inputMap.get('parId'))) {
                Id parId = (Id) inputMap.get('parId');
                List<PreliminaryApplicationRef> parList = LPI_PreliminaryApplicationRefDAO.getPreliminaryApplicationRefByDymanicQuery(
                    'Id, BusinessAccountNameId, Status__c, ' +
                    'New_Designated_in_charge_License_Number__c ',
                    'Id =\'' + parId + '\'',
                    '1',
                    null,
                    null
                );
                if (!parList.isEmpty()) {
                    LPI_BusinessRelationshipDAO.LPI_BusinessRelationshipsWithoutSharingDAO acrQuery = new LPI_BusinessRelationshipDAO.LPI_BusinessRelationshipsWithoutSharingDAO();
                    
                    for (
                        Business_Relationships__c acr : acrQuery.getBusinessRelationshipsByDymanicQuery(
                            'Id, Related_To__r.Name,License_Number__c,EndDate__c,IsActive__c,' +
                            ' Related_To__r.PersonOtherCity, Related_To__r.Phone, Related_To__r.PersonOtherStateCode,' +
                            ' Related_To__r.PersonHomePhone, Related_To__r.PersonOtherStreet, Related_To__r.PersonOtherState,' +
                            ' Related_To__r.PersonOtherPostalCode,Related_To__r.PersonEmail,Start_Date__c, Related_To__r.County__c, ' +
                            ' Related_To__r.FirstName, Related_To__r.MiddleName, Related_To__r.LastName, Roles__c',
                            'Related_From__c =\'' + parList[0].BusinessAccountNameId +
                            '\' AND Roles__c =\'' + DESIGNATED_INCHARGE +'\'',
                            null,
                            null,
                            null
                        )
                    ) {
                         
                        if ((acr.IsActive__c == true &&parList[0].Status__c != CONVERTED) 
                        ) {
                            outMap.putAll(fillRSSchoolPrevDesignatedAdminDetails(acr));
                        } else if (acr.Id == parList[0].New_Designated_in_charge_License_Number__c
                        ) {
                             
                            outMap.put('DesignatedBrokerName', acr.Related_To__r.Name);
                            outMap.put('ApplicantDesignatedInchargePhoneNumber', acr.Related_To__r.Phone);
                            outMap.put('ApplicantDesignatedInchargePhone', acr.Related_To__r.PersonHomePhone);
                            outMap.put('HomeAddressStreet',acr.Related_To__r.PersonOtherStreet);
                            outMap.put('HomeAddressCity',acr.Related_To__r.PersonOtherCity);
                            outMap.put('HomeAddressState',acr.Related_To__r.PersonOtherStateCode);
                            outMap.put('HomeAddressStateValue',acr.Related_To__r.PersonOtherState);
                            outMap.put('HomeAddressZipcode',acr.Related_To__r.PersonOtherPostalCode);
                            outMap.put('HomeAddressCounty',acr.Related_To__r.County__c);
                            outMap.put('AdministratorEmail',acr.Related_To__r.PersonEmail);
                            outMap.put('ApplicantDesignatedInchargeName',acr.Related_To__r.Name);
                            outMap.put('ApplicantDesignatedInchargeFirstName',acr.Related_To__r.FirstName);
                            outMap.put('ApplicantDesignatedInchargeMiddleName',acr.Related_To__r.MiddleName);
                            outMap.put('ApplicantDesignatedInchargeLastName',acr.Related_To__r.LastName);
                             
                        }
                    }
                }
            }
        } catch (Exception e) {
            LPI_ExceptionManager.logException('LPI_AmendmentDesignatedInchargeChange','getExistingDesignatedAdminDetails', e);
            throw new LPI_Exception(e.getMessage());
        }
    }
    /**
     * @author              :  MTX Group Product Team
     * @description         : This method is used to fill currently associated admin details
     * @param               : Business Relationships from which outputmap is filled
     * @return              : Map<String, Object>
     * @last modified by    : MTX Group Product Team
     * @since               : 20 June 2023
     */
    private static Map<String, Object> fillRSSchoolPrevDesignatedAdminDetails(
        Business_Relationships__c acr
    ) {
        Map<String, Object> designatedInchargeMap = new Map<String, Object>();
        designatedInchargeMap.put('DesignatedBrokerNameRO',acr.Related_To__r.Name);
        designatedInchargeMap.put('ApplicantDesignatedInchargePhoneNumberRO',acr.Related_To__r.Phone);
        designatedInchargeMap.put('ApplicantDesignatedInchargePhoneRO',acr.Related_To__r.PersonHomePhone);
        designatedInchargeMap.put('HomeAddressStreetRO',acr.Related_To__r.PersonOtherStreet);
        designatedInchargeMap.put('HomeAddressCityRO',acr.Related_To__r.PersonOtherCity);
        designatedInchargeMap.put('HomeAddressStateRO',acr.Related_To__r.PersonOtherStateCode);
        designatedInchargeMap.put('HomeAddressStateValueRO',acr.Related_To__r.PersonOtherState);
        designatedInchargeMap.put('HomeAddressZipcodeRO',acr.Related_To__r.PersonOtherPostalCode);
        designatedInchargeMap.put('HomeAddressCountyRO',acr.Related_To__r.County__c);
        designatedInchargeMap.put('AdministratorEmailRO',acr.Related_To__r.PersonEmail);
        designatedInchargeMap.put('PrevAdminId', acr.Id);
        designatedInchargeMap.put('ApplicantDesignatedInchargeNameRO',acr.Related_To__r.Name);
        designatedInchargeMap.put('ApplicantDesignatedInchargeFirstNameRO',acr.Related_To__r.FirstName);
        designatedInchargeMap.put('ApplicantDesignatedInchargeMiddleNameRO',acr.Related_To__r.MiddleName);
        designatedInchargeMap.put('ApplicantDesignatedInchargeLastNameRO',acr.Related_To__r.LastName);
        return designatedInchargeMap;
    }

    

    /**
     * @author                       : MTX Group Product Team
     * @since                        : November 1, 2023
     * @description                  : fetch Person In Charge record for License Amendment
     * @param inputMap               : input map
     * @param outMap                 : output map
     * @return                       : void
     */
    public static void fetchReviewInformation(
        Map<String, Object> inputMap,
        Map<String, Object> outMap
    ) {
        try {
            if (String.isNotBlank((String) inputMap.get('parId'))) {
                Id parId = (Id) inputMap.get('parId');
                if(parId!=null){
                    List<PreliminaryApplicationRef> parList = LPI_PreliminaryApplicationRefDAO.getPreliminaryApplicationRefByDymanicQuery(
                        'Id, BusinessAccountNameId, Status__c, ' +
                        'Person_Incharge_Relation_Id__c , Board_Name__c',
                        'Id = \'' + String.escapeSingleQuotes(parId) + '\'',
                        '1',
                        null,null
                    );
                    if (!parList.isEmpty()) {
                        Id businessLicenseId = null;

                        String isLicensed = null;
                        outMap.put('boardName',parList[0].Board_Name__c);
                        LPI_BusinessRelationshipDAO.LPI_BusinessRelationshipsWithoutSharingDAO acrQuery = new LPI_BusinessRelationshipDAO.LPI_BusinessRelationshipsWithoutSharingDAO();
                        for (
                            Business_Relationships__c acr : acrQuery.getBusinessRelationshipsByDymanicQuery(
                                'Id, Related_To__r.Name,License_Number__c, Related_To__r.Date_of_Birth__c, Is_Licensed_Entity__c, Related_To_License_Number__c,' +
                                ' Related_To__r.PersonOtherCity, Related_To__r.Phone, Related_To__r.PersonOtherStateCode,Related_To_License_Number__r.License_Number_With_Rat_Name__c,' +
                                ' Related_To__r.PersonOtherStreet,Related_To__r.PersonOtherPostalCode,Related_To__r.PersonBirthdate, Related_From_License_Number__c,' +
                                ' Related_To__r.FirstName, Related_To__r.LastName, Related_To__r.MiddleName,IsActive__c,'+
                                ' Related_To__r.PersonEmail, Related_To__r.PersonContactId, Related_To__c, Related_To__r.PersonOtherState, Related_To__r.Social_Security_Number__c, Person_Incharge_Email__c',
                                ' Related_From__c =\'' +parList[0].BusinessAccountNameId +
                                '\' AND Roles__c =\'' + DESIGNATED_INCHARGE + '\'',
                                null,
                                null,
                                null
                            )
                        ) {
                            if ((acr.IsActive__c == true && parList[0].Status__c != CONVERTED)) {
                                    outMap.put('FormerDesignatedInchargeFirstName',acr.Related_To__r.FirstName);
                                    outMap.put('FormerDesignatedInchargeMiddleName',acr.Related_To__r.MiddleName);
                                    outMap.put('FormerDesignatedInchargeLastName',acr.Related_To__r.LastName);
                                    outMap.put('FormerDesignatedInchargePhoneNumber', acr.Related_To__r.Phone);
                                    outMap.put('FormerDesignatedInchargeEmail', acr.Related_To__r.PersonEmail);
                                    outMap.put('FormerDesignatedInchargeSSN', acr.Related_To__r.Social_Security_Number__c);
                                    outMap.put('FormerDesignatedInchargeDoB', acr.Related_To__r.Date_of_Birth__c);
                                    if(acr.Is_Licensed_Entity__c == 'Yes'){
                                        outMap.put('FormerDesignatedInchargeLicenseNumber', acr.Related_To_License_Number__r.License_Number_With_Rat_Name__c);
                                    }else{
                                        outMap.put('FormerDesignatedInchargeLicenseNumber', acr.License_Number__c);
                                    }
                                    outMap.put('IsFormerPICLicensedInMissouri', acr.Is_Licensed_Entity__c);
                                    outMap.put('FormerPICId', acr.Id);
                                    businessLicenseId = acr.Related_From_License_Number__c;
                            } 
                            if (acr.Id ==parList[0].Person_Incharge_Relation_Id__c) {
                                outMap.put('IsTheNewPICLicensedInMissouri',acr.Is_Licensed_Entity__c);
                                isLicensed = acr.Is_Licensed_Entity__c;
                                if(acr.Is_Licensed_Entity__c == 'Yes'){
                                    outMap.put('NewDesignatedInchargeFirstName',acr.Related_To__r.FirstName);
                                    outMap.put('NewDesignatedInchargeMiddleName',acr.Related_To__r.MiddleName);
                                    outMap.put('NewDesignatedInchargeLastName',acr.Related_To__r.LastName);
                                    outMap.put('NewDesignatedInchargePhoneNumber', acr.Related_To__r.Phone);
                                    outMap.put('NewDesignatedInchargeEmail', acr.Related_To__r.PersonEmail);
                                    outMap.put('NewDesignatedInchargeSSN', acr.Related_To__r.Social_Security_Number__c);
                                    outMap.put('NewDesignatedInchargeDoB', acr.Related_To__r.Date_of_Birth__c);
                                    outMap.put('NewDesignatedInchargeLicenseNumber', acr.Related_To_License_Number__r.License_Number_With_Rat_Name__c);
                                }else{
                                    outMap.put('UnlicensedNewDesignatedInchargeFirstName',acr.Related_To__r.FirstName);
                                    outMap.put('UnlicensedNewDesignatedInchargeMiddleName',acr.Related_To__r.MiddleName);
                                    outMap.put('UnlicensedNewDesignatedInchargeLastName',acr.Related_To__r.LastName);
                                    outMap.put('UnlicensedNewDesignatedInchargePhoneNumber', acr.Related_To__r.Phone);
                                    outMap.put('UnlicensedNewDesignatedInchargeEmail', acr.Related_To__r.PersonEmail);
                                    outMap.put('UnlicensedNewDesignatedInchargeSSN', acr.Related_To__r.Social_Security_Number__c);
                                    outMap.put('UnlicensedNewDesignatedInchargeDoB', acr.Related_To__r.Date_of_Birth__c);
                                    outMap.put('UnlicensedNewDesignatedInchargeLicenseNumber', acr.License_Number__c);
                                }
                                
                            }
                        }
                        Schema.Address tempAddress = LPI_DesignatedInchargeController.fetchAddress(parList[0].Id, PERSON_INCHARGE_ADDRESS);
                        if (tempAddress != null) {
                            if(isLicensed == 'Yes'){
                                outMap.put('LocationId', tempAddress.ParentId);
                                outMap.put('NewDesignatedInchargeCity', tempAddress.City);
                                outMap.put('NewDesignatedInchargeStreetAddress', tempAddress.Street);
                                outMap.put('NewDesignatedInchargeCountry', tempAddress.Country);
                                outMap.put('NewDesignatedInchargeZipCode', tempAddress.PostalCode);
                                outMap.put('NewDesignatedInchargeCounty', tempAddress.County__c);
                                if (tempAddress.CountryCode == 'US') {
                                    outMap.put('NewDesignatedInchargeState', tempAddress.State);
                                } else {
                                    outMap.put('NewDesignatedInchargeState', tempAddress.Business_State__c);
                                }
                            }else{
                                outMap.put('LocationId', tempAddress.ParentId);
                                outMap.put('UnlicensedNewDesignatedInchargeCity', tempAddress.City);
                                outMap.put('UnlicensedNewDesignatedInchargeStreetAddress', tempAddress.Street);
                                outMap.put('UnlicensedNewDesignatedInchargeCountry', tempAddress.CountryCode);
                                outMap.put('UnlicensedNewDesignatedInchargeCountryFC', tempAddress.Country);
                                outMap.put('UnlicensedNewDesignatedInchargeZipCode', tempAddress.PostalCode);
                                outMap.put('UnlicensedNewDesignatedInchargeCounty', tempAddress.County__c);
                                if (tempAddress.CountryCode == 'US') {
                                    outMap.put('UnlicensedNewDesignatedInchargeState', tempAddress.StateCode);
                                    outMap.put('UnlicensedNewDesignatedInchargeStateFC', tempAddress.State);
                                } else {
                                    outMap.put('UnlicensedNewDesignatedInchargeNonUSState', tempAddress.Business_State__c);
                                }

                            }
                        }
                        if(businessLicenseId!=null){
                            Schema.Address tempBlAddress = LPI_DesignatedInchargeController.fetchBlAddress(businessLicenseId, PERSON_INCHARGE_ADDRESS);
                             
                            if(tempBlAddress!=null){
                                outMap.put('FormerDesignatedInchargeCity', tempBlAddress.City);
                                outMap.put('FormerDesignatedInchargeStreetAddress', tempBlAddress.Street);
                                outMap.put('FormerDesignatedInchargeCountry', tempBlAddress.Country);
                                outMap.put('FormerDesignatedInchargeZipCode', tempBlAddress.PostalCode);
                                outMap.put('FormerDesignatedInchargeCounty', tempBlAddress.County__c);
                                if (tempBlAddress.CountryCode == 'US') {
                                    outMap.put('FormerDesignatedInchargeState', tempBlAddress.State);
                                } else {
                                    outMap.put('FormerDesignatedInchargeState', tempBlAddress.Business_State__c);
                                }
                            }
                        }
                    }
                }
            }
        } catch (Exception e) {
            LPI_ExceptionManager.logException('LPI_AmendmentDesignatedInchargeChange','fetchReviewInformation',e);
            throw new LPI_Exception(e.getMessage());
        }
    }

    /**
     * @author                       : MTX Group Product Team
     * @since                        : November 1, 2023
     * @description                  : create location record for account
     * @param inputMap               : input map
     * @param outMap                 : output map
     * @return                       : void
     */
    private static void createLocationRecord(
        Id accountId,
        String accountName,
        Map<String, Object> inputMap,
        Map<String, Object> outMap
    ) {
        Id parId = (Id) inputMap.get('parId');
        if(parId==null || accountId==null){
            return;
        }
        Map<String, object> designatedBrokerDetailsStepInfo = (Map<String, object>) inputMap.get('DesignatedInchargeInformation');
        if(designatedBrokerDetailsStepInfo == null && designatedBrokerDetailsStepInfo.isEmpty()){
            return;
        }
        Map<String, object> addressValueMapping = new Map<String, object>();
        Map<String, Object> mailingAddressBlock = new Map<String, Object>();
        Map<String, String> addressKeyMapping;
        String isLicensedinMissuori = YES;
        if(String.isNotBlank((String) designatedBrokerDetailsStepInfo.get('IsTheNewPICLicensedInMissouri'))){
            isLicensedinMissuori = (String) designatedBrokerDetailsStepInfo.get('IsTheNewPICLicensedInMissouri');
        }
        if(isLicensedinMissuori == NO){
            mailingAddressBlock = (Map<String, object>) designatedBrokerDetailsStepInfo.get('NewDesignatedInchargeUnlicensed');
            Map<String, Object> lwcZipCityCountyMap = (Map<String, Object>) mailingAddressBlock?.get('DBCityCountyZip');
            addressKeyMapping = new Map<String, String>{
                'UnlicensedNewDesignatedInchargeStreetAddress' => 'Street',
                'UnlicensedNewDesignatedInchargeCity' => 'City',
                'UnlicensedNewDesignatedInchargeState' => 'StateCode',
                'UnlicensedNewDesignatedInchargeNonUSState' => 'Business_State__c',
                'UnlicensedNewDesignatedInchargeZipCode' => 'PostalCode',
                'UnlicensedNewDesignatedInchargeCountry' => 'CountryCode',
                'UnlicensedNewDesignatedInchargeCounty' => 'County__c'
            };
            addressValueMapping.put('UnlicensedNewDesignatedInchargeStreetAddress', lwcZipCityCountyMap?.get('UnlicensedNewDesignatedInchargeStreetAddress'));
            addressValueMapping.put('UnlicensedNewDesignatedInchargeCity', lwcZipCityCountyMap?.get('UnlicensedNewDesignatedInchargeCity') );
            addressValueMapping.put('UnlicensedNewDesignatedInchargeState', lwcZipCityCountyMap?.get('UnlicensedNewDesignatedInchargeState') );
            addressValueMapping.put('UnlicensedNewDesignatedInchargeNonUSState', lwcZipCityCountyMap?.get('UnlicensedNewDesignatedInchargeNonUSState') );
            addressValueMapping.put('UnlicensedNewDesignatedInchargeZipCode', lwcZipCityCountyMap?.get('UnlicensedNewDesignatedInchargeZipCode') );
            addressValueMapping.put('UnlicensedNewDesignatedInchargeCountry', lwcZipCityCountyMap?.get('UnlicensedNewDesignatedInchargeCountry') );
            addressValueMapping.put('UnlicensedNewDesignatedInchargeCounty', lwcZipCityCountyMap?.get('UnlicensedNewDesignatedInchargeCounty') );
            
        }else if(isLicensedinMissuori == YES){
            addressValueMapping = (Map<String, object>) designatedBrokerDetailsStepInfo.get('NewDesignatedInchargeLicenseNumber-Block');
            addressKeyMapping = new Map<String, String>{
                'NewDesignatedInchargeStreetAddress' => 'Street',
                'NewDesignatedInchargeCity' => 'City',
                'NewDesignatedInchargeZipCode' => 'PostalCode',
                'NewDesignatedInchargeCountry' => 'Country',
                'NewDesignatedInchargeCounty' => 'County__c'
            };
            if((String)addressValueMapping.get('NewDesignatedInchargeCountry') == 'United States'){
                addressKeyMapping.put('NewDesignatedInchargeStateCode','StateCode');
            }else{
                addressKeyMapping.put('NewDesignatedInchargeState','Business_State__c');
            }
        }
        if(String.isBlank(accountName)){
            return;
        }
        String locationId = LPI_AddressUtility.createLocationAndAddress(
            accountId,
            PERSON_INCHARGE_ADDRESS,
            accountName,
            addressKeyMapping,
            addressValueMapping
        );
        if(locationId==null){
            return;
        }
        outMap.put('LocationId', locationId);

        LPI_TempAuthApplicationPlaceDAO.LPI_TempAuthApplicationPlaceWithoutSharingDAO tAAP = new LPI_TempAuthApplicationPlaceDAO.LPI_TempAuthApplicationPlaceWithoutSharingDAO();
        List<Temp_AuthApplicationPlace__c> tempAAP = tAAP.getTempAuthApplicationPlaceByDymanicQuery(
            'Id, Location__r.LocationType',
            ' Preliminary_Application_Reference__c = \'' + parId +'\'' +
            ' AND Location__r.LocationType = \'' + PERSON_INCHARGE_ADDRESS + '\'',
            null, null, null
        );
        Temp_AuthApplicationPlace__c tempAuthRec = new Temp_AuthApplicationPlace__c();
        if (!tempAAP.isEmpty()) {
            tempAuthRec.Id = tempAAP[0].Id;
        }
        tempAuthRec.Location__c = locationId;
        tempAuthRec.Preliminary_Application_Reference__c = parId;
        LPI_WithoutSharingUtility.upsertSObject(tempAuthRec);
    }
}