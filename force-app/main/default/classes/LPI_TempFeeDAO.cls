/**
 *
 * @author          : Mahesh Reddy Chinthakunta
 * @Description     : This class contains DAO methods for Temp Fee object
 * @history
 * -------------------------------------------------------------------------------------------------------
 * Version      Date                Author                            Details
 *    1         3 Feb, 2023        Mahesh Reddy Chinthakunta        Developement
 * -------------------------------------------------------------------------------------------------------
 */
public without sharing class LPI_TempFeeDAO {
    // *************************************** ALL CONSTANTS ************************************************
	private static final String ASC_SORTING_ORDER = 'ASC';
	private static final String DESC_SORTING_ORDER = 'DESC';
    // ******************************************************************************************************
    
     /**
	 * @author                      : Nitesh Garg
	 * @since                       : 22 Feb, 2023
	 * @description                 : This method return the List of Temp Fee records by parId set
	 * @return                      : List<Temp_Fee__c>
	 * @last modified by            : Amit Agrawal
	 * @last modified date          : (Add if modified by you)
	 * @last modified details       : (Add if modified by you)
	 */
    public static List<Temp_Fee__c> getTempFeeByParIds(Set<Id> parIdsSet){
      	return [SELECT Id, Name, FeeAmount__c, PreliminaryApplicationReference__c
				FROM Temp_Fee__c
				WHERE PreliminaryApplicationReference__c IN :parIdsSet
				WITH SECURITY_ENFORCED];
    }
    
    
    /**
	 * @author                      : Mahesh Reddy Chinthakunta
	 * @since                       : 03 Feb, 2023
	 * @description                 : This method return the List of Temp Fee records by Dynamic query
	 * @param  fields               : list of fields for query
	 * @param  whereClause          : Where clause
	 * @param  limitValue           : Limit count
	 * @param  sortingByFields      : Order by field API name
	 * @param  sortingOrder         : Order for the Order By either ASC|DESC
	 * @return                      : List<Account>
	 * @last modified by            : Amit Agrawal
	 * @last modified date          : (Add if modified by you)
	 * @last modified details       : (Add if modified by you)
	 */
    public static List<Temp_Fee__c> getAccountListByDynamicQuery(String fields, 
	    String whereClause, Integer limitValue, String sortingByFields, String sortingOrder){
            
        String query = 'SELECT ' ;
        query +=fields;
        query += ' FROM Temp_Fee__c ';
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
	/**
	 * @author                      : Garvit Jain
	 * @since                       : 24 March, 2023
	 * @description                 : This method return the List of Temp Fee records by Dynamic query
	 * @param  fields               : list of fields for query
	 * @param  whereClause          : Where clause
	 * @param  limitValue           : Limit count
	 * @param  sortingByFields      : Order by field API name
	 * @param  sortingOrder         : Order for the Order By either ASC|DESC
	 * @return                      : List<Temp_Fee__c>
	 * @last modified by            : Amit Agrawal
	 * @last modified date          : (Add if modified by you)
	 * @last modified details       : (Add if modified by you)
	 */
	public static List<Temp_Fee__c> getTempFeeListByDynamicQuery(String fields, 
	    String whereClause, Integer limitValue, String sortingByFields, String sortingOrder){
            
        String query = 'SELECT ' ;
        query +=fields;
        query += ' FROM Temp_Fee__c ';
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