trigger ApplicationDocumentTrigger on Application_Document__c (after insert) {
//if(trigger.IsAfter && trigger.IsInsert){
ApplicationDocumentTriggerController.updatestatusOnIA(trigger.new);
//}

}
