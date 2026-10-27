/**
 * @author                      : MTX Group Product Team
 * @since                       : 11 Jan, 2023
 * @description                 : This class contains DAO methods for Fees__c object
 * @last modified by            : MTX Group Product Team
 * @last modified date          : (Add if modified by you)
 * @last modified details       : (Add if modified by you)
 */
public with sharing class LPI_FeesDAO {
    /**
     * @author                      : Nitesh Garg
     * @since                       : 
     * @description                 : Dynamic Query Get Fees__c fields by different where clauses.
     * @param  fields             	: fields with (,) separated
     * @param  whereClause          : where condition (Ex: Name = 'Nitesh' AND Status = 'Active')
     * @param  limitValue          	: any limit otherwise pass null
     * @param  sortingByFields      : fields name from which you have to sort otherwise pass null
     * @param  sortingOrder      	: order of sorting (asc or desc) accept only two value otehr wise pass null
     * @last modified by            : MTX Group Product Team
     * @last modified date          : (Add if modified by you)
     * @last modified details       : (Add if modified by you)
     */
    public static List<Fees__c> getFeesByDymanicQuery(String fields,
                                                      String whereClause,
                                                      String limitValue,
                                                      String sortingByFields,
                                                      String sortingOrder){

        String query = 'SELECT ';
        query += fields;
        query += ' FROM Fees__c ';
        query += 'WHERE ' + whereClause + ' WITH SECURITY_ENFORCED ';
        if(sortingByFields != null){
        	query += ' ORDER BY ' + sortingByFields;
            if(sortingOrder != null){
                query += ' ' + sortingOrder + ' ';
            }
        }                                                                             
        if(limitValue != null){
        	query += ' LIMIT ' + (limitValue != null ? limitValue : '50000');
        }                                                                                                                                                       
        return Database.query(query);
    }
    /**
     * @author                      : MTX Group Product Team
     * @since                       : 11 Jan, 2023
     * @description                 : This method is to get the Fees config records by RAT Type Ids
     * @param  setRATTypeId         : Takes Set of RAT Type Ids
     * @return                      : returns List<Fees__c> associated to RAT
     * @last modified by            : MTX Group Product Team
     * @last modified date          : (Add if modified by you)
     * @last modified details       : (Add if modified by you)
     */
    public static List<Fees__c> getFeesDetailsByRATTypeId(Set<Id> setRATTypeId){
  return [
            SELECT
                Id, 
                Fee_Type__c, 
                Fee_Sub_Type__c,
                Fee_Amount__c, 
                Regulatory_Authorization_Type__c
            FROM
                Fees__c
            WHERE
                Regulatory_Authorization_Type__c  IN :setRATTypeId
            WITH SECURITY_ENFORCED
        ];
    }
    
    /**
     * @author                      : MTX Group Product Team
     * @since                       : 18 Jan, 2023
     * @description                 : This method is to get the Temp Fees records by PAR Ids
     * @param  setPARId         	: Takes Set of PAR Id's
     * @return                      : returns List<Temp_Fee__c> associated to RAT
     * @last modified by            : MTX Group Product Team
     * @last modified date          : (Add if modified by you)
     * @last modified details       : (Add if modified by you)
     */
    public static List<Temp_Fee__c> getTempFeesDetailsByParId(Set<Id> setPARId){
        return [
            SELECT
                Id, Name,	
                FeeAmount__c, 
                PreliminaryApplicationReference__c 
            FROM
                Temp_Fee__c
            WHERE
                PreliminaryApplicationReference__c   IN :setPARId
            WITH SECURITY_ENFORCED
        ];
    }
}