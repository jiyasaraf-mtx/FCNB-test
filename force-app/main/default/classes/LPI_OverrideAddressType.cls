/**
 * @author            : MTX Group Product Team
 * @description       : Standard Class for Personal Information
 * @last modified on  : 07-26-2024
 * @last modified by  : MTX Group Product Team
 **/
global with sharing class LPI_OverrideAddressType implements Callable {
    private static  Map<String,String> ADDRESS_FIELD_OPTIONS = new Map<String,String>();

	private static final Map<String, String> ADDRESS_FIELD_OPTIONS_INDIVIDUAL = new Map<String, String>{
        'Branch Address' => 'Branch',
		'Business Address' => 'Business Address',
		'Local Address' => 'Local Address',
		'Mailing Address' => 'Mailing',
		'Other Address' => 'Other',
		'Residence Address' => 'Residence',
		'Secondary Business Address' => 'Secondary Business Address'
    };
	private static final Map<String, String> ADDRESS_FIELD_OPTIONS_BUSINESS = new Map<String, String>{
        'Branch Address' => 'Branch',
		'Business Address' => 'Business Address',
		'Mailing Address' => 'Mailing',
		'Other Address' => 'Other',
		'Secondary Business Address' => 'Secondary Business Address',
		'Warehouse Address' => 'Warehouse Address'
    };
	public final static String PRIMARY_CONTACT_ADDRESS = 'Primary Contact Address';
	public final static String LICENSE_ADDRESS = 'License Address';
	public final static String PUBLICLY_DISPLAYED_ADDRESS = 'Publicly Displayed Address';

	/**
    * @author            MTX Group Product Team
    * @description       Call method is used to run Invoke method.
    * @return  `Object`
    */
    global Object call(String action, Map<String, Object> args) {
        Map<String, Object> input = (Map<String, Object>) args.get('input');
        Map<String, Object> output = (Map<String, Object>) args.get('output');
        Map<String, Object> options = (Map<String, Object>) args.get('options');
        return invokeMethod(action, input, output, options);
    }

	    /**
    * @author            MTX Group Product Team
    * @description       This method will compare method from Omniscript and execute only that specific method
    * @return  `Boolean`
    */
    private Boolean invokeMethod(String methodName, Map<String, Object> inputMap, Map<String, Object> outMap, Map<String, Object> options) {
        Boolean result = true;
        try {
            switch on methodName {
                when 'picklistValueOfAddressField' {
                    outMap.put('picklistOptions', JSON.deserializeUntyped(JSON.serialize(picklistValueOfAddressField((String) inputMap.get('parId'), (String) inputMap.get('addressType')))));
                }
                when 'fetchSavedAddressFieldOnReload' {
                    outMap.put('savedValues', JSON.deserializeUntyped(JSON.serialize(fetchSavedAddressFieldOnReload((String)  inputMap.get('parId'), (String) inputMap.get('addressType')))));
                }
            }
        } catch (Exception e) {
            result = false;
            LPI_ExceptionManager.logException('LPI_OverrideAddressType', 'invokeMethod', e);
        }
        return result;
    }

	/**
	 * @author              : MTX Group Product Team
	 * @param parId         : PAR Id 
	 * @param addressType   : Address Type present on Personal Information step
	 * @description         : This method is will options to LWC
	 * @last modified by    : MTX Group Product Team
	 * @last modified date  :
	 * @modified details    :
	 */
    public static List<Map<String, Object>> picklistValueOfAddressField(String parId , String addressType) {
		List<Map<String, Object>> accList;
        try{
			List<PreliminaryApplicationRef> parList = new List<PreliminaryApplicationRef>();
			String boardName, applicationType,picklistValue, ratName;
			Map<String, Object> addressFieldOptions;

			if(String.isNotBlank(parId))
			{
				// previously its running in with sharing mode but from saturday not running in with security enforced
				parList = new LPI_PreliminaryApplicationRefDAO.LPI_PreliminaryApplicationRefWithoutSharingDAO().getPreliminaryApplicationRefByDymanicQuery(
					'Id,Regulatory_Authorization_Type__r.Authorisation_Type__c,Regulatory_Authorization_Type__r.Issuing_Department_Name__c, Regulatory_Authorization_Type__r.Name',
					'Id = \''+String.escapeSingleQuotes(parId)+'\'',
					null,
					null,
					null
				);
				if(!parList.isEmpty()){
					applicationType = parList[0].Regulatory_Authorization_Type__r.Authorisation_Type__c;
				    boardName = parList[0].Regulatory_Authorization_Type__r.Issuing_Department_Name__c;
					ratName = parList[0].Regulatory_Authorization_Type__r.Name;
					if(applicationType == 'Individual' || ratName == 'Pre-licensure Petition'){
						ADDRESS_FIELD_OPTIONS = ADDRESS_FIELD_OPTIONS_INDIVIDUAL;
					}else{
						ADDRESS_FIELD_OPTIONS = ADDRESS_FIELD_OPTIONS_BUSINESS;
					}
				}
			}
			//Added for issue I-250995
			String addressTypeMetadataFields = 'Id,Address_Type__c,Address_Type_Picklist_Value__c,Application_Type__c,Board_Name__c';
			List<LPI_Address_Picklist_value__mdt> allConfiguration = new List<LPI_Address_Picklist_value__mdt>();
			//First fetch mdt based on RAT Name
			allConfiguration = LPI_CustomMetadataTypeDAO.getCustomMetaDataByDymanicQuery(addressTypeMetadataFields,'LPI_Address_Picklist_value__mdt','Application_Type__c = \''+String.escapeSingleQuotes(applicationType)+'\''+' AND Regulatory_Authorization_Type_Name__c=\''+String.escapeSingleQuotes(ratName)+'\''+' AND Address_Type__c = \''+String.escapeSingleQuotes(addressType)+'\'' ,null,null,null);
			//If no mdt rec found based on RAT Name configuration then we use mdt rec based on board name if there are any
			//The RAT Name field should be null to fetch record for board level.
			if(allConfiguration.isEmpty() && boardName != null){
				allConfiguration = LPI_CustomMetadataTypeDAO.getCustomMetaDataByDymanicQuery(addressTypeMetadataFields,'LPI_Address_Picklist_value__mdt','Application_Type__c = \''+String.escapeSingleQuotes(applicationType)+'\''+' AND Board_Name__c=\''+String.escapeSingleQuotes(boardName)+'\''+' AND Address_Type__c = \''+String.escapeSingleQuotes(addressType)+'\''+' AND Regulatory_Authorization_Type_Name__c = NULL' ,null,null,null);
			}

			if(!allConfiguration.isEmpty())
			{
				for(LPI_Address_Picklist_value__mdt rec : allConfiguration)
				{		
					picklistValue = rec.Address_Type_Picklist_Value__c;
				}
				if(picklistValue != null && picklistValue != '')
				{
					addressFieldOptions = (Map<String,Object>) JSON.deserializeUntyped(picklistValue);
				}
				accList = new List<Map<String, Object>>();
				for (String key : addressFieldOptions.keySet()) {
					Map<String, Object> accMap = new Map<String, String>();
					accMap.put('value', (String)addressFieldOptions.get(key));
					accMap.put('label', key);
					accList.add(accMap);
				}
				
			}else{
				accList = new List<Map<String, Object>>();
				for (String key : ADDRESS_FIELD_OPTIONS.keySet()) {
					Map<String, Object> accMap = new Map<String, String>();
					accMap.put('value', (String)ADDRESS_FIELD_OPTIONS.get(key));
					accMap.put('label', key);
					accList.add(accMap);
				}
			}
		} 
		catch (Exception e) {
			LPI_ExceptionManager.logException('LPI_OverrideAddressType', 'picklistValueOfAddressField', e);
		}	
        return accList;	
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
    public static String fetchSavedAddressFieldOnReload(String parId , String addressType) {
		String result;
        try{
			List<PreliminaryApplicationRef> parList = new List<PreliminaryApplicationRef>();
			
			if(String.isNotBlank(parId))
			{
				parList = new LPI_PreliminaryApplicationRefDAO.LPI_PreliminaryApplicationRefWithoutSharingDAO().getPreliminaryApplicationRefByDymanicQuery(
					'Id,Primary_Contact_Address__c,License_Address__c,Publicly_Displayed_Address__c',
					'Id = \''+parId+'\'',
					null,
					null,
					null
				);
				if(!parList.isEmpty()){
					if(addressType == PRIMARY_CONTACT_ADDRESS)
					{
						result = parList[0].Primary_Contact_Address__c;
					}
					else if(addressType == LICENSE_ADDRESS)
					{
						result = parList[0].License_Address__c;
					}
					else if(addressType == PUBLICLY_DISPLAYED_ADDRESS) 
					{
						result = parList[0].Publicly_Displayed_Address__c;
					}
				}
			}
		} 
		catch (Exception e) {
			LPI_ExceptionManager.logException('LPI_OverrideAddressType', 'fetchSavedAddressFieldOnReload', e);
		}	
        return result;	
    }
}