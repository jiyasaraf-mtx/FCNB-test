/**
 * AVR Pension Portal – AVR Filing list and CRUD helpers.
 */
public without sharing class AVR_FilingCtrl {
    private static final String DEFAULT_FILING_TYPE = 'AVR';

    public class FilingDTO {
        @AuraEnabled public Id id;
        @AuraEnabled public String name;
        @AuraEnabled public String filingType;
        @AuraEnabled public String reportingYear;
        @AuraEnabled public String planName;
        @AuraEnabled public String planRegistrationNumber;
        @AuraEnabled public String firstName;
        @AuraEnabled public String lastName;
        @AuraEnabled public String email;
        @AuraEnabled public String phone;
        @AuraEnabled public String registrationNumber;
        @AuraEnabled public Date valuationDate;
        @AuraEnabled public Date filingDueDate;
        @AuraEnabled public String actuaryName;
        @AuraEnabled public String actuaryFirm;
        @AuraEnabled public String notes;
        @AuraEnabled public String status;
        @AuraEnabled public String rmiStatus;
        @AuraEnabled public String rmiComments;
        @AuraEnabled public Boolean attestationConfirmed;
        @AuraEnabled public String filingDueDateDisplay;
        @AuraEnabled public String valuationDateDisplay;
    }

    public class FilingPageResult {
        @AuraEnabled public List<FilingDTO> filings = new List<FilingDTO>();
        @AuraEnabled public Integer avrFilingCount = 0;
        @AuraEnabled public String reportingYearMetric;
        @AuraEnabled public String currentStatusMetric;
        @AuraEnabled public String filingDueDateMetric;
        @AuraEnabled public String accountName;
        @AuraEnabled public Id accountId;
        @AuraEnabled public Id contactId;
    }

    @AuraEnabled(cacheable=false)
    public static FilingPageResult getFilings() {
        FilingPageResult result = new FilingPageResult();
        Id contactId = resolveContactId();
        Id accountId = resolveAccountId(contactId);
        result.contactId = contactId;
        result.accountId = accountId;
        result.accountName = resolveAccountName(accountId);

        List<AVR_Filing__c> rows;
        if (contactId == null && accountId == null) {
            rows = [
                SELECT
                    Id,
                    Name,
                    Filing_Type__c,
                    Reporting_Year__c,
                    Plan_Name__c,
                    Plan_Registration_Number__c,
                    First_Name__c,
                    Last_Name__c,
                    Email__c,
                    Phone__c,
                    Registration_Number__c,
                    Valuation_Date__c,
                    Filing_Due_Date__c,
                    Actuary_Name__c,
                    Actuary_Firm__c,
                    Notes__c,
                    Status__c,
                    RMI_Status__c,
                    RMI_Comments__c,
                    Attestation_Confirmed__c
                FROM AVR_Filing__c
                ORDER BY Reporting_Year__c DESC NULLS LAST, CreatedDate DESC
                LIMIT 200
            ];
        } else {
            rows = [
                SELECT
                    Id,
                    Name,
                    Filing_Type__c,
                    Reporting_Year__c,
                    Plan_Name__c,
                    Plan_Registration_Number__c,
                    First_Name__c,
                    Last_Name__c,
                    Email__c,
                    Phone__c,
                    Registration_Number__c,
                    Valuation_Date__c,
                    Filing_Due_Date__c,
                    Actuary_Name__c,
                    Actuary_Firm__c,
                    Notes__c,
                    Status__c,
                    RMI_Status__c,
                    RMI_Comments__c,
                    Attestation_Confirmed__c
                FROM AVR_Filing__c
                WHERE Contact__c = :contactId OR Account__c = :accountId
                ORDER BY Reporting_Year__c DESC NULLS LAST, CreatedDate DESC
                LIMIT 200
            ];
        }

        for (AVR_Filing__c row : rows) {
            result.filings.add(toDto(row));
        }
        result.avrFilingCount = result.filings.size();
        if (!result.filings.isEmpty()) {
            FilingDTO first = result.filings[0];
            result.reportingYearMetric = first.reportingYear;
            result.currentStatusMetric = first.status;
            result.filingDueDateMetric = first.filingDueDateDisplay;
        }
        return result;
    }

    @AuraEnabled
    public static FilingDTO getFiling(Id filingId) {
        if (filingId == null) {
            throw new AuraHandledException('Filing Id is required.');
        }
        AVR_Filing__c row = [
            SELECT
                Id,
                Name,
                Filing_Type__c,
                Reporting_Year__c,
                Plan_Name__c,
                Plan_Registration_Number__c,
                First_Name__c,
                Last_Name__c,
                Email__c,
                Phone__c,
                Registration_Number__c,
                Valuation_Date__c,
                Filing_Due_Date__c,
                Actuary_Name__c,
                Actuary_Firm__c,
                Notes__c,
                Status__c,
                RMI_Status__c,
                RMI_Comments__c,
                Attestation_Confirmed__c
            FROM AVR_Filing__c
            WHERE Id = :filingId
            LIMIT 1
        ];
        return toDto(row);
    }

    @AuraEnabled
    public static FilingDTO saveFiling(String payloadJson) {
        if (String.isBlank(payloadJson)) {
            throw new AuraHandledException('Filing payload is required.');
        }
        Map<String, Object> payload = (Map<String, Object>) JSON.deserializeUntyped(payloadJson);
        Id filingId = payload.get('id') == null ? null : (Id) String.valueOf(payload.get('id'));

        AVR_Filing__c row;
        if (filingId != null) {
            row = [
                SELECT
                    Id,
                    Filing_Type__c,
                    Reporting_Year__c,
                    Plan_Name__c,
                    Plan_Registration_Number__c,
                    First_Name__c,
                    Last_Name__c,
                    Email__c,
                    Phone__c,
                    Registration_Number__c,
                    Actuary_Name__c,
                    Actuary_Firm__c,
                    Notes__c,
                    Status__c,
                    RMI_Status__c,
                    RMI_Comments__c,
                    Attestation_Confirmed__c,
                    Valuation_Date__c,
                    Filing_Due_Date__c
                FROM AVR_Filing__c
                WHERE Id = :filingId
                LIMIT 1
            ];
        } else {
            row = new AVR_Filing__c();
            row.Contact__c = resolveContactId();
            row.Account__c = resolveAccountId(row.Contact__c);
            if (String.isBlank((String) payload.get('filingType'))) {
                row.Filing_Type__c = DEFAULT_FILING_TYPE;
            }
            if (String.isBlank((String) payload.get('status'))) {
                row.Status__c = 'Draft';
            }
        }

        row.Filing_Type__c = asString(payload.get('filingType'), row.Filing_Type__c);
        row.Reporting_Year__c = asString(payload.get('reportingYear'), row.Reporting_Year__c);
        row.Plan_Name__c = asString(payload.get('planName'), row.Plan_Name__c);
        row.Plan_Registration_Number__c = asString(
            payload.get('planRegistrationNumber'),
            row.Plan_Registration_Number__c
        );
        row.First_Name__c = asString(payload.get('firstName'), row.First_Name__c);
        row.Last_Name__c = asString(payload.get('lastName'), row.Last_Name__c);
        row.Email__c = asString(payload.get('email'), row.Email__c);
        row.Phone__c = asString(payload.get('phone'), row.Phone__c);
        row.Registration_Number__c = asString(payload.get('registrationNumber'), row.Registration_Number__c);
        row.Actuary_Name__c = asString(payload.get('actuaryName'), row.Actuary_Name__c);
        row.Actuary_Firm__c = asString(payload.get('actuaryFirm'), row.Actuary_Firm__c);
        row.Notes__c = asString(payload.get('notes'), row.Notes__c);
        row.Status__c = asString(payload.get('status'), row.Status__c);
        row.RMI_Status__c = asString(payload.get('rmiStatus'), row.RMI_Status__c);
        if (payload.containsKey('attestationConfirmed')) {
            row.Attestation_Confirmed__c = payload.get('attestationConfirmed') == true;
        }
        row.Valuation_Date__c = asDate(payload.get('valuationDate'), row.Valuation_Date__c);
        row.Filing_Due_Date__c = asDate(payload.get('filingDueDate'), row.Filing_Due_Date__c);

        upsert row;
        return getFiling(row.Id);
    }

    @AuraEnabled
    public static FilingDTO submitFiling(Id filingId) {
        if (filingId == null) {
            throw new AuraHandledException('Filing Id is required.');
        }
        AVR_Filing__c row = [
            SELECT Id, Status__c, Attestation_Confirmed__c
            FROM AVR_Filing__c
            WHERE Id = :filingId
            LIMIT 1
        ];
        if (row.Attestation_Confirmed__c != true) {
            throw new AuraHandledException('Attestation must be confirmed before submit.');
        }
        row.Status__c = 'Submitted';
        update row;
        return getFiling(row.Id);
    }

    /**
     * Portal RMI response: optional comments + optional files (already linked via lightning-file-upload).
     * Sets Status to RMI Submitted.
     */
    @AuraEnabled
    public static FilingDTO submitRmiResponse(Id filingId, String comments) {
        if (filingId == null) {
            throw new AuraHandledException('Filing Id is required.');
        }
        AVR_Filing__c row = [
            SELECT Id, Status__c, RMI_Comments__c
            FROM AVR_Filing__c
            WHERE Id = :filingId
            LIMIT 1
        ];
        if (row.Status__c != 'More Information Required') {
            throw new AuraHandledException(
                'RMI response is only allowed when status is More Information Required.'
            );
        }
        row.RMI_Comments__c = comments;
        row.Status__c = 'RMI Submitted';
        row.RMI_Status__c = 'RMI Submitted';
        update row;

        // Ensure portal users can see any newly uploaded files
        List<ContentDocumentLink> links = [
            SELECT Id, Visibility
            FROM ContentDocumentLink
            WHERE LinkedEntityId = :filingId AND Visibility != 'AllUsers'
        ];
        if (!links.isEmpty()) {
            for (ContentDocumentLink link : links) {
                link.Visibility = 'AllUsers';
            }
            update links;
        }
        return getFiling(row.Id);
    }

    private static FilingDTO toDto(AVR_Filing__c row) {
        FilingDTO dto = new FilingDTO();
        dto.id = row.Id;
        dto.name = row.Name;
        dto.filingType = row.Filing_Type__c;
        dto.reportingYear = row.Reporting_Year__c;
        dto.planName = row.Plan_Name__c;
        dto.planRegistrationNumber = row.Plan_Registration_Number__c;
        dto.firstName = row.First_Name__c;
        dto.lastName = row.Last_Name__c;
        dto.email = row.Email__c;
        dto.phone = row.Phone__c;
        dto.registrationNumber = row.Registration_Number__c;
        dto.valuationDate = row.Valuation_Date__c;
        dto.filingDueDate = row.Filing_Due_Date__c;
        dto.actuaryName = row.Actuary_Name__c;
        dto.actuaryFirm = row.Actuary_Firm__c;
        dto.notes = row.Notes__c;
        dto.status = row.Status__c;
        dto.rmiStatus = row.RMI_Status__c;
        dto.rmiComments = row.RMI_Comments__c;
        dto.attestationConfirmed = row.Attestation_Confirmed__c == true;
        dto.filingDueDateDisplay = formatDate(row.Filing_Due_Date__c);
        dto.valuationDateDisplay = formatDate(row.Valuation_Date__c);
        return dto;
    }

    private static String formatDate(Date d) {
        if (d == null) {
            return '';
        }
        Datetime dt = Datetime.newInstance(d.year(), d.month(), d.day());
        return dt.format('dd MMM yyyy');
    }

    private static String asString(Object value, String fallback) {
        if (value == null) {
            return fallback;
        }
        String s = String.valueOf(value).trim();
        return String.isBlank(s) ? fallback : s;
    }

    private static Date asDate(Object value, Date fallback) {
        if (value == null || String.isBlank(String.valueOf(value))) {
            return fallback;
        }
        try {
            return Date.valueOf(String.valueOf(value));
        } catch (Exception e) {
            return fallback;
        }
    }

    private static Id resolveContactId() {
        List<User> users = [
            SELECT ContactId
            FROM User
            WHERE Id = :UserInfo.getUserId()
            LIMIT 1
        ];
        return users.isEmpty() ? null : users[0].ContactId;
    }

    private static Id resolveAccountId(Id contactId) {
        if (contactId == null) {
            return null;
        }
        List<Contact> contacts = [
            SELECT AccountId
            FROM Contact
            WHERE Id = :contactId
            LIMIT 1
        ];
        return contacts.isEmpty() ? null : contacts[0].AccountId;
    }

    private static String resolveAccountName(Id accountId) {
        if (accountId == null) {
            return null;
        }
        List<Account> accounts = [
            SELECT Name
            FROM Account
            WHERE Id = :accountId
            LIMIT 1
        ];
        return accounts.isEmpty() ? null : accounts[0].Name;
    }
}