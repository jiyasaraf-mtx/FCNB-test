/**
 * @description       : Helper class for LPI_PublicComplaintTriggerHandler.
 * @author            : MTX Group Product Team
 * @group             : 
 * @last modified on  : 07-26-2024
 * @last modified by  : MTX Group Product Team
**/
public with sharing class LPI_PublicComplaintTriggerHelper {
    
    /**
    * @description : Method to Update Board__c field from Board_Name__c lookup when we create/update Complaint Record.
    * @author MTX Group Product Team
    * @param recordsList
    * @param mapOfOldRecords 
    **/
    public static void updateBoardName(List<PublicComplaint> recordsList,Map<Id,PublicComplaint> mapOfOldRecords) {
        try{
            List<PublicComplaint> pcList = new List<PublicComplaint>();
            Set<Id> boardIdSet = new Set<Id>(); 

            for(PublicComplaint rec : recordsList) {
                if(rec.Board_Name__c!=null && (mapOfOldRecords == null || mapOfOldRecords.get(rec.Id).Board_Name__c!=rec.Board_Name__c )) {
                    pcList.add(rec);
                    boardIdSet.add(rec.Board_Name__c);
                }
            }
            if(!boardIdSet.isEmpty()) {

                Map<Id,RegulatoryAuthority> boardIdToBoardNameMap = new Map<Id,RegulatoryAuthority>(new LPI_RegulatoryAuthorityDAO.LPI_RegulatoryAuthorityWithoutSharingDAO().getRegulatoryAuthorityByDymanicQueryWithoutSharing(
                    'Id,Name','Id IN '+ LPI_ServiceUtility.getStringValuesBySet(boardIdSet),null,null,null));

                for(PublicComplaint pcRec : pcList) {
                    if(boardIdToBoardNameMap.containsKey(pcRec.Board_Name__c)) {
                        pcRec.Board__c = boardIdToBoardNameMap.get(pcRec.Board_Name__c).Name;
                    }
                }
            }
        }
        catch (Exception exp) {
            LPI_ExceptionManager.logException('LPI_PublicComplaintTriggerHelper','updateBoardName',exp);
        }   
    }
    
    /**
    * @description : Method to update the BL Json on BL for related PublicComplaint records.
    * @author MTX Group Product Team
    * @param recordsList, mapOfOldRecords
    **/
    public static void updateBlJson(
        List<PublicComplaint> recordsList,
        Map<Id, PublicComplaint> mapOfOldRecords
    ) {
        try{
            Set<Id> publicComplIdSet = new Set<Id>();
            Set<Id> businessLicenseIdSet = new Set<Id>();
            
            if (mapOfOldRecords == null) {
                for (PublicComplaint pc : recordsList) {
                    publicComplIdSet.add(pc.id);
                }
                
                for(Business_Complaint__c bc : [SELECT Id, Business_License__c FROM Business_Complaint__c WHERE 
                                                Public_Complaint__c IN: publicComplIdSet AND Business_License__c != Null AND 
                                                (
                                                    (Public_Complaint__r.Status = 'Closed') 
                                                )]){
                    businessLicenseIdSet.add(bc.Business_License__c);
                }
            }
            else{
                for (PublicComplaint pc : [SELECT Id,Board_Name__r.Name,Status,Primary_Category__c,Other_Categories__c, Board_Name__c
                                           FROM PublicComplaint WHERE Id IN: mapOfOldRecords.keyset()]) {
                    if(
                        mapOfOldRecords.get(pc.Id).Status != pc.Status ||
                        mapOfOldRecords.get(pc.Id).Primary_Category__c != pc.Primary_Category__c ||
                        mapOfOldRecords.get(pc.Id).Other_Categories__c != pc.Other_Categories__c ||
                        mapOfOldRecords.get(pc.Id).Board_Name__c != pc.Board_Name__c
                    ){
                        publicComplIdSet.add(pc.Id);
                    }
                }
                
                if(!publicComplIdSet.isEmpty()){
                    for(Business_Complaint__c bc : [SELECT Id, Business_License__c, Public_Complaint__r.Board_Name__r.Name FROM Business_Complaint__c WHERE Business_License__c != Null AND Public_Complaint__c IN: publicComplIdSet ]){
                        if(bc.Public_Complaint__r.Board_Name__r.Name != 'Accountancy'){
                            businessLicenseIdSet.add(bc.Business_License__c);
                        }
                	}
                }
                
            }
            
            if (
                !(businessLicenseIdSet.isEmpty() ||
                System.isBatch() ||
                System.isFuture() ||
                System.isQueueable())
            ) {
                LPI_BusinessLicenseFieldUpdateBatch blBatch = new LPI_BusinessLicenseFieldUpdateBatch(
                    businessLicenseIdSet
                );
                database.executeBatch(blBatch);
            }
        }
        catch (Exception exp) {
            LPI_ExceptionManager.logException('LPI_PublicComplaintTriggerHelper','updateBlJson',exp);
        }
        
    }
}