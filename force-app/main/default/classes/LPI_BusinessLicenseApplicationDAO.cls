/**
 * @author                      : MTX Group Product Team
 * @since                       : 10 Jan, 2023
 * @description                 : This method contains DAO methods for IndividualApplication object
 * @last modified by            : MTX Group Product Team
 * @last modified date          : 20 Jan, 2023
 * @last modified details       :
 */
public with sharing class LPI_BusinessLicenseApplicationDAO {
	/**
	 * @author                      : MTX Group Product Team
	 * @since                       :
	 * @description                 : Dynamic Query Get BusinessLicenseApplication fields by different where clauses.
	 * @param  fields             	: fields with (,) separated
	 * @param  whereClause          : where condition (Ex: Name = 'Nitesh' AND Status = 'Active')
	 * @param  limitValue          	: any limit otherwise pass null
	 * @param  sortingByFields      : fields name from which you have to sort otherwise pass null
	 * @param  sortingOrder      	: order of sorting (asc or desc) accept only two value otehr wise pass null
	 * @last modified by            : MTX Group Product Team
	 * @last modified date          : (Add if modified by you)
	 * @last modified details       : (Add if modified by you)
	 */
	public static List<BusinessLicenseApplication> getBusinessLicenseApplicationByDymanicQuery(
		String fields,
		String whereClause,
		String limitValue,
		String sortingByFields,
		String sortingOrder
	) {
		String query = 'SELECT ';
		query += fields;
		query += ' FROM BusinessLicenseApplication ';
		query += 'WHERE ' + whereClause + ' WITH SECURITY_ENFORCED ';
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
	 * @description                 : This method contains DAO methods for BusinessLicenseApplication object
	 * @param  setSavedAppRefId     : Set of SavedApplicationRefId (PAR ID's)
	 * @last modified by            : MTX Group Product Team
	 * @last modified date          : (Add if modified by you)
	 * @last modified details       : (Add if modified by you)
	 */
	public static List<BusinessLicenseApplication> getBLABySavedAppRefId(Set<Id> setSavedAppRefId) {
		return [
			SELECT Id, SavedApplicationRefId
			FROM BusinessLicenseApplication
			WHERE SavedApplicationRefId IN :setSavedAppRefId
			WITH SECURITY_ENFORCED
		];
	}

	/**
	 * @author                      : MTX Group Product Team
	 * @since                       : 20 Jan, 2023
	 * @description                 : This method contains DAO methods for BusinessLicenseApplication object
	 * @param  listBLAId            : List of BLA Id (PAR ID's)
	 * @last modified by            : MTX Group Product Team
	 * @last modified date          : (Add if modified by you)
	 * @last modified details       : (Add if modified by you)
	 */
	public static List<BusinessLicenseApplication> getBLAById(Set<Id> listBLAId) {
		return [
			SELECT
				Id,
				SavedApplicationRefId,
				Name,
				Applicant.AccountId,
				Applicant.Account.PersonEmail,
				AccountId,
				LicenseTypeId,
				ApplicationType,
				LicenseType.IssuingDepartment.Name,
				LicensePermitNameId,
				LicenseType.Name,
				LicensePermitName.Name,
				SavedApplicationRef.Employee_Information_ACR_Ids__c,
				Rejection_Reason__c,
				Amendment_Type__c,
				SavedApplicationRef.License_Questions__c,
				LicenseType.IssuingDepartment.OnBase_Mapping_Specs__c,
				LicenseType.Email_Specifications_Final__c,
				Applicant.Name,
				Applicant.Account.Name,
				Status,
				LicenseType.IssuingDepartment.ED_To_Approve__c,
				Issue_Temp_License__c,
				Temporary_License_Number__c
			FROM BusinessLicenseApplication
			WHERE Id IN :listBLAId
			WITH SECURITY_ENFORCED
		];
	}

	/****************************************** Without Security SOQL STARTS **************************************************/

	/**
	 * @description       : Without Security Inner class for Business License Application.
	 *
	 * @author            : MTX Group Product Team
	 * @last modified on  : 07-26-2024
	 * @last modified by  : MTX Group Product Team
	 **/
	public without sharing class LPI_DAO_BusinessLiceWithoutSecurity {

		/**
		 * @author                      : MTX Group Product Team
		 * @since                       : 10 Jan, 2023
		 * @description                 : This method contains DAO methods for BusinessLicenseApplication object
		 * @param  setSavedAppRefId     : Set of SavedApplicationRefId (PAR ID's)
		 * @last modified by            : MTX Group Product Team
		 * @last modified date          : (Add if modified by you)
		 * @last modified details       : (Add if modified by you)
		 */
		public List<BusinessLicenseApplication> getBLABySavedAppRefId(Set<Id> setSavedAppRefId) {
			return [
				SELECT Id, SavedApplicationRefId
				FROM BusinessLicenseApplication
				WHERE SavedApplicationRefId IN :setSavedAppRefId
				WITH SECURITY_ENFORCED
			];
		}
		/**
		 * description : To fetch Business License Application
		 * Created by :MTX Group Product Team
		 * Date : 11-22-2022
		 */
		public BusinessLicenseApplication getBusinessLicenseAppDetails(Id iaId) {
			return [
				SELECT
					Id,
					Status,
					ApplicationType,
					RecordType.Name,
					Name,
					SavedApplicationRefId
				FROM BusinessLicenseApplication
				WHERE Id = :iaId
				WITH SECURITY_ENFORCED
			];
		}
		/**
		 * @author                      : MTX Group Product Team
		 * @since                       :
		 * @description                 : Dynamic Query Get BusinessLicenseApplication fields by different where clauses.
		 * @param  fields             	: fields with (,) separated
		 * @param  whereClause          : where condition (Ex: Name = 'Nitesh' AND Status = 'Active')
		 * @param  limitValue          	: any limit otherwise pass null
		 * @param  sortingByFields      : fields name from which you have to sort otherwise pass null
		 * @param  sortingOrder      	: order of sorting (asc or desc) accept only two value otehr wise pass null
		 * @last modified by            : MTX Group Product Team
		 * @last modified date          : (Add if modified by you)
		 * @last modified details       : (Add if modified by you)
		 */
		public List<BusinessLicenseApplication> getBusinessLicenseApplicationByDymanicQuery(
			String fields,
			String whereClause,
			String limitValue,
			String sortingByFields,
			String sortingOrder
		) {
			String query = 'SELECT ';
			query += fields;
			query += ' FROM BusinessLicenseApplication ';
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
	}
}