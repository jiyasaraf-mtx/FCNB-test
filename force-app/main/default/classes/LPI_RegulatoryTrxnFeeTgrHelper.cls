/**
 * Author        : Saurabh singh
 * BuildDate     : 02/08/2023
 */
public with sharing class LPI_RegulatoryTrxnFeeTgrHelper {
	private static final String PAYMENT_PENDING = 'Payment Pending';
	private static final String PAID = 'Paid';

	/**
	 * @author             : Saurabh singh
	 * @description        : This method will mark Payment Pending field on IA and BlA false if regulatory transaction fee status is Paid
	 * BuildDate           : 02/08/2023
	 * @last modified by   : MTX Group Inc.
	 * @last modified date : 30 Aug, 2023
	 */
	public static void markPaymentPendingCheckBoxTrueFalseOnApp(
		List<RegulatoryTrxnFee> recordsList,
		Map<Id, RegulatoryTrxnFee> mapOfOldRecords
	) {
		try {
			List<BusinessLicenseApplication> updateBlaIdList = new List<BusinessLicenseApplication>();
			List<IndividualApplication> updateIaIdList = new List<IndividualApplication>();
			Set<Id> applicationIdSet = new Set<Id>();
			if (LPI_WithoutSharingUtility.isPortalUser()) {
				return;
			}
			for (RegulatoryTrxnFee rtf : recordsList) {
				if (
					(mapOfOldRecords == null) ||
					(mapOfOldRecords != null &&
					mapOfOldRecords.get(rtf.Id).Status__c != rtf.Status__c &&
					rtf.Status__c == PAID)
				) {
					if (rtf.ParentRecordId.getSObjectType() == Schema.BusinessLicenseApplication.getSObjectType()) {
						BusinessLicenseApplication updateBLA = new BusinessLicenseApplication(Id = rtf.ParentRecordId);
						updateBLA.Payment_Pending__c = rtf.Status__c == PAID
							? false
							: rtf.Status__c == PAYMENT_PENDING ? true : false;
						if (!updateBLA.Payment_Pending__c && mapOfOldRecords == null) {
							applicationIdSet.add(updateBLA.Id);
						}
						updateBlaIdList.add(updateBLA);
					} else if (rtf.ParentRecordId.getSObjectType() == Schema.IndividualApplication.getSObjectType()) {
						IndividualApplication updateIa = new IndividualApplication(Id = rtf.ParentRecordId);
						updateIa.Payment_Pending__c = rtf.Status__c == PAID
							? false
							: rtf.Status__c == PAYMENT_PENDING ? true : false;
						if (!updateIa.Payment_Pending__c && mapOfOldRecords == null) {
							applicationIdSet.add(updateIa.Id);
						}
						updateIaIdList.add(updateIa);
					}
				}
			}

			if (!applicationIdSet.isEmpty()) {
				List<RegulatoryTrxnFee> pendingRegTrxnFeeList = LPI_RegulatoryTrxnFeeDAO.getRegulatoryTrxnFeeByDymanicQuery(
					'Id',
					'Status__c = \'' +
						PAYMENT_PENDING +
						'\' AND ParentRecordId IN ' +
						LPI_ServiceUtility.getStringValuesBySet(applicationIdSet),
					null,
					null,
					null
				);
				for (RegulatoryTrxnFee rtf : pendingRegTrxnFeeList) {
					rtf.Status__c = PAID;
					rtf.Status = LPI_LiteralConstant.REG_PAID;
				}
				LPI_DML.doUpdate(pendingRegTrxnFeeList);
			}

			if (!updateBlaIdList.isEmpty()) {
				LPI_WithoutSharingUtility.updateSObjectList(updateBlaIdList);
			}

			if (!updateIaIdList.isEmpty()) {
				LPI_WithoutSharingUtility.updateSObjectList(updateIaIdList);
			}
		} catch (Exception ex) {
			LPI_ExceptionManager.logException(
				'LPI_RegulatoryTrxnFeeTgrHelper',
				'markPaymentPendingCheckBoxFalseOnApp',
				ex
			);
		}
	}
}