/**
 * @author         : MTX Group Product Team
 * @since          : 29th dec, 2022
 * @description    : This class contains methods that executes automatically after performing CRUD operations on Account records
 */
public with sharing class LPI_AccountTriggerHelper {

    private static final String JURISIN_TRANSACTION_STATUS_READY_TO_SEND = 'Ready to Send';
    private static final String NCSBN_ELIGIBILITY_TO_TEST_ELIGIBLE = 'Eligible';
    private static final String JURISIN_TRANSACTION_CODE_03 = '03';
	private static final String JURISIN_TRANSACTION_CODE_04 = '04';
	private static final Set<String> JURISIN_TRANSACTION_CODE_SET = new Set<String>{
		JURISIN_TRANSACTION_CODE_03,
		JURISIN_TRANSACTION_CODE_04
	};
    private static final Set<String> NCLEX_EXAMINATION_STATUS_SET = new Set<String>{
		'Passed',
		'Failed'
	};
    private static String getClassName() {
        return 'LPI_AccountTriggerHelper';
    }

    /**
    * @description : Method to update Combined_Name__pc for PersonAccount records.
    * @author MTX Group Product Team
    * @param newList 
    * @param oldMap 
    **/
    public static void updateCombinedNameForPersonAccount(
        List<Account> newList,
        Map<Id, Account> oldMap
    ) {                
        for (Account acc : newList) {        
            if (
                acc.RecordTypeId !=
                LPI_LiteralConstant.PERSON_ACCOUNT_REC_TYPE_ID ||
                (oldMap != null &&
                oldMap.get(acc.Id).FirstName == acc.FirstName &&
                oldMap.get(acc.Id).MiddleName == acc.MiddleName) &&
                oldMap.get(acc.Id).LastName == acc.LastName &&
                (acc.Date_of_Birth__c != null && oldMap.get(acc.Id).Date_of_Birth__c == acc.Date_of_Birth__c)
            ) {                
                continue;
            }
    
            acc.Date_of_Birth_Present__c = (acc.Date_of_Birth__c != null);

            acc.FirstName =  (String.isNotBlank(acc.FirstName)?acc.FirstName.trim():acc.FirstName);
            acc.MiddleName = (String.isNotBlank(acc.MiddleName)?acc.MiddleName.trim():acc.MiddleName);  
            acc.LastName =   acc.LastName.trim();

            acc.Combined_Name__pc = String.isNotBlank(acc.FirstName) &&
                String.isNotBlank(acc.MiddleName)
                ? acc.FirstName + ' ' + acc.MiddleName + ' ' + acc.LastName
                : String.isNotBlank(acc.FirstName)
                      ? acc.FirstName + ' ' + acc.LastName
                      : String.isNotBlank(acc.MiddleName)
                            ? acc.MiddleName + ' ' + acc.LastName
                            : acc.LastName;

        }
    }

     /**
     * @author                      : MTX Group Product Team
     * @since                       : 13th Apr 2023
     * @description                 : This method will update the related RN/LPN Individual Applications Transaction code and Transaction status flag fields
     *                                if Email is updated on Person Account (S-47082)
     * @param recordsList           : Takes New List of List<Account> (Account Records)
     * @param mapOfOldRecords       : Takes Old Map of Map<Id, Account> (Account Records)
     * @return                      : `void`
     */
    public static void checkSSNDuplicate(List<Account> newList,Map<Id, Account> OldMap){
        Map<String, Account> ssnToAccountMap = new Map<String, Account>();
        for(Account acc : newList){
            if(OldMap != NULL && OldMap.get(acc.Id).Social_Security_Number__c !=null && OldMap.get(acc.Id).Social_Security_Number__c != acc.Social_Security_Number__c 
                && acc.Social_Security_Number__c != NULL){
                    ssnToAccountMap.put(acc.Social_Security_Number__c, acc);
            }
        }

        if(!ssnToAccountMap.isEmpty()){
            LPI_AccountDAO.LPI_AccountWithoutSharingDAO accObj = new LPI_AccountDAO.LPI_AccountWithoutSharingDAO();
            Set<String> setForFilter = ssnToAccountMap.keySet();
            String whereClause = '';
            for(String val : ssnToAccountMap.keySet()){
                whereClause = whereClause != '' ?  whereClause + ' OR ' : '';
                whereClause += ' Social_Security_Number__c = \'' + val + '\''; 
            }
            List<Account> accList = accObj.getAccountByDymanicQuery(
                'ID,Social_Security_Number__c',
                whereClause,
                null,
                null,
                null,
                setForFilter
            );

            if (!accList.isEmpty()) {
                ssnToAccountMap.get(accList[0].Social_Security_Number__c).addError('SSN number already Registered');
            }
        }
    }
    /**
     * @author                      : MTX Group Product Team
     * @since                       : 10th July 2023
     * @description                 : This method will delete the related business relationship records where Roles = Owner if the Entity_type__c is getting updated                             
     * @param recordsList           : Takes New List of List<Account> (Account Records)
     * @param mapOfOldRecords       : Takes Old Map of Map<Id, Account> (Account Records)
     * @return                      : `void`
     */
    public static void deleteBusinessRelationships(List<Account> newlist, Map<Id, Account> oldMap) {
        String OWNER = 'Owner';
        Set<Id> accountIds = new Set<Id>();        
        for (Account acc : newlist) {
            Account oldAcc = oldMap.get(acc.Id);       
            if (oldAcc.Entity_type__c != acc.Entity_type__c && acc.Entity_type__c != null) {
                accountIds.add(acc.Id);
            }
        }
        if (!accountIds.isEmpty()) {
            String fieldsToQueryACRs = 'Id';
            String whereClauseForRelationship = 'Roles__c = \'' + OWNER + '\' '+
                ' AND Start_Date__c != NULL ' +
                ' AND EndDate__c = NULL ' +
                'AND IsActive__c = false ' +
                'AND ( Related_From__c IN ' + LPI_ServiceUtility.getStringValuesBySet(accountIds) + 
                'OR Related_To__c IN ' +LPI_ServiceUtility.getStringValuesBySet(accountIds) +')';
            List < Business_Relationships__c > blRelationships = LPI_BusinessRelationshipDAO.fetchBusinessRelationshipRecords(fieldsToQueryACRs, whereClauseForRelationship, null, null, null);
            if (!blRelationships.isEmpty()) { 
                LPI_WithoutSharingUtility.deleteSObject(blRelationships);
            }
        }
    }

    /**
     * @author                      : MTX Group Product Team
     * @since                       : 10th July 2023
     * @description                 : This method give child account access to parent account roles                      
     * @param newlist               : Takes New List of List<Account> (Account Records)
     * @param oldMap                : Takes Old Map of Map<Id, Account> (Account Records)
     * @return                      : `void`
     */
    public static void manageAccessForParentAccount(List<Account> newlist, Map<Id,Account> oldMap){
        Map<Id,Id> accountIdToParentIdMap = new Map<Id,Id>();
        Map<Id,Id> accountIdToOldParentIdMap = new Map<Id,Id>();

        for(Account acc : newList){
            if(oldMap == NULL && acc.ParentId != NULL){
                accountIdToParentIdMap.put(acc.Id, acc.ParentId);    
            }
            if(oldMap != NULL && oldMap.get(acc.Id).ParentId != acc.ParentId){
                if(acc.ParentId != NULL){
                    accountIdToParentIdMap.put(acc.Id, acc.ParentId);    
                }
                if(oldMap.get(acc.Id).ParentId != NULL){
                    accountIdToOldParentIdMap.put(acc.Id, oldMap.get(acc.Id).ParentId);    
                }
            }
        }
        if(!accountIdToParentIdMap.isEmpty()){
            LPI_ApexSharingUtility.giveAccessBasedOnParentId(accountIdToParentIdMap);
        }
        if(!accountIdToOldParentIdMap.isEmpty()){
            LPI_ApexSharingUtility.removeAccessBasedOnParentId(accountIdToOldParentIdMap);
        }
    }

    /**
     * @author                      : MTX Group Product Team
     * @since                       : 5th Feb 2022
     * @description                 : This method update Business License status as Expired/Void and Sub status as Deceased                  
     * @param newlist               : Takes New List of List<Account> (Account Records)
     * @param oldMap                : Takes Old Map of Map<Id, Account> (Account Records)
     * @return                      : `void`
     */
    public static void updatingBLStatusByDateOfDeath(List<Account> newlist, Map<Id,Account> oldMap){
        try{
            List<BusinessLicense> blList = new List<BusinessLicense>();
            Set<Id> accIdSet = new Set<Id>();
            for(Account acc: newlist){
                if(acc.Date_of_Death__c != null && oldMap == null){
                    accIdSet.add(acc.Id);
                }else if(oldMap != null && oldMap.get(acc.Id).Date_of_Death__c != acc.Date_of_Death__c){
                    accIdSet.add(acc.Id);
                }
            }
            if(!accIdSet.isEmpty()){
                for(BusinessLicense bl : LPI_BusinessLicenseDAO.fetchBusinessLicenseRecords(
                    'Id,Status,License_Sub_status__c',
                    'AccountId IN ' + LPI_ServiceUtility.getStringValuesBySet(accIdSet)
                )){
                    bl.Status = 'Expired / Void';
                    bl.License_Sub_status__c = 'Deceased';
                    blList.add(bl);
                }
                if(!blList.isEmpty()){
                    LPI_TriggerHandler.bypass('LPI_BusinessLicenseTriggerHandler');
                    if (LPI_TriggerHandler.isBypassed('LPI_BusinessLicenseTriggerHandler')) {
                        LPI_WithoutSharingUtility.updateSObjectList(blList);
                    }
                    LPI_TriggerHandler.clearBypass('LPI_BusinessLicenseTriggerHandler');
                }
            }
        }catch (Exception e) {
            LPI_ExceptionManager.logException(
                'LPI_AccountTriggerHelper',
                'updatingBLStatusByDateOfDeath',
                e
            );
        }
    }
}