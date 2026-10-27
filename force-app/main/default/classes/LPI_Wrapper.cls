/**
 * @description : Wrapper class for MO_DPR project.
 * @author : Mohit Karani
 * @group :
 * @last modified on : 06-19-2024
 * @last modified by : Ayush Dev
 **/
public with sharing class LPI_Wrapper {

    public class RespondentWrapperNew {
        @AuraEnabled
        public ProfessionDetailsWrapper professionDetails;
        @AuraEnabled
        public LicenseDetailsWrapper licenseDetails;
        @AuraEnabled
        public EmployerWrapper employerInfo;
        @AuraEnabled
        public AddressWrapper addressData{get;set;}
        @AuraEnabled
        public String uniqueKey;
        @AuraEnabled
        public String accountId;
        @AuraEnabled
        public String email;
        @AuraEnabled
        public String telephone;
        @AuraEnabled
        public String entityName{get;set;}
        @AuraEnabled
        public String firstName{get;set;}
        @AuraEnabled
        public String middleName;
        @AuraEnabled
        public String lastName;
        @AuraEnabled 
        public Integer respCounter;
        @AuraEnabled 
        public String publicComplaintName;
        @AuraEnabled 
        public String sNoDisplayVal; 

        public RespondentWrapperNew processJSONString(String jsonString) {
            RespondentWrapperNew instance = (RespondentWrapperNew) JSON.deserialize(
                jsonString,
                RespondentWrapperNew.class
            );
            if (instance.employerInfo != null) {
                instance.employerInfo = instance.employerInfo.processJSONString(
                    JSON.serialize(instance.employerInfo)
                );
            }
            if (instance.addressData != null) {
                instance.addressData = instance.addressData.processJSONString(
                    JSON.serialize(instance.addressData)
                );
            }
            removeTrailingSpaces(instance);
            return instance;
        }

        private void removeTrailingSpaces(RespondentWrapperNew instance) {
            instance.firstName = String.isNotBlank(instance.firstName)
                ? instance.firstName.trim()
                : instance.firstName;
            instance.lastName = String.isNotBlank(instance.lastName)
                ? instance.lastName.trim()
                : instance.lastName;
            instance.middleName = String.isNotBlank(instance.middleName)
                ? instance.middleName.trim()
                : instance.middleName;
            instance.email = String.isNotBlank(instance.email)
                ? instance.email.trim()
                : instance.email;
            instance.telephone = String.isNotBlank(instance.telephone)
                ? instance.telephone.trim()
                : instance.telephone;
        }
    }
    public class ProfessionDetailsWrapper {
        @AuraEnabled 
        public String pcId;
        @AuraEnabled 
        public String profession;
        @AuraEnabled 
        public String knowsRespondentProfession;
        @AuraEnabled 
        public String professionAuthType;
        @AuraEnabled 
        public String selectedBoardName;
        @AuraEnabled 
        public String licensedUnlicensed;
        @AuraEnabled
        public String entityOrIndividual;
        @AuraEnabled
        public String licenseTypeSelected;
    }

    public class LicenseDetailsWrapper {
        @AuraEnabled 
        public Boolean isPrimary;
        @AuraEnabled 
        public String entityName;
        @AuraEnabled 
        public String businessId;
        @AuraEnabled 
        public String licenseNum;
        @AuraEnabled 
        public String authorizationType;
        @AuraEnabled 
        public String profession;
        @AuraEnabled
        public String accountId;
        @AuraEnabled 
        public String licenseNumberText;
        @AuraEnabled 
        public AccountInfoWrapper licenseeAccountInfo;
        @AuraEnabled 
        public String otherLicenseState;
    }


    public class AccountInfoWrapper {
        @AuraEnabled 
        public String firstName;
        @AuraEnabled 
        public String middleName;
        @AuraEnabled 
        public String lastName;
        @AuraEnabled 
        public String ssn;
        @AuraEnabled 
        public String entityName;
        @AuraEnabled 
        public String suffixName;
        @AuraEnabled 
        public String dbaName;
        @AuraEnabled 
        public String corporateName;
    }

    public class RespondentWrapper {
        @AuraEnabled
        public String entityName{get;set;}
        @AuraEnabled
        public String businessId;
        @AuraEnabled
        public AddressWrapper addressData{get;set;}
        @AuraEnabled
        public String telephone;
        @AuraEnabled 
        public String cellPhone;
        @AuraEnabled
        public String profession;
        @AuraEnabled
        public String role;
        @AuraEnabled
        public String email;
        @AuraEnabled
        public String uniqueKey;
        @AuraEnabled
        public List<String> selectedBusinessIds;
        @AuraEnabled
        public String accountId;
        @AuraEnabled
        public String authorizationType;
        @AuraEnabled
        public String licenseNum;
        @AuraEnabled
        public String individualOrBusiness;
        @AuraEnabled
        public EmployerWrapper employerInfo;
        @AuraEnabled
        public String firstName{get;set;}
        @AuraEnabled
        public String middleName;
        @AuraEnabled
        public String lastName;
        @AuraEnabled
        public String licensedUnlicensed;
        @AuraEnabled
        public String employmentStatus;
        @AuraEnabled 
        public String entityOrIndividual;
        @AuraEnabled 
        public String entityRepresentative;
        
        public RespondentWrapper processJSONString(String jsonString) {
            RespondentWrapper instance = (RespondentWrapper) JSON.deserialize(
                jsonString,
                RespondentWrapper.class
            );
            if (instance.employerInfo != null) {
                instance.employerInfo = instance.employerInfo.processJSONString(
                    JSON.serialize(instance.employerInfo)
                );
            }
            if (instance.addressData != null) {
                instance.addressData = instance.addressData.processJSONString(
                    JSON.serialize(instance.addressData)
                );
            }
            removeTrailingSpaces(instance);
            return instance;
        }

        private void removeTrailingSpaces(RespondentWrapper instance) {
            instance.firstName = String.isNotBlank(instance.firstName)
                ? instance.firstName.trim()
                : instance.firstName;
            instance.lastName = String.isNotBlank(instance.lastName)
                ? instance.lastName.trim()
                : instance.lastName;
            instance.middleName = String.isNotBlank(instance.middleName)
                ? instance.middleName.trim()
                : instance.middleName;
            instance.email = String.isNotBlank(instance.email)
                ? instance.email.trim()
                : instance.email;
            instance.telephone = String.isNotBlank(instance.telephone)
                ? instance.telephone.trim()
                : instance.telephone;
        }
    }

    public class EmployerWrapper {
        @AuraEnabled
        public String employerName;
        @AuraEnabled
        public AddressWrapper employerAddress;
        @AuraEnabled
        public String telephone;
        @AuraEnabled
        public String email;
        @AuraEnabled 
        public String employmentStatus;

        public EmployerWrapper processJSONString(String jsonString) {
            EmployerWrapper instance = (EmployerWrapper) JSON.deserialize(
                jsonString,
                EmployerWrapper.class
            );
            if (instance.employerAddress != null) {
                instance.employerAddress = instance.employerAddress.processJSONString(
                    JSON.serialize(instance.employerAddress)
                );
            }
            removeTrailingSpaces(instance);
            return instance;
        }

        private void removeTrailingSpaces(EmployerWrapper instance) {
            instance.employerName = String.isNotBlank(instance.employerName)
                ? instance.employerName.trim()
                : instance.employerName;
            instance.email = String.isNotBlank(instance.email)
                ? instance.email.trim()
                : instance.email;
            instance.telephone = String.isNotBlank(instance.telephone)
                ? instance.telephone.trim()
                : instance.telephone;
        }
    }

    public class AddressWrapper {
        @AuraEnabled
        public String streetOne{get;set;}
        @AuraEnabled
        public String streetTwo{get;set;}
        @AuraEnabled
        public String city{get;set;}
        @AuraEnabled
        public String state{get;set;}
        @AuraEnabled
        public String zipCode{get;set;}
        @AuraEnabled
        public String addressType;
        @AuraEnabled
        public String locationName{get;set;}
        @AuraEnabled
        public String country;
        @AuraEnabled
        public String otherState;
        @AuraEnabled
        public String county;
        @AuraEnabled
        public Boolean isUs;
        @AuraEnabled
        public String addressId;

        public AddressWrapper processJSONString(String jsonString) {
            AddressWrapper instance = (AddressWrapper) JSON.deserialize(
                jsonString,
                AddressWrapper.class
            );
            removeTrailingSpaces(instance);

            return instance;
        }

        private void removeTrailingSpaces(AddressWrapper instance) {
            instance.streetOne = String.isNotBlank(instance.streetOne)
                ? instance.streetOne.trim()
                : instance.streetOne;
            instance.city = String.isNotBlank(instance.city)
                ? instance.city.trim()
                : instance.city;
            instance.state = String.isNotBlank(instance.state)
                ? instance.state.trim()
                : instance.state;
        }
    }

    public class PatientInfoWrapper {
        @AuraEnabled 
        public AddressWrapper complainantAddressData;
        @AuraEnabled 
        public String firstName{get;set;}
        @AuraEnabled 
        public String middleName;
        @AuraEnabled 
        public String lastName;
        @AuraEnabled 
        public String email;
        @AuraEnabled 
        public String telephone;
        @AuraEnabled 
        public String ssn;
        @AuraEnabled 
        public Date dob;
    }
    
    public class BoardSpecificQuestions {
        @AuraEnabled 
        public String docEvidence{get;set;}
        @AuraEnabled 
        public String prescriptionLabelEvidence{get;set;}
        @AuraEnabled 
        public List<String> complaintPractice{get;set;}
        @AuraEnabled 
        public List<String> complaintNature{get;set;}
        @AuraEnabled 
        public String outstandingBill{get;set;}
        @AuraEnabled 
        public Decimal outstandingBillAmount{get;set;}
        @AuraEnabled 
        public String treatmentByDiffOpto{get;set;}
        @AuraEnabled 
        public String optoSimiliarPatients{get;set;}
        @AuraEnabled 
        public String treatedByDifferentDentist{get;set;}
    }

    public class ComplaintsWrapper {
        @AuraEnabled
        public Boolean isCompliantSectionEditable;
        @AuraEnabled
        public List<RespondentWrapperNew> respondentData{get;set;}
        @AuraEnabled
        public List<RespondentWrapper> witnessData{get;set;}
        @AuraEnabled
        public List<RespondentWrapper> entitiesData{get;set;}
        @AuraEnabled
        public List<RespondentWrapper> employerData{get;set;}
        @AuraEnabled
        public List<RespondentWrapper> incidentList;
        @AuraEnabled
        public String complaintDesc{get;set;}
        @AuraEnabled 
        public Boolean isPatient;
        @AuraEnabled
        public String firstName;
        @AuraEnabled
        public String middleName;
        @AuraEnabled
        public String lastName;
        @AuraEnabled
        public String telephone;
        @AuraEnabled
        public String telephoneHome;
        @AuraEnabled 
        public String cellPhone;
        @AuraEnabled
        public String email;
        @AuraEnabled
        public Date dob;
        @AuraEnabled
        public String ssn;
        @AuraEnabled
        public AddressWrapper complainantAddressData;
        @AuraEnabled
        public String licensedUnlicensed;
        @AuraEnabled
        public Date incidentDate{get;set;}
        @AuraEnabled
        public List<FileWrapper> filesList;
        @AuraEnabled
        public String complaintName{get;set;}
        @AuraEnabled
        public Boolean isCaptchaInvalid;
        @AuraEnabled
        public Boolean isV3Failed;
        @AuraEnabled
        public String recaptchaResponse;
        @AuraEnabled
        public String ctype;
        @AuraEnabled
        public String profession;
        @AuraEnabled
        public List<AttorneyWrapper> attorneyInfo{get;set;}
        @AuraEnabled 
        public PatientInfoWrapper patientInfo{get;set;}
        @AuraEnabled 
        public BoardSpecificQuestions boardSpecficQues{get;set;}
        @AuraEnabled
        public String complaintReported;
        @AuraEnabled
        public String contactedAttorney{get;set;}
        @AuraEnabled
        public String lawSuitFiled{get;set;}
        @AuraEnabled
        public Date incidentStartDate{get;set;}
        @AuraEnabled
        public Date incidentEndDate{get;set;}
        @AuraEnabled
        public Boolean hipaaConsent;
        @AuraEnabled
        public String contactedIndividualAboutComplaint{get;set;}
        @AuraEnabled
        public String contactedIndividualAboutCompDate{get;set;}
        
        @AuraEnabled
        public String testifyHearing{get;set;}
        @AuraEnabled
        public String socialOrProfessionalRelation{get;set;}
        @AuraEnabled
        public String explainSocProfRelation{get;set;}
        @AuraEnabled
        public String isValueSelected;
        @AuraEnabled
        public Date coverageStartDate;
        @AuraEnabled
        public Date coverageEndDate;
        @AuraEnabled
        public String coverageOption;
        @AuraEnabled
        public Date authExpirationDate;
        @AuraEnabled
        public Boolean isSupportStaff;
        @AuraEnabled
        public String draftComplaintId;
        @AuraEnabled
        public String complaintToOtherAgency;
        @AuraEnabled
        public String relationshipToRespondent;
        @AuraEnabled
        public String relationshipDetails;
        @AuraEnabled
        public String releaseAuthorization;
        @AuraEnabled 
        public Boolean unknownProfession;
        @AuraEnabled
        public String selectedBoardName{get;set;}
        @AuraEnabled 
        public String complainantSignature;
        @AuraEnabled
        public String incidentDateString;
        @AuraEnabled
        public String coverageStartDateString;
        @AuraEnabled
        public String authExpirationDateString;
        @AuraEnabled
        public String coverageEndDateString;
        @AuraEnabled
        public String caseNumber{get;set;}
        @AuraEnabled
        public String complainantName{get;set;}
        @AuraEnabled
        public String uniqueId;
        @AuraEnabled
        public Boolean isBoardSpecific{get;set;}
        @AuraEnabled 
        public Date reportedDate{get;set;}
        @AuraEnabled 
        public String lawsuitcasenumber{get;set;}
        @AuraEnabled 
        public String lawsuitJury{get;set;}
        @AuraEnabled 
        public String uniqueKeyToDraftComp;

        public ComplaintsWrapper processJSONString(String jsonString) {
            ComplaintsWrapper instance = (ComplaintsWrapper) JSON.deserialize(
                jsonString,
                ComplaintsWrapper.class
            );
            List<RespondentWrapper> tmpList = new List<RespondentWrapper>();
            if (instance.complainantAddressData != null) {
                instance.complainantAddressData = instance.complainantAddressData.processJSONString(
                    JSON.serialize(instance.complainantAddressData)
                );
            }
            if (instance.attorneyInfo != null) {
                List<AttorneyWrapper> attorneyWrapperListTmp = new List<AttorneyWrapper>();
                for (AttorneyWrapper rec : instance.attorneyInfo) {
                    attorneyWrapperListTmp.add(rec.processJSONString(JSON.serialize(rec)));
                }
                instance.attorneyInfo = attorneyWrapperListTmp;
            }
            if (instance.incidentList != null) {
                tmpList = new List<RespondentWrapper>();
                for (RespondentWrapper rec : instance.incidentList) {
                    tmpList.add(rec.processJSONString(JSON.serialize(rec)));
                }
                instance.incidentList = tmpList;
            }
            if (instance.entitiesData != null) {
                tmpList = new List<RespondentWrapper>();
                for (RespondentWrapper rec : instance.entitiesData) {
                    tmpList.add(rec.processJSONString(JSON.serialize(rec)));
                }
                instance.entitiesData = tmpList;
            }
            if (instance.employerData != null) {
                tmpList = new List<RespondentWrapper>();
                for (RespondentWrapper rec : instance.employerData) {
                    tmpList.add(rec.processJSONString(JSON.serialize(rec)));
                }
                instance.employerData = tmpList;
            }
            if (instance.witnessData != null) {
                tmpList = new List<RespondentWrapper>();
                for (RespondentWrapper rec : instance.witnessData) {
                    tmpList.add(rec.processJSONString(JSON.serialize(rec)));
                }
                instance.witnessData = tmpList;
            }
            if (instance.respondentData != null) {
                List<RespondentWrapperNew> respList = new List<RespondentWrapperNew>();
                for (RespondentWrapperNew rec : instance.respondentData) {
                    respList.add(rec.processJSONString(JSON.serialize(rec)));
                }
                instance.respondentData = respList;
            }
            removeTrailingSpaces(instance);

            return instance;
        }

        public void removeTrailingSpaces(ComplaintsWrapper instance) {
            instance.firstName = String.isNotBlank(instance.firstName)
                ? instance.firstName.trim()
                : instance.firstName;
            instance.lastName = String.isNotBlank(instance.lastName)
                ? instance.lastName.trim()
                : instance.lastName;
            instance.middleName = String.isNotBlank(instance.middleName)
                ? instance.middleName.trim()
                : instance.middleName;
            instance.email = String.isNotBlank(instance.email)
                ? instance.email.trim()
                : instance.email;
            instance.telephone = String.isNotBlank(instance.telephone)
                ? instance.telephone.trim()
                : instance.telephone;
        }
    }

    public class FileWrapper {
        @AuraEnabled
        public String fileName;
        @AuraEnabled
        public String fileType;
        @AuraEnabled
        public String base64;
        @AuraEnabled
        public string fileUrl;
        @AuraEnabled
        public string licenseName;
        @AuraEnabled
        public string fileId;
        @AuraEnabled
        public string linkedEntityId;
        @AuraEnabled
        public string deleteAllFiles;
        @AuraEnabled
        public string contentDocumentId;
        @AuraEnabled
        public string thumbnailFileCard;
        @AuraEnabled
        public string uniqueId;
        @AuraEnabled
        public string parentRecId;
        @AuraEnabled
        public Boolean showDelete;
    }

    public class AttorneyWrapper {
        @AuraEnabled
        public AddressWrapper addressData;
        @AuraEnabled
        public String firstName{get;set;}
        @AuraEnabled
        public String middleName;
        @AuraEnabled
        public String lastName;
        @AuraEnabled
        public String attorneyPhone;
        @AuraEnabled
        public String attorneyEmail;
        @AuraEnabled 
        public String comments;

        public AttorneyWrapper processJSONString(String jsonString) {
            AttorneyWrapper instance = (AttorneyWrapper) JSON.deserialize(
                jsonString,
                AttorneyWrapper.class
            );
            if (instance.addressData != null) {
                instance.addressData = instance.addressData.processJSONString(
                    JSON.serialize(instance.addressData)
                );
            }

            removeTrailingSpaces(instance);

            return instance;
        }

        private void removeTrailingSpaces(AttorneyWrapper instance) {
            instance.firstName = String.isNotBlank(instance.firstName)
                ? instance.firstName.trim()
                : instance.firstName;
            instance.lastName = String.isNotBlank(instance.lastName)
                ? instance.lastName.trim()
                : instance.lastName;
            instance.middleName = String.isNotBlank(instance.middleName)
                ? instance.middleName.trim()
                : instance.middleName;
            instance.attorneyEmail = String.isNotBlank(instance.attorneyEmail)
                ? instance.attorneyEmail.trim()
                : instance.attorneyEmail;
            instance.attorneyPhone = String.isNotBlank(instance.attorneyPhone)
                ? instance.attorneyPhone.trim()
                : instance.attorneyPhone;
        }
    }

    public class OptionWrapper {
        @AuraEnabled
        public String label;
        @AuraEnabled
        public String value;
        @AuraEnabled
        public String uniqueKey;
    }

    public class ProfessionOptionWrapper {
        @AuraEnabled
        public String label;
        @AuraEnabled
        public String value;
        @AuraEnabled
        public String uniqueKey;
        @AuraEnabled
        public String authType;
        @AuraEnabled
        public String boardName;
        @AuraEnabled 
        public Boolean hipaaSectionValid;
        @AuraEnabled
        public Boolean showBoardSpecificQuestions;
    }

    public class LicenseSearchDownloadWrapper {
        @AuraEnabled
        public Map<String, List<OptionWrapper>> issuingDepartmentToProfessionMap = new Map<String, List<OptionWrapper>>();
        @AuraEnabled
        public string selectedBoard;
    }

    public class NABPCEActivityWrapper {
        public Date ActivityDate;
        public String UAN;
        public String Title;
        public String Provider;
        public String Format;
        public String TopicDesignator;
        public Decimal CreditUnits;
        public Decimal Live;
        public Decimal Home;
        public String ActivityType;
    }

    public class NursysEdisciplineRequestWrapper {
        public string jurisdiction;
        public LicenseTypeSpeciality licenseType = new LicenseTypeSpeciality();
        public string licenseNumber;
    }

    public class LicenseTypeSpeciality {
        public string code;
        public string speciality;
    }

    public class NursysEdisciplineResponse {
        public DisciplineLookupResponseClass disciplineLookupResponse;
    }

    public class DisciplineLookupResponseClass {
        public List<DisciplineLookupLicenseResponsesClass> disciplineLookupLicenseResponses;
    }

    public class DisciplineLookupLicenseResponsesClass {
        public string disciplineIndicator;
        public List<DisciplineLookupLicensesClass> disciplineLookupLicenses;
    }

    public class DisciplineLookupLicensesClass {
        public string licenseNumber;
        public string licenseType;
        public string jurisdiction;
        public string compactStatus;
        public string disciplineIndicator;
        public string isActive;
        public string nclexId;
        public List<DisciplineLookupLicenseStatusAlertMessagesClass> DisciplineLookupLicenseStatusAlertMessages;
    }

    public class DisciplineLookupLicenseStatusAlertMessagesClass{
        public string message;
        public string name;
    }

    public class OnbaseWrapper {
        @AuraEnabled
        public String authHeader;
    }
    public class OnbaseParentWrapper {
        public List<OnbaseDisplayColumnsWrapper> items;
        public String keywordGuid;
    }
    public class OnbaseDisplayColumnsWrapper {
        public List<OnbaseDisplayColumnsValuesWrapper> displayColumns;
        public string id;
    }
    public class OnbaseDisplayColumnsValuesWrapper {
        public string index;
        public List<string> values;
    }

    public class IncidentWrapper {
        @AuraEnabled
        public Id incidentId;
        @AuraEnabled
        public date beginDate{get;set;}
        @AuraEnabled
        public date endDate;
        @AuraEnabled
        public String affectedPerson;
        @AuraEnabled
        public date affectedPersonDob;
        @AuraEnabled
        public Decimal moneyPaid;
        @AuraEnabled
        public String injurySeverity;
        @AuraEnabled
        public String locationCategory;
        @AuraEnabled
        public String publicComplaintId;
        @AuraEnabled
        public String locationId{get;set;}
        @AuraEnabled
        public String addressId;
        @AuraEnabled
        public String searchKey;
        @AuraEnabled
        public String urgency;
        @AuraEnabled
        public String impact;
        @AuraEnabled
        public String priority;
        @AuraEnabled
        public String subject;
        @AuraEnabled
        public String startDateString;
        @AuraEnabled
        public String endDateString;
        @AuraEnabled
        public String addressInfo;
    }

    public class AccountWrapper {
        @AuraEnabled
        public String firstName;
        @AuraEnabled
        public String lastName;
        @AuraEnabled
        public String middleName;
        @AuraEnabled
        public String name;
        @AuraEnabled
        public String ssn;
        @AuraEnabled
        public String fein;
        @AuraEnabled
        public String dba;
        @AuraEnabled
        public List<AddressWrapper> addressRecords;
        @AuraEnabled
        public string licenseNumber;
        @AuraEnabled
        public string profession;
    }

    public class CaseParticipantWrapper {
        @AuraEnabled
        public String id;
        @AuraEnabled
        public String participantId;
        @AuraEnabled
        public String participantName;
        @AuraEnabled
        public String status;
        @AuraEnabled
        public String role;
        @AuraEnabled
        public String caseId;
        @AuraEnabled
        public String accFirstName;
        @AuraEnabled
        public String accLastName;
        @AuraEnabled
        public String accMiddleName;
        @AuraEnabled
        public String accEmail;
        @AuraEnabled
        public String accTelephne;
        @AuraEnabled
        public String accCellphone;
        @AuraEnabled
        public String accStreet;
        @AuraEnabled
        public String accCity;
        @AuraEnabled
        public String accState;
        @AuraEnabled
        public String accZipCode;
    }

    public class TaskWrapper {
        @AuraEnabled
        public List<LPI_NewVisitRecord.SelectOptionWrapper> actionOptions = new List<LPI_NewVisitRecord.SelectOptionWrapper>();
        @AuraEnabled
        public List<LPI_NewVisitRecord.SelectOptionWrapper> activityStatusOptions = new List<LPI_NewVisitRecord.SelectOptionWrapper>();
        @AuraEnabled
        public List<LPI_NewVisitRecord.SelectOptionWrapper> relatedToOptions = new List<LPI_NewVisitRecord.SelectOptionWrapper>();
        @AuraEnabled 
        public String relatedTo;
        @AuraEnabled 
        public String relatedToName;
        @AuraEnabled 
        public String relatedToRespName;
        @AuraEnabled 
        public String relatedToCompName;
        @AuraEnabled 
        public String boardName;
        @AuraEnabled
        public string action;
        @AuraEnabled
        public string activityStatus;
        @AuraEnabled
        public string assignedUserId;
        @AuraEnabled
        public string comments;
        @AuraEnabled
        public Date dueDate;
        @AuraEnabled
        public DateTime completedDate;
        @AuraEnabled
        public string taskId;
        @AuraEnabled
        public string caseId;
        @AuraEnabled
        public string subject;
    }
    public class SaveApiRequestWrapper {
        @AuraEnabled
        public string clientSftwrVer;
        @AuraEnabled
        public string alienNumber;
        @AuraEnabled
        public string i94Number;
        @AuraEnabled
        public string sevisId;
        @AuraEnabled
        public string passportNumber;
        @AuraEnabled
        public string countryOfIssuance;
        @AuraEnabled
        public string visaNumber;
        @AuraEnabled
        public string receiptNumber;
        @AuraEnabled
        public string naturalizationNumber;
        @AuraEnabled
        public String documentId;
        @AuraEnabled
        public string docLastName;
        @AuraEnabled
        public string docFirstName;
        @AuraEnabled
        public string docMiddleName;
        @AuraEnabled
        public String docBirthDate;
        @AuraEnabled
        public string docOtherDesc;
        @AuraEnabled
        public string docExpDate;
        @AuraEnabled
        public string requestSponsorDataInd;
        @AuraEnabled
        public string requestEmpAuthDataInd;
        @AuraEnabled
        public string requestGrantDateInd;
        @AuraEnabled
        public string suspectedCounterfeitAlteredDocumentIndicator;
        @AuraEnabled
        public string casePocPhoneNbr;
        @AuraEnabled
        public string casePocPhoneNbrExt;
        @AuraEnabled
        public string casePOC;
        @AuraEnabled
        public string uploadedDocInd;
        @AuraEnabled
        public string uploadedDoc;
        @AuraEnabled
        public List<BenfitWrapper> benefitCodes;
        @AuraEnabled
        public string citizenshipNumber;
        public SaveApiRequestWrapper() {
            clientSftwrVer = '';
            alienNumber = '';
            i94Number = '';
            sevisId = '';
            passportNumber = '';
            countryOfIssuance = '';
            visaNumber = '';
            receiptNumber = '';
            naturalizationNumber = '';
            documentId = '';
            docLastName = '';
            docFirstName = '';
            docMiddleName = '';
            docBirthDate = '';
            docOtherDesc = '';
            docExpDate = '';
            requestSponsorDataInd = '';
            requestEmpAuthDataInd = '';
            requestGrantDateInd = '';
            suspectedCounterfeitAlteredDocumentIndicator = '';
            casePocPhoneNbr = '';
            casePocPhoneNbrExt = '';
            casePOC = '';
            requestSponsorDataInd = 'N';
            requestEmpAuthDataInd = 'Y';
            requestGrantDateInd = 'Y';
            uploadedDocInd = 'N';
            benefitCodes = new List<BenfitWrapper>();
        }
    }
    public class SaveApiResponseWrapper {
        @AuraEnabled
        public agency3InitVerifResponseWrapper agency3InitVerifResponse;
    }
    public class Agency3InitVerifResponseWrapper {
        @AuraEnabled
        public agency3InitVerifResultWrapper agency3InitVerifResult;
    }
    public class Agency3InitVerifResultWrapper {
        @AuraEnabled
        public string caseNbr;
        @AuraEnabled
        public string nonCitLastName;
        @AuraEnabled
        public string nonCitFirstName;
        @AuraEnabled
        public string nonCitMiddleName;
        @AuraEnabled
        public String nonCitBirthDate;
        @AuraEnabled
        public String nonCitEntryDate;
        @AuraEnabled
        public String admittedToDate;
        @AuraEnabled
        public string admittedToText;
        @AuraEnabled
        public string nonCitCountryBirthCd;
        @AuraEnabled
        public string nonCitCountryCitCd;
        @AuraEnabled
        public string nonCitCoaCode;
        @AuraEnabled
        public string nonCitProvOfLaw;
        @AuraEnabled
        public String nonCitEadsExpireDate;
        @AuraEnabled
        public string eligStatementCd;
        @AuraEnabled
        public string eligStatementTxt;
        @AuraEnabled
        public string iAVTypeCode;
        @AuraEnabled
        public string iAVTypeText;
        @AuraEnabled
        public string grantDate;
        @AuraEnabled
        public string grantDateReasonCd;
        @AuraEnabled
        public string sponsorDataFoundInd;
        @AuraEnabled
        public string sponsorshipReasonCd;
        @AuraEnabled
        public string noEmpAuthDataInd;
        @AuraEnabled
        public string photoIncludedInd;
        @AuraEnabled
        public string caseSentToSecondary;
        @AuraEnabled
        public string photo;
        @AuraEnabled
        public string webServSftwrVer;
        @AuraEnabled
        public string returnStatus;
        @AuraEnabled
        public string returnStatusMsg;
    }

    public class AWSEmailWrapper {
        public String ConfigurationSetName;
        public List<AWSEmailRecipient> Destinations;
    }

    public class AWSEmailRecipient {
        public AWSEmailDestination Destination;
        public String ReplacementTemplateData;
        public String Template;
        public String Source;
    }

    public class AWSEmailDestination {
        public List<String> ToAddresses;
        public List<String> CcAddresses;
    }

    public class NotificationEmailWrapper {
        public String accountId;
        public String senderEmail;
        public String recipientEmail;
        public String templateName;
        public Map<String, String> replaceTextMap;
        public string attachmentRequired;
        public string pdfAttachmentName;
        public string ccAddresses;
        public string iaId;
        public string blaId;
        public string blId;
        public String caseId;
        public String complaintId;
        public String visitId;
        public String description;
        public String subject;
        public string taskId;
        public string recordType;
        public NotificationEmailWrapper() {
        }
        public NotificationEmailWrapper(
            String accountId,
            String senderEmail,
            String recipientEmail,
            String templateName,
            Map<String, String> replaceTextMap,
            string attachmentRequired,
            string pdfAttachmentName,
            String ccAddresses,
            String description,
            String subject
        ) {
            this.accountId = accountId;
            this.senderEmail = senderEmail;
            this.recipientEmail = recipientEmail;
            this.templateName = templateName;
            this.replaceTextMap = replaceTextMap;
            this.attachmentRequired = attachmentRequired;
            this.pdfAttachmentName = pdfAttachmentName;
            this.ccAddresses = ccAddresses;
            this.description = description;
            this.subject = subject;
        }
        public NotificationEmailWrapper(
            String accountId,
            String senderEmail,
            String recipientEmail,
            String templateName,
            Map<String, String> replaceTextMap,
            String ccAddresses
        ) {
            this.accountId = accountId;
            this.senderEmail = senderEmail;
            this.recipientEmail = recipientEmail;
            this.templateName = templateName;
            this.replaceTextMap = replaceTextMap;
            this.ccAddresses = ccAddresses;
            this.caseId = caseId;
        }
    }

    public class BenfitWrapper {
        public String intValue;
    }

    public class PersonEducationMetaDataWrapper {
        public String amendmentType;
        public String parId;
        public String contactId;
        public Boolean isLegacy;
        public Date reportDate;
        public Integer monthsToAdd;
        public String degreeName;
        public PersonEducationMetaDataWrapper() {
        }
        public PersonEducationMetaDataWrapper(
            String amendmentType,
            String parId,
            String contactId,
            Date reportDate,
            Boolean isLegacy,
            Integer monthsToAdd
        ) {
            this.amendmentType = amendmentType;
            this.parId = parId;
            this.contactId = contactId;
            this.reportDate = reportDate;
            this.isLegacy = isLegacy;
            this.monthsToAdd = monthsToAdd;
        }
        public PersonEducationMetaDataWrapper(
            String amendmentType,
            String parId,
            String contactId,
            Date reportDate,
            Boolean isLegacy,
            Integer monthsToAdd,
            String degreeName
        ) {
            this.amendmentType = amendmentType;
            this.parId = parId;
            this.contactId = contactId;
            this.reportDate = reportDate;
            this.isLegacy = isLegacy;
            this.monthsToAdd = monthsToAdd;
            this.degreeName = degreeName;
        }
    }
    public class ApplicationWrapperWithDueDiligence {
        public String dueDiligenceName;
        public String dueDiligenceComment;
        public ApplicationWrapperWithDueDiligence() {
        }
        public ApplicationWrapperWithDueDiligence(
            String dueDiligenceName,
            String dueDiligenceComment
        ) {
            this.dueDiligenceName = dueDiligenceName;
            this.dueDiligenceComment = dueDiligenceComment;
        }
    }

    public class AssessmentTaskWrapper{
        @AuraEnabled public string questionName;
        @AuraEnabled public string comment;
        @AuraEnabled public string questionId;
        @AuraEnabled public List<FileWrapper> filesList = new List<FileWrapper>();
        @AuraEnabled public List<OptionWrapper> options;
        @AuraEnabled public string value;
        @AuraEnabled public string assessmentTaskId;
        @AuraEnabled public Boolean isViolationDone;
        @AuraEnabled public Boolean doesNotaccountForViolation;
        @AuraEnabled public string visitId;
        @AuraEnabled public string responseContextId;
        @AuraEnabled public string dataType;
        @AuraEnabled public Datetime dateTimeValue;
        @AuraEnabled public Integer numberResponseValue;
        @AuraEnabled public string parentQuesId;
        @AuraEnabled public String multiPicklistValue;
        @AuraEnabled public String optionLabel;
        @AuraEnabled public Boolean readOnly;
        @AuraEnabled public String numberValue;
        @AuraEnabled public String onbasePayload;
        @AuraEnabled public String documentDate;
        @AuraEnabled public String boardName;
        @AuraEnabled public String twoByTwoPhotoRecommendation;
        @AuraEnabled public string inspectionDate;
        @AuraEnabled public string complaintNumber;
        @AuraEnabled public string entityName;
        @AuraEnabled public string firstName;
        @AuraEnabled public string middleName;
        @AuraEnabled public string lastName;
        @AuraEnabled public string suffixName;
        @AuraEnabled public string profCode;
        @AuraEnabled public string ssn;
        @AuraEnabled public string scanDate;
        @AuraEnabled public string licenseNumber;
        @AuraEnabled public string description;
        @AuraEnabled public Boolean hideComment;
        @AuraEnabled public string accountName;
        @AuraEnabled public string programType;
        @AuraEnabled public string providerCode;
        @AuraEnabled public Boolean hideComments;
    }
    
    public class ViolationEnforcementActionWrapper{
        @AuraEnabled public string type;
        @AuraEnabled public string frequency;
        @AuraEnabled public string endDate;
        @AuraEnabled public string startDate;
        @AuraEnabled public string id;
    }
    
    public class RoutineSiteInspectionWrapper {
        @AuraEnabled 
        public String licenseUrl;
        @AuraEnabled 
        public Boolean routineApplicationSubmitted;
        @AuraEnabled 
        public String ContextId;
        @AuraEnabled 
        public String programName;
        @AuraEnabled 
        public String schoolName; 
        @AuraEnabled 
        public String licenseNumber;
        @AuraEnabled 
        public Date issuanceDate;
        @AuraEnabled 
        public Date createdDate;
        @AuraEnabled 
        public Date expiryDate;
    }
}