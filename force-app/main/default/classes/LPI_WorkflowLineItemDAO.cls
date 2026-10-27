/**
* @author                      : Ayush Yadav
* @since                       : 23 Jan, 2023
* @description                 : This method contains DAO methods for Workflow Line Item object
* @last modified by            : Ayush Dev
* @last modified date          : 
* @last modified details       : 
*/
public with sharing class LPI_WorkflowLineItemDAO {
    /**
     * @author                      : Ayush Yadav
     * @since                       : 23 Jan, 2023
     * @description                 : Dynamic Query Get Workflow Line Item fields by different where clauses.
     * @param fields             	: fields with (,) separated
     * @param whereClause           : where condition (Ex: Name = 'Ayush' AND Status = 'Active') otherwise pass null
     * @param limitValue          	: any limit otherwise pass null
     * @param sortingByFields       : fields name from which you have to sort otherwise pass null
     * @param sortingOrder      	: order of sorting (asc or desc) accept only two value otehr wise pass null
     * @param offSetValue           : any offSet otherwise pass null
     * @last modified by            : Ayush Dev
     * @last modified date          : (Add if modified by you)
     * @last modified details       : (Add if modified by you)
     */
    public static List<Workflow_Line_Item__c> getWorkflowLineItemByDymanicQuery(String fields,
                                                      String whereClause,
                                                      String limitValue,
                                                      String sortingByFields,
                                                      String sortingOrder,
                                                      String offSetValue){

        String query = 'SELECT ';
        query += fields;
        query += ' FROM Workflow_Line_Item__c ';
        if(whereClause != null){
            query += 'WHERE ' + whereClause;
        }
        query += ' WITH SECURITY_ENFORCED ';
        if(sortingByFields != null){
        	query += ' ORDER BY ' + sortingByFields;
            if(sortingOrder != null){
                query += ' ' + sortingOrder + ' ';
            }
        }                                                                             
        if(limitValue != null){
        	query += ' LIMIT ' + (limitValue != null ? limitValue : '50000');
        }  
        if(offSetValue != null){
        	query += ' OFFSET ' + offSetValue;
        }                                                                                                                                                      
        return Database.query(query);
    }
    /****************************************** Without Security SOQL STARTS **************************************************/

    /**
     * @description       : Without Security Inner class for Workflow_Line_Item__c
     *                      
     * @author            : Nitesh Garg
     * @last modified on  : 07-12-2024
     * @last modified by  : Ayush Dev
    **/
    // public without sharing class LPI_WorkflowLineItemWithoutSharingDAO {
	
    //     /**
    //  * @author                      : Nitesh Garg
    //  * @since                       : 
    //  * @description                 : Dynamic Query Get Workflow_Line_Item__c fields by different where clauses.
    //  * @param  fields             	: fields with (,) separated
    //  * @param  whereClause          : where condition (Ex: Name = 'Nitesh' AND Status = 'Active')
    //  * @param  limitValue          	: any limit otherwise pass null
    //  * @param  sortingByFields      : fields name from which you have to sort otherwise pass null
    //  * @param  sortingOrder      	: order of sorting (asc or desc) accept only two value otehr wise pass null
    //  * @last modified by            : Amit Agrawal
    //  * @last modified date          : (Add if modified by you)
    //  * @last modified details       : (Add if modified by you)
    //  */
    // public List<Workflow_Line_Item__c> getWorkflowLineItemByDymanicQuery(String fields,
    //                                         String whereClause,
    //                                         String limitValue,
    //                                         String sortingByFields,
    //                                         String sortingOrder){

    //     String query = 'SELECT ';
    //     query += fields;
    //     query += ' FROM Workflow_Line_Item__c ';
    //     query += 'WHERE ' + whereClause + ' WITH SECURITY_ENFORCED ';
    //     if(sortingByFields != null){
    //     	query += ' ORDER BY ' + sortingByFields;
    //         if(sortingOrder != null){
    //             query += ' ' + sortingOrder + ' ';
    //         }
    //     }                                                                             
    //     if(limitValue != null){
    //     	query += ' LIMIT ' + (limitValue != null ? limitValue : '50000');
    //     }                                                                                                                                                       
    //     return Database.query(query);
    // }
    
        
    // }
}