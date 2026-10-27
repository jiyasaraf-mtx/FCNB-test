/**
 * @description       : A Remote Class Used for Subordiante Controller Step
 * @author            : MTX Group Product Team | 02-01-2023
 * @group             :
 * @last modified on  : 07-24-2024
 * @last modified by  : MTX Group Product Team
 **/
global with sharing class LPI_SubordinatesInfoController implements Callable {
    private final static String RESIDENCE_TYPE = 'Residence';
    private final static String PRM_SUPERVISOR = 'Primary Supervisor';
    public final static String INDIVIDAULICENSE_APPTYPE = 'Individual';
    private static Map<String, String> acrBlIdMap = new Map<String, String>();
    private static String acrList = '';
    private static String NAME_LABEL = 'Name';
    /**
     * @author                      : MTX Group Product Team
     * @since                       : 02-01-2023
     * @description                 : This method calls invoke method
     * @param action                : String
     * @param args                  : Map<String, Object>
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
     * @description                 : This method will compare method from Omniscript and execute only that specific method
     * @param inputMap              : Map<String, Object> input map from OS
     * @param outMap                : Map<String, Object>
     * @param options               : Map<String, Object>
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
            if (methodName == 'fetchSubordinatesInfoRecords') {
                fetchSubordinatesInfoRecords(inputMap, outMap, false);
            }
        } catch (Exception e) {
            result = false;
            LPI_ExceptionManager.logException(
                'LPI_SubordinatesInfoController',
                'invokeMethod',
                e
            );
        }
        return result;
    }

    /**
     * @author                      : MTX Group Product Team
     * @since                       : 02-01-2023
     * @description                 : This method will fetch the AuthApplicationPlace , Location ,Address details
     *                                related to business license list.
     * @param inputMap              : Map<String, Object> input map from OS
     * @return                      : List<Map<String,Object>>
     * @last modified by            : MTX Group Product Team
     * @last modified date          :
     * @modified details            :
     */
    public static List<Map<String, Object>> fetchAddressDetails(
        List<BusinessLicense> blList,
        Map<String, Object> outMap,
        String fetchType
    ) {
        Map<String, Map<String, Object>> mapOfdataMap = new Map<String, Map<String, Object>>();
        List<Map<String, Object>> dataMap = new List<Map<String, Object>>();
        try {
            if (!blList.isEmpty()) {
                Set<Id> locationIdSet = new Set<Id>();
                String fields;
                String whereClause;
                for (BusinessLicense bl : blList) {
                    Map<String, Object> tempmap = new Map<String, Object>();
                    String fullName = bl.First_Name__c + bl.Last_Name__c;
                    if (acrBlIdMap.containsKey(bl.Name)) {
                        tempMap.put('acrId', acrBlIdMap.get(bl.Name));
                        acrList =
                            acrList +
                            (String) acrBlIdMap.get(bl.Name) +
                            ',';
                    }
                    tempmap.put('HASubordinateLicenseNumber', bl.License_Number_With_Rat_Name__c);
                    tempmap.put('Name', bl.Name);
                    tempmap.put('TypeAheadKeyName', bl.License_Number_With_Rat_Name__c);
                    tempmap.put('HASubordinateName', (String) fullName);
                    tempmap.put(
                        'HATitleProfessionSI',
                        (String) bl.Profession__c
                    );
                    tempmap
                        .put(
                            'HASubordinateTelephoneNumberSI',
                            bl.Account.Phone
                        );
                    tempmap.put('blAccountId', bl.accountId);
                    mapOfdataMap.put(bl.Id, tempmap);
                }
                if (!mapOfdataMap.isEmpty()) {
                    fields = 'Id, AuthorizationId, PlaceId';
                    whereClause =
                        'AuthorizationId IN ' +
                        LPI_ServiceUtility.getStringValuesByStringSet(
                            mapOfdataMap.keySet()
                        );
                    LPI_AuthApplicationPlaceDAO.LPI_AuthApplicationPlaceWithoutSharingDAO aapObj = new LPI_AuthApplicationPlaceDAO.LPI_AuthApplicationPlaceWithoutSharingDAO();
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
                        if (!mapOfdataMap.containsKey(aap.PlaceId)) {
                            mapOfdataMap.put(
                                aap.PlaceId,
                                mapOfdataMap.get(aap.AuthorizationId)
                            );
                        }
                    }
                }
                if (!locationIdSet.isEmpty()) {
                    fields = 'ID,ParentId,Parent.LocationType,Parent.Name,StateCode,City,County__c,PostalCode,State,Street,Country';
                    whereClause =
                        'ParentId IN ' +
                        LPI_ServiceUtility.getStringValuesBySet(
                            locationIdSet
                        ) +
                        ' AND Parent.LocationType = \'' +
                        String.escapeSingleQuotes(RESIDENCE_TYPE) +
                        '\'' +
                        ' AND Parent.Status__c = \'' +
                        String.escapeSingleQuotes('Open') +
                        '\'';
                    LPI_AddressDAO.LPI_AddressDAOWithoutSharing addrObj = new LPI_AddressDAO.LPI_AddressDAOWithoutSharing();
                    List<Schema.Address> addresses = new List<Schema.Address>();
                    addresses = addrObj.getAddressByDymanicQuery(
                        fields,
                        whereClause,
                        null,
                        null,
                        null
                    );
                    for (Schema.Address address : addresses) {
                        if (address.Parent.LocationType == RESIDENCE_TYPE) {
                            Map<String, Object> tempMap = mapOfdataMap.get(
                                address.ParentId
                            );
                            tempMap.put('HAStreetAddress', address.Street);
                            tempMap.put('HACity', address.City);
                            tempMap.put('HAState', address.State);
                            tempMap.put('HAZipCodeSI', address.PostalCode);
                            if (fetchType == 'typeahead') {
                                dataMap.add(tempMap);
                            } else {
                                Map<String, Object> tempblockMap = new Map<String, Object>();
                                tempblockMap.put(
                                    'HASubordinateLicenseNumber-Block',
                                    tempMap
                                );
                                dataMap.add(tempblockMap);
                            }
                        }
                    }
                    if (fetchType == 'typeahead') {
                        outMap.put('subOrdinateData', dataMap);
                    } else {
                        outMap.put('HASubordinateBlock', dataMap);
                    }
                }
            }
        } catch (Exception e) {
            LPI_ExceptionManager.logException(
                'LPI_SubordinatesInfoController',
                'fetchAddressDetails',
                e
            );
        }
        return dataMap;
    }

   
    /**
     * @author                      : MTX Group Product Team
     * @since                       : 02-01-2023
     * @description                 : This method will take input form and return the list of typeAhead Block records.
     * @param inputMap              : Map<String, Object> input map from OS
     * @return                      : Map<String,String>
     * @last modified by            : MTX Group Product Team
     * @last modified date          :
     * @modified details            :
     */
    private static List<Map<String, Object>> getTypeAheadBlock(
        Map<String, Object> inputMap
    ) {
        List<Object> aCRelationList = new List<Object>();
        Integer accountContactListLen = (Integer) inputMap.get(
            'accountContactListLen'
        );
        List<Map<String, Object>> typeAheadBlockList = new List<Map<String, Object>>();
        if (accountContactListLen > 1) {
            aCRelationList = (List<Object>) inputMap.get('accountContactList');
        } else {
            aCRelationList.add(inputMap.get('accountContactList'));
        }
        for (Object acrRef : aCRelationList) {
            Map<String, Object> obj = (Map<String, Object>) acrRef;
            Map<String, Object> typeAheadBlock = new Map<String, Object>();
            typeAheadBlock = (Map<String, Object>) obj.get(
                'HASubordinateLicenseNumber-Block'
            );
            typeAheadBlockList.add(typeAheadBlock);
        }
        return typeAheadBlockList;
    }

   

    /**
     * @author                      : MTX Group Product Team
     * @since                       : February 1, 2023
     * @description                 : This method will fetch the ACR records with role as subordinate related to particular account
     * @param inputMap              : Input data passed from OmniScript
     * @param outputMap             : Output data passed to OmniScript
     * @param isCalledFromPDF       : If true, method is called from PDF; if false, method is called in general
     * @return                      : `List<Map<String, Object>>`
     * @last modified by            : MTX Group Product Team
     * @last modified date          : October 16, 2023
     * @modified details            : Added an extra parameter of Boolean type which detects whether the method is called from PDF or not
     */
    public static List<Map<String, Object>> fetchSubordinatesInfoRecords(Map<String, Object> inputMap, 
        Map<String, Object> outputMap, Boolean isCalledFromPDF) {
        List<Map<String, Object>> dataMap = new List<Map<String, Object>>();
        try {
            if (!inputMap.containsKey('parId')) {
                return null;
            }
            List<BusinessLicense> blList = new List<BusinessLicense>();
            Id parId = (Id) inputMap.get('parId');
            String clauseType = inputMap.containsKey('readOnly') ? (String) inputMap.get('readOnly') : null;
            String accId;
            String conId;
            String fields;
             
            String whereClause;
            List<String> acrIdsList = new List<String>();
            if (String.isNotBlank(parId)) {
                fields = 'Contact__c, BusinessAccountNameId, Employee_Information_ACR_Ids__c, ';
                            
                whereClause = 'Id = \'' + String.escapeSingleQuotes(parId) + '\'';
                for (PreliminaryApplicationRef par : LPI_PreliminaryApplicationRefDAO.getPreliminaryApplicationRefByDymanicQuery(
                    fields, whereClause, '1', null, null)) {
                    accId = par.BusinessAccountNameId;
                    conId = par.Contact__c;
                     
                    if (!String.isEmpty(par.Employee_Information_ACR_Ids__c)) {
                        acrIdsList = par.Employee_Information_ACR_Ids__c.split(',');
                    }
                }
                Set<String> roleSet = new Set<String>{ PRM_SUPERVISOR };
                fields = 'Id, Related_To__c, Related_From__c, Related_To_License_Number__c, Related_To_License_Number__r.Name, '
                            + 'IsActive__c, Speciality_Or_Board_Certification__c, Supervisor_License_Number__c';
                if (clauseType == 'No' && !acrIdsList.isEmpty()) {
                    whereClause = 'Id IN ' + LPI_ServiceUtility.getStringValuesByList(acrIdsList);
                } 
                else if (clauseType == 'Yes') {
                    whereClause = 'Related_To__c = \'' + String.escapeSingleQuotes(accId) + '\'' 
                                    + ' AND ROLES__c IN ' + LPI_ServiceUtility.getStringValuesByStringSet(roleSet) 
                                    + ' AND IsActive__c = TRUE'
                                    + ' AND (Related_To_License_Number__c != NULL OR Supervisor_License_Number__c != NULL)';
                }
                List<String> blIdsList = new List<String>();
                List<String> blNameList = new List<String>();
                LPI_BusinessRelationshipDAO.LPI_BusinessRelationshipsWithoutSharingDAO withoutSharingObj = 
                    new LPI_BusinessRelationshipDAO.LPI_BusinessRelationshipsWithoutSharingDAO();
                for (Business_Relationships__c acr : withoutSharingObj.getBusinessRelationshipsByDymanicQuery(fields, 
                    whereClause, null, null, null)) {
                    if (acr.Related_To_License_Number__c != null) {
                        blIdsList.add(acr.Related_To_License_Number__c);
                        acrBlIdMap.put(acr.Related_To_License_Number__r.Name, acr.Id);
                    }
                    if (acr.Supervisor_License_Number__c != null) {
                        blNameList.add(acr.Supervisor_License_Number__c);
                        acrBlIdMap.put(acr.Supervisor_License_Number__c, acr.Id);
                    }
                }
                String blFields = 'Id, Name, First_Name__c, Last_Name__c, Middle_Name__c, Account.Phone, ContactId, '
                                    + 'Profession__c, License_Number_With_Rat_Name__c';
                whereClause = '';
                if (!blNameList.isEmpty() && !blIdsList.isEmpty()) {
                    whereClause = 'Name IN ' + LPI_ServiceUtility.getStringValuesByList(blNameList) 
                                    + ' OR Id IN ' + LPI_ServiceUtility.getStringValuesByList(blIdsList);
                } 
                else if (!blIdsList.isEmpty()) {
                    whereClause = 'Id IN ' + LPI_ServiceUtility.getStringValuesByList(blIdsList);
                } 
                else if (!blNameList.isEmpty()) {
                    whereClause = 'Name IN ' + LPI_ServiceUtility.getStringValuesByList(blNameList);
                }
                if(whereClause!=''){
                    LPI_BusinessLicenseDAO.LPI_BusinessLicenseWithoutSharingDAO withoutSharingBL = 
                        new LPI_BusinessLicenseDAO.LPI_BusinessLicenseWithoutSharingDAO();
                    blList = withoutSharingBL.getBusinessLicenseByDymanicQuery(blFields, whereClause, null, null, null);
                }
                dataMap = fetchAddressDetails(blList, outputMap, 'allData');
               
                outputMap.put('acrList', acrList);
            }
        } 
        catch (Exception e) {
            LPI_ExceptionManager.logException('LPI_SubordinatesInfoController', 'fetchSubordinatesInfoRecords', e);
        }
        return dataMap;
    }
}