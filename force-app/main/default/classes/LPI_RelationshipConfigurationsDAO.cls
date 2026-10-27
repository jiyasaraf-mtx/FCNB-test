/**
 * @description       : DAO for Relationship_Configuration__c 
 * @author            : Kishore
 * @group             : 
 * @last modified on  : 07-13-2024
 * @last modified by  : MTX Group Inc
**/
public class LPI_RelationshipConfigurationsDAO {
    
    /**
    * @description : Get Relationship_Configuration__c by dynamic query.
    * @author Kishore | 11-09-2023
    * @param fields 
    * @param whereClause 
    * @param limitValue 
    * @param sortingByFields 
    * @param sortingOrder 
    * @return List<Relationship_Configuration__c > 
    **/
    // public static List<Relationship_Configuration__c > getRelationConfigsByDymanicQuery(
    //     String fields,
    //     String whereClause,
    //     String limitValue,
    //     String sortingByFields,
    //     String sortingOrder
    // ) {
    //     String query = 'SELECT ';
    //     query += fields;
    //     query += ' FROM Relationship_Configuration__c  ';
    //     query += 'WHERE ' + whereClause + ' WITH SECURITY_ENFORCED ';
    //     if (sortingByFields != null) {
    //         query += ' ORDER BY ' + sortingByFields;
    //         if (sortingOrder != null) {
    //             query += ' ' + sortingOrder + ' ';
    //         }
    //     }
    //     limitValue = String.isNotBlank(limitValue) ? limitValue : '50000';
    //     query += ' LIMIT ' + limitValue;
    //     return Database.query(query);
    // }

    /**
     * @description       : Without Security Inner class for Relationship_Configuration__c.
     *                      
     * @author            : Kishore
     * @last modified on  : 07-13-2024
     * @last modified by  : MTX Group Inc
    **/
    public without sharing class LPI_WithoutShareingRelationshipConfigDAO {

        /**
         * description : To fetch Relationship_Configuration__c Record
         * Created by                   : Kishore
         * Date                         : 11-09-2023
         * @last modified by            : MTX Group Inc
         * @last modified date          : 
         * @last modified details       : 
        */
        public List<Relationship_Configuration__c > getRelationConfigsByDymanicQuery(
        String fieldsToQuery,
        String whereClause,
        String limitValue,
        String orderByClause
    ) {
        String query = 'SELECT ' + fieldsToQuery;
        query += ' FROM Relationship_Configuration__c ';
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