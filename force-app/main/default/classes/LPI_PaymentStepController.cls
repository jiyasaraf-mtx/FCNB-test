/**
 *
 * @author          :MTX Group Product Team
 * @Description     : This class is a controller class that we are calling from payment step
 * @history         :
 * -------------------------------------------------------------------------------------------------------
 * Version      Date                Author                  Details
 *    1         23 March, 2023      MTX Group Product Team             Initial Developement
 * -------------------------------------------------------------------------------------------------------
 */
global with sharing class LPI_PaymentStepController implements Callable {
	public final static String SAVE_STEP_NAME = 'SaveStepInformation';
	public final static String INVOKE_METHOD = 'InvokeMethod';
	public final static String CLASS_NAME = 'LPI_PaymentStepController';
	public final static String INSTRUCTIONS_STEP = 'Instructions';
	public final static String JURIPRUDENCE_EXAM_STEP = 'Jurisprudence Examination';
	public final static String ATTESTATION_STEP = 'Attestation';
	public final static Set<String> STEP_LABEL_SET = new Set<String>{
		'License Questions',
		'Evaluation of Applicant/Supervisee',
		'Faculty to Student Ratio'
	};
	public final static Set<String> APPROVER_ATTESTATION_STEPS = new Set<String>{
		'Supervisor Attestation',
		'Approver Attestation'
	};
	/**
	 * @author                      : MTX Group Product Team
	 * @since                       : march 23,2023
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
	 * @since                       : march 23,2023
	 * @description                 : This method calls all other method besed on method name method
	 * @param methodName            : String
	 * @param inputMap			    : Map<String, Object>
	 * @param outMap			    : Map<String, Object>
	 * @param options			    : Map<String, Object>
	 * @return                      : Boolean
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
		try {
			if (methodName == SAVE_STEP_NAME) {
				saveStepInformation(inputMap, outMap);
			}
		} catch (Exception e) {
			LPI_ExceptionManager.logException(CLASS_NAME, INVOKE_METHOD, e);
			throw new LPI_Exception(CLASS_NAME, e);
		}

		return true;
	}

	/**
	 * @author                      : MTX Group Product Team
	 * @since                       : March 23, 2023
	 * @description                 : This method will save the name of steps on PAR record
	 * @param inputMap              : Map<String, Object>
	 * @param outMap			    : Map<String, Object>
	 * @return                      : Object
	 * @last modified by            : MTX Group Product Team
	 * @last modified date          :
	 * @modified details            :
	 */
	public static void saveStepInformation(Map<String, Object> inputMap, Map<String, Object> outMap) {
		String omniProcessId = (String) inputMap.get('omniProcessId');
		String parId = (String) inputMap.get('parid');
		Boolean isStudentApproval = (Boolean) inputMap.get('isStudentApproval');
		Boolean isSkipPayment = isSkipPaymentSelected(inputMap);

		List<PreliminaryApplicationRef> parList = LPI_PreliminaryApplicationRefDAO.getPreliminaryApplicationRefByDymanicQuery(
			'Id, Steps_Name__c,Type__c, Regulatory_Authorization_Type__r.Name',
			' Id =\'' + String.escapeSingleQuotes(parId) + '\'',
			null,
			null,
			null
		);

		if (String.IsNotBlank(omniProcessId) && String.IsNotBlank(parId)) {
			List<StepWrapper> stepWrapperList = getStepNameWithLabel(omniProcessId);
			if (stepWrapperList.isEmpty()) {
				if (isSkipPayment) {
					markRegulatoryTransactionFeeUnpaid(parId);
				}
				return;
			}
			Set<String> stepLabelSet = new Set<String>();
			PreliminaryApplicationRef parRecord = new PreliminaryApplicationRef(Id = parId);

			for (StepWrapper step : stepWrapperList) {
				Map<String, Object> stepDataMap = inputMap.containsKey(step.stepName) &&
					inputMap.get(step.stepName) != null
					? (Map<String, Object>) inputMap.get(step.stepName)
					: null;
				Boolean addStepNameInList = (step.stepLabel == INSTRUCTIONS_STEP)
					? stepDataMap != null && !stepDataMap.isEmpty()
					: stepDataMap != null;

				if (addStepNameInList) {
					stepLabelSet.add(step.stepLabel);
					Map<String, String> stepInfoMap = new Map<String, String>{
						'stepName' => step.stepName,
						'osName' => step.osName
					};
					if (STEP_LABEL_SET.contains(step.stepLabel)) {
						parRecord.License_Questions_Step_API_Name__c = JSON.serialize(stepInfoMap);

					}
					else if (step.stepLabel == JURIPRUDENCE_EXAM_STEP) {
						parRecord.Jurisprudence_Examination_Step_API_Name__c = JSON.serialize(stepInfoMap);

					} else if (step.stepLabel == ATTESTATION_STEP) {
						parRecord.Attestation_Step_API_Name__c = JSON.serialize(stepInfoMap);
						parRecord.Attestation_Data__c = JSON.serialize(inputMap.get(step.stepName));
						
					}
				}
			}
			if (isStudentApproval != null && isStudentApproval) {
				if (!parList.isEmpty()) {
					if (parList[0].Steps_Name__c == null) {
						parRecord.Steps_Name__c = String.join(new List<String>(stepLabelSet), ';');
					} else {
						Set<String> stepSet = new Set<String>(String.valueOf(parList[0].Steps_Name__c).split(';'));
						stepSet.addAll(stepLabelSet);
						parRecord.Steps_Name__c = String.join(new List<String>(stepSet), ';');
					}
				}
			} else {
				parRecord.Steps_Name__c = String.join(new List<String>(stepLabelSet), ';');
			}
			if (parRecord != null) {
				LPI_DML.doUpdate(parRecord);
			}
		}
		if (isSkipPayment && String.isNotBlank(parId)) {
			markRegulatoryTransactionFeeUnpaid(parId);
		}
	}

	/**
	 * @description When skipPayment is true from IndividualInsurancePayment, ensure related
	 *              Regulatory Transaction Fee records remain unpaid (Status = Due).
	 * @param parId Preliminary Application Ref Id
	 */
	public static void markRegulatoryTransactionFeeUnpaid(String parId) {
		if (String.isBlank(parId)) {
			return;
		}
		Set<Id> parentRecordIds = new Set<Id>();
		List<IndividualApplication> iaList = new LPI_IndividualApplicationDAO.LPI_DAO_IndividualApptWithoutSecurity()
			.getILABySavedAppRefId(new Set<Id>{ parId });
		for (IndividualApplication ia : iaList) {
			parentRecordIds.add(ia.Id);
		}
		List<BusinessLicenseApplication> blaList = new LPI_BusinessLicenseApplicationDAO.LPI_DAO_BusinessLiceWithoutSecurity()
			.getBLABySavedAppRefId(new Set<Id>{ parId });
		for (BusinessLicenseApplication bla : blaList) {
			parentRecordIds.add(bla.Id);
		}
		if (parentRecordIds.isEmpty()) {
			return;
		}
		List<RegulatoryTrxnFee> rtfList = LPI_RegulatoryTrxnFeeDAO.getRegulatoryTrxnFeeByDymanicQuery(
			'Id, Status, Status__c',
			'ParentRecordId IN ' + LPI_ServiceUtility.getStringValuesBySet(parentRecordIds),
			null,
			null,
			null
		);
		if (rtfList.isEmpty()) {
			return;
		}
		List<RegulatoryTrxnFee> rtfToUpdate = new List<RegulatoryTrxnFee>();
		for (RegulatoryTrxnFee rtf : rtfList) {
			if (rtf.Status != 'Due' || rtf.Status__c != 'Payment Pending') {
				rtf.Status = 'Due';
				rtf.Status__c = 'Payment Pending';
				rtfToUpdate.add(rtf);
			}
		}
		if (!rtfToUpdate.isEmpty()) {
			LPI_WithoutSharingUtility.updateSObjectList(rtfToUpdate);
		}
		List<SObject> appsToUpdate = new List<SObject>();
		for (IndividualApplication ia : iaList) {
			appsToUpdate.add(new IndividualApplication(Id = ia.Id, Payment_Pending__c = true));
		}
		for (BusinessLicenseApplication bla : blaList) {
			appsToUpdate.add(new BusinessLicenseApplication(Id = bla.Id, Payment_Pending__c = true));
		}
		if (!appsToUpdate.isEmpty()) {
			LPI_WithoutSharingUtility.updateSObjectList(appsToUpdate);
		}
	}

	/**
	 * @author                      : MTX Group Product Team
	 * @since                       : 23 March, 2023
	 * @description                 : This method will return the list of StepWrapper
	 * @param omniProcessId         : String
	 * @return                      : List<StepWrapper>
	 * @last modified by            : MTX Group Product Team
	 * @last modified date          :
	 * @modified details            :
	 */
	public static List<StepWrapper> getStepNameWithLabel(String omniProcessId) {
		String fieldToQuery =
			'Id,Name,Type,level,SequenceNumber,ParentElementName,PropertySetConfig,OmniProcess.Name,' +
			'EmbeddedOmniScriptKey,OmniProcess.Type,OmniProcess.SubType';
		string whereClause =
			'OmniProcessId = \'' +
			omniProcessId +
			'\'' +
			' AND OmniProcess.IsActive = TRUE' +
			' AND isActive = true' +
			' AND Type IN ' +
			LPI_ServiceUtility.getStringValuesByStringSet(new Set<String>{ 'OmniScript', 'Step' });
		string sortingByFields = 'Level, SequenceNumber';

		List<OmniProcessElement> topLevelElements = LPI_OmniProcessElementDAO.getOmniProcessElementByDymanicQuery(
			fieldToQuery,
			whereClause,
			null,
			sortingByFields,
			null
		);

		Set<String> omniscriptNames = new Set<String>();
		Set<String> typeset = new Set<String>();
		Set<String> subTypeset = new Set<String>();
		for (OmniProcessElement element : topLevelElements) {
			if (element.Type == 'OmniScript') {
				List<String> keyList = element.EmbeddedOmniScriptKey.split('\\|');
				typeset.add(keyList[0]);
				subTypeset.add(keyList[1]);
			}
		}

		Map<String, List<StepWrapper>> parentToStepListMap = new Map<String, List<StepWrapper>>();
		List<StepWrapper> result = new List<StepWrapper>();
		if (!typeset.isEmpty() && !subTypeset.isEmpty()) {
			whereClause =
				'OmniProcess.Type IN ' +
				LPI_ServiceUtility.getStringValuesByStringSet(typeset) +
				' AND OmniProcess.SubType IN ' +
				LPI_ServiceUtility.getStringValuesByStringSet(subTypeset) +
				' AND OmniProcess.IsActive = TRUE' +
				' AND isActive = true' +
				' AND Type IN ' +
				LPI_ServiceUtility.getStringValuesByStringSet(new Set<String>{ 'Step' });
			List<OmniProcessElement> omniscriptsSteps = LPI_OmniProcessElementDAO.getOmniProcessElementByDymanicQuery(
				fieldToQuery,
				whereClause,
				null,
				sortingByFields,
				null
			);
			for (OmniProcessElement step : omniscriptsSteps) {
				String embeddedKey = step.OmniProcess.Type + '|' + step.OmniProcess.SubType + '|' + 'English';
				if (!parentToStepListMap.containsKey(embeddedKey)) {
					parentToStepListMap.put(embeddedKey, new List<StepWrapper>());
				}

				parentToStepListMap.get(embeddedKey).add(new StepWrapper(step));
			}
		}

		for (OmniProcessElement parentElem : topLevelElements) {
			if (parentElem.Type == 'Step') {
				result.add(new StepWrapper(parentElem));
			} else if (parentToStepListMap.containsKey(parentElem.EmbeddedOmniScriptKey)) {
				result.addAll(parentToStepListMap.get(parentElem.EmbeddedOmniScriptKey));
			}
		}
		return result;
	}

	/**
	 * IndividualInsurancePayment radio: skipPayment = yes | no (legacy true | false also supported).
	 */
	private static Boolean isSkipPaymentSelected(Map<String, Object> inputMap) {
		if (inputMap == null) {
			return false;
		}
		Object skipVal = inputMap.get('skipPayment');
		if (skipVal == null && inputMap.get('Payment') instanceof Map<String, Object>) {
			Map<String, Object> paymentStep = (Map<String, Object>) inputMap.get('Payment');
			skipVal = paymentStep.get('skipPayment');
			if (skipVal == null && paymentStep.get('Block2') instanceof Map<String, Object>) {
				skipVal = ((Map<String, Object>) paymentStep.get('Block2')).get('skipPayment');
			}
		}
		if (skipVal == null) {
			return false;
		}
		if (skipVal instanceof Boolean) {
			return (Boolean) skipVal;
		}
		String skipPaymentStr = String.valueOf(skipVal).trim();
		return String.isNotBlank(skipPaymentStr) &&
			(skipPaymentStr.equalsIgnoreCase('yes') || skipPaymentStr.equalsIgnoreCase('true'));
	}

	/**
	 * @author                      : MTX Group Product Team
	 * @since                       : March 23, 2023
	 * @description                 : This is a wrapper class to store the name of step info
	 * @last modified by            : MTX Group Product Team
	 * @last modified date          :
	 * @modified details            :
	 */
	public class StepWrapper {
		public String stepName;
		public String stepLabel;
		public String osName;

		public StepWrapper(OmniProcessElement step) {
			this.stepName = step.Name;
			this.osName = step.OmniProcess.Name;
			Map<String, Object> deserializedValueMap = (Map<String, Object>) JSON.deserializeUntyped(
				String.valueOf(step.PropertySetConfig)
			);
			this.stepLabel = deserializedValueMap.containsKey('label')
				? String.valueOf(deserializedValueMap.get('label'))
				: '';
		}
	}
}