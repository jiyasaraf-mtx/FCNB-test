/**
 * @author : MTX Group Product Team
 * @since : 18th April 2023
 * @description : This apex class Captures Request from Mobile and returns required data.
 */

@RestResource(urlMapping='/UserEmployee/*')
global with sharing class LPI_EmployeesControllerRestResource {
    
    /**
     * @author                   MTX Group Product Team
     * @description              This is the GET Method of the class which will return all Associated Employees of Visits that are linked with the userId passed in the parameter
     * @return                   `void`
     */
  @HTTPGet
  global static void getUserEmployees() {

    RestResponse res = RestContext.response;
    RestRequest req = RestContext.request;
        try {

            String userId = req.params.get('userId');

            // Check if the user is requesting for it's own records
            if (String.isNotBlank(userId) && userId != UserInfo.getUserId()) {
               throw new UnAuthorizedUserException();
            }

            Set<Id> accountIds = new Set<Id>();
            List<Visit> allVisits = [
                SELECT Id, ContextId, AccountId
                FROM Visit WHERE visitorId = :userId
                AND Status IN ('Planned', 'InProgress') AND ContextId != null AND AccountId != null
            ];
            
            for (Visit visit : allVisits) {
                accountIds.add(visit.AccountId); 
            }
            
            if (accountIds.size() > 0) {
                List<String> allowedRoles = new List<String>();
                allowedRoles.add(LPI_LiteralConstant.ROLE_OWNER);
                allowedRoles.add(LPI_LiteralConstant.ROLE_EMPLOYEE);
                allowedRoles.add(LPI_LiteralConstant.ROLE_DESIGNATED_INCHARGE);
                allowedRoles.add(LPI_LiteralConstant.ROLE_DESIGNATED_INCHARGE_AND_OWNER);
                allowedRoles.add(LPI_LiteralConstant.FUNERAL_ESTABLISHMENT_EMPLOYEE);

                String fields = 'Id, Related_To__r.Name, Related_From__c, toLabel(Roles__c), Related_To_License_Number__r.Name, Related_To_License_Number__r.Regulatory_Authorization_Type_Name__c,  License_Number__c, Start_Date__c, EndDate__c, IsActive__c';
                String whereClause = ' Related_From__c IN ' +
                    + LPI_ServiceUtility.getStringValuesBySet(accountIds) +
                    ' AND Roles__c IN '+ LPI_ServiceUtility.getStringValuesByList(allowedRoles) + 
                    ' AND IsActive__c = true' + 
                    ' AND EndDate__c = null';
                List<Business_Relationships__c> accountContacts = LPI_BusinessRelationshipDAO.fetchBusinessRelationshipRecords(
                        fields,
                        whereClause,
                        null,
                        null,
                        null
                );
                
                // Bind all together in Wrapper and send response back
                List<EmployeeResponseWrapper> employeeWrap = new List<EmployeeResponseWrapper>();
                for (Business_Relationships__c objAC : accountContacts) {
                    employeeWrap.add(new EmployeeResponseWrapper(objAC));
                }
                
                res.responseBody = Blob.valueOf(JSON.serialize(employeeWrap));
                res.statusCode = 200;
                return;
            }       
            
            res.responseBody = Blob.valueOf('Cannot find the accounts');
            res.statusCode = 200;

        } catch (System.StringException e){
            res.statusCode = 400;
            res.responseBody = Blob.valueOf('Param: userId is not a valid Id');
        } catch (UnAuthorizedUserException e){
            res.statusCode = 500;
            res.responseBody = Blob.valueOf('User not authorized to access other users Notes');
        } catch (System.QueryException e){
            res.statusCode = 404;
            res.responseBody = Blob.valueOf('Requested User not found'+e);
        } catch (Exception e){ //something else happened
            res.statusCode = 500;
            res.responseBody = Blob.valueOf(e.getMessage());
        }
  }

  // Exceptions
  public class UnAuthorizedUserException extends Exception {}

  // Wrapper Classes
  /**
     * @description : Wrapper Class which contains Employee's object's manupulated data.
    */
  public class EmployeeResponseWrapper{
    	public String id;  
    	public String accountId; 
        public String contactId;  
        public String role;
        public String name;
        public String associationStartDate;    
        public String licenseType;
        public String licenseNo;
        public string status;

        public EmployeeResponseWrapper(Business_Relationships__c accountContact){

            this.id = accountContact.id;
            this.accountId = accountContact.Related_From__c;
            this.role = accountContact.Roles__c;
            this.name = accountContact.Related_To__r.Name;
            this.status = 'Active';
            this.licenseType = accountContact.Related_To_License_Number__r.Regulatory_Authorization_Type_Name__c != null ? accountContact.Related_To_License_Number__r.Regulatory_Authorization_Type_Name__c  : '';
            this.licenseNo = accountContact.Related_To_License_Number__r.Name != null ? accountContact.Related_To_License_Number__r.Name : '';
            this.associationStartDate = String.valueOf(accountContact.Start_Date__c);
        }
    }

}