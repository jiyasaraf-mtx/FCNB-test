/**
 * @description       : Controller class to get Inspection Records to populate on PDF via vfPage
 * @author            : Mohit Karani
 * @group             : 
 * @last modified on  : 05-28-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class LPI_InspectionReportController {
    public Id recordId {get;set;}
    public InspectionDetailWrapper inspectionDetail{get;set;}
    public Map<String,List<QuestionsWrapper>> headingToQuesMap{get;set;}
    public List<String> sectionsList{get;set;}
    public list<String> apiNameList{get;set;}
    public list<String> questionNameList{get;set;}
    public List<InspectionContenetWrapperList> wrapperList{get;set;}

    /**
    * @description       : Method used to get Inspection data and assign to repective Wrappers
    * @author            : Ankit
    * @group             : 
    * @last modified on  : 05-28-2024
    * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
    **/
    public LPI_InspectionReportController(ApexPages.StandardController controller){  
        recordId = ApexPages.currentPage() != null
            ? ApexPages.currentPage().getParameters().get('id')
            : null;
        if(String.isBlank(recordId) && controller != null){
            recordId = controller.getId();
        }
        headingToQuesMap = new Map<String,List<QuestionsWrapper>>();
        sectionsList = new List<String>();
        apiNameList = new List<String>();
        questionNameList = new List<String>();
        wrapperList = new List<InspectionContenetWrapperList>();
        inspectionDetail = new InspectionDetailWrapper();

        List<Visit> visitList = LPI_VisitControllerDAO.getVisitListByDynamicQueryWithoutSecurity(new List<String>{'Id,Account.Name,Business_Name__c,Account.Buisness_Email__c,Name_of_Licensee_Applicant_Representativ__c,Licensee_Applicant_Rep_Signed_Date__c,'
            +'Account.phone,AccountId,User.Name,Title__c,Owner.Name,Inspector_Signed_Date__c,ContextId,Date_Assigned__c,Actual_Start_Date__c,VisitType.Name,Visitor.Name,Board_Name__c,'
            +'TYPEOF Context WHEN Case THEN License_Number__c, License_Number_Custom__c, License_Number_Custom__r.Name, Board_Name__c, License_Type__c WHEN BusinessLicense THEN Name, RegulatoryAuthorizationType.Name WHEN BusinessLicenseApplication THEN Name, LicenseType.Name END,'
            +'License_Type__c,TYPEOF PLACE WHEN ADDRESS THEN Street,City,PostalCode,County__c END'},'Id =\''+ recordId+  '\'',null,null,null);
        if(visitList.isEmpty()){
            return; 
        }
        List<Visit> contextsVisitList = new List<Visit>();
        if(String.isNotBlank(visitList[0].ContextId)){
            contextsVisitList = LPI_VisitControllerDAO.getVisitListByDynamicQueryWithoutSecurity(
                new List<String>{'Id,Actual_Start_Date__c'},
                'ContextId =\''+ visitList[0].ContextId +  '\'',
                null,
                'CreatedDate',
                'Desc'
            );
        }
        Schema.Address addressRc = visitList[0].Place instanceof Schema.Address
            ? (Schema.Address) visitList[0].Place
            : null;
        if(visitList[0].Context instanceof Case){
            Case c = (Case) visitList[0].Context;
            String caseLicenseNum = String.isNotBlank(c.License_Number_Custom__c) && c.License_Number_Custom__r != null
                ? c.License_Number_Custom__r.Name
                : c.License_Number__c;
            inspectionDetail.preLicenseNum = caseLicenseNum;
        	inspectionDetail.licenseNum = caseLicenseNum;
            if(String.isBlank(visitList[0].Board_Name__c) && String.isNotBlank(c.Board_Name__c)){
                visitList[0].Board_Name__c = c.Board_Name__c;
            }
            if(String.isBlank(visitList[0].License_Type__c) && String.isNotBlank(c.License_Type__c)){
                visitList[0].License_Type__c = c.License_Type__c;
            }
        }else if(visitList[0].Context instanceof BusinessLicense){
            BusinessLicense bl = (BusinessLicense) visitList[0].Context;
            inspectionDetail.preLicenseNum = bl.Name;
        	inspectionDetail.licenseNum = bl.Name;
            if(String.isBlank(visitList[0].License_Type__c) && bl.RegulatoryAuthorizationType != null){
                visitList[0].License_Type__c = bl.RegulatoryAuthorizationType.Name;
            }
        }else if(visitList[0].Context instanceof BusinessLicenseApplication){
            BusinessLicenseApplication bla = (BusinessLicenseApplication) visitList[0].Context;
            inspectionDetail.preLicenseNum = bla.Name;
        	inspectionDetail.licenseNum = bla.Name;
            if(String.isBlank(visitList[0].License_Type__c) && bla.LicenseType != null){
                visitList[0].License_Type__c = bla.LicenseType.Name;
            }
        }else{
            inspectionDetail.preLicenseNum = null;
        	inspectionDetail.licenseNum = null;
        }
        inspectionDetail.entityName = String.isNotBlank(visitList[0].Business_Name__c)
            ? visitList[0].Business_Name__c
            : (visitList[0].Account != null ? visitList[0].Account.Name : null);
        inspectionDetail.businessEmail = visitList[0].Account != null ? visitList[0].Account.Buisness_Email__c : null;
        inspectionDetail.accPhone = visitList[0].Account != null ? visitList[0].Account.Phone : null;
        inspectionDetail.street = addressRc != null ? addressRc.Street : null;
        inspectionDetail.city = addressRc != null ? addressRc.City : null;
        inspectionDetail.zip = addressRc != null ? addressRc.PostalCode : null;
        inspectionDetail.county = addressRc != null ? addressRc.County__c : null;
        inspectionDetail.inspectionDate = visitList[0].Actual_Start_Date__c != null
            ? Date.valueOf(visitList[0].Actual_Start_Date__c).format()
            : null;
        if(!contextsVisitList.isEmpty() && contextsVisitList[0].Actual_Start_Date__c != null){
            inspectionDetail.lastInspectionDate = Date.valueOf(contextsVisitList[0].Actual_Start_Date__c).format();
        }
        inspectionDetail.inspectionType = visitList[0].VisitType != null ? visitList[0].VisitType.Name : null;
        inspectionDetail.inspector = visitList[0].Visitor != null ? visitList[0].Visitor.Name : null;
        inspectionDetail.professionCaps = String.isNotBlank(visitList[0].License_Type__c)
            ? visitList[0].License_Type__c.toUpperCase()
            : null;
        inspectionDetail.profession = visitList[0].License_Type__c;
        inspectionDetail.boardName = String.isNotBlank(visitList[0].Board_Name__c)
            ? visitList[0].Board_Name__c.toUpperCase()
            : null;
        List<Business_Relationships__c> businessRelationshipsRecord = new List<Business_Relationships__c>();
        if(String.isNotBlank(visitList[0].AccountId)){
            businessRelationshipsRecord = LPI_BusinessRelationshipDAO.fetchBusinessRelationshipRecords(
                'Id,Related_To__r.Name,Roles__c,Ownership_Percent__c',
                'Related_From__c = \'' + visitList[0].AccountId +'\' AND Roles__c = \'Owner\'',
                null,
                'Ownership_Percent__c Desc,Related_To__r.Name Desc',
                null
            );
        }
        if(businessRelationshipsRecord.isEmpty()){
            inspectionDetail.ownerName = visitList[0].Owner != null ? visitList[0].Owner.Name : null;
        }else{
            inspectionDetail.ownerName = businessRelationshipsRecord[0].Related_To__r?.Name;
        }
        inspectionDetail.inspectorName = visitList[0].User != null ? visitList[0].User.Name : null;
        if(visitList[0].Inspector_Signed_Date__c!=null){
            inspectionDetail.inspectorSingnedByDate = Date.valueOf(visitList[0].Inspector_Signed_Date__c)?.format();
        }
        else if(visitList[0].Date_Assigned__c != null){
            inspectionDetail.inspectorSingnedByDate = Date.valueOf(visitList[0].Date_Assigned__c)?.format();
        }
        inspectionDetail.title = visitList[0].Title__c;
        inspectionDetail.licenseeName = visitList[0].Name_of_Licensee_Applicant_Representativ__c;
        if(visitList[0].Licensee_Applicant_Rep_Signed_Date__c!=null){
            inspectionDetail.licenseeSignedDate = Date.valueOf(visitList[0].Licensee_Applicant_Rep_Signed_Date__c)?.format();
        }
        else if(visitList[0].Date_Assigned__c != null){
            inspectionDetail.licenseeSignedDate = Date.valueOf(visitList[0].Date_Assigned__c)?.format();
        }
        
        if(String.isNotBlank(visitList[0].Board_Name__c)){
            List<RegulatoryAuthority> boardDetails = LPI_RegulatoryAuthorityDAO.getRegulatoryAuthorityByDymanicQuery(
                'id,Email_Specifications__c',
                'Name Like \''+ String.escapeSingleQuotes(visitList[0].Board_Name__c) +'\'',
                null,
                null,
                null
            );
            if(!boardDetails.isEmpty() && String.isNotBlank(boardDetails[0].Email_Specifications__c)){
                BoardDetails boardInfo = (BoardDetails) JSON.deserializeStrict(
                    boardDetails[0].Email_Specifications__c,
                    BoardDetails.class
                );
                if(boardInfo != null && String.isNotBlank(boardInfo.boardPoBox)){
                    inspectionDetail.boardPOBox = boardInfo.boardPoBox.toUpperCase();
                }
            }
        }
        
        List<AssessmentIndValue> aivList = new List<AssessmentIndValue>();
        Map<Id,QuestionsWrapper> inspectionAssessmentIndToWrapperMap = new Map<Id,QuestionsWrapper>();

        for(InspectionAssessmentInd iai : LPI_InspectionAssessmentIndDAO.getInspectionAssessmentIndicatorByDymanicQuery('Id,AssessmentTask.AssessmentTaskDefinition.name,AssessmentIndDefinition.Convert_To_Text_Area__c,AssessmentIndDefinition.Question_Text__c,Comments__c,AssessmentIndDefinition.DataType,DateTimeFieldResponse,Text_Area_Field_Response__c,(SELECT ID,SourceObjectId,AssessmentIndDefinedValue.value from SourceObjects)','Assessmenttask.ParentId = \'' +recordId+ '\'',null,'Assessmenttask.Sequencenumber','ASC')){
            QuestionsWrapper wrapper = new QuestionsWrapper();
            wrapper.question = iai.AssessmentIndDefinition != null ? iai.AssessmentIndDefinition.Question_Text__c : null;
            wrapper.comments = iai.Comments__c;
            if(iai.AssessmentIndDefinition != null && iai.AssessmentIndDefinition.Convert_To_Text_Area__c){
                wrapper.answer = iai.Text_Area_Field_Response__c;
            }
            else if(iai.AssessmentIndDefinition != null && iai.AssessmentIndDefinition.DataType == 'DateTime' && iai.DateTimeFieldResponse != NULL ){
                wrapper.answer = iai.DateTimeFieldResponse.format();
            }
            else if(iai.AssessmentIndDefinition != null && iai.AssessmentIndDefinition.DataType == LPI_AssessmentTaskController.PICKLIST_TYPE && iai.SourceObjects != null && !iai.SourceObjects.isEmpty()){
                wrapper.answer = iai.SourceObjects[0].AssessmentIndDefinedValue.value;
            }
            else if(iai.AssessmentIndDefinition != null && iai.AssessmentIndDefinition.DataType == LPI_AssessmentTaskController.MULTI_SELECT_PICKLIST && iai.SourceObjects != null){
                aivList.addAll(iai.SourceObjects);
            }
            if(iai.AssessmentIndDefinition != null
                && iai.AssessmentIndDefinition.Question_Text__c == 'ESTABLISHMENT TYPE'
                && iai.SourceObjects != null
                && !iai.SourceObjects.isEmpty()
                && iai.SourceObjects[0].AssessmentIndDefinedValue != null){
                inspectionDetail.establishmentType = iai.SourceObjects[0].AssessmentIndDefinedValue.value;
            }

            inspectionAssessmentIndToWrapperMap.put(iai.Id,wrapper);
            String sectionName = iai.AssessmentTask != null
                && iai.AssessmentTask.AssessmentTaskDefinition != null
                ? iai.AssessmentTask.AssessmentTaskDefinition.Name
                : null;
            if(String.isBlank(sectionName)){
                continue;
            }
            if(!headingToQuesMap.containsKey(sectionName)){
                headingToQuesMap.put(sectionName,new List<QuestionsWrapper>());
            }
            headingToQuesMap.get(sectionName).add(wrapper);
        }
        for(AssessmentIndValue aiv : aivList){
            if(!inspectionAssessmentIndToWrapperMap.containsKey(aiv.SourceObjectId)
                || aiv.AssessmentIndDefinedValue == null){
                continue;
            }
            if(String.isBlank(inspectionAssessmentIndToWrapperMap.get(aiv.SourceObjectId).answer)){
                inspectionAssessmentIndToWrapperMap.get(aiv.SourceObjectId).answer = aiv.AssessmentIndDefinedValue.value;
            }else{
                inspectionAssessmentIndToWrapperMap.get(aiv.SourceObjectId).answer  = inspectionAssessmentIndToWrapperMap.get(aiv.SourceObjectId).answer + ';'+aiv.AssessmentIndDefinedValue.value;
            }
        }
        sectionsList = new List<String>(headingToQuesMap.keySet());
        if(String.isNotBlank(visitList[0].License_Type__c)){
            String ratFields = 'Id, Inspection_Questions__c';
            String ratWhereClause = 'Name = \'' + String.escapeSingleQuotes(visitList[0].License_Type__c) +'\'';
            LPI_RegulatoryAuthorizationTypeDAO.LPI_RegulatoryAuthorizationTypeWithoutSharingDAO getRATRecord= new LPI_RegulatoryAuthorizationTypeDAO.LPI_RegulatoryAuthorizationTypeWithoutSharingDAO();
        	List<RegulatoryAuthorizationType> ratInspectionQuestionRec = getRATRecord.getRegAuthTypeWithoutSecurity(ratFields, ratWhereClause, null, null, null);
            if(!ratInspectionQuestionRec.isEmpty() && ratInspectionQuestionRec[0].Inspection_Questions__c != null){
                Map<String, Object> inspectionQuestionsMap = (Map<String, Object>)
        				JSON.deserializeUntyped(ratInspectionQuestionRec[0].Inspection_Questions__c);
                inspectionDetail.header = (String) inspectionQuestionsMap.get('header');
    			inspectionDetail.footer = (String) inspectionQuestionsMap.get('footer');
                ApiQuestionNames extractedNames = extractApiNames(ratInspectionQuestionRec[0].Inspection_Questions__c);
    			apiNameList = extractedNames.apiNames != null ? extractedNames.apiNames : new List<String>();
    			questionNameList = extractedNames.questionNames != null ? extractedNames.questionNames : new List<String>();
            }
        }
        Map<String,List<Object>> inspectionContentMap = LPI_VisitController.getInscpetcionQuestion(recordId);
        if(inspectionContentMap != NULL && inspectionContentMap.get('inspectionContentList') != null && !apiNameList.isEmpty()){
            for(Inspection_Content__c ic : (List<Inspection_Content__c>)inspectionContentMap.get('inspectionContentList')){
                InspectionContenetWrapperList wrapper = new InspectionContenetWrapperList();
                wrapper.insColumnClassList = new List<InsColumnClass>();
                for(string stringtext : apiNameList){
                   InsColumnClass columnWrapper = new InsColumnClass();
                   columnWrapper.insConFieldValue = String.valueOf(ic.get(stringtext));
                   wrapper.insColumnClassList.add(columnWrapper);
                }
                wrapperList.add(wrapper);
            }  
        }  
    }
    
    /**
    * @description       : Method to get Questions and Questions API Name form Json String of Inspection Questions 
    * @author            : Ankit Bansal
    * @group             : 
    * @last modified on  : 05-28-2024
    * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
    **/
    public ApiQuestionNames extractApiNames(String jsonString) {
        Map<String,Object> mp = (Map<String,Object>) JSON.deserializeUntyped(jsonString);
        List<Object> jsonList = (List<Object>)mp.get('form');
        List<String> apiNames = new List<String>();
        List<String> questionNames = new List<String>();

        for (Object element : jsonList) {
            if (element instanceof Map<String, Object>) {
                Map<String, Object> jsonMap = (Map<String, Object>)element;
                if (jsonMap.containsKey('apiName')) {
                    apiNames.add((String)jsonMap.get('apiName'));
                }
                if(jsonMap.containsKey('question')){
                    questionNames.add((String)jsonMap.get('question'));
                }
            }
        }
        ApiQuestionNames result = new ApiQuestionNames();
    	result.apiNames = apiNames;
    	result.questionNames = questionNames;

        return result;
    }
    //Wrappers to store Qustion and api name
    public class ApiQuestionNames {
       public List<String> apiNames { get; set; }
       public List<String> questionNames { get; set; }
    }
    
    //Wrapper to store inspection content
    public class InspectionContenetWrapperList{
        public List<InsColumnClass> insColumnClassList {get;set;}
    }

    //Wrapper to store Inspection Question text value
    public class InsColumnClass{
        public string insConFieldValue {get;set;}
    }

    //Wrapper to store Inspection Details
    public class InspectionDetailWrapper{
        public string entityName{get;set;}
        public string preLicenseNum{get;set;}
        public string licenseNum{get;set;}
        public string phone{get;set;}
        public string street{get;set;}
        public string city{get;set;}
        public string zip{get;set;}
        public string county{get;set;}
        public String inspectionDate{get;set;}
        public String lastInspectionDate{get;set;}
        public string inspectionType{get;set;}
        public string inspector{get;set;}
        public string profession{get;set;}
        public string professionCaps{get;set;}
        public string establishmentType{get;set;}
        public string boardName{get;set;}
        public string boardPOBox{get;set;}
        public string ownerName{get;set;}
        public string businessEmail{get;set;}
        public string accPhone{get;set;}
        public string inspectorName{get;set;}
        public string title{get;set;}
        public String inspectorSingnedByDate{get;set;}
        public String licenseeName{get;set;}
        public String licenseeSignedDate{get;set;}
        public String header{get;set;}
        public String footer{get;set;}
    }

    //Wrapper to store questions from InspectionAssessmentInd 
    public class QuestionsWrapper{
        public string question{get;set;}
        public string answer{get;set;}
        public string comments{get;set;}
        public string quesNumber{get;set;}
    }
    
    //Wrapper to store Board Datails
    public class BoardDetails {
        public String boardEmail;
        public String boardPoBox;
        public String boardName;
    }
}