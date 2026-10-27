/**
 * @author                      : MTX Group Product Team
 * @since                       : 09-Jan-2023
 * @description                 : This class contains DAO methods for USER object
 */
public with sharing class LPI_UserDao {
    /**
     * @author                      : MTX Group Product Team
     * @since                       :
     * @description                 : Dynamic Query Get User fields by different where clauses.
     * @param  fields               : fields with (,) separated
     * @param  whereClause          : where condition (Ex: Name = 'Nitesh' AND Status = 'Active')
     * @param  limitValue           : any limit otherwise pass null
     * @param  sortingByFields      : fields name from which you have to sort otherwise pass null
     * @param  sortingOrder         : order of sorting (asc or desc) accept only two value otehr wise pass null
     * @last modified by            : MTX Group Product Team
     * @last modified date          : (Add if modified by you)
     * @last modified details       : (Add if modified by you)
     */
    public static List<User> getUserByDymanicQuery(
        String fields,
        String whereClause,
        String limitValue,
        String sortingByFields,
        String sortingOrder
    ) {
        String query = 'SELECT ';
        query += fields;
        query += ' FROM User ';
        query += 'WHERE ' + whereClause + ' WITH SECURITY_ENFORCED ';
        if (sortingByFields != null) {
            query += ' ORDER BY ' + sortingByFields;
            if (sortingOrder != null) {
                query += ' ' + sortingOrder + ' ';
            }
        }
        if (limitValue != null) {
            query += ' LIMIT ' + limitValue;
        }
        return Database.query(query);
    }

    /**
     * @description : Method to query user without adding WITH SECURITY_ENFORCED
     * @author MTX Group Product Team
     * @param fields
     * @param whereClause
     * @param limitValue
     * @param sortingByFields
     * @param sortingOrder
     * @return List<User>
     **/
    // Note : Do not add WITH SECURITY_ENFORCED to this query as Profile.Name is getting queried for which read access cannot be granted on profile level.
    public static List<User> getUserByDymanicQueryWithoutSecurityEnforced(
        String fields,
        String whereClause,
        String limitValue,
        String sortingByFields,
        String sortingOrder
    ) {
        String query = 'SELECT ';
        query += fields;
        query += ' FROM User ';
        query += 'WHERE ' + whereClause;
        if (sortingByFields != null) {
            query += ' ORDER BY ' + sortingByFields;
            if (sortingOrder != null) {
                query += ' ' + sortingOrder + ' ';
            }
        }
        if (limitValue != null) {
            query += ' LIMIT ' + limitValue;
        }
        return Database.query(query);
    }

    /**
     * @author                      : MTX Group Product Team
     * @since                       : 09-Jan-2023
     * @description                 : This method is to get USER Records From Id Set
     */
    public static List<User> getUserRecordsByIds(Set<Id> userIdSet) {
        return [
            SELECT Id, ProfileId, ContactId, AccountId, Profile.Name, Profile.UserLicense.Name
            FROM USER
            WHERE Id IN :userIdSet
        ];
    }

    /**
     * @author                      : MTX Group Product Team
     * @since                       : 09-Jan-2023
     * @description                 : This method is to get USER Records From Id Set
     * @last modified by            : MTX Group Product Team
     * @last modified date          : 2-1-2023
     * @last modified details       : Added fields in query
     */
    public static List<User> getCurrentUserRecord() {
        return [
            SELECT
                Id,
                Name,
                ProfileId,
                ContactId,
                Contact.FirstName,
                Contact.LastName,
                Contact.MiddleName,
                Account.Name,
                Account.Phone,
                Account.PersonEmail,
                Account.PersonHomePhone,
                Account.PersonOtherStreet,
                Account.PersonOtherStateCode,
                Account.PersonOtherCountryCode,
                Account.PersonOtherState,
                Account.PersonOtherCountry,
                Account.PersonOtherCity,
                Account.PersonOtherPostalCode,
                Account.Other_State__c,
                Account.FirstName,
                Account.MiddleName,
                Account.LastName,
                AccountId,
                IsPortalEnabled,
                Account.SelectedAccountId__c,
                Profile.Name,
                UserRole.Name
            FROM USER
            WHERE Id = :UserInfo.getUserId()
        ];
    }

    /**
     * @author                      : MTX Group Product Team
     * @since                       : 25-Jan-2023
     * @description                 : Dynamic Query Get Profile fields by different where clauses.
     * @param  fields               : fields with (,) separated
     * @param  whereClause          : where condition (Ex: Name = 'Portal User')
     * @param  limitValue           : any limit otherwise pass null
     * @param  sortingByFields      : fields name from which you have to sort otherwise pass null
     * @param  sortingOrder         : order of sorting (asc or desc) accept only two value otehr wise pass null
     * @last modified by            : MTX Group Product Team
     * @last modified date          : (Add if modified by you)
     * @last modified details       : (Add if modified by you)
     */
    public static List<Profile> getProfilesByDymanicQuery(
        String fields,
        String whereClause
    ) {
        String query = 'SELECT ';
        query += fields;
        query += ' FROM Profile ';
        query += 'WHERE ' + whereClause;
        return Database.query(query);
    }

    /****************************************** Without Security SOQL STARTS **************************************************/

    /**
     * @description       : Without Security Inner class for User
     *
     * @author            : MTX Group Product Team
     * @last modified on  : 07-26-2024
     * @last modified by  : MTX Group Product Team
     **/
    public without sharing class LPI_UserWithoutSharingDAO {
        /**
         * @author                      : MTX Group Product Team
         * @since                       :
         * @description                 : Dynamic Query Get User fields by different where clauses.
         * @param  fields               : fields with (,) separated
         * @param  whereClause          : where condition (Ex: Name = 'Nitesh' AND Status = 'Active')
         * @param  limitValue           : any limit otherwise pass null
         * @param  sortingByFields      : fields name from which you have to sort otherwise pass null
         * @param  sortingOrder         : order of sorting (asc or desc) accept only two value otehr wise pass null
         * @last modified by            : MTX Group Product Team
         * @last modified date          : (Add if modified by you)
         * @last modified details       : (Add if modified by you)
         */
        public List<User> getUserByDymanicQuery(
            String fields,
            String whereClause,
            String limitValue,
            String sortingByFields,
            String sortingOrder
        ) {
            String query = 'SELECT ';
            query += fields;
            query += ' FROM User ';
            query += 'WHERE ' + whereClause;
            if (sortingByFields != null) {
                query += ' ORDER BY ' + sortingByFields;
                if (sortingOrder != null) {
                    query += ' ' + sortingOrder + ' ';
                }
            }
            if (limitValue != null) {
                query += ' LIMIT ' + limitValue;
            }
            return Database.query(query);
        }

        /**
         * @description : Method to query user without adding WITH SECURITY_ENFORCED
         * @author MTX Group Product Team
         * @param fields
         * @param whereClause
         * @param limitValue
         * @param sortingByFields
         * @param sortingOrder
         * @return List<User>
         **/
        // Note : Do not add WITH SECURITY_ENFORCED to this query as Profile.Name is getting queried for which read access cannot be granted on profile level.
        public List<User> getUserByDymanicQueryWithoutSecurityEnforced(
            String fields,
            String whereClause,
            String limitValue,
            String sortingByFields,
            String sortingOrder
        ) {
            String query = 'SELECT ';
            query += fields;
            query += ' FROM User ';
            query += 'WHERE ' + whereClause;
            if (sortingByFields != null) {
                query += ' ORDER BY ' + sortingByFields;
                if (sortingOrder != null) {
                    query += ' ' + sortingOrder + ' ';
                }
            }
            if (limitValue != null) {
                query += ' LIMIT ' + limitValue;
            }
            return Database.query(query);
        }
        /**
         * @description : Method to query Profile without adding WITH SECURITY_ENFORCED
         * @author MTX Group Product Team 
         * @return List<Profile>
         **/
        public List<Profile> getProfileById(Set<Id> profileIdSet) {
            return [
                SELECT Id,Name 
                FROM Profile 
                WHERE Id IN : profileIdSet 
            ];
        }
        /**
         * @description : Method to query PermissionSet without adding WITH SECURITY_ENFORCED
         * @author MTX Group Product Team 
         * @return List<PermissionSet>
         **/
        public List<PermissionSet> getPermissionSetByName(Set<String> permissionSetName) {
            return [
                    SELECT Id, Name 
                    FROM PermissionSet 
                    WHERE Name IN : permissionSetName
                ];
        }

        /**
         * @description : Method to query PermissionSetGroup without adding WITH SECURITY_ENFORCED
         * @author MTX Group Product Team 
         * @return List<PermissionSetGroup>
         **/
        public List<PermissionSetGroup> getPermissionSetGroupByName(Set<String> permissionSetName) {
            return [
                SELECT Id, DeveloperName 
                FROM PermissionSetGroup 
                WHERE DeveloperName IN: permissionSetName
            ];
        }


        /**
         * @description : Method to query PermissionSetAssignment without adding WITH SECURITY_ENFORCED
         * @author MTX Group Product Team 
         * @return List<PermissionSet>
         **/
        public List<PermissionSetAssignment> getPermissionSetAssignment(Set<Id> userIdSet) {
            return [
                        SELECT Id,AssigneeId , PermissionSetId 
                        FROM PermissionSetAssignment 
                        WHERE AssigneeId IN:userIdSet
                    ];
        }

        /**
        * @author                      : MTX Group Product Team
        * @since                       : 09-Jan-2023
        * @description                 : This method is to get USER Records From Id Set
        */
        public List<User> getUserRecordsByIdsWithoutSharing(Set<Id> userIdSet) {
            return [
                SELECT Id, ProfileId, ContactId, AccountId, Profile.Name, Profile.UserLicense.Name
                FROM USER
                WHERE Id IN :userIdSet
            ];
        }
    }
}