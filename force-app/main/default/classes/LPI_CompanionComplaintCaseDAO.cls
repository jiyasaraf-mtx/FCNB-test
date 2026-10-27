/**
 * @description       : 
 * @author            : MTX Group Product Team
 * @group             : 
 * @last modified on  : 07-26-2024
 * @last modified by  : MTX Group Product Team
**/
public with sharing class LPI_CompanionComplaintCaseDAO {
    
    public without sharing class LPI_CompanionComplaintCaseWithoutSharingDAO {
        /**
         * @description : Get ComplaintParticipant records by different where clauses and different fields without security enforced
         * @author MTX Group Product Team | 10-23-2023
         * @param whereClause
         * @return List<ComplaintParticipant>
         **/
        public  List<Companion_Complaints_Cases__c> fetchCompanionComplaintWithoutSecurityEnforced(
            String fields,
            String whereClause,
            String limitValue,
            String sortingByFields,
            String sortingOrder
        ) {
            String query = 'SELECT ';
            query += fields;
            query += ' FROM Companion_Complaints_Cases__c ';
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