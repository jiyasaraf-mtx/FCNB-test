/**
 * @author          : MTX Group Product Team
 * @description     : This class is a remote class which is used in flexcard to get the IA/BLA Application number
 * * @history
 * --------------------------------------------------------------------------------------------------------
 * Version      Date                Author                  Details
 *    1        21st March,2023    MTX Group Product Team          Initial Developement
 * -------------------------------------------------------------------------------------------------------
 */
global with sharing class LPI_ApplicationNumber implements Callable {
    /***************************  Constants *************************************/
    private static final String CLASS_NAME = 'LPI_ApplicationNumber';
    private static final String METHOD_GET_APPLICATION_NUMBER = 'getApplicationNumber';
    private static final String METHOD_INVOKE_METHOD = 'invokeMethod';
    private static final String IA_SOBJECT = 'IndividualApplication';
    private static final String BLA_SOBJECT = 'BusinessLicenseApplication';

    /**
     * @author                      : MTX Group Product Team
     * @since                       : 
     * @description                 : This method calls invoke method
     * @param action                : String 
     * @param args			        : Map<String, Object> 
     * @return                      : Object
     * @last modified by            : MTX Group Product Team
     * @last modified date          : 
     * @modified details            : 
     */
    global Object call(String action, Map<String, Object> args) {
        Map<String, Object> input = (Map<String, Object>) args.get('input');
        Map<String, Object> output = (Map<String, Object>) args.get('output');
        Map<String, Object> options = (Map<String, Object>) args.get('options');
        return invokeMethod(action, input, output, options);
    } 
    /**
	 * @description         :   This method invokes methods which are used as remote methods in 
                                LPIApplicationNumber flexcard
	 * @author              :   MTX Group Product Team
	 * @param methodName 	:	String method name
	 * @param inputMap		:	Map<String, Object> input map from OS
	 * @param outMap 		: 	Map<String, Object>
	 * @param options 		:	Map<String, Object>
	 **/
    
    private Boolean invokeMethod(
        String methodName,
        Map<String, Object> inputMap,
        Map<String, Object> outMap,
        Map<String, Object> options
    ) {
        Boolean result = true;
        try 
        {
            if (METHOD_GET_APPLICATION_NUMBER.equalsIgnoreCase(methodName)) {
                getApplicationNumber(inputMap,outMap);
            }
        } 
        catch (Exception e) 
        {
            result = false;
            LPI_ExceptionManager.logException(
                CLASS_NAME,
                METHOD_INVOKE_METHOD,
                e
            );
        }
        return result;
    }
    /**
     * @description    : This method returns the Application Number from the parid
     * @author         : MTX Group Product Team
     * @param inputMap : fetching all the input from Omniscript
     * @param outMap   : Passing value to Omniscript
     **/
    private static void getApplicationNumber(Map<String, Object> inputMap, Map<String, Object> outMap) 
    {
        try
        {
            String  parId = (String) inputMap.get('c__parid');
            //checking if parid is not empty to use in query
            if(String.isNotBlank(parId) && parId != '{Params.c__parid}')
            {
                String whereClause;
                List<PreliminaryApplicationRef> parList = new List<PreliminaryApplicationRef>();
                String parFields = 'Id, Old_Application_Id__c ';
                whereClause =  'Id = \'' + String.escapeSingleQuotes(parId) + '\'';
                parList =
                LPI_PreliminaryApplicationRefDAO.getPreliminaryApplicationRefByDymanicQuery(parFields,whereClause, null,null,null);
                if(!parList.isEmpty())
                {
                    Id applicationId = parList[0].Old_Application_Id__c;
                    if(String.isNotBlank(applicationId))
                    {
                        String fields = 'Id, Name ';
                        whereClause = 'Id = \'' + String.escapeSingleQuotes(applicationId) + '\'';
                        String objectName = String.valueOf(applicationId.getSObjectType());
                        List<SObject> applicationList;
                        if(objectName == IA_SOBJECT)
                        {
                            applicationList =  
                             LPI_IndividualApplicationDAO.getIndividualApplicationByDymanicQuery(fields,whereClause,null,null,null);
                        }
                        else if(objectName == BLA_SOBJECT)
                        {
                           applicationList = 
                            LPI_BusinessLicenseApplicationDAO.getBusinessLicenseApplicationByDymanicQuery(fields,whereClause, null,null,null);
                        }
                        if(!applicationList.isEmpty())
                        {
                            outMap.put('applicationNumber', applicationList[0].get('Name'));
                        }    
                    }
                }
            }
        }
        catch (Exception e) 
        {
            LPI_ExceptionManager.logException(
                CLASS_NAME,
                METHOD_GET_APPLICATION_NUMBER,
                e
            );
        } 
    }
}