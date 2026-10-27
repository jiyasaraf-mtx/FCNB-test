/**
 * @author                          : MTX Group Product Team
 * @since                           : 20 Jan, 2023
 * @description                     : This class contains DAO methods for Portal Notification
 * @last modified by                : MTX Group Product Team
 * @last modified date              : (Add if modified by you)
 * @last modified details           : (Add if modified by you)
 */
public with sharing class LPI_PortalNotificationDAO {
    /**
     * @author                      : MTX Group Product Team
     * @since                       : 
     * @description                 : Dynamic Query Get Notification__c fields by different where clauses.
     * @param  fields             	: fields with (,) separated
     * @param  whereClause          : where condition (Ex: Name = 'Nitesh' AND Status = 'Active')
     * @param  limitValue          	: any limit otherwise pass null
     * @param  sortingByFields      : fields name from which you have to sort otherwise pass null
     * @param  sortingOrder      	: order of sorting (asc or desc) accept only two value otehr wise pass null
     * @last modified by            : MTX Group Product Team
     * @last modified date          : (Add if modified by you)
     * @last modified details       : (Add if modified by you)
     */
    public static List<Notification__c> getPortalNotificationByDymanicQuery(String fields,
                                                                                String whereClause,
                                                                                String limitValue,
                                                                               	String sortingByFields,
                                                                               	String sortingOrder){

        String query = 'SELECT ';
        query += fields;
        query += ' FROM Notification__c ';
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
     * @since                       : 20 Jan, 2023
     * @description                 : This method is to get  the Notification__c by type and relatedIds
     * @return                      : returns List<Notification__c>
     * @last modified by            : MTX Group Product Team
     * @last modified date          : (Add if modified by you)
     * @last modified details       : (Add if modified by you)
     */
    public static List<Notification__c> getAllPortalNotificationByType(String type,Set<Id> relatedIds){
        return [SELECT 
                Id,Is_Resolved__c
                FROM Notification__c 
                WHERE Type__c =:type
                AND (Individual_Application__c IN:relatedIds 
                     OR Business_License_Application__c IN:relatedIds)
                AND Is_Resolved__c = false
                WITH SECURITY_ENFORCED];
    }
	/**
     * @author                      : MTX Group Product Team
     * @since                       : 20 Jan, 2023
     * @description                 : This method is to get  the Notification__c by account
     * @return                      : returns List<Notification__c>
     * @last modified by            : MTX Group Product Team
     * @last modified date          : (Add if modified by you)
     * @last modified details       : (Add if modified by you)
     */
    public static List<Notification__c> getAllPortalNotificationByAccountId(Set<Id> accountIds){
        return [Select 
                Id,Description__c, 
                Button_Label__c, Icon_Name__c, 
                Navigate_Component_API_Name__c, Side_Color__c,
                Url_Param_Json__c,Navigation_Type__c ,Type__c
                FROM Notification__c 
                WHERE Account__c IN :accountIds
                AND Is_Resolved__c = false
                AND RecordType.DeveloperName IN : LPI_LiteralConstant.PORTAL_NOTIFICATION_RECORDTYPE_DEV_NAME_SET
                WITH SECURITY_ENFORCED
                Order by CreatedDate desc];
    }
    /**
     * @author                      : MTX Group Product Team
     * @since                       : 20 Jan, 2023
     * @description                 : This method is to get  the Notification__c by Id
     * @return                      : returns List<Notification__c>
     * @last modified by            : MTX Group Product Team
     * @last modified date          : (Add if modified by you)
     * @last modified details       : (Add if modified by you)
     */
    public static List<Notification__c> getPortalNotificationById(Id notiId){
        return [SELECT 
                Id,Description__c
                FROM Notification__c 
                WHERE Id =: notiId
                WITH SECURITY_ENFORCED];
    }
    /****************************************** Without Security SOQL STARTS **************************************************/

    /**
     * @description       : Without Security Inner class for Notification__c
     *                      
     * @author            : MTX Group Product Team
     * @last modified on  : 07-26-2024
     * @last modified by  : MTX Group Product Team
    **/
    public without sharing class LPI_PortalNotificationWithoutSharingDAO {
	
        /**
         * @author                      : MTX Group Product Team
         * @since                       : 
         * @description                 : Dynamic Query Get Notification__c fields by different where clauses.
         * @param  fields             	: fields with (,) separated
         * @param  whereClause          : where condition (Ex: Name = 'Nitesh' AND Status = 'Active')
         * @param  limitValue          	: any limit otherwise pass null
         * @param  sortingByFields      : fields name from which you have to sort otherwise pass null
         * @param  sortingOrder      	: order of sorting (asc or desc) accept only two value otehr wise pass null
         * @last modified by            : MTX Group Product Team
         * @last modified date          : (Add if modified by you)
         * @last modified details       : (Add if modified by you)
         */
        public List<Notification__c> getPortalNotificationByDymanicQuery(String fields,
                                                String whereClause,
                                                String limitValue,
                                                String sortingByFields,
                                                String sortingOrder){

            String query = 'SELECT ';
            query += fields;
            query += ' FROM Notification__c ';
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