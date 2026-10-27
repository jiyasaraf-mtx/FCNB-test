/**
 * @author      : Manish Kumar Singh
 * @since       :
 * @description : This Class create data from Omniscript related to the Criminal History Disclosure Statement
 *  -------------------------------------------------------------------------------------------------------
 * Version      Date                Author                           Details
 *    1         15 Mar, 2023        Manish Kumar Singh        		 Initial Developement
 * -------------------------------------------------------------------------------------------------------
 */
global with sharing class LPI_PreLicensurePetition implements Callable {
    /***************************  Constants *************************************/
    private static final String CLASS_NAME = 'LPI_PreLicensurePetition';
    private static final String METHOD_INVOKE_METHOD = 'invokeMethod';
    private static final String METHOD_CREATE_CRIMINAL_HISTORY_STATEMENT = 'createCriminalHistoryStatement';
    private static final String METHOD_FETCH_REG_AUTH_TYPE_ID = 'fetchRegAuthTypeId';
	private static final String HEADER_FILTER = 'Criminal History Disclosure Statement';
	private static final String REG_AUTH_TYPE = 'Pre-licensure Petition';
	private static final String PAR_NOT_FOUND = 'PAR record is not created for the flow';
    /***************************  Constants *************************************/
    global Object call(String action, Map<String, Object> args) {
        Map<String, Object> input = (Map<String, Object>) args.get('input');
        Map<String, Object> output = (Map<String, Object>) args.get('output');
        Map<String, Object> options = (Map<String, Object>) args.get('options');
        return invokeMethod(action, input, output, options);
    }

    /**
     * @description         : This method will compare method from Omniscript and execute only that specific method
     * @author              : Manish Kumar Singh | 03-15-2023
     * @param methodName 	: String method name
     * @param inputMap		: Map<String, Object> input map from OS
     * @param outMap 		: Map<String, Object>
     * @param options 		: Map<String, Object>
     **/
    private Boolean invokeMethod(
        String methodName,
        Map<String, Object> inputMap,
        Map<String, Object> outMap,
        Map<String, Object> options
    ) {
        Boolean result = true;
        try {
            if (methodName.equals(METHOD_CREATE_CRIMINAL_HISTORY_STATEMENT)) {
                createCriminalHistoryStatement(inputMap, outMap);
            } else {
                result = false;
            }
        } catch (Exception e) {
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
     * @description    : This method is Used to Create Application Content records(Criminal History Disclosure Statement)
     * @author         : Manish Kumar Singh | 03-15-2023
     * @param inputMap : fetching all the input from Omniscript
     * @param outMap   : Passing value to Omniscript
     **/
    private static void createCriminalHistoryStatement(
        Map<String, Object> inputMap,
        Map<String, Object> outMap
    ) {
        try {
            String parId = (String) inputMap.get('parId');
			Integer applicantListCount = (Integer) inputMap.get(
                'applicantListCount'
            );
			if (String.isEmpty(parId)) {
				LPI_ExceptionManager.logException(
					CLASS_NAME,
					METHOD_CREATE_CRIMINAL_HISTORY_STATEMENT,
					PAR_NOT_FOUND,
					PAR_NOT_FOUND,
					null,
					null
				);
				return;
			}

            String arWhereClause =
                'Preliminary_Application_Reference__c =\'' +
                String.escapeSingleQuotes(parId) +
                '\' AND Section_Header__c = \'' +
                String.escapeSingleQuotes(HEADER_FILTER) +
                '\'';

            Set<Id> previousRecords = new Map<Id, Application_Content__c>(
                    LPI_ApplicationContentDAO.getApplicationContentByDymanicQuery(
                        'Id',
                        arWhereClause,
                        null,
                        null,
                        null
                    )
                )
                .keySet();
            List<sObject> upsertList = new List<sObject>();
            List<Object> appStatementInfo = new List<Object>();
            Map<String, String> keyMapping = new Map<String, String>{
                'PLPDifferentName' => 'Did_You_Have_A_Different_Name__c',
                'PLPSpecify' => 'Specify__c',
                'PLPArrestingAgency' => 'Arresting_Agency__c',
                'PLPCourtName' => 'Court_Name__c',
                'PLPCourtLocation' => 'Court_Location__c',
                'PLPConvictionDate' => 'Conviction_Date__c',
                'PLPCaseNumber' => 'Case_Number__c',
                'PLPInitialCharges' => 'Initial_Charges__c',
                'PLPSentenceImposed' => 'Sentence_Imposed__c',
                'PLPIncarcerationDate' => 'Incarceration_Date__c',
                'PLPReleaseDate' => 'Release_Date__c',
                'PLPProbationStartDate' => 'Probation_Start_Date__c',
                'PLPProbationCompletionDate' => 'Probation_Completion_Date__c',
                'PLPProbationOfficer' => 'Probation_Officer__c',
                'PLPProbationOfficerPhone' => 'Probation_Officer_Phone__c',
                'PLPProbationOfficerEmail' => 'Probation_Officer_Email__c'
            };
            if (applicantListCount > 1) {
                appStatementInfo = (List<Object>) inputMap.get('applicantList');
            } else {
                appStatementInfo.add(inputMap.get('applicantList'));
            }
            for (Object appref : appStatementInfo) {
                Map<String, Object> obj = (Map<String, Object>) appref;
                String objId = (String) obj.get('AppContentId');
                Application_Content__c appDisStatementDetails = (Application_Content__c) LPI_VlocityUtility.createSObject(
                    obj,
                    keyMapping,
                    'Application_Content__c'
                );
                appDisStatementDetails.put(
                    'Preliminary_Application_Reference__c',
                    parId
                );
                appDisStatementDetails.put('Id', objId);
                appDisStatementDetails.put('Section_Header__c', HEADER_FILTER);
                appDisStatementDetails.put('Copy_To_License_Content__c', false);
                upsertList.add(appDisStatementDetails);
                if (previousRecords.contains(objId)) {
                    previousRecords.remove(objId);
                }
            }
            if (!upsertList.isEmpty()) {
                LPI_DML.doUpsert(upsertList);
            }
            if (!previousRecords.isEmpty()) {
                List<Id> deleteRecords = new List<Id>(previousRecords);
                Database.DeleteResult[] deleteResults = Database.delete(
                    deleteRecords,
                    true
                );
                for (Database.DeleteResult dr : deleteResults) {
                    if (!dr.isSuccess()) {
                        for (Database.Error err : dr.getErrors()) {
                            LPI_ExceptionManager.logException(
                                CLASS_NAME,
                                METHOD_CREATE_CRIMINAL_HISTORY_STATEMENT,
                                'Database.Error',
                                err.getMessage(),
                                '',
                                null
                            );
                        }
                    }
                }
            }
        } catch (Exception e) {
            LPI_ExceptionManager.logException(
                CLASS_NAME,
                METHOD_CREATE_CRIMINAL_HISTORY_STATEMENT,
                e
            );
        }
    }

    /**
     * @description               : This method is used to Fetch Regulatory Authorization Type Id
     * @author 					  : Manish Kumar Singh | 18-03-2023
     * @return  				  : String
     **/
    @AuraEnabled
    public static String fetchRegAuthTypeId() {
        try {
            String whereClause = 'Name =\'' + REG_AUTH_TYPE + '\'';
            List<RegulatoryAuthorizationType> regAuthId = LPI_RegulatoryAuthorizationTypeDAO.getRegulatoryAuthorizationTypeByDymanicQuery(
                'Id',
                whereClause,
                '1',
                null,
                null
            );
			if(!regAuthId?.isEmpty()){
				return (String) regAuthId[0].Id;
			}
        } catch (Exception e) {
            LPI_ExceptionManager.logException(
                CLASS_NAME,
                METHOD_FETCH_REG_AUTH_TYPE_ID,
                e
            );
        }
        return null;
    }
}