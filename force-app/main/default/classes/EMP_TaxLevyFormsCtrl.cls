/**
 * Employer Portal – Premium Tax / Fire Marshal Levy / Vehicle Levy form helpers.
 */
public without sharing class EMP_TaxLevyFormsCtrl {
    private static final String INSURER = 'Fundy Mutual Life Insurance Company';
    private static final String PARENT_LICENCE = 'BL-INS-CO-2001';
    private static final String PAID_TO = 'Province of New Brunswick';
    private static final Decimal PREM_RATE = 0.02;
    private static final Decimal FML_EXPECTED = 12500;
    private static final Decimal VL_ASSESSED = 8000;

    public class FormContextDTO {
        @AuraEnabled public String formType;
        @AuraEnabled public String insurerName;
        @AuraEnabled public String parentLicence;
        @AuraEnabled public String paidTo;
        @AuraEnabled public String contactFirstName;
        @AuraEnabled public String contactLastName;
        @AuraEnabled public String contactEmail;
        @AuraEnabled public String contactPhone;
        @AuraEnabled public Decimal rate;
        @AuraEnabled public String glAccount;
        @AuraEnabled public Decimal expectedAmount;
        @AuraEnabled public Decimal assessedAmount;
        @AuraEnabled public String assessedBy;
        @AuraEnabled public String sourceFilingRef;
        @AuraEnabled public Decimal priorYearActual;
        @AuraEnabled public List<String> periodOptions;
        @AuraEnabled public List<String> paymentMethods;
    }

    public class SubmitRequest {
        @AuraEnabled public String formType { get; set; }
        @AuraEnabled public Map<String, Object> values { get; set; }
    }

    public class SubmitResult {
        @AuraEnabled public Id recordId;
        @AuraEnabled public String recordNumber;
        @AuraEnabled public String status;
        @AuraEnabled public String flowKey;
        @AuraEnabled public String successUrl;
    }

    @AuraEnabled(cacheable=true)
    public static FormContextDTO getFormContext(String formType) {
        FormContextDTO dto = new FormContextDTO();
        dto.formType = formType;
        dto.insurerName = INSURER;
        dto.parentLicence = PARENT_LICENCE;
        dto.paidTo = PAID_TO;
        dto.contactFirstName = firstToken(UserInfo.getFirstName(), 'Claire');
        dto.contactLastName = firstToken(UserInfo.getLastName(), 'Dubois');
        dto.contactEmail = UserInfo.getUserEmail();
        dto.contactPhone = '506-450-3100';
        dto.paymentMethods = new List<String>{ 'EFT', 'Cheque', 'Provincial payment portal' };

        if (formType == 'FireMarshal') {
            dto.glAccount = '4100-INS-FIRELEVY';
            dto.expectedAmount = FML_EXPECTED;
            dto.priorYearActual = 12000;
            dto.sourceFilingRef = 'FIL-2025-2001';
            dto.periodOptions = new List<String>{ 'FY 2026', 'FY 2025' };
        } else if (formType == 'VehicleLevy') {
            dto.glAccount = '4100-INS-VEHLEVY';
            dto.assessedAmount = VL_ASSESSED;
            dto.assessedBy = 'Alex Moreau';
            dto.periodOptions = new List<String>{ 'Q2 2026', 'Q1 2026', 'Q3 2026', 'Q4 2026' };
        } else {
            dto.glAccount = '4100-INS-PREMTAX';
            dto.rate = PREM_RATE;
            dto.periodOptions = new List<String>{ 'Q2 2026', 'Q1 2026', 'Q3 2026', 'Q4 2026' };
        }
        return dto;
    }

    public class DraftResult {
        @AuraEnabled public Id recordId;
        @AuraEnabled public String recordNumber;
    }

    @AuraEnabled
    public static DraftResult createDraftRecord(String formType) {
        if (String.isBlank(formType)) {
            throw new AuraHandledException('Form type is required.');
        }

        DraftResult result = new DraftResult();
        if (formType == 'FireMarshal') {
            Fire_Marshal_Levy__c row = new Fire_Marshal_Levy__c();
            row.Applicant__c = UserInfo.getUserId();
            row.Insurer_Name__c = INSURER;
            row.Parent_Licence__c = PARENT_LICENCE;
            row.GL_Account__c = '4100-INS-FIRELEVY';
            row.Expected_Amount__c = FML_EXPECTED;
            row.Prior_Year_Actual__c = 12000;
            row.Source_Filing_Ref__c = 'FIL-2025-2001';
            row.Paid_To__c = PAID_TO;
            row.Filing_Status__c = 'Draft';
            insert row;
            Fire_Marshal_Levy__c saved = [
                SELECT Id, Name FROM Fire_Marshal_Levy__c WHERE Id = :row.Id LIMIT 1
            ];
            result.recordId = saved.Id;
            result.recordNumber = saved.Name;
            return result;
        }

        if (formType == 'VehicleLevy') {
            Vehicle_Levy__c row = new Vehicle_Levy__c();
            row.Applicant__c = UserInfo.getUserId();
            row.Insurer_Name__c = INSURER;
            row.Parent_Licence__c = PARENT_LICENCE;
            row.Assessed_By__c = 'Alex Moreau';
            row.Assessed_Amount__c = VL_ASSESSED;
            row.GL_Account__c = '4100-INS-VEHLEVY';
            row.Paid_To__c = PAID_TO;
            row.Filing_Status__c = 'Draft';
            insert row;
            Vehicle_Levy__c saved = [
                SELECT Id, Name FROM Vehicle_Levy__c WHERE Id = :row.Id LIMIT 1
            ];
            result.recordId = saved.Id;
            result.recordNumber = saved.Name;
            return result;
        }

        Tax_Return_Applications__c row = new Tax_Return_Applications__c();
        row.Applicant__c = UserInfo.getUserId();
        row.Tax_Type__c = 'Premium Tax';
        row.Filing_Status__c = 'Draft';
        row.Status__c = 'Unpaid';
        row.Obligation_Type__c = 'Premium Tax (quarterly estimate)';
        row.Insurer_Name__c = INSURER;
        row.Parent_Licence__c = PARENT_LICENCE;
        row.GL_Account__c = '4100-INS-PREMTAX';
        row.Paid_To__c = PAID_TO;
        row.Rate__c = PREM_RATE * 100;
        insert row;
        Tax_Return_Applications__c saved = [
            SELECT Id, Name FROM Tax_Return_Applications__c WHERE Id = :row.Id LIMIT 1
        ];
        result.recordId = saved.Id;
        result.recordNumber = saved.Name;
        return result;
    }

    @AuraEnabled
    public static SubmitResult submitForm(SubmitRequest request) {
        if (request == null || String.isBlank(request.formType)) {
            throw new AuraHandledException('Form type is required.');
        }
        Map<String, Object> values = request.values == null
            ? new Map<String, Object>()
            : request.values;

        if (request.formType == 'FireMarshal') {
            return submitFireMarshal(values);
        }
        if (request.formType == 'VehicleLevy') {
            return submitVehicleLevy(values);
        }
        return submitPremiumTax(values);
    }

    private static SubmitResult submitPremiumTax(Map<String, Object> values) {
        Decimal taxable = toDecimal(values.get('taxablePremiums'));
        Decimal exempt = toDecimal(values.get('exemptPremiums'));
        Decimal levy = taxable == null ? 0 : (taxable * PREM_RATE);
        Decimal amountPaid = toDecimal(values.get('amountPaid'));
        Id draftId = toId(values.get('recordId'));

        Tax_Return_Applications__c row = draftId == null
            ? new Tax_Return_Applications__c()
            : new Tax_Return_Applications__c(Id = draftId);
        row.Applicant__c = UserInfo.getUserId();
        row.Tax_Type__c = 'Premium Tax';
        row.Reporting_Period__c = toString(values.get('period'));
        row.Filing_Status__c = 'Submitted';
        row.Status__c = 'Paid';
        row.Taxable_Premiums_NB__c = taxable;
        row.Exempt_Premiums__c = exempt;
        row.Rate__c = PREM_RATE * 100;
        row.Calculated_Levy__c = levy;
        row.Obligation_Type__c = 'Premium Tax (quarterly estimate)';
        row.Period_Start__c = toDate(values.get('periodStart'));
        row.Period_End__c = toDate(values.get('periodEnd'));
        row.Insurer_Name__c = INSURER;
        row.Parent_Licence__c = PARENT_LICENCE;
        row.Contact_First_Name__c = toString(values.get('contactFirstName'));
        row.Contact_Last_Name__c = toString(values.get('contactLastName'));
        row.Contact_Email__c = toString(values.get('contactEmail'));
        row.Contact_Phone__c = toString(values.get('contactPhone'));
        row.GL_Account__c = '4100-INS-PREMTAX';
        row.Paid_To__c = PAID_TO;
        row.Amount_Due__c = levy;
        row.Payment_Date__c = toDate(values.get('paymentDate'));
        row.Amount_Paid__c = amountPaid;
        row.Payment_Method__c = toString(values.get('paymentMethod'));
        row.Remittance_Reference__c = toString(values.get('remittanceReference'));
        row.Attestation__c = toBoolean(values.get('attestation'));
        row.Proof_File_Name__c = toString(values.get('proofFileName'));
        upsert row;

        Tax_Return_Applications__c saved = [
            SELECT Id, Name FROM Tax_Return_Applications__c WHERE Id = :row.Id LIMIT 1
        ];
        return buildResult(saved.Id, saved.Name, 'PremiumTax');
    }

    private static SubmitResult submitFireMarshal(Map<String, Object> values) {
        Decimal amountPaid = toDecimal(values.get('amountPaid'));
        Decimal variance = (amountPaid == null ? 0 : amountPaid) - FML_EXPECTED;
        String matchStatus = variance == 0 ? 'Matched' : 'Variance — exception / RMI';
        String varianceDisplay = formatMoney(Math.abs(variance)) +
            (variance == 0 ? ' (none)' : (variance < 0 ? ' under' : ' over'));
        Id draftId = toId(values.get('recordId'));

        Fire_Marshal_Levy__c row = draftId == null
            ? new Fire_Marshal_Levy__c()
            : new Fire_Marshal_Levy__c(Id = draftId);
        row.Applicant__c = UserInfo.getUserId();
        row.Insurer_Name__c = INSURER;
        row.Parent_Licence__c = PARENT_LICENCE;
        row.Period__c = toString(values.get('period'));
        row.GL_Account__c = '4100-INS-FIRELEVY';
        row.Expected_Amount__c = FML_EXPECTED;
        row.Prior_Year_Actual__c = 12000;
        row.Source_Filing_Ref__c = 'FIL-2025-2001';
        row.Paid_To__c = PAID_TO;
        row.Payment_Date__c = toDate(values.get('paymentDate'));
        row.Amount_Paid__c = amountPaid;
        row.Payment_Method__c = toString(values.get('paymentMethod'));
        row.Remittance_Reference__c = toString(values.get('remittanceReference'));
        row.Variance_Display__c = varianceDisplay;
        row.Match_Status__c = matchStatus;
        row.Filing_Status__c = 'Submitted';
        row.Attestation__c = toBoolean(values.get('attestation'));
        row.Proof_File_Name__c = toString(values.get('proofFileName'));
        upsert row;

        Fire_Marshal_Levy__c saved = [
            SELECT Id, Name FROM Fire_Marshal_Levy__c WHERE Id = :row.Id LIMIT 1
        ];
        return buildResult(saved.Id, saved.Name, 'FireMarshalLevy');
    }

    private static SubmitResult submitVehicleLevy(Map<String, Object> values) {
        Decimal amountPaid = toDecimal(values.get('amountPaid'));
        Decimal paid = amountPaid == null ? 0 : amountPaid;
        Decimal diff = VL_ASSESSED - paid;
        String trueUpBalance;
        String trueUpTreatment;
        if (diff == 0) {
            trueUpBalance = '$0.00';
            trueUpTreatment = 'No true-up required';
        } else if (diff > 0) {
            trueUpBalance = formatMoney(diff) + ' underpaid';
            trueUpTreatment = 'Add ' + formatMoney(diff) + ' to next quarterly invoice';
        } else {
            trueUpBalance = formatMoney(Math.abs(diff)) + ' overpaid';
            trueUpTreatment = 'Credit ' + formatMoney(Math.abs(diff)) + ' on next quarterly invoice';
        }
        Id draftId = toId(values.get('recordId'));

        Vehicle_Levy__c row = draftId == null
            ? new Vehicle_Levy__c()
            : new Vehicle_Levy__c(Id = draftId);
        row.Applicant__c = UserInfo.getUserId();
        row.Insurer_Name__c = INSURER;
        row.Parent_Licence__c = PARENT_LICENCE;
        row.Assessment_Period__c = toString(values.get('period'));
        row.Assessed_By__c = 'Alex Moreau';
        row.Assessed_Amount__c = VL_ASSESSED;
        row.GL_Account__c = '4100-INS-VEHLEVY';
        row.Paid_To__c = PAID_TO;
        row.Payment_Date__c = toDate(values.get('paymentDate'));
        row.Amount_Paid__c = amountPaid;
        row.Payment_Method__c = toString(values.get('paymentMethod'));
        row.Remittance_Reference__c = toString(values.get('remittanceReference'));
        row.True_Up_Balance__c = trueUpBalance;
        row.True_Up_Treatment__c = trueUpTreatment;
        row.Filing_Status__c = 'Submitted';
        row.Attestation__c = toBoolean(values.get('attestation'));
        row.Proof_File_Name__c = toString(values.get('proofFileName'));
        upsert row;

        Vehicle_Levy__c saved = [
            SELECT Id, Name FROM Vehicle_Levy__c WHERE Id = :row.Id LIMIT 1
        ];
        return buildResult(saved.Id, saved.Name, 'VehicleLevy');
    }

    private static SubmitResult buildResult(Id recordId, String recordNumber, String flowKey) {
        SubmitResult result = new SubmitResult();
        result.recordId = recordId;
        result.recordNumber = recordNumber;
        result.status = 'Submitted';
        result.flowKey = flowKey;
        result.successUrl =
            '/employerportal/s/success-page?c__ContextId=' +
            EncodingUtil.urlEncode(String.valueOf(recordId), 'UTF-8') +
            '&c__FilingNumber=' +
            EncodingUtil.urlEncode(blank(recordNumber), 'UTF-8') +
            '&c__Status=Submitted&c__Flow=' +
            EncodingUtil.urlEncode(flowKey, 'UTF-8');
        return result;
    }

    private static String firstToken(String value, String fallback) {
        return String.isNotBlank(value) ? value : fallback;
    }

    private static Id toId(Object value) {
        if (value == null || String.isBlank(String.valueOf(value))) {
            return null;
        }
        try {
            return Id.valueOf(String.valueOf(value));
        } catch (Exception e) {
            return null;
        }
    }

    private static String toString(Object value) {
        return value == null ? null : String.valueOf(value);
    }

    private static Boolean toBoolean(Object value) {
        if (value == null) return false;
        if (value instanceof Boolean) return (Boolean) value;
        return String.valueOf(value).toLowerCase() == 'true';
    }

    private static Decimal toDecimal(Object value) {
        if (value == null || String.isBlank(String.valueOf(value))) return null;
        return Decimal.valueOf(String.valueOf(value));
    }

    private static Date toDate(Object value) {
        if (value == null || String.isBlank(String.valueOf(value))) return null;
        return Date.valueOf(String.valueOf(value));
    }

    private static String formatMoney(Decimal amount) {
        Decimal n = amount == null ? 0 : amount;
        return '$' + String.valueOf(n.setScale(2));
    }

    private static String blank(String value) {
        return value == null ? '' : value;
    }
}