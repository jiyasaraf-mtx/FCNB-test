/**
 * @author          : MTX Group Product Team
 * @description     : This class fetch, Save and delete all the Details Business Relationship related to Preneed Seller/Provider
 */
global with sharing class LPI_PreneedBusinessInformation implements Callable {
	global Object call(String action, Map<String, Object> args) {
		Map<String, Object> input = (Map<String, Object>) args.get('input');
		Map<String, Object> output = (Map<String, Object>) args.get('output');
		Map<String, Object> options = (Map<String, Object>) args.get('options');
		return invokeMethod(action, input, output, options);
	}

	public final static String SAVE_PREENED_BUSINESS_INFORMATION = 'savePreneedBusinessInformation';
	public final static String FETCH_PRENEED_BUSINESS_INFORMATION = 'fetchPreneedBusinessInformation';
	public final static String DELETE_PRENEED_BUSINESS_INFORMATION = 'deletePreneedBusinessInformation';
    public final static String UNITED_STATES = 'US';
    public final static String PRENEED_BUSS_ROLE = 'Authorised Sellers/Dealers';


	/**
	 * @author               : MTX Group Product Team
	 * @param methodName     : Method Name
	 * @param inputMap       : Input Parameter Passed from Omniscript
	 * @param outMap         : Output Passed to Omniscript
	 * @param options        : Extra Options passed from Omniscript
	 * @last modified by     : MTX Group Product Team
	 * @last modified date   : 25 Jan, 2023
	 * @return  `Boolean`
	 */
	private Boolean invokeMethod(
		String methodName,
		Map<String, Object> inputMap,
		Map<String, Object> outMap,
		Map<String, Object> options
	) {
		if (methodName == SAVE_PREENED_BUSINESS_INFORMATION) {
			savePreneedBusinessInformation(inputMap, outMap);
		} else if (methodName == FETCH_PRENEED_BUSINESS_INFORMATION) {
			fetchPreneedBusinessInformation(inputMap, outMap , false);
		} else if (methodName == DELETE_PRENEED_BUSINESS_INFORMATION) {
			deletePreneedBusinessInformation(inputMap, outMap);
		}
		return true;
	}

	/**
	 * @author : MTX Group Product Team
	 * @description This method is used to Save one or multiple Preneed Seller/Provider Business Informations
	 * @param inputMap fetching all the input from Omniscript
	 * @param outMap Passing value to Omniscript
	 * @since 8 Jan 2022
	 */
	public static void savePreneedBusinessInformation(Map<String, Object> inputMap, Map<String, Object> outMap) {
		try {
			Map<String, object> preneedSellerInformationStepInfo = (Map<String, object>) inputMap.get(
				'EFDApplicationPreneedSellerInformationStep'
			);
			String parId = (String) inputMap.get('parid');
			Integer noOfBranches = (Integer) PreneedSellerInformationStepInfo.get(
				'EFDApplicationPreneedSellerInfoNoOfBranches'
			);
			Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
				.get(LPI_LiteralConstant.ACCOUNT_BUSINESS_RECORDTYPE)
				.getRecordTypeId();
			Id userAccId;
			String fields;
			String whereClause;
			if (String.isNotBlank(parId)) {
				fields = 'BusinessAccountNameId';
				whereClause = 'Id =\'' + String.escapeSingleQuotes(parId) + '\'';
				List<PreliminaryApplicationRef> par = LPI_PreliminaryApplicationRefDAO.getPreliminaryApplicationRefByDymanicQuery(
					fields,
					whereClause,
					null,
					null,
					null
				);
                if(!par.isEmpty()){
                	userAccId = par[0].BusinessAccountNameId;   
                }
			}
			if (noOfBranches == 1) {
				Map<String, object> preneedSellerInformationBlockInfo = (Map<String, object>) preneedSellerInformationStepInfo.get(
					'EFDApplicationPreneedSellerInformationBlock'
				);
				 
				preneedSellerInformationBlockInfo.put('accRecordTypeId', (String) accRecordTypeId);
				preneedSellerInfoWrapper preneedWrapper = (preneedSellerInfoWrapper) JSON.deserialize(
					JSON.serialize(PreneedSellerInformationStepInfo.get('EFDApplicationPreneedSellerInformationBlock')),
					preneedSellerInfoWrapper.class
				);
				LPI_BusinessLicenseDAO.LPI_BusinessLicenseWithoutSharingDAO withoutSharingBL1 = new LPI_BusinessLicenseDAO.LPI_BusinessLicenseWithoutSharingDAO();
				String isPreneedEntity = preneedWrapper.EFDApplicationPreneedSellerInformationIsThePreneed;
				 
				String licenseNumEntityName = preneedWrapper.LicenseNumEntityName;
				Boolean isLicenseEntityName = preneedWrapper.isLicenseEntityName;
				String licenseNumberNo = preneedWrapper.EFDApplicationPreneedSellerInformationLicenseNumber;
				String newAccountId = preneedWrapper.newAccountId;
				Boolean isActive = preneedWrapper.IsActive; 
                Boolean IsRelatedFrom = preneedWrapper.IsRelatedFrom;
				Boolean isRelationWithYou = preneedWrapper.EFDApplicationPreneedSellerInformationRelationshipForYou;
				Id selectedBlId = preneedWrapper.selectedBusinessLicenseId;
				String licenseNumber;
				if(selectedBlId != null){
					fields = 'Name';
					whereClause = 'Id =\'' + String.escapeSingleQuotes(selectedBlId) + '\'';
					List<BusinessLicense> blName = withoutSharingBL1.getBusinessLicenseByDymanicQuery(
								fields,
								whereClause,
								null,
								null,
								null
							);
					licenseNumber = blName[0].Name;
				}
				String accId;
				Set<Id> IdSet = new Set<Id>();
				if (isActive == true || IsRelatedFrom == true) {
					Business_Relationships__c BussRelation = new Business_Relationships__c();
					bussRelation.id = preneedWrapper.blockAcrId;
					bussRelation.If_Relationship_is_Associated_with_you__c = isRelationWithYou;
					LPI_DML.doUpdate(BussRelation);
					return;
				}
				LPI_BusinessLicenseDAO.LPI_BusinessLicenseWithoutSharingDAO withoutSharingBL = new LPI_BusinessLicenseDAO.LPI_BusinessLicenseWithoutSharingDAO();
				if (isPreneedEntity == 'Yes') {
					 
					fields = 'AccountId';
					if (String.isNotEmpty(licenseNumber)) {
						whereClause = 'Name =\'' + String.escapeSingleQuotes(licenseNumber) + '\'';
						List<BusinessLicense> bl = withoutSharingBL.getBusinessLicenseByDymanicQuery(
							fields,
							whereClause,
							null,
							null,
							null
						);
						if (bl.size() > 0) {
							accId = bl[0].AccountId;
						}
					}
					 
					IdSet.add(accId);
					List<Business_Relationships__c> siteIdList = new List<Business_Relationships__c>();
					siteIdList = queryBusinessContactRelation(
						userAccId,
						LPI_ServiceUtility.getStringValuesBySet(IdSet)
					);
					IdSet.clear();

					Business_Relationships__c accConRelation = new Business_Relationships__c();
                    accConRelation = createBusinessRelationship(
							siteIdList.size()==0 ? null:siteIdList[0].Id,
							userAccId,
							accId,
							false,
							'Yes',
							isLicenseEntityName == true ? licenseNumEntityName : licenseNumber,
							true,
							selectedBlId);
                    
					if (accConRelation != null) {
						 
                        LPI_WithoutSharingUtility.upsertSObject(accConRelation);
					}
				} else {
					Map<String, String> keyMapping = new Map<String, String>{
						'EFDApplicationPreneedSellerInformationName' => 'Name',
						'EFDApplicationPreneedSellerInformationCity' => 'BillingCity',
						'EFDApplicationPreneedSellerInformationState' => 'BillingStateCode',
						'EFDApplicationPreneedSellerInformationStreet1' => 'BillingStreet',
						'EFDApplicationPreneedSellerInformationZip' => 'BillingPostalCode',
						'accRecordTypeId' => 'RecordTypeId'
					};
					Account accRec = (Account) LPI_VlocityUtility.createSObject(
						preneedSellerInformationBlockInfo,
						keyMapping,
						'Account'
					);
			        accRec.put('BillingCountryCode', UNITED_STATES);
					List<Account> accountsList = new List<Account>();
					accountsList.add(accRec);
					 
					List<Datacloud.MatchRecord> existingAccountList = new List<Datacloud.MatchRecord>();
					if (accountsList.size() > 0) {
						existingAccountList = LPI_ServiceUtility.getDuplicateRecordsService(accountsList);
					}

					if (!existingAccountList.isEmpty()) {
						accRec.Id = existingAccountList[0].getRecord().Id;
					} else {
						if (newAccountId != null) {
							accRec.Id = newAccountId;
						}
						 
                       	accRec = (Account) LPI_WithoutSharingUtility.upsertSObject(accRec);
					}
					 
					IdSet.add(accRec.Id);
					List<Business_Relationships__c> existingAcrNoList = new List<Business_Relationships__c>();
					existingAcrNoList = queryBusinessContactRelation(
						userAccId,
						LPI_ServiceUtility.getStringValuesBySet(IdSet)
					);

					Business_Relationships__c accConRelation = new Business_Relationships__c();
					if (existingAcrNoList.size() == 0) {
						accConRelation = createBusinessRelationship(null,userAccId,accRec.Id,false,'Pending',licenseNumberNo,true,null);
					} else {
						accConRelation = createBusinessRelationship(existingAcrNoList[0].Id,null,null,null,'Pending',licenseNumberNo,isRelationWithYou,null);
					}
                    if(accConRelation!=null){
					  
						LPI_WithoutSharingUtility.upsertSObject(accConRelation);
                    }
				}
			} else {
				List<preneedSellerInfoWrapper> preneedWrapperList = (List<preneedSellerInfoWrapper>) JSON.deserialize(
					JSON.serialize(PreneedSellerInformationStepInfo.get('EFDApplicationPreneedSellerInformationBlock')),
					List<preneedSellerInfoWrapper>.class
				);
				Set<String> bLNumbersSet = new Set<String>();
				List<Business_Relationships__c> acrList = new List<Business_Relationships__c>();
				List<Business_Relationships__c> acrYesList = new List<Business_Relationships__c>();
				List<Business_Relationships__c> acrYesUpdateList = new List<Business_Relationships__c>();
				List<Business_Relationships__c> existingAcrYesList = new List<Business_Relationships__c>();
				List<String> existingAcrYesCheckList = new List<String>();
				Map<String, Boolean> acrIdIsRelationCheckMap = new Map<String, Boolean>();
				Map<String, Id> blAccIdToBlIdMap = new Map<String, Id>();
				Map<String, Boolean> licenseNumEntityNameOrNot = new Map<String, Boolean>();
				for (preneedSellerInfoWrapper rec : preneedWrapperList) {
					if (rec.blockAcrId != null && (rec.isActive == true || rec.IsRelatedFrom ==true)) {
						acrIdIsRelationCheckMap.put(
							rec.blockAcrId,
							rec.EFDApplicationPreneedSellerInformationRelationshipForYou
						);
					}
					if (rec.EFDApplicationPreneedSellerInformationIsThePreneed == 'Yes' && rec.isActive != true && rec.IsRelatedFrom != true) {
						bLNumbersSet.add(rec.isLicenseEntityName ? rec.LicenseNumEntityName : rec.ApplicationLicenseNumber);
						licenseNumEntityNameOrNot.put(rec.LicenseNumEntityName,rec.isLicenseEntityName);
					}
				}
				Map<String, String> bLNumberAccIdsMap = new Map<String, String>();
				 
				fields = 'Id, AccountId, Name, Business_Entity_Name__c, License_Number_With_Rat_Name__c';
				String bLNamesSet = LPI_ServiceUtility.getStringValuesByList(new List<String>(bLNumbersSet));
				whereClause = 'Name IN' + bLNamesSet
					+' OR Business_Entity_Name__c IN' + bLNamesSet;
				LPI_BusinessLicenseDAO.LPI_BusinessLicenseWithoutSharingDAO withoutSharingBL = new LPI_BusinessLicenseDAO.LPI_BusinessLicenseWithoutSharingDAO();
				if (!bLNumbersSet.isEmpty()) {
					Set<Id> accIdsSet = new Set<Id>();
					for (
						BusinessLicense bl : withoutSharingBL.getBusinessLicenseByDymanicQuery(fields, whereClause,null,null,null)
					) {
						accIdsSet.add(bl.AccountId);
						blAccIdToBlIdMap.put(bl.AccountId, bl.Id);
						 
						if(licenseNumEntityNameOrNot.containsKey(bl.License_Number_With_Rat_Name__c) && licenseNumEntityNameOrNot.get(bl.License_Number_With_Rat_Name__c) == false){
							bLNumberAccIdsMap.put(bl.AccountId, bl.Name);
						}
						 
						if(licenseNumEntityNameOrNot.containsKey(bl.Business_Entity_Name__c) && licenseNumEntityNameOrNot.get(bl.Business_Entity_Name__c))
						{
							bLNumberAccIdsMap.put(bl.AccountId,bl.Business_Entity_Name__c);
						}
					}
                   
					 
					existingAcrYesList = queryBusinessContactRelation(
						userAccId,
						LPI_ServiceUtility.getStringValuesBySet(accIdsSet)
					);
					for (Business_Relationships__c existAcr : existingAcrYesList) {
						existingAcrYesCheckList.add(existAcr.Related_From__c);
						existingAcrYesCheckList.add(existAcr.Related_To__c);
					}

					Business_Relationships__c accConRelation = new Business_Relationships__c();
					for (Id accId : accIdsSet) {
						if (existingAcrYesList.size() == 0 || !existingAcrYesCheckList.contains(accId)) {
							accConRelation = createBusinessRelationship(
								null,
								userAccId,
								accId,
								false,
								'Yes',
								bLNumberAccIdsMap.get(accId),
								true,
								blAccIdToBlIdMap.get(accId)
							);
							acrYesList.add(accConRelation);
						}
					}
					 
					if (!existingAcrYesList.isEmpty()) {
						for (Business_Relationships__c acr : existingAcrYesList) {
							accConRelation = createBusinessRelationship(
								acr.Id,
								null,
								null,
								null,
								null,
								null,
								acrIdIsRelationCheckMap.get(acr.Id),
								null
							);
							acrYesList.add(accConRelation);
						}
					}
					if (!acrYesList.isEmpty()) {
						 
                        LPI_WithoutSharingUtility.upsertSObjectRecord(acrYesList);
					}
				}
				 
				List<String> keyList = new List<String>();
				Set<Id> accountIdSet = new Set<Id>();
				List<Account> newAccList = new List<Account>();
				List<Business_Relationships__c> acrNoUpdateList = new List<Business_Relationships__c>();
				List<Account> noAccountsList = new List<Account>();
				List<Datacloud.MatchRecord> noExistAccList = new List<Datacloud.MatchRecord>();
				Map<String, Account> accDataMap = new Map<String, Account>();
				Map<String, String> accKeyToLicenseMap = new Map<String, String>();
				List<Business_Relationships__c> existingAcrList = new List<Business_Relationships__c>();
				List<String> existingAcrCheckList = new List<String>();
				for (preneedSellerInfoWrapper preneedSellerInfo : preneedWrapperList) {
					if (
						preneedSellerInfo.EFDApplicationPreneedSellerInformationIsThePreneed == 'Pending' &&
						preneedSellerInfo.isActive != true && preneedSellerInfo.IsRelatedFrom != true 
					) {
						String licenseNumberNo = preneedSellerInfo.EFDApplicationPreneedSellerInformationLicenseNumber;
						String city = preneedSellerInfo.EFDApplicationPreneedSellerInformationCity;
						String state = preneedSellerInfo.EFDApplicationPreneedSellerInformationState;
						String zip = preneedSellerInfo.EFDApplicationPreneedSellerInformationZip;
						String name = preneedSellerInfo.EFDApplicationPreneedSellerInformationName;
						String street1 = preneedSellerInfo.EFDApplicationPreneedSellerInformationStreet1;
						String newAccountId = preneedSellerInfo.newAccountId;
						Account acc = new Account();
						 
						acc.Id = newAccountId;
						acc.RecordTypeId = accRecordTypeId;
						acc.Name = name;
						acc.BillingCity = city;
						acc.BillingStateCode = state;
						acc.BillingStreet = street1;
						acc.BillingPostalCode = zip;
                        acc.BillingCountryCode = UNITED_STATES;
						noAccountsList.add(acc);
						String newKey = createAccountKey(city,state,zip,name,street1);
						accDataMap.put(newKey, acc);
						accKeyToLicenseMap.put(newKey, licenseNumberNo);
					}
				}
				if (noAccountsList.size() > 0) {
					noExistAccList = LPI_ServiceUtility.getDuplicateRecordsService(noAccountsList);
				}
				List<String> accDetails = new List<String>();
				 
				for (Datacloud.MatchRecord rec : noExistAccList) {
					accountIdSet.add(rec.getRecord().Id);
					System.Address billingAdd = (System.Address) noExistAccList[0].getRecord().get('BillingAddress');
                    String key = createAccountKey(
                    	billingAdd.getCity(),
						billingAdd.getState(),
						billingAdd.getPostalCode(),
						(String) rec.getRecord().get('Name'),
						billingAdd.getStreet()
                    );
					accDataMap.remove(key);
				}
				newAccList = accDataMap.values();
				if (!newAccList.isEmpty()) {
					 
					newAccList = (List<Account>) LPI_WithoutSharingUtility.upsertSObjectList(newAccList);
                }

				for (Account acc : newAccList) {
					accountIdSet.add(acc.Id);
				}
				 
                String accFields = 'Name,Id,BillingStreet,BillingStateCode,BillingCity,BillingPostalCode';
				whereClause = 'Id IN' + LPI_ServiceUtility.getStringValuesBySet(accountIdSet);
                LPI_AccountDAO.LPI_AccountWithoutSharingDAO obj = new LPI_AccountDAO.LPI_AccountWithoutSharingDAO();
				if (accountIdSet.size() > 0) {
					for (
						Account allAcc : obj.getAccountByDymanicQuery(accFields, whereClause, null, null, null)
					) {
                        String key = createAccountKey(
							allAcc.BillingCity,
							allAcc.BillingStateCode,
							allAcc.BillingPostalCode,
							allAcc.Name, 
							allAcc.BillingStreet);
						if (accKeyToLicenseMap.containsKey(key)) {
							bLNumberAccIdsMap.put(allAcc.Id, accKeyToLicenseMap.get(key));
						}
					}
				}

				 
				existingAcrList = queryBusinessContactRelation(
					userAccId,
					LPI_ServiceUtility.getStringValuesBySet(accountIdSet)
				);
				for (Business_Relationships__c acr : existingAcrList) {
					existingAcrCheckList.add(acr.Related_From__c);
					existingAcrCheckList.add(acr.Related_To__c);
				}

				Business_Relationships__c accConRelation = new Business_Relationships__c();
				for (Id accId : accountIdSet) {
					if (existingAcrList.size() == 0 || !existingAcrCheckList.contains(accId)) {
						String LicenseNo = bLNumberAccIdsMap.get(accId) != 'null' ? bLNumberAccIdsMap.get(accId) : '';
						accConRelation = createBusinessRelationship(
							null,
							userAccId,
							accId,
							false,
							'Pending',
							LicenseNo,
							true,
							null
						);
						acrList.add(accConRelation);
					}
				}
				if (!acrList.isEmpty()) {
					LPI_DML.doInsert(acrList);
				}
				if (!existingAcrList.isEmpty()) {
					for (Business_Relationships__c acr : existingAcrList) {
						String LicenseNo;
						if (acr.Related_From__c == userAccId) {
							LicenseNo = bLNumberAccIdsMap.get(acr.Related_To__c) != 'null'
								? bLNumberAccIdsMap.get(acr.Related_To__c)
								: '';
						} else {
							LicenseNo = bLNumberAccIdsMap.get(acr.Related_From__c) != 'null'
								? bLNumberAccIdsMap.get(acr.Related_From__c)
								: '';
						}
						accConRelation = createBusinessRelationship(
							acr.Id,
							null,
							null,
							null,
							null,
							LicenseNo,
							acrIdIsRelationCheckMap.get(acr.Id),
							null
						);
                        if(acr.Related_From__c != userAccId){
                            acrNoUpdateList.add(accConRelation);
                        }
					}
				}
				 
				for (String acrId : acrIdIsRelationCheckMap.keySet()) {
					accConRelation = createBusinessRelationship(
						acrId,
						null,
						null,
						null,
						null,
						null,
						acrIdIsRelationCheckMap.get(acrId),
						null
					);
					acrNoUpdateList.add(accConRelation);
				}

				if (!acrNoUpdateList.isEmpty()) {
					LPI_DML.doUpdate(acrNoUpdateList);
				}
			}
		} catch (Exception exp) {
			LPI_ExceptionManager.logException(
				'LPI_PreneedBusinessInformation',
				'savePreneedBusinessInformation',
				exp
			);
		}
	}
	/**
	 * @author : MTX Group Product Team
	 * @description This method is used to fetch all Preneed Seller/Provider Business Informations
	 * @param inputMap fetching all the input from Omniscript
	 * @param outMap Passing value to Omniscript
	 *@since 8 Jan 2022
	 */
	public static void fetchPreneedBusinessInformation(Map<String, Object> inputMap, Map<String, Object> outMap, Boolean isCalledFromPDF) {
		try {
			String parId = (String) inputMap.get('parid');
			Set<Id> acrAccIds = new Set<Id>();
			Map<String, String> accountToBusinessMap = new Map<String, String>();
			Map<String, Account> businessToAccountMap = new Map<String, Account>();
			Map<String, String> accountKeyToIdMap = new Map<String, String>();
			List<Map<String, Object>> preneedSellerReviewList = new List<Map<String, Object>>();
            List<Business_Relationships__c> bussRelations = new List<Business_Relationships__c>();
			integer noOfbranch = 0;
			Id parConId;
			String fields;
			String whereClause;
            String licenseType;
            String preneedLabel;
			if (String.isNotBlank(parId)) {
				fields = 'BusinessAccountNameId,Regulatory_Authorization_Type__r.Name';
				whereClause = 'Id =\'' + String.escapeSingleQuotes(parId) + '\'';
				List<PreliminaryApplicationRef> par = LPI_PreliminaryApplicationRefDAO.getPreliminaryApplicationRefByDymanicQuery(
					fields,
					whereClause,
					null,
					null,
					null
				);
                if(!par.isEmpty()){
                	parConId = par[0].BusinessAccountNameId;   
                }
                licenseType = par[0].Regulatory_Authorization_Type__r.Name;
			}
         
			fields = 'Id,Related_To__c,Related_From__c,Is_Licensed_Entity__c,Entity_License_Number__c,IsActive__c,If_Relationship_is_Associated_with_you__c, Related_From_License_Number__r.License_Number_With_Rat_Name__c,Related_From_License_Number__r.Business_Entity_Name__c,Related_From_License_Number__r.Name';
			if (parConId != null) {
				whereClause =
					'(Related_To__c =\'' +
					String.escapeSingleQuotes(parConId) +
					'\'OR Related_From__c =\'' +
					String.escapeSingleQuotes(parConId) +
					'\''+') AND Roles__c = \''+PRENEED_BUSS_ROLE+'\' AND ((IsActive__c = FALSE AND EndDate__c = NULL)  OR IsActive__c = TRUE)';
				for (
					Business_Relationships__c br : LPI_BusinessRelationshipDAO.fetchBusinessRelationshipRecords(
						fields,
						whereClause
					)
                ){
                    bussRelations.add(br);
                    if (br.Related_To__c == parConId) {
						accountToBusinessMap.put(br.Related_From__c, br.Id);
					} else {
						accountToBusinessMap.put(br.Related_To__c, br.Id);
					}
                } 
                if(!bussRelations.isEmpty() && !isCalledFromPDF){
                    List<Id> lstRelationshipIds = new List<Id>(new Map<Id, Business_Relationships__c>(bussRelations).keySet());
                    if(String.isNotBlank(parId)){
                        PreliminaryApplicationRef par = new PreliminaryApplicationRef();
                        par.Id = parId;
                        par.Preneed_Relationship_Ids__c = String.join(lstRelationshipIds, ',');
                        LPI_DML.doUpdate(par);
                    }
                }
            }
             
			Set<String> accountIdSet = new Set<String>();
			accountIdSet = accountToBusinessMap.keySet();
            String accFields = 'Name,Id,BillingStreet,BillingStateCode,BillingCity,BillingPostalCode,BillingState,Other_State__c';
			String accIdSet = LPI_ServiceUtility.getStringValuesByList(new List<String>(accountIdSet));
			List<Account> accList = new List<Account>();
			if (String.isNotEmpty(accIdSet)) {
				whereClause = 'Id IN' + accIdSet;
                LPI_AccountDAO.LPI_AccountWithoutSharingDAO obj = new LPI_AccountDAO.LPI_AccountWithoutSharingDAO();
				accList = obj.getAccountByDymanicQuery(accFields, whereClause, null, null, null);

			}
			for (Account acc : accList) {
				String brId = accountToBusinessMap.get(acc.Id);
				businessToAccountMap.put(brId, acc);
			}
   
			for (Business_Relationships__c acr : bussRelations) {
				Map<String, Object> preneedSellerReviewMap = new Map<String, Object>();
				Map<String, Object> preneedSellerYesBLK = new Map<String, Object>();
				noOfbranch = noOfbranch + 1;
                preneedLabel = licenseType == 'Preneed Seller' ? 'Preneed Provider ' : 'Preneed Seller Information ';
				preneedSellerReviewMap.put('BranchNum', preneedLabel + String.ValueOf(noOfbranch));
				Account accDetails = businessToAccountMap.get(acr.Id);
				String getAccountId = accDetails.id;
                
             	boolean isRelated = acr.Related_From__c == parConId ? true : false;
				 
				if (acr.IsActive__c == false || isRelated== false) {
					if (acr.Is_Licensed_Entity__c == 'Yes') {
						preneedSellerYesBLK.put('SalesPersonStreetAddress', accDetails.BillingStreet);
						preneedSellerYesBLK.put('SalesPersonLicenseNumber', acr.Related_From_License_Number__r.Name == acr.Entity_License_Number__c ? acr.Related_From_License_Number__r.License_Number_With_Rat_Name__c : acr.Related_From_License_Number__r.Business_Entity_Name__c);
						preneedSellerYesBLK.put('SalesPersonNameOfCorporation', accDetails.Name);
						preneedSellerYesBLK.put('SalesPersonCity', accDetails.BillingCity);
                        preneedSellerYesBLK.put(
								'SalesPersonState',
								accDetails.BillingState != null
									? accDetails.BillingState
									: accDetails.Other_State__c
							);
						preneedSellerYesBLK.put('SalesPersonZipcode', accDetails.BillingPostalCode);
						preneedSellerReviewMap.put(
							'EFDApplicationPreneedSellerInformationIsThePreneed',
							acr.Is_Licensed_Entity__c
						);
						preneedSellerReviewMap.put('SalesPersonLicenseNumber-Block', preneedSellerYesBLK);
						 
						preneedSellerReviewMap.put('SalesPersonStreetAddress', accDetails.BillingStreet);
						preneedSellerReviewMap.put('OldLicenseNumber', acr.Entity_License_Number__c);
						preneedSellerReviewMap.put('SalesPersonLicenseNumber', acr.Related_From_License_Number__r.Name == acr.Entity_License_Number__c ? acr.Related_From_License_Number__r.License_Number_With_Rat_Name__c : acr.Related_From_License_Number__r.Business_Entity_Name__c);
						preneedSellerReviewMap.put('Name', acr.Entity_License_Number__c);
						preneedSellerReviewMap.put('SalesPersonNameOfCorporation', accDetails.Name);
						preneedSellerReviewMap.put('SalesPersonCity', accDetails.BillingCity);
						preneedSellerReviewMap.put('SalesPersonZipcode', accDetails.BillingPostalCode);
                        preneedSellerReviewMap.put(
								'SalesPersonState',
								accDetails.BillingState != null
									? accDetails.BillingState
									: accDetails.Other_State__c
							);
					} else {
						preneedSellerReviewMap.put(
							'EFDApplicationPreneedSellerInformationIsThePreneed',
							acr.Is_Licensed_Entity__c
						);
						preneedSellerReviewMap.put(
							'EFDApplicationPreneedSellerInformationStreet1',
							accDetails.BillingStreet
						);
						preneedSellerReviewMap.put(
							'EFDApplicationPreneedSellerInformationLicenseNumber',
							acr.Entity_License_Number__c
						);
						preneedSellerReviewMap.put('EFDApplicationPreneedSellerInformationName', accDetails.Name);
						preneedSellerReviewMap.put(
							'EFDApplicationPreneedSellerInformationCity',
							accDetails.BillingCity
						);
						preneedSellerReviewMap.put(
							'EFDApplicationPreneedSellerInformationState',
							accDetails.BillingStateCode
						);
						preneedSellerReviewMap.put(
							'EFDApplicationPreneedSellerInformationZip',
							accDetails.BillingPostalCode
						);
                        preneedSellerReviewMap.put(
							'EFDApplicationPreneedSellerInformationStateReview',
							 accDetails.BillingState
							);
						preneedSellerReviewMap.put('newAccId', getAccountId);
					}
					preneedSellerReviewMap.put('OldEntityResponse', acr.Is_Licensed_Entity__c);
				}
				if (acr.IsActive__c == true || isRelated == true) {
					preneedSellerReviewMap.put(
						'EFDApplicationPreneedSellerInformationIsThePreneedRead',
						acr.Is_Licensed_Entity__c
					);
					preneedSellerReviewMap.put(
						'EFDApplicationPreneedSellerInformationStreet1Read',
						accDetails.BillingStreet
					);
					preneedSellerReviewMap.put(
						'EFDApplicationPreneedSellerInformationLicenseNumberRead',
						acr.Entity_License_Number__c
					);
					preneedSellerReviewMap.put('EFDApplicationPreneedSellerInformationNameRead', accDetails.Name);
					preneedSellerReviewMap.put(
						'EFDApplicationPreneedSellerInformationCityRead',
						accDetails.BillingCity
					);
					preneedSellerReviewMap.put(
						'EFDApplicationPreneedSellerInformationStateRead',
						accDetails.BillingState
					);
					preneedSellerReviewMap.put(
						'EFDApplicationPreneedSellerInformationZipRead',
						accDetails.BillingPostalCode
					);
				}
				preneedSellerReviewMap.put(
					'EFDApplicationPreneedSellerInformationRelationshipForYou',
					acr.If_Relationship_is_Associated_with_you__c
				);
                preneedSellerReviewMap.put('IsRelatedFrom', isRelated);
				preneedSellerReviewMap.put('IsActive', acr.IsActive__c);
				preneedSellerReviewMap.put('blockAcrId', acr.Id);
				preneedSellerReviewList.add(preneedSellerReviewMap);
			}
			outMap.put('EFDApplicationPreneedSellerInformationBlock', preneedSellerReviewList);
		} catch (Exception exp) {
			LPI_ExceptionManager.logException(
				'LPI_PreneedBusinessInformation',
				'fetchPreneedBusinessInformation',
				exp
			);
		}
	}
	/**
	 * @author : MTX Group Product Team
	 * @description This method is used to delete Preneed Seller/Provider Business Informations
	 * @param inputMap fetching all the input from Omniscript
	 * @param outMap Passing value to Omniscript
	 *@since 8 Jan 2022
	 */
	public static void deletePreneedBusinessInformation(Map<String, Object> inputMap, Map<String, Object> outMap) {
		try {
			String parId = (String) inputMap.get('parid');
			List<Business_Relationships__c> deleteAcrIdsSet = new List<Business_Relationships__c>();
			List<Account> deleteNoAccIdsSet = new List<Account>();
			Set<Id> parConIds = new Set<Id>();
			Set<Id> acrAccIds = new Set<Id>();
			Id parAccId;
			String fields;
			String whereClause;
			Map<String, object> preneedSellerInformationStepInfo = (Map<String, object>) inputMap.get(
				'EFDApplicationPreneedSellerInformationStep'
			);
			List<String> acrIdsFromOsList = (List<String>) JSON.deserialize(
				JSON.serialize(
					preneedSellerInformationStepInfo.get('EFDApplicationPreneedSellerInformationAcrIdsFormula')
				),
				List<String>.class
			);
			if (String.isNotBlank(parId)) {
				fields = 'BusinessAccountNameId';
				whereClause = 'Id =\'' + String.escapeSingleQuotes(parId) + '\'';
				List<PreliminaryApplicationRef> par = LPI_PreliminaryApplicationRefDAO.getPreliminaryApplicationRefByDymanicQuery(
					fields,
					whereClause,
					null,
					null,
					null
				);
                if(!par.isEmpty()){
                	parAccId = par[0].BusinessAccountNameId;   
                }
			}

			fields = 'ID, Related_To__c, Related_From__c,IsActive__c,Is_Licensed_Entity__c';
			if (parAccId != null) {
				whereClause =
					'(Related_To__c =\'' +
					String.escapeSingleQuotes(parAccId) +
					'\'' +
					')AND IsActive__c = FALSE AND Roles__c = \''+ PRENEED_BUSS_ROLE+'\'';
				for (
					Business_Relationships__c acr : LPI_BusinessRelationshipDAO.fetchBusinessRelationshipRecords(
						fields,
						whereClause
					)
				) {
					if (
						acrIdsFromOsList == null || (!acrIdsFromOsList.isEmpty() && !acrIdsFromOsList.contains(acr.Id))
					) {
						deleteAcrIdsSet.add(acr);
					}
				}
				whereClause =
					'Related_To__c =\'' +
					String.escapeSingleQuotes(parAccId) +
					'\'' +
					' AND IsActive__c = FALSE AND Roles__c = \''+ PRENEED_BUSS_ROLE+'\'';
				for (
					Business_Relationships__c acrRec : LPI_BusinessRelationshipDAO.fetchBusinessRelationshipRecords(
						fields,
						whereClause
					)
				) {
					if (
						acrIdsFromOsList == null ||
						(!acrIdsFromOsList.isEmpty() && !acrIdsFromOsList.contains(acrRec.Id))
					) {
						if (acrRec.Is_Licensed_Entity__c == 'Pending') { 
                            if(acrRec.Related_From__c!=null){
                            	deleteNoAccIdsSet.add(new Account(id=acrRec.Related_From__c));   
                            }
						}
					}
				}
			}

			if (!deleteAcrIdsSet.isEmpty()) {
				LPI_WithoutSharingUtility.deleteSObject(deleteAcrIdsSet);
			}
			if (!deleteNoAccIdsSet.isEmpty()) {
				LPI_WithoutSharingUtility.deleteSObject(deleteNoAccIdsSet);
			}
		} catch (Exception exp) {
			LPI_ExceptionManager.logException(
				'LPI_PreneedBusinessInformation',
				'deletePreneedBusinessInformation',
				exp
			);
		}
	}

	/**
	 * @author 					   : MTX Group Product Team
	 * @param accountId            : Account Id
	 * @return  				   :`list<Business_Relationships__c>`
	 * @description                : Fetching ACR on the basis of different filter
	 * @last modified by           : MTX Group Product Team
	 * @last modified date         : 23 feb 2023
	 * @modified details           :
	 */
	public static list<Business_Relationships__c> queryBusinessContactRelation(String userAccId, String accIds) {
		List<Business_Relationships__c> existBusinessRelations = new List<Business_Relationships__c>();
        try{
            String fields, whereClause;
            fields = 'Id,Related_To__c,Related_From__c';
            if (String.isNotEmpty(accIds) && String.isNotEmpty(userAccId)) {
                whereClause =
                    '((Related_To__c IN' +
                    accIds +
                    ' AND  Related_From__c = \'' +
                    String.escapeSingleQuotes(userAccId) +
                    '\'' +
                    ')OR (Related_To__c =\'' +
                    String.escapeSingleQuotes(userAccId) +
                    '\'' +
                    ' AND  Related_From__c IN' +
                    accIds +
                    '))AND Roles__c = \''+PRENEED_BUSS_ROLE+'\' AND ((IsActive__c = FALSE AND EndDate__c = NULL) OR IsActive__c = TRUE)';
                existBusinessRelations = LPI_BusinessRelationshipDAO.fetchBusinessRelationshipRecords(
                    fields,
                    whereClause
                );
            }
        }catch(Exception exp){
            LPI_ExceptionManager.logException('LPI_PreneedBusinessInformation','deletePreneedBusinessInformation',exp);
        }
		return existBusinessRelations;
	}
	/**
	 * @author 					   : Sarabjeet singh
	 * @param accountId            : Account Id
	 * @return  				   :`Business_Relationships__c`
	 * @description                : Creating Bussiness Relationship record
	 * @last modified by           : MTX Group Inc
	 * @last modified date         : 23 feb 2023
	 * @modified details           :
	 */
	public static Business_Relationships__c createBusinessRelationship(
		String id,
		String relatedToId,
		String relatedFromId,
		boolean isActive,
		String isLicensedEntity,
		String licenseNumber,
		boolean relationshipAssociatedWithYou,
		Id businessLicenseId
	) {
		Business_Relationships__c businessRelation = new Business_Relationships__c();
		try {
			if (String.isNotEmpty(id)) {
				businessRelation.Id = id;
			}
			if (String.isNotEmpty(relatedToId)) {
				businessRelation.Related_To__c = relatedToId;
			}
			if (String.isNotEmpty(relatedFromId)) {
				businessRelation.Related_From__c = relatedFromId;
			}
			if (isActive != null) {
				businessRelation.IsActive__c = isActive;
			}
			if (String.isNotEmpty(isLicensedEntity)) {
				businessRelation.Is_Licensed_Entity__c = isLicensedEntity;
			}
			if (String.isNotEmpty(licenseNumber)) {
				businessRelation.Entity_License_Number__c = licenseNumber;
			}
			if (relationshipAssociatedWithYou != null) {
				businessRelation.If_Relationship_is_Associated_with_you__c = relationshipAssociatedWithYou;
			}
			if( businessLicenseId != null ){
				businessRelation.Related_From_License_Number__c = businessLicenseId;
			}
            businessRelation.Roles__c= PRENEED_BUSS_ROLE;
		} catch (Exception e) {
			LPI_ExceptionManager.logException('LPI_PreneedBusinessInformation','createBusinessRelationship', e);
		}
		return businessRelation;
	}

	public class preneedSellerInfoWrapper {
		public String ApplicationLicenseNumber;
		public String EFDApplicationPreneedSellerInformationIsThePreneed;
		public String EFDApplicationPreneedSellerInformationLicenseNumber;
		public String EFDApplicationPreneedSellerInformationName;
		public String EFDApplicationPreneedSellerInformationStreet1;
		public String EFDApplicationPreneedSellerInformationCity;
		public String EFDApplicationPreneedSellerInformationState;
		public String EFDApplicationPreneedSellerInformationZip;
		public Boolean IsActive;
        public Boolean IsRelatedFrom;
		public Boolean EFDApplicationPreneedSellerInformationRelationshipForYou;
		public Id blockAcrId;
		public Id newAccountId;
		public Id selectedBusinessLicenseId;
		public Boolean isLicenseEntityName;
		public String LicenseNumEntityName;
	}

	public static String createAccountKey(String city, String state, String zip, String name, String street) {
		String key;
		try {
			key = city + ':' + state + ':' + zip + ':' + name + ':' + street;
		} catch (Exception exp) {
			LPI_ExceptionManager.logException('LPI_PreneedSellerInformationController', 'createAccountKey', exp);
		}
		return key;
	}
}