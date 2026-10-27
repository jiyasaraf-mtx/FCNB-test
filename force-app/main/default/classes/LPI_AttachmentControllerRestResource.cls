/**
 * @author : Anmol Mathur
 * @since : 31st Jan 2023
 * @description : This apex class Captures Request from Mobile and returns required data.
 */

 @RestResource(urlMapping='/VisitAttachments/*')
 global with sharing class LPI_AttachmentControllerRestResource {
 
     /**
      * @author                   Anmol Mathur
      * @description              This is the POST Method of the class which will create a new attachment.
      * @return                   `void`
      */
   @HTTPPost
   global static void createNewAttachment() {
 
     RestRequest req = RestContext.request;
     RestResponse res = RestContext.response;
     APIResponse objResponse = new APIResponse();
 
     AttachmentPOSTRequest ehelper;
     String jsonStr;
 
     try {
         
         if (req.requestBody != null) {
             jsonStr = req.requestBody.toString();
         }
         ehelper = (AttachmentPOSTRequest) System.JSON.deserialize(jsonStr, AttachmentPOSTRequest.class);
        
         if(ehelper != null && String.isNotEmpty(ehelper.userId) && String.isNotEmpty(ehelper.onBaseDocumentId) && String.isNotEmpty(ehelper.visitId)) {
             
                 // Check if the user is requesting for it's own records
                 if (String.isNotBlank(ehelper.userId) && ehelper.userId != UserInfo.getUserId()) {
                    throw new UnAuthorizedUserException();
                 }

                 List<String> fields = new List<String>{'Id','Board_Name__c'};

                 List<Visit> visitRec = LPI_VisitControllerDAO.getVistListByDynamicQuery(
                    fields,
                    'Id = \'' +
                    ehelper.visitId +
                    '\'',
                    1,
                    null,
                    null
                );
 
                 // Create a new Application Doucment object to link the onBase Document Id to a record
                 Application_Document__c applicationDocument = new Application_Document__c();
                 applicationDocument.Inspection__c = ehelper.visitId;
                 applicationDocument.Upload_To_Onbase__c = true;
                 applicationDocument.Is_Doc_Uploaded_by_Internal_User__c = true;
                 applicationDocument.Document_Name__c = ehelper.typeOfDocument;
                 if (String.isNotEmpty(ehelper.onBasePayload)) {
                 applicationDocument.Onbase_Payload__c = ehelper.onBasePayload;
                 }
                 applicationDocument.File_Name__c = ehelper.fileName;
                 if (!visitRec.isEmpty()) {
                    applicationDocument.Board_name__c = visitRec[0]?.Board_Name__c;
                 }
                 
                 if(String.isNotEmpty(ehelper.assessmentId)){
                     applicationDocument.Inspection_Assessment_Indicator__c = ehelper.assessmentId;
                 }

                //  if(String.isNotEmpty(ehelper.externalId)){
                //      applicationDocument.Ipad_External_Id__c = ehelper.externalId;
                //  }


                 applicationDocument.Status__c = 'Submitted';

                 
                 
                 // Insert the Application  Doucment object
                 Database.SaveResult insertResult = Database.insert(applicationDocument);
                 

                if(insertResult.isSuccess()){
                    // GetContentDocumentId from  ContentVersion
                    ContentVersion[] cv = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :ehelper.onBaseDocumentId];
                   
                   
                    if(cv.size() >0){
                        cv[0].Guest_Record_fileupload__c = insertResult.getId();
                        Database.update(cv);
                        
                    }
                                     
   
                 }

                 // Build Response Object
                 objResponse.error = '';
                 objResponse.status = 'Success';
                 objResponse.response = new AttachmentPOSTResponse(insertResult);
 
                 // Send Response
                 res.responseBody = Blob.valueOf(JSON.serialize(objResponse));
                 res.statusCode = 200;
                 return;
         } 
         
         objResponse.error = 'Cannot Parse the Request';
         objResponse.status = 'Fail';
         res.responseBody = Blob.valueOf(JSON.serialize(objResponse));
         res.statusCode = 400;
 
     } catch (UnAuthorizedUserException e){
         res.statusCode = 500;
         res.responseBody = Blob.valueOf('User not authorized to create new Attachment');
     } catch (Exception ex) {
         res.statusCode = 400;
         res.responseBody = Blob.valueOf('Error with the request parameters' + ex.getMessage());
     }
   }
     
     /**
      * @author                   Anmol Mathur
      * @description              This is the GET Method of the class which will return all Attachments associated with the user id passed in the parameter
      * @return                   `void`
      */
   @HTTPGet
   global static void getVisitAttachments() {
 
     RestResponse res = RestContext.response;
     RestRequest req = RestContext.request;
         try {
 
             String userId = req.params.get('userId');
 
             // Check if the user is requesting for it's own records
            // if (String.isNotBlank(userId) && userId != UserInfo.getUserId()) {
            //    throw new UnAuthorizedUserException();
            // }
            String fileId = req.params.get('fileId');
            if(String.isNotBlank(fileId)){
                
                List<Application_Document__c> appDocList = LPI_ApplicationDocumentDAO.getApplicantDocumentByDymanicQuery('Id,File_Name__c,Onbase_Document_Id__c,(SELECT ID,ContentDocumentId FROM ContentDocumentLinks)', 'Id = \''+String.escapeSingleQuotes(fileId) + '\'', null, null, null);
                if(appDocList.isEmpty()){
                    res.statusCode = 200;
                    res.responseBody = Blob.valueOf('File not found');
                }
                if(String.isNotBlank(appDocList[0].Onbase_Document_Id__c)){
                    //Blob apiResponse = LPI_OnBaseIntegrationController.callDeleteDownloadApi(appDocList[0].Onbase_Document_Id__c,'GET');
           
                    //  res.setBodyAsBlob(apiResponse);
                   //res.responseBody = apiResponse;
                      
                   res.statusCode = 200;  
                } else{
                    res.statusCode = 200;
                    res.responseBody = Blob.valueOf('File not found');
                }   
                  
             
         }else{
           
             Set<Id> visitIds = new Set<Id>();
             if (req.params.containsKey('visitIds')) {
                String previousVisitIds = req.params.get('visitIds');  
                if(String.isNotBlank(previousVisitIds)){
 
                   List<String> idsPrevious = previousVisitIds.split(',');
                   for(String idPrevious : idsPrevious){
                     visitIds.add(idPrevious);
                   }
 
                }             
            }else{
             visitIds = LPI_VisitControllerDAO.getAllVisitIDs(userId);
            }
 
             if (visitIds != null) {
                 List<Application_Document__c> attachementAll = getAllAttachments(visitIds);
                 Set<Id> attchmentIds = new Set<Id>();
                    for(Application_Document__c attachement: attachementAll){
                        if(String.isEmpty(attachement.Onbase_Document_Id__c)){
                            attchmentIds.add(attachement.id);
                        }
                       
                    } 

                if(!attchmentIds.isEmpty()){
                    String stringToQuery = 'Id, LinkedEntityId, ContentDocumentId, ContentDocument.FileType, ContentDocument.FileExtension, ContentDocument.LatestPublishedVersion.Title, ContentDocument.LatestPublishedVersion.VersionDataUrl, ContentDocument.LatestPublishedVersionId';
                    String whereClause = 'LinkedEntityId IN ' + LPI_ServiceUtility.getStringValuesBySet(attchmentIds);
                     
                    //Creating list of ContentDocumentLink
                   LIST<ContentDocumentLink> allSFAttachments = LPI_ContentDocumentLinkDAO.getContentDocumentLinkByDymanicQuery(
                        stringToQuery,
                        whereClause,
                        null,
                        null,
                        null
                    );    
                 Map<Id, String> sfAttachmentsMap = new Map<Id, String>();   

                for (ContentDocumentLink objAttachment : allSFAttachments) {
                    sfAttachmentsMap.put(objAttachment.LinkedEntityId,objAttachment.ContentDocument.LatestPublishedVersion.VersionDataUrl);               
                }
                 
                 // Bind all together in Wrapper and send response back
                  List<AttachmentResponseWrapper> attachmentWrap = new List<AttachmentResponseWrapper>();
                   
                     for (Application_Document__c objAttachment : attachementAll) {
                         attachmentWrap.add(new AttachmentResponseWrapper(objAttachment,sfAttachmentsMap.get(objAttachment.id)));
                     }
                     res.statusCode = 200;
                     res.responseBody = Blob.valueOf(JSON.serialize(attachmentWrap));
                     return;
                }
               
                
              
             }
             
             res.responseBody = Blob.valueOf('No record found');
             res.statusCode = 200;
         }
         } catch (System.StringException e){
             res.statusCode = 400;
             res.responseBody = Blob.valueOf('Param: userId is not a valid Id');
         } catch (UnAuthorizedUserException e){
             res.statusCode = 500;
             res.responseBody = Blob.valueOf('User not authorized to access other users attachments');
         } catch (System.QueryException e){
             res.statusCode = 404;
             res.responseBody = Blob.valueOf('Requested QueryException '+e);
         } catch (Exception e){ //something else happened
             res.statusCode = 500;
             res.responseBody = Blob.valueOf(e.getMessage());
         }
   }
 
 
  /**
       * @author                   Anmol Mathur
       * @description              This method will return a List of AssessmentTask which are associated with the visitIds
       * @param :                  Set<Id> visitIds
       * @return                   `List<Application_Document__c>`
       */
       private static List<Application_Document__c> getAllAttachments(Set<Id> visitIds) {     
         return  
         [
             SELECT Id, Name,Document_Name__c,File_Name__c , Inspection__c, Onbase_Document_Id__c, Inspection_Assessment_Indicator__c
             FROM Application_Document__c 
             WHERE Inspection__c IN :visitIds 
         ];
     }
 
     
 
   // Exceptions
   public class UnAuthorizedUserException extends Exception {}
 
   // Wrapper Classes
   /**
      * @description : Wrapper Class which contains Attachment object's manupulated data.
     */
   public class AttachmentResponseWrapper{
         public String visitId;  
         public String assessmentId;  
         public String externalId;
         public String attachmentMetaData;
         public String type;
         public String name;
         public String id;
         public String downloadUrl;
         public String fileName;
 
         public AttachmentResponseWrapper(Application_Document__c document, String url){
             this.visitId = document.Inspection__c;
             this.assessmentId = document.Inspection_Assessment_Indicator__c;   
             //this.externalId = document.Ipad_External_Id__c != null ? document.Ipad_External_Id__c  : document.Id;
             this.attachmentMetaData = '';
             this.type = document.Document_Name__c;
             this.name =  document.File_Name__c != null ? document.File_Name__c  : document.Name;
             this.id = document.Id;
             this.downloadUrl = (url != null && String.isNotEmpty(url))? 'SF#'+url : document.Id;
             //Remove sending onBaseDocument id instead send reacord id to fetch the file from record on get call
             //this.downloadUrl = (url != null && String.isNotEmpty(url))? 'SF#'+url : ( String.isNotEmpty(document.Onbase_Document_Id__c)?document.Onbase_Document_Id__c:'');
             this.fileName = document.File_Name__c != null ? document.File_Name__c  : document.Name;
         }
     }
 
     /**
         * @description : Wrapper Class for parsing POST Request
     */
     public class AttachmentPOSTRequest {
     
         public String userId;
         public String onBaseDocumentId;
         public String assessmentId;
         public String visitId;
         public String typeOfDocument;
         public String fileName;
         public String externalId;
         public String onBasePayload;
 
     }
 
     /**
         * @description : Wrapper Class for POST Response
     */
     public class APIResponse {
         public String status;
         public String error;
         public AttachmentPOSTResponse response;
     }
 
     public class AttachmentPOSTResponse {
     
         public String id;
         public String result;
         public String error;
         public String syncTime;
 
         public AttachmentPOSTResponse(Database.SaveResult saveResult) {
             if (saveResult != null) {
                 DateTime currentDateTime = Datetime.now();
                 this.id = saveResult.getId();
                 this.syncTime = String.valueOf(currentDateTime);
                 if (saveResult.isSuccess()) {
                     this.error = ''; 
                     this.result = 'Synced';
                 } else {
                     this.result = 'Failed';
                     List<String> errorMessages = new List<String>();
                     for(Database.Error err : saveResult.getErrors()) {
                         errorMessages.add(err.getStatusCode() + ': ' + err.getMessage());
                     }
                     this.error = String.join(errorMessages, ' ');
                 }
             }
         }
     }
 }