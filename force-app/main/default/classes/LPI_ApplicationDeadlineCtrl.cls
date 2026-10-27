public with sharing class LPI_ApplicationDeadlineCtrl {
    private static final String EXPEDITED_FEE_NAME = 'Expedited Fee';
    private static final Integer EXPEDITED_DAYS = 2;
    private static final Integer STANDARD_DAYS = 7;

    /**
     * Returns deadline days for the Individual Application:
     * 3 when an "Expedited Fee" item exists, otherwise 7.
     */
    @AuraEnabled(cacheable=true)
    public static Integer getDeadlineDays(Id applicationId) {
        if (applicationId == null) {
            return STANDARD_DAYS;
        }

        List<RegulatoryTrxnFee> feeList = [
            SELECT Id,
                (SELECT Id, Name FROM RegulatoryTrxnFeeItems)
            FROM RegulatoryTrxnFee
            WHERE ParentRecordId = :applicationId
        ];

        for (RegulatoryTrxnFee fee : feeList) {
            if (fee.RegulatoryTrxnFeeItems == null) {
                continue;
            }
            for (RegulatoryTrxnFeeItem feeItem : fee.RegulatoryTrxnFeeItems) {
                if (feeItem.Name == EXPEDITED_FEE_NAME) {
                    return EXPEDITED_DAYS;
                }
            }
        }

        return STANDARD_DAYS;
    }
}