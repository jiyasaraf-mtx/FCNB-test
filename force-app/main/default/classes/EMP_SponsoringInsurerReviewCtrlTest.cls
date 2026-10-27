@IsTest
private class EMP_SponsoringInsurerReviewCtrlTest {
	@IsTest(SeeAllData = true)
	static void testGetQueueAndSaveDecision() {
		IndividualApplication ia = [
			SELECT Id, Name, Status, Board_Name__c
			FROM IndividualApplication
			WHERE Name = 'IA-0000000362'
			LIMIT 1
		];

		Test.startTest();
		EMP_SponsoringInsurerReviewCtrl.QueueResult queue = EMP_SponsoringInsurerReviewCtrl.getQueue();
		System.assertNotEquals(null, queue);
		System.assert(queue.applications != null && !queue.applications.isEmpty(), 'Expected IIA applications in queue');

		Boolean found = false;
		for (EMP_SponsoringInsurerReviewCtrl.ApplicationRow row : queue.applications) {
			if (row.id == ia.Id) {
				found = true;
				System.assert(
					String.isNotBlank(row.agency),
					'Agency should populate from Board_Name__c'
				);
			}
		}
		System.assert(found, 'Existing IIA application should appear in queue');

		EMP_SponsoringInsurerReviewCtrl.ApplicationRow updated = EMP_SponsoringInsurerReviewCtrl.saveDecision(
			ia.Id,
			'Approved by Insurer',
			'Sponsorship approved for test'
		);
		System.assertEquals('Approved by Insurer', updated.status);
		IndividualApplication iaAfter = [
			SELECT Status, Admin_Action_Status__c, SavedApplicationRef.SponsoringInsurer_Supervisor_JSON__c
			FROM IndividualApplication
			WHERE Id = :ia.Id
		];
		System.assert(
			iaAfter.SavedApplicationRef.SponsoringInsurer_Supervisor_JSON__c.contains('Approved by Insurer'),
			'SI_Status should retain insurer decision'
		);
		Test.stopTest();
	}

	@IsTest(SeeAllData = true)
	static void testPortalUserCanSaveDecision() {
		User portalUser = [
			SELECT Id
			FROM User
			WHERE Username = 'shubham.jain@mtxg.ai.lpi' AND IsActive = true
			LIMIT 1
		];
		PermissionSet ps = [
			SELECT Id
			FROM PermissionSet
			WHERE Name = 'EMP_Sponsoring_Insurer_Review'
			LIMIT 1
		];
		List<PermissionSetAssignment> existing = [
			SELECT Id
			FROM PermissionSetAssignment
			WHERE AssigneeId = :portalUser.Id AND PermissionSetId = :ps.Id
		];
		if (existing.isEmpty()) {
			insert new PermissionSetAssignment(AssigneeId = portalUser.Id, PermissionSetId = ps.Id);
		}

		// Prefer a Submitted IIA; otherwise reuse an Approved one after resetting via elevated path first as admin
		List<IndividualApplication> submitted = [
			SELECT Id, Board_Name__c
			FROM IndividualApplication
			WHERE License_Type_Name__c = 'Individual Insurance Agent' AND Status = 'Submitted'
			ORDER BY LastModifiedDate DESC
			LIMIT 1
		];
		Id appId;
		if (!submitted.isEmpty()) {
			appId = submitted[0].Id;
		} else {
			IndividualApplication anyIia = [
				SELECT Id
				FROM IndividualApplication
				WHERE License_Type_Name__c = 'Individual Insurance Agent'
				ORDER BY LastModifiedDate DESC
				LIMIT 1
			];
			// Put back to Submitted so portal can decide
			EMP_SponsoringInsurerReviewCtrl.saveDecision(anyIia.Id, 'Submitted to Insurer', 'Reset for portal test');
			appId = anyIia.Id;
		}

		Test.startTest();
		System.runAs(portalUser) {
			EMP_SponsoringInsurerReviewCtrl.QueueResult queue = EMP_SponsoringInsurerReviewCtrl.getQueue();
			System.assert(!queue.applications.isEmpty(), 'Portal user should read IIA queue');

			EMP_SponsoringInsurerReviewCtrl.ApplicationRow updated = EMP_SponsoringInsurerReviewCtrl.saveDecision(
				appId,
				'Approved by Insurer',
				'Portal user approve E2E'
			);
			System.assertEquals('Approved by Insurer', updated.status);
			System.assert(
				String.isNotBlank(updated.agency),
				'Agency should come from Board_Name__c for portal user'
			);
		}
		Test.stopTest();
	}

	@IsTest
	static void testSaveDecisionValidation() {
		Test.startTest();
		try {
			EMP_SponsoringInsurerReviewCtrl.saveDecision(null, 'Approved by Insurer', null);
			System.assert(false, 'Expected exception');
		} catch (AuraHandledException ex) {
			System.assert(ex.getMessage() != null);
		}
		try {
			EMP_SponsoringInsurerReviewCtrl.saveDecision(UserInfo.getUserId(), 'Invalid', null);
			System.assert(false, 'Expected exception');
		} catch (Exception ex) {
			System.assert(ex.getMessage() != null);
		}
		Test.stopTest();
	}

	@IsTest(SeeAllData = true)
	static void testApprovedStatusMapsForFilter() {
		IndividualApplication ia = [
			SELECT Id, Status, Board_Name__c
			FROM IndividualApplication
			WHERE License_Type_Name__c = 'Individual Insurance Agent' AND Status = 'Approved'
			ORDER BY LastModifiedDate DESC
			LIMIT 1
		];

		Test.startTest();
		EMP_SponsoringInsurerReviewCtrl.QueueResult queue = EMP_SponsoringInsurerReviewCtrl.getQueue();
		Test.stopTest();

		Boolean found = false;
		Integer approvedCount = 0;
		for (EMP_SponsoringInsurerReviewCtrl.ApplicationRow row : queue.applications) {
			if (row.status == 'Approved by Insurer') {
				approvedCount++;
			}
			if (row.id == ia.Id) {
				found = true;
				System.assertEquals('Approved by Insurer', row.status, 'Approved Status must map for Approved tab');
				System.assertEquals(ia.Board_Name__c, row.agency);
			}
		}
		System.assert(found, 'Approved IA should appear in queue');
		System.assert(approvedCount > 0, 'Approved tab count should be greater than zero');
	}
}