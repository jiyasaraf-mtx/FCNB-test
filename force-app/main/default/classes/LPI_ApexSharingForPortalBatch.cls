/**
* @author              : MTX Group Product Team
* @since               : 09-Jan-2023
* @description         : This batch class is to give sharing to portal users (community plus)
* @history
* -------------------------------------------------------------------------------------------------------
* Version      Date                Author                  Details
*    1         08-Feb-2023      MTX Group Product Team        	Initial Developement
* -------------------------------------------------------------------------------------------------------
*/
public class LPI_ApexSharingForPortalBatch implements Database.Batchable<sObject> {
    public final static String ROLE_OWNER = 'Owner';
    public final static String ROLE_DESIGNATED_INCHARGE = 'Designated Incharge';
    public final static String ROLE_PERSON_ACCOUNT_FOR_BUSINESS = 'Person Account For Business';
    public final static String ROLE_AUTHORIZED_CONTACT = 'Authorized Contact';
    public final static String ROLE_CEO = 'CEO';
    public final static String ROLE_CHAIRPERSON = 'Chairperson';
    public final static String ROLE_CORPORATE_OFFICER = 'Corporate Officer';
    public final static String ROLE_DIRECTOR = 'Director';
    public final static String ROLE_PARTNER = 'Partner';
    public final static String ROLE_PRESIDENT = 'President';
    public final static String ROLE_SECRETARY = 'Secretary';
    public final static String ROLE_SENIOR_VICE_PRESIDENT = 'Senior Vice President';
    public final static String ROLE_SHAREHOLDER = 'Shareholder';
    public final static String ROLE_TREASURER = 'Treasurer';
    public final static String ROLE_VICE_PRESIDENT = 'Vice President';
    public final static String ROLE_OPERATING_MANAGER = 'Operating Manager';
    public final static String ROLE_MANAGER = 'Manager';
    public final static String ROLE_PRINCIPAL = 'Principal';
    public final static String ROLE_CFO_CHIEF_FINANCIAL_OFFICER = 'CFO (Chief Financial Officer)';
    public final static String ROLE_EXECUTIVE_VICE_PRESIDENT = 'Executive Vice President';
    public final static String ROLE_CONTROLLING_PERSON = 'Controlling Person';
    public final static String ROLE_COO = 'COO';
    public final static String ROLE_NOT_APPLICABLE = 'Not Applicable';


    public final static Set<String> rolesSet = new Set<String>{
        ROLE_OWNER,
        ROLE_DESIGNATED_INCHARGE,
        ROLE_PERSON_ACCOUNT_FOR_BUSINESS,
        ROLE_AUTHORIZED_CONTACT,

        //Corporate Officer Roles
        ROLE_CEO,
        ROLE_CHAIRPERSON,
        ROLE_CORPORATE_OFFICER,
        ROLE_DIRECTOR,
        ROLE_PARTNER,
        ROLE_PRESIDENT,
        ROLE_SECRETARY,
        ROLE_SENIOR_VICE_PRESIDENT,
        ROLE_SHAREHOLDER,
        ROLE_TREASURER,
        ROLE_VICE_PRESIDENT,
        ROLE_OPERATING_MANAGER,
        ROLE_MANAGER,
        ROLE_PRINCIPAL,
        ROLE_CFO_CHIEF_FINANCIAL_OFFICER,
        ROLE_EXECUTIVE_VICE_PRESIDENT,
        ROLE_CONTROLLING_PERSON,
        ROLE_COO,
        ROLE_NOT_APPLICABLE
    };

    public Database.QueryLocator start(Database.BatchableContext batchContext) {
        String queryString = ' SELECT Id, Related_From__c, Related_To__c FROM Business_Relationships__c WHERE Start_Date__c != NULL ';
        queryString += ' AND EndDate__c = NULL AND Related_To__c != NULL AND Skip_Sharing__c = false';
        queryString += ' AND Roles__c ' + ' IN: rolesSet ' ;
        queryString += ' AND Related_From__r.RecordType.DeveloperName ' + ' = \'' + LPI_ApexSharingUtility.ACCOUNT_RECORDTYPE_BUSINESS + '\'' ;

        return Database.getQueryLocator(queryString);
    }
    
    public void execute(Database.BatchableContext batchContext, List<sObject> records) {
        Map<Id,Set<Id>> giveAccRelatedObjAccessToChildAccSetMap = new Map<Id,Set<Id>>();
        Set<Id> giveAccessToAccountId = new Set<Id>();

        for(Business_Relationships__c br : (List<Business_Relationships__c>)records){
            if(!giveAccRelatedObjAccessToChildAccSetMap.containsKey(br.Related_From__c)){
                giveAccRelatedObjAccessToChildAccSetMap.put(br.Related_From__c, new Set<Id>());
            }
            giveAccRelatedObjAccessToChildAccSetMap.get(br.Related_From__c).add(br.Related_To__c);
            giveAccessToAccountId.add(br.Related_To__c);
        }
        
        if(!giveAccRelatedObjAccessToChildAccSetMap.isEmpty() && !giveAccessToAccountId.isEmpty()){
            LPI_ApexSharingUtility.giveAccessOfObjectsFromAccountIdFromBR(giveAccRelatedObjAccessToChildAccSetMap, giveAccessToAccountId);
        }
    }
    
    public void finish(Database.BatchableContext batchContext){}
}