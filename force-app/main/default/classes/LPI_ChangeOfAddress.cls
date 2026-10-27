/**
 * @author      : Aditya Chaturvedi and Manish Kumar Singh
 * @since       : January 15, 2024
 * @description : This class handles the fetch operation of Residence Address and/or Mailing Address
 * --------------------------------------------------------------------------------------------------------
 * Version      Date                Author                                        Details
 *    1         January 15, 2024    Aditya Chaturvedi and Manish Kumar Singh      Initial Developement
 * --------------------------------------------------------------------------------------------------------
 */
global with sharing class LPI_ChangeOfAddress 
                            //implements Callable 
                            {
    public void method1(){
       
    }

    /**
     * @author                      : Aditya Chaturvedi and Manish Kumar Singh
     * @since                       : January 15, 2024
     * @description                 : This method is used to internally call the `invokeMethod` method
     * @param action                : It contains method name which is called from OmniScript
     * @param args                  : It is Map<String, Object> which contanis `input`, `output` and `options`
     * @return                      : `Object`
     * @last modified by            : MTX Group Inc
     * @last modified date          : {Add if modified by you}
     * @last modified details       : {Add if modified by you}
     */
    // global Object call(String action, Map<String, Object> args) {
    //     Map<String, Object> input = (Map<String, Object>) args.get('input');
    //     Map<String, Object> output = (Map<String, Object>) args.get('output');
    //     Map<String, Object> options = (Map<String, Object>) args.get('options');
    //     return invokeMethod(action, input, output, options);
    // }

    // /**
    //  * @author                      : Aditya Chaturvedi and Manish Kumar Singh
    //  * @since                       : January 15, 2024
    //  * @description                 : This method is called from `call` method and internally calls the OmniScript methods
    //  * @param methodName            : It contains method name which is called from OmniScript
    //  * @param inputMap              : Input data passed from OmniScript
    //  * @param outMap                : Output data passed to OmniScript
    //  * @param options               : Optional Input passed from OmniScript
    //  * @return                      : `Boolean`
    //  * @last modified by            : MTX Group Inc
    //  * @last modified date          : {Add if modified by you}
    //  * @last modified details       : {Add if modified by you}
    //  */
    // private Boolean invokeMethod(String methodName, Map<String, Object> inputMap, Map<String, Object> outMap, Map<String, Object> options) {
    //     Boolean result = true;
    //     try {
    //         if (methodName == 'fetchAddressBasedOnUserInput') {
    //             fetchAddressBasedOnUserInput(inputMap, outMap);
    //         }
    //     } 
    //     catch (Exception ex) {
    //         result = false;
    //         LPI_ExceptionManager.logException('LPI_ChangeOfAddress', 'invokeMethod', ex);
    //         throw new LPI_Exception(ex.getMessage());
    //     }
    //     return result;
    // }

    // /**
    //  * @author                      : Aditya Chaturvedi and Manish Kumar Singh
    //  * @since                       : January 15, 2024
    //  * @description                 : This method fetches Residence Address and/or Mailing Address based on user input
    //  * @param inputMap              : Input data passed from OmniScript
    //  * @param outMap                : Output data passed to OmniScript
    //  * @return                      : `void`
    //  * @last modified by            : MTX Group Inc
    //  * @last modified date          : {Add if modified by you}
    //  * @last modified details       : {Add if modified by you}
    //  */
    // private static void fetchAddressBasedOnUserInput(Map<String, Object> inputMap, Map<String, Object> outMap) {
    //     try {
    //         Map<String, object> userInputMap = (Map<String, object>) inputMap.get('AmendmentChangeOfAddressInstructions');
    //         Id parId = (Id) inputMap.get('parid');
    //         String addressType = (String) userInputMap.get('AddressTypeToChange');
    //         if (String.isNotBlank(parId)) {
    //             String parWhereClause = 'Id = \'' + String.escapeSingleQuotes(parId) + '\'';
    //             List<PreliminaryApplicationRef> parList = LPI_PreliminaryApplicationRefDAO.getPreliminaryApplicationRefByDymanicQuery(
    //                                                                                             'Id', parWhereClause, '1', null, null);
    //             if (!parList.isEmpty() && String.isNotBlank(addressType)) {
    //                 parList[0].Type_of_Address_Change__c = addressType;
    //                 LPI_DML.doUpdate(parList[0]);
    //                 if (addressType == 'Only Residence Address') {
    //                     LPI_FetchResidenceAddress.fetchResidenceAddress(inputMap, outMap);
    //                 } 
    //                 else if (addressType == 'Only Mailing Address') {
    //                     LPI_FetchMailingAddress.fetchNewMailingAddressFromPAR(inputMap, outMap);
    //                 } 
    //                 else {
    //                     LPI_FetchResidenceAddress.fetchResidenceAddress(inputMap, outMap);
    //                     LPI_FetchMailingAddress.fetchNewMailingAddressFromPAR(inputMap, outMap);
    //                 }
    //             }
    //         }
    //     }
    //     catch (Exception ex) {
    //         LPI_ExceptionManager.logException('LPI_ChangeOfAddress', 'fetchAddressBasedOnUserInput', ex);
    //         throw new LPI_Exception(ex.getMessage());
    //     }
    //}
}