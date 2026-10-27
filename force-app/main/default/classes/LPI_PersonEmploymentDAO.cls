/**
 * @description       :  DAO class for querying PersonEmployment
 * @author            :  MTX Group Product Team
 * @group             :
 * @last modified on  : 07-26-2024
 * @last modified by  : MTX Group Product Team
 **/
public with sharing class LPI_PersonEmploymentDAO {
	/**
	* @description Dynamic Query Get PersonEmployment fields by different where clauses.
	* @author MTX Group Product Team | 07-08-2024 
	* @param fields 
	* @param whereClause 
	* @param limitValue 
	* @param sortingByFields 
	* @param sortingOrder 
	* @return List<PersonEmployment> 
	**/
	public static List<PersonEmployment> getEmploymentHistoryByDymanicQuery(
		String fields,
		String whereClause,
		String limitValue,
		String sortingByFields,
		String sortingOrder
	) {
		String query = 'SELECT ';
		query += fields;
		query += ' FROM PersonEmployment ';
		query += 'WHERE ' + whereClause + ' WITH SECURITY_ENFORCED ';
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

	/****************************************** Without Security SOQL STARTS **************************************************/

	/**
	 * @description       : Without Security Inner class for Person Employment.
	 *
	 * @author            : MTX Group Product Team
	 * @last modified on  : 07-26-2024
	 * @last modified by  : MTX Group Product Team
	 **/
	public without sharing class LPI_EmploymentHistoryWithoutSharingDAO {

		/**
		* @description Dynamic Query Get BusinessLicense fields by different where clauses.
		* @author MTX Group Product Team | 07-08-2024 
		* @param fields 
		* @param whereClause 
		* @param limitValue 
		* @param sortingByFields 
		* @param sortingOrder 
		* @return List<PersonEmployment> 
		**/
		public List<PersonEmployment> getEmploymentHistoryByDymanicQuery(
			String fields,
			String whereClause,
			String limitValue,
			String sortingByFields,
			String sortingOrder
		) {
			String query = 'SELECT ';
			query += fields;
			query += ' FROM PersonEmployment ';
			query += 'WHERE ' + whereClause + ' WITH SECURITY_ENFORCED ';
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
}