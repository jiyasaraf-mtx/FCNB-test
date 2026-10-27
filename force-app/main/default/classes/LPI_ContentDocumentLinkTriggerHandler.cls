/**
 * @description       : Trigger handler for ContentDocumentLink
 * @author            : MTX Group Product Team
 * @group             : 
 * @last modified on  : 07-26-2024
 * @last modified by  : MTX Group Product Team
**/
public with sharing class LPI_ContentDocumentLinkTriggerHandler extends LPI_TriggerHandler {
   
    /**
    * @description : Method to run bussiness logic before insertion of ContentDocumentLink records.
    * @author MTX Group Product Team | 05-16-2023 
    * @param newList 
    **/
    public override void beforeInsert(){
        LPI_ContentDocumentLinkTriggerHelper.createPublicLink(Trigger.new);
        LPI_ContentDocumentLinkTriggerHelper.updateVisibilityToAllUser(Trigger.new);
    }

     /**
     *   @author : MTX Group Product Team
     *   @since  : 3rd Nov, 2022
     *   @description :This method contains methods which should invoke after insertion of Note record
     *   @return : void
     */
    public override void afterInsert() {
        PushTriggerHelper.sendNotificationOnVisitNote(Trigger.new);
    }

    /**
    * @description : Method to run bussiness logic before deletion of ContentDocumentLink records.
    * @author MTX Group Product Team | 05-16-2023 
    * @param newList 
    **/
    public override void afterDelete(){
        LPI_ContentDocumentLinkTriggerHelper.beforeDelete(Trigger.Old);
    }

}