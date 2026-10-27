/**
 * @author      : Kriti Gupta
 * @since       : 15 April, 2024
 * @description : This Class Contains methods which are used Request Detail Step
 *  -------------------------------------------------------------------------------------------------------
 * Version      Date                Author                  Details
 *    1      15 April, 2024      Kriti Gupta             Initial Developement
 * -------------------------------------------------------------------------------------------------------
 */
global with sharing class LPI_RequestDetailsController implements Callable{

    // *************************************** ALL CONSTANTS ************************************************
    public final static String CLASS_NAME = 'LPI_RequestDetailsController';
    public final static String INVOKE_METHOD = 'invokeMethod';
    public final static String FETCH_OPERATOR_LICENSES = 'fetchOperatorLicenses';
    public final static String FETCH_APPLICANT_REFERENCES = 'fetchApplicantReferences';
    public final static String SAVE_APPLICANT_REFERENCES = 'saveApplicantReferences';
    public final static String DELETE_APPLICANT_REFERENCES = 'deleteApplicantReferences';
    public final static String SECTION_HEADER = 'Certification of Licensure Request Detail';
    

    global Object call(String action, Map<String, Object> args) {
		Map<String, Object> input = (Map<String, Object>) args.get('input');
		Map<String, Object> output = (Map<String, Object>) args.get('output');
		Map<String, Object> options = (Map<String, Object>) args.get('options');
		return invokeMethod(action, input, output, options);
	}

    /**
	 * @description This Method is Used to Internally call the invokeMethod.
	 * @author Kriti Gupta
	 * @param action
	 * @param args
	 * @return Object
	 **/
    private Boolean invokeMethod(String methodName, Map<String, Object> inputMap, Map<String, Object> outMap, Map<String, Object> options) {
        Boolean result = true;
        try {
            if(methodName.equalsIgnoreCase(FETCH_APPLICANT_REFERENCES)) {
                fetchApplicantReferences(inputMap, outMap);
            } else if(methodName.equalsIgnoreCase(SAVE_APPLICANT_REFERENCES)){
                saveApplicantReferences(inputMap, outMap);
            } else if(methodName.equalsIgnoreCase(DELETE_APPLICANT_REFERENCES)){
                deleteApplicantReferences(inputMap);
            }
        } catch (Exception e) {
            LPI_ExceptionManager.logException(CLASS_NAME, INVOKE_METHOD, e);
            result = false;
        }
        return result;
    }

    /**
	 * @author                    : Kriti Gupta
	 * @description               : fetching request detail info
	 * @param inputMap            : fetching all the input from Omniscript
	 * @param outMap              : Passing value to Omniscript
	 * @since                     : 15 April, 2024
	 * @return                    : `void`
	 * @last modified by          : MTX Group Inc
	 * @last modified date        : 
	 */
    public static void fetchApplicantReferences(Map<String, Object> inputMap, Map<String, Object> outMap) {  
        try{
            String parId = (String) inputMap.get('parId');
            if(!String.isEmpty(parId)){
                List<Map<String, Object>> licenseList = new List<Map<String, Object>>();
                List<Map<String, Object>> licenseListPDF = new List<Map<String, Object>>();
                String fieldsToQuery = 'Id, License_Number__c, First_Name__c, Street_1__c, State__c, City__c, Zip_Code__c, Phone_Number__c, Applicant_Reference_Type__c,' +
                                       'Certification_Sent_To__c, Certification_Delivery_Option__c, Email__c, Fax_Number__c, Additional_Details__c, Country__c,'+
                                       'Do_you_require_board_to_include_cert__c';
                String whereCaluseToQuery = ' Preliminary_Application_Reference__c= \'' + parId + '\'' + ' AND Section_Header__c = \'' + SECTION_HEADER + '\'';
                List<Application_Content__c> appContent = LPI_ApplicationContentDAO.getApplicationContentByDymanicQuery(
                    fieldsToQuery,
                    whereCaluseToQuery,
                    null,
                    null,
                    null
                );
                Map<String, Id> blNameToAppConId = new Map<String, Id>();
                Integer applicantCount = 1;
                for(Application_Content__c appCon : appContent){
                        Map<String, Object> perReferenceMap = new Map<String, Object>();
                        Map<String, Object> appConMap = new Map<String, Object>();
                        perReferenceMap.put('recordId',appCon.Id);
                        perReferenceMap.put('Certification_Send_To',appCon.Certification_Sent_To__c);
                        perReferenceMap.put('Require_the_board_to_include_School__c',appCon.Do_you_require_board_to_include_cert__c);
                        perReferenceMap.put('Choose_the_Certification_Delivery_option__c1',appCon.Certification_Delivery_Option__c);
                        perReferenceMap.put('Choose_the_Certification_Delivery_option__c',appCon.Certification_Delivery_Option__c);
                        perReferenceMap.put('Certification_Email__c',appCon.Email__c);
                        perReferenceMap.put('Fax_Number__c',appCon.Fax_Number__c);
                        perReferenceMap.put('Please_Specify_if_you_need_any_more_data__c',appCon.Additional_Details__c);
                        perReferenceMap.put('Additional_Comments',appCon.Additional_Details__c);

                        Map<String, Object> typeAheadMap = new Map<String, Object>();
                        typeAheadMap.put('StreetAddress',appCon.Street_1__c);
                        typeAheadMap.put('City',appCon.City__c);
                        typeAheadMap.put('StatePicklist',appCon.State__c);
                        typeAheadMap.put('StateText',appCon.State__c);
                        typeAheadMap.put('Country',appCon.Country__c);
                        typeAheadMap.put('ZipCode',appCon.Zip_Code__c);
                        perReferenceMap.put('PostalAddressBlock', typeAheadMap);
                        perReferenceMap.put('ApplicantReference', 'Applicant Reference '+ applicantCount);
                        perReferenceMap.put('ReferenceType',appCon.Applicant_Reference_Type__c);
                        appConMap.put('recordId',appCon.Id);
                        appConMap.put('ApplicantReferenceType',appCon.Applicant_Reference_Type__c);
                        licenseList.add(appConMap); 
                        licenseListPDF.add(perReferenceMap);
                        applicantCount++;
                }
                if(!licenseList.isEmpty()){
                    outMap.put('RequestDetailsEditBlock', licenseListPDF);
                }
            }
        } catch(Exception e){
            LPI_ExceptionManager.logException(
                CLASS_NAME,
                FETCH_APPLICANT_REFERENCES,
                e
            );
        }
    }

    /**
	 * @author                    : Kriti Gupta
	 * @description               : saving request detail records in application content object
	 * @param inputMap            : fetching all the input from Omniscript
	 * @param outMap              : Passing value to Omniscript
	 * @since                     : 15 April, 2024
	 * @return                    : `void`
	 * @last modified by          : MTX Group Inc
	 * @last modified date        : 
	 */
    public static void saveApplicantReferences(Map<String, Object> inputMap, Map<String, Object> outMap) {
        try{
            String parId = (String) inputMap.get('parId');
            String recordId = (String) inputMap.get('recordId');
            if(!String.isEmpty(parId)){
                Application_Content__c appcon = new Application_Content__c();
                appcon.Id = recordId;
                appcon.Preliminary_Application_Reference__c=parId;
                appcon.Section_Header__c = 'Certification of Licensure Request Detail';
                appcon.Certification_Sent_To__c = (String)inputMap.get('Certification_Send_To');
                appcon.Do_you_require_board_to_include_cert__c = (String)inputMap.get('Require_the_board_to_include_School__c');
                appcon.Certification_Delivery_Option__c = (String)inputMap.get('Choose_the_Certification_Delivery_option__c1')!=null?
                                                            (String)inputMap.get('Choose_the_Certification_Delivery_option__c1') : 
                                                            (String)inputMap.get('Choose_the_Certification_Delivery_option__c');
                appcon.Email__c =(String)inputMap.get('Certification_Email__c');
                appcon.Fax_Number__c = (String)inputMap.get('Fax_Number__c');
                appcon.Additional_Details__c = (String)inputMap.get('Please_Specify_if_you_need_any_more_data__c')!=null?
                                                (String)inputMap.get('Please_Specify_if_you_need_any_more_data__c') : 
                                                (String)inputMap.get('Additional_Comments');
                Map<String, Object> postalAddressBlock = (Map<String, Object>) inputMap.get('PostalAddressBlock');
                if(postalAddressBlock!=null && !postalAddressBlock.isEmpty()){
                    appcon.Street_1__c =(String)postalAddressBlock.get('StreetAddress') ;
                    appcon.City__c =(String)postalAddressBlock.get('City') ;
                    appcon.State__c =(String)postalAddressBlock.get('StatePicklist')!=null?
                                        (String)postalAddressBlock.get('StatePicklist') : 
                                        (String)postalAddressBlock.get('StateText');
                    appcon.Country__c =(String)postalAddressBlock.get('Country') ;
                    appcon.Zip_Code__c =(String)postalAddressBlock.get('ZipCode') ;
                }
                appcon = (Application_Content__c)  LPI_DML.doUpsert(appcon);
                outMap.put('recordId', appcon.Id);

            }
        }catch(Exception e){
            LPI_ExceptionManager.logException(
                CLASS_NAME,
                SAVE_APPLICANT_REFERENCES,
                e
            );
        }
    }

    /**
	 * @author                    : Kriti Gupta
	 * @description               : deleting request detail record
	 * @param inputMap            : fetching all the input from Omniscript
	 * @param outMap              : Passing value to Omniscript
	 * @since                     : 15 April, 2024
	 * @return                    : `void`
	 * @last modified by          : MTX Group Inc
	 * @last modified date        : 
	 */
    public static void deleteApplicantReferences(Map<String, Object> inputMap) {
        try{
            String appContentId = (String) inputMap.get('recordId');
            if(!String.isEmpty(appContentId)){
                List<Application_Content__c> appContentList = LPI_ApplicationContentDAO.getApplicationContentByDymanicQuery(
                    'Id',
                    'Id = \'' + appContentId + '\'',
                    null,
                    null,
                    null
                ); 
                if(!appContentList.isEmpty()){
                    LPI_WithoutSharingUtility.deleteSObject(appContentList);
                }
            }
            
        }  catch(Exception e){
            LPI_ExceptionManager.logException(
                CLASS_NAME,
                DELETE_APPLICANT_REFERENCES,
                e
            );
        }
    }

}