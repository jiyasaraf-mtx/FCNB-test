/** 
* @author                      : Sukanya 
* @since                       : June 8th, 2023   
* @description                 : This class contains the business logic for all Chiropractic physician license flows 
*------------------------------------------------------------------------------------------------------- 
* Version      Date                Author                  Details 
*    1         June 8th, 2023      Sukanya                 Initial Developement 
* ------------------------------------------------------------------------------------------------------- 
*/ 
global class LPI_LawfulPresenceCitizenshipInfo implements Callable{ 
    // ********************************************** CONSTANTS ******************************************** 
    private static final String CLASS_NAME = 'LPI_LawfulPresenceCitizenshipInfo'; 
    private static final String INVOKE_METHOD = 'invokeMethod';  
    private static final String FETCH_CITIZENSHIP_DETAILS = 'fetchCitizenshipDetails';
    private static final String SAVE_CITIZENSHIP_DETAILS = 'saveCitizenshipDetails';
    private static final String TYPE_NEW = 'New';
    private static final String UNITED_STATES = 'UNITED STATES';
    private static final String FOREIGN = 'Foreign';
    private static final String NATURALIZATION = 'Naturalization';
    private static final String VISA_PERMIT = 'Visa with stamped date of US entry';
    private static final String RESIDENT_CARD = 'US Permanent Resident Card';
    private static final String STUDENT_VISA = 'F-1 Student Visa';
    private static final String RESIDENT_CARD_EXPIRED = 'Permanent Resident Card Expired - Extension Granted';
    private static final String ACCOUNTID ='accountId';
    private static final String IS_NEW_APPLICATION = 'isNewApplication';
    private static final String PERSONAL_INFORMATION = 'PersonalInformation';
    private static final String OBJECT_ACCOUNT = 'Account';
    private static final String PARID = 'parid';
    private static final String HB_VISA = 'H1B Visa';
    private static final String PERSONAL_INFORMATION_AMENDMENT = 'PersonalInformationNameAmendment2';
    private static final String IS_AMENDMENT = 'isAmendment';
    private static final Set<String> US_RESIDENTS_SET = new Set<String>{
        RESIDENT_CARD, RESIDENT_CARD_EXPIRED
    };
    private static final Set<String> VISA_PERMIT_SET = new Set<String>{
        VISA_PERMIT, HB_VISA
    };
    private static final String VALUE_YES = 'Yes';
    private static final String VALUE_NO = 'No';
    private static final String VALUE_NA = 'NA';
    private static final String OBJECT_PAR = 'PreliminaryApplicationRef';
    // ****************************************************************************************************** 
     
    /** 
     * @author                      : Ambati Sukanya 
     * @since                       : June 8th, 2023   
     * @description                 : This method calls invoke method 
     * @param action                : String  
     * @param args                  : Map<String, Object> 
     * @return                      : Object 
     * @last modified by            : MTX Group Inc
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
    * @author                      : Sukanya 
    * @since                       : June 8th, 2023 
    * @description                 : This method invokes methods which are used as remote methods in
    *                                PersonalInformationForLawfulPresence Information OS                                                                    
    * @param methodName 	       : String method name 
	* @param inputMap		       : Map<String, Object> input map from OS 
	* @param outMap 		       : Map<String, Object> 
	* @param options 		       : Map<String, Object> 
    * @return                      : Boolean 
    * @last modified by            : MTX Group Inc
    * @last modified date          :  
    * @modified details            :  
    */ 
 private Boolean invokeMethod( 
        String methodName, 
        Map<String, Object> inputMap, 
        Map<String, Object> outMap, 
        Map<String, Object> options 
    ) { 
        Boolean result = false; 
        try { 
            if (FETCH_CITIZENSHIP_DETAILS.equalsIgnoreCase(methodName)) { 
                fetchCitizenshipDetails(inputMap,outMap); 
            } 
            if (SAVE_CITIZENSHIP_DETAILS.equalsIgnoreCase(methodName)) { 
                saveCitizenshipDetails(inputMap);
                LPI_PersonalInfo.lawfulPresenceDocConfiguration((String) inputMap.get(PARID),(String) options.get('DocumentRequiredJSON')); 
            }        
        } catch (Exception e) { 
            result = false; 
            LPI_ExceptionManager.logException(CLASS_NAME, INVOKE_METHOD, e); 
        } 
        return result; 
    } 
 
     /**
    * @author                      : Sukanya  
    * @since                       : June 8th, 2023 
    * @description                 : This method updates the Account with citizenship details
	* @param inputMap		       : Map<String, Object> input map from OS 
    * @return                      : Void
    * @last modified by            : MTX Group Inc
    * @last modified date          :  
    * @modified details            :  
     */
   private static void saveCitizenshipDetails(Map<String, Object> inputMap)
    {
        try{
            String accountId = (String)inputMap.get(ACCOUNTID);
            String parId = (String)inputMap.get(PARID);
            if(String.isBlank(accountId)){
                if(String.isNotBlank(parId)){
                    List<PreliminaryApplicationRef> parList =  LPI_PreliminaryApplicationRefDAO.getPARRecordsByID(new Set<Id>{ parId });
                    accountId = parList[0]?.BusinessAccountNameId;
                }
                else{
                    return;
                }
            }       
            Boolean isAmendment = false;
            if(inputMap.containsKey(IS_AMENDMENT)){
                isAmendment = true;
            }
            Map<String, Object> personalInformation = new Map<String, Object>();
            Map<String, Object> editBlockDetails = new Map<String, Object>();
            editBlockDetails = (Map<String, Object>) inputMap.get(PERSONAL_INFORMATION_AMENDMENT);
            String citizenShip;
            String proofOfCitizenship;
            String proofOfWorkPermit;
            if(!editBlockDetails.isEmpty() && isAmendment !=null)
            {
                Boolean isEdit = isAmendment != null ? isAmendment : false;
                //getting the inside block based on application type
                if(editBlockDetails != null)
                {
                    //getting citizenship and related values from inside block
                    citizenShip = (String) editBlockDetails.get('CitizinshipStatusLawful');
                    proofOfCitizenship = (String) editBlockDetails.get('ProofOfCitizenshipIfUSLawful');
                    proofOfWorkPermit = (String) editBlockDetails.get('ProofOfCitizenshipIfForeignLawful');
                    //key mapping for new and amendment applications
                    Map<String, String> acckeyMaping = new Map<String, String>{
                        'UCSICNumberLawful' => 'USCIS_Number__c',
                        'NaturalizationNumberLawful' => 'Naturalization_Number__c',
                        'VISANumberLawful' => 'VISA_Number__c',
                        'PassportCountryLawful' => 'Passport_Country__c',
                        'PassportNumberLawful' => 'Passport_Number__c',
                        'USResidentCardNumberLawful' => 'US_Permanent_Resident_Card_Number__c',
                        //'USCISNumberLawful' => 'USCIS_Number__c',
                        'StudentPassportCountryLawful' => 'Passport_Country__c',
                        'StudentPassportNumberLawful' => 'Passport_Number__c',
                        'StudentSevisIDLawful' => 'SEVIS_ID__c',
                        //'StudentI94NumberLawful' => 'I_94_Number__c',
                        'USResidentCardNumberExpired' => 'US_Permanent_Resident_Card_Number__c',
                        'USCISNumberExpired' => 'USCIS_Number__c',
                        'H1BVisaNumberLawful' => 'H1B_Visa_Number__c'
                    };
                    Map<String, Object> childBlockDetails = new Map<String, Object>();
                    PreliminaryApplicationRef acc = new PreliminaryApplicationRef();
                    //setting values for US citizenship
                    if(citizenShip == UNITED_STATES)
                    {
                        if(!proofOfCitizenship.equalsIgnoreCase(NATURALIZATION)){
                        }
                        else{
                            childBlockDetails =(Map<String, Object>) editBlockDetails.get('POCIfNaturalizationBlockLawful');
                            acc =  
                                (PreliminaryApplicationRef) LPI_VlocityUtility.createSObject(childBlockDetails, acckeyMaping, OBJECT_PAR);
                        }
                        acc.Proof_of_Citizenship__c = proofOfCitizenship;
                        //clearing out the values if the citizenship value is changed
						//acc.Proof_of_work_permit_in_United_States__c = '';
						//acc.H1B_Visa_Number__c = '';
						//acc.VISA_Number__c = '';
						//acc.US_Permanent_Resident_Card_Number__c = '';
						//acc.SEVIS_ID__c  = '';
						//acc.I_94_Number__c = '';
						//acc.Passport_Country__c = '';
						//acc.Passport_Number__c  = '';
                    }
                    //setting values for foreign citizenship
                    else if(citizenShip == FOREIGN)
                    {
                        if(String.isNotBlank(proofOfWorkPermit)){
                            //setting the child blocks based on the work permit value
                            if(VISA_PERMIT_SET.contains(proofOfWorkPermit))
                            {
                                
                                childBlockDetails = (Map<String, Object>) editBlockDetails.get('VisaBlock');
                                acc.US_Permanent_Resident_Card_Number__c = '';
                                acc.USCIS_Number__c = '';
                                acc.SEVIS_ID__c  = '';
                                //acc.I_94_Number__c = '';
                            }
                            else if(US_RESIDENTS_SET.contains(proofOfWorkPermit))
                            {
                                childBlockDetails = (Map<String, Object>) editBlockDetails.get('ResidentBlock');
                                acc.SEVIS_ID__c  = '';
                                //acc.I_94_Number__c = '';
                                //acc.Passport_Country__c = '';
                                acc.Passport_Number__c  = '';
                                acc.H1B_Visa_Number__c = '';
                                acc.VISA_Number__c = '';
                            }
                            else if(proofOfWorkPermit.equalsIgnoreCase(STUDENT_VISA))
                            {
                                childBlockDetails =(Map<String, Object>) editBlockDetails.get('StudentVisaBlock');
                                acc.H1B_Visa_Number__c = '';
                                acc.VISA_Number__c = '';
                                acc.US_Permanent_Resident_Card_Number__c = '';
                                acc.USCIS_Number__c = '';
                            }
                            //creating Account Instance
                            acc =  
                                (PreliminaryApplicationRef) LPI_VlocityUtility.createSObject(childBlockDetails, acckeyMaping, OBJECT_PAR);
                            acc.Proof_of_work_permit_in_United_States__c = proofOfWorkPermit;
                            acc.Proof_of_Citizenship__c = '';
                            acc.Naturalization_Number__c = '';
                            //acc.Citizenship_Number__c = '';
                        }
                    }
                    //updating the account
                    acc.Id = parId;
                    //acc.Citizenship__c = citizenShip;
                    LPI_WithoutSharingUtility.updateSObject(acc);
                }
            }
        }
        catch (Exception e) { 
           LPI_ExceptionManager.logException( 
              CLASS_NAME, 
              SAVE_CITIZENSHIP_DETAILS, 
               e 
            ); 
        }         
    }
    /**
    * @author                      : Sukanya  
    * @since                       : June 8th, 2023 
    * @description                 : This method updates the Account with citizenship details
	* @param inputMap		       : Map<String, Object> input map from OS 
    * @return                      : Void
    * @last modified by            : MTX Group Inc
    * @last modified date          :  
    * @modified details            :  
    */
    private static void fetchCitizenshipDetails(Map<String, Object> inputMap, Map<String, Object> outMap)
    {
        try{
            String parId = (String)inputMap.get(PARID);
            String parFields = 'Id, BusinessAccountNameId, BusinessAccountName.Citizenship__c, BusinessAccountName.Proof_of_work_permit_in_United_States__c, ' +
            'BusinessAccountName.Proof_of_Citizenship__c, BusinessAccountName.USCIS_Number__c, BusinessAccountName.Naturalization_Number__c, BusinessAccountName.VISA_Number__c, ' +
            'BusinessAccountName.US_Permanent_Resident_Card_Number__c, BusinessAccountName.Passport_Number__c, BusinessAccountName.SEVIS_ID__c, ' +
            'BusinessAccountName.I_94_Number__c, BusinessAccountName.H1B_Visa_Number__c, BusinessAccountName.Passport_Country__c, ' +
            'Proof_of_work_permit_in_United_States__c, ' +
            'Proof_of_Citizenship__c, USCIS_Number__c, Naturalization_Number__c, VISA_Number__c, ' +
            'US_Permanent_Resident_Card_Number__c, Passport_Number__c, SEVIS_ID__c, ' +
            'H1B_Visa_Number__c';
            Boolean isNewApplication = (Boolean)inputMap.get(IS_NEW_APPLICATION);
            String parWhereClause;
            List<PreliminaryApplicationRef> parList = new List<PreliminaryApplicationRef>();
            if(String.isNotBlank(parId)){
                parWhereClause = 'Id = \'' + String.escapeSingleQuotes(parId) + '\'';
                //querying par to get accountId
                parList = 
                    LPI_PreliminaryApplicationRefDAO.getPreliminaryApplicationRefByDymanicQuery(
                        parFields,
                        parWhereClause,
                        null,
                        null,
                        null
                    );
            }
            if(!parList.isEmpty())
            {
                Map<String, String> countryCodeToLabelMap = new Map<String, String>();
                Schema.DescribeFieldResult fieldResult = Account.Passport_Country__c.getDescribe();
                List<Schema.PicklistEntry> values = fieldResult.getPicklistValues();
                for( Schema.PicklistEntry v : values) {
                   countryCodeToLabelMap.put(v.getValue(), v.getLabel());
                }
                String proofOfWorkPermit =  String.isNotBlank(parList[0].Proof_of_work_permit_in_United_States__c) ? parList[0].Proof_of_work_permit_in_United_States__c : parList[0].BusinessAccountName.Proof_of_work_permit_in_United_States__c;
                String proofOfCitizenship =  String.isNotBlank(parList[0].Proof_of_Citizenship__c) ? parList[0].Proof_of_Citizenship__c : parList[0].BusinessAccountName.Proof_of_Citizenship__c;
                // outMap.put('CitizinshipStatusLawful', citizenShip);
                outMap.put('ProofOfCitizenshipIfForeignLawful', proofOfWorkPermit);
                outMap.put('ProofOfCitizenshipIfUSLawful', proofOfCitizenship);
                //outMap.put('CitizinshipStatusAmendment', citizenShip);
                outMap.put('ProofOfCitizenshipIfForeignAmendment', proofOfWorkPermit);
                outMap.put('ProofOfCitizenshipIfUS', proofOfCitizenship);
                outMap.put('ProofOfCitizenshipIfUSAmendment', proofOfCitizenship);
                //if proof of citizenship is naturalization
                if(NATURALIZATION.equalsIgnoreCase(proofOfCitizenship))
                {
                    outMap.put('UCSICNumberLawful', String.isNotBlank(parList[0].USCIS_Number__c) ? parList[0].USCIS_Number__c : parList[0].BusinessAccountName.USCIS_Number__c);
                    outMap.put('NaturalizationNumberLawful', String.isNotBlank(parList[0].Naturalization_Number__c) ? parList[0].Naturalization_Number__c : parList[0].BusinessAccountName.Naturalization_Number__c);
                }
                // else if(){
                //     if(VISA_PERMIT_SET.contains(proofOfWorkPermit))
                //     {
                //         if(proofOfWorkPermit == HB_VISA){
                //             outMap.put('H1BVisaNumberLawful', String.isNotBlank(parList[0].H1B_Visa_Number__c) ? parList[0].H1B_Visa_Number__c : parList[0].BusinessAccountName.H1B_Visa_Number__c);
                //         }
                //         else if(proofOfWorkPermit == VISA_PERMIT){
                //             outMap.put('VISANumberLawful', String.isNotBlank(parList[0].VISA_Number__c) ? parList[0].VISA_Number__c : parList[0].BusinessAccountName.VISA_Number__c);
                //         }
                //         outMap.put('PassportNumberLawful', String.isNotBlank(parList[0].Passport_Number__c) ? parList[0].Passport_Number__c : parList[0].BusinessAccountName.Passport_Number__c);
                //         outMap.put('PassportCountryLawful', String.isNotBlank(parList[0].Passport_Country__c) ? parList[0].Passport_Country__c : parList[0].BusinessAccountName.Passport_Country__c);
                //         if(!countryCodeToLabelMap.isEmpty()){
                //             outMap.put('PassportCountryFC', 
                //             countryCodeToLabelMap.get(String.isNotBlank(parList[0].Passport_Country__c) ? parList[0].Passport_Country__c : parList[0].BusinessAccountName.Passport_Country__c)); 
                //         }
                //     }
                    //if proof of citizenship is US resident card permanent or expired
                    else if(US_RESIDENTS_SET.contains(proofOfWorkPermit))
                    {
                        outMap.put('USCISNumberLawful', String.isNotBlank(parList[0].USCIS_Number__c) ? parList[0].USCIS_Number__c : parList[0].BusinessAccountName.USCIS_Number__c);
                        outMap.put('USResidentCardNumberLawful', String.isNotBlank(parList[0].US_Permanent_Resident_Card_Number__c) ? parList[0].US_Permanent_Resident_Card_Number__c : parList[0].BusinessAccountName.US_Permanent_Resident_Card_Number__c);
                    }
                    //if proof of citizenship is student visa
                    else if(STUDENT_VISA.equalsIgnoreCase(proofOfWorkPermit))
                    {
                        outMap.put('StudentPassportNumberLawful', String.isNotBlank(parList[0].Passport_Number__c) ? parList[0].Passport_Number__c : parList[0].BusinessAccountName.Passport_Number__c);
                        outMap.put('StudentSevisIDLawful', String.isNotBlank(parList[0].SEVIS_ID__c) ? parList[0].SEVIS_ID__c : parList[0].BusinessAccountName.SEVIS_ID__c);
                        //outMap.put('StudentI94NumberLawful', String.isNotBlank(parList[0].I_94_Number__c) ? parList[0].I_94_Number__c : parList[0].BusinessAccountName.I_94_Number__c);
                        // outMap.put('StudentPassportCountryLawful', String.isNotBlank(parList[0].Passport_Country__c) ? parList[0].Passport_Country__c : parList[0].BusinessAccountName.Passport_Country__c);
                        // if(!countryCodeToLabelMap.isEmpty()){
                        //     outMap.put('StudentPassportCountryFC', countryCodeToLabelMap.get(String.isNotBlank(parList[0].Passport_Country__c) ? parList[0].Passport_Country__c : parList[0].BusinessAccountName.Passport_Country__c));
                        // }
                    }
                }
            } 
        catch (Exception e) { 
           LPI_ExceptionManager.logException( 
              CLASS_NAME, 
              FETCH_CITIZENSHIP_DETAILS, 
              e 
          ); 
        }
            
    }
}