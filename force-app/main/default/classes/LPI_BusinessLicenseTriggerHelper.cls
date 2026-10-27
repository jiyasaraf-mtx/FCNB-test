/**
 * @description       : 
 * @author            : MTX Group Product Team
 * @group             : 
 * @last modified on  : 07-25-2024
 * @last modified by  : MTX Group Product Team
**/
public class LPI_BusinessLicenseTriggerHelper {
    public final static List<String> APPLICABLE_LICENSE_NAME_LIST = new List<String>{
		'Registered Nurse',
		'Licensed Practical Nurse'
	};
    public static final String COURSE_STATUS_EXPIRED = 'Expired';
    public final static String VALUE_Y = 'Y';
	public static final String LICENSE_TYPE_CHIROPRACTIC_PHYSICIAN = 'Chiropractic Physician';
	public static final String TYPE_MTAA = 'MTAA';
	public static final String TYPE_DRY_NEEDLING = 'Dry Needling';
	public static final String TYPE_INSURANCE_CONSULTANT = 'Insurance Consultant';
	public static final String RENEWAL = 'Renewal';
	public static final String NURSING = 'Nursing';
	public static final Set<String> EXPIRY_STATUS_SET = new Set<String>{
		'Void', 'Expired'
	};
	public static final String REAL_ESTATE_SCHOOL = 'Real Estate School';
	public static final String LICENSE_TYPE_PSYCHOLOGIST = 'Psychologist';
	public static final String TYPE_HEALTH_SERVICE_PROVIDER = 'Health Service Provider (HSP)';
	public static final String LPI_ACTIVE = 'Active';
	public static final String LPI_INACTIVE = 'Inactive';

	
	public static final String  LICENSE_TYPE_PHARMACIST = 'Pharmacist';
	public static final String TYPE_NOTIFICATION_OF_INTENT = 'Notification of Intent';
	
	
	public static final String YES = 'Yes';
	public static final String NO = 'No';
    
	private static final Set<Integer> FEB_END_DAYS_SET = new Set<Integer>{
		28,
		29
	};
	
	private final static String ALIAS_TYPE_CORPORATION = 'Corporation';
    private static final String ALIAS_TYPE_LEGAL_NAME = 'Legal Name';
    private static final String ALIAS_TYPE_BUSINESS = 'Business';
    private static final String ALIAS_TYPE_DBA = 'DBA';
	 
	private final static String TYPE_INDIVIDUAL = 'Individual';
	private final static String NO_EXPIRY = 'No Expiry';
	private final static String STATUS_EXPIRED = 'Expired';
	private final static String STATUS_VOID = 'Void';
	private final static String LAWFUL_PRESENCE_EXPIRED = 'Lawful Presence Expired';
	private static String getClassName() {
		return 'LPI_BusinessLicenseTriggerHelper';
	}
	private static final String CIITIZENSHIP_FOREIGN = 'FOREIGN';

    public static void populateInactivationDateOnBLInactivation(
		List<BusinessLicense> recordsList,
		Map<Id, BusinessLicense> mapOfOldRecords
	) {
		try {
			for (BusinessLicense bl : recordsList) {
				 
				if (bl.Status != mapOfOldRecords.get(bl.Id).Status &&
					bl.Status == LPI_LiteralConstant.BUSINESSLICENSE_STATUS_INACTIVE) {
					bl.Inactivation_Date__c = Date.today();
				}
				
			}
		} catch (Exception ex) {
			LPI_ExceptionManager.logException('LPI_BusinessLicenseTriggerHelper', 'populateInactivationDateOnBLInactivation', ex);
			throw new LPI_Exception(ex.getMessage());
		}
	}

