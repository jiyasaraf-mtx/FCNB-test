/**
 * Employer Portal – Premium Tax Return helpers for OmniScript success navigation,
 * Success Page display, Return step defaults/save, and Premium Tax Filings list.
 */
global without sharing class EMP_PremiumTaxCtrl implements Callable {
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
        if (methodName == 'prepareSuccessParams') {
            prepareSuccessParams(inputMap, outMap);
            return true;
        }
        if (methodName == 'getReturnDefaults') {
            getReturnDefaults(inputMap, outMap);
            return true;
        }
        if (methodName == 'saveReturnHeader') {
            saveReturnHeader(inputMap, outMap);
            return true;
        }
        return false;
    }

    /**
     * Seeds Return step defaults (applicant, tax type, period, draft status).
     * Applicant is the logged-in User Id (Lookup).
     */
    private static void getReturnDefaults(
        Map<String, Object> inputMap,
        Map<String, Object> outMap
    ) {
        Id applicantId = UserInfo.getUserId();
        String applicantName = UserInfo.getName();
        String period = currentReportingPeriod();
        Id existingId = resolveTaxReturnId(inputMap);

        outMap.put('Applicant', applicantId);
        outMap.put('ApplicantName', applicantName);
        outMap.put('TaxType', 'Premium Tax');
        outMap.put('ReportingPeriod', period);
        outMap.put('FilingStatus', 'Draft');
        outMap.put('ReturnStatusBadge', 'Draft');

        if (existingId != null) {
            List<Tax_Return_Applications__c> rows = [
                SELECT
                    Id,
                    Name,
                    Applicant__c,
                    Applicant__r.Name,
                    Tax_Type__c,
                    Reporting_Period__c,
                    Filing_Status__c
                FROM Tax_Return_Applications__c
                WHERE Id = :existingId
                LIMIT 1
            ];
            if (!rows.isEmpty()) {
                Tax_Return_Applications__c row = rows[0];
                outMap.put('Id', row.Id);
                outMap.put('ContextId', row.Id);
                outMap.put('ReturnId', row.Name);
                outMap.put(
                    'Applicant',
                    row.Applicant__c != null ? row.Applicant__c : applicantId
                );
                outMap.put(
                    'ApplicantName',
                    row.Applicant__c != null && row.Applicant__r != null
                        ? row.Applicant__r.Name
                        : applicantName
                );
                outMap.put(
                    'TaxType',
                    String.isNotBlank(row.Tax_Type__c) ? row.Tax_Type__c : 'Premium Tax'
                );
                outMap.put(
                    'ReportingPeriod',
                    String.isNotBlank(row.Reporting_Period__c) ? row.Reporting_Period__c : period
                );
                outMap.put(
                    'FilingStatus',
                    String.isNotBlank(row.Filing_Status__c) ? row.Filing_Status__c : 'Draft'
                );
                outMap.put('ReturnStatusBadge', outMap.get('FilingStatus'));
            }
        }
    }

    /**
     * Creates/updates Tax Return header fields from the Return step.
     */
    private static void saveReturnHeader(
        Map<String, Object> inputMap,
        Map<String, Object> outMap
    ) {
        Id taxReturnId = resolveTaxReturnId(inputMap);
        Id applicantId = resolveApplicantId(inputMap);
        String taxType = firstNonBlank(inputMap, new List<String>{ 'TaxType', 'Return:TaxType' });
        String reportingPeriod = firstNonBlank(
            inputMap,
            new List<String>{ 'ReportingPeriod', 'Return:ReportingPeriod' }
        );
        String filingStatus = firstNonBlank(
            inputMap,
            new List<String>{ 'FilingStatus', 'Return:FilingStatus' }
        );

        Tax_Return_Applications__c row;
        Boolean isNew = taxReturnId == null;
        if (isNew) {
            row = new Tax_Return_Applications__c();
            row.Status__c = 'Unpaid';
        } else {
            row = new Tax_Return_Applications__c(Id = taxReturnId);
        }

        row.Applicant__c = applicantId != null ? applicantId : UserInfo.getUserId();
        row.Tax_Type__c = String.isNotBlank(taxType) ? taxType : 'Premium Tax';
        row.Reporting_Period__c = String.isNotBlank(reportingPeriod)
            ? reportingPeriod
            : currentReportingPeriod();
        row.Filing_Status__c = String.isNotBlank(filingStatus) ? filingStatus : 'Draft';

        upsert row;

        Tax_Return_Applications__c saved = [
            SELECT Id, Name, Filing_Status__c, Applicant__c, Applicant__r.Name
            FROM Tax_Return_Applications__c
            WHERE Id = :row.Id
            LIMIT 1
        ];

        outMap.put('Id', saved.Id);
        outMap.put('ContextId', saved.Id);
        outMap.put('c__ContextId', saved.Id);
        outMap.put('DRId_Tax_Return_Applications__c', saved.Id);
        outMap.put('ReturnId', saved.Name);
        outMap.put('Applicant', saved.Applicant__c);
        outMap.put(
            'ApplicantName',
            saved.Applicant__r != null ? saved.Applicant__r.Name : UserInfo.getName()
        );
        outMap.put('FilingStatus', saved.Filing_Status__c);
        outMap.put('ReturnStatusBadge', saved.Filing_Status__c);
    }

    private static void prepareSuccessParams(
        Map<String, Object> inputMap,
        Map<String, Object> outMap
    ) {
        Id taxReturnId = resolveTaxReturnId(inputMap);
        TaxReturnDTO dto = taxReturnId == null ? null : queryTaxReturn(taxReturnId);

        String contextId = dto != null ? String.valueOf(dto.id) : String.valueOf(taxReturnId);
        String filingNumber = dto != null ? dto.name : '';
        String status = 'Submitted';

        if (taxReturnId != null) {
            try {
                update new Tax_Return_Applications__c(
                    Id = taxReturnId,
                    Filing_Status__c = 'Submitted'
                );
            } catch (Exception e) {
                // non-blocking
            }
        }

        outMap.put('ContextId', contextId);
        outMap.put('c__ContextId', contextId);
        outMap.put('FilingNumber', filingNumber);
        outMap.put('Status', status);
        outMap.put(
            'retURL',
            '/s/success-page?c__ContextId=' +
                EncodingUtil.urlEncode(blankToEmpty(contextId), 'UTF-8') +
                '&c__FilingNumber=' +
                EncodingUtil.urlEncode(blankToEmpty(filingNumber), 'UTF-8') +
                '&c__Status=' +
                EncodingUtil.urlEncode(status, 'UTF-8') +
                '&c__Flow=PremiumTax'
        );
    }

    @AuraEnabled(cacheable=true)
    public static PremiumTaxPageDTO getPremiumTaxFilings() {
        return getFilingsByType('PremiumTax');
    }

    /**
     * Returns filings for the selected hub tile.
     * PremiumTax → Tax_Return_Applications__c
     * FireMarshal → Fire_Marshal_Levy__c
     * VehicleLevy → Vehicle_Levy__c
     */
    @AuraEnabled(cacheable=true)
    public static PremiumTaxPageDTO getFilingsByType(String filingType) {
        PremiumTaxPageDTO page = new PremiumTaxPageDTO();
        page.accountName = UserInfo.getName();
        page.filingType = String.isBlank(filingType) ? 'PremiumTax' : filingType;
        page.returns = new List<TaxReturnListItemDTO>();

        Id applicantId = UserInfo.getUserId();

        if (page.filingType == 'FireMarshal') {
            for (Fire_Marshal_Levy__c row : [
                SELECT
                    Id,
                    Name,
                    CreatedDate,
                    Applicant__c,
                    Applicant__r.Name,
                    Period__c,
                    Filing_Status__c,
                    Amount_Paid__c,
                    Insurer_Name__c
                FROM Fire_Marshal_Levy__c
                WHERE Applicant__c = :applicantId
                ORDER BY CreatedDate DESC
                LIMIT 200
            ]) {
                page.returns.add(toListItem(row));
            }
            return page;
        }

        if (page.filingType == 'VehicleLevy') {
            for (Vehicle_Levy__c row : [
                SELECT
                    Id,
                    Name,
                    CreatedDate,
                    Applicant__c,
                    Applicant__r.Name,
                    Assessment_Period__c,
                    Filing_Status__c,
                    Amount_Paid__c,
                    Insurer_Name__c
                FROM Vehicle_Levy__c
                WHERE Applicant__c = :applicantId
                ORDER BY CreatedDate DESC
                LIMIT 200
            ]) {
                page.returns.add(toListItem(row));
            }
            return page;
        }

        for (Tax_Return_Applications__c row : [
            SELECT
                Id,
                Name,
                CreatedDate,
                Applicant__c,
                Applicant__r.Name,
                Tax_Type__c,
                Reporting_Period__c,
                Filing_Status__c,
                Status__c,
                Taxable_Premiums_NB__c,
                Exempt_Premiums__c,
                Rate__c,
                Calculated_Levy__c,
                Installments__c,
                Currency__c,
                Premiums_Levy_Json__c
            FROM Tax_Return_Applications__c
            WHERE Applicant__c = :applicantId
            ORDER BY CreatedDate DESC
            LIMIT 200
        ]) {
            page.returns.add(toListItem(row));
        }
        return page;
    }

    @AuraEnabled(cacheable=true)
    public static TaxReturnDTO getTaxReturn(Id taxReturnId) {
        if (taxReturnId == null) {
            throw new AuraHandledException('Tax Return Id is required.');
        }
        TaxReturnDTO dto = queryTaxReturn(taxReturnId);
        if (dto == null) {
            throw new AuraHandledException('Tax return application was not found.');
        }
        return dto;
    }

    private static TaxReturnListItemDTO toListItem(Tax_Return_Applications__c row) {
        TaxReturnListItemDTO item = new TaxReturnListItemDTO();
        item.id = row.Id;
        item.name = row.Name;
        item.periodLabel = String.isNotBlank(row.Reporting_Period__c)
            ? row.Reporting_Period__c
            : toPeriodLabel(row.CreatedDate);
        String applicant = row.Applicant__r != null && String.isNotBlank(row.Applicant__r.Name)
            ? row.Applicant__r.Name
            : UserInfo.getName();
        item.accountName = applicant;
        item.subtitle = String.isNotBlank(applicant)
            ? row.Name + ' • ' + applicant
            : row.Name;
        item.paymentStatus = resolvePaymentStatus(row);
        item.isPaid = item.paymentStatus == 'Paid';
        return item;
    }

    private static TaxReturnListItemDTO toListItem(Fire_Marshal_Levy__c row) {
        TaxReturnListItemDTO item = new TaxReturnListItemDTO();
        item.id = row.Id;
        item.name = row.Name;
        item.periodLabel = String.isNotBlank(row.Period__c)
            ? row.Period__c
            : toPeriodLabel(row.CreatedDate);
        String applicant = row.Applicant__r != null && String.isNotBlank(row.Applicant__r.Name)
            ? row.Applicant__r.Name
            : UserInfo.getName();
        item.accountName = applicant;
        item.subtitle = String.isNotBlank(applicant)
            ? row.Name + ' • ' + applicant
            : row.Name;
        item.paymentStatus = resolveFilingStatus(row.Filing_Status__c, row.Amount_Paid__c);
        item.isPaid = item.paymentStatus == 'Submitted' || item.paymentStatus == 'Paid';
        return item;
    }

    private static TaxReturnListItemDTO toListItem(Vehicle_Levy__c row) {
        TaxReturnListItemDTO item = new TaxReturnListItemDTO();
        item.id = row.Id;
        item.name = row.Name;
        item.periodLabel = String.isNotBlank(row.Assessment_Period__c)
            ? row.Assessment_Period__c
            : toPeriodLabel(row.CreatedDate);
        String applicant = row.Applicant__r != null && String.isNotBlank(row.Applicant__r.Name)
            ? row.Applicant__r.Name
            : UserInfo.getName();
        item.accountName = applicant;
        item.subtitle = String.isNotBlank(applicant)
            ? row.Name + ' • ' + applicant
            : row.Name;
        item.paymentStatus = resolveFilingStatus(row.Filing_Status__c, row.Amount_Paid__c);
        item.isPaid = item.paymentStatus == 'Submitted' || item.paymentStatus == 'Paid';
        return item;
    }

    private static String resolveFilingStatus(String filingStatus, Decimal amountPaid) {
        if (String.isNotBlank(filingStatus)) {
            return filingStatus;
        }
        return amountPaid != null ? 'Submitted' : 'Draft';
    }

    private static String resolvePaymentStatus(Tax_Return_Applications__c row) {
        if (String.isNotBlank(row.Status__c)) {
            if (row.Status__c == 'Paid') {
                return 'Paid';
            }
            if (row.Status__c == 'Unpaid') {
                return 'Not Paid';
            }
            return row.Status__c;
        }
        Boolean hasPremiumData =
            row.Taxable_Premiums_NB__c != null ||
            row.Exempt_Premiums__c != null ||
            row.Rate__c != null ||
            row.Installments__c != null;
        return hasPremiumData ? 'Paid' : 'Not Paid';
    }

    private static String toPeriodLabel(Datetime created) {
        if (created == null) {
            return '—';
        }
        Integer month = created.month();
        Integer year = created.year();
        Integer quarter = ((month - 1) / 3) + 1;
        return 'Q' + String.valueOf(quarter) + ' ' + String.valueOf(year);
    }

    private static String currentReportingPeriod() {
        return toPeriodLabel(System.now());
    }

    private static Id resolveApplicantId(Map<String, Object> inputMap) {
        String raw = firstNonBlank(
            inputMap,
            new List<String>{
                'Applicant',
                'Return:Applicant',
                'Return:ReturnDetails:Applicant',
                'ApplicantId'
            }
        );
        if (String.isBlank(raw)) {
            return UserInfo.getUserId();
        }
        try {
            return (Id) raw;
        } catch (Exception e) {
            // Lookup may return Name in some configs — fall back to current user
            return UserInfo.getUserId();
        }
    }

    private static TaxReturnDTO queryTaxReturn(Id taxReturnId) {
        List<Tax_Return_Applications__c> rows = [
            SELECT Id, Name
            FROM Tax_Return_Applications__c
            WHERE Id = :taxReturnId
            LIMIT 1
        ];
        if (rows.isEmpty()) {
            return null;
        }
        TaxReturnDTO dto = new TaxReturnDTO();
        dto.id = rows[0].Id;
        dto.name = rows[0].Name;
        dto.status = 'Submitted';
        return dto;
    }

    private static Id resolveTaxReturnId(Map<String, Object> inputMap) {
        if (inputMap == null) {
            return null;
        }
        List<String> keys = new List<String>{
            'TaxReturnId',
            'Id',
            'ContextId',
            'DRId_Tax_Return_Applications__c',
            'Return:ReturnId'
        };
        for (String key : keys) {
            Object raw = inputMap.get(key);
            if (raw != null && String.isNotBlank(String.valueOf(raw))) {
                try {
                    return (Id) String.valueOf(raw);
                } catch (Exception e) {
                    // try next key
                }
            }
        }
        return null;
    }

    private static String firstNonBlank(Map<String, Object> inputMap, List<String> keys) {
        if (inputMap == null) {
            return null;
        }
        for (String key : keys) {
            Object raw = inputMap.get(key);
            if (raw != null && String.isNotBlank(String.valueOf(raw))) {
                return String.valueOf(raw);
            }
        }
        // nested Return node
        Object returnNode = inputMap.get('Return');
        if (returnNode instanceof Map<String, Object>) {
            Map<String, Object> ret = (Map<String, Object>) returnNode;
            for (String key : keys) {
                String shortKey = key.contains(':') ? key.substringAfterLast(':') : key;
                Object raw = ret.get(shortKey);
                if (raw != null && String.isNotBlank(String.valueOf(raw))) {
                    return String.valueOf(raw);
                }
                Object details = ret.get('ReturnDetails');
                if (details instanceof Map<String, Object>) {
                    Object nested = ((Map<String, Object>) details).get(shortKey);
                    if (nested != null && String.isNotBlank(String.valueOf(nested))) {
                        return String.valueOf(nested);
                    }
                }
            }
        }
        return null;
    }

    private static String blankToEmpty(String value) {
        return value == null ? '' : value;
    }

    public class PremiumTaxPageDTO {
        @AuraEnabled
        public String accountName;
        @AuraEnabled
        public String filingType;
        @AuraEnabled
        public List<TaxReturnListItemDTO> returns;
    }

    public class TaxReturnListItemDTO {
        @AuraEnabled
        public Id id;
        @AuraEnabled
        public String name;
        @AuraEnabled
        public String periodLabel;
        @AuraEnabled
        public String accountName;
        @AuraEnabled
        public String subtitle;
        @AuraEnabled
        public String paymentStatus;
        @AuraEnabled
        public Boolean isPaid;
    }

    public class TaxReturnDTO {
        @AuraEnabled
        public Id id;
        @AuraEnabled
        public String name;
        @AuraEnabled
        public String status;
    }
}