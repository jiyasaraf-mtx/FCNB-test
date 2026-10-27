/**
     * @author                      : MTX Group Product Team
     * @since                       : 20 Jan 2023
     * @description                 : This class used to fetch Draft Application for a Account
     * @last modified by            : MTX Group Product Team
     * @last modified date          : 
     * @modified details            : 
     */
    public with sharing class LPI_DraftApplicationViewController {
    
        public final static string SUPPORT_STAFF = 'Support Staff';
        /**
         * @author                      : MTX Group Product Team
         * @since                       : 20 Jan 2023
         * @description                 : This method fetches the Draft application created by support staff user
         * @param recordId              : takes input as accountId
         * @return                      : List<ApplicationWrapper>
         * @last modified by            : MTX Group Product Team
         * @last modified date          : 
         * @modified details            : 
         */
        @AuraEnabled
        public static List<ApplicationWrapper> fetchDraftApplication(String recordId){
            try {
                List<String> listOfStatus = new List<String>();
                listOfStatus.add(LPI_LiteralConstant.PAR_DRAFT_STATUS);
                Boolean isSupportStaffCreated;
                List<ApplicationWrapper> applicationList = new List<ApplicationWrapper>();
                String queryFields = 'Id,Name,Regulatory_Authorization_Type__r.Name,Type__c,Status__c,ApplicationType,Amendment_Type__c,CreatedDate,SavedApplicationUrl,CreatedBy.Profile.Name';
                String whereCondition = 'BusinessAccountNameId =' + '\'' + String.escapeSingleQuotes(recordId) + '\'' +
                                        ' AND Status__c IN ' + LPI_ServiceUtility.getStringValuesByList(listOfStatus);
                Map<Id, PreliminaryApplicationRef> mapOfPARWithId = new Map<Id, PreliminaryApplicationRef>(LPI_PreliminaryApplicationRefDAO.getPreAppRefByDymanicQueryWithoutSecurity(
                    queryFields, whereCondition, null,'CreatedDate','desc'));
                Set<Id> setOfParIds = mapOfPARWithId.keySet();
                Map<Id, String> mapOfOmniScriptSavedSessionWithParId = new Map<Id, String>();
                String queryForOmniScriptSavedSession = 'Select Id, RelatedRecordIdentifier FROM OmniScriptSavedSession Where RelatedRecordIdentifier IN :setOfParIds WITH SECURITY_ENFORCED ';
                for(OmniScriptSavedSession oss : Database.query(queryForOmniScriptSavedSession)) {
                    if(!mapOfOmniScriptSavedSessionWithParId.containsKey(oss.RelatedRecordIdentifier)) {
                        mapOfOmniScriptSavedSessionWithParId.put(oss.RelatedRecordIdentifier, oss.Id);
                    }
                }
                for(PreliminaryApplicationRef draftApplication : mapOfPARWithId.values())
                    {
                        isSupportStaffCreated = false;
                        if(draftApplication.CreatedBy.Profile.Name.equalsIgnoreCase(SUPPORT_STAFF)){
                            isSupportStaffCreated = true;
                        }
                        applicationList.add(new ApplicationWrapper(draftApplication.Id,draftApplication.Name,
                        draftApplication.Type__c,draftApplication.Regulatory_Authorization_Type__r.name,
                        draftApplication.ApplicationType,
                        String.valueOf(draftApplication.CreatedDate?.format()),
                        draftApplication.Status__c,draftApplication.SavedApplicationUrl,isSupportStaffCreated, 
                        mapOfOmniScriptSavedSessionWithParId.get(draftApplication.Id)));
                    }
                return applicationList;
            } catch (Exception e) {
                LPI_ExceptionManager.logException('LPI_DraftApplicationViewController', 'fetchDraftApplication', e);
                throw new AuraHandledException(e.getMessage());
            }
            
        }
    
       /**
         * @author                      : MTX Group Product Team
         * @since                       : 
         * @description                 : This class wrapper used to store application detail
         * @last modified by            : MTX Group Product Team
         * @last modified date          : 
         * @modified details            : 
         */
        public class ApplicationWrapper{
            @AuraEnabled public String id ;
            @AuraEnabled public String name ;
            @AuraEnabled public String type ;
            @AuraEnabled public String licenseType ;
            @AuraEnabled public String applicationType ;
            @AuraEnabled public String submittedDate ;
            @AuraEnabled public String status ;
            @AuraEnabled public String savedApplicationUrl ;
            @AuraEnabled public Boolean isSupportStaffCreated ;
            @AuraEnabled public String instanceId ;
            public ApplicationWrapper(String id,String name ,String type,String licenseType,
                                    String applicationType,String submittedDate,String status,
                                    String savedApplicationUrl,Boolean isSupportStaffCreated, String instanceId){
                this.id = id;
                this.name = name;
                this.type = type;
                this.licenseType = licenseType;
                this.applicationType = applicationType;
                this.submittedDate = submittedDate ; 
                this.status = status;
                this.savedApplicationUrl = savedApplicationUrl;
                this.isSupportStaffCreated = isSupportStaffCreated;
                this.instanceId = instanceId;
            }
            
        }
    }