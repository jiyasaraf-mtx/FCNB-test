/**
* @author                      : MTX Group Product Team
* @since                       : 
* @description                 : This class contains DAO methods for Profession object
* @last modified by            : MTX Group Product Team
* @last modified date          : (Add if modified by you)
* @last modified details       : (Add if modified by you)
*/
public with sharing class LPI_ProfessionDAO {
    /**
    * @author                      :MTX Group Product Team
    * @since                       : 
    * @description                 : This method return the List of Profession records by Dynamic query
    * @param  listOfFields         : list of fields for query
    * @param  limitValue           : Limit count
    * @param  sortingByFields      : Order by field API name
    * @param  sortingOrder         : Order for the Order By either ASC|DESC
    * @return                      : List<Profession__c>
    * @last modified by            : MTX Group Product Team
    * @last modified date          : (Add if modified by you)
    * @last modified details       : (Add if modified by you)
    */
    public static List<Profession__c> getProfessionByDymanicQuery(
        String fields,
        String whereClause,
        String limitValue,
        String sortingByFields,
        String sortingOrder
    ) {
        String query = 'SELECT '+ fields + ' FROM Profession__c ';
        if(whereClause != null){
            query += ' WHERE ' + whereClause + ' WITH SECURITY_ENFORCED ';
        }
        if (sortingByFields != null) {
            query += ' ORDER BY ' + sortingByFields;
            if (sortingOrder != null) {
                query += ' ' + sortingOrder + ' ';
            }
        }
        if (limitValue != null) {
            query += ' LIMIT ' + (limitValue != null ? limitValue : '50000');
        }
        return Database.query(query);
    }
}