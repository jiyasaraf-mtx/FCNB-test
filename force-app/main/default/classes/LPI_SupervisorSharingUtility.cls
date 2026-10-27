/**
 * @author              : Kishore
 * @since               : 08 May 2023
 * @description         : This class is utility class for managing Applicant & Supervisor sharing
 * @story number        : S-48295
 */

public with sharing class LPI_SupervisorSharingUtility {
    private final static String SUBMITTED_STATUS = 'Submitted';
    private final static String APPROVED_STATUS = 'Approved';
    private final static Set<String> STATUS_SET = new Set<String>{SUBMITTED_STATUS , APPROVED_STATUS};
    /**
     * @author                      : Kishore
     * @since                       : 8th May, 2023
     * @description                 : This method is to used to Share Account details to Supervisor
     * @story Number				: S-48295
     * @return                      : Sharing_Ledger__c
     * @last modified by            : (Add if modified by you)
     * @last modified date          : (Add if modified by you)
     * @modified details            : (Add if modified by you)
     */

    /*public static Sharing_Ledger__c shareAccountToSupervisor(
        String accountId,
        String userId
    ) {
        Sharing_Ledger__c shareRecord = LPI_ApexSharingUtility.createStaticLedgerRecord(
            'Account',
            accountId,
            userId
        );
        shareRecord.Access_Level__c = 1;
        return shareRecord;
    }*/

    /**
     * @author                      : Kishore
     * @since                       : 8th May, 2023
     * @description                 : This method is to used to Share PersonEducation details to Supervisor
     * @story Number				: S-48295
     * @return                      : List<Sharing_Ledger__c>
     * @last modified by            : (Add if modified by you)
     * @last modified date          : (Add if modified by you)
     * @modified details            : (Add if modified by you)
     */
   /* public static List<Sharing_Ledger__c> sharePersonEduToSupervisor(
        String contactId,
        String educationType,
        List<User> userList
    ) {
        List<Sharing_Ledger__c> insertSharingLedgerList = new List<Sharing_Ledger__c>();
        if (!userList.isEmpty() && contactId != null) {
            String eduFields = ' Id , Preliminary_Application_Reference__c ';
            String eduWhereCaluse =
                'ContactId = \'' +
                String.escapeSingleQuotes(contactId) +
                '\'' +
                ' AND Education_Type__c = \'' +
                String.escapeSingleQuotes(educationType) +
                '\'';
            LPI_PersonEducationDAO.LPI_PersonEducationWithoutSharingDAO withoutSharingEdu = new LPI_PersonEducationDAO.LPI_PersonEducationWithoutSharingDAO();
            for (
                PersonEducation rec : withoutSharingEdu.getPersonEducationByDymanicQuery(
                    eduFields,
                    eduWhereCaluse,
                    null,
                    null,
                    null
                )
            ) {
                for (User supervisorUsr : userList) {
                    Sharing_Ledger__c shareRecord = LPI_ApexSharingUtility.createStaticLedgerRecord(
                        'PersonEducation',
                        String.valueOf(rec.Id),
                        supervisorUsr.Id
                    );
                    shareRecord.Access_Level__c = 1;
                    insertSharingLedgerList.add(shareRecord);
                }
            }
        }
        return insertSharingLedgerList;
    }*/

    /**
     * @author                      : Kishore
     * @since                       : 8th May, 2023
     * @description                 : This method is to used to Share Application Content details to Supervisor
     * @story Number				: S-48295
     * @return                      : List<Sharing_Ledger__c>
     * @last modified by            : (Add if modified by you)
     * @last modified date          : (Add if modified by you)
     * @modified details            : (Add if modified by you)
     */
    /*public static List<Sharing_Ledger__c> shareAppContentToSupervisor(
        String parId,
        String sectionHeader,
        List<User> userList
    ) {
        List<Sharing_Ledger__c> insertSharingLedgerList = new List<Sharing_Ledger__c>();
        if (!userList.isEmpty() && parId != null) {
            String licenseHisFields = ' Id , Preliminary_Application_Reference__c ';
            String licenseHisWhereCaluse =
                'Preliminary_Application_Reference__c = \'' +
                String.escapeSingleQuotes(parId) +
                '\'' +
                ' AND Section_Header__c = \'' +
                String.escapeSingleQuotes(sectionHeader) +
                '\'';
                LPI_ApplicationContentDAO.LPI_ApplicationContentWithoutSharingDAO withoutSharingAppContent = new LPI_ApplicationContentDAO.LPI_ApplicationContentWithoutSharingDAO();
            for (
                Application_Content__c rec : withoutSharingAppContent.getApplicationContentByDymanicQuery(
                    licenseHisFields,
                    licenseHisWhereCaluse,
                    null,
                    null,
                    null
                )
            ) {
                for (User supervisorUsr : userList) {
                    Sharing_Ledger__c shareRecord = LPI_ApexSharingUtility.createStaticLedgerRecord(
                        'Application_Content__c',
                        String.valueOf(rec.Id),
                        supervisorUsr.Id
                    );
                    shareRecord.Access_Level__c = 1;
                    insertSharingLedgerList.add(shareRecord);
                }
            }
        }
        return insertSharingLedgerList;
    }*/

    /**
     * @author                      : Kishore
     * @since                       : 8th May, 2023
     * @description                 : This method is to used to Share Application Content details to Supervisor
     * @story Number				: S-48295
     * @return                      : List<Sharing_Ledger__c>
     * @last modified by            : (Add if modified by you)
     * @last modified date          : (Add if modified by you)
     * @modified details            : (Add if modified by you)
     */
    /*public static List<Sharing_Ledger__c> shareLocationToSupervisor(
        String parId,
        List<User> userList
    ) {
        List<Sharing_Ledger__c> insertSharingLedgerList = new List<Sharing_Ledger__c>();
        if (!userList.isEmpty() && parId != null) {
            String fields = 'ID, Location__c';
            String whereClause =
                'Preliminary_Application_Reference__c = \'' +
                String.escapeSingleQuotes(parId) +
                '\'';
                LPI_TempAuthApplicationPlaceDAO.LPI_TempAuthApplicationPlaceWithoutSharingDAO withoutSharingQuery = new LPI_TempAuthApplicationPlaceDAO.LPI_TempAuthApplicationPlaceWithoutSharingDAO();
            for (
                Temp_AuthApplicationPlace__c tempPlaceRec : withoutSharingQuery.getTempAuthApplicationPlaceByDymanicQuery(
                    fields,
                    whereClause,
                    null,
                    null,
                    null
                )
            ) {
                for (User supervisorUsr : userList) {
                    Sharing_Ledger__c shareRecord = LPI_ApexSharingUtility.createStaticLedgerRecord(
                        'Location',
                        String.valueOf(tempPlaceRec.Location__c),
                        supervisorUsr.Id
                    );
                    shareRecord.Access_Level__c = 1;
                    insertSharingLedgerList.add(shareRecord);
                }
            }
        }
        return insertSharingLedgerList;
    }*/
    /**
     * @author                      : Kishore
     * @since                       : 23rd May, 2023
     * @description                 : This method will return the ACR id of the supervisor relationship if the current logged in user is a supervisor else null.
     * @return                      : String
     * @last modified by            : (Add if modified by you)
     * @last modified date          : (Add if modified by you)
     * @modified details            : (Add if modified by you)
     */

    /*public static List<String> checkSharingAllowed(List<PreliminaryApplicationRef> parList) {
        List<String> supervisorIdsList = new List<String>();
        List<User> userList = LPI_UserDao.getCurrentUserRecord();
        if (!userList.isEmpty() && !parList.isEmpty()) {
            String currentUserAccountId = userList[0].AccountId;
            List<String> supervisorAcrIdsList = getSupervisorAcrIds(parList);
            if (!supervisorAcrIdsList.isEmpty()) {
                String acrFields = 'Id , Related_From__c ';
                String whereCaluse =
                    'Id IN ' +
                    LPI_ServiceUtility.getStringValuesByList(
                        supervisorAcrIdsList
                    ) +
                    ' AND Supervisor_Approval_Status__c IN ' 
                    + LPI_ServiceUtility.getStringValuesByStringSet(STATUS_SET);
                    LPI_BusinessRelationshipDAO.LPI_BusinessRelationshipsWithoutSharingDAO withoutSharingQuery = new LPI_BusinessRelationshipDAO.LPI_BusinessRelationshipsWithoutSharingDAO();
                for (
                    Business_Relationships__c rec : withoutSharingQuery.getBusinessRelationshipsByDymanicQuery(
                        acrFields,
                        whereCaluse,
                        null,
                        null,
                        null
                    )
                ) {
                    supervisorIdsList.add(rec.Id);
                }
            }
        }
        return supervisorIdsList;
    }*/
    /**
     * @author                      : Kishore
     * @since                       : 29th May, 2023
     * @description                 : This method will return 'pending' if there is NO response from any one of the supervisor ,
     *                                'Approve' if aleast one supervisor Approves request and 'Rejected' if all the supervisors rejects the requests.
     * @return                      :  String
     * @last modified by            : (Add if modified by you)
     * @last modified date          : (Add if modified by you)
     * @modified details            : (Add if modified by you)
     */
    public static String checkForSupervisorResponse(String parId) {
        List<String> supervisorAcrIdsList = new List<String>();
        Boolean isApproved = false; 
        if (!String.isBlank(parId)) {
            supervisorAcrIdsList = fetchSupervisorAcrIds(parId);
        }
        if (!supervisorAcrIdsList.isEmpty()) {
            String acrFields = 'Id  , Supervisor_Approval_Status__c ';
            String whereCaluse =
                'Id IN ' +
                LPI_ServiceUtility.getStringValuesByList(
                    supervisorAcrIdsList
                );
                LPI_BusinessRelationshipDAO.LPI_BusinessRelationshipsWithoutSharingDAO withoutSharingQuery = new LPI_BusinessRelationshipDAO.LPI_BusinessRelationshipsWithoutSharingDAO();
            for (
                Business_Relationships__c rec : withoutSharingQuery.getBusinessRelationshipsByDymanicQuery(
                    acrFields,
                    whereCaluse,
                    null,
                    null,
                    null
                )
            ) {
                if (rec.Supervisor_Approval_Status__c == 'Submitted') {
                    return 'Pending';
                } else if (rec.Supervisor_Approval_Status__c == 'Approved') {
                    isApproved = true;
                }
            }
            if (isApproved) {
                return 'Approved';
            } else {
                return 'Rejected';
            }
        }
        return null;
    }

    /**
     * @author                      : Kishore
     * @since                       : 29th May, 2023
     * @description                 : This method is to used to fetch the ACR ids of supervisor stored in a form of string .
     * @return                      : String
     * @last modified by            : (Add if modified by you)
     * @last modified date          : (Add if modified by you)
     * @modified details            : (Add if modified by you)
     */
    public static List<String> fetchSupervisorAcrIds(String parId) {
        List<String> supervisorAcrIdsList = new List<String>();
        if (parId == null) {
            return supervisorAcrIdsList;
        }
        String fields = ' Id, Approval_Supervisors_AcrIds__c ';
        String whereClause = 'Id= \'' + String.escapeSingleQuotes(parId) + '\'';
        List<PreliminaryApplicationRef> parList = LPI_PreliminaryApplicationRefDAO.getPreliminaryApplicationRefByDymanicQuery(
            fields,
            whereClause,
            null,
            null,
            null
        );
        return getSupervisorAcrIds(parList);
    }

    /**
     * @author                      : Kishore
     * @since                       : 29th May, 2023
     * @description                 : This method will delete all the instances of Save&Exit from the system related to PAR record.
     * @return                      : List<String>
     * @last modified by            : (Add if modified by you)
     * @last modified date          : (Add if modified by you)
     * @modified details            : (Add if modified by you)
     */
    public static void deleteSaveAndExitInstance(String parId) {
        List<OmniScriptSavedSession> saveInstanceList = [
            SELECT Id
            FROM OmniScriptSavedSession
            WHERE RelatedRecordIdentifier = :parId
        ];
        if (!saveInstanceList.isEmpty()) {
            LPI_WithoutSharingUtility.deleteSObject(saveInstanceList);
        }
    }

    /**
     * @author                      : Kishore
     * @since                       : 11th June, 2023
     * @description                 : This method is to used to fetch the ACR ids of supervisor stored in a form of string .
     * @return                      : List<String>
     * @last modified by            : (Add if modified by you)
     * @last modified date          : (Add if modified by you)
     * @modified details            : (Add if modified by you)
     */
    public static List<String> fetchSupervisorAcrIds(List<String> parIdList) {
        List<String> supervisorAcrIdsList = new List<String>();
        if (parIdList.isEmpty()) {
            return supervisorAcrIdsList;
        }
        String fields = ' Id, Approval_Supervisors_AcrIds__c ';
        String whereClause =
            'Id IN ' + LPI_ServiceUtility.getStringValuesByList(parIdList);
        List<PreliminaryApplicationRef> parList = LPI_PreliminaryApplicationRefDAO.getPreliminaryApplicationRefByDymanicQuery(
            fields,
            whereClause,
            null,
            null,
            null
        );
        return getSupervisorAcrIds(parList);
    }

    /**
     * @author                      : Kishore
     * @since                       : 11th June 2023
     * @description                 : This method is to used to get the Supervisor Id with ParList .
     * @return                      : List<String>
     * @last modified by            : (Add if modified by you)
     * @last modified date          : (Add if modified by you)
     * @modified details            : (Add if modified by you)
     */
   public static List<String> getSupervisorAcrIds(
        List<PreliminaryApplicationRef> parList
    ) {
        List<String> supervisorAcrIdsList = new List<String>();
        if (
            !parList.isEmpty() &&
            parList[0].Approval_Supervisors_AcrIds__c != null
        ) {
            supervisorAcrIdsList = parList[0]
                .Approval_Supervisors_AcrIds__c.split(',');
        }
        return supervisorAcrIdsList;
    }
}