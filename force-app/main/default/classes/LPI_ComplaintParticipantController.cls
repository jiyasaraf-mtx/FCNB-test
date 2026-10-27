/**
 * @description       : This Class was Created to Handle Compliant Participant Creation Part.
 * @author            : MTX Group Product Team
 * @group             : MTX Group Product Team
 * @last modified on  : 05-07-2024
 * @last modified by  : Ayush Dev
**/
public with sharing class LPI_ComplaintParticipantController {
    private static final String ATTORNEY_TEXT = 'Attorney';
    private static final String ATTORNEY_COMPLAINANT_TEXT = 'Attorney Complainant';
    private static final String ATTORNEY_Respondent_TEXT = 'Attorney Respondent';
    private static final String ATTORNEY_MODPR_TEXT = 'Attorney MODPR';
    private static final String ATTORNEY_Other_TEXT = 'Attorney Other';
    private static final String EMPLOYER_TEXT = 'Employer';
    private static final String OTHER_ENTITY_TEXT = 'Other Entity';
    private static final String INDIVIDUAL_TYPE_TEXT = 'Individual';
    private static final String BUSINESS_TYPE_TEXT = 'Business';
    private static final String INCIDENT_TYPE_TEXT = 'Incident';
    private static final String LOC_TYPE_OTHER = 'Other';
    private static final String DUPLICATE_INCIDENT_RECORD_ERR_MSG =  'Looks like you have added a duplicate Incident Record.';
    private static final String CA_COUNTRY_CODE = 'CA';
    private static final Set<String> CA_PROVINCE_CODES = new Set<String>{
        'AB', 'BC', 'MB', 'NB', 'NL', 'NS', 'NT', 'NU', 'ON', 'PE', 'QC', 'SK', 'YT'
    };
    private String complaintId;
    private String caseId;
    private String objectName;
    private String attorney_Role;
    public Set<sObject> cpListToInsert; 
    private Map<String, Account> keyToAccountMapToCreate;
    private List<LPI_Wrapper.RespondentWrapper> respondentWitnessList;
    private Map<String, sObject> keyToCpToInsert; 
    private Map<String, CaseParticipant> keyToCaseParticipantToInsert;
    private Map<String, Set<String>> emailPhoneToAccountKeyMap;
    private Set<String> professionSet;
    private Set<Id> businessIdSet;
    private Map<String, Account> keyToExistingAccountMap;
    private Map<String, Account> keyToAccountMap;
    private static String siteAdminId;
    public String objName;
    public LPI_ComplaintParticipantController(){
    }
    private static final String PUBLIC_COMPLAINT_SOBJECT_API_NAME = 'PublicComplaint';
    private static final String CASE_SOBJECT_API_NAME = 'Case';
    private static final String PATIENT_TEXT = 'Patient';
    private static final String ORG_RESP_CP_ROLE = 'Original Submitted Respondent';
    private static final String LICENSED_TEXT = 'Licensed';
    
    /**
    * @description Class Constructors Which Takes in ComplaintId.
    * @author MTX Group Product Team | 05-24-2023 
    * @param cpId 
    **/
    public LPI_ComplaintParticipantController(String recordId) {
        cpListToInsert = new Set<sObject>();
        keyToAccountMapToCreate = new Map<String, Account>();
        keyToCpToInsert = new Map<String, sObject>();
        respondentWitnessList = new List<LPI_Wrapper.RespondentWrapper>();
        professionSet = new Set<String>();
        businessIdSet = new Set<Id>();
        emailPhoneToAccountKeyMap = new Map<String, Set<String>>();
        Id recId = Id.valueOf(recordId);
        objectName = (recId!=null ? String.valueOf(recId.getSObjectType()):CASE_SOBJECT_API_NAME);
        if(objectName == PUBLIC_COMPLAINT_SOBJECT_API_NAME) {
            complaintId = recId;
        } else {
            caseId = recId;
        }
       siteAdminId = Site.getAdminId();
        siteAdminId = siteAdminId!=null?siteAdminId:UserInfo.getUserId();
    }


    /**  
    * @author                      : MTX Group Product Team
    * @since                       : 11 May 2023
    * @description                 : THis Method is Used to Abstract the Complaint Participant Creation, this method will be called by client. 
    * @param wrapper               : Complaints Wrapper provided.
    * @return                      : `void`
    * @last modified by            : MTX Group Product Team
    * @last modified date          : 24 May 2023
    * @modified details            : Code Review Fixes
    */
    public void createComplaintParticipant(LPI_Wrapper.ComplaintsWrapper wrapper) {
            this.createCompliantCPRecords(wrapper,LPI_LiteralConstant.COMPLAINANT_TEXT);
            this.createCompliantCPRecords(wrapper,PATIENT_TEXT);
            this.createWitnessCPRecords(wrapper);
            this.createAttorneyCPRecords(wrapper);
            this.createIncidentCPRecords(wrapper);
            this.createOtherEntitiesCPRecords(wrapper);
            this.createEmployerCPRecords(wrapper);
            this.handleDuplicateAccountsHelper();
            this.createLocAddressRecordsForAcc();
            this.linkAccountIdOnCPRecords();
    }

    /**  
    * @author                      : MTX Group Product Team
    * @since                       : 24 Oct 2023
    * @description                 : This Method is Used to Internally Call Respondent Records per Complaint,
    * @return                      : `void`
    * @last modified by            : MTX Group Product Team
    * @last modified date          : 24 May 2023
    * @modified details            : Code Review Fixes
    */
    public void createCPNew(Map<Integer,PublicComplaint> respCounterToPublicComplaintMap,Map<Integer,LPI_Wrapper.RespondentWrapperNew> respCounterToRespWrapperMap) {
        this.createRespondentRecords(respCounterToPublicComplaintMap, respCounterToRespWrapperMap);
    }

    public class ComplainantPatientWrapper {
        public String firstName;
        public String middleName;
        public String lastName;
        public String email;
        public String telephone;
        public String cellPhone;
        public String ssn;
        public Date dob;
        public LPI_Wrapper.AddressWrapper complainantAddressData;
    }
    
    /**  
    * @author                      : MTX Group Product Team
    * @since                       : 11 May 2023
    * @description                 : This Method is Used to Create Compliant - Complaint Participant Records.
    * @param wrapper               : Complaints Wrapper provided.
    * @return                      : `void`
    * @last modified by            : MTX Group Product Team
    * @last modified date          : 24 May 2023
    * @modified details            : Code Review Fixes
    */
    public void createCompliantCPRecords(LPI_Wrapper.ComplaintsWrapper complaintWrapperObj,String role) {
        try {
        String nameEmailKey;
        String namePhoneKey;
        ComplainantPatientWrapper wrapper = new ComplainantPatientWrapper();
        if(role == PATIENT_TEXT && complaintWrapperObj.patientInfo != null && complaintWrapperObj.isPatient==true) {
            wrapper = (ComplainantPatientWrapper)JSON.deserialize(JSON.serialize(complaintWrapperObj.patientInfo), ComplainantPatientWrapper.class); 
        } else if(role == LPI_LiteralConstant.COMPLAINANT_TEXT){
            wrapper = (ComplainantPatientWrapper)JSON.deserialize(JSON.serialize(complaintWrapperObj), ComplainantPatientWrapper.class); 
        } else {
            return;
        }
        wrapper.firstName = (String.isNotBlank(wrapper.firstName) ? wrapper.firstName.trim():wrapper.firstName);
        wrapper.middleName = (String.isNotBlank(wrapper.middleName) ? wrapper.middleName.trim():wrapper.middleName);
        wrapper.lastName = (String.isNotBlank(wrapper.lastName) ? wrapper.lastName.trim():wrapper.lastName);
        String complainantname =  String.isNotBlank(wrapper.firstName) &&
        String.isNotBlank(wrapper.middleName)
        ? wrapper.firstName + ' ' + wrapper.middleName + ' ' + wrapper.lastName
        : String.isNotBlank(wrapper.firstName)
                ? wrapper.firstName + ' ' + wrapper.lastName
                : String.isNotBlank(wrapper.middleName)
                    ? wrapper.middleName + ' ' + wrapper.lastName
                    : wrapper.lastName;

        String complainantAddress =
         wrapper.complainantAddressData.streetOne +
         '-' +
         wrapper.complainantAddressData.city +
         '-' +
         wrapper.complainantAddressData.state +
         '-' +
         wrapper.complainantAddressData.zipCode;
         String complainantKey = (complainantname +
         '-' +
         complainantAddress +
         '-' +
         LPI_LiteralConstant.PERSON_ACCOUNT_REC_TYPE_ID)
         .toLowerCase()
         .replaceAll(' ', '');
          Account personAcc = new Account();
          personAcc.RecordTypeId = LPI_LiteralConstant.PERSON_ACCOUNT_REC_TYPE_ID;
          personAcc.FirstName = wrapper.firstName;
          personAcc.MiddleName = wrapper.middleName;
          personAcc.LastName = wrapper.lastName;
          personAcc.Combined_Name__pc = String.isNotBlank(
                  personAcc.FirstName
              ) && String.isNotBlank(personAcc.MiddleName)
              ? personAcc.FirstName.trim() +
                ' ' +
                personAcc.MiddleName.trim() +
                ' ' +
                personAcc.LastName.trim()
              : String.isNotBlank(personAcc.FirstName)
                    ? personAcc.FirstName.trim() + ' ' + personAcc.LastName.trim()
                    : String.isNotBlank(personAcc.MiddleName)
                          ? personAcc.MiddleName.trim() + ' ' + personAcc.LastName.trim()
                          : personAcc.LastName.trim();

          personAcc.PersonHomePhone = wrapper.telephone;
          personAcc.Phone = wrapper.cellPhone;
          personAcc.PersonOtherStreet = wrapper.complainantAddressData.streetOne;
          personAcc.PersonOtherCity = wrapper.complainantAddressData.city;
          personAcc.OwnerId = siteAdminId;
          personAcc.PersonOtherPostalCode = wrapper.complainantAddressData.zipCode;
          personAcc.PersonEmail = wrapper.email;
          applyPersonOtherAddress(personAcc, wrapper.complainantAddressData);
          personAcc.Social_Security_Number__c = wrapper.ssn;
          personAcc.Date_of_Birth__c = wrapper.dob;
        if(String.isNotBlank(personAcc.PersonEmail)) {
            nameEmailKey = (complainantname +
                '-' +
                personAcc.PersonEmail + '-'
                + LPI_LiteralConstant.PERSON_ACCOUNT_REC_TYPE_ID)
                .toLowerCase()
                .replaceAll(' ', '');
        }
        if(String.isNotBlank(personAcc.PersonHomePhone)) {
          namePhoneKey = (complainantname +
              '-' +
              personAcc.PersonHomePhone + '-'
              + LPI_LiteralConstant.PERSON_ACCOUNT_REC_TYPE_ID)
              .toLowerCase()
              .replaceAll(' ', '');
        }
            if(!emailPhoneToAccountKeyMap.containsKey(nameEmailKey) && 
                !emailPhoneToAccountKeyMap.containsKey(namePhoneKey)) {
                keyToAccountMapToCreate.put(complainantKey, personAcc);
            }
            if(!emailPhoneToAccountKeyMap.containsKey(nameEmailKey) && nameEmailKey != NULL) {
                emailPhoneToAccountKeyMap.put(
                    nameEmailKey,
                    new Set<String>()
                );     
            }
            if(!emailPhoneToAccountKeyMap.containsKey(namePhoneKey) && namePhoneKey != NULL) {
                emailPhoneToAccountKeyMap.put(
                    namePhoneKey,
                    new Set<String>()
                );     
            }
            if(namePhoneKey!=null) {
                emailPhoneToAccountKeyMap.get(namePhoneKey).add(complainantKey);
            }
            if(nameEmailKey!=null) {
                emailPhoneToAccountKeyMap.get(nameEmailKey).add(complainantKey);
            }
            ComplaintParticipant cp = createComplaintParticipant(
                role,
                complaintId
            );
            keyToCpToInsert.put(cp.Role + 'role-' + complainantKey, cp);
            keyToCpToInsert.put(cp.Role + 'role-' + nameEmailKey, cp);
            keyToCpToInsert.put(cp.Role + 'role-' + namePhoneKey, cp);
        }
        catch(Exception ex) {
            LPI_ExceptionManager.logException('LPI_ComplaintParticipantController', 'createCompliantCPRecords', ex);
            throw new AuraHandledException(ex.getMessage());
        }
    }

    /**  
    * @author                      : MTX Group Product Team
    * @since                       : 11 May 2023
    * @description                 : This Method is Used to Create Witness Complaint Participant Records.
    * @param wrapper               : Complaints Wrapper provided.
    * @return                      : `void`
    * @last modified by            : MTX Group Product Team
    * @last modified date          : 24 May 2023
    * @modified details            : Code Review Fixes
    */
    public void createWitnessCPRecords(LPI_Wrapper.ComplaintsWrapper wrapper) {
        try {
            String key;
            String address;
            String namePhoneKey;
            String nameEmailKey;
            Set<String> witnessFieldsSet = new Set<String>();
            Account acc = new Account();
            for (
                LPI_Wrapper.RespondentWrapper witness : wrapper.witnessData
            ) {
                namePhoneKey = null;
                acc = createPersonAccount(
                    new Account(),
                    witness,
                    siteAdminId
                ); 
                address =
                    witness.addressData.streetOne +
                    '-' +
                    witness.addressData.city +
                    '-' +
                    witness.addressData.state +
                    '-' +
                    witness.addressData.zipCode;
                key = (acc.Combined_Name__pc +
                    '-' +
                    address +
                    '-' +
                    LPI_LiteralConstant.PERSON_ACCOUNT_REC_TYPE_ID)
                    .toLowerCase()
                    .replaceAll(' ', '');
                if (String.isNotBlank(witness.telephone)) {
                    namePhoneKey = (acc.Combined_Name__pc +
                    '-' +
                    witness.telephone + '-' + LPI_LiteralConstant.PERSON_ACCOUNT_REC_TYPE_ID).toLowerCase().replaceAll(' ', '');
                }
                if(String.isNotBlank(witness.email)) {
                    nameEmailKey = (acc.Combined_Name__pc +
                    '-' +
                    witness.email + '-' + LPI_LiteralConstant.PERSON_ACCOUNT_REC_TYPE_ID).toLowerCase().replaceAll(' ', '');
                }
                if (
                    (String.isNotBlank(key) && witnessFieldsSet.contains(key)) ||
                    (String.isNotBlank(namePhoneKey) && witnessFieldsSet.contains(namePhoneKey)) || 
                    (String.isNotBlank(nameEmailKey) && witnessFieldsSet.contains(nameEmailKey))
                ) {
                    throw new LPI_Exception(
                        'Looks like you have added duplicate witnesses.'
                    );
                }
                witness.role = LPI_LiteralConstant.WITNESS_TEXT;
                sObject cp; 
                if(objectName== PUBLIC_COMPLAINT_SOBJECT_API_NAME) {
                    cp = createComplaintParticipant(
                        LPI_LiteralConstant.WITNESS_TEXT,
                        complaintId
                    );

                }
                else {
                    cp = LPI_CreateCaseAndComplaintCase.createCaseParticipant(null,LPI_LiteralConstant.WITNESS_TEXT,caseId);
                }
                keyToCpToInsert.put( witness.role + 'role-' + key, cp);
                witnessFieldsSet.add(key);
                witnessFieldsSet.add(namePhoneKey);
                respondentWitnessList.add(witness);
                if (String.isNotBlank(acc.PersonHomePhone)) {
                    namePhoneKey = (acc.Combined_Name__pc +
                        '-' +
                        acc.PersonHomePhone)
                        .toLowerCase()
                        .replaceAll(' ', '');
                    keyToCpToInsert.put( witness.role + 'role-' + namePhoneKey, cp);
                }

                if(String.isNotBlank(acc.PersonEmail)) {
                    nameEmailKey = (acc.Combined_Name__pc +
                    '-' +
                    acc.PersonEmail + '-' + LPI_LiteralConstant.PERSON_ACCOUNT_REC_TYPE_ID)
                    .toLowerCase()
                    .replaceAll(' ', '');
                    keyToCpToInsert.put( witness.role + 'role-' + nameEmailKey, cp);
                }
                if (!emailPhoneToAccountKeyMap.containsKey(namePhoneKey) && !emailPhoneToAccountKeyMap.containsKey(nameEmailKey)) {
                    keyToAccountMapToCreate.put(key, acc);
                }
                if (!emailPhoneToAccountKeyMap.containsKey(namePhoneKey) && namePhoneKey != NULL) {
                    emailPhoneToAccountKeyMap.put(
                        namePhoneKey,
                        new Set<String>()
                    );
                } 
                if (!emailPhoneToAccountKeyMap.containsKey(nameEmailKey) && nameEmailKey != NULL) {
                    emailPhoneToAccountKeyMap.put(
                        nameEmailKey,
                        new Set<String>()
                    );
                } 
                if(nameEmailKey!=null) {
                    emailPhoneToAccountKeyMap.get(nameEmailKey).add(key);
                }
                if(namePhoneKey!=null) {
                    emailPhoneToAccountKeyMap.get(namePhoneKey).add(key);
                }
            }
        }
        catch(Exception ex) {
            LPI_ExceptionManager.logException('LPI_ComplaintParticipantController', 'createWitnessCPRecords', ex);
            throw new LPI_Exception(ex.getMessage());
        }
    }

     /**  
    * @author                      :MTX Group Product Team
    * @since                       : 20 Feb 2024
    * @description                 : This Method is Used to Create case - case Participant Records.
    * @param wrapper               : Complaints Wrapper provided.
    * @return                      : `void`
    */
    public void createEmployerCPRecords(LPI_Wrapper.ComplaintsWrapper wrapper) {
        try {
            String key;
            String address;
            String namePhoneKey;
            String nameEmailKey;
           Set<String> employerFieldsSet = new Set<String>();
            Account acc = new Account();
            if(wrapper?.employerData == null){
                return;
            }
            for (
                LPI_Wrapper.RespondentWrapper employer : wrapper.employerData
            ) {
                acc = createBusinessAccount(
                    new Account(),
                    employer,
                    siteAdminId
                ); 
                key = (acc.Name +
                    '-' +
                    acc.BillingStreet +
                    '-' +
                    acc.BillingCity +
                    '-' +
                    acc.BillingStateCode +
                    '-' +
                    acc.BillingPostalCode +
                    '-' +
                    LPI_LiteralConstant.BUSINESS_ACCOUNT_REC_TYPE_ID)
                    .toLowerCase()
                    .replaceAll(' ', '');
                keyToAccountMapToCreate.put(key, acc);
    
                employer.role =EMPLOYER_TEXT ;
                sObject cp; 
                
                if(objectName== PUBLIC_COMPLAINT_SOBJECT_API_NAME) {
                    cp = createComplaintParticipant(
                        EMPLOYER_TEXT,
                        complaintId
                    );
    
                }
                else {
                    cp = LPI_CreateCaseAndComplaintCase.createCaseParticipant(null,EMPLOYER_TEXT,caseId);
                }
                keyToCpToInsert.put( employer.role + 'role-' + key, cp);
                employerFieldsSet.add(key);
                cpListToInsert.add(cp);
            }
        }
        catch(Exception ex) {
            LPI_ExceptionManager.logException('LPI_ComplaintParticipantController', 'createEmployerCPRecords', ex);
            throw new LPI_Exception(ex.getMessage());
        }
    }


    /**  
    * @author                      : MTX Group Product Team
    * @since                       : 24 Oct 2023
    * @description                 : This Method is Used to Create Respondent Records per Complaint, this internall calls Business_Complaint__c creation method.
    * @return                      : `void`
    * @last modified by            : MTX Group Product Team
    * @last modified date          : 24 May 2023
    * @modified details            : Code Review Fixes
    */
    public void createRespondentRecords(Map<Integer,PublicComplaint> respCounterToPublicComplaintMap,Map<Integer,LPI_Wrapper.RespondentWrapperNew> respCounterToRespWrapperMap) {
        try {
            String address;
            String key;
            String namePhoneKey;
            String nameEmailKey;
            Account acc = new Account();
            ComplaintParticipant cp;
            for(Integer respCounter : respCounterToPublicComplaintMap.keySet()) {
                cp = new ComplaintParticipant();
                PublicComplaint pc = respCounterToPublicComplaintMap.get(respCounter);
                LPI_Wrapper.RespondentWrapperNew resp = respCounterToRespWrapperMap.get(respCounter);
                
                if(resp.professionDetails.licensedUnlicensed == LICENSED_TEXT &&
                    String.isNotBlank(resp.licenseDetails.accountId)) {
                       
                        cp = createComplaintParticipant(
                            LPI_LiteralConstant.RESPONDENT_TEXT,
                            pc.Id
                        );
                        cp.ParticipantId = resp.licenseDetails.accountId;
                        cpListToInsert.add(cp);
                        
                        businessIdSet.add(resp.licenseDetails.businessId);  
                } else {
                    cp = createComplaintParticipant(
                        LPI_LiteralConstant.RESPONDENT_TEXT,
                        pc.Id
                    );
                    if(resp.licenseDetails.authorizationType=='Business' || 
                        resp.professionDetails.entityOrIndividual=='Entity'
                        ) { 
                        acc = createBusinessAccount(
                            new Account(),
                            resp,
                            siteAdminId
                        );
                        key = (acc.Name +
                        '-' +
                        acc.BillingStreet +
                        '-' +
                        acc.BillingCity +
                        '-' +
                        acc.BillingStateCode +
                        '-' +
                        acc.BillingPostalCode +
                        '-' +
                        LPI_LiteralConstant.BUSINESS_ACCOUNT_REC_TYPE_ID)
                        .toLowerCase()
                        .replaceAll(' ', '');
                        keyToAccountMapToCreate.put(key, acc);
                        keyToCpToInsert.put(cp.Role + 'role-' + key, cp);
                    }
                    else if(resp.licenseDetails.authorizationType=='Individual' || 
                            resp.professionDetails.entityOrIndividual=='Individual'
                           ) { 
                        acc = createPersonAccount(
                            new Account(),
                            resp,
                            siteAdminId
                        );
                        acc.Employment_Status__c = resp.employerInfo.employmentStatus;
                        key = (acc.Combined_Name__pc +
                            '-' +
                            acc.PersonOtherStreet +
                            '-' +
                            acc.PersonOtherCity +
                            '-' +
                            acc.PersonOtherStateCode +
                            '-' +
                            acc.PersonOtherPostalCode +
                            '-' +
                            LPI_LiteralConstant.PERSON_ACCOUNT_REC_TYPE_ID)
                            .toLowerCase()
                            .replaceAll(' ', '');
                        
                        keyToCpToInsert.put(cp.Role + 'role-' + key, cp);
                        if (String.isNotBlank(acc.PersonHomePhone)) {
                            namePhoneKey = (acc.Combined_Name__pc +
                                '-' +
                                acc.PersonHomePhone + '-' + LPI_LiteralConstant.PERSON_ACCOUNT_REC_TYPE_ID)
                                .toLowerCase()
                                .replaceAll(' ', '');
                            keyToCpToInsert.put(cp.Role + 'role-' + namePhoneKey, cp);
                        }
                        if(String.isNotBlank(acc.PersonEmail)) {
                            nameEmailKey = (acc.Combined_Name__pc +
                            '-' +
                            acc.PersonEmail + '-'
                            + LPI_LiteralConstant.PERSON_ACCOUNT_REC_TYPE_ID)
                            .toLowerCase()
                            .replaceAll(' ', '');
                            keyToCpToInsert.put(cp.Role + 'role-' + nameEmailKey, cp);
                           
                        }

                        if(!emailPhoneToAccountKeyMap.containsKey(nameEmailKey) && !emailPhoneToAccountKeyMap.containsKey(namePhoneKey)) {
                            keyToAccountMapToCreate.put(key, acc);
                        }

                        if(!emailPhoneToAccountKeyMap.containsKey(nameEmailKey) && nameEmailKey!=null) {
                            emailPhoneToAccountKeyMap.put(
                                nameEmailKey,
                                new Set<String>()
                            );
                        }
                        if (!emailPhoneToAccountKeyMap.containsKey(namePhoneKey) && namePhoneKey!=null) {
                            emailPhoneToAccountKeyMap.put(
                                namePhoneKey,
                                new Set<String>()
                            );
                        }
                        if(namePhoneKey != null) {
                            emailPhoneToAccountKeyMap.get(namePhoneKey).add(key);
                        }
                        if(nameEmailKey != null) {
                            emailPhoneToAccountKeyMap.get(nameEmailKey).add(key);
                        }
                        if(resp.professionDetails.licensedUnlicensed != LICENSED_TEXT) {
                            createAccountforEmployer(resp);
                        }
                    }
                }
            }
            createBusinessParticipantRecords(respCounterToPublicComplaintMap,respCounterToRespWrapperMap);
            
        } catch(Exception ex) {
            LPI_ExceptionManager.logException('LPI_ComplaintParticipantController', 'createRespondentRecords', ex);
            throw new LPI_Exception(ex.getMessage());
        }
    }   

    /**  
    * @author                      : MTX Group Product Team
    * @since                       : 11 May 2023
    * @description                 : This Method is Used to Create Business Account for Employer.
    * @param respondent            : Complaint Record Created.
    * @return                      : `void`
    * @last modified by            : MTX Group Product Team
    * @last modified date          : 24 May 2023
    * @modified details            : Code Review Fixes
    */
    private void createAccountforEmployer(LPI_Wrapper.RespondentWrapperNew respondent) {
        if(respondent.employerInfo==null || String.isBlank(respondent.employerInfo.employerName)) {
            return;
        }
        ComplaintParticipant cp = createComplaintParticipant(
            EMPLOYER_TEXT,
            complaintId
        );
        Account acc = createBusinessAccount(
            new Account(),
            respondent.employerInfo,
            siteAdminId
        );

        String key = (acc.Name +
        '-' +
        acc.BillingStreet +
        '-' +
        acc.BillingCity +
        '-' +
        acc.BillingStateCode +
        '-' +
        acc.BillingPostalCode +
        '-' +
        LPI_LiteralConstant.BUSINESS_ACCOUNT_REC_TYPE_ID)
        .toLowerCase()
        .replaceAll(' ', '');
        keyToCpToInsert.put(cp.Role + 'role-' + key, cp);
        keyToAccountMapToCreate.put(key, acc);
    }

  /**  
    * @author                      : MTX Group Product Team
    * @since                       : 11 May 2023
    * @description                 : This Method is Used to Create Business Account for Given Account and Wrapper.
    * @param wrapper               : Complaint Record Created.
    * @param account               :  Account 
    * @return                      : `Account`
    * @last modified by            : MTX Group Product Team
    * @last modified date          : 24 May 2023
    * @modified details            : Code Review Fixes
    */
    private Account createBusinessAccount(  Account account,
                                            LPI_Wrapper.EmployerWrapper empInfo,
                                            Id ownerId) {
        account.RecordTypeId = LPI_LiteralConstant.BUSINESS_ACCOUNT_REC_TYPE_ID;
        account.Name = empInfo.employerName;
        account.Phone = empInfo.telephone;
        account.Buisness_Email__c = empInfo.email;
        account.BillingStreet = empInfo.employerAddress.streetOne;
        account.BillingCity = empInfo.employerAddress.city;
        account.BillingPostalCode = empInfo.employerAddress.zipCode;
        applyBillingAddress(account, empInfo.employerAddress);
        account.OwneriD = ownerId;
        return account;
    }

   
    /**  
    * @author                      : MTX Group Product Team
    * @since                       : 11 May 2023
    * @description                 : This Method is Used to Create Attorney Complaint Participant Records.
    * @param wrapper               : Complaint Record Created.
    * @return                      : `void`
    * @last modified by            : MTX Group Product Team
    * @last modified date          : 24 May 2023
    * @modified details            : Earlier there was only one attorney per complaint - refactoring it to multiple attornies.
    */
    public void createAttorneyCPRecords(LPI_Wrapper.ComplaintsWrapper wrapper) {
        try {
            String key;
            String address;
            String namePhoneKey;
            String nameEmailKey;
            Account acc; 
            if(wrapper.attorneyInfo == null || wrapper.attorneyInfo.isEmpty()) { 
                return; 
            }
            attorney_Role = String.isBlank(attorney_Role) ? ATTORNEY_COMPLAINANT_TEXT : attorney_Role;
            for(LPI_Wrapper.AttorneyWrapper attorneyObj : wrapper.attorneyInfo) {
                if(
                    String.isBlank(attorneyObj.firstName) || 
                    String.isBlank(attorneyObj.lastName)
                ) {
                    continue;
                }
                acc = createPersonAccount(
                    new Account(),
                    attorneyObj,
                    siteAdminId
                );
                sObject cp;
                if(objectName== PUBLIC_COMPLAINT_SOBJECT_API_NAME) {
                    ComplaintParticipant tmpComplaintPartRec = createComplaintParticipant(
                        attorney_Role,
                        complaintId
                    );
                    cp = tmpComplaintPartRec;
                }
                else {
                    CaseParticipant tmpCasePartRec = LPI_CreateCaseAndComplaintCase.createCaseParticipant(null,attorney_Role,caseId);
                    cp = tmpCasePartRec;
                }
                address =
                attorneyObj.addressData.streetOne +
                '-' +
                attorneyObj.addressData.city +
                '-' +
                attorneyObj.addressData.state +
                '-' +
                attorneyObj.addressData.zipCode;

                key = (acc.Combined_Name__pc +
                '-' +
                address +
                '-' +
                LPI_LiteralConstant.PERSON_ACCOUNT_REC_TYPE_ID)
                .toLowerCase()
                .replaceAll(' ', '');
                    keyToCpToInsert.put(attorney_Role + 'role-' + key, cp);
                    if (String.isNotBlank(acc.PersonHomePhone)) { 
                        namePhoneKey = (acc.Combined_Name__pc +
                            '-' +
                            acc.PersonHomePhone + '-' + LPI_LiteralConstant.PERSON_ACCOUNT_REC_TYPE_ID)
                            .toLowerCase()
                            .replaceAll(' ', '');
                        keyToCpToInsert.put(attorney_Role + 'role-' + namePhoneKey, cp);
                    }
                    if (String.isNotBlank(acc.PersonEmail)) { 
                        nameEmailKey = (acc.Combined_Name__pc +
                            '-' +
                            acc.PersonEmail + '-' + LPI_LiteralConstant.PERSON_ACCOUNT_REC_TYPE_ID)
                            .toLowerCase()
                            .replaceAll(' ', '');
                        keyToCpToInsert.put(attorney_Role + 'role-' + nameEmailKey, cp);
                    }
                    if (!emailPhoneToAccountKeyMap.containsKey(namePhoneKey) &&
                        !emailPhoneToAccountKeyMap.containsKey(nameEmailKey)) {
                        keyToAccountMapToCreate.put(key, acc);
                    }
                    if (!emailPhoneToAccountKeyMap.containsKey(namePhoneKey) && namePhoneKey!=null) {
                        emailPhoneToAccountKeyMap.put(
                            namePhoneKey,
                            new Set<String>()
                        );
                    }
                    if(!emailPhoneToAccountKeyMap.containsKey(nameEmailKey) && nameEmailKey!=null) {
                        emailPhoneToAccountKeyMap.put(
                            nameEmailKey,
                            new Set<String>()
                        );
                    }
                    if(namePhoneKey!=null) {
                        emailPhoneToAccountKeyMap.get(namePhoneKey).add(key);
                    }
                    if(nameEmailKey!=null) {
                        emailPhoneToAccountKeyMap.get(nameEmailKey).add(key);
                    }
            }
        }
        catch(Exception ex) {
            LPI_ExceptionManager.logException('LPI_ComplaintParticipantController', 'createAttorneyComplainantCPRecords', ex);
            throw new LPI_Exception(ex.getMessage());
        }
    }


    /**  
    * @author                      : MTX Group Product Team
    * @since                       : 11 May 2023
    * @description                 : This Method is Used to Create Incident Records FOr the Given Complaint.
    * @param wrapper               : Complaint Record Created.
    * @return                      : `void`
    * @last modified by            : MTX Group Product Team
    * @last modified date          : 24 May 2023
    * @modified details            : Code Review Fixes
    */
    public void createIncidentCPRecords(LPI_Wrapper.ComplaintsWrapper wrapper) {
        try {
        if(complaintId==null) {
            return;
        }
        LPI_Wrapper.ComplaintsWrapper  complaintDetailsWrapper = LPI_ComplaintsController.fetchComplaintDetails(complaintId,new LPI_Wrapper.ComplaintsWrapper());
        Schema.Location locRecord;
        Schema.Address addressRec;
        if(wrapper.incidentList!=null && !wrapper.incidentList.isEmpty()) {
            LPI_Wrapper.RespondentWrapper record = wrapper.incidentList[0];            
                locRecord = LPI_AddressUtility.createLocationRecord(null,record.entityName,INCIDENT_TYPE_TEXT,null);
                locRecord = (Schema.Location)LPI_WithoutSharingUtility.insertSObject(locRecord);
                addressRec =new Schema.Address();
                addressRec.ParentId=locRecord.Id;
                addressRec.Street = record.addressData!=null?record.addressData.streetOne:'';
                addressRec.City = record.addressData!=null?record.addressData.city:'';
                addressRec.StateCode = record.addressData!=null?record.addressData.state:'';
                addressRec.PostalCode = record.addressData!=null?record.addressData.zipCode:'';
                addressRec.LocationType=INCIDENT_TYPE_TEXT;
                addressRec.Do_not_populate_Lat_Long__c = true;
                LPI_WithoutSharingUtility.insertSObject(addressRec);
        }
            Incident incidentRec = new Incident();
            incidentRec.Complaint_Number__c = complaintId;
            if(locRecord!=null && String.isNotBlank(locRecord.Id)) {
                incidentRec.Location__c = locRecord.Id;
            }
            if(wrapper.incidentStartDate == null && wrapper.incidentEndDate == null) {
                return;
            }
            if(wrapper.incidentStartDate!=null) {
                incidentRec.StartDateTime = DateTime.newInstance(wrapper.incidentStartDate.year(),wrapper.incidentStartDate.month() , wrapper.incidentStartDate.day(),0,0,0);
            }
            if(wrapper.incidentEndDate!=null) {
                incidentRec.EndDateTime = DateTime.newInstance(wrapper.incidentEndDate.year(),wrapper.incidentEndDate.month() , wrapper.incidentEndDate.day(),0,0,0);
            }
            
            incidentRec.Urgency='Medium';
            incidentRec.Subject='Incident Details for Complaint - '+complaintDetailsWrapper.complaintName+' Incident Date - '+wrapper.incidentDate;
            incidentRec.Board_Name__c = complaintDetailsWrapper.selectedBoardName;
            LPI_WithoutSharingUtility.insertSObject(incidentRec);

    } catch(Exception ex) {
        LPI_ExceptionManager.logException('LPI_ComplaintParticipantController', 'createIncidentCPRecords', ex);
        throw new LPI_Exception(ex.getMessage());
    }
    }
    /**  
    * @author                      : MTX Group Product Team
    * @since                       : 11 May 2023
    * @description                 : Method is Used to Create Other Entites Complaint Participant Records.
    * @param wrapper               : Complaint Record Created.
    * @return                      : `void`
    * @last modified by            : MTX Group Product Team
    * @last modified date          : 24 May 2023
    * @modified details            : Code Review Fixes
    */
    public void createOtherEntitiesCPRecords(LPI_Wrapper.ComplaintsWrapper wrapper) {
        try {
        Set<String> otherEntitiesSet = new Set<String>();
        String key;
        String namePhoneKey;
        String nameEmailKey;
        if(wrapper.entitiesData==null) {
            return;
        }
        for(LPI_Wrapper.RespondentWrapper entityObj : wrapper.entitiesData) {

                 Account acc = createBusinessAccount(
                    new Account(),
                    entityObj,
                    siteAdminId
                );
                key = (acc.Name +
                    '-' +
                    acc.BillingStreet +
                    '-' +
                    acc.BillingCity +
                    '-' +
                    acc.BillingStateCode +
                    '-' +
                    acc.BillingPostalCode +
                    '-' +
                    LPI_LiteralConstant.BUSINESS_ACCOUNT_REC_TYPE_ID)
                    .toLowerCase()
                    .replaceAll(' ', '');
                keyToAccountMapToCreate.put(key, acc);

              
            sObject csp; 
            entityObj.role =OTHER_ENTITY_TEXT ;
            otherEntitiesSet.add(key);
            


            if(objectName== PUBLIC_COMPLAINT_SOBJECT_API_NAME) {
                csp = createComplaintParticipant(
                    OTHER_ENTITY_TEXT,
                    complaintId
                );
                csp.put('Entity_Representative_Contacted__c',entityObj.entityRepresentative);
            }
            else {
                csp = LPI_CreateCaseAndComplaintCase.createCaseParticipant(null,OTHER_ENTITY_TEXT,caseId);
            }
            keyToCpToInsert.put( entityObj.role + 'role-' + key, csp);
         }
        }
         catch(Exception ex) {
            LPI_ExceptionManager.logException('LPI_ComplaintParticipantController', 'createOtherEntitiesCPRecords', ex);
        throw new LPI_Exception(ex.getMessage());
    }

    }

    /**  
    * @author                      : MTX Group Product Team
    * @since                       : 11 May 2023
    * @description                 : This Method is Used to Find Potential Duplicate Accounts and Remove them before Inserting in System.
    * @return                      : `void`
    * @last modified by            : MTX Group Product Team
    * @last modified date          : 24 May 2023
    * @modified details            : Code Review Fixes
    */
    public void handleDuplicateAccountsHelper() {
        try {
            //System.assert(false,'893>>>');
        keyToExistingAccountMap = new Map<String, Account>();
        String nameEmailKey;
        String namePhoneKey;
        String key;
        if(keyToAccountMapToCreate.isEmpty()) {
            return;
        }
        Set<String> accIdSet = new Set<String>();
        Set<String> stringToRemoveSet = new Set<String>();
        for (
            Datacloud.MatchRecord matchRecord : LPI_WithoutSharingUtility.getDuplicateRecords(
                keyToAccountMapToCreate.values()
            )
        ) {
            accIdSet.add((String) matchRecord.getRecord().get('Id'));
        }
        if (!accIdSet.isEmpty()) {
            String fields = 'ID, Name,MiddleName,PersonHomePhone,PersonEmail,FirstName,LastName,Combined_Name__pc, PersonOtherStreet,';
                   fields+='PersonOtherCity, PersonOtherStateCode, PersonOtherPostalCode,BillingStreet,BillingCity,BillingStateCode,BillingPostalCode,RecordTypeId,PersonOtherCountryCode,Other_State__c,County__c, BillingCountryCode';
            String whereClause =
                'ID IN ' +
                LPI_ServiceUtility.getStringValuesByList(
                    new List<String>(accIdSet)
                );
            String name;
            for (
                Account accountRec : (new LPI_AccountDAO.LPI_AccountWithoutSharingDAO()).getAccountByDymanicQuery(
                    fields,
                    whereClause,
                    '40000',
                    null,
                    null
                )
            ) {
                    name = accountRec.RecordTypeId ==
                    LPI_LiteralConstant.PERSON_ACCOUNT_REC_TYPE_ID
                        ? String.isNotBlank(accountRec.Combined_Name__pc)
                                ? accountRec.Combined_Name__pc
                                : String.isNotBlank(accountRec.MiddleName) &&
                                    String.isNotBlank(accountRec.FirstName)
                                    ? accountRec.FirstName +
                                        accountRec.MiddleName +
                                        accountRec.LastName
                                    : String.isNotBlank(accountRec.MiddleName)
                                            ? accountRec.MiddleName +
                                            accountRec.LastName
                                            : String.isNotBlank(
                                                    accountRec.FirstName
                                                )
                                                ? accountRec.FirstName +
                                                    accountRec.LastName
                                                : accountRec.LastName
                        : null;
                    key = accountRec.RecordTypeId ==
                    LPI_LiteralConstant.PERSON_ACCOUNT_REC_TYPE_ID
                      ? name +
                        '-' +
                        accountRec.PersonOtherStreet +
                        '-' +
                        accountRec.PersonOtherCity +
                        '-' +
                        accountRec.PersonOtherStateCode +
                        '-' +
                        accountRec.PersonOtherPostalCode +
                        '-' +
                        LPI_LiteralConstant.PERSON_ACCOUNT_REC_TYPE_ID
                      : accountRec.Name +
                        '-' +
                        accountRec.BillingStreet +
                        '-' +
                        accountRec.BillingCity +
                        '-' +
                        accountRec.BillingStateCode +
                        '-' +
                        accountRec.BillingPostalCode +
                        '-' +
                        LPI_LiteralConstant.BUSINESS_ACCOUNT_REC_TYPE_ID;

                    key = key.toLowerCase().replaceAll(' ', '');
                    keyToExistingAccountMap.put(key, accountRec);
                    if (
                        String.isNotBlank(accountRec.PersonEmail) &&
                        accountRec.RecordTypeId ==
                        LPI_LiteralConstant.PERSON_ACCOUNT_REC_TYPE_ID
                    ) {
                        nameEmailKey = (name +
                            '-' +
                            accountRec.PersonEmail + '-' + LPI_LiteralConstant.PERSON_ACCOUNT_REC_TYPE_ID)
                            .toLowerCase()
                            .replaceAll(' ', '');
                        keyToExistingAccountMap.put(nameEmailKey, accountRec);
                    }
                    if (
                        String.isNotBlank(accountRec.PersonHomePhone) &&
                        accountRec.RecordTypeId ==
                        LPI_LiteralConstant.PERSON_ACCOUNT_REC_TYPE_ID
                    ) {
                        namePhoneKey = (name +
                            '-' +
                            accountRec.PersonHomePhone + '-' + LPI_LiteralConstant.PERSON_ACCOUNT_REC_TYPE_ID)
                            .toLowerCase()
                            .replaceAll(' ', '');
                        keyToExistingAccountMap.put(namePhoneKey, accountRec);
                    }
                    keyToAccountMapToCreate.remove(key);
                    if (emailPhoneToAccountKeyMap.containsKey(nameEmailKey)) {
                        stringToRemoveSet.addAll(
                            emailPhoneToAccountKeyMap.get(nameEmailKey)
                        );
                    }
                    if (emailPhoneToAccountKeyMap.containsKey(namePhoneKey)) {
                        stringToRemoveSet.addAll(
                            emailPhoneToAccountKeyMap.get(namePhoneKey)
                        );
                    }    
            }
        }    
            for (String keyString : stringToRemoveSet) {
                keyToAccountMapToCreate.remove(keyString);
            }
            LPI_TriggerHandler.bypass('LPI_AccountTriggerHandler');
            if (LPI_TriggerHandler.isBypassed('LPI_AccountTriggerHandler')) {
                LPI_WithoutSharingUtility.upsertSObjectList(
                    keyToAccountMapToCreate.values()
                );
                LPI_TriggerHandler.clearBypass('LPI_AccountTriggerHandler');
            }
            keyToAccountMapToCreate.putAll(keyToExistingAccountMap);
            keyToAccountMap = new Map<String, Account>();
            for (String keyString : keyToAccountMapToCreate.keySet()) {
                if (
                    keyToAccountMapToCreate.get(keyString).RecordTypeId !=
                    LPI_LiteralConstant.PERSON_ACCOUNT_REC_TYPE_ID
                ) {
                    continue;
                }
                Account acc = keyToAccountMapToCreate.get(keyString); 
                if (String.isNotBlank(acc.PersonHomePhone)) {
                    namePhoneKey = (acc.Combined_Name__pc +
                        '-' +
                        acc.PersonHomePhone + '-' + LPI_LiteralConstant.PERSON_ACCOUNT_REC_TYPE_ID)
                        .toLowerCase()
                        .replaceAll(' ', '');
                    keyToAccountMap.put(namePhoneKey, acc);

                } else if (String.isNotBlank(acc.PersonEmail)) {
                    nameEmailKey = (acc.Combined_Name__pc +
                        '-' +
                        acc.PersonEmail + '-' + LPI_LiteralConstant.PERSON_ACCOUNT_REC_TYPE_ID)
                        .toLowerCase()
                        .replaceAll(' ', '');
                    keyToAccountMap.put(nameEmailKey, acc);
                }
            }
       }
        catch(Exception ex) {
            String detailMessage = resolveExceptionMessage(ex);
            LPI_ExceptionManager.logException(
                'LPI_ComplaintParticipantController',
                'handleDuplicateAccountsHelper',
                'ERROR',
                detailMessage,
                ex.getStackTraceString(),
                ex.getLineNumber()
            );
            throw new LPI_Exception(detailMessage);
        }
    }

    /**
    * @description 
    * @author MTX Group Product Team | 05-07-2024 
    * @param acc 
    * @return Schema.Address 
    **/
        private Schema.Address createAddressRecord(Account acc) {
        Schema.Address addressRec = new Schema.Address();
        if(acc.RecordTypeId == LPI_LiteralConstant.PERSON_ACCOUNT_REC_TYPE_ID) {
            addressRec.CountryCode = acc.PersonOtherCountryCode;
            addressRec.PostalCode = acc.PersonOtherPostalCode;
            addressRec.Street = acc.PersonOtherStreet;
            addressRec.City = acc.PersonOtherCity;
            if (usesStateCodePicklist(acc.PersonOtherCountryCode)) {
                addressRec.StateCode = acc.PersonOtherStateCode;
            } else {
                addressRec.Business_State__c = acc.Other_State__c;
            }
            addressRec.County__c = acc.County__c;
        } else {    
            addressRec.CountryCode = acc.BillingCountryCode;
            addressRec.PostalCode = acc.BillingPostalCode;
            addressRec.Street = acc.BillingStreet;
            addressRec.City = acc.BillingCity;
            if (usesStateCodePicklist(acc.BillingCountryCode)) {
                addressRec.StateCode = acc.BillingStateCode;
            } else {
                addressRec.Business_State__c = acc.Other_State__c;
            }
            addressRec.County__c = acc.County__c;
        }
        addressRec.Do_not_populate_Lat_Long__c = true;
        addressRec.LocationType = LOC_TYPE_OTHER;
        return addressRec;
    }

    /**  
    * @author                      : MTX Group Product Team
    * @since                       : 25 May 2023
    * @description                 : This Method is Used Create and Link Accounts with location,Address via Associated Location Object.
    * @return                      : `void`
    * @last modified by            : MTX Group Product Team
    * @last modified date          : 25 May 2023
    * @modified details            : Code Review Fixes
    */
    public void createLocAddressRecordsForAcc() {
        try {
            if(keyToAccountMapToCreate.isEmpty()) {
                return;
            }
            List<Schema.Location> locList = new List<Schema.Location>();
            List<Schema.Address> addressList = new List<Schema.Address>();        
            List<AssociatedLocation> assocLocList = new List<AssociatedLocation>();
            Schema.Location tmpLocRec;
            for(String accountKey: keyToAccountMapToCreate.keySet()) {
                Account currAccount = keyToAccountMapToCreate.get(accountKey);
                String accName = (currAccount.RecordTypeId==LPI_LiteralConstant.PERSON_ACCOUNT_REC_TYPE_ID?currAccount.Combined_Name__pc:currAccount.Name);
                tmpLocRec = LPI_AddressUtility.createLocationRecord(null,accName,LOC_TYPE_OTHER,accountKey);
                locList.add(tmpLocRec);
            }
            if(!locList.isEmpty()) {
                locList = LPI_WithoutSharingUtility.insertSObjectList(locList);
            }
            for(Schema.Location locRec: locList) {
                Account currAccount = keyToAccountMapToCreate.get(locRec.Unique_Key__c);
                assocLocList.add(new AssociatedLocation(
                    ParentRecordId = currAccount.Id,
                    LocationId = locRec.Id
                ));
                Schema.Address addressRec = createAddressRecord(currAccount);
                addressRec.ParentId = locRec.Id;
                addressList.add(addressRec);
            }
            if(!addressList.isEmpty()) {
                addressList = LPI_WithoutSharingUtility.insertSObjectList(addressList);
            }
            if(!assocLocList.isEmpty()) {
                assocLocList = LPI_WithoutSharingUtility.insertSObjectList(assocLocList);
            }
        }
        catch(Exception ex) {
            LPI_ExceptionManager.logException('LPI_ComplaintParticipantController', 'createLocAddressRecordsForAcc', ex);
            throw new LPI_Exception(ex.getMessage());
        }
    }
    
    /**  
    * @author                      : MTX Group Product Team
    * @since                       : 11 May 2023
    * @description                 : This Method is Used to Link AccountId On Complaint Participant Records.
    * @return                      : `void`
    * @last modified by            : MTX Group Product Team
    * @last modified date          : 24 May 2023
    * @modified details            : Code Review Fixes
    */
    public void linkAccountIdOnCPRecords() {
        try {
            Set < sObject > complaintParticipantDuplicateSet = new Set < sObject > ();
            Set < ComplaintParticipant > compliantParticipantSet = new Set < ComplaintParticipant > ();
            Set < CaseParticipant > caseParticipantSet = new Set < CaseParticipant > ();
   
            if (!keyToCpToInsert.isEmpty()) {
                for (String keyCp: keyToCpToInsert.keySet()) {
                    String accKey = keyCp.substringAfter('role-');
                     if (
                        !keyToAccountMapToCreate.containsKey(accKey) &&
                        !keyToAccountMap.containsKey(accKey)
                    ) {
                        continue;
                    }
                    if (objectName == PUBLIC_COMPLAINT_SOBJECT_API_NAME) {
                        ComplaintParticipant cpNew = new ComplaintParticipant();
                        cpNew = (ComplaintParticipant) keyToCpToInsert.get(keyCp);
                        if (keyToAccountMapToCreate.containsKey(accKey)) {
                            cpNew.ParticipantId = keyToAccountMapToCreate.get(accKey).Id;
                        } else if (keyToAccountMap.containsKey(accKey)) {
                            cpNew.ParticipantId = keyToAccountMap.get(accKey).Id;
                        }
                        if (!compliantParticipantSet.contains(cpNew)) {
                            compliantParticipantSet.add(cpNew);
                            cpListToInsert.add(cpNew);
                        }
                    } else {
                        CaseParticipant cpNew = new CaseParticipant();
                        cpNew = (CaseParticipant) keyToCpToInsert.get(keyCp);
                        if (keyToAccountMapToCreate.containsKey(accKey)) {
                            cpNew.ParticipantId = keyToAccountMapToCreate.get(accKey).Id;
                        } else if (keyToAccountMap.containsKey(accKey)) {
                            cpNew.ParticipantId = keyToAccountMap.get(accKey).Id;
                        }
                        if (!caseParticipantSet.contains(cpNew)) {
                            caseParticipantSet.add(cpNew);
                            cpListToInsert.add(cpNew);
                        }
                    }
                }
                Map < String, Sobject > stringToSobjectMap = new Map < String, Sobject > ();
                for (Sobject sobj: cpListToInsert) {
                    if (sobj.get('PublicComplaintId') == NULL || stringToSobjectMap.containsKey((String) sobj.get('PublicComplaintId') + (String) sobj.get('ParticipantId') + (String) sobj.get('Role') + (String) sobj.get('Status'))) {
                        continue;
                    }
                    stringToSobjectMap.put((String) sobj.get('PublicComplaintId') + (String) sobj.get('ParticipantId') + (String) sobj.get('Role') + (String) sobj.get('Status'), sobj);
                }
                LPI_WithoutSharingUtility.upsertSObjectList(new List < sObject > (stringToSobjectMap.values()));
                cpListToInsert = new Set < Sobject > (stringToSobjectMap.values());
            }
        } catch (Exception ex) {
            LPI_ExceptionManager.logException('LPI_ComplaintParticipantController', 'linkAccountIdOnCPRecords', ex);
            throw new LPI_Exception(ex.getMessage());
        }
    }
    /**  
    * @author                      : MTX Group Product Team
    * @since                       : 11 May 2023
    * @description                 : This Method is Used to Create Business Participant Records for the Complaints Raised.
    * @return                      : `void`
    * @last modified by            : MTX Group Product Team
    * @last modified date          : 24 May 2023
    * @modified details            : Code Review Fixes
    */
    public void createBusinessParticipantRecords(Map<Integer,PublicComplaint> respCounterToPublicComplaintMap,Map<Integer,LPI_Wrapper.RespondentWrapperNew> respCounterToRespWrapperMap) {
        try {
            List<Business_Complaint__c> businessComplaintList = new List<Business_Complaint__c>();

            Integer respCnt = 1;
            Integer totalRecords = respCounterToPublicComplaintMap.size();

            while(respCnt <= totalRecords && respCounterToPublicComplaintMap.containsKey(respCnt)) {
                PublicComplaint pc = respCounterToPublicComplaintMap.get(respCnt);
                LPI_Wrapper.RespondentWrapperNew responseWrapperObj = respCounterToRespWrapperMap.get(respCnt);
                if(responseWrapperObj.professionDetails.licensedUnlicensed == LICENSED_TEXT &&
                String.isNotBlank(responseWrapperObj.licenseDetails.accountId) && 
                String.isNotBlank(responseWrapperObj.licenseDetails.businessId)) {
                    businessComplaintList.add(new Business_Complaint__c(
                        Business_License__c = responseWrapperObj.licenseDetails.businessId,
                        Public_Complaint__c = pc.Id
                    ));
                }
                respCnt++;
            }
            LPI_WithoutSharingUtility.upsertSObjectList(
                businessComplaintList
            );
        }
        catch(Exception ex) {
            LPI_ExceptionManager.logException('LPI_ComplaintParticipantController', 'createBusinessParticipantRecords', ex);
            throw new LPI_Exception(ex.getMessage());
        }
    }


    /**
     * @description : Method to create Person Account record.
     * @author MTX Group Product Team | 01-20-2023
     * @param account
     * @param wrapperWitnessResp
     * @return Account
     **/
    public static Account createPersonAccount(
        Account personAcc,
        LPI_Wrapper.RespondentWrapper wrapperWitnessResp,
        Id ownerId
    ) {
        personAcc.RecordTypeId = LPI_LiteralConstant.PERSON_ACCOUNT_REC_TYPE_ID;
       personAcc.LastName = wrapperWitnessResp.lastName;
       personAcc.FirstName = wrapperWitnessResp.firstName;
       personAcc.MiddleName = wrapperWitnessResp.middleName;
        personAcc.Combined_Name__pc = String.isNotBlank(
            personAcc.FirstName
        ) && String.isNotBlank(personAcc.MiddleName)
        ? personAcc.FirstName +
          ' ' +
          personAcc.MiddleName +
          ' ' +
          personAcc.LastName
        : String.isNotBlank(personAcc.FirstName)
              ? personAcc.FirstName + ' ' + personAcc.LastName
              : String.isNotBlank(personAcc.MiddleName)
                    ? personAcc.MiddleName + ' ' + personAcc.LastName
                    : personAcc.LastName;

        personAcc.PersonEmail = wrapperWitnessResp.email;
        personAcc.PersonHomePhone = wrapperWitnessResp.telephone;
        personAcc.Phone = wrapperWitnessResp.cellPhone;
        personAcc.PersonOtherStreet = wrapperWitnessResp.addressData.streetOne;
        personAcc.PersonOtherCity = wrapperWitnessResp.addressData.city;
        personAcc.PersonOtherPostalCode = wrapperWitnessResp.addressData.zipCode;
        applyPersonOtherAddress(personAcc, wrapperWitnessResp.addressData);
        personAcc.County__c=wrapperWitnessResp.addressData.county;
        personAcc.OwneriD = ownerId;
        return personAcc;
    }
      /**
     * @description : Method to create Person Account record, Specific to Respondent Section.
     * @author MTX Group Product Team | 01-20-2023
     * @param account
     * @param wrapperWitnessResp
     * @return Account
     **/
    private static Account createPersonAccount(
        Account personAcc,
        LPI_Wrapper.RespondentWrapperNew wrapperWitnessResp,
        Id ownerId
    ) {
        personAcc.RecordTypeId = LPI_LiteralConstant.PERSON_ACCOUNT_REC_TYPE_ID;
       personAcc.LastName = wrapperWitnessResp.lastName;
       personAcc.FirstName = wrapperWitnessResp.firstName;
       personAcc.MiddleName = wrapperWitnessResp.middleName;
        personAcc.Combined_Name__pc = String.isNotBlank(
            personAcc.FirstName
        ) && String.isNotBlank(personAcc.MiddleName)
        ? personAcc.FirstName +
          ' ' +
          personAcc.MiddleName +
          ' ' +
          personAcc.LastName
        : String.isNotBlank(personAcc.FirstName)
              ? personAcc.FirstName + ' ' + personAcc.LastName
              : String.isNotBlank(personAcc.MiddleName)
                    ? personAcc.MiddleName + ' ' + personAcc.LastName
                    : personAcc.LastName;

        personAcc.PersonEmail = wrapperWitnessResp.email;
        personAcc.PersonHomePhone = wrapperWitnessResp.telephone;
        personAcc.PersonOtherStreet = wrapperWitnessResp.addressData.streetOne;
        personAcc.PersonOtherCity = wrapperWitnessResp.addressData.city;
        personAcc.PersonOtherPostalCode = wrapperWitnessResp.addressData.zipCode;
        applyPersonOtherAddress(personAcc, wrapperWitnessResp.addressData);
        personAcc.County__c=wrapperWitnessResp.addressData.county;
        personAcc.OwneriD = ownerId;
        return personAcc;
    }
   
    /**
    * @description Overloaded Method for Inserting Person Account Based on Attorney Wrapper.
    * @author MTX Group Product Team| 05-05-2023 
    * @param personAcc 
    * @param attorneyWrapperObj 
    * @param ownerId 
    * @return Account 
    **/
    private static Account createPersonAccount(
        Account personAcc,
        LPI_Wrapper.AttorneyWrapper attorneyWrapperObj,
        Id ownerId
    ) {
        personAcc.RecordTypeId = LPI_LiteralConstant.PERSON_ACCOUNT_REC_TYPE_ID;
        personAcc.LastName = attorneyWrapperObj.lastName;
        personAcc.FirstName = attorneyWrapperObj.firstName;
        personAcc.MiddleName = attorneyWrapperObj.middleName;
        personAcc.Combined_Name__pc = String.isNotBlank(
            personAcc.FirstName
        ) && String.isNotBlank(personAcc.MiddleName)
        ? personAcc.FirstName +
          ' ' +
          personAcc.MiddleName +
          ' ' +
          personAcc.LastName
        : String.isNotBlank(personAcc.FirstName)
              ? personAcc.FirstName + ' ' + personAcc.LastName
              : String.isNotBlank(personAcc.MiddleName)
                    ? personAcc.MiddleName + ' ' + personAcc.LastName
                    : personAcc.LastName;
        personAcc.PersonHomePhone = attorneyWrapperObj.attorneyPhone;
        personAcc.PersonEmail = attorneyWrapperObj.attorneyEmail;
        personAcc.PersonOtherStreet = attorneyWrapperObj.addressData.streetOne;
        personAcc.PersonOtherCity = attorneyWrapperObj.addressData.city;
        personAcc.PersonOtherPostalCode = attorneyWrapperObj.addressData.zipCode;
        applyPersonOtherAddress(personAcc, attorneyWrapperObj.addressData);
        personAcc.County__c=attorneyWrapperObj.addressData.county;
        personAcc.OwneriD = ownerId;
        return personAcc;
    }
    
    /**
     * @description : Method to create Business Account record.
     * @author MTX Group Product Team | 01-20-2023
     * @param account
     * @param wrapperWitnessResp
     * @return Account
     **/
    public static Account createBusinessAccount(
        Account account,
        LPI_Wrapper.RespondentWrapper wrapperWitnessResp,
        Id ownerId
    ) {
        account.RecordTypeId = LPI_LiteralConstant.BUSINESS_ACCOUNT_REC_TYPE_ID;
        account.Name = wrapperWitnessResp.entityName;
        account.Phone = wrapperWitnessResp.telephone;
        account.Buisness_Email__c = wrapperWitnessResp.email;
        account.BillingStreet = wrapperWitnessResp.addressData.streetOne;
        account.BillingCity = wrapperWitnessResp.addressData.city;
        account.BillingPostalCode = wrapperWitnessResp.addressData.zipCode;
        applyBillingAddress(account, wrapperWitnessResp.addressData);
        account.County__c=wrapperWitnessResp.addressData.county;
        account.OwneriD = ownerId;
        return account;
    }
     /**
     * @description : Method to create Business Account record specific to Respondent Section.
     * @author MTX Group Product Team | 10-21-2023
     * @param account
     * @param wrapperWitnessResp
     * @return Account
     **/
    public static Account createBusinessAccount(
        Account account,
        LPI_Wrapper.RespondentWrapperNew wrapperWitnessResp,
        Id ownerId
    ) {
        account.RecordTypeId = LPI_LiteralConstant.BUSINESS_ACCOUNT_REC_TYPE_ID;
        account.Name = wrapperWitnessResp.entityName;
        account.Phone = wrapperWitnessResp.telephone;
        account.Buisness_Email__c = wrapperWitnessResp.email;
        account.BillingStreet = wrapperWitnessResp.addressData.streetOne;
        account.BillingCity = wrapperWitnessResp.addressData.city;
        account.BillingPostalCode = wrapperWitnessResp.addressData.zipCode;
        applyBillingAddress(account, wrapperWitnessResp.addressData);
        account.County__c=wrapperWitnessResp.addressData.county;
        account.OwneriD = ownerId;
        return account;
    }

    /**
    * @description 
    * @author MTX Group Product Team | 05-07-2024 
    * @param role 
    * @param publicComplaintId 
    * @return ComplaintParticipant 
    **/
    private static ComplaintParticipant createComplaintParticipant(
        String role,
        Id publicComplaintId
    ) {
        ComplaintParticipant cp = new ComplaintParticipant();
        cp.Role = role;
        cp.Status = LPI_LiteralConstant.ACTIVE_TEXT;
        cp.PublicComplaintId = publicComplaintId;
        return cp;
    }

    /**
    * @description :This method deserializes a given JSON into a ComplaintsWrapper object, modifies its 
    *               field values and performs different actions based on the wrapper data. It handles duplicate accounts and returns 
    *               either a success message or an error if any exception occurs.
    * @param jsonData - JSON data containing information about the new respondent
    * @param recordId - Id of the PC record
    * @author MTX Group Product Team | 10th May 2023
    * @return Success message or error message in case of failure
    **/
    @AuraEnabled
    public static String addNewComplaintParticipant(String jsonData, Id caseId, String sectionName) {
        try {
            if (String.isBlank(jsonData) || String.isEmpty(caseId)) {
                return null;
            }
            LPI_Wrapper.ComplaintsWrapper wrapper = (LPI_Wrapper.ComplaintsWrapper) JSON.deserializeStrict(jsonData, LPI_Wrapper.ComplaintsWrapper.class);
            List<ComplaintCase> compCaseRecList = LPI_ComplaintCaseDao.fetchComplaintCaseRecords('Id,PublicComplaintId,CaseId','CaseId = \'' +String.escapeSingleQuotes(caseId) +'\' AND PublicComplaintId != NULL',null,null);
            String recordId = (!compCaseRecList.isEmpty() && String.isNotEmpty(compCaseRecList[0].PublicComplaintId)?compCaseRecList[0].PublicComplaintId:caseId);
            LPI_ComplaintParticipantController obj = new LPI_ComplaintParticipantController(recordId);
                switch on sectionName {
                    when 'Witness' {
                        obj.createWitnessCPRecords(wrapper);
                    }
                    when  'Attorney Complainant','Attorney Respondent','Attorney MODPR','Attorney Other'{
                        obj.attorney_Role = sectionName;
                        obj.createAttorneyCPRecords(wrapper);
                   }
                    when 'Other Entity' {
                        obj.createOtherEntitiesCPRecords(wrapper);
                    }
                    when 'Employer'{
                       obj.createEmployerCPRecords(wrapper);
                    }
                    when else {
                        throw new LPI_Exception('Invalid input data');
                    }
                } 
                obj.handleDuplicateAccountsHelper();
                obj.createLocAddressRecordsForAcc();
                obj.linkAccountIdOnCPRecords();
                if(!compCaseRecList.isEmpty()) {
                    LPI_CreateCaseAndComplaintCase.insertCPRec(obj.keyToAccountMapToCreate?.values(),sectionName,caseId);
                }
            return 'Success';
        } catch (Exception e) {
            LPI_ExceptionManager.logException('LPI_ComplaintParticipantController', 'addNewComplaintParticipant', e);
            throw new  AuraHandledException('Error'+e.getMessage());
        }
    }

    /**
     * Applies Person Other address with CA/US country-state picklist integrity.
     * Canadian provinces force Country=CA and StateCode; invalid US+CA-province combos are corrected.
     */
    private static void applyPersonOtherAddress(Account personAcc, LPI_Wrapper.AddressWrapper addressData) {
        if (personAcc == null || addressData == null) {
            return;
        }
        AddressParts parts = normalizeAddressParts(addressData.country, addressData.state, addressData.otherState);
        personAcc.PersonOtherCountryCode = parts.countryCode;
        personAcc.PersonOtherStateCode = parts.stateCode;
        personAcc.Other_State__c = parts.otherState;
    }

    /**
     * Applies Billing address with CA/US country-state picklist integrity.
     */
    private static void applyBillingAddress(Account account, LPI_Wrapper.AddressWrapper addressData) {
        if (account == null || addressData == null) {
            return;
        }
        AddressParts parts = normalizeAddressParts(addressData.country, addressData.state, addressData.otherState);
        account.BillingCountryCode = parts.countryCode;
        account.BillingStateCode = parts.stateCode;
        account.Other_State__c = parts.otherState;
    }

    private static Boolean usesStateCodePicklist(String countryCode) {
        return countryCode == LPI_LiteralConstant.US_COUNTRY_CODE || countryCode == CA_COUNTRY_CODE;
    }

    private static AddressParts normalizeAddressParts(String country, String state, String otherState) {
        AddressParts parts = new AddressParts();
        String countryCode = normalizeCountryCode(country);
        String stateToken = firstNonBlankToken(state, otherState);
        String stateCodeCandidate = String.isNotBlank(stateToken) ? stateToken.toUpperCase() : null;

        // Province codes imply Canada even if UI sent US / blank country.
        if (String.isNotBlank(stateCodeCandidate) && CA_PROVINCE_CODES.contains(stateCodeCandidate)) {
            parts.countryCode = CA_COUNTRY_CODE;
            parts.stateCode = stateCodeCandidate;
            parts.otherState = null;
            return parts;
        }

        if (String.isBlank(countryCode)) {
            countryCode = LPI_LiteralConstant.US_COUNTRY_CODE;
        }
        parts.countryCode = countryCode;

        if (countryCode == CA_COUNTRY_CODE) {
            if (String.isNotBlank(stateCodeCandidate) && CA_PROVINCE_CODES.contains(stateCodeCandidate)) {
                parts.stateCode = stateCodeCandidate;
                parts.otherState = null;
            } else {
                parts.stateCode = null;
                parts.otherState = firstNonBlankToken(otherState, state);
            }
            return parts;
        }

        if (countryCode == LPI_LiteralConstant.US_COUNTRY_CODE) {
            // Never put a Canadian province into US StateCode.
            if (String.isNotBlank(stateCodeCandidate) && CA_PROVINCE_CODES.contains(stateCodeCandidate)) {
                parts.countryCode = CA_COUNTRY_CODE;
                parts.stateCode = stateCodeCandidate;
                parts.otherState = null;
            } else {
                parts.stateCode = String.isNotBlank(state) ? state.trim().toUpperCase() : null;
                parts.otherState = null;
            }
            return parts;
        }

        parts.stateCode = null;
        parts.otherState = firstNonBlankToken(otherState, state);
        return parts;
    }

    private static String normalizeCountryCode(String country) {
        if (String.isBlank(country)) {
            return null;
        }
        String normalized = country.trim().toUpperCase();
        if (
            normalized == 'CA' ||
            normalized == 'CAN' ||
            normalized == 'CANADA'
        ) {
            return CA_COUNTRY_CODE;
        }
        if (
            normalized == 'US' ||
            normalized == 'USA' ||
            normalized == 'UNITED STATES' ||
            normalized == 'UNITED STATES OF AMERICA'
        ) {
            return LPI_LiteralConstant.US_COUNTRY_CODE;
        }
        return normalized.length() <= 3 ? normalized : country.trim();
    }

    private static String firstNonBlankToken(String primary, String secondary) {
        if (String.isNotBlank(primary)) {
            return primary.trim();
        }
        if (String.isNotBlank(secondary)) {
            return secondary.trim();
        }
        return null;
    }

    private static String resolveExceptionMessage(Exception ex) {
        if (ex == null) {
            return 'Unknown error';
        }
        String message = ex.getMessage();
        if (ex instanceof DmlException) {
            DmlException dmlEx = (DmlException) ex;
            List<String> dmlMessages = new List<String>();
            for (Integer i = 0; i < dmlEx.getNumDml(); i++) {
                dmlMessages.add(dmlEx.getDmlMessage(i));
            }
            if (!dmlMessages.isEmpty()) {
                return String.join(dmlMessages, ' | ');
            }
        }
        if (String.isBlank(message) || message == 'Script-thrown exception') {
            return ex.getTypeName() + ' at line ' + ex.getLineNumber();
        }
        return message;
    }

    private class AddressParts {
        public String countryCode;
        public String stateCode;
        public String otherState;
    }
}