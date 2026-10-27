/**
 * @author                      : Kishore
 * @since                       : 23 Jan, 2023
 * @description                 : This class contains DAO methods for Site object
 * @last modified by            : Amit Agrawal
 * @last modified date          : (Add if modified by you)
 * @last modified details       : (Add if modified by you)
 */
public with sharing class LPI_OmniProcessDAO {
    
    /**
     * @author                      : Kishore
     * @since                       : 
     * @description                 : Dynamic Query Get Site fields by different where clauses.
     * @param  fields             	: fields with (,) separated
     * @param  whereClause          : where condition (Ex: Name = 'Nitesh' AND Status = 'Active')
     * @param  limitValue          	: any limit otherwise pass null
     * @param  sortingByFields      : fields name from which you have to sort otherwise pass null
     * @param  sortingOrder      	: order of sorting (asc or desc) accept only two value otehr wise pass null
     * @last modified by            : Amit Agrawal
     * @last modified date          : (Add if modified by you)
     * @last modified details       : (Add if modified by you)
     */
    public static List<OmniProcess> getOmniProcessByDymanicQuery(String fields,
                                                      String whereClause,
                                                      String limitValue,
                                                      String sortingByFields,
                                                      String sortingOrder){

        String query = 'SELECT ';
        query += fields;
        query += ' FROM OmniProcess ';
        query += 'WHERE ' + whereClause;
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
     * @description       : Without Security Inner class for OmniProcess
     *                      
     * @author            : Nitesh Garg
     * @last modified on  : 04-11-2024
     * @last modified by  : Amit Agrawal
    **/
    public without sharing class LPI_OmniProcessWithoutSharingDAO {
	
        /**
     * @author                      : Nitesh Garg
     * @since                       : 
     * @description                 : Dynamic Query Get OmniProcess fields by different where clauses.
     * @param  fields             	: fields with (,) separated
     * @param  whereClause          : where condition (Ex: Name = 'Nitesh' AND Status = 'Active')
     * @param  limitValue          	: any limit otherwise pass null
     * @param  sortingByFields      : fields name from which you have to sort otherwise pass null
     * @param  sortingOrder      	: order of sorting (asc or desc) accept only two value otehr wise pass null
     * @last modified by            : Amit Agrawal
     * @last modified date          : (Add if modified by you)
     * @last modified details       : (Add if modified by you)
     */
    public List<OmniProcess> getOmniProcessByDymanicQuery(String fields,
                                            String whereClause,
                                            String limitValue,
                                            String sortingByFields,
                                            String sortingOrder){

        String query = 'SELECT ';
        query += fields;
        query += ' FROM OmniProcess ';
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