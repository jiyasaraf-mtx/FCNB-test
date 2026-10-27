/**
* @description       : 
* @author            : MTX(Vipin Agarwal)
* @group             : 
* @last modified on  : 07-12-2024
* @last modified by  : Uzma Md
**/
global with sharing class LPI_FCDashboardProfileCompletion implements Callable {
   /**
    * @description This Method is Used to Internally call the invokeMethod. 
    * @author Vamsi Mudaliar | 01-31-2023 
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
    
    /*
    @author : 
    @BuildDate : 4th Nov, 2022
    @description : This method is returing true if its successfully invoked
    @params : String methodName, Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options
    @return : Boolean
    */
    private Boolean invokeMethod(String methodName, Map < String, Object > inputMap, Map < String, Object > outMap, Map < String, Object > options) {
        Boolean result = false;
        try {
            // outMap.put('profilePercentage', profileCompletionFieldSet((String) options.get('userrecid')));
            // outMap.put('userList', fetchUserDetails((String) options.get('userrecid')));
            // outMap.put('url', fetchUrl((String) options.get('userrecid')));
            
        } catch (Exception e) {
            LPI_ExceptionManager.logException('LPI_FCDashboardProfileCompletion', 'invokeMethod', e);
        }
        return result;
    }
    
    /*
    @author : 
    @BuildDate : 4th Nov, 2022
    @description : This method is returs profile Completion Percentage
    @params : String userId
    @return : double
    */
    // @AuraEnabled
    // public static double profileCompletionFieldSet(String userId) {
    //     String queryString;
    //     List < Contact > conList;
    //     Double profilePercentage;
    //     User us = LPI_WithoutSharingUtility.getUserRecordDetailWithoutSharing(userId);
        
    //     Id conId = us.ContactId;
    //     queryString = 'select id';
    //     for (Schema.FieldSetMember fld: SObjectType.Contact.FieldSets.Profile_Completion.getFields()) {
    //         queryString += ', ' + fld.getFieldPath();
    //     }
    //     queryString += ' from Contact where Id =: conId';
    //     conList = Database.query(queryString);
    //     Double fieldSetSize = SObjectType.Contact.FieldSets.Profile_Completion.getFields().size();
    //     for (Contact con: conList) {
    //         Integer counter = 0;
    //         for (Schema.FieldSetMember conField: SObjectType.Contact.FieldSets.Profile_Completion.getFields()) {
    //             if (String.valueOf(con.get(conField.getFieldPath())) != null) {
    //                 counter++;
    //             }
    //         }
    //         profilePercentage = Math.floor((counter) / (fieldSetSize) * 100);
    //     }
    //     return profilePercentage;
    // }
    
    /*
    @author : 
    @BuildDate : 4th Nov, 2022
    @description : This method is used to fetch user MediumPhotoUrl based on userId
    @params : String userId
    @return : List<User>
    */
    // public static List < User > fetchUserDetails(String userId) {
    //     List < User > userList = new List < User > {
    //         LPI_WithoutSharingUtility.getUserRecordDetailWithoutSharing(userId)
    //     };
    //     return userList;
    // }
    
    /*
    @author : 
    @BuildDate : 4th Nov, 2022
    @description : This method is returs profile Completion Percentage
    @params : String userId
    @return : string
    */
    // public static string fetchUrl(String userId) {
    //     User userList = LPI_WithoutSharingUtility.getUserRecordDetailWithoutSharing(userId);
    //     return userList.MediumPhotoUrl;
    // }
    
    /*
    @author : Vipin Agarwal
    @BuildDate : 29th Dec, 2022
    @description : This method is get all ACR record related to logged in user account id 
    @params : 
    @return : Map < String, Object >
    */
    @AuraEnabled
    public static Map<String,Object> getAcrRecords() {
        try{
            Map < String, Object > resultMap = new Map < String, Object > ();
            List<String> allowedRoles = new List<String>();
            for(String va: LPI_ApexSharingForPortalBatch.rolesSet){
                allowedRoles.add(va);
            }
            allowedRoles.add('Temporary Clerk');
            allowedRoles.add('License Service Provider');
            allowedRoles.add('Not Applicable');
            allowedRoles.add('Board Director');
            

            Account accOwnAccount = new Account();
            String currentName='';
            User usrData = LPI_WithoutSharingUtility.getUserRecordDetailWithoutSharing(Userinfo.getUserId());
            List<Account> accountList = LPI_AccountDAO.getAccountListByDynamicQuery(
                new List<String>{'Id','SelectedAccountId__c','Name','RecordType.DeveloperName', 'Person_Account_For_Business__c'},
                'Id = \''+usrData.AccountId +'\'',1,null,null);
            if(!accountList.isEmpty()){
                currentName = accountList[0].Name;
                accOwnAccount.Id = accountList[0].Id;
                accOwnAccount.Name = 'Switch to Personal Account';
                if(accountList[0].SelectedAccountId__c != null){
                    //Again query on account because selected account field is text not lookup
                    List<Account> getAccountData = LPI_AccountDAO.getAccountListByDynamicQuery(
                    new List<String>{'Id','Name'},
                    'Id = \''+accountList[0].SelectedAccountId__c +'\'',1,null,null);
                    if(!getAccountData.isEmpty()){
                        resultMap.put('accInfo', getAccountData[0]);
                    }else{
                        resultMap.put('accInfo', null);
                    }
                    resultMap.put('businessAccount', accountList[0].Person_Account_For_Business__c);
                }else{
                    // Always default to Individual/Person Account so portal never shows
                    // the Select Account Type modal on login (avoids flicker + reload).
                    resultMap.put('accInfo', new Account(Id = accountList[0].Id, Name = accountList[0].Name));
                    Account accountUpdateRec = new Account();
                    accountUpdateRec.Id = accountList[0].Id;
                    accountUpdateRec.SelectedAccountId__c = accountList[0].Id;
                    LPI_WithoutSharingUtility.updateSObject(accountUpdateRec);
                }
            }

            Set<Id> accountIdSet = new Set<Id>();
            List<Account> accList = new List<Account>();
            Account otherAccount;
            String fieldsToQueryACRs = 'Id, Related_From__c,Related_From__r.Name,Related_From__r.SelectedAccountId__c';
		    String whereClauseForRelationship = 'Related_To__c = \'' + String.escapeSingleQuotes(usrData.AccountId) + '\''+
                            ' AND Roles__c IN '+ LPI_ServiceUtility.getStringValuesByList(allowedRoles) + 
                            ' AND Start_Date__c != NULL '+
							' AND EndDate__c = NULL ';

            //Set<Id> relatedFromIdSet = new Set<Id>();
            Map<Id,Account> relatedFromIdMap = new  Map<Id,Account>();
            for(Business_Relationships__c acrList : new LPI_BusinessRelationshipDAO.LPI_BusinessRelationshipsWithoutSharingDAO().getBusinessRelationshipsByDymanicQuery(
                fieldsToQueryACRs,
                whereClauseForRelationship, 
                null,null,null
            )){
                if(acrList.Related_From__c != usrData.AccountId){
                    otherAccount = new Account();
                    otherAccount.Id = acrList.Related_From__c;
                    otherAccount.Name = acrList.Related_From__r.Name;
                    /*
                    if(!relatedFromIdSet.contains(acrList.Related_From__c)){
                        relatedFromIdSet.add(acrList.Related_From__c);
                        accList.add(otherAccount);
                    }
                    */
                    if(!relatedFromIdMap.containsKey(acrList.Related_From__c)){
                        relatedFromIdMap.put(acrList.Related_From__c,otherAccount );
                    }
                }
            }

            if(LPI_ServiceUtility.getStringValuesBySet(relatedFromIdMap.keySet()) != null){
                //To Check the access of account
                accList = LPI_AccountDAO.getAccountListByDynamicQuery( 
                    new List<String>{'Id','Name'},
                    'Id IN '+ LPI_ServiceUtility.getStringValuesBySet(relatedFromIdMap.keySet()) , null, null, null
                );
            }
            
            if(accList.isEmpty()){
                accList.add(accOwnAccount);
                // accOwnAccount.Name = currentName;
                resultMap.put('accInfo', new Account(Id = accOwnAccount.Id,Name = currentName));
                if(accOwnAccount.SelectedAccountId__c == null){
                    Account accountUpdateRec = new Account();
                    accountUpdateRec.Id = accOwnAccount.Id;
                    accountUpdateRec.SelectedAccountId__c = accOwnAccount.Id;
                    LPI_WithoutSharingUtility.updateSObject(accountUpdateRec);
                }
            }else{
                accList.add(0, accOwnAccount);
                Account headerAccount = new Account();
                headerAccount.Name = 'Select Business Account';
                accList.add(1,headerAccount);
            }
            resultMap.put('accList', accList);
            system.debug('@resultMap '+resultMap);
            return resultMap;
        } catch (Exception e) {
            LPI_ExceptionManager.logException(
                'LPI_FCDashboardProfileCompletion',
                'getAcrRecords',
                e
            );
            throw new AuraHandledException(e.getMessage()+ e.getStackTraceString());
        }
    }
    
    /*
    @author : Vipin Agarwal 
    @BuildDate : 29th Dec, 2022
    @description : This method is used to update the selected ACR account id on Logged in account 
    @params : String accountId
    @return : void
    */
    @AuraEnabled
    public static void updateAcrSelectedOnParentAccount(String accountId) {
        try {
            User usrData = LPI_WithoutSharingUtility.getUserRecordDetailWithoutSharing(Userinfo.getUserId());
            List<Account> accountRecordList = 
                getAcrRecords().containsKey('accList') 
                ? (List<Account>)(getAcrRecords().get('accList')) 
                : new List<Account>();
           	Boolean accountFound = false;
            for(Account accountRecord : accountRecordList){
                if(accountRecord.Id == (Id)accountId){
                    accountFound = true;
                    break;
				}
            }
            if(accountFound){
                List < Account > accountList = new List < Account > ();
                Account acc = new Account();
                acc.Id = usrData.AccountId;
                acc.SelectedAccountId__c = accountId;
                if (!String.isBlank(accountId)) {
                    accountList.add(acc);
                    //MODPR_DML.doUpdate(accountList);
                    LPI_WithoutSharingUtility.updateSObject(acc);
                } 
            }else{
                throw new AuraHandledException('Please select a valid account!');
            }
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getStackTraceString());
        }
    }

    /**
     * @description Portal header notifications facade.
     *              Entry point uses this already-enabled class so Experience Cloud users
     *              can call notifications without separate Apex class access grants.
     * @param language Optional portal language (en_US or fr).
     */
    @AuraEnabled
    public static Map<String, Object> getHeaderNotifications(String language) {
        return LPI_NotificationController.getHeaderNotifications(language);
    }

    /**
     * @description Marks header notifications as read (facade for portal users).
     */
    @AuraEnabled
    public static void markHeaderNotificationsRead(List<Id> notificationIds) {
        LPI_NotificationController.markHeaderNotificationsRead(notificationIds);
    }

}