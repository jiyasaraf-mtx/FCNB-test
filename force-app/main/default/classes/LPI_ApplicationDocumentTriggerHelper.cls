/**
 * @author       : MTX Group Product Team
 * @description  : This Class is the Helper class on Application_Document__c trigger 
 * @since        : 12-Jan-2023
 */
public with sharing class LPI_ApplicationDocumentTriggerHelper {

    private static final String APPROVED_STATUS = 'Approved';
    /**
	 * @author                      : MTX Group Product Team
	 * @since                       : Feb 1, 2024
	 * @description                 : Method helps to approve the child Application Documents on approving parent.
	 */
    public static void updateChildAppDocOnStatusApprove(List<Application_Document__c> newList, Map<Id,Application_Document__c> oldMap) {
        try {
            Set<Id> appDocIdSet = new Set<Id>();
            List<Application_Document__c> appDocListToUpdate = new List<Application_Document__c>();

            for(Application_Document__c appDoc : newList) {
                if(appDoc.Status__c!=oldMap.get(appDoc.Id).Status__c && appDoc.Status__c == APPROVED_STATUS) {
                    appDocIdSet.add(appDoc.Id);
                }
            }
            if(appDocIdSet.isEmpty()) {
                return;
            }
            String fields = 'Id,Application_Document__c';
            String whereClause = 'Application_Document__c IN '+ LPI_ServiceUtility.getStringValuesBySet(appDocIdSet);
            // Querying Child Records.
            for(Application_Document__c appDoc : LPI_ApplicationDocumentDAO.getApplicantDocumentByDymanicQuery(fields,whereClause,null,null,null)) {
                appDocListToUpdate.add(new Application_Document__c(
                    Id = appDoc.Id,
                    Status__c = APPROVED_STATUS
                ));
            }
            if(!appDocListToUpdate.isEmpty())  {
                LPI_DML.doUpdate(appDocListToUpdate);
            }
        }
        catch(Exception ex) {
            LPI_ExceptionManager.logException('LPI_ApplicationDocumentTriggerHelper', 'updateChildAppDocOnStatusApprove', ex);
        }
    }


    /**
	 * @author                      : MTX Group Product Team
	 * @since                       : Dec 20, 2022
	 * @description                 : This method update board name on IA
	 */
    public static void updateBoardName(List<Application_Document__c> newList, Map<Id,Application_Document__c> oldMap){
        Map<Application_Document__c, Id> appDocToIABLAMap = new Map<Application_Document__c, Id>();

        for(Application_Document__c appDoc : newList){
            if(oldMap == NULL  || 
            (oldMap.get(appDoc.Id).Individual_Application__c != appDoc.Individual_Application__c && appDoc.Individual_Application__c != NULL) ||
            (oldMap.get(appDoc.Id).Business_License_Application__c != appDoc.Business_License_Application__c && appDoc.Business_License_Application__c != NULL)
             ){
                if(appDoc.Individual_Application__c != NULL){
                    appDocToIABLAMap.put(appDoc, appDoc.Individual_Application__c);
                }else if(appDoc.Business_License_Application__c != NULL){
                    appDocToIABLAMap.put(appDoc, appDoc.Business_License_Application__c);
                }
            }
        }
        if(!appDocToIABLAMap.isEmpty()){
            Set<Id> iaBlaIdSet = new Set<Id>(appDocToIABLAMap.values());
            Map<Id, IndividualApplication> iaIdTosObjectRecord = new Map<Id, IndividualApplication>();
            Map<Id, BusinessLicenseApplication> blaIdTosObjectRecord = new Map<Id, BusinessLicenseApplication>();

            for(IndividualApplication iaRecord : LPI_IndividualApplicationDAO.getILAByIAId(iaBlaIdSet)){
                iaIdTosObjectRecord.put(iaRecord.Id, iaRecord);
            }

            for(BusinessLicenseApplication blaRecord : LPI_BusinessLicenseApplicationDAO.getBLAById(iaBlaIdSet)){
                blaIdTosObjectRecord.put(blaRecord.Id, blaRecord);
            }

            if(!blaIdTosObjectRecord.isEmpty() || !iaIdTosObjectRecord.isEmpty()){
                for(Application_Document__c accDoc : appDocToIABLAMap.keySet()){
                    if(accDoc.Individual_Application__c != NULL && 
                       iaIdTosObjectRecord.containsKey(accDoc.Individual_Application__c) ){
                        accDoc.Board_Name__c = iaIdTosObjectRecord.get(accDoc.Individual_Application__c).
                                                  LicenseType.IssuingDepartment.Name;
                    }else if(accDoc.Business_License_Application__c != NULL && 
                    blaIdTosObjectRecord.containsKey(accDoc.Business_License_Application__c) ){
                        accDoc.Board_Name__c = blaIdTosObjectRecord.get(accDoc.Business_License_Application__c).
                                               LicenseType.IssuingDepartment.Name;
                 }
                }
            }
        }
    }
}