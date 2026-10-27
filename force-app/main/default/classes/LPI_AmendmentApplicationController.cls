/**
 * @author                      : Kriti Gupta
 * @since                       : 17 Jan, 2023
 * @description                 : This class contains methods to perform update/fetch/remove operations on Licenses.
 * @last modified by            : Uzma Md
 * @last modified date          : 14th Feb 2023
 * @last modified details       : Code Review Fixes added String.escapeSingleQuotes in where clause queries
 */
global with sharing class LPI_AmendmentApplicationController implements Callable{
    
    // private static final String LICENSE_DETAILS_TO_BE_REMOVED = 'getLicenseeDetailsToBeRemoved';
    // private static final String UPDATE_LICENSE_NAME = 'updateBusinessLicenseName';
    private static final String FETCH_LICENSE_REMOVAL = 'fetchLicenseeRemovalDetails';
    //private static final String RS_BROKERAGE_LICENSE_NUMBER = 'RSBrokerageLicenseNumber';
    private static final String INDIVIDAULICENSE_APPTYPE = 'Individual';
    private static final String BUSINESSLICENSE_STATUS_ACTIVE = 'Active';
    private final static String ACCOUNT_PERSON_RECORDTYPE = 'PersonAccount';
    private final static String RS_BROKERAGE_LICENSE_INFO = 'LicenseInformation';
    private final static String RS_BROKERAGE_AMEND_TYPEAHEAD = 'RSBrokerageAmendmentTypeAhead';


    /**
     * @author                      : Vamsi Mudaliar
     * @since                       : 03 Oct 2022
     * @description                 : Used to internally call invokeMethod. 
     * @param action 
     * @param args 
	 * @return                      : `Object`
     * @last modified by            : Uzma Md
     * @last modified date          : 14 Feb 2023
     * @modified details            : Code Review Fixes
   */
	global Object call(String action, Map<String, Object> args) {
		Map<String, Object> input = (Map<String, Object>) args.get('input');
		Map<String, Object> output = (Map<String, Object>) args.get('output');
		Map<String, Object> options = (Map<String, Object>) args.get('options');
		return invokeMethod(action, input, output, options);
	}

    /**
     * @author                      : Vamsi Mudaliar
     * @since                       : 03 Oct 2022
     * @description                 : Used to call the respective method based on the methodName passed.
     * @param action 
     * @param args 
	 * @return                      : `Object`
     * @last modified by            : Uzma Md
     * @last modified date          : 14 Feb 2023
     * @modified details            : Code Review Fixes
   */
    private Boolean invokeMethod(String methodName, Map<String, Object> inputMap, Map<String, Object> outMap, Map<String, Object> options) {
        Boolean result = true;
        try {
            // if (methodName.equals(LICENSE_DETAILS_TO_BE_REMOVED)) {
            //     outMap.put('licensedetails', getLicenseeDetailsToBeRemoved(inputMap, outMap));
            // }
            // else if(methodName.equals(UPDATE_LICENSE_NAME)){
            //     updateBusinessLicenseName(inputMap,outMap,options);
            // }
            // else 
            if (methodName.equals(FETCH_LICENSE_REMOVAL)) {
                fetchLicenseeRemovalDetails(inputMap, outMap);
            }
            else {
                result = false;
            }
        }catch (Exception ex) {
            result = false;
            LPI_ExceptionManager.logException('LPI_AmendmentApplicationController', 'invokeMethod', ex);

        }
        return result;
    }
    /**
     * @author                      : Kriti Gupta
     * @since                       : 03 Oct 2022
     * @description                 : fetch license details that are to be removed
     * @param inputMap              : fetching all the input from Omniscript
     * @param outMap                : Passing value to Omniscript
	 * @return                      : `List<Map<String,String>>`
     * @last modified by            : Uzma Md
     * @last modified date          : 14 Feb 2023
     * @modified details            : Code Review Fixes
   */
    // public static List<Map<String, String>> getLicenseeDetailsToBeRemoved(Map<String, Object> inputMap, Map<String, Object> outMap) {
    //     try{
    //         Id parId = (Id)inputMap.get('parid');
    //         if(parId==null) {
    //             return null;
    //         }
    //         List<Map<String, String>> licenseeDeatilsMap = new List<Map<String, String>>();
    //         Map<String, BusinessLicense> businessLicenseToIdMap = new Map<String, BusinessLicense>();
    //         // Querying BusinessAccountNameId from PAR.
    //         List<PreliminaryApplicationRef> parRecordList = LPI_PreliminaryApplicationRefDAO.getPreliminaryApplicationRefByDymanicQuery(
    //             'Id, BusinessAccountNameId',
    //             'Id=\''+parId+'\' AND BusinessAccountNameId!=NULL',
    //             '1',
    //             null,null);
    //         if(parRecordList.isEmpty()) {
    //             return null;
    //         }
    //         // getting Business Account id from pAR 
    //         Set<Id> linkedAccountsWithBusiness = new Set<Id>();
    //         // fetching acr Record's accountIds.
    //         LPI_BusinessRelationshipDAO.LPI_BusinessRelationshipsWithoutSharingDAO acrquery = new LPI_BusinessRelationshipDAO.LPI_BusinessRelationshipsWithoutSharingDAO();
    //         for(Business_Relationships__c acr : acrquery.getBusinessRelationshipsByDymanicQuery(
    //             'Id,Related_From__c, Related_To__c',
    //             'Related_From__c = \''+parRecordList[0]?.BusinessAccountNameId+'\'',
    //             null,null,null)){             
    //             linkedAccountsWithBusiness.add(acr.Related_To__c);
    //         }
    //         if(linkedAccountsWithBusiness.isEmpty()) {
    //             return null;
    //         }
    //         // querying license record with the given businessAccountId and Person Account Record Type.
    //         String search = '%' + (String) inputMap.get(RS_BROKERAGE_AMEND_TYPEAHEAD) + '%';
            
    //         if(search==null || search?.length()<=5) {
    //             return null;
    //         }
    //         String licenseQueryFields = 'Id,Name, RegulatoryAuthorizationType.Name, First_Name__c ,Last_Name__c ,Middle_Name__c, License_Number_With_Rat_Name__c';
    //         String licenseWhereClause = 'Name LIKE \''+ String.escapeSingleQuotes(search) +'\''+ 
    //                                     ' AND AccountId IN '+LPI_ServiceUtility.getStringValuesBySet(linkedAccountsWithBusiness) + 
    //                                     ' AND RegulatoryAuthorizationType.Authorisation_Type__c= \''+INDIVIDAULICENSE_APPTYPE+'\'' +
    //                                     ' AND Status = \''+BUSINESSLICENSE_STATUS_ACTIVE+'\''+
    //                                     ' AND Account.RecordType.DeveloperName = \''+ACCOUNT_PERSON_RECORDTYPE +'\'';
    //         for(BusinessLicense bl : LPI_BusinessLicenseDAO.fetchBusinessLicenseRecords(licenseQueryFields,licenseWhereClause)){
    //             businessLicenseToIdMap.put(bl.Id,bl);
    //         }
    //         // Querying License Records and populating fields. 
    //         for(String licenseRecordId : businessLicenseToIdMap.keySet()){
    //             Map<String, String> licenseeInfoMap = new Map<String, String>();
    //             licenseeInfoMap.put('Id',businessLicenseToIdMap.get(licenseRecordId).Id);
    //             licenseeInfoMap.put('RSBrokerageLicenseNumber',businessLicenseToIdMap.get(licenseRecordId).License_Number_With_Rat_Name__c);
    //             licenseeInfoMap.put('RSBrokerageLicenseeName',businessLicenseToIdMap.get(licenseRecordId).First_Name__c);
    //             licenseeInfoMap.put('RSBrokerageLicenseeMiddleName',businessLicenseToIdMap.get(licenseRecordId).Middle_Name__c);
    //             licenseeInfoMap.put('RSBrokerageLicenseeLastName',businessLicenseToIdMap.get(licenseRecordId).Last_Name__c);
    //             licenseeInfoMap.put('RSBrokerageLicenseType',businessLicenseToIdMap.get(licenseRecordId).RegulatoryAuthorizationType.Name);
    //             licenseeInfoMap.put('Name',businessLicenseToIdMap.get(licenseRecordId).Name);
    //             licenseeDeatilsMap.add(licenseeInfoMap);
    //         }
    //         return licenseeDeatilsMap;
    //     }
    //     catch(Exception ex) {
    //         LPI_ExceptionManager.logException('LPI_AmendmentApplicationController', 'getLicenseeDetailsToBeRemoved', ex);
    //     }
    //     return null;
    // }

    /**
     * @author                      : Kriti Gupta
     * @since                       : 03 Oct 2022
     * @description                 : save license to be removed in PAR record
     * @param inputMap              : fetching all the input from Omniscript
     * @param outMap                : Passing value to Omniscript
	 * @return                      : `void`
     * @last modified by            : Uzma Md
     * @last modified date          : 14 Feb 2023
     * @modified details            : Code Review Fixes
   */
    // public static void updateBusinessLicenseName(Map<String, Object> inputMap, Map<String, Object> outMap , Map<String, Object> options){
    //     try {
    //         String parId = (String)inputMap.get('parid');
    //         if(parId==null) {
    //             return;
    //         }
    //         Map<String, object> licenseInfo = (Map<String, object>) inputMap.get(RS_BROKERAGE_LICENSE_INFO);
    //         // getting the type ahead block elements 
    //         if(licenseInfo!=null && !licenseInfo.isEmpty()){
    //             Map<String, object> licenseBlockInfo = (Map<String, object>) licenseInfo.get(RS_BROKERAGE_AMEND_TYPEAHEAD+'-Block');
    //             // getting license number element from type ahead block elements map.
    //             if(licenseBlockInfo!=null && !licenseBlockInfo.isEmpty()){
    //                 String licenseNum = (String)licenseBlockInfo.get('Name');
    //                 // updating PAR with new New_Designated_in_charge_License_Number__c if any
    //                 if(String.isNotBlank(licenseNum)){
    //                     PreliminaryApplicationRef par = new PreliminaryApplicationRef(
    //                     Id = parId,
    //                     New_Designated_in_charge_License_Number__c = licenseNum    
    //                 );
    //                 LPI_DML.doUpdate(par);
    //                 }
    //             }
    //         }
    //     }
    //     catch(Exception ex) {
    //         LPI_ExceptionManager.logException('LPI_AmendmentApplicationController', 'updateBusinessLicenseName', ex);
    //     }
    // }

    /**
         * @author                      : Kriti Gupta
         * @since                       : 03 Oct 2022
         * @description                 : display license details to be removed
         * @param inputMap  : fetching all the input from Omniscript
         * @param outMap    : Passing value to Omniscript
         * @return                      : `void`
         * @last modified by            : Uzma Md
         * @last modified date          : 14 Feb 2023
         * @modified details            : Code Review Fixes
     */
    public static void fetchLicenseeRemovalDetails(Map<String, Object> inputMap, Map<String, Object> outMap){
        try {
            Id parId = (Id)inputMap.get('parid');
            if(parId==null) {
                return;
            }
            // fetching New_Designated_in_charge_License_Number__c from PAR. 
            List<PreliminaryApplicationRef> parList = LPI_PreliminaryApplicationRefDAO.getPreliminaryApplicationRefByDymanicQuery(
                'Id, New_Designated_in_charge_License_Number__c',
                'Id=\''+parId+'\'',
                '1',
                null,null);
            if(parList.isEmpty()) {
                return;
            }
            // querying License Records with given New_Designated_in_charge_License_Number__c
            if((String.isNotEmpty((String) parList[0].New_Designated_in_charge_License_Number__c))){
                List<BusinessLicense> licenseRecord = LPI_BusinessLicenseDAO.fetchBusinessLicenseRecords(
                    'Id, First_Name__c, Last_Name__c, Middle_Name__c, Name, RegulatoryAuthorizationType.Name, License_Number_With_Rat_Name__c',
                    'Name=\''+parList[0].New_Designated_in_charge_License_Number__c+'\''
                );
                if(licenseRecord!=null && !licenseRecord.isEmpty()){
                    outMap.put('RSBrokerageAmendmentTypeAhead',licenseRecord[0].License_Number_With_Rat_Name__c);
                    outMap.put('RSBrokerageLicenseeName',licenseRecord[0].First_Name__c);
                    outMap.put('RSBrokerageLicenseeLastName',licenseRecord[0].Last_Name__c);
                    outMap.put('RSBrokerageLicenseeMiddleName',licenseRecord[0].Middle_Name__c);
                    outMap.put('RSBrokerageLicenseType',licenseRecord[0].RegulatoryAuthorizationType.Name);
                    outMap.put('Name',licenseRecord[0].Name);
                }
            }
        } catch(Exception ex) {
            LPI_ExceptionManager.logException('LPI_AmendmentApplicationController', 'fetchLicenseeRemovalDetails', ex);
        }
    }
}