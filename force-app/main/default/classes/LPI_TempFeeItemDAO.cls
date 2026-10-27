/**
 *
 * @author          : Garvit Jain
 * @Description     : This class contains DAO methods for Temp Fee Item object
 * @history
 * -------------------------------------------------------------------------------------------------------
 * Version      Date                Author                            Details
 *    1         24 Mar, 2023        Garvit Jain                     Created Class with getTempFeeItemListByDynamicQuery method
 * -------------------------------------------------------------------------------------------------------
 */
public with sharing class LPI_TempFeeItemDAO {
    // ******************************************************************************************************
	/**
	 * @author                      : Garvit Jain
	 * @since                       : 24 March, 2023
	 * @description                 : This method return the List of Temp Fee Item records by Dynamic query
	 * @param  fields               : list of fields for query
	 * @param  whereClause          : Where clause
	 * @param  limitValue           : Limit count
	 * @param  sortingByFields      : Order by field API name
	 * @param  sortingOrder         : Order for the Order By either ASC|DESC
	 * @return                      : List<Temp_Fee_Item__c>
	 * @last modified by            : Amit Agrawal
	 * @last modified date          : (Add if modified by you)
	 * @last modified details       : (Add if modified by you)
	 */
	public static List<Temp_Fee_Item__c> getTempFeeItemListByDynamicQuery(String fields, 
	    String whereClause, Integer limitValue, String sortingByFields, String sortingOrder){
            
        String query = 'SELECT ' ;
        query +=fields;
        query += ' FROM Temp_Fee_Item__c';
        query += ' WHERE ' + whereClause + ' WITH SECURITY_ENFORCED ';
        if(String.isNotBlank(sortingByFields)){
            query += ' ORDER BY  ' + sortingByFields ;
			if(sortingOrder.equalsIgnoreCase('ASC') || 
				sortingOrder.equalsIgnoreCase('DESC')) {
                query += ' ' + sortingOrder + ' ';
            }
        }
        if(limitValue != null){
            query += ' LIMIT ' + limitValue;
        }
        return Database.query(query);
    }

	/****************************************** Without Security SOQL STARTS **************************************************/

	/**
	 * @description       : Without Security Inner class for TempFeeItem
	 *                      
	 * @author            : Garvit Jain	
	 * @last modified on  : 04-04-2024
	 * @last modified by  : Amit Agrawal
	**/
   	public without sharing class LPI_TempFeeItemWithoutSharingDAO {
		/**
		 * @author                      : Garvit Jain
		 * @since                       : 24 March, 2023
		 * @description                 : This method return the List of Temp Fee Item records by Dynamic query
		 * @param  fields               : list of fields for query
		 * @param  whereClause          : Where clause
		 * @param  limitValue           : Limit count
		 * @param  sortingByFields      : Order by field API name
		 * @param  sortingOrder         : Order for the Order By either ASC|DESC
		 * @return                      : List<Temp_Fee_Item__c>
		 * @last modified by            : Amit Agrawal
		 * @last modified date          : (Add if modified by you)
		 * @last modified details       : (Add if modified by you)
		 */
		public List<Temp_Fee_Item__c> getTempFeeItemListByDynamicQuery(String fields, 
			String whereClause, Integer limitValue, String sortingByFields, String sortingOrder){
				
			String query = 'SELECT ' ;
			query +=fields;
			query += ' FROM Temp_Fee_Item__c';
			query += ' WHERE ' + whereClause + ' WITH SECURITY_ENFORCED ';
			if(String.isNotBlank(sortingByFields)){
				query += ' ORDER BY  ' + sortingByFields ;
				if(sortingOrder.equalsIgnoreCase('ASC') || 
					sortingOrder.equalsIgnoreCase('DESC')) {
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