/**
 * @description       : Controller for Employee detils on visit.
 * @author            : MTX Group Product Team
 * @group             : 
 * @last modified on  : 07-26-2024
 * @last modified by  : MTX Group Product Team
**/
public with sharing class LPI_VisitController {

    public static final List<String> PROFILE_NAME_LIST = new List<String>{'System Administrator','Inspectors'};
    

     /**
	 * @author                      : MTX Group Product Team
	 * @since                       : 24 Nov, 2023
	 * @description                 : This method return the List of Inspection question and inspection content records
	 * @last modified by            : MTX Group Product Team
	 * @last modified date          : (Add if modified by you)
	 * @last modified details       : (Add if modified by you)
	 */
    @AuraEnabled(cacheable=true)
    public static Map<String,List<Object>> getInscpetcionQuestion(String recordId){
        try {
            String insContFieldNames = '';
            Map<String,List<Object>> combinedDataMap = new Map<String,List<Object>>();
            List<Visit> visitAccountId = LPI_VisitControllerDAO.getVisitListByDynamicQueryWithoutSecurity(new List<String>{'Id,License_Type__c,Status__c'},'Id =\''+ String.escapeSingleQuotes(recordId)+  '\'',1,null,null);
            System.debug('Visit...'+visitAccountId);
            if (visitAccountId.isEmpty() || String.isBlank(visitAccountId[0].License_Type__c)) {
                return null;
            }

            
            String fields = 'Id, Inspection_Questions__c';
            String whereClause = 'Name = \'' + visitAccountId[0].License_Type__c +'\'';

            LPI_RegulatoryAuthorizationTypeDAO.LPI_RegulatoryAuthorizationTypeWithoutSharingDAO getRATRecord= new LPI_RegulatoryAuthorizationTypeDAO.LPI_RegulatoryAuthorizationTypeWithoutSharingDAO();
            List<RegulatoryAuthorizationType> ratInspectionQuestionRec = getRATRecord.getRegAuthTypeWithoutSecurity(fields, whereClause, null, null, null);
            System.debug('RAT...'+ratInspectionQuestionRec);
            if(ratInspectionQuestionRec.isEmpty() || ratInspectionQuestionRec[0].Inspection_Questions__c == null){
                return null;
            }else{
                combinedDataMap.put('ratInspectionQuestionRec', ratInspectionQuestionRec);
                insContFieldNames = extractApiNames(ratInspectionQuestionRec[0].Inspection_Questions__c);
            }
            String inspectionContentfields = 'Id,Name,'+insContFieldNames;
            String inspectionContentwhereClause = 'Inspection__c =\''+ String.escapeSingleQuotes(recordId)+  '\'';
            List<Inspection_Content__c> inspectionContentList = LPI_InspectionContentDAO.getInspectionContentByDynamicQueryWithoutSecurity(inspectionContentfields,inspectionContentwhereClause,null,'CreatedDate','DESC');
            System.debug('inspectionContentList...'+inspectionContentList);
            List<User> userList = LPI_UserDao.getUserByDymanicQueryWithoutSecurityEnforced('Id,Profile.Name','Id = \''+Userinfo.getuserId() + '\'',null,null,null);

            combinedDataMap.put('allowedToCreate',new List<Object>{PROFILE_NAME_LIST.contains(userList[0].Profile.Name) && visitAccountId[0].Status__c == 'InProgress'});
            System.debug('combinedDataMap...'+combinedDataMap);
            if(inspectionContentList.isEmpty()){
                return combinedDataMap;
            }
            combinedDataMap.put('inspectionContentList',inspectionContentList);
            return combinedDataMap;
        } catch(Exception ex) {
            LPI_ExceptionManager.logException(
                'LPI_VisitController',
                'getInscpetcionQuestion',
                ex
            );
            throw new AuraHandledException(ex.getMessage());
        }
    }

    //To retrive field names from Inspection_Questions__c json
    public static String extractApiNames(String jsonString) {
        Map<String,Object> mp = (Map<String,Object>) JSON.deserializeUntyped(jsonString);

        List<Object> jsonList = (List<Object>)mp.get('form');
        List<String> apiNames = new List<String>();

        for (Object element : jsonList) {
            if (element instanceof Map<String, Object>) {
                Map<String, Object> jsonMap = (Map<String, Object>)element;
                if (jsonMap.containsKey('apiName')) {
                    apiNames.add((String)jsonMap.get('apiName'));
                }
            }
        }

        return String.join(apiNames, ',');
    }

    /**
	 * @author                      : MTX Group Product Team
	 * @since                       : 29 Nov, 2023
	 * @description                 : This method return the List of business relationship records based on roles
	 * @last modified by            : MTX Group Product Team
	 * @last modified date          : (Add if modified by you)
	 * @last modified details       : (Add if modified by you)
	 */
    @AuraEnabled
    public static List<Business_Relationships__c> getEmployeeDetails(String recordId){

        if(String.isBlank(recordId)) {
            return null;
        }

        List<Visit> visitAccountId = LPI_VisitControllerDAO.getVisitListByDynamicQueryWithoutSecurity(new List<String>{'Id,AccountId'},'Id =\''+String.escapeSingleQuotes(recordId)+'\'',1,null,null);
        if (visitAccountId.isEmpty()) {
            return null;
        }
        if( visitAccountId[0].AccountId != null){
        String fields = 'Id, Name, IsActive__c, EndDate__c, Related_To__r.Name, Related_To__c, Roles__c';
        String whereClause = 'Related_From__c = \'' + visitAccountId[0].AccountId +'\''
        + 'AND IsActive__c = true AND EndDate__c = null AND (Roles__c = \'Owner\' OR Roles__c = \'Employee\' OR Roles__c = \'Funeral Establishment Employee\' OR Roles__c = \'Designated Incharge\')';
        List<Business_Relationships__c> businessRelationshipsRecord = LPI_BusinessRelationshipDAO.fetchBusinessRelationshipRecords(
            fields, whereClause, null, null, null);

        if(businessRelationshipsRecord.isEmpty()){
            return null;
        }

        return businessRelationshipsRecord;}
        else{
            return null;
        }
    }
}