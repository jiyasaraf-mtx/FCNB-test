/**
 * @description       : This class fetch the  Mailing Address details on the basis of Location Type
 * @author            : Mallika Nagula
 * @group             : 
 * @last modified on  : 07-13-2024
 * @last modified by  : MTX Group Inc
**/
global with sharing class LPI_FetchMailingAddress 
//implements Callable
 {
    public void method1(){
        
    }
   // *************************************** ALL CONSTANTS ************************************************
//     private final static String MAILING_TYPE = 'Mailing';
//     private final static String STATUS = 'Open';
//     private final static String INDIVIDAULICENSE_APPTYPE = 'Individual';
//     private final static String CLASS_NAME = 'LPI_FetchMailingAddress';
//     private final static String INVOKE_METHOD = 'invokeMethod';
//     private final static String FETCH_MAILING_ADDRESS_DETAILS= 'fetchMailingAddressFromBusinessLicense';
//     private final static String FETCH_NEW_MAILING_ADDRESS_DETAILS = 'fetchNewMailingAddressFromPAR';

//     /**
//      * @author                      : Mallika Nagula
//      * @since                       : 13-06-2023
//      * @description                 : This method calls invoke method
//      * @param action                : String
//      * @param args			        : Map<String, Object>
//      * @return                      : Object
//      * @last modified by            : MTX Group Inc
//      * @last modified date          :
//      * @modified details            :
//      */
//     global Object call(String action, Map<String, Object> args) {
//         Map<String, Object> input = (Map<String, Object>) args.get('input');
//         Map<String, Object> output = (Map<String, Object>) args.get('output');
//         Map<String, Object> options = (Map<String, Object>) args.get('options');
//         return invokeMethod(action, input, output, options);
//     }
//     /**
//      * @author                      : Mallika Nagula
//      * @since                       : 13-06-2023
//      * @description                 : This method will compare method from Omniscript and execute only that specific method
//      * @param inputMap		        : Map<String, Object> input map from OS
//      * @param outMap 		        : Map<String, Object>
//      * @param options 		        : Map<String, Object>
//      * @return                      : Boolean
//      * @last modified by            : MTX Group Inc
//      * @last modified date          :
//      * @modified details            :
//      */
//     private Boolean invokeMethod(
//         String methodName,
//         Map<String, Object> inputMap,
//         Map<String, Object> outMap,
//         Map<String, Object> options
//     ) {
//         Boolean result = false;
//         try {
//             if (methodName == FETCH_NEW_MAILING_ADDRESS_DETAILS) {
//                 fetchNewMailingAddressFromPAR(inputMap, outMap);
//             } 

//         } catch (Exception e) {
//             result = false;
//             LPI_ExceptionManager.logException(
//                 CLASS_NAME,
//                 INVOKE_METHOD,
//                 e
//             );
//         }
//         return result;
//     }

//     /**
//      * @author                      : Mallika 
//      * @since                       : 13-06-2023
//      * @description                 : This method will fetch the AuthApplicationPlace , Location ,Address details
//      *                                related to business license .
//      * @param outMap		        : Map<String, Object> output map, Passing value to Omniscript
//      * @return                      : List<Map<String,Object>>
//      * @last modified by            : MTX Group Inc
//      * @last modified date          :
//      * @modified details            :
//      */
// 	private static void fetchMailingAddressFromBusinessLicense(Map<String, Object> inputMap, Map<String, Object> outMap, String previousAdreessId) {
//         Id blId = (Id) inputMap.get('blId');
//         Map<Id, Map<String, Object>> mapOfdataMap = new Map<Id, Map<String, Object>>();
//         try {
//             Set<Id> locationIdSet = new Set<Id>();
//             String fields;
//             String whereClause;
            
//             //check if blId is not empty
//             if (String.isNotBlank(blId)) {
//                 if(String.isBlank(previousAdreessId) ){
//                     fields = 'Id, AuthorizationId, PlaceId';
//                     whereClause =
//                         'AuthorizationId = \'' +
//                         String.escapeSingleQuotes(blId) +
//                         '\'' ;
//                     //fetching  AuthApplicationPlace records in Without context because to get ParentId specifically based on businesslicense Ids
//                     LPI_AuthApplicationPlaceDAO.LPI_AuthApplicationPlaceWithoutSharingDAO aapObj = new LPI_AuthApplicationPlaceDAO.LPI_AuthApplicationPlaceWithoutSharingDAO();
//                     for (
//                         AuthApplicationPlace aap : aapObj.getAuthApplicationPlaceByDymanicQuery(
//                             fields,
//                             whereClause,
//                             null,
//                             null,
//                             null
//                         )
//                     ) {
//                         locationIdSet.add(aap.PlaceId);
//                     }
//                     //added locationIdSet.empty() check before query
//                     whereClause =
//                         '(ParentId IN ' +
//                         LPI_ServiceUtility.getStringValuesBySet(
//                             locationIdSet
//                         ) +
//                         'AND Parent.LocationType = \'' +
//                         String.escapeSingleQuotes(MAILING_TYPE) +
//                         '\'' +
//                         ' AND Parent.Status__c = \'' +
//                         String.escapeSingleQuotes('Open') +
//                         '\')';
//                 } else{
//                     locationIdSet.add(previousAdreessId);
//                     whereClause = 'Id IN ' +
//                     LPI_ServiceUtility.getStringValuesBySet(
//                         locationIdSet
//                     );
//                 }
//                 if (!locationIdSet.isEmpty()) {
//                     fields = 'ID,ParentId,Parent.LocationType,Parent.Name,Business_State__c,StateCode,City,County__c,PostalCode,State,Street,Country,CountryCode';
//                     LPI_AddressDAO.LPI_AddressDAOWithoutSharing addrObj = new LPI_AddressDAO.LPI_AddressDAOWithoutSharing();
//                     Set<Id> mailingLocIdList = new Set<Id>();
//                     //making the list the locationId for which the locationType is mailing
//                     for (
//                         Schema.Address address : addrObj.getAddressByDymanicQuery(
//                             fields,
//                             whereClause,
//                             null,
//                             null,
//                             null
//                         )
//                     ) {
//                             outMap.put('PreviousAddressId', address.Id);
//                             outMap.put('MailingStreetRO', address.Street);
//                             outMap.put('MailingCityRO', address.City);
//                             outMap.put('CurrentMailingCountryRO', address.CountryCode);
//                             outMap.put('CurrentMailingCountryROReview', address.Country);
//                             outMap.put('CurrentMailingZipCodeRO', address.PostalCode);
//                             outMap.put('currentMailingCountyRO', address.County__c);
//                             if (address.CountryCode == 'US') {
//                                 outMap.put('CurrentMailingStateRO', address.StateCode);
//                                 outMap.put('CurrentMailingStateROReview', address.State);
//                             }else{
//                                 outMap.put('CurrentMailingStateROText', address.Business_State__c);
//                             }
//                     }
//                 }
//             }
//         } catch (Exception e) {
//             LPI_ExceptionManager.logException(
//                 CLASS_NAME,
//                 FETCH_MAILING_ADDRESS_DETAILS,
//                 e
//             );
//         }
//     }

//     /**
//      * @author                      : Mallika 
//      * @since                       : 13-06-2023
//      * @description                 : This method will fetch the AuthApplicationPlace , Location ,Address details
//      *                                related to PAR  .
//      * @param outMap		        : Map<String, Object> output map, Passing value to Omniscript
//      * @return                      : List<Map<String,Object>>
//      * @last modified by            : MTX Group Inc
//      * @last modified date          :
//      * @modified details            :
//      */
//     public static void fetchNewMailingAddressFromPAR(Map<String, Object> inputMap, Map<String, Object> outMap) {
//      try {
//             String fields;
// 			String whereClause;
// 			PreliminaryApplicationRef par;
//             Id parId = (Id) inputMap.get('parid');
// 			Map<Id, Id> mapOfTempAuthAppPlaceIdWithLocationId = new Map<Id, Id>();
// 			// Query to fetch Type and subtype on par record
//             if (String.isNotBlank(parId)) {
//                 fields = 'Id, Amendment_Type__c, Type__c, PreviousAdreessId__c, Business_License__c ';
//                 whereClause = 'Id = \'' + String.escapeSingleQuotes(parId) + '\'';
//             }
// 			List<PreliminaryApplicationRef> parList = LPI_PreliminaryApplicationRefDAO.getPreliminaryApplicationRefByDymanicQuery(
// 				fields,
// 				whereClause,
// 				'1',
// 				null,
// 				null
// 			);
//             if ( !parList.isEmpty() ) {
//                 fetchMailingAddressFromBusinessLicense(inputMap, outMap, parList[0].PreviousAdreessId__c);
//                 fields = 'ID, Location__c,Location__r.LocationType';
// 				whereClause = 'Preliminary_Application_Reference__c = \'' + String.escapeSingleQuotes(parId) + '\'' + 
//                     'AND Location__r.LocationType = \'' +
//                                                 String.escapeSingleQuotes(MAILING_TYPE) +
//                                                 '\'';  
//                 LPI_TempAuthApplicationPlaceDAO.LPI_TempAuthApplicationPlaceWithoutSharingDAO temp_AAPList = new  LPI_TempAuthApplicationPlaceDAO.LPI_TempAuthApplicationPlaceWithoutSharingDAO();
//                 for (Temp_AuthApplicationPlace__c temp_AAP : temp_AAPList.getTempAuthApplicationPlaceByDymanicQuery(
//                                 fields,
//                                 whereClause,
//                                 '1',
//                                 null,
//                                 null
//                             )
//                         ) 
//                 {
//                     mapOfTempAuthAppPlaceIdWithLocationId.put(temp_AAP.Location__c, temp_AAP.Id);
//                  }
//                     if (!mapOfTempAuthAppPlaceIdWithLocationId.isEmpty()) {
//                         List<Schema.Address> addresses;
//                         fields = 'ID,ParentId,Parent.LocationType,Parent.Name,StateCode,Business_State__c,CountryCode,City,County__c,PostalCode,State,Street,Country';
//                         whereClause = 'ParentId IN ' + LPI_ServiceUtility.getStringValuesBySet(mapOfTempAuthAppPlaceIdWithLocationId.keySet());
//                          LPI_AddressDAO.LPI_AddressDAOWithoutSharing sharingObj = new LPI_AddressDAO.LPI_AddressDAOWithoutSharing();
//                         for (Schema.Address address : sharingObj.getAddressByDymanicQuery(
//                                 fields,
//                                 whereClause,
//                                 '1',
//                                 null,
//                                 null
//                                 )
//                             ) {
//                                 outMap.put('MailingCityNew', address.City);
//                                 outMap.put('MailingStreetNew', address.Street);
//                                 outMap.put('MailingZipCodeNew', address.PostalCode);
//                                 outMap.put('MailingCountryNew', address.CountryCode);
//                                 outMap.put('MailingCountryReview', address.Country);
//                                 outMap.put('MailingCountyEdit', address.County__c);
//                                 if (address.CountryCode == 'US') {
//                                     outMap.put('MailingStateNew', address.StateCode);
//                                     outMap.put('MailingStateNewReview', address.State);
//                                 } else {
//                                     outMap.put('MailingStateTextNew', address.Business_State__c);
//                                 }
//                         }
//                     }   
//             }
//         }
//         catch (Exception e) {
//             LPI_ExceptionManager.logException(
//                 CLASS_NAME,
//                 FETCH_NEW_MAILING_ADDRESS_DETAILS,
//                 e
//             );
//         }
//     }
}