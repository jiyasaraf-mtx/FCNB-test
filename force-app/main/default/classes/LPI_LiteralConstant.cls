/**
 * @description       :
 * @author            : Vamsi Mudaliar
 * @group             :
 * @last modified on  : 08-16-2024
 * @last modified by  : MTX Group Product Team
 **/
//defines constants so that they can be used in different classes/to avoid Insecure DOR
public with sharing class LPI_LiteralConstant {
    public final static string DML_UPDATE = 'update';
    public final static string DML_UPSERT = 'upsert';
    public final static string DML_INSERT = 'insert';
    public final static string DML_DELETE = 'delete';
    public final static String USER_SOBJECT_API = 'User';
    public final static String USER_TIMEZONE_SID_KEY = 'America/Los_Angeles';
    public final static String USER_EMAIL_ENCODING_KEY = 'UTF-8';
    public final static String USER_LANGUAGE_LOCALE_KEY = 'en_US';
    public final static String USER_LOCALE_SID_KEY = 'en_US';
    public final static String USER_USERNAME_SUFFIX =
        '.' + Label.PortalUserNameSuffix;
    public final static String NO_MATCH_PROFILE_FOUND = 'No Matching Profile Found';
    public final static String ACCOUNT_SOBJECT_API = 'Account';
    public final static String ACCOUNT_LPI_ACCOUNT_RECORDTYPE = 'LPI_Account';
    public final static String ACCOUNT_AGENCY_RECORDTYPE = 'Agency';
    public final static String ACCOUNT_PERSON_RECORDTYPE = 'PersonAccount';
    public final static String ACCOUNT_BUSINESS_RECORDTYPE = 'Business';
    public final static String CONTACT_BUSINESS_RECORDTYPE = 'Business';
    public final static String OMNISTUDIO_STANDARD_EXPERIENCE_USER = 'OmniStudio_Standard_Experience_Users';
    public final static String DOC_GENRUNTIME_COMMUNITY_USERS = 'DocGenRuntimeCC';
    public final static Set<String> PERMISSION_SET_SET = new Set<String>{
        OMNISTUDIO_STANDARD_EXPERIENCE_USER,
        DOC_GENRUNTIME_COMMUNITY_USERS
    };
    public final static String Contact_SOBJECT_API = 'Contact';
    public final static String CONTACT_INDIVIDUAL_RECORDTYPE = 'Individual';
    public final static String CONTACT_AGENT_RECORDTYPE = 'Agent';
    public final static string NETWORK_ID_LICENSING_PORTAL = '0DBWF00000003Ir4AI';
    public final static String Portal_Profile_Name = 'Portal User';
    public final static String Agent_Portal_Profile_Name = 'Agent Portal User';
    public final static String PRE_APPLICATION_INTAKEFORM_URL_VARIABLENAME = '&c__parid=';
    public final static String BUSINESS_L_A_INTAKEFORM_URL_VARIABLENAME = '&c__blaid=';
    public final static String PORTAL_USER_INTAKEFORM_URL_VARIABLENAME = '&c__portalUser=';
    public final static String INDIVIDUAL_L_A_INTAKEFORM_URL_VARIABLENAME = '&c__ilaid=';
    public final static string CONTENTDOCUMENT_SOBJECT_API = 'ContentDocument';
    public final static string CONTENTVERSION_SOBJECT_API = 'ContentVersion';
    public final static string REGAUTHCONTENT_SOBJECT_API = 'Regulatory_Authorization_Content__c';
    public final static string BLACONTENT_SOBJECT_API = 'Business_License_Application_Content__c';
    public final static string PARCONTENT_SOBJECT_API = 'Preliminary_Application_Content__c';
    public final static string INVALID_SOBJECT_API = 'Invalid';
    public final static string DOCUMENT_RECORDTYPE_API = 'Document';
    //PreliminaryApplicationRef
    public final static string PAR_SOBJECT_API = 'PreliminaryApplicationRef';
    public final static string PAR_DRAFT_STATUS = 'Draft';
    public final static string PAR_SUBMITTED_STATUS = 'Submitted';
    public final static string PAR_CONVERTED_STATUS = 'Converted';

    //BusinessLicense
    
    public final static string BLA_SOBJECT_API = 'BusinessLicenseApplication';
    public final static string BLA_AMENDMENT_APPLICATIONTYPE = 'Amendment';
    public final static string BLA_NEW_APPLICATIONTYPE = 'New';
    public final static string BLA_RENEWAL_APPLICATIONTYPE = 'Renewal';
    public final static string BLA_SUBMITTED_STATUS = 'Submitted';
    public final static string BLA_DRAFT_STATUS = 'Draft';
    public final static string BLA_RE_SUBMITTED_STATUS = 'Re-Submitted';
    public final static string BLA_UNDER_REVIEW_STATUS = 'Under Review';
    public final static string BLA_APPROVED_STATUS = 'Approved';
    public final static string BLA_REJECTED_STATUS = 'Rejected';
    public final static string BLA_CLOSED_STATUS = 'Closed';
    public final static string BLA_LICENSEISSUED_STATUS = 'License Issued';
    public final static string BLA_WITHDRAWN_STATUS = 'Withdrawn';
    public final static string BLA_CHANGES_NEEDED_STATUS = 'Changes Needed';
    public final static string BLA_NEW_APPLICATION_RECORDTYPE = 'New_Application';
    public final static string BLA_AMENDMENT_RECORDTYPE = 'Amendment';
    public final static string BLA_RENEWAL_RECORDTYPE = 'Renewal';
    public final static string BLA_IN_PROGRESS_STATUS = 'In Progress';
    public final static string BLA_PAYMENT_PENDING_STATUS = 'Payment Pending';
    public final static string BLA_CHANGE_OF_DESIGNATED_INCHARGE = 'Change of Designated Incharge';
    public final static string BLA_CHANGE_OF_OWNERSHIP = 'Change of Ownership';
    public final static string BLA_CHANGE_OF_INTERIM_DESIGNATED_INCHARGE = 'Change of Interim Designated Incharge';
    public final static string BLA_BUSINESS_OUTSIDE_MISSOURI = 'Business outside Missouri';
    public final static string BLA_CHANGE_OF_CORPORATION_ASSOCIATION_PARTNERSHIP = 'Facility Name Change';
    public final static string BLA_CHANGE_OF_FICTITIOUS_NAME_OR_TRADE_NAME = 'Facility Fictitious / (Doing Business As) DBA Name change';
    public final static string BLA_REMOVE_LICENSEE_FROM_ENTITY_AFFILIATION = 'Remove licensee from entity’s affiliation';
    public final static String BLA_BRANCH_OFFICE_NOTIFICATION = 'Branch Office Notification';
    public final static String BLA_CHANGE_OF_CLASS_CLASSIFICATION = 'Change Of Class Classification Application';
    public final static String BLA_CHANGE_IN_CURRICULUM = 'Change in Curriculum';
    public final static String BLA_INCREASE_IN_ENROLLMENT = 'Increase in Enrollment';
    public static final String INCREASE_IN_ENROLLMENT_AMENDMENT_LABEL = 'Change in Enrollment';

    //IndividualApplication
    public final static string IA_SOBJECT_API = 'IndividualApplication';
    public final static string IA_DRAFT_STATUS = 'Draft';
    public final static string IA_SUBMITTED_STATUS = 'Submitted';
    public final static string IA_RESUBMITTED_STATUS = 'Re-Submitted';
    public final static string IA_UNDER_REVIEW_STATUS = 'Under Review';
    public final static string IA_IN_PROGRESS_STATUS = 'In Progress';
    public final static string IA_REQUEST_FOR_REFUND_STATUS = 'Request for Refund';
    public final static string IA_APPROVED_STATUS = 'Approved';
    public final static string IA_REJECTED_STATUS = 'Rejected';
    public final static string IA_LICENSEISSUED_STATUS = 'License Issued';
    public final static string IA_AMENDMENT_APPLICATIONTYPE = 'Amendment';
    public final static string IA_NEW_APPLICATIONTYPE = 'New';
    public final static string IA_RENEWAL_APPLICATIONTYPE = 'Renewal';
    public final static string IA_REINSTATEMENT_APPLICATIONTYPE = 'Reinstatement';
    public final static string IA_AWAITING_RESPONSE_STATUS = 'Awaiting Response';
    public final static string IA_PAYMENT_PENDING_STATUS = 'Payment Pending';

    public final static string WLI_Manual_Status_RECORDTYPE = 'Manual_Status';
    public final static string WLI_APPROVAL_STEP_RECORDTYPE = 'Approval_Step';
    public final static string WLI_APPROVAL_STEP_RECORDTYPE_NAME = 'Approval Step';
    public final static string WLI_MANUAL_STATUS_RECORDTYPE_NAME = 'Manual Status';

    public final static string Inspection_Type_ROUTINE = 'Routine';
    public final static string Inspection_Type_PRELIMINARY = 'New';
    public final static string Inspection_Type_COMPLAINT = 'Complaint';
    public final static string Inspection_Recurrence_ANNUALLY = 'Annually';
    public final static string Inspection_Recurrence_HALFYEARLY = 'Half Yearly';
    public final static string Inspection_Status_COMPLETED = 'Completed';
    public final static string Inspection_Status_PLANNED = 'Planned';
    public final static string Expiration_Cycle_EVEN = 'Even';
    public final static string Expiration_Cycle_ODD = 'Odd';
    public final static string Expiration_Cycle_ANNUAL = 'Annual';
    public final static string Expiration_Cycle_BIENNIAL = 'Biennial';
    public final static string EXPIRATION_CYCLE_FIVE_YEARS = '5 Years From Approval';
    public final static string EXPIRATION_CYCLE_TWO_YEARS = '2 Years From Approval';
    public final static string EXPIRATION_CYCLE_FIXED_CYCLE = 'Fixed Cycle';
    public final static string EXPIRATION_PERIOD_CONTAINS_DAYS = ' Days';
    public final static string EXPIRATION_DAY_DAY_OF_ISSUANCE_MINUS_1 = 'Day of Issuance - 1';
    public final static string EXPIRATION_MONTH_MONTH_OF_ISSUANCE = 'Month of Issuance';
    public final static string Business_License_Status_EXPIRED = 'Expired';
    public final static String PAR_SOBJECT_TYPE_INACTIVATION = 'Inactivation';
    public final static String STATUS_INACTIVE = 'Inactive';
    public final static String LQ_PS_REINST_NUMBEROFCONTRACTS = 'NumberOfContracts';
    public final static String PAR_SOBJECT_TYPE_REACTIVATION = 'Reactivation';
    public final static String STATUS_ACTIVE = 'Active';
    public final static String PAR_SOBJECT_TYPE_REINSTATEMENT = 'Reinstatement';
    public final static String STATUS_SUSPENDED = 'Suspended';
    public final static String PAR_SOBJECT_TYPE_AMENDMENT = 'Amendment';
    public final static String BUSINESS_INFO_STEP_NAME = 'IndividualBusinessInformation';
    public final static List<String> BUSINESS_INFO_FIELD_NAMES = new List<String>{
        'FictitiousName',
        'BusinessPhone',
        'BusinessEmail',
        'BusinessName',
        'BusinessWebsite',
        'BusinessCity',
        'BusinessState',
        'BusinessZipcode',
        'StreetAddress1',
        'StreetAddress2',
        'BusinessCountry',
        'BusinessCounty'
    };
    public final static Set<String> setOfOpenApplicationStatus = new Set<String>{
        BLA_SUBMITTED_STATUS,
        BLA_RE_SUBMITTED_STATUS,
        BLA_UNDER_REVIEW_STATUS
    };
    public final static Set<String> setOfAllApplicationStatus = new Set<String>{
        BLA_CHANGES_NEEDED_STATUS,
        BLA_APPROVED_STATUS,
        BLA_RE_SUBMITTED_STATUS,
        BLA_SUBMITTED_STATUS,
        BLA_UNDER_REVIEW_STATUS,
        BLA_WITHDRAWN_STATUS,
        BLA_CLOSED_STATUS,
        BLA_REJECTED_STATUS
    };

    public final static String OTP_SOBJECT_API = 'OTP__c';
    public final static String FINAL_OTP_TYPE_ADDBUSINESS = 'Add Business';
    public final static String FINAL_OTP_PRIMARYCONTACTERROR = 'ERROR: No primary contact found for the Business.';
    public final static String FINAL_OTP_INVALIDOTP = 'ERROR: Invalid OTP';
    public final static String FINAL_OTP_SUCCESSOTP = 'SUCCESS: OTP Validated successfully';
    public static final String REGULATORY_AUTH_TYPE_CONFIG_RECTYP_WORKFLOW = Schema.getGlobalDescribe()
        .get('Regulatory_Auth_Type_WorkFlow__c')
        .getDescribe()
        .getRecordTypeInfosByDeveloperName()
        .get('Workflow')
        .getRecordTypeId();
        
    //Doc Gen constant
    public final static String DOCGENRUNTIMECC = 'DocGenRuntimeCC';
    public final static String DOCGENDESIGNER = 'DocGenDesigner';
    public final static String DOCGENRUNTIME = 'DocGenRuntime';
    public final static String DOCGEN_TEMPLATE_LIBRARY = 'Docgen Document Template Library';

    //Omniscript profile
    public final static String OmniStudio_Standard_Experience_Users = 'OmniStudio_Standard_Experience_Users';

    //ViolationType Object Name
  public final static string VIOLATION_TYPE = 'ViolationType';
  public final static string VIOLATION_TYPE_PICKLIST_FIELD_NAME = 'Type';

  public final static string VISIT_STATUS_PLANNED = 'Planned';
  public final static string VISIT_STATUS_INPROGRESS = 'InProgress';
  public final static string VISIT_STATUS_COMPLETED = 'Completed';
  public final static string VISIT_STATUS_NONCOMPLIANCE = 'Non Compliance';
  public final static string VISIT_READONLY_STATUS = 'readOnlyVisit';
  public final static string VISIT_CORRECTIVE_ACTION_STATUS_OPEN = 'Open';
  public final static string VISIT_CORRECTIVE_ACTION_STATUS_IN_REVIEW = 'In Review';
  public final static string VISIT_CORRECTIVE_ACTION_STATUS_RESOLVED = 'Resolved';

  //RegulatoryCodeViolation Object Name
  public final static string REGULATORY_CODE_VIOLATION = 'RegulatoryCodeViolation';
  public final static string REG_CODE_VIOL_PICKLIST_FIELD_NAME = 'Status';
  public final static string REG_CODE_VIOL_STATUS_IN_REVIEW = 'In Review';
  public final static string REG_CODE_VIOL_STATUS_OPEN = 'Open';
  public final static string REG_CODE_VIOL_STATUS_RESOLVED= 'Resolved';

    //Payment
    public final static String REG_PAID = 'PAID';
    public final static String ADMIN_PROFILE = 'System Administrator';
    public final static String PORTAL_USER_PROFILE = 'Portal User';
    public final static String COMMUNITY_NAME = 'Licensing_Portal';
    public final static String Metadata_Renewal_Behaviour_Analyst = 'Renewal_Behaviour_Analyst';
    public final static String MetaData_Renewal_Is_Due_Reminder_90_60_30 = 'Renewal_Is_Due_Reminder_90_60_30';
    public final static String Salutation_Thank_You = 'Thank You';
    public final static String MetaData_License_Expired_Notification = 'License_Expired_Notification';
    public final static String MetaData_License_Is_In_Renewal_Notification = 'License_Is_In_Renewal_Notification';
    public final static String MetaData_License_Renewal_Elapsed_Notification = 'License_Renewal_Elapsed_Notification';
    public final static String Template_Generic_Email_Template = 'Generic_Email_Template';
    public final static String MetaData_Business_License_Approval = 'Business_License_Approval';
    public final static String MetaData_Business_License_Rejected = 'Business_License_Rejected';
    public final static String MetaData_Seeking_Complainant_Information = 'Seeking_Complainant_Information';
    public final static String MetaData_New_Applic_Designator_Broker_Decision = 'New_Applic_Designator_Broker_Decision';
    public final static String MetaData_Amendment_Name_Address_Change = 'AmendmentName_AddressChange';
    public final static String MetaData_Reinstatement_of_Suspended = 'ReinstatementOfSuspendedLicense';
    public final static String MetaData_Amendment_Transfer_License = 'AmendmentTransferofLicense';
    public final static String METADATA_AMENDMENT_CHANGE_STATUS = 'AmendmentStatusChange';
    public final static String METADATA_AMENDMENT_CHANGE_STATUS_FOR_BROKER = 'AmendmentStatusChangeForBroker';
    public final static String METADATA_AMENDMENT_CHANGE_STATUS_TO_BROKER = 'AmendmentStatusChangeToIndividualBroker';
    public final static String METADATA_AMENDMENT_OBTAIN_ADD_LICENSE = 'AmendmentObtainAdditionalLicense';
    public final static String METADATA_AMENDMENT_REMOVE_LICENSEE_FROM_AFFILIATION = 'Amendment_RemoveLicensee';
    public final static String MetaData_Reminder_of_License_Date_of_Expiry = 'Reminder_of_License_Date_of_Expiry';
    public final static String METADATA_AMENDMENT_CANCELLED_LICENSE_STATUS_CHANGE = 'Amendment_CancelledLicenseStatusChange';
    public final static String METADATA_AMENDMENT_CHANGE_OF_DESIGNATED_INCHARGE = 'Change_of_Designated_Incharge';

    public final static String METADATA_LETTER_TO_RESPONDENT_FOR_NO_RESPONSE = 'Letter_to_Respondent_For_No_Response'; 
    public final static String METADATA_FOLLOW_UP_REMINDER_TO_BOARD_STAFF_15_DAY = 'Follow_up_reminder_to_Board_Staff_15_Day';
    public final static String METADATA_FOLLOW_UP_REMINDER_TO_BOARD_STAFF_30_DAY = 'Follow_up_reminder_to_Board_Staff_30_Day';
    public final static String METADATA_FOLLOW_UP_REMINDER_TO_BOARD_STAFF_45_DAY = 'Follow_up_reminder_to_Board_Staff_45_Day';
    public final static String METADATA_FOLLOW_UP_REMINDER_TO_BOARD_STAFF_60_DAY = 'Follow_up_reminder_to_Board_Staff_60_Day';

    public final static String Community_Navigation = 'comm__namedPage';
    public final static String Standard_Navigation = 'standard__component';

    //Application Document Status
    public final static String APPDOC_STATUS = 'Unsubmitted';
    public final static String APPDOC_STATUS_SUBMITTED = 'Submitted';

    //Queue
    public final static string QUEUE_SOBJECT_API_NAME = 'Queue';
    public final static string INTERNAL_STAFF_MEMBERS_QUEUE_NAME = 'Internal_Staff_Members';

    //Due Diligence
    public final static String DUE_DILIGENCE_SOBJECT_API = 'Due_Diligence__c';
    public final static String DD_NOT_STARTED_STATUS = 'Not Started';

    //Application Type
    public final static String BUSINESSLICENSE_APPTYPE = 'Business';
    public final static String INDIVIDAULICENSE_APPTYPE = 'Individual';

    //BusinessLicense
    public final static String BUSINESSLICENSE_SOBJECT_API = 'BusinessLicense';
    public final static String BUSINESSLICENSE_STATUS_ACTIVE = 'Active';
    public final static String BUSINESSLICENSE_STATUS_CANCELLED = 'Cancelled';
    public final static String BUSINESSLICENSE_STATUS_INACTIVE = 'Inactive';

    //Amendment Type
    public final static String PAR_AMENDMENT_SUBTYPE_LICENSE_TRANSFER = 'Transfer Salesperson or Broker-Salesperson license to another Broker';
    public final static String PAR_AMENDMENT_SUBTYPE_NAME_OR_ADDRESS_CHANGE = 'Change of Name and/or Residence Address';
    public final static String PAR_AMENDMENT_SUBTYPE_STATUS_CHANGE = 'Change status to other status';
    public final static String PAR_AMENDMENT_SUBTYPE_OBTAIN_ADD_LICENSE = 'Obtain Additional License';
    public final static String BROKER_SALESPERSON = 'Broker Salesperson';
    public final static String BROKER = 'Broker';
    public final static String BROKER_ASSOCIATE = 'Broker Associate';
    public final static String BROKER_OFFICER = 'Broker Officer';
    public final static String BROKER_PARTNER = 'Broker Partner';
    public final static String SALESPERSON = 'Salesperson';
    public final static String PROF_CORP_SALESPERSON = 'Prof. Corp. Salesperson';
    public final static String PROF_CORP_BROKER_SALESPERSON = 'Prof. Corp. Broker Salesperson';

    // Examination Details
    public final static String REAL_ESTATE_BROKER_NATIONAL = 'Real Estate National Broker Examination';
    public final static String REAL_ESTATE_BROKER_STATE = 'Missouri Real Estate Broker Examination';
    public final static String REAL_ESTATE_SALESPERSON_NATIONAL = 'Real Estate National Salesperson Examination';
    public final static String REAL_ESTATE_SALESPERSON_STATE = 'Missouri Real Estate Salesperson Examination';

    // AmendmentApplicationController. - start
    public final static String RS_BROKERAGE_AMEND_TYPEAHEAD = 'RSBrokerageAmendmentTypeAhead';
    public final static String RS_BROKERAGE_LICENSE_NUMBER = 'RSBrokerageLicenseNumber';
    public final static String RS_BROKERAGE_LICENSE_INFO = 'LicenseInformation';
    // AmendmentApplicationController. - end

    //ACR Roles
    public final static String ROLE_DESIGNATED_INCHARGE = 'Designated Incharge';
    public final static String ROLE_OWNER = 'Owner';
    public final static String ROLE_DESIGNATED_INCHARGE_AND_OWNER = 'Owner + Designated Incharge';
    public final static String ROLE_EMPLOYEE = 'Employee';
    public final static String FUNERAL_ESTABLISHMENT_EMPLOYEE = 'Funeral Establishment Employee';
    public final static String ROLE_PRIMARY_SUPERVISOR = 'Primary Supervisor';
    public final static String ROLE_PURCHASER = 'Purchaser';
    public final static String ROLE_AUTHORISED_SELLERS_DEALERS = 'Authorised Sellers/Dealers';
    public final static String ACR_ROLE_DESIGNATION_CUSTODIAN = 'Designation of Custodial';
    public final static String ROLE_SECONDARY_SUPERVISOR = 'Secondary Supervisor';
    public final static Set<String> SET_OF_ACR_ROLES = new Set<String>{
        ROLE_DESIGNATED_INCHARGE,
        ROLE_EMPLOYEE,
        FUNERAL_ESTABLISHMENT_EMPLOYEE,
        ROLE_DESIGNATED_INCHARGE_AND_OWNER,
        ROLE_OWNER,
        ROLE_PURCHASER,
        ACR_ROLE_DESIGNATION_CUSTODIAN,
        ROLE_SECONDARY_SUPERVISOR
    };
    // TRADE NAME Amendment Request Type Values
    public final static String AMENDMENT_REQUEST_TYPE_NEW = 'New';
    public final static String AMENDMENT_REQUEST_TYPE_CANCEL = 'Cancel';
    public final static String AMENDMENT_REQUEST_TYPE_RENEW = 'Renew';

    //BRANCH OFFICE NOTIFICATION Amendment Request Type Values
    public final static String BRANCH_OFFICE_AMENDMENDT_TYPE_NEW_OR_ADDITIONAL_BRANCH = 'New/additional branch office';
    public final static String BRANCH_OFFICE_AMENDMENDT_TYPE_CHANGE_IN_BRANCH = 'Change in branch office';
    public final static String BRANCH_OFFICE_AMENDMENDT_TYPE_CLOSING_BRANCH = 'Closing branch office';
    public final static String BRANCH_OFFICE_AMENDMENDT_TYPE_CHANGE_IN_BRANCH_MANAGER = 'Change in branch manager';

    //Location Status
    public final static String LOCATION_STATUS_OPEN = 'Open';
    public final static String LOCATION_STATUS_CLOSED = 'Closed';
    //Desgnated Incharge Role Set
    public final static Set<String> ROLE_INCHARGE_SET = new Set<String>{
        ROLE_DESIGNATED_INCHARGE,
        ROLE_DESIGNATED_INCHARGE_AND_OWNER
    };

    public final static String LOCATION_TYPE_COURSE_ADDRESS = 'Course Address';
    public final static String BLA_AMENDMENT_TYPE_NEW = 'New';
    public final static String BLA_AMENDMENT_TYPE_RENEWAL = 'Renewal';
    public final static String BLA_AMENDMENT_TYPE_APPLY_FOR_COURSE_APPROVAL = 'Apply for Course Approval';
    public final static String BLA_AMENDMENT_TYPE_ANNUAL_TRUST_REPORT = 'Annual Pre-Need Trust Report';
    
    public final static String  IA_AMENDMENT_TYPE_APPLY_FOR_COURSE_APPROVAL_FOR_CE_REQUIREMENTS = 'Apply for Course Approval for CE Requirements';
    public final static String REGULATORY_AUTHORIZATION_TYPE_PHARMACY_INTERN = 'Intern Pharmacist';
    public final static String LICENSE_TYPE_PHARMACIST = 'Pharmacist';
    public final static string Business_License_Status_VOID = 'Void';
    public final static String AMENDMENT_FACILITY_OUT_OF_BA = 'Facility Out of Business application';
    public final static String LOCATION_TYPE_WAREHOUSE_ADDRESS = 'Warehouse Address';
    public final static String LOCATION_TYPE_RECORDS_ADDRESS = 'Records Address';
    public final static String BLA_AMENDMENT_TYPE_COURSE_RENEWAL = 'Course Renewal';
    public final static String REAL_ESTATE_SCHOOL = 'Real Estate School';
    public final static String CERTIFICATION_OF_LICENSURE_INTAKE = 'Certification of Licensure Intake';
    public final static String REQUEST_FOR_CERTIFICATION_OF_LICENSURE = 'Request for certification of licensure';
    public final static String APPLY_CERTIFICATE_OF_MEDICATION = 'Apply Certificate of Medication';
    public final static String CERTIFICATION = 'Certification';
    public final static String MEDICATION_THERAPY_SERVICES = 'Medication Therapy services';
    public final static String CERTIFIED = 'Certified';
    public final static String LOCATION_TYPE_RESIDENCE = 'Residence';
    public final static String LOCATION_TYPE_BUSINESS_ADDRESS = 'Business Address';
    public final static String AMENDMENT_TYPE_Facility_Change_Of_Location_Application = 'Facility change of location application';
    public final static String AMENDMENT_TYPE_ADDRESS = 'Address';
    public final static String METADATA_CLASS_M_SPECIALITY_BLEEDING_DISORDER = 'Class_M_Speciality_Bleeding_Disorder';
    public final static String NON_MO_LICENSE_ACCOUNT_RECORDTYPE = 'Non_MO_License';
    public final static String ROLE_INTERN = 'Intern';
    public final static String ROLE_PRECEPTOR = 'Preceptor';
    public final static String IA_INITIAL_SITE_AND_PRECEPTOR_SUBTYPE = 'Initial Site and Preceptor';
    public final static String IA_CHANGE_OF_SITE_SUBTYPE = 'Change of Site';
    public final static String IA_CHANGE_OF_PRECEPTOR_SUBTYPE = 'Change of Preceptor';
    public final static String IA_AN_ADDITIONAL_PRECEPTOR_SUBTYPE = 'An additional Preceptor';
    public final static String IA_AN_ADDITIONAL_SITE_SUBTYPE = 'An Additional Site';
    public final static String IA_SPECIAL_SITE_AND_NON_PHARMACIST_SUBTYPE = 'Special Site and Non-Pharmacist Preceptor';
    public final static String IA_SPECIAL_SITE_SUBTYPE = 'Special Site';
    public final static String IA_NON_PHAMACIST_PRECEPTOR_SUBTYPE = 'Non-Pharmacist Preceptor';
    public final static String FEE_TYPE_AMENDMENT = 'Amendment';
    public final static String PRENEED_SELLER_LICENSE_TYPE = 'Preneed Seller';
    public final static String PRENEED_PROVIDER_LICENSE_TYPE = 'Preneed Provider';
    public final static string FEE_CHANGE_OF_FICTITIOUS_NAME_OR_TRADE_NAME = 'Facility Fictitious / (Doing Business As) DBA Name change';
    public final static String APPLICATION_FOR_PERMIT = 'Application for Permit';
    public final static String EVENT_INFORMATION = 'Event Information';
    public final static string DENIED_STATUS = 'Denied';
    public final static string VERIFIED_STATUS = 'Verified';
    public final static string MAILING = 'Mailing';
    public final static string CPA_PARTNERSHIP = 'CPA Partnership';
    public final static string CPA_PROF_CORPORATION = 'CPA Prof. Corporation';
    public final static string CPA_SOLE_PROPRIETORSHIP = 'CPA Sole Proprietorship';
    public final static string LIMITED_LIABILITY_COMPANY = 'Limited Liability Company';
    public final static string LIMITED_LIABILITY_PARTNER = 'Limited Liability Partner';
    public final static string ENDOWED_CARE_CEMETERY_LICENSE_TYPE = 'Endowed Care Cemetery';
    public final static string NON_ENDOWED_CARE_CEMETERY_LICENSE_TYPE = 'Non Endowed Care Cemetery';
    public final static string EXPIRY_RULE_TYPE_DAY_MONTH_CYCLE = 'Expiration Day/Month/Cycle';
    public final static string EXPIRY_RULE_TYPE_PERIOD = 'Expiration Period';
    public final static string EXPIRY_RULE_TYPE_NO_EXPIRY = 'No Expiry';

    public final static String ATHLETICS_PLAYER_RECORDTYPE = 'Athletics_Player';
    public final static String INSPECTOR_PREPOPULATION_RECORDTYPE = 'Inspector_Prepopulation';
    public final static String BOXERS_FEDERAL_ID_CARD = 'Boxer\'s Federal ID Card';
    public final static String BOXING_ID_TYPE = 'Boxing';
    public final static String MMA_NATIONAL_ID_CARD = 'MMA National ID Card';
    public final static String MMA_ID_TYPE = 'MMA';
    public final static String IA_BOUT_AGREEMENT_APPLICATIONTYPE = 'Bout Agreement';
    public final static String PRE_BOUT_APPLICATION_TYPE = 'Pre-bout Physical Questionnaire';
    public final static String ANNUAL_EXAM_APPLICATION_TYPE = 'Annual Exam Registration';
    public final static String PAR_SOBJECT_TYPE_ACTIVATION = 'Activation';
    public final static String LICENSE_TYPE_EMBALMER_APPRENTICE = 'Embalmer Apprentice';
    public final static String LICENSE_TYPE_EMBALMER_PRACTICUM = 'Embalmer Practicum';
    public final static Set<String> EMBALMER_INCHARGE_LICENSE_SET = new Set<String>{
        'Embalmer Apprentice',
        'Embalmer Practicum',
        'Funeral Director Apprentice'
    };
    public final static String LICENSE_TYPE_FUNERAL_DIRECTOR_APPRENTICE = 'Funeral Director Apprentice';
    public final static String AMENDMENT_TYPE_ADD_UPDATE_SUPERVISOR_OR_LOCATION = 'Add/Update Supervisor or Location';
    public final static String BLA_INTENT_TO_SELL_ASSETS = 'Intent to Sell Assets';

    public final static String LICENSE_TYPE_EMBALMER = 'Embalmer';
    public final static String LICENSE_TYPE_FUNERAL_DIRECTOR = 'Funeral Director';
    
    public final static String LICENSE_TYPE_FUNERAL_ESTABLISHMENT = 'Funeral Establishment';
    public final static String LICENSE_TYPE_TEMP_PERMIT_BEHIS = 'Temp Permit - BEHIS';
    public final static Set<String> PROMOTER_LICENSE_SET = new Set<String>{
        'Wrestling Promoter',
        'Boxing Promoter',
        'Martial Arts Promoter',
        'Martial Arts Amateur Promoter'
    };
    public static final String PERSON_ACCOUNT_REC_TYPE_ID = Schema.SObjectType.Account
        ?.getRecordTypeInfosByDeveloperName()
        ?.get(ACCOUNT_PERSON_RECORDTYPE)
        ?.getRecordTypeId();
    public static final String BUSINESS_ACCOUNT_REC_TYPE_ID = Schema.SObjectType.Account
        ?.getRecordTypeInfosByDeveloperName()
        ?.get(ACCOUNT_BUSINESS_RECORDTYPE)
        ?.getRecordTypeId();
    public static final String COMPLAINANT_TEXT = 'Complainant';
    public static final String RESPONDENT_TEXT = 'Respondent';
    public static final String WITNESS_TEXT = 'Witness';
    public static final String LOCATION_SOBJECT_NAME = 'Location';
    public static final String LICENSED_TYPE = 'Complaint against a Licensed Individual/Facility';
    public static final List<String> ADDRESS_TYPE_LIST = new List<String>{
        'Business Address',
        'Residence'
    };
    public static final String ACTIVE_TEXT = 'Active';
    public static final Map<String, String> AUTH_TYPE_TO_ADDRESS_TYPE_MAP = new Map<String, String>{
        'Business' => 'Business Address',
        'Individual' => 'Residence'
    };
    public static final String LICENSE_CONTENT_EVENT_PERMIT_RECORD_TYPE = Schema.getGlobalDescribe()
        .get('License_Content__c')
        .getDescribe()
        .getRecordTypeInfosByDeveloperName()
        .get('Event_Permit')
        .getRecordTypeId();
    public static final String LICENSE_TYPE_NAME_ARCHITECT = 'Architect';
    public static final String LICENSE_TYPE_NAME_PROFESSIONAL_LAND_SURVEYOR = 'Professional Land Surveyor';
    public static final String LICENSE_TYPE_NAME_PROFESSIONAL_ENGINEER = 'Professional Engineer';
    public static final String LICENSE_TYPE_NAME_PROFESSIONAL_LANDSCAPE_ARCHITECT = 'Professional Landscape Architect';
    public final static String DELIVERY_METHOD_OTHER = 'Other';
    public final static String FEE_APPROVED_STATUS = 'Approved';
    public final static String FEE_PAID_STATUS = 'Paid';
    public final static String FEE_FAILED_STATUS = 'Failed';
    public final static String FEE_CANCEL_STATUS = 'Canceled';
    public final static string CHANGE_OF_INDIVIDUAL_BUSINESS_ADDRESS = 'Change of Individual Business Address';
    public final static string ALL_APPLICATIONS = 'All Applications';
    public final static string AUDIT_ESCROW_OR_TRUST_ACCOUNT_QUESTIONS = 'Audit_Escrow_or_Trust_Account_Questions__c';
    public final static string FETCH_RECORDS = 'fetchRecords';
    public final static string GET_VIEW_APPLICATION_QUESTIONS = 'getViewApplicationQuestions';
    public final static string GET_PAR_ID = 'getPARId';
    public final static string VIEW_MILITARY_QUESTIONS_DETAILS = 'viewMilitaryQuestionDetails';
    public final static string GET_TAX_COMPLIANCE_DETAILS = 'getTaxComplianceDetails';
    public final static string GET_EXAMINATION_INFORMATION_DETAILS = 'getExaminationInformationDetails';
    public final static string GET_AUDIT_ESCROW_QUESTIONS = 'getAuditEscrowQuestions';
    public final static string PAR_ID = 'parId';
    public final static string REC_ID = 'recid';
    public final static string LICENSE_QUESTIONS = 'License_Questions__c';
    public final static string TAX_COMPLIANCE = 'Tax_Compliance__c';
    public final static string SPECIAL_ACCOMODATION = 'Special_Accomodation__c';
    public final static string USER_REC_ID = 'userrecid';
    public final static string STATUS = 'status';
    public final static string LIMIT_WORD = 'limit';
    public final static string LQ_ECC_APP_REINS_FINALDISPOSITIONS = 'ECCAppReinsFinalDispositions';
    public final static String NEW_INTAKE_APPLICATION = 'New intake application';
    public final static String INPUT = 'input';
    public final static String OUTPUT = 'output';
    public final static String OPTIONS = 'options';
    public final static string CEMETERY_ANNUAL_ENDOWED_CARE_TRUST_FUND_REPORT = 'Cemetery Annual Endowed care Trust Fund Report';
    public final static string FINANCIAL_DETAILS = 'Financial Details';
    public final static string PAYMENT_TYPE = 'Payment';
    public final static string PENDING_STATUS = 'Pending';
    public final static string DECLINED_STATUS = 'Declined';
    public final static string ACR_APPROVED_STATUS = 'Approved';
    public final static string INSPECTION_TEXT = 'Inspection';
    public final static List<String> BUSINESS_LICENSE_INSPECTION_TYPES_LIST_TO_CHECK = new List<String>{
        Inspection_Type_COMPLAINT,
        Inspection_Type_ROUTINE,
        Inspection_Type_PRELIMINARY
    };
    public final static string PUBLIC_COMPLAINT_API_NAME = 'PublicComplaint';
    public final static string INDUSTRIES_TEXT = 'Industries';
    public final static string MEDIUM_TEXT = 'Medium';
    public final static String LOCATION_TYPE_MAILING = 'Mailing';
    public final static string RECORD_ID_IS_BLANK = 'record Id is Blank';
    public final static string NULL_VALUES = 'Null Values';
    public final static string DUPLICATE_NAME = 'Duplicate Name';
    public final static string SUCCESS = 'success';
    public final static string DOCUMENT_REQUIRED = 'Required';
    public final static string DOCUMENT_OPTIONAL = 'Optional';
    public final static String LATE_REINSTATEMENT = 'Late Reinstatement';
    public final static String CLASSIFICATION_TYPE_RECIPROCITY = 'Reciprocity';
    public final static Set<String> LOCATION_TYPE_SET = new Set<String>{LPI_LiteralConstant.LOCATION_TYPE_RESIDENCE,LPI_LiteralConstant.LOCATION_TYPE_BUSINESS_ADDRESS};
    public final static String COURSE_STATUS_EXPIRED = 'Expired';
    public final static String PERSONAL_INFO_STEPNAME_OS = 'PersonalInformation';
    public final static String BANK_ACCOUNT_STATUS_OPEN = 'Open';
    public final static String BANK_ACCOUNT_STATUS_CLOSED = 'Closed';
    public final static String APPLICATION_WITH_SPACE = ' Application';
    public final static String DEFAULT_TEXT = 'Default';
    public final static String IA_APPLICATION_ERROR_TEXT = 'Couldn\'t Fetch Individual Application Record';
    public final static String REQ_PARAMS_MISSING_ERROR_TEXT = 'Required Parameter is Missing or In-valid';
    public final static String BLA_APPLICATION_ERROR_TEXT = 'Couldn\'t Fetch Business License Application Record';
    public final static Integer SUCCESS_STATUS_CODE = 200;
    public final static String HEADER_CONTENT_TYPE = 'application/json;charset=UTF-8';
    public final static String PAYMENT_CONFIG_DEVELOPERNAME = 'JetPay';
    public final static String SHA_HASHING_ALGO = 'hmacSHA512';
    public final static String US_COUNTRY_CODE = 'US' ;
    public static final List<String> PROFILE_NAME_SET = new List<String>{
        'System Administrator',
        'MODPR Integration User'
    };
    public final static String Healing_Arts_RecordType = 'Healing Arts';
    public final static String APPLICATION_REFERENCE = 'Application Reference';
    public final static String PODIATRIST_BOARD_TEXT = 'Podiatrist';
    public final static String PODIATRIST_ANKLE_BOARD_TEXT = 'Podiatrist/Ankle';
    public final static string REG_AUTH_TYPE_SOBJECT_NAME = 'RegulatoryAuthorizationType';
    public final static string REG_AUTH_SOBJECT_NAME = 'RegulatoryAuthority';
    public final static List<String> SOBJECT_TYPE_LIST_FOR_WEBPULL = new List<String>{
        REG_AUTH_TYPE_SOBJECT_NAME,REG_AUTH_SOBJECT_NAME
    };
    public final static string FILE_NAME_DELIMINITER = '---fileName';
    public final static String PHYSICIAN_LIMITED_WITH_MISSOURI_LICENSE = 'Physician Limited with Current Missouri License';
    public final static String BL_STATUS_RETIRED = 'Retired';
    public final static String CHANGE_OF_NAME_RESIDENCE_ADDRESS = 'Change of Name/Residence Address';
    public final static String IA_PHYSICIAN_ASSISTANT_LICENSE = 'Physician Assistant';
    public final static String IA_ASSISTANT_PHYSICIAN_LICENSE = 'Assistant Physician';
    public final static String IA_CONTROLLED_SUBSTANCE_RX_AUTHORITY = 'Certificate of Controlled Substance Prescriptive Authority';
    public final static String CERTIFICATE_SPECIALIZATION = 'Specialization';
    public final static String CERTIFICATE_PRIMARY = 'Primary';
    public final static String CERTIFICATE_CONTROLLED_SUBSTANCE_RX_AUTHORITY = 'Controlled Substance Rx Authority';
    public final static String POSTGRADUATION_TRAINING_EDUCATION_TYPE = 'Postgraduation Training';
    public final static String POSTGRADUATION_DETAILS_EDUCATION_TYPE = 'Postgraduation Details';
    public final static String HIGHER_EDUCATION_TYPE = 'Higher Education';
    public final static String DENTAL_HYGIENIST_LICENSE_TYPE = 'Dental Hygienist';
    public final static String FEE_TYPE_DENTAL_HYGIENIST_PERMIT = 'Application for Permit - Dental Hygienists';
    public final static String MetaData_Application_Submission_Email = 'Application_Submission_Email';
    public final static String LICENSE_TYPE_APRN = 'Advanced Practice Registered Nurse';
    public final static String LICENSE_TYPE_PROFESSIONAL_COUNSELOR = 'Professional Counselor';
    public final static String STATUS_ELIGIBLE = 'Eligible';
    public final static String IA_LICENSED_PRACTICAL_NURSE = 'Licensed Practical Nurse';
    public final static String IA_REGISTERED_NURSE = 'Registered Nurse';
    public final static Set<String> NURSING_CURR_EMP_SET = new Set<String>{
        IA_LICENSED_PRACTICAL_NURSE,
        IA_REGISTERED_NURSE, LICENSE_TYPE_APRN
    };
    public final static String LICENSE_TYPE_LPN = 'Licensed Practical Nurse';
    public final static String LPN_IV_CERTIFIED = 'IV Certified';
    public final static String LPN_PRACTICAL_NURSING = 'Practical Nursing';
    public final static String IA_LICENSED_PRACTICAL_NURSE_TEMP = 'Licensed Practical Nurse Temp';
    public final static String IA_REGISTERED_NURSE_TEMP = 'Registered Nurse Temp';
    public final static String LPI_YES='Yes';
    public final static String MODPR_YES='Yes';
    public final static String LPI_NO='No';
    public final static String MODPR_NO='No';
    public final static String LICENSE_TYPE_NURSING = 'Nursing';
    public final static String ACCOUNTANCY_LICENSE_TYPE_NAME = 'Certified Public Accountant(CPA)';
    public final static String LPI_PASS = 'Pass';
    public final static String ANNUAL_REPORT_SURVEY = 'Annual Report Survey'; 
    public final static String DENTAL_BOARD_NAME = 'Dental'; 
    public final static String DUPLICATE_LICENSE_RQUEST_TYPE = 'Request for Duplicate License';  
    public final static String NO_VIOLATION = 'No Violation';
    public final static String LPI_PORTAL_LINK = 'https://lpi-psf-core--widpi.sandbox.my.site.com/s/';
    public final static string CHANNEL_OFFLINE = 'Offline';
    public final static String EMAIL_NOTIFICATION_RECORDTYPE_DEV_NAME = 'Email_Notification';
    public final static String PORTAL_NOTIFICATION_RECORDTYPE_DEV_NAME = 'Portal_Notification';
    public final static String BELL_NOTIFICATION_RECORDTYPE_DEV_NAME = 'Bell_Notification';
    public final static String MOBILE_NOTIFICATION_RECORDTYPE_DEV_NAME = 'Mobile_Notification';
    public final static Set<String> PORTAL_NOTIFICATION_RECORDTYPE_DEV_NAME_SET = new Set<String>{
        PORTAL_NOTIFICATION_RECORDTYPE_DEV_NAME,
        BELL_NOTIFICATION_RECORDTYPE_DEV_NAME, 
        MOBILE_NOTIFICATION_RECORDTYPE_DEV_NAME
    };
    public static final String PORTAL_NOTIFICATION_RECORDTYPE_ID = Schema.SObjectType.Notification__c
        ?.getRecordTypeInfosByDeveloperName()
        ?.get(PORTAL_NOTIFICATION_RECORDTYPE_DEV_NAME)
        ?.getRecordTypeId();
}