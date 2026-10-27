/**
* @author      : kirti Agrawal
* @since       : 06 Nov, 2023
* @description : This Class retrun the List Of Auth Application Place Records
*  -------------------------------------------------------------------------------------------------------
* Version      Date                Author                  Details
*    1         06 Nov, 2023        kirti Agrawal               Initial Developement
* -------------------------------------------------------------------------------------------------------
*/
public with sharing class LPI_AuthApplicationPlaceListController {
    /**
    *   @author                  : kirti Agrawal
    *   @since                   : 6 Nov, 2023
    *   @description             : This method is used to fetch Auth App Place List or Associate Locations List
    *   @param                   : Id recordId
    *   @return                  : Map<String,Object>
    */
    @AuraEnabled
    public static Map<String,Object> getRelatedLocationList(Id recordId, Boolean isLimit){
        LocationWrapper locationWarpperObj = new LocationWrapper();
        Map<String,Object> objNameToAuthAppPlaceListMap = new MAp<String,Object>();
        if(String.isNotBlank(recordId)){
            SObjectType objectType = recordId.getSObjectType();
            String objName = objectType.getDescribe().getName();
            if(objName == 'Account' || objName == 'PersonAccount'){
                if(objName == 'Account'){
                    locationWarpperObj = getRelatedAssociateLocationList(recordId,isLimit);
                }
            }else{
                locationWarpperObj = getRelatedAuthApplicationPlaceList(recordId,isLimit);
            }
            
            objNameToAuthAppPlaceListMap.put('objName', objName);
            objNameToAuthAppPlaceListMap.put('locationWrapper',locationWarpperObj);
        }
        return objNameToAuthAppPlaceListMap;
    }
    
    /**
    *   @author                  : kirti Agrawal
    *   @since                   : 6 Nov, 2023
    *   @description             : This method is used to fetch Auth Application Place List
    *   @param                   : Id recordId, Boolean isLimit
    *   @return                  : List<AAPAndALWrapper>
    */
    
    private static LocationWrapper getRelatedAuthApplicationPlaceList(Id recordId, Boolean isLimit){
        try {
            String fields = 'Id, Name, PlaceId, AuthorizationId';
            String whereClause = 'AuthorizationId = \'' + String.escapeSingleQuotes(recordId) + '\'';
            List<AAPAndALWrapper> authApplicationPlaceWrapperList = new List<AAPAndALWrapper>();
            Map<Id,AAPAndALWrapper> locationIdToAuthAppPlaceWrapperMap = new Map<Id,AAPAndALWrapper>();
            String limitValue;
            if(isLimit){
                limitValue = null;
            }else{
                limitValue = '11';
            }
            for (
            AuthApplicationPlace authAppRec : LPI_AuthApplicationPlaceDAO.getAuthApplicationPlaceByDymanicQuery(
            fields,
            whereClause,
            limitValue,
            null,
            null
            )
            ) {
                AAPAndALWrapper authAppWrapper = new AAPAndALWrapper();
                authAppWrapper.authAppPlaceId = authAppRec.Id;
                authAppWrapper.Name = authAppRec.Name;
                locationIdToAuthAppPlaceWrapperMap.put(authAppRec.PlaceId,authAppWrapper);
            }
            
            if (!locationIdToAuthAppPlaceWrapperMap.keySet().isEmpty()) {
                for (
                Schema.Location loc : LPI_LocationDAO.getLocationByDymanicQuery(
                'Id, LocationType, Name, OpenDate, CloseDate, Status__c,'+
                '(SELECT Street, City, State, Business_State__c, postalCode, country, CountryCode FROM Addresses order by CreatedDate desc LIMIT 1)',
                ' Id IN ' +LPI_ServiceUtility.getStringValuesBySet(locationIdToAuthAppPlaceWrapperMap.keySet()),
                null,
                'Status__c',
                'ASC'
                )
                ) {
                    AAPAndALWrapper authAppWrapper = locationIdToAuthAppPlaceWrapperMap.get(loc.Id);
                    authAppWrapper.placeId = loc.Id;
                    authAppWrapper.placeName = loc.Name;
                    authAppWrapper.locationName = loc.Name;
                    authAppWrapper.openDate = loc.OpenDate;
                    authAppWrapper.closeDate = loc.CloseDate;
                    authAppWrapper.status = loc.Status__c;
                    authAppWrapper.isAccount = false;
                    if(loc.Addresses.size()>0){
                        Schema.Address add = loc.Addresses[0];
                        authAppWrapper.addressName = String.isNotBlank(add.Street) ? add.Street + ', ' : '';
                        authAppWrapper.addressName += String.isNotBlank(add.City) ? add.City + ', ':'';
                        if(add.CountryCode == 'US'){
                            authAppWrapper.addressName += String.isNotBlank(add.State) ? add.State + ', ' : '';
                        }else{
                            authAppWrapper.addressName += String.isNotBlank(add.Business_State__c) ? add.Business_State__c + ', ' : '';
                        }
                        authAppWrapper.addressName += String.isNotBlank(add.postalCode) ? add.postalCode + ', ' : '';
                        authAppWrapper.addressName += String.isNotBlank(add.country) ? add.country : '';
                    }
                    authApplicationPlaceWrapperList.add(authAppWrapper);
                }
            }
            LocationWrapper wrapObj = new LocationWrapper();
            wrapObj.isRecordMoreThanFive = authApplicationPlaceWrapperList.size()>10 ? true : false;
            wrapObj.authAppPlaceWrapperList = authApplicationPlaceWrapperList;
            if(!isLimit && authApplicationPlaceWrapperList.size()>10){
                authApplicationPlaceWrapperList.remove(authApplicationPlaceWrapperList.size()-1);
            }
            return wrapObj;
        } catch (Exception e) {
            LPI_ExceptionManager.logException('LPI_AuthApplicationPlaceListController', 'getRelatedAuthApplicationPlaceList', e);
            throw new AuraHandledException(e.getMessage());
        }
    }
    /**
    *   @author                  : kirti Agrawal
    *   @since                   : 6 Nov, 2023
    *   @description             : This method is used to fetch Association Location List
    *   @param                   : Id recordId, Boolean isLimit
    *   @return                  : List<AAPAndALWrapper>
    */
    private static LocationWrapper getRelatedAssociateLocationList(Id recordId, Boolean isLimit){
        try{
            Map<Id, AAPAndALWrapper> locationIdToAssocLocWrapperMap = new Map<Id, AAPAndALWrapper>();
            List<String> fields = new List <String>{'Id, ParentRecordId, LocationId, Location.Name, Location.OpenDate, Location.CloseDate, Location.Status__c'};
            String whereClause = 'ParentRecordId = \'' + String.escapeSingleQuotes(recordId) + '\'';
            List<AAPAndALWrapper> authApplicationPlaceWrapperList = new List<AAPAndALWrapper>();
            Integer limitValue;
            if(isLimit){
                limitValue = null;
            }else{
                limitValue = 11;
            }
            for (
            AssociatedLocation associateLoc : LPI_AssociatedLocationDAO.getAssociatedLocationListByDynamicQuery(
            fields,
            whereClause,
            limitValue,
            'Location.Status__c',
            'ASC'
            )
            ) {
                
                AAPAndALWrapper authAppWrapper = new AAPAndALWrapper();
                authAppWrapper.authAppPlaceId = associateLoc.Id;
                authAppWrapper.Name = associateLoc.Id;
                authAppWrapper.placeId = associateLoc.LocationId;
                authAppWrapper.placeName = associateLoc.Location.Name;
                authAppWrapper.openDate = associateLoc.Location.OpenDate;
                authAppWrapper.closeDate = associateLoc.Location.CloseDate;
                authAppWrapper.status = associateLoc.Location.Status__c;
                authAppWrapper.isAccount = true;
                authApplicationPlaceWrapperList.add(authAppWrapper);
                locationIdToAssocLocWrapperMap.put(associateLoc.LocationId, authAppWrapper);
            }
            if(!locationIdToAssocLocWrapperMap.keySet().isEmpty()){
                for( Schema.Location loc : LPI_LocationDAO.getLocationByDymanicQuery(
                'Id, '+
                '(SELECT Street, City, State, Business_State__c, ParentId, postalCode, CountryCode, country FROM Addresses order by CreatedDate desc LIMIT 1)',
                ' Id IN ' +LPI_ServiceUtility.getStringValuesBySet(locationIdToAssocLocWrapperMap.keySet()),
                null,
                null,
                null
                )
                ){
                    if(loc.Addresses.size()>0){
                        Schema.Address add = loc.Addresses[0];
                        AAPAndALWrapper authAppWrapper = locationIdToAssocLocWrapperMap.get(add.ParentId);
                        authAppWrapper.addressName = String.isNotBlank(add.Street) ? add.Street + ', ' : '';
                        authAppWrapper.addressName += String.isNotBlank(add.City) ? add.City + ', ':'';
                        if(add.CountryCode == 'US'){
                            authAppWrapper.addressName += String.isNotBlank(add.State) ? add.State + ', ' : '';
                        }else{
                            authAppWrapper.addressName += String.isNotBlank(add.Business_State__c) ? add.Business_State__c + ', ' : '';
                        }
                        authAppWrapper.addressName += String.isNotBlank(add.postalCode) ? add.postalCode + ', ' : '';
                        authAppWrapper.addressName += String.isNotBlank(add.country) ? add.country : '';
                    }
                }
            }
            LocationWrapper wrapObj = new LocationWrapper();
            wrapObj.isRecordMoreThanFive = authApplicationPlaceWrapperList.size()>10 ? true : false;
            wrapObj.authAppPlaceWrapperList = authApplicationPlaceWrapperList;
            if(!isLimit && authApplicationPlaceWrapperList.size()>10){
                authApplicationPlaceWrapperList.remove(authApplicationPlaceWrapperList.size()-1);
            }
            return wrapObj;
        }catch (Exception e) {
            LPI_ExceptionManager.logException('LPI_AuthApplicationPlaceListController', 'getRelatedAssociateLocationList', e);
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    public class AAPAndALWrapper{
        @AuraEnabled
        public id authAppPlaceId;
        @AuraEnabled
        public id placeId;
        @AuraEnabled
        public id associateLocationId;
        @AuraEnabled
        public String placeName;
        @AuraEnabled
        public String Name;
        @AuraEnabled
        public String locationName;
        @AuraEnabled
        public Date openDate;
        @AuraEnabled
        public Date closeDate;
        @AuraEnabled
        public String status;
        @AuraEnabled
        public Boolean isAccount;
        @AuraEnabled
        public String addressName;
    }
    public class LocationWrapper{
        @AuraEnabled
        public Boolean isRecordMoreThanFive;
        @AuraEnabled
        public List<AAPAndALWrapper> authAppPlaceWrapperList;
    }
}