/**
 * @author                      : Garvit Jain
 * @since                       : 03 Oct, 2022
 * @description                 :  This class is used to perform POST action on JetPay Portal, redirect to the thrid party, and also updating the tansection ID on  RegulatoryTrxnFee object.
 * @last modified by            : Ayush Dev
 * @last modified date          : 14th Feb 2023
 * @last modified details       : Code Review Fixes, Added DAO, Optimizing code and Sanitising input in soql query. 
 */
public with sharing class LPI_JetPayIntegrationController {

    private string PAYMENTID='';
    private string PAYMENT_METHOD='';
    private LPI_Payment_Configuration__mdt jetPayConfig;
    public String isPostActionDone { get; set;}
    private Static HttpResponse res;
    private String PENDING = 'Pending';
    private Map<String,String> paymentMethodMap = new Map<String,String>{ 'Credit'=>'2', 'Debit'=>'2'};
    /**
     * @author                      : Garvit Jain
     * @since                       : 03 Oct 2022
     * @description                 :  This Constructor is used to fetch the data from system and to create request data and to perporm POST action.
     * @param action 
     * @param args 
	 * @return                      : `Object`
     * @last modified by            : Ayush Dev
     * @last modified date          : 14 Feb 2023
     * @modified details            : Code Review Fixes
   */
    public PageReference redirectUser() {
        
        try {
            String parId = Apexpages.currentPage().getParameters().get('parId');
            String paymentMethod = Apexpages.currentPage().getParameters().get('paymentMethod');

            //Replace MetaData Query with > MetaData API class methods. to fetch metadata records.
            LPI_Payment_Configuration__mdt jetPayConfigRec = LPI_Payment_Configuration__mdt.getInstance(LPI_LiteralConstant.PAYMENT_CONFIG_DEVELOPERNAME);

            if (String.isBlank(parId) || jetPayConfigRec==null) {
                throw new AuraHandledException(LPI_LiteralConstant.REQ_PARAMS_MISSING_ERROR_TEXT);
            }
            jetPayConfig = jetPayConfigRec;
            String parQueryFields = 'Id, Regulatory_Authorization_Type__c, ApplicationType, Regulatory_Authorization_Type__r.IssuingDepartment.Payment_Type_Id__c, ';
            parQueryFields +=' BusinessAccountName.PersonEmail, BusinessAccountName.PersonHomePhone, BusinessAccountName.PersonOtherStreet, BusinessAccountName.PersonOtherCity, BusinessAccountName.PersonOtherCountryCode, BusinessAccountName.PersonOtherState, BusinessAccountName.Other_State__c, BusinessAccountName.PersonOtherPostalCode, BusinessAccountName.PersonOtherCountry, ';
            parQueryFields +='BusinessAccountNameId, BusinessAccountName.Name, BusinessAccountName.Buisness_Email__c, BusinessAccountName.Phone, BusinessAccountName.BillingStreet, BusinessAccountName.BillingCity, BusinessAccountName.BillingCountryCode, BusinessAccountName.BillingState, BusinessAccountName.BillingPostalCode, BusinessAccountName.BillingCountry, BusinessAccountName.RecordType.DeveloperName';
            String parWhereClause = 'Id = \''+String.escapeSingleQuotes(parId)+'\'';
            List <PreliminaryApplicationRef > parlist = LPI_PreliminaryApplicationRefDAO.getPreliminaryApplicationRefByDymanicQuery(parQueryFields, parWhereClause, null, null, null);

            if (parlist.isEmpty()) {
                throw new AuraHandledException(LPI_LiteralConstant.REQ_PARAMS_MISSING_ERROR_TEXT);
            }else {
                
                Decimal amount = 0;    
                List<String> regId;
                String paymentType = String.isNotEmpty(parlist[0].Regulatory_Authorization_Type__r.IssuingDepartment.Payment_Type_Id__c)?parlist[0].Regulatory_Authorization_Type__r.IssuingDepartment.Payment_Type_Id__c:'20';
                List<LineItemsWrappers> lineItemWrapList = new List <LineItemsWrappers>();
                String applicationTypeId = parlist[0].Id;
                Map<String,Object> billingWrapperBuilder = new Map<String,Object>();
                if(parlist[0].BusinessAccountNameId!=null){
                    if(parlist[0].BusinessAccountName.RecordType.DeveloperName == LPI_LiteralConstant.ACCOUNT_PERSON_RECORDTYPE){
                        String streetAddress= parlist[0].BusinessAccountName.PersonOtherStreet;
                        billingWrapperBuilder = new Map<String,Object>{
                            'BillingName'=> (parlist[0].BusinessAccountName.Name.length()>100 ? parlist[0].BusinessAccountName.Name.substring(0,100):parlist[0].BusinessAccountName.Name),
                            'Email'=> parlist[0].BusinessAccountName.PersonEmail,
                            'Phone'=> (String.isNotEmpty(parlist[0].BusinessAccountName.PersonHomePhone) && parlist[0].BusinessAccountName.PersonHomePhone.length()>10 ? parlist[0].BusinessAccountName.PersonHomePhone.substring(0,10):parlist[0].BusinessAccountName.PersonHomePhone),
                            'Address'=> String.isNotEmpty(streetAddress) ? (streetAddress.length()>100 ? streetAddress.substring(0,100):streetAddress):'',
                            'addressLine2'=> String.isNotEmpty(streetAddress) ? (streetAddress.length()>100 && streetAddress.length()<=200  ? streetAddress.substring(100,streetAddress.length()):(streetAddress.length()>200?streetAddress.substring(100,200):'')):'',
                            'City'=> parlist[0].BusinessAccountName.PersonOtherCity,
                            'State'=>  parlist[0].BusinessAccountName.PersonOtherCountryCode == 'US' ? parlist[0].BusinessAccountName.PersonOtherState : parlist[0].BusinessAccountName.Other_State__c,
                            'ZipCode'=>  parlist[0].BusinessAccountName.PersonOtherPostalCode,
                            'Country'=> parlist[0].BusinessAccountName.PersonOtherCountry
                        };
                    } else if(parlist[0].BusinessAccountName.RecordType.DeveloperName == LPI_LiteralConstant.ACCOUNT_BUSINESS_RECORDTYPE){
                        String streetAddress= parlist[0].BusinessAccountName.BillingStreet;
                        billingWrapperBuilder = new Map<String,Object>{
                            'BillingName'=> (parlist[0].BusinessAccountName.Name.length()>100 ? parlist[0].BusinessAccountName.Name.substring(0,100):parlist[0].BusinessAccountName.Name),
                            'Email'=> parlist[0].BusinessAccountName.Buisness_Email__c,
                            'Phone'=> (String.isNotEmpty(parlist[0].BusinessAccountName.Phone) && parlist[0].BusinessAccountName.Phone.length()>10 ? parlist[0].BusinessAccountName.Phone.substring(0,10):parlist[0].BusinessAccountName.Phone),
                            'Address'=> String.isNotEmpty(streetAddress) ? (streetAddress.length()>100 ? streetAddress.substring(0,100):streetAddress):'',
                            'addressLine2'=> String.isNotEmpty(streetAddress) ? (streetAddress.length()>100 && streetAddress.length()<=200  ? streetAddress.substring(100,streetAddress.length()):(streetAddress.length()>200?streetAddress.substring(100,200):'')):'',
                            'City'=> parlist[0].BusinessAccountName.BillingCity,
                            'State'=>  parlist[0].BusinessAccountName.BillingCountryCode == 'US' ? parlist[0].BusinessAccountName.BillingState : parlist[0].BusinessAccountName.Other_State__c,
                            'ZipCode'=>  parlist[0].BusinessAccountName.BillingPostalCode,
                            'Country'=> parlist[0].BusinessAccountName.BillingCountry
                        };
                    }
                }
                
                BillingWrapper bWrap = new BillingWrapper(billingWrapperBuilder);

                // Querying Temp Fee Item to clear old records
                String tempFeeItemQueryFields = 'Id,FeeAmount__c,Name, Temp_Fee__r.Payment_Method__c, Temp_Fee__r.Transaction_ID__c ';
                String tempFeeItemWhereClauseFields = 'Temp_Fee__r.PreliminaryApplicationReference__c =\''+String.escapeSingleQuotes(parId)+'\' AND FeeAmount__c !=0 AND Temp_Fee__r.Status__c=\''+PENDING+'\'';
                List<Temp_Fee_Item__c> feeItemList = new LPI_TempFeeItemDAO.LPI_TempFeeItemWithoutSharingDAO().getTempFeeItemListByDynamicQuery(tempFeeItemQueryFields,tempFeeItemWhereClauseFields,null,null,null);
                
                for(Temp_Fee_Item__c fee: feeItemList){
                    PAYMENTID = fee.Temp_Fee__r.Transaction_ID__c;
                    PAYMENT_METHOD=paymentMethodMap.containsKey(fee.Temp_Fee__r.Payment_Method__c)?paymentMethodMap.get(fee.Temp_Fee__r.Payment_Method__c):'';
                    regId = new List<String>{'RegistrationId: ' + generateRandomNumber(6)};
                        amount += fee.FeeAmount__c;
                    LineItemsWrappers lineItemWrap = new LineItemsWrappers( regId, fee.FeeAmount__c,fee.Name=='Processing Fee'?'202302':paymentType);
                    lineItemWrapList.add(lineItemWrap);
                }

                String returnURL = jetPayConfig.Return_URL__c + '?parId=' + String.escapeSingleQuotes(parId);                
                
                //String lpiURL = 'https://mtx-lpi-psf-core--lpicoredev.sandbox.my.site.com/apex/LPI_PaymentThankYouPage?parId='+String.escapeSingleQuotes(parId)+'&transid='+String.escapeSingleQuotes(regId[0].split(':')[1])+'&status=2';
                String lpiURL = 'https://lpi-psf-core--widpi.sandbox.my.site.com/apex/LPI_PaymentThankYouPage?parId='+String.escapeSingleQuotes(parId)+'&transid='+String.escapeSingleQuotes(regId[0].split(':')[1])+'&status=2';
                PageReference retURLP = new PageReference(lpiURL);
                retURLP.setRedirect(true);
                return retURLP;
            }
        } catch (Exception ex) {
            LPI_ExceptionManager.logException('LPI_JetPayIntegrationController', 'redirectUser', ex);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
            return null;
        }
    }

     /**
     * @author                      : Garvit Jain
     * @since                       : 03 Oct 2022
     * @description                 : This Method is used to generate a random number
    * @param length         
	 * @return                      : `String`
     * @last modified by            : Ayush Dev
     * @last modified date          : 14 Feb 2023
     * @modified details            : Code Review Fixes
   */
    public static String generateRandomNumber(Integer length) {
        String result = '';
        while(result.length() < length){
            Blob privateKey = crypto.generateAesKey(256);
            String randomString = EncodingUtil.base64Encode(crypto.generateMac(LPI_LiteralConstant.SHA_HASHING_ALGO,privateKey,privateKey));
            result += randomString.replaceAll('[^a-zA-Z0-9]','');
        }
        result = result.substring(0,length);
        return result;
    }

    /**
     * @author                      : Garvit Jain
     * @since                       : 03 Oct 2022
     * @description                 : This Method is used to return EndPoint URL.
    * @param length         
	 * @return                      : `String`
     * @last modified by            : Ayush Dev
     * @last modified date          : 14 Feb 2023
     * @modified details            : Code Review Fixes
   */
    // public String getEndpoint() {
    //     return jetPayConfig.VTURL__c+jetPayConfig.ClientId__c+'/'+paymentId;
    // }

 
    /**
     * @author                      : Garvit Jain
     * @since                       : 03 Oct 2022
     * @description                 : This Method is used to perform the POST callout on JetPay Portal.
     * @param endPoint                       
     * @param body              
	 * @return                      : `Void`
     * @last modified by            : Ayush Dev
     * @last modified date          : 14 Feb 2023
     * @modified details            : Code Review Fixes
   */
    // public static void postPaymentData(String endPoint, String body){
    //     Http http = new Http();
    //     HttpRequest req = new HttpRequest(); 
    //     req.setEndpoint(endPoint+'/transaction/redirect');
    //     req.setMethod('POST');
    //     req.setHeader('Content-Type', LPI_LiteralConstant.HEADER_CONTENT_TYPE);
    //     req.setBody(body); 
        
    //     try {  
    //         req.setTimeout(30000);
    //         res =  http.send(req);
    //     } catch(System.CalloutException e) {  
    //         LPI_ExceptionManager.logException('LPI_JetPayIntegrationController', 'postPaymentData', e);
    //     } 
    // }

    /**
     * @author                      : Garvit Jain
     * @since                       : 03 Oct 2022
     * @description                 : Below Wrapper classes are used to generate Request Data which is about to use in POST action.
     * @last modified by            : Ayush Dev
     * @last modified date          : 14 Feb 2023
     * @modified details            : Code Review Fixes
   */
    // public class HTTPBodyWrapper {
        
    //     public String clientKey;
    //     public String transactionIdentifier;
    //     public Decimal collectionMode;
    //     public Decimal amount;
    //     public BillingWrapper billing;
    //     public Decimal csiUserId;
    //     public String notes;
    //     public List<LineItemsWrappers> lineItems;
    //     public String urlSilentPost;
    //     public String urlReturnPost;
    //     public String allowedPaymentMethod;
        
    //     // this constructor is used to build HTTP Body for sending out a callout. Using Map to update fields dynamically, to prevent constructor explosion.  -- vamsi
    //     public HTTPBodyWrapper(Map<String,Object> builder) {
    //         clientKey = (String)builder.get('clientKey');
    //         transactionIdentifier = (String)builder.get('transactionIdentifier');
    //         collectionMode = (Decimal) builder.get('collectionMode');
    //         amount = (Decimal) builder.get('feeAmount');
    //         billing = (BillingWrapper) builder.get('billingInfo');
    //         csiUserId = (Decimal)builder.get('csiUserId') ;
    //         notes = (String)builder.get('notes');
    //         lineItems = (List<LineItemsWrappers>)builder.get('lineItems');
    //         urlSilentPost = (String)builder.get('silentUrlPost');
    //         urlReturnPost = (String)builder.get('returnUrlPost');
    //         allowedPaymentMethod = (String) builder.get('allowedPaymentMethod');
    //     }

    // }
    

    /**
     * @author                      : Garvit Jain
     * @since                       : 03 Oct 2022
     * @description                 : Below Wrapper is used to store billing address information.
     * @last modified by            : Ayush Dev
     * @last modified date          : 14 Feb 2023
     * @modified details            : Code Review Fixes
   */
    public class BillingWrapper{
        public String name;
        public String address;
        public String city;
        public String state;
        public String zip;
        public String country;
        public String email;
        public String phone;
        // this constructor is used to build Billing Wrapper Object. Using Map to update fields dynamically, to prevent constructor explosion.  -- vamsi
        public BillingWrapper(Map<String,Object> builder){
            name = (String) builder.get('BillingName');
            address = (String) builder.get('Address');
            city = (String) builder.get('City');
            state = (String) builder.get('State');
            zip = (String) builder.get('ZipCode');
            country = (String) builder.get('Country');
            email = (String) builder.get('Email');
            phone = (String) builder.get('Phone');
        }
    }
     /**
     * @author                      : Garvit Jain
     * @since                       : 03 Oct 2022
     * @description                 : Below Wrapper is used to store LineItem Information.
     * @last modified by            : Ayush Dev
     * @last modified date          : 14 Feb 2023
     * @modified details            : Code Review Fixes
   */
    public class LineItemsWrappers{
        public List<String> identifiers;
        public Decimal amount;
        public String paymentType;
        public LineItemsWrappers(List<String> identifiers1, Decimal amount1, String paymentType1){
            identifiers= identifiers1;
            amount= amount1;
            paymentType= paymentType1;  
        }
    }
    
}