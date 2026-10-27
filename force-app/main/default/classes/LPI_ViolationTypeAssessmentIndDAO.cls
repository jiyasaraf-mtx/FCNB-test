/**
 * @description       : DAO for ViolationTypeAssessmentInd
 * @author            : MTX Group Product Team
 * @group             : 
 * @last modified on  : 07-26-2024
 * @last modified by  : MTX Group Product Team
**/
public with sharing class LPI_ViolationTypeAssessmentIndDAO {

    /**
    * @description : Method to fetch ViolationTypeAssessmentInd records dynamically.
    * @author MTX Group Product Team | 07-24-2023 
    * @param fields 
    * @param whereClause 
    * @param limitValue 
    * @param sortingByFields 
    * @param sortingOrder 
    * @return List<ViolationTypeAssessmentInd> 
    **/
    public static List<ViolationTypeAssessmentInd> getViolationTypeAssessmentIndByDymanicQuery(
        String fields,
        String whereClause,
        String limitValue,
        String sortingByFields,
        String sortingOrder
    ) {
        String query = 'SELECT ';
        query += fields;
        query += ' FROM ViolationTypeAssessmentInd ';
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