/**
* @author                      : Neeraj Mani Sai
* @since                       : 13 Sep, 2023
* @description                 : This class is used to update Latitude and Longitude in Address Records
* @last modified by            : MTX Group Inc
* @last modified date          :
* @last modified details       :
*/
public with sharing class LPI_PopulateAddressLongAndLatQueueble implements Queueable, Database.AllowsCallouts{
    private List<Schema.Address> addressList;
    public LPI_PopulateAddressLongAndLatQueueble(List<Schema.Address> addressList) {
        this.addressList = addressList;
    }
    /**
    * @author                      : Neeraj Mani Sai
    * @since                       : 13 Sep, 2023
    * @description                 : Execute method used to update Latitude and Longitude in Address Records
    * @last modified by            : MTX Group Inc
    * @last modified date          :
    * @last modified details       :
    */
    public void execute(QueueableContext context) {
        /*try{
            List<Schema.Address> addressListToUpdate = new List<Schema.Address>();
            Schema.Address addressRecToUpdate;
            
            LPI_AddressValidationIntegration.AddressValidationResultWrapper resultWrap = new LPI_AddressValidationIntegration.AddressValidationResultWrapper();

            for(Schema.Address addressRec : addressList){
                //Get validated and return the latitude and logitude values
                String addressConcat = addressRec.Street + ' ' + addressRec.City + ' ' + addressRec.State + ' ' + addressRec.CountryCode + ' ' + addressRec.PostalCode;
                String modifiedAddress = addressConcat.replaceAll(',', '');
                String finalAddress = modifiedAddress.replaceAll(' ', '+');
                resultWrap = LPI_AddressValidationIntegration.checkAddressValidation(
                    addressRec.City, addressRec.CountryCode, finalAddress
                        );
                //check if address is valid
                if(resultWrap.addressValid){
                    //Since the records are getting locked in insert, We are creating instance and populating the values
                    addressRecToUpdate = new Schema.Address(Id = addressRec.Id);
                    addressRecToUpdate.Longitude = resultWrap.longitude;
                    addressRecToUpdate.Latitude = resultWrap.latitude;
                    addressListToUpdate.add(addressRecToUpdate);
                }
            }

            LPI_TriggerHandler.bypass('LPI_AddressTriggerHandler');
            if (LPI_TriggerHandler.isBypassed('LPI_AddressTriggerHandler')) {
                LPI_DML.doUpdate(addressListToUpdate);
            }
            LPI_TriggerHandler.clearBypass('LPI_AddressTriggerHandler');
        }catch(Exception ex){
            LPI_ExceptionManager.logException('LPI_PopulateAddressLongAndLatQueueble', 'executeMethod', ex);
        }*/
    }
}