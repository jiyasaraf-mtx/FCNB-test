/**
 * @description       : This class is a remote class which is used as controller for Healing Arts Board Method of Licensure steps
 * @author            : MTX Group Product Team
 * @group             :
 * @last modified on  : 07-24-2024
 * @last modified by  : MTX Group Product Team
 **/
global with sharing class LPI_HAUtility implements Callable {
	public final static String RESIDENCE = 'Residence';
	private static final String PAR_NOT_FOUND = 'PAR record is not created for the flow';
	private static final String CLASS_NAME = 'LPI_HAUtility';
	private static final String METHOD_UPDATE_PAR_DETAILS = 'updatePARdetails';
	private static final String METHOD_FETCH_PAR_DETAILS = 'fetchPARdetails';
	private static final String METHOD_INVOKE_METHOD = 'invokeMethod';
	private static final String PAR_ID = 'parId';
	private static final String PAR_SUB_TYPE = 'parSubType';
	private static final String PAR_LICENSE_QUESTION = 'parLicenseQuestions';
	private static final String TXT_STR = 'txt';
	private static final String YES_STR = 'Yes';
	private static final String IS_ANY_QUESTION_IS_YES = 'isAnyQuestionIsYes';
	private static final String PAR_ADDITIONAL_DETAILS = 'additionalDetailsPAR';
	private static final String MOL_KEY_OS = 'parMolKey';
	private static final String JEXAM_KEY_OS = 'parJExamKey';
	private static final String PS_KEY_OS = 'parPsKey';
	private static final String RAT_NAME_KEY = 'ratNameKey';
	private static final String BOARD_NAME_KEY = 'boardNameKey';  
	private static final String STEP_NAME_KEY = 'stepNameKey';  
	private static final String Search_Field_Name = 'searchFieldName';
	private static final String EXAM_PASSED = 'examPassed';
	private static final String SELECTED_EXAM = 'selectedExam';
	private static final String ELIGIBLE_CRITERIA = 'eligibleCriteria';
	private static final String PRACTICE_TYPES = 'practiseTypes';
	private static final String PREVIOUS_PERMIT_NUMBER = 'previousPermitNumber';
	private static final String CHANGE_LICENSE_TO_INACTIVE_STATUS = 'changeLicenseToInactiveStatus';
	private static final String BLSTATUS_KEY = 'blStatus';

	private static final String IN_SALE_OF_GOODS = 'inSaleOfGoods';
    private static final String HAS_RETAIL_BUSINESS_PAID_TAX = 'hasRetailBusinessPaidTax';
    
	private static final String TAX_ID_NUMBER = 'taxIdNumber';
	private static final String FACILITY_INCORPORATED = 'facilityIncorporated';
	private static final String CORPORATION_NAME = 'corporationName';
	private static final String DATE_INCORPORATED = 'dateIncorporated';
	private static final String STATUS_OPERATOR = 'statusOperator';

	private static final String LIABILITY_INSURANCE = 'LiabilityInsurance';
	private static final String COMPANY_NAME = 'CompanyName';
	private static final String POLICY_NUMBER = 'PolicyNumber';
	private static final String MISSOURI_JURIPRUDENCE_EXAM = 'Missouri Jurisprudence Exam';

	private static final String AI_KEY_OS = 'parAIKey';

	private static final String SUPERVISOR_PERSON_INCHARGE_CORRECT = 'supervisorPersonInchargeCorrect';
	private static final String HOLD_ACTIVE_CERTIFICATION = 'holdActiveCertification';
	private static final String PERSON_INCHARGE_CERTIFICATE_NUMBER = 'certificateNum';

    private static final String WORKERS_COMPENSATION_EXEMPT = 'workersCompensationExempt';

	 
	private static final String SW_SUPERVISION_SITE_AND_SUPERVISOR_INFORMATION_STEP = 'SWSupervisionSiteAndSupervisorInformationStep';
	private static final String PASSED_MO_EXAM = 'passedMOExam';
	 
	/**
	 * @author                      : MTX Group Product Team
	 * @since                       : 09-02-2023
	 * @description                 : This method calls invoke method
	 * @param action                : String
	 * @param args			        : Map<String, Object>
	 * @return                      : Object
	 * @last modified by            : MTX Group Product Team
	 * @last modified date          :
	 * @modified details            :
	 */
	global Object call(String action, Map<String, Object> args) {
		Map<String, Object> input = (Map<String, Object>) args.get('input');
		Map<String, Object> output = (Map<String, Object>) args.get('output');
		Map<String, Object> options = (Map<String, Object>) args.get('options');
		return invokeMethod(action, input, output, options);
	}
	/**
	 * @author                      : MTX Group Product Team
	 * @since                       : 09-02-2023
	 * @description                 : This method is used to match & call the controller methods
	 * @param action                : String
	 * @param args			        : Map<String, Object>
	 * @return                      : Object
	 * @last modified by            : MTX Group Product Team
	 * @last modified date          :
	 * @modified details            :
	 */
	private Boolean invokeMethod(
		String methodName,
		Map<String, Object> inputMap,
		Map<String, Object> outMap,
		Map<String, Object> options
	) {
		Boolean result = false;
		try {
			if (METHOD_UPDATE_PAR_DETAILS.equalsIgnoreCase(methodName)) {
				return updatePARdetails(inputMap, outMap);
			} else if (methodName == 'fetchPARdetails') {
				return fetchPARdetails(inputMap, outMap);
			} else if (methodName == 'fetchBLdetails') {
				fetchBLdetails(inputMap, outMap);
				return true;
			}else if (methodName == 'fetchBLForMultipleRATs') {
				fetchBLForMultipleRATs(inputMap, outMap);
				return true;
			}
		} catch (Exception e) {
			result = false;
			LPI_ExceptionManager.logException(CLASS_NAME, METHOD_INVOKE_METHOD, e);
		}
		return result;
	}
	/**
	 * @author                      : MTX Group Product Team
	 * @since                       : 09-02-2023
	 * @description                 : This method will update the amedmenttype on PreliminaryApplicationRef
	 * @param action                : String
	 * @param args			        : Map<String, Object> inputMap , Map<String, Object> outMap
	 * @return                      : Boolean
	 * @last modified by            : MTX Group Product Team
	 * @last modified date          : June 6, 2023
	 * @modified details            : Added saving of `PERSON_INCHARGE_CERTIFICATE_NUMBER` 
	 */

	public static Boolean updatePARdetails(Map<String, Object> inputMap, Map<String, Object> outMap) {
		try {
			String parId;
			parId = (String) inputMap.get(PAR_ID);
			if (String.isEmpty(parId)) {
				LPI_ExceptionManager.logException(
					CLASS_NAME,
					METHOD_UPDATE_PAR_DETAILS,
					PAR_NOT_FOUND,
					PAR_NOT_FOUND,
					null,
					null
				);
				return false;
			}
			 
			Map<String, String> keyMapping = new Map<String, String>{ PAR_ID => 'Id' };
			PreliminaryApplicationRef par = (PreliminaryApplicationRef) LPI_VlocityUtility.createSObject(
				inputMap,
				keyMapping,
				'PreliminaryApplicationRef'
			);
			if (inputMap.containsKey(PAR_SUB_TYPE)) {
				par.Amendment_Type__c = (String) inputMap.get(PAR_SUB_TYPE);
			}
			 
			
			if (inputMap.containsKey(DATE_INCORPORATED)) {
				String dateString = (String) inputMap.get(DATE_INCORPORATED);
				List<String> dateList = dateString.split('-');
				 
			}

			if (inputMap.containsKey(LIABILITY_INSURANCE)) {
				par.Liability_Insurance__c = (String) inputMap.get(LIABILITY_INSURANCE);
			}
			 
			if (inputMap.containsKey(PAR_LICENSE_QUESTION)) {
				Map<String, Object> mapOfLicenseQuestions = (Map<String, Object>) inputMap.get(PAR_LICENSE_QUESTION);
				Boolean isAnyQuestionIsYes = false;
				for (String key : mapOfLicenseQuestions.keySet()) {
					if (key.containsIgnoreCase(TXT_STR)) {
						continue;
					}
					if (key.containsIgnoreCase('block')) {
						continue;
					}
					if (
						mapOfLicenseQuestions.get(key) instanceof String &&
						YES_STR.equalsIgnoreCase((String) mapOfLicenseQuestions.get(key))
					) {
						isAnyQuestionIsYes = true;
						break;
					}
				}
				String licenseQuestions = JSON.serialize(mapOfLicenseQuestions);
				par.License_Questions__c = licenseQuestions;
				outMap.put(IS_ANY_QUESTION_IS_YES, isAnyQuestionIsYes);
			}
			if (inputMap.containsKey(MOL_KEY_OS)) {
				String molStr = JSON.serialize(inputMap.get(MOL_KEY_OS));
				Map<String, Object> mapOfadditionalDetailsPAR;
				if (!String.isEmpty(molStr)) {
					mapOfadditionalDetailsPAR = (Map<String, Object>) inputMap.get(MOL_KEY_OS);
				}
				String additionalDetailsPAR = JSON.serialize(mapOfadditionalDetailsPAR);
				par.Method_of_Licensure__c = additionalDetailsPAR;
				if(mapOfadditionalDetailsPAR.containsKey('AreYouAwareQues')){
					par.Period_of_employment_begins__c = (String)mapOfadditionalDetailsPAR.get('AreYouAwareQues');
					if((String)mapOfadditionalDetailsPAR.get('AreYouAwareQues') == 'No'){
					par.Employment_Start_Date__c = null;
					}
				}
				if(mapOfadditionalDetailsPAR.containsKey('EmploymentStartDate') && mapOfadditionalDetailsPAR.get('EmploymentStartDate')!=null){
					par.Employment_Start_Date__c = Date.valueOf((String)mapOfadditionalDetailsPAR.get('EmploymentStartDate'));

				}
				 
			}
			if (inputMap.containsKey(JEXAM_KEY_OS)) {
				Map<String, Object> mapOfadditionalDetailsPAR = (Map<String, Object>) inputMap.get(JEXAM_KEY_OS);
				String additionalDetailsPAR = JSON.serialize(mapOfadditionalDetailsPAR);
				par.Jurisprudence_Examination__c = additionalDetailsPAR;
				createJurisprudanceExamRecord(parId);
			}
			 
			if (inputMap.containsKey(AI_KEY_OS)) {
				String molStr = JSON.serialize(inputMap.get(AI_KEY_OS));
				Map<String, Object> mapOfAdditionalInfoPAR;
				if (!String.isEmpty(molStr)) {
					mapOfAdditionalInfoPAR = (Map<String, Object>) inputMap.get(AI_KEY_OS);
				}
				String assignmentInfoPAR = JSON.serialize(mapOfAdditionalInfoPAR);
				 
			}
			 
			LPI_DML.doUpdate(par);
			return true;
		} catch (Exception e) {
			LPI_ExceptionManager.logException(CLASS_NAME, METHOD_UPDATE_PAR_DETAILS, e);
			return false;
		}
	}
	/**
	 * @author                      : MTX Group Product Team
	 * @since                       : 09-02-2023
	 * @description                 : This method will fetch the records of PreliminaryApplicationRef
	 * @param action                : String
	 * @param args			       	: Map<String, Object> inputMap , Map<String, Object> outMap
	 * @return                      : Boolean
	 * @last modified by            : MTX Group Product Team
	 * @last modified date          : June 7, 2023
	 * @modified details            : Removed fetching of `SUPERVISOR_PERSON_INCHARGE_CORRECT`, `HOLD_ACTIVE_CERTIFICATION` and `PERSON_INCHARGE_CERTIFICATE_NUMBER`
	 */

	public static Boolean fetchPARdetails(Map<String, Object> inputMap, Map<String, Object> outMap) {
		String parId = (String) inputMap.get(PAR_ID);
		List<PreliminaryApplicationRef> parList = new List<PreliminaryApplicationRef>();
		try {
			if (!String.isBlank(parId)) {
				String blockName = '';
				String subTypeName = '';
				String fieldsOnPAR =
					'Jurisprudence_Examination__c ,Amendment_Type__c ,' +
					' Method_of_Licensure__c ,Id , License_Questions__c ,';
				String whereClause = 'Id = \'' + String.escapeSingleQuotes(parId) + '\'';
				Map<String, Object> serializeMap = new Map<String, Object>();
				parList = LPI_PreliminaryApplicationRefDAO.getPreliminaryApplicationRefByDymanicQuery(
					fieldsOnPAR,
					whereClause,
					null,
					null,
					null
				);
			}
			if (!parList.isEmpty()) {
				Map<String, Object> deserialized;
				if (parList[0].License_Questions__c != null && inputMap.containsKey(PAR_LICENSE_QUESTION)) {
					deserialized = (Map<String, Object>) JSON.deserializeUntyped(parList[0].License_Questions__c);
					outMap.put((String) inputMap.get(PAR_LICENSE_QUESTION), deserialized);
				}
				if (inputMap.containsKey(PAR_SUB_TYPE)) {
					outMap.put((String) inputMap.get(PAR_SUB_TYPE), parList[0].Amendment_Type__c);
				}
				 
				if (parList[0].Method_of_Licensure__c != null && inputMap.containsKey(MOL_KEY_OS)) {
					deserialized = (Map<String, Object>) JSON.deserializeUntyped(parList[0].Method_of_Licensure__c);
					outMap.put((String) inputMap.get(MOL_KEY_OS), deserialized);
				}

				if (parList[0].Jurisprudence_Examination__c != null && inputMap.containsKey(JEXAM_KEY_OS)) {
					deserialized = (Map<String, Object>) JSON.deserializeUntyped(
						parList[0].Jurisprudence_Examination__c
					);
					outMap.put((String) inputMap.get(JEXAM_KEY_OS), deserialized);
				}
				 
				
			}
			 
			return true;
		} catch (Exception e) {
			LPI_ExceptionManager.logException(CLASS_NAME, METHOD_FETCH_PAR_DETAILS, e);
			return false;
		}
	}
	
	/**
	 * @author                      : MTX Group Product Team
	 * @since                       : March 15, 2023
	 * @description                 : This method will fetch the records of BusinessLicense object
     * @param inputMap              : Input data passed from OmniScript
	 * @param outMap                : Output data passed to OmniScript
	 * @return                      : `void`
	 * @last modified by            : MTX Group Product Team
	 * @last modified date          : July 2, 2023
	 * @modified details            : Removed isNotBlank check for licenseNumber field, it was redundant
	 */
	public static void fetchBLdetails(Map<String, Object> inputMap, Map<String, Object> outMap) {
		List<Map<String, Object>> tempMapList = new List<Map<String, Object>>();
		try {
			if (inputMap.containsKey(Search_Field_Name)) {
				String statusOperator = '=';
				String blName = String.valueOf(inputMap.get(Search_Field_Name));
				if (String.isNotBlank(blName) && blName.length() > 3) {
					String licenseNumber = '%' + blName + '%';
					String stepName = '';
					String blFields = 'Id, Name,License_Number_With_Rat_Name__c, PeriodStart, PeriodEnd, RegulatoryAuthorizationType.Name, ' 
										+ 'RegulatoryAuthorizationType.IssuingDepartment.Name, Business_Name__c, '
										+ 'AccountId, Account.Name, Account.Phone, Account.PersonEmail, '
										+ 'Account.PersonOtherStreet, Account.PersonOtherCountry, Account.PersonOtherState, '
										+ 'Account.PersonOtherCity, Account.PersonOtherPostalCode, Business_Entity_Name__c';
					String blWhereClause = 'Name LIKE \'' + String.escapeSingleQuotes(licenseNumber) + '\'';
					if (inputMap.containsKey(STEP_NAME_KEY)) {
						stepName = (String) inputMap.get(STEP_NAME_KEY); 
					}
					if (inputMap.containsKey(RAT_NAME_KEY)) {
						 
							blWhereClause += ' AND RegulatoryAuthorizationType.Name = \'' +
											String.escapeSingleQuotes(String.valueOf(inputMap.get(RAT_NAME_KEY))) + '\'';
						 
					}
					if (inputMap.containsKey(BLSTATUS_KEY)) {
						if (inputMap.containsKey(STATUS_OPERATOR) && String.isNotBlank((String)inputMap.get(STATUS_OPERATOR))) {
							statusOperator = (String) inputMap.get(STATUS_OPERATOR);
						}
						blWhereClause += ' AND  Status ' + String.escapeSingleQuotes(statusOperator) + ' \'' +
											String.escapeSingleQuotes(String.valueOf(inputMap.get(BLSTATUS_KEY))) + '\'';
					}
					if (inputMap.containsKey(BOARD_NAME_KEY)) {
						blWhereClause += ' AND RegulatoryAuthorizationType.IssuingDepartment.Name = \'' +
											String.escapeSingleQuotes(String.valueOf(inputMap.get(BOARD_NAME_KEY))) + '\'';
					}
					for (BusinessLicense bl : new LPI_BusinessLicenseDAO.LPI_BusinessLicenseWithoutSharingDAO()
												.getBusinessLicenseByDymanicQuery(blFields, blWhereClause, '10', null, null)) {
						Map<String, Object> tempMap = new Map<String, Object>();
						tempMap.put('Name', bl.Name);
						tempMap.put('BLName', bl.Name);
						tempMap.put('TypeAheadKeyName', bl.License_Number_With_Rat_Name__c);
						tempMap.put('TypeAheadKeyName1', bl.License_Number_With_Rat_Name__c);
						tempMap.put('StartDate', bl.PeriodStart);
						tempMap.put('HISBEHISRegSVHearSpecDate', bl.PeriodStart);
						tempMap.put('EndDate', bl.PeriodEnd);
						tempMap.put('IDExpiryDate', bl.PeriodEnd);
						tempMap.put('RATName', bl.RegulatoryAuthorizationType.Name);
						tempMap.put('BoardName', bl.RegulatoryAuthorizationType.IssuingDepartment.Name);
						tempMap.put('TypeaheadBusinessName1', bl.Business_Name__c);
						tempMap.put('TypeaheadBusinessName2', bl.Business_Name__c);
						 
						tempMapList.add(tempMap);
					}
					outMap.put('blData', tempMapList);
				}
			}
		} 
		catch (Exception e) {
			LPI_ExceptionManager.logException(CLASS_NAME, 'fetchBlDetails', e);
		}
	}

	/**
	 * @author                      : MTX Group Product Team
	 * @since                       : 08-05-2023
	 * @description                 : This method will fetch the records of BusinessLIcense object For Multiple RATs separated by @
	 * @param action                : String
	 * @param args			        : Map<String, Object> inputMap , Map<String, Object> outMap
	 * @return                      : void
	 * @last modified by            : MTX Group Product Team
	 * @last modified date          :
	 * @modified details            :
	 */
	public static void fetchBLForMultipleRATs(Map<String, Object> inputMap, Map<String, Object> outMap) {
		List<Map<String, Object>> tempMapList = new List<Map<String, Object>>();
		try {
			if (
				inputMap.containsKey(Search_Field_Name) &&
				String.isNotBlank(String.valueOf(inputMap.get(Search_Field_Name)))
			) {
				String statusOperator = '=';
				String blName = String.valueOf(inputMap.get(Search_Field_Name));
				if (blName.length() > 3) {
					String licenseNumber = '%' + blName + '%';
					if (
						inputMap.containsKey(RAT_NAME_KEY) &&
						String.isNotBlank(String.valueOf(inputMap.get(RAT_NAME_KEY)))
					) {
						String ratNames = String.escapeSingleQuotes(String.valueOf(inputMap.get(RAT_NAME_KEY)));
						List<String> ratNamesList = ratNames.split('@');
						String blFields = 'Id,Name, License_Number_With_Rat_Name__c, PeriodStart, PeriodEnd , RegulatoryAuthorizationType.Name,Business_Name__c';
						String whereClause = 'Name LIKE \'' + String.escapeSingleQuotes(licenseNumber) + '\'';
						whereClause =
							whereClause +
							' AND RegulatoryAuthorizationType.Name IN ' +
							LPI_ServiceUtility.getStringValuesByList(ratNamesList);
						if (
							inputMap.containsKey(BLSTATUS_KEY) &&
							String.isNotBlank(String.valueOf(inputMap.containsKey(BLSTATUS_KEY)))
						) {
							if (
								inputMap.containsKey(STATUS_OPERATOR) &&
								String.isNotBlank((String) inputMap.get(STATUS_OPERATOR))
							) {
								statusOperator = (String) inputMap.get(STATUS_OPERATOR);
							}
							whereClause =
								whereClause +
								' AND  Status ' +
								String.escapeSingleQuotes(statusOperator) +
								' \'' +
								String.escapeSingleQuotes(String.valueOf(inputMap.get(BLSTATUS_KEY))) +
								'\'';
						}
						for (
							BusinessLicense bl : LPI_BusinessLicenseDAO.fetchBusinessLicenseRecordsWithOrderByLimit(
								blFields,
								whereClause,
								'30',
								'Name'
							)
						) {
							Map<String, Object> tempmap = new Map<String, Object>();
							tempmap.put('Name', bl.Name);
							tempmap.put('TypeAheadKeyName', bl.License_Number_With_Rat_Name__c);
							tempMapList.add(tempmap);
						}
						outMap.put('blData', tempMapList);
					}
				}
			}
		} catch (Exception e) {
			LPI_ExceptionManager.logException(CLASS_NAME, 'fetchBlDetails', e);
		}
	}

	/**
	 * @author                      : MTX Group Product Team
	 * @since                       : 15-05-2023
	 * @description                 : This method will create Person Examination record (For Issue - I-193283)
	 * @param parId	                : String
	 * @return                      : void
	 * @last modified by            : MTX Group Product Team
	 * @last modified date          :
	 * @modified details            :
	 */
	private static void createJurisprudanceExamRecord(String parId) {
		String fieldToQuery =
			'Id, Contact__c, ' +
			'(Select Id, Name FROM Person_Examination__r WHERE Examination.Name = \'' +
			MISSOURI_JURIPRUDENCE_EXAM +
			'\')';
		String whereCaluse = 'Id = \'' + parId + '\'';
		List<PreliminaryApplicationRef> parList = LPI_PreliminaryApplicationRefDAO.getPreliminaryApplicationRefByDymanicQuery(
			fieldToQuery,
			whereCaluse,
			null,
			null,
			null
		);
		if (!parList.isEmpty() && parList[0].Person_Examination__r.isEmpty()) {
			fieldToQuery = 'Id';
			whereCaluse = 'Name = \'' + MISSOURI_JURIPRUDENCE_EXAM + '\'';
			List<Examination> examList = LPI_ExaminationDAO.getExaminationByDynamicQuery(
				fieldToQuery,
				whereCaluse,
				null,
				null,
				null
			);
			if (!examList.isEmpty()) {
				PersonExamination personExam = new PersonExamination();
				personExam.ContactId = parList[0].Contact__c;
				personExam.ExaminationId = examList[0].Id;
				personExam.Preliminary_Application_Reference__c = parId;
				LPI_DML.doInsert(personExam);
			}
		}
	}
}