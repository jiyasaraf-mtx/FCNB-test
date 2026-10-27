/**
 * @description       : 
 * @author            : MTX Group Product Team
 * @group             : 
 * @last modified on  : 08-16-2024
 * @last modified by  : MTX Group Product Team
**/
public with sharing class LPI_DashbaordTableCtrl {
    
    public final static String CLASS_NAME = 'LPI_DashbaordTableCtrl';
    public final static String CHANGE_OF_PERSON_IN_CHARGE = 'Change of Person In Charge';
    public static final String APPROVED_STATUS = 'Approved';
    public static final String LICENSE_ISSUE_STATUS = 'License Issued';

    private static final String LICENSE_SERVICE_PROVIDER_ROLE = 'License Service Provider';
    private static final String STATUS_DRAFT = 'Draft';

    /**
    * @description 
    * @author MTX Group Product Team | 05-07-2024 
    * @return Set<Id> 
    **/
    private static Set<Id> getRelatedAccountId(){
        String userId = UserInfo.getUserId();
        User u  =  LPI_WithoutSharingUtility.getUserRecordDetailWithoutSharing(userId);
        String accwhereClause='Id = \''+ String.escapeSingleQuotes(u.AccountId)+'\'';
        List<Account> accData =  LPI_AccountDAO.getAccountListByDynamicQuery(new List<String>{'Id','SelectedAccountId__c'},accwhereClause,null,null,null);
        String selectedAccoutnId = (!accData.isEmpty() && String.isNotBlank(accData[0].SelectedAccountId__c)?accData[0].SelectedAccountId__c:u.AccountId);
        Set<Id> accIdSet = LPI_RelationshipService.getRelatedAccountId(selectedAccoutnId);
        return accIdSet;
    }

    /**
    * @description 
    * @author MTX Group Product Team | 05-07-2024 
    * @param requiredAll 
    * @param count 
    * @param onlyRenewal 
    * @param showAllLicenses 
    * @return Map<String, Object> 
    **/
    private static Map<String,Object> getMyLicenseDetail(boolean requiredAll,Integer count,boolean onlyRenewal, boolean showAllLicenses){
        try {
            Set<Id> accIdSet = showAllLicenses ? getRelatedAccIdsSet() : getRelatedAccountId();
            Set<Id> lspAccSet = getLicenseServiceProviderAccIds();
            String fieldsToQuery = ' Id,AccountId,Legacy_License_Number__c,Licensee_Modification_Reason__c,Status,PeriodStart, PeriodEnd,Profession__c , Name, Reinstatement_Count__c,Inactivation_Date__c, RegulatoryAuthorizationTypeId,RegulatoryAuthorizationType.Open_for_Renewal__c,RegulatoryAuthorizationType.Late_Renewal_Allowed__c,RegulatoryAuthorizationType.Extended_Expiry_Period__c,RegulatoryAuthorizationType.Name, BusinessType.Name, RegulatoryAuthorizationType.Inactivation_Allowed__c, RegulatoryAuthorizationType.Reactivation_Allowed__c, RegulatoryAuthorizationType.Reinstatement_Allowed__c, RegulatoryAuthorizationType.Subsequent_Reinstatement_Period__c, RegulatoryAuthorizationType.Reactivation_Period__c,RegulatoryAuthorizationType.Reinstatement_by_Exam_Period__c,License_Sub_status__c, ';
            fieldsToQuery += 'RegulatoryAuthorizationType.IssuingDepartment.Name,RegulatoryAuthorizationType.Authorisation_Type__c, ';
            fieldsToQuery += '(SELECT Status FROM IndividualApplicationPermit WHERE ' +'ApplicationType = \''+String.escapeSingleQuotes('Renewal')+'\'';
            fieldsToQuery += ' AND ( Status = \''+ APPROVED_STATUS +'\''+ ' OR Status = \''+LICENSE_ISSUE_STATUS+ '\' )';
            fieldsToQuery+= ' )';
            String whereClause = ' AccountId IN '+LPI_ServiceUtility.getStringValuesBySet(accIdSet);
            Integer totalLicenseRecords = 0;

            List<BusinessLicense> blList = new LPI_BusinessLicenseDAO.LPI_BusinessLicenseWithoutSharingDAO().getBusinessLicenseByDymanicQueryWithoutSecurity(
                fieldsToQuery,whereClause,null,' CreatedDate','DESC');

            Map<Id, Map<String, Set<String>>> ratToEligibleStatusMap = LPI_ServiceUtility.getRATToEligibleStatusMap(
                blList
            );
            Map<String,Integer> mapOfStatusToCount = new Map<String,Integer>();
            List<Map<String, String>> busLiceList = new List<Map<String, String>>();
            for (BusinessLicense bl : blList) {
                if(lspAccSet.contains(bl.AccountId)){
                    continue;
                }
                if(!mapOfStatusToCount.containsKey(bl.Status)){
                    mapOfStatusToCount.put(bl.Status,0);
                }
                mapOfStatusToCount.put(bl.Status, mapOfStatusToCount.get(bl.Status)+1);
                totalLicenseRecords = totalLicenseRecords + 1;
                if(requiredAll || totalLicenseRecords < count){
                    Map<String, String> mapOfBL = new Map<String, String>();
                    mapOfBL.put('blid',  bl.Id);
                    mapOfBL.put('AccountId',  bl.AccountId);
                    mapOfBL.put('name', String.isNotBlank(bl.Legacy_License_Number__c) ? bl.Legacy_License_Number__c : bl.Name);
                    if (ratToEligibleStatusMap.containsKey(bl.RegulatoryAuthorizationTypeId)){
                        Map<String, Boolean> isActionAllowedMap = LPI_ServiceUtility.getIsActionAllowedMap(
                            ratToEligibleStatusMap.get(bl.RegulatoryAuthorizationTypeId),bl.status);
                        for(String type : isActionAllowedMap.keySet()) {
                            switch on type {
                                when 'ReactivationAllowed' {		
                                    if(isActionAllowedMap.get(type) && LPI_BusinessLicenseUtility.checkForReactivation(bl)){
                                        mapOfBL.put(type,'true');
                                    }else{
                                        mapOfBL.put(type,'false');
                                    }
                                }	
                                when 'ReinstatementAllowed' {		
                                    if(isActionAllowedMap.get(type) && LPI_BusinessLicenseUtility.checkForReinstatement(bl)){
                                        mapOfBL.put(type,'true');
                                    }else{
                                        mapOfBL.put(type,'false');
                                    }
                                }
                                when 'RenewalAllowed','Annual Report SurveyAllowed' {	
                                    if(isActionAllowedMap.get(type) && LPI_BusinessLicenseUtility.checkForRenewal(bl)){
                                        mapOfBL.put(type,'true');
                                    }else{
                                        mapOfBL.put(type,'false');
                                    }
                                }
                                when 'Reinstatement by ExamAllowed' {	
                                    if(isActionAllowedMap.get(type) && LPI_BusinessLicenseUtility.checkForReinstatementByExam(bl)){
                                        mapOfBL.put(type,'true');
                                    }else{
                                        mapOfBL.put(type,'false');
                                    }
                                }
                                when else {		
                                    mapOfBL.put(type,String.valueOf(isActionAllowedMap.get(type)));
                                }
                            }
                        }
                    }
                    if(!onlyRenewal || (onlyRenewal && mapOfBL.containsKey('RenewalAllowed') && mapOfBL.get('RenewalAllowed') == 'true')){
                        mapOfBL.put('isRnLpn','false');
                        mapOfBL.put(
                            'businesstypename', bl.RegulatoryAuthorizationType.Name
                        );
                        if (bl.PeriodStart != null) {
                            mapOfBL.put('periodstart','' + bl.PeriodStart.format('MM/dd/yyyy'));
                        }
                        mapOfBL.put('periodend', bl.PeriodEnd != null ? 
                            '' + bl.PeriodEnd.format('MM/dd/yyyy') : 
                            'No Expiration'
                        );
                        
                        mapOfBL.put('status', bl.Status);
                        if(bl.Status == LPI_LiteralConstant.VERIFIED_STATUS){
                            mapOfBL.put('statusClass','slds-badge slds-theme_info');
                            }
                           else if(bl.Status == LPI_LiteralConstant.Business_License_Status_EXPIRED){
                                mapOfBL.put('statusClass','slds-badge slds-theme_error');
                            }
                            else if(bl.Status == LPI_LiteralConstant.STATUS_ACTIVE){
                                mapOfBL.put('statusClass','slds-badge slds-theme_success');
                            }
                            else if(bl.Status == LPI_LiteralConstant.STATUS_INACTIVE){
                                mapOfBL.put('statusClass','slds-badge slds-theme_error');
                            }
                            else {
                                mapOfBL.put('statusClass','slds-badge slds-theme_disabled');
                            }
                        mapOfBL.put('regAuthId', bl.RegulatoryAuthorizationTypeId);
                        mapOfBL.put('licenseType',bl.RegulatoryAuthorizationType.Name);
                        mapOfBL.put('licenseNumber',bl.Name);
                        mapOfBL.put('board',bl.RegulatoryAuthorizationType.IssuingDepartment.Name);
                        mapOfBL.put('authorisationType',bl.RegulatoryAuthorizationType.Authorisation_Type__c);
                        if (bl.PeriodEnd != null && bl.PeriodEnd.Date() < System.today()) {
                            mapOfBL.put('lateRenewal', 'true');
                        } else {
                            mapOfBL.put('lateRenewal', 'false');
                        }
                        if(bl.Licensee_Modification_Reason__c == 'Contact ED')
                        {
                            mapOfBL.put('licenseeModification', 'true');
                        }
                        busLiceList.add(mapOfBL);
                    }
                }
            }
            return new Map<String,Object>{
                'licenseCount' => totalLicenseRecords,
                    'licenseList'  => busLiceList,
                    'statusWithCount' => mapOfStatusToCount
                    };
                        }
        catch(Exception ex) {
            LPI_ExceptionManager.logException(CLASS_NAME, 'getMyLicenseDetail', ex);
            throw new AuraHandledException(ex.getMessage());
        }
    }
    /**
    * @description 
    * @author MTX Group Product Team | 05-07-2024 
    * @param showAllLicenses 
    * @return Map<String, Object> 
    **/
    @AuraEnabled
    public static Map<String,Object> getMyAllLicenseDetails(boolean showAllLicenses){
        try {
            return getMyLicenseDetail(true,0,false, showAllLicenses);
        }
        catch(Exception ex) {
            LPI_ExceptionManager.logException(CLASS_NAME, 'getMyAllLicenseDetails', ex);
            throw new AuraHandledException(ex.getMessage());
        }
    }
    /**
    * @description 
    * @author MTX Group Product Team | 05-07-2024 
    * @return Map<String, Object> 
    **/
    @AuraEnabled
    public static Map<String,Object> getMyLicenseDetails(){
        try {
            Map<String,Object> licenseDetail = getMyLicenseDetail(false,6,false, false);
            Set<Id> accIdSet = getRelatedAccountId();
            Set<Id> lspAccSet = getLicenseServiceProviderAccIds();
            Integer applicationCountRecord = 0;
            Set<Id> parentId = new Set<Id>();
            for(BusinessLicenseApplication bla : new LPI_BusinessLicenseApplicationDAO.LPI_DAO_BusinessLiceWithoutSecurity().getBusinessLicenseApplicationByDymanicQuery(
                'Id, AccountId, Status__c','Status__c != NULL AND Status__c != \'Draft\' AND AccountId IN ' + LPI_ServiceUtility.getStringValuesBySet(accIdSet),null,null,null)){
                    if(lspAccSet.contains(bla.AccountId) && bla.Status__c != STATUS_DRAFT){
                        continue;
                    }
                    parentId.add(bla.Id);
                    applicationCountRecord += 1;
                }
            AggregateResult[] groupParResults = [SELECT Count(Id)coun 
                                                 FROM PreliminaryApplicationRef 
                                                 WHERE BusinessAccountNameId IN : accIdSet
                                                 AND  Status__c != NULL
                                                 AND IsSubmitted = false
                                                 AND (Status__c =: LPI_LiteralConstant.PAR_DRAFT_STATUS
                                                      OR Status__c =: LPI_LiteralConstant.IA_PAYMENT_PENDING_STATUS)
                                                 AND Channel__c = 'Online'];
            applicationCountRecord += Integer.ValueOf(groupParResults[0].get('coun'));
            
            for(IndividualApplication ia : new LPI_IndividualApplicationDAO.LPI_DAO_IndividualApptWithoutSecurity().getIndividualApplicationByDymanicQuery(
                'Id','Status__c != NULL AND Status__c != \'Draft\' AND AccountId IN ' + LPI_ServiceUtility.getStringValuesBySet(accIdSet),null,null,null)){
                    parentId.add(ia.Id);
                    applicationCountRecord += 1;
                }
            Integer paymentCountRecord = 0;  
            AggregateResult[] groupRatResults = [SELECT Count(Id)coun FROM RegulatoryTrxnFee WHERE ParentRecordId IN : parentId];
            paymentCountRecord = Integer.ValueOf(groupRatResults[0].get('coun'));
            return new Map<String,Object>{
                'licenseCount' => licenseDetail.get('licenseCount'),
                    'licenseList'  => licenseDetail.get('licenseList'),
                    'applicationCount' => applicationCountRecord,
                    'paymentCount' => paymentCountRecord
                    };
                        }
        catch(Exception ex) {
            LPI_ExceptionManager.logException(CLASS_NAME, 'getMyLicenseDetails', ex);
            throw new AuraHandledException(ex.getMessage());
        }
    }
    /**
    * @description 
    * @author MTX Group Product Team | 05-07-2024 
    * @param requiredAll 
    * @param count 
    * @param showAllApplications 
    * @return Map<String, Object> 
    **/
    private static Map<String,Object> getMyApplicationRecord(boolean requiredAll,Integer count, boolean showAllApplications){
        try {
            Set<String> ratNameSet = new Set<String>{'Certificate of Authority - Corporation', 'Certificate of Authority - LLC'};
            Set<Id> accIdSet = showAllApplications ? getRelatedAccIdsSet() : getRelatedAccountId(); 
            Set<Id> lspAccSet = getLicenseServiceProviderAccIds();  
            List<Map<String, String>> appList = new List<Map<String, String>>();
            Set<String> licenseTypeNameSet = new Set<String>();
            String queryWherePAR ='Status__c != NULL AND IsSubmitted = false AND Channel__c = \'Online\' AND ';
            queryWherePAR += ' BusinessAccountNameId IN '+ LPI_ServiceUtility.getStringValuesBySet(accIdSet);
            queryWherePAR += ' AND (Status__c= \'Draft\' OR Status__c=\'Payment Pending\')';
            List<PreliminaryApplicationRef> parList = new LPI_PreliminaryApplicationRefDAO.LPI_PreliminaryApplicationRefWithoutSharingDAO().getPreliminaryApplicationRefByDymanicQuery(
                'Id, Name, Status__c, Type__c,FirstName__c,LastName__c,MiddleName__c,Business_Name__c, toLabel(Amendment_Type__c), Regulatory_Authorization_Type__c,Profession__c, ApplicationType,Regulatory_Authorization_Type__r.Name,CreatedDate,SavedApplicationUrl, ViewApplicationURL__c,Business_License__c,BusinessAccountName.Name,'+
                'Regulatory_Authorization_Type__r.IssuingDepartment.Name,Regulatory_Authorization_Type__r.Authorisation_Type__c',
                queryWherePAR,requiredAll ? null : String.valueOf(count),'LastModifiedDate','DESC');
            Set<Id> parIdSet = (new Map<Id, PreliminaryApplicationRef>(parList))
                .keySet();
            Map<Id, String> parIdToURLMap = new Map<Id, String>();
            for (OmniScriptSavedSession oss : [
                SELECT Id, name, RelatedRecordIdentifier, RelativeResumeUrl
                FROM OmniScriptSavedSession
                WHERE RelatedRecordIdentifier IN :parIdSet
            ]) {
                if(String.isNotBlank(oss.RelativeResumeUrl) && !oss.RelativeResumeUrl.contains('omnistudio__vlocityLWCOmniWrapper')){
                    parIdToURLMap.put(oss.RelatedRecordIdentifier, oss.RelativeResumeUrl);
                }
            }
            Integer totalRecords = 0;
            Map<String,Integer> mapOfStatusToCount = new Map<String,Integer>();
            Map<String, String> applicationTypeLabelValueMap = new Map<String, String>();
            Schema.DescribeFieldResult fieldLabelResult = PreliminaryApplicationRef.Type__c.getDescribe(); 
            List<Schema.PicklistEntry> pickListValues = fieldLabelResult.getPicklistValues(); 
            for( Schema.PicklistEntry value : pickListValues) { 
                applicationTypeLabelValueMap.put(value.getValue() , value.getLabel());
            }
            for(PreliminaryApplicationRef par : parList) {
                totalRecords = totalRecords + 1;
                if(!mapOfStatusToCount.containsKey(par.Status__c)){
                    mapOfStatusToCount.put(par.Status__c,0);
                }
                mapOfStatusToCount.put(par.Status__c, mapOfStatusToCount.get(par.Status__c)+1);
                Map<String, String> mapOfPAR = new Map<String, String>();
                mapOfPAR.put('recordId',par.Id);
                mapOfPAR.put('name',par.Name);
                mapOfPAR.put(
                    'licencetypename',
                    ratNameSet.contains(par.Regulatory_Authorization_Type__r.Name) && String.isNotEmpty(par.Profession__c) ? par.Regulatory_Authorization_Type__r.Name+' - '+par.Profession__c : par.Regulatory_Authorization_Type__r.Name
                );
                licenseTypeNameSet.add( par.Regulatory_Authorization_Type__r.Name);
                mapOfPAR.put('ratNameValue',par.Regulatory_Authorization_Type__r.Name);
                mapOfPAR.put('applicationType', applicationTypeLabelValueMap.containsKey(par.Type__c) ? applicationTypeLabelValueMap.get(par.Type__c) : par.Type__c);
                mapOfPAR.put('subType', par.Amendment_Type__c);
                mapOfPAR.put('status', par.Status__c);
                if(par.Status__c == LPI_LiteralConstant.PAR_SUBMITTED_STATUS){
                mapOfPAR.put('statusClass','slds-badge slds-theme_info');
                }
                else if(par.Status__c == LPI_LiteralConstant.PAR_DRAFT_STATUS){
                mapOfPAR.put('statusClass','slds-badge slds-theme_disabled');
                }
                else if(par.Status__c == LPI_LiteralConstant.DENIED_STATUS){
                mapOfPAR.put('statusClass','slds-badge slds-theme_error');
                }
                else {
                mapOfPAR.put('statusClass','slds-badge slds-theme_disabled');
                }
                if (String.isEmpty(parIdToURLMap.get(par.Id))) {
                    mapOfPAR.put(
                        'resumeurl',
                        par.SavedApplicationUrl + '&blId=' + par.Business_License__c
                    );
                } else {
                    mapOfPAR.put(
                        'resumeurl',
                        parIdToURLMap.get(par.Id) + '&blId=' + par.Business_License__c
                    );
                }
                mapOfPAR.put(
                    'reinstatePaymentURL',
                    par.SavedApplicationUrl + '&blId=' + par.Business_License__c
                );
                mapOfPAR.put('showWithdrawn', 'true');
                mapOfPAR.put('applicantBusinessName',String.isNotBlank(par.Business_Name__c) ? par.Business_Name__c : (String.isNotBlank(par.FirstName__c) ? 
                (par.FirstName__c + (String.isNotBlank(par.MiddleName__c) ? ' '+par.MiddleName__c+' '+par.LastName__c : ' '+par.LastName__c)) : par.BusinessAccountName.Name));
                mapOfPAR.put('showview', 'false');
                mapOfPAR.put('showreinstate', par.Status__c=='Payment Pending'?'true':'false');
                mapOfPAR.put('url', par.ViewApplicationURL__c);
                appList.add(mapOfPAR);
            }
            String queryWhereIA = '';
            queryWhereIA += ' Status__c != NULL AND Status__c != \'Draft\' AND AccountId IN '+LPI_ServiceUtility.getStringValuesBySet(accIdSet);
            for (IndividualApplication ia : new LPI_IndividualApplicationDAO.LPI_DAO_IndividualApptWithoutSecurity().getIndividualApplicationByDymanicQuery(
                'Id,Name,Applicant_Name__c, ApplicationType, toLabel(Amendment_Type__c), toLabel(Status__c), Status, AppliedDate, SavedApplicationRefId,LicenseTypeId,LicenseType.Name, SavedApplicationRef.ViewApplicationURL__c,Account.Name,'+
                'LicenseType.IssuingDepartment.Name,LicenseType.Authorisation_Type__c',
                queryWhereIA,
                requiredAll ? null : String.valueOf(count),
                'LastModifiedDate',
                'DESC'
            )) {
                totalRecords = totalRecords + 1;
                String portalStatus = resolvePortalApplicationStatus(ia.Status, ia.Status__c);
                if(!mapOfStatusToCount.containsKey(portalStatus)){
                    mapOfStatusToCount.put(portalStatus,0);
                }
                mapOfStatusToCount.put(portalStatus, mapOfStatusToCount.get(portalStatus)+1);
                Map<String, String> mapOfIA = new Map<String, String>();
                mapOfIA.put('recordId', ia.Id);
                mapOfIA.put('name', ia.Name);
                mapOfIA.put('parid', ia.SavedApplicationRefId);
                mapOfIA.put('submitteddate',ia.AppliedDate.format('MM/dd/yyyy')); 
                mapOfIA.put('showview', 'true');
                
                mapOfIA.put('showreinstate', ia.Status=='Payment Failed'?'true':'false');
                mapOfIA.put('applicantBusinessName', String.isNotBlank(ia.Applicant_Name__c) ? ia.Applicant_Name__c : ia.Account.Name);
                mapOfIA.put('applicationType', applicationTypeLabelValueMap.containsKey(ia.ApplicationType) ? applicationTypeLabelValueMap.get(ia.ApplicationType) : ia.ApplicationType);
                mapOfIA.put('subType', ia.Amendment_Type__c);
                
                mapOfIA.put('status', portalStatus);
                
                if(portalStatus == LPI_LiteralConstant.IA_REQUEST_FOR_REFUND_STATUS){
                mapOfIA.put('statusClass','slds-badge slds-theme_warning');
                }
                else if(ia.Status__c == LPI_LiteralConstant.IA_SUBMITTED_STATUS){
                mapOfIA.put('statusClass','slds-badge slds-theme_info');
                }
                else if(ia.Status__c == LPI_LiteralConstant.IA_DRAFT_STATUS){
                mapOfIA.put('statusClass','slds-badge slds-theme_disabled');
                }
                else if(ia.Status__c == LPI_LiteralConstant.BLA_UNDER_REVIEW_STATUS){
                mapOfIA.put('statusClass','slds-badge slds-theme_info');
                }
                else if(ia.Status__c == LPI_LiteralConstant.IA_IN_PROGRESS_STATUS){
                mapOfIA.put('statusClass','slds-badge slds-theme_warning');
                }
                else if(ia.Status__c == LPI_LiteralConstant.DENIED_STATUS){
                mapOfIA.put('statusClass','slds-badge slds-theme_error');
                }
                else if(ia.Status__c == LPI_LiteralConstant.IA_APPROVED_STATUS){
                mapOfIA.put('statusClass','slds-badge slds-theme_success');
                }
                else if(ia.Status__c == LPI_LiteralConstant.IA_LICENSEISSUED_STATUS){
                mapOfIA.put('statusClass','slds-badge slds-theme_success');
                }
                else if(ia.Status__c == LPI_LiteralConstant.STATUS_ACTIVE){
                mapOfIA.put('statusClass','slds-badge slds-theme_success');
                }
                else if(ia.Status__c == LPI_LiteralConstant.STATUS_INACTIVE){
                mapOfIA.put('statusClass','slds-badge slds-theme_error');
                }
                else {
                mapOfIA.put('statusClass','slds-badge slds-theme_disabled');
                }
                mapOfIA.put('statusreason', ia.Status);
                mapOfIA.put('licencetypename', ia.LicenseType.Name);
                mapOfIA.put('ratNameValue',ia.LicenseType.Name);
                licenseTypeNameSet.add(ia.LicenseType.Name);
                mapOfIA.put('showWithdrawn', 'false');
                mapOfIA.put('url', ia.SavedApplicationRef.ViewApplicationURL__c);
                appList.add(mapOfIA);
            }
            String queryWhereBLA = '';
            queryWhereBLA += ' Status__c != NULL AND Status__c != \'Draft\' AND AccountId IN '+LPI_ServiceUtility.getStringValuesBySet(accIdSet);
            for (BusinessLicenseApplication bl : new LPI_BusinessLicenseApplicationDAO.LPI_DAO_BusinessLiceWithoutSecurity().getBusinessLicenseApplicationByDymanicQuery(
                'Id,Name, toLabel(Status__c), Business_Name__c, toLabel(Amendment_Type__c), Applicant_submission_Date__c,Profession__c, Licence_Type_Name__c,ApplicationType,Status,SavedApplicationRefId, SavedApplicationRef.ViewApplicationURL__c,Account.Name,'+
                'LicenseType.IssuingDepartment.Name,LicenseType.Authorisation_Type__c',
                queryWhereBLA,
                requiredAll ? null : String.valueOf(count),
                'LastModifiedDate',
                'DESC'
            )) {
                if(lspAccSet.contains(bl.AccountId) && bl.Status__c != STATUS_DRAFT){
                    continue;
                }
                totalRecords = totalRecords + 1;
                String portalStatus = resolvePortalApplicationStatus(bl.Status, bl.Status__c);
                if(!mapOfStatusToCount.containsKey(portalStatus)){
                    mapOfStatusToCount.put(portalStatus,0);
                }
                mapOfStatusToCount.put(portalStatus, mapOfStatusToCount.get(portalStatus)+1);
                Map<String, String> mapOfBL = new Map<String, String>();
                mapOfBL.put('recordId', bl.Id);
                mapOfBL.put('parid', bl.SavedApplicationRefId);
                mapOfBL.put('name', bl.Name);
                mapOfBL.put('showview', 'true');
                if (bl.Applicant_submission_Date__c != null) {
                    mapOfBL.put(
                        'submitteddate',
                        bl.Applicant_submission_Date__c.month() +
                        '/' +
                        bl.Applicant_submission_Date__c.day() +
                        '/' +
                        bl.Applicant_submission_Date__c.year()
                    );
                }
                mapOfBL.put('showreinstate', bl.Status=='Payment Failed'?'true':'false');
                mapOfBL.put('applicantBusinessName',String.isNotBlank(bl.Business_Name__c) ? bl.Business_Name__c : bl.Account.Name);
                
                mapOfBL.put('licencetypename', ratNameSet.contains(bl.Licence_Type_Name__c) && String.isNotEmpty(bl.Profession__c) ? bl.Licence_Type_Name__c+' - '+bl.Profession__c : bl.Licence_Type_Name__c);
                mapOfBL.put('ratNameValue',bl.Licence_Type_Name__c);
                licenseTypeNameSet.add(bl.Licence_Type_Name__c);
                mapOfBL.put('applicationType', applicationTypeLabelValueMap.containsKey(bl.ApplicationType) ? applicationTypeLabelValueMap.get(bl.ApplicationType) : bl.ApplicationType);
                mapOfBL.put('subType', bl.Amendment_Type__c);
                
                mapOfBL.put('status', portalStatus);
                if(portalStatus == LPI_LiteralConstant.IA_REQUEST_FOR_REFUND_STATUS){
                    mapOfBL.put('statusClass','slds-badge slds-theme_warning');
                }
                else if(bl.Status__c == LPI_LiteralConstant.BLA_SUBMITTED_STATUS){
                mapOfBL.put('statusClass','slds-badge slds-theme_info');
                }
                else if(bl.Status__c == LPI_LiteralConstant.BLA_DRAFT_STATUS){
                    mapOfBL.put('statusClass','slds-badge slds-theme_disabled');
                }
                else if(bl.Status__c == LPI_LiteralConstant.DENIED_STATUS){
                    mapOfBL.put('statusClass','slds-badge slds-theme_error');
                }
                else if(bl.Status__c == LPI_LiteralConstant.BLA_UNDER_REVIEW_STATUS){
                    mapOfBL.put('statusClass','slds-badge slds-theme_info');
                }
                else if(bl.Status__c == LPI_LiteralConstant.IA_IN_PROGRESS_STATUS){
                    mapOfBL.put('statusClass','slds-badge slds-theme_warning');
                }
                else if(bl.Status__c == LPI_LiteralConstant.BLA_APPROVED_STATUS){
                    mapOfBL.put('statusClass','slds-badge slds-theme_success');
                }
                else if(bl.Status__c == LPI_LiteralConstant.BLA_LICENSEISSUED_STATUS){
                    mapOfBL.put('statusClass','slds-badge slds-theme_success');
                }
                else if(bl.Status__c == LPI_LiteralConstant.STATUS_ACTIVE){
                    mapOfBL.put('statusClass','slds-badge slds-theme_success');
                }
                else if(bl.Status__c == LPI_LiteralConstant.STATUS_INACTIVE){
                    mapOfBL.put('statusClass','slds-badge slds-theme_error');
                }
                else {
                    mapOfBL.put('statusClass','slds-badge slds-theme_disabled');
                }
                mapOfBL.put('statusreason', bl.Status);
                mapOfBL.put('showWithdrawn', 'false');
                mapOfBL.put('url', bl.SavedApplicationRef.ViewApplicationURL__c);
                appList.add(mapOfBL);
            }
            if(!licenseTypeNameSet.isEmpty()){
                Map<String,String> subTypeConfigMap = LPI_ServiceUtility.getSubTypeLabelToShowMap(licenseTypeNameSet);
                for(Map<String,String> appData : appList){
                    String keyToCheck = appData.get('ratNameValue')+' '+appData.get('applicationType')+' '+appData.get('subType');
                    
                    if(subTypeConfigMap.containsKey(keyToCheck)){
                         
                        appData.put('subType',subTypeConfigMap.get(keyToCheck));
                    }
                }
            }
    
            return new Map<String,Object>{
                'applicationCount' => totalRecords,
                    'applicationList' => appList,
                    'statusWithCount' => mapOfStatusToCount
                    };
                        } catch (Exception ex) {
                            LPI_ExceptionManager.logException(CLASS_NAME, 'getMyApplicationRecord', ex);
                            throw new AuraHandledException(ex.getMessage());
                        }
    }
    /**
    * @description 
    * @author MTX Group Product Team | 05-07-2024 
    * @param showAllApplications 
    * @return Map<String, Object> 
    **/
    @AuraEnabled
    public static Map<String,Object> fetchAllApplicationRecords(boolean showAllApplications) {
        try {
            return getMyApplicationRecord(true,0, showAllApplications);  
        } catch (Exception ex) {
            LPI_ExceptionManager.logException(CLASS_NAME, 'fetchAllApplicationRecords', ex);
            throw new AuraHandledException(ex.getMessage());
        }
    }
    /**
    * @description 
    * @author MTX Group Product Team | 05-07-2024 
    * @return Map<String, Object> 
    **/
    @AuraEnabled
    public static Map<String,Object> fetchApplicationRecords() {
        try {
            return getMyApplicationRecord(false,5, false); 
        } catch (Exception ex) {
            LPI_ExceptionManager.logException(CLASS_NAME, 'fetchApplicationRecords', ex);
            throw new AuraHandledException(ex.getMessage());
        }
    }
    /**
    * @description 
    * @author MTX Group Product Team | 05-07-2024 
    * @param requiredAll 
    * @param count 
    * @param showAllPayments 
    * @return Map<String, Object> 
    **/
    private static Map<String,Object> getMyPaymentRecord(boolean requiredAll,Integer count, boolean showAllPayments){
        try{
            Set<Id> accIdSet = showAllPayments ? getRelatedAccIdsSet() : getRelatedAccountId();  
            Map<Id,SObject> mapOfParentIdwithParIns = new Map<Id,SObject>();
            for(BusinessLicenseApplication bla : LPI_BusinessLicenseApplicationDAO.getBusinessLicenseApplicationByDymanicQuery(
                'Id,Name,Amendment_Type__c,Licence_Type_Name__c,LicenseType.Name,SavedApplicationRefId','Status__c != NULL AND Status__c != \'Draft\' AND AccountId IN ' + LPI_ServiceUtility.getStringValuesBySet(accIdSet),null,null,null)){
                    mapOfParentIdwithParIns.put(bla.Id,bla);
                }
            
            for(IndividualApplication ia : LPI_IndividualApplicationDAO.getIndividualApplicationByDymanicQuery(
                'Id,Name,Amendment_Type__c,License_Type_Name__c,LicenseType.Name,SavedApplicationRefId','Status__c != NULL AND Status__c != \'Draft\' AND AccountId IN ' + LPI_ServiceUtility.getStringValuesBySet(accIdSet),null,null,null)){
                    mapOfParentIdwithParIns.put(ia.Id,ia);
                }
            Set<Id> parentId = mapOfParentIdwithParIns.keySet();
            List<Map<String,Object>> regulatoryTrxnFeeList = new List<Map<String,Object>>();
            String query = 'SELECT Id, Name, TotalFeeAmount,Transaction_Date__c, ParentRecordId, ParentRecord.name, Status__c, Status, Transaction_Fee_Amount__c FROM RegulatoryTrxnFee WHERE ParentRecordId IN: parentId AND TotalFeeAmount>0';
            query+=' ORDER BY CreatedDate DESC';
            if(!requiredAll){
                query += ' LIMIT '+ String.valueOf(count);
            }
            Integer totalRecords = 0;
            Map<String,Integer> mapOfStatusToCount = new Map<String,Integer>();
            for(SObject obj: Database.query(query)){
                totalRecords = totalRecords + 1;
                if(!mapOfStatusToCount.containsKey((String)obj.get('Status__c'))){
                    mapOfStatusToCount.put((String)obj.get('Status__c'),0);
                }
                mapOfStatusToCount.put((String)obj.get('Status__c'), mapOfStatusToCount.get((String)obj.get('Status__c'))+1);
                Map<String,Object> regulatoryTrxnFeeMap = new Map<String,Object>();
                regulatoryTrxnFeeMap.put('Name',obj.get('Name'));
                regulatoryTrxnFeeMap.put('Id',obj.get('ParentRecordId'));
                regulatoryTrxnFeeMap.put('TotalFeeAmount','$'+((Decimal) obj.get('TotalFeeAmount') + (obj.get('Transaction_Fee_Amount__c') == null ? 0 :(Decimal) obj.get('Transaction_Fee_Amount__c'))));
                Datetime dt = (Datetime) obj.get('Transaction_Date__c');
                Date transactionDate = dt?.date();
                regulatoryTrxnFeeMap.put('Transaction_Date__c', transactionDate?.format());
                String LicenseTypeName = '';
                Id parentRecordId = (Id) obj.get('ParentRecordId');
                SObjectType parentObjectType = parentRecordId.getSObjectType();
                if (parentObjectType == IndividualApplication.SObjectType){
                    regulatoryTrxnFeeMap.put('LicenseTypeName',mapOfParentIdwithParIns.get(parentRecordId).get('License_Type_Name__c'));
                }
                else{
                    regulatoryTrxnFeeMap.put('LicenseTypeName',mapOfParentIdwithParIns.get(parentRecordId).get('Licence_Type_Name__c'));
                }
                regulatoryTrxnFeeMap.put('Amendment_Type__c',mapOfParentIdwithParIns.get((Id) obj.get('ParentRecordId')).get('Amendment_Type__c'));
                regulatoryTrxnFeeMap.put('ParentRecordId',obj.get('ParentRecordId')); 
                regulatoryTrxnFeeMap.put('ParentRecordName',mapOfParentIdwithParIns.get((Id) obj.get('ParentRecordId')).get('Name'));
                regulatoryTrxnFeeMap.put('parId',mapOfParentIdwithParIns.get((Id) obj.get('ParentRecordId')).get('SavedApplicationRefId'));
                regulatoryTrxnFeeMap.put('Status__c',obj.get('Status__c'));
                if(obj.get('Status__c') == LPI_LiteralConstant.FEE_PAID_STATUS){
                    regulatoryTrxnFeeMap.put('statusClass','slds-badge slds-theme_success'); 
                }
                else if(obj.get('Status__c') == LPI_LiteralConstant.FEE_FAILED_STATUS){
                    regulatoryTrxnFeeMap.put('statusClass','slds-badge slds-theme_error'); 
                }
                else if(obj.get('Status__c') == LPI_LiteralConstant.PENDING_STATUS){
                    regulatoryTrxnFeeMap.put('statusClass','slds-badge slds-theme_warning'); 
                }
                else if(obj.get('Status__c') == LPI_LiteralConstant.FEE_CANCEL_STATUS){
                    regulatoryTrxnFeeMap.put('statusClass','slds-badge slds-theme_disabled'); 
                }
                else if(obj.get('Status__c') == LPI_LiteralConstant.DECLINED_STATUS){
                    regulatoryTrxnFeeMap.put('statusClass','slds-badge slds-theme_error'); 
                }
                else {
                    regulatoryTrxnFeeMap.put('statusClass','slds-badge slds-theme_disabled');
                }
                
                regulatoryTrxnFeeList.add(regulatoryTrxnFeeMap);
            }
            return new Map<String,Object>{
                'paymentCount' => totalRecords,
                    'paymentList' => regulatoryTrxnFeeList,
                    'statusWithCount' => mapOfStatusToCount
                    };
                        } catch(Exception e) {
                            LPI_ExceptionManager.logException(CLASS_NAME, 'getMyPaymentRecord', e);
                            throw new AuraHandledException(e.getMessage());
                        }
    }
    /**
    * @description 
    * @author MTX Group Product Team | 05-07-2024 
    * @param showAllPayments 
    * @return Map<String, Object> 
    **/
    @AuraEnabled
    public static Map<String,Object> fetchAllPaymentRecord(boolean showAllPayments) {
        try{
            return getMyPaymentRecord(true,0, showAllPayments);
        } catch(Exception e) {
            LPI_ExceptionManager.logException(CLASS_NAME, 'fetchAllPaymentRecord', e);
            throw new AuraHandledException(e.getMessage());
        }
    }
    /**
    * @description 
    * @author MTX Group Product Team | 05-07-2024 
    * @return Map<String, Object> 
    **/
    @AuraEnabled
    public static Map<String,Object> fetchPaymentRecord() {
        try{
            return getMyPaymentRecord(false,5, false);
        } catch(Exception e) {
            LPI_ExceptionManager.logException(CLASS_NAME, 'fetchDashboardPayment', e);
            throw new AuraHandledException(e.getMessage());
        }
    }
    /**
    * @description 
    * @author MTX Group Product Team| 05-07-2024 
    * @param inputMap 
    * @return String 
    **/
    @AuraEnabled
    public static String launchApplication(Map<String, Object> inputMap){
        System.debug('@@@ launchApplication inputMap: ' + JSON.serializePretty(inputMap));
        try {
            Boolean isBadCheck =  LPI_ApplicationFlowUtility.fetchBLBadCheck(inputMap);
            System.debug('@@@ isBadCheck Result: ' + isBadCheck);
            if(isBadCheck){
                return 'BadCheck';
            } else {
                Boolean isActionAllowed =  LPI_ApplicationFlowUtility.setActionAllowedValidation(inputMap);
                System.debug('@@@ isActionAllowed Result: ' + isActionAllowed);
                if(isActionAllowed){
                    Map<String,Object> resultMap = LPI_ApplicationFlowUtility.createPARRecord(inputMap,null);
                    System.debug('@@@ createPARRecord resultMap: ' + resultMap);
                    if(resultMap != null){
                        return resultMap.containsKey('parRec') ? ((PreliminaryApplicationRef)resultMap.get('parRec')).SavedApplicationUrl : 'Error';
                    }else{
                        return 'Error';
                    }
                }else{
                    return 'Duplicate';
                }
            }
        } catch (Exception e) {
            LPI_ExceptionManager.logException(CLASS_NAME, 'launchApplication', e);
            throw new AuraHandledException(e.getMessage());
        }
    }
    /**
    * @description 
    * @author MTX Group Product Team | 05-07-2024 
    * @param blid 
    * @return List<ButtonWrapper> 
    **/
    @AuraEnabled
    public static List<ButtonWrapper> fetchAmendmentSubtype(String blid){
        
            String fieldsToQuery = ' Id,Name,Status,RegulatoryAuthorizationType.Eligible_Additional_License_Type__c,RegulatoryAuthorizationType.Eligible_License_Type_Change__c,RegulatoryAuthorizationType.Amendment_Type__c,RegulatoryAuthorizationTypeId,RegulatoryAuthorizationType.Name, ';
            fieldsToQuery += '(SELECT Status FROM IndividualApplicationPermit WHERE ';
            fieldsToQuery += ' LicenseType.Name IN ' + LPI_ServiceUtility.getStringValuesByStringSet(LPI_ApplicationViewController.PROF_CORP_NAME_APPROVAL_SET);
            fieldsToQuery += ' AND ApplicationType = \'' + String.escapeSingleQuotes('Amendment') + '\'';
            fieldsToQuery += ' AND Amendment_Type__c = \'' + String.escapeSingleQuotes(LPI_ApplicationViewController.PROFESSIONAL_CORPORATION_NAME_APPROVAL) + '\'';
            fieldsToQuery += ' AND Status = \'' + APPROVED_STATUS + '\' )';
            String whereClause = ' Id = \'' + blid + '\'';
             
            List<BusinessLicense> blRecord = new LPI_BusinessLicenseDAO.LPI_BusinessLicenseWithoutSharingDAO().getBusinessLicenseByDymanicQueryWithoutSecurity(
                fieldsToQuery,whereClause,null,' CreatedDate','DESC');
            
            List<ButtonWrapper> childButtonList = new List<ButtonWrapper>();
            if(!blRecord.isEmpty()){
                Map<String, Boolean> isActionAllowedMap = LPI_ApplicationViewController.getIsActionAllowedMap(blRecord[0].RegulatoryAuthorizationTypeId,
                                                                                                                blRecord[0].Status,
                                                                                                                false
                                                                                                               );
                
                if (blRecord[0].RegulatoryAuthorizationType.Amendment_Type__c != null) {
                    List<Schema.PicklistEntry> fieldResult = RegulatoryAuthorizationType.Eligible_License_Type_Change__c.getDescribe()
                        .getPicklistValues();
                    Map<String, String> apiNameToLabelMap = new Map<String, String>();
                    for (Schema.PicklistEntry pickListVal : fieldResult) {
                        apiNameToLabelMap.put(
                            pickListVal.getValue(),
                            pickListVal.getLabel()
                        );
                    }
                    List<Schema.PicklistEntry> amendmentTypefieldResult = RegulatoryAuthorizationType.Amendment_Type__c.getDescribe()
                        .getPicklistValues();
                    for (Schema.PicklistEntry pickListVal : amendmentTypefieldResult) {
                        apiNameToLabelMap.put(
                            pickListVal.getValue(),
                            pickListVal.getLabel()
                        );
                    }
                    for (String actions : blRecord[0].RegulatoryAuthorizationType.Amendment_Type__c.split(';')) {
                        List<ButtonWrapper> childOfChildButtonList = new List<ButtonWrapper>();
                        if (isActionAllowedMap.containsKey('Amendment' + actions) &&isActionAllowedMap.get('Amendment' + actions)) {
                            
                            if (actions == 'Change status to other status' &&
                                blRecord[0].RegulatoryAuthorizationType.Eligible_License_Type_Change__c !=null) {
                                    
                                    for (String childAction : blRecord[0].RegulatoryAuthorizationType.Eligible_License_Type_Change__c.split(';')) {
                                        childOfChildButtonList.add(
                                            new ButtonWrapper(
                                                apiNameToLabelMap.containsKey(
                                                    childAction
                                                )
                                                ? apiNameToLabelMap.get(childAction)
                                                : childAction,
                                                childAction,
                                                false,
                                                null,
                                                ''
                                            )
                                        );
                                    }
                                    childButtonList.add(
                                        new ButtonWrapper(
                                            actions,
                                            actions,
                                            true,
                                            childOfChildButtonList,
                                            'Change status to'
                                        )
                                    );
                                } else {
                                    if (actions == 'Obtain Additional License' &&
                                        blRecord[0].RegulatoryAuthorizationType.Eligible_Additional_License_Type__c !=null) {
                                            for (String childAction : blRecord[0].RegulatoryAuthorizationType.Eligible_Additional_License_Type__c.split(';')) {
                                                childOfChildButtonList.add(
                                                    new ButtonWrapper(
                                                        apiNameToLabelMap.containsKey(
                                                            childAction
                                                        )
                                                        ? apiNameToLabelMap.get(
                                                            childAction
                                                        )
                                                        : childAction,
                                                        childAction,
                                                        false,
                                                        null,
                                                        ''
                                                    )
                                                );
                                            }
                                            childButtonList.add(
                                                new ButtonWrapper(
                                                    actions,
                                                    actions,
                                                    true,
                                                    childOfChildButtonList,
                                                    'Select License Type'
                                                )
                                            );
                                        } else if(
                                            actions != LPI_ApplicationViewController.PROFESSIONAL_CORPORATION_TYPE ||
                                            (
                                                actions == LPI_ApplicationViewController.PROFESSIONAL_CORPORATION_TYPE &&
                                                blRecord[0].IndividualApplicationPermit.size() > 0
                                            )
                                        ){
                                            childButtonList.add(
                                                new ButtonWrapper(
                                                    apiNameToLabelMap.containsKey(actions) ? apiNameToLabelMap.get(actions) : actions,
                                                    actions,
                                                    false,
                                                    null,
                                                    ''
                                                )
                                            );
                                        }
                                }
                        }
                    }
                }
            }
           
            return childButtonList;
         
    }

    @AuraEnabled
    public static String getResumeLink(String parId){
        try {
            String resumeUrl;
            String searchPattern = 'c__parid=' + parId;
            
            // Query OmniScriptSavedSession ordered by CreatedDate DESC
            // Cannot use LIKE filter on Long Text Area field, so filter in Apex
            List<OmniScriptSavedSession> savedSessions = [
                SELECT Id, RelativeResumeUrl 
                FROM OmniScriptSavedSession 
                ORDER BY CreatedDate DESC 
                LIMIT 500
            ];
            
            // Find the session with matching PAR ID in the URL
            for (OmniScriptSavedSession session : savedSessions) {
                if (String.isNotBlank(session.RelativeResumeUrl) && 
                    session.RelativeResumeUrl.contains(searchPattern)) {
                    resumeUrl = session.RelativeResumeUrl;
                    break;
                }
            }
            
            return resumeUrl;
        } catch (Exception e) {
            LPI_ExceptionManager.logException(CLASS_NAME, 'getResumeLink', e);
            throw new AuraHandledException(e.getMessage());
        }
    }


    /**
    * @description 
    * @author MTX Group Product Team | 05-07-2024 
    * @return Map<String, Object> 
    **/
    @AuraEnabled
    public static Map<String,Object> getMyAllRenewLicenseDetails(){
        try {
            return getMyLicenseDetail(true,0,true, false);
        }
        catch(Exception ex) {
            LPI_ExceptionManager.logException(CLASS_NAME, 'getMyAllRenewLicenseDetails', ex);
            throw new AuraHandledException(ex.getMessage());
        }
    }
    public class ButtonWrapper {
        @AuraEnabled
        public String buttonLable;
        @AuraEnabled
        public String buttonName;
        @AuraEnabled
        public boolean hasChild;
        @AuraEnabled
        public String headingLabel;
        @AuraEnabled
        public List<ButtonWrapper> childButton;
        public ButtonWrapper(
            String buttonLable,
            String buttonName,
            boolean hasChild,
            List<ButtonWrapper> childButton,
            String headingLabel
        ) {
            this.buttonLable = buttonLable;
            this.buttonName = buttonName;
            this.hasChild = hasChild;
            this.childButton = childButton;
            this.headingLabel = headingLabel;
        }
    }

    /**
    * @description This method is to return all the related accounts of user
    * @author MTX Group Product Team | 05-07-2024 
    * @return Set<Id> 
    **/
    public static Set<Id> getRelatedAccIdsSet() {
        try{
            Set<Id> accountIdSet = new Set<Id>();
            List<String> allowedRoles = new List<String>();
            for(String va: LPI_ApexSharingForPortalBatch.rolesSet){
                allowedRoles.add(va);
            }
            allowedRoles.add('Temporary Clerk');
            allowedRoles.add('License Service Provider');
            allowedRoles.add('Not Applicable');
            User usrData = LPI_WithoutSharingUtility.getUserRecordDetailWithoutSharing(Userinfo.getUserId());
            accountIdSet.add(usrData.AccountId);
            String fieldsToQueryACRs = 'Id, Related_From__c';
            String whereClauseForRelationship = 'Related_To__c = \'' + String.escapeSingleQuotes(usrData.AccountId) + '\''+
                            ' AND Roles__c IN '+ LPI_ServiceUtility.getStringValuesByList(allowedRoles) + 
                            ' AND Start_Date__c != NULL '+
                            ' AND EndDate__c = NULL';
            for(Business_Relationships__c relRec : new LPI_BusinessRelationshipDAO.LPI_BusinessRelationshipsWithoutSharingDAO().getBusinessRelationshipsByDymanicQuery(
                fieldsToQueryACRs,
                whereClauseForRelationship, 
                null,null,null
            )){
                accountIdSet.add(relRec.Related_From__c);
            }
            Set<Id> accIdSet = LPI_RelationshipService.getRelatedAccountIdFromMultipleAccount(accountIdSet);
            return accIdSet;
        } catch (Exception e) {
            LPI_ExceptionManager.logException(
                'LPI_DashbaordTableCtrl',
                'getRelatedAccIdsSet',
                e
            );
            throw new AuraHandledException(e.getMessage()+ e.getStackTraceString());
        }
    }

    /**
    * @description This method is to return all license service provider users
    * @author MTX Group Product Team | 05-07-2024 
    * @return Set<Id> 
    **/
    public static Set<Id> getLicenseServiceProviderAccIds(){
        Set<Id> licenseServiceProviderAccIdsSet = new Set<Id>();
        User usrData = LPI_WithoutSharingUtility.getUserRecordDetailWithoutSharing(Userinfo.getUserId());
        String fieldsToQueryACRs = 'Id, Related_From__c';
        String whereClauseForRelationship = 'Related_To__c = \'' + String.escapeSingleQuotes(usrData.AccountId) + '\''+
                        ' AND Roles__c = \'' + LICENSE_SERVICE_PROVIDER_ROLE +'\''+
                        ' AND Start_Date__c != NULL '+
                        ' AND EndDate__c = NULL';
        for(Business_Relationships__c relRec : new LPI_BusinessRelationshipDAO.LPI_BusinessRelationshipsWithoutSharingDAO().getBusinessRelationshipsByDymanicQuery(
            fieldsToQueryACRs,
            whereClauseForRelationship, 
            null,null,null
        )){
            licenseServiceProviderAccIdsSet.add(relRec.Related_From__c);
        }
        return licenseServiceProviderAccIdsSet;
    }
    public class InstitutionWrapper {
        @AuraEnabled public String accountName { get; set; }
        @AuraEnabled public String accountPhone { get; set; }
        @AuraEnabled public String accountWebsite { get; set; }
        @AuraEnabled public String accountFax { get; set; }
        @AuraEnabled public String accountEmail { get; set; }
        @AuraEnabled public AddressInstitutionWrapper addressStreetData { get; set; }
        @AuraEnabled public AddressInstitutionWrapper addressData { get; set; }
    }
    public class AddressInstitutionWrapper {
        @AuraEnabled public String city { get; set; }
        @AuraEnabled public String state { get; set; }
        @AuraEnabled public String street { get; set; }
        @AuraEnabled public String country { get; set; }
        @AuraEnabled public String zip { get; set; }
    }

    public class RemittanceWrapper {
        @AuraEnabled public String accountName { get; set; }
        @AuraEnabled public String licenseId { get; set; }
        @AuraEnabled public String accountPhone { get; set; }
        @AuraEnabled public String program { get; set; }
        @AuraEnabled public Decimal tuitionFee { get; set; }
        @AuraEnabled public Decimal totalStudentRemittedFee { get; set; }
        @AuraEnabled public Date startDateProgram { get; set; }
        @AuraEnabled public Date endDateProgram { get; set; }
        @AuraEnabled public AddressInstitutionWrapper addressData { get; set; }
    }

    @AuraEnabled
    public static void saveInstitutionAccount(String wrapper) {
        try {
            InstitutionWrapper accountResult = (InstitutionWrapper)JSON.deserialize(wrapper, InstitutionWrapper.class);
            // Create a new Account record based on the wrapper data
            Account newAccount = new Account();
            newAccount.Name = accountResult.accountName;
            newAccount.Phone = accountResult.accountPhone;
            newAccount.Website = accountResult.accountWebsite;
            newAccount.Fax = accountResult.accountFax;
            newAccount.Buisness_Email__c = accountResult.accountEmail;
            // mailing address
            newAccount.BillingCity = accountResult?.addressData?.city;
            newAccount.BillingStateCode = accountResult?.addressData?.state;
            newAccount.BillingStreet = accountResult?.addressData?.street;
            newAccount.BillingCountry = accountResult?.addressData?.country;
            newAccount.BillingPostalCode = accountResult?.addressData?.zip;

            // Shipping address
            newAccount.ShippingCity = accountResult?.addressStreetData?.city;
            newAccount.ShippingStateCode = accountResult?.addressStreetData?.state;
            newAccount.ShippingStreet = accountResult?.addressStreetData?.street;
            newAccount.ShippingCountry = accountResult?.addressStreetData?.country;
            newAccount.ShippingPostalCode = accountResult?.addressStreetData?.zip;

            // Insert the Account record
            insert newAccount;
            List<User> currentUserInfoList = LPI_UserDao.getCurrentUserRecord();

			Business_Relationships__c brRecord = new Business_Relationships__c();
			brRecord.Roles__c = 'Other';
			brRecord.Related_From__c = currentUserInfoList[0].AccountId;
			brRecord.Related_To__c = newAccount.Id;
			brRecord.Start_Date__c = Date.today();
			brRecord.IsActive__c = true;
            insert brRecord;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static void saveRemittanceFee(String wrapper) {
        RemittanceWrapper remittanceWrapperData = (RemittanceWrapper)JSON.deserialize(wrapper, RemittanceWrapper.class);
        List<IndividualApplication> IndividualApplicationList = [SELECT Id,AccountId
                                                                    FROM IndividualApplication 
                                                                    WHERE LicensePermitNameId =: remittanceWrapperData.licenseId];
        RegulatoryTrxnFee regTrxnFee = new RegulatoryTrxnFee();
        if (IndividualApplicationList.isEmpty()) {
            throw new LPI_Exception('No data found!');
        }
        regTrxnFee.AccountId = IndividualApplicationList[0].AccountId;
        regTrxnFee.ParentRecordId = IndividualApplicationList[0].Id;
        regTrxnFee.Status = 'Due';  
        regTrxnFee.Status__c = 'Pending';
        regTrxnFee.Comments = 'Student Protection Fee';
        regTrxnFee.Transaction_Date__c = System.now();
        insert regTrxnFee;

        RegulatoryTrxnFeeItem regTrxnFeeItem = new RegulatoryTrxnFeeItem();
        regTrxnFeeItem.RegulatoryTrxnFeeId = regTrxnFee.Id;
        regTrxnFeeItem.Name = 'Remittance Protection Fee';
        regTrxnFeeItem.FeeAmount = remittanceWrapperData.totalStudentRemittedFee;
        insert regTrxnFeeItem;
    }

    /**
     * Portal My Applications displays Status__c, but Request for Refund is stored on standard Status.
     */
    private static String resolvePortalApplicationStatus(String standardStatus, String customStatus) {
        if (standardStatus == LPI_LiteralConstant.IA_REQUEST_FOR_REFUND_STATUS) {
            return LPI_LiteralConstant.IA_REQUEST_FOR_REFUND_STATUS;
        }
        return customStatus;
    }
}