	/**
	 * @author                  : MTX Group Product Team
	 * @description             : This Method send Portal notification to applicant once (Contact prior to renewa) field is marked as Yes
	 * @param recordsList
	 * @param mapOfOldRecords
	 * @exception
	 */
	public static void getPortalNotificationOnChangeOfField(
		List<BusinessLicense> recordsList,
		Map<Id, BusinessLicense> mapOfOldRecords
	) {
		try {
			Set<Id> updatedBusinessLicense = new Set<Id>();
			Map<String, Portal_Notification_Message__mdt> portalNotificationMessageMap;
			List<Notification__c> portalNotificationToInsert = new List<Notification__c>();
			Notification__c portalNoti = new Notification__c();

			
			for (BusinessLicense bl : recordsList) {
				updatedBusinessLicense.add(bl.Id);
			}
			 
			portalNotificationMessageMap = LPI_ServiceUtility.fetchPortalNotificationMetaDataRecord(
				APPLICABLE_LICENSE_NAME_LIST,
				new List<String>{ RENEWAL },
				new List<String>{ RENEWAL },
				new List<String>{ NURSING }
			);
			 
			for (BusinessLicense bl : LPI_BusinessLicenseDAO.getBLRecordsByID(updatedBusinessLicense)) {
				if (
					bl.Contact_prior_to_renewal__c == 'Yes' &&
					mapOfOldRecords.get(bl.Id).Contact_prior_to_renewal__c != bl.Contact_prior_to_renewal__c &&
					APPLICABLE_LICENSE_NAME_LIST.Contains(bl.RegulatoryAuthorizationType.Name)
				) {
					 
					String key = LPI_ServiceUtility.createKeyForMetaDataMap(
						bl.RegulatoryAuthorizationType.Name,
						RENEWAL,
						RENEWAL,
						NURSING
					);

					 
					portalNoti = LPI_ServiceUtility.createPortalNotificationRecord(
						portalNotificationMessageMap.get(key),
						false,
						null,
						null,
						bl.Contact.AccountId
					);

					 
					if (portalNoti != null) {
						portalNotificationToInsert.add(portalNoti);
					}
				}
			}

			 
			if (!portalNotificationToInsert.isEmpty()) {
				LPI_DML.doInsert(portalNotificationToInsert);
			}
		} catch (Exception ex) {
			LPI_ExceptionManager.logException(getClassName(), 'getPortalNotificationOnChangeOfField', ex);
			throw new LPI_Exception(ex.getMessage());
		}
	}
    
    
    /**
     * @author                      : MTX Group Product Team
     * @since                       : 19 April, 2023
     * @description                 : This method will call LPI_BusinessLicenseFieldUpdateBatch to update Business_License_JSON__c field on related BL records
     * @param recordsList           : Takes New List of List<BusinessLicense> (BusinessLicense Records)
     * @param mapOfOldRecords       : Takes Old Map of Map<Id, BusinessLicense> (BusinessLicense Records)
     * @return                      : `void`
     * @last modified by            : MTX Group Product Team
     * @last modified date          :
     * @modified details            :
     */
    public static void updateBlJson(
        List<BusinessLicense> recordsList,
        Map<Id, BusinessLicense> mapOfOldRecords
    ) {
        try {
            Set<String> licNoSet = new Set<String>();
            Set<Id> businessLicenseIdSet = new Set<Id>();
            String fields;
            String whereClause;
            
            if (mapOfOldRecords == null) {
                for (BusinessLicense bl : recordsList) {
                    businessLicenseIdSet.add(bl.Id);
                    if (String.isNotBlank(bl.Name)) {
                        
                        licNoSet.add(bl.Name);
                    }
                }
                
                
            }
            
            else{
                for (BusinessLicense bl : recordsList) {
                    if (
                        mapOfOldRecords.get(bl.Id).RegulatoryAuthorizationTypeId != bl.RegulatoryAuthorizationTypeId ||
                        mapOfOldRecords.get(bl.Id).AccountId != bl.AccountId ||
						mapOfOldRecords.get(bl.Id).Business_Name__c != bl.Business_Name__c ||
						mapOfOldRecords.get(bl.Id).First_Name__c != bl.First_Name__c ||
						mapOfOldRecords.get(bl.Id).Middle_Name__c != bl.Middle_Name__c	 ||
						mapOfOldRecords.get(bl.Id).Last_Name__c	 != bl.Last_Name__c	 ||
                        (mapOfOldRecords.get(bl.Id).Disciplinary_Status__c != bl.Disciplinary_Status__c && (String.isBlank(bl.Disciplinary_Status__c) || String.isBlank(mapOfOldRecords.get(bl.Id).Disciplinary_Status__c)))
                    ) {
                        businessLicenseIdSet.add(bl.Id);
                    }
                    
                }
            }
            
            if (
                !(businessLicenseIdSet.isEmpty() ||
                System.isBatch() ||
                System.isFuture() ||
                System.isQueueable())
            ) {
                LPI_BusinessLicenseFieldUpdateBatch blBatch = new LPI_BusinessLicenseFieldUpdateBatch(
                    businessLicenseIdSet
                );
                database.executeBatch(blBatch);
            }
        } catch (Exception exp) {
            LPI_ExceptionManager.logException(
                getClassName(),
                'updateBlJson',
                exp
            );
        }
    }

