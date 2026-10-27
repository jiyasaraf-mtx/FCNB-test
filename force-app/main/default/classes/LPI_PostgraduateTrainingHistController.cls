/**
 * @author      : Ayush Yadav
 * @since       : February 10, 2023
 * @description : This Class handles the CUD operations of Postgraduation Training History records
 *  -------------------------------------------------------------------------------------------------------
 * Version      Date                    Author                  Details
 *    1         February 10, 2023     Ayush Yadav         Initial Developement
 * -------------------------------------------------------------------------------------------------------
 */
global with sharing class LPI_PostgraduateTrainingHistController implements Callable {

	/**
	 * @description    	: Implementation of callable interface 
	 * @author 		   	: Ayush Yadav 
	 * @since           : February 10, 2023
	 * @param 			: action
	 * @param 			: args
	 * @return 			: Object
	 **/
	global Object call(String action, Map<String, Object> args) {
		Map<String, Object> input = (Map<String, Object>) args.get('input');
		Map<String, Object> output = (Map<String, Object>) args.get('output');
		Map<String, Object> options = (Map<String, Object>) args.get('options');

		return invokeMethod(action, input, output, options);
	}

	/**
     * @author                      : Ayush Yadav
     * @since                       : February 10, 2023
     * @description                 : This method is used to internally call the `invokeMethod` method
     * @param action                : It contains method name which is called from OmniScript
     * @param args                  : It is Map<String, Object> which contanis `input`, `output` and `options`
     * @return                      : `Object`
     * @last modified by            : Ayush Dev
     * @last modified date          : 
     */
	private Boolean invokeMethod(
		String methodName,
		Map<String, Object> inputMap,
		Map<String, Object> outMap,
		Map<String, Object> options
	) {
		Boolean result = true;
		try {
			// check if methodName is equal to "savePostgraduateTrainingHistoryRecords"
			if (methodName.equals('savePostgraduateTrainingHistoryRecords')) {
				savePostgraduateTrainingHistoryRecords(inputMap, outMap);
			} else {
				result = false;
			}
		} catch (Exception e) {
			//Log exception
			LPI_ExceptionManager.logException('LPI_PostgraduateTrainingHistController', 'invokeMethod', e);
			result = false;
		}
		return result;
	}

	/**
     * @author                      : Ayush Yadav
     * @since                       : February 10, 2023
     * @description                 : This method create, updates and deleats Postgraduation Training History Record (PersonEducation object)
     * @param inputMap              : Input data passed from OmniScript
     * @param outMap                : Output data passed to OmniScript
     * @param options               : Optional Input passed from OmniScript
     * @return                      : `void`
     * @last modified by            : Ayush Dev
     * @last modified date          : 
     * @last modified details       : 
     */
	private static void savePostgraduateTrainingHistoryRecords(Map<String, Object> inputMap, Map<String, Object> outMap) {
		try {
			Integer personEducationListCount = (Integer)inputMap.get('personEducationListCount');
			String parId = (String) inputMap.get('parId');
			String type = (String) inputMap.get('type');
			String boardName = (String) inputMap.get('boardName');
			//Added for issue I-241721 -- Start
			Map<String, Object> postGraduationTrngStepInfo = (Map<String, Object>) inputMap.get('PostgraduateTrainingHistory');
			
			String haveYouReceivedPGTrainingInUSAndCA = (String) postGraduationTrngStepInfo.get('HaveYouReceivedPGTrainingInUSAndCA');
			String confirmationForSpeciality = (String) postGraduationTrngStepInfo.get('ConfirmationForSpeciality');
			if(String.isNotBlank(parId)){
				PreliminaryApplicationRef par = new PreliminaryApplicationRef(Id = parId);
				if(!String.isBlank(haveYouReceivedPGTrainingInUSAndCA)){
					par.Have_you_received_PG_training_in_US_CA__c = haveYouReceivedPGTrainingInUSAndCA;
				}
				if(!String.isBlank(confirmationForSpeciality)){
					par.Have_you_received_PG_training_in_US_CA__c = ConfirmationForSpeciality;
				}
				LPI_DML.doUpdate(par);
			}
			if(haveYouReceivedPGTrainingInUSAndCA == 'Yes' ||
			   (type == 'Renewal' && confirmationForSpeciality == 'No') || 
			   boardName == 'Marital & Family Therapists' ){
				//Added for issue I-241721 -- End
				List<Object> contactIdList = new List<Object>();
				// Get Contact Id from input map
				if (personEducationListCount > 1 ) {
					if (inputMap.get('contactIdList') instanceof List<Object>) {
						contactIdList = (List<Object>) inputMap.get('contactIdList');
					} else if (inputMap.get('contactIdList') instanceof String) {
						String contactIdString = (String)inputMap.get('contactIdList');
						if (!String.isBlank(contactIdString)) {
							contactIdList.add(contactIdString);
						}
					}
				} else {
					contactIdList.add( inputMap.get('contactIdOS')); //Updated for Issue I-241721
				}
				String contactId = (String) contactIdList[0];
				String peWhereClause;
				peWhereClause =
				'ContactId =\'' +
				String.escapeSingleQuotes(contactId) +
				'\' AND Education_Type__c = \'' +
				String.escapeSingleQuotes(LPI_LiteralConstant.POSTGRADUATION_TRAINING_EDUCATION_TYPE) +'\''+
				' AND Status != \'' + String.escapeSingleQuotes('Revoked') +'\'';
				
					
				Set<Id> previousRecordsIdSet = new Map<Id, PersonEducation>(
				LPI_PersonEducationDAO.getPersonEducationByDymanicQuery(
				'Id',
				peWhereClause,
				null,
				null,
				null
				)
				)
				.keySet();
				List<sObject> upsertList = new List<sObject>();
				List<PersonEducation> upserRemovedRecoreds = new List<PersonEducation>();
				
				Map<String , String> keyMapping = new Map<String , String>{
					'PostgraduationTrainingFacilityName'=>'Name',
					'PostgraduationTrainingType'=>'Type__c',
					'PostgraduationStreetAddress'=>'Street_Address__c',
					'PostgraduationState'=>'State__c',
					'PostgraduationCity'=>'City__c',
					'PostgraduationZipCode'=>'Zip_Code__c',
					'PostgraduationDepartment'=>'Department_Speciality__c',
					'PostgraduationTermStartDate'=>'StartDate',
					'PostgraduationTermCompletedDate'=>'GraduationDate',
					'PostgraduationProgramDirectorName'=>'Program_Director_Name__c',
					'PostgraduationAccreditedBy'=>'Accredited_By__c',
					'PostgraduationYear'=>'Year__c',
					'PostgraduationHours'=>'Total_Hours_in_Program__c',
					'PostgraduationSupervisionHours'=>'Hours_of_One_to_One_Supervision_Per_Week__c',
					'PostgraduationPercentageTime'=>'Time_Dedicated_to_the_Internship__c'
				};
				
				
				List<Object> personEducationInfo = new List<Object>();
				//If user has added more than 1 Reference from the OS
				if (personEducationListCount > 1) {
					personEducationInfo = (List<Object>) inputMap.get('personEducationList');
				} else if(haveYouReceivedPGTrainingInUSAndCA == 'Yes' || confirmationForSpeciality == 'No' || boardName == 'Marital & Family Therapists' ){ //Added for issue I-241721
					personEducationInfo.add(inputMap.get('personEducationList'));
				}
				//Iterate over all the person education given by user
				for (Object pe : personEducationInfo) {
					Map<String, Object> obj = (Map<String, Object>) pe;
					String objId = (String) obj.get('educationHistoryIdFormula'); //Updated for Issue I-241721
					SObject personEducationDetails = (PersonEducation) LPI_VlocityUtility.createSObject(obj, keyMapping, 'PersonEducation');
					personEducationDetails.put('ContactId', contactId);
					personEducationDetails.put('Id', objId);
					personEducationDetails.put('Education_Type__c',LPI_LiteralConstant.POSTGRADUATION_TRAINING_EDUCATION_TYPE);
					if(String.isNotBlank(String.valueOf(obj.get('PostgraduationSpecify')))){
						personEducationDetails.put('Specify__c', (String) obj.get('PostgraduationSpecify'));
					}
					if(String.isNotBlank(String.valueOf(obj.get('PostgraduationSpecifyReadOnly')))){
						personEducationDetails.put('Specify__c', (String) obj.get('PostgraduationSpecifyReadOnly'));
					}
					if(type == 'Renewal' && String.ValueOf(obj.get('PostgraduationParId')) != null && String.ValueOf(inputMap.get('parId')) != String.ValueOf(obj.get('PostgraduationParId'))){
						personEducationDetails.put('Preliminary_Application_Reference__c', (String) obj.get('PostgraduationParId'));
					}
					else if(String.isNotBlank(String.valueOf(inputMap.get('parId'))) && inputMap.containsKey('parId')){
						personEducationDetails.put('Preliminary_Application_Reference__c', (String) inputMap.get('parId'));
					}
					upsertList.add(personEducationDetails);
					if (previousRecordsIdSet.contains(objId)) {
						previousRecordsIdSet.remove(objId);
					}
				}
				if (!upsertList.isEmpty()) {
					LPI_DML.doUpsert(upsertList);
				}
				//Delete the records if someone has deleted them from the UI
				if (!previousRecordsIdSet.isEmpty()) {
					String whereclause;
					whereclause = 'Id IN ' + LPI_ServiceUtility.getStringValuesBySet(previousRecordsIdSet);
					
					if(confirmationForSpeciality == 'No'){
						whereclause += ' AND Preliminary_Application_Reference__c =\'' + String.escapeSingleQuotes(parId) +'\'';
					}
					
					LPI_WithoutSharingUtility.deleteSObject(LPI_PersonEducationDAO.getPersonEducationByDymanicQuery(
					'Id',
					whereclause,
					null,
					null,
					null
					)
					);
					if(confirmationForSpeciality == 'No'){
						List<PersonEducation> perEduRevokedList = new List<PersonEducation>();
						String query = 'Id IN ' + LPI_ServiceUtility.getStringValuesBySet(previousRecordsIdSet) +
						' AND Preliminary_Application_Reference__c != \'' + String.escapeSingleQuotes(parId) +'\''+
						' AND Status = \'' + String.escapeSingleQuotes('Inactive') +'\'';			
						for(PersonEducation perEdu : LPI_PersonEducationDAO.getPersonEducationByDymanicQuery(
						'Id, Status',
						query,
						null,
						null,
						null
						)){
							perEdu.Status = 'Revoked';
							perEduRevokedList.add(perEdu);
						}
						if(!perEduRevokedList.isEmpty()){
							LPI_DML.doUpsert(perEduRevokedList);
						}
					}
				}
			}
				
			if(confirmationForSpeciality == 'Yes'){
				String whereClause =
				'Preliminary_Application_Reference__c =\'' +
				String.escapeSingleQuotes(parId) +
				'\'';
				List<PersonEducation> recordsToDelete = LPI_PersonEducationDAO.getPersonEducationByDymanicQuery(
				'Id',
				whereClause,
				null,
				null,
				null
				);
				if (!recordsToDelete.isEmpty()) {
					//Deleting records
					LPI_WithoutSharingUtility.deleteSObject(recordsToDelete);
				}
			}		
		} catch (Exception e) {
			LPI_ExceptionManager.logException(
			'LPI_PostgraduateTrainingHistController',
			'savePostgraduateTrainingHistoryRecords',
			e
			);
			throw new AuraHandledException(e.getMessage());
		}
	}
}