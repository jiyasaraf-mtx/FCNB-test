/**
* @description       : 
* @author            : Vamsi Mudaliar
* @group             : 
* @last modified on  : 04-04-2024
* @last modified by  : Amit Agrawal
**/
public with sharing class LPI_PersonExaminationDAO { 
    /**
     * @author                      : Vamsi Mudaliar
     * @since                       : 
     * @description                 : Dynamic Query Get PersonExamination fields by different where clauses.
     * @param  fields             	: fields with (,) separated
     * @param  whereClause          : where condition (Ex: Name = 'Vamsi' AND Status = 'Active')
     * @param  limitValue          	: any limit otherwise pass null
     * @param  sortingByFields      : fields name from which you have to sort otherwise pass null
     * @param  sortingOrder      	: order of sorting (asc or desc) accept only two value otehr wise pass null
	 * @last modified by            : Amit Agrawal
	 * @last modified date          : May 24, 2023
	 * @last modified details       : Added conditional operator for limitValue parameter
     */
    public static List<PersonExamination> getPersonExaminationByDynamicQuery(String fields, String whereClause, String limitValue, 
                                                                                String sortingByFields, String sortingOrder) {
        String query = 'SELECT ' + fields + ' FROM PersonExamination WHERE ' + whereClause + ' WITH SECURITY_ENFORCED ';
        if (sortingByFields != null) {
            query += ' ORDER BY ' + sortingByFields;
            if (sortingOrder != null) {
                query += ' ' + sortingOrder + ' ';
            }
        }
        query += ' LIMIT ' + (limitValue != null ? limitValue : '50000');                                                                                                                                                   
        return Database.query(query);
    }

    /**
     * @author                      : kirti Agrawal
     * @since                       : 21 Feb, 2023
     * @description                 : This method is to get PersonExamination related to PAR records
     * @param  setPARId             : Takes Set of PAR Id's
     * @return                      : returns List<PersonExamination> associated to PAR record
	 * @last modified by            : Amit Agrawal
	 * @last modified date          : May 24, 2023
	 * @last modified details       : Code Beautification
     */
    public static List<PersonExamination> getPersonExaminationByParId(Set<Id> setPARId){
        return [
            SELECT Id, Preliminary_Application_Reference__c, Individual_Application__c
            FROM PersonExamination
            WHERE Preliminary_Application_Reference__c IN :setPARId
            WITH SECURITY_ENFORCED
        ];
    }
    
    /****************************************** Without Security SOQL STARTS **************************************************/

	public without sharing class LPI_PersonExaminationWithoutSharingDAO {
        /**
         * @author                      : Vamsi Mudaliar
	     * @since                       : 03-10-2023
         * @description                 : Dynamic Query Get PersonExamination fields by different where clauses.
         * @param  fields             	: fields with (,) separated
         * @param  whereClause          : where condition (Ex: Name = 'Nitesh' AND Status = 'Active')
         * @param  limitValue          	: any limit otherwise pass null
         * @param  sortingByFields      : fields name from which you have to sort otherwise pass null
         * @param  sortingOrder      	: order of sorting (asc or desc) accept only two value otehr wise pass null
	     * @last modified by            : Amit Agrawal
	     * @last modified date          : May 24, 2023
	     * @last modified details       : Added conditional operator for limitValue parameter 
         */
        public List<PersonExamination> getPersonExaminationByDynamicQuery(String fields, String whereClause, String limitValue, 
                                                                                String sortingByFields, String sortingOrder) {
			String query = 'SELECT ' + fields + ' FROM PersonExamination WHERE ' + whereClause;
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