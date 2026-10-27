/**
 * @author       : MTX Group Product Team
 * @description  : This Class is the Handler class on TrainingCourseParticipant trigger 
 * @since        : 12-Jan-2023
 */
public class LPI_TrainingCourseParticipantTrgHndlr extends LPI_TriggerHandler {

    /**
    *   @author : MTX Group Product Team
    *   @since  : 09-Jan-2023
    *   @description : This method contains method calling which 
    *                  should invoke after insertion of TrainingCourseParticipant records
    */
    public override void afterInsert() {
        List<TrainingCourseParticipant> recordsList = (List<TrainingCourseParticipant>) Trigger.New;
        LPI_ApexSharingUtility.manageRecordAccess(recordsList, NULL);
        LPI_TrainingCourseParticipantTrgHelper.updateSubmittedHoursOnAuditDetails(recordsList,null);
    }
    /**
    *   @author             : MTX Group Product Team
    *   @since              : 09-Jan-2023
    *   @description        : This method calling which should invoke before update of TrainingCourseParticipant records 
    */
    public override void beforeUpdate(){
        List<TrainingCourseParticipant> recordsList = (List<TrainingCourseParticipant>) Trigger.New;
        Map<Id, TrainingCourseParticipant> mapOfOldRecords = (Map<Id, TrainingCourseParticipant>) Trigger.OldMap;
        LPI_TrainingCourseParticipantTrgHelper.linkTCPWithAuditDetailsRecord(recordsList, mapOfOldRecords);
        LPI_TrainingCourseParticipantTrgHelper.updateCourseTypeOnTCPRecord(recordsList, mapOfOldRecords);

    }

    /**
    *   @author             : MTX Group Product Team
    *   @since              : 06-Oct-2023
    *   @description        : This method calling which should invoke before insert of TrainingCourseParticipant records 
    */
    public override void beforeInsert(){
        List<TrainingCourseParticipant> recordsList = (List<TrainingCourseParticipant>) Trigger.New;
        LPI_TrainingCourseParticipantTrgHelper.linkTCPWithAuditDetailsRecord(recordsList,null);
        LPI_TrainingCourseParticipantTrgHelper.updateCourseTypeOnTCPRecord(recordsList,null);

    }

    /**
    *   @author             : MTX Group Product Team
    *   @since              : 18-Dec-2023
    *   @description        : This method calling which should invoke before delete of TrainingCourseParticipant records 
    */
    public override void beforeDelete(){
        List<TrainingCourseParticipant> recordsList = (List<TrainingCourseParticipant>) Trigger.Old;
        LPI_TrainingCourseParticipantTrgHelper.deleteRelatedAppContentRecord(recordsList);

    }

    /**
    *   @author             : MTX Group Product Team
    *   @since              : 18-Dec-2023
    *   @description        : This method calling which should invoke after delete of TrainingCourseParticipant records 
    */
    public override void afterDelete(){
        List<TrainingCourseParticipant> recordsList = (List<TrainingCourseParticipant>) Trigger.Old;
        Map<Id, TrainingCourseParticipant> mapOfOldRecords = (Map<Id, TrainingCourseParticipant>) Trigger.OldMap;
        LPI_TrainingCourseParticipantTrgHelper.updateApprovedHoursOnAuditDetails(recordsList,mapOfOldRecords);
        LPI_TrainingCourseParticipantTrgHelper.updateSubmittedHoursOnAuditDetails(recordsList,mapOfOldRecords);

    }

     /**
    *   @author             : MTX Group Product Team
    *   @since              : 20-Dec-2023
    *   @description        : This method calling which should invoke after update of TrainingCourseParticipant records 
    */
    public override void afterUpdate(){
        List<TrainingCourseParticipant> recordsList = (List<TrainingCourseParticipant>) Trigger.New;
        Map<Id, TrainingCourseParticipant> mapOfOldRecords = (Map<Id, TrainingCourseParticipant>) Trigger.OldMap;
        LPI_TrainingCourseParticipantTrgHelper.updateApprovedHoursOnAuditDetails(recordsList,mapOfOldRecords);
        LPI_TrainingCourseParticipantTrgHelper.updateSubmittedHoursOnAuditDetails(recordsList,mapOfOldRecords);
        LPI_TrainingCourseParticipantTrgHelper.updateAuditDetailOnDeLinking(recordsList,mapOfOldRecords);

    }

      /**
    *   @author             : MTX Group Product Team
    *   @since              : 20-Dec-2023
    *   @description        : This method calling which should invoke after undelete of TrainingCourseParticipant records 
    */
    public override void afterUndelete(){
        List<TrainingCourseParticipant> recordsList = (List<TrainingCourseParticipant>) Trigger.New;
        Map<Id, TrainingCourseParticipant> mapOfNewRecords = (Map<Id, TrainingCourseParticipant>) Trigger.NewMap;
        LPI_TrainingCourseParticipantTrgHelper.updateApprovedHoursOnAuditDetails(recordsList,mapOfNewRecords);
        LPI_TrainingCourseParticipantTrgHelper.updateSubmittedHoursOnAuditDetails(recordsList,null);
    }

}