/**
 * @description       : DAO for Schema.Incident
 * @author            : MTX Group Product Team
 * @group             : 
 * @last modified on  : 07-26-2024
 * @last modified by  : MTX Group Product Team
**/
public with sharing class LPI_IncidentDao {

    
    /**
    * @description : Get Incident records by dynamic query.
    * @author MTX Group Product Team | 05-22-2023 
    * @param fields 
    * @param whereClause 
    * @param limitValue 
    * @param sortingByFields 
    * @param sortingOrder 
    * @return List<Incident> 
    **/
    public static List<Incident> fetchIncidents(
		String fields,
		String whereClause,
		String limitValue,
		String sortingByFields,
		String sortingOrder
	) {
		String query = 'SELECT ' + fields;
		query += ' FROM Incident ';
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
	public without sharing class LPI_IncidentWithoutSharingDAO {
		/**
		* @description : Get Incident records by dynamic query.
		* @author MTX Group Product Team | 05-22-2023 
		* @param fields 
		* @param whereClause 
		* @param limitValue 
		* @param sortingByFields 
		* @param sortingOrder 
		* @return List<Incident> 
		**/
		public List<Incident> fetchIncidentsWithoutSecurityEnforced(
			String fields,
			String whereClause,
			String limitValue,
			String sortingByFields,
			String sortingOrder
		) {
			String query = 'SELECT ' + fields;
			query += ' FROM Incident ';
			query += ' WHERE ' + whereClause ;
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
}