/**
 * @description Builds PDF sections for FCNB applications (e.g. Real Estate Salesperson)
 * from PAR JSON fields and Form_Review_Config__mdt, matching the agent-review summary pattern.
 */
public with sharing class LPI_FCNBApplicationDataUtility {
	private static final String CONFIG_REAL_ESTATE = 'FCNBRealStateFCNB';
	private static final String FCNB_DEPT =
		'Financial and Consumer Services Commission of New Brunswick (FCNB)';

	/** Steps_Name__c custom-label token -> Form_Review_Config section key */
	private static final Map<String, String> STEP_TOKEN_TO_SECTION = new Map<String, String>{
		'LIC_LT_BlockLabel' => 'Licence',
		'LIC_StepLabel' => 'Licence',
		'AD_StepLabel' => 'ApplicantDetails',
		'ED_StepLabel' => 'Employment Details',
		'RLD_StepLabel' => 'RegulatoryLicensingDetails',
		'PJ_StepLabel' => 'ProceedingsJudgments',
		'AI_StepLabel' => 'AdditionalInformation'
	};

	/** Form_Review section key -> PAR long-text JSON field API name */
	private static final Map<String, String> SECTION_TO_PAR_FIELD = new Map<String, String>{
		'Licence' => 'Licence_Json__c',
		'ApplicantDetails' => 'Applicant_Details_json__c',
		'Employment Details' => 'Employement_json__c',
		'RegulatoryLicensingDetails' => 'Regulatory_licensing_json__c',
		'ProceedingsJudgments' => 'Proceedings_Judgments_json__c',
		'AdditionalInformation' => 'Additional_Info_json__c',
		'Expedited Service' => 'Expedited_Service_json__c'
	};

	/**
	 * @description Whether this PAR should use FCNB JSON-driven PDF sections.
	 */
	public static Boolean isFCNBApplication(PreliminaryApplicationRef parRecord) {
		return parRecord != null &&
			parRecord.Regulatory_Authorization_Type__r != null &&
			parRecord.Regulatory_Authorization_Type__r.IssuingDepartment != null &&
			parRecord.Regulatory_Authorization_Type__r.IssuingDepartment.Name == FCNB_DEPT;
	}

	/**
	 * @description Builds ordered PDF sections from FCNB PAR JSON + review config labels.
	 */
	public static List<LPI_PDFSectionWrapper> getSectionList(
		PreliminaryApplicationRef parRecord,
		Account accRecord,
		Set<String> appFlowSteps
	) {
		List<LPI_PDFSectionWrapper> sectionList = new List<LPI_PDFSectionWrapper>();
		if (parRecord == null || parRecord.Id == null) {
			return sectionList;
		}

		try {
			PreliminaryApplicationRef parWithJson = queryParJson(parRecord.Id);
			if (parWithJson == null) {
				return sectionList;
			}

			Map<String, Object> labelConfig = loadLabelConfig(CONFIG_REAL_ESTATE);
			List<String> orderedSteps = resolveOrderedSteps(parRecord, appFlowSteps);

			sectionList.add(LPI_ApplicationDataUtility.getLicenseSection(parRecord));

			Set<String> addedSections = new Set<String>();
			for (String stepToken : orderedSteps) {
				if (stepToken == 'License' || stepToken == 'DOC_StepLabel' || stepToken == 'Documents') {
					continue;
				}
				String sectionKey = STEP_TOKEN_TO_SECTION.get(stepToken);
				if (String.isBlank(sectionKey) || addedSections.contains(sectionKey)) {
					continue;
				}
				String fieldApi = SECTION_TO_PAR_FIELD.get(sectionKey);
				if (String.isBlank(fieldApi)) {
					continue;
				}
				String jsonStr = (String) parWithJson.get(fieldApi);
				if (String.isBlank(jsonStr)) {
					continue;
				}

				Object sectionData = JSON.deserializeUntyped(jsonStr);
				Map<String, Object> sectionLabels = getSectionLabelMap(labelConfig, sectionKey);
				String sectionTitle = resolveSectionTitle(sectionLabels, sectionKey, stepToken);

				List<LPI_PDFSectionWrapper.DataWrapper> dataList = new List<LPI_PDFSectionWrapper.DataWrapper>();
				flattenNode(sectionData, sectionLabels, dataList, null);

				if (!dataList.isEmpty()) {
					sectionList.add(new LPI_PDFSectionWrapper(sectionTitle, 2, dataList));
					addedSections.add(sectionKey);
				}
			}

			if (
				appFlowSteps != null &&
				(appFlowSteps.contains('DOC_StepLabel') ||
				appFlowSteps.contains('Documents') ||
				appFlowSteps.contains(LPI_ApplicationDataUtility.DOCUMENTS_STEP))
			) {
				sectionList.add(LPI_ApplicationDataUtility.getDocumentSection(parRecord.Id));
			}
		} catch (Exception e) {
			LPI_ExceptionManager.logException('LPI_FCNBApplicationDataUtility', 'getSectionList', e);
			throw new LPI_Exception(e.getMessage() + e.getLineNumber());
		}
		return sectionList;
	}

	private static PreliminaryApplicationRef queryParJson(Id parId) {
		List<PreliminaryApplicationRef> rows = [
			SELECT
				Id,
				Licence_Json__c,
				Applicant_Details_json__c,
				Employement_json__c,
				Regulatory_licensing_json__c,
				Proceedings_Judgments_json__c,
				Additional_Info_json__c,
				Expedited_Service_json__c
			FROM PreliminaryApplicationRef
			WHERE Id = :parId
			LIMIT 1
		];
		return rows.isEmpty() ? null : rows[0];
	}

	private static Map<String, Object> loadLabelConfig(String developerName) {
		List<Form_Review_Config__mdt> configs = [
			SELECT Label_JSON__c
			FROM Form_Review_Config__mdt
			WHERE DeveloperName = :developerName
			LIMIT 1
		];
		if (configs.isEmpty() || String.isBlank(configs[0].Label_JSON__c)) {
			return new Map<String, Object>();
		}
		try {
			Object parsed = JSON.deserializeUntyped(configs[0].Label_JSON__c);
			return parsed instanceof Map<String, Object>
				? (Map<String, Object>) parsed
				: new Map<String, Object>();
		} catch (Exception e) {
			return new Map<String, Object>();
		}
	}

	private static List<String> resolveOrderedSteps(
		PreliminaryApplicationRef parRecord,
		Set<String> appFlowSteps
	) {
		List<String> ordered = new List<String>();
		if (parRecord.Steps_Name__c != null) {
			for (String step : parRecord.Steps_Name__c.split(';')) {
				if (String.isNotBlank(step)) {
					ordered.add(step.trim());
				}
			}
		} else if (appFlowSteps != null) {
			ordered.addAll(appFlowSteps);
		}
		return ordered;
	}

	private static Map<String, Object> getSectionLabelMap(
		Map<String, Object> labelConfig,
		String sectionKey
	) {
		if (labelConfig == null || !labelConfig.containsKey(sectionKey)) {
			return new Map<String, Object>();
		}
		Object sectionObj = labelConfig.get(sectionKey);
		return sectionObj instanceof Map<String, Object>
			? (Map<String, Object>) sectionObj
			: new Map<String, Object>();
	}

	private static String resolveSectionTitle(
		Map<String, Object> sectionLabels,
		String sectionKey,
		String stepToken
	) {
		if (sectionLabels != null && sectionLabels.containsKey('_sectionTitle')) {
			return String.valueOf(sectionLabels.get('_sectionTitle'));
		}
		try {
			String fromLabel = System.Label.get('', stepToken, 'en_US');
			if (String.isNotBlank(fromLabel) && fromLabel != stepToken) {
				return fromLabel;
			}
		} catch (Exception e) {
			// fall through
		}
		return sectionKey;
	}

	/**
	 * Recursively flattens OmniScript JSON into label/value pairs for the PDF.
	 */
	private static void flattenNode(
		Object node,
		Map<String, Object> labels,
		List<LPI_PDFSectionWrapper.DataWrapper> dataList,
		String parentBlockTitle
	) {
		if (node == null) {
			return;
		}

		if (node instanceof List<Object>) {
			Integer i = 1;
			for (Object item : (List<Object>) node) {
				String itemTitle = String.isNotBlank(parentBlockTitle)
					? parentBlockTitle + ' #' + i
					: 'Item #' + i;
				dataList.add(new LPI_PDFSectionWrapper.DataWrapper(itemTitle, ''));
				flattenNode(item, labels, dataList, parentBlockTitle);
				i++;
			}
			return;
		}

		if (!(node instanceof Map<String, Object>)) {
			return;
		}

		Map<String, Object> dataMap = (Map<String, Object>) node;
		List<String> keys = new List<String>(dataMap.keySet());
		keys.sort();

		// Prefer config order when available
		List<String> orderedKeys = orderKeysByConfig(keys, labels);

		for (String key : orderedKeys) {
			if (key == null || key.startsWith('_')) {
				continue;
			}
			Object value = dataMap.get(key);
			if (value == null) {
				continue;
			}

			Object labelDef = labels != null ? labels.get(key) : null;

			if (value instanceof Map<String, Object> || value instanceof List<Object>) {
				String blockTitle = resolveBlockTitle(labelDef, key);
				Map<String, Object> childLabels = labelDef instanceof Map<String, Object>
					? (Map<String, Object>) labelDef
					: labels;
				if (String.isNotBlank(blockTitle) && blockTitle != key) {
					dataList.add(new LPI_PDFSectionWrapper.DataWrapper(blockTitle, ''));
				}
				flattenNode(value, childLabels, dataList, blockTitle);
			} else {
				String fieldLabel = resolveFieldLabel(labelDef, key);
				String fieldValue = formatFieldValue(value);
				if (String.isNotBlank(fieldValue)) {
					dataList.add(new LPI_PDFSectionWrapper.DataWrapper(fieldLabel, fieldValue));
				}
			}
		}
	}

	private static List<String> orderKeysByConfig(List<String> keys, Map<String, Object> labels) {
		if (labels == null || labels.isEmpty()) {
			return keys;
		}
		Map<Integer, List<String>> byOrder = new Map<Integer, List<String>>();
		List<String> unordered = new List<String>();
		for (String key : keys) {
			Object labelDef = labels.get(key);
			Integer orderVal = null;
			if (labelDef instanceof Map<String, Object>) {
				Map<String, Object> defMap = (Map<String, Object>) labelDef;
				if (defMap.containsKey('_order')) {
					try {
						orderVal = Integer.valueOf(String.valueOf(defMap.get('_order')));
					} catch (Exception e) {
						orderVal = null;
					}
				}
			}
			if (orderVal != null) {
				if (!byOrder.containsKey(orderVal)) {
					byOrder.put(orderVal, new List<String>());
				}
				byOrder.get(orderVal).add(key);
			} else {
				unordered.add(key);
			}
		}
		List<Integer> orderKeys = new List<Integer>(byOrder.keySet());
		orderKeys.sort();
		List<String> result = new List<String>();
		for (Integer o : orderKeys) {
			result.addAll(byOrder.get(o));
		}
		result.addAll(unordered);
		return result;
	}

	private static String resolveBlockTitle(Object labelDef, String key) {
		if (labelDef instanceof Map<String, Object>) {
			Map<String, Object> defMap = (Map<String, Object>) labelDef;
			if (defMap.containsKey('_blockTitle')) {
				return String.valueOf(defMap.get('_blockTitle'));
			}
			if (defMap.containsKey('label')) {
				return String.valueOf(defMap.get('label'));
			}
		} else if (labelDef instanceof String) {
			return String.valueOf(labelDef);
		}
		return key;
	}

	private static String resolveFieldLabel(Object labelDef, String key) {
		if (labelDef instanceof Map<String, Object>) {
			Map<String, Object> defMap = (Map<String, Object>) labelDef;
			if (defMap.containsKey('label')) {
				return String.valueOf(defMap.get('label'));
			}
		} else if (labelDef instanceof String) {
			return String.valueOf(labelDef);
		}
		return key;
	}

	private static String formatFieldValue(Object value) {
		if (value == null) {
			return '';
		}
		if (value instanceof Boolean) {
			return (Boolean) value ? 'Yes' : 'No';
		}
		String strVal = String.valueOf(value).trim();
		if (String.isBlank(strVal) || strVal.equalsIgnoreCase('null')) {
			return '';
		}
		// Resolve Custom Label API names stored as option values (e.g. COM_Opt_Yes)
		if (strVal.contains('_') && !strVal.contains(' ')) {
			try {
				String translated = System.Label.get('', strVal, 'en_US');
				if (String.isNotBlank(translated) && translated != strVal) {
					return translated;
				}
			} catch (Exception e) {
				// keep raw value
			}
		}
		return strVal;
	}
}