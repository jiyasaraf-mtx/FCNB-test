/**
 * @description       :
 * @author            : Mohit Karani
 * @group             :
 * @last modified on  : 09-25-2023
 * @last modified by  : Mohit Karani
 **/
public with sharing class LPI_ContentDocumentLinkTriggerHelper {
	//Declare a set of sObjects on the class constants like:
	public static final Set<String> SOBJECT_FOR_ACCESS = new set<String>{
		'Application_Document__c',
		'Account',
		'AVR_Filing__c'
	};
    public final static string REG_AUTH_TYPE_SOBJECT_NAME = 'RegulatoryAuthorizationType';
    public final static string REG_AUTH_SOBJECT_NAME = 'RegulatoryAuthority';
    public final static string REG_AUTH_CONTENT = 'Regulatory_Authorization_Content__c';
    public final static List<String> SOBJECT_TYPE_LIST_FOR_WEBPULL = new List<String>{
        REG_AUTH_TYPE_SOBJECT_NAME,REG_AUTH_SOBJECT_NAME,REG_AUTH_CONTENT
    };

    /**
     * @description : Method to create Public Link(For WEB PULLS funtionality)when a file has been added to the RegulatoryAuthorizationType.
     * @author Mohit Karani | 02-08-2023
     * @param newList
     **/
    public static void createPublicLink(List<ContentDocumentLink> newList) {
		if (!checkForProfile(LPI_LiteralConstant.PROFILE_NAME_SET)) {
            return;
        }
        Set<String> contentDocIdSet = new Set<String>();
        Map<String, String> contentDocumentIdtoLinkedEntityId = new Map<String, String>();
        for (ContentDocumentLink cdl : newList) {
            // If file is not attached with a RegulatoryAuthorizationType/RegulatoryAuthority record then skip;
            if ( cdl.LinkedEntityId.getSObjectType() == NULL ||
                !SOBJECT_TYPE_LIST_FOR_WEBPULL.contains(
                    cdl.LinkedEntityId.getSObjectType().getDescribe().getName()
                )
            ) {
                continue;
            }
            contentDocumentIdtoLinkedEntityId.put(
                cdl.ContentDocumentId,
                cdl.LinkedEntityId
            );
        }
        // If no document matches criteria then return
        if (contentDocumentIdtoLinkedEntityId.isEmpty()) {
            return;
        }
        String fields = 'ID,Title,ContentDocumentId,FileType';
        String whereClause =
            'ContentDocumentId IN ' +
            LPI_ServiceUtility.getStringValuesByList(
                new List<String>(contentDocumentIdtoLinkedEntityId.keySet())
            );
        List<ContentDistribution> contentDistributionList = new List<ContentDistribution>();
        Map<String, String> contentVersionIdToContentDocumentId = new Map<String, String>();
        Map<Id, ContentVersion> idToCvMap = new Map<Id, ContentVersion>();
        // Fetch content version records by ContentDocumentId to create ContentDistribution records.
        for (
            ContentVersion cv : LPI_ContentVersionDAO.getContentVersionByDymanicQuery(
                fields,
                whereClause,
                null,
                null,
                null
            )
        ) {
            ContentDistribution newDist = createContentDistribution(cv);
            contentDistributionList.add(newDist);
            contentVersionIdToContentDocumentId.put(
                cv.Id,
                cv.ContentDocumentId
            );
            idToCvMap.put(cv.Id, cv);
        }
        // insert contentDistribution records.
        contentDistributionList = (List<contentDistribution>) LPI_WithoutSharingUtility.upsertSObjectList(
            contentDistributionList
        );
        List<Id> contentDistributionIdList = new List<Id>();
        // Add Ids to a list to query contentDistribution back to fetch ContentDownloadUrl.
        for (
            contentDistribution contentDistributionRec : contentDistributionList
        ) {
            contentDistributionIdList.add(contentDistributionRec.Id);
        }
        fields = 'ID,ContentDownloadUrl,ContentVersionId';
        whereClause =
            ' ID IN ' +
            LPI_ServiceUtility.getStringValuesByList(
                contentDistributionIdList
            );
        List<RegulatoryAuthorizationType> regAuthTypeList = new List<RegulatoryAuthorizationType>();
        List<RegulatoryAuthority> regAuthList = new List<RegulatoryAuthority>();
        List<Regulatory_Authorization_Content__c> regAuthContentList = new List<Regulatory_Authorization_Content__c>();
        // query inserted contentDistribution records along with ContentDownloadUrl to update the ContentDownloadUrl on the  RegulatoryAuthorizationType record on which file has been uploaded.
        Id linkedEntityId;
        SObject sobjectRec;
        String fileUrl;
        for (
            ContentDistribution contentDistributionRec : LPI_ContentDistributionDao.getContentDistributionByDymanicQuery(
                fields,
                whereClause,
                null,
                null,
                null
            )
        ) {
            // If linkedentity id not found for the uploaded file then skip
            if (
                !contentVersionIdToContentDocumentId.containsKey(
                    contentDistributionRec.ContentVersionId
                ) ||
                !contentDocumentIdtoLinkedEntityId.containsKey(
                    contentVersionIdToContentDocumentId.get(
                        contentDistributionRec.ContentVersionId
                    )
                )
            ) {
                continue;
            }
            // Fetch linked entity id.
            linkedEntityId = contentDocumentIdtoLinkedEntityId.get(
                contentVersionIdToContentDocumentId.get(
                    contentDistributionRec.ContentVersionId
                )
            );
            // Update id and Webpull_File_Url__c on the record.
            sobjectRec = linkedEntityId.getSObjectType()
                .newSObject(linkedEntityId);
            fileUrl =
                contentDistributionRec.ContentDownloadUrl +
                LPI_LiteralConstant.FILE_NAME_DELIMINITER +
                idToCvMap.get(contentDistributionRec.ContentVersionId).Title +
                '.' +
                idToCvMap.get(contentDistributionRec.ContentVersionId).FileType;
            sobjectRec.put('Id', linkedEntityId);
           
            // If linked entity is of RegulatoryAuthorizationType
            if (
                linkedEntityId.getSObjectType().getDescribe().getName() ==
                LPI_LiteralConstant.REG_AUTH_TYPE_SOBJECT_NAME
            ) {
                sobjectRec.put('Webpull_File_Url__c', fileUrl);
                regAuthTypeList.add((RegulatoryAuthorizationType) sobjectRec);
            } // If linked entity is of RegulatoryAuthority
            else if (
                linkedEntityId.getSObjectType().getDescribe().getName() ==
                LPI_LiteralConstant.REG_AUTH_SOBJECT_NAME
            ) {
                sobjectRec.put('Webpull_File_Url__c', fileUrl);
                regAuthList.add((RegulatoryAuthority) sobjectRec);
            }
            else if(linkedEntityId.getSObjectType().getDescribe().getName() == REG_AUTH_CONTENT){
                sobjectRec.put('Description__c', contentDistributionRec.ContentDownloadUrl);
                regAuthContentList.add((Regulatory_Authorization_Content__c) sobjectRec);
            }
        }
		LPI_WithoutSharingUtility.updateSObjectList(regAuthTypeList);
		LPI_WithoutSharingUtility.updateSObjectList(regAuthList);
        if(!regAuthContentList.isEmpty()){
            LPI_WithoutSharingUtility.updateSObjectList(regAuthContentList);
        }
    }

    /**
     * @description : Method to create ContentDistribution record.
     * @author Mohit Karani | 02-08-2023
     * @param cv
     * @return ContentDistribution
     **/
    public static ContentDistribution createContentDistribution(
        ContentVersion cv
    ) {
        ContentDistribution newDist = new ContentDistribution();
        newDist.ContentVersionId = cv.Id;
        newDist.Name = 'External Link for ' + cv.Title;
        newDist.PreferencesNotifyOnVisit = false;
        newDist.PreferencesAllowViewInBrowser = true;
        newDist.PreferencesAllowOriginalDownload = true;
        return newDist;
    }

    public static Boolean checkForProfile(List<String> profileSet){
        String fields = 'Id,Name';
        String whereClause =
            'Name IN ' +
            LPI_ServiceUtility.getStringValuesByList(
                profileSet
            );
        Map<Id, Profile> idToProfileMap = new Map<Id, Profile>(
            LPI_ProfileDao.getProfileByDymanicQuery(
                fields,
                whereClause,
                null,
                null,
                null
            )
        );
        // If current user's profile does not matches with the user profiles that should be allowed to create public link then return.
        if (!idToProfileMap.containsKey(UserInfo.getProfileId())) {
            return false;
        }
        return true;
	}

	/**
	* @description : Method to update Visibility on CDL
	* @author Rahul Ameta | 07-10-2023
	* @param newList
	**/
	public static void updateVisibilityToAllUser(List<ContentDocumentLink> newList) {
        try {
			for(ContentDocumentLink cdLink : newList){
                if (cdLink.LinkedEntityId == null) {
                    continue;
                }
				String objectType = cdLink.LinkedEntityId.getSObjectType().getDescribe().getName();
				if(SOBJECT_FOR_ACCESS.contains(objectType)){
					cdLink.Visibility = 'AllUsers';
                    if (String.isBlank(cdLink.ShareType)) {
                        cdLink.ShareType = 'V';
                    }
				}
			}
        } catch (Exception e) {
            LPI_ExceptionManager.logException(
                'LPI_ContentDocumentLinkTriggerHelper',
                'linkDocumentToPortalUser',
                e
            );
        }
    }
     /**
     * @description : Method to make Description__c field on Regulatory_Authorization_Content__c to blank when related File is deleted.
     * @author Kishore | 14-11-2023
     * @param List<ContentDocumentList>
     * @return void
     **/
    public static void beforeDelete(List<ContentDocumentLink> oldList){
        if (!checkForProfile(LPI_LiteralConstant.PROFILE_NAME_SET)) {
            return;
        }
        Schema.SObjectType rac = Schema.getGlobalDescribe().get('Regulatory_Authorization_Content__c');
        SObject sobjectRec = rac.newSObject();

        List<Regulatory_Authorization_Content__c> regAuthContentList = new List<Regulatory_Authorization_Content__c>();        
        for (ContentDocumentLink cdl : oldList) {
            // If file is not attached with a RegulatoryAuthorizationType/RegulatoryAuthority record then skip;
            if (cdl.LinkedEntityId.getSObjectType() != NULL &&
                cdl.LinkedEntityId.getSObjectType().getDescribe().getName() == REG_AUTH_CONTENT)
            {   
                sobjectRec.put('Id', cdl.LinkedEntityId);
                sobjectRec.put('Description__c', null);
                regAuthContentList.add((Regulatory_Authorization_Content__c) sobjectRec);
            }
        }
        if(!regAuthContentList.isEmpty()){
            LPI_WithoutSharingUtility.updateSObjectList(regAuthContentList);
        }
    }
}