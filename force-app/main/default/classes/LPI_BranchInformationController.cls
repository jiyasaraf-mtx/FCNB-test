/**
* @author      : Neeraj Avadhanam
* @since       : 14 Nov, 2022
* @description : This Class Contains the Business Logic for Branch Information
*  -------------------------------------------------------------------------------------------------------
* Version      Date                Author                  Details
*    1         14 Nov, 2022        Neeraj Avadhanam         Initial Developement
*    2         31 Jan, 2023        Neeraj Avadhanam         Code Review fix
*    3         13 Feb, 2023        Neeraj Avadhanam         Code Review fix
*    4         27 Feb, 2023        Neeraj Avadhanam         Sharing Changes
*    5         10 Jul, 2023        Neeraj Avadhanam         Link Locations to PAR(Temp Auth)
* -------------------------------------------------------------------------------------------------------
*/

global with sharing class LPI_BranchInformationController implements Callable {
    // static final String LOCATION_TYPE_BRANCH = 'Branch';
    // static final String BRANCH_LOCATION_NAME = '- Branch Location';
    // static final String OBJECT_LOCATION = 'Location';
    // static final String OBJECT_ADDRESS = 'Address';
    // private final static String INDIVIDAULICENSE_APPTYPE = 'Individual';
    // private final static String LOCATION_STATUS_OPEN = 'Open';
    // private final static String ACCOUNT_PERSON_RECORDTYPE = 'PersonAccount';
    // private final static String BUSINESS_LICENSE_STATUS_ACTIVE = 'Active';
    // private final Static Set <String> BROKER_LICENSE_TYPE_SET = new Set<String>{
    //     'Broker', 'Broker Officer', 'Broker Salesperson', 'Broker Associate', 'Broker Partner'
    // };
    
    global Object call(String action, Map<String, Object> args) {
        Map<String, Object> input = (Map<String, Object>) args.get('input');
        Map<String, Object> output = (Map<String, Object>) args.get('output');
        Map<String, Object> options = (Map<String, Object>) args.get('options');
        
        return invokeMethod(action, input, output, options);
    }
    
    /**
    * @author            Neeraj Avadhanam
    * @updated           Neeraj Avadhanam
    * @description       This method will compare method from Omniscript and execute 
    only that specific method
    * @return  `Boolean`
    */
    private Boolean invokeMethod(
    String methodName,
    Map<String, Object> inputMap,
    Map<String, Object> outMap,
    Map<String, Object> options
    ) {
    //     Boolean result = true;
    //     try {
    //         switch on methodName {
    //             when 'getBranchManagerNameByLicense' {
    //                 outMap.put('branchinfodetails', getBranchManagerNameByLicense(inputMap, outMap));
    //             }
    //             when 'saveBranchInformation' {
    //                 saveBranchInformation(inputMap);
    //             }
    //             when 'deleteBranchInformation' {
    //                 deleteBranchInformation(inputMap);
    //             }
    //             when 'fetchBranchInfoReviewFC' {
    //                 fetchBranchInfoReviewFC(inputMap, outMap);
    //             }
    //             when else {
    //                 result = false;
    //             }
    //         }
    //     } catch (Exception e) {
    //         result = false;
    //     }
    //     return result;
        return null;
    }
    
    /**
    * @author : Neeraj Avadhanam
    * @since 14 Nov 2022
    * @description This Method is used to fetch the Branch Manager Name By Licence Number Search
    * @param inputMap fetching all the input from Omniscript
    * @param outMap Passing value to Omniscript
    * @return  `List<Map<String,String>>`
    */
    // private static List<Map<String, String>> getBranchManagerNameByLicense(
    // Map<String, Object> inputMap,
    // Map<String, Object> outMap
    // ) {
    //     List<Map<String, String>> branchInfoMap = new List<Map<String, String>>();
    //     try {
    //         Map<String, String> blMap;
    //         String search = '%' + (String) inputMap.get('RSBBranchInfoLicenseNumber') + '%';
    //         String fieldsToQuery = 'Id,AccountId,Name,License_Number_With_Rat_Name__c, First_Name__c, Last_Name__c, Middle_Name__c, Business_Entity_Name__c';
    //         String whereClause = 'RegulatoryAuthorizationType.Name IN '+LPI_ServiceUtility.getStringValuesByStringSet(BROKER_LICENSE_TYPE_SET) +
    //         ' AND '+' RegulatoryAuthorizationType.Authorisation_Type__c =\''
    //         +INDIVIDAULICENSE_APPTYPE+'\''+
    //         ' AND Account.RecordType.DeveloperName = \''
    //         +ACCOUNT_PERSON_RECORDTYPE+'\''+
    //         ' AND Status = \''+BUSINESS_LICENSE_STATUS_ACTIVE+'\'' +
    //         ' AND Name LIKE \''+search+'\'' ;
    //         // fetch business license records to select license numbers based on search
    //         //Because account OWD is private. So to fetch all the licenses using without sharing method
    //         for (
    //         BusinessLicense bl : (new LPI_BusinessLicenseDAO.LPI_BusinessLicenseWithoutSharingDAO()).getBusinessLicenseByDymanicQuery(
    //         fieldsToQuery, whereClause,
    //         '10',null,null
    //         )
    //         ) {
    //             blMap = new Map<String, String>();
    //             blMap.put('Name', bl.Name);
    //             blMap.put('TypeAheadKeyName', bl.License_Number_With_Rat_Name__c);
    //             blMap.put('accId', bl.AccountId);
    //             blMap.put('RSBBranchManagerName', bl.Business_Entity_Name__c);
    //             blMap.put('RSBBranchManagerFirstName', bl.First_Name__c);
    //             blMap.put('RSBBranchManagerLastName', bl.Last_Name__c);
    //             blMap.put('RSBBranchManagerMiddleName', bl.Middle_Name__c);
    //             branchInfoMap.add(blMap);
    //         }
    //     } catch (Exception exp) {
    //         LPI_ExceptionManager.logException(
    //         'LPI_BranchInformationController',
    //         'getBranchManagerNameByLicense',
    //         exp
    //         );
    //     }
    //     return branchInfoMap;
    // }
    
    /**
    * @author : Neeraj Avadhanam
    * @description This method is used to Save one or multiple Branch Informations
    * @param inputMap fetching all the input from Omniscript
    * @param outMap Passing value to Omniscript
    * @since 17 Nov 2022
    */
//     private static void saveBranchInformation(Map<String, Object> inputMap) {
//         String parId = (String) inputMap.get('parId');
//         Map<String, object> branchInformationStepInfo =
//         (Map<String, object>) inputMap.get('BranchInformation');
//         Integer noOfBranches = (Integer) branchInformationStepInfo.get('NumOfBranches');
//         Map<String, Object> branchInfoObjMap = new Map<String, Object>();
//         List<String> locationIdsFromOsList = (List<String>) JSON.deserialize(
//         JSON.serialize(branchInformationStepInfo.get('LocationIdsFormula')),
//         List<String>.class
//         );
//         List<AssociatedLocation> associatedLocList = new List<AssociatedLocation>();
//         //added to link with PAR
//         List<Temp_AuthApplicationPlace__c> tempAuthList = new List<Temp_AuthApplicationPlace__c>();
//         List<Object> branchInfo = new List<Object>();
//         try {
//             Map<String,Schema.Location> insertLocationMap = new Map<String,Schema.Location>();
//             Map<String,Schema.Address> insertAddressMap = new  Map<String,Schema.Address>();
//             Map<String,Id> keyLocIdMap = new Map<String,Id>();
//             List<String> streetList = new List<String>();
//             List<String> stateList = new List<String>();
//             List<String> cityList = new List<String>();
//             List<String> postalList = new List<String>();
//             String businAccIdStr = (String) inputMap.get('businessAccId');
//             //If user enter multiple entries
//             if (noOfBranches > 1) {
//                 branchInfo = (List<Object>) branchInformationStepInfo.get('BranchBlock');
//             } else {
//                 branchInfo.add(branchInformationStepInfo.get('BranchBlock'));
//             }
//             for(Object obj: branchInfo){
//                 Map<String, Object> branchInfoObj = (Map<String, Object>)obj;
//                 Map<String, String> keyMappingLoc = new Map<String, String>{
//                     'rSBBranchSelectedLicenseNumber'=>'License_Number__c',
//                     'branchPhoneNum'=>'Business_Phone__c',
//                     'accCPAFirmLicensedInMo' => 'Is_the_Firm_licensed_in_MO__c',
//                     'accCPAFirmNumberofLicensedPersons'=>'Number_of_Licensed_Professional__c'
//                 };
//                 if((String) branchInfoObj.get('accCPAFirmLicensedInMo') == 'Yes') 
//                 {   keyMappingLoc.put('accCPAFirmLicenseNumber','Firm_license_Number__c');
//                 keyMappingLoc.put('accCPAFirmEmailFor','Firm_Email__c');
//                 keyMappingLoc.put('accCPAFirmPhone','Firm_Telephone_Number__c');
//             }else{
//                 keyMappingLoc.put('accCPAFirmLicenseNumberIfNo','Firm_license_Number__c');
//                 keyMappingLoc.put('accCPAFirmEmailIfNo','Firm_Email__c');
//                 keyMappingLoc.put('accCPAFirmTelephoneNumberIfNo','Firm_Telephone_Number__c');
//             } 
//             Schema.Location locationRec = (Schema.Location) LPI_VlocityUtility.createSObject(
//             branchInfoObj, 
//             keyMappingLoc,
//             OBJECT_LOCATION 
//             );
//             locationRec.Name = branchInfoObj.get('branchManagerName')+BRANCH_LOCATION_NAME;
//             locationRec.OpenDate = System.today();
//             locationRec.Status__c = null;
//             locationRec.CloseDate = null;
//             locationRec.LocationType = LOCATION_TYPE_BRANCH;
            
//             Map<String, String> keyMappingBranchAddress = new Map<String, String>{
//                 'branchStreetAddress'=>'Street',
//                 'branchCity'=>'City',
//                 'branchState'=>'StateCode',
//                 'branchZipCode'=>'PostalCode'
//             };
//             Schema.Address branchAddress = (Schema.Address) LPI_VlocityUtility.createSObject(
//             branchInfoObj,
//             keyMappingBranchAddress,
//             OBJECT_ADDRESS 
//             );
//             branchAddress.LocationType = LOCATION_TYPE_BRANCH;
//             streetList.add(branchAddress.Street);
//             cityList.add(branchAddress.City);
//             stateList.add(branchAddress.StateCode);
//             postalList.add(branchAddress.PostalCode);
            
//             String key = LPI_AddressUtility.createKeyForAddress(
//             branchAddress.Street,
//             branchAddress.City,
//             branchAddress.StateCode,
//             branchAddress.PostalCode
//             );
//             locationRec.Unique_Key__c = key;
//             // Putting Location in map
//             insertLocationMap.put(key,locationRec);
//             // Putting Address in map
//             insertAddressMap.put(key, branchAddress);
//             branchInfoObjMap.put(key, obj);
//         }
//         keyLocIdMap = LPI_AddressUtility.createLocationAndAddress(
//         insertLocationMap,insertAddressMap,
//         businAccIdStr,
//         LOCATION_TYPE_BRANCH,streetList,
//         cityList,stateList,postalList,true
//         );
//         /*This map is used to compare that if user changes the existing branch Manager then
//         deleting the loc and acc rel and creating with the link with new branch manager acc*/
//         Map<String, AssociatedLocation> ascLocToCompareMap = new Map<String, AssociatedLocation>();
//         Map<String, AssociatedLocation> ascLocWithBusinAccToCompareMap =
//         new Map<String, AssociatedLocation>();
//         List<AssociatedLocation> ascLocToDeleteForManagerChanges = 
//         new List<AssociatedLocation>();
//         List<SObject> ascLocAndTempAuthToUpdate = new List<SObject>();
//         //check location Ids list is not null
//         //queriying To fetch the associated locations with branch manager acc
//         if (locationIdsFromOsList != null) {
//             //querying using without sharing as user did not have access to object
//             LPI_AssociatedLocationDAO.LPI_AssociatedLocationWithoutSharingDAO asscLocObj 
//             = new LPI_AssociatedLocationDAO.LPI_AssociatedLocationWithoutSharingDAO();
//             String whereClauseToQueryAscLocCompare =
//             'LocationId IN ' + LPI_ServiceUtility.getStringValuesByList(
//             locationIdsFromOsList);
//             for (
//             AssociatedLocation ascLoc : asscLocObj.getAssociatedLocationByDymanicQuery(
//             'Id, ParentRecordId, LocationId, Location.Name',
//             whereClauseToQueryAscLocCompare,
//             null,
//             null,
//             null
//             )
//             ) {
//                 ascLocToCompareMap.put(ascLoc.LocationId, ascLoc);
//             }
//         }
//         //queriying To fetch the associated locations with business acc
//         if((String) inputMap.get('businessAccId') != NULL){
//             //querying using without sharing as user did not have access to object
//             LPI_AssociatedLocationDAO.LPI_AssociatedLocationWithoutSharingDAO asscLocObj 
//             = new LPI_AssociatedLocationDAO.LPI_AssociatedLocationWithoutSharingDAO();
//             String whereClauseToQueryAscLocCompare =
//             'ParentRecordId =\'' + (String) inputMap.get('businessAccId')+'\'';
//             for (
//             AssociatedLocation ascLoc : asscLocObj.getAssociatedLocationByDymanicQuery(
//             'Id, ParentRecordId, LocationId, Location.Name',
//             whereClauseToQueryAscLocCompare,
//             null,
//             null,
//             null
//             )
//             ) {
//                 ascLocWithBusinAccToCompareMap.put(ascLoc.LocationId, ascLoc);
//             }
//         }
//         Map<String, Temp_AuthApplicationPlace__c> tempAuthToCompareMap = getBranchInfoTempAuthRecords(parId);
//         for(String key : keyLocIdMap.keySet()){
//             Map<String, Object> branchObjMap =(Map<String, Object>)branchInfoObjMap.get(key);
//             /*if we change the address then we will create the new loc and address 
//             so need to update the AssociatedLoc Loc Id with new Loc*/
//             if((branchObjMap.get('branchLocId') != keyLocIdMap.get(key))){
//                 //This map will be having associated locations with Business Account
//                 if(ascLocWithBusinAccToCompareMap.get(
//                 (String) branchObjMap.get('branchLocId')) != null){
//                     ascLocAndTempAuthToUpdate.add(new AssociatedLocation (
//                     Id = ascLocWithBusinAccToCompareMap.get(
//                     (String)branchObjMap.get('branchLocId')).Id,
//                     LocationId = keyLocIdMap.get(key)
//                     ));
//                     //update Temp Auth
//                     if(!tempAuthToCompareMap.isEmpty()){ 
//                         if(tempAuthToCompareMap.containsKey((String)branchObjMap.get('branchLocId'))){
//                             ascLocAndTempAuthToUpdate.add(new Temp_AuthApplicationPlace__c(
//                             Id = tempAuthToCompareMap.get((String)branchObjMap.get('branchLocId')).Id,
//                             Location__c = keyLocIdMap.get(key)
//                             ));
//                         }
//                     }
//                 }
//                 //This map will be having associated locations with Branch Manager Account
//                 if(ascLocToCompareMap.get((String) branchObjMap.get('branchLocId')) != null){                            
//                     ascLocAndTempAuthToUpdate.add(new AssociatedLocation (
//                     Id = ascLocToCompareMap.get((String)branchObjMap.get('branchLocId')).Id,
//                     LocationId = keyLocIdMap.get(key)
//                     ));
//                 }
//             }
//             if(branchObjMap.get('branchLocIdCalc') == NULL){
//                 associatedLocList.add(createAssociatedLocation(businAccIdStr, keyLocIdMap.get(key)));
//                 associatedLocList.add(createAssociatedLocation(
//                 (String) branchObjMap.get('branchManagerAccountId'), 
//                 keyLocIdMap.get(key)));
//                 //create Temp Auth List
//                 tempAuthList.add(new Temp_AuthApplicationPlace__c(
//                 Preliminary_Application_Reference__c = parId,
//                 Location__c = keyLocIdMap.get(key)
//                 ));
//             }
//             if (!ascLocToCompareMap.isEmpty()) {
//                 String locKey = keyLocIdMap.get(key);
//                 //if the map contains the key
//                 if (ascLocToCompareMap.containsKey(locKey)) {
//                     /*check if the branch manager acc Id and business Acc Id are different
//                     from the previous Ids*/
//                     if (
//                     ascLocToCompareMap.get(locKey).ParentRecordId !=
//                     (ID) branchObjMap.get('branchManagerAccountId') &&
//                     ascLocToCompareMap.get(locKey).ParentRecordId !=
//                     (Id) inputMap.get('businessAccId')
//                     ) {
//                         ascLocToDeleteForManagerChanges.add(
//                         ascLocToCompareMap.get(keyLocIdMap.get(key))
//                         );
//                         associatedLocList.add(createAssociatedLocation(
//                         (String) branchObjMap.get('branchManagerAccountId'), 
//                         keyLocIdMap.get(key)));
//                     }
//                 }
//             }
//         }
//         //check if list is not empty to del ascloc if user changes the existing branch manager
//         //Using without sharing as user does not have access to this object
//         if (!ascLocToDeleteForManagerChanges.isEmpty()) {
//             LPI_WithoutSharingUtility.deleteSObjectRecord(ascLocToDeleteForManagerChanges);
//         }
//         /*check if list is not empty to update ascloc with new loc Id 
//         if user changes the existing branch address*/
//         if (!ascLocAndTempAuthToUpdate.isEmpty()) {
//             LPI_WithoutSharingUtility.updateSObjectRecord(ascLocAndTempAuthToUpdate);
//         }
//         //check if list is not empty to insert ascloc with new loc Id for newly added address
//         if (!associatedLocList.isEmpty()) {
//             LPI_WithoutSharingUtility.insertSObjectRecord(associatedLocList);
//         }
//         //check if temp auth list is not empty
//         if(!tempAuthList.isEmpty()){
//             LPI_DML.doInsert(tempAuthList);
//         }
//         } catch (Exception exp) {
//             LPI_ExceptionManager.logException('LPI_BranchInformationController', 
//             'saveBranchInformation', exp);
//         }
//     }

// /**
// * @author : Neeraj Avadhanam
// * @description This method is used to Delete one or multiple Branch Informations
// * @param inputMap fetching all the input from Omniscript
// * @param outMap Passing value to Omniscript
// * @since 18 Nov 2022
// */

// private static void deleteBranchInformation(Map<String, Object> inputMap) {
//     List<SObject> locationAndTempAuthListToDelete = new List<SObject>();
//     try {
//         Map<String, object> branchInformationStepInfo = (Map<String, object>) inputMap.get('BranchInformation');
//         String whereClauseToQueryAscLoc =
//         'ParentRecordId = \'' +
//         String.escapeSingleQuotes((Id) inputMap.get('businessAccId')) +
//         '\''+
//         'AND Location.LocationType = \'' +
//         LOCATION_TYPE_BRANCH +
//         '\'';
//         LPI_AssociatedLocationDAO.LPI_AssociatedLocationWithoutSharingDAO asscLocObj = new LPI_AssociatedLocationDAO.LPI_AssociatedLocationWithoutSharingDAO();
//         List<AssociatedLocation> asscLocIdQueryList = asscLocObj.getAssociatedLocationByDymanicQuery(
//         'Id, LocationId',
//         whereClauseToQueryAscLoc,
//         null,
//         null,
//         null
//         );
//         Map<String, Temp_AuthApplicationPlace__c> branchInfoTempAuthMap = getBranchInfoTempAuthRecords(
//         (String) inputMap.get('parId'));
//         List<String> locationIdsFromOsList = (List<String>) JSON.deserialize(
//         JSON.serialize(branchInformationStepInfo.get('LocationIdsFormula')),
//         List<String>.class
//         );
//         for (AssociatedLocation ascLoc : asscLocIdQueryList) {
//             if (locationIdsFromOsList != null && !locationIdsFromOsList.contains(ascLoc.locationId)
//             //added not to fetch PCA of branch type
//             && ascLoc.Id != (String) inputMap.get('pcaAscLocationId') && !branchInfoTempAuthMap.isEmpty()) {
//                 locationAndTempAuthListToDelete.add(new Schema.Location(Id = ascLoc.locationId));
//                 if(branchInfoTempAuthMap.containsKey(ascLoc.locationId)){
//                     locationAndTempAuthListToDelete.add(new 
//                     Temp_AuthApplicationPlace__c(Id = 
//                     branchInfoTempAuthMap.get(ascLoc.locationId).Id));
//                 }
//             }else if (locationIdsFromOsList == null && !asscLocIdQueryList.isEmpty()
//             //added not to fetch PCA of branch type
//             && ascLoc.Id != (String) inputMap.get('pcaAscLocationId') && !branchInfoTempAuthMap.isEmpty()) {
//                 locationAndTempAuthListToDelete.add(new Schema.Location(Id = ascLoc.locationId));
//                 if(branchInfoTempAuthMap.containsKey(ascLoc.locationId)){
//                     locationAndTempAuthListToDelete.add(new 
//                     Temp_AuthApplicationPlace__c(Id = 
//                     branchInfoTempAuthMap.get(ascLoc.locationId).Id));
//                 }
//             }
//         }
//         if (!locationAndTempAuthListToDelete.isEmpty()) {
//             LPI_WithoutSharingUtility.deleteSObject(locationAndTempAuthListToDelete);
//         } 
//     } catch (Exception exp) {
//         LPI_ExceptionManager.logException('LPI_BranchInformationController', 'deleteBranchInformation', exp);
//     }
// }
// /**
// * @author : Neeraj Avadhanam
// * @description This method is used to fetch one or multiple Branch Informations
// * @param inputMap fetching all the input from Omniscript
// * @param outMap Passing value to Omniscript
// * @since 23 Nov 2022
// */

// public static void fetchBranchInfoReviewFC(Map<String, Object> inputMap, 
// Map<String, Object> outMap) {
//     try {
//         List<Map<String, Object>> branchInfoReviewFCList = new List<Map<String, Object>>();
//         String whereClause = 'Id = \'' + String.escapeSingleQuotes((Id) inputMap.get('parId')) + '\'';
//         list<PreliminaryApplicationRef> parList = LPI_PreliminaryApplicationRefDAO.getPreliminaryApplicationRefByDymanicQuery(
//         'Id,BusinessAccountNameId, Regulatory_Authorization_Type__r.IssuingDepartment.Name',
//         whereClause,
//         null,
//         null,
//         null
//         );
//         integer noOfbranch = 0;
//         Set<Id> locIds = new Set<Id>();
//         Map<Id, Id> locIdWithAccId = new Map<Id, Id>();
//         List<AssociatedLocation> assLocReviewList;
//         LPI_AssociatedLocationDAO.LPI_AssociatedLocationWithoutSharingDAO asscLocObjForReview =
//         new LPI_AssociatedLocationDAO.LPI_AssociatedLocationWithoutSharingDAO();
//         String fieldsToQueryFetchAscLoc = 'Id, ParentRecord.Name,'+
//         'Location.License_Number__c,'+
//         'LocationId,ParentRecordId, Location.Firm_license_Number__c';
//         if(!parList.isEmpty()){
//             String whereClauseForAscLocFetch =
//             'ParentRecordId = \'' +
//             String.escapeSingleQuotes(parList[0].BusinessAccountNameId) +
//             '\'' +
//             ' AND ' +
//             'Location.LocationType =\'' +
//             LOCATION_TYPE_BRANCH +
//             '\''+' AND Location.License_Number__c != NULL';
//             assLocReviewList = asscLocObjForReview.getAssociatedLocationByDymanicQuery(
//             fieldsToQueryFetchAscLoc,
//             whereClauseForAscLocFetch,
//             null,
//             null,
//             null
//             );
//             //Added fo issue I-250997
//             outMap.put('boardName', parList[0].Regulatory_Authorization_Type__r.IssuingDepartment.Name);
//         }
//         Set<String> licenseNumberSet = new Set<String>();
//         for (AssociatedLocation ascLoc : assLocReviewList) {
//             //added not to fetch PCA of branch type
//             if(ascLoc.Id != (String) inputMap.get('pcaAscLocationId')){
//                 locIds.add(ascLoc.LocationId);
//                 licenseNumberSet.add(ascLoc.Location.License_Number__c);
//                 if(String.isNotBlank(ascLoc.Location.Firm_license_Number__c)){
//                     licenseNumberSet.add(ascLoc.Location.Firm_license_Number__c);
//                 }
//                 locIdWithAccId.put(ascLoc.LocationId, ascLoc.ParentRecordId);
//             }
//         }
//         // S-43964 Started Here ----- Added By Mahesh
//         Map<String, Object> licenseNumberWithBL = new Map<String, Object>();
//         Map<String, String> licenseNumberWithRATMap = new Map<String, String>();
//         String fieldsToQuery = 'Id, AccountId, Name, First_Name__c, Last_Name__c, Middle_Name__c, License_Number_With_Rat_Name__c, Business_Entity_Name__c';
//         //checking this set is empty, Because giving error - expecting a colon, found 'null'
//         if(!licenseNumberSet.isEmpty()){
//             String whereClauseForBL = 'Name IN ' + LPI_ServiceUtility.getStringValuesByStringSet(
//             licenseNumberSet);
//             for (
//             BusinessLicense bl : LPI_BusinessLicenseDAO.fetchBusinessLicenseRecordsWithOrderByLimit(
//             fieldsToQuery,
//             whereClauseForBL,null,null
//             )
//             ) {
//                 if (licenseNumberSet.contains(bl.Name)) {
//                     String accNameAndIdStr = bl.Business_Entity_Name__c + '-' 
//                     + bl.First_Name__c + '-'
//                     + bl.Last_Name__c + '-'
//                     + bl.Middle_Name__c + '-'
//                     + String.ValueOf(bl.AccountId);
//                     licenseNumberWithBL.put(bl.Name, accNameAndIdStr);
//                     licenseNumberWithRATMap.put(bl.Name,bl.License_Number_With_Rat_Name__c);
//                 }
//             }
//         }
//         // S-43964 Ended Here ----- Added By Mahesh
//         String addressFieldsToQuery =
//         'Id,Name,ParentId,Parent.License_Number__c,Parent.Name,' +
//         ' Parent.Business_Phone__c,Parent.Is_the_Firm_licensed_in_MO__c,' +
//         'Parent.Firm_license_Number__c,Parent.Firm_Email__c,Parent.Firm_Telephone_Number__c,' +
//         'Parent.Number_of_Licensed_Professional__c, State, Street, City, PostalCode,StateCode';
//         //checking this set is empty, Because giving error - expecting a colon, found 'null'
//         if(!locIds.isEmpty()){
//             String addressWhereClause =
//             'ParentId IN ' +
//             LPI_ServiceUtility.getStringValuesBySet(locIds) +
//             ' AND ' +
//             'LocationType = \'' +
//             LOCATION_TYPE_BRANCH +
//             '\'';
//             for (
//             Schema.Address addReview :new LPI_AddressDAO.LPI_AddressDAOWithoutSharing().getAddressByDymanicQuery(
//             addressFieldsToQuery,
//             addressWhereClause,
//             null,
//             null,
//             null
//             )
//             ) {
//                 noOfbranch = noOfbranch + 1;
//                 Map<String, Object> rSBBranchInfoLicenseNumberBLK = new Map<String, Object>();
//                 List<String> branchManagerName = addReview.Parent.Name.split('-');
//                 Map<String, Object> branchInfoReviewMap = new Map<String, Object>();
//                 branchInfoReviewMap.put('branchStreetAddress', addReview.Street);
//                 branchInfoReviewMap.put('BranchNum', 'Branch Manager Information ' + String.ValueOf(noOfbranch));
//                 branchInfoReviewMap.put('branchManagerName', branchManagerName[0]);
//                 branchInfoReviewMap.put('branchSelectedLicenseNum', licenseNumberWithRATMap.get(addReview.Parent.License_Number__c) );
//                 branchInfoReviewMap.put('branchState', addReview.StateCode);
//                 branchInfoReviewMap.put('branchCity', addReview.City);
//                 branchInfoReviewMap.put('branchZipCode', addReview.PostalCode);
//                 branchInfoReviewMap.put('branchPhoneNum', addReview.Parent.Business_Phone__c);
//                 // S-43964 Started Here ----- Added By Mahesh
//                 rSBBranchInfoLicenseNumberBLK.put('RSBBranchInfoLicenseNumber', licenseNumberWithRATMap.get(addReview.Parent.License_Number__c) );
//                 rSBBranchInfoLicenseNumberBLK.put('Name', addReview.Parent.License_Number__c);
                
//                 List<String> branchManageNameaAndAccIdList = String.ValueOf(
//                 licenseNumberWithBL.get(addReview.Parent.License_Number__c)
//                 ).split('-');
//                 String banchManagerFirstName = branchManageNameaAndAccIdList.size() >= 2 ? branchManageNameaAndAccIdList[1]: '';
//                 String banchManagerLastName = branchManageNameaAndAccIdList.size() >= 3 ? branchManageNameaAndAccIdList[2]: '';
//                 String banchManagerMiddleName = branchManageNameaAndAccIdList.size() >= 4 && branchManageNameaAndAccIdList[3] != 'null'
//                 ? branchManageNameaAndAccIdList[3]: '';
//                 rSBBranchInfoLicenseNumberBLK.put(
//                 'RSBBranchManagerName',
//                 branchManageNameaAndAccIdList.size() >= 1 ? branchManageNameaAndAccIdList[0]: '');
//                 rSBBranchInfoLicenseNumberBLK.put('RSBBranchManagerFirstName', banchManagerFirstName);
//                 branchInfoReviewMap.put('RSBBranchManagerFirstNameReview',banchManagerFirstName);
//                 rSBBranchInfoLicenseNumberBLK.put('RSBBranchManagerLastName',banchManagerLastName);
//                 branchInfoReviewMap.put('RSBBranchManagerLastNameReview',banchManagerLastName);
//                 rSBBranchInfoLicenseNumberBLK.put('RSBBranchManagerMiddleName',banchManagerMiddleName);
//                 branchInfoReviewMap.put('RSBBranchManagerMiddleNameReview',banchManagerMiddleName);
//                 rSBBranchInfoLicenseNumberBLK.put(
//                 'accId',
//                 branchManageNameaAndAccIdList.size() == 5 ? branchManageNameaAndAccIdList[4] : ''
//                 );
//                 branchInfoReviewMap.put('RSBBranchInfoLicenseNumber-Block', rSBBranchInfoLicenseNumberBLK);
//                 branchInfoReviewMap.put('branchLocId', addReview.ParentId);
//                 branchInfoReviewMap.put('branchAddressId', addReview.Id);
//                 if (addReview.Parent.Is_the_Firm_licensed_in_MO__c == 'Yes') {
//                     rSBBranchInfoLicenseNumberBLK.put(
//                     'accCPAFirmLicensedNumberIfYes',
//                     licenseNumberWithRATMap.get( addReview.Parent.Firm_license_Number__c )
//                     );
//                     rSBBranchInfoLicenseNumberBLK.put('accCPAFirmEmail', addReview.Parent.Firm_Email__c);
//                     rSBBranchInfoLicenseNumberBLK.put(
//                     'accCPAFirmTelephoneNumber',
//                     addReview.Parent.Firm_Telephone_Number__c
//                     );
//                     branchInfoReviewMap.put('AccCPAFirmLicensedNumberIfYes-Block', rSBBranchInfoLicenseNumberBLK);
//                 } else {
//                     branchInfoReviewMap.put('accCPAFirmLicenseNumberIfNo', addReview.Parent.Firm_license_Number__c);
//                     branchInfoReviewMap.put('accCPAFirmEmailIfNo', addReview.Parent.Firm_Email__c);
//                     branchInfoReviewMap.put(
//                     'accCPAFirmTelephoneNumberIfNo',
//                     addReview.Parent.Firm_Telephone_Number__c
//                     );
//                 }
//                 branchInfoReviewMap.put('accCPAFirmLicensedNumberIfYes', licenseNumberWithRATMap.get( addReview.Parent.Firm_license_Number__c ));
//                 branchInfoReviewMap.put('Name1', addReview.Parent.Firm_license_Number__c );
//                 branchInfoReviewMap.put('accCPAFirmEmail', addReview.Parent.Firm_Email__c);
//                 branchInfoReviewMap.put('accCPAFirmTelephoneNumber', addReview.Parent.Firm_Telephone_Number__c);
//                 branchInfoReviewMap.put('accCPAFirmLicensedInMo', addReview.Parent.Is_the_Firm_licensed_in_MO__c);
//                 branchInfoReviewMap.put(
//                 'accCPAFirmNumberofLicensedPersons',
//                 addReview.Parent.Number_of_Licensed_Professional__c
//                 );
//                 // S-43964 Ended Here ----- Added By Mahesh
//                 //Added fo issue I-250997
//                 branchInfoReviewMap.put('boardName', parList[0].Regulatory_Authorization_Type__r.IssuingDepartment.Name);
//                 branchInfoReviewFCList.add(branchInfoReviewMap);
//             }
//             outMap.put('BranchBlock', branchInfoReviewFCList);
//             outMap.put('AddBranchCheckBox', branchInfoReviewFCList.size() > 0 ? true : false);
//             outMap.put('isBranchDataFound', true);
//         }else{
//             outMap.put('isBranchDataFound', false);
//         }
//     } catch (Exception exp) {
//         LPI_ExceptionManager.logException('LPI_BranchInformationController', 'fetchBranchInfoReviewFC', exp);
//     }
// }

// /**
// * @author : Neeraj Avadhanam
// * @description : This method is just to create(not insert) and return the Associated location record
// * @param accId : account Id
// * @param locId : location Id
// * @since 13 Feb 2023
// */

// private static AssociatedLocation createAssociatedLocation(String accId, String locId){
//     AssociatedLocation ascLocation = new AssociatedLocation();
//     ascLocation.ParentRecordId = accId;
//     ascLocation.LocationId = locId;
//     return ascLocation;
// }
// /**
// * @author : Neeraj Avadhanam
// * @description : This method is to return Temp Auth Record related to the PAR Id and branch loc type
// * @param parId : Preliminary Application Reference Id
// * @since 10 Jul 2023
// */

// private static Map<String, Temp_AuthApplicationPlace__c> getBranchInfoTempAuthRecords(String parId){
//     Map<String, Temp_AuthApplicationPlace__c> branchInfoTempAuthMap = new Map<String, Temp_AuthApplicationPlace__c>();
//     if(String.isNotBlank(parId)){
//         for (Temp_AuthApplicationPlace__c tempAuthRec : LPI_TempAuthApplicationPlaceDAO.getTempAuthApplicationPlaceByDymanicQuery(
//         'Id, Location__r.LocationType,Location__c',
//         'Preliminary_Application_Reference__c =\'' + String.escapeSingleQuotes(parId) + '\''+
//         ' AND Location__r.LocationType =\''+ LOCATION_TYPE_BRANCH+'\''+
//         ' AND Location__r.License_Number__c != NULL',
//         null,null,null
//         )) {
//             branchInfoTempAuthMap.put(tempAuthRec.Location__c, tempAuthRec);
//         }
//     }
//     return branchInfoTempAuthMap;
// }
}