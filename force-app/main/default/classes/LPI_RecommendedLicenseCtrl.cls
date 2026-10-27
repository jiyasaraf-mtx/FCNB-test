/**
 * @description       : LPI RecommendedLicenseCtrl
 * @author            : MTX Group Product Team
 * @group             :
 * @last modified on  : 07-26-2024
 * @last modified by  : MTX Group Product Team
 **/
public with sharing class LPI_RecommendedLicenseCtrl {
    /**
     * @author                         : MTX Group Product Team
     * @since                          :
     * @description                    : This method is used for fetch all licenses from org
     * @last modified by               : MTX Group Product Team
     * @last modified date             : 
     * @last modified details          : 
     */
    @AuraEnabled
    public static Map<String,Object> fetchBoardsDetails(){
        try {
            List<User> u = LPI_UserDao.getCurrentUserRecord();
            boolean showOnlyBusiness = false;
            if(u.size() > 0) {
                List<Account> accList = LPI_AccountDAO.getAccountListByDynamicQuery(new List<String>{'Id','Person_Account_For_Business__c'},
                'Id = \''+u[0].AccountId+'\'',1,null,null);
                if(!accList.isEmpty()){
                    showOnlyBusiness = accList[0].Person_Account_For_Business__c;
                }
            }
            String queryFields = ' Id, Name,IssuingDepartmentId,IssuingDepartment.Name,Authorisation_Type__c ';
            String whereClause =' New_Application_Allowed__c = true AND Not_for_Portal_User__c = false AND IssuingDepartmentId != null';
            Map<String,List<DataWrapper>> boardWithRegAuthMap = new Map<String,List<DataWrapper>>();
            Map<String,List<DataWrapper>> typeWithRegAuthMap = new Map<String,List<DataWrapper>>();
            DataWrapper dW;
            for(RegulatoryAuthorizationType regAuth : LPI_RegulatoryAuthorizationTypeDAO.getRegulatoryAuthorizationTypeByDymanicQuery(
                queryFields,whereClause,null,'Name','asc')) {
                    if(!typeWithRegAuthMap.containsKey(regAuth.Authorisation_Type__c)){
                        typeWithRegAuthMap.put(regAuth.Authorisation_Type__c,new List<DataWrapper>());
                    }
                    if(!boardWithRegAuthMap.containsKey(regAuth.IssuingDepartment.Name)){
                        boardWithRegAuthMap.put(regAuth.IssuingDepartment.Name,new List<DataWrapper>());
                    }
                    dW = new DataWrapper(regAuth.Id,regAuth.Name,
                    regAuth.IssuingDepartmentId != null ? regAuth.IssuingDepartment.Name : '',
                    null);
                    typeWithRegAuthMap.get(regAuth.Authorisation_Type__c).add(dW);
                    boardWithRegAuthMap.get(regAuth.IssuingDepartment.Name).add(dW);
            }
            return new Map<String,Object>{
                'boardList' => boardWithRegAuthMap.keySet(),
                'boardWithRegAuth' => boardWithRegAuthMap,
                'typeWithRegAuthMap' => typeWithRegAuthMap,
                'showOnlyBusiness' => showOnlyBusiness
            };
        } catch (Exception e) {
            LPI_ExceptionManager.logException('LPI_RecommendedLicenseCtrl', 'fetchBoardsDetails', e);
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * @author                         :MTX Group Product Team
     * @since                          :
     * @description                    : This method is used for to fetch blId fro rn/ lpn license only for reinstatement case.
     * @last modified by               : MTX Group Product Team
     * @last modified date             : 
     * @last modified details          : 
     */
    @AuraEnabled
    public static Map<String, String> fetchBusinessLicenseId(Map<String, Object> inputMap){
        Map<String, String> dataValueMap = new Map<String, String>();
        try{
            String regAuthId = (String) inputMap.get('regAuthId');
            Set<String> ratSetName = new Set<String>{'Registered Nurse','Licensed Practical Nurse'};
            String whereClause;
            String accountId;
            if(String.isNotBlank(regAuthId)){
                whereClause = 'Id =\'' + regAuthId + '\'';
                List<RegulatoryAuthorizationType> regAuthList = LPI_RegulatoryAuthorizationTypeDAO.getRegulatoryAuthorizationTypeByDymanicQuery(
                        'Name',
                        whereClause,
                        '1',
                        null,
                        null
                    );
                if(!regAuthList.isEmpty() && ratSetName.contains(regAuthList[0].Name)){
                    List<User> u = LPI_UserDao.getCurrentUserRecord();
                    if (u.size()> 0) {
                        accountId = u[0].AccountId;
                        if(String.isNotBlank(accountId)){
                            Set<String> statusSet = new Set<String>{'Expired','Inactive'};
                            whereClause =' RegulatoryAuthorizationTypeId = \'' + regAuthId + '\''+
                            ' AND Contact.AccountId  = \'' + accountId + '\'';
                            List<Businesslicense> businessLicenseList  = new LPI_BusinessLicenseDAO.LPI_BusinessLicenseWithoutSharingDAO()
                                .getBusinessLicenseByDymanicQuery('Id,Status', whereClause, '1', 'CreatedDate', 'desc');
                            if(!businessLicenseList.isEmpty()){
                                if(statusSet.contains(businessLicenseList[0].Status)){
                                    String blStatus = businessLicenseList[0].Status;
                                    if(blStatus == 'Inactive'){
                                        dataValueMap.put('amendmentType', 'Inactivation');
                                    }else if(blStatus == 'Expired'){
                                        dataValueMap.put('amendmentType', 'Reinstatement');
                                    }
                                    dataValueMap.put('type','Reinstatement');
                                    dataValueMap.put('blId', String.valueOf(businessLicenseList[0].Id));
                                }else if(businessLicenseList[0].Status == 'Revoked'){
                                    dataValueMap.put('revokedLicenseId', businessLicenseList[0].Id);
                                    dataValueMap.put('amendmentType', 'Examination');
                                    dataValueMap.put('type','New');
                                }
                            }
                        }
                    }
                }
            }
        } catch (Exception e) {
            LPI_ExceptionManager.logException('LPI_RecommendedLicenseCtrl', 'fetchBusinessLicenseId', e);
        }
        return dataValueMap;
    }


    /**
     * @author                         : MTX Group Product Team
     * @since                          :
     * @description                    : This method is used for create Application
     * @last modified by               : MTX Group Product Team
     * @last modified date             : 
     * @last modified details          : 
     */
    @AuraEnabled
    public static string createApplication(Map<String, Object> inputMap){
        try {
            Boolean isActionAllowed =  LPI_ApplicationFlowUtility.setActionAllowedValidation(inputMap);
            if(isActionAllowed){
                Map<String,Object> resultMap = LPI_ApplicationFlowUtility.createPARRecord(inputMap,null);
                if(resultMap != null){
                    return resultMap.containsKey('parRec') ? ((PreliminaryApplicationRef)resultMap.get('parRec')).SavedApplicationUrl : 'Error';
                }else{
                    return 'Error';
                }
            }else{
                return 'Duplicate';
            }
        } catch (Exception e) {
            LPI_ExceptionManager.logException('LPI_RecommendedLicenseCtrl', 'createApplication', e);
            throw new AuraHandledException(e.getMessage());
        }
    }

    public class DataWrapper{
        @AuraEnabled public String id;
        @AuraEnabled public String name;
        @AuraEnabled public String issuingDepartmentName;
        @AuraEnabled public String ariaLabelLicense;
        @AuraEnabled public boolean showKnowMore;
        @AuraEnabled public String knowMoreClassName;
        @AuraEnabled public String knowMoreIconName;
        @AuraEnabled public String knowMoreAriaLabel;
        @AuraEnabled public boolean knowMoreIsOpen;
        @AuraEnabled public String howToApply;

        public DataWrapper(String id,String name,String issuingDepartmentName,String howToApply){
            this.id = id;
            this.name = name;
            this.issuingDepartmentName = issuingDepartmentName;
            this.showKnowMore = String.isNotBlank(howToApply) ? true : false;
            this.knowMoreClassName = 'slds-section slds-is-close';
            this.knowMoreIconName = 'utility:chevronright';
            this.knowMoreIsOpen = false;
            this.howToApply = howToApply;
            this.ariaLabelLicense = 'Apply Online '+ name;
            this.knowMoreAriaLabel = 'Know more about '+ name;
        }
    }
}