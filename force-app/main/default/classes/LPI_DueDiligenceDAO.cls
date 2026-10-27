/**
 * @author                      : Ayush Yadav
 * @since                       : 23 Jan, 2023
 * @description                 : This method contains DAO methods for Due_Diligence__c object
 * @last modified by            : MTX Group Inc.
 * @last modified date          : 
 * @last modified details       : 
 */
public with sharing class LPI_DueDiligenceDAO {
    /**
     * @author                      : Ayush Yadav
     * @since                       : 23 Jan, 2023
     * @description                 : Dynamic Query Get Due_Diligence__c fields by different where clauses.
     * @param  fields             	: fields with (,) separated
     * @param  whereClause          : where condition (Ex: Name = 'Ayush' AND Status = 'Active')
     * @param  limitValue          	: any limit otherwise pass null
     * @param  sortingByFields      : fields name from which you have to sort otherwise pass null
     * @param  sortingOrder      	: order of sorting (asc or desc) accept only two value otehr wise pass null
     * @last modified by            : MTX Group Inc.
     * @last modified date          : (Add if modified by you)
     * @last modified details       : (Add if modified by you)
     */
    public static List<Due_Diligence__c> getDueDiligenceByDymanicQuery(String fields,
                                                      String whereClause,
                                                      String limitValue,
                                                      String sortingByFields,
                                                      String sortingOrder){
        String query = 'SELECT ';
        query += fields;
        query += ' FROM Due_Diligence__c ';
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
    /****************************************** Without Security SOQL STARTS **************************************************/

    /**
     * @description       : Without Security Inner class for Due_Diligence__c
     *                      
     * @author            : Nitesh Garg
     * @last modified on  : 05-02-2024
     * @last modified by  : MTX Group Inc.
    **/
    public without sharing class LPI_DueDiligenceWithoutSharingDAO {
	
        /**
         * @author                      : Nitesh Garg
         * @since                       : 
         * @description                 : Dynamic Query Get Due_Diligence__c fields by different where clauses.
         * @param  fields             	: fields with (,) separated
         * @param  whereClause          : where condition (Ex: Name = 'Nitesh' AND Status = 'Active')
         * @param  limitValue          	: any limit otherwise pass null
         * @param  sortingByFields      : fields name from which you have to sort otherwise pass null
         * @param  sortingOrder      	: order of sorting (asc or desc) accept only two value otehr wise pass null
         * @last modified by            : MTX Group Inc.
         * @last modified date          : (Add if modified by you)
         * @last modified details       : (Add if modified by you)
         */
        public List<Due_Diligence__c> getDueDiligenceByDymanicQuery(String fields,
                                                String whereClause,
                                                String limitValue,
                                                String sortingByFields,
                                                String sortingOrder){

            String query = 'SELECT ';
            query += fields;
            query += ' FROM Due_Diligence__c ';
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
    }
}