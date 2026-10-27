/**
 * @description       : This class contains DAO methods for IdentificationCard object
 * @author            : MTX Group Product Team
 * @since             : 03-17-2023
 * @last modified on  : 07-26-2024
 * @last modified by  : MTX Group Product Team
**/
public with sharing class LPI_IdentificationCardDAO {
   

    /****************************************** Without Security SOQL STARTS **************************************************/

    /**
	 * @description       : Without Security Inner class for IdentificationCard
	 * @author            : MTX Group Product Team
	 * @last modified on  : 07-26-2024
	 * @last modified by  : MTX Group Product Team
	 **/
    public without sharing class LPI_IdentificationCardWithoutSharingDAO {
        /**
         * @description 
         * @author                      : Ayushi Sharma | 03-17-2023 
         * @description                 : Dynamic Query Get Account fields by different where clauses.
		 * @param  fields               : fields with (,) separated
		 * @param  whereClause          : where condition (Ex: Name = 'Ayushi' AND Status = 'Active')
		 * @param  limitValue           : any limit otherwise pass null
		 * @param  sortingByFields      : fields name from which you have to sort otherwise pass null
		 * @param  sortingOrder         : order of sorting (asc or desc) accept only two value otehr wise pass null
         * @return                      : List<Identification_Card__c> 
		 * @last modified by            : MTX Group Product Team
		 * @last modified date          : May 24, 2023
		 * @last modified details       : Added conditional operator for limitValue parameter
         */
        public List<Identification_Card__c> getIdentificationCardByDymanicQuery(String fields, String whereClause, String limitValue, 
																					String sortingByFields, String sortingOrder) {
			String query = 'SELECT ' + fields + ' FROM Identification_Card__c WHERE ' + whereClause;
			if (sortingByFields != null) {
				query += ' ORDER BY ' + sortingByFields;
				if (sortingOrder != null) {
					query += ' ' + sortingOrder + ' ';
				}
			}
			query += ' LIMIT ' + (limitValue != null ? limitValue : '50000');
			return Database.query(query);
		}
    }
}