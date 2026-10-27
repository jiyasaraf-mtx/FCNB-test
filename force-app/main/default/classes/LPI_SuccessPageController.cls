/**
 * @description       : Fetching data from Success Page FlexCard(SucessPage)
 * @author            : MTX Group Product Team
 * @group             : 
 * @last modified on  : 07-26-2024
 * @last modified by  : MTX Group Product Team
**/

global without sharing class LPI_SuccessPageController implements Callable {
	public final static String FEE_PAID_STATUS = 'Paid';
	/**
	 * @description This Method is Used to Internally call the invokeMethod.
	 * @author MTX Group Product Team
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
	 * @author            MTX Group Product Team
	 * @description       This method will compare method from FlexCard and execute only that specific method
	 * @return  `Boolean`
	 */

	private Boolean invokeMethod(
		String methodName,
		Map<String, Object> inputMap,
		Map<String, Object> outMap,
		Map<String, Object> options
	) {
		Boolean result = true;
		try {
			if (methodName.equals('getSuccessPageData')) {
				outMap.put('successPageData', getSuccessPageData(inputMap));
			}
            if (methodName.equals('getTicketNumber')) {
				outMap.put('TicketNumber', getTicketNumber(inputMap));
			}
		} catch (Exception e) {
			LPI_ExceptionManager.logException('LPI_SuccessPageController', 'invokeMethod', e);
			result = false;
		}
		return result;
	}

	/**
	 * @author            MTX Group Product Team
	 * @description       This method will call from the invoke method
	 * @param  inputMap   data we are fetching from the Vlocity component
	 * @return  `List<Map<String,String>>`
	 */
	public static Map<String, object> getSuccessPageData(Map<String, Object> inputMap) {
		try {
			String blaId = (String) inputMap.get('blaId');
			String iaId = (String) inputMap.get('indAppId');
			String parId = (String) inputMap.get('parId');
			String defId = (String) inputMap.get('defId');
			String applicationId ;
			Boolean isDeficiencyCase = defId != 'null' && String.isNotBlank(defId) && defId != '{Params.parId}';
			Map<String, Object> dataMap = new Map<String, Object>();
			if (iaId != 'null' && String.isNotEmpty(iaId) && iaId != '{Params.indAppId}') {
                applicationId = iaId;
				String fieldToQuery = 'Id,Name,ApplicationType,SavedApplicationRefId';
				String whereClause = 'Id = \'' + String.escapeSingleQuotes(iaId) + '\'';
 				IndividualApplication indAppRec = new LPI_IndividualApplicationDAO.LPI_DAO_IndividualApptWithoutSecurity()
					.getIndividualApplicationByDymanicQuery(fieldToQuery,whereClause,null,null,null)[0];
				if (indAppRec != null) {
					dataMap.put('IndType', indAppRec.ApplicationType);
					dataMap.put('type', indAppRec.ApplicationType);
					dataMap.put('IndName', indAppRec.Name);
					List<PreliminaryApplicationRef> parData = LPI_PreliminaryApplicationRefDAO.getPARRecordsByID(
						new Set<Id>{ indAppRec.SavedApplicationRefId }
					);

					if (parData.size() > 0) {
						dataMap.put('parName', parData[0].Name);
						List<ContentDocumentLink> cdlData = LPI_ContentDocumentLinkDAO.getContentDocumentLinkByLinkedEntityIds(
							new Set<Id>{ parData[0].Id }
						);
					}
				}
			} else if (blaId != 'null' && String.isNotEmpty(blaId) && blaId != '{Params.blaId}') {
                applicationId = blaId;
				BusinessLicenseApplication blaAppRec = new LPI_BusinessLicenseApplicationDAO.LPI_DAO_BusinessLiceWithoutSecurity()
					.getBusinessLicenseAppDetails(blaId);
				if (blaAppRec != null) {
					dataMap.put('BlaType', blaAppRec.ApplicationType);
					dataMap.put('type', blaAppRec.ApplicationType);
					dataMap.put('BlaName', blaAppRec.Name);
					dataMap.put('blaRecordType', blaAppRec.RecordType.Name);
					List<PreliminaryApplicationRef> parData = LPI_PreliminaryApplicationRefDAO.getPARRecordsByID(
						new Set<Id>{ blaAppRec.SavedApplicationRefId }
					);

					if (parData.size() > 0) {
						dataMap.put('parName', parData[0].Name);
						List<ContentDocumentLink> cdlData = LPI_ContentDocumentLinkDAO.getContentDocumentLinkByLinkedEntityIds(
							new Set<Id>{ parData[0].Id }
						);
					}
				}
			}else if(parId != 'null' && String.isNotEmpty(parId) && parId != '{Params.parId}'){
				List<PreliminaryApplicationRef> parData = LPI_PreliminaryApplicationRefDAO.getPARRecordsByID(
					new Set<Id>{ parId }
				);
				if (parData.size() > 0) {
					dataMap.put('parName1', parData[0].Name);
				}
			}else if(isDeficiencyCase){
				List<Deficiency__c> deficiencyList = new LPI_DeficiencyDAO.LPI_DeficiencyWithoutSharingDAO().getDeficiencyByDymanicQuery('Id,Individual_Application__r.Name,Business_License_Application__r.Name','Id = \''+String.escapeSingleQuotes(defId) + '\'',null,null,null);
				if(deficiencyList != null && !deficiencyList.isEmpty()){
					String iaName = deficiencyList[0].Individual_Application__r?.Name;
					String blaName = deficiencyList[0].Business_License_Application__r?.Name;
					dataMap.put('applicationNumber', String.isNotBlank(iaName)?iaName:blaName);
				}
			}

			if (String.isNotBlank(applicationId) || isDeficiencyCase) {
				//Get Regulatory Trnx Fee For Receipt Data
				String whereClause;
				if(isDeficiencyCase){
					whereClause = 'Deficiency__c = \'' + String.escapeSingleQuotes(defId)+ '\'';
				}else{
					whereClause = 'ParentRecordId = \'' + applicationId + '\''+
					' AND TotalFeeAmount >= 0';
				}
				List<RegulatoryTrxnFee> feeRecord = LPI_RegulatoryTrxnFeeDAO.getRegulatoryTrxnFeeByDymanicQuery(
					'Id, TotalFeeAmount, Status__c',
					whereClause,
					'1',
					'CreatedDate',
					'DESC'
				);
				if(isDeficiencyCase){
					if(feeRecord != NULL && !feeRecord.isEmpty()){
						dataMap.put('feePaid', feeRecord[0].Status__c == FEE_PAID_STATUS);
						if(feeRecord[0].Status__c == FEE_PAID_STATUS){
							dataMap.put('showDownloadReceipt',true);
							dataMap.put(
							'receiptPDFURL',
							Url.getSalesforceBaseUrl().toExternalForm() +
								'/apex/LPI_PaymentReceiptPDFPage?targetId=' +
								feeRecord[0].Id
							);
						}else{
							dataMap.put('showDownloadReceipt',false);
						}
					}
				}else{
					dataMap.put(
					'downDocUrl',
					Url.getSalesforceBaseUrl().toExternalForm() + '/apex/LPI_PDFTemplatePage?targetId=' + applicationId);
					if(feeRecord != NULL && !feeRecord.isEmpty()){
						dataMap.put('showDownloadReceipt',true);
						dataMap.put(
						'receiptPDFURL',
						Url.getSalesforceBaseUrl().toExternalForm() +
							'/apex/LPI_PaymentReceiptPDFPage?targetId=' +
							applicationId
						);
						dataMap.put('feePaid', feeRecord[0].TotalFeeAmount > 0);
					}
				}
			}
			return dataMap;
		} catch (Exception e) {
			LPI_ExceptionManager.logException('LPI_SuccessPageController', 'getSuccessPageData', e);
			throw new AuraHandledException(e.getStackTraceString());
		}
	}
    
    public static String getTicketNumber(Map<String, Object> inputMap) {
        List<Ticket__c> listOfTickets = [select Id,Name from Ticket__c Order by Name DESC LIMIT 1];
        return listOfTickets[0].Name;
    }
}