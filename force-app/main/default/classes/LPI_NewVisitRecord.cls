/**
 * @description       :
 * @author            : MTX Group Product Team
 * @group             :
 * @last modified on  : 06-11-2024
 * @last modified by  : MTX Group Product Team
 **/
public with sharing class LPI_NewVisitRecord {
    private static final String CASE_OBJ = 'Case';
    private static final String VISIT_OBJ = 'Visit';
    private static final String US_COUNTRY_CODE = 'US';
    public static final List<String> INSPECTION_TYPES_LIST = new List<String>{
        'Adhoc Inspection'
    };
    
    private static final Set<String> RESULT_VALUES_SET = new Set<String>{
        'Violation',
        'No Violation',
        'N/A'
    };
    
    private static final String ADHOC_INSPECTION = 'Adhoc Inspection';
    private static final String ADDITIONAL_INSPECTION = 'Additional Inspection';
    private static final String BUSINESS_LICENSE = 'BusinessLicense';
    private static final String INDIVIDUAL_APPLICATION = 'IndividualApplication';
    private static final String BUSINESS_LICENSE_APPLICATION = 'BusinessLicenseApplication';
    private final static String IN_PROGRESS = 'InProgress';
    private final static String INSPECTOR = 'Inspectors';
    public static final String INSPECTOR_SUPERVISOR_ROLE = 'Inspector_Supervisor';
   
    public static final String INSPECTION_TYPE_REASON_DEPENDENCY_METADATA_NAME = 'InspectionTypeDependency';
    public static final String LOCATION_STATUS_OPEN = 'Open';
    public static final String LOCATION_TYPE = 'Business Address';
    public static final String ROUTINE_INSPECTION_TYPE = 'Routine';
    public static final String SUPERVISOR_ROLE = 'Inspector Supervisor';

    /**
     * @author          : MTX Group Product Team
     * @BuildDate       :
     * @description     : used to fetchPicklist(Generic Method)
     */
    public static List<SelectOptionWrapper> fetchPicklist(
        String objectName,
        String fieldName,
        Boolean includeNone
    ) {
        List<SelectOptionWrapper> optionList = new List<SelectOptionWrapper>();
        Schema.SObjectType s = Schema.getGlobalDescribe().get(objectName);
        Schema.DescribeSObjectResult r = s.getDescribe();
        Map<String, Schema.SObjectField> fields = r.fields.getMap();
        Schema.DescribeFieldResult fieldResult = fields.get(fieldName)
            .getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        if (includeNone) {
            optionList.add(new SelectOptionWrapper(null, '--None--'));
        }
        for (Schema.PicklistEntry pickListVal : ple) {
            optionList.add(
                new SelectOptionWrapper(
                    pickListVal.getValue(),
                    pickListVal.getLabel()
                )
            );
        }
        return optionList;
    }

    /**
    * @description 
    * @author MTX Group Product Team | 05-06-2024 
    * @return Map<String, Object> 
    **/
    private static Map<String,Object> getAdhocVisitDetail() {

        Map<String,Object> responseMap = new Map<String,Object>();
        responseMap.put(
            'locationType',
            fetchPicklist('Location', 'LocationType', false)
        );
        responseMap.put(
            'stateOptions',
            fetchPicklist('Account', 'PersonOtherStateCode', false)
        );
        List<InspectionType> inspectionTypeList= LPI_InspectionTypeDAO.getInspectionTypeRecords('Id',
                'Name = \''+ADHOC_INSPECTION+'\'',
                null,null
        );

        if(inspectionTypeList.isEmpty()) {
            throw new LPI_Exception('Couldnt Find Adhoc Inspection Type');
        }
        responseMap.put('inspectionType',inspectionTypeList[0]?.Id);
        responseMap.put('showCase', false);
        responseMap.put('otherRecQuickAction',false);
        Map<String,String> profileRoleMap = getUserProfileAndRoleName();
        responseMap.put('userRole',profileRoleMap.get('userRole'));
        responseMap.put('profileName',profileRoleMap.get('profileName'));
        responseMap.put('userName',profileRoleMap.get('userName'));
        
        return responseMap;
    }

    /**
    * @description : Method to fetch visit record details.
    * @author MTX Group Product Team | 06-09-2023 
    * @param recordId 
    * @param isAdhocInspection
    * @return Map<String, Object> 
    **/
    @AuraEnabled
    public static Map<String, Object> getRecordDetail(Id recordId, Boolean isAdhocInspection,Boolean isAddtionalInspection) {
        try {
            if(isAdhocInspection!=null && isAdhocInspection && (isAddtionalInspection==null || !isAddtionalInspection)) {
                return getAdhocVisitDetail();
            }
            String sObjName = recordId.getSObjectType().getDescribe().getName();
            Map<String, Object> responseMap = new Map<String, Object>();
            List<SelectOptionWrapper> inspectionTypeSelectList = new List<SelectOptionWrapper>();
            List<SelectOptionWrapper> resultSelectList = new List<SelectOptionWrapper>();
            Map<String,String> profileRoleMap = getUserProfileAndRoleName();
            String insWhereClause = 'Name NOT IN '+LPI_ServiceUtility.getStringValuesByList(INSPECTION_TYPES_LIST);
            Map<Id,InspectionType> idToInspectionType = new Map<Id,InspectionType>( LPI_InspectionTypeDAO.getInspectionTypeRecords(
                'Id,Name',
                insWhereClause ,
                null,null
            ));
            for(Id inspectionTypeRecId :idToInspectionType.keySet())  {
                SelectOptionWrapper obj = new SelectOptionWrapper(idToInspectionType.get(inspectionTypeRecId).Name,idToInspectionType.get(inspectionTypeRecId).Name);
                obj.recordId = inspectionTypeRecId;
                inspectionTypeSelectList.add(obj);
            }
            responseMap.put('userRole',profileRoleMap.get('userRole'));
            responseMap.put('profileName',profileRoleMap.get('profileName'));
            responseMap.put(
                'vistPriority',
                fetchPicklist('Visit', 'VisitPriority', false)
            );
            responseMap.put(
                'visitStatus',
                fetchPicklist('Visit', 'Status__c', false)
            );
            responseMap.put(
                'inspectionType',
                inspectionTypeSelectList
            );
            responseMap.put(
                'recurrenceOptions',
                fetchPicklist('Visit', 'Recurrence__c', false) 
            );
            responseMap.put(
                'visitDiscipline',
                fetchPicklist('Visit', 'Discipline__c', false)
            );
            responseMap.put(
                'locationType',
                fetchPicklist('Location', 'LocationType', false)
            );
            responseMap.put(
                'stateOptions',
                fetchPicklist('Account', 'PersonOtherStateCode', false)
            );
            responseMap.put(
                'inspectionReasonAll',
                fetchPicklist('Visit', 'Inspection_Reason__c', false)
            );
            responseMap.put(
                'subreasonValue',
                fetchPicklist('Visit', 'Sub_Reason__c', false)
            );
            List<LPI_InspectionConfig__mdt> inspsectionReasonList = LPI_CustomMetadataTypeDAO.getCustomMetaDataByDymanicQuery('Inspection_Types_Dependencies__c','LPI_InspectionConfig__mdt', 'DeveloperName = \''+ INSPECTION_TYPE_REASON_DEPENDENCY_METADATA_NAME + '\'' ,null,null,null);
            if(!inspsectionReasonList.isEmpty()){
                responseMap.put(
                        'inspectionReason',inspsectionReasonList[0].Inspection_Types_Dependencies__c
                );
                    responseMap.put(
                        'inspectionReasonToSort',true
                    );
            }
            for(SelectOptionWrapper records : fetchPicklist('Visit','Final_Assessment_Result__c',false)) {
                if(RESULT_VALUES_SET.contains(records.value)) {
                    resultSelectList.add(records);
                }
            }
            responseMap.put('otherRecQuickAction',true);
            responseMap.put('getContextId',recordId);
            String queryFields = 'Id,Account.Name,AccountId';
            String whereClause = 'Id = \'' + String.escapeSingleQuotes(recordId) +'\'';
            
            if (sObjName == CASE_OBJ) {
                List<Case> caseRec = LPI_CaseDAO.getCaseRecords(
                    'Id,Case_Number__c,Board_Name__c,License_Type__c,AccountId,Account.Name,Business_License_Id__c,Subject',
                    'Id = \'' +
                    String.escapeSingleQuotes(recordId)+
                    '\'',
                    '1',
                    null
                );
                if (!caseRec.isEmpty()) {
                    String boardName = caseRec[0].Board_Name__c;
                    String ratName = caseRec[0].License_Type__c;
                    Boolean isUnlicensedComplaint = String.isNotBlank(caseRec[0].Subject)
                        && caseRec[0].Subject.containsIgnoreCase('UNLICENSED');
                    // Fall back to linked Business License when Case board/license were never populated from the complaint.
                    if((String.isBlank(boardName) || String.isBlank(ratName)) && String.isNotBlank(caseRec[0].Business_License_Id__c)) {
                        List<BusinessLicense> blRecList = LPI_BusinessLicenseDAO.fetchBusinessLicenseRecordsWithOrderByLimit(
                            'Id,RegulatoryAuthorizationType.IssuingDepartment.Name,RegulatoryAuthorizationType.Name',
                            'Id = \'' + String.escapeSingleQuotes(caseRec[0].Business_License_Id__c) + '\'',
                            null,
                            null
                        );
                        if(!blRecList.isEmpty()) {
                            if(String.isBlank(boardName)) {
                                boardName = blRecList[0]?.RegulatoryAuthorizationType?.IssuingDepartment?.Name;
                            }
                            if(String.isBlank(ratName)) {
                                ratName = blRecList[0]?.RegulatoryAuthorizationType?.Name;
                            }
                        }
                    }
                    responseMap.put('contextName',caseRec[0].Case_Number__c);
                    responseMap.put('showCase',true);
                    responseMap.put('showVisit',false);
                    responseMap.put('boardName',boardName);
                    responseMap.put('ratName',ratName);
                    // Licensed complaints missing RAT need a picker; unlicensed complaints use default complaint tasks.
                    responseMap.put('requireLicenseTypeSelection', String.isBlank(ratName) && !isUnlicensedComplaint);
                    responseMap.put('vAccount',caseRec[0].AccountId);
                    responseMap.put('accName',caseRec[0].Account.Name);
                }
            } else if (sObjName == VISIT_OBJ) {
                List<String> fields = new List<String>{
                    'Id',
                    'PlaceId',
                    'VisitPriority',
                    'Status__c',
                    'AccountId',
                    'ContextId',
                    'Discipline__c',
                    'Comments__c',                    
                    'VisitorId',
                    'VisitTypeId',
                    'Inspection_Reason__c',
                    'ActualVisitStartTime',
                    'License_Type__c',
                    'Final_Assessment_Result__c',
                    'Recurrence__c',
                    'Remedial_Action_Sent__c',
                    'Unable_to_Inspect__c',
                    'Remedial_Response_Due__c',
                    'Remedial_response_received__c',
                    'Closed_Date__c',
                    'Actual_End_Date__c','Planned_Start_Date__c','Planned_End_Date__c, Board_Name__c','Description__c','Inspection_Forms__c','Name_of_Licensee_Applicant_Representativ__c','Title__c',
                    'Licensee_Applicant_Rep_Signed_Date__c', 'Inspector_Signed_Date__c', 'Attestation_by_Licensee_Applicant_Rep__c', 'Trigger_Site_Survey_Email_Notification__c',
                    '(SELECT ID, IsRequired, Status FROM AssessmentTasks WHERE IsRequired=true AND Status != \''+LPI_LiteralConstant.Inspection_Status_COMPLETED+'\' )',
                    'TYPEOF Context WHEN Case THEN Case_Number__c WHEN IndividualApplication THEN Name END'
                };
                List<Visit> visitRec = LPI_VisitControllerDAO.getVistListByDynamicQuery(
                    fields,
                    'Id = \'' +
                    recordId +
                    '\'',
                    1,
                    null,
                    null
                );

                if (!visitRec.isEmpty()) {
                    List<InspectionType> inspectionTypeList= LPI_InspectionTypeDAO.getInspectionTypeRecords('Id',
                        'Name = \''+ADHOC_INSPECTION+'\'',
                        null,null
                    );
                    responseMap.put('isAdhocVisit',false);
                    if(!inspectionTypeList.isEmpty() && visitRec[0]?.VisitTypeId==inspectionTypeList[0].Id && 
                            (isAddtionalInspection==null || !isAddtionalInspection)) {
                        responseMap.put('isAdhocVisit',true);
                        responseMap.put('inspectionType',ADHOC_INSPECTION);
                        List<RegulatoryAuthorizationType> regAuthList = LPI_RegulatoryAuthorizationTypeDAO.getRegulatoryAuthorizationTypeByDymanicQuery(
                            'Id,Name,IssuingDepartment.name',
                            ' Name = \''+ String.escapeSingleQuotes(visitRec[0]?.License_Type__c) +'\'' ,
                            null,null,null
                        );
                        responseMap.put('licenseId',regAuthList[0]?.Id);
                        responseMap.put('boardName',regAuthList[0]?.IssuingDepartment.name);
                    }
                    VisitWrapper visitData = new VisitWrapper(
                        visitRec[0].Id,
                        visitRec[0].PlaceId,
                        visitRec[0].VisitPriority,
                        visitRec[0].Status__c,
                        visitRec[0].AccountId,
                        visitRec[0].Board_Name__c,
                        visitRec[0].ContextId,
                        null,
                        idToInspectionType.get(visitRec[0].VisitTypeId)?.Name,
                        visitRec[0].Planned_Start_Date__c,
                        visitRec[0].Discipline__c,
                        visitRec[0].Comments__c,                
                        visitRec[0].VisitorId,
                        visitRec[0].VisitTypeId,
                        visitRec[0].Inspection_Reason__c,
                        visitRec[0].ActualVisitStartTime,
                        visitRec[0].Actual_End_Date__c,
                        visitRec[0].Remedial_Action_Sent__c,
                        visitRec[0].Remedial_Response_Due__c,
                        visitRec[0].Remedial_response_received__c
                    );
                    if(isAddtionalInspection!=null && isAddtionalInspection && visitData.vInspectionType ==ADHOC_INSPECTION) {
                        visitData.vInspectionType = null;
                    }
                    if(responseMap.containsKey('isAdhocVisit') && Boolean.valueOf(responseMap.get('isAdhocVisit'))) {
                        visitData.vInspectionType = ADHOC_INSPECTION;
                    }
                    visitData.vPlannedEndTime = visitRec[0].Planned_End_Date__c;
                    visitData.recurrence = visitRec[0].Recurrence__c;
                    visitData.result = visitRec[0].Final_Assessment_Result__c;
                    visitData.visitDesc = visitRec[0].Description__c;
                    visitData.inspectionForms = visitRec[0].Inspection_Forms__c;
                    visitData.triggerSiteSurveyEmailNotification = visitRec[0].Trigger_Site_Survey_Email_Notification__c;
                    visitData.nameOfLicenseeRep = visitRec[0].Name_of_Licensee_Applicant_Representativ__c;
                    visitData.title = visitRec[0].Title__c;
                    visitData.attestation = visitRec[0].Attestation_by_Licensee_Applicant_Rep__c;
                    visitData.licenseeSignedDate = visitRec[0].Licensee_Applicant_Rep_Signed_Date__c;
                    visitData.inspectorSignedDate = visitRec[0].Inspector_Signed_Date__c;
                    visitData.unableToInspect = visitRec[0].Unable_to_Inspect__c;
                    
                    if (visitRec[0].Context instanceof Case) {
                        Case cs = visitRec[0].Context;
                        visitData.contextName = cs.Case_Number__c;
                        visitData.isComplaintsVisit = true;
                    } else {
                        visitData.contextName = visitRec[0].Context.Name;
                        if(String.isNotBlank(visitRec[0].License_Type__c)) {
                            visitData.licenseTypeName = visitRec[0].License_Type__c;
                            
                        }
                    }
                    if(isAddtionalInspection!=null && isAddtionalInspection) {
                        visitData.vPlannedEndTime = null;
                        visitData.vPlannedStartTime = null;
                        visitData.vStatus = null;
                        visitData.vActualEndTime = null;
                        visitData.vActualStartTime = null;
                    }
                    responseMap.put('ratName',visitRec[0].License_Type__c);
                    responseMap.put('visitRec', visitData);
                    responseMap.put('showCase', false);
                    responseMap.put('showVisit', true);
                    responseMap.put('otherRecQuickAction',false);
                    responseMap.put('fromVisitDetail', true);
                    responseMap.put('isCurrentUserInspector',checkIfCurrentUserIsInspector(recordId));
                    responseMap.put('hasIncompleteTasks',!visitRec[0].AssessmentTasks.isEmpty());
                    responseMap.put('boardName',visitRec[0].Board_Name__c);
                }
            } else if(sObjName == BUSINESS_LICENSE) {
                List<BusinessLicense> blRecList = LPI_BusinessLicenseDAO.fetchBusinessLicenseRecords(
                    'Id,Account.Name,AccountId,RegulatoryAuthorizationType.IssuingDepartment.Name, RegulatoryAuthorizationType.Name',
                    whereClause
                );
                if(!blRecList.isEmpty()) {
                    responseMap.put('accName',blRecList[0]?.Account.Name);
                    responseMap.put('vAccount',blRecList[0].AccountId);
                    responseMap.put('boardName',blRecList[0]?.RegulatoryAuthorizationType.IssuingDepartment.Name);
                    responseMap.put('ratName',blRecList[0].RegulatoryAuthorizationType.Name);
                }
            } else if(sObjName == BUSINESS_LICENSE_APPLICATION) {
                List<BusinessLicenseApplication> blaList = LPI_BusinessLicenseApplicationDAO.getBusinessLicenseApplicationByDymanicQuery(
                    'Id,Account.Name,AccountId,LicenseType.Name, LicenseType.IssuingDepartment.Name',whereClause,null,null,null
                );
                if(!blaList.isEmpty()) {
                    responseMap.put('accName',blaList[0]?.Account.Name);
                    responseMap.put('vAccount',blaList[0].AccountId);
                    responseMap.put('boardName',blaList[0]?.LicenseType.IssuingDepartment.Name);
                    responseMap.put('ratName',blaList[0].LicenseType.Name);
                }
            }
            if(responseMap.get('boardName') == 'Nursing'){
               
            }else{
                responseMap.put(
                    'optionsForResult',
                    resultSelectList
                );
            }
            if(sObjName!=VISIT_OBJ) {
                populateDefaultAddressBasedOnContext(responseMap);
            }
            responseMap.put('displayInspectorField', !LPI_ScheduleInspectionsBatch.CIU_BOARD_NAME_TO_QUEUE_NAME.containsKey((String)responseMap.get('boardName')) || 
                                                        (
                                                            (String)responseMap.get('boardName') != 'Pharmacy' && 
                                                            LPI_ScheduleInspectionsBatch.CIU_BOARD_NAME_TO_QUEUE_NAME.containsKey((String)responseMap.get('boardName')) && 
                                                                (responseMap.get('profileName') == LPI_LiteralConstant.ADMIN_PROFILE || responseMap.get('userRole') == 'Inspector Supervisor' || responseMap.get('userRole') == 'Board Staff')
                                                        ) || 
                                                        (String)responseMap.get('boardName') == 'Pharmacy'
            );
            return responseMap;
        } catch (Exception e) {
            LPI_ExceptionManager.logException(
                'LPI_NewVisitRecord',
                'getRecordDetail',
                e
            );
            throw new AuraHandledException(e.getMessage());
        }
    }


    /**
    * @description : Method to populate default address based on context on Initate Inspection.
    * @author MTX Group Product Team | 06-09-2023 
    * @param jsonWrapper 
    **/ 
    private static void populateDefaultAddressBasedOnContext(Map<String,Object> mpObj) {
       
        if(!mpObj.containsKey('getContextId') || mpObj.get('getContextId') == null) {
            return;
        }
        String contextId = (String)mpObj.get('getContextId');
        String sObjectName = Id.valueOf(contextId)?.getSObjectType().getDescribe().getName();
        String fields;
        String whereClause='';
        String placeId;
        Set<Id> locIdSet = new Set<Id>();
            fields = 'Id,RgltyAuthApplicationId,PlaceId, TYPEOF Place  WHEN Location THEN LocationType,Status__c END';
            if(sObjectName == CASE_OBJ) {
                List<Case> caseRecList = LPI_CaseDAO.getCaseRecords('Id,Business_License_Id__c','Id = \'' + String.escapeSingleQuotes(contextId) + '\'',null,null);
                if(caseRecList.isEmpty() || String.isBlank(caseRecList[0].Business_License_Id__c)) {
                    return;
                }
                whereClause = ' AuthorizationId = \'' + caseRecList[0].Business_License_Id__c +'\'';
            } else if(sObjectName == BUSINESS_LICENSE) {
                whereClause = ' AuthorizationId = \'' + String.escapeSingleQuotes(contextId) +'\'';
            } else {
                whereClause = ' RgltyAuthApplicationId = \''+ String.escapeSingleQuotes(contextId) +'\'';
            }

            List<AuthApplicationPlace> authAppPlaceRecList = LPI_AuthApplicationPlaceDAO.getAuthApplicationPlaceByDymanicQuery(fields,whereClause,null,null,null);

            if(!authAppPlaceRecList.isEmpty()) {

                for(AuthApplicationPlace authplaceRec : authAppPlaceRecList) {
                    locIdSet.add(authplaceRec.PlaceId);
                }
                
                fields = 'Id,Street,City,StateCode,County__c,Business_State__c,PostalCode,LocationType,ParentId,Parent.LocationType,Parent.Status__c';
                whereClause = 'ParentId IN '+ LPI_ServiceUtility.getStringValuesBySet(locIdSet) + ' AND Parent.LocationType = \'' + LOCATION_TYPE +'\'';

                if(sObjectName != BUSINESS_LICENSE_APPLICATION) {
                    whereClause += ' AND Parent.Status__c = \'' + LOCATION_STATUS_OPEN + '\'';
                }
                List<Schema.Address> addressList = new LPI_AddressDAO.LPI_AddressDAOWithoutSharing().getAddressWithoutSecurityEnforced(fields,whereClause,null,null,null);
                if(addressList.isEmpty()) {
                    return;
                }
                mpObj.put('addressRecDefault',addressList[0]?.Id);
            }
    }

    /**
    * @description : Method to save visit record details.
    * @author MTX Group Product Team | 06-09-2023 
    * @param jsonWrapper 
    **/
    @AuraEnabled
    public static Map<String,Object> createVisitRecord(String jsonWrapper) {
        try {
            Map<String,Object> responseMap = new Map<String,Object>();
            String sObjectName;
            VisitWrapper vWrapper = (VisitWrapper) JSON.deserialize(
                jsonWrapper,
                VisitWrapper.class
            );
            Visit v = new Visit();
            if (vWrapper.visitId != null) {
                v.Id = vWrapper.visitId;
            }
            if (vWrapper.addressLoc != null) {
                v.PlaceId = vWrapper.addressLoc;
            } else {
                Schema.Location locRec = new Schema.Location();
                locRec.Name = vWrapper.locationName;
                locRec.LocationType = vWrapper.locationType;
                SObject locRecInsert = LPI_DML.doInsert(locRec);
                Schema.Address addressRec = new Schema.Address();
                addressRec.LocationType = vWrapper.locationType;
                addressRec.Street = vWrapper.street;
                addressRec.City = vWrapper.city;
                addressRec.PostalCode = vWrapper.zipCode;
                addressRec.StateCode = vWrapper.state;
                addressRec.CountryCode = US_COUNTRY_CODE;
                addressRec.County__c = vWrapper.county;
                addressRec.ParentId = (Id) locRecInsert.get('Id');
                SObject addRecInsert = LPI_DML.doInsert(addressRec);
                v.PlaceId = (Id) addRecInsert.get('Id');
            }

            v.VisitPriority = vWrapper.vPriority != null
                ? vWrapper.vPriority
                : '';
            v.Status__c = vWrapper.vStatus;
            v.AccountId = vWrapper.vAccount;
            v.Board_Name__c=vWrapper.boardName;
            if(!vWrapper.isAdhocVisit) { 
                v.ContextId = vWrapper.context != null ? vWrapper.context : null;
                sObjectName = (v.ContextId!=null ? v.ContextId.getSObjectType().getDescribe().getName():null);
            }
            v.VisitorId = vWrapper.visitor != null ? vWrapper.visitor : null;
            DateTime currentDateTime = DateTime.now().addMinutes(15);
            Time timeObj = Time.newInstance(currentDateTime.hour(), currentDateTime.minute(), currentDateTime.second(), currentDateTime.millisecond());
            
            v.PlannedVisitStartTime = (vWrapper.vPlannedStartTime >= Date.today() ? DateTime.newInstance(vWrapper.vPlannedStartTime,timeObj) : System.now());  
            v.Date_Assigned__c = vWrapper.vPlannedStartTime;

            if(vWrapper.vPlannedEndTime!=null) {
                timeObj =  Time.newInstance(23, 59, 0, 0);
                v.PlannedVisitEndTime = DateTime.newInstance(vWrapper.vPlannedEndTime,timeObj);   
            }
            v.Discipline__c = vWrapper.vDiscipline != null
                ? vWrapper.vDiscipline
                : '';
            v.Comments__c = vWrapper.visitComment != null
                ? vWrapper.visitComment
                : '';        
            if(vWrapper.additionalInspection!=null && vWrapper.additionalInspection) {
                v.Description__c = vWrapper.visitDesc != null 
                ? vWrapper.visitDesc 
                : '';
                List<InspectionType> inspectionTypeList= LPI_InspectionTypeDAO.getInspectionTypeRecords('Id',
                'Name = \''+ADDITIONAL_INSPECTION+'\'',
                null,null
                );
                if(inspectionTypeList.isEmpty()) {
                    throw new LPI_Exception('Couldnt Find Additional Inspection Type');
                }
                v.VisitTypeId = inspectionTypeList[0].Id;
                v.Id = null;
            } else {
                v.VisitTypeId = vWrapper.VisitTypeId;
            }
            v.Inspection_Reason__c = vWrapper.inspectionReason;
            v.Final_Assessment_Result__c = vWrapper.result;
            v.Recurrence__c = vWrapper.recurrence;
            v.License_Type__c =vWrapper.licenseTypeName;
            if(vWrapper.vInspectionType != 'Routine' || sObjectName == CASE_OBJ) {
                v.Remedial_Action_Sent__c = vWrapper.vRemedialActionSent;
                v.Remedial_Response_Due__c = vWrapper.vRemedialResponseDue;
                v.Remedial_response_received__c = vWrapper.vRemedialResponseReceived;
            }
            if(String.isBlank(v.Id)){
                v.Inspection_Forms__c = vWrapper.inspectionForms;
            }
            v.Title__c = vWrapper.title;
            v.Name_of_Licensee_Applicant_Representativ__c	 = vWrapper.nameOfLicenseeRep;
            v.Inspector_Signed_Date__c = vWrapper.inspectorSignedDate;
            v.Attestation_by_Licensee_Applicant_Rep__c = (vWrapper.attestation!=null ? vWrapper.attestation : false);
            v.Licensee_Applicant_Rep_Signed_Date__c = vWrapper.licenseeSignedDate;
            v.Trigger_Site_Survey_Email_Notification__c = vWrapper.triggerSiteSurveyEmailNotification != null ? vWrapper.triggerSiteSurveyEmailNotification : false;
            v.Unable_to_Inspect__c = vWrapper.unableToInspect!=null? vWrapper.unableToInspect : false;

            if(vWrapper.vActualEndTime!=null) {
                timeObj =  Time.newInstance(23, 59, 0, 0);
                v.ActualVisitEndTime = DateTime.newInstance(vWrapper.vActualEndTime,timeObj);
                v.Closed_Date__c = (vWrapper.result == 'No Violation' ? vWrapper.vActualEndTime : null); 
            }
            if(String.isNotBlank(v.Id)){
                List<Visit> visitList = LPI_VisitControllerDAO.getVistListByDynamicQuery(new List<String>{'VisitorId'},'Id =\''+ String.escapeSingleQuotes(v.Id) + '\'',null,null,null);
                if(!visitList.isEmpty() && visitList[0].VisitorId != v.VisitorId){
                    v.Is_Owner_Updated__c = true;  
                }
            }
            v = (Visit)LPI_DML.doUpsert(v);
            responseMap.put('visitId',v.Id);
            responseMap.put('licenseType',v.License_Type__c);
            String visitName = v.Name;
            if(String.isBlank(visitName)) {
                List<Visit> visitNameList = LPI_VisitControllerDAO.getVistListByDynamicQuery(
                    new List<String>{'Name'},
                    'Id =\''+ String.escapeSingleQuotes(v.Id) + '\'',
                    1,
                    null,
                    null
                );
                if(!visitNameList.isEmpty()) {
                    visitName = visitNameList[0].Name;
                }
            }
            responseMap.put('visitName', visitName);

            return responseMap;

        } 
        catch (Exception e) {
            If(e.getMessage().contains('Record cannot be changed once the status is Completed')){
                LPI_ExceptionManager.logException(
                'LPI_NewVisitRecord',
                'createVisitRecord',
                e
            );
            throw new AuraHandledException('Record cannot be changed once the status is Completed.');
            }
            else {
                LPI_ExceptionManager.logException(
                    'LPI_NewVisitRecord',
                    'createVisitRecord',
                    e
                );
                throw new AuraHandledException(e.getMessage());
            }
        }
    }
    
    /**
    * @description : Methdo to get Address record details.
    * @author MTX Group Product Team | 06-09-2023 
    * @param recordId 
    * @return Schema.Address 
    **/
    @AuraEnabled
    public static Schema.Address getAddressDetail(String recordId) {
        try {
            List<Schema.Address> addRec = LPI_AddressDAO.getAddressByDymanicQuery(
                'Id,Street,StateCode,City,PostalCode,ParentId,County__c',
                'Id = \'' +
                String.escapeSingleQuotes(recordId) +
                '\'',
                '1',
                null,
                null
            );
            if (!addRec.isEmpty()) {
                return addRec[0];
            }
            return null;
        } catch (Exception e) {
            LPI_ExceptionManager.logException(
                'LPI_NewVisitRecord',
                'getAddressDetail',
                e
            );
            throw new AuraHandledException(e.getMessage());
        }
    }

    public class SelectOptionWrapper {
        @AuraEnabled
        public string value;
        @AuraEnabled
        public string label;
        @AuraEnabled
        public string developerName;
        @AuraEnabled
        public string recordId;

        public SelectOptionWrapper(
            string value,
            string label,
            string developerName
        ) {
            this.value = value;
            this.label = label;
            this.developerName = developerName;
        }
        public SelectOptionWrapper(string value, string label) {
            this.value = value;
            this.label = label;
        }
    }
    
    public class VisitWrapper {
        @AuraEnabled
        public string visitId;
        @AuraEnabled
        public string locationName;
        @AuraEnabled
        public string locationType;
        @AuraEnabled
        public string street;
        @AuraEnabled
        public string city;
        @AuraEnabled
        public string state;
        @AuraEnabled
        public string zipCode;
        @AuraEnabled
        public string addressLoc;
        @AuraEnabled
        public string vPriority;
        @AuraEnabled
        public string vStatus;
        @AuraEnabled
        public string vAccount;
        @AuraEnabled
        public string context;
        @AuraEnabled
        public string contextName;
        @AuraEnabled
        public string vInspectionType;
        @AuraEnabled
        public Date vPlannedStartTime;
        @AuraEnabled
        public Date vPlannedEndTime;
        @AuraEnabled
        public string vDiscipline;
        @AuraEnabled
        public string visitComment;    
        @AuraEnabled
        public string visitDesc;   
        @AuraEnabled
        public string visitor;
        @AuraEnabled
        public string visitTypeId;
        @AuraEnabled
        public string inspectionReason;
        @AuraEnabled
        public Boolean isComplaintsVisit;
        @AuraEnabled
        public Datetime vActualStartTime;
        @AuraEnabled
        public Date vActualEndTime;
        @AuraEnabled 
        public Boolean isAdhocVisit;
        @AuraEnabled 
        public String licenseTypeName;
        @AuraEnabled 
        public String licenseId;
        @AuraEnabled
        public String visitName;
        @AuraEnabled
        public String visitTypeName;
        @AuraEnabled
        public Integer noOfOpenViolations;
        @AuraEnabled 
        public String accName;
        @AuraEnabled 
        public String recurrence;
        @AuraEnabled 
        public String result;
        @AuraEnabled
        public Date vRemedialActionSent;
        @AuraEnabled
        public Date vRemedialResponseDue;
        @AuraEnabled
        public Date vRemedialResponseReceived;
        @AuraEnabled
        public Boolean additionalInspection;
        @AuraEnabled 
        public String boardName;
        @AuraEnabled 
        public String inspectionForms;
        @AuraEnabled 
        public String nameOfLicenseeRep;
        @AuraEnabled 
        public String title;
        @AuraEnabled 
        public Date licenseeSignedDate;
        @AuraEnabled 
        public Date inspectorSignedDate;
        @AuraEnabled 
        public Boolean attestation;
        @AuraEnabled 
        public Boolean triggerSiteSurveyEmailNotification;
        @AuraEnabled 
        public Boolean unableToInspect;
        @AuraEnabled 
        public String county;

        public VisitWrapper(){}
        public VisitWrapper(
            String visitId,
            string addressLoc,
            string vPriority,
            string vStatus,
            string vAccount,
            string boardName,
            string context,
            string contextName,
            string vInspectionType,
            Date vPlannedStartTime,
            string vDiscipline,
            string visitComment,    
            string visitor,
            string visitTypeId,
            string inspectionReason,
            Datetime vActualStartTime,
            Date vActualEndTime,
            Date vRemedialActionSent,
            Date vRemedialResponseDue,
            Date vRemedialResponseReceived
        ) {
            this.visitId = visitId;
            this.addressLoc = addressLoc;
            this.vPriority = vPriority;
            this.vStatus = vStatus;
            this.vAccount = vAccount;
            this.boardName = boardName;
            this.context = context;
            this.contextName = contextName;
            this.vInspectionType = vInspectionType;
            this.vPlannedStartTime = vPlannedStartTime;
            this.vDiscipline = vDiscipline;
            this.visitComment = visitComment;
            this.visitor = visitor;
            this.visitTypeId = visitTypeId;
            this.inspectionReason = inspectionReason;
            this.vActualStartTime = vActualStartTime;
            this.vActualEndTime = vActualEndTime;
            this.isAdhocVisit = false;
            this.vRemedialActionSent = vRemedialActionSent;
            this.vRemedialResponseDue = vRemedialResponseDue;
            this.vRemedialResponseReceived = vRemedialResponseReceived;
        }
    }

    /**
     * @description : Method to update Planned visit date on visit.
     * @author MTX Group Product Team | 06-02-2023
     * @param jsonData
     * @return string
     **/
    @AuraEnabled
    public static string updatePlannedVisitDate(String jsonData) {
        try {
            if (String.isBlank(jsonData)) {
                return null;
            }
            VisitWrapper vWrapper = (VisitWrapper) JSON.deserialize(
                jsonData,
                VisitWrapper.class
            );
            Visit v = new Visit();
            v.Id = vWrapper.visitId;
            v.PlannedVisitStartTime = vWrapper.vPlannedStartTime;
            LPI_DML.doUpdate(v);
            return 'true';
        } catch (Exception e) {
            LPI_ExceptionManager.logException(
                'LPI_NewVisitRecord',
                'updatePlannedVisitDate',
                e
            );
            throw new AuraHandledException(e.getMessage());
        }
    }
     /**
     * @description : Method to fetch Visit's related Assessmenttask Status.
     * @author MTX Group Product Team | 06-02-2023
     * @param recordId
     * @return Boolean
     **/
    @AuraEnabled
    public static Boolean fetchVisitAssessmentStatus(Id recordId) {
        try {
            if (String.isBlank(recordId)) {
                return null;
            }
            if(!checkIfCurrentUserIsInspector(recordId)){
                throw new LPI_Exception('Looks like you are not the inspector on the inspection.');
            }
            for(AssessmentTask asTask : LPI_AssessmentTaskDAO.getAssessmentTaskListByDynamicQuery(
                'Id,Status',
                'ParentId = \'' + String.escapeSingleQuotes(recordId) +
                '\'',
                null,null,null
            ))
            {
                if(asTask != null && asTask.Status != LPI_LiteralConstant.Inspection_Status_COMPLETED)
                {
                    return false;
                }
            }
            return true;
        } catch (Exception e) {
            LPI_ExceptionManager.logException(
                'LPI_NewVisitRecord',
                'fetchVisitAssessmentStatus',
                e
            );
            throw new AuraHandledException(e.getMessage());
        }
    }
    /**
     * @description : Method to Update status and statusRemarks after Ending visit.
     * @author MTX Group Product Team | 06-02-2023
     * @param recordId
     * @param dataObj
     * @return Boolean
     **/
    @AuraEnabled
    public static Boolean saveVisitStatusRemark(Id recordId ,String dataObj) {
        try {
            if (String.isBlank(recordId)) {
                return null;
            }
            Visit vRecord = (Visit) JSON.deserialize(dataObj, Visit.class);
            vRecord.Id = recordId;
            LPI_DML.doUpdate(vRecord);
            return true;
        } catch (Exception e) {
            LPI_ExceptionManager.logException(
                'LPI_NewVisitRecord',
                'saveVisitStatusRemark',
                e
            );
            throw new AuraHandledException(e.getMessage());
        }
    }
     /**
     * @description : Method to fetch Visit records related to BusinessLicense.
     * @author MTX Group Product Team | 06-02-2023
     * @param recordId
     * @return List<VisitWrapper>
     **/
    @AuraEnabled
    public static List<VisitWrapper> fetchBlRelatedVisitRecords(Id recordId) {
        List<VisitWrapper> blRelatedVisitsWrapperList = new List<VisitWrapper>();
        try {
            List<Visit> blRelatedVisitsList = new List<Visit>();
            Map<Id,Visit> visitIdToMap = new Map<Id,Visit>();
            Map<Id,Integer> visitIdToRCVCount = new Map<Id,Integer>();
            if (String.isBlank(recordId)) {
                return null;
            }
            for(Visit visit : LPI_VisitControllerDAO.getVisitListByDynamicQueryWithoutSecurity(
                new List<String>{'Id, Name, VisitType.Name, Status__c','PlannedVisitStartTime'},
                'ContextId = \'' + String.escapeSingleQuotes(recordId) +
                '\'',
                null,'Name','DESC'
            ))
            {
                blRelatedVisitsList.add(visit);
                visitIdToMap.put(visit.Id,visit);
            }
            Integer noOfRecords = 0;
            if(!visitIdToMap.isEmpty())
            {
                for(RegulatoryCodeViolation rcv : LPI_RegulatoryCodeViolationDAO.getRegulatoryCodeViolationListByDynamicQuery(
                    'Id,InspectionId',
                    'InspectionId IN ' + LPI_ServiceUtility.getStringValuesBySet(visitIdToMap.keySet())
                    + ' AND (DateResolved = NULL OR DateResolved > TODAY)',
                    null,
                    null,
                    null
                ))
                {
                    noOfRecords += 1;
                    visitIdToRCVCount.put(rcv.InspectionId, noOfRecords);
                }
                for(Id visitId : visitIdToMap.keySet())
                {
                    VisitWrapper vWrapper = new VisitWrapper();
                    vWrapper.visitId = visitId;
                    vWrapper.visitName = visitIdToMap.get(visitId).Name;
                    vWrapper.visitTypeName = visitIdToMap.get(visitId).VisitType.Name;
                    vWrapper.vStatus = visitIdToMap.get(visitId).Status__c;
                    vWrapper.noOfOpenViolations = visitIdToRCVCount.get(visitId) != null ? visitIdToRCVCount.get(visitId) : 0;
                    DateTime plannedStartTime = visitIdToMap.get(visitId).PlannedVisitStartTime;
                    if(plannedStartTime!=null) {
                        vWrapper.vPlannedStartTime = Date.newInstance(plannedStartTime.year(), plannedStartTime.month(),plannedStartTime.day());
                    }

                    blRelatedVisitsWrapperList.add(vWrapper);
                }
            }
        } catch (Exception e) {
            LPI_ExceptionManager.logException(
                'LPI_NewVisitRecord',
                'fetchBlRelatedVisitRecords',
                e
            );
            throw new AuraHandledException(e.getMessage());
        }
        return blRelatedVisitsWrapperList;
    }

    @AuraEnabled
    public static Map<String,Object> fetchAdhocInspections() {
        try {
            Map<String,Object> responseMap = new Map<String,Object>();
            List<InspectionType> inspectionTypeList= LPI_InspectionTypeDAO.getInspectionTypeRecords('Id',
                                        'Name = \''+ADHOC_INSPECTION+'\'',
                                        null,null
                                      );
            if(inspectionTypeList.isEmpty()) {
                throw new LPI_Exception('Couldnt Find Adhoc Inspection Type');
            }
            Id inspectionTypeId = inspectionTypeList[0]?.Id;
            List<VisitWrapper> adhocVisitList = new List<VisitWrapper>();
            for(Visit visitRec : LPI_VisitControllerDAO.getVistListByDynamicQuery(new List<String>{
                'Id',
                'VisitTypeId',
                'PlannedVisitStartTime',
                'Status__c',
                'CreatedDate',
                'Name'            
            },'VisitTypeId = \''+inspectionTypeId+'\'',null,'CreatedDate','DESC')) {
                DateTime plannedStartTime = visitRec.PlannedVisitStartTime;

                VisitWrapper visitData = new VisitWrapper();
                visitData.visitId = visitRec.Id;
                visitData.visitTypeId = visitRec.VisitTypeId;
                visitData.vPlannedStartTime = Date.newInstance(plannedStartTime.year(), plannedStartTime.month(),plannedStartTime.day());
                visitData.vStatus = visitRec.Status__c;
                visitData.visitName = visitRec.Name;
                adhocVisitList.add(visitData);
            }
            responseMap.put('recordList',adhocVisitList);
            responseMap.put('inspectionType',ADHOC_INSPECTION);

            return responseMap;

        } catch (Exception e) {
            LPI_ExceptionManager.logException(
                'LPI_NewVisitRecord',
                'fetchBlRelatedVisitRecords',
                e
            );
            throw new AuraHandledException(e.getMessage());
        }
    }
    /**
     * @description : Method to update Actual Start date on visit.
     * @author MTX Group Product Team | 07-11-2023
     * @param recordId
     * @return string
     **/
    @AuraEnabled
    public static Boolean updateActualVisitStartTime(Id recordId) {
        try {
            if (String.isBlank(recordId)) {
                return null;
            }
            Visit v = new Visit();
            v.Id = recordId;
            v.Status__c = IN_PROGRESS;
            v.Status = IN_PROGRESS;
            v.ActualVisitStartTime = datetime.now();
            LPI_DML.doUpdate(v);
            return true;
        } catch (Exception e) {
            LPI_ExceptionManager.logException(
                'LPI_NewVisitRecord',
                'updateActualVisitStartTime',
                e
            );
            throw new AuraHandledException(e.getMessage());
        }
    }
    /**
     * @description : Method to check if current User Profile Name is Inspectors.
     * @author MTX Group Product Team | 08-02-2023
     * @param 
     * @return String
     **/
    public static Map<String,String> getUserProfileAndRoleName() {
        List<User> userList= LPI_UserDao.getCurrentUserRecord();
        if(userList.isEmpty())
        {
            return null;
        }
        return new  Map<String,String>{
            'userRole' => userList[0].UserRole.Name,
            'profileName' => userList[0].Profile.Name,
            'userName' => userList[0].Name
        };
    }

    /**
    * @description : Method to check if current user is inspetor on the visit.
    * @author MTX Group Product Team | 08-03-2023 
    * @param recordId 
    * @return Boolean 
    **/
    @AuraEnabled
    public static Boolean checkIfCurrentUserIsInspector(String recordId){
        try {
            List<Visit> visitList = LPI_VisitControllerDAO.getVistListByDynamicQuery(new List<String>{'VisitorId'},'Id = \'' + String.escapeSingleQuotes(recordId) + '\'',null,null,null);
            if(visitList.isEmpty()){
                return false;
            }
            String roleId = UserInfo.getUserRoleId();
            List<UserRole> userRoleList = new List<UserRole>();
            if(roleId != null){
                userRoleList = LPI_UserRoleDao.getUserRoleByDynamicQuery('Id,DeveloperName','Id = \''+ roleId + '\'',null,null,null);
            }
            return visitList[0].VisitorId == UserInfo.getUserId() || (!userRoleList.isEmpty() &&  userRoleList[0].DeveloperName == INSPECTOR_SUPERVISOR_ROLE);

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    
   private static final String ROUTINE_INSPECTION_TEXT = 'Site Survey';
   

    /**
     * @author                      : MTX Group Product Team
     * @since                       : 4th Sept 2023
     * @description                 : This method fetches the Routine Site Inspection Records Details which are pending and Past Due.
     * @return                      : `List<LPI_Wrapper.RoutineSiteInspectionWrapper>`
	 * @last modified by            :MTX Group Product Team
     * @last modified date          : 4 Sept, 2023
     * @modified details            : Optimized Code/ Added Expiry Date Mapping.
     */
   @AuraEnabled(cacheable = true)
   public static List<LPI_Wrapper.RoutineSiteInspectionWrapper> fetchRoutineSiteInspectionRec(){
    try {

        List<String> fieldsToQuery = new List<String>{
            'Id,Submitted_Routine_Survey_Application__c,ContextId,Name,CreatedDate,VisitTypeId,VisitType.Name',
            'TYPEOF Context WHEN BusinessLicense THEN Id, Name,RegulatoryAuthorizationType.Name,Account.Name,PeriodStart'
        };
        String whereClause = 'ContextId != NULL AND ' + 
        ' Context.Type =\'BusinessLicense\' AND ' +
        ' Submitted_Routine_Survey_Application__c = \'No\' AND ' + 
        ' VisitTypeId != NULL AND '+ 
        ' VisitType.Name = \'' + ROUTINE_INSPECTION_TEXT + '\'';
                
        List<LPI_Wrapper.RoutineSiteInspectionWrapper> resultList = new List<LPI_Wrapper.RoutineSiteInspectionWrapper>();

       for(Visit visitRec : LPI_VisitControllerDAO.getVisitListByDynamicQueryWithoutSecurity(
                    fieldsToQuery,
                    whereClause,
                    null,
                    null,
                    null
        )) {

            BusinessLicense blRec = (BusinessLicense) visitRec.Context;

            

            LPI_Wrapper.RoutineSiteInspectionWrapper rsInsRec = new LPI_Wrapper.RoutineSiteInspectionWrapper();
            rsInsRec.programName =blRec.RegulatoryAuthorizationType.Name;
            rsInsRec.schoolName = blRec.Account.Name;
            rsInsRec.routineApplicationSubmitted = false;
            rsInsRec.licenseUrl = '/'+blRec.Id;
            rsInsRec.licenseNumber = blRec.Name;
            rsInsRec.issuanceDate = blRec.PeriodStart!=null ? Date.newInstance(blRec.PeriodStart.year(),blRec.PeriodStart.month(),blRec.PeriodStart.day()):null;
            rsInsRec.createdDate = Date.newInstance(visitRec.CreatedDate.year(), visitRec.CreatedDate.month(),visitRec.CreatedDate.day());
           
            resultList.add(rsInsRec);
        }

        return resultList;

    } catch (Exception e) {
        LPI_ExceptionManager.logException('LPI_NewVisitRecord', 'fetchRoutineSiteInspectionRec', e);
        throw new AuraHandledException(e.getMessage());
    }
   }

   /**
    * @description : Method to check if the contextId is of case object
    * @author MTX Group Product Team | 09-04-2023 
    * @param recordId 
    * @return Boolean
    **/
    @AuraEnabled
    public static Map<String,String> checkContextIdCaseSobject(String recordId){
        try {
            Map<String, String> result = new Map<String, String>();
            if(String.isNotBlank(recordId)){
                String whereClause = 'Id = \'' + String.escapeSingleQuotes(recordId) + '\'';
                List<Visit> visitRecList = LPI_VisitControllerDAO.getVistListByDynamicQuery(
                    new List<String>{'Id', 'ContextId','Business_Name__c',
                                'Board_Name__c','Address_Name__c','PlaceId',
                                'Discipline__c','Doing_Business_As_DBA_or_Trade_Name__c','Classification_Type__c',
                                'TYPEOF Context WHEN Case THEN Last_Inspection_Date__c WHEN BusinessLicense THEN Last_Inspection_Date__c WHEN BusinessLicenseApplication THEN Last_Inspection_Date__c END'},
                    whereClause,
                    null,
                    null,
                    null
                );

                if(String.isNotBlank(visitRecList[0].ContextId)){
                    sObject contextObj = visitRecList[0].Context;
                    String sObjName = visitRecList[0].ContextId.getSObjectType().getDescribe().getName();
                    result.put('isCaseObj' , sObjName == CASE_OBJ ? 'true' : 'false');
                    result.put('boardName', visitRecList[0].Board_Name__c);
                    result.put('contextId', visitRecList[0].ContextId);
                    result.put('placeId',visitRecList[0].PlaceId);
                    result.put('businessName',visitRecList[0].Business_Name__c);
                    result.put('addressName',visitRecList[0].Address_Name__c);
                    result.put('dbaName',visitRecList[0].Doing_Business_As_DBA_or_Trade_Name__c);
                    result.put('lastInspectionDate', Date.valueOf(contextObj.get('Last_Inspection_Date__c'))?.format());
                    result.put('classification',visitRecList[0].Classification_Type__c);
                    return result;
                }
            }
            return result;
        } catch (Exception e) {
            LPI_ExceptionManager.logException('LPI_NewVisitRecord', 'checkContextIdCaseSobject', e);
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * Resolves Issuing Department (board) name from a Regulatory Authorization Type name.
     * Used when complaint Cases have no Board_Name__c but the user selects a License Type on create.
     */
    @AuraEnabled
    public static String getBoardNameFromLicenseType(String licenseTypeName) {
        try {
            if(String.isBlank(licenseTypeName)) {
                return null;
            }
            List<RegulatoryAuthorizationType> regAuthList = LPI_RegulatoryAuthorizationTypeDAO.getRegulatoryAuthorizationTypeByDymanicQuery(
                'Id,Name,IssuingDepartment.Name',
                ' Name = \'' + String.escapeSingleQuotes(licenseTypeName) + '\'',
                '1',
                null,
                null
            );
            return regAuthList.isEmpty() ? null : regAuthList[0]?.IssuingDepartment?.Name;
        } catch (Exception e) {
            LPI_ExceptionManager.logException('LPI_NewVisitRecord', 'getBoardNameFromLicenseType', e);
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * Pharmacy zip-based inspector assignment stub used by lpiNewVisitRecord.
     * Returns null when no zip mapping is available so the LWC can fall back to the logged-in user.
     */
    @AuraEnabled
    public static User assignInspectorBasedOnZipcodeForPharmacy(String zipCode) {
        try {
            if(String.isBlank(zipCode)) {
                return null;
            }
            return null;
        } catch (Exception e) {
            LPI_ExceptionManager.logException('LPI_NewVisitRecord', 'assignInspectorBasedOnZipcodeForPharmacy', e);
            throw new AuraHandledException(e.getMessage());
        }
    }

    
 }