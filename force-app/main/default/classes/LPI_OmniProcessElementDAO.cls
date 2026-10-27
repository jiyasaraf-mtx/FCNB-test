/**
 * @author                      : MTX Group Product Team
 * @since                       : 23 March, 2023
 * @description                 : This class contains DAO methods for OmniProcessElement object
 * @last modified by            : MTX Group Product Team
 * @last modified on            : 07-26-2024
 */
public with sharing class LPI_OmniProcessElementDAO {
    
    /**
     * @author                      : MTX Group Product Team
     * @since                       : 23 March, 2023
     * @description                 : Dynamic Query Get OmniProcessElement fields by different where clauses.
     * @param  fields             	: fields with (,) separated
     * @param  whereClause          : where condition (Ex: Name = 'Nitesh' AND Status = 'Active')
     * @param  limitValue          	: any limit otherwise pass null
     * @param  sortingByFields      : fields name from which you have to sort otherwise pass null
     * @param  sortingOrder      	: order of sorting (asc or desc) accept only two value otehr wise pass null
     * @last modified by            : MTX Group Product Team
     * @last modified on            : 07-26-2024
     */
    public static List<OmniProcessElement> getOmniProcessElementByDymanicQuery(String fields,
                                                      String whereClause,
                                                      String limitValue,
                                                      String sortingByFields,
                                                      String sortingOrder){

        String query = 'SELECT ';
        query += fields;
        query += ' FROM OmniProcessElement ';
        query += 'WHERE ' + whereClause;
        if(sortingByFields != null){
        	query += ' ORDER BY ' + sortingByFields;
            if(sortingOrder != null){
                query += ' ' + sortingOrder + ' ';
            }
        }                                                                             
        if(limitValue != null){
        	query += ' LIMIT ' + limitValue;
        } 
        return Database.query(query);
    }
}