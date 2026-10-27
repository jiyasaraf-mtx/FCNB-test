/**
 * @author                          : Milanjeet Singh
 * @since                           : 23 Jan, 2023
 * @description                     : This class contains DAO methods for GroupMember Object
 * -------------------------------------------------------------------------------------------------------
 * Version      Date                Author                  Details
 *    1         23 Jan, 2023        Milanjeet Singh         Initial Developement
 * -------------------------------------------------------------------------------------------------------
 */
public with sharing class LPI_GroupMemberDAO {
    /**
     * @author                      : Milanjeet Singh
     * @since                       : 23 Jan, 2023
     * @description                 : This method is to get all the group members by group names provided
     * @return                      : returns List<GroupMember> records
     * @last modified by            : Ayush Dev
     * @last modified date          : (Add if modified by you)
     * @last modified details       : (Add if modified by you)
     */
    public static List<GroupMember> getGroupMembersByGroupNames(Set<String> setGroupNames){
        return [
            SELECT
                Id,
                UserOrGroupId,
                Group.Type,
                Group.Name,
                GroupId 
            FROM 
                GroupMember 
            WHERE
                Group.Name IN :setGroupNames
            WITH SECURITY_ENFORCED
        ];
    }
    /****************************************** Without Security SOQL STARTS **************************************************/

    /**
     * @description       : Without Security Inner class for GroupMember
     *                      
     * @author            : Nitesh Garg
     * @last modified on  : 05-06-2024
     * @last modified by  : Ayush Dev
    **/
    public without sharing class LPI_GroupMemberWithoutSharingDAO {
	
        /**
         * @author                      : Nitesh Garg
         * @since                       : 
         * @description                 : Dynamic Query Get GroupMember fields by different where clauses.
         * @param  fields             	: fields with (,) separated
         * @param  whereClause          : where condition (Ex: Name = 'Nitesh' AND Status = 'Active')
         * @param  limitValue          	: any limit otherwise pass null
         * @param  sortingByFields      : fields name from which you have to sort otherwise pass null
         * @param  sortingOrder      	: order of sorting (asc or desc) accept only two value otehr wise pass null
         * @last modified by            : Ayush Dev
         * @last modified date          : (Add if modified by you)
         * @last modified details       : (Add if modified by you)
         */
        public List<GroupMember> getGroupMemberByDymanicQuery(String fields,
                                                                                    String whereClause,
                                                                                    String limitValue,
                                                                                    String sortingByFields,
                                                                                    String sortingOrder){

            String query = 'SELECT ' + fields + ' FROM GroupMember WHERE ' + whereClause + ' WITH SECURITY_ENFORCED ';
            if(sortingByFields != null){
                query += ' ORDER BY ' + sortingByFields;
                if(sortingOrder != null){
                    query += ' ' + sortingOrder + ' ';
                }
            }                                                                             
            if(limitValue != null){
                query += ' LIMIT ' + (limitValue != null ? limitValue : '50000');
            }                                                                                                                                                       
            return Database.query(query);
        }
    }
}