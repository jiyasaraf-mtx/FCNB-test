/**
 * @description       :
 * @author            : Mohit Karani
 * @group             :
 * @last modified on  : 05-26-2023
 * @last modified by  : Mohit Karani
 **/
public with sharing class LPI_CaseParticipantController {
    public static final string CASE_API_NAME = 'Case';
    public static final List<String> PARTICIPANTS_TO_EXCLUDE = new List<String>{
        LPI_LiteralConstant.RESPONDENT_TEXT,
        LPI_LiteralConstant.COMPLAINANT_TEXT
    };

    @AuraEnabled
    public static Map<String, List<LPI_Wrapper.CaseParticipantWrapper>> getCaseParticipantDetails(
        Id recordId
    ) {
        try {
            // return null if no record id.
            if (String.isBlank(recordId)) {
                return null;
            }

            if (String.valueOf(recordId.getsobjecttype()) == CASE_API_NAME) {
                return getComplaintParticipantsOnComplaint(recordId);
            }
            String fields = 'Id,Status,Role,Participant.Name,ParticipantId,CaseId';
            String whereClause =
                'Id = \'' +
                String.escapeSingleQuotes(recordId) +
                '\'';
            List<CaseParticipant> caseParticipantList = LPI_CaseParticipantDao.fetchCaseParticipantsRecordsWithoutSecurityEnforced(
                fields,
                whereClause,
                null,
                null,
                null
            );
            if (caseParticipantList.isEmpty()) {
                return null;
            }
            CaseParticipant cp = caseParticipantList[0];
            LPI_Wrapper.CaseParticipantWrapper wrapper = new LPI_Wrapper.CaseParticipantWrapper();
            wrapper.participantId = cp.ParticipantId;
            wrapper.participantName = cp.Participant.Name;
            wrapper.role = cp.Role;
            wrapper.status = cp.Status;
            wrapper.caseId = cp.CaseId;
            wrapper.id = cp.Id;
            return new Map<String, List<LPI_Wrapper.CaseParticipantWrapper>>{
                'caseParticipant' => new List<LPI_Wrapper.CaseParticipantWrapper>{
                    wrapper
                }
            };
        }
        catch (Exception ex) {
            LPI_ExceptionManager.logException(
                'LPI_CaseParticipantController',
                'getCaseParticipantDetails',
                ex
            );
            throw new LPI_Exception(ex.getMessage());
        }
    }

    public static Map<String, List<LPI_Wrapper.CaseParticipantWrapper>> getComplaintParticipantsOnComplaint(
        String recordId
    ) {
        try {
            if (String.isBlank(recordId)) {
                return null;
            }
            String fields = 'Id,PublicComplaintId';
            String whereClause =
                'PublicComplaintId != NULL AND CaseId = \'' +
                String.escapeSingleQuotes(recordId) +
                '\'';
            List<ComplaintCase> complaintCaseList = LPI_ComplaintCaseDao.fetchComplaintCaseRecords(
                fields,
                whereClause,
                null,
                null
            );
            if (complaintCaseList.isEmpty()) {
                throw new LPI_Exception(
                    'Case is not associated with any Public Complaint.'
                );
            }
            fields = 'ParticipantId,Participant.Name,Role';
            whereClause =
                ' Status = \'' +
                LPI_LiteralConstant.ACTIVE_TEXT +
                '\' AND Role NOT IN ' +
                LPI_ServiceUtility.getStringValuesByList(PARTICIPANTS_TO_EXCLUDE) +
                ' AND PublicComplaintId = \'' +
                complaintCaseList[0].PublicComplaintId +
                '\'';
            List<ComplaintParticipant> complaintParticipantList = LPI_ComplaintParticipantDAO.fetchComplaintParticipantsRecordsWithoutSecurityEnforced(
                fields,
                whereClause,
                null,
                null,
                null
            );
            if (complaintParticipantList.isEmpty()) {
                throw new LPI_Exception(
                    'No active Non-Respondents found on Public Complaint.'
                );
            }
            Map<String, List<LPI_Wrapper.CaseParticipantWrapper>> roleToComplaintParticipantMap = new Map<String, List<LPI_Wrapper.CaseParticipantWrapper>>();
            for (ComplaintParticipant cp : complaintParticipantList) {
                if (!roleToComplaintParticipantMap.containsKey(cp.Role)) {
                    roleToComplaintParticipantMap.put(
                        cp.Role,
                        new List<LPI_Wrapper.CaseParticipantWrapper>()
                    );
                }

                LPI_Wrapper.CaseParticipantWrapper wrapper = new LPI_Wrapper.CaseParticipantWrapper();
                wrapper.participantId = cp.ParticipantId;
                wrapper.participantName = cp.Participant.Name;
                roleToComplaintParticipantMap.get(cp.Role).add(wrapper);
            }
            return roleToComplaintParticipantMap;
        } catch (Exception ex) {
            LPI_ExceptionManager.logException(
                'LPI_CaseParticipantController',
                'getComplaintParticipantsOnComplaint',
                ex
            );
            throw new LPI_Exception(ex.getMessage());
        }
    }

    @AuraEnabled
    public static Boolean saveCaseParticipantDetails(String jsonData){
        try {
            
            if(String.isBlank(jsonData)){
                return false;
            }
            
            LPI_Wrapper.CaseParticipantWrapper wrapper = (LPI_Wrapper.CaseParticipantWrapper)JSON.deserialize(jsonData, LPI_Wrapper.CaseParticipantWrapper.class);
            if(String.isBlank(wrapper.id)){
                String fields = 'Id,Participant.Name, Role';
                String whereClause = 'CaseId = \'' + String.escapeSingleQuotes(wrapper.caseId)+ '\' AND ParticipantId = \'' + String.escapeSingleQuotes(wrapper.participantId) + '\' AND Role = \'' + String.escapeSingleQuotes(wrapper.role) +'\'';
                List<CaseParticipant> cpList = LPI_CaseParticipantDao.fetchCaseParticipantsRecordsWithoutSecurityEnforced(fields,whereClause,NULL,NULL,NULL);
                if(!cpList.isEmpty()){
                    throw new LPI_Exception(cpList[0].Participant.Name + ' has already been added as a ' + cpList[0].Role + ' on this case.');
                }
            }
            CaseParticipant cs = new CaseParticipant();
            cs.Id = wrapper.id;
            cs.CaseId = wrapper.caseId;
            cs.ParticipantId = wrapper.participantId;
            cs.Role = wrapper.role;
            cs.Status = wrapper.status;
            LPI_DML.doUpsert(new List<CaseParticipant>{cs});
            return true;
        } catch (Exception ex) {
            LPI_ExceptionManager.logException(
                'LPI_CaseParticipantController',
                'saveCaseParticipantDetails',
                ex
            );
            throw new LPI_Exception(ex.getMessage());
        }
    }

    /**
     *   @author                             : Ankit Bansal
     *   @since                              : 24 Jan, 2024
     *   @description                        : This method will get case participants.
     *   @param                              : case recordId 
     *   @return                             : LPI_Wrapper.CaseParticipantWrapper
     */
    @AuraEnabled
    public static LPI_Wrapper.CaseParticipantWrapper getCaseParticipants(String recordId){
        if(String.isBlank(recordId)){
            return null;
        }
        String fields = 'id,CaseId,Role,ParticipantId,TYPEOF Participant WHEN Account THEN PersonEmail,FirstName,MiddleName,LastName,PersonOtherState,PersonOtherStreet,PersonOtherCity,PersonOtherPostalCode,PersonOtherPhone,Phone,PersonHomePhone END';
        String whereClause = 'CaseId =\'' + String.escapeSingleQuotes(recordId) + '\' AND Role = \'Complainant\'';
        List<CaseParticipant> caseParticipantList = LPI_CaseParticipantDao.fetchCaseParticipantsRecordsWithoutSecurityEnforced(fields,whereClause,null,null,null);
        if(caseParticipantList.isEmpty()){
            return null;
        }
        CaseParticipant cpRec = caseParticipantList[0];
        LPI_Wrapper.CaseParticipantWrapper wrapper = new LPI_Wrapper.CaseParticipantWrapper();
        wrapper.id = cpRec.Id;
        if(cpRec.Participant instanceof Account){
            Account accRec = cpRec.Participant;
            wrapper.accFirstName = accRec.FirstName;
            wrapper.accMiddleName = accRec.MiddleName;
            wrapper.accLastName = accRec.LastName;
            wrapper.accEmail = accRec.PersonEmail;
            wrapper.accCellphone = accRec.Phone;
            wrapper.accTelephne = accRec.PersonHomePhone;
            wrapper.accStreet = accRec.PersonOtherStreet;
            wrapper.accState = accRec.PersonOtherState;
            wrapper.accCity = accRec.PersonOtherCity;
            wrapper.accZipCode = accRec.PersonOtherPostalCode;
        }
        return wrapper;
    }    
}