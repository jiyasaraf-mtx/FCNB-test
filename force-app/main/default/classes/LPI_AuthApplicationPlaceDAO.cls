/**
 * @author                      : MTX Group Product Team
 * @since                       : 17 Jan, 2023
 * @description                 : This class contains DAO methods for AuthApplicationPlace object
 * @last modified by            : MTX Group Product Team
 * @last modified date          : (Add if modified by you)
 * @last modified details       : (Add if modified by you)
 */
public with sharing class LPI_AuthApplicationPlaceDAO {
    /**
     * @author                      : MTX Group Product Team
     * @since                       : 
     * @description                 : Dynamic Query Get AuthApplicationPlace fields by different where clauses.
     * @param  fields             	: fields with (,) separated
     * @param  whereClause          : where condition (Ex: Name = 'Nitesh' AND Status = 'Active')
     * @param  limitValue          	: any limit otherwise pass null
     * @param  sortingByFields      : fields name from which you have to sort otherwise pass null
     * @param  sortingOrder      	: order of sorting (asc or desc) accept only two value otehr wise pass null
     * @last modified by            : MTX Group Product Team
     * @last modified date          : (Add if modified by you)
     * @last modified details       : (Add if modified by you)
     */
    public static List<AuthApplicationPlace> getAuthApplicationPlaceByDymanicQuery(String fields,
                                                                                String whereClause,
                                                                                String limitValue,
                                                                               	String sortingByFields,
                                                                               	String sortingOrder){

        String query = 'SELECT ';
        query += fields;
        query += ' FROM AuthApplicationPlace ';
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
        system.debug('------>+query'+query);                                                                                                                                                   
        return Database.query(query);
    }

    /**
    * @description : Method to query AuthApplicationPlace without adding SECURITY CHECK.
    * @author MTX Group Product Team
    * @param fields 
    * @param whereClause 
    * @param limitValue 
    * @param sortingByFields 
    * @param sortingOrder 
    * @return List<AuthApplicationPlace> 
    **/
    public static List<AuthApplicationPlace> getAuthApplicationPlaceByDymanicQueryWithoutSecurity(String fields,
                                                                                String whereClause,
                                                                                String limitValue,
                                                                               	String sortingByFields,
                                                                               	String sortingOrder){

        String query = 'SELECT ';
        query += fields;
        query += ' FROM AuthApplicationPlace ';
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

	/**
     * @author                      : MTX Group Product Team
     * @since                       : 17 Jan, 2023
     * @description                 : This method return the List of AuthApplicationPlace records by ID
     * @param  setOfAuthorizationIds: Set of Authorization Id
     * @return                      : List<AuthApplicationPlace>
     * @last modified by            : MTX Group Product Team
     * @last modified date          : (Add if modified by you)
     * @last modified details       : (Add if modified by you)
     */
    public static List<AuthApplicationPlace> getAuthApplicationPlaceByAuthorizationIds(Set<Id> setOfAuthorizationIds){
        return [
            SELECT 
            	Id,
            	AuthorizationId,
            	PlaceId
			FROM 
            	AuthApplicationPlace
			WHERE 
            	AuthorizationId  IN :setOfAuthorizationIds
			WITH SECURITY_ENFORCED
        ];
    }

    /**
     * @author                      : MTX Group Product Team
     * @since                       : 04 May, 2023
     * @description                 : This method return the List of AuthApplicationPlace records by IA/BLA Ids
     * @param  setOfRgltyAuthApplicationIds: Set of RgltyAuthApplicationId
     * @return                      : List<AuthApplicationPlace>
     * @last modified by            : MTX Group Product Team
     * @last modified date          : (Add if modified by you)
     * @last modified details       : (Add if modified by you)
     */
    public static List<AuthApplicationPlace> getAuthApplicationPlaceByRgltyAuthApplicationIds(Set<Id> setOfRgltyAuthApplicationIds){
        return [
            SELECT 
            	Id,
            	AuthorizationId,
            	PlaceId
			FROM 
            	AuthApplicationPlace
			WHERE 
            RgltyAuthApplicationId  IN :setOfRgltyAuthApplicationIds
			WITH SECURITY_ENFORCED
        ];
    }
    /****************************************** Without Security SOQL STARTS **************************************************/

    /**
     * @description       : Without Security Inner class for AuthApplicationPlace
     *                      
     * @author            : MTX Group Product Team
     * @last modified on  : 07-26-2024
     * @last modified by  : MTX Group Product Team
    **/
    public without sharing class LPI_AuthApplicationPlaceWithoutSharingDAO {
	
        /**
         * @author                      : MTX Group Product Team
         * @since                       : 
         * @description                 : Dynamic Query Get AuthApplicationPlace fields by different where clauses.
         * @param  fields             	: fields with (,) separated
         * @param  whereClause          : where condition (Ex: Name = 'Nitesh' AND Status = 'Active')
         * @param  limitValue          	: any limit otherwise pass null
         * @param  sortingByFields      : fields name from which you have to sort otherwise pass null
         * @param  sortingOrder      	: order of sorting (asc or desc) accept only two value otehr wise pass null
         * @last modified by            : MTX Group Product Team
         * @last modified date          : (Add if modified by you)
         * @last modified details       : (Add if modified by you)
         */
        public List<AuthApplicationPlace> getAuthApplicationPlaceByDymanicQuery(String fields,
                                                String whereClause,
                                                String limitValue,
                                                String sortingByFields,
                                                String sortingOrder){

            String query = 'SELECT ';
            query += fields;
            query += ' FROM AuthApplicationPlace ';
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
         * @since                       : 
         * @description                 : Dynamic Query Get AuthApplicationPlace fields by different where clauses without security.
         * @param  fields             	: fields with (,) separated
         * @param  whereClause          : where condition (Ex: Name = 'Nitesh' AND Status = 'Active')
         * @param  limitValue          	: any limit otherwise pass null
         * @param  sortingByFields      : fields name from which you have to sort otherwise pass null
         * @param  sortingOrder      	: order of sorting (asc or desc) accept only two value otehr wise pass null
         * @last modified by            : MTX Group Product Team
         * @last modified date          : (Add if modified by you)
         * @last modified details       : (Add if modified by you)
         */
        public List<AuthApplicationPlace> getAuthAppPlaceByDymQueryWithoutSecurity(String fields,
                                                String whereClause,
                                                String limitValue,
                                                String sortingByFields,
                                                String sortingOrder){

            String query = 'SELECT ';
            query += fields;
            query += ' FROM AuthApplicationPlace ';
            query += 'WHERE ' + whereClause;
            if(sortingByFields != null){
                query += ' ORDER BY ' + sortingByFields;
                if(sortingOrder != null){
                    query += ' ' + sortingOrder + ' ';
                }
            }                                                                             
            if(limitValue != null){
                query +=  ' LIMIT ' + (String.isNotBlank(limitValue) ? limitValue : '50000');
            }                                                                                                                                    
            return Database.query(query);
        }

        public List<AuthApplicationPlace> getAuthApplicationPlaceByAuthorizationIdsWithoutSecurity(Set<Id> setOfAuthorizationIds){
            return [
                SELECT 
                    Id,
                    AuthorizationId,
                    PlaceId
                FROM 
                    AuthApplicationPlace
                WHERE 
                    AuthorizationId  IN :setOfAuthorizationIds
                WITH SECURITY_ENFORCED
            ];
        }
    
    }
}