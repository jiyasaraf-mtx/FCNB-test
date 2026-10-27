/**
 * @author                      : Ayush Yadav
 * @since                       : 21 Jan, 2023
 * @description                 : This method contains DAO methods for IndividualApplication object
 * @last modified by            : Ayush Dev
 * @last modified date          : (Add if modified by you)
 * @last modified details       : (Add if modified by you)
 */
public with sharing class LPI_BankAccountDAO {
    
    /**
     * @author                      : Nitesh Garg
     * @since                       : 
     * @description                 : Dynamic Query Get Bank_Account__c fields by different where clauses.
     * @param  fields             	: fields with (,) separated
     * @param  whereClause          : where condition (Ex: Name = 'Nitesh' AND Status = 'Active')
     * @param  limitValue          	: any limit otherwise pass null
     * @param  sortingByFields      : fields name from which you have to sort otherwise pass null
     * @param  sortingOrder      	: order of sorting (asc or desc) accept only two value otehr wise pass null
     * @last modified by            : Ayush Dev
     * @last modified date          : (Add if modified by you)
     * @last modified details       : (Add if modified by you)
     */
    public static List<Bank_Account__c> getBankAccountByDymanicQuery(String fields,
                                                      String whereClause,
                                                      String limitValue,
                                                      String sortingByFields,
                                                      String sortingOrder){

        String query = 'SELECT ';
        query += fields;
        query += ' FROM Bank_Account__c ';
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
    /**
     * @author                      : Ayush Yadav
     * @since                       : 21 Jan, 2023
     * @description                 : This method contains DAO methods for BusinessLicenseApplication object
     * @param  accId                : List of Bank Account records
     * @last modified by            : Ayush Dev
     * @last modified date          : (Add if modified by you)
     * @last modified details       : (Add if modified by you)
     */
    // public static List<Bank_Account__c> getBankAccByAccountId(Id accId){
    //     return [
    //         SELECT
    //             Id
    //         FROM
    //             Bank_Account__c
    //         WHERE
    //         Account__c =: accId
    //         WITH SECURITY_ENFORCED
    //     ];
    // }
    /****************************************** Without Security SOQL STARTS **************************************************/

    /**
     * @description       : Without Security Inner class for Bank_Account__c
     *                      
     * @author            : Nitesh Garg
     * @last modified on  : 07-12-2024
     * @last modified by  : Ayush Dev
    **/
    public without sharing class LPI_BankAccountWithoutSharingDAO {
        /**
         * @author                      : Nitesh Garg
         * @since                       : 
         * @description                 : Dynamic Query Get Bank_Account__c fields by different where clauses.
         * @param  fields             	: fields with (,) separated
         * @param  whereClause          : where condition (Ex: Name = 'Nitesh' AND Status = 'Active')
         * @param  limitValue          	: any limit otherwise pass null
         * @param  sortingByFields      : fields name from which you have to sort otherwise pass null
         * @param  sortingOrder      	: order of sorting (asc or desc) accept only two value otehr wise pass null
         * @last modified by            : Ayush Dev
         * @last modified date          : (Add if modified by you)
         * @last modified details       : (Add if modified by you)
         */
        public List<Bank_Account__c> getBankAccountByDymanicQuery(String fields,
                                                String whereClause,
                                                String limitValue,
                                                String sortingByFields,
                                                String sortingOrder){

            String query = 'SELECT ';
            query += fields;
            query += ' FROM Bank_Account__c ';
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