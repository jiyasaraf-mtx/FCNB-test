/**
 * @description       : DAO for Business_Complaint__c
 * @author            : Mohit Karani
 * @group             : 
 * @last modified on  : 04-22-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class LPI_BusinesComplaintJunctionDao {

    /**
     * @description : Get Business_Complaint__c records by different where clauses and different fields.
     * @author Mohit Karani | 05-29-2023
     * @param whereClause
     * @return List<Business_Complaint__c>
     **/
    public static List<Business_Complaint__c> getBusinessComplaintByDymanicQuery(String fields,
                                                                                String whereClause,
                                                                                String limitValue,
                                                                               	String sortingByFields,
                                                                               	String sortingOrder){

        String query = 'SELECT ';
        query += fields;
        query += ' FROM Business_Complaint__c ';
        query += 'WHERE ' + whereClause+ ' WITH SECURITY_ENFORCED ';
        if(sortingByFields != null){
        	query += ' ORDER BY ' + sortingByFields;
            if(sortingOrder != null){
                query += ' ' + sortingOrder + ' ';
            }
        }     
        limitValue = (String.isNotBlank(limitValue)) ? limitValue : '50000';                                                                        
        query += ' LIMIT ' + limitValue;                                                                                                                                                      
        return Database.query(query);
    }

    public without sharing class LPI_BusinesComplaintJunctionDaoWithout {

            /**
         * @description : Get Business_Complaint__c records by different where clauses and different fields.
         * @author Mohit Karani | 05-29-2023
         * @param whereClause
         * @return List<Business_Complaint__c>
         **/
        public List<Business_Complaint__c> getBusinessComplaintByDymanicQueryWithout(String fields,
        String whereClause,
        String limitValue,
            String sortingByFields,
            String sortingOrder){

        String query = 'SELECT ';
        query += fields;
        query += ' FROM Business_Complaint__c ';
        query += 'WHERE ' + whereClause;
        if(sortingByFields != null){
        query += ' ORDER BY ' + sortingByFields;
        if(sortingOrder != null){
        query += ' ' + sortingOrder + ' ';
        }
        }     
        limitValue = (String.isNotBlank(limitValue)) ? limitValue : '50000';                                                                        
        query += ' LIMIT ' + limitValue;                                                                                                                                                      
        return Database.query(query);
        }

    }
    
}