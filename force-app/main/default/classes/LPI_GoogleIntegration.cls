/**
* @author              : MTX Group Product Team
* @since               : 12-Sep-2023
* @description         : This call is for callout to google for address validation
* @history
* -------------------------------------------------------------------------------------------------------
* Version         Date             Author                  Details
*    1         09-Jan-2023      MTX Group Product Team        	Initial Developement
* -------------------------------------------------------------------------------------------------------
*/
public with sharing class LPI_GoogleIntegration {
    
    /**
     * @author                      : MTX Group Product Team
     * @since                       : 12-Sept-2023
     * @description                 : verification and callout method for data
     */
    public static AddressValidationResultWrapper checkAddressValidation(String regionCode, String locality, List<String> addressLinesList){
        try{
            AddressValidationResultWrapper resultWrapper = new AddressValidationResultWrapper();
            resultWrapper.skipValidation = true;
            return resultWrapper;
        }catch(Exception ex) {
            LPI_ExceptionManager.logException('LPI_GoogleIntegration', 'checkAddressValidation', ex);
        }
        return null;
    }
    
    public class AddressValidationResultWrapper{
        public Double latitude;
        public Double longitude;
        public boolean addressValid;
        public boolean skipValidation;
        public AddressValidationResultWrapper(){
            this.latitude = null;
            this.longitude = null;
            this.addressValid = false;
            this.skipValidation = false;
        }
    }

  }