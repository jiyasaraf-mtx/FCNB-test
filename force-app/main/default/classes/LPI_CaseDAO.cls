/**
 * @description       : DAO for Case object.
 * @author            : MTX Group Product Team
 * @group             :
 * @last modified on  : 07-26-2024
 * @last modified by  : MTX Group Product Team
 **/
public with sharing class LPI_CaseDAO {
    /**
     * @description : Method to fetch Case records.
     * @author MTX Group Product Team | 01-22-2023
     * @param fieldsToQuery
     * @param whereClause
     * @param limitValue
     * @param orderByClause
     * @return List<Case>
     **/
    public static List<Case> getCaseRecords(
        String fieldsToQuery,
        String whereClause,
        String limitValue,
        String orderByClause
    ) {
        String query = 'SELECT ' + fieldsToQuery + ' FROM Case WHERE ' + whereClause + ' WITH SECURITY_ENFORCED';
        if (String.isNotBlank(orderByClause)) {
            query += ' ORDER BY  ' + orderByClause;
        }
        if (String.isNotBlank(limitValue)) {
            query += ' LIMIT ' + (limitValue != null ? limitValue : '50000');
        }
        return Database.query(query);
    }
    public without sharing class LPI_CaseWithoutSharingDAO {
    /**
       * @description : Method to fetch Case records.
       * @author MTX Group Product Team | 08-29-2023
       * @param fieldsToQuery
       * @param whereClause
       * @param limitValue
       * @param orderByClause
       * @return List<Case>
       **/
      public List<Case> getCaseRecordsWithoutSharing(
          String fieldsToQuery,
          String whereClause,
          String limitValue,
          String orderByClause
      ) {
          String query = 'SELECT ' + fieldsToQuery + ' FROM Case WHERE ' + whereClause ;
          if (String.isNotBlank(orderByClause)) {
              query += ' ORDER BY  ' + orderByClause;
          }
          if (String.isNotBlank(limitValue)) {
              query += ' LIMIT ' + (limitValue != null ? limitValue : '50000');
          }
          return Database.query(query);
      }
  }
}