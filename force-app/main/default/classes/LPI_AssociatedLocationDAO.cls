/**
 * @author              : Rachna Jadam
 * @since               : 23 Jan, 2023
 * @description         : This class contains DAO methods for AssociatedLocation object
 * @history
 * -------------------------------------------------------------------------------------------------------
 * Version      Date                Author                  Details
 *    1         23 Jan, 2023        Rachna Jadam            Initial Developement
 * -------------------------------------------------------------------------------------------------------
 */
public inherited sharing class LPI_AssociatedLocationDAO {
    private static final String ASC_SORTING_ORDER = 'ASC';
	private static final String DESC_SORTING_ORDER = 'DESC';
    /**
	 * @author                      : Rachna Jadam
	 * @since                       : 17 Jan, 2023
	 * @description                 : This method return the List of AssociatedLocation records by Dynamic query
	 * @param  listOfFields         : list of fields for query
	 * @param  whereClause          : Where clause
	 * @param  limitValue           : Limit count
	 * @param  sortingByFields      : Order by field API name
	 * @param  sortingOrder         : Order for the Order By either ASC|DESC
	 * @return                      : List<AssociatedLocation>
	 * @last modified by            : Mohit Karani
	 * @last modified date          : (Add if modified by you)
	 * @last modified details       : (Add if modified by you)
	 */
    public static List<AssociatedLocation> getAssociatedLocationListByDynamicQuery(List<String> listOfFields, 
	    String whereClause, Integer limitValue, String sortingByFields, String sortingOrder){

		if(listOfFields.isEmpty()) {
			return null;
		}
        String query = 'SELECT ' + String.join(listOfFields, ',');
        query += ' FROM AssociatedLocation ';
        query += ' WHERE ' + whereClause + ' WITH SECURITY_ENFORCED ';
        if(String.isNotBlank(sortingByFields)){
            query += ' ORDER BY  ' + sortingByFields ;
			if(ASC_SORTING_ORDER.equalsIgnoreCase(sortingOrder) || 
			    DESC_SORTING_ORDER.equalsIgnoreCase(sortingOrder)) {

                query += ' ' + sortingOrder + ' ';
            }
        }
        query += ' LIMIT ' +  (limitValue!= NULL ? String.valueOf(limitValue) : '50000');
        
        return Database.query(query);
    }
    /****************************************** Without Security SOQL STARTS **************************************************/

    /**
     * @description       : Without Security Inner class for AssociatedLocation
     *                      
     * @author            : Nitesh Garg
     * @last modified on  : 03-01-2024
     * @last modified by  : Mohit Karani
    **/
    public without sharing class LPI_AssociatedLocationWithoutSharingDAO {
	
        /**
     * @author                      : Nitesh Garg
     * @since                       : 
     * @description                 : Dynamic Query Get AssociatedLocation fields by different where clauses.
     * @param  fields             	: fields with (,) separated
     * @param  whereClause          : where condition (Ex: Name = 'Nitesh' AND Status = 'Active')
     * @param  limitValue          	: any limit otherwise pass null
     * @param  sortingByFields      : fields name from which you have to sort otherwise pass null
     * @param  sortingOrder      	: order of sorting (asc or desc) accept only two value otehr wise pass null
     * @last modified by            : Mohit Karani
     * @last modified date          : (Add if modified by you)
     * @last modified details       : (Add if modified by you)
     */
    public List<AssociatedLocation> getAssociatedLocationByDymanicQuery(String fields,
                                            String whereClause,
                                            String limitValue,
                                            String sortingByFields,
                                            String sortingOrder){

        String query = 'SELECT ';
        query += fields;
        query += ' FROM AssociatedLocation ';
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
    
        
    }
}