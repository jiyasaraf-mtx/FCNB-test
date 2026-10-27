/**
* @description       : Controller class to get Complaints data to populate data on PDF via vfPage
* @author            : MTX Group Product Team
* @group             : 
* @last modified on  : 07-11-2024
* @last modified by  : MTX Group Product Team
**/
public class LPI_CopyComplaintRespondentController {
    
    public Id recordId {get;set;}
    public PublicComplaintWrapper publicComplaintRecord {get;set;}
     
    private static final Integer NAME_LENGTH = 30;
    

    /**
    * @description       : Method used to get Public Complaint data and assign to repective Wrappers
    * @author            : MTX Group Product Team
    * @since             : 03-28-2024
    * @group             : 
    * @last modified on  : 07-11-2024
    * @last modified by  :MTX Group Product Team
    **/
    public LPI_CopyComplaintRespondentController(ApexPages.StandardController controller) {
        try{
            recordId  = ApexPages.currentPage().getParameters().get('recordId');

            String fields = 'Id,Name,Board_Name__r.Name,Board_Names_List__c,License_Name__c,License_Number__c,Complaint_Details__c,Contacted_Attorney__c,Lawsuit_Filed__c,Release_Authorization__c,'+
            'Lawsuit_Case_Number__c,Lawsuit_Jurisdiction__c,Complaint_Reported_to_Other_Agency__c,Contacted_Respondent__c,Contacted_Date_Details__c,Willing_to_Testify__c,Relationship_to_Respondent__c,Relationship_Details__c,'+
            'Reported_Date__c,Complainant_e_Signature__c,Coverage_Options__c,Coverage_End_Date__c,Coverage_Start_Date__c,Authorization_Expiration_Date__c,Hipaa_Section_Applicable__c,'+
            '(Select id,Entity_Representative_Contacted__c,Role,ParticipantId,TYPEOF Participant when account then id,RecordType.Name,name,firstname,lastname,middlename,PersonHomePhone,PersonEmail,Phone,BillingStreet,BillingCity,BillingCountry,BillingCountryCode,BillingPostalCode,BillingState,PersonOtherStreet,PersonOtherStateCode,PersonOtherState,PersonOtherPostalCode,PersonOtherCity,PersonOtherCountry,PersonOtherCountryCode,Social_Security_Number__c,Date_of_Birth__c,Buisness_Email__c end from PublicComplaintParticipants),'+ 
            '(select id,StartDateTime,EndDateTime,Location__c,location__r.Name from Incidents__r),'+
            '(Select id,Document_Name__c,Board_Name__c from Application_Document__r)';
            
            String whereClause = 'Id =\''+ recordId+  '\'';

             
            List<PublicComplaint> pcList = new LPI_PublicComplaintDao.LPI_PublicComplaintWithoutSharingDAO().getPublicComplaintByDymanicQueryWithoutSecurity(fields,whereClause,null,null,null);

            if(pcList.isEmpty()){
                return;
            }

            List<Businesslicense> blList = new List<BusinessLicense>();
            if(String.isNotBlank(pcList[0].License_Number__c)){
                blList = new LPI_BusinessLicenseDAO.LPI_BusinessLicenseWithoutSharingDAO().getBusinessLicenseByDymanicQueryWithoutSecurity('Name,Business_Entity_Name__c','Name =\''+ pcList[0].License_Number__c+'\'',null,null,null);
            }
            
            Set<Id> locationIdSet = new Set<Id>();
            Map<Id,Schema.Address> locIdtoAddressMap = new Map<Id,Schema.Address>();
            
            if(pcList[0].Incidents__r != null){
                for(Incident incident : pcList[0].Incidents__r){
                    if(incident.Location__c != null){
                        locationIdSet.add(incident.Location__c);
                    }
                }
            }
            if(!locationIdSet.isEmpty()) {
                 
                String fieldToQuery = 'ID, Street, City, State, PostalCode, ParentId, CountryCode, Business_State__c';
                String locWhereClause = 'ParentId IN ' + LPI_ServiceUtility.getStringValuesBySet(locationIdSet);
                for (
                Schema.Address tempAddress : new LPI_AddressDAO.LPI_AddressDAOWithoutSharing().getAddressWithoutSecurityEnforced(
                fieldToQuery,
                locWhereClause,
                null,
                null,
                null
                )
                ) {
                    locIdtoAddressMap.put(tempAddress.ParentId, tempAddress);
                }
            }

             
            PublicComplaintWrapper pcWrapper = new PublicComplaintWrapper();
            for(PublicComplaint pc : pcList){
                if(pc != null){
                    if(!pc.Incidents__r.isEmpty()){
                        pcWrapper.inscStartDate = pc.Incidents__r[0].StartDateTime != null ? pc.Incidents__r[0].StartDateTime.format('MM/dd/yyyy') : '';
                        pcWrapper.inscEndDate = pc.Incidents__r[0].EndDateTime != null ? pc.Incidents__r[0].EndDateTime.format('MM/dd/yyyy') : '';
                        pcWrapper.inscLocName = pc.Incidents__r[0].location__r.Name != null ? pc.Incidents__r[0]?.location__r.Name.split('-')[0] : null;
                        if(pc.Incidents__r[0].Location__c != null){
                            pcWrapper.inscLocation = removeNullFromAddress(locIdtoAddressMap.get(pc.Incidents__r[0].Location__c)?.Street,locIdtoAddressMap.get(pc.Incidents__r[0].Location__c)?.City,locIdtoAddressMap.get(pc.Incidents__r[0].Location__c)?.State,locIdtoAddressMap.get(pc.Incidents__r[0].Location__c)?.PostalCode);
                        }
                    }
                    pcWrapper.complaintName = pc.Name != null ? transformLength(pc.Name,NAME_LENGTH) : '';
                    pcWrapper.complaintDesc = pc.Complaint_Details__c;
                    pcWrapper.contactedAttorney = pc.Contacted_Attorney__c;
                    pcWrapper.filledLawsuit = pc.Lawsuit_Filed__c;
                    pcWrapper.lawsuitJuri = pc.Lawsuit_Jurisdiction__c;
                    pcWrapper.lawsuitCaseNo = pc.Lawsuit_Case_Number__c;
                    pcWrapper.complReportedToOtherAgency = pc.Complaint_Reported_to_Other_Agency__c;
                    pcWrapper.contactedRespondent = pc.Contacted_Respondent__c;
                    pcWrapper.contactedRespondentDate = pc.Contacted_Date_Details__c;
                    pcWrapper.relToRespondent = pc.Relationship_to_Respondent__c;
                    pcWrapper.relationDetails = pc.Relationship_Details__c;
                    pcWrapper.willingToTestify = pc.Willing_to_Testify__c;
                    pcWrapper.eSign = pc.Complainant_e_Signature__c;
                    pcWrapper.hippaAuthExpDate = pc.Authorization_Expiration_Date__c?.format();
                    pcWrapper.isPatientRelatedToComplaint = 'Yes';
                    pcWrapper.reportedDate = pc.Reported_Date__c != null ? pc.Reported_Date__c.format() : null;
                    pcWrapper.hippaConsent = pc.Release_Authorization__c;

                    
                    List<RespondantWrapper> respWrapperList = new List<RespondantWrapper>();
                    List<WitnessWrapper> witWrapperList = new List<WitnessWrapper>();
                    List<AttorneyWrapper> attWrapperList = new List<AttorneyWrapper>();
                    List<EntityWrapper> entityWrapperList = new List<EntityWrapper>();
                    List<ComplaintParticipantWrapper> compWrapperList = new List<ComplaintParticipantWrapper>();
                    List<PatientWrapper> patientWrapperList = new List<PatientWrapper>();
                    List<DocumentWrapper> documentWrapperList = new List<DocumentWrapper>();
                    LPI_Wrapper.BoardSpecificQuestions boardQues = new LPI_Wrapper.BoardSpecificQuestions();
                    if(pc.PublicComplaintParticipants != null){
                        
                        for(ComplaintParticipant cp : pc.PublicComplaintParticipants){
                            Switch on cp.Role{
                                when 'Respondent' {
                                    RespondantWrapper respWrapper = new RespondantWrapper();
                                    if(cp.Participant instanceof Account){
                                        Account accRec = (Account) cp.Participant;
                                        respWrapper.respEntityName = accRec.RecordType.Name == 'Business' ? transformLength(accRec?.Name,NAME_LENGTH) : transformLength(blList[0].Business_Entity_Name__c,NAME_LENGTH);
                                        respWrapper.respBoradName = pc.Board_Names_List__c;
                                        respWrapper.respProf = pc.License_Name__c;
                                        respWrapper.respLicenseNo = pc.License_Number__c;
                                        respWrapper.respTeleNo = accRec.RecordType.Name == 'Business' ? accRec.phone : accRec.PersonHomePhone;
                                        respWrapper.respAddress = accRec.RecordType.Name == 'Business' ? removeNullFromAddress(accRec.BillingStreet,accRec.BillingCity,accRec.BillingState,accRec.BillingPostalCode) : 
                                                                                                            removeNullFromAddress(accRec.PersonOtherStreet,accRec.PersonOtherCity,accRec.PersonOtherState,accRec.PersonOtherPostalCode);
                                        respWrapperList.add(respWrapper);
                                    }
                                }

                                when 'Complainant' {
                                    ComplaintParticipantWrapper cpWrapper = new ComplaintParticipantWrapper();
                                    if(cp.Participant instanceof Account){
                                        Account accRec = (Account) cp.Participant;
                                        cpWrapper.compFirstName = accRec.firstName;
                                        cpWrapper.compLastName = accRec.LastName;
                                        cpWrapper.compMiddleName = accRec.MiddleName;
                                        cpWrapper.compEmail = accRec.PersonEmail;
                                        cpWrapper.compTeleNo = accRec.PersonHomePhone;
                                        cpWrapper.compCellPhone = accRec.phone;
                                        cpWrapper.compStreet = accRec.PersonOtherStreet;
                                        cpWrapper.compCity = accRec.PersonOtherCity;
                                        cpWrapper.compState = accRec.PersonOtherState;
                                        cpWrapper.compZipCode = accRec.PersonOtherPostalCode;
                                        cpWrapper.compSSN = accRec.Social_Security_Number__c != null ? accRec.Social_Security_Number__c : null;
                                        cpWrapper.compDOB = accRec.Date_of_Birth__c?.format();
                                        compWrapperList.add(cpWrapper);
                                    }
                                }

                                when 'Witness' {
                                    WitnessWrapper witWrapper = new WitnessWrapper();
                                    if(cp.Participant instanceof Account){
                                        Account accRec = (Account) cp.Participant;
                                        witWrapper.witName = transformLength(accRec?.Name,NAME_LENGTH);
                                        witWrapper.witAddress = removeNullFromAddress(accRec.PersonOtherStreet,accRec.PersonOtherCity,accRec.PersonOtherState,accRec.PersonOtherPostalCode);
                                        witWrapper.witEmail = accRec.PersonEmail;
                                        witWrapper.witTeleNo = accRec.PersonHomePhone;
                                        witWrapperList.add(witWrapper);
                                    }
                                }

                                when 'Attorney','Attorney Complainant' {
                                    AttorneyWrapper attWrapper = new AttorneyWrapper();
                                    if(cp.Participant instanceof Account){
                                        Account accRec = (Account) cp.Participant;
                                        attWrapper.attName = transformLength(accRec?.Name,NAME_LENGTH);
                                        attWrapper.attAddress = removeNullFromAddress(accRec.PersonOtherStreet,accRec.PersonOtherCity,accRec.PersonOtherState,accRec.PersonOtherPostalCode);
                                        attWrapper.attEmail = accRec.PersonEmail;
                                        attWrapper.attTeleNo = accRec.PersonHomePhone;
                                        attWrapperList.add(attWrapper);
                                    }
                                }

                                when 'Other Entity' {
                                    EntityWrapper entWrapper = new EntityWrapper();
                                    if(cp.Participant instanceof Account){
                                        Account accRec = (Account) cp.Participant;
                                        entWrapper.entName = transformLength(accRec?.Name,NAME_LENGTH);
                                        entWrapper.entAddress = removeNullFromAddress(accRec.BillingStreet,accRec.BillingCity,accRec.BillingState,accRec.BillingPostalCode);
                                        entWrapper.entEmail = accRec.Buisness_Email__c;
                                        entWrapper.entTeleNo = accRec.phone;
                                        entWrapper.entRepresentative = cp.Entity_Representative_Contacted__c;
                                        entityWrapperList.add(entWrapper);
                                    }
                                }

                                When 'Patient' {
                                    PatientWrapper patientWrapper = new PatientWrapper();
                                    pcWrapper.isPatientRelatedToComplaint = 'No';
                                    if(cp.Participant instanceof Account){
                                        Account accRec = (Account) cp.Participant;
                                        patientWrapper.patientFirstName = accRec.firstName;
                                        patientWrapper.patientLastName = accRec.LastName;
                                        patientWrapper.patientMiddleName = accRec.MiddleName;
                                        patientWrapper.patientEmail = accRec.PersonEmail;
                                        patientWrapper.patientTeleNo = accRec.PersonHomePhone;
                                        patientWrapper.patientStreet = accRec.PersonOtherStreet;
                                        patientWrapper.patientCity = accRec.PersonOtherCity;
                                        patientWrapper.patientState = accRec.PersonOtherState;
                                        patientWrapper.patientZipCode = accRec.PersonOtherPostalCode;
                                        patientWrapper.patientSSN = accRec.Social_Security_Number__c;
                                        patientWrapper.patientDOB = accRec.Date_of_Birth__c?.format();
                                        patientWrapperList.add(patientWrapper);
                                    }
                                }
                            }
                        }
                    }
                     
                    pcWrapper.isBoardSpecific = false;
                    
                    if(pcList[0].Application_Document__r != null){
                        for(Application_Document__c ad : pcList[0].Application_Document__r){
                            DocumentWrapper docWrap = new DocumentWrapper();
                            docWrap.documentName = ad.Document_Name__c;
                            documentWrapperList.add(docWrap);
                        }
                    }

                     
                    if(pc.Hipaa_Section_Applicable__c == true){
                        pcWrapper.isHippaSectionAvailable = pc.Hipaa_Section_Applicable__c;
                        pcWrapper.coverageOption = pc.Coverage_Options__c;
                        if(pc.Coverage_Options__c == 'Covering the period of health care from'){
                            pcWrapper.coverageStartDate = pc.Coverage_Start_Date__c?.format();
                            pcWrapper.coverageEndDate = pc.Coverage_End_Date__c?.format();
                        }
                    }

                     
                    pcWrapper.respWrapList = respWrapperList;
                    pcWrapper.complaintWrapList = compWrapperList;
                    pcWrapper.entityWrapList = entityWrapperList;
                    pcWrapper.attWrapList = attWrapperList;
                    pcWrapper.witnessWrapList = witWrapperList;
                    pcWrapper.patientWrapList = patientWrapperList;
                    pcWrapper.documentWrapList = documentWrapperList;
                    publicComplaintRecord = pcWrapper;
                }
            }

        } catch (Exception e) {
            LPI_ExceptionManager.logException('LPI_CopyComplaintRespondentController', 'LPI_CopyComplaintRespondentController', e);
        }
    }

