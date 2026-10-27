/**
 * @author       : Ayush Yadav
 * @description  : This is trigger on Audit_Detail__c object
 * @since        : 12 Sep, 2023
 */
trigger LPI_AuditDetailTrigger on Audit_Detail__c (after insert,before insert, after update, before update) {
    LPI_TriggerConfiguration__mdt tcmdt = LPI_TriggerConfiguration__mdt.getInstance('Trigger_Configuration'); 
    if(tcmdt.AuditDetail__c){
        new LPI_AuditDetailTriggerHandler().run();
    }
}