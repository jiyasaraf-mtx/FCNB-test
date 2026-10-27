public class SendIAEmailFromFlow {
    public class EmailRequest {
        @InvocableVariable(label='IA ID' required=true)
        public Id recordId;

        @InvocableVariable(label='Email Template Name' required=true)
        public String templateName; 
    }

    @InvocableMethod(label='Send IA Email From Template' )
    public static void sendIAEmail(List<EmailRequest> requests) {
        if (requests.isEmpty() || requests[0].recordId == null || String.isBlank(requests[0].templateName)) {
            System.debug('SendEmailFromFlow Error: The request from the Flow is missing a Record ID or Template Name.');
            return;
        }

        EmailRequest req = requests[0];

        try {
            List<IndividualApplication> iaDetails = [SELECT Id,SavedApplicationRef.Contact__r.Name, SavedApplicationRef.Contact__r.Email,Name,Applicant_Full_Name__c,Applicant_submission_Date__c 
                                               FROM IndividualApplication 
                                               WHERE Id = :req.recordId 
                                               LIMIT 1];


            if (iaDetails.isEmpty()) {
                System.debug('SendEmailFromFlow Error: No IA found with ID: ' + req.recordId);
                return;
            }
            IndividualApplication ia = iaDetails[0];
            
            List<EmailTemplate> templates = [
                SELECT Name, Subject, HtmlValue, Body 
                FROM EmailTemplate 
                WHERE Name = :req.templateName 
                LIMIT 1
            ];

            if (templates.isEmpty()) {
                System.debug('SendEmailFromFlow Error: No Email Template found with Name: ' + req.templateName);
                return;
            }
            System.debug('template Name'+templates[0].Name);
            EmailTemplate template = templates[0];
            date SubmittedDate = date.valueOf(ia.Applicant_submission_Date__c);
            String subject = template.Subject;
            String htmlBody = template.HtmlValue != null ? template.HtmlValue : template.Body;
            String portalLink = 'https://mtx-lpi-psf-core--widpi.sandbox.my.site.com/s/';
    
            //if(template.Name == 'Revocation Letter Email'){
            subject = subject.replace('[Application_Number]', ia.Name);
            //}
            htmlBody = htmlBody.replace('[Application_Number]', ia.Name);
            htmlBody = htmlBody.replace('[Portal_Link]','<a href="' + portalLink + '" target="_blank">Portal</a>');
            htmlBody = htmlBody.replace('[Submitted_Date]', string.valueof(SubmittedDate));
            htmlBody = htmlBody.replace('[Applicant]', ia.Applicant_Full_Name__c);

            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            
            List<String> recipientEmails = new List<String>();
            //if(ia.SavedApplicationRef.Contact__r.Email != null){
                recipientEmails.add(ia.SavedApplicationRef.Contact__r.Email);
            //}
            System.debug('recipientEmails@@@....'+recipientEmails);
            if(recipientEmails.isEmpty()){
                System.debug('SendEmailFromFlow Error: No valid recipients found. The Applicant contact is missing or has no email, and no fallback Authorized Representatives could be found.');
                return;
            }
            mail.setToAddresses(recipientEmails);
            mail.setSubject(subject);
            mail.setHtmlBody(htmlBody);
            
            List<OrgWideEmailAddress> owes = [SELECT Id FROM OrgWideEmailAddress WHERE DisplayName = 'No-Reply' LIMIT 1];
            if(!owes.isEmpty()){
               mail.setOrgWideEmailAddressId(owes[0].Id);
            }

            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });

        } catch (Exception e) {
            System.debug('SendEmailFromFlow CRITICAL Error: ' + e.getMessage() + ' at line ' + e.getLineNumber() + ' Stacktrace: ' + e.getStackTraceString());
        }
    }
}