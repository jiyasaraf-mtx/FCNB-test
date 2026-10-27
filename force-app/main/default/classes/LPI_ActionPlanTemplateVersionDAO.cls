/**
 * @description       :  DAO FOR ActionPlanTemplateVersion
 * @author            : Mohit Karani
 * @group             :
 * @last modified on  : 07-13-2024
 * @last modified by  : Uzma Md
 **/
public with sharing class LPI_ActionPlanTemplateVersionDAO {
    /**
     * @description : Method to fetch ActionPlanTemplateVersion records.
     * @author Mohit Karani | 01-22-2023
     * @param fieldsToQuery
     * @param whereClause
     * @param limitValue
     * @param orderByClause
     * @return List<ActionPlanTemplateVersion>
     **/
    public static List<ActionPlanTemplateVersion> getActionPlanTemplateVersion(
        String fieldsToQuery,
        String whereClause,
        String limitValue,
        String orderByClause
    ) {
        String query = 'SELECT ' + fieldsToQuery;
        query += ' FROM ActionPlanTemplateVersion';
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
     * @description       : Without Security Inner class for ActionPlanTemplateVersion
     *                      
     * @author            : Nitesh Garg
     * @last modified on  : 07-13-2024
     * @last modified by  : Uzma Md
    **/
    // public without sharing class LPI_ActionPlanTempVerWithoutSharingDAO {
	
    //     /**
    //      * @author                      : Nitesh Garg
    //      * @since                       : 
    //      * @description                 : Dynamic Query Get ActionPlanTemplateVersion fields by different where clauses.
    //      * @param  fields             	: fields with (,) separated
    //      * @param  whereClause          : where condition (Ex: Name = 'Nitesh' AND Status = 'Active')
    //      * @param  limitValue          	: any limit otherwise pass null
    //      * @param  sortingByFields      : fields name from which you have to sort otherwise pass null
    //      * @param  sortingOrder      	: order of sorting (asc or desc) accept only two value otehr wise pass null
    //      * @last modified by            : Ayush Dev
    //      * @last modified date          : (Add if modified by you)
    //      * @last modified details       : (Add if modified by you)
    //      */
    //     public List<ActionPlanTemplateVersion> getActionPlanTempVerByDymanicQuery(String fields,
    //                                             String whereClause,
    //                                             String limitValue,
    //                                             String sortingByFields,
    //                                             String sortingOrder){

    //         String query = 'SELECT ';
    //         query += fields;
    //         query += ' FROM ActionPlanTemplateVersion ';
    //         query += 'WHERE ' + whereClause + ' WITH SECURITY_ENFORCED ';
    //         if(sortingByFields != null){
    //             query += ' ORDER BY ' + sortingByFields;
    //             if(sortingOrder != null){
    //                 query += ' ' + sortingOrder + ' ';
    //             }
    //         }                                                                             
    //         if(limitValue != null){
    //             query += ' LIMIT ' + (limitValue != null ? limitValue : '50000');
    //         }                                                                                                                                                       
    //         return Database.query(query);
    //     }
    // }
}