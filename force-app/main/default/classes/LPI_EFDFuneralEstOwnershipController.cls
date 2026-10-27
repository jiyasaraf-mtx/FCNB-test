/**
 * @description    : This class  managing the Ownership Details Records. It has methods to fetch and delete Ownership records.
 * @author         : MTX Group Product Team
 * -------------------------------------------------------------------------------------------------------
 * Version      Date                Author                  Details
 *    1         14 Mar, 2023        MTX Group Product Team		    Initial Developement
 * -------------------------------------------------------------------------------------------------------
 *
 **/
global with sharing class LPI_EFDFuneralEstOwnershipController implements Callable {
    // *************************************** ALL CONSTANTS ************************************************
    private final static String FETCH_OWNERSHIP_DETAILS = 'fetchOwnershipDetails';
    private final static String DELETE_OWNERSHIP = 'deleteOwnership';
    private final static String CLASS_NAME = 'LPI_EFDFuneralEstOwnershipController';
    public final static String OWNER_ROLE = 'Owner';
    // ********************************************************************************************************

    global Object call(String action, Map<String, Object> args) {
        Map<String, Object> input = (Map<String, Object>) args.get('input');
        Map<String, Object> output = (Map<String, Object>) args.get('output');
        Map<String, Object> options = (Map<String, Object>) args.get('options');

        return invokeMethod(action, input, output, options);
    }
    private Boolean invokeMethod(
        String methodName,
        Map<String, Object> inputMap,
        Map<String, Object> outMap,
        Map<String, Object> options
    ) {
        Boolean result = true;
        try {
            if (methodName.equals(FETCH_OWNERSHIP_DETAILS)) {
                fetchOwnershipDetails(inputMap, outMap);
            } 
            // else if (methodName.equals(DELETE_OWNERSHIP)) {
            //     deleteOwnership(inputMap, outMap, options);
            // } 
            else {
                result = false;
            }
        } catch (Exception e) {
            LPI_ExceptionManager.logException(CLASS_NAME, 'invokeMethod', e);
            result = false;
        }
        return result;
    }
    /**
     * @description       	  : This method will call from the invoke method and used to return Ownership Information to the OS
     * @author         		  : MTX Group Product Team
     * @param inputMap 		  : Map of input parameters
     * @param outMap 		  : Map of output parameters
     * @lastModifiedBy 		  : Add if modified by you
     * @last modified details : Add if modified by you
     */
    public static void fetchOwnershipDetails(
        Map<String, Object> inputMap,
        Map<String, Object> outMap
    ) {
        try {
            List<Map<String, Object>> responseDataList = new List<Map<String, Object>>();
            String parId = (String) inputMap.get('parid');
             
            if (String.isNotEmpty(parId))  {
                List<PreliminaryApplicationRef> parDataList = new List<PreliminaryApplicationRef>();
                String parStringToQuery = 'Id, BusinessAccountNameId,Contact__r.AccountId';
                String whereClause =
                    'Id = \'' +
                    String.escapeSingleQuotes(parId) +
                    '\'';
                
                //Retrieve Account ID from Preliminary Application Reference
                parDataList = LPI_PreliminaryApplicationRefDAO.getPreliminaryApplicationRefByDymanicQuery(
                    parStringToQuery,
                    whereClause,
                    null,
                    null,
                    null
                );
                
                // Check if parList is empty or not
                if (parDataList.size() > 0) {
                    whereClause = '';
                    whereClause +=  ' Related_From__c = \'' + String.escapeSingleQuotes(parDataList[0].BusinessAccountNameId) + '\'';
                    whereClause += ' AND Roles__c = \'' + String.escapeSingleQuotes(OWNER_ROLE) + '\'';
                    whereClause += ' AND IsActive__c = true';
                    whereClause += ' AND If_Relationship_is_Associated_with_you__c = true';

                    //using without sharing to fetch ACRs as the Account sharing is private
                    LPI_BusinessRelationshipDAO.LPI_BusinessRelationshipsWithoutSharingDAO withoutSharingACR =
                        new LPI_BusinessRelationshipDAO.LPI_BusinessRelationshipsWithoutSharingDAO();
                    
                    for(Business_Relationships__c br : withoutSharingACR.getBusinessRelationshipsByDymanicQuery(
                        'Id,Name,Related_To__r.Name,Related_To__c,License_Type__c, Title__c,If_Relationship_is_Associated_with_you__c, '+
                        'Related_To__r.FirstName, Related_To__r.MiddleName, Related_To__r.LastName,Ownership_Percent__c,Related_To__r.RecordType.DeveloperName, ' +
                        'Related_To__r.PersonOtherStreet, Related_To__r.PersonOtherCity, Related_To__r.PersonOtherState, Related_To__r.PersonOtherPostalCode, Related_To__r.BillingStreet, Related_To__r.BillingCity, Related_To__r.BillingState, Related_To__r.Other_State__c, Related_To__r.BillingPostalCode, Related_To__r.County__c, Related_To__r.BillingCountry, Related_To__r.PersonOtherCountry',
                        whereClause,
                        null,
                        null,
                        null)){
                           
                            Map<String, Object> responseDataMap = new Map<String, Object>();
                            responseDataMap.put('Id', br.Id);
                            responseDataMap.put('Name', br.Related_To__r.Name);
                            responseDataMap.put('OwnershipPercentage', br.Ownership_Percent__c);
                            responseDataMap.put('County', br.Related_To__r.County__c);
                            if(br.Related_To__r.RecordType.DeveloperName == 'PersonAccount'){
                                responseDataMap.put('Street', br.Related_To__r.PersonOtherStreet);
                                responseDataMap.put('State', String.isNotBlank(br.Related_To__r.PersonOtherState) ? br.Related_To__r.PersonOtherState : br.Related_To__r.Other_State__c);
                                responseDataMap.put('City', br.Related_To__r.PersonOtherCity);
                                responseDataMap.put('ZipCode', br.Related_To__r.PersonOtherPostalCode);
                                responseDataMap.put('Country', br.Related_To__r.PersonOtherCountry);
                            }else{
                                responseDataMap.put('Street',br.Related_To__r.BillingStreet);
                                responseDataMap.put('State', String.isNotBlank(br.Related_To__r.BillingState) ? br.Related_To__r.BillingState : br.Related_To__r.Other_State__c);
                                responseDataMap.put('City', br.Related_To__r.BillingCity);
                                responseDataMap.put('ZipCode', br.Related_To__r.BillingPostalCode);
                                responseDataMap.put('Country', br.Related_To__r.BillingCountry);
                            }

                            String address =responseDataMap.get('Street')+', '+ responseDataMap.get('City')+', '+ responseDataMap.get('State') +', ' + responseDataMap.get('Country') +', '+ responseDataMap.get('ZipCode');
                            address+= br.Related_To__r.County__c == NULL ? '': ', '+br.Related_To__r.County__c;
                            responseDataMap.put('Address',address);

                            responseDataList.add(responseDataMap);
						}                  
                    }
            }
            outMap.put('OwnershipInfoBlock', responseDataList);
        } catch (Exception e) {
            LPI_ExceptionManager.logException(
                CLASS_NAME,
                FETCH_OWNERSHIP_DETAILS,
                e
            );
        }
    }

}