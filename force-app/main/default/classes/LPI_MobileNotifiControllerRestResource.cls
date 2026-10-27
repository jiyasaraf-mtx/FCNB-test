/**
 * @author - Umangshu Chouhan
 * @since - June,05,2023
 * @description - Created this class to handle user notifications rest API calls.
 */

@RestResource(urlMapping='/UserNotifications/*')
global with sharing class LPI_MobileNotifiControllerRestResource {
    
    /**
     * @author - Umangshu Chouhan
     * @since - June, 05, 2023
     * @description - Fetch all user mobile push notifictions send from bckend.
     * params - userId
     * response - list of all notifications sent to particular user and record type of Mobile Notification.
     */
    @HTTPGet
    global static void getUserNotifications() {

    RestResponse res = RestContext.response;
    RestRequest req = RestContext.request;
        try {

            String userId = req.params.get('userId');

            // Check if the user is requesting for it's own records
            if (String.isNotBlank(userId) && userId != UserInfo.getUserId()) {
               throw new UnAuthorizedUserException();
            }

            List<Notification__c> allNotifications = [
                Select Id, CreatedDate, Name, Description__c, Url_Param_Json__c,is_Read__c 
                FROM Notification__c 
                WHERE RecordType.Name = 'Mobile Notification' AND isDeleted = false AND Is_Resolved__c = false AND User__c =: userId 
                ORDER BY CreatedDate desc LIMIT 100
            ];
            
            if (allNotifications.size() > 0) {
                // Bind all together in Wrapper and send response back
                List<MobileNotificationResponseWrapper> notifWrap = new List<MobileNotificationResponseWrapper>();
                for (Notification__c objNotification : allNotifications) {
                    notifWrap.add(new MobileNotificationResponseWrapper(objNotification));
                }
                
                res.responseBody = Blob.valueOf(JSON.serialize(notifWrap));
                res.statusCode = 200;
                return;
            }       
            
            res.responseBody = Blob.valueOf('Cannot find any notifications');
            res.statusCode = 200;

        } catch (System.StringException e){
            res.statusCode = 400;
            res.responseBody = Blob.valueOf('Param: userId is not a valid Id');
        } catch (UnAuthorizedUserException e){
            res.statusCode = 500;
            res.responseBody = Blob.valueOf('User not authorized to access other users Notes');
        } catch (System.QueryException e){
            res.statusCode = 404;
            res.responseBody = Blob.valueOf('Requested User not found');
        } catch (Exception e){ //something else happened
            res.statusCode = 500;
            res.responseBody = Blob.valueOf(e.getMessage());
        }
  }

  // Exceptions
  public class UnAuthorizedUserException extends Exception {}

  // Wrapper Classes
  /**
     * @description : Wrapper Class which contains mobile notification
    */
  public class MobileNotificationResponseWrapper{
    	public String id;  
        public String createdAt;  
        public String title;
        public String description;    
        public String data;
        public Boolean isRead;

        public MobileNotificationResponseWrapper(Notification__c notification){
            this.id = notification.Id;
            this.createdAt = string.valueOfGmt(notification.CreatedDate);
            this.title = notification.Name;
            this.description = notification.Description__c;
            this.data = notification.Url_Param_Json__c;
            this.isRead = notification.is_Read__c;
        }
    }

    /**
     * @author                   Umangshu Chouhan
     * @description              Mark notifications is read.
     * @return                   `void`
     */
  @HTTPPost
  global static void markReadNotifications() {

    RestRequest req = RestContext.request;
    RestResponse res = RestContext.response;
    APIResponse objResponse = new APIResponse();
    objResponse.response = new List<Object>();

    NotificationPOSTRequest ehelper;
    String jsonStr;

    try {
        
        if (req.requestBody != null) {
            jsonStr = req.requestBody.toString();
        }
        ehelper = (NotificationPOSTRequest) System.JSON.deserialize(jsonStr, NotificationPOSTRequest.class);
       
        if(ehelper != null) {
            if (String.isNotBlank(ehelper.userId) && ehelper.userId != UserInfo.getUserId()) {
                throw new UnAuthorizedUserException();
            }
            if (!ehelper.notifications.isEmpty()) {
                Notification__c[] allNotifications = new List<Notification__c>();
                for (Notification objNotification : ehelper.notifications) {
                    Notification__c notification = new Notification__c();
                    notification.Id = objNotification.id;
                    if (objNotification.isRead != null) {
                        notification.is_Read__c = objNotification.isRead;    
                    }
                    if (objNotification.isDeleted != null) {
                        notification.Is_Resolved__c = objNotification.isDeleted;
                    }
                    allNotifications.add(notification);
                }
                // TODO: Add transaction rollback
                //List<Database.SaveResult> updateResults = Database.update(allNotifications);
                LPI_WithoutSharingUtility.updateSObjectRecord(allNotifications);
                objResponse.error = '';
                objResponse.status = 'Success';
                res.responseBody = Blob.valueOf(JSON.serialize(objResponse));
                res.statusCode = 200;
                return;
            } else {
                 objResponse.error = 'Cannot Parse the Request';
                 objResponse.status = 'Fail';
                 res.responseBody = Blob.valueOf(JSON.serialize(objResponse));
                 res.statusCode = 400;
            }
        }

        objResponse.error = 'No Notifications found';
        objResponse.status = 'Fail';
        res.responseBody = Blob.valueOf(JSON.serialize(objResponse));
        res.statusCode = 400;

    } catch (UnAuthorizedUserException e){
        res.statusCode = 500;
        res.responseBody = Blob.valueOf('User not authorized to submit other users visit');
    } catch (Exception ex) {
        res.statusCode = 400;
        res.responseBody = Blob.valueOf('Error with the request parameters' + ex.getMessage());
    }
  }

  // Wrapper Classes
    /**
        * @description : Wrapper Class for parsing POST Request
    */
    public class NotificationPOSTRequest {
        public String userId;
        public List<Notification> notifications;
    }

     public class Notification {
        public String id;
        public Boolean isRead;
        public Boolean isDeleted;
    }

    public class APIResponse {
        public String status;
        public String error;
        List<Object> response;
    }
}