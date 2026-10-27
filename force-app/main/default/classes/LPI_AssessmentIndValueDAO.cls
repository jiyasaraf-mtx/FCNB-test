/**
 * @description       : DAO for AssessmentIndValue.
 * @author            : Mohit Karani
 * @group             : 
 * @last modified on  : 05-06-2024
 * @last modified by  : Ayush Dev
**/
public with sharing class LPI_AssessmentIndValueDAO {
    
     /**
    * @description : Method to fetch AssessmentIndValue records dynamically.
    * @author Mohit Karani | 07-24-2023 
    * @param fields 
    * @param whereClause 
    * @param limitValue 
    * @param sortingByFields 
    * @param sortingOrder 
    * @return List<AssessmentIndValue> 
    **/
    public static List<AssessmentIndValue> getAssessmentIndValueByDymanicQuery(
        String fields,
        String whereClause,
        String limitValue,
        String sortingByFields,
        String sortingOrder
    ) {
        String query = 'SELECT ';
        query += fields;
        query += ' FROM AssessmentIndValue ';
        query += 'WHERE ' + whereClause + ' WITH SECURITY_ENFORCED ';
        if (sortingByFields != null) {
            query += ' ORDER BY ' + sortingByFields;
            if (sortingOrder != null) {
                query += ' ' + sortingOrder + ' ';
            }
        }
        if (limitValue != null) {
            query += ' LIMIT ' + (limitValue != null ? limitValue : '50000');
        }
        return Database.query(query);
    }
    public without sharing class LPI_AssessmentIndValueWithoutSharingDAO {
        /**
        * @description : Method to fetch AssessmentIndValue records dynamically.
        * @author Mohit Karani | 07-24-2023 
        * @param fields 
        * @param whereClause 
        * @param limitValue 
        * @param sortingByFields 
        * @param sortingOrder 
        * @return List<AssessmentIndValue> 
        **/
        public List<AssessmentIndValue> getAssessmentIndValueByDymanicQuery(
            String fields,
            String whereClause,
            String limitValue,
            String sortingByFields,
            String sortingOrder) {
            String query = 'SELECT ';
            query += fields;
            query += ' FROM AssessmentIndValue ';
            query += 'WHERE ' + whereClause;
            if (sortingByFields != null) {
                query += ' ORDER BY ' + sortingByFields;
                if (sortingOrder != null) {
                    query += ' ' + sortingOrder + ' ';
                }
            }
            if (limitValue != null) {
                query += ' LIMIT ' + (limitValue != null ? limitValue : '50000');
            }
            return Database.query(query);
        }

    }
}