/**
* @author      : Piyush Aneja
* @since       : 2023-01-05
* @description : This class is responsible for managing the licensure information of a user in other states.
*                It implements the VlocityOpenInterface and has methods to upsert and delete licensure information of a user in other states.
*  -------------------------------------------------------------------------------------------------------
* Version      Date                Author                   Details
*    1         2023-01-05.         Piyush Aneja             Initial Developement - S-44562 - Licensure History Standardized
*    2		   Feb 2023      	   Piyush Aneja	            Shifting Query in DAO Class ,  Added class description, All constant declaration
															Method description and Proper Comments before for loop and if check
*    3							   Kirti Gupta              Changes related to Healing Arts, added ProfessionofLicensure field in mapping 
*    4         22nd Mar 2023       Piyush Aneja             State country changes - United States
* -------------------------------------------------------------------------------------------------------
*/
global with sharing class LPI_LicensureController implements Callable {
    public final static String LICENSE_IN_OTHER_STATES = 'Licensure In Other States';
    public final static String RELATIONSHIP_ID = 'relationshipId';
    //public final static String LICENSED_IN_OTHER_STATE = 'LicensedInOtherState';
    //public final static String IS_YOUR_LICENSE_INFORCE = 'Isyourlicense';
    //public final static String IS_YOUR_LICENSE_ACTIVE_CB = 'isYourLicenseActiveCB';
    public final static String OTHERS = 'Others';
    public final static String CLASS_NAME = 'LPI_LicensureController';
    public final static String FETCH_LICENSURE_HISTORY_READ_ONLY = 'fetchLicensureHistoryReadOnlyInfo';
    public final static String FETCH_COSBAR_LICENSURE_HISTORY_DATA = 'fetchCosBarLicensureHistoryData';

    global Object call(String action, Map < String, Object > args) {
        Map < String, Object > input = (Map < String, Object > ) args.get('input');
        Map < String, Object > output = (Map < String, Object > ) args.get('output');
        Map < String, Object > options = (Map < String, Object > ) args.get('options');
        return invokeMethod(action, input, output, options);
    }

    /**
     * @description       :This method is called by the Vlocity interface to execute a specific method based on the methodName passed in.
     *                     It calls the appropriate method to upsert or delete licensure information.
     * 
     * @author            : Piyush Aneja
     * @lastModifiedBy    : Piyush Aneja
     * @last modified details : Added class description, method description and proper comments before for loop and if check
     * @param methodName  : The name of the method to be executed.
     * @param inputMap    : A map containing input data for the method.
     * @param outMap      : A map to pass output data back to the Vlocity interface.
     * @param options     : A map containing options for the method, if needed.
     * 
     * @return Boolean    : Returns true if the method is successfully executed, else false.
     */
    private Boolean invokeMethod(String methodName, Map < String, Object > inputMap, Map < String, Object > outMap,
        Map < String, Object > options) {
        Boolean result = true;
        try {
            if (methodName.equals('upsertLicensureInOtherStatesInformation')) {
                upsertLicensureInOtherStatesInformation(inputMap, outMap, options);
            } else if (methodName.equals('deleteLicensureInOtherStatesInformation')) {
                deleteLicensureInOtherStatesInformation(inputMap, outMap, options);
            } else if (methodName.equals('fetchLicensureHistoryReadOnlyInfo')) {
                fetchLicensureHistoryReadOnlyInfo(inputMap, outMap);
            }
            // } else if (methodName.equals('fetchCosBarLicensureHistoryData')) {
            //     fetchCosBarLicensureHistoryData(inputMap, outMap);
            // } 
            else {
                result = false;
            }
        } catch (Exception e) {
            LPI_ExceptionManager.logException('LPI_LicensureController', 'invokeMethod', e);
            result = false;
        }
        return result;
    }

    /**
     * @description       :This method is responsible for creating or updating licensure information in other states.
     *                     It takes the input data from the inputMap, creates or updates the Application_Content__c object and passes the Id of the object back in the outMap
     *
     * @author            : Piyush Aneja
     * @lastModifiedBy    : Kriti Gupta
     * @last modified details : added ProfessionofLicensure field in mapping 
     * @param inputMap    : A map containing input data for the method.
     * @param outMap      : A map to pass output data back to the Vlocity interface.
     * @param options     : A map containing options for the method, if needed.
     */

    public static void upsertLicensureInOtherStatesInformation(Map < String, Object > inputMap, Map < String, Object > outMap,
        Map < String, Object > options) {
        try { 
            String parId = (String) inputMap.get('PARID');
            String StateofLicensureSelect = (String) inputMap.get('StateofLicensureSelect');
            String MethodofLicensureAIPI = (String) inputMap.get('MethodofLicensureAIPI');
            Map<String , String> keyMapping = new Map<String , String>{
                    'RecordId'=>'Id',
                    'LicenseNumber'=>'License_Number__c',
                    'LicensureDate'=>'Licensure_Date__c',
                    'ExpirationDate'=>'Expiration_Date__c',
                    'ExpirationDateAllowFutureDate'=>'Expiration_Date__c',
                    'StateofLicensure'=>'State_of_Licensure__c',
                    'MethodofLicensure'=>'Method_of_Licensure__c',
                    'Specify'=>'Specify__c',
                    'Describewhy'=>'Describe_why__c' ,
                    'Licensure In Other States'=>'Section_Header__c',
                    'ProfessionofLicensure'=>'Profession_of_Licensure__c',
                    'CountryofLicensure'=>'Country__c',
                    'IsyourlicenseF'=>'Is_your_license_in_force__c'
            };
            Application_Content__c  appcon = (Application_Content__c) LPI_VlocityUtility.createSObject(inputMap, keyMapping, 'Application_Content__c');
            appcon.Preliminary_Application_Reference__c = parId;
            if (StateofLicensureSelect != null ){
                appcon.State_of_Licensure__c = StateofLicensureSelect; }
            if (MethodofLicensureAIPI != null ){
                appcon.Method_of_Licensure__c = MethodofLicensureAIPI; }
            appcon.Section_Header__c = LICENSE_IN_OTHER_STATES;
            appcon.Copy_To_License_Content__c = true;
            if(inputMap.containsKey(RELATIONSHIP_ID)){
                appcon.Relationship_Id__c = (String) inputMap.get(RELATIONSHIP_ID);
            }
            appcon = (Application_Content__c) LPI_DML.doUpsert(appcon);
            outMap.put('RecordId', appcon.Id);
        } catch (Exception e) {
            LPI_ExceptionManager.logException('LPI_LicensureController', 'upsertLicensureInOtherStatesInformation', e);
        }
    }

    /**
     * @description       :This method is responsible for deleting licensure information in other states.
     * 					   It takes the Id of the object to be deleted from the inputMap and deletes the corresponding Application_Content__c object.
     *
     * @author            : Piyush Aneja
     * @lastModifiedBy    : Piyush Aneja
     * @last modified details : Added class description, method description and proper comments before for loop and if check
     * @param inputMap    : A map containing input data for the method.
     * @param outMap      : A map to pass output data back to the Vlocity interface.
     * @param options     : A map containing options for the method, if needed.
     */

    public static void deleteLicensureInOtherStatesInformation(Map < String, Object > inputMap, Map < String, Object > outMap, Map < String, Object > options) {
        try {
            if(inputMap.containsKey('Id')){
                List<Application_Content__c> appContentList = LPI_ApplicationContentDAO.getApplicationContentByDymanicQuery(
                        'Id', ' Id =\'' + (String)inputMap.get('RecordId') + '\'', null, null, null
                );
                if (!appContentList.isEmpty()) {
                    LPI_WithoutSharingUtility.deleteSObject(appContentList);
                }
            }
        }catch (Exception e) {
            LPI_ExceptionManager.logException('LPI_LicensureController', 'deleteLicensureInOtherStatesInformation', e);
        }
    }


    /**
	 * @author               : Ayush Yadav
	 * @description          : This method will call from the invoke method and used to return Licensure History [License_Content__c] Date from Contact
	 * @param  inputMap      : data we are fetching from the Vlocity component
	 * @param outMap         : Passing output Data
	 * @last modified by     : MTX Group Inc
	 * @last modified date   : 10 June, 2023
	 * @modified details     :
	 */
    public static void fetchLicensureHistoryReadOnlyInfo(Map<String, Object> inputMap, Map<String, Object> outMap) {
		try {
			String parId = (String) inputMap.get('parId');
			String fields = 'Id,Business_License__c,Business_License__r.Hold_Active_License__c,Is_Supervisor_User__c,'+
            ' Regulatory_Authorization_Type__r.Name,Type__c';
			String parWhereClause = 'Id = \'' + String.escapeSingleQuotes(parId) + '\'';
            
			List<PreliminaryApplicationRef> parList = LPI_PreliminaryApplicationRefDAO.getPreliminaryApplicationRefByDymanicQuery(
			    fields,
			    parWhereClause,
			    null,
			    null,
			    null
			);

            // String approvalSupervisorIds;
            // if(parList[0].Type__c != 'New' && String.isBlank(parList[0].Approval_Supervisors_AcrIds__c)){
            //     approvalSupervisorIds = parList[0].Business_License__r.Approval_Supervisors_AcrIds__c;
            // } else {
            //     approvalSupervisorIds = parList[0].Approval_Supervisors_AcrIds__c;
            // }

            if(!parList.isEmpty() && String.isNotBlank(parList[0].Business_License__c)){
                String stringToQuery = 'Id,License_Number__c,Licensure_Date__c,Expiration_Date__c,State_of_Licensure__c,Method_of_Licensure__c,' +
                'Is_your_license_in_force__c,Specify__c,Describe_why__c,Profession_of_Licensure__c,Country__c';
                String whereClause = 'Business_License__c = \'' + String.escapeSingleQuotes(parList[0].Business_License__c) + '\' AND Section_Header__c = \''+ LICENSE_IN_OTHER_STATES +'\'';
                String sortingByFields = 'Name';
                List<Map<String, Object>> licensureHistoryDataList = new List<Map<String, Object>>();
                List<License_Content__c> lcList = new List<License_Content__c>();
                if (parList[0].Is_Supervisor_User__c) {
                    lcList = new LPI_LicenseContentDAO.LPI_LicenseContentWithoutSharingDAO().getLicenseContentByDymanicQuery(
                            stringToQuery,
                            whereClause,
                            null,
                            null,
                            null
                    );
                } else {
                    lcList = LPI_LicenseContentDAO.getLicenseContentByDymanicQuery(
                            stringToQuery,
                            whereClause,
                            null,
                            null,
                            null
                    );
                }
                if(!lcList.isEmpty()){
                    for (License_Content__c lc : lcList) {
                        Map<String, Object> responseDataMap = new Map<String, Object>();
                        responseDataMap.put('LicenseNumber', lc.License_Number__c);
                        responseDataMap.put('LicensureDate', lc.Licensure_Date__c);
                        responseDataMap.put('ExpirationDate', lc.Expiration_Date__c);
                        responseDataMap.put('ExpirationDateAllowFutureDate', lc.Expiration_Date__c);
                        responseDataMap.put('StateofLicensure', lc.State_of_Licensure__c);
                        responseDataMap.put('MethodofLicensure', lc.Method_of_Licensure__c);
                        responseDataMap.put('Isyourlicense', lc.Is_your_license_in_force__c);
                        responseDataMap.put('isYourLicenseActiveCB', lc.Is_your_license_in_force__c);
                        if(lc.Method_of_Licensure__c == OTHERS){
                            responseDataMap.put('Specify', lc.Specify__c);
                        }
                        if(lc.Is_your_license_in_force__c == LPI_LiteralConstant.MODPR_NO){
                            responseDataMap.put('Describewhy', lc.Describe_why__c);
                        }
                        responseDataMap.put('ProfessionofLicensure', lc.Profession_of_Licensure__c);
                        responseDataMap.put('CountryofLicensure', lc.Country__c);
                        licensureHistoryDataList.add(responseDataMap);
                    }
                }
                outMap.put('licensureHistoryDataList', licensureHistoryDataList);
                outMap.put('holdActiveLicense', parList[0].Business_License__r.Hold_Active_License__c);
                //outMap.put('inwhichstate', parList[0].Business_License__r.What_state__c);
                outMap.put('regAuthTypeName', parList[0].Regulatory_Authorization_Type__r.Name);
            }
		} catch (Exception e) {
            LPI_ExceptionManager.logException(CLASS_NAME, FETCH_LICENSURE_HISTORY_READ_ONLY, e);
        }
	}

    /**
	 * @author               : Ayush Yadav
	 * @description          : This method will call from the invoke method and used to return Cosbar Owner/Applicant Licensure History [Application_Content__c] Date
	 * @param  inputMap      : data we are fetching from the Vlocity component
	 * @param outMap         : Passing output Data
	 * @last modified by     : MTX Group Inc
	 * @last modified date   : 10 June, 2023
	 * @modified details     :
	 */
    // public static void fetchCosBarLicensureHistoryData(Map<String, Object> inputMap, Map<String, Object> outMap) {
	// 	try {
	// 		String parId = (String) inputMap.get('parId');
    //         if(String.isNotBlank(parId)){
    //             String relationshipId;
    //             if(inputMap.containsKey(RELATIONSHIP_ID)){
    //                 relationshipId = (String) inputMap.get(RELATIONSHIP_ID);
    //             }

    //             String stringToQuery = 'Id,License_Number__c,Licensure_Date__c,Expiration_Date__c,State_of_Licensure__c,Method_of_Licensure__c,' +
    //                 'Is_your_license_in_force__c,Specify__c,Describe_why__c,Profession_of_Licensure__c,Country__c';
    //             String whereClause = 'Preliminary_Application_Reference__c = \'' + String.escapeSingleQuotes(parId) + '\' AND Section_Header__c = \''+ LICENSE_IN_OTHER_STATES +'\'';
    //             if(String.isNotBlank(relationshipId) && relationshipId != 'null'){
    //                 whereClause = whereClause + ' AND Relationship_Id__c = \'' + String.escapeSingleQuotes(relationshipId) + '\'';
    //             }else if (relationshipId == 'null'){
    //                 whereClause = whereClause + 'AND Relationship_Id__c = null';
    //             }
    //             List<Map<String, Object>> licensureHistoryDataList = new List<Map<String, Object>>();
    //             List<Application_Content__c> acList = new List<Application_Content__c>();

    //             acList = LPI_ApplicationContentDAO.getApplicationContentByDymanicQuery(
    //                     stringToQuery,
    //                     whereClause,
    //                     null,
    //                     null,
    //                     null
    //             );
                
    //             if(!acList.isEmpty()){
    //                 for (Application_Content__c lc : acList) {
    //                     Map<String, Object> responseDataMap = new Map<String, Object>();
    //                     responseDataMap.put('Id', lc.Id);
    //                     responseDataMap.put('LicenseNumber', lc.License_Number__c);
    //                     responseDataMap.put('LicensureDate', lc.Licensure_Date__c);
    //                     responseDataMap.put('ExpirationDate', lc.Expiration_Date__c);
    //                     responseDataMap.put('ExpirationDateAllowFutureDate', lc.Expiration_Date__c);
    //                     responseDataMap.put('StateofLicensure', lc.State_of_Licensure__c);
    //                     responseDataMap.put('MethodofLicensure', lc.Method_of_Licensure__c);
    //                     responseDataMap.put('IsyourlicenseF', lc.Is_your_license_in_force__c);
    //                     if(lc.Method_of_Licensure__c == OTHERS){
    //                         responseDataMap.put('Specify', lc.Specify__c);
    //                     }
    //                     if(lc.Is_your_license_in_force__c == LPI_LiteralConstant.MODPR_NO){
    //                         responseDataMap.put('Describewhy', lc.Describe_why__c);
    //                     }
    //                     responseDataMap.put('ProfessionofLicensure', lc.Profession_of_Licensure__c);
    //                     responseDataMap.put('CountryofLicensure', lc.Country__c);
    //                     licensureHistoryDataList.add(responseDataMap);
    //                 }
    //             }
    //             if(!licensureHistoryDataList.isEmpty()){
    //                 outMap.put('LicensureHistoryEditBlock', licensureHistoryDataList);
    //             }
    //         }   
	// 	} catch (Exception e) {
    //         LPI_ExceptionManager.logException(CLASS_NAME, FETCH_COSBAR_LICENSURE_HISTORY_DATA, e);
    //     }
	// }
}