/**
* @author      : MTX Group Product Team
* @since       : 7 December 2022, 11:36 PM
* @description : This class LPI_EmploymentHistoryData implements the Callable interface and contains the invokeMethod() method 
*                 which is used to call the respective action methods based on the methodName passed as argument. - S-43530
*/
global with sharing class LPI_EmploymentHistoryData implements Callable {
     
    private static final String CLASS_NAME_EMPLOYMENT_HISTORY_DATA = 'LPI_EmploymentHistoryData';
    private static final String VAR_UNITED_STATES = 'United States';
    private static final String METHOD_INVOKE_METHOD = 'invokeMethod';
    private static final String METHOD_FETCH_EMPLOYMENT_HISTORY_INFORMATION = 'fetchEmploymentHistoryInformation';
     
    private static final String METHOD_DELETE_EMPLOYMENT_INFORMATION = 'deleteEmploymentInformation';
    private static final String ERROR_VERIFIED = 'This record is already verified. You are not allowed to delete this.';
    private static final String ERROR_SAME_RECORD_EXIST = 'Same record exists. Please enter a new record.';
    private static final String VAR_NOT_VERIFIED = 'Not Verified';
    private static final String VAR_VERIFIED = 'Verified';
    private static final String VAR_STATUS = 'Status';
    private static final String ROLE_PERSON_IN_CHARGE = 'Designated Incharge';
    private static final String APP_TYPE_AMENDMENT = 'Amendment';
    private static final String APP_SUB_TYPE_CHANGE_OF_PERSON_INCHARGE = 'Change of Designated Incharge';
     
    private static final Set<String> BOARD_NAME_CHECK_APPROPRIATE_SET = new Set<String>{
        'Acupuncture',
        'Chiropractic Examiners',
        'Marital & Family Therapists',
        'Massage Therapists',
        'Professional Counselors'
    };
    private static final Set<String> BOARD_WITH_OPTIONAL_END_DATE = new Set<String>{
        'Veterinary',
        'Hearing Instrument Specialists',
        'Dietitians',
        'Interior Design'
    };
     
    private static final Set<String> SUPERVISORS_ADDRESS_CHECK_RAT_SET = new Set<String>{
        'Respiratory Care Practitioner', 'Clinical Social Worker', 'Advanced Macro Social Worker',
        'Master Social Worker', 'Baccalaureate Social Worker', 'Respiratory Temporary Educational Permit',
        'Respiratory Care Practitioner', 'State Licensed Appraiser Trainee', 'State Certified Residential Appraiser Trainee',
        'State Certified General Appraiser Trainee','Body Piercer','Brander','Tattooist','Brander and Body Piercer',
        'Tattooist and Body Piercer','Tattooist and Brander','Tattooist, Body Piercer and Brander', 'Occupational Therapist', 'Occupational Therapy Assistant'
    };
     
    private static final Set<String> MANAGER_INCHARGE_RAT_NAME_SET = new Set<String>{
        'Third-Party Logistics Provider', 
        'Drug Distributor'
    };
     
    
    global Object call(String action, Map<String, Object> args) {
         
        Map<String, Object> input = (Map<String, Object>) args.get('input');
        Map<String, Object> output = (Map<String, Object>) args.get('output');
        Map<String, Object> options = (Map<String, Object>) args.get('options');
         
        return invokeMethod(action, input, output, options);
    }
    
     
    private Boolean invokeMethod(String methodName, Map<String, Object> inputMap, Map<String, Object> outMap, Map<String, Object> options) {
        Boolean result = true;
        try {
             
            if (methodName.equals(METHOD_FETCH_EMPLOYMENT_HISTORY_INFORMATION)) {
                fetchEmploymentHistoryInformation(inputMap, outMap);
            } 
        } catch (Exception e) {
             
            result = false;
            String message = e.getMessage();
            if (message.equals(ERROR_VERIFIED) || message.equals(ERROR_SAME_RECORD_EXIST)) {
                throw new LPI_Exception(e.getMessage());
            }
            LPI_ExceptionManager.logException(CLASS_NAME_EMPLOYMENT_HISTORY_DATA, METHOD_INVOKE_METHOD, e);
        }
        
        return result;
    }
    
    
    /**
    * @description       This method will call from the invoke method and used to return Employment History Information
    * 
    * @author         :  MTX Group Product Team
    * @lastModifiedBy : MTX Group Product Team
    * @last modified details : Added class description, method description and proper comments before for loop and if check
    * @param inputMap : Map of input parameters 
    * @param outMap : Map of output parameters
    * @return  
    */
    public static void fetchEmploymentHistoryInformation( Map<String, Object> inputMap, Map<String, Object> outMap) {
        String parId = (String) inputMap.get('parId');
        if (String.isNotEmpty(parId)) {
            Set < Id > accountIds = new Set < Id > ();
            String parStringToQuery = 'Id, BusinessAccountNameId, Regulatory_Authorization_Type__r.Name,Board_Name__c';
            String whereClause = 'Id = \'' + String.escapeSingleQuotes(parId) + '\'';
            String boardName = '';
            String regAuthTypeName = '';
            Boolean fieldVisibility = false;
            Set<String> boardNameSet = new Set<String>{'Arch., Engr., Surveyors & Landscape Arch.'};
            for (PreliminaryApplicationRef parData: LPI_PreliminaryApplicationRefDAO.getPreliminaryApplicationRefByDymanicQuery(parStringToQuery, whereClause, null, null, null)) {
                regAuthTypeName = parData.Regulatory_Authorization_Type__r.Name;
                accountIds.add(parData.BusinessAccountNameId);
                boardName = parData.Board_Name__c;
                fieldVisibility = boardNameSet.contains(boardName);
            }
            if (!accountIds.isEmpty()) {
                String parQueryFields = 'Id, RelatedPersonId, Name, EndDate, StartDate, EmployerCity, EmployerStreet, EmployerCountry,'+ 
                'EmployerPostalCode, Employer_License_Number__c, Please_specify__c, Check_Appropriate_Experiences__c, Position,'+ 
                'EmployerState, Immediate_Supervisor_s_Name__c, Supervisor_s_City__c, Supervisor_s_Phone_number__c, Supervisor_s_State__c,'+ 
                'Supervisor_s_Street__c, Supervisor_s_Zip_Code__c, EmploymentStatus,Job_Responsibilities_Duties__c, Total_Hours_Claimed__c';
                String parWhereClause = 'RelatedPersonId IN ' + LPI_ServiceUtility.getStringValuesBySet(accountIds);
                if(!BOARD_WITH_OPTIONAL_END_DATE.contains(boardName)){
                    parWhereClause += ' AND EndDate != NULL';
                }
                Map < Id, PersonEmployment > employmentHistoryMap = new Map <Id, PersonEmployment> (new LPI_PersonEmploymentDAO.LPI_EmploymentHistoryWithoutSharingDAO().getEmploymentHistoryByDymanicQuery(parQueryFields, parWhereClause, null, null, null));
                if (employmentHistoryMap.keySet().size() > 0) {
                    List < Map < String, Object >> responseDataList = new List < Map < String, Object >> ();
                    for (Id empId: employmentHistoryMap.KeySet()) {
                        Map < String, Object > responseDataMap = new Map < String, Object > ();
                        responseDataMap.put('Id', empId);
                        responseDataMap.put('Status', employmentHistoryMap.get(empId).EmploymentStatus);
                        responseDataMap.put('PleaseSpecify', employmentHistoryMap.get(empId).Please_specify__c);
                        responseDataMap.put('EmployerLicenseNumber', employmentHistoryMap.get(empId).Employer_License_Number__c);
                        responseDataMap.put('NameoftheEmployer', employmentHistoryMap.get(empId).Name);
                        responseDataMap.put('Startdate', employmentHistoryMap.get(empId).StartDate);
                        responseDataMap.put('EndDate', employmentHistoryMap.get(empId).EndDate);
                        responseDataMap.put('EndDateRequired', employmentHistoryMap.get(empId).EndDate);
                        responseDataMap.put('EndDateRO', employmentHistoryMap.get(empId).EndDate);
                        responseDataMap.put('JobTitlePositionheld', employmentHistoryMap.get(empId).Position);
                        responseDataMap.put('City', employmentHistoryMap.get(empId).EmployerCity);
                        responseDataMap.put('StreetAddress', employmentHistoryMap.get(empId).EmployerStreet);
                        responseDataMap.put('Country', employmentHistoryMap.get(empId).EmployerCountry);
                        responseDataMap.put('Zip', employmentHistoryMap.get(empId).EmployerPostalCode);
                        responseDataMap.put('ImmediateSupervisorsName', employmentHistoryMap.get(empId).Immediate_Supervisor_s_Name__c);
                        responseDataMap.put('ImmediateSupervisorsPhoneNumber', employmentHistoryMap.get(empId).Supervisor_s_Phone_number__c);
                        responseDataMap.put('SAState', employmentHistoryMap.get(empId).Supervisor_s_State__c);
                        responseDataMap.put('StreetAddress1', employmentHistoryMap.get(empId).Supervisor_s_Street__c);
                        responseDataMap.put('SAZip', employmentHistoryMap.get(empId).Supervisor_s_Zip_Code__c);
                        responseDataMap.put('SACity', employmentHistoryMap.get(empId).Supervisor_s_City__c);
                        responseDataMap.put('JobDuties', employmentHistoryMap.get(empId).Job_Responsibilities_Duties__c);
                        
                        if(String.isNotBlank(employmentHistoryMap.get(empId).Total_Hours_Claimed__c)){
                            responseDataMap.put('TotalHoursClaimed', Integer.valueOf(employmentHistoryMap.get(empId).Total_Hours_Claimed__c));
                            responseDataMap.put('TotalHoursClaimedRO', Integer.valueOf(employmentHistoryMap.get(empId).Total_Hours_Claimed__c));
                        }
                         
                        responseDataMap.put('fieldVisibility', fieldVisibility);
                        
                        responseDataMap.put('fieldVisibilityCheckApprExp', BOARD_NAME_CHECK_APPROPRIATE_SET.contains(boardName));
                        
                        if (employmentHistoryMap.get(empId).EmploymentStatus == VAR_VERIFIED) {
                            responseDataMap.put('PleaseSpecifyReadOnly', employmentHistoryMap.get(empId).Please_specify__c);
                            responseDataMap.put('CountryReadOnly', employmentHistoryMap.get(empId).EmployerCountry);
                            
                            responseDataMap.put('CheckAppropriateExperiencesRO', employmentHistoryMap.get(empId).Check_Appropriate_Experiences__c);
                            
                            responseDataMap.put('CheckAppropriateExperiencesMassageTherapistRO', employmentHistoryMap.get(empId).Check_Appropriate_Experiences__c);
                            
                            if (employmentHistoryMap.get(empId).EmployerCountry != VAR_UNITED_STATES) {
                                responseDataMap.put('StateReadOnly', employmentHistoryMap.get(empId).EmployerState);
                            } else {
                                responseDataMap.put('StateSelectReadOnly', employmentHistoryMap.get(empId).EmployerState);
                            }
                        } else {
                            responseDataMap.put('PleaseSpecify', employmentHistoryMap.get(empId).Please_specify__c);
                            responseDataMap.put('Country', employmentHistoryMap.get(empId).EmployerCountry);
                             
                            responseDataMap.put('CheckAppropriateExperiences', employmentHistoryMap.get(empId).Check_Appropriate_Experiences__c);
                             
                            responseDataMap.put('CheckAppropriateExperiencesMassageTherapist', employmentHistoryMap.get(empId).Check_Appropriate_Experiences__c);
                            
                            if (employmentHistoryMap.get(empId).EmployerCountry != VAR_UNITED_STATES) {
                                responseDataMap.put('State', employmentHistoryMap.get(empId).EmployerState);
                            } else {
                                responseDataMap.put('StateSelect', employmentHistoryMap.get(empId).EmployerState);
                            }
                        }
                        
                        responseDataMap.put('hideSupervisorAddress', SUPERVISORS_ADDRESS_CHECK_RAT_SET.contains(regAuthTypeName));
                         
                        responseDataList.add(responseDataMap);
                    }
                    outMap.put('EmploymentHistoryDetails', responseDataList);
                }
            }
            
            outMap.put('fieldVisibility', fieldVisibility);
            outMap.put('BoardName', boardName);
            outMap.put('regAuthTypeName', regAuthTypeName);
             
            outMap.put('fieldVisibilityCheckApprExp', BOARD_NAME_CHECK_APPROPRIATE_SET.contains(boardName));
            
            outMap.put('hideSupervisorAddress', SUPERVISORS_ADDRESS_CHECK_RAT_SET.contains(regAuthTypeName));
            
        }
    }
    
}