/**
 * @description       : DAO for InspectionType
 * @author            : MTX Group Product Team
 * @group             : 
 * @last modified on  : 07-26-2024
 * @last modified by  : MTX Group Product Team
**/
public with sharing class LPI_InspectionTypeDAO {
    /**
    * @description : Method to fetch InspectionType records.
    * @author MTX Group Product Team | 01-22-2023 
    * @param fieldsToQuery 
    * @param whereClause 
    * @param limitValue 
    * @param orderByClause 
    * @return List<InspectionType> 
    **/
    public static List<InspectionType> getInspectionTypeRecords(String fieldsToQuery,String whereClause,String limitValue,String orderByClause){
        String query = 'SELECT '+ fieldsToQuery;
        query += ' FROM InspectionType';
        query += ' WHERE ' + whereClause; 
        if(String.isNotBlank(orderByClause)){
            query += ' ORDER BY  ' + orderByClause ;
        }
        limitValue = String.isNotBlank(limitValue) ? limitValue : '50000';         
        query += ' LIMIT ' +  limitValue;      
       
        return Database.query(query);
    }
}