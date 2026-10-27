/**
 * @description       : 
 * @author            : MTX Group Product Team
 * @group             : 
 * @last modified on  : 07-19-2024
 * @last modified by  : MTX Group Product Team
**/
public with sharing class LPI_AssessmentTaskController {
    
    public static final string PICKLIST_TYPE = 'Picklist';
    public static final string INPROGRESS_TEXT = 'InProgress';
    public static final string VIOLATION_TEXT = 'Violation';
    public static final string MULTI_SELECT_PICKLIST = 'Multi-Select Picklist';
    public static final String NOT_APPLICABLE = 'Not Applicable';
    public static final String SUPPORT_STAFF = 'Support Staff';
    public static final String BOARD_STAFF = 'Board Staff';
    public static final String PORTAL_USER = 'Portal User';
    private static final String NUMBER_TXT = 'Number';


    public class ParamsWrapper {
        @AuraEnabled public List<String> assessmentTasks;
        @AuraEnabled public Boolean isPortalUser;
        @AuraEnabled public String profileName;

        public ParamsWrapper(List<String> assessmentTasks, Boolean isPortalUser,String profileName) {
            this.assessmentTasks = assessmentTasks;
            this.isPortalUser = isPortalUser;
            this.profileName = profileName;
        } 
    }

    /**
         * @author                      : MTX Group Product Team
         * @since                       : 6 Oct 2023
         * @description                 : Method used to Fetch Inspection Questions List for the Portal User.
         * @param assessmentTasks       : List of Assessment Tasks
         * @return                      : `Map<Id,List<LPI_Wrapper.AssessmentTaskWrapper>>`
         * @last modified by            : MTX Group Product Team
         * @last modified date          : 6 Oct 2023
         * @modified details            : Code Review Fixes
         * @modified details            : Refactoring Code 
     */
    @AuraEnabled
    public static Map<Id,List<LPI_Wrapper.AssessmentTaskWrapper>> getInspectionQuestionsList(List<String> assessmentTasks) {
        try {
            if(assessmentTasks.isEmpty()){
                return null;
            }
            List<User> userRecList = LPI_UserDao.getCurrentUserRecord();
            if(userRecList.isEmpty()){
                return null;
            }
            
            String currUserProfile = LPI_ProfileDao.getProfileByDymanicQuery('Id,Name','Id =\'' + UserInfo.getProfileId() +'\'',null,null,null)[0]?.Name;

            Map<Id,List<LPI_Wrapper.AssessmentTaskWrapper>> mapToSend = populateAssessmentTaskWrapper(
                new ParamsWrapper(
                    assessmentTasks,
                    (currUserProfile == PORTAL_USER || currUserProfile == BOARD_STAFF),
                    currUserProfile
                )
            );
            return mapToSend;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

     /**
         * @author                      : MTX Group Product Team
         * @since                       : 6 Oct 2023
         * @description                 : This Method is used to encapsulate the logic for Populating AssessmentTaskWrapper.
         * @param obj                   : ParamsWrapper obj
         * @return                      : `Map<Id,List<LPI_Wrapper.AssessmentTaskWrapper>>`
         * @last modified by            : MTX Group Product Team
         * @last modified date          : 6 Oct 2023
         * @modified details            : Code Review Fixes
         * @modified details            : Refactoring Code 
     */
    private static Map<Id,List<LPI_Wrapper.AssessmentTaskWrapper>> populateAssessmentTaskWrapper(ParamsWrapper obj) {
        try {

            String fields = 'Id,AssessmentTask.Parent.Status__c,AssessmentIndDefinition.Hide_Comments__c,AssessmentTask.Parent.Business_Name__c,AssessmentTask.Parent.Actual_Start_Date__c,AssessmentTask.Parent.VisitType.Name,AssessmentTask.Parent.ContextId,AssessmentTask.Parent.name,AssessmentIndDefinition.Does_Not_Account_For_Violation__c,AssessmentIndDefinitionId,AssessmentIndDefinition.Question_Text__c,AssessmentTask.ParentId,'+
                'AssessmentTask.Board_Name__c,AssessmentIndDefinition.Name,Comments__c,AssessmentIndDefinition.DataType,Text_Area_Field_Response__c,NumberFieldResponse,'+
                'TextFieldResponse,AssessmentTask.Parent.License_Type__c,AssessmentTask.Parent.Account.Name,TYPEOF  AssessmentTask.Parent.Context when Businesslicense then ContactId,Name,Legacy_License_Number__c WHEN Case THEN License_Number__c, Business_License_Id__c,Account.IsPersonAccount,Account.FirstName,Account.LastName,Account.MiddleName,Account.Suffix,Account.Social_Security_Number__c WHEN BUSINESSLICENSEAPPLICATION THEN Name,ApplicantId END ,(SELECT ID ,SourceObjectId,AssessmentIndDefinedValueId FROM SourceObjects)';
            String whereClause = 'AssessmentTaskId IN ' + LPI_ServiceUtility.getStringValuesByList(obj.assessmentTasks) ;
            Map<Id,LPI_Wrapper.AssessmentTaskWrapper> insIdToAssessmentTaskWrapperMap = new Map<Id,LPI_Wrapper.AssessmentTaskWrapper>();
            Set<String> parentQuestionSet = new Set<String>();
            List<AssessmentIndValue> aivList = new List<AssessmentIndValue>();
             
            Map<Id,List<LPI_Wrapper.AssessmentTaskWrapper>> visitIdToInsAssessmentIndListMap = new Map<Id,List<LPI_Wrapper.AssessmentTaskWrapper>>();

            List<InspectionAssessmentInd> inspecAssessIndList;
                
             
            inspecAssessIndList = (new LPI_InspectionAssessmentIndDAO.LPI_InspectionAssessIndWithoutSharingDAO()).getInspectionAssessmentIndicatorByDymanicQuery(fields,whereClause,null,'DisplayOrder','ASC');

            List<String> boardNameList = new List<String>();
            Map<String,String> stringToConfigMetadata = new  Map<String,String>();
            if(obj.isPortalUser == null || !obj.isPortalUser){
                for(InspectionAssessmentInd iai :inspecAssessIndList ){
                    boardNameList.add(iai.AssessmentTask.Board_Name__c);
                }
            }
            
             
            Date todayDate = Date.today();
            List<String> questionsToRemoveComments = new List<String>{
                'SUPERVISING PHARMACIST LICENSE #'
                ,'SUPERVISING PHARMACIST',
                'FACILITY PERSONNEL PRESENT FOR INSPECTION'
            };
            for(InspectionAssessmentInd inspectionAssessmentIndRec : inspecAssessIndList) {
                LPI_Wrapper.AssessmentTaskWrapper wrapper = new LPI_Wrapper.AssessmentTaskWrapper(); 
                wrapper.questionId = inspectionAssessmentIndRec.Id;  
                wrapper.boardName = inspectionAssessmentIndRec.AssessmentTask.Board_Name__c;
                wrapper.documentDate = todayDate.month() + '-' + todayDate.day() + '-' + todayDate.year();
                wrapper.assessmentTaskId = inspectionAssessmentIndRec.AssessmentTaskId;  
                wrapper.questionName = inspectionAssessmentIndRec.AssessmentIndDefinition.Question_Text__c;  
                wrapper.hideComment = questionsToRemoveComments.contains(wrapper.questionName) && inspectionAssessmentIndRec.AssessmentTask.Parent.License_Type__c == 'Drug Outsourcer';
                wrapper.comment = inspectionAssessmentIndRec.Comments__c;  
                wrapper.visitId = inspectionAssessmentIndRec.AssessmentTask.ParentId;  
                wrapper.parentQuesId = inspectionAssessmentIndRec.AssessmentIndDefinitionId;  
                wrapper.doesNotaccountForViolation = inspectionAssessmentIndRec.AssessmentIndDefinition.Does_Not_Account_For_Violation__c;
                wrapper.dataType = inspectionAssessmentIndRec.AssessmentIndDefinition.DataType;
                wrapper.numberValue = inspectionAssessmentIndRec.AssessmentTask.Parent.name;
                wrapper.twoByTwoPhotoRecommendation =  System.Label.TwoByTwoPhotoRecommendations;
                wrapper.readOnly = (obj.profileName == SUPPORT_STAFF) || inspectionAssessmentIndRec.AssessmentTask.Parent.Status__c == 'Completed' ||  inspectionAssessmentIndRec.AssessmentTask.Parent.Status__c == 'Closed';
                wrapper.hideComments = inspectionAssessmentIndRec.AssessmentIndDefinition.Hide_Comments__c;

                wrapper.inspectionDate =inspectionAssessmentIndRec.AssessmentTask.Parent.Actual_Start_Date__c!= null ? String.valueOf(inspectionAssessmentIndRec.AssessmentTask.Parent.Actual_Start_Date__c.year() + '-'+String.valueOf(inspectionAssessmentIndRec.AssessmentTask.Parent.Actual_Start_Date__c.month()).leftPad(2, '0')+'-'+String.valueOf(inspectionAssessmentIndRec.AssessmentTask.Parent.Actual_Start_Date__c.day()).leftPad(2, '0')) : String.valueOf(Date.today().year()+'-'+String.valueOf(Date.today().month()).leftPad(2, '0')+'-'+String.valueOf(Date.today().day()).leftPad(2, '0'));
                wrapper.description =inspectionAssessmentIndRec.AssessmentTask.Parent.VisitType.Name;
                wrapper.licenseNumber =inspectionAssessmentIndRec.AssessmentTask.Parent.Context instanceof BusinessLicense ? ((BusinessLicense)inspectionAssessmentIndRec.AssessmentTask.Parent.Context).Legacy_License_Number__c != NULL ? ((BusinessLicense)inspectionAssessmentIndRec.AssessmentTask.Parent.Context).Legacy_License_Number__c : ((BusinessLicense)inspectionAssessmentIndRec.AssessmentTask.Parent.Context).Name : inspectionAssessmentIndRec.AssessmentTask.Parent.Context instanceof Case ?  ((Case)inspectionAssessmentIndRec.AssessmentTask.Parent.Context).License_Number__c : inspectionAssessmentIndRec.AssessmentTask.Parent.Context instanceof BUSINESSLICENSEAPPLICATION ?  ((BUSINESSLICENSEAPPLICATION)inspectionAssessmentIndRec.AssessmentTask.Parent.Context).Name.substringAfter('-')  : '';
                wrapper.scanDate =  String.valueOf(Date.today().year() + '-'+String.valueOf(Date.today().month()).leftPad(2,'0')+'-'+String.valueOf(Date.today().day()).leftPad(2,'0'));
                wrapper.entityName = inspectionAssessmentIndRec.AssessmentTask.Parent.Business_Name__c;
                wrapper.accountName = inspectionAssessmentIndRec.AssessmentTask.Parent.Account.Name;
                 

                Boolean accountDetailPoplated = false;
                if(inspectionAssessmentIndRec.AssessmentTask.Parent.Context instanceof Case && ((Case)inspectionAssessmentIndRec.AssessmentTask.Parent.Context).Account.IsPersonAccount ){
                    accountDetailPoplated = true;
                    populateAccountDetails(((Case)inspectionAssessmentIndRec.AssessmentTask.Parent.Context).Account,wrapper);
                }
                if(inspectionAssessmentIndRec.AssessmentTask.Parent.contextId != null){
                    for(ComplaintCase cc : LPI_ComplaintCaseDao.fetchComplaintCaseRecords('Id,PublicComplaint.Name','CaseId = \''+String.escapeSingleQuotes(inspectionAssessmentIndRec.AssessmentTask.Parent.contextId) + '\'',null,null)){
                        wrapper.complaintNumber = cc.PublicComplaint.Name.substringAfter('-');
                    }
                }
                if(inspectionAssessmentIndRec.AssessmentTask.Parent.Context instanceof Case && String.isNotBlank(((Case)inspectionAssessmentIndRec.AssessmentTask.Parent.Context).Business_License_Id__c)){
                    String contactId;
                    for(BusinessLicense bl : LPI_BusinessLicenseDAO.fetchBusinessLicenseRecords('Id,ContactId,RegulatoryAuthorizationType.Authorisation_Type__c,Business_Entity_Name__c,name,Legacy_License_Number__c,Pre_Licensure_Number__c, RegulatoryAuthorizationType.Profession_Code__c ', 'Id = \''+String.escapeSingleQuotes(((Case)inspectionAssessmentIndRec.AssessmentTask.Parent.Context).Business_License_Id__c) + '\'')){
                        contactId = bl.ContactId;
                    }
                    if(!accountDetailPoplated && String.isNotBlank(contactId)){
                        for(Account accNew : LPI_AccountDAO.getAccountListByDynamicQuery(new List<String>{'Id,firstname,middlename,lastname,suffix,Social_Security_Number__c'},'PersonContactId = \'' + String.escapeSingleQuotes(contactId) + '\'',null,null,null)){
                            populateAccountDetails(accNew,wrapper);
                        }
                    } 
                }else if((inspectionAssessmentIndRec.AssessmentTask.Parent.Context instanceof BusinessLicense &&  String.isNotBlank(((BusinessLicense)inspectionAssessmentIndRec.AssessmentTask.Parent.Context).ContactId)) || (inspectionAssessmentIndRec.AssessmentTask.Parent.Context instanceof BusinessLicenseApplication && String.isNotBlank(((BusinessLicenseApplication)inspectionAssessmentIndRec.AssessmentTask.Parent.Context).ApplicantId))){
                    String contactId = inspectionAssessmentIndRec.AssessmentTask.Parent.Context instanceof BusinessLicense  ? ((BusinessLicense)inspectionAssessmentIndRec.AssessmentTask.Parent.Context).ContactId : ((BusinessLicenseApplication)inspectionAssessmentIndRec.AssessmentTask.Parent.Context).ApplicantId;
                    if(String.isNotBlank(contactId)){
                        for(Account accNew : LPI_AccountDAO.getAccountListByDynamicQuery(new List<String>{'Id,firstname,middlename,lastname,suffix,Social_Security_Number__c'},'PersonContactId = \'' + String.escapeSingleQuotes(contactId) + '\'',null,null,null)){
                            populateAccountDetails(accNew,wrapper);
                        }
                    }   
                }

                if(String.isNotBlank(inspectionAssessmentIndRec.AssessmentTask.Parent.License_Type__c)){
                    for(RegulatoryAuthorizationType rat : new LPI_RegulatoryAuthorizationTypeDAO.LPI_RegulatoryAuthorizationTypeWithoutSharingDAO().getRegAuthTypeWithoutSecurity('Profession_Code__c', 'Name = \'' + inspectionAssessmentIndRec.AssessmentTask.Parent.License_Type__c +'\'', null, null, null)){
                        wrapper.profCode =rat.Profession_Code__c;
                    }
                }

                if(wrapper.dataType.equals(PICKLIST_TYPE)) {
                    parentQuestionSet.add(inspectionAssessmentIndRec.AssessmentIndDefinitionId);
                    
                    wrapper.value = inspectionAssessmentIndRec.SourceObjects.isEmpty() ?  null : inspectionAssessmentIndRec.SourceObjects[0].AssessmentIndDefinedValueId;
                } else if(wrapper.dataType.equals(MULTI_SELECT_PICKLIST)) {
                    parentQuestionSet.add(inspectionAssessmentIndRec.AssessmentIndDefinitionId);
                    
                    aivList.addAll(inspectionAssessmentIndRec.SourceObjects);
                } else if(wrapper.dataType.equals(NUMBER_TXT)) {
                    
                    wrapper.numberResponseValue = inspectionAssessmentIndRec.NumberFieldResponse;
                } else {
                     
                    wrapper.value = inspectionAssessmentIndRec.Text_Area_Field_Response__c;
                }
                insIdToAssessmentTaskWrapperMap.put(inspectionAssessmentIndRec.Id,wrapper);

                if(!visitIdToInsAssessmentIndListMap.containsKey(inspectionAssessmentIndRec.AssessmentTask.ParentId)) {
                    visitIdToInsAssessmentIndListMap.put(inspectionAssessmentIndRec.AssessmentTask.ParentId,new List<LPI_Wrapper.AssessmentTaskWrapper>());
                }
                visitIdToInsAssessmentIndListMap.get(inspectionAssessmentIndRec.AssessmentTask.ParentId).add(wrapper);  
            }
             
            for(AssessmentIndValue responseRec : aivList) {
                if(!insIdToAssessmentTaskWrapperMap.containsKey(responseRec.SourceObjectId)) {
                    insIdToAssessmentTaskWrapperMap.get(responseRec.SourceObjectId).value = responseRec.AssessmentIndDefinedValueId;
                } else {
                    insIdToAssessmentTaskWrapperMap.get(responseRec.SourceObjectId).value += (';' + responseRec.AssessmentIndDefinedValueId);
                }
            }
            Map<Id,List<LPI_Wrapper.OptionWrapper>> assessmentIndDefToOptionsMap = new Map<Id,List<LPI_Wrapper.OptionWrapper>>();

             
            if(!parentQuestionSet.isEmpty()) {
                fields = 'Id,Value,AssessmentIndicatorDefinitionId';
                whereClause = 'AssessmentIndicatorDefinitionId IN ' + LPI_ServiceUtility.getStringValuesByStringSet(parentQuestionSet);

                List<AssessmentIndDefinedValue> aidValList;

                 
                if(obj.isPortalUser!=null && obj.isPortalUser) {
                    aidValList = (new LPI_AssessmentIndDefinedValueDAO.LPI_AssessmentIndDefinedValueWithoutsharingDAO()).getAssessmentIndDefinedValueByDymanicQuery(fields,whereClause,null,'SequenceNumber','ASC');
                } else {
                    aidValList = LPI_AssessmentIndDefinedValueDAO.getAssessmentIndDefinedValueByDymanicQuery(fields,whereClause,null,'SequenceNumber','ASC');
                }

                for(AssessmentIndDefinedValue assessmentIndicatorDefValue : aidValList) {
                    if(!assessmentIndDefToOptionsMap.containsKey(assessmentIndicatorDefValue.AssessmentIndicatorDefinitionId)) {
                        assessmentIndDefToOptionsMap.put(assessmentIndicatorDefValue.AssessmentIndicatorDefinitionId,new List<LPI_Wrapper.OptionWrapper>());
                    }
                    LPI_Wrapper.OptionWrapper optionObj = new LPI_Wrapper.OptionWrapper();
                    optionObj.label = assessmentIndicatorDefValue.Value;
                    optionObj.value = assessmentIndicatorDefValue.Id;
                    assessmentIndDefToOptionsMap.get(assessmentIndicatorDefValue.AssessmentIndicatorDefinitionId).add(optionObj);
                }
            }
             
            for( Id assessmentIndQuesId : insIdToAssessmentTaskWrapperMap.keySet()) {
                LPI_Wrapper.AssessmentTaskWrapper valObj = insIdToAssessmentTaskWrapperMap.get(assessmentIndQuesId);
                if(valObj.parentQuesId==null){ 
                    continue;
                }
                if(assessmentIndDefToOptionsMap.containsKey(valObj.parentQuesId)) {
                    insIdToAssessmentTaskWrapperMap.get(assessmentIndQuesId).options = assessmentIndDefToOptionsMap.get(valObj.parentQuesId);
                }
            }

            if(obj.isPortalUser!=null && !obj.isPortalUser) {
                
                attachUploadedDocs(insIdToAssessmentTaskWrapperMap);
            } 

            return visitIdToInsAssessmentIndListMap;
        }
        catch(Exception ex) {
            LPI_ExceptionManager.logException(
                'LPI_AssessmentTaskController',
                'populateAssessmentTaskWrapper',
                ex
            );
            throw new LPI_Exception(ex.getMessage());
        }
    }

    public static void populateAccountDetails(Account acc,LPI_Wrapper.AssessmentTaskWrapper wrapper){
        wrapper.firstName = acc.firstName;
        wrapper.lastName = acc.lastName;
        wrapper.middleName = acc.middleName;
        wrapper.suffixName = acc.suffix;
        wrapper.ssn = acc.Social_Security_Number__c;
    }

    /**
         * @author                                  : MTX Group Product Team
         * @since                                   : 6 Oct 2023
         * @description                             : This Method used to upload docs on Linkedentity id, which is InspectionAssessmentIndicator.
         * @param cdlLinksList                      : ParamsWrapper obj
         * @param insIdToAssessmentTaskWrapperMap   : Inspection Assesment Id to Its Wrapper Map
         * @return                                  : `void`
         * @last modified by                        : MTX Group Product Team
         * @last modified date                      : 6 Oct 2023
         * @modified details                        :  Code Review Fixes
         * @modified details                        : Refactoring Code 
     */
    private static void attachUploadedDocs(Map<Id,LPI_Wrapper.AssessmentTaskWrapper> insIdToAssessmentTaskWrapperMap) {
        if(insIdToAssessmentTaskWrapperMap == null || insIdToAssessmentTaskWrapperMap.isEmpty()) {
            return;
        }
        for(Application_Document__c appDoc : LPI_ApplicationDocumentDAO.getApplicantDocumentByDymanicQuery('Id,File_Name__c,Onbase_Document_Id__c,Inspection_Assessment_Indicator__c','Inspection_Assessment_Indicator__c IN ' + LPI_ServiceUtility.getStringValuesBySet(insIdToAssessmentTaskWrapperMap.keySet()),null,null,null)){
            LPI_Wrapper.FileWrapper file = new LPI_Wrapper.FileWrapper();
            file.fileName = appDoc.File_Name__c;
            file.fileId = appDoc.Onbase_Document_Id__c;
            file.parentRecId = appDoc.Id;
            insIdToAssessmentTaskWrapperMap.get(appDoc.Inspection_Assessment_Indicator__c).filesList.add(file);
        }
    }

    /**
         * @author                                  : MTX Group Product Team
         * @since                                   : 6 Oct 2023
         * @description                             : This method is used to fetch Inspection > Assesment Task Questions based on Assessment Task Id. for internal users
         * @param recordId                          : recordId/AssessmentTaskId  
         * @return                                  : `List<LPI_Wrapper.AssessmentTaskWrapper>`
         * @last modified by                        : MTX Group Product Team
         * @last modified date                      : 6 Oct 2023
         * @modified details                        :  Code Review Fixes
         * @modified details                        : Refactoring Code 
     */
    @AuraEnabled
    public static List<LPI_Wrapper.AssessmentTaskWrapper> getInspectionQuestions(String recordId){
        try {
            if(String.isBlank(recordId)){
                return null;
            }
             
            String currUserProfile = LPI_ProfileDao.getProfileByDymanicQuery('Id,Name','Id =\'' + UserInfo.getProfileId() +'\'',null,null,null)[0]?.Name;

            if(String.isBlank(currUserProfile)){
                return null;
            }

            Map<Id,List<LPI_Wrapper.AssessmentTaskWrapper>> mapToSend = populateAssessmentTaskWrapper(
                    new ParamsWrapper(
                        new List<String>{recordId},
                        (currUserProfile == PORTAL_USER || currUserProfile == BOARD_STAFF),
                        currUserProfile
                    )
            );

            if(mapToSend!=null && !mapToSend.values()?.isEmpty()) {
                return mapToSend.values().get(0);
            }

            return null;

        } catch (Exception e) {
            LPI_ExceptionManager.logException(
                'LPI_AssessmentTaskController',
                'getInspectionQuestions',
                e
            );
            throw new LPI_Exception(e.getMessage());
        }
    }

    /**
         * @author                                  : MTX Group Product Team
         * @since                                   : 6 Oct 2023
         * @description                             : This method is used to save user responses to inspection assessment indicator from portal or BE.
         * @param jsonData                          : Contains JSON data for Assemsnet TaskWrapper.  
         * @return                                  : `void`
         * @last modified by                        : MTX Group Product Team
         * @last modified date                      : 6 Oct 2023
         * @modified details                        :  Code Review Fixes
         * @modified details                        : Refactoring Code 
     */
    @AuraEnabled
    public static void handleSaveInspectionQues(String jsonData){
        try {
            
            if(String.isBlank(jsonData)){
                return;
            }
             
            String currUserProfile = LPI_ProfileDao.getProfileByDymanicQuery('Id,Name','Id =\'' + UserInfo.getProfileId() +'\'',null,null,null)[0]?.Name;

             
            Boolean isPortalUser  =  (currUserProfile == PORTAL_USER  || currUserProfile == BOARD_STAFF);  

            List<LPI_Wrapper.AssessmentTaskWrapper> wrapperList = (List<LPI_Wrapper.AssessmentTaskWrapper>)JSON.deserialize(jsonData, List<LPI_Wrapper.AssessmentTaskWrapper>.class);
           
            Set<String> inspectionAssessmentIndIdSet = new Set<String>();
            for(LPI_Wrapper.AssessmentTaskWrapper wrapper : wrapperList){
                inspectionAssessmentIndIdSet.add(wrapper.questionId);
            }
            
            String fields;
            String whereClause;
            Map<Id,AssessmentIndValue> questionIdToOptionRecordMap = new Map<Id,AssessmentIndValue>();
            Map<Id,Set<String>> questionIdToValueIdsMap = new Map<Id,Set<String>>();
            List<AssessmentIndValue> aivOldRecs = new List<AssessmentIndValue>();
            if(!inspectionAssessmentIndIdSet.isEmpty()){
                fields = 'Id,SourceObjectId,AssessmentIndDefinedValueId,AssessmentIndDefinedValue.AssessmentIndicatorDefinition.DataType';
                whereClause = 'SourceObjectId IN' + LPI_ServiceUtility.getStringValuesByStringSet(inspectionAssessmentIndIdSet);

                List<AssessmentIndValue> assessmentIndValList;

                if(isPortalUser) {  
                    assessmentIndValList = (new LPI_AssessmentIndValueDAO.LPI_AssessmentIndValueWithoutSharingDAO()).getAssessmentIndValueByDymanicQuery(fields,whereClause,null,null,null);
                } else {
                    assessmentIndValList = LPI_AssessmentIndValueDAO.getAssessmentIndValueByDymanicQuery(fields,whereClause,null,null,null);
                }
                
                for(AssessmentIndValue aiv : assessmentIndValList){
                    aivOldRecs.add(aiv);
                    questionIdToOptionRecordMap.put(aiv.SourceObjectId,aiv);
                    if(!questionIdToValueIdsMap.containsKey(aiv.SourceObjectId)){
                        questionIdToValueIdsMap.put(aiv.SourceObjectId,new Set<String>());
                    }
                    questionIdToValueIdsMap.get(aiv.SourceObjectId).add(aiv.AssessmentIndDefinedValueId);
                }
            }
            
            Map<Id,Id> assessmentIndDefToViolationTypeAssessmentIndDef = new Map<Id,Id>();
            List<AssessmentIndValue> aiaListToUpsert = new List<AssessmentIndValue>();
            List<InspectionAssessmentInd> iaiListToUpdate = new List<InspectionAssessmentInd>();
            String assessmentTaskId;
            List<RegulatoryCodeViolation> rcvListToInsert = new List<RegulatoryCodeViolation>();
            String assessmentResult;
            List<String> mupltiPickListAnsList = new List<String>();
            Set<Id> assessmentIndDefValueIdSet = new Set<Id>();
            Map<String,String> parentQuesToChildQuesMap = new Map<String,String>();
            for(LPI_Wrapper.AssessmentTaskWrapper wrapper : wrapperList) {
                assessmentTaskId = wrapper.assessmentTaskId;
                InspectionAssessmentInd inspectionAssessmentInd = new InspectionAssessmentInd();
                inspectionAssessmentInd.Comments__c = wrapper.comment;
                inspectionAssessmentInd.Id = wrapper.questionId;
                parentQuesToChildQuesMap.put(wrapper.parentQuesId,wrapper.questionId);
                assessmentResult = wrapper.options != null && !wrapper.options.isEmpty() && wrapper.doesNotaccountForViolation != NULL && !wrapper.doesNotaccountForViolation  ? 'Pass' : 'NA';
                if(wrapper.dataType == 'DateTime'){
                    inspectionAssessmentInd.DateTimeFieldResponse = wrapper.dateTimeValue;
                }
                else if(wrapper.dataType == NUMBER_TXT) {
                    inspectionAssessmentInd.NumberFieldResponse = wrapper.numberResponseValue;
                }
                else if(wrapper.options == null || wrapper.options.isEmpty()){
                    inspectionAssessmentInd.Text_Area_Field_Response__c = wrapper.value;
                    inspectionAssessmentInd.TextFieldResponse = String.isNotBlank(inspectionAssessmentInd.Text_Area_Field_Response__c) ? inspectionAssessmentInd.Text_Area_Field_Response__c.length() < 256 ? inspectionAssessmentInd.Text_Area_Field_Response__c.subString(0,inspectionAssessmentInd.Text_Area_Field_Response__c.length()) : inspectionAssessmentInd.Text_Area_Field_Response__c.subString(0,255) : null;
                }else if(wrapper.dataType == PICKLIST_TYPE &&(!questionIdToOptionRecordMap.containsKey(wrapper.questionId) || (wrapper.value != questionIdToOptionRecordMap.get(wrapper.questionId).AssessmentIndDefinedValueId))){
                    assessmentResult = wrapper.optionLabel == NOT_APPLICABLE ? 'NA' : assessmentResult;
                    AssessmentIndValue aiv = new AssessmentIndValue(Id =  questionIdToOptionRecordMap.get(wrapper.questionId)?.Id,AssessmentIndDefinedValueId = wrapper.value,SourceObjectId=wrapper.questionId);
                    aiaListToUpsert.add(aiv);
                }
                else if(wrapper.dataType == PICKLIST_TYPE &&(questionIdToOptionRecordMap.containsKey(wrapper.questionId)  && wrapper.value == questionIdToOptionRecordMap.get(wrapper.questionId).AssessmentIndDefinedValueId)){
                    assessmentResult = wrapper.optionLabel == NOT_APPLICABLE ? 'NA' : assessmentResult;
                    assessmentIndDefValueIdSet.add( wrapper.value);
                }
                else if(wrapper.dataType == MULTI_SELECT_PICKLIST && String.isNotBlank(wrapper.multiPicklistValue)){
                    mupltiPickListAnsList.addAll(wrapper.multiPicklistValue.split(';'));
                }
                if(wrapper.options != null && !wrapper.options.isEmpty() && wrapper.isViolationDone != null && wrapper.isViolationDone){
                    assessmentResult = 'Fail';
                }
                
                inspectionAssessmentInd.Result = assessmentResult;
                iaiListToUpdate.add(inspectionAssessmentInd);
                 
            }
           
            if(!mupltiPickListAnsList.isEmpty()){

                List<AssessmentIndDefinedValue> assessmentIndDfValList;

                if(isPortalUser) {
                    assessmentIndDfValList = (new LPI_AssessmentIndDefinedValueDAO.LPI_AssessmentIndDefinedValueWithoutsharingDAO()).getAssessmentIndDefinedValueByDymanicQuery('Id,AssessmentIndicatorDefinitionId','ID IN ' + LPI_ServiceUtility.getStringValuesByList(mupltiPickListAnsList),NULL,NULL,NULL);
                } else {
                    assessmentIndDfValList = LPI_AssessmentIndDefinedValueDAO.getAssessmentIndDefinedValueByDymanicQuery('Id,AssessmentIndicatorDefinitionId','ID IN ' + LPI_ServiceUtility.getStringValuesByList(mupltiPickListAnsList),NULL,NULL,NULL);
                }
                 
                for(AssessmentIndDefinedValue aidv : assessmentIndDfValList) {
                    assessmentIndDefValueIdSet.add( aidv.Id);
                    if(questionIdToValueIdsMap.containsKey(parentQuesToChildQuesMap.get(aidv.AssessmentIndicatorDefinitionId)) && questionIdToValueIdsMap.get(parentQuesToChildQuesMap.get(aidv.AssessmentIndicatorDefinitionId)).contains(aidv.Id)){
                        continue;
                    }
                    AssessmentIndValue aiv = new AssessmentIndValue(AssessmentIndDefinedValueId =aidv.Id,SourceObjectId=parentQuesToChildQuesMap.get(aidv.AssessmentIndicatorDefinitionId));
                    aiaListToUpsert.add(aiv);
                }
                 
            }
            List<AssessmentIndValue> deleteList = new List<AssessmentIndValue>();
            for(AssessmentIndValue aiv : aivOldRecs){
                if(aiv.AssessmentIndDefinedValue.AssessmentIndicatorDefinition.DataType == MULTI_SELECT_PICKLIST && !assessmentIndDefValueIdSet.contains(aiv.AssessmentIndDefinedValueId)){
                    deleteList.add(aiv);
                }
            }
             
            if(isPortalUser) {
                LPI_WithoutSharingUtility.upsertSObjectList(aiaListToUpsert);
                LPI_WithoutSharingUtility.updateSObjectList(iaiListToUpdate);
                LPI_WithoutSharingUtility.deleteSObject(deleteList);    

            } else {
                LPI_DML.doUpsert(aiaListToUpsert);
                LPI_DML.doUpdate(iaiListToUpdate);
                LPI_DML.doDelete(deleteList);
            }
            updateTaskStatus(assessmentTaskId,LPI_LiteralConstant.Inspection_Status_COMPLETED); 
             
        } catch (Exception e) {
            LPI_ExceptionManager.logException(
                'LPI_AssessmentTaskController',
                'handleSaveInspectionQues',
                e
            );
            throw new LPI_Exception(e.getMessage());
        }
    }

    /**
         * @author                                  : MTX Group Product Team
         * @since                                   : 6 Oct 2023
         * @description                             : This method is used to update the task status to completed.
         * @param recordId                          : Contains RecordID
         * @param status                            : Status to update.
         * @param isPortalUser                      : to differentiate portal user. 
         * @return                                  : `void`
         * @last modified by                        :MTX Group Product Team
         * @last modified date                      : 6 Oct 2023
         * @modified details                        :  Code Review Fixes
         * @modified details                        : Refactoring Code 
     */
    @AuraEnabled
    public static void updateTaskStatus(Id recordId,String status){
        try{
            String fields = 'Id';
            String whereClause = 'Id = \'' + String.escapeSingleQuotes(recordId) +  '\' AND Status != \'' + String.escapeSingleQuotes(status) + '\'';
            List<AssessmentTask> assessmentTaskList; 
            
            String currUserProfile = LPI_ProfileDao.getProfileByDymanicQuery('Id,Name','Id =\'' + UserInfo.getProfileId() +'\'',null,null,null)[0]?.Name;

            
            Boolean isPortalUser  =  (currUserProfile == PORTAL_USER  || currUserProfile == BOARD_STAFF);  

            if(isPortalUser!=null && isPortalUser) {
                assessmentTaskList = (new LPI_AssessmentTaskDAO.LPI_AssessmentTaskWithoutSharingDAO()).getAssessmentTaskListByDynamicQuery(fields,whereClause,null,null,null);
            } else {
                assessmentTaskList = LPI_AssessmentTaskDAO.getAssessmentTaskListByDynamicQuery(fields,whereClause,null,null,null);
            }
            if(assessmentTaskList.isEmpty()){
                return;
            }
            AssessmentTask assessmentTaskRec = new AssessmentTask();
            assessmentTaskRec.Id = recordId;
            assessmentTaskRec.Status = status;
            if(isPortalUser!=null && isPortalUser) {
                LPI_WithoutSharingUtility.updateSObject(assessmentTaskRec);
            } else {
                LPI_DML.doUpdate(assessmentTaskRec);
            }
        }
        catch (Exception e) {
            LPI_ExceptionManager.logException(
                'LPI_AssessmentTaskController',
                'updateTaskStatus',
                e
            );
            throw new LPI_Exception(e.getMessage());
        }

    }
}