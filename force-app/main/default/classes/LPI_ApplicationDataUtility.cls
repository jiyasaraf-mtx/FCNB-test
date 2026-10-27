/**
 * @author                      : MTX Group Inc
 * @since                       : march 18,2023
 * @description                 : This is a generic data utility class for PDF
 */
public with sharing class LPI_ApplicationDataUtility {
	// *********************************************************************************************************** ALL CONSTANTS **************************************************************************************************
	public final static String LICENSE_STEP = 'License';
	public final static String INSTRUCTIONS_STEP = 'Instructions';
	public final static String PERSONAL_INFO_STEP = 'Personal Information';
	public final static String MILITARY_QUESTIONS_STEP = 'Military Questions';
	public final static String LICENSE_QUESTIONS_STEP = 'License Questions';
	public final static String DOCUMENTS_STEP = 'Documents';
	public final static String REQUEST_DETAILS_STEP = 'Request Details';
	public final static String BUSINESS_INFORMATION_STEP = 'Business Information';
	public final static String PERSON_IN_CHARGE_INFORMATION_STEP = 'Person In Charge Information';
	public final static String REAL_ESTATE_BROKERAGE_SOLE_PROPRIETORSHIP_AMENDMENT_TYPE = 'Closing of a Real Estate Brokerage/Sole Proprietorship';
	public final static String AUDIT_ESCROW_TRUST_ACCOUNT_STEP = 'Audit Escrow or Trust Account';
	public final static String AUDIT_ESCROW_TRUST_ACCOUNT_COND_STEP = 'Audit Escrow or Trust Account Contd.';
	public final static String TAX_COMPLIANCE_STEP = 'Tax Compliance';
	public final static String OWNERSHIP_INFORMATION_STEP = 'Ownership Information';
	public final static String OFFICERS_MEMBERS_PARTNERS_STEP = 'Officers/Members/Partners'; 
	public final static String CORPORATE_OFFICER_INFO_STEP = 'Corporate Officers';
	public final static String ADMINISTRATOR_INFORMATION_STEP = 'Administrator Information';
	public final static String EMPLOYMENT_HISTORY_STEP = 'Employment History';
	public final static String EDUCATION_HISTORY_STEP = 'Education History';
	public final static String EMPLOYEE_INFO_STEP = 'Employee Information';
	public final static String PRM_SUPERVISOR_STEP = 'Supervisor/Collaborating Professional Information';
	public final static String SUPERVISOR_INFO_STEP = 'Supervisor Information';
	public final static String LICENSURE_HISTORY_STEP = 'Licensure History';
	public final static String AMENDMENT_DETAILS_STEP = 'Amendment Details';
	public final static String BUSINESS_TAX_COMPLIANCE_STEP = 'Business Tax Compliance';
	public final static String CHANGE_OF_SUPERVISOR_OR_SITE_AMENDMENT_TYPE = 'Change of Supervisor and/or Site';
	public final static String ATTESTATION_STEP = 'Attestation';
	private final static String LICENSE_DETAILS_STEP = 'License Details';
	public final static String AUTHORIZED_CONTACTS = 'Authorized Contacts';
	private final static String PERSON_INCHARGE = 'Designated Incharge';
	private final static String REAL_ESTATE_BOARD = 'Real Estate';
	private static final String APEP_BOARD_NAME = 'Architects, Engineers, Land Surveryors, and Landscape Architects';
	private static final String APEP_BOARD_BUSINESS_REINSTATEMENT = 'Re-authorization';
	private static final String APEP_BOARD_INDIVIDUAL_REINSTATEMENT = 'Re-licensure';
	private static final String TRANSACTION_SUITABILITY_QUESTION = 'Transaction Suitability Question';
	// private static final String TRANSACTION_SUITABILITY_QUESTION = 'Personal Information';
	private static final String DEGREE_INFORMATION = 'Degree Information';
	private static final String WORK_HISTORY = 'Work History';

	public final static Set<String> ATHLETICS_CONTESTANT_SET = new Set<String>{
		'Boxing Contestant',
		'Martial Arts Amateur Contestant',
		'Martial Arts Contestant'
	};
	public final static Set<String> PI_PFI_AGENCY_BRANCH_SET = new Set<String>{
		'Private Fire Investigator Agency',
		'Private Investigator Agency'
	};
	public final static String AMENDMENT_TYPE = 'Amendment';
	public final static String RESIDENCE = 'Residence';
	public final static String MAILING = 'Mailing';
	public final static String CHANGE_IN_SPONSERSHIP = 'Change in Sponsorship';
	public final static String DRUG_DISTRIBUTOR_REG = 'Drug Distributor Registrant';
	public final static String FQHC_REGISTRATION = 'FQHC Registration';
	public final static String NFP_CORPORATION_PERMIT = 'NFP Corporation Permit';
	private final static Set<String> PROV_LP_MFT_LICENSE_SET = new Set<String>{
		'Provisional License Professional Counselor',
		'Provisional Marital and Family Therapist'
	};
	public final static String PARTYPE_NEW = 'New';
	public final static String CHANGE_OF_OWNERSHIP = 'Change of Ownership';
	private final static String ELECTRICAL_CONTRACTORS_BOARD = 'Electrical Contractors';
	private final static String APPLICATION_TYPE_RENEWAL = 'Renewal';
	private final static String APPRENTICESHIP = 'Apprenticeship';
	public final static List<String> ALL_ADDRESS_LIST = new List<String>{
		'Business Address',
		'Branch',
		'Secondary Business Address',
		'Local Address',
		'Other'
	};
	public final static Map<String, String> addressApiNameMap = new Map<String, string>{
		'Residence' => 'Residence Address',
		'Mailing' => 'Mailing Address',
		'Business Address' => 'Business Address',
		'Branch' => 'Branch Address',
		'Secondary Business Address' => 'Secondary Business Address',
		'Local Address' => 'Local Address',
		'Other' => 'Other Address',
		'Warehouse Address' => 'Warehouse Address'
	};
	public final static Map<String, String> addressApiNameMapForConsent = new Map<String, string>{
		'Residence' => 'residence address',
		'Mailing' => 'mailing address',
		'Business Address' => 'business address',
		'Branch' => 'branch address',
		'Secondary Business Address' => 'secondary business address',
		'Local Address' => 'local address',
		'Other' => 'other address',
		'Warehouse Address' => 'warehouse address'
	};
	private static final String UNITED_STATES = 'UNITED STATES';

	private static final String STUDENT_VISA = 'F-1 Student Visa';

	private static final String RESIDENT_CARD = 'US Permanent Resident Card';
	private static final String RESIDENT_CARD_EXPIRED = 'Permanent Resident Card Expired - Extension Granted';

	private static final Set<String> US_RESIDENTS_SET = new Set<String>{ RESIDENT_CARD, RESIDENT_CARD_EXPIRED };
	private final static Set<String> REQUEST_DET_ADDITIONAL_QUE_APPLICABLE_BOARDS = new Set<String>{
		'Social Workers',
		'Accountancy',
		'Cosmetology & Barber Examiners',
		'Chiropractic Examiners',
		'Professional Counselors',
		'Massage Therapists',
		'Marital & Family Therapists',
		'Acupuncture'
	};
	private final static String BOARD_NAME_RS_APPRAISERS = 'Real Estate Appraisers';
	private static String COUNTRY_VALUE = '';
	public final static List<String> INDIVIDUAL_LICENSE_TYPE_OF_NURSING = new List<String>{
		'Registered Nurse',
		'TEMP-Registered Nurse',
		'Licensed Practical Nurse',
		'TEMP-Licensed Practical Nurse',
		'Advanced Practice Registered Nurse'
	};
	private static final String EMBALMERS_AND_FUNERAL_DIRECTORS_BOARD_NAME = 'Embalmers & Funeral Directors';
	private static final Set<String> MAILING_ADDRESS_SAME_AS_RESIDENCE_BOARD_SET = new Set<String>{
		'Dietitians',
		'Interior Design',
		'Hearing Instrument Specialist\'s',
		'Veterinary'
	};
	private final static Set<String> HIDE_MO_REGISTRATION_NUMBER = new Set<String>{
		'NFP Corporation Permit',
		'FQHC Registration'
	};
	
	private static final Set<String> MILITARY_QUESTION_SET = new Set<String>{
		'Certificate of Authority - Corporation',
		'Certificate of Authority - LLC'
	};
	
	private static final String AMEND_PROFESSIONAL_CORPORATION_NAME_APPROVAL = 'Apply for Professional Corporation Name Approval';
	private static final String AMEND_APPLY_FOR_PROFESSIONAL_CORPORATION = 'Apply for Professional Corporation';
	private static final String AMENDMENT_INFORMATION = 'Amendment Information';
	//***********************************************************************************************************************************************************************************************************************

	/**
	 * @description
	 * @author MTX Group Inc | 03-19-2023
	 * @param parRecord :
	 * @param accRecord :
	 * @return LPI_PDFSectionWrapper
	 **/
	public static List<LPI_PDFSectionWrapper> getSectionList(
		PreliminaryApplicationRef parRecord,
		Account accRecord,
		Set<String> appFlowSteps
	) {
		List<LPI_PDFSectionWrapper> sectionList = new List<LPI_PDFSectionWrapper>();
		try { 

			//Applicant Information;Organization Information;Program Information;Staff Information; Documents;Payment

			sectionList.add(getLicenseSection(parRecord));
			if (appFlowSteps.contains(PERSONAL_INFO_STEP)) {
				LPI_PDFSectionWrapper personalInfoSection = getPersonalInformationSectionDPI(parRecord, accRecord);
				// LPI_PDFSectionWrapper personalInfoSection = getPersonalInformationSection(parRecord, accRecord);
				sectionList.add(personalInfoSection);
			}
			if (appFlowSteps.contains('Applicant Information')) {
				LPI_PDFSectionWrapper applicantInfoSection = getApplicantlInformationSection(parRecord, accRecord);
				sectionList.add(applicantInfoSection);
			}
			if (appFlowSteps.contains('Organization Information')) {
				LPI_PDFSectionWrapper applicantInfoSection = getOrganisationlInformationSection(parRecord, accRecord);
				sectionList.add(applicantInfoSection);
			}
			if (appFlowSteps.contains('Program Information')) {
				LPI_PDFSectionWrapper applicantInfoSection = getProgramlInformationSection(parRecord, accRecord);
				sectionList.add(applicantInfoSection);
			}
			if (appFlowSteps.contains('Staff Information')) {
				LPI_PDFSectionWrapper applicantInfoSection = getStafflInformationSection(parRecord, accRecord);
				sectionList.add(applicantInfoSection);
			}
			if (appFlowSteps.contains(MILITARY_QUESTIONS_STEP)) {
				sectionList.add(getMilitaryQuestionsSection(parRecord));
			}
			if (appFlowSteps.contains(LICENSE_QUESTIONS_STEP)) {
				sectionList.add(getLicensedQuestionSection(parRecord));
			}
			if (appFlowSteps.contains(DOCUMENTS_STEP)) {
				sectionList.add(getDocumentSection(parRecord.Id));
			}
			if (appFlowSteps.contains(REQUEST_DETAILS_STEP)) {
				sectionList.add(getRequestDetailsSection(parRecord));
			}
			if (appFlowSteps.contains(BUSINESS_INFORMATION_STEP)) {
				sectionList.add(getBusinessInformation(parRecord));
			}
			if (appFlowSteps.contains(PERSON_IN_CHARGE_INFORMATION_STEP)) {
				sectionList.add(getPersonInChargeInformationSection(parRecord));
			}
			if (appFlowSteps.contains(AUDIT_ESCROW_TRUST_ACCOUNT_STEP)) {
				sectionList.add(getAuditEscrowTrustAccount(parRecord));
			}
			if (appFlowSteps.contains(AUDIT_ESCROW_TRUST_ACCOUNT_COND_STEP)) {
				LPI_PDFSectionWrapper bankAccountSection = new LPI_PDFSectionWrapper(
					AUDIT_ESCROW_TRUST_ACCOUNT_COND_STEP,
					3,
					null
				);
				bankAccountSection.addSubSection(getBankAccountDetailsSection(parRecord.Id));
				bankAccountSection.addSubSection(getChangeInBankAccountSection(parRecord.Id));
				bankAccountSection.addSubSection(getAccountClosedSection(parRecord.Id));
				sectionList.add(bankAccountSection);
			}
			if (appFlowSteps.contains(TAX_COMPLIANCE_STEP)) {
				sectionList.add(getTaxComplianceSection(parRecord));
			}
			if (
				appFlowSteps.contains(OWNERSHIP_INFORMATION_STEP) ||
				appFlowSteps.contains(OFFICERS_MEMBERS_PARTNERS_STEP)
			) {
				sectionList.add(getOwnershipInformation(parRecord));
			}
			if (appFlowSteps.contains(CORPORATE_OFFICER_INFO_STEP)) {
				sectionList.add(getCorporateOfficerInfo(parRecord));
			}
			if (appFlowSteps.contains(ADMINISTRATOR_INFORMATION_STEP)) {
				sectionList.add(getAdministratorInformation(parRecord.Id));
			}
		
			if (appFlowSteps.contains(EMPLOYMENT_HISTORY_STEP)) {
				sectionList.add(getEmploymentHistory(parRecord));
			}
			if (appFlowSteps.contains(EDUCATION_HISTORY_STEP) ) {
				sectionList.add(getEducationHistoryDetails(parRecord));
			}
			if (appFlowSteps.contains(EMPLOYEE_INFO_STEP)) {
				sectionList.add(getEmployeeInformation(parRecord));
			}
			if (
				appFlowSteps.contains(PRM_SUPERVISOR_STEP) &&
				parRecord.Regulatory_Authorization_Type__r.Name != APPRENTICESHIP
			) {
				Map<String, Object> inputMap = new Map<String, Object>();
				inputMap.put('parId', String.valueOf(parRecord.Id));
				sectionList.add(getSupervisorInformation(parRecord, inputMap, PRM_SUPERVISOR_STEP));
			}
			if (appFlowSteps.contains(LICENSURE_HISTORY_STEP)) {
				
					sectionList.add(getLicensureHistory(parRecord));
				
			}
			if (
				appFlowSteps.contains(SUPERVISOR_INFO_STEP) &&
				parRecord.Regulatory_Authorization_Type__r.Name != APPRENTICESHIP
			) {
				Map<String, Object> inputMap = new Map<String, Object>();
				inputMap.put('parId', String.valueOf(parRecord.Id));
				inputMap.put('readOnly', 'approvalSupervisor');
				sectionList.add(getSupervisorInformation(parRecord, inputMap, SUPERVISOR_INFO_STEP));
			}
			if (appFlowSteps.contains(AMENDMENT_DETAILS_STEP)) {
				sectionList.add(getAmendmentDetails(parRecord));
			}
			if (appFlowSteps.contains(BUSINESS_TAX_COMPLIANCE_STEP)) {
				sectionList.add(getBusinessTaxCompliance(parRecord.Id));
			}
			
			if (appFlowSteps.contains(ATTESTATION_STEP)) {
				sectionList.add(getAttestationStep(parRecord));
			}
			
			if (appFlowSteps.contains(LICENSE_DETAILS_STEP)) {
				sectionList.add(getLicenseDetailsSection(parRecord));
			}
			if (appFlowSteps.contains(AUTHORIZED_CONTACTS)) {
				sectionList.add(getHospitalCoordinatorsInfo(parRecord.Id));
			}
			if (appFlowSteps.contains(AMENDMENT_INFORMATION)) {
				sectionList.add(
				 new LPI_PDFSectionWrapper(AMENDMENT_INFORMATION, 3, getLawfulPresenceDetails(new List<LPI_PDFSectionWrapper.DataWrapper>(), accRecord)));
			}
			if(appFlowSteps.contains(TRANSACTION_SUITABILITY_QUESTION)){
				sectionList.add(getTSQuestionSection(parRecord));
			}
			if(appFlowSteps.contains(DEGREE_INFORMATION)){
				sectionList.add(getDegreeInformationSection(parRecord));
			}
			if(appFlowSteps.contains(WORK_HISTORY)){
				sectionList.add(getWorkHistorySection(parRecord));
			}

			if(appFlowSteps.contains('Payment')){
			sectionList.add(getPaymentSection(parRecord));
			}
		} catch (Exception e) {
			LPI_ExceptionManager.logException('LPI_ApplicationDataUtility', 'getSectionList', e);
			throw new LPI_Exception(e.getMessage() + e.getLineNumber());
		}
		return sectionList;
	}   
        
	public static LPI_PDFSectionWrapper getPaymentSection(PreliminaryApplicationRef parRecord){
		List<LPI_PDFSectionWrapper.DataWrapper> dataList = new List<LPI_PDFSectionWrapper.DataWrapper>();
		dataList.add(new LPI_PDFSectionWrapper.DataWrapper('Payment Status','Success'));
		dataList.add(new LPI_PDFSectionWrapper.DataWrapper('Transaction Id','TID3872XG9 '));
		LPI_PDFSectionWrapper personalInfoSection = new LPI_PDFSectionWrapper('Payment', 6, dataList);
		return personalInfoSection;
	}

	/**
	 * @description
	 * @author MTX Group Inc | 03-19-2023
	 * @param parRecord :
	 * @param accRecord :
	 * @return LPI_PDFSectionWrapper
	 **/
	public static LPI_PDFSectionWrapper getLicenseSection(PreliminaryApplicationRef parRecord) {
		List<LPI_PDFSectionWrapper.DataWrapper> dataList = new List<LPI_PDFSectionWrapper.DataWrapper>();
		if (parRecord.Regulatory_Authorization_Type__r.IssuingDepartment.Name != 'Real Estate') {
			dataList.add(
				new LPI_PDFSectionWrapper.DataWrapper(
					'Board Name',
					parRecord.Regulatory_Authorization_Type__r.IssuingDepartment.Name
				)
			);
		} else if (parRecord.Regulatory_Authorization_Type__r.IssuingDepartment.Name == 'Real Estate') {
			dataList.add(
				new LPI_PDFSectionWrapper.DataWrapper(
					'State Commission Name',
					parRecord.Regulatory_Authorization_Type__r.IssuingDepartment.Name
				)
			);
		}
		dataList.add(
			new LPI_PDFSectionWrapper.DataWrapper('License Type', parRecord.Regulatory_Authorization_Type__r.Name)
		);
		PreliminaryApplicationRef parRec = LPI_PreliminaryApplicationRefDAO.getPreliminaryApplicationRefByDymanicQuery(
			'toLabel(Amendment_Type__c),Regulatory_Authorization_Type__r.Authorisation_Type__c,Type__c',
			'Id = \'' + parRecord.Id + '\'',
			null,
			null,
			null
		)[0];

		String subTypeToShow = LPI_ServiceUtility.getSubtypeLabelToShow(
			parRecord.Regulatory_Authorization_Type__r.IssuingDepartment.Name,
			parRecord.Regulatory_Authorization_Type__r.Name,
			parRec.Amendment_Type__c,
			parRec.Type__c
		);
		if (
			parRecord.Regulatory_Authorization_Type__r.IssuingDepartment.Name == APEP_BOARD_NAME &&
			(parRecord.Type__c == APEP_BOARD_INDIVIDUAL_REINSTATEMENT ||
			parRecord.Type__c == APEP_BOARD_BUSINESS_REINSTATEMENT)
		) {
			dataList.add(new LPI_PDFSectionWrapper.DataWrapper('Application Type', parRecord.Type__c));
		} else {
			dataList.add(new LPI_PDFSectionWrapper.DataWrapper('Application Sub Type', subTypeToShow));
		}
		LPI_PDFSectionWrapper newResult;
		newResult = new LPI_PDFSectionWrapper(LICENSE_STEP, 3, dataList);
		return newResult;
	}

	public static LPI_PDFSectionWrapper getPersonalInformationSectionDPI(PreliminaryApplicationRef parRecord, Account accRecord){
		List<LPI_PDFSectionWrapper.DataWrapper> dataList = new List<LPI_PDFSectionWrapper.DataWrapper>();
		dataList.add(new LPI_PDFSectionWrapper.DataWrapper('First Name', accRecord.FirstName));
		dataList.add(new LPI_PDFSectionWrapper.DataWrapper('Middle Name', accRecord.MiddleName));
		dataList.add(new LPI_PDFSectionWrapper.DataWrapper('Last Name', accRecord.LastName));
		dataList.add(new LPI_PDFSectionWrapper.DataWrapper('Date of Birth', String.valueOf(accRecord.Date_of_Birth__c)));
		dataList.add(new LPI_PDFSectionWrapper.DataWrapper('Email', accRecord.PersonEmail));
		LPI_PDFSectionWrapper personalInfoSection = new LPI_PDFSectionWrapper(PERSONAL_INFO_STEP, 2, dataList);
		return personalInfoSection;
	}

	public static LPI_PDFSectionWrapper getApplicantlInformationSection(PreliminaryApplicationRef parRecord, Account accRecord){
		List<LPI_PDFSectionWrapper.DataWrapper> dataList = new List<LPI_PDFSectionWrapper.DataWrapper>();
		dataList.add(new LPI_PDFSectionWrapper.DataWrapper('First Name', accRecord.FirstName));
		dataList.add(new LPI_PDFSectionWrapper.DataWrapper('Middle Name', accRecord.MiddleName));
		dataList.add(new LPI_PDFSectionWrapper.DataWrapper('Last Name', accRecord.LastName));
		dataList.add(new LPI_PDFSectionWrapper.DataWrapper('Date of Birth', String.valueOf(accRecord.Date_of_Birth__c)));
		dataList.add(new LPI_PDFSectionWrapper.DataWrapper('Email', accRecord.PersonEmail));
		LPI_PDFSectionWrapper personalInfoSection = new LPI_PDFSectionWrapper('Applicant Information',2, dataList);
		return personalInfoSection;
	}

	public static LPI_PDFSectionWrapper getOrganisationlInformationSection(PreliminaryApplicationRef parRecord, Account accRecord){
		List<LPI_PDFSectionWrapper.DataWrapper> dataList = new List<LPI_PDFSectionWrapper.DataWrapper>();
		dataList.add(new LPI_PDFSectionWrapper.DataWrapper('Organisation Name','IBM'));
		dataList.add(new LPI_PDFSectionWrapper.DataWrapper('Organisation Address','IBM Canada Ltd. 3600 Steeles Avenue East Markham, Ontario L3R 9Z7'));
		LPI_PDFSectionWrapper personalInfoSection = new LPI_PDFSectionWrapper('Organization Information', 3, dataList);
		return personalInfoSection;
	}

	public static LPI_PDFSectionWrapper getProgramlInformationSection(PreliminaryApplicationRef parRecord, Account accRecord){
		List<LPI_PDFSectionWrapper.DataWrapper> dataList = new List<LPI_PDFSectionWrapper.DataWrapper>();
		dataList.add(new LPI_PDFSectionWrapper.DataWrapper('Program Code', 'ETP-7681'));
		dataList.add(new LPI_PDFSectionWrapper.DataWrapper('Program Name','Educational Trainng Program'));
		dataList.add(new LPI_PDFSectionWrapper.DataWrapper('Program Start Date', '2024-08-18'));
		dataList.add(new LPI_PDFSectionWrapper.DataWrapper('Program End Date', '2024-11-18'));
		LPI_PDFSectionWrapper personalInfoSection = new LPI_PDFSectionWrapper('Program Information', 4, dataList);
		return personalInfoSection;
	}

	public static LPI_PDFSectionWrapper getStafflInformationSection(PreliminaryApplicationRef parRecord, Account accRecord){
		List<LPI_PDFSectionWrapper.DataWrapper> dataList = new List<LPI_PDFSectionWrapper.DataWrapper>();
		dataList.add(new LPI_PDFSectionWrapper.DataWrapper('First Name','Mark'));
		dataList.add(new LPI_PDFSectionWrapper.DataWrapper('Middle Name', 'H'));
		dataList.add(new LPI_PDFSectionWrapper.DataWrapper('Last Name', 'Green'));
		dataList.add(new LPI_PDFSectionWrapper.DataWrapper('Date of Birth','2094-04-07'));
		dataList.add(new LPI_PDFSectionWrapper.DataWrapper('Email', 'mark.green@em.com'));
		LPI_PDFSectionWrapper personalInfoSection = new LPI_PDFSectionWrapper('Staff Information', 5, dataList);
		return personalInfoSection;
	}

	public static LPI_PDFSectionWrapper getTSQuestionSection(PreliminaryApplicationRef parRecord){
		List<LPI_PDFSectionWrapper.DataWrapper> dataList = new List<LPI_PDFSectionWrapper.DataWrapper>();
		dataList.add(new LPI_PDFSectionWrapper.DataWrapper('Transaction Suitability Question', parRecord.Transaction_Suitability_Questions__c));
		
		LPI_PDFSectionWrapper tsSection = new LPI_PDFSectionWrapper(TRANSACTION_SUITABILITY_QUESTION, 1, dataList);
		return tsSection;
	}

	/**
	 * @author                      : MTX Group Inc
	 * @since                       : 03-19-2023
	 * @description                 : This method will give Personal Information Step Data
	 * @param parRecord             : PreliminaryApplicationRef
	 * @return                      : LPI_PDFSectionWrapper
	 * @last modified by            : Ayush Dev
	 * @last modified date          : 7th July, 2023
	 * @modified details            : added new mappings for lawful presence fields
	 */
	public static LPI_PDFSectionWrapper getPersonalInformationSection(
		PreliminaryApplicationRef parRecord,
		Account accRecord
	) {
		List<LPI_PDFSectionWrapper.DataWrapper> dataList = new List<LPI_PDFSectionWrapper.DataWrapper>();
		dataList.add(new LPI_PDFSectionWrapper.DataWrapper('First Name', parRecord.FirstName__c));
		dataList.add(new LPI_PDFSectionWrapper.DataWrapper('Middle Name', parRecord.MiddleName__c));
		dataList.add(new LPI_PDFSectionWrapper.DataWrapper('Last Name', parRecord.LastName__c));
		dataList.add(new LPI_PDFSectionWrapper.DataWrapper('Maiden Name', parRecord.MaidenName__c));
		dataList.add(new LPI_PDFSectionWrapper.DataWrapper('Suffix', accRecord.Suffix));

		LPI_PDFSectionWrapper personalInfoSection = new LPI_PDFSectionWrapper(PERSONAL_INFO_STEP, 3, dataList);
		dataList.clear();

		integer i = 1;
		Set<String> notAllowedApplication = new Set<String>{
			'Change of Name',
			'Change of Name and/or Residence Address',
			'Change of Residence Address'
		};
		List<Alias__c> aliasList = [
			SELECT Account__c, Alias_From_Date__c, Status__c, Alias_Thru_Date__c, Alias_Type__c, Id, Name
			FROM Alias__c
			WHERE Status__c = 'Active' AND Account__c = :accRecord.Id
			WITH SECURITY_ENFORCED
		];

		if (aliasList.size() > 0 && !notAllowedApplication.contains(parRecord.Type__c)) {
			LPI_PDFSectionWrapper aliasSubSection = new LPI_PDFSectionWrapper(
				'Include any alias names if you have ever been known by a different name',
				1,
				null
			);
			for (Alias__c aliasData : aliasList) {
				dataList.add(new LPI_PDFSectionWrapper.DataWrapper('Alias Type', aliasData.Alias_Type__c));
				dataList.add(new LPI_PDFSectionWrapper.DataWrapper('Alias Name', aliasData.Name));
				dataList.add(
					new LPI_PDFSectionWrapper.DataWrapper(
						'Alias From Date',
						Date.valueOf(aliasData.Alias_From_Date__c)?.format()
					)
				);
				dataList.add(
					new LPI_PDFSectionWrapper.DataWrapper(
						'Alias Thru Date',
						Date.valueOf(aliasData.Alias_Thru_Date__c)?.format()
					)
				);
				aliasSubSection.addSubSection(new LPI_PDFSectionWrapper('Alias ' + i, 2, dataList));
				dataList.clear();
				i++;
			}
			personalInfoSection.addSubSection(aliasSubSection);
		}
		dataList.add(new LPI_PDFSectionWrapper.DataWrapper('E-mail Address', accRecord.PersonEmail));
		dataList.add(
			new LPI_PDFSectionWrapper.DataWrapper('Social Security Number', accRecord.Social_Security_Number__c)
		);
		dataList.add(
			new LPI_PDFSectionWrapper.DataWrapper('Date of Birth', Date.valueOf(accRecord.Date_of_Birth__c)?.format())
		);
		dataList.add(new LPI_PDFSectionWrapper.DataWrapper('Age', String.valueOf(accRecord.Age__c)));
		if (parRecord.Regulatory_Authorization_Type__r.IssuingDepartment.Name == 'Nursing') {
			dataList.add(new LPI_PDFSectionWrapper.DataWrapper('Gender', String.valueOf(accRecord.Gender__c)));
			dataList.add(
				new LPI_PDFSectionWrapper.DataWrapper('Place of Birth', String.valueOf(accRecord.Place_of_Birth__c))
			);
		}

		dataList.add(new LPI_PDFSectionWrapper.DataWrapper('Cell Phone Number', accRecord.Phone));
		dataList.add(new LPI_PDFSectionWrapper.DataWrapper('Telephone/Home Phone Number', accRecord.PersonHomePhone));
		dataList.add(new LPI_PDFSectionWrapper.DataWrapper('Fax Number', accRecord.Fax));
		if (parRecord.Regulatory_Authorization_Type__r.IssuingDepartment.Name == 'Nursing') {
			dataList.add(new LPI_PDFSectionWrapper.DataWrapper('Language', accRecord.Language__c));
		}
		if (
			accRecord.Language__c == 'FOREIGN' &&
			parRecord.Regulatory_Authorization_Type__r.IssuingDepartment.Name == 'Nursing'
		) {
			dataList.add(new LPI_PDFSectionWrapper.DataWrapper('Foreign language', accRecord.Other_Language__c));
		}
		if (parRecord.Regulatory_Authorization_Type__r.IssuingDepartment.Name == 'Nursing') {
			dataList.add(new LPI_PDFSectionWrapper.DataWrapper('Ethnicity', accRecord.Race__c));
			if (accRecord.Race__c == 'OTHER') {
				dataList.add(
					new LPI_PDFSectionWrapper.DataWrapper(
						'Please Specify the Other Ethnicity',
						accRecord.Other_Race__c
					)
				);
			}

			dataList.add(new LPI_PDFSectionWrapper.DataWrapper('Nationality', accRecord.Nationality__c));
			if (accRecord.Nationality__c == 'OTHER') {
				dataList.add(new LPI_PDFSectionWrapper.DataWrapper('Nationality', accRecord.Other_Nationality__c));
			}
		}
		String fieldToQuery = 'ID, Location__c';
		String whereClause =
			'Preliminary_Application_Reference__c = \'' +
			String.escapeSingleQuotes(parRecord.Id) +
			'\'';
		Set<String> locationIds = new Set<String>();
		List<Temp_AuthApplicationPlace__c> personInfoTempAuthList = new List<Temp_AuthApplicationPlace__c>();
		if (parRecord.Is_Supervisor_User__c) {
			personInfoTempAuthList = new LPI_TempAuthApplicationPlaceDAO.LPI_TempAuthApplicationPlaceWithoutSharingDAO()
				.getTempAuthApplicationPlaceByDymanicQuery(fieldToQuery, whereClause, null, null, null);
		} else {
			personInfoTempAuthList = LPI_TempAuthApplicationPlaceDAO.getTempAuthApplicationPlaceByDymanicQuery(
				fieldToQuery,
				whereClause,
				null,
				null,
				null
			);
		}
		for (Temp_AuthApplicationPlace__c tempAAP : personInfoTempAuthList) {
			locationIds.add(tempAAP.Location__c);
		}
		List<LPI_PDFSectionWrapper> addressSubSection = new List<LPI_PDFSectionWrapper>();
		if (!locationIds.isEmpty()) {
			addressSubSection = getAddressSection(locationIds, parRecord);
		}
		dataList = getLawfulPresenceDetails(dataList, accRecord);
		personalInfoSection.addSubSection(new LPI_PDFSectionWrapper('', 3, dataList));
		personalInfoSection.addSubSection(addressSubSection);
		return personalInfoSection;
		
	}

	/* @description  This method is used to populate Licensure History Details
	 * @author MTX Group Inc | 04-06-2023
	 * @param parRecord :
	 * @param accRecord :
	 * @return LPI_PDFSectionWrapper
	 **/
	public static LPI_PDFSectionWrapper getLicensureHistory(PreliminaryApplicationRef parRecord) {
		String parId = parRecord.Id;
		LPI_PDFSectionWrapper instructionStep;
		List<LPI_PDFSectionWrapper.DataWrapper> dataList = new List<LPI_PDFSectionWrapper.DataWrapper>();
		LPI_PDFSectionWrapper.DataWrapper secondQst;
		List<LPI_PDFSectionWrapper.LicenseQuestionWrapper> stepList = new List<LPI_PDFSectionWrapper.LicenseQuestionWrapper>();
		Map<String, String> fieldAPIToLabelMap = new Map<String, String>{
			'LicenseNumber' => 'License Number',
			'LicensureDate' => 'Licensure Date',
			'ExpirationDate' => 'Expiration Date',
			'StateofLicensure' => 'State of Licensure',
			'ProfessionofLicensure' => 'Profession of Licensure',
			'CountryofLicensure' => 'Country of Licensure',
			'MethodofLicensure' => 'Method of Licensure',
			'Specify' => 'Specify',
			'Isyourlicense' => 'Is your license active?',
			'Describewhy' => 'Describe Why'
		};
		String stringToQuery = 'Id , Hold_Active_License__c, Amendment_Type__c, Business_License__r.Hold_Active_License__c, Board_Name__c, Regulatory_Authorization_Type__r.Name';
		String whereClause = 'Id= \'' + String.escapeSingleQuotes(parId) + '\'';
		List<PreliminaryApplicationRef> parList = LPI_PreliminaryApplicationRefDAO.getPreliminaryApplicationRefByDymanicQuery(
			stringToQuery,
			whereClause,
			'1',
			null,
			null
		);
		if (!parList.isEmpty()) {
                secondQst = new LPI_PDFSectionWrapper.DataWrapper(
				'Do you hold or have you ever held any licenses/registrations/certifications?',
                    parList[0].Amendment_Type__c ==
                        CHANGE_OF_SUPERVISOR_OR_SITE_AMENDMENT_TYPE
                        ? String.valueOf(
                            parList[0].Business_License__r.Hold_Active_License__c
                        )
                        : String.valueOf(parList[0].Hold_Active_License__c),
				'regularSectionHeading'
			);
            
			LPI_PDFSectionWrapper.LicenseQuestionWrapper secondQstMainWrap = new LPI_PDFSectionWrapper.LicenseQuestionWrapper(
				secondQst,
				3
			);
			stepList.add(secondQstMainWrap);
            LPI_PDFSectionWrapper.DataWrapper secondSubQst = new LPI_PDFSectionWrapper.DataWrapper(
                '',
                ''
            );
            if (
                parList[0].Hold_Active_License__c == 'Yes' ||
                (parList[0].Amendment_Type__c ==
                CHANGE_OF_SUPERVISOR_OR_SITE_AMENDMENT_TYPE &&
                parList[0].Business_License__r.Hold_Active_License__c == 'Yes')
				)
             {
				
				Map<String, Object> myTransformData = new Map<String, Object>{
					'parId' => parId,
					'headerFilterDr' => 'Licensure In Other States'
				};
				List<Map<String, Object>> myTransformResult = new List<Map<String, Object>>();
				Map<String, Object> applicantMap=new Map<String, Object>();
				
				if (parList[0].Amendment_Type__c == CHANGE_OF_SUPERVISOR_OR_SITE_AMENDMENT_TYPE) {
					Map<String, Object> outputMap = new Map<String, Object>();
					LPI_LicensureController.fetchLicensureHistoryReadOnlyInfo(myTransformData, outputMap);
					myTransformResult.addAll((List<Map<String, Object>>) outputMap.get('licensureHistoryDataList'));
				} else if(Test.isRunningTest()){
					applicantMap.put('Specify','Test');
					applicantMap.put('MethodofLicensure','Others');
					applicantMap.put('Describewhy','Test');
					applicantMap.put('Isyourlicense','No');
					applicantMap.put('LicensureDate',System.today());
					applicantMap.put('ExpirationDate',System.today());
					myTransformResult.add(applicantMap);
				} else {
					String DRName = 'FetchLicensureInOtherStates';
				omnistudio.DRProcessResult result = omnistudio.DRGlobal.process(myTransformData, DRName);
					myTransformResult = (List<Map<String, Object>>) result.toJsonList();
				}

				for (Map<String, Object> mapData : myTransformResult) {
					LPI_PDFSectionWrapper.LicenseQuestionWrapper secondQstWrap = new LPI_PDFSectionWrapper.LicenseQuestionWrapper(
						secondSubQst,
						3
					);
					for (String key : fieldAPIToLabelMap.keySet()) {
						if ((key == 'Specify' && mapData.get('MethodofLicensure') == 'Others')) {
							if (mapData.containsKey('Specify')) {
								secondQstWrap.addDependentQuestion(
									new LPI_PDFSectionWrapper.DataWrapper(
										fieldAPIToLabelMap.get('Specify'),
										String.valueOf(mapData.get('Specify'))
									)
								);
							}
						} else if ((key == 'Describewhy' && mapData.get('Isyourlicense') == 'No')) {
							if (mapData.containsKey('Describewhy')) {
								secondQstWrap.addDependentQuestion(
									new LPI_PDFSectionWrapper.DataWrapper(
										fieldAPIToLabelMap.get('Describewhy'),
										String.valueOf(mapData.get('Describewhy'))
									)
								);
							}
						} else if (key == 'LicensureDate' || key == 'ExpirationDate') {
							if (mapData.containsKey(key)) {
								secondQstWrap.addDependentQuestion(
									new LPI_PDFSectionWrapper.DataWrapper(
										fieldAPIToLabelMap.get(key),
										Date.valueOf(mapData.get(key))?.format()
									)
								);
							}
						} else {
							if (mapData.containsKey(key)) {
								secondQstWrap.addDependentQuestion(
									new LPI_PDFSectionWrapper.DataWrapper(
										fieldAPIToLabelMap.get(key),
										String.valueOf(mapData.get(key))
									)
								);
							}
						}
					}
					stepList.add(secondQstWrap);
				}
			}
		}
		return new LPI_PDFSectionWrapper(LICENSURE_HISTORY_STEP, stepList);
	}

	/* @description  This method is used to populate Supervisor Information Details
	 * @author MTX Group Inc | 03-31-2023
	 * @param parRecord :
	 * @param accRecord :
	 * @return LPI_PDFSectionWrapper
	 **/
	public static LPI_PDFSectionWrapper getSupervisorInformation(
		PreliminaryApplicationRef parRecord,
		Map<String, Object> inputMap,
		String stepName
	) {
		Map<String, Object> output = new Map<String, Object>();
		String parId = String.valueOf(parRecord.Id);
		List<LPI_PDFSectionWrapper.LicenseQuestionWrapper> stepList = new List<LPI_PDFSectionWrapper.LicenseQuestionWrapper>();
		Map<String, Object> dataMap = LPI_ApplicantSupervisorController.fetchPrimarySupervisorACR(inputMap);
		if (parRecord.Regulatory_Authorization_Type__r.IssuingDepartment.Name == 'Healing Arts') {
			LPI_PDFSectionWrapper.DataWrapper firstQst = new LPI_PDFSectionWrapper.DataWrapper(
				'Are you currently practicing under a supervisor/collaborating professional?',
				parRecord.Currently_Holding_Active_License_Number__c
			);
			LPI_PDFSectionWrapper.LicenseQuestionWrapper firstQstWrap = new LPI_PDFSectionWrapper.LicenseQuestionWrapper(
				firstQst,
				1
			);
			stepList.add(firstQstWrap);
		}
		if (dataMap != null && String.valueOf(dataMap.get('IsTheSupervisorLicensedinMissouri')) != 'No') {
			Map<String, String> fieldAPIToLabelMap = new Map<String, String>{
				'SupervisorFirstName' => 'First Name',
				'supervisorMiddleName' => 'Middle Name',
				'supervisorLastName' => 'Last Name',
				'supervisorStreetAddress' => 'Employment Street Address',
				'supervisorCity' => 'City',
				'supervisorState' => 'State',
				'supervisorZip' => 'Zip Code',
				'supervisorPhone' => 'Telephone Number',
				'supervisorEmail' => 'Email Address',
				'supervisorSpecialityCertification' => 'Speciality/Board Certification'
			};
			LPI_PDFSectionWrapper.DataWrapper mainHeading;
			if (stepName == PRM_SUPERVISOR_STEP && parRecord.Currently_Holding_Active_License_Number__c != 'No') {
				mainHeading = new LPI_PDFSectionWrapper.DataWrapper(
					'Primary Supervisor',
					'',
					'regularSectionHeading'
				);
			} else if (stepName == SUPERVISOR_INFO_STEP) {
				mainHeading = new LPI_PDFSectionWrapper.DataWrapper('', '', 'regularSectionHeading');
			}
			LPI_PDFSectionWrapper.LicenseQuestionWrapper mainHeadingWrap = new LPI_PDFSectionWrapper.LicenseQuestionWrapper(
				mainHeading,
				1
			);
			LPI_PDFSectionWrapper.DataWrapper mainQst = new LPI_PDFSectionWrapper.DataWrapper(
				'License Number',
				String.valueOf(dataMap.get('supervisorLicenseNumber'))
			);
			LPI_PDFSectionWrapper.LicenseQuestionWrapper newWrap = new LPI_PDFSectionWrapper.LicenseQuestionWrapper(
				mainQst,
				2
			);
			LPI_PDFSectionWrapper.LicenseQuestionWrapper licensedEntityWrap;
			if (String.valueOf(dataMap.get('IsTheSupervisorLicensedinMissouri')) == 'Yes'  && parRecord.Type__c != 'Provisional License Extension') {
				LPI_PDFSectionWrapper.DataWrapper licensedQst = new LPI_PDFSectionWrapper.DataWrapper(
					'Is your supervisor licensed in Missouri?',
					String.valueOf(dataMap.get('IsTheSupervisorLicensedinMissouri'))
				);
				licensedEntityWrap = new LPI_PDFSectionWrapper.LicenseQuestionWrapper(licensedQst, 1);
			}

			for (String fieldAPI : fieldAPIToLabelMap.keySet()) {
				if (dataMap.containsKey(fieldAPI)) {
					newWrap.addDependentQuestion(
						new LPI_PDFSectionWrapper.DataWrapper(
							fieldAPIToLabelMap.get(fieldAPI),
							String.valueOf(dataMap.get(fieldAPI))
						)
					);
				}
			}
			LPI_PDFSectionWrapper.LicenseQuestionWrapper attestationWrap;
			if (stepName == SUPERVISOR_INFO_STEP) {
				String attestationMsg = 'I hereby affirm that I have accurately completed the form and consent to the disclosure of my application information to the designated';
				attestationMsg += 'supervisor for the purpose of their consideration as my supervisor.';
				attestationWrap = new LPI_PDFSectionWrapper.LicenseQuestionWrapper(mainHeading, 1);
				attestationWrap.addDependentQuestion(
					new LPI_PDFSectionWrapper.DataWrapper(attestationMsg, 'true', 'checkbox')
				);
			}
			stepList.add(mainHeadingWrap);
			if (
				String.valueOf(dataMap.get('IsTheSupervisorLicensedinMissouri')) == 'Yes' &&
				parRecord.Currently_Holding_Active_License_Number__c != 'No'
			) {
				stepList.add(licensedEntityWrap);
			}
			if (parRecord.Currently_Holding_Active_License_Number__c != 'No') {
				stepList.add(newWrap);
			}
			stepList.add(attestationWrap);
		}
		String stringToQuery = 'Id ';
		String whereClause = 'Id= \'' + String.escapeSingleQuotes(parId) + '\'';
		List<PreliminaryApplicationRef> parList = LPI_PreliminaryApplicationRefDAO.getPreliminaryApplicationRefByDymanicQuery(
			stringToQuery,
			whereClause,
			null,
			null,
			null
		);
		inputMap.put('parId', parId);
		
		if (output != null && String.valueOf(output.get('IsTheSupervisorLicensedinMissouri')) == 'No') {
			Map<String, String> fieldAPIToLabelMap = new Map<String, String>{
				'unSupervisorLicenseNumber' => 'License Type',
				'unSupervisorFirstName' => 'First Name',
				'unSupervisorMiddleName' => 'Middle Name',
				'unSupervisorLastName' => 'Last Name',
				'unSupervisorStreetAddress' => 'Employment Street Address',
				'unSupervisorCity' => 'City',
				'unSupervisorState' => 'State',
				'unSupervisorZip' => 'Zip Code',
				'unSupervisorPhone' => 'Telephone Number',
				'unSupervisorEmail' => 'Email Address',
				'unSupervisorSpecialityCertification' => 'Speciality/Board Certification'
			};
			LPI_PDFSectionWrapper.DataWrapper mainHeading;
			if (stepName == PRM_SUPERVISOR_STEP) {
				mainHeading = new LPI_PDFSectionWrapper.DataWrapper(
					'Primary Supervisor',
					'',
					'regularSectionHeading'
				);
			}

			LPI_PDFSectionWrapper.LicenseQuestionWrapper mainHeadingWrap = new LPI_PDFSectionWrapper.LicenseQuestionWrapper(
				mainHeading,
				1
			);
			LPI_PDFSectionWrapper.DataWrapper mainQst = new LPI_PDFSectionWrapper.DataWrapper(
				'Is your supervisor licensed in Missouri?',
				String.valueOf(output.get('IsTheSupervisorLicensedinMissouri'))
			);
			LPI_PDFSectionWrapper.LicenseQuestionWrapper newWrap = new LPI_PDFSectionWrapper.LicenseQuestionWrapper(
				mainQst,
				2
			);
			for (String fieldAPI : fieldAPIToLabelMap.keySet()) {
				if (output.containsKey(fieldAPI)) {
					newWrap.addDependentQuestion(
						new LPI_PDFSectionWrapper.DataWrapper(
							fieldAPIToLabelMap.get(fieldAPI),
							String.valueOf(output.get(fieldAPI))
						)
					);
				}
			}
			stepList.add(mainHeadingWrap);
			stepList.add(newWrap);
		}
		return new LPI_PDFSectionWrapper(stepName, stepList);
	}

	/**
	 * @description  This method is used to populate Employee Information Details
	 * @author MTX Group Inc | 03-31-2023
	 * @param parRecord :
	 * @param accRecord :
	 * @return LPI_PDFSectionWrapper
	 **/
	public static LPI_PDFSectionWrapper getEmployeeInformation(PreliminaryApplicationRef parRecord) {
		LPI_PDFSectionWrapper employeeInfoStep = new LPI_PDFSectionWrapper('Employee Information', 2, null);
		Integer counter = 1;
		Map<String, Object> input = new Map<String, Object>();
		Map<String, Object> output = new Map<String, Object>();
		input.put('parId', String.valueOf(parRecord.Id));
		List<Map<String, Object>> empInfoList = LPI_EmployeeInformation.fetchEmployeeInformationForReview(
			input,
			output
		);
		Map<String, String> fieldAPIToLabelMap = new Map<String, String>{
			'LicenseNumber' => 'License Number',
			'LicenseType' => 'License Type',
			'NameEmployeeInformation' => 'Name',
			'Title1' => 'Title'
		};

		Map<String, String> fieldAPIToMissourilMap = new Map<String, String>{
			'NameEmployeeInformation' => 'Name',
			'LicenseNumber' => 'License Number',
			'LicenseType' => 'License Type',
			'Title1' => 'Title',
			'EmailIfAnsweredNo' => 'Email',
			'TelephoneIfAnsweredNo' => 'Phone Number'
		};

		for (Map<String, Object> empMap : empInfoList) {
			if (
				String.valueOf(empMap.get('BoardName')) != 'Cosmetology & Barber Examiners' &&
				String.valueOf(empMap.get('BoardName')) != 'Veterinary' &&
				String.valueOf(empMap.get('BoardName')) != 'Embalmers & Funeral Directors'
			) {
				fieldAPIToLabelMap.put('LicensedInMissouri', 'Is the employee licensed in Missouri?');
				fieldAPIToMissourilMap.put('LicensedInMissouri', 'Is the employee licensed in Missouri?');
			}
			if (String.valueOf(empMap.get('licenseType')) != 'Tattooing Establishment') {
				fieldAPIToLabelMap.put('StreetAddress1', 'Street Address');
				fieldAPIToLabelMap.put('City', 'City');
				fieldAPIToLabelMap.put('State', 'State');
				fieldAPIToLabelMap.put('Country', 'Country');
				fieldAPIToLabelMap.put('Zip', 'Zip Code');
			}

			List<LPI_PDFSectionWrapper.DataWrapper> addressList = new List<LPI_PDFSectionWrapper.DataWrapper>();
			List<LPI_PDFSectionWrapper.DataWrapper> dataList = new List<LPI_PDFSectionWrapper.DataWrapper>();
			if (
				String.valueOf(empMap.get('LicensedInMissouri')) == 'Yes' ||
				String.valueOf(empMap.get('BoardName')) == 'Cosmetology & Barber Examiners'
			) {
				dataList.add(
					new LPI_PDFSectionWrapper.DataWrapper(
						'This employee is actively associated with this organization',
						'true',
						'checkbox'
					)
				);
				for (String fieldAPI : fieldAPIToLabelMap.keySet()) {
					dataList.add(
						new LPI_PDFSectionWrapper.DataWrapper(
							fieldAPIToLabelMap.get(fieldAPI),
							String.valueOf(empMap.get(fieldAPI))
						)
					);
				}
			} else if (String.valueOf(empMap.get('LicensedInMissouri')) == 'No') {
				for (String fieldAPI : fieldAPIToMissourilMap.keySet()) {
					dataList.add(
						new LPI_PDFSectionWrapper.DataWrapper(
							fieldAPIToMissourilMap.get(fieldAPI),
							String.valueOf(empMap.get(fieldAPI))
						)
					);
				}
			}
			employeeInfoStep.addSubSection(new LPI_PDFSectionWrapper('Employee Information ' + counter, 2, dataList));
			counter += 1;
		}
		return employeeInfoStep;
	}

	/**
	 * @author                      : MTX Group Inc
	 * @since                       : August 31, 2022
	 * @description                 : This method is used to fetch Education History details
	 * @param parRecord             : Input `PreliminaryApplicationRef` record
	 * @return                      : `LPI_PDFSectionWrapper`
	 * @last modified by            : Ayush Dev
	 * @last modified date          : January 25, 2024
	 * @last modified details       : Code Beautification and HEARING_INSTRUMENT_SPECIALISTS_BOARD_NAME check for I-253601
	 */
	public static LPI_PDFSectionWrapper getEducationHistoryDetails(PreliminaryApplicationRef parRecord) {
		String parId = parRecord.Id;
		Integer counter = 1;
		String DRName = 'FetchPersonEducationHistoryDetails';
		omnistudio.DRProcessResult result;
		List<Map<String, Object>> myTransformResult;
		List<LPI_PDFSectionWrapper.LicenseQuestionWrapper> stepList = new List<LPI_PDFSectionWrapper.LicenseQuestionWrapper>();		
		Map<String, Object> myTransformData = new Map<String, Object>{
			'getParId' => parId,
			'filterEducationType' => 'Higher Education'
		};
		Map<String, Object> applicantMap=new Map<String, Object>();
		if(Test.isRunningTest()){
			myTransformResult = new List<Map<String, Object>>();
			applicantMap.put('newSchoolCheckBox',true);
			applicantMap.put('NameOfTheSchool','Test School');
			applicantMap.put('Country','United States');
			applicantMap.put('StateUnitedStates','California');
			applicantMap.put('City','Test City');
			applicantMap.put('Degree','Test Degree');
			applicantMap.put('GraduationDate',System.today().addDays(30));
			
			myTransformResult.add(applicantMap);
		}else{
			result = omnistudio.DRGlobal.process(myTransformData, DRName);
			myTransformResult = (List<Map<String, Object>>) result.toJsonList();
		}
		for (Map<String, Object> dataMap : myTransformResult) {
			LPI_PDFSectionWrapper.DataWrapper checkboxQst = new LPI_PDFSectionWrapper.DataWrapper('', '');
			LPI_PDFSectionWrapper.LicenseQuestionWrapper newCheckBoxWrap = new LPI_PDFSectionWrapper.LicenseQuestionWrapper(
				checkboxQst,
				1
			);
			newCheckBoxWrap.addDependentQuestion(
				new LPI_PDFSectionWrapper.DataWrapper(
					'If school is not found in the search, please check this box to add manually.',
					String.valueOf(dataMap.get('newSchoolCheckBox')),
					'checkbox'
				)
			);
			LPI_PDFSectionWrapper.DataWrapper mainQst;
			LPI_PDFSectionWrapper.LicenseQuestionWrapper newWrap = new LPI_PDFSectionWrapper.LicenseQuestionWrapper(
				mainQst,
				2
			);
			newWrap.addDependentQuestion(
				new LPI_PDFSectionWrapper.DataWrapper('Name Of The University', String.valueOf(dataMap.get('NameOfTheSchool')))
			);
			newWrap.addDependentQuestion(
				new LPI_PDFSectionWrapper.DataWrapper('Degree', String.valueOf(dataMap.get('Degree')))
			);
			newWrap.addDependentQuestion(
				new LPI_PDFSectionWrapper.DataWrapper('Country', String.valueOf(dataMap.get('Country')))
			);
			if (String.valueOf(dataMap.get('Country')) == 'United States') {
				newWrap.addDependentQuestion(
					new LPI_PDFSectionWrapper.DataWrapper(
						'State',
						String.valueOf(dataMap.get('StateUnitedStates'))
					)
				);
			} else {
				newWrap.addDependentQuestion(
					new LPI_PDFSectionWrapper.DataWrapper(
						'State',
						String.valueOf(dataMap.get('StateNonUnitedStates'))
					)
				);
			}
			newWrap.addDependentQuestion(
				new LPI_PDFSectionWrapper.DataWrapper('City', String.valueOf(dataMap.get('City')))
			);
			newWrap.addDependentQuestion(
				new LPI_PDFSectionWrapper.DataWrapper(
					'Start Date',
					Date.valueOf(dataMap.get('StartDate'))?.format()
				)
			);
			newWrap.addDependentQuestion(
				new LPI_PDFSectionWrapper.DataWrapper(
					'End Date',
					Date.valueOf(dataMap.get('EndDate'))?.format()
				)
			);
			newWrap.addDependentQuestion(
				new LPI_PDFSectionWrapper.DataWrapper(
					'Graduation Date',
					Date.valueOf(dataMap.get('GraduationDate'))?.format()
				)
			);
			stepList.add(newCheckBoxWrap);
			stepList.add(newWrap);
		}
		return new LPI_PDFSectionWrapper('Education History', stepList);
	}

	/**
	 * @description
	 * @author MTX Group Inc | 03-19-2023
	 * @param parRecord :
	 * @param accRecord :
	 * @return LPI_PDFSectionWrapper
	 **/
	public static List<LPI_PDFSectionWrapper> getAddressSection(
		Set<String> locationIds,
		PreliminaryApplicationRef parRecord
	) {
		String fields =
			'ID,ParentId,Parent.LocationType,Parent.Name,toLabel(StateCode),Business_State__c,' +
			'CountryCode,City,County__c,PostalCode,State,Street,Country';
		String whereClause = 'ParentId IN ' + LPI_ServiceUtility.getStringValuesByStringSet(locationIds);
		List<Schema.Address> addresses = LPI_AddressDAO.getAddressByDymanicQuery(
			fields,
			whereClause,
			null,
			null,
			null
		);
		List<LPI_PDFSectionWrapper> pdfSectionList = new List<LPI_PDFSectionWrapper>();
		LPI_PDFSectionWrapper residanceAddress;
		LPI_PDFSectionWrapper primaryStateOfResidence;
		LPI_PDFSectionWrapper mailingAddress;
		LPI_PDFSectionWrapper primaryContactAddress;
		LPI_PDFSectionWrapper licenseAddress;
		LPI_PDFSectionWrapper publicalyDisplayedAddress;
		LPI_PDFSectionWrapper otherField;
		for (Schema.Address address : addresses) {
			List<LPI_PDFSectionWrapper.DataWrapper> dataList = new List<LPI_PDFSectionWrapper.DataWrapper>();
			if (address.Parent.LocationType == RESIDENCE) {
				dataList.add(new LPI_PDFSectionWrapper.DataWrapper('Street Address', address.Street));
				dataList.add(new LPI_PDFSectionWrapper.DataWrapper('City', address.City));
				dataList.add(
					new LPI_PDFSectionWrapper.DataWrapper(
						'State',
						address.State != null ? address.StateCode : address.Business_State__c
					)
				);
				dataList.add(new LPI_PDFSectionWrapper.DataWrapper('Zip Code', address.PostalCode));
				dataList.add(new LPI_PDFSectionWrapper.DataWrapper('Country', address.Country));
				dataList.add(new LPI_PDFSectionWrapper.DataWrapper('County', address.County__c));
				COUNTRY_VALUE = address.Country;
				residanceAddress = new LPI_PDFSectionWrapper('Residence Address', 3, dataList);
			} else if (
				address.Parent.LocationType == MAILING &&
				!MAILING_ADDRESS_SAME_AS_RESIDENCE_BOARD_SET.contains(parRecord.Board_Name__c)
			) {
				dataList.add(new LPI_PDFSectionWrapper.DataWrapper('Street Address', address.Street));
				dataList.add(new LPI_PDFSectionWrapper.DataWrapper('City', address.City));
				dataList.add(
					new LPI_PDFSectionWrapper.DataWrapper(
						'State',
						address.State != null ? address.StateCode : address.Business_State__c
					)
				);
				dataList.add(new LPI_PDFSectionWrapper.DataWrapper('Zip Code', address.PostalCode));
				dataList.add(new LPI_PDFSectionWrapper.DataWrapper('Country', address.Country));
				dataList.add(new LPI_PDFSectionWrapper.DataWrapper('County', address.County__c));
				mailingAddress = new LPI_PDFSectionWrapper('Mailing Address', 3, dataList);
				dataList.clear();
				mailingAddress.addSubSection(new LPI_PDFSectionWrapper('', 1, dataList));
			}
			dataList.clear();
			if (
				!INDIVIDUAL_LICENSE_TYPE_OF_NURSING.contains(parRecord.Regulatory_Authorization_Type__r.Name) &&
				parRecord.Regulatory_Authorization_Type__r.IssuingDepartment.Name != REAL_ESTATE_BOARD
			) {
				if (address.Parent.LocationType == parRecord.Primary_Contact_Address__c) {
					dataList.add(
						new LPI_PDFSectionWrapper.DataWrapper(
							'Address Type',
							addressApiNameMap.get(parRecord.Primary_Contact_Address__c)
						)
					);
					primaryContactAddress = new LPI_PDFSectionWrapper('Primary Contact Address', 1, dataList);
					dataList.clear();

					if (
						ALL_ADDRESS_LIST.contains(address.Parent.LocationType) &&
						address.Parent.LocationType == parRecord.Primary_Contact_Address__c
					) {
						dataList.add(new LPI_PDFSectionWrapper.DataWrapper('Street Address', address.Street));
						dataList.add(new LPI_PDFSectionWrapper.DataWrapper('City', address.City));
						dataList.add(
							new LPI_PDFSectionWrapper.DataWrapper(
								'State',
								address.State != null ? address.StateCode : address.Business_State__c
							)
						);
						dataList.add(new LPI_PDFSectionWrapper.DataWrapper('Zip Code', address.PostalCode));
						dataList.add(new LPI_PDFSectionWrapper.DataWrapper('Country', address.Country));
						otherField = new LPI_PDFSectionWrapper('', 3, dataList);
						primaryContactAddress.addSubSection(otherField);
					}
				}
				dataList.clear();
				if (address.Parent.LocationType == parRecord.License_Address__c) {
					dataList.add(
						new LPI_PDFSectionWrapper.DataWrapper(
							'Address Type',
							addressApiNameMap.get(parRecord.License_Address__c)
						)
					);
					if (parRecord.Regulatory_Authorization_Type__r.Name == 'Preneed Agent') {
						licenseAddress = new LPI_PDFSectionWrapper('Registered Address', 1, dataList);
					} else {
						licenseAddress = new LPI_PDFSectionWrapper('License Address', 1, dataList);
					}
					dataList.clear();
					if (
						ALL_ADDRESS_LIST.contains(address.Parent.LocationType) &&
						address.Parent.LocationType == parRecord.License_Address__c
					) {
						dataList.add(new LPI_PDFSectionWrapper.DataWrapper('Street Address', address.Street));
						dataList.add(new LPI_PDFSectionWrapper.DataWrapper('City', address.City));
						dataList.add(
							new LPI_PDFSectionWrapper.DataWrapper(
								'State',
								address.State != null ? address.StateCode : address.Business_State__c
							)
						);
						dataList.add(new LPI_PDFSectionWrapper.DataWrapper('Zip Code', address.PostalCode));
						dataList.add(new LPI_PDFSectionWrapper.DataWrapper('Country', address.Country));
						otherField = new LPI_PDFSectionWrapper('', 3, dataList);
						licenseAddress.addSubSection(otherField);
					}
				}
				dataList.clear();
				if (address.Parent.LocationType == parRecord.Publicly_Displayed_Address__c) {
					dataList.add(
						new LPI_PDFSectionWrapper.DataWrapper(
							'Address Type',
							addressApiNameMap.get(parRecord.Publicly_Displayed_Address__c)
						)
					);
					publicalyDisplayedAddress = new LPI_PDFSectionWrapper('Publicly Displayed Address', 1, dataList);
					dataList.clear();
					if (
						ALL_ADDRESS_LIST.contains(address.Parent.LocationType) &&
						parRecord.Publicly_Displayed_Address__c != parRecord.License_Address__c &&
						parRecord.Publicly_Displayed_Address__c != parRecord.Primary_Contact_Address__c &&
						parRecord.Publicly_Displayed_Address__c != RESIDENCE &&
						parRecord.Publicly_Displayed_Address__c != MAILING
					) {
						dataList.add(new LPI_PDFSectionWrapper.DataWrapper('Street Address', address.Street));
						dataList.add(new LPI_PDFSectionWrapper.DataWrapper('City', address.City));
						dataList.add(
							new LPI_PDFSectionWrapper.DataWrapper(
								'State',
								address.State != null ? address.StateCode : address.Business_State__c
							)
						);
						dataList.add(new LPI_PDFSectionWrapper.DataWrapper('Zip Code', address.PostalCode));
						dataList.add(new LPI_PDFSectionWrapper.DataWrapper('Country', address.Country));
						otherField = new LPI_PDFSectionWrapper('', 3, dataList);
						publicalyDisplayedAddress.addSubSection(otherField);
						dataList.clear();
					
						publicalyDisplayedAddress.addSubSection(new LPI_PDFSectionWrapper('', 1, dataList));
					} else {
						dataList.add(
							new LPI_PDFSectionWrapper.DataWrapper(
								'By clicking this checkbox, your ' +
									addressApiNameMapForConsent.get(parRecord.Publicly_Displayed_Address__c) +
									' will be displayed publicly.',
								String.valueOf(parRecord.Consent_for_Primary_Contact_Address__c),
								'checkbox'
							)
						);
						publicalyDisplayedAddress.addSubSection(new LPI_PDFSectionWrapper('', 1, dataList));
					}
				}
			}
		}

		if (residanceAddress != null) {
			pdfSectionList.add(residanceAddress);
		}
		if (primaryStateOfResidence != null) {
			pdfSectionList.add(primaryStateOfResidence);
		}
		if (mailingAddress != null) {
			pdfSectionList.add(mailingAddress);
		}
		if (primaryContactAddress != null) {
			pdfSectionList.add(primaryContactAddress);
		}
		if (licenseAddress != null) {
			pdfSectionList.add(licenseAddress);
		}
		if (publicalyDisplayedAddress != null) {
			pdfSectionList.add(publicalyDisplayedAddress);
		}
		return pdfSectionList;
	}

	/**
	 * @author                      : MTX Group Inc
	 * @since                       : march 24,2023
	 * @description                 : This method will give Military Questions Step Data
	 * @param parRecord             : PreliminaryApplicationRef
	 * @return                      : LPI_PDFSectionWrapper
	 * @last modified by            : Ayush Dev
	 * @last modified date          :
	 * @modified details            :
	 */
	public static LPI_PDFSectionWrapper getMilitaryQuestionsSection(PreliminaryApplicationRef parRecord) {
		LPI_PDFSectionWrapper militaryQuestionSection;
		List<LPI_PDFSectionWrapper.DataWrapper> dataList = new List<LPI_PDFSectionWrapper.DataWrapper>();
		if (MILITARY_QUESTION_SET.contains(parRecord.Regulatory_Authorization_Type__r.Name)) {
			dataList.add(
				new LPI_PDFSectionWrapper.DataWrapper(
					'Have you (or any owner, officer, member, manager, or employee?) or an immediate family member ever served to the U.S. Armed forces?',
					parRecord.Served_In_US_Armed_Force__c
				)
			);
		} else {
			dataList.add(
				new LPI_PDFSectionWrapper.DataWrapper(
					'Have you or an immediate family member ever served in the U.S. Armed Forces?',
					parRecord.Served_In_US_Armed_Force__c
				)
			);
		}
		if (parRecord.Served_In_US_Armed_Force__c == 'Yes') {
			dataList.add(
				new LPI_PDFSectionWrapper.DataWrapper(
					'Would you like information about military related services in Missouri?',
					parRecord.Info_About_Military_Related_Services__c
				)
			);
		}
		militaryQuestionSection = new LPI_PDFSectionWrapper(MILITARY_QUESTIONS_STEP, 1, dataList);
		return militaryQuestionSection;
	}

	/**
	 * @author                      : MTX Group Inc
	 * @since                       : march 24,2023
	 * @description                 : This method will give Document Step Data
	 * @param parId                 : String
	 * @return                      : LPI_PDFSectionWrapper
	 * @last modified by            : Ayush Dev
	 * @last modified date          :
	 * @modified details            :
	 */
	public static LPI_PDFSectionWrapper getDocumentSection(String parId) {
		try{
		List<LPI_PDFSectionWrapper.DataWrapper> dataList = new List<LPI_PDFSectionWrapper.DataWrapper>();
		List<LPI_PDFSectionWrapper.DataWrapper> lawfulDocumentsList = new List<LPI_PDFSectionWrapper.DataWrapper>();
		List<LPI_PDFSectionWrapper> lawfulSubsectionList = new List<LPI_PDFSectionWrapper>();
		Map<String, String> response = LPI_GetApplicationDocumentController.getApplicationDocumentList(parId);
		String documentString = response != null ? response.get('documents') : null;
		if (String.isNotBlank(documentString)) {
			List<LPI_GetApplicationDocumentController.DocumentWrapper> documents = (List<LPI_GetApplicationDocumentController.DocumentWrapper>) JSON.deserialize(
				documentString,
				List<LPI_GetApplicationDocumentController.DocumentWrapper>.class
			);

			for (LPI_GetApplicationDocumentController.DocumentWrapper doc : documents) {
				if (String.isNotBlank(doc.documentRecord.Document_Name__c)) {
					String uploadedFiles = '';
					for (ContentDocumentLink cdLink : doc.documentRecord.ContentDocumentLinks) {
						if (uploadedFiles == '') {
							uploadedFiles += cdLink.ContentDocument.Title + '.' + cdLink.ContentDocument.FileExtension;
						} else {
							uploadedFiles +=
								', ' +
								cdLink.ContentDocument.Title +
								'.' +
								cdLink.ContentDocument.FileExtension;
						}
					}
					for (LPI_Wrapper.FileWrapper file : doc.files) {
						if (uploadedFiles == '') {
							uploadedFiles += file.fileName;
						} else {
							uploadedFiles += ', ' + file.fileName;
						}
					}

					if (doc.documentRecord.Is_Lawful_Presence_Document__c) {
						lawfulDocumentsList.add(
							new LPI_PDFSectionWrapper.DataWrapper(doc.documentRecord.Document_Name__c, uploadedFiles)
						);
					} else {
						dataList.add(
							new LPI_PDFSectionWrapper.DataWrapper(doc.documentRecord.Document_Name__c, uploadedFiles)
						);
					}
				}
			}
			if (!lawfulDocumentsList.isEmpty()) {
				lawfulSubsectionList.add(
					new LPI_PDFSectionWrapper('Lawful Presence Documentation', 3, lawfulDocumentsList)
				);
			}
		}
		LPI_PDFSectionWrapper documentPdfWrapper = new LPI_PDFSectionWrapper(DOCUMENTS_STEP, 3, dataList);
		documentPdfWrapper.addSubSection(lawfulSubsectionList);
		return documentPdfWrapper;
	}catch (Exception e) {
		LPI_ExceptionManager.logException('LPI_ApplicationDataUtility', 'getDocumentSection', e);
		return null;
	}
	}
	
	/**
	 * @author                      : MTX Group Inc
	 * @since                       : march 24,2023
	 * @description                 : This method will give Request Details Step Data
	 * @param parRecord             : PreliminaryApplicationRef
	 * @return                      : LPI_PDFSectionWrapper
	 * @last modified by            : Ayush Dev
	 * @last modified date          :
	 * @modified details            :
	 */
	public static LPI_PDFSectionWrapper getRequestDetailsSection(PreliminaryApplicationRef parRecord) {
		List<LPI_PDFSectionWrapper.DataWrapper> dataList = new List<LPI_PDFSectionWrapper.DataWrapper>();
		if (REQUEST_DET_ADDITIONAL_QUE_APPLICABLE_BOARDS.contains(parRecord.Board_Name__c)) {
			dataList.add(
				new LPI_PDFSectionWrapper.DataWrapper(
					'Do you require the board to include School/Exam/Continuing' +
					' Education Information as part of the certification of licensure?',
					String.valueOf(parRecord.Require_the_board_to_include_School__c)
				)
			);
		}
		
		dataList.add(
			new LPI_PDFSectionWrapper.DataWrapper(
				'Choose the delivery option(s)',
				parRecord.Choose_the_Certification_Delivery_option__c
			)
		);
		if (String.isNotBlank(parRecord.Certification_Email__c)) {
			dataList.add(new LPI_PDFSectionWrapper.DataWrapper('Email', parRecord.Certification_Email__c));
		}
		if (String.isNotBlank(parRecord.Fax_Number__c)) {
			dataList.add(new LPI_PDFSectionWrapper.DataWrapper('Fax Number', parRecord.Fax_Number__c));
		}
		if (String.isNotBlank(parRecord.Street_Address__c)) {
			dataList.add(new LPI_PDFSectionWrapper.DataWrapper('Street Address', parRecord.Street_Address__c));
		}
		
		if (String.isNotBlank(parRecord.Zip_Code__c)) {
			dataList.add(new LPI_PDFSectionWrapper.DataWrapper('Zip Code', parRecord.Zip_Code__c));
		}
		
		return new LPI_PDFSectionWrapper(REQUEST_DETAILS_STEP, 3, dataList);
	}

	/**
	 * @author                      : MTX Group Inc
	 * @since                       : March 24, 2023
	 * @description                 : This method is used to fetch License Question Section in PDF format
	 * @param parRecord             : Input `PreliminaryApplicationRef` record
	 * @return                      : `LPI_PDFSectionWrapper`
	 * @last modified by            : Ayush Dev
	 * @last modified date          : February 12, 2024
	 * @last modified details       : Code Beautification and fix for I-248742
	 */
	public static LPI_PDFSectionWrapper getLicensedQuestionSection(PreliminaryApplicationRef parRecord) {
		String licenseQuestionStepName = '';
		if (
			parRecord.License_Questions_Step_API_Name__c.contains('{') &&
			parRecord.License_Questions_Step_API_Name__c.contains('}')
		) {
			LPI_PaymentStepController.StepWrapper stepData = (LPI_PaymentStepController.StepWrapper) JSON.deserialize(
				parRecord.License_Questions_Step_API_Name__c,
				LPI_PaymentStepController.StepWrapper.class
			);
			licenseQuestionStepName = stepData.stepName;
		} else {
			licenseQuestionStepName = parRecord.License_Questions_Step_API_Name__c;
		}
		if (
			licenseQuestionStepName == 'OccupationalTherapyRenewalLicenseQuestionsStep' ||
			licenseQuestionStepName == 'CSWRenewalLicenseQuestions' ||
			licenseQuestionStepName == 'HISHearingInstSpecTempPermitBEHISLicenseQuestions' ||
			licenseQuestionStepName == 'GetVeterinarianAndVeterinaryTechnicianRenewalLicenseQuestions'
		) {
			Map<String, String> dynamicKeyToValues = new Map<String, String>();
			Map<String, Object> deserializedValueMap = (Map<String, Object>) JSON.deserializeUntyped(
				String.valueOf(parRecord.License_Questions__c)
			);
			if (licenseQuestionStepName == 'CSWRenewalLicenseQuestions') {
				dynamicKeyToValues.put('%blExpirationDate%', (String) deserializedValueMap.get('blExpirationDate'));
				dynamicKeyToValues.put('<p class="social-workers">', '');
				dynamicKeyToValues.put('</p>', '');
			} else if (licenseQuestionStepName == 'OccupationalTherapyRenewalLicenseQuestionsStep') {
				dynamicKeyToValues.put(
					'%startYear%',
					(String) deserializedValueMap.get('startYearFormulaForAppReview')
				);
				dynamicKeyToValues.put(
					'%expiryYear%',
					(String) deserializedValueMap.get('expiryYearFormulaForAppReview')
				);
			} else if (
				licenseQuestionStepName == 'HISHearingInstSpecTempPermitBEHISLicenseQuestions' &&
				parRecord.Type__c == APPLICATION_TYPE_RENEWAL
			) {
				Map<String, Object> blockMap = (Map<String, Object>) deserializedValueMap.get('TypeRewewalHISLQBlock');
				dynamicKeyToValues.put('%currYearHIS%', String.valueOf(blockMap.get('currYearHIS')));
			} else if (licenseQuestionStepName == 'GetVeterinarianAndVeterinaryTechnicianRenewalLicenseQuestions') {
				dynamicKeyToValues.put(
					'%expiryYear%',
					String.valueOf(deserializedValueMap.get('FormulaForPeriodEndDateYear'))
				);
				dynamicKeyToValues.put(
					'%FormulaForPeriodStartDateYear%',
					String.valueOf(deserializedValueMap.get('FormulaForPeriodStartDateYear'))
				);
				dynamicKeyToValues.put(
					'%FormulaForGraduateYear%',
					String.valueOf(deserializedValueMap.get('FormulaForGraduateYear'))
				);
			}
			dynamicKeyToValues.put('*', '');
			LPI_OSStepParser osParser = new LPI_OSStepParser(
				parRecord.License_Questions_Step_API_Name__c,
				parRecord,
				dynamicKeyToValues
			);
			return osParser.getPDFSectionWrapper(parRecord.License_Questions__c, LICENSE_QUESTIONS_STEP);
		} 
		
		else if (
			licenseQuestionStepName == 'RenewalLicenseQuestionsStep' ||
			licenseQuestionStepName == 'SCIInterpretersLicenseQuestions'
		) {
			Map<String, String> dynamicKeyToValues = new Map<String, String>();
			Map<String, Object> deserializedValueMap = (Map<String, Object>) JSON.deserializeUntyped(
				String.valueOf(parRecord.License_Questions__c)
			);
			if (deserializedValueMap.containsKey('ExpiryDate')) {
				dynamicKeyToValues.put('%ExpiryDate%', String.valueof(deserializedValueMap.get('ExpiryDate')));
			}
			if (deserializedValueMap.containsKey('ExpiryDateReact')) {
				dynamicKeyToValues.put(
					'%ExpiryDateReact%',
					String.valueof(deserializedValueMap.get('ExpiryDateReact'))
				);
			}
			if (deserializedValueMap.containsKey('ExpiryDateReact1')) {
				dynamicKeyToValues.put(
					'%ExpiryDateReact1%',
					String.valueof(deserializedValueMap.get('ExpiryDateReact1'))
				);
			}
			dynamicKeyToValues.put('* ', '');
			LPI_OSStepParser osParser = new LPI_OSStepParser(
				parRecord.License_Questions_Step_API_Name__c,
				parRecord,
				dynamicKeyToValues
			);
			return osParser.getPDFSectionWrapper(parRecord.License_Questions__c, LICENSE_QUESTIONS_STEP);
		} else if (licenseQuestionStepName == 'AccCPAProvisonalLicenseQuestion') {
			Map<String, String> dynamicKeyToValues = new Map<String, String>();
			Map<String, Object> deserializedValueMap = (Map<String, Object>) JSON.deserializeUntyped(
				String.valueOf(parRecord.License_Questions__c)
			);
			Date currentDate = Date.today();
			dynamicKeyToValues.put(
				'%CalendarStartDatePrevTwoYear%',
				'( ' + Date.parse('01/01/' + String.valueOf(currentDate.year() - 2)).format()
			);
			dynamicKeyToValues.put(
				'%CalendarEndDatePrevTwoYear%',
				' - ' + Date.parse('12/31/' + String.valueOf(currentDate.year() - 2)).format() + ')'
			);
			dynamicKeyToValues.put(
				'%CalendarStartDatePrevOneYear%',
				'( ' + Date.parse('01/01/' + String.valueOf(currentDate.year() - 1)).format()
			);
			dynamicKeyToValues.put(
				'%CalendarEndDatePrevOneYear%',
				' - ' + Date.parse('12/31/' + String.valueOf(currentDate.year() - 1)).format() + ')'
			);
			dynamicKeyToValues.put('%PrevTwoYearFrmula%', String.valueOf(currentDate.year() - 2));
			dynamicKeyToValues.put('%PrevOneYearFrmula%', String.valueOf(currentDate.year() - 1));
			dynamicKeyToValues.put('-%hypenToRemove%', '');
			dynamicKeyToValues.put('* ', '');
			LPI_OSStepParser osParser = new LPI_OSStepParser(
				parRecord.License_Questions_Step_API_Name__c,
				parRecord,
				dynamicKeyToValues
			);
			return osParser.getPDFSectionWrapper(parRecord.License_Questions__c, LICENSE_QUESTIONS_STEP);
		}
		else {
			LPI_OSStepParser osParser = new LPI_OSStepParser(
				parRecord.License_Questions_Step_API_Name__c,
				parRecord
			);
			return osParser.getPDFSectionWrapper(parRecord.License_Questions__c, LICENSE_QUESTIONS_STEP);
		}
	}


	/**
	 * @author                      : MTX Group Inc
	 * @since                       : march 27,2023
	 * @description                 : This is a generic Method which will give Business Information Section
	 * @param parId                 : String
	 * @return                      : LPI_PDFSectionWrapper
	 * @last modified by            : Ayush Dev
	 * @last modified date          :
	 * @modified details            :
	 */
	public static LPI_PDFSectionWrapper getBusinessInformation(PreliminaryApplicationRef parRecord) {
		String parId = parRecord.Id;
		Map<String, Object> input = new Map<String, Object>();
		Map<String, Object> output = new Map<String, Object>();
		input.put('parId', parId);
		LPI_PDFSectionWrapper pdfWrapper = new LPI_PDFSectionWrapper();
		LPI_CreateBusinessAccount.fetchBusinessInformation(input, output);
		List<LPI_PDFSectionWrapper.DataWrapper> dataList = new List<LPI_PDFSectionWrapper.DataWrapper>();
		List<LPI_PDFSectionWrapper.DataWrapper> SubSectionDataList = new List<LPI_PDFSectionWrapper.DataWrapper>();

		dataList.add(
			new LPI_PDFSectionWrapper.DataWrapper('Business Name', String.valueOf(output.get('BusinessName')))
		);
		if (!PI_PFI_AGENCY_BRANCH_SET.contains(parRecord.Regulatory_Authorization_Type__r.Name)) {
			
			dataList.add(
				new LPI_PDFSectionWrapper.DataWrapper(
					'Fictitious Name/D.B.A',
					String.valueOf(output.get('FictitiousName'))
				)
			);
			dataList.add(
				new LPI_PDFSectionWrapper.DataWrapper(
					'Telephone Number',
					String.valueOf(output.get('BusinessPhoneNumber'))
				)
			);
			dataList.add(
				new LPI_PDFSectionWrapper.DataWrapper('Fax Number', String.valueOf(output.get('BusinessFaxNumber')))
			);
			dataList.add(
				new LPI_PDFSectionWrapper.DataWrapper(
					'Business Website',
					String.valueOf(output.get('BusinessWebsite'))
				)
			);
			
		}
		dataList.add(
			new LPI_PDFSectionWrapper.DataWrapper('Business Email', String.valueOf(output.get('BusinessEmail')))
		);
		pdfWrapper.addSection(BUSINESS_INFORMATION_STEP, 3, dataList);
		SubSectionDataList = new List<LPI_PDFSectionWrapper.DataWrapper>();
		SubSectionDataList.add(
			new LPI_PDFSectionWrapper.DataWrapper(
				'Street Address',
				String.valueOf(output.get('BusinessStreetAddress'))
			)
		);
		SubSectionDataList.add(
			new LPI_PDFSectionWrapper.DataWrapper('City', String.valueOf(output.get('BusinessCity')))
		);
		if (output.containsKey('BusinessCountry') && String.valueOf(output.get('BusinessCountry')) == 'United States') {
			SubSectionDataList.add(
				new LPI_PDFSectionWrapper.DataWrapper('State', String.valueOf(output.get('BusinessState')))
			);
		} else {
			SubSectionDataList.add(
				new LPI_PDFSectionWrapper.DataWrapper(
					'State',
					String.valueOf(output.get('BusinessStateIfCountryIsNotUS'))
				)
			);
		}

		SubSectionDataList.add(
			new LPI_PDFSectionWrapper.DataWrapper('Zip Code', String.valueOf(output.get('BusinessZipcode')))
		);
		if (!PI_PFI_AGENCY_BRANCH_SET.contains(parRecord.Regulatory_Authorization_Type__r.Name)) {
			SubSectionDataList.add(
				new LPI_PDFSectionWrapper.DataWrapper('Country', String.valueOf(output.get('BusinessCountry')))
			);

			SubSectionDataList.add(
				new LPI_PDFSectionWrapper.DataWrapper('County', String.valueOf(output.get('BusinessCounty')))
			);
		}
		pdfWrapper.addSubSection(new LPI_PDFSectionWrapper('Business Address', 3, SubSectionDataList));
		pdfWrapper.addSubSection(
			new LPI_PDFSectionWrapper(
				'',
				1,
				new List<LPI_PDFSectionWrapper.DataWrapper>{
					new LPI_PDFSectionWrapper.DataWrapper(
						'Mailing address is the same as my current business address',
						String.valueOf(output.get('IsMailingAddressIsSameAsMyCurrentAddress')),
						'checkbox'
					)
				}
			)
		);
		SubSectionDataList = new List<LPI_PDFSectionWrapper.DataWrapper>();

		SubSectionDataList.add(
			new LPI_PDFSectionWrapper.DataWrapper(
				'Street Address',
				String.valueOf(output.get('MailingStreetAddress'))
			)
		);
		SubSectionDataList.add(
			new LPI_PDFSectionWrapper.DataWrapper('City', String.valueOf(output.get('MailingCity')))
		);

		if (
			output.containsKey('MailingCountryName') &&
			String.valueOf(output.get('MailingCountryName')) == 'United States'
		) {
			SubSectionDataList.add(
				new LPI_PDFSectionWrapper.DataWrapper('State', String.valueOf(output.get('MailingStateName')))
			);
		} else {
			SubSectionDataList.add(
				new LPI_PDFSectionWrapper.DataWrapper(
					'State',
					String.valueOf(output.get('MailingStateIfCountryIsNotUS'))
				)
			);
		}

		SubSectionDataList.add(
			new LPI_PDFSectionWrapper.DataWrapper('Zip Code', String.valueOf(output.get('MailingZipCode')))
		);
		if (!PI_PFI_AGENCY_BRANCH_SET.contains(parRecord.Regulatory_Authorization_Type__r.Name)) {
			SubSectionDataList.add(
				new LPI_PDFSectionWrapper.DataWrapper('Country', String.valueOf(output.get('MailingCountryName')))
			);

			if ((Boolean) output.get('IsMailingAddressIsSameAsMyCurrentAddress')) {
				SubSectionDataList.add(
					new LPI_PDFSectionWrapper.DataWrapper('County', String.valueOf(output.get('BusinessCounty')))
				);
			} else {
				SubSectionDataList.add(
					new LPI_PDFSectionWrapper.DataWrapper('County', String.valueOf(output.get('MailingCounty')))
				);
			}
		}

		pdfWrapper.addSubSection(new LPI_PDFSectionWrapper('Mailing Address', 3, SubSectionDataList));
		if (!PI_PFI_AGENCY_BRANCH_SET.contains(parRecord.Regulatory_Authorization_Type__r.Name)) {
			SubSectionDataList = new List<LPI_PDFSectionWrapper.DataWrapper>();
			SubSectionDataList.add(
				new LPI_PDFSectionWrapper.DataWrapper(
					'Address Type',
					addressApiNameMap.get(String.valueOf(output.get('BusinessInfoAddressTypePCA')))
				)
			);
			if (
				String.valueOf(output.get('BusinessInfoAddressTypePCA')) != 'Business Address' &&
				String.valueOf(output.get('BusinessInfoAddressTypePCA')) != 'Mailing'
			) {
				SubSectionDataList.add(
					new LPI_PDFSectionWrapper.DataWrapper(
						'Street Address',
						String.valueOf(output.get('PCAStreetAddress'))
					)
				);
				SubSectionDataList.add(
					new LPI_PDFSectionWrapper.DataWrapper('City', String.valueOf(output.get('PCACity')))
				);
				SubSectionDataList.add(
					new LPI_PDFSectionWrapper.DataWrapper('Country', String.valueOf(output.get('PCACountryName')))
				);
				SubSectionDataList.add(
					new LPI_PDFSectionWrapper.DataWrapper('Zip Code', String.valueOf(output.get('PCAZipCode')))
				);

				if (
					output.containsKey('PCACountryName') &&
					String.valueOf(output.get('PCACountryName')) == 'United States'
				) {
					SubSectionDataList.add(
						new LPI_PDFSectionWrapper.DataWrapper('State', String.valueOf(output.get('PCAStateName')))
					);
				} else {
					SubSectionDataList.add(
						new LPI_PDFSectionWrapper.DataWrapper('State', String.valueOf(output.get('PCAStateText')))
					);
				}
				SubSectionDataList.add(
					new LPI_PDFSectionWrapper.DataWrapper('County', String.valueOf(output.get('PCACounty')))
				);
			}

			pdfWrapper.addSubSection(new LPI_PDFSectionWrapper('Primary Contact Address', 3, SubSectionDataList));

			SubSectionDataList = new List<LPI_PDFSectionWrapper.DataWrapper>();
			SubSectionDataList.add(
				new LPI_PDFSectionWrapper.DataWrapper(
					'Address Type',
					String.valueOf(output.get('BusinessInfoAddressTypeLA'))
				)
			);
			if (parRecord.Board_Name__c != REAL_ESTATE_BOARD) {
				pdfWrapper.addSubSection(new LPI_PDFSectionWrapper('License Address', 3, SubSectionDataList));
			}
			String LPI_OwnerShipTypeAll = output.containsKey('LPI_OwnerShipTypeAll')
				? (String) output.get('LPI_OwnerShipTypeAll')
				: '';
			String LPI_OtherOwnershipType = output.containsKey('LPI_OtherOwnershipType')
				? (String) output.get('LPI_OtherOwnershipType')
				: '';
			SubSectionDataList = new List<LPI_PDFSectionWrapper.DataWrapper>();
			if (LPI_OwnerShipTypeAll == 'Other') {
				SubSectionDataList = new List<LPI_PDFSectionWrapper.DataWrapper>();
				SubSectionDataList.add(
					new LPI_PDFSectionWrapper.DataWrapper('Please specify', LPI_OtherOwnershipType)
				);
				pdfWrapper.addSubSection(new LPI_PDFSectionWrapper('', 1, SubSectionDataList));
			}
			if (
				output.get('HowAreYouAssociatedToThisEntity') != null &&
				!Boolean.valueOf(output.get('hideIdentifyYourRole'))
			) {
				SubSectionDataList = new List<LPI_PDFSectionWrapper.DataWrapper>();
				SubSectionDataList.add(
					new LPI_PDFSectionWrapper.DataWrapper(
						'Identify your role in submitting this application (Check Authorized Employee if you are a third-party initiating this application on behalf of a business entity and are not an officer, owner, or sole proprietor of the applicant, or do not hold a designated power of attorney authorizing you to submit a business application on the applicant’s behalf. (Note: If you are not a third-party person then choose "Not Applicable"))',
						getLabelFromRolesApiName(String.valueOf(output.get('HowAreYouAssociatedToThisEntity')))
					)
				);

				pdfWrapper.addSubSection(new LPI_PDFSectionWrapper('', 1, SubSectionDataList));
			}
		}

		return pdfWrapper;
	}

	/**
	 * @author                      : MTX Group Inc
	 * @since                       : march 27,2023
	 * @description                 : This method will give person Inchage Information Step
	 * @param parId                 : String
	 * @return                      : LPI_PDFSectionWrapper
	 * @last modified by            : Ayush Dev
	 * @last modified date          :
	 * @modified details            :
	 */
	public static LPI_PDFSectionWrapper getPersonInChargeInformationSection(PreliminaryApplicationRef parRecord) {
		if (parRecord == null) {
			return null;
		}
		LPI_PDFSectionWrapper schoolInformationSection;
		Map<String, Object> input = new Map<String, Object>();
		Map<String, Object> output = new Map<String, Object>();

		String parId = parRecord.Id;
		input.put('parId', parId);

		LPI_BusinessRelationshipDAO.LPI_BusinessRelationshipsWithoutSharingDAO acrQuery = new LPI_BusinessRelationshipDAO.LPI_BusinessRelationshipsWithoutSharingDAO();
		List<Business_Relationships__c> acr = acrQuery.getBusinessRelationshipsByDymanicQuery(
			'Id, Related_From__c, Is_Licensed_Entity__c',
			' Related_From__c =\'' +
				parRecord.BusinessAccountNameId +
				'\' AND Roles__c = \'' +
				PERSON_INCHARGE +
				'\' AND EndDate__c =null',
			'1',
			null,
			null
		);
		List<LPI_PDFSectionWrapper.DataWrapper> dataList = new List<LPI_PDFSectionWrapper.DataWrapper>();
		List<LPI_PDFSectionWrapper.DataWrapper> SubSectionDataList = new List<LPI_PDFSectionWrapper.DataWrapper>();
		LPI_PDFSectionWrapper personInChargeWrapper = new LPI_PDFSectionWrapper(
			PERSON_IN_CHARGE_INFORMATION_STEP,
			3,
			null
		);
		if (parRecord.type__c == AMENDMENT_TYPE && parRecord.Amendment_Type__c != REAL_ESTATE_BROKERAGE_SOLE_PROPRIETORSHIP_AMENDMENT_TYPE) {
			LPI_AmendmentDesignatedInchargeChange.fetchReviewInformation(input, output);
			SubSectionDataList.add(
				new LPI_PDFSectionWrapper.DataWrapper(
					'Person In Charge License Number',
					String.valueOf(output.get('FormerDesignatedInchargeLicenseNumber'))
				)
			);
			SubSectionDataList.add(
				new LPI_PDFSectionWrapper.DataWrapper(
					'First Name',
					String.valueOf(output.get('FormerDesignatedInchargeFirstName'))
				)
			);
			SubSectionDataList.add(
				new LPI_PDFSectionWrapper.DataWrapper(
					'Middle Name',
					String.valueOf(output.get('FormerDesignatedInchargeMiddleName'))
				)
			);
			SubSectionDataList.add(
				new LPI_PDFSectionWrapper.DataWrapper(
					'Last Name',
					String.valueOf(output.get('FormerDesignatedInchargeLastName'))
				)
			);
			if (output.get('IsFormerPICLicensedInMissouri') == 'No') {
				dataList.add(
					new LPI_PDFSectionWrapper.DataWrapper(
						'Date of Birth',
						Date.valueOf(output.get('FormerDesignatedInchargeDoB'))?.format()
					)
				);
			}
			SubSectionDataList.add(
				new LPI_PDFSectionWrapper.DataWrapper(
					'Phone Number',
					String.valueOf(output.get('FormerDesignatedInchargePhoneNumber'))
				)
			);
			SubSectionDataList.add(
				new LPI_PDFSectionWrapper.DataWrapper(
					'Email',
					String.valueOf(output.get('FormerDesignatedInchargeEmail'))
				)
			);
			SubSectionDataList.add(
				new LPI_PDFSectionWrapper.DataWrapper(
					'Street Address',
					String.valueOf(output.get('FormerDesignatedInchargeStreetAddress'))
				)
			);
			SubSectionDataList.add(
				new LPI_PDFSectionWrapper.DataWrapper(
					'City',
					String.valueOf(output.get('FormerDesignatedInchargeCity'))
				)
			);
			SubSectionDataList.add(
				new LPI_PDFSectionWrapper.DataWrapper(
					'Country',
					String.valueOf(output.get('FormerDesignatedInchargeCountry'))
				)
			);
			SubSectionDataList.add(
				new LPI_PDFSectionWrapper.DataWrapper(
					'State',
					String.valueOf(output.get('FormerDesignatedInchargeState'))
				)
			);
			SubSectionDataList.add(
				new LPI_PDFSectionWrapper.DataWrapper(
					'Zip Code',
					String.valueOf(output.get('FormerDesignatedInchargeZipCode'))
				)
			);
			SubSectionDataList.add(
				new LPI_PDFSectionWrapper.DataWrapper(
					'County',
					String.valueOf(output.get('FormerDesignatedInchargeCounty'))
				)
			);
			personInChargeWrapper.addSubSection(
				new LPI_PDFSectionWrapper('Former Person In Charge Details', 3, SubSectionDataList)
			);
			if (
				output.containsKey('IsTheNewPICLicensedInMissouri') &&
				output.get('IsTheNewPICLicensedInMissouri') == 'Yes'
			) {
				subSectionDataList = new List<LPI_PDFSectionWrapper.DataWrapper>();
				subSectionDataList.add(
					new LPI_PDFSectionWrapper.DataWrapper(
						'Is the Person In Charge licensed in Missouri?',
						String.valueOf(output.get('IsTheNewPICLicensedInMissouri'))
					)
				);
				subSectionDataList.add(
					new LPI_PDFSectionWrapper.DataWrapper(
						'Person In Charge License Number',
						String.valueOf(output.get('NewDesignatedInchargeLicenseNumber'))
					)
				);
				subSectionDataList.add(
					new LPI_PDFSectionWrapper.DataWrapper(
						'First Name',
						String.valueOf(output.get('NewDesignatedInchargeFirstName'))
					)
				);
				subSectionDataList.add(
					new LPI_PDFSectionWrapper.DataWrapper(
						'Middle Name',
						String.valueOf(output.get('NewDesignatedInchargeMiddleName'))
					)
				);
				subSectionDataList.add(
					new LPI_PDFSectionWrapper.DataWrapper(
						'Last Name',
						String.valueOf(output.get('NewDesignatedInchargeLastName'))
					)
				);
				subSectionDataList.add(
					new LPI_PDFSectionWrapper.DataWrapper(
						'Phone Number',
						String.valueOf(output.get('NewDesignatedInchargePhoneNumber'))
					)
				);
				subSectionDataList.add(
					new LPI_PDFSectionWrapper.DataWrapper(
						'Email',
						String.valueOf(output.get('NewDesignatedInchargeEmail'))
					)
				);
				subSectionDataList.add(
					new LPI_PDFSectionWrapper.DataWrapper(
						'Street Address',
						String.valueOf(output.get('NewDesignatedInchargeStreetAddress'))
					)
				);
				subSectionDataList.add(
					new LPI_PDFSectionWrapper.DataWrapper(
						'City',
						String.valueOf(output.get('NewDesignatedInchargeCity'))
					)
				);
				subSectionDataList.add(
					new LPI_PDFSectionWrapper.DataWrapper(
						'Country',
						String.valueOf(output.get('NewDesignatedInchargeCountry'))
					)
				);
				subSectionDataList.add(
					new LPI_PDFSectionWrapper.DataWrapper(
						'State',
						String.valueOf(output.get('NewDesignatedInchargeState'))
					)
				);
				subSectionDataList.add(
					new LPI_PDFSectionWrapper.DataWrapper(
						'Zip Code',
						String.valueOf(output.get('NewDesignatedInchargeZipCode'))
					)
				);
				subSectionDataList.add(
					new LPI_PDFSectionWrapper.DataWrapper(
						'County',
						String.valueOf(output.get('NewDesignatedInchargeCounty'))
					)
				);
				subSectionDataList.add(
					new LPI_PDFSectionWrapper.DataWrapper(
						'Effective Date of Person In Charge Change',
						Date.valueOf(output.get('EffectiveDateofInchargeChange'))?.format()
					)
				);
				personInChargeWrapper.addSubSection(
					new LPI_PDFSectionWrapper('New Person In Charge Details', 3, subSectionDataList)
				);
			} else {
				subSectionDataList = new List<LPI_PDFSectionWrapper.DataWrapper>();
				subSectionDataList.add(
					new LPI_PDFSectionWrapper.DataWrapper(
						'Is the Person In Charge licensed in Missouri?',
						String.valueOf(output.get('IsTheNewPICLicensedInMissouri'))
					)
				);
				subSectionDataList.add(
					new LPI_PDFSectionWrapper.DataWrapper(
						'Person In Charge License Number',
						String.valueOf(output.get('UnlicensedNewDesignatedInchargeLicenseNumber'))
					)
				);
				subSectionDataList.add(
					new LPI_PDFSectionWrapper.DataWrapper(
						'First Name',
						String.valueOf(output.get('UnlicensedNewDesignatedInchargeFirstName'))
					)
				);
				subSectionDataList.add(
					new LPI_PDFSectionWrapper.DataWrapper(
						'Middle Name',
						String.valueOf(output.get('UnlicensedNewDesignatedInchargeMiddleName'))
					)
				);
				subSectionDataList.add(
					new LPI_PDFSectionWrapper.DataWrapper(
						'Last Name',
						String.valueOf(output.get('UnlicensedNewDesignatedInchargeLastName'))
					)
				);
				subSectionDataList.add(
					new LPI_PDFSectionWrapper.DataWrapper(
						'Date of Birth',
						Date.valueOf(output.get('UnlicensedNewDesignatedInchargeDoB'))?.format()
					)
				);
				subSectionDataList.add(
					new LPI_PDFSectionWrapper.DataWrapper(
						'SSN',
						String.valueOf(output.get('UnlicensedNewDesignatedInchargeSSN'))
					)
				);
				subSectionDataList.add(
					new LPI_PDFSectionWrapper.DataWrapper(
						'Phone Number',
						String.valueOf(output.get('UnlicensedNewDesignatedInchargePhoneNumber'))
					)
				);
				subSectionDataList.add(
					new LPI_PDFSectionWrapper.DataWrapper(
						'Email',
						String.valueOf(output.get('UnlicensedNewDesignatedInchargeEmail'))
					)
				);
				subSectionDataList.add(
					new LPI_PDFSectionWrapper.DataWrapper(
						'Street Address',
						String.valueOf(output.get('UnlicensedNewDesignatedInchargeStreetAddress'))
					)
				);
				subSectionDataList.add(
					new LPI_PDFSectionWrapper.DataWrapper(
						'City',
						String.valueOf(output.get('UnlicensedNewDesignatedInchargeCity'))
					)
				);
				subSectionDataList.add(
					new LPI_PDFSectionWrapper.DataWrapper(
						'Country',
						String.valueOf(output.get('UnlicensedNewDesignatedInchargeCountryFC'))
					)
				);
				if (output.get('UnlicensedNewDesignatedInchargeCountryFC') == 'United States') {
					subSectionDataList.add(
						new LPI_PDFSectionWrapper.DataWrapper(
							'State',
							String.valueOf(output.get('UnlicensedNewDesignatedInchargeStateFC'))
						)
					);
				} else {
					subSectionDataList.add(
						new LPI_PDFSectionWrapper.DataWrapper(
							'State',
							String.valueOf(output.get('UnlicensedNewDesignatedInchargeNonUSState'))
						)
					);
				}
				subSectionDataList.add(
					new LPI_PDFSectionWrapper.DataWrapper(
						'Zip Code',
						String.valueOf(output.get('UnlicensedNewDesignatedInchargeZipCode'))
					)
				);
				subSectionDataList.add(
					new LPI_PDFSectionWrapper.DataWrapper(
						'County',
						String.valueOf(output.get('UnlicensedNewDesignatedInchargeCounty'))
					)
				);
				subSectionDataList.add(
					new LPI_PDFSectionWrapper.DataWrapper(
						'Effective Date of Person In Charge Change',
						Date.valueOf(output.get('EffectiveDateofInchargeChange'))?.format()
					)
				);
				personInChargeWrapper.addSubSection(
					new LPI_PDFSectionWrapper('New Person In Charge Details', 3, subSectionDataList)
				);
			}
		} else {
			LPI_DesignatedInchargeController.fetchPICDetailsFC(input, output);
			if (output.containsKey('flag') && Boolean.valueOf(output.get('flag')) == true) {
				if (
					parRecord.Regulatory_Authorization_Type__r.IssuingDepartment.Name == 'Embalmers & Funeral Directors'
				) {
					dataList.add(
						new LPI_PDFSectionWrapper.DataWrapper(
							'Funeral Director In Charge License Number',
							String.valueOf(output.get('LicNo'))
						)
					);
				} else {
					dataList.add(
						new LPI_PDFSectionWrapper.DataWrapper(
							'Person In Charge License Number',
							String.valueOf(output.get('LicNo'))
						)
					);
				}

				dataList.add(
					new LPI_PDFSectionWrapper.DataWrapper(
						'First Name',
						String.valueOf(output.get('DesignatedInchargeFirstName'))
					)
				);
				dataList.add(
					new LPI_PDFSectionWrapper.DataWrapper(
						'Middle Name',
						String.valueOf(output.get('DesignatedInchargeMiddleName'))
					)
				);
				dataList.add(
					new LPI_PDFSectionWrapper.DataWrapper(
						'Last Name',
						String.valueOf(output.get('DesignatedInchargeLastName'))
					)
				);
				if (
					output.get('IsThePersonInChargeLicensedinMissouriPIPFI') == 'No' ||
					output.get('IsThePersonInChargeLicensedinMissouri') == 'No'
				) {
					dataList.add(
						new LPI_PDFSectionWrapper.DataWrapper(
							'Date of Birth',
							Date.valueOf(output.get('DesignatedInchargeDOB'))?.format()
						)
					);
					dataList.add(
						new LPI_PDFSectionWrapper.DataWrapper(
							'SSN',
							String.valueOf(output.get('DesignatedInchargeSSN'))
						)
					);
				}
				if(parRecord.Regulatory_Authorization_Type__r.IssuingDepartment.Name !=
					'Embalmers & Funeral Directors'){
					dataList.add(
						new LPI_PDFSectionWrapper.DataWrapper(
							'Phone Number',
							String.valueOf(output.get('DesignatedInchargePhoneNumber'))
						)
					);
					dataList.add(
						new LPI_PDFSectionWrapper.DataWrapper(
							'Email',
							String.valueOf(output.get('DesignatedInchargeEmail'))
						)
					);

				}
			}
		}

		if (
			parRecord.Type__c == PARTYPE_NEW ||
			parRecord.Type__c == APPLICATION_TYPE_RENEWAL ||
			parRecord.Type__c == CHANGE_OF_OWNERSHIP ||
			parRecord.Type__c == 'Reinstatement' || 
			(parRecord.Type__c == AMENDMENT_TYPE && parRecord.Amendment_Type__c == REAL_ESTATE_BROKERAGE_SOLE_PROPRIETORSHIP_AMENDMENT_TYPE)
		) {
			personInChargeWrapper = new LPI_PDFSectionWrapper(PERSON_IN_CHARGE_INFORMATION_STEP, 3, dataList);
			if (!acr.isEmpty() && acr[0].Is_Licensed_Entity__c != null) {
				subSectionDataList.add(
					new LPI_PDFSectionWrapper.DataWrapper(
						'Street Address',
						String.valueOf(output.get('DesignatedInchargeStreetAddress'))
					)
				);
				subSectionDataList.add(
					new LPI_PDFSectionWrapper.DataWrapper(
						'City',
						String.valueOf(output.get('DesignatedInchargeCity'))
					)
				);
				subSectionDataList.add(
					new LPI_PDFSectionWrapper.DataWrapper(
						'Country',
						String.valueOf(output.get('DesignatedInchargeCountryFC'))
					)
				);
				subSectionDataList.add(
					new LPI_PDFSectionWrapper.DataWrapper(
						'State',
						String.valueOf(output.get('DesignatedInchargeUSStateFC'))
					)
				);
				subSectionDataList.add(
					new LPI_PDFSectionWrapper.DataWrapper(
						'Zip Code',
						String.valueOf(output.get('DesignatedInchargeUSZipCode'))
					)
				);
				subSectionDataList.add(
					new LPI_PDFSectionWrapper.DataWrapper(
						'County',
						String.valueOf(output.get('DesignatedInchargeCounty'))
					)
				);
				if (parRecord.Regulatory_Authorization_Type__r.IssuingDepartment.Name == APEP_BOARD_NAME) {
					subSectionDataList.add(
						new LPI_PDFSectionWrapper.DataWrapper(
							'Employment Status (Check all boxes that apply. At least one box must be checked.)',
							String.valueOf(output.get('EmploymentStatusCorporation'))
						)
					);
				}
				personInChargeWrapper.addSubSection(
					new LPI_PDFSectionWrapper('Mailing Address', 3, subSectionDataList)
				);
			}
		}
		return personInChargeWrapper;
	}

	/**
	 * @author                      : MTX Group Inc
	 * @since                       : march 27,2023
	 * @description                 : This method will give Audit Escrow Trust Account section
	 * @param parRecord             : PreliminaryApplicationRef
	 * @return                      : LPI_PDFSectionWrapper
	 * @last modified by            : Ayush Dev
	 * @last modified date          :
	 * @modified details            :
	 */
	public static LPI_PDFSectionWrapper getAuditEscrowTrustAccount(PreliminaryApplicationRef parRecord) {
		LPI_PDFSectionWrapper bankAccountSection = new LPI_PDFSectionWrapper(
			AUDIT_ESCROW_TRUST_ACCOUNT_STEP,
			3,
			null
		);
		if (parRecord.Type__c != 'Amendment') {
			LPI_OSStepParser osParserAuditLQ = new LPI_OSStepParser(
				'AuditEscrowOrTrustAccountLicenseQuestionsBlock',
				true
			);
			bankAccountSection.addSubSection(
				osParserAuditLQ.getPDFSectionWrapper(
					parRecord.Audit_Escrow_or_Trust_Account_Questions__c,
					'License Questions'
				)
			);
			bankAccountSection.addSubSection(getBankAccountDetailsSection(parRecord.Id));
			if (parRecord.Type__c != PARTYPE_NEW) {
				bankAccountSection.addSubSection(getChangeInBankAccountSection(parRecord.Id));
			}
			bankAccountSection.addSubSection(getAccountClosedSection(parRecord.Id));
		} else {
			LPI_OSStepParser osParser = new LPI_OSStepParser('AuditEscrowOrTrustAccountQuestions');
			return osParser.getPDFSectionWrapper(
				parRecord.Audit_Escrow_or_Trust_Account_Questions__c,
				AUDIT_ESCROW_TRUST_ACCOUNT_STEP
			);
		}
		return bankAccountSection;
	}

	/**
	 * @author                      : MTX Group Inc
	 * @since                       : march 28,2023
	 * @description                 : This method will give bank account detail section
	 * @param parId                 : String
	 * @last modified by            : Ayush Dev
	 * @last modified date          :
	 * @modified details            :
	 */
	public static LPI_PDFSectionWrapper getBankAccountDetailsSection(String parId) {
		LPI_PDFSectionWrapper bankAccountSection = new LPI_PDFSectionWrapper('Bank Account', 3, null);
		Map<String, Object> input = new Map<String, Object>();
		Map<String, Object> output = new Map<String, Object>();
		input.put('parId', parId);
		LPI_AuditEscrowController.fetchAuditEscrowBankAccountDetails(input, output);
		if (output.containsKey('BankAccInfoList')) {
			Map<String, String> fieldAPIToLabelMap = new Map<String, String>{
				'NameOfFinancialInstitution' => 'Name of Financial Institution',
				'City' => 'City',
				'State' => 'State',
				'BankAccountNumber' => 'Account number',
				'TypeOfAccount' => 'Type of Account',
				'OtherAccountType' => 'Other Account Type'
			};
			Integer counter = 1;
			for (Map<String, Object> bankAccDetail : (List<Map<String, Object>>) output.get('BankAccInfoList')) {
				List<LPI_PDFSectionWrapper.DataWrapper> dataList = new List<LPI_PDFSectionWrapper.DataWrapper>();
				for (String fieldAPI : fieldAPIToLabelMap.keySet()) {
					if (bankAccDetail.containsKey(fieldAPI)) {
						dataList.add(
							new LPI_PDFSectionWrapper.DataWrapper(
								fieldAPIToLabelMap.get(fieldAPI),
								String.valueOf(bankAccDetail.get(fieldAPI))
							)
						);
					}
				}
				bankAccountSection.addSubSection(
					new LPI_PDFSectionWrapper('Bank Account ' + counter, 3, dataList, true)
				);
				counter += 1;
			}
		}

		return bankAccountSection;
	}

	/**
	 * @author                      : MTX Group Inc
	 * @since                       : march 28,2023
	 * @description                 : This method will give changed bank account detail section
	 * @param parId                 : String
	 * @last modified by            : Ayush Dev
	 * @last modified date          :
	 * @modified details            :
	 */
	public static LPI_PDFSectionWrapper getChangeInBankAccountSection(String parId) {
		LPI_PDFSectionWrapper changeInBankAccountSection = new LPI_PDFSectionWrapper(
			'Change in Bank Account',
			3,
			null
		);
		Map<String, Object> input = new Map<String, Object>();
		Map<String, Object> output = new Map<String, Object>();
		input.put('parId', parId);
		LPI_AuditEscrowController.fetchAuditChangeInBankAccountDetails(input, output);
		if (output.containsKey('ChangeInBankAccInfoList')) {
			Integer counter = 1;
			for (
				Map<String, Object> chanageAccDetail : (List<Map<String, Object>>) output.get('ChangeInBankAccInfoList')
			) {
				if (
					chanageAccDetail.containsKey('isChangeInBankAccDataFoundReview') &&
					!Boolean.valueOf(chanageAccDetail.get('isChangeInBankAccDataFoundReview'))
				) {
					break;
				}
				Map<String, String> fieldAPIToLabelMapForPrev = new Map<String, String>{
					'ChangeBankAccFromNameOfFinancialInstitution' => 'From : Name of Financial Institution',
					'ChangeBankAccFromCity' => 'City',
					'ChangeBankAccFromState' => 'State',
					'ChangeBankAccFromAccountNumber' => 'Account number',
					'ChangeBankAccTypeOfAccount' => 'Type of Account',
					'ChangeBankAccFromOtherAccountType' => 'Other Account Type'
				};
				Map<String, String> fieldAPIToLabelMapforNew = new Map<String, String>{
					'ToChangeBankAccNameOfFinancialInstitution' => 'To : Name of Financial Institution',
					'ToChangeBankAccCity' => 'City',
					'ToChangeBankAccState' => 'State',
					'ToChangeBankAccAccountNumber' => 'Account number',
					'ToChangeBankAccTypeOfAccount' => 'Type of Account',
					'ToChangeBankAccOtherAccountType' => 'Other Account Type'
				};
				List<LPI_PDFSectionWrapper.DataWrapper> preDetailDataList = new List<LPI_PDFSectionWrapper.DataWrapper>();
				List<LPI_PDFSectionWrapper.DataWrapper> newDetailDataList = new List<LPI_PDFSectionWrapper.DataWrapper>();
				for (String fieldAPI : fieldAPIToLabelMapForPrev.keySet()) {
					if (chanageAccDetail.containsKey(fieldAPI)) {
						preDetailDataList.add(
							new LPI_PDFSectionWrapper.DataWrapper(
								fieldAPIToLabelMapForPrev.get(fieldAPI),
								String.valueOf(chanageAccDetail.get(fieldAPI))
							)
						);
					}
				}
				for (String fieldAPI : fieldAPIToLabelMapforNew.keySet()) {
					if (chanageAccDetail.containsKey(fieldAPI)) {
						newDetailDataList.add(
							new LPI_PDFSectionWrapper.DataWrapper(
								fieldAPIToLabelMapforNew.get(fieldAPI),
								String.valueOf(chanageAccDetail.get(fieldAPI))
							)
						);
					}
				}
				LPI_PDFSectionWrapper changeInBankAccount = new LPI_PDFSectionWrapper(
					'Change in Bank Account ' + counter,
					3,
					null,
					true
				);
				changeInBankAccount.addSubSection(new LPI_PDFSectionWrapper('', 3, preDetailDataList));
				changeInBankAccount.addSubSection(new LPI_PDFSectionWrapper('', 3, newDetailDataList));
				changeInBankAccountSection.addSubSection(changeInBankAccount);
				counter += 1;
			}
		}

		return changeInBankAccountSection;
	}

	/**
	 * @author                      : MTX Group Inc
	 * @since                       : march 28,2023
	 * @description                 : This method will give closed bank account detail section
	 * @param parId                 : String
	 * @last modified by            : Ayush Dev
	 * @last modified date          :
	 * @modified details            :
	 */
	public static LPI_PDFSectionWrapper getAccountClosedSection(String parId) {
		LPI_PDFSectionWrapper changeInBankAccountSection = new LPI_PDFSectionWrapper('Account Closed', 3, null);
		Map<String, Object> input = new Map<String, Object>();
		Map<String, Object> output = new Map<String, Object>();
		input.put('parId', parId);
		LPI_AuditEscrowController.fetchAuditEscrowClosedBankAccountDetails(input, output);
		if (output.containsKey('closedBankAccInfoList')) {
			Integer counter = 1;
			for (Map<String, Object> closedAccount : (List<Map<String, Object>>) output.get('closedBankAccInfoList')) {
				List<LPI_PDFSectionWrapper.DataWrapper> dataList = new List<LPI_PDFSectionWrapper.DataWrapper>();
				dataList.add(
					new LPI_PDFSectionWrapper.DataWrapper(
						'Name of Financial Institution',
						String.valueOf(closedAccount.get('AccountClosedNameOfFinancialInstitution'))
					)
				);
				dataList.add(
					new LPI_PDFSectionWrapper.DataWrapper(
						'Account Number',
						String.valueOf(closedAccount.get('accountsClosedAccountNumber'))
					)
				);
				dataList.add(
					new LPI_PDFSectionWrapper.DataWrapper(
						'Date Closed',
						Date.valueOf(closedAccount.get('dateClosed'))?.format()
					)
				);
				changeInBankAccountSection.addSubSection(
					new LPI_PDFSectionWrapper('Account Closed ' + counter, 3, dataList, true)
				);
				counter += 1;
			}
		}
		return changeInBankAccountSection;
	}

	/**
	 * @author                      : MTX Group Inc
	 * @since                       : march 29,2023
	 * @description                 : This method will give Tax Compliance Section Details
	 * @param parRecord             : PreliminaryApplicationRef
	 * @return                      : LPI_PDFSectionWrapper
	 * @last modified by            : Ayush Dev
	 * @last modified date          :
	 * @modified details            :
	 */
	public static LPI_PDFSectionWrapper getTaxComplianceSection(PreliminaryApplicationRef parRecord) {
		LPI_OSStepParser osParser = new LPI_OSStepParser('IndividualTaxCompliance', parRecord);
		return osParser.getPDFSectionWrapper(parRecord.Tax_Compliance__c, TAX_COMPLIANCE_STEP);
	}

	/**
	 * @author                      : MTX Group Inc
	 * @since                       : march 27,2023
	 * @description                 : This is a method to get Ownership Info
	 * @param parRecord             : PreliminaryApplicationRef
	 * @return                      : LPI_PDFSectionWrapper
	 */
	public static LPI_PDFSectionWrapper getOwnershipInformation(PreliminaryApplicationRef parRecord) {
		Map<String, Object> input = new Map<String, Object>();
		Map<String, Object> outputData = new Map<String, Object>();
		input.put('parId', parRecord.Id);
		outputData.put(
			'ownershipInformationWrap',
			LPI_OwnershipInformationController.loadOwnerShipInformation(input)
		);
		List<LPI_PDFSectionWrapper.DataWrapper> dataList = new List<LPI_PDFSectionWrapper.DataWrapper>();
		LPI_PDFSectionWrapper ownerInfoSection = new LPI_PDFSectionWrapper();
		if (parRecord.Board_Name__c == EMBALMERS_AND_FUNERAL_DIRECTORS_BOARD_NAME) {
			ownerInfoSection = new LPI_PDFSectionWrapper(OFFICERS_MEMBERS_PARTNERS_STEP, 3, dataList);
		} else {
			ownerInfoSection = new LPI_PDFSectionWrapper(OWNERSHIP_INFORMATION_STEP, 3, dataList);
		}

		if (outputData.containsKey('ownershipInformationWrap')) {
			Integer counter = 1;

			Map<String, Object> ownerMapData = (Map<String, Object>) JSON.deserializeUntyped(
				JSON.serialize(LPI_OwnershipInformationController.loadOwnerShipInformation(input))
			);
			for (
				Object ownerInformationData : (List<Object>) JSON.deserializeUntyped(
					JSON.serialize(ownerMapData.get('ownerInformation'))
				)
			) {
				Map<String, Object> ownerInformation = (Map<String, Object>) ownerInformationData;
				List<LPI_PDFSectionWrapper.DataWrapper> subSectionDataList = new List<LPI_PDFSectionWrapper.DataWrapper>();
				if (String.isNotEmpty(String.valueOf(ownerInformation.get('isBusinessEntityData')))) {
					subSectionDataList.add(
						new LPI_PDFSectionWrapper.DataWrapper(
							'Is the Owner/Partner/Member a Business Entity?',
							String.valueOf(ownerInformation.get('isBusinessEntityData'))
						)
					);
				}

				ownerInfoSection.addSubSection(
					new LPI_PDFSectionWrapper('Ownership Information ' + counter, 1, subSectionDataList)
				);
				counter += 1;
				subSectionDataList = new List<LPI_PDFSectionWrapper.DataWrapper>();

				if ((Boolean) ownerInformation.get('isBusinessOwner')) {
					if (!(Boolean) ownerInformation.get('isCorporateOwnerShip')) {
						if (ownerInformation.get('boardName') != 'Real Estate') {
							if (ownerInformation.get('boardName') != 'Tattooing, Body Piercing & Branding') {
								subSectionDataList.add(
									new LPI_PDFSectionWrapper.DataWrapper(
										'Is the Entity Licenses in Missouri by the Board?',
										String.valueOf(ownerInformation.get('isTheOwnerLicensedInMO'))
									)
								);
								subSectionDataList.add(
									new LPI_PDFSectionWrapper.DataWrapper(
										'Board License Number',
										String.valueOf(ownerInformation.get('isTheOwnerLicensedInMO')) == 'Yes'
											? String.valueOf(ownerInformation.get('searchedKey'))
											: String.valueOf(ownerInformation.get('licenseNumber'))
									)
								);
							}
						} else if (ownerInformation.get('boardName') == 'Real Estate') {
							subSectionDataList.add(
								new LPI_PDFSectionWrapper.DataWrapper(
									'Is the Entity Licenses in Missouri by the State Commission?',
									String.valueOf(ownerInformation.get('isTheOwnerLicensedInMO'))
								)
							);
							subSectionDataList.add(
								new LPI_PDFSectionWrapper.DataWrapper(
									'State Commission License Number',
									String.valueOf(ownerInformation.get('isTheOwnerLicensedInMO')) == 'Yes'
										? String.valueOf(ownerInformation.get('searchedKey'))
										: String.valueOf(ownerInformation.get('licenseNumber'))
								)
							);
						}
						ownerInfoSection.addSubSection(new LPI_PDFSectionWrapper('', 1, subSectionDataList));
						subSectionDataList = new List<LPI_PDFSectionWrapper.DataWrapper>();
					}
					subSectionDataList.add(
						new LPI_PDFSectionWrapper.DataWrapper(
							'Business Name',
							String.valueOf(ownerInformation.get('businessName'))
						)
					);
					subSectionDataList.add(
						new LPI_PDFSectionWrapper.DataWrapper(
							'Business Email',
							String.valueOf(ownerInformation.get('businessEmail'))
						)
					);
					subSectionDataList.add(
						new LPI_PDFSectionWrapper.DataWrapper(
							'Telephone Number',
							String.valueOf(ownerInformation.get('busienssPhone'))
						)
					);
					if (
						ownerInformation.get('ownershipPercent') != '' &&
						ownerInformation.get('ownershipPercent') != null
					) {
						subSectionDataList.add(
							new LPI_PDFSectionWrapper.DataWrapper(
								'Ownership Percentage',
								String.valueOf(ownerInformation.get('ownershipPercent')) + '%'
							)
						);
					} else {
						subSectionDataList.add(
							new LPI_PDFSectionWrapper.DataWrapper(
								'Ownership Percentage',
								String.valueOf(ownerInformation.get('ownershipPercent'))
							)
						);
					}
				} else {
					if (String.isNotEmpty(String.valueOf(ownerInformation.get('isTheOwnerLicensedInMO')))) {
						if (ownerInformation.get('boardName') != 'Real Estate') {
							if (ownerInformation.get('boardName') != 'Tattooing, Body Piercing & Branding') {
								subSectionDataList.add(
									new LPI_PDFSectionWrapper.DataWrapper(
										'Is the Owner/Partner/Member licensed with the Board?',
										String.valueOf(ownerInformation.get('isTheOwnerLicensedInMO'))
									)
								);
								subSectionDataList.add(
									new LPI_PDFSectionWrapper.DataWrapper(
										'Board License Number',
										String.valueOf(ownerInformation.get('isTheOwnerLicensedInMO')) == 'Yes'
											? String.valueOf(ownerInformation.get('searchedKey'))
											: String.valueOf(ownerInformation.get('licenseNumber'))
									)
								);
							}
						} else if (ownerInformation.get('boardName') == 'Real Estate') {
							subSectionDataList.add(
								new LPI_PDFSectionWrapper.DataWrapper(
									'Is the Owner/Partner/Member licensed with the State Commission?',
									String.valueOf(ownerInformation.get('isTheOwnerLicensedInMO'))
								)
							);
							subSectionDataList.add(
								new LPI_PDFSectionWrapper.DataWrapper(
									'State Commission License Number',
									String.valueOf(ownerInformation.get('isTheOwnerLicensedInMO')) == 'Yes'
										? String.valueOf(ownerInformation.get('searchedKey'))
										: String.valueOf(ownerInformation.get('licenseNumber'))
								)
							);
						}
						ownerInfoSection.addSubSection(new LPI_PDFSectionWrapper('', 1, subSectionDataList));
						subSectionDataList = new List<LPI_PDFSectionWrapper.DataWrapper>();
					}
					subSectionDataList.add(
						new LPI_PDFSectionWrapper.DataWrapper(
							'First Name',
							String.valueOf(ownerInformation.get('firstName'))
						)
					);
					subSectionDataList.add(
						new LPI_PDFSectionWrapper.DataWrapper(
							'Middle Name',
							String.valueOf(ownerInformation.get('middleName'))
						)
					);
					subSectionDataList.add(
						new LPI_PDFSectionWrapper.DataWrapper(
							'Last Name',
							String.valueOf(ownerInformation.get('lastName'))
						)
					);
					subSectionDataList.add(
						new LPI_PDFSectionWrapper.DataWrapper('Email', String.valueOf(ownerInformation.get('email')))
					);
					if (String.valueOf(ownerInformation.get('isTheOwnerLicensedInMO')) == 'No') {
						subSectionDataList.add(
							new LPI_PDFSectionWrapper.DataWrapper('SSN', String.valueOf(ownerInformation.get('SSN')))
						);
					}
					subSectionDataList.add(
						new LPI_PDFSectionWrapper.DataWrapper('Title', String.valueOf(ownerInformation.get('title')))
					);
					if (
						ownerInformation.get('ownershipPercent') != '' &&
						ownerInformation.get('ownershipPercent') != null
					) {
						subSectionDataList.add(
							new LPI_PDFSectionWrapper.DataWrapper(
								'Ownership Percentage',
								String.valueOf(ownerInformation.get('ownershipPercent')) + '%'
							)
						);
					} else {
						subSectionDataList.add(
							new LPI_PDFSectionWrapper.DataWrapper(
								'Ownership Percentage',
								String.valueOf(ownerInformation.get('ownershipPercent'))
							)
						);
					}
				}
				ownerInfoSection.addSubSection(new LPI_PDFSectionWrapper('', 3, subSectionDataList));
				subSectionDataList = new List<LPI_PDFSectionWrapper.DataWrapper>();

				if ((Boolean) ownerInformation.get('isBusinessOwner')) {
					subSectionDataList.add(new LPI_PDFSectionWrapper.DataWrapper('', 'Business Address'));
				} else {
					subSectionDataList.add(new LPI_PDFSectionWrapper.DataWrapper('', 'Residence Address'));
				}
				ownerInfoSection.addSubSection(new LPI_PDFSectionWrapper('', 1, subSectionDataList));
				subSectionDataList = new List<LPI_PDFSectionWrapper.DataWrapper>();

				subSectionDataList.add(
					new LPI_PDFSectionWrapper.DataWrapper(
						'Street Address',
						String.valueOf(ownerInformation.get('streetAddress1'))
					)
				);
				subSectionDataList.add(
					new LPI_PDFSectionWrapper.DataWrapper('City', String.valueOf(ownerInformation.get('city')))
				);

				if ((Boolean) ownerInformation.get('isUsState')) {
					subSectionDataList.add(
						new LPI_PDFSectionWrapper.DataWrapper(
							'State',
							String.valueOf(ownerInformation.get('stateValue'))
						)
					);
				} else {
					subSectionDataList.add(
						new LPI_PDFSectionWrapper.DataWrapper(
							'State',
							String.valueOf(ownerInformation.get('stateText'))
						)
					);
				}
				subSectionDataList.add(
					new LPI_PDFSectionWrapper.DataWrapper(
						'Country',
						String.valueOf(ownerInformation.get('countryValue'))
					)
				);
				subSectionDataList.add(
					new LPI_PDFSectionWrapper.DataWrapper('Zip Code', String.valueOf(ownerInformation.get('zipCode')))
				);
				subSectionDataList.add(
					new LPI_PDFSectionWrapper.DataWrapper('County', String.valueOf(ownerInformation.get('county')))
				);
				ownerInfoSection.addSubSection(new LPI_PDFSectionWrapper('', 3, subSectionDataList));
			}
		}
		return ownerInfoSection;
	}
	/**
	 * @author                      : MTX Group Inc
	 * @since                       : 15 July,2023
	 * @description                 : This is a method to get Ownership Info
	 * @param parRecord             : PreliminaryApplicationRef
	 * @return                      : LPI_PDFSectionWrapper
	 */
	public static LPI_PDFSectionWrapper getCorporateOfficerInfo(PreliminaryApplicationRef parRecord) {
		Map<String, Object> input = new Map<String, Object>();
		Map<String, Object> output = new Map<String, Object>();
		input.put('parid', parRecord.Id);
		LPI_CorporateOfficerController.extractCorporateOfficers(input, output);
		List<LPI_PDFSectionWrapper.DataWrapper> dataList = new List<LPI_PDFSectionWrapper.DataWrapper>();
		LPI_PDFSectionWrapper ownerInfoSection = new LPI_PDFSectionWrapper(
			CORPORATE_OFFICER_INFO_STEP,
			3,
			dataList
		);

		if (Output.containsKey('Co_CorporateOfficerDataEB')) {
			Integer counter = 1;

			for (
				Map<String, Object> ownerInformation : (List<Map<String, Object>>) Output.get(
					'Co_CorporateOfficerDataEB'
				)
			) {
				List<LPI_PDFSectionWrapper.DataWrapper> subSectionDataList = new List<LPI_PDFSectionWrapper.DataWrapper>();
				subSectionDataList.add(
					new LPI_PDFSectionWrapper.DataWrapper(
						'Role/Title',
						String.valueOf(ownerInformation.get('CO_Role'))
					)
				);
				ownerInfoSection.addSubSection(
					new LPI_PDFSectionWrapper('Corporate Officer ' + counter, 1, subSectionDataList)
				);
				subSectionDataList = new List<LPI_PDFSectionWrapper.DataWrapper>();

				subSectionDataList.add(
					new LPI_PDFSectionWrapper.DataWrapper(
						'First Name',
						String.valueOf(ownerInformation.get('CO_FirstName'))
					)
				);
				subSectionDataList.add(
					new LPI_PDFSectionWrapper.DataWrapper(
						'Middle Name',
						String.valueOf(ownerInformation.get('CO_MiddleName'))
					)
				);
				subSectionDataList.add(
					new LPI_PDFSectionWrapper.DataWrapper(
						'Last Name',
						String.valueOf(ownerInformation.get('CO_LastName'))
					)
				);
				if (parRecord.Board_Name__c != 'Pharmacy') {
					subSectionDataList.add(
						new LPI_PDFSectionWrapper.DataWrapper(
							'Email',
							String.valueOf(ownerInformation.get('CO_Email'))
						)
					);
					subSectionDataList.add(
						new LPI_PDFSectionWrapper.DataWrapper('SSN', String.valueOf(ownerInformation.get('CO_SSN')))
					);
				}
				subSectionDataList.add(
					new LPI_PDFSectionWrapper.DataWrapper(
						'Date of Birth',
						Date.valueOf(ownerInformation.get('CO_DOB'))?.format()
					)
				);
				ownerInfoSection.addSubSection(new LPI_PDFSectionWrapper('', 3, subSectionDataList));
				subSectionDataList = new List<LPI_PDFSectionWrapper.DataWrapper>();
				subSectionDataList.add(new LPI_PDFSectionWrapper.DataWrapper('', 'Mailing Address'));
				ownerInfoSection.addSubSection(new LPI_PDFSectionWrapper('', 1, subSectionDataList));
				subSectionDataList = new List<LPI_PDFSectionWrapper.DataWrapper>();

				subSectionDataList.add(
					new LPI_PDFSectionWrapper.DataWrapper(
						'Street Address',
						String.valueOf(ownerInformation.get('StreetAddress'))
					)
				);
				subSectionDataList.add(
					new LPI_PDFSectionWrapper.DataWrapper('City', String.valueOf(ownerInformation.get('CO_City')))
				);

				if ((String) ownerInformation.get('CO_Country') == 'United States') {
					subSectionDataList.add(
						new LPI_PDFSectionWrapper.DataWrapper(
							'State',
							String.valueOf(ownerInformation.get('CO_State'))
						)
					);
				} else {
					subSectionDataList.add(
						new LPI_PDFSectionWrapper.DataWrapper(
							'State',
							String.valueOf(ownerInformation.get('CO_StateText'))
						)
					);
				}
				subSectionDataList.add(
					new LPI_PDFSectionWrapper.DataWrapper(
						'Country',
						String.valueOf(ownerInformation.get('CO_Country'))
					)
				);

				if ((String) ownerInformation.get('CO_Country') == 'United States') {
					subSectionDataList.add(
						new LPI_PDFSectionWrapper.DataWrapper(
							'Zip Code',
							String.valueOf(ownerInformation.get('CO_ZipCodeUS'))
						)
					);
				} else {
					subSectionDataList.add(
						new LPI_PDFSectionWrapper.DataWrapper(
							'Zip Code',
							String.valueOf(ownerInformation.get('CO_ZipCode'))
						)
					);
				}

				subSectionDataList.add(
					new LPI_PDFSectionWrapper.DataWrapper('County', String.valueOf(ownerInformation.get('CO_County')))
				);
				ownerInfoSection.addSubSection(new LPI_PDFSectionWrapper('', 3, subSectionDataList));
				counter += 1;
			}
		}
		return ownerInfoSection;
	}
	/**
	 * @author                      : MTX Group Inc
	 * @since                       : march 27,2023
	 * @description                 : This is a method to get Admin Info
	 * @param parRecord             : PreliminaryApplicationRef
	 * @return                      : LPI_PDFSectionWrapper
	 */
	public static LPI_PDFSectionWrapper getAdministratorInformation(String parId) {
		Map<String, Object> input = new Map<String, Object>();
		Map<String, Object> output = new Map<String, Object>();
		input.put('parId', parId);

		String stringToQuery = 'Id, Type__c, Amendment_Type__c  ';
		String whereClause = 'Id= \'' + String.escapeSingleQuotes(parId) + '\'';
		List<PreliminaryApplicationRef> parList = LPI_PreliminaryApplicationRefDAO.getPreAppRefByDymanicQueryWithoutSecurity(
			stringToQuery,
			whereClause,
			null,
			null,
			null
		);

		LPI_PDFSectionWrapper adminInfoWrapper = new LPI_PDFSectionWrapper();
		if (parList[0].Type__c == AMENDMENT_TYPE && parList[0].Amendment_Type__c != CHANGE_IN_SPONSERSHIP) {
			adminInfoWrapper.addSection(ADMINISTRATOR_INFORMATION_STEP, 3, null);

			LPI_AmendmentDesignatedInchargeChange.getExistingDesignatedAdminDetails(input, output);
			List<LPI_PDFSectionWrapper.DataWrapper> subSectionDataList = new List<LPI_PDFSectionWrapper.DataWrapper>();
			subSectionDataList.add(
				new LPI_PDFSectionWrapper.DataWrapper(
					'Administrator First Name',
					String.valueOf(output.get('ApplicantDesignatedInchargeFirstNameRO'))
				)
			);
			subSectionDataList.add(
				new LPI_PDFSectionWrapper.DataWrapper(
					'Administrator Middle Name',
					String.valueOf(output.get('ApplicantDesignatedInchargeMiddleNameRO'))
				)
			);
			subSectionDataList.add(
				new LPI_PDFSectionWrapper.DataWrapper(
					'Administrator Last Name',
					String.valueOf(output.get('ApplicantDesignatedInchargeLastNameRO'))
				)
			);
			adminInfoWrapper.addSubSection(
				new LPI_PDFSectionWrapper('Prev Designated Admin Details', 3, subSectionDataList)
			);

			subSectionDataList = new List<LPI_PDFSectionWrapper.DataWrapper>();

			subSectionDataList.add(
				new LPI_PDFSectionWrapper.DataWrapper('Home Address', '', 'view-info-label bold-heading')
			);

			adminInfoWrapper.addSubSection(new LPI_PDFSectionWrapper('', 1, subSectionDataList));

			subSectionDataList = new List<LPI_PDFSectionWrapper.DataWrapper>();

			subSectionDataList.add(
				new LPI_PDFSectionWrapper.DataWrapper('Street Address', String.valueOf(output.get('HomeAddressStreetRO')))
			);
			subSectionDataList.add(
				new LPI_PDFSectionWrapper.DataWrapper('County', String.valueOf(output.get('HomeAddressCountyRO')))
			);
			subSectionDataList.add(
				new LPI_PDFSectionWrapper.DataWrapper('City', String.valueOf(output.get('HomeAddressCityRO')))
			);
			subSectionDataList.add(
				new LPI_PDFSectionWrapper.DataWrapper('State', String.valueOf(output.get('HomeAddressStateValueRO')))
			);
			subSectionDataList.add(
				new LPI_PDFSectionWrapper.DataWrapper('Zip Code', String.valueOf(output.get('HomeAddressZipcodeRO')))
			);
			subSectionDataList.add(
				new LPI_PDFSectionWrapper.DataWrapper(
					'E-mail address',
					String.valueOf(output.get('AdministratorEmailRO'))
				)
			);
			subSectionDataList.add(
				new LPI_PDFSectionWrapper.DataWrapper(
					'Office Telephone number',
					String.valueOf(output.get('ApplicantDesignatedInchargePhoneRO'))
				)
			);
			subSectionDataList.add(
				new LPI_PDFSectionWrapper.DataWrapper(
					'Cell Phone Number',
					String.valueOf(output.get('ApplicantDesignatedInchargePhoneNumberRO'))
				)
			);
			adminInfoWrapper.addSubSection(new LPI_PDFSectionWrapper('', 3, subSectionDataList));

			subSectionDataList = new List<LPI_PDFSectionWrapper.DataWrapper>();
			subSectionDataList.add(
				new LPI_PDFSectionWrapper.DataWrapper(
					'Administrator First Name',
					String.valueOf(output.get('ApplicantDesignatedInchargeFirstName'))
				)
			);
			subSectionDataList.add(
				new LPI_PDFSectionWrapper.DataWrapper(
					'Administrator Middle Name',
					String.valueOf(output.get('ApplicantDesignatedInchargeMiddleName'))
				)
			);
			subSectionDataList.add(
				new LPI_PDFSectionWrapper.DataWrapper(
					'Administrator Last Name',
					String.valueOf(output.get('ApplicantDesignatedInchargeLastName'))
				)
			);
			adminInfoWrapper.addSubSection(
				new LPI_PDFSectionWrapper('New Designated Admin Details', 3, subSectionDataList)
			);

			subSectionDataList = new List<LPI_PDFSectionWrapper.DataWrapper>();

			subSectionDataList.add(
				new LPI_PDFSectionWrapper.DataWrapper('Home Address', '', 'view-info-label bold-heading')
			);

			adminInfoWrapper.addSubSection(new LPI_PDFSectionWrapper('', 1, subSectionDataList));

			subSectionDataList = new List<LPI_PDFSectionWrapper.DataWrapper>();

			subSectionDataList.add(
				new LPI_PDFSectionWrapper.DataWrapper('Street Address', String.valueOf(output.get('HomeAddressStreet')))
			);
			subSectionDataList.add(
				new LPI_PDFSectionWrapper.DataWrapper('City', String.valueOf(output.get('HomeAddressCity')))
			);
			subSectionDataList.add(
				new LPI_PDFSectionWrapper.DataWrapper('County', String.valueOf(output.get('HomeAddressCounty')))
			);
			subSectionDataList.add(
				new LPI_PDFSectionWrapper.DataWrapper('State', String.valueOf(output.get('HomeAddressStateValue')))
			);
			subSectionDataList.add(
				new LPI_PDFSectionWrapper.DataWrapper('Zip Code', String.valueOf(output.get('HomeAddressZipcode')))
			);
			subSectionDataList.add(
				new LPI_PDFSectionWrapper.DataWrapper(
					'E-mail address',
					String.valueOf(output.get('AdministratorEmail'))
				)
			);
			subSectionDataList.add(
				new LPI_PDFSectionWrapper.DataWrapper(
					'Office Telephone number',
					String.valueOf(output.get('ApplicantDesignatedInchargePhone'))
				)
			);
			subSectionDataList.add(
				new LPI_PDFSectionWrapper.DataWrapper(
					'Cell Phone Number',
					String.valueOf(output.get('ApplicantDesignatedInchargePhoneNumber'))
				)
			);
			subSectionDataList.add(
				new LPI_PDFSectionWrapper.DataWrapper(
					'Effective Date Of Change',
					Date.valueOf(output.get('ApplicantDesignatedInchargeEffectiveDateOfChange'))?.format()
				)
			);

			adminInfoWrapper.addSubSection(new LPI_PDFSectionWrapper('', 3, subSectionDataList));
		} else {
			LPI_DesignatedInchargeController.fetchRSBDesignatedBrokerName(input, output);
			List<LPI_PDFSectionWrapper.DataWrapper> dataList = new List<LPI_PDFSectionWrapper.DataWrapper>();

			dataList.add(
				new LPI_PDFSectionWrapper.DataWrapper(
					'Administrator First Name',
					String.valueOf(output.get('DesignatedInchargeFirstName'))
				)
			);
			dataList.add(
				new LPI_PDFSectionWrapper.DataWrapper(
					'Administrator Middle Name',
					String.valueOf(output.get('DesignatedInchargeMiddleName'))
				)
			);
			dataList.add(
				new LPI_PDFSectionWrapper.DataWrapper(
					'Administrator Last Name',
					String.valueOf(output.get('DesignatedInchargeLastName'))
				)
			);
			dataList.add(
				new LPI_PDFSectionWrapper.DataWrapper(
					'Street Address',
					String.valueOf(output.get('HomeAddressStreet'))
				)
			);
			dataList.add(
				new LPI_PDFSectionWrapper.DataWrapper('City', String.valueOf(output.get('HomeAddressCity')))
			);
			dataList.add(
				new LPI_PDFSectionWrapper.DataWrapper('County', String.valueOf(output.get('HomeAddressCounty')))
			);
			dataList.add(
				new LPI_PDFSectionWrapper.DataWrapper('State', String.valueOf(output.get('HomeAddressState')))
			);
			dataList.add(
				new LPI_PDFSectionWrapper.DataWrapper('Zip Code', String.valueOf(output.get('HomeAddressZipcode')))
			);
			dataList.add(
				new LPI_PDFSectionWrapper.DataWrapper(
					'E-mail address',
					String.valueOf(output.get('AdministratorEmail'))
				)
			);
			dataList.add(
				new LPI_PDFSectionWrapper.DataWrapper(
					'Office Telephone number',
					String.valueOf(output.get('ApplicantDesignatedInchargePhone'))
				)
			);
			dataList.add(
				new LPI_PDFSectionWrapper.DataWrapper(
					'Cell Phone Number',
					String.valueOf(output.get('DesignatedInchargePhoneNumber'))
				)
			);
			adminInfoWrapper.addSection(ADMINISTRATOR_INFORMATION_STEP, 3, dataList);
		}

		return adminInfoWrapper;
	}

	public static LPI_PDFSectionWrapper getDegreeInformationSection(PreliminaryApplicationRef parRecord){
		List<Degree__c> degreeList = [
			Select Id, Name, Institution_Name__c, Graduation_Date__c, Major__c, Minor__c From Degree__c Where Preliminary_Application_Reference__c =: parRecord.Id
		];
		LPI_PDFSectionWrapper pdfWrap = new LPI_PDFSectionWrapper(DEGREE_INFORMATION, 2, null);
		
			Integer counter = 1;
			for(Degree__c deg: degreeList){
				List<LPI_PDFSectionWrapper.DataWrapper> SubSectionDataList = new List<LPI_PDFSectionWrapper.DataWrapper>();
				SubSectionDataList.add(new LPI_PDFSectionWrapper.DataWrapper('Institution Name', deg.Institution_Name__c));
				SubSectionDataList.add(new LPI_PDFSectionWrapper.DataWrapper('Graduation Date', String.valueOf(deg.Graduation_Date__c)));
				SubSectionDataList.add(new LPI_PDFSectionWrapper.DataWrapper('Major', deg.Major__c));
				SubSectionDataList.add(new LPI_PDFSectionWrapper.DataWrapper('Minor', deg.Minor__c));
				pdfWrap.addSubSection(
					new LPI_PDFSectionWrapper('Degree Information ' + counter, 2, SubSectionDataList)
				);
				counter += 1;
			}
			if (pdfWrap.subSectionList == null || pdfWrap.subSectionList.isEmpty()) {
				List<LPI_PDFSectionWrapper.DataWrapper> dataList = new List<LPI_PDFSectionWrapper.DataWrapper>();
				dataList.add(new LPI_PDFSectionWrapper.DataWrapper('No Degree Information Data Found in the System', ''));
				pdfWrap = new LPI_PDFSectionWrapper(DEGREE_INFORMATION, 2, dataList);
			}
			return pdfWrap;
	}
	public static LPI_PDFSectionWrapper getWorkHistorySection(PreliminaryApplicationRef parRecord){
		List<Work_History__c> workList = [
			Select Id, Name, School_Agency_or_Instution__c, Employment_State__c, Employment_Country__c, Employment_City__c,
			Employment_End_Month__c, Employment_Start_Month__c, Employment_End_Year__c, Employment_Start_Year__c, Contact__r.Name From Work_History__c Where Preliminary_Application_Reference__c =: parRecord.Id
		];
		LPI_PDFSectionWrapper pdfWrap = new LPI_PDFSectionWrapper(WORK_HISTORY, 2, null);
		
			Integer counter = 1;
			for(Work_History__c wh: workList){
				List<LPI_PDFSectionWrapper.DataWrapper> SubSectionDataList = new List<LPI_PDFSectionWrapper.DataWrapper>();
				SubSectionDataList.add(new LPI_PDFSectionWrapper.DataWrapper('School/Agency/Institution Name', wh.School_Agency_or_Instution__c));
				SubSectionDataList.add(new LPI_PDFSectionWrapper.DataWrapper('Employer Name', wh.Contact__r.Name));
				SubSectionDataList.add(new LPI_PDFSectionWrapper.DataWrapper('Employment Start Month', wh.Employment_Start_Month__c));
				SubSectionDataList.add(new LPI_PDFSectionWrapper.DataWrapper('Employment Start Year', String.valueOf(wh.Employment_Start_Year__c)));
				SubSectionDataList.add(new LPI_PDFSectionWrapper.DataWrapper('Employment End Month', wh.Employment_End_Month__c));
				SubSectionDataList.add(new LPI_PDFSectionWrapper.DataWrapper('Employment End Year', String.valueOf(wh.Employment_End_Year__c)));
				SubSectionDataList.add(new LPI_PDFSectionWrapper.DataWrapper('Employment City', wh.Employment_City__c));
				SubSectionDataList.add(new LPI_PDFSectionWrapper.DataWrapper('Employment State', wh.Employment_State__c));
				pdfWrap.addSubSection(
					new LPI_PDFSectionWrapper('Work History ' + counter, 2, SubSectionDataList)
				);
				counter += 1;
			}
			if (pdfWrap.subSectionList == null || pdfWrap.subSectionList.isEmpty()) {
				List<LPI_PDFSectionWrapper.DataWrapper> dataList = new List<LPI_PDFSectionWrapper.DataWrapper>();
				dataList.add(new LPI_PDFSectionWrapper.DataWrapper('No Work History Data Found in the System', ''));
				pdfWrap = new LPI_PDFSectionWrapper(WORK_HISTORY, 2, dataList);
			}
			return pdfWrap;
	}

	/**
	 * @author                      : MTX Group Inc
	 * @since                       : march 27,2023
	 * @description                 : This is a method to get Employment History
	 * @param parRecord             : PreliminaryApplicationRef Id
	 * @return                      : LPI_PDFSectionWrapper
	 * @last modified               : MTX Group Inc
	 * @last modified Details       : Removed all verified checkbox changes to status picklist and created boolean verified to handle
	 * @last modified date          : 04 May 2023
	 */
	public static LPI_PDFSectionWrapper getEmploymentHistory(PreliminaryApplicationRef parRecord) {
		Map<String, Object> input = new Map<String, Object>();
		Map<String, Object> output = new Map<String, Object>();
		input.put('parId', parRecord.Id);
		input.put('parid', parRecord.Id);
		LPI_EmploymentHistoryData.fetchEmploymentHistoryInformation(input, output);
		LPI_PDFSectionWrapper pdfWrap = new LPI_PDFSectionWrapper(EMPLOYMENT_HISTORY_STEP, 3, null);
		if (output.containsKey('LPIEmploymentHistoryDetails')) {
			Integer counter = 1;
			for (
				Map<String, Object> employmentHistory : (List<Map<String, Object>>) output.get(
					'LPIEmploymentHistoryDetails'
				)
			) {
				List<LPI_PDFSectionWrapper.DataWrapper> SubSectionDataList = new List<LPI_PDFSectionWrapper.DataWrapper>();

				SubSectionDataList.add(
					new LPI_PDFSectionWrapper.DataWrapper(
						'Name of the Employer',
						String.valueOf(employmentHistory.get('LPINameoftheEmployer'))
					)
				);
				SubSectionDataList.add(
					new LPI_PDFSectionWrapper.DataWrapper(
						'Start Date',
						Date.valueOf(employmentHistory.get('LPIStartdate'))?.format()
					)
				);
				SubSectionDataList.add(
					new LPI_PDFSectionWrapper.DataWrapper(
						'End Date',
						Date.valueOf(employmentHistory.get('LPIEndDate'))?.format()
					)
				);
				if (parRecord.Board_Name__c == ELECTRICAL_CONTRACTORS_BOARD) {
					SubSectionDataList.add(
						new LPI_PDFSectionWrapper.DataWrapper(
							'Total Hours Claimed',
							String.valueOf(employmentHistory.get('TotalHoursClaimed'))
						)
					);
				}
				SubSectionDataList.add(
					new LPI_PDFSectionWrapper.DataWrapper(
						'Street Address',
						String.valueOf(employmentHistory.get('LPIStreetAddress'))
					)
				);
				SubSectionDataList.add(
					new LPI_PDFSectionWrapper.DataWrapper('City', String.valueOf(employmentHistory.get('LPICity')))
				);

				boolean verified = false;
				String statusValue = String.valueOf(employmentHistory.get('Status'));
				if (statusValue != null && statusValue.equals('Verified')) {
					verified = true;
				}

				if (
					employmentHistory.containsKey('LPICountry') &&
					String.valueOf(employmentHistory.get('LPICountry')) != 'United States' &&
					verified == false
				) {
					SubSectionDataList.add(
						new LPI_PDFSectionWrapper.DataWrapper(
							'State',
							String.valueOf(employmentHistory.get('LPIState'))
						)
					);
				}
				if (
					employmentHistory.containsKey('LPICountryReadOnly') &&
					String.valueOf(employmentHistory.get('LPICountryReadOnly')) != 'United States' &&
					verified == true
				) {
					SubSectionDataList.add(
						new LPI_PDFSectionWrapper.DataWrapper(
							'State',
							String.valueOf(employmentHistory.get('LPIStateReadOnly'))
						)
					);
				}

				if (
					employmentHistory.containsKey('LPICountry') &&
					String.valueOf(employmentHistory.get('LPICountry')) == 'United States' &&
					verified == false
				) {
					SubSectionDataList.add(
						new LPI_PDFSectionWrapper.DataWrapper(
							'State',
							String.valueOf(employmentHistory.get('LPIStateSelect'))
						)
					);
				}

				if (
					employmentHistory.containsKey('LPICountryReadOnly') &&
					String.valueOf(employmentHistory.get('LPICountryReadOnly')) == 'United States' &&
					verified == true
				) {
					SubSectionDataList.add(
						new LPI_PDFSectionWrapper.DataWrapper(
							'State',
							String.valueOf(employmentHistory.get('LPIStateSelectReadOnly'))
						)
					);
				}

				if (verified == true) {
					SubSectionDataList.add(
						new LPI_PDFSectionWrapper.DataWrapper(
							'Country',
							String.valueOf(employmentHistory.get('LPICountryReadOnly'))
						)
					);
				} else {
					SubSectionDataList.add(
						new LPI_PDFSectionWrapper.DataWrapper(
							'Country',
							String.valueOf(employmentHistory.get('LPICountry'))
						)
					);
				}

				SubSectionDataList.add(
					new LPI_PDFSectionWrapper.DataWrapper(
						'Zip Code',
						String.valueOf(employmentHistory.get('LPIZip'))
					)
				);
				SubSectionDataList.add(
					new LPI_PDFSectionWrapper.DataWrapper(
						'Job Title/Position held',
						String.valueOf(employmentHistory.get('LPIJobTitlePositionheld'))
					)
				);
				if (String.valueOf(employmentHistory.get('JobDuties')) != null) {
					SubSectionDataList.add(
						new LPI_PDFSectionWrapper.DataWrapper(
							'Job Duties',
							String.valueOf(employmentHistory.get('JobDuties'))
						)
					);
				}
				if (
					employmentHistory.containsKey('fieldVisibilityCheckApprExp') &&
					Boolean.valueOf(employmentHistory.get('fieldVisibilityCheckApprExp') == true)
				) {
					SubSectionDataList.add(
						new LPI_PDFSectionWrapper.DataWrapper(
							'Check Appropriate Experiences',
							String.valueOf(employmentHistory.get('CheckAppropriateExperiencesMassageTherapist'))
						)
					);
				}
				if (Boolean.valueOf(employmentHistory.get('fieldVisibility')) == true) {
					SubSectionDataList.add(
						new LPI_PDFSectionWrapper.DataWrapper(
							'Check Appropriate Experiences',
							String.valueOf(employmentHistory.get('CheckAppropriateExperiences'))
						)
					);
				}
				if (
					employmentHistory.containsKey('PleaseSpecify') &&
					String.valueOf(employmentHistory.get('PleaseSpecify')) != null
				) {
					SubSectionDataList.add(
						new LPI_PDFSectionWrapper.DataWrapper(
							'Please Specify',
							String.valueOf(employmentHistory.get('PleaseSpecify'))
						)
					);
				}
				SubSectionDataList.add(
					new LPI_PDFSectionWrapper.DataWrapper(
						'Immediate Supervisor\'s Name',
						String.valueOf(employmentHistory.get('LPIImmediateSupervisorsName'))
					)
				);
				SubSectionDataList.add(
					new LPI_PDFSectionWrapper.DataWrapper(
						'Supervisor\'s Phone Number',
						String.valueOf(employmentHistory.get('LPIImmediateSupervisorsPhoneNumber'))
					)
				);
				pdfWrap.addSubSection(
					new LPI_PDFSectionWrapper('Employment History ' + counter, 3, SubSectionDataList)
				);

				if (!(boolean) output.get('hideSupervisorAddress')) {
					SubSectionDataList = new List<LPI_PDFSectionWrapper.DataWrapper>();
					SubSectionDataList.add(
						new LPI_PDFSectionWrapper.DataWrapper(
							'Street Address',
							String.valueOf(employmentHistory.get('LPIStreetAddress1'))
						)
					);
					SubSectionDataList.add(
						new LPI_PDFSectionWrapper.DataWrapper(
							'City',
							String.valueOf(employmentHistory.get('LPISACity'))
						)
					);
					SubSectionDataList.add(
						new LPI_PDFSectionWrapper.DataWrapper(
							'State',
							String.valueOf(employmentHistory.get('LPISAState'))
						)
					);
					SubSectionDataList.add(
						new LPI_PDFSectionWrapper.DataWrapper(
							'Zip Code',
							String.valueOf(employmentHistory.get('LPISAZip'))
						)
					);
					SubSectionDataList.add(
						new LPI_PDFSectionWrapper.DataWrapper(
							'Supervisor License Number (if applicable)',
							String.valueOf(employmentHistory.get('LPIEmployerLicenseNumber'))
						)
					);

					pdfWrap.addSubSection(new LPI_PDFSectionWrapper('Supervisor\'s Address', 3, SubSectionDataList));
				}

				counter += 1;
			}
		}

		if (pdfWrap.subSectionList == null || pdfWrap.subSectionList.isEmpty()) {
			List<LPI_PDFSectionWrapper.DataWrapper> dataList = new List<LPI_PDFSectionWrapper.DataWrapper>();
			dataList.add(new LPI_PDFSectionWrapper.DataWrapper('No Employment History Data Found in the System', ''));
			pdfWrap = new LPI_PDFSectionWrapper(EMPLOYMENT_HISTORY_STEP, 3, dataList);
		}

		return pdfWrap;
	}

	public static string getLabelFromRolesApiName(String apiName) {
		if (apiName == 'Designated Incharge') {
			return ('Person In Charge');
		} else if (apiName == 'Owner + Designated Incharge') {
			return ('Owner + Person In Charge');
		} else if (apiName == 'Owner') {
			return ('Owner');
		}
		return apiName;
	}


	/**
	 * @author                      : MTX Group Inc
	 * @since                       : march 27,2023
	 * @description                 : This is a method to get Amendment Details
	 * @param parRecord             : PreliminaryApplicationRef
	 * @return                      : LPI_PDFSectionWrapper
	 */
	public static LPI_PDFSectionWrapper getAmendmentDetails(PreliminaryApplicationRef parRecord) {
		LPI_PDFSectionWrapper amendmentDetailSection = new LPI_PDFSectionWrapper(AMENDMENT_DETAILS_STEP, 3, null);
		if (
			parRecord.Amendment_Type__c == LPI_LiteralConstant.BLA_CHANGE_OF_FICTITIOUS_NAME_OR_TRADE_NAME ||
			parRecord.Amendment_Type__c == LPI_LiteralConstant.BLA_CHANGE_OF_CORPORATION_ASSOCIATION_PARTNERSHIP
		) {
			amendmentDetailSection = getAmendmentDetailsForBusinessNameorParternship(
				parRecord
			);
		}else if(
			parRecord.Amendment_Type__c == AMEND_PROFESSIONAL_CORPORATION_NAME_APPROVAL ||
			parRecord.Amendment_Type__c == AMEND_APPLY_FOR_PROFESSIONAL_CORPORATION
		){
			amendmentDetailSection = getAmendmentDetailsForProfCorporation(parRecord);
		}
		return amendmentDetailSection;
	}
	 /**
     * @author                      : MTX Group Inc
     * @since                       : March 22, 2024
     * @description                 : This method displays `Amendment Details` in Application PDF for Professional Corporation amendments
     * @param parRecord             : Input PreliminaryApplicationRef record
     * @return                      : `LPI_PDFSectionWrapper`
     * @last modified by            : Ayush Dev
     * @last modified date          : {Add if modified by you}
     * @last modified details       : {Add if modified by you}
     */
    public static LPI_PDFSectionWrapper getAmendmentDetailsForProfCorporation(PreliminaryApplicationRef parRecord) {
        List<LPI_PDFSectionWrapper.DataWrapper> dataList = new List<LPI_PDFSectionWrapper.DataWrapper>();
        dataList.add(new LPI_PDFSectionWrapper.DataWrapper(
            'License Number', 
            parRecord.Business_License__r.Name)
        );
        if(parRecord.Board_Name__c == 'Healing Arts'){
            Map<String, Object> myTransformData = new Map<String, Object>{ 'parId' => parRecord.Id };
            omnistudio.DRProcessResult result = omnistudio.DRGlobal.process(
                myTransformData,
                'LPIProfessionalCorporationFetch'
            );
            List<Map<String, Object>> myTransformResult = (List<Map<String, Object>>) result.toJsonList();
            for (Map<String, Object> dataMap : myTransformResult) {
                if(dataMap.containsKey('ProfessionalCorporationNameAmendmentDetails')){
                    Map<String, object> profCorpDetails = (Map<String, object>) dataMap.get('ProfessionalCorporationNameAmendmentDetails');
                    dataList.add(new LPI_PDFSectionWrapper.DataWrapper(
                        'Name of the Professional Corporation', 
                        String.valueOf(profCorpDetails.get('ProfessionalCorporationName')))
                    );
                }
            }
        }
        if(parRecord.Amendment_Type__c == AMEND_APPLY_FOR_PROFESSIONAL_CORPORATION){
            dataList.add(new LPI_PDFSectionWrapper.DataWrapper(
                'Type of Professional Corporation', 
                parRecord.Regulatory_Authorization_Type__r.Name)
            );
        }
        
        return new LPI_PDFSectionWrapper(AMENDMENT_DETAILS_STEP, 3, dataList);
    }

	/**
     * @author                      : MTX Group Inc
     * @since                       : march 27,2023
     * @description                 : This is a method to get Amendment Details
     * @param parRecord             : PreliminaryApplicationRef
     * @return                      : LPI_PDFSectionWrapper
     */

	public static LPI_PDFSectionWrapper getAmendmentDetailsForBusinessNameorParternship(PreliminaryApplicationRef parRecord) {
        Map<String, Object> input = new Map<String, Object>();
        Map<String, Object> output = new Map<String, Object>();
        input.put('parId', parRecord.Id);
        LPI_FacilityOrDBANameChangeController.RSBGetNewAndFormerBusinessNameOrFictitiousName(input, output);
        List<LPI_PDFSectionWrapper.DataWrapper> dataList = new List<LPI_PDFSectionWrapper.DataWrapper>();
        Map<String, String> fieldAPIToLabelMap;
        String regAuthTypeName = output != null && output.containsKey('regAuthTypeName')
            ? String.valueOf(output.get('regAuthTypeName'))
            : '';
        String amendmentRequestType = output != null && output.containsKey('AmendmentRequestType')
            ? String.valueOf(output.get('AmendmentRequestType'))
            : '';
        String boardName = output != null && output.containsKey('boardName') ? String.valueOf(output.get('boardName')) : '';
        Set<String> regAuthNameSet1 = new Set<String>{
            'Pharmacy',
            'Third-Party Logistics Provider',
            'Drug Distributor',
            'Drug Outsourcer',
            'Drug Distributor Registrant',
            'Certificate of Authority - Corporation'
        };
        Set<String> regAuthNameSet2 = new Set<String>{
            'Drug Distributor',
            'Drug Outsourcer',
            'Drug Distributor Registrant',
            'FQHC Registration',
            'NFP Corporation Permit',
            'Funeral Establishment',
            'Certificate of Authority - Corporation'
        };
        if (parRecord.Amendment_Type__c == LPI_LiteralConstant.BLA_CHANGE_OF_FICTITIOUS_NAME_OR_TRADE_NAME) {
           
            dataList.add(
                new LPI_PDFSectionWrapper.DataWrapper(
                    'Current Fictitious/DBA Name',
                    String.valueOf(output.get('FormerBusinessOrFictitiousNameForReview'))
                )
            );
            if (amendmentRequestType == 'New') {
                dataList.add(
                    new LPI_PDFSectionWrapper.DataWrapper(
                        'New Fictitious/DBA Name',
                        String.valueOf(output.get('NewFictitiousName'))
                    )
                );
            }

            if (regAuthNameSet1.contains(regAuthTypeName)) {
                dataList.add(
                    new LPI_PDFSectionWrapper.DataWrapper(
                        'Person In Charge',
                        String.valueOf(output.get('DesignatedIncharge'))
                    )
                );
            }
            if (amendmentRequestType == 'New' && regAuthNameSet2.contains(regAuthTypeName)) {
                dataList.add(
                    new LPI_PDFSectionWrapper.DataWrapper(
                        'Effective Date Of Name Change',
                        Date.valueOf(output.get('NewEffectiveDateOfNameChange'))?.format()
                    )
                );
            }
        } else if (parRecord.Amendment_Type__c == LPI_LiteralConstant.BLA_CHANGE_OF_CORPORATION_ASSOCIATION_PARTNERSHIP) {
            dataList.add(
                new LPI_PDFSectionWrapper.DataWrapper(
                    'Current Facility Name',
                    String.valueOf(output.get('FormerBusinessOrFictitiousNameForReview'))
                )
            );
            dataList.add(
                new LPI_PDFSectionWrapper.DataWrapper('New Name', String.valueOf(output.get('NewBusinessName')))
            );
            
            if (regAuthNameSet1.contains(regAuthTypeName)) {
                dataList.add(
                    new LPI_PDFSectionWrapper.DataWrapper(
                        'Person In Charge',
                        String.valueOf(output.get('DesignatedIncharge'))
                    )
                );
            }
            if (regAuthNameSet2.contains(regAuthTypeName) || regAuthNameSet1.contains(regAuthTypeName)) {
                dataList.add(
                    new LPI_PDFSectionWrapper.DataWrapper(
                        'Effective Date Of Name Change',
                        Date.valueOf(output.get('NewEffectiveDateOfNameChange'))?.format()
                    )
                );
            }
        }

        return new LPI_PDFSectionWrapper(LPI_ApplicationDataUtility.AMENDMENT_DETAILS_STEP, 3, dataList);
    }

	/**
	 * @author                      : MTX Group Inc
	 * @since                       : march 27,2023
	 * @description                 : This is a method to get Business Tax Compliance
	 * @param parRecord             : PreliminaryApplicationRef
	 * @return                      : LPI_PDFSectionWrapper
	 */
	public static LPI_PDFSectionWrapper getBusinessTaxCompliance(String parId) {
		LPI_PDFSectionWrapper businessTaxComplianceSection = new LPI_PDFSectionWrapper(
			BUSINESS_TAX_COMPLIANCE_STEP,
			3,
			null
		);
		List<LPI_PDFSectionWrapper.DataWrapper> dataList = new List<LPI_PDFSectionWrapper.DataWrapper>();
		Map<String, Object> myTransformData = new Map<String, Object>{ 'parid' => parId };
		Map<String, Object> myTransformResult = new Map<String, Object>();
		Map<String, Object> testMap = new Map<String, Object>();
		if(Test.isRunningTest()){
			testMap.put('LPIBusinessTaxComplianceStatement','Test');
			testMap.put('LPIBusinessTaxComplianceMissouriStateTaxNumber','9876543210');
		
			myTransformResult.put('LPIBusinessTaxCompliance',testMap);
		} else {
			omnistudio.DRProcessResult result = omnistudio.DRGlobal.process(
			myTransformData,
			'LPIBusinessTaxComplianceDetailsFetch'
			);
			myTransformResult = (Map<String, Object>) result.toJson();
		}
		
		
		if (myTransformResult != null && myTransformResult.containsKey('LPIBusinessTaxCompliance')) {
			Map<String, Object> taxComplianceDataMap = (Map<String, Object>) myTransformResult.get(
				'LPIBusinessTaxCompliance'
			);
			dataList.add(
				new LPI_PDFSectionWrapper.DataWrapper(
					'Please select one of the following',
					String.valueOf(taxComplianceDataMap.get('LPIBusinessTaxComplianceStatement'))
				)
			);
			if (taxComplianceDataMap.get('LPIBusinessTaxComplianceMissouriStateTaxNumber') != null) {
				dataList.add(
					new LPI_PDFSectionWrapper.DataWrapper(
						'Missouri state tax number',
						String.valueOf(taxComplianceDataMap.get('LPIBusinessTaxComplianceMissouriStateTaxNumber'))
					)
				);
			}
			businessTaxComplianceSection.addSubSection(
				new LPI_PDFSectionWrapper('Compliance Statement', 1, dataList)
			);
		}

		return businessTaxComplianceSection;
	}

	
	
	/**
	 * @author                      : MTX Group Inc
	 * @since                       : 22th August 2023
	 * @description                 : This is a method to get Attestation Step Details
	 * @param parRecord             : PreliminaryApplicationRef Id
	 * @return                      : LPI_PDFSectionWrapper
	 */
	public static LPI_PDFSectionWrapper getAttestationStep(PreliminaryApplicationRef parRecord) {
		if (parRecord.Attestation_Step_API_Name__c != null && parRecord.Attestation_Data__c != null) {
			LPI_OSStepParser osParser = new LPI_OSStepParser(parRecord.Attestation_Step_API_Name__c, parRecord);
			return osParser.getPDFSectionWrapper(parRecord.Attestation_Data__c, ATTESTATION_STEP);
		}

		return null;
	}

	

	/**
	 * @author                      : MTX Group Inc
	 * @since                       : 04 October,2023
	 * @description                 : This is a method to get License Details Step Info
	 * @param parRecord             : PreliminaryApplicationRef
	 * @return                      : LPI_PDFSectionWrapper
	 */
	private static LPI_PDFSectionWrapper getLicenseDetailsSection(PreliminaryApplicationRef parRecord) {
		LPI_PDFSectionWrapper licenseDetailsSection;
		List<LPI_PDFSectionWrapper.DataWrapper> dataList = new List<LPI_PDFSectionWrapper.DataWrapper>();
		dataList.add(
			new LPI_PDFSectionWrapper.DataWrapper(
				'License Type',
				String.isNotBlank(parRecord.Regulatory_Authorization_Type__r.Name)
					? parRecord.Regulatory_Authorization_Type__r.Name
					: ''
			)
		);

		dataList.add(
			new LPI_PDFSectionWrapper.DataWrapper(
				'License Number',
				String.isNotBlank(parRecord.Business_License__r.Name) ? parRecord.Business_License__r.Name : ''
			)
		);

		dataList.add(
			new LPI_PDFSectionWrapper.DataWrapper(
				'Issuance date',
				parRecord.Business_License__r.PeriodStart != null
					? Date.valueOf(parRecord.Business_License__r.PeriodStart)?.format()
					: ''
			)
		);

		dataList.add(
			new LPI_PDFSectionWrapper.DataWrapper(
				'Expiration date',
				parRecord.Business_License__r.PeriodEnd != null
					? Date.valueOf(parRecord.Business_License__r.PeriodEnd)?.format()
					: ''
			)
		);

		dataList.add(
			new LPI_PDFSectionWrapper.DataWrapper(
				'Status',
				String.isNotBlank(parRecord.Business_License__r.Status) ? parRecord.Business_License__r.Status : ''
			)
		);

		licenseDetailsSection = new LPI_PDFSectionWrapper(LICENSE_DETAILS_STEP, 2, dataList);
		return licenseDetailsSection;
	}

	/**
	 * @author                      : MTX Group Inc
	 * @since                       : Nov 15,2023
	 * @description                 : This is a method to get Hospital Coordinators
	 * @param parRecord             : PreliminaryApplicationRef
	 * @return                      : LPI_PDFSectionWrapper
	 */
	public static LPI_PDFSectionWrapper getHospitalCoordinatorsInfo(String parId) {
		Integer counter = 1;
		String DRName = 'FetchApplicantReferenceDetails';
		/* Populate the input JSON */
		Map<String, Object> myTransformData = new Map<String, Object>{
			'parid' => parId,
			'headerFilterDr' => AUTHORIZED_CONTACTS
		};

		omnistudio.DRProcessResult result = omnistudio.DRGlobal.process(myTransformData, DRName);

		List<Map<String, Object>> myTransformResult = (List<Map<String, Object>>) result.toJsonList();
		List<Map<String, Object>> applicantMap = new List<Map<String, Object>>();
		
		if(Test.isRunningTest()){
			Map<String, Object> testMap = new Map<String, Object>{
				'ApplicantReferenceName' => 'Test Name',
				'ApplicantReferencePhone' => '1234567890',
				'CoordinatorEmail' => 'test@test.com'
			};
			applicantMap.add(testMap);
		}
		else if (myTransformResult[0].get('MOApplicantDetails') instanceof List<Object>) {
			applicantMap = (List<Map<String, Object>>) myTransformResult[0].get('MOApplicantDetails');
		} else {
			applicantMap.add((Map<String, Object>) myTransformResult[0].get('MOApplicantDetails'));
		}

		LPI_PDFSectionWrapper hospitalCoordinatorStep = new LPI_PDFSectionWrapper(AUTHORIZED_CONTACTS, 3, null);
		for (Map<String, Object> dataMap : applicantMap) {
			if (String.isBlank((String) dataMap.get('ApplicantReferenceName'))) {
				return hospitalCoordinatorStep;
			}
			List<LPI_PDFSectionWrapper.DataWrapper> dataList = new List<LPI_PDFSectionWrapper.DataWrapper>();
			dataList.add(
				new LPI_PDFSectionWrapper.DataWrapper('Name', String.valueOf(dataMap.get('ApplicantReferenceName')))
			);
			dataList.add(
				new LPI_PDFSectionWrapper.DataWrapper(
					'Phone Number',
					String.valueOf(dataMap.get('ApplicantReferencePhone'))
				)
			);
			dataList.add(
				new LPI_PDFSectionWrapper.DataWrapper('Email', String.valueOf(dataMap.get('CoordinatorEmail')))
			);
			hospitalCoordinatorStep.addSubSection(
				new LPI_PDFSectionWrapper('Authorized Contact ' + counter, 3, dataList)
			);
	 		counter += 1;
		}
    	return hospitalCoordinatorStep;
	}
	
	/**
	 * @author                      : MTX Group Inc
	 * @since                       : march 28, 2024
	 * @description                 : This method will give lawful presence field details
	 * @param parRecord             : PreliminaryApplicationRef
	 * @return                      : LPI_PDFSectionWrapper
	 * @last modified by            : Ayush Dev
	 * @last modified date          :
	 * @modified details            :
	 */
	 public static List<LPI_PDFSectionWrapper.DataWrapper> getLawfulPresenceDetails(List<LPI_PDFSectionWrapper.DataWrapper> dataList, Account accRecord){
		try{
			Boolean lawfulAmendment = false;
			if(dataList.isEmpty()){
				lawfulAmendment = true;
			}
			dataList.add(new LPI_PDFSectionWrapper.DataWrapper('Citizenship', accRecord.Citizenship__c));
			dataList.add(new LPI_PDFSectionWrapper.DataWrapper('Proof of Citizenship', accRecord.Proof_of_Citizenship__c));
			if (accRecord.Citizenship__c == 'FOREIGN' && (COUNTRY_VALUE == UNITED_STATES || lawfulAmendment)) {
				dataList.add(new LPI_PDFSectionWrapper.DataWrapper('Evidence of Lawful Presence',accRecord.Proof_of_work_permit_in_United_States__c));
			}
			return dataList;
		}catch(Exception e){
			LPI_ExceptionManager.logException('LPI_ApplicationDataUtility', 'getLawfulPresenceDetails', e);
		}
		return null;
	 }
}