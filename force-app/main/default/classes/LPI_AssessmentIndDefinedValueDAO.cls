/**
 * @description       : DAO for AssessmentIndDefinedValue.
 * @author            : Mohit Karani
 * @group             : 
 * @last modified on  : 10-05-2023
 * @last modified by  : Vamsi Mudaliar
**/
public with sharing class LPI_AssessmentIndDefinedValueDAO {

    /**
    * @description : Method to fetch AssessmentIndDefinedValue records using a dynamic query.
    * @author Mohit Karani | 07-24-2023 
    * @param fields 
    * @param whereClause 
    * @param limitValue 
    * @param sortingByFields 
    * @param sortingOrder 
    * @return List<AssessmentIndDefinedValue> 
    **/
    public static List<AssessmentIndDefinedValue> getAssessmentIndDefinedValueByDymanicQuery(
        String fields,
        String whereClause,
        String limitValue,
        String sortingByFields,
        String sortingOrder
    ) {
        String query = 'SELECT ';
        query += fields;
        query += ' FROM AssessmentIndDefinedValue ';
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

    public without sharing class LPI_AssessmentIndDefinedValueWithoutsharingDAO {
        /**
        * @description : Method to fetch AssessmentIndDefinedValue records using a dynamic query.
        * @author Mohit Karani | 07-24-2023 
        * @param fields 
        * @param whereClause 
        * @param limitValue 
        * @param sortingByFields 
        * @param sortingOrder 
        * @return List<AssessmentIndDefinedValue> 
        **/
        public  List<AssessmentIndDefinedValue> getAssessmentIndDefinedValueByDymanicQuery(
            String fields,
            String whereClause,
            String limitValue,
            String sortingByFields,
            String sortingOrder
        ) {
            String query = 'SELECT ';
            query += fields;
            query += ' FROM AssessmentIndDefinedValue ';
            query += 'WHERE ' + whereClause;
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