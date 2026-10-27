/**
 * @author            : MTX Group Product Team
 * @description       : This class is used to populate where Longitude and Latitude are missing in Address Records
 * -------------------------------------------------------------------------------------------------------
 * Version      Date                Author                  Details
 *    1         15 Sep, 2023        MTX Group Product Team         Initial Developement
 * -------------------------------------------------------------------------------------------------------
 * @last modified by  : MTX Group Product Team
**/
global with sharing class LPI_PopulateAddressLongAndLatBatch implements Database.Batchable<sObject>, Database.AllowsCallouts,Database.Stateful {    
	 private final static String LOCATION_TYPE_BUSINESS = 'Business Address';
	// List<Schema.Address> addressListToUpdate = new List<Schema.Address>();

    /**
	 * @author                      : MTX Group Product Team
	 * @since                       :
	 * @description                 : Start Method to populate Latitude and Longitude on the legacy Address records
	 * @return                      :
	 * @last modified by            : MTX Group Product Team
	 * @last modified date          :
	 * @modified details            :
	 */
	global Database.QueryLocator start(Database.BatchableContext bc) {
		return Database.getQueryLocator(
			'SELECT Id, Parent.Status__c, CountryCode, Street, City, PostalCode, State, Latitude, Longitude from Address WHERE (Latitude = NULL OR Longitude = NULL)'+
			' AND Parent.LocationType =\''+LOCATION_TYPE_BUSINESS+'\''
		);
	}
	/**
	 * @author                      : Neeraj Mani Sai
	 * @since                       :
	 * @description                 : Execute method that calls queueable class to populate Lat and Long on Address
	 * @return                      :
	 * @last modified by            : MTX Group Product Team
	 * @last modified date          :
	 * @modified details            :
	 */
    global void execute(Database.BatchableContext bc, List<Schema.Address> addressList){
       // System.enqueueJob(new LPI_PopulateAddressLongAndLatQueueble(addressList));
        
    }
    /**
	 * @author                      : Neeraj Mani Sai
	 * @since                       :
	 * @description                 : Finish method of the batch class
	 * @return                      :
	 * @last modified by            : MTX Group Product Team
	 * @last modified date          :
	 * @modified details            :
	 */
    global void finish(Database.BatchableContext bc) {
		
	}
}