/**
 * @author                      : Kishore
 * @since                       : 6th July, 2023
 * @description                 : This class contains DAO methods for Application_Content__c object
 * @last modified by            : Amit Agrawal
 * @last modified date          : (Add if modified by you)
 * @last modified details       : (Add if modified by you)
 */
public with sharing class LPI_AliasDAO {
    /**
     * @author                      :Kishore
     * @since                       :
     * @description                 : Dynamic Query Get Alias__c fields by different where clauses.
     * @param  fields             	: fields with (,) separated
     * @param  whereClause          : where condition (Ex: Name = 'Nitesh' AND Status = 'Active')
     * @param  limitValue          	: any limit otherwise pass null
     * @param  sortingByFields      : fields name from which you have to sort otherwise pass null
     * @param  sortingOrder      	: order of sorting (asc or desc) accept only two value otehr wise pass null
     * @last modified by            : Amit Agrawal
     * @last modified date          : (Add if modified by you)
     * @last modified details       : (Add if modified by you)
     */
    public static List<Alias__c> getAliasByDymanicQuery(
        String fields,
        String whereClause,
        String limitValue,
        String sortingByFields,
        String sortingOrder
    ) {
        String query = 'SELECT ';
        query += fields;
        query += ' FROM Alias__c ';
        query += 'WHERE ' + whereClause + ' WITH SECURITY_ENFORCED ';
        if (sortingByFields != null) {
            query += ' ORDER BY ' + sortingByFields;
            if (sortingOrder != null) {
                query += ' ' + sortingOrder + ' ';
            }
        }
        if (limitValue != null) {
            query += ' LIMIT ' + limitValue;
        }
        return Database.query(query);
    }

    /****************************************** Without Security SOQL STARTS **************************************************/

    /**
     * @description       : Without Security Inner class for Sharing_Ledger__c
     *
     * @author            : Kishore
     * @last modified on  : 05-03-2024
     * @last modified by  : Amit Agrawal
     **/
    public without sharing class LPI_AliasWithoutSharingDAO {
        /**
         * @author                      : Kishore Reddy
         * @since                       :
         * @description                 : Dynamic Query Get Alias__c fields by different where clauses.
         * @param  fields             	: fields with (,) separated
         * @param  whereClause          : where condition (Ex: Name = 'Nitesh' AND Status = 'Active')
         * @param  limitValue          	: any limit otherwise pass null
         * @param  sortingByFields      : fields name from which you have to sort otherwise pass null
         * @param  sortingOrder      	: order of sorting (asc or desc) accept only two value otehr wise pass null
         * @last modified by            : Amit Agrawal
         * @last modified date          : (Add if modified by you)
         * @last modified details       : (Add if modified by you)
         */
        public List<Alias__c> getAliasByDymanicQuery(
            String fields,
            String whereClause,
            String limitValue,
            String sortingByFields,
            String sortingOrder
        ) {
            String query = 'SELECT ';
            query += fields;
            query += ' FROM Alias__c ';
            query += 'WHERE ' + whereClause + ' WITH SECURITY_ENFORCED ';
            if (sortingByFields != null) {
                query += ' ORDER BY ' + sortingByFields;
                if (sortingOrder != null) {
                    query += ' ' + sortingOrder + ' ';
                }
            }
            if (limitValue != null) {
                query += ' LIMIT ' + limitValue;
            }

            return Database.query(query);
        }
    }
}