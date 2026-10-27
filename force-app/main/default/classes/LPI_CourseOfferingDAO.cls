/**
 * @description       :
 * @author            : MTX Group Product Team
 * @group             :
 * @last modified on  : 07-26-2024
 * @last modified by  : MTX Group Product Team
 **/
public with sharing class LPI_CourseOfferingDAO {
	private static final String SOQL_ROW_LIMIT = '50000';
	/**
	 * @description
	 * @author MTX Group Product Team
	 * @param fields
	 * @param whereClause
	 * @param limitValue
	 * @param sortingByFields
	 * @param sortingOrder
	 * @return List<CourseOffering>
	 **/
	public static List<CourseOffering> getCourseOfferingByDymanicQuery(
		String fields,
		String whereClause,
		String limitValue,
		String sortingByFields,
		String sortingOrder
	) {
		String query = 'SELECT ';
		query += fields;
		query += ' FROM CourseOffering ';
		query += 'WHERE ' + whereClause + ' WITH SECURITY_ENFORCED ';
		if (sortingByFields != null) {
			query += ' ORDER BY ' + sortingByFields;
			if (sortingOrder != null) {
				query += ' ' + sortingOrder + ' ';
			}
		}
		query += ' LIMIT ' + (limitValue != null ? limitValue : SOQL_ROW_LIMIT);
		return Database.query(query);
	}

	/**
	 * @description
	 * @author MTX Group Product Team
	 * @param parId
	 * @return List<CourseOffering>
	 **/
	public static List<CourseOffering> getCourseOfferingRecordsByParId(String parId) {
		return [
			SELECT
				Id,
				StartDate,
				EndDate,
				Month__c,
				Year__c,
				Class_Start_Time__c,
				Name_of_the_Instructor__c,
				LocationId,
				CourseName.Name,
				CourseName.Id,
				CourseName.Course_ID__c,
				CourseNameId,
				Preliminary_Application_Reference__c
			FROM CourseOffering
			WHERE Preliminary_Application_Reference__c = :parId
			WITH SECURITY_ENFORCED
		];
	}

	/**
	 * @description
	 * @author MTX Group Product Team
	 * @param parId
	 * @param setOfCourseOfferingId
	 * @return List<CourseOffering>
	 **/
	public static List<CourseOffering> getCourseOfferingRecordsByCourseOfferingAndParID(
		String parId,
		List<CourseOffering> listOfCourseOfferingforDeletion
	) {
		return [
			SELECT Id, Preliminary_Application_Reference__c
			FROM CourseOffering
			WHERE Preliminary_Application_Reference__c = :parId AND Id NOT IN :listOfCourseOfferingForDeletion
			WITH SECURITY_ENFORCED
		];
	}
    
    /**
	 * @description       : Without Security Inner class for CourseOffering
	 *
	 * @author            : MTX Group Product Team
	 * @last modified on  : 07-26-2024
	 * @last modified by  : MTX Group Product Team
	 **/
    public without sharing class LPI_CourseOfferingWithoutSharingDAO {
        /**
         * @author                      : MTX Group Product Team
         * @since                       : 27 Jan, 2023
         * @description                 : This method return the List of CourseOffering records by course Informations
         * @param  schoolId             : School account Id
         * @param  courseId             : Course_ID__c value of the course
         * @param  courseTitle          : Course title
         * @param  endDate              : course completion Date
         * @param  courseType           : course type 
         * @param  course               : course id
         * @param  instructorName       : course instructor name
         * @return                      : List<CourseOffering>
         * @last modified by            : MTX Group Product Team
         * @last modified date          : (Add if modified by you)
         * @last modified details       : (Add if modified by you)
         */
        public List<CourseOffering> getCourseOfferingByCourseInfo(String schoolId, String courseId, String courseTitle,
            Date endDate, String courseType, String course, String instructorName) {
            return [SELECT
                    Id,
                    CourseName.Course_ID__c,
                    CourseName.Name,
                    EndDate,
                    CourseName.Course_Type__c,
                    CourseName.Course__c,
                    LocationId
                FROM CourseOffering
                WHERE
                    CourseName.Account__c = :schoolId
                    AND CourseName.Course_ID__c = :courseId
                    AND CourseName.Name = :courseTitle
                    AND DAY_ONLY(EndDate) = :endDate
                    AND CourseName.Course_Type__c = :courseType
                    AND CourseName.Course__c = :course
                    AND Name_of_the_Instructor__c = :instructorName
                WITH SECURITY_ENFORCED];
        }
        
        /**
         * @description
         * @author MTX Group Product Team
         * @param fields
         * @param whereClause
         * @param limitValue
         * @param sortingByFields
         * @param sortingOrder
         * @return List<CourseOffering>
         **/
        public List<CourseOffering> getCourseOfferingByDymanicQuery(
            String fields,
            String whereClause,
            String limitValue,
            String sortingByFields,
            String sortingOrder
        ) {
            String query = 'SELECT ';
            query += fields;
            query += ' FROM CourseOffering ';
            query += 'WHERE ' + whereClause + ' WITH SECURITY_ENFORCED ';
            if (sortingByFields != null) {
                query += ' ORDER BY ' + sortingByFields;
                if (sortingOrder != null) {
                    query += ' ' + sortingOrder + ' ';
                }
            }
            query += ' LIMIT ' + (limitValue != null ? limitValue : SOQL_ROW_LIMIT);
            return Database.query(query);
        }
    }
}