/**
 * @author              : HITEN AGGARWAL
 * @since               : 25th Jan, 2023
 * @description         : This Class will be used to write down generic and reuseable code for Vlocity, Omnistudio
 * @history
 * -------------------------------------------------------------------------------------------------------
 * Version      Date                Author                  Details
 *    1         25th Jan, 2023      HITEN AGGARWAL        	Initial Developement
 * -------------------------------------------------------------------------------------------------------
 */
public with sharing class LPI_VlocityUtility {
	private static final String TYPE_STRING = 'STRING';
	private static final String TYPE_URL = 'URL';
    private static final Set<String> SET_OF_NAME_FIELDS = new Set<String>{
        'FirstName', 'MiddleName', 'LastName', 'MiddleName__c', 
        'FirstName__c', 'LastName__c',  'MaidenName__c','Suffix'
    };
    private static final Set<String> SET_OF_SOBJECT_NAME_FOR_UPDATE_NAME = new Set<String>{
        'Account', 'PreliminaryApplicationRef'
    };
	/**
	 * @author                      : HITEN AGGARWAL
	 * @since                       : 25th Jan, 2023
	 * @description                 : Sobject Field Map and return SObject
	 * @param inputMap           	: Take map of input, that come from omniscript
	 * @param keyMaping       		: Map of key on input map and field api name
	 * @return                      : `SObject`
	 * @last modified by            : Ayush Dev
	 * @last modified date          : 15th Feb, 2023
	 * @modified details            : -
	 */
	public static SObject createSObject(
		Map<String, Object> inputMap,
		Map<String, String> keyMaping,
		String sObjectName
	) {
		SObject record;
		try{	
			SObjectType objectType = LPI_UtilityDescribe.globalDescribe.get(sObjectName);
			record = objectType.newsObject();
			JSONParser parser;
			String fieldName = '';
			//Loop on set of keys in input map ( To map the value in the SObject, Map)
			for (String str : inputMap.keySet()) {
				//Check if key is present in keyMaping or not
				if (keyMaping.containsKey(str)) {
					fieldName = keyMaping.get(str);
					String typeValue = LPI_UtilityDescribe.globalDescribe.get((String) sObjectName)
						.getDescribe()
						.fields.getMap()
						.get((String) fieldName)
						.getDescribe()
						.getType()
						.name();
					/*if (inputMap.get(str) != null) {
						//parser = JSON.createParser('{"":"' + inputMap.get(str) + '"}');
						parser.nextToken();
						parser.nextValue();
					}*/
					//To check if sf support the type
					if (System.Type.forName(typeValue) == null || typeValue == TYPE_URL) {
						typeValue = TYPE_STRING;
					}
					if (inputMap.get(str) != null) {
						/*Object fieldValue = parser.readValueAs(System.Type.forName(typeValue));
						if(SET_OF_SOBJECT_NAME_FOR_UPDATE_NAME.contains(sObjectName) && SET_OF_NAME_FIELDS.contains(fieldName)) {
							fieldValue = updateStringToCamelCase((String)fieldValue);
						}
						record.put(fieldName, fieldValue);*/
					} else {
						record.put(fieldName, null);
					}
				}
			}
		}
		catch(Exception e){
			LPI_ExceptionManager.logException('LPI_VlocityUtility', 'createSObject', e);
		}
		return record;
	}

	/**
	 * @author                      : HITEN AGGARWAL
	 * @since                       : 25th Jan, 2023
	 * @description                 :
	 * @param timeValue           	:
	 * @return                      : `Time`
	 * @last modified by            : Ayush Dev
	 * @last modified date          : -
	 * @modified details            : -
	 */
	// public static Time convertObjectToTime(Object timeValue) {
	// 	String objectTime = (String) timeValue;
	// 	String[] strTimeSplit = objectTime.split(':');
	// 	Time timeConvertedValue = Time.newInstance(
	// 		Integer.valueOf(strTimeSplit.size() > 0 ? strTimeSplit[0] : '0'), //hour
	// 		Integer.valueOf(strTimeSplit.size() > 1 ? strTimeSplit[1] : '0'), //min
	// 		0,
	// 		0
	// 	);
	// 	return timeConvertedValue;
	// }

    /**
	 * @author                      : Rachna Jadam
	 * @since                       : 29 Mar, 2023
	 * @description                 : This Method convert name in Camel case(Eg.: Convert RAchna jadam to Rachna Jadam)
	 * @param name           	    : input name
	 * @return                      : String
	 * @last modified by            : Ayush Dev
	 * @last modified date          : -
	 * @modified details            : -
	 */
    public static String updateStringToCamelCase(String name) {
        if(String.isEmpty(name)) {
            return null;
        }
        String updatedName = '';
        for(String nameSubString : name.split(' ')) {
            updatedName += nameSubString?.toLowerCase()?.capitalize() + ' ';
        }
        return updatedName.trim();
    }

}