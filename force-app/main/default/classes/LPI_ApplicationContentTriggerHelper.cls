/**
 * @author       : MTX Group Product Team
 * @description  : This Class is the Helper class on Application_Content__c trigger 
 * @since        : 12-Jan-2023
 */
public with sharing class LPI_ApplicationContentTriggerHelper {
    /**
	 * @author                      : MTX Group Product Team
	 * @since                       : Dec 20, 2022
	 * @description                 : This method update board name on IA
	 */
    public static void updateBoardName(List<Application_Content__c> newList, Map<Id,Application_Content__c> oldMap){
        Map<Application_Content__c, Id> appContentToIABLAMap = new Map<Application_Content__c, Id>();

        for(Application_Content__c appContent : newList){
            if(oldMap == NULL || 
            (oldMap.get(appContent.Id).Individual_Application__c != appContent.Individual_Application__c && appContent.Individual_Application__c != NULL) ||
            (oldMap.get(appContent.Id).Business_License_Application__c != appContent.Business_License_Application__c && appContent.Business_License_Application__c != NULL)
             ){
                if(appContent.Individual_Application__c != NULL){
                    appContentToIABLAMap.put(appContent, appContent.Individual_Application__c);
                }else if(appContent.Business_License_Application__c != NULL){
                    appContentToIABLAMap.put(appContent, appContent.Business_License_Application__c);
                }
            }
        }
        if(!appContentToIABLAMap.isEmpty()){
            Set<Id> iaBlaIdSet = new Set<Id>(appContentToIABLAMap.values());
            Map<Id, IndividualApplication> iaIdTosObjectRecord = new Map<Id, IndividualApplication>();
            Map<Id, BusinessLicenseApplication> blaIdTosObjectRecord = new Map<Id, BusinessLicenseApplication>();

            for(IndividualApplication iaRecord : 
                new LPI_IndividualApplicationDAO.LPI_DAO_IndividualApptWithoutSecurity().getIndividualApplicationByDymanicQuery(
                    'Id, LicenseType.IssuingDepartment.Name',
                    ' Id IN ' + LPI_ServiceUtility.getStringValuesBySet(iaBlaIdSet), null, null, null)
            ){
                iaIdTosObjectRecord.put(iaRecord.Id, iaRecord);
            }

            for(BusinessLicenseApplication blaRecord : 
                new LPI_BusinessLicenseApplicationDAO.LPI_DAO_BusinessLiceWithoutSecurity().getBusinessLicenseApplicationByDymanicQuery(
                    'Id, LicenseType.IssuingDepartment.Name',
                    ' Id IN ' + LPI_ServiceUtility.getStringValuesBySet(iaBlaIdSet), null, null, null)){
                blaIdTosObjectRecord.put(blaRecord.Id, blaRecord);
            }

            if(!blaIdTosObjectRecord.isEmpty() || !iaIdTosObjectRecord.isEmpty()){
                for(Application_Content__c accContent : appContentToIABLAMap.keySet()){
                    if(accContent.Individual_Application__c != NULL && 
                       iaIdTosObjectRecord.containsKey(accContent.Individual_Application__c) ){
                        accContent.Board_Name__c = iaIdTosObjectRecord.get(accContent.Individual_Application__c).
                                                  LicenseType.IssuingDepartment.Name;
                    }else if(accContent.Business_License_Application__c != NULL && 
                    blaIdTosObjectRecord.containsKey(accContent.Business_License_Application__c) ){
                        accContent.Board_Name__c = blaIdTosObjectRecord.get(accContent.Business_License_Application__c).
                                               LicenseType.IssuingDepartment.Name;
                 }
                }
            }
        }
    }
}