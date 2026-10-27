/**
 * @description       : 
 * @author            : MTX Group Product Team
 * @group             : 
 * @last modified on  : 07-08-2024
 * @last modified by  : MTX Group Product Team
**/
public without sharing class LPI_LicenseSearchController {
    private static final String CRIMINAL_NOTIFICATION = 'Criminal Notification';
    private static final String DOMESTIC_VOILENCE_VICTIM_ORDER = 'Domestic Violence Victim Order';
    private static final Set<String> ALLOWED_LICENSE_SEARCH_PROFESSIONS = new Set<String>{
        'Real Estate Salesperson',
        'Individual Insurance Agent'
    };
    
    @AuraEnabled
    public static List<Map<String, String>> loadPicklistValues(String status){
        try {
            String whereClause = '';
            List<Map<String, String>> listOfStatusOptions = new List<Map<String, String>>();
            if(status =='Active'){
                whereClause ='IssuingDepartment.name !=\'Nursing\'';
            }else{
                whereClause ='( IssuingDepartment.name !=\'Nursing\' AND IssuingDepartment.name !=\'Athlete Agents\' AND IssuingDepartment.name !=\'Athletics\' AND IssuingDepartment.name !=\'Pharmacy\' )';
            }
            whereClause += ' AND Name IN (\'Real Estate Salesperson\', \'Individual Insurance Agent\')';
            
            String fieldsToQuery='Id,Name'; 
            String limitValue='500';
            String query = 'SELECT ' + fieldsToQuery;
            query += ' FROM RegulatoryAuthorizationType ';
            if(whereClause != ''){
                query += ' WHERE ' + whereClause ;
            }
            query += 'ORDER BY Name ASC';
            query += ' LIMIT ' + limitValue;
            List<RegulatoryAuthorizationType> ratList = new List<RegulatoryAuthorizationType>((List<RegulatoryAuthorizationType>)Database.query(query));
            for(RegulatoryAuthorizationType rat:ratList){
                if (!ALLOWED_LICENSE_SEARCH_PROFESSIONS.contains(rat.Name)) {
                    continue;
                }
                listOfStatusOptions.add(new Map<String, String>{
                    'label' => rat.Name,
                    'value' => rat.Id
                });
            }
             return listOfStatusOptions;
           
        } catch (Exception e) {
            LPI_ExceptionManager.logException(
                'LPI_LicenseSearchController',
                'loadPicklistValues',
                e
            );
            throw new LPI_Exception(e.getMessage());
        }
    }
    @AuraEnabled
    public static List<LicenseSearchWrapper> fetchBusinessLicense(String status,String countyName, String professionName,String searchCriteria, String partialRequires){
        String query2;
        try{ 
            if (!String.isBlank(partialRequires) && partialRequires.contains('%')) {
                return null;
            }
            String whereClause ='County__c ='+'\''+countyName+'\'';
            String fieldsToQuery='Id,address, Parent.Id,Parent.Consent_For__c, County__c,Business_State__c'; 
            String limitValue='20000';
            String query = 'SELECT ' + fieldsToQuery;
            query += ' FROM Address ';
            query += ' WHERE ' + whereClause + ' LIMIT '+ limitValue;
            Map<Id,List<String>> addressIdMap = new Map<Id,List<String>>();
            Map<Id,Id> locIdToAddIdMap = new Map<Id,Id>();
            List<Schema.Address> addr=new List<Schema.Address>((List<Schema.Address>)Database.query(query));
            List<String> citystate = new list<string>();
            
            for(Schema.Address a:addr){
                citystate = new list<string>();
                // Prefer publicly displayed addresses; otherwise use any matching county address
                if(a.ParentId !=null){
                    Boolean isPublicAddress = a.Parent.Consent_For__c != null
                        && a.Parent.Consent_For__c.contains('Publicly Displayed Address');
                    citystate.add(a.address.getCity());
                    if(a.address.getState() != null){
                        citystate.add(a.address.getState());
                    }else{
                        citystate.add(a.Business_State__c);
                    }
                    if (isPublicAddress || !addressIdMap.containsKey(a.Parent.Id)
                        || addressIdMap.get(a.Parent.Id) == null
                        || addressIdMap.get(a.Parent.Id).isEmpty()) {
                        addressIdMap.put(a.Parent.Id, citystate);
                        locIdToAddIdMap.put(a.Parent.Id, a.Id);
                    }
                }
            }
            String whereClause2 ='';
            String fieldsToQuery2='id,Authorization.Issuing_Department_Name__c,Authorization.Legacy_License_Number__c,Authorization.Licensee_Modification_Reason__c,Authorization.AccountId,placeId,Authorization.RegulatoryAuthorizationType.IssuingDepartmentId,Authorization.First_Name__c, Authorization.Last_Name__c,Authorization.Doing_Business_As_DBA_or_Trade_Name__c,Authorization.status,Authorization.Name,Authorization.Regulatory_Authorization_Type_Name__c,Authorization.Business_Entity_Name__c, AuthorizationId'; 
            String limitValue2='50000';
            
            if(status!='Active'){
                String whereClauseStatus = 'Authorization.status = \'Expired\'';
                if(!String.isBlank(professionName)){
                    whereClauseStatus ='';
                    whereClauseStatus = getInactiveStatusByRAT(professionName);
                }
                whereClause2+= ''+ whereClauseStatus+'';
            }
            if(status=='Active'){
                whereClause2+= ' Authorization.status='+'\''+status+'\'';
            }
            if(!addressIdMap.isEmpty()){
                whereClause2 +=' AND PlaceId IN '+LPI_ServiceUtility.getStringValuesBySet(addressIdMap.keyset());
            }
            if(!String.isBlank(professionName)){
                whereClause2+= ' AND Authorization.RegulatoryAuthorizationTypeId='+'\''+professionName+'\'';
            }
            if( searchCriteria=='Licensee Name (Partial Last, First - enter in the textbox below)'){
                String partial= '%' + partialRequires + '%'; 
                whereClause2+= ' AND (Authorization.First_Name__c LIKE \''+String.escapeSingleQuotes(partial)+'\'';
                whereClause2+= ' OR  Authorization.Last_Name__c LIKE \''+String.escapeSingleQuotes(partial)+'\'';
                whereClause2+= ' OR  Authorization.Business_Name__c LIKE \''+String.escapeSingleQuotes(partial)+'\')';
                whereClause2+= ' AND Authorization.Issuing_Department_Name__c !=\'Nursing\'';
            }
            if(searchCriteria=='License Number (Exact - enter in the textbox below)'){
                whereClause2+= ' AND (Authorization.Name='+'\''+partialRequires+'\'';
                whereClause2+=' OR Authorization.Legacy_License_Number__c = \''+partialRequires+'\''; 
                whereClause2+=' OR Authorization.Licensee_Modification_Reason__c = \''+CRIMINAL_NOTIFICATION+'\')';               
            }
            if(searchCriteria=='Practitioner DBA Name (Partial - enter in the textbox below)'){ 
                String partial= '%' + partialRequires + '%'; 
                whereClause2+= ' AND Authorization.Doing_Business_As_DBA_or_Trade_Name__c LIKE \''+String.escapeSingleQuotes(partial)+'\''; 
                whereClause2+= ' AND Authorization.Issuing_Department_Name__c !=\'Nursing\'';   
            }

            query2 = 'SELECT ' + fieldsToQuery2;
            query2 += ' FROM AuthApplicationPlace ';
            query2 += ' WHERE ' + whereClause2 + 'LIMIT ' + limitValue2;
            Set<String> accountNameWithCriminalRecord = new Set<String>();
           
            List<AuthApplicationPlace> aapData = new List<AuthApplicationPlace>((List<AuthApplicationPlace>)Database.query(query2));
            List<map<string,string>> dataToReturn=new List<map<string,string>>();
            List<LicenseSearchWrapper> licenseSearchList = new List<LicenseSearchWrapper>();
            Integer i=1;
           
            Set<Id> blIdSet = new Set<Id>();

            for(AuthApplicationPlace aap:aapData){
                if(aap.Authorization.Licensee_Modification_Reason__c == CRIMINAL_NOTIFICATION){
                    accountNameWithCriminalRecord.add(aap.Authorization.Business_Entity_Name__c.toLowerCase());
                }
            }
            for(AuthApplicationPlace aap:aapData){
                if(addressIdMap.keyset().contains(aap.PlaceId) && !blIdSet.contains(aap.AuthorizationId) && !accountNameWithCriminalRecord.contains(aap.Authorization.Business_Entity_Name__c.toLowerCase())){
                    LicenseSearchWrapper wrapper = new LicenseSearchWrapper();
                    wrapper.businessLicenseId = aap.AuthorizationId;
                    wrapper.rat = aap.Authorization.Regulatory_Authorization_Type_Name__c;
                    if(aap.Authorization.Licensee_Modification_Reason__c != DOMESTIC_VOILENCE_VICTIM_ORDER)
                    {  
                        if(!addressIdMap.get(aap.PlaceId).isEmpty()){
                            wrapper.city = addressIdMap.get(aap.PlaceId)[0] != null ? addressIdMap.get(aap.PlaceId)[0] : '';
                            wrapper.state = addressIdMap.get(aap.PlaceId)[1] != null ? addressIdMap.get(aap.PlaceId)[1] : '';
                        } 
                    }
                    wrapper.licenseeName = aap.Authorization.Business_Entity_Name__c;
                    wrapper.viewlicenseeName = 'View, ' + aap.Authorization.Business_Entity_Name__c;
                    wrapper.addressId = locIdToAddIdMap.containsKey(aap.PlaceId) ? locIdToAddIdMap.get(aap.PlaceId) : null;
                    wrapper.boardName = aap.Authorization.Issuing_Department_Name__c;
                    wrapper.sNo = ''+ i;
                    i++;
                    blIdSet.add(aap.AuthorizationId);
                    licenseSearchList.add(wrapper);
                }
                
            }
            return licenseSearchList;
        } catch (Exception e) {
            LPI_ExceptionManager.logException(
                'LPI_LicenseSearchController',
                'fetchBusinessLicense',
                e
            );
            throw new LPI_Exception(e.getMessage());
        }
    } 
    @AuraEnabled
    public static List<LicenseSearchWrapper> fetchBLWithoutCounty(String status,String professionName,String searchCriteria, String partialRequires){
        try {
            if (!String.isBlank(partialRequires) && partialRequires.contains('%')) {
                return null;
            }
            String query2;
            String whereClause2 ='';
            String fieldsToQuery2='id,placeId,Authorization.Issuing_Department_Name__c,Authorization.Legacy_License_Number__c,Authorization.Licensee_Modification_Reason__c,Authorization.AccountId,Authorization.RegulatoryAuthorizationType.IssuingDepartmentId,Authorization.First_Name__c, Authorization.Last_Name__c,Authorization.Doing_Business_As_DBA_or_Trade_Name__c,Authorization.status,Authorization.Name,Authorization.Regulatory_Authorization_Type_Name__c,Authorization.Business_Entity_Name__c, AuthorizationId, TYPEOF Place WHEN Location THEN Id,Consent_For__c END'; 
            String limitValue2='50000';
            
            if(status!='Active'){
                String whereClauseStatus = 'Authorization.status = \'Expired\'';
                if(!String.isBlank(professionName)){
                    whereClauseStatus ='';
                    whereClauseStatus = getInactiveStatusByRAT(professionName);
                }
              whereClause2+= whereClauseStatus+'';
              whereClause2+= ' AND Place.Type =\'Location\'';
            }
            if(status=='Active'){
                whereClause2+= ' Authorization.status='+'\''+status+'\'AND Place.Type =\'Location\'';
            }
            if(!String.isBlank(professionName)){
                whereClause2+= ' AND Authorization.RegulatoryAuthorizationTypeId='+'\''+professionName+'\'';
            }
            if( searchCriteria=='Licensee Name (Partial Last, First - enter in the textbox below)'){
                String partial= '%' + partialRequires + '%'; 
                whereClause2+= ' AND (Authorization.First_Name__c LIKE \''+String.escapeSingleQuotes(partial)+'\'';
                whereClause2+= ' OR  Authorization.Last_Name__c LIKE \''+String.escapeSingleQuotes(partial)+'\'';
                whereClause2+= ' OR  Authorization.Business_Name__c LIKE \''+String.escapeSingleQuotes(partial)+'\')';
                whereClause2+= ' AND Authorization.Issuing_Department_Name__c !=\'Nursing\'';
             }
            if(searchCriteria=='License Number (Exact - enter in the textbox below)'){
                whereClause2+= ' AND (Authorization.Name='+'\''+partialRequires+'\'';
                whereClause2+=' OR Authorization.Legacy_License_Number__c = \''+partialRequires+'\''; 
                whereClause2+=' OR Authorization.Licensee_Modification_Reason__c = \''+CRIMINAL_NOTIFICATION+'\')';               
            }
            if(searchCriteria=='Practitioner DBA Name (Partial - enter in the textbox below)'){ 
                String partial= '%' + partialRequires + '%'; 
                whereClause2+= ' AND Authorization.Doing_Business_As_DBA_or_Trade_Name__c LIKE \''+String.escapeSingleQuotes(partial)+'\'';
                whereClause2+= ' AND Authorization.Issuing_Department_Name__c !=\'Nursing\'';   
            }
             

            query2 = 'SELECT ' + fieldsToQuery2;
            query2 += ' FROM AuthApplicationPlace ';
            query2 += ' WHERE ' + whereClause2 + ' LIMIT '+limitValue2;   
            
            Set<String> accountNameWithCriminalRecord = new Set<String>(); 
            List<AuthApplicationPlace> aapData = new List<AuthApplicationPlace>((List<AuthApplicationPlace>)Database.query(query2));
            // aap.Id -> Location Id (all linked locations)
            Map<Id,Id> aapToLocationMap = new Map<Id,Id>();
            // Prefer locations marked for public display when available
            Map<Id,Id> aapToPublicLocationMap = new Map<Id,Id>();
            Map<Id,AuthApplicationPlace> blAAP = new Map<Id,AuthApplicationPlace>();
            Set<Id> allLocationIds = new Set<Id>();
            for(AuthApplicationPlace aap : aapData){
                if(aap.Authorization.Licensee_Modification_Reason__c == CRIMINAL_NOTIFICATION){
                    accountNameWithCriminalRecord.add(aap.Authorization.Business_Entity_Name__c.toLowerCase());
                }
                if (aap.Place instanceof Schema.Location) {
                    Schema.Location loc = aap.Place;
                    aapToLocationMap.put(aap.Id, loc.Id);
                    allLocationIds.add(loc.Id);
                    Boolean isPublicAddress = loc.Consent_For__c != null
                        && loc.Consent_For__c.contains('Publicly Displayed Address');
                    if (isPublicAddress) {
                        aapToPublicLocationMap.put(aap.Id, loc.Id);
                        blAAP.put(aap.AuthorizationId, aap);
                    } else if (!blAAP.containsKey(aap.AuthorizationId)) {
                        blAAP.put(aap.AuthorizationId, aap);
                    }
                }
            }
            List<String> citystate = new list<string>();
            Map<Id,List<String>> addressIdMap = new Map<Id,List<String>>();
            Map<Id,Id> locIdToAddIdMap = new Map<Id,Id>();
            if(!allLocationIds.isEmpty()){
                // Load addresses for all linked locations; prefer public-consent ones at assignment time
                String whereClause ='ParentId IN '+ LPI_ServiceUtility.getStringValuesBySet(allLocationIds);
                String fieldsToQuery='Id,address, Parent.Id,Parent.Consent_For__c, County__c,Business_State__c'; 
                String limitValue='50000';
                String query = 'SELECT ' + fieldsToQuery;
                query += ' FROM Address ';
                query += ' WHERE ' + whereClause ;
                
                List<Schema.Address> addr=new List<Schema.Address>((List<Schema.Address>)Database.query(query));

                for(Schema.Address a:addr){
                    citystate = new list<string>();
                    citystate.add(a.address.getCity());
                    if(a.address.getState() != null){
                        citystate.add(a.address.getState());
                    }else{
                        citystate.add(a.Business_State__c);
                    }
                    
                    addressIdMap.put(a.Parent.Id, citystate); 
                    locIdToAddIdMap.put(a.Parent.Id,a.Id);
                } 
            }
             
            List<LicenseSearchWrapper> licenseSearchList = new List<LicenseSearchWrapper>();
            Integer i=1;
            for(AuthApplicationPlace aap : blAAP.values()){
                if(aap.Authorization != null && aap.Authorization.Business_Entity_Name__c != null
                    && !accountNameWithCriminalRecord.contains(aap.Authorization.Business_Entity_Name__c.toLowerCase())){
                    LicenseSearchWrapper wrapper = new LicenseSearchWrapper();

                    wrapper.businessLicenseId = aap.AuthorizationId;
                    wrapper.rat = aap.Authorization.Regulatory_Authorization_Type_Name__c;
                    Id locationIdForAddress = aapToPublicLocationMap.containsKey(aap.Id)
                        ? aapToPublicLocationMap.get(aap.Id)
                        : aapToLocationMap.get(aap.Id);
                    if(locationIdForAddress != null
                        && addressIdMap.containsKey(locationIdForAddress)
                        && aap.Authorization.Licensee_Modification_Reason__c != DOMESTIC_VOILENCE_VICTIM_ORDER ){ 
                        List<String> addressParts = addressIdMap.get(locationIdForAddress);
                        wrapper.city = addressParts.isEmpty() || addressParts[0] == null ? '' : addressParts[0];
                        wrapper.state = addressParts.size() < 2 || addressParts[1] == null ? '' : addressParts[1];
                        wrapper.addressId = locIdToAddIdMap.containsKey(locationIdForAddress)
                            ? locIdToAddIdMap.get(locationIdForAddress)
                            : '';
                    }else{
                        wrapper.city = '';
                        wrapper.state = '';
                        wrapper.addressId = '';
                    }
                    wrapper.licenseeName = aap.Authorization.Business_Entity_Name__c;
                    wrapper.viewlicenseeName = 'View, ' + aap.Authorization.Business_Entity_Name__c;
                    wrapper.boardName = aap.Authorization.Issuing_Department_Name__c;
                    wrapper.sNo = ''+ i;
                    i++;
                    licenseSearchList.add(wrapper);
                }
            }
        return licenseSearchList;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage()+'--'+ e.getLineNumber());
        }
    }
    public static String getInactiveStatusByRAT(Id ratId){
      List<RegulatoryAuthorizationType> ratList =   [select id, IssuingDepartment.name from RegulatoryAuthorizationType  WHERE ID=:ratId LIMIT 1];
      List<License_Search_Configuration__c> lscList = [select id, Regulatory_Authority__r.name, Status__c from License_Search_Configuration__c WHERE Regulatory_Authority__r.name=:ratList[0].IssuingDepartment.name AND Status__c !='Active' LIMIT 1];
      
      String search = '';
      
      for(License_Search_Configuration__c lsc : lscList){
        List<String> statusQuery = lscList[0].Status__c.split(';');
        search = '( Authorization.status = \''+ statusQuery[0] +'\'';
        for(String str: statusQuery){
            
            if(!search.contains(str)){
                search += ' OR Authorization.status =\''+str+'\'';
            }
        }
        search +=')';
      }
      
      return search;
    }

    public class LicenseSearchWrapper{
        @AuraEnabled public String businessLicenseId; 
        @AuraEnabled public String rat;
        @AuraEnabled public String city;
        @AuraEnabled public String state;
        @AuraEnabled public String licenseeName;
        @AuraEnabled public String sNo;
        @AuraEnabled public String addressId;
        @AuraEnabled public String boardName;
        @AuraEnabled public String viewlicenseeName;

    }
    @AuraEnabled
    public static List<HeadingFieldValueWrapper> getApplicationData(String blId,String addId,String status,String directApplication) {
        try {
            if(String.isNotEmpty(blId)){
                String fields = 'Id,RegulatoryAuthorizationType.IssuingDepartmentId,Licensee_Modification_Reason__c';
                String whereClause = '';
                // LWC may pass a Boolean that serializes to ''/null for a String param.
                // Only treat explicit "true" as name-based (URL) lookup; otherwise use Id (View button).
                Boolean lookupByLicenseName = String.isNotBlank(directApplication)
                    && directApplication.equalsIgnoreCase('true');
                Boolean looksLikeSalesforceId = false;
                try {
                    looksLikeSalesforceId = (Id.valueOf(blId) != null);
                } catch (Exception ignore) {
                    looksLikeSalesforceId = false;
                }

                if (!lookupByLicenseName || looksLikeSalesforceId) {
                    // View-from-search always sends BusinessLicense Id
                    whereClause = ' Id = \'' + String.escapeSingleQuotes(blId) + '\'';
                } else {
                    status = 'Active';
                    whereClause = ' Name = \'' + String.escapeSingleQuotes(blId) + '\'';
                }
                List<BusinessLicense> blRecordList = new LPI_BusinessLicenseDAO.LPI_BusinessLicenseWithoutSharingDAO().getBusinessLicenseByDymanicQueryWithoutSecurity(
                    fields,whereClause,null,null,null
                );
                if(!blRecordList.isEmpty()){
                    blId = blRecordList[0].Id;
                    Id issuingDeptId = blRecordList[0].RegulatoryAuthorizationType != null
                        ? blRecordList[0].RegulatoryAuthorizationType.IssuingDepartmentId
                        : null;
                    List<License_Search_Configuration__c>  configList = new List<License_Search_Configuration__c>();
                    if(status != 'Active'){
                        configList = [SELECT Id,Business_License_Object_Fields__c,Status__c,Certification_Fields__c,
                                                                            Other_Business_Address__c,Address__c
                                                                            FROM License_Search_Configuration__c 
                                                                            WHERE Regulatory_Authority__c =: issuingDeptId
                                                                            AND Status__c != 'Active'];
                    }else{
                        configList = [SELECT Id,Business_License_Object_Fields__c,Status__c,Certification_Fields__c,
                                                                            Other_Business_Address__c,Address__c
                                                                            FROM License_Search_Configuration__c 
                                                                            WHERE Regulatory_Authority__c =: issuingDeptId
                                                                            AND Status__c=:status];
                    }
                    
                    List<HeadingFieldValueWrapper> applicationViewList = new List<HeadingFieldValueWrapper>();
                    Map<String,String> fieldValueMap = new Map<String,String>();
                    if(!configList.isEmpty() && String.isNotEmpty(configList[0].Business_License_Object_Fields__c)){
                        fieldValueMap = (Map<String,String>)JSON.deserialize(configList[0].Business_License_Object_Fields__c,Map<String,String>.Class);
                        if(!fieldValueMap.isEmpty()) {
                            applicationViewList.add(getDynamicDetail('License',fieldValueMap,'BusinessLicense','Id',blId));
                            if(String.isNotEmpty(configList[0].Certification_Fields__c)){
                                fieldValueMap = (Map<String,String>)JSON.deserialize(configList[0].Certification_Fields__c,Map<String,String>.Class);
                                applicationViewList.add(getDynamicDetail('Certification',fieldValueMap,'BoardCertification','Business_License__c',blId));
                            }
                            if(String.isNotEmpty(configList[0].Address__c) && blRecordList[0].Licensee_Modification_Reason__c != DOMESTIC_VOILENCE_VICTIM_ORDER){
                                fieldValueMap = (Map<String,String>)JSON.deserialize(configList[0].Address__c,Map<String,String>.Class);
                                if(String.isNotEmpty(addId) && addId != ''){
                                    applicationViewList.add(getDynamicDetail('Address Information',fieldValueMap,'Address','Id',addId));
                                }else{
                                    addId = fetchPublicAddressId(blId);
                                    if(String.isNotEmpty(addId)){
                                    applicationViewList.add(getDynamicDetail('Address Information',fieldValueMap,'Address','Id',addId));}
                                }
                            }
                            
                            if(configList[0].Other_Business_Address__c &&  blRecordList[0].Licensee_Modification_Reason__c != DOMESTIC_VOILENCE_VICTIM_ORDER){
                                List<HeadingFieldValueWrapper>  otherBusinesList = getOtherBusinessAddress(blId);
                                if(otherBusinesList != null){
                                    applicationViewList.addAll(otherBusinesList);
                                }
                            }
                            return applicationViewList;
                        }
                    }
                    // License found but no License Search Configuration for its issuing department.
                    // Returning null surfaces as "Invalid License Number" in the LWC; keep contract but log for admins.
                    System.debug(LoggingLevel.WARN,
                        'License Search Configuration missing for Issuing Department: ' + issuingDeptId
                        + ' / BusinessLicense: ' + blId + ' / status: ' + status);
                }
            }
            return null;
        } catch (Exception e) {
            LPI_ExceptionManager.logException('LPI_LicenseSearchController','getApplicationData',e);
            throw new AuraHandledException(e.getMessage());
        }
    }
    private static String fetchPublicAddressId(String blId){
        String query = 'SELECT Id,PlaceId,AuthorizationId,TYPEOF Place WHEN Location THEN Id,Consent_For__c END FROM AuthApplicationPlace WHERE AuthorizationId =:blId';
        List<AuthApplicationPlace> aapData = new List<AuthApplicationPlace>((List<AuthApplicationPlace>)Database.query(query));
        String locationId = '';
        String fallbackLocationId = '';

        for(AuthApplicationPlace aap : aapData){
            if (aap.Place instanceof Schema.Location) {
                Schema.Location loc = aap.Place;
                if(loc.Consent_For__c !=null && loc.Consent_For__c.contains('Publicly Displayed Address')){
                    locationId = loc.Id;
                    break;
                }
                if (String.isBlank(fallbackLocationId)) {
                    fallbackLocationId = loc.Id;
                }
            }
        }
        if(String.isBlank(locationId)){
            locationId = fallbackLocationId;
        }
        if(String.isNotBlank(locationId)){
            List<Schema.Address> addList = new LPI_AddressDAO.LPI_AddressDAOWithoutSharing().getAddressByDymanicQuery('Id',' ParentId =\''+locationId+'\'','1',null,null);
            if(!addList.isEmpty()){
                return addList[0].Id;
            }
        }
        return null;
    }
    private static HeadingFieldValueWrapper getDynamicDetail(String headingName,Map<String,String> fieldValueMap,String objName,String mappingFields,String blId) {
        try {
            List<FieldValueWrapper> fieldValues = new List<FieldValueWrapper>();
            String fields = String.join(new List<String>(fieldValueMap.keySet()), ',' );
            String query = 'SELECT ' + fields +' FROM ' + objName;
            query += ' WHERE '+ mappingFields +' = \'' + String.escapeSingleQuotes(blId) + '\'';
            List<SObject> recordList = Database.query(query);
            boolean alreadyAddedLicenseNumber = false;
            if(!recordList.isEmpty()){  
                for(String key : fieldValueMap.keySet()){
                    // Hide Current Discipline Status from public license search details
                    if (key == 'Disciplinary_Status__c'
                        || fieldValueMap.get(key) == 'Current Discipline Status') {
                        continue;
                    }
                    String typeValue = LPI_UtilityDescribe.globalDescribe.get(objName)
                        .getDescribe()
                        .fields.getMap()
                        .get((String) key)
                        .getDescribe()
                        .getType()
                        .name();
                    if(typeValue == 'Datetime' ){
                        DateTime dt = recordList[0].get(key) !=null ? DateTime.valueOf(string.valueOf(recordList[0].get(key))) : null;
                        if(dt != null){
                            fieldValues.add(new FieldValueWrapper(fieldValueMap.get(key),string.valueOf(dt.format('MM/dd/yyyy')),true));
                        }
                        else{
                            fieldValues.add(new FieldValueWrapper(fieldValueMap.get(key),'',true));
                        }
                    }else{
                        if(key == 'Business_State__c'  || key == 'State'){
                            if(string.valueOf(recordList[0].get(key)) != null){
                                fieldValues.add(new FieldValueWrapper(fieldValueMap.get(key),string.valueOf(recordList[0].get(key)),true));
                            }
                        }else{
                            if(key == 'Legacy_License_Number__c'){
                                if(String.isNotBlank(string.valueOf(recordList[0].get(key)))){
                                    alreadyAddedLicenseNumber = true;
                                    fieldValues.add(new FieldValueWrapper(fieldValueMap.get(key),string.valueOf(recordList[0].get(key)),true));
                                }
                            }else{
                                if(!(alreadyAddedLicenseNumber && key == 'Name')){
                                    fieldValues.add(new FieldValueWrapper(fieldValueMap.get(key),string.valueOf(recordList[0].get(key)),true));
                                }
                            }
                        }
                    } 
                }
            }
            if(!fieldValues.isEmpty()){
                return new HeadingFieldValueWrapper(headingName,fieldValues);
            }
            return null;
        } catch (Exception e) {
            LPI_ExceptionManager.logException('LPI_LicenseSearchController','getDynamicDetail',e);
            throw new AuraHandledException(e.getMessage());
        }
    }
    private static List<HeadingFieldValueWrapper> getOtherBusinessAddress(String blId) {
        try {
            String query = 'SELECT Id,PlaceId,AuthorizationId,TYPEOF Place WHEN Location THEN Id,LocationType,Status__c END FROM AuthApplicationPlace WHERE AuthorizationId =:blId';
            List<AuthApplicationPlace> aapData = new List<AuthApplicationPlace>((List<AuthApplicationPlace>)Database.query(query));
            Map<Id,Id> blIdTolocId = new Map<Id,Id>();
            for(AuthApplicationPlace aap : aapData){
                if (aap.Place instanceof Schema.Location) {
                    Schema.Location loc = aap.Place;
                    if(loc.LocationType == 'Branch' && loc.Status__c == 'Open') {
                        blIdTolocId.put(aap.PlaceId,aap.AuthorizationId);
                    }
                }
            }
            
            Integer index =1;
            List<HeadingFieldValueWrapper> headingValueList = new List<HeadingFieldValueWrapper>();
            if(!blIdTolocId.isEmpty()){
                String addrQuery = 'Select Id, ParentId,Street, City, State, PostalCode, County__c FROM Address WHERE ParentId IN '+LPI_ServiceUtility.getStringValuesBySet(blIdTolocId.keyset());
                List<Schema.Address> addressList = new List<Schema.Address>((List<Schema.Address>)Database.query(addrQuery));
                for(Schema.Address addr: addressList){
                    List<FieldValueWrapper> fieldValues = new List<FieldValueWrapper>();
                    fieldValues.add(new FieldValueWrapper ('Steet', (addr.street !=null ? addr.street : ''), true));
                    fieldValues.add(new FieldValueWrapper ('City', (addr.city !=null ? addr.city : ''), true));
                    fieldValues.add(new FieldValueWrapper ('State', (addr.state !=null ? addr.state : ''),true));
                    fieldValues.add(new FieldValueWrapper ('Zip Code', (addr.postalcode !=null ? addr.postalcode : ''),true));
                    fieldValues.add(new FieldValueWrapper ('County', (addr.County__c !=null ? addr.County__c : ''),true));
                    headingValueList.add(new HeadingFieldValueWrapper('Other Business Address - '+ index,fieldValues));
                    index++;
                }
            }
            if(!headingValueList.isEmpty()){
                return headingValueList;
            }
            return null;
        } catch (Exception e) {
            LPI_ExceptionManager.logException('LPI_LicenseSearchController','getDynamicDetail',e);
            throw new AuraHandledException(e.getMessage());
        }
    }
   
    public class FieldValueWrapper {
        @AuraEnabled public String label;
        @AuraEnabled public String value;
        @AuraEnabled public Boolean isCoverCompleteWidth;
        public FieldValueWrapper() {
        }
        public FieldValueWrapper(String label, String value,Boolean isCoverCompleteWidth) {
            this.label = label;
            this.value = value;
            this.isCoverCompleteWidth = isCoverCompleteWidth;
        }
    }
    public class HeadingFieldValueWrapper {
        @AuraEnabled public String headingName;
        @AuraEnabled public List<FieldValueWrapper> headingFieldValue;
        public HeadingFieldValueWrapper(){

        }
        public HeadingFieldValueWrapper(
            String headingName,
            List<FieldValueWrapper> headingFieldValue
        ) {
            this.headingName = headingName;
            this.headingFieldValue = headingFieldValue;
        }
    }
      
}