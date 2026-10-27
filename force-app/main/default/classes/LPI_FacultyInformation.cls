/**
 * @author          : Saurabh singh
 * @description     : This class fetch and Save all the Details of Faculty Information Details
 * * @history
 * Vamsi Mudaliar : Modified ACR Object with Business_Relationships__c object mappings.
 * -------------------------------------------------------------------------------------------------------
 * Version      Date                Author                  Details
 *    1         14 Mar, 2023        Saurabh Singh         Initial Developement
 * -------------------------------------------------------------------------------------------------------
 */
global with sharing class LPI_FacultyInformation 
//implements Callable 
{
	public void m1(){}
// 	public final static String FETCH_FACULTY_INFORMATION_DETAILS = 'fetchFacultyInformationDetails';
// 	public final static String LICENSE_DETAILS = 'licenseDetails';
// 	public final static String CLASS_NAME = 'LPI_FacultyInformation';
// 	public final static String LICENSE_NUMBER = 'licenseNumber';
// 	public final static String REGISTERED_NURSE = 'Registered Nurse';
// 	public final static String SAVE_FACULTY_INFORMATION_DETAILS = 'saveFacultyInformationDetails';
// 	public final static String FETCH_FACULTY_INFORMATION = 'fetchFacultyInformation';
// 	public final static String DELETE_FACULTY_INFORMATION = 'deleteFacultyInformation';
// 	public final static String ACTIVE = 'Active';
// 	public final static String PAR_ID = 'parId';
// 	public final static String ROLES = 'Roles';
// 	public final static String UPSERT_ACCOUNT_CONTACT_RELATION = 'upsertAccountContactRelation';
// 	private static final String PAR_NOT_FOUND = 'PAR record is not created for the flow';
// 	public final static String CANNOT_DELETE_ACTIVE_ACR = 'You can not delete active relationship without approval ,If you want to deactivate relationship edit the record and uncheck the checkbox';
// 	public final static String ACR_ALREADY_EXIST = 'Faculty is already linked with this Organization';
// 	public final static String SAVE_FACULTY_INFORMATION = 'saveFacultyInformationIds';
// 	public final static String FETCH_LICENSE_QUESTIONS = 'fetchLicenseQuestionsForNursingSchool';
// 	public final static String TYPE = 'type';
// 	public final static String LICENSE_NAME = 'LicenseName';
// 	public final static String PRACTICAL_NURSING_PROGRAM = 'Practical Nursing Program';
// 	public final static String ASSOCIATE_DEGREE_NURSING_PROGRAM = 'Associate Degree Nursing Program';
// 	public final static String BACCALAUREATE_DEGREE_NURSING_PROGRAM = 'Baccalaureate Degree Nursing Program';
// 	public final static String LPN_FACULTY_ELIGIBLE = 'LPN Faculty Eligible';
// 	public final static String ADN_FACULTY_ELIGIBLE = 'ADN Faculty Eligible';
// 	public final static String BSN_FACULTY_ELIGIBLE = 'BSN Faculty Eligible';
// 	public final static String LPN_FACULTY_ELIGIBLE_LIST = '(\'' + LPN_FACULTY_ELIGIBLE + '\'' + ')';
// 	public final static String ADN_FACULTY_ELIGIBLE_LIST = '(\'' + ADN_FACULTY_ELIGIBLE + '\'' + ')';
// 	public final static String BSN_FACULTY_ELIGIBLE_LIST = '(\'' + BSN_FACULTY_ELIGIBLE + '\'' + ')';
// 	public final static String FETCH_PD_LICENSE = 'fetchPDLicense';
// 	public final static String DO_NOT_HAVE_ACCESS =  'You do not have access to perform this operation';
// 	public final static String GET_NUR_SCHOOL_ADMIN_DETAILS = 'getNurSchoolAdministratorDetails';
// 	public final static Set<String> NUR_ADMIN_RENEWAL_ROUTINE_TYPES = new Set<String>{
// 		'Renewal','Routine Survey','Change in Sponsorship'};
// 	public final static String IV_THERAPY_COURSE_LICENSE = 'IV Therapy Course';
// 	public final static String NURSING_RAT = 'Nursing';
// 	public final static String INDIVIDAULICENSE_APPTYPE = 'Individual';

// 	// ******************************************************************************************************

// 	global Object call(String action, Map<String, Object> args) {
// 		Map<String, Object> input = (Map<String, Object>) args.get('input');
// 		Map<String, Object> output = (Map<String, Object>) args.get('output');
// 		Map<String, Object> options = (Map<String, Object>) args.get('options');
// 		return invokeMethod(action, input, output, options);
// 	}

// 	/**
// 	 * @author               : Saurabh Singh
// 	 * @param methodName     : Method Name
// 	 * @param inputMap       : Input Parameter Passed from Omniscript
// 	 * @param outMap         : Output Passed to Omniscript
// 	 * @param options        : Extra Options passed from Omniscript
// 	 * @last modified by     : MTX Group Inc
// 	 * @last modified date   : 16 Jan, 2023
// 	 * @modified details     : Optimized Code
// 	 * @return  `Boolean`
// 	 */
// 	private Boolean invokeMethod(
// 		String methodName,
// 		Map<String, Object> inputMap,
// 		Map<String, Object> outMap,
// 		Map<String, Object> options
// 	) {
// 		if (methodName == FETCH_FACULTY_INFORMATION_DETAILS) {
// 			outMap.put(LICENSE_DETAILS, fetchFacultyInformationDetails(inputMap, outMap, options));
// 		} else if (methodName == SAVE_FACULTY_INFORMATION_DETAILS) {
// 			saveFacultyInformationDetails(inputMap, outMap, options);
// 		} else if (methodName == FETCH_FACULTY_INFORMATION) {
// 			fetchFacultyInformation(inputMap, outMap, options);
// 		} else if (methodName == DELETE_FACULTY_INFORMATION) {
// 			deleteFacultyInformation(inputMap, outMap,options);
// 		} else if (methodName == SAVE_FACULTY_INFORMATION) {
// 			saveFacultyInformationIds(inputMap, outMap);
// 		} else if (methodName == FETCH_LICENSE_QUESTIONS) {
// 			fetchLicenseQuestionsForNursingSchool(inputMap,outMap);
// 		}
// 		else if (methodName.equalsIgnoreCase(FETCH_PD_LICENSE)) {
// 			outMap.put('pdLicenseRecords', fetchPDLicense(inputMap,options));
// 		} else if (methodName.equalsIgnoreCase(GET_NUR_SCHOOL_ADMIN_DETAILS)) {
// 			getNurSchoolAdministratorDetails(inputMap,outMap);
// 		}

// 		return true;
// 	}

// 	/**
// 	 * @author          	: Saurabh singh
// 	 * @param inputMap  	: Input value passed from OS
// 	 * @param outMap    	: Output value passed from here to OS
// 	 * @param options   	: Options value passed from OS
// 	 * @description     	: This Method Will fetch Business License Number on the basis of registered nurse
// 	 * @last modified by    : MTX Group Inc
// 	 * @last modified date  :
// 	 * @modified details    :
// 	 */
// 	private static List<Map<String, object>> fetchFacultyInformationDetails(
// 		Map<String, Object> inputMap,
// 		Map<String, Object> outMap,
// 		Map<String, Object> options
// 	) {
// 		List<Map<String, Object>> licenseList;
// 		try {
// 			licenseList = new List<Map<String, Object>>();
// 			String licenseNumber = '%' + (String) options.get(String.escapeSingleQuotes(LICENSE_NUMBER)) + '%';
// 			String licenseName = (String) options.get(String.escapeSingleQuotes(LICENSE_NAME));
// 			String fieldsToQuery = 'ID,Name,First_Name__c,Last_Name__c,Middle_Name__c,RegulatoryAuthorizationType.Name,ContactId,Contact.Account.Date_of_Birth__c,License_Number_With_Rat_Name__c';
// 			String whereClause =
// 				'Name LIKE ' +
// 				'\'' +
// 				String.escapeSingleQuotes(licenseNumber) +
// 				'\'' +
// 				' AND Status = \'' +
// 				ACTIVE +
// 				'\'' +
// 				' AND ContactId!=null';

// 			if(licenseName != IV_THERAPY_COURSE_LICENSE){
// 				whereClause += ' AND RegulatoryAuthorizationType.Name = \'' + String.escapeSingleQuotes(REGISTERED_NURSE) + '\'';
// 				// If license Name is practical Nursing program check for LPN faculty Eligible (level of faculty Approval)
// 				if (licenseName == PRACTICAL_NURSING_PROGRAM) {
// 					whereClause += ' AND Level_of_Faculty_Approval__c INCLUDES' + LPN_FACULTY_ELIGIBLE_LIST;
// 				} // If license Name is Associate Degree Nursing program check for ADN faculty Eligible (level of faculty Approval )
// 				else if (licenseName == ASSOCIATE_DEGREE_NURSING_PROGRAM) {
// 					whereClause += ' AND Level_of_Faculty_Approval__c INCLUDES' + ADN_FACULTY_ELIGIBLE_LIST;
// 				} // If license Name is Baccalaureate Nursing program check for BSN faculty Eligible (level of faculty Approval )
// 				else if (licenseName == BACCALAUREATE_DEGREE_NURSING_PROGRAM) {
// 					whereClause += ' AND Level_of_Faculty_Approval__c INCLUDES' + BSN_FACULTY_ELIGIBLE_LIST;
// 				} 
// 		    }// If license Name is IV Therapy Course search Nursing Licenses
// 			else if(licenseName == IV_THERAPY_COURSE_LICENSE){
// 				whereClause += ' AND RegulatoryAuthorizationType.IssuingDepartment.Name = \'' + NURSING_RAT + '\''+
// 				               ' AND RegulatoryAuthorizationType.Authorisation_Type__c= \'' + INDIVIDAULICENSE_APPTYPE + '\'' ;
// 			}

// 			// This for loop will return all the Business license and there details where license number like whatever user enter
// 			// Account records are not getting fetched due to OWD private
// 			LPI_BusinessLicenseDAO.LPI_BusinessLicenseWithoutSharingDAO businessLicense = new LPI_BusinessLicenseDAO.LPI_BusinessLicenseWithoutSharingDAO();
// 			for (
// 				BusinessLicense bl : businessLicense.getBusinessLicenseByDymanicQuery(
// 					fieldsToQuery,
// 					whereClause,
// 					'100',
// 					null,
// 					null
// 				)
// 			) {
// 				// creating map to store all the details of business license
// 				Map<String, String> licenseMap = new Map<String, String>();
// 				licenseMap.put('Name', bl.Name);
// 				licenseMap.put('LicenseName', bl.Name);
// 				licenseMap.put('TypeAheadKey', bl.License_Number_With_Rat_Name__c);
// 				licenseMap.put('FirstName', bl.First_Name__c);
// 				licenseMap.put('MiddleName', bl.Middle_Name__c);
// 				licenseMap.put('LastName', bl.Last_Name__c);
// 				licenseMap.put('DateOfBirth', String.valueOf(bl.Contact.Account.Date_of_Birth__c));
// 				licenseMap.put('LicenseTypes', bl.RegulatoryAuthorizationType.Name);
// 				licenseMap.put('setContactId', bl.ContactId);
// 				licenseMap.put('blId', bl.Id);
// 				licenseList.add(licenseMap);
// 			}
// 		} catch (Exception e) {
// 			LPI_ExceptionManager.logException(CLASS_NAME, FETCH_FACULTY_INFORMATION_DETAILS, e);
// 			throw new LPI_Exception('Problem in Fetching the deails', e);
// 		}
// 		return licenseList;
// 	}

// 	/**
// 	 * @author              : Saurabh singh
// 	 * @param inputMap      : Input value passed from OS
// 	 * @param outMap        : Output value passed from here to OS
// 	 * @param options       : Options value passed from here to OS
// 	 * @description         : This method will save the detail of Newly added Employee Information
// 	 * @last modified by    : MTX Group Inc
// 	 * @last modified date  :
// 	 * @modified details    :
// 	 */
// 	private static void saveFacultyInformationDetails(
// 		Map<String, Object> inputMap,
// 		Map<String, Object> outMap,
// 		Map<String, Object> options
// 	) {
// 		try {
// 			String parId = (String) options.get(String.escapeSingleQuotes(PAR_ID));
// 			String roles = (String) options.get(String.escapeSingleQuotes(ROLES));
// 			String type = (String) options.get(String.escapeSingleQuotes(TYPE));
// 			Boolean activelyAssociated = (Boolean)(inputMap.get('FacultyActivelyAssociated')!=null?inputMap.get('FacultyActivelyAssociated'):true);

// 			String personContactId;
// 			// Data entered by user This is The ACR Id
// 			// String recordId = (String) inputMap.get('Id');
// 			Id recordId = String.isNotBlank((String)inputMap.get('Id')) ? (Id) inputMap.get('Id') : null;
// 			outMap.put('businessRelId',recordId);
// 			Map<String, Object> completeBlock = (Map<String, Object>) inputMap.get(
// 				String.escapeSingleQuotes('LicenseNumber-Block')
// 			);

// 			String employmentDate = null;
// 			String contactId = null;
// 			String businessLicesneId = null;
// 			String licenseNumberToDisplay = null;//for I-277962
// 			if(completeBlock!=null) {
// 				employmentDate = (String) completeBlock.get('EmploymentDate');
// 				contactId = (String) completeBlock.get('setContactId');
// 				businessLicesneId = (String) completeBlock.get('blId');
// 				licenseNumberToDisplay = (String) completeBlock.get('LicenseNumber');//for I-277962
// 				outMap.put('ContactId', businessLicesneId);
// 				outMap.put('licenseNumberUI', licenseNumberToDisplay); //for I-277962
// 			} else {
// 				completeBlock = new Map<String,Object>();
// 			}
// 			// Fetching Business License Name
// 			List<BusinessLicense> businessLicenseList;
// 			if (String.isNotBlank(businessLicesneId)) {
// 				businessLicenseList = LPI_BusinessLicenseDAO.fetchBusinessLicenseRecords(
// 					'Id,Name,License_Number_With_Rat_Name__c',
// 					'Id =\'' + businessLicesneId + '\''
// 				);
// 			}
// 			if (String.isNotBlank(recordId)) {
// 				personContactId = (String) inputMap.get('ContactId');
// 			} else {
// 				personContactId = (String) completeBlock.get('setContactId');
// 			}
// 			//System.assert(false, 'parId '+parId+' roles '+roles+' personContactId '+personContactId);
// 			// if any variable is coming as null then throughing exception
// 			if (String.isBlank(parId) || String.isBlank(roles) || String.isBlank(personContactId)) {
// 				LPI_ExceptionManager.logException(
// 					CLASS_NAME,
// 					SAVE_FACULTY_INFORMATION_DETAILS,
// 					PAR_NOT_FOUND,
// 					PAR_NOT_FOUND,
// 					null,
// 					null
// 				);
// 				return;
// 			}
// 			// Fecting Account Id on then basis of personContactId
// 			LPI_AccountDAO.LPI_AccountWithoutSharingDAO withoutSharingAcc = new LPI_AccountDAO.LPI_AccountWithoutSharingDAO();
// 			List<Account> personAccountList = withoutSharingAcc.getAccountByDymanicQuery(
// 				'Id,Name',
// 				'PersonContactId =\'' + String.escapeSingleQuotes(personContactId) + '\'',
// 				null,
// 				null,
// 				null
// 			);
// 			if (personAccountList.isEmpty()) {
// 				LPI_ExceptionManager.logException(
// 					CLASS_NAME,
// 					SAVE_FACULTY_INFORMATION_DETAILS,
// 					'Problem in fetching the Name',
// 					'Problem in fetching the Name',
// 					null,
// 					null
// 				);
// 				return;
// 			}
// 			Id relatedToAccId = personAccountList[0]?.Id;
// 			Id businessAccountId;
// 			String licenseToPopulate = null;
// 			String licenseNameToPopulate = null;

// 			// Fetching Business Account From PAR
// 			List<PreliminaryApplicationRef> par;
// 			if (String.isNotBlank(parId)) {
// 				// Fetching the fields from PAR ID
// 				par = LPI_PreliminaryApplicationRefDAO.getPreliminaryApplicationRefByDymanicQuery(
// 					'BusinessAccountNameId , BusinessAccountName.Name ,BusinessAccountName.BillingCity,BusinessAccountName.BillingCountry,BusinessAccountName.BillingPostalCode,BusinessAccountName.BillingStreet,BusinessAccountName.Other_State__c,BusinessAccountName.BillingState,Business_License__c',
// 					'Id = \'' + String.escapeSingleQuotes(parId) + '\'',
// 					null,
// 					null,
// 					null
// 				);
// 				if (!par.isEmpty()) {
// 					businessAccountId = par[0].BusinessAccountNameId;
// 					licenseToPopulate = par[0].Business_License__c;
// 				}

// 				// Query BusinessLicense Record to Get its Name.
// 				if(licenseToPopulate!=null) {
// 					LPI_BusinessLicenseDAO.LPI_BusinessLicenseWithoutSharingDAO bLListWithOutSharing = new LPI_BusinessLicenseDAO.LPI_BusinessLicenseWithoutSharingDAO();
                    
// 					List<BusinessLicense> blList = bLListWithOutSharing.getBusinessLicenseByDymanicQuery(
// 						'Id,Name',
// 						'Id =\'' + String.escapeSingleQuotes(licenseToPopulate) + '\'',
// 						'1',null,null
// 					);
// 					licenseNameToPopulate = blList[0]?.Name;
// 				}

// 				// Checking ACR Already Exists then Show user Message
// 				if (businessAccountId != null && relatedToAccId != null) {
// 					List<Business_Relationships__c> accountContactRelationExist = queryAccountContactRelation(
// 						relatedToAccId,
// 						businessAccountId,
// 						roles
// 					);
// 					if (!accountContactRelationExist.isEmpty() && String.isBlank(recordId)) {
// 						throw new LPI_Exception(ACR_ALREADY_EXIST);
// 					}
// 					else if(!accountContactRelationExist.isEmpty() && completeBlock.isEmpty()) {
// 						completeBlock.put('LicenseName',accountContactRelationExist[0]?.License_Number__c);
// 						completeBlock.put('LicenseTypes',accountContactRelationExist[0]?.License_Type__c);
// 						completeBlock.put('ACRActive',accountContactRelationExist[0]?.IsActive__c);
// 						employmentDate = String.valueOf(accountContactRelationExist[0]?.Start_Date__c);
// 						String selectedEmpHistoryId = (String) inputMap.get('EmploymentHistoryId');

// 						List<PersonEmployment> empHistoryRecList = LPI_PersonEmploymentDAO.getEmploymentHistoryByDymanicQuery('Id,Position,Type_of_Employment__c','Id = \''+String.escapeSingleQuotes(selectedEmpHistoryId)+'\'',null,null,null);

// 						if(!empHistoryRecList.isEmpty()) {
// 							completeBlock.put('TitleOfPosition',empHistoryRecList[0]?.Position);
// 							completeBlock.put('TypeOfEmployment',empHistoryRecList[0]?.Type_of_Employment__c);
// 						}
// 					}
// 				}

// 				// Field Mapping of Employment History
// 				Map<String, String> fieldMappingOfEmploymentHistory = new Map<String, String>{
// 					'TitleOfPosition' => 'Position',
// 					'TypeOfEmployment' => 'Type_of_Employment__c',
// 					'TeachingCourses' => 'Name_of_Courses_Teaching__c',
// 					'NursingLicenseEverDisciplined' => 'Nursing_license_ever_been_disciplined__c'
// 				};

// 				if (type.equals('Amendment')) {
// 					fieldMappingOfEmploymentHistory.putAll(
// 						new Map<String, String>{
// 							'NewPosition' => 'New_Position__c',
// 							'ReplaceExistingFaculty' => 'Replacing_an_existing_faculty__c',
// 							'SpecifyNameofReplacedFaculty' => 'Specify_Name_of_Replaced_Faculty__c',
// 							'EndDateOfAssociation' => 'End_Date_of_Association__c'
// 						}
// 					);
// 				}
// 				PersonEmployment employmentHistory = null;
// 					// Instance of Employment history and link it with business Account
// 					employmentHistory = (PersonEmployment) LPI_VlocityUtility.createSObject(
// 						completeBlock,
// 						fieldMappingOfEmploymentHistory,
// 						'PersonEmployment'
// 					);
// 					employmentHistory.put('RelatedPersonId', personAccountList[0].Id);
// 					if (String.isNotBlank(businessLicesneId)) {
// 						employmentHistory.put('Business_License__c', businessLicesneId);
// 					}
// 					employmentHistory.put('Name', par[0].BusinessAccountName.Name);
// 					employmentHistory.put('EmployerStreet', par[0].BusinessAccountName.BillingStreet);
// 					employmentHistory.put('EmployerCity', par[0].BusinessAccountName.BillingCity);
// 					if (par[0].BusinessAccountName.BillingState != null) {
// 						employmentHistory.put('EmployerState', par[0].BusinessAccountName.BillingState);
// 					} else {
// 						employmentHistory.put('EmployerState', par[0].BusinessAccountName.Other_State__c);
// 					}

// 					employmentHistory.put('EmployerCountry', par[0].BusinessAccountName.BillingCountry);
// 					employmentHistory.put('EmployerPostalCode', par[0].BusinessAccountName.BillingPostalCode);

// 					if (String.isNotBlank(employmentDate)) {
// 						employmentHistory.put('StartDate', date.valueOf(employmentDate));
// 					}
// 					if(String.isNotBlank(licenseNameToPopulate)) {
// 						employmentHistory.put('Employer_License_Number__c', licenseNameToPopulate);
// 					}
// 					string employmentHistoryId = (String) inputMap.get('EmploymentHistoryId');
// 					if (String.isNotBlank(employmentHistoryId)) {
// 						employmentHistory.put('Id', employmentHistoryId);
// 					}
// 					// user do not have access of Account and Employment History created by support staff
// 					employmentHistory = (PersonEmployment) LPI_WithoutSharingUtility.upsertSObject(
// 						employmentHistory
// 					);
// 					outMap.put('EmploymentHistoryId', employmentHistory.id);

// 				// Upserting ACR
// 				Business_Relationships__c insertAccConRelation;
// 				if (String.isBlank(recordId)) {
// 					insertAccConRelation = upsertAccountContactRelation(
// 						null,
// 						relatedToAccId,
// 						businessAccountId,
// 						roles,
// 						completeBlock,
// 						activelyAssociated,
// 						employmentDate
// 					);
// 				} else {
// 					// Deleting ACR and again creating new ACR because we cannot Update ACR once its created.
// 					// Business_Relationships__c accConRelation = new Business_Relationships__c(Id = recordId);
// 					// LPI_WithoutSharingUtility.deleteSObject(accConRelation);

// 					// List<Business_Relationships__c> accountContactRelationExist = queryAccountContactRelation(
// 					// 	relatedToAccId,
// 					// 	businessAccountId,
// 					// 	roles
// 					// );
// 					// if (!accountContactRelationExist.isEmpty()) {
// 					// 	throw new LPI_Exception(ACR_ALREADY_EXIST);
// 					// }

// 					insertAccConRelation = upsertAccountContactRelation(
// 						recordId,
// 						relatedToAccId,
// 						businessAccountId,
// 						roles,
// 						completeBlock,
// 						activelyAssociated,
// 						employmentDate
// 					);
// 				}
// 				outMap.put('Id', insertAccConRelation.id);
// 				outMap.put('Name', personAccountList[0].Name);
// 				List<String> acrIdList = new List<String>();
// 				List<String> empHistoryList = new List<String>();
// 				// Query PAR record.
// 				String fields = 'Id,Employee_Information_ACR_Ids__c,Amendment_Type__c';
//                 String whereClause = 'Id = \''+String.escapeSingleQuotes(parId)+'\'';

//                 List<PreliminaryApplicationRef> parList = LPI_PreliminaryApplicationRefDAO.getPreliminaryApplicationRefByDymanicQuery(
//                     										fields,whereClause,'1',
//                     										null,null
//                 										);
				
// 				if(String.isNotBlank(parList[0]?.Employee_Information_ACR_Ids__c)) {
// 					empHistoryList = parList[0]?.Employee_Information_ACR_Ids__c?.split(',');
// 				}
// 				if(!acrIdList.contains(insertAccConRelation.id)) {
// 					acrIdList.add(insertAccConRelation.id);
// 				}
// 				if(!empHistoryList.contains(employmentHistory.id)) {
// 					empHistoryList.add(employmentHistory.id);
// 				}
// 				// update PAR Record.
// 				LPI_DML.doUpdate(new PreliminaryApplicationRef(
// 					Id = parId,
// 					//Registered_Agent_Relation_Id__c = String.join(acrIdList,','),
// 					Employee_Information_ACR_Ids__c = String.join(empHistoryList,',')
// 				));

// 				if(employmentHistory!=null) {
// 					outMap.put('TitleOfPositionUI', employmentHistory.Position);
// 					outMap.put('TypeOfEmploymentUI', employmentHistory.Type_of_Employment__c);
// 				}
// 				if (businessLicenseList!=null && !businessLicenseList.isEmpty()) {
// 					outMap.put('licenseNumberUI', businessLicenseList[0].License_Number_With_Rat_Name__c);
// 				}
// 			}
// 		} catch (Exception e) {
// 			if (e.getMessage() == ACR_ALREADY_EXIST) {
// 				throw new LPI_Exception(ACR_ALREADY_EXIST, e);
// 			}
// 			LPI_ExceptionManager.logException(CLASS_NAME, SAVE_FACULTY_INFORMATION_DETAILS, e);
// 			throw new LPI_Exception('Problem in saving the the Faculty Information details', e);
// 		}
// 	}

// 	/**
// 	 * @author              : Saurabh singh
// 	 * @param inputMap      : Input value passed from OS
// 	 * @param outMap        : Output value passed from here to OS
// 	 * @param options       : Options value passed from here to OS
// 	 * @description         : Fetching Faculty information once page reload by user or in Review page
// 	 * @last modified by    : MTX Group Inc
// 	 * @last modified date  :
// 	 * @modified details    :
// 	 */
// 	public static List<Map<String, Object>> fetchFacultyInformation(
// 		Map<String, Object> inputMap,
// 		Map<String, Object> outMap,
// 		Map<String, Object> options
// 	) {
// 		List<Map<String, Object>> facultyInformationList;
// 		List<Map<String, Object>> reviewFacultyInformationList;
// 		try {
// 			// Fetching PAR Id from OS
// 			String parId = (String) options.get('parId');
// 			// Fetching Roles from parent every OS
// 			String roles = (String) inputMap.get('Roles');
// 			Id businessAccountId;

// 			if (String.isBlank(parId) || String.isBlank(roles)) {
// 				LPI_ExceptionManager.logException(
// 					CLASS_NAME,
// 					FETCH_FACULTY_INFORMATION,
// 					PAR_NOT_FOUND,
// 					PAR_NOT_FOUND,
// 					null,
// 					null
// 				);
// 				return facultyInformationList;
// 			}
// 			// Fecting contact Id from PAR object for ACR creation
// 			List<String> employmentHistoryIds = new List<String>();
//             String businessLicenseName = null;
// 			List<PreliminaryApplicationRef> par = LPI_PreliminaryApplicationRefDAO.getPreliminaryApplicationRefByDymanicQuery(
// 				'BusinessAccountNameId,Employee_Information_ACR_Ids__c,Business_License__c',
// 				'Id = \'' + String.escapeSingleQuotes(parId) + '\'',
// 				null,
// 				null,
// 				null
// 			);
// 			if (!par.isEmpty()) {
// 				businessAccountId = par[0].BusinessAccountNameId;
// 				if (par[0].Employee_Information_ACR_Ids__c != null) {
// 					if (par[0].Employee_Information_ACR_Ids__c.contains(',')) {
// 						employmentHistoryIds = par[0].Employee_Information_ACR_Ids__c.split(',');
// 					} else {
// 						employmentHistoryIds.add(par[0].Employee_Information_ACR_Ids__c);
// 					}
// 				}
//                 // This is in case of Flows other than New. We will be storing BusinessLicenseName which will be used to fetch employment history records.
//                 if(par[0].Business_License__c!=null) {
//                 	List<BusinessLicense> blRecList = LPI_BusinessLicenseDAO.fetchBusinessLicenseRecordsWithOrderByLimit('Id,Name','Id=\''+ String.escapeSingleQuotes(par[0].Business_License__c)+'\'',null,null);
//                     if(!blRecList.isEmpty()) {
//                         businessLicenseName = blRecList[0].Name;
//                     }
//                 }
//             }

// 			LPI_BusinessRelationshipDAO.LPI_BusinessRelationshipsWithoutSharingDAO acrWithoutSharing = new LPI_BusinessRelationshipDAO.LPI_BusinessRelationshipsWithoutSharingDAO();
// 			facultyInformationList = new List<Map<String, Object>>();
// 			reviewFacultyInformationList = new List<Map<String, Object>>();
// 			Map<Id, String> mapOfContactIdLicenseNumber = new Map<Id, String>();
// 			Map<Id, Id> mapOfContactIdAcrId = new Map<Id, Id>();
// 			Map<Id, Id> mapOfContactIdPersonContactId = new Map<Id, Id>();
// 			Map<Id, object> mapOfContactIdActivlyAssociated = new Map<Id, object>();
// 			Map<Id, Object> mapOfContactIdIsActive = new Map<Id, Object>();

// 			for (
// 				Business_Relationships__c acr : acrWithoutSharing.getBusinessRelationshipsByDymanicQuery(
// 					'ID,License_Type__c,License_Number__c,If_Relationship_is_Associated_with_you__c,IsActive__c,Related_To__r.Name,Related_To__r.FirstName,Related_To__r.MiddleName,Related_To__r.LastName,Related_From__c,Related_To__c',
// 					'Related_From__c = \'' +
// 						String.escapeSingleQuotes(businessAccountId) +
// 						'\'' +
// 						' AND Roles__c = \'' +
// 						String.escapeSingleQuotes(roles) +
// 						'\'' +
// 						' AND ((IsActive__c = FALSE AND Start_Date__c != null) OR (IsActive__c = TRUE AND EndDate__c = null))',
// 					null,
// 					null,
// 					null
// 				)
// 			) {
// 				mapOfContactIdLicenseNumber.put(acr.Related_To__c, acr.License_Number__c);
// 				mapOfContactIdAcrId.put(acr.Related_To__c, acr.Id);
// 				mapOfContactIdPersonContactId.put(acr.Related_To__c, acr.Related_To__c);
// 				mapOfContactIdIsActive.put(acr.Related_To__c, acr.IsActive__c);
// 				mapOfContactIdActivlyAssociated.put(
// 					acr.Related_To__c,
// 					acr.If_Relationship_is_Associated_with_you__c
// 				);
// 			}
// 			if (!mapOfContactIdLicenseNumber.isEmpty()) {

//             String empHistoryWhereClause = '( RelatedPersonId IN' + LPI_ServiceUtility.getStringValuesBySet(mapOfContactIdLicenseNumber.keySet());

//             // this will be in case of New Faculty Information Records.
//             if(!employmentHistoryIds.isEmpty()) {
// 				Set<String> empHistorySet = new Set<String>(employmentHistoryIds);
// 				// removing null Id's from the list.
// 				empHistorySet.remove('null');
//               	empHistoryWhereClause+=' AND Id IN' + LPI_ServiceUtility.getStringValuesByList(new List<String>(empHistorySet)) + ' )';

//             } else {
// 				empHistoryWhereClause+=')';
// 			}
// 			// this is added to fetch existing faculty information for Other than New Flows.
// 			if(businessLicenseName!=null && employmentHistoryIds.isEmpty()){
//               empHistoryWhereClause+=' AND Employer_License_Number__c = \'' + String.escapeSingleQuotes(businessLicenseName)+'\' ';
//             }
// 			// Querying Employment History in Without Sharing because in With Sharing Date of Birth Field from account is not coming
// 			LPI_PersonEmploymentDAO.LPI_EmploymentHistoryWithoutSharingDAO withoutSharing = new LPI_PersonEmploymentDAO.LPI_EmploymentHistoryWithoutSharingDAO();
// 			for (
// 					PersonEmployment eh : withoutSharing.getEmploymentHistoryByDymanicQuery(
// 						'Id,Employer_License_Number__c,Business_License__r.Last_Name__c,Business_License__r.Middle_Name__c,Business_License__r.First_Name__c,Business_License__c,Business_License__r.Name,Business_License__r.License_Number_With_Rat_Name__c,Position,Start_date__c,Type_of_Employment__c,Name_of_Courses_Teaching__c,Nursing_license_ever_been_disciplined__c,RelatedPerson.FirstName,RelatedPerson.MiddleName,RelatedPerson.LastName,RelatedPerson.Name,New_Position__c,Replacing_an_existing_faculty__c,Specify_Name_of_Replaced_Faculty__c,End_Date_of_Association__c',//I-275921
// 						 empHistoryWhereClause,
// 						null,
// 						null,
// 						null
// 					)
// 				) {
// 					Map<String, Object> singleFacultyInformation = new Map<String, Object>();
// 					if (eh.Business_License__r.Name == mapOfContactIdLicenseNumber.get(eh.RelatedPersonId)) {
// 						singleFacultyInformation.put('LicenseNumber', eh.Business_License__r.License_Number_With_Rat_Name__c);
// 						singleFacultyInformation.put('LicenseName', eh.Business_License__c);
// 						singleFacultyInformation.put('FirstName', eh.Business_License__r.First_Name__c);
// 						singleFacultyInformation.put('MiddleName', eh.Business_License__r.Middle_Name__c);
// 						singleFacultyInformation.put('LastName', eh.Business_License__r.Last_Name__c);
// 						singleFacultyInformation.put('licenseNumberUI', eh.Business_License__r.License_Number_With_Rat_Name__c);
// 						// singleFacultyInformation.put('DateOfBirth', eh.RelatedPerson.Date_of_Birth__c);
// 						singleFacultyInformation.put('LicenseTypes', 'Registered Nurse');
// 						singleFacultyInformation.put('TitleOfPosition', eh.Position);
// 						singleFacultyInformation.put('EmploymentDate', eh.StartDate);
// 						singleFacultyInformation.put('TypeOfEmployment', eh.Type_of_Employment__c);
// 						singleFacultyInformation.put('TeachingCourses', eh.Name_of_Courses_Teaching__c);
// 						singleFacultyInformation.put('NewPosition', eh.New_Position__c);
// 						singleFacultyInformation.put('ReplaceExistingFaculty', eh.Replacing_an_existing_faculty__c);
// 						if(eh.Replacing_an_existing_faculty__c == 'Yes') {
// 							singleFacultyInformation.put(
// 								'SpecifyNameofReplacedFaculty',
// 								eh.Specify_Name_of_Replaced_Faculty__c
// 							);
// 							singleFacultyInformation.put('EndDateOfAssociation', eh.End_Date_of_Association__c);
// 						}
// 						singleFacultyInformation.put(
// 							'FacultyActivelyAssociated',
// 							mapOfContactIdActivlyAssociated.get(eh.RelatedPersonId)
// 						);
// 						singleFacultyInformation.put(
// 							'NursingLicenseEverDisciplined',
// 							eh.Nursing_license_ever_been_disciplined__c
// 						);
// 						Map<String, Object> multipleFacultyInformation = new Map<String, Object>();

// 						// Read only field for Active Employees
// 						Map<String, Object> readOnlyFacultyInformation = new Map<String, Object>();
// 						if (mapOfContactIdIsActive.get(eh.RelatedPersonId) == true) {
// 							readOnlyFacultyInformation.put('LicenseNumberReadOnly', eh.Business_License__r.Name);
// 							readOnlyFacultyInformation.put('FirstNameReadonly', eh.Business_License__r.First_Name__c);
// 							readOnlyFacultyInformation.put('MiddleNameReadOnly', eh.Business_License__r.Middle_Name__c);
// 							readOnlyFacultyInformation.put('LastNameReadOnly',eh.Business_License__r.Last_Name__c);
// 							// readOnlyFacultyInformation.put('DateOfBirthReadOnly', eh.RelatedPerson.Date_of_Birth__c);
// 							readOnlyFacultyInformation.put('LicenseTypesReadOnly', 'Registered Nurse');
// 							readOnlyFacultyInformation.put('TitleOfPositionReadOnly', eh.Position);
// 							readOnlyFacultyInformation.put('EmploymentDateReadOnly', eh.StartDate);
// 							readOnlyFacultyInformation.put('TypeOfEmploymentReadOnly', eh.Type_of_Employment__c);
// 							readOnlyFacultyInformation.put('TeachingCoursesReadOnly', eh.Name_of_Courses_Teaching__c);
// 							readOnlyFacultyInformation.put(
// 								'NursingLicenseEverDisciplinedReadOnly',
// 								eh.Nursing_license_ever_been_disciplined__c
// 							);

// 							multipleFacultyInformation.put('FacultyReadOnlyBlock', readOnlyFacultyInformation);
// 						}

// 						multipleFacultyInformation.put('ContactId', mapOfContactIdPersonContactId.get(eh.RelatedPersonId));
// 						multipleFacultyInformation.put('EmploymentHistoryId', eh.Id);
// 						multipleFacultyInformation.put('Id', mapOfContactIdAcrId.get(eh.RelatedPersonId));
// 						multipleFacultyInformation.put('Name', eh.RelatedPerson.Name);
// 						multipleFacultyInformation.put('TitleOfPositionUI', eh.Position);
// 						multipleFacultyInformation.put('TypeOfEmploymentUI', eh.Type_of_Employment__c);
// 						multipleFacultyInformation.put('licenseNumberUI', eh.Business_License__r.License_Number_With_Rat_Name__c);
// 						multipleFacultyInformation.put('IsActive', mapOfContactIdIsActive.get(eh.RelatedPersonId));
// 						multipleFacultyInformation.put('LicenseNumber-Block', singleFacultyInformation);

// 						facultyInformationList.add(multipleFacultyInformation);
// 						reviewFacultyInformationList.add(singleFacultyInformation);
// 					}
// 				}

// 				if (!facultyInformationList.isEmpty()) {
// 					outMap.put('ReviewResult', reviewFacultyInformationList);
// 					outMap.put('AddFacultyInformation', facultyInformationList);
// 				}
// 			}
// 		} catch (Exception e) {
// 			LPI_ExceptionManager.logException(CLASS_NAME, FETCH_FACULTY_INFORMATION, e);
// 			throw new LPI_Exception('Problem in fetching the the Faculty Information details', e);
// 		}

// 		return facultyInformationList;
// 	}

// 	/**
// 	 * @author          	: Saurabh singh
// 	 * @param inputMap  	: fetching all the input from Omniscript
// 	 * @param outMap    	: Passing value to Omniscript
// 	 * @description     	: This Method will delete ACR When user delete record from Portal
// 	 * @last modified by    : MTX Group Inc
// 	 * @last modified date  :
// 	 * @modified details    :
// 	 */

// 	private static void deleteFacultyInformation(Map<String, Object> inputMap, Map<String, Object> outMap,Map<String,Object> options) {
// 		try {
// 			// Fetching id of ACR record
// 			Id recordId = String.isNotBlank((String)inputMap.get('Id')) ? (Id) inputMap.get('Id') : null;
// 			Id employmentHistoryId = String.isNotBlank((String)inputMap.get('EmploymentHistoryId')) ? (Id) inputMap.get('EmploymentHistoryId') : null;
// 			String parId = (String) options.get(String.escapeSingleQuotes(PAR_ID));

// 			// Fecthing id of Employment history
// 			if (String.isNotBlank(recordId) && String.isNotBlank(employmentHistoryId)) {
// 				List<Business_Relationships__c> acrActiveList = LPI_BusinessRelationshipDAO.fetchBusinessRelationshipRecords(
// 					'Id',
// 					'Id = \'' + recordId + '\'' + 'AND IsActive__c = true',
// 					null,
// 					null,
// 					null
// 				);
// 				if (!acrActiveList.isEmpty()) {
// 					throw new LPI_Exception(CANNOT_DELETE_ACTIVE_ACR);
// 				} else if (acrActiveList.isEmpty() && String.isNotBlank(recordId)) {
// 					// Deleting ACR

// 						// delete ACR and Employment History IDs from PAR.
// 						String fields = 'Id,Employee_Information_ACR_Ids__c';
// 						String whereClause = 'Id = \''+String.escapeSingleQuotes(parId)+'\'';

// 						List<PreliminaryApplicationRef> parList = LPI_PreliminaryApplicationRefDAO.getPreliminaryApplicationRefByDymanicQuery(
// 																	fields,whereClause,'1',
// 																	null,null
// 																);
// 						List<String> empHistoryIds = (!parList.isEmpty()?parList[0].Employee_Information_ACR_Ids__c?.split(','):new List<String>());
// 						List<String> acrIdList = new List<String>();
//                     Integer recordLen = acrIdList==null?0:acrIdList.size();
// 						for(Integer k = recordLen-1;k>=0; k-- ) {
// 							if(empHistoryIds!=null && !empHistoryIds.isEmpty() && empHistoryIds.get(k)?.equals(employmentHistoryId)) {
// 								empHistoryIds.remove(k);
// 							}
// 							if(acrIdList!=null && !acrIdList.isEmpty() && acrIdList.get(k)?.equals(recordId)) {
// 								acrIdList.remove(k);
// 							}
// 						}
// 						if(recordLen>0) {
// 							PreliminaryApplicationRef parRec = new PreliminaryApplicationRef(Id = parId);
// 							if(empHistoryIds!=null && !empHistoryIds.isEmpty()) {
// 								parRec.Employee_Information_ACR_Ids__c = String.join(empHistoryIds,',');
// 							}
// 							LPI_DML.doUpdate(parRec);
// 						}

// 						Business_Relationships__c accConRelation = new Business_Relationships__c();
// 						accConRelation.Id = recordId;
// 						 // checking if use has access of record then only they will be able to delete record else Not.
// 						 if (LPI_WithoutSharingUtility.checkACRAccess(recordId)) {
//                             LPI_WithoutSharingUtility.deleteSObject(accConRelation);
//                         } else {
//                             throw new LPI_Exception('You do not have access to perform this operation');
//                         }

// 						// Deleting Employment History
// 						PersonEmployment employmentHistory = new PersonEmployment();
// 						employmentHistory.id = employmentHistoryId;
// 						// checking if use has access of record then only they will be able to delete record else Not.
//                         List<PersonEmployment> employmentHistoryList = LPI_PersonEmploymentDAO.getEmploymentHistoryByDymanicQuery('Id','Id =\''+employmentHistoryId+'\'',null,null,null);
//                     	if(employmentHistoryList.size() > 0)
//                         {
//                             LPI_WithoutSharingUtility.deleteSObject(employmentHistory);
//                         }
//                     	else {
// 							throw new LPI_Exception('You do not have access to perform this operation');
// 						}
// 				}
// 			}
// 		} catch (Exception e) {
// 			if (e.getMessage() == CANNOT_DELETE_ACTIVE_ACR) {
// 				throw new LPI_Exception(CANNOT_DELETE_ACTIVE_ACR, e);
// 			}else if(e.getMessage() == DO_NOT_HAVE_ACCESS){
//                 throw new LPI_Exception(DO_NOT_HAVE_ACCESS,e);
//             }
// 			LPI_ExceptionManager.logException(CLASS_NAME, DELETE_FACULTY_INFORMATION, e);
// 			throw new LPI_Exception('Problem occured in deleting the record please contact admin', e);
// 		}
// 	}

// 	/**
// 	 * @author                     : Saurabh singh
// 	 * @param id 				   : ACR ID id
// 	 * @param AccountId 		   : Account Id
// 	 * @param ContactId            : Contact Id
// 	 * @param Options              : Options map data pass from OS to code
// 	 * @param answerYesBlock 	   : access all element present in answerYesBlock
// 	 * @param answerNo 			   : access all element present in answerNo
// 	 * @param activelyAssociated   : Acr is actively associated or not checkbox(If_Relationship_is_Associated_with_you__c)
// 	 * @param updateRecordIfExists : Check if ACR is already created then update that ACR
// 	 * @return  `Business_Relationships__c`
// 	 * @description                : Fetching Employee information For Review Page
// 	 * @last modified by           : MTX Group Inc
// 	 * @last modified date         :
// 	 * @modified details           :
// 	 */
// 	private static Business_Relationships__c upsertAccountContactRelation(
// 		String id,
// 		String personContactId,
// 		Id businessAccountId,
// 		String roles,
// 		Map<String, Object> completeBlock,
// 		Boolean activelyAssociated,
// 		String employmentDate
// 	) {
// 		Business_Relationships__c accConRelation = new Business_Relationships__c();
// 		//try {
// 			String licenseNumber, licenseType;
// 			Boolean acrActive = false;
// 			if (completeBlock != null) {
// 				licenseNumber = (String) completeBlock.get(String.escapeSingleQuotes('LicenseName'));
// 				licenseType = (String) completeBlock.get(String.escapeSingleQuotes('LicenseTypes'));
// 				acrActive = (Boolean) completeBlock.get('ACRActive');
// 			}

// 			if (string.isNotBlank(id)) {
// 				accConRelation.Id = id;
// 			}

// 			if (personContactId != null) {
// 				accConRelation.Related_To__c = personContactId;
// 			}
// 			if (businessAccountId != null) {
// 				accConRelation.Related_From__c = businessAccountId;
// 			}

// 			if (roles!=null) {
// 				accConRelation.Roles__c =  roles;
// 			}
// 			// Adding Duplicate check.
// 			List<sObject> dupRecords =  LPI_RelationshipService.findDuplicates(accConRelation);
// 			if(!dupRecords.isEmpty()) {
// 				throw new LPI_Exception('Duplicate Relationship Found.');
// 			}
// 			if (String.isNotBlank(licenseNumber)) {
// 				accConRelation.License_Number__c = licenseNumber;
// 			}
// 			if (String.isNotBlank(licenseType)) {
// 				accConRelation.License_Type__c = licenseType;
// 			}
// 			if (String.isNotBlank(employmentDate)) {
// 				accConRelation.Start_Date__c = date.valueOf(employmentDate);
// 			}
// 			accConRelation.IsActive__c = (acrActive==null?false:true);
// 			accConRelation.If_Relationship_is_Associated_with_you__c = activelyAssociated;

// 			if (String.isBlank(id)) {
// 				accConRelation = (Business_Relationships__c) LPI_WithoutSharingUtility.insertSObject(accConRelation);
// 			} else if(String.isNotBlank(id)){
// 				LPI_WithoutSharingUtility.updateSObject(accConRelation); // For Portal user there is no option to give permission for updating ACR
// 			}
// 		// } catch (Exception e) {
// 		// 	LPI_ExceptionManager.logException(CLASS_NAME, UPSERT_ACCOUNT_CONTACT_RELATION, e);
// 		// }

// 		return accConRelation;
// 	}

// 	/**
// 	 * @author 					   : Saurabh singh
// 	 * @param accountId            : Account Id
// 	 * @param contactId 		   : Contact Id
// 	 * @param roles                : Role of ACR
// 	 * @return  `list<Business_Relationships__c>`
// 	 * @description                : Fetching ACR on the basis of different filter
// 	 * @last modified by           : MTX Group Inc
// 	 * @last modified date         :
// 	 * @modified details           : Changing ACR to Business_Relationships__c
// 	 */
// 	private static List<Business_Relationships__c> queryAccountContactRelation(
// 		String personContactId,
// 		Id businessAccountId,
// 		String roles
// 	) {
// 		String whereClause;
// 		if (personContactId != null && businessAccountId != null) {
// 			whereClause =
// 				'Related_From__c =\'' +
// 				String.escapeSingleQuotes(businessAccountId) +
// 				'\'' +
// 				' AND Related_To__c = \'' +
// 				String.escapeSingleQuotes(personContactId) +
// 				'\'';
// 		}
// 		if (String.isNotBlank(roles)) {
// 			whereClause = whereClause + ' AND Roles__c = \'' + String.escapeSingleQuotes(roles) + '\'';
// 		}

// 		// Account records are not getting fetched due to OWD private
// 		LPI_BusinessRelationshipDAO.LPI_BusinessRelationshipsWithoutSharingDAO acrWithoutSharing = new LPI_BusinessRelationshipDAO.LPI_BusinessRelationshipsWithoutSharingDAO();
// 		List<Business_Relationships__c> accountContactRelationExist = acrWithoutSharing.getBusinessRelationshipsByDymanicQuery(
// 			'Id,Related_From__r.Name,Related_From__c,License_Type__c, Title__c,Related_To__r.Name,Roles__c,License_Number__c,Start_Date__c,IsActive__c',
// 			whereClause,
// 			null,
// 			null,
// 			null
// 		);
// 		return accountContactRelationExist;
// 	}

// 	/**
// 	 * @author              : Saurabh singh
// 	 * @param obj           : object
// 	 * @description         : This Method will tell us whether deserialize object is Map or not
// 	 * @last modified by    : MTX Group Inc
// 	 * @last modified date  :
// 	 * @modified details    :
// 	 */
// 	private static Boolean isMap(Object obj) {
// 		String str, firstCharacter, lastCharacter;
// 		if (obj != null) {
// 			str = String.valueOf(obj);
// 			firstCharacter = str.substring(0, 1);
// 			lastCharacter = str.substring(str.length() - 1, str.length());
// 		}

// 		return !(obj instanceof String) && '{'.equals(firstCharacter) && '}'.equals(lastCharacter);
// 	}

// 	/**
// 	 * @author              : Saurabh singh
// 	 * @param inputMap      : Input value passed from OS
// 	 * @param outMap        : Output value passed from here to OS
// 	 * @description         : Saving All Employment History Id on PAR (Employee_Information_ACR_Ids__c) field
// 	 * @last modified by    : MTX Group Inc
// 	 * @last modified date  :
// 	 * @modified details    :
// 	 */
// 	private static void saveFacultyInformationIds(Map<String, Object> inputMap, Map<String, Object> outMap) {
// 		try {
// 			String parId = (String) inputMap.get('parid');
// 			String employementHistoryIds = '';
// 			String businessRelIds = '';
// 			Map<String, Object> facultyInformation = (Map<String, Object>) inputMap.get('FacultyInformation');
// 			List<Object> addFacultyInformationDetails = new List<Object>();

// 			if (facultyInformation.containsKey('AddFacultyInformation')) {
// 				if (isMap(facultyInformation.get('AddFacultyInformation'))) {
// 					addFacultyInformationDetails.add((Object) facultyInformation.get('AddFacultyInformation'));
// 				} else {
// 					addFacultyInformationDetails = (List<Object>) facultyInformation.get('AddFacultyInformation');
// 				}
// 				if (addFacultyInformationDetails != null) {
// 					for (Object data : addFacultyInformationDetails) {
// 						Map<String, Object> facultyData = (Map<String, Object>) data;
// 						employementHistoryIds += (String) facultyData.get('EmploymentHistoryId') + ',';
// 						businessRelIds += (String) facultyData.get('Id') + ',';
// 					}

// 					PreliminaryApplicationRef par = new PreliminaryApplicationRef(Id = parId);
// 					par.Employee_Information_ACR_Ids__c = employementHistoryIds.removeEnd(',');
// 					//par.Registered_Agent_Relation_Id__c = businessRelIds.removeEnd(',');
// 					LPI_DML.doUpdate(par);
// 				}
// 			}
// 		} catch (Exception e) {
// 			LPI_ExceptionManager.logException(CLASS_NAME, SAVE_FACULTY_INFORMATION, e);
// 			throw new LPI_Exception('Problem in Saving Faculty Information details', e);
// 		}
// 	}

// 	/**
// 	 * @author 				 : Saurabh singh
// 	 * @description          : method is used to Fetch details for  License Question from License_Questions__c field on PAR
// 	 * @return 				 : Map<String, String>
// 	 * @last modified by     : MTX Group Inc
// 	 * @last modified date   : 30 Jan 2023
// 	 * @modified details     : Shifting Query to DAO CLass
// 	 */
// 	private static void fetchLicenseQuestionsForNursingSchool(Map<String, Object> inputMap,Map<String, Object> outMap) {
// 		try {
// 			// Please don't change anything in this Method without informing saurabh
// 			Id recoId = (String) inputMap.get('parid');
// 			// Query to fetch License Question and Classification field
// 			String parFields = 'Id, License_Questions__c';
// 			String parWhereClause = 'Id = \'' + String.escapeSingleQuotes(recoId) + '\'';
// 			List<PreliminaryApplicationRef> parList = LPI_PreliminaryApplicationRefDAO.getPreliminaryApplicationRefByDymanicQuery(
// 				parFields,
// 				parWhereClause,
// 				null,
// 				null,
// 				null
// 			);
// 			// Deserializing License Question field if License Question is not Empty
// 			if (!parList.isEmpty() && String.isNotBlank(parList[0].License_Questions__c)) {
// 				Map<String, Object> deserializedLicenseQuestions;
// 					deserializedLicenseQuestions = (Map<String, Object>) JSON.deserializeUntyped(
// 						String.valueOf(parList[0].get('License_Questions__c'))
// 					);

// 					// Deserializing each and every key present in License Question in the form of JSON
// 					if (!deserializedLicenseQuestions.isEmpty()) {
// 						for (String values : deserializedLicenseQuestions.keySet()) {
// 							if (values != null) {
// 								if (String.valueOf(deserializedLicenseQuestions.get(values)).contains('{')) {
// 									//System.assert(false,'&&&'+values+'***'+deserializedLicenseQuestions.get(values));
// 									Map<String, Object> subBlockMap = (Map<String, Object>) deserializedLicenseQuestions.get(
// 										values
// 									);
// 									for (String subBlock : subBlockMap.keySet()) {
// 										outMap.put(subBlock, subBlockMap.get(subBlock));
// 									}
// 								} else {
// 									outMap.put(values, deserializedLicenseQuestions.get(values));
// 								}
// 							}
// 						}
// 					}
// 			}
// 		} catch (Exception e) {
// 			LPI_ExceptionManager.logException(CLASS_NAME, FETCH_LICENSE_QUESTIONS, e);
// 		}
// 	}

// 	/**
//          * @author                      : Ayman Sheikh
//          * @since                       : 27 Jul 2023
//          * @description                 : This method will fetch the License Details
//         */
//         public static List<Map<String, object>> fetchPDLicense(Map<String, Object> inputMap, Map<String, Object> options) {
// 			List<Map<String, Object>> licenseList = new List<Map<String, Object>>();
// 			try {
// 				// getting License Number from the OS
// 				String licenseNumber = '%' + (String)inputMap.get('LicenseNumber') + '%';
// 				if(!String.isEmpty(licenseNumber) && licenseNumber.length() >= 4){
// 					String parId = (String)options.get('parId');

// 					// Fetching PAR Details with the Help of DAO class.
// 					String fields ='Id, Contact__c';
// 					String whereClause = ' Id = \'' + String.escapeSingleQuotes(parId) + '\'';
// 					List<PreliminaryApplicationRef> parList =  LPI_PreliminaryApplicationRefDAO.getPreliminaryApplicationRefByDymanicQuery(
// 						fields, whereClause, null, null, null);

// 					List<BusinessLicense> blRecordList = new List<BusinessLicense>();
// 					if (String.isNotEmpty(licenseNumber) && !parList.isEmpty()) {
// 						fields = 'Id, Name, License_Number_With_Rat_Name__c, Regulatory_Authorization_Type_Name__c';
// 						whereClause = 'Name LIKE \'' +licenseNumber +'\'' +
// 										' AND ContactId = \'' + parList[0].Contact__c + '\'';
// 						blRecordList = LPI_BusinessLicenseDAO.fetchBusinessLicenseRecords(fields, whereClause);
// 					}
// 					// Iterating through Business License Record and putting the details in Map
// 					for (BusinessLicense blRecord : blRecordList) {
// 						Map<String, Object> licenseMap = new Map<String, Object>();
// 						licenseMap.put('Name', blRecord.Regulatory_Authorization_Type_Name__c);
// 						licenseMap.put('LicenseNumber', blRecord.Name);
// 						licenseList.add(licenseMap);
// 					}
// 				}
// 			}
// 			catch (Exception e) {
// 				LPI_ExceptionManager.logException(CLASS_NAME, FETCH_PD_LICENSE, e);
// 			}
// 			return licenseList;
// 		}

// 	/**
// 	 * @author                       : Vamshi Kumar
// 	 * @since                        : Aug 14, 2023
// 	 * @description                  : get Nursing school Administrator Details(S-53693)
// 	 * @param inputMap               : input map
// 	 * @param outMap                 : output map
// 	 * @return                       : List<Map<String, Object>>
// 	 */
// 	public static void getNurSchoolAdministratorDetails(Map<String, Object> inputMap, Map<String, Object> outMap) {
// 		try {
// 			Id parid = (Id) inputMap.get('parId');
// 			if (parid != null) {
// 				String parFields;
// 				String whereClause;
// 				String whereCondition;
// 				List<Business_Relationships__c> listOfACR = new List<Business_Relationships__c>();
// 				List<PreliminaryApplicationRef> parList = new List<PreliminaryApplicationRef>();
// 				Map<String, Object> nursingProgramAdministratorInfoStep = new Map<String, Object>();
// 				List<Map<String, Object>> adminAccountList = new List<Map<String, Object>>();
// 				Map<String, Object> ownerBlockMap = new Map<String, Object>();
// 				List<BusinessLicense> blList = new List<BusinessLicense>();
// 				String fieldsToQuery = 'Id';
							
// 				parFields = fieldsToQuery + ',Type__c,Business_License__c,Person_Incharge_Relation_Id__c,Contact__r.AccountId,How_are_you_associated_to_this_entity__c,BusinessAccountNameId,Amendment_Type__c,Licensed_in_Missouri__c';
// 				whereClause = 'Id = \'' + String.escapeSingleQuotes(parid) + '\'';
// 				parList = LPI_PreliminaryApplicationRefDAO.getPreliminaryApplicationRefByDymanicQuery(
// 					parFields,
// 					whereClause,
// 					'1',
// 					null,
// 					null
// 				);
// 				//fetching admin details
// 				if(!parList.isEmpty())
// 				{
// 					if((NUR_ADMIN_RENEWAL_ROUTINE_TYPES.contains(parList[0].Type__c)||
// 					NUR_ADMIN_RENEWAL_ROUTINE_TYPES.contains(parList[0].Amendment_Type__c))
// 						&& String.isNotBlank(parList[0].Business_License__c))
// 					{
// 						whereClause = 'Id = \'' + parList[0].Business_License__c + '\'';
// 						//applicant user don't have access to business license
// 						LPI_BusinessLicenseDAO.LPI_BusinessLicenseWithoutSharingDAO bLListWithOutSharing = new LPI_BusinessLicenseDAO.LPI_BusinessLicenseWithoutSharingDAO();
// 						blList = bLListWithOutSharing.getBusinessLicenseByDymanicQuery(
// 							fieldsToQuery,
// 							whereClause,
// 							null,
// 							null,
// 							null
// 						);
// 					}
					
// 					if((parList[0].Licensed_in_Missouri__c == LPI_LiteralConstant.LPI_NO && !listOfACR.isEmpty())){
// 						Account acc = listOfACR[0].Related_To__r;
// 						outMap.put('NcsbnIdNumber', acc?.NCSBN_Candidate_ID__c);
//                         outMap.put('ProgramDirectorTelephone', acc?.PersonHomePhone);
//                         outMap.put('ProgramDirectorMobile', acc?.Phone);
//                         outMap.put('ProgramDirectorStreet', acc?.PersonOtherStreet);
//                         outMap.put('ProgramDirectorCity', acc?.PersonOtherCity);
// 						outMap.put('ProgramDirectorState', acc?.PersonOtherStateCode);
//                         outMap.put('ProgramDirectorZipcode', acc?.PersonOtherPostalCode);
//                         outMap.put('ProgramDirectorEmail', acc?.PersonEmail);
//                         outMap.put('ProgramDirectorFirstName', acc?.FirstName);
// 						outMap.put('ProgramDirectorMiddleName', acc?.MiddleName);
//                         outMap.put('ProgramDirectorLastName', acc?.LastName);
// 						outMap.put('ProgramDirectorCounty', acc?.County__c);
// 					}
// 					//end
// 				}
// 				if(!ownerBlockMap.isEmpty())
// 				{
// 					adminAccountList.add(ownerBlockMap);
// 				}
// 				//Storing Response in outMap
// 				if (!adminAccountList.isEmpty()) {
// 					outMap.put('OwnerBlock', adminAccountList);
// 					outMap.put('OwnerBlockRead', adminAccountList);
// 				}
// 			}
// 		} catch (Exception e) {
// 			LPI_ExceptionManager.logException(CLASS_NAME, GET_NUR_SCHOOL_ADMIN_DETAILS, e);
// 		}
// 	}
}