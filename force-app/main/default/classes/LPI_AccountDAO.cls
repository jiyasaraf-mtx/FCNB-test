/**
 * @author                      : MTX Group Product Team
 * @since                       : 17 Jan, 2023
 * @description                 : This class contains DAO methods for Account object
 * @last modified by            : MTX Group Product Team
 * @last modified date          : (Add if modified by you)
 * @last modified details       : (Add if modified by you)
 */
public without sharing class LPI_AccountDAO {
	private static final String ASC_SORTING_ORDER = 'ASC';
	private static final String DESC_SORTING_ORDER = 'DESC';

	/**
	 * @author                      : MTX Group Product Team
	 * @since                       : 17 Jan, 2023
	 * @description                 : This method return the List of Account records by Dynamic query
	 * @param  listOfFields         : list of fields for query
	 * @param  whereClause          : Where clause
	 * @param  limitValue           : Limit count
	 * @param  sortingByFields      : Order by field API name
	 * @param  sortingOrder         : Order for the Order By either ASC|DESC
	 * @return                      : List<Account>
	 * @last modified by            : MTX Group Product Team
	 * @last modified date          : (Add if modified by you)
	 * @last modified details       : (Add if modified by you)
	 */
	public static List<Account> getAccountListByDynamicQuery(
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
		query += ' FROM Account ';
		query += ' WHERE ' + whereClause;
		if (String.isNotBlank(sortingByFields)) {
			query += ' ORDER BY  ' + sortingByFields;
			if (ASC_SORTING_ORDER.equalsIgnoreCase(sortingOrder) || DESC_SORTING_ORDER.equalsIgnoreCase(sortingOrder)) {
				query += ' ' + sortingOrder + ' ';
			}
		}
		if (limitValue != null) {
			query += ' LIMIT ' + (limitValue != null ? String.valueof(limitValue) : '50000');
		}
		System.debug('>>>>>>>>	'+query);
		return Database.query(query);
	}
    

	/**
	 * @author                      : MTX Group Product Team
	 * @since                       : 17 Jan, 2023
	 * @description                 : This method return the List of Account records by ID
	 * @param  setOfAccountIds      : Set of Account Id
	 * @return                      : List<Account>
	 * @last modified by            : MTX Group Product Team
	 * @last modified date          : (Add if modified by you)
	 * @last modified details       : (Add if modified by you)
	 */
	public static List<Account> getAccountByIDs(Set<String> setOfAccountIds) {
		return [
			SELECT
				Id,
				Name,
				PersonOtherStreet,
				PersonOtherState,
				PersonOtherStateCode,
				Other_State__c,
				PersonOtherCountryCode,
				County__c,
				PersonOtherPostalCode,
				SelectedAccountId__c,
				PersonOtherCity,
				RecordType.DeveloperName,
				PersonContactId,
				FirstName,
				MiddleName,
				LastName,
				BillingStreet,
				BillingCity,
				BillingState,
				BillingPostalCode,
				BillingCountry,
				Criminal_Background_Fee_Payment_Date__c
			FROM Account
			WHERE Id IN :setOfAccountIds
			WITH SECURITY_ENFORCED
			FOR UPDATE
		];
	}

	/****************************************** Without Security SOQL STARTS **************************************************/

	/**
	 * @description       : Without Security Inner class for Account
	 *
	 * @author            : MTX Group Product Team
	 * @last modified on  : 07-26-2024
	 * @last modified by  : MTX Group Product Team
	 **/
	public without sharing class LPI_AccountWithoutSharingDAO {
		/**
		 * @author                      : MTX Group Product Team
		 * @since                       :
		 * @description                 : Dynamic Query Get Account fields by different where clauses.
		 * @param  fields             	: fields with (,) separated
		 * @param  whereClause          : where condition (Ex: Name = 'Nitesh' AND Status = 'Active')
		 * @param  limitValue          	: any limit otherwise pass null
		 * @param  sortingByFields      : fields name from which you have to sort otherwise pass null
		 * @param  sortingOrder      	: order of sorting (asc or desc) accept only two value otehr wise pass null
		 * @last modified by            : MTX Group Product Team
		 * @last modified date          : (Add if modified by you)
		 * @last modified details       : (Add if modified by you)
		 */
		public List<Account> getAccountByDymanicQuery(
			String fields,
			String whereClause,
			String limitValue,
			String sortingByFields,
			String sortingOrder
		) {
			String query = 'SELECT ';
			query += fields;
			query += ' FROM Account ';
			query += 'WHERE ' + whereClause;
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

		/**
		 * @author                      : MTX Group Product Team
		 * @since                       :
		 * @description                 : Dynamic Query Get Account fields by different where clauses.
		 * @param  fields             	: fields with (,) separated
		 * @param  whereClause          : where condition (Ex: Name = 'Nitesh' AND Status = 'Active')
		 * @param  limitValue          	: any limit otherwise pass null
		 * @param  sortingByFields      : fields name from which you have to sort otherwise pass null
		 * @param  sortingOrder      	: order of sorting (asc or desc) accept only two value otehr wise pass null
		 * @param  setOfRecordForFilter : extra param of set If needed
		 */
		public List<Account> getAccountByDymanicQuery(
			String fields,
			String whereClause,
			String limitValue,
			String sortingByFields,
			String sortingOrder,
			Set<String> setForFilter
		) {
			String query = 'SELECT ';
			query += fields;
			query += ' FROM Account ';
			query += 'WHERE ' + whereClause;
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
}