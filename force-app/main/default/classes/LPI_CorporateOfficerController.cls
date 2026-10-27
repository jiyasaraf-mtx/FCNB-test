/**
 * @author      : MTX Group Product Team
 * @since       : 15th Jun, 2023, 12:36 AM
 * @description : This class LPI_CorporateOfficerController implements the Callable interface and contains the invokeMethod() method
 *                 which is used to call the respective action methods based on the methodName passed as argument. - S-49484
 */
global with sharing class LPI_CorporateOfficerController implements Callable {
    private static final String CLASS_NAME = 'LPI_CorporateOfficerController';
    private static final String SATELLITE_CLASSROOM = 'Satellite Classroom';
    private final static String INDIVIDAULICENSE_APPTYPE = 'Individual';
	private final static String ACCOUNT_PERSON_RECORDTYPE = 'PersonAccount';


    global Object call(String action, Map<String, Object> args) {
        Map<String, Object> input = (Map<String, Object>) args.get('input');
        Map<String, Object> output = (Map<String, Object>) args.get('output');
        Map<String, Object> options = (Map<String, Object>) args.get('options');
        return invokeMethod(action, input, output, options);
    }

    private Boolean invokeMethod(
        String methodName,
        Map<String, Object> inputMap,
        Map<String, Object> outMap,
        Map<String, Object> options
    ) {
        Boolean result = true;
        switch on methodName {
            when 'extractCorporateOfficers' {
                extractCorporateOfficers(inputMap, outMap);
            }
            when 'upsertCorporateOfficers' {
                    upsertCorporateOfficers(inputMap, outMap);
            }
            when 'deleteCorporateOfficers' {
                deleteCorporateOfficers(inputMap, outMap);
            }
        }
        return result;
    }
    /**
     * @description       This method will call from the invoke method and used to return Alias records
     * @author           :  MTX Group Product Team
     * @param inputMap   : Map of input parameters
     * @param outMap     : Map of output parameters
     * @return  List<Map<String,Object>>
     */
    public static void extractCorporateOfficers(Map<String, Object> inputMap, Map<String, Object> outMap ) {
        try{
            Set<String> corporatorsRoleList = new Set<String>{'Board Director','CEO','Chairperson','Corporate Officer','Director','Partner','President','Secretary','Senior Vice President','Shareholder','Treasurer','Vice President','Operating Manager','Manager','Principal','CFO (Chief Financial Officer)','Executive Vice President','Controlling Person','COO'};
            String parId = inputMap.containsKey('parid')? (String) inputMap.get('parid'): null;
            if (parId != null) {
                List<PreliminaryApplicationRef> parList = LPI_PreliminaryApplicationRefDAO.getPreliminaryApplicationRefByDymanicQuery(
                                                            'Id,  Amendment_Type__c , BusinessAccountNameId, BusinessAccountName.ParentId, BusinessAccountName.Entity_type__c, Regulatory_Authorization_Type__r.Name, How_are_you_associated_to_this_entity__c, Board_Name__c',
                                                            'Id = \'' + String.escapeSingleQuotes(parId) + '\'',null,null,null);
                if (!parList.isEmpty()) {
                    outMap.put('CO_HowAreYouAssociated',parList[0].How_are_you_associated_to_this_entity__c);
                    String queryBusinessAccountId  = '';
                    String queryParentBusinessAccountId  = '';
                        queryBusinessAccountId = parList[0].BusinessAccountNameId;
                        queryParentBusinessAccountId  = parList[0].BusinessAccountName.ParentId;
                        outMap.put('COStep_ValidateCoroporateOfficer', String.isNotEmpty(parList[0].BusinessAccountName.Entity_type__c) && 
                        System.Label.OwnershipTypeWhichRequiresCorporators.contains(parList[0].BusinessAccountName.Entity_type__c));
                    outMap.put('COStep_ShowCorporateOfficerStep', parList[0].Amendment_Type__c != 'Adding a Co-Owner' 
                                                                && (parList[0].Amendment_Type__c != 'Reinstatement' 
                                                                || parList[0].Board_Name__c != 'Cosmetology & Barber Examiners') ? true : false);
                    List<Map<String, Object>> corporatorInformationList = new List<Map<String, Object>>();
                    String accountId = String.isNotEmpty(queryParentBusinessAccountId) ? queryParentBusinessAccountId: queryBusinessAccountId; 

                    String businessRelationShipWhereClouse ='Related_From__c =\''+accountId +'\' AND Start_Date__c != NULL AND EndDate__c = NULL AND Roles__c IN  ' +LPI_ServiceUtility.getStringValuesByStringSet(corporatorsRoleList);
                    List<Business_Relationships__c> relDataList = new LPI_BusinessRelationshipDAO.LPI_BusinessRelationshipsWithoutSharingDAO().getBusinessRelationshipsByDymanicQuery(
                        'Id, License_Number__c, Ownership_Percent__c, IsActive__c, License_Type__c,  Is_the_Owner_a_Business_Entity__c, Is_Licensed_Entity__c, Roles__c, Related_From__c, Related_To__c, Related_To__r.PersonEmail, Related_To__r.FirstName, Related_To__r.LastName, Related_To__r.MiddleName, Related_To__r.PersonMailingCity, Related_To__r.PersonMailingState, Related_To__r.PersonMailingPostalCode, Related_To__r.PersonMailingStreet, Related_To__r.PersonMailingCountry, Related_To__r.Other_State__c, Related_To__r.County__c,  Related_To__r.Social_Security_Number__c, Related_To__r.Date_of_Birth__c,Related_To__r.PersonOtherCountry,Related_To__r.PersonOtherStreet,Related_To__r.PersonOtherCity,Related_To__r.PersonOtherState,Related_To__r.PersonOtherPostalCode',
                        businessRelationShipWhereClouse,
                        null,null,null
                    );
					
                    for(Business_Relationships__c relData: relDataList)
                    {
                        Map<String, Object> corporatorInformation = new Map<String,Object>();
                        corporatorInformation.put('LicenseNumber',relData.License_Number__c);
                        corporatorInformation.put('FullName',relData.Related_To__r.FirstName +' '+ (String.isNotEmpty(relData.Related_To__r.MiddleName) ? relData.Related_To__r.MiddleName+' ' :'') + relData.Related_To__r.LastName);
                        corporatorInformation.put('FullAddress',relData.Related_To__r.PersonMailingStreet+', '+relData.Related_To__r.PersonMailingCity+', '+(relData.Related_To__r.PersonMailingCountry =='United States'?relData.Related_To__r.PersonMailingState:relData.Related_To__r.Other_State__c)+', '+ relData.Related_To__r.PersonMailingCountry+', '+relData.Related_To__r.PersonMailingPostalCode+(String.isNotEmpty(relData.Related_To__r.County__c)?', '+relData.Related_To__r.County__c:''));
                        corporatorInformation.put('CO_Role',relData.Roles__c);
                        corporatorInformation.put('RelId',relData.Id);
                        corporatorInformation.put('AccId',relData.Related_To__c);
                        corporatorInformation.put('CO_FirstName',relData.Related_To__r.FirstName);
                        corporatorInformation.put('CO_MiddleName',relData.Related_To__r.MiddleName);
                        corporatorInformation.put('CO_LastName',relData.Related_To__r.LastName);
                        corporatorInformation.put('CO_Email',relData.Related_To__r.PersonEmail);
                        corporatorInformation.put('CO_SSN',relData.Related_To__r.Social_Security_Number__c);
                        corporatorInformation.put('CO_DOB',relData.Related_To__r.Date_of_Birth__c);
                        corporatorInformation.put('CO_Country',relData.Related_To__r.PersonOtherCountry);
                        corporatorInformation.put('StreetAddress',relData.Related_To__r.PersonOtherStreet);
                        corporatorInformation.put('CO_City',relData.Related_To__r.PersonOtherCity);
                        corporatorInformation.put('CO_State',relData.Related_To__r.PersonOtherState);
                        corporatorInformation.put('CO_StateText',relData.Related_To__r.Other_State__c);
                        corporatorInformation.put('CO_ZipCodeUS',relData.Related_To__r.PersonOtherPostalCode);
                        corporatorInformation.put('CO_ZipCode',relData.Related_To__r.PersonOtherPostalCode);
                        corporatorInformation.put('CO_County',relData.Related_To__r.County__c);
                        corporatorInformation.put('CODLicensedOrNot',relData.Is_Licensed_Entity__c);
                        if(parList[0].How_are_you_associated_to_this_entity__c == 'Temporary Clerk'
                            && relData.Related_To__r.Social_Security_Number__c != NULL
                            && LPI_WithoutSharingUtility.isPortalUser()){
                            corporatorInformation.put('CO_SSNReview','•••••••••'); 
                        }else{
                            corporatorInformation.put('CO_SSNReview',relData.Related_To__r.Social_Security_Number__c);
                        }
                        corporatorInformation.put('CO_SSNForTempClerk',relData.Related_To__r.Social_Security_Number__c);
                        corporatorInformationList.add(corporatorInformation);
                    }
                    if(corporatorInformationList.size()>0){
                        outMap.put('Co_CorporateOfficerDataEB',corporatorInformationList);
                    }
                }
            }
        }catch(Exception e){
            LPI_ExceptionManager.logException(CLASS_NAME, 'extractCorporateOfficers', e);
        }
    }
    /**
     * @description       This method will call from the invoke method and used to upsert Corporate Officer records
     * @author           :  MTX Group Product Team
     * @param inputMap   : Map of input parameters
     * @param outMap     : Map of output parameters
     * @return  List<Map<String,Object>>
     */
    public static void upsertCorporateOfficers(Map<String, Object> inputMap, Map<String, Object> outMap ) {
       try{
            List<Datacloud.MatchRecord> existingAccountList = new List<Datacloud.MatchRecord>();
            Account accRec = new Account();
            accRec.Id = (String) inputMap.get('AccId')  ;                       
            accRec.FirstName = (String) inputMap.get('CO_FirstName');  
            accRec.MiddleName = (String) inputMap.get('CO_MiddleName');  
            accRec.LastName = (String) inputMap.get('CO_LastName');  
            accRec.PersonEmail = (String) inputMap.get('CO_Email');  
            accRec.Social_Security_Number__c = inputMap.get('CO_SSN') != NULL ? (String) inputMap.get('CO_SSN') : (String) inputMap.get('CO_SSNForTempClerk');  
            accRec.Date_of_Birth__c = String.isNotBlank((String) inputMap.get('CO_DOB'))? Date.valueOf((String) inputMap.get('CO_DOB')): null;
            accRec.PersonMailingCountry = (String) inputMap.get('CO_Country');  
            accRec.PersonMailingStreet = (String) inputMap.get('StreetAddress');  
            accRec.PersonMailingCity = (String) inputMap.get('CO_City');  
            accRec.PersonMailingState = (String) inputMap.get('CO_State');  
            accRec.Other_State__c = (String) inputMap.get('CO_StateText');  
            accRec.PersonMailingPostalCode = (String) inputMap.get('CO_Country')=='United States'? (String) inputMap.get('CO_ZipCodeUS'): (String) inputMap.get('CO_ZipCode');  
            accRec.County__c = (String) inputMap.get('CO_County');  

            accRec.Combined_Name__pc = String.isNotBlank(accRec.FirstName) && String.isNotBlank(accRec.MiddleName) ?
                accRec.FirstName + ' ' + accRec.MiddleName + ' ' + accRec.LastName :
            String.isNotBlank(accRec.FirstName) ?
                accRec.FirstName + ' ' + accRec.LastName :
            String.isNotBlank(accRec.MiddleName) ?
                accRec.MiddleName + ' ' + accRec.LastName :
            accRec.LastName;
            
            accRec.recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(ACCOUNT_PERSON_RECORDTYPE).getRecordTypeId();
	        existingAccountList = LPI_WithoutSharingUtility.getDuplicateRecordsService(new List<Account>{ accRec });
            if (!existingAccountList.isEmpty()) {
                accRec.Id =  existingAccountList[0].getRecord().Id;
            }
            accRec = (Account) LPI_WithoutSharingUtility.upsertSObject(accRec);
            outMap.put('AccId', accRec.Id);

            String parId = inputMap.containsKey('parRecId')? (String) inputMap.get('parRecId'): null;
            List<PreliminaryApplicationRef> parList = LPI_PreliminaryApplicationRefDAO.getPreliminaryApplicationRefByDymanicQuery(
                'Id,  Amendment_Type__c , BusinessAccountNameId, BusinessAccountName.ParentId, BusinessAccountName.Entity_type__c ',
                'Id = \'' + String.escapeSingleQuotes(parId) + '\'',
                null,
                null,
                null
            );
            if (!parList.isEmpty()) {
                String relatedFromAccId = String.isNotEmpty(parList[0].BusinessAccountName.ParentId) ? parList[0].BusinessAccountName.ParentId: parList[0].BusinessAccountNameId; 
                Business_Relationships__c relData = new Business_Relationships__c();
                relData.Id = (String)  inputMap.get('RelId');  
                relData.Roles__c = (String)  inputMap.get('CO_Role');
                relData.Related_To__c =   accRec.Id;
                relData.Related_From__c = relatedFromAccId;
                relData.Start_Date__c = System.today();
                relData.IsActive__c = true;
                relData = (Business_Relationships__c)  LPI_WithoutSharingUtility.upsertSObject(relData);
                outMap.put('RelId', relData.Id);

                
            }
        }catch(Exception e){
            LPI_ExceptionManager.logException(CLASS_NAME, 'upsertCorporateOfficers', e);
        }
    }
    /**
     * @description       This method will call from the invoke method and used to return Alias records
     * @author           :  MTX Group Product Team
     * @param inputMap   : Map of input parameters
     * @param outMap     : Map of output parameters
     * @return  List<Map<String,Object>>
     */
    public static void deleteCorporateOfficers(Map<String, Object> inputMap, Map<String, Object> outMap ) {
        try{
            String relationShipId = (String) inputMap.get('RelId');
            
            if(String.isNotEmpty(relationShipId)){
                String businessRelationShipWhereClouse ='Id =\''+relationShipId +'\'';
                List<Business_Relationships__c> relDataList = new LPI_BusinessRelationshipDAO.LPI_BusinessRelationshipsWithoutSharingDAO().getBusinessRelationshipsByDymanicQuery(
                    'Id, Related_From__c, Related_To__c',
                    businessRelationShipWhereClouse,
                    null,null,null
                );
                
                If(relDataList.size()>0 && LPI_AccountDAO.getAccountByIDs(new Set<String>{relDataList[0].Related_From__c}).size()>0){
                    LPI_WithoutSharingUtility.deleteSObject(new Business_Relationships__c(Id =relationShipId));
                }
            }
        }catch(Exception e){
            LPI_ExceptionManager.logException(CLASS_NAME, 'deleteCorporateOfficers', e);
        }
    }

}