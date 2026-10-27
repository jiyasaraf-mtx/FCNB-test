/**
 * @author                      : MTX Group Product Team
 * @since                       : 17 Jan, 2023
 * @description                 : This class contains methods to perform withdrawal of PAR/IA/BLA records in the portal.
 * @last modified by            : MTX Group Product Team
 * @last modified date          : 14th Feb 2023
 * @last modified details       : Code Review Fixes
 */
global with sharing class LPI_RemoteActionForApplicationWithdraw implements Callable {
    /**
     * @description This Method is Used to Internally call the invokeMethod.
     * @author MTX Group Product Team | 01-31-2023
     * @param action
     * @param args
     * @return Object
     **/
    global Object call(String action, Map<String, Object> args) {
        Map<String, Object> input = (Map<String, Object>) args.get('input');
        Map<String, Object> output = (Map<String, Object>) args.get('output');
        Map<String, Object> options = (Map<String, Object>) args.get('options');
        return invokeMethod(action, input, output, options);
    }

    /**
     * @description Used to invoke Respective class based on the method type.
     * @author MTX Group Product Team | 01-23-2023
     * @param methodName
     * @param inputMap
     * @param outMap
     * @param options
     * @return Boolean
     **/
    private Boolean invokeMethod(
        String methodName,
        Map<String, Object> inputMap,
        Map<String, Object> outMap,
        Map<String, Object> options
    ) {
        Boolean result = false;
        try {
            if (methodName == 'withdrawApplication') {
                outMap.put(
                    'withdrawApplication',
                    withdrawApplication((String) inputMap.get('id'))
                );
                result = true;
            }
        } catch (Exception e) {
            LPI_ExceptionManager.logException(
                'LPI_RemoteActionForApplicationWithdraw',
                'invokeMethod',
                e
            );
        }
        return result;
    }
    /**
     * @description Used to Withdraw Application BLA,IA or PAR.
     * @author MTX Group Product Team | 01-23-2023
     * @param applicationId
     * @return Boolean
     **/
    @AuraEnabled
    public static Boolean withdrawApplication(String applicationId) {
        try {
            if (applicationId == null) {
                return false;
            }
            Boolean flag = false;
            Id recordid = Id.valueOf(applicationId);
            String objectName = recordid.getSObjectType()
                .getDescribe()
                .getName();

            if (objectName == LPI_LiteralConstant.PAR_SOBJECT_API) {
                deleteApplicationWithRelatedData(applicationId);
            }
            return flag;
        } catch (Exception ex) {
            LPI_ExceptionManager.logException(
                'LPI_RemoteActionForApplicationWithdraw',
                'withdrawApplication',
                ex
            );
        }
        return null;
    }

    /**
     * @description : Method to delete PAR on withdrawl along with its related data.
     * @author MTX Group Product Team | 06-29-2023
     * @param applicationId
     **/
    public static void deleteApplicationWithRelatedData(String applicationId) {
        try {
            Set<String> appStatusToAllowWithdrawl = new Set<String>{
                LPI_LiteralConstant.BLA_PAYMENT_PENDING_STATUS,
                LPI_LiteralConstant.PAR_DRAFT_STATUS
            };
            String fields = 'Id,Contact__c,Contact__r.AccountId,Employee_Information_ACR_Ids__c,Supervisor_ACR_Id__c,Person_Incharge_Relation_Id__c,Related_Owner_Ids__c,Preneed_Relationship_Ids__c,Designation_Of_Custodial_Relation_Id__c,Approval_Supervisors_AcrIds__c,Business_Info_Relation_Id__c';
            fields += ',(SELECT ID FROM Person_Examination__r),(SELECT ID FROM Person_Education__r),(SELECT ID FROM Application_Contents__r),(SELECT ID,Onbase_Document_Id__c,Onbase_Upload_Status__c FROM Application_Document__r),(SELECT ID FROM Bank_Accounts__r),(SELECT ID FROM Certifications__r),(SELECT ID FROM Course_Offerings__r),(SELECT ID FROM Employment_Histories__r),(SELECT ID,Location__c FROM Temp_Authorization_Application_Place__r),(SELECT ID FROM Training_Course_Participants__r),(SELECT ID FROM Training_Courses__r)';
            String whereClause =
                'Id = \'' +
                String.escapeSingleQuotes(applicationId) +
                '\' AND Status__c IN ' +
                LPI_ServiceUtility.getStringValuesByStringSet(
                    appStatusToAllowWithdrawl
                );
            List<PreliminaryApplicationRef> appList = LPI_PreliminaryApplicationRefDAO.getPreliminaryApplicationRefByDymanicQuery(
                fields,
                whereClause,
                null,
                null,
                null
            );
            if (appList.isEmpty()) {
                return;
            }
            PreliminaryApplicationRef parRecord = appList[0];
            whereClause = 'ContactId = \'' + parRecord.Contact__c + '\'';
            List<BusinessLicense> blList = LPI_BusinessLicenseDAO.fetchBusinessLicenseRecordsWithOrderByLimit(
                'Id',
                whereClause,
                '1',
                null
            );
            Boolean deleteAliasRecords = false;
            deleteAliasRecords = blList.isEmpty();
            List<SObject> deleteList = new List<SObject>();
            List<SObject> updateList = new List<SObject>();
            if (deleteAliasRecords) {
                whereClause =
                    'Contact__c = \'' +
                    parRecord.Contact__c +
                    '\' AND Id != \'' +
                    parRecord.Id +
                    '\'';
                List<PreliminaryApplicationRef> otherParList = LPI_PreliminaryApplicationRefDAO.getPreliminaryApplicationRefByDymanicQuery(
                    'Id',
                    whereClause,
                    '1',
                    null,
                    null
                );
                deleteAliasRecords = otherParList.isEmpty();
            }
            if (deleteAliasRecords) {
                whereClause =
                    'Account__c = \'' +
                    parRecord.Contact__r.AccountId +
                    '\'';
                deleteList.addAll(
                    LPI_AliasDAO.getAliasByDymanicQuery(
                        'Id',
                        whereClause,
                        null,
                        null,
                        null
                    )
                );
            }
            Set<String> relationShipIdsSet = new Set<String>();
            if (String.isNotBlank(parRecord.Employee_Information_ACR_Ids__c)) {
                relationShipIdsSet.addAll(
                    parRecord.Employee_Information_ACR_Ids__c.split(',')
                );
            }
            
            if (String.isNotBlank(parRecord.Supervisor_ACR_Id__c)) {
                relationShipIdsSet.addAll(
                    parRecord.Supervisor_ACR_Id__c.split(',')
                );
            }
            if (String.isNotBlank(parRecord.Person_Incharge_Relation_Id__c)) {
                relationShipIdsSet.addAll(
                    parRecord.Person_Incharge_Relation_Id__c.split(',')
                );
            }
            if (String.isNotBlank(parRecord.Related_Owner_Ids__c)) {
                relationShipIdsSet.addAll(
                    parRecord.Related_Owner_Ids__c.split(',')
                );
            }
            
            if (String.isNotBlank(parRecord.Preneed_Relationship_Ids__c)) {
                relationShipIdsSet.addAll(
                    parRecord.Preneed_Relationship_Ids__c.split(',')
                );
            }
            if(String.isNotBlank(parRecord.Designation_Of_Custodial_Relation_Id__c)){
                relationShipIdsSet.addAll(
                    parRecord.Designation_Of_Custodial_Relation_Id__c.split(',')
                );
            }
            if(String.isNotBlank(parRecord.Approval_Supervisors_AcrIds__c)){
                relationShipIdsSet.addAll(
                    parRecord.Approval_Supervisors_AcrIds__c.split(',')
                );
            }
            if(String.isNotBlank(parRecord.Business_Info_Relation_Id__c)){
                relationShipIdsSet.addAll(
                    parRecord.Business_Info_Relation_Id__c.split(',')
                );
            }
            deleteList.addAll(parRecord.Person_Examination__r);
            deleteList.addAll(parRecord.Person_Education__r);
            deleteList.addAll(parRecord.Application_Contents__r);
             
            for(Application_Document__c app:parRecord.Application_Document__r)
            {
                if(app.Onbase_Upload_Status__c != 'Uploaded to Onbase'){
                     deleteList.add(app); 
                }
                else if(app.Onbase_Upload_Status__c == 'Uploaded to Onbase'){
 			             app.Onbase_Upload_Status__c = 'Delete from onbase';
                         updateList.add(app); 
                }        
            }

            deleteList.addAll(parRecord.Bank_Accounts__r);
            deleteList.addAll(parRecord.Certifications__r);
            deleteList.addAll(parRecord.Course_Offerings__r);
            deleteList.addAll(parRecord.Employment_Histories__r);
            deleteList.addAll(
                parRecord.Temp_Authorization_Application_Place__r
            );
            deleteList.addAll(parRecord.Training_Course_Participants__r);
            deleteList.addAll(parRecord.Training_Courses__r);

            Set<String> locationIdSet = new Set<String>();
            Set<String> tempAuthIdSet = new Set<String>();
            for (
                Temp_AuthApplicationPlace__c temp : parRecord.Temp_Authorization_Application_Place__r
            ) {
                locationIdSet.add(temp.Location__c);
                tempAuthIdSet.add(temp.Id);
            }
            if (!locationIdSet.isEmpty()) {
                fields = 'Id,Location__c';
                whereClause =
                    ' Location__c != null AND Location__c IN ' +
                    LPI_ServiceUtility.getStringValuesByStringSet(
                        locationIdSet
                    ) +
                    ' AND ID NOT IN ' +
                    LPI_ServiceUtility.getStringValuesByStringSet(
                        tempAuthIdSet
                    );
                for (
                    Temp_AuthApplicationPlace__c tempAuthPlace : new LPI_TempAuthApplicationPlaceDAO.LPI_TempAuthApplicationPlaceWithoutSharingDAO()
                        .getTempAuthApplicationPlaceByDymanicQuery(
                            fields,
                            whereClause,
                            null,
                            null,
                            null
                        )
                ) {
                    locationIdSet.remove(tempAuthPlace.Location__c);
                }
            }
            
            if (!locationIdSet.isEmpty()) {
                fields = 'Id,PlaceId';
                whereClause =
                    ' PlaceId != null AND PlaceId IN ' +
                    LPI_ServiceUtility.getStringValuesByStringSet(
                        locationIdSet
                    );
                for (
                    AuthApplicationPlace authAppPlace : new LPI_AuthApplicationPlaceDAO.LPI_AuthApplicationPlaceWithoutSharingDAO()
                        .getAuthApplicationPlaceByDymanicQuery(
                            fields,
                            whereClause,
                            null,
                            null,
                            null
                        )
                ) {
                    locationIdSet.remove(authAppPlace.PlaceId);
                }  
            }

            Map<String,String> addressIdToLocationId = new Map<String,String>();
            if (!locationIdSet.isEmpty()) {
                for(Schema.Address addresRec : LPI_AddressDAO.getAddressByDymanicQuery('ParentId,Id', 'ParentId IN  '+ LPI_ServiceUtility.getStringValuesByStringSet(locationIdSet),null,null,null)){
                    addressIdToLocationId.put(addresRec.Id,addresRec.ParentId);
                }
            }
            if(!addressIdToLocationId.keySet().isEmpty()){
                for(Visit visitRec : new LPI_VisitControllerDAO.LPI_VisitControllerWithoutSharingDAO().getVisitListByDynamicQueryWithoutSharing(new List<String>{'PlaceId'},'PlaceId IN '+ LPI_ServiceUtility.getStringValuesByStringSet(addressIdToLocationId.keySet()),null,null,null)){
                    locationIdSet.remove(addressIdToLocationId.get(visitRec.PlaceId));
                }
            }

            for (String locationId : locationIdSet) {
                deleteList.add(new Schema.Location(Id = locationId));
            }

            Set<String> accountIdsSet = new Set<String>();
            Map<Id, Business_Relationships__c> idToBusinessRelationShipMap = new Map<Id, Business_Relationships__c>();
            if (!relationShipIdsSet.isEmpty()) {
                fields = 'Id,Related_To__c,Related_From__c';
                whereClause =
                    'ID IN ' +
                    LPI_ServiceUtility.getStringValuesByStringSet(
                        relationShipIdsSet
                    ) +
                    ' AND IsActive__c = FALSE AND EndDate__c = null';
                idToBusinessRelationShipMap = (new Map<Id, Business_Relationships__c>(
                    LPI_BusinessRelationshipDAO.fetchBusinessRelationshipRecords(
                        fields,
                        whereClause,
                        null,
                        null,
                        null
                    )
                ));
                for (
                    Business_Relationships__c businessRelationship : idToBusinessRelationShipMap.values()
                ) {
                    accountIdsSet.add(businessRelationship.Related_To__c);
                    accountIdsSet.add(businessRelationship.Related_From__c);
                    deleteList.add(businessRelationship);
                }
            }
            Map<Id, Account> idToAccountMap = new Map<Id, Account>();
            if (!accountIdsSet.isEmpty()) {
                fields =
                    'Id,PersonContactId,(SELECT ID FROM ComplaintParticipants),(SELECT ID FROM Cases),(SELECT ID,IsActive FROM Users WHERE IsActive = TRUE),(SELECT ID FROM BusinessLicenses),(SELECT ID FROM Business_Relationships1__r WHERE ID NOT IN ' +
                    LPI_ServiceUtility.getStringValuesBySet(
                        idToBusinessRelationShipMap.keySet()
                    ) +
                    ' ),(SELECT ID FROM Business_Relationships__r WHERE ID NOT IN ' +
                    LPI_ServiceUtility.getStringValuesBySet(
                        idToBusinessRelationShipMap.keySet()
                    ) +
                    ' )';
                whereClause =
                    ' ID IN ' +
                    LPI_ServiceUtility.getStringValuesByStringSet(
                        accountIdsSet
                    );
                idToAccountMap = (new Map<Id, Account>(
                    new LPI_AccountDAO.LPI_AccountWithoutSharingDAO()
                        .getAccountByDymanicQuery(
                            fields,
                            whereClause,
                            null,
                            null,
                            null
                        )
                ));
            }
            Set<String> accountContactIdSet = new Set<String>();
            Map<Id, Id> contactIdToAccountIdMap = new Map<Id, Id>();
            for (Account acc : idToAccountMap.values()) {
                if (
                    !acc.ComplaintParticipants.isEmpty() ||
                    !acc.Cases.isEmpty() ||
                    !acc.Users.isEmpty() ||
                    !acc.BusinessLicenses.isEmpty() ||
                    !acc.Business_Relationships1__r.isEmpty() ||
                    !acc.Business_Relationships__r.isEmpty()
                ) {
                    idToAccountMap.remove(acc.Id);
                }
                accountContactIdSet.add(acc.Id);
                if (String.isNotBlank(acc.PersonContactId)) {
                    accountContactIdSet.add(acc.PersonContactId);
                }
                if (String.isNotBlank(acc.PersonContactId)) {
                    contactIdToAccountIdMap.put(acc.PersonContactId, acc.Id);
                }
            }
            if (!accountContactIdSet.isEmpty()) {
                fields = 'Id,BusinessAccountNameId,Contact__c';
                whereClause =
                    '((BusinessAccountNameId != NULL AND BusinessAccountNameId IN ' +
                    LPI_ServiceUtility.getStringValuesByStringSet(
                        accountContactIdSet
                    ) +
                    ' ) OR  (Contact__c != NULL AND Contact__c IN ' +
                    LPI_ServiceUtility.getStringValuesByStringSet(
                        accountContactIdSet
                    ) +
                    ' )) AND Id != \'' +
                    String.escapeSingleQuotes(applicationId) +
                    '\'';
                for (
                    PreliminaryApplicationRef par : new LPI_PreliminaryApplicationRefDAO.LPI_PreliminaryApplicationRefWithoutSharingDAO()
                        .getPreliminaryApplicationRefByDymanicQuery(
                            fields,
                            whereClause,
                            null,
                            null,
                            null
                        )
                ) {
                    idToAccountMap.remove(par.BusinessAccountNameId);
                    if (
                        String.isNotBlank(par.Contact__c) &&
                        contactIdToAccountIdMap.containsKey(par.Contact__c)
                    ) {
                        idToAccountMap.remove(
                            contactIdToAccountIdMap.get(par.Contact__c)
                        );
                    }
                }
                fields = 'Id,ContactId,AccountId';
                whereClause =
                    '((ContactId != NULL AND ContactId IN ' +
                    LPI_ServiceUtility.getStringValuesByStringSet(
                        accountContactIdSet
                    ) +
                    ' ) OR (AccountId != NULL AND AccountId IN ' +
                    LPI_ServiceUtility.getStringValuesByStringSet(
                        accountContactIdSet
                    ) +
                    '))';
                for (
                    BusinessLicense bl : new LPI_BusinessLicenseDAO.LPI_BusinessLicenseWithoutSharingDAO()
                        .getBusinessLicenseByDymanicQuery(
                            fields,
                            whereClause,
                            null,
                            null,
                            null
                        )
                ) {
                    idToAccountMap.remove(
                        contactIdToAccountIdMap.get(bl.ContactId)
                    );
                    idToAccountMap.remove(bl.AccountId);
                }
            }
            deleteList.add(new PreliminaryApplicationRef(Id = applicationId));
            deleteList.addAll(idToAccountMap.values());
            Set<String> linkedRecordIdSet = new Set<String>();
            for (SObject record : deleteList) {
                linkedRecordIdSet.add(record.Id);
            }
            if (!linkedRecordIdSet.isEmpty()) {
                fields = 'Id,ContentDocumentId';
                whereClause =
                    'LinkedEntityId IN ' +
                    LPI_ServiceUtility.getStringValuesByStringSet(
                        linkedRecordIdSet
                    );
                Set<String> contentDocumentIdSet = new Set<String>();
                for (
                    ContentDocumentLink cdl : new LPI_ContentDocumentLinkDAO.LPI_ContentDocumentLinkWithoutSharingDAO()
                        .getContentDocumentLinkByDymanicQuery(
                            fields,
                            whereClause,
                            null,
                            null,
                            null
                        )
                ) {
                    if (contentDocumentIdSet.contains(cdl.ContentDocumentId)) {
                        continue;
                    }
                    contentDocumentIdSet.add(cdl.ContentDocumentId);
                    deleteList.add(
                        new ContentDocument(Id = cdl.ContentDocumentId)
                    );
                }
            }
            LPI_DML.deleteWithSystemPermission(deleteList);
            LPI_DML.doUpdate(updateList);

            if(idToAccountMap.keySet().isEmpty()){
                return;
            }
            List<User> userRecList = LPI_UserDao.getUserByDymanicQueryWithoutSecurityEnforced('Id,AccountId','Id = \'' + UserInfo.getUserId() + '\'',null,null,null);
            if(userRecList.isEmpty()){
                return;
            }
            List<Account> accList = LPI_AccountDAO.getAccountListByDynamicQuery(new List<String>{'Id','SelectedAccountId__c'},'Id = \''+ userRecList[0].AccountId + '\'',null,null,null);
            if(accList.isEmpty()){
                return;
            }
            if(idToAccountMap.containsKey(accList[0].SelectedAccountId__c)){
                accList[0].SelectedAccountId__c = accList[0].Id;
            }
            LPI_DML.doUpdate(accList);

        } catch (Exception ex) {
            LPI_ExceptionManager.logException(
                'LPI_RemoteActionForApplicationWithdraw',
                'deleteApplicationWithRelatedData',
                ex
            );
        }
    }
}