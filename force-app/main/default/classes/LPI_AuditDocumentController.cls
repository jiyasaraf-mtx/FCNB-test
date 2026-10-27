/**
 * @author      : Piyush Aneja
 * @since       : 13 Sep 2023
 * @description : This class is used to retrive existing application document record or document record with that it is also used to create documents for Audit.
 *  -------------------------------------------------------------------------------------------------------
 * Version      Date                Author                  Details
 *    1         15 Sep 2023         Piyush Aneja 	        Initial Developement for Audit Document
 * -------------------------------------------------------------------------------------------------------
 */
global with sharing class LPI_AuditDocumentController {
	// *************************************** ALL CONSTANTS ************************************************
	private static final String SEQUENCE = 'Sequence__c';
	private static final String TCP_OBJECT = 'TrainingCourseParticipant';
	private static final String DELETE_FROM_ONBASE_STATUS = 'Delete from onbase';
	// ******************************************************************************************************

	/**
	 * @author                      : Piyush Aneja
	 * @since                       : 15 Sep 2023
	 * @description                 : This method creates a new Application_Document__c record and associates it with ContentDocumentLink records.
	 * @param auditId               : The Id of the Audit_Detail__c record to associate the new Application_Document__c record with.
	 * @param documentName          : The name of the new document.
	 * @param description           : The description for the new document.
	 * @param newContentDocumentId  : A list of ContentDocumentIds to associate with the new Application_Document__c record.
	 * @return                      : A map containing information about the created Application_Document__c record and 'newDocumentId' (ID of the newly created document).
	 * @last modified by            : MTX Group Inc
	 * @last modified date          : (Add if modified by you)
	 * @last modified details       : (Add if modified by you)
	 */
	// @AuraEnabled
	// public static Map<String, Object> createApplicationDocument(
	// 	Id auditId,
	// 	String documentName,
	// 	String description,
	// 	Map<String,Object> objectMap
	// ) {
	// 	try {
	// 		Map<String, Object> outMap = new Map<String, Object>();
	// 		String objectType = String.valueOf(auditId.getSObjectType());
	// 		String boardName, payload;
	// 		Application_Document__c newDocument = new Application_Document__c(
	// 			Audit_Detail__c = auditId,
	// 			Document_Name__c = documentName,
	// 			Description__c = description,
	// 			Is_Manual_Document__c = true,
	// 			Board_Name__c = boardName,
	// 			File_Name__c = (String) objectMap?.get('fileName'),
	// 			Application_Document__c = (String) objectMap?.get('parentDocId'),
	// 			Status__c = (String) objectMap?.get('documentStatus'),
	// 			Onbase_Payload__c = payload
	// 		);
	// 		if(String.isNotBlank((String) objectMap?.get('tcpId'))){
	// 			newDocument.Training_Course_Participant__c = (String) objectMap?.get('tcpId');
	// 		}
	// 		if(objectMap?.get('additionalRec') != NULL && Boolean.valueOf(objectMap?.get('additionalRec'))){
	// 			newDocument.Is_additional_document_by_portal_user__c = true;
	// 		}
	// 		newDocument = (Application_Document__c) LPI_WithoutSharingUtility.insertSObject(newDocument);
	// 		Map<String, Object> jsonDataMap = new Map<String, Object>{
	// 			'tcpId' => (String)objectMap?.get('tcpId'),
	// 			'ceAudit' => (Boolean)objectMap?.get('isCeAudit'),
	// 			'appDocId' => '',
	// 			'fromCourseModal' => false
	// 		};
	// 		outMap.put('outputData', getApplicationDocumentList(auditId, jsonDataMap));
	// 		outMap.put('newDocumentId', newDocument.Id);
	// 		return outMap;
	// 	} catch (DmlException e) {
	// 		LPI_ExceptionManager.logException('LPI_AuditDocumentController', 'createApplicationDocument', e);
	// 		return null;
	// 	}
	// }

	/**
	 * @author                      : Piyush Aneja
	 * @since                       : 15 Sep 2023
	 * @description                 : This Method is used to return document list.
	 * @param auditId     		   : The ID of the audit.
	 * @return             		   : A string representing the document wrapperList.
	 * @last modified by            : MTX Group Inc
	 * @last modified date          : (Add if modified by you)
	 * @last modified details       : (Add if modified by you)
	 */
	@AuraEnabled
	public static Map<String,String> getApplicationDocumentList(String auditId, Map<String, Object> inputMap) {
		try {
			Map<String,String> responseMap = new Map<String,String>();
			String tcpId = (String)inputMap.get('tcpId');
			Boolean ceAudit = (Boolean)inputMap.get('ceAudit');
			String appDocId = (String)inputMap.get('appDocId') ;
			Boolean fromCourseModal = (Boolean)inputMap.get('fromCourseModal');
			String appDocumentQueryFields = ' Id,Board_Name__c,File_Name__c, Uploaded_By_Internal_User__c, Onbase_Document_Id__c, Document_Name__c,Audit_Detail__r.Business_License__r.Pre_Licensure_Number__c, Preliminary_Application_Reference__c, Business_License_Application__c, Is_Lawful_Presence_Document__c, Is_Document_Required__c, Help_Text__c,(SELECT ID,Application_Document__c, File_Name__c,Onbase_Document_Id__c,Uploaded_By_Internal_User__c FROM Application_Document__r), ' +
			'(SELECT ContentDocument.Title, LinkedEntityId, ContentDocument.FileExtension, ContentDocumentId,ContentDocument.CreatedBy.Profile.Name, Id FROM ContentDocumentLinks LIMIT 50) ';
			String appDocumentWhereClause;
			if(ceAudit!=null && ceAudit){
				if(String.isBlank(tcpId) && String.isBlank(appDocId)){
					return responseMap;
				}
				if(String.isNotBlank(tcpId)){
					appDocumentWhereClause = 'Training_Course_Participant__c = \''+ String.escapeSingleQuotes(tcpId) + '\'';
				}else{
					appDocumentWhereClause = 'Id IN ' +
					LPI_ServiceUtility.getStringValuesByList(appDocId.split(','));
				}
				
			}else{
				appDocumentWhereClause = 'Application_Document__c = NULL AND Audit_Detail__c = \'' + String.escapeSingleQuotes(auditId) + '\'';
			}
			if(!(fromCourseModal != null && (Boolean)fromCourseModal)){
				appDocumentWhereClause += ' AND (CreatedBy.Profile.Name != \'' + LPI_LiteralConstant.Portal_Profile_Name + '\' OR (CreatedBy.Profile.Name = \'' + LPI_LiteralConstant.Portal_Profile_Name + '\' AND Status__c = \'' + LPI_LiteralConstant.IA_SUBMITTED_STATUS + '\'))';
			}else if((fromCourseModal != null && (Boolean)fromCourseModal)){
				appDocumentWhereClause += ' AND (Status__c = \'' + LPI_LiteralConstant.IA_SUBMITTED_STATUS + '\' OR (Status__c != \'' + LPI_LiteralConstant.IA_SUBMITTED_STATUS + '\'' + ' AND Id IN ' + LPI_ServiceUtility.getStringValuesByList(appDocId.split(','))+')) ';
			}
			appDocumentWhereClause += ' AND Onbase_Upload_Status__c !=  \'' + DELETE_FROM_ONBASE_STATUS + '\'';
			List<Application_Document__c> applicationDocumentList = new List<Application_Document__c>();
			applicationDocumentList = LPI_ApplicationDocumentDAO.getApplicantDocumentByDymanicQueryWithoutSecurity(
				appDocumentQueryFields,
				appDocumentWhereClause,
				null,
				SEQUENCE,
				null
			);
			Map<Id, Application_Document__c> applicationDocumentMap = new Map<Id, Application_Document__c>();
			LPI_Onbase_Configuration__mdt onbaseConfig;
			for (Application_Document__c tempAppDoc : applicationDocumentList) {
				applicationDocumentMap.put(tempAppDoc.Id, tempAppDoc);
			}
			if (applicationDocumentMap.isEmpty()) {
				return responseMap;
			}
			Map<Id,DocumentWrapper> idToDocumentMap = new Map<Id,DocumentWrapper>();
			Map<String, Object> twoByTwoPhotoDocMap = (Map<String, Object>) JSON.deserializeUntyped(
				System.Label.TwoByTwoPhotoRecommendations
			);
			
			List<Application_Document__c> childAppDocList = new List<Application_Document__c> ();
			for (Application_Document__c appDocument : applicationDocumentMap.values()) {
				childAppDocList.addAll(appDocument.Application_Document__r);
				DocumentWrapper wrapper = new DocumentWrapper();
				wrapper.documentRecord = appDocument;
				if (wrapper.contentDocumentId != null) {
					wrapper.fileName = wrapper.contentVersionList[0].PathOnClient;
					wrapper.cssString = 'slds-grid slds-wrap box-container-inner documentuploaded';
				} else {
					wrapper.cssString = 'slds-grid slds-wrap box-container-inner';
				}
				LPI_Wrapper.FileWrapper fileWrapper = new LPI_Wrapper.FileWrapper();
                if(String.isNotBlank(appDocument.Onbase_Document_Id__c)){
                    fileWrapper.fileName = appDocument.File_Name__c;
                    fileWrapper.uniqueId = appDocument.Onbase_Document_Id__c;
					fileWrapper.parentRecId = appDocument.Id;
					fileWrapper.showDelete = !appDocument.Uploaded_By_Internal_User__c;
                    wrapper.files.add(fileWrapper);
                }
				wrapper.hideUpload = (appDocument.Document_Name__c == twoByTwoPhotoDocMap.get('docName') &&
				!appDocument.ContentDocumentLinks.isEmpty());
				idToDocumentMap.put(appDocument.Id,wrapper);
			}
			if(!idToDocumentMap.keySet().isEmpty()){
				idToDocumentMap.values()[0].twoByTwoPhotoRecommendation = System.Label.TwoByTwoPhotoRecommendations;
            }
			for(Application_Document__c appDoc : childAppDocList){
                LPI_Wrapper.FileWrapper fileWrapper = new LPI_Wrapper.FileWrapper();
                fileWrapper.fileName = appDoc.File_Name__c;
                fileWrapper.uniqueId = appDoc.Onbase_Document_Id__c;
				fileWrapper.parentRecId = appDoc.Id;
                fileWrapper.showDelete = !appDoc.Uploaded_By_Internal_User__c;
                DocumentWrapper wrapper = idToDocumentMap.get(appDoc.Application_Document__c);
                wrapper.files.add(fileWrapper);
            }
			responseMap.put('documents',JSON.serialize(idToDocumentMap.values()));
			return responseMap ;
		} catch (Exception ex) {
			LPI_ExceptionManager.logException('LPI_AuditDocumentController', 'getApplicationDocumentList', ex);
			throw new LPI_Exception(ex.getMessage());
		}
	}

	/**
	 * @author                      : Piyush Aneja
	 * @since                       : 15 Sep 2023
	 * @description                 : This is the  Wrapper class for handling document-related data in Apex.
	 * @last modified by            : MTX Group Inc
	 * @last modified date          : (Add if modified by you)
	 * @last modified details       : (Add if modified by you)
	 */
	public class DocumentWrapper {
		@AuraEnabled
		public Application_Document__c documentRecord;
		@AuraEnabled
		public String contentDocumentId;
		@AuraEnabled
		public List<ContentVersion> contentVersionList;
		@AuraEnabled
		public String fileName;
		@AuraEnabled
		public String cssString;
		@AuraEnabled
		public List<LPI_Wrapper.FileWrapper> files = new List<LPI_Wrapper.FileWrapper>();
		@AuraEnabled
		public string twoByTwoPhotoRecommendation;
		@AuraEnabled
		public Boolean hideUpload;
		@AuraEnabled public string numberValue;
        @AuraEnabled public string description;
        @AuraEnabled public string documentDate;
        @AuraEnabled public string comment;
	}
	/**
	 * @author                      : Sukanya Ambati
	 * @since                       : 5th March, 2023
	 * @description                 : This is the  Wrapper class for updating status of Application documents on cancelling course
	 * @last modified by            : MTX Group Inc
	 * @last modified date          : (Add if modified by you)
	 * @last modified details       : (Add if modified by you)
	 */
	public class appDocCancelWrapper {
		@AuraEnabled public string tcpId;
		@AuraEnabled public Boolean deleteAll;
		@AuraEnabled public Boolean isAudit;
		@AuraEnabled public String appDocIdList;
	}

	/**
	 * @author                      : Piyush Aneja
	 * @since                       : 15 Sep 2023
	 * @description                 : This method updates the status of an Application Document and returns information about the updated document list.
	 * @param documentIdForFileUpload: The ID of the document to be updated.
	 * @param auditId 				: The ID of the associated audit.
	 * @return A Map containing information about the updated Application Document list.
	 * @last modified by            : MTX Group Inc
	 * @last modified date          : (Add if modified by you)
	 * @last modified details       : (Add if modified by you)
	 */
	// @AuraEnabled
	// public static Map<String, Object> updateStatus(String documentIdForFileUpload, String auditId) {
	// 	try {
	// 		Map<String, Object> outMap = new Map<String, Object>();
	// 		LPI_DML.doUpdate(
	// 			new Application_Document__c(
	// 				Id = documentIdForFileUpload,
	// 				Status__c = LPI_LiteralConstant.APPDOC_STATUS_SUBMITTED
	// 			)
	// 		);
	// 		Map<String, Object> jsonDataMap = new Map<String, Object>{
	// 			'tcpId' => '',
	// 			'ceAudit' => false,
	// 			'appDocId' => '',
	// 			'fromCourseModal' => false
	// 		};
	// 		outMap.put('applicationDocumentInfo', getApplicationDocumentList(auditId, jsonDataMap));
	// 		return outMap;
	// 	} catch (Exception ex) {
	// 		LPI_ExceptionManager.logException('LPI_AuditDocumentController', 'updateStatus', ex);
	// 		return null;
	// 	}
	// }

	/**
	 * @author                      : Piyush Aneja
	 * @since                       : 15 Sep 2023
	 * @description                 : This method deletes content files and performs related operations.
	 * @param documentRecordId	   : List of document record Ids to delete
	 * @param auditId 			   : Audit Id associated with the document.
	 * @param record 			   : Record Id associated with the document.
	 * @return 					   : Map<String, Object> - Map containing application document information.
	 * @last modified by            : MTX Group Inc
	 * @last modified date          : (Add if modified by you)
	 * @last modified details       : (Add if modified by you)
	 */
	// @AuraEnabled
	// public static Map<String, Object> deleteContentFile(List<Object> documentRecordId, String record, Id auditId) {
	// 	try {
	// 		Map<String, Object> outMap = new Map<String, Object>();
	// 		List<ContentDocument> cdToBeDeleted = new List<ContentDocument>();

	// 		for (Object conDoc : documentRecordId) {
	// 			cdToBeDeleted.add(new ContentDocument(Id = (Id) conDoc));
	// 		}

	// 		if (cdToBeDeleted.size() > 0) {
	// 			LPI_DML.doDelete(cdToBeDeleted);

	// 			if (String.isNotBlank(record)) {
	// 				String contentDocumentLinkQueryFields = 'ID, ContentDocumentId, LinkedEntityId';
	// 				String contentDocumentLinkWhereClause =
	// 					'LinkedEntityId IN ' +
	// 					LPI_ServiceUtility.getStringValuesByList(new List<Id>(new Set<Id>{ record }));
	// 				List<ContentDocumentLink> contentDocumentLinkList = LPI_ContentDocumentLinkDAO.getContentDocumentLinkByDymanicQuery(
	// 					contentDocumentLinkQueryFields,
	// 					contentDocumentLinkWhereClause,
	// 					null,
	// 					null,
	// 					null
	// 				);

	// 				if (contentDocumentLinkList.size() == 0) {
	// 					String appDocumentQueryFields = 'Id, Is_Manual_Document__c';
	// 					String appDocumentWhereClause =
	// 						'Is_Manual_Document__c = TRUE AND ID IN ' +
	// 						LPI_ServiceUtility.getStringValuesByList(new List<Id>(new Set<Id>{ record }));

	// 					List<Application_Document__c> docList = LPI_ApplicationDocumentDAO.getApplicantDocumentByDymanicQuery(
	// 						appDocumentQueryFields,
	// 						appDocumentWhereClause,
	// 						null,
	// 						null,
	// 						null
	// 					);

	// 					if (docList.size() > 0 && docList[0].Is_Manual_Document__c) {
	// 						delete docList;
	// 					} else {
	// 						LPI_DML.doUpdate(
	// 							new Application_Document__c(Id = record, Status__c = LPI_LiteralConstant.APPDOC_STATUS)
	// 						);
	// 					}
	// 				}
	// 			}
	// 		}
	// 		Map<String, Object> jsonDataMap = new Map<String, Object>{
	// 			'tcpId' => '',
	// 			'ceAudit' => false,
	// 			'appDocId' => '',
	// 			'fromCourseModal' => false
	// 		};
	// 		outMap.put('applicationDocumentInfo', getApplicationDocumentList(auditId, jsonDataMap));
	// 		return outMap;
	// 	} catch (Exception ex) {
	// 		LPI_ExceptionManager.logException('LPI_AuditDocumentController', 'deleteContentFile', ex);
	// 		return null;
	// 	}
	// }
	/**
	 * @author                      : Piyush Aneja
	 * @since                       : 15 Sep 2023
	 * @description                 : This method generates a download URL for a Salesforce document based on its content ID.
	 * @param contentId    		   : The unique identifier for the content document.
	 * @return 					   : A map containing the 'contentDocURL' key with the download URL, or null in case of an exception.
	 * @last modified by            : MTX Group Inc
	 * @last modified date          : (Add if modified by you)
	 * @last modified details       : (Add if modified by you)
	 */
	// @AuraEnabled
	// public static Map<String, Object> documentDownloadUrl(String contentId) {
	// 	try {
	// 		Map<String, Object> outMap = new Map<String, Object>();
	// 		String downloadUrl =
	// 			Url.getSalesforceBaseUrl().toExternalForm() +
	// 			'/sfc/servlet.shepherd/document/download/' +
	// 			contentId;
	// 		outMap.put('contentDocURL', downloadUrl);
	// 		return outMap;
	// 	} catch (Exception ex) {
	// 		LPI_ExceptionManager.logException('LPI_AuditDocumentController', 'documentDownloadUrl', ex);
	// 		return null;
	// 	}
	// }

	/**
	 * @author                      : Sukanya Ambati
	 * @since                       : 12th Jan, 2024
	 * @description                 : Method to update status to delete from onbase on cancel function of course details
	 * @param recordId              : String
	 * @return                      : void
	 * @last modified by            : MTX Group Inc
	 * @last modified date          : 
	 * @modified details            : 
	 */
	@AuraEnabled
	public static void updateAppDocStatusOnCancel(String jsonData){
	   try {
		   if(String.isBlank(jsonData)){
			   return;
		   }
		   appDocCancelWrapper mainWrapperObj = (appDocCancelWrapper) JSON.deserializeStrict(jsonData, appDocCancelWrapper.Class);
		   String fields = 'Id,Document_Name__c,Upload_To_Onbase__c,Case__r.Request_Id__c'; 
		   String whereClause;
		   if(mainWrapperObj.deleteAll != null && (Boolean)mainWrapperObj.deleteAll && String.isNotBlank((String)mainWrapperObj.tcpId)){
				whereClause = 'Training_Course_Participant__c = \''+ String.escapeSingleQuotes((String)mainWrapperObj.tcpId) + '\'';
		   }else if(mainWrapperObj.deleteAll != null && !(Boolean)mainWrapperObj.deleteAll){
				whereClause = 'Id IN ' +
				LPI_ServiceUtility.getStringValuesByList(String.valueOf(mainWrapperObj?.appDocIdList)?.split(','));
		   }
		  
		   List<Application_Document__c> appDocList = LPI_ApplicationDocumentDAO.getApplicantDocumentByDymanicQueryWithoutSecurity(fields,whereClause,null,null,null);
		   if(!appDocList.isEmpty()){
			   List<Application_Document__c> updateAppDocList = new List<Application_Document__c>();
			   for(Application_Document__c appDoc : appDocList){
				   Application_Document__c appDocRec = new Application_Document__c();
				   appDocRec.Id = appDoc.Id;
				   appDocRec.Onbase_Upload_Status__c = DELETE_FROM_ONBASE_STATUS;
				   updateAppDocList.add(appDocRec);
			   }
			   if(!updateAppDocList.isEmpty()){
				LPI_DML.doUpdate(updateAppDocList);
			   }
		   }
	   } catch (Exception e) {
		   LPI_ExceptionManager.logException(
			   'LPI_AuditDocumentController',
			   'updateAppDocStatusOnCancel',
			   e
		   );
		   throw new AuraHandledException(e.getMessage());
	   }
	}
	/**
	 * @author                      : Ambati Sukanya
	 * @since                       : 16 Jan 2024
	 * @description                 : This method checks if the application Document has any child records present
	 * @param appDocId              : The Id of the Application document record
	 * @return                      : true if the application document has child records
	 * @last modified by            : MTX Group Inc
	 * @last modified date          : (Add if modified by you)
	 * @last modified details       : (Add if modified by you)
	 */
	//  @AuraEnabled
	//  public static Boolean checkParentApplicationDocument(String appDocId){
	// 	try{
	// 		if(String.isBlank(appDocId)){
	// 			return null;
	// 		}
	// 		String fields = 'Id, (SELECT ID,Application_Document__c, File_Name__c,Onbase_Document_Id__c,Uploaded_By_Internal_User__c FROM Application_Document__r) ';
	// 		String whereClause = 'Id = \'' + String.escapeSingleQuotes(appDocId) + '\'';
	// 		List<Application_Document__c> applicationDocumentList = new List<Application_Document__c>();
	// 		applicationDocumentList = LPI_ApplicationDocumentDAO.getApplicantDocumentByDymanicQueryWithoutSecurity(
	// 			fields,
	// 			whereClause,
	// 			null,
	// 			null,
	// 			null
	// 		);
	// 		if(!applicationDocumentList.isEmpty() && !applicationDocumentList[0].Application_Document__r.isEmpty()){
	// 			return true;
	// 		}else{
	// 			return false;
	// 		}
	// 	}
	// 	catch (Exception e) {
	// 		LPI_ExceptionManager.logException(
	// 			'LPI_AuditDocumentController',
	// 			'checkParentApplicationDocument',
	// 			e
	// 		);
	// 		throw new AuraHandledException(e.getMessage());
	// 	}
	
	//  }
}