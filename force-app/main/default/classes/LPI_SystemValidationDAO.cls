/**
 * @author                      : MTX Group Product Team
 * @since                       : 
 * @description                 : This class contains DAO methods for System_Validation__c object
 * @last modified by            : MTX Group Product Team
 * @last modified date          : (Add if modified by you)
 * @last modified details       : (Add if modified by you)
 */
public with sharing class LPI_SystemValidationDAO {
    /**
	 * @author                      :MTX Group Product Team
	 * @since                       : 
	 * @description                 : This method return the List of System_Validation__c records by Dynamic query
	 * @param  listOfFields         : list of fields for query
	 * @param  limitValue           : Limit count
	 * @param  sortingByFields      : Order by field API name
	 * @param  sortingOrder         : Order for the Order By either ASC|DESC
	 * @return                      : List<System_Validation__c>
	 * @last modified by            : MTX Group Product Team
	 * @last modified date          : (Add if modified by you)
	 * @last modified details       : (Add if modified by you)
	 */
    public static List<System_Validation__c> getSystemValidByDymanicQuery(
        String fields,
        String whereClause,
        String limitValue,
        String sortingByFields,
        String sortingOrder
    ) {
        String query = 'SELECT ';
        query += fields;
        query += ' FROM System_Validation__c ';
        query += ' WHERE ' + whereClause + ' WITH SECURITY_ENFORCED ';
        if (sortingByFields != null) {
            query += ' ORDER BY ' + sortingByFields;
            if (sortingOrder != null) {
                query += ' ' + sortingOrder + ' ';
            }
        }
        if (limitValue != null) {
            query += ' LIMIT ' + (limitValue != null ? limitValue : '50000');
        }
        return Database.query(query);
    }
}