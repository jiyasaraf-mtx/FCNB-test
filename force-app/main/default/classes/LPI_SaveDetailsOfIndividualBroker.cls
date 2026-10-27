/**
* @author                      : Vamsi Mudaliar
* @since                       : 10 Dec, 2022
* @description                 :  This Method is Used to Fetch and Store Individual Business Information on Address and Location Objects.
* @group                      : MTX Group Inc
* @last modified by            : Uzma Md
* @last modified date          : 16th Feb 2023
* @last modified details       : Code Review Fixes, Added DAO, Optimizing code and Sanitising input in soql query. 
*/
global with sharing class LPI_SaveDetailsOfIndividualBroker implements Callable {
    
    private static Map<String,String> osFieldToLocationAPIMap; 
    private static Map<String,String> osFieldToAddressAPIMap; 
    public final static String YES = 'Yes';
    public final static String NO = 'No';
    public final static String ACCOUNTANCY = 'Accountancy';
    
    /**
    * @description 
    * @author Ayush Dev | 05-06-2024 
    * @param action 
    * @param args 
    * @return Object 
    **/
    global Object call(String action, Map<String, Object> args) {
        Map<String, Object> input = (Map<String, Object>) args.get('input');
        Map<String, Object> output = (Map<String, Object>) args.get('output');
        Map<String, Object> options = (Map<String, Object>) args.get('options');
        return invokeMethod(action, input, output, options);
    }
    
    /**
    * @author               : Vamsi Mudaliar
    * @param methodName     : InvokeMethod
    * @param inputMap       : Input Parameter Passed from Omniscript
    * @param outMap         : Output Passed to Omniscript
    * @param options        : Extra Options passed from Omniscript
    * @return  `Boolean`
    */
    private Boolean InvokeMethod(String methodName, Map<String, Object> inputMap, Map<String, Object> outMap, Map<String, Object> options) {
        try {
            
            if (methodName == 'fetchBusinessDetails') {
                fetchBusinessDetails(inputMap, outMap);
            } 
            // else if (methodName == 'updateBusinessDetails') {
            //     updateBusinessDetails(inputMap, outMap);
            // }
            
            return true;
            
        } catch (Exception ex) {
            LPI_ExceptionManager.logException('LPI_SaveDetailsOfIndividualBroker', 'InvokeMethod', ex);
        }
        
        return false;
    }
    /**
    * @author                      : Vamsi Mudaliar
    * @since                       : 03 Oct 2022
    * @description                 :  This method is used to Get LocationRecords from PAR if BusinessLicense is Empty or else from business license. 
    * @param parId 
    * @return                      : `Set<Id>`
    * @last modified by            : Uzma Md
    * @last modified date          : 16 Feb 2023
    * @modified details            : Code Review Fixes
    */
    private static Set<Id> getLocationRecordsBasedOnPAR(List<PreliminaryApplicationRef> parInfoList) {
        try {
            Set<Id> locationSet = new Set<Id>();  
            Set<String> licenseToSkipSet = new Set<String>{
                LPI_LiteralConstant.BROKER_OFFICER,
                LPI_LiteralConstant.BROKER_PARTNER,
                LPI_LiteralConstant.BROKER_ASSOCIATE,
                'Private Investigator'
            };
            if(parInfoList.isEmpty()) {
                return locationSet;                   
            }  
            else if(parInfoList[0].Business_License__c!=null && 
            !parInfoList[0].Business_License__r.Is_Migrated_Data__c &&
            (!licenseToSkipSet.contains(parInfoList[0].Regulatory_Authorization_Type__r.Name) && 
            parInfoList[0].Type__c!=LPI_LiteralConstant.PAR_SOBJECT_TYPE_AMENDMENT)
            ) {
                String businesslicenseId = parInfoList[0].Business_License__c;
                String authPlaceQueryFields = 'Id, AuthorizationId,PlaceId,Authorization.AccountId';
                String authPlaceWhereClause = 'AuthorizationId =\''+String.escapeSingleQuotes(businesslicenseId)+'\'';
                for(AuthApplicationPlace authAppPlace : LPI_AuthApplicationPlaceDAO.getAuthApplicationPlaceByDymanicQuery(authPlaceQueryFields,authPlaceWhereClause,null,null,null)){
                    locationSet.add(authAppPlace.PlaceId);
                }
                String locQueryFields = 'ID,LocationType';
                String locWhereClause = 'LocationType != \'' +LPI_LiteralConstant.LOCATION_TYPE_BUSINESS_ADDRESS+ '\' AND ID IN '+LPI_ServiceUtility.getStringValuesByList(new List<Id>(locationSet));
                for(Schema.Location locRec:LPI_LocationDAO.getLocationByDymanicQuery(locQueryFields,locWhereClause,null,null,null)) {
                    locationSet.remove(locRec.Id);
                }            
                
            }  else {
                String tempAuthPlaceQueryFields = 'ID,Location__c';
                String tempAuthPlaceWhereClause = 'Preliminary_Application_Reference__c =\''+String.escapeSingleQuotes(parInfoList[0]?.Id)+ 
                '\' AND Location__r.LocationType = \'' +LPI_LiteralConstant.LOCATION_TYPE_BUSINESS_ADDRESS+ '\'';
                for(Temp_AuthApplicationPlace__c tempAuthPlaceRec : LPI_TempAuthApplicationPlaceDAO.getTempAuthApplicationPlaceByDymanicQuery(tempAuthPlaceQueryFields,tempAuthPlaceWhereClause,null,null,null)){
                    locationSet.add(tempAuthPlaceRec.Location__c);
                }
            }
            return locationSet;
        } catch(Exception ex) {
            LPI_ExceptionManager.logException('LPI_SaveDetailsOfIndividualBroker', 'getLocationRecordsBasedOnPAR', ex);
        }
        return null;
    }
    /**
    * @author                      : Vamsi Mudaliar
    * @since                       : 03 Oct 2022
    * @description                 : This Method is used to Fetch Business Information from the associated PAR Record. if it exists.
    * @param inputMap              : Input Parameter Passed from Omniscript
    * @param outMap                : Output Passed to Omniscript
    * @return                      : `void`
    * @last modified by            : Uzma Md
    * @last modified date          : 13 December 2023
    * @modified details            : Piyush Aneja - I-246030 and I-245626 Fix and Development
    */
    public static void fetchBusinessDetails(Map<String, Object> inputMap, Map<String, Object> outMap) {
        try {
            
            String parId = (String) inputMap.get('parid');
            if(parId==null) {
                return;
            }
            Set<Id> locationSet = new Set<Id>();
            String parQueryFields = 'Id,Business_License__c,Type__c,Regulatory_Authorization_Type__r.Name,Amendment_Type__c,Board_Name__c,Business_License__r.Is_Migrated_Data__c';
            String parWhereClause = 'Id = \''+String.escapeSingleQuotes(parId)+'\'';
            List<PreliminaryApplicationRef> parInfoList = LPI_PreliminaryApplicationRefDAO.getPreliminaryApplicationRefByDymanicQuery(parQueryFields,parWhereClause,null,null,null);
            // if( parInfoList[0]?.Wish_to_provide_Entity_details__c!= null){
            //     outMap.put('WishToProvideEntityDetails', parInfoList[0]?.Wish_to_provide_Entity_details__c);
            // }else
             if (parInfoList[0]?.Board_Name__c != ACCOUNTANCY){
                outMap.put('WishToProvideEntityDetails', 'Yes');
            }
            outMap.put('BoardName', parInfoList[0]?.Board_Name__c);

            locationSet = getLocationRecordsBasedOnPAR(parInfoList);

            if (parInfoList[0]?.Board_Name__c == ACCOUNTANCY && parInfoList[0]?.Type__c == 'Renewal' && !locationSet.isEmpty()) {
                outMap.put('WishToProvideEntityDetailsRO', 'Yes');
            } else {
                outMap.put('WishToProvideEntityDetailsRO', 'No');
            }
            String businessLicenseId = (!parInfoList.isEmpty() && parInfoList[0]?.Business_License__c!=null)?parInfoList[0]?.Business_License__c:null;
            List<Schema.Address> address = new List<Schema.Address>();
            String addressQueryFields = 'Id,Business_State__c, City,County__c,Country, CountryCode, Street,State, PostalCode, StateCode,';
            addressQueryFields+='Parent.LocationType,Parent.Business_Website__c,Parent.Firm_Email__c,Parent.Business_Phone__c,Parent.Fictitious_Name__c,Parent.Name ';
            if(!locationSet.isEmpty()) {
                String addressWhereClause='ParentId IN ' + LPI_ServiceUtility.getStringValuesByList(new List<Id>(locationSet));
                address = LPI_AddressDAO.getAddressByDymanicQuery(addressQueryFields,addressWhereClause,null,null,null);
            }
            if(address.isEmpty()) {
                return;
            }
            if(address[0].Parent.Name == 'Business Address'){
                outMap.put('BusinessName',null);
            }else{
                outMap.put('BusinessName',address[0].Parent.Name);
            }
            outMap.put('FictitiousName', address[0].Parent.Fictitious_Name__c);
            outMap.put('BusinessPhone', address[0].Parent.Business_Phone__c);
            outMap.put('BusinessEmail', address[0].Parent.Firm_Email__c);
            outMap.put('BusinessNameRO',address[0].Parent.Name);
            outMap.put('FictitiousNameRO', address[0].Parent.Fictitious_Name__c);
            outMap.put('BusinessPhoneRO', address[0].Parent.Business_Phone__c);
            outMap.put('BusinessEmailRO', address[0].Parent.Firm_Email__c);
            outMap.put('StreetAddress1', address[0].Street);
            outMap.put('StreetAddress1RO', address[0].Street);
            outMap.put('BusinessCity', address[0].City);
            outMap.put('BusinessCityRO', address[0].City);
            outMap.put('BusinessStateOtherThanUS', address[0].Business_State__c);
            outMap.put('BusinessStateOtherThanUSRO', address[0].Business_State__c);
            outMap.put('USBusinessState',address[0].StateCode);
            outMap.put('BusinessStateRO',address[0].Business_State__c==null?address[0].State:address[0].Business_State__c);
            outMap.put('BusinessZipcode', address[0].PostalCode);
            outMap.put('BusinessWebsite',address[0].Parent.Business_Website__c);
            outMap.put('BusinessCounty', address[0].County__c);
            outMap.put('BusinessCountry',address[0].CountryCode);
            outMap.put('BusinessZipcodeRO', address[0].PostalCode);
            outMap.put('BusinessWebsiteRO',address[0].Parent.Business_Website__c);
            outMap.put('BusinessCountyRO', address[0].County__c);
            outMap.put('BusinessCountryRO',address[0].Country);
            
        }
        catch(Exception ex) {
            LPI_ExceptionManager.logException('LPI_SaveDetailsOfIndividualBroker', 'fetchBusinessDetails', ex);
        }
    }
    private static final Set<String> BLOCK_DATA_INFO_SET = new Set<String>{'IndividualBrokerBlock1','IndividualBrokerBlock2','IndividualBrokerBlock3'};
    /**
    * @author                      : Vamsi Mudaliar
    * @since                       : 03 Oct 2022
    * @description                 : This Method is used to Update Business Information On the Temp AuthorizationPlace Record. if it exists.
    * @param inputMap              : Input Parameter Passed from Omniscript
    * @param outMap                : Output Passed to Omniscript
    * @return                      : `void`
    * @last modified by            : Uzma Md
    * @last modified date          : 13 December 2023
    * @modified details            : Piyush Aneja - I-246030 and I-245626 Fix and Development
    */
    // public static void updateBusinessDetails(Map<String, Object> inputMap, Map<String, Object> outMap) {
    //     try {
            
    //         String parId = (String) inputMap.get('parid');
    //         if(parId==null) {
    //             return;
    //         }
    //         Map<String, object> mainBlockMap = (Map<String, object>) inputMap.get(LPI_LiteralConstant.BUSINESS_INFO_STEP_NAME);// IndividualBroker
    //         Map<String, object> stepConInfo = new Map<String,Object>();
    //         for(String blocks :  mainBlockMap.keySet()) {
    //             if(BLOCK_DATA_INFO_SET.contains(blocks)) {
    //                 Map<String,Object> tmp = (Map<String,Object>) mainBlockMap.get(blocks);
    //                 if(tmp!=null){
    //                     stepConInfo.putAll(tmp);
    //                 }
    //             }
    //         }
    //         String parQueryFields = 'Id, BusinessAccountNameId,Board_Name__c,Wish_to_provide_Entity_details__c,Type__c,Regulatory_Authorization_Type__r.Name,Amendment_Type__c';
    //         String parWhereClause = 'Id = \''+String.escapeSingleQuotes(parId)+'\'';
    //         List<PreliminaryApplicationRef> parObj = LPI_PreliminaryApplicationRefDAO.getPreliminaryApplicationRefByDymanicQuery(parQueryFields,parWhereClause,null,null,null);
    //         List<Account> acc = LPI_AccountDAO.getAccountListByDynamicQuery(new List<String>{'Id', 'Name'},'Id = \''+parObj[0]?.BusinessAccountNameId+'\'',null,null,null);
    //         Map<Id,Id> locationIds = new Map<Id,Id>();
    //         String wishToProvideEntityDetails;
    //         if (mainBlockMap.get('WishToProvideEntityDetails') != null) {
    //             wishToProvideEntityDetails = (String) mainBlockMap.get('WishToProvideEntityDetails');
    //         } else {
    //             wishToProvideEntityDetails = (String) mainBlockMap.get('WishToProvideEntityDetailsRO');
    //         }            
    //         if(parObj[0].Board_Name__c == ACCOUNTANCY){
    //             if (wishToProvideEntityDetails != null) {
    //                 parObj[0].Wish_to_provide_Entity_details__c = wishToProvideEntityDetails;
    //             }
    //             if (!parObj.isEmpty()) {
    //                 LPI_DML.doUpsert(parObj);
    //             }
    //         }
    //         if(wishToProvideEntityDetails == NO){
    //             return;
    //         }     
    //             String tempAuthPlaceQueryFields = 'ID,Location__c';
    //             String tempAuthPlaceWhereClause = 'Preliminary_Application_Reference__c =\''+String.escapeSingleQuotes(parId)+ 
    //             '\' AND Location__r.LocationType = \'' +LPI_LiteralConstant.LOCATION_TYPE_BUSINESS_ADDRESS+ '\'';
    //             List<Temp_AuthApplicationPlace__c> tempAuthPlaceRecord = LPI_TempAuthApplicationPlaceDAO.getTempAuthApplicationPlaceByDymanicQuery(tempAuthPlaceQueryFields,tempAuthPlaceWhereClause,null,null,null);
    //             List<Schema.Address> addresses = new List<Schema.Address>();
    //             if(!tempAuthPlaceRecord.isEmpty()) {
    //                 String addressQueryFields = 'ID, ParentId, Parent.LocationType';
    //                 String addressWhereClause='ParentId = \'' + tempAuthPlaceRecord[0]?.Location__c +'\'';
    //                 addresses =LPI_AddressDAO.getAddressByDymanicQuery(addressQueryFields,addressWhereClause,null,null,null);
    //             }
    //             osFieldToLocationAPIMap = new Map<String,String>{
    //                 'BusinessName'=>'Name',
    //                 'BusinessPhone'=>'Business_Phone__c',
    //                 'FictitiousName'=>'Fictitious_Name__c',
    //                 'BusinessEmail'=>'Firm_Email__c',
    //                 'BusinessWebsite'=>'Business_Website__c'
    //             };
    //             osFieldToAddressAPIMap = new Map<String,String>{
    //                 'BusinessCity'=>'City',
    //                 'StreetAddress1'=>'Street',
    //                 'BusinessZipcode'=>'PostalCode',
    //                 'BusinessCountry'=>'CountryCode',
    //                 'BusinessCounty'=> 'County__c'
    //             };
                
    //             String selectedCountryCode = (String)stepConInfo.get('BusinessCountry');
    //             if(selectedCountryCode==LPI_LiteralConstant.US_COUNTRY_CODE) {
    //                 osFieldToAddressAPIMap.put('USBusinessState','StateCode');
    //             } else {
    //                 osFieldToAddressAPIMap.put('BusinessStateOtherThanUS','Business_State__c');
    //             }
    //             String reqLocId = LPI_AddressUtility.createLocationAndAddress(
    //             parObj[0]?.BusinessAccountNameId,
    //             LPI_LiteralConstant.LOCATION_TYPE_BUSINESS_ADDRESS,
    //             stepConInfo.get('BusinessName') != null ? (String)stepConInfo.get('BusinessName') : '',
    //             osFieldToAddressAPIMap,
    //             stepConInfo
    //             );
    //             if(reqLocId!=null) {
    //                 Schema.Location locRecordToUpdate = (Schema.Location)LPI_VlocityUtility.createSObject(stepConInfo,osFieldToLocationAPIMap,'Location');
    //                 locRecordToUpdate.Id = reqLocId;
    //                 if(stepConInfo.get('BusinessName')==null){
    //                     locRecordToUpdate.Name = 'Business Address';
    //                 } 
    //                 LPI_WithoutSharingUtility.upsertSObject(locRecordToUpdate);
    //                 LPI_AddressUtility.createTempAuthPlaceRecord((!tempAuthPlaceRecord.isEmpty()?tempAuthPlaceRecord[0]?.Id:null), reqLocId, parId);
    //                 LPI_AddressUtility.upsertAssociationLocRecord(parObj[0]?.BusinessAccountNameId,'', reqLocId);  
    //             }
                
    //             if(parObj[0].Regulatory_Authorization_Type__r.Name == 'Broker')
    //             {
    //                 PreliminaryApplicationRef updatePar = new PreliminaryApplicationRef(Id = parObj[0].Id);
    //                 updatePar.License_Address__c = 'Business Address';
    //                 LPI_TriggerHandler.bypass('PreliminaryApplicationTriggerHandler');
    //                 if (LPI_TriggerHandler.isBypassed('PreliminaryApplicationTriggerHandler')) {
    //                     LPI_DML.doUpdate(updatePar);
    //                 }
    //                 LPI_TriggerHandler.clearBypass('PreliminaryApplicationTriggerHandler');
    //             }
    //     }
    //     catch(Exception ex) {
    //         LPI_ExceptionManager.logException('LPI_SaveDetailsOfIndividualBroker', 'updateBusinessDetails', ex);
    //     }
    // }
}