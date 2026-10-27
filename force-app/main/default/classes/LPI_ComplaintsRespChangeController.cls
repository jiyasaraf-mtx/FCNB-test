/**
 * @description       : 
 * @author            : Vamsi Mudaliar
 * @group             : 
 * @last modified on  : 05-02-2024
 * @last modified by  : MTX Group Inc.
**/
public with sharing class LPI_ComplaintsRespChangeController {
    
    private static final String LICENSED  = 'Licensed';
    private static final String UNLICENSED  = 'UnLicensed';
    private static final String INTERNAL_STAFF_MEMBERS = 'Internal Staff Members';
    private static final String RESPONDENT_TEXT = 'Respondent';
    private static final String NEW_OPTION = 'New';
    private static final String EXISTING_OPTION = 'Existing';
    private static final String BUSINESS = 'Business';
    private static final String INDIVIDUAL = 'Individual';


    /**
    * @author                      : Vamsi Mudaliar
    * @since                       : 4 March 2024
    * @description                 : This Method is Exposed to the Client and Deals with Updating Respondent Details.
    * @return                      : `Map<String,Object>`
    * @last modified by            : MTX Group Inc.
    * @last modified date          : 4 March 2024
    * @modified details            : Code Review Fixes
    */
    @AuraEnabled 
    public static Map<String,Object> updateRespondentDetails(String jsonData) {
        try {  
            ChangeRespondentWrapper wrapper = (ChangeRespondentWrapper) JSON.deserialize(jsonData,ChangeRespondentWrapper.class);  
            
            if( wrapper == null || 
                String.isBlank(wrapper.complaintId) || 
                String.isBlank(wrapper.respondentType) || 
                String.isBlank(wrapper.board) ||
                (String.isBlank(wrapper.businessOrIndividual) && wrapper.respondentType == UNLICENSED) || 
                (wrapper.newOrExisting == NEW_OPTION && wrapper.accountInfo == null)
                ) {
                throw new LPI_Exception('Incorrect Details, Please retry');
            }

            Map<String,Object> resultMap = new Map<String,Object>();

            String fields = 'Id,OwnerId,Board_Names_List__c,Board_Name__c,License_Number__c,License_Name__c,(SELECT Id,CaseId FROM ComplaintCaseComplaint),(SELECT ID,ParticipantId,Role FROM PublicComplaintParticipants WHERE Role=\'Respondent\' AND Status=\'Active\'),' + 
                                '(SELECT ID,Business_License__c FROM Business_Complaints__r)';

            String whereClause = 'Id = \'' + String.escapeSingleQuotes(wrapper.complaintId) + '\'';
            
            // Fetch the Complaint Information along with Case Details. 
            List<PublicComplaint> pcList = LPI_PublicComplaintDao.fetchPublicComplaintRecords(fields,whereClause,'1',null);

            if(pcList.isEmpty() || pcList[0].PublicComplaintParticipants.isEmpty()) {
                throw new LPI_Exception('Error fetching Complaint/Respondent Details');
            }
            
            resultMap.put('complaint',pcList);

            // If the respondent is Unlicensed and Account Type is New 
            // We have to create a new Account and then associate that AccountId in wrapper. and then call 
            // this updateRespDetailsOnAssociatedObjects method.
            if(wrapper.respondentType == UNLICENSED && wrapper.newOrExisting == NEW_OPTION) {
                createNewRespondentService(wrapper,resultMap); // this would populate accountId. 
            }
            updateRespDetailsOnAssociatedObjects(wrapper,resultMap);
            // Fetch Task Details linked with Case. 
            return resultMap;
        }
        catch(Exception ex) {
            LPI_ExceptionManager.logException('LPI_ComplaintsRespChangeController', 'updateRespondentDetails', ex);
            throw new AuraHandledException(ex.getMessage());
        }
    }

    /**
    * @author                      : Vamsi Mudaliar
    * @since                       : 4 March 2024
    * @description                 : This Method is Deals with the Account Field mappings and Account Creation with enforcing duplicate checks.
    * @return                      : `void`
    * @last modified by            : MTX Group Inc.
    * @last modified date          : 4 March 2024
    * @modified details            : Code Review Fixes
    */
    private static void createNewRespondentService(ChangeRespondentWrapper wrapper, Map<String,Object> resultMap) {
        try {   

            Account accToPopulate = new Account();
            String accountIdToPopulate;
            if(wrapper.businessOrIndividual.equals(BUSINESS)) {      
                accToPopulate = LPI_ComplaintParticipantController.createBusinessAccount(accToPopulate, wrapper.accountInfo, UserInfo.getUserId());
                
            } else if(wrapper.businessOrIndividual.equals(INDIVIDUAL)){
                accToPopulate = LPI_ComplaintParticipantController.createPersonAccount(accToPopulate,wrapper.accountInfo,UserInfo.getUserId());
            } else {
                throw new LPI_Exception('Invalid Authorisation Option Selected');
            }
            // After preparing Account Details.
            for(Datacloud.MatchRecord matchRecord : LPI_WithoutSharingUtility.getDuplicateRecords(new List<Account>{accToPopulate})) {
                accountIdToPopulate = (String) matchRecord.getRecord().get('Id');
                break;
            }
            if(String.isNotBlank(accountIdToPopulate)) {
                wrapper.accountId = accountIdToPopulate;
            } else {
                Account acc = (Account) LPI_WithoutSharingUtility.insertSObject(accToPopulate);
                wrapper.accountId = acc.Id;
            }

        }
        catch(Exception ex) {
            LPI_ExceptionManager.logException('LPI_ComplaintsRespChangeController', 'createNewRespondentService', ex);
            throw new AuraHandledException(ex.getMessage());
        }
    }

    /**
    * @author                      : Vamsi Mudaliar
    * @since                       : 4 March 2024
    * @description                 : This Method is Deals with the Updating the Changed Details Across all the Related/Associated Objects related via Public Complaint.
    * @return                      : `void`
    * @last modified by            : MTX Group Inc.
    * @last modified date          : 4 March 2024
    * @modified details            : Code Review Fixes
    */
    private static void updateRespDetailsOnAssociatedObjects(ChangeRespondentWrapper wrapper,Map<String,Object> resultMap) {
        try {  
            
            List<PublicComplaint> pcList = (List<PublicComplaint>)resultMap.get('complaint');
            List<sObject> sObjectList = new List<sObject>(); // used for upserting the sObjects.
            List<sObject> sObjectListToDelete = new List<sObject>(); // used for deleting the sObject records.

            Map<String,String> boardNameToQueueIdMap = LPI_ComplaintsController.getQueueIdByBoardNames(new Set<String>{wrapper.board});
            String fields;
            String whereClause;
            // Populate the Board, Profession of this new License Record Selected
            pcList[0].License_Name__c = wrapper.profession;

            if(String.isNotBlank(wrapper.board)) {
                Map<String,Id> boardNameToboardIdMap = new Map<String,Id>();

                for(RegulatoryAuthority regAuthRec : new LPI_RegulatoryAuthorityDAO.LPI_RegulatoryAuthorityWithoutSharingDAO().getRegulatoryAuthorityByDymanicQueryWithoutSharing('Id,Name','Name  IN ' + LPI_ServiceUtility.getStringValuesByStringSet(new Set<String>{wrapper.board}),null,null,null)) {
                    boardNameToboardIdMap.put(regAuthRec.Name,regAuthRec.Id);
                }

                pcList[0].Board_Name__c = boardNameToboardIdMap.get(wrapper.board);
                pcList[0].Board_Names_List__c = wrapper.board;
                pcList[0].AccountId = wrapper.accountId;
                if(wrapper.respondentType == UNLICENSED && String.isNotBlank(pcList[0].License_Number__c)) {
                    pcList[0].License_Number__c = null;
                } else if(wrapper.respondentType == LICENSED) {
                    pcList[0].License_Number__c = wrapper.licenseNum;
                }
                // Change the Owner to the respective board queue. 
                String selectedBoardSubStr = wrapper.board.length() > 40 ? wrapper.board.substring(0,40).trim() : wrapper.board; // Null check already done above.
                pcList[0].OwnerId = boardNameToQueueIdMap.containsKey(selectedBoardSubStr) ? boardNameToQueueIdMap.get(selectedBoardSubStr) : boardNameToQueueIdMap.get(INTERNAL_STAFF_MEMBERS);
            }    
            
            sObjectList.add(pcList[0]);

            // Each complaint will have many complaint participants. If present get the respondent role, update the details.
            List<ComplaintParticipant> cpList = pcList[0].PublicComplaintParticipants;
            if(String.isNotBlank(wrapper.accountId)) {
                cpList[0].ParticipantId = wrapper.accountId;            
                sObjectList.add(cpList[0]);
            }

            if(wrapper.respondentType == LICENSED) {
                // Fetch Business Complaint Junction Records.
                if(!pcList[0].Business_Complaints__r.isEmpty()) { // Licensed to Licensed
                    List<Business_Complaint__c> businessCompJunRecList = pcList[0].Business_Complaints__r;
                    businessCompJunRecList[0].Business_License__c = wrapper.licenseId;
                    sObjectList.add(businessCompJunRecList[0]);
                } else { // UnLicensed to Licensed.
                    Business_Complaint__c bcompRec = new Business_Complaint__c(
                        Business_License__c = wrapper.licenseId,
                        Public_Complaint__c = wrapper.complaintId
                    );
                    sObjectList.add(bcompRec);
                }
            } else if(!pcList[0].Business_Complaints__r.isEmpty()){ // Licensed to UnLicensed
                // in case of un licensed and business Complaint Record is Present then we need to delete them.
                List<Business_Complaint__c> businessCompJunRecList = pcList[0].Business_Complaints__r;
                sObjectListToDelete.add(businessCompJunRecList[0]);
            }

            // Each complaint will have complaint case record. if present get the case Id from there. 
            String caseId = !pcList[0].ComplaintCaseComplaint.isEmpty() ? pcList[0].ComplaintCaseComplaint[0].CaseId : null;

            if(String.isNotBlank(caseId)) {

                fields = 'Id,AccountId,Board_Name__c,License_Type__c,Business_License_Id__c,Origin,'+
                            '(SELECT ID,Respondent__c,Board_Name__c FROM Regulatory_Code_Violations__r),'+
                            '(SELECT ID,ParticipantId,Role,Status FROM CaseParticipantCase WHERE Role = \'Respondent\' AND Status = \'Active\')';

                whereClause = 'Id = \'' + String.escapeSingleQuotes(caseId) + '\''; 
                // Query Case Records. 
                List<Case> caseRecList = LPI_CaseDAO.getCaseRecords(fields, whereClause, '1', null);
                if(!caseRecList.isEmpty()) {
                    caseRecList[0].Board_Name__c = wrapper.board;
                    caseRecList[0].License_Type__c = wrapper.profession;
                    if(String.isNotBlank(wrapper.accountId)) {
                        caseRecList[0].AccountId = wrapper.accountId;
                        caseRecList[0].Subject = wrapper.accountName+ ' ' +(wrapper.respondentType == LICENSED ? wrapper.licenseNum : UNLICENSED)+ ' ' + caseRecList[0].Origin;      
                        caseRecList[0].ContactId = null;
                    }   
                    if(String.isNotBlank(wrapper.licenseId) && wrapper.respondentType == LICENSED) {
                        caseRecList[0].Business_License_Id__c = wrapper.licenseId;
                    }
                    sObjectList.add(caseRecList[0]);  

                    // Query for Case Participant Records for Respondent Role.
                    if(!caseRecList[0].CaseParticipantCase.isEmpty()) {
                        CaseParticipant caseParticipantRec = caseRecList[0].CaseParticipantCase[0];
                        caseParticipantRec.ParticipantId = wrapper.accountId;
                        sObjectList.add(caseParticipantRec);  
                    }

                    Set<Id> rcvIdSet = new Set<Id>();

                    // Query for RCV Records which were related to Case Record.
                    for(RegulatoryCodeViolation rcv : caseRecList[0].Regulatory_Code_Violations__r) {
                        rcv.Respondent__c = wrapper.accountId;
                        rcv.Board_Name__c = wrapper.board;
                        rcvIdSet.add(rcv.Id);
                        sObjectList.add(rcv);  
                    }
                    if(!rcvIdSet.isEmpty()) {
                        fields = 'ID,Board_Name__c,Respondent_Licensee_Name__c';
                        whereClause = 'ViolationId IN ' + LPI_ServiceUtility.getStringValuesBySet(rcvIdSet);
                        // Query for VEA Records which were associated to RCV
                        for(ViolationEnforcementAction vea : LPI_ViolationEnforcementActionDAO.fetchViolationEnforcementActionRecordsWithoutSecurity(fields,whereClause,null,null)) {
                            vea.Respondent_Licensee_Name__c = wrapper.accountName;
                            vea.Board_Name__c = wrapper.board;
                            sObjectList.add(vea);  
                        }
                    }
                }           
                
                fields = 'Id,Board_Name__c,Related_To__c,Related_to_Name__c';
                whereClause = 'WhatId = \'' + String.escapeSingleQuotes(caseId) + '\'';
                // Get the Task Details.
                List<Task> taskList = LPI_TaskDao.getTaskByDymanicQuery(fields, whereClause, null,null,null);

                for(Task tsk : taskList) {
                    tsk.Board_Name__c = wrapper.board;
                    if(tsk.Related_To__c == RESPONDENT_TEXT && String.isNotBlank(wrapper.accountName)) {
                        // update related to name. 
                        tsk.Related_to_Name__c =wrapper.accountName;
                    }
                }
                sObjectList.addAll(taskList);             
            }

            if(!sObjectList.isEmpty()) {
                LPI_WithoutSharingUtility.upsertSObjectList(sObjectList);
            }
            if(!sObjectListToDelete.isEmpty()) {
                LPI_WithoutSharingUtility.deleteSObject(sObjectListToDelete);
            }
        }
        catch(Exception ex) {
            LPI_ExceptionManager.logException('LPI_ComplaintsRespChangeController', 'updateRespDetailsOnAssociatedObjects', ex);
            throw new AuraHandledException(ex.getMessage());
        }
    }

    public class ChangeRespondentWrapper {
        @AuraEnabled 
        public String complaintId;
        @AuraEnabled 
        public String respondentType;
        @AuraEnabled 
        public String board;
        @AuraEnabled 
        public String profession;
        @AuraEnabled 
        public String accountId;
        @AuraEnabled 
        public String licenseId;
        @AuraEnabled 
        public String accountName;
        @AuraEnabled 
        public String licenseNum;
        @AuraEnabled 
        public String newOrExisting;
        @AuraEnabled 
        public String businessOrIndividual;
        @AuraEnabled 
        public LPI_Wrapper.RespondentWrapper accountInfo;
    }

}