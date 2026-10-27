/**
 * @description       : DAO for RegulatoryCodeAssessmentInd.
 * @author            : MTX Group Product Team
 * @group             : 
 * @last modified on  : 07-26-2024
 * @last modified by  : MTX Group Product Team
**/
public with sharing class LPI_RegulatoryCodeAssessmentIndDAO {
     /**
    * @description : Method to fetch RegulatoryCodeAssessmentInd records dynamically.
    * @author MTX Group Product Team| 07-24-2023 
    * @param fields 
    * @param whereClause 
    * @param limitValue 
    * @param sortingByFields 
    * @param sortingOrder 
    * @return List<RegulatoryCodeAssessmentInd> 
    **/
    public static List<RegulatoryCodeAssessmentInd> getRegulatoryCodeAssessmentIndByDymanicQuery(
        String fields,
        String whereClause,
        String limitValue,
        String sortingByFields,
        String sortingOrder
    ) {
        String query = 'SELECT ';
        query += fields;
        query += ' FROM RegulatoryCodeAssessmentInd ';
        query += 'WHERE ' + whereClause + ' WITH SECURITY_ENFORCED ';
        if (sortingByFields != null) {
            query += ' ORDER BY ' + sortingByFields;
            if (sortingOrder != null) {
                query += ' ' + sortingOrder + ' ';
            }
        }
       
        query += ' LIMIT ' +  (String.isNotBlank(limitValue) ? limitValue : '50000');
        
        return Database.query(query);
    }
}