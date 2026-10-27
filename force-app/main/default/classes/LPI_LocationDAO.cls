/**
 * @author                      : MTX Group Product Team
 * @since                       : 17 Jan, 2023
 * @description                 : This class contains DAO methods for Location object
 * @last modified by            : MTX Group Product Team
 * @last modified date          : (Add if modified by you)
 * @last modified details       : (Add if modified by you)
 */
public with sharing class LPI_LocationDAO {
    /**
     * @author                      : MTX Group Product Team
     * @since                       : 
     * @description                 : Dynamic Query Get Schema.Location fields by different where clauses.
     * @param  fields             	: fields with (,) separated
     * @param  whereClause          : where condition (Ex: Name = 'Nitesh' AND Status = 'Active')
     * @param  limitValue          	: any limit otherwise pass null
     * @param  sortingByFields      : fields name from which you have to sort otherwise pass null
     * @param  sortingOrder      	: order of sorting (asc or desc) accept only two value otehr wise pass null
     * @last modified by            : MTX Group Product Team
     * @last modified date          : (Add if modified by you)
     * @last modified details       : (Add if modified by you)
     */
    public static List<Schema.Location> getLocationByDymanicQuery(String fields,
                                                      String whereClause,
                                                      String limitValue,
                                                      String sortingByFields,
                                                      String sortingOrder){

        String query = 'SELECT ';
        query += fields;
        query += ' FROM Location ';
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
     * @since                       : 17 Jan, 2023
     * @description                 : This method return the List of Location records by ID and Location Type
     * @param  setOfLocationIds     : Set of Location Id
     * @param  setOfLocationType    : set of Location types
     * @return                      : List<Location>
     * @last modified by            : MTX Group Product Team
     * @last modified date          : (Add if modified by you)
     * @last modified details       : (Add if modified by you)
     */
    public static List<Schema.Location> getLocationByIDsAndLocationType(Set<Id> setOfLocationIds, 
                                                                        Set<String> setOfLocationType){
        return [
            SELECT 
            	Id
			FROM 
            	Location
			WHERE 
            	Id IN :setOfLocationIds
            	AND LocationType IN :setOfLocationType
            	AND CloseDate = NULL
			WITH SECURITY_ENFORCED
        ];
    }
    
    /**
     * @author                      : MTX Group Product Team
     * @since                       : 17 Jan, 2023
     * @description                 : This method return the List of Location records by Location Type
     * @param  setOfLocationType    : set of Location types
     * @return                      : List<Location>
     * @last modified by            : MTX Group Product Team
     * @last modified date          : (Add if modified by you)
     * @last modified details       : (Add if modified by you)
     */
    public static List<Schema.Location> getLocationByLocationTypes(Set<String> setOfLocationType){
        return [
            SELECT 
            	Id
			FROM 
            	Location
			WHERE 
            	LocationType IN :setOfLocationType
			WITH SECURITY_ENFORCED
        ];
    }
    
    /**
     * @author                      : MTX Group Product Team
     * @since                       : 25 Jan, 2023
     * @description                 : This method return the List of Location records by ID and Location Type with the status
     * @param  setOfLocationIds     : Set of Location Id
     * @param  setOfLocationType    : set of Location types
     * @param status				: Status of the location records
     * @return                      : List<Location>
     * @last modified by            : MTX Group Product Team
     * @last modified date          : (Add if modified by you)
     * @last modified details       : (Add if modified by you)
     */
    public static List<Schema.Location> getLocationByIDsAndLocationType(Set<Id> setOfLocationIds, 
                                                                        Set<String> setOfLocationType,
                                                                       String status){
        return [
            SELECT 
            	Id,
            	Status__c
			FROM 
            	Location
			WHERE 
            	Id IN :setOfLocationIds
            	AND LocationType IN :setOfLocationType
            	AND Status__c = :status
			WITH SECURITY_ENFORCED
        ];
    }
    
    /****************************************** Without Security SOQL STARTS **************************************************/

    /**
     * @description       : Without Security Inner class for Schema.Location
     *                      
     * @author            : MTX Group Product Team
     * @last modified on  : 07-26-2024
     * @last modified by  : MTX Group Product Team
    **/
    public without sharing class LPI_LocationWithoutSharingDAO {
	
        /**
     * @author                      : MTX Group Product Team
     * @since                       : 
     * @description                 : Dynamic Query Get Location fields by different where clauses.
     * @param  fields             	: fields with (,) separated
     * @param  whereClause          : where condition (Ex: Name = 'Nitesh' AND Status = 'Active')
     * @param  limitValue          	: any limit otherwise pass null
     * @param  sortingByFields      : fields name from which you have to sort otherwise pass null
     * @param  sortingOrder      	: order of sorting (asc or desc) accept only two value otehr wise pass null
     * @last modified by            : MTX Group Product Team
     * @last modified date          : (Add if modified by you)
     * @last modified details       : (Add if modified by you)
     */
    public List<Schema.Location> getLocationByDymanicQuery(String fields,
                                            String whereClause,
                                            String limitValue,
                                            String sortingByFields,
                                            String sortingOrder){

        String query = 'SELECT ';
        query += fields;
        query += ' FROM Location ';
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
     * @description                 : Dynamic Query Get Location fields by different where clause WITHOUT SECURITY_ENFORED.
     * @param  fields             	: fields with (,) separated
     * @param  whereClause          : where condition (Ex: Name = 'Nitesh' AND Status = 'Active')
     * @param  limitValue          	: any limit otherwise pass null
     * @param  sortingByFields      : fields name from which you have to sort otherwise pass null
     * @param  sortingOrder      	: order of sorting (asc or desc) accept only two value otehr wise pass null
     * @last modified by            : MTX Group Product Team
     * @last modified date          : (Add if modified by you)
     * @last modified details       : (Add if modified by you)
     */
    public List<Schema.Location> getLocWithoutSharingWithoutSecurityEnforced(String fields,
                                            String whereClause,
                                            String limitValue,
                                            String sortingByFields,
                                            String sortingOrder){

        String query = 'SELECT ';
        query += fields;
        query += ' FROM Location ';
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
    
     
        
    }
}