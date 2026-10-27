/**
 * @description       :
 * @author            : Mohit Karani
 * @group             :
 * @last modified on  : 07-25-2024
 * @last modified by  : Uzma Md
 **/
global without sharing class LPI_BusinessLicenseFieldUpdateBatch implements Database.Batchable<sObject> {
    
    /**
    * @description 
    * @author Ayush Dev | 05-07-2024 
    * @param businessLicIdSetParam 
    **/
    public LPI_BusinessLicenseFieldUpdateBatch(
        Set<Id> businessLicIdSetParam
    ) {
        businessLicIdSet = businessLicIdSetParam;
    }
    String fields;
    String whereClause;
    Set<Id> businessLicIdSet = new Set<Id>();
    public final static String LOCATION_TYPE_PRIMARY_ADDRESS = 'Primary Address';
    public final static String LOCATION_TYPE_LICENSE_ADDRESS = 'License Address';
    public final static String LOCATION_TYPE_PUBLIC_ADDRESS = 'Public Address';
    public final static String LOCATION_TYPE_BRANCH = 'Branch';
    public final static String CONSENT_FOR_PRIMARY_ADDRESS = 'Primary Contact Address';
    public final static String CONSENT_FOR_LICENSE_ADDRESS = 'License Address';
    public final static String CONSENT_FOR_PUBLIC_ADDRESS = 'Publicly Displayed Address';

    /**
     * @description : Method to fetch the BusinessLicense records.
     * @author Mohit Karani | 03-23-2023
     * @param bc
     * @return Database.QueryLocator
     **/
    global Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'SELECT Id, Account.PersonContactId, RegulatoryAuthorizationTypeId, Primary_Contact_Address__c, License_Address__c, Publicly_Displayed_Address__c FROM BusinessLicense';
        String whereClause = businessLicIdSet.isEmpty()
            ? ' ' 
            : ' WHERE Id IN : businessLicIdSet ';
        query += whereClause + ' WITH SECURITY_ENFORCED';
        return Database.getQueryLocator(query);
    }

    /**
     * @description : Method to perform operation on the BusinessLicense records.
     * @author Mohit Karani | 03-23-2023
     * @param bc
     * @param businessLicenseRecordsList
     **/
    global void execute(
        Database.BatchableContext bc,
        List<BusinessLicense> businessLicenseRecordsList
    ) {
        try {
            Set<Id> contIdSet = new Set<Id>();
            Set<Id> ratIdSet = new Set<Id>();
            Set<Id> examIdSet = new Set<Id>();
            // Set<String> entLicNumSet = new Set<String>();
            List<BusinessLicense> blToUpdateList = new List<BusinessLicense>();
            Map<String, List<LPI_BLIntFieldWrapper.Address>> blIdToAddrMap = new Map<String, List<LPI_BLIntFieldWrapper.Address>>();
            // Map<String, BusinessLicense> entBlNameToEntBlMap = new Map<String, BusinessLicense>();
            Map<Id, Set<Id>> ratIdToExamIdMap = new Map<Id, Set<Id>>();
            Map<Id, List<PersonExamination>> conIdToPerExamListMap = new Map<Id, List<PersonExamination>>();
            Map<Id, List<LPI_BLIntFieldWrapper.perEdu>> conIdToPerEduListMap = new Map<Id, List<LPI_BLIntFieldWrapper.perEdu>>();
            // Map<Id, List<LPI_BLIntFieldWrapper.Violation>> complIdToViolnListMap = new Map<Id, List<LPI_BLIntFieldWrapper.Violation>>();
            // Map<Id, List<LPI_BLIntFieldWrapper.Codefandant>> complIdToCodefListMap = new Map<Id, List<LPI_BLIntFieldWrapper.Codefandant>>();
            // Map<String, String> blAndComplIdToComplIdMap = new Map<String, String>();
            // Set<Id> plcIdSet = new Set<Id>();
            // Map<Id, List<LPI_BLIntFieldWrapper.Discipline>> blIdToDiscListMap = new Map<Id, List<LPI_BLIntFieldWrapper.Discipline>>();
            // Map<Id, LPI_BLIntFieldWrapper.Discipline> complIdToDiscMap = new Map<Id, LPI_BLIntFieldWrapper.Discipline>();
            // Map<Id, LPI_BLIntFieldWrapper.Relation> blIdToChildRelMap = new Map<Id, LPI_BLIntFieldWrapper.Relation>();
            // Map<Id, List<LPI_BLIntFieldWrapper.Entity>> blIdToParentRelMap = new Map<Id, List<LPI_BLIntFieldWrapper.Entity>> ();
            // Map<String, List<String>> blIdToEntBlIdMap = new Map<String, List<String>>();
            // Map<String, String> blIdToChildBlIdMap = new Map<String, String>();
            Map<Id, BusinessLicense> blIdToBlMap = new Map<Id, BusinessLicense>();
            // Set<Id> childBlIdSet = new Set<Id>();
            // Set<Id> parentBlIdSet = new Set<Id>();
            // Map<Id,LPI_BLIntFieldWrapper.Entity > blIdTodetailsMap = new Map <Id,LPI_BLIntFieldWrapper.Entity >();
            Set<Id> blIdSet = new Set<Id>();
            for (BusinessLicense bl : businessLicenseRecordsList) {
                blIdSet.add(bl.Id);
                blIdToBlMap.put(bl.Id, bl);
                if (String.isNotBlank(bl.Account.PersonContactId)) {
                    contIdSet.add(bl.Account.PersonContactId);
                }
                if (String.isNotBlank(bl.RegulatoryAuthorizationTypeId)) {
                    ratIdSet.add(bl.RegulatoryAuthorizationTypeId);
                }
            }
            
            // if(!blIdSet.isEmpty()){
                // for(Business_Complaint__c  blc : [SELECT Business_License__c, Public_Complaint__c, Public_Complaint__r.Board_Name__r.Name, 
                //                                   Public_Complaint__r.Primary_Category__c, Public_Complaint__r.Other_Categories__c, 
                //                                   Public_Complaint__r.Status FROM 
                //                                   Business_Complaint__c WHERE ((Public_Complaint__r.Status = 'Closed' AND Public_Complaint__r.Board_Name__r.Name NOT IN ('Accountancy', 'Real Estate Appraisers')) OR (Public_Complaint__r.Board_Name__r.Name = 'Accountancy' AND Business_License__r.Disciplinary_Status__c != Null) OR (Public_Complaint__r.Board_Name__r.Name = 'Real Estate Appraisers')) 
                //                                   AND Business_License__c IN : blIdSet]){
                //                                       LPI_BLIntFieldWrapper.Discipline discWrp = new LPI_BLIntFieldWrapper.Discipline();
                //                                       discWrp.boardName = blc.Public_Complaint__r.Board_Name__r.Name;
                //                                       discWrp.primCategory = blc.Public_Complaint__r.Primary_Category__c;
                //                                       discWrp.secCategory = blc.Public_Complaint__r.Other_Categories__c;
                //                                       discWrp.status = blc.Public_Complaint__r.Status;
                //                                       complIdToDiscMap.put(blc.Public_Complaint__c, discWrp);
                //                                       plcIdSet.add(blc.Public_Complaint__c);
                //                                       blAndComplIdToComplIdMap.put(blc.Business_License__c + '-' + blc.Public_Complaint__c, blc.Public_Complaint__c);
				// }
                // if(!plcIdSet.isEmpty()){
                //     Map<String, String> caseIdToComplIdMap = new Map<String, String>();
                //     for(ComplaintCase cc: [SELECT CaseId, PublicComplaintId FROM ComplaintCase WHERE CaseId != NULL AND PublicComplaintId != NULL AND PublicComplaintId IN: plcIdSet]){
                //         caseIdToComplIdMap.put(cc.CaseId, cc.PublicComplaintId);                    
                //     }
                //     if(!caseIdToComplIdMap.isEmpty()){
                //         for(RegulatoryCodeViolation rcv : [SELECT Id, Action__c, Case__c, Terms_Of_Discipline__c, DateCreated, DateResolved, Is_Public__c FROM RegulatoryCodeViolation WHERE Case__c IN : caseIdToComplIdMap.Keyset()]){
                //             if(caseIdToComplIdMap.containsKey(rcv.Case__c)){
                //                 String complId = caseIdToComplIdMap.get(rcv.Case__c);
                //                 if (!complIdToViolnListMap.containsKey(complId)) { 
                //                     complIdToViolnListMap.put(complId,new List<LPI_BLIntFieldWrapper.Violation>());
                //                 }
                //                 LPI_BLIntFieldWrapper.Violation violWrp = new LPI_BLIntFieldWrapper.Violation();
                //                 violWrp.sfId = rcv.Id;
                //                 violWrp.violationType = rcv.Action__c;
                //                 violWrp.discStartDt = rcv.DateCreated;
                //                 violWrp.discEndDt = rcv.DateResolved;
                //                 violWrp.discTerms = rcv.Terms_Of_Discipline__c;
                //                 violWrp.reportFlag = rcv.Is_Public__c;
                //                 complIdToViolnListMap.get(complId).add(violWrp); 
                //             }
                //         }
                //     }
                //     for(ComplaintParticipant cmp : [SELECT Id, ParticipantId, PublicComplaintId 
                //                                        FROM ComplaintParticipant WHERE Role = 'Respondent' AND PublicComplaintId IN : plcIdSet]){
                //         if (!complIdToCodefListMap.containsKey(cmp.PublicComplaintId)) {
                //             complIdToCodefListMap.put(cmp.PublicComplaintId, new List<LPI_BLIntFieldWrapper.Codefandant>());
                //         }
                //         LPI_BLIntFieldWrapper.Codefandant codWrp = new LPI_BLIntFieldWrapper.Codefandant();
                //         codWrp.cid = cmp.ParticipantId;
                //         complIdToCodefListMap.get(cmp.PublicComplaintId).add(codWrp);
                //     }
                //     for(String blCl : blAndComplIdToComplIdMap.keySet()){
                //         LPI_BLIntFieldWrapper.Discipline finalDiscWrp = new LPI_BLIntFieldWrapper.Discipline();
                //         String bLicId = blCl.substringBefore('-');
                //         String complId = blCl.substringAfter('-');
                //         finalDiscWrp = complIdToDiscMap.get(complId);
                //         finalDiscWrp.rcv = complIdToViolnListMap.get(complId);
                //         finalDiscWrp.cod = complIdToCodefListMap.get(complId);
                        
                //         if (!blIdToDiscListMap.containsKey(bLicId)) {
                //             blIdToDiscListMap.put(bLicId, new List<LPI_BLIntFieldWrapper.Discipline>());
                //         }
                //         blIdToDiscListMap.get(bLicId).add(finalDiscWrp);
                //     }
                // }
                // for(Business_Relationships__c brs : [SELECT Id, Related_To_License_Number__c, Related_From_License_Number__c, Related_To_License_Number__r.Account.FirstName, Related_To_License_Number__r.Account.MiddleName, Related_To_License_Number__r.Account.LastName, Related_To_License_Number__r.Account.Suffix, Related_To_License_Number__r.Business_Entity_Name__c, Related_To_License_Number__r.Name, Related_To_License_Number__r.Legacy_License_Number__c,Related_To_License_Number__r.Primary_Contact_Address__c, Related_To_License_Number__r.License_Address__c, Related_To_License_Number__r.Publicly_Displayed_Address__c FROM Business_Relationships__c 
                //                                     WHERE Related_To_License_Number__c != null AND Related_From_License_Number__c IN: blIdSet 
                //                                     AND Related_From_License_Number__r.RegulatoryAuthorizationType.Profession_Code__c IN ('REC','REA','RPF') 
                //                                     AND Roles__c = 'Designated Incharge' AND IsActive__c = true Order BY Start_Date__c DESC]){
                //     if (!blIdToChildRelMap.containsKey(brs.Related_From_License_Number__c)) {
                //         LPI_BLIntFieldWrapper.Relation finalChildRelWrp = new LPI_BLIntFieldWrapper.Relation();
                //         finalChildRelWrp.relType = 'Designated Broker';
                //         finalChildRelWrp.firstName = brs.Related_To_License_Number__r.Account.FirstName;
                //         finalChildRelWrp.midName = brs.Related_To_License_Number__r.Account.MiddleName;
                //         finalChildRelWrp.lastName = brs.Related_To_License_Number__r.Account.LastName;
                //         finalChildRelWrp.suffix = brs.Related_To_License_Number__r.Account.Suffix;
                //         finalChildRelWrp.prcName = brs.Related_To_License_Number__r.Business_Entity_Name__c;
                //         finalChildRelWrp.licNo = String.isNotBlank(brs.Related_To_License_Number__r.Legacy_License_Number__c) ? brs.Related_To_License_Number__r.Legacy_License_Number__c : brs.Related_To_License_Number__r.Name;

                //         finalChildRelWrp.mailingAddresses = new List<LPI_BLIntFieldWrapper.Address>();
                //         finalChildRelWrp.businessAddresses = new List<LPI_BLIntFieldWrapper.Address>();
                //         finalChildRelWrp.residenceAddresses = new List<LPI_BLIntFieldWrapper.Address>();
                //         finalChildRelWrp.branchAddresses = new List<LPI_BLIntFieldWrapper.Address>();
                //         finalChildRelWrp.licenceAddress = new List<LPI_BLIntFieldWrapper.Address>();
                //         finalChildRelWrp.primaryAddress = new List<LPI_BLIntFieldWrapper.Address>();
                //         finalChildRelWrp.publicAddress = new List<LPI_BLIntFieldWrapper.Address>();
                        
                //         blIdToChildRelMap.put(brs.Related_From_License_Number__c, finalChildRelWrp);
                //         blIdToChildBlIdMap.put(brs.Related_From_License_Number__c, brs.Related_To_License_Number__c);
                //         childBlIdSet.add(brs.Related_To_License_Number__c);
                        
                //         BusinessLicense blForAddress = new BusinessLicense();
                //         blForAddress.Primary_Contact_Address__c = brs.Related_To_License_Number__r.Primary_Contact_Address__c;
                //         blForAddress.License_Address__c = brs.Related_To_License_Number__r.License_Address__c;
                //         blForAddress.Publicly_Displayed_Address__c = brs.Related_To_License_Number__r.Publicly_Displayed_Address__c;
                //         blForAddress.Id = brs.Related_To_License_Number__c;
                //         blIdToBlMap.put(brs.Related_To_License_Number__c, blForAddress);
                //     }
                // }
                // blIdSet.addAll(childBlIdSet);
            // }
            // for(Business_Relationships__c brs : [SELECT Id, Related_To_License_Number__c, Related_From_License_Number__c, Related_From_License_Number__r.Business_Entity_Name__c,Related_From_License_Number__r.Name, Related_From_License_Number__r.Legacy_License_Number__c,Related_From_License_Number__r.Primary_Contact_Address__c, Related_From_License_Number__r.License_Address__c, Related_From_License_Number__r.Publicly_Displayed_Address__c 
            //                                         FROM Business_Relationships__c WHERE Related_From_License_Number__c != null AND Related_To_License_Number__c != NULL AND Related_To_License_Number__c IN: blIdSet AND 
            //                                         Related_To_License_Number__r.RegulatoryAuthorizationType.Profession_Code__c IN ('BRA','BRO','BRP','BRS','PCS','SAL','PCB', 'RAP','RSL','SCG')  AND IsActive__c = true Order BY Start_Date__c DESC]){
            //     if (!blIdToParentRelMap.containsKey(brs.Related_To_License_Number__c)) {
            //         blIdToParentRelMap.put(brs.Related_To_License_Number__c, new List<LPI_BLIntFieldWrapper.Entity>());
            //         blIdToEntBlIdMap.put(brs.Related_To_License_Number__c,new List<String>());
            //     }
            //     LPI_BLIntFieldWrapper.Entity finalChildRelWrp = new LPI_BLIntFieldWrapper.Entity();
            //     finalChildRelWrp.busName = brs.Related_From_License_Number__r.Business_Entity_Name__c;
            //     finalChildRelWrp.prcName = brs.Related_From_License_Number__r.Business_Entity_Name__c;
            //     finalChildRelWrp.licNo = String.isNotBlank(brs.Related_From_License_Number__r.Legacy_License_Number__c) ? brs.Related_From_License_Number__r.Legacy_License_Number__c : brs.Related_From_License_Number__r.Name;

            //     finalChildRelWrp.mailingAddresses = new List<LPI_BLIntFieldWrapper.Address>();
            //     finalChildRelWrp.businessAddresses = new List<LPI_BLIntFieldWrapper.Address>();
            //     finalChildRelWrp.residenceAddresses = new List<LPI_BLIntFieldWrapper.Address>();
            //     finalChildRelWrp.branchAddresses = new List<LPI_BLIntFieldWrapper.Address>();
            //     finalChildRelWrp.licenceAddress = new List<LPI_BLIntFieldWrapper.Address>();
            //     finalChildRelWrp.primaryAddress = new List<LPI_BLIntFieldWrapper.Address>();
            //     finalChildRelWrp.publicAddress = new List<LPI_BLIntFieldWrapper.Address>();
                
            //     blIdToParentRelMap.get(brs.Related_To_License_Number__c).add(finalChildRelWrp);
            //     blIdToEntBlIdMap.get(brs.Related_To_License_Number__c).add(brs.Related_From_License_Number__c);

            //     parentBlIdSet.add(brs.Related_From_License_Number__c);                
            //     BusinessLicense blForAddress = new BusinessLicense();
            //     blForAddress.Primary_Contact_Address__c = brs.Related_From_License_Number__r.Primary_Contact_Address__c;
            //     blForAddress.License_Address__c = brs.Related_From_License_Number__r.License_Address__c;
            //     blForAddress.Publicly_Displayed_Address__c = brs.Related_From_License_Number__r.Publicly_Displayed_Address__c;
            //     blForAddress.Id = brs.Related_From_License_Number__c;
            //     blIdToBlMap.put(brs.Related_From_License_Number__c, blForAddress);
            //     blIdTodetailsMap.put(brs.Related_From_License_Number__c,finalChildRelWrp);
            // }
            // blIdSet.addAll(parentBlIdSet);
            if (!ratIdSet.isEmpty()) {
                ratIdToExamIdMap = getBoardExams(ratIdSet);
            }
            for (Id ratId : ratIdToExamIdMap.keySet()) {
                examIdSet.addAll(ratIdToExamIdMap.get(ratId));
            }
            if (!examIdSet.isEmpty() && !contIdSet.isEmpty()) {
                conIdToPerExamListMap = getExamDetails(examIdSet, contIdSet);
            }
            if (!contIdSet.isEmpty()) {
                conIdToPerEduListMap = getEduDetails(contIdSet);
            }
            Map<String, String> nameToBlIdMap = new Map<String, String>();
            blIdToAddrMap = getAddress(blIdSet, blIdToBlMap);
            // String residenceAddressKey;
            // String mailingAddressKey;
            // String businessAddressKey;
            // String branchAddressKey;
            // String primaryAddressKey;
            // String licAddressKey;
            // String pubAddressKey;

            // for(Id blId : blIdTodetailsMap.keySet()){
            //     residenceAddressKey =
            //             blId +
            //             '-' +
            //             LPI_LiteralConstant.LOCATION_TYPE_RESIDENCE.toLowerCase();
            //         mailingAddressKey =
            //         blId +
            //             '-' +
            //             LPI_LiteralConstant.MAILING.toLowerCase();
            //         branchAddressKey =
            //         blId +
            //             '-' +
            //             LOCATION_TYPE_BRANCH.toLowerCase();
            //         businessAddressKey =
            //         blId +
            //             '-' +
            //             LPI_LiteralConstant.LOCATION_TYPE_BUSINESS_ADDRESS.toLowerCase();
            //         primaryAddressKey =
            //         blId +
            //             '-' +
            //             LOCATION_TYPE_PRIMARY_ADDRESS.toLowerCase();
            //         licAddressKey =
            //         blId +
            //             '-' +
            //             LOCATION_TYPE_LICENSE_ADDRESS.toLowerCase();
            //         pubAddressKey =
            //         blId +
            //             '-' +
            //             LOCATION_TYPE_PUBLIC_ADDRESS.toLowerCase();
                    
            //         if (blIdToAddrMap.containsKey(residenceAddressKey)) {
            //             blIdTodetailsMap.get(blId).residenceAddresses = blIdToAddrMap.get(
            //                 residenceAddressKey
            //             );
            //         }
            //         if (blIdToAddrMap.containsKey(branchAddressKey)) {
            //             blIdTodetailsMap.get(blId).branchAddresses = blIdToAddrMap.get(
            //                 branchAddressKey
            //             );
            //         }
            //         if (blIdToAddrMap.containsKey(mailingAddressKey)) {
            //             blIdTodetailsMap.get(blId).mailingAddresses = blIdToAddrMap.get(
            //                 mailingAddressKey
            //             );
            //         }
            //         if (blIdToAddrMap.containsKey(businessAddressKey)) {
            //             blIdTodetailsMap.get(blId).businessAddresses = blIdToAddrMap.get(
            //                 businessAddressKey
            //             );
            //         }
            //         if (blIdToAddrMap.containsKey(primaryAddressKey)) {
            //             blIdTodetailsMap.get(blId).primaryAddress = blIdToAddrMap.get(
            //                 primaryAddressKey
            //             );
            //         }
            //         if (blIdToAddrMap.containsKey(licAddressKey)) {
            //             blIdTodetailsMap.get(blId).licenceAddress = blIdToAddrMap.get(
            //                 licAddressKey
            //             );
            //         }
            //         if (blIdToAddrMap.containsKey(pubAddressKey)) {
            //             blIdTodetailsMap.get(blId).publicAddress = blIdToAddrMap.get(
            //                 pubAddressKey
            //             );
            //         }
            // }

            // residenceAddressKey = null;
            // mailingAddressKey = null;
            // businessAddressKey = null;
            // branchAddressKey = null;
            // primaryAddressKey = null;
            // licAddressKey = null;
            // pubAddressKey = null;

            List<PersonExamination> perExamList = new List<PersonExamination>();
            for (Id contactId : conIdToPerExamListMap.keySet()) {
                perExamList.addAll(conIdToPerExamListMap.get(contactId));
            }
            Map<String, List<LPI_BLIntFieldWrapper.perExam>> contactIdExamIdToPerExam = new Map<String, List<LPI_BLIntFieldWrapper.perExam>>();
            String key;
            for (PersonExamination perExam : perExamList) {
                key = perExam.ContactId + '-' + perExam.ExaminationId;
                if (!contactIdExamIdToPerExam.containsKey(key)) {
                    contactIdExamIdToPerExam.put(
                        key,
                        new List<LPI_BLIntFieldWrapper.perExam>()
                    );
                }

                contactIdExamIdToPerExam.get(key)
                    .add(mapPersonExamination(perExam));
            }

            Map<Id, LPI_BLIntFieldWrapper> blIdToBLIntFieldWrapperMap = new Map<Id, LPI_BLIntFieldWrapper>();

            BusinessLicense entityBl;
            String contactIdExamId;
            Map<String, BusinessLicense> personContactIdBlIdToBlMap = new Map<String, BusinessLicense>();
            for (BusinessLicense bl : businessLicenseRecordsList) {
                LPI_BLIntFieldWrapper intWrap = new LPI_BLIntFieldWrapper();

                intWrap.mailingAddresses = new List<LPI_BLIntFieldWrapper.Address>();
                intWrap.businessAddresses = new List<LPI_BLIntFieldWrapper.Address>();
                intWrap.residenceAddresses = new List<LPI_BLIntFieldWrapper.Address>();
                intWrap.branchAddresses = new List<LPI_BLIntFieldWrapper.Address>();
                intWrap.primaryAddress = new List<LPI_BLIntFieldWrapper.Address>();
                intWrap.licenceAddress = new List<LPI_BLIntFieldWrapper.Address>();
                intWrap.publicAddress = new List<LPI_BLIntFieldWrapper.Address>();
                
                intWrap.licenseDiscipline = new List<LPI_BLIntFieldWrapper.Discipline>();
                
                // if(blIdToDiscListMap.containsKey(bl.Id)){
                //     intWrap.licenseDiscipline = blIdToDiscListMap.get(bl.Id);
                // }

                // if (
                //     blIdToParentRelMap.containsKey(bl.Id)
                // ) {
                    
                //     intWrap.relatedEntity = new List<LPI_BLIntFieldWrapper.Entity>();
                //     intWrap.relatedEntity.addAll(blIdToParentRelMap.get(bl.Id));
                // }
                // if (
                //     blIdToChildRelMap.containsKey(bl.Id)
                // ) {
                //     intWrap.childEntity = new LPI_BLIntFieldWrapper.Relation();
                //     intWrap.childEntity = blIdToChildRelMap.get(bl.Id);
                // }
                if (
                    String.isNotBlank(bl.Account.PersonContactId) &&
                    conIdToPerEduListMap.containsKey(bl.Account.PersonContactId)
                ) {
                    intWrap.personEducation = conIdToPerEduListMap.get(
                        bl.Account.PersonContactId
                    );
                }
                blIdToBLIntFieldWrapperMap.put(bl.Id, intWrap);
                if (
                    !ratIdToExamIdMap.containsKey(
                        bl.RegulatoryAuthorizationTypeId
                    )
                ) {
                    continue;
                }
                intWrap.personExam = new List<LPI_BLIntFieldWrapper.perExam>();
                for (
                    Id examId : ratIdToExamIdMap.get(
                        bl.RegulatoryAuthorizationTypeId
                    )
                ) {
                    contactIdExamId = bl.Account.PersonContactId + '-' + examId;
                    if (
                        !contactIdExamIdToPerExam.containsKey(contactIdExamId)
                    ) {
                        continue;
                    }
                    intWrap.personExam.addAll(
                        contactIdExamIdToPerExam.get(contactIdExamId)
                    );
                }
            }
            LPI_BLIntFieldWrapper blWrapper;
            String businessLicenseId;
            for (String blId : blIdToBLIntFieldWrapperMap.keySet()) {
                if (
                    blIdToAddrMap.containsKey(
                        blId +
                        '-' +
                        LPI_LiteralConstant.MAILING.toLowerCase()
                    ) ||
                    blIdToAddrMap.containsKey(
                        blId +
                        '-' +
                        LPI_LiteralConstant.LOCATION_TYPE_RESIDENCE.toLowerCase()
                    ) ||
                    blIdToAddrMap.containsKey(
                        blId +
                        '-' +
                        LOCATION_TYPE_BRANCH.toLowerCase()
                    ) ||
                    blIdToAddrMap.containsKey(
                        blId +
                        '-' +
                        LPI_LiteralConstant.LOCATION_TYPE_BUSINESS_ADDRESS.toLowerCase()
                    ) ||
                    blIdToAddrMap.containsKey(
                        blId +
                        '-' +
                        LOCATION_TYPE_PRIMARY_ADDRESS.toLowerCase()
                    ) ||
                    blIdToAddrMap.containsKey(
                        blId +
                        '-' +
                        LOCATION_TYPE_LICENSE_ADDRESS.toLowerCase()
                    ) ||
                    blIdToAddrMap.containsKey(
                        blId +
                        '-' +
                        LOCATION_TYPE_PUBLIC_ADDRESS.toLowerCase()
                    )
                ) {
                    continue;
                }
                blIdToAddrMap.put(
                    blId +
                    '-' +
                    LPI_LiteralConstant.MAILING.toLowerCase(),
                    new List<LPI_BLIntFieldWrapper.Address>()
                );
            }
            for (String keyString : blIdToAddrMap.keySet()) {
                businessLicenseId = keyString.substringBefore('-');
                if (
                    !blIdToBLIntFieldWrapperMap.containsKey(businessLicenseId)
                ) {
                    continue;
                }
                blWrapper = blIdToBLIntFieldWrapperMap.get(businessLicenseId);
                if(blIdToAddrMap.get(keyString) != null && !blIdToAddrMap.get(keyString).isEmpty()){
                    if (keyString.substringAfter('-') == LPI_LiteralConstant.MAILING.toLowerCase()) {
                        blWrapper.mailingAddresses.addAll(
                            blIdToAddrMap.get(keyString)
                        );
                    } 
                    else if (keyString.substringAfter('-') == LPI_LiteralConstant.LOCATION_TYPE_RESIDENCE.toLowerCase()) {
                        blWrapper.residenceAddresses.addAll(
                            blIdToAddrMap.get(keyString)
                        );
                    }  
                    else if (keyString.substringAfter('-') == LOCATION_TYPE_BRANCH.toLowerCase()) {
                        blWrapper.branchAddresses.addAll(
                            blIdToAddrMap.get(keyString)
                        );
                    } 
                    else if (keyString.substringAfter('-') == LPI_LiteralConstant.LOCATION_TYPE_BUSINESS_ADDRESS.toLowerCase()) {
                        blWrapper.businessAddresses.addAll(
                            blIdToAddrMap.get(keyString)
                        );
                    } 
                    else if (keyString.substringAfter('-') == LOCATION_TYPE_PRIMARY_ADDRESS.toLowerCase()) {
                        blWrapper.primaryAddress.addAll(
                            blIdToAddrMap.get(keyString)
                        );
                    } 
                    else if (keyString.substringAfter('-') == LOCATION_TYPE_LICENSE_ADDRESS.toLowerCase()) {
                        blWrapper.licenceAddress.addAll(
                            blIdToAddrMap.get(keyString)
                        );
                    } 
                    else if (keyString.substringAfter('-') == LOCATION_TYPE_PUBLIC_ADDRESS.toLowerCase()) {
                        blWrapper.publicAddress.addAll(
                            blIdToAddrMap.get(keyString)
                        );
                    }
                }
                // if(blIdToChildBlIdMap.containsKey(businessLicenseId)){
                //     residenceAddressKey =
                //         blIdToChildBlIdMap.get(businessLicenseId) +
                //         '-' +
                //         LPI_LiteralConstant.LOCATION_TYPE_RESIDENCE.toLowerCase();
                //     mailingAddressKey =
                //         blIdToChildBlIdMap.get(businessLicenseId) +
                //         '-' +
                //         LPI_LiteralConstant.MAILING.toLowerCase();
                //     branchAddressKey =
                //         blIdToChildBlIdMap.get(businessLicenseId) +
                //         '-' +
                //         LOCATION_TYPE_BRANCH.toLowerCase();
                //     businessAddressKey =
                //         blIdToChildBlIdMap.get(businessLicenseId) +
                //         '-' +
                //         LPI_LiteralConstant.LOCATION_TYPE_BUSINESS_ADDRESS.toLowerCase();
                //     primaryAddressKey =
                //         blIdToChildBlIdMap.get(businessLicenseId) +
                //         '-' +
                //         LOCATION_TYPE_PRIMARY_ADDRESS.toLowerCase();
                //     licAddressKey =
                //         blIdToChildBlIdMap.get(businessLicenseId) +
                //         '-' +
                //         LOCATION_TYPE_LICENSE_ADDRESS.toLowerCase();
                //     pubAddressKey =
                //         blIdToChildBlIdMap.get(businessLicenseId) +
                //         '-' +
                //         LOCATION_TYPE_PUBLIC_ADDRESS.toLowerCase();
                //     if (blIdToAddrMap.containsKey(residenceAddressKey)) {
                //         blWrapper.childEntity.residenceAddresses = blIdToAddrMap.get(
                //             residenceAddressKey
                //         );
                //     }
                //     if (blIdToAddrMap.containsKey(branchAddressKey)) {
                //         blWrapper.childEntity.branchAddresses = blIdToAddrMap.get(
                //             branchAddressKey
                //         );
                //     }
                //     if (blIdToAddrMap.containsKey(mailingAddressKey)) {
                //         blWrapper.childEntity.mailingAddresses = blIdToAddrMap.get(
                //             mailingAddressKey
                //         );
                //     }
                //     if (blIdToAddrMap.containsKey(businessAddressKey)) {
                //         blWrapper.childEntity.businessAddresses = blIdToAddrMap.get(
                //             businessAddressKey
                //         );
                //     }
                //     if (blIdToAddrMap.containsKey(primaryAddressKey)) {
                    
                //         blWrapper.childEntity.primaryAddress = blIdToAddrMap.get(
                //             primaryAddressKey
                //         );
                //     }
                //     if (blIdToAddrMap.containsKey(licAddressKey)) {
                //         blWrapper.childEntity.licenceAddress = blIdToAddrMap.get(
                //             licAddressKey
                //         );
                //     }
                //     if (blIdToAddrMap.containsKey(pubAddressKey)) {
                //         blWrapper.childEntity.publicAddress = blIdToAddrMap.get(
                //             pubAddressKey
                //         );
                //     }
                // }
            }
            for (Id blId : blIdToBLIntFieldWrapperMap.keySet()) {
                blIdToBLIntFieldWrapperMap.get(blId)
                    .personEducation = blIdToBLIntFieldWrapperMap.get(blId)
                        .personEducation == null
                    ? new List<LPI_BLIntFieldWrapper.perEdu>()
                    : blIdToBLIntFieldWrapperMap.get(blId).personEducation;
                blIdToBLIntFieldWrapperMap.get(blId)
                    .personExam = blIdToBLIntFieldWrapperMap.get(blId)
                        .personExam == null
                    ? new List<LPI_BLIntFieldWrapper.perExam>()
                    : blIdToBLIntFieldWrapperMap.get(blId).personExam;
                blIdToBLIntFieldWrapperMap.get(blId)
                    .relatedEntity = blIdToBLIntFieldWrapperMap.get(blId)
                        .relatedEntity == null
                    ? new List<LPI_BLIntFieldWrapper.Entity>()
                    : blIdToBLIntFieldWrapperMap.get(blId).relatedEntity;

                String jsonStr = JSON.serialize(
                    blIdToBLIntFieldWrapperMap.get(blId)
                );
                BusinessLicense blToUpdate = new BusinessLicense();
                blToUpdate.Id = blId;
                blToUpdate.Business_License_JSON__c = jsonStr;
                blToUpdateList.add(blToUpdate);
            }
            Database.update(blToUpdateList, false,AccessLevel.SYSTEM_MODE);
        } catch (Exception e) {
            LPI_ExceptionManager.logException(
                'LPI_BusinessLicenseFieldUpdateBatch',
                'execute',
                e
            );
        }
    }

    /**
     * @description : Method to fetch the Examination Id's by License Type
     * @author Mohit Karani | 03-23-2023
     * @param ratIds
     * @return Map<Id, Set<Id>>
     **/
    public Map<Id, Set<Id>> getBoardExams(Set<Id> ratIds) {
        Map<Id, Set<Id>> ratIdToExIdMap = new Map<Id, Set<Id>>();
        fields = 'Id, Examination__c, Regulatory_Authorization_Type__c';
        whereClause =
            ' Examination__c != NULL AND Regulatory_Authorization_Type__c != NULL AND Regulatory_Authorization_Type__c IN ' +
            LPI_ServiceUtility.getStringValuesBySet(ratIds);
        for (
            Regulatory_Examination_Junction__c rej : LPI_RegulatoryExaminationJunctionDao.getRegulatoryExaminationJunctionByDymanicQuery(
                fields,
                whereClause,
                null,
                null,
                null
            )
        ) {
            if (
                !ratIdToExIdMap.containsKey(
                    rej.Regulatory_Authorization_Type__c
                )
            ) {
                ratIdToExIdMap.put(
                    rej.Regulatory_Authorization_Type__c,
                    new Set<Id>()
                );
            }
            ratIdToExIdMap.get(rej.Regulatory_Authorization_Type__c)
                .add(rej.Examination__c);
        }
        return ratIdToExIdMap;
    }

    /**
     * @description : Method to fetch all the PersonExamination records for the provided contact Id's and Exam Id's
     * @author Mohit Karani | 03-23-2023
     * @param exIds
     * @param conIds
     * @return Map<Id, List<PersonExamination>>
     **/
    public Map<Id, List<PersonExamination>> getExamDetails(
        Set<Id> exIds,
        Set<Id> conIds
    ) {
        Map<Id, List<PersonExamination>> conIdToPerExMap = new Map<Id, List<PersonExamination>>();
        fields = 'Id,Exam_Retake__c,Exam_Section__c,ExaminationDate,Result,Score,Examination.name,ContactId,ExaminationId';
        whereClause =
            'ExaminationId != NULL AND ContactId != NULL AND Result = \'Pass\' AND ExaminationId IN ' +
            LPI_ServiceUtility.getStringValuesBySet(exIds) +
            ' AND ContactId IN ' +
            LPI_ServiceUtility.getStringValuesBySet(conIds);

        for (
            PersonExamination pe : LPI_PersonExaminationDAO.getPersonExaminationByDynamicQuery(
                fields,
                whereClause,
                null,
                null,
                null
            )
        ) {
            if (!conIdToPerExMap.containsKey(pe.ContactId)) {
                conIdToPerExMap.put(
                    pe.ContactId,
                    new List<PersonExamination>()
                );
            }
            conIdToPerExMap.get(pe.ContactId).add(pe);
        }
        return conIdToPerExMap;
    }

    /**
     * @description : Fetch address records mapped to the Businesslicense along with the location type.
     * @author Mohit Karani | 03-23-2023
     * @param blIdSet
     * @return Map<String, List<LPI_BLIntFieldWrapper.Address>>
     **/
    public Map<String, List<LPI_BLIntFieldWrapper.Address>> getAddress(
        Set<Id> blIdSet, Map<Id, BusinessLicense> blIdToBl
    ) {
        Set<String> addressTypeSet = new Set<String>{'Residence', 'Mailing', 'Business Address', 'Branch'};
        Set<String> addressTypeCheckSet = new Set<String>{'Residence', 'Mailing', 'Business Address', 'Branch'};
        Map<String, String> blAuthAppIdToLocationId = new Map<String, String>();
        Map<String, List<LPI_BLIntFieldWrapper.Address>> blIdToAddressMap = new Map<String, List<LPI_BLIntFieldWrapper.Address>>();
        String key;
        fields = ' Id, AuthorizationId, PlaceId';
        whereClause =
            'AuthorizationId IN ' +
            LPI_ServiceUtility.getStringValuesBySet(blIdSet) +
            ' AND AuthorizationId != NULL AND PlaceId != NULL';
        
        Map<String, String> locIdToPrimaryMap = new Map<String, String>();
        Map<String, String> locIdToLicMap = new Map<String, String>();
        Map<String, String> locIdToPubMap = new Map<String, String>();
        Map<String, String> locIdtoBlIdMap = new Map<String, String>();

        for(String i : blIdSet){
            if(blIdToBl.containsKey(i)){
                BusinessLicense bli = new BusinessLicense();
                bli = blIdToBl.get(i);
                
                if (String.isNotBlank(bli.Primary_Contact_Address__c)) {
                    addressTypeSet.add(bli.Primary_Contact_Address__c);
                }
                if (String.isNotBlank(bli.License_Address__c)) {
                    addressTypeSet.add(bli.License_Address__c);
                }
                if (String.isNotBlank(bli.Publicly_Displayed_Address__c)) {
                    addressTypeSet.add(bli.Publicly_Displayed_Address__c);
                }
            }
        }

        for (
            AuthApplicationPlace appl : LPI_AuthApplicationPlaceDAO.getAuthApplicationPlaceByDymanicQuery(
                fields,
                whereClause,
                null,
                null,
                null
            )
        ) {
            key = appl.AuthorizationId + '-' + appl.Id;
            blAuthAppIdToLocationId.put(key, appl.PlaceId);
            locIdtoBlIdMap.put(appl.PlaceId, appl.AuthorizationId);
        }

        if (blAuthAppIdToLocationId.isEmpty()) {
            return blIdToAddressMap;
        }

        Map<Id, List<LPI_BLIntFieldWrapper.Address>> locationIdToAddressMap = new Map<Id, List<LPI_BLIntFieldWrapper.Address>>();
        Map<Id, String> locationIdToTypeMap = new Map<Id, String>();
        fields = 'ID,ParentId,Street,Business_State__c,City,State,StateCode,PostalCode,Country,CountryCode,LocationType,County__c,Parent.OpenDate,Parent.Status__c,Parent.Consent_For__c ';

        whereClause =
            'LocationType IN ' +
            LPI_ServiceUtility.getStringValuesByStringSet(addressTypeSet) +
            ' AND ParentId IN ' +
            LPI_ServiceUtility.getStringValuesByList(
                blAuthAppIdToLocationId.values()
            );
        for (
            Schema.Address addressRec : LPI_AddressDAO.getAddressByDymanicQuery(
                fields,
                whereClause,
                null,
                null,
                null
            )
        ) {
             if (addressRec.Parent.Status__c != LPI_LiteralConstant.LOCATION_STATUS_OPEN
                ) {
                 continue;
             }
            
            LPI_BLIntFieldWrapper.Address adrs = mapAddress(addressRec);
            String locType = addressRec.LocationType;
            
            
            if(locIdtoBlIdMap.containsKey(addressRec.ParentId) && blIdToBl.containsKey(locIdtoBlIdMap.get(addressRec.ParentId)) && String.isNotBlank(addressRec.Parent.Consent_For__c)){
                List<String> consentForList = new List<String>();
                consentForList = addressRec.Parent.Consent_For__c.split(';');
                BusinessLicense busl = new BusinessLicense();
                busl = blIdToBl.get(locIdtoBlIdMap.get(addressRec.ParentId));
                if(addressTypeCheckSet.contains(addressRec.LocationType)){
                    if(addressRec.LocationType == busl.Primary_Contact_Address__c && consentForList.contains(CONSENT_FOR_PRIMARY_ADDRESS)){
                        locIdToPrimaryMap.put(addressRec.ParentId, LOCATION_TYPE_PRIMARY_ADDRESS.toLowerCase());
                    }
                    if(addressRec.LocationType == busl.License_Address__c && consentForList.contains(CONSENT_FOR_LICENSE_ADDRESS)){
                        locIdToLicMap.put(addressRec.ParentId, LOCATION_TYPE_LICENSE_ADDRESS.toLowerCase());
                    }
                    if(addressRec.LocationType == busl.Publicly_Displayed_Address__c && consentForList.contains(CONSENT_FOR_PUBLIC_ADDRESS)){
                        locIdToPubMap.put(addressRec.ParentId, LOCATION_TYPE_PUBLIC_ADDRESS.toLowerCase());
                    }
                }
                else{
                    if(addressRec.LocationType == busl.Primary_Contact_Address__c && consentForList.contains(CONSENT_FOR_PRIMARY_ADDRESS)){
                        locType = LOCATION_TYPE_PRIMARY_ADDRESS;
                    }
                    if(addressRec.LocationType == busl.License_Address__c && consentForList.contains(CONSENT_FOR_LICENSE_ADDRESS)){
                        locType = LOCATION_TYPE_LICENSE_ADDRESS;
                    }
                    if(addressRec.LocationType == busl.Publicly_Displayed_Address__c && consentForList.contains(CONSENT_FOR_PUBLIC_ADDRESS)){
                        locType = LOCATION_TYPE_PUBLIC_ADDRESS;
                    }
                }
            }
            locationIdToTypeMap.put(
                addressRec.ParentId,
                locType.toLowerCase()
            );
            if (!locationIdToAddressMap.containsKey(addressRec.ParentId)) {
                locationIdToAddressMap.put(
                    addressRec.ParentId,
                    new List<LPI_BLIntFieldWrapper.Address>()
                );
            }
            locationIdToAddressMap.get(addressRec.ParentId).add(adrs);
        }

        String mapKey;
        String newKey;
        
        for (String keyString : blAuthAppIdToLocationId.keySet()) {
            mapKey =
                keyString.substringBefore('-') +
                '-' +
                locationIdToTypeMap.get(blAuthAppIdToLocationId.get(keyString));

            if (
                locationIdToAddressMap.get(
                    blAuthAppIdToLocationId.get(keyString)
                ) == null
            ) {
                continue;
            }

            if (!blIdToAddressMap.containsKey(mapKey)) {
                blIdToAddressMap.put(
                    mapKey,
                    new List<LPI_BLIntFieldWrapper.Address>()
                );
            }

            blIdToAddressMap.get(mapKey)
                .addAll(
                    locationIdToAddressMap.get(
                        blAuthAppIdToLocationId.get(keyString)
                    )
                );
            if(locIdToPrimaryMap.containsKey(blAuthAppIdToLocationId.get(keyString))){
                newKey = keyString.substringBefore('-') +'-' + locIdToPrimaryMap.get(blAuthAppIdToLocationId.get(keyString));
                if (!blIdToAddressMap.containsKey(newKey)) {
                    blIdToAddressMap.put(
                        newKey,
                        new List<LPI_BLIntFieldWrapper.Address>()
                    );
                }
                blIdToAddressMap.get(newKey).addAll(locationIdToAddressMap.get(blAuthAppIdToLocationId.get(keyString)));
            } 
            if(locIdToLicMap.containsKey(blAuthAppIdToLocationId.get(keyString))){
                newKey = keyString.substringBefore('-') +'-' + locIdToLicMap.get(blAuthAppIdToLocationId.get(keyString));
                if (!blIdToAddressMap.containsKey(newKey)) {
                    blIdToAddressMap.put(
                        newKey,
                        new List<LPI_BLIntFieldWrapper.Address>()
                    );
                }
                blIdToAddressMap.get(newKey).addAll(locationIdToAddressMap.get(blAuthAppIdToLocationId.get(keyString)));
            } 

            if(locIdToPubMap.containsKey(blAuthAppIdToLocationId.get(keyString))){
                newKey = keyString.substringBefore('-') +'-' + locIdToPubMap.get(blAuthAppIdToLocationId.get(keyString));
                if (!blIdToAddressMap.containsKey(newKey)) {
                    blIdToAddressMap.put(
                        newKey,
                        new List<LPI_BLIntFieldWrapper.Address>()
                    );
                }
                blIdToAddressMap.get(newKey).addAll(locationIdToAddressMap.get(blAuthAppIdToLocationId.get(keyString)));
                
            } 
        }
        return blIdToAddressMap;
    }

    /**
     * @description : Create wrapper variables for Address records.
     * @author Mohit Karani | 03-23-2023
     * @param addressRec
     * @return LPI_BLIntFieldWrapper.Address
     **/
    public LPI_BLIntFieldWrapper.Address mapAddress(
        Schema.Address addressRec
    ) {
        LPI_BLIntFieldWrapper.Address wrapAdd = new LPI_BLIntFieldWrapper.Address();
        wrapAdd.street = addressRec.street;
        wrapAdd.city = addressRec.city;
        wrapAdd.state = addressRec.countryCode == 'US' ? addressRec.state : addressRec.Business_State__c;
        wrapAdd.stateCode = addressRec.stateCode;
        wrapAdd.zipCode = addressRec.postalCode;
        wrapAdd.country = addressRec.country;
        wrapAdd.countryCode = addressRec.countryCode;
        wrapAdd.county = addressRec.county__c;
        wrapAdd.effDate = addressRec.Parent.OpenDate;
        return wrapAdd;
    }

    public Map<Id, List<LPI_BLIntFieldWrapper.perEdu>> getEduDetails(
        Set<Id> conIds
    ) {
        Map<Id, List<LPI_BLIntFieldWrapper.perEdu>> conIdToPerEduMap = new Map<Id, List<LPI_BLIntFieldWrapper.perEdu>>();
        fields = 'Id,Name,Type_of_Degree_Awarded__c,City__c,State__c,Zip_Code__c,Country__c,ContactId,GraduationDate,IdentifierIssuer';
        whereClause =
            'ContactId IN ' + LPI_ServiceUtility.getStringValuesBySet(conIds);

        for (
            PersonEducation pEd : LPI_PersonEducationDAO.getPersonEducationByDymanicQuery(
                fields,
                whereClause,
                null,
                null,
                null
            )
        ) {
            LPI_BLIntFieldWrapper.perEdu indEdu = new LPI_BLIntFieldWrapper.perEdu();
            indEdu.instName = pEd.IdentifierIssuer;
            indEdu.eduName = pEd.Name;
            indEdu.degType = pEd.Type_of_Degree_Awarded__c;
            indEdu.eduCity = pEd.City__c;
            indEdu.eduState = pEd.State__c;
            indEdu.eduZip = pEd.Zip_Code__c;
            indEdu.eduCountry = pEd.Country__c;
            indEdu.gradDt = pEd.GraduationDate;

            if (!conIdToPerEduMap.containsKey(pEd.ContactId)) {
                conIdToPerEduMap.put(
                    pEd.ContactId,
                    new List<LPI_BLIntFieldWrapper.perEdu>()
                );
            }
            conIdToPerEduMap.get(pEd.ContactId).add(indEdu);
        }
        return conIdToPerEduMap;
    }

    /**
     * @description : Create wrapper variables for PersonExamination records.
     * @author Mohit Karani | 03-23-2023
     * @param perEx
     * @return LPI_BLIntFieldWrapper.perExam
     **/
    public static LPI_BLIntFieldWrapper.perExam mapPersonExamination(
        PersonExamination perEx
    ) {
        LPI_BLIntFieldWrapper.perExam peEx = new LPI_BLIntFieldWrapper.perExam();
        peEx.isRetake = perEx.Exam_Retake__c;
        peEx.exSection = perEx.Exam_Section__c;
        peEx.exDate = perEx.ExaminationDate;
        peEx.exSecResult = perEx.Result;
        peEx.exSecScore = perEx.Score;
        peEx.exName = perEx.Examination.name;
        return peEx;
    }

    global void finish(Database.BatchableContext bc) {
    }
}