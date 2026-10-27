/**
 * @author              Mahesh Reddy Chinthakunta
 * @description         Trigger on PublicComplaint Object when the record is inserted
 * @param insert 
 * @return  `trigger LPI_`
 */
trigger LPI_PublicComplaintTrigger on PublicComplaint (before insert, before update, after insert, after update) {
  LPI_TriggerConfiguration__mdt tcmdt = LPI_TriggerConfiguration__mdt.getInstance('Trigger_Configuration');
    if(tcmdt.PublicComplaint__c){
		new LPI_PublicComplaintTriggerHandler().run();
    }
}