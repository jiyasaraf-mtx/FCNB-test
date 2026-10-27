/**
 * @author                          : MTX Group Product Team
 * @since                           : 11 Jan, 2023
 * @description                     : This class contains DAO methods for Temp_AuthApplicationPlace__c object
 * @last modified by                : MTX Group Product Team
 * @last modified date              : (Add if modified by you)
 * @last modified details           : (Add if modified by you)
 */
public with sharing class LPI_TempAuthApplicationPlaceDAO {
    
    /**
     * @author                      : MTX Group Product Team
     * @since                       : 
     * @description                 : Dynamic Query Get Temp_AuthApplicationPlace__c fields by different where clauses.
     * @param  fields             	: fields with (,) separated
     * @param  whereClause          : where condition (Ex: Name = 'Nitesh' AND Status = 'Active')
     * @param  limitValue          	: any limit otherwise pass null
     * @param  sortingByFields      : fields name from which you have to sort otherwise pass null
     * @param  sortingOrder      	: order of sorting (asc or desc) accept only two value otehr wise pass null
     * @last modified by            : MTX Group Product Team
     * @last modified date          : (Add if modified by you)
     * @last modified details       : (Add if modified by you)
     */
    public static List<Temp_AuthApplicationPlace__c> getTempAuthApplicationPlaceByDymanicQuery(String fields,
                                                      String whereClause,
                                                      String limitValue,
                                                      String sortingByFields,
                                                      String sortingOrder){

        String query = 'SELECT ';
        query += fields;
        query += ' FROM Temp_AuthApplicationPlace__c ';
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
     * @since                       : 18 Mar, 2023
     * @description                 : This method return the List of Temp_AuthApplicationPlace__c records by Dynamic query
     * @param  listOfFields         : list of fields for query
	 * @param  whereClause          : Where clause
	 * @param  limitValue           : Limit count
	 * @param  sortingByFields      : Order by field API name
	 * @param  sortingOrder         : order of sorting (asc or desc) accept only two value otehr wise pass null
	 * @return                      : List<Temp_AuthApplicationPlace__c>
     */
    public static List<Temp_AuthApplicationPlace__c> getTempAuthApplicationPlaceByDymanicQuery(List<String> listOfFields,
                                                      String whereClause,
                                                      String limitValue,
                                                      String sortingByFields,
                                                      String sortingOrder){

        if (listOfFields.isEmpty()) {
			return null;
		}
        String query = 'SELECT ' + String.join(listOfFields, ',');                                                  
        query += ' FROM Temp_AuthApplicationPlace__c ';
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
     * @description                 : This method is to update the BLA ID on Application Content
     * @param  setPARId             : Takes Set of PAR Id's
     * @return                      : returns List<Temp_AuthApplicationPlace__c> associated to PAR record
     * @last modified by            : MTX Group Product Team
     * @last modified date          : 19 Jan, 2023
     * @last modified details       : Added Location__c != NULL condition in SOQL
     */
    public static List<Temp_AuthApplicationPlace__c> getTempAuthAppPlacesByPARId(Set<Id> setPARId){
        return [
            SELECT
                Id, 
                Preliminary_Application_Reference__c, 
                Location__c
            FROM
                Temp_AuthApplicationPlace__c
            WHERE
                Preliminary_Application_Reference__c  IN :setPARId
                AND Location__c != NULL
            WITH SECURITY_ENFORCED
        ];
    }
    /****************************************** Without Security SOQL STARTS **************************************************/

    /**
     * @description       : Without Security Inner class for Temp_AuthApplicationPlace__c
     *                      
     * @author            : MTX Group Product Team
     * @last modified on  : 07-26-2024
     * @last modified by  : MTX Group Product Team
    **/
    public without sharing class LPI_TempAuthApplicationPlaceWithoutSharingDAO {
	
        /**
     * @author                      : MTX Group Product Team
     * @since                       : 
     * @description                 : Dynamic Query Get Temp_AuthApplicationPlace__c fields by different where clauses.
     * @param  fields             	: fields with (,) separated
     * @param  whereClause          : where condition (Ex: Name = 'Nitesh' AND Status = 'Active')
     * @param  limitValue          	: any limit otherwise pass null
     * @param  sortingByFields      : fields name from which you have to sort otherwise pass null
     * @param  sortingOrder      	: order of sorting (asc or desc) accept only two value otehr wise pass null
     * @last modified by            : MTX Group Product Team
     * @last modified date          : (Add if modified by you)
     * @last modified details       : (Add if modified by you)
     */
    public List<Temp_AuthApplicationPlace__c> getTempAuthApplicationPlaceByDymanicQuery(String fields,
                                            String whereClause,
                                            String limitValue,
                                            String sortingByFields,
                                            String sortingOrder){

        String query = 'SELECT ';
        query += fields;
        query += ' FROM Temp_AuthApplicationPlace__c ';
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
     * @since                       : 15 July, 2023
     * @description                 : This method is to update the BLA ID on Application Content
     * @param  setPARId             : Takes Set of PAR Id's
     * @return                      : returns List<Temp_AuthApplicationPlace__c> associated to PAR record
     * @last modified by            : MTX Group Product Team
     * @last modified date          : 19 Jan, 2023
     * @last modified details       : Added Location__c != NULL condition in SOQL
     */
    public List<Temp_AuthApplicationPlace__c> getTempAuthAppPlacesByPARId(Set<Id> setPARId){
        return [
            SELECT
                Id, 
                Preliminary_Application_Reference__c, 
                Location__c
            FROM
                Temp_AuthApplicationPlace__c
            WHERE
                Preliminary_Application_Reference__c  IN :setPARId
                AND Location__c != NULL
            WITH SECURITY_ENFORCED
        ];
    }
        
    }
}