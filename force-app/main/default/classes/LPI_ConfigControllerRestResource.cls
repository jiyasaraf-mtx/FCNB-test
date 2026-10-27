/**
 * @author : Anmol Mathur
 * @since : 6th Feb 2023
 * @description : This apex class Captures Request from Mobile and returns required data.
 */

 @RestResource(urlMapping='/ApplicationConfig/*')
 global with sharing class LPI_ConfigControllerRestResource {
       // Exceptions
   public class UnAuthorizedUserException extends Exception {}
     
     /**
      * @author                   Anmol Mathur
      * @description              This is the GET Method of the class which will return all Custom Label as a Mobile Application Config
      * @return                   `void`
      */
   @HTTPGet
   global static void getApplicationConfig() {
     RestResponse res = RestContext.response;
     RestRequest req = RestContext.request;
       
 
         try {
 
             String userId = req.params.get('userId');
 
             // Check if the user is requesting for it's own records
             if (String.isBlank(userId) || String.isNotBlank(userId) && userId != UserInfo.getUserId()) {
                throw new UnAuthorizedUserException();
             }
 
             Map<String, Object> response = new Map<String, Object>();
 
             response.put('imageFileSize', integer.valueOf(Label.Mobile_Config_ImageFileSize));
             response.put('numberOfAttachments', integer.valueOf(Label.Mobile_Config_NumberOfAttachments));
             response.put('otherDocumentFileSize', integer.valueOf(Label.Mobile_Config_OtherDocumentFileSize));
             response.put('videoLength', integer.valueOf(Label.Mobile_Config_VideoLength));
             response.put('videoSize', integer.valueOf(Label.Mobile_Config_VideoSize));
             response.put('syncHistory', integer.valueOf(Label.Mobile_Config_SyncHistory));
             LPI_Integration_Config__mdt intt = LPI_Integration_Config__mdt.getInstance('Onbase');     
             if(intt != null){
                Map<String, Object> obj = new Map<String, Object>();
                obj.put('X-Correlation-Id', intt.X_Correlation_Id__c);
                obj.put('client_secret', intt.Private_Key__c);
                obj.put('client_id',intt.Client_Id__c);
               response.put('onbaseHeaders',obj);   
                response.put('onbaseURL',intt.Auth_End_Point__c);  
             } 
                       
             
             res.statusCode = 200;
             res.responseBody = Blob.valueOf(JSON.serialize(response));
 
         }catch (UnAuthorizedUserException e){
             res.statusCode = 400;
             res.responseBody = Blob.valueOf('User not authorized');
         }catch (Exception e){ 
             res.statusCode = 500;
             res.responseBody = Blob.valueOf(e.getMessage());
         }
   }
 }