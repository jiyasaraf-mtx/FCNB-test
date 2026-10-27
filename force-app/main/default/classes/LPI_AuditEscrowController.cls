/**
 * @author      : MTX Group Product Team
 * @since       : 31 Jan, 2023
 * @description : This Class Contains methods which are used for Audit Escrow Flow
 */ 
global with sharing class LPI_AuditEscrowController implements Callable {
	private final static String BANK_ACCOUNT_STATUS_OPEN = 'Open';
    private final static String BANK_ACCOUNT_STATUS_CLOSED = 'Closed';
	/**
	 * @description                 : This Method is Used to Internally call the invokeMethod.
	 * @author                      : MTX Group Product Team | 01-31-2023
	 * @param action:               : It contains method name which is called from OmniScript
	 * @param args                  : It is Map<String, Object> which contanis `input`, `output` and `options`
	 * @return                      : `Object`
	 **/
	global Object call(String action, Map<String, Object> args) {
		Map<String, Object> input = (Map<String, Object>) args.get(LPI_LiteralConstant.INPUT);
		Map<String, Object> output = (Map<String, Object>) args.get(LPI_LiteralConstant.OUTPUT);
		Map<String, Object> options = (Map<String, Object>) args.get(LPI_LiteralConstant.OPTIONS);
		return invokeMethod(action, input, output, options);
	}

	/**
	 * @author               : MTX Group Product Team
	 * @description       	 : This Method is used to invoke methods from a omnistudio components.
	 * @param methodName     : Method Name
	 * @param inputMap       : Input Parameter Passed from Omniscript
	 * @param outMap         : Output Passed to Omniscript
	 * @param options        : Extra Options passed from Omniscript
	 * @last modified by     : MTX Group Product Team
	 * @last modified date   :
	 * @modified details     :
	 * @return               :`Boolean`
	 */
	private Boolean invokeMethod(
		String methodName,
		Map<String, Object> inputMap,
		Map<String, Object> outMap,
		Map<String, Object> options
	) {
		Boolean result = true;
		try {
			if (methodName.equals('deleteOpenBankAccounts')) {
				deleteOpenBankAccounts(inputMap);
			} 
			
			else if (methodName.equals('fetchAuditEscrowBankAccountDetails')) {
				fetchAuditEscrowBankAccountDetails(inputMap, outMap);
			} else if (methodName.equals('fetchAuditEscrowClosedBankAccountDetails')) {
				fetchAuditEscrowClosedBankAccountDetails(inputMap, outMap);
			} else if (methodName.equals('fetchAuditChangeInBankAccountDetails')) {
				fetchAuditChangeInBankAccountDetails(inputMap, outMap);
			} else if (methodName.equals('fetchBankAccountDetails')) {
				fetchBankAccountDetails(inputMap, outMap);
			} else if(methodName.equals('saveBankAccountDetails')){
				saveBankAccountDetails(inputMap, outMap);
			} else {
				result = false;
			}
		} catch (Exception e) {
			LPI_ExceptionManager.logException('LPI_AuditEscrowController', 'invokeMethod', e);
			throw new AuraHandledException(e.getMessage());
		}
		return result;
	}

	private static Map<String, String> keyMappingForBankAccount;

	

	/**
	 * @author                      : MTX Group Product Team
	 * @since                       : 18 Jan 2023
	 * @description                 : This Method deletes Bank Account record
	 * @param inputMap              : Input data passed from OmniScript
	 * @param outMap                : Output data passed to OmniScript
	 * @return                      : `void`
	 * @last modified by            : MTX Group Product Team
	 * @last modified date          : 01 Feb 2023
	 * @last modified details       : Beautified the code with proper indentation
	 */

	public static void deleteBankAccounts(
		String parId, List<String> bankAccIdsFromResponse, String status
	) {
		try {
			String bankAccountWherrClause;
			if(bankAccIdsFromResponse != null){
				bankAccountWherrClause ='Preliminary_Application_Reference__c =\'' +
				String.escapeSingleQuotes(parId) +
				'\' AND Status__c = \'' +
				status +
				'\' AND Id NOT IN ' +
				LPI_ServiceUtility.getStringValuesByList(bankAccIdsFromResponse);
			}
			String bankAccountWhereClauseForParId =
				'Preliminary_Application_Reference__c =\'' +
				String.escapeSingleQuotes(parId) +
                '\' AND Status__c = \'' +
				status +
				'\'';
			if (bankAccIdsFromResponse != null && String.isNotBlank(bankAccountWherrClause)) {
				List<Bank_Account__c> delBankAccList = LPI_BankAccountDAO.getBankAccountByDymanicQuery(
					'Id',
					bankAccountWherrClause,
					null,
					null,
					null
				);
				if (!delBankAccList.isEmpty()) {
					LPI_WithoutSharingUtility.deleteSObject(delBankAccList);
				}
			} else {
				List<Bank_Account__c> bankAccListForParId = LPI_BankAccountDAO.getBankAccountByDymanicQuery(
					'Id',
					bankAccountWhereClauseForParId,
					null,
					null,
					null
				);
				if (!bankAccListForParId.isEmpty()) {
					LPI_WithoutSharingUtility.deleteSObject(bankAccListForParId);
				}
			}
		} catch (Exception e) {
			LPI_ExceptionManager.logException('LPI_AuditEscrowController', 'deleteBankAccounts', e);
		}
	}

	

	/**
	 * @author                      : MTX Group Product Team
	 * @since                       : 18 Jan 2023
	 * @description                 : This Method fetches Audit Escrow Bank Account Details in FC
	 * @param inputMap              : Input data passed from OmniScript
	 * @param outMap                : Output data passed to OmniScript
	 * @return                      : `void`
	 * @last modified by            : MTX Group Product Team
	 * @last modified date          : 01 Feb 2023
	 * @last modified details       : Beautified the code with proper indentation
	 */

	public static void fetchAuditEscrowBankAccountDetails(Map<String, Object> inputMap, Map<String, Object> outMap) {
		try {
			list<PreliminaryApplicationRef> parList = LPI_PreliminaryApplicationRefDAO.getPARRecordsByParId(
				(Id) inputMap.get('parId')
			);
			List<Map<String, String>> bankAccountListMap = new List<Map<String, String>>();

			String bankAccountFieldsToQuery = 'Id,City__c, State__c,Status__c, Date_Closed__c, Name_of_Financial_Institution__c, Type_of_Account__c, Other_Account_Type__c ,Account_Number__c ';
			String bankAccountWhereClauseFromDetails =
				'Preliminary_Application_Reference__c =\'' +
				String.escapeSingleQuotes((Id) inputMap.get('parId')) +
				'\' AND Status__c = \'' +
				LPI_LiteralConstant.BANK_ACCOUNT_STATUS_OPEN +
				'\'';

			integer noOfbankAcc = 0;
			for (
				Bank_Account__c bankAcc : LPI_BankAccountDAO.getBankAccountByDymanicQuery(
					bankAccountFieldsToQuery,
					bankAccountWhereClauseFromDetails,
					null,
					null,
					null
				)
			) {
				noOfbankAcc = noOfbankAcc + 1;
				Map<String, String> bankAccMap = new Map<String, String>();
				bankAccMap.put('NoOfBankAcc', 'Bank Account ' + noOfbankAcc);
				bankAccMap.put('NameOfFinancialInstitution', bankAcc.Name_of_Financial_Institution__c);
				bankAccMap.put('CityAccInfo', bankAcc.City__c);
				bankAccMap.put('StateAccInfo', bankAcc.State__c);
				bankAccMap.put('BankAccountNumber', bankAcc.Account_Number__c);
				bankAccMap.put('TypeOfAccount', bankAcc.Type_of_Account__c);
				bankAccMap.put('OtherAccountType', bankAcc.Other_Account_Type__c);
				bankAccountListMap.add(bankAccMap);
			}
			outMap.put('BankAccInfoList', bankAccountListMap);
		} catch (Exception e) {
			LPI_ExceptionManager.logException('LPI_AuditEscrowController', 'fetchAuditEscrowBankAccountDetails', e);
		}
	}

	/**
	 * @author                      : MTX Group Product Team
	 * @since                       : 18 Jan 2023
	 * @description                 : This Method fetches Closed Bank Account Details in FC
	 * @param inputMap              : Input data passed from OmniScript
	 * @param outMap                : Output data passed to OmniScript
	 * @return                      : `void`
	 * @last modified by            : MTX Group Product Team
	 * @last modified date          : 01 Feb 2023
	 * @last modified details       : Beautified the code with proper indentation
	 */

	public static void fetchAuditEscrowClosedBankAccountDetails(
		Map<String, Object> inputMap,
		Map<String, Object> outMap
	) {
		try {
			list<PreliminaryApplicationRef> parList = LPI_PreliminaryApplicationRefDAO.getPARRecordsByParId(
				(Id) inputMap.get('parId')
			);
			String bankAccountFieldsToQuery = 'Id,City__c, State__c,Status__c, Date_Closed__c, Name_of_Financial_Institution__c, Type_of_Account__c, Other_Account_Type__c ,Account_Number__c ';
			String bankAccountWhereClauseFromDetails =
				'Preliminary_Application_Reference__c =\'' +
				String.escapeSingleQuotes((Id) inputMap.get('parId')) +
				'\' AND Status__c = \'' +
				LPI_LiteralConstant.BANK_ACCOUNT_STATUS_CLOSED +
				'\'';
			List<Map<String, String>> closedBankAccountListMap = new List<Map<String, String>>();
			integer noOfClosedbankAcc = 0;
			for (
				Bank_Account__c bankAcc : LPI_BankAccountDAO.getBankAccountByDymanicQuery(
					bankAccountFieldsToQuery,
					bankAccountWhereClauseFromDetails,
					null,
					null,
					null
				)
			) {
				String closedDateString = '';
				noOfClosedbankAcc = noOfClosedbankAcc + 1;
				if (bankAcc.Date_Closed__c != null) {
					Date dateClosed = bankAcc.Date_Closed__c;
					Datetime dateTimeValue = datetime.newInstance(
						dateClosed.year(),
						dateClosed.month(),
						dateClosed.day()
					);
					closedDateString = dateTimeValue.format('MM-dd-yyyy');
					
				}
				Map<String, String> closedbankAccMap = new Map<String, String>();
				closedbankAccMap.put('NoOfClosedBankAcc', 'Accounts Closed ' + noOfClosedbankAcc);
				closedbankAccMap.put(
					'AccountClosedNameOfFinancialInstitution',
					bankAcc.Name_of_Financial_Institution__c
				);
				closedbankAccMap.put('accountsClosedAccountNumber', bankAcc.Account_Number__c);
				closedbankAccMap.put('dateClosed', closedDateString);
				closedBankAccountListMap.add(closedbankAccMap);
			}
			outMap.put('closedBankAccInfoList', closedBankAccountListMap);
		} catch (Exception e) {
			LPI_ExceptionManager.logException(
				'LPI_AuditEscrowController',
				'fetchAuditEscrowClosedBankAccountDetails',
				e
			);
		}
	}

	/**
	 * @author                      : MTX Group Product Team
	 * @since                       : 18 Jan 2023
	 * @description                 : This Method fetches Change in Bank Account Details in FC
	 * @param inputMap              : Input data passed from OmniScript
	 * @param outMap                : Output data passed to OmniScript
	 * @return                      : `void`
	 * @last modified by            : MTX Group Product Team
	 * @last modified date          : 01 Feb 2023
	 * @last modified details       : Beautified the code with proper indentation
	 */

	public static void fetchAuditChangeInBankAccountDetails(Map<String, Object> inputMap, Map<String, Object> outMap) {
		try {
			list<PreliminaryApplicationRef> parList = LPI_PreliminaryApplicationRefDAO.getPARRecordsByParId(
				(Id) inputMap.get('parId')
			);
			String bankAccountFieldsToQuery = 'Id,City__c, State__c,Status__c, Date_Closed__c, Name_of_Financial_Institution__c, Type_of_Account__c, Other_Account_Type__c ,Account_Number__c ';
			String bankAccountWhereClauseFormerDetails;
			String bankAccountWhereClauseNewDetails;
			List<Map<String, String>> changeInBankAccountListMap = new List<Map<String, String>>();
			Map<String, String> bankAccMap = new Map<String, String>();
			
				outMap.put('changeInBankAccClosedId',null);
			
			if (parList[0].New_Designated_in_charge_License_Number__c != null) {
				bankAccountWhereClauseNewDetails =
					'Preliminary_Application_Reference__c =\'' +
					String.escapeSingleQuotes((Id) inputMap.get('parId')) +
					'\' AND Id = \'' +
					String.escapeSingleQuotes(parList[0].New_Designated_in_charge_License_Number__c) +
					'\'';
				for (
					Bank_Account__c bankAcc : LPI_BankAccountDAO.getBankAccountByDymanicQuery(
						bankAccountFieldsToQuery,
						bankAccountWhereClauseNewDetails,
						null,
						null,
						null
					)
				) {
					bankAccMap.put(
						'ToChangeBankAccNameOfFinancialInstitution',
						bankAcc.Name_of_Financial_Institution__c
					);
					bankAccMap.put('ToChangeBankAccCity', bankAcc.City__c);
					bankAccMap.put('ToChangeBankAccState', bankAcc.State__c);
					bankAccMap.put('ToChangeBankAccAccountNumber', bankAcc.Account_Number__c);
					bankAccMap.put('ToChangeBankAccTypeOfAccount', bankAcc.Type_of_Account__c);
					bankAccMap.put('ToChangeBankAccOtherAccountType', bankAcc.Other_Account_Type__c);
				}
				changeInBankAccountListMap.add(bankAccMap);
			}
            if(changeInBankAccountListMap.size()==0){
                Map<String, String> mapIfNoChangeDataFound = new  Map<String, String>{'isChangeInBankAccDataFoundReview'=>'false'};
                changeInBankAccountListMap.add(mapIfNoChangeDataFound);
            }
			outMap.put('ChangeInBankAccInfoList', changeInBankAccountListMap);
		} catch (Exception e) {
			LPI_ExceptionManager.logException(
				'LPI_AuditEscrowController',
				'fetchAuditChangeInBankAccountDetails',
				e
			);
		}
	}

	/**
	 * @author                      : MTX Group Product Team
	 * @since                       : 18 Jan 2023
	 * @description                 : This method fetches Bank Account Details
	 * @param inputMap              : Input data passed from OmniScript
	 * @param outMap                : Output data passed to OmniScript
	 * @return                      : `void`
	 * @last modified by            : MTX Group Product Team
	 * @last modified date          : 01 Feb 2023
	 * @last modified details       : Beautified the code with proper indentation
	 */

	public static void fetchBankAccountDetails(Map<String, Object> inputMap, Map<String, Object> outMap) {
		try {
			String parId = (String) inputMap.get('parId');
            
			List<Map<String, String>> bankAccountListMap = new List<Map<String, String>>();
			Integer noOfbankAcc = 0;
			String fieldsToQuery = 'Id,City__c, State__c,Status__c, Date_Closed__c,Name_of_Financial_Institution__c, Type_of_Account__c, Other_Account_Type__c, Account_Number__c, Contact_Person_at_financial_Institution__c, Email__c, Contact_Telephone_Number__c, Exact_Name_on_Account__c, Street_Address_1__c, Zip__c, Telephone_Number__c';
			String whereClause = ' Preliminary_Application_Reference__c = \'' +
					String.escapeSingleQuotes(parId) +
					'\' AND Status__c = \'' +
					LPI_LiteralConstant.BANK_ACCOUNT_STATUS_OPEN +
					'\'';
			 
			List<Bank_Account__c> bankAccList = new LPI_BankAccountDAO.LPI_BankAccountWithoutSharingDAO().getBankAccountByDymanicQuery(
				fieldsToQuery,
				whereClause,
				null,
				null,
				null
			);
			for (Bank_Account__c bankAcc : bankAccList) {
				noOfbankAcc = noOfbankAcc + 1;
				Map<String, String> bankAccMap = new Map<String, String>();
				bankAccMap.put('NoOfBankAcc', 'Account Information ' + noOfbankAcc);
				bankAccMap.put('NameOfFinancialInstitution', bankAcc.Name_of_Financial_Institution__c);
				bankAccMap.put('CityAccInfo', bankAcc.City__c);
				bankAccMap.put('StateAccInfo', bankAcc.State__c);
				bankAccMap.put('BankAccountNumber', bankAcc.Account_Number__c);
				bankAccMap.put('TypeOfAccount', bankAcc.Type_of_Account__c);
				bankAccMap.put('OtherAccountType', bankAcc.Other_Account_Type__c);
				bankAccMap.put(
					'ContactPersonatfinancialInstitution',
					bankAcc.Contact_Person_at_financial_Institution__c
				);
				bankAccMap.put('EmailAccInfo', bankAcc.Email__c);
				bankAccMap.put('ContactTelephoneNumber', bankAcc.Contact_Telephone_Number__c);
				bankAccMap.put('ExactNameonAccount', bankAcc.Exact_Name_on_Account__c);
				bankAccMap.put('ExactNameonAccountJA', bankAcc.Exact_Name_on_Account__c);
				bankAccMap.put('StreetAddressAccInfo', bankAcc.Street_Address_1__c);
				bankAccMap.put('ZipAccInfo', bankAcc.Zip__c);
				bankAccMap.put('TelephoneNumber', bankAcc.Telephone_Number__c);
				bankAccountListMap.add(bankAccMap);
			}
			outMap.put('BankAccountInfoList', bankAccountListMap);
		} catch (Exception e) {
			LPI_ExceptionManager.logException('LPI_AuditEscrowController', 'fetchBankAccountDetails', e);
		}
	}

	/**
	 * @author                      : MTX Group Product Team
	 * @since                       : 18 Jan 2023
	 * @description                 : This Method deletes Open Bank Account record
	 * @param inputMap              : Input data passed from OmniScript
	 * @param outMap                : Output data passed to OmniScript
	 * @return                      : `void`
	 * @last modified by            : MTX Group Product Team
	 * @last modified date          : 01 Feb 2023
	 * @last modified details       : Beautified the code with proper indentation
	 */

	public static void deleteOpenBankAccounts(
		Map<String, Object> inputMap
	) {
		try {
			String parId = (String) inputMap.get('parId');
			List<String> openBankAccIdsFromResponse = new List<String>();
			Map<String, object> escrowBankAccountInfo = (Map<String, object>) inputMap.get(
				'AuditEscrowORTrustAccountStep'
			);
			if((List<String>) JSON.deserialize(
				JSON.serialize(escrowBankAccountInfo.get('BankAccountIds')),
				List<String>.class
			) != NULL){
				openBankAccIdsFromResponse = (List<String>) JSON.deserialize(
				JSON.serialize(escrowBankAccountInfo.get('BankAccountIds')),
				List<String>.class
				);
			}
			List<PreliminaryApplicationRef> parList;
			if (String.isNotBlank(parId)) {
				String parfields = 'Id,New_Designated_in_charge_License_Number__c';
				String parWhereClause = 'Id = \'' + String.escapeSingleQuotes(parId) + '\'';
				parList = LPI_PreliminaryApplicationRefDAO.getPreliminaryApplicationRefByDymanicQuery(
					parfields,
					parWhereClause,
					null,
					null,
					null
				);
				if(!parList.isEmpty()){
					if(parList[0].New_Designated_in_charge_License_Number__c!=NULL){
						openBankAccIdsFromResponse.add(parList[0].New_Designated_in_charge_License_Number__c);
					}
				}
			}
            if(!openBankAccIdsFromResponse.isEmpty()){
                deleteBankAccounts(parId, openBankAccIdsFromResponse, LPI_LiteralConstant.BANK_ACCOUNT_STATUS_OPEN);
            }else{
				deleteBankAccounts(parId, null, LPI_LiteralConstant.BANK_ACCOUNT_STATUS_OPEN);
			}
		} catch (Exception e) {
			LPI_ExceptionManager.logException('LPI_AuditEscrowController', 'deleteOpenBankAccounts', e);
		}
	}
	

	public static void saveBankAccountDetails(Map<String, Object> inputMap, Map<String, Object> outMap) {
		try {
			String parId = (String) inputMap.get('parId');
			String businessAccId = (String) inputMap.get('businessAccId');
			Map<String, Object> escrowBankAccountInfo = (Map<String, Object>) inputMap.get(
				'AuditEscrowORTrustAccountStep'
			);
			List<sObject> upsertList = new List<sObject>();
			List<Object> bankAccountInfoList = new List<Object>();
            Map<String , String> keyMapping = new Map<String , String>{
                    'BankAccountNumber'=>'Account_Number__c',
                    'CityAccInfo'=>'City__c',
                    'ContactPersonatfinancialInstitution'=>'Contact_Person_at_financial_Institution__c',
                    'ContactTelephoneNumber'=>'Contact_Telephone_Number__c',
                    'EmailAccInfo'=>'Email__c',
                    'ExactNameonAccount'=>'Exact_Name_on_Account__c',
                    'ExactNameonAccountJA'=>'Exact_Name_on_Account__c',
                    'FomulaBankAccIdCalc'=>'Id',
					'NameOfFinancialInstitution'=>'Name_of_Financial_Institution__c',
					'OtherAccountType'=>'Other_Account_Type__c',
					'StateAccInfo'=>'State__c',
					'StreetAddressAccInfo'=>'Street_Address_1__c',
					'TelephoneNumber'=>'Telephone_Number__c',
					'TypeOfAccount'=>'Type_of_Account__c',
					'ZipAccInfo'=>'Zip__c'
            };
                        
			Integer bankAccountListCount = (Integer) escrowBankAccountInfo.get('bankAccountListCount');
			
			if (bankAccountListCount > 1) {
				bankAccountInfoList = (List<Object>) escrowBankAccountInfo.get('AddBankAccountBlock');
			} else {
				bankAccountInfoList.add(escrowBankAccountInfo.get('AddBankAccountBlock'));
			}
			
			for (Object bankInfo : bankAccountInfoList) {
				Map<String, Object> obj = (Map<String, Object>) bankInfo;
				Bank_Account__c bankAccountDetails = (Bank_Account__c) LPI_VlocityUtility.createSObject(obj, keyMapping, 'Bank_Account__c');
                bankAccountDetails.put('Preliminary_Application_Reference__c', parId);
                bankAccountDetails.put('Account__c', businessAccId);
                bankAccountDetails.put('Status__c', 'Open');
				upsertList.add(bankAccountDetails);
			}
			if (!upsertList.isEmpty()) {
				LPI_WithoutSharingUtility.upsertSObjectList(upsertList);
            }
		} catch (Exception e) {
			LPI_ExceptionManager.logException('LPI_AuditEscrowController', 'saveBankAccountDetails', e);
		}
	}

	public class BankAccountInfoWrapper {
		public String accountsClosedAccountNumber;
		public String dateClosed;
	}
}