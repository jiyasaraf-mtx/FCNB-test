/**
 * @author            : MTX Group Product Team
 * @description       : This Class Would be related to PAR
 *                      Fetching & updating the data on PAR
 *                      OS that can be referred for this is "HAPhysicianLimitedIntakeApplication"
 *
 * @last modified by  : MTX Group Product Team
**/

global with sharing class LPI_TrainingCourseController implements Callable{
    
    private static final String CLASS_NAME = 'LPI_TrainingCourseController';
    private static final String COURSE_DETAILS = 'Course Details';
    private static final String PAR_NOT_FOUND = 'PAR record is not created for the flow';
    private static final String CREATE_TRAINING_COURSE = 'createTrainingCourse';
    private static final String FETCH_TRAINING_COURSE = 'fetchTrainingCourses';
    private static final String CREATE_COURSE_INFORMATION = 'createCourseInformation';
     
    private static final String limitOne = '1';
    
    global Object call(String action, Map<String, Object> args) {
        Map<String, Object> input = (Map<String, Object>) args.get(LPI_LiteralConstant.INPUT);
        Map<String, Object> output = (Map<String, Object>) args.get(LPI_LiteralConstant.OUTPUT);
        Map<String, Object> options = (Map<String, Object>) args.get(LPI_LiteralConstant.OPTIONS);
        return invokeMethod(action, input, output, options);
    }

    /**
     * @author            MTX Group Product Team
     * @description       This method will compare method from Omniscript and execute only that specific method
     * @return  `Boolean`
     */
    private Boolean invokeMethod(
        String methodName,
        Map<String, Object> inputMap,
        Map<String, Object> outMap,
        Map<String, Object> options
    ) {
        Boolean result = true;
        try {
            if (CREATE_TRAINING_COURSE.equals(methodName)) {
                createTrainingCourse(inputMap, outMap);
            }
            else if(FETCH_TRAINING_COURSE.equals(methodName)){
                fetchTrainingCourses(inputMap,outMap);
            }
            else if(CREATE_COURSE_INFORMATION.equals(methodName)){
                createCourseInformation(inputMap,outMap);
            }
             
        } catch (Exception e) {
            result = false;
        }
        return result;
    }

    /**
     * @author              : MTX Group Product Team
     * @description         : This method is Used to Training Course
     * @param inputMap      : fetching all the input from Omniscript
     * @param outMap        : Passing value to Omniscript
     * @lastModifiedBy      : MTX Group Product Team
     * @lastModifiedDate    : 2 Feb, 2023
     * @lastModifiedDetails : Updated whole method with few standards
     */
    private static void createTrainingCourse(Map<String, Object> inputMap, Map<String, Object> outMap) {
        try {
             
            String parid = (String) inputMap.get('parid');
            if ( checkPARIsEmpty(parId, CREATE_TRAINING_COURSE) ) {
                return;
            }

            Map<String, Object> courseInfo = (Map<String, Object>) inputMap.get('CourseInformation');
            String courseFields = 'Id, Delivery_Method__c';
            String whereCondition = 'Preliminary_Application_Reference__c = \'' +
                                            String.escapeSingleQuotes(parid)
                                            + '\'';
            List<TrnCourse> previousCourses = new List<TrnCourse>();
            previousCourses = LPI_TrnCourseDAO.getTrnCourseByDymanicQuery(courseFields,
                                                                            whereCondition,
                                                                            null,null,null);

            String deliveryMethod = (String) courseInfo.get('DeliveryMethod');
            String description = (String) courseInfo.get('Description');
            List<TrnCourse> courseList = new List<TrnCourse>();

            Map<String , String> keyMapping = new Map<String , String>{
                'CourseTitle' => 'Name',
                'CourseType' => 'Course_Type__c',
                'Course' => 'Course__c'
            };

            TrnCourse obj = (TrnCourse) LPI_VlocityUtility.createSObject(courseInfo, keyMapping, 'TrnCourse');
            obj.Preliminary_Application_Reference__c = parid;

            List<String> methods = deliveryMethod.split(';');

             
            if ( previousCourses.isEmpty() ) {
                for (String currentMethod : methods) {
                    TrnCourse courseObj = setTrainingCourse(null,
                                obj.Name,
                                obj.Course_Type__c,
                                obj.Course__c,
                                currentMethod,
                                description,
                                obj.Preliminary_Application_Reference__c);
                    courseObj.Delivery_Method__c = currentMethod;                    
                    courseList.add(courseObj);
                }
            } else {
                

                Set<Id> removeCoursesSet = new Set<Id>();
                for (TrnCourse courseObj : previousCourses) {
                    removeCoursesSet.add(courseObj.Id);
                }
            
                Integer numberOfDeliveryMethods = methods.size(), previousCoursesSize = previousCourses.size();
                for (Integer currentMethod = 0; currentMethod < numberOfDeliveryMethods; currentMethod++) {
                    Id currentCourseId = null;
                    if (currentMethod < previousCoursesSize) {
                        currentCourseId = previousCourses.get(currentMethod).Id;
                        removeCoursesSet.remove(previousCourses.get(currentMethod).Id);
                    }

                    TrnCourse courseObj = setTrainingCourse(currentCourseId,
                                                obj.Name,
                                                obj.Course_Type__c,
                                                obj.Course__c,
                                                methods.get(currentMethod),
                                                description,
                                                obj.Preliminary_Application_Reference__c);
                    courseList.add(courseObj);
                }

                 
                if (removeCoursesSet.size() > 0) {
                    List<Id> deleteRecords = new List<Id>(removeCoursesSet);
                    Database.DeleteResult[] deleteResults = Database.delete(deleteRecords, true);
                    for (Database.DeleteResult dr : deleteResults) {
                        if (!dr.isSuccess()) {
                            for (Database.Error err : dr.getErrors()) {
                                databaseError(err);
                            }
                        }
                    }
                }
            }

            if( courseList.size() > 0 ){
                LPI_WithoutSharingUtility.upsertSObjectList(courseList);
            }
            String courseIds = '';
            for (TrnCourse courseObj : courseList) {
                courseIds += courseObj.Id + ';';
            }

             
            PreliminaryApplicationRef par = new PreliminaryApplicationRef();
            par.Id = parid;
            par.Amendment_Type__c = obj.Course_Type__c;
            par.Course_ID__c = courseIds;
            LPI_DML.doUpdate(par);

            outMap.put('Id', courseIds);
        } catch (Exception e) {
            LPI_ExceptionManager.logException(CLASS_NAME, CREATE_TRAINING_COURSE, e);
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * @author          : MTX Group Product Team
     * @description     : This method is Used to Create Application Content records(Course Information)
     * @param inputMap  : fetching all the input from Omniscript
     * @param outMap    : Passing value to Omniscript
     * @lastModifiedBy      : MTX Group Product Team
     * @lastModifiedDate    : 2 Feb, 2023
     * @lastModifiedDetails : Updated whole method with few standards
     */
    private static void createCourseInformation(Map<String, Object> inputMap, Map<String, Object> outMap) {
        try {
             
            Integer count = (Integer)inputMap.get('count');
            String parId = (String) inputMap.get('parid');
            if ( checkPARIsEmpty(parId, CREATE_COURSE_INFORMATION) ) {
                return;
            }
            String fields = 'Id';
            String whereClause = 'Preliminary_Application_Reference__c = \'' +
                            String.escapeSingleQuotes(parId)
                            + '\'';
            
            List<Application_Content__c> appContentList = new List<Application_Content__c>();
            appContentList = LPI_ApplicationContentDAO.getApplicationContentByDymanicQuery(fields,
                                                                whereClause,
                                                                null,null,null);
            
            Set<Id> previousRecords = new Map<Id, Application_Content__c>(appContentList).keySet();
            
            List<Application_Content__c> upsertList = new List<Application_Content__c>();
            List<Object> courseInfo = new List<Object>();
            if(count > 1){
                courseInfo = (List<Object>) inputMap.get('courseList');
            } 
            else{
                 
                courseInfo.add(inputMap.get('courseList'));
            }
            
            Map<String , String> keyMapping = new Map<String , String>{
                'AppContentId' => 'Id',
                'LearningObjectives'=>'Learning_Objectives__c',
                'DetailedContentOutline' => 'Detailed_Content_Outline__c',
                'Time' => 'Time__c'
            };

            for (Object curr : courseInfo) {
                Map<String, Object> obj = (Map<String, Object>) curr;
                String objId = (String) obj.get('AppContentId');
                Application_Content__c courseDetails = (Application_Content__c) LPI_VlocityUtility.createSObject(obj, keyMapping, 'Application_Content__c');
                courseDetails.Section_Header__c = COURSE_DETAILS;
                courseDetails.Preliminary_Application_Reference__c = parId;
                upsertList.add(courseDetails);
                if (previousRecords.contains(objId)) {
                    previousRecords.remove(objId);
                }
            }

            if (upsertList.size() > 0) {
                LPI_DML.doUpsert(upsertList);
            }
            if (previousRecords.size() > 0) {
                List<Id> deleteRecords = new List<Id>(previousRecords);
                Database.DeleteResult[] deleteResults = Database.delete(deleteRecords, true);
                for (Database.DeleteResult dr : deleteResults) {
                    if (!dr.isSuccess()) {
                        for (Database.Error err : dr.getErrors()) {
                            databaseError(err);
                        }
                    }
                }
            }
        } catch (Exception e) {
            LPI_ExceptionManager.logException(CLASS_NAME, CREATE_COURSE_INFORMATION, e);
            throw new AuraHandledException(e.getMessage());
        }
    }

   

    /**
     * @author              : MTX Group Product Team
     * @description         : This method is Used to set the values of training course object
     * @param courseId      : Id of Training Course Record
     * @param name          : Name of Training Course Object
     * @param courseType    : Type of course
     * @param course        : course
     * @param currentMethod : delivery Method
     * @param description   : description
     */

    private static TrnCourse setTrainingCourse(
        Id courseId,
        String name,
        String courseType,
        String course,
        String currentMethod,
        String description,
        Id parId
    ) {
        TrnCourse courseObj = new TrnCourse();
        courseObj.Id = courseId;
        courseObj.Name = name;
        courseObj.Course_Type__c = courseType;
        courseObj.Course__c = course;
        courseObj.Delivery_Method__c = currentMethod;
        if (currentMethod == LPI_LiteralConstant.DELIVERY_METHOD_OTHER) {
            courseObj.Description = description;
        } else {
            courseObj.Description = null;
        }
        courseObj.Preliminary_Application_Reference__c = parId;
        return courseObj;
    }

    /**
     * @author          : MTX Group Product Team
     * @description     : This method is fetch to Training Courses
     * @param inputMap  : fetching all the input from Omniscript
     * @param outMap    : Passing value to Omniscript
     * @lastModifiedBy      : MTX Group Product Team
     * @lastModifiedDate    : 2 Feb, 2023
     * @lastModifiedDetails : Updated whole method with few standards
     */

    public static void fetchTrainingCourses(Map<String, Object> inputMap, Map<String, Object> outMap) {
        try {
            String parid = (String) inputMap.get('parid');
            if ( checkPARIsEmpty(parId, FETCH_TRAINING_COURSE) ) {
                return;
            }
            String fieldsOnPAR = 'Id, Course_ID__c, Type__c';
            String whereConditionOnPAR = 'Id = \'' +
                    String.escapeSingleQuotes(parid)
                    + '\'';
            
             
            List<PreliminaryApplicationRef> parList = new List<PreliminaryApplicationRef>();
            parList = LPI_PreliminaryApplicationRefDAO.getPreliminaryApplicationRefByDymanicQuery(
                                            fieldsOnPAR,
                                            whereConditionOnPAR,
                                            limitOne,
                                            null,null
                                        );

            String courseFields = 'Id, Name, Delivery_Method__c, Course__c, Course_Type__c, Description';
            String whereCondition;
            if(parList.size() > 0 && parList.get(0).Type__c == LPI_LiteralConstant.BLA_RENEWAL_APPLICATIONTYPE){
                whereCondition = 'Id = \'' +
                                            String.escapeSingleQuotes(parList.get(0).Course_ID__c)
                                            + '\'';
            } else{
                whereCondition = 'Preliminary_Application_Reference__c = \'' +
                                            String.escapeSingleQuotes(parid)
                                            + '\'';
            }
            
            List<TrnCourse> previousCourses = new List<TrnCourse>();
            previousCourses = LPI_TrnCourseDAO.getTrnCourseByDymanicQuery(courseFields,
                                                        whereCondition,
                                                        null,null,null);
            String courseIdOnPar = '';
            if (previousCourses.size() > 0) {
                List<String> methods = new List<String>();
                 
                for (TrnCourse courseObj : previousCourses) {
                    methods.add(courseObj.Delivery_Method__c);
                    if (courseObj.Delivery_Method__c == LPI_LiteralConstant.DELIVERY_METHOD_OTHER) {
                        outMap.put('Description', courseObj.Description);
                        outMap.put('HasDeliveryMethodOther', true);
                    }
                    courseIdOnPar = courseIdOnPar + courseObj.Id + ';';
                }
                courseIdOnPar = courseIdOnPar.substring(0,courseIdOnPar.length() - 1);

                String DeliveryMethod = String.join(methods, ';');
        
                outMap.put('CourseTitle', previousCourses.get(0).Name);
                outMap.put('DeliveryMethod', DeliveryMethod);
                outMap.put('CourseType', previousCourses.get(0).Course_Type__c);
                outMap.put('Course', previousCourses.get(0).Course__c);
                outMap.put('TrainingCourseIds', courseIdOnPar);
            }
        } catch (Exception e) {
            LPI_ExceptionManager.logException(CLASS_NAME,FETCH_TRAINING_COURSE,e);
            throw new AuraHandledException(e.getMessage());
        }
    }

    private static void databaseError(Database.Error err){
        System.assert(false,'The following error has occurred.' +
                            '\n' + err.getStatusCode() +
                            ': ' + err.getMessage() +
                            '\n fields that affected this error: ' +err.getFields());
    }

    private static Boolean checkPARIsEmpty(String parId,String method){
        if (String.isEmpty(parId)) {
            LPI_ExceptionManager.logException(
                CLASS_NAME,
                method,
                PAR_NOT_FOUND,
                PAR_NOT_FOUND,
                null,
                null
            );
            return true;
        }
        return false;
    }
}