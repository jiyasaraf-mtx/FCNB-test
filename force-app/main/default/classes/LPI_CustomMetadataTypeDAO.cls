/**
 * @author                          : MTX Group Product Team
 * @since                           : 12 Jan, 2023
 * @description                     : This class contains DAO methods for Custom Metadata Types
 * -------------------------------------------------------------------------------------------------------
 * Version      Date                Author                  Details
 *    1         12 Jan, 2023        MTX Group Product Team             Initial Developement
 *    2         20 Jan, 2023        MTX Group Product Team             Added Dynamic Query Methods
 *    3         23 Jan, 2023        MTX Group Product Team         Added getAllPortalNotificationByDeveloperNames()
 *    4         29 May, 2023        MTX Group Product Team         Security Fixes for SOQL, Added Limits
 * -------------------------------------------------------------------------------------------------------
 */
public with sharing class LPI_CustomMetadataTypeDAO {
    /**
     * @author                      : MTX Group Product Team
     * @since                       : 
     * @description                 : Dynamic Query Get CustomMetaData fields by different where clauses.
     * @param  fields             	: fields with (,) separated
     * @param  whereClause          : where condition (Ex: Name = 'Nitesh' AND Status = 'Active')
     * @param  limitValue          	: any limit otherwise pass null
     * @param  sortingByFields      : fields name from which you have to sort otherwise pass null
     * @param  sortingOrder      	: order of sorting (asc or desc) accept only two value otehr wise pass null
     * @last modified by            : MTX Group Product Team
     * @last modified date          : (Add if modified by you)
     * @last modified details       : (Add if modified by you)
     */
    public static List<SObject> getCustomMetaDataByDymanicQuery(String fields,
                                                                String customMetaDataName,
                                                                String whereClause,
                                                                String limitValue,
                                                                String sortingByFields,
                                                                String sortingOrder){

        String query = 'SELECT ';
        query += fields;
        query += ' FROM '+ customMetaDataName +' ';
        if(whereClause != null){
            query += 'WHERE ' + whereClause + ' WITH SECURITY_ENFORCED ';                                                        
        }                                                            
        if(sortingByFields != null){
        	query += ' ORDER BY ' + sortingByFields;
            if(sortingOrder != null){
                query += ' ' + sortingOrder + ' ';
            }
        }
        query += ' LIMIT ' + (limitValue != null ? limitValue : '50000');
        system.debug('---query'+query);
        return Database.query(query);
    }
    /**
     * @author                      : MTX Group Product Team
     * @since                       : 12 Jan, 2023
     * @description                 : This method is to get all the configurations from LPI_Profession_LicenseType_Mapping__mdt
     * @return                      : returns List<LPI_Profession_LicenseType_Mapping__mdt>
     * @last modified by            : MTX Group Product Team
     * @last modified date          : (Add if modified by you)
     * @last modified details       : (Add if modified by you)
     */
    public static List<LPI_Profession_LicenseType_Mapping__mdt> getAllMODPRProfessionLicenseType(){
        return [
            SELECT 
                Id, 
                DeveloperName, 
                Related_License__c,
                Board_Name__c
            FROM 
                LPI_Profession_LicenseType_Mapping__mdt
            WITH SECURITY_ENFORCED
            LIMIT 50000
        ];
    }
    /**
     * @author                      : MTX Group Product Team
     * @since                       : 20 Jan, 2023
     * @description                 : This method is to get all the Portal_Notification_Message__mdt
     * @return                      : returns List<Portal_Notification_Message__mdt>
     * @last modified by            : MTX Group Product Team
     * @last modified date          : (Add if modified by you)
     * @last modified details       : (Add if modified by you)
     */
    public static List<Portal_Notification_Message__mdt> getAllPortalNotificationByDeveloperName(String developerName){
        return [
            SELECT 
                Id, 
                DeveloperName, 
                Button_Label__c, 
                Description__c,
                Icon_Name__c,
                Navigate_Component_API_Name__c,
                Navigation_Tab_Label__c,
                Navigation_Type__c,
                Side_Color__c,
                Title__c
            FROM 
                Portal_Notification_Message__mdt 
            WHERE 
                DeveloperName =: developerName 
            WITH SECURITY_ENFORCED
            ];
    }

    /**
     * @author                      : MTX Group Product Team
     * @since                       : 23 Jan, 2023
     * @description                 : This method is to get all the Portal_Notification_Message__mdt by developer names provided
     * @return                      : returns List<Portal_Notification_Message__mdt>
     * @last modified by            : MTX Group Product Team
     * @last modified date          : (Add if modified by you)
     * @last modified details       : (Add if modified by you)
     */
    public static List<Portal_Notification_Message__mdt> getAllPortalNotificationByDeveloperNames(Set<String> setDeveloperNames){
        return [
            SELECT 
                Id, 
                DeveloperName, 
                Description__c,
                Title__c,
				Button_Label__c,
				Icon_Name__c,
				Navigate_Component_API_Name__c,
				Navigation_Tab_Label__c,
				Navigation_Type__c,
				Side_Color__c
            FROM 
                Portal_Notification_Message__mdt 
            WHERE 
                DeveloperName IN :setDeveloperNames 
            WITH SECURITY_ENFORCED
            ];
    }
    /**
     * @author                      : MTX Group Product Team
     * @since                       : 30 Jan, 2023
     * @description                 : This method is to get all the Notification_Message__mdt by developer names provided
     * @return                      : returns List<Notification_Message__mdt>
     * @last modified by            : MTX Group Product Team
     * @last modified date          : (Add if modified by you)
     * @last modified details       : (Add if modified by you)
     */
    public static List<Notification_Message__mdt> getAllNotificationByDeveloperNames(Set<String> setDeveloperNames){
        return [
            SELECT 
                Id,
            	DeveloperName,
            	Description__c,
            	Title__c,
                Template_Name__c,
                Attachment_Required__c,
                PDF_Attachment_Name__c,
                Email_CC_Addresses__c
            FROM 
                Notification_Message__mdt 
            WHERE 
                DeveloperName IN :setDeveloperNames 
            WITH SECURITY_ENFORCED
            ];
    }

     /**
     * @author                      : MTX Group Product Team
     * @since                       : 21th Nov, 2023
     * @description                 : Dynamic method is to get the In_App_Checklist_Settings__c
     * @return                      : returns List<In_App_Checklist_Settings__c>
     * @last modified by            : MTX Group Product Team
     * @last modified date          : (Add if modified by you)
     * @last modified details       : (Add if modified by you)
     */
    public static List<In_App_Checklist_Settings__c> dynamicGetAppChecklistSettingBusinessLicenseNumber(
                                                                String fields,
                                                                String whereClause,
                                                                String customSettingField
    ){
        String query = 'SELECT ';
        query += fields;
        query += ' FROM '+ customSettingField +' ';
        if(whereClause != null){
            query += 'WHERE ' + whereClause;                                                        
        }else{
            query += 'WHERE Business_License_Counter__c != null' ;
        }                                                   
        query += ' LIMIT 1 FOR UPDATE';
        return Database.query(query);
    }

    /****************************************** Without Security SOQL STARTS **************************************************/

    /**
     * @description       : Without Security Inner class for CustomMetadataType
     *                      
     * @author            : MTX Group Product Team
     * @last modified on  : 07-26-2024
     * @last modified by  : MTX Group Product Team
    **/
    public without sharing class LPI_CustomMetadataTypeWithoutSharingDAO 
    {   
        /**
        * @author                      : MTX Group Product Team
        * @since                       : 
        * @description                 : Dynamic Query Get CustomMetadataType fields by different where clauses.
        * @param  fields             	: fields with (,) separated
        * @param  whereClause          : where condition (Ex: Name = 'Nitesh' AND Status = 'Active')
        * @param  limitValue          	: any limit otherwise pass null
        * @param  sortingByFields      : fields name from which you have to sort otherwise pass null
        * @param  sortingOrder      	: order of sorting (asc or desc) accept only two value otehr wise pass null
        * @last modified by            : MTX Group Product Team
        * @last modified date          : (Add if modified by you)
        * @last modified details       : (Add if modified by you)
        */
        public List<SObject> getCustomMetaByDymQueryWithoutSec(
            String fields, String customMetaDataName, String whereClause, String limitValue, String sortingByFields, String sortingOrder
        ){
            String query = 'SELECT ';
            query += fields;
            query += ' FROM '+ customMetaDataName +' ';
            query += 'WHERE ' + whereClause + ' ';
            if(sortingByFields != null){
                query += ' ORDER BY ' + sortingByFields;
                if(sortingOrder != null){
                    query += ' ' + sortingOrder + ' ';
                }
            }
            query += ' LIMIT ' + (limitValue != null ? limitValue : '50000');
            System.debug(query);
            return Database.query(query);
        }
        
        public List<LPI_Permission_Set_Assignment__mdt> getPermissionSetAssignmentMdtByProfileName(List<String> profileName){
            return [
                SELECT Id, Profile_Name__c, Permission_Set_Api_Name__c, Permission_Set_Group_Api_Name__c
                FROM LPI_Permission_Set_Assignment__mdt  
                WHERE Profile_Name__c IN : profileName
            ];
        }
    }
}