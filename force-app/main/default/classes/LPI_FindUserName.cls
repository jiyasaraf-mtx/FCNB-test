/**
 *
 * @author          : MTX Group Product Team
 * @Description     : This class will retrieve the username
 
 */

public without sharing class LPI_FindUserName {
     
   public final static String CLASS_NAME = 'LPI_FindUserName';
   public final static String FETCH_FORGET_USERNAME = 'fetchForgetUsernameFormWrapper';
   public final static String DOFINISH_FORGET_USERNAME_CAPCTCHA = 'doFinishForgetUsernameCapctcha';
   public final static String FIND_CONTACT = 'findContact';
   public final static String IS_RECAPTCHA_DISABLED = 'isRecaptchaDisabled';
   public final static String GET_TODAY_DATE = 'getTodayDate';
    
   /**
    * @author                      : MTX Group Product Team
    * @since                       : 01 Oct 2022
    * @description                 : This method will return wrapper 
    * @return                      : `ResponseWrapper`
    * @last modified by            : MTX Group Product Team
    * @last modified date          : 28 Sep 2023
    * @modified details            : 
   */
   @AuraEnabled
   public static ForgetUsernameFormWrapper fetchForgetUsernameFormWrapper() {
       try{
           ForgetUsernameFormWrapper wr = new ForgetUsernameFormWrapper();
       	   return wr; 
       } catch(Exception e){
           LPI_ExceptionManager.logException(
               CLASS_NAME,
               FETCH_FORGET_USERNAME,
               e
           );
           return null;
       }   
   }

   public class ForgetUsernameFormWrapper {
       @AuraEnabled
       public String firstName;
       @AuraEnabled
       public String lastName;
       @AuraEnabled
       public String dateOfBirth;
       @AuraEnabled
       public String securityQuestionAnswer;
       @AuraEnabled
       public String businessName;
       @AuraEnabled
       public String uniqueIdentificationNumber;
       @AuraEnabled
       public String identificationType;
       @AuraEnabled
       public Boolean isIndividualForgotUsername;
       @AuraEnabled
       public Boolean isBusinessForgotUsername;

       public ForgetUsernameFormWrapper() {
           firstName = '';
           lastName = '';
           securityQuestionAnswer = '';
       }
   }

   public class CaptchaWrapper {
       @AuraEnabled
       public Boolean cflag;
       @AuraEnabled
       public String ctype;
       @AuraEnabled public String tid;
   }

   public class ResponseWrapper {
       @AuraEnabled
       public Boolean userExists;
       @AuraEnabled
       public Boolean isCaptchaInvalid ;
       @AuraEnabled
       public Boolean isV3Failed ;
   }

   public class RecaptchaResponseWrapper {
       @AuraEnabled
       public String action;
       @AuraEnabled
       public String response;
   }
   /**
    * @author                      : MTX Group Product Team
    * @since                       : 01 Oct 2022
    * @description                 : This method will pass the data to findContact method 
    * @param wrapperData		   : Data we are passing from portal like firstname ,lastname ,date of birth
    * @param recaptchaResponse	   : Passing captacha token value
    * @param ctype                 : Passing captacha Version V2 or V3
    * @return                      : `ResponseWrapper`
    * @last modified by            : MTX Group Product Team
    * @last modified date          : 01 Feb 2023
    * @modified details            : 
   */
   @AuraEnabled
   public static ResponseWrapper doFinishForgetUsernameCapctcha(
       String wrapperData,
       String recaptchaResponse,
       String ctype
   ) {
       try{
           CaptchaWrapper inputWrapperObject = new CaptchaWrapper();
           inputWrapperObject.cflag = LPI_FindUserName.isRecaptchaDisabled();
           inputWrapperObject.ctype = ctype;
           return findContact(
               wrapperData,
               JSON.serialize(inputWrapperObject),
               recaptchaResponse
            );
       } catch(exception e){
            LPI_ExceptionManager.logException(
                CLASS_NAME,
                DOFINISH_FORGET_USERNAME_CAPCTCHA,
                e
            );
           return null;
       }
       
   }

   /**
    * @author                      : MTX Group Product Team
    * @since                       : 01 Oct 2022
    * @description                 : This Method will verify the captcha and send username to their email if user exists
    * @param wrapperJSON		   : Data we are passing from portal like firstname ,lastname ,date of birth
    * @param captchaWrapper	       : Here we are checking captcha is disable or Enable
    * @param recaptchaResponse     : Response we are sending back to javascript
    * @return                      : `ResponseWrapper`
    * @last modified by            : MTX Group Product Team
    * @last modified date          : 28 Sep 2023
    * @modified details            : 
   */
   @AuraEnabled
   public static ResponseWrapper findContact(String wrapperJSON,String captchaWrapper,String recaptchaResponse) {
       Savepoint sp;
       ResponseWrapper responseWrap = new ResponseWrapper();
       try {
            
           if (String.isNotEmpty(wrapperJSON) && String.isNotBlank(wrapperJSON)) {
               ForgetUsernameFormWrapper wr = (ForgetUsernameFormWrapper) JSON.deserializeStrict(wrapperJSON,ForgetUsernameFormWrapper.class);
               CaptchaWrapper inputWrapperObject = (CaptchaWrapper) JSON.deserializeStrict(captchaWrapper,CaptchaWrapper.class);
               
               if (inputWrapperObject.cflag != true) {
                   Boolean captchaValid = false;
                    
                   if (String.isNotBlank(recaptchaResponse)) {
                       
                       if (inputWrapperObject.ctype == 'v3') {
                           RecaptchaResponseWrapper captchaWrpMap = (RecaptchaResponseWrapper) JSON.deserializeStrict(
                               recaptchaResponse,
                               RecaptchaResponseWrapper.class
                           );
                           
                           if (captchaWrpMap.action == 'Submit') {
                               Map<String, Object> txnMap = new Map<String, Object>();
                               txnMap = LPI_VerifyCaptcha.makeRequest(
                                   captchaWrpMap.response,
                                   captchaWrpMap.action,
                                   false
                               );
                               captchaValid = (Boolean) txnMap.get('valid');
                           }
                           
                           if (!captchaValid) {
                               responseWrap.isV3Failed = true;
                           }
                       } else {
                           Map<String, Object> v2TxnMap = LPI_VerifyCaptcha.verifyRecaptchaV2(recaptchaResponse);
                           
                           if ((Boolean) v2TxnMap.get('valid')) {
                               captchaValid = true;
                           }
                       }
                   }
                    
                   if (Test.isRunningTest()) {
                       captchaValid = true;
                   }
                   
                   if (!captchaValid) {
                       responseWrap.isCaptchaInvalid = true;
                       responseWrap.isV3Failed = true;
                       responseWrap.userExists=true;
                       return responseWrap;
                   }
               }
               String emailValue = '';
               String userAccId = '';
               sp = Database.setSavepoint();
               
               String accQueryFields='Id ,Name, PersonEmail, Security_Question__c, Buisness_Email__c, Date_of_Birth__c';
               String accWhereClauseFieldsForBusinessPersonAcc ='';
               String queryLimit = '1';
               List<Account> accountList = new List<Account>();
               List<Account> personAccForBusinessList = new List<Account>();
               LPI_AccountDAO.LPI_AccountWithoutSharingDAO accList=new LPI_AccountDAO.LPI_AccountWithoutSharingDAO();
                
               if(wr.isIndividualForgotUsername){
                 
                String accWhereClauseFields = '';
                if(wr.identificationType == 'ssn'){
                    accWhereClauseFields='Social_Security_Number__c =\''+String.escapeSingleQuotes(wr.uniqueIdentificationNumber) + '\'';
                } else{
                    queryLimit = '100000';
                    accWhereClauseFields = 'FirstName = \'' + String.escapeSingleQuotes(wr.firstName) + '\' AND  LastName = \'' + String.escapeSingleQuotes(wr.lastName) + '\''; 
                }
                accountList = accList.getAccountByDymanicQuery(accQueryFields,accWhereClauseFields,queryLimit,null,null);
                if(wr.identificationType != 'ssn'){
                    accountList = matchDateOfBirth(accountList,wr.dateOfBirth);
                }
               } 
               else if(wr.isBusinessForgotUsername){
                 
                String accWhereClauseFieldsForBusiness ='';
                if(wr.identificationType == 'ownerSSN'){
                    accWhereClauseFieldsForBusiness='Owner_s_Social_Security_Number__c =\''+String.escapeSingleQuotes(wr.uniqueIdentificationNumber) + '\'';
                } else{
                    accWhereClauseFieldsForBusiness='Federal_Employer_ID_Number_EIN__c =\''+String.escapeSingleQuotes(wr.uniqueIdentificationNumber) + '\'';
                }
                accountList = accList.getAccountByDymanicQuery(accQueryFields,accWhereClauseFieldsForBusiness,'1',null,null);
               }
               
                
               If(accountList.isEmpty()){
                   responseWrap.userExists=false;
                   responseWrap.isCaptchaInvalid = true;
                   responseWrap.isV3Failed = true;
                   return responseWrap;
                }
               else{
                    accWhereClauseFieldsForBusinessPersonAcc='Name =\''+String.escapeSingleQuotes(accountList[0].Name)+ '\' AND Person_Account_For_Business__c = true';
                    personAccForBusinessList = accList.getAccountByDymanicQuery(accQueryFields,accWhereClauseFieldsForBusinessPersonAcc,'1',null,null);
                   if(wr.isBusinessForgotUsername && !personAccForBusinessList.isEmpty()){
                    userAccId = personAccForBusinessList[0].Id;
                    emailValue = accountList[0].Buisness_Email__c;
                   } else{
                    userAccId = accountList[0].Id;
                    emailValue= emailValue = accountList[0].PersonEmail;
                   }
                     
                  Map<String, Object> securityQueResponseFromUser = (Map<String, Object>) JSON.deserializeUntyped(wr.securityQuestionAnswer);
                  Map<String, Object> securityQueResponseFromBackend = (Map<String, Object>) JSON.deserializeUntyped(accountList[0].Security_Question__c);
                  for(String que : securityQueResponseFromBackend.keySet()){
                        if(securityQueResponseFromBackend.get(que) != securityQueResponseFromUser.get(que)){
                            responseWrap.userExists = false;
                            break;
                        }
                        responseWrap.userExists = true;
                   }
                   responseWrap.isCaptchaInvalid = false;
                   responseWrap.isV3Failed = false;
                }
                
               String userQueryFields='Id,Username';
               String userWhereClauseFields='';
               If(!accountList.isEmpty() && String.isNotBlank(userAccId)){
                   userWhereClauseFields='AccountId=\''+String.escapeSingleQuotes(userAccId)+'\'';
               }
               LPI_UserDao.LPI_UserWithoutSharingDAO userclass = new LPI_UserDao.LPI_UserWithoutSharingDAO();
               List<User> userList = userclass.getUserByDymanicQuery(userQueryFields,userWhereClauseFields,'1',null,null);
                
               
               If(!userList.isEmpty() && responseWrap.userExists && String.isNotBlank(emailValue)){
                   String userName = userList[0].Username;
               
                   OrgWideEmailAddress[] owea = [
                       SELECT Id
                       FROM OrgWideEmailAddress
                       WHERE Address =: System.label.Org_Wide_Email_Address 
                   ];
                    
                   Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                   message.setTargetObjectId(userList[0].Id);
                   message.setReplyTo('no-reply@gmail.com');
                   message.setUseSignature(false);
                   message.setBccSender(false);
                   message.setSaveAsActivity(false);
                   message.setOrgWideEmailAddressId(owea.get(0).Id);
                   
                   EmailTemplate emailTemplate = [
                       SELECT
                           Id,
                           Subject,
                           Description,
                           HtmlValue,
                           DeveloperName,
                           Body
                       FROM EmailTemplate
                       WHERE name = 'getUserName'
                   ];
                   String subject = emailTemplate.Subject;
                   
                   String plainBody = emailTemplate.Body;
                   plainBody = plainBody.replace('{!User.Username}', userName);
                   plainBody = plainBody.replace('{!$Label.MO_DPR_Site_Url}', System.Label.Site_Url+'/s/login/');
                   message.setSubject(subject);
                   message.setPlainTextBody(plainBody);
                   message.setTemplateID(emailTemplate.Id);
                   message.toAddresses = new List<String>{ emailValue };
                   Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage>{
                       message
                   };
                   Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
               } else{
                responseWrap.userExists=false;
                responseWrap.isCaptchaInvalid = true;
                responseWrap.isV3Failed = true;
                return responseWrap;               }
           }
           return responseWrap;
       } catch (DmlException e) {
           Database.rollback(sp);
           LPI_ExceptionManager.logException(
               CLASS_NAME,
               FIND_CONTACT,
               e
           );
           return null;
       } catch (Exception e) {
           Database.rollback(sp);
           LPI_ExceptionManager.logException(
               CLASS_NAME,
               FIND_CONTACT,
               e
           );
           return null;
       }
   }
   /**
    * @author                      : MTX Group Product Team
    * @since                       : 01 Oct 2022
    * @description                 : This Method will verify whether recaptcha disabled or not
    * @return                      : `Boolean`
    * @last modified by            : MTX Group Product Team
    * @last modified date          : 01 Feb 2023
    * @modified details            : 
   */
   @AuraEnabled
   public static Boolean isRecaptchaDisabled() {
       try{
           LPI_Recaptcha_Configuration__mdt recapConfig = LPI_Recaptcha_Configuration__mdt.getInstance('Recaptcha');
           return recapConfig.isDisabled__c;
       } catch(exception e){
           LPI_ExceptionManager.logException(
               CLASS_NAME,
               IS_RECAPTCHA_DISABLED,
               e
           );
           return false;
       }
       
   }

    /**
    * @author                      : MTX Group Product Team
    * @since                       : 20 Sep 2023
    * @description                 : This method fetch security questions
    * @return                      : `Map`
    * @last modified by            : MTX Group Product Team
    * @last modified date          : 
    * @modified details            : 
   */
   @AuraEnabled
   public static Map<String,Object> getSecurityQuestions() {
       Map<String,Object> result = new Map<String,Object>();
       try{
            List<Security_Question_For_Registration__mdt> securityQuestionsList = [
                SELECT Id, Question_Name__c, DeveloperName, Error_When_Missing__c
                FROM Security_Question_For_Registration__mdt
                Order by Question_Order__c ASC
            ];
            result.put('securityQuestionsList', securityQuestionsList);
            return result;
       } catch(exception e){
            LPI_ExceptionManager.logException(CLASS_NAME,IS_RECAPTCHA_DISABLED,e);
            return result;
       }
   }

       /**
    * @author                      : MTX Group Product Team
    * @since                       : 21 Nov 2023
    * @description                 : This method fetch security questions from Account using uniqueIdentificationNumber(ssn, nationalId, MO State or EIN)
    * @return                      : 'Set<Stirng>'
    * @last modified by            : MTX Group Product Team
    * @last modified date          : 
    * @modified details            : 
    */
    @AuraEnabled
    public static List<String> fetchAccountByUniqueIdentificationNumber(String wrapperJSON) {
        List<String> result = new List<String>();
        try{
            ForgetUsernameFormWrapper wr = (ForgetUsernameFormWrapper) JSON.deserializeStrict(wrapperJSON,ForgetUsernameFormWrapper.class);
            String accQueryFields='Id , Security_Question__c, Date_of_Birth__c ';
            String accWhereClause = ''; 
            String queryLimit = '1';
            if(wr.isIndividualForgotUsername){
                if(wr.identificationType == 'ssn'){
                    accWhereClause  =  'Social_Security_Number__c = \'' + String.escapeSingleQuotes(wr.uniqueIdentificationNumber) + '\''; 
                }
                else{
                    accWhereClause  =  'FirstName = \'' + String.escapeSingleQuotes(wr.firstName) + '\' AND  LastName = \'' + String.escapeSingleQuotes(wr.lastName) + '\''; 
                    queryLimit = '100000';
                }
            }
            else{
                if(wr.identificationType == 'ownerSSN'){
                    accWhereClause  =  'Owner_s_Social_Security_Number__c = \'' + String.escapeSingleQuotes(wr.uniqueIdentificationNumber) + '\''; 
                }
                else{
                    accWhereClause  =  'Federal_Employer_ID_Number_EIN__c = \'' + String.escapeSingleQuotes(wr.uniqueIdentificationNumber) + '\''; 
                }
            }
            List<Account> accountList = new List<Account>();
            LPI_AccountDAO.LPI_AccountWithoutSharingDAO accList=new LPI_AccountDAO.LPI_AccountWithoutSharingDAO();
            accountList = accList.getAccountByDymanicQuery(accQueryFields,accWhereClause,queryLimit,null,null);
            if(!accountList.isEmpty()){
               
                if(wr.isIndividualForgotUsername && wr.identificationType != 'ssn'){
                    accountList = matchDateOfBirth(accountList,wr.dateOfBirth);
                    
                    if(accountList.isEmpty()){
                        return result;
                    }
                    if(accountList.size()>1){
                        result.add('multiple');
                        return result;
                    }
                }
                String jsonString = '[' + accountList[0].Security_Question__c + ']';
                List<Map<String, String>> keyValueList = (List<Map<String, String>>)JSON.deserializeStrict(jsonString, List<Map<String, String>>.class);
                Map<String, String> resultMap = new Map<String, String>();
    
                for (Map<String, String> keyValue : keyValueList) {
                    resultMap.putAll(keyValue);
                }
                for (String key : resultMap.keySet()) {
                    result.add(key);
                }
                
            }
            return result;
        } catch(exception e){
            LPI_ExceptionManager.logException(CLASS_NAME,'fetchAccountByUniqueIdentificationNumber',e);
            return result;
        }
    }


   /**
    * @author                      : MTX Group Product Team
    * @since                       : 21 Dec 2023
    * @description                 : This method fetch today's date
    * @return                      : `Date`
    * @last modified by            : MTX Group Product Team
    * @last modified date          : 01 Feb 2023
    * @modified details            : 
   */
   @AuraEnabled
   public static Date getTodayDate(){
       return System.today();
   }

   /**
    * @author                      : MTX Group Product Team
    * @since                       : 13 Dec 2023
    * @description                 : This method matches the date entered by user and DOB
    * @return                      : `List<Account>`
   */
   private static List<Account> matchDateOfBirth(List<Account> accList, String checkdate){

    Date checkdate1 = Date.valueOf(checkdate);
    List<Account> newAccList = new List<Account>();
    for(Account acc:accList){
        if(acc.Date_of_Birth__c != null && checkdate1.isSameDay(acc.Date_of_Birth__c)){
            newAccList.add(acc);
        }
    }
    return newAccList;
   }
   
}