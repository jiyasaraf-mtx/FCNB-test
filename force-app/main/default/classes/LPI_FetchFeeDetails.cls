/**
 *
 * @author          : MTX Group Product Team
 * @Description     : This class will fetch the records for Fee Details
 */
global with sharing class LPI_FetchFeeDetails implements Callable {
	public final static String FETCH_FEES_RECORDS = 'fetchFeesRecords';
	public final static String APPLY_FOR_COURSE_APPROVAL = 'Apply for Course Approval';
	public final static String APPLY_FOR_NON_PREAPPROVED_COURSE_CREDIT = 'Apply for Non-preapproved Course Credit';
	public final static String APPLY_FOR_COURSE_APPROVAL_FOR_CE_REQUIREMENTS = 'Apply for Course Approval for CE Requirements';
	
	public final static String CLASS_NAME = 'LPI_FetchFeeDetails';
	public final static String INVOKE_METHOD = 'invokeMethod';
	
	public final static String RENEWAL_FEE_TYPE = 'Renewal';
	public final static String INACTIVATION_TYPE = 'Inactivation';
	public final static String PROFESSIONAL_COUNSELOR = 'Professional Counselor';
	public final static String PRIVATE_INVESTIGATOR = 'Private Investigator';
	public final static String AGENCY_INVESTIGATOR_EMPLOYEE = 'Agency Investigator Employee';
	public final static String INDIVIDUAL_APPLICATION_TYPE = 'IndividualApplication';
	public final static String BUSINESS_LICENSE_APPLICATION_TYPE = 'BusinessLicenseApplication';
	public final static String MARITAL_AND_FAMILY_THERAPIST = 'Marital & Family Therapist';
	private static final String CONTINUING_EDUCATION_PROVIDER = 'Continuing Education Provider';
	private static final String APPRAISAL_MANAGEMENT_COMPANY = 'Appraisal Management Company';
	private static final String ANNUAL_REGISTRY_REPORT = 'Annual Registry Report';
	private static final String PAR_SOBJECT_TYPE_REINSTATEMENT = 'Reinstatement';
	
	private static final String REAL_ESTATE_APPRAISERS = 'Real Estate Appraisers';
	private static final String QUALIFYING_EDUCATION = 'Qualifying Education';
	private static final String SERVICE_LEVEL_STANDARD = 'Standard';
	private static final String SERVICE_LEVEL_EXPEDITED = 'ES_ExpeditedOption';
	private static final String FEE_NAME_STANDARD = 'Standard Fee';
	private static final String FEE_NAME_EXPEDITED = 'Expedited Fee';
	
    public final static String EMBALMERS_AND_FUNERAL_BOARD_NAME = 'Embalmers & Funeral Directors';
    public final static String CPA_CCOUNTANCY_TXT = 'Certified Public Accountant(CPA)';

	/**
	 * @author                      : MTX Group Product Team
	 * @since                       :
	 * @description                 : This method calls invoke method
	 * @param action                : String
	 * @param args			            : Map<String, Object>
	 * @return                      : Object
	 * @last modified by            : MTX Group Product Team
	 * @last modified date          : 03 Feb 2023
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
	 * @since                       : 17th Nov, 2022
	 * @description                 : This method is returing true if its successfully invoked
	 * @param methodName            : String
	 * @param inputMap			        : Map<String, Object>
	 * @param outMap			          : Map<String, Object>
	 * @param options			          : Map<String, Object>
	 * @return                      : `Boolean`
	 * @last modified by            : MTX Group Product Team
	 * @last modified date          : 03 Feb 2023
	 * @modified details            :
	 */
	private Boolean invokeMethod(
		String methodName,
		Map<String, Object> inputMap,
		Map<String, Object> outMap,
		Map<String, Object> options
	) {
		Boolean result = true;
		try {
			if (methodName == FETCH_FEES_RECORDS) {
				fetchFeeRecords(inputMap, outMap);
			}
		} catch (Exception e) {
			LPI_ExceptionManager.logException(CLASS_NAME, INVOKE_METHOD, e);
			result = false;
		}
		return result;
	}
	/**
	 * @author                      : MTX Group Product Team
	 * @since                       : 17th Nov, 2022
	 * @description                 : This Method will fetch Fee Records
	 * @param  inputMap             : data we are fetching from the Vlocity component
	 * @param  outMap               : data we are fetching from the Vlocity component
	 * @return                      : `void`
	 * @last modified by            : MTX Group Product Team
	 * @last modified date          : 16 Feb 2023
	 * @modified details            :
	 */
	public static void fetchFeeRecords(Map<String, Object> inputMap, Map<String, Object> outputMap) {
		try {
			String parId = (String) inputMap.get('parId');
			Decimal programCount = null;
			if (inputMap.containsKey('ProgramInformation')) {
				Map<String, Object> ProgramInformationBlock = (Map<String, Object>) inputMap.get('ProgramInformation');
				programCount = (Decimal) ProgramInformationBlock.get('ProgramsCount');
			}
			Map<String, Object> outMap = new Map<String, Object>();

			String parQueryFields = 'Id,Name,Type__c,Amendment_Type__c,BusinessAccountNameId,BusinessAccountName.How_are_you_associated_to_this_entity__c,Regulatory_Authorization_Type__c,Regulatory_Authorization_Type__r.Name,';	
			parQueryFields += 'Course_ID__c,Choose_the_Certification_Delivery_option__c,Contact__r.Account.Age__c,Contact__r.Account.Date_of_Birth__c,License_Questions__c , Business_License__c, Contact__r.AccountId,Approval_Supervisors_AcrIds__c,';
			parQueryFields += 'Channel__c, Regulatory_Authorization_Type__r.Authorisation_Type__c, Contact__r.Account.Criminal_Background_Fee_Payment_Date__c,Is_Submitted_By_Internal_User__c,ApplicationType, Regulatory_Authorization_Type__r.IssuingDepartment.Name';
			String parWhereClause = '';
			List<PreliminaryApplicationRef> par;
			Double totalAmount = 0;
			 
			if (!String.isEmpty(parId)) {
				parWhereClause += 'Id = \'' + String.escapeSingleQuotes(parId) + '\'';
				par = LPI_PreliminaryApplicationRefDAO.getPreliminaryApplicationRefByDymanicQuery(
					parQueryFields,
					parWhereClause,
					null,
					null,
					null
				);
			}
			 
			if(!par.isEmpty()){
				if(par[0].Regulatory_Authorization_Type__r.Name == CONTINUING_EDUCATION_PROVIDER && par[0].Regulatory_Authorization_Type__r.IssuingDepartment.Name == REAL_ESTATE_APPRAISERS){
					List<TrnCourse> trnCrsList = LPI_TrnCourseDAO.getTrnCourseByDymanicQuery(
                        'Id,Preliminary_Application_Reference__c,Course__c ', 'Preliminary_Application_Reference__c = \'' + String.escapeSingleQuotes(parId) + '\'', null, null, null
                    );

					if(!trnCrsList.isEmpty() && trnCrsList[0].Course__c != null){
						Set<String> courseSet = new Set<String>(trnCrsList[0].Course__c.split(';'));
						if(courseSet.contains(QUALIFYING_EDUCATION)){
							totalAmount = 0;
							outMap.put('FeesSummary', null);
							outMap.put('TotalAmount', totalAmount);
							outMap.put('parType', par[0].Type__c);
							outMap.put('Exempt', false);
							outMap.put('IsInternalUser', false);
							outMap.put('currentUserIsPortalUser', LPI_WithoutSharingUtility.isPortalUser());
							outputMap.put('PaymentData', outMap);
							return;
						}
					}
				}
			}

			if (!par.isEmpty()) {
				if (par[0].Is_Submitted_By_Internal_User__c) {
					List<SObject> applicationRecordList = new List<SObject>();
					if (par[0].ApplicationType == INDIVIDUAL_APPLICATION_TYPE) {
						applicationRecordList = LPI_IndividualApplicationDAO.getIndividualApplicationByDymanicQuery(
							'Id',
							'SavedApplicationRefId = \'' + par[0].Id + '\'',
							'1',
							null,
							null
						);
					} else if (par[0].ApplicationType == BUSINESS_LICENSE_APPLICATION_TYPE) {
						applicationRecordList = LPI_BusinessLicenseApplicationDAO.getBusinessLicenseApplicationByDymanicQuery(
							'Id',
							'SavedApplicationRefId = \'' + par[0].Id + '\'',
							'1',
							null,
							null
						);
					}
					if (!applicationRecordList.isEmpty()) {
						outputMap.putAll(fetchFeesForInternalUser((Id) applicationRecordList[0].get('Id'), par[0]));
					}
				} else {
					String blId = '';
					Map<String, Object> licenseQuestionsJSON = new Map<String, Object>();
					Set<String> appStatus = new Set<String>{ 'Approved', 'License Issued', 'Submitted' };
					Boolean repeatExaminationFeeApplicable = false;
					 
					if (String.isNotEmpty(par[0].License_Questions__c)) {
						licenseQuestionsJSON = (Map<String, Object>) JSON.deserializeUntyped(
							String.valueOf(par[0].License_Questions__c)
						);
					}
					blId = par[0].Business_License__c;

					String blQuery = 'Id , PeriodEnd ';
					String blwhereClause = '';
					List<BusinessLicense> blrecords = new List<BusinessLicense>();
					if (String.isNotBlank(blId)) {
						blwhereClause += 'Id = \'' + String.escapeSingleQuotes(blId) + '\'';
						blrecords = LPI_BusinessLicenseDAO.fetchBusinessLicenseRecordsWithOrderByLimit(
							blQuery,
							blwhereClause,
							null,
							null
						);
					}
					Boolean lateRenewal = false;
					List<Map<String, Object>> feesSummary = new List<Map<String, Object>>();
					totalAmount = 0;
					Date myDate = null;
					if (!blrecords.isEmpty() && blrecords[0].PeriodEnd!=null) {
						myDate = Date.newInstance(blrecords[0].PeriodEnd.year(), blrecords[0].PeriodEnd.month(), blrecords[0].PeriodEnd.day());
					}
					if (myDate != null && par[0].Type__c == LPI_LiteralConstant.IA_RENEWAL_APPLICATIONTYPE) {
						if (myDate < System.today()) {
							lateRenewal = true;
						}
					}
					if (lateRenewal) {
						String feeQueryFields = 'Id,Name,Fee_Amount__c,Fee_Type__c,Fee_Sub_Type__c,Is_Late_Fee_Static__c,Is_Late_Renewal__c,Regulatory_Authorization_Type__r.Name, Regulatory_Authorization_Type__r.IssuingDepartment.Name,Object_Code__c';
						String feeWhereClauseFields = '';
						 
						if (String.isNotEmpty(par[0].Regulatory_Authorization_Type__c)) {
							feeWhereClauseFields +=
								'Regulatory_Authorization_Type__c=\'' +
								String.escapeSingleQuotes(par[0].Regulatory_Authorization_Type__c) +
								'\'';
						}
						if (String.isNotEmpty(par[0].Type__c)) {
							feeWhereClauseFields +=
								' AND Fee_Type__c =\'' +
								String.escapeSingleQuotes(par[0].Type__c) +
								'\'';
						}
            if(par[0].Channel__c=='Offline')
                feeWhereClauseFields+=' AND Is_Online_Fee__c = false ';
						List<Fees__c> feeList = LPI_FeesDAO.getFeesByDymanicQuery(
							feeQueryFields,
							feeWhereClauseFields,
							null,
							null,
							null
						);
						for (Fees__c fee : feeList) {
							if (
								par[0].Amendment_Type__c == fee.Fee_Sub_Type__c && par[0].Type__c == LPI_LiteralConstant.IA_RENEWAL_APPLICATIONTYPE 
							) {
								Double feeAmount = lateRenewal && fee.Is_Late_Renewal__c
									? getLateRenewalAmount(myDate, fee)
									: fee.Fee_Amount__c;
								if (fee.Name == 'Programs' && programCount != null) {
									feeAmount = feeAmount * programCount;
								}
								Map<String, Object> feeDetailMap = getFeeDetailMap(
									fee.Id,
									fee.Name,
									fee.Fee_Type__c,
									feeAmount,
                                    fee.Object_Code__c
								);
								feesSummary.add(feeDetailMap);
								if (fee.Fee_Amount__c != null)
									totalAmount += (Double) feeDetailMap.get('Fee_Amount');
                                     system.debug('inside fee.Fee_Amount 249');
							}
                            
						}
						applyServiceLevelFeeFilter(inputMap, feesSummary, outMap, par[0].Type__c);
						outMap.put('currentUserIsPortalUser', LPI_WithoutSharingUtility.isPortalUser());
					} else {
						String appConQueryFields = 'Id,Preliminary_Application_Reference__c';
						String appConWhereClauseFields =
							'Preliminary_Application_Reference__c=\'' +
							String.escapeSingleQuotes(parId) +
							'\'';
						List<Application_Content__c> appContent = LPI_ApplicationContentDAO.getApplicationContentByDymanicQuery(
							appConQueryFields,
							appConWhereClauseFields,
							null,
							null,
							null
						);
						String tcpQueryFields = 'Id';
						String tcpWhereClauseFields =
							'Preliminary_Application_Reference__c=\'' +
							String.escapeSingleQuotes(parId) +
							'\'';
						List<TrainingCourseParticipant> participantList = LPI_TrainingCourseParticipantDAO.getTrainingCourseParticipantByDymanicQuery(
							tcpQueryFields,
							tcpWhereClauseFields,
							null,
							null,
							null
						);
						String feeQueryFields = 'Id,Name,Fee_Amount__c,Fee_Type__c,Fee_Sub_Type__c,Is_Late_Renewal__c,Regulatory_Authorization_Type__c,Extra_Amount__c,Regulatory_Authorization_Type__r.Name,Regulatory_Authorization_Type__r.IssuingDepartment.Name,Object_Code__c,Regulatory_Authorization_Type__r.Grace_Period__c';
						String feeWhereClauseFields = 'Is_Late_Renewal__c=' + lateRenewal;
						if (String.isNotEmpty(par[0].Regulatory_Authorization_Type__c)) {
							feeWhereClauseFields +=
								' AND Regulatory_Authorization_Type__c=\'' +
								String.escapeSingleQuotes(par[0].Regulatory_Authorization_Type__c) +
								'\'';
						}
						if (String.isNotEmpty(par[0].Type__c)) {
							feeWhereClauseFields +=
								' AND Fee_Type__c=\'' +
								String.escapeSingleQuotes(par[0].Type__c) +
								'\'';
						}
            if(par[0].Channel__c=='Offline')
                feeWhereClauseFields+=' AND Is_Online_Fee__c = false ';

						List<TrnCourse> courseList = new List<TrnCourse>();
						String whereConditionForCourses =
							'Preliminary_Application_Reference__c = \'' +
							String.escapeSingleQuotes(parId) +
							'\'';
						if (String.isNotEmpty(par[0].Type__c) && par[0].Type__c == APPLY_FOR_COURSE_APPROVAL) {
							courseList = LPI_TrnCourseDAO.getTrnCourseByDymanicQuery(
								'Id',
								whereConditionForCourses,
								null,
								null,
								null
							);
						}
						List<Fees__c> feeList = LPI_FeesDAO.getFeesByDymanicQuery(
							feeQueryFields,
							feeWhereClauseFields,
							null,
							null,
							null
						);
						Boolean isInstructorFeeRequired = true;
						String instructorFields = 'Id';
						String instructorWhereClause =
							'Preliminary_Application_Reference__c = \'' +
							String.escapeSingleQuotes(par[0].Id) +
							'\'';
						List<CourseOffering> instructorInformationList = LPI_CourseOfferingDAO.getCourseOfferingByDymanicQuery(
							instructorFields,
							instructorWhereClause,
							null,
							null,
							null
						);
						Integer instructorCount = 0;
						if (!instructorInformationList.isEmpty()) {
							instructorCount = instructorInformationList.size();
						}

						String RegTrxnFeeFields = 'Id, AccountId, Status, TotalFeeAmount, Transaction_Date__c';
						String RegTrxnFeeWhereClause =
							'AccountId =  \'' +
							String.escapeSingleQuotes(par[0].businessAccountNameId) +
							'\'' +
							'AND Status = ' +
							'\'Paid' +
							'\'' +
							'AND TotalFeeAmount = 500';
						String sortingByFields = 'Transaction_Date__c';

						List<RegulatoryTrxnFee> biennialInstructorFees = LPI_RegulatoryTrxnFeeDAO.getRegulatoryTrxnFeeByDymanicQuery(
							RegTrxnFeeFields,
							RegTrxnFeeWhereClause,
							'1',
							sortingByFields,
							'DESC'
						);

						if (!biennialInstructorFees.isEmpty()) {
							Date today = System.today();
							Integer currentBiennialStartYear = 0;
							 
							if (math.mod(today.year(), 2) == 0) {
								currentBiennialStartYear = today.year() - 1;
							} else if (today.month() > 2) {
								currentBiennialStartYear = today.year();
							} else {
								currentBiennialStartYear = today.year() - 2;
							}
							 
							if (
								biennialInstructorFees[0].Transaction_Date__c >
								Date.newInstance(currentBiennialStartYear - 1, 11, 28)
							) {
								isInstructorFeeRequired = false;
							}
						}
						List<Business_Relationships__c> employeeRecords = new List<Business_Relationships__c>();
						Set<Id> accountIdSet = new Set<Id>();
        				Set<Id> contactIdSet = new Set<Id>();
						String whereClauseForAccount;
						Boolean maxLimitReachedForDuplicateLicenseRequest = false;
                        Map<String, Integer> criminalFeeMap = countAccountOwners(par);
						for (Fees__c fee : feeList) {
							Double feeAmount;
							if (par[0].Amendment_Type__c == fee.Fee_Sub_Type__c) {
								if (fee.Fee_Type__c == APPLY_FOR_COURSE_APPROVAL) {
									Integer totalDeliveryMethods = courseList.size();
									feeAmount = fee.Fee_Amount__c * totalDeliveryMethods;
								} else if (
									fee.Fee_Type__c == APPLY_FOR_NON_PREAPPROVED_COURSE_CREDIT ||
									(fee.Fee_Type__c == APPLY_FOR_COURSE_APPROVAL_FOR_CE_REQUIREMENTS &&
									(par[0].Regulatory_Authorization_Type__r.Name == PRIVATE_INVESTIGATOR ||
									par[0].Regulatory_Authorization_Type__r.Name == AGENCY_INVESTIGATOR_EMPLOYEE))
								) {
									feeAmount = fee.Fee_Amount__c * participantList.size();
                } else if (fee.Fee_Type__c == LPI_LiteralConstant.REQUEST_FOR_CERTIFICATION_OF_LICENSURE || fee.Fee_Type__c == 'Request for certification and/or verification of licensure') {
                    if(fee.Fee_Type__c  == LPI_LiteralConstant.REQUEST_FOR_CERTIFICATION_OF_LICENSURE){
                      feeAmount =
                      fee.Fee_Amount__c *
                      getMultiplierofFeeAmount(
                      LPI_LiteralConstant.REQUEST_FOR_CERTIFICATION_OF_LICENSURE,
                      par
                      );
                  }
                    else{
                      feeAmount =
                      fee.Fee_Amount__c *
                      getMultiplierofFeeAmount(
                      'Request for certification and/or verification of licensure',
                      par
                      );
                    }
                   } else if (
									fee.Extra_Amount__c != null &&
									(fee.Fee_Type__c == LPI_LiteralConstant.FEE_TYPE_AMENDMENT ||
									fee.Fee_Type__c == LPI_LiteralConstant.BLA_NEW_APPLICATIONTYPE) &&
									(fee.Regulatory_Authorization_Type__r.Name ==
									LPI_LiteralConstant.PRENEED_SELLER_LICENSE_TYPE)
								) {
									if (fee.Fee_Type__c == LPI_LiteralConstant.FEE_TYPE_AMENDMENT) {
										feeAmount =
											fee.Fee_Amount__c +
											(fee.Extra_Amount__c * criminalFeeMap.get('activeCount'));
									} else if (fee.Fee_Type__c == LPI_LiteralConstant.BLA_NEW_APPLICATIONTYPE) {
										feeAmount =
											fee.Fee_Amount__c + (fee.Extra_Amount__c * criminalFeeMap.get('allCount'));
									}
								} else if (
									(fee.Fee_Type__c == LPI_LiteralConstant.PAR_SOBJECT_TYPE_REINSTATEMENT ||
									fee.Fee_Type__c == LPI_LiteralConstant.BLA_RENEWAL_APPLICATIONTYPE) &&
									(fee.Regulatory_Authorization_Type__r.Name ==
									LPI_LiteralConstant.PRENEED_SELLER_LICENSE_TYPE)
								) {
									feeAmount =
										fee.Fee_Amount__c +
										fee.Extra_Amount__c *
										Integer.valueOf(
											licenseQuestionsJSON.get(LPI_LiteralConstant.LQ_PS_REINST_NUMBEROFCONTRACTS)
										);
								} 
								 
								else {
									feeAmount = fee.Fee_Amount__c;
								}
								if (fee.Name == 'Programs' && programCount != null) {
									feeAmount = feeAmount * programCount;
								}
								Map<String, Object> feeDetailMap = getFeeDetailMap(
									fee.Id,
									fee.Name,
									fee.Fee_Type__c,
									feeAmount,
                                    fee.Object_Code__c
								);
								feesSummary.add(feeDetailMap);
								if (fee.Fee_Amount__c != null)
									totalAmount += (Double) feeDetailMap.get('Fee_Amount');
                                system.debug('inside fee.Fee_Amount 457 ');
							}
						}
                       // totalAmount=150;// adding to check the value remove it later.....................................
						applyServiceLevelFeeFilter(inputMap, feesSummary, outMap, par[0].Type__c);
						outMap.put('parSubType', par[0].Amendment_Type__c);
						outMap.put('currentUserIsPortalUser', LPI_WithoutSharingUtility.isPortalUser());
					}
					if (!outMap.containsKey('Exempt')) {
						outMap.put('Exempt', false);
					}
					outMap.put('IsInternalUser', false);
					outputMap.put('PaymentData', outMap);
				}
			}
		} catch (Exception e) {
			LPI_ExceptionManager.logException(CLASS_NAME, FETCH_FEES_RECORDS, e);
		}
	}

	/**
	 * @author                      : MTX Group Product Team
	 * @since                       : 27th July 2023
	 * @description                 : This method will return fees for internal user
	 * @param applicationId 	    : IA/BLA Id 
     * @param parRecord 	        : PAR record
	 * @return                      : Map<String, Object>
	 * @last modified by            : MTX Group Product Team
	 * @last modified date          :
	 * @modified details            :
	 */
	public static Map<String, Object> fetchFeesForInternalUser(Id applicationId, PreliminaryApplicationRef parRecord) {
		try {
			String fieldsToQuerry =
				'Id, Transaction_ID__c, Amount_Tendered__c, Paid_by_someone_other_than_applicant__c, Payer_Full_Name__c, Payer_Phone_Number__c, Payment_Method__c, Deposit_Method__c, Comments, ' +
				+'(SELECT Id,Name,FeeAmount,Object_Code__c FROM RegulatoryTrxnFeeItems LIMIT 200)';
			String whereClause = 'ParentRecordId = \'' + applicationId + '\'';
			List<RegulatoryTrxnFee> regTrxnFeeList = LPI_RegulatoryTrxnFeeDAO.getRegulatoryTrxnFeeByDymanicQuery(
				fieldsToQuerry,
				whereClause,
				null,
				null,
				null
			);
			List<RegulatoryTrxnFeeItem> regTrxnFeeItemList = new List<RegulatoryTrxnFeeItem>();
			for(RegulatoryTrxnFee rtf : regTrxnFeeList){
				regTrxnFeeItemList.addAll(rtf.RegulatoryTrxnFeeItems);
			}
			if (!regTrxnFeeItemList.isEmpty()) {
				Map<String, Object> outputMap = new Map<String, Object>();
				List<Map<String, Object>> feesItemSummary = new List<Map<String, Object>>();
				Double totalAmount = 0;
				Map<String,Double> feeTypeToTotalAmount = new Map<String,Double>();

				for(RegulatoryTrxnFeeItem regTrxnFeeItem : regTrxnFeeItemList){
					if(!feeTypeToTotalAmount.containsKey(regTrxnFeeItem.Name)){
						feeTypeToTotalAmount.put(regTrxnFeeItem.Name,0);
					} 
					feeTypeToTotalAmount.put(regTrxnFeeItem.Name,(Double) (feeTypeToTotalAmount.get(regTrxnFeeItem.Name) + regTrxnFeeItem.FeeAmount));
				}
				for (String feeType : feeTypeToTotalAmount.keySet()) {
					Double totalItemAmount = feeTypeToTotalAmount.get(feeType);
					Map<String, Object> feeItemDetailMap = new Map<String, Object>();
					feeItemDetailMap.put('Fee_Amount', totalItemAmount);
					feeItemDetailMap.put('Name', feeType);
					if (totalItemAmount != null) {
						totalAmount += totalItemAmount;
					}
					feesItemSummary.add(feeItemDetailMap);
				}
				Map<String, Object> internalPaymentDetailMap = new Map<String, Object>();
				Map<String, Object> feeDataBlockMap = new Map<String, Object>();
				feeDataBlockMap.put('InternalPaymentDetail', internalPaymentDetailMap);
				Map<String, Object> paymentDataMap = new Map<String, Object>();
				Map<String, Object> paymentStepMap = new Map<String, Object>();
				paymentStepMap.put('FeeDataBlock', feeDataBlockMap.isEmpty() ? null : feeDataBlockMap);

				paymentDataMap.put('FeesSummary', feesItemSummary.isEmpty() ? null : feesItemSummary);
				paymentDataMap.put('TotalAmount', totalAmount);
				paymentDataMap.put('currentUserIsPortalUser', LPI_WithoutSharingUtility.isPortalUser());

				paymentDataMap.put('parType', parRecord.Type__c);
				paymentDataMap.put('parSubType', parRecord.Amendment_Type__c);
				paymentDataMap.put('IsInternalUser', true);
				outputMap.put('PaymentData', paymentDataMap);
				outputMap.put('Payment', paymentStepMap);
				return outputMap;
			} else {
				return null;
			}
		} catch (Exception ex) {
			LPI_ExceptionManager.logException(CLASS_NAME, 'fetchFeesForInternalUser', ex);
			return null;
		}
	}

	/**
	 * @author                      : MTX Group Product Team
	 * @since                       :
	 * @description                 : This Method will calculate late renewal amount
	 * @param myDate 			    : data we are fetching from fetchFeeRecords methods
	 * @param fee                   : data we are fetching from fetchFeeRecords methods
	 * @return                      : `Double`
	 * @last modified by            : MTX Group Product Team
	 * @last modified date          : 03 Feb 2023
	 * @modified details            :
	 */
	public static Double getLateRenewalAmount(Date myDate, Fees__c fee) {
		Double lateRenewalAmt;
		if (fee.Is_Late_Fee_Static__c) {
			lateRenewalAmt = fee.Fee_Amount__c;
		} else if (
			(fee.Regulatory_Authorization_Type__r.Name == PROFESSIONAL_COUNSELOR ||
			fee.Regulatory_Authorization_Type__r.Name == MARITAL_AND_FAMILY_THERAPIST) &&
			fee.Fee_Type__c == RENEWAL_FEE_TYPE &&
			fee.Is_Late_Renewal__c
		) {
			 
			if (myDate != null && myDate.daysBetween(Date.TODAY()) < 61) {
				lateRenewalAmt = fee.Fee_Amount__c;
			} else if (myDate != null && Math.abs(myDate.year() - Date.today().year()) <= 2) {
				 
				if (fee.Regulatory_Authorization_Type__r.Name == PROFESSIONAL_COUNSELOR) {
					lateRenewalAmt = fee.Fee_Amount__c + 100;
				} else if (fee.Regulatory_Authorization_Type__r.Name == MARITAL_AND_FAMILY_THERAPIST) {
					lateRenewalAmt = fee.Fee_Amount__c + 25;
				}
			}
		} 
        else if(fee.Regulatory_Authorization_Type__r.Name.equals(CPA_CCOUNTANCY_TXT) && 
        fee.Fee_Type__c == RENEWAL_FEE_TYPE && 
        fee.Is_Late_Renewal__c)  {
            lateRenewalAmt = fee.Fee_Sub_Type__c == INACTIVATION_TYPE ? Math.max(1,myDate.monthsBetween(Date.TODAY())) * fee.Fee_Amount__c : fee.Fee_Amount__c; 
        }
    	else {
			lateRenewalAmt = getMonthlyLateRenewalFee(myDate, (Double) fee.Fee_Amount__c, 200);
		}
		return lateRenewalAmt;
	}

	/**
	 * @author                      : MTX Group Product Team
	 * @since                       :
	 * @description                 : This Method will calculate the multiplier of FeesAmount
	 * @param feeType 			         : This is the type of that fee.
	 * @param par                   : This is the instance of PreliminaryApplicationRef Object
	 * @return                      : `Integer`
	 * @last modified by            : MTX Group Product Team
	 * @last modified date          : 03 Feb 2023
	 * @modified details            :
	 */
	public static Integer getMultiplierofFeeAmount(String feeType, List<PreliminaryApplicationRef> par) {
		 
		if (feeType == LPI_LiteralConstant.REQUEST_FOR_CERTIFICATION_OF_LICENSURE || feeType == 'Request for certification and/or verification of licensure') {
			List<String> deliveryOptions = par[0].Choose_the_Certification_Delivery_option__c.split(';');
			return deliveryOptions.size();
		}
		return 1;
	}

	
	/**
	 * When Payment step selects Standard or ES_ExpeditedOption, keep only the matching
	 * Fees__c row (Standard Fee / Expedited Fee) so a single fee item is created.
	 * Other license types without a service-level selection are unchanged.
	 */
	private static void applyServiceLevelFeeFilter(
		Map<String, Object> inputMap,
		List<Map<String, Object>> feesSummary,
		Map<String, Object> outMap,
		String parType
	) {
		Double totalAmount = 0;
		List<Map<String, Object>> filteredFees = feesSummary;
		String serviceLevel = resolveServiceOrServiceLevel(inputMap);
		String expectedFeeName = resolveFeeNameForServiceLevel(serviceLevel);

		if (String.isNotBlank(expectedFeeName) && feesSummary != null && !feesSummary.isEmpty()) {
			List<Map<String, Object>> matchingFees = new List<Map<String, Object>>();
			for (Map<String, Object> feeDetailMap : feesSummary) {
				if (expectedFeeName.equals((String) feeDetailMap.get('Name'))) {
					matchingFees.add(feeDetailMap);
				}
			}
			if (!matchingFees.isEmpty()) {
				filteredFees = matchingFees;
			}
		}

		Boolean feeExempt = isApplicantFeeExempt(inputMap);
		if (filteredFees != null) {
			for (Map<String, Object> feeDetailMap : filteredFees) {
				if (feeExempt) {
					feeDetailMap.put('Fee_Amount', 0);
				}
				Object amountObj = feeDetailMap.get('Fee_Amount');
				if (amountObj != null) {
					totalAmount += (Double) amountObj;
				}
			}
		}
		if (feeExempt) {
			totalAmount = 0;
		}

		outMap.put('FeesSummary', (filteredFees == null || filteredFees.isEmpty()) ? null : filteredFees);
		outMap.put('TotalAmount', totalAmount);
		outMap.put('parType', parType);
		outMap.put('Exempt', feeExempt);
	}

	/**
	 * Reads ApplicantInformation:ApplicantDetails:feeExempt from OmniScript input (Yes = exempt).
	 */
	private static Boolean isApplicantFeeExempt(Map<String, Object> inputMap) {
		if (inputMap == null) {
			return false;
		}
		Object applicantInfoObj = inputMap.get('ApplicantInformation');
		if (!(applicantInfoObj instanceof Map<String, Object>)) {
			return false;
		}
		Object applicantDetailsObj = ((Map<String, Object>) applicantInfoObj).get('ApplicantDetails');
		if (!(applicantDetailsObj instanceof Map<String, Object>)) {
			return false;
		}
		Object feeExemptObj = ((Map<String, Object>) applicantDetailsObj).get('feeExempt');
		if (feeExemptObj == null) {
			return false;
		}
		String feeExemptVal = String.valueOf(feeExemptObj).trim();
		return feeExemptVal.equalsIgnoreCase('Yes') || feeExemptVal.equalsIgnoreCase('true');
	}

	private static String resolveServiceOrServiceLevel(Map<String, Object> inputMap) {
		if (inputMap == null) {
			return null;
		}
		Object direct = inputMap.get('ServiceOrServiceLevel');
		if (direct != null && String.isNotBlank(String.valueOf(direct))) {
			return String.valueOf(direct);
		}
		Object paymentNode = inputMap.get('Payment');
		if (paymentNode instanceof Map<String, Object>) {
			Object nested = ((Map<String, Object>) paymentNode).get('ServiceOrServiceLevel');
			if (nested != null && String.isNotBlank(String.valueOf(nested))) {
				return String.valueOf(nested);
			}
		}
		return null;
	}

	private static String resolveFeeNameForServiceLevel(String serviceLevel) {
		if (SERVICE_LEVEL_EXPEDITED.equals(serviceLevel)) {
			return FEE_NAME_EXPEDITED;
		}
		if (SERVICE_LEVEL_STANDARD.equals(serviceLevel)) {
			return FEE_NAME_STANDARD;
		}
		return null;
	}

	/**
	 * @author                      : MTX Group Product Team
	 * @since                       : 03 Feb 2023
	 * @description                 : This Method will add the values to a Map
	 * @param feeId 			           : Data will be fetched from fetchFeeRecords method
	 * @param feeName               : Data will be fetched from fetchFeeRecords method
	 * @param feeType 			         : Data will be fetched from fetchFeeRecords method
	 * @param feeAmount             : Data will be fetched from fetchFeeRecords method
	 * @return                      : `Map<String,Object>`
	 * @last modified by            : MTX Group Product Team
	 * @last modified date          : 03 Feb 2023
	 * @modified details            :
	 */
	public static Map<String, Object> getFeeDetailMap(Id feeId, String feeName, String feeType, Double feeAmount,String ObjectCode) {
		Map<String, Object> feeDetailMap = new Map<String, Object>();
		feeDetailMap.put('Fee_Amount', feeAmount);
		feeDetailMap.put('Fee_Type', feeType);
		feeDetailMap.put('Id', feeId);
		feeDetailMap.put('Name', feeName);
        feeDetailMap.put('Object_Code', ObjectCode);
		return feeDetailMap;
	}

	/**
	 * @author                      : MTX Group Product Team
	 * @since                       : 10th June, 0223
	 * @description                 : This Method will calculate the late renewal fee monthly up to a maximum amount.
	 * @param expiryDate 			: This is the Expirydate from which we have to calculate number of months till today.
	 * @param feeAmount 		    : This is the fee amount monthly.
	 * @param MaxLateFee            : This is the maximum late renewal fee need to be charged.
	 * @return                      : `Double`
	 * @last modified by            : MTX Group Product Team
	 * @last modified date          :
	 * @modified details            :
	 */
	public static Double getMonthlyLateRenewalFee(Date expiryDate, Double feeAmount, Integer MaxLateFee) {
		Double lateRenewalAmt;
		 
		if (expiryDate.year() != Date.TODAY().Year()) {
			Integer noOfMonthsDifference = (Date.TODAY().Year() - expiryDate.year()) * 12;
			 
			if (expiryDate.day() < Date.today().Day()) {
				lateRenewalAmt = ((Date.TODAY().Month() - expiryDate.Month() + noOfMonthsDifference + 1) * feeAmount) <
					MaxLateFee
					? (Date.TODAY().Month() - expiryDate.Month() + noOfMonthsDifference + 1) * feeAmount
					: MaxLateFee;
			} else {
				lateRenewalAmt = ((Date.TODAY().Month() - expiryDate.Month() + noOfMonthsDifference) * feeAmount) <
					MaxLateFee
					? (Date.TODAY().Month() - expiryDate.Month() + noOfMonthsDifference) * feeAmount
					: MaxLateFee;
			}
		} else {
			 
			if (expiryDate.day() < Date.today().Day()) {
				lateRenewalAmt = (Date.TODAY().Month() - expiryDate.Month() + 1) * feeAmount < MaxLateFee
					? (Date.TODAY().Month() - expiryDate.Month() + 1) * feeAmount
					: MaxLateFee;
			} else {
				lateRenewalAmt = (Date.TODAY().Month() - expiryDate.Month()) * feeAmount < MaxLateFee
					? (Date.TODAY().Month() - expiryDate.Month()) * feeAmount
					: MaxLateFee;
			}
		}
		return lateRenewalAmt;
	}
	
	/**
	 * @author                      : MTX Group Product Team
	 * @since                       : 19th July 2023
	 * @description                 : This method will calculate the difference between two dates and returns boolean value
	 * @param inputMap 			    : expiryDate
	 * @return                      : `Boolean`
	 * @last modified by            : MTX Group Product Team
	 * @last modified date          :
	 * @modified details            :
	 */
	 public static Boolean getDifferenceBTWDates(Date expiryDate) {
		if (expiryDate != null) {
			Boolean sixMonthsDiffCheck = false;
			if (expiryDate.year() != Date.TODAY().Year()) {
				Integer noOfMonthsDifference = Date.TODAY().Month() + 12 - expiryDate.Month();
				if (noOfMonthsDifference > 6) {
					sixMonthsDiffCheck = true;
				} else if ((noOfMonthsDifference == 6)) {
					if (expiryDate.day() < Date.today().Day()) {
						sixMonthsDiffCheck = true;
					} else {
						sixMonthsDiffCheck = false;
					}
				} else {
					sixMonthsDiffCheck = false;
				}
			} else {
				Integer noOfMonthsDifference = Date.TODAY().Month() - expiryDate.Month();
				if (noOfMonthsDifference > 6) {
					sixMonthsDiffCheck = true;
				} else if ((noOfMonthsDifference == 6)) {
					if (expiryDate.day() < Date.today().Day()) {
						sixMonthsDiffCheck = true;
					} else {
						sixMonthsDiffCheck = false;
					}
				} else {
					sixMonthsDiffCheck = false;
				}
			}
			return sixMonthsDiffCheck;
		}
		return null;
	}
	/**
	 * @author                      : MTX Group Product Team
	 * @since                       : 19th July 2023
	 * @description                 : This method will return number of owners associated to the account
	 * @param inputMap 			    : parList
	 * @return                      : `Map<String, Integer>`
	 * @last modified by            : MTX Group Product Team
	 * @last modified date          :
	 * @modified details            :
	 */
	 public static Map<String, Integer> countAccountOwners(List<PreliminaryApplicationRef> parList) {
		Boolean applyCriminalFee = false;
		Map<Id, String> brAccountIdToDateNewMap = new Map<Id, String>();
		Map<Id, String> brAccountIdToDateAmendmentMap = new Map<Id, String>();
		Map<String, Integer> criminalFeeMap = new Map<String, Integer>();
		 
		List<Id> criminalBackgroundFeeOwnerIdsList = new List<Id>();
		Integer activeCount = 0, allCount = 0, criminalFee = 0;
		String accConQueryFields = 'Id, IsActive__c, EndDate__c, Related_To__r.Criminal_Background_Fee_Payment_Date__c';
		String accConWhereClauseFields = 'Roles__c = \'' + LPI_LiteralConstant.ROLE_OWNER + '\'';
		 
		if (String.isNotEmpty(parList[0].BusinessAccountNameId)) {
			accConWhereClauseFields +=
			' AND Related_From__c =\'' +
			String.escapeSingleQuotes(parList[0].BusinessAccountNameId) +
			'\'';
		}
		List<Business_Relationships__c> brList = new LPI_BusinessRelationshipDAO.LPI_BusinessRelationshipsWithoutSharingDAO()
		.getBusinessRelationshipsByDymanicQuery(accConQueryFields, accConWhereClauseFields, null, null, null);
		for (Business_Relationships__c brRecord : brList) {
			if (brRecord.IsActive__c == false && brRecord.EndDate__c == null) {
				brAccountIdToDateNewMap.put(
				brRecord.Related_To__c,
				brRecord.Related_To__r.Criminal_Background_Fee_Payment_Date__c != null
				? String.valueOf(brRecord.Related_To__r.Criminal_Background_Fee_Payment_Date__c)
				: '-'
				);
			} else if (brRecord.IsActive__c == true) {
				brAccountIdToDateAmendmentMap.put(
				brRecord.Related_To__c,
				String.valueOf(brRecord.Related_To__r.Criminal_Background_Fee_Payment_Date__c)
				);
			}
		}
		if (!brList.isEmpty()) {
			if (!brAccountIdToDateNewMap.isEmpty()) {
				for (Id accId : brAccountIdToDateNewMap.keySet()) {
					if (
					brAccountIdToDateNewMap.get(accId) != '-' &&
					getDifferenceBTWDates(Date.valueOf(brAccountIdToDateNewMap.get(accId)))
					) {
						allCount++;
						criminalBackgroundFeeOwnerIdsList.add(accId);
					} else if (
					brAccountIdToDateNewMap.get(accId) != '-' &&
					!getDifferenceBTWDates(Date.valueOf(brAccountIdToDateNewMap.get(accId)))
					) {
						continue;
					} else {
						allCount++;
						criminalBackgroundFeeOwnerIdsList.add(accId);
					}
				}
			}
			if (!brAccountIdToDateAmendmentMap.isEmpty()) {
				for (Id accId : brAccountIdToDateAmendmentMap.keySet()) {
					if (brAccountIdToDateAmendmentMap.get(accId) != null && !getDifferenceBTWDates(Date.valueOf(brAccountIdToDateAmendmentMap.get(accId)))) {
						activeCount++;
						criminalBackgroundFeeOwnerIdsList.add(accId);
					}
				}
			}
		} else {
			if (parList[0].Contact__r.Account.Criminal_Background_Fee_Payment_Date__c != null) {
				if (
				!getDifferenceBTWDates(
				Date.valueOf(parList[0].Contact__r.Account.Criminal_Background_Fee_Payment_Date__c)
				)
				) {
					applyCriminalFee = false;
				} else {
					applyCriminalFee = true;
                    criminalBackgroundFeeOwnerIdsList.add(parList[0].Contact__r.AccountId);
				}
			} else {
				applyCriminalFee = true;
                criminalBackgroundFeeOwnerIdsList.add(parList[0].Contact__r.AccountId);
			}
		}
		if (applyCriminalFee) {
			criminalFee = 1;
		}
		criminalFeeMap.put('allCount', allCount);
		criminalFeeMap.put('activeCount', activeCount);
		criminalFeeMap.put('applyCriminalFee', criminalFee);
        String criminalBackgroundFeeOwnerIDs = String.join(criminalBackgroundFeeOwnerIdsList, ',');
       
        LPI_DML.doUpdate(parList[0]);
		return criminalFeeMap;
	}
}