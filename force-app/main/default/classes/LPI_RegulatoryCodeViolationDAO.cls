/**
 * @author                      : MTX Group Product Team
 * @since                       : 24 Jul, 2023
 * @description                 : This method contains the DAO methods for RegulatoryCodeViolation object
 * @last modified by            : MTX Group Product Team
 * @last modified date          : 07-06-2024
 */
public with sharing class LPI_RegulatoryCodeViolationDAO {
	/**
	 * @author                      : MTX Group Product Team
	 * @since                       : 24 Jul, 2023
	 * @description                 : This method return the List of RegulatoryCodeViolation records by Dynamic query
	 * @param  fields               : String of fields for query
	 * @param  whereClause          : Where clause
	 * @param  limitValue           : Limit count
	 * @param  sortingByFields      : Order by field API name
	 * @param  sortingOrder         : Order for the Order By either ASC|DESC
	 * @return                      : List<RegulatoryCodeViolation>
	 * @last modified by            : MTX Group Product Team
	 */
	public static List<RegulatoryCodeViolation> getRegulatoryCodeViolationListByDynamicQuery(
		String fields,
		String whereClause,
		String limitValue,
		String sortingByFields,
		String sortingOrder
	) {
		String query = 'SELECT ' + fields + ' FROM RegulatoryCodeViolation WHERE ' + whereClause + ' WITH SECURITY_ENFORCED ';
		if (sortingByFields != null) {
			query += ' ORDER BY ' + sortingByFields;
			if (sortingOrder != null) {
				query += ' ' + sortingOrder + ' ';
			}
		}
		query += ' LIMIT ' + (String.isNotBlank(limitValue) ? limitValue : '50000');
		System.debug('Query>>>>'+query);
		return Database.query(query);
	}
}