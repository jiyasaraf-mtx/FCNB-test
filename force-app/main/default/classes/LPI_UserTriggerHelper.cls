/**
 * @author       : MTX Group Product Team
 * @description  : This Class is the Helper class on User trigger
 * @since        : 09-Jan-2023
 */
public class LPI_UserTriggerHelper {

    public static final Map<String,String> PROFILE_NAME_TO_ROLE_NAME = new Map<String,String>{
        
        'Board Staff' => 'Board Staff'
    };

    /**
    *   @author : MTX Group Product Team
    *   @since  : 09-Jan-2023
    *   @description : This method manages the permission set assignment based on metadata on inesert
    */
    public static void managePermissionSetOnInsert(List<User> recordsList){
        try{
            Set<Id> userIdSet = new Set<Id>();
             
            for(User userRecord : recordsList){
                if(userRecord.isActive){
                    userIdSet.add(userRecord.Id);
                }
            }
            if(!userIdSet.isEmpty()){
                assignPermissionSet(userIdSet);
            }
        }
        catch(Exception e) {
            LPI_ExceptionManager.logException('LPI_UserTriggerHelper', 'managePermissionSetOnInsert', e);
        }
    }
    
    /**
    *   @author : MTX Group Product Team
    *   @since  : 09-Jan-2023
    *   @description :  
    */
    public static void managePermissionSetOnUpdate(List<User> recordsList, Map<Id, User> mapOfOldRecords){
        try{
            Set<Id> userToAssignPermissionIdSet = new Set<Id>();
            Set<Id> userToRemovePermissionIdSet = new Set<Id>();
            for(User userRecord : recordsList){
                if(mapOfOldRecords != null && mapOfOldRecords.get(userRecord.Id).isActive != userRecord.isActive){
                    if(userRecord.isActive){
                        userToAssignPermissionIdSet.add(userRecord.Id);
                    }else if(!userRecord.isActive){
                        userToRemovePermissionIdSet.add(userRecord.Id);
                    }
                }
            }
            if(!userToAssignPermissionIdSet.isEmpty()){
                LPI_UserTriggerHelper.assignPermissionSet(userToAssignPermissionIdSet);
            }
            if(!userToRemovePermissionIdSet.isEmpty()){
                LPI_UserTriggerHelper.removePermissionSet(userToRemovePermissionIdSet);
            }
        }
        catch(Exception e) {
            LPI_ExceptionManager.logException('LPI_UserTriggerHelper', 'managePermissionSetOnUpdate', e);
        }
    }
    
