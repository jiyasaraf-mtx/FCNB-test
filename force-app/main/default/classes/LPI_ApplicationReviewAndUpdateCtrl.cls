/**
 * @description       :  Application Review Class
 * @author            : MTX Group Product Team
 * @group             :
 * @last modified on  : 07-08-2024
 * @last modified by  :MTX Group Product Team
 **/
public with sharing class LPI_ApplicationReviewAndUpdateCtrl {

    public static String CLASS_NAME = 'LPI_ApplicationReviewAndUpdateCtrl';
    public static List<String> notUpdatedableStatus = new List<String>{'Pass','Active','Approved','Verified'};

    /**
     * @author                      : MTX Group Product Team
     * @since                       :
     * @description                 : fetch related application data
     * @return                      : 
     * @last modified by            : MTX Group Product Team
     * @last modified date          :
     * @modified details            :
    */
    @AuraEnabled
    public static Map<String,Object> getApplicationReviewData(Id recordId){
        List<ChecklistWrapper> checklistWrapList = new List<ChecklistWrapper>();
        String fields = 'Id,SavedApplicationRefId,Status';
        String whereClause = 'Id = \''+ recordId + '\'';
        String sObjName = recordId.getSObjectType().getDescribe().getName();
        Set<String> applicationStatus = new Set<String>{LPI_LiteralConstant.BLA_LICENSEISSUED_STATUS,LPI_LiteralConstant.BLA_REJECTED_STATUS,LPI_LiteralConstant.BLA_APPROVED_STATUS,LPI_LiteralConstant.BLA_CLOSED_STATUS};
        List<SObject> recordData = new List<SObject>();
        if (sObjName == LPI_LiteralConstant.IA_SOBJECT_API) {
            recordData = LPI_IndividualApplicationDAO.getIndividualApplicationByDymanicQuery(
                fields,whereClause,null,null,null);

        } else if (sObjName == LPI_LiteralConstant.BLA_SOBJECT_API) {
            recordData = LPI_BusinessLicenseApplicationDAO.getBusinessLicenseApplicationByDymanicQuery(
                fields,whereClause,null,null,null);
        }
        if(!recordData.isEmpty()){
            String applicationId = (String)recordData[0].get('SavedApplicationRefId');
            fields = 'Id,Type__c,Regulatory_Authorization_Type__c,Contact__c,Contact__r.AccountId,Employee_Information_ACR_Ids__c,Supervisor_ACR_Id__c,Person_Incharge_Relation_Id__c,Related_Owner_Ids__c,Preneed_Relationship_Ids__c,Designation_Of_Custodial_Relation_Id__c,Approval_Supervisors_AcrIds__c';
            if(String.isNotBlank(applicationId)) {
                whereClause = 'Id = \'' + String.escapeSingleQuotes(applicationId) + '\'';
            }
            List<PreliminaryApplicationRef> parList = LPI_PreliminaryApplicationRefDAO.getPreliminaryApplicationRefByDymanicQuery(
                fields,whereClause,null,null,null);
            if(!parList.isEmpty()){
                ChecklistWrapper relationRec = getRelationshipRecords(parList[0]);
                if(relationRec != null){
                    checklistWrapList.add(relationRec);
                }
                if(parList[0].Type__c == LPI_LiteralConstant.IA_NEW_APPLICATIONTYPE || parList[0].Type__c == LPI_LiteralConstant.IA_RENEWAL_APPLICATIONTYPE){
                    ChecklistWrapper educationRec = getPersonEducationRecords(parList[0].Id);
                    if(educationRec != null){
                        checklistWrapList.add(educationRec);
                    }
                }
                if(parList[0].Type__c == LPI_LiteralConstant.IA_NEW_APPLICATIONTYPE){
                    ChecklistWrapper examRec = getPersonExaminationRecords(parList[0].Regulatory_Authorization_Type__c,parList[0].Contact__c);
                    if(examRec != null){
                        checklistWrapList.add(examRec);
                    }
                }
                ChecklistWrapper emplHistoryParRec = getEmploymentHistoryRecords(parList[0].Id);
                if(emplHistoryParRec != null){
                    checklistWrapList.add(emplHistoryParRec);
                }
                
                ChecklistWrapper traingCourseParRec = getTrainingCourseParticipantRecords(parList[0].Id);
                if(traingCourseParRec != null){
                    checklistWrapList.add(traingCourseParRec);
                }
                List<ChecklistWrapper> trainingCouRec = getTrainingCourseRecords(parList[0].Id);
                if(trainingCouRec != null && !trainingCouRec.isEmpty()){
                    checklistWrapList.addAll(trainingCouRec);
                }
            }
        }
        return new Map<String,Object>{
            'checklistWrapList' => checklistWrapList,
            'allDisabled' => applicationStatus.contains((String)recordData[0].get('Status'))
        };
    }

    /**
     * @author                      : MTX Group Product Team
     * @since                       :
     * @description                 : fetch Business_Relationships__c data
     * @return                      : 
     * @last modified by            : MTX Group Product Team
     * @last modified date          :
     * @modified details            :
    */
    private static ChecklistWrapper getRelationshipRecords(PreliminaryApplicationRef parRecord){
        try{
            Set<String> relationShipIdsSet = new Set<String>();
            if (String.isNotBlank(parRecord.Employee_Information_ACR_Ids__c)) {
                relationShipIdsSet.addAll(
                    parRecord.Employee_Information_ACR_Ids__c.split(',')
                );
            }
             
            if (String.isNotBlank(parRecord.Supervisor_ACR_Id__c)) {
                relationShipIdsSet.addAll(
                    parRecord.Supervisor_ACR_Id__c.split(',')
                );
            }
            if (String.isNotBlank(parRecord.Person_Incharge_Relation_Id__c)) {
                relationShipIdsSet.addAll(
                    parRecord.Person_Incharge_Relation_Id__c.split(',')
                );
            }
            if (String.isNotBlank(parRecord.Related_Owner_Ids__c)) {
                relationShipIdsSet.addAll(
                    parRecord.Related_Owner_Ids__c.split(',')
                );
            }
            
            if (String.isNotBlank(parRecord.Preneed_Relationship_Ids__c)) {
                relationShipIdsSet.addAll(
                    parRecord.Preneed_Relationship_Ids__c.split(',')
                );
            }
            if(String.isNotBlank(parRecord.Designation_Of_Custodial_Relation_Id__c)){
                relationShipIdsSet.addAll(
                    parRecord.Designation_Of_Custodial_Relation_Id__c.split(',')
                );
            }
            if(String.isNotBlank(parRecord.Approval_Supervisors_AcrIds__c)){
                relationShipIdsSet.addAll(
                    parRecord.Approval_Supervisors_AcrIds__c.split(',')
                );
            }
            Map<Id, Business_Relationships__c> idToBusinessRelationShipMap = new Map<Id, Business_Relationships__c>();
            if (!relationShipIdsSet.isEmpty()) {
                String fields = 'Id,Related_To__c,Related_From__c,Related_To__r.Name,Related_From__r.Name,Roles__c,Start_Date__c, EndDate__c, IsActive__c,Related_From_License_Number__r.Name,Related_To_License_Number__r.Name,Related_To_License_Number__r.RegulatoryAuthorizationType.Name,Related_From_License_Number__r.RegulatoryAuthorizationType.Name';
                String whereClause =
                    'ID IN ' +
                    LPI_ServiceUtility.getStringValuesByStringSet(
                        relationShipIdsSet
                    );
                idToBusinessRelationShipMap = (new Map<Id, Business_Relationships__c>(
                    LPI_BusinessRelationshipDAO.fetchBusinessRelationshipRecords(
                        fields,whereClause,null,null,null)
                ));
                List<RecordValuesWrapper> valueList = new List<RecordValuesWrapper>();
                for (Business_Relationships__c businessRelationship : idToBusinessRelationShipMap.values()) {
                    List<ValueWrapper> valueWrap = new List<ValueWrapper>();
                    valueWrap.add(new ValueWrapper(null,businessRelationship.Related_To__r.Name,true,false,null,false,false,false,null,false,false));
                    valueWrap.add(new ValueWrapper(null,businessRelationship.Related_To_License_Number__r.Name,true,false,null,false,false,false,null,false,false));
                    valueWrap.add(new ValueWrapper(null,businessRelationship.Related_To_License_Number__r.RegulatoryAuthorizationType.Name,true,false,null,false,false,false,null,false,false));
                    valueWrap.add(new ValueWrapper(null,businessRelationship.Related_From__r.Name,true,false,null,false,false,false,null,false,false));
                    valueWrap.add(new ValueWrapper(null,businessRelationship.Related_From_License_Number__r.Name,true,false,null,false,false,false,null,false,false));
                    valueWrap.add(new ValueWrapper(null,businessRelationship.Related_From_License_Number__r.RegulatoryAuthorizationType.Name,true,false,null,false,false,false,null,false,false));
                    valueWrap.add(new ValueWrapper(null,businessRelationship.Roles__c,true,false,null,false,false,false,null,false,false));
                    valueWrap.add(new ValueWrapper('Start_Date__c',String.valueOf(businessRelationship.Start_Date__c),false,false,null,false,true,false,null,false,true));
                    valueWrap.add(new ValueWrapper('EndDate__c',String.valueOf(businessRelationship.EndDate__c),false,false,null,false,true,false,null,false,false));
                    valueWrap.add(new ValueWrapper('IsActive__c',String.valueOf(businessRelationship.IsActive__c),false,false,null,false,false,false,null,true,false));
                    valueList.add(new RecordValuesWrapper(businessRelationship.id,valueWrap,businessRelationship.IsActive__c));
                }
                if(!valueList.isEmpty()){
                    return new ChecklistWrapper('Business Relationships',new List<String>{'Related To','Related To License Number','Related To License Type','Related From','Related From License Number','Related From License Type','Role','Start Date','End Date','Is Active'},valueList,'Business_Relationships__c',
                    getFieldsApi('Business_Relationships__c','View_Layout'),
                    null,null,false);
                }
            }
            return null;
        } catch (Exception e) {
            LPI_ExceptionManager.logException(CLASS_NAME, 'getRelationshipRecords', e);
            throw new AuraHandledException(e.getMessage());
        }
    }
    /**
     * @author                      : MTX Group Product Team
     * @since                       :
     * @description                 : fetch PersonEducation data
     * @return                      : 
     * @last modified by            : MTX Group Product Team
     * @last modified date          :
     * @modified details            :
    */
    private static ChecklistWrapper getPersonEducationRecords(Id parId){
        List<RecordValuesWrapper> valueList = new List<RecordValuesWrapper>();
        List<PersonEducation> educationList = LPI_PersonEducationDAO.getPersonEducationByDymanicQuery(
            'Id,Name,Education_Type__c,GraduationDate,IdentifierIssuer,Education_Status__c',
            'Preliminary_Application_Reference__c = \'' + parId + '\'',null,null,null
        );
        List<SelectOptionWrapper> picklistValues = fetchPicklist('PersonEducation','Education_Status__c');
        for(PersonEducation education : educationList){
            List<ValueWrapper> valueWrap = new List<ValueWrapper>();
            valueWrap.add(new ValueWrapper(null,education.Name,true,true,education.Id,false,false,false,null,false,false));
            valueWrap.add(new ValueWrapper(null,education.Education_Type__c,true,false,null,false,false,false,null,false,false));
            valueWrap.add(new ValueWrapper(null,education.IdentifierIssuer,true,false,null,false,false,false,null,false,false));
            valueWrap.add(new ValueWrapper(null,convertDateFormat(String.valueOf(education.GraduationDate?.format('MM/dd/YYYY'))),true,false,null,false,false,false,null,false,false));
            valueWrap.add(new ValueWrapper('Education_Status__c',education.Education_Status__c,false,false,null,false,false,true,picklistValues,false,true));
            valueList.add(new RecordValuesWrapper(education.id,valueWrap,notUpdatedableStatus.contains(education.Education_Status__c)));
        }
        if(!valueList.isEmpty()){
            return new ChecklistWrapper('Education',new List<String>{'Name of Degree','Type of Education','Institution','Graduation Date','Status'},valueList,'PersonEducation',
            getFieldsApi('PersonEducation','View_Layout'),
            new Map<String,Object>{'Education_Status__c' => 'Verified'},new Map<String,Object>{'Education_Status__c' => 'Inactive'},true);
        }
        return null;
    }
    /**
     * @author                      : MTX Group Product Team
     * @since                       :
     * @description                 : fetch PersonExamination data
     * @return                      : 
     * @last modified by            : MTX Group Product Team
     * @last modified date          :
     * @modified details            :
    */
    private static ChecklistWrapper getPersonExaminationRecords(Id ratId,Id contactId){
        try{
            List<RecordValuesWrapper> valueList = new List<RecordValuesWrapper>();
            List<Regulatory_Examination_Junction__c>  junctionList = LPI_RegulatoryExaminationJunctionDao.getRegulatoryExaminationJunctionByDymanicQuery(
                'Id, Examination__c',
                ' Examination__c != NULL AND Regulatory_Authorization_Type__c != NULL AND Regulatory_Authorization_Type__c = \'' +
                ratId + '\'',
                null,null,null
            );
            Set<String> examinationIds = new Set<String>();
            for(Regulatory_Examination_Junction__c junction :junctionList){
                examinationIds.add(junction.Examination__c);
            }
            if(!examinationIds.isEmpty()){
                List<PersonExamination> personExamList = LPI_PersonExaminationDAO.getPersonExaminationByDynamicQuery(
                    'Id,Examination.Name,ExaminationDate,Score,Result,Exam_Section__c',
                    'ExaminationId IN '+ LPI_ServiceUtility.getStringValuesByStringSet(
                        examinationIds) + ' AND ContactId = \'' + contactId + '\''
                    ,null,null,null
                );
                List<SelectOptionWrapper> picklistValues = fetchPicklist('PersonExamination','Result');
                for(PersonExamination personExam : personExamList){
                    List<ValueWrapper> valueWrap = new List<ValueWrapper>();
                    valueWrap.add(new ValueWrapper(null,personExam.Examination.Name,true,true,personExam.Id,false,false,false,null,false,false));
                    valueWrap.add(new ValueWrapper(null,personExam.Exam_Section__c,true,false,null,false,false,false,null,false,false));
                    valueWrap.add(new ValueWrapper(null,convertDateFormat(String.valueOf(personExam.ExaminationDate?.format('MM/dd/YYYY'))),true,false,null,false,false,false,null,false,false));
                    valueWrap.add(new ValueWrapper(null,String.valueOf(personExam.Score),true,false,null,false,false,false,null,false,false));
                    valueWrap.add(new ValueWrapper('Result',personExam.Result,false,false,null,false,false,true,picklistValues,false,true));
                    valueList.add(new RecordValuesWrapper(personExam.Id,valueWrap,notUpdatedableStatus.contains(personExam.Result)));
                }
            }
            if(!valueList.isEmpty()){
                return new ChecklistWrapper('Examination',new List<String>{'Examination Name','Exam Section','Exam Date','Score','Result'},valueList,'PersonExamination',
                getFieldsApi('PersonExamination','View_Layout'),
                new Map<String,Object>{'Result' => 'Pass'},new Map<String,Object>{'Result' => 'Fail'},true);
            }
            return null;
        } catch (Exception e) {
            LPI_ExceptionManager.logException(CLASS_NAME, 'getPersonExaminationRecords', e);
            throw new AuraHandledException(e.getMessage());
        }
    }
    /**
     * @author                      : MTX Group Product Team
     * @since                       :
     * @description                 : fetch TrainingCourseParticipant data
     * @return                      : 
     * @last modified by            : MTX Group Product Team
     * @last modified date          :
     * @modified details            :
    */
    private static ChecklistWrapper getTrainingCourseParticipantRecords(Id parId){   
        try{
            List<RecordValuesWrapper> valueList = new List<RecordValuesWrapper>();
            List<TrainingCourseParticipant> trnCoursePartList = LPI_TrainingCourseParticipantDAO.getTrainingCourseParticipantByDymanicQuery(
                'Id,Name,Title__c,VerificationStatus,Contact.Name,Delivery_Method__c,Approved_Hours__c,TotalHours,Program_DateTime__c,TotalCredits',
                ' Preliminary_Application_Reference__c = \'' + parId + '\'',null,null,null
            );
            List<SelectOptionWrapper> picklistValues = fetchPicklist('TrainingCourseParticipant','VerificationStatus');
            for(TrainingCourseParticipant trnCoursePar : trnCoursePartList){
                List<ValueWrapper> valueWrap = new List<ValueWrapper>();
                valueWrap.add(new ValueWrapper(null,trnCoursePar.Name,true,true,trnCoursePar.Id,false,false,false,null,false,false));
                valueWrap.add(new ValueWrapper(null,trnCoursePar.Contact.Name,true,false,null,false,false,false,null,false,false));
                valueWrap.add(new ValueWrapper(null,trnCoursePar.Delivery_Method__c,true,false,null,false,false,false,null,false,false));
                valueWrap.add(new ValueWrapper(null,String.valueOf(trnCoursePar.Approved_Hours__c),true,false,null,false,false,false,null,false,false));
                valueWrap.add(new ValueWrapper(null,String.valueOf(trnCoursePar.TotalCredits),true,false,null,false,false,false,null,false,false));
                valueWrap.add(new ValueWrapper('VerificationStatus',trnCoursePar.VerificationStatus,false,false,null,false,false,true,picklistValues,false,true));
                valueList.add(new RecordValuesWrapper(trnCoursePar.Id,valueWrap,notUpdatedableStatus.contains(trnCoursePar.VerificationStatus)));
            }
            if(!valueList.isEmpty()){
                return new ChecklistWrapper('Training Course participant',new List<String>{'Name','Contact','Delivery Method','Approved Hours','Total Credits','Verification Status'},valueList,'TrainingCourseParticipant',
                getFieldsApi('TrainingCourseParticipant','View_Layout'),
                null,null,false);
            }
            return null;
        } catch (Exception e) {
            LPI_ExceptionManager.logException(CLASS_NAME, 'getTrainingCourseParticipantRecords', e);
            throw new AuraHandledException(e.getMessage());
        }
    }
    /**
     * @author                      : MTX Group Product Team
     * @since                       :
     * @description                 : fetch TrnCourse data
     * @return                      : 
     * @last modified by            : MTX Group Product Team
     * @last modified date          :
     * @modified details            :
    */
    private static List<ChecklistWrapper> getTrainingCourseRecords(Id parId){
        try{
            List<RecordValuesWrapper> valueList = new List<RecordValuesWrapper>();
            List<TrnCourse> trnCourseList = LPI_TrnCourseDAO.getTrnCourseByDymanicQuery(
                'Id,Name,Course_Type__c,Course__c,Status,Delivery_Method__c,TotalCredits',
                ' Preliminary_Application_Reference__c = \'' + parId + '\'',null,null,null
            );
            Set<String> trnCourseIdSet = new Set<String>();
            List<SelectOptionWrapper> picklistValues = fetchPicklist('TrnCourse','Status');
            for(TrnCourse trnCourse : trnCourseList){
                List<ValueWrapper> valueWrap = new List<ValueWrapper>();
                valueWrap.add(new ValueWrapper(null,trnCourse.Name,true,true,trnCourse.Id,false,false,false,null,false,false));
                valueWrap.add(new ValueWrapper(null,String.valueOf(trnCourse.Course_Type__c),true,false,null,false,false,false,null,false,false));
                valueWrap.add(new ValueWrapper(null,String.valueOf(trnCourse.Delivery_Method__c),true,false,null,false,false,false,null,false,false));
                valueWrap.add(new ValueWrapper(null,String.valueOf(trnCourse.TotalCredits),true,false,null,false,false,false,null,false,false));
                valueWrap.add(new ValueWrapper('Status',trnCourse.Status,false,false,null,false,false,true,picklistValues,false,true));
                valueList.add(new RecordValuesWrapper(trnCourse.Id,valueWrap,notUpdatedableStatus.contains(trnCourse.Status)));
                trnCourseIdSet.add(trnCourse.Id);
            }
            if(!trnCourseIdSet.isEmpty()){
                List<ChecklistWrapper> tainingCourseRec = new List<ChecklistWrapper>();
                tainingCourseRec.add(new ChecklistWrapper('Training Course',new List<String>{'Name','Course Type','Delivery Method','Total Credits','Status'},valueList,'TrnCourse',
                getFieldsApi('TrnCourse','View_Layout'),
                new Map<String,Object>{'Status' => 'Active'},new Map<String,Object>{'Status' => 'Rejected'},true));
                ChecklistWrapper coureOff = getTrainingCourseOfferingRecords(trnCourseIdSet,null);
                if(coureOff != null){
                    tainingCourseRec.add(coureOff);
                }
                return tainingCourseRec;
            } else{
                List<ChecklistWrapper> tainingCourseRec = new List<ChecklistWrapper>();
                ChecklistWrapper coureOff = getTrainingCourseOfferingRecords(null,parid);
                if(coureOff != null){
                    tainingCourseRec.add(coureOff);
                }
                return tainingCourseRec;
            }
        } catch (Exception e) {
            LPI_ExceptionManager.logException(CLASS_NAME, 'getTrainingCourseRecords', e);
            throw new AuraHandledException(e.getMessage());
        }
    }
    /**
     * @author                      : MTX Group Product Team
     * @since                       :
     * @description                 : fetch CourseOffering data
     * @return                      : 
     * @last modified by            : MTX Group Product Team
     * @last modified date          :
     * @modified details            :
    */
    private static ChecklistWrapper getTrainingCourseOfferingRecords(Set<String> trnCourseIdSet,Id parid){
        try{
            List<RecordValuesWrapper> valueList = new List<RecordValuesWrapper>();
            String whereClause;
            if(parid == NULL){
                whereClause = ' CourseNameId IN ' + LPI_ServiceUtility.getStringValuesByStringSet(trnCourseIdSet);
            }else if(trnCourseIdSet == NULL){
                whereClause = 'Preliminary_Application_Reference__c = \'' + parid +'\'';
            }
            List<CourseOffering> courseOffList = LPI_CourseOfferingDAO.getCourseOfferingByDymanicQuery(
                'Id,Name,StartDate,Class_Start_Time__c,Class_End_Time__c,EndDate,Name_of_the_Instructor__c',
                whereClause,null,null,null
            );
            for(CourseOffering courseOff : courseOffList){
                List<ValueWrapper> valueWrap = new List<ValueWrapper>();
                valueWrap.add(new ValueWrapper(null,courseOff.Name,true,true,courseOff.Id,false,false,false,null,false,false));
                valueWrap.add(new ValueWrapper(null,convertDateFormat(String.valueOf(courseOff.StartDate?.format('MM/dd/YYYY'))),true,false,null,false,false,false,null,false,false));
                valueWrap.add(new ValueWrapper(null,courseOff.Class_Start_Time__c != null ? String.valueOf(convertToAmPm(courseOff.Class_Start_Time__c)) : '',true,false,null,false,false,false,null,false,false));
                valueWrap.add(new ValueWrapper(null,convertDateFormat(String.valueOf(courseOff.EndDate?.format('MM/dd/YYYY'))),true,false,null,false,false,false,null,false,false));
                valueWrap.add(new ValueWrapper(null,courseOff.Class_End_Time__c != null ? String.valueOf(convertToAmPm(courseOff.Class_End_Time__c)) : '',true,false,null,false,false,false,null,false,false));
                valueList.add(new RecordValuesWrapper(courseOff.Id,valueWrap,true));
            }
            if(!valueList.isEmpty()){
                return new ChecklistWrapper('Course Offering',new List<String>{'Course Name','Start Date','Start Time','End Date','End Time'},valueList,'CourseOffering',
                getFieldsApi('CourseOffering','View_Layout'),null,null,false);
            }
            return null;
        } catch (Exception e) {
            LPI_ExceptionManager.logException(CLASS_NAME, 'getTrainingCourseOfferingRecords', e);
            throw new AuraHandledException(e.getMessage());
        }
    }
    /**
    * @description 
    * @author MTX Group Product Team | 05-06-2024 
    * @param inputTime 
    * @return String 
    **/
    public static String convertToAmPm(Time inputTime) {
        Date myDate = Date.today();
        DateTime dt = Datetime.newInstance(myDate,inputTime);
        String amPmTime = dt.format('hh:mm a');
        return amPmTime;
    }
    /**
     * @author                      : MTX Group Product Team
     * @since                       :
     * @description                 : fetch PersonEmployment data
     * @return                      : 
     * @last modified by            : MTX Group Product Team
     * @last modified date          :
     * @modified details            :
    */
    private static ChecklistWrapper getEmploymentHistoryRecords(Id parId){
        try{
            List<RecordValuesWrapper> valueList = new List<RecordValuesWrapper>();
            List<PersonEmployment> empRecList = LPI_PersonEmploymentDAO.getEmploymentHistoryByDymanicQuery(
                'Id,Name,StartDate,Employer_License_Number__c,EmploymentStatus,Position,EndDate,EmployerCity,Type_of_Employment__c',
                ' Preliminary_Application_Reference__c = \'' + parId + '\'',null,null,null
            );
            List<SelectOptionWrapper> picklistValues = fetchPicklist('PersonEmployment','EmploymentStatus');
            for(PersonEmployment empRec : empRecList){
                List<ValueWrapper> valueWrap = new List<ValueWrapper>();
                valueWrap.add(new ValueWrapper(null,empRec.Name,true,true,empRec.Id,false,false,false,null,false,false));
                valueWrap.add(new ValueWrapper(null,String.valueOf(empRec.Position),true,false,null,false,false,false,null,false,false));
                valueWrap.add(new ValueWrapper(null,convertDateFormat(String.valueOf(empRec.StartDate?.format())),true,false,null,false,false,false,null,false,false));
                valueWrap.add(new ValueWrapper(null,convertDateFormat(String.valueOf(empRec.EndDate?.format())),true,false,null,false,false,false,null,false,false));
                valueWrap.add(new ValueWrapper('EmploymentStatus',empRec.EmploymentStatus,false,false,null,false,false,true,picklistValues,false,true));
                valueList.add(new RecordValuesWrapper(empRec.Id,valueWrap,notUpdatedableStatus.contains(empRec.EmploymentStatus)));
            }
            if(!valueList.isEmpty()){
                return new ChecklistWrapper('Employment History',new List<String>{'Name of the Employer','Job Title/Position','Start Date','End Date','Status'},valueList,'PersonEmployment',
                getFieldsApi('PersonEmployment','View_Layout'),
                new Map<String,Object>{'EmploymentStatus' => 'Verified'},new Map<String,Object>{'EmploymentStatus' => 'Not Verified'},true);
            }
            return null;
        } catch (Exception e) {
            LPI_ExceptionManager.logException(CLASS_NAME, 'getEmploymentHistoryRecords', e);
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
    * @description 
    * @author MTX Group Product Team | 05-06-2024 
    * @param objectName 
    * @param fieldName 
    * @return List<SelectOptionWrapper> 
    **/
    private static List<SelectOptionWrapper> fetchPicklist(String objectName, String fieldName){
		List<SelectOptionWrapper> optionList = new List<SelectOptionWrapper>(); 
		Schema.SObjectType s = Schema.getGlobalDescribe().get(objectName) ;
		Schema.DescribeSObjectResult r = s.getDescribe() ;
		Map<String,Schema.SObjectField> fields = r.fields.getMap() ;
		Schema.DescribeFieldResult fieldResult = fields.get(fieldName).getDescribe();
		List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
		for( Schema.PicklistEntry pickListVal : ple){
			optionList.add( new SelectOptionWrapper( pickListVal.getValue(), pickListVal.getLabel())  );
		}    
		return optionList;
	}

    /**
    * @description 
    * @author MTX Group Product Team | 05-06-2024 
    * @param dataList 
    * @return boolean 
    **/
    @AuraEnabled
    public static boolean updateRecords(String dataList){
        try {
            List<SObject> sObjectList = (List<SObject>)JSON.deserializeStrict(dataList,List<SObject>.Class);
            sObjectList.sort();
            Database.update(sObjectList);
            return true;
        } catch (Exception ex) {
            LPI_ExceptionManager.logException(CLASS_NAME, 'updateRecords', ex);
            if ( String.isNotBlank( ex.getMessage() ) && ex.getMessage().contains( 'error:' ) ) {
                if(ex.getMessage().split('error:')[1].contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')){
                    throw new AuraHandledException(ex.getMessage().split('error:')[1].split(',')[1].split(':')[0]);
                }else{
                    throw new AuraHandledException(ex.getMessage().split('error:')[1].split(':')[0]);
                }
            } else {
                throw new AuraHandledException(ex.getMessage());
            }
        }
    }

    /**
    * @description 
    * @author MTX Group Product Team | 05-06-2024 
    * @param objName 
    * @param fieldSetName 
    * @return List<String> 
    **/
    private static List<String> getFieldsApi(String objName,String fieldSetName){
        try{
            List<String> fieldList = new List<String>();
            Map<String,Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe();
            Schema.SObjectType sObjectTypeObj = globalDescribe.get(objName);
            Schema.DescribeSObjectResult describeSObjectResult =sObjectTypeObj.getDescribe();
            Schema.FieldSet fieldSetObj = describeSObjectResult.FieldSets.getMap().get(fieldSetName);
            for(Schema.FieldSetMember fsmObj : fieldSetObj.getFields()){
                fieldList.add(fsmObj.getFieldPath());
            }
            return fieldList;
        } catch (Exception e) {
            LPI_ExceptionManager.logException(CLASS_NAME, 'updateRecords', e);
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
    * @description 
    * @author MTX Group Product Team | 05-06-2024 
    * @param dateValue 
    * @return string 
    **/
    private static string convertDateFormat(String dateValue) {
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
		@AuraEnabled public string developerName;
		public SelectOptionWrapper(string value, string label, string developerName){
			this.value = value;
			this.label = label;
			this.developerName = developerName;
		}
		public SelectOptionWrapper(string value, string label){
			this.value = value;
			this.label = label;
		}
	}

    public class ValueWrapper {
        @AuraEnabled
        public String value;
        @AuraEnabled
        public String apiName;
        @AuraEnabled
        public boolean isLookup;
        @AuraEnabled
        public String lookupId;
        @AuraEnabled
        public Boolean isValue;
        @AuraEnabled
        public Boolean isText;
        @AuraEnabled
        public Boolean isDate;
        @AuraEnabled
        public Boolean isPicklist;
        @AuraEnabled
        public List<SelectOptionWrapper> picklistValues;
        @AuraEnabled
        public Boolean isCheckbox;
        @AuraEnabled
        public Boolean isRequired;
        public ValueWrapper() {
        }
        public ValueWrapper(
            String apiName,
            String value,
            boolean isValue,
            boolean isLookup,
            String lookupId,
            Boolean isText,
            Boolean isDate,
            Boolean isPicklist,
            List<SelectOptionWrapper> picklistValues,
            Boolean isCheckbox,
            Boolean isRequired
        ) {
            this.apiName = apiName;
            this.value = value;
            this.isValue = isValue;
            this.isLookup = isLookup;
            this.lookupId = lookupId;
            this.isText = isText;
            this.isPicklist = isPicklist;
            this.isDate = isDate;
            this.picklistValues = picklistValues;
            this.isCheckbox = isCheckbox;
            this.isRequired = isRequired;
        }
    }

    public class RecordValuesWrapper{
        @AuraEnabled
        public String id;
        @AuraEnabled
        public List<ValueWrapper> valueList;
        @AuraEnabled
        public Boolean showRespectiveSave;
        public RecordValuesWrapper(){
        }
        public RecordValuesWrapper(String id,List<ValueWrapper> valueList,Boolean showRespectiveSave){
            this.id = id;
            this.showRespectiveSave = showRespectiveSave;
            this.valueList = valueList;
        }
    }

    public class ChecklistWrapper{
        @AuraEnabled
        public String headingName;
        @AuraEnabled
        public List<String> columnName;
        @AuraEnabled
        public String objName;
        @AuraEnabled
        public List<String> fieldsVisibleOnView;
        @AuraEnabled
        public List<RecordValuesWrapper> recordValues;
        @AuraEnabled
        public boolean showButtons;
        @AuraEnabled
        public Map<String,Object> onApproveFields;
        @AuraEnabled
        public Map<String,Object> onRejectFields;
        public ChecklistWrapper(){
        }
        public ChecklistWrapper(String headingName,List<String> columnName,List<RecordValuesWrapper> recordValues,String objName,List<String> fieldsVisibleOnView,Map<String,Object> onApproveFields,Map<String,Object> onRejectFields,boolean showButtons){
            this.headingName = headingName;
            this.columnName = columnName;
            this.recordValues = recordValues;
            this.objName = objName;
            this.fieldsVisibleOnView = fieldsVisibleOnView;
            this.onApproveFields = onApproveFields;
            this.onRejectFields = onRejectFields;
            this.showButtons = showButtons;
        }
    }
}