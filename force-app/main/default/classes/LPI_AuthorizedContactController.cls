/**
 *
 * @author          : MTX Group Product Team
 * @Description     : This class will Upsert and Delete and Fetch Application Content Records
 * @history
 * -------------------------------------------------------------------------------------------------------
 * Version      Date                Author                            Details
 *    1         14 Dec, 2023        MTX Group Product Team            Developement
 * -------------------------------------------------------------------------------------------------------
 */
global with sharing class LPI_AuthorizedContactController implements Callable{
    private final static String CLASS_NAME = 'LPI_AuthorizedContactController';
    private final static String SAVE_AUTHORIZED_CONTACT_DETAIL = 'saveAuthorizedContactDetail';
    private final static String INVOKE_METHOD = 'invokeMethod';
    private final static String FETCH_AUTHORIZED_CONTACT_DETAIL = 'fetchAuthorizedContactDetails';
    private final static String DELETE_AUTHORIZED_CONTACT_DETAIL = 'deleteAuthorizedContactDetail';
    private final static String AUTHORIZED_CONTACT = 'Authorized Contacts';
    /**
    * @author                      : MTX Group Product Team
    * @since                       : 14 JanDec 2023
    * @description                 : This method calls invoke method
    * @param action                : String
    * @param args			        : Map<String, Object>
    * @return                      : Object
    */
    global Object call(String action, Map<String, Object> args) {
        Map<String, Object> input = (Map<String, Object>) args.get('input');
        Map<String, Object> output = (Map<String, Object>) args.get('output');
        Map<String, Object> options = (Map<String, Object>) args.get('options');
        
        return invokeMethod(action, input, output, options);
    }
    /**
    @author      : MTX Group Product Team
    @BuildDate   : 14 Dec 2023
    @description : This method is returing true if its successfully invoked
    @params      : String methodName, Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options
    @return      : Boolean
    */
    private Boolean invokeMethod(
    String methodName,
    Map<String, Object> inputMap,
    Map<String, Object> outMap,
    Map<String, Object> options
    ) {
        Boolean result = true;
        try {
            if (methodName.equals(SAVE_AUTHORIZED_CONTACT_DETAIL)) {
                saveAuthorizedContactDetail(inputMap, outMap);
            } else if (methodName.equals(FETCH_AUTHORIZED_CONTACT_DETAIL)){
                fetchAuthorizedContactDetails(inputMap,outMap);
            } else if (methodName.equals(DELETE_AUTHORIZED_CONTACT_DETAIL)){
                deleteAuthorizedContactDetail(inputMap,outMap);
            }
            else {
                result = false;
            }
        } catch (Exception e) {
            LPI_ExceptionManager.logException(
            CLASS_NAME,
            INVOKE_METHOD,
            e
            );
            result = false;
        }
        return result;
    }
    
    /**
    * @author               : MTX Group Product Team
    * @description          : This method will call from the invoke method and used to return Authorized Contact Information
    * @param  inputMap      : data we are fetching from the Vlocity component
    * @param outMap         : Passing value to Omniscript
    **/
    public static void saveAuthorizedContactDetail(Map<String, Object> inputMap, Map<String, Object> outMap) {
        try {
            Id parId = (String)inputMap.get('parId');
            Map<String, String> keyMapping = new Map<String, String>{
                'IdIntakeAuthorizedContact' => 'Id',
                'ApplicantReferenceName' => 'First_Name__c',
                'ApplicantReferencePhone' => 'Phone_Number__c',
                'CoordinatorEmail' => 'Email__c'
            };
            Application_Content__c appContent = (Application_Content__c) LPI_VlocityUtility.createSObject(
            inputMap,
            keyMapping,
            'Application_Content__c'
            );
            appContent.Section_Header__c = AUTHORIZED_CONTACT;
            appContent.Preliminary_Application_Reference__c = parId;
            appContent.Copy_To_License_Content__c = true;
            appContent = (Application_Content__c) LPI_DML.doUpsert(appContent);
            outMap.put('IdIntakeAuthorizedContact', appContent.Id);
        } catch (Exception e) {
            LPI_ExceptionManager.logException(CLASS_NAME, SAVE_AUTHORIZED_CONTACT_DETAIL, e);
        }
    }
    
    /**
    * @author               : MTX Group Product Team
    * @description          : This method will call from the invoke method and used to return Application Content Information
    * @param  inputMap      : data we are fetching from the Vlocity component
    * @param outMap         : Passing value to Omniscript
    */
    
    public static void fetchAuthorizedContactDetails(Map<String, Object> inputMap, Map<String, Object> outMap){
        try{
            Id parId = (String) inputMap.get('parId');
            String appConQuryFields = 'Id, First_Name__c, Phone_Number__c, Email__c';
            String appContentWhereClause = 'Preliminary_Application_Reference__c = \'' + String.escapeSingleQuotes(parId) + '\' AND Section_Header__c = \'' + AUTHORIZED_CONTACT + '\'';
            if(String.isNotBlank(parId)){
                List<Application_Content__c> appContentList = (List<Application_Content__c>)LPI_ApplicationContentDAO.getApplicationContentByDymanicQuery(
                appConQuryFields,
                appContentWhereClause,
                null,
                null,
                null
                );
                List<Map<String,Object>> authorizedContactsDetailList = new List<Map<String,Object>>();
                Integer counter = 1;
                for(Application_Content__c appCon : appContentList){
                    Map<String,Object> resposeDataMap = new Map<String,Object>();
                    resposeDataMap.put('IdIntakeAuthorizedContact',appCon.Id);
                    resposeDataMap.put('ApplicantReferenceName',appCon.First_Name__c);
                    resposeDataMap.put('ApplicantReferencePhone',appCon.Phone_Number__c);
                    resposeDataMap.put('CoordinatorEmail',appCon.Email__c);
                    resposeDataMap.put('AuthorizedContact','Authorized Contact '+counter);
                    authorizedContactsDetailList.add(resposeDataMap);
                    counter+=1;
                }
                if(!authorizedContactsDetailList.isEmpty()){
                    outMap.put('AuthorizedContactsEditBlock', authorizedContactsDetailList);
                }
            }
        }catch (Exception e) {
            LPI_ExceptionManager.logException(CLASS_NAME, FETCH_AUTHORIZED_CONTACT_DETAIL, e);
        }
    }
    /**
    * @author          : MTX Group Product Team
    * @description 	: This method is used for performing delete action for the Edit blocks in the OS
    * @param inputMap  : fetching all the input from Omniscript
    * @param outMap    : Passing value to Omniscript
    * @param options   : Passing Options to Omniscript if needed
    */
    public static void deleteAuthorizedContactDetail(
    Map<String, Object> inputMap,
    Map<String, Object> outMap
    ) {
        try {
            Id appContentRecord = (String)inputMap.get('IdIntakeAuthorizedContact');
            if(String.isNotBlank(appContentRecord)){
                List<Application_Content__c> appContentRecordList = LPI_ApplicationContentDAO.getApplicationContentByDymanicQuery(
                'Id',
                ' Id =\'' + appContentRecord + '\'',
                null,
                null,
                null
                );
                if (!appContentRecordList.isEmpty()) {
                    LPI_WithoutSharingUtility.deleteSObject(appContentRecordList);
                }
            }
        } catch (Exception e) {
            LPI_ExceptionManager.logException(CLASS_NAME, DELETE_AUTHORIZED_CONTACT_DETAIL, e);
        }
    }
}