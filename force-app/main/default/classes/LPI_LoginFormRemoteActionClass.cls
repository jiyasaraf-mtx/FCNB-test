/**
 * @author                      : MTX Group Product Team
 * @since                       : 
 * @description                 : Class used for LoginFormRemoteAction in omniscript
 * @Reason						: without sharing because this class is used by Guest user
 * @last modified by            : MTX Group Product Team
 * @last modified date          : 
 * @modified details            : Add comment,Use Dao Class
 */
global without sharing class LPI_LoginFormRemoteActionClass implements Callable {
	
    private static final String CONTACT_ED = 'Contact ED';
    private static final String IDENTITY_THEFT = 'Identity Theft';

    /**
     * @author                      : MTX Group Product Team
     * @since                       : 
     * @description                 : Call Method
     * @last modified by            : MTX Group Product Team
     * @last modified date          : 
     * @modified details            : 
     */
    global Object call(String action, Map<String, Object> args) {
        Map<String, Object> input = (Map<String, Object>)args.get('input');
        Map<String, Object> output = (Map<String, Object>)args.get('output');
        Map<String, Object> options = (Map<String, Object>)args.get('options');

        return invokeMethod(action, input, output, options);
    }
	/**
     * @author                      : MTX Group Product Team
     * @since                       : 
     * @description                 : invoke method
     * @last modified by            : MTX Group Product Team
     * @last modified date          : 
     * @modified details            : Add comment
     */
    global Boolean invokeMethod(String methodName, Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options){
        Boolean result = false;
        try {
            if (methodName.equals('getLoginPageDetails')) {
                return getLoginDetails(inputMap, outMap, options );
            }
            else if (methodName.equals('getForgetPasswordDetails')) {
                getForgotPasswordDetails(inputMap, outMap, options );
            } 
            else
             if (methodName.equals('resendPasswordLink')) {
                resendPasswordLink((String)inputMap.get('username'));
            } 
            else {
                result = false;
            }
        } catch (Exception e) {
            LPI_ExceptionManager.logException('LoginFormRemoteActionClass', 'invokeMethod', e);
            result = false;
        }
        return result;
    } 
    /**
     * @author                      : MTX Group Product Team
     * @since                       : 
     * @description                 : fetch login detail
     * @last modified by            : MTX Group Product Team
     * @last modified date          : 
     * @modified details            : Add comment,Use Dao class
     */
    public boolean getLoginDetails(Map < String, Object > inputMap, Map < String, Object > outMap, Map < String, Object > options){
        Map <String,object> loginStepInfo = (Map <String,object> )inputMap.get('Login');
        String userName = (String)loginStepInfo.get('username'); 
        String userPassword = (String)loginStepInfo.get('password');
        try{
            outMap.put('returnurl',Site.login(username, userPassword,'/s/').getUrl());
            outMap.put('loginError',false);
            List<User> userList = new LPI_UserDao.LPI_UserWithoutSharingDAO().getUserByDymanicQueryWithoutSecurityEnforced(
            'Id,AccountId,ContactId,Account.Person_Account_For_Business__c,Account.Licensee_Modification__c,Account.Licensee_Modification_Reason__c',
            ' Username = ' + '\'' + String.escapeSingleQuotes(username) + '\'',
            null,null,null);
            if(userList.isEmpty()){
                LPI_ExceptionManager.logException('LoginFormRemoteActionClass', 'getLoginDetails','User Not Found!!',
					'User Not Found',null,null);
                outMap.put('loginError',true);
                return false;
            }
            if(!userList.isEmpty() && userList[0].Account.Licensee_Modification__c == true && (userList[0].Account.Licensee_Modification_Reason__c == CONTACT_ED || userList[0].Account.Licensee_Modification_Reason__c == IDENTITY_THEFT)){
                outMap.put('licenseeModification',true);
            }else{
                outMap.put('licenseeModification',false);
            }
            User u = userList[0];
            List<String> allowedRoles = new List<String>();
            for(String va: LPI_ApexSharingForPortalBatch.rolesSet){
                allowedRoles.add(va);
            }
            allowedRoles.add('Temporary Clerk');
            allowedRoles.add('License Service Provider');
            allowedRoles.add('Not Applicable');
            Set<Id> accountIdSet = new Set<Id>();
            String fieldsToQueryACRs = 'Id, Related_From__c,Related_From__r.Name,Related_From__r.SelectedAccountId__c';
		    String whereClauseForRelationship = 'Related_To__c = \'' + String.escapeSingleQuotes(u.AccountId) + '\''+
                            ' AND Roles__c IN '+ LPI_ServiceUtility.getStringValuesByList(allowedRoles) + 
                            ' AND Start_Date__c != NULL '+
							' AND EndDate__c = NULL ';
            
            for(Business_Relationships__c acrList : new LPI_BusinessRelationshipDAO.LPI_BusinessRelationshipsWithoutSharingDAO().getBusinessRelationshipsByDymanicQuery(
                fieldsToQueryACRs,
                whereClauseForRelationship, 
                null,null,null
            )){
                accountIdSet.add(acrList.Related_From__c);
            }
            Account acc = new Account();
            acc.Id = u.AccountId;
            if(accountIdSet.isEmpty() || u.Account.Person_Account_For_Business__c){
                acc.SelectedAccountId__c = u.AccountId;
            }else{
                acc.SelectedAccountId__c = '';
            }
            update acc;
            omnistudio.DRGlobal.clearCacheForAllDataRaptor();
            return true;
        }
        catch(Exception e){
            LPI_ExceptionManager.logException('LoginFormRemoteActionClass', 'getLoginDetails', e);
            outMap.put('loginError',true);
            return false;
        }
    }
    /**
     * @author                      : MTX Group Product Team
     * @since                       : 
     * @description                 : used for getting forget password details
     * @last modified by            : MTX Group Product Team
     * @last modified date          : 
     * @modified details            : Add comment
     */
    public void getForgotPasswordDetails(Map < String, Object > inputMap, Map < String, Object > outMap, Map < String, Object > options){
        try {
            Map<String,object> forgetStepInfo = (Map<String,object>)inputMap.get('ForgotPassword');
            String userId = (String)forgetStepInfo.get('Email1'); 
            List<User> userList = new LPI_UserDao.LPI_UserWithoutSharingDAO().getUserByDymanicQuery(
                'Id, Username',
                'Username = \'' + userId + '\'',
                null,
                null,
                null
            );
            if(!userList.isEmpty()){
                outMap.put('empty', false);
                Boolean res = Site.forgotPassword(userId);
            } else{
                outMap.put('empty', true);
            }
        } catch(Exception e){
            LPI_ExceptionManager.logException('LoginFormRemoteActionClass', 'getForgotPasswordDetails', e);
            outMap.put('empty',true);
        }
    }
    /**
     * @author                      : MTX Group Product Team
     * @since                       : 
     * @description                 : used to send password link for reset
     * @last modified by            : MTX Group Product Team
     * @last modified date          : 
     * @modified details            : Add comment
     */
    public static void resendPasswordLink(String userId) {
        try{
            Boolean res = Site.forgotPassword(userId);
        }
        catch(Exception e){
            LPI_ExceptionManager.logException('LoginFormRemoteActionClass', 'resendPasswordLink', e);
        }
    }
}