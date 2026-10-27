/**
 * @description       :
 * @author            : MTX Group Product Team
 * @group             :
 * @last modified on  : 07-26-2024
 * @last modified by  : MTX Group Product Team
 **/
public with sharing class LPI_ProfileDao {
    /**
    * @description : Get Profile records.
    * @author MTX Group Product Team | 02-08-2023 
    * @param fields 
    * @param whereClause 
    * @param limitValue 
    * @param sortingByFields 
    * @param sortingOrder 
    * @return List<Profile> 
    **/
    public static List<Profile> getProfileByDymanicQuery(
        String fields,
        String whereClause,
        String limitValue,
        String sortingByFields,
        String sortingOrder
    ) {
        String query = 'SELECT ';
        query += fields;
        query += ' FROM Profile ';
        query += 'WHERE ' + whereClause ;
        if (sortingByFields != null) {
            query += ' ORDER BY ' + sortingByFields;
            if (sortingOrder != null) {
                query += ' ' + sortingOrder + ' ';
            }
        }
        limitValue = String.isNotBlank(limitValue) ? limitValue : '50000';
        query += ' LIMIT ' + limitValue;
        return Database.query(query);
    }
}