    /**
     * @author                      : MTX Group Product Team
     * @since                       : 1 May, 2023
     * @description                 : This is used to check the status of BL (Void/Expired) 
	 * @scenarios				      1. If BL get Void/Expired for Real Estate School, Expire the Related Courses
     * @param lstNewBLRecords       : Takes New List of List<BusinessLicense> (BusinessLicense Records)
     * @param mapOldBLRecords       : Takes Old Map of Map<Id, BusinessLicense> (BusinessLicense Records)
     * @return                      : `void`
     * @last modified by            : MTX Group Product Team
     * @last modified date          : 1 May, 2023(Add if modified by you)
     * @modified details            : Removed 'Course Status' and used 'Status' instead (Add if modified by you)
     */
	public static void manageBusinessLicenseExpiry(List<BusinessLicense> lstNewBLRecords, Map<Id, BusinessLicense> mapOldBLRecords){
		try {
			Set<Id> setRealStateSchoolAccount = new Set<Id>();
			for(BusinessLicense updatedBLRecord : lstNewBLRecords){
				if(updatedBLRecord.Status != mapOldBLRecords.get(updatedBLRecord.Id).Status
				&& EXPIRY_STATUS_SET.contains(updatedBLRecord.Status)
				&& updatedBLRecord.Regulatory_Authorization_Type_Name__c.equalsIgnoreCase(REAL_ESTATE_SCHOOL)){
					setRealStateSchoolAccount.add(updatedBLRecord.AccountId);
				}
			}
			if(!setRealStateSchoolAccount.isEmpty()){
				List<TrnCourse> lstTrnCourseToUpdate = new List<TrnCourse>();
				String fieldsToQuery = 'Id, Status';
				String whereConditions = 'Account__c IN ' + LPI_ServiceUtility.getStringValuesBySet(setRealStateSchoolAccount);
				for(TrnCourse courseToUpdate : LPI_TrnCourseDAO.getTrnCourseByDymanicQuery(fieldsToQuery, whereConditions, null, null, null)){
					lstTrnCourseToUpdate.add(new TrnCourse(Id = courseToUpdate.Id, Status = COURSE_STATUS_EXPIRED));
				}
				if(!lstTrnCourseToUpdate.isEmpty()){
					LPI_DML.doUpdate(lstTrnCourseToUpdate);
				}
			}
		} catch (Exception ex) {
			LPI_ExceptionManager.logException(
                getClassName(),
                'manageBusinessLicenseExpiry',
                ex
            );
		}
	}

	
	
	
	

	 

