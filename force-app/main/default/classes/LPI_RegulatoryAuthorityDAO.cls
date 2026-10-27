/**
 * @description       :  DAO class for querying RegulatoryAuthority
 * @author            :  Piyush Aneja
 * @group             :
 * @last modified on  : 02-09-2023
 * @last modified by  : Mohit Karani
**/
public with sharing class LPI_RegulatoryAuthorityDAO {

    /**
     * @author                      : Piyush Aneja
     * @since                       : 
     * @description                 : Dynamic Query Get RegulatoryAuthority fields by different where clauses.
     * @param  fields             	: fields with (,) separated
     * @param  whereClause          : where condition (Ex: Name = 'Piyush' AND Status = 'Active')
     * @param  limitValue          	: any limit otherwise pass null
     * @param  sortingByFields      : fields name from which you have to sort otherwise pass null
     * @param  sortingOrder      	: order of sorting (asc or desc) accept only two value otehr wise pass null
     * @last modified by            : Mohit Karani
     * @last modified date          : (Add if modified by you)
     * @last modified details       : (Add if modified by you)
     */
    public static List<RegulatoryAuthority> getRegulatoryAuthorityByDymanicQuery(String fields,
                                                      String whereClause,
                                                      String limitValue,
                                                      String sortingByFields,
                                                      String sortingOrder){

        String query = 'SELECT ';
        query += fields;
        query += ' FROM RegulatoryAuthority ';
        query += 'WHERE ' + whereClause + ' WITH SECURITY_ENFORCED ';
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

    public without sharing class LPI_RegulatoryAuthorityWithoutSharingDAO{
        /**
        * @description : Get RegulatoryAuthority records in without sharing context.
        * @author Mohit Karani | 02-09-2023 
        * @param fields 
        * @param whereClause 
        * @param limitValue 
        * @param sortingByFields 
        * @param sortingOrder 
        * @return List<RegulatoryAuthority> 
        **/
        // Note: Do not add WITH SECURITY_ENFORCED as read permission cannot be given for this object to guest user.
        public List<RegulatoryAuthority> getRegulatoryAuthorityByDymanicQueryWithoutSharing(String fields,
        String whereClause,
        String limitValue,
        String sortingByFields,
        String sortingOrder){

        String query = 'SELECT ';
        query += fields;
        query += ' FROM RegulatoryAuthority ';
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
}