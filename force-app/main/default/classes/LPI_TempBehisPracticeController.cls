/**
 * @description    : This class  managing the Practice Location Records. It has methods to upsert, fetch and delete records.
 * @author         : MTX Group Product Team
 * -------------------------------------------------------------------------------------------------------
 * Version      Date                Author                  Details
 *    1         29 Mar, 2024        MTX Group Product Team         Initial Developement
 * -------------------------------------------------------------------------------------------------------
 */
global with sharing class LPI_TempBehisPracticeController implements Callable {
    // *************************************** ALL CONSTANTS ************************************************
    private final static String FETCH_PRACTICE_LOCATION = 'fetchPracticeLocation';
    private final static String CLASS_NAME = 'LPI_NURRNWorkExperienceController';
    // ********************************************************************************************************

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
        try {
            if (methodName.equals(FETCH_PRACTICE_LOCATION)) {
                fetchPracticeLocation(inputMap, outMap);
            } 
        } catch (Exception e) {
            LPI_ExceptionManager.logException(CLASS_NAME, 'invokeMethod', e);
        }
        return result;
    }
    /**
     * @description           : This method will call from the invoke method and used to return Practice Location Information to the OS
     * @author                : MTX Group Product Team
     * @param inputMap        : Map of input parameters
     * @param outMap          : Map of output parameters
     * @lastModifiedBy        : Add if modified by you
     * @last modified details : Add if modified by you
     */
    public static void fetchPracticeLocation(
        Map<String, Object> inputMap,
        Map<String, Object> outMap
    ) {
        try {
            String parId = (String) inputMap.get('parId');
            Integer numberOfRecords =0;
            List<Map<String, Object>> responseDataList = new List<Map<String, Object>>();
            if (String.isNotEmpty(parId)) {
                String fieldsToQuery = 'Id,Street_1__c,';
                fieldsToQuery += 'Country__c,City__c,State__c,Zip_Code__c,Title__c,Describe_why__c';
                String whereClause = ' Preliminary_Application_Reference__c= \'' + String.escapeSingleQuotes(parId) + '\'';
                for (
                    Application_Content__c appContent : LPI_ApplicationContentDAO.getApplicationContentByDymanicQuery(
                        fieldsToQuery,
                        whereClause,
                        null,
                        null,
                        null
                    )
                ) {
                        numberOfRecords++;
                        Map<String, Object> responseDataMap = new Map<String, Object>();
                        responseDataMap.put('Id',appContent.Id);
                        responseDataMap.put('StreetAddress',appContent.Street_1__c);
                        responseDataMap.put('Country',appContent.Country__c);
                        responseDataMap.put('City',appContent.City__c);
                        responseDataMap.put('State',appContent.State__c);
                        responseDataMap.put('ZipCode',appContent.Zip_Code__c);
                        responseDataMap.put('DescribeNatureSupervisor',appContent.Describe_why__c);
                        responseDataList.add(responseDataMap);
                }
                if(responseDataList.size()>0){
                    outMap.put('PracticeLocationBlock', responseDataList);
                }
            }
        } catch (Exception e) {
            LPI_ExceptionManager.logException(
                CLASS_NAME,
                FETCH_PRACTICE_LOCATION,
                e
            );
        }
    }
    
}