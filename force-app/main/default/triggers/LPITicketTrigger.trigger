trigger LPITicketTrigger on Ticket__c (after insert,after update) {
    if(Trigger.isAfter && Trigger.isInsert){
        LPITicketTriggerHandler.submittedStatus(Trigger.new);
    }
    
    if(Trigger.isAfter && Trigger.isUpdate){
        LPITicketTriggerHandler.updateStatus(Trigger.new,Trigger.oldMap);
    }
}