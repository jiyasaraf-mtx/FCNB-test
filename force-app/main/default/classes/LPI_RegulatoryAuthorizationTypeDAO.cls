/**
 * @author                      : MTX Group Product Team
 * @since                       : 6 Jan, 2023
 * @description                 : This class contains DAO methods for RegulatoryAuthorizationType object
 * @last modified by            : MTX Group Product Team
 * @last modified date          : 17 Jan, 2023
 * @last modified details       : Filds are added in getRATTypeByID
 */
public with sharing class LPI_RegulatoryAuthorizationTypeDAO {
    /**
     * @author                      : MTX Group Product Team
     * @since                       :
     * @description                 : Dynamic Query Get RegulatoryAuthorizationType fields by different where clauses.
     * @param  fields             	: fields with (,) separated
     * @param  whereClause          : where condition (Ex: Name = 'Nitesh' AND Status = 'Active')
     * @param  limitValue          	: any limit otherwise pass null
     * @param  sortingByFields      : fields name from which you have to sort otherwise pass null
     * @param  sortingOrder      	: order of sorting (asc or desc) accept only two value otehr wise pass null
     * @last modified by            : MTX Group Product Team
     * @last modified date          : (Add if modified by you)
     * @last modified details       : (Add if modified by you)
     */
    public static List<RegulatoryAuthorizationType> getRegulatoryAuthorizationTypeByDymanicQuery(
        String fields,
        String whereClause,
        String limitValue,
        String sortingByFields,
        String sortingOrder
    ) {
        String query = 'SELECT ' + fields + ' FROM RegulatoryAuthorizationType WHERE ' + whereClause + ' WITH SECURITY_ENFORCED ';
        if (sortingByFields != null) {
            query += ' ORDER BY ' + sortingByFields;
            if (sortingOrder != null) {
                query += ' ' + sortingOrder + ' ';
            }
        }
        if (limitValue != null) {
            query += ' LIMIT ' + (limitValue != null ? limitValue : '50000');
        }
        return Database.query(query);
    }

    /**
     * @author                      : MTX Group Product Team
     * @since                       : 6 Jan, 2023
     * @description                 : This method return the List of RAT records by ID
     * @param  setRATId             : Set of RAT Id
     * @last modified by            : MTX Group Product Team
     * @last modified date          : 17 Jan, 2023
     * @last modified details       : Filds are added
     */
    public static List<RegulatoryAuthorizationType> getRATTypeByID(
        Set<Id> setRATId
    ) {
        return [
            SELECT
                ID,
                Name,
                Authorisation_Type__c,
                RegulatoryAuthCategory,
                IssuingDepartment.Name,
                Email_Specifications_Final__c,
            	Open_for_Renewal__c,
                Renewal_Window_Period_Before_Expiry__c,
                Expiration_Day__c,
                Expiration_Month__c,
                Expiration_Cycle__c,
                Expiration_Period__c,
                Expiration_Date__c,
                Expiry_Rule_Type__c,
                ID_Card_Expiration_Period__c,
                Expiration_Fixed_Cycle_Start_Year__c,
                Expiration_Fixed_Cycle_Difference__c,
                Renewal_Expiration_Day__c,
                Renewal_Expiration_Month__c,
                Renewal_Expiration_Cycle__c,
                Renewal_Expiration_Period__c,
                Renewal_Expiry_Rule_Type__c,
            	License_Number_Format__c,
            	Course_Expiration_Day__c,
				Course_Expiration_Month__c,
				Course_Expiration_Cycle__c,
				Course_Expiration_Period__c,
                Temporary_License_Type__c,
                Temporary_License_Type__r.Id,
                Temporary_License_Type__r.Name,
				Temporary_License_Type__r.Open_for_Renewal__c,
                Temporary_License_Type__r.Renewal_Window_Period_Before_Expiry__c,
				Temporary_License_Type__r.Expiration_Day__c,
                Temporary_License_Type__r.Expiration_Month__c,
				Temporary_License_Type__r.Expiration_Cycle__c,
                Temporary_License_Type__r.Expiration_Period__c,
				Temporary_License_Type__r.Expiration_Date__c,
                Temporary_License_Type__r.Expiry_Rule_Type__c,
				Temporary_License_Type__r.ID_Card_Expiration_Period__c,
                Temporary_License_Type__r.Expiration_Fixed_Cycle_Start_Year__c,
				Temporary_License_Type__r.Expiration_Fixed_Cycle_Difference__c,
                Temporary_License_Type__r.Renewal_Expiration_Day__c,
				Temporary_License_Type__r.Renewal_Expiration_Month__c,
                Temporary_License_Type__r.Renewal_Expiration_Cycle__c,
				Temporary_License_Type__r.Renewal_Expiration_Period__c,
                Temporary_License_Type__r.Renewal_Expiry_Rule_Type__c,
                Temporary_License_Type__r.IssuingDepartment.Name
            FROM RegulatoryAuthorizationType
            WHERE Id IN :setRATId
            WITH SECURITY_ENFORCED
        ];
    }
    /****************************************** Without Security SOQL STARTS **************************************************/

    /**
     * @description       : Without Security Inner class for RegulatoryAuthorizationType
     *
     * @author            : MTX Group Product Team
     * @last modified on  : 07-26-2024
     * @last modified by  : MTX Group Product Team
     **/
    public without sharing class LPI_RegulatoryAuthorizationTypeWithoutSharingDAO {
        
        /**
        * @description : Get RegulatoryAuthorizationType for guest user.
        * @author MTX Group Product Team
        * @param fields 
        * @param whereClause 
        * @param limitValue 
        * @param sortingByFields 
        * @param sortingOrder 
        * @return List<RegulatoryAuthorizationType> 
        **/
        // Note : WITH SECURITY_ENFORCED NOT added as No access for guest user on this object.
        public List<RegulatoryAuthorizationType> getRegAuthTypeWithoutSecurity(
            String fields,
            String whereClause,
            String limitValue,
            String sortingByFields,
            String sortingOrder
        ) {
            String query = 'SELECT ' + fields + ' FROM RegulatoryAuthorizationType WHERE ' + whereClause;
            if (sortingByFields != null) {
                query += ' ORDER BY ' + sortingByFields;
                if (sortingOrder != null) {
                    query += ' ' + sortingOrder + ' ';
                }
            }
            if (limitValue != null) {
                query += ' LIMIT ' + (limitValue != null ? limitValue : '50000');
            }
            return Database.query(query);
        }
    }
}