/**
 * @                  : 
 * @author            : Abel David Solomon
 * @group             : 
 * @last modified on  : 08-02-2024
 * @last modified by  : Abel David Solomon
**/
public without sharing class LPITicketTriggerHandler {
    public static void submittedStatus(List<Ticket__c> listOfTickets){
        for(Ticket__c ticket : listOfTickets){
            if(ticket.Ticket_Status__c == 'Submitted'){
                EmailTemplate emailTemp = [
                    Select Id, Subject, Body from EmailTemplate Where Name = 'Ticket submission'
                ];
                String subject = (String)emailTemp.Subject;
                subject = subject.replace('{!Ticket__c.Name}', ticket.Name);
                String emailBody = (String)emailTemp.Body;
                emailBody = emailBody.replace('{!Ticket__c.Name}', ticket.Name);
                emailBody = emailBody.replace('[Customers Name]', ticket.First_Name__c+' '+ticket.Last_Name__c);
                emailBody = emailBody.replace('[Date]', String.valueOf(ticket.CreatedDate));
                emailBody = emailBody.replace('[Brief summary of the issue or request]', ticket.Description__c);
                List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
                OrgWideEmailAddress[] owea = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'shreay.mittal@mtxb2b.com'];
                
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setTemplateId(emailTemp.Id);
                mail.setToAddresses(new String[] {ticket.Email__c});
                mail.setSubject(subject);
                mail.setPlainTextBody(emailBody);
                mail.setWhatId(ticket.Id);
                if(String.isNotBlank(owea[0].Id)){
                    mail.setOrgWideEmailAddressId(owea[0].Id);    
                }
                mailList.add(mail);
                Messaging.SendEmailResult[] results = Messaging.sendEmail(mailList);
        }
    }
}
    
    public static void updateStatus(List<Ticket__c> listOfTickets,Map<Id,Ticket__c> mapOfTickets){
        for(Ticket__c ticket : listOfTickets){
            if(ticket.Ticket_Status__c == 'Resolved' && ticket.Ticket_Status__c !=mapOfTickets.get(ticket.Id).Ticket_Status__c){
                EmailTemplate emailTemp = [
                    Select Id, Subject, Body from EmailTemplate Where Name = 'Ticket resolved'
                ];
                String subject = (String)emailTemp.Subject;
                // subject = subject.replace('{!Ticket__c.Name}', ticket.Name);
                String emailBody = (String)emailTemp.Body;
                emailBody = emailBody.replace('[Recipients Name]', ticket.First_Name__c+' '+ticket.Last_Name__c);
                emailBody = emailBody.replace('#[Ticket Number]', ticket.Name);
                // emailBody = emailBody.replace('[Date]', ticket.CreatedDate);
                // emailBody = emailBody.replace('[Brief summary of the issue or request]', ticket.Description__c);
                List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
                OrgWideEmailAddress[] owea = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'shreay.mittal@mtxb2b.com'];
                
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setTemplateId(emailTemp.Id);
                mail.setToAddresses(new String[] {ticket.Email__c});
                mail.setSubject(subject);
                mail.setPlainTextBody(emailBody);
                mail.setWhatId(ticket.Id);
                if(String.isNotBlank(owea[0].Id)){
                    mail.setOrgWideEmailAddressId(owea[0].Id);    
                }
                mailList.add(mail);
                Messaging.SendEmailResult[] results = Messaging.sendEmail(mailList);
            }
        }
    }
}