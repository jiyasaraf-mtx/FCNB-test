/**
 * @author          : Vamshi Kumar
 * @description     : This class fetch Education Program Code Config Details(S-48026)
 * @history
 * -------------------------------------------------------------------------------------------------------
 * Version      Date                Author                  Details
 *    1         5 May, 2023         Vamshi Kumar            Initial Developement
 * -------------------------------------------------------------------------------------------------------
 */
global with sharing class LPI_NursingEducationProgramController 
//implements Callable 
{
	public void m1(){

	}
	// *************************************** ALL CONSTANTS ************************************************
	// public final static String CLASS_NAME = 'LPI_NursingEducationProgramController';
	// //public final static String GET_SCHOOLNAME_PROGRAMCODE = 'getSchoolNameProgramCode';
	// public final static String BASIC_PROFESSIONAL_NUR_EDUCATION_VALID_CHECK = 'basicProfessionalNursingEducationValidCheck';
	// //public final static String FETCH_BPNE_DETAILS = 'fetchBasicProfessionalNursingEducationDetails';
	// public final static Set<String> RN_PROGRAMTYPES = new Set<String>{
	// 	'RN - ADN',
	// 	'RN - BS',
	// 	'RN - BSN',
	// 	'RN - DPL',
	// 	'RN - MSN',
	// 	'RN - ND',
	// 	'RN - BN'
	// };
	// public final static String PRACTICAL_NURSING_PROGRAM = 'Practical Nursing (PN)';
	// public final static String BASIC_PROFESSIONAL_NURSING_EDUCATION = 'Nursing Education'; /*Changing name as per S-54290*/
	// private final static String UNITED_STATES = 'United States';
	// private final static String CANADA = 'Canada';
	// private final static String MISSOURI = 'Missouri';
	// private final static Set<String> NURSING_SCHOOL_LIC_TYPE_SET = new Set<String>{
	// 	'Practical Nursing Program',
	// 	'Associate Degree Nursing Program',
	// 	'Baccalaureate Degree Nursing Program'
	// };
	// //private final static String NURSING_SCHOOL_PROGRAM_NAME_CODE_CHECK = 'nursingSchoolProgramNameCodeValidCheck';
	// //private final static String NURSING_EDUCATION_PROGRAM_NAME_CODE_CHECK = 'nursingEducationProgramNameCodeValidCheck';
	// private final static String STUDENT = 'Student';
	// //private final static String CREATE_NURSING_EDUCATION_SCHOOL_REL = 'createNursingEducationSchoolRelationship';
	// //private final static String DELETE_APPLICATION_CONTENT = 'deleteApplicationContent';
	// //Added by Vamshi Kumar S-60083
	// //private final static String GET_PROGRAM_COUNTRY_CODE = 'getProgramCountryCode';
	// private final static String FOREIGN = 'Foreign';
	// // ******************************************************************************************************

	// // Added by Adarsh Singh - I-275469
	// private final static String FETCH_AMENDMENT_DETAILS = 'fetchChangeInProgramLenghtAmendementDetails';

	// /**
	//  * @author                      : Vamshi Kumar
	//  * @since                       : 05 May 2023
	//  * @description                 : This method calls invoke method
	//  * @param action                : String
	//  * @param args			        : Map<String, Object>
	//  * @return                      : Object
	//  * @last modified by            : MTX Group Inc
	//  * @last modified date          :
	//  * @modified details            :
	//  */
	// global Object call(String action, Map<String, Object> args) {
	// 	Map<String, Object> input = (Map<String, Object>) args.get('input');
	// 	Map<String, Object> output = (Map<String, Object>) args.get('output');
	// 	Map<String, Object> options = (Map<String, Object>) args.get('options');
	// 	return invokeMethod(action, input, output, options);
	// }

	// /**
	//  * @author               : Vamshi Kumar
	//  * @param methodName     : invokeMethod
	//  * @param inputMap       : Input Parameter Passed from Omniscript
	//  * @param outMap         : Output Passed to Omniscript
	//  * @param options        : Extra Options passed from Omniscript
	//  * @created date		 : 05 May, 2023
	//  * @last modified by     : MTX Group Inc
	//  * @last modified date   :
	//  * @modified details     :
	//  * @return  `Boolean`
	//  */
	// private Boolean invokeMethod(
	// 	String methodName,
	// 	Map<String, Object> inputMap,
	// 	Map<String, Object> outMap,
	// 	Map<String, Object> options
	// ) {
	// 	try {
	// 		// if (methodName.equals(GET_SCHOOLNAME_PROGRAMCODE)) {
	// 		// 	outMap.put('programCodeDetails', getSchoolNameProgramCode(inputMap, outMap, options));
	// 		// } else 
	// 		// if (methodName.equals(FETCH_BPNE_DETAILS)) {
	// 		// 	fetchBasicProfessionalNursingEducationDetails(inputMap, outMap);
	// 		// } else 
	// 		// if (methodName.equals(NURSING_SCHOOL_PROGRAM_NAME_CODE_CHECK)) {
	// 		// 	nursingSchoolProgramNameCodeValidCheck(inputMap, outMap);
	// 		// } else 
	// 		// if (methodName.equals(NURSING_EDUCATION_PROGRAM_NAME_CODE_CHECK)) {
	// 		// 	nursingEducationProgramNameCodeValidCheck(inputMap, outMap, options);
	// 		// } else 
	// 		// if (methodName.equals(CREATE_NURSING_EDUCATION_SCHOOL_REL)) {
	// 		// 	createNursingEducationSchoolRelationship(inputMap, outMap, options);
	// 		// } else 
	// 		// if(methodName.equals(DELETE_APPLICATION_CONTENT)){
	// 		// 	deleteApplicationContent(inputMap);
	// 		// } else 
	// 		// if(methodName.equals(GET_PROGRAM_COUNTRY_CODE)) {
	// 		// 	outMap.put('programCodeCountryDetails', getProgramCountryCode(inputMap, outMap));
	// 		// } else 
	// 		if(methodName.equals(FETCH_AMENDMENT_DETAILS)){
	// 			fetchChangeInProgramLenghtAmendementDetails(inputMap,outMap);
	// 		}
	// 		return true;
	// 	} catch (Exception exp) {
	// 		LPI_ExceptionManager.logException(CLASS_NAME, 'invokeMethod', exp);
	// 		return false;
	// 	}
	// }

	// /**
	//  * @author                      : Vamshi Kumar
	//  * @since                       : 5 May 2023
	//  * @description                 : This method will fetch the Education Program Code Config Details
	//  * @param inputMap			   	: Map<String, Object>
	//  * @return                      : `List<Map<String,String>>` List of Matching PRogram Codes
	//  * @last modified by            : MTX Group Inc
	//  * @last modified date          :
	//  * @modified details            :
	//  */
	// // private static List<Map<String, String>> getSchoolNameProgramCode(
	// // 	Map<String, Object> inputMap,
	// // 	Map<String, Object> outMap,
	// // 	Map<String, Object> options
	// // ) {
	// // 	List<Map<String, String>> programCodeList = new List<Map<String, String>>();
	// // 	try {
	// // 		String programSearchKey = (String) inputMap.get('RNLPNApplicationEducationProgramCode');
	// // 		String programNameSearchKey = (String) inputMap.get('RNLPNApplicationNursingProgramName');
	// // 		//String country = (String) options.get('RNLPNApplicationBPNECountry');
	// // 		String country = (String) options.get('RNLPNApplicationBPNEUSCountry') == UNITED_STATES ?
	// // 			(String) options.get('RNLPNApplicationBPNEUSCountry') : (String) options.get('RNLPNApplicationBPNECountry');
	// // 		String state = (String) options.get('RNLPNApplicationBPNEUSStates');
	// // 		String programType = (String) options.get('RNLPNApplicationProgramTypeFormula');
	// // 		String programCode = (String) options.get('RNLPNApplicationEducationProgramCode');
	// // 		String programName = (String) options.get('RNLPNApplicationNursingProgramName');
	// // 		//Added by Vamshi Kumar S-60083
	// // 		String prov = (String) options.get('RNLPNApplicationBPNEState');
	// // 		String fieldsToQuery = 'Program_Code__c,School_Name__c, State_Prov_Terr_Abbrev__c, Location__c';
	// // 		String whereClause;
	// // 		if(String.isNotBlank(country) && ((String.isNotBlank(programSearchKey) && programSearchKey.length() >= 3) || (String.isNotBlank(programNameSearchKey)  && programNameSearchKey.length() >= 3))){
	// // 			//Seraching program name and code from Configuration records if country and program type are not blank
	// // 			if(String.isNotBlank(programType)){
	// // 				whereClause = 'School_Name__c LIKE \'%' + String.escapeSingleQuotes(programNameSearchKey) + '%\'' 
	// // 					+' AND Country__c = \'' + String.escapeSingleQuotes(country) + '\''
	// // 					+ ' AND Type__c = \'' + String.escapeSingleQuotes(programType) + '\'';
	// // 				//Added by Vamshi Kumar S-60083
	// // 				if(country == UNITED_STATES)
	// // 				{
	// // 					whereClause += ' AND State_Prov_Terr_Abbrev__c = \'' + String.escapeSingleQuotes(state) + '\'';
	// // 				} else{
	// // 					whereClause += ' AND State_Prov_Terr_Abbrev__c = \'' + String.escapeSingleQuotes(prov) + '\'';
	// // 				}
	// // 				for (
	// // 					Education_Program_Code_Configuration__c ep : LPI_EducationProgramConfigDAO.getEducationProgramConfigByDynamicQuery(
	// // 						fieldsToQuery,
	// // 						whereClause
	// // 					)
	// // 				) {
	// // 					Map<String, String> programCodeMap = new Map<String, String>();
	// // 					programCodeMap.put('programCode', ep.Program_Code__c);
	// // 					programCodeMap.put('programNameKey', ep.School_Name__c + ' -' + ep.State_Prov_Terr_Abbrev__c + ',' + ep.Location__c);
	// // 					programCodeMap.put('programName', ep.School_Name__c);
	// // 					programCodeMap.put('RNLPNApplicationBPNECity', ep.Location__c);
	// // 					programCodeMap.put('RNLPNApplicationBPNECityCheck', ep.Location__c);
	// // 					programCodeList.add(programCodeMap);
	// // 				}
	// // 			}

	// // 			//Searching program name and code from licenses if County is US and State is Missouri
	// // 			if(country == UNITED_STATES && state == MISSOURI && String.isNotBlank(programNameSearchKey)){
	// // 				String whereClauseForLicense = 'RegulatoryAuthorizationType.Name IN '+LPI_ServiceUtility.getStringValuesByStringSet(NURSING_SCHOOL_LIC_TYPE_SET)
	// // 					+' AND Business_Entity_Name__c LIKE \'%' + String.escapeSingleQuotes(programNameSearchKey) + '%\''
	// // 					+ ' AND Program_Code__c != NULL ';

	// // 				for (
	// // 					BusinessLicense bl : new LPI_BusinessLicenseDAO.LPI_BusinessLicenseWithoutSharingDAO()
	// // 					.getBusinessLicenseByDymanicQuery(
	// // 						'Name, Business_Entity_Name__c, Program_Code__c, Account.BillingCity, Account.Id, Account.BillingState',
	// // 						whereClauseForLicense,
	// // 						null,
	// // 						null,
	// // 						null
	// // 					)
	// // 				) {
	// // 					Map<String, String> programCodeMap = new Map<String, String>();
	// // 					programCodeMap.put('programCode', bl.Program_Code__c);
	// // 					programCodeMap.put('programName', bl.Business_Entity_Name__c);
	// // 					programCodeMap.put('RNLPNApplicationBPNECity', bl.Account.BillingCity);
	// // 					programCodeMap.put('SchoolAccId', bl.Account.Id);
	// // 					programCodeMap.put('SchoolBlId', bl.Id);
	// // 					programCodeMap.put('SchoolBlName', bl.Name);
	// // 					programCodeMap.put('RNLPNApplicationBPNECityCheck', bl.Account.BillingCity);
	// // 					programCodeMap.put('programNameKey',bl.Business_Entity_Name__c + ' -' + bl.Account.BillingState + ',' + bl.Account.BillingCity);
	// // 					programCodeList.add(programCodeMap);
	// // 				}
	// // 			}
	// // 		}
	// // 		Map<String, String> otherMap = new Map<String, String>();
	// // 		otherMap.put('programNameKey', LPI_LiteralConstant.DELIVERY_METHOD_OTHER);
	// // 		programCodeList.add(otherMap);
	// // 	} catch (Exception e) {
	// // 		LPI_ExceptionManager.logException(CLASS_NAME, 'getSchoolNameProgramCode', e);
	// // 	}
	// // 	return programCodeList;
	// // }

	
	// /**
	//  * @author                      : Vamshi Kumar
	//  * @since                       : 18 May 2023
	//  * @description                 : This method will fetch the Person Education Details based on EducationType and ProgramType(EducationLevel)
	//  * @param inputMap			   	: Map<String, Object>
	//  * @return                      : Void
	//  * @last modified by            : MTX Group Inc
	//  * @last modified date          :
	//  * @modified details            :
	//  */
	// // public static void fetchBasicProfessionalNursingEducationDetails(
	// // 	Map<String, Object> inputMap,
	// // 	Map<String, Object> outMap
	// // ) {
	// // 	try {
	// // 		String parId = (String) inputMap.get('parid');
	// // 		List<PreliminaryApplicationRef> parDetails = new List<PreliminaryApplicationRef>();
	// // 		Id contactId;
	// // 		Id accountId;
	// // 		Set<String> programTypeSet;
	// // 		List<Map<String, Object>> programCodeBlockList = new List<Map<String, Object>>();
	// // 		//check if parid is not null and fetch par Details
	// // 		if (parId != null) {
	// // 			String parQueryFields = 'Contact__c,Regulatory_Authorization_Type__r.Name,BusinessAccountNameId,Employee_Information_ACR_Ids__c,Amendment_Type__c';
	// // 			String parWhereClause = 'Id = \'' + String.escapeSingleQuotes(parId) + '\'';
	// // 			parDetails = LPI_PreliminaryApplicationRefDAO.getPreliminaryApplicationRefByDymanicQuery(
	// // 				parQueryFields,
	// // 				parWhereClause,
	// // 				null,
	// // 				null,
	// // 				null
	// // 			);
	// // 		}
	// // 		//save contactId and License Type related Type of Program Set
	// // 		if (!parDetails.isEmpty()) {
	// // 			contactId = parDetails[0]?.Contact__c;
	// // 			accountId = parDetails[0]?.BusinessAccountNameId;
	// // 			if (parDetails[0].Regulatory_Authorization_Type__r.Name == LPI_LiteralConstant.IA_REGISTERED_NURSE) {
	// // 				programTypeSet = RN_PROGRAMTYPES;
	// // 			} else {
	// // 				programTypeSet = new Set<String>{ PRACTICAL_NURSING_PROGRAM };
	// // 			}
	// // 		}
	// // 		//fetch contact related person education with BASIC_PROFESSIONAL_NURSING_EDUCATION Type
	// // 		if (!String.isEmpty(contactId)) {
	// // 			String personEduQueryFields = 'Id,IdentifierIssuer,EducationLevel,Is_Your_Program_Closed__c,Program_Code__c,Specify__c,Name,Website_Name__c,City__c,State__c,Country_Text__c,GraduationDate,Institution_Email__c,'
	// // 				+'Date_Fingerprinted__c,Date_of_Credentials_Evaluation_Report__c,English_Language_Proficiency_Exam_Date__c,Street_Address__c,Zip_Code__c';
	// // 			String personEduWhereClause =
	// // 				'ContactId =\'' +
	// // 				String.escapeSingleQuotes(contactId) +
	// // 				'\' AND Education_Type__c  = \'' +
	// // 				BASIC_PROFESSIONAL_NURSING_EDUCATION +
	// // 				'\'';
	// // 			for (
	// // 				PersonEducation pe : LPI_PersonEducationDAO.getPersonEducationByDymanicQuery(
	// // 					personEduQueryFields,
	// // 					personEduWhereClause,
	// // 					null,
	// // 					null,
	// // 					null
	// // 				)
	// // 			) {
	// // 				//checking for matching ProgramType(EducationLevel)
	// // 				if (programTypeSet.contains(pe.EducationLevel)) {
	// // 					outMap.put('regAuthTypeName', parDetails[0]?.Regulatory_Authorization_Type__r.Name);
	// // 					//outMap.put('RNLPNApplicationInstructionsMissouriBoardAuthorize', parDetails[0]?.Exam_Application_Status_Authorize__c);
	// // 					outMap.put('subTypeCategory',parDetails[0]?.Amendment_Type__c);
	// // 					outMap.put('personEduId', pe?.Id);
	// // 					outMap.put('RNLPNApplicationBPNEProgramTypeRN', pe?.EducationLevel);
	// // 					outMap.put('RNLPNApplicationBPNEProgramTypeLPN', pe?.EducationLevel);
	// // 					outMap.put('RNLPNApplicationBPNEProgramTypeRead', pe?.EducationLevel);
	// // 					outMap.put('RNLPNApplicationBPNECity', pe?.City__c);
	// // 					outMap.put('RNLPNApplicationBPNECountry', pe?.Country_Text__c);
	// // 					outMap.put('RNLPNApplicationBPNECountryRead', pe?.Country_Text__c);
	// // 					outMap.put('RNLPNApplicationBPNEGradDate', pe?.GraduationDate);
	// // 					outMap.put('RNLPNProgramCodeOtherRead', pe?.Is_Your_Program_Closed__c);
	// // 					outMap.put('RNLPNProgramCodeOther', pe?.Is_Your_Program_Closed__c);
	// // 					if(pe.Country_Text__c == UNITED_STATES){
	// // 						outMap.put('RNLPNApplicationBPNEUSStates', pe?.State__c);
	// // 					}
	// // 					if(pe.Country_Text__c == CANADA){
	// // 						outMap.put('RNLPNApplicationBPNEState', pe?.State__c);
	// // 						outMap.put('RNLPNApplicationBPNEStateRead', pe?.State__c);
	// // 					}
	// // 					outMap.put('RLPNCountryForInstruction',pe.Country_Text__c);
	// // 					outMap.put('RLPNStateForInstruction',pe.State__c);
	// // 					outMap.put('RNLPNApplicationBPNEUSStatesRead', pe?.State__c);
    // //                     outMap.put('RNLPNApplicationBPNEGradDateRead', pe?.GraduationDate);
    // //                     outMap.put('RNLPNApplicationBPNECityRead', pe?.City__c);
	// // 					outMap.put('RNLPNEngProfExamDateExam', pe?.English_Language_Proficiency_Exam_Date__c);
	// // 					outMap.put('RNLPNEngProfFingerprintDate', pe?.Date_Fingerprinted__c);
	// // 					outMap.put('RNLPNEngProfCredsEvaluationDate', pe?.Date_of_Credentials_Evaluation_Report__c);
	// // 					outMap.put('RNLPNEngProfExamDateEndorsement', pe?.English_Language_Proficiency_Exam_Date__c);
	// // 					outMap.put('RNLPNEngProfExamDateExamRead', pe?.English_Language_Proficiency_Exam_Date__c);
	// // 					outMap.put('RNLPNEngProfFingerprintDateRead', pe?.Date_Fingerprinted__c);
	// // 					outMap.put('RNLPNEngProfCredsEvaluationDateRead', pe?.Date_of_Credentials_Evaluation_Report__c);
	// // 					OutMap.put('RNLPNApplicationEducationProgramCodeRead', pe?.Program_Code__c);
	// // 					outMap.put('RNLPNApplicationBPNEStreet', pe?.Street_Address__c);
	// // 					outMap.put('RNLPNApplicationBPNEStreetRead', pe?.Street_Address__c);
	// // 					outMap.put('RNLPNApplicationBPNEZip', pe?.Zip_Code__c);
	// // 					outMap.put('RNLPNApplicationBPNEZipRead', pe?.Zip_Code__c);
	// // 					outMap.put('BPNENursingProgramCountry',pe?.Country_Text__c == UNITED_STATES ? UNITED_STATES : (String.isNotBlank(pe?.Country_Text__c) 
	// // 						&& pe?.Country_Text__c != UNITED_STATES ? FOREIGN : null));
	// // 					if(String.isNotBlank(pe?.Specify__c))
	// // 					{
	// // 						outMap.put('RNLPNApplicationBPNECityCheck', pe?.City__c);
	// // 					} else{
	// // 						outMap.put('RNLPNApplicationBPNECityText', pe?.City__c);
	// // 					}
	// // 					//Added by Vamshi Kumar S-60083
	// // 					outMap.put('ProgramCountry', pe?.Country_Text__c);
	// // 					outMap.put('ProgramCountryCheck',pe?.Country_Text__c);
	// // 					if(pe.Country_Text__c == UNITED_STATES || pe.Country_Text__c == CANADA){
	// // 						if(pe.IdentifierIssuer == LPI_LiteralConstant.DELIVERY_METHOD_OTHER)
	// // 						{
	// // 							OutMap.put('RNLPNApplicationNursingProgramNameRead', pe?.IdentifierIssuer);
	// // 							OutMap.put('RNLPNApplicationNursingProgramName', pe?.IdentifierIssuer);
	// // 						}
	// // 						else {
	// // 							OutMap.put('RNLPNApplicationNursingProgramName', pe?.IdentifierIssuer + ' -' + pe?.State__c + ',' + pe?.City__c);
	// // 							OutMap.put('RNLPNApplicationNursingProgramNameRead', pe?.IdentifierIssuer + ' -' + pe?.State__c + ',' + pe?.City__c);
	// // 						}
	// // 						OutMap.put('RNLPNApplicationEducationProgramCode', pe?.Program_Code__c);
	// // 						OutMap.put('programCode', pe?.Program_Code__c);
	// // 						OutMap.put('programName', pe?.IdentifierIssuer);
	// // 						if(pe?.Is_Your_Program_Closed__c == 'Yes'){
	// // 							if(pe.Country_Text__c == UNITED_STATES){
	// // 								OutMap.put('RNLPNApplicationNursingProgramCodeUSDisabled', pe?.Program_Code__c);
	// // 							}else{
	// // 								OutMap.put('RNLPNApplicationNursingProgramCodeCanadaDisabled', pe?.Program_Code__c);
	// // 							}
	// // 						}
	// // 					}else{
	// // 						OutMap.put('RNLPNApplicationNursingProgramNameRead', pe?.IdentifierIssuer);
	// // 						OutMap.put('RNLPNApplicationNursingProgramNameText', pe?.IdentifierIssuer);
	// // 						OutMap.put('RNLPNApplicationEducationProgramCodeText', pe?.Program_Code__c);
	// // 					}
	// // 				}
	// // 			}
	// // 			outMap.put('conId', contactId);
	// // 			outMap.put('accId', accountId);
	// // 		}
	// // 		//added by sudhanshu - start
	// // 		outMap.put('ScoreTransferDocDownloadLink',System.Label.ScoreTransferDocDownloadLink);
	// // 		outMap.put('AirforceDocDownloadLink',System.Label.AirforceDocDownloadLink);
	// // 		//added by sudhanshu - end
	// // 		if(!parDetails.isEmpty() && String.isNotBlank(parDetails[0].Employee_Information_ACR_Ids__c))
	// // 		{
	// // 			//Fetching Supervisor Pharmacist Relationship details
	// // 			LPI_BusinessRelationshipDAO.LPI_BusinessRelationshipsWithoutSharingDAO relationsWithOutSharing = new LPI_BusinessRelationshipDAO.LPI_BusinessRelationshipsWithoutSharingDAO(); //Portal user do not have permission to fetch Account details
	// // 			List<Business_Relationships__c> studentRelList = relationsWithOutSharing.getBusinessRelationshipsByDymanicQuery(
	// // 					'Id, Related_From__c, Entity_License_Number__c, Related_From_License_Number__c, Related_From_License_Number__r.Name',
	// // 					'Id = \'' + String.escapeSingleQuotes(parDetails[0].Employee_Information_ACR_Ids__c) + '\'',
	// // 					null,
	// // 					null,
	// // 					null
	// // 				);
	// // 			if(!studentRelList.isEmpty()){
	// // 				Map<String,Object> programNameBlock = new Map<String,Object>();
	// // 				programNameBlock.put('SchoolAccId',studentRelList[0].Related_From__c);
	// // 				programNameBlock.put('SchoolBlId',studentRelList[0].Related_From_License_Number__c);
	// // 				programNameBlock.put('schoolBlName',studentRelList[0].Related_From_License_Number__r.Name);
	// // 				outMap.put('RNLPNApplicationNursingProgramName-Block',programNameBlock);
	// // 				outMap.put('studentRelId',studentRelList[0].Id);
	// // 			}
	// // 		}
			
	// // 	} catch (Exception e) {
	// // 		LPI_ExceptionManager.logException(CLASS_NAME, 'fetchBasicProfessionalNursingEducationDetails', e);
	// // 	}
	// // }

	// /**
	//  * @author                      : Vamshi Kumar
	//  * @since                       : 27 Nov 2023
	//  * @description                 : This method will check if user entered ProgramCode & SchoolName are valid or not
	//  * 								  by comparing with existing Education Program Code Config Details
	//  * @param inputMap			   	: Map<String, Object>
	//  * @return                      : Void
	//  * @last modified by            : MTX Group Inc
	//  * @last modified date          :
	//  * @modified details            :
	//  */
	// // private static void nursingSchoolProgramNameCodeValidCheck(
	// // 	Map<String, Object> inputMap,
	// // 	Map<String, Object> outMap
	// // ) {
	// // 	try {
	// // 		List<Education_Program_Code_Configuration__c> programCodeConfigList;
	// // 		Map<String, Object> nursingSchoolInstructStep = (Map<String, Object>) inputMap.get(
	// // 			'Instructions'
	// // 		);
	// // 		Map<String, Object> nursingSchoolExistProgramBlock = (Map<String, Object>) nursingSchoolInstructStep.get(
	// // 			'NursingSchoolIntakeBlock'
	// // 		);
	// // 		String programCode = (String) nursingSchoolExistProgramBlock.get('NursingProgramCode');
	// // 		if(String.isNotBlank(programCode))
	// // 		{
	// // 			String fieldsToQuery = 'Id';
	// // 			String whereClause =
	// // 				'Program_Code__c = \'' +
	// // 				String.escapeSingleQuotes(programCode) +
	// // 				'\'';
	// // 			//fetching Education_Program_Code_Configuration__c records 
	// // 			programCodeConfigList =  LPI_EducationProgramConfigDAO.getEducationProgramConfigByDynamicQuery(
	// // 				fieldsToQuery,
	// // 				whereClause
	// // 			);
	// // 		}
	// // 		//Sending false boolean if we dont have any matching record of programCode
	// // 		if(programCodeConfigList.isEmpty())
	// // 		{
	// // 			outMap.put('validData',false);
	// // 		}
	// // 		else{
	// // 			outMap.put('validData',true);
	// // 			//outMap.put('fraudulentCode',programCodeConfigList[0].Fraudulent_Flag__c);
	// // 		}
	// // 	} catch (Exception e) {
	// // 		LPI_ExceptionManager.logException(CLASS_NAME, NURSING_SCHOOL_PROGRAM_NAME_CODE_CHECK, e);
	// // 	}
	// // }

	// /**
	//  * @author                      : Vamshi Kumar
	//  * @since                       : 27 Nov 2023
	//  * @description                 : This method will check if user entered ProgramCode & SchoolName are valid or not
	//  * 								  by comparing with existing Education Program Code Config Details/new licenses programCodes
	//  * @param inputMap			   	: Map<String, Object>
	//  * @return                      : Void
	//  * @last modified by            : MTX Group Inc
	//  * @last modified date          :
	//  * @modified details            :
	//  */
	// // private static void nursingEducationProgramNameCodeValidCheck(
	// // 	Map<String, Object> inputMap,
	// // 	Map<String, Object> outMap,
	// // 	Map<String, Object> options
	// // ) {
	// // 	try {
	// // 		List<Education_Program_Code_Configuration__c> programCodeConfigList;
	// // 		String fieldsToQuery;
	// // 		String whereClause;
	// // 		Map<String, Object> nursingEducationEditBlock;
	// // 		Map<String, Object> nursingEducationProgramNameBlock;
	// // 		Map<String, Object> nursingEducationProgramCodeBlock;
	// // 		String programName;
	// // 		String programCode;
	// // 		String state;
	// // 		//Added by Vamshi Kumar S-60083
	// // 		String prov;
	// // 		Boolean validData = false;
	// // 		Map<String, Object> nursingEducationStep = (Map<String, Object>) inputMap.get(
	// // 			'BasicProfessionalNursingEducationStep'
	// // 		);
	// // 		//fetching block with editable elements
	// // 		if(nursingEducationStep.containsKey('RNLPNBPNEBlockEdit'))
	// // 		{
	// // 			nursingEducationEditBlock = (Map<String, Object>) nursingEducationStep.get(
	// // 				'RNLPNBPNEBlockEdit'
	// // 			);
	// // 		}
	// // 		//String country = (String) options.get('RNLPNApplicationBPNECountry');
	// // 		String country = (String) options.get('RNLPNApplicationBPNEUSCountry') == UNITED_STATES ?
	// // 			(String) options.get('RNLPNApplicationBPNEUSCountry') : (String) options.get('RNLPNApplicationBPNECountry');
	// // 		String programType = (String) options.get('RNLPNApplicationProgramTypeFormula');
	// // 		programCode = (String) options.get('RNLPNApplicationEducationProgramCode');
	// // 		programName = (String) options.get('RNLPNApplicationNursingProgramName');
	// // 		//fetching programcode and programName blocks
	// // 		if(nursingEducationEditBlock != null)
	// // 		{
	// // 			state = (String) nursingEducationEditBlock.get('RNLPNApplicationBPNEUSStates');
	// // 			//Added by Vamshi Kumar S-60083
	// // 			prov = (String) nursingEducationEditBlock.get('RNLPNApplicationBPNEState');
	// // 			if(nursingEducationEditBlock.containsKey('RNLPNApplicationNursingProgramName-Block'))
	// // 			{
	// // 				nursingEducationProgramNameBlock = (Map<String, Object>) nursingEducationEditBlock.get(
	// // 					'RNLPNApplicationNursingProgramName-Block'
	// // 				);
	// // 			}
	// // 		}
	// // 		//fetching programName
	// // 		if(nursingEducationProgramNameBlock != null)
	// // 		{
	// // 			programName = (String) nursingEducationProgramNameBlock.get('programName');
	// // 			programCode = (String) nursingEducationProgramNameBlock.get('programCode');
	// // 		}
	// // 		//Checking validation of Program Code and ProgramName except OTHER
	// // 		if(String.isNotBlank(programName) && String.isNotBlank(programCode) && programName != LPI_LiteralConstant.DELIVERY_METHOD_OTHER)
	// // 		{
	// // 			if(String.isNotBlank(programType))
	// // 			{
	// // 				fieldsToQuery = 'Id';
	// // 				whereClause = 'Type__c = \'' + String.escapeSingleQuotes(programType) + '\'' 
	// // 					+' AND Country__c = \'' + String.escapeSingleQuotes(country) + '\''
	// // 					+' AND Program_Code__c = \'' + String.escapeSingleQuotes(programCode) + '\''
	// // 					+' AND School_Name__c = \'' + String.escapeSingleQuotes(programName) + '\'';
	// // 				//Added by Vamshi Kumar S-60083
	// // 				if(country == UNITED_STATES)
	// // 				{
	// // 					whereClause += ' AND State_Prov_Terr_Abbrev__c = \'' + String.escapeSingleQuotes(state) + '\'';
	// // 				} else{
	// // 					whereClause += ' AND State_Prov_Terr_Abbrev__c = \'' + String.escapeSingleQuotes(prov) + '\'';
	// // 				}
	// // 				//fetching Education_Program_Code_Configuration__c records 
	// // 				programCodeConfigList =  LPI_EducationProgramConfigDAO.getEducationProgramConfigByDynamicQuery(
	// // 					fieldsToQuery,
	// // 					whereClause
	// // 				);
	// // 			}
	// // 			if(!programCodeConfigList.isEmpty()){
	// // 				validData = true;
	// // 			}
	// // 			//Sending boolean true if we have any matching record of programCode & SchoolName
	// // 			if(programCodeConfigList.isEmpty() && state == MISSOURI)
	// // 			{
	// // 				fieldsToQuery = 'Id';
	// // 				whereClause = 'RegulatoryAuthorizationType.Name IN '+LPI_ServiceUtility.getStringValuesByStringSet(NURSING_SCHOOL_LIC_TYPE_SET)
	// // 					+' AND Business_Entity_Name__c = \'' +String.escapeSingleQuotes(programName) +'\''
	// // 					+' AND Program_Code__c = \'' + String.escapeSingleQuotes(programCode) + '\'';
	// // 				for (
	// // 					BusinessLicense bl : new LPI_BusinessLicenseDAO.LPI_BusinessLicenseWithoutSharingDAO()
	// // 					.getBusinessLicenseByDymanicQuery(
	// // 						fieldsToQuery,
	// // 						whereClause,
	// // 						null,
	// // 						null,
	// // 						null
	// // 					)
	// // 				) {
	// // 					validData = true;
	// // 				}
	// // 			}
	// // 			outMap.put('validData',validData);
	// // 		}
	// // 	} catch (Exception e) {
	// // 		LPI_ExceptionManager.logException(CLASS_NAME, NURSING_EDUCATION_PROGRAM_NAME_CODE_CHECK, e);
	// // 	}
	// // }
	// /**
	//  * @author                      : Vamshi Kumar
	//  * @since                       : 14 Dec 2023
	//  * @description                 : This method will create relationship between student and nursing school
	//  * 								  selected in search from business license in missouri
	//  * @param inputMap			   	: Map<String, Object>
	//  * @return                      : Void
	//  */
	// // private static void createNursingEducationSchoolRelationship(
	// // 	Map<String, Object> inputMap,
	// // 	Map<String, Object> outMap,
	// // 	Map<String, Object> options
	// // ) {
	// // 	try {
	// // 		String parId = (String) inputMap.get('parid');
	// // 		String studentRelId = (String) inputMap.get('studentRelId');
	// // 		String schoolAccId = (String) options.get('SchoolAccId');
	// // 		String applicantId = (String) options.get('accId');
	// // 		String schoolBlId = (String) options.get('SchoolBlId');
	// // 		String schoolBlName = (String) options.get('SchoolBlName');
	// // 		List<Business_Relationships__c> relationshipExistList = new List<Business_Relationships__c>();
	// // 		Business_Relationships__c rel = new Business_Relationships__c();
	// // 		//querying for any existing Relationship
	// // 		if(String.isNotBlank(studentRelId))
	// // 		{
	// // 			rel.Id = studentRelId;
	// // 		}
	// // 		if(String.isNotBlank(studentRelId) && String.isBlank(schoolAccId))
	// // 		{
	// // 			LPI_WithoutSharingUtility.deleteSObject(rel);
	// // 		}
	// // 		Business_Relationships__c newRel = new Business_Relationships__c();
	// // 		String newRelId;
	// // 		if (String.isNotBlank(schoolAccId) && String.isNotBlank(applicantId) && String.isNotBlank(schoolBlId)) {
	// // 			rel.Related_From__c = schoolAccId;
	// // 			rel.Related_To__c = applicantId;
	// // 			rel.Roles__c = STUDENT;
	// // 			rel.IsActive__c = false;
	// // 			rel.Entity_License_Number__c = schoolBlName;
	// // 			rel.Related_From_License_Number__c = schoolBlId;
	// // 			relationshipExistList = LPI_RelationshipService.findDuplicates(
	// // 				new List<Business_Relationships__c>{ rel }
	// // 			);
	// // 			if (relationshipExistList.isEmpty()) {
	// // 				//inserting Relationship
	// // 				newrel = (Business_Relationships__c) LPI_WithoutSharingUtility.upsertSObject(
	// // 					rel
	// // 				); //Portal user do not have permission to insert Relationships
	// // 			}
	// // 			newRelId = relationshipExistList.isEmpty() ? newRel.Id : relationshipExistList[0].Id;
	// // 		}
			
	// // 		//storing student relationship id in Par
	// // 		if (String.isNotBlank(parId)) {
	// // 			PreliminaryApplicationRef par = new PreliminaryApplicationRef(Id = parId);
	// // 			par.Employee_Information_ACR_Ids__c = String.isNotBlank(newRelId) ? newRelId : null;
	// // 			LPI_DML.doUpdate(par);
	// // 		}
	// // 		outMap.put('studentRelId', newrel.Id);
	// // 	} catch (Exception e) {
	// // 		LPI_ExceptionManager.logException(CLASS_NAME, CREATE_NURSING_EDUCATION_SCHOOL_REL, e);
	// // 	}
	// // }

	// /**
	//  * @author                      : Sudhanshu Jain
	//  * @since                       : 14 Dec 2023
	//  * @description                 : This method will delete Application content related to the par
	//  * @param inputMap			   	: Map<String, Object>
	//  * @return                      : Void
	//  */
	// // private static void deleteApplicationContent(Map<String, Object> inputMap) {
	// // 	try {
	// // 		String parId = (String) inputMap.get('parId');
    // //         if(String.isNotEmpty(parId)){
	// // 			List<Application_Content__c> appContentList = new List<Application_Content__c>();
	// // 			String fields = 'Id, Preliminary_Application_Reference__c';
    // //             String whereClause = 'Preliminary_Application_Reference__c =\''+String.escapeSingleQuotes(parId)+'\''+
	// // 			'AND Section_Header__c = \'Licensure In Other States\'';
    // //             // Querying on PAR to get all related records
    // //             appContentList = LPI_ApplicationContentDAO.getApplicationContentByDymanicQuery(
    // //                     fields,
    // //                     whereClause,
    // //                     null,
    // //                     null,
    // //                     null);
	// // 			if (!appContentList.isEmpty()) {
	// // 				LPI_DML.doDelete(appContentList);
	// // 			}
    // //         }
	// // 	} catch (Exception exp) {
	// // 		LPI_ExceptionManager.logException(
	// // 			CLASS_NAME,
	// // 			DELETE_APPLICATION_CONTENT,
	// // 			exp
	// // 		);
    // //     }
	// // }

	// /**
	//  * @author                      : Vamshi Kumar
	//  * @since                       : 6 Jan 2023
	//  * @description                 : This method will fetch country list from the Education Program Code Config Details S-60083
	//  * @param inputMap			   	: Map<String, Object>
	//  * @return                      : `List<Map<String,String>>` List of Matching Countries
	//  * @last modified by            : MTX Group Inc
	//  * @last modified date          :
	//  * @modified details            :
	//  */
	// // private static List<Map<String, String>> getProgramCountryCode(
	// // 	Map<String, Object> inputMap,
	// // 	Map<String, Object> outMap
	// // ) {
	// // 	List<Map<String, String>> programCodeCountryList = new List<Map<String, String>>();
	// // 	try {
	// // 		String programCountryKey = (String) inputMap.get('ProgramCountry');
	// // 		String fieldsToQuery = 'Program_Code__c,Country__c';
	// // 		String whereClause;
	// // 		if((String.isNotBlank(programCountryKey) && programCountryKey.length() >= 3)){
	// // 			//Searching country and code from Configuration records if country is not blank
	// // 			whereClause = 'Country__c LIKE \'%' + String.escapeSingleQuotes(programCountryKey) + '%\'';
	// // 			for (
	// // 				Education_Program_Code_Configuration__c ep : LPI_EducationProgramConfigDAO.getEducationProgramConfigByDynamicQuery(
	// // 					fieldsToQuery,
	// // 					whereClause
	// // 				)
	// // 			) {
	// // 				//adding country and program values in a map
	// // 				if(ep.Country__c != UNITED_STATES && ep.Country__c != CANADA)
	// // 				{
	// // 					Map<String, String> programCodeMap = new Map<String, String>();
	// // 					programCodeMap.put('NursingCountryKey', ep.Country__c);
	// // 					programCodeMap.put('ProgramCountryCheck', ep.Country__c);
	// // 					programCodeMap.put('RNLPNApplicationEducationProgramCodeText', ep.Program_Code__c);
	// // 					programCodeCountryList.add(programCodeMap);
	// // 				}
	// // 			}
	// // 		}
	// // 		//Adding Canada and United States values in a map to avoid mutliple values from records
	// // 		Map<String, String> canadaMap = new Map<String, String>();
	// // 		canadaMap.put('NursingCountryKey', CANADA);
	// // 		programCodeCountryList.add(canadaMap);
	// // 		// Map<String, String> unitedStatesMap = new Map<String, String>();
	// // 		// unitedStatesMap.put('NursingCountryKey', UNITED_STATES);
	// // 		// programCodeCountryList.add(unitedStatesMap);
	// // 	} catch (Exception e) {
	// // 		LPI_ExceptionManager.logException(CLASS_NAME, 'getProgramCountryCode', e);
	// // 	}
	// // 	return programCodeCountryList;
	// // }

	//  /**
    //  * @author                      : Adarsh Singh
    //  * @since                       : 18th Apr, 2024
    //  * @description                 : This Method is used to fetch Amendment Details for Practicle Nursing Program "Change in Curriculum"
    //  * @param  inputMap             : data we are fetching from the Vlocity component
    //  * @return                      : void
    //  **/
    // public static void fetchChangeInProgramLenghtAmendementDetails(Map<String, Object> inputMap, Map<String, Object> outMap){
   
    //     try{
    //      String parId = (String)inputMap.get('parId');
	// 	 String fields = 'Id,Business_License__c,Credit_Hours__c';
    //      String whereClause = 'Id = \'' + String.escapeSingleQuotes(parId) + '\'';
         
    //      List<PreliminaryApplicationRef> parList = LPI_PreliminaryApplicationRefDAO.getPreliminaryApplicationRefByDymanicQuery(fields, whereClause, null, null, null);
            
    //      if(!parList.isEmpty() && String.isNotBlank(parList[0].Business_License__c)){
    //          List<BusinessLicense> blList = (new LPI_BusinessLicenseDAO.LPI_BusinessLicenseWithoutSharingDAO())
	// 			.getBusinessLicenseByDymanicQuery(
    //              	'Id,Program_Type__c',
    //              	'Id =\''+String.escapeSingleQuotes(parList[0].Business_License__c)+'\'',
    //              	null,
    //             	null,
    //                 null
    //          	);
    //          if(!blList.isEmpty()){
    //                 outMap.put('ProgramType', blList[0].Program_Type__c);
    //          }}
    //          //outMap.put('ProgramLength',parList[0].Program_Length__c);
    //          outMap.put('CreditHours',parList[0].Credit_Hours__c);
            

    //     }catch (Exception e) {
    //      LPI_ExceptionManager.logException('LPI_NursingEducationProgramController', 'fetchChangeInProgramLenghtAmendementDetails', e);
    //     }
    // }
}