public with sharing class ClinicalTrialsController {
    
    @AuraEnabled
    public static String searchTrials(String condition, String status) {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        
        // Base v2 endpoint requesting up to 50 results
        String endpoint = 'https://clinicaltrials.gov/api/v2/studies?pageSize=50';
        
        // Append parameters if provided by the user
        if (String.isNotBlank(condition)) {
            endpoint += '&query.cond=' + EncodingUtil.urlEncode(condition, 'UTF-8');
        }
        if (String.isNotBlank(status)) {
            endpoint += '&filter.overallStatus=' + EncodingUtil.urlEncode(status, 'UTF-8');
        }
        
        request.setEndpoint(endpoint);
        request.setMethod('GET');
        request.setHeader('Accept', 'application/json');
        
        try {
            HttpResponse response = http.send(request);
            if (response.getStatusCode() == 200) {
                return response.getBody();
            } else {
                throw new AuraHandledException('Failed to fetch data: ' + response.getStatusCode() + ' ' + response.getStatus());
            }
        } catch (Exception e) {
            throw new AuraHandledException('Error calling ClinicalTrials API: ' + e.getMessage());
        }
    }
}