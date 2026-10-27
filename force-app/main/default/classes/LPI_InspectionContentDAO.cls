/**
 * @description       : 
 * @author            : MTX Group Product Team
 * @group             : 
 * @last modified on  : 07-26-2024
 * @last modified by  : MTX Group Product Team
**/
public inherited sharing class LPI_InspectionContentDAO {

    private static final String ASC_SORTING_ORDER = 'ASC';
	private static final String DESC_SORTING_ORDER = 'DESC';

    /**
	 * @author                      : MTX Group Product Team
	 * @since                       : 22 Nov, 2023
	 * @description                 : This method return the List of Inspection content records by Dynamic query without SecurityEnforced
     *
	 * @param  listOfFields         : list of fields for query
	 * @param  whereClause          : Where clause
	 * @param  limitValue           : Limit count
	 * @param  sortingByFields      : Order by field API name
	 * @param  sortingOrder         : Order for the Order By either ASC|DESC
	 * @return                      : List<Inspection_Content__c>
	 * @last modified by            : MTX Group Product Team
	 */
	public static List<Inspection_Content__c> getInspectionContentByDynamicQueryWithoutSecurity(
		String fields,
		String whereClause,
		String limitValue,
		String sortingByFields,
		String sortingOrder
	) {
		String query = 'SELECT ' + fields +' FROM Inspection_Content__c WHERE ' + whereClause;
		if (String.isNotBlank(sortingByFields)) {
			query += ' ORDER BY  ' + sortingByFields;
			if (ASC_SORTING_ORDER.equalsIgnoreCase(sortingOrder) || DESC_SORTING_ORDER.equalsIgnoreCase(sortingOrder)) {
				query += ' ' + sortingOrder + ' ';
			}
		}
		query += ' LIMIT ' + (String.isNotBlank(limitValue) ? limitValue : '50000');
		return Database.query(query);
	}
}