@RestResource(urlMapping='/keys/*')
global with sharing class LPI_MobileKeyRestResource {
    public LPI_MobileKeyRestResource() {
    }
  
    @HttpGet
    global static void doGet() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        try {
            Mobile_App_Key_Value__mdt metaData = [SELECT iv__c, key__c from Mobile_App_Key_Value__mdt LIMIT 1];
            Map<String, String> response = new Map<String, String>();
            response.put('key', metaData.key__c);
            response.put('iv', metaData.iv__c);
            if(response != null) {
                res.statusCode = 200;
                res.responseBody = Blob.valueOf(JSON.serialize(response));
            } else {
                res.statusCode = 400;
                res.responseBody = Blob.valueOf('user does not exist.');
            }
        } catch (Exception e){
        }
    }
  
}