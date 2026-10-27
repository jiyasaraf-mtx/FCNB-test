/**
 *
 * @author          : MTX Group Product Team | 22-07-2023
 * @description     : This class is used to contain all logics internal payment part from support staff.
 */
public with sharing class LPI_InternalPaymentController {
	
	private static final String ADDITIONAL_FEE = 'Additional Fee';
	private static final String MISSOURI = 'Missouri';
	private static final String PAYMENT_PENDING = 'Payment Pending';
	private static final String UNDERPAYMENT = 'UnderPayment';
	private static final String DRAFT = 'Draft';
	private static final String INDIVIDUAL_APPLICATION_TYPE = 'IndividualApplication';
	private static final String RENEWAL_TYPE = 'Renewal';
	private static final String APEP_BOARD_BUSINESS_REINSTATEMENT = 'Re-authorization';
    private static final String APEP_BOARD_INDIVIDUAL_REINSTATEMENT = 'Re-licensure';
	private static final String REINSTATEMENT_APPLICATIONTYPE = 'Reinstatement';
	private static final String AUTHORISATION_TYPE_BUSINESS = 'Business';
	private static final String APEP_BOARD_NAME = 'Architects, Engineers, Land Surveryors, and Landscape Architects';
	private static final String BAD_CHECK_STATUS = 'Bad Check';
	private static final String ACCOUNT_SOBJECT_API = 'Account';
	private static final String STATUS_DUE = 'Due';
	private static final String STATUS_DUE_API = 'DUE';

	private static final List<string> notAllowedList = new List<String>{
		'Credit',
		'Debit',
		'E-Check',
		'Offline',
		'Cheque'
	};
	 
	public static final String LICENSE_TYPE_APRN = 'Advanced Practice Registered Nurse';
	private final static String MISSOURI_STATE = 'Missouri';

	/**
	 * @author                    : MTX Group Product Team
	 * @description               : This Method is use to fetch Application SubType for internal payment Model
	 * @param  searchKey          : Entered data on type ahead box of Application SubType by user
	 * @return                    : return List of all Application SubType
	 * @exception                 : Handle the error in case unable to fetch data
	 */
	@AuraEnabled(cacheable=true)
	public static List<SelectOption> fetchFeeSubType(String selectedType, Id licenseType) {
		List<SelectOption> options = new List<SelectOption>();
		Set<String> uniqueOptions = new Set<String>();
		try {
			if (String.isBlank(selectedType) || licenseType == null) {
				return options;
			}
			String fieldsToQuery = 'Fee_Type__c,Fee_Sub_Type__c,Regulatory_Authorization_Type__r.IssuingDepartment.Name,Regulatory_Authorization_Type__r.Authorisation_Type__c';
			String whereClause =
				'Regulatory_Authorization_Type__c = \'' +
				licenseType +
				'\'' +
				' AND Fee_Type__c = \'' +
				String.escapeSingleQuotes(selectedType) +
				'\'';

			 
			Map<String,String> valueToLabelMap = new Map<String,String>();
			List<Fees__c> feesList = LPI_FeesDAO.getFeesByDymanicQuery(fieldsToQuery, whereClause, null, null, null);
			if(!feesList.isEmpty()){
				for(Schema.PicklistEntry pickEntry : Fees__c.Fee_Sub_Type__c.getDescribe().getPicklistValues()){
					if(
						feesList[0].Regulatory_Authorization_Type__r.IssuingDepartment.Name ==  APEP_BOARD_NAME && 
						feesList[0].Fee_Sub_Type__c == REINSTATEMENT_APPLICATIONTYPE
					){
						valueToLabelMap.put(pickEntry.getValue(), feesList[0].Regulatory_Authorization_Type__r.Authorisation_Type__c == AUTHORISATION_TYPE_BUSINESS ? APEP_BOARD_BUSINESS_REINSTATEMENT : APEP_BOARD_INDIVIDUAL_REINSTATEMENT);
					} else {
						valueToLabelMap.put(pickEntry.getValue(),pickEntry.getLabel());
					}
				}
	
				for (Fees__c fee : feesList) {
					if (!uniqueOptions.contains(fee.Fee_Sub_Type__c) && valueToLabelMap.containsKey(fee.Fee_Sub_Type__c)) {
						 
						options.add(new SelectOption(valueToLabelMap.get(fee.Fee_Sub_Type__c),fee.Fee_Sub_Type__c));
						uniqueOptions.add(fee.Fee_Sub_Type__c);
					}
				}
			}
			return options;
		} catch (Exception e) {
			LPI_ExceptionManager.logException('LPI_InternalPaymentController', 'fetchFeeSubType', e);
			throw new AuraHandledException(e.getMessage());
		}
	}

	/**
	 * @author                    : MTX Group Product Team
	 * @description               : This Method is use to fetch Payment Type for internal payment Information part
	 * @return                    : return List of all payment Type from Payment method field of Temp Fee Object
	 * @exception                 : Handle the error in case unable to fetch data
	 */
	@AuraEnabled(cacheable=true)
	public static List<SelectOption> fetchPaymentType() {
		try {
			List<SelectOption> options = new List<SelectOption>();
			Schema.DescribeFieldResult fieldResult = Temp_Fee__c.Payment_Method__c.getDescribe();
			List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
			for (Schema.PicklistEntry f : ple) {
				if (f.getValue() != 'Offline') {
					options.add(new SelectOption(f.getLabel(), f.getValue()));
				}
			}
			return options;
		} catch (Exception e) {
			LPI_ExceptionManager.logException('LPI_InternalPaymentController', 'fetchPaymentType', e);
			throw new AuraHandledException(e.getMessage());
		}
	}

	/**
	 * @author                    : MTX Group Product Team
	 * @description               : This Method is use to fetch process for internal payment Information part
	 * @return                    : return List of all process from deposit method field of Temp Fee Object
	 * @exception                 : Handle the error in case unable to fetch data
	 */
	@AuraEnabled(cacheable=true)
	public static List<SelectOption> fetchProcess() {
		List<SelectOption> options = new List<SelectOption>();
		try {
			Schema.DescribeFieldResult fieldResult = Temp_Fee__c.Deposit_Method__c.getDescribe();
			List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
			for (Schema.PicklistEntry f : ple) {
				options.add(new SelectOption(f.getLabel(), f.getValue()));
			}

			return options;
		} catch (Exception e) {
			LPI_ExceptionManager.logException('LPI_InternalPaymentController', 'fetchProcess', e);
			throw new AuraHandledException(e.getMessage());
		}
	}

	/**
	 * @author                    : MTX Group Product Team
	 * @description               : This Method is use to fetch process for internal payment Information part
	 * @return                    : return List of all process from deposit method field of Temp Fee Object
	 * @exception                 : Handle the error in case unable to fetch data
	 */
	@AuraEnabled(cacheable=true)
	public static List<SelectOption> fetchExceptionReason() {
		List<SelectOption> options = new List<SelectOption>();
		try {
			Schema.DescribeFieldResult fieldResult = Temp_Fee__c.Exemption_Reason__c.getDescribe();
			List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
			for (Schema.PicklistEntry f : ple) {
				options.add(new SelectOption(f.getLabel(), f.getValue()));
			}

			return options;
		} catch (Exception e) {
			LPI_ExceptionManager.logException('LPI_InternalPaymentController', 'fetchExceptionReason', e);
			throw new AuraHandledException(e.getMessage());
		}
	}

	/**
	 * @author                    : MTX Group Product Team
	 * @description               : Returns navigation payload for Complete Pending Payment (same inputs as lpiPendingPaymentComp)
	 * @param recordId            : IndividualApplication or BusinessLicenseApplication Id
	 * @return                    : Map with application/license/account/RTF fields for pending payment UI
	 */
	@AuraEnabled
	public static Map<String, Object> getCompletePendingPaymentNavData(Id recordId) {
		try {
			if (recordId == null) {
				throw new AuraHandledException('Record Id is required.');
			}
			String objectType = String.valueOf(recordId.getSObjectType());
			String fieldsToQuery =
				'Id, AccountId, LicenseTypeId, ApplicationType, Amendment_Type__c, Payment_Pending__c';
			String whereClause = 'Id = \'' + String.escapeSingleQuotes(recordId) + '\'';
			List<SObject> appList;
			if (objectType == INDIVIDUAL_APPLICATION_TYPE) {
				appList = LPI_IndividualApplicationDAO.getIndividualApplicationByDymanicQuery(
					fieldsToQuery,
					whereClause,
					null,
					null,
					null
				);
			} else {
				appList = LPI_BusinessLicenseApplicationDAO.getBusinessLicenseApplicationByDymanicQuery(
					fieldsToQuery,
					whereClause,
					null,
					null,
					null
				);
			}
			if (appList == null || appList.isEmpty()) {
				throw new AuraHandledException('Application record not found.');
			}
			SObject appRecord = appList[0];
			String applicationId = (String) appRecord.get('Id');
			String unpaidRtfId = getLatestUnpaidRegTrxFeeId(applicationId);
			Boolean isPaymentPending =
				(Boolean) appRecord.get('Payment_Pending__c') == true || String.isNotBlank(unpaidRtfId);
			// Portal skipPayment can create unpaid RTF without setting Payment_Pending__c — sync it
			if (isPaymentPending && (Boolean) appRecord.get('Payment_Pending__c') != true) {
				SObject appToUpdate = objectType == INDIVIDUAL_APPLICATION_TYPE
					? (SObject) new IndividualApplication(Id = applicationId, Payment_Pending__c = true)
					: (SObject) new BusinessLicenseApplication(Id = applicationId, Payment_Pending__c = true);
				LPI_WithoutSharingUtility.updateSObjectList(new List<SObject>{ appToUpdate });
			}
			Map<String, Object> navData = new Map<String, Object>();
			navData.put('applicationId', applicationId);
			navData.put('licenseTypeId', (String) appRecord.get('LicenseTypeId'));
			navData.put('accId', (String) appRecord.get('AccountId'));
			navData.put('objectType', objectType);
			navData.put('applicationType', (String) appRecord.get('ApplicationType'));
			navData.put('applicationSubType', (String) appRecord.get('Amendment_Type__c'));
			navData.put('isPaymentPending', isPaymentPending);
			navData.put('regTrxFeeId', unpaidRtfId);
			return navData;
		} catch (AuraHandledException ahe) {
			throw ahe;
		} catch (Exception e) {
			LPI_ExceptionManager.logException('LPI_InternalPaymentController', 'getCompletePendingPaymentNavData', e);
			throw new AuraHandledException(e.getMessage());
		}
	}

	/**
	 * @description Returns latest unpaid Regulatory Transaction Fee Id for an application
	 */
	private static String getLatestUnpaidRegTrxFeeId(String applicationId) {
		if (String.isBlank(applicationId)) {
			return null;
		}
		String whereClause =
			'ParentRecordId = \'' +
			String.escapeSingleQuotes(applicationId) +
			'\' AND (Status__c = \'' +
			PAYMENT_PENDING +
			'\' OR Status = \'' +
			STATUS_DUE +
			'\' OR Status = \'' +
			STATUS_DUE_API +
			'\')';
		List<RegulatoryTrxnFee> rtfList = LPI_RegulatoryTrxnFeeDAO.getRegulatoryTrxnFeeByDymanicQuery(
			'Id',
			whereClause,
			'1',
			'CreatedDate',
			'DESC'
		);
		return rtfList.isEmpty() ? null : rtfList[0].Id;
	}

	/**
	 * @author                    : MTX Group Product Team
	 * @description               : This Method will fetch most recent Underpayment fees
	 * @param applicationId       : Application Id
	 * @param regTrxFeeId         : Optional Regulatory Transaction Fee Id
	 * @param fetchBadCheckFee    : Whether to fetch bad check fee
	 * @return                    : return FeeDetailsFromRatWrapper
	 * @exception                 : Handle the error in case unable to fetch data
	 */
	@AuraEnabled
	public static List<FeeDetailsFromRatWrapper> fetchUnderpaymentFees(
		String applicationId,
		String regTrxFeeId,
		Boolean fetchBadCheckFee
	) {
		try {
			String whereClause = '';
			String queryFields =
				'Id,Name,Status,Status__c,(SELECT Name,FeeAmount,Remaining_Amount__c,Actual_Asked_Amount__c,Object_Code__c FROM RegulatoryTrxnFeeItems)';
			if (fetchBadCheckFee) {
				whereClause +=
					'Id = \'' +
					String.escapeSingleQuotes(regTrxFeeId) +
					'\' AND Status__c = \'' +
					BAD_CHECK_STATUS +
					'\'';
			} else if (String.isNotBlank(regTrxFeeId)) {
				whereClause += 'Id = \'' + String.escapeSingleQuotes(regTrxFeeId) + '\'';
			} else {
				whereClause +=
					'ParentRecordId = \'' +
					String.escapeSingleQuotes(applicationId) +
					'\' AND (Status__c = \'' +
					PAYMENT_PENDING +
					'\' OR Status = \'' +
					STATUS_DUE +
					'\' OR Status = \'' +
					STATUS_DUE_API +
					'\')';
			}
			List<RegulatoryTrxnFee> rtfList = LPI_RegulatoryTrxnFeeDAO.getRegulatoryTrxnFeeByDymanicQuery(
				queryFields,
				whereClause,
				'1',
				'CreatedDate',
				'DESC'
			);

			if (!rtfList.isEmpty()) {
				List<FeeDetailsFromRatWrapper> feeWrapperList = new List<FeeDetailsFromRatWrapper>();
				Integer count = 1;
				for (RegulatoryTrxnFeeItem feeItem : rtfList[0].RegulatoryTrxnFeeItems) {
					Decimal amount;
					if (fetchBadCheckFee) {
						amount = feeItem.FeeAmount;
					} else if (feeItem.Remaining_Amount__c != null && feeItem.Remaining_Amount__c != 0) {
						amount = feeItem.Remaining_Amount__c;
					} else if (feeItem.FeeAmount != null && feeItem.FeeAmount != 0) {
						amount = feeItem.FeeAmount;
					} else {
						amount = feeItem.Actual_Asked_Amount__c;
					}
					if (amount == null || amount == 0) {
						continue;
					}
					FeeDetailsFromRatWrapper feeWrapper = new FeeDetailsFromRatWrapper();
					feeWrapper.Id = count;
					feeWrapper.Name = feeItem.Name;
					feeWrapper.Amount = amount;
					feeWrapper.disableMenu = false;
					feeWrapper.regTrxFeeId = rtfList[0].Id;
					feeWrapper.objectCode = feeItem.Object_Code__c;
					feeWrapper.actualAskedAmount = feeItem.Actual_Asked_Amount__c != null
						? feeItem.Actual_Asked_Amount__c
						: amount;
					feeWrapperList.add(feeWrapper);
					count++;
				}
				return feeWrapperList.isEmpty() ? null : feeWrapperList;
			}
			return null;
		} catch (Exception e) {
			LPI_ExceptionManager.logException('LPI_InternalPaymentController', 'fetchUnderpaymentFees', e);
			throw new AuraHandledException(e.getMessage());
		}
	}

	/**
	 * @author                      : MTX Group Product Team
     * @since                       : July 23, 2023
	 * @description                 : This Method is use to fetch FeeList from RAT and display it on UI
	 * @param ratId                 : Regulatory Authorization Type Id
	 * @param type                  : Application Type
	 * @param subtype               : Application SubType
	 * @param parId                 : Preliminary Application Ref Id
	 * @return                      : `FeeDetailsFromRatWrapper`
	 * @exception                   : Handle the error in case unable to fetch data
	 * @last modified by            : MTX Group Product Team
	 * @last modified date          : February 19, 2024
	 * @last modified details       : Code Beautification and fix for I-263648
	 */
	@AuraEnabled(cacheable=true)
	public static List<FeeDetailsFromRatWrapper> fetchFeeFromRat(String ratId, String type, String subtype, String parId) {
		List<FeeDetailsFromRatWrapper> feeWrapperList = new List<FeeDetailsFromRatWrapper>();
		List<PreliminaryApplicationRef> parList = new List<PreliminaryApplicationRef>();
		try {
			if (String.isNotBlank(parId)) {
				parList = LPI_PreliminaryApplicationRefDAO.getPreliminaryApplicationRefByDymanicQuery(
					'Id, Business_License__c, Late_Renewal__c, Business_License__r.PeriodEnd',
					'Id = \'' + String.escapeSingleQuotes(parId) + '\'', null, null, null);
			}
            if (!parList.isEmpty()) {
                List<Fees__c> feeList = LPI_FeesDAO.getFeesByDymanicQuery(
                    'Name, Fee_Amount__c, Object_Code__c, Is_Late_Renewal__c, Fee_Type__c, Is_Late_Fee_Static__c, ' +
                    'Regulatory_Authorization_Type__r.Name, Regulatory_Authorization_Type__r.Grace_Period__c',
                    'Regulatory_Authorization_Type__c = \'' + String.escapeSingleQuotes(ratId) + '\'' +
                    ' AND Fee_Type__c = \'' + String.escapeSingleQuotes(type) + '\'' +
                    ' AND Fee_Sub_Type__c = \'' + String.escapeSingleQuotes(subtype) + '\'' + 
                    ' AND Is_Online_Fee__c = false ', null, null, null);
                Integer i = 0;
                if (!feeList.isEmpty()) {
                    for (Fees__c fee : feeList) {
                        Decimal feeAmount = 0;
                        Date expDate = parList[0].Business_License__r.PeriodEnd != null ? Date.newInstance(parList[0].Business_License__r.PeriodEnd.year(), parList[0].Business_License__r.PeriodEnd.month(), parList[0].Business_License__r.PeriodEnd.day()) : null;
                        if (fee.Fee_Type__c == RENEWAL_TYPE) {
                            if (fee.Is_Late_Renewal__c && !parList[0].Late_Renewal__c) {
                                continue;
                            }
                             
                            if (fee.Regulatory_Authorization_Type__r.Name == LICENSE_TYPE_APRN ) {
                                feeAmount = 85;
                            } 
                            else {
                                feeAmount = fee.Is_Late_Renewal__c && parList[0].Late_Renewal__c ? LPI_FetchFeeDetails.getLateRenewalAmount(expDate, fee) : fee.Fee_Amount__c;
                            }
                        } 
                        else {
                            feeAmount = fee.Fee_Amount__c;
                        }
                         
                        FeeDetailsFromRatWrapper feeWrapper = new FeeDetailsFromRatWrapper();
                        feeWrapper.Id = i;
                        feeWrapper.Name = fee.Name;
                        if (parList[0].Business_License__c != null) {
                             
                                feeWrapper.Amount = feeAmount;
                             
                        } 
                        else {
                            feeWrapper.Amount = feeAmount;
                        }
                        feeWrapper.disableMenu = false;
                        feeWrapper.objectCode = fee.Object_Code__c;
                        feeWrapperList.add(feeWrapper);
                        i = i + 1;
                    }
                }
            }
			return feeWrapperList;
		} 
        catch (Exception e) {
			LPI_ExceptionManager.logException('LPI_InternalPaymentController', 'fetchFeeFromRat', e);
			throw new AuraHandledException(e.getMessage());
		}
	}

	/**
	 * @author                    : MTX Group Product Team
	 * @description               : This Method is use to fetch FeeType for Additional fee
	 * @param ratId               : License Type Id
	 * @return                    : return List of Fees
	 * @exception                 : Handle the error in case unable to fetch data
	 */
	@AuraEnabled(cacheable=true)
	public static List<AdditionalFeeTypeWrapper> fetchAdditionalFeeTypeFromRat(string ratId) {
		List<AdditionalFeeTypeWrapper> feeTypeListWrapper = new List<AdditionalFeeTypeWrapper>();
		try {
			if (String.isBlank(ratId)) {
				return feeTypeListWrapper;
			}
			for (
				Fees__c fee : LPI_FeesDAO.getFeesByDymanicQuery(
					'Id,Name,Fee_Amount__c,Object_Code__c',
					'Regulatory_Authorization_Type__c = \'' +
						String.escapeSingleQuotes(ratId) +
						'\'' +
						' AND Fee_Type__c = \'' +
						ADDITIONAL_FEE +
						'\'' +
						' AND Fee_Sub_Type__c = \'' +
						ADDITIONAL_FEE +
						'\'',
					null,
					null,
					null
				)
			) {
				AdditionalFeeTypeWrapper feeTypeWr = new AdditionalFeeTypeWrapper();
				feeTypeWr.Name = fee.Name;
				feeTypeWr.Amount = fee.Fee_Amount__c;
				feeTypeWr.objectCode = fee.Object_Code__c;
				feeTypeListWrapper.add(feeTypeWr);
			}
			return feeTypeListWrapper;
		} catch (Exception e) {
			LPI_ExceptionManager.logException('LPI_InternalPaymentController', 'fetchAdditionalFeeTypeFromRat', e);
			throw new AuraHandledException(e.getMessage());
		}
	}

	/**
	 * @author                    : MTX Group Product Team
	 * @description               : This Method is use to save all data in PAR
	 * @param feeList             : FeeDetailsFromRatWrapper in List format from LWC
	 * @param paymentInformation  : Payment Information in JSON Format
	 * @return                    : return FeeDetailsFromRatWrapper
	 * @exception                 : Handle the error in case unable to fetch data
	 */
	@AuraEnabled
	public static Boolean saveDetails(
		List<FeeDetailsFromRatWrapper> feeList,
		String paymentInformation,
		String accountId,
		Decimal remainingAmount
	) {
		try {
			PaymentInformationWrapper paymentDetails = (PaymentInformationWrapper) JSON.deserializeStrict(
				paymentInformation,
				PaymentInformationWrapper.class
			);

			Decimal sum = 0;
			if (!feeList.isEmpty()) {
				for (integer i = 0; i < feeList.size(); i++) {
					if (feeList[i].Name != UNDERPAYMENT) {
						sum += feeList[i].Amount;
					}
				}
			}

			String accountName = LPI_AccountDAO.getAccountListByDynamicQuery(
					new List<String>{ 'Name' },
					'Id =\'' + String.escapeSingleQuotes(accountId) + '\'',
					null,
					null,
					null
				)[0]
				.Name;

			List<Temp_Fee_Item__c> tempFeeItemList = new List<Temp_Fee_Item__c>();
			 
			Temp_Fee__c tempFee = new Temp_Fee__c();
			tempFee.PreliminaryApplicationReference__c = paymentDetails.parId;
			tempFee.Transaction_ID__c = paymentDetails.checkNumber;
			tempFee.Amount_Tendered__c = String.isBlank(paymentDetails.amountTendered)
				? 0
				: Decimal.valueOf(paymentDetails.amountTendered);
			if (paymentDetails.paidBySomeoneOther != null) {
				tempFee.Paid_by_someone_other_than_applicant__c = Boolean.valueOf(
					paymentDetails.paidBySomeoneOther
				);
				tempFee.Payer_Phone_Number__c = paymentDetails.payerPhone;
			}
			if (paymentDetails.payerName == null) {
				tempFee.Payer_Full_Name_Company_Name__c = accountName;
			} else {
				tempFee.Payer_Full_Name_Company_Name__c = paymentDetails.payerName;
			}

			if (paymentDetails.exempt == 'true') {
				if (paymentDetails.paymentType == null) {
					tempFee.Payment_Method__c = 'Offline';
				} else {
					tempFee.Payment_Method__c = paymentDetails.paymentType;
				}
				if (paymentDetails.process == null) {
					tempFee.Deposit_Method__c = 'CRR';
				} else {
					tempFee.Deposit_Method__c = paymentDetails.process;
				}
				tempFee.FeeAmount__c = 0;
				tempFee.Status__c = LPI_LiteralConstant.REG_PAID;
			} else {
				tempFee.Payment_Method__c = paymentDetails.paymentType;
				tempFee.Deposit_Method__c = paymentDetails.process;
				tempFee.FeeAmount__c = sum;
				if (remainingAmount != 0) {
					tempFee.Status__c = PAYMENT_PENDING;
				} else {
					tempFee.Status__c = LPI_LiteralConstant.REG_PAID;
				}
			}

			tempFee.Memo__c = paymentDetails.memoText;
			tempFee.Fee_State__c = MISSOURI;
			tempFee.Transaction_Date__c = System.now();
			if (paymentDetails.exempt != null) {
				tempFee.Exempt__c = Boolean.valueOf(paymentDetails.exempt);
				tempFee.Exemption_Reason__c = paymentDetails.exemptionReason;
			}
			tempFee = (Temp_Fee__c) LPI_DML.doInsert(tempFee);

			 
			if (!feeList.isEmpty()) {
				for (integer i = 0; i < feeList.size(); i++) {
					Temp_Fee_Item__c tempFeeItem = new Temp_Fee_Item__c();
					tempFeeItem.Temp_Fee__c = tempFee.Id;
					tempFeeItem.Name = feeList[i].Name;
					tempFeeItem.Object_Code__c = feeList[i].objectCode;
					
					if(paymentDetails.exempt == 'true'){
						tempFeeItem.FeeAmount__c = 0;
						tempFeeItem.Actual_Asked_Amount__c = 0;
					} else {
						tempFeeItem.FeeAmount__c = feeList[i].Amount;
						tempFeeItem.Actual_Asked_Amount__c = feeList[i].actualAskedAmount;
					}
					tempFeeItemList.add(tempFeeItem);
				}
			}
			if (!tempFeeItemList.isEmpty()) {
				LPI_DML.doInsert(tempFeeItemList);
			}

			 
			if (paymentDetails.parId != null) {
				PreliminaryApplicationRef par = new PreliminaryApplicationRef(id = paymentDetails.parId);
				par.Is_Submitted_By_Internal_User__c = true;
				 
				LPI_DML.doUpdate(par);
				return true;
			} else {
				return false;
			}
		} catch (Exception e) {
			LPI_ExceptionManager.logException('LPI_InternalPaymentController', 'saveDetails', e);
			throw new LPI_Exception(e.getMessage());
		}
	}

	/**
	 * @author                    : MTX Group Product Team
	 * @description               : This Method will return IA/BLA Id so that we can navigate on to the respective record page after payment page
	 * @return                    : (String) IA/BLA Id
	 * @exception                 : Handle the error in case unable to fetch data
	 */
	@AuraEnabled
	public static String fetchApplicationIdForNav(
		String licenseTypeId,
		String accId,
		String applicationType,
		String applicationSubType
	) {
		List<PreliminaryApplicationRef> parList = LPI_PreliminaryApplicationRefDAO.getPreliminaryApplicationRefByDymanicQuery(
			'Id,ApplicationType',
			'Regulatory_Authorization_Type__c = \'' +
				String.escapeSingleQuotes(licenseTypeId) +
				'\'' +
				' AND BusinessAccountNameId = \'' +
				String.escapeSingleQuotes(accId) +
				'\'' +
				' AND Is_Submitted_By_Internal_User__c = ' +
				true +
				' AND Status__c = \'' +
				DRAFT +
				'\'' +
				'AND Type__c = \'' +
				applicationType +
				'\'' +
				'AND Amendment_Type__c = \'' +
				String.escapeSingleQuotes(applicationSubType) +
				'\'',
			'1',
			'CreatedDate',
			'DESC'
		);
		if (!parList.isEmpty()) {
			if (parList[0].ApplicationType == INDIVIDUAL_APPLICATION_TYPE) {
				List<IndividualApplication> iaList = LPI_IndividualApplicationDAO.getIndividualApplicationByDymanicQuery(
					'Id',
					'SavedApplicationRefId = \'' + parList[0].Id + '\'',
					null,
					null,
					null
				);
				if (!iaList.isEmpty()) {
					return parList[0].ApplicationType + '-' + iaList[0].Id;
				}
			} else {
				List<BusinessLicenseApplication> blaList = LPI_BusinessLicenseApplicationDAO.getBusinessLicenseApplicationByDymanicQuery(
					'Id',
					'SavedApplicationRefId = \'' + parList[0].Id + '\'',
					null,
					null,
					null
				);
				if (!blaList.isEmpty()) {
					return parList[0].ApplicationType + '-' + blaList[0].Id;
				}
			}
		}
		return null;
	}

	/**
	 * @author                    : MTX Group Product Team
	 * @description               : This Method is use to save pending payment data in on IA/BLA
	 * @return                    : Boolean
	 * @exception                 : Handle the error in case unable to fetch data
	 */
	@AuraEnabled
	public static String savePendingPaymentData(
		List<FeeDetailsFromRatWrapper> feeList,
		String paymentInformation,
		String applicationId,
		String accountId,
		Decimal remainingAmount,
		Boolean isBadCheckPayment,
		String boardName,
		String badCheckRegTrxFeeId
	) {
		try {
			Decimal sum = 0;
			if (!feeList.isEmpty()) {
				for (integer i = 0; i < feeList.size(); i++) {
					sum += feeList[i].Amount;
				}
			}

			String accountName = LPI_AccountDAO.getAccountListByDynamicQuery(
					new List<String>{ 'Name' },
					'Id =\'' + String.escapeSingleQuotes(accountId) + '\'',
					null,
					null,
					null
				)[0]
				.Name;

			PaymentInformationWrapper paymentDetails = (PaymentInformationWrapper) JSON.deserializeStrict(
				paymentInformation,
				PaymentInformationWrapper.class
			);

			// Complete Pending Payment (skipPayment): update existing unpaid RTF — do not insert a duplicate
			Boolean updateExistingUnpaidRtf =
				isBadCheckPayment != true &&
				String.isNotBlank(badCheckRegTrxFeeId) &&
				(remainingAmount == null || remainingAmount == 0);

			RegulatoryTrxnFee regTrxnFee = new RegulatoryTrxnFee();
			if (updateExistingUnpaidRtf) {
				regTrxnFee.Id = badCheckRegTrxFeeId;
			}
			regTrxnFee.Transaction_ID__c = paymentDetails.checkNumber;
			regTrxnFee.ParentRecordId = applicationId;
			regTrxnFee.AccountId = accountId;
			regTrxnFee.Board_Name__c = boardName;
			regTrxnFee.Amount_Tendered__c = String.isBlank(paymentDetails.amountTendered)
				? 0
				: Decimal.valueOf(paymentDetails.amountTendered);
			if (paymentDetails.paidBySomeoneOther != null) {
				regTrxnFee.Paid_by_someone_other_than_applicant__c = Boolean.valueOf(paymentDetails.paidBySomeoneOther);
				regTrxnFee.Payer_Phone_Number__c = paymentDetails.payerPhone;
			}
			if (paymentDetails.payerName == null) {
				regTrxnFee.Payer_Full_Name__c = accountName;
			} else {
				regTrxnFee.Payer_Full_Name__c = paymentDetails.payerName;
			}

			regTrxnFee.Payment_Method__c = paymentDetails.paymentType;
			regTrxnFee.Deposit_Method__c = paymentDetails.process;
			regTrxnFee.Comments = paymentDetails.memoText;
			regTrxnFee.Status = LPI_LiteralConstant.REG_PAID;
			if (remainingAmount != null && remainingAmount != 0) {
				regTrxnFee.Status__c = PAYMENT_PENDING;
			} else {
				regTrxnFee.Status__c = LPI_LiteralConstant.FEE_PAID_STATUS;
			}
			regTrxnFee.Fee_State__c = MISSOURI;
			regTrxnFee.Transaction_Date__c = System.now();
			if (paymentDetails.exempt != null) {
				regTrxnFee.Exempt__c = Boolean.valueOf(paymentDetails.exempt);
				regTrxnFee.Exemption_Reason__c = paymentDetails.exemptionReason;
			}

			if (updateExistingUnpaidRtf) {
				LPI_DML.doUpdate(regTrxnFee);
				return regTrxnFee.Id;
			}

			regTrxnFee = (RegulatoryTrxnFee) LPI_DML.doInsert(regTrxnFee);

			List<RegulatoryTrxnFeeItem> regTrxnFeeItemList = new List<RegulatoryTrxnFeeItem>();
			if (!feeList.isEmpty()) {
				for (integer i = 0; i < feeList.size(); i++) {
					RegulatoryTrxnFeeItem regTrxnFeeItem = new RegulatoryTrxnFeeItem();
					regTrxnFeeItem.RegulatoryTrxnFeeId = regTrxnFee.Id;
					regTrxnFeeItem.Name = feeList[i].Name;
					regTrxnFeeItem.FeeAmount = feeList[i].Amount;
					regTrxnFeeItem.Object_Code__c = feeList[i].objectCode;
					regTrxnFeeItem.Actual_Asked_Amount__c = feeList[i].actualAskedAmount;
					regTrxnFeeItemList.add(regTrxnFeeItem);
				}
			}
			if (!regTrxnFeeItemList.isEmpty()) {
				LPI_DML.doInsert(regTrxnFeeItemList);
			}
			if(isBadCheckPayment){
				RegulatoryTrxnFee rtf = new RegulatoryTrxnFee();
				rtf.Id = badCheckRegTrxFeeId;
				rtf.Fee_Against_Bad_Check__c = regTrxnFee.Id;
				LPI_DML.doUpdate(rtf);
			}
			return regTrxnFee.Id;
		} catch (Exception e) {
			LPI_ExceptionManager.logException('LPI_InternalPaymentController', 'savePendingPaymentData', e);
			throw new LPI_Exception(e.getMessage());
		}
	}

	/**
	 * @author                    : MTX Group Product Team
	 * @description               : This Method check if there is any PAR in draft status then delete that PAR
	 * @param feeList             : FeeDetailsFromRatWrapper in List format from LWC
	 * @param paymentInformation  : Payment Information in JSON Format
	 * @return                    : return FeeDetailsFromRatWrapper
	 * @exception                 : Handle the error in case unable to fetch data
	 */
	@AuraEnabled
	public static Boolean checkPARExistInDraftOrNot(string accountId, String licenseId) {
		try {
			if (String.isBlank(accountId) || String.isBlank(licenseId)) {
				return true;
			}
			List<User> userList = LPI_UserDao.getCurrentUserRecord();

			List<PreliminaryApplicationRef> parList = LPI_PreliminaryApplicationRefDAO.getPreliminaryApplicationRefByDymanicQuery(
				'Id',
				'Regulatory_Authorization_Type__c = \'' +
					String.escapeSingleQuotes(licenseId) +
					'\'' +
					' AND BusinessAccountNameId = \'' +
					String.escapeSingleQuotes(accountId) +
					'\'' +
					' AND Is_Submitted_By_Internal_User__c = ' +
					false +
					' AND Status__c =\'' +
					DRAFT +
					'\'',
				'10',
				'CreatedDate',
				'desc'
			);
			if (!parList.isEmpty()) {
				LPI_WithoutSharingUtility.deleteSObject(parList[0]);
				return true;
			} else {
				return true;
			}
		} catch (Exception e) {
			LPI_ExceptionManager.logException('LPI_InternalPaymentController', 'checkPARExistInDraftOrNot', e);
			throw new AuraHandledException(e.getMessage());
		}
	}

	/**
	 * @author                    : MTX Group Product Team
	 * @description               : This Method is use to check license is exempted or Not
	 * @param parId               : ParId
	 * @return                    :
	 * @exception                 :
	 */
	@AuraEnabled(cacheable=true)
	public static Date checkExemptedOrNot(string parId, String type) {
		try {
			Date exemptionDate;
			if (type != 'New') {
				List<PreliminaryApplicationRef> parList = LPI_PreliminaryApplicationRefDAO.getPreliminaryApplicationRefByDymanicQuery(
					'Id,Business_License__r.Exemption_Expiry_Date__c',
					'Id =\'' + String.escapeSingleQuotes(parId) + '\'',
					null,
					null,
					null
				);
				if (
					!parList.isEmpty() &&
					parList[0].Business_License__c != null &&
					parList[0].Business_License__r.Exemption_Expiry_Date__c != null
				) {
					exemptionDate = parList[0].Business_License__r.Exemption_Expiry_Date__c;
				}
			}
			return exemptionDate;
		} catch (Exception e) {
			LPI_ExceptionManager.logException('LPI_InternalPaymentController', 'checkExemptedOrNot', e);
			throw new AuraHandledException(e.getMessage());
		}
	}

	/**
	 * @author                    : MTX Group Product Team
	 * @description               : This Method will give license related information to show on payment screen
	 * @param recordId            : Id
	 * @return                    : return Map<String, String>
	 * @exception                 : Handle the error in case unable to fetch data
	 */
	@AuraEnabled
	public static Map<String, String> getLicenseDetail(Id recordId) {
		try {
			Map<String, String> resultMap = new Map<String, String>();
			String objectType = String.valueOf(recordId.getSObjectType());

			if (objectType == LPI_LiteralConstant.BUSINESSLICENSE_SOBJECT_API) {
				String fieldToQuery = 'Legacy_License_Number__c,Name,Account.Name,RegulatoryAuthorizationType.IssuingDepartment.Name,RegulatoryAuthorizationType.Authorisation_Type__c';
				String whereClause = 'Id = \'' + recordId + '\'';
				List<BusinessLicense> blList = LPI_BusinessLicenseDAO.fetchBusinessLicenseRecordsWithOrderByLimit(
					fieldToQuery,
					whereClause,
					null,
					null
				);
				if (!blList.isEmpty()) {
					resultMap.put('licenseeName', blList[0].Account.Name);
					resultMap.put(
						'licenseNumber',
						String.isNotBlank(blList[0].Legacy_License_Number__c)
							? blList[0].Legacy_License_Number__c
							: blList[0].Name
					);
					resultMap.put('boardName', blList[0].RegulatoryAuthorizationType.IssuingDepartment.Name);		
					resultMap.put('authorisationType', blList[0].RegulatoryAuthorizationType.Authorisation_Type__c);			
				}
			} else if (objectType == LPI_LiteralConstant.IA_SOBJECT_API) {
				String fieldToQuery =
					'LicensePermitNameId, LicensePermitName.Name, LicensePermitName.Legacy_License_Number__c, ' +
					'LicensePermitName.Account.Name,'+
					'LicenseType.IssuingDepartment.Name,LicenseType.Authorisation_Type__c';
				String whereClause = 'Id = \'' + recordId + '\'';
				List<IndividualApplication> iaList = LPI_IndividualApplicationDAO.getIndividualApplicationByDymanicQuery(
					fieldToQuery,
					whereClause,
					null,
					null,
					null
				);
				if (!iaList.isEmpty()) {
					if(iaList[0].LicensePermitNameId != null){
						resultMap.put('licenseeName', iaList[0].LicensePermitName.Account.Name);
						resultMap.put(
							'licenseNumber',
							String.isNotBlank(iaList[0].LicensePermitName.Legacy_License_Number__c)
								? iaList[0].LicensePermitName.Legacy_License_Number__c
								: iaList[0].LicensePermitName.Name
						);	
					}
					resultMap.put('boardName', iaList[0].LicenseType.IssuingDepartment.Name);		
					resultMap.put('authorisationType', iaList[0].LicenseType.Authorisation_Type__c);
				}
			} else if (objectType == LPI_LiteralConstant.BLA_SOBJECT_API) {
				String fieldToQuery =
					'LicensePermitNameId, LicensePermitName.Name, LicensePermitName.Legacy_License_Number__c, ' +
					'LicensePermitName.Account.Name,'+
					'LicenseType.IssuingDepartment.Name,LicenseType.Authorisation_Type__c';
				String whereClause = 'Id = \'' + recordId + '\'';
				List<BusinessLicenseApplication> blaList = LPI_BusinessLicenseApplicationDAO.getBusinessLicenseApplicationByDymanicQuery(
					fieldToQuery,
					whereClause,
					null,
					null,
					null
				);
				if (!blaList.isEmpty()) {
					if(blaList[0].LicensePermitNameId != null){
						resultMap.put('licenseeName', blaList[0].LicensePermitName.Account.Name);
						resultMap.put(
							'licenseNumber',
							String.isNotBlank(blaList[0].LicensePermitName.Legacy_License_Number__c)
								? blaList[0].LicensePermitName.Legacy_License_Number__c
								: blaList[0].LicensePermitName.Name
						);
					}
					resultMap.put('boardName', blaList[0].LicenseType.IssuingDepartment.Name);		
					resultMap.put('authorisationType', blaList[0].LicenseType.Authorisation_Type__c);	
				}
			}
			return resultMap;
		} catch (Exception e) {
			LPI_ExceptionManager.logException('LPI_InternalPaymentController', 'getLicenseDetail', e);
			throw new AuraHandledException(e.getMessage());
		}
	}

	public class AdditionalFeeTypeWrapper {
		@AuraEnabled
		public String Name { get; set; }
		@AuraEnabled
		public Decimal Amount { get; set; }
		@AuraEnabled
		public String objectCode { get; set; }

		public AdditionalFeeTypeWrapper() {
			Name = '';
			Amount = 0;
			objectCode = '';
		}
	}

	public class FeeDetailsFromRatWrapper {
		@AuraEnabled
		public Integer Id { get; set; }
		@AuraEnabled
		public String Name { get; set; }
		@AuraEnabled
		public Decimal Amount { get; set; }
		@AuraEnabled
		public boolean disableMenu { get; set; }
		@AuraEnabled
		public String regTrxFeeId { get; set; }
		@AuraEnabled
		public String objectCode { get; set; }
		@AuraEnabled
		public Decimal actualAskedAmount { get; set; }
		@AuraEnabled
		public Decimal pendingPaymentAmount { get; set; }

		public FeeDetailsFromRatWrapper() {
			Id = 0;
			Name = '';
			Amount = 0;
			disableMenu = false;
			regTrxFeeId = '';
			objectCode = '';
			actualAskedAmount = 0;
			pendingPaymentAmount = 0;
		}
	}

	public class PaymentInformationWrapper {
		@AuraEnabled
		public String checkNumber;
		@AuraEnabled
		public String amountTendered;
		@AuraEnabled
		public String paidBySomeoneOther;
		@AuraEnabled
		public String payerName;
		@AuraEnabled
		public String payerPhone;
		@AuraEnabled
		public String paymentType;
		@AuraEnabled
		public String process;
		@AuraEnabled
		public String memoText;
		@AuraEnabled
		public String parId;
		@AuraEnabled
		public String exempt;
		@AuraEnabled
		public String exemptionReason;

		 
		public PaymentInformationWrapper() {
			checkNumber = '';
			amountTendered = '';
			paidBySomeoneOther = '';
			payerName = '';
			payerPhone = '';
			paymentType = '';
			process = '';
			memoText = '';
			exempt = '';
			exemptionReason = '';
		}
	}

	public class SelectOption {
		@AuraEnabled
		public String label;
		@AuraEnabled
		public String value;

		public SelectOption(String label, String value) {
			this.label = label;
			this.value = value;
		}
	}
}