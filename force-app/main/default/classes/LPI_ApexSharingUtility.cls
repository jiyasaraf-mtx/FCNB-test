/**
* @author              : MTX Group Product Team
* @since               : 09-Jan-2023
* @description         : This class is utility class for managing apex sharing
* @history
*/
public without sharing class LPI_ApexSharingUtility {
    public final static String ACCOUNT_RECORDTYPE_BUSINESS = 'Business';
    public final static String SHARING_REASON_MANUAL = 'Manual';
    public final static String OBJECT_PRELIMINARYAPPLICATIONREF = 'PreliminaryApplicationRef';
    public final static String OBJECT_BUSINESSLICENSEAPPLICATION = 'BusinessLicenseApplication';    
    public final static String OBJECT_CERTIFICATION = 'BoardCertification';
    public final static String OBJECT_LICENSECONTENT = 'License_Content__c';
    public final static String OBJECT_APPLICATIONDOCUMENT = 'Application_Document__c';
    public final static String OBJECT_APPLICATIONCONTENT = 'Application_Content__c';
    public final static String OBJECT_REGULATORYTRXNFEE = 'RegulatoryTrxnFee';
    public final static String OBJECT_TEMPFEE = 'Temp_Fee__c';
    public final static String OBJECT_TEMPAUTHAPPLICATIONPLACE = 'Temp_AuthApplicationPlace__c';
    public final static String OBJECT_BANKACCOUNT = 'Bank_Account__c';
    public final static String OBJECT_ACCOUNT = 'Account';
    public final static String OBJECT_BUSINESSRELATIONSHIPS = 'Business_Relationships__c';
    public final static String OBJECT_BUSINESSRELATIONSHIPS_RELATEDTO = 'Business_Relationships_Related_To__c';
    public final static String OBJECT_LOCATION = 'Location';
    public final static String OBJECT_TRAININGCOURSEPARTICIPANT = 'TrainingCourseParticipant';
    public final static String OBJECT_ALIAS = 'Alias__c';
    public final static String OBJECT_TRAININGCOURSE = 'TrnCourse';   
    private static Map<String, String> objectToAccountRelationNameMap = new Map<String, String>{
        OBJECT_BUSINESSLICENSEAPPLICATION => 'AccountId',
        OBJECT_PRELIMINARYAPPLICATIONREF => 'BusinessAccountNameId',
        OBJECT_CERTIFICATION => 'Business_License__r.AccountId',
        OBJECT_LICENSECONTENT => 'Business_License__r.AccountId',
        OBJECT_APPLICATIONDOCUMENT => 'Preliminary_Application_Reference__r.BusinessAccountNameId',
        OBJECT_APPLICATIONCONTENT => 'Preliminary_Application_Reference__r.BusinessAccountNameId',
        OBJECT_REGULATORYTRXNFEE => 'AccountId',
        OBJECT_TEMPFEE => 'PreliminaryApplicationReference__r.BusinessAccountNameId',
        OBJECT_TEMPAUTHAPPLICATIONPLACE => 'Preliminary_Application_Reference__r.BusinessAccountNameId',
        OBJECT_BANKACCOUNT => 'Account__c',
        OBJECT_BUSINESSRELATIONSHIPS => 'Related_To__c',
        OBJECT_BUSINESSRELATIONSHIPS_RELATEDTO => 'Related_From__c',
        OBJECT_TRAININGCOURSEPARTICIPANT => 'Preliminary_Application_Reference__r.BusinessAccountNameId',
        OBJECT_ALIAS => 'Account__c',
        OBJECT_TRAININGCOURSE => 'Account__c'

	};
    private static Map<String, String> objectToParentAccountRelationNameMap = new Map<String, String>{
        OBJECT_BUSINESSLICENSEAPPLICATION => 'Account.ParentId',
        OBJECT_PRELIMINARYAPPLICATIONREF => 'BusinessAccountName.ParentId',
        OBJECT_CERTIFICATION => 'Business_License__r.Account.ParentId',
        OBJECT_LICENSECONTENT => 'Business_License__r.Account.ParentId',
        OBJECT_APPLICATIONDOCUMENT => 'Preliminary_Application_Reference__r.BusinessAccountName.ParentId',
        OBJECT_APPLICATIONCONTENT => 'Preliminary_Application_Reference__r.BusinessAccountName.ParentId',
        OBJECT_REGULATORYTRXNFEE => 'Account.ParentId',
        OBJECT_TEMPFEE => 'PreliminaryApplicationReference__r.BusinessAccountName.ParentId',
        OBJECT_TEMPAUTHAPPLICATIONPLACE => 'Preliminary_Application_Reference__r.BusinessAccountName.ParentId',
        OBJECT_BANKACCOUNT => 'Account__r.ParentId',
        OBJECT_BUSINESSRELATIONSHIPS => 'Related_To__r.ParentId',
        OBJECT_BUSINESSRELATIONSHIPS_RELATEDTO => 'Related_From__r.ParentId',
        OBJECT_TRAININGCOURSEPARTICIPANT => 'Preliminary_Application_Reference__r.BusinessAccountName.ParentId',
        OBJECT_ALIAS => 'Account__r.ParentId',
        OBJECT_TRAININGCOURSE => 'Account__r.ParentId'
	};
               
   /**
    * @author                      : MTX Group Product Team
    * @since                       : 09-Jan-2023
    * @description                 : This method is to get USER Records From ContactId Set
    */
    public static List<User> getUserRecordsByContactIds(Set<Id> contactIdSet) {
        return [
            SELECT Id, ProfileId, ContactId
            FROM USER
            WHERE ContactId IN :contactIdSet
            LIMIT 50000
        ];
    }
    
    /**
     * @author                      : MTX Group Product Team
     * @since                       : 09-Jan-2023
     * @description                 : This method is to get USER Records From accountIdSet Set
     */
    public static List<User> getUserRecordsBySccountIdSet(Set<Id> accountIdSet) {
        return [
            SELECT Id, ProfileId, ContactId, AccountId
            FROM USER
            WHERE AccountId IN :accountIdSet
            LIMIT 50000
        ];
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
            LIMIT 50000
        ];
    }

    /**
    *   @author                             : MTX Group Product Team
    *   @since                              : 11-Jan-2023
    *   @description                        : This method will give access of application related objects
    * 										  from account and there related contact map. 
    * 										  This is getting called from ACRTriggerHelper.
    */
    public static void giveAccessOfObjectsFromAccountIdFromBR(
        Map<Id, Set<Id>> giveAccRelatedObjAccessToConSetMap,Set<Id> giveAccessToAccountId
    ){
        Map<Id, Id> accountIdToUserIdMap = new Map<Id, Id>();
        List<Sharing_Ledger__c> sharingLedgerList = new List<Sharing_Ledger__c>();
        for (User us : getUserRecordsBySccountIdSet(giveAccessToAccountId)) {
            accountIdToUserIdMap.put(us.accountId, us.Id);
        }

        for (Account acc : [
            SELECT Id, OwnerId
            FROM Account
            WHERE Id IN :giveAccRelatedObjAccessToConSetMap.keySet()
            LIMIT 50000
        ]){
            for (Id childAccId : giveAccRelatedObjAccessToConSetMap.get(acc.Id)) {
                if (accountIdToUserIdMap.containsKey(childAccId)) {
                    if(acc.OwnerId != accountIdToUserIdMap.get(childAccId)){
                        sharingLedgerList.add(
                            createStaticLedgerRecord(
                                OBJECT_ACCOUNT, acc.Id, accountIdToUserIdMap.get(childAccId)
                            )
                        ); 
                    }
                }
            }
        }

        if(!sharingLedgerList.isEmpty()){
            LPI_WithoutSharingUtility.insertSObjectList(sharingLedgerList);
            sharingLedgerList = new List<Sharing_Ledger__c>();
        }
     
        List<Sharing_Ledger__c> secondSharingLedgerList = new List<Sharing_Ledger__c>();

        for (Business_Relationships__c br : [
            SELECT Id, OwnerId, Related_From__c, Related_To__c, Related_From__r.OwnerId, Related_To__r.OwnerId
            FROM Business_Relationships__c
            WHERE Related_From__c IN: giveAccRelatedObjAccessToConSetMap.keySet()
            OR Related_To__c IN: giveAccRelatedObjAccessToConSetMap.keySet()
            LIMIT 50000
        ]){
            if(giveAccRelatedObjAccessToConSetMap.containsKey(br.Related_From__c)){
                for (Id childAccId : giveAccRelatedObjAccessToConSetMap.get(br.Related_From__c)) {
                    if (accountIdToUserIdMap.containsKey(childAccId)) {
                        if(br.OwnerId != accountIdToUserIdMap.get(childAccId)){
                            sharingLedgerList.add(
                                createStaticLedgerRecord(
                                    OBJECT_BUSINESSRELATIONSHIPS, br.Id, accountIdToUserIdMap.get(childAccId)
                                )
                            );
                        }

                       
                        if(br.Related_To__r.OwnerId != accountIdToUserIdMap.get(childAccId)){
                            secondSharingLedgerList.add(
                                createStaticLedgerRecord(
                                    OBJECT_ACCOUNT, br.Related_To__c, accountIdToUserIdMap.get(childAccId)
                                )
                            );
                        }
                    }

                    
                }
            }
            if(giveAccRelatedObjAccessToConSetMap.containsKey(br.Related_To__c)){
                for (Id childAccId : giveAccRelatedObjAccessToConSetMap.get(br.Related_To__c)) {
                    if (accountIdToUserIdMap.containsKey(childAccId)) {
                        if(br.OwnerId != accountIdToUserIdMap.get(childAccId)){
                            sharingLedgerList.add(
                                createStaticLedgerRecord(
                                    OBJECT_BUSINESSRELATIONSHIPS, br.Id, accountIdToUserIdMap.get(childAccId)
                                )
                            ); 
                        }

                        
                        if(br.Related_From__r.OwnerId != accountIdToUserIdMap.get(childAccId)){
                            secondSharingLedgerList.add(
                                createStaticLedgerRecord(
                                    OBJECT_ACCOUNT, br.Related_From__c, accountIdToUserIdMap.get(childAccId)
                                )
                            );
                        }
                    }
                }
            }
        }

        if(!sharingLedgerList.isEmpty()){
            LPI_WithoutSharingUtility.insertSObjectList(sharingLedgerList);
            sharingLedgerList = new List<Sharing_Ledger__c>();
        }

        if(!secondSharingLedgerList.isEmpty()){
            LPI_WithoutSharingUtility.insertSObjectList(secondSharingLedgerList);
        }

        
        for (PreliminaryApplicationRef par : [
            SELECT Id, BusinessAccountNameId, OwnerId
            FROM PreliminaryApplicationRef
            WHERE BusinessAccountNameId IN :giveAccRelatedObjAccessToConSetMap.keySet()
            LIMIT 50000
        ]) {
            for (Id childAccId : giveAccRelatedObjAccessToConSetMap.get(par.BusinessAccountNameId)) {
                if (accountIdToUserIdMap.containsKey(childAccId)) {
                    if(par.OwnerId != accountIdToUserIdMap.get(childAccId)){
                        sharingLedgerList.add(
                            createStaticLedgerRecord(
                                OBJECT_PRELIMINARYAPPLICATIONREF, par.Id, accountIdToUserIdMap.get(childAccId)
                            )
                        );
                    }
                }
            }
        }
        
        if(!sharingLedgerList.isEmpty()){
            LPI_WithoutSharingUtility.insertSObjectList(sharingLedgerList);
            sharingLedgerList = new List<Sharing_Ledger__c>();
        }


       
        Map<Id, Id> blaToAccountMap = new Map<Id, Id>();
        for (BusinessLicenseApplication bla : [
            SELECT Id, AccountId, OwnerId
            FROM BusinessLicenseApplication
            WHERE AccountId IN :giveAccRelatedObjAccessToConSetMap.keySet()
            LIMIT 50000
        ]) {
            blaToAccountMap.put(bla.Id, bla.AccountId);
           
            for (Id childAccId : giveAccRelatedObjAccessToConSetMap.get(bla.AccountId)) {
                if (accountIdToUserIdMap.containsKey(childAccId)) {
                    if(bla.OwnerId != accountIdToUserIdMap.get(childAccId)){
                        sharingLedgerList.add(
                            createStaticLedgerRecord(
                                OBJECT_BUSINESSLICENSEAPPLICATION, bla.Id, accountIdToUserIdMap.get(childAccId)
                            )
                        );
                    }
                }
            }
        }
        
        if(!sharingLedgerList.isEmpty()){
            LPI_WithoutSharingUtility.insertSObjectList(sharingLedgerList);
            sharingLedgerList = new List<Sharing_Ledger__c>();
        }
        
       
        for (Application_Content__c ap : [
            SELECT Id, Preliminary_Application_Reference__r.BusinessAccountNameId, Business_License_Application__r.AccountId,
            OwnerId
            FROM Application_Content__c
            WHERE Preliminary_Application_Reference__r.BusinessAccountNameId IN :giveAccRelatedObjAccessToConSetMap.keySet()
            OR Business_License_Application__r.AccountId IN :giveAccRelatedObjAccessToConSetMap.keySet()
            LIMIT 50000
        ]) {
            Id accId = null;
            if (ap.Preliminary_Application_Reference__r.BusinessAccountNameId != null) {
                accId = ap.Preliminary_Application_Reference__r.BusinessAccountNameId;
            }
            else {
                accId = ap.Business_License_Application__r.AccountId;
            }
            if(giveAccRelatedObjAccessToConSetMap.containsKey(accId)){
                for (Id childAccId : giveAccRelatedObjAccessToConSetMap.get(accId)) {
                    if (accountIdToUserIdMap.containsKey(childAccId)) {
                        if(ap.OwnerId != accountIdToUserIdMap.get(childAccId)){
                            sharingLedgerList.add(
                                createStaticLedgerRecord(
                                    OBJECT_APPLICATIONCONTENT, ap.Id, accountIdToUserIdMap.get(childAccId)
                                )
                            );
                        }
                    }
                } 
            }
            
        }

        if(!sharingLedgerList.isEmpty()){
            LPI_WithoutSharingUtility.insertSObjectList(sharingLedgerList);
            sharingLedgerList = new List<Sharing_Ledger__c>();
        }
        
       
        for (Application_Document__c ad : [
            SELECT Id, Preliminary_Application_Reference__r.BusinessAccountNameId, Business_License_Application__r.AccountId,
            OwnerId
            FROM Application_Document__c
            WHERE Preliminary_Application_Reference__r.BusinessAccountNameId IN :giveAccRelatedObjAccessToConSetMap.keySet()
            OR Business_License_Application__r.AccountId IN :giveAccRelatedObjAccessToConSetMap.keySet()
            LIMIT 50000
        ]) {
            Id accId = null;
            if (ad.Preliminary_Application_Reference__r.BusinessAccountNameId != null){
                accId = ad.Preliminary_Application_Reference__r.BusinessAccountNameId;
            }
            else {
                accId = ad.Business_License_Application__r.AccountId;
            }
            if(giveAccRelatedObjAccessToConSetMap.containsKey(accId)){
                for (Id childAccId : giveAccRelatedObjAccessToConSetMap.get(accId)) {
                    if (accountIdToUserIdMap.containsKey(childAccId)) {
                        if(ad.OwnerId != accountIdToUserIdMap.get(childAccId)){
                            sharingLedgerList.add(
                                createStaticLedgerRecord(
                                    OBJECT_APPLICATIONDOCUMENT, ad.Id, accountIdToUserIdMap.get(childAccId)
                                )
                            );
                        }
                    }
                }
            }
        }
        
        if(!sharingLedgerList.isEmpty()){
            LPI_WithoutSharingUtility.insertSObjectList(sharingLedgerList);
            sharingLedgerList = new List<Sharing_Ledger__c>();
        }
        
               
        for(AssociatedLocation assLoc : [
            SELECT Id, LocationId, ParentRecordId, Location.OwnerId
            FROM AssociatedLocation
            WHERE ParentRecordId IN: giveAccRelatedObjAccessToConSetMap.keySet()
            LIMIT 50000
        ]){
            for (Id childAccId : giveAccRelatedObjAccessToConSetMap.get(assLoc.ParentRecordId)) {
                if (accountIdToUserIdMap.containsKey(childAccId)) {
                    if(assLoc.Location.OwnerId != accountIdToUserIdMap.get(childAccId)){
                        sharingLedgerList.add(
                            createStaticLedgerRecord(
                                OBJECT_LOCATION, assLoc.LocationId, accountIdToUserIdMap.get(childAccId)
                            )
                        );
                    }
                }
            }
        }

        
        if(!sharingLedgerList.isEmpty()){
            LPI_WithoutSharingUtility.insertSObjectList(sharingLedgerList);
            sharingLedgerList = new List<Sharing_Ledger__c>();
        }

        for (AuthApplicationPlace auth : [
            SELECT Id, RgltyAuthApplicationId, OwnerId
            FROM AuthApplicationPlace
            WHERE RgltyAuthApplicationId IN : blaToAccountMap.keySet()
            LIMIT 50000
        ]) {
            if (blaToAccountMap.containsKey(auth.RgltyAuthApplicationId)) {
                for (Id childAccId : giveAccRelatedObjAccessToConSetMap.get(blaToAccountMap.get(auth.RgltyAuthApplicationId))) {
                    if (accountIdToUserIdMap.containsKey(childAccId)) {
                        if(auth.OwnerId != accountIdToUserIdMap.get(childAccId)){
                            sharingLedgerList.add(
                                createStaticLedgerRecord(
                                    'AuthApplicationPlace', auth.Id, accountIdToUserIdMap.get(childAccId)
                                )
                            );
                        }
                    }
                }
            }
        }

        if(!sharingLedgerList.isEmpty()){
            LPI_WithoutSharingUtility.insertSObjectList(sharingLedgerList);
            sharingLedgerList = new List<Sharing_Ledger__c>();
        }
        
        for (RegulatoryTrxnFee fee : [
            SELECT Id, AccountId, OwnerId
            FROM RegulatoryTrxnFee
            WHERE AccountId IN :giveAccRelatedObjAccessToConSetMap.keySet()
            LIMIT 50000
        ]) {
            for (Id childAccId : giveAccRelatedObjAccessToConSetMap.get(fee.AccountId)) {
                if (accountIdToUserIdMap.containsKey(childAccId)) {
                    if(fee.OwnerId != accountIdToUserIdMap.get(childAccId)){
                        sharingLedgerList.add(
                            createStaticLedgerRecord(
                                OBJECT_REGULATORYTRXNFEE, fee.Id, accountIdToUserIdMap.get(childAccId)
                            )
                        );
                    }
                }
            }
        }

        
        if(!sharingLedgerList.isEmpty()){
            LPI_WithoutSharingUtility.insertSObjectList(sharingLedgerList);
            sharingLedgerList = new List<Sharing_Ledger__c>();
        }

        for (Temp_Fee__c tempFee : [
            SELECT Id, PreliminaryApplicationReference__r.BusinessAccountNameId, OwnerId
            FROM Temp_Fee__c
            WHERE PreliminaryApplicationReference__r.BusinessAccountNameId IN :giveAccRelatedObjAccessToConSetMap.keySet()
            LIMIT 50000
        ]) {
            for (Id childAccId : giveAccRelatedObjAccessToConSetMap.get(tempFee.PreliminaryApplicationReference__r.BusinessAccountNameId)){
                if (accountIdToUserIdMap.containsKey(childAccId)) {
                    if(tempFee.OwnerId != accountIdToUserIdMap.get(childAccId)){
                        sharingLedgerList.add(
                            createStaticLedgerRecord(
                                OBJECT_TEMPFEE, tempFee.Id, accountIdToUserIdMap.get(childAccId)
                            )
                        );
                    }
                }
            }
        }

        if(!sharingLedgerList.isEmpty()){
            LPI_WithoutSharingUtility.insertSObjectList(sharingLedgerList);
            sharingLedgerList = new List<Sharing_Ledger__c>();
        }

        for (Temp_AuthApplicationPlace__c tempAuth : [
            SELECT Id, Preliminary_Application_Reference__r.BusinessAccountNameId, OwnerId
            FROM Temp_AuthApplicationPlace__c
            WHERE
            Preliminary_Application_Reference__r.BusinessAccountNameId IN :giveAccRelatedObjAccessToConSetMap.keySet()
            LIMIT 50000
        ]) {
            for (Id childAccId : giveAccRelatedObjAccessToConSetMap.get(tempAuth.Preliminary_Application_Reference__r.BusinessAccountNameId)){
                if (accountIdToUserIdMap.containsKey(childAccId)) {
                    if(tempAuth.OwnerId != accountIdToUserIdMap.get(childAccId)){
                        sharingLedgerList.add(
                            createStaticLedgerRecord(
                                OBJECT_TEMPAUTHAPPLICATIONPLACE, tempAuth.Id, accountIdToUserIdMap.get(childAccId)
                            )
                        );
                    }
                }
            }
        }
        
        if(!sharingLedgerList.isEmpty()){
            LPI_WithoutSharingUtility.insertSObjectList(sharingLedgerList);
            sharingLedgerList = new List<Sharing_Ledger__c>();
        }

        for (Bank_Account__c bank : [
            SELECT Id, Account__c, OwnerId
            FROM Bank_Account__c
            WHERE Account__c IN :giveAccRelatedObjAccessToConSetMap.keySet()
            LIMIT 50000
        ]) {
            for (Id childAccId : giveAccRelatedObjAccessToConSetMap.get(bank.Account__c)) {
                if (accountIdToUserIdMap.containsKey(childAccId)) {
                    if(bank.OwnerId != accountIdToUserIdMap.get(childAccId)){
                        sharingLedgerList.add(
                            createStaticLedgerRecord(
                                OBJECT_BANKACCOUNT, bank.Id, accountIdToUserIdMap.get(childAccId)
                            )
                        );
                    }
                }
            }
        }


        if(!sharingLedgerList.isEmpty()){
            LPI_WithoutSharingUtility.insertSObjectList(sharingLedgerList);
            sharingLedgerList = new List<Sharing_Ledger__c>();
        }

        for (Business_Relationships__c busRel : [
            SELECT Id, Related_To__c, OwnerId, Related_From__c
            FROM Business_Relationships__c
            WHERE Related_To__c IN :giveAccRelatedObjAccessToConSetMap.keySet()
            OR Related_From__c IN: giveAccRelatedObjAccessToConSetMap.keySet()
            LIMIT 50000
        ]) {
            if(giveAccRelatedObjAccessToConSetMap.containsKey(busRel.Related_To__c)){
                for (Id childAccId : giveAccRelatedObjAccessToConSetMap.get(busRel.Related_To__c)) {
                    if (accountIdToUserIdMap.containsKey(childAccId)) {
                        if(busRel.OwnerId != accountIdToUserIdMap.get(childAccId)){
                            sharingLedgerList.add(
                                createStaticLedgerRecord(
                                    OBJECT_BUSINESSRELATIONSHIPS, busRel.Id, accountIdToUserIdMap.get(childAccId)
                                )
                            );
                        }                    
                    }
                }   
            }else if(giveAccRelatedObjAccessToConSetMap.containsKey(busRel.Related_From__c)){
                for (Id childAccId : giveAccRelatedObjAccessToConSetMap.get(busRel.Related_From__c)) {
                    if (accountIdToUserIdMap.containsKey(childAccId)) {
                        if(busRel.OwnerId != accountIdToUserIdMap.get(childAccId)){
                            sharingLedgerList.add(
                                createStaticLedgerRecord(
                                    OBJECT_BUSINESSRELATIONSHIPS, busRel.Id, accountIdToUserIdMap.get(childAccId)
                                )
                            );
                        }                    
                    }
                } 
            }
            
        }

        if(!sharingLedgerList.isEmpty()){
            LPI_WithoutSharingUtility.insertSObjectList(sharingLedgerList);
            sharingLedgerList = new List<Sharing_Ledger__c>();
        }

        for (Alias__c al : [
            SELECT Id, Account__c, OwnerId
            FROM Alias__c
            WHERE Account__c IN :giveAccRelatedObjAccessToConSetMap.keySet()
            LIMIT 50000
        ]) {
            for (Id childAccId : giveAccRelatedObjAccessToConSetMap.get(al.Account__c)) {
                if (accountIdToUserIdMap.containsKey(childAccId)) {
                    if(al.OwnerId != accountIdToUserIdMap.get(childAccId)){
                        sharingLedgerList.add(
                            createStaticLedgerRecord(
                                OBJECT_ALIAS, al.Id, accountIdToUserIdMap.get(childAccId)
                            )
                        );
                    }
                }
            }
        }


        if(!sharingLedgerList.isEmpty()){
            LPI_WithoutSharingUtility.insertSObjectList(sharingLedgerList);
            sharingLedgerList = new List<Sharing_Ledger__c>();
        }

        for (TrnCourse tc : [
            SELECT Id, Account__c, OwnerId
            FROM TrnCourse
            WHERE Account__c IN: giveAccRelatedObjAccessToConSetMap.keySet()
            LIMIT 50000
        ]) {
            for (Id childAccId : giveAccRelatedObjAccessToConSetMap.get(tc.Account__c)) {
                if (accountIdToUserIdMap.containsKey(childAccId)) {
                    if(tc.OwnerId != accountIdToUserIdMap.get(childAccId)){
                        sharingLedgerList.add(
                            createStaticLedgerRecord(
                                OBJECT_TRAININGCOURSE, tc.Id, accountIdToUserIdMap.get(childAccId)
                            )
                        );
                    }
                }
            }
        }
   

        if(!sharingLedgerList.isEmpty()){
            LPI_WithoutSharingUtility.insertSObjectList(sharingLedgerList);
            sharingLedgerList = new List<Sharing_Ledger__c>();
        }    

       
    }
    
    /**
    *   @author                             : MTX Group Product Team
    *   @since                              : 11-Jan-2023
    *   @description                        : This method will remove access of application related objects
    * 										  from account and there related contact map.
    * 										  This is getting called from ACRTriggerHelper.
    */
    public static void removeAccessOfObjectsFromAccountIdFromBR(
        Map<Id, Set<Id>> removeAccRelatedObjAccessToConSetMap,Set<Id> removeAccessToContactId
    ){
        
        Map<Id, Id> accountIdToUserIdMap = new Map<Id, Id>();
        
        
        for (User us : getUserRecordsByContactIds(removeAccessToContactId)){
            accountIdToUserIdMap.put(us.ContactId, us.Id);
        }
        
       
        Map<Id, Set<Id>> accountToUserToRemoveAccessMap = new Map<Id, Set<Id>>();
        
        for (Account acc : [
            SELECT Id
            FROM Account
            WHERE Id IN :removeAccRelatedObjAccessToConSetMap.keySet()
            LIMIT 50000
        ]) {
            if (!accountToUserToRemoveAccessMap.containsKey(acc.Id)) {
                accountToUserToRemoveAccessMap.put(acc.Id, new Set<Id>());
            }
            for (Id childAccId : removeAccRelatedObjAccessToConSetMap.get(acc.Id)) {
                if (accountIdToUserIdMap.containsKey(childAccId)) {
                    accountToUserToRemoveAccessMap.get(acc.Id).add(accountIdToUserIdMap.get(childAccId));
                }
            }
        }

        
        Map<Id, Set<Id>> brToUserToRemoveAccessMap = new Map<Id, Set<Id>>();
        
        
        for (Business_Relationships__c br : [
            SELECT Id, Related_From__c, Related_To__c
            FROM Business_Relationships__c
            WHERE Related_From__c IN: removeAccRelatedObjAccessToConSetMap.keySet()
            OR Related_To__c IN: removeAccRelatedObjAccessToConSetMap.keySet()
            LIMIT 50000
        ]){
            if (!brToUserToRemoveAccessMap.containsKey(br.Related_From__c)) {
                brToUserToRemoveAccessMap.put(br.Related_From__c, new Set<Id>());
            }
            if(removeAccRelatedObjAccessToConSetMap.containsKey(br.Related_From__c)){
                for (Id childAccId : removeAccRelatedObjAccessToConSetMap.get(br.Related_From__c)) {
                    if (accountIdToUserIdMap.containsKey(childAccId)) {
                        brToUserToRemoveAccessMap.get(br.Related_From__c).add(accountIdToUserIdMap.get(childAccId));
                    }
                }
            }

            if (!brToUserToRemoveAccessMap.containsKey(br.Related_To__c)) {
                brToUserToRemoveAccessMap.put(br.Related_To__c, new Set<Id>());
            }
            if(removeAccRelatedObjAccessToConSetMap.containsKey(br.Related_To__c)){
                for (Id childAccId : removeAccRelatedObjAccessToConSetMap.get(br.Related_To__c)) {
                    if (accountIdToUserIdMap.containsKey(childAccId)) {
                        brToUserToRemoveAccessMap.get(br.Related_To__c).add(accountIdToUserIdMap.get(childAccId));
                    }
                }
            }

        }
        
       
        Map<Id, Set<Id>> parToUserToRemoveAccessMap = new Map<Id, Set<Id>>();
        for (PreliminaryApplicationRef par : [
            SELECT Id, BusinessAccountNameId
            FROM PreliminaryApplicationRef
            WHERE BusinessAccountNameId IN :removeAccRelatedObjAccessToConSetMap.keySet()
            LIMIT 50000
        ]){
            if(!parToUserToRemoveAccessMap.containsKey(par.Id)) {
                parToUserToRemoveAccessMap.put(par.Id, new Set<Id>());
            }
            for (Id childAccId : removeAccRelatedObjAccessToConSetMap.get(par.BusinessAccountNameId)) {
                if (accountIdToUserIdMap.containsKey(childAccId)) {
                    parToUserToRemoveAccessMap.get(par.Id).add(accountIdToUserIdMap.get(childAccId));
                }
            }
        }
        
       
        Map<Id, Set<Id>> blaToUserToRemoveAccessMap = new Map<Id, Set<Id>>();
        Map<Id, Id> blaToAccountMap = new Map<Id, Id>();
        for (BusinessLicenseApplication bla : [
            SELECT Id, AccountId
            FROM BusinessLicenseApplication
            WHERE AccountId IN :removeAccRelatedObjAccessToConSetMap.keySet()
            LIMIT 50000
        ]) {
            blaToAccountMap.put(bla.Id, bla.AccountId);
            if (!blaToUserToRemoveAccessMap.containsKey(bla.Id)) {
                blaToUserToRemoveAccessMap.put(bla.Id, new Set<Id>());
            }
            for (Id childAccId : removeAccRelatedObjAccessToConSetMap.get(bla.AccountId)) {
                if (accountIdToUserIdMap.containsKey(childAccId)) {
                    blaToUserToRemoveAccessMap.get(bla.Id).add(accountIdToUserIdMap.get(childAccId));
                }
            }
        }
        
       
        Map<Id, Set<Id>> appContentToUserToRemoveAccessMap = new Map<Id, Set<Id>>();
        for (Application_Content__c ap : [
            SELECT Id, Preliminary_Application_Reference__r.BusinessAccountNameId, Business_License_Application__r.AccountId
            FROM Application_Content__c
            WHERE Preliminary_Application_Reference__r.BusinessAccountNameId IN :removeAccRelatedObjAccessToConSetMap.keySet()
            OR Business_License_Application__r.AccountId IN :removeAccRelatedObjAccessToConSetMap.keySet()
            LIMIT 50000
        ]) {
            if (!appContentToUserToRemoveAccessMap.containsKey(ap.Id)) {
                appContentToUserToRemoveAccessMap.put(ap.Id, new Set<Id>());
            }
            Id accId = null;
            if(ap.Preliminary_Application_Reference__r.BusinessAccountNameId != null){
                accId = ap.Preliminary_Application_Reference__r.BusinessAccountNameId;
            }
            else{
                accId = ap.Business_License_Application__r.AccountId;
            }
            if(removeAccRelatedObjAccessToConSetMap.containsKey(accId)){
                for (Id childAccId : removeAccRelatedObjAccessToConSetMap.get(accId)) {
                    if (accountIdToUserIdMap.containsKey(childAccId)) {
                        appContentToUserToRemoveAccessMap.get(ap.Id)
                            .add(accountIdToUserIdMap.get(childAccId));
                    }
                }
            }
        }
        
        
        Map<Id, Set<Id>> appDocumentToUserToRemoveAccessMap = new Map<Id, Set<Id>>();
        for (Application_Document__c ad : [
            SELECT Id, Preliminary_Application_Reference__r.BusinessAccountNameId, Business_License_Application__r.AccountId
            FROM Application_Document__c
            WHERE Preliminary_Application_Reference__r.BusinessAccountNameId IN :removeAccRelatedObjAccessToConSetMap.keySet()
            OR Business_License_Application__r.AccountId IN :removeAccRelatedObjAccessToConSetMap.keySet()
            LIMIT 50000
        ]) {
            if (!appDocumentToUserToRemoveAccessMap.containsKey(ad.Id)) {
                appDocumentToUserToRemoveAccessMap.put(ad.Id, new Set<Id>());
            }
            Id accId = null;
            if (ad.Preliminary_Application_Reference__r.BusinessAccountNameId != null){
                accId = ad.Preliminary_Application_Reference__r.BusinessAccountNameId;
            } 
            else{
                accId = ad.Business_License_Application__r.AccountId;
            }
            if(removeAccRelatedObjAccessToConSetMap.containsKey(accId)){                
                for (Id childAccId : removeAccRelatedObjAccessToConSetMap.get(accId)) {
                    if (accountIdToUserIdMap.containsKey(childAccId)) {
                        appDocumentToUserToRemoveAccessMap.get(ad.Id).add(accountIdToUserIdMap.get(childAccId));
                    }
                }
            }
        }
        
        
        Map<Id, Set<Id>> locationToUserToRemoveAccessMap = new Map<Id, Set<Id>>();
        for(AssociatedLocation assLoc : [
            SELECT Id, LocationId, ParentRecordId
            FROM AssociatedLocation
            WHERE ParentRecordId IN: removeAccRelatedObjAccessToConSetMap.keySet()
            LIMIT 50000
        ]){
            if (!locationToUserToRemoveAccessMap.containsKey(assLoc.LocationId)) {
                locationToUserToRemoveAccessMap.put(assLoc.LocationId, new Set<Id>());
            }
            for (Id childAccId : removeAccRelatedObjAccessToConSetMap.get(assLoc.ParentRecordId)) {
                if (accountIdToUserIdMap.containsKey(childAccId)) {
                    locationToUserToRemoveAccessMap.get(assLoc.LocationId).add(accountIdToUserIdMap.get(childAccId));
                }
            }
        }
        
        
        Map<Id, Set<Id>> authAppPlaceToRemoveAccessMap = new Map<Id, Set<Id>>();
        for (AuthApplicationPlace auth : [
            SELECT Id, RgltyAuthApplicationId
            FROM AuthApplicationPlace
            WHERE RgltyAuthApplicationId IN :blaToUserToRemoveAccessMap.keySet()
            LIMIT 50000
        ]) {
            if (!authAppPlaceToRemoveAccessMap.containsKey(auth.Id)) {
                authAppPlaceToRemoveAccessMap.put(auth.Id, new Set<Id>());
            }
            if (blaToAccountMap.containsKey(auth.RgltyAuthApplicationId)) {
                for (
                    Id childAccId : removeAccRelatedObjAccessToConSetMap.get(
                        blaToAccountMap.get(auth.RgltyAuthApplicationId)
                    )
                ) {
                    if (accountIdToUserIdMap.containsKey(childAccId)) {
                        authAppPlaceToRemoveAccessMap.get(auth.Id).add(accountIdToUserIdMap.get(childAccId));
                    }
                }
            }
        }
        
       
        Map<Id, Set<Id>> trxFeeToRemoveAccessMap = new Map<Id, Set<Id>>();
        
        for (RegulatoryTrxnFee fee : [
            SELECT Id, AccountId
            FROM RegulatoryTrxnFee
            WHERE AccountId IN :removeAccRelatedObjAccessToConSetMap.keySet()
            LIMIT 50000
        ]) {
            if (!trxFeeToRemoveAccessMap.containsKey(fee.Id)) {
                trxFeeToRemoveAccessMap.put(fee.Id, new Set<Id>());
            }
            for (Id childAccId : removeAccRelatedObjAccessToConSetMap.get(fee.AccountId)) {
                if (accountIdToUserIdMap.containsKey(childAccId)) {
                    trxFeeToRemoveAccessMap.get(fee.Id)
                        .add(accountIdToUserIdMap.get(childAccId));
                }
            }
        }
        
        
        Map<Id, Set<Id>> tempFeeToRemoveAccessMap = new Map<Id, Set<Id>>();
        for (Temp_Fee__c tempFee : [
            SELECT Id, PreliminaryApplicationReference__r.BusinessAccountNameId
            FROM Temp_Fee__c
            WHERE PreliminaryApplicationReference__r.BusinessAccountNameId IN :removeAccRelatedObjAccessToConSetMap.keySet()
            LIMIT 50000
        ]) {
            if (!tempFeeToRemoveAccessMap.containsKey(tempFee.Id)) {
                tempFeeToRemoveAccessMap.put(tempFee.Id, new Set<Id>());
            }
            for (
                Id childAccId : removeAccRelatedObjAccessToConSetMap.get(
                    tempFee.PreliminaryApplicationReference__r.BusinessAccountNameId
                )
            ) {
                if (accountIdToUserIdMap.containsKey(childAccId)) {
                    tempFeeToRemoveAccessMap.get(tempFee.Id)
                        .add(accountIdToUserIdMap.get(childAccId));
                }
            }
        }
        
        
        Map<Id, Set<Id>> tempAuthAppPlaceToRemoveAccessMap = new Map<Id, Set<Id>>();
        for (Temp_AuthApplicationPlace__c tempAuth : [
            SELECT Id, Preliminary_Application_Reference__r.BusinessAccountNameId
            FROM Temp_AuthApplicationPlace__c
            WHERE Preliminary_Application_Reference__r.BusinessAccountNameId IN :removeAccRelatedObjAccessToConSetMap.keySet()
            LIMIT 50000
        ]) {
            if (!tempAuthAppPlaceToRemoveAccessMap.containsKey(tempAuth.Id)) {
                tempAuthAppPlaceToRemoveAccessMap.put(tempAuth.Id, new Set<Id>());
            }
            for (Id childAccId : removeAccRelatedObjAccessToConSetMap.get(tempAuth.Preliminary_Application_Reference__r.BusinessAccountNameId)){
                if (accountIdToUserIdMap.containsKey(childAccId)) {
                    tempAuthAppPlaceToRemoveAccessMap.get(tempAuth.Id).add(accountIdToUserIdMap.get(childAccId));
                }
            }
        }
        
       
        Map<Id, Set<Id>> bankAccountToUserToRemoveAccessMap = new Map<Id, Set<Id>>();
        for (Bank_Account__c bank : [
            SELECT Id, Account__c
            FROM Bank_Account__c
            WHERE Account__c IN :removeAccRelatedObjAccessToConSetMap.keySet()
            LIMIT 50000
        ]) {
            if (!bankAccountToUserToRemoveAccessMap.containsKey(bank.Id)) {
                bankAccountToUserToRemoveAccessMap.put(bank.Id, new Set<Id>());
            }
            for (Id childAccId : removeAccRelatedObjAccessToConSetMap.get(bank.Account__c)) {
                if (accountIdToUserIdMap.containsKey(childAccId)) {
                    bankAccountToUserToRemoveAccessMap.get(bank.Id).add(accountIdToUserIdMap.get(childAccId));
                }
            }
        }
        
       
        Map<Id, Set<Id>> busRelToUserToRemoveAccessMap = new Map<Id, Set<Id>>();
        for (Business_Relationships__c busRel : [
            SELECT Id, Related_To__c, Related_From__c
            FROM Business_Relationships__c
            WHERE Related_To__c IN :removeAccRelatedObjAccessToConSetMap.keySet()
            OR Related_From__c IN: removeAccRelatedObjAccessToConSetMap.keySet()
            LIMIT 50000
        ]) {
            if (!busRelToUserToRemoveAccessMap.containsKey(busRel.Id)) {
                busRelToUserToRemoveAccessMap.put(busRel.Id, new Set<Id>());
            }
            if(removeAccRelatedObjAccessToConSetMap.containsKey(busRel.Related_To__c)){
                for (Id childAccId : removeAccRelatedObjAccessToConSetMap.get(busRel.Related_To__c)) {
                    if (accountIdToUserIdMap.containsKey(childAccId)) {
                        busRelToUserToRemoveAccessMap.get(busRel.Id).add(accountIdToUserIdMap.get(childAccId));
                    }
                }
            }else if(removeAccRelatedObjAccessToConSetMap.containsKey(busRel.Related_From__c)){
                for (Id childAccId : removeAccRelatedObjAccessToConSetMap.get(busRel.Related_From__c)) {
                    if (accountIdToUserIdMap.containsKey(childAccId)) {
                        busRelToUserToRemoveAccessMap.get(busRel.Id).add(accountIdToUserIdMap.get(childAccId));
                    }
                }
            }
            
        }


       
        Map<Id, Set<Id>> aliasToUserToRemoveAccessMap = new Map<Id, Set<Id>>();
        for (Alias__c al : [
            SELECT Id, Account__c
            FROM Alias__c
            WHERE Account__c IN :removeAccRelatedObjAccessToConSetMap.keySet()
            LIMIT 50000
        ]) {
            if (!aliasToUserToRemoveAccessMap.containsKey(al.Id)) {
                aliasToUserToRemoveAccessMap.put(al.Id, new Set<Id>());
            }
            for (Id childAccId : removeAccRelatedObjAccessToConSetMap.get(al.Account__c)) {
                if (accountIdToUserIdMap.containsKey(childAccId)) {
                    aliasToUserToRemoveAccessMap.get(al.Id).add(accountIdToUserIdMap.get(childAccId));
                }
            }
        }

         
         Map<Id, Set<Id>> tcToUserToRemoveAccessMap = new Map<Id, Set<Id>>();
         for (TrnCourse tc : [
             SELECT Id, Account__c
             FROM TrnCourse
             WHERE Account__c IN: removeAccRelatedObjAccessToConSetMap.keySet()
             LIMIT 50000
         ]) {
             if (!tcToUserToRemoveAccessMap.containsKey(tc.Id)) {
                tcToUserToRemoveAccessMap.put(tc.Id, new Set<Id>());
             }
             for (Id childAccId : removeAccRelatedObjAccessToConSetMap.get(tc.Account__c)) {
                 if (accountIdToUserIdMap.containsKey(childAccId)) {
                    tcToUserToRemoveAccessMap.get(tc.Id).add(accountIdToUserIdMap.get(childAccId));
                 }
             }
         }
        
        
        if(!accountToUserToRemoveAccessMap.isEmpty()){
            LPI_ApexSharingUtility.deleteSharingForSObject(accountToUserToRemoveAccessMap);
        }

       
        if (!parToUserToRemoveAccessMap.isEmpty()) {
            LPI_ApexSharingUtility.deleteSharingForSObject(parToUserToRemoveAccessMap);
        }

        
        if (!blaToUserToRemoveAccessMap.isEmpty()) {
            LPI_ApexSharingUtility.deleteSharingForSObject(blaToUserToRemoveAccessMap);
        }

        
        if (!appContentToUserToRemoveAccessMap.isEmpty()) {
            LPI_ApexSharingUtility.deleteSharingForSObject(appContentToUserToRemoveAccessMap);
        }

       
        if (!appDocumentToUserToRemoveAccessMap.isEmpty()) {
            LPI_ApexSharingUtility.deleteSharingForSObject(appDocumentToUserToRemoveAccessMap);
        }

       
        if (!locationToUserToRemoveAccessMap.isEmpty()) {
            LPI_ApexSharingUtility.deleteSharingForSObject(locationToUserToRemoveAccessMap);
        }

       
        if (!trxFeeToRemoveAccessMap.isEmpty()) {
            LPI_ApexSharingUtility.deleteSharingForSObject(trxFeeToRemoveAccessMap);
        }

       
        if (!tempFeeToRemoveAccessMap.isEmpty()) {
            LPI_ApexSharingUtility.deleteSharingForSObject(tempFeeToRemoveAccessMap);
        }

       
        if (!tempAuthAppPlaceToRemoveAccessMap.isEmpty()) {
            LPI_ApexSharingUtility.deleteSharingForSObject(tempAuthAppPlaceToRemoveAccessMap);
        }

       
        if (!bankAccountToUserToRemoveAccessMap.isEmpty()) {
            LPI_ApexSharingUtility.deleteSharingForSObject(bankAccountToUserToRemoveAccessMap);
        }

       
        if (!busRelToUserToRemoveAccessMap.isEmpty()) {
            LPI_ApexSharingUtility.deleteSharingForSObject(busRelToUserToRemoveAccessMap);
        }

       
        if (!aliasToUserToRemoveAccessMap.isEmpty()) {
            LPI_ApexSharingUtility.deleteSharingForSObject(aliasToUserToRemoveAccessMap);
        }

       
        if (!tcToUserToRemoveAccessMap.isEmpty()) {
            LPI_ApexSharingUtility.deleteSharingForSObject(tcToUserToRemoveAccessMap);
        }

        
        if (!brToUserToRemoveAccessMap.isEmpty()) {
            LPI_ApexSharingUtility.deleteSharingForSObject(brToUserToRemoveAccessMap);
        }
    }

    /**
    *   @author                             : MTX Group Product Team
    *   @since                              : 11-Jan-2023
    *   @description                        : Give Access To Child Accounts of Parent BRs Records
	*/
    @future
    public static void giveAccessBasedOnParentId(Map<Id,Id> accountIdToParentIdMap){
        try{
            Map<Id,Set<Id>> giveAccRelatedObjAccessToChildAccSetMap = new Map<Id,Set<Id>>();
            Set<Id> giveAccessToChildAccountId = new Set<Id>();
    
            Map<Id, Set<Id>> parentIdToItsBRMap = new Map<Id, Set<Id>>();
            for(Business_Relationships__c br : [
                SELECT Id, Related_From__c, Related_To__c
                FROM Business_Relationships__c
                WHERE Related_From__c IN: accountIdToParentIdMap.values()
                AND Roles__c IN: LPI_ApexSharingForPortalBatch.rolesSet
                AND Start_Date__c != NULL
                AND EndDate__c = NULL
                AND Related_To__c != NULL
                AND Related_From__r.RecordType.DeveloperName =: ACCOUNT_RECORDTYPE_BUSINESS
                AND Skip_Sharing__c = false
                LIMIT 50000
            ]){
                if(!parentIdToItsBRMap.containsKey(br.Related_From__c)){
                    parentIdToItsBRMap.put(br.Related_From__c, new Set<Id>());
                }
                parentIdToItsBRMap.get(br.Related_From__c).add(br.Related_To__c);
            }
    
            for(Id childAccountId : accountIdToParentIdMap.keySet() ){
                if(parentIdToItsBRMap.containsKey(accountIdToParentIdMap.get(childAccountId))){
                    for(Id relatedToOfParent :  parentIdToItsBRMap.get(accountIdToParentIdMap.get(childAccountId))){
                        if(!giveAccRelatedObjAccessToChildAccSetMap.containsKey(childAccountId)){
                            giveAccRelatedObjAccessToChildAccSetMap.put(childAccountId, new Set<Id>());
                        }
                        giveAccRelatedObjAccessToChildAccSetMap.get(childAccountId).add(relatedToOfParent);
                        giveAccessToChildAccountId.add(relatedToOfParent);
                    }
                }
            }
            
            if(!giveAccRelatedObjAccessToChildAccSetMap.isEmpty() && !giveAccessToChildAccountId.isEmpty()){
                LPI_ApexSharingUtility.giveAccessOfObjectsFromAccountIdFromBR(giveAccRelatedObjAccessToChildAccSetMap,giveAccessToChildAccountId);
                
            }
        }catch(Exception e){
            LPI_ExceptionManager.logException('LPI_ApexSharingUtility','getAccountDetails',e);
            throw new LPI_Exception(e.getMessage());
        }
    }

    /**
    *   @author                             : MTX Group Product Team
    *   @since                              : 11-Jan-2023
    *   @description                        : Remove Access To Child Accounts of Parent
	*/
    @future
    public static void removeAccessBasedOnParentId(Map<Id,Id> accountIdToOldParentIdMap){
        try{

            Map<Id,Set<Id>> removeAccRelatedObjAccessToChildAccSetMap = new Map<Id,Set<Id>>();
            Set<Id> removeAccessToChildAccountId = new Set<Id>();

            Map<Id, Set<Id>> parentIdToItsBRMap = new Map<Id, Set<Id>>();
            for(Business_Relationships__c br : [
                SELECT Id, Related_From__c, Related_To__c
                FROM Business_Relationships__c
                WHERE Related_From__c IN: accountIdToOldParentIdMap.values()
                AND Roles__c IN: LPI_ApexSharingForPortalBatch.rolesSet
                AND Related_From__r.RecordType.DeveloperName =: ACCOUNT_RECORDTYPE_BUSINESS
                AND Skip_Sharing__c = false
                LIMIT 50000
            ]){
                if(!parentIdToItsBRMap.containsKey(br.Related_From__c)){
                    parentIdToItsBRMap.put(br.Related_From__c, new Set<Id>());
                }
                parentIdToItsBRMap.get(br.Related_From__c).add(br.Related_To__c);
            }

            for(Id childAccountId : accountIdToOldParentIdMap.keySet() ){
                if(parentIdToItsBRMap.containsKey(accountIdToOldParentIdMap.get(childAccountId))){
                    for(Id relatedToOfParent :  parentIdToItsBRMap.get(accountIdToOldParentIdMap.get(childAccountId))){
                        if(!removeAccRelatedObjAccessToChildAccSetMap.containsKey(childAccountId)){
                            removeAccRelatedObjAccessToChildAccSetMap.put(childAccountId, new Set<Id>());
                        }
                        removeAccRelatedObjAccessToChildAccSetMap.get(childAccountId).add(relatedToOfParent);
                        removeAccessToChildAccountId.add(relatedToOfParent);
                    }
                }
            }
            
            if(!removeAccRelatedObjAccessToChildAccSetMap.isEmpty() && !removeAccessToChildAccountId.isEmpty()){
                LPI_ApexSharingUtility.removeAccessOfObjectsFromAccountIdFromBR(removeAccRelatedObjAccessToChildAccSetMap,removeAccessToChildAccountId);
            }
        }catch(Exception e){
            LPI_ExceptionManager.logException('LPI_ApexSharingUtility','getAccountDetails',e);
            throw new LPI_Exception(e.getMessage());
        }
    }
    
    

    /**
    *   @author                             : MTX Group Product Team
    *   @since                              : 11-Jan-2023
    *   @description                        : This method manage record access based on their relation with account
	*/
    public static void manageRecordAccess(List<sObject> newList, Map<Id, sObject> oldMap){
        String objectApiName = '';
        String relationName = '';
        String parentRelationshipName = '';
        
        Set<Id> recordIdSet = new Set<Id>();
        
        for (sObject record : newList) {
            Id recordId = (Id) record.get('Id');
            if (objectApiName == '') {
                objectApiName = recordId.getSobjectType().getDescribe().getName();
            }
            if(oldMap == NULL){
                recordIdSet.add(recordId);
            }
        }

        if (objectToAccountRelationNameMap.containsKey(objectApiName)) {
            relationName = objectToAccountRelationNameMap.get(objectApiName);
        }

        if (objectToParentAccountRelationNameMap.containsKey(objectApiName)) {
            parentRelationshipName = objectToParentAccountRelationNameMap.get(objectApiName);
        }
        
        if (relationName != '' && objectApiName != '' && !recordIdSet.isEmpty()) {
            queryRecordFromRelationName(objectApiName, relationName, parentRelationshipName, recordIdSet);
        }
    }
    
    
    /**
    *   @author                             : MTX Group Product Team
    *   @since                              : 11-Jan-2023
    *   @description                        : This method query the records and form a map of Record to Account Id
	*/
    public static void queryRecordFromRelationName(String objectApiName, String relationName, String parentRelationshipName, Set<Id> recordIdSet){
        Map<Id, Set<Id>> recordToBusinessAccountSetIdMap = new Map<Id, Set<Id>>();
        String query = '';
        if(relationName == 'Id'){
            query = 'SELECT Id, ' + parentRelationshipName + ' FROM ' + objectApiName + ' WHERE Id IN: recordIdSet';
        }else{
            query = 'SELECT Id, ' + relationName + ', ' + parentRelationshipName + ' FROM ' + objectApiName + ' WHERE Id IN: recordIdSet';
        }
        for (SObject record : Database.query(query)) {
            Map<String, Object> mapOfRecord = (Map<String, Object>) JSON.deserializeUntyped( JSON.serialize(record));
            if (relationName.contains('.')) {
                List<String> relationNameList = relationName.split('\\.');
                Map<String, Object> tempObj = mapOfRecord;
                for (Integer i = 0; i < relationNameList.size(); i++) {
                    if (relationNameList.size() - 1 == i) {
                        if (tempObj.ContainsKey(relationNameList[i])) {
                            
                            if(!recordToBusinessAccountSetIdMap.containsKey(record.Id)){
                                recordToBusinessAccountSetIdMap.put(record.Id, new set<Id>());
                            }
                            recordToBusinessAccountSetIdMap.get(record.Id).add((Id) tempObj.get(relationNameList[i]));
                        }
                    } else {
                        if (tempObj.containsKey((String) relationNameList[i]) && tempObj.get((String) relationNameList[i]) != null) {
                            tempObj = (Map<String, Object>) tempObj.get(relationNameList[i]);
                        }
                    }
                }
            } else {
                if (mapOfRecord.ContainsKey(relationName) && mapOfRecord.get(relationName) != null) {
                    if(!recordToBusinessAccountSetIdMap.containsKey(record.Id)){
                        recordToBusinessAccountSetIdMap.put(record.Id, new set<Id>());
                    }
                    recordToBusinessAccountSetIdMap.get(record.Id).add((Id) mapOfRecord.get(relationName));
                }
            }

            if (parentRelationshipName.contains('.')) {
                List<String> parentRelationshipNameList = parentRelationshipName.split('\\.');
                Map<String, Object> tempObj = mapOfRecord;
                for (Integer i = 0; i < parentRelationshipNameList.size(); i++) {
                    if (parentRelationshipNameList.size() - 1 == i) {
                        if (tempObj.ContainsKey(parentRelationshipNameList[i])) {
                            if(!recordToBusinessAccountSetIdMap.containsKey(record.Id)){
                                recordToBusinessAccountSetIdMap.put(record.Id, new set<Id>());
                            }
                            recordToBusinessAccountSetIdMap.get(record.Id).add((Id) tempObj.get(parentRelationshipNameList[i]));
                        }
                    } else {
                        if (tempObj.containsKey((String) parentRelationshipNameList[i]) && tempObj.get((String) parentRelationshipNameList[i]) != null) {
                            tempObj = (Map<String, Object>) tempObj.get(parentRelationshipNameList[i]);
                        }
                    }
                }
            } else {
                if (mapOfRecord.ContainsKey(parentRelationshipName) && mapOfRecord.get(parentRelationshipName) != null) {
                    if(!recordToBusinessAccountSetIdMap.containsKey(record.Id)){
                        recordToBusinessAccountSetIdMap.put(record.Id, new set<Id>());
                    }
                    recordToBusinessAccountSetIdMap.get(record.Id).add((Id) mapOfRecord.get(parentRelationshipName));
                }
            }
        }
        if (!recordToBusinessAccountSetIdMap.isEmpty()) {
            giveRecordAccessToAccountFromBusinessRelation(recordToBusinessAccountSetIdMap, objectApiName);
        }
    }

    /**
    *   @author                             : MTX Group Product Team
    *   @since                              : 11-Jan-2023
    *   @description                        : This method create sharing record of a object from
    * 										  given map of record and user to give access

    METHOD OVERRIDED
    */
    public static void giveRecordAccessToAccountFromBusinessRelation(Map<Id,Set<Id>> recordToBusinessAccountSetIdMap, String objectApiName){
        Map<Id, Set<Id>> fromAccountIdToToAccountSetMap = new Map<Id, Set<Id>>();
        Map<Id, Id> accountIdToUserIdMap = new Map<Id, Id>();
        Set<Id> childAccountIdSet = new Set<Id>();
        
        Map<Id,Id> accountToParentIdMap = new Map<Id,Id>();
    
        Set<Id> businessAccountIdSet = new Set<Id>();
        for(Id accountId : recordToBusinessAccountSetIdMap.keySet()){
            businessAccountIdSet.addAll(recordToBusinessAccountSetIdMap.get(accountId));
        }

        for(Account acc : [
            SELECT Id, ParentId
            FROM Account
            WHERE Id IN: businessAccountIdSet
            AND ParentId != NULL
        ]){
            accountToParentIdMap.put(acc.Id, acc.ParentId);
        }
        
        for(Business_Relationships__c acr : [
            SELECT Id, Related_From__c, Related_To__c
            FROM Business_Relationships__c
            WHERE ( 
                Related_From__c IN : businessAccountIdSet   
             OR Related_From__c IN : accountToParentIdMap.values() 
            )
            AND ROLES__c IN: LPI_ApexSharingForPortalBatch.rolesSet
            AND Start_Date__c != NULL
            AND EndDate__c = NULL
            AND Related_To__c != NULL
            AND Related_From__r.RecordType.DeveloperName = :ACCOUNT_RECORDTYPE_BUSINESS
            AND Skip_Sharing__c = false
            LIMIT 50000
        ]) {
            if (!fromAccountIdToToAccountSetMap.containsKey(acr.Related_From__c)) {
                fromAccountIdToToAccountSetMap.put(acr.Related_From__c, new Set<Id>());
            }
            fromAccountIdToToAccountSetMap.get(acr.Related_From__c).add(acr.Related_To__c);
            childAccountIdSet.add(acr.Related_To__c);
        }

        if (!childAccountIdSet.isEmpty()) {
            for(User userRecord : getUserRecordsBySccountIdSet(childAccountIdSet)) {
                accountIdToUserIdMap.put(userRecord.AccountId, userRecord.Id);
            }
            
            List<Sharing_Ledger__c> sharingLedgerList = new List<Sharing_Ledger__c>();
            Sharing_Ledger__c sharingLedger;
            for(Id recordId : recordToBusinessAccountSetIdMap.keySet()){
                for(Id accountRecordId : recordToBusinessAccountSetIdMap.get(recordId)){
                    if (fromAccountIdToToAccountSetMap.containsKey(accountRecordId)) {
                        for (Id contId : fromAccountIdToToAccountSetMap.get(accountRecordId)) {
                            if(accountIdToUserIdMap.containsKey(contId)) {
                                sharingLedgerList.add(
                                    createStaticLedgerRecord(
                                        objectApiName, recordId, accountIdToUserIdMap.get(contId)
                                    )
                                ); 
                            }
                        }
                    }

                    if(accountToParentIdMap.containsKey(accountRecordId)){
                        if (fromAccountIdToToAccountSetMap.containsKey(accountToParentIdMap.get(accountRecordId))) {
                            for (Id contId : fromAccountIdToToAccountSetMap.get(accountToParentIdMap.get(accountRecordId))) {
                                if(accountIdToUserIdMap.containsKey(contId)) {
                                    sharingLedgerList.add(
                                        createStaticLedgerRecord(
                                            objectApiName, recordId, accountIdToUserIdMap.get(contId)
                                        )
                                    ); 
                                }
                            }
                        }
                       
                    }
                }
                
                
            }
            if (!sharingLedgerList.isEmpty()) {
                LPI_WithoutSharingUtility.insertSObjectList(sharingLedgerList);
            }
        }
    }

       
    /**
    *   @author                             : MTX Group Product Team
    *   @since                              : 11-Jan-2023
    *   @description                        : This method create sharing record of a object from
    * 										  given map of record and user to give access
    */
    public static void giveLocationAccountToPersonAccount(Map<Id,Id> accountIdToUserIdMap){
        List<Sharing_Ledger__c> sharingLedgerList = new List<Sharing_Ledger__c>();
       
             
        for(AssociatedLocation assLoc : [
            SELECT Id, LocationId, ParentRecordId, Location.OwnerId
            FROM AssociatedLocation
            WHERE ParentRecordId IN: accountIdToUserIdMap.keySet()
            LIMIT 50000
        ]){
                sharingLedgerList.add(
                    createStaticLedgerRecord(
                        OBJECT_LOCATION, assLoc.LocationId, accountIdToUserIdMap.get(assLoc.ParentRecordId)
                    )
                );
        }

        if(!sharingLedgerList.isEmpty()){
            LPI_WithoutSharingUtility.insertSObjectList(sharingLedgerList);
        }

    }
    
    
    
    /**
    *   @author                             : MTX Group Product Team
    *   @since                              : 11-Jan-2023
    *   @description                        : This method delete the sharing object records from
    *										  given map of record and user to give access
    */
    public static void deleteSharingForSObject(map<Id, set<Id>> mapRecordIdUserIds){
        String filterSharingLedger = '';
        for (Id recordId : mapRecordIdUserIds.keySet()) {
            String outerFilterSharingLedger = ' ' + ' Source_Table_Id__c ' + ' = \'' + recordId + '\'';

            String internalFilterSharingLedger = '';

            for (Id userOrGroupId : mapRecordIdUserIds.get(recordId)) {
                internalFilterSharingLedger = internalFilterSharingLedger != ''
                    ? internalFilterSharingLedger + ' OR User_or_Group_Id__c  = \'' + UserOrGroupId + '\''
                    : ' User_or_Group_Id__c  = \'' + UserOrGroupId + '\'';
            }
            if (internalFilterSharingLedger != '') {
                filterSharingLedger = filterSharingLedger != ''
                    ? filterSharingLedger + ' OR (' + outerFilterSharingLedger + ' AND ( ' + internalFilterSharingLedger + ' )) '
                    : +'(' + outerFilterSharingLedger + ' AND ( ' + internalFilterSharingLedger + ' )) ';
                
            } else {
                outerFilterSharingLedger = '';
            }
        }
        
        if(filterSharingLedger != ''){
            String querySharingLedger = 'SELECT Id FROM ' + ' Sharing_Ledger__c ' + ' WHERE ' + filterSharingLedger;
            list<SObject> lstObjects = Database.query(querySharingLedger);
            if (!lstObjects.isEmpty()) {
                LPI_WithoutSharingUtility.deleteSObject(lstObjects);
            }
        }
    }
    
   /**
    *   @author                             : MTX Group Product Team
    *   @since                              : 11-Jan-2023
    *   @description                        : Create sharing ledger record instance
    */
    public static Sharing_Ledger__c createStaticLedgerRecord(String objectApiName, Id recordId,  Id userOrGroupId){
        Sharing_Ledger__c sharingLedger = new Sharing_Ledger__c();
        sharingLedger.User_or_Group_Id__c = userOrGroupId;
        sharingLedger.Source_Table__c = objectApiName;
        sharingLedger.Source_Table_Id__c  = recordId;
        sharingLedger.Share_Reason__c = SHARING_REASON_MANUAL;
        sharingLedger.Access_Level__c = 2;
        return sharingLedger;
    }
    
   /**
     * This method restricts field updates based on the provided restrictions.
     *
     * @param newList                                The list of sObjects to be updated.
     * @param oldMap                                 Map of sObject Id to corresponding old sObject.
     * @param fieldNotToBeUpdatedToLabelMap           Map of field API names to their labels, specifying fields that should not be updated.
     * @param picklistToStatusToStatusChangeNotAllowedMap
     *                                               Map of picklist field API names to nested maps representing the status transitions
     *                                               that are not allowed to be changed. The nested map has old status as key and
     *                                               set of disallowed new status values as values.
     */
    public static void restrictFieldUpdate(
        List<sObject> newList, Map<Id, sObject> oldMap, Map<String,String> fieldNotToBeUpdatedToLabelMap, 
        Map<String, Map<String, Set<String>>> picklistToStatusToStatusChangeNotAllowedMap
    ){       
        
        User userRecord = [
            SELECT Id, Profile.Name
            FROM User
            WHERE Id =: UserInfo.getUserId()
            LIMIT 50000
        ];

        
        if(
            (
                (picklistToStatusToStatusChangeNotAllowedMap != NULL && !picklistToStatusToStatusChangeNotAllowedMap.isEmpty()) ||
                (fieldNotToBeUpdatedToLabelMap != NULL && !fieldNotToBeUpdatedToLabelMap.isEmpty())
            ) && userRecord.Profile.Name == LPI_LiteralConstant.Portal_Profile_Name
        ){
            for (sObject record : newList) {
                if(oldMap != NULL){
                   
                    if(fieldNotToBeUpdatedToLabelMap != NULL && !fieldNotToBeUpdatedToLabelMap.isEmpty()){
                        for(String apiNameOfField : fieldNotToBeUpdatedToLabelMap.keySet()){
                            if(record.get(apiNameOfField) != oldMap.get((Id)record.get('Id')).get(apiNameOfField)){
                                String errorMessage = '';
                                if(fieldNotToBeUpdatedToLabelMap.values().size() > 1){
                                    errorMessage = string.join( 
                                        fieldNotToBeUpdatedToLabelMap.values(), ', ' 
                                    )  + ' : Fields are not updateable.';
                                }else{
                                    errorMessage = string.join( 
                                        fieldNotToBeUpdatedToLabelMap.values(), ', ' 
                                    )  + ' : Field is not updateable.';
                                }
                                record.addError(errorMessage);
                            }
                        }
                    }

                   
                    if(picklistToStatusToStatusChangeNotAllowedMap != NULL && !picklistToStatusToStatusChangeNotAllowedMap.isEmpty()){
                        for(String apiNameOfField : picklistToStatusToStatusChangeNotAllowedMap.keySet()){
                            if(record.get(apiNameOfField) != oldMap.get((Id)record.get('Id')).get(apiNameOfField)
                               && picklistToStatusToStatusChangeNotAllowedMap.get(apiNameOfField).
                               containsKey((String)oldMap.get((Id)record.get('Id')).get(apiNameOfField))
                              && picklistToStatusToStatusChangeNotAllowedMap.get(apiNameOfField).
                               get((String)oldMap.get((Id)record.get('Id')).get(apiNameOfField)).
                               contains((String)record.get(apiNameOfField) )){
                                   record.addError(
                                       apiNameOfField + ' can\'t be updated after ' + 
                                       oldMap.get((Id)record.get('Id')).get(apiNameOfField) + ' to ' + record.get(apiNameOfField) + '.'
                                   );
                            }
                        } 
                    }
                }
            }            
        }
    } 
}