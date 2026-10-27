/**
 * @description       :  DAO class for querying PersonEducation
 * @author            : Nitesh Garg
 * @group             :
 * @last modified on  : 05-02-2024
 * @last modified by  : MTX Group Inc.
**/
public with sharing class LPI_PersonEducationDAO {
    /**
     * @author                      : Nitesh Garg
     * @since                       : 
     * @description                 : Dynamic Query Get PersonEducation fields by different where clauses.
     * @param  fields             	: fields with (,) separated
     * @param  whereClause          : where condition (Ex: Name = 'Nitesh' AND Status = 'Active')
     * @param  limitValue          	: any limit otherwise pass null
     * @param  sortingByFields      : fields name from which you have to sort otherwise pass null
     * @param  sortingOrder      	: order of sorting (asc or desc) accept only two value otehr wise pass null
	 * @last modified by            : MTX Group Inc.
	 * @last modified date          : May 24, 2023
	 * @last modified details       : Added conditional operator for limitValue parameter
     */
    public static List<PersonEducation> getPersonEducationByDymanicQuery(String fields, String whereClause, String limitValue, 
                                                                            String sortingByFields, String sortingOrder) {
        String query = 'SELECT ';
        query += fields;
        query += ' FROM PersonEducation ';
        query += 'WHERE ' + whereClause + ' WITH SECURITY_ENFORCED ';
        if (sortingByFields != null) {
        	query += ' ORDER BY ' + sortingByFields;
            if (sortingOrder != null) {
                query += ' ' + sortingOrder + ' ';
            }
        }
        query += ' LIMIT ' + (limitValue != null ? limitValue : '50000');                                                                                                                                                     
        return Database.query(query);
    }

    /****************************************** Without Security SOQL STARTS **************************************************/

    /**
     * @description       : Without Security Inner class for PersonEducation
     *                      
     * @author            : Nitesh Garg
     * @last modified on  : 05-02-2024
     * @last modified by  : MTX Group Inc.
    **/
    public without sharing class LPI_PersonEducationWithoutSharingDAO {
        /**
         * @author                      : Nitesh Garg
         * @since                       : 
         * @description                 : Dynamic Query Get PersonEducation fields by different where clauses.
         * @param  fields             	: fields with (,) separated
         * @param  whereClause          : where condition (Ex: Name = 'Nitesh' AND Status = 'Active')
         * @param  limitValue          	: any limit otherwise pass null
         * @param  sortingByFields      : fields name from which you have to sort otherwise pass null
         * @param  sortingOrder      	: order of sorting (asc or desc) accept only two value otehr wise pass null
         * @last modified by            : MTX Group Inc.
         * @last modified date          : May 24, 2023
         * @last modified details       : Added conditional operator for limitValue parameter
         */
        public List<PersonEducation> getPersonEducationByDymanicQuery(String fields, String whereClause, String limitValue, 
                                                                        String sortingByFields, String sortingOrder) {
            String query = 'SELECT ';
            query += fields;
            query += ' FROM PersonEducation ';
            query += 'WHERE ' + whereClause + ' WITH SECURITY_ENFORCED ';
            if (sortingByFields != null) {
                query += ' ORDER BY ' + sortingByFields;
                if (sortingOrder != null) {
                    query += ' ' + sortingOrder + ' ';
                }
            }
            query += ' LIMIT ' + (limitValue != null ? limitValue : '50000');                                                                                                                                                    
            return Database.query(query);
        }    
    }
}