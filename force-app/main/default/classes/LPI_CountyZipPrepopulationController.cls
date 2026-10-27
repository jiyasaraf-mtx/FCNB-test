/**
 * @description       : Controller for LPI_countyzipprepopulation Component used to pre popuplate city and county using zipcode
 * @author            : MTX Group Product Team
 * @group             : 
 * @since             : 23 Jan 2024
 * @last modified on  : 06-04-2024
 * @last modified by  : MTX Group Product Team
**/
global without sharing class LPI_CountyZipPrepopulationController implements Callable {
    public static final String CLASS_NAME = 'LPI_CountyZipPrepopulationController';
	public static final String ZIP_CITY_COUNTY_PRE_POPULATION ='Zip City County Pre Population';
	public static final String PERSON_INCHARGE = 'Designated Incharge';

    private static final Set<String> NO_PCA_BLOCK_BOARD_NAME_SET = new Set<String>{
		'Real Estate'
	};
	private static final Set<String> NO_LA_BLOCK_BOARD_NAME_SET = new Set<String>{
		'Real Estate'
	};
	private static final Set<String> NO_PDA_BLOCK_BOARD_NAME_SET= new Set<String>{
		 
		'Real Estate'
	};
	
	private final static String FACILITY_CHANGE_OF_LOCATION = 'Facility change of location application';
	private final static String ACCOUNT_BUSINESS_RECORDTYPE = 'Business';
	
	private static final Set<String> STEPNAME_SET_FOR_COUNTY = new Set<String>{
		'BusinessAccount'
	};
	global Object call(String action, Map<String, Object> args) {
        Map<String, Object> input = (Map<String, Object>) args.get('input');
        Map<String, Object> output = (Map<String, Object>) args.get('output');
        Map<String, Object> options = (Map<String, Object>) args.get('options');
        return invokeMethod(action, input, output, options);
    }
	

	private Boolean invokeMethod(String methodName, Map<String, Object> inputMap, Map<String, Object> outMap, Map<String, Object> options) {
        Boolean result = true;
        try {
            switch on methodName {
                when 'getDataToPrepopulateBasedOnZipCode' {
                    outMap.put('fetchCityCounty', JSON.deserializeUntyped(JSON.serialize(getDataToPrepopulateBasedOnZipCode(inputMap))));
                }
				when 'requiredCheckMethod'{
					outMap.put('requiredError',requiredCheckMethod(inputMap,outMap,options));
				}
				when 'RequiredCheckMethodForMailing'{
					outMap.put('requiredErrorForMailing',requiredCheckMethod(inputMap,outMap,options));
				}
				when 'fetchSavedZipCountyCityValues'{
					outMap.put('savedValuesOfZipCountyCity',JSON.deserializeUntyped(JSON.serialize(fetchSavedZipCountyCityValues(inputMap))));
				}
				when 'checkfieldVisibility'{
					outMap.put('checkfieldVisibility',JSON.deserializeUntyped(JSON.serialize(checkfieldVisibility(inputMap))));
				}
				when 'checkCountyFieldRequired'{  
					outMap.put('isCountyFieldRequired',JSON.deserializeUntyped(JSON.serialize(checkCountyFieldRequired(inputMap))));
				}
            }
        } catch (Exception e) {
            result = false;
            LPI_ExceptionManager.logException('LPI_CountyZipPrepopulationController', 'invokeMethod', e);
        }
        return result;
    }


	/**
	 * @author                      : MTX Group Product Team
	 * @since                       : 23 Jan 2024
	 * @description                 : fetch city and county based on zipcode entered
	 * @return                      : DataWrapper
	 * @last modified by            : MTX Group Product Team
	 * @last modified date          :
	 * @modified details            :
	 */
	public static DataWrapper getDataToPrepopulateBasedOnZipCode(Map<String,Object> inputMap) {
        DataWrapper dataWrap = new DataWrapper();
		string zipCode = (String) inputMap.get('zipCode');
		try {
			String orginalZipCode;
			if(String.isNotBlank(zipCode))
			{
				orginalZipCode = zipCode.deleteWhitespace();
			}
			if(String.isNotBlank(orginalZipCode) && orginalZipCode.length() >= 5){
				List<County_ZipCode_Inspector_Mapping__c> countyZiplist = new LPI_CountyZipCodeInspectorMappingDao.LPI_CountyZipCodeInspectorMappingWithoutSharingDao().getCountyZipCodeInspectorByDynamicQuery(
				'City__c ,County__c, ZipCode__c', 'ZipCode__c = \''+orginalZipCode+'\''+' And RecordType.Name = \''+ZIP_CITY_COUNTY_PRE_POPULATION+'\'', null, null, null); 
				if(!countyZiplist.isEmpty()){
					dataWrap.city = countyZiplist[0].City__c;
					dataWrap.county = countyZiplist[0].County__c;
				}	
			}
        } catch (Exception ex) {
            LPI_ExceptionManager.logException(CLASS_NAME, 'getDataToPrepopulate', ex);
        }
		return dataWrap;
	}
	/**
	 * @author              : MTX Group Product Team
	 * @param parId         : PAR Id 
	 * @param addressType   : Address Type present on Personal Information step
	 * @description         : This method is use to trgger required check
	 * @last modified by    : MTX Group Product Team
	 * @last modified date  :
	 * @modified details    :
	 */
	public static boolean requiredCheckMethod(Map<String,Object> inputMap,Map<String,Object> outMap ,Map<String, Object> options) {
		Boolean result;
		try 
		{		
			String stepName = (String) options.get('stepname');
			 
			Map<String, object> stepMap = (Map<String, object>) inputMap.get(stepName);

			if(stepMap != null )
			{
				boolean requiredFieldCheckForLA,requiredFieldCheckForPDA,requiredFieldCheckForResidence,
				requiredFieldCheckForMailing,requiredFieldCheckForPCA,requiredFieldCheckForHomeAdd,requiredFieldCheckForSchoolAddress;	
				if(stepName == 'BusinessAccount' || stepName == 'NewLocationInformation')
				{
					requiredFieldCheckForResidence = (boolean) stepMap.get('RequiredFieldCheckForResidence');
					requiredFieldCheckForMailing = (boolean) stepMap.get('RequiredFieldCheckForMailing');
				 	requiredFieldCheckForPCA = (boolean) stepMap.get('RequiredFieldCheckForPCA');
				}
				else if(stepName == 'DesignatedBrokerDetails'){
					requiredFieldCheckForMailing = (boolean) stepMap.get('RequiredFieldCheckForMailing');
				}
				else if(stepName == 'PersonalInformation'){
					requiredFieldCheckForResidence = (boolean) stepMap.get('RequiredFieldCheckForResidence');
					requiredFieldCheckForMailing = (boolean) stepMap.get('RequiredFieldCheckForMailing');
					if(!NO_PCA_BLOCK_BOARD_NAME_SET.contains((String) inputMap.get('BoardName')))
					{
						requiredFieldCheckForPCA = (boolean) stepMap.get('RequiredFieldCheckForPCA');
					}
					if(!NO_LA_BLOCK_BOARD_NAME_SET.contains((String) inputMap.get('BoardName')))
					{
						requiredFieldCheckForLA = (boolean) stepMap.get('RequiredFieldCheckForLA');
					}
					if(!NO_PDA_BLOCK_BOARD_NAME_SET.contains((String) inputMap.get('BoardName')))
					{
						requiredFieldCheckForPDA = (boolean) stepMap.get('RequiredFieldCheckForPDA');
					}
				}
				else if(stepName == 'SchoolAdministratorInformation' || stepName == 'AdminInfoAmendment' || stepName == 'ProgramAdministratorInformation')
				{
					requiredFieldCheckForHomeAdd = (boolean) stepMap.get('RequiredFieldCheckForHomeAdd');
				}
				else if(stepName == 'SchoolInformation'){
					requiredFieldCheckForSchoolAddress = (boolean) stepMap.get('RequiredFieldCheckForSchoolAddress');
				}else if(stepName == 'PersonalInformationNameAmendment')
				{
					requiredFieldCheckForResidence = (boolean) stepMap.get('RequiredFieldCheckForResidence');
				}
				else if(stepName == 'MailingAddressDetails')
				{
					requiredFieldCheckForMailing = (boolean) stepMap.get('RequiredFieldCheckFoMailing');
				}
				 
				if(requiredFieldCheckForResidence == true || requiredFieldCheckForMailing == true || requiredFieldCheckForPCA == true || requiredFieldCheckForLA == true || requiredFieldCheckForPDA == true
				|| requiredFieldCheckForHomeAdd == true || requiredFieldCheckForSchoolAddress == true){
					result= true;
				}else{
					result = false;
				}	
			}
			else{
				result = true;
			}
			 
		}catch (Exception ex) {
            LPI_ExceptionManager.logException(CLASS_NAME, 'requiredCheckMethod', ex);
        }
		return result;
	}

	/**
	 * @author              : MTX Group Product Team
	 * @param parId         : PAR Id 
	 * @param addressType   : Address Type present on Personal Information step
	 * @description         : This method is will fetch the data once page is refreshed
	 * @last modified by    : MTX Group Product Team
	 * @last modified date  :
	 * @modified details    :
	 */
    public static SavedDataWrapper fetchSavedZipCountyCityValues(Map<String,Object> inputMap) {
		SavedDataWrapper result = new SavedDataWrapper();
        try{
			List<PreliminaryApplicationRef> parList = new List<PreliminaryApplicationRef>();
			String parId = (String) inputMap.get('parId');
			String addressType = (String) inputMap.get('addressType');
			Set<Id> locationIdSet = new Set<Id>();
			String primaryContactAddress,licenseAddress,publiclyDisplayedAddress,personInchargeRelationId;
			Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
				.get(ACCOUNT_BUSINESS_RECORDTYPE)
				.getRecordTypeId();

			if(String.isNotBlank(parId))
			{
				List<PreliminaryApplicationRef> par = LPI_PreliminaryApplicationRefDAO.getPreliminaryApplicationRefByDymanicQuery('Id,BusinessAccountName.BillingPostalCode,BusinessAccountName.BillingCity, BusinessAccountName.County__c,BusinessAccountName.BillingCountryCode,BusinessAccountName.BillingStateCode,BusinessAccountName.BillingStreet,BusinessAccountName.Other_State__c,Person_Incharge_Relation_Id__c,Amendment_Type__c, BusinessAccountName.RecordTypeId',' Id =\''+String.escapeSingleQuotes(parId)+'\'',null,null,null);
				personInchargeRelationId = par[0].Person_Incharge_Relation_Id__c;				
				for (Temp_AuthApplicationPlace__c tempAap : new LPI_TempAuthApplicationPlaceDAO.LPI_TempAuthApplicationPlaceWithoutSharingDAO()
					.getTempAuthApplicationPlaceByDymanicQuery(
						'Id,Location__c,Preliminary_Application_Reference__r.Primary_Contact_Address__c,Preliminary_Application_Reference__r.License_Address__c,Preliminary_Application_Reference__r.Publicly_Displayed_Address__c,Preliminary_Application_Reference__r.Person_Incharge_Relation_Id__c',
						'Preliminary_Application_Reference__c = \'' + String.escapeSingleQuotes(parId) + '\'',
						null,
						null,
						null
					)
				) 
				{
					locationIdSet.add(tempAap.Location__c);
					primaryContactAddress = tempAap.Preliminary_Application_Reference__r.Primary_Contact_Address__c;
					licenseAddress = tempAap.Preliminary_Application_Reference__r.License_Address__c;
					publiclyDisplayedAddress = tempAap.Preliminary_Application_Reference__r.Publicly_Displayed_Address__c;
				}
				if(!locationIdSet.isEmpty())
				{
					string fields = 'ID,ParentId,Parent.LocationType,City,County__c,PostalCode,Parent.Consent_For__c,Street,CountryCode,StateCode,Business_State__c';	
					String whereClause = 'ParentId IN ' + LPI_ServiceUtility.getStringValuesBySet(locationIdSet);	
					List<Schema.Address> addresses = LPI_AddressDAO.getAddressByDymanicQuery(fields, whereClause, null, null, null);
					for (Schema.Address address : addresses) {
						if (address.Parent.LocationType == 'Residence' && addressType == 'Residence') {
							result.zipcode = address.PostalCode;
							result.city = address.City;
							result.county = address.County__c;
							result.streetaddress = address.Street;
							result.country = address.CountryCode;
							result.statepicklist = address.StateCode;
							result.statetext = address.Business_State__c;
						}
						else if (address.Parent.LocationType == 'Mailing' && addressType == 'Mailing') {
							result.zipcode = address.PostalCode;
							result.city = address.City;
							result.county = address.County__c;
							result.streetaddress = address.Street;
							result.country = address.CountryCode;
							result.statepicklist = address.StateCode;
							result.statetext = address.Business_State__c;
						}
						else if (address.Parent.LocationType == 'Business Address' && addressType == 'Business Address') {
							result.zipcode = address.PostalCode;
							result.city = address.City;
							result.county = address.County__c;
							result.streetaddress = address.Street;
							result.country = address.CountryCode;
							result.statepicklist = address.StateCode;
							result.statetext = address.Business_State__c;
						}
						else if (address.Parent.LocationType == 'Branch' && addressType == 'Branch') {
							result.zipcode = address.PostalCode;
							result.city = address.City;
							result.county = address.County__c;
							result.streetaddress = address.Street;
							result.country = address.CountryCode;
							result.statepicklist = address.StateCode;
							result.statetext = address.Business_State__c;
						}
						else if (address.Parent.LocationType == 'Secondary Business Address' && addressType == 'Secondary Business Address') {
							result.zipcode = address.PostalCode;
							result.city = address.City;
							result.county = address.County__c;
							result.streetaddress = address.Street;
							result.country = address.CountryCode;
							result.statepicklist = address.StateCode;
							result.statetext = address.Business_State__c;
						}
						else if (address.Parent.LocationType == 'Local Address' && addressType == 'Local Address') {
							result.zipcode = address.PostalCode;
							result.city = address.City;
							result.county = address.County__c;
							result.streetaddress = address.Street;
							result.country = address.CountryCode;
							result.statepicklist = address.StateCode;
							result.statetext = address.Business_State__c;
						}
						else if (address.Parent.LocationType == 'Other' && addressType == 'Other') {
							result.zipcode = address.PostalCode;
							result.city = address.City;
							result.county = address.County__c;
							result.streetaddress = address.Street;
							result.country = address.CountryCode;
							result.statepicklist = address.StateCode;
							result.statetext = address.Business_State__c;
						}
						else if (address.Parent.LocationType == 'Person In Charge Address' && addressType == 'Person In Charge Address') {
							result.zipcode = address.PostalCode;
							result.city = address.City;
							result.county = address.County__c;
							result.streetaddress = address.Street;
							result.country = address.CountryCode;
							result.statepicklist = address.StateCode;
							result.statetext = address.Business_State__c;
						}
						if(address.Parent.Consent_For__c != null)
						{
							if (address.Parent.Consent_For__c.contains('Primary Contact Address') && addressType == 'Primary Contact Address' && 
								primaryContactAddress != 'Residence' && primaryContactAddress != 'Mailing' ) {
								result.zipcode = address.PostalCode;
								result.city = address.City;
								result.county = address.County__c;
								result.streetaddress = address.Street;
								result.country = address.CountryCode;
								result.statepicklist = address.StateCode;
								result.statetext = address.Business_State__c;
							}
							else if (address.Parent.Consent_For__c.contains('License Address') && addressType == 'License Address' &&
								licenseAddress != 'Residence' && licenseAddress != 'Mailing') {
								result.zipcode = address.PostalCode;
								result.city = address.City;
								result.county = address.County__c;
								result.streetaddress = address.Street;
								result.country = address.CountryCode;
								result.statepicklist = address.StateCode;
								result.statetext = address.Business_State__c;
							}
							else if (address.Parent.Consent_For__c.contains('Publicly Displayed Address') && addressType == 'Publicly Displayed Address' &&
								publiclyDisplayedAddress != 'Residence' && publiclyDisplayedAddress != 'Mailing') {
								result.zipcode = address.PostalCode;
								result.city = address.City;
								result.county = address.County__c;
								result.streetaddress = address.Street;
								result.country = address.CountryCode;
								result.statepicklist = address.StateCode;
								result.statetext = address.Business_State__c;
							}
						}
					}
				}
				else if(locationIdSet.isEmpty() && addressType == 'Business Address' && !par.isEmpty() && par[0].Amendment_Type__c != FACILITY_CHANGE_OF_LOCATION && par[0].BusinessAccountName.RecordTypeId == accRecordTypeId){
					 
					result.zipcode = par[0].BusinessAccountName.BillingPostalCode;
					result.city = par[0].BusinessAccountName.BillingCity;
					result.county = par[0].BusinessAccountName.County__c;
					result.streetaddress = par[0].BusinessAccountName.BillingStreet;
					result.country = par[0].BusinessAccountName.BillingCountryCode;
					result.statepicklist = par[0].BusinessAccountName.BillingStateCode;
					result.statetext = par[0].BusinessAccountName.Other_State__c;
				}

				if(addressType == 'Account Address'){
					String accountId;
					List<Business_Relationships__c> businessRelationRecord = new List<Business_Relationships__c>();
					if(personInchargeRelationId != null){
						businessRelationRecord = LPI_BusinessRelationshipDAO.fetchBusinessRelationshipRecords(
							'Related_To__r.PersonOtherStateCode,Related_To__r.Other_State__c,Related_To__r.PersonOtherStreet,Related_To__r.PersonOtherCountryCode,Related_To__r.PersonOtherPostalCode,Related_To__r.PersonOtherCity,Related_To__r.County__c',
							'Id =\''+String.escapeSingleQuotes(personInchargeRelationId)+'\'',
							null,null,null);
						}else{
						businessRelationRecord = LPI_BusinessRelationshipDAO.fetchBusinessRelationshipRecords(
							'Related_To__r.PersonOtherStateCode,Related_To__r.Other_State__c,Related_To__r.PersonOtherStreet,Related_To__r.PersonOtherCountryCode,Related_To__r.PersonOtherPostalCode,Related_To__r.PersonOtherCity,Related_To__r.County__c',
						    'Related_From__c =\''+par[0].BusinessAccountNameId+'\'' +
							' AND Roles__c = \'' + PERSON_INCHARGE + '\'' + 
							' AND EndDate__c = null',
							null,null,null);
						}
						if(!businessRelationRecord.isEmpty()){
							result.zipcode = businessRelationRecord[0].Related_To__r.PersonOtherPostalCode;
							result.city = businessRelationRecord[0].Related_To__r.PersonOtherCity;
							result.county = businessRelationRecord[0].Related_To__r.County__c;
							result.streetaddress = businessRelationRecord[0].Related_To__r.PersonOtherStreet;
							result.country = businessRelationRecord[0].Related_To__r.PersonOtherCountryCode;
							result.statepicklist = businessRelationRecord[0].Related_To__r.PersonOtherStateCode;
							result.statetext = businessRelationRecord[0].Related_To__r.Other_State__c;
						}
					}
				}
			}
		catch (Exception e) {
			LPI_ExceptionManager.logException(CLASS_NAME, 'fetchSavedZipCountyCityValues', e);
		}	
        return result;	
    }

	/**
	 * @author              : MTX Group Product Team
	 * @param parId         : PAR Id 
	 * @param addressType   : Address Type present on Personal Information step
	 * @description         : This method is will check field visibility
	 * @last modified by    : MTX Group Product Team
	 * @last modified date  :
	 * @modified details    :
	 */
	public static FieldVisibilty checkfieldVisibility(Map<String,Object> inputMap) {
		
		FieldVisibilty result ;
		List<PreliminaryApplicationRef> parList = new List<PreliminaryApplicationRef>();
		String parId = (String) inputMap.get('parId');
		String stepName = (String) inputMap.get('stepName');
		String stepNameAndElementName = (String) inputMap.get('stepNameAndElementName');
		
		if(String.isNotBlank(parId))
		{	
			result = new FieldVisibilty();
			List<PreliminaryApplicationRef> par = LPI_PreliminaryApplicationRefDAO.getPreliminaryApplicationRefByDymanicQuery('Id,Regulatory_Authorization_Type__r.Name,Board_Name__c ,Regulatory_Authorization_Type__r.Authorisation_Type__c',' Id =\''+String.escapeSingleQuotes(parId)+'\'',null,null,null);
			if(par[0]!= null && 
			(par[0].Regulatory_Authorization_Type__r.Name == 'Continuing Education Provider' ||
			par[0].Regulatory_Authorization_Type__r.Name == 'Real Estate School') || stepNameAndElementName == 'SchoolInformationSchoolEditableCountry' ){
				result.isCountryRO = true;
			}	
			
			if(stepNameAndElementName.equalsIgnoreCase('SchoolAdministratorInformationAdmincountry') || stepNameAndElementName.equalsIgnoreCase('AdminInfoAmendmentHomeAddressCountry')){
				result.isCountryVisible = false;
			}
		}
		return result;
	}
	/**
	 * @author              : MTX Group Product Team
	 * @param inputMap      : Input Map coming from LWC
	 * @description         : This method will check that County field is Required or Not based on BoardName and StepName (I-267573)
	 * @last modified by    : MTX Group Product Team
	 * @last modified date  :
	 * @modified details    :
	 */
	public static Boolean checkCountyFieldRequired(Map<String,Object> inputMap) {
		Boolean countyFieldReq = true;
		String parId = (String) inputMap.get('parId');
		String stepName = (String) inputMap.get('stepName');

		 
		
		
		return countyFieldReq;
	}



	public class DataWrapper {		
		public string city;
		public string county;

	}

	public class SavedDataWrapper {		
		public string zipcode;
		public string city;
		public string county;
		public string streetaddress;
		public string country;
		public string statepicklist;
		public string statetext;

		public SavedDataWrapper(
		) {
			this.zipCode = null;
			this.city = null;
			this.county = null;
			this.streetaddress = null;
			this.country = 'US';
			this.statepicklist = 'MO';
			this.statetext = null;
		}
	}
	public class FieldVisibilty {		
		public Boolean isCountryRO;
		public Boolean isCountryVisible;
		public FieldVisibilty(){
			this.isCountryRO = false;
			this.isCountryVisible = true;
		}
	}
	
}