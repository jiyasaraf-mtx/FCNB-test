/**
 *
 * @author          : MTX Group Product Team
 * @Description     : This class will save the location and Address for Location Types of Warehouse Address and Record Address 
 */

global with sharing class LPI_SaveLocationForPharmacy implements Callable {

    
	public final static String SAVE_PHARMACY_LOCATION = 'savePharmacyLocation';
	public final static String FETCH_PHARMACY_LOCATION = 'fetchPharmacyLocation';
	public final static String SAVE_DESIGNATED_CUSTODIAL = 'saveDesignatedCustodial';
    public final static String UPSERT_RELATIONSHIPS_RECORD = 'upsertRelationshipsRecord';
	public final static String FETCH_DESIGNATED_CUSTODIAL = 'fetchDesignatedCustodial';
	public final static String CLASS_NAME = 'LPI_SaveLocationForPharmacy';
	public final static String INVOKE_METHOD = 'invokeMethod';
    public final static String INVENTORY_TRANSFERRED = 'Inventory sold/transferred to the following person/location';
    private static final String ACR_ROLE_DESIGNATION_CUSTODIAN = 'Designation of Custodial';
    private static final String ACCOUNT_PERSON_RECORDTYPE = 'PersonAccount';
    private static final String LOCATION_TYPE_RECORDS_ADDRESS = 'Records Address';
    private static final String LOCATION_TYPE_WAREHOUSE_ADDRESS = 'Warehouse Address';
    private static final String CLOSING_OF_A_BROKERAGE_SOLE_PROPRIETORSHIP_SUBTYPE = 'Closing of a Real Estate Brokerage/Sole Proprietorship';


    /**
     * @author                      : MTX Group Product Team
     * @since                       : 
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
     * @since                       : 21 Dec 2023
     * @description                 : This method is returing true if its successfully invoked
     * @param methodName            : String 
     * @param inputMap			    : Map<String, Object>
     * @param outMap			    : Map<String, Object> 
     * @param options			    : Map<String, Object> 
     * @return                      : `Boolean`
     * @last modified by            : MTX Group Product Team
     * @last modified date          : 31 Jan 2023
     * @modified details            : 
    */
    private Boolean invokeMethod(String methodName, Map<String, Object> inputMap, Map<String, Object> outMap, Map<String, Object> options) {
        Boolean result = true;
        try {
             if(methodName == SAVE_DESIGNATED_CUSTODIAL){
                saveDesignatedCustodial(inputMap,outMap);
            } else if(methodName == FETCH_DESIGNATED_CUSTODIAL){
                fetchDesignatedCustodial(inputMap,outMap);
            }         
        } catch (Exception e) {
            LPI_ExceptionManager.logException(CLASS_NAME, INVOKE_METHOD, e);
            result = false;
        }
        return result;
    }

    

    /**
     * @author                      : MTX Group Product Team
     * @since                       : December 21, 2023
     * @description                 : This method will save the Designated Custodial Information 
     * @param inputMap              : Input data passed from OmniScript
     * @param outMap                : Output data passed to OmniScript
     * @return                      : `void`
     * @last modified by            : MTX Group Product Team
     * @last modified date          : March 7, 2024
     * @last modified details       : 
    */
    public static void saveDesignatedCustodial(Map<String, Object> inputMap, Map<String, Object> outMap) {
        try {
            String personAccId = '';
            String name = '';
            Boolean isLocationOtherThanCustodianAddress = false;
            String parId = (String) inputMap.get('parId');
            String accId = (String) inputMap.get('businessAccId');
            String perAccId = (String) inputMap.get('perAccId');
            String perAccIdYes = (String) inputMap.get('perAccIdYes');
            Map<String, object> designatedCustodialStepInfo = (Map<String, object>) inputMap.get('DesignationOfTheCustodial');
            String customerInfo = (String) designatedCustodialStepInfo.get('CustodialInformationIntact');
            String areThereAnyBusinessRecords20CSRFor3Years = (String) designatedCustodialStepInfo.get('BusinessRecords20CSRFor3Years');
            isLocationOtherThanCustodianAddress = designatedCustodialStepInfo.get('LocationOtherThanCustodianAddress') != null ? 
                                                (Boolean) designatedCustodialStepInfo.get('LocationOtherThanCustodianAddress') : false;
            String designatedBooksLocId = (String) inputMap.get('designatedBooksLocId');
            Map<String, String> keyMappingAcc = new Map<String, String>{
                'DesignationCustodialFirstName' => 'FirstName',
                'DesignationCustodialMiddleName' => 'MiddleName',
                'DesignationCustodialLastName' => 'LastName',
                'DesignationCustodialStreetAddress1' => 'PersonOtherStreet',
                'DesignationCustodialCity' => 'PersonOtherCity',
                'DesignationCustodialState' => 'PersonOtherStateCode',
                'DesignationCustodialZipcode' => 'PersonOtherPostalCode',
                'DesignationCustodialTelephone' => 'Phone',
                'DesignationCustodialEmail' => 'PersonEmail',
                'DesignationCustodialFax' => 'Fax',
                'DesignationCustodialCountry' => 'PersonOtherCountryCode',
                'DesignationCustodialStateText' => 'Other_State__c'       
            };
            String parQueryFields = 'Id';
            String parWhereClause = '';
            List<PreliminaryApplicationRef> parList = new List<PreliminaryApplicationRef>();
            if (String.isNotBlank(parId)) {
                parWhereClause += 'Id = \'' + String.escapeSingleQuotes(parId) + '\'' 
                                + ' AND Amendment_Type__c = \'' + CLOSING_OF_A_BROKERAGE_SOLE_PROPRIETORSHIP_SUBTYPE + '\'';
                parList = new LPI_PreliminaryApplicationRefDAO.LPI_PreliminaryApplicationRefWithoutSharingDAO()
                            .getPreliminaryApplicationRefByDymanicQuery(parQueryFields, parWhereClause, null, null, null);
            }
            if (!parList.isEmpty() && String.isNotBlank(areThereAnyBusinessRecords20CSRFor3Years)) {
                if (areThereAnyBusinessRecords20CSRFor3Years == 'No') {
                    
                    LPI_DML.doUpdate(parList[0]);
                }
                else {
                    customerInfo = 'Yes';
                    designatedCustodialStepInfo.put('DesignationCustodialCountry', 'US');
                }
            }
            if (customerInfo == 'Yes') {
                perAccId = perAccIdYes;
            } 
            else if (customerInfo == 'No') {
                String accConQueryFieldsDel = 'Id, Related_To__c';
                String accConWhereClauseFieldsDel = 'IsActive__c = false AND EndDate__c = null AND Related_From__c = \'' 
                                                    + String.escapeSingleQuotes(accId) + '\' AND Roles__c = \'' 
                                                    + ACR_ROLE_DESIGNATION_CUSTODIAN + '\'';
                List<Business_Relationships__c> accConListDel = LPI_BusinessRelationshipDAO.fetchBusinessRelationshipRecords(
                                                                                accConQueryFieldsDel, accConWhereClauseFieldsDel);
                if (!accConListDel.isEmpty()) {
                    LPI_WithoutSharingUtility.deleteSObject(accConListDel);    
                    Account delAcc = new Account();
                    delAcc.Id = accConListDel[0].Related_To__c;
                    LPI_WithoutSharingUtility.deleteSObject(delAcc);                   
            	}     
                String accConQueryFields = 'Id, Related_To__c';
                String accConWhereClauseFields = 'Related_From__c = \'' + String.escapeSingleQuotes(accId) 
                                                + '\' AND IsActive__c = true AND Roles__c = \'' + ACR_ROLE_DESIGNATION_CUSTODIAN + '\'';
                List<Business_Relationships__c> accConList = LPI_BusinessRelationshipDAO.fetchBusinessRelationshipRecords(
                                                                accConQueryFields, accConWhereClauseFields, null, null, null);
                if (!accConList.isEmpty()) {
                    perAccId = accConList[0].Related_To__c;
                }
            }
            if (parList.isEmpty() || (!parList.isEmpty() && areThereAnyBusinessRecords20CSRFor3Years == 'Yes')) {                
                Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(ACCOUNT_PERSON_RECORDTYPE).getRecordTypeId();                   
                Account acc = (Account) LPI_VlocityUtility.createSObject(designatedCustodialStepInfo, keyMappingAcc, 'Account');
                if (String.isNotEmpty(acc.MiddleName)) {
                    name = acc.FirstName + ' ' + acc.MiddleName + ' ' + acc.LastName;
                } 
                else {
                    name = acc.FirstName + ' ' + acc.LastName;
                }
                acc.put('RecordTypeId', accRecordTypeId);
                if (String.isEmpty(perAccId)) {
                    List<Datacloud.MatchRecord> accList = LPI_WithoutSharingUtility.getDuplicateRecords(new List<Account>{acc});
                    if (accList.isEmpty()) {
                        Account securityDecision = (Account) LPI_DML.doInsert(acc);
                        personAccId = securityDecision.Id;         
                    } 
                    else {
                        personAccId = accList[0].getRecord().Id;            
                    }
                } 
                else {
                    acc.Id = perAccId;
                    LPI_WithoutSharingUtility.updateSObjectRecord(acc);
                    personAccId = perAccId;
                }
                upsertRelationshipsRecord(accId, personAccId, customerInfo, parId, areThereAnyBusinessRecords20CSRFor3Years, 
                                                                                        isLocationOtherThanCustodianAddress);  
                Map<String, String> keyMappingAdd = new Map<String, String>{
                    'DesignationCustodialBooksStateText' => 'Business_State__c',
                    'DesignationCustodialBooksStreetAddress1' => 'Street',
                    'DesignationCustodialBooksCity' => 'City',
                    'DesignationCustodialBooksZipcode' => 'PostalCode',
                    'DesignationCustodialBooksState' => 'StateCode',
                    'DesignationCustodialBooksCountry' => 'CountryCode'
                };
                if (!parList.isEmpty() && areThereAnyBusinessRecords20CSRFor3Years == 'Yes') {
                    designatedCustodialStepInfo.put('DesignationCustodialBooksCountry', 'US');
                }
                String locId = '';
                if (parList.isEmpty() || (!parList.isEmpty() && areThereAnyBusinessRecords20CSRFor3Years == 'Yes' 
                    && isLocationOtherThanCustodianAddress)) {
                    locId = LPI_AddressUtility.createLocationAndAddress(accId, LOCATION_TYPE_RECORDS_ADDRESS, name, keyMappingAdd, 
                                                                                                            designatedCustodialStepInfo);
                    LPI_AddressUtility.upsertAssociationLocRecord(accId, designatedBooksLocId, locId);
                    String tempAuthPlaceQueryFields = 'Id, Location__c';
                    String tempAuthPlaceWhereClause = 'Preliminary_Application_Reference__c = \'' + String.escapeSingleQuotes(parId) 
                                                    + '\' AND Location__r.LocationType = \'' + LOCATION_TYPE_RECORDS_ADDRESS + '\'';
                    List<Temp_AuthApplicationPlace__c> tempAAP = LPI_TempAuthApplicationPlaceDAO.getTempAuthApplicationPlaceByDymanicQuery(
                                                                        tempAuthPlaceQueryFields, tempAuthPlaceWhereClause, null ,null, null);
                    if (tempAAP.isEmpty()) {
                        LPI_AddressUtility.createTempAuthPlaceRecord(null, locId, parId);
                    } 
                    else {
                        LPI_AddressUtility.createTempAuthPlaceRecord(tempAAP[0].Id, locId, parId);
                    }
                }
                outMap.put('perAccId', personAccId);
                outMap.put('perAccIdYes', personAccId);
                outMap.put('designatedBooksLocId', locId);
            }
        } 
        catch (Exception e) {
            LPI_ExceptionManager.logException(CLASS_NAME, SAVE_DESIGNATED_CUSTODIAL, e);
            throw new LPI_Exception(e.getMessage());
        }  
    }

    /**
     * @author                                                  : MTX Group Product Team
     * @since                                                   : February 16, 2023
     * @description                                             : This method will create the Business Relationship record
     * @param busAccId                                          : Related From Id
     * @param perAccountId                                      : Related To Id
     * @param customerInfo                                      : Custodial Information Intact which contains Yes or No or blank
     * @param parId                                             : PreliminaryApplicationRef Id
     * @param areThereAnyBusinessRecords20CSRFor3Years          : Business Records 20 CSR for 3 years which contains Yes or No or blank
     * @param isLocationOtherThanCustodianAddress               : Is location other than Custodian Address which contains true or false or null
     * @return                                                  : `void`
     * @last modified by                                        : MTX Group Product Team
     * @last modified date                                      : March 7, 2024
     * @last modified details                                   : 
    */
    public static void upsertRelationshipsRecord(String busAccId, String perAccountId, String customerInfo, String parId, 
    String areThereAnyBusinessRecords20CSRFor3Years, Boolean isLocationOtherThanCustodianAddress) {
        try {
            String brId = '';
            if (areThereAnyBusinessRecords20CSRFor3Years != 'No') {
                Business_Relationships__c relations = new Business_Relationships__c();
                relations.Related_From__c = busAccId;
                relations.Related_To__c = perAccountId;
                relations.Roles__c = ACR_ROLE_DESIGNATION_CUSTODIAN;
                relations.Start_Date__c = System.today();
                List<Business_Relationships__c> acrRecList = LPI_RelationshipService.findDuplicates(
                                                        new List<Business_Relationships__c> {relations});
                if (acrRecList.isEmpty()) { 
                    relations.IsActive__c = false;   
                    if (String.isEmpty(customerInfo)) {
                        relations.Custodial_Information_intact__c = 'No'; 
                    } 
                    else {
                        relations.Custodial_Information_intact__c = customerInfo; 
                    }
                } 
                else {
                    relations.Id = acrRecList[0].Id;
                }
                brId = (String) LPI_WithoutSharingUtility.upsertSObjectRecord(new List<Business_Relationships__c> {relations})
                                                                                                            .getRecords()[0].Id;                                                                                         
            }
            PreliminaryApplicationRef updatePar = new PreliminaryApplicationRef();
            updatePar.Id = parId;
            updatePar.Designation_Of_Custodial_Relation_Id__c = brId;
         
            LPI_DML.doUpdate(updatePar);
        } 
        catch (Exception e) {
            LPI_ExceptionManager.logException(CLASS_NAME, UPSERT_RELATIONSHIPS_RECORD, e);
            throw new LPI_Exception(e.getMessage());
        } 
    }
    
    /**
     * @author                      : MTX Group Product Team
     * @since                       : December 21, 2023
     * @description                 : This method will fetch the Designated Custodial Information 
     * @param inputMap              : Input data passed from OmniScript
     * @param outMap                : Output data passed to OmniScript
     * @return                      : `void`
     * @last modified by            : MTX Group Product Team
     * @last modified date          : March 7, 2024
     * @last modified details       : S-61234 changes
    */
    public static void fetchDesignatedCustodial(Map<String, Object> inputMap, Map<String, Object> outMap) {
        try {
            String parId = (String) inputMap.get('parId');
            List<Business_Relationships__c> accConList = new List<Business_Relationships__c>();
            Map<Id, String> accConIdCustodianMap = new Map<Id, String>();
            List<Account> acc = new List<Account>();
            String accConId = '';
            String parQueryFields = 'Id, BusinessAccountNameId, Type__c, Amendment_Type__c ' ;
                                    
            String parWhereClause = '';
            List<PreliminaryApplicationRef> parList = new List<PreliminaryApplicationRef>();
            if (String.isNotBlank(parId)) {
                parWhereClause += 'Id = \'' + String.escapeSingleQuotes(parId) + '\'';
                parList = new LPI_PreliminaryApplicationRefDAO.LPI_PreliminaryApplicationRefWithoutSharingDAO()
                            .getPreliminaryApplicationRefByDymanicQuery(parQueryFields, parWhereClause, null, null, null);
            }
            if (!parList.isEmpty()) {
                String accConQueryFields = 'Id, IsActive__c, EndDate__c, Related_To__c, Custodial_Information_intact__c';
                String accConWhereClauseFields = 'Related_From__c = \'' + String.escapeSingleQuotes(parList[0].BusinessAccountNameId) + '\'' 
                                                + ' AND (IsActive__c = true OR (EndDate__c = null AND IsActive__c = false))' 
                                                + ' AND Roles__c = \'' + ACR_ROLE_DESIGNATION_CUSTODIAN + '\'';
                LPI_BusinessRelationshipDAO.LPI_BusinessRelationshipsWithoutSharingDAO accConRelWithOutSharing = 
                                    new LPI_BusinessRelationshipDAO.LPI_BusinessRelationshipsWithoutSharingDAO();
                accConList = accConRelWithOutSharing.getBusinessRelationshipsByDymanicQuery(accConQueryFields, accConWhereClauseFields, 
                                                                                                                    null, null, null);
                if (accConList.size() > 1) {
                    for (Business_Relationships__c accConRel : accConList) {
                        if (accConRel.IsActive__c == false && accConRel.EndDate__c == null) {
                            accConId = accConRel.Related_To__c;
                            accConIdCustodianMap.put(accConId, accConRel.Custodial_Information_intact__c);
                        } 
                    }                  
                } 
                else if (accConList.size() == 1) {
                    accConId = accConList[0].Related_To__c;
                    accConIdCustodianMap.put(accConId, accConList[0].Custodial_Information_intact__c);
                }
                if (!accConList.isEmpty()) {
                    String personAccQueryFields = 'Id, FirstName, LastName, MiddleName, PersonOtherPostalCode, PersonOtherState, ' 
                                                    + 'PersonOtherStateCode, Other_State__c, PersonOtherStreet, PersonOtherCity, Fax, ' 
                                                    + 'Phone, PersonEmail, PersonOtherCountry, PersonOtherCountryCode';
                    String personAccWhereClauseFields = 'Id = \'' + String.escapeSingleQuotes(accConId) + '\'';
                    acc = new LPI_AccountDAO.LPI_AccountWithoutSharingDAO().getAccountByDymanicQuery(personAccQueryFields,
                                                                                personAccWhereClauseFields, null, null, null);
                    if (!acc.isEmpty()) {
                        outMap.put('DesignationCustodialFirstName', acc[0].FirstName);
                        outMap.put('DesignationCustodialMiddleName', acc[0].MiddleName);
                        outMap.put('DesignationCustodialLastName', acc[0].LastName);
                        outMap.put('DesignationCustodialStreetAddress1', acc[0].PersonOtherStreet);
                        outMap.put('DesignationCustodialCity', acc[0].PersonOtherCity);
                        outMap.put('DesignationCustodialZipcode', acc[0].PersonOtherPostalCode);
                        if (acc[0].PersonOtherState != null) {
                            outMap.put('DesignationCustodialState', acc[0].PersonOtherStateCode);
                            outMap.put('DesignationCustodialStateFC', acc[0].PersonOtherState);
                        } 
                        else {
                            outMap.put('DesignationCustodialStateText', acc[0].Other_State__c);
                        }
                        outMap.put('DesignationCustodialTelephone', acc[0].Phone);
                        outMap.put('DesignationCustodialEmail', acc[0].PersonEmail);
                        outMap.put('DesignationCustodialFax', acc[0].Fax);
                        outMap.put('DesignationCustodialCountry', acc[0].PersonOtherCountryCode);
                        outMap.put('DesignationCustodialCountryFC', acc[0].PersonOtherCountry);
                        outMap.put('CustodialInformationIntact', accConIdCustodianMap.get(acc[0].Id));
                    }
                }  
                outMap.put('type', parList[0].Type__c);
                outMap.put('subType', parList[0].Amendment_Type__c);
                
                if (!accConIdCustodianMap.isEmpty() && !acc.isEmpty()) {
                    if (accConIdCustodianMap.get(acc[0].Id) == 'No') {
                        outMap.put('perAccId', acc[0].Id);
                    } 
                    else if (accConIdCustodianMap.get(acc[0].Id) == 'Yes') {
                        outMap.put('perAccIdYes', acc[0].Id);
                    } 
                    else {
                        outMap.put('perAccIdYes', '');
                        outMap.put('perAccId', acc[0].Id);
                    }            
                }
                Set<Id> assLocIds = new Set<Id>();
                String assLocWhereQueryFields = 'ParentRecordId = \'' + String.escapeSingleQuotes(parList[0].BusinessAccountNameId) + '\'';   
                List<AssociatedLocation> assocList = LPI_AssociatedLocationDAO.getAssociatedLocationListByDynamicQuery(
                                            new List<String>{'Id, LocationId'}, assLocWhereQueryFields, null, null, null);
                for (AssociatedLocation asLocation: assocList) {
                    assLocIds.add(asLocation.LocationId);
                }
                String addressQueryFields = 'Id, StateCode, Parent.Name, Street, ParentId, City, State, PostalCode, CountryCode, ' 
                                                + 'Country, Business_State__c';
                String addressWhereClause = 'ParentId IN ' + LPI_ServiceUtility.getStringValuesBySet(assLocIds) 
                                            + ' AND Parent.LocationType = \'' + LOCATION_TYPE_RECORDS_ADDRESS + '\'';
                LPI_AddressDAO.LPI_AddressDAOWithoutSharing addressQuery = new LPI_AddressDAO.LPI_AddressDAOWithoutSharing();
                List<Schema.Address> addressList = addressQuery.getAddressByDymanicQuery(addressQueryFields, addressWhereClause, 
                                                                                                    null, 'CreatedDate', 'DESC');
                if (!addressList.isEmpty()) {
                    outMap.put('DesignationCustodialBooksStreetAddress1', addressList[0].Street);
                    outMap.put('DesignationCustodialBooksCity', addressList[0].City);
                    outMap.put('DesignationCustodialBooksZipcode', addressList[0].PostalCode);
                    if (addressList[0].StateCode != null) {
                        outMap.put('DesignationCustodialBooksState', addressList[0].StateCode);
                        outMap.put('DesignationCustodialBooksStateFC', addressList[0].State);
                    } 
                    else {
                        outMap.put('DesignationCustodialBooksStateText', addressList[0].Business_State__c);
                    }   
                    outMap.put('DesignationCustodialBooksCountry', addressList[0].CountryCode);
                    outMap.put('DesignationCustodialBooksCountryFC', addressList[0].Country);
                    outMap.put('designatedBooksLocId', addressList[0].ParentId);
                    outMap.put('designatedBooksAddressId', addressList[0].Id);
                }  
            }          
        } 
        catch (Exception e) {
            LPI_ExceptionManager.logException(CLASS_NAME, FETCH_DESIGNATED_CUSTODIAL, e);
            throw new LPI_Exception(e.getMessage());
        }  
    }    
}