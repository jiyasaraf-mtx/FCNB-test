/**
 * @description       : 
 * @author            : MTX Group Product Team
 * @group             : 
 * @last modified on  : 07-26-2024
 * @last modified by  : MTX Group Product Team
**/
public without sharing class LPI_ComplaintCaseDao {
    /**
     * @description : Get ComplaintCase records by different where clauses and different fields.
     * @author MTX Group Product Team
     * @param whereClause
     * @return List<ComplaintCase>
     **/
    public static List<ComplaintCase> fetchComplaintCaseRecords(
        String fieldsToQuery,
        String whereClause,
        String limitValue,
        String orderByClause
    ) {
        String query = 'SELECT ' + fieldsToQuery + ' FROM ComplaintCase  WHERE ' + whereClause;
        if (String.isNotBlank(orderByClause)) {
            query += ' ORDER BY  ' + orderByClause;
        }
        query += ' LIMIT ' + (String.isNotBlank(limitValue) ? limitValue : '50000');                                                                                                                                                    
        return Database.query(query);
    }
      /**
     * @description       : Without Security Inner class for ComplaintCase
     *                      
     * @author            : MTX Group Product Team
     * @last modified on  : 07-26-2024
     * @last modified by  : MTX Group Product Team
    **/
    public without sharing class LPI_ComplaintCaseWithoutSharingDAO {
	
    /**
     * @author                      : MTX Group Product Team
     * @since                       : 
     * @description                 : Dynamic Query Get ComplaintCase fields by different where clauses.
     * @param  fields             	: fields with (,) separated
     * @param  whereClause          : where condition (Ex: Name = 'Nitesh' AND Status = 'Active')
     * @param  limitValue          	: any limit otherwise pass null
     * @param  sortingByFields      : fields name from which you have to sort otherwise pass null
     * @param  sortingOrder      	: order of sorting (asc or desc) accept only two value otehr wise pass null
     * @last modified by            : MTX Group Product Team
     * @last modified date          : (Add if modified by you)
     * @last modified details       : (Add if modified by you)
     */
    public List<ComplaintCase> getComplaintCaseByDymanicQuery(String fields, String whereClause,
                                                                                String limitValue,
                                                                               	String sortingByFields,
                                                                               	String sortingOrder){
        String query = 'SELECT ';
        query += fields;
        query += ' FROM ComplaintCase ';
        query += 'WHERE ' + whereClause + ' WITH SECURITY_ENFORCED ';
        if(sortingByFields != null){
        	query += ' ORDER BY ' + sortingByFields;
            if(sortingOrder != null){
                query += ' ' + sortingOrder + ' ';
            }
        }                                                                             
        query += ' LIMIT ' + (String.isNotBlank(limitValue) ? limitValue : '50000');                                                                                                                                                    
        return Database.query(query);
    }
    	
    /**
     * @author                      : MTX Group Product Team
     * @since                       : 
     * @description                 : Dynamic Query Get ComplaintCase fields by different where clauses without Security Enforced.
     * @param  fields             	: fields with (,) separated
     * @param  whereClause          : where condition (Ex: Name = 'Nitesh' AND Status = 'Active')
     * @param  limitValue          	: any limit otherwise pass null
     * @param  sortingByFields      : fields name from which you have to sort otherwise pass null
     * @param  sortingOrder      	: order of sorting (asc or desc) accept only two value otehr wise pass null
     * @last modified by            : MTX Group Product Team
     * @last modified date          : (Add if modified by you)
     * @last modified details       : (Add if modified by you)
     */
    public List<ComplaintCase> getCompCaseByDymanicQueryWithoutSecurityEnforced(String fields, String whereClause,
                                                                                String limitValue,
                                                                               	String sortingByFields,
                                                                               	String sortingOrder){
        String query = 'SELECT ';
        query += fields;
        query += ' FROM ComplaintCase ';
        query += 'WHERE ' + whereClause ;
        if(sortingByFields != null){
        	query += ' ORDER BY ' + sortingByFields;
            if(sortingOrder != null){
                query += ' ' + sortingOrder + ' ';
            }
        }                                                                             
        query += ' LIMIT ' + (String.isNotBlank(limitValue) ? limitValue : '50000');                                                                                                                                                   
        return Database.query(query);
    }
        
    }
}