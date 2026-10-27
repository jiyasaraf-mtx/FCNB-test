/**
 * @author                      : MTX Group Product Team
 * @since                       : 21 June, 2023
 * @description                 : This Class contains DAO methods for LPI_Document_Action_Config__mdt Metadata
 * @last modified by            : MTX Group Product Team
*/
public with sharing class LPI_AppSubtypeOverrideMdtDAO {
    /**
      * @author                      : MTX Group Product Team
      * @since                       : 21 June, 2023
      * @description                 : Dynamic Query Get LPI_Document_Action_Config__mdt metaData records.
      * @param fields             	: fields with (,) separated
      * @param whereClause           : where condition (Ex: Name = 'Test' AND Status = 'Active') otherwise pass null
      * @param limitValue          	: any limit otherwise pass null
      * @param sortingByFields       : fields name from which you have to sort otherwise pass null
      * @param sortingOrder      	: order of sorting (asc or desc) accept only two value otehr wise pass null
      * @last modified by            : MTX Group Product Team
     */
     public static List<Application_SubType_Override_Metadata__mdt> getAppSubtypeOverrideByDymanicQuery(
         String fields,
         String whereClause,
         String limitValue,
         String sortingByFields,
         String sortingOrder
     ) {
         String query = 'SELECT ';
         query += fields;
         query += ' FROM Application_SubType_Override_Metadata__mdt ';
         if (whereClause != null) {
             query += 'WHERE ' + whereClause;
         }
         if (sortingByFields != null) {
             query += ' ORDER BY ' + sortingByFields;
             if (sortingOrder != null) {
                 query += ' ' + sortingOrder + ' ';
             }
         }
         query += ' LIMIT ' + (String.isNotBlank(limitValue) ? limitValue : '50000');
         return Database.query(query);
     }
 }