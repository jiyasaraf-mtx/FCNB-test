public with sharing class EMP_SponsoringInsurerReviewCtrl {
    public static final String LICENSE_TYPE_IIA = 'Individual Insurance Agent';
    public static final String LICENSE_TYPE_RES = 'Real Estate Salesperson';

    public static final String STATUS_SUBMITTED_TO_INSURER = 'Submitted to Insurer';
    public static final String STATUS_RMI = 'More Info Require';
    public static final String STATUS_APPROVED = 'Approved by Insurer';
    public static final String STATUS_DENIED_BY_INSURER = 'Denied by Insurer';
    public static final String STATUS_INFO_SUBMITTED = 'Information Submitted';
    
    /** @deprecated Use STATUS_DENIED_BY_INSURER */
    public static final String STATUS_NOT_SPONSORED = 'Denied by Insurer';
    /** Legacy IIA submissions prior to insurer-specific statuses */
    public static final String STATUS_SUBMITTED = 'Submitted';

    public static final String STATUS_SUBMITTED_TO_AGENT = 'Submitted to Agent';
    public static final String STATUS_AGENT_RMI = 'Agency Require More Info';
    public static final String STATUS_SUBMITTED_TO_FCNB = 'Submitted to FCNB';
    public static final String STATUS_AGENT_DENIED = 'Agency Denied';

    private static final Set<String> AGENT_QUEUE_STATUSES = new Set<String>{
        STATUS_SUBMITTED,
        STATUS_SUBMITTED_TO_AGENT,
        STATUS_AGENT_RMI,
        STATUS_SUBMITTED_TO_FCNB,
        STATUS_AGENT_DENIED,
        STATUS_INFO_SUBMITTED,
        'Agent Requires More Information',
        'Information Submitted',
        'Denied',
        'Rejected',
        'Awaiting Response',
        'Approved'
    };

    private static final Set<String> AGENT_DECISION_STATUSES = new Set<String>{
        STATUS_SUBMITTED_TO_AGENT,
        STATUS_AGENT_RMI,
        STATUS_SUBMITTED_TO_FCNB,
        STATUS_AGENT_DENIED
    };

    private static final Set<String> INSURER_QUEUE_STATUSES = new Set<String>{
        STATUS_SUBMITTED,
        STATUS_SUBMITTED_TO_INSURER,
        STATUS_RMI,
        STATUS_APPROVED,
        STATUS_DENIED_BY_INSURER,
        STATUS_INFO_SUBMITTED,
        'Insurer Requires More Information',
        'Not Sponsored',
        'Awaiting Response',
        'Approved',
        'Rejected'
    };

    private static final Set<String> INSURER_DECISION_STATUSES = new Set<String>{
        STATUS_SUBMITTED_TO_INSURER,
        STATUS_RMI,
        STATUS_APPROVED,
        STATUS_DENIED_BY_INSURER,
        STATUS_INFO_SUBMITTED
    };

    @AuraEnabled(cacheable=true)
    public static QueueResult getQueue() {
        QueueResult result = new QueueResult();
        List<ApplicationRow> rows = new List<ApplicationRow>();

        List<IndividualApplication> apps = [
            SELECT
                Id,
                Name,
                Status,
                Description,
                Insurer_Comments__c,
                Real_Estate_Salesperson_Comments__c,
                Admin_Action_Status__c,
                Applicant_Full_Name__c,
                Applicant_submission_Date__c,
                License_Type_Name__c,
                Board_Name__c,
                AccountId,
                Account.Name,
                Account.PersonEmail,
                Account.Phone,
                Account.PersonBirthdate,
                Business_Account__c,
                Business_Account__r.Name,
                SavedApplicationRefId,
                SavedApplicationRef.SponsoringInsurer_Supervisor_JSON__c,
                SavedApplicationRef.AgencyEmployment_JSON__c,
                SavedApplicationRef.LicenceType_JSON__c,
                SavedApplicationRef.ApplicantInformation_JSON__c,
                SavedApplicationRef.Upload_Documents_Json__c
            FROM IndividualApplication
            WHERE
                LicenseType.Name = :LICENSE_TYPE_IIA
                AND (
                    Status IN :INSURER_QUEUE_STATUSES
                    OR Admin_Action_Status__c IN :INSURER_DECISION_STATUSES
                    OR Status IN ('Employer Review Completed', 'Under Review')
                )
            ORDER BY Applicant_submission_Date__c DESC NULLS LAST, Name DESC
            LIMIT 500
        ];

        for (IndividualApplication ia : apps) {
            rows.add(mapRow(ia));
        }
        result.applications = rows;
        result.insurerName = resolveInsurerName(rows);
        return result;
    }

    @AuraEnabled
    public static QueueResult getInsurerReviewApplication(Id applicationId) {
        QueueResult result = new QueueResult();
        result.applications = new List<ApplicationRow>();
        if (applicationId == null) {
            return result;
        }

        List<IndividualApplication> apps = [
            SELECT
                Id,
                Name,
                Status,
                Description,
                Insurer_Comments__c,
                Real_Estate_Salesperson_Comments__c,
                Admin_Action_Status__c,
                Applicant_Full_Name__c,
                Applicant_submission_Date__c,
                License_Type_Name__c,
                Board_Name__c,
                AccountId,
                Account.Name,
                Account.PersonEmail,
                Account.Phone,
                Account.PersonBirthdate,
                Business_Account__c,
                Business_Account__r.Name,
                SavedApplicationRefId,
                SavedApplicationRef.SponsoringInsurer_Supervisor_JSON__c,
                SavedApplicationRef.AgencyEmployment_JSON__c,
                SavedApplicationRef.LicenceType_JSON__c,
                SavedApplicationRef.ApplicantInformation_JSON__c,
                SavedApplicationRef.Upload_Documents_Json__c
            FROM IndividualApplication
            WHERE
                Id = :applicationId
                AND LicenseType.Name = :LICENSE_TYPE_IIA
            LIMIT 1
        ];
        if (!apps.isEmpty()) {
            result.applications.add(mapRowWithSummary(apps[0]));
        }
        result.insurerName = resolveInsurerName(result.applications);
        return result;
    }

    @AuraEnabled(cacheable=true)
    public static QueueResult getAgentReviewQueue() {
        QueueResult result = new QueueResult();
        List<ApplicationRow> rows = new List<ApplicationRow>();

        List<IndividualApplication> apps = [
            SELECT
                Id,
                Name,
                Status,
                Description,
                Insurer_Comments__c,
                Real_Estate_Salesperson_Comments__c,
                Admin_Action_Status__c,
                Applicant_Full_Name__c,
                Applicant_submission_Date__c,
                License_Type_Name__c,
                Board_Name__c,
                AccountId,
                Account.Name,
                Account.PersonEmail,
                Account.Phone,
                Account.PersonBirthdate,
                Business_Account__c,
                Business_Account__r.Name,
                SavedApplicationRefId,
                SavedApplicationRef.Additional_Information_JSON__c,
                SavedApplicationRef.AgencyEmployment_JSON__c,
                SavedApplicationRef.LicenceType_JSON__c,
                SavedApplicationRef.ApplicantInformation_JSON__c,
                SavedApplicationRef.Upload_Documents_Json__c
            FROM IndividualApplication
            WHERE
                LicenseType.Name = :LICENSE_TYPE_RES
                AND Status IN :AGENT_QUEUE_STATUSES
            ORDER BY Applicant_submission_Date__c DESC NULLS LAST, Name DESC
            LIMIT 500
        ];

        for (IndividualApplication ia : apps) {
            rows.add(mapAgentRow(ia));
        }
        result.applications = rows;
        result.reviewerName = UserInfo.getName();
        return result;
    }

    @AuraEnabled
    public static QueueResult getAgentReviewApplication(Id applicationId) {
        QueueResult result = new QueueResult();
        result.applications = new List<ApplicationRow>();
        result.reviewerName = UserInfo.getName();
        if (applicationId == null) {
            return result;
        }

        List<IndividualApplication> apps = [
            SELECT
                Id,
                Name,
                Status,
                Description,
                Insurer_Comments__c,
                Real_Estate_Salesperson_Comments__c,
                Admin_Action_Status__c,
                Applicant_Full_Name__c,
                Applicant_submission_Date__c,
                License_Type_Name__c,
                Board_Name__c,
                AccountId,
                Account.Name,
                Account.PersonEmail,
                Account.Phone,
                Account.PersonBirthdate,
                Business_Account__c,
                Business_Account__r.Name,
                SavedApplicationRefId,
                SavedApplicationRef.Additional_Information_JSON__c,
                SavedApplicationRef.AgencyEmployment_JSON__c,
                SavedApplicationRef.LicenceType_JSON__c,
                SavedApplicationRef.ApplicantInformation_JSON__c,
                SavedApplicationRef.Upload_Documents_Json__c,
                SavedApplicationRef.Applicant_Details_json__c,
                SavedApplicationRef.Employement_json__c,
                SavedApplicationRef.Licence_Json__c,
                SavedApplicationRef.Additional_Info_json__c,
                SavedApplicationRef.Regulatory_licensing_json__c,
                SavedApplicationRef.Proceedings_Judgments_json__c,
                SavedApplicationRef.Expedited_Service_json__c
            FROM IndividualApplication
            WHERE
                Id = :applicationId
                AND LicenseType.Name = :LICENSE_TYPE_RES
            LIMIT 1
        ];
        if (!apps.isEmpty()) {
            result.applications.add(mapAgentRowWithSummary(apps[0]));
        }
        return result;
    }

    @AuraEnabled
    public static ApplicationRow saveAgentReviewDecision(Id applicationId, String decisionStatus, String comments) {
        if (applicationId == null) {
            throw new AuraHandledException('Application Id is required.');
        }
        if (String.isBlank(decisionStatus) || !AGENT_DECISION_STATUSES.contains(decisionStatus)) {
            throw new AuraHandledException('Select a valid agent review decision.');
        }

        List<IndividualApplication> readable = [
            SELECT
                Id,
                Name,
                Status,
                Description,
                Insurer_Comments__c,
                Real_Estate_Salesperson_Comments__c,
                Admin_Action_Status__c,
                Applicant_Full_Name__c,
                Applicant_submission_Date__c,
                License_Type_Name__c,
                Board_Name__c,
                AccountId,
                Account.Name,
                Account.PersonEmail,
                Account.Phone,
                Account.PersonBirthdate,
                Business_Account__c,
                Business_Account__r.Name,
                SavedApplicationRefId,
                SavedApplicationRef.Additional_Information_JSON__c,
                SavedApplicationRef.AgencyEmployment_JSON__c,
                SavedApplicationRef.LicenceType_JSON__c,
                SavedApplicationRef.ApplicantInformation_JSON__c,
                SavedApplicationRef.Upload_Documents_Json__c,
                SavedApplicationRef.Applicant_Details_json__c,
                SavedApplicationRef.Employement_json__c,
                SavedApplicationRef.Licence_Json__c,
                SavedApplicationRef.Additional_Info_json__c,
                SavedApplicationRef.Regulatory_licensing_json__c,
                SavedApplicationRef.Proceedings_Judgments_json__c,
                SavedApplicationRef.Expedited_Service_json__c
            FROM IndividualApplication
            WHERE Id = :applicationId
            LIMIT 1
        ];
        if (readable.isEmpty()) {
            throw new AuraHandledException('You do not have access to this application.');
        }
        IndividualApplication ia = readable[0];
        if (ia.License_Type_Name__c != LICENSE_TYPE_RES) {
            throw new AuraHandledException(
                'Agent review decisions apply only to Real Estate Salesperson applications.'
            );
        }

        ia.Status = resolveAgentWritableStatus(decisionStatus);
        ia.Admin_Action_Status__c = resolveAgentWritableAdminAction(decisionStatus);
        ia.Real_Estate_Salesperson_Comments__c = comments;
        ia.Description = String.isBlank(comments) ? ia.Description : comments.left(255);

        new AgentDecisionWriteService().commitDecision(ia, decisionStatus, comments);

        IndividualApplication refreshed = [
            SELECT
                Id,
                Name,
                Status,
                Description,
                Insurer_Comments__c,
                Real_Estate_Salesperson_Comments__c,
                Admin_Action_Status__c,
                Applicant_Full_Name__c,
                Applicant_submission_Date__c,
                License_Type_Name__c,
                Board_Name__c,
                AccountId,
                Account.Name,
                Account.PersonEmail,
                Account.Phone,
                Account.PersonBirthdate,
                Business_Account__c,
                Business_Account__r.Name,
                SavedApplicationRefId,
                SavedApplicationRef.Additional_Information_JSON__c,
                SavedApplicationRef.AgencyEmployment_JSON__c,
                SavedApplicationRef.LicenceType_JSON__c,
                SavedApplicationRef.ApplicantInformation_JSON__c,
                SavedApplicationRef.Upload_Documents_Json__c,
                SavedApplicationRef.Applicant_Details_json__c,
                SavedApplicationRef.Employement_json__c,
                SavedApplicationRef.Licence_Json__c,
                SavedApplicationRef.Additional_Info_json__c,
                SavedApplicationRef.Regulatory_licensing_json__c,
                SavedApplicationRef.Proceedings_Judgments_json__c,
                SavedApplicationRef.Expedited_Service_json__c
            FROM IndividualApplication
            WHERE Id = :applicationId
            LIMIT 1
        ];
        return mapAgentRowWithSummary(refreshed);
    }

    @AuraEnabled
    public static ApplicationRow saveDecision(Id applicationId, String decisionStatus, String comments) {
        if (applicationId == null) {
            throw new AuraHandledException('Application Id is required.');
        }
        if (String.isBlank(decisionStatus) || !INSURER_DECISION_STATUSES.contains(decisionStatus)) {
            throw new AuraHandledException('Select a valid insurer decision.');
        }

        List<IndividualApplication> readable = [
            SELECT
                Id,
                Name,
                Status,
                Description,
                Insurer_Comments__c,
                Real_Estate_Salesperson_Comments__c,
                Admin_Action_Status__c,
                Applicant_Full_Name__c,
                Applicant_submission_Date__c,
                License_Type_Name__c,
                Board_Name__c,
                AccountId,
                Account.Name,
                Account.PersonEmail,
                Account.Phone,
                Account.PersonBirthdate,
                Business_Account__c,
                Business_Account__r.Name,
                SavedApplicationRefId,
                SavedApplicationRef.SponsoringInsurer_Supervisor_JSON__c,
                SavedApplicationRef.AgencyEmployment_JSON__c,
                SavedApplicationRef.LicenceType_JSON__c,
                SavedApplicationRef.ApplicantInformation_JSON__c,
                SavedApplicationRef.Upload_Documents_Json__c
            FROM IndividualApplication
            WHERE Id = :applicationId
            LIMIT 1
        ];
        if (readable.isEmpty()) {
            throw new AuraHandledException('You do not have access to this application.');
        }
        IndividualApplication ia = readable[0];

        if (ia.License_Type_Name__c != LICENSE_TYPE_IIA) {
            throw new AuraHandledException(
                'Insurer review decisions apply only to Individual Insurance Agent applications.'
            );
        }

        ia.Admin_Action_Status__c = resolveWritableAdminAction(decisionStatus);
        ia.Status = resolveWritableStatus(decisionStatus);
        ia.Insurer_Comments__c = comments;
        ia.Description = String.isBlank(comments) ? ia.Description : comments.left(255);

        new DecisionWriteService().commitDecision(ia, decisionStatus, comments);

        IndividualApplication refreshed = [
            SELECT
                Id,
                Name,
                Status,
                Description,
                Insurer_Comments__c,
                Real_Estate_Salesperson_Comments__c,
                Admin_Action_Status__c,
                Applicant_Full_Name__c,
                Applicant_submission_Date__c,
                License_Type_Name__c,
                Board_Name__c,
                AccountId,
                Account.Name,
                Account.PersonEmail,
                Account.Phone,
                Account.PersonBirthdate,
                Business_Account__c,
                Business_Account__r.Name,
                SavedApplicationRefId,
                SavedApplicationRef.SponsoringInsurer_Supervisor_JSON__c,
                SavedApplicationRef.AgencyEmployment_JSON__c,
                SavedApplicationRef.LicenceType_JSON__c,
                SavedApplicationRef.ApplicantInformation_JSON__c,
                SavedApplicationRef.Upload_Documents_Json__c
            FROM IndividualApplication
            WHERE Id = :applicationId
            LIMIT 1
        ];
        return mapRowWithSummary(refreshed);
    }

    private without sharing class DecisionWriteService {
        public void commitDecision(IndividualApplication ia, String decisionStatus, String comments) {
            update ia;
            if (ia.SavedApplicationRefId == null) {
                return;
            }
            PreliminaryApplicationRef par = [
                SELECT Id, SponsoringInsurer_Supervisor_JSON__c
                FROM PreliminaryApplicationRef
                WHERE Id = :ia.SavedApplicationRefId
                LIMIT 1
            ];
            Map<String, Object> root = parseJsonMap(par.SponsoringInsurer_Supervisor_JSON__c);
            Map<String, Object> sponsoring = root.containsKey('SponsoringInsurer') &&
                root.get('SponsoringInsurer') instanceof Map<String, Object>
                ? (Map<String, Object>) root.get('SponsoringInsurer')
                : new Map<String, Object>();
            sponsoring.put('SI_Status', decisionStatus);
            if (!String.isBlank(comments)) {
                sponsoring.put('SI_Comments', comments);
            }
            sponsoring.put('SI_DecisionDate', String.valueOf(Date.today()));
            root.put('SponsoringInsurer', sponsoring);
            par.SponsoringInsurer_Supervisor_JSON__c = JSON.serialize(root);
            update par;
        }
    }

    private static ApplicationRow mapRow(IndividualApplication ia) {
        Map<String, Object> applicantJson = extractNested(
            parseJsonMap(
                ia.SavedApplicationRef != null ? ia.SavedApplicationRef.ApplicantInformation_JSON__c : null
            ),
            'ApplicantDetails'
        );
        Map<String, Object> licenceJson = extractNested(
            parseJsonMap(ia.SavedApplicationRef != null ? ia.SavedApplicationRef.LicenceType_JSON__c : null),
            'LT_LicInfo'
        );
        Map<String, Object> sponsorRoot = parseJsonMap(
            ia.SavedApplicationRef != null ? ia.SavedApplicationRef.SponsoringInsurer_Supervisor_JSON__c : null
        );
        Map<String, Object> sponsoring = extractNested(sponsorRoot, 'SponsoringInsurer');
        Map<String, Object> supervisor = extractNested(sponsorRoot, 'SupervisorDetails');
        Map<String, Object> agencyEmp = extractNested(
            parseJsonMap(ia.SavedApplicationRef != null ? ia.SavedApplicationRef.AgencyEmployment_JSON__c : null),
            'AE_Emp'
        );

        ApplicationRow row = new ApplicationRow();
        row.id = ia.Id;
        row.applicationNumber = ia.Name;
        row.applicantName = firstNonBlank(
            new List<String>{
                ia.Applicant_Full_Name__c,
                joinName(
                    (String) applicantJson.get('AI_FirstName'),
                    (String) applicantJson.get('AI_LastName')
                ),
                ia.Account != null ? ia.Account.Name : null
            }
        );
        row.dateOfBirth = formatDateValue(
            applicantJson.containsKey('AI_DOB')
                ? String.valueOf(applicantJson.get('AI_DOB'))
                : (ia.Account != null && ia.Account.PersonBirthdate != null
                        ? String.valueOf(ia.Account.PersonBirthdate)
                        : null)
        );
        row.ciprNumber = stringVal(applicantJson.get('AI_CIPR'));
        row.email = firstNonBlank(
            new List<String>{
                stringVal(applicantJson.get('AI_Email')),
                ia.Account != null ? ia.Account.PersonEmail : null
            }
        );
        row.phone = firstNonBlank(
            new List<String>{
                stringVal(applicantJson.get('AI_PhNo')),
                ia.Account != null ? ia.Account.Phone : null
            }
        );
        row.licenceType = firstNonBlank(
            new List<String>{
                buildLicenceLabel(licenceJson),
                ia.License_Type_Name__c
            }
        );
        row.term = stringVal(licenceJson.get('LI_LicTerm'));
        row.classAppliedFor = firstNonBlank(
            new List<String>{
                stringVal(sponsoring.get('SI_Class')),
                stringVal(licenceJson.get('LI_LicClass'))
            }
        );
        row.insurerLicensedFor = stringVal(sponsoring.get('SI_Class'));
        if (String.isBlank(row.insurerLicensedFor)) {
            row.insurerLicensedFor = 'Life / A&S';
        }
        row.classMatches = classMatches(row.classAppliedFor, row.insurerLicensedFor);
        row.agency = firstNonBlank(
            new List<String>{
                ia.Board_Name__c,
                ia.Business_Account__r != null ? ia.Business_Account__r.Name : null,
                stringVal(agencyEmp.get('E_EmpModel'))
            }
        );
        row.supervisor = stringVal(supervisor.get('SD_Name'));
        row.submittedOn = ia.Applicant_submission_Date__c != null
            ? formatDateValue(String.valueOf(ia.Applicant_submission_Date__c))
            : null;
        String decisionFromJson = stringVal(sponsoring.get('SI_Status'));
        String displayStatus = resolveDisplayStatus(ia.Status, ia.Admin_Action_Status__c, decisionFromJson);
        row.status = displayStatus;
        row.rawStatus = ia.Status;
        row.insurerDecision = displayStatus;
        if (
            row.insurerDecision == STATUS_SUBMITTED_TO_INSURER ||
            row.insurerDecision == 'Pending' ||
            row.insurerDecision == STATUS_SUBMITTED
        ) {
            row.insurerDecision = '';
        }
        row.comments = firstNonBlank(
            new List<String>{ ia.Insurer_Comments__c, stringVal(sponsoring.get('SI_Comments')), ia.Description }
        );
        row.insurerName = stringVal(sponsoring.get('SI_Insurer'));
        row.documents = new List<DocumentItem>();
        row.canDecide = row.status == STATUS_SUBMITTED_TO_INSURER || row.status == STATUS_RMI || row.status == STATUS_INFO_SUBMITTED;
        return row;
    }

    private static ApplicationRow mapRowWithSummary(IndividualApplication ia) {
        ApplicationRow row = mapRow(ia);
        try {
            row.documents = new AgentReviewDocumentReader()
                .loadUploadedDocuments(ia.Id, ia.SavedApplicationRefId);
        } catch (Exception e) {
            row.documents = new List<DocumentItem>();
        }
        populateInsurerReviewSummary(row, ia);
        return row;
    }

    private static ApplicationRow mapAgentRow(IndividualApplication ia) {
        Map<String, Object> applicantJson = extractNested(
            parseJsonMap(
                ia.SavedApplicationRef != null ? ia.SavedApplicationRef.ApplicantInformation_JSON__c : null
            ),
            'ApplicantDetails'
        );
        Map<String, Object> licenceJson = extractNested(
            parseJsonMap(ia.SavedApplicationRef != null ? ia.SavedApplicationRef.LicenceType_JSON__c : null),
            'LT_LicInfo'
        );
        Map<String, Object> agentRoot = parseJsonMap(
            ia.SavedApplicationRef != null ? ia.SavedApplicationRef.Additional_Information_JSON__c : null
        );
        Map<String, Object> agentReview = extractNested(agentRoot, 'AgentReview');
        Map<String, Object> agencyEmp = extractNested(
            parseJsonMap(ia.SavedApplicationRef != null ? ia.SavedApplicationRef.AgencyEmployment_JSON__c : null),
            'AE_Emp'
        );

        ApplicationRow row = new ApplicationRow();
        row.id = ia.Id;
        row.applicationNumber = ia.Name;
        row.transactionId = ia.Name;
        row.applicantName = firstNonBlank(
            new List<String>{
                ia.Applicant_Full_Name__c,
                joinName(
                    (String) applicantJson.get('AI_FirstName'),
                    (String) applicantJson.get('AI_LastName')
                ),
                ia.Account != null ? ia.Account.Name : null
            }
        );
        row.dateOfBirth = formatDateValue(
            applicantJson.containsKey('AI_DOB')
                ? String.valueOf(applicantJson.get('AI_DOB'))
                : (ia.Account != null && ia.Account.PersonBirthdate != null
                        ? String.valueOf(ia.Account.PersonBirthdate)
                        : null)
        );
        row.email = firstNonBlank(
            new List<String>{
                stringVal(applicantJson.get('AI_Email')),
                ia.Account != null ? ia.Account.PersonEmail : null
            }
        );
        row.phone = firstNonBlank(
            new List<String>{
                stringVal(applicantJson.get('AI_PhNo')),
                ia.Account != null ? ia.Account.Phone : null
            }
        );
        row.licenceType = firstNonBlank(
            new List<String>{ buildLicenceLabel(licenceJson), ia.License_Type_Name__c }
        );
        row.agency = firstNonBlank(
            new List<String>{
                ia.Board_Name__c,
                ia.Business_Account__r != null ? ia.Business_Account__r.Name : null,
                stringVal(agencyEmp.get('E_EmpModel'))
            }
        );
        row.submittedOn = ia.Applicant_submission_Date__c != null
            ? formatDateValue(String.valueOf(ia.Applicant_submission_Date__c))
            : null;
        String decisionFromJson = stringVal(agentReview.get('AR_Status'));
        row.status = resolveAgentDisplayStatus(ia.Status, ia.Admin_Action_Status__c, decisionFromJson);
        row.rawStatus = ia.Status;
        row.comments = firstNonBlank(
            new List<String>{ ia.Real_Estate_Salesperson_Comments__c, stringVal(agentReview.get('AR_Comments')), ia.Description }
        );
        row.documents = new List<DocumentItem>();
        row.canDecide =
            row.status == STATUS_SUBMITTED_TO_AGENT || row.status == STATUS_AGENT_RMI || row.status == STATUS_INFO_SUBMITTED;
        return row;
    }

    private static ApplicationRow mapAgentRowWithSummary(IndividualApplication ia) {
        ApplicationRow row = mapAgentRow(ia);
        try {
            row.documents = new AgentReviewDocumentReader()
                .loadUploadedDocuments(ia.Id, ia.SavedApplicationRefId);
        } catch (Exception e) {
            row.documents = new List<DocumentItem>();
        }
        populateAgentReviewSummary(row, ia);
        return row;
    }

    private without sharing class AgentDecisionWriteService {
        public void commitDecision(IndividualApplication ia, String decisionStatus, String comments) {
            update ia;
            if (ia.SavedApplicationRefId == null) {
                return;
            }
            PreliminaryApplicationRef par = [
                SELECT Id, Additional_Information_JSON__c
                FROM PreliminaryApplicationRef
                WHERE Id = :ia.SavedApplicationRefId
                LIMIT 1
            ];
            Map<String, Object> root = parseJsonMap(par.Additional_Information_JSON__c);
            Map<String, Object> agentReview = root.containsKey('AgentReview') &&
                root.get('AgentReview') instanceof Map<String, Object>
                ? (Map<String, Object>) root.get('AgentReview')
                : new Map<String, Object>();
            agentReview.put('AR_Status', decisionStatus);
            if (!String.isBlank(comments)) {
                agentReview.put('AR_Comments', comments);
            }
            agentReview.put('AR_DecisionDate', String.valueOf(Date.today()));
            root.put('AgentReview', agentReview);
            par.Additional_Information_JSON__c = JSON.serialize(root);
            update par;
        }
    }

    private static String resolveAgentDisplayStatus(String status, String adminAction, String arStatus) {
        if (status == STATUS_INFO_SUBMITTED || status == 'Information Submitted') {
            return STATUS_INFO_SUBMITTED;
        }
        if (status == STATUS_SUBMITTED || status == STATUS_SUBMITTED_TO_AGENT) {
            return STATUS_SUBMITTED_TO_AGENT;
        }
        if (
            status == STATUS_AGENT_RMI ||
            status == 'Awaiting Response' ||
            status == 'Agent Requires More Information'
        ) {
            return STATUS_AGENT_RMI;
        }
        if (status == STATUS_SUBMITTED_TO_FCNB) {
            return STATUS_SUBMITTED_TO_FCNB;
        }
        if (status == STATUS_AGENT_DENIED || status == 'Denied') {
            return STATUS_AGENT_DENIED;
        }
        if (status == 'Approved') {
            return STATUS_SUBMITTED_TO_FCNB;
        }
        if (status == 'Rejected') {
            return STATUS_AGENT_DENIED;
        }
        if (String.isBlank(status) || !isKnownAgentStatus(status)) {
            if (AGENT_DECISION_STATUSES.contains(arStatus)) {
                return arStatus;
            }
            if (arStatus == 'Agent Requires More Information') {
                return STATUS_AGENT_RMI;
            }
            if (arStatus == 'Denied') {
                return STATUS_AGENT_DENIED;
            }
            if (adminAction == 'Approved') {
                return STATUS_SUBMITTED_TO_FCNB;
            }
            if (adminAction == 'Rejected') {
                return STATUS_AGENT_DENIED;
            }
        }
        return String.isBlank(status) ? STATUS_SUBMITTED_TO_AGENT : status;
    }

    private static Boolean isKnownAgentStatus(String status) {
        return status == STATUS_SUBMITTED ||
            status == STATUS_SUBMITTED_TO_AGENT ||
            status == STATUS_AGENT_RMI ||
            status == STATUS_SUBMITTED_TO_FCNB ||
            status == STATUS_AGENT_DENIED ||
            status == STATUS_INFO_SUBMITTED ||
            status == 'Information Submitted' ||
            status == 'Awaiting Response' ||
            status == 'Approved' ||
            status == 'Rejected' ||
            status == 'Denied' ||
            status == 'Agent Requires More Information' ||
            status == 'Under Review' ||
            status == 'Employer Review Completed';
    }

    private static String resolveAgentWritableStatus(String decisionStatus) {
        Set<String> activeStatusValues = getActivePicklistValues(IndividualApplication.Status);
        if (decisionStatus == STATUS_SUBMITTED_TO_FCNB) {
            return activeStatusValues.contains(STATUS_SUBMITTED_TO_FCNB)
                ? STATUS_SUBMITTED_TO_FCNB
                : (activeStatusValues.contains('Approved') ? 'Approved' : decisionStatus);
        }
        if (decisionStatus == STATUS_AGENT_RMI) {
            return activeStatusValues.contains(STATUS_AGENT_RMI)
                ? STATUS_AGENT_RMI
                : (activeStatusValues.contains('Awaiting Response') ? 'Awaiting Response' : decisionStatus);
        }
        if (decisionStatus == STATUS_AGENT_DENIED) {
            return activeStatusValues.contains(STATUS_AGENT_DENIED)
                ? STATUS_AGENT_DENIED
                : (activeStatusValues.contains('Rejected') ? 'Rejected' : decisionStatus);
        }
        if (decisionStatus == STATUS_SUBMITTED_TO_AGENT) {
            return activeStatusValues.contains(STATUS_SUBMITTED) ? STATUS_SUBMITTED : decisionStatus;
        }
        if (activeStatusValues.contains(decisionStatus)) {
            return decisionStatus;
        }
        return decisionStatus;
    }

    private static String resolveAgentWritableAdminAction(String decisionStatus) {
        if (decisionStatus == STATUS_SUBMITTED_TO_FCNB) {
            return 'Approved';
        }
        if (decisionStatus == STATUS_AGENT_DENIED) {
            return 'Rejected';
        }
        return null;
    }

    private without sharing class AgentReviewDocumentReader {
        public List<DocumentItem> loadUploadedDocuments(Id individualApplicationId, Id parId) {
            List<DocumentItem> docs = new List<DocumentItem>();
            if (individualApplicationId == null && parId == null) {
                return docs;
            }

            List<Application_Document__c> appDocs;
            try {
                if (individualApplicationId != null && parId != null) {
                    appDocs = [
                        SELECT
                            Id,
                            Name,
                            Document_Name__c,
                            File_Name__c,
                            Status__c,
                            Application_Document__c,
                            LastModifiedDate,
                            (
                                SELECT
                                    ContentDocumentId,
                                    ContentDocument.Title,
                                    ContentDocument.FileExtension,
                                    ContentDocument.LatestPublishedVersionId
                                FROM ContentDocumentLinks
                            )
                        FROM Application_Document__c
                        WHERE
                            Individual_Application__c = :individualApplicationId
                            OR Preliminary_Application_Reference__c = :parId
                        ORDER BY Document_Name__c ASC NULLS LAST, LastModifiedDate DESC
                    ];
                } else if (individualApplicationId != null) {
                    appDocs = [
                        SELECT
                            Id,
                            Name,
                            Document_Name__c,
                            File_Name__c,
                            Status__c,
                            Application_Document__c,
                            LastModifiedDate,
                            (
                                SELECT
                                    ContentDocumentId,
                                    ContentDocument.Title,
                                    ContentDocument.FileExtension,
                                    ContentDocument.LatestPublishedVersionId
                                FROM ContentDocumentLinks
                            )
                        FROM Application_Document__c
                        WHERE Individual_Application__c = :individualApplicationId
                        ORDER BY Document_Name__c ASC NULLS LAST, LastModifiedDate DESC
                    ];
                } else {
                    appDocs = [
                        SELECT
                            Id,
                            Name,
                            Document_Name__c,
                            File_Name__c,
                            Status__c,
                            Application_Document__c,
                            LastModifiedDate,
                            (
                                SELECT
                                    ContentDocumentId,
                                    ContentDocument.Title,
                                    ContentDocument.FileExtension,
                                    ContentDocument.LatestPublishedVersionId
                                FROM ContentDocumentLinks
                            )
                        FROM Application_Document__c
                        WHERE Preliminary_Application_Reference__c = :parId
                        ORDER BY Document_Name__c ASC NULLS LAST, LastModifiedDate DESC
                    ];
                }
            } catch (Exception e) {
                return docs;
            }

            Set<Id> seenContentDocumentIds = new Set<Id>();
            for (Application_Document__c appDoc : appDocs) {
                if (appDoc.ContentDocumentLinks == null || appDoc.ContentDocumentLinks.isEmpty()) {
                    continue;
                }
                String docLabel = firstNonBlank(
                    new List<String>{ appDoc.Document_Name__c, appDoc.File_Name__c, appDoc.Name }
                );
                if (
                    String.isBlank(docLabel) ||
                    docLabel.trim().equalsIgnoreCase('Application information')
                ) {
                    continue;
                }

                for (ContentDocumentLink cdl : appDoc.ContentDocumentLinks) {
                    if (
                        cdl.ContentDocumentId == null ||
                        seenContentDocumentIds.contains(cdl.ContentDocumentId)
                    ) {
                        continue;
                    }
                    seenContentDocumentIds.add(cdl.ContentDocumentId);

                    String title = cdl.ContentDocument != null ? cdl.ContentDocument.Title : null;
                    String extension = cdl.ContentDocument != null
                        ? cdl.ContentDocument.FileExtension
                        : null;
                    String fileName = title;
                    if (
                        !String.isBlank(extension) &&
                        !String.isBlank(title) &&
                        !title.toLowerCase().endsWith('.' + extension.toLowerCase())
                    ) {
                        fileName = title + '.' + extension;
                    } else if (String.isBlank(fileName)) {
                        fileName = appDoc.File_Name__c;
                    }

                    Id versionId = cdl.ContentDocument != null
                        ? cdl.ContentDocument.LatestPublishedVersionId
                        : null;

                    DocumentItem item = new DocumentItem(docLabel, true);
                    item.key = String.valueOf(cdl.ContentDocumentId);
                    item.applicationDocumentId = appDoc.Id;
                    item.contentDocumentId = cdl.ContentDocumentId;
                    item.contentVersionId = versionId;
                    item.fileName = fileName;
                    item.downloadUrl =
                        '/sfc/servlet.shepherd/document/download/' + cdl.ContentDocumentId;
                    item.previewUrl = item.downloadUrl;
                    docs.add(item);
                }
            }
            return docs;
        }
    }

    private static void populateInsurerReviewSummary(ApplicationRow row, IndividualApplication ia) {
        if (row == null || ia == null || ia.SavedApplicationRefId == null) {
            return;
        }
        try {
            PreliminaryApplicationRef par = new InsurerReviewSummaryReader()
                .getParForSummary(ia.SavedApplicationRefId);
            if (par == null) {
                return;
            }
            Map<String, Object> formData = new Map<String, Object>();
            putParsedSection(formData, 'ApplicantInformation', par.ApplicantInformation_JSON__c);
            putParsedSection(formData, 'LicenceType', par.LicenceType_JSON__c);
            putParsedSection(formData, 'AgencyEmployment', par.AgencyEmployment_JSON__c);
            putParsedSection(formData, 'SponsoringInsurer_Supervisor', par.SponsoringInsurer_Supervisor_JSON__c);
            putParsedSection(formData, 'Trust Account_Employment', par.Trust_Account_Employment_JSON__c);
            putParsedSection(formData, 'Prior Insurance Experience', par.Prior_Insurance_Experience_JSON__c);
            putParsedSection(formData, 'Regulatory_Suitability', par.Regulatory_Suitability_JSON__c);
            putParsedSection(formData, 'Employment_Declarations', par.Employment_Declarations_JSON__c);
            putParsedSection(formData, 'Other_Business_Education', par.Other_Business_Education_JSON__c);
            putParsedSection(formData, 'Additional Information', par.Additional_Information_JSON__c);

            if (!formData.isEmpty()) {
                row.reviewFormDataJson = JSON.serialize(formData);
            }
            row.reviewLabelDataJson = new InsurerReviewSummaryReader().getReviewLabelJson();
        } catch (Exception e) {
            // Review summary is optional UI
        }
    }

    private without sharing class InsurerReviewSummaryReader {
        public PreliminaryApplicationRef getParForSummary(Id parId) {
            if (parId == null) {
                return null;
            }
            List<PreliminaryApplicationRef> rows = [
                SELECT
                    Id,
                    ApplicantInformation_JSON__c,
                    LicenceType_JSON__c,
                    AgencyEmployment_JSON__c,
                    SponsoringInsurer_Supervisor_JSON__c,
                    Trust_Account_Employment_JSON__c,
                    Prior_Insurance_Experience_JSON__c,
                    Regulatory_Suitability_JSON__c,
                    Employment_Declarations_JSON__c,
                    Other_Business_Education_JSON__c,
                    Additional_Information_JSON__c
                FROM PreliminaryApplicationRef
                WHERE Id = :parId
                LIMIT 1
            ];
            return rows.isEmpty() ? null : rows[0];
        }

        public String getReviewLabelJson() {
            List<Form_Review_Config__mdt> configs = [
                SELECT Label_JSON__c
                FROM Form_Review_Config__mdt
                WHERE DeveloperName = 'CNB_IndividualInsuranceAgentLicForm'
                LIMIT 1
            ];
            if (configs.isEmpty() || String.isBlank(configs[0].Label_JSON__c)) {
                return null;
            }
            return configs[0].Label_JSON__c;
        }
    }

    private static void populateAgentReviewSummary(ApplicationRow row, IndividualApplication ia) {
        if (row == null || ia == null || ia.SavedApplicationRefId == null) {
            return;
        }
        try {
            PreliminaryApplicationRef par = new AgentReviewSummaryReader()
                .getParForSummary(ia.SavedApplicationRefId);
            if (par == null) {
                return;
            }
            Map<String, Object> formData = new Map<String, Object>();
            putParsedSection(formData, 'Licence', par.Licence_Json__c);
            putParsedSection(formData, 'ApplicantDetails', par.Applicant_Details_json__c);
            putParsedSection(formData, 'Employment Details', par.Employement_json__c);
            putParsedSection(formData, 'RegulatoryLicensingDetails', par.Regulatory_licensing_json__c);
            putParsedSection(formData, 'ProceedingsJudgments', par.Proceedings_Judgments_json__c);
            putParsedSection(formData, 'AdditionalInformation', par.Additional_Info_json__c);
            putParsedSection(formData, 'Expedited Service', par.Expedited_Service_json__c);

            if (!formData.isEmpty()) {
                row.reviewFormDataJson = JSON.serialize(formData);
            }

            row.reviewLabelDataJson = new AgentReviewSummaryReader().getReviewLabelJson();
        } catch (Exception e) {
            // Review summary is optional UI
        }
    }

    private static void putParsedSection(Map<String, Object> formData, String sectionKey, String jsonStr) {
        if (formData == null || String.isBlank(sectionKey) || String.isBlank(jsonStr)) {
            return;
        }
        try {
            Object parsed = JSON.deserializeUntyped(jsonStr);
            if (parsed != null) {
                formData.put(sectionKey, parsed);
            }
        } catch (Exception e) {
            // skip invalid section JSON
        }
    }

    private without sharing class AgentReviewSummaryReader {
        public PreliminaryApplicationRef getParForSummary(Id parId) {
            if (parId == null) {
                return null;
            }
            List<PreliminaryApplicationRef> rows = [
                SELECT
                    Id,
                    Licence_Json__c,
                    Applicant_Details_json__c,
                    Employement_json__c,
                    Regulatory_licensing_json__c,
                    Proceedings_Judgments_json__c,
                    Additional_Info_json__c,
                    Expedited_Service_json__c
                FROM PreliminaryApplicationRef
                WHERE Id = :parId
                LIMIT 1
            ];
            return rows.isEmpty() ? null : rows[0];
        }

        public String getReviewLabelJson() {
            List<Form_Review_Config__mdt> configs = [
                SELECT Label_JSON__c
                FROM Form_Review_Config__mdt
                WHERE DeveloperName = 'FCNBRealStateFCNB'
                LIMIT 1
            ];
            if (configs.isEmpty() || String.isBlank(configs[0].Label_JSON__c)) {
                return null;
            }
            return configs[0].Label_JSON__c;
        }
    }

    private static String resolveDisplayStatus(String status, String adminAction, String siStatus) {
        if (status == STATUS_INFO_SUBMITTED || status == 'Information Submitted') {
            return STATUS_INFO_SUBMITTED;
        }
        if (status == STATUS_SUBMITTED || status == STATUS_SUBMITTED_TO_INSURER) {
            return STATUS_SUBMITTED_TO_INSURER;
        }
        if (
            status == STATUS_RMI ||
            status == 'Awaiting Response' ||
            status == 'Insurer Requires More Information'
        ) {
            return STATUS_RMI;
        }
        if (status == STATUS_APPROVED) {
            return STATUS_APPROVED;
        }
        if (status == STATUS_DENIED_BY_INSURER || status == 'Not Sponsored') {
            return STATUS_DENIED_BY_INSURER;
        }
        if (status == 'Approved' || status == 'Employer Review Completed') {
            return STATUS_APPROVED;
        }
        if (status == 'Rejected') {
            return STATUS_DENIED_BY_INSURER;
        }
        if (String.isBlank(status) || !isKnownInsurerStatus(status)) {
            if (INSURER_DECISION_STATUSES.contains(siStatus)) {
                return siStatus;
            }
            if (siStatus == 'Insurer Requires More Information') {
                return STATUS_RMI;
            }
            if (siStatus == 'Not Sponsored') {
                return STATUS_DENIED_BY_INSURER;
            }
            if (adminAction == 'Approved' || adminAction == STATUS_APPROVED) {
                return STATUS_APPROVED;
            }
            if (adminAction == 'Rejected' || adminAction == STATUS_DENIED_BY_INSURER || adminAction == 'Not Sponsored') {
                return STATUS_DENIED_BY_INSURER;
            }
        }
        return String.isBlank(status) ? STATUS_SUBMITTED_TO_INSURER : status;
    }

    private static Boolean isKnownInsurerStatus(String status) {
        return status == STATUS_SUBMITTED ||
            status == STATUS_SUBMITTED_TO_INSURER ||
            status == STATUS_RMI ||
            status == STATUS_APPROVED ||
            status == STATUS_DENIED_BY_INSURER ||
            status == STATUS_INFO_SUBMITTED ||
            status == 'Awaiting Response' ||
            status == 'Approved' ||
            status == 'Rejected' ||
            status == 'Not Sponsored' ||
            status == 'Insurer Requires More Information' ||
            status == 'Employer Review Completed' ||
            status == 'Under Review';
    }

    private static String resolveWritableStatus(String decisionStatus) {
        Set<String> activeStatusValues = getActivePicklistValues(IndividualApplication.Status);
        if (decisionStatus == STATUS_APPROVED) {
            return activeStatusValues.contains(STATUS_APPROVED)
                ? STATUS_APPROVED
                : (activeStatusValues.contains('Approved') ? 'Approved' : decisionStatus);
        }
        if (decisionStatus == STATUS_DENIED_BY_INSURER || decisionStatus == 'Not Sponsored') {
            return activeStatusValues.contains(STATUS_DENIED_BY_INSURER)
                ? STATUS_DENIED_BY_INSURER
                : (activeStatusValues.contains('Rejected') ? 'Rejected' : decisionStatus);
        }
        if (decisionStatus == STATUS_RMI || decisionStatus == 'Insurer Requires More Information') {
            return activeStatusValues.contains(STATUS_RMI)
                ? STATUS_RMI
                : (activeStatusValues.contains('Awaiting Response') ? 'Awaiting Response' : decisionStatus);
        }
        if (decisionStatus == STATUS_SUBMITTED_TO_INSURER) {
            return activeStatusValues.contains(STATUS_SUBMITTED) ? STATUS_SUBMITTED : decisionStatus;
        }
        if (activeStatusValues.contains(decisionStatus)) {
            return decisionStatus;
        }
        return decisionStatus;
    }

    private static String resolveWritableAdminAction(String decisionStatus) {
        if (decisionStatus == STATUS_APPROVED) {
            return 'Approved';
        }
        if (decisionStatus == STATUS_DENIED_BY_INSURER || decisionStatus == 'Not Sponsored') {
            return 'Rejected';
        }
        return null;
    }

    private static Set<String> getActivePicklistValues(Schema.SObjectField fieldToken) {
        Set<String> activeValues = new Set<String>();
        for (Schema.PicklistEntry pe : fieldToken.getDescribe().getPicklistValues()) {
            if (pe.isActive()) {
                activeValues.add(pe.getValue());
            }
        }
        return activeValues;
    }

    private static String buildLicenceLabel(Map<String, Object> licenceJson) {
        String licType = stringVal(licenceJson.get('LI_LicType'));
        String includes = stringVal(licenceJson.get('LI_Includes'));
        if (String.isBlank(licType)) {
            return null;
        }
        if (!String.isBlank(includes)) {
            return licType + ' (Includes ' + includes.replace('Accident & Sickness', 'A & S') + ')';
        }
        return licType;
    }

    private static Boolean classMatches(String applied, String licensed) {
        if (String.isBlank(applied) || String.isBlank(licensed)) {
            return true;
        }
        String a = applied.toLowerCase().replace('&', 'and');
        String l = licensed.toLowerCase().replace('&', 'and');
        return a.contains('life') && l.contains('life');
    }

    private static String resolveInsurerName(List<ApplicationRow> rows) {
        for (ApplicationRow r : rows) {
            if (!String.isBlank(r.insurerName)) {
                return r.insurerName;
            }
        }
        return 'Sponsoring Insurer';
    }

    private static Map<String, Object> parseJsonMap(String jsonStr) {
        if (String.isBlank(jsonStr)) {
            return new Map<String, Object>();
        }
        try {
            Object o = JSON.deserializeUntyped(jsonStr);
            if (o instanceof Map<String, Object>) {
                return (Map<String, Object>) o;
            }
        } catch (Exception e) {
            return new Map<String, Object>();
        }
        return new Map<String, Object>();
    }

    private static Map<String, Object> extractNested(Map<String, Object> root, String key) {
        if (root == null || !root.containsKey(key)) {
            return new Map<String, Object>();
        }
        Object v = root.get(key);
        if (v instanceof Map<String, Object>) {
            return (Map<String, Object>) v;
        }
        return new Map<String, Object>();
    }

    private static String stringVal(Object o) {
        return o == null ? null : String.valueOf(o);
    }

    private static String firstNonBlank(List<String> vals) {
        for (String v : vals) {
            if (!String.isBlank(v) && v != 'null') {
                return v;
            }
        }
        return null;
    }

    private static String joinName(String first, String last) {
        List<String> parts = new List<String>();
        if (!String.isBlank(first)) {
            parts.add(first);
        }
        if (!String.isBlank(last)) {
            parts.add(last);
        }
        return parts.isEmpty() ? null : String.join(parts, ' ');
    }

    private static String formatDateValue(String raw) {
        if (String.isBlank(raw)) {
            return null;
        }
        try {
            Date d = Date.valueOf(raw.left(10));
            Datetime dt = Datetime.newInstance(d.year(), d.month(), d.day());
            return dt.format('dd MMM yyyy');
        } catch (Exception e) {
            return raw;
        }
    }

    public class QueueResult {
        @AuraEnabled
        public List<ApplicationRow> applications;
        @AuraEnabled
        public String insurerName;
        @AuraEnabled
        public String reviewerName;
    }

    public class ApplicationRow {
        @AuraEnabled
        public Id id;
        @AuraEnabled
        public String applicationNumber;
        @AuraEnabled
        public String transactionId;
        @AuraEnabled
        public String applicantName;
        @AuraEnabled
        public String dateOfBirth;
        @AuraEnabled
        public String ciprNumber;
        @AuraEnabled
        public String email;
        @AuraEnabled
        public String phone;
        @AuraEnabled
        public String licenceType;
        @AuraEnabled
        public String term;
        @AuraEnabled
        public String classAppliedFor;
        @AuraEnabled
        public String insurerLicensedFor;
        @AuraEnabled
        public Boolean classMatches;
        @AuraEnabled
        public String agency;
        @AuraEnabled
        public String supervisor;
        @AuraEnabled
        public String submittedOn;
        @AuraEnabled
        public String status;
        @AuraEnabled
        public String rawStatus;
        @AuraEnabled
        public String insurerDecision;
        @AuraEnabled
        public String comments;
        @AuraEnabled
        public String insurerName;
        @AuraEnabled
        public List<DocumentItem> documents;
        @AuraEnabled
        public Boolean canDecide;
        @AuraEnabled
        public String reviewFormDataJson;
        @AuraEnabled
        public String reviewLabelDataJson;
    }

    public class DocumentItem {
        @AuraEnabled
        public String key;
        @AuraEnabled
        public String label;
        @AuraEnabled
        public Boolean received;
        @AuraEnabled
        public Id applicationDocumentId;
        @AuraEnabled
        public Id contentDocumentId;
        @AuraEnabled
        public Id contentVersionId;
        @AuraEnabled
        public String fileName;
        @AuraEnabled
        public String downloadUrl;
        @AuraEnabled
        public String previewUrl;

        public DocumentItem(String label, Boolean received) {
            this.label = label;
            this.received = received;
            this.key = label;
        }
    }
}