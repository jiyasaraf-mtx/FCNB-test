/**
 * OmniStudio Callable for AVR Filing init: load ContextId, existing Draft, or create Draft.
 */
global without sharing class AVR_FilingOmniCtrl implements Callable {
    global Object call(String action, Map<String, Object> args) {
        Map<String, Object> input = (Map<String, Object>) args.get('input');
        Map<String, Object> output = (Map<String, Object>) args.get('output');
        Map<String, Object> options = (Map<String, Object>) args.get('options');
        return invokeMethod(action, input, output, options);
    }

    private Boolean invokeMethod(
        String methodName,
        Map<String, Object> inputMap,
        Map<String, Object> outMap,
        Map<String, Object> options
    ) {
        if (methodName == 'initFiling') {
            initFiling(inputMap, outMap);
            return true;
        }
        if (methodName == 'submitFiling') {
            submitFiling(inputMap, outMap);
            return true;
        }
        return false;
    }

    private static void initFiling(Map<String, Object> inputMap, Map<String, Object> outMap) {
        if (inputMap == null) {
            inputMap = new Map<String, Object>();
        }

        Id contactId = resolveContactId();
        Id accountId = resolveAccountId(contactId);
        String contextId = firstNonBlank(
            asString(inputMap.get('ContextId')),
            asString(inputMap.get('c__ContextId')),
            asString(inputMap.get('AVRFilingId'))
        );

        AVR_Filing__c filing;
        if (String.isNotBlank(contextId)) {
            filing = queryFiling(contextId);
        }
        if (filing == null) {
            filing = findExistingDraft(contactId);
        }

        if (filing == null) {
            User u = currentUser();
            filing = new AVR_Filing__c(
                Filing_Type__c = 'AVR',
                Status__c = 'Draft',
                Contact__c = contactId,
                Account__c = accountId,
                First_Name__c = u != null ? u.FirstName : null,
                Last_Name__c = u != null ? u.LastName : null,
                Email__c = u != null ? u.Email : null
            );
            insert filing;
            filing = queryFiling(filing.Id);
        } else {
            // Portal users must own the Draft to upload Files (OWD Private).
            Boolean needsStamp = ensurePortalAccess(filing, contactId, accountId);
            if (needsStamp) {
                update filing;
                filing = queryFiling(filing.Id);
            }
        }

        putFilingToOutput(filing, outMap);
    }

    private static AVR_Filing__c findExistingDraft(Id contactId) {
        Id userId = UserInfo.getUserId();
        List<AVR_Filing__c> drafts;
        if (contactId != null) {
            drafts = [
                SELECT
                    Id,
                    Name,
                    Filing_Type__c,
                    Reporting_Year__c,
                    Plan_Name__c,
                    Plan_Registration_Number__c,
                    Plan__c,
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
                    Attestation_Confirmed__c,
                    Contact__c,
                    Account__c,
                    OwnerId
                FROM AVR_Filing__c
                WHERE Status__c = 'Draft'
                AND (
                    Contact__c = :contactId
                    OR CreatedById = :userId
                    OR OwnerId = :userId
                )
                ORDER BY LastModifiedDate DESC
                LIMIT 1
            ];
        } else {
            drafts = [
                SELECT
                    Id,
                    Name,
                    Filing_Type__c,
                    Reporting_Year__c,
                    Plan_Name__c,
                    Plan_Registration_Number__c,
                    Plan__c,
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
                    Attestation_Confirmed__c,
                    Contact__c,
                    Account__c,
                    OwnerId
                FROM AVR_Filing__c
                WHERE Status__c = 'Draft'
                AND (CreatedById = :userId OR OwnerId = :userId)
                ORDER BY LastModifiedDate DESC
                LIMIT 1
            ];
        }
        return drafts.isEmpty() ? null : drafts[0];
    }

    private static void submitFiling(Map<String, Object> inputMap, Map<String, Object> outMap) {
        if (inputMap == null) {
            inputMap = new Map<String, Object>();
        }
        String filingId = firstNonBlank(
            asString(inputMap.get('ContextId')),
            asString(inputMap.get('c__ContextId')),
            asString(inputMap.get('AVRFilingId'))
        );
        if (String.isBlank(filingId)) {
            throw new AuraHandledException('AVR Filing Id is required to submit.');
        }

        AVR_Filing__c filing = queryFiling(filingId);
        if (filing == null) {
            throw new AuraHandledException('AVR Filing not found.');
        }
        Boolean attested = isTruthy(inputMap.get('AttestationConfirmed'))
            || isTruthy(inputMap.get('ReviewSummary:AttestationConfirmed'))
            || isTruthy(inputMap.get('ReviewSummaryAttestation'))
            || (inputMap.get('ReviewSummary') instanceof Map<String, Object>
                && isTruthy(((Map<String, Object>) inputMap.get('ReviewSummary')).get('AttestationConfirmed')))
            || filing.Attestation_Confirmed__c == true;
        if (!attested) {
            throw new AuraHandledException('Attestation must be confirmed before submit.');
        }
        filing.Status__c = 'Submitted';
        filing.Attestation_Confirmed__c = true;

        String planId = firstNonBlank(
            asString(inputMap.get('PlanId')),
            asString(nestedValue(inputMap, 'FilingHeader', 'PlanLookup-Block', 'Id')),
            asString(nestedValue(inputMap, 'FilingHeader', 'PlanLookup', 'Id'))
        );
        if (String.isNotBlank(planId)) {
            filing.Plan__c = planId;
        }
        String planName = firstNonBlank(
            asString(inputMap.get('PlanName')),
            asString(nestedValue(inputMap, 'FilingHeader', 'PlanLookup-Block', 'PlanName')),
            asString(nestedValue(inputMap, 'FilingHeader', 'PlanName'))
        );
        if (String.isNotBlank(planName)) {
            filing.Plan_Name__c = planName;
        }
        String planReg = firstNonBlank(
            asString(inputMap.get('PlanRegistrationNumber')),
            asString(nestedValue(inputMap, 'FilingHeader', 'PlanLookup-Block', 'PlanRegistrationNumber')),
            asString(nestedValue(inputMap, 'FilingHeader', 'PlanRegistrationNumber'))
        );
        if (String.isNotBlank(planReg)) {
            filing.Plan_Registration_Number__c = planReg;
            filing.Registration_Number__c = planReg;
        }

        update filing;
        filing = queryFiling(filing.Id);
        putFilingToOutput(filing, outMap);
        outMap.put('Submitted', true);
        outMap.put('FilingNumber', filing.Name);
        outMap.put('Status', filing.Status__c);
    }

    private static void putFilingToOutput(AVR_Filing__c filing, Map<String, Object> outMap) {
        outMap.put('ContextId', filing.Id);
        outMap.put('AVRFilingId', filing.Id);
        outMap.put('FilingNumber', filing.Name);
        outMap.put('Status', filing.Status__c);
        outMap.put('ContactId', filing.Contact__c);
        outMap.put('AccountId', filing.Account__c);
        outMap.put('PlanId', filing.Plan__c);

        Map<String, Object> header = new Map<String, Object>{
            'FilingType' => blankIfNull(filing.Filing_Type__c),
            'ReportingYear' => blankIfNull(filing.Reporting_Year__c),
            'PlanName' => blankIfNull(filing.Plan_Name__c),
            'PlanRegistrationNumber' => blankIfNull(filing.Plan_Registration_Number__c),
            'PlanId' => filing.Plan__c,
            'FirstName' => blankIfNull(filing.First_Name__c),
            'LastName' => blankIfNull(filing.Last_Name__c),
            'Email' => blankIfNull(filing.Email__c),
            'Phone' => blankIfNull(filing.Phone__c)
        };
        // Only return plan-data keys when values exist so Omni does not keep stale defaults.
        Map<String, Object> planData = new Map<String, Object>();
        putIfHasText(planData, 'RegistrationNumber', filing.Registration_Number__c);
        putIfHasText(planData, 'PlanRegistrationNumber', filing.Plan_Registration_Number__c);
        putIfHasText(planData, 'PlanDataRegistrationNumber', filing.Plan_Registration_Number__c);
        if (filing.Valuation_Date__c != null) {
            planData.put('ValuationDate', filing.Valuation_Date__c);
        } else {
            planData.put('ValuationDate', '');
        }
        if (filing.Filing_Due_Date__c != null) {
            planData.put('FilingDueDate', filing.Filing_Due_Date__c);
        } else {
            planData.put('FilingDueDate', '');
        }
        planData.put('ActuaryName', blankIfNull(filing.Actuary_Name__c));
        planData.put('ActuaryFirm', blankIfNull(filing.Actuary_Firm__c));
        planData.put('Notes', blankIfNull(filing.Notes__c));

        Map<String, Object> review = new Map<String, Object>{
            'AttestationConfirmed' => filing.Attestation_Confirmed__c == true
        };

        outMap.put('FilingHeader', header);
        outMap.put('PlanData', planData);
        outMap.put('ReviewSummary', review);
    }

    private static void putIfHasText(Map<String, Object> target, String key, String value) {
        if (String.isNotBlank(value)) {
            target.put(key, value);
        } else {
            target.put(key, '');
        }
    }

    private static String blankIfNull(String value) {
        return value == null ? '' : value;
    }

    private static AVR_Filing__c queryFiling(Id filingId) {
        List<AVR_Filing__c> rows = [
            SELECT
                Id,
                Name,
                Filing_Type__c,
                Reporting_Year__c,
                Plan_Name__c,
                Plan_Registration_Number__c,
                Plan__c,
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
                Attestation_Confirmed__c,
                Contact__c,
                Account__c,
                OwnerId
            FROM AVR_Filing__c
            WHERE Id = :filingId
            LIMIT 1
        ];
        return rows.isEmpty() ? null : rows[0];
    }


    /**
     * Ensure Contact/Account are stamped and Owner is the running user so
     * Experience Cloud users can attach ContentDocuments (Private OWD).
     */
    private static Boolean ensurePortalAccess(
        AVR_Filing__c filing,
        Id contactId,
        Id accountId
    ) {
        Boolean needsStamp = false;
        Id runningUserId = UserInfo.getUserId();
        if (filing.Contact__c == null && contactId != null) {
            filing.Contact__c = contactId;
            needsStamp = true;
        }
        if (filing.Account__c == null && accountId != null) {
            filing.Account__c = accountId;
            needsStamp = true;
        }
        if (filing.OwnerId != runningUserId) {
            filing.OwnerId = runningUserId;
            needsStamp = true;
        }
        return needsStamp;
    }

    private static Id resolveContactId() {
        User u = currentUser();
        return u == null ? null : u.ContactId;
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

    private static User currentUser() {
        List<User> users = [
            SELECT Id, ContactId, FirstName, LastName, Email
            FROM User
            WHERE Id = :UserInfo.getUserId()
            LIMIT 1
        ];
        return users.isEmpty() ? null : users[0];
    }

    private static String asString(Object value) {
        if (value == null) {
            return null;
        }
        String s = String.valueOf(value).trim();
        return String.isBlank(s) ? null : s;
    }

    private static Boolean isTruthy(Object value) {
        if (value == null) {
            return false;
        }
        if (value instanceof Boolean) {
            return (Boolean) value;
        }
        String s = String.valueOf(value).trim().toLowerCase();
        return s == 'true' || s == '1' || s == 'yes';
    }

    private static String firstNonBlank(String a, String b, String c) {
        if (String.isNotBlank(a)) {
            return a;
        }
        if (String.isNotBlank(b)) {
            return b;
        }
        return String.isNotBlank(c) ? c : null;
    }

    private static Object nestedValue(
        Map<String, Object> root,
        String key1,
        String key2
    ) {
        if (root == null || !root.containsKey(key1)) {
            return null;
        }
        Object level1 = root.get(key1);
        if (!(level1 instanceof Map<String, Object>)) {
            return null;
        }
        return ((Map<String, Object>) level1).get(key2);
    }

    private static Object nestedValue(
        Map<String, Object> root,
        String key1,
        String key2,
        String key3
    ) {
        Object level2 = nestedValue(root, key1, key2);
        if (!(level2 instanceof Map<String, Object>)) {
            return null;
        }
        return ((Map<String, Object>) level2).get(key3);
    }
}
