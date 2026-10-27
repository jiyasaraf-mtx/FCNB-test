/**
*
* @author          : Mahesh Reddy Chinthakunta
* @Description     : This class will Save UnLicensed Current Employment Information
* @history
* -------------------------------------------------------------------------------------------------------
* Version      Date                Author                            Details
*    1         03 Mar, 2023        Mahesh Reddy Chinthakunta         Developement
* -------------------------------------------------------------------------------------------------------
*/
global with sharing class LPI_UnLicensedCurrentEmpInfo 
                        //implements Callable
                        {
                public void method1(){
                }
    // *************************************** ALL CONSTANTS ************************************************
//     private final static String SAVE_UNLICENSED_CURRENT_EMP_INFO = 'saveUnLicensedCurrentEmpInfo';
//     private final static String INSERT_ACCOUNT_CONTACT_RECORD = 'insertAccountContactRecord';
//     private final static String OBJECT_ACCOUNT = 'Account';
//     private final static String CREATE_ACR_RECORD = 'createACRRecord';
//     private final static String CLASS_NAME = 'LPI_UnLicensedCurrentEmpInfo';
//     private final static String INVOKE_METHOD = 'invokeMethod';
//     private final static String ACCOUNTCONTACTOBJECT = 'AccountContactRelation';
//     private final static String FETCH_UNLICENSED_CURRENT_EMP_INFO_READONLY = 'fetchUnLicensedEmpInfoReadOnly';
//     private final static String ACR_ROLE_EMPLOYEE = 'Employee';
//     private final static String UNITED_STATES = 'United States';
//     private final static String US = 'US';
//     private final static String OBJECT_EMPLOYMENT_HISTORY = 'PersonEmployment';
//     private final static String CREATE_EMPLOYMENT_HISTORY_RECORD = 'createEmploymentHistory';
//     private final static Map<String,String> keyMappingAcc = new Map<String,String>{
//         'LPIULCEIName' => 'Name',
//         'LPIULCEIPhone' => 'Phone',
//         'LPIULCEIStreetAddress' =>'BillingStreet',
//         'LPIULCEICity' => 'BillingCity',
//         'LPIULCEIZipcode' => 'BillingPostalCode',
//         'LPIULCEICounty' => 'County__c',
//         'LPIULCEICountry' => 'BillingCountryCode',
//         'LPIULCEIEmail' => 'Buisness_Email__c',
//         'Firmpermitnumber' => 'Firm_permit_number__c'
//         };
//     private final static Map<String,String> keyMappingEmpHis = new Map<String,String>{
//         'LPIULCEIName' => 'Name',
//         'LPIULCEIPhone' => 'EmployerPhone',
//         'LPIULCEIStreetAddress' =>'EmployerStreet',
//         'LPIULCEICity' => 'EmployerCity',
//         'LPIULCEIZipcode' => 'EmployerPostalCode',
//         // 'LPIULCEICounty' => 'County__c',
//         'LPIULCEIEmail' => 'Current_Employer_Email__c',
//         'LPIULCEIPersonInChargeEmailAddress' => 'Supervisor_Email__c',
//         'LPIULCEIPersonInChargeName' => 'Immediate_Supervisor_s_Name__c',
//         'LPIULCEIEmploymentStartDate' => 'StartDate',
//         'LPIULCEIEmploymentType' => 'Type_of_Employment__c',
//         'LPIULCEIJobTitle' => 'Position'
//     };
//     // ******************************************************************************************************
   
//     /**
//      * @author                      : Mahesh Reddy Chinthakunta
//      * @since                       :
//      * @description                 : This method calls invoke method
//      * @param action                : String
//      * @param args                  : Map<String, Object>
//      * @return                      : Object
//      * @last modified by            : MTX Group Inc
//      * @last modified date          :
//      * @modified details            :
//     */
//     global Object call(String action, Map<String, Object> args) {
//         Map<String, Object> input = (Map<String, Object>) args.get('input');
//         Map<String, Object> output = (Map<String, Object>) args.get('output');
//         Map<String, Object> options = (Map<String, Object>) args.get('options');
//         return invokeMethod(action, input, output, options);
//     }
 
 
//    /**
//     * @author                      : Mahesh Reddy Chinthakunta
//     * @since                       : 03 Mar 2023
//     * @description                 : This method will compare method from Omniscript and execute only that specific method
//     * @param methodName            : String
//     * @param inputMap              : Map<String, Object>
//     * @param outMap                : Map<String, Object>
//     * @param options               : Map<String, Object>
//     * @return                      : `Boolean`
//     * @last modified by            : MTX Group Inc
//     * @last modified date          :
//     * @modified details            :
//    */
//     private Boolean invokeMethod(String methodName, Map<String, Object> inputMap, Map<String, Object> outMap, Map<String, Object> options) {
//         Boolean result = true;
//         try {
//             // if (SAVE_UNLICENSED_CURRENT_EMP_INFO.equals(methodName)) {
//             //     saveUnLicensedCurrentEmpInfo(inputMap,outMap);
//             // } else if(FETCH_UNLICENSED_CURRENT_EMP_INFO_READONLY.equals(methodName)){
//             //     fetchUnLicensedEmpInfoReadOnly(inputMap,outMap);
//             // }
//         } catch (Exception e) {
//             LPI_ExceptionManager.logException(CLASS_NAME, INVOKE_METHOD, e);
//             result = false;
//         }
//         return result;
//     }
//     /**
//      * @author                      : Mahesh Reddy Chinthakunta
//      * @since                       : 03 Mar 2023
//      * @description                 : This method will create Business Account and AccountContactRelation record with role Employee
//      * @param inputMap              : Map<String, Object>
//      * @return                      : `void`
//      * @last modified by            : MTX Group Inc
//      * @last modified date          :
//      * @modified details            :
//     */
//     // private static void saveUnLicensedCurrentEmpInfo(Map<String, Object> inputMap, Map<String, Object> outMap){
//     //     try{
//     //         String parId = (String) inputMap.get('parId');
//     //         String parQueryFields = 'Id, Name, BusinessAccountNameId, Employment_History_Ids__c, Contact__r.AccountId, Are_you_currently_Employed__c, Regulatory_Authorization_Type__r.IssuingDepartment.Name';
//     //         String parWhereClause='';
//     //         List<PreliminaryApplicationRef> par;
//     //         if(!String.isEmpty(parId)){
//     //             parWhereClause += 'Id = \'' + String.escapeSingleQuotes(parId) + '\'';
//     //             par = LPI_PreliminaryApplicationRefDAO.getPreliminaryApplicationRefByDymanicQuery(parQueryFields,parWhereClause,null,null,null);
//     //         }
//     //         if(par.isEmpty()){
//     //             return;
//     //         }
//     //         String accId = (String) inputMap.get('accId');
//     //         String brIdDelete = (String) inputMap.get('brIdYes');
//     //         String brIdUpdate = (String) inputMap.get('brIdNo') != null ? (String) inputMap.get('brIdNo') : null;
//     //         Map<String, object> currentEmpInfo = (Map<String, object>) inputMap.get('SalesPersonDesignatedBroker');
//     //         Map<String, object> currentEmpInfoUnLicensedBlock = (Map<String, object>) currentEmpInfo.get('LPIULCEIEmployerUnLicensed');
//     //         Map<String, object> acrValueMap = new Map<String, object>();
//     //         acrValueMap.put('empType', currentEmpInfoUnLicensedBlock.get('LPIULCEIEmploymentType') != null ? currentEmpInfoUnLicensedBlock.get('LPIULCEIEmploymentType') : '');
//     //         acrValueMap.put('empDate', currentEmpInfoUnLicensedBlock.get('LPIULCEIEmploymentStartDate') != null ? currentEmpInfoUnLicensedBlock.get('LPIULCEIEmploymentStartDate') : null);
//     //         acrValueMap.put('jobTitle', currentEmpInfoUnLicensedBlock.get('LPIULCEIJobTitle') != null ? currentEmpInfoUnLicensedBlock.get('LPIULCEIJobTitle') : '');
//     //         acrValueMap.put('businessRelationShipId', brIdUpdate);
//     //         if(US.equalsIgnoreCase(String.valueOf(currentEmpInfoUnLicensedBlock.get('LPIULCEICountry')))){
//     //             keyMappingAcc.put('LPIULCEIState', 'BillingStateCode');
//     //             currentEmpInfoUnLicensedBlock.put('LPIULCEICountry', 'US');
//     //         }else {
//     //             keyMappingAcc.put('LPIULCEIStateText', 'Other_State__c');
//     //         }
//     //         if(String.isNotBlank(brIdDelete)){
//     //             Business_Relationships__c relationshipRec = new Business_Relationships__c(Id = brIdDelete);
//     //             String accConQueryFieldsDel = 'Id';
//     //             String accConWhereClauseFieldsDel = 'Id = \''+String.escapeSingleQuotes(brIdDelete) + '\'' + ' AND IsActive__c = false AND EndDate__c = null';
//     //             List<Business_Relationships__c> brListDel = LPI_BusinessRelationshipDAO.fetchBusinessRelationshipRecords(accConQueryFieldsDel, accConWhereClauseFieldsDel);
//     //             if(!brListDel.isEmpty()){
//     //                 LPI_WithoutSharingUtility.deleteSObject(brListDel); // For Portal user there is no option to give permission for deleting Acr    
//     //             }
//     //             outMap.put('brIdYes', '');
//     //         }     
//     //         Account businessAccDetails = (Account) LPI_VlocityUtility.createSObject(
//     //             currentEmpInfoUnLicensedBlock,
//     //             keyMappingAcc,
//     //             OBJECT_ACCOUNT
//     //         );
//     //         Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
//     //             .get(LPI_LiteralConstant.NON_MO_LICENSE_ACCOUNT_RECORDTYPE)
//     //             .getRecordTypeId();
//     //         businessAccDetails.put('RecordTypeId', accRecordTypeId);
//     //         List<Datacloud.MatchRecord> existingAccountId = new List<Datacloud.MatchRecord>();
//     //         existingAccountId = LPI_WithoutSharingUtility.getDuplicateRecordsService(
//     //             new List<Account>{ businessAccDetails });
//     //         if (!existingAccountId.isEmpty()) {
//     //             businessAccDetails.Id = existingAccountId[0].getRecord().Id;
//     //             LPI_WithoutSharingUtility.updateSObjectRecord(businessAccDetails);
//     //         } else{
//     //             if(accId != null){
//     //                 businessAccDetails.Id = accId;
//     //             }
//     //             businessAccDetails = (Account) LPI_WithoutSharingUtility.upsertSObject(businessAccDetails);
//     //         }
//     //         accId = businessAccDetails.Id;
//     //         List<Account> accList = LPI_AccountDAO.getAccountByIDs(new Set<String> {accId});
//     //         String brId = createACRRecord(accId, par, acrValueMap);
//     //         if(accList!=null && !accList.isEmpty()){
//     //             if(String.isNotEmpty(accList[0].BillingCountry)){
//     //                 currentEmpInfoUnLicensedBlock.put('LPIULCEICountryEmp', accList[0].BillingCountry);
//     //                 keyMappingEmpHis.put('LPIULCEICountryEmp','EmployerCountry');
//     //             }
//     //             if(UNITED_STATES.equalsIgnoreCase((String) currentEmpInfoUnLicensedBlock.get('LPIULCEICountryEmp')) && String.isNotEmpty(accList[0].BillingState)){
//     //                 currentEmpInfoUnLicensedBlock.put('LPIULCEIStateEmp', accList[0].BillingState);
//     //                 keyMappingEmpHis.put('LPIULCEIStateEmp','EmployerState');
//     //             } else if(String.isNotEmpty(accList[0].Other_State__c)){
//     //                 currentEmpInfoUnLicensedBlock.put('LPIULCEIStateEmpText', accList[0].Other_State__c);
//     //                 keyMappingEmpHis.put('LPIULCEIStateEmpText','EmployerState');
//     //             }
//     //         }
//     //         PersonEmployment empHistory = createEmploymentHistory(currentEmpInfoUnLicensedBlock, keyMappingEmpHis, par);
//     //         PreliminaryApplicationRef updatePar = new PreliminaryApplicationRef();
//     //         updatePar.Id = parId;
//     //         updatePar.Entity_License_Number__c = brId;
//     //         updatePar.Employee_Information_ACR_Ids__c = brId;
//     //         LPI_DML.doUpdate(updatePar);
//     //         outMap.put('accId', accId);
//     //         outMap.put('brIdNo', brId);
//     //     } catch(exception e){
//     //             LPI_ExceptionManager.logException(
//     //             CLASS_NAME,
//     //             SAVE_UNLICENSED_CURRENT_EMP_INFO,
//     //             e
//     //         );
//     //     }
//     // }
//     /**
//      * @author                      : Mahesh Reddy Chinthakunta
//      * @since                       : 03 Mar 2023
//      * @description                 : This method will insert Account Contact Relation record
//      * @param accountId             : String
//      * @param contactId             : String
//      * @param acrValueMap           : Map<String, object>
//      * @return                      : `String`
//      * @last modified by            : MTX Group Inc
//      * @last modified date          : 07 Jun 2023
//      * @modified details            :
//     */
//     public static String createACRRecord(String accountId, List<PreliminaryApplicationRef> par, Map<String, object> acrValueMap){
//         String acrId='';
//         try{
//             if(String.isEmpty(accountId) || String.isEmpty(par[0].BusinessAccountNameId)){
//                 return null;
//             }
//             Business_Relationships__c acrToCreate = new Business_Relationships__c();
//             if(String.isNotBlank((String) acrValueMap.get('empDate'))){
//                 acrToCreate.Start_Date__c =  Date.valueOf((String) acrValueMap.get('empDate'));
//             }
//             acrToCreate.Related_From__c = accountId;
//             acrToCreate.Related_To__c = par[0]?.BusinessAccountNameId;
//             acrToCreate.Roles__c = LPI_LiteralConstant.ROLE_EMPLOYEE;
//             List<Business_Relationships__c> acrRecList = LPI_RelationshipService.findDuplicates(
//                     acrToCreate
//             );
//             if(acrRecList.isEmpty()){
//                 acrToCreate.Employment_Type__c = String.valueOf(acrValueMap.get('empType'));
//                 acrToCreate.Job_Title_Position_held__c = String.valueOf(acrValueMap.get('jobTitle'));
//                 acrToCreate.IsActive__c = false;
//                 if(String.isNotBlank((String) acrValueMap.get('businessRelationShipId'))){
//                     acrToCreate.Id = String.valueOf(acrValueMap.get('businessRelationShipId'));
//                     LPI_WithoutSharingUtility.updateSObjectRecord(acrToCreate);  
//                     acrId = String.valueOf(acrValueMap.get('businessRelationShipId'));
//                 } else{
//                     acrId = (String) LPI_WithoutSharingUtility.insertSObjectRecord(
//                         new List<Business_Relationships__c> {acrToCreate}
//                     ).getRecords()[0].Id;
//                 }    
//             } else{
//                 acrId = acrRecList[0].Id;
//                 acrToCreate.Employment_Type__c = String.valueOf(acrValueMap.get('empType'));
//                 acrToCreate.Job_Title_Position_held__c = String.valueOf(acrValueMap.get('jobTitle'));
//                 if(String.isNotBlank((String) acrValueMap.get('businessRelationShipId'))){
//                     acrToCreate.Id = String.valueOf(acrValueMap.get('businessRelationShipId'));
//                     LPI_WithoutSharingUtility.updateSObjectRecord(acrToCreate);  
//                     acrId = String.valueOf(acrValueMap.get('businessRelationShipId'));
//                 }
//             }
//             return acrId;
//         }catch(exception e){
//             LPI_ExceptionManager.logException(
//                 CLASS_NAME,
//                 CREATE_ACR_RECORD,
//                 e
//             );
//         }  
//         return acrId;
//     }
//     /**
//      * @author                      : Neeraj Avadhanam
//      * @since                       : 28 Mar 2023
//      * @description                 : This method will fetch the UnLicensed Emp Info for readonly mode
//      * @param inputMap              : Map<String, Object>
//      * @return                      : void
//      * @last modified by            : MTX Group Inc
//      * @last modified date          :
//      * @modified details            :
//     */
// //    private static void fetchUnLicensedEmpInfoReadOnly(Map<String, Object> inputMap, Map<String, Object> outMap){
// //         String parId = (String) inputMap.get('parId');
// //         String parQueryFields = 'Id, Business_License__c, Contact__r.AccountId';
// //         String parWhereClause;
// //         String blWhereClauseFields;
// //         String blQueryFields;
// //         Set<String> accRoleSet = new Set<String>{'Employee'};
// //         List<PreliminaryApplicationRef> parList = new List<PreliminaryApplicationRef>();
// //         List<BusinessLicense> blList = new List<BusinessLicense>();
// //         List<BusinessLicense> emplyeeBlList = new List<BusinessLicense>();
// //         if(String.isNotEmpty(parId)){
// //             parWhereClause = 'Id = \''+String.escapeSingleQuotes(parId)+'\'';
// //             parList = LPI_PreliminaryApplicationRefDAO.getPreliminaryApplicationRefByDymanicQuery(parQueryFields,parWhereClause,null,null,null);
// //         }
// //         if (!parList.isEmpty() && String.isNotEmpty(parList[0].Business_License__c)) {
// //             blQueryFields='Id, Entity_License_Number__c, Are_you_Currently_Employeed__c,AccountId';
// //             blWhereClauseFields ='Id=\''+String.escapeSingleQuotes(parList[0].Business_License__c)+'\'';
// //             blList=new LPI_BusinessLicenseDAO.LPI_BusinessLicenseWithoutSharingDAO().getBusinessLicenseByDymanicQuery(blQueryFields,blWhereClauseFields,null,null,null);
// //             }
// //         if(!blList.isEmpty() && String.isNotEmpty(blList[0].Entity_License_Number__c) 
// //                             && blList[0].Are_you_Currently_Employeed__c == 'Yes'){
// //             if (blList[0].Entity_License_Number__c instanceOf Id) {
// //                 outMap.put('AreYouCurrentlyEmployedRo','Yes');
// //                 outMap.put('LPIULCEIEmployerLicensedRo','No');
// //                 fetchAccConRelForReadOnly(blList[0].Entity_License_Number__c, parList, outMap);
// //             } else {
// //                 String emploeeBlWhereClause = 'Name =\''+blList[0].Entity_License_Number__c+'\'';
// //                 emplyeeBlList=new LPI_BusinessLicenseDAO.LPI_BusinessLicenseWithoutSharingDAO().getBusinessLicenseByDymanicQuery(blQueryFields,emploeeBlWhereClause,null,null,null);
// //                     outMap.put('AreYouCurrentlyEmployedRo','Yes');
// //                     outMap.put('LPIULCEIEmployerLicensedRo','Yes');
// //                     String accConQueryFields='Id, Related_From__c, Related_From__r.Name, Related_From__r.BillingStreet, Related_From__r.BillingCity, Related_From__r.BillingState, Related_From__r.BillingPostalCode, Related_From__r.Phone,Related_To__r.Name,Related_To__r.PersonEmail, Related_From__r.BillingCountry, Related_From__r.County__c, Related_From__r.Buisness_Email__c,Roles__c,Start_Date__c,Employment_Type__c, Job_Title_Position_held__c,  Related_From__r.Other_State__c';
// //                     String accConWhereClauseFields;
// //                     If(!emplyeeBlList.isEmpty() && String.isNotEmpty(emplyeeBlList[0].AccountId)){
// //                         accConWhereClauseFields = 'Related_From__c =\''+String.escapeSingleQuotes(emplyeeBlList[0].AccountId)+'\''
// //                                                 + ' AND Related_To__c = \''+String.escapeSingleQuotes(parList[0].Contact__r.AccountId)+'\''
// //                                                 + 'AND Roles__c =\''+ACR_ROLE_EMPLOYEE+'\'';
// //                     }
// //                     List<Business_Relationships__c> accConRel=
// //                     new LPI_BusinessRelationshipDAO.LPI_BusinessRelationshipsWithoutSharingDAO().getBusinessRelationshipsByDymanicQuery(
// //                         accConQueryFields,accConWhereClauseFields,null,null,null);
// //                     if(!accConRel.isEmpty()){
// //                     outMap.put('EmploymentStartDateRo', accConRel[0].Start_Date__c);
// //                     outMap.put('SalesPersonLicenseNumberRo', blList[0].Entity_License_Number__c);
// //                     outMap.put('SalesPersonNameOfCorporationRo', accConRel[0].Related_From__r.Name);
// //                     outMap.put('SalesPersonStreetAddressRo', accConRel[0].Related_From__r.BillingStreet);
// //                     outMap.put('SalesPersonCityRo', accConRel[0].Related_From__r.BillingCity);
// //                     if(UNITED_STATES.equalsIgnoreCase(accConRel[0].Related_From__r.BillingCountry)){
// //                         outMap.put('SalesPersonStateRo', accConRel[0].Related_From__r.BillingState);
// //                     }else {
// //                         outMap.put('SalesPersonStateRo', accConRel[0].Related_From__r.Other_State__c);
// //                     }
// //                     outMap.put('SalesPersonZipcodeRo', accConRel[0].Related_From__r.BillingPostalCode);
// //                     outMap.put('SalesPersonPhoneRo', accConRel[0].Related_From__r.Phone);
// //                     outMap.put('SalesPersonEmailRo', accConRel[0].Related_From__r.Buisness_Email__c);
// //                     outMap.put('SalesPersonNameOfNewCorporationRo', accConRel[0].Related_From__r.Name);
// //                     outMap.put('SalesPersonCountryRo', accConRel[0].Related_From__r.BillingCountry);
// //                     outMap.put('SalesPersonCountyRo', accConRel[0].Related_From__r.County__c);
// //                     outMap.put('EmploymentTypeRo', accConRel[0].Employment_Type__c);
// //                     outMap.put('EmploymentJobTitleRo', accConRel[0].Job_Title_Position_held__c);
// //                     }
// //                 }
// //             } else{
// //                 outMap.put('AreYouCurrentlyEmployedRo','No');
// //             } 
// //     }      
//     /**
//      * @author                      : Neeraj Avadhanam
//      * @since                       : 28 Mar 2023
//      * @description                 : This method will fetch the AccountContact Relation Details
//      * @param accConId              : account contact Rel Id
//      * @return                      : void
//      * @last modified by            : MTX Group Inc
//      * @last modified date          :
//      * @modified details            :
//     */

//     // private static void fetchAccConRelForReadOnly(String accConId,List<PreliminaryApplicationRef> parList, Map<String, Object> outMap){
//     //     String empFields = 'Id, Supervisor_Email__c, Immediate_Supervisor_s_Name__c';
//     //     String empWhereClause = 'Business_License__c = \'' + String.escapeSingleQuotes(parList[0].Business_License__c) + '\'';
//     //     List<PersonEmployment> empList = new LPI_PersonEmploymentDAO.LPI_EmploymentHistoryWithoutSharingDAO().getEmploymentHistoryByDymanicQuery(empFields,empWhereClause,null,null,null);

//     //     List<Business_Relationships__c> accConList = new List<Business_Relationships__c>();
//     //     List<Account> acc = new List<Account>();
//     //     String accConQueryFields = 'Id, Related_To__c, Related_From__c, Start_Date__c, Employment_Type__c, Job_Title_Position_held__c';
//     //     String accConWhereClauseFields = 'Id =\'' + String.escapeSingleQuotes(accConId) + '\'';
//     //     accConList =new LPI_BusinessRelationshipDAO.LPI_BusinessRelationshipsWithoutSharingDAO().getBusinessRelationshipsByDymanicQuery(accConQueryFields, accConWhereClauseFields, null, null, null);
//     //     if(!accConList.isEmpty()){
//     //         String personAccWhereClauseFields = 'Id =\'' + String.escapeSingleQuotes(accConList[0].Related_From__c) + '\'';
//     //         acc = (new LPI_AccountDAO.LPI_AccountWithoutSharingDAO()).getAccountByDymanicQuery('Id, Name, Phone, BillingStreet, BillingCity, BillingPostalCode, County__c, BillingState, BillingCountry, BillingCountryCode, Other_State__c, BillingStateCode, Buisness_Email__c', personAccWhereClauseFields, null, null, null);
//     //         outMap.put('LPIULCEINameRo', acc[0].Name);
//     //         outMap.put('LPIULCEIStreetAddressRo', acc[0].BillingStreet);
//     //         outMap.put('LPIULCEICityRo', acc[0].BillingCity);
//     //         outMap.put('LPIULCEIZipcodeRo', acc[0].BillingPostalCode);
//     //         if(UNITED_STATES.equalsIgnoreCase(acc[0].BillingCountry)){
//     //             outMap.put('LPIULCEIStateRo', acc[0].BillingStateCode);
//     //             outMap.put('LPIULCEIStateFCRo', acc[0].BillingState);
//     //         } else{
//     //             outMap.put('LPIULCEIStateTextRo', acc[0].Other_State__c);
//     //         }
//     //         outMap.put('LPIULCEIPhoneRo', acc[0].Phone);
//     //         outMap.put('LPIULCEIEmailRo', acc[0].Buisness_Email__c);
//     //         outMap.put('LPIULCEICountyRo', acc[0].County__c);
//     //         outMap.put('LPIULCEICountryRo', acc[0].BillingCountryCode);
//     //         outMap.put('LPIULCEICountryFCRo', acc[0].BillingCountry);
//     //         outMap.put('LPIULCEIEmploymentStartDateRo', accConList[0].Start_Date__c);
//     //         outMap.put('LPIULCEIEmploymentTypeRo', accConList[0].Employment_Type__c);
//     //         outMap.put('LPIULCEIJobTitleRo', accConList[0].Job_Title_Position_held__c);
//     //     }
//     //     if(!empList.isEmpty()){
//     //         outMap.put('LPIULCEIPersonInChargeNameRo', empList[0].Immediate_Supervisor_s_Name__c);
//     //         outMap.put('LPIULCEIPersonInChargeEmailAddressRo', empList[0].Supervisor_Email__c);
//     //     }
//     // }   
//     /**
//      * @author                                  : Mahesh Reddy Chinthakunta
//      * @since                                   : 29 Mar 2023
//      * @description                             : This method will create Employment History Records
//      * @param currentEmpInfoUnLicensedBlock     : Map<String, object>
//      * @param keyMappingEmpHis                  : Map<String, String>
//      * @param personAccountId                   : String
//      * @param par                               : List<PreliminaryApplicationRef>
//      * @return                                  : `PersonEmployment`
//      * @last modified by                        : MTX Group Inc
//      * @last modified date                      : 14 Apr 2023
//      * @modified details                        : Added Duplicate Check for Employment History 
//     */
//     public static PersonEmployment createEmploymentHistory(Map<String, object> currentEmpInfoUnLicensedBlock, Map<String, String> keyMappingEmpHis, List<PreliminaryApplicationRef> par){
//         try{
//             if(par.isEmpty()){
//                 return null;
//             }
//             List<PersonEmployment> empHistoryList = new List<PersonEmployment>();
//             PersonEmployment empHistory = (PersonEmployment) LPI_VlocityUtility.createSObject(
//                 currentEmpInfoUnLicensedBlock,
//                 keyMappingEmpHis,
//                 'PersonEmployment'
//             );
//             empHistory.Preliminary_Application_Reference__c = par[0].Id;
//             String empHisQueryFields = 'Id';
//             String empHisWhereClause = '';
//             empHisWhereClause += 'Name = \'' + String.escapeSingleQuotes(empHistory.Name) + '\'';
//             if(empHistory.Position != null){
//                 empHisWhereClause += 'AND Position = \'' + String.escapeSingleQuotes(empHistory.Position) + '\'';
//             }
//             if(empHistory.StartDate != null){
//                 empHisWhereClause += 'AND StartDate = ' + String.escapeSingleQuotes(String.valueOf(empHistory.StartDate)) + ' ';
//             }
//             if(empHistory.Type_of_Employment__c != null){
//                 empHisWhereClause += 'AND Type_of_Employment__c = \'' + String.escapeSingleQuotes(String.valueOf(empHistory.Type_of_Employment__c)) + '\'';
//             }
//             if(empHistory.Current_Employer_Email__c != null){
//                 empHisWhereClause += 'AND Current_Employer_Email__c = \'' + String.escapeSingleQuotes(String.valueOf(empHistory.Current_Employer_Email__c)) + '\'';
//             }
//             if(empHistory.EmployerStreet != null){
//                 empHisWhereClause += 'AND EmployerStreet = \'' + String.escapeSingleQuotes(empHistory.EmployerStreet) + '\'';
//             }
//             if(empHistory.EmployerCity != null){
//                 empHisWhereClause += 'AND EmployerCity = \'' + String.escapeSingleQuotes(empHistory.EmployerCity) + '\'';
//             }
//             if(empHistory.EmployerCountry != null){
//                 empHisWhereClause += 'AND EmployerCountry = \'' + String.escapeSingleQuotes(empHistory.EmployerCountry) + '\'';
//             }
//             if(empHistory.EmployerState != null){
//                 empHisWhereClause += 'AND EmployerState = \'' + String.escapeSingleQuotes(empHistory.EmployerState) + '\'';              
//             } 
//             if(empHistory.EmployerPostalCode != null){
//                 empHisWhereClause += 'AND EmployerPostalCode = \'' + String.escapeSingleQuotes(empHistory.EmployerPostalCode) + '\'';
//             }
//             // if(empHistory.County__c != null){
//             //     empHisWhereClause += 'AND County__c = \'' + String.escapeSingleQuotes(empHistory.County__c) + '\'';
//             // }
//             if(empHistory.EmployerPhone != null){
//                 empHisWhereClause += 'AND EmployerPhone = \'' + String.escapeSingleQuotes(empHistory.EmployerPhone) + '\'';
//             }
//             if(empHistory.Immediate_Supervisor_s_Name__c != null){
//                 empHisWhereClause += 'AND Immediate_Supervisor_s_Name__c = \'' + String.escapeSingleQuotes(empHistory.Immediate_Supervisor_s_Name__c) + '\'';
//             }
//             if(empHistory.Supervisor_Email__c != null){
//                 empHisWhereClause += 'AND Supervisor_Email__c = \'' + String.escapeSingleQuotes(empHistory.Supervisor_Email__c) + '\'';
//             }
//             if(!String.isEmpty(empHistory.Employer_License_Number__c)){
//                 empHisWhereClause += 'AND Employer_License_Number__c = \'' + String.escapeSingleQuotes(String.valueOf(empHistory.Employer_License_Number__c)) + '\'';
//             }
//             if(!String.isEmpty(empHistory.Current_License_Posted__c)){
//                 empHisWhereClause += 'AND Current_License_Posted__c = \'' + String.escapeSingleQuotes(String.valueOf(empHistory.Current_License_Posted__c)) + '\'';
//             }
//             if(!String.isEmpty(empHistory.Current_License_Posted_Year__c)){
//                 empHisWhereClause += 'AND Current_License_Posted_Year__c = \'' + String.escapeSingleQuotes(String.valueOf(empHistory.Current_License_Posted_Year__c)) + '\'';
//             }
//             List<PersonEmployment> duplicatesList = LPI_PersonEmploymentDAO.getEmploymentHistoryByDymanicQuery(empHisQueryFields, empHisWhereClause, null, null, null);
//             if(!duplicatesList.isEmpty()){
//                 return null;
//             }
//             if(String.isEmpty(empHistory.Employer_License_Number__c)){
//                 empHistory.Employer_License_Number__c = '';
//             }
//             empHistory.RelatedPersonId = par[0]?.Contact__r.AccountId;
//             String empHistoryFields = 'Id';
//             String empWhereClause = 'Preliminary_Application_Reference__c = \'' + String.escapeSingleQuotes(par[0].Id) + '\' AND End_Date__c = null';
//             empHistoryList = LPI_PersonEmploymentDAO.getEmploymentHistoryByDymanicQuery( empHistoryFields, empWhereClause, null, null, null );
//             if (!empHistoryList.isEmpty()) {
//                 empHistory.Id = empHistoryList[0].Id;
//             }
//             if(par[0]?.Are_you_currently_Employed__c == 'No'){
//                 if(empHistory != null){
//                     LPI_WithoutSharingUtility.deleteSObject(empHistory);
//                 } else {
//                     return null;
//                 }
//             } else{
//                 empHistory = (PersonEmployment) LPI_DML.doUpsert(empHistory);
//             }
//             return empHistory;
//         } catch(Exception e){
//             LPI_ExceptionManager.logException(
//                 CLASS_NAME,
//                 CREATE_EMPLOYMENT_HISTORY_RECORD,
//                 e
//             );
//         }
//         return null;
//     }
}