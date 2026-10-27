/**
 * @author                      : MTX Group Product Team
 * @since                       : 10 Jan, 2023
 * @description                 : This method contains DAO methods for Regulatory_Authorization_Content__c object
 * @last modified by            : MTX Group Product Team
 * @last modified date          : (Add if modified by you)
 * @last modified details       : (Add if modified by you)
 */
public with sharing class LPI_RegulatoryAuthorizationContentDAO {
    
    /**
     * @author                      : MTX Group Product Team
     * @since                       : 10 Jan, 2023
     * @description                 : This method return Regulatory_Authorization_Content__c records by RAT Type ID and Record Type.Developer Name
     * @param  setOfRegAuthId       : Set of RAT Type Id
     * @param  recordTypeDevName    : Record Type Developer Name
     * @return                      : returns List<Regulatory_Authorization_Content__c>
     * @last modified by            : MTX Group Product Team
     * @last modified date          : (Add if modified by you)
     * @last modified details       : (Add if modified by you)
     */
    public static List<Regulatory_Authorization_Content__c> getRegAuthContentByRATTypeAndRecordType(Set<Id> setOfRegAuthId, String recordTypeDevName){
        // Without sharing / without SECURITY_ENFORCED so portal users can clone RAT
        // document checklists onto Application_Document__c during PAR insert.
        return new LPI_RegAuthorizationContentWithoutSharingDAO().getRegAuthContentByRATTypeAndRecordType(
            setOfRegAuthId,
            recordTypeDevName
        );
    }
    /****************************************** Without Security SOQL STARTS **************************************************/

    /**
     * @description       : Without Security Inner class for Regulatory_Authorization_Content__c
     *                      
     * @author            : MTX Group Product Team
     * @last modified on  : 07-26-2024
     * @last modified by  : MTX Group Product Team
    **/
    public without sharing class LPI_RegAuthorizationContentWithoutSharingDAO {

        public List<Regulatory_Authorization_Content__c> getRegAuthContentByRATTypeAndRecordType(
            Set<Id> setOfRegAuthId,
            String recordTypeDevName
        ) {
            return [
                SELECT
                    ID,
                    Name_of_Document__c,
                    Is_Document_Required__c,
                    RecordTypeId,
                    Responsible_Party__c,
                    Sequence_of_Document__c,
                    Related_Element_Name__c,
                    Type_of_Due_Diligence__c,
                    Regulatory_Authorization_Type__c,
                    RecordType.DeveloperName,
                    Description__c,
                    Type__c,
                    Sub_Type__c,
                    Help_Text__c,
                    Is_Lawful_Presence_Document__c
                FROM Regulatory_Authorization_Content__c
                WHERE
                    Regulatory_Authorization_Type__c = :setOfRegAuthId
                    AND RecordType.DeveloperName = :recordTypeDevName
            ];
        }
	
        /**
         * @author                      : MTX Group Product Team
         * @since                       : 
         * @description                 : Dynamic Query Get Regulatory_Authorization_Content__c fields by different where clauses.
         * @param  fields             	: fields with (,) separated
         * @param  whereClause          : where condition (Ex: Name = 'Nitesh' AND Status = 'Active')
         * @param  limitValue          	: any limit otherwise pass null
         * @param  sortingByFields      : fields name from which you have to sort otherwise pass null
         * @param  sortingOrder      	: order of sorting (asc or desc) accept only two value otehr wise pass null
         * @last modified by            : MTX Group Product Team
         * @last modified date          : (Add if modified by you)
         * @last modified details       : (Add if modified by you)
         */
        public List<Regulatory_Authorization_Content__c> getRegAuthorizationContentByDymanicQuery(String fields,
                                                String whereClause,
                                                String limitValue,
                                                String sortingByFields,
                                                String sortingOrder){

            String query = 'SELECT ';
            query += fields;
            query += ' FROM Regulatory_Authorization_Content__c ';
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
    }
}