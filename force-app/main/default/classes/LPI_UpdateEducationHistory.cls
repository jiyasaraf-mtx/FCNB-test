/**
 * @author      : MTX Group Product Team
 * @since       : December 7, 2022
 * @description : This Class handles the CUD operations of Education History and Presentation Record
 */
global with sharing class LPI_UpdateEducationHistory implements Callable {
    private static final String LPI_UPDATE_EDUCATION_HISTORY_CLASS_NAME = 'LPI_UpdateEducationHistory';
    private static final String MASSAGE_THERAPIST_EDU = 'Massage Therapist Education';
    private static final String PROVISIONAL_MASSAGE_THERAPIST = 'Provisional Massage Therapist';
    private static final String MASSAGE_THERAPY_EDUCATION = 'Massage Therapy Education';
    private static Map<String, String> osFieldToAppContentApiMap;
    private static Map<String, String> personEduMap;
    private static final String HIGHER_EDUCATION_TYPE = 'Higher Education';
    private static final String VERIFIED_EDUCATION_STATUS = 'Verified';
    private static Boolean lockError = true;
    private static Boolean alreadyLockedError = false;

    /**
     * @author                      : MTX Group Product Team
     * @since                       : January 31, 2023
     * @description                 : This method is used to internally call the `invokeMethod` method
     * @param action                : It contains method name which is called from OmniScript
     * @param args                  : It is Map<String, Object> which contanis `input`, `output` and `options`
     * @return                      : `Object`
     * @last modified by            : MTX Group Product Team
     * @last modified date          : February 28, 2023
     * @last modified details       : Changed access modifier to back to global
     */
    global Object call(String action, Map<String, Object> args) {
        Map<String, Object> input = (Map<String, Object>) args.get('input');
        Map<String, Object> output = (Map<String, Object>) args.get('output');
        Map<String, Object> options = (Map<String, Object>) args.get('options');
        return invokeMethod(action, input, output, options);
    }

    /**
     * @author                      : MTX Group Product Team
     * @since                       : December 7, 2022
     * @description                 : This method is called from `call` method and internally calls the OmniScript methods
     * @param methodName            : It contains method name which is called from OmniScript
     * @param inputMap              : Input data passed from OmniScript
     * @param outMap                : Output data passed to OmniScript
     * @param options               : Optional Input passed from OmniScript
     * @return                      : `Boolean`
     * @last modified by            : MTX Group Product Team
     * @last modified date          : April 21, 2023
     * @last modified details       : Code Beautification
     */
    private Boolean invokeMethod(String methodName, Map<String, Object> inputMap, Map<String, Object> outMap, Map<String, Object> options) {
        Boolean result = true;
        Boolean educationHistoryVerified = (Boolean) inputMap.get('EducationHistoryVerified');
        alreadyLockedError = false;
        try {
            if (methodName.equals('upsertEducationHistoryInformation')) {
                if (!educationHistoryVerified) {
                    upsertEducationHistoryInformation(inputMap, outMap, options);
                } 
                else {
                    result = false;
                }
            } 
            else if (methodName.equals('deleteEducationHistoryInformation')) {
                if (!educationHistoryVerified) {
                    deleteEducationHistoryInformation(inputMap, outMap, options);
                } 
                else {
                    lockError = false;
                    result = false;
                    throw new LPI_Exception('This record is already verified. You are not allowed to delete this.');
                }
            } 
            else if (methodName.equals('fetchEducationDetails')) {
                fetchEducationDetails(inputMap, outMap);
            } 
            else if (methodName.equals('fetchInstitutionDetails')) {
                fetchInstitutionDetails(inputMap, outMap);
            } 
            else {
                result = false;
            }
        } 
        catch (Exception ex) {
            result = false;
            if (lockError && !alreadyLockedError) {
                LPI_ExceptionManager.logException(LPI_UPDATE_EDUCATION_HISTORY_CLASS_NAME, 'invokeMethod', ex);
                alreadyLockedError = true;
            }
            throw new LPI_Exception(ex.getMessage());
        }
        return result;
    }

    

    /**
     * @author                      : MTX Group Product Team
     * @since                       : December 7, 2022
     * @description                 : This method upserts Education History Record (PersonEducation object)
     * @param inputMap              : Input data passed from OmniScript
     * @param outMap                : Output data passed to OmniScript
     * @param options               : Optional Input passed from OmniScript
     * @return                      : `void`
     * @last modified by            : MTX Group Product Team
     * @last modified date          : January 24, 2023
     * @last modified details       : Put error check on End Date - Graduation Date validation for Non Pharmacy boards
     */
    private static void upsertEducationHistoryInformation(Map<String, Object> inputMap, Map<String, Object> outMap, Map<String, Object> options) {
        String showErrorMessages = '';
        alreadyLockedError = false;
        try {
            Id parId = (Id) inputMap.get('PARID');
            if (parId == null) {
                return;
            }
            String contactId;
            String educationHistoryRecordStatus = '';
            String parQueryFields = 'Id, Contact__c, Regulatory_Authorization_Type__r.Name, ' + 
                                        'Regulatory_Authorization_Type__r.Issuing_Department_Name__c';
            String parWhereClause = 'Id = \'' + parId + '\'';
            List<PreliminaryApplicationRef> parList = LPI_PreliminaryApplicationRefDAO.getPreliminaryApplicationRefByDymanicQuery(
                                                                                    parQueryFields, parWhereClause, '1', null, null);
            PersonEducation personEdu = new PersonEducation();
            if (!parList.isEmpty() && parList[0].Contact__c != null) {
                contactId = parList[0].Contact__c;
                if (inputMap.containsKey('UniversityNameTypeAhead-Block')) {
                    Map<String, Object> typeAheadMap = (Map<String, Object>) inputMap.get('UniversityNameTypeAhead-Block');
                    if (typeAheadMap != null && typeAheadMap.containsKey('InstitutionName')) {
                        String universtiyName = (String) typeAheadMap.get('InstitutionName');
                        if (String.isNotEmpty(universtiyName)) {
                            personEdu.IdentifierIssuer = universtiyName;
                            personEdu.City__c = (String) typeAheadMap.get('EduCity');
                            personEdu.State__c = (String) typeAheadMap.get('EduState');   
                            personEdu.Country_Text__c = (String) typeAheadMap.get('EduCountryRO');
                            personEdu.Is_New_School__c = false;
                        }
                    } 
                    else if (inputMap.containsKey('EduHistoryEditBlock')) {
                        Map<String, Object> eduHistoryEditMap = (Map<String, Object>) inputMap.get('EduHistoryEditBlock');
                        personEdu.IdentifierIssuer = (String) eduHistoryEditMap.get('EduUniversityName');
                        personEdu.City__c = (String) eduHistoryEditMap.get('CityEducationHistory');
                        personEdu.Country_Text__c = (String) inputMap.get('CountryFormula');
                        if ((String) inputMap.get('CountryFormula') == 'United States') {
                            personEdu.State__c = (String) inputMap.get('StateFormula');
                        } 
                        else {
                            personEdu.State__c = (String) eduHistoryEditMap.get('StateNonUN');
                        }
                        personEdu.Is_New_School__c = true;
                    } 
                    else {
                        personEdu.IdentifierIssuer = (String) inputMap.get('NameOfTheSchool');
                        personEdu.City__c = (String) inputMap.get('CityEducationHistory');
                        personEdu.State__c = (String) inputMap.get('StateUnitedStates');
                    }
                } 
                else {
                    personEdu.IdentifierIssuer = (String) inputMap.get('NameOfTheSchool');
                    personEdu.City__c = (String) inputMap.get('CityEducationHistory');
                    personEdu.State__c = (String) inputMap.get('StateUnitedStates');
                }
                if(inputMap.containsKey('Degree')){
                    personEdu.Name = inputMap.get('Degree') != null ? (String) inputMap.get('Degree') : 'Not Applicable';
                }
                if(inputMap.containsKey('StartDate') && inputMap.get('StartDate') != null ){
                    personEdu.StartDate = Date.valueOf((String) inputMap.get('StartDate'));
                }
                if(inputMap.containsKey('EndDate') && inputMap.get('EndDate') != null){
                    personEdu.CompletionDate = Date.valueOf((String) inputMap.get('EndDate'));
                }
                if(inputMap.containsKey('GraduationDate') && inputMap.get('GraduationDate') != null){
                    personEdu.GraduationDate = Date.valueOf((String) inputMap.get('GraduationDate'));
                }
                personEdu.Id = inputMap.containsKey('Id') ? (String) inputMap.get('Id') : null;
                personEdu.ContactId = contactId;
                educationHistoryRecordStatus = inputMap.containsKey('EducationHistoryStatus') ? (String) inputMap.get('EducationHistoryStatus') : '';
            }
            if (personEdu.StartDate != null && personEdu.CompletionDate != null && personEdu.StartDate >= personEdu.CompletionDate) {
                showErrorMessages = 'Start Date cannot be greater than or equal to End Date';
            }
            if (personEdu.StartDate != null && personEdu.GraduationDate != null && personEdu.StartDate >= personEdu.GraduationDate) {
                showErrorMessages = showErrorMessages != '' ? showErrorMessages + 
                ', and Start Date cannot be greater than or equal to Graduation Date' : 'Start Date cannot be greater than or equal to Graduation Date';
            }
            if (personEdu.CompletionDate != null && personEdu.GraduationDate != null && personEdu.CompletionDate > personEdu.GraduationDate && 
                parList[0].Regulatory_Authorization_Type__r.Issuing_Department_Name__c != 'Pharmacy' && educationHistoryRecordStatus != VERIFIED_EDUCATION_STATUS) {
                showErrorMessages = showErrorMessages != '' ? showErrorMessages + 
                ', and End Date cannot be greater than Graduation Date' : 'End Date cannot be greater than Graduation Date';
            }
            if (showErrorMessages == '') {
                if (contactId != null && contactId != '') {
                    personEdu.ContactId = contactId;
                }
                personEdu.Preliminary_Application_Reference__c = parId;
                personEdu.Not_Education_History_Record__c = false;
                String personEduQueryFields = 'Id, Not_Education_History_Record__c, Education_Type__c, IdentifierIssuer, ' +
                                                'Country__c, State__c, City__c, Name, GraduationDate, ContactId';
                String personEduWhereClause = 'Not_Education_History_Record__c = ' +
                                                String.escapeSingleQuotes(String.valueOf(personEdu.Not_Education_History_Record__c)) +
                                                ' AND ' + 'IdentifierIssuer = \'' + String.escapeSingleQuotes(personEdu.IdentifierIssuer) + '\'' + 
                                                ' AND ' + 'ContactId = \'' + personEdu.ContactId + '\'';
                if (String.isNotBlank(personEdu.State__c)) {
                    personEduWhereClause += ' AND ' + 'State__c = \'' + String.escapeSingleQuotes(personEdu.State__c) + '\'' ;
                }
                if (String.isNotBlank(personEdu.City__c)) {
                    personEduWhereClause = personEduWhereClause + ' AND ' + 'City__c = \'' + String.escapeSingleQuotes(personEdu.City__c) + '\'';
                }
                if (!parList.isEmpty() && parList[0].Regulatory_Authorization_Type__r.Name != PROVISIONAL_MASSAGE_THERAPIST) {
                    personEdu.Education_Type__c = HIGHER_EDUCATION_TYPE;
                    personEduWhereClause += ' AND ' + 'Country_Text__c = \'' + String.escapeSingleQuotes(personEdu.Country_Text__c) + '\'';
                    if(personedu.Name!=null){
                        personEduWhereClause +=  ' AND ' + 'Name = \'' + String.escapeSingleQuotes(personEdu.Name) + '\'';
                    }
                    if (personEdu.GraduationDate != null ) {
                        personEduWhereClause += ' AND ' + 'DAY_ONLY(GraduationDate) = ' + 
                                                String.escapeSingleQuotes(String.valueOf(personEdu.GraduationDate.format('yyyy-MM-dd')));
                    }                      
                } 
                else {
                    personEdu.Education_Type__c = MASSAGE_THERAPIST_EDU;
                    personEdu.Name = MASSAGE_THERAPY_EDUCATION;
                    if (personEdu.StartDate != null && personEdu.CompletionDate != null) {
                        personEduWhereClause += ' AND ' + 'DAY_ONLY(StartDate) = ' + 
                                                String.escapeSingleQuotes(String.valueOf(personEdu.StartDate.format('yyyy-MM-dd'))) + 
                                                ' AND ' + 'DAY_ONLY(CompletionDate) = ' + 
                                                String.escapeSingleQuotes(String.valueOf(personEdu.CompletionDate.format('yyyy-MM-dd')));
                    }
                }
                personEduWhereClause += ' AND ' + 'Education_Type__c = \'' + String.escapeSingleQuotes(personEdu.Education_Type__c) + '\'';
                List<PersonEducation> personEduList = LPI_PersonEducationDAO.getPersonEducationByDymanicQuery(personEduQueryFields, 
                                                                                            personEduWhereClause, null, null, null);
                if (personEduList.isEmpty()) {
                    personEdu = (PersonEducation) LPI_WithoutSharingUtility.upsertSObject(personEdu);
                    outMap.put('Id', personEdu.Id);
                } 
                else {
                    lockError = false;
                    showErrorMessages = 'Same record exists. Please enter a new record.';
                }
            } 
            else {
                lockError = false;
            }
        } 
        catch (Exception ex) {
            if (lockError && !alreadyLockedError) {
                LPI_ExceptionManager.logException(LPI_UPDATE_EDUCATION_HISTORY_CLASS_NAME, 'upsertEducationHistoryInformation', ex);
                alreadyLockedError = true;
            }
            throw new LPI_Exception(ex.getMessage());
        }
        if (showErrorMessages != null && showErrorMessages != '') {
            throw new LPI_Exception(showErrorMessages);
        }
    }

    /**
     * @author                      : MTX Group Product Team
     * @since                       : December 7, 2022
     * @description                 : This method deletes Education History Record (PersonEducation object)
     * @param inputMap              : Input data passed from OmniScript
     * @param outMap                : Output data passed to OmniScript
     * @param options               : Optional Input passed from OmniScript
     * @return                      : `void`
     * @last modified by            : MTX Group Product Team
     * @last modified date          : April 28, 2023
     * @last modified details       : Put check of Education_Status__c field for deletion
     */
    private static void deleteEducationHistoryInformation(Map<String, Object> inputMap, Map<String, Object> outMap, Map<String, Object> options) {
        alreadyLockedError = false;
        try {
            if (inputMap.containsKey('Id')) {
                String personEduQueryFields = 'Id, Not_Education_History_Record__c, Education_Status__c, Education_Type__c';
                String personEduWhereClause = 'Id = \'' + String.escapeSingleQuotes(String.valueOf(inputMap.get('Id'))) + '\'' +
                                                ' AND ' + 'Not_Education_History_Record__c = false' +
                                                ' AND ' + 'Education_Status__c != \'' + VERIFIED_EDUCATION_STATUS + '\'' +
                                                ' AND ' + '(Education_Type__c = \'' + HIGHER_EDUCATION_TYPE + '\'' +
                                                    ' OR ' + 'Education_Type__c = \'' + MASSAGE_THERAPIST_EDU + '\'' + ')';
                List<PersonEducation> personEduList = LPI_PersonEducationDAO.getPersonEducationByDymanicQuery(personEduQueryFields, 
                                                            personEduWhereClause, '1', null, null);
                if (!personEduList.isEmpty()) {
                    LPI_WithoutSharingUtility.deleteSObject(personEduList);
                }
            }
        } 
        catch (Exception ex) {
            if (!alreadyLockedError) {
                LPI_ExceptionManager.logException(LPI_UPDATE_EDUCATION_HISTORY_CLASS_NAME, 'deleteEducationHistoryInformation', ex);
                alreadyLockedError = true;
            }
            throw new LPI_Exception(ex.getMessage());
        }
    }

    /**
     * @author                      : MTX Group Product Team
     * @since                       : August 31, 2022
     * @description                 : This method is used to fetch Person Education details
     * @param inputMap              : Input data passed from OmniScript
     * @param outMap                : Output data passed to OmniScript
     * @return                      : `void`
     * @last modified by            : MTX Group Product Team
     * @last modified date          : January 24, 2024
     * @last modified details       : Code Beautification
     */
    private static void fetchEducationDetails(Map<String, Object> inputMap, Map<String, Object> outMap) {
        try {                                
            if (inputMap.containsKey('parId') && (Id) inputMap.get('parId') != null) {
                Id parId = (Id) inputMap.get('parId');
                String eduType = (String) inputMap.get('filterEducationType');
                String parQueryFields = 'Id, Contact__c, Regulatory_Authorization_Type__r.Issuing_Department_Name__c';
                String parWhereClause = 'Id = \'' + parId + '\'';
                List<PreliminaryApplicationRef> parList = LPI_PreliminaryApplicationRefDAO.getPreliminaryApplicationRefByDymanicQuery(
                                                                                        parQueryFields, parWhereClause, '1', null, null);
                if (!parList.isEmpty() && parList[0].Contact__c != null && eduType != null) {
                    Set<String> universityNameSet = new Set<String>();
                    String personEduQueryFields = 'Id, City__c, CompletionDate, Country_Text__c, Education_Type__c, Education_Status__c, ' + 
                                                    'GraduationDate, IdentifierIssuer, StartDate, State__c, Name, Is_New_School__c';
                    String personEduWhereClause = 'ContactId = \'' + parList[0].Contact__c + '\'' +
                                                    ' AND ' + 'Education_Type__c = \'' + String.escapeSingleQuotes(eduType) + '\'';
                    LPI_PersonEducationDAO.LPI_PersonEducationWithoutSharingDAO withoutPersonEdu = new LPI_PersonEducationDAO.LPI_PersonEducationWithoutSharingDAO();
                    List<PersonEducation> personEduRecList = withoutPersonEdu.getPersonEducationByDymanicQuery(
                                                            personEduQueryFields, personEduWhereClause, null, null, null);
                    for (PersonEducation eduRecord : personEduRecList) {
                        universityNameSet.add(eduRecord.IdentifierIssuer);
                    }
                    if (!personEduRecList.isEmpty()) {
                        List<Map<String, Object>> dataMapList = new List<Map<String, Object>>();
                        List<String> queryUniversityList = new List<String>();
                        Map<String, String> institutionMap = new Map<String, String>();
                        String queryFields = 'Institution_Name__c, Institution_With_Address__c';
                        String queryWhere = 'Institution_Name__c IN ' + LPI_ServiceUtility.getStringValuesByStringSet(universityNameSet);
                        LPI_InstitutionDAO.LPI_InstitutionWithoutSharingDAO withoutSharingQuery = new LPI_InstitutionDAO.LPI_InstitutionWithoutSharingDAO();
                        for (Institution__c institute : withoutSharingQuery.getInstitutionByDymanicQuery(queryFields, queryWhere, '20', null, null)) {
                            queryUniversityList.add(institute.Institution_Name__c);
                            institutionMap.put(institute.Institution_Name__c, institute.Institution_With_Address__c);
                        }
                        for (PersonEducation eduRecord : personEduRecList) {
                            Map<String, Object> tempMap = new Map<String, Object>();
                            if (eduRecord.StartDate != null) {
                                tempMap.put('StartDate', Date.valueOf(eduRecord.StartDate));
                            }
                            if (eduRecord.CompletionDate != null) {
                                tempMap.put('EndDate', Date.valueOf(eduRecord.CompletionDate));
                                tempMap.put('EndDateRO', Date.valueOf(eduRecord.CompletionDate));
                            }
                            if (eduRecord.GraduationDate != null) {
                                tempMap.put('GraduationDate', Date.valueOf(eduRecord.GraduationDate));
                                tempMap.put('GraduationDateRO', Date.valueOf(eduRecord.GraduationDate));
                            }
                            if(eduRecord.Name == 'Not Applicable'){
                                tempMap.put('Degree', null);
                            }else{
                                tempMap.put('Degree', (String) eduRecord.Name);
                            }
                            tempMap.put('Id', (String) eduRecord.Id);
                            tempMap.put('EducationHistoryStatus', (String) eduRecord.Education_Status__c);
                            tempMap.put('boardName', (String) parList[0].Regulatory_Authorization_Type__r.Issuing_Department_Name__c);
                            if (queryUniversityList.contains(eduRecord.IdentifierIssuer)) {
                                Map<String, Object> typeAheadMap = new Map<String, Object>();
                                if (eduRecord.Education_Status__c != 'Verified') {
                                    typeAheadMap.put('UniversityNameTypeAhead', institutionMap.get(eduRecord.IdentifierIssuer));
                                    typeAheadMap.put('InstitutionName', (String) eduRecord.IdentifierIssuer);
                                    typeAheadMap.put('EduCity', (String) eduRecord.City__c);
                                    typeAheadMap.put('EduState', (String) eduRecord.State__c);
                                    typeAheadMap.put('EduCountryRO', (String) eduRecord.Country_Text__c);
                                    tempMap.put('UniversityNameTypeAhead-Block', typeAheadMap);
                                } 
                                else {
                                    typeAheadMap.put('SchoolNameRO', (String) eduRecord.IdentifierIssuer);
                                    typeAheadMap.put('CityROEducationHistory', (String) eduRecord.City__c);
                                    typeAheadMap.put('StateRO', (String) eduRecord.State__c);
                                    typeAheadMap.put('CountryRO', (String) eduRecord.Country_Text__c);
                                    tempMap.put('UniversityNameTypeAheadRO', typeAheadMap); 
                                }
                                tempMap.put('isSchoolRecord', 'Yes');
                            } 
                            else {
                                Map<String, Object> eduHistoryEditMap = new Map<String, Object>();
                                eduHistoryEditMap.put('EduUniversityName', (String) eduRecord.IdentifierIssuer);
                                eduHistoryEditMap.put('CityEducationHistory', (String) eduRecord.City__c);
                                eduHistoryEditMap.put('CountryEducationHistory', (String) eduRecord.Country_Text__c);
                                if (eduRecord.Country_Text__c == 'United States') {
                                    eduHistoryEditMap.put('StateEducationHistory', (String) eduRecord.State__c);
                                    eduHistoryEditMap.put('StateHide', (String) eduRecord.State__c);
                                } 
                                else {
                                    eduHistoryEditMap.put('StateNonUN', (String) eduRecord.State__c);
                                    eduHistoryEditMap.put('StateNonUNHide', (String) eduRecord.State__c);
                                }
                                tempMap.put('EduHistoryEditBlock', eduHistoryEditMap);
                                tempMap.put('isSchoolRecord', 'No');
                            }
                            tempMap.put('newSchoolCheckBox',eduRecord.Is_New_School__c);
                            dataMapList.add(tempMap);
                        }
                        outMap.put('NodeFromEducationDR', dataMapList);
                    }
                }
            }
        } 
        catch (Exception e) {
            LPI_ExceptionManager.logException(LPI_UPDATE_EDUCATION_HISTORY_CLASS_NAME, 'fetchEducationDetails', e);
            throw new LPI_Exception(e.getMessage());
        }
    }

    /**
     * @author                      : MTX Group Product Team
     * @since                       : August 31, 2022
     * @description                 : This method is used to fetch Institution details
     * @param inputMap              : Input data passed from OmniScript
     * @param outMap                : Output data passed to OmniScript
     * @return                      : `void`
     * @last modified by            : MTX Group Product Team
     * @last modified date          : January 24, 2024
     * @last modified details       : Code Beautification
     */
    private static void fetchInstitutionDetails(Map<String, Object> inputMap, Map<String, Object> outMap) {
        List<Map<String, Object>> dataMap = new List<Map<String, Object>>();
        try {
            if (inputMap.containsKey('UniversityNameTypeAhead') && String.valueOf(inputMap.get('UniversityNameTypeAhead')).length() > 3) {
                String searchUniversityName = '%' + (String) inputMap.get('UniversityNameTypeAhead') + '%';
                String queryFields = 'Institution_Name__c, City__c, State__c, Country__c, Institution_With_Address__c';
                String queryWhere = 'Institution_With_Address__c LIKE  \'' + searchUniversityName + '\'' + ' AND Is_Institute__c = TRUE';
                LPI_InstitutionDAO.LPI_InstitutionWithoutSharingDAO withoutSharingQuery = new LPI_InstitutionDAO.LPI_InstitutionWithoutSharingDAO();
                for (Institution__c institute : withoutSharingQuery.getInstitutionByDymanicQuery(queryFields, queryWhere, '10', null, null)) {
                    Map<String, Object> tempmap = new Map<String, Object>();
                    tempmap.put('EduCountryRO', institute.Country__c);
                    tempmap.put('EduCity', institute.City__c);
                    tempmap.put('EduState', institute.State__c);
                    tempmap.put('UniversityName', institute.Institution_With_Address__c);
                    tempmap.put('InstitutionName', institute.Institution_Name__c);
                    dataMap.add(tempmap);
                }
                outMap.put('instituteDetails', dataMap);
            }
        } 
        catch (Exception e) {
            LPI_ExceptionManager.logException(LPI_UPDATE_EDUCATION_HISTORY_CLASS_NAME, 'fetchInstitutionDetails', e);
            throw new LPI_Exception(e.getMessage());
        }
    }

    
}