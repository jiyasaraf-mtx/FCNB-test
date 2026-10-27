/**
 *
 * @author          Mahesh Reddy Chinthakunta
 * @description     Updating date fields based on Status value
 */
public class LPI_CaseTriggerHandler extends LPI_TriggerHandler {
    /**
     * @author                      Mahesh Reddy Chinthakunta
     * @description                 Triggering methods before updating
     */
    public override void beforeUpdate() {
        List<Case> recordsList = (List<Case>) Trigger.New;
        Map<Id, Case> recordsMap = (Map<Id, Case>) Trigger.oldMap;
        LPI_CaseTriggerHelper.updateDateEmailSent(recordsList, recordsMap);
        LPI_CaseTriggerHelper.updateDateReceived(recordsList, recordsMap);
        LPI_CaseTriggerHelper.updateClosedDate(recordsList,recordsMap);
        LPI_CaseTriggerHelper.countOfCasesOnLicenses(recordsList,recordsMap,'isUpdate');

    }

    /**
    * @description : Method to perform business logics after record is updated.
    * @author Mohit Karani | 06-14-2023 
    **/
    public override void afterUpdate() {
        List<Case> recordsList = (List<Case>) Trigger.New;
        Map<Id, Case> recordsMap = (Map<Id, Case>) Trigger.oldMap;
        Map<Id, Case> recordsMapNew = (Map<Id, Case>) Trigger.newMap;
        LPI_CaseTriggerHelper.sendCaseNotificationOnStageChanges(recordsList, recordsMap);
        List<Case> oldRecordsList = (List<Case>) Trigger.Old;
        LPI_CaseTriggerHelper.countOfCasesOnAccount(recordsList,oldRecordsList);
        LPI_CaseTriggerHelper.toTriggerRcvTrigger(recordsMapNew,recordsMap);
    }

    /**
    * @description : Method to perform business logics after record is inserted.
    * @author Mohit Karani | 06-14-2023 
    **/
    public override void afterInsert() {
        List<Case> recordsList = (List<Case>) Trigger.New;
        Map<Id, Case> recordsMapNew = (Map<Id, Case>) Trigger.newMap;
        LPI_CaseTriggerHelper.sendCaseNotificationOnStageChanges(recordsList, null);
        LPI_CaseTriggerHelper.countOfCasesOnAccount(recordsList,null);
        LPI_CaseTriggerHelper.countOfCasesOnLicenses(recordsList,null,'isInsert');
        LPI_CaseTriggerHelper.sendNotificationForRespondent(recordsList);
    }

    /**
    * @description : Method to perform business logics before record is inserted.
    * @author Vamshi Kumar | 08-25-2023 
    **/
    public override void beforeInsert() {
        List<Case> recordsList = (List<Case>) Trigger.New;
        LPI_CaseTriggerHelper.updateCaseNameWithCounter(recordsList);
    }
    
     /**
    * @description : Method to perform business logics after record is deleted.
    * @author: Nayana Gupta | 02-15-2024 
    **/
    public override void afterDelete() {
        List<Case> recordsList = (List<Case>) Trigger.Old;
        Map<Id,Case> recordsMap = (Map<Id, Case>) Trigger.oldMap;
        LPI_CaseTriggerHelper.countOfCasesOnAccount(null,recordsList);
        LPI_CaseTriggerHelper.countOfCasesOnLicenses(null,recordsMap,'isDelete');
        LPI_CaseTriggerHelper.toTriggerRcvTrigger(null,recordsMap);
    }
    
       /**
    * @description : Method to perform business logics after record is deleted.
    * @author: Nayana Gupta | 02-15-2024 
    **/
    public override void afterUnDelete() {
        List<Case> recordsList = (List<Case>) Trigger.New;
        Map<Id, Case> recordsMapNew = (Map<Id, Case>) Trigger.newMap;
         LPI_CaseTriggerHelper.countOfCasesOnAccount(recordsList,null);
         LPI_CaseTriggerHelper.countOfCasesOnLicenses(recordsList,null,'isUndelete');
         LPI_CaseTriggerHelper.toTriggerRcvTrigger(recordsMapNew,null);
    }
}