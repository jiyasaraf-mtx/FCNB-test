/**
 * @description       : Controller to create scheduled inspections.
 * @author            : Ramadevi Medoji
 * @group             :
 * @last modified on  : 07-12-2024
 * @last modified by  : Uzma Md
 **/

public with sharing class LPI_ScheduleInspections {

    private static final String LOCATION_STATUS_OPEN = 'Open';
    private static final String LOCATION_TYPE = 'Business Address';
    private static final String PLANNED_STATUS = 'Planned';
    private static final String VISIT_PRIORITY_MEDIUM = 'Medium';
    private static final String INSPECTION_REASON = 'Follow-up';
    private static final String INSPECTION_TYPE = 'Other';
    private static final String QUEUE_TYPE = 'Queue';
    private static final Set<String> ELIGIBLE_QUEUE_NAMES = new Set<String>{
        'Tattooing_Body_Piercing_Inspectors_Queue'
    };
    /**
    * @description : Method to create routine inspections.
    * @author Mohit Karani | 07-31-2023 
    * @param recordId 
    * @param inspectionType 
    **/
    @AuraEnabled
    public static void createRoutineInspections(
        String recordId,
        String inspectionType
    ) {
        try {
            System.debug('Record Id....'+recordId);
            System.debug('Insopection Type....'+inspectionType);
            List<RegulatoryAuthority> regulatoryAuthorityList = LPI_RegulatoryAuthorityDAO.getRegulatoryAuthorityByDymanicQuery(
                'Id, Name',
                'Id =\'' +
                String.escapeSingleQuotes(recordId) +
                '\'',
                null,
                null,
                null
            );
            System.debug('RAT>>>'+regulatoryAuthorityList);
            if (regulatoryAuthorityList.isEmpty()) {
                throw new LPI_Exception(
                    'Regulatory Authority record not found.'
                );
            }
            List<InspectionType> inspectionTypeList = LPI_InspectionTypeDAO.getInspectionTypeRecords(
                'Id, Name',
                'Name = \'' + String.escapeSingleQuotes(inspectionType) +  '\'',
                null,
                null
            );
            System.debug('Inspection Type>>>'+inspectionTypeList);
            if (inspectionTypeList.isEmpty()) {
                throw new LPI_Exception(
                    'No ' +
                    inspectionType +
                    ' configuration found for inspection type.'
                );
            }
            List<LPI_InspectionConfig__mdt> inspectionConfigList = LPI_CustomMetadataTypeDAO.getCustomMetaDataByDymanicQuery(
                'Id,Inspection_Duration_In_Months__c, Board_Name__c, Start_Day__c, Start_Month__c, Test_Date__c',
                'LPI_InspectionConfig__mdt',
                'Inspection_Type__c =  \'' +
                inspectionTypeList[0].Name +
                '\' AND Board_Name__c = \'' + regulatoryAuthorityList[0].Name + '\'',
                null,
                null,
                null
            );
            if (inspectionConfigList.isEmpty()) {
                throw new LPI_Exception(
                    'No configuration found to schedule inspections.'
                );
            }
            System.debug('Inspection Config>>>'+inspectionConfigList);
            LPI_ScheduleInspectionsBatch batch = new LPI_ScheduleInspectionsBatch(
                regulatoryAuthorityList[0].Id,
                inspectionConfigList[0],
                inspectionTypeList[0].Id,
                null
            );
            batch.setInspectionType(inspectionTypeList[0].Name);
            Database.executeBatch(batch);
        } catch (Exception e) {
            LPI_ExceptionManager.logException(
                'LPI_ScheduleInspections',
                'createRoutineInspections',
                e
            );
            throw new AuraHandledException(e.getMessage());
        }
    }
  
    /**
    * @description : Method to create scheduled inspections on license creation.
    * @author Vamsi Mudaliar | 11-27-2023 
    * @param List<Request>  
    **/
    // @InvocableMethod(
    //     label='Create Inspections'
    //     description='Used to Create Inspection from License after certain months of Issuance.'
    // )
    // public static List<Visit> createScheduledInspectionsFromLicense(List<Request> recordList) {
    //     try {

    //         Map<Id,Request> contextIdToRequestMap = new Map<Id,Request>();
    //         Map<Id,Schema.Address> contextIdToBusinessAddressMap = new Map<Id,Schema.Address>();
    //         Map<String,String> placeIdToLicenseIdMap = new Map<String,String>();
    //         List<Visit> inspectionListToInsert = new List<Visit>();

    //         for(Request req : recordList) {
    //             if(String.isNotBlank(req.contextId)) {
    //                 contextIdToRequestMap.put(req.contextId,req);
    //             }
    //         }
    //         if(contextIdToRequestMap.isEmpty()){
    //             return inspectionListToInsert;
    //         }

    //         String fields = 'Id,Contact.AccountId,Name';
    //         String whereClause = 'Id IN ' + LPI_ServiceUtility.getStringValuesBySet(contextIdToRequestMap.keySet());

    //         Map<Id,BusinessLicense> licenseIdToLicenseDetailsMap = new Map<Id,BusinessLicense>(LPI_BusinessLicenseDAO.fetchBusinessLicenseRecords(fields,whereClause));

    //         // Query for Authplace Record and pull out business address from the associated license.
    //         fields = 'Id,AuthorizationId,RgltyAuthApplicationId,PlaceId, TYPEOF Place  WHEN Location THEN LocationType,Status__c END';
    //         whereClause = ' AuthorizationId IN ' + LPI_ServiceUtility.getStringValuesBySet(contextIdToRequestMap.keySet());

    //         List<AuthApplicationPlace> authAppPlaceRecList = LPI_AuthApplicationPlaceDAO.getAuthApplicationPlaceByDymanicQuery(fields,whereClause,null,null,null);

    //         if(!authAppPlaceRecList.isEmpty()) {

    //             for(AuthApplicationPlace authplaceRec : authAppPlaceRecList) {
    //                 placeIdToLicenseIdMap.put(authplaceRec.PlaceId,authplaceRec.AuthorizationId);
    //             }
                
    //             fields = 'Id,Street,City,StateCode,Business_State__c,PostalCode,LocationType,ParentId,Parent.LocationType,Parent.Status__c';
    //             whereClause = 'ParentId IN '+ LPI_ServiceUtility.getStringValuesByStringSet(placeIdToLicenseIdMap.keySet()) +' AND Parent.Status__c = \'' + LOCATION_STATUS_OPEN +'\' AND Parent.LocationType = \'' + LOCATION_TYPE +'\'';

    //             // Get the Address Record 
    //             for(Schema.Address addressRec : LPI_AddressDAO.getAddressByDymanicQuery(fields,whereClause,null,null,null)) {
    //                 String licenseId =  placeIdToLicenseIdMap.get(addressRec.ParentId);
    //                 contextIdToBusinessAddressMap.put(licenseId,addressRec);
    //             }
    //         }

    //         // query inspection Type Record. 
    //         String inspectionTypeId = LPI_InspectionTypeDAO.getInspectionTypeRecords('Id,Name','Name =\'' + INSPECTION_TYPE + '\'',null,null)[0]?.Id;

    //         // query tattoo Queue
    //         String groupFields ='Id,DeveloperName,Type';
    //         String groupWhereClause = 'DeveloperName IN ' +LPI_ServiceUtility.getStringValuesByStringSet(ELIGIBLE_QUEUE_NAMES)+ ' AND Type=\''+QUEUE_TYPE+'\'';

    //         List<Group> grpList = new LPI_GroupDAO.LPI_GroupWithoutSharingDAO().getGroupByDymanicQueryWithoutSecurityEnforced(groupFields,groupWhereClause,null,null,null);
    //         Date todayDate = System.today();
    //         DateTime todayDateTime = System.now();
            
    //         for(Id contextId : contextIdToRequestMap.keySet()) {
    //             Request req = contextIdToRequestMap.get(contextId);

    //             if(contextIdToBusinessAddressMap.containsKey(contextId)) {
    //                 Visit visitRec = new Visit();
    //                 visitRec.ContextId = contextId;
    //                 visitRec.Status__c = PLANNED_STATUS;
    //                 visitRec.VisitPriority = VISIT_PRIORITY_MEDIUM;
    //                 visitRec.Board_Name__c = req.boardName;
    //                 visitRec.ActualVisitStartTime = todayDateTime;
    //                 visitRec.Date_Assigned__c = todayDate;
    //                 visitRec.Inspection_Reason__c = INSPECTION_REASON;
    //                 visitRec.VisitTypeId = inspectionTypeId;
    //                 visitRec.PlaceId = contextIdToBusinessAddressMap.get(contextId)?.Id;
    //                 visitRec.PlannedVisitStartTime = todayDateTime;
    //                 visitRec.AccountId = licenseIdToLicenseDetailsMap.containsKey(contextId) ? licenseIdToLicenseDetailsMap.get(contextId)?.Contact.AccountId : null;
    //                 visitRec.PlannedVisitEndTime = todayDateTime.addDays(30);
    //                 if(!grpList.isEmpty()) {
    //                     visitRec.OwnerId = grpList[0].Id;  
    //                 }
    //                 inspectionListToInsert.add(visitRec);
    //             }
    //         }

    //         if(!inspectionListToInsert.isEmpty()) {
    //             inspectionListToInsert = (List<Visit>) LPI_WithoutSharingUtility.insertSObjectList(inspectionListToInsert);
    //         }
    //         System.debug('Inspection To Insert>>'+inspectionListToInsert);
    //         return inspectionListToInsert;
    //     }
    //     catch(Exception ex) {
    //         LPI_ExceptionManager.logException(
    //             'LPI_ScheduleInspections',
    //             'createScheduledInspectionsFromLicense',
    //             ex
    //         );
    //     }
    //     return null;
    // }

    public class Request {
        @InvocableVariable(label='License Id' required=true)
		public String contextId;

        @InvocableVariable(label='Board Name' required=true)
		public String boardName;

        @InvocableVariable(label='License Issuance Date' required=true)
		public Date licenseIssuanceDate;
    }


}