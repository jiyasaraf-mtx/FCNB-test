/**
 * @description       : This is controller class for Manage Business Account
 * @author            : MTX Group Product Team | 28 Oct 2023
 * @group             :
 * @last modified on  : 
 * @last modified by  : 
 **/
public with sharing class LPI_ManageBusinessAccountController {
    private static final String CLASS_NAME = 'LPI_ManageBusinessAccountController';
    private static final String ROLE_AUTHORIZED_CONTACT = 'Authorized Contact';
    private static final Set<String> COO_ROLES_SET = new Set<String>{
		'Board Director',
		'Corporate Officer',
		'Shareholder'
		 
	};
    private static final Set<String> ROLES_SET = new Set<String>{
		'Authorized Contact',
		 
		'Corporate Officer',
		 
		'Shareholder'
		 
	};
    /**
	 * @author 					:MTX Group Product Team
	 * @description 			: This method is to fetch the Business Account details		
	 * @param personAccId 		: Person Account Id for Business to fetch the Business Account Details
	 * @last modified on 
	 * @last modified by 
	 * @return  `ManageBusinessAccWrapper`
	*/
	@AuraEnabled
    public static ManageBusinessAccWrapper getBusinessAccountData(String personAccId){
        try {
			List<ContactDeatils> authDetailsList = new List<ContactDeatils>();
			List<ContactDeatils> corporateOfficerList = new List<ContactDeatils>();
            ManageBusinessAccWrapper manageAccWrapper;
			Integer authConIndex = 0;
			Integer corpIndex = 0;
			List<Account> personAccList = new List<Account>();
			 
			if(String.isNotBlank(personAccId)){
				String queryFields = 'Id, Name, PersonEmail';
                String whereClause = 'Id = \'' + String.escapeSingleQuotes(personAccId) + '\'';
				 
				personAccList = LPI_AccountDAO.getAccountListByDynamicQuery(new List<String>{queryFields}, whereClause, 1, null, null);
			}
			 
            if(!personAccList.isEmpty()){
				 
                String queryFields = 'Id,Name,MO_State_Registration_Number__c,Buisness_Email__c,Fictitious_Name__c,Phone,'+
                'Federal_Employer_ID_Number_EIN__c,BillingCountryCode, BillingStreet,BillingCity,BillingPostalCode,'+
                'BillingStateCode,Other_State__c,County__c,Business_Identification_Number__c,'+
                'IsMailingAddress_same_as_current_Address__c,ShippingCountryCode,'+
                'ShippingStreet,ShippingCity,ShippingPostalCode,ShippingStateCode,Mailing_Other_State__c,Mailing_County__c';
                String whereClause = 'Name = \'' + String.escapeSingleQuotes(personAccList[0].Name) + '\''+
									' AND Person_Account_For_Business__c = false';
									
				List<Account> businessAccList = LPI_AccountDAO.getAccountListByDynamicQuery(new List<String>{queryFields}, whereClause, 1, null, null);				 
                
				if(!businessAccList.isEmpty()){
					
					 
					String brQueryFields = 'Id, Related_To__r.FirstName, Roles__c, Related_To__r.MiddleName,'+
					' Related_To__r.LastName, Related_To__r.PersonEmail, Related_To__r.Phone, IsActive__c,'+
					' Related_To__r.PersonOtherStreet, Related_To__r.PersonOtherPostalCode,Related_To__c,'+
					' Related_To__r.PersonOtherCity, Related_To__r.PersonOtherStateCode,Related_From__c,'+
					' Related_To__r.Other_State__c, Related_To__r.PersonOtherCountryCode,Related_To__r.County__c,'+
					' Related_To__r.Social_Security_Number__c, Related_To__r.Date_of_Birth__c';
					 
					String brQueryClause = 'Related_From__c = \''+businessAccList[0].Id + '\''+
					+' AND Roles__c IN '+LPI_ServiceUtility.getStringValuesByStringSet(ROLES_SET)
					+' AND IsActive__c = true';
					
					for(Business_Relationships__c br : new LPI_BusinessRelationshipDAO.LPI_BusinessRelationshipsWithoutSharingDAO().getBusinessRelationshipsByDymanicQuery(
						brQueryFields, brQueryClause, null, null, null)){
						 
						if(br.Roles__c == ROLE_AUTHORIZED_CONTACT){
							authDetailsList.add(new ContactDeatils(br, authConIndex));
							authConIndex = authConIndex + 1;
						}  
						else if(COO_ROLES_SET.Contains(br.Roles__c)){
							corporateOfficerList.add(new ContactDeatils(br, corpIndex));
							corpIndex = corpIndex + 1;
						}
					}
					manageAccWrapper = new ManageBusinessAccWrapper(businessAccList[0], personAccList[0], authDetailsList, corporateOfficerList);
				}
            }
            return manageAccWrapper;
        } catch (Exception ex) {
            LPI_ExceptionManager.logException(CLASS_NAME, 'getBusinessAccountData', ex);
        }
        return null;
    }
	/**
	 * @author 					: MTX Group Product Team
	 * @description 			: This method id to save the Business Account Changes
	 * @param manageAccData 	: Business Account Data from the JS
	 * @last modified on 
	 * @last modified by 
	 * @return  `Boolean`
	*/
	@AuraEnabled
	public static Boolean saveBusinessAccountData(String manageAccData){
		Boolean result = false;
		try{
			ManageBusinessAccWrapper manageAccDataWrapper = (ManageBusinessAccWrapper) JSON.deserializeStrict(
				manageAccData,
				ManageBusinessAccWrapper.class
			);
			Id personAccountRecordTypeId = LPI_UtilityDescribe.getRecordTypeIdWithName(
				'Account',
				LPI_LiteralConstant.ACCOUNT_PERSON_RECORDTYPE
			);
			List<SObject> recordsListToUpdate = new List<SObject>();
			Map<String, ContactDeatils> authAndCorporateOfficersBRMap = new Map<String, ContactDeatils>();
			List<Business_Relationships__c> insertRelationshipList = new List<Business_Relationships__c>();
			 
			Map<Integer, Account> accountIndexingMapForAuthContact = new Map<Integer, Account>();
			Map<Integer, ContactDeatils> initialWrapperMapForAuthContact = new Map<Integer, ContactDeatils>();
			Integer countAuth = 0;
			 
            
			for(ContactDeatils con : manageAccDataWrapper.authContactListResp){
				Account personAcc = new Account();
				personAcc.RecordTypeId = personAccountRecordTypeId;
				personAcc.FirstName = LPI_VlocityUtility.updateStringToCamelCase(con.firstname);
				personAcc.middleName = LPI_VlocityUtility.updateStringToCamelCase(con.middleName);
				personAcc.LastName = LPI_VlocityUtility.updateStringToCamelCase(con.lastName);
				personAcc.Phone = con.phone;
				
				personAcc.PersonEmail = con.email;
				if(String.isNotBlank(con.conId)){
					personAcc.Id = con.conId;
				}
				List<Account> existingAuthorizedAccount = LPI_ServiceUtility.getDuplicateRecordsByEmail(new List<Account>{personAcc});
				 
				if (!existingAuthorizedAccount.isEmpty()) {
					personAcc.Id = existingAuthorizedAccount[0].Id;
				}

				accountIndexingMapForAuthContact.put(countAuth, personAcc);
				initialWrapperMapForAuthContact.put(countAuth, con);
				countAuth = countAuth + 1;
			}
			LPI_WithoutSharingUtility.upsertSObjectList(accountIndexingMapForAuthContact.values());
			 
			for(Integer var : accountIndexingMapForAuthContact.keySet()){
				Business_Relationships__c brRecordTemp = new Business_Relationships__c();
				 
				if(manageAccDataWrapper.businessAccId != NULL && 
					initialWrapperMapForAuthContact.get(var).conId == NULL){
					insertRelationshipList.add(brRecordHelper('Authorized Contact', manageAccDataWrapper.businessAccId, accountIndexingMapForAuthContact.get(var).Id));
				} 
				else if(initialWrapperMapForAuthContact.get(var).relId != NULL){
					authAndCorporateOfficersBRMap.put(initialWrapperMapForAuthContact.get(var).relId, initialWrapperMapForAuthContact.get(var));
				}
			}
			 
			Map<Integer, Account> accountIndexingMap = new Map<Integer, Account>();
			Map<Integer, ContactDeatils> initialWrapperMap = new Map<Integer, ContactDeatils>();
			Integer count = 0;
			
			for(ContactDeatils con : manageAccDataWrapper.corporateOfficerListResp){
				Account personAcc = new Account();
				
				personAcc.RecordTypeId = personAccountRecordTypeId;
				personAcc.FirstName = LPI_VlocityUtility.updateStringToCamelCase(con.firstname);
				personAcc.middleName = LPI_VlocityUtility.updateStringToCamelCase(con.middleName);
				personAcc.LastName = LPI_VlocityUtility.updateStringToCamelCase(con.lastName);
				personAcc.PersonOtherStreet = con.addressData.street1;
				personAcc.PersonOtherPostalCode = con.addressData.zipcode;
				personAcc.PersonOtherCity = con.addressData.city;
				if (con.addressData.state != null) {
					personAcc.PersonOtherStateCode = con.addressData.state;
				}
				if (con.addressData.stateText != null) {
					personAcc.Other_State__c = con.addressData.stateText;
				}
				personAcc.PersonOtherCountryCode = con.addressData.country;
				personAcc.County__c = con.addressData.county;
				personAcc.PersonEmail = con.email;
				personAcc.Social_Security_Number__c = con.newssn;
				if(con.birthdate != NULL && con.birthdate != ''){
					personAcc.Date_of_Birth__c = Date.valueOf(con.birthdate);
				}
				if(String.isNotBlank(con.conId)){
					personAcc.Id = con.conId;
				}
				List<Account> existingCorporateAccount = LPI_ServiceUtility.getDuplicateRecordsByEmail(new List<Account>{personAcc});
				 
				if (!existingCorporateAccount.isEmpty()) {
					personAcc.Id = existingCorporateAccount[0].Id;
				}

				accountIndexingMap.put(count, personAcc);
				initialWrapperMap.put(count, con);
				count = count + 1;
			}

			LPI_WithoutSharingUtility.upsertSObjectList(accountIndexingMap.values());
			 
			for(Integer var : accountIndexingMap.keySet()){
				Business_Relationships__c brRecordTemp = new Business_Relationships__c();
				 
				if(manageAccDataWrapper.businessAccId != NULL && 
					initialWrapperMap.get(var).conId == NULL){
					insertRelationshipList.add(brRecordHelper(initialWrapperMap.get(var).role, manageAccDataWrapper.businessAccId, accountIndexingMap.get(var).Id));
				} 
				else if(initialWrapperMap.get(var).relId != NULL){
					authAndCorporateOfficersBRMap.put(initialWrapperMap.get(var).relId,initialWrapperMap.get(var));
				}
			}
			 
			deleteAuthContactAndCorporateOfficers(manageAccDataWrapper.businessAccId, authAndCorporateOfficersBRMap);
			 
			Account manageAccRec = new Account(Id = manageAccDataWrapper.businessAccId,
				Buisness_Email__c = manageAccDataWrapper.businessEmail,
				Phone = manageAccDataWrapper.businessPhone
			);
			recordsListToUpdate.add(manageAccRec);
			 
			Account personAccRec = new Account(Id = manageAccDataWrapper.personAccId,
				Phone = manageAccDataWrapper.businessPhone
			);
			recordsListToUpdate.add(personAccRec);
			 
			if(manageAccDataWrapper.businessEmail != manageAccDataWrapper.oldBusinessEmail){	
				User userRec = new User(Id = UserInfo.getUserId(), Email = manageAccDataWrapper.businessEmail);
				recordsListToUpdate.add(userRec);
			}
			 
			if(!insertRelationshipList.isEmpty()){
				LPI_WithoutSharingUtility.insertSObjectList(insertRelationshipList);
			}
			 
			if(!recordsListToUpdate.isEmpty()){
				LPI_DML.doUpdate(recordsListToUpdate);
			}
			result = true;
		}catch(Exception ex){
			result = false;
			LPI_ExceptionManager.logException(CLASS_NAME, 'saveBusinessAccountData', ex);
		}
		return result;
	}
	/**
	 * @author 								: MTX Group Product Team
	 * description 							: This method is used to delete the Auth contact and Corportate officers
	 * @param accId 						: Business Account Id
	 * @param authAndCorporateOfficersBRMap : Authorized Contact and Corporate Officers BR Map
	 * @last modified on 
	 * @last modified by 
	*/
	public static void deleteAuthContactAndCorporateOfficers(String accId, Map<String, ContactDeatils> authAndCorporateOfficersBRMap){
        List<Business_Relationships__c> brListToDelete = new List<Business_Relationships__c>();
		 
		String brQueryClause = 'Related_From__c = \''+String.escapeSingleQuotes(accId) + '\''
			+' AND Roles__c IN '+LPI_ServiceUtility.getStringValuesByStringSet(ROLES_SET)
			+' AND IsActive__c = true';
			for(Business_Relationships__c br : LPI_BusinessRelationshipDAO.fetchBusinessRelationshipRecords(
				'Id, IsActive__c, EndDate__c, Roles__c', brQueryClause, null, null, null
			)){
				
				 
				if(!authAndCorporateOfficersBRMap.containsKey(br.Id)){
					br.IsActive__c = false;
					br.EndDate__c = Date.today();
					brListToDelete.add(br);
				}  
				else if(authAndCorporateOfficersBRMap.containsKey(br.Id) && authAndCorporateOfficersBRMap.get(br.Id).role != br.Roles__c){
					br.Roles__c = authAndCorporateOfficersBRMap.get(br.Id).role;
					brListToDelete.add(br);
				}
			}
			 
			if(!brListToDelete.isEmpty()){
				LPI_DML.doUpdate(brListToDelete);
			}
	}
	/**
	 * @author 				: MTX Group Product Team
	 * @description 		: This method will return the BR SObject Record
	 * @param brRole 		: Role value
	 * @param relFromId 	: Related From Id
	 * @param relToId 		: Related To Id
	 * @last modified on 
	 * @last modified by 
	 * @return  `Business_Relationships__c`
	*/
	public static Business_Relationships__c brRecordHelper(String brRole, String relFromId, String relToId){
		Business_Relationships__c brRecordTemp = new Business_Relationships__c();
		brRecordTemp.Roles__c = brRole;
		brRecordTemp.Related_From__c = relFromId;
		brRecordTemp.Related_To__c = relToId;
		brRecordTemp.Start_Date__c = Date.today();
		brRecordTemp.IsActive__c = true;
		return brRecordTemp;
	}
	/**
	 * @author      :MTX Group Product Team
	 * @description : This is Wrapper class for Authorized Contact and Corporate Officers fields 
	 */
    public class ContactDeatils{
		@AuraEnabled public String firstName;
		@AuraEnabled public String middleName;
		@AuraEnabled public String lastName;
		@AuraEnabled public String email;
		@AuraEnabled public String phone;
		@AuraEnabled public String role;
		@AuraEnabled public String ssn;
		@AuraEnabled public String newssn;
		@AuraEnabled public String birthdate;
		@AuraEnabled public AddressDetails addressData;
		@AuraEnabled public String index;
		@AuraEnabled public String editButtonAriaLabel;
		@AuraEnabled public String deleteButtonAriaLabel;
		@AuraEnabled public String ssnCheck;
		@AuraEnabled public String conId;
		@AuraEnabled public String relId;
		
		public ContactDeatils(Business_Relationships__c br, Integer conIndex){
			String msg = br.Related_To__r.FirstName + ' ' + br.Related_To__r.LastName+ ' ' +br.Roles__c;
			firstName = br.Related_To__r.FirstName;
			lastName = br.Related_To__r.LastName;
			middleName = br.Related_To__r.MiddleName;
			email = br.Related_To__r.PersonEmail;
			phone = br.Related_To__r.Phone;
			role = br.Roles__c;
			ssn = br.Related_To__r.Social_Security_Number__c;
			newssn = br.Related_To__r.Social_Security_Number__c;
			birthdate = String.ValueOf(br.Related_To__r.Date_of_Birth__c);
			conId = br.Related_To__c;
			relId = br.Id;
			index = String.valueOf(conIndex);
			editButtonAriaLabel = 'Edit '+msg;
			deleteButtonAriaLabel = 'Delete '+msg;
			addressData = new AddressDetails(br);
		}
	}
	/**
	 * @author      : MTX Group Product Team
	 * @description : This is Wrapper class for fields of Address 
	*/
	public class AddressDetails{
		@AuraEnabled public String street1;
		@AuraEnabled public String city;
		@AuraEnabled public String state;
		@AuraEnabled public String stateText;
		@AuraEnabled public String zipcode;
		@AuraEnabled public String country;
		@AuraEnabled public String county;

		public AddressDetails(Business_Relationships__c br){
			street1 = br.Related_To__r.PersonOtherStreet;
			city = br.Related_To__r.PersonOtherCity;
			state = br.Related_To__r.PersonOtherStateCode;
			stateText = br.Related_To__r.Other_State__c;
			zipcode = br.Related_To__r.PersonOtherPostalCode;
			country = br.Related_To__r.PersonOtherCountryCode;
			county = br.Related_To__r.County__c;
		}
	}
    /**
	 * @author      : MTX Group Product Team
	 * @description : This is Wrapper class for fields of registration page
	*/
	public class ManageBusinessAccWrapper{
		@AuraEnabled public String personAccId;
		@AuraEnabled public String businessAccId;
		@AuraEnabled public String businessName;
		@AuraEnabled public String moStateRegistrationNumber;
		@AuraEnabled public String businessEmail;
		@AuraEnabled public String businessFictitiousName;
		@AuraEnabled public String businessPhone;
		@AuraEnabled public String employerIdentificationNum;
		@AuraEnabled public String businessCountry;
		@AuraEnabled public String businessStreet1;
		@AuraEnabled public String businessCity;
		@AuraEnabled public String businessZipcode;
		@AuraEnabled public String businessZipcodeNonUS;
		@AuraEnabled public String businessState;
		@AuraEnabled public String businessStateText;
        @AuraEnabled public String businessCounty;
		@AuraEnabled public String mailingCountry;
		@AuraEnabled public String mailingStreet1;
		@AuraEnabled public String mailingCity;
		@AuraEnabled public String mailingZipcode;
		@AuraEnabled public String mailingZipcodeNonUS;
		@AuraEnabled public String mailingState;
		@AuraEnabled public String mailingStateText;
		@AuraEnabled public String mailingCounty;
		@AuraEnabled public Boolean mailingAddressSameAsBusiness;
		@AuraEnabled public String oldBusinessEmail;

		@AuraEnabled public ContactDeatils authorizedContactDetails;
		@AuraEnabled public List<ContactDeatils> authContactListResp;
		@AuraEnabled public List<ContactDeatils> corporateOfficerListResp;
		@AuraEnabled public String businessOutsideUS;
		@AuraEnabled public String businessIdentificationNumber;
		 
		public ManageBusinessAccWrapper(Account businessAcc, Account personAccount,
										List<ContactDeatils> authContactListResp,
										List<ContactDeatils> corporateOfficerListResp) {
			this.personAccId = personAccount.Id;
			this.businessAccId = businessAcc.Id;
			this.businessName = businessAcc.Name;
			this.moStateRegistrationNumber = businessAcc.MO_State_Registration_Number__c;
			this.businessEmail = personAccount.PersonEmail;
			this.oldBusinessEmail = personAccount.PersonEmail;
			this.businessFictitiousName = businessAcc.Fictitious_Name__c;
			this.businessPhone = businessAcc.Phone;
			this.employerIdentificationNum = businessAcc.Federal_Employer_ID_Number_EIN__c;
            this.businessCountry= businessAcc.BillingCountryCode;
            this.businessStreet1= businessAcc.BillingStreet;
            this.businessCity= businessAcc.BillingCity;
            this.businessZipcode= businessAcc.BillingPostalCode;
            this.businessZipcodeNonUS= businessAcc.BillingPostalCode;
            this.businessState= businessAcc.BillingStateCode;
            this.businessStateText= businessAcc.Other_State__c;
            this.businessCounty= businessAcc.County__c;
            this.mailingAddressSameAsBusiness= businessAcc.IsMailingAddress_same_as_current_Address__c;
            this.mailingCountry= businessAcc.ShippingCountryCode;
            this.mailingStreet1= businessAcc.ShippingStreet;
            this.mailingCity= businessAcc.ShippingCity;
            this.mailingZipcode= businessAcc.ShippingPostalCode;
            this.mailingZipcodeNonUS= businessAcc.ShippingPostalCode;
            this.mailingState= businessAcc.ShippingStateCode;
            this.mailingStateText= businessAcc.Mailing_Other_State__c;
            this.mailingCounty= businessAcc.Mailing_County__c;
			this.authContactListResp = authContactListResp;
			this.corporateOfficerListResp = corporateOfficerListResp;
			this.businessOutsideUS = String.isNotBlank(businessAcc.Business_Identification_Number__c) ? 'Yes' : 'No';
			this.businessIdentificationNumber = businessAcc.Business_Identification_Number__c;
		}
	}
}