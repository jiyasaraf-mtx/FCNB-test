/**
 * @author                      : MTX Group Product Team
 * @since                       : 03 July, 2023
 * @description                 : This method contains DAO methods for System_Response__c object
 * @last modified by            : MTX Group Product Team
 */
public with sharing class LPI_SystemResponseDao {
    /**
	 * @author                      : MTX Group Product Team
	 * @since                       :
	 * @description                 : Dynamic Query Get System_Response__c fields by different where clauses.
	 * @param  fields             	: fields with (,) separated
	 * @param  whereClause          : where condition (Ex: Name = 'MTX Group Product Team' AND Status = 'Active')
	 * @param  limitValue          	: any limit otherwise pass null
	 * @param  sortingByFields      : fields name from which you have to sort otherwise pass null
	 * @param  sortingOrder      	: order of sorting (asc or desc) accept only two value otehr wise pass null
	 * @last modified by            : MTX Group Product Team
	  */
	public static List<System_Response__c> getSystemResponseByDymanicQuery(
		String fields,
		String whereClause,
		String limitValue,
		String sortingByFields,
		String sortingOrder
	) {
		String query = 'SELECT ';
		query += fields;
		query += ' FROM System_Response__c ';
		query += 'WHERE ' + whereClause;
		if (sortingByFields != null) {
			query += ' ORDER BY ' + sortingByFields;
			if (sortingOrder != null) {
				query += ' ' + sortingOrder + ' ';
			}
		}
		if (limitValue != null) {
			query += ' LIMIT ' + limitValue;
		}
		return Database.query(query);
	}
}