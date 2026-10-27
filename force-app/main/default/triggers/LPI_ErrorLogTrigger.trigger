/**
 * @author                      : Milanjeet Singh
 * @since                       : 18 Jan, 2023
 * @description                 : This Trigger is on LPI_Error_Log__e platform event
 */
trigger LPI_ErrorLogTrigger on LPI_Error_Log__e (after insert) {
    //Calling helper method to handle new LPI_Error_Log__e platform events
    LPI_ExceptionManager.handleExceptionEvents(Trigger.New);
}