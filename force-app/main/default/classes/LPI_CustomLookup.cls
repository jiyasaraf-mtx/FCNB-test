/**
 * @author          : Nitesh garg
 * @description     : This Class contains logic for custom lookup
 * -------------------------------------------------------------------------------------------------------
 * Version      Date                Author                  Details
 *    1                             Nitesh garg    Initial Developement
 * -------------------------------------------------------------------------------------------------------
 */
public with sharing class LPI_CustomLookup {

    private static final String ADDRESS_OBJ_NAME = 'Address';
   //private static final String INSPECTORS_PROFILE_TXT = 'Inspectors';
   // private static final String BOARD_STAFF_PROFILE_TXT = 'Board Staff';

    public static final String USER_OBJ_SEARCH = 'User-Visit';
    public static final String USER_OBJ_API_NAME = 'User';
    //private static final String BOARD_STAFF_LIKE_INSPECTOR = 'Board_Staff_with_Exclusive_Inspection';
   //private static final String INS_SUPERVISOR_ROLE = 'Inspector Supervisor';

    private static final String BOARD_STAFF_INSP_SUPER_CP = 'Board_Staff_Inspector_Supervisor_Custom_Permission';
    private static final String BOARD_STAFF_INT_BOARD_ADMIN_CP = 'Board_Staff_Internal_Board_Admin_Custom_Permission';
    
    public static final List<String> OBJECTS_TO_EXCLUDE_SECURITY_ENFORCED = new List<String>{
        'User'
    };
    public static final List<String> PROFILES_TO_EXCLUDE = new List<String>{
        'Portal User',
        'Support Staff'
    };
    private static Set<String> INCLUDE_FILTER_USER_PROFILE_SET = new Set<String> {
        'Inspectors',
        'System Administrator'
    };
    public static final String USER_OBJ_DUEDILIGENCE_SEARCH = 'User-DueDiligence';
    public static final List<String> PROFILES_TO_INCLUDE_DUE_DILIGENCE = new List<String>{
        'Board Staff'
    };

    /**
     * @author          : Nitesh Garg
     * @BuildDate       : 3rd Nov, 2022
     * @description     : used in customLookUp lwc for search feature
     * @params          : string recordId , string sObjectApiName
     * @return          : sObject
     */
    @AuraEnabled
    public static LookupWrapper fetchDefaultUserRecord(string recordId, string sObjectApiName) {
        try {
            string sRecId = recordId;
            string sQuery;
            if(sObjectApiName == USER_OBJ_SEARCH){
                sObjectApiName = USER_OBJ_API_NAME;
                sQuery = 'SELECT Id,Name FROM '+ sObjectApiName  +  ' WHERE Id = :sRecId';
            }
            else if(sObjectApiName == ADDRESS_OBJ_NAME){
                sQuery = 'SELECT Id,Street,State,City,County__c,PostalCode FROM ' + sObjectApiName ;
                sQuery += ' WHERE Id = :sRecId';
            }
            else if(sObjectApiName == USER_OBJ_DUEDILIGENCE_SEARCH){
                sObjectApiName = USER_OBJ_API_NAME;
                sQuery = 'SELECT Id,Name FROM '+ sObjectApiName  +  ' WHERE Id = :sRecId AND Profile.Name IN : PROFILES_TO_INCLUDE_DUE_DILIGENCE';
            }
            else{
                sQuery = 'SELECT Id,Name FROM ' + sObjectApiName + ' WHERE Id = :sRecId';
            }

            if(!OBJECTS_TO_EXCLUDE_SECURITY_ENFORCED.contains(sObjectApiName)){
                sQuery += ' WITH SECURITY_ENFORCED';
            }
            sQuery += ' LIMIT 1';
            for (sObject obj : database.query(String.escapeSingleQuotes(sQuery))) {
                if(sObjectApiName == ADDRESS_OBJ_NAME){
                    String add = ((String)obj.get('Street') != null ? (String)obj.get('Street') : '') + 
                                        ((String)obj.get('City') != null ? ' , '+(String)obj.get('City') : '' )+
                                                ((String)obj.get('State') != null ? ' , '+ (String)obj.get('State') : '' )+
                                                    ((String)obj.get('County__c') != null ? ' , '+ (String)obj.get('County__c') : '' )+
                                                        ((String)obj.get('PostalCode') != null ? ' , '+ (String)obj.get('PostalCode'): '');
                    return new LookupWrapper((String)obj.get('Id'),add);
                }else{
                    return new LookupWrapper((String)obj.get('Id'),(String)obj.get('Name'));
                }
            }
            return null;
        } catch (Exception e) {
            LPI_ExceptionManager.logException('LPI_CustomLookup', 'fetchDefaultUserRecord', e);
            throw new AuraHandledException(e.getMessage());
        }
    }
    /**
     * @author          : Nitesh Garg
     * @BuildDate       : 3rd Nov, 2022
     * @description     : used to fetch user based on key from lwc
     * @params          : string searchKey , string sObjectApiName
     * @return : list<sObject>
     */
    @AuraEnabled(cacheable=true)
    public static list<LookupWrapper> fetchLookupUserData(string searchKey, string sObjectApiName) {
        try {
            // Do not add SECURITY_ENFORCED for setup objects.
            List<LookupWrapper> returnList = new List<LookupWrapper>();
            string sWildCardText = '%' + String.escapeSingleQuotes(searchKey) + '%';
            string sQuery;
            if(sObjectApiName == ADDRESS_OBJ_NAME){
                sQuery = 'SELECT Id,Street,State,City,County__c,PostalCode FROM ' + sObjectApiName ;
                sQuery += ' WHERE (State LIKE :sWildCardText OR City LIKE :sWildCardText OR Street LIKE :sWildCardText OR PostalCode LIKE :sWildCardText)';
                
            }else if(sObjectApiName == USER_OBJ_SEARCH){
                sObjectApiName = USER_OBJ_API_NAME;
                sQuery = 'SELECT Id,Name FROM '+ sObjectApiName +
                ' WHERE Name LIKE : sWildCardText AND Profile.Name NOT IN : PROFILES_TO_EXCLUDE AND IsActive = true';
            }
            else if(sObjectApiName == USER_OBJ_DUEDILIGENCE_SEARCH){
                sObjectApiName = USER_OBJ_API_NAME;
                sQuery = 'SELECT Id,Name FROM '+ sObjectApiName  +  ' WHERE Name LIKE : sWildCardText AND Profile.Name IN : PROFILES_TO_INCLUDE_DUE_DILIGENCE AND IsActive = true';
            }
            else{
                sQuery = 'SELECT Id,Name FROM ' + sObjectApiName +
                ' WHERE Name LIKE : sWildCardText';
            }

            if(!OBJECTS_TO_EXCLUDE_SECURITY_ENFORCED.contains(sObjectApiName)){
                sQuery += ' WITH SECURITY_ENFORCED';
            }
            sQuery += ' ORDER BY createdDate DESC LIMIT 5';
            for (sObject obj : database.query(String.escapeSingleQuotes(sQuery))) {
                if(sObjectApiName == ADDRESS_OBJ_NAME){
                    String add = ((String)obj.get('Street') != null ? (String)obj.get('Street') : '') + 
                                        ((String)obj.get('City') != null ? ' , '+(String)obj.get('City') : '' )+
                                            ((String)obj.get('State') != null ? ' , '+ (String)obj.get('State') : '' )+
                                                ((String)obj.get('County__c') != null ? ' , '+ (String)obj.get('County__c') : '' )+
                                                    ((String)obj.get('PostalCode') != null ? ' , '+ (String)obj.get('PostalCode'): '');
                    returnList.add(new LookupWrapper((String)obj.get('Id'),
                    add));
                }else{
                    returnList.add(new LookupWrapper((String)obj.get('Id'),(String)obj.get('Name')));
                }
                
            }
            return returnList;
        } catch (Exception e) {
            LPI_ExceptionManager.logException('LPI_CustomLookup', 'fetchLookupUserData', e);
            throw new AuraHandledException(e.getStackTraceString());
        }
    }
    /**
     * @author          : Vamsi Mudaliar
     * @BuildDate       : 23th November
     * @description     : used to fetch Users Specific to Board.
     * @params          : string searchKey
     * @return : list<sObject>
     */
    @AuraEnabled 
    public static List<LookupWrapper> fetchInspectorSpecificToBoard(String searchKey,String boardName) {
        try {
            List<LookupWrapper> resultList = new List<LookupWrapper>();
            string sWildCardText = '%' + String.escapeSingleQuotes(searchKey) + '%';
            String userIdPrefix = Schema.SObjectType.User.getKeyPrefix();
            Set<Id> userIdSet = new Set<Id>();
            String groupType = 'Regular';

            // When board is known, prefer members of the mapped public group(s).
            // Blank board (common on complaint Cases) falls through to profile-based search.
            if(String.isNotBlank(boardName)) {
                Map<String, Object> groupDetails =  (Map<String,Object>) JSON.deserializeUntyped(System.Label.CIU_Boards_To_Group_Mappings);
                Set<String> grpDevNameSet = new Set<String>();

                Map<String,Object> ciuBoardMap = (Map<String,Object>)groupDetails.get('CIUBoards');
                Map<String,Object> otherBoardsMap = (Map<String,Object>)groupDetails.get('OtherBoards');

                if(otherBoardsMap?.containsKey(boardName)) {
                    grpDevNameSet.add((String)otherBoardsMap.get(boardName));
                } 
                else if(ciuBoardMap?.containsKey(boardName)) {
                    grpDevNameSet.add((String)ciuBoardMap.get(boardName));
                }
                else if(ciuBoardMap != null) { 
                    for(String key : ciuBoardMap.keySet()) {
                        grpDevNameSet.add((String)ciuBoardMap.get(key));
                    }
                }

                if(!grpDevNameSet.isEmpty()) {
                    String fields = 'Id,Group.DeveloperName,UserOrGroupId';
                    String whereClause = '( Group.DeveloperName IN ' +LPI_ServiceUtility.getStringValuesByStringSet(grpDevNameSet);
                    
                    if(String.isNotBlank(groupType)) {
                        whereClause+= ' AND Group.Type = \'' + groupType + '\' )';
                    } else {
                        whereClause+= ')';
                    }
                    for(GroupMember grpMember : new LPI_GroupMemberDAO.LPI_GroupMemberWithoutSharingDAO().getGroupMemberByDymanicQuery(fields,whereClause,null,null,null)) {
                        if(grpMember.UserOrGroupId!=null && String.valueOf(grpMember.UserOrGroupId)?.startsWith(userIdPrefix)) { // starts with 005
                            userIdSet.add(grpMember.UserOrGroupId);
                        }
                    }
                }
            }

            String fields = 'Id,Name,Profile.Name,UserRole.Name';
            String whereClause;
            // Prefer board group members. If board is blank or the mapped group is empty,
            // fall back to active Inspectors / System Administrators so complaint create still works.
            if(userIdSet.isEmpty()) {
                whereClause = ' Name LIKE \''+ sWildCardText + '\' AND IsActive = true AND Profile.Name IN '
                    + LPI_ServiceUtility.getStringValuesByStringSet(INCLUDE_FILTER_USER_PROFILE_SET);
            } else {
                whereClause = ' Name LIKE \''+ sWildCardText + '\' AND IsActive = true AND ( ( Id IN '
                    + LPI_ServiceUtility.getStringValuesBySet(userIdSet)
                    + ' AND Profile.Name IN '
                    + LPI_ServiceUtility.getStringValuesByStringSet(INCLUDE_FILTER_USER_PROFILE_SET)
                    + ') OR Profile.Name = \'System Administrator\' ) ';
            }

            for(User usr : new LPI_UserDao.LPI_UserWithoutSharingDAO().getUserByDymanicQuery(fields,whereClause,null,null,null)) {
                resultList.add(new LookupWrapper(usr.Id,usr.Name)); 
            }

            return resultList;
        }
        catch(Exception ex) {
            LPI_ExceptionManager.logException('LPI_CustomLookup', 'fetchInspectorSpecificToBoard', ex);
            throw new AuraHandledException(ex.getStackTraceString());
        }
    }



     /**
     * @author          : Nitish
     * @BuildDate       : 17rd Oct, 2023
     * @description     : used to fetch Institution records based on key from lwc
     * @params          : string searchKey
     * @return : list<sObject>
     */
    @AuraEnabled(cacheable=true)
    public static List<InstitutionWrapper> fetchInstitutionDetails(string searchKey,Boolean searchById) {
        try {
            List<InstitutionWrapper> returnList = new List<InstitutionWrapper>();
            string sWildCardText = '%' + String.escapeSingleQuotes(searchKey) + '%';
            String fields = 'Id, Institution_Name__c, Institution_With_Address__c, Street_Address__c, City__c, State__c, Country__c, Zip_Code__c';
            String whereClause;
            if(searchById){
                whereClause = 'Id = \'' + String.escapeSingleQuotes(searchKey) + '\'';
            } else {
                whereClause = 'Institution_With_Address__c LIKE \'' + sWildCardText + '\'';
            }
            
            for (Institution__c institution : LPI_InstitutionDAO.getInstitutionByDymanicQuery(
                    fields,
                    whereClause,
                    '100',
                    null,
                    null
                )
            ) {
                returnList.add(new InstitutionWrapper(institution));
            }
            return returnList;
        } catch (Exception e) {
            LPI_ExceptionManager.logException('LPI_CustomLookup', 'fetchInstitutionDetails', e);
            throw new AuraHandledException(e.getStackTraceString());
        }
    }

    public class LookupWrapper {
        @AuraEnabled
        public String Id;
        @AuraEnabled
        public String Name;
        
        public LookupWrapper(String Id,String Name){
            this.Id = Id;
            this.Name = Name;
        }
    }

    public class InstitutionWrapper {
        @AuraEnabled
        public String Id;
        @AuraEnabled
        public String InstitutionName;
        @AuraEnabled
        public String Name;
        @AuraEnabled
        public String Street;
        @AuraEnabled
        public String City;
        @AuraEnabled
        public String State;
        @AuraEnabled
        public String Country;
        @AuraEnabled
        public String Zipcode;
        
        public InstitutionWrapper(Institution__c institution){
            this.Id = institution.Id;
            this.InstitutionName = institution.Institution_Name__c;
            this.Name = institution.Institution_With_Address__c;
            this.Street = institution.Street_Address__c;
            this.City = institution.City__c;
            this.State = institution.State__c;
            this.Country = institution.Country__c;
            this.Zipcode = institution.ZIP_Code__c;
        }
    }
    
}