	/**
     * @author                      :MTX Group Product Team
     * @since                       : 21st Novemeber 2023
     * @description                 : This method is to update Name on Account when Name is updated on License and creates an alias Name record(I-243729)
     * @param recordsList           : Takes New List of List<BusinessLicense> (BusinessLicense Records)
     * @param mapOfOldRecords       : Takes Old Map of Map<Id, BusinessLicense> (BusinessLicense Records)
     * @return                      : `void`
     * @last modified by            : MTX Group Product Team
     * @last modified date          :
     * @modified details            :
     */
	public static void updateAccountNamesonBlNameChange(List<BusinessLicense> recordsList,Map<Id, BusinessLicense> mapOfOldRecords) {
		try {
			Set<Id> businessIds = new Set<Id>();
			String fieldsToQuery, whereClause;
			String appType = 'Individual';
			List<Account> accountsToUpdate = new List<Account>();
			List<SObject> upsertList = new List<SObject>();
			Set<Id> accountIdSet = new Set<Id>();
			
			for (BusinessLicense bl : recordsList) {
				BusinessLicense oldBl = mapOfOldRecords.get(bl.Id);
				
				if (oldBl != null && (oldBl.First_Name__c != bl.First_Name__c
				|| oldBl.Middle_Name__c != bl.Middle_Name__c 
				|| oldBl.Last_Name__c != bl.Last_Name__c
				|| oldBl.Maiden_Name__c != bl.Maiden_Name__c)) {															
					businessIds.add(bl.Id);
				}
			}
			if(!businessIds.isEmpty()){
				fieldsToQuery = 'Id,AccountId,RegulatoryAuthorizationTypeId,First_Name__c,Middle_Name__c,Last_Name__c,Maiden_Name__c,Account.FirstName,Account.MiddleName,Account.LastName,Account.Maiden_Name__c';
				whereClause = 'Id IN ' + LPI_ServiceUtility.getStringValuesBySet(businessIds) +
				' AND RegulatoryAuthorizationType.Authorisation_Type__c = \'' +appType+ '\'';
				
				for(BusinessLicense bl : LPI_BusinessLicenseDAO.fetchBusinessLicenseRecords(fieldsToQuery,whereClause)){
					if (bl.First_Name__c != bl.Account.FirstName
						|| bl.Middle_Name__c != bl.Account.MiddleName
						|| bl.Last_Name__c != bl.Account.LastName) {															
						String firstName = bl.First_Name__c != null ? bl.First_Name__c + ' ' : '';
						String middleName = bl.Middle_Name__c != null ? bl.Middle_Name__c + ' ' : '';
						String lastName = bl.Last_Name__c != null ? bl.Last_Name__c : '';
						
						upsertList.add(createAliasInstance(firstName + middleName + lastName, ALIAS_TYPE_LEGAL_NAME, bl.AccountId));
					}
					if(!accountIdSet.contains(bl.AccountId)){
						Account acc = new Account();
						acc.Id = bl.AccountId;
						acc.FirstName = bl.First_Name__c;
						acc.MiddleName = bl.Middle_Name__c;
						acc.LastName = bl.Last_Name__c;
						acc.Maiden_Name__c = bl.Maiden_Name__c;
						accountIdSet.add(bl.AccountId);
						upsertList.add(acc);
					}
				}
			}
			if(!accountIdSet.isEmpty()){
				fieldsToQuery = 'Id, Status__c, Alias_Thru_Date__c';
				whereClause = 'Status__c = \'' + LPI_ACTIVE + '\' AND Alias_Type__c = \'' + 'Legal Name' + '\' AND Is_Present_On_Account__c = true AND Alias_Thru_Date__c = null';
                whereClause += ' AND Account__c IN ' + LPI_ServiceUtility.getStringValuesBySet(accountIdSet);
                for(Alias__c alias : LPI_AliasDAO.getAliasByDymanicQuery(fieldsToQuery, whereClause, null, null, null)){
					alias.Alias_Thru_Date__c = Date.today();
					alias.Is_Present_On_Account__c = false;
					upsertList.add(alias);
				}
			}
			
		 
			if (!upsertList.isEmpty()) {
				upsertList.sort();
				LPI_DML.doUpsert(upsertList);
			}
		}  catch (Exception ex) {
			LPI_ExceptionManager.logException(getClassName(), 'updateAccountNamesonBlNameChange', ex);
			throw new LPI_Exception(ex.getMessage());
		}
	}

