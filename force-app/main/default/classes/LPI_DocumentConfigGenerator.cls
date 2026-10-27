/**
 * @author      : MTX Group Product Team
 * @since       : 13 Oct 2023
 * @description : This LPI_DocumentConfigGenerator is used to generate Renewal, Reinstatement, PostCard and Wall Hanging Template data

 */
public with sharing class LPI_DocumentConfigGenerator{
	
	public static Set<String> TWO_YEARS_EXPIRY_CYCLES = new Set<String>{ LPI_LiteralConstant.Expiration_Cycle_EVEN, LPI_LiteralConstant.Expiration_Cycle_ODD, LPI_LiteralConstant.Expiration_Cycle_BIENNIAL, LPI_LiteralConstant.EXPIRATION_CYCLE_TWO_YEARS };
	public static final Set<String> REINSTATEMENT_TYPE_SET = new Set<String>{ 'Reinstatement', 'Re-licensure', 'Re-authorization' };
	
	public final static Set<String> STATUS_SET = new Set<String>{ 'Submitted', 'Under Review', 'MO Board Member Review', 'Awaiting Response', 'Ready for ED Approval', 'Approved', 'License Issued' };
	public final static Set<String> BL_STATUS_SET = new Set<String>{ 'Active', 'Expired', 'Inactive', 'Restricted', 'Revoked' };
	public final static Set<String> NURSINGBL_STATUS_SET = new Set<String>{ 'Active', 'Expired', 'Inactive', 'Restricted', 'Revoked', 'Retired' };
	public final static Set<String> BL_STATUS_SET_REINST = new Set<String>{ 'Expired', 'Inactive', 'Restricted', 'Revoked' };
	
	public final static String WALL_HANGING = 'Wall Hangings';
	public static final String RENEWAL_TYPE = 'Renewal';
	public static final String POSTCARD_TYPE = 'Postcard';
	
	public static final String CLASS_NAME = 'LPI_DocumentConfigGenerator';
	

	/**
	 * @author                       : MTX Group Product Team
	 * @since                        : Oct 2023
	 * @description                  : Prepares the JSON document for renewal documents to get RegAuthType Information.
	 * @param recordId               : String
	 * @return                       : List<Map<String, String>
	 * @last modified by             : MTX Group Product Team
	 * @last modified date           :
	 * @last modified details        :
	 */
	@AuraEnabled
	public static List<Map<String, String>> getRegAuthType(String recordId){
		try{
			
			if (recordId != null){
				List<Map<String, String>> picklistOptions = new List<Map<String, String>>();
				
				for (RegulatoryAuthorizationType regAuthType : LPI_RegulatoryAuthorizationTypeDAO.getRegulatoryAuthorizationTypeByDymanicQuery('Id,Name,IssuingDepartmentId', 'IssuingDepartmentId =\'' + String.escapeSingleQuotes(recordId) + '\'', null, null, null)){
					
					picklistOptions.add(new Map<String, String>{ 'label' => regAuthType.Name, 'value' => regAuthType.Id });
				}
				return picklistOptions;
			}
			return null;
		} catch (Exception e){
			LPI_ExceptionManager.logException(CLASS_NAME, 'getRegAuthType', e);
			throw new LPI_Exception(e.getMessage());
		}
	}

	/**
	 * @author                       : MTX Group Product Team
	 * @since                        : Oct 2023
	 * @description                  : Prepares the JSON document for renewal documents to get License Details Information.
	 * @param regAuthTypeId          : String
	 * @return                       :  List<BusinessLicense>
	 * @last modified by             : MTX Group Product Team
	 * @last modified date           :
	 * @last modified details        :
	 */
	@AuraEnabled
	public static List<BusinessLicense> getLicenseDetails(String regAuthTypeId, String type, Map<String, String> issueDateRange, Boolean selectedIndicator){
		try{
			
			if (regAuthTypeId != null && type != null){
				
				String rATfields = 'Name';
				String rATwhereClause = 'Id = \'' + regAuthTypeId + '\'';
				List<RegulatoryAuthorizationType> regulatoryAuthorizationTypes = LPI_RegulatoryAuthorizationTypeDAO.getRegulatoryAuthorizationTypeByDymanicQuery(rATfields, rATwhereClause, '1', null, null);
				String regulatoryAuthorizationTypeName = regulatoryAuthorizationTypes[0].Name;
				
				String fieldsToQuery = 
					'Id,Business_Entity_Name__c,contact.Account.Name, contact.Account.FirstName, First_Name__c, Middle_Name__c, contact.Account.MiddleName,' + 
					' Last_Name__c, contact.Account.LastName, Status, Account.Name, Name, PeriodStart, PeriodEnd, Regulatory_Authorization_Type_Name__c,' + 
					'RegulatoryAuthorizationType.Authorisation_Type__c,Wall_Hanging_Print_Indicator__c';
				String whereClause;
				
				if (type == RENEWAL_TYPE){
					if (selectedIndicator == false){
						
							whereClause = 'RegulatoryAuthorizationTypeId = \'' + regAuthTypeId + 
															 
                        										'\' AND PeriodEnd = THIS_YEAR AND Status IN ' + LPI_ServiceUtility.getStringValuesByStringSet(BL_STATUS_SET);
						
					} else{
						
							whereClause = 'RegulatoryAuthorizationTypeId = \'' + regAuthTypeId + 
															 
															  '\' AND PeriodEnd = THIS_YEAR AND Status IN ' + LPI_ServiceUtility.getStringValuesByStringSet(BL_STATUS_SET);
						
					}
				} else if (REINSTATEMENT_TYPE_SET.contains(type) ){
					if (selectedIndicator == false){
						
							whereClause = 'RegulatoryAuthorizationTypeId = \'' + regAuthTypeId + 
															  '\' AND PeriodEnd = THIS_YEAR AND Status IN ' + LPI_ServiceUtility.getStringValuesByStringSet(BL_STATUS_SET_REINST);
						
					} else{
							whereClause = 'RegulatoryAuthorizationTypeId = \'' + regAuthTypeId + 
															  '\' AND PeriodEnd = THIS_YEAR AND Status IN ' + LPI_ServiceUtility.getStringValuesByStringSet(BL_STATUS_SET_REINST);
						
					}
				} else if (type == WALL_HANGING){
					whereClause = 'RegulatoryAuthorizationTypeId = \'' + regAuthTypeId + 
															  '\' AND Status IN ' + LPI_ServiceUtility.getStringValuesByStringSet(BL_STATUS_SET) + 
															  ' AND Wall_Hanging_Print_Indicator__c  != \'Ready for Printing\'';
					if (issueDateRange.containsKey('issuanceDateFrom') && String.isNotBlank(issueDateRange.get('issuanceDateFrom'))){
						Date filterDate = Date.valueOf(issueDateRange.get('issuanceDateFrom'));
						DateTime selectedIssueDateFromTime = DateTime.newInstance(filterDate.year(), filterDate.month(), filterDate.day(), 0, 0, 0);
						whereClause += 
							' AND PeriodStart >= ' + selectedIssueDateFromTime.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'');
					}
					if (issueDateRange.containsKey('issuanceDateTo') && String.isNotBlank(issueDateRange.get('issuanceDateTo'))){
						Date filterDate = Date.valueOf(issueDateRange.get('issuanceDateTo'));
						DateTime selectedIssueDateToTime = DateTime.newInstance(filterDate.year(), filterDate.month(), filterDate.day(), 0, 0, 0);
						whereClause += 
							' AND PeriodStart < ' + selectedIssueDateToTime.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'');
					}
				}
				String limitValue = '500';
				String orderByClause = 'Account.Name ASC';

				List<BusinessLicense> businessLicenses = LPI_BusinessLicenseDAO.fetchBusinessLicenseRecordsWithOrderByLimit(fieldsToQuery, whereClause, limitValue, orderByClause);

				
				Set<Id> individualbusinessLicenseIdsSet = new Set<Id>();
				Set<Id> businessbusinessLicenseIdsSet = new Set<Id>();
				
				for (BusinessLicense license : businessLicenses){
					
					if (license.RegulatoryAuthorizationType.Authorisation_Type__c == 'Individual'){
						individualbusinessLicenseIdsSet.add(license.Id);
					} else if (license.RegulatoryAuthorizationType.Authorisation_Type__c == 'Business'){
						
						businessbusinessLicenseIdsSet.add(license.Id);
					}
				}

				
				if (individualbusinessLicenseIdsSet != null && !individualbusinessLicenseIdsSet.isEmpty()){
					String ilaFields = 'Id, LicensePermitNameId, Status, ApplicationType';
					String whereClauseForILA = '';
					if (type == RENEWAL_TYPE){
						whereClauseForILA += 'ApplicationType = \'' + RENEWAL_TYPE + '\'';
					} else{
						whereClauseForILA += 'ApplicationType IN ' + LPI_ServiceUtility.getStringValuesByStringSet(REINSTATEMENT_TYPE_SET);
					}
					whereClauseForILA += ' AND LicensePermitNameId IN ' + LPI_ServiceUtility.getStringValuesBySet(individualbusinessLicenseIdsSet) + 
											' AND Status IN ' + LPI_ServiceUtility.getStringValuesByStringSet(STATUS_SET) + 
											' AND CreatedDate = THIS_YEAR';

					List<IndividualApplication> ila = LPI_IndividualApplicationDAO.getIndividualApplicationByDymanicQuery(ilaFields, whereClauseForILA, null, null, null);

					
					for (IndividualApplication ia : ila){
						individualbusinessLicenseIdsSet.remove(ia.LicensePermitNameId);
					}
				}

				
				if (businessbusinessLicenseIdsSet != null && !businessbusinessLicenseIdsSet.isEmpty()){
					String blaFields = 'Id, LicensePermitNameId, Status, ApplicationType';
					String whereClauseForBLA = '';
					if (type == RENEWAL_TYPE){
						whereClauseForBLA += 'ApplicationType = \'' + RENEWAL_TYPE + '\'';
					} else{
						whereClauseForBLA += 'ApplicationType IN ' + LPI_ServiceUtility.getStringValuesByStringSet(REINSTATEMENT_TYPE_SET);
					}
					whereClauseForBLA += ' AND LicensePermitNameId IN ' + LPI_ServiceUtility.getStringValuesBySet(businessbusinessLicenseIdsSet) + 
											' AND Status IN ' + LPI_ServiceUtility.getStringValuesByStringSet(STATUS_SET) + 
											' AND CreatedDate = THIS_YEAR';

					List<BusinessLicenseApplication> bla = LPI_BusinessLicenseApplicationDAO.getBusinessLicenseApplicationByDymanicQuery(blaFields, whereClauseForBLA, null, null, null);

					
					for (BusinessLicenseApplication bl : bla){
						businessbusinessLicenseIdsSet.remove(bl.LicensePermitNameId);
					}
				}

				
				List<BusinessLicense> filteredLicenses = new List<BusinessLicense>();
				for (BusinessLicense license : businessLicenses){
					if (individualbusinessLicenseIdsSet.contains(license.Id) || businessbusinessLicenseIdsSet.contains(license.Id)){
						filteredLicenses.add(license);
					}
				}

				return filteredLicenses;
			}
			return null;
		} catch (Exception e){
			LPI_ExceptionManager.logException(CLASS_NAME, 'getLicenseDetails', e);
			throw new LPI_Exception(e.getMessage());
		}
	}

	/**
	 * @author                       : MTX Group Product Team
	 * @since                        : Oct 2023
	 * @description                  : Prepares the JSON document for renewal documents to get Adobe Document Link.
	 * @param recordId               : List<String>
	 * @param licenseTypeName        : String
	 * @param cycle                  : Integer
	 * @param status                 : String
	 * @return                       : String
	 * @last modified by             : MTX Group Product Team
	 * @last modified date           : 21 Dec 2023
	 * @last modified details        : Added Postcard conditions
	 */
	@AuraEnabled
	public static String getAdobeDocumentLink(List<String> recordId, String licenseTypeName, Integer cycle, String status, String type, Id regAuthId){
		try{
			
			if (recordId != null && regAuthId != null && licenseTypeName != null && status != null && (cycle != null || REINSTATEMENT_TYPE_SET.contains(type) )){
				Set<String> blIdSet = new Set<String>(recordId);
				
			} else if (type == POSTCARD_TYPE){
				Set<String> blIdSet = new Set<String>(recordId);
				updateBlRecordList(blIdSet, type);
			} else if (type == WALL_HANGING){
				
				List<BusinessLicense> blToUpdateList = new List<BusinessLicense>();
				for (String blId : recordId){
					BusinessLicense blToUpdate = new BusinessLicense(
						Id = blId
					);
					blToUpdate.Wall_Hanging_Print_Indicator__c = 'Ready for Printing';
					blToUpdateList.add(blToUpdate);
				}
				if (!blToUpdateList.isEmpty()){
					
					LPI_WithoutSharingUtility.updateSObjectList(blToUpdateList);
				}
			}
			return null;
		} catch (Exception e){
			LPI_ExceptionManager.logException(CLASS_NAME, 'getAdobeDocumentLink', e);
			throw new LPI_Exception(e.getMessage());
		}
	}

	/**
	 * @author                       : MTX Group Product Team
	 * @since                        : Oct 2023
	 * @description                  : Prepares the JSON document for renewal documents to get Previous Cycle Expiry Dates
	 * @param blRecord               : BusinessLicense
	 * @param cycle                  : Integer
	 * @return                       : DateTime
	 * @last modified by             :MTX Group Product Team
	 * @last modified date           :
	 * @last modified details        :
	 */
	public static DateTime getPrevCycleExpiryDates(BusinessLicense blRecord, Integer cycle){
		try{
			DateTime prevExpiryDateTime = blRecord.PeriodEnd;
			
			if (blRecord.PeriodEnd != null && String.isNotBlank(blRecord.RegulatoryAuthorizationType.Expiry_Rule_Type__c) && cycle > 0){
				Date prevExpiryDate = Date.newInstance(blrecord.PeriodEnd.year(), blrecord.PeriodEnd.month(), blrecord.PeriodEnd.day());
				
				if (blRecord.RegulatoryAuthorizationType.Expiry_Rule_Type__c == LPI_LiteralConstant.EXPIRY_RULE_TYPE_DAY_MONTH_CYCLE){
					
					if (TWO_YEARS_EXPIRY_CYCLES.contains(blRecord.RegulatoryAuthorizationType.Expiration_Cycle__c)){
						prevExpiryDate = prevExpiryDate.addYears(-2 * cycle);
					} else if (blRecord.RegulatoryAuthorizationType.Expiration_Cycle__c == LPI_LiteralConstant.Expiration_Cycle_ANNUAL){
						prevExpiryDate = prevExpiryDate.addYears(-1 * cycle);
					} else if (blRecord.RegulatoryAuthorizationType.Expiration_Cycle__c == LPI_LiteralConstant.EXPIRATION_CYCLE_FIXED_CYCLE){
						prevExpiryDate = prevExpiryDate.addYears(-(Integer) blRecord.RegulatoryAuthorizationType.Expiration_Fixed_Cycle_Difference__c * cycle);
					} else if (blRecord.RegulatoryAuthorizationType.Expiration_Cycle__c == LPI_LiteralConstant.EXPIRATION_CYCLE_FIVE_YEARS){
						prevExpiryDate = prevExpiryDate.addYears(-5 * cycle);
					}
				} else if (blRecord.RegulatoryAuthorizationType.Expiry_Rule_Type__c == LPI_LiteralConstant.EXPIRY_RULE_TYPE_PERIOD){
				
					if (blRecord.RegulatoryAuthorizationType.Expiration_Period__c.contains(LPI_LiteralConstant.EXPIRATION_PERIOD_CONTAINS_DAYS)){
						prevExpiryDate = prevExpiryDate.addDays(-Integer.valueOf(blRecord.RegulatoryAuthorizationType.Expiration_Period__c.remove(LPI_LiteralConstant.EXPIRATION_PERIOD_CONTAINS_DAYS)) * cycle);
					} else{
						prevExpiryDate = prevExpiryDate.addMonths(-Integer.valueOf(blRecord.RegulatoryAuthorizationType.Expiration_Period__c) * cycle);
					}
					
					if (blRecord.RegulatoryAuthorizationType.Expiration_Day__c != null && blRecord.RegulatoryAuthorizationType.Expiration_Day__c == LPI_LiteralConstant.EXPIRATION_DAY_DAY_OF_ISSUANCE_MINUS_1 && blRecord.RegulatoryAuthorizationType.Expiration_Month__c != null && blRecord.RegulatoryAuthorizationType.Expiration_Month__c == LPI_LiteralConstant.EXPIRATION_MONTH_MONTH_OF_ISSUANCE){
						prevExpiryDate = prevExpiryDate.addDays(-1 * cycle);
					}
				}
				
				prevExpiryDateTime = DateTime.newInstance(prevExpiryDate.year(), prevExpiryDate.month(), prevExpiryDate.day(), 0, 0, 0);
			}
			
			return prevExpiryDateTime;
		} catch (Exception e){
			
			LPI_ExceptionManager.logException(CLASS_NAME, 'getPrevCycleExpiryDates', e);
			
			throw new LPI_Exception(e.getMessage());
		}
	}


	/**
	 * @author                      : MTX Group Product Team
	 * @since                       : 24 Oct 2023
	 * @description                 : This method is used to update Renewal_Document_Print_Indicator__c = 'Sent for Printing' in Future
	 * @param conIdsSet             : Set of business license IDs
	 * @return                      : Void
	 * @last modified by            : MTX Group Product Team
	 * @last modified date          : (Add if modified by you)
	 * @last modified details       : (Add if modified by you)
	 */
	@future
	public static void updateBlRecordList(Set<String> blIdSet, String type){
		try{
			
			if (!blIdSet.isEmpty() && type != null){
				String fieldsToQuery = 'Id, PeriodEnd, PeriodStart';
				String whereClause = 'Id IN ' + LPI_ServiceUtility.getStringValuesByStringSet(blIdSet);
				Date currentDate = Date.today();

				List<BusinessLicense> businessLicenses = LPI_BusinessLicenseDAO.fetchBusinessLicenseRecords(fieldsToQuery, whereClause);
				List<BusinessLicense> blListToUpdate = new List<BusinessLicense>();
				
				for (BusinessLicense license : businessLicenses){
					
					if (license.PeriodEnd >= license.PeriodStart){
						
						if (type == RENEWAL_TYPE){
							
						} else if (type == POSTCARD_TYPE){
							
							DateTime currentDateTime = Datetime.now();
							
						} else{
							
						}
						blListToUpdate.add(license);
					}
				}
				
				if (!blListToUpdate.isEmpty()){
					LPI_DML.doUpdate(blListToUpdate);
				}
			}
		} catch (Exception ex){
			LPI_ExceptionManager.logException(CLASS_NAME, 'updateBlRecordList', ex);
			throw new LPI_Exception(ex.getMessage());
		}
	}

	/**
	 * @author                      : MTX Group Product Team
	 * @since                       : 2 Jan 2024
	 * @description                 : This method is used to get licenses for Postcard
	 * @param regAuthTypeId         : regAuthTypeId ID
	 * @param selectedIndicator     : Boolean
	 * @param dontNeedEmail         : String
	 * @return                      : List<BusinessLicense>
	 * @last modified by            : MTX Group Product Team
	 * @last modified date          : (Add if modified by you)
	 * @last modified details       : (Add if modified by you)
	 */
	@AuraEnabled
	public static List<BusinessLicense> getPostcardLicenseDetails(List<String> regAuthTypeIds, String type, Boolean selectedIndicator, String dontNeedEmail){
		try{
			if (regAuthTypeIds != null && type != null){
				String fieldsToQuery = 'Id,Business_Entity_Name__c,contact.Account.Name, contact.Account.FirstName, First_Name__c, Middle_Name__c, contact.Account.MiddleName, Last_Name__c, contact.Account.LastName, Status, Account.Name, Name, PeriodEnd, Regulatory_Authorization_Type_Name__c,RegulatoryAuthorizationType.Authorisation_Type__c,Account.RecordType.DeveloperName';

				String whereClause = 
					'RegulatoryAuthorizationTypeId IN ' + LPI_ServiceUtility.getStringValuesByList(regAuthTypeIds);
				whereClause = whereClause + 
					'AND Status IN ' + LPI_ServiceUtility.getStringValuesByStringSet(BL_STATUS_SET) + 
					' AND PeriodEnd = NEXT_90_DAYS';
				
				
				if (selectedIndicator){
					String postcardSentForPrint = 'Sent for Printing';
					
				} 
				

				
				if (dontNeedEmail != null && dontNeedEmail == 'true'){
					whereClause += ' AND ('; 

					
					whereClause += '(Account.RecordType.DeveloperName = \'PersonAccount\' AND Account.PersonEmail = null)';

					
					whereClause += ' OR ';

					whereClause += '(Account.RecordType.DeveloperName = \'Business\' AND Account.Buisness_Email__c = null)';

					whereClause += ')'; 
				}

				String limitValue = '500';
				String orderByClause = '';
				orderByClause += 'Name ASC';
				

				List<BusinessLicense> businessLicenses = LPI_BusinessLicenseDAO.fetchBusinessLicenseRecordsWithOrderByLimit(fieldsToQuery, whereClause, limitValue, orderByClause);

			
				Set<Id> individualbusinessLicenseIdsSet = new Set<Id>();
				Set<Id> businessbusinessLicenseIdsSet = new Set<Id>();
				for (BusinessLicense license : businessLicenses){
					if (license.RegulatoryAuthorizationType.Authorisation_Type__c == 'Individual'){
						individualbusinessLicenseIdsSet.add(license.Id);
					} else if (license.RegulatoryAuthorizationType.Authorisation_Type__c == 'Business'){
						businessbusinessLicenseIdsSet.add(license.Id);
					}
				}

				
				if (individualbusinessLicenseIdsSet != null && !individualbusinessLicenseIdsSet.isEmpty()){
					String ilaFields = 'Id, LicensePermitNameId, Status, ApplicationType';
					String whereClauseForILA = 
						'ApplicationType = \'Renewal\' AND LicensePermitNameId IN ' + LPI_ServiceUtility.getStringValuesBySet(individualbusinessLicenseIdsSet) + 
						' AND Status IN ' + LPI_ServiceUtility.getStringValuesByStringSet(STATUS_SET) + 
						' AND CreatedDate = THIS_YEAR';

					List<IndividualApplication> ila = LPI_IndividualApplicationDAO.getIndividualApplicationByDymanicQuery(ilaFields, whereClauseForILA, null, null, null);

					
					for (IndividualApplication ia : ila){
						individualbusinessLicenseIdsSet.remove(ia.LicensePermitNameId);
					}
				}

				
				if (businessbusinessLicenseIdsSet != null && !businessbusinessLicenseIdsSet.isEmpty()){
					String blaFields = 'Id, LicensePermitNameId, Status, ApplicationType';
					String whereClauseForBLA = 
						'ApplicationType = \'Renewal\' AND LicensePermitNameId IN ' + LPI_ServiceUtility.getStringValuesBySet(businessbusinessLicenseIdsSet) + +' AND Status IN ' + LPI_ServiceUtility.getStringValuesByStringSet(STATUS_SET) + 
						' AND CreatedDate = THIS_YEAR';

					List<BusinessLicenseApplication> bla = LPI_BusinessLicenseApplicationDAO.getBusinessLicenseApplicationByDymanicQuery(blaFields, whereClauseForBLA, null, null, null);

				
					for (BusinessLicenseApplication bl : bla){
						businessbusinessLicenseIdsSet.remove(bl.LicensePermitNameId);
					}
				}

			
				List<BusinessLicense> filteredLicenses = new List<BusinessLicense>();
				for (BusinessLicense license : businessLicenses){
					if (individualbusinessLicenseIdsSet.contains(license.Id) || businessbusinessLicenseIdsSet.contains(license.Id)){
						filteredLicenses.add(license);
					}
				}

				return filteredLicenses;
			}
			return null;
		} catch (Exception e){
			LPI_ExceptionManager.logException(CLASS_NAME, 'getPostcardLicenseDetails', e);
			throw new LPI_Exception(e.getMessage());
		}
	}

}