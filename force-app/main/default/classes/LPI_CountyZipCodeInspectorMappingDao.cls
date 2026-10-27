/**
 * @description       : DAO For County_ZipCode_Inspector_Mapping__c
 * @author            : MTX Group Product Team
 * @group             : 
 * @last modified on  : 07-26-2024
 * @last modified by  : MTX Group Product Team
**/
public with sharing class LPI_CountyZipCodeInspectorMappingDao {

    /**
    * @description : Method to fetch County_ZipCode_Inspector_Mapping__c records by dynamic query.
    * @author MTX Group Product Team | 07-28-2023 
    * @param fields 
    * @param whereClause 
    * @param limitValue 
    * @param sortingByFields 
    * @param sortingOrder 
    * @return List<County_ZipCode_Inspector_Mapping__c> 
    **/
    public static List<County_ZipCode_Inspector_Mapping__c> getCountyZipCodeInspectorByDynamicQuery(
		String fields,
		String whereClause,
		String limitValue,
		String sortingByFields,
		String sortingOrder
	) {
		String query = 'SELECT ';
		query += fields;
		query += ' FROM County_ZipCode_Inspector_Mapping__c ';
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


	public without sharing class LPI_CountyZipCodeInspectorMappingWithoutSharingDao {


		 /**
		* @description : Method to fetch County_ZipCode_Inspector_Mapping__c records by dynamic query.
		* @author MTX Group Product Team | 07-28-2023 
		* @param fields 
		* @param whereClause 
		* @param limitValue 
		* @param sortingByFields 
		* @param sortingOrder 
		* @return List<County_ZipCode_Inspector_Mapping__c> 
		**/
		public List<County_ZipCode_Inspector_Mapping__c> getCountyZipCodeInspectorByDynamicQuery(
			String fields,
			String whereClause,
			String limitValue,
			String sortingByFields,
			String sortingOrder
		) {
			String query = 'SELECT ';
			query += fields;
			query += ' FROM County_ZipCode_Inspector_Mapping__c ';
			query += 'WHERE ' + whereClause ;
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