    /**
    *   @author : MTX Group Product Team
    *   @since  : 09-Jan-2023
    *   @description : This method remove persmission set from user based on metadata
    */
    private static void removePermissionSet(Set<Id> userIdSet){
        try{
            Set<Id> profileIdSet = new Set<Id>();
            Set<Id> permissionIdSet = new Set<Id>();
            Set<Id> permissionGroupIdSet = new Set<Id>();

            Set<String> permissionSetName = new Set<String>();
            Set<String> permissionSetGroupName = new Set<String>();

            Map<Id,String> profileIdToName = new Map<Id,String>();
            LPI_UserDao.LPI_UserWithoutSharingDAO classObj = new LPI_UserDao.LPI_UserWithoutSharingDAO();
            List<User> userList = classObj.getUserRecordsByIdsWithoutSharing(userIdSet);
            
            List<PermissionSetAssignment> deletePermissionSetList = new List<PermissionSetAssignment>();
            
             
            Set<Id> removeAccessToAccountIdSet= new Set<Id>();
            
            Map<Id,Set<Id>> removeAccRelatedObjAccessToChildAccSetMap = new Map<Id,Set<Id>>();
            Set<Id> removeAccessToChildAccountId = new Set<Id>();
            
             
            for(User userRecord : userList){
                profileIdSet.add(userRecord.ProfileId);
                
                if(userRecord.AccountId != NULL){
                    removeAccessToAccountIdSet.add(userRecord.AccountId);
                }
            }
            
            List<Profile> profileRecordList = new LPI_UserDao.LPI_UserWithoutSharingDAO().getProfileById(profileIdSet);
            for(Profile profileRecord : profileRecordList){
                profileIdToName.put(profileRecord.Id,profileRecord.Name);
            }
            if(!profileIdToName.isEmpty()){
                 
                List<LPI_Permission_Set_Assignment__mdt> permList = 
                    new LPI_CustomMetadataTypeDAO.LPI_CustomMetadataTypeWithoutSharingDAO().
                    getPermissionSetAssignmentMdtByProfileName(profileIdToName.Values());
                
                for(LPI_Permission_Set_Assignment__mdt  permissionSetAssignmentRecord : permList){
                    if(permissionSetAssignmentRecord.Permission_Set_Api_Name__c != null 
                    && permissionSetAssignmentRecord.Permission_Set_Api_Name__c != ''){
                        permissionSetName.addAll(permissionSetAssignmentRecord.Permission_Set_Api_Name__c.split(','));
                    }
                    if(permissionSetAssignmentRecord.Permission_Set_Group_Api_Name__c != null 
                    && permissionSetAssignmentRecord.Permission_Set_Group_Api_Name__c != ''){
                        permissionSetGroupName.addAll(permissionSetAssignmentRecord.Permission_Set_Group_Api_Name__c.split(','));
                    }
                }
                if(!permissionSetName.isEmpty()){
                    
                    List<PermissionSet> permissionSetRecordList = 
                        new LPI_UserDao.LPI_UserWithoutSharingDAO().getPermissionSetByName(permissionSetName);
                    for(PermissionSet permissionSetRecord : permissionSetRecordList){
                        permissionIdSet.add(permissionSetRecord.Id);
                    }
                    if(!permissionIdSet.isEmpty()){
                        
                        List<PermissionSetAssignment> psaList = 
                            new LPI_UserDao.LPI_UserWithoutSharingDAO().getPermissionSetAssignment(userIdSet);
                        for(PermissionSetAssignment psa : psaList){
                            if(permissionIdSet.contains(psa.PermissionSetId)){
                                deletePermissionSetList.add(psa);           
                            }
                        }
                    }
                }

                if(!permissionSetGroupName.isEmpty()){
                    
                    List<PermissionSetGroup> permissionSetGroupRecordList = 
                        new LPI_UserDao.LPI_UserWithoutSharingDAO().getPermissionSetGroupByName(permissionSetGroupName);
                    for(PermissionSetGroup permissionSetGroupRecord : permissionSetGroupRecordList){
                        permissionGroupIdSet.add(permissionSetGroupRecord.Id);
                    }
                    if(!permissionGroupIdSet.isEmpty()){
                        
                        List<PermissionSetAssignment> psaList = 
                            new LPI_UserDao.LPI_UserWithoutSharingDAO().getPermissionSetAssignment(userIdSet);
                        for(PermissionSetAssignment psa : psaList){
                            if(permissionGroupIdSet.contains(psa.PermissionSetId)){
                                deletePermissionSetList.add(psa);           
                            }
                        }
                    }
                }
            }
            
            if(!removeAccessToAccountIdSet.isEmpty()){
                
                for(Business_Relationships__c br : [
                    SELECT Id, Related_To__c, Related_From__c, EndDate__c, Start_Date__c, Skip_Sharing__c, Roles__c
                    FROM Business_Relationships__c
                    WHERE Roles__c IN: LPI_ApexSharingForPortalBatch.rolesSet AND
                    Related_To__c IN: removeAccessToAccountIdSet
                ]){
                    if(!removeAccRelatedObjAccessToChildAccSetMap.containsKey(br.Related_From__c)){
                        removeAccRelatedObjAccessToChildAccSetMap.put(br.Related_From__c, new Set<Id>());
                    }
                    removeAccRelatedObjAccessToChildAccSetMap.get(br.Related_From__c).add(br.Related_To__c);
                    removeAccessToChildAccountId.add(br.Related_To__c);
                }
            }
            
            System.enqueueJob(new LPI_UserRecordJobQueue(
                deletePermissionSetList, removeAccRelatedObjAccessToChildAccSetMap, removeAccessToChildAccountId, null, 'remove'
            ));
        }
        catch(Exception e) {
            LPI_ExceptionManager.logException('LPI_UserTriggerHelper', 'removePermissionSet', e);
        }
    }
    
