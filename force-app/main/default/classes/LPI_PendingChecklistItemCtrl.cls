/**
 * @author                      : Nitesh Garg
 * @since                       : 15/02/2021
 * @description                 : Class used for Pending Checklist Item
 * @last modified by            : Ayush Dev
 * @last modified date          : 
 * @modified details            : 
 */
public with sharing class LPI_PendingChecklistItemCtrl {
  /**
   * @author                      : Nitesh Garg
   * @since                       : 15/02/2021
   * @description                 : fetch Pending Due_Diligence__c 
   * @return                      : List<Due_Diligence__c>
   * @last modified by            : Ayush Dev
   * @last modified date          : 
   * @modified details            : 
   */
   @AuraEnabled
   public static Map<String,String> getPendingChecklistItem(string parId){
       try {
           List<Due_Diligence__c> pendingDueDigilenceList = new List<Due_Diligence__c>();
           String applicationNumber;
           if(String.isNotEmpty(parId)){
               
                List<PreliminaryApplicationRef> parList = LPI_PreliminaryApplicationRefDAO.getPreliminaryApplicationRefByDymanicQuery(
                    'Id,(SELECT Id,Name FROM IndividualApplicationAppRef),(SELECT Id,Name FROM BusinessLicenseApplicationSavedRef) ',
                    'Id =\''+parId+'\'',
                    '1',null,null
                );
                if(!parList.isEmpty()){
                    String appId;
                    if(parList[0].IndividualApplicationAppRef.size() > 0){
                        appId = parList[0].IndividualApplicationAppRef[0].Id;
                        applicationNumber = parList[0].IndividualApplicationAppRef[0].Name;
                    }else if(parList[0].BusinessLicenseApplicationSavedRef.size() > 0){
                        appId = parList[0].BusinessLicenseApplicationSavedRef[0].Id;
                        applicationNumber = parList[0].BusinessLicenseApplicationSavedRef[0].Name;
                    }
                    if(String.isNotEmpty(appId)){
                        pendingDueDigilenceList = LPI_DueDiligenceDAO.getDueDiligenceByDymanicQuery(
                            'Id,Checklist_Name__c,Comment__c',
                            'Status__c  != \'Completed\' AND (Application__c = \''+appId+'\''+
                            ' OR Individual_Application__c = \''+appId+'\')',
                            null,'Sequence__c',null
                        );
                    }
                }
           }
           return new Map<String,String>{
            'applicationNumber' => applicationNumber,
            'pendingDueDigilenceList' => JSON.serialize(pendingDueDigilenceList)
           };
       } catch (Exception e) {
           LPI_ExceptionManager.logException('LPI_PendingChecklistItemCtrl', 'getPendingChecklistItem', e);
           throw new AuraHandledException(e.getMessage());
       }
   }
}