/**
*
* @author      : Saurabh singh
* @description : This class is used to create and Fetch Regestered Agent and contact Person information for Pharmacy Board -[S-43507]
* @since       : 18 Dec 2022
* @history
* -------------------------------------------------------------------------------------------------------
* Version      Date                Author                  Details
*    1         18 Dec, 2022        Saurabh Singh         Initial Developement
*     2         31 Jan, 2023        Saurabh Singh         Shifting Query in DAO Class
*    3         21 June, 2023       Nitish Gundedi        Updated creatingPersonAccountForRegisteredAgent method to create Relationship Record
* -------------------------------------------------------------------------------------------------------
*/
global with sharing class LPI_CreateRegisteredAgentForPharmacy 
//implements Callable 
{
    public void m1(){}
    // *************************************** ALL CONSTANTS ************************************************
    // public final static String CLASS_NAME = 'LPI_CreateRegisteredAgentForPharmacy';
    // public final static String CREATEING_PERSON_ACCOUNT_FOR_REGISTERED_AGENT = 'creatingPersonAccountForRegisteredAgent';
    // public final static String FETCHING_PERSON_ACCOUNT_FOR_REGISTERED_AGENT = 'fectingPersonAccountForRegisteredAgent';
    // public final static String GET_VIEW_CONTACT_PERSON = 'getViewContactPerson';
    // public final static String INVOKED_METHOD = 'invokeMethod';
    // public final static String ROLE_REGISTERED_AGENT = 'Registered Agent';
    // ******************************************************************************************************
    
    // global Object call(String action, Map<String, Object> args) {
    //     Map<String, Object> input = (Map<String, Object>) args.get('input');
    //     Map<String, Object> output = (Map<String, Object>) args.get('output');
    //     Map<String, Object> options = (Map<String, Object>) args.get('options');
    //     return invokeMethod(action, input, output, options);
    // }
    // /**
    // * @author              : Saurabh Singh
    // * @description         : This method will compare method from Omniscript and execute only that specific method
    // * @param methodName    : Method Name
    // * @param inputMap      : Input Fetching from OS
    // * @param outMap        : Output sending from apex to OS
    // * @param options       : Options Fetching from OS
    // * @return  `Boolean`
    // * @last modified by    : MTX Group Inc
    // * @last modified date  :
    // * @modified details    :
    // */
    // private Boolean invokeMethod(
    // String methodName,
    // Map<String, Object> inputMap,
    // Map<String, Object> outMap,
    // Map<String, Object> options
    // ) {
        // Boolean result = true;
        // try {
        //     if (methodName.equals(CREATEING_PERSON_ACCOUNT_FOR_REGISTERED_AGENT)) {
        //         creatingPersonAccountForRegisteredAgent(inputMap, outMap);
        //     } else if (methodName.equals(FETCHING_PERSON_ACCOUNT_FOR_REGISTERED_AGENT)) {
        //         fectingPersonAccountForRegisteredAgent(inputMap, outMap);
        //     } else if (methodName == GET_VIEW_CONTACT_PERSON) {
        //         outMap.put('contactPersonDetails', getViewContactPerson(inputMap));
        //     }
        // } catch (Exception e) {
        //     LPI_ExceptionManager.logException(CLASS_NAME, INVOKED_METHOD, e);
        //     result = false;
        // }
        // return result;

    //     return null;
    // }
    
    /**
    * @author           : Saurabh singh
    * @since                : 12-18-2022
    * @param inputMap   : Input value passed from OS
    * @param outMap     : Output value passed from here to OS
    * @description      : This method is use to save the details of Registered Agent Details of Drug Distributor license
    * @last modified by    : MTX Group Inc
    * @last modified date  : 30 Jan 2023
    * @modified details    : Added Query in DAO Class
    */
    // public static void creatingPersonAccountForRegisteredAgent(
    // Map<String, Object> inputMap,
    // Map<String, Object> outMap
    // ) {
    //     try {
    //         // Fetching all the input from user
    //         Map<String, object> registeredAgentDetails = (Map<String, object>) inputMap.get('RegisteredAgentDetails');
    //         String company = (String) registeredAgentDetails.get('Company');
    //         String wantToProvideRegisteredAgentDetails = (String) registeredAgentDetails.get('wantToProvideRegisteredAgentDetails');
    //         String registeredAgentType = (String) registeredAgentDetails.get('registeredAgentType');
    //         String registeredAgentRelationId = (String) registeredAgentDetails.get('RegisteredAgentRelationId');
    //         String parId = (String) inputMap.get('parid');
    //         // Person Record Type Id
    //         Id accPersonRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
    //         .get(LPI_LiteralConstant.ACCOUNT_PERSON_RECORDTYPE)
    //         .getRecordTypeId();
    //         // Business Record Type Id
    //         Id accBusinessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
    //         .get(LPI_LiteralConstant.ACCOUNT_BUSINESS_RECORDTYPE)
    //         .getRecordTypeId();
            
    //         if(parId == null )
    //         {
    //             throw new LPI_Exception('Par Id not present');
    //         }
            
    //         String fields = 'BusinessAccountNameId';
    //         String whereClause = 'Id = \'' + String.escapeSingleQuotes(parId) + '\'';
    //         List <PreliminaryApplicationRef> parList = LPI_PreliminaryApplicationRefDAO.getPreliminaryApplicationRefByDymanicQuery(fields, whereClause, null, null, null);
            
    //         PreliminaryApplicationRef par = new PreliminaryApplicationRef();
    //         par.id = parId;
    //         // par.Registered_Agent_Present__c = wantToProvideRegisteredAgentDetails;
    //         //par.Registered_Agent_Type__c = registeredAgentType;
            
    //         // checking whether registered Agent relationship  exit on business account or not
    //         List<Business_Relationships__c> registertedAgentRelationship = LPI_BusinessRelationshipDAO.fetchBusinessRelationshipRecords('Id','Related_From__c = \''+parList[0].BusinessAccountNameId+'\''+' AND Roles__c = \''+ROLE_REGISTERED_AGENT+'\'',null,null,null);
            
    //         if(wantToProvideRegisteredAgentDetails == 'Yes')
    //         {
    //             SObject acc;
    //             Map<String, String> keyMapping;
    //             Account appRefDetails;
    //             if(registeredAgentType == 'Individual')
    //             {
    //                 // Checking if any Duplicate Account Exist in the system then use the same Account else create new one
    //                 keyMapping = new Map<String, String>{
    //                     'FirstName' => 'FirstName',
    //                     'MiddleName' => 'MiddleName',
    //                     'LastName' => 'LastName',
    //                     'StreetAddress1' => 'PersonOtherStreet',
    //                     'State' => 'PersonOtherStateCode',
    //                     'City' => 'PersonOtherCity',
    //                     'Zip' => 'PersonOtherPostalCode'
    //                 };
                    
    //                 appRefDetails = (Account) LPI_VlocityUtility.createSObject(
    //                 registeredAgentDetails,
    //                 keyMapping,
    //                 'Account'
    //                 );
                    
    //                 appRefDetails.put('PersonOtherCountryCode', 'US');
    //                 appRefDetails.put('RecordTypeId', accPersonRecordTypeId);
    //                 appRefDetails.FirstName =  (String.isNotBlank(appRefDetails.FirstName)?appRefDetails.FirstName.trim():appRefDetails.FirstName);
    //                 appRefDetails.MiddleName = (String.isNotBlank(appRefDetails.MiddleName)?appRefDetails.MiddleName.trim():appRefDetails.MiddleName);
    //                 appRefDetails.LastName =   appRefDetails.LastName.trim();
                    
    //                 appRefDetails.Combined_Name__pc = String.isNotBlank(appRefDetails.FirstName) &&
    //                 String.isNotBlank(appRefDetails.MiddleName)
    //                 ? appRefDetails.FirstName + ' ' + appRefDetails.MiddleName + ' ' + appRefDetails.LastName
    //                 : String.isNotBlank(appRefDetails.FirstName)
    //                 ? appRefDetails.FirstName + ' ' + appRefDetails.LastName
    //                 : String.isNotBlank(appRefDetails.MiddleName)
    //                 ? appRefDetails.MiddleName + ' ' + appRefDetails.LastName
    //                 : appRefDetails.LastName;   
    //             }
    //             else if(registeredAgentType == 'Company')
    //             {
    //                 keyMapping = new Map<String, String>{
    //                     'CompanyStreetAddress1' => 'BillingStreet',
    //                     'CompanyState' => 'BillingStateCode',
    //                     'CompanyCity' => 'BillingCity',
    //                     'CompanyZip' => 'BillingPostalCode',
    //                     'Company' => 'Company__c'
    //                 };
                    
    //                 appRefDetails = (Account) LPI_VlocityUtility.createSObject(
    //                 registeredAgentDetails,
    //                 keyMapping,
    //                 'Account'
    //                 );
                    
    //                 appRefDetails.put('BillingCountryCode', 'US');
    //                 appRefDetails.put('Name', company);
    //                 appRefDetails.put('RecordTypeId', accBusinessRecordTypeId);
    //                 appRefDetails.Name =  (String.isNotBlank(appRefDetails.Name)?appRefDetails.Name.trim():appRefDetails.Name);
    //             }
    //             // Checking duplicate Account exist or not
    //             List<Datacloud.MatchRecord> existingAcc = new List<Datacloud.MatchRecord>();
    //             existingAcc = LPI_WithoutSharingUtility.getDuplicateRecords(new List<Account>{ appRefDetails });
                
    //             // SObject acc;
    //             if (existingAcc.isEmpty()) {
    //                 acc = LPI_DML.doInsert(appRefDetails);
    //             } else {
    //                 acc = new Account(
    //                 Id = existingAcc[0].getrecord().Id,
    //                 Company__c = company
    //                 );
    //                 LPI_WithoutSharingUtility.updateSObject(acc); // Here we are updating person account and we cannot give Edit access to account that's why not added LPI_DML Class
    //             }
                
    //             //  Saving Registered Account field of PAR  object and avoiding trigger to execute
    //             if (String.isNotBlank(parId)) {
                    
    //                 Business_Relationships__c relationshipToCreate = new Business_Relationships__c();
    //                 relationshipToCreate.Roles__c = ROLE_REGISTERED_AGENT;
    //                 relationshipToCreate.Related_From__c = parList[0].BusinessAccountNameId;
    //                 relationshipToCreate.Related_To__c = acc.Id;
    //                 relationshipToCreate.Start_Date__c = Date.today();
                    
    //                 List<Business_Relationships__c> duplicates = (List<Business_Relationships__c>) LPI_RelationshipService.findDuplicates(relationshipToCreate);
    //                 if (!duplicates.isEmpty()) {
    //                     relationshipToCreate.Id = duplicates[0].Id;
    //                 }
    //                 // If relationship Id is present then update the relationship with updated details
    //                 if(registeredAgentRelationId != null )
    //                 {
    //                     relationshipToCreate.Id = registeredAgentRelationId;
    //                 }
    //                 else if(!registertedAgentRelationship.isEmpty() && registertedAgentRelationship[0].Id != null)
    //                 {
    //                     relationshipToCreate.Id = registertedAgentRelationship[0].Id;
    //                 }
    //                 Business_Relationships__c br = (Business_Relationships__c) LPI_WithoutSharingUtility.upsertSObject(relationshipToCreate); 
                    
    //                 //par.Registered_Agent_Relation_Id__c = br.Id;                    
    //             }
    //         }
    //         else if(wantToProvideRegisteredAgentDetails == 'No') {
    //             Business_Relationships__c relationShipRecord = new Business_Relationships__c();
    //             if(registeredAgentRelationId != null )
    //             {
    //                 relationShipRecord.Id = registeredAgentRelationId;
    //             }
    //             else if(!registertedAgentRelationship.isEmpty() && registertedAgentRelationship[0].Id != null)
    //             {
    //                 relationShipRecord.Id = registertedAgentRelationship[0].Id;
    //             }
    //             LPI_WithoutSharingUtility.deleteSObject(relationShipRecord);
    //         }
    //         LPI_TriggerHandler.bypass('PreliminaryApplicationTriggerHandler');
    //         if (LPI_TriggerHandler.isBypassed('PreliminaryApplicationTriggerHandler')) {
    //             LPI_DML.doUpdate(par);
    //         }
    //         LPI_TriggerHandler.clearBypass('PreliminaryApplicationTriggerHandler');
            
    //     } catch (Exception e) {
    //         LPI_ExceptionManager.logException(CLASS_NAME, CREATEING_PERSON_ACCOUNT_FOR_REGISTERED_AGENT, e);
    //         throw new LPI_Exception('Problem in Saving Registered Agent', e);
    //     }
    // }
    
    // /**
    // * @author           : Saurabh singh
    // * @since                : 12-18-2022
    // * @param inputMap   : Input value passed from OS
    // * @param outMap     : Output value passed from here to OS
    // * @description      : This method is use to fetch the details of Registered Agent Details of Drug Distributor license
    // * @last modified by    : MTX Group Inc
    // * @last modified date  : 30 Jan 2023
    // * @modified details    : Shifting Query to DAO CLass
    // */
    // public static void fectingPersonAccountForRegisteredAgent(
    // Map<String, Object> inputMap,
    // Map<String, Object> outMap
    // ) {
    //     try {
    //         String parId = (String) inputMap.get('parid');
    //         // Query to fetch all the Details of Registered Agent from PAR
    //         if (parId != null) {
    //             List<PreliminaryApplicationRef> par = LPI_PreliminaryApplicationRefDAO.getPreliminaryApplicationRefByDymanicQuery(
    //             'Id',
    //             'Id = \'' + String.escapeSingleQuotes(parId) + '\'',
    //             null,
    //             null,
    //             null
    //             );
                
                
                
    //         }
    //     } catch (Exception e) {
    //         LPI_ExceptionManager.logException(CLASS_NAME, FETCHING_PERSON_ACCOUNT_FOR_REGISTERED_AGENT, e);
    //         throw new LPI_Exception('Problem in Fetching Registered Agent', e);
    //     }
    // }
    
    // /**
    // * @author                : Saurabh singh
    // * @description       : method is used to Fetch details of Contact person Step details when page reloads
    // * @return                : Map<String, String>
    // * @last modified by     : MTX Group Inc
    // * @last modified date   : 30 Jan 2023
    // * @modified details     : Shifting Query to DAO CLass
    // */
    // public static Map<String, String> getViewContactPerson(Map<String, Object> inputMap) {
    //     Map<String, String> contactPersonDetails = new Map<String, String>();
    //     try {
    //         Id recoId = (String) inputMap.get('parid');
    //         Sobject obj;
    //         // Query to fetch Contact Person field from PAR object so that we can deserialize and use it
    //         List<PreliminaryApplicationRef> parList = LPI_PreliminaryApplicationRefDAO.getPreliminaryApplicationRefByDymanicQuery(
    //         'Id, Contact_Person__c',
    //         'Id = \'' + String.escapeSingleQuotes(recoId) + '\'',
    //         null,
    //         null,
    //         null
    //         );
    //         if (!parList.isEmpty()) {
    //             obj = parList[0];
    //         }
    //         // Deserializing Contact Person Details
    //         if(obj.get('Contact_Person__c') != null){
    //             Map<String, Object> deserialized = (Map<String, Object>) JSON.deserializeUntyped(
    //             String.valueOf(obj.get('Contact_Person__c'))
    //             );
    //             // After Deserializing Map all the value in form of key value pair inside map
    //             for (String values : deserialized.keySet()) {
    //                 contactPersonDetails.put(
    //                 values,
    //                 deserialized.get(values) != null ? String.valueOf(deserialized.get(values)) : null
    //                 );
    //             }
                
    //         }
    //     } catch (Exception e) {
    //         LPI_ExceptionManager.logException(CLASS_NAME, GET_VIEW_CONTACT_PERSON, e);
    //         throw new LPI_Exception('Problem in Fetching Contact Person Details', e);
    //     }
        
    //     return contactPersonDetails;
    // }
}