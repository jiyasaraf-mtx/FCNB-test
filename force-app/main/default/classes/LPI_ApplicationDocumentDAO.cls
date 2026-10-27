/**
 * @author                      : MTX Group Product Team
 * @since                       : 6 Jan, 2023
 * @description                 : This class contains DAO methods for Application_Document__c object
 * @last modified by            : MTX Group Product Team
 * @last modified date          : 17 Jan, 2023
 * @last modified details       : Add getApplicationDocumentMapByPARIdAndType method
 */
public with sharing class LPI_ApplicationDocumentDAO {
    
    /**
     * @author                      : MTX Group Product Team
     * @since                       : 
     * @description                 : Dynamic Query Get Application_Document__c fields by different where clauses.
     * @param  fields             	: fields with (,) separated
     * @param  whereClause          : where condition (Ex: Name = 'Nitesh' AND Status = 'Active')
     * @param  limitValue          	: any limit otherwise pass null
     * @param  sortingByFields      : fields name from which you have to sort otherwise pass null
     * @param  sortingOrder      	: order of sorting (asc or desc) accept only two value otehr wise pass null
     * @last modified by            : MTX Group Product Team
     * @last modified date          : (Add if modified by you)
     * @last modified details       : (Add if modified by you)
     */
    public static List<Application_Document__c> getApplicantDocumentByDymanicQuery(String fields,
                                                                                String whereClause,
                                                                                String limitValue,
                                                                               	String sortingByFields,
                                                                               	String sortingOrder){

        String query = 'SELECT ';
        query += fields;
        query += ' FROM Application_Document__c ';
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
     * @author                      : MTX Group Product Team
     * @since                       : 
     * @description                 : Dynamic Query Get Application_Document__c fields by different where clauses.
     * @param  fields             	: fields with (,) separated
     * @param  whereClause          : where condition (Ex: Name = 'Nitesh' AND Status = 'Active')
     * @param  limitValue          	: any limit otherwise pass null
     * @param  sortingByFields      : fields name from which you have to sort otherwise pass null
     * @param  sortingOrder      	: order of sorting (asc or desc) accept only two value otehr wise pass null
     * @last modified by            : MTX Group Product Team
     * @last modified date          : (Add if modified by you)
     * @last modified details       : (Add if modified by you)
     */
    public static List<Application_Document__c> getApplicantDocumentByDymanicQueryWithoutSecurity(String fields,
                                                                                String whereClause,
                                                                                String limitValue,
                                                                               	String sortingByFields,
                                                                               	String sortingOrder){

        String query = 'SELECT ';
        query += fields;
        query += ' FROM Application_Document__c ';
        query += 'WHERE ' + whereClause ;
        if(sortingByFields != null){
        	query += ' ORDER BY ' + sortingByFields;
            if(sortingOrder != null){
                query += ' ' + sortingOrder + ' ';
            }
        }                                                                             
        if(limitValue != null){
        	query += ' LIMIT ' + (String.isNotBlank(limitValue) ? limitValue : '50000');
        }               
        System.debug('##QUERY STRING '+query);
        return Database.query(query);
    }

    /**
     * @author                      : MTX Group Product Team
     * @since                       : 6 Jan, 2023
     * @description                 : This method return the List of Application_Document__c records by related to PAR
     * @param  setPARId             : Set of PAR Id
     * @last modified by            : MTX Group Product Team
     * @last modified date          : (Add if modified by you)
     * @last modified details       : (Add if modified by you)
     */
    public static List<Application_Document__c> getApplicationContentByPARId(Set<Id> setPARId){
        return [
            SELECT
                Id,
                Preliminary_Application_Reference__c,
                Individual_Application__c,
            	Business_License_Application__c
            FROM
                Application_Document__c
            WHERE
                Preliminary_Application_Reference__c  in: setPARId
            WITH SECURITY_ENFORCED
        ];
    }
    
    /**
     * @author                      : MTX Group Product Team
     * @since                       : 17 Jan, 2023
     * @description                 : This method return the List of Application_Document__c records by related to PAR and Type
     * @param setPARId              : Set of PAR Id
     * @param typeOfDocument        : Application document Type
     * @returnType                  : Map<Id, Application_Document__c>
     * @last modified by            : MTX Group Product Team
     * @last modified date          : (Add if modified by you)
     * @last modified details       : (Add if modified by you)
     */
    public static Map<Id, Application_Document__c> getApplicationDocumentMapByPARIdAndType(Set<Id> setPARId, String typeOfDocument){
        return new Map<Id, Application_Document__c>([
            SELECT
                Id,
            	Document_Name__c,
				Business_License_Application__c,
				Is_Document_Required__c,
                Preliminary_Application_Reference__c
            FROM
                Application_Document__c
            WHERE
                Preliminary_Application_Reference__c  IN: setPARId
            	AND Type__c INCLUDES (:typeOfDocument)
            WITH SECURITY_ENFORCED
            ORDER BY Sequence__c
        ]);
    }
	
    /**
     * @author                      : MTX Group Product Team
     * @since                       : 21 Jan, 2023
     * @description                 : This method return the List of Application_Document__c records 
     * @last modified by            : MTX Group Product Team
     * @last modified date          : (Add if modified by you)
     * @last modified details       : (Add if modified by you)
     */
    public static List<Application_Document__c> getApplicationContentByPARId(Id applicationId,
                                                                            String status,boolean isDeficency,
                                                                            boolean isApplicantReq,boolean isDocReq){
        return [
            SELECT Id,Status__c
            FROM Application_Document__c
            WHERE Deficiency__c = :applicationId 
            AND Is_Deficiency_Notice__c =: isDeficency
            AND Is_Applicant_Submission_Required__c = :isApplicantReq
            AND Is_Document_Required__c = :isDocReq
            AND Status__c = :status
            WITH SECURITY_ENFORCED
        ];
    }
    /****************************************** Without Security SOQL STARTS **************************************************/

    /**
     * @description       : Without Security Inner class for Application_Document__c
     *                      
     * @author            : MTX Group Product Team
     * @last modified on  : 07-26-2024
     * @last modified by  : MTX Group Product Team
    **/
    public without sharing class LPI_ApplicationDocumentWithoutSharingDAO {
        /**
         * @author                      : Manish Singh
         * @since                       : 
         * @description                 : we're querying ContentDocumentLinks hence created this without SECURITY_ENFORCED
         * @param  fields             	: fields with (,) separated
         * @param  whereClause          : where condition (Ex: Name = 'Nitesh' AND Status = 'Active')
         * @param  limitValue          	: any limit otherwise pass null
         * @param  sortingByFields      : fields name from which you have to sort otherwise pass null
         * @param  sortingOrder      	: order of sorting (asc or desc) accept only two value otehr wise pass null
         * @last modified by            : MTX Group Product Team
         * @last modified date          : (Add if modified by you)
         * @last modified details       : (Add if modified by you)
         **/
        public List<Application_Document__c> getApplicantDocumentByDymanicQueryWithoutSecurityEnforced(String fields,
                                                                                    String whereClause,
                                                                                    String limitValue,
                                                                                    String sortingByFields,
                                                                                    String sortingOrder){

            String query = 'SELECT ';
            query += fields;
            query += ' FROM Application_Document__c ';
            query += 'WHERE ' + whereClause;
            if(sortingByFields != null){
                query += ' ORDER BY ' + sortingByFields;
                if(sortingOrder != null){
                    query += ' ' + sortingOrder + ' ';
                }
            }                                                                             
            limitValue = String.isNotBlank(limitValue) ? limitValue : '50000';
            query += ' LIMIT ' + limitValue;
            system.debug('query:- '+query);
            return Database.query(query);
        }
    
    }


}