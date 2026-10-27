/**
 * @author                      : MTX Group Product Team
 * @since                       : 24 Jul, 2023
 * @description                 : This method contains the DAO methods for AssessmentTask object
 * @last modified by            : MTX Group Product Team
 * @last modified on            : 07-26-2024
 */
public with sharing class LPI_AssessmentTaskDAO {
	/**
	 * @author                      : MTX Group Product Team
	 * @since                       : 24 Jul, 2023
	 * @description                 : This method return the List of AssessmentTask records by Dynamic query
	 * @param  fields               : String of fields for query
	 * @param  whereClause          : Where clause
	 * @param  limitValue           : Limit count
	 * @param  sortingByFields      : Order by field API name
	 * @param  sortingOrder         : Order for the Order By either ASC|DESC
	 * @return                      : List<AssessmentTask>
	 * @last modified by            : MTX Group Product Team
	 * @last modified on            : 07-26-2024
	 */
	public static List<AssessmentTask> getAssessmentTaskListByDynamicQuery(
		String fields,
		String whereClause,
		String limitValue,
		String sortingByFields,
		String sortingOrder
	) {
		String query = 'SELECT '+ fields + ' FROM AssessmentTask WHERE ' + whereClause + ' WITH SECURITY_ENFORCED ';
		if (sortingByFields != null) {
			query += ' ORDER BY ' + sortingByFields;
			if (sortingOrder != null) {
				query += ' ' + sortingOrder + ' ';
			}
		}
		query += ' LIMIT ' + (String.isNotBlank(limitValue) ? limitValue : '50000');
		return Database.query(query);
	}

	public without sharing class LPI_AssessmentTaskWithoutSharingDAO {
		/**
		 * @author                      : Vamsi Mudaliar
		 * @since                       : 6th Oct, 2023
		 * @description                 : This method return the List of AssessmentTask records by Dynamic query in without sharing
		 * @param  fields               : String of fields for query
		 * @param  whereClause          : Where clause
		 * @param  limitValue           : Limit count
		 * @param  sortingByFields      : Order by field API name
		 * @param  sortingOrder         : Order for the Order By either ASC|DESC
		 * @return                      : List<AssessmentTask>
		 * @last modified by            : MTX Group Product Team
		 * @last modified on            : 07-26-2024
		 */
		public List<AssessmentTask> getAssessmentTaskListByDynamicQuery(
			String fields,
			String whereClause,
			String limitValue,
			String sortingByFields,
			String sortingOrder
		) {
			String query = 'SELECT '+ fields + ' FROM AssessmentTask WHERE ' + whereClause;
			if (sortingByFields != null) {
				query += ' ORDER BY ' + sortingByFields;
				if (sortingOrder != null) {
					query += ' ' + sortingOrder + ' ';
				}
			}
			query += ' LIMIT ' + (String.isNotBlank(limitValue) ? limitValue : '50000');
			return Database.query(query);
		}
	}
}