/**
 * @author                      : MTX Group Product Team
 * @since                       : 13 Sep, 2023
 * @description                 : Handler class for LPI_AddressTrigger
 * @last modified by            : MTX Group Product Team
 * @last modified date          : 
 * @modified details            : 
 */
public with sharing class LPI_AddressTriggerHandler extends LPI_TriggerHandler{
    /**
    * Author        : MTX Group Product Team
    * BuildDate     : 13 Sep, 2023
    * Description   : This method will be called in after insert context of Address__c Trigger
    * return : void
    */
    public override void afterInsert() {
        LPI_AddressTriggerHelper.populateAddressLatitudeAndLongitude((List<Schema.Address>) Trigger.New, null);
    }
    /**
    * Author        : MTX Group Product Team
    * BuildDate     : 13 Sep, 2023
    * Description   : This method will be called in before update context of Address__c Trigger
    * return : void
    */
    public override void beforeUpdate() {
        LPI_AddressTriggerHelper.populateAddressLatitudeAndLongitude((List<Schema.Address>) Trigger.New, (Map<Id, Schema.Address>) Trigger.oldMap);
    }
}