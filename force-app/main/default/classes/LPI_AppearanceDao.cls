/**
 * @description       : DAO for Schema.Appearance__c
 * @author            : MTX Group Product Team
 * @group             : 
 * @last modified on  : 07-26-2024
 * @last modified by  : MTX Group Product Team
**/
public with sharing class LPI_AppearanceDao {
     /**
    * @description : Get Appearance records by dynamic query.
    * @author MTX Group Product Team | 18-09-2023 
    * @return List<Appearance__c> 
    **/
    public static List<Appearance__c> fetchAppearanceRecords(
		String fields,
		String whereClause,
		String limitValue,
		String sortingByFields,
		String sortingOrder
	) {
		String query = 'SELECT ' + fields;
		query += ' FROM Appearance__c ';
		query += ' WHERE ' + whereClause + ' WITH SECURITY_ENFORCED';
		if (sortingByFields != null) {
			query += ' ORDER BY ' + sortingByFields;
			if (sortingOrder != null) {
				query += ' ' + sortingOrder + ' ';
			}
		}
		limitValue = String.isNotBlank(limitValue) ?  limitValue : '50000';
		query += ' LIMIT ' + limitValue;
		return Database.query(query);
	}
}