    /**
    *   @author : MTX Group Product Team
    *   @since  : 09-Jan-2023
    *   @description : This method assign persmission set to user based on metadata
    */
    public static void assignPermissionSet(Set<Id> userIdSet){
        try{
            Set<Id> profileIdSet = new Set<Id>();
            Set<String> permissionSetName = new Set<String>();
            Set<String> permissionSetGroupName = new Set<String>();

            Map<String,List<String>> profileToPermissionSet = new Map<String,List<String>>();
            Map<String,List<String>> profileToPermissionSetGroup = new Map<String,List<String>>();

            Map<String,PermissionSet> permissionSetMap = new Map<String,PermissionSet>();
            Map<String,PermissionSetGroup> permissionSetGroupMap = new Map<String,PermissionSetGroup>();
            Map<Id,String> profileIdToName = new Map<Id,String>();
            List<PermissionSetAssignment> insertPermissionSetList = new List<PermissionSetAssignment>();
            LPI_UserDao.LPI_UserWithoutSharingDAO classObj = new LPI_UserDao.LPI_UserWithoutSharingDAO();
            List<User> userList = classObj.getUserRecordsByIdsWithoutSharing(userIdSet);
            
             
            Set<Id> giveAccessToAccountIdSet= new Set<Id>();
             
            Map<Id,Set<Id>> giveAccRelatedObjAccessToChildAccSetMap = new Map<Id,Set<Id>>();
            Set<Id> giveAccessToChildAccountId = new Set<Id>();
            Map<Id,Id> accountIdToUserIdMap = new Map<Id,Id>();

            for(User userRecord : userList){
                profileIdSet.add(userRecord.ProfileId);
                if(userRecord.AccountId != NULL){
                    giveAccessToAccountIdSet.add(userRecord.AccountId);
                }
                accountIdToUserIdMap.put(userRecord.AccountId, userRecord.Id);
            }
            List<Profile> profileRecordList = new LPI_UserDao.LPI_UserWithoutSharingDAO().getProfileById(profileIdSet);
            for(Profile profileRecord : profileRecordList){
                profileIdToName.put(profileRecord.Id,profileRecord.Name);
            } 
            if(!profileIdToName.isEmpty()){
                List<LPI_Permission_Set_Assignment__mdt> permList = 
                    new LPI_CustomMetadataTypeDAO.LPI_CustomMetadataTypeWithoutSharingDAO().
                    getPermissionSetAssignmentMdtByProfileName(profileIdToName.Values());
                
                for(LPI_Permission_Set_Assignment__mdt permissionSetAssignmentRecord :permList){
                    if(permissionSetAssignmentRecord.Permission_Set_Api_Name__c != NULL 
                       && permissionSetAssignmentRecord.Permission_Set_Api_Name__c != ''){
                           profileToPermissionSet.put(permissionSetAssignmentRecord.Profile_Name__c , permissionSetAssignmentRecord.Permission_Set_Api_Name__c.split(','));
                           permissionSetName.addAll(permissionSetAssignmentRecord.Permission_Set_Api_Name__c.split(','));
                       }
                    if(permissionSetAssignmentRecord.Permission_Set_Group_Api_Name__c != NULL 
                       && permissionSetAssignmentRecord.Permission_Set_Group_Api_Name__c != ''){
                            profileToPermissionSetGroup.put(permissionSetAssignmentRecord.Profile_Name__c , permissionSetAssignmentRecord.Permission_Set_Group_Api_Name__c.split(','));
                            permissionSetGroupName.addAll(permissionSetAssignmentRecord.Permission_Set_Group_Api_Name__c.split(','));
                       }
                }
                
                if(!permissionSetName.isEmpty()){
                     
                    List<PermissionSet> permissionSetRecordList = 
                        new LPI_UserDao.LPI_UserWithoutSharingDAO().getPermissionSetByName(permissionSetName);
                    for(PermissionSet PermissionSetRecord : permissionSetRecordList){
                        permissionSetMap.put(PermissionSetRecord.Name ,PermissionSetRecord);
                    }
                    if(!permissionSetMap.isEmpty()){
                        for(User userRecord : userList){
                            if(profileIdToName.containsKey(userRecord.ProfileId) && profileToPermissionSet.containsKey(profileIdToName.get(userRecord.ProfileId))){
                                for(String permissionName : profileToPermissionSet.get(profileIdToName.get(userRecord.ProfileId))){
                                    if(permissionSetMap.containsKey(permissionName)){
                                        PermissionSetAssignment psa = new PermissionSetAssignment (PermissionSetId = permissionSetMap.get(permissionName).Id , AssigneeId = userRecord.Id);
                                        insertPermissionSetList.add(psa);
                                    }
                                }
                            }
                        } 
                    }
                }

                if(!permissionSetGroupName.isEmpty()){
                    
                    List<PermissionSetGroup> permissionSetGroupRecordList = 
                        new LPI_UserDao.LPI_UserWithoutSharingDAO().getPermissionSetGroupByName(permissionSetGroupName);
                    for(PermissionSetGroup PermissionSetGroupRecord : permissionSetGroupRecordList){
                        permissionSetGroupMap.put(PermissionSetGroupRecord.DeveloperName, PermissionSetGroupRecord);
                    }
                    if(!permissionSetGroupMap.isEmpty()){
                        for(User userRecord : userList){
                            if(profileIdToName.containsKey(userRecord.ProfileId) && profileToPermissionSetGroup.containsKey(profileIdToName.get(userRecord.ProfileId))){
                                for(String permissionName : profileToPermissionSetGroup.get(profileIdToName.get(userRecord.ProfileId))){
                                    if(permissionSetGroupMap.containsKey(permissionName)){
                                        PermissionSetAssignment psa = new PermissionSetAssignment (PermissionSetGroupId = permissionSetGroupMap.get(permissionName).Id, AssigneeId = userRecord.Id);
                                        insertPermissionSetList.add(psa);
                                    }
                                }
                            }
                        }  
                    }
                }
                
            }
            
            
            if(!giveAccessToAccountIdSet.isEmpty()){
                for(Business_Relationships__c br : [
                    SELECT Id, Related_To__c, Related_From__c, EndDate__c, Start_Date__c, Skip_Sharing__c, Roles__c
                    FROM Business_Relationships__c
                    WHERE Roles__c IN: LPI_ApexSharingForPortalBatch.rolesSet AND
                    Related_To__c IN: giveAccessToAccountIdSet
                ]){
                    if( br.EndDate__c == NULL && br.Start_Date__c != NULL && br.Skip_Sharing__c == false ){
                        if(!giveAccRelatedObjAccessToChildAccSetMap.containsKey(br.Related_From__c)){
                            giveAccRelatedObjAccessToChildAccSetMap.put(br.Related_From__c, new Set<Id>());
                        }
                        giveAccRelatedObjAccessToChildAccSetMap.get(br.Related_From__c).add(br.Related_To__c);
                        giveAccessToChildAccountId.add(br.Related_To__c);
                    }

                    if(!giveAccRelatedObjAccessToChildAccSetMap.isEmpty()){
                        for(Account acc : [
                            SELECT Id, ParentId
                            FROM Account 
                            WHERE ParentId IN: giveAccRelatedObjAccessToChildAccSetMap.keySet()
                            AND ParentId != NULL
                        ]){
                            if(giveAccRelatedObjAccessToChildAccSetMap.containsKey(acc.ParentId)){
                                giveAccRelatedObjAccessToChildAccSetMap.put(acc.Id, giveAccRelatedObjAccessToChildAccSetMap.get(acc.ParentId));
                                giveAccessToChildAccountId.add(acc.Id);
                            }
                        }
                    }
                    
                }
            }
            
            System.enqueueJob(new LPI_UserRecordJobQueue(
                insertPermissionSetList, giveAccRelatedObjAccessToChildAccSetMap, giveAccessToChildAccountId, accountIdToUserIdMap,'create'
            ));
        }
        catch(Exception e) {
            LPI_ExceptionManager.logException('LPI_UserTriggerHelper', 'assignPermissionSet', e);
        }
    }
    
