/**
 * @description       : QuestionDetails DAO class.
 * @author            : MTX Group Product Team
 * @group             : 
 * @last modified on  : 07-26-2024
 * @last modified by  : MTX Group Product Team
**/
public with sharing class LPI_QuestionDetailsDAO {
        /**
        * @description 
        * @author MTX Group Product Team | 05-02-2024 
        * @param fields 
        * @param whereClause 
        * @param limitValue 
        * @param sortingByFields 
        * @param sortingOrder 
        * @return List<Question_Detail__c> 
        **/
        public static List<Question_Detail__c> getQuestionDetailsByDynamicQuery(String fields,
        String whereClause,
        String limitValue,
        String sortingByFields,
        String sortingOrder
    ) {
        String query = 'SELECT ';
        query += fields;
        query += ' FROM Question_Detail__c ';
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
}