/**
 * @author                      : Rahul Ameta
 * @since                       : march 14,2023
 * @description                 : This is a controller class for LPI_PDFTemplatePage
 *-------------------------------------------------------------------------------------------------------
 * Version      Date                Author                  Details
 *    1         14 Mar, 2023        Rahul Ameta             Initial Developement
 *    2         11 May, 2023        Ambati Sukanya          Added board specific method call &
                                                            added a String in prepareSectionWrapperListToShow()                                 
 * -------------------------------------------------------------------------------------------------------
 */
public with sharing class LPI_ApplicationPDFController {
    public List<LPI_PDFSectionWrapper> pdfSectionWrapper { get; private set; }
    public String parName { get; private set; }
    public String applicationName { get; private set; }
    public String businessLicenseNumber { get; private set; }
    private PreliminaryApplicationRef parRecord;
    private Account accRecord;

    /**
     * @author                      : Rahul Ameta
     * @since                       : march 14,2023
     * @description                 : Constructor for the class
     * @return                      :
     * @last modified by            : Uzma Md
     * @last modified date          :
     * @modified details            :
     */
    public LPI_ApplicationPDFController() {
        try {
            Id targetId = ApexPages.currentPage().getParameters().get('targetId');
            if (String.isNotBlank(targetId)) {
                String objectType = String.valueOf(targetId.getSObjectType());
                String parId = getPARRecordId(targetId, objectType);
                dataSetupForApplication(parId);
                prepareSectionWrapperListToShow();
                string fileName = 'ApplicationReview ' + this.applicationName;
                Apexpages.currentPage()
                    .getHeaders()
                    .put('content-disposition', 'attachment; filename=' + fileName + '.pdf');
            }
        } catch (Exception e) {
            LPI_ExceptionManager.logException('LPI_ApplicationPDFController', '', e);
            throw new LPI_Exception(e.getMessage() + e.getLineNumber());
        }
    }

    /**
     * @author                      : Rahul Ameta
     * @since                       : march 24,2023
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
        String fieldToQuery = 'Id, Name, SavedApplicationRefId';
        String whereClause = 'Id = \'' + targetId + '\'';
        //Updated by Vamshi - I-260099 Schools doesn't have access to applicants(Stundent) application while downloading PDF after payment
        LPI_IndividualApplicationDAO.LPI_DAO_IndividualApptWithoutSecurity withoutSharingIa = new LPI_IndividualApplicationDAO.LPI_DAO_IndividualApptWithoutSecurity();
        if (objectType == 'IndividualApplication') {
            List<IndividualApplication> iaList = withoutSharingIa.getIndividualApplicationByDymanicQuery(
                fieldToQuery,
                whereClause,
                null,
                null,
                null
            );
            if (!iaList.isEmpty()) {
                parId = iaList[0].SavedApplicationRefId;
                //updated by Vamshi Kumar - S-57994
                applicationName = iaList[0].Name;
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
                //updated by Vamshi Kumar - S-57994
                applicationName = blaList[0].Name;
            }
        }
        return parId;
    }

    /**
     * @author                      : Rahul Ameta
     * @since                       : march 14,2023
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

        //Get Par Data
        if (parId != null) {
            fieldToQuery =
                'Id,Name,FirstName__c,MiddleName__c,MaidenName__c,LastName__c,Contact__c,Regulatory_Authorization_Type__c,' +
                'Other_Names__c,BusinessAccountNameId,Tax_Compliance__c,License_Questions__c,Business_License__r.PeriodStart,' +
                'Info_About_Military_Related_Services__c,Served_In_US_Armed_Force__c,Type__c,Amendment_Type__c,Currently_Holding_Active_License_Number__c,' +
                'Regulatory_Authorization_Type__r.Name,Regulatory_Authorization_Type__r.IssuingDepartment.Name,Business_License__r.Status, ' +
                'Steps_Name__c,Require_the_board_to_include_School__c, ' +
                'Choose_the_Certification_Delivery_option__c,Certification_Email__c,' +
                'Fax_Number__c,License_Questions_Step_API_Name__c,Audit_Escrow_or_Trust_Account_Questions__c,' +
                'Consent_for_Primary_Contact_Address__c,' +
                'Method_of_Licensure__c,' +
                'Jurisprudence_Examination_Step_API_Name__c,Board_Name__c,' +
                'Jurisprudence_Examination__c,Business_License__r.Name,Business_License__r.Legacy_License_Number__c,Business_License__c,BusinessAccountName.How_are_you_associated_to_this_entity__c,' +
                'ApplicationType,How_are_you_associated_to_this_entity__c,' +
                'Contact__r.Id,Primary_Contact_Address__c,License_Address__c,' +
                'Publicly_Displayed_Address__c,Business_License__r.PeriodEnd, Is_Supervisor_User__c,' +
                'Attestation_Step_API_Name__c,Attestation_Data__c,' +
                'Person_Incharge_Relation_Id__c,Controlled_Substance_Checkbox__c,Transaction_Suitability_Questions__c,' +
                'Street_Address__c,Zip_Code__c, Do_you_maintain_Trust_or_Joint_Account__c,Have_you_received_PG_training_in_US_CA__c,BusinessAccountName.Name,Applicant_Signature__c,' +
                'Supervisor_ACR_Id__c';
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
                if (parRecord[0].Business_License__c != null) {
                    this.businessLicenseNumber = String.isNotBlank(
                            parRecord[0].Business_License__r.Legacy_License_Number__c
                        )
                        ? 'License Number : ' + parRecord[0].Business_License__r.Legacy_License_Number__c
                        : 'License Number : ' + parRecord[0].Business_License__r.Name;
                }
                accountId = parRecord[0].BusinessAccountNameId;
            }
        }

        //Get Account Data
        if (accountId != null) {
            fieldToQuery =
                'Id,Suffix,PersonEmail,FirstName,LastName,MiddleName,Social_Security_Number__c,Date_of_Birth__c,Age__c,Gender__c,Place_of_Birth__c,' +
                'Phone,PersonHomePhone,Fax,Identity_Number__c,Race__c, PersonOtherPhone ,' +
                'Language__c,Citizenship__c,Nationality__c,Other_Nationality__c,' +
                'Other_Language__c,Other_Citizenship__c,Other_Race__c,Other_Names__c,' +
                'Proof_of_work_permit_in_United_States__c, ' +
                'Proof_of_Citizenship__c' ;
                /*'US_Permanent_Resident_Card_Number__c, Passport_Number__c, SEVIS_ID__c, USCIS_Number__c, Naturalization_Number__c, VISA_Number__c,' +
                'I_94_Number__c,Citizenship_Number__c, H1B_Visa_Number__c, Passport_Country__c'*/
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
     * @author                      : Rahul Ameta
     * @since                       : march 16,2023
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

        Set<String> appFlowSteps;
        if (this.parRecord != null && this.parRecord.Steps_Name__c != null) {
            String stepNameConfigs;
            if (this.parRecord.Regulatory_Authorization_Type__r.Name == 'Preneed Agent') {
                stepNameConfigs = 'Registration;' + this.parRecord.Steps_Name__c;
            } else if(this.parRecord.Regulatory_Authorization_Type__r.Name == 'Educator License'){
                stepNameConfigs = this.parRecord.Steps_Name__c;
            } else {
                stepNameConfigs = 'License;' + this.parRecord.Steps_Name__c;
            }
            appFlowSteps = new Set<String>(stepNameConfigs.split(';'));
        }
        System.debug('appFlowSteps data'+appFlowSteps);

        //Get all the steps one by one
        if (appFlowSteps != null && !appFlowSteps.isEmpty()) {
            List<LPI_PDFSectionWrapper> sectionList = new List<LPI_PDFSectionWrapper>();
            String issuingDeptName = this.parRecord.Regulatory_Authorization_Type__r != null &&
                this.parRecord.Regulatory_Authorization_Type__r.IssuingDepartment != null
                ? this.parRecord.Regulatory_Authorization_Type__r.IssuingDepartment.Name
                : null;

            // FCNB apps store step data in PAR JSON with Custom Label step tokens
            if (LPI_FCNBApplicationDataUtility.isFCNBApplication(this.parRecord)) {
                this.pdfSectionWrapper = LPI_FCNBApplicationDataUtility.getSectionList(
                    this.parRecord,
                    this.accRecord,
                    appFlowSteps
                );
                return;
            }

            //Get All Common Section across the boards
            sectionList.addAll(
                LPI_ApplicationDataUtility.getSectionList(this.parRecord, this.accRecord, appFlowSteps)
            );

            //start switch on issuingDeptName
            switch on issuingDeptName {                
                //Get Healing Art Baord Specific Section
                when 'Healing Arts' {
                    sectionList.addAll(
                        LPI_HAApplicationDataUtility.getSectionList(this.parRecord, this.accRecord, appFlowSteps)
                    );
                }
                //Get Embalmers & Funeral Directors Baord Specific Section
                when 'Embalmers & Funeral Directors' {
                    sectionList.addAll(
                        LPI_EFDApplicationDataUtility.getSectionList(this.parRecord, this.accRecord, appFlowSteps)
                    );
                }
            }
            // Add Other boards condition here with the respective Utility Classes
            //Reorder All the section as per configuration
            reorderSectionToShow(sectionList);
        }
    }

    /**
     * @author                      : Rahul Ameta
     * @since                       : march 17,2023
     * @description                 : This method will reorder the section list as per the config on par
     * @param sectionList           : List<LPI_PDFSectionWrapper>
     * @return                      : Void
     * @last modified by            : Uzma Md
     * @last modified date          :
     * @modified details            :
     */
    private void reorderSectionToShow(List<LPI_PDFSectionWrapper> sectionList) {
        this.pdfSectionWrapper = new List<LPI_PDFSectionWrapper>();
        Map<String, LPI_PDFSectionWrapper> sectionNameToSectionMap = new Map<String, LPI_PDFSectionWrapper>();
        //Create a Map with the name of step
        for (LPI_PDFSectionWrapper wrap : sectionList) {
            if (wrap != null && wrap.sectionName != null) {
                sectionNameToSectionMap.put(wrap.sectionName, wrap);
            }
        }

        //Reorder the section as per the Configuration
        String stepNameConfigs;
        
            stepNameConfigs = 'License;' + this.parRecord.Steps_Name__c;
        
        for (String sectionName : stepNameConfigs.split(';')) {
            if (sectionNameToSectionMap.containsKey(sectionName)) {
                this.pdfSectionWrapper.add(sectionNameToSectionMap.get(sectionName));
            }
        }
    }
}