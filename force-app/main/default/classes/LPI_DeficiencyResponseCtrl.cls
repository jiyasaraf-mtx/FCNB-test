/**
 * @description       : class Used to provide Deficiency Response
 * @author            : Nitesh Garg
 * @last modified on  : 08-14-2024
 * @last modified by  : MTX Group Product Team
**/
public with sharing class LPI_DeficiencyResponseCtrl {
    private final static String APPDOC_STATUS = 'Unsubmitted';
    private final static String STATUS_RECEIVED_RESPONSE = 'Received Response';
    private final static String INDIVIDUAL_APPLICATION = 'IndividualApplication';

    /**
     * @author  Nitesh Garg
     * @param    String comment,Id applicationId,String notiId
     * @return  string   
     */
   @AuraEnabled
   public static string submitDeficiencyResponse(String comment,Id applicationId,String notiId, String iaId){
       try {
           if(!String.isNotBlank(applicationId)){
               return 'Error';
           }
        Boolean isfeeExist = false;
        List<RegulatoryTrxnFee> rtfList = new LPI_RegulatoryTrxnFeeDAO.LPI_RegulatoryTrxnFeeWithoutSharingDAO().getRegulatoryTrxnFeeByDymanicQuery(
				'Name,Transaction_ID__c',
				'Deficiency__c = \'' + String.escapeSingleQuotes(applicationId)+ '\' AND Status__c = \'Pending\'',
				'1',
				null,
				null);
        if(!rtfList.isEmpty()){
            isfeeExist = true;
        }
        Deficiency__c defObj = new Deficiency__c();
        defObj.Id = applicationId;
        defObj.Deficiency_Response_Comment__c = comment;
        defObj.Deficiency_Response_Date__c = Date.today();
        defObj.Status__c = STATUS_RECEIVED_RESPONSE;
        
        /* Commented by Rajeev Why check is needed to mark a response as Recieved?
        if(!isfeeExist){
            defObj.Deficiency_Response_Date__c = Date.today();
            defObj.Status__c = STATUS_RECEIVED_RESPONSE;

        }*/
        //portal user do not have access to Deficiency record so update in without sharing.
        LPI_WithoutSharingUtility.updateSObjectRecord(defObj);
       // if(!isfeeExist){
            //portal user do not have acess to all Portal Notification which is related to particular Deficiency.
            LPI_PortalNotificationDAO.LPI_PortalNotificationWithoutSharingDAO portalQueryDAO = new LPI_PortalNotificationDAO.LPI_PortalNotificationWithoutSharingDAO();
	        List<Notification__c> lNotificationsResolved = new List<Notification__c>();
            List<Notification__c> portalRecList = portalQueryDAO.getPortalNotificationByDymanicQuery(
                                                                    'Id',
                                                                    'Record_Id__c= \'' + String.escapeSingleQuotes(applicationId) + '\'',
                                                                    null,
                                                                    null,
                                                                    null);
           
           System.debug('>>> portalRecList'+portalRecList);
            for (Notification__c rec : portalRecList) {
                Notification__c notif = new Notification__c();
                notif.Id=rec.Id;
                notif.Is_Resolved__c = true;
                lNotificationsResolved.add(notif);
            }
           System.debug('>>> lNotificationsResolved'+lNotificationsResolved);
           System.debug('>>> lNotificationsResolved.isEmpty'+!lNotificationsResolved.isEmpty());
           
           
            if(!lNotificationsResolved.isEmpty()){
                //portal user do not have acess to all Portal Notification so update record in Without Sharing.
                LPI_WithoutSharingUtility.updateSObjectList(lNotificationsResolved);
            }
            //Logic to update IA/BLA status to Submitted Once the Deficiency Response is received.
            if(String.isNotBlank(iaId)){
                String fields = 'Id,Status';
                String whereClause = 'Id = \'' + String.escapeSingleQuotes(iaId) + '\'';
                List<Sobject> recordList = new List<Sobject>();
                if(String.valueOf(Id.valueOf(iaId).getSObjectType()) == INDIVIDUAL_APPLICATION){
                    recordList = LPI_IndividualApplicationDAO.getIndividualApplicationByDymanicQuery(fields, whereClause, null, null, null);
                }else{
                    recordList = LPI_BusinessLicenseApplicationDAO.getBusinessLicenseApplicationByDymanicQuery(fields, whereClause, null, null, null);
                }
                IndividualApplication iaObj=new IndividualApplication();
                BusinessLicenseApplication blaObj=new BusinessLicenseApplication();
                if(!recordList.isEmpty()){
                    for(Sobject sobj: recordList){
                        if(String.valueOf(Id.valueOf(iaId).getSObjectType()) == INDIVIDUAL_APPLICATION){
                            iaObj = (IndividualApplication)sobj;
                            iaObj.Status = 'Response Recieved';
                            
                        }else{
                            blaObj = (BusinessLicenseApplication)sobj;
                            blaObj.Status = 'Submitted';
                        }
                    }
                }
                if(String.valueOf(Id.valueOf(iaId).getSObjectType()) == INDIVIDUAL_APPLICATION){
                    LPI_WithoutSharingUtility.updateSObjectRecord(iaObj);
                }else{
                    LPI_WithoutSharingUtility.updateSObjectRecord(blaObj);
                }
            }
        
        return 'Success';
       } catch (Exception e) {
           LPI_ExceptionManager.logException('LPI_DeficiencyResponseCtrl', 'submitDeficiencyResponse', e);
           throw new AuraHandledException(e.getMessage());
     }
   }
    /**
     * @author  Nitesh Garg
     * @param    String notiId
     * @return  string   
     */
   @AuraEnabled
   public static String getNotificationRecord(String notiId){
       try {
           if(String.isNotBlank(notiId)){
              List<Notification__c> portalNotiRec = LPI_PortalNotificationDAO.getPortalNotificationById(notiId);
           
               if(portalNotiRec.size()>0){
                   return portalNotiRec[0].Description__c;
               } 
           }
           return null;
       } catch (Exception e) {
           LPI_ExceptionManager.logException('LPI_DeficiencyResponseCtrl', 'getNotificationRecord', e);
           throw new AuraHandledException(e.getMessage());
       }
   }
    
    /**
    * @author                      : Rachna Jadam
    * @since                       : 8 Oct 2023
    * @description                 : This method will return missing Due_Diligence__c items with deficiency review comment
    * @last modified by            : MTX Group Product Team
    * @last modified date          :
    * @modified details            :
    */
    @AuraEnabled
    public static DueDiligenceWrapper getDueDiligenceDetails(String deficencyId){
        try {
            if(String.isBlank(deficencyId)) {
                return null;
            }
            Id applicationId;
            String applicationNumber;
            String deficiencyReviewReason;
            for(Deficiency__c deficiency : new LPI_DeficiencyDAO.LPI_DeficiencyWithoutSharingDAO().getDeficiencyByDymanicQuery(
                'Id, Business_License_Application__c, Individual_Application__c, Deficiency_Reason__c, Business_License_Application__r.Name, Individual_Application__r.Name',
                'Id = \'' + String.escapeSingleQuotes(deficencyId) + '\'', '1', null, null)) {
                if(deficiency.Business_License_Application__c != null) {
                    applicationId = deficiency.Business_License_Application__c;
                    applicationNumber = deficiency.Business_License_Application__r.Name;
                } else if(deficiency.Individual_Application__c != null) {
                    applicationId = deficiency.Individual_Application__c;
                    applicationNumber = deficiency.Individual_Application__r.Name;
                }
                deficiencyReviewReason = deficiency.Deficiency_Reason__c;

            }
            List<RegulatoryTransactionFeeItemsWrapper> regTransactionFeeItemList = new List<RegulatoryTransactionFeeItemsWrapper>();
            for(RegulatoryTrxnFeeItem regTranFeeItem : new LPI_RegulatoryTrxnFeeItemDAO.LPI_RegulatoryTrxnFeeItemWithoutSharingDAO().getRegulatoryTrxnFeeItemByDymanicQuery('Id,Name,FeeAmount',
                                                        'RegulatoryTrxnFee.Deficiency__c = \''+String.escapeSingleQuotes(deficencyId)+'\''+
                                                        'AND RegulatoryTrxnFee.status__c =\'Pending\'',
                                                            null,
                                                            null,
                                                            null)){
                                    
                regTransactionFeeItemList.add(new RegulatoryTransactionFeeItemsWrapper(regTranFeeItem.Name,regTranFeeItem.FeeAmount));
            }
            if(applicationId != null) {
                List<DueDiligenceItemsWrapper> listOfDueDiligenceItems = new List<DueDiligenceItemsWrapper>();
                for(Due_Diligence__c dueDiligence : new LPI_DueDiligenceDAO.LPI_DueDiligenceWithoutSharingDAO().getDueDiligenceByDymanicQuery(
                    'Id, Checklist_Name__c, Comment__c',
                    '(Application__c = \'' + applicationId +'\' OR Individual_Application__c = \'' + applicationId +
                    '\' ) AND Status__c = \'Missing\'', null, null, null)){

                    listOfDueDiligenceItems.add(new DueDiligenceItemsWrapper(dueDiligence.Checklist_Name__c, dueDiligence.Comment__c));

                }
                return new DueDiligenceWrapper(listOfDueDiligenceItems,applicationNumber,deficiencyReviewReason,regTransactionFeeItemList);
            }
        } catch (Exception e) {
           LPI_ExceptionManager.logException('LPI_DeficiencyResponseCtrl', 'getNotificationRecord', e);
           throw new AuraHandledException(e.getMessage());
        }
        return null;
    }

    /**
    * @author                      : Rachna Jadam
    * @since                       : 8 Oct 2023
    * @description                 : Wrapper class used for Due_Diligence__c 
    * @last modified by            : MTX Group Product Team
    * @last modified date          :
    * @modified details            :
    */
    public class DueDiligenceWrapper {
        @AuraEnabled public List<DueDiligenceItemsWrapper> listOfDueDiligenceItems {get;set;}
        @AuraEnabled public String applicationNumber {get;set;}
        @AuraEnabled public String deficiencyReviewReason {get;set;}
        @AuraEnabled public List<RegulatoryTransactionFeeItemsWrapper> regTransactionFeeItemList{get;set;}

        public DueDiligenceWrapper(List<DueDiligenceItemsWrapper> listOfDueDiligenceItems, String applicationNumber, String deficiencyReviewReason, List<RegulatoryTransactionFeeItemsWrapper> regTransactionFeeItemList) {
            this.listOfDueDiligenceItems = listOfDueDiligenceItems;
            this.applicationNumber = applicationNumber;
            this.deficiencyReviewReason = deficiencyReviewReason;
            this.regTransactionFeeItemList = regTransactionFeeItemList;
        }
    }

    /**
    * @author                      : Rachna Jadam
    * @since                       : 8 Oct 2023
    * @description                 : Wrapper class used for Due_Diligence__c 
    * @last modified by            : MTX Group Product Team
    * @last modified date          :
    * @modified details            :
    */
    public class DueDiligenceItemsWrapper {
        @AuraEnabled public String checklistName {get;set;}
        @AuraEnabled public String comment {get;set;}
        
        public DueDiligenceItemsWrapper(String checklistName, String comment) {
            this.checklistName = checklistName;
            this.comment = comment;
        }
    }

    /**
    * @author                      : Sudhanshu Jain
    * @since                       : 22 feb 2024
    * @description                 : Wrapper class used for Regulatory Transaction Fee
    * @last modified by            : MTX Group Product Team
    * @last modified date          :
    * @modified details            :
    */
    public class RegulatoryTransactionFeeItemsWrapper {
        @AuraEnabled public String feeName {get;set;}
        @AuraEnabled public Decimal feeAmount {get;set;}
        RegulatoryTransactionFeeItemsWrapper(String feeName, Decimal feeAmount){
            this.feeName = feeName;
            this.feeAmount = feeAmount;
        }
    }
}