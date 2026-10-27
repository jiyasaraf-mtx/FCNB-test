/**
 * @author                      : MTX Group Product Team
 * @since                       : 10 Jan, 2023
 * @description                 : This method contains the DAO methods for PreliminaryApplicationRef object
 * @last modified by            : MTX Group Product Team
 * @last modified date          : 17 Jan 2023
 * @last modified details       : Added new method : getPARRecordsByTypeAmendTypeOldBLIdAndStatus
 */
public with sharing class LPI_PreliminaryApplicationRefDAO {
	/**
	 * @author                      : MTX Group Product Team
	 * @since                       :
	 * @description                 : Dynamic Query Get PreliminaryApplicationRef fields by different where clauses.
	 * @param  fields             	: fields with (,) separated
	 * @param  whereClause          : where condition (Ex: Name = 'Nitesh' AND Status = 'Active')
	 * @param  limitValue          	: any limit otherwise pass null
	 * @param  sortingByFields      : fields name from which you have to sort otherwise pass null
	 * @param  sortingOrder      	: order of sorting (asc or desc) accept only two value otehr wise pass null
	 * @last modified by            : MTX Group Product Team
	 * @last modified date          : (Add if modified by you)
	 * @last modified details       : (Add if modified by you)
	 */
	public static List<PreliminaryApplicationRef> getPreliminaryApplicationRefByDymanicQuery(
		String fields,
		String whereClause,
		String limitValue,
		String sortingByFields,
		String sortingOrder
	) {
		String query = 'SELECT ';
		query += fields;
		query += ' FROM PreliminaryApplicationRef ';
		query += 'WHERE ' + whereClause;
		if (sortingByFields != null) {
			query += ' ORDER BY ' + sortingByFields;
			if (sortingOrder != null) {
				query += ' ' + sortingOrder + ' ';
			}
		}
		query += ' LIMIT ' + (String.isNotBlank(limitValue) ? limitValue : '50000');
		system.debug('query:- '+query);
		return Database.query(query);
	}

	/**
	 * @author                      : MTX Group Product Team
	 * @since                       :
	 * @description                 : Dynamic Query Get PreliminaryApplicationRef fields by different where clauses without SECURITY_ENFORCED
	 * @param  fields             	: fields with (,) separated
	 * @param  whereClause          : where condition (Ex: Name = 'Nitesh' AND Status = 'Active')
	 * @param  limitValue          	: any limit otherwise pass null
	 * @param  sortingByFields      : fields name from which you have to sort otherwise pass null
	 * @param  sortingOrder      	: order of sorting (asc or desc) accept only two value otehr wise pass null
	 * @last modified by            : MTX Group Product Team
	 * @last modified date          : (Add if modified by you)
	 * @last modified details       : (Add if modified by you)
	 */
	public static List<PreliminaryApplicationRef> getPreAppRefByDymanicQueryWithoutSecurity(
		String fields,
		String whereClause,
		String limitValue,
		String sortingByFields,
		String sortingOrder
	) {
		String query = 'SELECT ';
		query += fields;
		query += ' FROM PreliminaryApplicationRef ';
		query += 'WHERE ' + whereClause + ' ';
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
	 * @author                      : MTX Group Product Team
	 * @since                       : 10 Jan, 2023
	 * @description                 : This method return PreliminaryApplicationRef records by Set of Id
	 * @param  setPARId             : Set of RAT Type Id
	 * @return                      : returns List<PreliminaryApplicationRef> by ID
	 * @last modified by            : MTX Group Product Team
	 * @last modified date          : April 28, 2023
	 * @last modified details       : Status__c field is added
	 */
	public static List<PreliminaryApplicationRef> getPARRecordsByID(Set<Id> setPARId) {
		return [
			SELECT
				Id,
				Name,
				Type__c,
				Amendment_Type__c,
				Contact__c,
				Board_Name__c,
				BusinessAccountNameId,
				Regulatory_Authorization_Type__c,
				Regulatory_Authorization_Type__r.Name,
				Regulatory_Authorization_Type__r.IssuingDepartment.Name,
				How_are_you_associated_to_this_entity__c,
				Is_Auto_Approval_Allowed__c,
				License_Questions__c,
				Status__c,
				FirstName__c,
				MiddleName__c,
				LastName__c,
				Profession__c,
				Supervisor_ACR_Id__c,
				Approval_Supervisors_AcrIds__c,
				Business_License__r.Profession__c,
				BusinessAccountName.RecordTypeId,
            	Business_Account__c
			FROM PreliminaryApplicationRef
			WHERE Id IN :setPARId
			WITH SECURITY_ENFORCED
			FOR UPDATE
		];
	}

	/**
	 * @author                      : MTX Group Product Team
	 * @since                       : 18 Jan, 2023
	 * @description                 : This method return PreliminaryApplicationRef records by Type, Amendment Type,
	 * 							      BusinessLicense and Status
	 * @param  setOldBLIds          : Set of Old BusinessLincense Id
	 * @param  setOfType            : Set of Types
	 * @param  setOfAmendmentType   : Set of Amendment Type
	 * @param  setOfStatus          : Set of Status
	 * @return                      : returns List<PreliminaryApplicationRef> by ID
	 * @last modified by            : MTX Group Product Team
	 * @last modified date          : (Add if modified by you)
	 * @last modified details       : (Add if modified by you)     */
	public static List<PreliminaryApplicationRef> getPARRecordsByTypeAmendTypeOldBLIdAndStatus(
		Set<String> setOldBLIds,
		Set<String> setOfType,
		Set<String> setOfAmendmentType,
		Set<String> setOfStatus
	) {
		return [
			SELECT Id, Name, Type__c, Status__c, ApplicationType, Amendment_Type__c
			FROM PreliminaryApplicationRef
			WHERE
				Business_License__c IN :setOldBLIds
				AND Amendment_Type__c IN :setOfAmendmentType
				AND Type__c IN :setOfType
				AND Status__c IN :setOfStatus
			WITH SECURITY_ENFORCED
		];
	}


	/**
	 * @author                      : MTX Group Product Team
	 * @since                       : 20 Jan, 2023
	 * @description                 : This method return PreliminaryApplicationRef records by Id
	 * @param  parId          		: PAR record Id
	 * @return                      : List<PreliminaryApplicationRef>
	 */
	public static List<PreliminaryApplicationRef> getPARRecordsByParId(String parId) {
		return [
			SELECT
				Id,
				BusinessAccountNameId,
				Name,
				Status__c,
				ApplicationType,
				Type__c,
				Amendment_Type__c,
				License_Questions__c,
				Board_Name__c,
				New_Designated_in_charge_License_Number__c,
				Person_Incharge_Relation_Id__c,
                BusinessAccountName.Name,
                Regulatory_Authorization_Type__r.Name
			FROM PreliminaryApplicationRef
			WHERE Id = :parId
			WITH SECURITY_ENFORCED
		];
	}

	/**
	 * @author                      : MTX Group Product Team
	 * @since                       : 20 Jan, 2023
	 * @description                 : This method return PreliminaryApplicationRef records by Regulatory Authorization Type Business Account Id and Amendment Type
	 * @param regAuthId             : RAT record Id
	 * @param oblId					: Old Business Lincense Id
	 * @param baId					: Business Account Name Id
	 * @param atSet					: Set of Amendement Type
	 * @return                      : List<PreliminaryApplicationRef>
	 */
	public static List<PreliminaryApplicationRef> getPARRecordsByregAuthIdAndoblIdAndbaIdAndatSet(
		String regAuthId,
		String oblId,
		String baId,
		Set<String> atSet
	) {
		return [
			SELECT Id
			FROM PreliminaryApplicationRef
			WHERE
				Regulatory_Authorization_Type__c = :regAuthId
				AND Business_License__c = :oblId
				AND BusinessAccountNameId = :baId
				AND Amendment_Type__c IN :atSet
			WITH SECURITY_ENFORCED
			ORDER BY LastModifiedDate DESC
		];
	}
	/**
	 * @author                      : MTX Group Product Team
	 * @since                       : 26 May, 2023
	 * @description                 : Dynamic Query Get PersonExamination fields by different where clauses.
	 * @param  fields               : fields with (,) separated
	 * @param  whereClause          : where condition (Ex: Name = 'Vamsi' AND Status = 'Active')
	 * @last modified by            : MTX Group Product Team
	 * @last modified date          : (Add if modified by you)
	 * @last modified details       : (Add if modified by you)
	 */
	public static List<PreliminaryApplicationRef> getPreliminaryApplicationRefByDymanicQuery(
		String fields,
		String whereClause
	) {
		return getPreliminaryApplicationRefByDymanicQuery(fields, whereClause, null, null, null);
	}
	/****************************************** Without Security SOQL STARTS **************************************************/

	/**
	 * @description       : Without Security Inner class for PreliminaryApplicationRef
	 *
	 * @author            : MTX Group Product Team
	 * @last modified on  : 07-26-2024
	 * @last modified by  : MTX Group Product Team
	 **/
	public without sharing class LPI_PreliminaryApplicationRefWithoutSharingDAO {
		/**
		 * @author                      : MTX Group Product Team
		 * @since                       :
		 * @description                 : Dynamic Query Get PreliminaryApplicationRef fields by different where clauses.
		 * @param  fields             	: fields with (,) separated
		 * @param  whereClause          : where condition (Ex: Name = 'Nitesh' AND Status = 'Active')
		 * @param  limitValue          	: any limit otherwise pass null
		 * @param  sortingByFields      : fields name from which you have to sort otherwise pass null
		 * @param  sortingOrder      	: order of sorting (asc or desc) accept only two value otehr wise pass null
		 * @last modified by            : MTX Group Product Team
		 * @last modified date          : (Add if modified by you)
		 * @last modified details       : (Add if modified by you)
		 */
		public List<PreliminaryApplicationRef> getPreliminaryApplicationRefByDymanicQuery(
			String fields,
			String whereClause,
			String limitValue,
			String sortingByFields,
			String sortingOrder
		) {
			String query = 'SELECT ';
			query += fields;
			query += ' FROM PreliminaryApplicationRef ';
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