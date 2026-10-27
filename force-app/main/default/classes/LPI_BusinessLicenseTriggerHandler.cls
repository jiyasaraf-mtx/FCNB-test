/**
 * @description       : 
 * @author            : MTX Group Inc
 * @group             : 
 * @last modified on  : 07-26-2024
 * @last modified by  : MTX Group Product Team
**/
public class LPI_BusinessLicenseTriggerHandler extends LPI_TriggerHandler{
    public override void beforeInsert() {
	}
	public override void beforeUpdate() {
		List<BusinessLicense> recordsList = (List<BusinessLicense>) Trigger.New;
		Map<Id, BusinessLicense> mapOfOldRecords = (Map<Id, BusinessLicense>) Trigger.oldMap;
		LPI_BusinessLicenseTriggerHelper.populateInactivationDateOnBLInactivation(recordsList, mapOfOldRecords);
		LPI_BusinessLicenseTriggerHelper.updateLicenseSubStatusOnStatusChange(recordsList,mapOfOldRecords);
	}
	public override void afterInsert() {
		List<BusinessLicense> recordsList = (List<BusinessLicense>) Trigger.New;
		LPI_BusinessLicenseTriggerHelper.updateBlJson(recordsList, null);
		LPI_BusinessLicenseTriggerHelper.updateRenewalPeriodFields(recordsList);
	}
	public override void afterUpdate() {

		List<BusinessLicense> recordsList = (List<BusinessLicense>) Trigger.New;
		Map<Id, BusinessLicense> mapOfOldRecords = (Map<Id, BusinessLicense>) Trigger.oldMap;
        List<BusinessLicense> parentLicenseActiveList = new List<BusinessLicense>();
		List<BusinessLicense> parentLicenseInActiveList = new List<BusinessLicense>();
		List<BusinessLicense> expiryDateUpdatedList = new List<BusinessLicense>();
		List<BusinessLicense> aliasNameUpdateList = new List<BusinessLicense>();
		Set<String> setOfConfiguredParentNames = new Set<String>();
		Set<String> setOfblRats = new Set<String>();
		for (BusinessLicense blRecord : recordsList) {
			if(String.isNotEmpty(blRecord.RegulatoryAuthorizationTypeId)) {
				setOfblRats.add(blRecord.RegulatoryAuthorizationTypeId);
			}
		}
		if(!setOfblRats.isEmpty()){
			String queryFields = 'Id,Parent_License_Type__c';
			String whereClause = ' Parent_License_Type__c IN '+  LPI_ServiceUtility.getStringValuesByStringSet(setOfblRats);
			LPI_RelationshipConfigurationsDAO.LPI_WithoutShareingRelationshipConfigDAO relationshipConfigurations = new LPI_RelationshipConfigurationsDAO.LPI_WithoutShareingRelationshipConfigDAO();

			for(Relationship_Configuration__c config : relationshipConfigurations.getRelationConfigsByDymanicQuery(queryFields,whereClause,null,null)) {
				setOfConfiguredParentNames.add(config.Parent_License_Type__c);
			}
		}
        LPI_BusinessLicenseTriggerHelper.updateBlJson(
			recordsList,
            mapOfOldRecords
        );

		LPI_BusinessLicenseTriggerHelper.getPortalNotificationOnChangeOfField(recordsList, mapOfOldRecords);

		LPI_BusinessLicenseTriggerHelper.manageBusinessLicenseExpiry(recordsList, mapOfOldRecords);
        LPI_BusinessLicenseTriggerHelper.updateAccountNamesonBlNameChange(recordsList, mapOfOldRecords);
		for(BusinessLicense blRecord : recordsList){
			if (blRecord.Status != mapOfOldRecords.get(blRecord.Id).Status){
				if(setOfConfiguredParentNames.contains(blRecord.RegulatoryAuthorizationTypeId)){
					if(blRecord.Status == LPI_LiteralConstant.STATUS_ACTIVE) {
						parentLicenseActiveList.add(blRecord);
					}else if(blRecord.Status != LPI_LiteralConstant.STATUS_ACTIVE){
						parentLicenseInActiveList.add(blRecord);
					}
				}
			}
			if (blRecord.periodEnd != null && blRecord.periodEnd != mapOfOldRecords.get(blRecord.Id).periodEnd){
				expiryDateUpdatedList.add(blRecord);
			}
			
			if (
				mapOfOldRecords != null && 
				(
					(String.isNotBlank(blRecord.Name_of_the_Professional_Corporation__c) &&
					blRecord.Name_of_the_Professional_Corporation__c != mapOfOldRecords.get(blRecord.Id).Name_of_the_Professional_Corporation__c) ||
					(String.isNotBlank(blRecord.Doing_Business_As_DBA_or_Trade_Name__c) &&
					blRecord.Doing_Business_As_DBA_or_Trade_Name__c != mapOfOldRecords.get(blRecord.Id).Doing_Business_As_DBA_or_Trade_Name__c) ||
					(String.isNotBlank(blRecord.Business_Name__c) &&
					blRecord.Business_Name__c != mapOfOldRecords.get(blRecord.Id).Business_Name__c)
				)
			) {
				aliasNameUpdateList.add(blRecord);
			}
		}
		
		if(!expiryDateUpdatedList.isEmpty()){
			LPI_BusinessLicenseTriggerHelper.updateRenewalPeriodFields(expiryDateUpdatedList);
		}
		
		if(!aliasNameUpdateList.isEmpty()){
			LPI_BusinessLicenseTriggerHelper.createAndUpdateAliasRecords(aliasNameUpdateList, mapOfOldRecords);
		}
		
		LPI_BusinessLicenseTriggerHelper.updateCalculatedExpiryDate(recordsList, mapOfOldRecords);
    }
}