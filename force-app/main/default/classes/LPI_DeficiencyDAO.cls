/**
 * @description       : 
 * @author            : MTX Group Product Team
 * @group             : 
 * @last modified on  : 07-26-2024
 * @last modified by  : MTX Group Product Team
**/
public with sharing class LPI_DeficiencyDAO {
    
    
    /****************************************** Without Security SOQL STARTS **************************************************/

	/**
	 * @description       : Without Security Inner class for Deficiency
	 *
	 * @author            : MTX Group Product Team
	 * @last modified on  : 07-26-2024
	 * @last modified by  : MTX Group Product Team
	 **/
	public without sharing class LPI_DeficiencyWithoutSharingDAO {
        /**
         * @author                      : MTX Group Product Team
         * @since                       : 8 Oct 2023
         * @description                 : Dynamic Query Get Deficiency fields by different where clauses.
         * @param  fields             	: fields with (,) separated
         * @param  whereClause          : where condition 
         * @param  limitValue          	: any limit otherwise pass null
         * @param  sortingByFields      : fields name from which you have to sort otherwise pass null
         * @param  sortingOrder      	: order of sorting (asc or desc) accept only two value otehr wise pass null
         * @last modified by            : MTX Group Product Team
         * @last modified on            : 07-26-2024
         */
        public List<Deficiency__c> getDeficiencyByDymanicQuery(
            String fields,
            String whereClause,
            String limitValue,
            String sortingByFields,
            String sortingOrder
        ) {
            String query = 'SELECT ';
            query += fields;
            query += ' FROM Deficiency__c ';
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
    }
}