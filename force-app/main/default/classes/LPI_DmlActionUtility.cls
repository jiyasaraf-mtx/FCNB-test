/**
 *
 * @author Saurabh singh
 * @description  This class use to check the correct access to perform any DML
 */
public with sharing class LPI_DmlActionUtility {
    /**
     * @author           Saurabh singh
     * @param sObjList   List Of Sobjects
     * @param dmlAction  DML Operation Like Insert ,Update,delete
     * @return  `SObjectAccessDecision`
     */
    public static SObjectAccessDecision getAccessibleDataSObjectAccessDecision(List<sObject> sObjList, String dmlAction) {
        dmlAction = dmlAction.toLowerCase();
        SObjectAccessDecision securityDecision;
        switch on dmlAction {
            when 'query' {
                securityDecision = Security.stripInaccessible(AccessType.READABLE, sObjList);
            }
            when 'insert' {
                securityDecision = Security.stripInaccessible(AccessType.CREATABLE, sObjList);
            }
            when 'update' {
                securityDecision = Security.stripInaccessible(AccessType.UPDATABLE, sObjList);
            }
            when 'upsert' {
                securityDecision = Security.stripInaccessible(AccessType.UPSERTABLE, sObjList);
            }
        }
        return securityDecision;
    }
    /**
     * @author Saurabh singh
     * @param sObjectName       Object name
     * @param sObjList          List Of Sobjects
     * @param dmlAction         DML Operation Like Insert ,Update,delete
     * @param throwException    Exception in case do not have proper Access
     * @return  `SObjectAccessDecision`
     * @exception If User Do not have permission then throw Exception
     */
    public static SObjectAccessDecision getAccessibleData(String sObjectName, List<sObject> sObjList, String dmlAction, Boolean throwException) {
        dmlAction = dmlAction.toLowerCase();
        SObjectAccessDecision securityDecision;
        switch on dmlAction {
            when 'insert' {
                securityDecision = Security.stripInaccessible(AccessType.CREATABLE, sObjList);
            }
            when 'update' {
                securityDecision = Security.stripInaccessible(AccessType.UPDATABLE, sObjList);
            }
            when 'upsert' {
                securityDecision = Security.stripInaccessible(AccessType.UPSERTABLE, sObjList);
            }
            when 'read' {
                securityDecision = Security.stripInaccessible(AccessType.READABLE, sObjList);
            }
        }

        if (securityDecision != null && !securityDecision.getRemovedFields().isEmpty() && throwException == true) {
            List<String> fieldsList = new List<String>();
            if (securityDecision.getRemovedFields().get(sObjectName) != null) {
                fieldsList.addAll(securityDecision.getRemovedFields().get(sObjectName));
            } else {
                for (Set<String> strSet : securityDecision.getRemovedFields().values()) {
                    fieldsList.addAll(strSet);
                }
            }
            String inaccessibleFields = String.join(fieldsList, ', ');
            String message = 'You don\'t have access to ' + dmlAction + ' ' + inaccessibleFields + ' on ' + sObjectName;
            throw new LPI_Exception(message);
        }
        return securityDecision;
    }
    public class LPI_Exception extends Exception {
    }
}