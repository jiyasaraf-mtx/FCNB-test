/**
 * @description       :
 * @author            : Rahul Ameta
 * @group             :
 * @description       : This Class will Auto Populate application URl while creating New Application_Flow_Config record.
 * @last modified on  : 05-09-2024
 * @last modified by  : MTX Group Inc
 **/
public with sharing class LPI_ApplicationFlowConfigTriggerHelper {
    /**
     * @description       :
     * @author            : Rahul Ameta
     * @description       : This method will Auto Populate application URl while creating New Application_Flow_Config record.
     * @last modified on  : 05-09-2024
     * @last modified by  : MTX Group Inc
     **/
    public static void populateApplicationURL(
        Map<Id, Application_Flow_Config__c> mapOfOldRecords,
        List<Application_Flow_Config__c> recordsList
    ) {
        List<String> setOfIntakeFormId = new List<String>();
        //try{
            for (Application_Flow_Config__c config : recordsList) {
                if (
                    config.Application_Flow__c != null &&
                    (mapOfOldRecords == null ||
                    (config.Application_Flow__c !=
                    mapOfOldRecords.get(config.Id).Application_Flow__c))
                ) {
                    setOfIntakeFormId.add(config.Application_Flow__c);
                }
            }
            if (setOfIntakeFormId.isEmpty()) {
                return;
            }
            String omniFields = ' Id, Type, SubType, Language ';
            String whereOmniClause = ' Id IN '+ LPI_ServiceUtility.getStringValuesByList(setOfIntakeFormId) ;
            List<OmniProcess> omniList = LPI_OmniProcessDAO.getOmniProcessByDymanicQuery(omniFields,whereOmniClause, null,null,null);
            Map<Id, OmniProcess> mapOS = new Map<Id, OmniProcess>(omniList);

            String whereClause = ' Name = \'' + String.escapeSingleQuotes(Label.SiteNameLabel) + '\'';
            List<Site> site =  LPI_SiteDAO.getSiteByDymanicQuery('Id',whereClause,'1',null,null);
            String whereSiteClause = ' DurableId = \'' + String.escapeSingleQuotes(site[0].Id) + '\'';
            List<SiteDetail> siteDetailList = LPI_SiteDetailDAO.getSiteDetailByDymanicQuery('SecureURL',whereSiteClause,null,null,null);
            String communityUrl = siteDetailList[0].SecureUrl;
            for (Application_Flow_Config__c config : recordsList) {
                if (
                    config.Application_Flow__c != null &&
                    (mapOfOldRecords == null ||
                    (config.Application_Flow__c !=
                    mapOfOldRecords.get(config.Id).Application_Flow__c))
                ) {
                    OmniProcess objOS = mapOS.get(config.Application_Flow__c);
                    // OmniStudio compiled LWC names drop non-alphanumeric chars
                    // (e.g. Multi-Language -> MultiLanguage).
                    String name = (objOS.Type + objOS.SubType + objOS.Language).replaceAll('[^A-Za-z0-9]', '');
                    name = name.substring(0, 1).toLowerCase() + name.substring(1);
                    config.Application_URL__c =
                        communityUrl +
                        '/s/apply-license?c__layout=lightning&c__tabIcon=custom:custom18&c__target=c:' +
                        name +
                        '&ContextId=' +
                        config.Regulatory_Authorization_Type__c;
                }
            }
        /*}
        catch (Exception e) {
            LPI_ExceptionManager.logException(
				'LPI_ApplicationFlowConfigTriggerHelper',
				'populateApplicationURL',
				e
			);
        }*/
    }
}