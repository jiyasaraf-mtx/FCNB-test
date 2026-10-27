/**
 * @description Change Data Capture trigger for IndividualApplication.
 *              Creates portal Notification__c records when Status changes.
 */
trigger LPI_IAChangeEventTrigger on IndividualApplicationChangeEvent (after insert) {
    LPI_IAChangeEventHelper.handleAfterInsert(Trigger.new);
}