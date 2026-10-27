/**
 * @author                      : MTX Group Product Team
 * @since                       : 11 Sep, 2023
 * @description                 : This class contains DAO methods for Audit_Detail__c object
 */
public with sharing class LPI_AuditDetailsDAO {
    /**
     * @author                      : MTX Group Product Team
     * @since                       :
     * @description                 : Dynamic Query Get Audit_Detail__c fields by different where clauses.
     * @param  fields             	: fields with (,) separated
     * @param  whereClause          : where condition (Ex: Name = 'Test' AND Status = 'Active')
     * @param  limitValue          	: any limit otherwise pass null
     * @param  sortingByFields      : fields name from which you have to sort otherwise pass null
     * @param  sortingOrder      	: order of sorting (asc or desc) accept only two value otehr wise pass null
     * @last modified by            : MTX Group Product Team
     * @last modified date          : (Add if modified by you)
     * @last modified details       : (Add if modified by you)
    */
    public static List<Audit_Detail__c> getAuditDetailsByDymanicQuery(
        String fields,
        String whereClause,
        String limitValue,
        String sortingByFields,
        String sortingOrder
    ) {
        String query = 'SELECT ' + fields + ' FROM Audit_Detail__c WHERE ' + whereClause + ' WITH SECURITY_ENFORCED ';
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