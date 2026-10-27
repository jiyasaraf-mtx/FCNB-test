/**
 * @author                      : MTX Group Product Team
 * @since                       : Dec 6th 2023
 * @description                 : This is a controller class for LPI_ApplicationReviewInfoTemplatePage
 *-------------------------------------------------------------------------------------------------------
 */
public with sharing class LPI_ApplicationReviewInfoPDFController {
    public List<LPI_PDFSectionWrapper> pdfSectionWrapper { get; private set; }
    public String parName { get; private set; }
    public String applicationName { get; private set; }
    public String businessLicenseNumber { get; private set; }
    public String blLicenseId { get;private set; }
    private PreliminaryApplicationRef parRecord;
    private Account accRecord;
    public final static String PERSONAL_INFO_STEP = 'Personal Information';
    public final static String BUSINESS_INFORMATION_STEP = 'Business Information';
    public final static List<LPI_PDFSectionWrapper> sectionList = new List<LPI_PDFSectionWrapper>();
    public final static String NURING_PRGM_INFO = 'Nursing Program Information';
    public static final String SCHOOL_INFORMATION = 'School Information';
    /**
     * @author                      : MTX Group Product Team
     * @since                       : Dec 6th 2023
     * @description                 : Constructor for the class
     * @return                      :
     * @last modified by            : Uzma Md
     * @last modified date          :
     * @modified details            :
     */
    public LPI_ApplicationReviewInfoPDFController() {
        try {
            Id targetId = ApexPages.currentPage().getParameters().get('targetId');
            if (String.isNotBlank(targetId)) {
                String objectType = String.valueOf(targetId.getSObjectType());
                String parId = getPARRecordId(targetId, objectType);
                 
                dataSetupForApplication(parId);
                 
                prepareSectionWrapperListToShow();
                
                fetchDueDiligenceRecords(targetId);
                 
                fetchExamRecords();
                
                fetchInspectionRecords(targetId);
                 
                fetchComplaintRecords();
                this.pdfSectionWrapper = new List<LPI_PDFSectionWrapper>();
                 
                for (LPI_PDFSectionWrapper sectionWrapper : sectionList) {
                    if(sectionWrapper!=null && sectionWrapper.sectionName != null){
                        this.pdfSectionWrapper.add(sectionWrapper);
                    }   
                }
                string fileName = 'Application Licensee Review Information '+this.applicationName;
                Apexpages.currentPage()
                .getHeaders()
                .put('content-disposition', 'attachment; filename='+fileName+'.pdf');
            }
        } catch (Exception e) {
            LPI_ExceptionManager.logException('LPI_ApplicationReviewInfoPDFController', '', e);
            throw new AuraHandledException(e.getMessage() + e.getLineNumber());
        }
    }

    /**
     * @author                      : MTX Group Product Team
     * @since                       : Dec 6th 2023
     * @description                 : This method will give par Id from the target Id
     * @param targetId              : Id
     * @param objectType            : String
     * @return                      : String
     * @last modified by            : Uzma Md
     * @last modified date          :
     * @modified details            :
     */
    private String getPARRecordId(Id targetId, String objectType) {
        String parId = '';
        String fieldToQuery = 'Id, Name, SavedApplicationRefId , LicenseTypeId ';
        String whereClause = ' Id = \'' + targetId + '\'';
        if (objectType == 'IndividualApplication') {
            List<IndividualApplication> iaList = LPI_IndividualApplicationDAO.getIndividualApplicationByDymanicQuery(
                fieldToQuery,
                whereClause,
                null,
                null,
                null
            );
            if (!iaList.isEmpty()) {
                parId = iaList[0].SavedApplicationRefId;
                applicationName = iaList[0].Name;
                if(iaList[0].LicenseTypeId!=null){
                    blLicenseId = iaList[0].LicenseTypeId;
                }
            }
        } else if (objectType == 'BusinessLicenseApplication') {
            List<BusinessLicenseApplication> blaList = LPI_BusinessLicenseApplicationDAO.getBusinessLicenseApplicationByDymanicQuery(
                fieldToQuery,
                whereClause,
                null,
                null,
                null
            );
            if (!blaList.isEmpty()) {
                parId = blaList[0].SavedApplicationRefId;
                applicationName = blaList[0].Name;
                if(blaList[0].LicenseTypeId!=null){
                    blLicenseId = blaList[0].LicenseTypeId;
                }
            }
        }
        return parId;
    }

    /**
     * @author                      : MTX Group Product Team
     * @since                       : Dec 6th 2023
     * @description                 : This method will do the data setup for pdf controller
     * @param parId                 : String
     * @return                      : void
     * @last modified by            : Uzma Md
     * @last modified date          :
     * @modified details            :
     */
    private void dataSetupForApplication(String parId) {
        String fieldToQuery;
        String whereClause;
        String accountId;

        
        if (parId != null) {
            fieldToQuery =
                'Id,Name,FirstName__c,MiddleName__c,MaidenName__c,LastName__c,Contact__c,Regulatory_Authorization_Type__c,' +
                'Other_Names__c,BusinessAccountNameId,Tax_Compliance__c,License_Questions__c,Business_License__r.PeriodStart,' +
                'Info_About_Military_Related_Services__c,Served_In_US_Armed_Force__c,Type__c,Amendment_Type__c,Currently_Holding_Active_License_Number__c,' +
                'Regulatory_Authorization_Type__r.Name,Regulatory_Authorization_Type__r.IssuingDepartment.Name,Business_License__r.Status, ' +
                'Are_you_currently_Employed__c,Steps_Name__c,Require_the_board_to_include_School__c, ' +
                'Choose_the_Certification_Delivery_option__c,Certification_Email__c,' +
                'Fax_Number__c,License_Questions_Step_API_Name__c,Audit_Escrow_or_Trust_Account_Questions__c,' +
                'Consent_for_Primary_Contact_Address__c,' +
                'Method_of_Licensure__c,' +
                'Primary_Supevisor_Collaborative_Practice__c,Jurisprudence_Examination_Step_API_Name__c,Board_Name__c,' +
                'Jurisprudence_Examination__c,Business_License__r.Name,Business_License__r.Legacy_License_Number__c,Business_License__c,BusinessAccountName.How_are_you_associated_to_this_entity__c,' +
                'ApplicationType,How_are_you_associated_to_this_entity__c,'+
                'Contact__r.Id,Primary_Contact_Address__c,License_Address__c,'+
                'Publicly_Displayed_Address__c, Business_License__r.PeriodEnd, Is_Supervisor_User__c,'+
                ' Reviewer__c,Attestation_Step_API_Name__c,Attestation_Data__c,'+
                'Person_Incharge_Relation_Id__c,Controlled_Substance_Checkbox__c,'+
                'Street_Address__c,Zip_Code__c,City__c,Postal_State__c,Country__c, Do_you_maintain_Trust_or_Joint_Account__c,Have_you_received_PG_training_in_US_CA__c';
            whereClause = 'Id = \'' + parId + '\'';

            List<PreliminaryApplicationRef> parRecord = LPI_PreliminaryApplicationRefDAO.getPreliminaryApplicationRefByDymanicQuery(
                fieldToQuery,
                whereClause,
                null,
                null,
                null
            );
            if (!parRecord.isEmpty()) {
                this.parRecord = parRecord[0];
                this.parName = parRecord[0].Name;
                if(parRecord[0].Business_License__c != null){
                    this.businessLicenseNumber = String.isNotBlank(parRecord[0].Business_License__r.Legacy_License_Number__c)
                    ? 'License Number : ' + parRecord[0].Business_License__r.Legacy_License_Number__c
                    : 'License Number : ' + parRecord[0].Business_License__r.Name;
                }
                accountId = parRecord[0].BusinessAccountNameId;
            }
        }
        
        
        if (accountId != null) { 
            fieldToQuery =
                'Id,Suffix,PersonEmail,Social_Security_Number__c,Date_of_Birth__c,Age__c,Gender__c,Place_of_Birth__c,' +
                'Phone,PersonHomePhone,Fax,Identity_Number__c,Race__c, PersonOtherPhone ,' +
                'Language__c,Citizenship__c,Nationality__c,Other_Nationality__c,' +
                'Other_Language__c,Other_Citizenship__c,Other_Race__c,Other_Names__c,' +
                'Proof_of_work_permit_in_United_States__c, ' +
                'Proof_of_Citizenship__c ';
                
            whereClause = 'Id = \'' + accountId + '\'';

            List<Account> accList = LPI_AccountDAO.getAccountListByDynamicQuery(
                fieldToQuery.split(','),
                whereClause,
                null,
                null,
                null
            );
            if (!accList.isEmpty()) {
                this.accRecord = accList[0];
            }
        }
    }

    /**
     * @author                      : MTX Group Product Team 
     * @since                       : Dec 6th,2023
     * @description                 : This method will prepare the section List to show on pdf side
     * @return                      : void
     * @last modified by            : Uzma Md
     * @last modified date          :
     * @modified details            :
     */
    private void prepareSectionWrapperListToShow() {
        if (this.parRecord == null) {
            return;
        }
        Set<String> appFlowSteps = new Set<String>{'License'};
        List<String> allFlowSteps = new List<String>();
        if (this.parRecord != null && this.parRecord.Steps_Name__c != null) {
            allFlowSteps = this.parRecord.Steps_Name__c.split(';');
        }
        if(!allFlowSteps.isEmpty() && allFlowSteps.contains(PERSONAL_INFO_STEP)){
            appFlowSteps.add(PERSONAL_INFO_STEP);
        }else if(!allFlowSteps.isEmpty() && allFlowSteps.contains(BUSINESS_INFORMATION_STEP)){
            appFlowSteps.add(BUSINESS_INFORMATION_STEP);
        }
        if (appFlowSteps != null && !appFlowSteps.isEmpty()) {
           
            sectionList.addAll(
                LPI_ApplicationDataUtility.getSectionList(this.parRecord, this.accRecord, appFlowSteps)
            );
            
        }
        
    }
    /**
     * @author                      : MTX Group Product Team 
     * @since                       : Dec 7th,2023
     * @description                 : This method will fetch all Due Diligence Records related to Applicant and form Section Wrapper.
     * @return                      : void
     * @last modified by            : Uzma Md
     * @last modified date          :
     * @modified details            :
     */
    private void fetchDueDiligenceRecords(Id targetId){
        LPI_PDFSectionWrapper dueDiligenceSection = new LPI_PDFSectionWrapper(
            'Due Diligence Items',
            2,
            null
        );
        Integer counter =1;
        String fieldsToQuery = 'Id,Completed_by__r.Name,Application_Status__c,Checklist_Name__c,Comment__c,Completion_Date__c,'
                                +'Sequence__c,Status__c,Application__c,Individual_Application__c';
        String whereClause = ' Application__c = \'' + targetId + '\''
                             +' OR Individual_Application__c = \'' +targetId + '\'' ;
        String orderBy = 'Application_Status__c DESC, Sequence__c ASC';
        for(Due_Diligence__c ddRecord : LPI_DueDiligenceDAO.getDueDiligenceByDymanicQuery(
            fieldsToQuery,
            whereClause,
            null,
            orderBy,
            null
        )){
            List<LPI_PDFSectionWrapper.DataWrapper> dataList = new List<LPI_PDFSectionWrapper.DataWrapper>();
            if(ddRecord.Checklist_Name__c!=null){
                dataList.add(
                    new LPI_PDFSectionWrapper.DataWrapper(
                        'Checklist Name',
                        ddRecord.Checklist_Name__c
                    )
                );
            }else{
                dataList.add(
                    new LPI_PDFSectionWrapper.DataWrapper(
                        'Checklist Name',
                        '-'
                    )
                );
            }
            if(ddRecord.Comment__c!=null){
            dataList.add(
                new LPI_PDFSectionWrapper.DataWrapper(
                    'Comment',
                    ddRecord.Comment__c
                )
            );
            }else{
                dataList.add(
                    new LPI_PDFSectionWrapper.DataWrapper(
                        'Comment',
                        '-'
                    )
                );
            }
            if(ddRecord.Status__c!=null){
            dataList.add(
                new LPI_PDFSectionWrapper.DataWrapper(
                    'Status',
                    ddRecord.Status__c
                )
            );
            }else{
                dataList.add(
                    new LPI_PDFSectionWrapper.DataWrapper(
                        'Status',
                        '-'
                    )
                );
            }
            if(ddRecord.Completed_by__r.Name!=null){
            dataList.add(
                new LPI_PDFSectionWrapper.DataWrapper(
                    'Completed By',
                    ddRecord.Completed_by__r.Name
                )
            );
            }else{
                dataList.add(
                    new LPI_PDFSectionWrapper.DataWrapper(
                        'Completed By',
                        '-'
                    )
                );
            }
            DateTime StartDate = ddRecord.Completion_Date__c;
            if(StartDate!=null){
                dataList.add(
                    new LPI_PDFSectionWrapper.DataWrapper(
                        'Completion Date',
                        StartDate.format('MM/dd/YYYY')
                    )
                );
            }else{
                dataList.add(
                    new LPI_PDFSectionWrapper.DataWrapper(
                        'Completion Date',
                        '-'
                    )
                );
            }
            dueDiligenceSection.addSubSection(new LPI_PDFSectionWrapper('Due Diligence Item #'+counter ,2, dataList));
            counter+=1;
        }
        if(counter==1){
            return;
        }
        sectionList.add(dueDiligenceSection);
    }
    /**
     * @author                      : MTX Group Product Team
     * @since                       : Dec 7th,2023
     * @description                 : This method will fetch all PersonExamination Records related to Applicant and form Section Wrapper.
     * @return                      : void
     * @last modified by            : Uzma Md
     * @last modified date          :
     * @modified details            :
     */
    private void fetchExamRecords(){
        if (this.parRecord == null) {
            return;
        }
        String fields;
        String whereClause;
        Set<Id> examIdSet = new Set<Id>();
        if(this.parRecord.Regulatory_Authorization_Type__c!=null){
            fields = ' Id ,Examination__c,Regulatory_Authorization_Type__c ';
            whereClause = ' Regulatory_Authorization_Type__c = \'' + String.escapeSingleQuotes(this.parRecord.Regulatory_Authorization_Type__c) + '\'';
            for (Regulatory_Examination_Junction__c examRecord : LPI_RegulatoryExaminationJunctionDao.getRegulatoryExaminationJunctionByDymanicQuery(fields,whereClause,null,null,null)){
                examIdSet.add(examRecord.Examination__c);
            }
        }
        if(this.parRecord.Contact__c!=null && !examIdSet.isEmpty()){
            List<LPI_PDFSectionWrapper.DataWrapper> dataList = new List<LPI_PDFSectionWrapper.DataWrapper>();
            dataList.add(
                    new LPI_PDFSectionWrapper.DataWrapper(
                        'Exam Name',
                        ''
                    ));
                    dataList.add(
                    new LPI_PDFSectionWrapper.DataWrapper(
                        'Exam Subsections',
                        ''
                    ));
                    dataList.add(
                    new LPI_PDFSectionWrapper.DataWrapper(
                        'Exam Scores',
                        ''
                    ));
                    dataList.add(
                    new LPI_PDFSectionWrapper.DataWrapper(
                        'Exam Results',
                        ''
                    )
                );
            fields = ' Id ,Result , Score , Examination_Formula__c , ExaminationId ';
            whereClause = ' ExaminationId IN '+LPI_ServiceUtility.getStringValuesBySet(examIdSet)
            + ' AND ContactId = \'' + String.escapeSingleQuotes(this.parRecord.Contact__c) + '\'';
            LPI_PersonExaminationDAO.LPI_PersonExaminationWithoutSharingDAO withoutShare = new LPI_PersonExaminationDAO.LPI_PersonExaminationWithoutSharingDAO();
            List<PersonExamination> examList = withoutShare.getPersonExaminationByDynamicQuery(fields,whereClause,null,null,null);
            if(examList.isEmpty()){
                return;
            }
            for(PersonExamination personExam : examList){
                if(personExam.Examination_Formula__c!=null){
                    dataList.add(
                        new LPI_PDFSectionWrapper.DataWrapper(
                            '',
                            personExam.Examination_Formula__c
                        )
                    );
                }else{
                    dataList.add(
                        new LPI_PDFSectionWrapper.DataWrapper(
                            '',
                            '-'
                        )
                    );
                }
                if(personExam.Examination_Formula__c!=null){
                    dataList.add(
                        new LPI_PDFSectionWrapper.DataWrapper(
                            '',
                            ''
                        )
                    );
                }else{
                    dataList.add(
                        new LPI_PDFSectionWrapper.DataWrapper(
                            '',
                            '-'
                        )
                    );
                }
                if(personExam.Score!=null){
                    dataList.add(
                        new LPI_PDFSectionWrapper.DataWrapper(
                            '',
                            String.valueOf(personExam.Score)
                        )
                    );
                }else{
                    dataList.add(
                        new LPI_PDFSectionWrapper.DataWrapper(
                            '',
                            '-'
                        )
                    );
                }
                if(personExam.Result!=null){
                    dataList.add(
                        new LPI_PDFSectionWrapper.DataWrapper(
                            '',
                            personExam.Result
                        )
                    );
                }else{
                    dataList.add(
                        new LPI_PDFSectionWrapper.DataWrapper(
                            '',
                            '-'
                        )
                    );
                }
            }
            LPI_PDFSectionWrapper examSection = new LPI_PDFSectionWrapper(
                'Exam Information',
                4,
                dataList
            );
        sectionList.add(examSection);
        }
    }
    /**
     * @author                      : MTX Group Product Team 
     * @since                       : Dec 7th,2023
     * @description                 : This method will fetch all Inspection Records related to Applicant and form Section Wrapper.
     * @return                      : void
     * @last modified by            : Uzma Md
     * @last modified date          :
     * @modified details            :
     */
    private void fetchInspectionRecords(Id targetId){
        LPI_PDFSectionWrapper inspectionSection = new LPI_PDFSectionWrapper(
            'Inspection Information',
            2,
            null
        );
        String fields = ' Business_Name__c , Inspector_Name__c , Address_Name__c , VisitType.Name , Date_Assigned__c , Id , VisitorId, Visitor.Name ';
        String whereClause = ' ContextId = \'' + targetId + '\'';
        Integer counter = 1;
        for(Visit record : LPI_VisitControllerDAO.getVisitListByDynamicQueryWithoutSecurity(fields.split(','),whereClause,null,null,null)){
            List<LPI_PDFSectionWrapper.DataWrapper> dataList = new List<LPI_PDFSectionWrapper.DataWrapper>();
            if(record.Date_Assigned__c!=null){
                DateTime assignDate = record.Date_Assigned__c;
                dataList.add(
                    new LPI_PDFSectionWrapper.DataWrapper(
                        'Assigned Date',
                        assignDate.format('MM/dd/YYYY')
                    )
                );
            }else{
                dataList.add(
                    new LPI_PDFSectionWrapper.DataWrapper(
                        'Assigned Date',
                        '-'
                    )
                );
            }
            if(record.Business_Name__c!=null){
                dataList.add(
                    new LPI_PDFSectionWrapper.DataWrapper(
                        'Business Name',
                        record.Business_Name__c
                    )
                );
            }else{
                dataList.add(
                    new LPI_PDFSectionWrapper.DataWrapper(
                        'Business Name',
                        '-'
                    )
                );
            }
            if(record.VisitorId!=null && record.Visitor.Name!=null){
                dataList.add(
                    new LPI_PDFSectionWrapper.DataWrapper(
                        'Inspector Name',
                        record.Visitor.Name
                    )
                );
            }else{
                dataList.add(
                    new LPI_PDFSectionWrapper.DataWrapper(
                        'Inspector Name',
                        '-'
                    )
                );
            }
            if(record.VisitType.Name!=null){
                dataList.add(
                    new LPI_PDFSectionWrapper.DataWrapper(
                        'Visit Type',
                        record.VisitType.Name
                    )
                );
            }else{
                dataList.add(
                    new LPI_PDFSectionWrapper.DataWrapper(
                        'Visit Type',
                        '-'
                    )
                );
            }
            if(record.Address_Name__c!=null){
                dataList.add(
                    new LPI_PDFSectionWrapper.DataWrapper(
                        'Address',
                        record.Address_Name__c
                    )
                );
            }else{
                dataList.add(
                    new LPI_PDFSectionWrapper.DataWrapper(
                        'Address',
                        '-'
                    )
                );
            }
            dataList.add(
                    new LPI_PDFSectionWrapper.DataWrapper(
                        '',
                        ''
                    )
                );
            inspectionSection.addSubSection(new LPI_PDFSectionWrapper('Inspection '+counter ,2, dataList));
            counter+=1;
        }
        if(counter==1){
            return;
        }
        sectionList.add(inspectionSection);
    } 
    /**
     * @author                      : MTX Group Product Team 
     * @since                       : Dec 7th,2023
     * @description                 : This method will fetch all Complaint Records related to Applicant and form Section Wrapper.
     * @return                      : void
     * @last modified by            : Uzma Md
     * @last modified date          :
     * @modified details            :
     */
    private void fetchComplaintRecords(){
        if(this.accRecord == null){
            return;
        }
        Set<Id> blIdSet = new Set<Id>();
        Set<Id> complaintIdSet = new Set<Id>();
        Set<Id>  caseIdSet = new Set<Id>();
        Integer counter =1;
        LPI_PDFSectionWrapper complaintSection = new LPI_PDFSectionWrapper(
            'Complaint Information',
            2,
            null
        );
        String fields = ' Id , AccountId ';
        String whereClause = ' AccountId = \'' + this.accRecord.Id + '\'';
        LPI_BusinessLicenseDAO.LPI_BusinessLicenseWithoutSharingDAO withoutshare = new LPI_BusinessLicenseDAO.LPI_BusinessLicenseWithoutSharingDAO();
        for(BusinessLicense blRecord : withoutshare.getBusinessLicenseByDymanicQuery(fields,whereClause,null,null,null)){
            blIdSet.add(blRecord.Id);
        }
        if(blIdSet.isEmpty()){
            return;
        }
        fields = ' Public_Complaint__c , Business_License__c, Id ';
        whereClause = ' Business_License__c IN '+LPI_ServiceUtility.getStringValuesBySet(blIdSet);
        for(Business_Complaint__c complaintJUNC : LPI_BusinesComplaintJunctionDao.getBusinessComplaintByDymanicQuery(fields,whereClause,null,null,null)){
            complaintIdSet.add(complaintJUNC.Public_Complaint__c);
        }
        if(complaintIdSet.isEmpty()){
            return;
        }
        Map<Id , List<LPI_PDFSectionWrapper.DataWrapper>> idPdfWrapperMap = new Map<Id , List<LPI_PDFSectionWrapper.DataWrapper>>();
        fields = ' Complaint_Details__c , AccountId ,Reported_Date__c, Status , Name,Id ';
        whereClause = ' Id IN ' +LPI_ServiceUtility.getStringValuesBySet(complaintIdSet);
        LPI_PublicComplaintDao.LPI_PublicComplaintWithoutSharingDAO withoutShareComplaint = new LPI_PublicComplaintDao.LPI_PublicComplaintWithoutSharingDAO();
        for(PublicComplaint complaint : withoutShareComplaint.getPublicComplaintByDymanicQuery(fields,whereClause,null,null,null)){
            List<LPI_PDFSectionWrapper.DataWrapper> dataList = new List<LPI_PDFSectionWrapper.DataWrapper>();
            if(complaint.Name!=null){
                dataList.add(
                    new LPI_PDFSectionWrapper.DataWrapper(
                        'Name',
                        complaint.Name
                    )
                );
            }else{
                dataList.add(
                    new LPI_PDFSectionWrapper.DataWrapper(
                        'Name',
                        '-'
                    )
                );
            }
            if(complaint.Complaint_Details__c!=null){
                dataList.add(
                    new LPI_PDFSectionWrapper.DataWrapper(
                        'Complaint Details',
                        complaint.Complaint_Details__c
                    )
                );
            }else{
                dataList.add(
                    new LPI_PDFSectionWrapper.DataWrapper(
                        'Complaint Details',
                        '-'
                    )
                );
            }
            if(complaint.Reported_Date__c!=null){
                DateTime assignDate = complaint.Reported_Date__c;
                dataList.add(
                    new LPI_PDFSectionWrapper.DataWrapper(
                        'Reported Date',
                        assignDate.format('MM/dd/YYYY')
                    )
                );
            }else{
                dataList.add(
                    new LPI_PDFSectionWrapper.DataWrapper(
                        'Reported Date',
                        '-'
                    )
                );
            }
            if(complaint.Status!=null){
                dataList.add(
                    new LPI_PDFSectionWrapper.DataWrapper(
                        'Complaint Status',
                        complaint.Status
                    )
                );
            }else{
                dataList.add(
                    new LPI_PDFSectionWrapper.DataWrapper(
                        'Complaint Status',
                        '-'
                    )
                );
            }
            idPdfWrapperMap.put(complaint.Id , dataList);
        }
        
        Map<Id , Id> caseComplaintMap = new Map<Id , Id>();
        fields = ' Id , PublicComplaintId , CaseId ';
        whereClause =  ' PublicComplaintId IN '+LPI_ServiceUtility.getStringValuesBySet(complaintIdSet);
        LPI_ComplaintCaseDao.LPI_ComplaintCaseWithoutSharingDAO complaintCaseObj = new LPI_ComplaintCaseDao.LPI_ComplaintCaseWithoutSharingDAO();
        for(ComplaintCase caseRec : complaintCaseObj.getComplaintCaseByDymanicQuery(fields,whereClause,null,null,null)){
            caseIdSet.add(caseRec.CaseId);
            caseComplaintMap.put(caseRec.CaseId , caseRec.PublicComplaintId);
        }
        Map<Id , List<List<LPI_PDFSectionWrapper.DataWrapper>>> casePdfWrapperMap = new Map<Id , List<List<LPI_PDFSectionWrapper.DataWrapper>>>();
        Map<Id , List<List<LPI_PDFSectionWrapper.DataWrapper>>> regCodeMap = new Map<Id , List<List<LPI_PDFSectionWrapper.DataWrapper>>>();
        Map<Id , List<List<LPI_PDFSectionWrapper.DataWrapper>>> taskPdfWrapperMap = new Map<Id , List<List<LPI_PDFSectionWrapper.DataWrapper>>>();
        if(!caseIdSet.isEmpty()){
         
        fields = 'Id , WhatId , Action__c , Subject , Status , Priority ,Description , Date_Received__c , CompletedDateTime ';
        whereClause =  ' WhatId IN '+LPI_ServiceUtility.getStringValuesBySet(caseIdSet);
        LPI_TaskDao.LPI_DAO_TaskWithoutSecurity taskWithout = new LPI_TaskDao.LPI_DAO_TaskWithoutSecurity();
        for(Task taskRec : taskWithout.fetchTaskRecords(fields,whereClause,null,null)){
            List<LPI_PDFSectionWrapper.DataWrapper> dataList = new List<LPI_PDFSectionWrapper.DataWrapper>();
            if(taskRec.Subject!=null){
                dataList.add(
                    new LPI_PDFSectionWrapper.DataWrapper(
                        'Task Subject',
                        taskRec.Subject
                    )
                );
            }else{
                dataList.add(
                    new LPI_PDFSectionWrapper.DataWrapper(
                        'Task Subject',
                        '-'
                    )
                );
            }
            if(taskRec.Status!=null){
                dataList.add(
                    new LPI_PDFSectionWrapper.DataWrapper(
                        'Task Status',
                        taskRec.Status
                    )
                );
            }else{
                dataList.add(
                    new LPI_PDFSectionWrapper.DataWrapper(
                        'Task Status',
                        '-'
                    )
                );
            }
            if(taskRec.Subject!=null){
                dataList.add(
                    new LPI_PDFSectionWrapper.DataWrapper(
                        'Task Priority',
                        taskRec.Priority
                    )
                );
            }else{
                dataList.add(
                    new LPI_PDFSectionWrapper.DataWrapper(
                        'Task Priority',
                        '-'
                    )
                );
            }
            if(taskRec.Date_Received__c!=null){
                DateTime assignDate = taskRec.Date_Received__c;
                dataList.add(
                    new LPI_PDFSectionWrapper.DataWrapper(
                        'Date Received',
                        assignDate.format('MM/dd/YYYY')
                    )
                );
            }else{
                dataList.add(
                    new LPI_PDFSectionWrapper.DataWrapper(
                        'Date Received',
                        '-'
                    )
                );
            }
            if(taskRec.CompletedDateTime!=null){
                DateTime completeDate = taskRec.CompletedDateTime;
                dataList.add(
                    new LPI_PDFSectionWrapper.DataWrapper(
                        'Completed Date',
                        completeDate.format('MM/dd/YYYY')
                    )
                );
            }else{
                dataList.add(
                    new LPI_PDFSectionWrapper.DataWrapper(
                        'Completed Date',
                        '-'
                    )
                );
            }
            if(caseComplaintMap!=null && caseComplaintMap.containsKey(taskRec.WhatId)){
                Id compalintId = caseComplaintMap.get(taskRec.WhatId);
                if(!taskPdfWrapperMap.containsKey(compalintId)){
                    List<List<LPI_PDFSectionWrapper.DataWrapper>> tempList = new List<List<LPI_PDFSectionWrapper.DataWrapper>>();
                    tempList.add(dataList);
                    taskPdfWrapperMap.put(compalintId, tempList);
                }
                taskPdfWrapperMap.get(compalintId).add(dataList);
            }
            
        }
        
        fields = 'Id , Status , Subject , Description ,Date_Filed__c ,Case_Number__c ';
        whereClause = 'Id IN '+LPI_ServiceUtility.getStringValuesBySet(caseIdSet);
        LPI_CaseDAO.LPI_CaseWithoutSharingDAO caseWithout = new LPI_CaseDAO.LPI_CaseWithoutSharingDAO();
        for(Case caseRec : caseWithout.getCaseRecordsWithoutSharing(fields,whereClause,null,null)){
            List<LPI_PDFSectionWrapper.DataWrapper> dataList = new List<LPI_PDFSectionWrapper.DataWrapper>();
            if(caseRec.Case_Number__c!=null){
                dataList.add(
                    new LPI_PDFSectionWrapper.DataWrapper(
                        'Case Number',
                        caseRec.Case_Number__c
                    )
                );
            }else{
                dataList.add(
                    new LPI_PDFSectionWrapper.DataWrapper(
                        'Case Number',
                        '-'
                    )
                );
            }
            if(caseRec.Subject!=null){
                dataList.add(
                    new LPI_PDFSectionWrapper.DataWrapper(
                        'Case Subject',
                        caseRec.Subject
                    )
                );
            }else{
                dataList.add(
                    new LPI_PDFSectionWrapper.DataWrapper(
                        'Case Subject',
                        '-'
                    )
                );
            }
            if(caseRec.Status!=null){
                dataList.add(
                    new LPI_PDFSectionWrapper.DataWrapper(
                        'Case Status',
                        caseRec.Status
                    )
                );
            }else{
                dataList.add(
                    new LPI_PDFSectionWrapper.DataWrapper(
                        'Case Status',
                        '-'
                    )
                );
            }
            if(caseRec.Description!=null){
                dataList.add(
                    new LPI_PDFSectionWrapper.DataWrapper(
                        'Case Description',
                        caseRec.Description
                    )
                );
            }else{
                dataList.add(
                    new LPI_PDFSectionWrapper.DataWrapper(
                        'Case Description',
                        '-'
                    )
                );
            }
            if(caseRec.Date_Filed__c!=null){
                DateTime completeDate = caseRec.Date_Filed__c;
                dataList.add(
                    new LPI_PDFSectionWrapper.DataWrapper(
                        'Date Filed',
                        completeDate.format('MM/dd/YYYY')
                    )
                );
            }else{
                dataList.add(
                    new LPI_PDFSectionWrapper.DataWrapper(
                        'Date Filed',
                        '-'
                    )
                );
            }
            if(caseComplaintMap!=null && caseComplaintMap.containsKey(caseRec.Id)){
                Id compalintId = caseComplaintMap.get(caseRec.Id);
                if(!casePdfWrapperMap.containsKey(compalintId)){
                    List<List<LPI_PDFSectionWrapper.DataWrapper>> tempList = new List<List<LPI_PDFSectionWrapper.DataWrapper>>();
                    casePdfWrapperMap.put(compalintId, tempList);
                }
                casePdfWrapperMap.get(compalintId).add(dataList);
            }
        }       
        fields = 'Id , RegulatoryCode.Name , RegulatoryCode.Regulatory_Code_Description__c ,status, Action__c ,Terms_Of_Discipline__c,'+
                 'Start_Date__c,DateResolved,Acceptance_Date__c , DaysOpen , Case__c ';
        whereClause = 'Case__c IN '+LPI_ServiceUtility.getStringValuesBySet(caseIdSet);
        for(RegulatoryCodeViolation codeViolation :LPI_RegulatoryCodeViolationDAO.getRegulatoryCodeViolationListByDynamicQuery(fields,whereClause,null,null,null)){
                List<LPI_PDFSectionWrapper.DataWrapper> dataList = new List<LPI_PDFSectionWrapper.DataWrapper>();
                if(codeViolation.Action__c!=null){
                    dataList.add(
                        new LPI_PDFSectionWrapper.DataWrapper(
                            'Action',
                            codeViolation.Action__c
                        )
                    );
                }else{
                    dataList.add(
                        new LPI_PDFSectionWrapper.DataWrapper(
                            'Action',
                            '-'
                        )
                    );
                }
                if(codeViolation.status!=null){
                    dataList.add(
                        new LPI_PDFSectionWrapper.DataWrapper(
                            'Diciplinary Action Status',
                            codeViolation.status
                        )
                    );
                }else{
                    dataList.add(
                        new LPI_PDFSectionWrapper.DataWrapper(
                            'Diciplinary Action Status',
                            '-'
                        )
                    );
                }
                if(codeViolation.Start_Date__c!=null){
                    DateTime assignDate = codeViolation.Start_Date__c;
                    dataList.add(
                        new LPI_PDFSectionWrapper.DataWrapper(
                            'Start Date',
                            assignDate.format('MM/dd/YYYY')
                        )
                    );
                }else{
                    dataList.add(
                        new LPI_PDFSectionWrapper.DataWrapper(
                            'Start Date',
                            '-'
                        )
                    );
                }
                if(codeViolation.Acceptance_Date__c!=null){
                    DateTime assignDate = codeViolation.Acceptance_Date__c;
                    dataList.add(
                        new LPI_PDFSectionWrapper.DataWrapper(
                            'Acceptance Date',
                            assignDate.format('MM/dd/YYYY')
                        )
                    );
                }else{
                    dataList.add(
                        new LPI_PDFSectionWrapper.DataWrapper(
                            'Acceptance Date',
                            '-'
                        )
                    );
                }
                if(codeViolation.DateResolved!=null){
                    DateTime assignDate = codeViolation.DateResolved;
                    dataList.add(
                        new LPI_PDFSectionWrapper.DataWrapper(
                            'Date Resolved',
                            assignDate.format('MM/dd/YYYY')
                        )
                    );
                }else{
                    dataList.add(
                        new LPI_PDFSectionWrapper.DataWrapper(
                            'Date Resolved',
                            '-'
                        )
                    );
                }
                if(codeViolation.Terms_Of_Discipline__c!=null){
                    dataList.add(
                        new LPI_PDFSectionWrapper.DataWrapper(
                            'Terms Of Discipline',
                            codeViolation.Terms_Of_Discipline__c
                        )
                    );
                }else{
                    dataList.add(
                        new LPI_PDFSectionWrapper.DataWrapper(
                            'Terms Of Discipline',
                            '-'
                        )
                    );
                }
                if(codeViolation.RegulatoryCode.Name!=null){
                    dataList.add(
                        new LPI_PDFSectionWrapper.DataWrapper(
                            'Regulatory Code Name',
                            codeViolation.RegulatoryCode.Name
                        )
                    );
                }else{
                    dataList.add(
                        new LPI_PDFSectionWrapper.DataWrapper(
                            'Regulatory Code Name',
                            '-'
                        )
                    );
                }
                if(codeViolation.RegulatoryCode.Regulatory_Code_Description__c!=null){
                    dataList.add(
                        new LPI_PDFSectionWrapper.DataWrapper(
                            'Regulatory Code Description',
                            codeViolation.RegulatoryCode.Regulatory_Code_Description__c
                        )
                    );
                }else{
                    dataList.add(
                        new LPI_PDFSectionWrapper.DataWrapper(
                            'Regulatory Code Description',
                            '-'
                        )
                    );
                }
                if(caseComplaintMap!=null && caseComplaintMap.containsKey(codeViolation.Case__c)){
                    Id compalintId = caseComplaintMap.get(codeViolation.Case__c);
                    if(!regCodeMap.containsKey(compalintId)){
                        List<List<LPI_PDFSectionWrapper.DataWrapper>> tempList = new List<List<LPI_PDFSectionWrapper.DataWrapper>>();
                        regCodeMap.put(compalintId, tempList );
                    }
                    regCodeMap.get(compalintId).add(dataList);
                }
            }
        }
        
            for(Id complaintId : idPdfWrapperMap.keySet()){
                complaintSection.addSubSection(new LPI_PDFSectionWrapper('Complaint #'+counter ,2, idPdfWrapperMap.get(complaintId)));
                Integer taskcounter =1;
                if(taskPdfWrapperMap.containsKey(complaintId)){
                    for(List<LPI_PDFSectionWrapper.DataWrapper> wrapperList : taskPdfWrapperMap.get(complaintId)){
                        complaintSection.addSubSection(new LPI_PDFSectionWrapper('Task #'+taskcounter ,2, wrapperList));
                        taskcounter+=1;
                    }
                }
                Integer caseCounter =1;
                if(casePdfWrapperMap.containsKey(complaintId)){
                    for(List<LPI_PDFSectionWrapper.DataWrapper> wrapperList : casePdfWrapperMap.get(complaintId)){
                        complaintSection.addSubSection(new LPI_PDFSectionWrapper('Case #'+caseCounter ,2, wrapperList));
                        caseCounter+=1;
                    }
                }
                Integer regCodeCounter =1;
                if(regCodeMap.containsKey(complaintId)){
                    for(List<LPI_PDFSectionWrapper.DataWrapper> wrapperList : regCodeMap.get(complaintId)){
                        complaintSection.addSubSection(new LPI_PDFSectionWrapper('Violation Action #'+regCodeCounter ,2, wrapperList));
                        regCodeCounter+=1;
                    }
                }
            counter+=1;
            }
            if(counter==1){
                return;
            }
            sectionList.add(complaintSection);
    }
}