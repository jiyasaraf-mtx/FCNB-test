/**
 * @description             :
 * @author                  : MTX Group Product Team
 * @group                   :
 * @last modified on        : 07-26-2024
 * @last modified by        : MTX Group Product Team
 * @last modified details   : Added try catch for exception handling
 **/
public inherited sharing class LPI_DML{
    /**
     * @author  MTX Group Product Team
     * @param sObjs
     * @return  `List<SObject>`
     * @exception    If User Do not have permission then throw Exception
     */
    public static List<SObject> doInsert(List<SObject> sObjs){
        if (!sObjs.isEmpty() && !sObjs[0].getSObjectType().getDescribe().isCreateable()){
            System.debug('Insert Log>>>');
            throw new AuraHandledException('Insufficient create access. ( Object: ' + sObjs[0].getSObjectType() + ' )');
        }
        SObjectAccessDecision securityDecision = LPI_DmlActionUtility.getAccessibleDataSObjectAccessDecision(sObjs, 'insert');
        System.debug('Decision>>>'+securityDecision);
        try{
            insert securityDecision.getRecords();
            return securityDecision.getRecords();
        } catch (Exception exceptionInstance){
            LPI_ExceptionManager.logException('LPI_WithoutSharingUtility', 'doInsert', exceptionInstance);
            throw new AuraHandledException('Error: ' + exceptionInstance.getMessage());
        }
    }

    /**
     * @author  MTX Group Product Team
     * @param sObjs
     * @return  `SObject`
     * @exception    If User Do not have permission then throw Exception
     * @last modified on        : 07-26-2024
     * @last modified by        : MTX Group Product Team
     * @last modified details   : Added try catch for exception handling
     */
    public static SObject doInsert(SObject sObj){
        if (!sObj.getSObjectType().getDescribe().isCreateable()){
            throw new LPI_Exception('Insufficient create access. ( Object: ' + sObj.getSObjectType() + ' )');
        }

        SObjectAccessDecision securityDecision = LPI_DmlActionUtility.getAccessibleDataSObjectAccessDecision(new List<SObject>{ sObj }, 'insert');
        try{
            insert securityDecision.getRecords();
            return securityDecision.getRecords()[0];
        } catch (Exception exceptionInstance){
            LPI_ExceptionManager.logException('LPI_WithoutSharingUtility', 'doInsert', exceptionInstance);
            throw new AuraHandledException('Error: ' + exceptionInstance.getMessage());
        }
    }

    /**
     *
     * @param sObj
     * @return  `SObject`
     * @exception  :  If User Do not have permission then throw Exception
     * @last modified on        : 07-26-2024
     * @last modified by        : MTX Group Product Team
     * @last modified details   : Added try catch for exception handling
     */
    public static SObject doUpdate(SObject sObj){
        if (!sObj.getSObjectType().getDescribe().isUpdateable()){
            throw new LPI_Exception('Insufficient update access. ( Object: ' + sObj.getSObjectType() + ' )');
        }
        try{
            update sObj;
            System.debug('=== [doUpdate SUCCESS] Record Updated ID: ' + sObj.Id);
            return sObj;
        } catch (Exception exceptionInstance){
            System.debug('=== [FAIL POINT - DML EXCEPTION] Message: ' + exceptionInstance.getMessage());
            System.debug('=== Stack Trace: ' + exceptionInstance.getStackTraceString());
            LPI_ExceptionManager.logException('LPI_WithoutSharingUtility', 'doUpdate', exceptionInstance);
            throw new AuraHandledException('Error: ' + exceptionInstance.getMessage());
        }
    }

    /**
     * @author  MTX Group Product Team
     * @param sObjs
     * @return  `List<SObject>`
     * @exception    If User Do not have permission then throw Exception
     * @last modified on        : 07-26-2024
     * @last modified by        : MTX Group Product Team
     * @last modified details   : Added try catch for exception handling
     */
    public static List<SObject> doUpdate(List<SObject> sObjs){
        if (!sObjs.isEmpty() && !sObjs[0].getSObjectType().getDescribe().isUpdateable()){
            throw new LPI_Exception('Insufficient update access. ( Object: ' + sObjs[0].getSObjectType() + ' )');
        }
        SObjectAccessDecision securityDecision = LPI_DmlActionUtility.getAccessibleDataSObjectAccessDecision(sObjs, 'update');
        try{
            update securityDecision.getRecords();
            return securityDecision.getRecords();
        } catch (Exception exceptionInstance){
            LPI_ExceptionManager.logException('LPI_WithoutSharingUtility', 'doUpdate', exceptionInstance);
            throw new AuraHandledException('Error: ' + exceptionInstance.getMessage());
        }
    }

    /**
     * @author  MTX Group Product Team
     * @param sObj
     * @return  `SObject`
     * @exception  :  If User Do not have permission then throw Exception
     * @last modified on        : 07-26-2024
     * @last modified by        : MTX Group Product Team
     * @last modified details   : Added try catch for exception handling
     */
    public static void doDelete(SObject sObj){
        if (!sObj.getSObjectType().getDescribe().isDeletable()){
            throw new AuraHandledException('Insufficient delete access. ( Object: ' + sObj.getSObjectType() + ' )');
        }
        try{
            delete sObj;
        } catch (Exception exceptionInstance){
            LPI_ExceptionManager.logException('LPI_WithoutSharingUtility', 'doDelete', exceptionInstance);
            throw new AuraHandledException('Error: ' + exceptionInstance.getMessage());
        }
    }

    /**
     * @author  MTX Group Product Team
     * @param sObjs
     * @return  `SObject`
     * @exception  :  If User Do not have permission then throw Exception
     * @last modified on        : 07-26-2024
     * @last modified by        : MTX Group Product Team
     * @last modified details   : Added try catch for exception handling
     */
    public static void doDelete(List<SObject> sObjs){
        if (!sObjs.isEmpty() && !sObjs[0].getSObjectType().getDescribe().isDeletable()){
            throw new AuraHandledException('Insufficient delete access. ( Object: ' + sObjs[0].getSObjectType() + ' )');
        }
        try{
            delete sObjs;
        } catch (Exception exceptionInstance){
            LPI_ExceptionManager.logException('LPI_WithoutSharingUtility', 'doDelete', exceptionInstance);
            throw new AuraHandledException('Error: ' + exceptionInstance.getMessage());
        }
    }

    /**
     * @author  MTX Group Product Team
     * @param List<SObject> sObjs
     * @return  `List<SObject>`
     * @exception    If User Do not have upsert permission then throw Exception
     * @last modified on        : 07-26-2024
     * @last modified by        : MTX Group Product Team
     * @last modified details   : Added try catch for exception handling
     */
    public static List<SObject> doUpsert(List<SObject> sObjs){
        if (!sObjs.isEmpty() && !sObjs[0].getSObjectType().getDescribe().isCreateable() && !sObjs[0].getSObjectType().getDescribe().isUpdateable()){
            throw new AuraHandledException('Insufficient upsert access. ( Object: ' + sObjs[0].getSObjectType() + ' )');
        }
        SObjectAccessDecision securityDecision = LPI_DmlActionUtility.getAccessibleDataSObjectAccessDecision(sObjs, 'upsert');
        try{
            upsert securityDecision.getRecords();
            return securityDecision.getRecords();
        } catch (Exception exceptionInstance){
            LPI_ExceptionManager.logException('LPI_WithoutSharingUtility', 'doUpsert', exceptionInstance);
            throw new AuraHandledException('Error: ' + exceptionInstance.getMessage());
        }
    }

    /**
     * @author  MTX Group Product Team
     * @param List<SObject> sObjs
     * @return  `List<SObject>`
     * @exception    If User Do not have upsert permission then throw Exception
     * @last modified on        : 07-26-2024
     * @last modified by        : MTX Group Product Team
     * @last modified details   : Added try catch for exception handling
     */
    public static SObject doUpsert(SObject sObjs){
        if (sObjs != null && !sObjs.getSObjectType().getDescribe().isCreateable() && !sObjs.getSObjectType().getDescribe().isUpdateable()){
            throw new AuraHandledException('Insufficient upsert access. ( Object: ' + sObjs.getSObjectType() + ' )');
        }
        SObjectAccessDecision securityDecision = LPI_DmlActionUtility.getAccessibleDataSObjectAccessDecision(new List<SObject>{ sObjs }, 'upsert');
        try{
            upsert securityDecision.getRecords();
            return securityDecision.getRecords()[0];
        } catch (Exception exceptionInstance){
            LPI_ExceptionManager.logException('LPI_WithoutSharingUtility', 'doUpsert', exceptionInstance);
            throw new AuraHandledException('Error: ' + exceptionInstance.getMessage());
        }
    }

    /**
     * @author  MTX Group Product Team
     * @param List<SObject> sObjs
     * @return  `List<SObject>`
     * desc : This method is used to upsert Records in System Context. Added this so that masterdetail ref like ParentIds are not stripped while performing DML.
     * @exception    If User Do not have upsert permission then throw Exception
     * @last modified on        : 07-26-2024
     * @last modified by        : MTX Group Product Team
     * @last modified details   : Added try catch for exception handling
     */
    public static List<sObject> doUpsertSystemContext(List<sObject> sObjs){
        if (!sObjs.isEmpty() && !sObjs[0].getSObjectType().getDescribe().isCreateable() && !sObjs[0].getSObjectType().getDescribe().isUpdateable()){
            throw new AuraHandledException('Insufficient upsert access. ( Object: ' + sObjs[0].getSObjectType() + ' )');
        }
        try{
            upsert sObjs;
            return sObjs;
        } catch (Exception exceptionInstance){
            LPI_ExceptionManager.logException('LPI_WithoutSharingUtility', 'doUpsertSystemContext', exceptionInstance);
            throw new AuraHandledException('Error: ' + exceptionInstance.getMessage());
        }
    }

    /**
     * @author                       : MTX Group Product Team
     * @since                        : July 13, 2023
     * @description                  : This Method use to Upsert sObject without checking Object Level Permission
     * @param sObjectRecord          : List<sObject> Record to be upsert
     * @return                       : List<sObject>
     * @last modified on             : 07-26-2024
     * @last modified by             : MTX Group Product Team
     * @last modified details        : Added try catch for exception handling
     */
    public static List<sObject> upsertSObject(List<sObject> sObjList){
        try{
            upsert sObjList;
            return sObjList;
        } catch (Exception exceptionInstance){
            LPI_ExceptionManager.logException('LPI_WithoutSharingUtility', 'upsertSObject', exceptionInstance);
            throw new AuraHandledException('Error: ' + exceptionInstance.getMessage());
        }
    }

    /**
     * @description : Method to delete record with System permissions.
     * @author MTX Group Product Team
     * @param deleteRecList
     * @last modified on        : 07-26-2024
     * @last modified by        : MTX Group Product Team
     * @last modified details   : Added try catch for exception handling
     **/
    public static void deleteWithSystemPermission(List<SObject> deleteRecList){
        try{
            delete deleteRecList;
        } catch (Exception exceptionInstance){
            LPI_ExceptionManager.logException('LPI_WithoutSharingUtility', 'deleteWithSystemPermission', exceptionInstance);
            throw new AuraHandledException('Error: ' + exceptionInstance.getMessage());
        }
    }

    /**
     * @author                       : MTX Group Product Team
     * @since                        : July 13, 2023
     * @description                  : This Method use to Upsert sObject without checking Object Level Permission
     * @param sObjectRecord          : sObject Record to be upsert
     * @return                       : sObject
     * @last modified on             : 07-26-2024
     * @last modified by             : MTX Group Product Team
     * @last modified details        : Added try catch for exception handling
     */
    public static sObject upsertSObject(sObject sObjectRecord){
        try{
            upsert sObjectRecord;
            return sObjectRecord;
        } catch (Exception exceptionInstance){
            LPI_ExceptionManager.logException('LPI_WithoutSharingUtility', 'upsertSObject', exceptionInstance);
            throw new AuraHandledException('Error: ' + exceptionInstance.getMessage());
        }
    }

}