/**
 * @description       :
 * @author            : MTX Group Product Team
 * @group             :
 * @last modified on  : 07-26-2024
 * @last modified by  : MTX Group Product Team
 **/
global with sharing class LPI_IntakeApplicationController implements Callable {
    private static final String CLASS_NAME = 'LPI_IntakeApplicationController';
	private static final String METHOD_CREATE_PAR_RECORD = 'createPARRecord';
	private static final String METHOD_GET_UPDATED_DOCUMENTS = 'getUploadedDocuments';
	private static final String METHOD_SET_ACTION_ALLOWED_VALIDATION = 'setActionAllowedValidation';
	private static final String APPLICATION_DOCUMENT_INFO = 'applicationDocumentInfo';
	private static final String PAR_ID = 'parid';
    private static final String BLA_ERROR = 'blaError';
    private static final String REGAUTH_ID = 'regauthid';
    private static final String INTAKE_LINK = 'intakeLink';
    private static final String CONTENT_DOCUMENT_ID = 'contentDocumentId';
    private static final String FILE_NAME = 'fileName';
	private static final String DOCUMENT_NAME = 'DocumentName';
	private static final String SH_DOWN_BUTTON = 'shDownBtn';
	private static final String DOWNLOAD_LINK = 'DownloadLink';
	private static final String DOWNLOAD_URL = '/sfc/servlet.shepherd/document/download/';
	private static final String NOT_SUBMITTED = 'Not-Submitted';
    private static final String IS_ACTION_ALLOWED = 'isActionAllowed';

	global Object call(String action, Map<String, Object> args) {
		Map<String, Object> input = (Map<String, Object>) args.get(LPI_LiteralConstant.INPUT);
		Map<String, Object> output = (Map<String, Object>) args.get(LPI_LiteralConstant.OUTPUT);
		Map<String, Object> options = (Map<String, Object>) args.get(LPI_LiteralConstant.OPTIONS);
		return invokeMethod(action, input, output, options);
	}

	/**
	 * @author                         : MTX Group Product Team
	 * @since                          : 3 Nov, 2022
	 * @description                    : This method is returing true if its successfully invoked
	 * @param methodName               : Remote action Method name
	 * @param inputMap                 : Map Of input param
	 * @param outMap                   : Map Of output param
	 * @param options                  : Map Of options
	 * @return                         : Boolean
	 * @last modified by               : MTX Group Product Team
	 * @last modified date             : 17 Jan, 2023
	 * @last modified details          : Convert all if conditions to if-else conditions
	 */
	private Boolean invokeMethod(
		String methodName,
		Map<String, Object> inputMap,
		Map<String, Object> outMap,
		Map<String, Object> options
	) {
		if (METHOD_CREATE_PAR_RECORD.equalsIgnoreCase(methodName)) {
			return createPARRecord(inputMap, outMap, options);
		} else if (METHOD_GET_UPDATED_DOCUMENTS.equalsIgnoreCase(methodName)) {
			outMap.put(APPLICATION_DOCUMENT_INFO, getUploadedDocuments((String) options.get(PAR_ID)));
		} else if (METHOD_SET_ACTION_ALLOWED_VALIDATION.equalsIgnoreCase(methodName)) {
			return setActionAllowedValidation(inputMap, outMap, options);
		}
		return true;
	}

	/**
	 * @author                         : MTX Group Product Team
	 * @since                          : 3 Nov, 2022
	 * @description                    : This method is used for creating PAR record onclick Apply Online on portal
	 * @param inputMap                 : Map Of input param
	 * @param outMap                   : Map Of output param
	 * @param options                  : Map Of options
	 * @return                         : Boolean
	 * @last modified by               : MTX Group Product Team
	 * @last modified date             : 17 Jan, 2023
	 * @last modified details          : Move queries to respective DAO classes, replace DML statement to
	 *                                   MODPR_DML methods and removed static Strings
	 */
	private static Boolean createPARRecord(
		Map<String, Object> inputMap,
		Map<String, Object> outMap,
		Map<String, Object> options
	) {
        try {
            Map<String,Object> resultMap = LPI_ApplicationFlowUtility.createPARRecord(inputMap,outMap);
            if(resultMap != null){
                return true;
            }   
            return false;
		} catch (Exception exceptionInstance) {
			outMap.put(BLA_ERROR, exceptionInstance.getStackTraceString());
			LPI_ExceptionManager.logException(CLASS_NAME, METHOD_CREATE_PAR_RECORD, exceptionInstance);
			return false;
		}
	}

	/**
	 * @author                         : MTX Group Product Team
	 * @since                          : 3 Nov, 2022
	 * @description                    : Method used to retrieve the doc uploaded on previous and current step on portal
	 * @param parId                    : PreliminaryApplicationRef record id
	 * @return                         : Boolean
	 * @last modified by               : MTX Group Product Team
	 * @last modified date             : Rachna Jadam
	 * @last modified details          : Move queries to respective DAO classes, replace DML statement to
	 *                                   MODPR_DML methods and removed static Strings
	 */
	@AuraEnabled
	public static List<Map<String, String>> getUploadedDocuments(String parId) {
		List<Map<String, String>> listOfStatusToCount = new List<Map<String, String>>();
		try {
			List<PreliminaryApplicationRef> parlist = LPI_PreliminaryApplicationRefDAO.getPARRecordsByID(
				new Set<Id>{ parId }
			);
            if(parlist.isEmpty()) {
                return null;
            }
			Map<Id, Application_Document__c> applicationDocumentList = LPI_ApplicationDocumentDAO.getApplicationDocumentMapByPARIdAndType(
				new Set<Id>{ parId },
				parlist?.get(0)?.Type__c
			);
			if (applicationDocumentList.isEmpty()) {
				return null;
			}
			List<ContentDocumentLink> contentDocumentLinkList = LPI_ContentDocumentLinkDAO.getContentDocumentLinkByLinkedEntityIds(
				applicationDocumentList.keySet()
			);
			Map<Id, Id> mapOfContentDocumentIdToLinkedEntitytId = new Map<Id, Id>();
			Map<Id, Id> mapOfApplicationDocumentIdToContentDocumentId = new Map<Id, Id>();
			for (ContentDocumentLink contentDocuLink : contentDocumentLinkList) {
				mapOfContentDocumentIdToLinkedEntitytId.put(
					contentDocuLink.ContentDocumentId,
					contentDocuLink.LinkedEntityId
				);
				mapOfApplicationDocumentIdToContentDocumentId.put(
					contentDocuLink.LinkedEntityId,
					contentDocuLink.ContentDocumentId
				);
			}
			List<ContentVersion> contentVersionList = LPI_ContentVersionDAO.getContentVersionsByContentDocumentIds(
				mapOfContentDocumentIdToLinkedEntitytId.keySet()
			);
			Map<Id, List<ContentVersion>> mapOfContentDocumentIdToContentVersionList = new Map<Id, List<ContentVersion>>();
			for (ContentVersion conVersion : contentVersionList) {
				if (!mapOfContentDocumentIdToContentVersionList.containsKey(conVersion.contentDocumentId)) {
					mapOfContentDocumentIdToContentVersionList.put(
						conVersion.ContentDocumentId,
						new List<ContentVersion>()
					);
				}
				mapOfContentDocumentIdToContentVersionList.get(conVersion.ContentDocumentId).add(conVersion);
			}
			for (Application_Document__c appDocument : applicationDocumentList.values()) {
				if (mapOfApplicationDocumentIdToContentDocumentId.get(appDocument.Id) != null) {
					Map<String, String> tempMap = new Map<String, String>();
					tempMap.put(CONTENT_DOCUMENT_ID, mapOfApplicationDocumentIdToContentDocumentId.get(appDocument.Id));
					List<ContentVersion> tempContent = mapOfContentDocumentIdToContentVersionList.get(
						mapOfApplicationDocumentIdToContentDocumentId.get(appDocument.Id)
					);
					if (tempContent != null) {
						tempMap.put(FILE_NAME, tempContent[0].PathOnClient);
					}
					tempMap.put(DOCUMENT_NAME, appDocument.Document_Name__c);
					tempMap.put(LPI_LiteralConstant.STATUS, LPI_LiteralConstant.PAR_SUBMITTED_STATUS);
					tempMap.put(SH_DOWN_BUTTON, '' + true);
					tempMap.put(
						DOWNLOAD_LINK,
						Url.getSalesforceBaseUrl().toExternalForm() +
							DOWNLOAD_URL +
							mapOfApplicationDocumentIdToContentDocumentId.get(appDocument.Id)
					);
					listOfStatusToCount.add(tempMap);
				} else {
					Map<String, String> tempMap = new Map<String, String>();
					tempMap.put(LPI_LiteralConstant.STATUS, NOT_SUBMITTED);
					tempMap.put(SH_DOWN_BUTTON, '' + false);
					tempMap.put(DOCUMENT_NAME, appDocument.Document_Name__c);
					listOfStatusToCount.add(tempMap);
				}
			}
			return listOfStatusToCount;
		} catch (Exception exceptionInstance) {
			LPI_ExceptionManager.logException(CLASS_NAME, METHOD_GET_UPDATED_DOCUMENTS, exceptionInstance);
			return listOfStatusToCount;
		}
	}

	/**
	 * @author                         : MTX Group Product Team
	 * @since                          : 3 Nov, 2022
	 * @description                    : This method is used for validating if action is allowed based
	 *                                   on existing applications
	 * @param inputMap                 : Map Of input param
	 * @param outMap                   : Map Of output param
	 * @param options                  : Map Of options
	 * @return                         : Boolean
	 * @last modified by               : MTX Group Product Team
	 * @last modified date             : 17 Jan, 2023
	 * @last modified details          : Move queries to respective DAO classes, replace DML statement to
	 *                                   MODPR_DML methods and removed static Strings
	 */
	private static Boolean setActionAllowedValidation(
		Map<String, Object> inputMap,
		Map<String, Object> outMap,
		Map<String, Object> options
	) {
		try {
            Boolean isActionAllowed =  LPI_ApplicationFlowUtility.setActionAllowedValidation(inputMap);
			outMap.put(IS_ACTION_ALLOWED, isActionAllowed);
			return true;
		} catch (Exception exceptionInstance) {
			LPI_ExceptionManager.logException(CLASS_NAME, METHOD_SET_ACTION_ALLOWED_VALIDATION, exceptionInstance);
			return false;
		}
	}
}