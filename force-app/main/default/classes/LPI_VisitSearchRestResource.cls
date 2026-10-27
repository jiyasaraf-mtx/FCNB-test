/**
 * @author : Lokendra Jhala
 * @since : 21st Aug 2023
 * @description : This apex class Captures Request from Mobile and returns required data.
 */

 @RestResource(urlMapping='/SearchInspections/*')
 global with sharing class LPI_VisitSearchRestResource {

      // Exceptions
    public class UnAuthorizedUserException extends Exception {}

    @HTTPPost
    global static void submiSearchInspections(){
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        APIResponse objResponse = new APIResponse();
        objResponse.response = new List<Object>();

        InspectionPOSTRequest ehelper;
        String jsonStr;

        try {
            if (req.requestBody != null) {
                jsonStr = req.requestBody.toString();
            }
            ehelper = (InspectionPOSTRequest) System.JSON.deserialize(jsonStr, InspectionPOSTRequest.class);
           
            if(ehelper != null) {
                 // Check if the user is requesting for it's own records
                if (String.isNotBlank(ehelper.userId) && ehelper.userId != UserInfo.getUserId()) {
                    throw new UnAuthorizedUserException();
                }
                //InspectionPOSTRequest
                if(ehelper.inspection != null && ehelper.inspection.id != null && ehelper.inspection.visitorId != null){
                  
                   //Visit Id Set
                   Set<Id> visitGroupIdSet = new Set<Id>();
                   //Fetch the visit object 
                   List<Visit> allVisits = getVisitById(ehelper.inspection.visitorId,ehelper.inspection.id);
                    
                   for (Visit visit : allVisits) {       
                    visitGroupIdSet.add(visit.ownerid);   
                }

               
        
                    if(!visitGroupIdSet.isEmpty()){

                        //Fetch the vists Group member and check current user is the part of the group to assit on the visit
                        Set<String> userIDs = new Set<String>();
                        String fieldsToQuery, whereClause;
                        fieldsToQuery = 'id,Group.Name, GroupId, UserOrGroupId';
                        whereClause = 'GroupId IN '+ LPI_ServiceUtility.getStringValuesBySet(visitGroupIdSet) +'  AND UserOrGroupId =\''+ehelper.userId +'\''; 
                        LPI_GroupMemberDAO.LPI_GroupMemberWithoutSharingDAO groupDao = new LPI_GroupMemberDAO.LPI_GroupMemberWithoutSharingDAO();
                        List<GroupMember> groupMemberIds = groupDao.getGroupMemberByDymanicQuery(fieldsToQuery,
                        whereClause,
                        null,
                        null,
                        null);

                        //Check if user is member of COSBAR Inspector Supervisor
                        fieldsToQuery = 'id,Group.Name, GroupId, UserOrGroupId';
                        whereClause = 'Group.Name =\'COSBAR Inspector Supervisor\' AND UserOrGroupId =\''+ehelper.userId +'\''; 
                        List<GroupMember> cosbarGroupMemberIds = groupDao.getGroupMemberByDymanicQuery(fieldsToQuery,
                        whereClause,
                        null,
                        null,
                        null);



                        //To Assist the visit Visitor should be part of visit owner group or a member of COSBAR Inspector Supervisor
                        // in case of COSBAR
                        if(!groupMemberIds.isEmpty() || !cosbarGroupMemberIds.isEmpty()){

                            for (Visit objVisit : allVisits) {
                                
                                objVisit.VisitorId = ehelper.userId;
    
                            }

                            List<Database.SaveResult> updateResults = Database.update(allVisits);
                            objResponse.error = '';
                            objResponse.status = 'Success';
                            for (Database.SaveResult updateResult : updateResults) {
                                objResponse.response.add(new VisitPOSTResponse(updateResult));
                            }
                            res.responseBody = Blob.valueOf(JSON.serialize(objResponse));
                            res.statusCode = 200;
                        }else{
                            objResponse.error = 'You are not a part of the visit group to assist';
                            objResponse.status = 'Fail';
                            res.responseBody = Blob.valueOf(JSON.serialize(objResponse));
                            res.statusCode = 400;
                        }

                    }else{
                        objResponse.error = 'Visit not found';
                        objResponse.status = 'Fail';
                        res.responseBody = Blob.valueOf(JSON.serialize(objResponse));
                        res.statusCode = 400;
                    }
                    
        

                }else{
                    objResponse.error = 'Cannot Parse the Request';
                    objResponse.status = 'Fail';
                    res.responseBody = Blob.valueOf(JSON.serialize(objResponse));
                    res.statusCode = 400;
                }
            }
        } catch (UnAuthorizedUserException e){
            res.statusCode = 500;
            res.responseBody = Blob.valueOf('User not authorized');
        } catch (Exception ex) {
            res.statusCode = 400;
            res.responseBody = Blob.valueOf('Error with the request parameters' + ex.getMessage());
        }
    }

    @HttpGet
    global static void searchInspection(){
        RestResponse res = RestContext.response;
        RestRequest req = RestContext.request;
            try {
    
                String userId = req.params.get('userId');
                String inspectorId = req.params.get('inspectorId');



                // Check if the user is requesting for it's own records
                if (String.isNotBlank(userId) && userId != UserInfo.getUserId()) {
                   throw new UnAuthorizedUserException();
                }

                if(String.isNotBlank(inspectorId)){
                    List<Visit> allVisits = getVisits(inspectorId);
                    if (allVisits.isEmpty()) {
                        
                        res.responseBody = Blob.valueOf(JSON.serialize(allVisits));
                        res.statusCode = 200;
                        return;
                    }

                            // Get the address and VisitType associated with Visit
                    Set<Id> addressIDs = new Set<Id>();
                    Map<Id, Schema.Address> addressMap = new Map<Id, Schema.Address>();
                    
                    Set<Id> visitTypeIds = new Set<Id>();
                    Map<Id, InspectionType> visitTypeMap = new Map<Id, InspectionType>();
                    
                    for (Visit visit : allVisits) {
                        if(visit.placeId != null){
                            addressIDs.add(visit.placeId);
                        }
                        if(visit.visitTypeId != null){
                            visitTypeIds.add(visit.visitTypeId);
                        }
                    }

                    if (!addressIDs.isEmpty()) {
                        Schema.Address[] allAddresses = LPI_VisitControllerRestResource.getAllAddress(addressIDs);
                        for (Schema.Address add : allAddresses) {
                            addressMap.put(add.Id, add);
                        }
                    }

                    if (!visitTypeIds.isEmpty()) {
                        InspectionType[] allVisitTypes = LPI_VisitControllerRestResource.getAllVisitType(visitTypeIds);
                        for (InspectionType vTypes : allVisitTypes) {
                            visitTypeMap.put(vTypes.Id, vTypes);
                        }
                    }

                    // Bind all together in Wrapper and send response back
                    List<LPI_VisitControllerRestResource.VisitResponseWrapper> visitWrap = new List<LPI_VisitControllerRestResource.VisitResponseWrapper>();
                    for (Visit objVisit : allVisits) {
                        Schema.Address objAddress = addressMap.get(objVisit.placeId);
                        InspectionType objType = visitTypeMap.get(objVisit.visitTypeId);
                        visitWrap.add(new LPI_VisitControllerRestResource.VisitResponseWrapper(objVisit, objAddress, objType, false,'',''));
                    }

                    res.responseBody = Blob.valueOf(JSON.serialize(visitWrap));
                    res.statusCode = 200;
                }else{
                    res.statusCode = 404;
                    res.responseBody = Blob.valueOf('Inspector Id not found');
                }
            } catch (System.StringException e){
                res.statusCode = 400;
                res.responseBody = Blob.valueOf('Param: userId is not a valid Id');
            } catch (UnAuthorizedUserException e){
                res.statusCode = 500;
                res.responseBody = Blob.valueOf('User not authorized to access other users visit');
            } catch (System.QueryException e){
                res.statusCode = 404;
                res.responseBody = Blob.valueOf('Requested User not found');
            } catch (Exception e){ //something else happened
                res.statusCode = 500;
                res.responseBody = Blob.valueOf(e.getMessage());
            }
    
        }   
    
    
    
    
    /**
     * @author                  Lokendra Jhala
     * @description              This method will return Visit[] which are associated with the UserId and Visit Id and status is {'Planned', 'InProgress','Abandoned'}
     * @param :                  String userId
     * @param :                  String visitId
     * @return                   `Visit[]`
     */
    private static List<Visit> getVisitById(String userId,String visitId) {  
    
    
            List<String> fieldsToQuery = new List<String>();  
            List<String> status = new List<String>{'Planned', 'InProgress','Abandoned'};  
            String whereClause;
            fieldsToQuery.add('Id');
            fieldsToQuery.add('ownerid');
            fieldsToQuery.add('VisitorId');
            whereClause = 'Status__c IN '+ LPI_ServiceUtility.getStringValuesByList(status) +' AND visitorId =\''+userId+'\'' + ' AND Id =\''+visitId+'\'';
            return LPI_VisitControllerDAO.getVisitListByDynamicQueryWithoutSecurity(fieldsToQuery,
            whereClause,
            null,
            null,
            null);
    }
    


     /**
     * @author                  Lokendra Jhala
     * @description              This method will return Visit[] which are associated with the UserId
     * @param :                  String userId
     * @param :                  Boolean isPrevious
     * @return                   `Visit[]`
     */
  private static List<Visit> getVisits(String userId) {  
    List<String> fieldsToQuery = new List<String>();  
    List<String> status = new List<String>{'Planned', 'InProgress','Abandoned'};  
    String whereClause;
    String typeOf = 'TYPEOF Context WHEN BusinessLicense THEN Last_Inspection_Date__c, RegulatoryAuthorizationType.Name, RegulatoryAuthorizationType.IssuingDepartment.Name, Name,  RegulatoryAuthorizationType.IssuingDepartment.Pin_Color__c, Doing_Business_As_DBA_or_Trade_Name__c, Legacy_License_Number__c, RegulatoryAuthorizationType.Inspection_Questions__c, RegulatoryAuthorizationType.Profession_Code__c WHEN IndividualApplication THEN LicenseType.Name, LicenseType.IssuingDepartment.Name, Name, LicenseType.IssuingDepartment.Pin_Color__c WHEN BusinessLicenseApplication THEN Last_Inspection_Date__c, LicenseType.Name, LicenseType.IssuingDepartment.Name, Name, LicenseType.IssuingDepartment.Pin_Color__c,Doing_Business_As_DBA_or_Trade_Name__c, LicenseType.Inspection_Questions__c, LicenseType.Profession_Code__c  WHEN Case THEN Last_Inspection_Date__c,Board_Name__c, License_Number__c, Business_License_Id__c,CaseNumber, Contact.FirstName, Contact.LastName, Contact.MiddleName,Contact.Suffix, Contact.Account.Social_Security_Number__c ELSE Name END';
    fieldsToQuery.add('Id');
    fieldsToQuery.add('ActualVisitEndTime');
    fieldsToQuery.add('ActualVisitStartTime');
    fieldsToQuery.add('ownerid');
    fieldsToQuery.add('owner.name');
    fieldsToQuery.add('Account.name');
    fieldsToQuery.add('Account.Phone');
    fieldsToQuery.add('Business_Name__c');
    
    fieldsToQuery.add('Application_Type__c');
    fieldsToQuery.add('Business_License_Inspection_Type__c');
    fieldsToQuery.add('Contact.name');
    fieldsToQuery.add('InstructionDescription');
    fieldsToQuery.add('LocationId');
    fieldsToQuery.add('Name');

    fieldsToQuery.add('PlannedVisitEndTime');
    fieldsToQuery.add('PlannedVisitStartTime');
    fieldsToQuery.add('ServiceResourceId');
    fieldsToQuery.add('Status__c');
    fieldsToQuery.add('StatusRemarks');
    fieldsToQuery.add('Comments__c');
    fieldsToQuery.add('UserId');
    fieldsToQuery.add('Unable_to_Inspect__c');
    

    fieldsToQuery.add('VisitPriority');
    fieldsToQuery.add('ContextId');
    fieldsToQuery.add('PlaceId');
    fieldsToQuery.add('VisitorId');
    fieldsToQuery.add('Visitor.name');

    fieldsToQuery.add('AccountId');
    fieldsToQuery.add('visitTypeId');
    fieldsToQuery.add('Recurrence__c');
    fieldsToQuery.add('Inspection_Reason__c');

    fieldsToQuery.add('Description__c');
    fieldsToQuery.add('Name_of_Licensee_Applicant_Representativ__c');
    fieldsToQuery.add('Title__c');
    fieldsToQuery.add('Inspector_Signed_Date__c');
    fieldsToQuery.add('Licensee_Applicant_Rep_Signed_Date__c');
    fieldsToQuery.add('Attestation_by_Licensee_Applicant_Rep__c');
    fieldsToQuery.add('Classification__c');
    fieldsToQuery.add('Classification_type__c');

    fieldsToQuery.add(typeOf);
    
    whereClause = 'Status__c IN '+LPI_ServiceUtility.getStringValuesByList(status) +'AND Unable_to_Inspect__c != true AND visitorId =\''+userId+'\'';
    return LPI_VisitControllerDAO.getVisitListByDynamicQueryWithoutSecurity(fieldsToQuery,
    whereClause,
    null,
    null,
    null);
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
    }


  public class APIResponse {
    public String status;
    public String error;
    List<Object> response;

  }

  // Wrapper Classes
    /**
        * @description : Wrapper Class for parsing POST Request
    */
    public class InspectionPOSTRequest {
    
        public String userId;
        public Inspection inspection;
    }

     public class Inspection {
        
        public String id;
        public String visitorId;
        public String name;  
        
    }

}