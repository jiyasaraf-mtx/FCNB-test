/**
 * @author          : Vamshi Kumar
 * @description     : This is DAO class for Education_Program_Code_Configuration__c Object
 * @history
 * -------------------------------------------------------------------------------------------------------
 * Version      Date                Author                  Details
 *    1         5 May, 2023       	Vamshi Kumar         	Initial Developement
 * -------------------------------------------------------------------------------------------------------
 */
public with sharing class LPI_EducationProgramConfigDAO {
	public void m1(){}
// 	/**
// 	 * @author                      : Vamshi Kumar
// 	 * @since                       : 5 May, 2023
// 	 * @description                 : Dynamic Query Get Education_Program_Code_Configuration__c fields by different where clauses.
// 	 * @param  fields               : fields with (,) separated
// 	 * @param  whereClause          : where condition (Ex: Name = 'Vamsi' AND Status = 'Active')
// 	 * @param  limitValue           : any limit otherwise pass null
// 	 * @param  sortingByFields      : fields name from which you have to sort otherwise pass null
// 	 * @param  sortingOrder         : order of sorting (asc or desc) accept only two value otehr wise pass null
// 	 * @last modified by            : MTX Group Inc
// 	 * @last modified date          : (Add if modified by you)
// 	 * @last modified details       : (Add if modified by you)
// 	 */
// 	public static List<Education_Program_Code_Configuration__c> getEducationProgramConfigByDynamicQuery(
// 		String fields,
// 		String whereClause,
// 		String limitValue,
// 		String sortingByFields,
// 		String sortingOrder
// 	) {
// 		String query = 'SELECT ';
// 		query += fields;
// 		query += ' FROM Education_Program_Code_Configuration__c ';
// 		query += 'WHERE ' + whereClause + ' WITH SECURITY_ENFORCED ';
// 		if (sortingByFields != null) {
// 			query += ' ORDER BY ' + sortingByFields;
// 			if (sortingOrder != null) {
// 				query += ' ' + sortingOrder + ' ';
// 			}
// 		}
// 		query += ' LIMIT ' + (limitValue != null ? limitValue : '50000');
// 		return Database.query(query);
// 	}

// 	/**
// 	 * @author                      : Vamshi Kumar
// 	 * @since                       : 5 May, 2023
// 	 * @description                 : Dynamic Query Get Education_Program_Code_Configuration__c fields by different where clauses.
// 	 * @param  fields               : fields with (,) separated
// 	 * @param  whereClause          : where condition (Ex: Name = 'Vamsi' AND Status = 'Active')
// 	 * @last modified by            : MTX Group Inc
// 	 * @last modified date          : (Add if modified by you)
// 	 * @last modified details       : (Add if modified by you)
// 	 */
// 	public static List<Education_Program_Code_Configuration__c> getEducationProgramConfigByDynamicQuery(
// 		String fields,
// 		String whereClause){
// 		return getEducationProgramConfigByDynamicQuery(fields, whereClause, null, null, null);
// 	}
}