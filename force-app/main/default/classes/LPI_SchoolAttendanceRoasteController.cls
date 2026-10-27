/**
 * @author      : MTX Group Product Team
 * @since       : 30 Jan, 2023
 * @description : This Class Contains the Business Logic related to Real Estate Education Attendance Roaster application
 */
global with sharing class LPI_SchoolAttendanceRoasteController implements Callable {
    private static final String CLASS_NAME = 'LPI_SchoolAttendanceRoasteController';
    private static final String METHOD_INVOKE_METHOD = 'invokeMethod';
    private static final String METHOD_GET_COURSE_DETAILS_BY_COURSE_ID = 'getCourseDetailsByCourseId';
     
    private static final String METHOD_GET_COURSE_PARTICIPANT_DETAILS = 'getCourseParticipantDetails';
    private static final String METHOD_CREATE_TRIAINING_COURSE_PARTICIPANT = 'createTrainingCourseParticipant';
    private static final String METHOD_GET_ACCOUNT_BY_SSN = 'getAccountBySSN';
    private static final String PAR_ID = 'parId';
    private static final String FIELD_COURSE_ID = 'Course_ID__c';
    private static final String COURSE_ID_NUMBER = 'CourseIdNumber';
    private static final String COURSE_TITLE = 'CourseTitle';
    private static final String COURSE_COMPLETION_DATE = 'CourseCompletionDate';
    private static final String COURSE_TYPE = 'CourseType';
    private static final String RS_COURSE = 'Course';
    private static final String NAME_OF_INSTRUCTOR = 'NameOfTheInstructor';
    private static final String COURSE_STREET = 'CourseStreet';
    private static final String COURSE_CITY = 'CourseCity';
    private static final String COURSE_STATE = 'CourseStat';
    private static final String COURSE_STATE_CODE = 'CourseStateCode';
    private static final String COURSE_ZIPCODE = 'CourseZipcode';
    private static final String COURSE_INFORMATION = 'CourseInformation';
    private static final String IS_COURSE_EXIST = 'IsCourseExisit';
    private static final String COURSE_OFFERING_ID = 'CourseOfferingId';
    private static final String TRAINING_COURSE_ID = 'TrainingCourseId';
    private static final String ID_STR = 'Id';
    private static final String SOCIAL_SECURITY_NUMBER = 'SocialSecurityNumber';
    private static final String SSN_NUMBER = 'SSNNumber';
    private static final String FIRST_NAME = 'PersonFirstName';
    private static final String LAST_NAME = 'PersonLastName';
    private static final String MIDDLE_NAME = 'PersonMiddleName';
    private static final String CONTACT_ID = 'AccPersonContactId';
    private static final String CREDIT_HOURS = 'StudentInformationCreditHours';
    private static final String SSN_BLOCK = 'SocialSecurityNumber-Block';
    private static final String STUDENT_DETAILS = 'StudentDetails';
    private static final String STUDENT_INFORMATION = 'StudentInformation';
    private static final String NOT_VERIFIED = 'Not Verified';
    private final static String INPUT = 'input';
    private final static String OUTPUT = 'output';
    private final static String OPTIONS = 'options';
    private final static List<String> LIST_OF_ACCOUNT_FIELDS = new List<String>{
        'Id', 'Social_security_number__c', 'Name', 'PersonContactId', 'Personcontact.Name', 'Personcontact.Firstname', 
        'Personcontact.Middlename', 'Personcontact.Lastname'
    };    
    
    private static final List<String> LIST_OF_COURSE_OFFERING_FIELDS = new List<String> {
        'Id', 'CourseName.Course_ID__c', 'CourseName.Name', 'EndDate', 'CourseName.Course_Type__c',
        'CourseName.Course__c','LocationId', 'Name_of_the_Instructor__c','CourseNameId'
    };
    private static final List<String> LIST_OF_PARTICIPANT_FIELDS = new List<String> {
        'Id', 'Preliminary_Application_Reference__c', 'Contact.Account.Social_Security_Number__c',
        'Contact.FirstName', 'Contact.LastName', 'Contact.MiddleName', 'ContactId' , 'Approved_Hours__c'
    };
    
    global Object call(String action, Map<String, Object> args) {
        Map<String, Object> input = (Map<String, Object>) args.get(INPUT);
        Map<String, Object> output = (Map<String, Object>) args.get(OUTPUT);
        Map<String, Object> options = (Map<String, Object>) args.get(OPTIONS);
        return invokeMethod(action, input, output, options);
    }
    
    private Boolean invokeMethod(String methodName, Map<String, Object> inputMap, 
        Map<String, Object> outMap, Map<String, Object> options) {
        Boolean result = true;
        try {
            if(METHOD_GET_COURSE_DETAILS_BY_COURSE_ID.equalsIgnoreCase(methodName)) {
                getCourseDetailsByCourseId(inputMap, outMap);
            } 
             
            else if(METHOD_GET_COURSE_PARTICIPANT_DETAILS.equalsIgnoreCase(methodName)) {
                getCourseParticipantDetails(inputMap, outMap);
            } else if(METHOD_CREATE_TRIAINING_COURSE_PARTICIPANT.equalsIgnoreCase(methodName)) {
                createTrainingCourseParticipant(inputMap, outMap);
            } else if(METHOD_GET_ACCOUNT_BY_SSN.equalsIgnoreCase(methodName)) {
                outMap.put('SocialSecurityNumber-Block', getAccountBySSN(inputMap));
            }else if('getIntegerationMetadataRecord'.equalsIgnoreCase(methodName)) {
                getIntegerationMetadataRecord(inputMap, outMap);
            }
             
            else if (methodName.equals('fetchCourseOfferings')) {
                outMap.put('classRecords',fetchCourseOfferings(inputMap));
            }
            else {
                result = false;
            }
            return result;
        } catch (Exception exceptionInstance) {
            LPI_ExceptionManager.logException(CLASS_NAME, METHOD_INVOKE_METHOD ,
                exceptionInstance);
            return false;
        }
    }

     
    private static void getIntegerationMetadataRecord(Map<String, Object> inputMap, Map<String, Object> outputMap) {
         outputMap.put('warningMessage','Here is the warining');
    }
    /**
     * @author                       : MTX Group Product Team
     * @since                        : Dec 22, 2022
     * @description                  : get course details assocaiated with the PAR
     * @param inputMap               : input map
     * @param outputMap              : output map
     * @return                       : void
     */
    public static void getCourseDetailsByCourseId(Map<String, Object> inputMap, Map<String, Object> outputMap) {
        try {
            Set<Id> setOfLocationId = new Set<Id>();
            List<PreliminaryApplicationRef> listOfPAR = 
                LPI_PreliminaryApplicationRefDAO.getPreliminaryApplicationRefByDymanicQuery(
                FIELD_COURSE_ID, 'ID = \'' + String.escapeSingleQuotes((String) inputMap.get(PAR_ID)) + '\'',
                null, null, null);
            String courseOfferingId;
            if(!listOfPAR.isEmpty()) {
                courseOfferingId = listOfPAR[0].Course_ID__c;
            }
            if(String.isNotEmpty(courseOfferingId)) {
                for (CourseOffering course : 
                     new LPI_CourseOfferingDAO.LPI_CourseOfferingWithoutSharingDAO().getCourseOfferingByDymanicQuery(
                                            String.join(LIST_OF_COURSE_OFFERING_FIELDS, ','),
                                            'Id = \'' + String.escapeSingleQuotes(courseOfferingId) + '\'',
                                            null, null, null
                )) {
                    setOfLocationId.add(course.LocationId);
                    outputMap.put(COURSE_ID_NUMBER, course.CourseName.Course_ID__c + '-' + course.Name_of_the_Instructor__c + '-' + Date.valueOf(course.EndDate).format());
                    outputMap.put(COURSE_TITLE, course.CourseName.Name);
                    outputMap.put(COURSE_COMPLETION_DATE, course.EndDate.format('yyyy-MM-dd'));
                    outputMap.put('courseCompletionDateFC', course.EndDate.format('MM/dd/yyyy'));
                    outputMap.put(COURSE_TYPE, String.valueOf(course.CourseName.Course_Type__c));
                    outputMap.put(RS_COURSE, String.valueOf(course.CourseName.Course__c));
                    outputMap.put(NAME_OF_INSTRUCTOR, course.Name_of_the_Instructor__c);
                    outputMap.put(COURSE_OFFERING_ID, course.Id);
                    outputMap.put(TRAINING_COURSE_ID, course.CourseNameId);
                
                }
                if (!setOfLocationId.isEmpty()) {
                    for (Schema.Address address : new LPI_AddressDAO.LPI_AddressDAOWithoutSharing().getAddressByDymanicQuery(
                        'ParentId, Street, City, State, StateCode, PostalCode,County__c',
                        'parentId IN ' + LPI_ServiceUtility.getStringValuesBySet(setOfLocationId), '1', null, null)) {
                            
                        outputMap.put(COURSE_STREET, address.Street);
                        outputMap.put(COURSE_CITY, address.City);
                        outputMap.put(COURSE_STATE, address.State);
                        outputMap.put(COURSE_STATE_CODE, address.StateCode);
                        outputMap.put(COURSE_ZIPCODE, address.PostalCode);
                    }
                }
            }
        } catch (Exception exceptionInstance) {
            LPI_ExceptionManager.logException(CLASS_NAME, METHOD_GET_COURSE_DETAILS_BY_COURSE_ID ,
                exceptionInstance);
        }
    }
    
    

    /**
     * @author                       : MTX Group Product Team
     * @since                        : Dec 22, 2022
     * @description                  : get Course Participant Details
     * @param inputMap               : input map
     * @param outputMap              : output map
     * @return                       : void
     */
    public static void getCourseParticipantDetails(Map<String, Object> inputMap, Map<String, Object> outputMap) {
        List<Map<String, Object>> listOfStudentDetails = new List<Map<String, Object>>();
        Integer noOfRecords = 0;
        try {
            for (TrainingCourseParticipant participant : 
                new LPI_TrainingCourseParticipantDAO.LPI_TrainingCourseParticipantWithoutSharingDAO().getTrainingCourseParticipantByDymanicQuery(
                    String.join(LIST_OF_PARTICIPANT_FIELDS, ','),
                    'Preliminary_Application_Reference__c = \'' + String.escapeSingleQuotes((String) inputMap.get('parId'))
                    + '\' AND ContactId != NULL', null, null, null)) 
            {
                noOfRecords = noOfRecords + 1;
                Map<String, Object> mapOfParticipantTABlock = new Map<String, Object>();
                mapOfParticipantTABlock.put(SOCIAL_SECURITY_NUMBER, participant.Contact?.Account?.Social_Security_Number__c);
                mapOfParticipantTABlock.put(SSN_NUMBER, participant.Contact?.Account?.Social_Security_Number__c);
                mapOfParticipantTABlock.put(FIRST_NAME, participant.Contact?.FirstName);
                mapOfParticipantTABlock.put(LAST_NAME, participant.Contact?.LastName);
                mapOfParticipantTABlock.put(MIDDLE_NAME, participant.Contact?.MiddleName);
                mapOfParticipantTABlock.put(CONTACT_ID, participant?.ContactId);
                listOfStudentDetails.add(
                    new Map<String, Object>{ SSN_BLOCK => mapOfParticipantTABlock , 
                                            CREDIT_HOURS => participant?.Approved_Hours__c ,
                                            'NoOfRecords' => 'Student ' + String.ValueOf(noOfRecords)
                                            });
            }
            outputMap.put(STUDENT_DETAILS, listOfStudentDetails);
        } catch (Exception exceptionInstance) {
            LPI_ExceptionManager.logException(CLASS_NAME, METHOD_GET_COURSE_PARTICIPANT_DETAILS ,
                exceptionInstance);
        }
    }

    /**
     * @author                       : MTX Group Product Team
     * @since                        : Dec 22, 2022
     * @description                  : create TrainingCourseParticipant records for Attendance Roaster Application
     * @param inputMap               : input map
     * @param outputMap              : output map
     * @return                       : void
     */
    private static void createTrainingCourseParticipant(Map<String, Object> inputMap, Map<String, Object> outputMap) {
        try {
            String parId = (String) inputMap.get(PAR_ID);
            Map<String, Object> CourseInformationRecords = (Map<String, Object>) inputMap.get('CourseInformation');
            Map<String, Object> CourseIdNumberBlock = (Map<String, Object>) CourseInformationRecords.get('CourseIdNumber-Block');
            String courseOfferingId = (String) CourseIdNumberBlock.get('CourseOfferingId');
            String TrainingCourseId = (String) CourseIdNumberBlock.get('TrainingCourseId');
            List<TrainingCourseParticipant> listOfParticipant = 
                LPI_TrainingCourseParticipantDAO.getTrainingCourseParticipantByDymanicQuery( ID_STR,
                'Preliminary_Application_Reference__c = \'' + String.escapeSingleQuotes(parId) + '\'', null, null, null);
            LPI_WithoutSharingUtility.deleteSObject(listOfParticipant);
            
            List<TrainingCourseParticipant> listOfParticipants = new List<TrainingCourseParticipant>();
            Map<String, Object> mapOfStudentInformation = (Map<String, Object>) inputMap.get(STUDENT_INFORMATION);
            List<Object> listOfStudentDetails;
            if(mapOfStudentInformation.get(STUDENT_DETAILS) instanceof Map<String, Object> ) {
                Map<String, Object> mapOfStudentDetails = (Map<String, Object>)mapOfStudentInformation.get(STUDENT_DETAILS);
                Map<String, Object> mapOfContactInfo = (Map<String, Object>) mapOfStudentDetails.get(SSN_BLOCK);
                listOfParticipants.add(
                    new TrainingCourseParticipant(
                        Preliminary_Application_Reference__c = parId,
                        CourseOfferingId = courseOfferingId,
                        ContactId = (String) mapOfContactInfo.get(CONTACT_ID),
                        VerificationStatus = NOT_VERIFIED,
                        Training_Course__c=TrainingCourseId,
                        Approved_Hours__c = Integer.valueOf(mapOfStudentDetails.get('StudentInformationCreditHours'))
                    )
                );
            } else{
                listOfStudentDetails = (List<Object>) mapOfStudentInformation.get(STUDENT_DETAILS);
                for (Object studentDetail : listOfStudentDetails) {
                    Map<String, Object> mapOfObj = (Map<String, Object>) studentDetail;
                    Map<String, Object> block = (Map<String, Object>) mapOfObj.get(SSN_BLOCK);
                    listOfParticipants.add(
                        new TrainingCourseParticipant(
                        Preliminary_Application_Reference__c = parId,
                        CourseOfferingId = courseOfferingId,
                        ContactId = (String) block.get(CONTACT_ID),
                        VerificationStatus = NOT_VERIFIED ,
                        Training_Course__c=TrainingCourseId,
                        Approved_Hours__c = Integer.valueOf(mapOfObj.get('StudentInformationCreditHours'))
                    ));
                }
            }       
            if (!listOfParticipants.isEmpty()) {
                LPI_WithoutSharingUtility.insertSObjectList(listOfParticipants);
            }
        } catch (Exception exceptionInstance) {
            LPI_ExceptionManager.logException(CLASS_NAME, METHOD_CREATE_TRIAINING_COURSE_PARTICIPANT ,
                exceptionInstance);
        }
    }
    
    /**
     * @author                       : MTX Group Product Team
     * @since                        : Dec 22, 2022
     * @description                  : get Account by SSN
     * @param inputMap               : input map
     * @param outputMap              : output map
     * @return                       : void
     */
    private static Map<String, object> getAccountBySSN(Map<String, Object> inputMap) {
        List<Map<String, Object>> ssnDetailsList = new List<Map<String, Object>>();
        Map<String, Object> accountMap = new Map<String, Object>();
        try {
            String ssnNumber = (String) inputMap.get('SocialSecurityNumber');
            if(String.isBlank(ssnNumber)) {
                return accountMap;
            }
            
            for(Account account : new LPI_AccountDAO.LPI_AccountWithoutSharingDAO().getAccountByDymanicQuery(
                String.join(LIST_OF_ACCOUNT_FIELDS, ','),
                'Social_Security_Number__c = \'' + String.escapeSingleQuotes(ssnNumber) + '\'',
                '1', null, null)) {
                accountMap.put('PersonFirstName', account.Personcontact.Firstname);
                accountMap.put('PersonLastName', account.Personcontact.Lastname);
                accountMap.put('PersonMiddleName', account.Personcontact.Middlename);
                accountMap.put('PersonContactName', account.Personcontact.Name);
                accountMap.put('AccPersonContactId', account.PersonContactId);
                accountMap.put('ssn', account.Social_security_number__c);
                accountMap.put('SSNNumber', account.Social_security_number__c);
                accountMap.put('SocialSecurityNumber', account.Social_security_number__c);
                accountMap.put('DesignatedAccNameBySSN', account.Name);
                accountMap.put('AccountId', account.Id);
                ssnDetailsList.add(accountMap);
            }            
        }catch (Exception exceptionInstance) {
            LPI_ExceptionManager.logException(CLASS_NAME, METHOD_GET_ACCOUNT_BY_SSN ,
                exceptionInstance);
        }
        return accountMap;
    }

    /**
    * @description                         : Based on Course ID this method returns course details for each item and for a specified parid.
    * @author                              : MTX Group Product Team
    * @since                               : 11 Jan, 2024
    * @param inputMap                      : fetching all the input from Omniscript
    * @return `List<Map<String, Object>>`  : returns the list of items that has Training Course infromation and Course Offering details.
    * @last modified by                    : MTX Group Product Team
    * @last modified date                  : 11 Jan, 2024
    * @last modified details               : Code Fixes
    **/
    private static List<Map<String, Object>> fetchCourseOfferings(Map<String, Object> inputMap) {
        try{
            String courseId = '%' + (String) inputMap.get('CourseIdNumber') + '%';
            String parid = (String) inputMap.get('parid');
            String accountId = LPI_PreliminaryApplicationRefDAO.getPARRecordsByParId(parId)[0].BusinessAccountNameId;
            List<Map<String,Object>> courseNameMapList = new List<Map<String,Object>>();
            Map<Id,Schema.Address> courseIdToAddressMap = new Map<Id,Schema.Address>();
            Map<Id,Id> locationIdToCourseIdMap = new Map<Id,Id>();
            Map<String,Object> courseNameMap;
            Set<Id> setOfLocationId = new Set<Id>();
            
            String cofields = 'Name,CourseNameId,Name_of_the_Instructor__c,EndDate,CourseName.Course_Type__c,CourseName.Course__c,CourseName.Name,LocationId';
            String coWhereClause = 'CourseName.Course_ID__c LIKE \'' + 
                                    String.escapeSingleQuotes(courseId) + 
                                    '\' AND CourseName.Account__r.Id = \'' + 
                                    accountId + '\'';

            List<CourseOffering> coList = LPI_CourseOfferingDAO.getCourseOfferingByDymanicQuery(cofields,coWhereClause,null,null,null);     
            for(CourseOffering co : coList){
                if(!locationIdToCourseIdMap.containsKey(co.LocationId)){
                    locationIdToCourseIdMap.put(co.LocationId, co.Id);
                }
            }

            for(Schema.Address address : LPI_AddressDAO.getAddressByParentId(locationIdToCourseIdMap.keySet())){  
                String coId = locationIdToCourseIdMap.get(address.ParentId);
                if(!courseIdToAddressMap.containsKey(coId)){
                    courseIdToAddressMap.put(coId,address);
                }
            } 
            for(CourseOffering courseOffering : coList){
                courseNameMap = new Map<String,Object>();
                setOfLocationId.add(courseOffering.LocationId);
                courseNameMap.put(COURSE_TITLE,courseOffering.CourseName.Name) ;
                courseNameMap.put('TypeAheadKeyName',courseOffering.Name+'-'+courseOffering.Name_of_the_Instructor__c+'-'+Date.valueOf(courseOffering.EndDate).format());
                courseNameMap.put(COURSE_COMPLETION_DATE,courseOffering.EndDate);
                courseNameMap.put(COURSE_TYPE,courseOffering.CourseName.Course_Type__c);
                courseNameMap.put(RS_COURSE,courseOffering.CourseName.Course__c);
                courseNameMap.put(NAME_OF_INSTRUCTOR,courseOffering.Name_of_the_Instructor__c);
                courseNameMap.put(COURSE_OFFERING_ID, courseOffering.Id);
                courseNameMap.put(TRAINING_COURSE_ID, courseOffering.CourseNameId);
                if(courseIdToAddressMap.containsKey(courseOffering.Id)){
                    courseNameMap.put(COURSE_STREET, courseIdToAddressMap.get(courseOffering.Id).Street);
                    courseNameMap.put(COURSE_CITY, courseIdToAddressMap.get(courseOffering.Id).City);
                    courseNameMap.put(COURSE_STATE, courseIdToAddressMap.get(courseOffering.Id).State);
                    courseNameMap.put(COURSE_STATE_CODE, courseIdToAddressMap.get(courseOffering.Id).StateCode);
                    courseNameMap.put(COURSE_ZIPCODE, courseIdToAddressMap.get(courseOffering.Id).PostalCode);
                    courseNameMapList.add(courseNameMap);
                }
            }
            return courseNameMapList;
        } catch (Exception e) {
            LPI_ExceptionManager.logException('LPI_ScheduleEducationClassController','fetchCourseOfferings',e);
            return null;
        }
    }
}