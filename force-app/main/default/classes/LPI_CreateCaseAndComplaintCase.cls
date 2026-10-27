/**
 * @description       : Controller for creating case from public complaint.
 * @author            : MTX Group Product Team
 * @group             :
 * @last modified on  : 07-11-2024
 * @last modified by  : MTX Group Product Team
 **/

public with sharing class LPI_CreateCaseAndComplaintCase {
    public static final String ONLINE_PORTAL_TEXT = 'Online Portal';
    public static final String NEW_STATUS = 'New';
    private static final String ATTORNEY_ROLE = 'Attorney';
    public static final String CASE_COMPLAINT_RECORD_TYPE_ID = Schema.SObjectType.Case
        ?.getRecordTypeInfosByDeveloperName()
        ?.get('Complaint')
        ?.getRecordTypeId();
    private static String boardName;
    public static void setBoardName(String bName) {
        boardName = bName;
    }


    /**
    * @description This Method will be used to populate case data onto.
    * @author MTX Group Product Team | 10-23-2023 
    * @param publicComplaintId 
    **/
    @AuraEnabled
    public static String populateCaseOnCompanionComplaintRecords(Id recordId) {
        try {
            if(String.isBlank(recordId)) {
                throw new LPI_Exception('NO RECORD ID FOUND');
            }
            String publicComplaintId = recordId; 
            String fields = 'Id,Companion_Case__c,Case__c,Companion_Complaint__c,Public_Complaint__c';
            String whereClause = 'Companion_Complaint__c =\''+publicComplaintId+'\' OR Public_Complaint__c = \'' +publicComplaintId+'\'';
            
            List<Companion_Complaints_Cases__c> companionCompCaseList = new LPI_CompanionComplaintCaseDAO.LPI_CompanionComplaintCaseWithoutSharingDAO()
                                                                .fetchCompanionComplaintWithoutSecurityEnforced(fields,whereClause,null,null,null);
            for(Companion_Complaints_Cases__c  compCaseRec : companionCompCaseList) {
                    if(
                        (publicComplaintId == compCaseRec.Companion_Complaint__c && String.isNotBlank(compCaseRec.Companion_Case__c)) || 
                        (publicComplaintId == compCaseRec.Public_Complaint__c && String.isNotBlank(compCaseRec.Case__c))) {
                            return 'CaseExist';
                    } else if(compCaseRec.Case__c != null && compCaseRec.Companion_Case__c!=null) {
                        return 'CaseExist';
                    }
            }
            fields = 'Id,Name, Status, Complaint_Details__c, OwnerId, Board_Name__c, Board_Name__r.Name, License_Name__c, Is_Companion_Complaint__c,Reported_Date__c,Lawsuit_Case_Number__c,Lawsuit_Jurisdiction__c,License_Number__c,Other_License_State__c,Primary_Category__c, Other_Categories__c,County__c,( SELECT Id,Business_License__r.Name,Business_License__r.AccountId,Business_License__c FROM Business_Complaints__r),(select id,Case__c,Public_Complaint__c from Application_Document__r),' +
                            '(SELECT ID,ParticipantId,Role FROM PublicComplaintParticipants WHERE Status = \'' + LPI_LiteralConstant.STATUS_ACTIVE + '\' ), (SELECT ID,Name FROM ComplaintCaseComplaint)';
            whereClause = 'Id = \'' +publicComplaintId+ '\'';
            
            List<Business_Complaint__c> businessComplaintList = new List<Business_Complaint__c>();
            Set<String> participantIdSet = new Set<String>();
            Map<Id,String> accountIdToLicenseNumberMap = new Map<Id,String>();
            ComplaintParticipant cpToPass;
            List<PublicComplaint> pcList = new LPI_PublicComplaintDao.LPI_PublicComplaintWithoutSharingDAO().getPublicComplaintByDymanicQueryWithoutSecurity(fields,whereClause,null,null,null);
            
            if(pcList.isEmpty() || pcList[0].PublicComplaintParticipants.isEmpty()) {
                return 'NoRecordFound';
            } 
            if(!pcList[0].ComplaintCaseComplaint.isEmpty()) { 
                return 'CaseExist';
            }
            List<ComplaintParticipant> otherCPRecordList = new List<ComplaintParticipant>();
            List<ComplaintParticipant> respondentCPRecordList = new List<ComplaintParticipant>();

            for(ComplaintParticipant cpRec : pcList[0].PublicComplaintParticipants) {
                if(cpRec.Role == LPI_LiteralConstant.RESPONDENT_TEXT) {
                    participantIdSet.add(cpRec.ParticipantId);
                    respondentCPRecordList.add(cpRec);
                }
                otherCPRecordList.add(cpRec);
            }
            if(participantIdSet.isEmpty()) {
                return 'NoRespondent';
            }
            businessComplaintList.addAll(pcList[0].Business_Complaints__r);

            fields = 'Id,Name,PersonContactId';
            whereClause =
                'Id IN ' + LPI_ServiceUtility.getStringValuesByStringSet(participantIdSet);
                
            Map<Id, Account> accountIdToAccountMap =  new Map<Id, Account>(new LPI_AccountDAO.LPI_AccountWithoutSharingDAO().getAccountByDymanicQuery(fields, whereClause, null, null, null));
           
            for(Business_Complaint__c businessCompRec : businessComplaintList) {                
                accountIdToLicenseNumberMap.put(businessCompRec.Business_License__r.AccountId,businessCompRec.Business_License__r.Name+'-'+businessCompRec.Business_License__c);
            }
            Case caseRecToInsert = (Case) LPI_WithoutSharingUtility.insertSObject(createCaseForRespondent(respondentCPRecordList[0],pcList[0],accountIdToAccountMap,accountIdToLicenseNumberMap));
            LPI_WithoutSharingUtility.insertSObject(new ComplaintCase(
                CaseId = caseRecToInsert.Id,
                PublicComplaintId = publicComplaintId
            ));
            List<Application_Document__c> appDocList = new List<Application_Document__c>();
            for(Application_Document__c ad : pcList[0].Application_Document__r){
                if(String.isNotBlank(ad.Public_Complaint__c)){
                    ad.case__c = caseRecToInsert.Id;
                    appDocList.add(ad);
                }
            }
            if(!appDocList.isEmpty()){
                LPI_DML.doUpdate(appDocList);
            }
            List<CaseParticipant> caseParticipantList = new List<CaseParticipant>();
            for(ComplaintParticipant cpRec : otherCPRecordList) {
                String participantId = cpRec.Role == LPI_LiteralConstant.RESPONDENT_TEXT ? caseRecToInsert.AccountId : cpRec.ParticipantId;
                
                CaseParticipant casePartRec = createCaseParticipant(
                    participantId,
                    cpRec.Role,
                    caseRecToInsert.Id
                );
                caseParticipantList.add(
                    casePartRec
                );
            }
            if(!caseParticipantList.isEmpty()) {
                LPI_WithoutSharingUtility.insertSObjectList(caseParticipantList);
            }
            for(Companion_Complaints_Cases__c  compCaseRec : companionCompCaseList) {
                if(publicComplaintId == compCaseRec.Companion_Complaint__c) {
                    compCaseRec.Companion_Case__c = caseRecToInsert.Id;
                } else if(publicComplaintId == compCaseRec.Public_Complaint__c){
                    compCaseRec.Case__c =  caseRecToInsert.Id;
                } 
            }   
            LPI_WithoutSharingUtility.updateSObjectList(companionCompCaseList);
            List<Case> caseRecList = new LPI_CaseDAO.LPI_CaseWithoutSharingDAO().getCaseRecordsWithoutSharing('Id,Case_Number__c','Id = \'' + caseRecToInsert.Id + '\'',null,null);
            return caseRecList[0].Case_Number__c;
        }        
        catch(Exception ex) {
            LPI_ExceptionManager.logException(
                'LPI_CreateCaseAndComplaintCase',
                'populateCaseOnCompanionComplaintRecords',
                ex
            );
            throw new LPI_Exception(ex.getMessage());
        }
    }
    

    /**
     * @description : Method to add create case for a respondent.
     * @author MTX Group Product Team | 05-19-2023
     * @param cp
     * @param pc
     * @param accountIdToContactId
     * @return Case
     **/
    public static Case createCaseForRespondent(
        ComplaintParticipant cp,
        PublicComplaint pc,
        Map<Id, Account> accountIdToAccountMap,
        Map<Id,String> accIdToLicenseNumMap
    ) {
        Case cs = new Case();
        cs.Complaint_Channel__c = ONLINE_PORTAL_TEXT;
        cs.Status = NEW_STATUS;
        cs.AccountId = cp.ParticipantId;
        cs.ContactId = accountIdToAccountMap.get(cp.ParticipantId).PersonContactId;
        cs.Origin = LPI_LiteralConstant.Inspection_Type_COMPLAINT;
        cs.RecordTypeId = CASE_COMPLAINT_RECORD_TYPE_ID;
        cs.Business_License_Id__c = accIdToLicenseNumMap.containsKey(cs.AccountId)? accIdToLicenseNumMap.get(cs.AccountId).split('-')[1] :'';
        cs.License_Number__c = accIdToLicenseNumMap.containsKey(cs.AccountId)? accIdToLicenseNumMap.get(cs.AccountId).split('-')[0] :pc.License_Number__c;
        cs.Subject = accIdToLicenseNumMap != null && accIdToLicenseNumMap.containsKey(cs.AccountId)?
                        accountIdToAccountMap.get(cp.ParticipantId).Name+' '+ cs.License_Number__c  +' '+ cs.Origin:
                        accountIdToAccountMap.get(cp.ParticipantId).Name+' '+ ' UNLICENSED ' +' '+ cs.Origin;
        cs.Stage__c = NEW_STATUS;
        cs.OwnerId = UserInfo.getUserId();
        cs.Is_Companion_Case__c = pc.Is_Companion_Complaint__c;
        cs.Date_Filed__c = pc.Reported_Date__c;
        cs.License_Type__c = pc.License_Name__c;
        cs.Lawsuit_Case_Number__c = pc.Lawsuit_Case_Number__c;
        cs.Lawsuit_Jurisdiction__c = pc.Lawsuit_Jurisdiction__c;
        cs.License_Number__c = pc.License_Number__c;
        cs.Other_State__c = pc.Other_License_State__c;
        cs.Primary_Category__c = pc.Primary_Category__c;
        cs.Other_Category__c = pc.Other_Categories__c;
        cs.County__c = pc.County__c;
       if(String.isNotBlank(pc.Board_Name__c)) {
            cs.Board_Name__c = pc.Board_Name__r.Name;
       }
        return cs;
    }

    /**
     * @description : Method to create case pasrticipants for a case
     * @author MTX Group Product Team | 05-19-2023
     * @param participantId
     * @param role
     * @param caseId
     * @return CaseParticipant
     **/
    public static CaseParticipant createCaseParticipant(
        String participantId,
        String role,
        String caseId
    ) {
        CaseParticipant caseParticipant = new CaseParticipant();
        caseParticipant.ParticipantId = participantId;
        caseParticipant.Role = role;
        caseParticipant.Status = LPI_LiteralConstant.STATUS_ACTIVE;
        caseParticipant.CaseId = caseId;
        return caseParticipant;
    }
    
    /**
    * @description 
    * @author MTX Group Product Team | 05-07-2024 
    * @param accList 
    * @param sectionName 
    * @param caseId 
    * @return Boolean 
    **/
    public static Boolean insertCPRec(List<Account> accList , String sectionName,String caseId) {
        List<CaseParticipant> caseParticipantRecList = new List<CaseParticipant>();
        Set<Id> accIdSet = new Set<Id>();
        for(Account acc : accList) {
            if(accIdSet.contains(acc.Id)) {
                continue;
            }
            caseParticipantRecList.add(createCaseParticipant(acc.Id,sectionName,caseId));
            accIdSet.add(acc.Id);
        }
        if(!caseParticipantRecList.isEmpty()) {
            LPI_DML.doInsert(caseParticipantRecList);
        }
        return true;
    }
}