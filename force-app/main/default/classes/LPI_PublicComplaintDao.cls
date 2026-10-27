/**
 * @description       : DAO for PublicComplaint
 * @author            : Mohit Karani
 * @group             :
 * @last modified on  : 03-31-2023
 * @last modified by  : Mohit Karani
 **/
public with sharing class LPI_PublicComplaintDao {
    /**
     * @description : Get PublicComplaint records by different where clauses and different fields.
     * @author Mohit Karani | 01-22-2023
     * @param whereClause
     * @return List<PublicComplaint>
     **/
    public static List<PublicComplaint> fetchPublicComplaintRecords(
        String fieldsToQuery,
        String whereClause,
        String limitValue,
        String orderByClause
    ) {
        String query = 'SELECT ' + fieldsToQuery;
        query += ' FROM PublicComplaint ';
        query += ' WHERE ' + whereClause + ' WITH SECURITY_ENFORCED';
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
     * @description       : Without Security Inner class for PublicComplaint
     *
     * @author            : Nitesh Garg
     * @last modified on  : 03-31-2023
     * @last modified by  : Mohit Karani
     **/
    public without sharing class LPI_PublicComplaintWithoutSharingDAO {
        /**
         * @author                      : Nitesh Garg
         * @since                       :
         * @description                 : Dynamic Query Get PublicComplaint fields by different where clauses.
         * @param  fields             	: fields with (,) separated
         * @param  whereClause          : where condition (Ex: Name = 'Nitesh' AND Status = 'Active')
         * @param  limitValue          	: any limit otherwise pass null
         * @param  sortingByFields      : fields name from which you have to sort otherwise pass null
         * @param  sortingOrder      	: order of sorting (asc or desc) accept only two value otehr wise pass null
         * @last modified by            : Mohit Karani
         * @last modified date          : (Add if modified by you)
         * @last modified details       : (Add if modified by you)
         */
        public List<PublicComplaint> getPublicComplaintByDymanicQuery(
            String fields,
            String whereClause,
            String limitValue,
            String sortingByFields,
            String sortingOrder
        ) {
            String query = 'SELECT ';
            query += fields;
            query += ' FROM PublicComplaint ';
            query += 'WHERE ' + whereClause + ' WITH SECURITY_ENFORCED ';
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


        /**
        * @description : Method to fetch PublicComplaint in without security context.
        * @author Mohit Karani | 03-31-2023 
        * @param fields 
        * @param whereClause 
        * @param limitValue 
        * @param sortingByFields 
        * @param sortingOrder 
        * @return List<PublicComplaint> 
        **/
        public List<PublicComplaint> getPublicComplaintByDymanicQueryWithoutSecurity(
            String fields,
            String whereClause,
            String limitValue,
            String sortingByFields,
            String sortingOrder
        ) {
            String query = 'SELECT ';
            query += fields;
            query += ' FROM PublicComplaint ';
            query += 'WHERE ' + whereClause;
            if (sortingByFields != null) {
                query += ' ORDER BY ' + sortingByFields;
                if (sortingOrder != null) {
                    query += ' ' + sortingOrder + ' ';
                }
            }
            if (limitValue != null) {
                query += ' LIMIT ' + (limitValue != null ? limitValue : '50000');
            }
            System.debug('Query>>'+query);
            return Database.query(query);
        }
    }
}