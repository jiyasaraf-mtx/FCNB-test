/**
 * @description       : DAO for InspectionAssessmentInd.
 * @author            : Mohit Karani
 * @group             : 
 * @last modified on  : 05-06-2024
 * @last modified by  : Ayush Dev
**/
public with sharing class LPI_InspectionAssessmentIndDAO {
   
    /**
    * @description : Method to fetch InspectionAssessmentInd records dynamically.
    * @author Mohit Karani | 07-24-2023 
    * @param fields 
    * @param whereClause 
    * @param limitValue 
    * @param sortingByFields 
    * @param sortingOrder 
    * @return List<InspectionAssessmentInd> 
    **/
    public static List<InspectionAssessmentInd> getInspectionAssessmentIndicatorByDymanicQuery(
        String fields,
        String whereClause,
        String limitValue,
        String sortingByFields,
        String sortingOrder
    ) {
        String query = 'SELECT ';
        query += fields;
        query += ' FROM InspectionAssessmentInd ';
        query += 'WHERE ' + whereClause ;
        if (sortingByFields != null) {
            query += ' ORDER BY ' + sortingByFields;
            if (sortingOrder != null) {
                query += ' ' + sortingOrder + ' ';
            }
        }
        query += ' LIMIT ' +  (String.isNotBlank(limitValue) ? limitValue : '50000');
        return Database.query(query);
    }

    public without sharing class LPI_InspectionAssessIndWithoutSharingDAO {
            /**
            * @description : Method to fetch InspectionAssessmentInd records dynamically.
            * @author Vamsi Mudaliar | 10-05-2023 
            * @param fields 
            * @param whereClause 
            * @param limitValue 
            * @param sortingByFields 
            * @param sortingOrder 
            * @return List<InspectionAssessmentInd> 
            **/
            public List<InspectionAssessmentInd> getInspectionAssessmentIndicatorByDymanicQuery(
                String fields,
                String whereClause,
                String limitValue,
                String sortingByFields,
                String sortingOrder
            ) {
                String query = 'SELECT ';
                query += fields;
                query += ' FROM InspectionAssessmentInd ';
                query += 'WHERE ' + whereClause;
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


}