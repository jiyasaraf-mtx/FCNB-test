/**
 * @description       : Batch class to schedule inpections based on inspetcion type and board.
 * @author            : Mohit Karani
 * @group             : 
 * @last modified on  : 05-22-2024
 * @last modified by  : Ayush Dev
**/
public with sharing class LPI_ScheduleInspectionsBatch implements Database.Batchable<sObject> {
    String regulatoryAuthorityId;
    String inspectionTypeId;
    LPI_InspectionConfig__mdt	mdtRec;
    String licenseId;
    private static final String ROUTINE_INSPECTION_TYPE = 'Routine';
    private static final String INSPECTION_PRIORITY_LOW = 'Low';
   // private static final String CLASSIFICATION_CLASS_H = 'Class H (Sterile Product Compounding)';
    

    String inspectionTypeName;

    public void setInspectionType(String inspectionTypeName) {
        this.inspectionTypeName = inspectionTypeName;
    }

    public static final Set<String> BOARD_NAME_TO_ASSIGN_INSPECOR_BY_COUNTY = new Set<String>{
        'Embalmers & Funeral Directors'
    };
    public static final Map<String,String> CIU_BOARD_NAME_TO_QUEUE_NAME = new  Map<String,String>{
        'Embalmers & Funeral Directors' => 'Embalmers_FD_Inspectors_Queue'
    };

    public LPI_ScheduleInspectionsBatch(String regulatoryAuthorityId,LPI_InspectionConfig__mdt	mdtRec,String inspectionTypeId,String licenseId) {
        this.regulatoryAuthorityId = regulatoryAuthorityId;
        this.mdtRec = mdtRec;
        this.inspectionTypeId = inspectionTypeId;
        this.licenseId = licenseId;
    }

    /**
    * @description : Method to fetch records based on board and inspection type.
    * @author Mohit Karani | 07-28-2023 
    * @param bc 
    * @return Database.QueryLocator 
    **/
    public Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'SELECT Id,RegulatoryAuthorizationType.IssuingDepartment.Name,AccountId,Classification__c,Last_Inspection_Date__c FROM BusinessLicense WHERE Status = \'' + LPI_LiteralConstant.BUSINESSLICENSE_STATUS_ACTIVE+'\' AND RegulatoryAuthorizationType.Authorisation_Type__c = \'' + LPI_LiteralConstant.BUSINESSLICENSE_APPTYPE + '\' AND RegulatoryAuthorizationType.IssuingDepartmentId = \''+ regulatoryAuthorityId + '\'' ;
        query = String.isNotBlank(licenseId) ? query + ' AND ID = \'' + licenseId + '\' WITH SECURITY_ENFORCED' : query + ' WITH SECURITY_ENFORCED';
        return Database.getQueryLocator(query);
    }

    /**
    * @description : Method to do processing on the list of records fetched.
    * @author Mohit Karani | 07-28-2023 
    * @param bc 
    * @param businessLicenseRecordsList 
    **/
    public void execute(Database.BatchableContext bc,List<BusinessLicense> businessLicenseRecordsList){
        Map<Id,BusinessLicense> idToBlMap = new Map<Id,BusinessLicense>(businessLicenseRecordsList);
        String boardName = idToBlMap.values()[0].RegulatoryAuthorizationType.IssuingDepartment.Name;
        String fields = 'Id,PlaceId,AuthorizationId, TYPEOF Place  WHEN Location THEN LocationType END';
        String whereClause = 'PlaceId != NULL AND Place.Type = \''+LPI_LiteralConstant.LOCATION_SOBJECT_NAME + '\' AND AuthorizationId IN ' +  LPI_ServiceUtility.getStringValuesBySet(idToBlMap.keySet());
        Set<String> locationIdSet = new Set<String> ();
        
        Map<String,String> appAuthBlIdToPlaceId = new Map<String,String>();
        for(AuthApplicationPlace authAppPlace : LPI_AuthApplicationPlaceDAO.getAuthApplicationPlaceByDymanicQueryWithoutSecurity(fields,whereClause,null,null,null)){
            locationIdSet.add(authAppPlace.PlaceId);
            appAuthBlIdToPlaceId.put(authAppPlace.Id + '-'+authAppPlace.AuthorizationId,authAppPlace.PlaceId);
        }
        if(locationIdSet.isEmpty()){
            return;
        }
        Map<Id,Schema.Address> locationIdToAddressRec = new Map<Id,Schema.Address>();
        Set<String> zipCodeSet = new Set<String>();
        fields = 'Id,PostalCode,ParentId,County__c,Parent.Status__c,City';
        whereClause = 'ParentId IN ' + LPI_ServiceUtility.getStringValuesByStringSet(locationIdSet) + ' AND LocationType = \'' + LPI_LiteralConstant.LOCATION_TYPE_BUSINESS_ADDRESS + '\'';
        for(Schema.Address addressRec : LPI_AddressDAO.getAddressByDymanicQuery(fields,whereClause,null,null,null)){
            if(addressRec.Parent.Status__c != LPI_LiteralConstant.LOCATION_STATUS_OPEN ){
                continue;
            }
            locationIdToAddressRec.put(addressRec.ParentId,addressRec);
            zipCodeSet.add(addressRec.PostalCode);
        }

        Map<String,Id> zipCodeToInspectorMapping = new Map<String,Id>();
        if(BOARD_NAME_TO_ASSIGN_INSPECOR_BY_COUNTY.contains(boardName)){
            Id inspectorPrepopulationRecId = Schema.SObjectType.County_ZipCode_Inspector_Mapping__c
			.getRecordTypeInfosByDeveloperName()
			.get(LPI_LiteralConstant.INSPECTOR_PREPOPULATION_RECORDTYPE)
			.getRecordTypeId();
            fields = 'ID,ZipCode__c,County__c,Inspector__c,Board_Name__c';
            whereClause = 'Board_Name__c = \'' +boardName+ '\''+' And RecordTypeId = \''+ inspectorPrepopulationRecId +'\' AND ZipCode__c IN ' +  LPI_ServiceUtility.getStringValuesByStringSet(zipCodeSet);
            for(County_ZipCode_Inspector_Mapping__c czim : LPI_CountyZipCodeInspectorMappingDao.getCountyZipCodeInspectorByDynamicQuery(fields,whereClause,null,null,null)){
                zipCodeToInspectorMapping.put(czim.ZipCode__c+'-'+czim.Board_Name__c,czim.Inspector__c);
                if(String.isNotBlank(czim.County__c)){
                    zipCodeToInspectorMapping.put(czim.ZipCode__c+'-'+czim.County__c+'-'+czim.Board_Name__c,czim.Inspector__c);
                }       
            }
        }
        Map<String,String> queueNameQueueIdMap = new Map<String,String>();
        if(CIU_BOARD_NAME_TO_QUEUE_NAME.containsKey(boardName)){
            whereClause = 'Type =  \'Queue\' AND DeveloperName =\'' + CIU_BOARD_NAME_TO_QUEUE_NAME.get(boardName) + '\'';
            fields = 'Id,DeveloperName';
            for(Group grp : LPI_GroupDAO.getGroups(fields,whereClause,null,null)){
                queueNameQueueIdMap.put(grp.DeveloperName,grp.Id);
            }
        }
        Integer month;
        Integer monthDate;
        Integer inspectionStartDay;
        Integer inspectionStartMonth;
        Integer inspectionStartYear;
        List<Visit> visitList = new List<Visit>();
        for(String keyString : appAuthBlIdToPlaceId.keySet()){
            if(!locationIdToAddressRec.containsKey(appAuthBlIdToPlaceId.get(keyString))){
                continue;
            }
            Visit visitRec = new Visit();
            visitRec.PlaceId = locationIdToAddressRec.get(appAuthBlIdToPlaceId.get(keyString)).Id;
            visitRec.ContextId = keyString.substringAfter('-');
            visitRec.Status = LPI_LiteralConstant.Inspection_Status_PLANNED;
            visitRec.AccountId = idToBlMap.get(keyString.substringAfter('-')).AccountId;
            visitRec.VisitTypeId = inspectionTypeId;
            inspectionStartDay = mdtRec.Start_Day__c != null ? (Integer)mdtRec.Start_Day__c : 1;
            inspectionStartMonth = mdtRec.Start_Month__c != null ? (Integer)mdtRec.Start_Month__c : 1;
            if(inspectionTypeName!=null && inspectionTypeName.equals(ROUTINE_INSPECTION_TYPE)) {
                visitRec.VisitPriority = INSPECTION_PRIORITY_LOW;
            } 
            Id inspectorId;
            if(BOARD_NAME_TO_ASSIGN_INSPECOR_BY_COUNTY.contains(boardName)){
                String key = (String.isBlank(locationIdToAddressRec.get(appAuthBlIdToPlaceId.get(keyString)).County__c) || ((locationIdToAddressRec.get(appAuthBlIdToPlaceId.get(keyString)).County__c == 'St. Louis City' || locationIdToAddressRec.get(appAuthBlIdToPlaceId.get(keyString)).County__c == 'St. Louis') && locationIdToAddressRec.get(appAuthBlIdToPlaceId.get(keyString)).City == 'St. Louis'))
                    ? locationIdToAddressRec.get(appAuthBlIdToPlaceId.get(keyString)).PostalCode + '-'+boardName 
                    : locationIdToAddressRec.get(appAuthBlIdToPlaceId.get(keyString)).PostalCode + '-'+locationIdToAddressRec.get(appAuthBlIdToPlaceId.get(keyString)).County__c + '-'+ boardName;
                //inspectorId = zipCodeToInspectorMapping.get(key);
                inspectorId = '005WF000001pDgz';
                visitRec.VisitorId = inspectorId;
            }
            if(CIU_BOARD_NAME_TO_QUEUE_NAME.containsKey(boardName)){
                Date todayDate = mdtRec.Test_Date__c != null ? mdtRec.Test_Date__c : Date.today();
                if(Math.mod(todayDate.year(), 2) == 0){
                    inspectionStartYear = todayDate.year()+1;
                }else if(Math.mod(todayDate.year(), 2) == 1){
                    Date ciuInspectionStartDate = Date.newInstance(todayDate.year(), inspectionStartMonth, inspectionStartDay);
                    if(todayDate > ciuInspectionStartDate){
                        inspectionStartYear = todayDate.year()+2;
                    }else{
                        inspectionStartYear = todayDate.year();
                    }
                }
                visitRec.OwnerId = queueNameQueueIdMap.containsKey(CIU_BOARD_NAME_TO_QUEUE_NAME.get(boardName)) ? queueNameQueueIdMap.get(CIU_BOARD_NAME_TO_QUEUE_NAME.get(boardName)) : null;
            }
  
            
            
                visitRec.PlannedVisitStartTime = Datetime.newInstance(inspectionStartYear, inspectionStartMonth, inspectionStartDay, 7, 0, 0);
                month = date.newinstance(inspectionStartYear, inspectionStartMonth, inspectionStartDay).addMonths(Integer.valueOf(mdtRec.Inspection_Duration_In_Months__c-1)).month();
                monthDate =  date.daysInMonth(date.newinstance(inspectionStartYear, inspectionStartMonth, inspectionStartDay).addMonths(Integer.valueOf(mdtRec.Inspection_Duration_In_Months__c-1)).year(),month);
                visitRec.PlannedVisitEndTime = Datetime.newInstance(date.newinstance(inspectionStartYear, inspectionStartMonth, inspectionStartDay).addMonths(Integer.valueOf(mdtRec.Inspection_Duration_In_Months__c-1)).year(),month,monthDate, 7, 0, 0);
            
            visitList.add(visitRec);
        }
        LPI_DML.doInsert(visitList);
    }


    /**
    * @description : Finish method for batch class.
    * @author Mohit Karani | 07-28-2023 
    * @param bc 
    **/
    public void finish(Database.BatchableContext bc) {

    }
}