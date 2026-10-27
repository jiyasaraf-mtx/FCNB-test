/** 
 * @author          : MTX Group Product Team
 * @Description     : This class fetch the Address details on the basis of Location Type
 */
global with sharing class LPI_FetchResidenceAddress implements Callable {
	
	public final static String FETCH_RESIDENCE_ADDRESS = 'fetchResidenceAddress';
	public final static String FETCH_RESIDENCE_MAILING_ADDRESS_FROM_BUSINESS_LICENSE = 'fetchResidenceMailingAddressFromBusinessLicense';
	
	public final static String RESIDENCE = 'Residence';
	public final static String MAILING = 'Mailing';
	public final static String CLASS_NAME = 'LPI_FetchResidenceAddress';
	public final static String INVOKE_METHOD = 'InvokeMethod';
	public final static String APPROVED_STATUS = 'Approved';
	public final static String OPEN = 'Open';

	/**
	 * @author                      : MTX Group Product Team
	 * @since                       :
	 * @description                 : This method calls invoke method
	 * @param action                : String
	 * @param args			        : Map<String, Object>
	 * @return                      : Object
	 * @last modified by            : MTX Group Product Team
	 * @last modified date          :
	 * @modified details            :
	 */
	global Object call(String action, Map<String, Object> args) {
		Map<String, Object> input = (Map<String, Object>) args.get('input');
		Map<String, Object> output = (Map<String, Object>) args.get('output');
		Map<String, Object> options = (Map<String, Object>) args.get('options');
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
	 * @return  `Boolean`
	 */
	private Boolean invokeMethod(
		String methodName,
		Map<String, Object> inputMap,
		Map<String, Object> outMap,
		Map<String, Object> options
	) {
		try {
			if (methodName == FETCH_RESIDENCE_ADDRESS) {
				fetchResidenceAddress(inputMap, outMap);
			} else if (methodName == FETCH_RESIDENCE_MAILING_ADDRESS_FROM_BUSINESS_LICENSE) {
				fetchResidenceMailingAddressFromBusinessLicense(inputMap, outMap);
			} 
		} catch (Exception e) {
			LPI_ExceptionManager.logException(CLASS_NAME, INVOKE_METHOD, e);
			throw new LPI_Exception('There is some problem in Fetching Address Details', e);
		}

		return true;
	}

	/**
	 * @author               		: MTX Group Product Team
	 * @description       	 		: This method is used to fetch all the fields of Residence address and Mailing address present under PAR record
     * @param inputMap              : Input data passed from OmniScript
     * @param outMap                : Output data passed to OmniScript
	 * @return                      : `void`
	 * @last modified by     		: MTX Group Product Team
	 * @last modified date   		: March 4, 2024
	 * @modified details     		: Code Beautification for better understanding
	 */
	public static void fetchResidenceAddress(Map<String, Object> inputMap, Map<String, Object> outMap) {
		try {
			 
			String fields;
			String whereClause;
			PreliminaryApplicationRef par;
			String parId = (String) inputMap.get('parid');
			String type = (String) inputMap.get('type');
			String subType = (String) inputMap.get('amendmentType');
			String boardName = (String) inputMap.get('boardName');
			if (type == 'Amendment' && subType == 'Change of Residence and/or Mailing Address') {
				fetchResidenceAddressFromBusinessLicense(inputMap, outMap);
			}
			Map<Id, Id> locationIds = new Map<Id, Id>();
			 
			fields = 'Id, Amendment_Type__c, Type__c, Consent_for_Primary_Contact_Address__c, Approval_Supervisors_AcrIds__c, '
						+ 'Is_Supervisor_User__c, Regulatory_Authorization_Type__r.Name, Primary_Contact_Address__c, License_Address__c, '
						+ 'BusinessAccountName.IsMailingAddress_same_as_current_Address__c, Publicly_Displayed_Address__c, Board_Name__c';
			whereClause = 'Id = \'' + String.escapeSingleQuotes(parId) + '\'';
			List<PreliminaryApplicationRef> parList = LPI_PreliminaryApplicationRefDAO.getPreliminaryApplicationRefByDymanicQuery(
																								fields, whereClause, null, null, null);
			if (!parList.isEmpty()) {
				String primaryContactAddress = parList[0].Primary_Contact_Address__c;
				String licenseAddress = parList[0].License_Address__c;
				String publicDisplayedAddress = parList[0].Publicly_Displayed_Address__c;
				Boolean consentCheckboxForPIStep = parList[0].Consent_for_Primary_Contact_Address__c;
				Boolean isSupervisorUser = false;
				String approvalSupervisorIds;
				 
				isSupervisorUser = parList[0].Is_Supervisor_User__c;
				approvalSupervisorIds = parList[0].Approval_Supervisors_AcrIds__c;
				outMap.put('parType', parList[0].Type__c);
				outMap.put('parAmendmentType', parList[0].Amendment_Type__c);
				outMap.put('ConsentForPrimaryContactAddress', parList[0].Consent_for_Primary_Contact_Address__c);
				outMap.put('regAuthTypeName', parList[0].Regulatory_Authorization_Type__r.Name);
				outMap.put('BoardName', parList[0].Board_Name__c);
				outMap.put('MailingAddressIsSameAsMyCurrentAddress', 
								parList[0].BusinessAccountName.IsMailingAddress_same_as_current_Address__c);
				 
				fields = 'Id, Location__c';
				whereClause = 'Preliminary_Application_Reference__c = \'' + String.escapeSingleQuotes(parId) + '\'';
				List<Temp_AuthApplicationPlace__c> temp_AAPList;
				if (isSupervisorUser && approvalSupervisorIds != null) {
					LPI_TempAuthApplicationPlaceDAO.LPI_TempAuthApplicationPlaceWithoutSharingDAO withoutSharingQuery = 
									new LPI_TempAuthApplicationPlaceDAO.LPI_TempAuthApplicationPlaceWithoutSharingDAO();
					temp_AAPList = withoutSharingQuery.getTempAuthApplicationPlaceByDymanicQuery(fields, whereClause, null, null, null);
				}
				else {
					temp_AAPList = LPI_TempAuthApplicationPlaceDAO.getTempAuthApplicationPlaceByDymanicQuery(fields, whereClause, null, null, null);
				}
				for (Temp_AuthApplicationPlace__c temp_AAP : temp_AAPList) {
					locationIds.put(temp_AAP.Location__c, temp_AAP.Id);
				}
				 
				if (!locationIds.keySet().isEmpty()) {
					List<Schema.Address> addresses;
					fields = 'Id, ParentId, Parent.LocationType, Parent.Name, StateCode, Business_State__c, CountryCode, City, County__c, '
								+ 'PostalCode, State, Street, Country';
					whereClause = 'ParentId IN ' + LPI_ServiceUtility.getStringValuesBySet(locationIds.keySet());
					LPI_AddressDAO.LPI_AddressDAOWithoutSharing sharingObj = new LPI_AddressDAO.LPI_AddressDAOWithoutSharing();
					addresses = sharingObj.getAddressByDymanicQuery(fields, whereClause, null, null, null);
					 
					if (String.isNotBlank(licenseAddress)) {
						outMap.put('AddressTypeLA', licenseAddress);
					}
					if (String.isNotBlank(primaryContactAddress)) {
						outMap.put('AddressTypePCA', primaryContactAddress);
					}
					if (String.isNotBlank(publicDisplayedAddress)) {
						outMap.put('AddressTypePDA', publicDisplayedAddress);
					}
					if (consentCheckboxForPIStep != null) {
						outMap.put('ConsentCheckboxForPIStep', consentCheckboxForPIStep);
					}
					for (Schema.Address address : addresses) {
						if (address.Parent.LocationType == RESIDENCE) {
							outMap.put('residence_Temp_AAP_Id', locationIds.get(address.ParentId));
							outMap.put('residenceLocationId', address.ParentId);
							outMap.put('residenceAddressId', address.Id);
							outMap.put('StreetAddress', address.Street);
							outMap.put('ResCountry', address.CountryCode);
							outMap.put('ResCountryAmendment', address.CountryCode);
							outMap.put('ReviewCountry', address.Country);
							if (address.CountryCode == 'US') {
								outMap.put('State', address.StateCode);
								outMap.put('statePicklistEdit', address.StateCode);
								outMap.put('StateTextReadOnlyForUs', address.StateCode);
								 
									outMap.put('ReviewState', address.State);
								 
								outMap.put('StateAmendment', address.StateCode);
							} 
							else {
								outMap.put('StateTextReadOnly', address.Business_State__c);
								outMap.put('StateTextEdit', address.Business_State__c);
								outMap.put('StateText', address.Business_State__c);
								outMap.put('StateTextReadOnlyForNonUs', address.Business_State__c);
								outMap.put('ReviewState', address.Business_State__c);
							}
							outMap.put('City', address.City);
							outMap.put('StreetAddress', address.Street);
							outMap.put('ZipCode', address.PostalCode);
							outMap.put('County', address.County__c);
							outMap.put('StreetAddressEdit', address.Street);
						} 
						else if (address.Parent.LocationType == MAILING ) {
							outMap.put('mailing_Temp_AAP_Id', locationIds.get(address.ParentId));
							outMap.put('MailinglocationId', address.ParentId);
							outMap.put('MailingaddressId', address.Id);
							outMap.put('MailingCountry', address.CountryCode);
							outMap.put('ReviewMailingCountry', address.Country);
							if (address.CountryCode == 'US') {
								outMap.put('MailingState', address.StateCode);
								outMap.put('MailingStateRO', address.StateCode);
								 
									outMap.put('ReviewMailingState', address.State);
								 
							} 
							else {
								outMap.put('MailingStateText', address.Business_State__c);
								outMap.put('MailingStateTextRO', address.Business_State__c);
								outMap.put('MailingStateROText', address.Business_State__c);
								outMap.put('ReviewMailingState', address.Business_State__c);
							}
							outMap.put('MailingCity', address.City);
							outMap.put('MailingStreet', address.Street);
							outMap.put('MailingStreetRO', address.Street);
							outMap.put('MailingZipCode', address.PostalCode);
							outMap.put('MailingCountryRO', address.CountryCode);
							outMap.put('MailingCityRO', address.City);
							outMap.put('MailingZipCodeRO', address.PostalCode);
							outMap.put('MailingCounty', address.County__c);
						}
						if (address.Parent.LocationType == 'Business Address' || address.Parent.LocationType == 'Branch' ||
							address.Parent.LocationType == 'Secondary Business Address' || 
							address.Parent.LocationType == 'Local Address' || address.Parent.LocationType == 'Other') {
							if (address.Parent.LocationType == primaryContactAddress) {
								outMap.put('PCACountry', address.CountryCode);
								outMap.put('ReviewPCACountry', address.Country);
								if (address.CountryCode == 'US') {
									outMap.put('PCAState', address.StateCode);
									outMap.put('PCAStateRO', address.StateCode);
								} 
								else {
									outMap.put('PCAStateText', address.Business_State__c);
									outMap.put('PCAStateTextRO', address.Business_State__c);
								}
								outMap.put('PCACity', address.City);
								outMap.put('PCACityRO', address.City);
								outMap.put('PCAStreetAddress', address.Street);
								outMap.put('PCAStreetAddressRO', address.Street);
								outMap.put('PCAZipCode', address.PostalCode);
								outMap.put('PCAZipCodeRO', address.PostalCode);
								outMap.put('PCACountryRO', address.CountryCode);
								outMap.put('PCACounty', address.County__c);
							} 
							else if (address.Parent.LocationType == licenseAddress) {
								outMap.put('LACountry', address.CountryCode);
								outMap.put('ReviewLaCountry', address.Country);
								if (address.CountryCode == 'US') {
									outMap.put('LAState', address.StateCode);
									outMap.put('LAStateRO', address.StateCode);
								} 
								else {
									outMap.put('LAStateText', address.Business_State__c);
									outMap.put('LAStateTextRO', address.Business_State__c);
								}
								outMap.put('LACity', address.City);
								outMap.put('LACityRO', address.City);
								outMap.put('LAStreetAddress', address.Street);
								outMap.put('LAStreetAddressRO', address.Street);
								outMap.put('LAZipCode', address.PostalCode);
								outMap.put('LAZipCodeRO', address.PostalCode);
								outMap.put('LACountryRO', address.CountryCode);
								outMap.put('LACounty', address.County__c);
							}
							else if (address.Parent.LocationType == publicDisplayedAddress) {
								outMap.put('PDA_AAP_Id', locationIds.get(address.ParentId));
								outMap.put('pdaLocationId', address.ParentId);
								outMap.put('pdaAddressId', address.Id);
								outMap.put('PDACountry', address.CountryCode);
								outMap.put('ReviewPDACountry', address.Country);
								if (address.CountryCode == 'US') {
									outMap.put('PDAState', address.StateCode);
									outMap.put('PDAStateRO', address.StateCode);
								} 
								else {
									outMap.put('PDAStateText', address.Business_State__c);
									outMap.put('PDAStateTextRO', address.Business_State__c);
								}
								outMap.put('PDACity', address.City);
								outMap.put('PDACityRO', address.City);
								outMap.put('PDAStreetAddress', address.Street);
								outMap.put('PDAStreetAddressRO', address.Street);
								outMap.put('PDAZipCode', address.PostalCode);
								outMap.put('PDAZipCodeRO', address.PostalCode);
								outMap.put('PDACountryRO', address.CountryCode);
								outMap.put('PDACounty', address.County__c);
							}
						}
					}
					 
				}
			}
		} 
		catch (Exception e) {
			LPI_ExceptionManager.logException(CLASS_NAME, FETCH_RESIDENCE_ADDRESS, e);
			throw new LPI_Exception('Facing Issue in Fetching Address Details', e);
		}
	}

	

	/**
	 * @author               : MTX Group Product Team
	 * @description          : This method is used to fetch Residence address from business license and create tempAuthAppPlace record for PAR
	 * @param inputMap       : Input Parameter Passed from Omniscript
	 * @param outMap         : Output Passed to Omniscript
	 * @last modified by     : MTX Group Product Team
	 * @last modified date   :
	 * @modified details     :
	 */
	public static void fetchResidenceMailingAddressFromBusinessLicense(Map<String, Object> inputMap, Map<String, Object> outMap) {
		String blId = (String) inputMap.get('blId');
		String parId = (String) inputMap.get('parid');
		Set<Id> locationIdSet = new Set<Id>();
		String fields;
		String whereClause;
		 
		if (String.isNotBlank(blId)) {
			fields = 'Id, AuthorizationId, PlaceId';

			whereClause = 'AuthorizationId = \'' + String.escapeSingleQuotes(blId) + '\'';
            
			LPI_AuthApplicationPlaceDAO.LPI_AuthApplicationPlaceWithoutSharingDAO aapObj = new LPI_AuthApplicationPlaceDAO.LPI_AuthApplicationPlaceWithoutSharingDAO();
			for (
				AuthApplicationPlace aap : aapObj.getAuthApplicationPlaceByDymanicQuery(
					fields,
					whereClause,
					null,
					null,
					null
				)
			) {
				locationIdSet.add(aap.PlaceId);
			}
		}else{ 
			fields = 'Id , Old_Application_Id__c';
			whereClause = 'Id = \'' + String.escapeSingleQuotes(parId) + '\'';
			 
			for(
				PreliminaryApplicationRef par : LPI_PreliminaryApplicationRefDAO.getPreliminaryApplicationRefByDymanicQuery(
				fields,
				whereClause,
				null,
				null,
				null 
				)
			){
				 
				if(String.isNotBlank(par.Old_Application_Id__c)){
					fields = 'Id, RgltyAuthApplicationId, PlaceId';
					whereClause = 'RgltyAuthApplicationId = \'' + String.escapeSingleQuotes(par.Old_Application_Id__c) + '\'';
				
					for (
						AuthApplicationPlace aap : LPI_AuthApplicationPlaceDAO.getAuthApplicationPlaceByDymanicQuery(
							fields,
							whereClause,
							null,
							null,
							null
						)
					) {
						locationIdSet.add(aap.PlaceId);
					}
				}	
			}

		}
		Set<Id> openLocationIdSet = new Set<Id>();
		
		if(!locationIdSet.isEmpty()){
			for(Schema.location loc : LPI_LocationDAO.getLocationByDymanicQuery('Id','Id IN '+LPI_ServiceUtility.getStringValuesBySet(locationIdSet)+' AND Status__c = \''+OPEN+'\'',null,null,null) )
			{
				openLocationIdSet.add(loc.Id);
			}
		}


		if (!openLocationIdSet.isEmpty()) {
			
				 
				fields = 'Id, Location__c, Preliminary_Application_Reference__c';
				whereClause =
					'Location__c IN ' +
					LPI_ServiceUtility.getStringValuesBySet(openLocationIdSet) +
					'AND Preliminary_Application_Reference__c = \'' +
					String.escapeSingleQuotes(parId) +
					'\'';
					List<Temp_AuthApplicationPlace__c> existingTempAapRecords = LPI_TempAuthApplicationPlaceDAO.getTempAuthApplicationPlaceByDymanicQuery(
						fields,
						whereClause,
						null,
						null,
						null
					);
					List<Temp_AuthApplicationPlace__c> insertApp = new List<Temp_AuthApplicationPlace__c>();
					if (existingTempAapRecords.isEmpty()) {
						 
						for(Id locId : openLocationIdSet)
						{
							Temp_AuthApplicationPlace__c aap = new Temp_AuthApplicationPlace__c();
							aap.Preliminary_Application_Reference__c = parId;
							aap.Location__c = locId;
							insertApp.add(aap);
						}
						
						if(!insertApp.isEmpty())
						{
							LPI_WithoutSharingUtility.insertSObjectList(insertApp);
						}
					
				     }
			
			
		}
        
	}
	
	/**
     * @author                      : MTX Group Product Team
     * @since                       : 17th January, 2024
     * @description                 : This method will fetch the  AuthApplicationPlace , Location ,Address details of Type Residence
     *                                related to business license .
     * @param outMap		        : Map<String, Object> output map, Passing value to Omniscript
     * @return                      : List<Map<String,Object>>
     * @last modified by            : MTX Group Product Team
     * @last modified date          :
     * @modified details            :
     */
	private static void fetchResidenceAddressFromBusinessLicense(Map<String, Object> inputMap, Map<String, Object> outMap) {
        Id blId = (Id) inputMap.get('blId');
        Map<Id, Map<String, Object>> mapOfdataMap = new Map<Id, Map<String, Object>>();
        try {
            Set<Id> locationIdSet = new Set<Id>();
            String fields;
            String whereClause;
            
             
            if (String.isNotBlank(blId)) {
                fields = 'Id, AuthorizationId, PlaceId';
                whereClause =
                    'AuthorizationId = \'' +
                    String.escapeSingleQuotes(blId) +
                    '\'' ;
                 
                LPI_AuthApplicationPlaceDAO.LPI_AuthApplicationPlaceWithoutSharingDAO aapObj = new LPI_AuthApplicationPlaceDAO.LPI_AuthApplicationPlaceWithoutSharingDAO();
                for (
                    AuthApplicationPlace aap : aapObj.getAuthApplicationPlaceByDymanicQuery(
                        fields,
                        whereClause,
                        null,
                        null,
                        null
                    )
                ) {
                    locationIdSet.add(aap.PlaceId);
                }
                
                whereClause =
                    '(ParentId IN ' +
                    LPI_ServiceUtility.getStringValuesBySet(
                        locationIdSet
                    ) +
                    'AND Parent.LocationType = \'' +
                    String.escapeSingleQuotes(RESIDENCE) +
                    '\'' +
                    ' AND Parent.Status__c = \'' +
                    String.escapeSingleQuotes('Open') +
                    '\')';

                if (!locationIdSet.isEmpty()) {
                    fields = 'ID,ParentId,Parent.LocationType,Parent.Name,Business_State__c,StateCode,City,County__c,PostalCode,State,Street,Country,CountryCode';
                    LPI_AddressDAO.LPI_AddressDAOWithoutSharing addrObj = new LPI_AddressDAO.LPI_AddressDAOWithoutSharing();
                    Set<Id> mailingLocIdList = new Set<Id>();
                     
                    for (
                        Schema.Address address : addrObj.getAddressByDymanicQuery(
                            fields,
                            whereClause,
                            null,
                            null,
                            null
                        )
                    ) {
                        outMap.put('CurrentRAStreetAddress', address.Street);
                        outMap.put('CurrentRACity', address.City);
                        outMap.put('CurrentRACountry', address.CountryCode);
                        outMap.put('CurrentRACountryReview', address.Country);
                        outMap.put('CurrentRAZipCode', address.PostalCode);
						outMap.put('CurrentRACounty', address.County__c);
                        if (address.CountryCode == 'US') {
                            outMap.put('CurrentRAStateUS', address.StateCode);
                            outMap.put('CurrentRAStateUSReview', address.State);
                        }else{
                            outMap.put('CurrentRAStateNonUS', address.Business_State__c);
                        }
                    }
                }
            }
        } catch (Exception e) {
            LPI_ExceptionManager.logException(
                'LPI_ChangeOfAddress',
                'fetchResidenceAddressFromBusinessLicense',
                e
            );
        }
    }
}