    /**
    *   @author : MTX Group Product Team
    *   @since  : 09-Jan-2023
    *   @description : This method give access of account and contact to PORTAL USER
    */
    public static void giveAccountAccessToUser(List<User> recordsList, Map<Id,User> mapOfOldRecords){
        try{
        	Set<Id> userIdSet = new Set<Id>();
            
            for(User userRecord : recordsList){
                 
                if((mapOfOldRecords == null || mapOfOldRecords.get(userRecord.Id).IsActive != userRecord.IsActive ) 
                   && userRecord.IsPortalEnabled && userRecord.IsActive ){
                         userIdSet.add(userRecord.Id);            
                   }
            }
            if(!userIdSet.isEmpty()){
                futureCallToFiveAccountAccess(userIdSet);
            }
        }
        catch(Exception e) {
            LPI_ExceptionManager.logException('LPI_UserTriggerHelper', 'giveAccountAccessToUser', e);
    	}
    }
    
    /**
    *   @author :MTX Group Product Team
    *   @since  : 09-Jan-2023
    *   @description : METHOD TO AVOID MIX DML
    */
    @future
    private static void futureCallToFiveAccountAccess(Set<Id> userIdSet){
        Map<Id,Set<Id>> accountIdUserIdSetMap = new Map<Id,Set<Id>>();
        List<Sharing_Ledger__c> sharingLedgerList = new List<Sharing_Ledger__c>();
        LPI_UserDao.LPI_UserWithoutSharingDAO classObj = new LPI_UserDao.LPI_UserWithoutSharingDAO();
        for(User userRecord : classObj.getUserRecordsByIdsWithoutSharing(userIdSet)){
            if(userRecord.AccountId != NULL){
                sharingLedgerList.add(
                    LPI_ApexSharingUtility.createStaticLedgerRecord('Account', userRecord.AccountId, userRecord.Id)
                );
            } 
        }
        
        if(!sharingLedgerList.isEmpty()){
            LPI_WithoutSharingUtility.upsertSObjectList(sharingLedgerList);
        }
    }

