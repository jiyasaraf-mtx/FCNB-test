/**
 * @author                      : MTX Group Product Team
 * @since                       : 17 Jan, 2023
 * @description                 : This class contains DAO methods for ContentVersion object
 * @last modified by            : MTX Group Product Team
 * @last modified date          : (Add if modified by you)
 * @last modified details       : (Add if modified by you)
 */
public with sharing class LPI_ContentVersionDAO {
    /**
     * @author                      : MTX Group Product Team
     * @since                       :
     * @description                 : Dynamic Query Get ContentVersion fields by different where clauses.
     * @param  fields             	: fields with (,) separated
     * @param  whereClause          : where condition (Ex: Name = 'Nitesh' AND Status = 'Active')
     * @param  limitValue          	: any limit otherwise pass null
     * @param  sortingByFields      : fields name from which you have to sort otherwise pass null
     * @param  sortingOrder      	: order of sorting (asc or desc) accept only two value otehr wise pass null
     * @last modified by            : MTX Group Product Team
     * @last modified date          : (Add if modified by you)
     * @last modified details       : (Add if modified by you)
     */
    public static List<ContentVersion> getContentVersionByDymanicQuery(
        String fields,
        String whereClause,
        String limitValue,
        String sortingByFields,
        String sortingOrder
    ) {
        String query = 'SELECT ';
        query += fields;
        query += ' FROM ContentVersion ';
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
     * @author                         : MTX Group Product Team
     * @since                          : 17 Jan, 2023
     * @description                    : This method return the List of ContentVersion records by ID
     * @param setOfContentDocumentIds  : Set of ContentDocument Id
     * @return                         : List<ContentVersion>
     * @last modified by               : MTX Group Product Team
     * @last modified date             : (Add if modified by you)
     * @last modified details          : (Add if modified by you)
     */
    public static List<ContentVersion> getContentVersionsByContentDocumentIds(
        Set<Id> setOfContentDocumentIds
    ) {
        return [
            SELECT
                Id,
                ContentDocumentId,
                Title,
                VersionNumber,
                PathOnClient,
                CreatedDate
            FROM ContentVersion
            WHERE ContentDocumentId IN :setOfContentDocumentIds
            WITH SECURITY_ENFORCED
            ORDER BY VersionNumber DESC
        ];
    }
    /****************************************** Without Security SOQL STARTS **************************************************/

    /**
     * @description       : Without Security Inner class for ContentVersion
     *
     * @author            : MTX Group Product Team
     * @last modified on  : 07-26-2024
     * @last modified by  : MTX Group Product Team
     **/
    public without sharing class LPI_ContentVersionWithoutSharingDAO {
        /**
         * @author                      : MTX Group Product Team
         * @since                       :
         * @description                 : Dynamic Query Get ContentVersion fields by different where clauses.
         * @param  fields             	: fields with (,) separated
         * @param  whereClause          : where condition (Ex: Name = 'Nitesh' AND Status = 'Active')
         * @param  limitValue          	: any limit otherwise pass null
         * @param  sortingByFields      : fields name from which you have to sort otherwise pass null
         * @param  sortingOrder      	: order of sorting (asc or desc) accept only two value otehr wise pass null
         * @last modified by            : MTX Group Product Team
         * @last modified date          : (Add if modified by you)
         * @last modified details       : (Add if modified by you)
         */
        public List<ContentVersion> getContentVersionByDymanicQuery(
            String fields,
            String whereClause,
            String limitValue,
            String sortingByFields,
            String sortingOrder
        ) {
            String query = 'SELECT ';
            query += fields;
            query += ' FROM ContentVersion ';
            query += 'WHERE ' + whereClause + ' WITH SECURITY_ENFORCED ';
            if (sortingByFields != null) {
                query += ' ORDER BY ' + sortingByFields;
                if (sortingOrder != null) {
                    query += ' ' + sortingOrder + ' ';
                }
            }
            if (limitValue != null) {
                query +=
                    ' LIMIT ' + (limitValue != null ? limitValue : '50000');
            }
            return Database.query(query);
        }
    }
}