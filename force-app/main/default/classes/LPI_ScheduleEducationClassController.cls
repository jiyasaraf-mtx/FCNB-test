/**
 * @author            : Ayushi Sharma
 * @description       : This class represents Education Schedule of a school for a particular course.CourseOffering object
 *                      represents class information like class start time date ,instructor name,etc. and its a child of TrnCourseObject
 *                      which represents a course offered by the school and contains all the course details.
 *                      This class mainly works upon Class Information Step.
 *                      Fetching the existing user data , Creating/Inserting new data , deleting the unwanted data & updating the data
 *                      OS that can be referred for this is "SchoolScheduleClassInformation"
 * -------------------------------------------------------------------------------------------------------
 * Version      Date                Author                  Details
 *    1         20 Dec, 2022        Ayushi Sharma           Initial Developement
 * -------------------------------------------------------------------------------------------------------
 * @last modified by  : MTX Group Inc
**/

global with sharing class LPI_ScheduleEducationClassController implements Callable{
    /**
    * @description 
    * @author       : Ayushi Sharma 
    * @since        : 20 Dec, 2022
    * @param action 
    * @param args 
    * @return Object 
    **/
    global Object call(String action, Map<String, Object> args) {
        Map<String, Object> input = (Map<String, Object>) args.get('input');
        Map<String, Object> output = (Map<String, Object>) args.get('output');
        Map<String, Object> options = (Map<String, Object>) args.get('options');
        return invokeMethod(action, input, output, options);
    }
   
    /**
    * @description                  : This method will compare method coming from Omniscript and execute only that specific method
    * @author                       : Ayushi Sharma 
    * @since                        : 20 Dec, 2022 
    * @param methodName             : method called by the OS
    * @param inputMap               : fetching all the input from Omniscript
    * @param outMap                 : Passing value to Omniscript
    * @param options                : Passing Options to Omniscript if needed
    * @last modified by             : MTX Group Inc
    * @last modified date           : 30 Jan, 2023
    * @last modified details        : Code Fixes
    * @return Boolean 
    **/
    private Boolean invokeMethod(String methodName, Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options) {
        Boolean result = true;
        try {
             if (methodName.equals('fetchCourseIDNumber')) {
            outMap.put('classRecords', fetchClassInformation(inputMap));
            }else 
            if(methodName.equals('fetchCourseOfferingDetails')){
                outMap.put('ClassScheduleInfo', fetchCourseOfferingDetails(inputMap));
            }else if(methodName.equals('saveClassInformation')){
                saveClassInformation(inputMap);
            }
        } catch (Exception e) {
            result = false;
            LPI_ExceptionManager.logException('LPI_ScheduleEducationClassController', 'invokeMethod', e);
        }
        return result;
    }

    /**
    * @description                         : Based on Course ID this method returns course details for each item and for a specified parid.
    * @author                              : Ayushi Sharma  
    * @since                               : 20 Dec, 2022
    * @param inputMap                      : fetching all the input from Omniscript
    * @return `List<Map<String, Object>>`  : returns the list of items that has Training Course infromation.
    * @last modified by                    : MTX Group Inc
    * @last modified date                  : 30 Jan, 2023
    * @last modified details               : Code Fixes
    **/
    private static List<Map<String, Object>> fetchClassInformation(Map<String, Object> inputMap) {
        try{
            String courseId = '%' + (String) inputMap.get('SchoolCourseID') + '%';
            String parid = (String) inputMap.get('parid');
            List<Map<String,Object>> courseNameMapList = new List<Map<String,Object>>();
            Map<String,Object> courseNameMap;
            String accountId = LPI_PreliminaryApplicationRefDAO.getPARRecordsByParId(parId)[0].BusinessAccountNameId;
            for(TrnCourse tcList : LPI_TrnCourseDAO.getTrnCourseRecordsByCourseIdAndAccountId(accountId,courseId)){
                courseNameMap = new Map<String,Object>();
                courseNameMap.put('SchoolCourseTitle',tcList.Name) ;
                courseNameMap.put('Name',tcList.Course_ID__c);
                courseNameMap.put('SchoolCourseID',tcList.Course_ID__c);
                courseNameMap.put('TrainingCourseId',tcList.Id);
                courseNameMapList.add(courseNameMap);
            }
            return courseNameMapList;
        } catch (Exception e) {
            LPI_ExceptionManager.logException('LPI_ScheduleEducationClassController','fetchClassInformation',e);
            return null;
        }
    }

    
    /**
    * @description                      : this method stores the user input data coming from OS into SF.It inserts new class information
                                          records , updates the existing user data & deletes unwanted existing user data
    * @author                           : Ayushi Sharma 
    * @since                            : 20 Dec, 2022
    * @param inputMap                   : fetching all the input from Omniscript
    * @last modified by                 : MTX Group Inc
    * @last modified date               : 27 Jan, 2023
    * @last modified details            : Code Fixes
    **/
    private static void saveClassInformation(Map<String,Object> inputMap){
        try{
            String parId=(String) inputMap.get('parid');
            String accountId = LPI_PreliminaryApplicationRefDAO.getPARRecordsByParId(parId)[0].BusinessAccountNameId;
            List<Object> classInfo = new List<Object>();
            Integer applicantListCount = (Integer) inputMap.get('applicantListCount');
            if (applicantListCount > 1) {
                classInfo = (List<Object>) inputMap.get('courseData');
            } else {
                classInfo.add(inputMap.get('courseData'));
            }   
            Map<String,Schema.Location> insertLocationMap = new Map<String,Schema.Location>();
            Map<String,AssociatedLocation> insertAssociatedLocationMap = new Map<String,AssociatedLocation>();
            Map<String,CourseOffering> insertCourseOfferingMap = new Map<String,CourseOffering>();
            Map<String,Schema.Address> insertAddressMap = new  Map<String,Schema.Address>();
            Map<String,Id> keyLocIdMap = new Map<String,Id>();
            List<String> streetList = new List<String>();
            List<String> stateList = new List<String>();
            List<String> cityList = new List<String>();
            List<String> postalList = new List<String>();
            List<String> countryList = new List<String>();
            List<CourseOffering> deleteCourseOfferingList = new List<CourseOffering>();
            CourseOffering courseOfferingRecord;
            Schema.Address address;
            Schema.Location loc;
            Map<String,String> keyMapPair = new Map<String,String>{
                'SchoolClassesForTheMonthOf'=>'Month__c',
                'SchoolYear'=>'Year__c',
                'SchoolClassBeginDate'=>'StartDate',
                'SchoolClassEndDate'=>'EndDate',
                'SchoolClassStartTime'=>'Class_Start_Time__c',
                'SchoolNameOfTheInstructor'=>'Name_of_the_Instructor__c',
                'SchoolId'=>'Id'
            };
            for(Object obj: classInfo){
                Map<String, Object> info = (Map<String, Object>)obj;
                Map<String,Object> getName = (Map<String,Object>) info.get('SchoolCourseID-Block');
                
                courseOfferingRecord = (CourseOffering) LPI_VlocityUtility.createSObject(info, keyMapPair, 'CourseOffering' );
                courseOfferingRecord.Name = (String) getName.get('SchoolCourseID');
                courseOfferingRecord.Preliminary_Application_Reference__c = parId;
                if(((Map<String,Object>)info.get('SchoolCourseID-Block')).containsKey('TrainingCourseId')){
                    courseOfferingRecord.CourseNameId= (String)(
                        (Map<String,Object>)info.get('SchoolCourseID-Block')
                    ).get('TrainingCourseId');
                }
                address = new Schema.Address();
                address.Street = (String)info.get('SchoolStreet');
                streetList.add(address.Street);
                address.City = (String)info.get('SchoolCity');
                cityList.add(address.City);
                address.StateCode = (String)info.get('SchoolState');
                stateList.add(address.StateCode);
                address.PostalCode = (String)info.get('SchoolZip');
                postalList.add(address.PostalCode);
                address.CountryCode = LPI_LiteralConstant.US_COUNTRY_CODE;
                address.LocationType='Course Address';

                String key = LPI_AddressUtility.createKeyForAddress(address.Street,address.City,address.StateCode,address.PostalCode);

                String locType = 'Course Address';
                loc=LPI_AddressUtility.createLocationRecord(null,courseOfferingRecord.Name,locType,key);
                insertLocationMap.put(key,loc);
                insertAddressMap.put(key, address);
                insertCourseOfferingMap.put(key,courseOfferingRecord);
                AssociatedLocation ascLocation = new AssociatedLocation();
                ascLocation.ParentRecordId = accountId;
                insertAssociatedLocationMap.put(key,ascLocation);
            }
            keyLocIdMap = LPI_AddressUtility.createLocationAndAddress(insertLocationMap,insertAddressMap, accountId,'Course Address', streetList, cityList, stateList, postalList,false);
            for(String key : insertAddressMap.keySet()){
                insertAddressMap.get(key).ParentId = keyLocIdMap.get(key);
                insertCourseOfferingMap.get(key).LocationId = keyLocIdMap.get(key);
                insertAssociatedLocationMap.get(key).LocationId = keyLocIdMap.get(key);
            }
            for(CourseOffering course : LPI_CourseOfferingDAO.getCourseOfferingRecordsByCourseOfferingAndParID(parId,insertCourseOfferingMap.values())){
                deleteCourseOfferingList.add(course);
            }  
            if(!insertAssociatedLocationMap.isEmpty()){
                LPI_WithoutSharingUtility.insertSObjectRecord(insertAssociatedLocationMap.values());  
            }
            if(!deleteCourseOfferingList.isEmpty()){
                LPI_WithoutSharingUtility.deleteSObject(deleteCourseOfferingList);
            }
            if(!insertCourseOfferingMap.isEmpty()){
                LPI_WithoutSharingUtility.upsertSObjectList(insertCourseOfferingMap.values());
            }
        } catch (Exception e) {
            LPI_ExceptionManager.logException('LPI_ScheduleEducationClassController','saveClassInformation',e);
        }
    }

   /**
   * @description                           : This method fetches the pre existing user data to OS
   * @author                                : Ayushi Sharma
   * @since                                 : 20 Dec, 2022
   * @param inputMap                        : fetching all the input from Omniscript
   * @param outMap                          : Passing values to Omniscript
   * @return `List<Map<String, Object>>`    : returns list of items to OS
   * @last modified by                      : MTX Group Inc
   * @last modified date                    : 30 Jan, 2023
   * @last modified details                 : Code Fixes
   **/
    public static List<Map<String, Object>> fetchCourseOfferingDetails(Map<String,Object> inputMap){
        try{
            String coparId=(String) inputMap.get('parid');
            List<Map<String, Object>> courseOfferingMapList = new List<Map<String, Object>>();  
            Map<Id,Id> locationIdToCourseIdMap = new Map<Id,Id>();
            Map<Id,Schema.Address> courseIdToAddressMap = new Map<Id,Schema.Address>();
            List<CourseOffering> coList = LPI_CourseOfferingDAO.getCourseOfferingRecordsByParId(coparId);
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
            for(CourseOffering co:coList){
                Map<String, Object> courseOfferingMap = new Map<String, Object>();
                Map<String, Object> traningCourseBlockMap = new Map<String, Object>();
                courseOfferingMap.put('SchoolClassesForTheMonthOf', co.Month__c);
                courseOfferingMap.put('SchoolYear', co.Year__c);
                courseOfferingMap.put('SchoolNameOfTheInstructor', co.Name_of_the_Instructor__c);
                courseOfferingMap.put('SchoolClassBeginDate', co.StartDate);
                courseOfferingMap.put('SchoolClassEndDate', co.EndDate);
                courseOfferingMap.put('SchoolClassStartTime', co.Class_Start_Time__c);
                courseOfferingMap.put('SchoolId',co.Id);
                if(courseIdToAddressMap.containsKey(co.Id)){
                    courseOfferingMap.put('SchoolStreet', courseIdToAddressMap.get(co.Id).Street);
                    courseOfferingMap.put('SchoolCity', courseIdToAddressMap.get(co.Id).City);
                    courseOfferingMap.put('SchoolState', courseIdToAddressMap.get(co.Id).StateCode);
                    courseOfferingMap.put('ReviewSchoolState', courseIdToAddressMap.get(co.Id).State);
                    courseOfferingMap.put('SchoolZip', courseIdToAddressMap.get(co.Id).PostalCode);
                }
                traningCourseBlockMap.put('SchoolCourseID',co.CourseName.Course_ID__c);
                traningCourseBlockMap.put('Name',co.CourseName.Course_ID__c);
                traningCourseBlockMap.put('TrainingCourseId',co.CourseNameId);
                traningCourseBlockMap.put('SchoolCourseTitle',co.CourseName.Name);
                courseOfferingMap.put('SchoolCourseID-Block',traningCourseBlockMap);
                courseOfferingMapList.add(courseOfferingMap);
            }
            return courseOfferingMapList;
        }catch (Exception e) {
            LPI_ExceptionManager.logException('LPI_ScheduleEducationClassController','fetchCourseOfferingDetails',e);
            return null;
        }
    }
}