/**
 * @author                      : MTX Group Product Team
 * @since                       : 16 Jan, 2023
 * @description                 : This class contains the the logic to handle exception logs created in the system
 * @last modified by            : MTX Group Product Team
 * @last modified date          : (Add if modified by you)
 * @last modified details       : (Add if modified by you)
 */
public with sharing class LPI_ExceptionManager {
    /**
     * @author                      : MTX Group Product Team
     * @since                       : 16 Jan, 2023
     * @description                 : This is used to publish LPI_Error_Log__e event to maintain the exception logs
     * @param  className            : Takes Class Name 
     * @param  methodName           : Takes Method Name
     * @param  expRec               : Takes Exception Object
     * @return                      : returns void
     * @last modified by            : MTX Group Product Team
     * @last modified date          : (Add if modified by you)
     * @last modified details       : (Add if modified by you)
     */
    public static void logException(String className, String methodName, Exception expRec){
        LPI_Error_Log__e exceptionEvent = new LPI_Error_Log__e();
        exceptionEvent.Method_Name__c = methodName;
        exceptionEvent.Class_Name__c = className;
        exceptionEvent.Exception_Type__c = expRec.getTypeName();
        exceptionEvent.Line_Number__c = expRec.getLineNumber();
        exceptionEvent.Error_Message__c = expRec.getMessage();
        exceptionEvent.Stack_Trace__c = expRec.getStackTraceString();
        //Mapping Current User Details
        exceptionEvent.Profile_Id__c = UserInfo.getProfileId();
        exceptionEvent.User_Id__c = UserInfo.getUserId();
        EventBus.publish(exceptionEvent);
    }

    /**
     * @author                      : MTX Group Product Team
     * @since                       : 16 Jan, 2023
     * @description                 : This is used to publish LPI_Error_Log__e event to maintain the exception logs
     * @param  affectedRecordId     : Takes Record ID for which the exception occurred
     * @param  className            : Takes Class Name
     * @param  methodName           : Takes Method Name
     * @param  expRec               : Takes Exception Object
     * @return                      : returns void
     * @last modified by            : MTX Group Product Team
     * @last modified date          : (Add if modified by you)
     * @last modified details       : (Add if modified by you)
     */
    public static void logException(String affectedRecordId, String className, String methodName, Exception expRec){
        LPI_Error_Log__e exceptionEvent = new LPI_Error_Log__e();
        exceptionEvent.Method_Name__c = methodName;
        exceptionEvent.Class_Name__c = className;
        exceptionEvent.Exception_Type__c = expRec.getTypeName();
        exceptionEvent.Line_Number__c = expRec.getLineNumber();
        exceptionEvent.Error_Message__c = expRec.getMessage();
        exceptionEvent.Stack_Trace__c = expRec.getStackTraceString();
        exceptionEvent.Record_Id__c = affectedRecordId;
        //Mapping Current User Details
        exceptionEvent.Profile_Id__c = UserInfo.getProfileId();
        exceptionEvent.User_Id__c = UserInfo.getUserId();
       
        EventBus.publish(exceptionEvent);
    }

    /**
     * @author                      : MTX Group Product Team
     * @since                       : 16 Jan, 2023
     * @description                 : This is used to publish LPI_Error_Log__e event to maintain the exception logs
     * @param  className            : Takes Class Name 
     * @param  methodName           : Takes Method Name
     * @param  expRec               : Takes Exception Object
     * @return                      : returns void
     * @last modified by            : MTX Group Product Team
     * @last modified date          : (Add if modified by you)
     * @last modified details       : (Add if modified by you)
     */
    public static void logException(Exception expRec){
        LPI_Error_Log__e exceptionEvent = new LPI_Error_Log__e();
        String rawStackTrace = expRec.getStackTraceString().substringBefore('\n');
        String className = rawStackTrace.substringAfter('.').substringBefore('.');  
        String methodName = rawStackTrace.substringBefore(':').substringAfter(className).substringAfter('.');

        exceptionEvent.Method_Name__c = methodName;
        exceptionEvent.Class_Name__c = className;
        exceptionEvent.Exception_Type__c = expRec.getTypeName();
        exceptionEvent.Line_Number__c = expRec.getLineNumber();
        exceptionEvent.Error_Message__c = expRec.getMessage();
        exceptionEvent.Stack_Trace__c = expRec.getStackTraceString();
        //Mapping Current User Details
        exceptionEvent.Profile_Id__c = UserInfo.getProfileId();
        exceptionEvent.User_Id__c = UserInfo.getUserId();
        EventBus.publish(exceptionEvent);
    }

    /**
     * @author                      : MTX Group Product Team
     * @since                       : 16 Jan, 2023
     * @description                 : This is used to publish LPI_Error_Log__e event to maintain the exception logs
     * @param  className            : Takes Class Name 
     * @param  methodName           : Takes Method Name
     * @param  expRec               : Takes Exception Object
     * @return                      : returns void
     * @last modified by            : MTX Group Product Team
     * @last modified date          : (Add if modified by you)
     * @last modified details       : (Add if modified by you)
     */
    public static void logException(String className, String methodName, String exceptionType, String errorMessage, String stackTrace, Integer lineNumber){
        LPI_Error_Log__e exceptionEvent = new LPI_Error_Log__e();
        exceptionEvent.Class_Name__c = className;
        exceptionEvent.Method_Name__c = methodName;
        exceptionEvent.Exception_Type__c = exceptionType;
        exceptionEvent.Error_Message__c = errorMessage;
        exceptionEvent.Stack_Trace__c = stackTrace;
        exceptionEvent.Line_Number__c = lineNumber;
        //Mapping Current User Details
        exceptionEvent.Profile_Id__c = UserInfo.getProfileId();
        exceptionEvent.User_Id__c = UserInfo.getUserId();
        EventBus.publish(exceptionEvent);
    }

    /**
     * @author                      : MTX Group Product Team
     * @since                       : 16 Jan, 2023
     * @description                 : This is used to handle the published LPI_Error_Log__e event and create exception log records in the system
     * @param  logToCreate          : Takes LPI_ExceptionManager.Log Object
     * @return                      : returns void
     * @last modified by            : MTX Group Product Team
     * @last modified date          : (Add if modified by you)
     * @last modified details       : (Add if modified by you)
     */
    public static void logException(Log logToCreate){
        try{
            if(checkRequiredLimits()){                   
                Exception_Log__c newExpLog = new Exception_Log__c(
                    Exception_Type__c      = logToCreate.type,
                    Class_Name__c          = logToCreate.apexClass,
                    Method_Name__c         = logToCreate.method,
                    Record_Id__c           = logToCreate.recordId,
                    Profile_Id__c          = logToCreate.profileId,
                    User_Id__c             = logToCreate.userId,
                    Error_Message__c       = logToCreate.message,
                    Stack_Trace__c         = logToCreate.stackTrace
                );
                LPI_WithoutSharingUtility.insertSObjectRecord(newExpLog);
            }
            else{
                throw new LPI_Exception('The Governor Limits have already been reached and hence failed to create a Log.');
            }
        } catch(DMLException ex){
            throw new LPI_Exception('Something fatal has occurred and hence failed to create a Log. Error:' + ex.getMessage());
        }
    }

    /**
     * @author                      : MTX Group Product Team
     * @since                       : 16 Jan, 2023
     * @description                 : This is used to handle the published LPI_Error_Log__e event and create exception log records in the system
     * @usage                       : This method has usage in LPI_ErrorLogTrigger.trigger
     * @param  lstNewErrorLogEvents : Takes new List<LPI_Error_Log__e> published
     * @return                      : returns void
     * @last modified by            : MTX Group Product Team
     * @last modified date          : (Add if modified by you)
     * @last modified details       : (Add if modified by you)
     */
    public static void handleExceptionEvents(List<LPI_Error_Log__e> lstNewErrorLogEvents){
        try{
            if(checkRequiredLimits()){
                List<Exception_Log__c> lstExceptionLogsToCreate = new List<Exception_Log__c>();
                for (LPI_Error_Log__e errorLogEvent : lstNewErrorLogEvents) {
                    //Mapping Fields from Event to Custom Exception Log Object
                    Exception_Log__c newLog = new Exception_Log__c();
                    newLog.Method_Name__c = errorLogEvent.Method_Name__c;
                    newLog.Class_Name__c = errorLogEvent.Class_Name__c;
                    newLog.Exception_Type__c = errorLogEvent.Exception_Type__c;
                    newLog.Line_Number__c = errorLogEvent.Line_Number__c;
                    newLog.Error_Message__c = errorLogEvent.Error_Message__c;
                    newLog.Stack_Trace__c = errorLogEvent.Stack_Trace__c;
                    newLog.Record_Id__c = errorLogEvent.Record_Id__c;
                    //Mapping Current User Details
                    newLog.Profile_Id__c = errorLogEvent.Profile_Id__c;
                    newLog.User_Id__c = errorLogEvent.User_Id__c;
                    lstExceptionLogsToCreate.add(newLog);
                }
                if(!lstExceptionLogsToCreate.isEmpty()){
                    LPI_WithoutSharingUtility.insertSObjectRecord(lstExceptionLogsToCreate);
                }
            }else{
                throw new LPI_Exception('The Governor Limits have already been reached and hence failed to create a Log.');
            }
        }catch(Exception ex){
            throw new LPI_Exception('Something fatal has occurred and hence failed to create a Log. Error:' + ex.getMessage());
        }
    }
    /**
     * @author                      : MTX Group Product Team
     * @since                       : 20 Jan, 2023
     * @description                 : This method used to check the DML Limits
     * @return                      : returns Boolean (True if Limits Available for DML else False)
     * @last modified by            : MTX Group Product Team
     * @last modified date          : (Add if modified by you)
     * @last modified details       : (Add if modified by you)
     */
    private static Boolean checkRequiredLimits(){
        return (Limits.getDMLRows() < Limits.getLimitDMLRows()) && (Limits.getDMLStatements() < Limits.getLimitDMLStatements());
    }

    public virtual class Log{
        public String type;
        public String apexClass;
        public String method;
        public String profileId;
        public String recordId;
        public String userId;
        public String message;
        public String stackTrace;
    }
    
    public class Error extends Log{
        public Error(String cls, String routine, String recId, Exception ex){
            this.type = 'Error';
            this.apexClass = cls;
            this.method = routine;
            this.profileId = UserInfo.getProfileId();
            this.recordId = recId;
            this.userId = UserInfo.getUserId();
            this.message = ex.getMessage();
            this.stackTrace = ex.getStackTraceString();
        }
    }
    
    public class Warning extends Log{
        public Warning(String cls, String routine, String recId, String msg){
            this.type = 'Warning';
            this.apexClass = cls;
            this.profileId = UserInfo.getProfileId();
            this.method = routine;
            this.recordId = recId;
            this.userId = UserInfo.getUserId();
            this.message = msg;
            this.stackTrace = NULL;
        }
    }
}