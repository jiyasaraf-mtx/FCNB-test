/**
 * @description       : This Class is Use to track validation logic of Attestation Step
 * @author            : MTX Group Product Team
 * @last modified on  : 07-26-2024
 * @last modified by  : MTX Group Product Team
 **/
global with sharing class LPI_AttestationCheck implements Callable {
    // ************************************************************* All Constant *************************************************************
    private final static String CLASS_NAME = 'LPI_AttestationCheck';
    private final static String INVOKE_METHOD = 'InvokeMethod';
    private final static String IS_ALLOWED_FOR_Validation = 'isAllowedForAttestation';   
    private final static Set<String> NOT_ALLOWED_ROLES = new Set<String>{'Temporary Clerk','License Service Provider'}; 
    private final static String BUSINESS = 'Business';   
    // ****************************************************************************************************************************************

    /**
    * @description 
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
	 * @author               : MTX Group Product Team
	 * @param methodName     : Method Name
	 * @param inputMap       : Input Parameter Passed from Omniscript
	 * @param outMap         : Output Passed to Omniscript
	 * @param options        : Extra Options passed from Omniscript
	 * @last modified by     : MTX Group Product Team
	 * @last modified date   :
	 * @modified details     :
	 * @return  `Boolean`
	 */
    private Boolean invokeMethod(
		String methodName,
		Map<String, Object> inputMap,
		Map<String, Object> outMap,
		Map<String, Object> options
	) {
		try {
			if (methodName == IS_ALLOWED_FOR_Validation) {
                isAllowedForAttestation(inputMap, outMap);
			} 
		} catch (Exception e) {
			LPI_ExceptionManager.logException(CLASS_NAME, INVOKE_METHOD, e);
			throw new LPI_Exception('There is some problem in Attestation Validation', e);
		}
		return true;
	}

    /**
	 * @author               : MTX Group Product Team
	 * @description 		 : This method will check is user allow to see attestation step or not
	 * @param inputMap       : Input Parameter Passed from Omniscript
	 * @param outMap         : Output Passed to Omniscript
	 * @last modified by     : MTX Group Product Team
	 * @last modified date   :
	 * @modified details     :
	 * @return  `Boolean`
	 */
    private static void isAllowedForAttestation(Map<String, Object> inputMap, Map<String, Object> outMap) {
		try 
        {
            String parId = (String) inputMap.get('parid');
			Id conId;
			List<User> userList = LPI_UserDao.getCurrentUserRecord();
            if(String.isNotBlank(parId))
            {
				List<PreliminaryApplicationRef> parList = LPI_PreliminaryApplicationRefDAO.getPreliminaryApplicationRefByDymanicQuery('Id,Contact__r.AccountId,BusinessAccountNameId,Regulatory_Authorization_Type__r.Authorisation_Type__c,BusinessAccountName.Name','Id = \'' + String.escapeSingleQuotes(parId) + '\'',null,null,null);
				if (!userList.isEmpty() && userList[0].Profile.Name == 'Portal User') {
					LPI_AccountDAO.LPI_AccountWithoutSharingDAO accountWithoutSharing = new LPI_AccountDAO.LPI_AccountWithoutSharingDAO();
					List<Account> acc =  accountWithoutSharing.getAccountByDymanicQuery('Id','PersonContactId = \''+userList[0].ContactId+'\'',null,null,null);
					conId = acc[0].Id;
				}
				else if(!userList.isEmpty() && userList[0].Profile.Name != 'Portal User'){
					conId = parList[0].Contact__r.AccountId;
				}
				if(!parList.isEmpty() && parList[0].Regulatory_Authorization_Type__r.Authorisation_Type__c == BUSINESS && conId != null && parList[0].BusinessAccountNameId != null)
                {
                    List<Business_Relationships__c> relation = LPI_BusinessRelationshipDAO.fetchBusinessRelationshipRecords('Id,Roles__c','Related_To__c = \''+conId+'\''+' AND Related_From__c =\''+parList[0].BusinessAccountNameId+'\'',null,null,null);
                    if(relation != null && !relation.isEmpty() && NOT_ALLOWED_ROLES.contains(relation[0].Roles__c))
                    {
                        outMap.put('isAllowedForAttest',true);
                    }
					else {
						outMap.put('isAllowedForAttest',false);
					}
					outMap.put('businessAccountName',parList[0].BusinessAccountName.Name);
                }
                else{
                    outMap.put('isAllowedForAttest',false);
                }
            }

        } catch (Exception e) {
			LPI_ExceptionManager.logException(CLASS_NAME, 'isAllowedForAttestation', e);
			throw new LPI_Exception('Problem in Attestation validation ', e);
		}
	}
}