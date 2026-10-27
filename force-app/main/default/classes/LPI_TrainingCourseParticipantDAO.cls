/**
 * @author                      : Manish Kumar Singh
 * @since                       : 31 Jan, 2023
 * @description                 : This class contains DAO methods for Application_Document__c object
 * @last modified by            : MTX Group Inc.
 * @last modified date          : 
 * @last modified details       : 
 */
public with sharing class LPI_TrainingCourseParticipantDAO {
    private static final String SOQL_ROW_LIMIT = '50000';
     /**
     * @author                      : Manish Kumar Singh
     * @since                       : 
     * @description                 : Dynamic Query Get TrainingCourseParticipant fields by different where clauses.
     * @param  fields             	: fields with (,) separated
     * @param  whereClause          : where condition (Ex: Name = 'Nitesh' AND Status = 'Active')
     * @param  limitValue          	: any limit otherwise pass null
     * @param  sortingByFields      : fields name from which you have to sort otherwise pass null
     * @param  sortingOrder      	: order of sorting (asc or desc) accept only two value otehr wise pass null
     * @last modified by            : MTX Group Inc.
     * @last modified date          : (Add if modified by you)
     * @last modified details       : (Add if modified by you)
     */
    public static List<TrainingCourseParticipant> getTrainingCourseParticipantByDymanicQuery(String fields,
                                                                                String whereClause,
                                                                                String limitValue,
                                                                               	String sortingByFields,
                                                                               	String sortingOrder){
        String query = 'SELECT ';
        query += fields;
        query += ' FROM TrainingCourseParticipant ';
        query += 'WHERE ' + whereClause + ' WITH SECURITY_ENFORCED ';
        if(sortingByFields != null){
        	query += ' ORDER BY ' + sortingByFields;
            if(sortingOrder != null){
                query += ' ' + sortingOrder + ' ';
            }
        }                                                                             
        query += ' LIMIT ' + (limitValue != null ? limitValue : SOQL_ROW_LIMIT);
        return Database.query(query);
    }
    
    /**
	 * @description       : Without Security Inner class for TrainingCourseParticipant
	 *
	 * @author            : Rachna Jadam
	 * @last modified on  : 05-02-2024
	 * @last modified by  : MTX Group Inc.
	 **/
    public without sharing class LPI_TrainingCourseParticipantWithoutSharingDAO {
        /**
         * @author                      : Rachna Jadam
         * @since                       : 
         * @description                 : Dynamic Query Get TrainingCourseParticipant fields by different where clauses.
         * @param  fields             	: fields with (,) separated
         * @param  whereClause          : where condition (Ex: Name = 'Nitesh' AND Status = 'Active')
         * @param  limitValue          	: any limit otherwise pass null
         * @param  sortingByFields      : fields name from which you have to sort otherwise pass null
         * @param  sortingOrder      	: order of sorting (asc or desc) accept only two value otehr wise pass null
         * @last modified by            : MTX Group Inc.
         * @last modified date          : (Add if modified by you)
         * @last modified details       : (Add if modified by you)
         */
        public List<TrainingCourseParticipant> getTrainingCourseParticipantByDymanicQuery(String fields,
                                                                                    String whereClause,
                                                                                    String limitValue,
                                                                                    String sortingByFields,
                                                                                    String sortingOrder){
            String query = 'SELECT ';
            query += fields;
            query += ' FROM TrainingCourseParticipant ';
            query += 'WHERE ' + whereClause + ' WITH SECURITY_ENFORCED ';
            if(sortingByFields != null){
                query += ' ORDER BY ' + sortingByFields;
                if(sortingOrder != null){
                    query += ' ' + sortingOrder + ' ';
                }
            }                                                                             
            query += ' LIMIT ' + (limitValue != null ? limitValue : SOQL_ROW_LIMIT);
            return Database.query(query);
        }
    }
}