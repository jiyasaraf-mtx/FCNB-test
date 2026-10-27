/**
 * @description       : DAO Class for Regulatory_Examination_Junction__c.
 * @author            : MTX Group Product Team
 * @group             :
 * @last modified on  : 07-26-2024
 * @last modified by  : MTX Group Product Team
 **/
public with sharing class LPI_RegExamJnDAO {
    /**
     * @description : Get Regulatory_Examination_Junction__c records by different where clauses and different fields.
     * @author MTX Group Product Team | 03-30-2023
     * @param fieldsToQuery
     * @param whereClause
     * @return List<Regulatory_Examination_Junction__c>
     **/
    public static List<Regulatory_Examination_Junction__c> fetchRegExamJnRecords(
        String fieldsToQuery,
        String whereClause
    ) {
        String query = 'SELECT ' + fieldsToQuery;
        query += ' FROM Regulatory_Examination_Junction__c ';
        query += ' WHERE ' + whereClause + ' WITH SECURITY_ENFORCED';
        return Database.query(query);
    }
}