    /**
        * @description       : Method used to add spaces for text wrapping in Vfpage
        * @author            : MTX Group Product Team
        * @since             : 9th April, 2024
        * @group             : 
        * @last modified on  : 07-11-2024
        * @last modified by  : MTX Group Product Team
        **/
        public static String transformLength(String textdata , Integer maxLength){
            if(String.isNotBlank(textdata)){
                if(!textdata.contains(' ') && textdata.length() > maxLength){
                    textdata = textdata.substring(0,maxLength) +' '+transformLength(textdata.substring(maxLength),maxLength);
                }
            }
            return textData;
        }

    /**
        * @description       : Method used remove null from address
        * @author            : MTX Group Product Team
        * @since             : 9th April, 2024
        * @group             : 
        * @last modified on  : 07-11-2024
        * @last modified by  : MTX Group Product Team
        **/
        public static String removeNullFromAddress(String street,String city,String state,String postalCode){
            String addString = '';

            if(street != null && (city != null || state != null || postalCode != null)){
                addString += street +', ';
            }else if(street != null){
                addString += street;
                return addString;
            }
            if(city != null){
                addString += city+ ' ';
            }
            if(state != null){
                addString += state+ ' ';
            }
            if(postalCode != null){
                addString += postalCode+ ' ';
            }

            return addString;
        }

     
    public class PublicComplaintWrapper
    {
        public String complaintName {get;set;}
        public String complaintDesc {get;set;}
        public String contactedAttorney {get;set;}
        public String filledLawsuit {get;set;}
        public String lawsuitJuri {get;set;}
        public String lawsuitCaseNo {get;set;}
        public String complReportedToOtherAgency {get;set;}
        public String contactedRespondent {get;set;}
        public String contactedRespondentDate {get;set;}
        public String relToRespondent {get;set;}
        public String relationDetails {get;set;}
        public String willingToTestify {get;set;}
        public String coverageOption {get;set;}
        public String coverageStartDate {get;set;}
        public String coverageEndDate {get;set;}
        public String reportedDate {get;set;}
        public String eSign {get;set;}
        public String isPatientRelatedToComplaint {get;set;}
        public String inscStartDate {get;set;}
        public String inscEndDate {get;set;}
        public String inscLocation {get;set;}
        public String inscLocName {get;set;}
        public Boolean isBoardSpecific {get;set;}
        public String selectedBoardName {get;set;}
        public Boolean isHippaSectionAvailable {get;set;}
        public String hippaAuthExpDate {get;set;}
        public Boolean hippaConsent {get;set;}
        public List<RespondantWrapper> respWrapList {get;set;}
        public List<WitnessWrapper> witnessWrapList {get;set;}
        public List<AttorneyWrapper> attWrapList {get;set;}
        public List<EntityWrapper> entityWrapList {get;set;}
        public List<ComplaintParticipantWrapper> complaintWrapList {get;set;}
        public List<PatientWrapper> patientWrapList {get;set;}
        public List<DocumentWrapper> documentWrapList {get;set;}
        public LPI_Wrapper.BoardSpecificQuestions boardSpecficQues{get;set;}
    }

    
    public class RespondantWrapper
    {
        public String respEntityName {get;set;}
        public String respBoradName {get;set;}
        public String respProf {get;set;}
        public String respLicenseNo {get;set;}
        public String respAddress {get;set;}
        public String respTeleNo {get;set;}
    }

    
    public class WitnessWrapper
    {
        public String witName {get;set;}
        public String witAddress {get;set;}
        public String witTeleNo {get;set;}
        public String witEmail {get;set;}
    }

     
    public class AttorneyWrapper
    {
        public String attName {get;set;}
        public String attAddress {get;set;}
        public String attTeleNo {get;set;}
        public String attEmail {get;set;}
    }

     
    public class EntityWrapper
    {
        public String entName {get;set;}
        public String entAddress {get;set;}
        public String entTeleNo {get;set;}
        public String entEmail {get;set;}
        public String entRepresentative {get;set;}
    }

     
    public class ComplaintParticipantWrapper
    {
        public String compFirstName {get;set;}
        public String compLastName {get;set;}
        public String compMiddleName {get;set;}
        public String compEmail {get;set;}
        public String compTeleNo {get;set;}
        public String compCellPhone {get;set;}
        public String compStreet {get;set;}
        public String compCity {get;set;}
        public String compState {get;set;}
        public String compZipCode {get;set;}
        public String compSSN {get;set;}
        public String compDOB {get;set;}
    }

     
    public class PatientWrapper
    {
        public String patientSSN {get;set;}
        public String patientDOB {get;set;}
        public String patientFirstName {get;set;}
        public String patientLastName {get;set;}
        public String patientMiddleName {get;set;}
        public String patientEmail {get;set;}
        public String patientTeleNo {get;set;}
        public String patientStreet {get;set;}
        public String patientCity {get;set;}
        public String patientState {get;set;}
        public String patientZipCode {get;set;}
    }

     
    public class DocumentWrapper 
    {
        public String documentName {get;set;}
    }
}