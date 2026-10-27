/**
 * @description       : DAO Class for BusinessLicense.
 * @author            : MTX Group Product Team
 * @group             :
 * @last modified on  : 07-26-2024
 * @last modified by  : MTX Group Product Team
 **/
public with sharing class LPI_BusinessLicenseDAO {
	/**
	 * @description : Get BusinessLicense records by different where clauses and different fields.
	 * @author MTX Group Product Team
	 * @param whereClause
	 * @return List<BusinessLicense>
	 **/
	public static List<BusinessLicense> fetchBusinessLicenseRecords(String fieldsToQuery, String whereClause) {
		String query = 'SELECT ' + fieldsToQuery;
		query += ' FROM BusinessLicense ';
		query += ' WHERE ' + whereClause + ' WITH SECURITY_ENFORCED';
		return Database.query(query);
	}

	/**
	 * @description : Get BusinessLicense records by different where clauses and different fields.
	 * @author MTX Group Product Team
	 * @param whereClause
	 * @return List<BusinessLicense>
	 **/
	public static List<BusinessLicense> fetchBusinessLicenseRecordsWithOrderByLimit(
		String fieldsToQuery,
		String whereClause,
		String limitValue,
		String orderByClause
	) {
		String query = 'SELECT ' + fieldsToQuery;
		query += ' FROM BusinessLicense ';
		query += ' WHERE ' + whereClause;
		if (String.isNotBlank(orderByClause)) {
			query += ' ORDER BY  ' + orderByClause;
		}
		query += ' LIMIT ' + (String.isNotBlank(limitValue) ? limitValue : '50000');
		
		return Database.query(query);
	}

	/**
	 * @author                      : MTX Group Product Team
	 * @since                       : 05 Apr, 2023
	 * @description                 : This method return PreliminaryApplicationRef records by Set of Id
	 * @param  setPARId             : Set of RAT Type Id
	 * @return                      : returns List<PreliminaryApplicationRef> by ID
	 * @last modified by            : MTX Group Product Team
	 * @last modified date          : 17 Jan, 2023
	 * @last modified details       : Name and Type__c fields are added
	 */
	public static List<BusinessLicense> getBLRecordsByID(Set<Id> setBlId) {
		return [
			SELECT
				Id,
				Name,
				RegulatoryAuthorizationType.Name,
				Contact_prior_to_renewal__c,
				Contact.AccountId,
				First_Name__c,
				Last_Name__c,
				Middle_Name__c,
				AccountId,
				Maiden_Name__c
			FROM BusinessLicense
			WHERE Id IN :setBlId
			WITH SECURITY_ENFORCED
			FOR UPDATE
		];
	}

	/****************************************** Without Security SOQL STARTS **************************************************/

	/**
	 * @description       : Without Security Inner class for BusinessLicense
	 *
	 * @author            : MTX Group Product Team
	 * @last modified on  : 07-26-2024
	 * @last modified by  : MTX Group Product Team
	 **/
	public without sharing class LPI_BusinessLicenseWithoutSharingDAO {
		/**
		 * @author                      : MTX Group Product Team
		 * @since                       :
		 * @description                 : Dynamic Query Get BusinessLicense fields by different where clauses.
		 * @param  fields             	: fields with (,) separated
		 * @param  whereClause          : where condition (Ex: Name = 'Nitesh' AND Status = 'Active')
		 * @param  limitValue          	: any limit otherwise pass null
		 * @param  sortingByFields      : fields name from which you have to sort otherwise pass null
		 * @param  sortingOrder      	: order of sorting (asc or desc) accept only two value otehr wise pass null
		 * @last modified by            : MTX Group Product Team
		 * @last modified date          : 31-01-2023
		 * @last modified details       : removed 2 methods created by me
		 */
		public List<BusinessLicense> getBusinessLicenseByDymanicQuery(
			String fields,
			String whereClause,
			String limitValue,
			String sortingByFields,
			String sortingOrder
		) {
			String query = 'SELECT ';
			query += fields;
			query += ' FROM BusinessLicense ';
			query += 'WHERE ' + whereClause;
			if (sortingByFields != null) {
				query += ' ORDER BY ' + sortingByFields;
				if (sortingOrder != null) {
					query += ' ' + sortingOrder + ' ';
				}
			}
			query += ' LIMIT ' + (String.isNotBlank(limitValue) ? limitValue : '50000');
			return Database.query(query);
		}


		/**
		 * @description : Method to fetch BusinessLicense records by name of license number.
		 * @author MTX Group Product Team
		 * @param String param,List<Id> selectedBusinessIds
		 * @return List<BusinessLicense>
		 **/
		// Polymorphic field Place is not supported in query using WITH SECURITY_ENFORCED
		public List<BusinessLicense> getBusinessListByNameLicense(
			String param,
			String profession,
			List<Id> selectedBusinessIds,
			String licenseType,
			String authType
		) {
			String whereClause = '( Name LIKE \'' + String.escapeSingleQuotes(param) + 
									'\' OR Business_Entity_Name__c LIKE \'' + String.escapeSingleQuotes(param) + 
										'\' OR Legacy_License_Number__c LIKE \'' + String.escapeSingleQuotes(param) + 
											'\' OR Account.Corporate_Name__c LIKE \'' + String.escapeSingleQuotes(param) + 
											'\' OR Account.Doing_Business_As_DBA_or_Trade_Name__c LIKE \'' + String.escapeSingleQuotes(param) +'\' ) AND RegulatoryAuthorizationType.Issuing_Department_Name__c = \'' + String.escapeSingleQuotes(profession) + '\' AND ID NOT IN ' + LPI_ServiceUtility.getStringValuesByList(selectedBusinessIds) + ' AND AccountId != NULL';
			if(String.isNotBlank(licenseType) && licenseType != 'None'){
				whereClause += ' AND RegulatoryAuthorizationType.Name = \'' + String.escapeSingleQuotes(licenseType) + '\'';
			} else if(String.isNotBlank(authType)){
				whereClause += ' AND RegulatoryAuthorizationType.Authorisation_Type__c = \'' + String.escapeSingleQuotes(authType) + '\'';
			}
			String query = 'ID,Name,AccountId,Account.FirstName,Account.MiddleName,Account.LastName, Account.Name, Account.Corporate_Name__c, Account.Doing_Business_As_DBA_or_Trade_Name__c, Account.Suffix,Business_Entity_Name__c,Account.PersonHomePhone,Last_Name__c,First_Name__c,Middle_Name__c,Account.Buisness_Email__c,Account.Phone,Account.PersonEmail,RegulatoryAuthorizationType.Name,RegulatoryAuthorizationType.Issuing_Department_Name__c,RegulatoryAuthorizationType.Authorisation_Type__c,Legacy_License_Number__c,(SELECT Id, PlaceId, AuthorizationId FROM ApplAuthorization WHERE Place.Type = \''+LPI_LiteralConstant.LOCATION_SOBJECT_NAME + '\' )';
			return getBusinessLicenseByDymanicQueryWithoutSecurity(query,whereClause,'10',null,null);
		}

		
		/**
		 * @author                      : MTX Group Product Team
		 * @since                       :
		 * @description                 : Dynamic Query Get BusinessLicense fields by different where clauses without Security.
		 * @param  fields             	: fields with (,) separated
		 * @param  whereClause          : where condition (Ex: Name = 'Nitesh' AND Status = 'Active')
		 * @param  limitValue          	: any limit otherwise pass null
		 * @param  sortingByFields      : fields name from which you have to sort otherwise pass null
		 * @param  sortingOrder      	: order of sorting (asc or desc) accept only two value otehr wise pass null
		 * @last modified by            : MTX Group Product Team
		 * @last modified date          : 31-01-2023
		 * @last modified details       : removed 2 methods created by me
		 */
		public List<BusinessLicense> getBusinessLicenseByDymanicQueryWithoutSecurity(
			String fields,
			String whereClause,
			String limitValue,
			String sortingByFields,
			String sortingOrder
		) {
			String query = 'SELECT ';
			query += fields;
			query += ' FROM BusinessLicense ';
			query += 'WHERE ' + whereClause;
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