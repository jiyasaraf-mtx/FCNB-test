/**
 * @author                      : MTX Group Product Team
 * @since                       : 
 * @description                 : Regulatory Transaction Fee Trigger Helper
 * @last modified by            : MTX Group Product Team
 * @last modified date          : 
 * @modified details            : 
 */
public with sharing class LPI_RegulatoryTrnxFeeTriggerHelper {
	
    public final static string PAYMENT_PENDING_STATUS = 'Payment_Pending';
    /**
     * @author                      : MTX Group Product Team
     * @since                       : 
     * @description                 : sendPortalNotificationForPayment
     * @param recordList            : List<RegulatoryTrxnFee>
     * @param oldRecMap				: Map<Id, RegulatoryTrxnFee>
     * @return                      : void
     * @last modified by            : MTX Group Product Team
     * @last modified date          : 
     * @modified details            : 
     */
    public static void sendPortalNotificationForPayment(List<RegulatoryTrxnFee> recordList,
                                                        Map<Id, RegulatoryTrxnFee> oldRecMap){
        try{                                                                                               
            List<Notification__c> portalNotificationToInsert = new List<Notification__c>();
            Map<String, String> replaceTextMap = new Map<String, String>();
            Map<String, String> urlParameter = new Map<String, String>();
            urlParameter.put('c__isreinitiate','true');
            Map<String, Portal_Notification_Message__mdt> portalNotificationMessageMap = 
                                    new Map<String, Portal_Notification_Message__mdt>();
            Set<Id> iAOrBlaIdDeleteList = new Set<Id>();
            Set<Id> iAOrBlaIdAddList = new Set<Id>();
            Notification__c notification;
            for(RegulatoryTrxnFee objRe:recordList){
                if(objRe.Status__c != null && objRe.TotalFeeAmount != null && objRe.TotalFeeAmount != 0 
                   && (oldRecMap == null || oldRecMap.get(objRe.Id).Status__c != objRe.Status__c)
                   && (LPI_ServiceUtility.getSObjectNameById(objRe.ParentRecordId) == LPI_LiteralConstant.IA_SOBJECT_API ||
                    LPI_ServiceUtility.getSObjectNameById(objRe.ParentRecordId) == LPI_LiteralConstant.BLA_SOBJECT_API)){
                    if(objRe.Status__c == LPI_LiteralConstant.BLA_APPROVED_STATUS || 
                        objRe.Status__c == LPI_LiteralConstant.DECLINED_STATUS){
                        iAOrBlaIdDeleteList.add(objRe.ParentRecordId);
                    }else if(objRe.Status__c == LPI_LiteralConstant.PENDING_STATUS){
                        iAOrBlaIdAddList.add(objRe.ParentRecordId);
                    }
                }
            }
            if(!iAOrBlaIdDeleteList.isEmpty()){
                List<Notification__c> portalList =LPI_PortalNotificationDAO.getAllPortalNotificationByType(
                                                            LPI_LiteralConstant.PAYMENT_TYPE,iAOrBlaIdDeleteList);
                if(!portalList.isEmpty()){
                    for(Notification__c portRec : portalList){
                        portRec.Is_Resolved__c = true;
                    }
                    LPI_DML.doUpdate(portalList);
                }
            }
            if(!iAOrBlaIdAddList.isEmpty()){
                for (Portal_Notification_Message__mdt notiRec:LPI_CustomMetadataTypeDAO.getAllPortalNotificationByDeveloperName
                                                                (PAYMENT_PENDING_STATUS)) {
                    portalNotificationMessageMap.put(notiRec.DeveloperName, notiRec);
                }
                for(IndividualApplication iaRec:LPI_IndividualApplicationDAO.getILAByIAId(iAOrBlaIdAddList)){
                                                    replaceTextMap.put('[Application_Number]',iaRec.Name);
                                                    urlParameter.put('c__parid',iaRec.SavedApplicationRefId);
                                                    if(portalNotificationMessageMap.containskey(PAYMENT_PENDING_STATUS)){
                                                        notification = LPI_ServiceUtility.createPortalNotificationRecord(
                                                            portalNotificationMessageMap.get(PAYMENT_PENDING_STATUS),
                                                            true, replaceTextMap, urlParameter , iaRec.AccountId);
                                                        notification.Type__c = LPI_LiteralConstant.PAYMENT_TYPE;
                                                        notification.Individual_Application__c = iaRec.Id;
                                                        portalNotificationToInsert.add(notification);
                                                    } 
                                                }
                for(BusinessLicenseApplication blaRec:LPI_BusinessLicenseApplicationDAO.getBLAById(iAOrBlaIdAddList)){
                                                    replaceTextMap.put('[Application_Number]',blaRec.Name);
                                                    urlParameter.put('c__parid',blaRec.SavedApplicationRefId);
                                                    if(portalNotificationMessageMap.containskey(PAYMENT_PENDING_STATUS)){
                                                        notification = LPI_ServiceUtility.createPortalNotificationRecord(
                                                            portalNotificationMessageMap.get(PAYMENT_PENDING_STATUS),
                                                            true, replaceTextMap, urlParameter , blaRec.Applicant.AccountId);
                                                        notification.Type__c = LPI_LiteralConstant.PAYMENT_TYPE ;
                                                        notification.Business_License_Application__c = blaRec.Id;
                                                        portalNotificationToInsert.add(notification);
                                                    }
                                                }
            }
            if(!portalNotificationToInsert.isEmpty()){
                LPI_DML.doInsert(portalNotificationToInsert);
            }
        } catch (Exception e) {
          LPI_ExceptionManager.logException('RegulatoryTransactionFeeTriggerHelper', 'sendPortalNotificationForPayment', e);
          throw new AuraHandledException(e.getMessage());
      }
    }
    
    /**
    * @author                      : MTX Group Product Team
    * @since                       : Dec 20, 2022
    * @description                 : This method update board name on Regulatory Trxn Fee
    */
    public static void updateBoardName(List<RegulatoryTrxnFee> newList, Map<Id,RegulatoryTrxnFee> oldMap){
        Map<RegulatoryTrxnFee, Id> feeToIABLAMap = new Map<RegulatoryTrxnFee, Id>();
        
        for(RegulatoryTrxnFee fee : newList){
            if(oldMap == NULL || 
               (oldMap.get(fee.Id).ParentRecordId  != fee.ParentRecordId  && fee.ParentRecordId  != NULL)){
                   if(fee.ParentRecordId  != NULL){
                       feeToIABLAMap.put(fee, fee.ParentRecordId);
                   }
               }
        }
        if(!feeToIABLAMap.isEmpty()){
            Set<Id> iaBlaIdSet = new Set<Id>(feeToIABLAMap.values());
            Map<Id, IndividualApplication> iaIdTosObjectRecord = new Map<Id, IndividualApplication>();
            Map<Id, BusinessLicenseApplication> blaIdTosObjectRecord = new Map<Id, BusinessLicenseApplication>();
            
            for(IndividualApplication iaRecord : LPI_IndividualApplicationDAO.getILAByIAId(iaBlaIdSet)){
                iaIdTosObjectRecord.put(iaRecord.Id, iaRecord);
            }
            for(BusinessLicenseApplication blaRecord : LPI_BusinessLicenseApplicationDAO.getBLAById(iaBlaIdSet)){
                blaIdTosObjectRecord.put(blaRecord.Id, blaRecord);
            }
            if(!blaIdTosObjectRecord.isEmpty() || !iaIdTosObjectRecord.isEmpty()){
                for(RegulatoryTrxnFee fee : feeToIABLAMap.keySet()){
                    if(fee.ParentRecordId != NULL && 
                       iaIdTosObjectRecord.containsKey(fee.ParentRecordId) ){
                           fee.Board_Name__c = iaIdTosObjectRecord.get(fee.ParentRecordId).
                               LicenseType.IssuingDepartment.Name;
                    }
                    else if(fee.ParentRecordId != NULL && 
                            blaIdTosObjectRecord.containsKey(fee.ParentRecordId)){
                                fee.Board_Name__c = blaIdTosObjectRecord.get(fee.ParentRecordId).
                                    LicenseType.IssuingDepartment.Name;
                    }
                }
            }
        }
    }
}