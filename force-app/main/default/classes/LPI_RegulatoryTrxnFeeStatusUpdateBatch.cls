/**
 * @author                      : MTX Group Product Team
 * @since                       : 24 Mar, 2023
 * @description                 : This class is used update RegulatoryTrxnFee to failed status after saven days of its transection. 
 * @last modified by            : MTX Group Product Team
 * @last modified on            : 07-26-2024
 */
global with sharing class LPI_RegulatoryTrxnFeeStatusUpdateBatch implements Database.Batchable<sObject> {

    /**
     * @author                      : MTX Group Product Team
     * @since                       : 24 Mar, 2023
     * @description                 : This method is used query RegulatoryTrxnFee data. 
     * @last modified by            : MTX Group Product Team
     * @last modified on            : 07-26-2024
     */
    global Database.QueryLocator start(Database.BatchableContext bc) {
        //Datetime sevenDaysBefore = System.Now().addDays(-7);
        String query;
           /* query = 'SELECT Id, Transaction_Date__c, Status__c ';
        query += 'FROM RegulatoryTrxnFee WHERE Status__c = \'Approved\' AND Transaction_Date__c <=:sevenDaysBefore';*/
        return Database.getQueryLocator(query);
    }
    /**
     * @author                      : MTX Group Product Team
     * @since                       : 24 Mar, 2023
     * @description                 : This method is used update RegulatoryTrxnFee to failed status after saven days of its transection.
     * @param bc 
     * @param regulatoryTrxnFeeList : RegulatoryTrxnFee object list 
     * @last modified by            : MTX Group Product Team
     * @last modified on            : 07-26-2024
     */
    global void execute(Database.BatchableContext bc,List<RegulatoryTrxnFee> regulatoryTrxnFeeList) {

        /*List<RegulatoryTrxnFee> regulatoryTrxnFeeListToBeUpdated = new List<RegulatoryTrxnFee>();
        for(RegulatoryTrxnFee rtfRec:regulatoryTrxnFeeList){
            rtfRec.Status__c='Failed';
            regulatoryTrxnFeeListToBeUpdated.add(rtfRec);
        }
        if(regulatoryTrxnFeeListToBeUpdated.size()>0){
            Database.update(regulatoryTrxnFeeListToBeUpdated, false);
        }*/
    }

    /**
     * @author                      : MTX Group Product Team
     * @since                       : 24 Mar, 2023
     * @param bc 
     * @description                 :  
     * @last modified by            : MTX Group Product Team
     * @last modified on            : 07-26-2024
    */
    global void finish(Database.BatchableContext bc) {
    }
}