	/**
     * @author                      :MTX Group Product Team
     * @since                       : 17th Jan 2024
     * @description                 : This method is to update Renewal Start Date, Renewal End Dates on BL which indicates whether license is in renewal or not. (S-53693)
     * @param recordsList           : Takes New List of List<BusinessLicense> (BusinessLicense Records)
     * @param mapOfOldRecords       : Takes Old Map of Map<Id, BusinessLicense> (BusinessLicense Records)
     * @return                      : `void`
     * @last modified by            : MTX Group Product Team
     * @last modified date          :
     * @modified details            :
     */
	public static void updateRenewalPeriodFields(List<BusinessLicense> blList){
		try {
			Set<Id> blIdSet = new Set<Id>();
			List<BusinessLicense> blListToUpdate = new List<BusinessLicense>();
			for(BusinessLicense bl : blList){
				blIdSet.add(bl.Id);
			}
			for (
				BusinessLicense blRecord : new LPI_BusinessLicenseDAO.LPI_BusinessLicenseWithoutSharingDAO()
					.getBusinessLicenseByDymanicQuery(
						'Id, PeriodEnd, RegulatoryAuthorizationType.Open_for_Renewal__c, RegulatoryAuthorizationType.Late_Renewal_Allowed__c, Renewal_Period_Start_Date__c, Renewal_Period_End_Date__c',
						' Id IN ' + LPI_ServiceUtility.getStringValuesBySet(blIdSet) + ' AND RegulatoryAuthorizationTypeId != null',
						null,
						null,
						null
					)
			) {
				if(blRecord.PeriodEnd == null){
					continue;
				}
				Date expiryDate = Date.newInstance(blRecord.PeriodEnd.year(), blRecord.PeriodEnd.month(), blRecord.PeriodEnd.day());
				Date renewalStartDate;
				 
				if (blRecord.RegulatoryAuthorizationType.Open_for_Renewal__c != null) {
					 
					renewalStartDate = expiryDate.addMonths(
						-Integer.valueOf(blRecord.RegulatoryAuthorizationType.Open_for_Renewal__c)
					);
				}else{
				 
					renewalStartDate = expiryDate;
				}
				Date renewalEndDate;
				 
				if (blRecord.RegulatoryAuthorizationType.Late_Renewal_Allowed__c != null) {
					renewalEndDate = expiryDate.addMonths(
						Integer.valueOf(blRecord.RegulatoryAuthorizationType.Late_Renewal_Allowed__c)
					);
				}else{
					 
					renewalEndDate = expiryDate;
				}
				 
				if((expiryDate.month() == 2 && FEB_END_DAYS_SET.contains(expiryDate.day())) || expiryDate.day() == date.daysInMonth(expiryDate.year(),expiryDate.month())){
					renewalStartDate = renewalStartDate.addMonths(1).toStartOfMonth();
					renewalEndDate = renewalEndDate.addMonths(1).toStartOfMonth().addDays(-1);
				}else{
					 
					renewalStartDate = renewalStartDate.addDays(1);
				}
				blRecord.Renewal_Period_Start_Date__c = renewalStartDate;
				blRecord.Renewal_Period_End_Date__c = renewalEndDate;
				blListToUpdate.add(blRecord);
			}
			if(!blListToUpdate.isEmpty()){
				LPI_WithoutSharingUtility.updateSObjectList(blListToUpdate);
			}
		} catch (Exception ex) {
			LPI_ExceptionManager.logException(getClassName(), 'updateRenewalPeriodFields', ex);
			throw new LPI_Exception(ex.getMessage());
		}
	}

