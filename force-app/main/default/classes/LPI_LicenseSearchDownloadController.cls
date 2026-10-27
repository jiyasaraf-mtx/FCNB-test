/**
 * @description       : 
 * @author            : MTX Group Product Team
 * @group             : 
 * @last modified on  : 07-26-2024
 * @last modified by  : MTX Group Product Team
**/
public with sharing class LPI_LicenseSearchDownloadController {
    
    @AuraEnabled
    public static List<LPI_Wrapper.OptionWrapper> getBoardNames(){
        try {
            String fields = 'Id,Name';
            String whereClause= 'Name != NULL ';//+
            List<LPI_Wrapper.OptionWrapper> wrapperList = new List<LPI_Wrapper.OptionWrapper> ();
            LPI_RegulatoryAuthorityDAO.LPI_RegulatoryAuthorityWithoutSharingDAO classObj = new LPI_RegulatoryAuthorityDAO.LPI_RegulatoryAuthorityWithoutSharingDAO();
            for(RegulatoryAuthority regAuth : classObj.getRegulatoryAuthorityByDymanicQueryWithoutSharing(fields,whereClause,null,null,null)){
                LPI_Wrapper.OptionWrapper wrapper = new LPI_Wrapper.OptionWrapper();
                wrapper.value = regAuth.Name;
                wrapper.label = regAuth.Name;
                wrapperList.add(wrapper);
            }
            return wrapperList;
        } catch (Exception e) {
            LPI_ExceptionManager.logException(
                'LPI_LicenseSearchDownloadController',
                'getBoardNames',
                e
            );
            throw new LPI_Exception(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<LPI_Wrapper.FileWrapper> getFilesForSelectedBoard(String jsonData){
        try {
            if(String.isBlank(jsonData)){
                return null;
            }
            LPI_Wrapper.LicenseSearchDownloadWrapper wrapper = (LPI_Wrapper.LicenseSearchDownloadWrapper)JSON.deserialize(jsonData, LPI_Wrapper.LicenseSearchDownloadWrapper.class);
            if(String.isBlank(wrapper.selectedBoard)){
                return null;
            }
            List<LPI_Wrapper.FileWrapper> filesList = new List<LPI_Wrapper.FileWrapper>();
            String fields ='Id,Name,Webpull_File_Url__c';
            String whereClause ='Webpull_File_Url__c != NULL AND Name = \'' + String.escapeSingleQuotes(wrapper.selectedBoard) + '\'';
            LPI_RegulatoryAuthorityDAO.LPI_RegulatoryAuthorityWithoutSharingDAO classObj = new LPI_RegulatoryAuthorityDAO.LPI_RegulatoryAuthorityWithoutSharingDAO();
            for(RegulatoryAuthority regAuth : classObj.getRegulatoryAuthorityByDymanicQueryWithoutSharing(fields,whereClause,null,null,null)){
                LPI_Wrapper.FileWrapper fileWrapper = new LPI_Wrapper.FileWrapper();
                fileWrapper.fileName = regAuth.Webpull_File_Url__c.substringAfter(LPI_LiteralConstant.FILE_NAME_DELIMINITER);
                fileWrapper.fileUrl = regAuth.Webpull_File_Url__c.substringBefore(LPI_LiteralConstant.FILE_NAME_DELIMINITER);
                fileWrapper.licenseName = regAuth.Name;
                filesList.add(fileWrapper);
            }
            
            fields ='Id,Name,Webpull_File_Url__c';
            whereClause ='Webpull_File_Url__c != NULL AND IssuingDepartment.Name = \'' + String.escapeSingleQuotes(wrapper.selectedBoard) + '\'';
            LPI_RegulatoryAuthorizationTypeDAO.LPI_RegulatoryAuthorizationTypeWithoutSharingDAO classObjRegAuthType = new LPI_RegulatoryAuthorizationTypeDAO.LPI_RegulatoryAuthorizationTypeWithoutSharingDAO();
            for(RegulatoryAuthorizationType regAuthType : classObjRegAuthType.getRegAuthTypeWithoutSecurity(fields,whereClause,null,null,null)){
                LPI_Wrapper.FileWrapper fileWrapper = new LPI_Wrapper.FileWrapper();
                fileWrapper.fileName = regAuthType.Webpull_File_Url__c.substringAfter(LPI_LiteralConstant.FILE_NAME_DELIMINITER);
                fileWrapper.fileUrl = regAuthType.Webpull_File_Url__c.substringBefore(LPI_LiteralConstant.FILE_NAME_DELIMINITER);
                fileWrapper.licenseName = regAuthType.Name;
                filesList.add(fileWrapper);
            }
            return filesList;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}