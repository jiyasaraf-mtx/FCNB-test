/**
 * @description Sends multilingual Employer Portal emails for Financial_Filing__c status changes
 *              (Request Missing Schedule, Accepted) and shared email utilities.
 */
public without sharing class EMP_FinancialFilingEmailService {
    private static final String CLASS_NAME = 'EMP_FinancialFilingEmailService';
    private static final String STATUS_REQUEST_MISSING = 'Request Missing Schedule';
    private static final String STATUS_ACCEPTED = 'Accepted';
    private static final String CC_ADDRESS = 'rishi.kansara@mtxg.ai';

    /**
     * @description Sends portal emails when filing status changes to Request Missing Schedule
     *              or Accepted. Intended for after-update trigger context.
     */
    public static void sendEmailsOnStatusChange(
        List<Financial_Filing__c> newRecords,
        Map<Id, Financial_Filing__c> oldMap
    ) {
        if (newRecords == null || newRecords.isEmpty() || oldMap == null) {
            return;
        }

        try {
            List<Financial_Filing__c> requestMissing = new List<Financial_Filing__c>();
            List<Financial_Filing__c> accepted = new List<Financial_Filing__c>();

            for (Financial_Filing__c filing : newRecords) {
                Financial_Filing__c oldFiling = oldMap.get(filing.Id);
                String oldStatus = oldFiling != null ? oldFiling.Status__c : null;
                if (filing.Status__c == STATUS_REQUEST_MISSING && oldStatus != STATUS_REQUEST_MISSING) {
                    requestMissing.add(filing);
                } else if (filing.Status__c == STATUS_ACCEPTED && oldStatus != STATUS_ACCEPTED) {
                    accepted.add(filing);
                }
            }

            if (requestMissing.isEmpty() && accepted.isEmpty()) {
                return;
            }

            Set<Id> accountIds = new Set<Id>();
            for (Financial_Filing__c filing : requestMissing) {
                if (filing.Account__c != null) {
                    accountIds.add(filing.Account__c);
                }
            }
            for (Financial_Filing__c filing : accepted) {
                if (filing.Account__c != null) {
                    accountIds.add(filing.Account__c);
                }
            }
            Map<Id, String> accountNameById = resolveAccountNames(accountIds);
            Id oweaId = resolveOrgWideEmailAddressId();

            for (Financial_Filing__c filing : requestMissing) {
                sendRequestMissingScheduleEmail(filing, accountNameById.get(filing.Account__c), oweaId);
            }
            for (Financial_Filing__c filing : accepted) {
                sendAcceptedEmail(filing, accountNameById.get(filing.Account__c), oweaId);
            }
        } catch (Exception ex) {
            LPI_ExceptionManager.logException(CLASS_NAME, 'sendEmailsOnStatusChange', ex);
        }
    }

    private static void sendRequestMissingScheduleEmail(
        Financial_Filing__c filing,
        String employerName,
        Id oweaId
    ) {
        Set<String> toAddresses = resolveRecipientEmails(filing);
        if (toAddresses.isEmpty()) {
            return;
        }

        String lang = resolveLanguage(toAddresses);
        String firstName = resolveFirstName(filing);
        String filingNumber = filing.Name != null ? filing.Name : '';
        String reportingYear = filing.Reporting_Year__c != null ? filing.Reporting_Year__c : '';
        String employer = String.isNotBlank(employerName) ? employerName : 'Employer';

        String subject = System.Label.get('', 'EP_FF_Email_RMS_Subject', lang)
            .replace('{0}', filingNumber);
        String greeting = System.Label.get('', 'EP_FF_Email_Greeting', lang)
            .replace('{0}', firstName);
        String bodyIntro = System.Label.get('', 'EP_FF_Email_RMS_Body', lang)
            .replace('{0}', employer)
            .replace('{1}', reportingYear);
        String filingNumberLine = System.Label.get('', 'EP_FF_Email_Filing_Number', lang)
            .replace('{0}', filingNumber);
        String statusLine = System.Label.get('', 'EP_FF_Email_Status', lang)
            .replace('{0}', System.Label.get('', 'EP_FF_Email_RMS_Status_Value', lang));
        String actionLine = System.Label.get('', 'EP_FF_Email_RMS_Action', lang);
        String portalLine = System.Label.get('', 'EP_FF_Email_RMS_Portal', lang)
            .replace('{0}', filingNumber);
        String thankYou = System.Label.get('', 'EP_FF_Email_Thank_You', lang);
        String signature = System.Label.get('', 'EP_FF_Email_Signature', lang);

        String plainBody = greeting + '\n\n' + bodyIntro + '\n\n'
            + filingNumberLine + '\n' + statusLine + '\n\n'
            + actionLine + '\n'
            + portalLine + '\n\n'
            + thankYou + '\n' + signature;

        String htmlBody = '<p>' + greeting + '</p>'
            + '<p>' + bodyIntro + '</p>'
            + '<p>' + filingNumberLine + '<br/>' + statusLine + '</p>'
            + '<p>' + actionLine + '<br/>' + portalLine + '</p>'
            + '<p>' + thankYou + '<br/>' + signature + '</p>';

        sendEmail(toAddresses, subject, plainBody, htmlBody, oweaId);
    }

    private static void sendAcceptedEmail(
        Financial_Filing__c filing,
        String employerName,
        Id oweaId
    ) {
        Set<String> toAddresses = resolveRecipientEmails(filing);
        if (toAddresses.isEmpty()) {
            return;
        }

        String lang = resolveLanguage(toAddresses);
        String firstName = resolveFirstName(filing);
        String filingNumber = filing.Name != null ? filing.Name : '';
        String reportingYear = filing.Reporting_Year__c != null ? filing.Reporting_Year__c : '';
        String employer = String.isNotBlank(employerName) ? employerName : 'Employer';

        String subject = System.Label.get('', 'EP_FF_Email_Accepted_Subject', lang)
            .replace('{0}', filingNumber);
        String greeting = System.Label.get('', 'EP_FF_Email_Greeting', lang)
            .replace('{0}', firstName);
        String bodyIntro = System.Label.get('', 'EP_FF_Email_Accepted_Body', lang)
            .replace('{0}', employer)
            .replace('{1}', reportingYear);
        String filingNumberLine = System.Label.get('', 'EP_FF_Email_Filing_Number', lang)
            .replace('{0}', filingNumber);
        String statusLine = System.Label.get('', 'EP_FF_Email_Status', lang)
            .replace('{0}', System.Label.get('', 'EP_FF_Email_Accepted_Status_Value', lang));
        String actionLine = System.Label.get('', 'EP_FF_Email_Accepted_Action', lang);
        String thankYou = System.Label.get('', 'EP_FF_Email_Thank_You', lang);
        String signature = System.Label.get('', 'EP_FF_Email_Signature', lang);

        String plainBody = greeting + '\n\n' + bodyIntro + '\n\n'
            + filingNumberLine + '\n' + statusLine + '\n\n'
            + actionLine + '\n\n'
            + thankYou + '\n' + signature;

        String htmlBody = '<p>' + greeting + '</p>'
            + '<p>' + bodyIntro + '</p>'
            + '<p>' + filingNumberLine + '<br/>' + statusLine + '</p>'
            + '<p>' + actionLine + '</p>'
            + '<p>' + thankYou + '<br/>' + signature + '</p>';

        sendEmail(toAddresses, subject, plainBody, htmlBody, oweaId);
    }

    private static void sendEmail(
        Set<String> toAddresses,
        String subject,
        String plainBody,
        String htmlBody,
        Id oweaId
    ) {
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setToAddresses(new List<String>(toAddresses));
        email.setCcAddresses(new List<String>{ CC_ADDRESS });
        email.setSubject(subject);
        email.setPlainTextBody(plainBody);
        email.setHtmlBody(htmlBody);
        email.setSaveAsActivity(false);
        email.setUseSignature(false);
        email.setTreatTargetObjectAsRecipient(false);
        if (oweaId != null) {
            email.setOrgWideEmailAddressId(oweaId);
        }

        Messaging.SendEmailResult[] results = Messaging.sendEmail(
            new List<Messaging.SingleEmailMessage>{ email },
            false
        );
        if (results != null && !results.isEmpty() && !results[0].isSuccess()) {
            String errorMsg = 'Financial filing status email failed';
            if (results[0].getErrors() != null && !results[0].getErrors().isEmpty()) {
                errorMsg = results[0].getErrors()[0].getMessage();
            }
            LPI_ExceptionManager.logException(
                CLASS_NAME,
                'sendEmail',
                'EmailSendFailure',
                errorMsg,
                null,
                null
            );
        }
    }

    private static Set<String> resolveRecipientEmails(Financial_Filing__c filing) {
        Set<String> emails = new Set<String>();
        if (String.isNotBlank(filing.Filer_Email__c)) {
            emails.add(filing.Filer_Email__c.trim());
        }
        if (filing.Account__c != null) {
            for (User portalUser : [
                SELECT Email
                FROM User
                WHERE IsActive = true
                  AND ContactId != null
                  AND Contact.AccountId = :filing.Account__c
                  AND Profile.Name = 'Employer Portal User'
                  AND Email != null
                LIMIT 10
            ]) {
                if (String.isNotBlank(portalUser.Email)) {
                    emails.add(portalUser.Email.trim());
                }
            }
        }
        return emails;
    }

    private static String resolveFirstName(Financial_Filing__c filing) {
        if (String.isNotBlank(filing.Filer_First_Name__c)) {
            return filing.Filer_First_Name__c;
        }
        if (String.isNotBlank(filing.Filer_Last_Name__c)) {
            return filing.Filer_Last_Name__c;
        }
        return 'Filer';
    }

    private static String resolveLanguage(Set<String> emails) {
        if (emails == null || emails.isEmpty()) {
            return 'en_US';
        }
        List<User> users = [
            SELECT LanguageLocaleKey
            FROM User
            WHERE IsActive = true
              AND Email IN :emails
              AND LanguageLocaleKey != null
            LIMIT 5
        ];
        for (User u : users) {
            if (u.LanguageLocaleKey != null && u.LanguageLocaleKey.startsWith('fr')) {
                return 'fr';
            }
        }
        return 'en_US';
    }

    private static Map<Id, String> resolveAccountNames(Set<Id> accountIds) {
        Map<Id, String> names = new Map<Id, String>();
        if (accountIds == null || accountIds.isEmpty()) {
            return names;
        }
        for (Account acc : [SELECT Id, Name FROM Account WHERE Id IN :accountIds]) {
            names.put(acc.Id, acc.Name);
        }
        return names;
    }

    private static Id resolveOrgWideEmailAddressId() {
        List<OrgWideEmailAddress> owea = [
            SELECT Id
            FROM OrgWideEmailAddress
            WHERE Address IN (
                'ria.goel+noreply@mtxb2b.com',
                'ayush.dev@mtxb2b.com',
                'shreay.mittal@mtxb2b.com'
            )
            ORDER BY CreatedDate ASC
            LIMIT 1
        ];
        if (!owea.isEmpty()) {
            return owea[0].Id;
        }
        List<OrgWideEmailAddress> anyOwea = [
            SELECT Id
            FROM OrgWideEmailAddress
            LIMIT 1
        ];
        return anyOwea.isEmpty() ? null : anyOwea[0].Id;
    }
}