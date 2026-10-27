/**
 * @author          : MTX Group Product Team
 * @description     : This class is responsible for managing the Real Estate Appraiser board Information. 
 *                    It has methods to upsert, fetch and delete Course records.
 */
global with sharing class LPI_REACourseInformationController implements Callable {
    private final static String FETCH_COURSE_DETAILS = 'fetchCourseInformation';
    private final static String SAVE_COURSE_INFORMATION = 'saveCourseInformation';
    private final static String CLASS_NAME = 'LPI_REACourseInformationController';
    private final static String DELETE_INSTRUCTOR_DETAILS = 'deleteInstructorInformation';
    private final static String UPSERT_INSTRUCTOR_DETAILS = 'upsertInstructorInformation';
    public static final string CONTINUING_EDUCATION_PROVIDER = 'Continuing Education Provider';
    public static final string DESIGNATED_INCHARGE = 'Designated Incharge';
    private final static String SAVE_CONTACT_PERSON_DETAILS = 'saveContactPersonDetails';
    private final static String INSERT_ACCOUNT_CONTACT_RECORD = 'insertAccountContactRecord';
    private final static String CREATE_CONTACT_RECORD = 'createContactPersonAccount';
    private final static String CREATE_COURSE_FOR_RENEWAL = 'createCourseForRenewal';
    private final static String QUALIFYING_EDUCATION = 'Qualifying Education';
    
    
    global Object call(String action, Map<String, Object> args) {
        Map<String, Object> input = (Map<String, Object>) args.get('input');
        Map<String, Object> output = (Map<String, Object>) args.get('output');
        Map<String, Object> options = (Map<String, Object>) args.get('options');

        return invokeMethod(action, input, output, options);
    }
    
    /**
     * @author            : MTX Group Product Team
     * @lastModifiedBy    : MTX Group Product Team
     * @param methodName  : The name of the method to be executed.
     * @param inputMap    : Input Parameter Passed from Omniscript
     * @param outMap      : Output Passed to Omniscript
     * @param options     : Extra Options passed from Omniscript
     * @return Boolean    : Returns true if the method is successfully executed, else false.
     */
    
    private Boolean invokeMethod(
        String methodName,
        Map<String, Object> inputMap,
        Map<String, Object> outMap,
        Map<String, Object> options
    ) {
        Boolean result = true;
        try{
            if(methodName == FETCH_COURSE_DETAILS) {
                fetchCourseInformation(inputMap, outMap, options);
            }else if(methodName == SAVE_COURSE_INFORMATION){
                saveCourseInformation(inputMap, outMap, options);
            }else if (methodName == UPSERT_INSTRUCTOR_DETAILS) {
				upsertInstructorInformation(inputMap, outMap, options);
			}else if (methodName == DELETE_INSTRUCTOR_DETAILS) {
                deleteInstructorInformation(inputMap, outMap, options);
            }else if (methodName == SAVE_CONTACT_PERSON_DETAILS) {
				saveContactPersonDetails(inputMap, outMap);
			}else{
                result = false;
            }            
        } catch(Exception e){
            LPI_ExceptionManager.logException(CLASS_NAME, 'invokeMethod', e);
            result = false;
        }
        return result;
    }
    
     /**
     * @description       : This method is responsible for fetching Course details entered by the user
     * @author            : 
     * @lastModifiedBy    : 
     * @param inputMap    : fetching all the input from Omniscript
     * @param outMap      : Passing value to Omniscript
     * @param options     : Passing Options to Omniscript if needed
     */
    
    public static void fetchCourseInformation(
        Map<String, Object> inputMap,
        Map<String, Object> outputMap,
        Map<String, Object> options
    ) {
        try {
             
            String parId = ''; 
            String availableParId = (String) inputMap.get('parId');
            String trCourseId = (String) inputMap.get('TrnCourseID');
            Map<Id, Map<String, Object>> intructorInfoMap = new  Map<Id, Map<String, Object>>();
            if(String.isNotBlank(trCourseId)){
                List<TrnCourse> trnCourse = [select Id,Course_ID__c,Preliminary_Application_Reference__r.Id from TrnCourse where Id  =: trCourseId ];
                if(!trnCourse.isEmpty()){
                    parId = trnCourse[0]?.Preliminary_Application_Reference__r?.Id;
                }
            }else{
                parId = availableParId;
            }
            Integer noOfRecords = 0;
            if(String.isNotBlank(parId)){
                 
                String fields = 'Id, Name, Name_of_the_Instructor__c,Owner_of_Course_Materials__c,'
                    + 'CourseName.Name, CourseName.Delivery_Method__c, CourseName.Course__c, CourseName.TotalCredits,'
                    + 'CourseName.Course_Type__c,Number_of_Classroom_Hours__c,Number_of_Exam_Hours__c';
                String whereClause = 'Preliminary_Application_Reference__c = \'' + String.escapeSingleQuotes(parId) + '\'';
                List<CourseOffering> instructorInformationList = LPI_CourseOfferingDAO.getCourseOfferingByDymanicQuery(
                    fields, whereClause, null, null, null);
                if(!instructorInformationList.isEmpty()){
                    Integer instructorCount = 0;
                    for(CourseOffering instructor : instructorInformationList){
                        Map<String, Object> instMap = new Map<String, Object>();
                        instructorCount = instructorCount + 1;
                        instMap.put('InstructorPresenterName', instructor.Name_of_the_Instructor__c);
                        instMap.put('CourseTitle', instructor.CourseName.Name);
                        instMap.put('DeliveryMethod', instructor.CourseName.Delivery_Method__c);
                        instMap.put('NumberOfExamHours', instructor.Number_of_Exam_Hours__c);
                        instMap.put('NumberOfClassroomHours', instructor.Number_of_Classroom_Hours__c);
                        instMap.put('OwnerOfCourseMaterial', instructor.Owner_of_Course_Materials__c);
                        instMap.put('Category', instructor.CourseName.Course__c);
                        instMap.put('CECourseType', instructor.CourseName.Course__c);
                        instMap.put('CrsOffId', instructor.Id);
                        instMap.put('TrnCrsID', instructor.CourseName.Id);
                        instMap.put('NoOfRecords', 'Instructor ' + String.ValueOf(instructorCount));
                        intructorInfoMap.put(instructor.Id, instMap);
                    }
                    outputMap.put('CourseTitle',instructorInformationList[0].CourseName.Name);
                    outputMap.put('NumberOfExamHours',instructorInformationList[0].Number_of_Exam_Hours__c);
                    outputMap.put('NumberOfClassroomHours',instructorInformationList[0].Number_of_Classroom_Hours__c);
                    outputMap.put('CECourseType',instructorInformationList[0].CourseName.Course__c);
                    outputMap.put('DeliveryMethod',instructorInformationList[0].CourseName.Delivery_Method__c);
                    outputMap.put('OwnerOfCourseMaterial',instructorInformationList[0].Owner_of_Course_Materials__c);
                }
                
                if (!intructorInfoMap.isEmpty()) {
                    outputMap.put('InstructorInfoEditBlock', new List<Map<String, Object>>(intructorInfoMap.values()));
                    
                    List<Map<String, Object>> instructorInfoList = new List<Map<String, Object>>(intructorInfoMap.values());
					Map<String, Object> courseInfoMap = instructorInfoList[0];
    				outputMap.put('CourseInfoEditBlock', courseInfoMap);
                }
            }
        } catch (Exception e) {
            LPI_ExceptionManager.logException(CLASS_NAME, FETCH_COURSE_DETAILS, e);
            throw new LPI_Exception('Problem in Fetching the instructor details', e);
        }
    }

    /**
     * @description       : This method is responsible for upserting Course details entered by the user
     * @author            :  MTX Group Product Team
     * @lastModifiedBy    : MTX Group Product Team
     * @param inputMap    : fetching all the input from Omniscript
     * @param outMap      : Passing value to Omniscript
     * @param options     : Passing Options to Omniscript if needed
     */
    
    private static void upsertInstructorInformation(
        Map<String, Object> inputMap,
        Map<String, Object> outMap,
        Map<String, Object> options) {
        try 
        {
            String parId = (String) inputMap.get('parId');
            String accountId = '';
            if(String.isNotBlank(parId)){
                String fields = 'Id, BusinessAccountNameId';
                String whereClause = '';
                List<PreliminaryApplicationRef> parList;
                whereClause = 'Id = \'' + String.escapeSingleQuotes(parId) + '\'';
                parList = LPI_PreliminaryApplicationRefDAO.getPreliminaryApplicationRefByDymanicQuery(fields, whereClause, null, null, null); 
                accountId = parList[0].businessAccountNameId;

                
                Map<String, String> trnCoursekeyMapping = new Map<String, String> {
                    'CECourseType' => 'Course__c',
                    'CourseTitle' => 'Name',
                    'DeliveryMethod' => 'Delivery_Method__c'
                };
                TrnCourse trnCou = (TrnCourse) LPI_VlocityUtility.createSObject(inputMap, trnCoursekeyMapping, 'TrnCourse');
                trnCou.Preliminary_Application_Reference__c = parId;
                trnCou.Course_Type__c = CONTINUING_EDUCATION_PROVIDER;
                LPI_WithoutSharingUtility.upsertSObject(trnCou);
                
                
                Map<String, String> courseOffkeyMapping = new Map<String, String> {
                    'InstructorPresenterName' => 'Name_of_the_Instructor__c',
                    'CourseTitle' => 'Name',
                    'OwnerOfCourseMaterial' => 'Owner_of_Course_Materials__c',
                    'NumberOfExamHours' => 'Number_of_Exam_Hours__c',
                    'NumberOfClassroomHours' => 'Number_of_Classroom_Hours__c'
                };
                
                CourseOffering crsOffering = (CourseOffering) LPI_VlocityUtility.createSObject(inputMap, courseOffkeyMapping, 'CourseOffering');
                crsOffering.Preliminary_Application_Reference__c = parId;
                crsOffering.CourseNameId = trnCou.Id;
                LPI_WithoutSharingUtility.upsertSObject(crsOffering);
                outMap.put('TrnCrsID', trnCou.Id);
                outMap.put('CrsOffId', crsOffering.Id);
            }
        }
         catch (Exception e) {
            LPI_ExceptionManager.logException(CLASS_NAME, UPSERT_INSTRUCTOR_DETAILS, e);
        }
    }

    /**
     * @description       : This method is responsible for delete Course details entered by the user
     * @author            : MTX Group Product Team
     * @lastModifiedBy    : MTX Group Product Team
     * @param inputMap    : fetching all the input from Omniscript
     * @param outMap      : Passing value to Omniscript
     * @param options     : Passing Options to Omniscript if needed
     */
    
    private static void deleteInstructorInformation(
        Map<String, Object> inputMap,
        Map<String, Object> outMap,
        Map<String, Object> options
    ) {
        try {
            if(inputMap.containsKey('CrsOffId')){
                List<CourseOffering> crsOffList = LPI_CourseOfferingDAO.getCourseOfferingByDymanicQuery(
                    'Id,Preliminary_Application_Reference__c', 'Id = \'' + String.escapeSingleQuotes((String)inputMap.get('CrsOffId')) + '\'', null, null, null
                );

                Boolean CourseOffDelete = false;
                if(!crsOffList.isEmpty()){
                    List<PreliminaryApplicationRef> CourseOffListUsingPar = LPI_PreliminaryApplicationRefDAO.getPreliminaryApplicationRefByDymanicQuery(
                        'Id',
                        'Id = \'' + crsOffList[0].Preliminary_Application_Reference__c + '\'',
                        null,
                        null,
                        null
                    );

                    if(!CourseOffListUsingPar.isEmpty()){
                        CourseOffDelete = true;
                        }
                    }
                    
                    if (CourseOffDelete) {
                        LPI_WithoutSharingUtility.deleteSObject(crsOffList);
                    }

                if(inputMap.containsKey('TrnCrsID')){
                    List<TrnCourse> trnCrsList = LPI_TrnCourseDAO.getTrnCourseByDymanicQuery(
                        'Id,Preliminary_Application_Reference__c ', 'Id = \'' + String.escapeSingleQuotes((String)inputMap.get('TrnCrsID')) + '\'', null, null, null
                    );

                    Boolean trnCourseDelete = false;
                    if(!trnCrsList.isEmpty()){
                        List<PreliminaryApplicationRef> trnCrsListUsingPar = LPI_PreliminaryApplicationRefDAO.getPreliminaryApplicationRefByDymanicQuery(
                            'Id,(SELECT Id FROM Training_Courses__r)',
                            'Id = \'' + trnCrsList[0].Preliminary_Application_Reference__c + '\'',
                            null,
                            null,
                            null
                        );

                        if(!trnCrsListUsingPar.isEmpty()){
                            for(TrnCourse trnParItem : trnCrsListUsingPar[0].Training_Courses__r){
                                if(trnParItem.Id == inputMap.get('TrnCrsID')){
                                    trnCourseDelete = true;
                                    break;
                                }
                            }
                        }
                    }
                    
                    if (trnCourseDelete) {
                        LPI_WithoutSharingUtility.deleteSObject(trnCrsList);
                    }
                }
            }
        } catch (Exception e) {
            LPI_ExceptionManager.logException(CLASS_NAME, DELETE_INSTRUCTOR_DETAILS, e);
            throw new LPI_Exception('Problem occured in deleting the record please contact admin', e);
        }
    }

    /**
     * @description       : This method is responsible for save Course details entered by the user
     * @author            : MTX Group Product Team
     * @lastModifiedBy    : MTX Group Product Team
     * @param inputMap    : fetching all the input from Omniscript
     * @param outMap      : Passing value to Omniscript
     * @param options     : Passing Options to Omniscript if needed
     */
    
    private static void saveCourseInformation(Map<String, Object> inputMap,Map<String, Object> outMap, Map<String, Object> options) {
        try{
             
            String parId = (String) inputMap.get('parId');
              
             String trnCourseId = (String) inputMap.get('TrnCourseID');
             if(String.isNotBlank(trnCourseId)){
                String trnCoufields = 'Id, Name, Course__c, Delivery_Method__c,Preliminary_Application_Reference__c';
                String trnCouWhereClause = 'Id = \'' + String.escapeSingleQuotes(trnCourseId) + '\'';
                List<TrnCourse> trnCrsList = LPI_TrnCourseDAO.getTrnCourseByDymanicQuery(trnCoufields, trnCouWhereClause, null, null, null);
                createCourseForRenewal(trnCrsList[0].Preliminary_Application_Reference__c,parId);
             }else{  
                if(String.isNotBlank(parId)){
                    String courseTitle  = (String) inputMap.get('CourseTitle');
                    String cECourseType  = (String) inputMap.get('CECourseType');
                    Decimal numberOfClassroomHours  = (Decimal)inputMap.get('NumberOfClassroomHours');
                    Object numberOfExamHours = inputMap.get('NumberOfExamHours');
                    Decimal numberOfExamHoursDecimal = null;

                    if(cECourseType.split(';').contains(QUALIFYING_EDUCATION)){
                        numberOfExamHoursDecimal = (Decimal)numberOfExamHours;
                    }

                    String deliveryMethod  = (String) inputMap.get('DeliveryMethod');
                    String ownerOfCourseMaterial  = (String) inputMap.get('OwnerOfCourseMaterial');
                    
                    List<CourseOffering> courseInfo = new List<CourseOffering>();
                    List<TrnCourse> trnCourseInfo = new List<TrnCourse>();
                    
                    String fields = 'Id, Name, Number_of_Classroom_Hours__c, Number_of_Exam_Hours__c, Owner_of_Course_Materials__c';
                    String whereClause = 'Preliminary_Application_Reference__c = \'' + String.escapeSingleQuotes(parId) + '\'';
                    List<CourseOffering> instInfoList = LPI_CourseOfferingDAO.getCourseOfferingByDymanicQuery(
                        fields, whereClause, null, null, null);
                     
                    if(!instInfoList.isEmpty()){
                        for(CourseOffering course : instInfoList){
                            course.Name = courseTitle;
                            course.Number_of_Classroom_Hours__c = numberOfClassroomHours;
                            course.Owner_of_Course_Materials__c = ownerOfCourseMaterial;
                            course.Number_of_Exam_Hours__c = numberOfExamHoursDecimal;
                            courseInfo.add(course);
                        }
                        if(!courseInfo.isEmpty()){
                            courseInfo = LPI_WithoutSharingUtility.upsertSObjectList(courseInfo);
                        }
                    }
                    
                    String trnCoufields = 'Id, Name, Course__c, Delivery_Method__c';
                    String trnCouWhereClause = 'Preliminary_Application_Reference__c = \'' + String.escapeSingleQuotes(parId) + '\'';
                    List<TrnCourse> trnCrsList = LPI_TrnCourseDAO.getTrnCourseByDymanicQuery(trnCoufields, trnCouWhereClause, null, null, null);
                    if(!trnCrsList.isEmpty()){
                        for(TrnCourse trnCourse : trnCrsList){
                            trnCourse.Name = courseTitle;
                            trnCourse.Course__c = cECourseType;
                            trnCourse.Delivery_Method__c = deliveryMethod;
                            trnCourseInfo.add(trnCourse);
                        }
                    }
                    if(!trnCourseInfo.isEmpty()){
                         trnCourseInfo = LPI_WithoutSharingUtility.upsertSObjectList(trnCourseInfo);
                    }
                    outMap.put('trnCrs',trnCourseInfo);
                }
              }
        }catch (Exception e) {
            LPI_ExceptionManager.logException(CLASS_NAME, SAVE_COURSE_INFORMATION, e);
            throw new LPI_Exception('Problem in Fetching the instructor details', e);
        }
    }

    /**
     * @description       : This method is responsible for creating course for renewal
     * @author            : MTX Group Product Team
     * @lastModifiedBy    : MTX Group Product Team
     * @param inputMap    : fetching all the input from Omniscript
     * @param outMap      : Passing value to Omniscript
     * @param options     : Passing Options to Omniscript if needed
     */
    
    @TestVisible private static void createCourseForRenewal(String trnCourseId,String parId){
        try{

            String trnCoufieldsPreviousRec = 'Id, Name, Course__c, Delivery_Method__c';
            String trnCouWhereClausePreviousRec = 'Preliminary_Application_Reference__c = \'' + String.escapeSingleQuotes(parId) + '\'';
            List<TrnCourse> trnCrsListForPreviousRecord = LPI_TrnCourseDAO.getTrnCourseByDymanicQuery(trnCoufieldsPreviousRec, trnCouWhereClausePreviousRec, null, null, null);

            if(trnCrsListForPreviousRecord.isEmpty()){
                  
                String trnCoufields = 'Id, Name, Course__c, Delivery_Method__c';
                String trnCouWhereClause = 'Preliminary_Application_Reference__c = \'' + String.escapeSingleQuotes(trnCourseId) + '\'';
                List<TrnCourse> trnCrsList = LPI_TrnCourseDAO.getTrnCourseByDymanicQuery(trnCoufields, trnCouWhereClause, null, null, null);    
                
                List<TrnCourse> trnCourseToBeCreateList = new List<TrnCourse>();

                if(!trnCrsList.isEmpty()){
                    for(TrnCourse trnCrs : trnCrsList){
                        TrnCourse newTrnCrs = new TrnCourse();
                        newTrnCrs.Name = trnCrs.Name;
                        newTrnCrs.Course__c = trnCrs.Course__c;
                        newTrnCrs.Delivery_Method__c = trnCrs.Delivery_Method__c;
                        newTrnCrs.Preliminary_Application_Reference__c = parId;
                        newTrnCrs.Course_Type__c = CONTINUING_EDUCATION_PROVIDER;
                        trnCourseToBeCreateList.add(newTrnCrs);
                    }
                }

                if(!trnCourseToBeCreateList.isEmpty()){
                    trnCourseToBeCreateList = LPI_WithoutSharingUtility.upsertSObjectList(trnCourseToBeCreateList);
                }

                List<CourseOffering> courseToBeCreateList = new List<CourseOffering>();
                 
                String fields = 'Id, Name, Number_of_Classroom_Hours__c, Number_of_Exam_Hours__c,Name_of_the_Instructor__c, Owner_of_Course_Materials__c';
                String whereClause = 'Preliminary_Application_Reference__c = \'' + String.escapeSingleQuotes(trnCourseId) + '\'';
                List<CourseOffering> courseInfoList = LPI_CourseOfferingDAO.getCourseOfferingByDymanicQuery(
                    fields, whereClause, null, null, null);

                if(!courseInfoList.isEmpty()){
                    Integer index = 0;
                    for(CourseOffering courseOff : courseInfoList){
                        CourseOffering course = new CourseOffering();
                        course.Name = courseOff.Name;
                        course.Name_of_the_Instructor__c = courseOff.Name_of_the_Instructor__c;
                        course.Number_of_Classroom_Hours__c = courseOff.Number_of_Classroom_Hours__c;
                        course.Number_of_Exam_Hours__c = courseOff.Number_of_Exam_Hours__c;
                        course.Owner_of_Course_Materials__c = courseOff.Owner_of_Course_Materials__c;
                        course.Preliminary_Application_Reference__c = parId;
                        course.CourseNameId = trnCourseToBeCreateList[index].Id;
                        courseToBeCreateList.add(course);
                        index++;
                    }
                }

                if(!courseToBeCreateList.isEmpty()){
                    courseToBeCreateList = LPI_WithoutSharingUtility.upsertSObjectList(courseToBeCreateList);
                }
            }

        }catch (exception e) {
			LPI_ExceptionManager.logException(CLASS_NAME, CREATE_COURSE_FOR_RENEWAL, e);
		}
    }

    /**
     * @description       : This method is responsible for creating contact person details entered by the user
     * @author            :  MTX Group Product Team
     * @lastModifiedBy    :  MTX Group Product Team
     * @param inputMap    : fetching all the input from Omniscript
     * @param outMap      : Passing value to Omniscript
     * @param options     : Passing Options to Omniscript if needed
     */
    public static void saveContactPersonDetails(Map<String, Object> inputMap, Map<String, Object> outMap) {
		try {
            String parId = (String) inputMap.get('parId');
            String businessAccId = (String) inputMap.get('businessAccId');
            Map<String, String> keyMappingPrimaryAcc = new Map<String, String>{
                'ContactName' => 'LastName',
                'EmailAddress' => 'PersonEmail',
                'ContactTelephoneNumber' => 'PersonHomePhone',
                'ContactFaxNumber' => 'Fax'
            };
			 
			createContactPersonAccount(
                inputMap,
                outMap,
                keyMappingPrimaryAcc,
                DESIGNATED_INCHARGE
            );
		} catch (Exception e) {
			LPI_ExceptionManager.logException(CLASS_NAME, SAVE_CONTACT_PERSON_DETAILS, e);
		}
	}

    /**
     * @description       : This method is responsible for creating contact person details entered by the user
     * @author            :MTX Group Product Team
     * @lastModifiedBy    : MTX Group Product Team
     * @param inputMap    : fetching all the input from Omniscript
     * @param outMap      : Passing value to Omniscript
     * @param options     : Passing Options to Omniscript if needed
     */
    public static void createContactPersonAccount(
		Map<String, Object> inputMap,
		Map<String, Object> outMap,
		Map<String, String> keyMapping,
		String role
	) {
		try {
			String personAccId = '';
            String perAccId = '';
			String parId = (String) inputMap.get('parId');
			String businessAccId = (String) inputMap.get('businessAccId');
            String primaryPerAccId=(String) inputMap.get('primaryPerAccId');
            perAccId = primaryPerAccId;
		    Map<String, object> contactStepInfo = (Map<String, object>) inputMap.get('REAContinuingEducationProviderContactPersonInfo');
			Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
				.get(LPI_LiteralConstant.ACCOUNT_PERSON_RECORDTYPE)
				.getRecordTypeId();
			Account acc = (Account) LPI_VlocityUtility.createSObject(contactStepInfo, keyMapping, 'Account');
			acc.put('RecordTypeId', accRecordTypeId);
			acc.put('PersonOtherCountryCode', 'US');
            String parQueryFields = 'Id';
			String parWhereClause = '';
			List<PreliminaryApplicationRef> parList;
			if (!String.isEmpty(parId)) {
				parWhereClause = 'Id = \'' + String.escapeSingleQuotes(parId) + '\'';
				parList = LPI_PreliminaryApplicationRefDAO.getPreliminaryApplicationRefByDymanicQuery(
					parQueryFields,
					parWhereClause,
					null,
					null,
					null
				);
			}
			 
			if (parList.isEmpty()) {
				return;
			}
			 
			if (String.isBlank(perAccId)) {
                List<Datacloud.MatchRecord> accList = new List<Datacloud.MatchRecord>();
                List<Account> existingAccountId = new List<Account>();
                 
                existingAccountId = LPI_RelationshipService.findDuplicates(new List<Account>{ acc });
				accList = LPI_ServiceUtility.getDuplicateRecordsService(new List<Account>{ acc });
				 
				if (existingAccountId.isEmpty()) {
					 
					Account securityDecision = (Account) LPI_DML.doInsert(acc);
					personAccId = securityDecision.Id;
					insertAccountContactRecord(businessAccId, String.escapeSingleQuotes(personAccId), Role);
				} else {
                    personAccId = existingAccountId[0].Id;
                     
					String accConQueryFields = 'Id';
					String accConWhereClauseFields =
						'Related_To__c=\'' +
						String.escapeSingleQuotes(businessAccId) +
						'\' AND Related_From__c=\'' +
						String.escapeSingleQuotes(personAccId) +
						'\' AND Roles__c=\'' +
						Role +
						'\'';
					List<Business_Relationships__c> accConRel = LPI_BusinessRelationshipDAO.fetchBusinessRelationshipRecords(
						accConQueryFields,
						accConWhereClauseFields
					);
				 
					if (accConRel.isEmpty()) {
						insertAccountContactRecord(businessAccId, personAccId, Role);
					}
				}
			} else {
			    
				acc.Id = perAccId;
				LPI_WithoutSharingUtility.updateSObject(acc);
				personAccId = perAccId;
			}
            outMap.put('primaryPerAccId', personAccId);
		} catch (exception e) {
			LPI_ExceptionManager.logException(CLASS_NAME, CREATE_CONTACT_RECORD, e);
		}
	}

    /**
     * @description       : This method is responsible for creating Relationship 
     * @author            : MTX Group Product Team
     * @lastModifiedBy    : MTX Group Product Team
     * @param inputMap    : fetching all the input from Omniscript
     * @param outMap      : Passing value to Omniscript
     * @param options     : Passing Options to Omniscript if needed
     */
    public static void insertAccountContactRecord(String busAccId, String perAccountId, String Role) {
		try {
			Business_Relationships__c accConRelation = new Business_Relationships__c();
			accConRelation.Related_To__c = busAccId;
			accConRelation.Related_From__c = perAccountId;
			accConRelation.Roles__c = Role;
			accConRelation.IsActive__c = false;
			accConRelation.Start_Date__c = System.today();
			LPI_WithoutSharingUtility.upsertSObject(accConRelation);
		} catch (exception e) {
			LPI_ExceptionManager.logException(CLASS_NAME, INSERT_ACCOUNT_CONTACT_RECORD, e);
		}
	}
}