/**
 * @author                      : Manish Kumar Singh
 * @since                       : 24 Jan, 2023
 * @description                 : This class contains DAO methods for ContentDocument object
 * @last modified by            : Ayush Dev
 * @last modified date          : 
 * @last modified details       : 
 */
public with sharing class LPI_ContentDocumentDAO {
    /**
     * @author                      : Manish Kumar Singh
     * @since                       : 24 Jan, 2023
     * @description                 : Dynamic Query Get ContentDocument fields by different where clauses.
     * @param  fields             	: fields with (,) separated
     * @param  whereClause          : where condition (Ex: Name = 'Nitesh' AND Status = 'Active')
     * @param  limitValue          	: any limit otherwise pass null
     * @param  sortingByFields      : fields name from which you have to sort otherwise pass null
     * @param  sortingOrder      	: order of sorting (asc or desc) accept only two value otehr wise pass null
     * @last modified by            : Ayush Dev
     * @last modified date          : (Add if modified by you)
     * @last modified details       : (Add if modified by you)
     */
    public static List<ContentDocument> getContentDocumentByDymanicQuery(String fields,
                                                                                String whereClause,
                                                                                String limitValue,
                                                                               	String sortingByFields,
                                                                               	String sortingOrder){

        String query = 'SELECT ';
        query += fields;
        query += ' FROM ContentDocument ';
        query += 'WHERE ' + whereClause + ' WITH SECURITY_ENFORCED ';
        if(sortingByFields != null){
        	query += ' ORDER BY ' + sortingByFields;
            if(sortingOrder != null){
                query += ' ' + sortingOrder + ' ';
            }
        }                                                                             
        if(limitValue != null){
        	query += ' LIMIT ' + (limitValue != null ? limitValue : '50000');
        }                                                                                                                                                       
        return Database.query(query);
    }
    /****************************************** Without Security SOQL STARTS **************************************************/

    /**
     * @description       : Without Security Inner class for ContentDocument
     *                      
     * @author            : Nitesh Garg
     * @last modified on  : 07-12-2024
     * @last modified by  : Ayush Dev
    **/
    // public without sharing class LPI_ContentDocumentWithoutSharingDAO {
	
    //     /**
    //      * @author                      : Nitesh Garg
    //      * @since                       : 
    //      * @description                 : Dynamic Query Get ContentDocument fields by different where clauses.
    //      * @param  fields             	: fields with (,) separated
    //      * @param  whereClause          : where condition (Ex: Name = 'Nitesh' AND Status = 'Active')
    //      * @param  limitValue          	: any limit otherwise pass null
    //      * @param  sortingByFields      : fields name from which you have to sort otherwise pass null
    //      * @param  sortingOrder      	: order of sorting (asc or desc) accept only two value otehr wise pass null
    //      * @last modified by            : Ayush Dev
    //      * @last modified date          : (Add if modified by you)
    //      * @last modified details       : (Add if modified by you)
    //      */
    //     public List<ContentDocument> getContentDocumentByDymanicQuery(String fields,
    //                                             String whereClause,
    //                                             String limitValue,
    //                                             String sortingByFields,
    //                                             String sortingOrder){

    //         String query = 'SELECT ';
    //         query += fields;
    //         query += ' FROM ContentDocument ';
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