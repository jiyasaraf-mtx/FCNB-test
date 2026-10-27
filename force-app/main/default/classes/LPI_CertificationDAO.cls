/**
 * @description       : DAO for Certification object.
 * @author            : MTX Group Product Team
 * @group             :
 * @last modified on  : 07-26-2024
 * @last modified by  : MTX Group Product Team
 **/

 public with sharing class LPI_CertificationDAO {
    /**
     * @description : Method to fetch Certification records.
     * @author MTX Group Product Team
     * @param fieldsToQuery
     * @param whereClause
     * @param limitValue
     * @param orderByClause
     * @return List<BoardCertification>
     **/    
    public static List<BoardCertification> getCertificationByDymanicQuery(
                                            String fieldsToQuery,
                                            String whereClause,
                                            String limitValue,
                                            String sortingByFields,
                                            String sortingOrder){        
        String query = 'SELECT ' + fieldsToQuery;
        query += ' FROM BoardCertification';
        query += ' WHERE ' + whereClause + ' WITH SECURITY_ENFORCED';
        if(sortingByFields != null){
        	query += ' ORDER BY ' + sortingByFields;
            if(sortingOrder != null){
                query += ' ' + sortingOrder + ' ';
            }
        }                                                                             
        query += ' LIMIT ' + (limitValue != null ? limitValue : '50000');            
        return Database.query(query);
    }
    /**
     * @author                      : MTX Group Product Team
     * @since                       : 17 Jul, 2023
     * @description                 : Without Security Inner class for BoardCertification Object
     * @return                      : List<BoardCertification>
     */
    public without sharing class LPI_CertificationWithOutSharingDAO {
        /**
         * @author                      : MTX Group Product Team
         * @since                       : 17 Jul, 2023
         * @description                 : This method return PreliminaryApplicationRef records by Regulatory Authorization Type Business Account Id and Amendment Type
         * @param  fieldsToQuery        : fields with (,) separated
         * @param  whereClause          : where condition (Ex: Name = 'Nitesh' AND Status = 'Active')
         * @param  limitValue          	: any limit otherwise pass null
         * @param  sortingByFields      : fields name from which you have to sort otherwise pass null
         * @param  sortingOrder      	: order of sorting (asc or desc) accept only two value otehr wise pass null
         * @return                      : List<BoardCertification>
        */
       public List<BoardCertification> getCertificationByDymanicQueryWithoutSecurity(
        String fieldsToQuery,
        String whereClause,
        String limitValue,
        String sortingByFields,
        String sortingOrder){        
            String query = 'SELECT ' + fieldsToQuery;
            query += ' FROM BoardCertification';
            query += ' WHERE ' + whereClause;
            if(sortingByFields != null){
                query += ' ORDER BY ' + sortingByFields;
                if(sortingOrder != null){
                    query += ' ' + sortingOrder + ' ';
                }
            }                                                                             
            query += ' LIMIT ' + (limitValue != null ? limitValue : '50000');
            return Database.query(query);
        }
    }
}