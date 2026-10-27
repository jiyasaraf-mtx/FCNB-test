/**
* @author                      : Kishore
* @since                       : 11 May, 2023
* @description                 : This class contains DAO methods for Application_Content__c object
* @last modified by            : Ayush Dev
* @last modified date          : (Add if modified by you)
* @last modified details       : (Add if modified by you)
*/
public with sharing class LPI_SharingLedgerDAO {
    /**
* @author                      : Kishoer
* @since                       : 
* @description                 : Dynamic Query Get Sharing_ledger__c fields by different where clauses.
* @param  fields             	: fields with (,) separated
* @param  whereClause          : where condition (Ex: Name = 'Nitesh' AND Status = 'Active')
* @param  limitValue          	: any limit otherwise pass null
* @param  sortingByFields      : fields name from which you have to sort otherwise pass null
* @param  sortingOrder      	: order of sorting (asc or desc) accept only two value otehr wise pass null
* @last modified by            : Ayush Dev
* @last modified date          : (Add if modified by you)
* @last modified details       : (Add if modified by you)
*/
    /*public static List<Sharing_Ledger__c> getSharingLedgerByDymanicQuery(String fields,
                                                                         String whereClause,
                                                                         String limitValue,
                                                                         String sortingByFields,
                                                                         String sortingOrder){
                                                                             
        String query = 'SELECT ';
        query += fields;
        query += ' FROM Sharing_Ledger__c ';
        query += 'WHERE ' + whereClause + ' WITH SECURITY_ENFORCED ';
        if(sortingByFields != null){
            query += ' ORDER BY ' + sortingByFields;
            if(sortingOrder != null){
                query += ' ' + sortingOrder + ' ';
            }
        }                                                                             
        if(limitValue != null){
            query += ' LIMIT ' + limitValue;
        }                                                                                                                                                       
        return Database.query(query);
    }*/
    
    /****************************************** Without Security SOQL STARTS **************************************************/
    
    /**
    * @description       : Without Security Inner class for Sharing_Ledger__c
    *                      
    * @author            : Kishore
    * @last modified on  : 05-06-2024
    * @last modified by  : Ayush Dev
    **/
    public without sharing class LPI_SharingLedgerWithoutSharingDAO {
        
        /**
        * @author                      : Nitesh Garg
        * @since                       : 
        * @description                 : Dynamic Query Get Sharing_Ledger__c fields by different where clauses.
        * @param  fields             	: fields with (,) separated
        * @param  whereClause          : where condition (Ex: Name = 'Nitesh' AND Status = 'Active')
        * @param  limitValue          	: any limit otherwise pass null
        * @param  sortingByFields      : fields name from which you have to sort otherwise pass null
        * @param  sortingOrder      	: order of sorting (asc or desc) accept only two value otehr wise pass null
        * @last modified by            : Ayush Dev
        * @last modified date          : (Add if modified by you)
        * @last modified details       : (Add if modified by you)
        */
        public List<Sharing_Ledger__c> getSharingLedgerByDymanicQuery(String fields,
                                                                      String whereClause,
                                                                      String limitValue,
                                                                      String sortingByFields,
                                                                      String sortingOrder){
            String query = 'SELECT ';
            query += fields;
            query += ' FROM Sharing_Ledger__c ';
            query += ' WHERE ' + whereClause + ' WITH SECURITY_ENFORCED ';
            if(sortingByFields != null){
                query += ' ORDER BY ' + sortingByFields;
                if(sortingOrder != null){
                    query += ' ' + sortingOrder + ' ';
                }
            }                                                                             
            if(limitValue != null){
                query += ' LIMIT ' + limitValue;
            }
            return Database.query(query);
        }
    }
}