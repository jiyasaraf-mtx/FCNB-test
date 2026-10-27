/**
 * @description       : 
 * @author            : MTX Group Product Team
 * @group             : 
 * @last modified on  : 07-26-2024
 * @last modified by  : MTX Group Product Team
**/
public with sharing class LPI_VisitControllerDAO {
    
    /**
     * @author                   MTX Group Product Team
     * @description              This method will return Set<Id> of Visit Ids which are associated with the UserId
     * @param :                  String userId
     * @return                   `Set<Id>`
	 * @last modified on  : 07-26-2024
     * @last modified by  : MTX Group Product Team
     */
  public static Set<Id> getAllVisitIDs(String userId) {     
    Set<Id> visitIDs = new Set<Id>();
    Visit[] currentVisits = [
        SELECT Id, ContextId
        FROM Visit WHERE visitorId = :userId
        AND Status__c IN ('Planned', 'InProgress') ];

    if (currentVisits.isEmpty()) {
        return new Set<Id>();
    }

    for (Visit visit : currentVisits) {
        visitIDs.add(visit.Id);
    }


    return visitIDs;
  }


  private static final String ASC_SORTING_ORDER = 'ASC';
	private static final String DESC_SORTING_ORDER = 'DESC';

	/**
	 * @author                      : MTX Group Product Team
	 * @since                       : 11 May, 2023
	 * @description                 : This method return the List of Vist records by Dynamic query
	 * @param  listOfFields         : list of fields for query
	 * @param  whereClause          : Where clause
	 * @param  limitValue           : Limit count
	 * @param  sortingByFields      : Order by field API name
	 * @param  sortingOrder         : Order for the Order By either ASC|DESC
	 * @return                      : List<Visit>
	 * @last modified by            : MTX Group Product Team
	 * @last modified date          : (Add if modified by you)
	 * @last modified details       : (Add if modified by you)
	 */
	public static List<Visit> getVistListByDynamicQuery(
		List<String> listOfFields,
		String whereClause,
		Integer limitValue,
		String sortingByFields,
		String sortingOrder
	) {
		if (listOfFields.isEmpty()) {
			return null;
		}
		String query = 'SELECT ' + String.join(listOfFields, ',');
		query += ' FROM Visit ';
		query += ' WHERE ' + whereClause + ' WITH SECURITY_ENFORCED ';
		if (String.isNotBlank(sortingByFields)) {
			query += ' ORDER BY  ' + sortingByFields;
			if (ASC_SORTING_ORDER.equalsIgnoreCase(sortingOrder) || DESC_SORTING_ORDER.equalsIgnoreCase(sortingOrder)) {
				query += ' ' + sortingOrder + ' ';
			}
		}
		if (limitValue != null) {
			query += ' LIMIT ' + limitValue;
		}
		return Database.query(query);
	}
   
    /**
	 * @author                      : MTX Group Product Team
	 * @since                       : 24 Jul, 2023
	 * @description                 : This method return the List of Vist records by Dynamic query without SecurityEnforced
     *                                to query POLYMORPHIC FIELD Context
	 * @param  listOfFields         : list of fields for query
	 * @param  whereClause          : Where clause
	 * @param  limitValue           : Limit count
	 * @param  sortingByFields      : Order by field API name
	 * @param  sortingOrder         : Order for the Order By either ASC|DESC
	 * @return                      : List<Visit>
	 * @last modified by            : MTX Group Product Team
	 * @last modified date          : (Add if modified by you)
	 * @last modified details       : (Add if modified by you)
	 */
	public static List<Visit> getVisitListByDynamicQueryWithoutSecurity(
		List<String> listOfFields,
		String whereClause,
		Integer limitValue,
		String sortingByFields,
		String sortingOrder
	) {
		if (listOfFields.isEmpty()) {
			return null;
		}
		String query = 'SELECT ' + String.join(listOfFields, ',');
		query += ' FROM Visit ';
		query += ' WHERE ' + whereClause;
		if (String.isNotBlank(sortingByFields)) {
			query += ' ORDER BY  ' + sortingByFields;
			if (ASC_SORTING_ORDER.equalsIgnoreCase(sortingOrder) || DESC_SORTING_ORDER.equalsIgnoreCase(sortingOrder)) {
				query += ' ' + sortingOrder + ' ';
			}
		}
		if (limitValue != null) {
			query += ' LIMIT ' + limitValue;
		}
		return Database.query(query);
	}

	 /**
     * @description       : Without Security Inner class for Visits         
     * @author            : MTX Group Product Team
     * @last modified on  : 07-26-2024
     * @last modified by  : MTX Group Product Team
    **/
    public without sharing class LPI_VisitControllerWithoutSharingDAO {
	
		/**
		 * @author                      : MTX Group Product Team
		 * @since                       : 
		 * @description                 : Dynamic Query Get Visit fields by different where clauses.
		 * @param  fields             	: fields with (,) separated
		 * @param  whereClause          : where condition (Ex: Name = 'Nitesh' AND Status = 'Active')
		 * @param  limitValue          	: any limit otherwise pass null
		 * @param  sortingByFields      : fields name from which you have to sort otherwise pass null
		 * @param  sortingOrder      	: order of sorting (asc or desc) accept only two value otehr wise pass null
		 * @last modified by            : MTX Group Product Team
		 * @last modified date          : (Add if modified by you)
		 * @last modified details       : (Add if modified by you)
		 */
		public List<Visit> getVisitListByDynamicQueryWithoutSharing(
			List<String> listOfFields,
			String whereClause,
			Integer limitValue,
			String sortingByFields,
			String sortingOrder
		) {
			if (listOfFields.isEmpty()) {
				return null;
			}
			String query = 'SELECT ' + String.join(listOfFields, ',');
			query += ' FROM Visit ';
			query += ' WHERE ' + whereClause;
			if (String.isNotBlank(sortingByFields)) {
				query += ' ORDER BY  ' + sortingByFields;
				if (ASC_SORTING_ORDER.equalsIgnoreCase(sortingOrder) || DESC_SORTING_ORDER.equalsIgnoreCase(sortingOrder)) {
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