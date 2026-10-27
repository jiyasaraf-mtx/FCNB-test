/**
 * @author                      : MTX Group Product Team
 * @since                       : april 27,2023
 * @description                 : This is a generic data utility class for Embalmers & Funeral Directors board
 */
public with sharing class LPI_EFDApplicationDataUtility {
    public final static String EFD_BOARD = 'Embalmers & Funeral Directors';
    public final static String PRENEED_SELLER_INFO_STEP = 'Preneed Seller Information';
    public final static String ACCOUNT_INFO_STEP = 'Account Information';
    public final static String INSURANCE_INFO_STEP = 'Insurance Information';
    public final static String ESTABLISHMENT_USAGE_STEP = 'Establishment Usage';
    public final static String FUNERAL_ESTAB_RELATIONSHIPS_STEP = 'Funeral Establishment Relationships';
    public final static String BUSINESS_APPLICATION_TYPE = 'BusinessLicenseApplication';
    public final static String INDIVIDUAL_APPLICATION_TYPE = 'IndividualApplication';
    public final static String ROLE_DESIGNATED_INCHARGE = 'Designated Incharge';
    public final static Set<String> PRENEED_BUSINESS_SET = new Set<String>{     
        'Preneed Provider',
        'Preneed Seller'
         };
    public final static String PRENEED_SELLER = 'Preneed Seller';
    public final static String PRENEED_PROVIDER_INFO_STEP = 'Preneed Provider Information';
    public final static String PRENEED_SELLER_QUES = 'Is the Preneed Seller a licensed entity?';
    public final static String PRENEED_PROVIDER_QUES = 'Is the Preneed Provider a licensed entity?';

    public final static String REGISTRATION_QUESTIONS_STEP = 'Registration Questions';
    public final static String OWNNER_INFO_STEP = 'Ownership Information';
    
    /**
     * @author                      : MTX Group Product Team
     * @since                       : april 27,2023
     * @description                 : This method will give List of section eligible for Dental board
     * @param parRecord             : PreliminaryApplicationRef
     * @param accRecord             : Account
     * @param appFlowSteps          : Set<String> appFlowSteps
     * @return                      : List<LPI_PDFSectionWrapper>
     * @last modified by            : MTX Group Product Team
     * @last modified date          :
     * @modified details            :
     */
    public static List<LPI_PDFSectionWrapper> getSectionList(
        PreliminaryApplicationRef parRecord,
        Account accRecord,
        Set<String> appFlowSteps
    ) {
        List<LPI_PDFSectionWrapper> sectionList = new List<LPI_PDFSectionWrapper>();
        try {
            
            if (appFlowSteps.contains(PRENEED_SELLER_INFO_STEP) ||
                appFlowSteps.contains(PRENEED_PROVIDER_INFO_STEP)) {
                sectionList.add(getPreneedSellerInfoStep(parRecord));
            }
             
            if (appFlowSteps.contains(ACCOUNT_INFO_STEP)) {
                sectionList.add(getAccountInfoStep(parRecord));
            }

             
            if (appFlowSteps.contains(INSURANCE_INFO_STEP)) {
                sectionList.add(getInsuranceInfoStep(parRecord.Id));
            }

             
            if (appFlowSteps.contains(ESTABLISHMENT_USAGE_STEP)) {
                sectionList.add(getEstablishmentUsageStep(parRecord.Id));
            }


             
            if (appFlowSteps.contains(REGISTRATION_QUESTIONS_STEP)) {
                LPI_PDFSectionWrapper wrapObj = new LPI_PDFSectionWrapper();
                wrapObj = LPI_ApplicationDataUtility.getLicensedQuestionSection(parRecord);
                wrapObj.sectionName = 'Registration Questions';
                sectionList.add(wrapObj);
            }
            
             
            if (appFlowSteps.contains(FUNERAL_ESTAB_RELATIONSHIPS_STEP)) {
                if (parRecord.ApplicationType == INDIVIDUAL_APPLICATION_TYPE) {
                    sectionList.add(getIndividualFunralEstablishmentRelationStep(parRecord.Id));
                } else if (parRecord.ApplicationType == BUSINESS_APPLICATION_TYPE) {
                    sectionList.add(getBusinessFunralEstablishmentRelationStep(parRecord.Id));
                }
            }

            if (appFlowSteps.contains(OWNNER_INFO_STEP)) {
                if (parRecord.Amendment_Type__c == 'Change of Ownership(without additional owners)') {
                    sectionList.add(getOwnerInfoStep(parRecord));
                }
            }
            
        } catch (Exception e) {
            LPI_ExceptionManager.logException(
                'LPI_EFDApplicationDataUtility',
                'getSectionList',
                e
            );
        }

        return sectionList;
    }

    /**
     * @author                      : MTX Group Product Team
     * @since                       : May 03,2023
     * @description                 : This method will give Secton for Preneed Seller/Provider Information
     * @param parRecord            : PreliminaryApplicationRef
     * @return                      : LPI_PDFSectionWrapper
     * @last modified by            : MTX Group Product Team
     * @last modified date          :
     * @modified details
     */
    public static LPI_PDFSectionWrapper getPreneedSellerInfoStep(
        PreliminaryApplicationRef parRecord
    ) {
        String preneedLabel = parRecord.Regulatory_Authorization_Type__r.Name == PRENEED_SELLER ? PRENEED_PROVIDER_INFO_STEP : PRENEED_SELLER_INFO_STEP;
        String preneedCounterLabel = parRecord.Regulatory_Authorization_Type__r.Name == PRENEED_SELLER ? PRENEED_PROVIDER_INFO_STEP : PRENEED_SELLER_INFO_STEP;
        String preneedEntityQues = parRecord.Regulatory_Authorization_Type__r.Name == PRENEED_SELLER ? PRENEED_PROVIDER_QUES : PRENEED_SELLER_QUES;
        LPI_PDFSectionWrapper finalResultStep = new LPI_PDFSectionWrapper(
            preneedLabel,
            2,
            null
        );
        Map<String, Object> input = new Map<String, Object>();
        Map<String, Object> output = new Map<String, Object>();
        input.put('parid', parRecord.Id);
        if (parRecord.ApplicationType == 'BusinessLicenseApplication') {
            LPI_PreneedBusinessInformation.fetchPreneedBusinessInformation(
                input,
                output,
                true
            );
        } else {
          
        }
        List<LPI_PDFSectionWrapper.DataWrapper> dataList = new List<LPI_PDFSectionWrapper.DataWrapper>();
        if (
            output != null &&
            output.containsKey('EFDApplicationPreneedSellerInformationBlock')
        ) {
            List<Map<String, Object>> preneedSellerInfoList = (List<Map<String, Object>>) output.get(
                'EFDApplicationPreneedSellerInformationBlock'
            );
            Integer counter = 1;
            for (Map<String, Object> preneedSaller : preneedSellerInfoList) {
                dataList.clear();
                LPI_PDFSectionWrapper preneedSallerInfo = new LPI_PDFSectionWrapper(
                    preneedCounterLabel + ' ' + counter,
                    1,
                    dataList
                );
                dataList.clear();
                Boolean isActive = preneedSaller.get('IsActive') != null
                    ? Boolean.valueOf(preneedSaller.get('IsActive'))
                    : false;
                String isPreneedSellerALicensedEntity = '';
                String licenseNumber = '';
                String name = '';
                String streetAddress = '';
                String cityName = '';
                String stateName = '';
                String zipCode = '';
                if (isActive) {
                    isPreneedSellerALicensedEntity = String.valueOf(
                        preneedSaller.get(
                            'EFDApplicationPreneedSellerInformationIsThePreneedRead'
                        )
                    );
                    licenseNumber = String.valueOf(
                        preneedSaller.get(
                            'EFDApplicationPreneedSellerInformationLicenseNumberRead'
                        )
                    );
                    name = String.valueOf(
                        preneedSaller.get(
                            'EFDApplicationPreneedSellerInformationNameRead'
                        )
                    );
                    streetAddress = String.valueOf(
                        preneedSaller.get(
                            'EFDApplicationPreneedSellerInformationStreet1Read'
                        )
                    );
                    cityName = String.valueOf(
                        preneedSaller.get(
                            'EFDApplicationPreneedSellerInformationCityRead'
                        )
                    );
                    stateName = String.valueOf(
                        preneedSaller.get(
                            'EFDApplicationPreneedSellerInformationStateRead'
                        )
                    );
                    zipCode = String.valueOf(
                        preneedSaller.get(
                            'EFDApplicationPreneedSellerInformationZipRead'
                        )
                    );
                } else {
                    isPreneedSellerALicensedEntity = String.valueOf(
                        preneedSaller.get(
                            'EFDApplicationPreneedSellerInformationIsThePreneed'
                        )
                    );
                    if (isPreneedSellerALicensedEntity == 'Yes') {
                        licenseNumber = String.valueOf(
                            preneedSaller.get('SalesPersonLicenseNumber')
                        );
                        name = String.valueOf(
                            preneedSaller.get('SalesPersonNameOfCorporation')
                        );
                        streetAddress = String.valueOf(
                            preneedSaller.get('SalesPersonStreetAddress')
                        );
                        cityName = String.valueOf(
                            preneedSaller.get('SalesPersonCity')
                        );
                        stateName = String.valueOf(
                            preneedSaller.get('SalesPersonState')
                        );
                        zipCode = String.valueOf(
                            preneedSaller.get('SalesPersonZipcode')
                        );
                    } else {
                        licenseNumber = String.valueOf(
                            preneedSaller.get(
                                'EFDApplicationPreneedSellerInformationLicenseNumber'
                            )
                        );
                        name = String.valueOf(
                            preneedSaller.get(
                                'EFDApplicationPreneedSellerInformationName'
                            )
                        );
                        streetAddress = String.valueOf(
                            preneedSaller.get(
                                'EFDApplicationPreneedSellerInformationStreet1'
                            )
                        );
                        cityName = String.valueOf(
                            preneedSaller.get(
                                'EFDApplicationPreneedSellerInformationCity'
                            )
                        );
                        stateName = String.valueOf(
                            preneedSaller.get(
                                'EFDApplicationPreneedSellerInformationState'
                            )
                        );
                        zipCode = String.valueOf(
                            preneedSaller.get(
                                'EFDApplicationPreneedSellerInformationZip'
                            )
                        );
                    }
                }
                
                if(PRENEED_BUSINESS_SET.contains(parRecord.Regulatory_Authorization_Type__r.Name)){
                    dataList.add(
                        new LPI_PDFSectionWrapper.DataWrapper(
                            preneedEntityQues,
                            isPreneedSellerALicensedEntity
                        )
                    );
                }
                if(isPreneedSellerALicensedEntity == 'Yes'){
                    dataList.add(
                        new LPI_PDFSectionWrapper.DataWrapper(
                            'Registered Number',
                            licenseNumber
                        )
                    );
                }
                dataList.add(
                    new LPI_PDFSectionWrapper.DataWrapper('Name', name)
                );
                dataList.add(
                    new LPI_PDFSectionWrapper.DataWrapper(
                        'Street Address',
                        streetAddress
                    )
                );
                dataList.add(
                    new LPI_PDFSectionWrapper.DataWrapper('City', cityName)
                );
                dataList.add(
                    new LPI_PDFSectionWrapper.DataWrapper('State', stateName)
                );
                dataList.add(
                    new LPI_PDFSectionWrapper.DataWrapper('Zip Code', zipCode)
                );
                preneedSallerInfo.addSubSection(
                    new LPI_PDFSectionWrapper('', 2, dataList)
                );
                finalResultStep.addSubSection(preneedSallerInfo);
                counter += 1;
            }
        }
        return finalResultStep;
    }

    /**
     * @author                      : MTX Group Product Team
     * @since                       : May 03,2023
     * @description                 : This method will give Secton for Account Information
     * @param parId                : String
     * @return                      : LPI_PDFSectionWrapper
     * @last modified by            : MTX Group Product Team
     * @last modified date          :
     * @modified details
     */
    public static LPI_PDFSectionWrapper getAccountInfoStep(PreliminaryApplicationRef par) {
        LPI_PDFSectionWrapper finalResultStep = new LPI_PDFSectionWrapper(
            ACCOUNT_INFO_STEP,
            2,
            null
        );
        Map<String, Object> input = new Map<String, Object>();
        Map<String, Object> output = new Map<String, Object>();
        input.put('parId', par.Id);
        LPI_AuditEscrowController.fetchBankAccountDetails(input, output);
        List<LPI_PDFSectionWrapper.DataWrapper> dataList = new List<LPI_PDFSectionWrapper.DataWrapper>();
       
        String doYouMaintainTrustOrJointAcc = par.Do_you_maintain_Trust_or_Joint_Account__c;
        List<LPI_PDFSectionWrapper.DataWrapper> queDataList = new List<LPI_PDFSectionWrapper.DataWrapper>();
            queDataList.add(
                new LPI_PDFSectionWrapper.DataWrapper(
                        'Do you maintain a trust account or joint account in any financial institution, where funds received on your behalf as payment for preneed sales and contracts will be deposited?',
                        doYouMaintainTrustOrJointAcc
                )
            );
            finalResultStep.addSubSection(
                new LPI_PDFSectionWrapper('', 1, queDataList, true)
            );
         
        if (doYouMaintainTrustOrJointAcc == 'Yes' && output != null && output.containsKey('BankAccountInfoList')) {
            List<Map<String, Object>> bankAccInfoList = (List<Map<String, Object>>) output.get(
                'BankAccountInfoList'
            );
            Integer counter = 1;
            for (Map<String, Object> bankAccInfo : bankAccInfoList) {
                dataList.clear();
                dataList.add(
                    new LPI_PDFSectionWrapper.DataWrapper(
                        'Name of the Financial Institution',
                        String.valueOf(
                            bankAccInfo.get('NameOfFinancialInstitution')
                        )
                    )
                );
                LPI_PDFSectionWrapper bankAccountInfo = new LPI_PDFSectionWrapper(
                    ACCOUNT_INFO_STEP +
                    ' ' +
                    counter,
                    1,
                    dataList
                );
                dataList.clear();
                dataList.add(
                    new LPI_PDFSectionWrapper.DataWrapper(
                        'Street Address',
                        String.valueOf(bankAccInfo.get('StreetAddressAccInfo'))
                    )
                );
                dataList.add(
                    new LPI_PDFSectionWrapper.DataWrapper(
                        'City',
                        String.valueOf(bankAccInfo.get('CityAccInfo'))
                    )
                );
                dataList.add(
                    new LPI_PDFSectionWrapper.DataWrapper(
                        'State',
                        String.valueOf(bankAccInfo.get('StateAccInfo'))
                    )
                );
                dataList.add(
                    new LPI_PDFSectionWrapper.DataWrapper(
                        'Zip',
                        String.valueOf(bankAccInfo.get('ZipAccInfo'))
                    )
                );
                dataList.add(
                    new LPI_PDFSectionWrapper.DataWrapper(
                        'Telephone Number',
                        String.valueOf(bankAccInfo.get('TelephoneNumber'))
                    )
                );
                bankAccountInfo.addSubSection(
                    new LPI_PDFSectionWrapper(
                        'Financial Institution Address',
                        2,
                        dataList
                    )
                );
                dataList.clear();
                String typeOfAccount = String.valueOf(
                    bankAccInfo.get('TypeOfAccount')
                );
                dataList.add(
                    new LPI_PDFSectionWrapper.DataWrapper(
                        'Type of Account',
                        typeOfAccount
                    )
                );

                if (typeOfAccount == 'Other') {
                    dataList.add(
                        new LPI_PDFSectionWrapper.DataWrapper(
                            'Other Account Type',
                            String.valueOf(bankAccInfo.get('OtherAccountType'))
                        )
                    );
                } else if (typeOfAccount != 'Joint Account') {
                    dataList.add(
                        new LPI_PDFSectionWrapper.DataWrapper(
                            'Exact Name on Account',
                            String.valueOf(
                                bankAccInfo.get('ExactNameonAccount')
                            )
                        )
                    );
                } else if (typeOfAccount == 'Joint Account') {
                    dataList.add(
                        new LPI_PDFSectionWrapper.DataWrapper(
                            'Exact Name on Account',
                            String.valueOf(
                                bankAccInfo.get('ExactNameonAccountJA')
                            )
                        )
                    );
                }
                dataList.add(
                    new LPI_PDFSectionWrapper.DataWrapper(
                        'Account Number',
                        String.valueOf(bankAccInfo.get('BankAccountNumber'))
                    )
                );
                dataList.add(
                    new LPI_PDFSectionWrapper.DataWrapper(
                        'Contact Person at Financial Institution',
                        String.valueOf(
                            bankAccInfo.get(
                                'ContactPersonatfinancialInstitution'
                            )
                        )
                    )
                );
                dataList.add(
                    new LPI_PDFSectionWrapper.DataWrapper(
                        'Telephone Number',
                        String.valueOf(
                            bankAccInfo.get('ContactTelephoneNumber')
                        )
                    )
                );
                dataList.add(
                    new LPI_PDFSectionWrapper.DataWrapper(
                        'Email',
                        String.valueOf(bankAccInfo.get('EmailAccInfo'))
                    )
                );
                bankAccountInfo.addSubSection(
                    new LPI_PDFSectionWrapper('', 2, dataList)
                );
                dataList.clear();
                counter += 1;
                finalResultStep.addSubSection(bankAccountInfo);
            }
        }

        return finalResultStep;
    }

    /**
     * @author                      : MTX Group Product Team
     * @since                       : May 03,2023
     * @description                 : This method will give Secton for Insurance Information
     * @param parId                : String
     * @return                      : LPI_PDFSectionWrapper
     * @last modified by            : MTX Group Product Team
     * @last modified date          :
     * @modified details
     */
    public static LPI_PDFSectionWrapper getInsuranceInfoStep(String parId) {
        LPI_PDFSectionWrapper finalResultStep = new LPI_PDFSectionWrapper(
            INSURANCE_INFO_STEP,
            2,
            null
        );
        Map<String, Object> myTransformData = new Map<String, Object>{
            'parId' => parId
        };
        Map<String, Object> myTransformResult;
        
            if(Test.isRunningTest()){
                myTransformResult = new Map<String, Object>();
                Map<String, Object> applicantMap=new Map<String, Object>();
                Map<String, Object> InsuranceInformationStepMap=new Map<String, Object>();
                Map<String, Object> InsuranceInformationBlockMap=new Map<String, Object>();
                applicantMap.put('NameOfTheSchool','School of Test Class');
                applicantMap.put('State','Test State');
                applicantMap.put('City','Test City');
                applicantMap.put('StartDate',System.today());
                applicantMap.put('EndDate',System.today());
                InsuranceInformationBlockMap.put('InsuranceInformationBlock',applicantMap);
                myTransformResult.put('InsuranceInformationStep',InsuranceInformationBlockMap);
            }else{
                omnistudio.DRProcessResult result = omnistudio.DRGlobal.process(
                    myTransformData,
                    'FetchInsuranceInformation'
                );
                myTransformResult = (Map<String, Object>) result.toJson();
            }
        if(myTransformResult.containsKey('IsInsuranceCompanyDetailsApplicable') && myTransformResult.get('IsInsuranceCompanyDetailsApplicable') == 'Not Applicable'){
            List<LPI_PDFSectionWrapper.DataWrapper> dataList = new List<LPI_PDFSectionWrapper.DataWrapper>();
                dataList.clear();
                dataList.add(
                    new LPI_PDFSectionWrapper.DataWrapper(
                        '',
                        'Not Applicable'
                    )
                );
                finalResultStep = new LPI_PDFSectionWrapper(
                INSURANCE_INFO_STEP,
                2,
                dataList
                );
        }
        else if (myTransformResult.containsKey('InsuranceInformationStep')) {
            List<Map<String, Object>> insuranceInfoList = new List<Map<String, Object>>();
            Map<String, Object> insuranceInfoBlockMap = (Map<String, Object>) myTransformResult.get(
                'InsuranceInformationStep'
            );
            if (
                insuranceInfoBlockMap.get(
                    'InsuranceInformationBlock'
                ) instanceof List<Object>
            ) {
                insuranceInfoList = (List<Map<String, Object>>) insuranceInfoBlockMap.get(
                    'InsuranceInformationBlock'
                );
            } else {
                insuranceInfoList.add(
                    (Map<String, Object>) insuranceInfoBlockMap.get(
                        'InsuranceInformationBlock'
                    )
                );
            }
            List<LPI_PDFSectionWrapper.DataWrapper> dataList = new List<LPI_PDFSectionWrapper.DataWrapper>();
            Integer counter = 1;
            for (Map<String, Object> insuranceInfo : insuranceInfoList) {
                dataList.clear();
                dataList.add(
                    new LPI_PDFSectionWrapper.DataWrapper(
                        'Name of Insurance Company',
                        String.valueOf(
                            insuranceInfo.get('NameOfInsuranceCompany')
                        )
                    )
                );
               
                dataList.add(
                    new LPI_PDFSectionWrapper.DataWrapper(
                        'Contact Person at Insurance Company',
                        String.valueOf(
                            insuranceInfo.get('ContactPersonFirstName')
                        )
                    )
                );
                dataList.add(
                    new LPI_PDFSectionWrapper.DataWrapper(
                        'Email for Contact Person',
                        String.valueOf(
                            insuranceInfo.get('ContactEmail')
                        )
                    )
                );
                
                LPI_PDFSectionWrapper insuranceInfoWrapper = new LPI_PDFSectionWrapper(
                    INSURANCE_INFO_STEP +
                    ' ' +
                    counter,
                    2,
                    dataList
                );
                dataList.clear();
                dataList.add(
                    new LPI_PDFSectionWrapper.DataWrapper(
                        'Street Address',
                        String.valueOf(insuranceInfo.get('Street1'))
                    )
                );
                dataList.add(
                    new LPI_PDFSectionWrapper.DataWrapper(
                        'City',
                        String.valueOf(insuranceInfo.get('City'))
                    )
                );
                dataList.add(
                    new LPI_PDFSectionWrapper.DataWrapper(
                        'State',
                        String.valueOf(insuranceInfo.get('State'))
                    )
                );
                dataList.add(
                    new LPI_PDFSectionWrapper.DataWrapper(
                        'Zip Code',
                        String.valueOf(insuranceInfo.get('Zip'))
                    )
                );
                dataList.add(
                    new LPI_PDFSectionWrapper.DataWrapper(
                        'Phone',
                        String.valueOf(insuranceInfo.get('Phone'))
                    )
                );
                insuranceInfoWrapper.addSubSection(
                    new LPI_PDFSectionWrapper(
                        'Insurance Company Address',
                        2,
                        dataList
                    )
                );
                finalResultStep.addSubSection(insuranceInfoWrapper);
                dataList.clear();
                counter += 1;
            }
        }
        return finalResultStep;
    }

    /**
     * @author                      : MTX Group Product Team
     * @since                       : May 03,2023
     * @description                 : This method will give Secton for Establishment Usage
     * @param parId                : String
     * @return                      : LPI_PDFSectionWrapper
     * @last modified by            : MTX Group Product Team
     * @last modified date          :
     * @modified details
     */
    public static LPI_PDFSectionWrapper getEstablishmentUsageStep(
        String parId
    ) {
        Map<String, Object> myTransformData = new Map<String, Object>{
            'getParId' => parId
        };
       
        omnistudio.DRProcessResult result = omnistudio.DRGlobal.process(
            myTransformData,
            'exportPersonalInfo'
        );
        
        Map<String, Object> myTransformResult;
        if(Test.isRunningTest()){
            myTransformResult = new Map<String, Object>();
            myTransformResult.put('FunctionA',true);
            myTransformResult.put('FunctionB',true);
            myTransformResult.put('FunctionC',true);
            myTransformResult.put('FunctionD',true);
            myTransformResult.put('FunctionE',true);
        }else{
            myTransformResult = (Map<String, Object>) result.toJson();
        }
        List<LPI_PDFSectionWrapper.DataWrapper> dataList = new List<LPI_PDFSectionWrapper.DataWrapper>();
        dataList.add(
            new LPI_PDFSectionWrapper.DataWrapper(
                'Please select the appropriate option to notify ' +
                'the board that the establishment will be used.',
                ''
            )
        );
        if (Boolean.valueOf(myTransformResult.get('FunctionA'))) {
            dataList.add(
                new LPI_PDFSectionWrapper.DataWrapper(
                    'Function A establishments shall have authority to embalm dead ' +
                    'human bodies and to transport dead human bodies to and from the ' +
                    'funeral establishment. (embalming only)',
                    ''
                )
            );
        }
        if (Boolean.valueOf(myTransformResult.get('FunctionB'))) {
            dataList.add(
                new LPI_PDFSectionWrapper.DataWrapper(
                    'Function B establishments shall have authority to cremate dead human ' +
                    'bodies and to transport dead human bodies to and from the funeral establishment. ' +
                    '(cremation only - facility has a retort onsite)',
                    ''
                )
            );
        }
        if (Boolean.valueOf(myTransformResult.get('FunctionC'))) {
            dataList.add(
                new LPI_PDFSectionWrapper.DataWrapper(
                    'Function C establishments shall have authority for the care and preparation of dead human bodies, ' +
                    'other than by embalming or cremating, authority to transport dead human bodies to and from the funeral establishment, ' +
                    'make funeral arrangements, and furnish any funeral services in connection with the disposition of dead human bodies or the sale ' +
                    'of funeral merchandise. (care and preparation only)',
                    ''
                )
            );
        }
        if (Boolean.valueOf(myTransformResult.get('FunctionD'))) {
            dataList.add(
                new LPI_PDFSectionWrapper.DataWrapper(
                    ' Function D establishments shall have authority to conduct visitations and funeral ceremonies only. ' +
                    'a function D license is dependent upon and must be operated under the supervision and ownership of ' +
                    'a function C establishment. (visitations only - you can have this function only if you have another ' +
                    'location licensed for care and preparation.)',
                    ''
                )
            );
        }
        if (Boolean.valueOf(myTransformResult.get('FunctionE'))) {
            dataList.add(
                new LPI_PDFSectionWrapper.DataWrapper(
                    'Function E establishment shall have the authority to make funeral arrangements and furnish any ' +
                    'funeral services in connection with the disposition of dead human bodies or the sale of ' +
                    'funeral merchandise and file death certificates.',
                    ''
                )
            );
        }

        return new LPI_PDFSectionWrapper(
            ESTABLISHMENT_USAGE_STEP,
            1,
            dataList
        );
    }

    /**
     * @author                      : MTX Group Product Team
     * @since                       : May 03,2023
     * @description                 : This method will give Secton for Funeral Establishment Relationships
     * @param parId                : String
     * @return                      : LPI_PDFSectionWrapper
     * @last modified by            : MTX Group Product Team
     * @last modified date          :
     * @modified details
     */
    public static LPI_PDFSectionWrapper getIndividualFunralEstablishmentRelationStep(
        String parId
    ) {
        LPI_PDFSectionWrapper finalResultStep = new LPI_PDFSectionWrapper(
            FUNERAL_ESTAB_RELATIONSHIPS_STEP,
            2,
            null
        );
        Map<String, Object> inputMap = new Map<String, Object>();
        inputMap.put('parid', parId);
        List<LPI_EstablishmentInformationController.EstablishmentWrapper> establishmentWrapperList = LPI_EstablishmentInformationController.getRecords(
            inputMap
        );
        if (
            establishmentWrapperList != null &&
            !establishmentWrapperList.isEmpty()
        ) {
            populateEstablishmentWrapper(establishmentWrapperList);
        }
        List<LPI_PDFSectionWrapper.DataWrapper> dataList = new List<LPI_PDFSectionWrapper.DataWrapper>();
        Integer counter = 1;
        for (
            LPI_EstablishmentInformationController.EstablishmentWrapper wrapper : establishmentWrapperList
        ) {
            dataList.clear();
            dataList.add(
                new LPI_PDFSectionWrapper.DataWrapper(
                    'Establishment License Number',
                    wrapper.establishmentLicNo
                )
            );
            dataList.add(
                new LPI_PDFSectionWrapper.DataWrapper(
                    'Establishment Name',
                    wrapper.establishmentName
                )
            );
            dataList.add(
                new LPI_PDFSectionWrapper.DataWrapper(
                    'Street Address',
                    wrapper.billingStreet
                )
            );
            dataList.add(
                new LPI_PDFSectionWrapper.DataWrapper(
                    'City',
                    wrapper.billingCity
                )
            );
            dataList.add(
                new LPI_PDFSectionWrapper.DataWrapper(
                    'State',
                    wrapper.billingState
                )
            );
            dataList.add(
                new LPI_PDFSectionWrapper.DataWrapper(
                    'Zip Code',
                    wrapper.billingPostalCode
                )
            );
            dataList.add(
                new LPI_PDFSectionWrapper.DataWrapper(
                    'Establishment Telephone Number',
                    wrapper.phone
                )
            );
            dataList.add(
                new LPI_PDFSectionWrapper.DataWrapper(
                    'Funeral Director In Charge',
                    wrapper.inchargeName
                )
            );
            dataList.add(
                new LPI_PDFSectionWrapper.DataWrapper(
                    'Funeral Director In Charge License Number',
                    wrapper.inchargeLicNumber
                )
            );
            dataList.add(
                new LPI_PDFSectionWrapper.DataWrapper(
                    'Date Relationship Began Or Will Begin With Establishment',
                    wrapper.beginDate?.format()
                )
            );
            if(!wrapper.isDisable){
                dataList.add(
                    new LPI_PDFSectionWrapper.DataWrapper(
                        'The board\'s records reflect the relationship listed below ' +
                        'is the current relationship that is on record for you.' +
                        ' In order for the board to update our records, please ' +
                        'indicate by checking Yes or No if this relationship is associated with you.',
                        String.valueOf(wrapper.relationshipAssociatedWithYou),
                        'checkbox'
                    )
                );
            }
            LPI_PDFSectionWrapper establishmentInfoStep = new LPI_PDFSectionWrapper(
                'Establishment - ' + counter,
                2,
                dataList
            );
            dataList.clear();
            Integer innerCounter = 1;
            for (
                LPI_EstablishmentInformationController.EmbalmerDetailList childWrapper : wrapper.embalmerDetailList
            ) {
                dataList.add(
                    new LPI_PDFSectionWrapper.DataWrapper(
                        'Embalmer License Number',
                        childWrapper.embalmerLicNo
                    )
                );
                dataList.add(
                    new LPI_PDFSectionWrapper.DataWrapper(
                        'Embalmer Name',
                        childWrapper.embalmerName
                    )
                );
                establishmentInfoStep.addSubSection(
                    new LPI_PDFSectionWrapper(
                        'Embalmer - ' + innerCounter,
                        2,
                        dataList
                    )
                );
                dataList.clear();
                innerCounter += 1;
            }

            finalResultStep.addSubSection(establishmentInfoStep);
            counter += 1;
        }

        return finalResultStep;
    }

    /**
     * @author                           : MTX Group Product Team
     * @since                            : May 03,2023
     * @description                      : This method will update wrapper instance with the backend data
     * @param establishmentWrapperList  : List<LPI_EstablishmentInformationController.EstablishmentWrapper>
     * @return                           : LPI_PDFSectionWrapper
     * @last modified by                 : MTX Group Product Team
     * @last modified date               :
     * @modified details
     */
    private static void populateEstablishmentWrapper(
        List<LPI_EstablishmentInformationController.EstablishmentWrapper> establishmentWrapperList
    ) {
        Map<String, BusinessLicense> licenseNameToBLMap = new Map<String, BusinessLicense>();
        List<String> allowedRoles = new List<String>{
            LPI_LiteralConstant.ROLE_DESIGNATED_INCHARGE,
            LPI_LiteralConstant.ROLE_DESIGNATED_INCHARGE_AND_OWNER
        };
        Set<String> licenseNameSet = new Set<String>();
        for (
            LPI_EstablishmentInformationController.EstablishmentWrapper wrapper : establishmentWrapperList
        ) {
            licenseNameSet.add(wrapper.establishmentLicNo);
            for (
                LPI_EstablishmentInformationController.EmbalmerDetailList childWrapper : wrapper.embalmerDetailList
            ) {
                licenseNameSet.add(childWrapper.embalmerLicNo);
            }
        }
        String fieldsToQuery =
            'ID, Name, First_Name__c, Middle_Name__c, Last_Name__c, Business_Name__c, ContactId, AccountId, ' +
            'Account.BillingStreet, Account.BillingCity, Account.BillingState, Account.BillingPostalCode, Account.Phone, ' +
            'RegulatoryAuthorizationType.Name, RegulatoryAuthorizationType.Authorisation_Type__c, License_Number_With_Rat_Name__c ';
        String whereClause =
            'Name IN ' +
            LPI_ServiceUtility.getStringValuesByStringSet(licenseNameSet);
        LPI_BusinessLicenseDAO.LPI_BusinessLicenseWithoutSharingDAO wihoutSharingBL = new LPI_BusinessLicenseDAO.LPI_BusinessLicenseWithoutSharingDAO();
        Map<String, String> accountIdToContactNameMap = new Map<String, String>();
        Map<String, String> accountIdToContactIdMap = new Map<String, String>();
        Map<String, String> contactIdToLicNumberMap = new Map<String, String>();
        for (
            BusinessLicense blrecord : wihoutSharingBL.getBusinessLicenseByDymanicQuery(
                fieldsToQuery,
                whereClause,
                null,
                null,
                null
            )
        ) {
            licenseNameToBLMap.put(blrecord.Name, blrecord);
            accountIdToContactNameMap.put(blrecord.AccountId, null);
        }

        if(!accountIdToContactNameMap.isEmpty()){
            fieldsToQuery = ' Id, Roles__c, Related_From__c, Related_From__r.Name, Related_To__c, Related_To__r.Name ';
            whereClause =
                ' IsActive__c = true AND Related_From__c IN ' +
                LPI_ServiceUtility.getStringValuesByStringSet(
                    accountIdToContactNameMap.keySet()
                ) +
                ' AND Roles__c IN ' +
                LPI_ServiceUtility.getStringValuesByList(allowedRoles);
            LPI_BusinessRelationshipDAO.LPI_BusinessRelationshipsWithoutSharingDAO withoutSharingQuery = new LPI_BusinessRelationshipDAO.LPI_BusinessRelationshipsWithoutSharingDAO();
            for (
                Business_Relationships__c acr : withoutSharingQuery.getBusinessRelationshipsByDymanicQuery(
                    fieldsToQuery,
                    whereClause,
                    null,
                    null,
                    null
                )
            ) {
                accountIdToContactNameMap.put(
                    acr.Related_From__c,
                    acr.Related_To__r.Name
                );
                accountIdToContactIdMap.put(acr.Related_From__c, acr.Related_To__c);
            }
        }

        for (
            LPI_EstablishmentInformationController.EstablishmentWrapper wrapper : establishmentWrapperList
        ) {
            if (licenseNameToBLMap.containsKey(wrapper.establishmentLicNo)) {
                BusinessLicense blRecord = licenseNameToBLMap.get(
                    wrapper.establishmentLicNo
                );
                wrapper.establishmentLicNo = blRecord.License_Number_With_Rat_Name__c;
                wrapper.establishmentName = blRecord.Business_Name__c;
                wrapper.billingStreet = blRecord.Account.BillingStreet;
                wrapper.billingCity = blRecord.Account.BillingCity;
                wrapper.billingState = blRecord.Account.BillingState;
                wrapper.billingPostalCode = blRecord.Account.BillingPostalCode;
                wrapper.phone = blRecord.Account.Phone;
                wrapper.inchargeName = accountIdToContactNameMap.containsKey(
                        blRecord.AccountId
                    )
                    ? accountIdToContactNameMap.get(blRecord.AccountId)
                    : '';
                String contactId = accountIdToContactIdMap.containsKey(
                        blRecord.AccountId
                    )
                    ? accountIdToContactIdMap.get(blRecord.AccountId)
                    : '';
                wrapper.inchargeLicNumber = contactId != null &&
                    contactIdToLicNumberMap.containsKey(contactId)
                    ? contactIdToLicNumberMap.get(contactId)
                    : '';
            }
            for (
                LPI_EstablishmentInformationController.EmbalmerDetailList childWrapper : wrapper.embalmerDetailList
            ) {
                if (
                    licenseNameToBLMap.containsKey(childWrapper.embalmerLicNo)
                ) {
                    BusinessLicense blRecord = licenseNameToBLMap.get(
                        childWrapper.embalmerLicNo
                    );
                    childWrapper.embalmerLicNo = blRecord.License_Number_With_Rat_Name__c;
                    String fullName = '';
                    fullName = fullName + blRecord.First_Name__c + ' ';
                    fullName =
                        fullName +
                        (String.isNotBlank(blRecord.Middle_Name__c)
                            ? blRecord.Middle_Name__c + ' '
                            : '');
                    fullName = fullName + blRecord.Last_Name__c;
                    childWrapper.embalmerName = fullName;
                }
            }
        }
    }

    /**
     * @author                      : MTX Group Product Team
     * @since                       : July 31st, 2023
     * @description                 : This method will give Secton for Funeral Establishment Relationships for business application
     * @param parId                 : String
     * @return                      : LPI_PDFSectionWrapper
     * @last modified by            : MTX Group Product Team
     * @last modified date          :
     * @modified details            :
     */
    public static LPI_PDFSectionWrapper getBusinessFunralEstablishmentRelationStep(
        String parId
    ) {
        LPI_PDFSectionWrapper finalResultStep = new LPI_PDFSectionWrapper(
            FUNERAL_ESTAB_RELATIONSHIPS_STEP,
            2,
            null
        );
        Map<String, Object> inputMap = new Map<String, Object>();
        Map<String, String> accountIdToInchargeNameMap = new Map<String, String>();
        Map<String, String> accountIdToInchargeIdMap = new Map<String, String>();
        Map<String,BusinessLicense> blNoToBlMap = new Map<String,BusinessLicense>();
        Set<Id> orgIdSet = new Set<Id>();
        Set<String> blIdSet = new Set<String>();
        
        inputMap.put('parid', parId);
        List<LPI_EstablishmentInformationController.EstablishmentBusinessWrapper> establishmentWrapperList = LPI_EstablishmentInformationController.getBusinessRecords(
            inputMap
        );
       
        
        if (!establishmentWrapperList.isEmpty()) {
            for(LPI_EstablishmentInformationController.EstablishmentBusinessWrapper est : establishmentWrapperList){
                blIdSet.add(est.establishmentLicNo);
            }
            
            String fieldsToQuery = 'Id, Name, Business_Name__c, Account.BillingStreet, Account.BillingCity, Account.BillingState, Account.BillingPostalCode, Account.Phone, AccountId, License_Number_With_Rat_Name__c ';
            String whereClause = 'ContactId != null AND AccountId != null AND Name IN ' + LPI_ServiceUtility.getStringValuesByStringSet(blIdSet);

            if(!blIdSet.isEmpty()){
                for(BusinessLicense bl :new LPI_BusinessLicenseDAO.LPI_BusinessLicenseWithoutSharingDAO().getBusinessLicenseByDymanicQuery(fieldsToQuery,whereClause,'100',null,null)){
                    blNoToBlMap.put(bl.Name,bl);
                    orgIdSet.add(bl.AccountId);
                }
            }
            

            if(!orgIdSet.isEmpty()){
                fieldsToQuery = ' Id, Roles__c, Related_From__c, Related_From__r.Name, Related_To__c, Related_To__r.Name ';
                whereClause =' IsActive__c = true AND Related_From__c IN ' + LPI_ServiceUtility.getStringValuesBySet(orgIdSet) + ' AND Roles__c = \'' + ROLE_DESIGNATED_INCHARGE + '\'';
                LPI_BusinessRelationshipDAO.LPI_BusinessRelationshipsWithoutSharingDAO daoInnerObj = new LPI_BusinessRelationshipDAO.LPI_BusinessRelationshipsWithoutSharingDAO();
                for (
                    Business_Relationships__c businessRelationship : daoInnerObj.getBusinessRelationshipsByDymanicQuery(
                        fieldsToQuery,
                        whereClause,
                        null,
                        null,
                        null
                    )
                ) {
                    accountIdToInchargeNameMap.put(businessRelationship.Related_From__c, businessRelationship.Related_To__r.Name);
                    accountIdToInchargeIdMap.put(businessRelationship.Related_From__c, businessRelationship.Related_To__c);
                }
            }

            Map<String, String> InchargeIdToLicNumberMap = new Map<String, String>();
            List<LPI_PDFSectionWrapper.DataWrapper> dataList = new List<LPI_PDFSectionWrapper.DataWrapper>();
            Integer counter = 1;
            for (
                LPI_EstablishmentInformationController.EstablishmentBusinessWrapper wrapper : establishmentWrapperList
            ) {
                dataList.clear();
                if (accountIdToInchargeNameMap.containsKey(blNoToBlMap.get(wrapper.establishmentLicNo).AccountId)) {
                    wrapper.inchargeName = accountIdToInchargeNameMap.get(blNoToBlMap.get(wrapper.establishmentLicNo).AccountId);
                    String contactId = '';
                     
                    if (accountIdToInchargeIdMap.containsKey(blNoToBlMap.get(wrapper.establishmentLicNo).AccountId)) {
                        contactId = accountIdToInchargeIdMap.get(blNoToBlMap.get(wrapper.establishmentLicNo).AccountId);
                        if (InchargeIdToLicNumberMap.containsKey(contactId)) {
                             
                            wrapper.inchargeLicNumber = InchargeIdToLicNumberMap.get(contactId);
                        }
                    }
                }
                dataList.add(
                    new LPI_PDFSectionWrapper.DataWrapper(
                        'Establishment License Number',
                        blNoToBlMap.get(wrapper.establishmentLicNo).License_Number_With_Rat_Name__c
                    )
                );
                dataList.add(
                    new LPI_PDFSectionWrapper.DataWrapper(
                        'Establishment Name',
                        blNoToBlMap.get(wrapper.establishmentLicNo).Business_Name__c
                    )
                );
                dataList.add(
                    new LPI_PDFSectionWrapper.DataWrapper(
                        'Street Address',
                        blNoToBlMap.get(wrapper.establishmentLicNo).Account.BillingStreet
                    )
                );
                dataList.add(
                    new LPI_PDFSectionWrapper.DataWrapper(
                        'City',
                        blNoToBlMap.get(wrapper.establishmentLicNo).Account.BillingCity
                    )
                );
                dataList.add(
                    new LPI_PDFSectionWrapper.DataWrapper(
                        'State',
                        blNoToBlMap.get(wrapper.establishmentLicNo).Account.BillingState
                    )
                );
                dataList.add(
                    new LPI_PDFSectionWrapper.DataWrapper(
                        'Zip Code',
                        blNoToBlMap.get(wrapper.establishmentLicNo).Account.BillingPostalCode
                    )
                );
                dataList.add(
                    new LPI_PDFSectionWrapper.DataWrapper(
                        'Establishment Telephone Number',
                        blNoToBlMap.get(wrapper.establishmentLicNo).Account.Phone
                    )
                );
                dataList.add(
                    new LPI_PDFSectionWrapper.DataWrapper(
                        'Funeral Director In Charge',
                        wrapper.inchargeName
                    )
                );
                dataList.add(
                    new LPI_PDFSectionWrapper.DataWrapper(
                        'Funeral Director In Charge License Number',
                        wrapper.inchargeLicNumber
                    )
                );
                dataList.add(
                    new LPI_PDFSectionWrapper.DataWrapper(
                        'Date Relationship Began Or Will Begin With Establishment',
                        wrapper.beginDate?.format()
                    )
                );
                LPI_PDFSectionWrapper establishmentInfoStep = new LPI_PDFSectionWrapper(
                    'Establishment - ' + counter,
                    2,
                    dataList
                );
                finalResultStep.addSubSection(establishmentInfoStep);

                dataList.clear();
                if(!wrapper.isDisable){
                    dataList.add(
                        new LPI_PDFSectionWrapper.DataWrapper(
                            'The board\'s records reflect the relationship listed below ' +
                            'is the current relationship that is on record for you.' +
                            ' In order for the board to update our records, please ' +
                            'indicate by checking Yes or No if this relationship is associated with you.',
                            String.valueOf(wrapper.relationshipAssociatedWithYou),
                            'checkbox'
                        )
                    );
                }
                LPI_PDFSectionWrapper establishmentDeclarationInfo = new LPI_PDFSectionWrapper(
                    '',
                    1,
                    dataList
                );
            
                finalResultStep.addSubSection(establishmentDeclarationInfo);
                counter += 1;
            }
        }
        return finalResultStep;
    }

    /**
     * @author                      : MTX Group Product Team
     * @since                       : Feb 26,2024
     * @description                 : This method will give Secton for Ownership Information
     * @param parId                 : String
     * @return                      : LPI_PDFSectionWrapper
     * @last modified by            : MTX Group Product Team
     * @last modified date          :
     * @modified details
     */
    public static LPI_PDFSectionWrapper getOwnerInfoStep(PreliminaryApplicationRef par) {
        LPI_PDFSectionWrapper finalResultStep = new LPI_PDFSectionWrapper(
            OWNNER_INFO_STEP,
            3,
            null
        );
        Map<String, Object> input = new Map<String, Object>();
        Map<String, Object> output = new Map<String, Object>();
        input.put('parid', par.Id);
        LPI_EFDFuneralEstOwnershipController.fetchOwnershipDetails(input, output);
        List<LPI_PDFSectionWrapper.DataWrapper> dataList = new List<LPI_PDFSectionWrapper.DataWrapper>();
       
        if (output != null && output.containsKey('OwnershipInfoBlock')) {
            List<Map<String, Object>> ownershipInfoList = (List<Map<String, Object>>) output.get(
                'OwnershipInfoBlock'
            );
            Integer counter = 1;
            for (Map<String, Object> ownerInfo : ownershipInfoList) {
                dataList.clear();
                dataList.add(
                    new LPI_PDFSectionWrapper.DataWrapper(
                        'Name',
                        String.valueOf(ownerInfo.get('Name'))
                    )
                );
                dataList.add(
                    new LPI_PDFSectionWrapper.DataWrapper(
                        'Ownership Percentage',
                        String.valueOf(Integer.valueOf(ownerInfo.get('OwnershipPercentage')))
                    )
                );
                dataList.add(
                    new LPI_PDFSectionWrapper.DataWrapper(
                        'Address',
                        String.valueOf(ownerInfo.get('Address'))
                    )
                );
                
                LPI_PDFSectionWrapper ownInfoStep = new LPI_PDFSectionWrapper(
                'Ownership Information - ' + counter,
                3,
                dataList
            );
                finalResultStep.addSubSection(ownInfoStep);
                counter += 1;
            }
        }
        return finalResultStep;
    }
}