	/**
     * @author                      : MTX Group Product Team
     * @since                       : 26th Mar 2024
     * @description                 : This method is create/update the alias records when Name_of_the_Professional_Corporation__c is updated (S-61933)
     * @param recordsList           : Takes New List of List<BusinessLicense> (BusinessLicense Records)
	 * @param mapOfOldRecords       : Takes Old Map of Map<Id, BusinessLicense> (BusinessLicense Records)
     * @return                      : `void`
     * @last modified by            : MTX Group Product Team
     * @last modified date          :
     * @modified details            :
     */
	public static void createAndUpdateAliasRecords(List<BusinessLicense> blList, Map<Id, BusinessLicense> mapOfOldRecords){
		try {
			Set<Id> corporationNameUpdateAccSet = new Set<Id>();
			Set<Id> dbaNameUpdateAccSet = new Set<Id>();
			Set<Id> businessNameUpdateAccSet = new Set<Id>();
			List<Alias__c> aliasListTobeUpserted = new List<Alias__c>();
			for (BusinessLicense bl : blList) {
				if(bl.Name_of_the_Professional_Corporation__c != mapOfOldRecords.get(bl.Id).Name_of_the_Professional_Corporation__c){
					corporationNameUpdateAccSet.add(bl.AccountId);
				}
				if(bl.Doing_Business_As_DBA_or_Trade_Name__c != mapOfOldRecords.get(bl.Id).Doing_Business_As_DBA_or_Trade_Name__c){
					dbaNameUpdateAccSet.add(bl.AccountId);
				}
				if(bl.Business_Name__c != mapOfOldRecords.get(bl.Id).Business_Name__c){
					businessNameUpdateAccSet.add(bl.AccountId);
				}
			}
			if(!corporationNameUpdateAccSet.isEmpty() || !dbaNameUpdateAccSet.isEmpty() || !businessNameUpdateAccSet.isEmpty()){
				String fields = 'Id, Status__c, Alias_Thru_Date__c, Is_Present_On_Account__c';
				String whereClause = '';
				if(!corporationNameUpdateAccSet.isEmpty()){
					whereClause += '(Alias_Type__c = \'' + ALIAS_TYPE_CORPORATION + '\' AND Account__c IN ' + LPI_ServiceUtility.getStringValuesBySet(corporationNameUpdateAccSet) + ')';
				}
				if(!dbaNameUpdateAccSet.isEmpty()){
					if(String.isNotBlank(whereClause)){
						whereClause += ' OR (Alias_Type__c = \'' + ALIAS_TYPE_DBA + '\' AND Account__c IN ' + LPI_ServiceUtility.getStringValuesBySet(dbaNameUpdateAccSet) + ')';
					}else{
						whereClause += '(Alias_Type__c = \'' + ALIAS_TYPE_DBA + '\' AND Account__c IN ' + LPI_ServiceUtility.getStringValuesBySet(dbaNameUpdateAccSet) + ')';
					}
				}
				if(!businessNameUpdateAccSet.isEmpty()){
					if(String.isNotBlank(whereClause)){
						whereClause += ' OR (Alias_Type__c = \'' + ALIAS_TYPE_BUSINESS + '\' AND Account__c IN ' + LPI_ServiceUtility.getStringValuesBySet(businessNameUpdateAccSet) + ')';
					}else{
						whereClause += '(Alias_Type__c = \'' + ALIAS_TYPE_BUSINESS + '\' AND Account__c IN ' + LPI_ServiceUtility.getStringValuesBySet(businessNameUpdateAccSet) + ')';
					}
				}
				String whereClauseFinal = '(' + whereClause + ') AND Status__c = \'' + LPI_ACTIVE + '\' AND Is_Present_On_Account__c = true AND Alias_Thru_Date__c = null';
                for(Alias__c alias : LPI_AliasDAO.getAliasByDymanicQuery(fields, whereClauseFinal, null, null, null)){
					alias.Alias_Thru_Date__c = Date.today();
					alias.Is_Present_On_Account__c = false;
					aliasListTobeUpserted.add(alias);
				}
				for (BusinessLicense bl : blList) {
					if(bl.Name_of_the_Professional_Corporation__c != mapOfOldRecords.get(bl.Id).Name_of_the_Professional_Corporation__c){
						aliasListTobeUpserted.add(createAliasInstance(bl.Name_of_the_Professional_Corporation__c, ALIAS_TYPE_CORPORATION, bl.AccountId));
					}
					if(bl.Doing_Business_As_DBA_or_Trade_Name__c != mapOfOldRecords.get(bl.Id).Doing_Business_As_DBA_or_Trade_Name__c){
						aliasListTobeUpserted.add(createAliasInstance(bl.Doing_Business_As_DBA_or_Trade_Name__c, ALIAS_TYPE_DBA, bl.AccountId));
					}
					if(bl.Business_Name__c != mapOfOldRecords.get(bl.Id).Business_Name__c){
						aliasListTobeUpserted.add(createAliasInstance(bl.Business_Name__c, ALIAS_TYPE_BUSINESS, bl.AccountId));
					}
				}
			}
			if(!aliasListTobeUpserted.isEmpty()){
				LPI_DML.doUpsert(aliasListTobeUpserted);
			}
		} catch (Exception ex) {
			LPI_ExceptionManager.logException(getClassName(), 'createAndUpdateAliasRecords', ex);
			throw new LPI_Exception(ex.getMessage());
		}
	}

