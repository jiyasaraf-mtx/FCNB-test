/**
 * @description       : 
 * @author            : MTX Group Product Team
 * @group             : 
 * @last modified on  : 07-26-2024
 * @last modified by  : MTX Group Product Team
**/
public with sharing class LPI_AddressTriggerHelper {

   /**
   * @description This method will used to call queueable class to update Latitude and Longitude in Address Records
   * @author MTX Group Product Team | 05-06-2024 
   * @param recordsList 
   * @param mapOfOldRecords 
   **/
   public static void populateAddressLatitudeAndLongitude(
    List<Schema.Address> recordsList, Map<Id, Schema.Address> mapOfOldRecords
    ) {
        List<Schema.Address> addressRecListToUpdate = new List<Schema.Address>();
        for(Schema.Address addressRec : recordsList){
            if(addressRec.Do_not_populate_Lat_Long__c != null && addressRec.Do_not_populate_Lat_Long__c)  {
                continue;
            }
            if((mapOfOldRecords == NULL) || 
                (mapOfOldRecords != NULL && (mapOfOldRecords.get(addressRec.Id).CountryCode != addressRec.CountryCode ||
                mapOfOldRecords.get(addressRec.Id).City != addressRec.City ||
                mapOfOldRecords.get(addressRec.Id).Street != addressRec.Street ||
                mapOfOldRecords.get(addressRec.Id).PostalCode != addressRec.PostalCode))){
                    addressRecListToUpdate.add(addressRec);
            }
        }
    }
}