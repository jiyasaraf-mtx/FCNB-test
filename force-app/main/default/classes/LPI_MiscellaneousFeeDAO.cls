/**
 *
 * @author          : MTX Group Product Team
 * @Description     : This class contains DAO methods for Temp Fee object
 * @history
 * -------------------------------------------------------------------------------------------------------
 * Version      Date                Author                            Details
 *    1         3 Feb, 2023        MTX Group Product Team             Developement
 * -------------------------------------------------------------------------------------------------------
 */
public without sharing class LPI_MiscellaneousFeeDAO {
    // *************************************** ALL CONSTANTS ************************************************
    private static final String ASC_SORTING_ORDER = 'ASC';
    private static final String DESC_SORTING_ORDER = 'DESC';
    // ******************************************************************************************************
   
   
    /**
	 * @author                      : MTX Group Product Team
	 * @since                       : 03 Feb, 2023
	 * @description                 : This method return the List of Temp Fee records by Dynamic query
	 * @param  fields               : list of fields for query
	 * @param  whereClause          : Where clause
	 * @param  limitValue           : Limit count
	 * @param  sortingByFields      : Order by field API name
	 * @param  sortingOrder         : Order for the Order By either ASC|DESC
	 * @return                      : List<Account>
	 * @last modified by            : MTX Group Product Team
	 * @last modified on            : 07-26-2024
	*/
    public static List<Miscellaneous_Fee__c> getAccountListByDynamicQuery(String fields, 
	    String whereClause, Integer limitValue, String sortingByFields, String sortingOrder){
            
        String query = 'SELECT ' ;
        query +=fields;
        query += ' FROM Miscellaneous_Fee__c ';
        query += ' WHERE ' + whereClause + ' WITH SECURITY_ENFORCED ';
        if(String.isNotBlank(sortingByFields)){
            query += ' ORDER BY  ' + sortingByFields ;
			if(ASC_SORTING_ORDER.equalsIgnoreCase(sortingOrder) || 
			    DESC_SORTING_ORDER.equalsIgnoreCase(sortingOrder)) {

                query += ' ' + sortingOrder + ' ';
            }
        }
        if(limitValue != null){
            query += ' LIMIT ' + limitValue;
        }
        return Database.query(query);
    }
}