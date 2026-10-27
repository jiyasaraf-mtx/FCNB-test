/**
 * @description       : DAO for Task
 * @author            : MTX Group Product Team
 * @group             : 
 * @last modified on  : 07-26-2024
 * @last modified by  : MTX Group Product Team
**/
public with sharing class LPI_TaskDao {

    /**
    * @description : Get task by dynamic query.
    * @author MTX Group Product Team | 05-31-2023 
    * @param fields 
    * @param whereClause 
    * @param limitValue 
    * @param sortingByFields 
    * @param sortingOrder 
    * @return List<Task> 
    **/
    public static List<Task> getTaskByDymanicQuery(
        String fields,
        String whereClause,
        String limitValue,
        String sortingByFields,
        String sortingOrder
    ) {
        String query = 'SELECT ';
        query += fields;
        query += ' FROM Task ';
        query += 'WHERE ' + whereClause ;
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
     * @description       : Without Security Inner class for Task.
     *                      
     * @author            : MTX Group Product Team
     * @last modified on  : 07-26-2024
     * @last modified by  : MTX Group Product Team
    **/
    public without sharing class LPI_DAO_TaskWithoutSecurity {

        /**
         * description : To fetch Task Record
         * Created by                   : Ankit Bansal
         * Date                         : 19-10-2023
         * @last modified by            : MTX Group Product Team
         * @last modified date          : 
         * @last modified details       : 
        */
        public List<Task> fetchTaskRecords(
        String fieldsToQuery,
        String whereClause,
        String limitValue,
        String orderByClause) {
            String query = 'SELECT ' + fieldsToQuery;
            query += ' FROM Task ';
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