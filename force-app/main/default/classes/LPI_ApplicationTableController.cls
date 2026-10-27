/**
 *
 * @author      :  MTX Group Product Team
 * @description : This class is use to fetch All the submitted Application and along with that use for fetching saved steps Details
 */
global with sharing class LPI_ApplicationTableController implements Callable {
    
    private static final String CLASS_NAME = 'ApplicationTableController';
    /**
    * @description This Method is Used to Internally call the invokeMethod. 
    * @author MTX Group Product Team
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
    * @description 
    * @author MTX Group Product Team
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
        Boolean result = false;
        try {
            if (methodName == LPI_LiteralConstant.GET_VIEW_APPLICATION_QUESTIONS) {
                outMap.put(
                    'questions' ,getViewApplicationQuestions(
                        inputMap,
                        (String) inputMap.get(LPI_LiteralConstant.REC_ID)
                    )
                );
            } else if (methodName == LPI_LiteralConstant.GET_AUDIT_ESCROW_QUESTIONS) {
                outMap.put(
                    'questions',
                    getAuditEscrowQuestions(
                        inputMap,
                        (String) inputMap.get(LPI_LiteralConstant.REC_ID)
                    )
                );
            }
            result = true;
        } catch (Exception e) {
            LPI_ExceptionManager.logException(CLASS_NAME, 'invokeMethod', e);
            result = false;
        }
        return result;
    }

    /**
    * @description method is used to view Application questions
    * @author MTX Group Product Team
    * @param inputMap 
    * @param recordid 
    * @return Map<String, Object> 
    **/
    public static Map<String, Object> getViewApplicationQuestions(Map<String, Object> inputMap, String recordid) {
        Map<String, Object> questionDetails = new Map<String, Object>();
        try{
            Id recoId = (Id) recordid;
            if (String.isEmpty(recoId)) {
                recoId = (String) inputMap.get('parid');
            }
            String objectName = recoId.getSObjectType().getDescribe().getName();
            List<Sobject> obj;
            String whereClause;
            if (String.isNotEmpty(recoId)) {
                if (objectName == LPI_LiteralConstant.PAR_SOBJECT_API) {
                    obj = LPI_PreliminaryApplicationRefDAO.getPreliminaryApplicationRefByDymanicQuery(
                        'Id, applicationtype, License_Questions__c, Tax_Compliance__c',
                        ' Id = \''+recoId+'\'',
                        null,null,null);
                }
            }
            if(!obj.isEmpty()&& String.isNotEmpty((String)obj[0].get(LPI_LiteralConstant.LICENSE_QUESTIONS))){
                Map<String, Object> deserialized = (Map<String, Object>) JSON.deserializeUntyped(
                    String.valueOf(obj[0].get(LPI_LiteralConstant.LICENSE_QUESTIONS))
                );
                for (String values : deserialized.keySet()) {
                    if(!values.endsWith('Formula')){
                        questionDetails.put(
                            values,
                            deserialized.get(values) != null ? deserialized.get(values) : null
                        );
                    }
                    
                }
            }
        } catch(Exception ex) {
            LPI_ExceptionManager.logException(CLASS_NAME, 'getViewApplicationQuestions', ex);
        }
        return questionDetails;
    }

    /**
    * @description method is used to view Audit Escow questions
    * @author MTX Group Product Team
    * @param inputMap 
    * @param recordid 
    * @return Map<String, Object> 
    **/
    public static Map<String, Object> getAuditEscrowQuestions(
        Map<String, Object> inputMap,
        String recordid
    ) {
        Map<String, Object> questionDetails = new Map<String, Object>();
        try {
            Id recoId = (Id) recordid;
            if (String.isEmpty(recoId)) {
                recoId = (String) inputMap.get('parid');
            }
            String objectName = recoId.getSObjectType().getDescribe().getName();
            List<Sobject> obj = new  List<Sobject>();
            
            if (String.isNotEmpty(recoId)) {
                if (objectName == LPI_LiteralConstant.PAR_SOBJECT_API) {
                    obj = LPI_PreliminaryApplicationRefDAO.getPreliminaryApplicationRefByDymanicQuery(
                        'Id, Audit_Escrow_or_Trust_Account_Questions__c, Regulatory_Authorization_Type__c',
                        'Id = \''+recoId+'\'',
                        null,null,null);
                }
            }
            if(!obj.isEmpty() && String.isNotBlank((String)obj[0].get(LPI_LiteralConstant.AUDIT_ESCROW_OR_TRUST_ACCOUNT_QUESTIONS))){
                Map<String, Object> deserialized = (Map<String, Object>) JSON.deserializeUntyped(
                    String.valueOf(
                        obj[0].get(LPI_LiteralConstant.AUDIT_ESCROW_OR_TRUST_ACCOUNT_QUESTIONS)
                    )
                );
                for (String values : deserialized.keySet()) {
                    if(!values.endsWith('Formula')){
                        questionDetails.put(
                            values,
                            deserialized.get(values) != null
                            ? deserialized.get(values)
                            : null
                        );
                    }
                }
            }
        } catch(Exception ex) {
            LPI_ExceptionManager.logException(CLASS_NAME, 'getAuditEscrowQuestions', ex);
        }
        
        return questionDetails;
    }

}