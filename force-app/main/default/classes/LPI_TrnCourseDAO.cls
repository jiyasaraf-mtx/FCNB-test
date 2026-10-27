/**
 * @description       :
 * @author            : MTX Group Product Team
 * @group             :
 * @last modified on  : 07-26-2024
 * @last modified by  : MTX Group Product Team
 **/
public with sharing class LPI_TrnCourseDAO {
	/**
	 * @description
	 * @author MTX Group Product Team | 01-27-2023
	 * @param fields
	 * @param whereClause
	 * @param limitValue
	 * @param sortingByFields
	 * @param sortingOrder
	 * @return List<TrnCourse>
	 **/
	public static List<TrnCourse> getTrnCourseByDymanicQuery(
		String fields,
		String whereClause,
		String limitValue,
		String sortingByFields,
		String sortingOrder
	) {
		String query = 'SELECT ';
		query += fields;
		query += ' FROM TrnCourse ';
		query += 'WHERE ' + whereClause + ' WITH SECURITY_ENFORCED ';
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
	* @description 
	* @author MTX Group Product Team | 01-27-2023 
	* @param accountId 
	* @param courseId 
	* @return List<TrnCourse> 
	**/
	public static List<TrnCourse> getTrnCourseRecordsByCourseIdAndAccountId(
		String accountId,
	 	String courseId
	) {
 	return [
	 		SELECT Id, Name, Course_ID__c
			FROM TrnCourse
			WHERE Course_ID__c LIKE :courseId AND Account__c = :accountId
	 		WITH SECURITY_ENFORCED
	];
	 }
	
}