/**
 * @description       : This Method is Used to fetch PersonExamination Exam Info.
 * @author            : MTX Group Product Team
 * @group             : MTX Group Inc
 * @last modified on  : 07-26-2024
 * @last modified by  : MTX Group Product Team
 **/
global with sharing class LPI_UserPassOrFail implements Callable {
    public static final string FAIL_TEXT = 'Fail';
    global Object call(String action, Map<String, Object> args) {
        Map<String, Object> input = (Map<String, Object>) args.get('input');
        Map<String, Object> output = (Map<String, Object>) args.get('output');
        Map<String, Object> options = (Map<String, Object>) args.get('options');

        return invokeMethod(action, input, output, options);
    }
    /**
     * @author               : MTX Group Product Team
     * @param methodName     : Method Name
     * @param inputMap       : Input Parameter Passed from Omniscript
     * @param outMap         : Output Passed to Omniscript
     * @param options        : Extra Options passed from Omniscript
     * @return  `Boolean`
     */
    private Boolean invokeMethod(
        String methodName,
        Map<String, Object> inputMap,
        Map<String, Object> outMap,
        Map<String, Object> options
    ) {
        try {
            if (methodName == 'deletePAR') {
                deletePAR(inputMap, outMap);
            }
            return true;
        } catch (Exception ex) {
            LPI_ExceptionManager.logException(
                'LPI_UserPassOrFail',
                'invokeMethod',
                ex
            );
        }
        return false;
    }

    
    /**
     * @author           : MTX Group Product Team
     * @param inputMap   : Input value passed from OS
     * @param outMap     : Output value passed from here to OS
     */
    public static void deletePAR(
        Map<String, Object> inputMap,
        Map<String, Object> outMap
    ) {
        try {
            String parId = (String) inputMap.get('parId');
            if (parId == null) {
                return;
            }
            //if there is any PAR then it will used to delete
            List<PreliminaryApplicationRef> parList = LPI_PreliminaryApplicationRefDAO.getPreliminaryApplicationRefByDymanicQuery(
                'Id',
                'Id = \'' +
                String.escapeSingleQuotes(parId) +
                '\'',
                null,
                null,
                null
            );
            if (parList != null && parList.size() > 0) {
                LPI_TriggerHandler.bypass('PreliminaryApplicationTriggerHandler');
                if (
                    LPI_TriggerHandler.isBypassed(
                        'PreliminaryApplicationTriggerHandler'
                    )
                ) {
                    LPI_WithoutSharingUtility.deleteSObject(parList[0]);
                }
            }
        } catch (Exception ex) {
            LPI_ExceptionManager.logException(
                'LPI_UserPassOrFail',
                'deletePAR',
                ex
            );
        }
    }
}