	/**
     * @author                      : MTX Group Product Team
     * @since                       : 29th Mar 2024
     * @description                 : This method will create alias instance and can be used in multiple places
     * @param aliasName             : String of alias Name
	 * @param aliasType       	    : String of alias type
	 * @param accountId             : String of accountId
     * @return                      : `void`
     * @last modified by            : MTX Group Product Team
     * @last modified date          :
     * @modified details            :
     */
	private static Alias__c createAliasInstance(String aliasName, String aliasType, String accountId){
		Alias__c aliasData = new Alias__c();
		aliasData.Name = aliasName;
		aliasData.Alias_Type__c = aliasType;
		aliasData.Alias_From_Date__c = Date.today();
		aliasData.Account__c = accountId;
		aliasData.Status__c = LPI_ACTIVE;
		aliasData.Is_Present_On_Account__c = true;
		return aliasData;
	}
	/**
     * @author                      : MTX Group Product Team
     * @since                       : 01st May 2024
     * @description                 : This method will throw error if board staff manually updates the expiry date and expiry date 
	 * 								  is greater than lawful presence date
     * @param recordsList           : List<BusinessLicense>
	 * @param mapOfOldRecords       : Map<Id, BusinessLicense>
     * @return                      : `void`
     * @last modified by            : MTX Group Product Team
     * @last modified date          :
     * @modified details            :
     */
	public static void validateExpiryDate(List<BusinessLicense> recordList, Map<Id, BusinessLicense> mapOfOldRecords){
		try{
			Set<Id> blIdSet = new Set<Id>();
			Map<Id, BusinessLicense> blIdToBlMap = new Map<Id, BusinessLicense>();
			for(BusinessLicense bl : recordList){
				if(bl.PeriodEnd != null && mapOfOldRecords.get(bl.Id).PeriodEnd != bl.PeriodEnd){
					blIdToBlMap.put(bl.Id, bl);
				}
			}
			if(blIdToBlMap.isEmpty()){
				return;
			}
			String fields = 'Id, Name, Account.LawfulPresenceExpirationDate__c, Account.Citizenship__c, PeriodEnd';
			String whereClause = ' Id IN ' + LPI_ServiceUtility.getStringValuesBySet(blIdToBlMap.keySet());
			for (BusinessLicense bl : 
				LPI_BusinessLicenseDAO.fetchBusinessLicenseRecords(fields,whereClause)
			) {
 				if(bl.Account?.Citizenship__c == CIITIZENSHIP_FOREIGN && bl.Account?.LawfulPresenceExpirationDate__c != null &&
					bl.Account?.LawfulPresenceExpirationDate__c < Date.newInstance(bl?.PeriodEnd?.year(), bl?.PeriodEnd?.month(), bl?.PeriodEnd?.day())){
					blIdToBlMap.get(bl.Id)?.addError('The validity of Lawful Presence ends on ' + Date.valueOf(bl.Account.LawfulPresenceExpirationDate__c).format() + 
						'. The license expiration date must not exceed the lawful presence expiration date.');
				}
			}
		}catch (Exception ex) {
			LPI_ExceptionManager.logException(getClassName(), 'validateExpiryDate', ex);
			throw new LPI_Exception(ex.getMessage());
		}
	}
	/**
     * @author                      : MTX Group Product Team
     * @since                       : 15th May 2024
     * @description                 : This method will update calculated expiry date for manually updated licenses
     * @param recordsList           : List<BusinessLicense>
	 * @param mapOfOldRecords       : Map<Id, BusinessLicense>
     * @return                      : `void`
     * @last modified by            : MTX Group Product Team
     * @last modified date          :
     * @modified details            :
     */
	public static void updateCalculatedExpiryDate(List<BusinessLicense> recordList, Map<Id, BusinessLicense> mapOfOldRecords){
		try{
			Set<Id> blIdSet = new Set<Id>();
			
			if(blIdSet.isEmpty()){
				return;
			}
			List<BusinessLicense> updateBlList = new List<BusinessLicense>();
			String fields = 'Id, Name, Account.LawfulPresenceExpirationDate__c, Account.Citizenship__c, PeriodEnd, RegulatoryAuthorizationType.Expiry_Rule_Type__c, RegulatoryAuthorizationType.Authorisation_Type__c';
			String whereClause = ' Id IN ' + LPI_ServiceUtility.getStringValuesBySet(blIdSet) + 
				' AND RegulatoryAuthorizationType.Authorisation_Type__c = \'' + TYPE_INDIVIDUAL + '\'' + 
				' AND (RegulatoryAuthorizationType.Expiry_Rule_Type__c = \'' + NO_EXPIRY + '\'' +
				' OR RegulatoryAuthorizationType.Expiry_Rule_Type__c = null)';
			for (BusinessLicense bl : 
				LPI_BusinessLicenseDAO.fetchBusinessLicenseRecords(fields,whereClause)
			) {
				BusinessLicense newBl = new BusinessLicense();
				newBl.Id = bl.Id;
				
				if(bl.Account.Citizenship__c == CIITIZENSHIP_FOREIGN && bl.Account?.LawfulPresenceExpirationDate__c != null &&
				bl.Account?.LawfulPresenceExpirationDate__c < Date.newInstance(bl?.PeriodEnd?.year(), bl?.PeriodEnd?.month(), bl?.PeriodEnd?.day())){
					newBl.PeriodEnd = Datetime.newInstance(bl?.Account?.LawfulPresenceExpirationDate__c?.year(), bl?.Account?.LawfulPresenceExpirationDate__c?.month(), 
					bl?.Account?.LawfulPresenceExpirationDate__c?.day(), 23, 59, 59);
				}
				updateBlList.add(newBl);
			}
			if(!updateBlList.isEmpty()){
				
				LPI_WithoutSharingUtility.updateSObjectList(updateBlList);
			}
		}
		catch(Exception e){
			LPI_ExceptionManager.logException(getClassName(), 'updateCalculatedExpiryDate', e);
		}
	}
	 /**
     * @author                      : MTX Group Product Team
     * @since                       : 15th May 2024
     * @description                 : This method will update license sub status if substatus is lawful presence expired the status is changed
     * @param recordsList           : List<BusinessLicense>
	 * @param mapOfOldRecords       : Map<Id, BusinessLicense>
     * @return                      : `void`
     * @last modified by            : MTX Group Product Team
     * @last modified date          :
     * @modified details            :
     */
	public static void updateLicenseSubStatusOnStatusChange(List<BusinessLicense> recordList, Map<Id, BusinessLicense> mapOfOldRecords){
		try{
			List<BusinessLicense> updateBlList = new List<BusinessLicense>();
			for(BusinessLicense bl : recordList){
				if(bl.status != null &&  mapOfOldRecords.get(bl.Id).Status != bl.Status &&
					mapOfOldRecords.get(bl.Id).Status == STATUS_EXPIRED && bl.Status != STATUS_VOID && 
					bl.License_Sub_Status__c == LAWFUL_PRESENCE_EXPIRED){
					bl.License_Sub_Status__c = '';
				}
			}
		}catch(Exception e){
			LPI_ExceptionManager.logException(getClassName(), 'updateLicenseSubStatusOnStatusChange', e);
		}
	}
}