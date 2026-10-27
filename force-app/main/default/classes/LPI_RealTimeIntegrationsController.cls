/**
 * @description       : Controller class for Realtime Integrations.
 * @author            : MTX Group Product Team
 * @group             : 
 * @last modified on  : 07-22-2024
 * @last modified by  : MTX Group Product Team
**/

global with sharing class LPI_RealTimeIntegrationsController implements Callable {

   
    public static final String MO_TEXT = 'MO'; 
    public static final String MULTISTATE = 'MULTISTATE';
    public static final String SINGLE_STATE = 'SINGLE_STATE';
    public static final String SINGLE_STATE_LICENSE = 'Single State License';
    public static final String FEDERAL_SINGLE_STATE = 'Federal Single State License';
    public static final String LPI_DISCIPLINE_WARNING_MESSAGE_METADATA = 'LPI_Discipline_Warning_Message__mdt';
    public static final String NOT_ELIGIBLE_TO_APPLY_ENDORSMENT_LICENSE = 'Not_Eligibile_To_Apply_EndorsmentLicense';
    public static final String DECLARING_NON_MISSOURI_ADDRESS = 'Declaring_Non_Missouri_Address';
    public static final String DECLARING_ANOTHER_COMPACT_STATE = 'Declared_Another_Compact_State';
    public static final String DO_NOT_HOLD_LICENSE_IN_PRIMARY_RESIDENCE = 'Do_Not_Hold_License_in_Primary_Residence';
    public static final String EMPLOYED_BY_US_GOVERNMENT_OR_IN_ARMED = 'Employed_By_US_Governement_or_In_Armed';
    public static final String DO_NOT_HAVE_MISSOURI_PRIMARY_RESIDENCE = 'Do_Not_Have_Missouri_Primary_Residence';
    public static final String ALREADY_HOLD_MULTISTATE_LICENSE = 'Already_Hold_Multistate_License';
    
    public static final String MESSAGE = 'Message__c';
    
    /**
    * @description : Method to call functions from Omniscript.
    * @author MTX Group Product Team | 04-28-2023 
    * @param action 
    * @param args 
    * @return Object 
    **/
    global Object call(String action, Map<String, Object> args) {
		Map<String, Object> input = (Map<String, Object>) args.get('input');
		Map<String, Object> output = (Map<String, Object>) args.get('output');
		Map<String, Object> options = (Map<String, Object>) args.get('options');
		return invokeMethod(action, input, output, options);
	}

    /**
    * @description : Method to invoke different methods based on method name passed.
    * @author MTX Group Product Team | 04-28-2023 
    * @param methodName 
    * @param inputMap 
    * @param outMap 
    * @param options 
    * @return Boolean 
    **/
    private Boolean invokeMethod(
		String methodName,
		Map<String, Object> inputMap,
		Map<String, Object> outMap,
		Map<String, Object> options
	) {
		if (methodName == 'getIntegerationMetadataRecord') {
			getIntegerationMetadataRecord(inputMap, outMap);
		}
        else if (methodName == 'displayMessage') {
			displayMessage(inputMap, outMap);
		}
        
		return true;
	}

    


    /**
    * @description : Method to display message as an exception.
    * @author MTX Group Product Team | 04-28-2023 
    * @param inputMap 
    * @param outMap 
    * @return string 
    **/
    public static string displayMessage(Map<String, Object> inputMap,Map<String, Object> outMap){
        throw new LPI_Exception((String)inputMap.get('warningMessage'));

    }

    

    /**
    * @description : Get Meatdata record to perform realtime integratiom
    * @author MTX Group Product Team | 04-28-2023 
    * @param inputMap 
    * @param outMap 
    * @return string 
    **/
    public static string getIntegerationMetadataRecord(Map<String, Object> inputMap,Map<String, Object> outMap){

        try{
            String parId = String.escapeSingleQuotes((String)(inputMap.get('parid')));
            String fields = 'ID,Regulatory_Authorization_Type__r.IssuingDepartment.Name,Regulatory_Authorization_Type__r.Name,Amendment_Type__c,Business_License__r.Name,Business_License__r.Legacy_License_Number__c,Contact__r.AccountId,Business_License__r.Restriction__c, Currently_Holding_License_State__c, ' +
                ' Business_License__r.Currently_Holding_License_State__c, Type__c';
            String whereClause = 'Id =\'' + parId +'\'';
            List<PreliminaryApplicationRef> preLiminaryAppRefList =  LPI_PreliminaryApplicationRefDAO.getPreliminaryApplicationRefByDymanicQuery(fields,whereClause,null,null,null);
            String integrationType = String.escapeSingleQuotes((String)(inputMap.get('integrationType')));
            if(preLiminaryAppRefList.isEmpty() || String.isBlank(integrationType)){
                return null;
            }
            List<LPI_RealTimeAPIConfiguration__mdt> recordList = LPI_RealTimeAPIConfiguration__mdt.getAll()?.values();
            if(recordList.isEmpty()){
                return null;
            }
            LPI_RealTimeAPIConfiguration__mdt configRecord;
            PreliminaryApplicationRef appRec = preLiminaryAppRefList[0];
            for(LPI_RealTimeAPIConfiguration__mdt record : recordList){
                if(record.Board_Name__c == appRec.Regulatory_Authorization_Type__r.IssuingDepartment.Name && record.License_Type__c == appRec.Regulatory_Authorization_Type__r.Name && record.Sub_Type__c == appRec.Amendment_Type__c &&  integrationType ==  record.Integeration_Type__c){
                    configRecord = record;
                    break;
                }
            }
            if(configRecord == null){

                return null;
            }
           
            return 'true';
        }
        catch(Exception e){
            LPI_ExceptionManager.logException('LPI_RealTimeIntegrationsController', 'getIntegerationMetadataRecord', e);
            throw new LPI_Exception(e.getMessage());
        }
    }

    
    /**
    * @description 
    * @author MTX Group Product Team | 05-06-2024 
    * @return Schema.DescribeFieldResult 
    **/
    private static Schema.DescribeFieldResult getBillingStateCodeFieldData() {
        Schema.SObjectType sObjectType = Schema.getGlobalDescribe().get('Account');
        Schema.DescribeSObjectResult sObjectData = sObjectType.getDescribe();
        Map<String, Schema.SObjectField> fields = sObjectData.fields.getMap();
        return fields.get('BillingStateCode').getDescribe();
    }

 /**
    * @description : Method to updated fields on PAR if a reinstatement,renewal or Amendment type application.
    * @author MTX Group Product Team | 04-28-2023 
    * @param appRec 
    * @param isCompactStateSelected 
    * @param compactStatusList 
    * @param stateCode 
    * @param outMap 
    * @return PreliminaryApplicationRef 
    **/
    public static PreliminaryApplicationRef renewalAmendmentReinstateApp(PreliminaryApplicationRef appRec, Boolean isCompactStateSelected,List<String> compactStatusList,String stateCode,Map<String, Object> outMap){
        
        if(isCompactStateSelected && compactStatusList.contains(SINGLE_STATE)){
            outMap.put('warningMessage',queryDisciplineWarningMessage(DECLARING_NON_MISSOURI_ADDRESS));
             
        }
        else if(isCompactStateSelected && compactStatusList.contains(MULTISTATE)){
            outMap.put('warningMessage',queryDisciplineWarningMessage(DECLARING_ANOTHER_COMPACT_STATE));
             
        }
         
        if(isCompactStateSelected && compactStatusList.isEmpty()){
            outMap.put('warningMessage',queryDisciplineWarningMessage(DO_NOT_HOLD_LICENSE_IN_PRIMARY_RESIDENCE));
        }
        if(appRec.Amendment_Type__c != LPI_LiteralConstant.PAR_AMENDMENT_SUBTYPE_NAME_OR_ADDRESS_CHANGE
        ){
            outMap.put('warningMessage',queryDisciplineWarningMessage(EMPLOYED_BY_US_GOVERNMENT_OR_IN_ARMED));
             
        }
    
        return appRec;
    }

    /**
    * @description 
    * @author MTX Group Product Team | 05-07-2024 
    * @param appRec 
    * @param isCompactStateSelected 
    * @param compactStatusList 
    * @param stateCode 
    * @param outMap 
    * @return PreliminaryApplicationRef 
    **/
    public static PreliminaryApplicationRef resiprocityApp(PreliminaryApplicationRef appRec, Boolean isCompactStateSelected,List<String> compactStatusList,String stateCode,Map<String, Object> outMap){
        if(!isCompactStateSelected && stateCode != MO_TEXT){
            outMap.put('warningMessage',queryDisciplineWarningMessage(DO_NOT_HAVE_MISSOURI_PRIMARY_RESIDENCE));
             
        }
        if(isCompactStateSelected && compactStatusList.isEmpty()){
            outMap.put('warningMessage',queryDisciplineWarningMessage(NOT_ELIGIBLE_TO_APPLY_ENDORSMENT_LICENSE));
            outMap.put('hardStop',true);
        }
        else if(isCompactStateSelected && compactStatusList.contains(MULTISTATE)){
            
            outMap.put('warningMessage',queryDisciplineWarningMessage(ALREADY_HOLD_MULTISTATE_LICENSE));
        }
        else if(isCompactStateSelected && compactStatusList.contains(SINGLE_STATE)){
             
            outMap.put('warningMessage',queryDisciplineWarningMessage(DO_NOT_HAVE_MISSOURI_PRIMARY_RESIDENCE));
        }
       
        return appRec;
    }

    
    

    /**
	 * @author                      : Vamshi Kumar
	 * @since                       : 26th Jul, 2023
	 * @description                 : This method is used to fetch Discipline Warning Messages from LPI_Discipline_Warning_Message__mdt
	 * @param inputMap			    : String - Metadata Api Name
	 * @return                      : String - Message
	 * @last modified by            : MTX Group Inc
	 * @last modified date          :
	 * @modified details            :
	 */
    public static String queryDisciplineWarningMessage(String metadataApiName)
    {
        String messageString;
        try {
            if(String.isNotBlank(metadataApiName))
            {
                List<SObject> messageList = new List<SObject>();
                messageList = LPI_CustomMetadataTypeDAO.getCustomMetaDataByDymanicQuery(
                    'Message__c',
                    LPI_DISCIPLINE_WARNING_MESSAGE_METADATA,
                    'DeveloperName = \'' + String.escapeSingleQuotes(metadataApiName) + '\'',
                    null,null,null);
                    messageString = messageList.isEmpty() ? '' : String.valueOf(messageList[0].get(MESSAGE));
            }
        } catch (Exception ex) {
			LPI_ExceptionManager.logException('LPI_RealTimeIntegrationsController', 'queryDisciplineWarningMessage', ex);
		}
        return messageString;
    }
}