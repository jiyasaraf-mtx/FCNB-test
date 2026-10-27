/**
 * @author          : Nitesh Garg
 * @description     : This class is used for Address and Location Utility
 * * @history
 * -------------------------------------------------------------------------------------------------------
 * Version      Date                Author                  Details
 *    1         18 Jan , 2023        Nitesh Garg         Initial Developement
 * -------------------------------------------------------------------------------------------------------
 */

public with sharing class LPI_AddressUtility {
   
    static final string OBJECT_ADDRESS = 'Address';
	public final static String CANNOT_ADD_DUPLICATE_ADDRESS = 'Address already exists';
    /**
	 * @author          : Nitesh Garg
     * @since           : 17 Feb 2023
	 * @description     : Method used to create key for address
	 */
    public static String createKeyForAddress(String street,String city,String state,String postalCode){
        String key = '';
        key += street != null ? street : '';
        key += city != null ? city : '';
        key += state != null ? state : '';
        key += postalCode != null ? postalCode : '';
        return key;
    }
    /**
	 * @author          : Nitesh Garg
     * @since           : 17 Feb 2023
	 * @description     : Method used to create location record/This method is not inserting record in the salesforce
     * param key        : it is used when you ar creating multiple location at a single time. passed unique every time.
	 */
    public static Schema.Location createLocationRecord(String id,String name,String locationType,String key){
        Schema.Location locationRec = new Schema.Location();
        if(String.isNotEmpty(id)){
            locationRec.Id =id;
        }
        if(name.length()>=240) {
            locationRec.Name = name;
        }
        else {
              locationRec.Name = name + ' - '+ locationType; 
        }
        locationRec.OpenDate = System.today();
        locationRec.Status__c = LPI_LiteralConstant.LOCATION_STATUS_CLOSED;
        locationRec.CloseDate = null;
        locationRec.LocationType  = locationType;
        locationRec.Unique_Key__c = key;
        return locationRec;
    }
    /**
	 * @author          : Nitesh Garg
     * @since           : 17 Feb 2023
	 * @description     : Method used to check existing address and create new location and address
	 */
    public static String createLocationAndAddress(String accountId,String locationType,String locName
                                                ,Map<String,String> addressMapping,
                                                Map<String,Object> addressValueMapping){
        List<Id> locIdList = new List<Id>();
        String locationId = '';
        Schema.Address addressRec = (Schema.Address) LPI_VlocityUtility.createSObject(
                                                    addressValueMapping,
                                                    addressMapping,
                                                    OBJECT_ADDRESS 
                                                );
        if(accountId != null){
            for(AssociatedLocation assLoc: new LPI_AssociatedLocationDAO.LPI_AssociatedLocationWithoutSharingDAO()
                .getAssociatedLocationByDymanicQuery('LocationId',
                                        ' ParentRecordId = \'' + accountId + '\'' +
                                        ' AND Location.LocationType = \'' + locationType + '\'',
                                        null,null,null)){
                                            locIdList.add(assLoc.LocationId); 
                                        }
        }
        if(!locIdList.isEmpty()){
            String addressQueryFields = 'Id,Parent.Status__c,ParentId';
            String addressWhereClause =
                ' ParentId IN ' + LPI_ServiceUtility.getStringValuesByList(locIdList) + 
                ' AND City=\'' + String.escapeSingleQuotes(addressRec.City) + '\''+ 
                ' AND Street=\'' + String.escapeSingleQuotes(addressRec.Street) +
                '\' AND Parent.LocationType =\'' + locationType + '\'';
                if(String.isNotEmpty(addressRec.PostalCode)){
                    addressWhereClause += ' AND PostalCode=\'' + String.escapeSingleQuotes(addressRec.PostalCode) + '\'';
                }
                if(String.isNotBlank(addressRec.CountryCode)) {
                    addressWhereClause += ' AND CountryCode=\'' + String.escapeSingleQuotes(addressRec.CountryCode) + '\'';
                } else {
                    addressRec.CountryCode = 'US';
                }
                if('US'.equalsIgnoreCase(addressRec.CountryCode)){
                    addressWhereClause += ' AND StateCode = \''+String.escapeSingleQuotes(addressRec.StateCode)+ '\'';
                }else{
                    if(String.isNotEmpty(addressRec.Business_State__c)){
                        addressWhereClause += ' AND Business_State__c =\'' + String.escapeSingleQuotes(addressRec.Business_State__c) +'\'';
                    }
                }
            LPI_AddressDAO.LPI_AddressDAOWithoutSharing getAddressRecords=new LPI_AddressDAO.LPI_AddressDAOWithoutSharing();
            List<Schema.Address> addressList = getAddressRecords.getAddressByDymanicQuery(
                addressQueryFields,
                addressWhereClause,
                null,
                null,
                null
            );

            if(!addressList.isEmpty()){
                addressRec.Id = addressList[0].Id;
                LPI_DML.doUpdate(new List<Schema.Address>{ addressRec });
                return addressList[0].ParentId;
            }
        }
        Schema.Location locationRec = createLocationRecord(locationId,locName,locationType,null);
        locationId = ((Schema.Location) LPI_DML.doUpsert(locationRec)).Id;
        addressRec.ParentId = locationId;
        addressRec.LocationType = locationType;
        LPI_DML.doInsert(new List<Schema.Address>{ addressRec });
        return locationId;
    }

    /**
	 * @author          : Nitesh Garg
     * @since           : 17 Feb 2023
	 * @description     : Method used to check existing address and create new muliple location and address
     * Note             : for creating multiple location and address you must need to insert Unique_Key__c field in Location object.
	 */
    public static Map<String,Id> createLocationAndAddress(Map<String,Schema.Location> keyLocMap,
                                                        Map<String,Schema.Address> keyAddMap,
                                                        String accountId,
                                                        String locationType,
                                                        List<String> streetList,
                                                        List<String> cityList,
                                                        List<String> stateList,
                                                        List<String> postalList,
                                                        Boolean isLocUpdateReq){
    List<Id> locIdList = new List<Id>();
    if(accountId != null){
        for(AssociatedLocation assLoc:LPI_AssociatedLocationDAO.getAssociatedLocationListByDynamicQuery(
                new List<String> {'LocationId'}, 
                ' ParentRecordId = \'' + accountId + '\'' +
                ' AND Location.LocationType = \'' + locationType + '\'',
                null,null,null)){
            locIdList.add(assLoc.LocationId); 
        }
    }
    Map<String,Id> keyLocIdMap = new Map<String,Id>();
    if(!locIdList.isEmpty()){
        String addressQueryFields = 'Id,Parent.Status__c,ParentId,Parent.Name,City,Street,PostalCode,StateCode,Business_State__c';
        String addressWhereClause =
        ' ParentId IN ' + LPI_ServiceUtility.getStringValuesByList(locIdList) + 
        ' AND City IN' + LPI_ServiceUtility.getStringValuesByList(cityList) + 
        ' AND Street IN' + LPI_ServiceUtility.getStringValuesByList(streetList) +
        ' AND PostalCode IN ' + LPI_ServiceUtility.getStringValuesByList(postalList) +
        ' AND Parent.LocationType =\'' + locationType + '\'' +
        ' AND ( StateCode IN' + LPI_ServiceUtility.getStringValuesByList(stateList) +
        ' OR Business_State__c IN' + LPI_ServiceUtility.getStringValuesByList(stateList) +')';
        String key = '';
        String state = '';
        LPI_AddressDAO.LPI_AddressDAOWithoutSharing getAddressRecords=new LPI_AddressDAO.LPI_AddressDAOWithoutSharing();
        for(Schema.Address addressRec : getAddressRecords.getAddressByDymanicQuery(
                                            addressQueryFields,
                                            addressWhereClause,
                                            null,
                                            null,
                                            null
                                            )){
                                                if(addressRec.StateCode!= null){
                                                    state = addressRec.StateCode;
                                                }else{
                                                    state = addressRec.Business_State__c;
                                                }
                                                key =  createKeyForAddress(addressRec.Street,
                                                                            addressRec.City,
                                                                            state,
                                                                            addressRec.PostalCode);
                                                if(keyLocMap.containsKey(key)){
                                                    keyLocIdMap.put(key,addressRec.ParentId);
                                                }
                                            }
    }
    List<Schema.Location> newlocationInsertList = new List<Schema.Location>();
    List<Schema.Location> locationUpdateList = new List<Schema.Location>();
    for(String lockKey : keyLocMap.keySet()){
        if(!keyLocIdMap.containsKey(lockKey)){
            newlocationInsertList.add(keyLocMap.get(lockKey));
        }else if(isLocUpdateReq == true){
            keyLocMap.get(lockKey).Id = keyLocIdMap.get(lockKey);
            locationUpdateList.add(keyLocMap.get(lockKey));
        }
    }
     if(!locationUpdateList.isEmpty()){
        LPI_DML.doUpdate(locationUpdateList);
    }
    if(!newlocationInsertList.isEmpty()){
        newlocationInsertList = (List<Schema.Location>)LPI_DML.doUpsert(newlocationInsertList);    
       Map<String,Id> newlocationInsertMap = new Map<String,Id>();
       for(Schema.Location locRec : newlocationInsertList){
            newlocationInsertMap.put(locRec.Unique_Key__c,locRec.Id);
       }
       List<Schema.Address> newAddressList = new List<Schema.Address>();
        for(String key:newlocationInsertMap.keySet()){
            if(keyAddMap.containsKey(key)){
                Schema.Address addr = keyAddMap.get(key);
                addr.ParentId = newlocationInsertMap.get(key);
                newAddressList.add(addr);
            }
            keyLocIdMap.put(key,newlocationInsertMap.get(key));
        }
        if(!newAddressList.isEmpty()){
            LPI_DML.doInsert(newAddressList);
        }
    }
    return keyLocIdMap;
    }
    /**
	 * @author          : Nitesh Garg
     * @since           : 17 Feb 2023
	 * @description     : Method used to create Temp_AuthApplicationPlace__c record
	 */
    public static String createTempAuthPlaceRecord(String tempAuthId,String locationId,String parId){
        Temp_AuthApplicationPlace__c tempAuthRec = new Temp_AuthApplicationPlace__c();
        if (tempAuthId != null){
            tempAuthRec.Id = tempAuthId;
        }
        List<Temp_AuthApplicationPlace__c> tempAAP = LPI_TempAuthApplicationPlaceDAO.getTempAuthApplicationPlaceByDymanicQuery(
				'Id',
				' Preliminary_Application_Reference__c = \'' + parId + '\'' +
                ' AND Location__c = \'' + locationId + '\'',
				null,
				null,
				null
			);
        if(!tempAAP.isEmpty()){
            return CANNOT_ADD_DUPLICATE_ADDRESS;
        }
        tempAuthRec.Location__c = locationId;
        tempAuthRec.Preliminary_Application_Reference__c = parId;
        return ((Temp_AuthApplicationPlace__c) LPI_DML.doUpsert(tempAuthRec))?.Id;
    }

     /**
	 * @author          : Nitesh Garg
     * @since           : 17 Feb 2023
	 * @description     : Method used to upsert AssociatedLocation record
	 */
    public static void upsertAssociationLocRecord(String parentId,String prevLocationId,String locationId){
        AssociatedLocation ascLocation = new AssociatedLocation();
        boolean noPrevious = false;
        ascLocation.LocationId = locationId;
        if(String.isBlank(prevLocationId)){
            prevLocationId = locationId;
            noPrevious = true;
        }
        Map<Id,AssociatedLocation> ascLocationMap = new Map<Id,AssociatedLocation>();
        for(AssociatedLocation ascLocationRec : new LPI_AssociatedLocationDAO.LPI_AssociatedLocationWithoutSharingDAO()
        .getAssociatedLocationByDymanicQuery('Id,LocationId, Location.Status__c, Location.CloseDate', 
                                            ' ParentRecordId = \'' + parentId + '\'' +
                                            ' AND (LocationId = \'' + prevLocationId + '\'' +
                                            ' OR LocationId = \'' + locationId + '\')',
                                            null,null,null)){
                ascLocationMap.put(ascLocationRec.LocationId,ascLocationRec);
            }
        if(!ascLocationMap.isEmpty()){
            if(!noPrevious && ascLocationMap.size() == 1 && ascLocationMap.get(prevLocationId).Location.Status__c == LPI_LiteralConstant.LOCATION_STATUS_CLOSED
                && ascLocationMap.get(prevLocationId).Location.CloseDate == null){
                ascLocation.Id = ascLocationMap.get(prevLocationId).Id;
                LPI_WithoutSharingUtility.updateSObjectRecord(new List<AssociatedLocation>{ ascLocation });
            }else if(!noPrevious && ascLocationMap.size() == 1 && ascLocationMap.get(prevLocationId).Location.Status__c == LPI_LiteralConstant.LOCATION_STATUS_CLOSED
                && ascLocationMap.get(prevLocationId).Location.CloseDate != null){
                ascLocation.ParentRecordId = parentId;
                LPI_WithoutSharingUtility.insertSObjectRecord(new List<AssociatedLocation>{ ascLocation });
            }else if(!noPrevious && ascLocationMap.size() == 1 && ascLocationMap.get(prevLocationId).Location.Status__c == LPI_LiteralConstant.LOCATION_STATUS_OPEN){
                ascLocation.ParentRecordId = parentId;
                LPI_WithoutSharingUtility.insertSObjectRecord(new List<AssociatedLocation>{ ascLocation });
            }
        }
        else if(ascLocationMap.isEmpty()){
            ascLocation.ParentRecordId = parentId;
            LPI_WithoutSharingUtility.insertSObjectRecord(new List<AssociatedLocation>{ ascLocation });
        }
    }
    /**
	 * @author          : Nayana Gupta
     * @since           : 29 Feb 2024
	 * @description     : Method used to get Address Details from Account.
	 */
    @AuraEnabled
    public static List<Account> getAddressDetails(String accountID){
        String fields;
		String whereClause;
        fields = 'id,Name,Phone,Buisness_Email__c, BillingStreet,County__c, BillingCity, BillingState, BillingPostalCode, BillingCountry ,BillingCountryCode,BillingStateCode,FirstName, MiddleName, LastName,PersonEmail,PersonHomePhone,PersonOtherStreet,PersonOtherCity,PersonOtherCountryCode,PersonOtherStateCode,PersonOtherPostalCode, PersonOtherState,OwneriD';
        whereClause = 'Id = \'' + String.escapeSingleQuotes(accountID) + '\'';
        LPI_AccountDAO.LPI_AccountWithoutSharingDAO acc = new LPI_AccountDAO.LPI_AccountWithoutSharingDAO();
        return   acc.getAccountByDymanicQuery(fields,whereClause,null, null,null);
    }
}