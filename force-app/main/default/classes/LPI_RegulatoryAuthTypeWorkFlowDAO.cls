/**
 * @author                      : Milanjeet Singh
 * @since                       : 17 Jan, 2023
 * @description                 : This class contains DAO methods for Regulatory_Auth_Type_WorkFlow__c object
 * @last modified by            : Ayush Dev
 * @last modified date          : (Add if modified by you)
 * @last modified details       : (Add if modified by you)
 */
public with sharing class LPI_RegulatoryAuthTypeWorkFlowDAO {
    
    /**
     * @description : Method to fetch Regulatory_Auth_Type_WorkFlow__c records.
     * @author Mohit Karani | 01-22-2023
     * @param fieldsToQuery
     * @param whereClause
     * @param limitValue
     * @param orderByClause
     * @return List<Regulatory_Auth_Type_WorkFlow__c>
     **/
    public static List<Regulatory_Auth_Type_WorkFlow__c> getRegAuthWorkflowRecs(
        String fieldsToQuery,
        String whereClause,
        String limitValue,
        String orderByClause) {
        String query = 'SELECT ' + fieldsToQuery;
        query += ' FROM Regulatory_Auth_Type_WorkFlow__c';
        query += ' WHERE ' + whereClause + ' WITH SECURITY_ENFORCED';
        if (String.isNotBlank(orderByClause)) {
            query += ' ORDER BY  ' + orderByClause;
        }
        if (String.isNotBlank(limitValue)) {
            query += ' LIMIT ' + (limitValue != null ? limitValue : '50000');
        }
        return Database.query(query);
    }
    /**
     * @author                      : Milanjeet Singh
     * @since                       : 11 Jan, 2023
     * @description                 : This method is to get the Regulatory_Auth_Type_WorkFlow__c config records by RAT Type Ids and Record Type Dev Name
     * @param  setRATId             : Takes Set of RAT Id
     * @param  recordTypeDevName    : Takes Record Type Developer Name as String
     * @return                      : returns List<Regulatory_Auth_Type_WorkFlow__c> by RAT Id and Record Type Dev Name
     * @last modified by            : Ayush Dev
     * @last modified date          : (Add if modified by you)
     * @last modified details       : (Add if modified by you)
     */
    public static List<Regulatory_Auth_Type_WorkFlow__c> getRATWorkflowByRATIdAndRecordTypeDevName(Set<Id> setRATId, String recordTypeDevName){
        return [
            SELECT
                ID, 
                Workflow__c, 
                Type__c, 
            	Sub_Type__c,
                Regulatory_Authorization_Type__c
            FROM
                Regulatory_Auth_Type_WorkFlow__c
            WHERE
                Regulatory_Authorization_Type__c IN :setRATId 
                AND RecordType.DeveloperName = :recordTypeDevName
            WITH SECURITY_ENFORCED
        ];
    }
    /****************************************** Without Security SOQL STARTS **************************************************/

    /**
     * @description       : Without Security Inner class for Regulatory_Auth_Type_WorkFlow__c
     *                      
     * @author            : Nitesh Garg
     * @last modified on  : 07-12-2024
     * @last modified by  : Ayush Dev
    **/
    public without sharing class LPI_RegAuthTypeWorkFlowWithoutSharingDAO {
	
        /**
         * @author                      : Nitesh Garg
         * @since                       : 
         * @description                 : Dynamic Query Get Regulatory_Auth_Type_WorkFlow__c fields by different where clauses.
         * @param  fields             	: fields with (,) separated
         * @param  whereClause          : where condition (Ex: Name = 'Nitesh' AND Status = 'Active')
         * @param  limitValue          	: any limit otherwise pass null
         * @param  sortingByFields      : fields name from which you have to sort otherwise pass null
         * @param  sortingOrder      	: order of sorting (asc or desc) accept only two value otehr wise pass null
         * @last modified by            : Ayush Dev
         * @last modified date          : (Add if modified by you)
         * @last modified details       : (Add if modified by you)
         */
        // public List<Regulatory_Auth_Type_WorkFlow__c> getRegulatoryAuthTypeWorkFlowByDymanicQuery(String fields,
        //                                                                             String whereClause,
        //                                                                             String limitValue,
        //                                                                             String sortingByFields,
        //                                                                             String sortingOrder){

        //     String query = 'SELECT ';
        //     query += fields;
        //     query += ' FROM Regulatory_Auth_Type_WorkFlow__c ';
        //     query += 'WHERE ' + whereClause + ' WITH SECURITY_ENFORCED ';
        //     if(sortingByFields != null){
        //         query += ' ORDER BY ' + sortingByFields;
        //         if(sortingOrder != null){
        //             query += ' ' + sortingOrder + ' ';
        //         }
        //     }                                                                             
        //     if(limitValue != null){
        //         query += ' LIMIT ' + (limitValue != null ? limitValue : '50000');
        //     }                                                                                                                                                       
        //     return Database.query(query);
        // }
    }
}