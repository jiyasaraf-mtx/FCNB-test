/**
 * @description       :
 * @author            : MTX Group Product Team
 * @group             :
 * @last modified on  : 07-26-2024
 * @last modified by  : MTX Group Product Team
 **/
public with sharing class LPI_ProfileController {

    public static final string PROFILE_PICTURE_TEXT = 'Profile Picture';

    /**
    * @description : Method to fetch User details on the profile Page.
    * @author MTX Group Product Team | 04-10-2023 
    * @return LPI_RegisterController.RegistrationFormWrapper 
    **/
    @AuraEnabled
    public static LPI_RegisterController.RegistrationFormWrapper getProfileDetails() {
        try {
            String fields = 'Account.FirstName,Account.MiddleName,FullPhotoUrl,Account.LastName,Account.PersonEmail,Account.Phone,Account.Social_Security_Number__c,Account.Date_of_Birth__c,Account.Is_the_address_in_US_or_International__c,Account.PersonOtherState,Account.PersonOtherCountry,Account.PersonOtherStreet,Account.PersonOtherCity,Account.PersonOtherPostalCode,Account.PersonOtherStateCode,Account.PersonOtherCountryCode,Account.Other_State__c';
            String whereClause = ' ID = \'' + UserInfo.getUserId() + '\'';
            LPI_RegisterController.RegistrationFormWrapper wrapper = new LPI_RegisterController.RegistrationFormWrapper();
            for (
                User userRec : LPI_UserDao.getUserByDymanicQuery(
                    fields,
                    whereClause,
                    null,
                    null,
                    null
                )
            ) {
                wrapper.firstname = userRec.Account.FirstName;
                wrapper.middleName = userRec.Account.MiddleName;
                wrapper.lastName = userRec.Account.LastName;
                wrapper.email = userRec.Account.PersonEmail;
                wrapper.phone = userRec.Account.Phone;
                wrapper.ssn = userRec.Account.Social_Security_Number__c;
                wrapper.birthdate = String.valueOf(
                    userRec.Account.Date_of_Birth__c
                );
                wrapper.street1 = userRec.Account.PersonOtherStreet;
                wrapper.city = userRec.Account.PersonOtherCity;
                wrapper.addressInUSOrInternational = userRec.Account.Is_the_address_in_US_or_International__c;
                wrapper.zipcode = userRec.Account.PersonOtherPostalCode;
                wrapper.state = String.isNotBlank(
                        userRec.Account.PersonOtherStateCode
                    )
                    ? userRec.Account.PersonOtherStateCode
                    : userRec.Account.Other_State__c;
                wrapper.country = userRec.Account.PersonOtherCountryCode;
                wrapper.profileUrl = userRec.FullPhotoUrl.replace(
                    '/licence/',
                    ''
                );
                wrapper.oldPhone = userRec.Account.Phone;
                wrapper.oldEmail = userRec.Account.PersonEmail;
            }
            return wrapper;
        } catch (Exception e) {
            LPI_ExceptionManager.logException(
                'LPI_ProfileController',
                'getProfileDetails',
                e
            );
            throw new LPI_Exception(e.getMessage());
        }
    }

    /**
    * @description : Method to update Email or Phone for the user.
    * @author MTX Group Product Team
    * @param jsonData 
    * @return Boolean 
    **/
    @AuraEnabled
    public static Boolean updateProfileDetails(String jsonData) {
        try {
            if (String.isBlank(jsonData)) {
                return false;
            }
            LPI_RegisterController.RegistrationFormWrapper wrapper = (LPI_RegisterController.RegistrationFormWrapper) JSON.deserialize(
                jsonData,
                LPI_RegisterController.RegistrationFormWrapper.class
            );
            String fields = 'Id,AccountId,Email,Phone';
            String whereClause = ' ID = \'' + UserInfo.getUserId() + '\'';
            List<User> userList = LPI_UserDao.getUserByDymanicQuery(
                fields,
                whereClause,
                null,
                null,
                null
            );
            if (
                userList[0].Phone != wrapper.phone
            ) {
                userList[0].Phone = wrapper.phone;
                LPI_WithoutSharingUtility.updateSObjectList(userList);

                Account acc = new Account(
                    Id = userList[0].AccountId,
                    Phone = wrapper.phone
                );
                LPI_WithoutSharingUtility.updateSObjectList( new List<Account>{acc} );
            }
            if (
                userList[0].Email != wrapper.email
            ) {
                userList[0].Email = wrapper.email;
                LPI_WithoutSharingUtility.updateSObjectList(userList);
            }

            return true;
        } catch (Exception e) {
            LPI_ExceptionManager.logException(
                'LPI_ProfileController',
                'updateProfileDetails',
                e
            );
            throw new LPI_Exception(e.getMessage());
        }
    }

    /**
    * @description : Method to update Profile image of the user.
    * @author MTX Group Product Team
    * @param documentId 
    * @return String 
    **/
    @AuraEnabled
    public static String uploadProilePhoto(String documentId) {
        try {
            if (String.isBlank(documentId)) {
                throw new LPI_Exception('Error uploading file');
            }
            String fields = 'ContentDocumentId,FileExtension,title,VersionData,Content_Type__c';
            String whereClause =
                'ContentDocumentId = \'' +
                String.escapeSingleQuotes(documentId) +
                '\' OR Content_Type__c = \'' + PROFILE_PICTURE_TEXT + '\'';
            List<ContentVersion> cvList = LPI_ContentVersionDAO.getContentVersionByDymanicQuery(
                fields,
                whereClause,
                null,
                null,
                null
            );
            if (cvList.isEmpty()) {
                return null;
            }
            Set<String> contentDocIdSet = new Set <String>();
            ContentVersion cvRecordUpdate = new ContentVersion();
            ContentVersion newCvRec = new ContentVersion();
            for( ContentVersion cv : cvList){
                if(cv.ContentDocumentId ==  documentId){
                    newCvRec = cv;
                    cvRecordUpdate.Id = cv.Id;
                    cvRecordUpdate.Content_Type__c = PROFILE_PICTURE_TEXT;
                }
                else if(cv.Content_Type__c == PROFILE_PICTURE_TEXT){
                    contentDocIdSet.add(cv.ContentDocumentId);
                }
            }
            ConnectApi.UserProfiles.setPhoto(
                null,
                UserInfo.getUserId(),
                new ConnectApi.BinaryInput(
                    newCvRec.VersionData,
                    'image/' + newCvRec.FileExtension,
                    newCvRec.title +
                    '.' +
                    newCvRec.FileExtension
                )
            );
            fields = 'FullPhotoUrl';
            whereClause = ' ID = \'' + UserInfo.getUserId() + '\'';
            List<User> userList = LPI_UserDao.getUserByDymanicQuery(
                fields,
                whereClause,
                null,
                null,
                null 
            );

            if(!contentDocIdSet.isEmpty()){
                fields = 'Id';
                whereClause = ' ID IN ' + LPI_ServiceUtility.getStringValuesByList(new List<String>(contentDocIdSet));
                List<ContentDocument> cdList = LPI_ContentDocumentDAO.getContentDocumentByDymanicQuery(fields,whereClause,null,null,null);
                LPI_DML.doDelete(cdList);
            }
            LPI_DML.doUpsertSystemContext(new List<ContentVersion>{cvRecordUpdate});
            return userList[0].FullPhotoUrl.replace('/licence/', '');
        } catch (Exception e) {
            LPI_ExceptionManager.logException(
                'LPI_ProfileController',
                'uploadProilePhoto',
                e
            );
            throw new LPI_Exception(e.getMessage());
        }
    }
    @AuraEnabled
    public static void deleteUserPhoto(){
        Savepoint sp = Database.setSavepoint();        
        try { 
            ConnectApi.UserProfiles.deletePhoto(null, UserInfo.getUserId());
        } catch(DMLException de){
            Database.rollback(sp);
        }
}
}