/**
* @description       : 
* @author            : MTX Group Product Team
* @group             : 
* @last modified on  : 07-26-2024
* @last modified by  : MTX Group Product Team
**/
public with sharing class LPI_ExaminationDAO {
    
    /**
    * @author                      :MTX Group Product Team
    * @since                       : 
    * @description                 : Dynamic Query Get Examination fields by different where clauses.
    * @param  fields             	: fields with (,) separated
    * @param  whereClause          : where condition (Ex: Name = 'Nandirudra' AND Status = 'Active')
    * @param  limitValue          	: any limit otherwise pass null
    * @param  sortingByFields      : fields name from which you have to sort otherwise pass null
    * @param  sortingOrder      	: order of sorting (asc or desc) accept only two value otehr wise pass null
    * @last modified by            : MTX Group Product Team
    * @last modified on            : 07-26-2024
    */
   public static List<Examination> getExaminationByDynamicQuery(String fields,
   String whereClause,
   String limitValue,
   String sortingByFields,
   String sortingOrder){
       
       String query = 'SELECT ';
       query += fields;
       query += ' FROM Examination ';
       query += 'WHERE ' + whereClause + ' WITH SECURITY_ENFORCED ';
       if(sortingByFields != null){
           query += ' ORDER BY ' + sortingByFields;
           if(sortingOrder != null){
               query += ' ' + sortingOrder + ' ';
           }
       }                                                                             
       query += ' LIMIT ' + (limitValue != null ? limitValue : '50000');                                                                                                                                                       
       return Database.query(query);
   }
    /**
	 * @author                      : MTX Group Product Team
	 * @since                       : 26 May, 2023
	 * @description                 : Dynamic Query Get Examination fields by different where clauses.
	 * @param  fields               : fields with (,) separated
	 * @param  whereClause          : where condition (Ex: Name = 'Vamsi' AND Status = 'Active')
	 * @last modified by            : MTX Group Product Team
	 * @last modified on            : 07-26-2024
	 */
	public static List<Examination> getExaminationByDynamicQuery(
		String fields,
		String whereClause){
		return getExaminationByDynamicQuery(fields, whereClause, null, null, null);
	}
}