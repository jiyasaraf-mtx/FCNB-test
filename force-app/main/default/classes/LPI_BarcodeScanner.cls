/**
 *
 * @author          :  MTX Group Product Team
 * @description     : This class is used as helper for scanner component
 * @history
 * -------------------------------------------------------------------------------------------------------
 * Version      Date                Author                  Details
 *    1         19 Oct, 2023         MTX Group Product Team            Initial Developement
 * -------------------------------------------------------------------------------------------------------
 */
public class LPI_BarcodeScanner{
   
    /**
	 * @description : Get BusinessLicense record Id from license numbers
	 * @author  MTX Group Product Team
	 **/
    @AuraEnabled
    public static String getLicenseIdFromNumber(String licenseNumber) {
            List<BusinessLicense> blList = LPI_BusinessLicenseDAO.fetchBusinessLicenseRecords(
                'Id',
                'Name = ' +
                '\'' + licenseNumber  + '\'' 
            );
            String urlRecord =  blList.isEmpty() ? null : URL.getSalesforceBaseUrl().toExternalForm() + '/' + blList[0].Id;
            return urlRecord;
    }
}