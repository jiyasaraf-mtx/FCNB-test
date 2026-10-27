/**
 * @description       : DAO class for CaseParticipant.
 * @author            : Mohit Karani
 * @group             : 
 * @last modified on  : 07-13-2024
 * @last modified by  : Uzma Md
**/
public with sharing class LPI_CaseParticipantDao {
   
    /**
     * @description : Get CaseParticipant records by different where clauses and different fields.
     * @author Mohit Karani | 01-22-2023
     * @param whereClause
     * @return List<CaseParticipant>
     **/
    // public static List<CaseParticipant> fetchCaseParticipantsRecords(
    //     String fields,
    //     String whereClause,
    //     String limitValue,
    //     String sortingByFields,
    //     String sortingOrder
    // ) {
    //     String query = 'SELECT ';
    //     query += fields;
    //     query += ' FROM CaseParticipant ';
    //     query += 'WHERE ' + whereClause + ' WITH SECURITY_ENFORCED ';
    //     if(sortingByFields != null){
    //     	query += ' ORDER BY ' + sortingByFields;
    //         if(sortingOrder != null){
    //             query += ' ' + sortingOrder + ' ';
    //         }
    //     }   
    //     limitValue = String.isNotBlank(limitValue) ? limitValue : '50000';                                                                         
    //     query += ' LIMIT ' + limitValue;
    //     return Database.query(query);
    // }

    /**
     * @description : Get CaseParticipant records by different where clauses and different fields without security enforced
     * @author Mohit Karani | 01-22-2023
     * @param whereClause
     * @return List<CaseParticipant>
     **/
    public static List<CaseParticipant> fetchCaseParticipantsRecordsWithoutSecurityEnforced(
        String fields,
        String whereClause,
        String limitValue,
        String sortingByFields,
        String sortingOrder
    ) {
        String query = 'SELECT ';
        query += fields;
        query += ' FROM CaseParticipant ';
        query += 'WHERE ' + whereClause ;
        if(sortingByFields != null){
        	query += ' ORDER BY ' + sortingByFields;
            if(sortingOrder != null){
                query += ' ' + sortingOrder + ' ';
            }
        }   
        limitValue = String.isNotBlank(limitValue) ? limitValue : '50000';                                                                         
        query += ' LIMIT ' + limitValue;
        return Database.query(query);
    }

}