    /**
    * @description : Method to assign role to the user based on Profile.
    * @author MTX Group Product Team | 06-11-2023 
    * @param newList 
    **/
    public static void assignUserRole(List<User> newList){
        String fields = 'Id,Name';
        String whereClause = ' Name IN ' + LPI_ServiceUtility.getStringValuesByStringSet(PROFILE_NAME_TO_ROLE_NAME.keySet());
        Map<Id,Profile> idToProfileMap = new Map<Id,Profile>(LPI_ProfileDao.getProfileByDymanicQuery(fields,whereClause,null,null,null));
        if(idToProfileMap.keySet().isEmpty()){
            return;
        }
        fields = 'Id,Name';
        whereClause = ' Name IN ' + LPI_ServiceUtility.getStringValuesByList(PROFILE_NAME_TO_ROLE_NAME.values());
        Map<String,String> roleNameToIdMap = new Map<String,String> ();
        for(UserRole roleRec : LPI_UserRoleDao.getUserRoleByDynamicQuery(fields,whereClause,null,null,null)){
            roleNameToIdMap.put(roleRec.Name,roleRec.Id);
        }
        for(User userRec :  newList){
            if(!idToProfileMap.containsKey(userRec.ProfileId)){
                continue;
            }
            userRec.UserRoleId = roleNameToIdMap.get(PROFILE_NAME_TO_ROLE_NAME.get(idToProfileMap.get(userRec.ProfileId).Name));
        }
    }

