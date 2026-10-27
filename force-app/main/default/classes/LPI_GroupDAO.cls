/**
 * @description       : DAO for Group
 * @author            : MTX Group Product Team
 * @group             :
 * @last modified on  : 07-26-2024
 * @last modified by  : MTX Group Product Team
 **/

public with sharing class LPI_GroupDAO {
    /**
     * @description : Method to fetch Group records.
     * @author MTX Group Product Team | 01-22-2023
     * @param fieldsToQuery
     * @param whereClause
     * @param limitValue
     * @param orderByClause
     * @return List<Group>
     **/
    public static List<Group> getGroups(
        String fieldsToQuery,
        String whereClause,
        String limitValue,
        String orderByClause
    ) {
        String query = 'SELECT ' + fieldsToQuery + ' FROM Group WHERE ' + whereClause + ' WITH SECURITY_ENFORCED';
        if (String.isNotBlank(orderByClause)) {
            query += ' ORDER BY  ' + orderByClause;
        }
        if (String.isNotBlank(limitValue)) {
            query += ' LIMIT ' + (limitValue != null ? limitValue : '50000');
        }
        return Database.query(query);
    }

    /****************************************** Without Security SOQL STARTS **************************************************/

    /**
     * @description       : Without Security Inner class for Group
     *
     * @author            : MTX Group Product Team
     * @last modified on  : 07-26-2024
     * @last modified by  : MTX Group Product Team
     **/
    public without sharing class LPI_GroupWithoutSharingDAO {
        /**
        * @description : Get group records without adding WITH SECURITY_ENFORCED
        * @author MTX Group Product Team | 01-27-2023 
        * @param fields 
        * @param whereClause 
        * @param limitValue 
        * @param sortingByFields 
        * @param sortingOrder 
        * @return List<Group> 
        **/
        public List<Group> getGroupByDymanicQueryWithoutSecurityEnforced(
            String fields,
            String whereClause,
            String limitValue,
            String sortingByFields,
            String sortingOrder
        ) {
            String query = 'SELECT '+ fields + ' FROM Group WHERE ' + whereClause;
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
}