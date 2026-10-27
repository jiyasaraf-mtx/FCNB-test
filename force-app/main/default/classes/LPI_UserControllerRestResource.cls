@RestResource(urlMapping='/UserDetails/*')
global with sharing class LPI_UserControllerRestResource {
      // Exceptions
  public class UnAuthorizedUserException extends Exception {}
    public LPI_UserControllerRestResource() {
    }
  
    @HttpGet
    global static void doGet() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        Boolean isCosbar = false;
        String userId = RestContext.request.params.get('userId');
        String fieldsToQuery, whereClause;
        try {
             // Check if the user is requesting for it's own records
             if (String.isNotBlank(userId) && userId != UserInfo.getUserId()) {
                 throw new UnAuthorizedUserException();
             }
            fieldsToQuery = 'Phone, FirstName, LastName, Email, City, State, PostalCode, ProfileId, Country, Username, Alias, CreatedDate, MiddleName, Name, FullPhotoUrl, Address, Title, UserRole.Name';
            whereClause = 'Id =\''+userId+'\'';
            List<User> records = LPI_UserDao.getUserByDymanicQueryWithoutSecurityEnforced(fieldsToQuery,
            whereClause,
            null,
            null,
            null);

            List<GroupMembersWrapper> groupMemberWrapperList = new List<GroupMembersWrapper>();
             // 1. Fetch the groups of inspector
            Set<String> groupIDSet = new Set<String>();
            fieldsToQuery = 'id,Group.name, GroupId';
                whereClause = 'Group.Type = \'Regular\' AND UserOrGroupId =\''+userId+'\'';
                LPI_GroupMemberDAO.LPI_GroupMemberWithoutSharingDAO groupDao = new LPI_GroupMemberDAO.LPI_GroupMemberWithoutSharingDAO();
                List<GroupMember> groupIds = groupDao.getGroupMemberByDymanicQuery(fieldsToQuery,
                whereClause,
                null,
                null,
                null);
            if (groupIds != null && groupIds.size()>0) {

                

                for (GroupMember groupId : groupIds) {
                    if(groupId.Group.name.contains('COSBAR')){
                        isCosbar = true;
                    }
                    groupIDSet.add(groupId.GroupId);
                }

                if(!isCosbar){
                    // 2. Fetch the inspectors  ids of groups 
                    Set<String> userIDs = new Set<String>();
                    fieldsToQuery = 'id,Group.Name, GroupId, UserOrGroupId';
                    whereClause = 'GroupId IN '+ LPI_ServiceUtility.getStringValuesByStringSet(groupIDSet); 
                    List<GroupMember> groupMemberIds = groupDao.getGroupMemberByDymanicQuery(fieldsToQuery,
                    whereClause,
                    null,
                    null,
                    null);

                    for (GroupMember memberId : groupMemberIds) {
                    
                            userIDs.add(memberId.UserOrGroupId);
                                
                    }

                    //3. Fetch the member details of the group

                    fieldsToQuery = 'Phone, Email,  Name, FullPhotoUrl, Title, UserRole.Name';
                    whereClause = ' Profile.Name = \'Inspectors\' And Id IN '+ LPI_ServiceUtility.getStringValuesByStringSet(userIDs); 
                    List<User> memberList = LPI_UserDao.getUserByDymanicQueryWithoutSecurityEnforced(fieldsToQuery,
                    whereClause,
                    null,
                    null,
                    null);
                    for (User user : memberList) {
                        groupMemberWrapperList.add(new GroupMembersWrapper(user));
                    }

                }else{
                    if(records != null && !records.isEmpty()) {
                        groupMemberWrapperList.add(new GroupMembersWrapper(records[0]));
                    }
                    
                }
                
            }
           
            
            if(records != null && !records.isEmpty()) {
                res.statusCode = 200;
                res.responseBody = Blob.valueOf(JSON.serialize(userToUserWrapper(records[0], groupMemberWrapperList, isCosbar)));
            } else {
                res.statusCode = 400;
                res.responseBody = Blob.valueOf('user does not exist.');
            }
        } catch (System.StringException e){
            RestContext.response.statusCode = 400;
            RestContext.response.responseBody = Blob.valueOf('Param: userId is not a valid Id');
        } catch (System.QueryException e){
            RestContext.response.statusCode = 404;
            RestContext.response.responseBody = Blob.valueOf('Requested User not found'+e);
        } catch (UnAuthorizedUserException e){
            res.statusCode = 500;
            res.responseBody = Blob.valueOf('User not authorized to access other users deatils');
        } catch (Exception e){ //something else happened
            RestContext.response.statusCode = 500;
            RestContext.response.responseBody = Blob.valueOf(e.getMessage());
        }
    }
  

    static UserCreateWrapper userToUserWrapper(User user, List<GroupMembersWrapper> members,Boolean isCosbar) {
        UserCreateWrapper userToSend = new UserCreateWrapper();
        userToSend.phone = user.Phone;
        userToSend.firstName = user.FirstName;
        userToSend.lastName = user.LastName;
        userToSend.email = user.Email;
        userToSend.country = user.Country;
        userToSend.name = user.Name;
        userToSend.fullPhotoUrl = user.FullPhotoUrl;
        //userToSend.regulatoryAuthority = authorityCodes;
        userToSend.title = user.Title;
        userToSend.role = user.UserRole.Name;
        userToSend.memberInspectors = members;

        return userToSend;
    }
    global class UserCreateWrapper{
        global UserCreateWrapper(){}
    	global String phone;  
    	global String website;    
        global String firstName;
        global String lastName;
        global String email;
        global String city;
        global String state;
        global String country;

        global String middleName;
        global String name;
        global String fullPhotoUrl;
        global String title;
        global String role;
        global System.Address address;
        global Boolean isCosbar;
       // global List<RegulatoryAuthorityWrapper> regulatoryAuthority;
        global List<GroupMembersWrapper> memberInspectors;
    } 

   // Wrapper Classes
  /**
     * @description : Wrapper Class which contains Member Inspectors object's manupulated data.
    */
    public class GroupMembersWrapper{
        public String id;    
        public String title;
        public String role;
        public String phone;  
        public String name;
        public String photoUrl;
        public String email;
        public  GroupMembersWrapper(User user){
            this.id = user.id;
            this.title = user.Title;
            this.role = user.UserRole.Name;
            this.phone =  user.Phone;
            this.name = user.name;
            this.photoUrl = user.FullPhotoUrl;
            this.email = user.Email;
        }
      }
}