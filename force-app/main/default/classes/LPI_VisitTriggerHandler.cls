/**
 * @description       : This class contains methods that executes automatically after performing CRUD operations on Visit records
 * @author            : Ayush Dev
 * @group             : 
 * @last modified on  : 05-06-2024
 * @last modified by  : Ayush Dev
**/

public class LPI_VisitTriggerHandler extends LPI_TriggerHandler {
    /**
     *   @author : MTX.Inc
     *   @since  :3rd Nov, 2022
     *   @description :This method contains methods which should invoke before insertion of Visit record
     *   @param : List<Visit> recordsList
     *   @return : void
     */
    public override void beforeInsert() {
        List<Visit> recordsList = (List<Visit>) Trigger.New;
        LPI_VisitTriggerHelper.handleValidations(recordsList,null);
        LPI_VisitTriggerHelper.updateBoardNameOnVisit(recordsList);
        LPI_VisitTriggerHelper.updateStatusField(recordsList,null);
    }

    
    /**
    * @description : Method contains business logics to perform before a record is updated in database.
    * @author Mohit Karani | 08-02-2023 
    **/
    public override void beforeUpdate(){
        List<Visit> recordsList = (List<Visit>) Trigger.New;
        Map<Id, Visit> mapOfOldRecords = (Map<Id, Visit>) Trigger.oldMap;
        LPI_VisitTriggerHelper.handleValidations(recordsList,mapOfOldRecords);
        LPI_VisitTriggerHelper.updateStatusField(recordsList,mapOfOldRecords);
    }

    /**
     *   @author : MTX.Inc
     *   @since  : 3rd Nov, 2022
     *   @description :This method contains methods which should invoke after insertion of Visit record
     *   @param : List<BusinessLicenseApplication> recordsList
     *   @return : void
     */
    public override void afterInsert() {
        List<Visit> recordsList = (List<Visit>) Trigger.New;
        LPI_VisitTriggerHelper.createActionPlansForVisit(recordsList);
        LPI_VisitTriggerHelper.updatePlaceAndEntityName(recordsList,null);
        LPI_VisitTriggerHelper.populateLastInspectionDateOnVisitContext(recordsList,null);
        LPI_VisitTriggerHelper.sendEmailToOwnersForAdminClosingStatus(recordsList,null);
        LPI_VisitTriggerHelper.sendEmailOnUnavailableInspections(recordsList,null);
        LPI_VisitTriggerHelper.createInspectionLifecycleNotifications(recordsList, null);
    }
    /**
     *   @author : MTX.Inc
     *   @since  : 3rd Nov, 2022
     *   @description :This method contains methods which should invoke after updation of Visit record
     *   @param : List<BusinessLicenseApplication> recordsList
     *   @return : void
     */
    public override void afterUpdate() {
        List<Visit> recordsList = (List<Visit>) Trigger.New;
        Map<Id, Visit> mapOfOldRecords = (Map<Id, Visit>) Trigger.oldMap;
        LPI_VisitTriggerHelper.createActionPlansForVisitOnUpdate(recordsList, mapOfOldRecords);
        LPI_VisitTriggerHelper.updatePlaceAndEntityName(recordsList,mapOfOldRecords);
        LPI_VisitTriggerHelper.populateLastInspectionDateOnVisitContext(recordsList,mapOfOldRecords);
        LPI_VisitTriggerHelper.sendEmailToOwnersForAdminClosingStatus(recordsList,mapOfOldRecords);
        LPI_VisitTriggerHelper.sendEmailOnUnavailableInspections(recordsList,mapOfOldRecords);
        LPI_VisitTriggerHelper.createInspectionLifecycleNotifications(recordsList, mapOfOldRecords);
    }
}