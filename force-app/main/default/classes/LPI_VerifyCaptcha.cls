/**
 *
 * @author          : MTX Group Product Team
 * @Description     : This class will Verifying the captcha
 * @history
 * -------------------------------------------------------------------------------------------------------
 * Version      Date                Author                            Details
 *    1         3 Oct, 2022        MTX Group Product Team         Developement
 * -------------------------------------------------------------------------------------------------------
 */
// According to our discussion LPI_VerifyCaptcha will be used by the external user and external users don't have access to user records and other information. So it should be in Without sharing.
public without sharing class LPI_VerifyCaptcha {
    // *************************************** ALL CONSTANTS ************************************************
    public final static String CLASS_NAME = 'LPI_VerifyCaptcha';
    public final static String MAKE_REQUEST = 'makeRequest';
    public final static String VERIFY_RECAPTCHAV2 = 'verifyRecaptchaV2';
    // public final static String VERIFY_CAPTCHA = 'verifyCaptcha';
    public final static String GET_HTTP_RESPONSE = 'getHttpResponse';
    // ******************************************************************************************************
    public static Boolean  enableVerify = true;
    
    /**
    * @author                      : MTX Group Product Team
    * @since                       : 03 Oct 2022
    * @description                 : This method will verify the captcha 
	* @param token                 : data we are passing from LPI_FindUserName Class
	* @param action     		   : data we are passing from LPI_FindUserName Class
	* @param bypassScore           : data we are passing from LPI_FindUserName Class    
	* @return                      : `Map<String, Object>`
    * @last modified by            : MTX Group Product Team
    * @last modified date          : 02 Feb 2023
    * @modified details            : 
   	*/
    public static Map<String, Object> makeRequest(String token, String action, Boolean bypassScore){
        LPI_Recaptcha_Configuration__mdt recapConfig = LPI_Recaptcha_Configuration__mdt.getInstance('Recaptcha');
        Transaction_Log__c log = new Transaction_Log__c();
        log.Method__c = 'Recaptcha V3';
        Boolean validCaptcha = false;
        Map<String, Object> responseMap = new Map<String,Object>();
        try {
            String url = recapConfig.CAPTCHA_URL__c+'?secret='+recapConfig.Recaptcha_V3_Secret_Key__c+
                '&response='+token;
            String body = '{"event":{"secret":"'+recapConfig.Recaptcha_V3_Secret_Key__c+',"response":"'+token+'}}';
            log.Request__c = body;
            Boolean output;   
            String res = getHttpResponse(url);
            log.Response__c = res;
            Map<String, Object> result = (Map<String, Object>)JSON.deserializeUntyped(res);
            
            if(result != null
               && result.containsKey('success')
               && (Boolean)result.get('success')==true
               && bypassScore==true ){
                   validCaptcha =true;
               }
            else if(result != null && result.containsKey('score')){
                if( ((Decimal)result.get('score')) >= recapConfig.Recaptcha_Minimum_Score__c){
                    validCaptcha = true;
                }
            }
            if( validCaptcha ) {
                Integer expiryTimeInMins = Integer.valueOf( recapConfig.Transaction_Log_Expiry_Time_in_minutes__c ) ;
                log.Expiration_Date_Time__c = System.now().addMinutes( expiryTimeInMins );
                log.Status__c = 'Verified';
                log.Score__c = ( result != null && result.containsKey('score') ) ? ((Decimal)result.get('score')) : null;
            }
            
        } catch (Exception e) {
            responseMap.put('valid', validCaptcha);   
            responseMap.put('ErrorMessage', e.getMessage());
            LPI_ExceptionManager.logException(
                CLASS_NAME,
                MAKE_REQUEST,
                e
            );
        }
        LPI_WithoutSharingUtility.insertSObject(log);
        responseMap.put('valid', validCaptcha);
        
        return responseMap;
    }
    
    /**
    * @author                      : MTX Group Product Team
    * @since                       : 03 Oct 2022
    * @description                 : This method will verify the captcha version v2
	* @param recaptchaResponse     : data we are passing from LPI_FindUserName Class   
	* @return                      : `Map<String, Object>`
    * @last modified by            : MTX Group Product Team
    * @last modified date          : 02 Feb 2023
    * @modified details            : 
    */
    public static Map<String, Object> verifyRecaptchaV2(String recaptchaResponse){
        LPI_Recaptcha_Configuration__mdt recapConfig = LPI_Recaptcha_Configuration__mdt.getInstance('Recaptcha');
        Transaction_Log__c log = new Transaction_Log__c();
        log.Method__c = 'Recaptcha V2';
        String token  = recaptchaResponse;
        Boolean validCaptcha = false;
        Map<String, Object> responseMap = new Map<String,Object>();
        try {
            String url = recapConfig.CAPTCHA_URL__c+'?secret='+recapConfig.Recaptcha_V2_Secret_Key__c+
            '&response='+token;
            String body = '{"event":{"secret":"'+recapConfig.Recaptcha_V2_Secret_Key__c+',"response":"'+token+'}}';
            log.Request__c = body;
            Boolean output;
            String res = getHttpResponse(url);
  
            log.Response__c = res;
            Map<String, Object> result = (Map<String, Object>)JSON.deserializeUntyped(res);
                if(Boolean.valueOf(result.get('success'))){
                    validCaptcha = true;
                }
                if( validCaptcha ) {
                 Integer expiryTimeInMins = Integer.valueOf( recapConfig.Transaction_Log_Expiry_Time_in_minutes__c ) ;
                 log.Expiration_Date_Time__c = System.now().addMinutes( expiryTimeInMins );
                 log.Status__c = 'Verified';
             }
           
         } catch (Exception e) {
             responseMap.put('ErrorMessage', e.getMessage());
             LPI_ExceptionManager.logException(
               CLASS_NAME,
               VERIFY_RECAPTCHAV2,
               e
           );

         }
         LPI_WithoutSharingUtility.insertSObject(log);
         responseMap.put('valid', validCaptcha);
        return responseMap;
    }

    
   /**
    * @author                      : MTX Group Product Team
    * @since                       : 02 Feb 2023
    * @description                 : This method will return HTTP response
	* @param url                   : data we are passing from respective methods   
	* @return                      : `String`
    * @last modified by            : MTX Group Product Team
    * @last modified date          : 02 Feb 2023
    * @modified details            : 
    */
    public static string getHttpResponse(String url){
        try{
            HttpResponse response = null;
            HttpRequest req = new HttpRequest();
            req.setEndpoint(url); 
            req.setMethod('POST');
            req.setHeader('accept', 'application/json');
            req.setHeader('Content-Length', '0');
            req.setHeader('Content-Type', 'application/json');
           
            Http http = new Http();
            response = http.send(req);
            return response.getBody();
        } catch(Exception e){
            LPI_ExceptionManager.logException( CLASS_NAME, GET_HTTP_RESPONSE, e );
            return null;
        }
    }

    public class RecaptchaResponseWrapper{
        public String response;
        public String action;
        public Boolean bs;
        
        public RecaptchaResponseWrapper(){
            this.response = '';
            this.action = '';
            this.bs = false;
        }
    }

}