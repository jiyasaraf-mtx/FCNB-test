/**
 * @author                      : Vamsi Mudaliar
 * @since                       : 10 May, 2023
 * @description                 : This Class is Used to Handle NABP CPE Activity Callouts and TCP Creation Part.
  * @group                      : MTX Group Inc
 * @last modified by            : Ayush Dev
 * @last modified date          : 11th May 2023
 * @last modified details       : Code Review Fixes, Added DAO, Optimizing code and Sanitising input in soql query. 
 */
public with sharing class LPI_NABPCPEActivityController {
    public static final String LICENSE_SOBJECT_API_NAME = 'BusinessLicense';
    public static final String IA_SOBJECT_API_NAME = 'IndividualApplication';
    public static final String NO_RECORD_FOUND_MSG = 'Couldn\'t Fetch the Record,Please try again.';
    public static final String EXPIRED_LICENSE_ERR_MSG = 'CE data from NABP can be retrieved only for Active and Inactive licenses';
    public static final Set<String> VALID_STATUS_SET = new Set<String>{'Active','Inactive'};
    public static final String RENEWAL_TEXT = 'Renewal';
    public static final String CE_HOURS_TEXT = 'CE Hours';
    public static final Integer SUCCESS_STATUS_CODE = 200;
    public static final Integer SUCCESS_STATUS_CODE_INTERNAL = 202;
    public static final String ACKNOWLEDGE_INTERNAL_USER = 'You will be informed once the data gets loaded into the system.';
    public static final String METADATA_DEV_NAME_INTERNAL = 'Pharmacy_Pharmacist_Renewal_CPE_Batch';
    public static final String METADATA_DEV_NAME = 'Pharmacy_Pharmacist_Renewal_CPE';
    

    private static Map<Integer, String> statusCodeToResponseMap = new Map<Integer, String>{
        200 => 'Response received from NABP. CE hours have been updated on the applicant record.',
        400 => 'Invalid request. Please retry',
        401 => 'Unauthorized',
        403 => 'Forbidden',
        404 => '"No Cpe activity found."',
        409 => 'Provided DOB is not a match/ EProfile not found',
        500 => 'Error while processing request',
        202=> 'You will be informed once the data gets loaded into the system.'
    };

    @AuraEnabled
    public static List<LPI_Wrapper.OptionWrapper> getBoardOptions(String boardSearchTxt) {
        try {
            if(String.isBlank(boardSearchTxt)) {
                return null;
            }
            String filterText =  '\''+ String.escapeSingleQuotes(boardSearchTxt) + '%\'';
            List<LPI_Wrapper.OptionWrapper> optionList = new List<LPI_Wrapper.OptionWrapper>();
            for(RegulatoryAuthority regAuth : LPI_RegulatoryAuthorityDAO.getRegulatoryAuthorityByDymanicQuery('Id,Name','Name LIKE '+ filterText,null,null,null)) {
                LPI_Wrapper.OptionWrapper obj = new LPI_Wrapper.OptionWrapper();
                obj.label = regAuth.Name;
                obj.value = regAuth.Name;
                obj.uniqueKey = regAuth.Id;
                optionList.add(obj);
            }
            return optionList;

        } catch (Exception ex) {
            LPI_ExceptionManager.logException('LPI_NABPCPEActivityController', 'validateEProfileIdOnAccount', ex);
            throw new AuraHandledException(ex.getMessage());
        }
    }

    @AuraEnabled
    public static List<LPI_Wrapper.OptionWrapper> getRATRecordsBasedOnBoard(String boardId) {
        try {
            if(String.isBlank(boardId)) {
                return null;
            }
            List<LPI_Wrapper.OptionWrapper> optionList = new List<LPI_Wrapper.OptionWrapper>();
            for(RegulatoryAuthorizationType ratRecord : LPI_RegulatoryAuthorizationTypeDAO.getRegulatoryAuthorizationTypeByDymanicQuery('Id,Name,IssuingDepartmentId','IssuingDepartmentId =\''+String.escapeSingleQuotes(boardId)+'\'',null,null,null)) {
                
                LPI_Wrapper.OptionWrapper obj = new LPI_Wrapper.OptionWrapper();
                obj.label = ratRecord.Name;
                obj.value = ratRecord.Name;
                obj.uniqueKey = ratRecord.Id;
                optionList.add(obj);
            }
            return optionList;
        } catch (Exception ex) {
            LPI_ExceptionManager.logException('LPI_NABPCPEActivityController', 'getRATRecordsBasedOnBoard', ex);
            throw new AuraHandledException(ex.getMessage());
        }
    }

    /**
     * @author                      : Vamsi Mudaliar
     * @since                       : 10 May 2023
     * @description                 : Method is Used to Validate Eprofile Id on Account and Get Few more Details based on the recordId we are passing.
     * @param licenseId             : This can be either Individual Application / BusinessLicense Id.
     * @return                      : `Map<String,Object>`
     * @last modified by            : Ayush Dev
     * @last modified date          : 11 May 2023
     * @modified details            : Code Review Fixes
     */
    @AuraEnabled
    public static Map<String,Object> validateEProfileIdOnAccount(String licenseId){
        try {
            if(String.isBlank(licenseId)) {
                return null;
            }
            Id paramVal = Id.valueOf(licenseId);
            String objectName = String.valueOf(paramVal.getSObjectType());
            Map<String,Object> result = new Map<String,Object>();
            String eProfileId;
            String contactId;
            String mmDDFormat;
            Date dob;
            String boardName;
            String licenseName;
            String blId;
            List<BusinessLicense> blList = new List<BusinessLicense>();
            List<IndividualApplication> iaList = new List<IndividualApplication>();
            if(objectName.equals(IA_SOBJECT_API_NAME)) {
                iaList = LPI_IndividualApplicationDAO.getIndividualApplicationByDymanicQuery(
                                'Id,AccountId,Account.NABP_e_Profile_ID__c,Account.PersonContactId,Account.Date_of_Birth__c,LicenseType.IssuingDepartment.Name,License_Type_Name__c,LicensePermitName.Status,LicensePermitNameId',
                                'Id=\''+String.escapeSingleQuotes(licenseId)+'\'',null,null,null
                        );
                if(iaList.isEmpty()) {
                    throw new LPI_Exception(NO_RECORD_FOUND_MSG);
                } else if(!VALID_STATUS_SET.contains(iaList[0].LicensePermitName.Status)) {
                    throw new LPI_Exception(EXPIRED_LICENSE_ERR_MSG);
                }
                licenseName = iaList[0]?.License_Type_Name__c;
                boardName = iaList[0]?.LicenseType.IssuingDepartment.Name;
                eProfileId = iaList[0]?.Account.NABP_e_Profile_ID__c;
                contactId = iaList[0]?.Account.PersonContactId;
                dob = iaList[0]?.Account.Date_of_Birth__c;
                blId = iaList[0]?.LicensePermitNameId;
            } else if(objectName.equals(LICENSE_SOBJECT_API_NAME)) {
                blList = LPI_BusinessLicenseDAO.fetchBusinessLicenseRecords('Id,AccountId,Status,Account.NABP_e_Profile_ID__c,Account.PersonContactId,Account.Date_of_Birth__c,RegulatoryAuthorizationType.IssuingDepartment.Name,Regulatory_Authorization_Type_Name__c','Id=\''+String.escapeSingleQuotes(licenseId)+'\'');
                if(blList.isEmpty()) {
                    throw new LPI_Exception(NO_RECORD_FOUND_MSG);
                } else if(!VALID_STATUS_SET.contains(blList[0].Status)) {
                    throw new LPI_Exception(EXPIRED_LICENSE_ERR_MSG);
                }
                licenseName = blList[0]?.Regulatory_Authorization_Type_Name__c;
                boardName = blList[0]?.RegulatoryAuthorizationType.IssuingDepartment.Name;
                eProfileId = blList[0]?.Account.NABP_e_Profile_ID__c;
                contactId = blList[0]?.Account.PersonContactId;   
                dob = blList[0]?.Account.Date_of_Birth__c;
                blId = blList[0]?.Id;
            } else {
                throw new LPI_Exception(NO_RECORD_FOUND_MSG);
            }
            if(dob!=null) {
                DateTime formattedDob = DateTime.newInstance(
                    dob.year(),
                    dob.month(),
                    dob.day(),
                    0,
                    0,
                    0
                );
                mmDDFormat = formattedDob.format('MM-dd');
            }
            result.put('eProfileId',eProfileId);
            result.put('licenseName',licenseName);
            result.put('contactId',contactId);
            result.put('dob',mmDDFormat);
            result.put('boardName',boardName);
            result.put('blId',blId);
            return result;
        } catch (Exception ex) {
            LPI_ExceptionManager.logException('LPI_NABPCPEActivityController', 'validateEProfileIdOnAccount', ex);
            throw new AuraHandledException(ex.getMessage());
        }
    }

    /**
     * @author                      : Vamsi Mudaliar
     * @since                       : 10 May 2023
     * @description                 : This Method is used to Fetch The Records from External Nursys System via Callout. And get the Corresponding Status
     * @param jsonData              : this JSON String contains Information we passed via LWC. Which is then used to make Callout.
     * @param contactId             : ContactID of the Applicant.
     * @return                      : `Map<String,Object>`
     * @last modified by            : Ayush Dev
     * @last modified date          : 11 May 2023
     * @modified details            : Code Review Fixes
     */
    @AuraEnabled
    public static Map<String,Object> fetchTrainingCourseParticipantRec(String contactId,String jsonData) {
        try {
            Map<String,Object> wrapper = (Map<String,Object>) JSON.deserializeUntyped(jsonData);
            Boolean isInternalUser = (Boolean)wrapper.get('forInternalUser');
            String blId = (String) wrapper.get('blId');
            EProfileInternalWrapper bulkReqWrapper;
            EProfileWrapper realTimeReqWrapper;
            String jsonBody;
            if(isInternalUser) {
                bulkReqWrapper = (EProfileInternalWrapper) JSON.deserialize(jsonData, EProfileInternalWrapper.class);            
                jsonBody = JSON.serialize(bulkReqWrapper);
                wrapper.put('metaDataName',METADATA_DEV_NAME_INTERNAL);
                if(bulkReqWrapper.activityDateFrom > bulkReqWrapper.activityDateTo) {
                    throw new LPI_Exception('Activity Start Date cannot be greater than Activity End Date');
                }
            } else {
                realTimeReqWrapper =  (EProfileWrapper) JSON.deserialize(jsonData,EProfileWrapper.class);
                wrapper.put('metaDataName',METADATA_DEV_NAME);
                jsonBody = JSON.serialize(realTimeReqWrapper);
            }
            Map<String,Object> mapResponse = new Map<String,Object>();
            LPI_RealTimeAPIConfiguration__mdt configRecord = getMetaDataConfig(wrapper,mapResponse);
            if (configRecord == null) {
                return mapResponse;
            }
            String calloutApi =
            'callout:' +
            configRecord.Named_Credential_Name__c +
            configRecord.EndPoint_Url__c;

            HTTPResponse response =null;/* LPI_RealTimeIntegrationsController.fetchResultFromApi(
                calloutApi,
                jsonBody
            );*/
            Integer statusCode = response.getStatusCode();
            if(isInternalUser && statusCode==SUCCESS_STATUS_CODE_INTERNAL) {
                mapResponse.put('statusCode',statusCode);
                mapResponse.put('statusMessage',statusCodeToResponseMap.get(statusCode));
                return mapResponse;
            }
            else if(statusCode==SUCCESS_STATUS_CODE) {
                if(response.getBody()==statusCodeToResponseMap.get(404)) {
                    mapResponse.put('statusCode',404);
                    mapResponse.put('statusMessage',statusCodeToResponseMap.get(404)
                                    .replace('"', '')
                                    .replace('Cpe', 'CPE'));  
                    return mapResponse;      
                }
                List<LPI_Wrapper.NABPCEActivityWrapper> responseList = (List<LPI_Wrapper.NABPCEActivityWrapper>)JSON.deserialize(response.getBody(),List<LPI_Wrapper.NABPCEActivityWrapper>.class);
                createTCPRecords(responseList,contactId,blId);
            }

            mapResponse.put('statusCode',statusCode);
            mapResponse.put('statusMessage',statusCodeToResponseMap.get(statusCode));
            return mapResponse;
        } catch(Exception ex) {
            LPI_ExceptionManager.logException('LPI_NABPCPEActivityController', 'fetchTrainingCourseParticipantRec', ex);
            throw new AuraHandledException(ex.getMessage());
        }
    }  

    /**
     * @author                      : Vamsi Mudaliar
     * @since                       : 10 May 20223
     * @description                 : This Method is used to Insert newly fetched TCP Records via Callout. by comparing the existing Records in System.
     * @param responseList          : List of TCP Records Fetched via Callout.
     * @param contactId             : ContactID of the Applicant.
     * @return                      : `void`
     * @last modified by            : Ayush Dev
     * @last modified date          : 11 May 2023
     * @modified details            : Code Review Fixes
     */
    private static void createTCPRecords(List<LPI_Wrapper.NABPCEActivityWrapper> responseList,String contactId,String blId) {
        try {
            if(String.isBlank(contactId)) {
                return;
            }
            String key;
            Date dateObj;
            Map<String,Set<String>> fieldToUniqueValMap = new Map<String,Set<String>>{
                'Title'=> new Set<String>(),
                'UAN'=> new Set<String>()
            };
            List<TrainingCourseParticipant> tcpRecToInsert = new List<TrainingCourseParticipant>();
            for(LPI_Wrapper.NABPCEActivityWrapper record: responseList) {
                if(String.isNotBlank(record.UAN)) {
                    fieldToUniqueValMap.get('UAN').add(record.UAN);
                }
                if(String.isNotBlank(record.Title)) {
                    fieldToUniqueValMap.get('Title').add(record.Title);
                }
            }
            Set<String> uniqueKeySet = new Set<String>();
            String tcpFields = 'Id,Title__c,StartDate,UAN__c,Business_License__c';
            String tcpWhereClause = 'ContactId = \''+String.escapeSingleQuotes(contactId)+'\'';
            tcpWhereClause+=' AND Title__c IN '+LPI_ServiceUtility.getStringValuesByStringSet(fieldToUniqueValMap.get('Title'));
            tcpWhereClause+=' AND UAN__c IN '+ LPI_ServiceUtility.getStringValuesByStringSet(fieldToUniqueValMap.get('UAN'));

            for(TrainingCourseParticipant record: (new LPI_TrainingCourseParticipantDAO.LPI_TrainingCourseParticipantWithoutSharingDAO())
                                                .getTrainingCourseParticipantByDymanicQuery(tcpFields,tcpWhereClause,null,null,null)) {
                    dateObj = Date.newInstance(record.StartDate.year(), record.StartDate.month(), record.StartDate.day());
                    key = (String.valueOf(dateObj) +'@'+ record.UAN__c + '@'+record.Title__c).toLowerCase().replace(' ','');   
                    uniqueKeySet.add(key);
            }

            for(LPI_Wrapper.NABPCEActivityWrapper record: responseList) {
                key = (String.valueOf(record.ActivityDate)+ '@' + record.UAN + '@'+record.Title).toLowerCase().replace(' ','');   
                
                if(!uniqueKeySet.contains(key)) {
                    tcpRecToInsert.add(createTrainingParticipant(record,contactId,blId));
                }
            }

            if(!tcpRecToInsert.isEmpty()) {
                LPI_DML.doInsert(tcpRecToInsert); 
            }
        }
        catch(Exception ex) {
                LPI_ExceptionManager.logException('LPI_NABPCPEActivityController', 'createTCPRecords', ex);
                throw new AuraHandledException(ex.getMessage());
        }
    }
    /**
     * @author                      : Vamsi Mudaliar
     * @since                       : 10 May 20223
     * @description                 : This Helper Method is used to Populate Required Fields onto TCP Record and Return the Object.
     * @param record                : This Wrapper Object Hold TCP Record Information
     * @param contactId             : ContactID of the Applicant.
     * @return                      : `TrainingCourseParticipant`
     * @last modified by            : Ayush Dev
     * @last modified date          : 11 May 2023
     * @modified details            : Code Review Fixes
     */
    private static TrainingCourseParticipant createTrainingParticipant(LPI_Wrapper.NABPCEActivityWrapper record,String contactId,String blId) {
        TrainingCourseParticipant tcpRec = new TrainingCourseParticipant();
        tcpRec.UAN__c = record.UAN;
        tcpRec.StartDate = DateTime.newInstance(Date.valueOf(record.ActivityDate), Time.newInstance(0,0,0,0));
        tcpRec.Title__c = record.Title;
        tcpRec.TotalHours = record.Home + record.Live;
        tcpRec.Topic_Designator__c = record.TopicDesignator;
        tcpRec.TotalCredits = record.CreditUnits;
        tcpRec.ContactId = contactId;
        tcpRec.Business_License__c = blId;
        if(record.ActivityDate != null && String.isNotBlank(record.UAN) && String.isNotBlank(record.Title)){
            tcpRec.Unique_Identifier__c = EncodingUtil.convertToHex(Crypto.generateDigest('MD5', Blob.valueOf(String.valueOf(record.ActivityDate).removeEnd(' 00:00:00')+record.UAN+record.Title)));
        }
        return tcpRec;
    }

    /**
     * @author                      : Vamsi Mudaliar
     * @since                       : 10 May 20223
     * @description                 : This Helper Method is used to Get the MetaData Configuration and Extract NameCredentials and Other info, for making callout.
     * @param wrapper               : This Wrapper Object Additional Information Along with Info Specific to callout.
     * @param mapResponse           : This Map is used to output info back to the FrontEnd.
     * @return                      : `LPI_RealTimeAPIConfiguration__mdt`
     * @last modified by            : Ayush Dev
     * @last modified date          : 11 May 2023
     * @modified details            : Code Review Fixes
     */
    private static LPI_RealTimeAPIConfiguration__mdt getMetaDataConfig(Map<String,Object> wrapper,Map<String,Object> mapResponse) {
        LPI_RealTimeAPIConfiguration__mdt configRecord=null;
        List<LPI_RealTimeAPIConfiguration__mdt>  recordList = 
        LPI_RealTimeAPIConfiguration__mdt.getAll()
        ?.values();
        if (!wrapper.containsKey('boardName') || !wrapper.containsKey('licenseName') || !wrapper.containsKey('metaDataName') ) {
            mapResponse.put('isSuccess', false);
            mapResponse.put('response', 'Metadata not found');
            return configRecord;
        }
        for (LPI_RealTimeAPIConfiguration__mdt record : recordList) {
            if (
                record.Board_Name__c == wrapper.get('boardName') &&
                record.License_Type__c == wrapper.get('licenseName') &&
                record.Sub_Type__c == RENEWAL_TEXT &&
                record.Integeration_Type__c == CE_HOURS_TEXT && 
                record.DeveloperName == wrapper.get('metaDataName')
            ) {
                configRecord = record;
                break;
            }
        }
        if(configRecord==null) {
            mapResponse.put('isSuccess', false);
            mapResponse.put('response', 'Metadata not found');
        }
        return configRecord;
    }

    public class EProfileInternalWrapper {
        public Date activityDateFrom;
        public Date activityDateTo;
    }

    public class EProfileWrapper {
        public Integer eProfileId;
        public String dob;
        public Date activityDateFrom;
        public Date activityDateTo;
    }

}