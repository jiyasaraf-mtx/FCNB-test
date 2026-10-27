/**
* @author              : MTX Group Product Team
* @since               : 2nd Jan, 2023
* @description         : This class is used to fetch Ownership Inormation.
*                        To get Individual License records which can be associated as Owner.
*                        To save, update and delete acr's associated as per actions.
*/
global with sharing class LPI_OwnershipInformationController implements Callable {
    
    private static final String CLASS_NAME = 'LPI_OwnershipInformationController';
   
    private static final String OWNERSHIPTYPE_INDIVIDUAL = 'Individual/Sole Proprietorship';
    private static final String OWNERHSIPTYPE_CORPORATION = 'Corporation';
    private static final String AMENDMENTTYPE_ADDING_A_CO_OWNER = 'Adding a Co-Owner';
    private static final String OWNERSHIP_TITLE = 'Ownership Information ';


    /**
    * @author           MTX Group Product Team
    * @description       Call method is used to run Invoke method.
    * @return  `Object`
    */
    global Object call(String action, Map<String, Object> args) {
        Map<String, Object> input = (Map<String, Object>) args.get('input');
        Map<String, Object> output = (Map<String, Object>) args.get('output');
        Map<String, Object> options = (Map<String, Object>) args.get('options');
        return invokeMethod(action, input, output, options);
    }
    
    /**
    * @author            MTX Group Product Team
    * @description       This method will compare method from Omniscript and execute only that specific method
    * @return  `Boolean`
    */
    private Boolean invokeMethod(String methodName, Map<String, Object> inputMap, Map<String, Object> outMap, Map<String, Object> options) {
        Boolean result = true;
        try {
            switch on methodName {
                when 'loadOwnerShipInformation' {
                    outMap.put('ownershipInformationWrap', JSON.deserializeUntyped(JSON.serialize(loadOwnerShipInformation(inputMap))));
                }
                when 'saveOwnerShipnformation' {
                    saveOwnerShipnformation(inputMap, outMap);
                }
                when 'getOwnershipDetailsByLicense' {
                    outMap.put('licData',JSON.deserializeUntyped(JSON.serialize(getOwnershipDetailsByLicense(inputMap))));
                }
                when 'deleteRelationShipData' {
                    deleteRelationShipData(inputMap);
                }
                 
                when 'fetchPicklist' {
                    outMap.put('picklistValues', JSON.deserializeUntyped(JSON.serialize(fetchPicklist(inputMap))));
                }
            }
        } catch (Exception e) {
            result = false;
            LPI_ExceptionManager.logException(CLASS_NAME, 'invokeMethod', e);
            throw new AuraHandledException(e.getMessage() + e.getLineNumber());
        }
        return result;
    }
    /**
    * @author          MTX Group Product Team
    * @description     Method is used to load the data on Ownership Information Section
    * @param           inputMap 
    * @return  `OwnershipInformationWrapper`
    */
    public static OwnershipInformationWrapper loadOwnerShipInformation(Map<String,Object> inputMap){
        try{
            String parId = (String) inputMap.get('parId');        
            OwnershipInformationWrapper ownershipInformationWrap= new OwnershipInformationWrapper();
            if(String.isNotEmpty(parId)){
                List<OwnerInformation> ownerInfo = new List<OwnerInformation>();
                List<String> activeSections=new List<String>();
                List<PreliminaryApplicationRef> parRec = LPI_PreliminaryApplicationRefDAO.getPreliminaryApplicationRefByDymanicQuery(
                    'Id, BusinessAccountNameId, Amendment_Type__c, Related_Owner_Ids__c, BusinessAccountName.How_are_you_associated_to_this_entity__c, BusinessAccountName.Other_Entity_Type__c,BusinessAccountName.Entity_type__c, Regulatory_Authorization_Type__r.Name,Regulatory_Authorization_Type__r.IssuingDepartment.Name ',
                    'Id=\''+parId+'\'',
                    null,null,null
                );
                if(!parRec.isEmpty()){
                    String queryBusinessAccountId  = '';
                        queryBusinessAccountId = parRec[0].BusinessAccountNameId;
                        ownershipInformationWrap.showAllOwnerShip = true;
                        ownershipInformationWrap.showAddOwnerShipDetails = parRec[0].BusinessAccountName.Entity_type__c == OWNERSHIPTYPE_INDIVIDUAL || parRec[0].Amendment_Type__c==AMENDMENTTYPE_ADDING_A_CO_OWNER ?false:true;
                        ownershipInformationWrap.isCorporateOwnerShipType = parRec[0].BusinessAccountName.Entity_type__c == OWNERHSIPTYPE_CORPORATION ? true:false;
                    
                    ownershipInformationWrap.boardName = parRec[0].Regulatory_Authorization_Type__r.IssuingDepartment.Name;
                    ownershipInformationWrap.licenseType = parRec[0].Regulatory_Authorization_Type__r.Name;
                    if(String.isNotEmpty(queryBusinessAccountId) ){
                        User usrData = LPI_WithoutSharingUtility.getUserRecordDetailWithoutSharing(UserInfo.getUserId());
                        Map<Id, Business_Relationships__c> accIdWithReldata =  new Map<Id, Business_Relationships__c>();

                        String businessRelationShipWhereClouse= '';
                        if(parRec[0].Amendment_Type__c==AMENDMENTTYPE_ADDING_A_CO_OWNER && parRec[0].Related_Owner_Ids__c != null){
                            businessRelationShipWhereClouse='Id=\'' +parRec[0].Related_Owner_Ids__c+'\'';

                        } else if(parRec[0].Amendment_Type__c!=AMENDMENTTYPE_ADDING_A_CO_OWNER){
                            businessRelationShipWhereClouse ='(Related_From__c =\''+queryBusinessAccountId +'\' OR  Related_To__c=\''+queryBusinessAccountId+'\')  AND Roles__c=\''+LPI_LiteralConstant.ROLE_OWNER+'\' AND Start_Date__c != NULL AND EndDate__c = NULL';
                        }
                        
                        List<Business_Relationships__c> relDataList = new List<Business_Relationships__c>();
                        if(String.isNotBlank(businessRelationShipWhereClouse)){
                            relDataList = new LPI_BusinessRelationshipDAO.LPI_BusinessRelationshipsWithoutSharingDAO().getBusinessRelationshipsByDymanicQuery(
                                'Id, License_Number__c, Ownership_Percent__c,Related_To_License_Number__c, Related_From_License_Number__c, Related_To_License_Number__r.License_Number_With_Rat_Name__c, Related_From_License_Number__r.License_Number_With_Rat_Name__c, IsActive__c, License_Type__c, Is_the_Owner_a_Business_Entity__c, Is_Licensed_Entity__c, Related_From__c, Related_To__c',
                                businessRelationShipWhereClouse,
                                null,null,null
                        	);
                        }
                        
                        for(Business_Relationships__c relData: relDataList) {
                            if(relData.Is_the_Owner_a_Business_Entity__c == 'Yes'){
                                accIdWithReldata.put(relData.Related_From__c, relData);
                            } else {
                                accIdWithReldata.put(relData.Related_To__c, relData);
                            }
                        }


                        if(accIdWithReldata.keySet().size()>0) {
                           
                            List<Account> accList = new LPI_AccountDAO.LPI_AccountWithoutSharingDAO().getAccountByDymanicQuery(
                                'Id, Name, Phone, Buisness_Email__c, BillingStreet, BillingCountryCode, BillingCountry, BillingCity, BillingStateCode, BillingState, BillingPostalCode , County__c, Other_State__c,  FirstName, LastName, MiddleName, PersonOtherCity, PersonOtherStateCode, PersonOtherState, PersonOtherCountry, PersonOtherPostalCode, PersonOtherStreet, PersonOtherCountryCode, RecordType.DeveloperName, PersonTitle, PersonBirthdate, Date_of_Birth__c, Social_Security_Number__c, PersonEmail',
                                'Id IN '+LPI_ServiceUtility.getStringValuesBySet(accIdWithReldata.keySet()) ,
                                null,null,null
                            );
                            for(Account accData: accList)
                            {
                                Business_Relationships__c relData = accIdWithReldata.get(accData.Id);
                                if(accData.RecordType.DeveloperName == LPI_LiteralConstant.ACCOUNT_BUSINESS_RECORDTYPE){
                                    
                                    OwnerInformation ownerData= new OwnerInformation();     
                                    ownerData.boardName = parRec[0].Regulatory_Authorization_Type__r.IssuingDepartment.Name;
                                    ownerData.licenseType = parRec[0].Regulatory_Authorization_Type__r.Name;
                                    ownerData.uniqueId = ownerInfo.size();
                                    ownerData.isCorporateOwnerShip = ownershipInformationWrap.isCorporateOwnerShipType;
                                    ownerData.ownershipInformationTitle =  OWNERSHIP_TITLE  + (ownerInfo.size()>0? ''+(ownerInfo.size()+1):''+1);
                                    ownerData.isTheOwnerBusinessEntityName =  'isTheOwnerBusinessEntityName'+ownerInfo.size();
                                    ownerData.isBusinessEntityData = relData.Is_the_Owner_a_Business_Entity__c;
                                    ownerData.isBusinessOwner = relData.Is_the_Owner_a_Business_Entity__c=='Yes'?true:false;
                                    ownerData.isIndividualOwner = relData.Is_the_Owner_a_Business_Entity__c=='No'?true:false;
                                    ownerData.searchedKey = relData.Is_the_Owner_a_Business_Entity__c=='No'? relData.Related_To_License_Number__r.License_Number_With_Rat_Name__c:relData.Related_From_License_Number__r.License_Number_With_Rat_Name__c;
                                    ownerData.businessLicenseId = relData.Related_From_License_Number__c;
                                    ownerData.isTheBusinessLicensedInMOName = 'isTheBusinessLicensedInMOName'+ownerInfo.size();
                                    ownerData.isTheOwnerLicensedInMO =relData.Is_Licensed_Entity__c ;
                                    ownerData.showOwnerShipSection = String.isNotEmpty(relData.Is_Licensed_Entity__c)?true:false ;
                                    ownerData.showLookUpLicense = relData.Is_Licensed_Entity__c=='Yes'?true:false;
                                    ownerData.licenseNumber = relData.License_Number__c;
                                    ownerData.isPartialDisable = relData.Is_Licensed_Entity__c=='Yes'?true:false;
                                    ownerData.isPartialRequired = ownerData.isPartialDisable==true?false:true;
                                    ownerData.businessName = accData.Name;
                                    ownerData.businessEmail = accData.Buisness_Email__c;
                                    ownerData.busienssPhone = accData.Phone;
                                    ownerData.ownershipPercent = relData.Ownership_Percent__c ;
                                    ownerData.businessAccountId = accData.Id;
                                    ownerData.country = accData.BillingCountryCode;
                                    ownerData.streetAddress1 = accData.BillingStreet;
                                    ownerData.city = accData.BillingCity;
                                    ownerData.isUsState = accData.BillingCountryCode == 'US'?true:false;
                                    ownerData.state = accData.BillingStateCode;
                                    ownerData.stateText = accData.Other_State__c;
                                    ownerData.zipCode = accData.BillingPostalCode;
                                    ownerData.county = accData.County__c;
                                    ownerData.countryValue = accData.BillingCountry;
                                    ownerData.stateValue = accData.BillingState;
                                    ownerData.isTheOwnerLicensedInMOName = 'isTheOwnerLicensedInMOName'+ownerInfo.size();
                                    ownerData.firstName = '';
                                    ownerData.middleName = '';
                                    ownerData.lastName = '';        
                                    ownerData.email = '';
                                    ownerData.SSN = '';
                                    ownerData.birthdate = null;
                                    ownerData.title = '';
                                    ownerData.personAccountId = '';
                                    ownerData.relationShipId = relData.Id;
                                    ownerData.showDelete = ownerInfo.size()>0 ? true : false;
                                    ownerData.isStateMO = ownerData.isUsState && ownerData.state == 'MO' ? true : false;

                                    activeSections.add(ownerData.ownershipInformationTitle);
                                    ownerInfo.add(ownerData);
                                } else {
                                    OwnerInformation ownerData= new OwnerInformation();
                                    ownerData.boardName = parRec[0].Regulatory_Authorization_Type__r.IssuingDepartment.Name;      
                                    ownerData.licenseType = parRec[0].Regulatory_Authorization_Type__r.Name;
                                    ownerData.searchedKey = relData.Is_the_Owner_a_Business_Entity__c=='No'? relData.Related_To_License_Number__r.License_Number_With_Rat_Name__c:relData.Related_From_License_Number__r.License_Number_With_Rat_Name__c;
                                    ownerData.businessLicenseId = relData.Related_To_License_Number__c;
                                    ownerData.uniqueId = ownerInfo.size();
                                    ownerData.isCorporateOwnerShip = ownershipInformationWrap.isCorporateOwnerShipType;
                                    ownerData.ownershipInformationTitle =  OWNERSHIP_TITLE  + (ownerInfo.size()>0? ''+(ownerInfo.size()+1):''+1);
                                    ownerData.isTheOwnerBusinessEntityName =  'isTheOwnerBusinessEntityName'+ownerInfo.size();
                                    ownerData.isBusinessEntityData = relData.Is_the_Owner_a_Business_Entity__c;
                                    ownerData.isBusinessOwner = relData.Is_the_Owner_a_Business_Entity__c=='Yes'?true:false;
                                    ownerData.isIndividualOwner = relData.Is_the_Owner_a_Business_Entity__c=='No'?true:false;
                                    ownerData.isTheBusinessLicensedInMOName = 'isTheBusinessLicensedInMOName'+ownerInfo.size();
                                    ownerData.isTheOwnerLicensedInMO =relData.Is_Licensed_Entity__c ;
                                    ownerData.showOwnerShipSection = String.isNotEmpty(relData.Is_Licensed_Entity__c)?true:false ;
                                    ownerData.showLookUpLicense = relData.Is_Licensed_Entity__c=='Yes'?true:false;
                                    ownerData.licenseNumber = relData.License_Number__c;
                                    ownerData.isPartialDisable = relData.Is_Licensed_Entity__c=='Yes'?true:false;
                                    ownerData.isPartialRequired = ownerData.isPartialDisable==true?false:true;
                                    ownerData.businessName = '';
                                    ownerData.businessEmail = '';
                                    ownerData.busienssPhone = '';
                                    ownerData.ownershipPercent = relData.Ownership_Percent__c ;
                                    ownerData.businessAccountId = '';
                                    ownerData.country = accData.PersonOtherCountryCode;
                                    ownerData.streetAddress1 = accData.PersonOtherStreet;
                                    ownerData.city = accData.PersonOtherCity;
                                    ownerData.isUsState = accData.PersonOtherCountryCode == 'US'?true:false;
                                    ownerData.state = accData.PersonOtherStateCode;
                                    ownerData.stateText = accData.Other_State__c;
                                    ownerData.zipCode = accData.PersonOtherPostalCode;
                                    ownerData.county = accData.County__c;
                                    ownerData.countryValue = accData.PersonOtherCountry;
                                    ownerData.stateValue = accData.PersonOtherState;
                                    ownerData.isTheOwnerLicensedInMOName='isTheOwnerLicensedInMOName'+ownerInfo.size();
                                    ownerData.firstName =  accData.FirstName;
                                    ownerData.middleName =  accData.MiddleName;
                                    ownerData.lastName =  accData.LastName;
                                    ownerData.email =  accData.PersonEmail;
                                    ownerData.SSN =  accData.Social_Security_Number__c;
                                    ownerData.birthdate = accData.Date_of_Birth__c;
                                    ownerData.title =  String.isEmpty(accData.PersonTitle)? '':accData.PersonTitle;
                                    ownerData.personAccountId =  accData.Id;
                                    ownerData.relationShipId = relData.Id;
                                    ownerData.showDelete = ownerInfo.size()>0 ? true : false;
                                    ownerData.isStateMO = ownerData.isUsState && ownerData.state == 'MO' ? true : false;
                                    activeSections.add(ownerData.ownershipInformationTitle);
                                    ownerInfo.add(ownerData);
                                }
                            }
                        }
                    }
                }
                
                if(ownerInfo.size()==0){
                    
                    OwnerInformation ownerData= new OwnerInformation();
                    ownerData.boardName = parRec[0].Regulatory_Authorization_Type__r.IssuingDepartment.Name;
                    ownerData.licenseType = parRec[0].Regulatory_Authorization_Type__r.Name;
                    ownerData.uniqueId = 0;
                    ownerData.isCorporateOwnerShip = ownershipInformationWrap.isCorporateOwnerShipType;
                    ownerData.showDelete =false ;
                    ownerData.ownershipInformationTitle = OWNERSHIP_TITLE +'1';
                    ownerData.isTheOwnerBusinessEntityName = 'isTheOwnerBusinessEntityName0';
                    ownerData.isBusinessEntityData = '';
                    ownerData.isBusinessOwner =false ;
                    ownerData.isIndividualOwner = false;
                    ownerData.isTheBusinessLicensedInMOName = 'isTheBusinessLicensedInMOName0';
                    ownerData.isTheOwnerLicensedInMO = ownershipInformationWrap.isCorporateOwnerShipType?'No':'';
                    ownerData.showOwnerShipSection = ownershipInformationWrap.isCorporateOwnerShipType;
                    ownerData.showLookUpLicense = false;
                    ownerData.licenseNumber = '';
                    ownerData.isPartialDisable = false;
                    ownerData.isPartialRequired = true;
                    ownerData.businessName = '';
                    ownerData.businessEmail = '';
                    ownerData.busienssPhone = '';
                    ownerData.ownershipPercent = null;
                    ownerData.businessAccountId = '';
                    ownerData.country = '';
                    ownerData.streetAddress1 = '';
                    ownerData.city = '';
                    ownerData.isUsState = false;
                    ownerData.state = '';
                    ownerData.stateText = '';
                    ownerData.zipCode = '';
                    ownerData.county = '';
                    ownerData.countryValue = '';
                    ownerData.stateValue = '';
                    ownerData.isTheOwnerLicensedInMOName = 'isTheOwnerLicensedInMOName0';
                    ownerData.firstName = '';
                    ownerData.middleName = '';
                    ownerData.lastName = '';
                    ownerData.email = '';
                    ownerData.SSN = '';
                    ownerData.birthdate = null;
                    ownerData.title = '';
                    ownerData.personAccountId = '';
                    ownerData.relationShipId = '';
                    ownerData.searchedKey = '';
                    ownerData.businessLicenseId = '';
                    ownerData.isStateMO = false;

                    ownerInfo.add(ownerData);
                    activeSections.add(OWNERSHIP_TITLE +'1');
                }
                ownershipInformationWrap.activeSections=activeSections;
                ownershipInformationWrap.ownerInformation=ownerInfo;
            }
            
            return ownershipInformationWrap;
        }catch(Exception e){
            LPI_ExceptionManager.logException(CLASS_NAME, 'loadOwnerShipInformation', e);
            throw new AuraHandledException(e.getMessage() + e.getLineNumber());
        }
    }   
    /**
    * @author         MTX Group Product Team
    * @description    Method used to save compare Person Account and Account Contact Relation record.
    * @param          inputMap 
    */
    private void saveOwnerShipnformation(Map<String,Object> inputMap ,Map < String, Object > outMap){
        
        try{
            
            
            String parId = (String) inputMap.get('parId');
            
            String ownershipInformationWrap = (String)inputMap.get('ownershipInformationWrap');
            
            if(String.isNotEmpty(parId)){
                
                
                OwnershipInformationWrapper ownershipInformationData = (OwnershipInformationWrapper)JSON.deserialize(ownershipInformationWrap,
                                                                                                                     OwnershipInformationWrapper.class);
                
                 
                List<PreliminaryApplicationRef> parRec = LPI_PreliminaryApplicationRefDAO.getPreliminaryApplicationRefByDymanicQuery(
                    'Id, BusinessAccountNameId, Related_Owner_Ids__c',
                    'Id=\''+parId+'\'',
                    null,null,null
                );
                
                if(!parRec.isEmpty()){
                    
                     
                    Id personAccRTId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(LPI_LiteralConstant.ACCOUNT_PERSON_RECORDTYPE).getRecordTypeId();
                    
                     
                    Id businessAccRTId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(LPI_LiteralConstant.ACCOUNT_BUSINESS_RECORDTYPE).getRecordTypeId();
                    
                     
                    Map<String,Business_Relationships__c> accIdWithReldata = new Map<String,Business_Relationships__c>();
                    for(Business_Relationships__c relData: [SELECT Id, License_Number__c, Ownership_Percent__c, IsActive__c, License_Type__c, 
                                                            Is_the_Owner_a_Business_Entity__c, Is_Licensed_Entity__c, 
                                                            Related_From__c, Related_To__c
                                                            FROM Business_Relationships__c WHERE (Related_From__c =:parRec[0].BusinessAccountNameId OR  Related_To__c=:parRec[0].BusinessAccountNameId) AND
                                                            Roles__c=:LPI_LiteralConstant.ROLE_OWNER AND Start_Date__c != NULL
                                                            AND EndDate__c = NULL  WITH SECURITY_ENFORCED])
                    {
                        if(relData.Is_the_Owner_a_Business_Entity__c == 'Yes'){
                            accIdWithReldata.put(relData.Related_From__c, relData);
                        } else {
                            accIdWithReldata.put(relData.Related_To__c, relData);
                        }
                    }
                     
                    List<Account> accDataToBeUpserted = new List<Account>();
                    
                     
                    Map<String , OwnerInformation> uniqueIdWithOwnerInformation = new Map<String, OwnerInformation>();
                    
                    
                    Map<String , String> personKeyMapping = new Map<String , String>
                    {
                        'personAccountId'=>'Id',
                            'firstName' =>'FirstName',
                            'lastName' =>'LastName',
                            'middleName' =>'MiddleName',
                            'country' =>'PersonOtherCountryCode',
                            'streetAddress1' =>'PersonOtherStreet',
                            'city' =>'PersonOtherCity',
                            'state' =>'PersonOtherStateCode',
                            'stateText' =>'Other_State__c',
                            'zipCode' =>'PersonOtherPostalCode',
                            'county' =>'County__c',
                            'email' =>'PersonEmail',
                            'birthdate' =>'Date_of_Birth__c',
                            'title' =>'PersonTitle',
                            'SSN' =>'Social_Security_Number__c'
                    };
                        
                    
                    Map<String , String> businessKeyMapping = new Map<String , String>
                    {
                        'busienssAccountId'=>'Id',
                            'businessName' =>'Name',
                            'businessEmail' =>'Buisness_Email__c',
                            'busienssPhone' =>'Phone',
                            'streetAddress1' =>'BillingStreet',
                            'city' =>'BillingCity',
                            'state' =>'BillingStateCode',
                            'zipCode' =>'BillingPostalCode',
                            'country' =>'BillingCountryCode',
                            'stateText' =>'Other_State__c',
                            'county' =>'County__c'
                      };
                          
                       
                      for(OwnerInformation ownerData : ownershipInformationData.ownerInformation)
                      {
                          if(ownerData.isBusinessEntityData=='No'){
                               
                              String uniqueKey=ownerData.firstName+ownerData.lastName+ownerData.email;
                              
                              
                              uniqueIdWithOwnerInformation.put(uniqueKey.toUpperCase(),ownerData);
                              
                              
                              Map<String, Object> obj = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(ownerData));
                              
                              Account accToBeUpserted = (Account) LPI_VlocityUtility.createSObject((Map<String, Object>) obj, personKeyMapping, 'Account');
                              
                                  accToBeUpserted.RecordTypeId = personAccRTId;
                              
                              if(String.isEmpty(accToBeUpserted.Id)){
                                  accToBeUpserted.Id=null;
                                  
                                  List<Datacloud.MatchRecord> existingAccountId = new List<Datacloud.MatchRecord>();
                                  existingAccountId = LPI_WithoutSharingUtility.getDuplicateRecords(new List<Account>{accToBeUpserted});   
                                  
                                  if (!existingAccountId.isEmpty()) {
                                      accToBeUpserted.Id = existingAccountId[0].getRecord().Id;
                                  }
                              }                                        
                              
                              accDataToBeUpserted.add(accToBeUpserted);
                          } else if(ownerData.isBusinessEntityData=='Yes') {
                              
                              
                              String uniqueKey = ownerData.businessName + ownerData.busienssPhone;
                              
                              
                              uniqueIdWithOwnerInformation.put(uniqueKey.toUpperCase(),ownerData);
                               
                              Map<String, Object> obj = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(ownerData));
                              
                              Account accToBeUpserted = (Account) LPI_VlocityUtility.createSObject((Map<String, Object>) obj, businessKeyMapping, 'Account');
                                  accToBeUpserted.RecordTypeId = businessAccRTId;
                              
                              if(String.isEmpty(accToBeUpserted.Id)){
                                  accToBeUpserted.Id=null;
                                   
                                  List<Datacloud.MatchRecord> existingAccountId = new List<Datacloud.MatchRecord>();
                                  existingAccountId = LPI_WithoutSharingUtility.getDuplicateRecords(new List<Account>{accToBeUpserted});   
                                  
                                  if (!existingAccountId.isEmpty()) {
                                      accToBeUpserted.Id = existingAccountId[0].getRecord().Id;
                                  }
                              }                                        
                              
                              accDataToBeUpserted.add(accToBeUpserted);
                          }
                      }
                    
                    
                    if(!accDataToBeUpserted.isEmpty()){
                        LPI_WithoutSharingUtility.upsertSObjectList(accDataToBeUpserted);
                    }
                    
                    List<Id> accId = new List<Id>();
                    for(Account acc: accDataToBeUpserted){
                        accId.add(acc.Id);
                    }
                    
                     
                    List<Business_Relationships__c> listOfrelationShipToBeUpserted = new List<Business_Relationships__c>();
                    
                     
                    for(Account accRec : new LPI_AccountDAO.LPI_AccountWithoutSharingDAO().getAccountByDymanicQuery(
                        'Id, FirstName, PersonEmail, PersonBirthdate, Date_of_Birth__c, LastName, RecordType.DeveloperName, Buisness_Email__c, Name,Phone',
                        'ID IN'+LPI_ServiceUtility.getStringValuesByList(accId),
                        null, null, null ))
                    {
                        if(accRec.RecordType.DeveloperName==LPI_LiteralConstant.ACCOUNT_PERSON_RECORDTYPE){
                            
                            Business_Relationships__c relToBeUpserted = new Business_Relationships__c();
                            
                            if(accIdWithReldata.keySet().size()>0 && accIdWithReldata.containsKey(accRec.Id)) {
                                
                                relToBeUpserted.Id= accIdWithReldata.get(accRec.Id).Id;
                            } else {
                                relToBeUpserted.Roles__c = LPI_LiteralConstant.ROLE_OWNER ;
                                relToBeUpserted.Related_To__c = accRec.Id;
                                relToBeUpserted.Related_From__c = parRec[0].BusinessAccountNameId;
                                relToBeUpserted.IsActive__c=false;
                                relToBeUpserted.Start_Date__c = System.today();
                            }
                             
                            String uniqueKey=(accRec.FirstName+accRec.LastName+accRec.PersonEmail).toUpperCase();
                            
                             
                            if(uniqueIdWithOwnerInformation.containsKey(uniqueKey)) {
                                relToBeUpserted.Ownership_Percent__c = (Decimal) uniqueIdWithOwnerInformation.get(uniqueKey).ownershipPercent;
                                relToBeUpserted.License_Number__c = (String) uniqueIdWithOwnerInformation.get(uniqueKey).licenseNumber;
                                relToBeUpserted.Is_the_Owner_a_Business_Entity__c = (String) uniqueIdWithOwnerInformation.get(uniqueKey).isBusinessEntityData;
                                relToBeUpserted.Is_Licensed_Entity__c = (String) uniqueIdWithOwnerInformation.get(uniqueKey).isTheOwnerLicensedInMO;
                                relToBeUpserted.Related_To_License_Number__c= String.isNotEmpty((String) uniqueIdWithOwnerInformation.get(uniqueKey).businessLicenseId)? (String) uniqueIdWithOwnerInformation.get(uniqueKey).businessLicenseId:null;
                            }
                            listOfrelationShipToBeUpserted.add(relToBeUpserted);
                        } else if(accRec.RecordType.DeveloperName==LPI_LiteralConstant.ACCOUNT_BUSINESS_RECORDTYPE){
                             
                            Business_Relationships__c relToBeUpserted = new Business_Relationships__c();
                            
                            if(accIdWithReldata.keySet().size()>0 && accIdWithReldata.containsKey(accRec.Id)) {
                               
                                relToBeUpserted.Id= accIdWithReldata.get(accRec.Id).Id;
                            } else {
                                relToBeUpserted.Roles__c = LPI_LiteralConstant.ROLE_OWNER ;
                                relToBeUpserted.Related_From__c= accRec.Id;
                                relToBeUpserted.Related_To__c = parRec[0].BusinessAccountNameId;
                                relToBeUpserted.IsActive__c=false;
                                relToBeUpserted.Start_Date__c = System.today();
                            }
                            
                            String uniqueKey=(accRec.Name+accRec.Phone).toUpperCase();
                            
                            if(uniqueIdWithOwnerInformation.containsKey(uniqueKey)) {
                                relToBeUpserted.Ownership_Percent__c = (Decimal) uniqueIdWithOwnerInformation.get(uniqueKey).ownershipPercent;
                                relToBeUpserted.License_Number__c = (String) uniqueIdWithOwnerInformation.get(uniqueKey).licenseNumber;
                                relToBeUpserted.Is_the_Owner_a_Business_Entity__c = (String) uniqueIdWithOwnerInformation.get(uniqueKey).isBusinessEntityData;
                                relToBeUpserted.Is_Licensed_Entity__c = (String) uniqueIdWithOwnerInformation.get(uniqueKey).isTheOwnerLicensedInMO;
                                relToBeUpserted.Related_From_License_Number__c= String.isNotEmpty((String) uniqueIdWithOwnerInformation.get(uniqueKey).businessLicenseId)? (String) uniqueIdWithOwnerInformation.get(uniqueKey).businessLicenseId:null;
                            }
                            listOfrelationShipToBeUpserted.add(relToBeUpserted);
                        }
                    }
                    if(!listOfrelationShipToBeUpserted.isEmpty()) {
                        
                       
                        listOfrelationShipToBeUpserted =  (List<Business_Relationships__c>) LPI_WithoutSharingUtility.upsertSObjectRecord(listOfrelationShipToBeUpserted).getRecords();
                        String brIds= '';
                        for (Business_Relationships__c brData : listOfrelationShipToBeUpserted) {
                            brIds+=brData.Id+',';
                        }
                        if(String.isNotEmpty(brIds))
                        LPI_DML.doUpdate(new PreliminaryApplicationRef(Id=parRec[0].Id ,Related_Owner_Ids__c=brIds.removeEnd(',')));

                    }
                }
            }
        }catch(Exception e){
            LPI_ExceptionManager.logException(CLASS_NAME, 'saveOwnerShipnformation', e);
            throw new AuraHandledException(e.getMessage() + e.getLineNumber());
        }
    }
    /**
    * @author         MTX Group Product Team
    * @description     Method is used to delete ACR record.
    * @param           inputMap : contains relationship record Id and PAR Id
    */
    private void deleteRelationShipData(Map<String,Object> inputMap){
        try{
             
            String relationShipId = (String) inputMap.get('relationShipId');
            
            if(String.isNotEmpty(relationShipId)){
                LPI_WithoutSharingUtility.deleteSObject(new Business_Relationships__c(Id =relationShipId));
            }
        }catch(Exception e){
            LPI_ExceptionManager.logException(CLASS_NAME, 'deleteRelationShipData', e);
            throw new AuraHandledException(e.getMessage() + e.getLineNumber());
        }
    }
    /** 
    * @description Method is used to fetch the Ownership information on the search of license number.
    * @param inputMap 
    * @return  `List<Map<String, String>>`
    */
    private static List<Map<String, Object>> getOwnershipDetailsByLicense(Map<String,Object> inputMap) {
        
        List<Map<String, Object>> ownershipDeatilsMap = new List<Map<String, Object>>();
        try{
            
            Set<String> locIds = new Set<String>();
            String searchblock = '%' + (String) inputMap.get('searchKey') + '%';
            String licnesetype = (String) inputMap.get('licneseType');

            List<BusinessLicense> businessLicenses = new LPI_BusinessLicenseDAO.LPI_BusinessLicenseWithoutSharingDAO().getBusinessLicenseByDymanicQuery('Id, Name, Account.Name, Account.Phone, Account.Buisness_Email__c,Account.BillingStreet,License_Number_With_Rat_Name__c, Account.BillingCountryCode, Account.BillingCity,  Account.BillingStateCode, Account.BillingPostalCode , Account.County__c,AccountId, Account.Other_State__c, Account.FirstName, Account.LastName, Account.MiddleName,Account.PersonOtherCity,Account.PersonOtherStateCode,Account.PersonOtherPostalCode,Account.PersonOtherStreet,Account.PersonOtherCountryCode, Account.PersonTitle, Account.PersonBirthdate, Account.Date_of_Birth__c, Account.Social_Security_Number__c, Account.PersonEmail ',
                                                        'Name LIKE  \'%' + searchblock + '%\' AND RegulatoryAuthorizationType.Authorisation_Type__c =\''+licnesetype+'\''
                                                        ,'100', null, null);
            for (BusinessLicense blData : businessLicenses) 
            {        
                Map<String, Object> authInfoMap = new Map<String, Object>();
                if(licnesetype =='Business'){
                    authInfoMap.put('Name', blData.Name);
                    authInfoMap.put('searchedKey', blData.License_Number_With_Rat_Name__c);
                    authInfoMap.put('licenseNumber', blData.Name);
                    authInfoMap.put('Id', blData.Id);
                    
                     
                    authInfoMap.put('businessLicenseId', blData.Id);
                    authInfoMap.put('businessName', blData.Account.Name);
                    authInfoMap.put('businessEmail', blData.Account.Buisness_Email__c);
                    authInfoMap.put('busienssPhone', blData.Account.Phone);
                    authInfoMap.put('busienssAccountId', blData.AccountId);
                    
                    
                    authInfoMap.put('firstName', '');
                    authInfoMap.put('lastName', '');
                    authInfoMap.put('middleName', '');
                    authInfoMap.put('title', '');
                    authInfoMap.put('birthdate', null);
                    authInfoMap.put('ownershipPercent', null);
                    authInfoMap.put('SSN', '');
                    authInfoMap.put('email', '');
                    authInfoMap.put('personAccountId', '');
                    
                    
                    authInfoMap.put('country', blData.Account.BillingCountryCode);
                    authInfoMap.put('streetAddress1', blData.Account.BillingStreet);
                    authInfoMap.put('city', blData.Account.BillingCity);
                    authInfoMap.put('state', blData.Account.BillingStateCode);
                    authInfoMap.put('stateText', blData.Account.Other_State__c);
                    authInfoMap.put('zipCode', blData.Account.BillingPostalCode);
                    authInfoMap.put('county', blData.Account.County__c);
                    authInfoMap.put('isUsState', blData.Account.BillingCountryCode=='US'?true:false);
                    
                } else if(licnesetype =='Individual') {
                    
                    authInfoMap.put('Name', blData.Name);
                    authInfoMap.put('licenseNumber', blData.Name);
                    authInfoMap.put('Id', blData.Id);
                    authInfoMap.put('searchedKey', blData.License_Number_With_Rat_Name__c);

                    
                    authInfoMap.put('businessLicenseId', blData.Id);
                    authInfoMap.put('businessName', '');
                    authInfoMap.put('businessEmail', '');
                    authInfoMap.put('busienssPhone', '');
                    authInfoMap.put('busienssAccountId', '');
                    
                    
                    authInfoMap.put('firstName', blData.Account.FirstName);
                    authInfoMap.put('middleName', blData.Account.MiddleName);
                    authInfoMap.put('lastName', blData.Account.LastName);
                    authInfoMap.put('email', blData.Account.PersonEmail);
                    authInfoMap.put('SSN', blData.Account.Social_Security_Number__c);
                    authInfoMap.put('title', blData.Account.PersonTitle);
                    authInfoMap.put('birthdate',blData.Account.Date_of_Birth__c);
                    authInfoMap.put('ownershipPercent', null);
                    authInfoMap.put('personAccountId', blData.AccountId);
                    
                    
                    authInfoMap.put('country', blData.Account.PersonOtherCountryCode);
                    authInfoMap.put('streetAddress1', blData.Account.PersonOtherStreet);
                    authInfoMap.put('city', blData.Account.PersonOtherCity);
                    authInfoMap.put('state', blData.Account.PersonOtherStateCode);
                    authInfoMap.put('stateText', blData.Account.Other_State__c);
                    authInfoMap.put('zipCode', blData.Account.PersonOtherPostalCode);
                    authInfoMap.put('county', blData.Account.County__c);
                    authInfoMap.put('isUsState', blData.Account.PersonOtherCountryCode=='US'?true:false);
                }
                ownershipDeatilsMap.add(authInfoMap);
            }
        } catch(Exception e) {
            LPI_ExceptionManager.logException(CLASS_NAME, 'getOwnershipDetailsByLicense', e);
            throw new AuraHandledException(e.getMessage() + e.getLineNumber());
        }
        return ownershipDeatilsMap;
    } 
    
    /**
    * @description : Method is used to fetch the picklist values
    * @param inputMap 
    * @return  `List<ComboboxWrapper>`
    */
    private List<ComboboxWrapper> fetchPicklist(Map<String,Object> inputMap){
        
        
        String objectName = (String)inputMap.get('objectName');
        
        
        String fieldName = (String)inputMap.get('fieldName');
        List<ComboboxWrapper> opts = new List<ComboboxWrapper>();
        Schema.SObjectType s = Schema.getGlobalDescribe().get(objectName) ;
        Schema.DescribeSObjectResult r = s.getDescribe() ;
        Map<String,Schema.SObjectField> fields = r.fields.getMap() ;
        Schema.DescribeFieldResult fieldResult = fields.get(fieldName).getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
        for( Schema.PicklistEntry pickListVal : ple){
            ComboboxWrapper wrapper = new ComboboxWrapper();
            wrapper.label = pickListVal.getLabel();
            wrapper.value = pickListVal.getValue();
            opts.add(wrapper);
        }    
        
        return opts;
    }
    
    /**
    * @description : Wrapper Class is used to wrap picklist values.
    */
    public class ComboboxWrapper {
        @AuraEnabled public String label {get;set;}
        @AuraEnabled public String value {get;set;}
        
        public ComboboxWrapper() {
            this.label = '';
            this.value = '';
        }
    }
    
    /**
    * @description : Wrapper Class is used to wrap Ownership Section Information.
    */
    public class OwnershipInformationWrapper {
        @AuraEnabled public List<OwnerInformation> ownerInformation {get;set;}
        @AuraEnabled public List<String> activeSections {get;set;}
        @AuraEnabled public Boolean showAddOwnerShipDetails {get;set;}
        @AuraEnabled public Boolean showAllOwnerShip {get;set;}
        @AuraEnabled public Boolean isCorporateOwnerShipType {get;set;}
        @AuraEnabled public String boardName {get;set;}
        @AuraEnabled public String licenseType {get;set;}
    }
    /**
    * @description : Wrapper Class is used to wrap owner information.
    */
    public class OwnerInformation {
        @AuraEnabled public Integer uniqueId {get;set;}
        @AuraEnabled public Boolean showDelete {get;set;}
        @AuraEnabled public String ownershipInformationTitle {get;set;}
        @AuraEnabled public String isTheOwnerBusinessEntityName {get;set;}
        @AuraEnabled public String isBusinessEntityData {get;set;}
        @AuraEnabled public Boolean isBusinessOwner {get;set;} 
        @AuraEnabled public Boolean isIndividualOwner {get;set;} 
        @AuraEnabled public String isTheBusinessLicensedInMOName {get;set;}
        @AuraEnabled public String isTheOwnerLicensedInMO {get;set;}
        @AuraEnabled public Boolean showOwnerShipSection {get;set;}
        @AuraEnabled public Boolean showLookUpLicense {get;set;}
        @AuraEnabled public String licenseNumber {get;set;}
        @AuraEnabled public Boolean isPartialDisable {get;set;}
        @AuraEnabled public Boolean isPartialRequired {get;set;}
        @AuraEnabled public String businessLicenseId {get;set;}
        
        @AuraEnabled public String businessName {get;set;}
        @AuraEnabled public String businessEmail {get;set;}
        @AuraEnabled public String busienssPhone {get;set;}
        @AuraEnabled public Decimal ownershipPercent {get;set;}
        @AuraEnabled public String businessAccountId {get;set;}
        
        @AuraEnabled public String country {get;set;}
        @AuraEnabled public String streetAddress1 {get;set;}
        @AuraEnabled public String city {get;set;}
        @AuraEnabled public Boolean isUsState {get;set;}
        @AuraEnabled public String state {get;set;}
        @AuraEnabled public String stateText {get;set;}
        @AuraEnabled public String zipCode {get;set;}
        @AuraEnabled public String county {get;set;}
        
        @AuraEnabled public String isTheOwnerLicensedInMOName {get;set;}
        @AuraEnabled public String firstName {get;set;}
        @AuraEnabled public String middleName {get;set;}
        @AuraEnabled public String lastName {get;set;}        
        @AuraEnabled public String email {get;set;}
        @AuraEnabled public String SSN {get;set;}
        @AuraEnabled public String title {get;set;}
        @AuraEnabled public String personAccountId {get;set;}
        @AuraEnabled public String relationShipId {get;set;}
        @AuraEnabled public String stateValue {get;set;}
        @AuraEnabled public String searchedKey {get;set;}
        @AuraEnabled public String countryValue {get;set;}
        @AuraEnabled public Boolean isCorporateOwnerShip {get;set;}
        @AuraEnabled public Boolean isStateMO {get;set;}
        @AuraEnabled public String boardName {get;set;}
        @AuraEnabled public String licenseType {get;set;}
        @AuraEnabled public Date birthdate {get;set;}
    }
}