/**
 * @description       : 
 * @author            : MTX Group Product Team
 * @group             : 
 * @last modified on  : 08-02-2024
 * @last modified by  : Uzma Md
**/
public with sharing class LPI_IndividualAppTriggerHelper {

    private static String getClassName() {
		return 'IndividualAppTriggerHelper';
	}
	private static final String LICENSE_TYPE_NAME_PROVISIONAL_VETERINARIAN = 'Provisional Veterinarian';
	private static final String LICENSE_TYPE_GRADUATE_NURSE_RELEASE_FORM = 'Graduate Nurse Release Form';
	private static final String LICENSE_TYPE_EXAM_MODIFICATIONS = 'Request for Exam Modifications';
	private static final String LICENSE_TYPE_CHIROPRACTIC_PHYSICIAN = 'Chiropractic Physician';
	private static final String TYPE_MTAA = 'MTAA';
	private static final String TYPE_INSURANCE_CONSULTANT = 'Insurance Consultant';
	private static final String TYPE_DRY_NEEDLING = 'Dry Needling';
	private static final String TYPE_PROFESSIONAL_CORPORATION = 'Professional Corporation'; 
	private static final String AMENDMENT_SUBTYPE_CHANGE_OF_NAME = 'Change of Name';
	private static final String AMENDMENT_SUBTYPE_CHANGE_OF_MAILING_ADDRESS = 'Change of Mailing Address';
    private static final String AMENDMENT_SUBTYPE_ADDRESS = 'Change of Residence and/or Mailing Address';
    private static final String AMENDMENT_SUBTYPE_CHANGE_OF_RESIDENCE_ADDRESS = 'Change of Residence Address';
	private static final String APPRENTICESHIP = 'Apprenticeship';
	private static final String LICENSE_TYPE_PSY = 'Psychologist';
	private static final String IA_APPLICATION_TYPE_HSP = 'Health Service Provider (HSP)';
	private static final String IA_TYPE_CERTIFICATE_OF_IDENTIFICATION = 'Request for Certificate of Identification';
	private static final String REINSTATEMENT_BY_EXAM = 'Reinstatement by Exam';
	private static final String MAILING_ADDRESS = 'Mailing';
	private static final String UPDATE_MAILING_ADDRESS_TO_BL='updateMailingAddressTOBL';
	private static final String LOCATION_STATUS_CLOSED='Closed';
	private static final String LOCATION_STATUS_OPEN='Open';
	private static final String CLOSED = 'Closed';
	private final static String  COSMETOLOGY_BARBER_EDUCATION  = 'Cosmetology/Barber Education';
	private static final String APEP_BOARD_BUSINESS_REINSTATEMENT = 'Re-authorization';
	private static final String APEP_BOARD_INDIVIDUAL_REINSTATEMENT = 'Re-licensure';
	private static final String REQUEST_FOR_DUPLICATE_WALLHANGING_LICENSE = 'Request for Duplicate Wallhanging License';
	public static final Set<String> REINSTATEMENT_TYPE_SET = new Set<String>{
		LPI_LiteralConstant.IA_REINSTATEMENT_APPLICATIONTYPE,
		APEP_BOARD_BUSINESS_REINSTATEMENT,
		APEP_BOARD_INDIVIDUAL_REINSTATEMENT
	};
	private static final Set<String> IDENTIFICATION_CARD_SET = new Set<String>{		
		'Boxer\'s Federal ID Card',
		'MMA National ID Card'
	};
	private static final String COSMETOLOGY_AND_BARBER_BOARD = 'Cosmetology & Barber Examiners';
	private static final Set<String> AMENDMENT_SUBTYPE_SET = new Set<String>{
		AMENDMENT_SUBTYPE_CHANGE_OF_NAME,
		AMENDMENT_SUBTYPE_CHANGE_OF_RESIDENCE_ADDRESS,
		AMENDMENT_SUBTYPE_CHANGE_OF_MAILING_ADDRESS,
        AMENDMENT_SUBTYPE_ADDRESS
	};
	private static final String NCLEX_EXAMINATION_STATUS_AUTH_ISSUED = 'Authorization Issued';
	private static final String NCLEX_EXAMINATION_STATUS_SCORE_HOLD = 'Score Hold';
	private static final String NCLEX_EXAMINATION_STATUS_AUTH_PASSED = 'Passed';
	private static final String NCLEX_EXAMINATION_STATUS_AUTH_FAILED = 'Failed';
    private static final String NCLEX_EXAMINATION_STATUS_ERROR = 'Error';
	private static final String NCLEX_EXAM_STATUS_AUTH_ISSUED_UNIQUE_KEY = 'NCLEXExamStatusAuthIssued';
	private static final String NCLEX_EXAM_STATUS_SCORE_HOLD_UNIQUE_KEY = 'NCLEXExamStatusScoreHold';
	private static final String NCLEX_EXAM_STATUS_PASSED_UNIQUE_KEY = 'NCLEXExamStatusPassed';
	private static final String NCLEX_EXAM_STATUS_FAILED_UNIQUE_KEY = 'NCLEXExamStatusFailed';
    private static final String NCLEX_EXAM_STATUS_ERROR_UNIQUE_KEY = 'NCLEXExamStatusERROR';
	private static final String RN_LPN_TEMP_LICENSE_ISSUED_UNIQUE_KEY = 'RNLPNTempLicenseIssuedNotification'; 
	private static final String PRIMARY_CONTACT_ADDRESS = 'Primary Contact Address'; 
	private static final List<String> NCLEX_EXAM_STATUS_UNIQUE_KEY_SET = new List<String>{
		NCLEX_EXAM_STATUS_AUTH_ISSUED_UNIQUE_KEY,
		NCLEX_EXAM_STATUS_SCORE_HOLD_UNIQUE_KEY,
		NCLEX_EXAM_STATUS_PASSED_UNIQUE_KEY,
		NCLEX_EXAM_STATUS_FAILED_UNIQUE_KEY,
        NCLEX_EXAM_STATUS_ERROR_UNIQUE_KEY,
		RN_LPN_TEMP_LICENSE_ISSUED_UNIQUE_KEY 
	};
	private static final String VERIFIED = 'Verified'; 
    private static final String HIGHER_EDUCATION_TYPE = 'Higher Education'; 
	public static final String AMENDMENT_TYPE_EXAMINATION = 'Examination';
	private static final String ISSUING_AGENCY_NAME = 'Behavior Analyst Certification Board';
	private static final String INVESTIGATOR_RECORDTYPE = 'Investigators';
	public static final String LICENSE_INTERPRETER = 'Interpreter';
	public static final String CERTIFICATIONS_TYPE = 'Certifications';
	public static final Set<String>  eligibleApplicationTypeList = new Set<String>{
		LPI_LiteralConstant.IA_RENEWAL_APPLICATIONTYPE,
		LPI_LiteralConstant.IA_REINSTATEMENT_APPLICATIONTYPE,
		APEP_BOARD_BUSINESS_REINSTATEMENT,
		APEP_BOARD_INDIVIDUAL_REINSTATEMENT,
		LPI_LiteralConstant.PAR_SOBJECT_TYPE_REACTIVATION,
		CERTIFICATIONS_TYPE
	};
	public static final String CERTIFICATION_STATUS_ACTIVE = 'Active';
	public static final String CERTIFICATION_STATUS_INACTIVE = 'Inactive';
	private static final String REVOKED = 'Revoked';
	public static final Set<String> geologistLicenseTypeSet = new Set<String>{
		'Geologist Registrant in Training',
		'Geologist'
	};
	private static final List<String> PSYCHOLOGIST_LICENSE_LIST = new List<String>{
		'Psychologist - Temporary',
		'Psychologist',
		'Provisional License Psychologist'
	};
	private final static Set<String> MONTHLY_QUATERLY_REPRT_SUB_TYPE_SET = new set<String>{
        'Apprentice Monthly Time Report - Class CA - Hairdressing and Manicuring',
        'Apprentice Monthly Time Report - Esthetician',
        'Apprentice Monthly Time Report - Manicuring',
        'Apprentice Monthly Time Report - Class CH - Hairdresser',
        'Barber Quarterly Time Report'
    };
	public static final Set<String> LICENSURE_NOTIFICATION_ALLOWED_LICENCE_TYPES = new Set<String>{
		'Barber',
		'Cosmetologist/All-Barber',
		'Cosmetologist/Hair-Barber',
		'Barber Instructor',
		'Cosmetology Instructor',
		'Cosmetology/Barber Instructor'
	};
	public final static Set<String> CERTIFICATE_IDENTIFICATION_ALLOWED_LIC_TYPES = new Set<String>{
		'Barber',
		'Class CA - Hairdressing and Manicuring',
		'Class CH - Hairdresser',
		'Class E - Estheticians',
		'Class MO - Manicurist',
		'Cosmetologist/All-Barber',
		'Cosmetologist/Hair-Barber',
		'Barber Instructor',
		'Cosmetology Instructor',
		'Cosmetology/Barber Instructor'
	};
    public final static String STATUS_BOARD_REVIEW = 'Board Review';
    public final static String COSBAR_STUDENT_REJECTION_NOTIFY = 'CosBarStudentEnrollmentRejection';
	public static final String LICENSURE_NOTIFICATION_TEMPLATE = 'Cos_Bar_Licensure_Notication';
	private final static String FIELD_TRIP_REQUEST_TYPE = 'Field Trip Request';
	public final static String PERSON_ADDITIONAL_INFO = 'Person Additional Information';
	public static final String APPRENTICESHIP_APPROVAL_LETTER = 'Apprenticeship_Approval_Letter';
	public static final String FIELD_TRIP_NOTIFICATION_TEMPLATE = 'Field_Trip_Approval_Letter';
	public static final Set<String> ALL_ADDRESS_AMENDMENT_TYPE_SET = new Set<String>{
		LPI_LiteralConstant.PAR_AMENDMENT_SUBTYPE_NAME_OR_ADDRESS_CHANGE,
		LPI_LiteralConstant.CHANGE_OF_INDIVIDUAL_BUSINESS_ADDRESS,
		AMENDMENT_SUBTYPE_CHANGE_OF_RESIDENCE_ADDRESS,
		AMENDMENT_SUBTYPE_CHANGE_OF_MAILING_ADDRESS,
		AMENDMENT_SUBTYPE_CHANGE_OF_NAME,
        AMENDMENT_SUBTYPE_ADDRESS
	};
    private final static String CLASSIFICATION_MILITARY = 'Military';
	private final static Set<String> COS_BAR_OPERATORS_AND_INSTRUCTORS = new Set<String>{
		'Barber',
		'Barber Instructor',
		'Class CA - Hairdressing and Manicuring',
		'Class CH - Hairdresser',
		'Class E - Estheticians',
		'Class MO - Manicurist',
		'Cosmetology Instructor',
		'Cosmetology/Barber Instructor'
	};
	private final static String IA_SUB_TYPE_RECIPROCITY = 'Reciprocity';
	private final static String IA_SUB_TYPE_EXAM_SCORE_ENDORSEMENT = 'Exam Score Endorsement';
	private final static String IA_TYPE_REQUEST_CERTIFICATION_AFFIDAVIT = 'Request for Certification/Affidavit of License';
	private final static String COSBAR_RECIPROCITY_REJECTION_NOTIFICATION = 'Cos_Bar_Reciprocity_Rejection';
	private final static String COSBAR_EXAM_SCORE_ENDORSEMENT_REJECTION_NOTIFICATION = 'Cos_Bar_Exam_Score_Endorsement_Rejection';
	private final static String COSBAR_REQ_CERT_AFFIDAVIT_REJECTION_NOTIFICATION = 'Cos_Bar_Certificate_Affidavit_Rejection';
	private final static String COSBAR_RECIPROCITY_BOARD_REVIEW_NOTIFICATION = 'Cos_Bar_Notification_of_Board_Letter';
	private final static String COSBAR_STUDENT_BOARD_MEETING_NOTIFICATION = 'CosBar_Student_Board_Meeting_Letter';
	private final static String COSBAR_CERT_IDENTIFICATION_REJECTION_NOTIFICATION = 'CosBarCertificateIdentificationRejection';
    private final static String COSBAR_REINSTATEMENT_REJECTION_NOTIFICATION = 'CosBarReinstatementRejection';
    private final static String COSBAR_REACTIVATION_REJECTION_NOTIFICATION = 'CosBarReactivationRejection';
	private final static String LICENSURE_NOTIFICATION_TYPE = 'Licensure Notification';
	public final static String EMBALMERS_AND_FUNERAL_BOARD_NAME = 'Embalmers & Funeral Directors';
	private static final Set<String> COSBAR_REJECTION_EMAIL_APPLICABLE_TYPE_SET = new Set<String>{
		REINSTATEMENT_BY_EXAM,
		IA_TYPE_REQUEST_CERTIFICATION_AFFIDAVIT,
		LICENSURE_NOTIFICATION_TYPE,
		IA_TYPE_CERTIFICATE_OF_IDENTIFICATION,
		LPI_LiteralConstant.IA_REINSTATEMENT_APPLICATIONTYPE,
		LPI_LiteralConstant.PAR_SOBJECT_TYPE_REACTIVATION
	};
	private static final String EXAMINATION_RESULT_PASS = 'Pass';
	public static final String REINSTATEMENT_BY_EXAM_REJECT_NOTIFICATION = 'CosbarReinstatetByExamRejectNotification';
	private final static Set<String> STUDENT_LICENSE_TYPES_SET = 
		new Set<String>{'Barber Student', 'Cosmetology Student', 'Cosmetology Instructor Trainee'};
    private final static String HEALING_ARTS_BOARD = 'Healing Arts'; 
	private static final Set<String> GRANDFATHER_INDICATOR_APPLICABLE_LICENSES_SET = new Set<String>{
		'Registered Nurse',
		'Licensed Practical Nurse'
	};
	private static final String VALUE_NA = 'NA';
	private final static String PAR_AMENDMENT_SUBTYPE_NAME_OR_ADDRESS_CHANGE = 'Change of Name and/or Residence Address';
	private final static String LOCATION_TYPE_RESIDENCE = 'Residence';
	private final static Set<String> STATUS_FOR_OWNER_UPDATE_SET = new Set<String>{
		'Ready for ED Approval',
		'Approved'
	};
	private final static String LICENSE_ISSUED_STATUS = 'License Issued';
    private static final String PASSED_STATUS = 'Passed';
    private final static Set<String> licensureNotiRATSet = new Set<String>{
        'Barber',
        'Class CA - Hairdressing and Manicuring',
        'Class CH - Hairdresser',
        'Class E - Estheticians',
        'Class MO - Manicurist',
        'Cosmetologist/All-Barber',
        'Cosmetologist/Hair-Barber',
        'Barber Instructor',
        'Cosmetology Instructor',
        'Cosmetology/Barber Instructor'
    };
	private static final Set<String> RN_LPN_LICENSE_TYPES = new Set<String>{
		'Registered Nurse',
		'Licensed Practical Nurse'
	};
	private static final Set<String> RN_LPN_NO_STANDARD_REJECTION_EMAIL_NCLEX_EXAM_VALUES = new Set<String>{
		'No-show',
		'Failed'
	};
    private static final Map<String,String> estateAppraiserTraineeMap = new Map<String,String>{
        'State Licensed Real Estate Appraiser' => 'State Licensed Appraiser Trainee',
        'State Certified Residential Real Estate Appraiser' => 'State Certified Residential Appraiser Trainee',
        'State Certified General Real Estate Appraiser' => 'State Certified General Appraiser Trainee'
    };
    private static final String ADD_APRN_CERT_TYPE = 'Add APRN Certification';
    private static final Set<String> PROF_CORP_NAME_APPROVAL_SET = new Set<String>{
		'Assistant Physician'
	};
	private static final String PROFESSIONAL_CORPORATION_NAME_APPROVAL = 'Apply for Professional Corporation Name Approval';
	private static final String TYPE_APPLY_FOR_PROFESSIONAL_CORPORATION = 'Apply for Professional Corporation';
	private static final Map<String, String> PROF_CORP_CONVERT_LICENSE_TYPES_MAP = new Map<String, String>{
		'Salesperson' => 'Prof. Corp. Salesperson',
		'Broker Salesperson' => 'Prof. Corp. Broker Salesperson'
	};
	private static final String CLASSIFICATION_PROFESSIONAL_CORPORATION = 'Professional Corporation'; 
	private static final String CITIZENSHIP_FOREIGN = 'FOREIGN';
	private final static Set<String> OWNER_UPDATE_TO_FOR_SUPERVISOR_REVIEW_SET = new Set<String>{
	    'Temp. Pharmacist' 
	}; 
	private final static String CANCELED_STATUS = 'Canceled';
	private final static String CLOSED_STATUS = 'Closed';
    private final static String EXPIRATION_PERIOD = '180 Days';
	private static final String LICENSE_TYPE_REAL_ESTATE_SALESPERSON = 'Real Estate Salesperson';
	private static final String LICENSE_TYPE_INDIVIDUAL_INSURANCE_AGENT = 'Individual Insurance Agent';
	private static final String REVIEWER_NAME_IIA = 'Marie LeBlanc';
	private static final String REVIEWER_PROFILE_IIA = 'Agent Review Portal User';
	private static final String REVIEWER_NAME_RES = 'Employer Portal user';
	private static final String REVIEWER_PROFILE_RES = 'Employer Portal User';

	private static Id cachedReviewerIdForIia;
	private static Id cachedReviewerIdForRes;
	private static Boolean reviewerIdsResolved = false;
    private static final String PLS_STATE_EXAM = 'PLS State Exam';
    private static final String PLS_STATE_RE_EXAM = 'PLS State Re-Exam';
	private final static String READY_FOR_ED_APPROVAL_STATUS = 'Ready For ED Approval';
	private static final String NCSBN_ELIGIBILITY_TO_TEST_ELIGIBLE = 'Eligible';
	private static final String APPROVED = 'Approved';
    private static final Set<String> PLS_STATE_EXAM_SET = new Set<String>{PLS_STATE_EXAM, PLS_STATE_RE_EXAM};


    /**
    * @description 
    * @author MTX Group Product Team | 05-06-2024 
    * @param recordsList 
    **/

    public static void beforeInsertHelper(List<IndividualApplication> recordsList) {
        List<IndividualApplication> iaHavingLicenseTypeList = new List<IndividualApplication>();
        List<IndividualApplication> priorityApplicationList = new List<IndividualApplication>();
        Set<Id> lpnIvCertifiedaccountIdSet = new Set<Id>();
        Map<Id, IndividualApplication> appToUpdateMap = new Map<Id, IndividualApplication>();
        for (IndividualApplication newIARecord : recordsList) {
            if (String.isNotBlank(newIARecord.LicenseTypeId)) {
                iaHavingLicenseTypeList.add(newIARecord);
            }
            if ((newIARecord.Status__c == LPI_LiteralConstant.IA_SUBMITTED_STATUS) || (newIARecord.Status__c == LPI_LiteralConstant.IA_PAYMENT_PENDING_STATUS && newIARecord.Payment_Pending__c != false)){
                priorityApplicationList.add(newIARecord);
            }
        }
        if (!iaHavingLicenseTypeList.isEmpty()) {
            updatePreRequiredFields(iaHavingLicenseTypeList);
        }
        if (!priorityApplicationList.isEmpty()) {
            LPI_ApplicationPriority.updatePriorityApplication(priorityApplicationList);
        }
    }

    /**
    * @description 
    * @author MTX Group Product Team | 05-06-2024 
    * @param recordsList 
    * @param mapOfOldRecords 
    **/

    public static void afterInsertHelper( List<IndividualApplication> recordsList, 
        Map<Id, IndividualApplication> mapOfOldRecords ){
		List<IndividualApplication> isParPresentIAList = new List<IndividualApplication>();
        List<IndividualApplication> isIASubmittedList = new List<IndividualApplication>();
        List<IndividualApplication> isWorkflowIAList = new List<IndividualApplication>();
        for (IndividualApplication newIARecord : recordsList) {
            if(String.isNotBlank(newIARecord.Workflow__c)) {
                isWorkflowIAList.add(newIARecord);
            }
			if(String.isNotBlank(newIARecord.SavedApplicationRefId)) {
				isParPresentIAList.add(newIARecord);
			}
			isIASubmittedList.add(newIARecord);
        }
        if(!isWorkflowIAList.isEmpty()) {
            createDueDiligence(isWorkflowIAList);
        }
		if(!isParPresentIAList.isEmpty()){
			afterInsertFunctioanlity(isParPresentIAList);
		}

		if(!isIASubmittedList.isEmpty()){
			LPI_TriggerServiceUtility.createNotifications(isIASubmittedList);
		}
    }

    /**
    * @description 
    * @author MTX Group Product Team | 05-06-2024 
    * @param recordsList 
    * @param mapOfOldRecords 
    **/
    public static void afterUpdateHelper(List<IndividualApplication> recordsList,Map<Id, IndividualApplication> mapOfOldRecords) {

		List<IndividualApplication> amendmentIAList = new List<IndividualApplication>();
		Set<Id> funeralInchargeIASet = new Set<Id>();
		List<IndividualApplication> certificationIAList = new List<IndividualApplication>();
		List<IndividualApplication> approvedRejectedIssuedIAList = new List<IndividualApplication>();
		List<IndividualApplication> afterLicenseIssuedIAList = new List<IndividualApplication>();
		List<IndividualApplication> amendmentsIAList = new List<IndividualApplication>();
		List<IndividualApplication> havingBLIdIAList = new List<IndividualApplication>();
		List<IndividualApplication> medOsteoIAList = new List<IndividualApplication>();
		List<IndividualApplication> ownerIdChangeList=new List<IndividualApplication>();
        List<IndividualApplication> approvedIaList = new List<IndividualApplication>();
        List<IndividualApplication> rejectedIaList = new List<IndividualApplication>();
		List<IndividualApplication> updateCertificationDateList = new List<IndividualApplication>();
		List<IndividualApplication> apprenticeApprovedRejectedIssuedIAList = new List<IndividualApplication>();
		List<IndividualApplication> approvedIaListForTwoByTwoPhoto = new List<IndividualApplication>();
		List<IndividualApplication> exemptionIaList = new List<IndividualApplication>();
		List<IndividualApplication> validationForApprovedStatusList = new List<IndividualApplication>();
        List<IndividualApplication> updateThreeAddressFieldIaList = new List<IndividualApplication>();
		List<IndividualApplication> parentChildRelationList =  new List<IndividualApplication>();
		List<IndividualApplication> autoRenewList = new List<IndividualApplication>();
		List<IndividualApplication> updateLicensePrintInicatorIAList = new List<IndividualApplication>();
		List<IndividualApplication> updateWallHangingPrintIndicatorIAList = new List<IndividualApplication>();
		Set<String> setRNLPNLicenseName = new Set<String>{
			LPI_LiteralConstant.IA_LICENSED_PRACTICAL_NURSE ,
			LPI_LiteralConstant.IA_REGISTERED_NURSE
		};
		Set<String> setAncillaryApplicationType = new Set<String>{
			LICENSE_TYPE_GRADUATE_NURSE_RELEASE_FORM,
			LICENSE_TYPE_EXAM_MODIFICATIONS
		};
		Set<String> SETOFAPPRENTICELICENSES = new Set<String>{
			'Barber Apprentice',
			'Cosmetology Apprentice',
			'COSBAR Apprentice Supervisor',
			'Hair Braiding'
		};
		Set<Id> setOfBlId = new Set<Id>();
		Set<Id> blIdSet = new Set<Id>();
		Set<Id> setOfRatId = new Set<Id>();
		for (IndividualApplication newIARecord : recordsList) {
			if(String.isNotEmpty(newIARecord.LicensePermitNameId)) {
				setOfBlId.add(newIARecord.LicensePermitNameId);
			}
			if(String.isNotEmpty(newIARecord.LicenseTypeId)){
				setOfRatId.add(newIARecord.LicenseTypeId);
			}
		}
		Map<Id, BusinessLicense> blIdmap = new Map<Id, BusinessLicense>();
		Set<Id> individualAppIdSet = new Set<Id>();
		Set<Id> updateOwnerIdSet = new Set<Id>();
		if(!setOfBlId.isEmpty()){
			blIdmap = new Map<Id,BusinessLicense>(LPI_BusinessLicenseDAO.fetchBusinessLicenseRecords(
					'Id, Is_Migrated_Data__c',
				'Id IN ' + LPI_ServiceUtility.getStringValuesBySet(setOfBlId)));
		}
		Set<String> setOfConfiguredChildLicense = new Set<String>();
		List<IndividualApplication> profCorpNameApprovalIAList = new List<IndividualApplication>();
		List<IndividualApplication> stateExamIAList = new List<IndividualApplication>();

		for (IndividualApplication newIARecord : recordsList) {
			if(LPI_LiteralConstant.PAR_SOBJECT_TYPE_AMENDMENT.equalsIgnoreCase(newIARecord.ApplicationType) &&
				LPI_LiteralConstant.PAR_AMENDMENT_SUBTYPE_STATUS_CHANGE.equalsIgnoreCase(newIARecord.Amendment_Type__c) &&
				LPI_LiteralConstant.IA_SUBMITTED_STATUS.equalsIgnoreCase(newIARecord.Status) &&
				(mapOfOldRecords == null ||
				(!LPI_LiteralConstant.IA_SUBMITTED_STATUS.equalsIgnoreCase(mapOfOldRecords?.get(newIARecord.Id)?.Status)))){
				amendmentIAList.add(newIARecord);
			}
            if (
                ((mapOfOldRecords != null &&
                  mapOfOldRecords.get(newIARecord.Id).Status != LPI_LiteralConstant.IA_SUBMITTED_STATUS &&
                  newIARecord.Status == LPI_LiteralConstant.IA_SUBMITTED_STATUS) ||
                 (mapOfOldRecords == null &&
                  newIARecord.Status == LPI_LiteralConstant.IA_SUBMITTED_STATUS)) &&
                (LPI_LiteralConstant.EMBALMER_INCHARGE_LICENSE_SET.Contains(newIARecord.License_Type_Name__c) &&
				(newIARecord.ApplicationType == LPI_LiteralConstant.IA_NEW_APPLICATIONTYPE ||
				  (newIARecord.ApplicationType == LPI_LiteralConstant.IA_AMENDMENT_APPLICATIONTYPE && newIARecord.Amendment_Type__c == LPI_LiteralConstant.AMENDMENT_TYPE_ADD_UPDATE_SUPERVISOR_OR_LOCATION)) &&
                 newIARecord.AccountId != null)
            ) {
                funeralInchargeIASet.add(newIARecord.Id);
            }
			if(newIARecord.Status == LPI_LiteralConstant.IA_LICENSEISSUED_STATUS &&
				newIARecord.Status != mapOfOldRecords.get(newIARecord.Id).Status &&
				
				(newIARecord.License_Type_Name__c == LPI_LiteralConstant.IA_PHYSICIAN_ASSISTANT_LICENSE ||
				newIARecord.License_Type_Name__c == LPI_LiteralConstant.IA_ASSISTANT_PHYSICIAN_LICENSE) 
				
			) {
				certificationIAList.add(newIARecord);
			}
			if (
				(
				(mapOfOldRecords.get(newIARecord.Id).Status != LPI_LiteralConstant.BLA_REJECTED_STATUS &&
				newIARecord.Status == LPI_LiteralConstant.BLA_REJECTED_STATUS &&
				(!(COS_BAR_OPERATORS_AND_INSTRUCTORS.contains(newIARecord.License_Type_Name__c) &&
				newIARecord.ApplicationType == LPI_LiteralConstant.IA_NEW_APPLICATIONTYPE &&
				(newIARecord.Amendment_Type__c == IA_SUB_TYPE_RECIPROCITY ||
				newIARecord.Amendment_Type__c == IA_SUB_TYPE_EXAM_SCORE_ENDORSEMENT))) &&
				(!(CERTIFICATE_IDENTIFICATION_ALLOWED_LIC_TYPES.contains(newIARecord.License_Type_Name__c) && 
				COSBAR_REJECTION_EMAIL_APPLICABLE_TYPE_SET.contains(newIARecord.ApplicationType))) &&
				(!(STUDENT_LICENSE_TYPES_SET.contains(newIARecord.License_Type_Name__c) && 
				newIARecord.ApplicationType == LPI_LiteralConstant.IA_NEW_APPLICATIONTYPE &&
				newIARecord.Amendment_Type__c == LPI_LiteralConstant.IA_NEW_APPLICATIONTYPE)) &&
				(!(RN_LPN_LICENSE_TYPES.contains(newIARecord.License_Type_Name__c) &&
					newIARecord.ApplicationType == LPI_LiteralConstant.IA_NEW_APPLICATIONTYPE /*&&
				   RN_LPN_NO_STANDARD_REJECTION_EMAIL_NCLEX_EXAM_VALUES.contains(newIARecord.NCLEX_Examination_Status__c)*/)))||
				(mapOfOldRecords.get(newIARecord.Id).Status != LPI_LiteralConstant.IA_LICENSEISSUED_STATUS &&
                     newIARecord.Status == LPI_LiteralConstant.IA_LICENSEISSUED_STATUS && 
                     (!(GRANDFATHER_INDICATOR_APPLICABLE_LICENSES_SET.contains(newIARecord.License_Type_Name__c) && 
                        newIARecord.ApplicationType == LPI_LiteralConstant.PAR_SOBJECT_TYPE_INACTIVATION)))) &&
				(!(SETOFAPPRENTICELICENSES.contains(newIARecord.License_Type_Name__c) &&
				newIARecord.ApplicationType == LPI_LiteralConstant.IA_NEW_APPLICATIONTYPE &&
				newIARecord.Amendment_Type__c == LPI_LiteralConstant.IA_NEW_APPLICATIONTYPE)) &&
				(newIARecord.ApplicationType != 'Abbreviated Application for Exams' || 
				newIARecord.License_Type_Name__c != 'Temp Permit - BEHIS')
			) {
				approvedRejectedIssuedIAList.add(newIARecord);
			}
			if(setOfConfiguredChildLicense.contains(newIARecord.LicenseTypeId)){
				if(newIARecord.ApplicationType == LPI_LiteralConstant.IA_RENEWAL_APPLICATIONTYPE &&
			 	   newIARecord.Status == LPI_LiteralConstant.BLA_SUBMITTED_STATUS){
					autoRenewList.add(newIARecord);
				}
			}
			if (
				newIARecord.Status != mapOfOldRecords.get(newIARecord.Id).Status &&
				newIARecord.Status == LPI_LiteralConstant.IA_LICENSEISSUED_STATUS
			) {
				if(setOfConfiguredChildLicense.contains(newIARecord.LicenseTypeId)){
					if(newIARecord.ApplicationType == LPI_LiteralConstant.IA_NEW_APPLICATIONTYPE ||
				  	   newIARecord.ApplicationType == LPI_LiteralConstant.IA_RENEWAL_APPLICATIONTYPE){
						parentChildRelationList.add(newIARecord);
					}
				}
				exemptionIaList.add(newIARecord);
                updateThreeAddressFieldIaList.add(newIARecord);
				validationForApprovedStatusList.add(newIARecord);
                 if (
                    /*(newIARecord.Behavior_Analyst_License_Number__c == null) &&*/
                    (newIARecord.License_Type_Name__c != APPRENTICESHIP) &&
                    (!((setRNLPNLicenseName.contains(newIARecord.License_Type_Name__c) ||
                       (licensureNotiRATSet.contains(newIARecord.License_Type_Name__c) && String.isBlank(newIARecord.Temporary_License_Number__c) && String.isBlank(newIARecord.LicensePermitNameId))) &&
                       newIARecord.Issue_Temp_License__c)) &&
                    !((newIARecord.License_Type_Name__c == LICENSE_INTERPRETER ||
                       PSYCHOLOGIST_LICENSE_LIST.contains(newIARecord.License_Type_Name__c)) &&
                      String.isNotBlank(newIARecord.LicensePermitNameId)) &&
                    !(geologistLicenseTypeSet.contains(newIARecord.License_Type_Name__c) &&
                      AMENDMENT_TYPE_EXAMINATION.equalsIgnoreCase(newIARecord.Amendment_Type__c) 
                     ) && (!(IDENTIFICATION_CARD_SET.contains(newIARecord.Amendment_Type__c)))
                ) {
                    afterLicenseIssuedIAList.add(newIARecord);
                }
					if(LPI_LiteralConstant.IA_AMENDMENT_APPLICATIONTYPE.equalsIgnoreCase(newIARecord.ApplicationType) || 
					    (blIdmap.containsKey(newIARecord.LicensePermitNameId) && blIdmap.get(newIARecord.LicensePermitNameId).Is_Migrated_Data__c)){
					amendmentsIAList.add(newIARecord);
				}
					if(String.isNotBlank(newIARecord.LicensePermitNameId)) { 
					havingBLIdIAList.add(newIARecord);
				}
			} else if (
				mapOfOldRecords.get(newIARecord.Id).Issue_Temp_License__c != newIARecord.Issue_Temp_License__c &&
				newIARecord.Issue_Temp_License__c &&
				String.isBlank(newIARecord.LicensePermitNameId)
			) {
		
			}
			if (
				newIARecord.Status == LPI_LiteralConstant.IA_SUBMITTED_STATUS &&
				(mapOfOldRecords == null ||
				mapOfOldRecords.get(newIARecord.Id).Status != newIARecord.Status) &&
				HEALING_ARTS_BOARD.equalsIgnoreCase(newIARecord.Board_Name__c)){
				medOsteoIAList.add(newIARecord);
			}
			if(mapOfOldRecords.get(newIARecord.Id).OwnerId != newIARecord.OwnerId) {
				ownerIdChangeList.add(newIARecord);
			}
            if (
				mapOfOldRecords.get(newIARecord.Id).Status != newIARecord.Status &&
				newIARecord.Status == LPI_LiteralConstant.IA_APPROVED_STATUS
			) {
				approvedIaListForTwoByTwoPhoto.add(newIARecord);
				if (PROF_CORP_NAME_APPROVAL_SET.contains(newIARecord.License_Type_Name__c) &&
					newIARecord.ApplicationType == LPI_LiteralConstant.IA_AMENDMENT_APPLICATIONTYPE &&
					newIARecord.Amendment_Type__c == PROFESSIONAL_CORPORATION_NAME_APPROVAL){
					profCorpNameApprovalIAList.add(newIARecord);
				}
			}
			if (
				((mapOfOldRecords.get(newIARecord.Id).Status != LPI_LiteralConstant.IA_APPROVED_STATUS &&
				newIARecord.Status == LPI_LiteralConstant.IA_APPROVED_STATUS ) ||
				(mapOfOldRecords.get(newIARecord.Id).Status != LPI_LiteralConstant.BLA_SUBMITTED_STATUS &&
				newIARecord.Status == LPI_LiteralConstant.BLA_SUBMITTED_STATUS)||
				(mapOfOldRecords.get(newIARecord.Id).Status != LPI_LiteralConstant.BLA_REJECTED_STATUS &&
				newIARecord.Status == LPI_LiteralConstant.BLA_REJECTED_STATUS) ||
				(mapOfOldRecords.get(newIARecord.Id).Status != LPI_LiteralConstant.IA_LICENSEISSUED_STATUS &&
				newIARecord.Status == LPI_LiteralConstant.IA_LICENSEISSUED_STATUS))
			) {
				apprenticeApprovedRejectedIssuedIAList.add(newIARecord);
			}
			if(newIARecord.Status == STATUS_BOARD_REVIEW &&
			newIARecord.Status != mapOfOldRecords.get(newIARecord.Id).Status){
			}
			if (
				mapOfOldRecords.get(newIARecord.Id).Status != LPI_LiteralConstant.BLA_REJECTED_STATUS &&
				newIARecord.Status == LPI_LiteralConstant.BLA_REJECTED_STATUS)
            {
				
            }
			if (mapOfOldRecords.get(newIARecord.Id).Status != newIARecord.Status && newIARecord.Status == LPI_LiteralConstant.IA_LICENSEISSUED_STATUS) { 
				approvedIaListForTwoByTwoPhoto.add(newIARecord);
            }	
			if(mapOfOldRecords.get(newIARecord.Id).Status != newIARecord.Status
				&& (STATUS_FOR_OWNER_UPDATE_SET.contains(newIARecord.Status)
				|| (mapOfOldRecords.get(newIARecord.Id).Status == READY_FOR_ED_APPROVAL_STATUS
				&& newIARecord.Status == LICENSE_ISSUED_STATUS))
			){
				updateOwnerIdSet.add(newIARecord.Id);
			}
			if (
				(mapOfOldRecords.get(newIARecord.Id).Status != LPI_LiteralConstant.IA_APPROVED_STATUS &&
                newIARecord.Status == LPI_LiteralConstant.IA_APPROVED_STATUS &&
				newIARecord.Board_Name__c.equalsIgnoreCase('Veterinary')) || 
				(mapOfOldRecords.get(newIARecord.Id).Status != LPI_LiteralConstant.IA_SUBMITTED_STATUS &&
                newIARecord.Status == LPI_LiteralConstant.IA_SUBMITTED_STATUS &&
				newIARecord.Board_Name__c.equalsIgnoreCase('Dental')) &&
				(newIARecord.ApplicationType == LPI_LiteralConstant.IA_NEW_APPLICATIONTYPE)){
				stateExamIAList.add(newIARecord);
			}

			if(mapOfOldRecords.get(newIARecord.Id).Status != newIARecord.Status && newIARecord.Status == LICENSE_ISSUED_STATUS  && newIARecord.ApplicationType == 'Renewal'){
				updateLicensePrintInicatorIAList.add(newIARecord);
			}
			if(mapOfOldRecords.get(newIARecord.Id).Status != newIARecord.Status && newIARecord.Status == LICENSE_ISSUED_STATUS  && newIARecord.ApplicationType == REQUEST_FOR_DUPLICATE_WALLHANGING_LICENSE){
				updateWallHangingPrintIndicatorIAList.add(newIARecord);
			}
        }
		if(!afterLicenseIssuedIAList.isEmpty()){
			createBusinessLicenseOnLicesneIssued(afterLicenseIssuedIAList, mapOfOldRecords);
			sendNotificationToApprentice(afterLicenseIssuedIAList);
			createBoutAgreementOnApproval(afterLicenseIssuedIAList);
			assignIDCardToLicenseeOnApproval(afterLicenseIssuedIAList);
			changeVerificationStatusForEmploymentHistory(afterLicenseIssuedIAList);
			changeVerificationStatusForEducationHistory(afterLicenseIssuedIAList);
		}

		if(!approvedRejectedIssuedIAList.isEmpty()){
			system.debug('$$##');
		}
		if(!havingBLIdIAList.isEmpty()){
			updateBusinessLicenseStatusOnApproval(havingBLIdIAList);
			updateBLOnIALicenseIssued(havingBLIdIAList);
			updateRequiredPermitsOnBL(havingBLIdIAList);
			cloneAppConToLicCon(havingBLIdIAList);
			updateExpiryDateOnBL(havingBLIdIAList);
			updateBlOnAuthApplicationPlace(havingBLIdIAList);
			LPI_TriggerServiceUtility.linkNotesFromApplicationToLicense(havingBLIdIAList);
		}
		if(!amendmentsIAList.isEmpty()){
			performAmendmentOnBusinessLicense(amendmentsIAList, blIdmap);
			LPI_TriggerServiceUtility.linkAuditEscrowToBl(amendmentsIAList);
		}
        if(!havingBLIdIAList.isEmpty())
		{
			updatelocationStatusOnBLWhenIsMigratedDataTrue(havingBLIdIAList,mapOfOldRecords);
		}
		if(!apprenticeApprovedRejectedIssuedIAList.isEmpty()){
			sendNotificationToApprentice(apprenticeApprovedRejectedIssuedIAList);
		}
		
		if(!blIdSet.isEmpty())
		{
			updateMailingAddressTOBL(blIdSet, MAILING_ADDRESS);
		}
	}

    /**
    * @description 
    * @author MTX Group Product Team | 05-06-2024 
    * @param recordsList 
    **/

    public static void updatePreRequiredFields(List<IndividualApplication> recordsList) {
		try {
			Map<IndividualApplication, Id> individualAppToLicenseTypeNameMap = new Map<IndividualApplication, Id>();
			for (IndividualApplication newIARecord : recordsList) {
				individualAppToLicenseTypeNameMap.put(newIARecord, newIARecord.LicenseTypeId);
			}
			if (!individualAppToLicenseTypeNameMap.isEmpty()){
				Map<Id, String> ratToBoardNameMap = new Map<Id, String>();
				Map<Id, String> ratIdToNameMap = new Map<Id, String>();
				Map<String, Regulatory_Auth_Type_WorkFlow__c> mapOfRegWorkflow = new Map<String, Regulatory_Auth_Type_WorkFlow__c>();
				Set<Id> ratIdSet = new Set<Id>(individualAppToLicenseTypeNameMap.values());
				for(Regulatory_Auth_Type_WorkFlow__c regW : LPI_RegulatoryAuthTypeWorkFlowDAO.getRATWorkflowByRATIdAndRecordTypeDevName(
						ratIdSet,
						'Workflow')){
					mapOfRegWorkflow.put(regW.Regulatory_Authorization_Type__c + '-' + regW.Type__c + '-' + regW.Sub_Type__c, regW);
				}
				for(RegulatoryAuthorizationType ratRecord : LPI_RegulatoryAuthorizationTypeDAO.getRATTypeByID(ratIdSet)) {
					ratToBoardNameMap.put(ratRecord.Id, ratRecord.IssuingDepartment.Name);
					ratIdToNameMap.put(ratRecord.Id, ratRecord.Name);
				}
				Map<String, Id> iaRecordTypeByDevName = new Map<String, Id>();
				for (Schema.RecordTypeInfo rti : Schema.SObjectType.IndividualApplication.getRecordTypeInfosByDeveloperName().values()) {
					if (rti.isAvailable()) {
						iaRecordTypeByDevName.put(rti.getDeveloperName(), rti.getRecordTypeId());
					}
				}
				for (IndividualApplication iaRecord : individualAppToLicenseTypeNameMap.keySet()) {
					if (mapOfRegWorkflow.containsKey(iaRecord.LicenseTypeId + '-' + iaRecord.ApplicationType + '-' + iaRecord.Amendment_Type__c)) {
						iaRecord.Workflow__c = mapOfRegWorkflow.get(iaRecord.LicenseTypeId + '-' + iaRecord.ApplicationType + '-' + iaRecord.Amendment_Type__c).Workflow__c;
					}
					if (ratToBoardNameMap.containsKey(iaRecord.LicenseTypeId)) {
						iaRecord.Board_Name__c = ratToBoardNameMap.get(iaRecord.LicenseTypeId);
					}
					String licenseTypeName = ratIdToNameMap.get(iaRecord.LicenseTypeId);
					if (licenseTypeName == LICENSE_TYPE_REAL_ESTATE_SALESPERSON && iaRecordTypeByDevName.containsKey('Real_Estate_Sales_Person')) {
						iaRecord.RecordTypeId = iaRecordTypeByDevName.get('Real_Estate_Sales_Person');
					} else if (licenseTypeName == LICENSE_TYPE_INDIVIDUAL_INSURANCE_AGENT && iaRecordTypeByDevName.containsKey('Insurance_Agent_Application')) {
						iaRecord.RecordTypeId = iaRecordTypeByDevName.get('Insurance_Agent_Application');
					}
					assignReviewerByLicenseType(iaRecord, licenseTypeName);
				}
			}
		} catch (Exception ex) {
			LPI_ExceptionManager.logException(getClassName(), 'updatePreRequiredFields', ex);
		}
	}

	/**
	 * Assigns Reviewer__c on Individual Application submit/create:
	 * Robust and case-insensitive check to assign Reviewer User.
	 */
	private static void assignReviewerByLicenseType(IndividualApplication iaRecord, String licenseTypeName) {
		if (iaRecord == null || String.isBlank(licenseTypeName)) {
			return;
		}
		resolveReviewerUserIds();
		if (LICENSE_TYPE_INDIVIDUAL_INSURANCE_AGENT.equalsIgnoreCase(licenseTypeName) && cachedReviewerIdForIia != null) {
			iaRecord.Reviewer__c = cachedReviewerIdForIia;
		} else if (LICENSE_TYPE_REAL_ESTATE_SALESPERSON.equalsIgnoreCase(licenseTypeName) && cachedReviewerIdForRes != null) {
			iaRecord.Reviewer__c = cachedReviewerIdForRes;
		}
	}

	/**
	 * Resolves reviewer user IDs without sharing.
	 * Includes fallbacks to handle Name/Profile case-insensitivity and whitespace mismatches.
	 */
	private static void resolveReviewerUserIds() {
		if (reviewerIdsResolved && (cachedReviewerIdForIia != null || cachedReviewerIdForRes != null)) {
			return;
		}
		reviewerIdsResolved = true;

		List<User> reviewerUsers = new ReviewerUserLookup().queryActiveReviewers();
		for (User reviewerUser : reviewerUsers) {
			String uName = reviewerUser.Name != null ? reviewerUser.Name.trim().toLowerCase() : '';
			String pName = (reviewerUser.Profile != null && reviewerUser.Profile.Name != null) ? reviewerUser.Profile.Name.trim().toLowerCase() : '';

			if (cachedReviewerIdForIia == null && 
				(uName.equalsIgnoreCase(REVIEWER_NAME_IIA) || pName.equalsIgnoreCase(REVIEWER_PROFILE_IIA))) {
				cachedReviewerIdForIia = reviewerUser.Id;
			}
			
			if (cachedReviewerIdForRes == null && 
				(uName.equalsIgnoreCase(REVIEWER_NAME_RES) || pName.equalsIgnoreCase(REVIEWER_PROFILE_RES))) {
				cachedReviewerIdForRes = reviewerUser.Id;
			}
		}
	}

	private without sharing class ReviewerUserLookup {
		private List<User> queryActiveReviewers() {
			Set<String> reviewerNames = new Set<String>{ 
				REVIEWER_NAME_IIA, 
				REVIEWER_NAME_RES, 
				'Employer Portal User' 
			};
			Set<String> reviewerProfiles = new Set<String>{ 
				REVIEWER_PROFILE_IIA, 
				REVIEWER_PROFILE_RES 
			};
			return [
				SELECT Id, Name, Profile.Name
				FROM User
				WHERE IsActive = TRUE
					AND (Name IN :reviewerNames OR Profile.Name IN :reviewerProfiles)
			];
		}
	}

    /**
    * @description 
    * @author Ayush Dev | 05-06-2024 
    * @param recordsList 
    **/

    public static void createDueDiligence(List<IndividualApplication> recordsList) {
		try {
			LPI_TriggerServiceUtility.createDueDiligenceRecord(recordsList);
		} catch (Exception e) {
			LPI_ExceptionManager.logException(getClassName(), 'createDueDiligence', e);
			throw new AuraHandledException(e.getMessage() + e.getLineNumber());
		}
	}
	/**
     * @author                      : MTX Group Product Team
     * @since                       : July 28, 2023
     * @description                 : This method is before Update helper method for CRR Applications
     * @param recordsList           : It contains List of Application records
	 * @param mapOfOldRecords       : It contains old Map of records
     * @return                      : void
     * @last modified by            : Uzma Md
     * @last modified date          :
     * @last modified details       :
     * @story Numbers               : S-51313
     */

	public static void beforeUpdateForCRRApplications(
		List<IndividualApplication> recordsList,
		Map<Id, IndividualApplication> mapOfOldRecords
	){
		try{
			beforeUpdateHelper(recordsList,mapOfOldRecords);
		}catch(Exception e){
			LPI_ExceptionManager.logException(getClassName(), 'beforeUpdateForCRRApplications', e);
		}
		
	}

	/**
	* @description 
	* @author MTX Group Product Team | 05-06-2024 
	* @param recordsList 
	**/

	public static void afterInsertFunctioanlity(List<IndividualApplication> recordsList) {
		try {
			List<RegulatoryTrxnFee> trxnFeeList = new List<RegulatoryTrxnFee>();
			List<RegulatoryTrxnFeeItem> trxnFeeItemList = new List<RegulatoryTrxnFeeItem>();
			Map<Id, Id> parIdWithIaIds = new Map<Id, Id>();
			Map<Id, List<Temp_Fee__c>> iaIdsWithListTempFee = new Map<Id, List<Temp_Fee__c>>();
			for (IndividualApplication iaRecord : recordsList) {
				parIdWithIaIds.put(iaRecord.SavedApplicationRefId, iaRecord.Id);
			}
			if (!parIdWithIaIds.isEmpty()) {
				LPI_TriggerServiceUtility.createRegulatoryTrxnFeeAndFeeItemRec(parIdWithIaIds);
				LPI_TriggerServiceUtility.createAuthApplicationPlace(parIdWithIaIds);
				LPI_TriggerServiceUtility.createApplicationContentRecord(parIdWithIaIds);
				LPI_TriggerServiceUtility.createPersonExaminationRecord(parIdWithIaIds);
			}
		} catch (Exception e) {
			LPI_ExceptionManager.logException(getClassName(), 'afterInsertFunctioanlity', e);
		}
	}
	/**
     * @author                      : MTX Group Product Team
     * @since                       : July 28, 2023
     * @description                 : This method is after Insert helper method for CRR Applications
     * @param recordsList           : It contains List of Application records
	 * @param mapOfOldRecords       : It contains old Map of records
     * @return                      : void
     * @last modified by            : Uzma Md
     * @last modified date          :
     * @last modified details       :
     * @story Numbers               : S-51313
     */
	public static void afterInsertForCRRApplications(
		List<IndividualApplication> recordsList,
		Map<Id, IndividualApplication> mapOfOldRecords
	){
		try{
			List<IndividualApplication> isWorkflowIAList = new List<IndividualApplication>();
			Map<Id, Id> parIdWithIaIds = new Map<Id, Id>();
			for (IndividualApplication newIARecord : recordsList) {
				if(String.isNotBlank(newIARecord.Workflow__c)){
					isWorkflowIAList.add(newIARecord);
				}
				if(newIARecord.SavedApplicationRefId != null){
					parIdWithIaIds.put(newIARecord.SavedApplicationRefId, newIARecord.Id);
				}
			}
			if(!isWorkflowIAList.isEmpty()) {
				createDueDiligence(isWorkflowIAList);
			}	
			if(!parIdWithIaIds.isEmpty()){
				LPI_TriggerServiceUtility.createRegulatoryTrxnFeeAndFeeItemRec(parIdWithIaIds);
			}
		}catch(Exception e){
			LPI_ExceptionManager.logException(getClassName(), 'afterInsertForCRRApplications', e);
		}
	}

	/**
	* @description This method is used to to filter out the records and call respective method.
	* @author MTX Group Product Team | 05-06-2024 
	* @param recordsList 
	* @param mapOfOldRecords 
	**/
	public static void beforeUpdateHelper(
		List<IndividualApplication> recordsList,
		Map<Id, IndividualApplication> mapOfOldRecords
	) {
		updateFieldsBasedOnStatus(recordsList, mapOfOldRecords);
		List<IndividualApplication> ownerUpdateList = new List<IndividualApplication>();
		List<IndividualApplication> priorityApplicationList = new List<IndividualApplication>();
		List<IndividualApplication> iaHavingLicenseTypeList = new List<IndividualApplication>();
		Set<Id> lpnIvCertifiedaccountIdSet = new Set<Id>();
		Map<Id, IndividualApplication> appToUpdateMap = new Map<Id, IndividualApplication>();
		List<IndividualApplication> updateOwnerToSupervisorReviewList = new List<IndividualApplication>();
		for (IndividualApplication newIARecord : recordsList) {
			if (String.isNotBlank(newIARecord.LicenseTypeId)) {
				iaHavingLicenseTypeList.add(newIARecord);
			}
			if (mapOfOldRecords.get(newIARecord.Id).OwnerId != newIARecord.OwnerId) {
				ownerUpdateList.add(newIARecord);
			}
			if (
				(
					newIARecord.Status__c == LPI_LiteralConstant.IA_SUBMITTED_STATUS 
					&& 
					(
						mapOfOldRecords.get(newIARecord.Id).Status__c != newIARecord.Status__c
						|| mapOfOldRecords.get(newIARecord.Id).Disciplinary_Status__c != newIARecord.Disciplinary_Status__c
						|| mapOfOldRecords.get(newIARecord.Id).Payment_Pending__c != newIARecord.Payment_Pending__c
					)
				)
				||
				(
					(LPI_PARTriggerHelper.APPLICABLE_TYPES_SET.contains(newIARecord.ApplicationType) 
					|| newIARecord.Amendment_Type__c == LPI_PARTriggerHelper.UPDATE_LAWFUL_PRESENCE_AMENDMENT)
					&& mapOfOldRecords.get(newIARecord.Id).Is_API_Triggered__c != newIARecord.Is_API_Triggered__c 
					&& newIARecord.Status__c == LPI_LiteralConstant.IA_SUBMITTED_STATUS
				)
				||
				(
					newIARecord.Status__c == LPI_LiteralConstant.IA_PAYMENT_PENDING_STATUS
					&&
					(
						mapOfOldRecords.get(newIARecord.Id).Payment_Pending__c != newIARecord.Payment_Pending__c	
					)
				)
				
			){
				priorityApplicationList.add(newIARecord);
			}
			if(mapOfOldRecords.get(newIARecord.Id).Status != newIARecord.Status 
				&& newIARecord.Status == READY_FOR_ED_APPROVAL_STATUS && OWNER_UPDATE_TO_FOR_SUPERVISOR_REVIEW_SET.contains(newIARecord.License_Type_Name__c))
			{
				updateOwnerToSupervisorReviewList.add(newIARecord);
			}
		}
		if (!priorityApplicationList.isEmpty()) {
			LPI_ApplicationPriority.updatePriorityApplication(priorityApplicationList);
		}
		if (!iaHavingLicenseTypeList.isEmpty()) {
			updatePreRequiredFields(iaHavingLicenseTypeList);
		}
	}

	/**
	* @description This method is used to update field based on status before update.
	* @author MTX Group Product Team | 05-06-2024 
	* @param newList 
	* @param mapOfOldRecords 
	**/
	public static void updateFieldsBasedOnStatus(List<IndividualApplication> newList,Map<Id, IndividualApplication> mapOfOldRecords
	) {
		try {
			Set<String> setStatusToValidate = new Set<String>{
				LPI_LiteralConstant.IA_SUBMITTED_STATUS,
				LPI_LiteralConstant.IA_RESUBMITTED_STATUS
			};
			for (IndividualApplication newIARecord : newList) {
				if (mapOfOldRecords.get(newIARecord.Id).OwnerId != newIARecord.OwnerId 
					&& setStatusToValidate.contains(newIARecord.Status)) {
					if (String.valueOf(newIARecord.OwnerId).subString(0, 3) == '005' &&
						(String.valueOf(mapOfOldRecords.get(newIARecord.Id).OwnerId).subString(0, 3) == '00G' ||
						'Pre-licensure Petition'.equalsIgnoreCase(newIARecord.ApplicationType))) {
						newIARecord.Status__c = LPI_LiteralConstant.IA_IN_PROGRESS_STATUS;
						newIARecord.Status = LPI_LiteralConstant.IA_UNDER_REVIEW_STATUS;
					}
				}else if (mapOfOldRecords.get(newIARecord.Id).Status__c != newIARecord.Status__c 
						&& newIARecord.Status__c.equalsIgnoreCase(LPI_LiteralConstant.IA_IN_PROGRESS_STATUS)) {
					newIARecord.Application_In_Process_Date__c = Date.today();
				}else if(mapOfOldRecords.get(newIARecord.Id).Status != newIARecord.Status
						&& newIARecord.Status.equalsIgnoreCase(LPI_LiteralConstant.IA_APPROVED_STATUS)){
					newIARecord.ApprovedDate = DateTime.parse(System.Now().format());
				}else if(mapOfOldRecords.get(newIARecord.Id).Status != newIARecord.Status
						&& newIARecord.Status.equalsIgnoreCase(LPI_LiteralConstant.IA_REJECTED_STATUS)){
					newIARecord.ApprovedDate = DateTime.parse(System.Now().format());
				}
				else if(
					mapOfOldRecords.get(newIARecord.Id).Status != newIARecord.Status && 
					newIARecord.Status == CANCELED_STATUS){
					newIARecord.Status__c = CLOSED_STATUS;
				}
			}
		} catch (Exception ex) {
			LPI_ExceptionManager.logException(getClassName(), 'updateFieldsBasedOnStatus', ex);
		}
	}

	/**
     * @author                      : MTX Group Product Team
     * @since                       : July 28, 2023
     * @description                 : This method is after Update helper method for CRR Applications
     * @param recordsList           : It contains List of Application records
	 * @param mapOfOldRecords       : It contains old Map of records
     * @return                      : void
     * @last modified by            : Uzma Md
     * @last modified date          :
     * @last modified details       :
     * @story Numbers               : S-51313
     */
	public static void afterUpdateForCRRApplications(
		List<IndividualApplication> recordsList,
		Map<Id, IndividualApplication> mapOfOldRecords
	){
		try{
			Map<Id, Id> parIdWithIaIds = new Map<Id, Id>();
			List<IndividualApplication> submittedRecordList = new List<IndividualApplication>();
			List<IndividualApplication> designatedBrokerIAList = new List<IndividualApplication>();
			List<IndividualApplication> amendmentIAList = new List<IndividualApplication>();
			List<IndividualApplication> superisorConsentIAList = new List<IndividualApplication>();
			List<IndividualApplication> applicationActionList = new List<IndividualApplication>();
			Map<String, String> parIdToStudentIAIdMap = new Map<String, String>();
			List<IndividualApplication> updateCriminalBGCDateList = new List<IndividualApplication>();

			for (IndividualApplication iaRecord : recordsList) {
				if(mapOfOldRecords.get(iaRecord.Id).status != iaRecord.status && 
					iaRecord.status == LPI_LiteralConstant.IA_SUBMITTED_STATUS
				){
					parIdWithIaIds.put(iaRecord.SavedApplicationRefId, iaRecord.Id);
					submittedRecordList.add(iaRecord);
					if(LPI_LiteralConstant.PAR_SOBJECT_TYPE_AMENDMENT.equalsIgnoreCase(iaRecord.ApplicationType) &&
						LPI_LiteralConstant.PAR_AMENDMENT_SUBTYPE_STATUS_CHANGE.equalsIgnoreCase(iaRecord.Amendment_Type__c)
					){
						amendmentIAList.add(iaRecord);
					}
					if(iaRecord.Board_Name__c.equalsIgnoreCase(EMBALMERS_AND_FUNERAL_BOARD_NAME) &&
						(iaRecord.ApplicationType == LPI_LiteralConstant.BLA_NEW_APPLICATIONTYPE ||
						iaRecord.ApplicationType == LPI_LiteralConstant.BLA_AMENDMENT_APPLICATIONTYPE)
					){
						updateCriminalBGCDateList.add(iaRecord);
					}
				}
			}
			if(!parIdWithIaIds.isEmpty()){
				LPI_TriggerServiceUtility.createAuthApplicationPlace(parIdWithIaIds);
				LPI_TriggerServiceUtility.createApplicationContentRecord(parIdWithIaIds);
				LPI_TriggerServiceUtility.createPersonExaminationRecord(parIdWithIaIds);
			}
			afterUpdateHelper(recordsList,mapOfOldRecords);
		}catch(Exception e){
			LPI_ExceptionManager.logException(getClassName(), 'afterUpdateForCRRApplications', e);
		}
		
	}

    /**
    * @description 
    * @author MTX Group Product Team | 05-06-2024 
    * @param recordsList 
    * @param mapOfOldRecords 
    **/
    public static void createBusinessLicenseOnLicesneIssued(
		List<IndividualApplication> recordsList , Map<Id,IndividualApplication> mapOfOldRecords
	) {
		List<IndividualApplication> certificationIAList = new List<IndividualApplication>();
		Set<Id> setPARId = new Set<Id>();
		Set<Id> setRATId = new Set<Id>();
		set<String> setOfAccId = new Set<String>();
		List<IndividualApplication> lstNewApplications = new List<IndividualApplication>();
		List<IndividualApplication> sendNurseExamResultsIAList = new List<IndividualApplication>();
		List<IndividualApplication> examinationStatusUpdatedList = new List<IndividualApplication>();
		Map<Id, Id> iaAccountIdToBlId = new Map<Id, Id>();
		for (IndividualApplication newIARecord : recordsList) {
			if (
				newIARecord.ApplicationType.equalsIgnoreCase(LPI_LiteralConstant.IA_NEW_APPLICATIONTYPE) &&
				newIARecord.AccountId != null &&
				newIARecord.SavedApplicationRefId != null &&
				newIARecord.LicenseTypeId != null
			) {
				lstNewApplications.add(newIARecord);
				setOfAccId.add(newIARecord.AccountId);
				setPARId.add(newIARecord.SavedApplicationRefId);
				setRATId.add(newIARecord.LicenseTypeId);
			
			}
		}
		if (!lstNewApplications.isEmpty()) {
			String fieldsToQuery = 'Id,Name,Open_for_Renewal__c,Renewal_Window_Period_Before_Expiry__c,Expiration_Day__c,'
			+'Expiration_Month__c,Expiration_Cycle__c,Expiration_Period__c,Expiration_Date__c,'
			+'Expiry_Rule_Type__c,ID_Card_Expiration_Period__c,Expiration_Fixed_Cycle_Start_Year__c,'
			+'Expiration_Fixed_Cycle_Difference__c,Renewal_Expiration_Day__c,Renewal_Expiration_Month__c,'
			+'Renewal_Expiration_Cycle__c,Renewal_Expiration_Period__c,Renewal_Expiry_Rule_Type__c,IssuingDepartment.Name,'
			+'Temporary_License_Type__c,Temporary_License_Type__r.Id,Temporary_License_Type__r.Name,'
			+'Temporary_License_Type__r.Open_for_Renewal__c,Temporary_License_Type__r.Renewal_Window_Period_Before_Expiry__c,'
			+'Temporary_License_Type__r.Expiration_Day__c,Temporary_License_Type__r.Expiration_Month__c,'
			+'Temporary_License_Type__r.Expiration_Cycle__c,Temporary_License_Type__r.Expiration_Period__c,'
			+'Temporary_License_Type__r.Expiration_Date__c,Temporary_License_Type__r.Expiry_Rule_Type__c,'
			+'Temporary_License_Type__r.ID_Card_Expiration_Period__c,Temporary_License_Type__r.Expiration_Fixed_Cycle_Start_Year__c,'
			+'Temporary_License_Type__r.Expiration_Fixed_Cycle_Difference__c,Temporary_License_Type__r.Renewal_Expiration_Day__c,'
			+'Temporary_License_Type__r.Renewal_Expiration_Month__c,Temporary_License_Type__r.Renewal_Expiration_Cycle__c,'
			+'Temporary_License_Type__r.Renewal_Expiration_Period__c,Temporary_License_Type__r.Renewal_Expiry_Rule_Type__c, Temporary_License_Type__r.IssuingDepartment.Name';
			String whereClause = 'Id IN '+LPI_ServiceUtility.getStringValuesBySet(setRATId);
			Map<Id, RegulatoryAuthorizationType> mapRATConfigs = new Map<Id, RegulatoryAuthorizationType>(
				LPI_RegulatoryAuthorizationTypeDAO.getRegulatoryAuthorizationTypeByDymanicQuery(
					fieldsToQuery,
					whereClause,
					null,
					null,
					null
				)
			);

			fieldsToQuery =
				'Id,Degree__c,Distinguishing_Characteristics__c,' +
				'Eye_Color__c,Feet__c,' +
				'Graduated_Year__c,Hair_Color__c,Inches__c,Lost__c,Medical_School_Name__c,' +
				'Result__c,' +
				'Last_Bout__c,Preliminary_Application_Reference__c';
			whereClause =
				'Preliminary_Application_Reference__c IN ' + LPI_ServiceUtility.getStringValuesBySet(setPARId);
			Map<Id, Application_Content__c> appContentIdToAppContentMap = new Map<Id, Application_Content__c>(
				LPI_ApplicationContentDAO.getApplicationContentByDymanicQuery(
					fieldsToQuery,
					whereClause,
					null,
					null,
					null
				)
			);
			Map<Id, Application_Content__c> parIdToAppContentMap = new Map<Id, Application_Content__c>();
            for(Id appContentId: appContentIdToAppContentMap.KeySet()){
				parIdToAppContentMap.put(
					appContentIdToAppContentMap.get(appContentId).Preliminary_Application_Reference__c,
					appContentIdToAppContentMap.get(appContentId)
				);
			}

			Map<Id, Account> personAccountData = new Map<Id, Account>(
				LPI_AccountDAO.getAccountByIDs(setOfAccId)
			);

			List<In_App_Checklist_Settings__c> appcheckCustomSettingList;
            In_App_Checklist_Settings__c appcheckCustomSetting;
			String fields = 'Business_License_Counter__c';
			String whereClauseCustomField = 'Business_License_Counter__c != null';
			appcheckCustomSettingList = LPI_CustomMetadataTypeDAO.dynamicGetAppChecklistSettingBusinessLicenseNumber(fields,whereClauseCustomField,'In_App_Checklist_Settings__c');
			if(!appcheckCustomSettingList.isEmpty())
            {
				appcheckCustomSetting = appcheckCustomSettingList[0];
            }
            Integer blNameCounter;
            if(appcheckCustomSetting != null)
            {
                blNameCounter = Integer.valueOf(appcheckCustomSetting.Business_License_Counter__c);
            }
			if (!lstNewApplications.isEmpty()) {
				List<BusinessLicense> lstNewBusinessLicense = new List<BusinessLicense>();
				List<Account> lstNewAccount = new List<Account>();
                Map<String,Id> blNameToIaIdMap = new Map<String,Id>();
				for (IndividualApplication newApprovedIARecord : lstNewApplications) {
					RegulatoryAuthorizationType configRATRecord = mapRATConfigs.get(newApprovedIARecord.LicenseTypeId);
					String contactId = personAccountData.containsKey(newApprovedIARecord.AccountId)
						? personAccountData.get(newApprovedIARecord.AccountId).PersonContactId
						: null;
                    BusinessLicense blToInsert = getMappedBLRecord(
                        newApprovedIARecord,
                        blNameCounter,
                        newApprovedIARecord.Issue_Temp_License__c && newApprovedIARecord.LicensePermitNameId == null && newApprovedIARecord.Temporary_License_Number__c == null && configRATRecord.Temporary_License_Type__c != null
                        ? configRATRecord.Temporary_License_Type__r
                        : configRATRecord,
                        contactId
                    );				
                    blNameToIaIdMap.put(blToInsert.Name,newApprovedIARecord.Id);
					blNameCounter += 1;
					lstNewBusinessLicense.add(blToInsert);
				}
				if (!lstNewBusinessLicense.isEmpty()) {
					List<BusinessLicense> blRecordInsertedList = (List<BusinessLicense>)LPI_DML.doInsert(lstNewBusinessLicense);
					if (!lstNewAccount.isEmpty()){
						LPI_DML.doUpdate(lstNewAccount);
					}
					Map<Id, Id> mapOfIAIdToBLId = new Map<Id, Id>();
					List<IndividualApplication> updateIAList = new List<IndividualApplication>();
					for (BusinessLicense blRecord : blRecordInsertedList) {
						mapOfIAIdToBLId.put(blNameToIaIdMap.get(blRecord.Name), blRecord.Id);
					}
                    for(IndividualApplication objIA : lstNewApplications) {
                        if (mapOfIAIdToBLId.containsKey(objIA.Id)){
							updateIAList.add(
								new IndividualApplication(
									Id = objIA.Id,
									LicensePermitNameId = mapOfIAIdToBLId.get(objIA.Id)
								)
							);
						}
					}
                    if(!updateIAList.isEmpty()){
						LPI_TriggerHandler.bypass('IndividualAppTriggerHandler');
						if (LPI_TriggerHandler.isBypassed('IndividualAppTriggerHandler')) {
							LPI_DML.doUpdate(updateIAList);
						}
						LPI_TriggerHandler.clearBypass('IndividualAppTriggerHandler');
                        List<IndividualApplication> latestIaRecord = LPI_IndividualApplicationDAO.getILAByIAId(mapOfIAIdToBLId.keySet());
						updateBLOnIALicenseIssued(latestIaRecord);
						cloneAppConToLicCon(latestIaRecord);
						updateExpiryDateOnBL(latestIaRecord);
						updateBlOnAuthApplicationPlace(latestIaRecord);
						copyCertificationRecordsToBL(latestIaRecord);
						LPI_TriggerServiceUtility.linkAuditEscrowToBl(latestIaRecord);
						LPI_TriggerServiceUtility.linkInsuranceToBl(latestIaRecord);
						for (IndividualApplication newIARecord : latestIaRecord) {
							iaAccountIdToBlId.put(newIARecord.AccountId, newIARecord.LicensePermitNameId);
						}
						populateBusinessLicenseOnPersonExaminationsOnIALicIssued(latestIaRecord);
						LPI_TriggerServiceUtility.linkNotesFromApplicationToLicense(latestIaRecord);
						updateBusinessLicenseOnEmpHistory(latestIaRecord);
						if (!iaAccountIdToBlId.isEmpty() && !setPARId.isEmpty()) {
							updateIABlIdOnRelationsRelatedToLicNo(setPARId, iaAccountIdToBlId);
						}
					}
				}
				appcheckCustomSetting.Business_License_Counter__c = blNameCounter;
				LPI_WithoutSharingUtility.updateAppChecklistCustomSetting(appcheckCustomSetting);
			}
		}
	}

    /**
    * @description 
    * @author MTX Group Product Team | 05-06-2024 
    * @param objIA 
    * @param counter 
    * @param regAuth 
    * @param contactId 
    * @return BusinessLicense 
    **/

    private static BusinessLicense getMappedBLRecord(
		IndividualApplication objIA,
		Integer counter,
		RegulatoryAuthorizationType regAuth,
		String contactId
	) {
		BusinessLicense blRec = new BusinessLicense();
		blRec.Name = String.valueOf(Date.today().year()) + String.valueOf(counter).leftPad(6, '0');
		blRec.RegulatoryAuthorizationTypeId = regAuth.Id;
		blRec.Status = LPI_LiteralConstant.STATUS_ACTIVE;
		blRec.AccountId = objIA.AccountId;
		blRec.ContactId = contactId;
		blRec.PeriodStart = DateTime.parse(System.Now().format());
		blRec.First_Name__c = objIA.First_Name__c;
		blRec.Last_Name__c = objIA.Last_Name__c;
		blRec.Middle_Name__c = objIA.Middle_Name__c;
		blRec.Maiden_Name__c = objIA.Maiden_Name__c;
		blRec.Hold_Active_License__c = objIA.Hold_Active_License__c;
		blRec.Info_About_Military_Related_Services__c = objIA.Info_About_Military_Related_Services__c;
		blRec.Served_In_US_Armed_Force__c = objIA.Served_In_US_Armed_Force__c;
		blRec.Consent_for_Primary_Contact_Address__c = objIA.Consent_for_Primary_Contact_Address__c;
		//blRec.Currently_Hold_an_Active_License__c = objIA.Currently_Hold_an_Active_License__c;
		blRec.PeriodEnd = LPI_ServiceUtility.getExpirationDate(regAuth);
		blRec.Are_you_Currently_Employeed__c = objIA.Are_you_Currently_Employeed__c;
		blRec.Supervisor_ACR_Id__c = objIA.Supervisor_ACR_Id__c;
		blRec.Disciplinary_Status__c = objIA.Disciplinary_Status__c;
		blRec.Primary_Contact_Address__c = objIA.Primary_Contact_Address__c;
		blRec.License_Address__c = objIA.License_Address__c;
        blRec.Publicly_Displayed_Address__c = objIA.Publicly_Displayed_Address__c;
        blRec.Currently_Holding_Active_License_Number__c = objIA.Currently_Holding_Active_License_Number__c;
		blRec.Employment_Start_Date__c = objIA.Employment_Start_Date__c;
        if(String.isBlank(objIA.LicensePermitNameId)){
            blRec.Pre_Licensure_Number__c = objIA.Pre_Licensure_Number__c;
        }
        blRec.General_Educational_Development_GED__c = objIA.General_Educational_Development_GED__c;
        return blRec;
	}

    /**
    * @description 
    * @author MTX Group Product Team | 05-06-2024 
    * @param recordsList 
    **/

    public static void updateExpiryDateOnBL(List<IndividualApplication> recordsList){
		try{
			LPI_TriggerServiceUtility.updateExpiryDateOnBL(recordsList);
		}catch (Exception ex) {
			LPI_ExceptionManager.logException(getClassName(), 'updateExpiryDateOnBL', ex);
		}
	}

    /**
    * @description 
    * @author MTX Group Product Team | 05-06-2024 
    * @param recordsList 
    **/

    public static void updateBusinessLicenseStatusOnApproval(List<IndividualApplication> recordsList) {
		try {
			LPI_TriggerServiceUtility.updateBusinessLicenseStatusOnApproval(recordsList);
		} catch (Exception ex) {
			LPI_ExceptionManager.logException(getClassName(), 'updateBusinessLicenseStatusOnApproval', ex);
		}
	}

    /**
    * @description 
    * @author MTX Group Product Team | 05-06-2024 
    * @param listOfNewApplication 
    **/
    public static void populateBusinessLicenseOnPersonExaminationsOnIALicIssued(List<IndividualApplication> listOfNewApplication) {
		try {
			Map<Id, Id> iaIdtoBlIdMap = new Map<Id, Id>();
			String fields, whereClause;
			for (IndividualApplication individualApp : listOfNewApplication) {
                if (individualApp.LicensePermitNameId == null) {
                    iaIdtoBlIdMap.put(individualApp.Id, individualApp.Temporary_License_Number__c);
                } else{
                    iaIdtoBlIdMap.put(individualApp.Id, individualApp.LicensePermitNameId);
                }
            }
			
			List<PersonExamination> personExaminationListToBeUpdated = new List<PersonExamination>();
			if (!iaIdtoBlIdMap.isEmpty()) {
				fields = 'Id,Individual_Application__c,Business_License__c ';
				whereClause =
					'Individual_Application__c IN ' +
					LPI_ServiceUtility.getStringValuesBySet(iaIdtoBlIdMap.keySet());
				List<PersonExamination> personExaminationList = LPI_PersonExaminationDAO.getPersonExaminationByDynamicQuery(
					fields,
					whereClause,
					null,
					null,
					null
				);
				if (!personExaminationList.isEmpty()) {
					for (PersonExamination personExamination : personExaminationList) {
						personExamination.Business_License__c = iaIdtoBlIdMap.get(personExamination.Individual_Application__c);
						personExaminationListToBeUpdated.add(personExamination);
					}
					if (!personExaminationListToBeUpdated.isEmpty()) {
						LPI_DML.doUpdate(personExaminationListToBeUpdated);
					}
				}
			}
		} catch (Exception e) {
            LPI_ExceptionManager.logException(getClassName(), 'populateBusinessLicenseOnPersonExaminationsOnIALicIssued', e);
		}
	}

    /**
    * @description 
    * @author MTX Group Product Team | 05-06-2024 
    * @param latestIaRecord 
    **/
    public static void updateBusinessLicenseOnEmpHistory(List<IndividualApplication> latestIaRecord) {
		try {
			List<PersonEmployment> empListToUpdate = new List<PersonEmployment>(); 
			Map<String,String> parIdToBusinessLicenseIdMap = new Map<String,String>();
            for (IndividualApplication newIARecord : latestIaRecord) {
                if(newIARecord.LicensePermitNameId == null){
                    parIdToBusinessLicenseIdMap.put(newIARecord.SavedApplicationRefId, newIARecord.Temporary_License_Number__c);
                } else{
                    parIdToBusinessLicenseIdMap.put(newIARecord.SavedApplicationRefId, newIARecord.LicensePermitNameId);
                }
            }
			String fields = 'Id, Business_License__c, Preliminary_Application_Reference__c';
			String whereClause =
				'Preliminary_Application_Reference__c IN ' +
				LPI_ServiceUtility.getStringValuesByList(new List<String>(parIdToBusinessLicenseIdMap.keyset()));
			List<PersonEmployment> empList = new List<PersonEmployment>();
			empList = LPI_PersonEmploymentDAO.getEmploymentHistoryByDymanicQuery(
				fields,
				whereClause,
				null,
				null,
				null
			);
			if(empList.size() > 0){
				for(PersonEmployment empHis : empList){
					empHis.Business_License__c = parIdToBusinessLicenseIdMap.get(empHis.Preliminary_Application_Reference__c);
					empListToUpdate.add(empHis);
				}
			}
			if (empListToUpdate.size() > 0) {
				LPI_DML.doUpdate(empListToUpdate);
			}
		} catch (Exception e) {
			LPI_ExceptionManager.logException(getClassName(), 'updateBusinessLicenseOnEmpHistory', e);
		}
	}
     /**
     * @author                      : MTX Group Product Team
     * @since                       : July 01, 2024
     * @description                 : This method is before Insert helper method for CRR Applications
     * @param recordsList           : It contains List of Application records
     * @return                      : void
     */

	public static void beforeInsertForCRRApplications(List<IndividualApplication> recordsList){
		try{
			List<IndividualApplication> iaHavingLicenseTypeList = new List<IndividualApplication>();
			for (IndividualApplication newIARecord : recordsList) {
				if (String.isNotBlank(newIARecord.LicenseTypeId)) {
					iaHavingLicenseTypeList.add(newIARecord);
				}
			}

			if (!iaHavingLicenseTypeList.isEmpty()) {
				updatePreRequiredFields(iaHavingLicenseTypeList);
			}
		}catch(Exception e){
			LPI_ExceptionManager.logException(getClassName(), 'beforeInsertForCRRApplications', e);
		}
	}

    /**
    * @description 
    * @author MTX Group Product Team | 05-06-2024 
    * @param parIdSet 
    * @param iaAccountIdToBlId 
    **/

    public static void updateIABlIdOnRelationsRelatedToLicNo(Set<Id> parIdSet, Map<Id, Id> iaAccountIdToBlId) {
		try {
			List<Id> relationsIdList = new List<Id>();
			List<Business_Relationships__c> relationsList = new List<Business_Relationships__c>();
			Map<Id, String> parAccIdToLicNameMap = new Map<Id, String>();
			String fields;
			String whereClause;
			if (!parIdSet.isEmpty()) {
				fields = 'BusinessAccountNameId,Regulatory_Authorization_Type__r.Name,Supervisor_ACR_Id__c,Employee_Information_ACR_Ids__c,Preneed_Relationship_Ids__c';
				whereClause = 'Id IN ' + LPI_ServiceUtility.getStringValuesBySet(parIdSet);
				for (
					PreliminaryApplicationRef par : LPI_PreliminaryApplicationRefDAO.getPreliminaryApplicationRefByDymanicQuery(
						fields,
						whereClause,
						null,
						null,
						null
					)
				) {
					if (!String.isEmpty(par.Employee_Information_ACR_Ids__c)){
						relationsIdList.addAll(par.Employee_Information_ACR_Ids__c.split(','));
					}
					if (!String.isEmpty(par.Supervisor_ACR_Id__c)){
						relationsIdList.addAll(par.Supervisor_ACR_Id__c.split(','));
					}
                    if (!String.isEmpty(par.Preneed_Relationship_Ids__c)){
                        relationsIdList.addAll(par.Preneed_Relationship_Ids__c.split(','));
                    }
					parAccIdToLicNameMap.put(par.BusinessAccountNameId, par.Regulatory_Authorization_Type__r.Name);
				}
			}
			if (!relationsIdList.isEmpty()) {
				fields = 'Related_To__c,Related_To_License_Number__c,Parent_Relationship__c,Parent_Relationship__r.Roles__c';
				whereClause =
					'Id IN ' +
					LPI_ServiceUtility.getStringValuesByList(relationsIdList) +
					' AND Related_To_License_Number__c = NULL';
				for (
					Business_Relationships__c br : LPI_BusinessRelationshipDAO.fetchBusinessRelationshipRecords(
						fields,
						whereClause
					)
				) {
					Business_Relationships__c brUpdate = new Business_Relationships__c(Id = br.Id);
					brUpdate.Related_To_License_Number__c = iaAccountIdToBlId.get(br.Related_To__c);
					relationsList.add(brUpdate);
				}
			}
			if (!relationsList.isEmpty()) {
				LPI_WithoutSharingUtility.updateSObjectRecord(relationsList);
			}
		} catch (Exception e) {
			LPI_ExceptionManager.logException(getClassName(), 'updateIABlIdOnRelationsRelatedToLicNo', e);
		}
	}

    /**
    * @description 
    * @author MTX Group Product Team | 05-06-2024 
    * @param listOfNewApplication 
    **/
    public static void copyCertificationRecordsToBL(List<IndividualApplication> listOfNewApplication) {
		try {
			Map<Id, Id> businessLicenseIAMap = new Map<Id, Id>();
			String fields, whereClause;
			String subType;
            Datetime approvedDate;
            for (IndividualApplication iA : listOfNewApplication) {
                if (iA.SavedApplicationRefId != null){
                    if(iA.LicensePermitNameId == null){
                        businessLicenseIAMap.put(iA.SavedApplicationRefId, iA.Temporary_License_Number__c);
                    } else{
                        businessLicenseIAMap.put(iA.SavedApplicationRefId, iA.LicensePermitNameId);
                    }
                }
                subType = iA.Amendment_Type__c;
                approvedDate = iA.ApprovedDate;
            }

			List<BoardCertification> updateCertList = new List<BoardCertification>();
			if (!businessLicenseIAMap.isEmpty()) {
				fields = 'Id,Business_License__c,Effective_Date__c,Title__c,Preliminary_Application_Reference__c';
				whereClause =
					'( Preliminary_Application_Reference__c IN ' +
					LPI_ServiceUtility.getStringValuesBySet(businessLicenseIAMap.keySet()) +
                    ' OR Business_License__c IN ' + 
                    LPI_ServiceUtility.getStringValuesByList(businessLicenseIAMap.values()) + 
					') ';
				List<BoardCertification> certList = LPI_CertificationDAO.getCertificationByDymanicQuery(
					fields,
					whereClause,
					null,
					null,
					null
				);
				if (!certList.isEmpty()) {
					for (BoardCertification certRec : certList) {
						BoardCertification cert = new BoardCertification();
						cert.Id = certRec.Id;
						if(String.isBlank(certRec.Business_License__c)){
							cert.Business_License__c = businessLicenseIAMap.get(
								certRec.Preliminary_Application_Reference__c
							);
						}
						updateCertList.add(cert);
					}
					if (!updateCertList.isEmpty()) {
						LPI_DML.doUpdate(updateCertList);
					}
				}
			}
		} catch (Exception e) {
			LPI_ExceptionManager.logException(getClassName(), 'copyCertificationRecordsToBL', e);
		}
	}

    /**
    * @description 
    * @author MTX Group Product Team | 05-06-2024 
    * @param recordsList 
    **/
    public static void cloneAppConToLicCon(List<IndividualApplication> recordsList){
		Map<Id,Id> mapOfPARIdAndLicenseId= new Map<Id,Id>();
		for (IndividualApplication objIA : recordsList) {
            if(LPI_LiteralConstant.APPLICATION_FOR_PERMIT.equalsIgnoreCase(objIA.ApplicationType)) {
                continue;
            }
            mapOfPARIdAndLicenseId.put(objIA.SavedApplicationRefId, objIA.LicensePermitNameId);
		}
		if(!mapOfPARIdAndLicenseId.isEmpty()) {
			LPI_TriggerServiceUtility.cloneAppConToLicCon(mapOfPARIdAndLicenseId, true);
		}
	}

    /**
    * @description 
    * @author MTX Group Product Team | 05-06-2024 
    * @param listOfNewApplication 
    **/
    public static void updateBLOnIALicenseIssued(List<IndividualApplication> listOfNewApplication) {
        try{
			Map<Id, IndividualApplication> blIdToIAMap = new Map<Id, IndividualApplication>();
			Set<Id> setRATId = new Set<Id>(); 
			Set<Id> setPARId = new Set<Id>(); 
            Map<Id, Id> iaAccountIdToBlId = new Map<Id, Id>();
			Map<Id, RegulatoryAuthorizationType> mapRATConfigs = new Map<Id, RegulatoryAuthorizationType>();
			List<RegulatoryAuthorizationType> ratList = new List<RegulatoryAuthorizationType>();
			Map<String, RegulatoryAuthorizationType> ratNameToRatMap = new Map<String, RegulatoryAuthorizationType>();
			for (IndividualApplication objIA : listOfNewApplication) {
				blIdToIAMap.put(objIA.LicensePermitNameId, objIA);
				iaAccountIdToBlId.put(objIA.AccountId, objIA.LicensePermitNameId);
				setRATId.add(objIA.LicenseTypeId);
                setPARId.add(objIA.SavedApplicationRefId);
			}
			List<IndividualApplication> convertTempToBusinessLicenseList = new List<IndividualApplication>();
			if (!setRATId.isEmpty()) {
				String fieldsToQuery =
					'Id,Name,Open_for_Renewal__c,Renewal_Window_Period_Before_Expiry__c,Expiration_Day__c,' +
					'Expiration_Month__c,Expiration_Cycle__c,Expiration_Period__c,Expiration_Date__c,' +
					'Expiry_Rule_Type__c,ID_Card_Expiration_Period__c,Expiration_Fixed_Cycle_Start_Year__c,' +
					'Expiration_Fixed_Cycle_Difference__c,Renewal_Expiration_Day__c,Renewal_Expiration_Month__c,' +
					'Renewal_Expiration_Cycle__c,Renewal_Expiration_Period__c,Renewal_Expiry_Rule_Type__c,IssuingDepartment.Name';
				String whereClause = 'Id IN ' + LPI_ServiceUtility.getStringValuesBySet(setRATId) ;
				ratList = LPI_RegulatoryAuthorizationTypeDAO.getRegulatoryAuthorizationTypeByDymanicQuery(
					fieldsToQuery,
					whereClause,
					null,
					null,
					null
				);
				for(RegulatoryAuthorizationType rat : ratList){
					mapRATConfigs.put(rat.Id, rat);
					ratNameToRatMap.put(rat.Name, rat);
				}
			}
            if(!blIdToIAMap.isEmpty()){
				List<BusinessLicense> updateBlList = new List<BusinessLicense>();
				for (
					BusinessLicense bl : LPI_BusinessLicenseDAO.fetchBusinessLicenseRecords(
						'Id, Currently_Hold_an_Active_License__c,'+
						'Are_you_Currently_Employeed__c,'+
						'PeriodEnd, Certificate_of_Identification_Issued__c, RegulatoryAuthorizationType.IssuingDepartment.Name, ' + 
						'Date_of_Business_Ceased_Activity__c',
						'Id IN ' + LPI_ServiceUtility.getStringValuesBySet(blIdToIAMap.keySet())
					)
				) {
					BusinessLicense blRec = new BusinessLicense();
					
					if (
						blIdToIAMap.get(bl.Id).Issue_Temp_License__c &&
						blIdToIAMap.get(bl.Id).Status == LPI_LiteralConstant.IA_LICENSEISSUED_STATUS
					) {
						convertTempToBusinessLicenseList.add(blIdToIAMap.get(bl.Id));
					}
					if( mapRATConfigs.get( blIdToIAMap.get(bl.Id).LicenseTypeId ).IssuingDepartment.Name == LPI_LiteralConstant.Healing_Arts_RecordType){
						String recordTypeName = Schema.getGlobalDescribe().get(LPI_LiteralConstant.IA_SOBJECT_API).getDescribe().getRecordTypeInfosById().get(  blIdToIAMap.get(bl.Id).RecordTypeId).getDeveloperName();
						blRec.Profession__c = recordTypeName;
					}

					if (
						blIdToIAMap.get(bl.Id).ApplicationType == LPI_LiteralConstant.IA_AMENDMENT_APPLICATIONTYPE &&
						blIdToIAMap.get(bl.Id).Amendment_Type__c == TYPE_APPLY_FOR_PROFESSIONAL_CORPORATION
					){
						if(
							PROF_CORP_CONVERT_LICENSE_TYPES_MAP.containsKey(blIdToIAMap.get(bl.Id).License_Type_Name__c) &&
							ratNameToRatMap.containsKey(PROF_CORP_CONVERT_LICENSE_TYPES_MAP.get(blIdToIAMap.get(bl.Id).License_Type_Name__c))
						){
							blRec.RegulatoryAuthorizationTypeId = ratNameToRatMap.get(PROF_CORP_CONVERT_LICENSE_TYPES_MAP.get(blIdToIAMap.get(bl.Id).License_Type_Name__c)).Id;
						}
						
						if(blIdToIAMap.get(bl.Id).Board_Name__c == HEALING_ARTS_BOARD){
							blRec.Name_of_the_Professional_Corporation__c = blIdToIAMap.get(bl.Id).Name_of_the_Professional_Corporation__c;
						}
						
					}
					blRec.Info_About_Military_Related_Services__c = blIdToIAMap.get(bl.Id).Info_About_Military_Related_Services__c; 
					blRec.Served_In_US_Armed_Force__c = blIdToIAMap.get(bl.Id).Served_In_US_Armed_Force__c; 
					blRec.Id = bl.Id;
					updateBlList.add(blRec);
				}
				if (updateBlList.size() > 0) {
					LPI_WithoutSharingUtility.updateSObjectList(updateBlList);
				}
			}
			updateBusinessLicenseOnEmpHistory(listOfNewApplication);
            if (!iaAccountIdToBlId.isEmpty() && !setPARId.isEmpty()) {
                updateIABlIdOnRelationsRelatedToLicNo(setPARId, iaAccountIdToBlId);
            }
		} catch (Exception ex) {
			LPI_ExceptionManager.logException(getClassName(), 'updateBLOnIALicenseIssued', ex);
		}
	}

	/**
	* @description 
	* @author MTX Group Product Team | 05-06-2024 
	* @param recordList 
	**/

	public static void updateBlOnAuthApplicationPlace(List<IndividualApplication> recordList){
        try{
      		LPI_TriggerServiceUtility.updateAuthApplicationPlace(recordList);
        }
        catch (Exception ex) {
      		LPI_ExceptionManager.logException(getClassName(), 'updateBlOnAuthApplicationPlace', ex);
    	}
    }

	/**
	* @description 
	* @author MTX Group Product Team | 05-06-2024 
	* @param recordsList 
	**/

	public static void sendNotificationToApprentice(List<IndividualApplication> recordsList){
		try{
			LPI_TriggerServiceUtility.sendEmailNotificationToApprentice(recordsList);
		} catch(Exception e){
			LPI_ExceptionManager.logException(getClassName(), 'sendNotificationToApprentice', e);
		}
	}

	public static void createBoutAgreementOnApproval(List<IndividualApplication> recordsList) {
		List<License_Content__c> licenseContentsToInsert = new List<License_Content__c>();
		for (IndividualApplication newIARecord : recordsList) {
			if (newIARecord.ApplicationType.equalsIgnoreCase(LPI_LiteralConstant.IA_BOUT_AGREEMENT_APPLICATIONTYPE)) {
				Map<String, Object> deserializedLicenseQuestions = (Map<String, Object>) JSON.deserializeUntyped(
					String.valueOf(newIARecord.License_Questions__c)
				);
				License_Content__c lc = new License_Content__c();
				lc.Expiration_Date__c = date.valueOf(
					String.valueOf(deserializedLicenseQuestions.get('BoutDateOfBout'))
				);
				lc.Business_License__c = newIARecord.LicensePermitNameId;
				lc.Section_Header__c = LPI_LiteralConstant.IA_BOUT_AGREEMENT_APPLICATIONTYPE;
				licenseContentsToInsert.add(lc);
			}
		}
		if (!licenseContentsToInsert.isEmpty()) {
			LPI_DML.doInsert(licenseContentsToInsert);
		}
	}

	public static void assignIDCardToLicenseeOnApproval(List<IndividualApplication> recordsList) {
		Set<Id> setRATId = new Set<Id>();
		Set<Id> setPARId = new Set<Id>();
		Set<Id> setParRecordsId = new Set<Id>();
		Set<String> setApplicationTypeToValidate = new Set<String>{
			LPI_LiteralConstant.BOXERS_FEDERAL_ID_CARD,
			LPI_LiteralConstant.MMA_NATIONAL_ID_CARD
		};
		List<IndividualApplication> lstNewApplications = new List<IndividualApplication>();
		for (IndividualApplication newIARecord : recordsList) {
			if (setApplicationTypeToValidate.contains(newIARecord.ApplicationType) 
			    || (newIARecord.ApplicationType == LPI_LiteralConstant.IA_NEW_APPLICATIONTYPE && 
				(setApplicationTypeToValidate.contains(newIARecord.Amendment_Type__c)))) {
				setRATId.add(newIARecord.LicenseTypeId);
				setPARId.add(newIARecord.SavedApplicationRefId);
				lstNewApplications.add(newIARecord);
			}
		}

		if (!setRATId.isEmpty()) {
			String fieldsToQuery =
				'Id,Name,Open_for_Renewal__c,Renewal_Window_Period_Before_Expiry__c,Expiration_Day__c,' +
				'Expiration_Month__c,Expiration_Cycle__c,Expiration_Period__c,Expiration_Date__c,' +
				'Expiry_Rule_Type__c,ID_Card_Expiration_Period__c,Expiration_Fixed_Cycle_Start_Year__c,' +
				'Expiration_Fixed_Cycle_Difference__c,Renewal_Expiration_Day__c,Renewal_Expiration_Month__c,' +
				'Renewal_Expiration_Cycle__c,Renewal_Expiration_Period__c,Renewal_Expiry_Rule_Type__c,IssuingDepartment.Name';
			String whereClause = 'Id IN ' + LPI_ServiceUtility.getStringValuesBySet(setRATId);
			Map<Id, RegulatoryAuthorizationType> mapRATConfigs = new Map<Id, RegulatoryAuthorizationType>(
				LPI_RegulatoryAuthorizationTypeDAO.getRegulatoryAuthorizationTypeByDymanicQuery(
					fieldsToQuery,
					whereClause,
					null,
					null,
					null
				)
			);
			
			fieldsToQuery = 'Id, Contact__c,BusinessAccountNameId';
			whereClause = 'Id IN ' + LPI_ServiceUtility.getStringValuesBySet(setPARId);
			Map<Id, PreliminaryApplicationRef> mapPAR = new Map<Id, PreliminaryApplicationRef>(
				LPI_PreliminaryApplicationRefDAO.getPreliminaryApplicationRefByDymanicQuery(
					fieldsToQuery,
					whereClause,
					null,
					null,
					null
				)
			);
			List<Identification_Card__c> idCardToInsert = new List<Identification_Card__c>();
			for (IndividualApplication newApprovedIARecord : lstNewApplications) {
				Identification_Card__c idCard = new Identification_Card__c();
				idCard.Contestant_Name__c = mapPAR.get(newApprovedIARecord.SavedApplicationRefId).BusinessAccountNameId;
				idCard.Expiry_Date__c = Date.today()
					.addMonths(
						Integer.valueOf(
							mapRATConfigs.get(newApprovedIARecord.LicenseTypeId).ID_Card_Expiration_Period__c
						)
					);
				idCard.ID_Type__c = newApprovedIARecord.Amendment_Type__c == LPI_LiteralConstant.BOXERS_FEDERAL_ID_CARD
					? LPI_LiteralConstant.BOXING_ID_TYPE
					: LPI_LiteralConstant.MMA_ID_TYPE;
				idCardToInsert.add(idCard);
			}
			if (!idCardToInsert.isEmpty()) {
				LPI_DML.doInsert(idCardToInsert);
			}
		}
		for(IndividualApplication record: recordsList){
			setParRecordsId.add(record.SavedApplicationRefId);
		}

		if (!setParRecordsId.isEmpty()) {
			String fieldsToQuery =
				'Id,Degree__c,Distinguishing_Characteristics__c,' +
				'Eye_Color__c,Feet__c,' +
				'Graduated_Year__c,Hair_Color__c,Inches__c,Medical_School_Name__c,' +
				'Result__c,' +
				'Last_Bout__c,Preliminary_Application_Reference__c, Section_Header__c';
			String whereClause =
				'Preliminary_Application_Reference__c IN ' +
				LPI_ServiceUtility.getStringValuesBySet(setParRecordsId) +
				' AND Section_Header__c  = \'' +
				String.escapeSingleQuotes(PERSON_ADDITIONAL_INFO) +
				'\'';
			Map<Id, Application_Content__c> appContentIdToAppContentMap = new Map<Id, Application_Content__c>(
				LPI_ApplicationContentDAO.getApplicationContentByDymanicQuery(
					fieldsToQuery,
					whereClause,
					null,
					null,
					null
				)
			);
			Map<Id, Application_Content__c> parIdToAppContentMap = new Map<Id, Application_Content__c>();
			for (Id appContentId : appContentIdToAppContentMap.KeySet()) {
				parIdToAppContentMap.put(
					appContentIdToAppContentMap.get(appContentId).Preliminary_Application_Reference__c,
					appContentIdToAppContentMap.get(appContentId)
				);
			}
			List<Account> accListToUpdate = new List<Account>();
			for (IndividualApplication record : recordsList) {
				if (parIdToAppContentMap.get(record.SavedApplicationRefId) != null) {
					Account accToUpsert = new Account(Id = record.AccountId);
					prePopulateApplicationContentFieldsonBL(
						parIdToAppContentMap.get(record.SavedApplicationRefId),
						null,
						accToUpsert
					);
					accListToUpdate.add(accToUpsert);
				}
			}
			if (!accListToUpdate.isEmpty()) {
				LPI_WithoutSharingUtility.updateSObjectList(accListToUpdate);
			}
		}
	}

	public static void changeVerificationStatusForEmploymentHistory(
        List<IndividualApplication> recordsList
    ) {
        Set<String> parIdSet = new Set<String>();
        for (IndividualApplication ia : recordsList) {
            parIdSet.add(ia.SavedApplicationRefId);
        }
        if (parIdSet.size() > 0) {
            String fields = 'Id, Status__c';
            String whereClause =
                'Preliminary_Application_Reference__c IN ' +
                LPI_ServiceUtility.getStringValuesByList(
                    new List<String>(parIdSet)
                );
            List<PersonEmployment> empList = new List<PersonEmployment>();
            empList = LPI_PersonEmploymentDAO.getEmploymentHistoryByDymanicQuery(
                fields,
                whereClause,
                null,
                null,
                null
            );
            if (empList.size() > 0) {
                List<PersonEmployment> updateEmpList = new List<PersonEmployment>();
                for (PersonEmployment emp : empList) {
                    PersonEmployment updateEmp = new PersonEmployment();
                    updateEmp.Id = emp.Id;
                    updateEmp.EmploymentStatus = VERIFIED;
                    updateEmpList.add(updateEmp);
                }
                LPI_DML.doUpdate(updateEmpList);
            }
        }
    }

	public static void changeVerificationStatusForEducationHistory(List<IndividualApplication> recordsList) {
		Set<String> parIdSet = new Set<String>();
		Set<String> contactIdSet = new Set<String>();
		Set<Id> amtrParIdSet = new Set<Id>();
		for (IndividualApplication ia : recordsList) {
			if(MONTHLY_QUATERLY_REPRT_SUB_TYPE_SET.contains(ia.Amendment_Type__c)) {
				amtrParIdSet.add(ia.SavedApplicationRefId);
			}else {
				parIdSet.add(ia.SavedApplicationRefId);
			}
		}
		List<PersonEducation> personEduList = new List<PersonEducation>();

		if(!amtrParIdSet.isEmpty()) {
			String personEduQueryFields = 'Id, Education_Status__c, Not_Education_History_Record__c, Education_Type__c';
			String personEduWhereClause =
					'Preliminary_Application_Reference__c IN ' +
					LPI_ServiceUtility.getStringValuesBySet(amtrParIdSet) +
					' AND ' +
					'Education_Status__c  != \'' +
					VERIFIED +
					'\'' +
					' AND ' +
					'Education_Type__c = \'' +
					COSMETOLOGY_BARBER_EDUCATION +
					'\'';
				for (
						PersonEducation personEdu : LPI_PersonEducationDAO.getPersonEducationByDymanicQuery(
							personEduQueryFields,
							personEduWhereClause,
							null,
							null,
							null
						)
					) {
						personEdu.Education_Status__c = VERIFIED;
						personEduList.add(personEdu);
					}
					
		}
		else if (!parIdSet.isEmpty()) {
			String parQueryFields = 'Id, Contact__c';
			String parWhereClause = 'Id IN ' + LPI_ServiceUtility.getStringValuesByList(new List<String>(parIdSet)) + 
									' AND Contact__c != NULL ';
			for (
				PreliminaryApplicationRef par : LPI_PreliminaryApplicationRefDAO.getPreliminaryApplicationRefByDymanicQuery(
					parQueryFields,
					parWhereClause,
					null,
					null,
					null
				)
			) {
				contactIdSet.add(par.Contact__c);
			}
			if (!contactIdSet.isEmpty()) {
				String personEduQueryFields = 'Id, Education_Status__c, Not_Education_History_Record__c, Education_Type__c';
				String personEduWhereClause = 'ContactId IN ' +
					                            LPI_ServiceUtility.getStringValuesByList(new List<String>(contactIdSet)) +
                                                ' AND ' + 'Preliminary_Application_Reference__c IN ' + 
					                            LPI_ServiceUtility.getStringValuesByList(new List<String>(parIdSet)) +
					                            ' AND ' + 'Education_Status__c  != \'' + VERIFIED + '\'' + 
                                                ' AND ' + 'Not_Education_History_Record__c = false' + 
                                                ' AND ' + 'Education_Type__c = \'' + HIGHER_EDUCATION_TYPE + '\'';
												
				for (PersonEducation personEdu : LPI_PersonEducationDAO.getPersonEducationByDymanicQuery(personEduQueryFields, 
                                                                                    personEduWhereClause, null, null, null)) {
					personEdu.Education_Status__c = VERIFIED;
					personEduList.add(personEdu);
				}
			
			}
		}
		if (!personEduList.isEmpty()) {
			LPI_DML.doUpdate(personEduList);
		}
	}

	public static void updateRequiredPermitsOnBL(List<IndividualApplication> recordsList){
		Set<Id> blIdSet = new Set<Id>();
		List<IndividualApplication> applicationUpdatePermits = new List<IndividualApplication>();
		for(IndividualApplication newIARecord : recordsList){
			if(newIARecord.ApplicationType == LPI_LiteralConstant.FEE_TYPE_DENTAL_HYGIENIST_PERMIT &&
				newIARecord.Amendment_Type__c == LPI_LiteralConstant.FEE_TYPE_DENTAL_HYGIENIST_PERMIT){
				blIdSet.add(newIARecord.LicensePermitNameId);
				applicationUpdatePermits.add(newIARecord);
			}
		}

		if(!applicationUpdatePermits.isEmpty()){
			List<BusinessLicense> blListToUpdate = new List<BusinessLicense>();
			String fieldsToQuery = 'Id, Status, Reinstatement_Count__c, Required_Permits__c';
			String whereClause = 'Id IN '+LPI_ServiceUtility.getStringValuesBySet(blIdSet);
			Map<Id,BusinessLicense> BusinessLicenseMap = new Map<Id,BusinessLicense>(
				LPI_BusinessLicenseDAO.fetchBusinessLicenseRecords(
					fieldsToQuery,
					whereClause
				)
			);
			if(!blListToUpdate.isEmpty()){
				LPI_DML.doUpdate(blListToUpdate);
			}
		}
	}

	public static void performAmendmentOnBusinessLicense(List<IndividualApplication> recordsList, Map<Id, BusinessLicense> mapOfBLWithId) {
		try {
			List<BusinessLicense> lstBLToUpsert = new List<BusinessLicense>();
			List<IndividualApplication> additionalLicenseReqApps = new List<IndividualApplication>();
			List<IndividualApplication> addressChangeApps = new List<IndividualApplication>();
			Set<Id> statusChangeIAIdSet = new Set<Id>();
			Map<Id,IndividualApplication> accountIdToIaMap = new Map<Id,IndividualApplication> ();
			for (IndividualApplication updatedIA : recordsList) {
				BusinessLicense blToUpsert;
				Account accToUpdate;
				if (
					LPI_LiteralConstant.PAR_AMENDMENT_SUBTYPE_LICENSE_TRANSFER.equalsIgnoreCase(updatedIA.Amendment_Type__c)
				) {
					blToUpsert = handleAmendmentLicenseTransfer(updatedIA);
				}
				else if (
					AMENDMENT_SUBTYPE_CHANGE_OF_NAME.equalsIgnoreCase(updatedIA.Amendment_Type__c) 
				) {
                    blToUpsert = updateNameOnBusinessLicense(updatedIA); 
				} else if (
					LPI_LiteralConstant.CHANGE_OF_INDIVIDUAL_BUSINESS_ADDRESS.equalsIgnoreCase(updatedIA.Amendment_Type__c)
				) {
					blToUpsert = new BusinessLicense(Id = updatedIA.LicensePermitNameId);
					//blToUpsert.Effective_Date__c = updatedIA.Effective_Date__c;
					addressChangeApps.add(updatedIA);
				} else if (
					LPI_LiteralConstant.PAR_AMENDMENT_SUBTYPE_NAME_OR_ADDRESS_CHANGE.equalsIgnoreCase(
						updatedIA.Amendment_Type__c
					) ||
					(mapOfBLWithId.containsKey(updatedIA.LicensePermitNameId) &&
					mapOfBLWithId.get(updatedIA.LicensePermitNameId).Is_Migrated_Data__c)
				) {
					blToUpsert = updateNameOnBusinessLicense(updatedIA);
					addressChangeApps.add(updatedIA);
				} 
				else if (LPI_LiteralConstant.PAR_AMENDMENT_SUBTYPE_OBTAIN_ADD_LICENSE.equalsIgnoreCase(updatedIA.Amendment_Type__c)) {
					additionalLicenseReqApps.add(updatedIA);
				} 
				else if (
					LPI_LiteralConstant.PAR_AMENDMENT_SUBTYPE_STATUS_CHANGE.equalsIgnoreCase(updatedIA.Amendment_Type__c)
				) {
					statusChangeIAIdSet.add(updatedIA.Id);
				} else if (
					AMENDMENT_SUBTYPE_SET.contains(updatedIA.Amendment_Type__c)

				) {
					addressChangeApps.add(updatedIA);
				}
				if (blToUpsert != null) {
					lstBLToUpsert.add(blToUpsert);
                }
            }
			if (!addressChangeApps.isEmpty()) {
				handleNameAndAddressForAmendments(addressChangeApps);
			}
			if(!additionalLicenseReqApps.isEmpty()){
				String fields = 'Business_License_Counter__c';
                String whereClause = 'Business_License_Counter__c != null';
                In_App_Checklist_Settings__c appcheckCustomSetting = LPI_CustomMetadataTypeDAO.dynamicGetAppChecklistSettingBusinessLicenseNumber(fields,whereClause,'In_App_Checklist_Settings__c')[0];
				Integer blNameCounter = Integer.valueOf(appcheckCustomSetting.Business_License_Counter__c);
				handleAmendmentObtainAdditionalLicense(additionalLicenseReqApps,blNameCounter);
			}
			if(!statusChangeIAIdSet.isEmpty()){
				updateLicenseTypeOnBusinessLicenses(statusChangeIAIdSet);
			}
			if (!lstBLToUpsert.isEmpty()) {
				LPI_WithoutSharingUtility.updateSObjectList(lstBLToUpsert);
            }
        } catch (Exception ex) {
			LPI_ExceptionManager.logException(getClassName(), 'performAmendmentOnBusinessLicense', ex);
		}
	}

	public static void updatelocationStatusOnBLWhenIsMigratedDataTrue(List<IndividualApplication> newList,Map<Id, IndividualApplication> mapOfOldRecords) {
		try {
			Set<Id> blId = new Set<Id>();
			Set<Id> iaIds = new Set<Id>();
			Set<Id> blLocIds = new Set<Id>();
			Set<Id> iaIdSet = new Set<Id>();
			Set<Id> ialocIds = new Set<Id>();
			List<Schema.location> updateLocList = new List<Schema.location>();
			for(IndividualApplication ia : newList)
			{
                if(( mapOfOldRecords != null && mapOfOldRecords.get(ia.Id).status != ia.status && ia.status == LPI_LiteralConstant.IA_LICENSEISSUED_STATUS) || 
				  (mapOfOldRecords == null && ia.status == LPI_LiteralConstant.IA_SUBMITTED_STATUS && ia.Is_Auto_Approval_Allowed__c == true) )
				{
                    iaIds.add(ia.Id);
                } 
			}
            if(!iaIds.isEmpty()){
                for(IndividualApplication ia : LPI_IndividualApplicationDAO.getIndividualApplicationByDymanicQuery('Id,LicensePermitNameId,Status,SavedApplicationRef.Is_Migrated_Data__c,Amendment_Type__c','Id IN '+LPI_ServiceUtility.getStringValuesBySet(iaIds),null,null,null)){
                    if((!ALL_ADDRESS_AMENDMENT_TYPE_SET.contains(ia.Amendment_Type__c)) && 
                    ia.LicensePermitNameId != null && 
                        ia.SavedApplicationRef.Is_Migrated_Data__c == true 
                    )
                    {
                        blId.add(ia.LicensePermitNameId);
                        iaIdSet.add(ia.Id);
                    }
                }
                if(!iaIdSet.isEmpty() && !blId.isEmpty())
                {
                for(AuthApplicationPlace aap : LPI_AuthApplicationPlaceDAO.getAuthApplicationPlaceByRgltyAuthApplicationIds(iaIdSet))
                {
                    ialocIds.add(aap.placeId);
                }
                for(AuthApplicationPlace aap : LPI_AuthApplicationPlaceDAO.getAuthApplicationPlaceByAuthorizationIds(blId))
                {
                    blLocIds.add(aap.placeId);
                }

                for(Id locId : blLocIds)
                {
                    if(!ialocIds.contains(locId)){
                        Schema.location updateLoc = new Schema.location(Id = locId);
                            updateLoc.status__c = CLOSED;
                        updateLoc.CloseDate = System.today();
                        updateLocList.add(updateLoc);
                    }	
                }
                if(!updateLocList.isEmpty())
                {
                    LPI_WithoutSharingUtility.updateSObjectList(updateLocList);
                    }
                }
            }
		} catch (DmlException e) {
			LPI_ExceptionManager.logException(getClassName(), 'updatelocationStatusOnBLWhenIsMigratedDataTrue', e);
		}
	}

	public static void updateMailingAddressTOBL(Set<Id> blIdSet, String locationType) {		
		Set<Id> locationIdSet = new Set<Id>();
		Map<Id,Id> mapOfAccountAndLocation = new Map<Id,Id>();	
		Map<Id, AuthApplicationPlace> mapOfAuthPlaceWithId = new Map<Id, AuthApplicationPlace>();
		Map<Id,Id> mapOfAuthPlaceWithLocationId = new Map<Id,Id>();
		Set<Id> setOfMaillingLocation = new Set<Id>();
		List<String> associateLocationQueryList = new List<String> {'Id','ParentRecordId','LocationId','Location.LocationType','Location.Status__c'};			
		try {
			String fields;
			String whereClause;
			if(!blIdSet.isEmpty())
			{
				fields = 'id,PlaceId,RgltyAuthApplicationId,AuthorizationId';
				whereClause = 'AuthorizationId IN ';
				LPI_AuthApplicationPlaceDAO.LPI_AuthApplicationPlaceWithoutSharingDAO aapObj = new LPI_AuthApplicationPlaceDAO.LPI_AuthApplicationPlaceWithoutSharingDAO();
				for (
					AuthApplicationPlace aap : aapObj.getAuthApplicationPlaceByDymanicQuery(
						fields,
						whereClause + LPI_ServiceUtility.getStringValuesBySet(blIdSet),
						null,
						null,
						null
					)
				){
					locationIdSet.add(aap.PlaceId);
				}
			}
			if(!locationIdSet.isEmpty()){
				for(AssociatedLocation ascLocation : LPI_AssociatedLocationDAO.getAssociatedLocationListByDynamicQuery(
					associateLocationQueryList, 
					' LocationId IN ' + LPI_ServiceUtility.getStringValuesBySet(locationIdSet) +
					' AND Location.LocationType = \'' + locationType + '\''+  ' AND Location.Status__c = \'' +
					LOCATION_STATUS_OPEN +
					'\'',
					null,null,null))
				{
					mapOfAccountAndLocation.put(ascLocation.ParentRecordId, ascLocation.LocationId);
				}
			} 
			if(!mapOfAccountAndLocation.isEmpty())
			{
				fields = 'id,PlaceId,RgltyAuthApplicationId,AuthorizationId, Authorization.AccountId,Authorization.Status';
				whereClause = ' Authorization.AccountId IN '+ LPI_ServiceUtility.getStringValuesBySet(mapOfAccountAndLocation.keySet()) +
								' AND Authorization.RegulatoryAuthorizationType.IssuingDepartment.Name = \'' +
								COSMETOLOGY_AND_BARBER_BOARD + '\'' + ' AND Authorization.Status != \'' +
								CLOSED + '\'' ;
				LPI_AuthApplicationPlaceDAO.LPI_AuthApplicationPlaceWithoutSharingDAO aapObj1 = new LPI_AuthApplicationPlaceDAO.LPI_AuthApplicationPlaceWithoutSharingDAO();
				for (AuthApplicationPlace aap : aapObj1.getAuthApplicationPlaceByDymanicQuery(
					fields,
					whereClause,
					null,
					null,
					null
				)){
					mapOfAuthPlaceWithLocationId.put(aap.Id, aap.PlaceId);
					mapOfAuthPlaceWithId.put(aap.Id, aap);
				}
			}
			Set<Id> updateSobjectSet = new Set<Id>();
			List<AuthApplicationPlace> listOfAutAppPlaceToBeUpdate = new List<AuthApplicationPlace>();
			List<Schema.location> listOfLocationToBeUpdate = new List<Schema.location>();
			if (!mapOfAuthPlaceWithLocationId.isEmpty()) 
			{
				for(AssociatedLocation ascLocation : LPI_AssociatedLocationDAO.getAssociatedLocationListByDynamicQuery(
					associateLocationQueryList, 
					' LocationId IN ' + LPI_ServiceUtility.getStringValuesByList(mapOfAuthPlaceWithLocationId.Values()) +
					' AND Location.LocationType = \'' +  locationType + '\''+  ' AND Location.Status__c = \'' +
					LOCATION_STATUS_OPEN +
					'\''
					,null,null,null))
					{
							setOfMaillingLocation.add(ascLocation.LocationId);
					}
				
				Id locationId;
				for(Id authAppPlaceId : mapOfAuthPlaceWithLocationId.keySet() ) {
					if(setOfMaillingLocation.contains(mapOfAuthPlaceWithLocationId.get(authAppPlaceId)) && mapOfAuthPlaceWithId.containsKey(authAppPlaceId)) {
						locationId = mapOfAccountAndLocation.get(mapOfAuthPlaceWithId.get(authAppPlaceId).Authorization.AccountId);
						if(locationId != mapOfAuthPlaceWithLocationId.get(authAppPlaceId) ) {
							
							if(!updateSobjectSet.contains(mapOfAuthPlaceWithLocationId.get(authAppPlaceId))) {
								updateSobjectSet.add(mapOfAuthPlaceWithLocationId.get(authAppPlaceId));
								listOfLocationToBeUpdate.add(
								    new Schema.location(Id = mapOfAuthPlaceWithLocationId.get(authAppPlaceId), Status__c =LOCATION_STATUS_CLOSED)
								);
							}
							if(!updateSobjectSet.contains(authAppPlaceId)) {
								updateSobjectSet.add(authAppPlaceId);
								AuthApplicationPlace aap = mapOfAuthPlaceWithId.get(authAppPlaceId).clone(false, false, false, false);
								aap.PlaceId = locationId;
								listOfAutAppPlaceToBeUpdate.add(aap);
							}
						}
					}
				}
			}
			if(!listOfLocationToBeUpdate.isEmpty()){
				LPI_WithoutSharingUtility.updateSObjectRecord(listOfLocationToBeUpdate);
			}
			if(!listOfAutAppPlaceToBeUpdate.isEmpty()){
				LPI_WithoutSharingUtility.insertSObjectRecord(listOfAutAppPlaceToBeUpdate);
			}
		}
		catch (DmlException e) {
			LPI_ExceptionManager.logException(getClassName(),UPDATE_MAILING_ADDRESS_TO_BL, e);
		}
	}

	public static void handleNameAndAddressForAmendments(List<IndividualApplication> lstUpdatedIA) {
        try{
            Map<String,String> amendmentTypeToLocType = new Map<String,String>();
            amendmentTypeToLocType.put(LPI_LiteralConstant.PAR_AMENDMENT_SUBTYPE_NAME_OR_ADDRESS_CHANGE,
									LPI_LiteralConstant.LOCATION_TYPE_RESIDENCE);
            amendmentTypeToLocType.put(LPI_LiteralConstant.CHANGE_OF_INDIVIDUAL_BUSINESS_ADDRESS,
									LPI_LiteralConstant.LOCATION_TYPE_BUSINESS_ADDRESS);
			amendmentTypeToLocType.put(AMENDMENT_SUBTYPE_CHANGE_OF_NAME,'');
            amendmentTypeToLocType.put(
                AMENDMENT_SUBTYPE_CHANGE_OF_RESIDENCE_ADDRESS,
                LPI_LiteralConstant.LOCATION_TYPE_RESIDENCE
            );
			amendmentTypeToLocType.put(
				AMENDMENT_SUBTYPE_CHANGE_OF_MAILING_ADDRESS,
				MAILING_ADDRESS
			);
            amendmentTypeToLocType.put(
                AMENDMENT_SUBTYPE_ADDRESS,
                'Residence or Mailing'
            );
		
            Map<String,Set<Id>> amendmentTypeToIaIdSetMap = new Map<String,Set<Id>>();
            Map<Id,IndividualApplication> iaIdToIaMap = new Map<Id,IndividualApplication>();
            Map<Id, Id> iaIdToAccountIdMap = new Map<Id, Id>();
            Map<Id, Id> iaIdToBusinessLicenseIDMap = new Map<Id, Id>();
            Map<Id,Id> locIdToIAIdMap = new Map<Id,Id>();
            Map<Id,Schema.Location> iaIdLinkedWithLocMap = new Map<Id,Schema.Location>();
            Map<Id, Schema.Location> iaIdLinkedWithDifferentLocMap = new Map<Id, Schema.Location>();
            Map<Id,set<Id>> businessLicenseIdToLocIdSetMap = new Map<Id,set<Id>>();
            Set<Id> locIdSet = new Set<Id>();
            Map<Id,Schema.Location> locIdToLocationMap = new Map<Id,Schema.Location>();
            Map<Id,Id> authApplicationIdToLocIdMap = new  Map<Id,Id>();
            Set<Id> newOrClosedLocationIdSet = new Set<Id>();
            List<AuthApplicationPlace> updateAuthAppList = new List<AuthApplicationPlace>();

            for (IndividualApplication updatedIA : lstUpdatedIA) {
                String amendmentType = updatedIA.Amendment_Type__c;
                if (String.isNotBlank(amendmentType) && amendmentTypeToLocType.containsKey(amendmentType) &&
                    String.isNotBlank(updatedIA.Id) && String.isNotBlank(updatedIA.AccountId) &&
                    String.isNotBlank(updatedIA.LicensePermitNameId)){
                    if(amendmentTypeToIaIdSetMap.containsKey(amendmentType)){
                        amendmentTypeToIaIdSetMap.get(amendmentType).add(updatedIA.Id);
                    }else{
                        amendmentTypeToIaIdSetMap.put(amendmentType, new Set<Id>{updatedIA.Id});
                    }
                    iaIdToIaMap.put(updatedIA.Id, updatedIA);
                    iaIdToAccountIdMap.put(updatedIA.Id, updatedIA.AccountId);
                    iaIdToBusinessLicenseIDMap.put(updatedIA.Id, updatedIA.LicensePermitNameId);
                }
            }

            if(!amendmentTypeToIaIdSetMap.isEmpty() && !iaIdToIaMap.isEmpty()){
                String fieldToQuery = 'Id, PlaceId, RgltyAuthApplicationId, AuthorizationId';
				String whereClause = 'RgltyAuthApplicationId IN '+  LPI_ServiceUtility.getStringValuesBySet(iaIdToIaMap.keySet()) + 
                ' OR AuthorizationId IN '+ LPI_ServiceUtility.getStringValuesByList(iaIdToBusinessLicenseIDMap.values());
				for(AuthApplicationPlace authPlace : LPI_AuthApplicationPlaceDAO.getAuthApplicationPlaceByDymanicQuery(
					fieldToQuery,
					whereClause,
					null,
					null,
					null)){
                        if(String.isNotBlank(authPlace.PlaceId) && String.isNotBlank(authPlace.RgltyAuthApplicationId) 
                            && iaIdToIaMap.containsKey(authPlace.RgltyAuthApplicationId)
                        ){
                            locIdToIAIdMap.put(authPlace.PlaceId, authPlace.RgltyAuthApplicationId);
                            authApplicationIdToLocIdMap.put(authPlace.Id,authPlace.PlaceId);
                        }else if(String.isNotBlank(authPlace.AuthorizationId) && String.isNotBlank(authPlace.PlaceId) &&
                                iaIdToBusinessLicenseIDMap.values().contains(authPlace.AuthorizationId)){

                                if(businessLicenseIdToLocIdSetMap.containsKey(authPlace.AuthorizationId)){
                                    businessLicenseIdToLocIdSetMap.get(authPlace.AuthorizationId).add(authPlace.PlaceId);
                                }else{
                                    businessLicenseIdToLocIdSetMap.put(authPlace.AuthorizationId,new Set<Id>{authPlace.PlaceId});
                                }
                                locIdSet.add(authPlace.PlaceId);
                        }
				}

                if(!locIdToIAIdMap.isEmpty()){
                    fieldToQuery = 'Id, LocationType, Status__c, Firm_Email__c, Business_Phone__c';
                    whereClause = ' LocationType IN '+LPI_ServiceUtility.getStringValuesByList(amendmentTypeToLocType.values())+ 
                    'AND ((Id IN '+LPI_ServiceUtility.getStringValuesBySet(locIdToIAIdMap.keySet())+ ' AND (Status__c = NULL OR Status__c = \'Closed\')) OR '+ 
                    '(Id IN '+LPI_ServiceUtility.getStringValuesBySet(locIdSet)+' AND Status__c = \'Open\' ))';


                    for(Schema.Location loc : LPI_LocationDAO.getLocationByDymanicQuery(fieldToQuery,whereClause,null,null,null)){
                        if(locIdToIAIdMap.containsKey(loc.Id) && loc.Status__c == 'Closed'){
                            Id tempIAId = locIdToIAIdMap.get(loc.Id);
                            for(String amendmentType : amendmentTypeToIaIdSetMap.keySet()){
                                if(amendmentTypeToIaIdSetMap.get(amendmentType).contains(tempIAId) &&
                                	(loc.LocationType == amendmentTypeToLocType.get(amendmentType) || 
                                    (amendmentTypeToLocType.get(amendmentType).containsIgnoreCase('Residence')|| 
                                    amendmentTypeToLocType.get(amendmentType).containsIgnoreCase('Mailing')))
                                ){
                                   
                                    if (!iaIdLinkedWithLocMap.containsKey(tempIAId)) {
                                        iaIdLinkedWithLocMap.put(tempIAId, loc);
                                    } else {
                                       
                                        iaIdLinkedWithDifferentLocMap.put(tempIAId, loc);
                                    }
                                   
									newOrClosedLocationIdSet.add(loc.Id);
                                }
                            }
                        }else if(locIdSet.contains(loc.Id) && loc.Status__c == 'Open'){
                            locIdToLocationMap.put(loc.Id,loc);
                        }                        
                    }
                    List<Schema.Location> updateLocationList = new List<Schema.Location>();
                    Set<Id> uniqueLocationIdSet = new Set<Id>();
                    Set<Id> userInsertedLocIdSet = new Set<Id>();

                    for(Id tempIaId : iaIdLinkedWithLocMap.keySet()){
                        Schema.Location userInsertedloc = iaIdLinkedWithLocMap.get(tempIaId);
                        Schema.Location userInsertedDiffloc = new Schema.Location();
                        if (iaIdLinkedWithDifferentLocMap.containsKey(tempIaId)) {
                            userInsertedDiffloc = iaIdLinkedWithDifferentLocMap.get(tempIaId);
                        }
                        if(iaIdToBusinessLicenseIDMap.containsKey(tempIaId) &&
                        businessLicenseIdToLocIdSetMap.containsKey(iaIdToBusinessLicenseIDMap.get(tempIaId))
                        ){
                            Id tempBlId = iaIdToBusinessLicenseIDMap.get(tempIaId);
                            for(Id locId : businessLicenseIdToLocIdSetMap.get(tempBlId)){
                                if(locIdToLocationMap.containsKey(locId) &&
                                (locIdToLocationMap.get(locId).LocationType == userInsertedloc.LocationType || 
                                locIdToLocationMap.get(locId).LocationType == userInsertedDiffloc.LocationType)){
                                    if(!uniqueLocationIdSet.contains(locId)){
                                        Schema.Location locToBeClosed = locIdToLocationMap.get(locId);
                                        locToBeClosed.Status__c = 'Closed';
                                        locToBeClosed.CloseDate = System.today();
                                        updateLocationList.add(locToBeClosed);
                                        uniqueLocationIdSet.add(locId);
                                    }
                                }
                            }
                        }
                        if(!userInsertedLocIdSet.contains(userInsertedloc.Id)){
                            Schema.Location locToBeOpen = userInsertedloc;
							IndividualApplication tempIaObj = iaIdToIaMap.get(tempIaId);
							locToBeOpen.Name = getFullName(tempIaObj) + '-' +locToBeOpen.LocationType;
                            locToBeOpen.Status__c = 'Open';
                            locToBeOpen.CloseDate = null;
                            locToBeOpen.OpenDate = System.today();
                            updateLocationList.add(locToBeOpen);
                            userInsertedLocIdSet.add(userInsertedloc.Id);
                        }
			
                        if ( userInsertedDiffloc.Id != null && !userInsertedLocIdSet.contains(userInsertedDiffloc.Id) ) {
                            Schema.Location locToBeOpen = userInsertedDiffloc;
                            IndividualApplication tempIaObj = iaIdToIaMap.get(tempIaId);
							locToBeOpen.Name = getFullName(tempIaObj) + '-' +locToBeOpen.LocationType;
                            locToBeOpen.Status__c = 'Open';
                            locToBeOpen.CloseDate = null;
                            locToBeOpen.OpenDate = System.today();
                            updateLocationList.add(locToBeOpen);
                            userInsertedLocIdSet.add(userInsertedDiffloc.Id);
                        }
						
                    }

                    for(Id tempAuthId : authApplicationIdToLocIdMap.keySet()){
                        Id locId = authApplicationIdToLocIdMap.get(tempAuthId);
                        if(newOrClosedLocationIdSet.contains(locId) && locIdToIAIdMap.containsKey(locId) && 
                            iaIdToBusinessLicenseIDMap.containsKey(locIdToIAIdMap.get(locId)) 
                        ){
                            AuthApplicationPlace authApp = new AuthApplicationPlace();
                            authApp.id = tempAuthId;
                            authApp.AuthorizationId = iaIdToBusinessLicenseIDMap.get(locIdToIAIdMap.get(locId));
                            updateAuthAppList.add(authApp);
                        }
                    }

                    if(!iaIdToAccountIdMap.isEmpty() && !iaIdToIaMap.isEmpty()){
                        handlePersonAccountNameAndAddress(iaIdLinkedWithLocMap,iaIdToAccountIdMap,iaIdToIaMap);
                    }

                    if(!iaIdLinkedWithLocMap.isEmpty() && !iaIdToAccountIdMap.isEmpty()){
                        handleAssociatedLocationForAddressChange(iaIdLinkedWithLocMap,iaIdToAccountIdMap);
                    }

                    if(!updateLocationList.isEmpty()){
                        LPI_DML.doUpdate(updateLocationList);
                    }
                    
                    if(!updateAuthAppList.isEmpty()){
                        LPI_DML.doUpdate(updateAuthAppList);
                    }
                }
            }
        } catch (Exception ex) {
			LPI_ExceptionManager.logException(getClassName(), 'handleNameAndAddressForAmendments', ex);
		}
	}

	private static BusinessLicense updateNameOnBusinessLicense(IndividualApplication iaRecord) {
		BusinessLicense blRecord = new BusinessLicense(Id = iaRecord.LicensePermitNameId);
		blRecord.First_Name__c = iaRecord.First_Name__c;
		blRecord.Last_Name__c = iaRecord.Last_Name__c;
		blRecord.Middle_Name__c = iaRecord.Middle_Name__c;
		blRecord.Maiden_Name__c = iaRecord.Maiden_Name__c;
		return blRecord;
	}

	private static BusinessLicense handleAmendmentLicenseTransfer(IndividualApplication iaRecord) {
		BusinessLicense blRecord = new BusinessLicense(Id = iaRecord.LicensePermitNameId);
		
		return blRecord;
	}

	private static void handleAmendmentObtainAdditionalLicense(
		List<IndividualApplication> iaRecords,
		Integer blNameCounter
	) {
		Map<String, RegulatoryAuthorizationType> mapOfRegAuth = new Map<String, RegulatoryAuthorizationType>();
		List<BusinessLicense> lstBLToUpsert = new List<BusinessLicense>();
		String fieldsToQuery = 'ID,Name,Open_for_Renewal__c,Expiry_Rule_Type__c,'+
		'Renewal_Window_Period_Before_Expiry__c,Expiration_Day__c,Expiration_Month__c,'+
			'Expiration_Cycle__c,Expiration_Period__c,Expiration_Date__c';
		String whereClause = 'Name LIKE \'Broker%\'';
		set<String> setOfAccId = new Set<String>();
		for (RegulatoryAuthorizationType regAuthType : LPI_RegulatoryAuthorizationTypeDAO.getRegulatoryAuthorizationTypeByDymanicQuery(
				fieldsToQuery,
				whereClause,
				null,
				null,
			null)
		){
			mapOfRegAuth.put(regAuthType.Name, regAuthType);
		}
		for(IndividualApplication iaRecord : iaRecords){
			setOfAccId.add(iaRecord.AccountId);
		}

		if(!setOfAccId.isEmpty()){
			Map<Id, Account> personAccountData = new Map<Id, Account>(
				LPI_AccountDAO.getAccountByIDs(setOfAccId)
					);
			if(!lstBLToUpsert.isEmpty()){
				LPI_DML.doUpsert(lstBLToUpsert);
				In_App_Checklist_Settings__c appcheckCustomSetting = In_App_Checklist_Settings__c.getOrgDefaults();
				appcheckCustomSetting.Business_License_Counter__c = blNameCounter;
				LPI_WithoutSharingUtility.updateAppChecklistCustomSetting(appcheckCustomSetting);
			}
		}
	}

	private static void updateLicenseTypeOnBusinessLicenses(Set<Id> iaApplicationIds){
		Set<String> ratNameSet = new Set<String>{LPI_LiteralConstant.BROKER_SALESPERSON,LPI_LiteralConstant.BROKER,
			LPI_LiteralConstant.BROKER_ASSOCIATE, LPI_LiteralConstant.BROKER_OFFICER,
			LPI_LiteralConstant.BROKER_PARTNER,LPI_LiteralConstant.SALESPERSON};
		Map<String, Id> regAuthTypeNameToIdMap = new Map<String, Id>();
		List<IndividualApplication> iaApplicationList = new List<IndividualApplication>();
		List<BusinessLicense> blToUpdate = new List<BusinessLicense>();

		String fieldToQuery = 'Id,Amendment_Type__c,SavedApplicationRef.Change_Status_to__c,'
            +'LicensePermitNameId,LicensePermitName.Status';
		String whereClause = 'Id IN '+LPI_ServiceUtility.getStringValuesBySet(iaApplicationIds);
		for(IndividualApplication ia : LPI_IndividualApplicationDAO.getIndividualApplicationByDymanicQuery(
				fieldToQuery,
				whereClause,
				null,
				null,
			null)){
			if (ratNameSet.contains(ia.SavedApplicationRef.Change_Status_to__c)){
				regAuthTypeNameToIdMap.put(ia.SavedApplicationRef.Change_Status_to__c, null);
				iaApplicationList.add(ia);
			}
		}

		if(!regAuthTypeNameToIdMap.isEmpty()){
			fieldToQuery = 'Id,Name';
			whereClause = 'Name IN '+LPI_ServiceUtility.getStringValuesByStringSet(regAuthTypeNameToIdMap.keySet());
			for(RegulatoryAuthorizationType rat : LPI_RegulatoryAuthorizationTypeDAO.getRegulatoryAuthorizationTypeByDymanicQuery(
					fieldToQuery,
					whereClause,
					null,
					null,
				null)){
				regAuthTypeNameToIdMap.put(rat.Name,rat.Id);
			}

			for(IndividualApplication ia : iaApplicationList){
				if(regAuthTypeNameToIdMap.containsKey(ia.SavedApplicationRef.Change_Status_to__c) 
					&& regAuthTypeNameToIdMap.get(ia.SavedApplicationRef.Change_Status_to__c) != null)
				{
					BusinessLicense businessLicense = new BusinessLicense(Id = ia.LicensePermitNameId);
					businessLicense.RegulatoryAuthorizationTypeId = regAuthTypeNameToIdMap.get(ia.SavedApplicationRef.Change_Status_to__c);
					if(ia.LicensePermitName.Status != null && ia.LicensePermitName.Status ==  LPI_LiteralConstant.BUSINESSLICENSE_STATUS_CANCELLED){
						businessLicense.Status = LPI_LiteralConstant.BUSINESSLICENSE_STATUS_ACTIVE;
					}
					blToUpdate.add(businessLicense);

				}
			}
		}

		if(!blToUpdate.isEmpty()){
			LPI_DML.doUpdate(blToUpdate);
		}
	}

	private static void prePopulateApplicationContentFieldsonBL(Application_Content__c ap, BusinessLicense blRec , Account accRec) {
        if(ap == null) {
            return;
        }
		accRec.Inches__c = ap.Inches__c;
		accRec.Hair_Color__c = ap.Hair_Color__c;
		accRec.Eye_Color__c = ap.Eye_Color__c;
		accRec.Feet__c = ap.Feet__c;
		accRec.Distinguishing_Characteristics__c = ap.Distinguishing_Characteristics__c;
	}

	private static void handlePersonAccountNameAndAddress(Map<Id,Schema.Location> iaIdLinkedWithLocMap, 
                                            Map<Id, Id> iaIdToAccountIdMap, 
                                            Map<Id,IndividualApplication> iaIdToIaMap){
        List<Account> accUpdateList = new List<Account>();
        Set<Id> locationIdSet = new Set<Id>();
        Map<Id,Schema.Address> locIdtoAddressMap= new Map<Id,Schema.Address>();
        for(Schema.Location loc : iaIdLinkedWithLocMap.values()){
            locationIdSet.add(loc.Id);
        }
		if(!locationIdSet.isEmpty()){
			String fieldToQuery = 'ID, City, PostalCode, State, Street, ParentId, CountryCode, Business_State__c';
			String whereClause =  'ParentId IN '+LPI_ServiceUtility.getStringValuesBySet(locationIdSet);

			for (Schema.Address tempAddress : LPI_AddressDAO.getAddressByDymanicQuery(fieldToQuery,whereClause,null,null,null)){
				locIdtoAddressMap.put(tempAddress.ParentId,tempAddress);
			}
		}
        

        for(Id tempIAId : iaIdToAccountIdMap.keySet()){
            Id tempaccId = iaIdToAccountIdMap.get(tempIAId);
            IndividualApplication iaRecord = iaIdToIaMap.get(tempIAId);
            Boolean includeAccount = false;
            Account acc = new Account();
            acc.id = tempaccId;
            if(iaIdLinkedWithLocMap.containsKey(tempIAId)){
                Schema.Location loc = iaIdLinkedWithLocMap.get(tempIAId);
                String locType = iaIdLinkedWithLocMap.get(tempIAId).LocationType;
                if(locIdtoAddressMap.containsKey(loc.Id)){
                    Schema.Address tempAddress = locIdtoAddressMap.get(loc.Id);
                    if(locType == LPI_LiteralConstant.LOCATION_TYPE_RESIDENCE){
                        acc.PersonOtherCity = tempAddress.City;
                        acc.PersonOtherStreet = tempAddress.Street;
                        acc.PersonOtherPostalCode = tempAddress.PostalCode;
                        acc.PersonOtherCountryCode = tempAddress.CountryCode;
                        if(tempAddress.CountryCode == 'US'){
                            acc.PersonOtherState = tempAddress.State;
                            acc.Other_State__c = null;
                        }else{
                            acc.Other_State__c = tempAddress.Business_State__c;
                            acc.PersonOtherState = null;
                        }
                        includeAccount = true;
                    }
  
                }
            }
            if(includeAccount){
                accUpdateList.add(acc);
            }
        }
        if(!accUpdateList.isEmpty()){
            
            LPI_WithoutSharingUtility.updateSObjectRecord(accUpdateList);
        }
    }

	private static void handleAssociatedLocationForAddressChange(Map<Id,Schema.Location> iaIdLinkedWithLocMap, Map<Id, Id> iaIdToAccountIdMap) {
        List<AssociatedLocation> associatedLocationTobeInserted = new List<AssociatedLocation>();
        for(Id tempIAId : iaIdToAccountIdMap.keySet()){
            Id tempaccId = iaIdToAccountIdMap.get(tempIAId);
            if(iaIdLinkedWithLocMap.containsKey(tempIAId)){
                Schema.Location loc = iaIdLinkedWithLocMap.get(tempIAId);
				if(loc.LocationType == LPI_LiteralConstant.LOCATION_TYPE_BUSINESS_ADDRESS){
					continue;
				}
                AssociatedLocation ascLocation = new AssociatedLocation();
                ascLocation.LocationId = loc.Id;
                ascLocation.ParentRecordId = tempaccId;
                associatedLocationTobeInserted.add(ascLocation);
            }
        }
        if (!associatedLocationTobeInserted.isEmpty()) {
           
			LPI_WithoutSharingUtility.insertSObjectList(associatedLocationTobeInserted);
        }
	}

	@TestVisible private static String getFullName(IndividualApplication tempIaObj){
        String fullName = '';
        if(String.isNotBlank(tempIaObj.First_Name__c)){
            fullName = tempIaObj.First_Name__c;
        }
        if(String.isNotBlank(tempIaObj.Middle_Name__c)){
            if(String.isNotBlank(fullName)){
                fullName += ' ';
            }
            fullName += tempIaObj.Middle_Name__c;
        }
        if(String.isNotBlank(tempIaObj.Last_Name__c)){
            if(String.isNotBlank(fullName)){
                fullName += ' ';
            }
            fullName += tempIaObj.Last_Name__c;
        }
        return fullName;
    }
}