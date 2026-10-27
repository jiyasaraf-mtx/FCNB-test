/**
 * @author                      : Kishore
 * @since                       : 21 Jan, 2023
 * @description                 : This class contains DAO methods for SiteDetails object
 * @last modified by            : Ayush Dev
 * @last modified date          : (Add if modified by you)
 * @last modified details       : (Add if modified by you)
 */
public with sharing class LPI_SiteDetailDAO {
    /**
     * @author                      : Nitesh Garg
     * @since                       : 
     * @description                 : Dynamic Query Get SiteDetail fields by different where clauses.
     * @param  fields             	: fields with (,) separated
     * @param  whereClause          : where condition (Ex: Name = 'Nitesh' AND Status = 'Active')
     * @param  limitValue          	: any limit otherwise pass null
     * @param  sortingByFields      : fields name from which you have to sort otherwise pass null
     * @param  sortingOrder      	: order of sorting (asc or desc) accept only two value otehr wise pass null
     * @last modified by            : Ayush Dev
     * @last modified date          : (Add if modified by you)
     * @last modified details       : (Add if modified by you)
     */
    public static List<SiteDetail> getSiteDetailByDymanicQuery(String fields,
                                                      String whereClause,
                                                      String limitValue,
                                                      String sortingByFields,
                                                      String sortingOrder){

        String query = 'SELECT ';
        query += fields;
        query += ' FROM SiteDetail ';
        query += 'WHERE ' + whereClause ;
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
     * @description                 : This method return the List of SiteDetail records by Site ID
     * @param  siteId               : String Id of the Site
     * @return                      : String
     * @last modified by            : Ayush Dev
     * @last modified date          : (Add if modified by you)
     * @last modified details       : (Add if modified by you)
     */
    // public static String getURLFromSiteId(String siteId) { 
    //     return [
    //         SELECT SecureURL
    //         FROM SiteDetail
    //         WHERE DurableId = :siteId
    //     ].SecureUrl;
    // }
    /****************************************** Without Security SOQL STARTS **************************************************/

    /**
     * @description       : Without Security Inner class for SiteDetail
     *                      
     * @author            : Nitesh Garg
     * @last modified on  : 07-12-2024
     * @last modified by  : Ayush Dev
    **/
    // public without sharing class LPI_SiteDetailWithoutSharingDAO {
	
    //     /**
    //  * @author                      : Nitesh Garg
    //  * @since                       : 
    //  * @description                 : Dynamic Query Get SiteDetail fields by different where clauses.
    //  * @param  fields             	: fields with (,) separated
    //  * @param  whereClause          : where condition (Ex: Name = 'Nitesh' AND Status = 'Active')
    //  * @param  limitValue          	: any limit otherwise pass null
    //  * @param  sortingByFields      : fields name from which you have to sort otherwise pass null
    //  * @param  sortingOrder      	: order of sorting (asc or desc) accept only two value otehr wise pass null
    //  * @last modified by            : Ayush Dev
    //  * @last modified date          : (Add if modified by you)
    //  * @last modified details       : (Add if modified by you)
    //  */
    // public List<SiteDetail> getSiteDetailByDymanicQuery(String fields,
    //                                         String whereClause,
    //                                         String limitValue,
    //                                         String sortingByFields,
    //                                         String sortingOrder){

    //     String query = 'SELECT ';
    //     query += fields;
    //     query += ' FROM SiteDetail ';
    //     query += 'WHERE ' + whereClause ;
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