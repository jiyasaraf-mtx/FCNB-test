/**
 * @author : Anmol Mathur
 * @since : 6th Dec 2022
 * @description : This apex class Captures Request from Mobile and returns required data.
 */

 @RestResource(urlMapping='/InspectionTasks/*')
 global with sharing class LPI_InspectionsControllerRestResource {
 
      /**
      * @author                   Anmol Mathur
      * @description              This is the POST Method of the class which will update the Visit's tasks.
      * @return                   `void`
      */
   @HTTPPost
   global static void submitUserVisitsTask() {
 
     RestRequest req = RestContext.request;
     RestResponse res = RestContext.response;
     APIResponse objResponse = new APIResponse();
     InspectionPOSTRequest ehelper;
     String jsonStr;
 
     try {
         
         if (req.requestBody != null) {
             jsonStr = req.requestBody.toString();
         }
         ehelper = (InspectionPOSTRequest) System.JSON.deserialize(jsonStr, InspectionPOSTRequest.class);
        
         if(ehelper != null) {
             // Check if the user is requesting for it's own records
             if (String.isNotBlank(ehelper.userId) && ehelper.userId != UserInfo.getUserId()) {
                 throw new UnAuthorizedUserException();
             }
 
             // Check if Visits and Tasks are available 
             if (ehelper.visits != null && ehelper.visits.size() > 0) {
                 
                 Set<String> visitIds = new Set<String>();
                 Set<String> assesmentTaskIds = new Set<String>();
                 Set<String> inspectionAssessmentIndDefinitionId = new Set<String>();
                 Set<String> inspectionAssessmentIndDefinitionIdPicklist = new Set<String>();
                 Map<Id, Visit> visitsMap = new Map<Id, Visit>();
                 Map<Id, cls_tasks> assesmentTaskIdMap = new Map<Id, cls_tasks>();
                 Map<Id, cls_rows> inspectionAssessmentIndIdMap = new Map<Id, cls_rows>();
                 Map<Id, AssessmentIndValue> assessmentIndValueMap = new Map<Id, AssessmentIndValue>();
                 Map<Id, InspectionAssessmentInd> inspectionAssessmentIndMap = new Map<Id, InspectionAssessmentInd>();
                 List<AssessmentIndValue> listAssessmentIndValue = new List<AssessmentIndValue>();
 
                 // Below code will get all the visits and their status
                 for (cls_visits visit : ehelper.visits) {
                     visitIds.add(visit.visitId);
                 }
                 List<Visit> allVisits = [SELECT Id, Status__c FROM Visit WHERE Id IN :visitIds];
                 for (Visit objVisit : allVisits) {
                     visitsMap.put(objVisit.Id, objVisit);
                 }
 
                 // Get Task ID's, InspectionAssessmentInd Id's, and setup map for Task and InspectionAssessmentInd
                 for (cls_visits visit : ehelper.visits) {
 
                     Visit apiVisit = visitsMap.get(visit.visitId);
                     // If Visit Is Planned or InProgress then only update this Visit.
                     if (apiVisit != null && (apiVisit.Status__c == 'Planned' || apiVisit.Status__c == 'InProgress')) {
                         for (cls_tasks objTask : visit.tasks) {
                             if (objTask.id != null) {
                                 assesmentTaskIds.add(objTask.id);
                                 assesmentTaskIdMap.put(objTask.id, objTask);
                             }
                             if (objTask.rows != null && objTask.rows.size() > 0) {
                                 for (cls_rows objRow : objTask.rows) {
                                     if (objRow.id != null) {
                                         // If Type is Picklist or Multi-Select Picklist then have to set "value" to AssessmentIndValue otherwise InspectionAssessmentInd
                                         if (objRow.type == 'Picklist' || objRow.type == 'Multi-Select Picklist') {
                                             inspectionAssessmentIndDefinitionIdPicklist.add(objRow.id);
                                         } 
                                         inspectionAssessmentIndDefinitionId.add(objRow.id);
                                         inspectionAssessmentIndIdMap.put(objRow.id, objRow);
                                     }
                                 }
                             }
                         }   
                     }
                 }
                 
                 // Fetch All AssessmentTask, InspectionAssessmentInd, AssessmentIndValue
                 List<AssessmentTask> allTasks = [SELECT Id, Status FROM AssessmentTask WHERE Id IN :assesmentTaskIds];
                 List<InspectionAssessmentInd> allAssessmentInd = [SELECT Id, DateTimeFieldResponse, DecimalFieldResponse, NumberFieldResponse, PercentageFieldResponse,  AssessmentIndDefinition.DataType,AssessmentIndDefinition.Does_Not_Account_For_Violation__c, TextFieldResponse, Text_Area_Field_Response__c, Result FROM InspectionAssessmentInd WHERE Id IN :inspectionAssessmentIndDefinitionId];
                 List<AssessmentIndValue> allAssessmentIndValue = [SELECT Id, AssessmentIndDefinedValue.Value, SourceObjectId FROM AssessmentIndValue WHERE SourceObjectId IN :inspectionAssessmentIndDefinitionIdPicklist];
 
                 // InspectionAssessmentInd Map
                 for (InspectionAssessmentInd objInspectionAssessmentInd : allAssessmentInd) {
                     inspectionAssessmentIndMap.put(objInspectionAssessmentInd.Id, objInspectionAssessmentInd);
                 }
 
                 // AssessmentIndValue Map
                 for (AssessmentIndValue objAssessmentIndValue : allAssessmentIndValue) {
                     assessmentIndValueMap.put(objAssessmentIndValue.SourceObjectId, objAssessmentIndValue);
                 }
 
                 // Update Task
                 for (AssessmentTask assessmentTask : allTasks) {
                     cls_tasks objTask = assesmentTaskIdMap.get(assessmentTask.Id);
                     assessmentTask.Status = objTask.status;
                 }
 
                 // Start a loop on each Row Item from Request 
                 // and Update Result 
                 // if Type is Picklist then Update AssessmentIndValue else InspectionAssessmentInd
                 for (Id key : inspectionAssessmentIndIdMap.keySet()) {
                     cls_rows objRow = inspectionAssessmentIndIdMap.get(key);
                     InspectionAssessmentInd assessmentInd = inspectionAssessmentIndMap.get(objRow.id);
                     if (assessmentInd != null) {
                         assessmentInd.Result = objRow.assessmentResult;  
                         if (objRow.comments  != null) {
                             assessmentInd.Comments__c =  objRow.comments;
                             }
    
                         if (objRow.value != null && String.isNotEmpty(objRow.value)) {
                             // If Type is Picklist or Multi-Select Picklist then have to set "value" to AssessmentIndValue otherwise InspectionAssessmentInd
                             if (objRow.type == 'Picklist' ) {
                                 AssessmentIndValue objAssessmentIndV = assessmentIndValueMap.get(assessmentInd.Id);
                                 if (objAssessmentIndV != null) {
                                     objAssessmentIndV.AssessmentIndDefinedValueId = objRow.optionId;
                                     listAssessmentIndValue.add(objAssessmentIndV);
                                 } else {
                                     // Add New AssessmentIndValue Object
                                     AssessmentIndValue newObj = new AssessmentIndValue();
                                     newObj.AssessmentIndDefinedValueId = objRow.optionId;
                                     newObj.SourceObjectId = objRow.id;
                                     listAssessmentIndValue.add(newObj);
                                 }
                             }else if (objRow.type == 'Multi-Select Picklist' && String.isNotEmpty(objRow.optionId)) {
                                    
                                    List<String> optionIdList =  objRow.optionId.split(',');
                                    for (String optionId : optionIdList) {
                                        // Add New AssessmentIndValue Object
                                        AssessmentIndValue newObj = new AssessmentIndValue();
                                        newObj.AssessmentIndDefinedValueId = optionId;
                                        newObj.SourceObjectId = objRow.id;
                                        listAssessmentIndValue.add(newObj);
                                    }
                                    
                                
                            } else {     
                                 if(objRow.type == 'TextArea'){
                                     assessmentInd.Text_Area_Field_Response__c = objRow.value;
                                     assessmentInd.TextFieldResponse = String.isNotBlank(objRow.value) ? objRow.value.length() < 256 ? objRow.value : objRow.value.subString(0,255) : null;
                                 }else{
                                     setInspectionAssessmentInd(assessmentInd, objRow.value);
                                 }
                             }
                         }
                     } 
                 }
                 
                 // Update AssessmentTask, InspectionAssessmentInd, AssessmentIndValue
                 List<Database.SaveResult> allResults = new List<Database.SaveResult>();
                 List<Database.UpsertResult> indicatorResult = Database.upsert(listAssessmentIndValue);
                 List<Database.SaveResult> assessmentResult = Database.update(allAssessmentInd);
                 List<Database.SaveResult> taskResults = Database.update(allTasks);
 
                 allResults.addAll(assessmentResult);
                 allResults.addAll(taskResults);
                 
                 objResponse = new APIResponse(allResults, indicatorResult);
                 res.responseBody = Blob.valueOf(JSON.serialize(objResponse));
                 res.statusCode = 200;
                 return;
             } 
         }
 
         objResponse.error = 'No Visits or Tasks found';
         objResponse.status = 'Fail';
         res.responseBody = Blob.valueOf(JSON.serialize(objResponse));
         res.statusCode = 400;
 
     } catch (UnAuthorizedUserException e){
         res.statusCode = 500;
         res.responseBody = Blob.valueOf('User not authorized to submit other users visit');
     } catch (Exception ex) {
         res.statusCode = 400;
         res.responseBody = Blob.valueOf('Error with the request parameters' + ex.getMessage());
     }
   }
 
     /**
      * @author                   Anmol Mathur
      * @description              This is the GET Method of the class which will return all Visit's Tasks associated with the userId passed in the parameter
      * @return                   `void`
      */
 
     @HttpGet
     global static void getInspectionTasksForUser() {
         RestRequest req = RestContext.request;
         RestResponse res = RestContext.response;
         
         try {
 
             String userId = RestContext.request.params.get('userId');
 
             // Check if the user is requesting for it's own records
             if (String.isNotBlank(userId) && userId != UserInfo.getUserId()) {
              // throw new UnAuthorizedUserException();
             }

             Integer page;
             if (String.isNotBlank(RestContext.request.params.get('page'))) {
                //throw new UnAuthorizedUserException();
                page = Integer.valueOf(RestContext.request.params.get('page'));
             }

             Set<Id> visitIDs = new Set<Id>();
            if (req.params.containsKey('visitIds')) {
               String previousVisitIds = req.params.get('visitIds');  
               if(String.isNotBlank(previousVisitIds)){

                  List<String> idsPrevious = previousVisitIds.split(',');
                  for(String idPrevious : idsPrevious){
                     visitIDs.add(idPrevious);
                  }

               }             
           }else{
               visitIDs =  page == null ? LPI_VisitControllerDAO.getAllVisitIDs(userId):getVisitIDByPage(userId,page);
            
           }

 
             Set<Id> assesmentTaskIds = new Set<Id>();
             Set<Id> assessmentIndDefinitionId = new Set<Id>();
             Map<Id, Id> taskAssesmentTaskDefinitionIdMap = new Map<Id, Id>();
             Map<Id, Id> taskAssesmentTaskIndicatorsIdMap = new Map<Id, Id>();
             List<Map<String,Object>> assesmentTaskFinalResponse = new List<Map<String,Object>>();
             Map<Id, List<Map<String,Object>>> taskPicklists = new Map<Id, List<Map<String,Object>>>();
             Map<Id, List<Map<String,Object>>> taskRegulatories = new Map<Id, List<Map<String,Object>>>();
             Map<Id, Map<String,Object>> taskQuestionDefinitions = new Map<Id, Map<String,Object>>();
             
 
             // getting tasks
             if(visitIDs != null) {
                     List<AssessmentTask> assesmentTasks = req.params.containsKey('sequence')?getTasksWithSequence(visitIDs,Integer.valueOf(req.params.get('sequence'))):getAllTasks(visitIDs);
                  
 
                     if(assesmentTasks != null) {
                         for (AssessmentTask task : assesmentTasks) {
                             assesmentTaskIds.add(task.Id);
                         }
                         
                         
                         // getting task definition - AssessmentTaskDefinition
                         List<InspectionAssessmentInd> inspectionAssessmentIds = getAllInspectionAssessmentInd(assesmentTaskIds);
                         // getting Assessment Ind Value
                         Map<Id, AssessmentIndValue> mapAssessmentIndValue = getAllAssessmentIndValue(assesmentTaskIds);
                        
                         if(inspectionAssessmentIds != null) {
                             taskQuestionDefinitions = getTaskQuestionWrapper(inspectionAssessmentIds, mapAssessmentIndValue);
                             for (InspectionAssessmentInd inspectionAssessmentId : inspectionAssessmentIds) {
                                 if (inspectionAssessmentId.AssessmentIndDefinitionId != null) {
                                     assessmentIndDefinitionId.add(inspectionAssessmentId.AssessmentIndDefinitionId);
                                     // Verify this
                                     taskAssesmentTaskIndicatorsIdMap.put(inspectionAssessmentId.id, inspectionAssessmentId.AssessmentTaskId);
                                     taskAssesmentTaskDefinitionIdMap.put(inspectionAssessmentId.id, inspectionAssessmentId.AssessmentIndDefinitionId);    
                                 }
                             }
 
                             List<AssessmentIndDefinedValue> assesmentTaskIndPicklistValues = [SELECT AssessmentIndicatorDefinitionId,Id,IsDeleted,Name,Value,SequenceNumber FROM AssessmentIndDefinedValue WHERE AssessmentIndicatorDefinitionId IN : assessmentIndDefinitionId ORDER BY SequenceNumber];
                             if(assesmentTaskIndPicklistValues != null) {
                                 taskPicklists = getPicklistValueWrapper(assesmentTaskIndPicklistValues);
                             }
                             List<RegulatoryCodeAssessmentInd> regulatoryCodeAssessmentInds = [SELECT ID,AssessmentIndDefinitionId, Name, RegulatoryCode.Name, RegulatoryCode.Subject, RegulatoryCode.EffectiveFrom, RegulatoryCode.EffectiveTo, RegulatoryCode.IsActive, RegulatoryCode.Description FROM  RegulatoryCodeAssessmentInd WHERE AssessmentIndDefinitionId IN : assessmentIndDefinitionId];
                             if(regulatoryCodeAssessmentInds != null) {
                                 taskRegulatories = getRegulatoryCodesWrapper(regulatoryCodeAssessmentInds);
                             }
                         }
 
                         Map<String,List<Object>> tempVisitTaskRow = new Map<String,List<Object>>();
                         List<Map<String,String>> dummyOptions = new List<Map<String,String>>();
                         Map<String,String> yesObject = new Map<String,String>();
                         yesObject.put('value', 'Yes');
                         yesObject.put('label', 'Yes');
                         yesObject.put('optionId', 'Yes');
                         dummyOptions.add(yesObject);
 
                         Map<String,String> noObject = new Map<String,String>();
                         noObject.put('value', 'No');
                         noObject.put('label', 'No');
                         noObject.put('optionId', 'No');
                         dummyOptions.add(noObject);
 
                         for (AssessmentTask task : assesmentTasks) {
                             Map<String,Object> tempTaskRow = new Map<String,Object>();
                             tempTaskRow.put('id', task.Id);
                             tempTaskRow.put('title', task.Name);
                             tempTaskRow.put('status', task.Status);
                             tempTaskRow.put('order', task.SequenceNumber);
                             tempTaskRow.put('form',task.AssessmentTaskDefinition.Description);
                             List<Object> rows = new List<Object>();
                             Set<Id> keys = taskAssesmentTaskIndicatorsIdMap.keySet();
                             for (Id key : keys) {
                                  if(taskAssesmentTaskIndicatorsIdMap.get(key) == task.id) {
                                      Map<String,Object> tempQuestion = new Map<String,Object>();
                                      tempQuestion.putAll(taskQuestionDefinitions.get(key));
                                      if(taskRegulatories.get(taskAssesmentTaskDefinitionIdMap.get(key)) !=null){
                                          tempQuestion.put('regulatoryCodes', taskRegulatories.get(taskAssesmentTaskDefinitionIdMap.get(key)));
                                      }else{
                                          tempQuestion.put('regulatoryCodes',new List<Map<String,Object>>());
                                      }
                                     
                                      if(taskPicklists.get(taskAssesmentTaskDefinitionIdMap.get(key)) != null){
                                          tempQuestion.put('options', taskPicklists.get(taskAssesmentTaskDefinitionIdMap.get(key)));
                                      }else{
                                          tempQuestion.put('options',dummyOptions);
                                      }
                                     
                                      rows.add(tempQuestion);
                                  }
                             }
                             tempTaskRow.put('rows', rows);
                             if(tempVisitTaskRow.get(task.ParentId) != null) {
                                 List<Object> tempList = tempVisitTaskRow.get(task.ParentId);
                                 tempList.add(tempTaskRow);
                                 tempVisitTaskRow.put(task.ParentId, tempList);
                             } else {
                                 List<Object> tempList = new List<Object>();
                                 tempList.add(tempTaskRow);
                                 tempVisitTaskRow.put(task.ParentId, tempList);
                             }
                         }
                         for(Id key: tempVisitTaskRow.keySet()) {
                             Map<String,Object> tempVisitTask = new Map<String,Object>();
                             tempVisitTask.put('visitId', key);
                             tempVisitTask.put('tasks', tempVisitTaskRow.get(key));
                             assesmentTaskFinalResponse.add(tempVisitTask);
                         }
                     }
                 }
 
             res.statusCode = 200;
             if (page == null) {              
                res.responseBody = Blob.valueOf(JSON.serialize(assesmentTaskFinalResponse));               
            } else {                
                 Map<String,Object> response= new Map<String,Object> ();               
                 response.put('data',assesmentTaskFinalResponse);                
                 response.put('hasNextRecords', visitIds.size() >= 10 ? 'true':'false');                
                 res.responseBody = Blob.valueOf(JSON.serialize(response));               
                }
             
 
         } catch (System.StringException e){
             RestContext.response.statusCode = 400;
             RestContext.response.responseBody = Blob.valueOf('Param: userId is not a valid Id');
         } catch (System.QueryException e){
             RestContext.response.statusCode = 404;
             RestContext.response.responseBody = Blob.valueOf('Requested User not found');
         }catch (UnAuthorizedUserException e){ 
            RestContext.response.statusCode = 400;
            RestContext.response.responseBody = Blob.valueOf('User not authorized to fetch other users visit');
         }
         catch (Exception e){ //something else happened
             RestContext.response.statusCode = 500;
             RestContext.response.responseBody = Blob.valueOf(e.getMessage());
         }
     }
   
     /**
      * @author                   Anmol Mathur
      * @description              This method will return a List of AssessmentTask which are associated with the visitIds
      * @param :                  Set<Id> visitIds
      * @return                   `List<AssessmentTask>`
      */
     private static List<AssessmentTask> getAllTasks(Set<Id> visitIds) {     
         return  
         [
             SELECT AssessmentTaskDefinitionId,AssessmentTaskDefinition.Description,Description,EndTime,Id,IsDeleted,IsRequired,Name,OwnerId,ParentId,SequenceNumber,StartTime,Status,TaskDefinitionId,TaskType 
             FROM AssessmentTask 
             WHERE ParentId IN :visitIds 
             ORDER BY CreatedDate
         ];
     }

     /**
     * @author                   Anmol Mathur
     * @description              This method will return a List of AssessmentTask which are associated with the visitIds
     * @param :                  Set<Id> visitIds
     * @return                   `List<AssessmentTask>`
     */
    private static List<AssessmentTask> getTasksWithSequence(Set<Id> visitIds,Integer squenceNumber) {     
        return  
        [
            SELECT AssessmentTaskDefinitionId,AssessmentTaskDefinition.Description,Description,EndTime,Id,IsDeleted,IsRequired,Name,OwnerId,ParentId,SequenceNumber,StartTime,Status,TaskDefinitionId,TaskType 
            FROM AssessmentTask 
            WHERE ParentId IN :visitIds 
            AND SequenceNumber = :squenceNumber
            ORDER BY CreatedDate
        ];
    }
 
      /**
      * @author                   Anmol Mathur
      * @description              This method will return a List of InspectionAssessmentInd which are associated with the assessmentTask Id's
      * @param :                  Set<Id> assessmentTaskIds
      * @return                   `List<InspectionAssessmentInd>`
      */
     private static List<InspectionAssessmentInd> getAllInspectionAssessmentInd(Set<Id> assessmentTaskIds) {     
         return  
         [
             SELECT Id,AssessmentIndDefinition.Hide_Comments__c, DateTimeFieldResponse, DecimalFieldResponse, DisplayOrder, IsDeleted, NumberFieldResponse, PercentageFieldResponse, AssessmentIndDefinitionId,AssessmentIndDefinition.Does_Not_Account_For_Violation__c,  AssessmentIndDefinition.DataType, AssessmentIndDefinition.Name, AssessmentIndDefinition.Question_Text__c, Comments__c, TextFieldResponse, AssessmentTaskId, Result, AssessmentTask.IsRequired, AssessmentIndDefinition.Convert_To_Text_Area__c, Text_Area_Field_Response__c
             FROM InspectionAssessmentInd 
             WHERE AssessmentTaskId IN :assessmentTaskIds AND IsDeleted = false 
             ORDER BY DisplayOrder
         ];
     }
 
     /**
      * @author                   Anmol Mathur
      * @description              This method will return a Map of AssessmentIndValue with the SourceObjectId
      * @param :                  Set<Id> assessmentTaskIds
      * @return                   `Map<Id, AssessmentIndValue>`
      */
     private static Map<Id, AssessmentIndValue> getAllAssessmentIndValue(Set<Id> assessmentTaskIds) {   
         Map<Id, AssessmentIndValue> mapAssessmentIndValue = new Map<Id, AssessmentIndValue>();
         List<AssessmentIndValue> assessmentIndValues = 
         [
             Select Id, AssessmentIndDefinedValue.Value, SourceObjectId
             FROM AssessmentIndValue 
             WHERE SourceObjectId 
             IN :[Select Id from InspectionAssessmentInd WHERE AssessmentTaskId IN :assessmentTaskIds]
         ];
         for (AssessmentIndValue obj : assessmentIndValues) {
             if (obj.SourceObjectId != null) {
                 mapAssessmentIndValue.put(obj.SourceObjectId, obj);    
             }
         }
         return mapAssessmentIndValue;
     }
 
     /**
      * @author                   Anmol Mathur
      * @description              This method will return a List of Object which are Picklist value of Result Field
      * @return                   `List<Object>`
      */
     private static List<Object> getResultPicklistValues() {
         List<Schema.PicklistEntry> values = InspectionAssessmentInd.Result.getDescribe().getPickListValues();
         List<Object> assessmentOptionsList = new List<Object>();
         for (Schema.PicklistEntry value : values) {
             if (value.isActive()) {
                 Map<String,Object> assessmentOptionsMap = new Map<String,Object>();
                 assessmentOptionsMap.put('label', value.label);
                 assessmentOptionsMap.put('value', value.value);
                 assessmentOptionsMap.put('optionId', value.value);
                 assessmentOptionsMap.put('violation', value.value == 'Fail' ? true: false);
                 assessmentOptionsList.add(assessmentOptionsMap);
             }
         }
         return assessmentOptionsList;
     }
 
     /**
      * @author                   Anmol Mathur
      * @description              This method will return the value of each question
      * @param :                  InspectionAssessmentInd taskDefinition
      * @param :                  Map<Id, AssessmentIndValue> indValues
      * @return                   `String`
      */
     private static String getAssessmentIndValue(InspectionAssessmentInd taskDefinition, Map<Id, AssessmentIndValue> indValues) {
         String value = '';
         switch on taskDefinition.AssessmentIndDefinition.DataType {
             when 'Number' {
                 value = String.valueOf(taskDefinition.NumberFieldResponse);
             }
             when 'Boolean' {
                 value = '';
             }
             when 'Percentage' {
                 value = String.valueOf(taskDefinition.PercentageFieldResponse);
             }
             when 'DateTime' {
                 value = String.valueOf(taskDefinition.DateTimeFieldResponse);
             }
             when 'Text', 'String' {
                 value = String.valueOf(taskDefinition.TextFieldResponse);
             }
             when 'Decimal' {
                 value = String.valueOf(taskDefinition.DecimalFieldResponse);
             }
             when 'Picklist', 'Multi-Select Picklist' {
                 AssessmentIndValue picklistValue = indValues.get(taskDefinition.Id);
                 if (picklistValue != null) {
                     value = picklistValue.AssessmentIndDefinedValue.Value;    
                 }
             }
             when else {
 
                 if(taskDefinition.AssessmentIndDefinition.Convert_To_Text_Area__c == true){
                     value = String.valueOf(taskDefinition.Text_Area_Field_Response__c);
                 }else{
                     value = '';
                 }
                 
                    
                 }
                 
             
         }
         return value;
     }
 
     /**
      * @author                   Anmol Mathur
      * @description              This method will set the value of each question
      * @param :                  InspectionAssessmentInd taskDefinition
      * @param :                  value String
      * @return                   void
      */
     private static void setInspectionAssessmentInd(InspectionAssessmentInd taskDefinition, String value) {
         switch on taskDefinition.AssessmentIndDefinition.DataType {
             when 'Number' {
                 taskDefinition.NumberFieldResponse = Integer.valueOf(value);
             }
             when 'Percentage' {
                 taskDefinition.PercentageFieldResponse = Decimal.valueOf(value);
             }
             when 'DateTime' {
                 taskDefinition.DateTimeFieldResponse = Datetime.valueOf(value.replace('T',' '));
             }
             when 'Text', 'String' {
                 taskDefinition.TextFieldResponse = value;
             }
             when 'Decimal' {
                 taskDefinition.DecimalFieldResponse = Decimal.valueOf(value);
             }
             when else {
             }
         }
     }
 
 
     static Map<Id, Map<String,Object>> getTaskQuestionWrapper(InspectionAssessmentInd[] inspectionAssessmentInds, Map<Id, AssessmentIndValue> indValues) {
        
        //Grouped based on Assessment Task Id AssessmentTaskId
        
         Map<Id, Map<String,Object>> taskDefinitionMap = new Map<Id, Map<String,Object>> ();
         List<Object> assessmentOptionsList = getResultPicklistValues();
     
         for (InspectionAssessmentInd taskDefinition : inspectionAssessmentInds) {
             Map<String,Object> taskDefinitionTemp = new Map<String,Object>();
             String currentValue = getAssessmentIndValue(taskDefinition, indValues);
             taskDefinitionTemp.put('id', taskDefinition.id);
             taskDefinitionTemp.put('assessmentIndDefinitionId', taskDefinition.AssessmentIndDefinition.Id);
             taskDefinitionTemp.put('type',taskDefinition.AssessmentIndDefinition.Convert_To_Text_Area__c == true? 'TextArea': taskDefinition.AssessmentIndDefinition.DataType);
             taskDefinitionTemp.put('title', taskDefinition.AssessmentIndDefinition.Question_Text__c);
             taskDefinitionTemp.put('placeholder', taskDefinition.AssessmentIndDefinition.Question_Text__c);
             taskDefinitionTemp.put('isEditable', true);
             //taskDefinitionTemp.put('isMandatory', taskDefinition.AssessmentTask.IsRequired);
             taskDefinitionTemp.put('isMandatory', true);
             taskDefinitionTemp.put('order', taskDefinition.DisplayOrder);
             taskDefinitionTemp.put('value', currentValue);
             taskDefinitionTemp.put('isMultiSelect', taskDefinition.AssessmentIndDefinition.DataType == 'Multi-Select Picklist');
             taskDefinitionTemp.put('assessmentTitle', 'Assessment Result');
             taskDefinitionTemp.put('assessmentResult', taskDefinition.Result);
             taskDefinitionTemp.put('assessmentOptions', assessmentOptionsList);
             taskDefinitionTemp.put('comments', taskDefinition.Comments__c);
             taskDefinitionTemp.put('avoidViolation',taskDefinition.AssessmentIndDefinition.Does_Not_Account_For_Violation__c);
             taskDefinitionTemp.put('hideComments',taskDefinition.AssessmentIndDefinition.Hide_Comments__c);
             taskDefinitionMap.put(taskDefinition.id, taskDefinitionTemp);

 
            }
         return taskDefinitionMap;
     }
 
     static Map<Id, List<Map<String,Object>>> getPicklistValueWrapper(AssessmentIndDefinedValue[] picklistValues) {
         Map<Id, List<Map<String,Object>>> picklistValuesMap = new Map<Id, List<Map<String,Object>>> ();
         for (AssessmentIndDefinedValue picklistValue : picklistValues) {
             Map<String,Object> picklistValueLabelMap = new Map<String,Object>();
             //Added as a part of story S-54526
             String result = 'NA';
             if (picklistValue.Value.equalsIgnoreCase('yes') || picklistValue.Value.equalsIgnoreCase('no violation')) {
                 result = 'Pass';
             }else if (picklistValue.Value.equalsIgnoreCase('no') || picklistValue.Value.equalsIgnoreCase('violation')) {
                 result = 'Fail';
             }else{
                 result = 'NA';
             }
             picklistValueLabelMap.put('label', picklistValue.Value);
             picklistValueLabelMap.put('value', picklistValue.Value);
             picklistValueLabelMap.put('optionId', picklistValue.Id);
             picklistValueLabelMap.put('result', result);
             if(picklistValuesMap.get(picklistValue.AssessmentIndicatorDefinitionId) != null) {
                 List<Map<String,Object>> tempList = picklistValuesMap.get(picklistValue.AssessmentIndicatorDefinitionId);
                 tempList.add(picklistValueLabelMap);
                 picklistValuesMap.put(picklistValue.AssessmentIndicatorDefinitionId, tempList);
             } else {
                 List<Map<String,Object>> tempList = new List<Map<String,Object>>();
                 tempList.add(picklistValueLabelMap);
                 picklistValuesMap.put(picklistValue.AssessmentIndicatorDefinitionId, tempList);
             }
         }
         return picklistValuesMap;
     }
 
     static Map<Id, List<Map<String,Object>>> getRegulatoryCodesWrapper(RegulatoryCodeAssessmentInd[] regulatoryCodes) {
         Map<Id, List<Map<String,Object>>> regulatoryCodesMap = new Map<Id, List<Map<String,Object>>> ();
         for (RegulatoryCodeAssessmentInd regulatoryCode : regulatoryCodes) {
             Map<String,Object> picklistValueLabelMap = new Map<String,Object>();
             picklistValueLabelMap.put('id', regulatoryCode.RegulatoryCode.Id);
             picklistValueLabelMap.put('name', regulatoryCode.RegulatoryCode.Name);
             picklistValueLabelMap.put('subject', regulatoryCode.RegulatoryCode.Subject);
             picklistValueLabelMap.put('isActive', regulatoryCode.RegulatoryCode.IsActive);
             picklistValueLabelMap.put('effectiveFrom', regulatoryCode.RegulatoryCode.EffectiveFrom);
             picklistValueLabelMap.put('effectiveTo', regulatoryCode.RegulatoryCode.EffectiveTo);
             if(regulatoryCodesMap.get(regulatoryCode.AssessmentIndDefinitionId) != null) {
                 List<Map<String,Object>> tempList = regulatoryCodesMap.get(regulatoryCode.AssessmentIndDefinitionId);
                 tempList.add(picklistValueLabelMap);
                 regulatoryCodesMap.put(regulatoryCode.AssessmentIndDefinitionId, tempList);
             } else {
                 List<Map<String,Object>> tempList = new List<Map<String,Object>>();
                 tempList.add(picklistValueLabelMap);
                 regulatoryCodesMap.put(regulatoryCode.AssessmentIndDefinitionId, tempList);
             }
         }
         return regulatoryCodesMap;
     }


     /**
     * @author                   Lokendra Jhala
     * @description              This method will return Set<Id> of Visit Ids which are associated with the UserId based on page
     * @param :                  String userId
     * @param :                  Integer page
     * @return                   `Set<Id>`
     */
	public static Set<Id> getVisitIDByPage(String userId, Integer page) {  
           
		Set<Id> visitIDs = new Set<Id>();
        Integer recordLimit = 10;
        Integer offsetRecord = (recordLimit * page);
        Visit[] currentVisits = [
            SELECT Id, ContextId
            FROM Visit WHERE visitorId = :userId
            AND Status__c IN ('Planned', 'InProgress') LIMIT :recordLimit OFFSET :offsetRecord ];//AND ContextId != null];
		if (currentVisits.isEmpty()) {
			return new Set<Id>();
		}
		// Get all contextIDs
		Set<Id> contextIDs = new Set<Id>();
		for (Visit visit : currentVisits) {
			visitIDs.add(visit.Id);
			if(visit.ContextId != null){
				contextIDs.add(visit.ContextId);
			}
			
		}

        Visit[] allVisitsOfContexts = new List<Visit>();
        // [
       //SELECT Id, ContextId
       //FROM Visit 
       //WHERE ContextId IN : contextIds AND Status IN ('Completed', 'Abandoned')];

		Integer maxRecords = integer.valueOf(Label.Mobile_Max_Previous_Visits);
		Map<Id, List<Visit>> previousVisitMap = new  Map<Id, List<Visit>>();

		for (Visit obj : allVisitsOfContexts) {
			if (previousVisitMap.containsKey(obj.ContextId)) {
				List<Visit> contextVisit = previousVisitMap.get(obj.ContextId);
				if (contextVisit.size() < maxRecords) {
					contextVisit.add(obj);
					visitIDs.add(obj.Id);
					previousVisitMap.put(obj.ContextId, contextVisit);
				} 
			} else {
				List<Visit> newListVisit = new List<Visit>();
				newListVisit.add(obj);
				visitIDs.add(obj.Id);
				previousVisitMap.put(obj.ContextId, newListVisit);
			}
		}
		
		return visitIDs;
	}
 
     // Exceptions
     public class UnAuthorizedUserException extends Exception {}
 
     // Wrapper Classes
     /**
         * @description : Wrapper Class for parsing POST Request
     */
     public class InspectionPOSTRequest {
     
         public String userId;
         public cls_visits[] visits;
     }
 
     public class cls_visits {
         public String visitId;	
         public cls_tasks[] tasks;
     }
 
     public class cls_tasks {
         public String id;	
         public String status;	
         public cls_rows[] rows;
     }
 
     public class cls_rows {
         public String assessmentResult;	
         public String id;	
         public String type;	
         public String value;	
         public String optionId;
         public String comments;
     }
 
     public class APIResponse {
         public String status;
         public String error;
 
         public APIResponse(List<Database.SaveResult> results, List<Database.UpsertResult> upsertResults) {
 
             this.status = 'Success';
             this.error = '';
             List<String> errorMessages = new List<String>();
 
             for (Database.SaveResult result : results) {
                 if (result.success == false) {
                     this.status = 'Failed';
                     for(Database.Error err : result.getErrors()) {
                         errorMessages.add(err.getStatusCode() + ': ' + err.getMessage());
                     }
                 }
             }
             for (Database.UpsertResult upsertResult : upsertResults) {
                 if (upsertResult.success == false) {
                     this.status = 'Failed';
                     for(Database.Error err : upsertResult.getErrors()) {
                         errorMessages.add(err.getStatusCode() + ': ' + err.getMessage());
                     }
                 }
             }
             
             if (errorMessages.size() > 0) {
                 this.error = String.join(errorMessages, ' ');    
             }
         }
 
         public APIResponse() {}
     }
 }