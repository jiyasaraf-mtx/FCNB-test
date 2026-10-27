/**
 * @author                      : MTX Group Product Team
 * @since                       : 24-May-2024
 * @description                 : Class for integration code of ESRI ( Address Validation )
 */
public with sharing class LPI_AddressValidationIntegration {
     
    /**
    * @author                      : MTX Group Product Team
    * @since                       : 24-May-2024
    * @description                 : Data services callout
    */
    public static AddressValidationResultWrapper checkAddressValidation(String regionCode, String locality, String singleAddressLine){
        try{
            AddressValidationResultWrapper resultWrapper = new AddressValidationResultWrapper();

            if(locality == 'APO' || locality == 'FPO' || locality == 'Army Post Office' || locality == 'Fleet Post Office' || regionCode != 'US'){
                resultWrapper.skipValidation = true;
                return resultWrapper;
            }

            List<LPI_Integration_Config__mdt> esriApiDeatilsList = 
                new LPI_CustomMetadataTypeDAO.LPI_CustomMetadataTypeWithoutSharingDAO().getCustomMetaByDymQueryWithoutSec(
                'Id, API_Name__c, Auth_End_Point__c, Client_Id__c, Private_Key__c, Grant_String__c, Data_End_Point__c',
                'LPI_Integration_Config__mdt',
                'API_Name__c = \''+'ESRI_Address_Validation'+ '\'', null, null, null
            );
            
            if(!esriApiDeatilsList.isEmpty()){
                
                String token = getAccessToken(esriApiDeatilsList);
                if(token != 'error'){
                    String body = 'SingleLine=' + EncodingUtil.urlEncode(singleAddressLine, 'UTF-8')  + 
                    '&f=' + EncodingUtil.urlEncode('pjson', 'UTF-8') + 
                    '&outFields=' + EncodingUtil.urlEncode('*', 'UTF-8');
                    
                    Http http = new Http();
                    HttpRequest httpReq = new  HttpRequest();
                    
                    httpReq.setEndpoint(esriApiDeatilsList[0].Data_End_Point__c + '?' + body);
                    httpReq.setMethod('POST');
                    httpReq.setHeader('Content-Type', esriApiDeatilsList[0].Data_End_Point__c);
                    httpReq.setHeader('Authorization', 'Bearer ' + token );
                    httpReq.setBody( body );

                    HttpResponse httpRes = http.send( httpReq );
                    
                    if (httpRes.getStatusCode() != 200) {
                        resultWrapper.validationAPIError = true;
                        resultWrapper.errorMessage = 'Data service failed!!';
                        return resultWrapper;
                    }

                    String resultJSON = httpRes.getBody();

                    if(resultJSON.contains('Unsupported region code:')){
                        resultWrapper.skipValidation = true;
                        return resultWrapper;
                    }

                    LPI_AddressValidationWrapper addressResult = (LPI_AddressValidationWrapper)JSON.deserialize(resultJSON, LPI_AddressValidationWrapper.class);
                    for(LPI_AddressValidationWrapper.cls_candidates candidate  : addressResult.candidates){
                        if( candidate.address != NULL && candidate.score > 90 && candidate.attributes != null && candidate.attributes.Addr_type == 'PointAddress'){
                            resultWrapper.latitude = candidate.location.x;
                            resultWrapper.longitude = candidate.location.y;
                            resultWrapper.addressValid = true ;
                            break;
                        }
                    }
                }else{
                    resultWrapper.validationAPIError = true;
                    resultWrapper.errorMessage = 'Authentication Failed!!';
                    return resultWrapper;
                }
            }
            
            return resultWrapper;

        }catch(Exception ex) {
            LPI_ExceptionManager.logException('LPI_AddressValidationIntegration', 'checkAddressValidation', ex);
        }
        return null;
        
    }
    
    /**
    * @author                      : MTX Group Product Team
    * @since                       : 24-May-2024
    * @description                 : Auth Token Generation
    */
    public static String getAccessToken(List<LPI_Integration_Config__mdt> esriApiDeatilsList) {

        if(!esriApiDeatilsList.isEmpty()){
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(esriApiDeatilsList[0].Auth_End_Point__c);
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            request.setBody('grant_type=client_credentials&client_id=' + esriApiDeatilsList[0].Client_Id__c + '&client_secret=' + esriApiDeatilsList[0].Private_Key__c);
            
            HttpResponse response = http.send(request);
            if (response.getStatusCode() == 200) {
                Map<String, Object> jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                return (String) jsonResponse.get('access_token');
            } else {
                return 'error';
            }
        }
        return 'error';
    }

    /**
    * @author                      : MTX Group Product Team
    * @since                       : 24-May-2024
    * @description                 : Wrapper class for returning the data after callout
    */
    public class AddressValidationResultWrapper{
        public Double latitude;
        public Double longitude;
        public boolean addressValid;
        public boolean skipValidation;
        
        /*Use these parameters 
         * if API gives error ( Example : Authentication Failed )
         * */
        public boolean validationAPIError;
        public String errorMessage;
        
        /**
        * @author                      : MTX Group Product Team
        * @since                       : 24-May-2024
        * @description                 : Default constructor for avoiding null pointers and setting default values
        */
        public AddressValidationResultWrapper(){
            this.latitude = null;
            this.longitude = null;
            this.addressValid = false;
            this.skipValidation = false;
            this.validationAPIError = false;
            this.errorMessage = '';
        }
    }
}