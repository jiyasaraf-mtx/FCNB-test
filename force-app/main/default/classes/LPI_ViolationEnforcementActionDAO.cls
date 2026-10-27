/**
 * @description       : DAO FOR ViolationEnforcementAction
 * @author            : mohit.karani@mtxb2b.com
 * @group             : 
 * @last modified on  : 05-02-2024
 * @last modified by  : MTX Group Inc.
 **/
public with sharing class LPI_ViolationEnforcementActionDAO {

    /**
     * description : To fetch ViolationEnforcementAction Record
     * Created by                   : Ankit Bansal
     * Date                         : 19-10-2023
     * @last modified by            : MTX Group Inc.
     * @last modified date          : 
     * @last modified details       : 
     */
    public static List < ViolationEnforcementAction > fetchViolationEnforcementActionRecords(
        String fieldsToQuery,
        String whereClause,
        String limitValue,
        String orderByClause
    ) {
        String query = 'SELECT ' + fieldsToQuery;
        query += ' FROM ViolationEnforcementAction ';
        query += 'WHERE ' + whereClause + ' WITH SECURITY_ENFORCED ';
        if (String.isNotBlank(orderByClause)) {
            query += ' ORDER BY  ' + orderByClause;
        }
        if (String.isNotBlank(limitValue)) {
            query += ' LIMIT ' + (limitValue != null ? limitValue : '50000');
        }
        return Database.query(query);
    }
    /**
    * @description 
    * @author MTX Group Inc. | 05-02-2024 
    * @param fieldsToQuery 
    * @param whereClause 
    * @param limitValue 
    * @param orderByClause 
    * @return List<ViolationEnforcementAction> 
    **/
    public static List < ViolationEnforcementAction > fetchViolationEnforcementActionRecordsWithoutSecurity(
        String fieldsToQuery,
        String whereClause,
        String limitValue,
        String orderByClause
    ) {
        String query = 'SELECT ' + fieldsToQuery;
        query += ' FROM ViolationEnforcementAction ';
        query += 'WHERE ' + whereClause ;
        if (String.isNotBlank(orderByClause)) {
            query += ' ORDER BY  ' + orderByClause;
        }
        if (String.isNotBlank(limitValue)) {
            query += ' LIMIT ' + (limitValue != null ? limitValue : '50000');
        }
        return Database.query(query);
    }

    /**
     * @description       : Without Security Inner class for Violation Enforcement Action
     *                      
     * @author            : Ankit Bansal
     * @last modified on  : 05-02-2024
     * @last modified by  : MTX Group Inc.
     **/
    public without sharing class LPI_DAO_ViolationEnfActionWithoutSecurity {

        /**
         * description : To fetch ViolationEnforcementAction Record
         * Created by                   : Ankit Bansal
         * Date                         : 19-10-2023
         * @last modified by            : MTX Group Inc.
         * @last modified date          : 
         * @last modified details       : 
         */
        public List < ViolationEnforcementAction > fetchViolationEnforcementActionRecords(
            String fieldsToQuery,
            String whereClause,
            String limitValue,
            String orderByClause
        ) {
            String query = 'SELECT ' + fieldsToQuery;
            query += ' FROM ViolationEnforcementAction ';
            query += ' WHERE ' + whereClause;
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