/**
 * @description       : Controller class to send email notifications using AWS API.
 * @author            : MTX Group Product Team
 * @group             :
 * @last modified on  : 08-02-2024
 * @last modified by  : MTX Group Product Team
 **/
public without sharing class LPI_NotificationCalloutHelper {    
    /**
    * @description Sends email notifications based on a list of Notification__c objects in JSON format.
    * @author MTX Group Product Team
    * @param jsonString (String) The JSON string representing a list of Notification__c objects.
    */
    @future(callout=true)
    public static void sendNotification(String notifPayload) {
        List<Notification__c> notificationList = (List<Notification__c>)Json.deserialize(notifPayload,List<Notification__c>.class);
        try {
            List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
            OrgWideEmailAddress[] owea = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'Ian.Hutt-Borrelli@ibm.com'];
            for (Notification__c notification : notificationList) {
                String emailBody = notification.Description__c != null ? notification.Description__c : '';
                String subject = notification.Subject__c != null ? notification.Subject__c : '';
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(new String[] {notification.Recipient_Email__c, 'Ian.Hutt-Borrelli@ibm.com'});
                mail.setSubject(subject);
                mail.setPlainTextBody(emailBody);
                mail.setWhatId(notification.Individual_Application__c);
                if(String.isNotBlank(owea[0].Id)){
                    mail.setOrgWideEmailAddressId(owea[0].Id);    
                }
                
                // Optional fields
                if (notification.CC_Addresses__c != null && notification.CC_Addresses__c != '') {
                    mail.setCcAddresses(new String[] {notification.CC_Addresses__c});
                }
                
                mailList.add(mail);
            }
            Messaging.SendEmailResult[] results = Messaging.sendEmail(mailList);
        } catch (Exception ex) {
            LPI_ExceptionManager.logException(
                'LPI_NotificationCalloutHelper',
                'sendNotification',
                ex
            );
            throw new AuraHandledException(ex.getMessage());
        }
    }

    public static void sendIAEmail(IndividualApplication ia){
        try {
            Account iaAccount = [
                Select Id, Name, PersonEmail From Account Where Id =: ia.AccountId
            ];
            EmailTemplate emailTemp = new EmailTemplate();
            if(ia.Status == 'Employer Review Completed'){
                emailTemp = [
                    Select Id, Subject, Body from EmailTemplate Where Name = 'IA Employer Review Completed'
                ];
            } else if(ia.Status == 'Additional Doc Upload'){
                emailTemp = [
                    Select Id, Subject, Body from EmailTemplate Where Name = 'IA Employer Review Required'
                ];
            }
            system.debug('###'+emailTemp);
            system.debug('$$$'+iaAccount);
            system.debug('$$$'+ia.Account);
            String emailBody = (String)emailTemp.Body;
            emailBody = emailBody.replace('{!Contact.Name}', iaAccount.Name);
            system.debug('###'+emailTemp);
            Notification__c newNotification = new Notification__c();
            newNotification.Description__c = emailBody;
            newNotification.Individual_Application__c = ia.Id;
            newNotification.Account__c = ia.AccountId;
            newNotification.Subject__c = emailTemp.Subject;
            newNotification.Recipient_Email__c = iaAccount.PersonEmail;
            newNotification.Sender_Email__c = 'Ian.Hutt-Borrelli@ibm.com';
            newNotification.Template_Name__c = 'ApplicationSubmissionNotification';
            insert newNotification;
            // List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
            // OrgWideEmailAddress[] owea = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'shreay.mittal@mtxb2b.com'];
            
            //     // String emailBody = emailTemp.Body != null ? emailTemp.Body : '';
            //     String subject = emailTemp.Subject != null ? emailTemp.Subject : '';
            //     Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            //     mail.setTemplateId(emailTemp.Id);
            //     mail.setToAddresses(new String[] {iaAccount.PersonEmail});
            //     mail.setSubject(subject);
            //     mail.setPlainTextBody(emailBody);
            //     mail.setWhatId(ia.Id);
            //     if(String.isNotBlank(owea[0].Id)){
            //         mail.setOrgWideEmailAddressId(owea[0].Id);    
            //     }
            //     // // Optional fields
            //     // if (notification.CC_Addresses__c != null && notification.CC_Addresses__c != '') {
            //     //     mail.setCcAddresses(new String[] {notification.CC_Addresses__c});
            //     // }
                
            //     mailList.add(mail);
            
            // Messaging.SendEmailResult[] results = Messaging.sendEmail(mailList);
        } catch (Exception e) {
            system.debug('sendIAEmail exception::: '+e);
        }
    }

     public static void sendNotificationWhenUpdate(String notifPayload) {
        System.debug('notifPayload Line 116>>>>'+notifPayload);
        List<Notification__c> notificationList = (List<Notification__c>)Json.deserialize(notifPayload,List<Notification__c>.class);
        System.debug('notificationList>>>>'+notificationList);
        try {
            List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
            OrgWideEmailAddress[] owea = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'Ian.Hutt-Borrelli@ibm.com'];
            for (Notification__c notification : notificationList) {
                String emailBody = notification.Description__c != null ? notification.Description__c : '';
                String subject = notification.Subject__c != null ? notification.Subject__c : '';
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(new String[] {notification.Recipient_Email__c, 'Ian.Hutt-Borrelli@ibm.com'});
                mail.setSubject(subject);
                mail.setPlainTextBody(emailBody);
                mail.setWhatId(notification.Individual_Application__c);
                mail.setSaveAsActivity(false);
                mail.setUseSignature(false);
                mail.setBccSender(false); 
                if(String.isNotBlank(owea[0].Id)){
                    mail.setOrgWideEmailAddressId(owea[0].Id);    
                }
                List<Messaging.EmailFileAttachment> emailFileAttList = getContentVers(notification.Id);
                System.debug('emailFileAttList>>>>'+emailFileAttList);
                if(emailFileAttList.size() > 0) {
                    mail.setFileAttachments(emailFileAttList);   
                }
                // Optional fields
                if (notification.CC_Addresses__c != null && notification.CC_Addresses__c != '') {
                    mail.setCcAddresses(new String[] {notification.CC_Addresses__c});
                }
                
                mailList.add(mail);
            }

            System.debug('Final mail list for sending >>.' + mailList);
            // Send all emails in one batch
            Messaging.SendEmailResult[] results = Messaging.sendEmail(mailList);
			if (results[0].success) 
			{
				System.debug('The email was sent successfully.');
			} else {
				System.debug('The email failed to send: ' +  results[0].errors[0].message);
			}
        } catch (Exception ex) {
            System.debug('EXCEPTION>>>>'+ex);
            LPI_ExceptionManager.logException(
                'LPI_NotificationCalloutHelper',
                'sendNotification',
                ex
            );
            throw new AuraHandledException(ex.getMessage());
        }
    }

    public static List<Messaging.EmailFileAttachment> getContentVers(Id objId) {
		System.debug('Entered getContentVers>>>>');
        List<Messaging.EmailFileAttachment> emailAttachList = new List<Messaging.EmailFileAttachment>();
        List<ContentDocumentLink> CDLs = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =: objId];
		System.debug('CDLs>>>>'+CDLs);
        List <Id> CDIdList = new List <Id> ();
        
        for (ContentDocumentLink nextCDL : CDLs) {
            CDIdList.add(nextCDL.ContentDocumentId); 
        }
		System.debug('CDIdList>>>>'+CDIdList);
        List<ContentDocument> entries = [SELECT Id, Title, FileType FROM ContentDocument WHERE ContentDocument.Id IN :CDIdList];
		System.debug('entries>>>>'+entries);
        if(entries.size() > 0) {
            List<ContentVersion> cvList = [SELECT Id, title, VersionData, FileExtension, ContentDocumentId 
                                           FROM ContentVersion 
                                           WHERE ContentDocumentId IN:entries 
                                           And isLatest = true];

			System.debug('cvList>>>>'+cvList);
            for(ContentVersion cvObj : cvList) {
                emailAttachList.add(setEmailFileAtt(cvObj));            
            }
			System.debug('emailAttachList>>>>'+emailAttachList);
            return emailAttachList;
        }
        return emailAttachList;
    }

    public static Messaging.EmailFileAttachment setEmailFileAtt(ContentVersion cvObj) {
		System.debug('Entered setEmailFileAtt>>>>');
        Messaging.EmailFileAttachment emlAtt = new Messaging.EmailFileAttachment();
        Blob fileData = cvObj.VersionData;
        emlAtt.setFilename(cvObj.title);
        emlAtt.setBody(fileData);
		System.debug('emlAtt>>>>'+emlAtt);
        return emlAtt;
    }
}