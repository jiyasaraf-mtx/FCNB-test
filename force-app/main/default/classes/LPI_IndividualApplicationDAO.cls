/**
 * @author                      : MTX Group Product Team
 * @since                       : 10 Jan, 2023
 * @description                 : This method contains DAO methods for IndividualApplication object
 * @last modified by            : MTX Group Product Team
 * @last modified date          : 18 Jan, 2023
 * @last modified details       : Added new Method: getIAByBLIdsApplicationTypeStatusAndPARIds
 */
public with sharing class LPI_IndividualApplicationDAO {
	/**
	 * @author                      : MTX Group Product Team
	 * @since                       :
	 * @description                 : Dynamic Query Get IndividualApplication fields by different where clauses.
	 * @param  fields             	: fields with (,) separated
	 * @param  whereClause          : where condition (Ex: Name = 'Nitesh' AND Status = 'Active')
	 * @param  limitValue          	: any limit otherwise pass null
	 * @param  sortingByFields      : fields name from which you have to sort otherwise pass null
	 * @param  sortingOrder      	: order of sorting (asc or desc) accept only two value otehr wise pass null
	 * @last modified by            : MTX Group Product Team
	 * @last modified date          : (Add if modified by you)
	 * @last modified details       : (Add if modified by you)
	 */
	public static List<IndividualApplication> getIndividualApplicationByDymanicQuery(
		String fields,
		String whereClause,
		String limitValue,
		String sortingByFields,
		String sortingOrder
	) {
		String query = 'SELECT ';
		query += fields;
		query += ' FROM IndividualApplication ';
		query += 'WHERE ' + whereClause + ' WITH SECURITY_ENFORCED ';
		if (sortingByFields != null) {
			query += ' ORDER BY ' + sortingByFields;
			if (sortingOrder != null) {
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
	 * @since                       : 10 Jan, 2023
	 * @description                 : This method contains DAO methods for IndividualApplication object
	 * @param  setSavedAppRefId     : Set of SavedApplicationRefId (PAR ID's)
	 * @last modified by            : MTX Group Product Team
	 * @last modified date          : (Add if modified by you)
	 * @last modified details       : (Add if modified by you)
	 */
	public static List<IndividualApplication> getILABySavedAppRefId(Set<Id> setSavedAppRefId) {
		return [
			SELECT
				Id,
				SavedApplicationRefId,
				SavedApplicationRef.FirstName__c,
				SavedApplicationRef.MiddleName__c,
				SavedApplicationRef.LastName__c,
				LicensePermitNameId,
				status,
				Name,
				OwnerId
			FROM IndividualApplication
			WHERE SavedApplicationRefId IN :setSavedAppRefId
			WITH SECURITY_ENFORCED
		];
	}

	/**
	 * @author                      : MTX Group Product Team
	 * @since                       : 18 Jan, 2023
	 * @description                 : This method contains DAO methods for IndividualApplication object
	 * @param setOfBLIds            : Set of LicensePermitNameId (BL ID's)
	 * @param setOfApplicationType  : Set of ApplicationType
	 * @param setOfStatus           : Set of Status
	 * @param setOfPARIds           : Set of SavedApplicationRefId (PAR ID's)
	 * @last modified by            : MTX Group Product Team
	 * @last modified date          : (Add if modified by you)
	 * @last modified details       : (Add if modified by you)
	 */
	public static List<IndividualApplication> getIAByBLIdsApplicationTypeStatusAndPARIds(
		Set<String> setOfBLIds,
		Set<String> setOfApplicationType,
		Set<String> setOfStatus,
		Set<Id> setOfPARIds
	) {
		return [
			SELECT Id, Name
			FROM IndividualApplication
			WHERE
				LicensePermitNameId IN :setOfBLIds
				AND ApplicationType IN :setOfApplicationType
				AND Status NOT IN :setOfStatus
				AND SavedApplicationRefId IN :setOfPARIds
		];
	}

	/**
	 * @author                      : MTX Group Product Team
	 * @since                       :
	 * @description                 : This method contains DAO methods for IndividualApplication object
	 * @param  listIAId     		: List of IA Id
	 * @last modified by            : MTX Group Product Team
	 * @last modified date          : 18 july, 2023
	 * @last modified details       : Added two fields in the query
	 */
	public static List<IndividualApplication> getILAByIAId(Set<Id> listIAId) {
		return [
			SELECT
				Id,
				RecordTypeId,
				Account.Name,
				LicenseType.Name,
				LicensePermitNameId,
				LicensePermitName.Name,
				LicensePermitName.Contact_prior_to_renewal__c,
				ApplicationType,
				Amendment_Type__c,
				SavedApplicationRef.Change_Status_to__c,
				SavedApplicationRef.Is_Auto_Approval_Allowed__c,
				License_Type_Name__c,
				License_Questions__c,
				ApprovedDate,
				SavedApplicationRef.Business_License__c,
				SavedApplicationRefId,
				Name,
				Status,
				AccountId,
				LicenseType.IssuingDepartment.Name,
				Issue_Temp_License__c,
				Are_you_Currently_Employeed__c,
				LicensePermitName.Last_Name__c,
				LicensePermitName.Middle_Name__c,
				LicensePermitName.First_Name__c,
				LicensePermitName.Maiden_Name__c,
				First_Name__c,
				Last_Name__c,
				Middle_Name__c,
				Maiden_Name__c,
				Applicant_submission_Date__c,
				Disciplinary_Status__c,
				SavedApplicationRef.License_Questions__c,
				Consent_for_Primary_Contact_Address__c,
				Account.PersonEmail,
				Info_About_Military_Related_Services__c,
				Served_In_US_Armed_Force__c,
				LicenseType.IssuingDepartment.OnBase_Mapping_Specs__c,
				LicenseType.Email_Specifications_Final__c,
				Account.PersonContactId,
				LicenseType.IssuingDepartment.ED_To_Approve__c,
				OwnerId,
				Temporary_License_Number__c,
				Hold_Active_License__c,
				Board_Name__c
			FROM IndividualApplication
			WHERE Id IN :listIAId
			WITH SECURITY_ENFORCED
		];
	}

	/****************************************** Without Security SOQL STARTS **************************************************/

	/**
	 * @description       : Without Security Inner class for Individual Application.
	 *
	 * @author            : MTX Group Product Team
	 * @last modified on  : 07-26-2024
	 * @last modified by  : MTX Group Product Team
	 **/
	public without sharing class LPI_DAO_IndividualApptWithoutSecurity {
		/**
		 * @author                      : MTX Group Product Team
		 * @since                       : 10 Jan, 2023
		 * @description                 : This method contains DAO methods for IndividualApplication object
		 * @param  setSavedAppRefId     : Set of SavedApplicationRefId (PAR ID's)
		 * @last modified by            : MTX Group Product Team
		 * @last modified date          : (Add if modified by you)
		 * @last modified details       : (Add if modified by you)
		 */
		public List<IndividualApplication> getILABySavedAppRefId(Set<Id> setSavedAppRefId) {
			return [
				SELECT Id, SavedApplicationRefId, First_Name__c, Middle_Name__c, Last_Name__c
				FROM IndividualApplication
				WHERE SavedApplicationRefId IN :setSavedAppRefId
				WITH SECURITY_ENFORCED
			];
		}
		/**
		 * description : To fetch Individual Application
		 * Created by :MTX Group Product Team
		 * Date : 11-18-2022
		 */
		public IndividualApplication getindividualApplicationDetails(Id iaId) {
			return [
				SELECT
					Id,
					Account.PersonContactId,
					Status,
					SavedApplicationRefId,
					Amendment_Type__c,
					ApplicationType,
					RecordType.Name,
					Name,
					LicenseType.Name,
					SavedApplicationRef.Change_Status_to__c,
					SavedApplicationRef.SavedApplicationUrl,
					LicenseType.IssuingDepartment.Name,
					//LicensePermitName.Grandfather_Indicator__c,
					//LicensePermitName.Restriction__c,
					LicenseType.IssuingDepartment.OnBase_Mapping_Specs__c,
					LicenseType.Email_Specifications_Final__c
				FROM IndividualApplication
				WHERE Id = :iaId
				WITH SECURITY_ENFORCED
			];
		}
		/**
		 * @author                      : MTX Group Product Team
		 * @since                       :
		 * @description                 : Dynamic Query Get IndividualApplication fields by different where clauses.
		 * @param  fields             	: fields with (,) separated
		 * @param  whereClause          : where condition (Ex: Name = 'Nitesh' AND Status = 'Active')
		 * @param  limitValue          	: any limit otherwise pass null
		 * @param  sortingByFields      : fields name from which you have to sort otherwise pass null
		 * @param  sortingOrder      	: order of sorting (asc or desc) accept only two value otehr wise pass null
		 * @last modified by            : MTX Group Product Team
		 * @last modified date          : (Add if modified by you)
		 * @last modified details       : (Add if modified by you)
		 */
		public List<IndividualApplication> getIndividualApplicationByDymanicQuery(
			String fields,
			String whereClause,
			String limitValue,
			String sortingByFields,
			String sortingOrder
		) {
			String query = 'SELECT ';
			query += fields;
			query += ' FROM IndividualApplication ';
			query += 'WHERE ' + whereClause + ' WITH SECURITY_ENFORCED ';
			if (sortingByFields != null) {
				query += ' ORDER BY ' + sortingByFields;
				if (sortingOrder != null) {
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
		 * @since                       :
		 * @description                 : Dynamic Query Get IndividualApplication fields by different where clauses.
		 * @param  fields             	: fields with (,) separated
		 * @param  whereClause          : where condition (Ex: Name = 'Nitesh' AND Status = 'Active')
		 * @param  limitValue          	: any limit otherwise pass null
		 * @param  sortingByFields      : fields name from which you have to sort otherwise pass null
		 * @param  sortingOrder      	: order of sorting (asc or desc) accept only two value otehr wise pass null
		 * @last modified by            : MTX Group Product Team
		 * @last modified date          : (Add if modified by you)
		 * @last modified details       : (Add if modified by you)
		 */
		public List<IndividualApplication> getIndividualApplicationByDymanicQueryWithoutSec(
			String fields,
			String whereClause,
			String limitValue,
			String sortingByFields,
			String sortingOrder
		) {
			String query = 'SELECT ';
			query += fields;
			query += ' FROM IndividualApplication ';
			query += 'WHERE ' + whereClause;
			if (sortingByFields != null) {
				query += ' ORDER BY ' + sortingByFields;
				if (sortingOrder != null) {
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