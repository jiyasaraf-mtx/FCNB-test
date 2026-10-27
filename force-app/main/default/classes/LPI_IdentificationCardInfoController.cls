/**
 * @author                      : Sudhanshu Jain
 * @since                       :
 * @description                 : Identification Card View Page Controller
 * @last modified by            : 
 * @last modified date          : 
 * @modified details            : 
 */
public with sharing class LPI_IdentificationCardInfoController {
    private static final String TYPE_MMA = 'MMA';
    private static final String TYPE_BOXING = 'Boxing';
    private static final String SUB_TYPE_MMA = 'MMA National ID Card';
    private static final String SUB_TYPE_BOXING = 'Boxer\'s Federal ID Card';
    private static final String MMA_NIC = 'MMA National Identification Card';
    private static final String BOXER_FIC = 'Boxer\'s Federal Identification Card';
    private static final Set<String> REG_AUTH_NAME_SET =  new Set<String> {
                    'MMA National Identification Card', 
                    'Boxer\'s Federal Identification Card' 
                };


    /**
     * @author                      : Sudhanshu Jain
     * @since                       :
     * @description                 : fetch Appication Data
     * @return                      : DataWrapper
     * @last modified by            : 
     * @last modified date          :
     * @modified details            :
     */
    @AuraEnabled(cacheable=true)
    public static List<IdentificationTableDataWrapper> fetchIdentificationCardInfo(Id icId, Boolean isPortalUser){
        String accId = null;
        List<IdentificationTableDataWrapper> identificationTableDataWrapperList= new List<IdentificationTableDataWrapper>();
        if(isPortalUser){
            accId = getAccountIdSelectedByPortalUser();
        }
        if((isPortalUser && String.isNotBlank(accId)) || String.isNotBlank(icId)){
            Map<String,Map<String,String>> ratNameWithOpenRenewalMonthMap = new Map<String,Map<String,String>>();
            Map<String,String> typewithRatNameMap = new Map<String,String>();
            for(RegulatoryAuthorizationType rat: LPI_RegulatoryAuthorizationTypeDAO.getRegulatoryAuthorizationTypeByDymanicQuery(
                'Id, Name, ID_Card_Open_for_Renewal__c',
                'ID_Card_Open_for_Renewal__c != NULL AND Name IN ' + 
                LPI_ServiceUtility.getStringValuesByList(new List<String>(REG_AUTH_NAME_SET)),
                null,
                null,
                null)){
                    Map<String,String> ratPropWithValueMap = new Map<String,String>();
                    ratPropWithValueMap.put('OpenForRenewal', String.valueOf(rat.ID_Card_Open_for_Renewal__c));
                    ratPropWithValueMap.put('RatId',rat.Id );
                    ratNameWithOpenRenewalMonthMap.put(rat.Name, ratPropWithValueMap);
            }
            typewithRatNameMap.put(TYPE_MMA,MMA_NIC);
            typewithRatNameMap.put(TYPE_BOXING,BOXER_FIC);
            LPI_IdentificationCardDAO.LPI_IdentificationCardWithoutSharingDAO icDao = new LPI_IdentificationCardDAO.LPI_IdentificationCardWithoutSharingDAO();
            String queryFields = 'Id,Contestant_Name__c,Contestant_Name__r.Name,Issued_Date__c,ID_Issuing_Commission__c,'+
                                 'Expiry_Date__c,ID_Type__c, Federal_ID_Number__c,National_ID_Number__c, Status__c ';
            String queryWhere =  isPortalUser ? 'Contestant_Name__c = \''+ String.escapeSingleQuotes(accId) +'\'' : 
                                                'Id = \''+ String.escapeSingleQuotes(icId) +'\'';  
            
            for(Identification_Card__c idCard : icDao.getIdentificationCardByDymanicQuery(
                queryFields, queryWhere, null, null, null)){
                    List<MenuItemWrapper> menuItemWrapperList =  new List<MenuItemWrapper>();
                    IdentificationTableDataWrapper icTableWrapper = new IdentificationTableDataWrapper();
                    MenuItemWrapper viewAction = new MenuItemWrapper('View','View');
                    menuItemWrapperList.add(viewAction);
                    icTableWrapper.type = idCard.ID_Type__c;
                    icTableWrapper.icId = idCard.Id;
                    icTableWrapper.applicationType = 'Renewal';
                    if(isPortalUser){
                        icTableWrapper.contestantName = idCard.Contestant_Name__r.Name;
                        icTableWrapper.issuingCommission = String.isNotBlank(idCard.ID_Issuing_Commission__c) ? idCard.ID_Issuing_Commission__c : '-';
                        icTableWrapper.expiryDate = idCard.Expiry_Date__c != null ? 
                        LPI_ApplicationViewController.convertDateFormat(String.valueOf(idCard.Expiry_Date__c.format())) :
                                            '-';
                        icTableWrapper.issuanceDate = idCard.Issued_Date__c != null ? 
                        LPI_ApplicationViewController.convertDateFormat(String.valueOf(idCard.Issued_Date__c.format())) : 
                                            '-';
                    }else{
                        icTableWrapper.accountId = idCard.Contestant_Name__c;
                    }
                    if(idCard.ID_Type__c == TYPE_MMA){
                        icTableWrapper.cardNumber = String.isNotBlank(idCard.National_ID_Number__c) ? idCard.National_ID_Number__c : '-';
                        icTableWrapper.applicationSubType = SUB_TYPE_MMA;
                        icTableWrapper.regAuthTypeName = MMA_NIC;
                    }else if(idCard.ID_Type__c == TYPE_BOXING){
                        icTableWrapper.cardNumber = String.isNotBlank(idCard.Federal_ID_Number__c) ? idCard.Federal_ID_Number__c : '-';
                        icTableWrapper.applicationSubType = SUB_TYPE_BOXING;
                        icTableWrapper.regAuthTypeName = BOXER_FIC;
                    }else{
                        icTableWrapper.cardNumber = '-';
                        icTableWrapper.applicationSubType = null;
                    }

                    if(idCard.Expiry_Date__c != null && String.isNotBlank(idCard.ID_Type__c) &&
                        typewithRatNameMap.containsKey(idCard.ID_Type__c)){
                        String ratName = typewithRatNameMap.get(idCard.ID_Type__c);
                        if(ratNameWithOpenRenewalMonthMap.containsKey(ratName)){
                            Date expiryDate = idCard.Expiry_Date__c.addMonths(
                                -Integer.valueOf(ratNameWithOpenRenewalMonthMap.get(ratName)?.get('OpenForRenewal'))
                            );
                            icTableWrapper.regAuthId = ratNameWithOpenRenewalMonthMap.get(ratName)?.get('RatId');
                            if(expiryDate <= System.today() && idCard.Expiry_Date__c >= System.today()){
                                icTableWrapper.isRenewalAllowed = true;
                                MenuItemWrapper renewAction = new MenuItemWrapper('Renew','Renew');
                                menuItemWrapperList.add(renewAction);
                            }else{
                                icTableWrapper.isRenewalAllowed = false;
                            }            
                        }
                    }
                    if(isPortalUser){
                        icTableWrapper.menuItems = menuItemWrapperList;
                    }
                    identificationTableDataWrapperList.add(icTableWrapper);
            }
        }
        return identificationTableDataWrapperList;
    }

    /**
     * @author                      : Sudhanshu Jain
     * @since                       :
     * @description                 : get account Id which is selected by the portal user.
     * @last modified by            : 
     * @last modified date          :
     * @modified details            :
     */
    private static String getAccountIdSelectedByPortalUser() {
        String userId = UserInfo.getUserId();
        User u  =  LPI_WithoutSharingUtility.getUserRecordDetailWithoutSharing(userId);
        String accwhereClause='Id = \''+ String.escapeSingleQuotes(u.AccountId)+'\'';
        List<Account> accData =  LPI_AccountDAO.getAccountListByDynamicQuery(new List<String>{'Id','SelectedAccountId__c'},accwhereClause,null,null,null);
        //Fetch Selected Account Id
        String selectedAccoutnId = (!accData.isEmpty() && String.isNotBlank(accData[0].SelectedAccountId__c)?accData[0].SelectedAccountId__c:u.AccountId);
        return selectedAccoutnId;
    }

    /**
     * @author                      : Sudhanshu Jain
     * @since                       :
     * @description                 : Main Wrapper class used to display Identification Card Table
     * @last modified by            : 
     * @last modified date          :
     * @modified details            :
     */
    public class IdentificationTableDataWrapper {
        @AuraEnabled public String icId;
        @AuraEnabled public String cardNumber;
        @AuraEnabled public String contestantName;
        @AuraEnabled public String issuingCommission;
        @AuraEnabled public String type;
        @AuraEnabled public String issuanceDate;
        @AuraEnabled public String expiryDate;
        @AuraEnabled public String regAuthId;
        @AuraEnabled public String applicationType;
        @AuraEnabled public String applicationSubType;
        @AuraEnabled public List<MenuItemWrapper> menuItems;
        @AuraEnabled public Boolean isRenewalAllowed;
        @AuraEnabled public String accountId;
        @AuraEnabled public String regAuthTypeName;
    }

    /**
     * @author                      : Sudhanshu Jain
     * @since                       :
     * @description                 : Main Wrapper class used to display Identification Card Table
     * @last modified by            : 
     * @last modified date          :
     * @modified details            :
     */
    public class MenuItemWrapper {
        @AuraEnabled public String label;
        @AuraEnabled public String value;

        MenuItemWrapper(String label, String value){
            this.label = label;
            this.value = value;
        }
    }
}