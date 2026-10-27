/**
 * @author       : MTX Group Product Team
 * @description  : This Class is the Handler class on User trigger 
 * @since        : 09-Jan-2023
 */
public class LPI_UserTriggerHandler extends LPI_TriggerHandler {
    /**
    *   @author :MTX Group Product Team
    *   @since  : 09-Jan-2023
    *   @description : This method contains method calling which should invoke after insertion of USER records
    */
    public override void afterInsert() {
        List<User> recordsList = (List<User>) Trigger.New;
        
        LPI_UserTriggerHelper.managePermissionSetOnInsert(recordsList);
        LPI_UserTriggerHelper.giveAccountAccessToUser(recordsList,null);
        LPI_UserTriggerHelper.shareCertificationAndLocationRecords(recordsList);
    }
    
    /**
    *   @author : MTX Group Product Team
    *   @since  : 09-Jan-2023
    *   @description : This method contains method calling which should invoke after updation of USER records
    */
    public override void afterUpdate() {
        List<User> recordsList = (List<User>) Trigger.New;
        Map<Id, User> mapOfOldRecords = (Map<Id, User>) Trigger.oldMap;
        
        LPI_UserTriggerHelper.managePermissionSetOnUpdate(recordsList,mapOfOldRecords);
        LPI_UserTriggerHelper.giveAccountAccessToUser(recordsList,mapOfOldRecords);
    }

    /**
    * @description : Method to perform business logic before inserting a user record.
    * @author MTX Group Product Team | 06-10-2023 
    **/
    public override void beforeInsert() {
        List<User> newList = (List<User>) Trigger.New;
        LPI_UserTriggerHelper.assignUserRole(newList);
    }
    /**
    * @description : Method to perform business logic befor update a user record.
    * @author MTX Group Product Team | 05-20-2024
    **/
    public override void beforeUpdate() {
        List<User> newList = (List<User>) Trigger.New;
        Map<Id, User> mapOfOldRecords = (Map<Id, User>) Trigger.oldMap;
        LPI_UserTriggerHelper.updateEmailUsername(newList,mapOfOldRecords);
    }
}