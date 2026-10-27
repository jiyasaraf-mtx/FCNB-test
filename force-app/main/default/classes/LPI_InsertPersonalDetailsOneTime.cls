/**
 *
 * @author   : Saurabh singh
 * @since    : 15 nov 2022
 * @description : Inserting names like Maiden_Name__c,MiddleName,HaveYouAnotherName__c,Other_Names__c
 *                fields only one time after registration.
 * @history
 * -------------------------------------------------------------------------------------------------------
 * Version      Date                Author                  Details
 *    1         15 nov, 2022        Saurabh Singh	        Initial Developement
 * 	  2			27 Jan, 2023		Kirti Agrawal 		    Shifting Query in DAO Class
 * 	  3			06 Mar, 2023		Saurabh singh 		    Changing Query on line 112 to Without sharing
 * -------------------------------------------------------------------------------------------------------
 */
global with sharing class LPI_InsertPersonalDetailsOneTime implements Callable {
	// *************************************************** Constant *******************************************************
    public static final Set<String> APPLICABLE_IA_STATUS = new Set<String>{
        'Approved', 'License Issued', 'Rejected'
    };
    public static final String LOCATION_TYPE_RESIDENCE = 'Residence';
    public static final String LOCATION_TYPE_MAILING = 'Mailing';
	// ********************************************************************************************************************

	global Object call(String action, Map<String, Object> args) {
		Map<String, Object> input = (Map<String, Object>) args.get('input');
		Map<String, Object> output = (Map<String, Object>) args.get('output');
		Map<String, Object> options = (Map<String, Object>) args.get('options');
		return invokeMethod(action, input, output, options);
	}

	/**
	 * @author             : Saurabh singh
	 * @param methodName   : Method name
	 * @param inputMap     : Input value passed from OS
	 * @param outMap       : Output value passed from here to OS
	 * @param options      : Options value passed from os
	 * @return             : `Boolean`
	 */
	private Boolean invokeMethod(
		String methodName,
		Map<String, Object> inputMap,
		Map<String, Object> outMap,
		Map<String, Object> options
	) {
		/*if (methodName == 'insertOneTime') {
			insertOneTime(inputMap, outMap);
		} else */
        if (methodName == 'updatePersonalInformationDetails') {
			updatePersonalInformationDetails(inputMap, outMap);
		} 
        /*else if (methodName == 'sendNotificationAfterApplicationSubmission') {
			sendNotificationAfterApplicationSubmission(inputMap, outMap);
		}*/
		return true;
	}

	/**
	 * @author                      : Saurabh Singh
	 * @description                 : This Method will update account data first time on Account
	 * @param inputMap              : Input value passed from OS
	 * @param outMap                : Output value passed from here to OS
	 * @return                      : `void`
	 * @last modified by            : MTX Group Inc
	 * @last modified date          : 06 March, 2023
	 * @modified details            : change DML to Without sharing on line 112
	 */
	/*public static void insertOneTime(Map<String, Object> inputMap, Map<String, Object> outMap) {
		try {
			Map<String, object> personalInformation = (Map<String, object>) inputMap.get('PersonalInformation');
			String accountId = (String) personalInformation.get('accountId');
			String conMiddleName = (String) personalInformation.get('ConMiddleName');
			String maidenName = (String) personalInformation.get('MaidenName');
			String otherName = (String) personalInformation.get('AnotherName');
			String listAnotherNames = (String) personalInformation.get('ListOfAnotherNames');
			// check accountId is not empty
			if (String.isNotEmpty(accountId)) {
				List<Account> accToBeUpdated = new List<Account>();
				List<String> accountFieldsQueryList = new List<String>{
					'Id',
					'Maiden_Name__c',
					'MiddleName',
					'HaveYouAnotherName__c',
					'Other_Names__c'
				};
				String accountIdClause = 'Id =\'' + String.escapeSingleQuotes(accountId) + '\'';
				List<Account> accountList = LPI_AccountDAO.getAccountListByDynamicQuery(
					accountFieldsQueryList,
					accountIdClause,
					null,
					null,
					null
				);
				// Iterating on account list to update account properties.
				for (Account accData : accountList) {
					Boolean isAnyEmpty = false;
					// check account middleName is not empty
					if (String.isEmpty(accData.MiddleName)) {
						accData.MiddleName = conMiddleName;
						isAnyEmpty = true;
					}
					// check account maidenName is not empty
					if (String.isEmpty(accData.Maiden_Name__c)) {
						accData.Maiden_Name__c = maidenName;
						isAnyEmpty = true;
					}
					// check account haveYouAnotherName is not empty
					if (String.isEmpty(accData.HaveYouAnotherName__c)) {
						accData.HaveYouAnotherName__c = otherName;
						isAnyEmpty = true;
					}

					//check account otherNames is not empty
					if (String.isEmpty(accData.Other_Names__c)) {
						accData.Other_Names__c = listAnotherNames;
						isAnyEmpty = true;
					}

					//IfAnyEmpty found then add instanse to update
					if (isAnyEmpty) {
						accToBeUpdated.add(accData);
					}
				}
				// check accToBeUpdated List is not empty
				if (!accToBeUpdated.isEmpty()) {
					LPI_WithoutSharingUtility.updateSObjectRecord(accToBeUpdated); // INSUFFICIENT_ACCESS_OR_READONLY, insufficient access rights on object id
				}
			}
		} catch (exception ex) {
			LPI_ExceptionManager.logException('LPI_InsertPersonalDetailsOneTime', 'insertOneTime', ex);
			throw new LPI_Exception('Problem in updating details first time', ex);
		}
	}*/

	/**
	 * @author                      : Saurabh Singh
	 * @description                 : This Method is used to update the Personal Information details on Account and PAR
	 * @param inputMap              : Input value passed from OS
	 * @param outMap                : Output value passed from here to OS
	 * @return                      : `void`
	 * @last modified by            : MTX Group Inc
	 * @last modified date          :
	 * @modified details            :
	 */
	public static void updatePersonalInformationDetails(Map<String, Object> inputMap, Map<String, Object> outMap) {
		//try {
			System.debug('$$$$$'+inputMap);
			String parId = (String) inputMap.get('parid');
			String parType = (String) inputMap.get('parType');
			Boolean showEdit = (Boolean) inputMap.get('showEdit');
			Boolean isNameChangeAmendment = inputMap.containsKey('isNameChangeAmendment')
				? (Boolean) inputMap.get('isNameChangeAmendment')
				: false;
			Map<String, Object> personalInformation = isNameChangeAmendment
				? (Map<String, Object>) inputMap.get('PersonalInformationNameAmendment')
				: (Map<String, Object>) inputMap.get('PersonalInformation');
			Boolean formulaToCheckRAandMA = inputMap.containsKey('isNameChangeAmendment') 
				? (Boolean) personalInformation.get('FormulaToCheckRAandMAAmendment') 
				: (Boolean) inputMap.get('FormulaToCheckRAandMA');
			String listOfAnotherNamesForRenewal = (String) personalInformation.get('ListOfAnotherNamesForRenewal');
			String socialSecurityNumberEditForRenewal = isNameChangeAmendment
				? (String) inputMap.get('SocialSecurityNumberEditForRenewal')
				: (String) personalInformation.get('SocialSecurityNumberEditForRenewal');
			String socialSecurityNumberRO = (String) personalInformation.get('SocialSecurityNumberRO');
			String socialSecurityNumberROAmendment = (String) personalInformation.get('SocialSecurityNumber');
			String foreignCitizenship = (String) personalInformation.get('ForeignCitizenship');
			String foreignLanguage = (String) personalInformation.get('ForeignLanguage');
			String foreignCitizenshipReadOnly = (String) personalInformation.get('ForeignCitizenshipReadOnly');
			String foreignLanguageReadOnly = (String) personalInformation.get('ForeignLanguageReadOnly');
			String OtherRace = (String) personalInformation.get('OtherRace');
			String OtherRaceReadOnly = (String) personalInformation.get('OtherRaceReadOnly');

			// updating details on PreliminaryApplicationRef
			Map<String, String> parkeyMaping = new Map<String, String>{
				//'AnotherName' => 'HaveYouAnotherName__c',
				'ConMiddleName' => 'MiddleName__c',
				'ConsentForPrimaryContactAddress' => 'Consent_for_Primary_Contact_Address__c',
				'FirstName' => 'FirstName__c',
				'LastName' => 'LastName__c',
				'ListOfAnotherNames' => 'Other_Names__c',
				'MaidenName' => 'MaidenName__c'
			};
			PreliminaryApplicationRef par = (PreliminaryApplicationRef) LPI_VlocityUtility.createSObject(
				personalInformation,
				parkeyMaping,
				'PreliminaryApplicationRef'
			);
			par.put('Id', parId);
			if (parType.equals('Renewal')) {
				par.put('Other_Names__c', listOfAnotherNamesForRenewal);
			}
			Map<String, Object> parkey = (Map<String, Object>) personalInformation.get('ConsentBlockForAll');
			if (parkey != null && parkey.get('ConsentForPrimaryContactAddress') != null) {
				par.Consent_for_Primary_Contact_Address__c = (Boolean) parkey.get('ConsentForPrimaryContactAddress');
			}
			LPI_DML.doUpdate(par);

			// updating details on Account
			Map<String, String> acckeyMaping = new Map<String, String>{
				'Age' => 'Age__c',
				'CellPhone' => 'Phone',
				//'CitizinshipStatus' => 'Citizenship__c',
				'DateofBirth' => 'Date_of_Birth__c',
				'DriverLicenseNumber' => 'Driver_s_License_Number__c',
				'FaxNumber' => 'Fax',
				'Gender' => 'Gender__c',
				'IssuedState' => 'Issued_State__c',
				'language' => 'Language__c',
				'MotherMaidenName' => 'Mother_s_Maiden_Name__c',
				'PlaceOfBirth' => 'Place_of_Birth__c',
				'Suffix' => 'Suffix',
				'TelephoneNumber' => 'PersonHomePhone',
				'Race' => 'Race__c'
			};

			if (parType == 'New') {
				acckeyMaping.put('MailingAddressSameAsCurrentAddress', 'IsMailingAddress_same_as_current_Address__c');
			} else {
				if (formulaToCheckRAandMA == true) {
					acckeyMaping.put(
						isNameChangeAmendment ? 'MailingAddressSameAsCurrentAddressAmend' :'MailingAddressSameAsCurrentAddress',
						'IsMailingAddress_same_as_current_Address__c'
					);
				} else {
					acckeyMaping.put(
						isNameChangeAmendment ? 'MailingAddressNotSameAsCurrentAddressAmend' : 'MailingAddressNotSameAsCurrentAddress',
						'IsMailingAddress_same_as_current_Address__c'
					);
				}
			}
			List<PreliminaryApplicationRef> parList;
			Account acc = (Account) LPI_VlocityUtility.createSObject(personalInformation, acckeyMaping, 'Account');
			if (showEdit == true) {
				acc.put('Other_Citizenship__c', foreignCitizenship);
				acc.put('Other_Language__c', foreignLanguage);
				acc.put('Other_Race__c', OtherRace);
			}
			if (showEdit == false) {
				acc.put('Other_Citizenship__c', foreignCitizenshipReadOnly);
				acc.put('Other_Language__c', foreignLanguageReadOnly);
				acc.put('Other_Race__c', OtherRaceReadOnly);
			}

			if (String.isNotBlank(parId)) {
				parList = LPI_PreliminaryApplicationRefDAO.getPARRecordsByID(new Set<Id>{ parId });
				acc.put('Id', parList[0].BusinessAccountNameId);
			}
			if (parType.equals('Renewal') ) {
				acc.put('Social_Security_Number__c', socialSecurityNumberEditForRenewal);
			} else if (parType.equals('Amendment')) {
				if(socialSecurityNumberROAmendment != null)
				{
					acc.put('Social_Security_Number__c', socialSecurityNumberROAmendment);
				}else {
					acc.put('Social_Security_Number__c', socialSecurityNumberRO);	
				}
			} else {
				acc.put('Social_Security_Number__c', socialSecurityNumberRO);
			}
			System.debug('*****'+outMap);
			LPI_WithoutSharingUtility.updateSObject(acc); // INSUFFICIENT_ACCESS_OR_READONLY, insufficient access rights on object id
		/*} catch (exception e) {
			LPI_ExceptionManager.logException(
				'LPI_InsertPersonalDetailsOneTime',
				'updatePersonalInformationDetails',
				e
			);
			//throw new LPI_Exception('Problem in updating Personal Information Details', e);
		}*/
	}

	/**
	 * @author                      : Saurabh Singh
	 * @description                 : This Method is used to send the notification to board staff if Applicant changes its Address after Application Submission
	 * @param inputMap              : Input value passed from OS
	 * @param outMap                : Output value passed from here to OS
	 * @return                      : `void`
	 * @last modified by            : MTX Group Inc
	 * @last modified date          :
	 * @modified details            :
	 */
	/*public static void sendNotificationAfterApplicationSubmission(
		Map<String, Object> inputMap,
		Map<String, Object> outMap
	) {
		try {
            
			Id parId = (Id) inputMap.get('parid');
			Map<String, object> personalInformation = (Map<String, object>) inputMap.get('PersonalInformation');

			// User input residence address
			String residenceStreetAddress = (String) personalInformation.get('StreetAddress');
			String residenceCity = (String) personalInformation.get('City');
			String residenceCountry = (String) personalInformation.get('ResCountry');
			String residenceZipCode = (String) personalInformation.get('ZipCode');
			String residenceStatePicklistEdit = (String) personalInformation.get('statePicklistEdit');
			String residenceStateTextEdit = (String) personalInformation.get('StateTextEdit');

			// User input mailing address
			String mailingStreetAddress = (String) personalInformation.get('MailingStreet');
			String mailingCity = (String) personalInformation.get('MailingCity');
			String mailingCountry = (String) personalInformation.get('MailingCountry');
			String mailingZipCode = (String) personalInformation.get('MailingZipCode');
			String mailingStatePicklistEdit = (String) personalInformation.get('MailingState');
			String mailingStateTextEdit = (String) personalInformation.get('MailingStateText');

			// Now compare user entered Input from save details if there is change then send notification to IA owner
			set<Id> locationList = new Set<Id>();
			for (
				Temp_AuthApplicationPlace__c taap : LPI_TempAuthApplicationPlaceDAO.getTempAuthAppPlacesByPARId(
					new Set<Id>{ parId }
				)
			) {
				locationList.add(taap.Location__c);
			}

			String fields = 'ID, ParentId, Parent.LocationType, Parent.Name, StateCode, Business_State__c, CountryCode,'
                +'City, County__c, PostalCode, State, Street, Country';
			String whereClause = 'ParentId IN ' + LPI_ServiceUtility.getStringValuesBySet(locationList);
			List<Schema.Address> addresses = LPI_AddressDAO.getAddressByDymanicQuery(
				fields,
				whereClause,
				null,
				null,
				null
			);
			Boolean isResidenceChanged = false;
			Boolean isMailingChanged = false;
			Map<String, Portal_Notification_Message__mdt> portalNotificationMessageMap = new Map<String, Portal_Notification_Message__mdt>();
			Map<String, String> replaceTextMap = new Map<String, String>();
			List<Notification__c> portalNotificationToInsert = new List<Notification__c>();
			for (Schema.Address address : addresses) {
				if (address.Parent.LocationType == LOCATION_TYPE_RESIDENCE) {
					if (
						address.Street != residenceStreetAddress ||
						address.Country != residenceCountry ||
						address.City != residenceCity ||
						address.PostalCode != residenceZipCode ||
						address.State != residenceStatePicklistEdit ||
						address.Business_State__c != residenceStateTextEdit
					) {
						isResidenceChanged = true;
					}
				}
				
                if(address.Parent.LocationType == LOCATION_TYPE_MAILING) {
					if (
						address.Street != mailingStreetAddress ||
						address.Country != mailingCountry ||
						address.City != mailingCity ||
						address.PostalCode != mailingZipCode ||
						address.State != mailingStatePicklistEdit ||
						address.Business_State__c != mailingStateTextEdit
					) {
						isMailingChanged = true;
					}
				}
			}
            
			// Send notification is Address Changeds
			if ((isMailingChanged || isResidenceChanged) && parId != null) {
				List<IndividualApplication> iaApplication = LPI_IndividualApplicationDAO.getILABySavedAppRefId(
					new Set<Id>{ parId }
				);
				// Fetch bell notification from meta data
				for (
					Portal_Notification_Message__mdt notiRec : LPI_CustomMetadataTypeDAO.getAllPortalNotificationByDeveloperNames(
						new Set<String>{ 'Bell_Notification_If_Address_Changed' }
					)
				) {
					portalNotificationMessageMap.put(notiRec.DeveloperName, notiRec);
				}

				if (
					!iaApplication.isEmpty() &&
					String.isBlank(iaApplication[0].LicensePermitNameId) &&
                    (!APPLICABLE_IA_STATUS.contains(iaApplication[0].Status))
				) {
					// replaceTextMap
					replaceTextMap.put('[Application_Name]', iaApplication[0].Name);
					if (isMailingChanged) {
						replaceTextMap.put('[Address_Type]', 'Mailing');
					} else if (isResidenceChanged) {
						replaceTextMap.put('[Address_Type]', 'Residence');
					}
                    
                    if(isResidenceChanged && isMailingChanged) {
						replaceTextMap.put('[Address_Type]', 'Residence and Mailing');
					}

					//  create bell notification record
					portalNotificationToInsert.add(
						LPI_ServiceUtility.createBellNotificationRecord(
							portalNotificationMessageMap.get('Bell_Notification_If_Address_Changed'),
							true,
							replaceTextMap,
							iaApplication[0].OwnerId,
							iaApplication[0].Id
						)
					);
				}
			}
			if (!portalNotificationToInsert.isEmpty()) {
				LPI_WithoutSharingUtility.insertSObjectList(portalNotificationToInsert);
			}
		} catch (exception ex) {
			LPI_ExceptionManager.logException(
				'LPI_InsertPersonalDetailsOneTime',
				'sendNotificationAfterApplicationSubmission',
				ex
			);
		}
	}*/
}