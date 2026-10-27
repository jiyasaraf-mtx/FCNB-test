/**
 * @description Controller for Public Complaint RCV warning banner on record page.
 * @author MTX Group Product Team
 */
public without sharing class LPI_PublicComplaintRcvController {
	/**
	 * @description Returns true when any Case linked to the Public Complaint via ComplaintCase
	 *              has a Visit with at least one RegulatoryCodeViolation (InspectionId).
	 * @param publicComplaintId PublicComplaint Id
	 * @return Boolean
	 */
	@AuraEnabled
	public static Boolean hasCaseRelatedRcv(Id publicComplaintId) {
		try {
			if (publicComplaintId == null) {
				return false;
			}

			List<ComplaintCase> complaintCases = [
				SELECT CaseId
				FROM ComplaintCase
				WHERE PublicComplaintId = :publicComplaintId AND CaseId != NULL
			];

			if (complaintCases.isEmpty()) {
				return false;
			}

			Set<Id> caseIds = new Set<Id>();
			for (ComplaintCase cc : complaintCases) {
				caseIds.add(cc.CaseId);
			}

			List<Visit> caseVisits = [
				SELECT Id
				FROM Visit
				WHERE ContextId IN :caseIds
			];

			if (caseVisits.isEmpty()) {
				return false;
			}

			Set<Id> visitIds = new Set<Id>();
			for (Visit visitRec : caseVisits) {
				visitIds.add(visitRec.Id);
			}

			List<RegulatoryCodeViolation> rcvList = [
				SELECT Id
				FROM RegulatoryCodeViolation
				WHERE InspectionId IN :visitIds
				LIMIT 1
			];

			return !rcvList.isEmpty();
		} catch (Exception e) {
			LPI_ExceptionManager.logException('LPI_PublicComplaintRcvController', 'hasCaseRelatedRcv', e);
			throw new AuraHandledException(e.getMessage());
		}
	}
}