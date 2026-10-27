/**
 * @description       : Controller class to get Violation Data From Inspection Records to populate on PDF via vfPage
 * @author            : MTX Group Product Team
 * @group             : 
 * @last modified on  : 07-26-2024
 * @last modified by  : MTX Group Product Team
**/
public with sharing class LPI_ViolationLetterController {
    public List<ViolationWrapper> violationsList {get;set;}
    public AccPlaceDetailWrapper AccPlaceDetails {get;set;}
    public Id RecordId {get;set;}

    /**
    * @description       : Method used to get Visit and its Related Data to show on PDF
    * @author            : MTX Group Product Team
    * @group             : 
    * @last modified on  : 07-26-2024
    * @last modified by  : MTX Group Product Team
    **/
    public LPI_ViolationLetterController(ApexPages.StandardController controller){  
        RecordId  = ApexPages.currentPage().getParameters().get('recordId');
        
        //Using query to fetch Visit and InspectionAssmntInd records
        List<Visit> accPlaceDetailsList = LPI_VisitControllerDAO.getVisitListByDynamicQueryWithoutSecurity(new List<String>{'Id,Actual_End_Date__c,Business_Name__c,AccountId,Account.Name,License_Type__c,PlaceId,Account.BillingStreet,Account.BillingCity,Account.BillingCountry,Account.BillingCountryCode,Account.BillingPostalCode,Account.BillingState,Board_Name__c,Comments__c,'
            +'( SELECT ID, RegulatoryCode.Name, Supervisor_Board_Staff_Comments__c, RegulatoryCode.Regulatory_Code_Description__c, InspectionAssmntInd.Comments__c, InspectionAssmntInd.DisplayOrder From RegCodeInspection Where Include_In_Violation_Letter__c = true AND RegulatoryCodeId != null order by InspectionAssmntInd.DisplayOrder Asc)'},                                                                                                 
            +'Id =\''+ recordId+  '\'',1,null,null);
        
        if(accPlaceDetailsList.isEmpty()){
            return; 
        }
        
        Integer displayOrder = 1;
        violationsList = new List<ViolationWrapper>();

        //Storing Violation Details in ViolationWrapper
        for(RegulatoryCodeViolation rcv : accPlaceDetailsList[0].RegCodeInspection) {
            ViolationWrapper viWrapper = new ViolationWrapper();
            viWrapper.violationRule = rcv.RegulatoryCode.Name;
            viWrapper.violationDesc = rcv.RegulatoryCode.Regulatory_Code_Description__c;
            viWrapper.assessmentIndiComm = rcv.InspectionAssmntInd.Comments__c;
            viWrapper.displayOrder = displayOrder;
            viWrapper.boardStaffInspectorSupComments = rcv.Supervisor_Board_Staff_Comments__c;
            violationsList.add(viWrapper);
            displayOrder++;
        }
        
        //Storing Account and its address in AccPlaceDetailWrapper
        AccPlaceDetailWrapper accPlaceWrapper = new AccPlaceDetailWrapper();
        accPlaceWrapper.accountName = accPlaceDetailsList[0].Business_Name__c;
        accPlaceWrapper.profession = accPlaceDetailsList[0].License_Type__c?.toUpperCase();
        accPlaceWrapper.street = accPlaceDetailsList[0].Account?.BillingStreet;
        accPlaceWrapper.city = accPlaceDetailsList[0].Account?.BillingCity;
        accPlaceWrapper.country = accPlaceDetailsList[0].Account?.BillingCountry;
        accPlaceWrapper.countryCode = accPlaceDetailsList[0].Account?.BillingCountryCode;
        accPlaceWrapper.postalCode = accPlaceDetailsList[0].Account?.BillingPostalCode;
        accPlaceWrapper.businessState = accPlaceDetailsList[0].Account?.BillingState;
        if(accPlaceDetailsList[0].Actual_End_Date__c != null){
            Date dt = accPlaceDetailsList[0].Actual_End_Date__c;
            integer year = dt.year();
            integer month = dt.month();
            integer day = dt.day();
            accPlaceWrapper.inspectionComDate = String.valueOf(Year) + '-' + String.valueOf(month).leftPad(2, '0')+'-'+String.valueOf(day).leftPad(2, '0');
        }else{
            accPlaceWrapper.inspectionComDate = '';
        }
        accPlaceWrapper.boardName = accPlaceDetailsList[0].Board_Name__c;
        accPlaceWrapper.comments = accPlaceDetailsList[0].Comments__c;
        
        //Using query to fetch RegulatoryAuthority details
        List<RegulatoryAuthority> boardDetails = LPI_RegulatoryAuthorityDAO.getRegulatoryAuthorityByDymanicQuery('id,Email_Specifications__c','Name Like \''+accPlaceDetailsList[0].Board_Name__c+'\'',null,null,null);
        
        if(!boardDetails.isEmpty()){
            String jsonStr = boardDetails[0].Email_Specifications__c;
			BoardDetails boardInfo = (BoardDetails) JSON.deserializeStrict(jsonStr, BoardDetails.class);
        	accPlaceWrapper.boardPOBox = boardInfo.boardPoBox;
        	accPlaceWrapper.boardEmailId = boardInfo.boardEmail;
        }
        AccPlaceDetails = accPlaceWrapper;
    }
    
    //Wrapper for Regulatory Code Violation Details
    public class ViolationWrapper{
        public string violationRule {get;set;}
        public string violationDesc {get;set;}
        public string assessmentIndiComm {get;set;}
        public Integer displayOrder {get;set;}
        public Integer count {get;set;}
        public String boardStaffInspectorSupComments {get;set;}
    }
    
    //Wrapper for Account and Account's Address Details
    public class AccPlaceDetailWrapper{
        public string accountName {get;set;}
        public string street {get;set;}
        public string city {get;set;}
        public string country {get;set;}
        public string countryCode {get;set;}
        public string postalCode {get;set;}
        public string businessState {get;set;}
        public String inspectionComDate {get;set;}
        public string boardName {get;set;}
        public string boardPOBox {get;set;}
        public string boardEmailId {get;set;}
        public string profession {get;set;}
        public string comments{get;set;}
    }
    
    //Wrapper for Board Details from RegulatoryAuthority
    public class BoardDetails {
        public String boardEmail;
        public String boardPoBox;
        public String boardName;
    }
    
}