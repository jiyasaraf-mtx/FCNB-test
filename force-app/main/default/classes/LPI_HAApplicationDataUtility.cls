/**
 * @author                      : MTX Group Product Team
 * @since                       : april 13,2023
 * @description                 : This is a generic data utility class for Healing Arts Borad
 */
public with sharing class LPI_HAApplicationDataUtility {
    public final static String POST_GRADUATE_TRAINING_HISTORY_STEP = 'Postgraduate Training History'; 
    public final static String LICESNE_RELATIONSHIP_REPORT_STEP = 'License Relationship Report'; 
    public final static String JURIPRUDENCE_EXAM_STEP = 'Jurisprudence Examination';
    private final static Set<String> POST_GRADUATE_DATE_FIELDS_SET = new Set<String>{
        'StartDate',
        'GraduationDate',
        'PostgraduationTermStartDate',
        'PostgraduationTermCompletedDate'
    };


    public static List<LPI_PDFSectionWrapper> getSectionList(
        PreliminaryApplicationRef parRecord,
        Account accRecord,
        Set<String> appFlowSteps
    ) {
        List<LPI_PDFSectionWrapper> sectionList = new List<LPI_PDFSectionWrapper>();
        try{

            
            if (appFlowSteps.contains(POST_GRADUATE_TRAINING_HISTORY_STEP)) {
                sectionList.add(getPostGraduateTrainingHistorySection(parRecord));
            }

            
            if (appFlowSteps.contains(LICESNE_RELATIONSHIP_REPORT_STEP)) {
                sectionList.add(getLicenseRelationReport(parRecord));
            }

           
            if (appFlowSteps.contains(JURIPRUDENCE_EXAM_STEP)) {
                sectionList.add(getJurisprudenceExamSection(parRecord));
            }

        }catch(Exception e){
            LPI_ExceptionManager.logException('LPI_HAApplicationDataUtility', 'getSectionList', e);
        }
        
        return sectionList;
    }

    

    /**
     * @description : Get Postgraduate Training History Step
     * @author Rahul Ameta | 04-13-2023
     * @param parId : String
     * @return LPI_PDFSectionWrapper
     **/
    public static LPI_PDFSectionWrapper getPostGraduateTrainingHistorySection(PreliminaryApplicationRef parRecord) {
        String parId = parRecord.Id;
        Map<String, Object> output = new Map<String, Object>();
        LPI_PDFSectionWrapper mainSection = new LPI_PDFSectionWrapper(POST_GRADUATE_TRAINING_HISTORY_STEP, 3, null);
        Map<String, Object> myTransformData = new Map<String, Object>{
            'getParId' => parId,
            'parId' => parId,
            'filterEducationType' => 'Postgraduation Training'
        };
        omnistudio.DRProcessResult result = new omnistudio.DRProcessResult();
        if(parRecord.Type__c == 'Renewal' && parRecord.Have_you_received_PG_training_in_US_CA__c != null && parRecord.Have_you_received_PG_training_in_US_CA__c == 'Yes' ){
            result = omnistudio.DRGlobal.process(
                myTransformData,
                'FetchPostgraduatesTrainingHistoryRenewDetails'
            );
        } else if(parRecord.Type__c == 'Renewal' && parRecord.Have_you_received_PG_training_in_US_CA__c != null && parRecord.Have_you_received_PG_training_in_US_CA__c == 'No'){
            result = omnistudio.DRGlobal.process(
                myTransformData,
                'FetchPostgraduateTrainingHistoryDetail'
            );
        } else if(parRecord.Type__c != 'Renewal' && parRecord.Have_you_received_PG_training_in_US_CA__c != null && parRecord.Have_you_received_PG_training_in_US_CA__c == 'Yes'){
            result = omnistudio.DRGlobal.process(
                myTransformData,
                'FetchPersonEducationHistoryDetails'
            );
        }
        
        List<Map<String, Object>> myTransformResult = (List<Map<String, Object>>) result.toJsonList();
        List<LPI_PDFSectionWrapper> postGraduateTrainingList = new List<LPI_PDFSectionWrapper>();

        if (myTransformResult != null) {
            Map<String, String> fieldAPIToLabelMap = new Map<String, String>{
                'StreetAddress' => 'Street Address',
                'Location' => 'City',
                'State' => 'State',
                'ZipCode' => 'Zip Code',
                'Department' => 'Department/Speciality',
                'ProgramDirectorName' => 'Program Director Name',
                'StartDate' => 'Term Started',
                'GraduationDate' => 'Term Completed',
                'AccreditedBy' => 'Accredited By',
                'PostgraduationYear' => 'Postgraduation Year',
                'PostgraduationHours'=>'Hours Worked Per Week',
                'PostgraduationSupervisionHours'=>'Hours of One to One Supervision Per Week',
                'PostgraduationPercentageTime'=>'Estimate the Percentage of time dedicated to providing Marital & Family Therapy during the Practicum/Internship',

                'PostgraduationStreetAddress' => 'Street Address',
                'PostgraduationCity' => 'City',
                'PostgraduationState' => 'State',
                'PostgraduationZipCode' => 'Zip Code',
                'PostgraduationDepartment' => 'Department/Speciality',
                'PostgraduationProgramDirectorName' => 'Program Director Name',
                'PostgraduationTermStartDate' => 'Term Started',
                'PostgraduationTermCompletedDate' => 'Term Completed',
                'PostgraduationAccreditedBy' => 'Accredited By'
            };
            List<LPI_PDFSectionWrapper.DataWrapper> quesDataList = new List<LPI_PDFSectionWrapper.DataWrapper>();
            if(parRecord.Have_you_received_PG_training_in_US_CA__c != null && parRecord.Type__c == 'New'){
                quesDataList.add(
                new LPI_PDFSectionWrapper.DataWrapper(
                'Have you received post graduate trainings in the United States and Canada?',
                String.valueOf(parRecord.Have_you_received_PG_training_in_US_CA__c)
            )
            );
            }
            
            else if(parRecord.Have_you_received_PG_training_in_US_CA__c != null && parRecord.Type__c == 'Renewal'){
                quesDataList.add(
                new LPI_PDFSectionWrapper.DataWrapper(
                    'Do you confirm the fact that the Board of Healing Arts\'' + ' records indicate that you are American Specialty Board Certified or have obtained certification by the American Osteopathic Association?' + '\'',
                String.valueOf(parRecord.Have_you_received_PG_training_in_US_CA__c)
            )
            );
            }
            LPI_PDFSectionWrapper postGradTrainingQuestionSection = new LPI_PDFSectionWrapper('',1,quesDataList);
            postGraduateTrainingList.add(postGradTrainingQuestionSection);
        
            Integer counter = 1;
            for (Map<String, Object> postGraduateTraining : myTransformResult) {
                List<LPI_PDFSectionWrapper.DataWrapper> dataList = new List<LPI_PDFSectionWrapper.DataWrapper>();
                if(postGraduateTraining.containsKey('Degree') && String.valueOf(postGraduateTraining.get('Degree')) != null){
                    dataList.add(
                    new LPI_PDFSectionWrapper.DataWrapper(
                        'Training Facility Name',
                        String.valueOf(postGraduateTraining.get('Degree'))
                    )
                );
                }
                if(postGraduateTraining.containsKey('PostgraduationTrainingFacilityName') && String.valueOf(postGraduateTraining.get('PostgraduationTrainingFacilityName')) != null){
                    dataList.add(
                    new LPI_PDFSectionWrapper.DataWrapper(
                        'Training Facility Name',
                        String.valueOf(postGraduateTraining.get('PostgraduationTrainingFacilityName'))
                    )
                );
                }
                if(postGraduateTraining.containsKey('TrainingType') && String.valueOf(postGraduateTraining.get('TrainingType')) != null){
                    dataList.add(
                    new LPI_PDFSectionWrapper.DataWrapper(
                        'Type of Training',
                        String.valueOf(postGraduateTraining.get('TrainingType'))
                    )
                );
                }
                if(postGraduateTraining.containsKey('PostgraduationTrainingType') && String.valueOf(postGraduateTraining.get('PostgraduationTrainingType')) != null){
                    dataList.add(
                    new LPI_PDFSectionWrapper.DataWrapper(
                        'Type of Training',
                        String.valueOf(postGraduateTraining.get('PostgraduationTrainingType'))
                    )
                );
                }
                
                LPI_PDFSectionWrapper postGradTrainingSection = new LPI_PDFSectionWrapper(
                    POST_GRADUATE_TRAINING_HISTORY_STEP + ' ' + counter,
                    2,
                    dataList
                );
                dataList.clear();
                for (String fieldAPI : fieldAPIToLabelMap.keySet()) {
                    if (postGraduateTraining.containsKey(fieldAPI)) {
                        String fieldValue = (POST_GRADUATE_DATE_FIELDS_SET.contains(fieldAPI))
                            ? Date.valueOf(String.valueOf(postGraduateTraining.get(fieldAPI)))?.format()
                            : String.valueOf(postGraduateTraining.get(fieldAPI));
                        dataList.add(
                            new LPI_PDFSectionWrapper.DataWrapper(fieldAPIToLabelMap.get(fieldAPI), fieldValue)
                        );
                    }
                }
                if (
                    postGraduateTraining.containsKey('Specify') &&
                    String.valueOf(postGraduateTraining.get('AccreditedBy')) == 'Other'
                ) {
                    dataList.add(
                        new LPI_PDFSectionWrapper.DataWrapper(
                            'Specify',
                            String.valueOf(postGraduateTraining.get('Specify'))
                        )
                    );
                }

                if (
                    postGraduateTraining.containsKey('PostgraduationSpecify') &&
                    String.valueOf(postGraduateTraining.get('PostgraduationAccreditedBy')) == 'Other'
                ) {
                    dataList.add(
                        new LPI_PDFSectionWrapper.DataWrapper(
                            'Specify',
                            String.valueOf(postGraduateTraining.get('PostgraduationSpecify'))
                        )
                    );
                }
                if (
                    postGraduateTraining.containsKey('PostgraduationSpecifyReadOnly') &&
                    String.valueOf(postGraduateTraining.get('PostgraduationAccreditedBy')) == 'Other'
                ) {
                    dataList.add(
                        new LPI_PDFSectionWrapper.DataWrapper(
                            'Specify',
                            String.valueOf(postGraduateTraining.get('PostgraduationSpecifyReadOnly'))
                        )
                    );
                }
                
                postGradTrainingSection.addSubSection(
                    new LPI_PDFSectionWrapper('Training Facility Address', 2, dataList, true)
                );
                postGraduateTrainingList.add(postGradTrainingSection);
                counter += 1;
            }
        }

        mainSection.addSubSection(postGraduateTrainingList);
        return mainSection;
    }

    

    /**
     * @description : Get License Relationship Report Step
     * @author MTX Group Product Team | 04-13-2023
     * @param parRecord : PreliminaryApplicationRef
     * @return LPI_PDFSectionWrapper
     **/
    public static LPI_PDFSectionWrapper getLicenseRelationReport(PreliminaryApplicationRef parRecord) {
        LPI_PDFSectionWrapper mainSection;
        List<LPI_PDFSectionWrapper.DataWrapper> dataList = new List<LPI_PDFSectionWrapper.DataWrapper>();
        mainSection = new LPI_PDFSectionWrapper(LICESNE_RELATIONSHIP_REPORT_STEP, 1, dataList);
        dataList.clear();
        Map<String, Object> input = new Map<String, Object>();
        input.put('parId', parRecord.Id);
        input.put('readOnly', 'Yes');
        List<Map<String, Object>> superVisorList = new List<Map<String, Object>>();
        superVisorList.add(LPI_ApplicantSupervisorController.fetchPrimarySupervisorACR(input));
       
        for (Map<String, Object> superVisor : superVisorList) {
            Map<String, String> fieldAPIToLabelMap = new Map<String, String>{
                'supervisorLicenseNumber' => 'License Number',
                'SupervisorFirstName' => 'First Name',
                'supervisorMiddleName' => 'Middle Name',
                'supervisorLastName' => 'Last Name',
                'supervisorStreetAddress' => 'Employment Street Address',
                'supervisorCity' => 'City',
                'supervisorZip' => 'Zip Code',
                'supervisorState' => 'State',
                'supervisorPhone' => 'Telephone Number',
                'supervisorEmail' => 'Email Address',
                'supervisorSpecialityCertification' => 'Speciality/Board Certification'
            };
            dataList.clear();
            for (String fieldAPI : fieldAPIToLabelMap.keySet()) {
                if (superVisor != null && superVisor.containsKey(fieldAPI)) {
                    dataList.add(
                        new LPI_PDFSectionWrapper.DataWrapper(
                            fieldAPIToLabelMap.get(fieldAPI),
                            String.valueOf(superVisor.get(fieldAPI))
                        )
                    );
                }
            }
            mainSection.addSubSection(new LPI_PDFSectionWrapper('Primary Supervisor', 2, dataList));
        }

        return mainSection;
    }

    /**
     * @description : Get Jurisprudence Examination Step
     * @author MTX Group Product Team | 04-13-2023
     * @param parRecord : PreliminaryApplicationRef
     * @return LPI_PDFSectionWrapper
     **/
    public static LPI_PDFSectionWrapper getJurisprudenceExamSection(PreliminaryApplicationRef parRecord) {
        LPI_OSStepParser osParser = new LPI_OSStepParser(parRecord.Jurisprudence_Examination_Step_API_Name__c);
        return osParser.getPDFSectionWrapper(parRecord.Jurisprudence_Examination__c, JURIPRUDENCE_EXAM_STEP);
    }

}