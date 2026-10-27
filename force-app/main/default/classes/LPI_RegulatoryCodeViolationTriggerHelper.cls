/**
 * @description       : 
 * @author            : MTX Group Product Team
 * @group             : 
 * @last modified on  : 07-24-2024
 * @last modified by  : MTX Group Product Team
**/
public with sharing class LPI_RegulatoryCodeViolationTriggerHelper {
    private static final String DISCIPLINE_VALUES_MDT  = 'Public_Discipline_Values';
    private static final String CLASS_NAME = 'LPI_RegulatoryCodeViolationTriggerHelper';

    /**
    * @description 
    * @author MTX Group Product Team | 05-06-2024 
    * @param newList 
    * @param oldMap 
    **/
    public static void populatePublicCheckBoxBasedOnAction(List<RegulatoryCodeViolation> newList,Map<Id, RegulatoryCodeViolation> oldMap) {
        Set<String> actionValues = new Set<String>();
        String yesValues =  [SELECT Id,Value__c FROM LPI_RealTimeAPIConfiguration__mdt WHERE DeveloperName = :DISCIPLINE_VALUES_MDT]?.Value__c;
        actionValues.addAll(yesValues?.split(';'));
        
        for(RegulatoryCodeViolation record: newList) {
             if(record.Action__c!=null || (oldMap!=null && oldMap.get(record.Id).Action__c!=record.Action__c)) {
                record.Is_Public__c = ( actionValues.contains(record.Action__c) ? 'Yes': 'No');
            }
        }
    }
    
    /**
    * @description : Method to update the BL Json on BL for related RegulatoryCodeViolation records.
    * @author MTX Group Product Team | 06-02-2023 
    * @param recordsList, mapOfOldRecords
    **/
    public static void updateBlJson(
        List<RegulatoryCodeViolation> recordsList,
        Map<Id, RegulatoryCodeViolation> mapOfOldRecords
    ) {
        try{
            Set<Id> businessLicenseIdSet = new Set<Id>();
            Set<Id> caseIdSet = new Set<Id>();
            
            if (mapOfOldRecords == null) {
                for (RegulatoryCodeViolation rc : recordsList) {
                    if(String.isNotBlank(rc.Case__c)){
                        caseIdSet.add(rc.Case__c);
                    }
                }
                businessLicenseIdSet = getBlId(caseIdSet);
            }
            else{
                for(RegulatoryCodeViolation rc : recordsList){
                    if(
                    	mapOfOldRecords.get(rc.Id).Action__c != rc.Action__c ||
                    	mapOfOldRecords.get(rc.Id).DateCreated != rc.DateCreated ||
                    	mapOfOldRecords.get(rc.Id).DateResolved != rc.DateResolved ||
                    	mapOfOldRecords.get(rc.Id).Terms_Of_Discipline__c != rc.Terms_Of_Discipline__c
                	){
                        if(String.isNotBlank(rc.Case__c)){
                            caseIdSet.add(rc.Case__c);
                        }
                	}
                }
                businessLicenseIdSet = getBlId(caseIdSet);
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
            LPI_ExceptionManager.logException('RegulatoryCodeViolationTriggerHelper','updateBlJson',exp);
        }
    }
    
    public static Set<Id> getBlId(Set<Id> casIdSet){
        Set<Id> publicComplIdSet = new Set<Id>();
        Set<Id> busLicenseIdSet = new Set<Id>();
        
        if(!casIdSet.isEmpty()){
            for(ComplaintCase cCase : [SELECT ID,PublicComplaintId FROM ComplaintCase WHERE CaseId != null AND CaseId IN : casIdSet AND PublicComplaint.Board_Name__r.Name IN ('Accountancy', 'Real Estate Appraisers')]){
                publicComplIdSet.add(cCase.PublicComplaintId);
            }
        }
        if(!publicComplIdSet.isEmpty()){
            for(Business_Complaint__c bc : [SELECT Id, Business_License__c FROM Business_Complaint__c WHERE Public_Complaint__c IN: publicComplIdSet AND ((Public_Complaint__r.Board_Name__r.Name = 'Accountancy' AND Business_License__r.Disciplinary_Status__c != Null) OR Public_Complaint__r.Board_Name__r.Name = 'Real Estate Appraisers')]){
                busLicenseIdSet.add(bc.Business_License__c);
            }
        }
        return busLicenseIdSet;
    }
    /**
	 * @author                      : MTX Group Product Team
	 * @since                       : 24 Jul, 2023
	 * @description                 : This method will update RegulatoryCodeViolation's Visit ContextId on ResponseContextId
	 * @param recordsList           : Takes List of List<RegulatoryCodeViolation>
	 * @return                      : `void`
	 * @last modified by            : MTX Group Product Team
	 * @last modified date          :
	 * @modified details            :
	 */
    public static void updateVisitContextIdOnRCV(List<RegulatoryCodeViolation> recordsList) {
        try {
            Set<Id> visitContextIdSet = new Set<id>();
            Set<Id> caseIdSet = new Set<id>();
            Map<Id, Visit> idToVisitMap = new Map<Id, Visit>();
            Map<Id,ComplaintCase> casIdToComplaintCasemap = new Map<Id,ComplaintCase>();
            for (RegulatoryCodeViolation rcv : recordsList) {
                if (String.isNotBlank(rcv.InspectionId)) {
                    visitContextIdSet.add(rcv.InspectionId);
                }
                if (String.isNotBlank(rcv.Case__c)) {
                    caseIdSet.add(rcv.Case__c);
                }
            }
            if (!visitContextIdSet.isEmpty()) {
                idToVisitMap = new Map<Id,Visit>(LPI_VisitControllerDAO.getVistListByDynamicQuery(
                    new List<String>{'Id, ContextId,Board_Name__c'},
                    'Id IN ' +
                        LPI_ServiceUtility.getStringValuesBySet(visitContextIdSet),
                    null,
                    null,
                    null
                ));
            }
            if (!caseIdSet.isEmpty()) {
                for(ComplaintCase cs : LPI_ComplaintCaseDao.fetchComplaintCaseRecords(
                    'Id,caseId,Case.Board_Name__c,PublicComplaintId',
                    'CaseId IN '+
                        LPI_ServiceUtility.getStringValuesBySet(caseIdSet),
                    null,
                    null
                )){
                    casIdToComplaintCasemap.put(cs.caseId,cs);
                }
                
            }
            if (idToVisitMap.isEmpty() && casIdToComplaintCasemap.isEmpty()) {
                return; 
            }
            for (RegulatoryCodeViolation rcv : recordsList) {
                if (!idToVisitMap.containsKey(rcv.InspectionId) && !casIdToComplaintCasemap.containsKey(rcv.Case__c)) {
                    continue;
                    
                }
                rcv.Board_Name__c = casIdToComplaintCasemap.containsKey(rcv.Case__c) ? casIdToComplaintCasemap.get(rcv.Case__c).Case.Board_Name__c : idToVisitMap.get(rcv.InspectionId).Board_Name__c;
                rcv.ResponseContextId = idToVisitMap.containsKey(rcv.InspectionId) && String.isNotBlank(idToVisitMap.get(rcv.InspectionId).ContextId) && idToVisitMap.get(rcv.InspectionId).ContextId.getSObjectType().getDescribe().getName() != LPI_LiteralConstant.BUSINESSLICENSE_SOBJECT_API ?  idToVisitMap.get(rcv.InspectionId).ContextId : casIdToComplaintCasemap.containsKey(rcv.Case__c) ? casIdToComplaintCasemap.get(rcv.Case__c).PublicComplaintId :  rcv.ResponseContextId;
            }
        } catch (Exception e) {
			LPI_ExceptionManager.logException(CLASS_NAME, 'updateVisitContextIdOnRCV', e);
		}
	}

    /**
     *   @author                         : MTX Group Product Team
     *   @since                          : 1 March, 2024
     *   @description                    : this method update the field on rcv
     *   @param newCasesList             : Contains List of New RCV Records
     */
    public static void updateBLFormCaseOrIns(List<RegulatoryCodeViolation> newRCVList){
        
        Set<Id> caseIds = new Set<Id>();
        for(RegulatoryCodeViolation rcv : newRCVList){
            if(rcv.Case__c != null){
                caseIds.add(rcv.Case__c);
            }else{
                rcv.BL_From_Case__c = '';
            }
        }
        if(caseIds.isEmpty()){
            return;
        }
        Map<Id,Id> caseBLIdMap = new Map<Id,Id>();
        Map<Id,Id> caseAccountIdMap = new Map<Id,Id>();
        String fields = 'id,Business_License_Id__c,AccountId ';
		String whereClause = 'Id IN '+LPI_ServiceUtility.getStringValuesBySet(caseIds);
		LPI_CaseDAO.LPI_CaseWithoutSharingDAO caseWithout = new LPI_CaseDAO.LPI_CaseWithoutSharingDAO();
        for(Case c : caseWithout.getCaseRecordsWithoutSharing(fields,whereClause,null,null)){
            caseBLIdMap.put(c.Id,c.Business_License_Id__c);
            caseAccountIdMap.put(c.Id,c.AccountId);
        }
        for(RegulatoryCodeViolation rcv : newRCVList){
            if(rcv.case__c != null && caseBLIdMap.get(rcv.Case__c) != null){
                rcv.BL_From_Case__c = caseBLIdMap.get(rcv.Case__c);
                rcv.Respondent__c  = caseAccountIdMap.get(rcv.Case__c);
            }else{
                rcv.BL_From_Case__c = '';
            }
        }

	}

    /**
     *   @author                         : MTX Group Product Team
     *   @since                          : 22 Feb, 2024
     *   @description                    : this method count the RCV on Account
     *   @param newCasesList             : Contains List of New RCV Records
     *   @param oldCasesMap              : Contains List of Old Old Records
     */
    public static void countOfRCVOnAccount(List<RegulatoryCodeViolation> newRCVList, Map<Id,RegulatoryCodeViolation> oldRCVMap)
    {
        try{
           set<id> accIds= new set<id>();
            if(newRCVList != null){

                for(RegulatoryCodeViolation rcv : newRCVList){
                    
                    if(rcv.Respondent__c  != null){
                        accIds.add(rcv.Respondent__c);
                    }
                }      
            }
            if(oldRCVMap != null){
                for(RegulatoryCodeViolation rcv : oldRCVMap.values()){
                    if(rcv.Respondent__c  != null){
                        accIds.add(rcv.Respondent__c);
                    }
                }
            }
            if(accIds.isEmpty()){
                return;
            }
            String fieldsToQuery ='id,Discipline_Counter__c,(Select id from Regulatory_Code_Violations__r)';
            String whereClause =  'Id IN '+ LPI_ServiceUtility.getStringValuesBySet(accids);
            List<Account> accList = new LPI_AccountDAO.LPI_AccountWithoutSharingDAO().getAccountByDymanicQuery(fieldsToQuery,whereClause,null,null,null);
            if(accList!=null){
                for(Account acc : accList){
                    acc.Discipline_Counter__c = acc.Regulatory_Code_Violations__r.size();
                } 
            }
            
            if (!accList.isEmpty()) {
                LPI_TriggerHandler.bypass('LPI_AccountTriggerHandler');
                if (LPI_TriggerHandler.isBypassed('LPI_AccountTriggerHandler')) {
                    LPI_DML.doUpdate(accList);
                }
                LPI_TriggerHandler.clearBypass('LPI_AccountTriggerHandler');
            }

        } catch (Exception e) {
            LPI_ExceptionManager.logException(
                'RegulatoryCodeViolationTriggerHelper',
                'countOfRCVOnAccount',
                e
            );
        }
    }

    /**
     *   @author                         : MTX Group Product Team
     *   @since                          : 22 Feb, 2024
     *   @description                    : this method count the RCV on License
     *   @param newCasesList             : Contains List of New RCV Records
     *   @param oldCasesMap              : Contains List of Old Old Records
     */
    public static void countOfRCVOnLicense(List<RegulatoryCodeViolation> newRCVList, Map<Id,RegulatoryCodeViolation> oldRCVMap,String triggerContextType)
    {
        try{
            Set<Id> licIdSet = new Set<Id>();
            Map<Id, Integer> licenseCounterMap = new Map<Id, Integer>();

            if(newRCVList != null){
                for (RegulatoryCodeViolation rcv : newRCVList) {
                    Boolean isBLNewContext = false;
                    Boolean isBLOldContext = false;
                    if(rcv.case__c == null && rcv.InspectionId != null && rcv.ContextId_From_Inspection__c != null){
                        Id blIdNew = (Id)rcv.ContextId_From_Inspection__c;
                        isBLNewContext = blIdNew.getSObjectType().getDescribe().getName().equals('BusinessLicense');
                    }
                    if(oldRCVMap != null && oldRCVMap.get(rcv.Id).BL_From_Case__c == null && oldRCVMap.get(rcv.Id).ContextId_From_Inspection__c != null){
                        Id blIdOld = (Id)oldRCVMap.get(rcv.Id).ContextId_From_Inspection__c;
                        isBLOldContext = blIdOld.getSObjectType().getDescribe().getName().equals('BusinessLicense');
                    }

                
                    if (triggerContextType == 'isInsert' || triggerContextType == 'isUndelete') {
                        if (rcv.case__c != null && rcv.BL_From_Case__c != null) {
                            updateRCVCountOnLic((Id)rcv.BL_From_Case__c, licenseCounterMap, licIdSet, 1);
                        }else if(rcv.InspectionId != null && rcv.ContextId_From_Inspection__c != null){
                            if(isBLNewContext){
                                updateRCVCountOnLic((Id)rcv.ContextId_From_Inspection__c, licenseCounterMap, licIdSet, 1);
                            }
                }      
                    } else if (triggerContextType == 'isUpdate') { 
                        if(rcv.Case__c != null || oldRCVMap.get(rcv.Id).BL_From_Case__c != null){
                            if(rcv.BL_From_Case__c != null && oldRCVMap != null && oldRCVMap.get(rcv.Id).BL_From_Case__c != null){
                                if(oldRCVMap.get(rcv.Id).BL_From_Case__c != rcv.BL_From_Case__c){
                                    updateRCVCountOnLic((Id)rcv.BL_From_Case__c, licenseCounterMap, licIdSet, 1);
                                    updateRCVCountOnLic((Id)oldRCVMap.get(rcv.Id).BL_From_Case__c, licenseCounterMap, licIdSet, -1);
                                }
                            }else if(rcv.BL_From_Case__c == null && oldRCVMap.get(rcv.Id).BL_From_Case__c != null){
                                updateRCVCountOnLic((Id)oldRCVMap.get(rcv.Id).BL_From_Case__c, licenseCounterMap, licIdSet, -1);
                            }else if(rcv.BL_From_Case__c != null && oldRCVMap.get(rcv.Id).BL_From_Case__c == null){
                                updateRCVCountOnLic((Id)rcv.BL_From_Case__c, licenseCounterMap, licIdSet, 1);
                            }
                        }
                        if(rcv.InspectionId != null || oldRCVMap.get(rcv.Id).ContextId_From_Inspection__c != null){
                            if(rcv.ContextId_From_Inspection__c != null && oldRCVMap != null && oldRCVMap.get(rcv.Id).ContextId_From_Inspection__c != null){
                                if(oldRCVMap.get(rcv.Id).InspectionId != rcv.InspectionId){
                                    if(isBLNewContext){
                                        updateRCVCountOnLic((Id)rcv.ContextId_From_Inspection__c, licenseCounterMap, licIdSet, 1);
                                    }
                                    if(isBLOldContext){
                                        updateRCVCountOnLic((Id)oldRCVMap.get(rcv.Id).ContextId_From_Inspection__c, licenseCounterMap, licIdSet, -1);
                                    }
                                }
                            }else if(rcv.InspectionId == null && oldRCVMap.get(rcv.Id).InspectionId != null && isBLOldContext == true){
                                updateRCVCountOnLic((Id)oldRCVMap.get(rcv.Id).ContextId_From_Inspection__c, licenseCounterMap, licIdSet, -1);
                            }else if(rcv.InspectionId != null && oldRCVMap.get(rcv.Id).InspectionId == null && isBLNewContext == true){
                                updateRCVCountOnLic((Id)rcv.ContextId_From_Inspection__c, licenseCounterMap, licIdSet, 1);
                            }
                        }
                    } 
                }
            }
            if (triggerContextType == 'isDelete' && oldRCVMap != null) {
                for (RegulatoryCodeViolation rcv : oldRCVMap.values()) {
                    if (rcv.case__c != null && rcv.BL_From_Case__c != null) {
                        updateRCVCountOnLic((Id)rcv.BL_From_Case__c, licenseCounterMap, licIdSet, -1);
                    }else if(rcv.InspectionId != null && rcv.ContextId_From_Inspection__c != null){
                        Id blId = (Id)rcv.ContextId_From_Inspection__c;
                        if(blId.getSObjectType().getDescribe().getName().equals('BusinessLicense')){
                            updateRCVCountOnLic(blId, licenseCounterMap, licIdSet, -1);
                    }
                }
            }
            }

            List<BusinessLicense> updatedBLList = new List<BusinessLicense>();
            if(licIdSet.isEmpty()){
                return;
            }
            
            LPI_BusinessLicenseDAO.LPI_BusinessLicenseWithoutSharingDAO businessLicenseDao = new LPI_BusinessLicenseDAO.LPI_BusinessLicenseWithoutSharingDAO();
                List<BusinessLicense> businessLicList = businessLicenseDao.getBusinessLicenseByDymanicQuery(
                'id,Discipline_Counter__c',
                'Id IN '+ LPI_ServiceUtility.getStringValuesBySet(licIdSet),
                    null,
                    null,
                    null
                );
            for (BusinessLicense bl : businessLicList) {
                Integer counter = licenseCounterMap.get(bl.Id);
                if (counter != null) {
                    bl.Discipline_Counter__c = (bl.Discipline_Counter__c != null ? bl.Discipline_Counter__c : 0) + counter;
                    updatedBLList.add(bl);
                }
            }
            
            if (!updatedBLList.isEmpty()) {
                LPI_TriggerHandler.bypass('LPI_BusinessLicenseTriggerHandler');
                if (LPI_TriggerHandler.isBypassed('LPI_BusinessLicenseTriggerHandler')) {
                    LPI_DML.doUpdate(updatedBLList);
                }
                LPI_TriggerHandler.clearBypass('LPI_BusinessLicenseTriggerHandler');
            }

        } catch (Exception e) {
            LPI_ExceptionManager.logException(
                'RegulatoryCodeViolationTriggerHelper',
                'countOfRCVOnLicense',
                e
            );
        }
    }
    
    /**
    * @description 
    * @author MTX Group Product Team | 05-06-2024 
    * @param licenseId 
    * @param licenseCounterMap 
    * @param licIdSet 
    * @param countChange 
    **/
    private static void updateRCVCountOnLic(Id licenseId, Map<Id, Integer> licenseCounterMap, Set<Id> licIdSet, Integer countChange) {
        licIdSet.add(licenseId);
        if (licenseCounterMap.containsKey(licenseId)) {
            licenseCounterMap.put(licenseId, licenseCounterMap.get(licenseId) + countChange);
        } else {
            licenseCounterMap.put(licenseId, countChange);
        }
    }
}