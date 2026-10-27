/**
 * @author                      : Kishore
 * @since                       : 21 Jan, 2023
 * @description                 : This class contains DAO methods for Site object
 * @last modified by            : Ayush Dev
 * @last modified date          : (Add if modified by you)
 * @last modified details       : (Add if modified by you)
 */
public with sharing class LPI_SiteDAO {
    
    /**
     * @author                      : Nitesh Garg
     * @since                       : 
     * @description                 : Dynamic Query Get Site fields by different where clauses.
     * @param  fields             	: fields with (,) separated
     * @param  whereClause          : where condition (Ex: Name = 'Nitesh' AND Status = 'Active')
     * @param  limitValue          	: any limit otherwise pass null
     * @param  sortingByFields      : fields name from which you have to sort otherwise pass null
     * @param  sortingOrder      	: order of sorting (asc or desc) accept only two value otehr wise pass null
     * @last modified by            : Ayush Dev
     * @last modified date          : (Add if modified by you)
     * @last modified details       : (Add if modified by you)
     */
    public static List<Site> getSiteByDymanicQuery(String fields,
                                                      String whereClause,
                                                      String limitValue,
                                                      String sortingByFields,
                                                      String sortingOrder){

        String query = 'SELECT ';
        query += fields;
        query += ' FROM Site ';
        query += 'WHERE ' + whereClause;
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
    /**
     * @author                      : Kishore
     * @since                       : 21 Jan, 2023
     * @description                 : This method return the List of Site records by ID
     * @param  communityName        : String Name of the Community
     * @return                      : Site
     * @last modified by            : Ayush Dev
     * @last modified date          : (Add if modified by you)
     * @last modified details       : (Add if modified by you)
     */
    // public static List<Site> getSiteIdFromName(String communityName) {
    //     return [
    //         SELECT Id 
    //         FROM Site 
    //         WHERE Name = :communityName
    //         LIMIT 1
    //     ];
    // }
    /****************************************** Without Security SOQL STARTS **************************************************/

    /**
     * @description       : Without Security Inner class for Site
     *                      
     * @author            : Nitesh Garg
     * @last modified on  : 07-12-2024
     * @last modified by  : Ayush Dev
    **/
    // public without sharing class LPI_SiteWithoutSharingDAO {
	
    //     /**
    //  * @author                      : Nitesh Garg
    //  * @since                       : 
    //  * @description                 : Dynamic Query Get Site fields by different where clauses.
    //  * @param  fields             	: fields with (,) separated
    //  * @param  whereClause          : where condition (Ex: Name = 'Nitesh' AND Status = 'Active')
    //  * @param  limitValue          	: any limit otherwise pass null
    //  * @param  sortingByFields      : fields name from which you have to sort otherwise pass null
    //  * @param  sortingOrder      	: order of sorting (asc or desc) accept only two value otehr wise pass null
    //  * @last modified by            : Ayush Dev
    //  * @last modified date          : (Add if modified by you)
    //  * @last modified details       : (Add if modified by you)
    //  */
    // public List<Site> getSiteByDymanicQuery(String fields,
    //                                         String whereClause,
    //                                         String limitValue,
    //                                         String sortingByFields,
    //                                         String sortingOrder){

    //     String query = 'SELECT ';
    //     query += fields;
    //     query += ' FROM Site ';
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