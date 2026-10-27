public without sharing class EmpDocumentUpload {
    public EmpDocumentUpload() {

    }

    @AuraEnabled()
    public static String uploadFile(String fileContent, String filename, String base64, Id IndividualApplicationID) {
        Application_Document__c AppDoc = new Application_Document__c();
        AppDoc.File_Name__c = fileContent;
        AppDoc.Document_Name__c = 'Supporting Document';
        AppDoc.Individual_Application__c = IndividualApplicationID;
        AppDoc.Type__c = 'Renewal';
        AppDoc.Status__c = 'Submitted';
        INSERT AppDoc;

        ContentVersion cv = createContentVersion(base64, filename);
        System.debug('cv@@@'+cv);
        ContentDocumentLink cdl = createContentLink(cv.Id, AppDoc.Id);
        System.debug('cdl&&&'+cdl);
        
        if(String.isNotBlank(AppDoc.Id) || AppDoc.Id!=null){
            List<IndividualApplication> indAppList = [select Id,Status from IndividualApplication where Id =:IndividualApplicationID LIMIT 1];
            if(!indAppList.isEmpty()){
                //indAppList[0].Status = 'Ready for ED Approval';
                
                //update indAppList;
            }
        }
        
        return AppDoc.Id;

    }
    // @AuraEnabled
    // public static String uploadFileSF(String base64, String filename, String recordId) {
    //     system.debug('method called:- '+recordId);
    //     system.debug('method base64:- '+base64);
    //     system.debug('method filename:- '+filename);
    //     ContentVersion cv = createContentVersion(base64, filename);
    //     System.debug('cv@@@'+cv);
    //     ContentDocumentLink cdl = createContentLink(cv.Id, recordId);
    //     System.debug('cdl&&&'+cdl);
    //     if (cv == null || cdl == null) { return null; }
    //     return cdl.ContentDocumentId;
    // }
   public static ContentVersion createContentVersion(String base64, String filename) {
        ContentVersion cv = new ContentVersion();
        cv.VersionData = EncodingUtil.base64Decode(base64);
        cv.Title = filename;
        cv.PathOnClient = filename;
        try {
            insert cv;
            return cv;
        } catch(DMLException e) {
            System.debug(e);
            return null;
        }
    }
public static ContentDocumentLink createContentLink(String contentVersionId, String recordId) {
        system.debug('recordId:- '+recordId);
        if (contentVersionId == null || recordId == null) { return null; }
        
        Id conId = [SELECT ContentDocumentId 
                     FROM ContentVersion 
                     WHERE Id =:contentVersionId].ContentDocumentId;
        
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = conId;
        cdl.LinkedEntityId = recordId;
        cdl.ShareType = 'V';
        try {
            insert cdl;
            return cdl;
        } catch(DMLException e) {
            System.debug(e);
            return null;
        } 
    }

}