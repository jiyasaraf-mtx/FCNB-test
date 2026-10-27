/**
 * @author      : Sudhanshu Jain
 * @since       : 10-11-2023in
 * @description : This MODPR_ProLandSurveyController class is used by ModprProLandSurveyStateExam lwc for sending notification.
 *  ------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * Version      Date                Author                   Details
 *    1         10-11-2023        Sudhanshu Jain              Initial Developement
 * -------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
public with sharing class LPI_ProLandSurveyController {
    private static final String PLS_STATE_EXAM_BUTTON = 'Approve_PLS_State_Exam';
    private static final String PLS_STATE_RE_EXAM_BUTTON = 'Approve_PLS_State_Re_Exam';
    private static final String PLS_STATE_EXAM = 'PLS State Exam';
    private static final String PLS_STATE_RE_EXAM = 'PLS State Re-Exam';
    private static final String PROFESSIONAL_LAND_SURVEYOR = 'Professional Land Surveyor';
    private static final Set<String> buttonNameSet = new Set<String> {PLS_STATE_EXAM_BUTTON,PLS_STATE_RE_EXAM_BUTTON};

   

    /**
    * @author                      : MTX Product
    * @since                       : 
    * @description                 : This method returns the Instructions present in our flow
    * @param parId                 : PreliminaryApplicationRef record Id
    * @param buttonName            : pressed button name
    * @return                      : String
    * @last modified by            : Uzma Md
    * @last modified date          : 
    * @modified details            : 
    */
    @AuraEnabled
    public static String createNotification(String iaId, String buttonName, Boolean isConfirmButton) {
        try{
            Boolean isPortalNotificationCreated = false;
            Boolean isEmailNotificationSend = false;
            if(String.isNotBlank(iaId) && buttonNameSet.contains(buttonName)){
                String fieldsToQuery = 'Id, AccountId, License_Type_Name__c, Account.Name, LicenseType.Email_Specifications_Final__c, Account.PersonEmail, LicensePermitNameId, LicenseTypeId';
                String whereClause = 'Id = \'' + String.escapeSingleQuotes(iaId) +'\'';
                List<IndividualApplication> iaList= LPI_IndividualApplicationDAO.getIndividualApplicationByDymanicQuery(
                    fieldsToQuery,
                    whereClause,
                    '1',
                    null,
                    null
                );
                if(!iaList.isEmpty()){
                    IndividualApplication ia = iaList[0];
                    String licenseTypeName = ia.License_Type_Name__c;
                    String portalUserAccountId = ia.AccountId;
                    String applicationType;
                    String subType;
                    if(buttonName == PLS_STATE_EXAM_BUTTON){
                        applicationType = PLS_STATE_EXAM;
                        subType = PLS_STATE_EXAM;
                    }else if(buttonName == PLS_STATE_RE_EXAM_BUTTON){
                        applicationType = PLS_STATE_RE_EXAM;
                        subType = PLS_STATE_RE_EXAM;
                    }
                    if(String.isNotBlank(applicationType) && String.isNotBlank(subType) && 
                        PROFESSIONAL_LAND_SURVEYOR.equalsIgnoreCase(licenseTypeName) &&
                        String.isNotBlank(portalUserAccountId )){
                        List<String> typeList = new List<String>();
                        List<String> subTypeList = new List<String>();
                        List<String> regAuthNAmeList = new List<String>();
                        Map<String, Portal_Notification_Message__mdt> portalNotificationMessageMap;
                        Map<String, Notification_Message__mdt> notificationMessageMap;
                        String key = '';
                        typeList.add(applicationType);
                        subTypeList.add(subType);   
                        regAuthNAmeList.add(licenseTypeName);
                          
                        portalNotificationMessageMap = LPI_ServiceUtility.fetchPortalNotificationMetaDataRecord(
                            regAuthNAmeList,
                            typeList,
                            subTypeList,
                            null
                        );
                        notificationMessageMap = LPI_ServiceUtility.fetchNotificationMetaDataRecord(
                            regAuthNAmeList,
                            typeList,
                            subTypeList,
                            null
                        );
                        Map<String, Object> boardSignatureMap = (Map<String, Object>) JSON.deserializeUntyped(
                            String.valueOf(ia.LicenseType.Email_Specifications_Final__c)
                        );
                        key = LPI_ServiceUtility.createKeyForMetaDataMap(
                            licenseTypeName,
                            applicationType,
                            subType,
                            null
                        );
                        if (portalNotificationMessageMap.containsKey(key)) {
                            Map<String, String> urlParameter = new Map<String, String>();
                            urlParameter.put('applicationId',ia.Id);
                            urlParameter.put('type',applicationType);
                            urlParameter.put('amendmentType',subType);
                            urlParameter.put('accountId',portalUserAccountId);
                            urlParameter.put('regAuthId',ia.LicenseTypeId);
                            urlParameter.put('blId',ia.LicensePermitNameId);
                            Notification__c portalNoti;
                            portalNoti = LPI_ServiceUtility.createPortalNotificationRecord(
                                portalNotificationMessageMap.get(key),
                                false,
                                null,
                                urlParameter,
                                portalUserAccountId
                            );
                            portalNoti.Individual_Application__c = ia.Id;
                            portalNoti.Type__c = applicationType;
                            if (portalNoti != null) {
                                LPI_DML.doInsert(portalNoti);
                                isPortalNotificationCreated = true;
                            }
                        }
                        
                        LPI_DML.doUpdate(ia);
                    }
                }
            }
            if(isPortalNotificationCreated){
                return 'success';
            }else{
                throw new LPI_Exception('Problem in creating portal Notification Message or Notification Message');
            }
        }catch (Exception e) {
			LPI_ExceptionManager.logException('LPI_ProLandSurveyController', 'createNotification', e);
            throw new AuraHandledException(e.getMessage()); 
		}
    }
}