public without sharing class LPIInspectionsCorrectiveActionController {
   
    @AuraEnabled
    public static List<RegulatoryCodeViolation> fetchInspectionViolationRecords(String inspectionId){
        try {
            try {
                String fieldsToQuery = 'Id, Name, Inspection.Name, InspectionId, Status, Licensee_Comments__c, ViolationType.Name, Supervisor_Board_Staff_Comments__c, ViolationType.Type, RegulatoryCode.Name';
                String whereClause = 'InspectionId = \'' + inspectionId + '\'';
                List<RegulatoryCodeViolation> regCodeVioList = LPI_RegulatoryCodeViolationDAO.getRegulatoryCodeViolationListByDynamicQuery(fieldsToQuery,whereClause,null,null,null);
                if (!regCodeVioList.isEmpty()) {
                    return regCodeVioList;
                }
                return null;
            } catch (Exception ex) {
                LPI_ExceptionManager.logException('LPIInspectionsCorrectiveActionController', 'fetchInspectionViolationRecords', ex);
                throw new LPI_Exception(ex.getMessage());
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Boolean getUserType() {
        try {
            User currentUser = [SELECT UserType, IsPortalEnabled FROM User WHERE Id = :UserInfo.getUserId()];
            return currentUser.IsPortalEnabled;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<RegulatoryCodeViolation> fetchVisitList() {
        try {
            Set<Id> accIdSet = getRelatedAccountId();
            Set<Id> newVisitIdSet = new Set<Id>();
            for(Visit v: [SELECT Id, Name , AccountId FROM Visit WHERE AccountId IN :accIdSet]){
                newVisitIdSet.add(v.Id);
            }
            System.debug('newVisitIdSet>>>'+newVisitIdSet);
             List<RegulatoryCodeViolation> regCodeVioList = [SELECT Id, Name, Inspection.Name, InspectionId, Status, Licensee_Comments__c, 
                                                    ViolationType.Name, Supervisor_Board_Staff_Comments__c, ViolationType.Type, 
                                                    RegulatoryCode.Name
                                                    FROM RegulatoryCodeViolation
                                                    WHERE InspectionId =:newVisitIdSet];

            
            System.debug('regCodeVioList>>>'+regCodeVioList);
            if(!regCodeVioList.isEmpty()){
                return regCodeVioList;
            }
            return null;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    private static Set<Id> getRelatedAccountId(){
        String userId = UserInfo.getUserId();
        User u  =  LPI_WithoutSharingUtility.getUserRecordDetailWithoutSharing(userId);
        String accwhereClause='Id = \''+ String.escapeSingleQuotes(u.AccountId)+'\'';
        List<Account> accData =  LPI_AccountDAO.getAccountListByDynamicQuery(new List<String>{'Id','SelectedAccountId__c'},accwhereClause,null,null,null);
        String selectedAccoutnId = (!accData.isEmpty() && String.isNotBlank(accData[0].SelectedAccountId__c)?accData[0].SelectedAccountId__c:u.AccountId);
        Set<Id> accIdSet = LPI_RelationshipService.getRelatedAccountId(selectedAccoutnId);
        return accIdSet;
    }

    @AuraEnabled
    public static void updateRCV(List<RegulatoryCodeViolation> records) {
        try {
            System.debug('RCV Records>>>'+records);
            update records;
        } catch (Exception e) {
            throw new AuraHandledException('An error occurred while updating records: ' + e.getMessage());
        }
    }
}