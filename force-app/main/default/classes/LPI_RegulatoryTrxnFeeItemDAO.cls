/**
 * @description       : 
 * @author            : Vamsi Mudaliar
 * @group             : 
 * @last modified on  : 02-27-2023
 * @last modified by  : Vamsi Mudaliar
**/
public with sharing class LPI_RegulatoryTrxnFeeItemDAO {
   
	/**
     * @author                      : Vamsi Mudaliar
     * @since                       : 
     * @description                 : Dynamic Query Get RegulatoryTrxnFee fields by different where clauses.
     * @param  fields             	: fields with (,) separated
     * @param  whereClause          : where condition (Ex: Name = 'Vamsi' AND Status = 'Active')
     * @param  limitValue          	: any limit otherwise pass null
     * @param  sortingByFields      : fields name from which you have to sort otherwise pass null
     * @param  sortingOrder      	: order of sorting (asc or desc) accept only two value other wise pass null
     * @last modified by            : Vamsi Mudaliar
     * @last modified date          : (Add if modified by you)
     * @last modified details       : (Add if modified by you)
     */
    public static List<RegulatoryTrxnFeeItem> getRegulatoryTrxnFeeItemByDynamicQuery(String fields,
                                                                                String whereClause,
                                                                                String limitValue,
                                                                               	String sortingByFields,
                                                                               	String sortingOrder){

        String query = 'SELECT ';
        query += fields;
        query += ' FROM RegulatoryTrxnFeeItem ';
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
     * @description       : Without Security Inner class for RegulatoryTrxnFeeItem
     *                      
     * @author            : Nitesh Garg
     * @last modified on  : 02-27-2023
     * @last modified by  : Vamsi Mudaliar
    **/
    public without sharing class LPI_RegulatoryTrxnFeeItemWithoutSharingDAO {
	
        /**
     * @author                      : Nitesh Garg
     * @since                       : 
     * @description                 : Dynamic Query Get RegulatoryTrxnFeeItem fields by different where clauses.
     * @param  fields             	: fields with (,) separated
     * @param  whereClause          : where condition (Ex: Name = 'Nitesh' AND Status = 'Active')
     * @param  limitValue          	: any limit otherwise pass null
     * @param  sortingByFields      : fields name from which you have to sort otherwise pass null
     * @param  sortingOrder      	: order of sorting (asc or desc) accept only two value otehr wise pass null
     * @last modified by            : Vamsi Mudaliar
     * @last modified date          : (Add if modified by you)
     * @last modified details       : (Add if modified by you)
     */
    public List<RegulatoryTrxnFeeItem> getRegulatoryTrxnFeeItemByDymanicQuery(String fields,
                                            String whereClause,
                                            String limitValue,
                                            String sortingByFields,
                                            String sortingOrder){

        String query = 'SELECT ';
        query += fields;
        query += ' FROM RegulatoryTrxnFeeItem ';
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
    
        
    }
}