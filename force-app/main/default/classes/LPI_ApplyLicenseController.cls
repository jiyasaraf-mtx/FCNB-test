/**
 * @description : This Class is used to return List of Licenses.
 * @author : MTX Group Product Team
 * @lastModifiedBy : MTX Group Product Team
 * @last modified details : Added class description, method description and proper comments before for loop and if check
 **/
global with sharing class LPI_ApplyLicenseController implements Callable {
    global Object call(String action, Map<String, Object> args) {
        Map<String, Object> input = (Map<String, Object>) args.get(LPI_LiteralConstant.INPUT);
        Map<String, Object> output = (Map<String, Object>) args.get(LPI_LiteralConstant.OUTPUT);
        Map<String, Object> options = (Map<String, Object>) args.get(LPI_LiteralConstant.OPTIONS);
        return invokeMethod(action, input, output, options);
    }

    /**
     * @description :This method is used to invoke methods from a omnistudio components.
     *
     * @author : MTX Group Product Team
     * @lastModifiedBy : MTX Group Product Team
     * @last modified details : Added class description, method description and proper comments before for loop and if check
     * @param methodName : The name of the method to be invoked
     * @param inputMap : Input data used by the method
     * @param outMap : Output data returned by the method
     * @param options : Additional options for the method
     *
     * @return Boolean - returns true if the method was invoked successfully
     **/
    private static Boolean invokeMethod(
        String methodName,
        Map<String, Object> inputMap,
        Map<String, Object> outMap,
        Map<String, Object> options
    ) {
        Boolean result = false;
        try {
            // Check if methodName is equal to 'fetchRecords'
            if (methodName == 'fetchRecords') {
                // Get the category, userId, sorting, selectOption, and boardName from the inputMap
                String category = (String) inputMap.get('category');
                String userId = (String) inputMap.get('userId');
                String sorting = (String) inputMap.get('sorting');
                String selectOption = (String) inputMap.get('selectedOption');
                String boardName = (String) inputMap.get('boardName');

                outMap.put('regulate', fetchRecords(userId, category, sorting, selectOption, boardName));
                result = true;
            }
        } catch (Exception ex) {
            //Log exception
            LPI_ExceptionManager.logException('ApplyLicenseController', 'invokeMethod', ex);
        }
        return result;
    }

    /**
     * @description :This Method is used to return List of Licenses based on given category, userId and sorting.
     *
     * @author : MTX Group Product Team
     * @lastModifiedBy : MTX Group Product Team
     * @last modified details : Added class description, method description and proper comments before for loop and if check
     * @param userId : The user id
     * @param category : The category of license
     * @param sorting : Sorting order (ASC or DESC)
     * @param selectOption : The option selected by the user
     * @param boardName : The board name
     *
     * @return List<Map<String, String>> : Returns a list of licenses
     **/
    public static List<Map<String, String>> fetchRecords(
        String userId,
        String category,
        String sorting,
        String selectOption,
        String boardName
    ) {
        try {
            // Check if category is null or equals to 'All Categories'
            if (category == null || category == 'All Categories') {
                category = '%';
            } else {
                category = '%' + category + '%';
            }
            // Check if sorting is null
            if (sorting == null) {
                sorting = 'ASC';
            }
            String parStringToQuery = 'Id, Name,Description,IssuingDepartmentId,New_Application_Allowed__c,IssuingDepartment.Name,Not_for_Portal_User__c';
            String whereClause =
                'Name LIKE \'' +
                String.escapeSingleQuotes(category) +
                '\' AND New_Application_Allowed__c = true AND Not_for_Portal_User__c=false';
            // Check if boardName is not empty
            if (String.isNotEmpty(boardName)) {
                whereClause += ' AND IssuingDepartment.Name = \'' + boardName + '\'';
            }
            String filterReg;
            String userType = UserInfo.getUserType();
            // Check if the userType is not equal to 'Guest'
            if (userType != 'Guest') {
                filterReg = String.isEmpty(selectOption) ? 'Individual' : selectOption;
                whereClause += ' AND Authorisation_Type__c = \'' + filterReg + '\'';
            }

            List<RegulatoryAuthorizationType> conList = new List<RegulatoryAuthorizationType>();
            List<Map<String, String>> listOfRegAuth = new List<Map<String, String>>();
            //query the RegulatoryAuthorizationType object from the database
            for (
                RegulatoryAuthorizationType regAuth : LPI_RegulatoryAuthorizationTypeDAO.getRegulatoryAuthorizationTypeByDymanicQuery(
                    parStringToQuery,
                    whereClause,
                    null,
                    'Name',
                    sorting
                )
            ) {
                Map<String, String> tempMap = new Map<String, String>();
                tempMap.put('Id', regAuth.Id);
                tempMap.put('Name', regAuth.Name);
                tempMap.put('Description', regAuth.Description);
                tempMap.put(
                    'IssuingDepartment',
                    regAuth.IssuingDepartmentId != null ? regAuth.IssuingDepartment.Name : ''
                );
                tempMap.put('HowToApply', null);
                listOfRegAuth.add(tempMap);
            }

            return listOfRegAuth;
        } catch (Exception ex) {
            //Log exception
            LPI_ExceptionManager.logException('ApplyLicenseController', 'fetchRecords', ex);
        }
        return null;
    }
}