/**
 * @description       : 
 * @author            : Mohit Karani
 * @group             : 
 * @last modified on  : 05-03-2024
 * @last modified by  : MTX Group Inc.
**/
public with sharing class LPI_CaseController {
    
    // public static final String BILLING_ADDRESS_TYPE = 'Billing Address';
    // public static final String MAILING_ADDRESS_TYPE = 'Mailing Address';
    // public static final String RESIDENCE_ADDRESS_TYPE = 'Residence Address';
    // public static final String SHIPPING_ADDRESS_TYPE = 'Shipping Address';

    @AuraEnabled
    public static LPI_Wrapper.AccountWrapper getAccountDetails(String recordId){
        try{
            if(String.isBlank(recordId)){
                return null;
            }
            String fields = 'Id,AccountId,(SELECT ID,PublicComplaintId,PublicComplaint.License_Name__c FROM ComplaintCaseCase LIMIT 1)';
            String whereClause = 'Id =\'' + String.escapeSingleQuotes(recordId) + '\'';
            List<Case> caseList = LPI_CaseDAO.getCaseRecords(fields,whereClause,null,null);
            if(caseList.isEmpty() || String.isBlank(caseList[0].AccountId) || caseList[0].ComplaintCaseCase.isEmpty() ){
                return null;
            }
            fields = 'Id,PersonContactId,RecordTypeId,Name,FirstName,MiddleName,LastName,Doing_Business_As_DBA_or_Trade_Name__c,Social_Security_Number__c,Federal_Employer_ID_Number_EIN__c';
            whereClause = 'Id =\'' + caseList[0].AccountId + '\'';
            List<Account> accountList = LPI_AccountDAO.getAccountListByDynamicQuery(fields.split(';'),whereClause,null,null,null);
            if(accountList.isEmpty()){
                return null;
            }
            Account accRec = accountList[0];
            LPI_Wrapper.AccountWrapper accWrapper = new LPI_Wrapper.AccountWrapper();
            accWrapper.firstName = accRec.FirstName;
            accWrapper.lastName = accRec.LastName;
            accWrapper.middleName = accRec.MiddleName;
            accWrapper.name = accRec.RecordTypeId == LPI_LiteralConstant.PERSON_ACCOUNT_REC_TYPE_ID ? null :  accRec.Name;
            accWrapper.ssn = accRec.Social_Security_Number__c;
            accWrapper.fein = accRec.Federal_Employer_ID_Number_EIN__c;
            accWrapper.dba = accRec.Doing_Business_As_DBA_or_Trade_Name__c;
            accWrapper.profession = caseList[0].ComplaintCaseCase[0].PublicComplaint.License_Name__c;

            fields = 'Id,Business_License__r.Name,Business_License__r.Regulatory_Authorization_Type_Name__c';
            whereClause = 'Business_License__r.ContactId != NULL AND Public_Complaint__c = \'' + caseList[0].ComplaintCaseCase[0].PublicComplaintId + '\'';
            whereClause = accRec.RecordTypeId == LPI_LiteralConstant.PERSON_ACCOUNT_REC_TYPE_ID ? whereClause +' AND Business_License__r.ContactId = \'' + accRec.PersonContactId  + '\'' :  whereClause + ' AND Business_License__r.AccountId = \'' + accRec.Id  + '\'';

            List<Business_Complaint__c> businessComplaintList = new List<Business_Complaint__c>();
            LPI_BusinesComplaintJunctionDao.LPI_BusinesComplaintJunctionDaoWithout bcjRec  = new LPI_BusinesComplaintJunctionDao.LPI_BusinesComplaintJunctionDaoWithout();
            businessComplaintList = bcjRec.getBusinessComplaintByDymanicQueryWithout(fields,whereClause,null,null,null);
            if(!businessComplaintList.isEmpty()){
                accWrapper.licenseNumber = businessComplaintList[0].Business_License__r.Name;
            }
            fields = 'Id,LocationId';
            whereClause = ' LocationId != NULL AND ParentRecordId = \'' + accRec.Id + '\'';
            List<AssociatedLocation> associatedLocList = LPI_AssociatedLocationDAO.getAssociatedLocationListByDynamicQuery(fields.split(','),whereClause,1000,null,null);
            if(associatedLocList.isEmpty()){
                return accWrapper;
            }
            Set<String> locationIdSet = new Set<String>();
            for (AssociatedLocation accLoc : associatedLocList) {
                locationIdSet.add(accLoc.LocationId);
            }

            fields = 'Id,Street,State,City,PostalCode,Country,County__c,LocationType,Business_State__c';
            whereClause = ' LocationType != NULL AND ParentId IN ' +  LPI_ServiceUtility.getStringValuesByStringSet(locationIdSet);
            List<Schema.Address> addressList = LPI_AddressDAO.getAddressByDymanicQuery(
                fields,
                whereClause,
                NULL,
                'CreatedDate',
                'DESC'
            );
            if(associatedLocList.isEmpty()){
                return accWrapper;
            }
            accWrapper.addressRecords = new List<LPI_Wrapper.AddressWrapper>();
            for(Schema.Address addressRec : addressList){
                LPI_Wrapper.AddressWrapper addressRecWrapper = new LPI_Wrapper.AddressWrapper();
                addressRecWrapper.streetOne = addressRec.Street;
                addressRecWrapper.city = addressRec.City;
                addressRecWrapper.state = String.isNotBlank(addressRec.State) ? addressRec.State : addressRec.Business_State__c;
                addressRecWrapper.zipCode = addressRec.PostalCode;
                addressRecWrapper.country = addressRec.Country;
                addressRecWrapper.county = addressRec.County__c;
                addressRecWrapper.addressType = addressRec.LocationType;
                addressRecWrapper.addressId = addressRec.Id;
                accWrapper.addressRecords.add(addressRecWrapper);
            }
    
            return accWrapper;
        }catch(Exception e){
            LPI_ExceptionManager.logException(
                'LPI_CaseController',
                'getAccountDetails',
                e
            );
            throw new LPI_Exception(e.getMessage());
        }
        
    }

    /**
    * @description : Method to fetch public Complaint details related to Case record.
    * @author Vamshi Kumar | 08-24-2023
    * @param recordId
    * @return LPI_Wrapper.ComplaintsWrapper
    **/
    @AuraEnabled
    public static LPI_Wrapper.ComplaintsWrapper getPublicComplaintFromCase(String recordId){
        try{
            if(String.isBlank(recordId)){
                return null;
            }
            String fields = 'Id,CaseId,PublicComplaint.Complaint_Details__c,PublicComplaint.IncidentDate,PublicComplaint.Contacted_Attorney__c,PublicComplaint.Lawsuit_Filed__c,PublicComplaint.Complaint_Reported_to_Other_Agency__c,' +
                'PublicComplaint.Contacted_Respondent__c,PublicComplaint.Relationship_to_Respondent__c,PublicComplaint.Willing_to_Testify__c,PublicComplaint.Contacted_Date__c,PublicComplaint.Relationship_Details__c,'+
                'PublicComplaint.Coverage_Options__c,PublicComplaint.Coverage_Start_Date__c,PublicComplaint.Release_Authorization__c,PublicComplaint.Coverage_End_Date__c,PublicComplaint.Authorization_Expiration_Date__c';
            String whereClause = 'CaseId =\'' + String.escapeSingleQuotes(recordId) + '\'';
            List<ComplaintCase> complaintCaseList = LPI_ComplaintCaseDao.fetchComplaintCaseRecords(fields,whereClause,null,null);
            if(complaintCaseList.isEmpty()){
                return null;
            }
            ComplaintCase compCase = complaintCaseList[0];
            LPI_Wrapper.ComplaintsWrapper pubCompWrapper = new LPI_Wrapper.ComplaintsWrapper();
            pubCompWrapper.complaintDesc = compCase.PublicComplaint.Complaint_Details__c;
            pubCompWrapper.incidentDateString = Date.valueOf(compCase.PublicComplaint.IncidentDate)?.format();
            pubCompWrapper.contactedAttorney = compCase.PublicComplaint.Contacted_Attorney__c;
            pubCompWrapper.lawSuitFiled = compCase.PublicComplaint.Lawsuit_Filed__c;
            pubCompWrapper.complaintToOtherAgency = compCase.PublicComplaint.Complaint_Reported_to_Other_Agency__c;
            pubCompWrapper.contactedIndividualAboutComplaint = compCase.PublicComplaint.Contacted_Respondent__c;
            pubCompWrapper.relationshipToRespondent = compCase.PublicComplaint.Relationship_to_Respondent__c;
            pubCompWrapper.testifyHearing = compCase.PublicComplaint.Willing_to_Testify__c;
            pubCompWrapper.contactedIndividualAboutCompDate = Date.valueOf(compCase.PublicComplaint.Contacted_Date__c)?.format();
            pubCompWrapper.relationshipDetails = compCase.PublicComplaint.Relationship_Details__c;
            pubCompWrapper.coverageOption = compCase.PublicComplaint.Coverage_Options__c;
            pubCompWrapper.coverageStartDateString = Date.valueOf(compCase.PublicComplaint.Coverage_Start_Date__c)?.format();
            pubCompWrapper.releaseAuthorization = compCase.PublicComplaint.Release_Authorization__c == true ? LPI_LiteralConstant.MODPR_YES : LPI_LiteralConstant.MODPR_NO;
            pubCompWrapper.coverageEndDateString = Date.valueOf(compCase.PublicComplaint.Coverage_End_Date__c)?.format();
            pubCompWrapper.authExpirationDateString = Date.valueOf(compCase.PublicComplaint.Authorization_Expiration_Date__c)?.format();
            return pubCompWrapper;
        }catch(Exception e){
            LPI_ExceptionManager.logException(
                'LPI_CaseController',
                'getPublicComplaintFromCase',
                e
            );
            throw new LPI_Exception(e.getMessage());
        }
    }
    /**
    * @description : Method to fetch public Complaint details related to Case record.
    * @author Vamshi Kumar | 08-24-2023
    * @param recordId
    * @return LPI_Wrapper.ComplaintsWrapper
    **/
    @AuraEnabled
    public static String getCaseData(String caseID){
        List<Case> caseList = LPI_CaseDAO.getCaseRecords('Case_Number__c',
        'Id =\'' + String.escapeSingleQuotes(caseID) + '\'',null,null);
        return caseList[0].Case_Number__c;
    }

        /**
    * @description : Method to fetch incident details Case record.
    * @author Vamshi Kumar | 03-27-2024
    * @param recordId
    * @return List<LPI_Wrapper.IncidentWrapper>
    **/
   @AuraEnabled
   public static List<LPI_Wrapper.IncidentWrapper> getIncidentDetailsFromCase(
       String recordId
   ) {
       try {
           if (String.isBlank(recordId)) {
               return null;
           }
           String fields;
           String whereClause;
           fields = 'Id,CaseId,PublicComplaintId';
           whereClause =
               'CaseId =\'' +
               String.escapeSingleQuotes(recordId) +
               '\'';
           List<ComplaintCase> complaintCaseList = LPI_ComplaintCaseDao.fetchComplaintCaseRecords(
               fields,
               whereClause,
               null,
               null
           );
           if (
               complaintCaseList.isEmpty() ||
               String.isBlank(complaintCaseList[0].PublicComplaintId)
           ) {
               return null;
           }
           fields = 'Id,Complaint_Number__c,EndDateTime,StartDateTime,Location__c';
           whereClause =
               'Complaint_Number__c =\'' +
               String.escapeSingleQuotes(
                   complaintCaseList[0].PublicComplaintId
               ) +
               '\'';
           Map<Id, Incident> incidentLocIdToDetailsMap = new Map<Id, Incident>();
           for(Incident inc : LPI_IncidentDao.fetchIncidents(
               fields,
               whereClause,
               null,
               null,
               null
           )){
               if(String.isNotBlank(inc.Location__c))
               {
                   incidentLocIdToDetailsMap.put(inc.Location__c, inc);
               }
           }
           if(incidentLocIdToDetailsMap.isEmpty()){
               return null;
           }
           List<LPI_Wrapper.IncidentWrapper> incidentWrapperList = new List<LPI_Wrapper.IncidentWrapper>();
           fields = 'Id,Street,State,City,PostalCode,Country,County__c,Business_State__c,ParentId';
           whereClause = 'ParentId IN ' +  LPI_ServiceUtility.getStringValuesBySet(incidentLocIdToDetailsMap.keySet());
           for(Schema.Address address : LPI_AddressDAO.getAddressByDymanicQuery(
               fields,
               whereClause,
               null,
               'CreatedDate',
               'DESC'
           )){
               LPI_Wrapper.IncidentWrapper incidentWrapper = new LPI_Wrapper.IncidentWrapper();
               incidentWrapper.incidentId = incidentLocIdToDetailsMap.get(address.ParentId).Id;
               incidentWrapper.startDateString = Date.valueOf(incidentLocIdToDetailsMap.get(address.ParentId).StartDateTime).format();
               incidentWrapper.endDateString = Date.valueOf(incidentLocIdToDetailsMap.get(address.ParentId).EndDateTime).format();
               incidentWrapper.addressInfo = address.Street + ',' + address.City + ',' + (String.isNotBlank(address.State) ? address.State : address.Business_State__c)
                   + ',' + address.PostalCode + ',' + address.Country + ',' + address.County__c;
               incidentWrapperList.add(incidentWrapper);
           }
           return incidentWrapperList;
       } catch (Exception e) {
           LPI_ExceptionManager.logException(
               'LPI_CaseController',
               'getIncidentDetailsFromCase',
               e
           );
           throw new LPI_Exception(e.getMessage());
       }
   }
}