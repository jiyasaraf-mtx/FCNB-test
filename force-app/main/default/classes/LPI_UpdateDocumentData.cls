/**
 * @description       : This class is used to retrive existing application document recod or document record with that it is also used to create documents.
 * @author            : Garvit Jain
 **/
global with sharing class LPI_UpdateDocumentData implements Callable {
	/**
	 * @description This Method is Used to Internally call the invokeMethod.
	 * @author Vamsi Mudaliar | 01-31-2023
	 * @param action
	 * @param args
	 * @return Object
	 **/
	global Object call(String action, Map<String, Object> args) {
		Map<String, Object> input = (Map<String, Object>) args.get('input');
		Map<String, Object> output = (Map<String, Object>) args.get('output');
		Map<String, Object> options = (Map<String, Object>) args.get('options');
		return invokeMethod(action, input, output, options);
	}
	/**
	 * @author            : Garvit Jain
	 * @description       : This Method is used to invoke methods from a omnistudio components.
	 * @param   methodName
	 * @param   inputMap
	 * @param   outMap
	 * @param   options
	 */
	private Boolean invokeMethod(
		String methodName,
		Map<String, Object> inputMap,
		Map<String, Object> outMap,
		Map<String, Object> options
	) {
		try {
			if (methodName == 'updateApplicationDocument') {
				updateApplicationDocument(
					(String) inputMap.get('parId'),
					(String) options.get('DocumentRequiredJSON')
				);
			}
			return true;
		} catch (Exception e) {
			LPI_ExceptionManager.logException('LPI_UpdateDocumentData', 'invokeMethod', e);
			throw new AuraHandledException(e.getStackTraceString());
		}
	}
	/**
	 * @author            : Garvit Jain
	 * @description       : This Method is used to update Application Document as required.
	 * @param parId
	 * @param DocumentRequiredJSON
	 */
	public static void updateApplicationDocument(String parId, String DocumentRequiredJSON) {
		try {
			if (String.isNotEmpty(DocumentRequiredJSON)) {
				Map<String, Object> docDataJson = (Map<String, Object>) JSON.deserializeUntyped(
					DocumentRequiredJSON
				);
				List<Application_Document__c> applicationDocumentToBeUpdatedList = new List<Application_Document__c>();
				String fieldsToQuery = 'Id,Is_Document_Required__c,Related_Element_Name__c, Document_Name__c';
				String whereClause =
					'Preliminary_Application_Reference__c = \'' +
					String.escapeSingleQuotes(parId) +
					'\' AND Related_Element_Name__c IN ' +
					LPI_ServiceUtility.getStringValuesByList(
						(List<String>) JSON.deserialize(JSON.serialize(docDataJson.keySet()), List<String>.class)
					);

				for (
					Application_Document__c applicationDocument : LPI_ApplicationDocumentDAO.getApplicantDocumentByDymanicQuery(
						fieldsToQuery,
						whereClause,
						null,
						null,
						null
					)
				) {
					if (
						applicationDocument.Is_Document_Required__c !=
						(Boolean) docDataJson.get(applicationDocument.Related_Element_Name__c)
					) {
						applicationDocument.Is_Document_Required__c = (Boolean) docDataJson.get(
							applicationDocument.Related_Element_Name__c
						);
						applicationDocumentToBeUpdatedList.add(applicationDocument);
					}
				}
				if (applicationDocumentToBeUpdatedList.size() > 0) {
					LPI_DML.doUpdate(applicationDocumentToBeUpdatedList);
				}
			}
		} catch (Exception e) {
			LPI_ExceptionManager.logException('LPI_UpdateDocumentData', 'updateApplicationDocument', e);
			throw new AuraHandledException(e.getStackTraceString());
		}
	}
}