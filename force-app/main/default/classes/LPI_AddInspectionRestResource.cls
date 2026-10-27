@RestResource(urlMapping='/AddInspection/*')
global with sharing class LPI_AddInspectionRestResource {
    
    @HTTPPost
    global static void createNewVisit() {

    RestRequest req = RestContext.request;
    RestResponse res = RestContext.response;
    InspectionPOSTRequest requestWrapper;
    String US_COUNTRY_CODE = 'US';
    String DEFAULT_VISIT_STATUS = 'Planned';
    String ADHOC_INSPECTION = 'Adhoc Inspection';
    String OTHER_INSPECTION = 'Other';
    String ADDITIONAL_INSPECTION = 'Additional Inspection';
    String ADDITIONAL_INSPECTION_REASON = 'Additional Assistance';
    String ADHOC_INSPECTION_REASON = 'Adhoc Inspection';
    Map<String,Object> responseMap = new Map<String,Object>();
    
    String jsonStr;
    try {
        if (req.requestBody != null) {
            jsonStr = req.requestBody.toString();
        }
        requestWrapper = (InspectionPOSTRequest) System.JSON.deserialize(jsonStr, InspectionPOSTRequest.class);
       
        if(requestWrapper != null) {
            // Check if the user is requesting for it's own records
            if (String.isNotBlank(requestWrapper.userId) && requestWrapper.userId != UserInfo.getUserId()) {
                throw new UnAuthorizedUserException();
            }
            if (requestWrapper.inspection != null) {
                Inspection inspectionRequest = requestWrapper.inspection;
                Visit v = new Visit();
                
                //Insert address for the visit.
                if (inspectionRequest.placeId != null) {
                    v.PlaceId = inspectionRequest.placeId;
                } else {
                Schema.Location locRec = new Schema.Location();
                locRec.Name = inspectionRequest.address.name;
                locRec.LocationType = inspectionRequest.address.type;
                SObject locRecInsert = LPI_DML.doInsert(locRec);
                Schema.Address addressRec = new Schema.Address();
                addressRec.LocationType = inspectionRequest.address.type;
                addressRec.Street = inspectionRequest.address.street;
                addressRec.City = inspectionRequest.address.city;
                addressRec.PostalCode = inspectionRequest.address.zip;
                addressRec.StateCode = inspectionRequest.address.state;
                addressRec.CountryCode = US_COUNTRY_CODE;
                addressRec.ParentId = (Id) locRecInsert.get('Id');
                SObject addRecInsert = LPI_DML.doInsert(addressRec);
                v.PlaceId = (Id) addRecInsert.get('Id');
            }
                v.VisitPriority = inspectionRequest.priority != null? inspectionRequest.priority : '';
                v.Status__c = DEFAULT_VISIT_STATUS;
                v.VisitorId = inspectionRequest.visitorId != null ? inspectionRequest.visitorId : '';
                v.ContextId = inspectionRequest.contextId != null ? inspectionRequest.contextId : null;
                v.AccountId = inspectionRequest.accountId != null ? inspectionRequest.accountId : null;
                v.License_Type__c =inspectionRequest.licenseType;
                v.Inspection_Forms__c = inspectionRequest.inspectionForms != null ? inspectionRequest.inspectionForms : '';

                DateTime currentDateTime = DateTime.now().addMinutes(15);
                Time timeObj = Time.newInstance(currentDateTime.hour(), currentDateTime.minute(), currentDateTime.second(), currentDateTime.millisecond());
                v.PlannedVisitStartTime = DateTime.newInstance(inspectionRequest.plannedStartDate,timeObj);  
                if(inspectionRequest.plannedEndDate!=null) {
                    timeObj =  Time.newInstance(23, 59, 0, 0);
                    v.PlannedVisitEndTime = DateTime.newInstance(inspectionRequest.plannedEndDate,timeObj);
                }
                if(requestWrapper.type!=null && (requestWrapper.type.equalsIgnoreCase('additional') || requestWrapper.type.equalsIgnoreCase('adhoc'))) {
                // Populating Description in case of Additional inspection.
                    v.Description__c = inspectionRequest.description != null 
                    ? inspectionRequest.description 
                    : '';
                    String comparator = requestWrapper.type.equalsIgnoreCase('additional') ? ADDITIONAL_INSPECTION : ADHOC_INSPECTION;
                    // Fetch Inspection Type for Additional Inspection and Assign it while creating Visit.
                    List<InspectionType> inspectionTypeList= LPI_InspectionTypeDAO.getInspectionTypeRecords('Id',
                    'Name = \''+ comparator +'\'',
                    null,null
                    );
                    if(inspectionTypeList.isEmpty()) {
                        throw new LPI_Exception('Couldnt Find Additional Inspection Type');
                    }
                    v.VisitTypeId = inspectionTypeList[0].Id;
                    v.Id = null;
                    if ((requestWrapper.type.equalsIgnoreCase('additional'))) {
                        v.Inspection_Reason__c = ADDITIONAL_INSPECTION_REASON;
                    }else{
                        v.Inspection_Reason__c = ADHOC_INSPECTION_REASON;
                    }
                } 

                v = (Visit)LPI_DML.doUpsert(v);
                responseMap.put('visitId', v.Id);

                res.responseBody = Blob.valueOf(JSON.serialize(responseMap));
                res.statusCode = 200;
                return;
            } else {
                 res.statusCode = 400;
                 res.responseBody = Blob.valueOf('Bad request');
            }
        }else{
            res.statusCode = 400;
            res.responseBody = Blob.valueOf('Bad request');
        }
    } catch (UnAuthorizedUserException e){
        res.statusCode = 500;
        res.responseBody = Blob.valueOf('User not authorized to submit other users visit');
    } catch (Exception ex) {
        res.statusCode = 400;
        res.responseBody = Blob.valueOf('Error with the request parameters' + ex.getMessage());
    }
  }

     public class UnAuthorizedUserException extends Exception {}
    /**
      * @author                   Umangshu Chouhan
      * @description              This is the GET Method of the class which will returns required fields to be displayed on Create Additional Inspection and Create AdHoc Inspection pages.
      * @return                   `void`
      */
 
     @HttpGet
     global static void getAddInspectionData() {
         RestRequest req = RestContext.request;
         RestResponse res = RestContext.response;
         
         try {
             String userId = RestContext.request.params.get('userId');
             String type = RestContext.request.params.get('type');
             
             Map<String,Object> responseMap = new Map<String,Object>();
            responseMap.put('locationType',LPI_NewVisitRecord.fetchPicklist('Location', 'LocationType', false));
            responseMap.put('stateOptions',LPI_NewVisitRecord.fetchPicklist('Account', 'PersonOtherStateCode', false));
            responseMap.put('vistPriority',LPI_NewVisitRecord.fetchPicklist('Visit', 'VisitPriority', false));
            
            RegulatoryAuthorizationType[] allTypes = getAllLicenseTypes();
            List<LicenseType> licenseTypes = new List<LicenseType>();
            for (RegulatoryAuthorizationType lTObj : allTypes) {
                licenseTypes.add(new LicenseType(lTObj));
            }
            responseMap.put('licenseTypes', licenseTypes);
            res.responseBody = Blob.valueOf(JSON.serialize(responseMap));
 
         } catch (System.StringException e){
             RestContext.response.statusCode = 400;
             RestContext.response.responseBody = Blob.valueOf('Param: userId is not a valid Id');
         } catch (System.QueryException e){
             RestContext.response.statusCode = 404;
             RestContext.response.responseBody = Blob.valueOf('Requested User not found');
         } catch (Exception e){ //something else happened
             RestContext.response.statusCode = 500;
             RestContext.response.responseBody = Blob.valueOf(e.getMessage());
         }
     }

         public class APIResponse {
            public String status;
            public String error;
            List<Object> response;
        
          }

    /**
     * @author                   Umangshu Chouhan
     * @description              This method will return all RegulatoryAuthorizationType[]
     * @return                   `RegulatoryAuthorizationType[]`
     */
    private static RegulatoryAuthorizationType[] getAllLicenseTypes() {  
        return  
        [
            SELECT Id, Name 
            FROM RegulatoryAuthorizationType WHERE Authorisation_Type__c = 'Business' 
        ];
    }

    public class LicenseType{    
        public String id;
        public String name;
        public InspectionForm[] forms;

        public LicenseType(RegulatoryAuthorizationType objReg){
            this.id = objReg.Id;
            this.name = objReg.Name;
            this.forms = new InspectionForm[0];
            if (name.equalsIgnoreCase('Drug Outsourcer')) {
                this.forms.add(new InspectionForm('Inspection Template','Inspection Template'));
                this.forms.add(new InspectionForm('Quality Assurance Template','Quality Assurance Template'));
            }
        }
    }

    public class InspectionForm{
        public String label;
        public String value;

        public InspectionForm(String lbl, String val){
            this.label = lbl;
            this.value = val;
        }
    }
     

         // Wrapper Classes
    /**
        * @description : Wrapper Class for parsing POST Request
    */
    public class InspectionPOSTRequest {
        public String userId;
        public Inspection inspection;
        public String type; //adhoc, additional
    }

     public class Inspection {
        public String id;
        public String visitorId;
        public Address address;
        public String licenseType;
        public Date plannedStartDate;
        public Date plannedEndDate;
        public String contextId; //To be sent in case of additional inspections
        public String accountId; //To be sent in case of additional inspections
        public String status;
        public String placeId;
        public String priority;
        public String inspectionForms; //Comma separated in case of multiple forms
        public String description; //Sent in case of additional inspection.
    }

    public class Address {
        public String type;
        public String name;
        public String street;
        public String city;
        public String state;
        public String country;
        public String zip;
    }
}