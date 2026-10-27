/**
* @author                      : MTX Group Product Team
* @since                       : 03 Oct, 2022
* @description                 : This Class is used to get the data from payment portal, redirect user to success page to update the response data on RegulatoryTrxnFee object.
* @last modified by            : MTX Group Product Team
* @last modified date          : 14th Feb 2023
* @last modified details       : Code Review Fixes, Added DAO, Optimizing code and Sanitising input in soql query. 
*/
public with sharing class LPI_JetPayThankYouController {
    private Static HttpResponse res;
    private String responseStatus;
    private String parId;
    private List<Temp_Fee__c> tempFeeData = new List<Temp_Fee__c>();
    private String statusSubmited = LPI_LiteralConstant.IA_SUBMITTED_STATUS;
    private String statusPending=LPI_LiteralConstant.IA_PAYMENT_PENDING_STATUS;
    private Map<String,String> responseMap = new Map<String,String>{ '0'=>'Declined', '2'=>'Paid'};
    /**
    * @author                      : MTX Group Product Team
    * @since                       : 03 Oct 2022
    * @description                 : This constructor is used to post GET action to fetch response.
    * @return                      : ``
    * @last modified by            : MTX Group Product Team
    * @last modified date          : 14 Feb 2023
    * @modified details            : Code Review Fixes
    */
    public LPI_JetPayThankYouController() {
        
        try {
            parId = Apexpages.currentPage().getParameters().get('parId');
            String tempFeeQueryFields = 'Id, Status__c, Transaction_ID__c,Billing_Information__c,Transaction_Fee_Amount__c,Transaction_Date__c, PreliminaryApplicationReference__c';
            String tempFeeWhereClauseFields = 'PreliminaryApplicationReference__c =\''+String.escapeSingleQuotes(parId)+'\' AND Status__c = \'Pending\'';
            tempFeeData = LPI_TempFeeDAO.getTempFeeListByDynamicQuery(tempFeeQueryFields,tempFeeWhereClauseFields,null,null,null);
            if(!tempFeeData.isEmpty()){    
                LPI_Payment_Configuration__mdt jetPayConfigList =  LPI_Payment_Configuration__mdt.getInstance(LPI_LiteralConstant.PAYMENT_CONFIG_DEVELOPERNAME);
                //Generating URL to make to the GET callout.
                String getURL = jetPayConfigList.URL__c + '/transaction/redirect/' +jetPayConfigList.ClientKey__c+'/'+String.escapeSingleQuotes(tempFeeData[0].Transaction_ID__c);
                
                //Instantiate a new http object
                Http http = new Http();
                
                // Instantiate a new HTTP request, specify the method (GET) as well as the endpoint
                HttpRequest req = new HttpRequest();
                req.setEndpoint(getURL);
                req.setMethod('GET');
                // Send the request, and return a response
                res =  http.send(req);
            }
        } catch (Exception ex) {
            LPI_ExceptionManager.logException('LPI_JetPayThankYouController', 'LPI_JetPayThankYouController', ex);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
        }
    }
    
    /**
    * @author                      : MTX Group Product Team
    * @since                       : 03 Oct 2022
    * @description                 :  This method is used to redirect user to the success page and with that also updating the response data on RegulatoryTrxnFee object.
    * @return                      : `PageReference`
    * @last modified by            : MTX Group Product Team
    * @last modified date          : 14 Feb 2023
    * @modified details            : Code Review Fixes
    */
    public PageReference validateAndRedirect() {
        try {  
            Map<String, Object> resultsMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            responseStatus = LPI_LiteralConstant.FEE_PAID_STATUS;
            String siteQueryFields = 'Id';
            String siteWhereClause = 'Name = \''+LPI_LiteralConstant.COMMUNITY_NAME+'\'';
            List<Site> siteList = LPI_SiteDAO.getSiteByDymanicQuery(siteQueryFields, siteWhereClause, null, null, null);
            
            String siteDetailQueryField ='SecureURL';
            String siteDetailWhereClause = 'DurableId =\''+String.escapeSingleQuotes(siteList[0].Id)+'\'';
            List<SiteDetail> siteDetailList = LPI_SiteDetailDAO.getSiteDetailByDymanicQuery(siteDetailQueryField,siteDetailWhereClause,null,null,null);
            String communityUrl = siteDetailList[0]?.SecureUrl;
            
            List<Temp_Fee__c> tfToBeUpdated = new List<Temp_Fee__c>();
            String applicationId = null;
            
            for(Temp_Fee__c tfData : tempFeeData){
                if(responseStatus==LPI_LiteralConstant.FEE_PAID_STATUS) {
                    tfData.Billing_Information__c = Json.serialize(resultsMap.get('billing'));
                    tfData.Transaction_Fee_Amount__c = (Decimal) resultsMap.get('feeAmount');
                    tfData.Transaction_Date__c=System.now();
                    tfData.Status__c = LPI_LiteralConstant.FEE_PAID_STATUS;
                } else {
                    tfData.Status__c = responseStatus;
                }
                tfToBeUpdated.add(tfData);
            }
            
            if(!tfToBeUpdated.isEmpty()){
                LPI_WithoutSharingUtility.updateSObjectList(tfToBeUpdated);
            }
            String retURL = '';
            
            if(String.isNotEmpty(String.escapeSingleQuotes(parId)) && responseStatus==LPI_LiteralConstant.FEE_PAID_STATUS) 
            {                
                PreliminaryApplicationRef parRec = new PreliminaryApplicationRef(Id=String.escapeSingleQuotes(parId), Status__c= LPI_LiteralConstant.PAR_CONVERTED_STATUS, IsSubmitted=true);
                // updating PAR in with sharing Context.
                LPI_WithoutSharingUtility.updateSObjectList(new List<PreliminaryApplicationRef>{parRec});
                List<IndividualApplication> iaList= new LPI_IndividualApplicationDAO.LPI_DAO_IndividualApptWithoutSecurity().getILABySavedAppRefId(new Set<Id>{parId}); 
                List<BusinessLicenseApplication> blaList= LPI_BusinessLicenseApplicationDAO.getBLABySavedAppRefId(new Set<Id>{parId});
                if(blaList.size()>0){
                    retURL = 's/success-page?blaId='+blaList[0].Id+'&status='+responseStatus+'&indAppId=null&parId=null';
                } else if(iaList.size()>0){
                    retURL = 's/success-page?indAppId='+iaList[0].Id+'&status='+responseStatus+'&blaId=null&parId=null';
                } else {
                    retURL ='s/success-page?parId='+String.escapeSingleQuotes(parId)+'&status='+responseStatus+'&indAppId=null&blaId=null';
                }   
            }else {
                retURL ='s/success-page?parId='+String.escapeSingleQuotes(parId)+'&status='+responseStatus+'&indAppId=null&blaId=null';
            }

            PageReference retURLP = new PageReference(communityUrl+retURL);
            retURLP.setRedirect(true);
            return retURLP;
        } catch(Exception ex) { 
            LPI_ExceptionManager.logException('LPI_JetPayThankYouController', 'validateAndRedirect', ex);
        } 
        return null;
    }
}