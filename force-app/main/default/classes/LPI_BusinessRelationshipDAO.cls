/**
 * @description       :
 * @author            : MTX Group Product Team
 * @group             :
 * @last modified on  : 07-26-2024
 * @last modified by  : MTX Group Product Team
 **/
public without sharing class LPI_BusinessRelationshipDAO {
    /**
	 * @author                      : MTX Group Product Team
	 * @since                       :
	 * @description                 : Dynamic Query Get Business_Relationships__c fields by different where clauses.
	 * @param  fields             	: fields with (,) separated
	 * @param  whereClause          : where condition (Ex: Name = 'Nitesh' AND Status = 'Active')
	 * @param  limitValue          	: any limit otherwise pass null
	 * @param  sortingByFields      : fields name from which you have to sort otherwise pass null
	 * @param  sortingOrder      	: order of sorting (asc or desc) accept only two value otehr wise pass null
	 * @last modified by            : MTX Group Product Team
	 * @last modified date          : (Add if modified by you)
	 * @last modified details       : (Add if modified by you)
	 */
	public static List<Business_Relationships__c> fetchBusinessRelationshipRecords(
		String fields,
		String whereClause,
		String limitValue,
		String sortingByFields,
		String sortingOrder
	) {
		String query = 'SELECT ' + fields + ' FROM Business_Relationships__c WHERE ' + whereClause + ' WITH SECURITY_ENFORCED ';
		if (sortingByFields != null) {
			query += ' ORDER BY ' + sortingByFields;
			if (sortingOrder != null) {
				query += ' ' + sortingOrder + ' ';
			}
		}
		if (limitValue != null) {
			query += ' LIMIT ' + (limitValue != null ? limitValue : '50000');
		}
		System.debug('Query>>>>>'+query);
		return Database.query(query);
	}
	/**
	 * @description : Get BusinessLicense records by different where clauses and different fields.
	 * @author MTX Group Product Team
	 * @param whereClause
	 * @return List<BusinessLicense>
	 **/
	public static List<Business_Relationships__c> fetchBusinessRelationshipRecords(
		String fieldsToQuery,
		String whereClause
	) {
		return fetchBusinessRelationshipRecords(fieldsToQuery, whereClause, null, null, null);
	}
	 /**
	 * @author                      : MTX Group Product Team
	 * @since                       :
	 * @description                 : This method return Business_Relationships__c records by Set of Id
	 * @param  brIdSet             	: set of Business_Relationships__c ID's
	 * @return   					: `List<Business_Relationships__c>`
	 * @last modified by            : MTX Group Product Team
	 * @last modified date          : (Add if modified by you)
	 * @last modified details       : (Add if modified by you)
	 */
	public static List<Business_Relationships__c> getRelationRecordsById(Set<Id> brIdSet){
		return [
			SELECT
				Id,
				Related_From__c,
				Related_From__r.PersonEmail,
				Related_To__r.PersonEmail,
				Related_To__c
			FROM Business_Relationships__c
			WHERE ID IN :brIdSet
			WITH SECURITY_ENFORCED
		];
	}
    /**
	 * @description : This method will check for duplicate records on Business Relationships object
	 * @author MTX Group Product Team
	 * @param conditions
	 * @return List<BusinessLicense>
	 **/
    public static List<Business_Relationships__c> checkDuplicateRelationship(
		String relatedToId,
		Set<Id> relatedFromIdsSet,
		String roles,
		Date startDate,
		Date endDate) {
        List<Business_Relationships__c> relationshipList = new List<Business_Relationships__c>();
		try{
			if(String.isNotBlank(relatedToId) && relatedFromIdsSet != null && !relatedFromIdsSet.isEmpty()){
				String fields;
				String conditions;
				String relatedFromIds = LPI_ServiceUtility.getStringValuesBySet(relatedFromIdsSet) ;
				fields = 'Id, Related_To__c, Related_From__c';
				conditions = 'Related_To__c = \'' + String.escapeSingleQuotes(relatedToId) + '\'' 
					+ ' AND  Related_From__c IN ' + relatedFromIds 
					+ ' AND Roles__c = \'' + String.escapeSingleQuotes(roles) + '\'';
				if(startDate != null){
					conditions += ' AND Start_Date__c = ' + String.escapeSingleQuotes(String.valueOf(startDate));
				}
				//Need to check whether we need to have this filter or not - Garvit
				if(endDate != null){
					conditions += ' AND EndDate__c = ' + String.escapeSingleQuotes(String.valueOf(endDate));
				}
				relationshipList = fetchBusinessRelationshipRecords(fields, conditions);
			}
		}
        catch(Exception exp){
            LPI_ExceptionManager.logException('LPI_BusinessRelationshipDAO','checkDuplicateRelationship', exp);
        }
        return relationshipList;
	}

	public static List<Business_Relationships__c> checkDuplicateRelationship(
		Id relatedToId,
		Id relatedFromId,
		String roles,
		Date startDate,
		Date endDate) {
			return checkDuplicateRelationship(relatedToId, new Set<Id>{relatedFromId}, roles, startDate, endDate);
		}
	/****************************************** Without Security SOQL STARTS **************************************************/

	/**
	 * @description       : Without Security Inner class for Business_Relationships__c
	 *
	 * @author            : MTX Group Product Team
	 * @last modified on  : 07-26-2024
	 * @last modified by  : MTX Group Product Team
	 **/
	public without sharing class LPI_BusinessRelationshipsWithoutSharingDAO {
		/**
		 * @author                      : MTX Group Product Team
		 * @since                       :
		 * @description                 : Dynamic Query Get Business_Relationships__c fields by different where clauses.
		 * @param  fields             	: fields with (,) separated
		 * @param  whereClause          : where condition (Ex: Name = 'Nitesh' AND Status = 'Active')
		 * @param  limitValue          	: any limit otherwise pass null
		 * @param  sortingByFields      : fields name from which you have to sort otherwise pass null
		 * @param  sortingOrder      	: order of sorting (asc or desc) accept only two value otehr wise pass null
		 * @last modified by            : MTX Group Product Team
		 * @last modified date          : (Add if modified by you)
		 * @last modified details       : (Add if modified by you)
		 */
		public List<Business_Relationships__c> getBusinessRelationshipsByDymanicQuery(
			String fields,
			String whereClause,
			String limitValue,
			String sortingByFields,
			String sortingOrder
		) {
			String query = 'SELECT '+ fields +' FROM Business_Relationships__c WHERE ' + whereClause ;//+ ' WITH SECURITY_ENFORCED '  ;
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
	 	* @description                 : This method will check for duplicate records on Business Relationships object
	 	* @param  fields               : fields with (,) separated
	 	* @param  whereClause          : where condition (Ex: Name = 'Nitesh' AND Status = 'Active')
	 	* @param  limitValue           : any limit otherwise pass null
	 	* @param  sortingByFields      : fields name from which you have to sort otherwise pass null
	 	* @param  sortingOrder         : order of sorting (asc or desc) accept only two value otehr wise pass null
	 	* @last modified by            : MTX Group Product Team
	 	* @last modified date          : (Add if modified by you)
	 	* @last modified details       : (Add if modified by you)
	 	*/
		public List<Business_Relationships__c> checkDuplicateRelationship(
			String relatedToId,
			Set<Id> relatedFromIdsSet,
			String roles,
			Date startDate,
			Date endDate) {
			List<Business_Relationships__c> relationshipList = new List<Business_Relationships__c>();
			try{
				if(String.isNotBlank(relatedToId) && relatedFromIdsSet != null && !relatedFromIdsSet.isEmpty()){
					String fields;
					String conditions;
					String relatedFromIds = LPI_ServiceUtility.getStringValuesBySet(relatedFromIdsSet) ;
					fields = 'Id, Related_To__c, Related_From__c';
					conditions = 'Related_To__c = \'' + String.escapeSingleQuotes(relatedToId) + '\'' 
						+ ' AND  Related_From__c IN ' + relatedFromIds 
						+ ' AND Roles__c = \'' + String.escapeSingleQuotes(roles) + '\'';
					if(startDate != null){
						conditions += ' AND Start_Date__c = ' + String.escapeSingleQuotes(String.valueOf(startDate));
					}
					//Need to check whether we need to have this filter or not - Garvit
					if(endDate != null){
						conditions += ' AND EndDate__c = ' + String.escapeSingleQuotes(String.valueOf(endDate));
					}
					relationshipList = fetchBusinessRelationshipRecords(fields, conditions);
				}
			}
			catch(Exception exp){
				LPI_ExceptionManager.logException('LPI_BusinessRelationshipDAO','checkDuplicateRelationship', exp);
			}
			return relationshipList;
		}
		/**
		 * @author                      : MTX Group Product Team
		 * @since                       :
		 * @description                 : Dynamic Query Get Business_Relationships__c fields by different where clauses.
		 * @param  fields             	: fields with (,) separated
		 * @param  whereClause          : where condition (Ex: Name = 'Nitesh' AND Status = 'Active')
		 * @param  limitValue          	: any limit otherwise pass null
		 * @param  sortingByFields      : fields name from which you have to sort otherwise pass null
		 * @param  sortingOrder      	: order of sorting (asc or desc) accept only two value otehr wise pass null
		 * @last modified by            : MTX Group Product Team
		 * @last modified date          : (Add if modified by you)
		 * @last modified details       : (Add if modified by you)
		 */
		public List<Business_Relationships__c> getBusinessRelationshipsByDymanicQueryWithoutSecurity(
			String fields,
			String whereClause,
			String limitValue,
			String sortingByFields,
			String sortingOrder
		) {
			String query = 'SELECT ' + fields + ' FROM Business_Relationships__c WHERE ' + whereClause;
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