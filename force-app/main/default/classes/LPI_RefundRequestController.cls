/**
 * @description Controller for Licensing Portal Refund Request page.
 */
public with sharing class LPI_RefundRequestController {

    private static final String CLASS_NAME = 'LPI_RefundRequestController';

    /**
     * @description Fetches applicant, application, and payment details for a refund request.
     * @param applicationId IndividualApplication or BusinessLicenseApplication Id
     * @return RefundRequestWrapper
     */
    @AuraEnabled(cacheable=true)
    public static RefundRequestWrapper getRefundRequestDetails(String applicationId) {
        try {
            if (String.isBlank(applicationId)) {
                throw new LPI_Exception('Application Id is required.');
            }

            Id recordId = Id.valueOf(applicationId);
            String objectType = String.valueOf(recordId.getSObjectType());
            RefundRequestWrapper wrapper = new RefundRequestWrapper();

            if (objectType == 'IndividualApplication') {
                populateFromIndividualApplication(recordId, wrapper);
            } else if (objectType == 'BusinessLicenseApplication') {
                populateFromBusinessLicenseApplication(recordId, wrapper);
            } else {
                throw new LPI_Exception('Unsupported application type for refund request.');
            }

            populateTransactionFee(recordId, wrapper);
            return wrapper;
        } catch (Exception ex) {
            LPI_ExceptionManager.logException(CLASS_NAME, 'getRefundRequestDetails', ex);
            throw new AuraHandledException(ex.getMessage());
        }
    }

    /**
     * @description Submits the refund request by creating a Refund_Request__c record
     *              and updating application status to 'Request for Refund'.
     * @param applicationId IndividualApplication or BusinessLicenseApplication Id
     * @param selectedReasons Semicolon separated reasons chosen by applicant
     * @param otherReasonDetails Additional details if 'Other' is selected
     */
    @AuraEnabled
    public static void submitRefundRequest(String applicationId, String selectedReasons, String otherReasonDetails) {
        try {
            if (String.isBlank(applicationId)) {
                throw new LPI_Exception('Application Id is required.');
            }
            if (String.isBlank(selectedReasons)) {
                throw new LPI_Exception('At least one reason for the refund request is required.');
            }

            Id recordId = Id.valueOf(applicationId);
            String objectType = String.valueOf(recordId.getSObjectType());

            Id feeId = getLatestTransactionFeeId(recordId);
            if (feeId == null) {
                throw new LPI_Exception('No payment transaction found for this application.');
            }

            String reasonValue = normalizeRefundReasons(selectedReasons);

            Refund_Request__c refundRequest = new Refund_Request__c(
                Regulatory_Transaction_Fee__c = feeId,
                Reason_for_Refund_Request__c = reasonValue,
                Reason_for_Refund__c = String.isNotBlank(otherReasonDetails)
                    ? otherReasonDetails.trim()
                    : null,
                Status__c = 'Request for Refund'
            );
            insert refundRequest;

            if (objectType == 'IndividualApplication') {
                IndividualApplication app = new IndividualApplication(
                    Id = recordId,
                    Status = 'Request for Refund'
                );
                update app;
            } else if (objectType == 'BusinessLicenseApplication') {
                BusinessLicenseApplication app = new BusinessLicenseApplication(
                    Id = recordId,
                    Status = 'Request for Refund'
                );
                update app;
            } else {
                throw new LPI_Exception('Unsupported application type for refund request.');
            }
        } catch (Exception ex) {
            LPI_ExceptionManager.logException(CLASS_NAME, 'submitRefundRequest', ex);
            throw new AuraHandledException(ex.getMessage());
        }
    }

    private static Id getLatestTransactionFeeId(Id parentRecordId) {
        List<RegulatoryTrxnFee> fees = [
            SELECT Id
            FROM RegulatoryTrxnFee
            WHERE ParentRecordId = :parentRecordId
            ORDER BY CreatedDate DESC
            LIMIT 1
        ];
        return fees.isEmpty() ? null : fees[0].Id;
    }

    /**
     * @description Maps UI/short reason labels to restricted multiselect picklist API values.
     *              Multiselect values must be semicolon-delimited with no space after ';'.
     */
    @TestVisible
    private static String normalizeRefundReasons(String selectedReasons) {
        List<String> validValues = new List<String>();
        for (Schema.PicklistEntry entry : Refund_Request__c.Reason_for_Refund_Request__c.getDescribe().getPicklistValues()) {
            if (entry.isActive()) {
                validValues.add(entry.getValue());
            }
        }

        List<String> normalized = new List<String>();
        for (String part : selectedReasons.split(';')) {
            String trimmed = part != null ? part.trim() : '';
            if (String.isBlank(trimmed)) {
                continue;
            }

            String matched = matchRefundReason(trimmed, validValues);
            if (matched == null) {
                throw new LPI_Exception('Invalid reason for refund request: ' + trimmed);
            }
            if (!normalized.contains(matched)) {
                normalized.add(matched);
            }
        }

        if (normalized.isEmpty()) {
            throw new LPI_Exception('At least one reason for the refund request is required.');
        }
        return String.join(normalized, ';');
    }

    private static String matchRefundReason(String selected, List<String> validValues) {
        for (String valid : validValues) {
            if (valid.equalsIgnoreCase(selected)) {
                return valid;
            }
        }
        // Support short labels from UI (e.g. "Deceased" -> "Deceased – Must provide death certificate")
        for (String valid : validValues) {
            String prefix = getReasonPrefix(valid);
            if (prefix.equalsIgnoreCase(selected) || valid.toLowerCase().startsWith(selected.toLowerCase())) {
                return valid;
            }
        }
        return null;
    }

    private static String getReasonPrefix(String picklistValue) {
        Integer enDashIdx = picklistValue.indexOf('\u2013'); // –
        Integer hyphenIdx = picklistValue.indexOf('-');
        Integer splitIdx = -1;
        if (enDashIdx > 0 && (hyphenIdx < 0 || enDashIdx < hyphenIdx)) {
            splitIdx = enDashIdx;
        } else if (hyphenIdx > 0) {
            splitIdx = hyphenIdx;
        }
        return splitIdx > 0 ? picklistValue.substring(0, splitIdx).trim() : picklistValue;
    }

    private static void populateFromIndividualApplication(Id recordId, RefundRequestWrapper wrapper) {
        List<IndividualApplication> apps = [
            SELECT Id, Name, Board_Name__c, Applicant_Name__c,
                AccountId, Account.Name, Account.FirstName, Account.MiddleName, Account.LastName,
                Account.PersonEmail, Account.Phone, Account.Date_of_Birth__c,
                Account.PersonOtherStreet, Account.PersonOtherCity, Account.PersonOtherState,
                Account.PersonOtherStateCode, Account.Other_State__c, Account.PersonOtherPostalCode,
                LicenseType.Name, LicenseType.IssuingDepartment.Name
            FROM IndividualApplication
            WHERE Id = :recordId
            LIMIT 1
        ];
        if (apps.isEmpty()) {
            throw new LPI_Exception('Application not found.');
        }
        IndividualApplication app = apps[0];
        wrapper.applicationNumber = app.Name;
        wrapper.licenseType = app.LicenseType != null ? app.LicenseType.Name : '';
        wrapper.stateOrBoard = String.isNotBlank(app.Board_Name__c)
            ? app.Board_Name__c
            : (app.LicenseType != null && app.LicenseType.IssuingDepartment != null
                ? app.LicenseType.IssuingDepartment.Name
                : '');
        populateApplicantFromAccount(app.Account, app.Applicant_Name__c, wrapper);
    }

    private static void populateFromBusinessLicenseApplication(Id recordId, RefundRequestWrapper wrapper) {
        List<BusinessLicenseApplication> apps = [
            SELECT Id, Name, Business_Name__c, Licence_Type_Name__c,
                AccountId, Account.Name, Account.FirstName, Account.MiddleName, Account.LastName,
                Account.PersonEmail, Account.Phone, Account.Date_of_Birth__c,
                Account.PersonOtherStreet, Account.PersonOtherCity, Account.PersonOtherState,
                Account.PersonOtherStateCode, Account.Other_State__c, Account.PersonOtherPostalCode,
                LicenseType.Name, LicenseType.IssuingDepartment.Name
            FROM BusinessLicenseApplication
            WHERE Id = :recordId
            LIMIT 1
        ];
        if (apps.isEmpty()) {
            throw new LPI_Exception('Application not found.');
        }
        BusinessLicenseApplication app = apps[0];
        wrapper.applicationNumber = app.Name;
        wrapper.licenseType = String.isNotBlank(app.Licence_Type_Name__c)
            ? app.Licence_Type_Name__c
            : (app.LicenseType != null ? app.LicenseType.Name : '');
        wrapper.stateOrBoard = app.LicenseType != null && app.LicenseType.IssuingDepartment != null
            ? app.LicenseType.IssuingDepartment.Name
            : '';
        populateApplicantFromAccount(
            app.Account,
            String.isNotBlank(app.Business_Name__c) ? app.Business_Name__c : null,
            wrapper
        );
    }

    private static void populateApplicantFromAccount(Account acc, String fallbackName, RefundRequestWrapper wrapper) {
        if (acc == null) {
            wrapper.applicantName = fallbackName;
            return;
        }
        String fullName = '';
        if (String.isNotBlank(acc.FirstName) || String.isNotBlank(acc.LastName)) {
            fullName = (String.isNotBlank(acc.FirstName) ? acc.FirstName : '')
                + (String.isNotBlank(acc.MiddleName) ? ' ' + acc.MiddleName : '')
                + (String.isNotBlank(acc.LastName) ? ' ' + acc.LastName : '');
            fullName = fullName.trim();
        }
        wrapper.applicantName = String.isNotBlank(fullName)
            ? fullName
            : (String.isNotBlank(fallbackName) ? fallbackName : acc.Name);
        wrapper.email = acc.PersonEmail;
        wrapper.phone = acc.Phone;
        wrapper.dateOfBirth = acc.Date_of_Birth__c;
        wrapper.streetAddress = acc.PersonOtherStreet;
        wrapper.city = acc.PersonOtherCity;
        wrapper.state = String.isNotBlank(acc.PersonOtherStateCode)
            ? acc.PersonOtherStateCode
            : (String.isNotBlank(acc.Other_State__c) ? acc.Other_State__c : acc.PersonOtherState);
        wrapper.zipCode = acc.PersonOtherPostalCode;
    }

    private static void populateTransactionFee(Id parentRecordId, RefundRequestWrapper wrapper) {
        List<RegulatoryTrxnFee> fees = [
            SELECT Id, Name
            FROM RegulatoryTrxnFee
            WHERE ParentRecordId = :parentRecordId
            ORDER BY CreatedDate DESC
            LIMIT 1
        ];
        if (!fees.isEmpty()) {
            wrapper.paymentTransactionId = fees[0].Name;
            wrapper.paymentTransactionRecordId = fees[0].Id;
        }
    }

    public class RefundRequestWrapper {
        @AuraEnabled public String applicantName;
        @AuraEnabled public String email;
        @AuraEnabled public String phone;
        @AuraEnabled public Date dateOfBirth;
        @AuraEnabled public String streetAddress;
        @AuraEnabled public String city;
        @AuraEnabled public String state;
        @AuraEnabled public String zipCode;
        @AuraEnabled public String applicationNumber;
        @AuraEnabled public String stateOrBoard;
        @AuraEnabled public String licenseType;
        @AuraEnabled public String paymentTransactionId;
        @AuraEnabled public String paymentTransactionRecordId;
    }
}