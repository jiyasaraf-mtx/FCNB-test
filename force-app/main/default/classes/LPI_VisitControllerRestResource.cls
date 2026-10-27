/**
 * @author : Anmol Mathur
 * @since : 23rd Nov 2022
 * @description : This apex class Captures Request from Mobile and returns required data.
 */

 @RestResource(urlMapping='/UserVisits/*')
 global with sharing class LPI_VisitControllerRestResource {
 
 
     /**
      * @author                   Anmol Mathur
      * @description              This is the POST Method of the class which will update the Visit's details.
      * @return                   `void`
      */
   @HTTPPost
   global static void submitUserVisits() {
 
     RestRequest req = RestContext.request;
     RestResponse res = RestContext.response;
     APIResponse objResponse = new APIResponse();
     objResponse.response = new List<Object>();
 
     VisitPOSTRequest ehelper;
     String jsonStr;
 
     try {
         
         if (req.requestBody != null) {
             jsonStr = req.requestBody.toString();
         }
         ehelper = (VisitPOSTRequest) System.JSON.deserialize(jsonStr, VisitPOSTRequest.class);
        
         if(ehelper != null) {
             // Check if the user is requesting for it's own records
             if (String.isNotBlank(ehelper.userId) && ehelper.userId != UserInfo.getUserId()) {
                 throw new UnAuthorizedUserException();
             }
 
             Set<Id> visitIds = new Set<Id>();
             Map<Id, UserVisits> userVisitMap = new Map<Id, UserVisits>();
             Set<Inspection_Content__c> inspectionContent = new Set<Inspection_Content__c>(); // Use to hold Inspection Licence data added on form at time of inspection
             for (UserVisits obj : ehelper.visits) {
                 if (obj.id != null) {
                     visitIds.add(obj.id);
                     userVisitMap.put(obj.id, obj);
                 }
             }
             if (!visitIds.isEmpty()) {
                 Visit[] allVisits = [SELECT Id, ActualVisitEndTime, ActualVisitStartTime, Status__c, StatusRemarks, Comments__c FROM Visit WHERE Id IN :visitIds AND visitorId = :ehelper.userId];
                 Visit[] notMyVisits = [SELECT Id FROM Visit WHERE Id IN :visitIds AND visitorId != :ehelper.userId];
 
                 
                 for (Visit objVisit : allVisits) {
                     UserVisits objUserVisit = userVisitMap.get(objVisit.Id);
                     if (objUserVisit != null) {
                         //Unable_to_Inspect__c

                         if(objUserVisit.inspectionQuestionsAnswers!=null && String.isNotBlank(objUserVisit.inspectionQuestionsAnswers)){

                            List<Inspection_Content__c> wrapperLines = (List<Inspection_Content__c>)JSON.deserialize(objUserVisit.inspectionQuestionsAnswers, List<
                            Inspection_Content__c>.class);
                            inspectionContent.addAll(wrapperLines);
                            // Inspection_Content__c  inspectionLicence = (Inspection_Content__c) System.JSON.deserialize(objUserVisit.inspectionQuestionsAnswers, Inspection_Content__c.class);
                            // inspectionContent.add(inspectionLicence);

                         } 
                         objVisit.Status__c = objUserVisit.status;
                         objVisit.Comments__c = objUserVisit.statusRemarks;

 
                         if (objUserVisit.unabletoInspect != null) {
                             objVisit.Unable_to_Inspect__c = objUserVisit.unabletoInspect;
                             if(objUserVisit.subReason != null){
                                objVisit.Sub_Reason__c = objUserVisit.subReason;
                             }
                             
                         }

                        //  if (objUserVisit.drugName != null) {
                        //     objVisit.Drug_Name__c = objUserVisit.drugName;
                        //     if (objUserVisit.sequenceNumber != null) {
                        //         objVisit.Sequence_Number__c = double.valueOf(objUserVisit.sequenceNumber);
                        //     }
                        // }
                         if (objUserVisit.finalAssessmentResult != null) {
                             objVisit.Final_Assessment_Result__c = objUserVisit.finalAssessmentResult;
                         }
                         if (objUserVisit.actualVisitStartTime != null && String.isNotBlank(objUserVisit.actualVisitStartTime)) {
                             objVisit.ActualVisitStartTime = Datetime.valueOf(objUserVisit.actualVisitStartTime.replace('T',' '));
                         }  
                         if (objUserVisit.actualVisitEndTime != null && String.isNotBlank(objUserVisit.actualVisitEndTime)) {
                             objVisit.ActualVisitEndTime = Datetime.valueOf(objUserVisit.actualVisitEndTime.replace('T',' '));
                         }   
 
                         if (objUserVisit.licenseeApplicantSignDate != null && String.isNotBlank(objUserVisit.licenseeApplicantSignDate)) {
                             objVisit.Licensee_Applicant_Rep_Signed_Date__c = Date.parse(objUserVisit.licenseeApplicantSignDate);
                         }
                         if (objUserVisit.title != null) {
                             objVisit.Title__c = objUserVisit.title;
                         }
                         if (objUserVisit.attestationbyLicenseeApplicantRep != null) {
                            objVisit.Attestation_by_Licensee_Applicant_Rep__c = objUserVisit.attestationbyLicenseeApplicantRep;
                        }        
                         if (objUserVisit.licenseeApplicantSignName != null) {
                             objVisit.Name_of_Licensee_Applicant_Representativ__c = objUserVisit.licenseeApplicantSignName;
                         }
                         if (objUserVisit.inspectorSignedDate != null && String.isNotBlank(objUserVisit.inspectorSignedDate)) {
                             objVisit.Inspector_Signed_Date__c = Date.parse(objUserVisit.inspectorSignedDate);
                         }
                     }
                 }
                 // TODO: Add transaction rollback

                 //Insert Inspection Content
                 if(inspectionContent!=null && !inspectionContent.isEmpty()) {
                    List<Inspection_Content__c> objList = new List<Inspection_Content__c>(inspectionContent);
                    List<Database.SaveResult> insertResults =   Database.insert(objList);
                    
                 }
                 

                 //Insert The Visit

                 List<Database.SaveResult> updateResults = Database.update(allVisits);
                 objResponse.error = '';
                 objResponse.status = 'Success';
                 for (Database.SaveResult updateResult : updateResults) {
                     objResponse.response.add(new VisitPOSTResponse(updateResult));
                 }
                 for (Visit obj : notMyVisits) {
                     objResponse.response.add(new VisitPOSTResponse(obj.id));
                 }
                 res.responseBody = Blob.valueOf(JSON.serialize(objResponse));
                 res.statusCode = 200;
                 return;
             } else {
                  objResponse.error = 'Cannot Parse the Request';
                  objResponse.status = 'Fail';
                  res.responseBody = Blob.valueOf(JSON.serialize(objResponse));
                  res.statusCode = 400;
             }
         }
 
         objResponse.error = 'No Visits found';
         objResponse.status = 'Fail';
         res.responseBody = Blob.valueOf(JSON.serialize(objResponse));
         res.statusCode = 400;
 
     } catch (UnAuthorizedUserException e){
         res.statusCode = 500;
         res.responseBody = Blob.valueOf('User not authorized to submit other users visit');
     } catch (Exception ex) {
         res.statusCode = 400;
         res.responseBody = Blob.valueOf('Error with the request parameters' + ex.getMessage());
     }
   }
 
     /**
      * @author                   Anmol Mathur
      * @description              This is the GET Method of the class which will return all Visits associated with the userId passed in the parameter
      * @return                   `void`
      */
   @HTTPGet
   global static void getUserVisits() {
 
     RestResponse res = RestContext.response;
     RestRequest req = RestContext.request;
         try {
 
             String userId = req.params.get('userId');
             Boolean isPrevious = false;
             String contextId = '';
             if (req.params.containsKey('isPrevious')) {
                 String previous = req.params.get('isPrevious');
                 isPrevious = Boolean.valueOf(previous);
                 if (req.params.containsKey('contextId')) {
                     contextId = req.params.get('contextId');
                 }
             }
 
             //Check if the user is fetching previous inspection and sending contextId
             if (isPrevious == true && String.isBlank(contextId)) {
                //throw new ContextIdMissingException();
             }
 
             // Check if the user is requesting for it's own records
             if (String.isNotBlank(userId) && userId != UserInfo.getUserId()) {
                throw new UnAuthorizedUserException();
             }
 			System.debug('---->userId visit rest res' + userId);
             Visit[] allVisits = getAllVisits(userId, isPrevious, contextId);
             if (allVisits.isEmpty()) {
                 if (isPrevious == true) {
                     res.responseBody = Blob.valueOf(JSON.serialize(allVisits));    
                 } else {
                     res.responseBody = Blob.valueOf(JSON.serialize(allVisits));
                 }
                 res.statusCode = 200;
                 return;
             }
           
             // Get the address and VisitType associated with Visit
             Set<Id> addressIDs = new Set<Id>();
             Map<Id, Schema.Address> addressMap = new Map<Id, Schema.Address>();
             
             Set<Id> visitTypeIds = new Set<Id>();
             Map<Id, InspectionType> visitTypeMap = new Map<Id, InspectionType>();
             Map<String, String> visitOnBaseConfig = new Map<String, String>();

             Set<Id> inspectionIDs = new Set<Id>();
             Map<Id, Set<Inspection_Content__c>> inspectionContentMap = new Map<Id, Set<Inspection_Content__c>>();

             Schema.LPI_Onbase_Configuration__mdt[] onBaseConfig = getAllOnBaseConfig();

             if(!onBaseConfig.isEmpty()){
                 for (Schema.LPI_Onbase_Configuration__mdt config : onBaseConfig) {
                     visitOnBaseConfig.put(config.Board_Name__c, config.Payload__c);
                 }
             }
             
             for (Visit visit : allVisits) {
                 inspectionIDs.add(visit.Id);

                 if(visit.placeId != null){
                     addressIDs.add(visit.placeId);
                 }
                 if(visit.visitTypeId != null){
                     visitTypeIds.add(visit.visitTypeId);
                 }
             }

             if(!inspectionIDs.isEmpty()){
                Inspection_Content__c[] allInspectionContent= getAllInspectionContent(inspectionIDs);
                 for (Inspection_Content__c inc : allInspectionContent) {
                    Set<Inspection_Content__c> incSet = inspectionContentMap.containsKey(inc.Inspection__c)?inspectionContentMap.get(inc.Inspection__c): new Set<Inspection_Content__c>();
                    incSet.add(inc);
                    inspectionContentMap.put(inc.Inspection__c,incSet);
                 }
             }
 
             if (!addressIDs.isEmpty()) {
                 Schema.Address[] allAddresses = getAllAddress(addressIDs);
                 for (Schema.Address add : allAddresses) {
                     addressMap.put(add.Id, add);
                 }
             }
 
             if (!visitTypeIds.isEmpty()) {
                 InspectionType[] allVisitTypes = getAllVisitType(visitTypeIds);
                 for (InspectionType vTypes : allVisitTypes) {
                     visitTypeMap.put(vTypes.Id, vTypes);
                 }
             }
             // Bind all together in Wrapper and send response back
             List<VisitResponseWrapper> visitWrap = new List<VisitResponseWrapper>();
             for (Visit objVisit : allVisits) {
                  System.debug('----->' + objVisit.Board_Name__c + ' ---- ' + visitOnBaseConfig + ' ---- ' + visitOnBaseConfig.containsKey(objVisit.Board_Name__c));

                 Schema.Address objAddress = addressMap.get(objVisit.placeId);
                 InspectionType objType = visitTypeMap.get(objVisit.visitTypeId);

                 String onBasePayload = '';
                 if(String.isNotBlank(objVisit.Board_Name__c) && visitOnBaseConfig.containsKey(objVisit.Board_Name__c) ){
                    String profCode = '';
                    String contextName = '';
                    String businessName = objVisit.Business_Name__c != null ? objVisit.Business_Name__c :'';
                    String firstName = '';
                    String middleName = '';
                    String lastName = '';
                    String suffix = '';
                    String ssn = '';
                    String complaintNumber = '';
                    String description = objType != null ? objType.Name: '';
                    if(objVisit.Context != null){
                        if (objVisit.Context instanceof Schema.BusinessLicense) {
                           Schema.BusinessLicense businessL = objVisit.Context;
                           profCode = businessL.RegulatoryAuthorizationType.Profession_Code__c;
                           contextName = businessL.Legacy_License_Number__c != null ? businessL.Legacy_License_Number__c : businessL.Name;
                           if(businessL.Contact != null){
                                firstName = businessL.Contact.FirstName != null ? businessL.Contact.FirstName : '';
                                middleName = businessL.Contact.MiddleName != null ? businessL.Contact.MiddleName : '';
                                lastName = businessL.Contact.LastName != null ? businessL.Contact.lastName : '';
                                suffix = businessL.Contact.Suffix != null ? businessL.Contact.Suffix : '';
                                if(businessL.Contact.Account != null){
                                    ssn = businessL.Contact.Account.Social_Security_Number__c != null ? businessL.Contact.Account.Social_Security_Number__c : '';
                                }
                               
                            }
                          
                        } else if (objVisit.Context instanceof Schema.BusinessLicenseApplication ) {
                            Schema.BusinessLicenseApplication businessLA = objVisit.Context;
                            profCode = businessLA.LicenseType.Profession_Code__c;
                            contextName = businessLA.name;
                           
                            if(businessLA.Applicant != null){
                                firstName = businessLA.Applicant.FirstName != null ? businessLA.Applicant.FirstName : '';
                                middleName = businessLA.Applicant.MiddleName != null ? businessLA.Applicant.MiddleName : '';
                                lastName = businessLA.Applicant.LastName != null ? businessLA.Applicant.lastName : '';
                                suffix = businessLA.Applicant.Suffix != null ? businessLA.Applicant.Suffix : '';
                                if(businessLA.Applicant.Account != null){
                                    ssn = businessLA.Applicant.Account.Social_Security_Number__c != null ? businessLA.Applicant.Account.Social_Security_Number__c : '';
                            
                                }
                            }
                        }
                    }
                     
                    //Trim the string as per length
                    profCode = subStringwithLenght(3,profCode);
                    complaintNumber = subStringwithLenght(10,complaintNumber);
                    businessName = subStringwithLenght(70,businessName);
                    contextName = subStringwithLenght(12,contextName);
                    firstName = subStringwithLenght(40,firstName);
                    middleName = subStringwithLenght(20,middleName);
                    lastName = subStringwithLenght(40,lastName);
                    suffix = subStringwithLenght(10,suffix);
                    ssn = subStringwithLenght(9,ssn);
                    description = subStringwithLenght(40,description);





                     onBasePayload = visitOnBaseConfig.get(objVisit.Board_Name__c).replace('numberValue',objVisit.Name).replace('profCode',profCode)
                     .replace('firstName',firstName).replace('middleName',middleName).replace('lastName',lastName).replace('suffixName',suffix).replace('ssn',ssn)  
                     .replace('licenseNumber',contextName).replace('description',description).replace('entityName',businessName).replace('complaintNumber',complaintNumber);
                 }

                 String inspectionQuestionsAnswersJson = '';
                 if(inspectionContentMap.containsKey(objVisit.Id)){
                    inspectionQuestionsAnswersJson = JSON.serialize(inspectionContentMap.get(objVisit.Id));
                 }
                 
                 visitWrap.add(new VisitResponseWrapper(objVisit, objAddress, objType, isPrevious,onBasePayload, inspectionQuestionsAnswersJson));
             }
 
             res.responseBody = Blob.valueOf(JSON.serialize(visitWrap));
             res.statusCode = 200;
 
         } catch (System.StringException e){
             res.statusCode = 400;
             res.responseBody = Blob.valueOf(e.getMessage());
         } catch (UnAuthorizedUserException e){
             res.statusCode = 500;
             res.responseBody = Blob.valueOf('User not authorized to access other users visit');
         } catch (ContextIdMissingException e){
             res.statusCode = 400;
             res.responseBody = Blob.valueOf('Context ID(contextId) is required parameter to fetch previous inspections');
         } catch (System.QueryException e){
             res.statusCode = 404;
             res.responseBody = Blob.valueOf('Requested User not found');
         } catch (Exception e){ //something else happened
             res.statusCode = 500;
             res.responseBody = Blob.valueOf(e.getMessage());
         }
   }



   /**
   * @author                   Lokendra Jhala
   * @description              This method will return trimed string as per length
   * @return                   `String`
   */
  public static String subStringwithLenght(Integer length, String str) {   
   
        if( str.length()>length && str.contains('-')){
            str = str.substringAfter('-');
        }    

        if(str.length()>length){
            
            str= str.substring(0,length);
        }

        return str;   
      
    }




    /**
     * @author                   Lokendra Jhala
     * @description              This method will return Address[] which are associated with the Visits
     * @return                   `LPI_Onbase_Configuration__mdt[]`
     */
    public static Schema.LPI_Onbase_Configuration__mdt[] getAllOnBaseConfig() {     
        return  
        [
            SELECT id,Board_Name__c, Payload__c 
            FROM LPI_Onbase_Configuration__mdt 
            WHERE Flow_Name__c = 'Inspection'
        ];
      }
 
   /**
      * @author                   Anmol Mathur
      * @description              This method will return Visit[] which are associated with the UserId OR previous visits associated the userId
      * @param :                  String userId
      * @param :                  Boolean isPrevious
      * @return                   `Visit[]`
      */
   private static Visit[] getAllVisits(String userId, Boolean isPrevious, String contextId) {    
     if (isPrevious == true) {
         return getAllPreviousVisits(userId, contextId);
     } else {
         return  
         [
             SELECT Id,Classification__c,Classification_type__c, Description__c, Board_Name__c, Unable_to_Inspect__c, Name_of_Licensee_Applicant_Representativ__c, Title__c,Inspector_Signed_Date__c, Licensee_Applicant_Rep_Signed_Date__c, Attestation_by_Licensee_Applicant_Rep__c, ActualVisitEndTime, ActualVisitStartTime, ownerid, owner.name, Account.name, Account.Phone, Application_Type__c, Business_License_Inspection_Type__c, Contact.name, InstructionDescription, LocationId, Name, PlannedVisitEndTime, PlannedVisitStartTime, ServiceResourceId, Status__c, StatusRemarks,Comments__c, UserId, VisitPriority, ContextId, PlaceId, VisitorId, Visitor.name, AccountId, visitTypeId, Recurrence__c,Inspection_Reason__c, Business_Name__c,
                 TYPEOF Context
                    WHEN BusinessLicense THEN Last_Inspection_Date__c, RegulatoryAuthorizationType.Name, RegulatoryAuthorizationType.IssuingDepartment.Name, Name,  RegulatoryAuthorizationType.IssuingDepartment.Pin_Color__c, Doing_Business_As_DBA_or_Trade_Name__c, Legacy_License_Number__c, RegulatoryAuthorizationType.Inspection_Questions__c, RegulatoryAuthorizationType.Profession_Code__c, Contact.FirstName, Contact.LastName, Contact.MiddleName,Contact.Suffix, Contact.Account.Social_Security_Number__c
                    WHEN IndividualApplication THEN LicenseType.Name, LicenseType.IssuingDepartment.Name, Name, LicenseType.IssuingDepartment.Pin_Color__c
                    WHEN BusinessLicenseApplication THEN Last_Inspection_Date__c, LicenseType.Name, LicenseType.IssuingDepartment.Name, Name, LicenseType.IssuingDepartment.Pin_Color__c,Doing_Business_As_DBA_or_Trade_Name__c, LicenseType.Inspection_Questions__c, LicenseType.Profession_Code__c, Applicant.FirstName, Applicant.LastName, Applicant.MiddleName,Applicant.Suffix, Applicant.Account.Social_Security_Number__c
                    WHEN Case THEN Last_Inspection_Date__c,Board_Name__c, License_Number__c, Business_License_Id__c,CaseNumber, Contact.FirstName, Contact.LastName, Contact.MiddleName,Contact.Suffix, Contact.Account.Social_Security_Number__c
                    ELSE Name
                 END
             FROM Visit WHERE visitorId = :userId
             AND Status__c IN ('Planned', 'InProgress')
         ];
     }
   }
 
   /**
      * @author                   Anmol Mathur
      * @description              This method will Fetch Mobile_Max_Previous_Visits Count Visit[] which are associated with the Assigned Visit's Context
      * @param :                  String userId
      * @return                   `Visit[]`
      */
   private static Visit[] getAllPreviousVisits(String userId, String contextId) {     
     Set<Id> contextIDs = new Set<Id>();
     contextIDs.add(contextId);
     Visit[] allVisitsOfContexts = getAllVisitsOfContext(contextIDs);
     return allVisitsOfContexts;
   }
 
    /**
      * @author                   Anmol Mathur
      * @description              This method will Fetch all Visit[] which are associated with the Context
      * @param :                  Set<Id> contextIds
      * @return                   `Visit[]`
      */
   private static Visit[] getAllVisitsOfContext(Set<Id> contextIds) {     
     Integer maxRecords = integer.valueOf(Label.Mobile_Max_Previous_Visits);
     return  
     [
        SELECT Id,Classification__c,Classification_type__c, Description__c, Board_Name__c, Unable_to_Inspect__c, Name_of_Licensee_Applicant_Representativ__c, Title__c,Inspector_Signed_Date__c, Licensee_Applicant_Rep_Signed_Date__c, Attestation_by_Licensee_Applicant_Rep__c, ActualVisitEndTime, ActualVisitStartTime, ownerid, owner.name, Account.name, Account.Phone, Application_Type__c, Business_License_Inspection_Type__c, Contact.name, InstructionDescription, LocationId, Name, PlannedVisitEndTime, PlannedVisitStartTime, ServiceResourceId, Status__c,Comments__c, StatusRemarks, UserId, VisitPriority, ContextId, PlaceId, VisitorId, Visitor.name, AccountId, visitTypeId, Recurrence__c,Inspection_Reason__c, Business_Name__c,
        TYPEOF Context
           WHEN BusinessLicense THEN Last_Inspection_Date__c, RegulatoryAuthorizationType.Name, RegulatoryAuthorizationType.IssuingDepartment.Name, Name,  RegulatoryAuthorizationType.IssuingDepartment.Pin_Color__c, Doing_Business_As_DBA_or_Trade_Name__c, Legacy_License_Number__c, RegulatoryAuthorizationType.Inspection_Questions__c, RegulatoryAuthorizationType.Profession_Code__c, Contact.FirstName, Contact.LastName, Contact.MiddleName,Contact.Suffix, Contact.Account.Social_Security_Number__c
           WHEN IndividualApplication THEN LicenseType.Name, LicenseType.IssuingDepartment.Name, Name, LicenseType.IssuingDepartment.Pin_Color__c
           WHEN BusinessLicenseApplication THEN Last_Inspection_Date__c, LicenseType.Name, LicenseType.IssuingDepartment.Name, Name, LicenseType.IssuingDepartment.Pin_Color__c,Doing_Business_As_DBA_or_Trade_Name__c, LicenseType.Inspection_Questions__c, LicenseType.Profession_Code__c, Applicant.FirstName, Applicant.LastName, Applicant.MiddleName,Applicant.Suffix, Applicant.Account.Social_Security_Number__c
           WHEN Case THEN Last_Inspection_Date__c,Board_Name__c, License_Number__c, Business_License_Id__c,CaseNumber, Contact.FirstName, Contact.LastName, Contact.MiddleName,Contact.Suffix, Contact.Account.Social_Security_Number__c                  
           ELSE Name
        END
         FROM Visit 
         WHERE ContextId IN : contextIds AND Status__c IN ('Completed', 'Abandoned') 
         ORDER BY Actual_End_Date__c DESC LIMIT :maxRecords 
     ];
   }
 
 
    /**
      * @author                   Anmol Mathur
      * @description              This method will return Address[] which are associated with the Visits
      * @param :                  Set<Id> allAddressIds
      * @return                   `Address[]`
      */
   public static Schema.Address[] getAllAddress(Set<Id> allAddressIds) {     
     return  
     [
         SELECT Id, Street, AddressType, County__c, city, Country, Latitude, LocationType, Longitude, Name, PostalCode, State, Parent.Name 
         FROM Address WHERE Id IN : allAddressIds
     ];
   }


    /**
      * @author                   Anmol Mathur
      * @description              This method will return Address[] which are associated with the Visits
      * @param :                  Set<Id> allAddressIds
      * @return                   `Address[]`
      */
      public static Inspection_Content__c[] getAllInspectionContent(Set<Id> inspectionIds) {     
        return  
        [
            SELECT Id,Prof_Liability_Insurance__c,License_Number__c,Inspection__c, Current__c, Photo_Attached__c, Posted__c, Present__c, Operator_Temp_Permits_and_Apprentices__c
            FROM Inspection_Content__c WHERE Inspection__c IN : inspectionIds
        ];
      }
 
    /**
      * @author                   Anmol Mathur
      * @description              This method will return InspectionType[] which are associated with the Visits
      * @param :                  Set<Id> allVisitTypeIds
      * @return                   `InspectionType[]`
      */
     public static InspectionType[] getAllVisitType(Set<Id> allVisitTypeIds) {     
     return  
     [
         SELECT Id,Description, Duration_In_Hours__c, name 
         FROM InspectionType WHERE Id IN : allVisitTypeIds
     ];
   }
 
   // Exceptions
   public class UnAuthorizedUserException extends Exception {}
 
   public class ContextIdMissingException extends Exception {}
 
   // Wrapper Classes
   /**
      * @description : Wrapper Class which contains Visit object's manupulated data.
     */
   public class VisitResponseWrapper{
         public String name;  
         public String accountId;    
         public String accountName;
         public String visitorName;
         public String phone;
         public String actualVisitEndTime;
         public String actualVisitStartTime;
         public String applicationType;
         public String businessLicenseInspectionType;
         public String contactId;
         public String contactName;
         public String id;
         public String instructionDescription;
         public String locationId;
         public String ownerId;
         public String ownerName;
         public String plannedVisitEndTime;
         public String plannedVisitStartTime;
         public String serviceResourceId;
         public String status;
         public String statusRemarks;
         public String userId;
         public String visitPriority;
         public String professionType;
         public String board;
         public String sourceId;
         public String sourceName;
         public String recurrence;
         public Boolean isPast;
         public Boolean displayEmployee;
         public AddressResponseWrapper place; 
         public VisitTypeResponseWrapper visitType;
         public String  pinColor;
         public String subType;
         public String DBA;
         public String description;
         public Boolean isAttestation;
         public String licenseeApplicantSignDate;
         public String title;
         public String licenseeApplicantSignName;
         public String inspectorSignedDate;
         public Boolean unabletoInspect;
         public String onBasePayload;
         public String inspectionQuestions;
         public String inspectionQuestionsAnswers;
         public String classification;
         public String lastInspectionDate;
         public String sourceType;
 
         public VisitResponseWrapper(Visit visit, Schema.Address objAddress, InspectionType objType, Boolean isPast, String onBasePayload, String inspectionQuestionsAnswers){
             this.name = visit.name;
             this.isPast = isPast;
             this.onBasePayload = onBasePayload;
             if (visit.accountid != null) {
                 this.accountId = visit.accountid;    
             } else {
                  this.accountId = '';
             }
             if (visit.Account != null) {
                 this.accountName = visit.Account.name;
                 this.phone = visit.Account.phone;
             } else {
                 this.accountName = '';
                 this.phone = '';
             }
             if (visit.Visitor != null) {
                 this.visitorName = visit.Visitor.name;    
             } else {
                 this.visitorName = '';
             }
             this.actualVisitEndTime = string.valueOfGmt(visit.actualvisitendtime);
             this.actualVisitStartTime = string.valueOfGmt(visit.actualvisitstarttime);
             this.applicationType = visit.Application_Type__c;
             this.businessLicenseInspectionType = visit.Business_License_Inspection_Type__c;
             if (visit.contactid != null) {
                 this.contactId = visit.contactid;    
             } else {
                 this.contactId = '';
             }
             if (visit.contact != null) {
                 this.contactName = visit.contact.name;    
             } else {
                 this.contactName = '';
             }
             this.id = visit.id;
             this.instructionDescription = visit.InstructionDescription;
             this.locationId = visit.LocationId;
             this.ownerId = visit.ownerid;
             this.ownerName = visit.owner.name;
             this.plannedVisitEndTime = string.valueOfGmt(visit.plannedvisitendtime);
             this.plannedVisitStartTime = string.valueOfGmt(visit.plannedvisitstarttime);
             this.serviceResourceId = visit.serviceresourceid;
             this.status = visit.Status__c;
             this.statusRemarks = visit.Comments__c;
             this.userId = visit.userid;
             this.visitPriority = visit.visitpriority;
             this.sourceId = visit.ContextId;
             this.recurrence = visit.Recurrence__c;
             this.displayEmployee = false;
             this.description = visit.Description__c;
             this.isAttestation = visit.Attestation_by_Licensee_Applicant_Rep__c;
             this.licenseeApplicantSignDate = string.valueOfGmt(visit.Licensee_Applicant_Rep_Signed_Date__c);
             this.title = visit.Title__c;
             this.licenseeApplicantSignName = visit.Name_of_Licensee_Applicant_Representativ__c;
             this.inspectorSignedDate = string.valueOfGmt(visit.Inspector_Signed_Date__c);
             this.unabletoInspect = visit.Unable_to_Inspect__c;
             if(String.isNotBlank(visit.Classification_type__c)){
                this.classification = visit.Classification_type__c.replace(';',',');
             }
                       
             if(visit.Inspection_Reason__c != null){
                 this.subType = visit.Inspection_Reason__c;
             }else{
                 this.subType = '';
             }
             
             
             if(visit.Context instanceof Schema.IndividualApplication) {
                 Schema.IndividualApplication lType = visit.Context;
                 this.professionType = lType.LicenseType.Name;
                 this.board = lType.LicenseType.IssuingDepartment.Name;
                 this.sourceName = lType.Name;
                 this.pinColor= lType.LicenseType.IssuingDepartment.Pin_Color__c;
                 this.sourceType = 'IndividualApplication';
             } else if (visit.Context instanceof Schema.BusinessLicense) {
                 Schema.BusinessLicense businessL = visit.Context;
                 this.professionType = businessL.RegulatoryAuthorizationType.Name;
                 this.board = businessL.RegulatoryAuthorizationType.IssuingDepartment.Name;
                 this.sourceName = businessL.Legacy_License_Number__c != null ? businessL.Legacy_License_Number__c : businessL.Name;
                 this.pinColor = businessL.RegulatoryAuthorizationType.IssuingDepartment.Pin_Color__c;
                 this.displayEmployee = true;
                 this.DBA = businessL.Doing_Business_As_DBA_or_Trade_Name__c;
                 this.inspectionQuestions = businessL.RegulatoryAuthorizationType.Inspection_Questions__c;
                 this.lastInspectionDate = string.valueOfGmt(businessL.Last_Inspection_Date__c);
                 this.sourceType = 'BusinessLicense';
             } else if (visit.Context instanceof Schema.BusinessLicenseApplication ) {
                 Schema.BusinessLicenseApplication businessLA = visit.Context;
                 this.professionType = businessLA.LicenseType.Name;
                 this.board = businessLA.LicenseType.IssuingDepartment.Name;
                 this.sourceName = businessLA.Name;
                 this.displayEmployee = true;
                 this.pinColor=  businessLA.LicenseType.IssuingDepartment.Pin_Color__c;
                 this.DBA = businessLA.Doing_Business_As_DBA_or_Trade_Name__c;
                 this.inspectionQuestions = businessLA.LicenseType.Inspection_Questions__c;
                 this.lastInspectionDate =string.valueOfGmt(businessLA.Last_Inspection_Date__c);
                 this.sourceType = 'BusinessLicenseApplication';
             }else if (visit.Context instanceof Schema.Case ) {
                Schema.Case caseContext = visit.Context;
                this.board = caseContext.Board_Name__c;
                this.sourceName = caseContext.CaseNumber;
                this.displayEmployee = false;
                this.lastInspectionDate =string.valueOfGmt(caseContext.Last_Inspection_Date__c);
                this.sourceType = 'Case';
            }

 
             this.place = new AddressResponseWrapper(objAddress);
             this.visitType = new VisitTypeResponseWrapper(objType);

             this.inspectionQuestionsAnswers= inspectionQuestionsAnswers;
         }
 
     }
     
     /**
      * @description : Wrapper Class which contains address object's manupulated data.
      */
 
     public class AddressResponseWrapper{
         public String address = '';  
         public String city = '';    
         public String country = '';
         public String id = '';
         public String latitude = '';
         public String longitude = '';
         public String postalcode = '';
         public String state = '';
         public String street = '';
         public String county = '';
         public String name = '';
 
         public AddressResponseWrapper(Schema.Address objAddress){
             if (objAddress != null) {
                 this.address = objAddress.Street;
                 this.city = objAddress.city;
                 this.country = objAddress.country;
                 this.id = objAddress.Id;
                 this.latitude = string.valueof(objAddress.latitude);
                 this.longitude = string.valueof(objAddress.longitude);
                 this.postalcode = objAddress.postalcode;
                 this.state = objAddress.state;
                 this.street = objAddress.street;
                 this.county = objAddress.County__c;
                 this.name = objAddress.Parent.Name;
             }
         }
     }
 
     // Wrapper Classes
     /**
      * @description : Wrapper Class which contains Visit Type object's manupulated data.
      */
 
     public class VisitTypeResponseWrapper{
           public String name = '';  
           public String id = ''; 
           
           public VisitTypeResponseWrapper(InspectionType objType){
             if (objType != null) {
                 this.name= objType.name;
                 this.id= objType.id;
             }   
         }
     }
 
     // Wrapper Classes
     /**
         * @description : Wrapper Class for parsing POST Request
     */
     public class VisitPOSTRequest {
     
         public String userId;
         public List<UserVisits> visits;
     }
 
      public class UserVisits {
         
         public String id;
         public String status;
         public String actualVisitStartTime;
         public String actualVisitEndTime;
         public String finalAssessmentResult;
         public String statusRemarks;
         public String licenseeApplicantSignDate;
         public String title;
         public String licenseeApplicantSignName;
         public String inspectorSignedDate;
         public Boolean unabletoInspect;
         public Boolean attestationbyLicenseeApplicantRep;
         public String inspectionQuestions;
         public String inspectionQuestionsAnswers;
         public String subReason;
         public String drugName;
         public String sequenceNumber;
         
 
     }
 
      // Wrapper Classes
     /**
         * @description : Wrapper Class for POST Response
     */
     public class VisitPOSTResponse {
     
         public String id;
         public String result;
         public String error;
         public String syncTime;
 
         public VisitPOSTResponse(Database.SaveResult saveResult) {
             if (saveResult != null) {
                 DateTime currentDateTime = Datetime.now();
                 this.id = saveResult.getId();
                 this.syncTime = String.valueOf(currentDateTime);
                 if (saveResult.isSuccess()) {
                     this.error = ''; 
                     this.result = 'Synced';
                 } else {
                     this.result = 'Failed';
                     List<String> errorMessages = new List<String>();
                     for(Database.Error err : saveResult.getErrors()) {
                         errorMessages.add(err.getStatusCode() + ': ' + err.getMessage());
                     }
                     this.error = String.join(errorMessages, ' ');
                 }
             }
         }
 
         public VisitPOSTResponse(String Id) {
             this.id = Id;
             this.result = 'Not Assigned';
             this.error = 'Visit Not assigned to Visitor';
             DateTime currentDateTime = Datetime.now();
             this.syncTime = String.valueOf(currentDateTime);
         }
     }
 
     public class APIResponse {
         public String status;
         public String error;
         List<Object> response;
     }
 }