    /**
     * @author                      : MTX Group Product Team
     * @since                       : 24 July, 2023
     * @description                 : This method  is to share the certification records and location records with the user
     * @param recordsList           : Takes List of user records
     * @return                      : `void`
     * @last modified by            : MTX Group Product Team
     * @last modified date          : (Add if modified by you)
     * @modified details            : (Add if modified by you)
     */
    public static void shareCertificationAndLocationRecords(List<User> newList){
        try{
            Map<Id, Id> accountIdTouserIdMap = new Map<Id, Id>();
            for(User userRec : newList){
                if(String.isNotBlank(userRec.AccountId)){
                    accountIdTouserIdMap.put(userRec.AccountId, userRec.Id);
                }
            }
            if(!accountIdTouserIdMap.isEmpty()){
                updateCertificationRecords(accountIdTouserIdMap);
            }
        }
        catch(Exception ex){
             LPI_ExceptionManager.logException('LPI_UserTriggerHelper', 'shareCertificationRecordsWithPortalUser', ex);
             throw new LPI_Exception(ex.getMessage());
        }
    }
    
    /**
     * @author                      : MTX Group Product Team
     * @since                       : 24 July, 2023
     * @description                 : This method  is to update the certification records in future
     * @param recordsList           : Takes List of user records
     * @return                      : `void`
     * @last modified by            : MTX Group Product Team
     * @last modified date          : (Add if modified by you)
     * @modified details            : (Add if modified by you)
     */
    @future
    public static void updateCertificationRecords(Map<Id, Id> accountIdTouserIdMap){
        try{
            List<BoardCertification> updateSbojectList = new List<BoardCertification>();
            String fields = 'Id, Applicant_Id__c';
            String whereClause = 'Applicant_Id__c IN ' + LPI_ServiceUtility.getStringValuesBySet(accountIdTouserIdMap.keySet());
            LPI_CertificationDAO.LPI_CertificationWithOutSharingDAO certObj = new LPI_CertificationDAO.LPI_CertificationWithOutSharingDAO();
             
            for(BoardCertification cert : certObj.getCertificationByDymanicQueryWithoutSecurity(fields, whereClause, null, null, null)){
                BoardCertification certRec = new BoardCertification();
                certRec.Applicant_Id__c = '';
                certRec.ownerId = accountIdTouserIdMap.get(cert.Applicant_Id__c);
                certRec.Id = cert.Id;
                updateSbojectList.add(certRec);
            }
            if(!updateSbojectList.isEmpty()){
                LPI_DML.doUpdate(updateSbojectList);
            }
        }
        catch(Exception ex){
            LPI_ExceptionManager.logException('LPI_UserTriggerHelper', 'updateCertificationRecords', ex);
            throw new AuraHandledException(ex.getMessage());
       }
        

    }
    /**
    * @description : To Update email
    * @author MTX Group Product Team | 05-20-2024 
    * @param newUserList 
    * @param oldUserMap 
    **/
    public static void updateEmailUsername(List<User> newUserList,Map<Id,User> oldUserMap){
        
        for(User userRec : newUserList){
            if(!oldUserMap.isEmpty()){
                if(String.isNotBlank(userRec.Email) && userRec.Email != oldUserMap.get(userRec.id).Email){
                    userRec.Username = userRec.Email+'.lpi';
                }
            }else if(String.isNotBlank(userRec.Email)){
                userRec.Username = userRec.Email+'.lpi';
            }
        }
    }
    
}