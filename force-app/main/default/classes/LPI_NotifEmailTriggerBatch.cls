/**
 * @description       : This Batch is Used to Send Notifications via AWS for Bulk Notification Records.
 * @author            : Vamsi Mudaliar
 * @group             : MTX Group Inc
 * @last modified on  : 05-29-2024
 * @last modified by  : Amit Agrawal
**/
public with sharing class LPI_NotifEmailTriggerBatch  implements Database.Batchable<sObject>, Database.AllowsCallouts{
    // Contains List of Notification Records for Which Email Needs to be sent.
    private List<Notification__c> recordsToProcess;
    
    /**
    * @description Chaining Batch Class.
    * @author Vamsi Mudaliar | 06-20-2023 
    * @param recordsToProcess 
    **/
    public LPI_NotifEmailTriggerBatch(List<Notification__c> recordsToProcess) {
      
        this.recordsToProcess = (recordsToProcess!=null?recordsToProcess:new List<Notification__c>());
    }

    public List<Notification__c> start(Database.BatchableContext BC) {
        return this.recordsToProcess;
     }

     /**
     * @author                          : Vamsi Mudaliar
     * @since                           : 21 June 2023
     * @description                     : This Method is used to Send Notification emails via AWS for a defult batch size of 100 or less.
     * @param bc                        : `Database.BatchableContext`
     * @param recordList                : `List<Notification__c>`
	 * @return                          : `void`
     * @last modified by                : Amit Agrawal
     * @last modified date              : 21 June 2023
     * @modified details                : Code Review Fixes
   */
     public void execute(Database.BatchableContext BC, List<Notification__c> recordList) {         
        try {
            // Fetch the Metadata record.
            Notification_Message__mdt notificationMessage = Notification_Message__mdt.getInstance(
                'Email_Configuration_Data'
            );
            LPI_Bypass_API__mdt bypassAWSApi = LPI_Bypass_API__mdt.getInstance('Bypass_API_Config');

            // Null Check.
            if (
                recordList.isEmpty() ||
                notificationMessage == null ||
                String.isBlank(notificationMessage.Description__c) ||
                bypassAWSApi == NULL || bypassAWSApi.AWS_Email__c){
                return;
            }
            // Contains Important Info About Sender Email and Config Set name.
            Map<String, Object> emailConfigMap = (Map<String, Object>) JSON.deserializeUntyped(
                notificationMessage.Description__c
            );
            /*LPI_Wrapper.AWSEmailWrapper wrapper =  LPI_ServiceUtility.createNotificationEmailWrapper(emailConfigMap);

            for (Notification__c rec : recordList) {
                if(String.isBlank(rec.Recipient_Email__c) || String.isBlank(rec.Template_Name__c)){
                    continue;
                }
                wrapper.Destinations.add(LPI_ServiceUtility.createDestinationsForEmailTemplate(rec));
            }*/

            LPI_Integration_Config__mdt azureAuth = LPI_Integration_Config__mdt.getInstance('AzureAuth');
            LPI_Integration_Config__mdt awsAuth = LPI_Integration_Config__mdt.getInstance('AWSAuth');
            if(azureAuth == null || awsAuth== null){
                return;
            }
            HttpRequest req = new HttpRequest();
            req.setEndpoint(azureAuth.Auth_End_Point__c );
            req.setMethod('POST');
            String reqbody = 'grant_type=client_credentials&client_id='+azureAuth.Client_Id__c+'&client_secret='+azureAuth.Private_Key__c;
            req.setBody(reqBody);
            Http http = new Http();
            HttpResponse response = http.send(req);
            Map<String, Object> deserialized = (Map<String, Object>) JSON.deserializeUntyped(
            response.getBody());

            HttpRequest request = new HttpRequest();
            request.setEndPoint(awsAuth.Auth_End_Point__c);
            request.setMethod('POST');
            request.setHeader('Content-Type', awsAuth.Auth_Content_Type__c);
            request.setHeader('Authorization', 'Bearer '+(String)deserialized.get('access_token'));
            //request.setBody(JSON.serialize(wrapper));
            new HTTP().send(request);        
        }
        catch(Exception ex) {
            LPI_ExceptionManager.logException(
                'LPI_NotifEmailTriggerBatch',
                'execute',
                ex
            );
            throw new AuraHandledException(ex.getMessage());
        }
    }   

    public void finish(Database.BatchableContext BC){   
        // POST BATCH EXECUTION LOGIC  
    }


}