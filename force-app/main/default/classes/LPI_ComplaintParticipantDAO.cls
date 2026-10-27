/**
 * @description       : DAO for ComplaintParticipant.
 * @author            : Mohit Karani
 * @group             :
 * @last modified on  : 10-21-2023
 * @last modified by  : Vamsi Mudaliar
 **/
public with sharing class LPI_ComplaintParticipantDAO {
    /**
     * @description : Get ComplaintParticipant by dynamic query.
     * @author Mohit Karani | 05-24-2023
     * @param fields
     * @param whereClause
     * @param limitValue
     * @param sortingByFields
     * @param sortingOrder
     * @return List<ComplaintParticipant>
     **/
    public static List<ComplaintParticipant> getComplaintParticipantByDymanicQuery(
        String fields,
        String whereClause,
        String limitValue,
        String sortingByFields,
        String sortingOrder
    ) {
        String query = 'SELECT ';
        query += fields;
        query += ' FROM ComplaintParticipant ';
        query += 'WHERE ' + whereClause + ' WITH SECURITY_ENFORCED ';
        if (sortingByFields != null) {
            query += ' ORDER BY ' + sortingByFields;
            if (sortingOrder != null) {
                query += ' ' + sortingOrder + ' ';
            }
        }
        limitValue = String.isNotBlank(limitValue) ? limitValue : '50000';
        query += ' LIMIT ' + limitValue;
        return Database.query(query);
    }

    /**
     * @description : Get ComplaintParticipant records by different where clauses and different fields without security enforced
     * @author Mohit Karani | 01-22-2023
     * @param whereClause
     * @return List<ComplaintParticipant>
     **/
    public static List<ComplaintParticipant> fetchComplaintParticipantsRecordsWithoutSecurityEnforced(
        String fields,
        String whereClause,
        String limitValue,
        String sortingByFields,
        String sortingOrder
    ) {
        String query = 'SELECT ';
        query += fields;
        query += ' FROM ComplaintParticipant ';
        query += 'WHERE ' + whereClause;
        if (sortingByFields != null) {
            query += ' ORDER BY ' + sortingByFields;
            if (sortingOrder != null) {
                query += ' ' + sortingOrder + ' ';
            }
        }
        limitValue = String.isNotBlank(limitValue) ? limitValue : '50000';
        query += ' LIMIT ' + limitValue;
        return Database.query(query);
    }

    public without sharing class LPI_ComplaintParticipantWithoutSharingDAO {
            /**
             * @description : Get ComplaintParticipant records by different where clauses and different fields without security enforced
             * @author Mohit Karani | 01-22-2023
             * @param whereClause
             * @return List<ComplaintParticipant>
             **/
            public  List<ComplaintParticipant> fetchComplaintParticipantsRecordsWithoutSecurityEnforced(
                String fields,
                String whereClause,
                String limitValue,
                String sortingByFields,
                String sortingOrder
            ) {
                String query = 'SELECT ';
                query += fields;
                query += ' FROM ComplaintParticipant ';
                query += 'WHERE ' + whereClause;
                if (sortingByFields != null) {
                    query += ' ORDER BY ' + sortingByFields;
                    if (sortingOrder != null) {
                        query += ' ' + sortingOrder + ' ';
                    }
                }
                limitValue = String.isNotBlank(limitValue) ? limitValue : '50000';
                query += ' LIMIT ' + limitValue;
                return Database.query(query);
            }
    }


}