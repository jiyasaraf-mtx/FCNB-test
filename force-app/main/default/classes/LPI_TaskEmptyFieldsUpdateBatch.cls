/**
 * @description       : 
 * @author            : MTX Group Product Team
 * @group             : 
 * @last modified on  : 07-26-2024
 * @last modified by  : MTX Group Product Team
**/
public with sharing class LPI_TaskEmptyFieldsUpdateBatch implements Database.Batchable<sObject>, Database.Stateful{
    public Database.QueryLocator start(Database.BatchableContext bc) {
        String fields = 'SELECT Id,Board_Name__c,RecordType.DeveloperName,TYPEOF What WHEN ViolationEnforcementAction THEN Violation.Board_Name__c END FROM Task ';
        String whereClause = ' WHERE Board_Name__c = NULL';
        return Database.getQueryLocator(fields + whereClause);
    }

    public void execute(
        Database.BatchableContext bc,
        List<Task> taskRecList
    ) {
        // List<Task> tskToUpdate = new List<Task>();

        // for(Task tsk : taskRecList) {
        //     if(tsk.What instanceOf ViolationEnforcementAction) {
        //         ViolationEnforcementAction veaRec = tsk.What;
        //         if(String.isNotBlank(veaRec.Violation.Board_Name__c)) {
        //             tsk.Board_Name__c = veaRec.Violation.Board_Name__c;
        //             tskToUpdate.add(tsk);
        //         }
        //     }
        // }
        // Database.update(tskToUpdate,false);
    }
    public void finish(Database.BatchableContext bc) {
       
    }

}