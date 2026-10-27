/**
 * @description       : 
 * @author            : MTX Group Product Team
 * @group             : 
 * @last modified on  : 05-07-2024
 * @last modified by  : MTX Group Product Team
**/
public with sharing class LPI_DecisionTreeQuestionsController {
    
    private final static String reAppraiserErrorMsg = 'A trainee application has already been submitted or a draft application has been created. Go to My Applications section on Dashboard in order to access it.';
    private final static Set<String> setActionAllowedValidationExceptionRatSet = new Set<String>{
        'Temporary Real Estate Appraiser'
    };

    /**
    * Description : Get All Question Details records related to the Application Id passed 
    * @author : MTX Group Product Team
    * @param : ProfessionName 
    * @return : List<QuestionDetailsWrapper>
    */
    @AuraEnabled
    public static Map<String,Object> getQuestionDetails(String professionId, String language){
        try{
            Boolean useFrench = String.isNotBlank(language) && language.startsWith('fr');
            String queryFields = ' Id,System_Validation_Needed__c,Name,Examination_Check__c,Fail_Verbiage__c,Pass_Verbiage__c,Regulatory_Authorization_Type__c';
            String whereClause = ' Id = \''+ professionId +'\'';
            List<Profession__c> profList =  LPI_ProfessionDAO.getProfessionByDymanicQuery(
                queryFields,whereClause,null,'Name','asc');
            String systemResponsePar = 'Not Needed';
            Map<string,Object> mainExamResponse = new Map<String,Object>();
            if(!profList.isEmpty() && profList[0].System_Validation_Needed__c){
                List<String> ratIdList = new List<String>();
                Id validRecordTypeId = Schema.SObjectType.System_Validation__c.getRecordTypeInfosByName().get('Validation').getRecordTypeId();
                Map<String,System_Validation__c> valueWithValidMap = new Map<String,System_Validation__c>();
                for(System_Validation__c sysValidList : LPI_SystemValidationDAO.getSystemValidByDymanicQuery(
                    'Id,Regulatory_Authorization_Type__c,RecordTypeId,Response_Type__c,Response_Value__c,Error_Message__c',
                    'Profession__c = \'' + profList[0].Id + '\' AND Question_Detail__c = null',null,null,null)){
                                                            if(validRecordTypeId == sysValidList.RecordTypeId){
                                                                    ratIdList.add(sysValidList.Regulatory_Authorization_Type__c);
                                                            }else{
                                                                    valueWithValidMap.put(sysValidList.Response_Value__c,sysValidList);
                                                            }
                                                        }
                                                        
                if(!ratIdList.isEmpty()){
                    String systemResponse = checkSystemValidationForMultiple(ratIdList);
                    if(systemResponse == 'No' && new Set<String>{'Veterinarian'}.contains(profList[0].Name)){
                        systemResponse = setActionAllowedValidation(ratIdList);
                    } 
                    if(valueWithValidMap.containsKey(systemResponse) && valueWithValidMap.get(systemResponse).Response_Type__c == 'Launch Flow'){
                        String responseApp = createApplication(new Map<String,Object>{
                            'type' => 'New',
                            'regAuthId' => valueWithValidMap.get(systemResponse).Regulatory_Authorization_Type__c
                        });
                        return new Map<String,Object>{
                            'openFLow' => true,
                            'showError' => false,
                            'responseValue' => responseApp
                        };
                    }
                    else{
                        if(valueWithValidMap.containsKey(systemResponse) && valueWithValidMap.get(systemResponse).Response_Type__c == 'Decision Tree'){
                            systemResponsePar = systemResponse;
                        }else{
                            if(valueWithValidMap.containsKey(systemResponse) && valueWithValidMap.get(systemResponse).Response_Type__c == 'Error message'){
                                return new Map<String,Object>{
                                    'showError' => true,
                                    'errorMessage' => valueWithValidMap.get(systemResponse).Error_Message__c
                                };
                            }
                        }
                    }  
                } 
                if(!profList.isEmpty() && profList[0].Examination_Check__c)
                { 
                    mainExamResponse = new Map<String,Object>();

                    Map<String,Object> examResponse = examinationCheck(profList[0].Regulatory_Authorization_Type__c);
                    systemResponsePar = (String)examResponse.get('ExamResult');
                    String passVerbiage = profList[0].Pass_Verbiage__c;
                    String failVerbiage = profList[0].Fail_Verbiage__c;
                    if(systemResponsePar == 'Yes'){
                        if(passVerbiage!= null){
                            if (passVerbiage.contains('{Exam_Name}') && examResponse.containsKey('ExamName') && examResponse.get('ExamName') != null) {
                                passVerbiage = passVerbiage.replace('{Exam_Name}', (String)examResponse.get('ExamName'));
                            }
                            if (passVerbiage.contains('{Date_Taken}') && examResponse.containsKey('DateTaken') && examResponse.get('DateTaken') != null) {
                                passVerbiage = passVerbiage.replace('{Date_Taken}', string.valueOf(examResponse.get('DateTaken')));
                            }
                            mainExamResponse.put('examResult',(String)examResponse.get('ExamResult'));
                            mainExamResponse.put('passVerbiage',passVerbiage); 
                        }
                    }
                    else if(systemResponsePar == 'No')
                    {
                        mainExamResponse.put('examResult',(String)examResponse.get('ExamResult'));
                        mainExamResponse.put('failVerbiage',failVerbiage);
                    }
                }  
            }
            String questionDetailsFields = 'Id,Question_Description__c ,Answer_Type__c,Question_Values__c,Regulatory_Authorization_Type__c,System_Validation_Matching_Value__c,Error_message__c,Error_Matching_Value__c, Is_Required__c,Save_Response__c,Flow_Launch_Condition__c, Launch_Flow__c, Matching_Criteria__c, Matching_Value__c, Name, Order__c, Parent_Question__c, Parent_Question__r.name,Profession__c, Profession__r.name, Target_Field__c, Target_Object__c';
            String questionDetailsWhereClause = ' Profession__c = \'' + professionId + '\'';
            String orderBy = 'Order__c';
            List<QuestionDetailsWrapper> questionsList = new List<QuestionDetailsWrapper>();
            List<Question_Detail__c> questionDetailsList = LPI_QuestionDetailsDAO.getQuestionDetailsByDynamicQuery(questionDetailsFields,questionDetailsWhereClause,null,orderBy,null );
            String requiredSuffix = useFrench
                ? System.Label.get('', 'LP_DT_Error_Required_Suffix', 'fr')
                : System.Label.get('', 'LP_DT_Error_Required_Suffix', 'en_US');
            Map<String, String> frTextMap = useFrench ? buildDecisionTreeFrMap() : new Map<String, String>();
            for(Question_Detail__c question : questionDetailsList){
                QuestionDetailsWrapper questionWrapper = new QuestionDetailsWrapper();
                questionWrapper.showQuestion = true;
                if(String.isEmpty(question.Question_Description__c)){
                    questionWrapper.showQuestion = false;
                }
                questionWrapper.id = question.Id;
                questionWrapper.name = question.Name;
                questionWrapper.answerType = question.Answer_Type__c;
                questionWrapper.isRadio = false;
                questionWrapper.isPicklist = false;
                questionWrapper.showLabel = true;
                questionWrapper.isTextInput = false;
                if(question.Answer_Type__c == 'Radio'){
                    questionWrapper.isRadio = true;
                }else if(question.Answer_Type__c == 'Picklist'){
                    questionWrapper.isPicklist = true;
                }else if (question.Answer_Type__c =='Text'){
                    questionWrapper.isText = true;
                    questionWrapper.showLabel = false;
                }else if(question.Answer_Type__c =='Text Input'){
                    questionWrapper.isTextInput = true;
                    questionWrapper.forInputNamedPage = question.Question_Values__c;
                }
                questionWrapper.description = translateDecisionTreeHtml(
                    question.Question_Description__c,
                    useFrench,
                    frTextMap
                );
                if(String.isNotBlank(questionWrapper.description)){
                    questionWrapper.errorText = 'Error: ' + questionWrapper.description.stripHtmlTags() + ' ' + requiredSuffix;
                }
                questionWrapper.order =  Integer.valueOf(question.Order__c);
                questionWrapper.required = question.Is_Required__c;
                questionWrapper.targetField = question.Target_Field__c;
                questionWrapper.targetObject = question.Target_Object__c;
                questionWrapper.professionId = question.Profession__c;
                questionWrapper.allowLaunchFlow = question.Launch_Flow__c;
                questionWrapper.saveUserResponse = question.Save_Response__c;
                questionWrapper.errorMessage = translateDecisionTreePlain(
                    question.Error_message__c,
                    useFrench,
                    frTextMap
                );
                questionWrapper.errorMessageMatchingCondition = question.Error_Matching_Value__c;
                questionWrapper.questionValues = String.isEmpty(question.Question_Values__c)
                    ? new List<SelectOptionWrapper>()
                    : createOptionWrapper(question.Question_Values__c, useFrench ? frTextMap : null);
                if(question.Parent_Question__c != null && question.Matching_Value__c != null){
                    questionWrapper.questionConditionMeet = false;
                    questionWrapper.questionCondition = question.Matching_Value__c;
                    questionWrapper.questionDependentOn = question.Parent_Question__c;
                    questionWrapper.isQuestionDependent = true;
                    
                    if(question.Matching_Criteria__c == 'Not Equal To'){
                        questionWrapper.isMatchingCriteriaEqualTo = false;
                    } else{
                        questionWrapper.isMatchingCriteriaEqualTo = true;
                    }
                }else{
                    if((question.Parent_Question__c == null  && question.Matching_Criteria__c == null && question.Matching_Value__c == null)  || 
                        (question.Parent_Question__c == null && question.Matching_Value__c == systemResponsePar)){
                        questionWrapper.questionConditionMeet = true;
                        questionWrapper.questionCondition = '';
                        questionWrapper.questionDependentOn = '';
                        questionWrapper.isQuestionDependent = false;
                        questionWrapper.isMatchingCriteriaEqualTo = true;
                    }else{
                        questionWrapper.questionConditionMeet = false;
                        questionWrapper.questionCondition = '';
                        questionWrapper.questionDependentOn = '';
                        questionWrapper.isQuestionDependent = false;
                        questionWrapper.isMatchingCriteriaEqualTo = false;
                    }
                }
                questionWrapper.checkSystemValidation = false;
                if(!String.isEmpty(question.System_Validation_Matching_Value__c)){
                    questionWrapper.checkSystemValidation = true;
                    questionWrapper.systemValidMatchValue = question.System_Validation_Matching_Value__c;
                    questionWrapper.baseRatId = question.Regulatory_Authorization_Type__c;
                }
                questionsList.add(questionWrapper);  
            }
            
            return new Map<String,Object>{
                'openFLow' => false,
                'showError' => false,
                'questionsList' => questionsList,
                'professionName' => !profList.isEmpty() ? profList[0].Name : '',
                'examDetails' => mainExamResponse
            };
        } catch (Exception e) {
            LPI_ExceptionManager.logException('LPI_DecisionTreeQuestionsController', 'getQuestionDetails', e);
            throw new AuraHandledException(e.getMessage()+' '+e.getStackTraceString());    
        }
    }
    /**
    * @description 
    * @author MTX Group Product Team | 05-07-2024 
    * @param responseData 
    * @return String 
    **/
    @AuraEnabled
    public static String updateResponse(String responseData){
        try {
            List<QuestionDetailsWrapper> responseDataWrapper = (List<QuestionDetailsWrapper>)JSON.deserializeStrict(responseData,List<QuestionDetailsWrapper>.class);
            Map<String,String> questionWithResponseMap = new Map<String,String>();
            PreliminaryApplicationRef preRef = new PreliminaryApplicationRef();
            Id responseRecordTypeId = Schema.SObjectType.System_Response__c.getRecordTypeInfosByName().get('Response').getRecordTypeId();
            Id launchRecordTypeId = Schema.SObjectType.System_Response__c.getRecordTypeInfosByName().get('Launch Flow').getRecordTypeId();
            Id regAuthId;
            String regAuthTypeName;
            for(QuestionDetailsWrapper res:responseDataWrapper){
                questionWithResponseMap.put(res.id,res.userResponse);
            }
            for(System_Response__c systemRes : LPI_SystemResponseDao.getSystemResponseByDymanicQuery(
                'Id,Question_Detail__c, Response_Value__c, Response_Saving_JSON__c,RecordTypeId,Regulatory_Authorization_Type__c, Regulatory_Authorization_Type__r.Name',
                'Question_Detail__c IN ' + LPI_ServiceUtility.getStringValuesByStringSet(questionWithResponseMap.keySet()),
                null,null,null)){
                    if(questionWithResponseMap.containsKey(systemRes.Question_Detail__c) && questionWithResponseMap.get(systemRes.Question_Detail__c) == systemRes.Response_Value__c){
                        if(systemRes.RecordTypeId == responseRecordTypeId && String.isNotBlank(systemRes.Response_Saving_JSON__c)){
                            preRef = (PreliminaryApplicationRef)JSON.deserializeStrict(systemRes.Response_Saving_JSON__c,PreliminaryApplicationRef.Class);
                        }
                        if(systemRes.RecordTypeId == launchRecordTypeId && String.isNotBlank(systemRes.Regulatory_Authorization_Type__c)){
                            regAuthId = systemRes.Regulatory_Authorization_Type__c;
                            regAuthTypeName = systemRes.Regulatory_Authorization_Type__r.Name;
                        }
                    }
            }
            if(preRef !=  null && preRef.Type__c == null){
                preRef.Type__c = 'New';
            }
            return createApplication(new Map<String,Object>{
                                'type' => preRef !=  null ? preRef.Type__c : '',
                                'parDetail' => preRef,
                                'regAuthId' => regAuthId,
                                'createParRef' => preRef != null  ? true : false,
                                'amendmentType' => preRef != null ? preRef.Amendment_Type__c : null,
                                'regAuthTypeName' => regAuthTypeName
                            });
        } catch (Exception e) {
            LPI_ExceptionManager.logException('LPI_DecisionTreeQuestionsController', 'updateResponse', e);
            throw new AuraHandledException(e.getMessage());
        }
    }
    /**
    * @description 
    * @author MTX Group Product Team | 05-07-2024 
    * @param inputMap 
    * @return string 
    **/
    private static string createApplication(Map<String, Object> inputMap){
        try {
            Boolean isActionAllowed = true;
            String regAuthTypeName = (String) inputMap.get('regAuthTypeName');
            Id regAuthId = (Id) inputMap.get('regAuthId');
            if (
                isDuplicateCheckEnabled() &&
                !(String.isNotBlank(regAuthTypeName) &&
                setActionAllowedValidationExceptionRatSet.contains(regAuthTypeName)) &&
                hasExistingApplicationForRat(regAuthId)
            ) {
                isActionAllowed = false;
            }
            if(isActionAllowed){
                Map<String,Object> resultMap = LPI_ApplicationFlowUtility.createPARRecord(inputMap,null);
                if(resultMap != null){
                    return resultMap.containsKey('parRec') ? ((PreliminaryApplicationRef)resultMap.get('parRec')).SavedApplicationUrl : 'Error';
                }else{
                    return 'Error';
                }
            }else{
                return 'Duplicate';
            }
        } catch (Exception e) {
            LPI_ExceptionManager.logException('LPI_DecisionTreeQuestionsController', 'createApplication', e);
			throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * @description Returns whether Decision Tree duplicate application validation is enabled.
     * Resolves Hierarchy explicitly (User → Profile → Org). Defaults to true only when unset.
     */
    private static Boolean isDuplicateCheckEnabled() {
        LPI_Decision_Tree_Settings__c userSettings = LPI_Decision_Tree_Settings__c.getValues(
            UserInfo.getUserId()
        );
        if (userSettings != null) {
            return userSettings.Enable_Duplicate_App_Check__c == true;
        }
        LPI_Decision_Tree_Settings__c profileSettings = LPI_Decision_Tree_Settings__c.getValues(
            UserInfo.getProfileId()
        );
        if (profileSettings != null) {
            return profileSettings.Enable_Duplicate_App_Check__c == true;
        }
        LPI_Decision_Tree_Settings__c orgSettings = LPI_Decision_Tree_Settings__c.getOrgDefaults();
        if (orgSettings != null && orgSettings.Id != null) {
            return orgSettings.Enable_Duplicate_App_Check__c == true;
        }
        return true;
    }

    /**
     * @description True when the current portal user already has a New application
     * (Draft/Submitted/Converted, etc.) for the given Regulatory Authorization Type.
     * Terminal statuses Withdrawn / Rejected / Expired are ignored so re-apply is allowed.
     */
    private static Boolean hasExistingApplicationForRat(Id regAuthId) {
        if (regAuthId == null) {
            return false;
        }
        List<User> users = LPI_UserDao.getCurrentUserRecord();
        if (users.isEmpty() || users[0].AccountId == null) {
            return false;
        }
        Id accountId = users[0].AccountId;
        Set<String> terminalStatuses = new Set<String>{
            LPI_LiteralConstant.BLA_WITHDRAWN_STATUS,
            LPI_LiteralConstant.IA_REJECTED_STATUS,
            'Expired'
        };
        String whereClause =
            'Regulatory_Authorization_Type__c = \'' +
            String.escapeSingleQuotes(String.valueOf(regAuthId)) +
            '\' AND Type__c = \'' +
            String.escapeSingleQuotes(LPI_LiteralConstant.IA_NEW_APPLICATIONTYPE) +
            '\' AND Status__c NOT IN ' +
            LPI_ServiceUtility.getStringValuesByStringSet(terminalStatuses) +
            ' AND (Contact__r.AccountId = \'' +
            String.escapeSingleQuotes(String.valueOf(accountId)) +
            '\' OR BusinessAccountNameId = \'' +
            String.escapeSingleQuotes(String.valueOf(accountId)) +
            '\')';
        List<PreliminaryApplicationRef> existingApps =
            new LPI_PreliminaryApplicationRefDAO.LPI_PreliminaryApplicationRefWithoutSharingDAO()
                .getPreliminaryApplicationRefByDymanicQuery(
                    'Id, Status__c',
                    whereClause,
                    '1',
                    'CreatedDate',
                    'desc'
                );
        return !existingApps.isEmpty();
    }

    /**
    * @description 
    * @author MTX Group Product Team | 05-07-2024 
    * @param questionId 
    * @return String 
    **/
    @AuraEnabled
    public static String checkSystemValidation(String questionId){
        try{
            if(String.isNotEmpty(questionId)){
                List<String> ratIdList = new List<String>();
                Id validRecordTypeId = Schema.SObjectType.System_Validation__c.getRecordTypeInfosByName().get('Validation').getRecordTypeId();
                for(System_Validation__c sysValidList : LPI_SystemValidationDAO.getSystemValidByDymanicQuery(
                    'Id,Regulatory_Authorization_Type__c,RecordTypeId,Response_Type__c,Response_Value__c,Error_Message__c',
                    'Question_Detail__c = \'' + questionId + '\'',null,null,null)){
                    if(validRecordTypeId == sysValidList.RecordTypeId){
                            ratIdList.add(sysValidList.Regulatory_Authorization_Type__c);
                    }
                }                                  
                if(!ratIdList.isEmpty()){
                    return checkSystemValidationForMultiple(ratIdList);
                }
            }
            return 'No';
        }
        catch (Exception e) {
            LPI_ExceptionManager.logException('LPI_DecisionTreeQuestionsController', 'checkSystemValidation', e);
            throw new AuraHandledException(e.getMessage());
        }
    }
    /**
    * @description 
    * @author MTX Group Product Team | 05-07-2024 
    * @param baseRatId 
    * @return String 
    **/
    @AuraEnabled
    public static String checkSystemValidationForMultiple(List<String> baseRatId){
        try{
            List<User> u = LPI_UserDao.getCurrentUserRecord();
            if (u.isEmpty()){
                LPI_ExceptionManager.logException(
                    'LPI_DecisionTreeQuestionsController',
                    'checkSystemValidationForMultiple',
                    'User Not Found!!',
                    'User Session Expired',
                    null,
                    null
                );
                return 'Error';
            }
            String accountId = u[0].AccountId;
            String fieldsToQuery = 'Id,Status,RegulatoryAuthorizationTypeId';
            String whereClause =' RegulatoryAuthorizationTypeId IN ' + LPI_ServiceUtility.getStringValuesByList(baseRatId);
            whereClause = whereClause + ' AND Contact.AccountId  = \'' + accountId + '\'';
            Map<Id,BusinessLicense> ratIdWithBlMap = new Map<Id,BusinessLicense>();
            for(BusinessLicense bl : new LPI_BusinessLicenseDAO.LPI_BusinessLicenseWithoutSharingDAO()
                                    .getBusinessLicenseByDymanicQuery(fieldsToQuery, whereClause,null, 'CreatedDate', 'desc')){
                if(!ratIdWithBlMap.containsKey(bl.RegulatoryAuthorizationTypeId)){
                    ratIdWithBlMap.put(bl.RegulatoryAuthorizationTypeId,bl);
                }
            }
            for(Id ratId : ratIdWithBlMap.keySet()){
                if(ratIdWithBlMap.get(ratId).Status == 'Active'){
                    return 'Yes';
                }
            }
            return 'No';
        }
        catch (Exception e) {
            LPI_ExceptionManager.logException('LPI_DecisionTreeQuestionsController', 'checkSystemValidation', e);
            throw new AuraHandledException(e.getMessage());
        }
    }

	/**
	* @description 
	* @author MTX Group Product Team | 05-07-2024 
	* @param baseRatId 
	* @return String 
	**/
	private static String setActionAllowedValidation(List<String> baseRatId) {
		try {
			List<PreliminaryApplicationRef> parRecList = new List<PreliminaryApplicationRef>();
			List<String> statusAllowed = new List<String>{
				LPI_LiteralConstant.BLA_WITHDRAWN_STATUS,
				LPI_LiteralConstant.IA_REJECTED_STATUS
			};
			String whereCondition = '';
            whereCondition =
                ' Regulatory_Authorization_Type__c IN ' +
                LPI_ServiceUtility.getStringValuesByList(baseRatId);
            List<User> u = LPI_UserDao.getCurrentUserRecord();
            if (u.size() == 0) {
                LPI_ExceptionManager.logException(
                    'LPI_DecisionTreeQuestionsController',
                    'setActionAllowedValidation',
                    'User Not Found!!',
                    'User Session Expired',
                    null,
                    null
                );
                return 'Error';
            }
            whereCondition += ' AND Contact__r.AccountId = ' + '\'' + String.escapeSingleQuotes(u[0].AccountId) + '\'';
			parRecList = LPI_PreliminaryApplicationRefDAO.getPreliminaryApplicationRefByDymanicQuery(
				'Id, Status__c,Regulatory_Authorization_Type__c,Regulatory_Authorization_Type__r.Name,ApplicationType,(SELECT Status FROM IndividualApplicationAppRef),(SELECT Status FROM BusinessLicenseApplicationSavedRef) ',
				whereCondition,
				'1',
				'CreatedDate',
				'desc'
			);
			if (parRecList.isEmpty()) {
				return 'No';
			} else {
				if (parRecList[0].Status__c.equals(LPI_LiteralConstant.PAR_CONVERTED_STATUS)) {
					if (parRecList[0].IndividualApplicationAppRef.size() > 0) {
						if (!statusAllowed.contains(parRecList[0].IndividualApplicationAppRef[0].Status)) {
                            List<Businesslicense> businessLicenseList = fetchVoidBusinessLicense(baseRatId,u[0].AccountId);
                            if (!businessLicenseList.isEmpty() && businessLicenseList[0].Status == LPI_LiteralConstant.Business_License_Status_VOID) {
                                return 'No';
                            }
							return 'Yes';
						}
                        return 'No';
					} else {
						return 'No';
					}
				} else if (parRecList[0].Status__c.equals(LPI_LiteralConstant.PAR_DRAFT_STATUS)) {
                    return 'Yes';
                } else {
					return 'No';
				}
			}
		} catch (Exception e) {
			LPI_ExceptionManager.logException('LPI_DecisionTreeQuestionsController', 'setActionAllowedValidation', e);
			throw new AuraHandledException(e.getMessage());
		}
	}

    /**
    * @description This method is Used to fetch Void licenses
    * @author MTX Group Product Team | 05-07-2024 
    * @param baseRatId 
    * @param accountId 
    * @return List<BusinessLicense> 
    **/
    public static List<BusinessLicense> fetchVoidBusinessLicense(List<String> baseRatId, String accountId) {
        String fieldsToQuery = 'Id,Status';
        String whereClause =' RegulatoryAuthorizationTypeId IN ' + LPI_ServiceUtility.getStringValuesByList(baseRatId);
        if (accountId != null) {
            whereClause = whereClause + ' AND Contact.AccountId  = \'' + accountId + '\'';
        }
        return new LPI_BusinessLicenseDAO.LPI_BusinessLicenseWithoutSharingDAO()
            .getBusinessLicenseByDymanicQuery(fieldsToQuery, whereClause, '1', 'CreatedDate', 'desc');
    }

    /**
    * @description 
    * @author MTX Group Product Team | 05-07-2024 
    * @param questionValues 
    * @return List<SelectOptionWrapper> 
    **/
    public static List<SelectOptionWrapper> createOptionWrapper(String questionValues){
        return createOptionWrapper(questionValues, null);
    }

    public static List<SelectOptionWrapper> createOptionWrapper(String questionValues, Map<String, String> frTextMap){
        try{
            List<SelectOptionWrapper> optionList = new List<SelectOptionWrapper>();
            for (String queVal : questionValues.split(';')) {
                String val = queVal != null ? queVal.trim() : '';
                String label = val;
                if (frTextMap != null && frTextMap.containsKey(val.toLowerCase())) {
                    label = frTextMap.get(val.toLowerCase());
                }
                optionList.add(new SelectOptionWrapper(val, label));
            }
            return optionList;
        }
        catch (Exception e) {
            LPI_ExceptionManager.logException('LPI_DecisionTreeQuestionsController', 'createOptionWrapper', e);
            throw new AuraHandledException(e.getMessage());
        }
    }

    private static Map<String, String> buildDecisionTreeFrMap() {
        Map<String, String> m = new Map<String, String>();
        m.put('select the license type', System.Label.get('', 'LP_DT_Q_Select_License_Type', 'fr'));
        m.put('salesperson', System.Label.get('', 'LP_DT_Opt_Salesperson', 'fr'));
        m.put('manager', System.Label.get('', 'LP_DT_Opt_Manager', 'fr'));
        m.put('agent', System.Label.get('', 'LP_DT_Opt_Agent', 'fr'));
        m.put('individual agent', System.Label.get('', 'LP_DT_Opt_Individual_Agent', 'fr'));
        m.put('individual professional corporation', System.Label.get('', 'LP_DT_Opt_Individual_PC', 'fr'));
        m.put('yes', System.Label.get('', 'LP_DT_Opt_Yes', 'fr'));
        m.put('no', System.Label.get('', 'LP_DT_Opt_No', 'fr'));
        m.put(
            'do you currently have legal authorization to work in canada?',
            System.Label.get('', 'LP_DT_Q_Work_Auth_Canada', 'fr')
        );
        m.put(
            'you are not eligible to apply for this certification.',
            System.Label.get('', 'LP_DT_Err_Not_Eligible', 'fr')
        );
        return m;
    }

    private static String translateDecisionTreePlain(String source, Boolean useFrench, Map<String, String> frTextMap) {
        if (!useFrench || String.isBlank(source) || frTextMap == null || frTextMap.isEmpty()) {
            return source;
        }
        String key = source.trim().toLowerCase();
        if (frTextMap.containsKey(key)) {
            return frTextMap.get(key);
        }
        return source;
    }

    private static String translateDecisionTreeHtml(String source, Boolean useFrench, Map<String, String> frTextMap) {
        if (!useFrench || String.isBlank(source) || frTextMap == null || frTextMap.isEmpty()) {
            return source;
        }
        String plain = source.stripHtmlTags().trim().toLowerCase();
        if (frTextMap.containsKey(plain)) {
            return '<p>' + frTextMap.get(plain) + '</p>';
        }
        // Tolerate trailing/leading punctuation differences from rich text
        for (String key : frTextMap.keySet()) {
            if (plain.contains(key) && key.length() > 8) {
                return source.replace(source.stripHtmlTags(), frTextMap.get(key));
            }
        }
        return source;
    }

    /**
    * @description 
    * @author MTX Group Product Team | 05-07-2024 
    * @param questionId 
    * @return Map<String, Object> 
    **/
    @AuraEnabled
    public static Map<String,Object> checkTraineeLicense(String questionId){
        try {
            if(String.isNotEmpty(questionId)){ 
                List<String> ratIdList = new List<String>();
                Id validRecordTypeId = Schema.SObjectType.System_Validation__c.getRecordTypeInfosByName().get('Validation').getRecordTypeId();
                for(System_Validation__c sysValidList : LPI_SystemValidationDAO.getSystemValidByDymanicQuery(
                    'Id,Regulatory_Authorization_Type__c,RecordTypeId,Response_Type__c,Response_Value__c,Error_Message__c',
                    'Question_Detail__c = \'' + questionId + '\'',null,null,null)){
                    if(validRecordTypeId == sysValidList.RecordTypeId){
                            ratIdList.add(sysValidList.Regulatory_Authorization_Type__c);
                    }
                }                                
                if(!ratIdList.isEmpty()){
                    if(setActionAllowedValidation(ratIdList) == 'Yes'){
                        return new Map<String,Object>{
                            'showError' => true,
                            'errorMessage' => reAppraiserErrorMsg
                        };
                    }
                }
            }
            return null;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
    * @description 
    * @author MTX Group Product Team | 05-07-2024 
    * @param ratId 
    * @return Map<String, Object> 
    **/
    public static Map<String,Object> examinationCheck(Id ratId){
        Map<String,Object> result = new Map<String,Object>();
        if(String.isNotBlank(ratId))
        {
            String queryField = 'Id,Examination__c';
            String queryWhereClause = ' Regulatory_Authorization_Type__c = \''+String.escapeSingleQuotes(ratId)+'\'';
            List<String> examIds = new List<String>();
            for(Regulatory_Examination_Junction__c examJunc : LPI_RegulatoryExaminationJunctionDao.getRegulatoryExaminationJunctionByDymanicQuery(queryField,queryWhereClause,null,null,null)){
                if(examJunc.Examination__c != null){
                    examIds.add(examJunc.Examination__c);
                }
            }
            if(!examIds.isEmpty()){
                List<User> userList =  LPI_UserDao.getUserByDymanicQuery('Id,ContactId','Id= \''+UserInfo.getUserId()+'\'',null,null,null);
                List<PersonExamination> accPersonExamList = LPI_PersonExaminationDAO.getPersonExaminationByDynamicQuery('Id,Result,Examination_Date__c,Examination.Name',
                ' ContactId = \''+userList[0].ContactId+'\''+' AND ExaminationId IN'+LPI_ServiceUtility.getStringValuesByList(examIds),null,null,null);
                if(!accPersonExamList.isEmpty()){
                    if(accPersonExamList[0].Result == 'Pass'){
                        result.put('ExamResult','Yes');
                        result.put('ExamName',accPersonExamList[0].Examination.Name);
                        result.put('DateTaken',convertDateFormat(String.valueOf(accPersonExamList[0].Examination_Date__c?.format())));
                    }else{
                        result.put('ExamResult','No');                    
                    } 
                }
                else{
                    result.put('ExamResult','No Record Present');
                }
            }else{
                result.put('ExamResult','No Record Present');
            }
        }
        return result ;
    }

    /**
     * @author                      : MTX Group Product Team
     * @since                       :
     * @description                 : get date format in MM/dd/YYYY
     * @last modified by            : Ayush Dev
     * @last modified date          :
     * @modified details            :
     */
    public static string convertDateFormat(String dateValue) {
        String resDate;
        if (String.isNotBlank(dateValue)) {
            List<String> res = dateValue.split('/', 3);
            if (!res.isEmpty() && res[0].length() == 1) {
                res[0] = '0' + res[0];
            }
            if (!res.isEmpty() && res[1].length() == 1) {
                res[1] = '0' + res[1];
            }
            resDate = res[0] + '/' + res[1] + '/' + res[2];
        }

        return resDate;
    }

    public class SelectOptionWrapper{
		@AuraEnabled public string value;
		@AuraEnabled public string label;
		public SelectOptionWrapper(string value, string label){
			this.value = value;
			this.label = label;
		}
	}
    public class  QuestionDetailsWrapper {
        @AuraEnabled public Boolean showQuestion;
        @AuraEnabled public String id;
        @AuraEnabled public String professionId;
        @AuraEnabled public String regulatoryAuthId;
        @AuraEnabled public String name;
        @AuraEnabled public String helpText;
        @AuraEnabled public String question;
        @AuraEnabled public String answerType;
        @AuraEnabled public List<SelectOptionWrapper> questionValues;
        @AuraEnabled public String forInputNamedPage;
        @AuraEnabled public String description;
        @AuraEnabled public String errorText;
        @AuraEnabled public Integer order;
        @AuraEnabled public Boolean required;
        @AuraEnabled public String targetObject;
        @AuraEnabled public String targetField;
        @AuraEnabled public string userResponse;
        @AuraEnabled public boolean saveUserResponse;
        @AuraEnabled public string launchFlowCondition;
        @AuraEnabled public Boolean questionConditionMeet;
        @AuraEnabled public String questionCondition;
        @AuraEnabled public String questionDependentOn;
        @AuraEnabled public Boolean isQuestionDependent;
        @AuraEnabled public Boolean isMatchingCriteriaEqualTo;
        @AuraEnabled public Boolean allowLaunchFlow;
        @AuraEnabled public String errorMessage;
        @AuraEnabled public String errorMessageMatchingCondition;
        @AuraEnabled public boolean checkSystemValidation;
        @AuraEnabled public String systemValidMatchValue;
        @AuraEnabled public String baseRatId;
        @AuraEnabled public boolean showLabel;
        @AuraEnabled public boolean isRadio;
        @AuraEnabled public boolean isPicklist;
        @AuraEnabled public boolean isText;
        @AuraEnabled public boolean isTextInput;
        
        public QuestionDetailsWrapper() {
            id = '';
            professionId = '';
            regulatoryAuthId = '';
            name = '';
            helpText = '';
            question = '';
            answerType = '';
            description = '';
            targetObject = '';
            targetField = '';
            required = true;
            allowLaunchFlow = false;
            userResponse = '';
            saveUserResponse = false;
            launchFlowCondition = '';
        } 
    }
}