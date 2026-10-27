/**
 * @description       : DAO class for AssessmentTaskIndDefintion
 * @author            : MTX Group Product Team
 * @group             : 
 * @last modified on  : 07-26-2024
 * @last modified by  : MTX Group Product Team
**/
public with sharing class LPI_AssessmentTaskIndDefinitionDAO {
    /**
	 * @author                      : MTX Group Product Team
	 * @since                       : 4 Oct, 2023
	 * @description                 : This method return the List of AssessmentTaskDefinition records by Dynamic query
	 * @param  fields               : String of fields for query
	 * @param  whereClause          : Where clause
	 * @param  limitValue           : Limit count
	 * @param  sortingByFields      : Order by field API name
	 * @param  sortingOrder         : Order for the Order By either ASC|DESC
	 * @return                      : List<AssessmentTask>
	 * @last modified by            : MTX Group Product Team
	 */
	public static List<AssessmentTaskIndDefinition> getAssessmentTaskIndDefListByDynamicQuery(
		String fields,
		String whereClause,
		String limitValue,
		String sortingByFields,
		String sortingOrder
	) {
		String query = 'SELECT '+ fields + ' FROM AssessmentTaskIndDefinition WHERE ' + whereClause + ' WITH SECURITY_ENFORCED ';
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