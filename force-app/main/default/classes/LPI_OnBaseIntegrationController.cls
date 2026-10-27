/**
 * @description       : Controller for uploading/deleting/fetching files from Onbase.
 * @author            : Mohit Karani
 * @group             : 
 * @last modified on  : 07-03-2024
 * @last modified by  : Ayush Dev
**/
public with sharing class LPI_OnBaseIntegrationController{
    public static Integer executionnumber  = 0;


    /**
    * @description : Method to get onbase config to uplaod a file.
    * @author Mohit Karani | 10-23-2023 
    * @param boardName 
    * @param flowName 
    * @return List<LPI_Onbase_Configuration__mdt> 
    **/
    public static List<LPI_Onbase_Configuration__mdt> getOnbaseConfigMetadata(List<String> boardName,List<String> flowName){
        try {
            return new LPI_CustomMetadataTypeDAO.LPI_CustomMetadataTypeWithoutSharingDAO().getCustomMetaByDymQueryWithoutSec('Payload__c,Board_Name__c,Flow_Name__c','LPI_Onbase_Configuration__mdt','Board_Name__c IN '+ LPI_ServiceUtility.getStringValuesByList(boardName) + ' AND Flow_Name__c IN  ' + LPI_ServiceUtility.getStringValuesByList(flowName) ,null,null,null);
        } catch (Exception e) {
            LPI_ExceptionManager.logException(
                'LPI_OnBaseIntegrationController',
                'getOnbaseConfigMetadata',
                e
            );
            throw new LPI_Exception(e.getMessage());
        }
    }

    /**
    * @description : Method to get details and prepare wrapper to uplaod a file.
    * @author Mohit Karani | 10-23-2023 
    * @param recordId 
    * @param objectApiName 
    * @param whereClause 
    * @return ResponseWrapper 
    **/
    @AuraEnabled
    public static ResponseWrapper getUploadDetails(String recordId,String objectApiName,String whereClause){
        try {
            if(String.isBlank(recordId)){
                return null;
            }
            List<String> boardNameList = new List<String>();
            List<String> flowNameList = new List<String>();
            ResponseWrapper wrapper = new ResponseWrapper();
            Date todayDate = Date.today();
            wrapper.documentDate = todayDate.month() + '-' +todayDate.day() + '-' + todayDate.year();
            if(objectApiName == 'Task'){
                getDetailsFromTask(wrapper,recordId);
            }
            else if(objectApiName == 'PublicComplaint'){
                getDetailsFromComplaint(wrapper,recordId);
            }
            else if(objectApiName == 'Visit'){
                getDetailsFromVisit(wrapper,recordId);
            }
            else if(objectApiName == 'Case'){
                getDetailsFromCase(wrapper, recordId);
            }
            else if(objectApiName == 'Audit_Detail__c'){
                getDetailsFromAudit(wrapper,recordId);
            }
            if(String.isBlank(wrapper.boardName)|| String.isBlank(wrapper.flowName)){
                throw new LPI_Exception('Onbase config not found');
            }
            boardNameList.add(wrapper.boardName);
            flowNameList.add(wrapper.flowName);
            
            for(LPI_Onbase_Configuration__mdt onbaseConfig  : getOnbaseConfigMetadata(boardNameList,flowNameList)){
                wrapper.onbaseConfig.put('payload',onbaseConfig.Payload__c);
            }

          whereClause +=   ' AND Is_Doc_Uploaded_by_Internal_User__c = true'; 
          
            for(Application_Document__c appDoc : LPI_ApplicationDocumentDAO.getApplicantDocumentByDymanicQuery('Id,File_Name__c,Is_Doc_Uploaded_by_Internal_User__c,Onbase_Document_Id__c',whereClause,null,null,null)){
                LPI_Wrapper.FileWrapper file = new LPI_Wrapper.FileWrapper();
                file.fileName = appDoc.File_Name__c;
                file.fileId = appDoc.Onbase_Document_Id__c;
                file.parentRecId = appDoc.Id;
                wrapper.fileList.add(file);
            }
            wrapper.numberValue = String.isNotBlank(wrapper.numberValue) && wrapper.numberValue.contains('-') ? wrapper.numberValue.replace('-', '') : wrapper.numberValue;
            wrapper.twoByTwoPhotoRecommendation =  System.Label.TwoByTwoPhotoRecommendations;
            return wrapper;
        } catch (Exception e) {
            LPI_ExceptionManager.logException(
                'LPI_OnBaseIntegrationController',
                'getUploadDetails',
                e
            );
            throw new LPI_Exception(e.getMessage());
        }

    }
    
    @AuraEnabled
    public static Map<String,Object> downloadFileFromSf(String recordId){
        try{

            Map<String,Object> responseMap = new Map<String,Object>();
            if(String.isBlank(recordId)){
                throw new LPI_Exception('Error downloading document');
            }
            List<Application_Document__c> appDocList = LPI_ApplicationDocumentDAO.getApplicantDocumentByDymanicQuery('Id,File_Name__c,Onbase_Document_Id__c,(SELECT ID,ContentDocumentId FROM ContentDocumentLinks)', 'Id = \''+String.escapeSingleQuotes(recordId) + '\'', null, null, null);
            if(appDocList.isEmpty()){
                throw new LPI_Exception('Error downloading document');
            }
            if(String.isNotBlank(appDocList[0].Onbase_Document_Id__c)){
                responseMap.put('fileId',appDocList[0].Onbase_Document_Id__c);
                responseMap.put('fileName',appDocList[0].File_Name__c);

                //Blob apiResponse = callDeleteDownloadApi(appDocList[0].Onbase_Document_Id__c,'GET');
                ContentVersion cv = new ContentVersion();
                //cv.VersionData = apiResponse;
                cv.Content_Type__c = 'OnBase Download Document';
                cv.Title = appDocList[0].File_Name__c.substringBeforeLast('.');
                cv.PathOnClient =appDocList[0].File_Name__c;
                cv = (ContentVersion)LPI_DML.doInsert(cv);

    
                List<ContentVersion> cvList = LPI_ContentVersionDAO.getContentVersionByDymanicQuery('Id,ContentDocumentId', 'Id = \'' + cv.Id + '\'',null,null,null);
                if(cvList.isEmpty()){
                    throw new LPI_Exception('Error downloading the document.'); 
                }
                responseMap.put('downloadUrl',LPI_GetApplicationDocumentController.documentDownloadUrl(cvList[0].ContentDocumentId));
                responseMap.put('contentDocId',cvList[0].ContentDocumentId);    
                responseMap.put('fromOnbase',true);           
            }
            else if(!appDocList[0].ContentDocumentLinks.isEmpty()){
                responseMap.put('downloadUrl', LPI_GetApplicationDocumentController.documentDownloadUrl(appDocList[0].ContentDocumentLinks[0].ContentDocumentId));
                responseMap.put('contentDocId',appDocList[0].ContentDocumentLinks[0].ContentDocumentId);

            }
            return responseMap;
           
            
        }catch (Exception e) {
            LPI_ExceptionManager.logException(
                'LPI_OnBaseIntegrationController',
                'downloadFileFromSf',
                e
            );
            throw new LPI_Exception(e.getMessage());
        }
    }

    /**
    * @description : Method to get details from task to upload a file.
    * @author Mohit Karani | 10-23-2023 
    * @param wrapper 
    * @param recordId 
    **/
    public static void getDetailsFromTask(ResponseWrapper wrapper,String recordId){
        try {
            Set<Id> caseIdSet = new Set<Id>();
            List<Task> taskList = LPI_TaskDao.getTaskByDymanicQuery('WhatId','ID =\''+ String.escapeSingleQuotes(recordId) + '\' AND WhatId != NULL',null,null,null);
            if(taskList.isEmpty()){
                wrapper.uploadReqd = false;
                return;
            }
            Set<String> veaIdSet = new Set<String>();
            Boolean fromCase,fromVea = false;
            for(Task taskRec : taskList){
                if(taskRec.WhatId.getSObjectType().getDescribe().getName() == 'ViolationEnforcementAction'){
                    veaIdSet.add(taskRec.WhatId);
                    fromVea = true;
                }else if(taskRec.WhatId.getSObjectType().getDescribe().getName() == 'Case'){
                    fromCase = true;
                    caseIdSet.add(taskRec.WhatId);
                }
            }
            if(veaIdSet.isEmpty() && caseIdSet.isEmpty()){
                return;
            }
            Map<Id,ViolationEnforcementAction> idToVea = new Map<Id,ViolationEnforcementAction>();
            if(!veaIdSet.isEmpty()){
                idToVea = new Map<Id,ViolationEnforcementAction>( LPI_ViolationEnforcementActionDAO.fetchViolationEnforcementActionRecordsWithoutSecurity('Violation.Inspection.Account.firstname,Violation.Inspection.Account.middlename,Violation.Inspection.Business_Name__c,Violation.Inspection.Account.lastname,Violation.Inspection.Account.suffix,Violation.Inspection.Account.Social_Security_Number__c,Violation.Inspection.Account.IsPersonAccount,Violation.Case__r.Business_License_Id__c,Violation.Case__c,Violation.Case__r.AccountId,Violation.Board_Name__c,Violation.InspectionId,Violation.Inspection.Name,Violation.Case__r.Account.Name,Violation.Case__r.Account.IsPersonAccount,Violation.Case__r.Case_Number__c,Violation.Inspection.Actual_Start_Date__c,Violation.Inspection.VisitType.Name,Violation.Inspection.ContextId,Violation.Inspection.License_Type__c,Violation.Case__r.Account.firstname,Violation.Case__r.Account.middlename,Violation.Case__r.Account.lastname,Violation.Case__r.Account.suffix,Violation.Case__r.Account.Social_Security_Number__c,TYPEOF Violation.inspection.context WHEN BUSINESSLICENSE then Legacy_License_Number__c,Name,Pre_Licensure_NUmber__c,ContactId,Account.Name WHEN CASE THEN License_Number__c,Account.Name WHEN BUSINESSLICENSEAPPLICATION THEN Name,ApplicantId END','ID IN '+ LPI_ServiceUtility.getStringValuesByStringSet(veaIdSet),null,null));
            }
            for(ViolationEnforcementAction veaRec :idToVea.values()){
                wrapper.boardName = veaRec.Violation.Board_Name__c;
                if(String.isNotBlank(veaRec.Violation.Case__c)){
                    caseIdSet.add(veaRec.Violation.Case__c);
                }
            }

            Map<Id,ComplaintCase> caseIdToComplaintCase = new Map<Id,ComplaintCase>();
            if(!caseIdSet.isEmpty()){
                for(ComplaintCase cs : new LPI_ComplaintCaseDao.LPI_ComplaintCaseWithoutSharingDAO().getCompCaseByDymanicQueryWithoutSecurityEnforced('Case.Board_Name__c,PublicComplaintId,PublicComplaint.Name,PublicComplaint.Complaint_Details__c,CaseId,Case.Case_Number__c,Case.Account.Name,Case.Business_License_Id__c,Case.Account.IsPersonAccount,Case.Account.firstname,Case.Account.middlename,Case.Account.lastname,Case.Account.suffix,Case.Account.Social_Security_Number__c','CaseId IN ' +LPI_ServiceUtility.getStringValuesBySet(caseIdSet), null,null,null )){
                    wrapper.boardName = cs.Case.Board_Name__c;
                    caseIdToComplaintCase.put(cs.CaseId,cs);
                }
            }
            if(idToVea.containsKey(taskList[0].WhatId) && String.isNotBlank(idToVea.get(taskList[0].WhatId).Violation.InspectionId)){
                wrapper.flowName =  LPI_ScheduleInspectionsBatch.BOARD_NAME_TO_ASSIGN_INSPECOR_BY_COUNTY.contains(wrapper.boardName) || wrapper.boardName == 'Nursing' ? 'inspection' : 'complaint';
                wrapper.numberValue = idToVea.get(taskList[0].WhatId).Violation.Inspection.Name?.abbreviate(10) ;
                wrapper.inspectionDate =idToVea.get(taskList[0].WhatId).Violation.Inspection.Actual_Start_Date__c!= null ? String.valueOf(idToVea.get(taskList[0].WhatId).Violation.Inspection.Actual_Start_Date__c.year() + '-'+String.valueOf(idToVea.get(taskList[0].WhatId).Violation.Inspection.Actual_Start_Date__c.month()).leftPad(2, '0')+'-'+String.valueOf(idToVea.get(taskList[0].WhatId).Violation.Inspection.Actual_Start_Date__c.day()).leftPad(2, '0')) :  String.valueOf(Date.today().year()+'-'+String.valueOf(Date.today().month()).leftPad(2, '0')+'-'+String.valueOf(Date.today().day()).leftPad(2, '0'));
                wrapper.description =  idToVea.get(taskList[0].WhatId).Violation.Inspection.VisitType.Name;
                wrapper.licenseNumber =idToVea.get(taskList[0].WhatId).Violation.Inspection.Context instanceof BusinessLicense ? String.isNotBlank(((BusinessLicense)idToVea.get(taskList[0].WhatId).Violation.Inspection.Context).Legacy_License_Number__c) ? ((BusinessLicense)idToVea.get(taskList[0].WhatId).Violation.Inspection.Context).Legacy_License_Number__c?.abbreviate(12) :  ((BusinessLicense)idToVea.get(taskList[0].WhatId).Violation.Inspection.Context).Name?.abbreviate(12) : idToVea.get(taskList[0].WhatId).Violation.Inspection.Context instanceof Case ?  ((Case)idToVea.get(taskList[0].WhatId).Violation.Inspection.Context).License_Number__c?.abbreviate(12) : idToVea.get(taskList[0].WhatId).Violation.Inspection.Context instanceof BUSINESSLICENSEAPPLICATION ?  ((BUSINESSLICENSEAPPLICATION)idToVea.get(taskList[0].WhatId).Violation.Inspection.Context).Name?.abbreviate(12)  : '';
                wrapper.preLicensureNumber = idToVea.get(taskList[0].WhatId).Violation.Inspection.Context instanceof BusinessLicense 
                                    ? ((BusinessLicense)idToVea.get(taskList[0].WhatId).Violation.Inspection.Context)?.Pre_Licensure_NUmber__c?.abbreviate(10) 
                                    : idToVea.get(taskList[0].WhatId).Violation.Inspection.Context instanceof BUSINESSLICENSEAPPLICATION 
                                    ?  ((BUSINESSLICENSEAPPLICATION)idToVea.get(taskList[0].WhatId).Violation.Inspection.Context).Name?.abbreviate(12)  : '';
                wrapper.preLicenseNumber = wrapper.preLicensureNumber;
                wrapper.entityName = idToVea.get(taskList[0].WhatId).Violation.Inspection.Business_Name__c?.abbreviate(70);
                if((idToVea.get(taskList[0].WhatId).Violation.Inspection.Context instanceof BusinessLicense && String.isNotBlank(((BusinessLicense)idToVea.get(taskList[0].WhatId).Violation.Inspection.Context).ContactId)) || (idToVea.get(taskList[0].WhatId).Violation.Inspection.Context instanceof BusinessLicenseApplication && String.isNotBlank(((BusinessLicenseApplication)idToVea.get(taskList[0].WhatId).Violation.Inspection.Context).ApplicantId))){
                    String contactId = idToVea.get(taskList[0].WhatId).Violation.Inspection.Context instanceof BusinessLicense  ? ((BusinessLicense)idToVea.get(taskList[0].WhatId).Violation.Inspection.Context).ContactId : ((BusinessLicenseApplication)idToVea.get(taskList[0].WhatId).Violation.Inspection.Context).ApplicantId;
                    if(String.isNotBlank(contactId)){
                        for(Account accNew : LPI_AccountDAO.getAccountListByDynamicQuery(new List<String>{'Id,firstname,middlename,lastname,suffix,Social_Security_Number__c'},'PersonContactId = \'' + String.escapeSingleQuotes(contactId) + '\'',null,null,null)){
                            populateAccountDetails(accNew,wrapper);
                        }
                    }   
                }

                if(String.isNotBlank(idToVea.get(taskList[0].WhatId).Violation.Inspection.License_Type__c)){
                    for(RegulatoryAuthorizationType rat : LPI_RegulatoryAuthorizationTypeDAO.getRegulatoryAuthorizationTypeByDymanicQuery('Profession_Code__c', 'Name = \'' + idToVea.get(taskList[0].WhatId).Violation.Inspection.License_Type__c +'\'', null, null, null)){
                        wrapper.profCode =rat.Profession_Code__c;
                    }
                }
                wrapper.accountName = idToVea.get(taskList[0].WhatId).Violation.Inspection.Context instanceof BusinessLicense ? ((BusinessLicense)idToVea.get(taskList[0].WhatId).Violation.Inspection.Context).Account.Name : null;
                //wrapper.programType = idToVea.get(taskList[0].WhatId).Violation.Inspection.Context instanceof BusinessLicense ? ((BusinessLicense)idToVea.get(taskList[0].WhatId).Violation.Inspection.Context).Program_Type__c?.abbreviate(10)  : null;
                //wrapper.providerCode = idToVea.get(taskList[0].WhatId).Violation.Inspection.Context instanceof BusinessLicense ? ((BusinessLicense)idToVea.get(taskList[0].WhatId).Violation.Inspection.Context).Program_Code__c?.abbreviate(10)  : null;
            }else if((idToVea.containsKey(taskList[0].WhatId) && String.isNotBlank(idToVea.get(taskList[0].WhatId).Violation.Case__c)) || (caseIdToComplaintCase.containsKey(taskList[0].WhatId))){
                wrapper.flowName = 'complaint';
                wrapper.numberValue = fromVea ? idToVea.get(taskList[0].WhatId).Violation.Case__r.Case_Number__c.replaceAll('-','')?.abbreviate(10) :String.isNotBlank(caseIdToComplaintCase.get(taskList[0].WhatId).Case.Case_Number__c )? caseIdToComplaintCase.get(taskList[0].WhatId).Case.Case_Number__c.replaceAll('-','')?.abbreviate(10):NULL ;
                wrapper.description = fromVea ? idToVea.get(taskList[0].WhatId).Violation.Case__r.Account.Name?.abbreviate(30) : caseIdToComplaintCase.get(taskList[0].WhatId).Case.Account.Name?.abbreviate(30) ;
                wrapper.entityName =  fromVea ? 
                                        !idToVea.get(taskList[0].WhatId).Violation.Case__r.Account.IsPersonAccount ? 
                                        idToVea.get(taskList[0].WhatId).Violation.Case__r.Account.Name.length() > 70 ? idToVea.get(taskList[0].WhatId).Violation.Case__r.Account.Name.substring(0,70) : idToVea.get(taskList[0].WhatId).Violation.Case__r.Account.Name
                                            : '' 
                                        : !caseIdToComplaintCase.get(taskList[0].WhatId).Case.Account.IsPersonAccount ? 
                                        caseIdToComplaintCase.get(taskList[0].WhatId).Case.Account.Name.length() > 70 ? caseIdToComplaintCase.get(taskList[0].WhatId).Case.Account.Name.substring(0,70) : caseIdToComplaintCase.get(taskList[0].WhatId).Case.Account.Name : '';
                wrapper.dateValue =   String.valueOf(Date.today().year()+'-'+String.valueOf(Date.today().month()).leftPad(2, '0')+'-'+String.valueOf(Date.today().day()).leftPad(2, '0'));
                Boolean accountDetailPoplated = false; 
                if((idToVea.containsKey(taskList[0].WhatId) && String.isNotBlank(idToVea.get(taskList[0].WhatId).Violation.Case__r.AccountId) && idToVea.get(taskList[0].WhatId).Violation.Case__r.Account.IsPersonAccount) || (caseIdToComplaintCase.containsKey(taskList[0].WhatId) && caseIdToComplaintCase.get(taskList[0].WhatId).Case.Account.IsPersonAccount)){
                    Account accRec = fromVea ? idToVea.get(taskList[0].WhatId).Violation.Case__r.Account : caseIdToComplaintCase.get(taskList[0].WhatId).Case.Account;
                    accountDetailPoplated = true;
                    populateAccountDetails(accRec,wrapper);
                }
                if((idToVea.containsKey(taskList[0].WhatId) && String.isNotBlank(idToVea.get(taskList[0].WhatId).Violation.Case__r.Business_License_Id__c)) || ((caseIdToComplaintCase.containsKey(taskList[0].WhatId) && String.isNotBlank(caseIdToComplaintCase.get(taskList[0].WhatId).Case.Business_License_Id__c)))){
                    String blId = fromVea ? idToVea.get(taskList[0].WhatId).Violation.Case__r.Business_License_Id__c : caseIdToComplaintCase.get(taskList[0].WhatId).Case.Business_License_Id__c;
                    String contactId;
                    for(BusinessLicense bl : LPI_BusinessLicenseDAO.fetchBusinessLicenseRecords('id,ContactId,RegulatoryAuthorizationType.Authorisation_Type__c,Business_Entity_Name__c,name,Legacy_License_Number__c,Pre_Licensure_Number__c, RegulatoryAuthorizationType.Profession_Code__c ', 'Id = \''+String.escapeSingleQuotes(blId) + '\'')){
                        contactId = bl.ContactId;
                        wrapper.profCode = bl.RegulatoryAuthorizationType.Profession_Code__c;
                        wrapper.preLicensureNumber = bl.Pre_Licensure_Number__c?.abbreviate(10);
                        wrapper.preLicenseNumber = wrapper.preLicensureNumber;
                        wrapper.licenseNumber = String.isNotBlank(bl.Legacy_License_Number__c) ? bl.Legacy_License_Number__c?.abbreviate(12) : bl.Name?.abbreviate(12);
                        wrapper.entityName = bl.RegulatoryAuthorizationType.Authorisation_Type__c == 'Business' ? bl.Business_Entity_Name__c.length () > 70 ? bl.Business_Entity_Name__c.substring(0,70) :  bl.Business_Entity_Name__c :  '';
                    }
                    if(!accountDetailPoplated && String.isNotBlank(contactId)){
                        for(Account accNew : LPI_AccountDAO.getAccountListByDynamicQuery(new List<String>{'Id,firstname,middlename,lastname,suffix,Social_Security_Number__c'},'PersonContactId = \'' + String.escapeSingleQuotes(contactId) + '\'',null,null,null)){
                            populateAccountDetails(accNew,wrapper);
                        }
                    }   
                }
                for(ComplaintCase cc : LPI_ComplaintCaseDao.fetchComplaintCaseRecords('Id,PublicComplaint.Name','CaseId = \''+String.escapeSingleQuotes(taskList[0].WhatId) + '\'',null,null)){
                    wrapper.complaintNumber = cc.PublicComplaint.Name.substringAfter('-')?.abbreviate(10);
                }
            }
            wrapper.scanDate =   String.valueOf(Date.today().year() + '-'+String.valueOf(Date.today().month()).leftPad(2,'0')+'-'+String.valueOf(Date.today().day()).leftPad(2,'0'));
        } catch (Exception e) {
            LPI_ExceptionManager.logException(
                'LPI_OnBaseIntegrationController',
                'getDetailsFromTask',
                e
            );
            throw new LPI_Exception(e.getMessage());
        }
        
    }

    /**
    * @description :  Method to get details from PublicComplaint to upload a file.
    * @author Mohit Karani | 10-23-2023 
    * @param wrapper 
    * @param recordId 
    **/
    public static void getDetailsFromComplaint(ResponseWrapper wrapper,String recordId){
        try {
            List<PublicComplaint> pcList = LPI_PublicComplaintDao.fetchPublicComplaintRecords('License_Name__c,IncidentDate,Reported_Date__c,Account.IsPersonAccount,Id,Board__c,Complaint_Details__c,Name,Account.Name,(SELECT Id, TYPEOF PARTICIPANT WHEN ACCOUNT THEN firstname,middlename,lastname,suffix,Social_Security_Number__c,IsPersonAccount END FROM PublicComplaintParticipants where Role = \''+LPI_LiteralConstant.RESPONDENT_TEXT +  '\' )','ID =\''+ String.escapeSingleQuotes(recordId) + '\'',null,null);
            if(pcList.isEmpty()){
                return ;
            }
            wrapper.description = String.isNotBlank(pcList[0].Account.Name) ? pcList[0].Account.Name.length() > 30 ? pcList[0].Account.Name.substring(0,30) :pcList[0].Account.Name : '' ;
            wrapper.numberValue = pcList[0].Name.substringAfter('PC-')?.abbreviate(10);
            wrapper.boardName = pcList[0].Board__c;
            wrapper.entityName =  !pcList[0].Account.IsPersonAccount ? pcList[0].Account?.Name.length() > 70 ?  pcList[0].Account?.Name.substring(0,70) : pcList[0].Account?.Name : '';
            wrapper.dateValue =  String.valueOf(Date.today().year() + '-'+String.valueOf(Date.today().month()).leftPad(2,'0')+'-'+String.valueOf(Date.today().day()).leftPad(2,'0'));
            wrapper.scanDate =  String.valueOf(Date.today().year() + '-'+String.valueOf(Date.today().month()).leftPad(2,'0')+'-'+String.valueOf(Date.today().day()).leftPad(2,'0'));
            Boolean accountDetailsPopulated = false;
            if(!pcList[0].PublicComplaintParticipants.isEmpty() && ((Account)pcList[0].PublicComplaintParticipants[0].Participant).IsPersonAccount){
                accountDetailsPopulated = true;
                populateAccountDetails((Account)pcList[0].PublicComplaintParticipants[0].Participant, wrapper);
            }
            if(String.isNotBlank(pcList[0].License_Name__c)){
                for(RegulatoryAuthorizationType rat : LPI_RegulatoryAuthorizationTypeDAO.getRegulatoryAuthorizationTypeByDymanicQuery('Profession_Code__c', 'Name = \'' + pcList[0].License_Name__c +'\'', null, null, null)){
                    wrapper.profCode =rat.Profession_Code__c;
                }
            }
            String blId;
            for(ComplaintCase cc : LPI_ComplaintCaseDao.fetchComplaintCaseRecords('Id,Case.Business_License_Id__c','PublicComplaintId = \''+String.escapeSingleQuotes(recordId) + '\'',null,null)){
                blId = cc.Case.Business_License_Id__c;
            }
            String contactId;
            if(String.isNotBlank(blId)){
                for(BusinessLicense bl : LPI_BusinessLicenseDAO.fetchBusinessLicenseRecords('id,ContactId,RegulatoryAuthorizationType.Authorisation_Type__c,Business_Entity_Name__c,name,Legacy_License_Number__c,Pre_Licensure_Number__c, RegulatoryAuthorizationType.Profession_Code__c ', 'Id = \''+String.escapeSingleQuotes(blId) + '\'')){
                    contactId = bl.ContactId;
                    wrapper.profCode = bl.RegulatoryAuthorizationType.Profession_Code__c;
                    wrapper.preLicensureNumber = bl.Pre_Licensure_Number__c?.abbreviate(10);
                    wrapper.preLicenseNumber = wrapper.preLicensureNumber;
                    wrapper.licenseNumber = String.isNotBlank(bl.Legacy_License_Number__c) ? bl.Legacy_License_Number__c?.abbreviate(12) : bl.Name?.abbreviate(12);
                    wrapper.entityName = bl.RegulatoryAuthorizationType.Authorisation_Type__c == 'Business' ?  bl.Business_Entity_Name__c.length() > 70 ?  bl.Business_Entity_Name__c.substring(0,70) :  bl.Business_Entity_Name__c : '';
                }

                
                if(!accountDetailsPopulated && String.isNotBlank(contactId)){
                    for(Account accNew : LPI_AccountDAO.getAccountListByDynamicQuery(new List<String>{'Id,firstname,middlename,lastname,suffix,Social_Security_Number__c'},'PersonContactId = \'' + String.escapeSingleQuotes(contactId) + '\'',null,null,null)){
                        populateAccountDetails(accNew,wrapper);
                    }
                } 
            }
            wrapper.flowName = 'complaint';
        } catch (Exception e) {
            LPI_ExceptionManager.logException(
                'LPI_OnBaseIntegrationController',
                'getDetailsFromComplaint',
                e
            );
            throw new LPI_Exception(e.getMessage());
        }
        
    }

    /**
    * @description :  Method to get details from Visit to upload a file.
    * @author Mohit Karani | 10-23-2023 
    * @param wrapper 
    * @param recordId 
    **/
    public static void getDetailsFromVisit(ResponseWrapper wrapper,String recordId){
        try {
            List<Visit> visitList = LPI_VisitControllerDAO.getVisitListByDynamicQueryWithoutSecurity(new List<String>{'Id,Account.Name,Board_Name__c,Name,Actual_Start_Date__c,ContextId,License_Type__c,Business_Name__c,VisitType.Name, TYPEOF context WHEN BUSINESSLICENSE then Name,ContactId,Legacy_License_Number__c,Pre_Licensure_Number__c WHEN CASE THEN License_Number__c,Business_License_Id__c,Account.IsPersonAccount,Account.FirstName,Account.LastName,Account.MiddleName,Account.Suffix,Account.Social_Security_Number__c WHEN BUSINESSLICENSEAPPLICATION THEN Name,ApplicantId,Pre_Licensure_Number__c END '},'ID =\''+ String.escapeSingleQuotes(recordId) + '\'',null,null,null);
            if(visitList.isEmpty()){
                return ;
            }

            Visit visitRec =  visitList[0];
            wrapper.numberValue =visitRec.Name?.abbreviate(10);
            wrapper.boardName =visitRec.Board_Name__c;
            wrapper.inspectionDate =visitRec.Actual_Start_Date__c!= null ? String.valueOf(visitRec.Actual_Start_Date__c.year() + '-'+String.valueOf(visitRec.Actual_Start_Date__c.month()).leftPad(2, '0')+'-'+String.valueOf(visitRec.Actual_Start_Date__c.day()).leftPad(2, '0')) : String.valueOf(Date.today().year()+'-'+String.valueOf(Date.today().month()).leftPad(2, '0')+'-'+String.valueOf(Date.today().day()).leftPad(2, '0'));
            wrapper.description =visitRec.VisitType.Name;
            wrapper.licenseNumber = visitRec.Context instanceof BusinessLicense ? ((BusinessLicense)visitRec.Context).Legacy_License_Number__c != NULL ? ((BusinessLicense)visitRec.Context).Legacy_License_Number__c?.abbreviate(12) : ((BusinessLicense)visitRec.Context).Name?.abbreviate(12) : visitRec.Context instanceof Case ?  ((Case)visitRec.Context).License_Number__c?.abbreviate(12) : visitRec.Context instanceof BUSINESSLICENSEAPPLICATION ?  ((BUSINESSLICENSEAPPLICATION)visitRec.Context).Name.substringAfter('-')?.abbreviate(12)  : '';
            wrapper.preLicensureNumber = visitRec.Context instanceof BusinessLicense ?  ((BusinessLicense)visitRec.Context).Pre_Licensure_Number__c?.abbreviate(12) :  visitRec.Context instanceof BUSINESSLICENSEAPPLICATION ?  ((BUSINESSLICENSEAPPLICATION)visitRec.Context).Pre_Licensure_Number__c?.abbreviate(12)  : '';
            wrapper.preLicenseNumber = wrapper.preLicensureNumber;
            wrapper.scanDate = String.valueOf(Date.today().year() + '-'+String.valueOf(Date.today().month()).leftPad(2,'0')+'-'+String.valueOf(Date.today().day()).leftPad(2,'0'));
            wrapper.entityName = visitRec.Business_Name__c?.abbreviate(70);
            wrapper.accountName = visitRec.Account.Name?.abbreviate(100);
            //wrapper.programType = visitRec.Context instanceof BusinessLicense ? ((BusinessLicense)visitRec.Context).Program_Type__c?.abbreviate(30) : null ;
           // wrapper.providerCode =  visitRec.Context instanceof BusinessLicense ? ((BusinessLicense)visitRec.Context).Program_Code__c?.abbreviate(10) : null;
            wrapper.dateValue = String.valueOf(Date.today().year() + '-'+String.valueOf(Date.today().month()).leftPad(2,'0')+'-'+String.valueOf(Date.today().day()).leftPad(2,'0'));
            Boolean accountDetailPoplated = false;
            wrapper.flowName =  LPI_ScheduleInspectionsBatch.BOARD_NAME_TO_ASSIGN_INSPECOR_BY_COUNTY.contains(wrapper.boardName) || wrapper.boardName == 'Nursing' ? 'inspection' :  'complaint';
            if(visitRec.Context instanceof Case && ((Case)visitRec.Context).Account.IsPersonAccount ){
                accountDetailPoplated = true;
                populateAccountDetails(((Case)visitRec.Context).Account,wrapper);
            }
            if(visitRec.contextId != null){
            for(ComplaintCase cc : LPI_ComplaintCaseDao.fetchComplaintCaseRecords('Id,PublicComplaint.Name','CaseId = \''+String.escapeSingleQuotes(visitRec.contextId) + '\'',null,null)){
                wrapper.complaintNumber = cc.PublicComplaint.Name.substringAfter('-')?.abbreviate(10);}
            }   
            if(visitRec.Context instanceof Case && String.isNotBlank(((Case)visitRec.Context).Business_License_Id__c)){
                String contactId;
                for(BusinessLicense bl : LPI_BusinessLicenseDAO.fetchBusinessLicenseRecords('id,ContactId,RegulatoryAuthorizationType.Authorisation_Type__c,Business_Entity_Name__c,name,Legacy_License_Number__c,Pre_Licensure_Number__c, RegulatoryAuthorizationType.Profession_Code__c ', 'Id = \''+String.escapeSingleQuotes(((Case)visitRec.Context).Business_License_Id__c) + '\'')){
                    contactId = bl.ContactId;
                    //wrapper.programType = bl.Program_Type__c?.abbreviate(30);
                    //wrapper.providerCode = bl.Program_Code__c?.abbreviate(10);
                }
                if(!accountDetailPoplated && String.isNotBlank(contactId)){
                    for(Account accNew : LPI_AccountDAO.getAccountListByDynamicQuery(new List<String>{'Id,firstname,middlename,lastname,suffix,Social_Security_Number__c'},'PersonContactId = \'' + String.escapeSingleQuotes(contactId) + '\'',null,null,null)){
                        populateAccountDetails(accNew,wrapper);
                    }
                } 
            }else if((visitRec.Context instanceof BusinessLicense &&  String.isNotBlank(((BusinessLicense)visitRec.Context).ContactId)) || (visitRec.Context instanceof BusinessLicenseApplication && String.isNotBlank(((BusinessLicenseApplication)visitRec.Context).ApplicantId))){
                String contactId = visitRec.Context instanceof BusinessLicense  ? ((BusinessLicense)visitRec.Context).ContactId : ((BusinessLicenseApplication)visitRec.Context).ApplicantId;
                if(String.isNotBlank(contactId)){
                    for(Account accNew : LPI_AccountDAO.getAccountListByDynamicQuery(new List<String>{'Id,firstname,middlename,lastname,suffix,Social_Security_Number__c'},'PersonContactId = \'' + String.escapeSingleQuotes(contactId) + '\'',null,null,null)){
                        populateAccountDetails(accNew,wrapper);
                    }
                }   
            }
            if(String.isNotBlank(visitRec.License_Type__c)){
                for(RegulatoryAuthorizationType rat : LPI_RegulatoryAuthorizationTypeDAO.getRegulatoryAuthorizationTypeByDymanicQuery('Profession_Code__c', 'Name = \'' + visitRec.License_Type__c +'\'', null, null, null)){
                    wrapper.profCode =rat.Profession_Code__c;
                }
            }
           
        } catch (Exception e) {
            LPI_ExceptionManager.logException(
                'LPI_OnBaseIntegrationController',
                'getDetailsFromVisit',
                e
            );
            throw new LPI_Exception(e.getMessage());
        }
    }

    public static void populateAccountDetails(Account acc,ResponseWrapper wrapper){
        wrapper.firstName = acc.firstName?.abbreviate(40);
        wrapper.lastName = acc.lastName?.abbreviate(40);
        wrapper.middleName = acc.middleName?.abbreviate(20);
        wrapper.suffixName = acc.suffix?.abbreviate(10);
        wrapper.ssn = acc.Social_Security_Number__c?.abbreviate(9);
    }

    @AuraEnabled
    public static ResponseWrapper bypassOnbase(String jsonData){
        try {
             ResponseWrapper response = new ResponseWrapper();
             ScanFileWrapper result = (ScanFileWrapper) JSON.deserialize(jsonData, ScanFileWrapper.class);
            //return getUploadDetails(result.recordId, result.objectApiName, result.whereClause);
             String fields = 'AFSC__Full_File_Name__c,AFSC__Verdict__c,AFSC__File_Parent_Id__c';
            List<Application_Document__c> appDocList = new List<Application_Document__c>();
             String userType = UserInfo.getUserType();
            fields = 'Onbase_Upload_Status__c,Id,Status__c,File_Name__c,Document_Name__c,Onbase_Document_Id__c,Is_additional_document_by_portal_user__c,Application_Document__c,Is_System_Generated__c';
            System.debug('jSON===>'+jsonData);
            System.debug('appDocId===>'+result.appDocumentId);
            if(userType!=null && userType.equals('Guest')) {
                appDocList = new LPI_ApplicationDocumentDAO.LPI_ApplicationDocumentWithoutSharingDAO().getApplicantDocumentByDymanicQueryWithoutSecurityEnforced(fields, 'Id = \''+String.escapeSingleQuotes(result.appDocumentId) + '\'', null, null, null);
            } else {
                appDocList = LPI_ApplicationDocumentDAO.getApplicantDocumentByDymanicQuery(fields, 'Id = \''+String.escapeSingleQuotes(result.appDocumentId) + '\'', null, null, null);
            }
                List<Application_Document__c> updateList = new List<Application_Document__c> ();
                Application_Document__c appDocument = new Application_Document__c(Id = String.escapeSingleQuotes(result.appDocumentId));
                System.debug('doc name'+appDocList[0].Document_Name__c);
                if(result.newDocumentName!=null){
                    appDocument.File_Name__c =String.escapeSingleQuotes(result.newDocumentName) ;
                }
                else{
                appDocument.File_Name__c =appDocList[0].Document_Name__c;
                }
                //appDocument.Is_Lawful_Presence_Document__c = true;
                if(appDocList[0].Is_System_Generated__c &&  result.isSubmittedAsPartOfDeficiency == true){
                    appDocument.Is_Submitted_as_a_part_of_deficiency__c = true;
                }
                //appDocument.Status__c = (result.fromhandleSave != NULL && result.fromhandleSave) || (!appDocList[0].Is_additional_document_by_portal_user__c  && (result.markUnsubmitted == NULL || !result.markUnsubmitted))? 'Submitted' : 'Unsubmitted' ;
            appDocument.Status__c = 'Submitted';    
            if((result.uploadByInternalUser != NULL && result.uploadByInternalUser)){
                    appDocument.Is_Doc_Uploaded_by_Internal_User__c = true;
                } 
                if((result.fromhandleSave != NULL && result.fromhandleSave && appDocList[0].Onbase_Upload_Status__c != 'Uploaded to Onbase')){
                    appDocument.Onbase_Upload_Status__c = 'Ready to upload';
                    
                }
                appDocument.Upload_To_Onbase__c = true;
                if(String.isNotBlank(result.payLoad)){
                    appDocument.Onbase_Payload__c = result.payLoad;
                }
                if(String.isNotBlank(result.newDocumentName)){
                        appDocument.Document_Name__c =  result.newDocumentName;
                }
                if(String.isNotBlank(result.newDocumentDescription)){
                            appDocument.Description__c =  result.newDocumentDescription;
                }
                updateList.add(appDocument);
                 if((appDocument.Status__c != 'Approved')&&(result.markUnsubmitted == NULL || !result.markUnsubmitted) &&  String.isNotBlank(appDocList[0].Application_Document__c)){
                    updateList.add(new Application_Document__c(Id = appDocList[0].Application_Document__c , Status__c = 'Submitted'));
                }
            	system.debug('###'+updateList);
                LPI_WithoutSharingUtility.updateSObjectList(updateList); // made this in without sharing update for guest users. 
               //GetApplicationDocumentController.updateStatus(appDocument.Id);

            // }
            // if(result.fromGenericCmp != NULL && result.fromGenericCmp){
            //     return getUploadDetails(result.recordId, result.objectApiName, result.whereClause);
            // }
            return response;
        }catch (Exception e) {
            LPI_ExceptionManager.logException(
                'LPI_OnBaseIntegrationController',
                'getFileScanResult',
                e
            );
            throw new LPI_Exception(e.getMessage());
        }
    }


    @AuraEnabled
    public static /*ResponseWrapper*/ void getFileScanResult(String jsonData){

       /* try {
            Integer retryAllowed = 4;
            ResponseWrapper response = new ResponseWrapper();
            ScanFileWrapper result = (ScanFileWrapper) JSON.deserialize(jsonData, ScanFileWrapper.class);
           
            List<AFSC__FSFileScanLog__c> fileScanList = new List<AFSC__FSFileScanLog__c>();

            // check current user profile. 
            // String currUserProfile = MODPR_ProfileDao.getProfileByDymanicQuery('Id,Name','Id =\'' + UserInfo.getProfileId() +'\'',null,null,null)[0]?.Name;
            //if(currUserProfile == PORTAL_USER) { 
            String userType = UserInfo.getUserType();

            String fields = 'AFSC__Full_File_Name__c,AFSC__Verdict__c,AFSC__File_Parent_Id__c';
            String whereClause;
            if(userType!=null && userType.equals('Guest')) {
                whereClause = 'AFSC__File_Parent_Id__c = \''+ String.escapeSingleQuotes(result.appDocumentId) + '\'';
            } else{
                whereClause = 'AFSC__Ref_Content_Document_Id__c = \''+ String.escapeSingleQuotes(result.contentDocumentId) + '\'';
            }
            if(userType!=null && userType.equals('Guest')) {
                fileScanList = new LPI_FileScanDao.LPI_FileScanWithoutSharingDAO().getFileScanRecordsWithoutSharing(fields,whereClause,null,null);
            } else {
                fileScanList = LPI_FileScanDao.getFileScanRecords(fields,whereClause,null,null);
            }
            // } else {
            //     fileScanList = new MODPR_FileScanDao.MODPR_FileScanWithoutSharingDAO().getFileScanRecordsWithoutSharing('AFSC__Full_File_Name__c,AFSC__Verdict__c,AFSC__File_Parent_Id__c','AFSC__Ref_Content_Document_Id__c = \''+ String.escapeSingleQuotes(result.contentDocumentId) + '\'',null,null);
            // }
            if(userType!=null && userType.equals('Guest') && !fileScanList.isEmpty() && String.isNotBlank(result?.appDocumentId)) { // Added - Vamsi Mudaliar
                fileScanList[0].AFSC__File_Parent_Id__c = result?.appDocumentId; // in case of guest user this value was giving the user id who uploaded the file. so we needed to change it to appDocId. 
                // updating in without sharing. 
                LPI_WithoutSharingUtility.updateSObjectList(fileScanList);
            }


            if(fileScanList.isEmpty()){
                if(executionnumber++ < retryAllowed) {
                    getFileScanResult(jsonData);
                }
                else{
                    throw new LPI_Exception('File has not been scanned yet.');
                } 
            }
            List<Application_Document__c> appDocList = new List<Application_Document__c>();
            fields = 'Onbase_Upload_Status__c,Id,Status__c,File_Name__c,Onbase_Document_Id__c,Is_additional_document_by_portal_user__c,Application_Document__c,Is_System_Generated__c';
            if(userType!=null && userType.equals('Guest')) {
                appDocList = new LPI_ApplicationDocumentDAO.LPI_ApplicationDocumentWithoutSharingDAO().getApplicantDocumentByDymanicQueryWithoutSecurityEnforced(fields, 'Id = \''+String.escapeSingleQuotes(fileScanList[0].AFSC__File_Parent_Id__c) + '\'', null, null, null);
            } else {
                appDocList = LPI_ApplicationDocumentDAO.getApplicantDocumentByDymanicQuery(fields, 'Id = \''+String.escapeSingleQuotes(fileScanList[0].AFSC__File_Parent_Id__c) + '\'', null, null, null);
            }
            if(appDocList.isEmpty()){
                throw new LPI_Exception('File not linked to document.');
            }
            if(fileScanList[0].AFSC__Verdict__c != 'Safe'){

                Application_Document__c appDocument = new Application_Document__c(Id = fileScanList[0].AFSC__File_Parent_Id__c);
                LPI_WithoutSharingUtility.deleteSObject(appDocument);
                throw new LPI_Exception('File has been deleted due to harmful content.');
            }else if(fileScanList[0].AFSC__Verdict__c == 'Safe'){
                List<Application_Document__c> updateList = new List<Application_Document__c> ();
                Application_Document__c appDocument = new Application_Document__c(Id = fileScanList[0].AFSC__File_Parent_Id__c);
                appDocument.File_Name__c = fileScanList[0].AFSC__Full_File_Name__c;
                if(appDocList[0].Is_System_Generated__c &&  result.isSubmittedAsPartOfDeficiency == true){
                    appDocument.Is_Submitted_as_a_part_of_deficiency__c = true;
                }
                appDocument.Status__c = (result.fromhandleSave != NULL && result.fromhandleSave) || (!appDocList[0].Is_additional_document_by_portal_user__c  && (result.markUnsubmitted == NULL || !result.markUnsubmitted))? 'Submitted' : 'Unsubmitted' ;
                if((result.uploadByInternalUser != NULL && result.uploadByInternalUser)){
                    appDocument.Is_Doc_Uploaded_by_Internal_User__c = true;
                } 
                if((result.fromhandleSave != NULL && result.fromhandleSave && appDocList[0].Onbase_Upload_Status__c != 'Uploaded to Onbase')){
                    appDocument.Onbase_Upload_Status__c = 'Ready to upload';
                    
                }
                appDocument.Upload_To_Onbase__c = true;
                if(String.isNotBlank(result.payLoad)){
                    appDocument.Onbase_Payload__c = result.payLoad;
                }
                if(String.isNotBlank(result.newDocumentName)){
                        appDocument.Document_Name__c =  result.newDocumentName;
                }
                if(String.isNotBlank(result.newDocumentDescription)){
                            appDocument.Description__c =  result.newDocumentDescription;
                }
                updateList.add(appDocument);
                 if((appDocument.Status__c != 'Approved')&&(result.markUnsubmitted == NULL || !result.markUnsubmitted) &&  String.isNotBlank(appDocList[0].Application_Document__c)){
                    updateList.add(new Application_Document__c(Id = appDocList[0].Application_Document__c , Status__c = 'Submitted'));
                }
                LPI_WithoutSharingUtility.updateSObjectList(updateList); // made this in without sharing update for guest users. 
               //GetApplicationDocumentController.updateStatus(appDocument.Id);

            }
            if(result.fromGenericCmp != NULL && result.fromGenericCmp){
                return getUploadDetails(result.recordId, result.objectApiName, result.whereClause);
            }
            return response;

        } catch (Exception e) {
            LPI_ExceptionManager.logException(
                'LPI_OnBaseIntegrationController',
                'getFileScanResult',
                e
            );
            throw new LPI_Exception(e.getMessage());
        }*/
    }


    /**
    * @description :  Method to get details from Case to upload a file.
    * @author Mohit Karani | 10-23-2023 
    * @param wrapper 
    * @param recordId 
    **/
    public static void getDetailsFromCase(ResponseWrapper wrapper,String recordId){
        try {
            List<Case> caseList = LPI_CaseDAO.getCaseRecords('Id,Business_License_Id__c,Account.Name,Account.IsPersonAccount,Account.firstname,Account.middlename,Account.lastname,Account.suffix,Account.Social_Security_Number__c,Board_Name__c,Case_Number__c,Is_Discipline_Reporting_Action__c','ID =\''+ String.escapeSingleQuotes(recordId) + '\'',null,null);
            if(caseList.isEmpty()){
                return ;
            }
            wrapper.description =  String.isNotBlank(caseList[0].Account.Name) ? caseList[0].Account.Name.length() > 30 ?  caseList[0].Account.Name.substring(0,30) :  caseList[0].Account.Name : null ;
            wrapper.numberValue = caseList[0].Case_Number__c.replaceAll('-', '');
            wrapper.entityName =  !caseList[0].Account.IsPersonAccount ? String.isNotBlank(caseList[0].Account.Name) && caseList[0].Account.Name.length() > 70 ? caseList[0].Account.Name.substring(0,70) : caseList[0].Account.Name :  '';
            wrapper.dateValue =   String.valueOf(Date.today().year() + '-'+String.valueOf(Date.today().month()).leftPad(2,'0')+'-'+String.valueOf(Date.today().day()).leftPad(2,'0'));
            wrapper.scanDate =  String.valueOf(Date.today().year() + '-'+String.valueOf(Date.today().month()).leftPad(2,'0')+'-'+String.valueOf(Date.today().day()).leftPad(2,'0'));
            //wrapper.recId = caseList[0].Case_Number__c;
            if(caseList[0].Is_Discipline_Reporting_Action__c){
                wrapper.boardName = 'Pharmacy';
            }else{
                wrapper.boardName = caseList[0].Board_Name__c;
            }
            Boolean accountDetailsNotPopulated = false;
            if(String.isNotBlank(caseList[0].AccountId) && caseList[0].Account.IsPersonAccount){
                accountDetailsNotPopulated = true;
                populateAccountDetails(caseList[0].Account,wrapper);
            }
            if(String.isNotBlank(caseList[0].Business_License_Id__c)){
                String contactId;
                for(BusinessLicense bl : LPI_BusinessLicenseDAO.fetchBusinessLicenseRecords('id,ContactId,RegulatoryAuthorizationType.Authorisation_Type__c,Business_Entity_Name__c,name,Legacy_License_Number__c,Pre_Licensure_Number__c, RegulatoryAuthorizationType.Profession_Code__c ', 'Id = \''+String.escapeSingleQuotes(caseList[0].Business_License_Id__c) + '\'')){
                    contactId = bl.ContactId;
                    wrapper.profCode = bl.RegulatoryAuthorizationType.Profession_Code__c;
                    wrapper.preLicensureNumber = String.isNotBlank(bl.Pre_Licensure_Number__c) ?   bl.Pre_Licensure_Number__c?.abbreviate(10) : null;
                    wrapper.preLicenseNumber = wrapper.preLicensureNumber;
                    wrapper.licenseNumber = String.isNotBlank(bl.Legacy_License_Number__c) ? bl.Legacy_License_Number__c?.abbreviate(12)  : bl.Name?.abbreviate(12);
                    wrapper.entityName = bl.RegulatoryAuthorizationType.Authorisation_Type__c == 'Business' ? bl.Business_Entity_Name__c.length() > 70 ?  bl.Business_Entity_Name__c.substring(0,70) :  bl.Business_Entity_Name__c : '';

                }
                if(!accountDetailsNotPopulated && String.isNotBlank(contactId)){
                    for(Account accNew : LPI_AccountDAO.getAccountListByDynamicQuery(new List<String>{'Id,firstname,middlename,lastname,suffix,Social_Security_Number__c'},'PersonContactId = \'' + String.escapeSingleQuotes(contactId) + '\'',null,null,null)){
                        populateAccountDetails(accNew,wrapper);
                    }
                }  
            }
            wrapper.flowName = 'complaint';
        } catch (Exception e) {
            LPI_ExceptionManager.logException(
                'LPI_OnBaseIntegrationController',
                'getDetailsFromCase',
                e
            );
            throw new LPI_Exception(e.getMessage());
        }
        
    }

     /**
    * @description :  Method to get details from Audit_Details to upload a file.
    * @author Kishore | 10-23-2023 
    * @param wrapper 
    * @param recordId 
    **/
    public static void getDetailsFromAudit(ResponseWrapper wrapper,String recordId){
        try {
            List<Audit_Detail__c> auditList = LPI_AuditDetailsDAO.getAuditDetailsByDymanicQuery('Id,Business_License__r.ContactId,Board_Name__c,Business_License__r.Legacy_License_Number__c,Business_License__r.RegulatoryAuthorizationType.Profession_Code__c,Business_License__r.Business_Entity_Name__c,Business_License__r.Regulatory_Authorization_Type_Name__c,Business_License__r.Pre_Licensure_Number__c,Business_License__r.Name,Business_License__r.Contact.Suffix,Business_License__r.Contact.FirstName,Business_License__r.Contact.MiddleName,Business_License__r.Contact.LastName,Business_License__r.Contact.IsPersonAccount,Name','ID =\''+ String.escapeSingleQuotes(recordId) + '\'',null,null,null);
            if(auditList.isEmpty()){
                return ;
            }
            //String numberValue = String.isNotBlank(auditList[0].Business_License__r.Promo_Id__c) ?auditList[0].Business_License__r.Promo_Id__c  : auditList[0].Business_License__r.Pre_Licensure_Number__c;

            //wrapper.description = numberValue?.abbreviate(30);
            //wrapper.numberValue = numberValue?.abbreviate(10);
            wrapper.lienseNumber = String.isNotBlank(auditList[0].Business_License__r.Pre_Licensure_Number__c) ? auditList[0].Business_License__r.Pre_Licensure_Number__c : auditList[0].Business_License__r.Name;
            wrapper.boardName = auditList[0].Board_Name__c;
            if(String.isNotBlank(auditList[0].Business_License__r.ContactId)){
                for(Account accNew : LPI_AccountDAO.getAccountListByDynamicQuery(new List<String>{'Id,firstname,middlename,lastname,suffix,Social_Security_Number__c'},'PersonContactId = \'' + String.escapeSingleQuotes(auditList[0].Business_License__r.ContactId) + '\'',null,null,null)){
                    populateAccountDetails(accNew,wrapper);
                }
            }
            wrapper.entityName = auditList[0].Business_License__r.Business_Entity_Name__c?.abbreviate(70);
            wrapper.profCode = auditList[0].Business_License__r.RegulatoryAuthorizationType.Profession_Code__c;
            wrapper.dateValue =  String.valueOf(Date.today().year() + '-'+String.valueOf(Date.today().month()).leftPad(2,'0')+'-'+String.valueOf(Date.today().day()).leftPad(2,'0'));
            wrapper.scanDate =  String.valueOf(Date.today().year() + '-'+String.valueOf(Date.today().month()).leftPad(2,'0')+'-'+String.valueOf(Date.today().day()).leftPad(2,'0'));
            //wrapper.recId =  auditList[0].Name.substringAfter('-');
            wrapper.flowName = 'License';
        } catch (Exception e) {
            LPI_ExceptionManager.logException(
                'LPI_OnBaseIntegrationController',
                'getDetailsFromAudit',
                e
            );
            throw new LPI_Exception(e.getMessage());
        }
    }

    /**
    * @description : Method to delete the created app document on click of Cancel or Close Button.
    * @author Mohit Karani | 12-29-2023 
    * @param recordId 
    **/
    @AuraEnabled
    public static void handleCancel(String recordId){
        try {
           if(String.isBlank(recordId)){
                throw new LPI_Exception('Error cancelling document');
            }
            List<Application_Document__c> appDocList = LPI_ApplicationDocumentDAO.getApplicantDocumentByDymanicQuery('Id,Onbase_Document_Id__c,File_Name__c,Preliminary_Application_Reference__c,Board_Name__c,Document_Name__c,Is_System_Generated__c,Upload_To_Onbase__c','ID = \'' + String.escapeSingleQuotes(recordId) + '\'', null, null, null);
            if(appDocList.isEmpty()){
                throw new LPI_Exception('Error occured while canceling document'); 
            }
            // if(String.isNotBlank(appDocList[0].Onbase_Document_Id__c)){
            //     callDeleteDownloadApi(appDocList[0].Onbase_Document_Id__c,'DELETE');
            // }
            if(!appDocList[0].Is_System_Generated__c){
                LPI_WithoutSharingUtility.deleteSObject(appDocList[0]);
            }
        } 
        catch (Exception e) {
            LPI_ExceptionManager.logException(
                'LPI_OnBaseIntegrationController',
                'handleCancel',
                e
            );
            throw new LPI_Exception(e.getMessage());
        }
    }

    @AuraEnabled
    public static void updateOnbaseuploadStatus(List<Id> recordIdList){
        try {
            if(recordIdList.isEmpty()){
                return;
            }
            List<Application_Document__c> appDocList = LPI_ApplicationDocumentDAO.getApplicantDocumentByDymanicQuery('Id,File_Name__c,Preliminary_Application_Reference__c,Board_Name__c,Document_Name__c,Is_System_Generated__c,Upload_To_Onbase__c',  'ID IN  ' +LPI_ServiceUtility.getStringValuesByList(recordIdList), null, null, null);
            for(Application_Document__c appDoc : appDocList){
                appDoc.Onbase_Upload_Status__c = 'Delete from onbase';
            }
            LPI_DML.doUpdate(appDocList);

        } catch (Exception e) {
            LPI_ExceptionManager.logException(
                'LPI_OnBaseIntegrationController',
                'updateOnbaseuploadStatus',
                e
            );
            throw new LPI_Exception(e.getMessage());
        }
    }

    /**
    * @description : Method to call delete or download api based on the method type passed.
    * @author Mohit Karani | 01-30-2024 
    * @param fileId 
    * @param methodType 
    * @return String 
    **/
    
    // public static Blob callDeleteDownloadApi(String fileId,String methodType){
    //     try{
    //         LPI_Integration_Config__mdt onbaseConfig = LPI_Integration_Config__mdt.getInstance('Onbase');
    //         HttpRequest request = new HttpRequest();
    //         if(methodType == 'DELETE'){
    //         request.setMethod('DELETE');
    //         request.setEndpoint(onbaseConfig.Auth_End_Point__c+'/'+fileId);
    //         }else{
    //             request.setMethod('GET');
    //             request.setEndpoint(onbaseConfig.Auth_End_Point__c+'retrieve/'+fileId);
    //         }
    //         request.setHeader('client_id', onbaseConfig.Client_Id__c);
    //         request.setHeader('client_secret', onbaseConfig.Private_Key__c);
    //         request.setHeader('X-Correlation-Id', onbaseConfig.X_Correlation_Id__c);
    //         request.setTimeOut(120000);
    //         Http httpReq = new Http();
    //         HTTPResponse response = httpReq.send(request);
    //         if(response.getStatusCode() != 200 && methodType == 'DELETE'){
    //             throw new LPI_Exception('Error deleting document.');
    //         }else if(response.getStatusCode() != 200 && methodType == 'GET'){
    //             throw new LPI_Exception('Error Downloading document.'+response.getStatusCode());
    //         }
    //         return response.getBodyAsBlob();
    //     }
    //     catch (Exception e) {
    //         LPI_ExceptionManager.logException(
    //             'LPI_OnBaseIntegrationController',
    //             'callDeleteDownloadApi',
    //             e
    //         );
    //         throw new LPI_Exception(e.getMessage());
    //     }
        
    // }

    /**
    * @description : Method to delete the ContentDocument from SF after downloading the file. 
    * @author Mohit Karani | 01-30-2024 
    * @param contentDocumentId 
    **/
    @AuraEnabled @future
    public static void handleContentDocumentDelete(String contentDocumentId,String appDocId){
        try{
            List<Application_Document__c> appDocList = LPI_ApplicationDocumentDAO.getApplicantDocumentByDymanicQuery('Id,File_Name__c,Preliminary_Application_Reference__c,Board_Name__c,Document_Name__c,Is_System_Generated__c,Upload_To_Onbase__c',  'ID = \'' + String.escapeSingleQuotes(appDocId) + '\' AND Onbase_Document_Id__c != NULL' , null, null, null);
            if(!appDocList.isEmpty()){
                LPI_DML.doDelete(new ContentDocument(Id = contentDocumentId));
            }
        }catch (Exception e) {
            LPI_ExceptionManager.logException(
                'LPI_OnBaseIntegrationController',
                'handleContentDocumentDelete',
                e
            );
            throw new LPI_Exception(e.getMessage());
        }
       
       
    }
    

    /**
    * @description : Method to delete files from SF and Onbase.
    * @author Mohit Karani | 12-27-2023 
    * @param jsonData 
    * @return ResponseWrapper 
    **/
    @AuraEnabled
    public static ResponseWrapper handleFileDelete(String jsonData){
        try {
            
            ScanFileWrapper file = (ScanFileWrapper)JSON.deserialize(jsonData, ScanFileWrapper.class);
            if(String.isBlank(file.appDocumentId)){
                throw new LPI_Exception('Unable to delete file12312.'+file.appDocumentId);
            }

            List<Application_Document__c> appDocList = LPI_ApplicationDocumentDAO.getApplicantDocumentByDymanicQueryWithoutSecurity('Application_Document__r.CreatedBy.ProfileId,Uploaded_By_Internal_User__c,Id,CreatedBy.ProfileId,Is_additional_document_by_portal_user__c,Application_Document__r.Is_System_Generated__c,Application_Document__c,Application_Document__r.Onbase_Document_Id__c,Is_System_Generated__c,Onbase_Document_Id__c', 'Id = \''+String.escapeSingleQuotes(file.appDocumentId) + '\'', null, null, null);
            List<Application_Document__c> childAppDocList = LPI_ApplicationDocumentDAO.getApplicantDocumentByDymanicQueryWithoutSecurity('Id,CreatedBy.ProfileId,(SELECT ID FROM ContentDocumentLinks),Onbase_Document_Id__c', 'Application_Document__c = \''+String.escapeSingleQuotes(file.appDocumentId) + '\'', null, null, null);
            if(appDocList.isEmpty()){
                throw new LPI_Exception('Error deleting document.');
            }
            List<String> internalProfileslist = new List<String>{
                'Board Staff',
                'Support Staff',
                'Inspectors',
                'System Administrator'

            };
            Set<String> intenralProfileIdSet = new Set<String>();
            for(Profile profileRec : LPI_ProfileDao.getProfileByDymanicQuery('Id','Profile.Name IN ' + LPI_ServiceUtility.getStringValuesByList(internalProfileslist),null,null,null)){
                intenralProfileIdSet.add(profileRec.Id);
            }
            // if(((file.fromDeficiencyResponse != null && file.fromDeficiencyResponse &&  !appDocList[0].Uploaded_By_Internal_User__c) || (appDocList[0].CreatedBy.ProfileId == Userinfo.getProfileId() || intenralProfileIdSet.contains(Userinfo.getProfileId())) )&& String.isNotBlank(appDocList[0].Onbase_Document_Id__c)){
            //     callDeleteDownloadApi(appDocList[0].Onbase_Document_Id__c,'DELETE');
            // }
            Set<Id> deletedAppDocIdSet = new Set<Id>();
           
           
            if((appDocList[0].CreatedBy.ProfileId == Userinfo.getProfileId() || intenralProfileIdSet.contains(Userinfo.getProfileId())) && !appDocList[0].Is_System_Generated__c && childAppDocList.isEmpty()&& (file.doNotDelete == NULL || !file.doNotDelete)){
                deletedAppDocIdSet.add(appDocList[0].Id);
                LPI_WithoutSharingUtility.deleteSObject(appDocList[0]);
            }
            

            Boolean doUpdate = false;
            if((file.fromDeficiencyResponse != null && file.fromDeficiencyResponse &&  !appDocList[0].Uploaded_By_Internal_User__c) || appDocList[0].Is_System_Generated__c || !childAppDocList.isEmpty() ||(file.doNotDelete != NULL && file.doNotDelete)){
                String cdId;
                for(ContentDocumentLink cdl : LPI_ContentDocumentLinkDAO.getContentDocumentLinkByDymanicQuery('Id,ContentDocumentId','LinkedEntityId = \''+String.escapeSingleQuotes(appDocList[0].Id) + '\'',null,null,null)){
                    cdId = cdl.ContentDocumentId;
                }
                if(String.isNotBlank(cdId)){
                    ContentDocument cd = new ContentDocument(Id = cdId);
                    LPI_DML.doDelete(cd);
                }
                appDocList[0].Onbase_Upload_Status__c = null;
                appDocList[0].Onbase_Document_Id__c = null;
                appDocList[0].File_Name__c = null;
                //appDocList[0].Onbase_Error_Log__c = null; 
                doUpdate = true;
            }
            Boolean parentDeleted = false;
            if( (appDocList[0].Application_Document__r.CreatedBy.ProfileId == Userinfo.getProfileId() || intenralProfileIdSet.contains(Userinfo.getProfileId())) && String.isNotBlank(appDocList[0].Application_Document__c) && file.intakeFileDelete != NULL && file.intakeFileDelete && !appDocList[0].Application_Document__r.Is_System_Generated__c){
                Boolean deteleAppDocParent = true;
                for(Application_Document__c appDoc :  LPI_ApplicationDocumentDAO.getApplicantDocumentByDymanicQuery('Id,Onbase_Document_Id__c,(SELECT ID FROM ContentDocumentLinks)','(Application_Document__c = \''+appDocList[0].Application_Document__c+ '\' OR Id = \''+appDocList[0].Application_Document__c + '\')',NULL,NULL,NULL)){
                    deteleAppDocParent = appDoc.ContentDocumentLinks.isEmpty() && String.isBlank(appDoc.Onbase_Document_Id__c);
                   
                    if(!deteleAppDocParent){
                        break;
                    }
                }
                if(deteleAppDocParent){
                    parentDeleted = true;
                    deletedAppDocIdSet.add(appDocList[0].Application_Document__c);
                    LPI_WithoutSharingUtility.deleteSObject(new Application_Document__c(Id = appDocList[0].Application_Document__c));
                }
            }

            Boolean markUnsmubitted = false;
            // parent application document and no child docs and parent record also file also removed
            if(String.isBlank(appDocList[0].Application_Document__c) && childAppDocList.isEmpty() && appDocList[0].Is_System_Generated__c){
                appDocList[0].Status__c = 'Unsubmitted';
                appDocList[0].Source_of_Document_Upload__c = null;
                doUpdate = true;
            }
            else if(String.isBlank(appDocList[0].Application_Document__c) && !childAppDocList.isEmpty()){
               
                for(Application_Document__c childAppDocs : childAppDocList){
                    markUnsmubitted = childAppDocs.ContentDocumentLinks.isEmpty() && String.isBlank(childAppDocs.Onbase_Document_Id__c);
                    if(!markUnsmubitted){
                        break;
                    }

                }
                if(markUnsmubitted){
                    appDocList[0].Status__c = 'Unsubmitted';
                    appDocList[0].Source_of_Document_Upload__c =null;
                    doUpdate = true;
                }
                // appDocList[0].Status__c = 'Unsubmitted';
            }else if(String.isNotBlank(appDocList[0].Application_Document__c) && !parentDeleted){

                for(Application_Document__c appDoc :  LPI_ApplicationDocumentDAO.getApplicantDocumentByDymanicQuery('Id,Onbase_Document_Id__c,(SELECT ID FROM ContentDocumentLinks)','(Application_Document__c = \''+appDocList[0].Application_Document__c+ '\' OR Id = \''+appDocList[0].Application_Document__c + '\')',NULL,NULL,NULL)){
                    markUnsmubitted = appDoc.ContentDocumentLinks.isEmpty() && String.isBlank(appDoc.Onbase_Document_Id__c);
                   
                    if(!markUnsmubitted){
                        break;
                    }
                }
                if(markUnsmubitted){
                    appDocList[0].Status__c = 'Unsubmitted';
                    appDocList[0].Source_of_Document_Upload__c =null;
                    doUpdate = true;
                }
            }
            
            if(doUpdate && !deletedAppDocIdSet.contains(appDocList[0].Id)){
                LPI_DML.doUpdate(appDocList[0]);
            }
            
           
            if(file.fromGenericCmp != NULL && file.fromGenericCmp){
                return getUploadDetails(file.recordId, file.objectApiName, file.whereClause);
            }
            ResponseWrapper respWrapper = new ResponseWrapper();
            respWrapper.parentDeleted = parentDeleted;
            respWrapper.deletedAppRecId = new List<Id>(deletedAppDocIdSet);
            return respWrapper;
            
        } catch (Exception e) {
            LPI_ExceptionManager.logException(
                'LPI_OnBaseIntegrationController',
                'handleFileDelete',
                e
            );
            throw new LPI_Exception(e.getMessage());
        }
    }


    public class ResponseWrapper{
       @AuraEnabled public string numberValue;
       @AuraEnabled public string description;
       @AuraEnabled public string documentDate;
      // @AuraEnabled public string onbaseHeaders;
       @AuraEnabled public string boardName;
       @AuraEnabled public string flowName;
       @AuraEnabled public string inspectionDate;
       @AuraEnabled public string complaintNumber;
       @AuraEnabled public string entityName;
       @AuraEnabled public string firstName;
       @AuraEnabled public string middleName;
       @AuraEnabled public string lastName;
       @AuraEnabled public string suffixName;
       @AuraEnabled public string profCode;
       @AuraEnabled public string ssn;
       @AuraEnabled public string scanDate;
       @AuraEnabled public string dateValue;
       @AuraEnabled public string harmfulContent;
       @AuraEnabled public string preLicensureNumber;
       @AuraEnabled public string preLicenseNumber;
       @AuraEnabled public string licenseNumber;
       @AuraEnabled public string lienseNumber;
       @AuraEnabled public Map<String,String> onbaseConfig = new Map<String,String>();
       @AuraEnabled public List<LPI_Wrapper.FileWrapper> fileList = new List<LPI_Wrapper.FileWrapper>();
       @AuraEnabled public string twoByTwoPhotoRecommendation;
       @AuraEnabled public Boolean uploadReqd = true;
       @AuraEnabled public string recId;
       @AuraEnabled public Boolean parentDeleted; 
       @AuraEnabled public List<Id> deletedAppRecId;
       @AuraEnabled public string programType;
       @AuraEnabled public string providerCode;
       @AuraEnabled public string accountName;
       
    }

    public class OnbaseFileWrapper{
        @AuraEnabled public string documentId;
        @AuraEnabled public string fileName;
        @AuraEnabled public string documentName;
        @AuraEnabled public string lookupFieldName;
        @AuraEnabled public string lookupFieldId;
        @AuraEnabled public string boardName;
        @AuraEnabled public Boolean isSendNotification;
        @AuraEnabled public String ownerId;
        @AuraEnabled public String caseNumber;
        @AuraEnabled public String portalUserName;
        @AuraEnabled public String activeActivity;
        @AuraEnabled public String status;
        @AuraEnabled public String dueDate;
        @AuraEnabled public String caseSubject;
        @AuraEnabled public String ownerName;
        @AuraEnabled public String onbasePayload;
    }

    public class ScanFileWrapper{
        @AuraEnabled public string contentDocumentId;
        @AuraEnabled public string recordId;
        @AuraEnabled public string objectApiName;
        @AuraEnabled public string whereClause;
        @AuraEnabled public string appDocumentId;
        @AuraEnabled public Boolean fromGenericCmp;
        @AuraEnabled public string payLoad;
        @AuraEnabled public string fileId;
        @AuraEnabled public string newDocumentName;
        @AuraEnabled public string newDocumentDescription;
        @AuraEnabled public Boolean intakeFileDelete;
        @AuraEnabled public Boolean doNotDelete;
        @AuraEnabled public Boolean markUnsubmitted;
        @AuraEnabled public Boolean fromDeficiencyResponse;
        @AuraEnabled public Boolean fromhandleSave;
        @AuraEnabled public Boolean fromDeficiency;
        @AuraEnabled public Boolean uploadByInternalUser;
        @AuraEnabled public Boolean isSubmittedAsPartOfDeficiency;
        @AuraEnabled public string applicationId;
  }

    
}