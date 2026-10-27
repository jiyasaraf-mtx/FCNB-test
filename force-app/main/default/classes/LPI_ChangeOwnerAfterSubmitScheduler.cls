/**
 * @description       : 
 * @author            : Ayush Dev
 * @group             : 
 * @last modified on  : 07-08-2024
 * @last modified by  : Uzma Md
**/
public without sharing class  LPI_ChangeOwnerAfterSubmitScheduler {
    public class ChangeOwnerException extends Exception {}

	/**
	* @description This method is to remove onwer
	* @author Ayush Dev | 05-06-2024 
	* @param blaIdSet 
	**/
	@future
	public static void removeOwner(Set<Id> blaIdSet){
		try {
			Map<Id,Id> blaIdToAccountIdMap = new Map<Id,Id>();
			Map<Id,BusinessLicenseApplication> blaIdToBlaMap = new Map<Id,BusinessLicenseApplication>();
			for(BusinessLicenseApplication bla : [
				SELECT Id, AccountId, OwnerId, SavedApplicationRefId, SavedApplicationRef.OwnerId,  SavedApplicationRef.BusinessAccountNameId
				FROM BusinessLicenseApplication
				WHERE Id IN: blaIdSet
			]){
				blaIdToBlaMap.put(bla.Id, bla);
				blaIdToAccountIdMap.put(bla.Id, bla.AccountId);
			}

			if (!blaIdToBlaMap.isEmpty()) {

				List<Group> queueToAssignRecordList = [
					SELECT Id
					FROM Group
					WHERE Type = 'Queue' 
					AND DeveloperName = 'Empty_Queue'
				];
				Group queueToAssignRecord;
				if(queueToAssignRecordList.isEmpty()){
					throw new ChangeOwnerException('No queue found to assign change owner records');
				}else{
					queueToAssignRecord = queueToAssignRecordList[0];
					
					Map<Id,Set<Id>> businessIdToRelatedToId = new Map<Id,Set<Id>>();
					Set<Id> relatedToIdForUser = new Set<Id>();
					for(Business_Relationships__c br : [
						SELECT Id, Roles__c, Related_To__c, Related_From__c
						FROM Business_Relationships__c
						WHERE Related_From__c IN: blaIdToAccountIdMap.values() 
						AND ( 
							Roles__c = 'Temporary Clerk' OR Roles__c = 'License Service Provider' 
						)
						AND Related_To__c != NULL
					]){
						if(!businessIdToRelatedToId.containsKey(br.Related_From__c)){
							businessIdToRelatedToId.put(br.Related_From__c, new Set<Id>());
						}
						businessIdToRelatedToId.get(br.Related_From__c).add(br.Related_To__c);
						relatedToIdForUser.add(br.Related_To__c);
					}

					Map<Id,Id> relatedTotoUserIdMap = new Map<Id,Id>();

					for(User us: [
						SELECT Id, ProfileId, ContactId, AccountId
						FROM USER
						WHERE AccountId IN: relatedToIdForUser
					]){
						relatedTotoUserIdMap.put(us.AccountId, us.Id);
					}
					
					List<BusinessLicenseApplication> blaUpdateList = new List<BusinessLicenseApplication>();
					List<PreliminaryApplicationRef> parUpdateList = new List<PreliminaryApplicationRef>();

					Set<Id> parIdSet = new Set<Id>();
					Set<Id> accountOfPar = new Set<Id>();

					for(BusinessLicenseApplication bla : blaIdToBlaMap.values()){
						if(businessIdToRelatedToId.containsKey(bla.AccountId)){
							for(Id relatedToId : businessIdToRelatedToId.get(bla.AccountId)){
								if (bla.OwnerId == relatedTotoUserIdMap.get(relatedToId)) {
									bla.OwnerId = queueToAssignRecord.Id;
									blaUpdateList.add(bla);
								}
	
								if(bla.SavedApplicationRef.OwnerId == relatedTotoUserIdMap.get(relatedToId)){
									PreliminaryApplicationRef par = new PreliminaryApplicationRef();
									par.Id = bla.SavedApplicationRefId;
									par.OwnerId = queueToAssignRecord.Id;
									parUpdateList.add(par);
								}
								if(bla.SavedApplicationRef != NULL){
									parIdSet.add(bla.SavedApplicationRefId);
									accountOfPar.add(bla.SavedApplicationRef.BusinessAccountNameId);
								}
							}
						}
					}
					if(!blaUpdateList.isEmpty()){
						LPI_DML.doUpdate(blaUpdateList);
					}
					if(!parUpdateList.isEmpty()){
						LPI_DML.doUpdate(parUpdateList);
					}

					List<BoardCertification> certList = new List<BoardCertification>();
					for (BoardCertification cert : [
						SELECT Id, OwnerId
						FROM BoardCertification
						WHERE Preliminary_Application_Reference__c IN: parIdSet
						AND OwnerId IN: relatedTotoUserIdMap.values()
					]) {
						cert.OwnerId = queueToAssignRecord.Id;
						certList.add(cert);
					}
					if (!certList.isEmpty()) {
						LPI_DML.doUpdate(certList);
					}

					List<Application_Content__c> appcontentList = new List<Application_Content__c>();
					for (Application_Content__c appCont : [
						SELECT Id, OwnerId
						FROM Application_Content__c
						WHERE Business_License_Application__c IN: blaIdToBlaMap.keySet() 
						AND OwnerId IN: relatedTotoUserIdMap.values()
					]) {
						appCont.OwnerId = queueToAssignRecord.Id;
						appcontentList.add(appCont);
					}
					if (!appcontentList.isEmpty()) {
						LPI_DML.doUpdate(appcontentList);
					}

					List<Application_Document__c> appdocList = new List<Application_Document__c>();
					for (Application_Document__c appDoc : [
						SELECT Id, OwnerId
						FROM Application_Document__c
						WHERE Business_License_Application__c IN: blaIdToBlaMap.keySet() 
						AND OwnerId IN: relatedTotoUserIdMap.values()
					]) {
						appDoc.OwnerId = queueToAssignRecord.Id;
						appdocList.add(appDoc);
					}
					if (!appdocList.isEmpty()) {
						LPI_DML.doUpdate(appdocList);
					}

					List<RegulatoryTrxnFee> feeList = new List<RegulatoryTrxnFee>();
					for (RegulatoryTrxnFee fee : [
						SELECT Id, OwnerId
						FROM RegulatoryTrxnFee
						WHERE (ParentRecordId IN: blaIdToBlaMap.keySet() OR ParentRecordId IN: parIdSet)
						AND OwnerId IN: relatedTotoUserIdMap.values()
					]) {
						fee.OwnerId = queueToAssignRecord.Id;
						feeList.add(fee);
					}
					if (!feeList.isEmpty()) {
						LPI_DML.doUpdate(feeList);
					}

					List<Temp_Fee__c> tempFeeList = new List<Temp_Fee__c>();
					for (Temp_Fee__c tempFee : [
						SELECT Id, OwnerId
						FROM Temp_Fee__c
						WHERE PreliminaryApplicationReference__c IN: parIdSet
						AND OwnerId IN: relatedTotoUserIdMap.values()
					]) {
						tempFee.OwnerId = queueToAssignRecord.Id;
						tempFeeList.add(tempFee);
					}
					if (!tempFeeList.isEmpty()) {
						LPI_DML.doUpdate(tempFeeList);
					}

					List<Temp_AuthApplicationPlace__c> tempAuthList = new List<Temp_AuthApplicationPlace__c>();
					for (Temp_AuthApplicationPlace__c tempAuth : [
						SELECT Id, OwnerId
						FROM Temp_AuthApplicationPlace__c
						WHERE Preliminary_Application_Reference__c IN: parIdSet 
						AND OwnerId IN: relatedTotoUserIdMap.values()
					]) {
						tempAuth.OwnerId = queueToAssignRecord.Id;
						tempAuthList.add(tempAuth);
					}
					if (!tempAuthList.isEmpty()) {
						LPI_DML.doUpdate(tempAuthList);
					}

					List<Bank_Account__c> bankAccountList = new List<Bank_Account__c>();
					for (Bank_Account__c bankAccount : [
						SELECT Id, OwnerId
						FROM Bank_Account__c
						WHERE Preliminary_Application_Reference__c IN: parIdSet 
						AND OwnerId IN: relatedTotoUserIdMap.values()
					]) {
						bankAccount.OwnerId = queueToAssignRecord.Id;
						bankAccountList.add(bankAccount);
					}
					if (!bankAccountList.isEmpty()) {
						LPI_DML.doUpdate(bankAccountList);
					}

					List<TrainingCourseParticipant> trainingCouseParticipantList = new List<TrainingCourseParticipant>();
					for (TrainingCourseParticipant trainingCouseParticipant : [
						SELECT Id, OwnerId
						FROM TrainingCourseParticipant
						WHERE Preliminary_Application_Reference__c IN: parIdSet
						AND OwnerId IN: relatedTotoUserIdMap.values()
					]) {
						trainingCouseParticipant.OwnerId = queueToAssignRecord.Id;
						trainingCouseParticipantList.add(trainingCouseParticipant);
					}
					if (!trainingCouseParticipantList.isEmpty()) {
						LPI_DML.doUpdate(trainingCouseParticipantList);
					}

					List<PreliminaryApplicationRef> moreParForSameAccount =  [
						SELECT Id, OwnerId, BusinessAccountNameId
						FROM PreliminaryApplicationRef
						WHERE OwnerId IN: relatedTotoUserIdMap.values()
						AND ID NOT IN: parIdSet
						AND BusinessAccountNameId IN: accountOfPar
					];

					if(moreParForSameAccount.isEmpty()){
						List<Account> accountList = new List<Account>();
						for (Account acc : [
							SELECT Id, OwnerId
							FROM Account
							WHERE OwnerId IN: relatedTotoUserIdMap.values()
							AND Id IN: accountOfPar
						]) {
							acc.OwnerId = Label.UserOwnerId;
							accountList.add(acc);
						}
						if (!accountList.isEmpty()) {
							LPI_DML.doUpdate(accountList);
						}
					}
				}				
			}
		} catch (Exception e) {
			LPI_ExceptionManager.logException('LPI_ChangeOwnerAfterSubmitScheduler', 'execute', e);
		}
	}
}