/**
 * @description Test class for LPI_PublicComplaintRcvController.
 * @author MTX Group Product Team
 */
@IsTest
private class LPI_PublicComplaintRcvControllerTest {
	@IsTest
	static void hasCaseRelatedRcv_nullId_returnsFalse() {
		Test.startTest();
		Boolean result = LPI_PublicComplaintRcvController.hasCaseRelatedRcv(null);
		Test.stopTest();

		System.assertEquals(false, result, 'Null Id should return false');
	}

	@IsTest
	static void hasCaseRelatedRcv_noCase_returnsFalse() {
		PublicComplaint pc = new PublicComplaint(
			Status = 'Draft',
			IncidentDate = System.today(),
			Complaint_Details__c = 'Test complaint without case'
		);
		insert pc;

		Test.startTest();
		Boolean result = LPI_PublicComplaintRcvController.hasCaseRelatedRcv(pc.Id);
		Test.stopTest();

		System.assertEquals(false, result, 'Public Complaint with no Case should return false');
	}

	@IsTest
	static void hasCaseRelatedRcv_caseWithoutRcv_returnsFalse() {
		PublicComplaint pc = new PublicComplaint(
			Status = 'Draft',
			IncidentDate = System.today(),
			Complaint_Details__c = 'Test complaint with case no RCV'
		);
		insert pc;

		Id complaintRtId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName()
			.get('Complaint')
			?.getRecordTypeId();

		Case cs = new Case(
			Status = 'New',
			Origin = 'Complaint',
			Subject = 'Test Case No RCV',
			RecordTypeId = complaintRtId
		);
		insert cs;

		insert new ComplaintCase(CaseId = cs.Id, PublicComplaintId = pc.Id);

		Test.startTest();
		Boolean result = LPI_PublicComplaintRcvController.hasCaseRelatedRcv(pc.Id);
		Test.stopTest();

		System.assertEquals(false, result, 'Case with no Visit RCV should return false');
	}

	@IsTest
	static void hasCaseRelatedRcv_visitWithRcv_returnsTrue() {
		PublicComplaint pc = new PublicComplaint(
			Status = 'Draft',
			IncidentDate = System.today(),
			Complaint_Details__c = 'Test complaint with visit RCV'
		);
		insert pc;

		Id complaintRtId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName()
			.get('Complaint')
			?.getRecordTypeId();

		Case cs = new Case(
			Status = 'New',
			Origin = 'Complaint',
			Subject = 'Test Case With Visit RCV',
			RecordTypeId = complaintRtId
		);
		insert cs;

		insert new ComplaintCase(CaseId = cs.Id, PublicComplaintId = pc.Id);

		InspectionType visitType = [
			SELECT Id
			FROM InspectionType
			WHERE Name = 'Complaint'
			LIMIT 1
		];
		Schema.Location place = new Schema.Location(Name = 'Test Place RCV', LocationType = 'Site');
		insert place;

		Visit visitRec = new Visit(
			VisitTypeId = visitType.Id,
			ContextId = cs.Id,
			PlaceId = place.Id,
			PlannedVisitStartTime = System.now(),
			PlannedVisitEndTime = System.now().addDays(1)
		);
		insert visitRec;

		RegulatoryCodeViolation rcv = new RegulatoryCodeViolation(
			InspectionId = visitRec.Id,
			DateCreated = Date.today(),
			Status = 'Open'
		);
		insert rcv;

		Test.startTest();
		Boolean result = LPI_PublicComplaintRcvController.hasCaseRelatedRcv(pc.Id);
		Test.stopTest();

		System.assertEquals(true, result, 'Visit RCV linked to Case should return true');
	}
}