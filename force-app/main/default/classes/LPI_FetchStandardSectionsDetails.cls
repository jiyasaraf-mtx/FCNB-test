/**
 * @author          : Vamshi Kumar
 * @description     : This class fetch Standard section details
 * * @history
 * -------------------------------------------------------------------------------------------------------
 * Version      Date                Author                  Details
 *    1         16 Jan, 2023        Vamshi Kumar         Initial Developement
 *    2         26 Jan, 2023        Vamshi Kumar         Added DAO classes in place of queries
 * -------------------------------------------------------------------------------------------------------
 */
global with sharing class LPI_FetchStandardSectionsDetails implements Callable {
	// ******************************** ALL CONSTANT **************************************************************************************
	public final static String GET_TAX_COMPLIANCE_DETAILS = 'getTaxComplianceDetails';
	// ************************************************************************************************************************************
	global Object call(String action, Map<String, Object> args) {
		Map<String, Object> input = (Map<String, Object>) args.get('input');
		Map<String, Object> output = (Map<String, Object>) args.get('output');
		Map<String, Object> options = (Map<String, Object>) args.get('options');
		return invokeMethod(action, input, output, options);
	}
	/**
	 * @author               : Vamshi Kumar
	 * @param methodName     : invokeMethod
	 * @param inputMap       : Input Parameter Passed from Omniscript
	 * @param outMap         : Output Passed to Omniscript
	 * @param options        : Extra Options passed from Omniscript
	 * @created date		     : 16 Jan, 2023
	 * @last modified by     : Ayush Dev
	 * @last modified date   :
	 * @modified details     :
	 * @return  `Boolean`
	 */
	private Boolean invokeMethod(
		String methodName,
		Map<String, Object> inputMap,
		Map<String, Object> outMap,
		Map<String, Object> options
	) {
		try {
			if (methodName == GET_TAX_COMPLIANCE_DETAILS) {
				outMap.put('taxcompliancedetails', getTaxComplianceDetails(inputMap));
			}
			return true;
		} catch (Exception e) {
			LPI_ExceptionManager.logException('LPI_FetchStandardSectionsDetails', 'invokeMethod', e);
			return false;
		}
	}
	/**
	 * @author          	: Vamshi Kumar
	 * @param inputMap  	: fetching all the input from Omniscript
	 * @param outMap    	: Passing value to Omniscript
	 * @param options   	: Passing Options to Omniscript if needed
	 * @description     	: This method is used to get Tax Compliance Details
	 * @created date		: 16 Jan 2022
	 * @last modified by    : Ayush Dev
	 * @last modified date  :
	 * @modified details    :
	 */
	public static Map<String, String> getTaxComplianceDetails(Map<String, Object> inputMap) {
		Map<String, String> questionDetails;
		try {
			String recordid = (String) inputMap.get('parid');
			questionDetails = new Map<String, String>();
			List<PreliminaryApplicationRef> parList;
			PreliminaryApplicationRef par;
			String fields;
			String whereClause;
			if (String.isNotEmpty(recordid)) {
				fields = 'Tax_Compliance__c';
				whereClause = 'Id =\'' + String.escapeSingleQuotes(recordid) + '\'';
				parList = LPI_PreliminaryApplicationRefDAO.getPreliminaryApplicationRefByDymanicQuery(
					fields,
					whereClause,
					null,
					null,
					null
				);
				if (!parList.isEmpty()) {
					par = parList[0];
				}
			}
			if (par != null && par.get(LPI_LiteralConstant.TAX_COMPLIANCE) != null) {
				Map<String, Object> deserialized = (Map<String, Object>) JSON.deserializeUntyped(
					String.valueOf(par.get(LPI_LiteralConstant.TAX_COMPLIANCE))
				);
				for (String values : deserialized.keySet()) {
					questionDetails.put(
						values,
						deserialized.get(values) != null ? String.valueOf(deserialized.get(values)) : null
					);
				}
			}
		} catch (Exception e) {
			LPI_ExceptionManager.logException('LPI_FetchStandardSectionsDetails', 'getTaxComplianceDetails', e);
		}
		return questionDetails;
	}
}