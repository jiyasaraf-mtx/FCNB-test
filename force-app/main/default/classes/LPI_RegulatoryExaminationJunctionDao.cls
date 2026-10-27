/**
 * @description       : DAO class for Regulatory_Examination_Junction__c
 * @author            : MTX Group Product Team
 * @group             :
 * @last modified on  : 07-26-2024
 * @last modified by  : MTX Group Product Team
 **/
public with sharing class LPI_RegulatoryExaminationJunctionDao {
    /**
     * @description : Method to fetch Regulatory_Examination_Junction__c in without sharing context.
     * @author MTX Group Product Team| 04-11-2023
     * @param fields
     * @param whereClause
     * @param limitValue
     * @param sortingByFields
     * @param sortingOrder
     * @return List<Regulatory_Examination_Junction__c>
     **/
    public static List<Regulatory_Examination_Junction__c> getRegulatoryExaminationJunctionByDymanicQuery(
        String fields,
        String whereClause,
        String limitValue,
        String sortingByFields,
        String sortingOrder
    ) {
        String query = 'SELECT ' + fields +  ' FROM Regulatory_Examination_Junction__c WHERE ' + whereClause + ' WITH SECURITY_ENFORCED ';
        if (sortingByFields != null) {
            query += ' ORDER BY ' + sortingByFields;
            if (sortingOrder != null) {
                query += ' ' + sortingOrder + ' ';
            }
        }
        if (limitValue != null) {
            query += ' LIMIT ' + limitValue;
        }
        return Database.query(query);
    }
}