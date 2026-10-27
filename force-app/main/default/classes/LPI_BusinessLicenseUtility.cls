/**
 * @author          : MTX Group Product Team
 * @description     : Utility Class
 * * @history
 * -------------------------------------------------------------------------------------------------------
 * Version      Date                Author                  Details
 *    1         11 Nov, 2022        Nandirudra Mokalsare    Initial Developement
 * 	  2         Feb 15, 2023        Nitish Gundedi          Updated logic for checkForReinstatement and Added checkForReactivation
 *    3         Mar 31, 2023        Nitish Gundedi          Updated checkForReinstatement incase of Extended expiry blank
 *    4         July 27, 2023       Nitish Gundedi          Updated Exception case for CPA Reinstatment and Suspended Status Exception for Few RAT's
 * -------------------------------------------------------------------------------------------------------
 */
public inherited sharing class LPI_BusinessLicenseUtility {
	private static final Set<String> HIDE_RENEWAL_LICENSE_SUB_STATUS_SET = new Set<String>{
		'Non-Renew',
        'Non-Practicing'
	};
	private static final Set<Integer> FEB_END_DAYS_SET = new Set<Integer>{
		28,
		29
	};

	/**
	 * @description : This method is to check whether present date lies within Reinstatement period of BusinessLicense
	 * @author Nandirudra Mokalsar | 01-22-2023
	 * @param blRecord
	 * @return Boolean
	 **/
	public static Boolean checkForReinstatement(BusinessLicense blRecord) {
		try {
			if (blRecord.PeriodEnd != null) {
				Date expiryDate = Date.newInstance(blRecord.PeriodEnd.year(), blRecord.PeriodEnd.month(), blRecord.PeriodEnd.day());
				if (
					blrecord.RegulatoryAuthorizationType.Extended_Expiry_Period__c != null &&
					blrecord.RegulatoryAuthorizationType.Extended_Expiry_Period__c != 0
				) {
					Date reinstateStartDate;
					if (
						blRecord.RegulatoryAuthorizationType.Late_Renewal_Allowed__c != null &&
						blRecord.RegulatoryAuthorizationType.Late_Renewal_Allowed__c != 0
					) {
						reinstateStartDate = expiryDate.addMonths(
							Integer.valueOf(blRecord.RegulatoryAuthorizationType.Late_Renewal_Allowed__c)
						);
					} else {
						reinstateStartDate = expiryDate;
					}
					if((expiryDate.month() == 2 && FEB_END_DAYS_SET.contains(expiryDate.day())) || expiryDate.day() == date.daysInMonth(expiryDate.year(),expiryDate.month())){
						reinstateStartDate = reinstateStartDate.addMonths(1).toStartOfMonth();
					}else{
						reinstateStartDate = reinstateStartDate.addDays(1);
					}
					Date reinstateEndDate;
					if (
						blrecord.Reinstatement_Count__c != null &&
						blrecord.Reinstatement_Count__c >= 1 &&
						blrecord.RegulatoryAuthorizationType.Subsequent_Reinstatement_Period__c != null &&
						blrecord.RegulatoryAuthorizationType.Subsequent_Reinstatement_Period__c != 0
					) {
						reinstateEndDate = reinstateStartDate.addMonths(
							Integer.valueof(blRecord.RegulatoryAuthorizationType.Subsequent_Reinstatement_Period__c)
						);
					} else if (
						blrecord.Reinstatement_Count__c == null ||
						blrecord.Reinstatement_Count__c < 1 ||
						(blrecord.Reinstatement_Count__c >= 1 &&
						(blrecord.RegulatoryAuthorizationType.Subsequent_Reinstatement_Period__c == null ||
						blrecord.RegulatoryAuthorizationType.Subsequent_Reinstatement_Period__c == 0))
					) {
						reinstateEndDate = reinstateStartDate.addMonths(
							Integer.valueof(blRecord.RegulatoryAuthorizationType.Extended_Expiry_Period__c)
						);
					} 
					if (reinstateStartDate != null && reinstateStartDate <= System.today() && reinstateEndDate > System.today()) {
						return true;
					} else {
						return false;
					}
				} else {
					Date reinstateStartDate;
					if (
						blRecord.RegulatoryAuthorizationType.Late_Renewal_Allowed__c != null &&
						blRecord.RegulatoryAuthorizationType.Late_Renewal_Allowed__c != 0
					) {
						reinstateStartDate = expiryDate.addMonths(
							Integer.valueOf(blRecord.RegulatoryAuthorizationType.Late_Renewal_Allowed__c)
						);
					} else {
						reinstateStartDate = expiryDate;
					}
					if((expiryDate.month() == 2 && FEB_END_DAYS_SET.contains(expiryDate.day())) || expiryDate.day() == date.daysInMonth(expiryDate.year(),expiryDate.month())){
						reinstateStartDate = reinstateStartDate.addMonths(1).toStartOfMonth();
					}else{
						reinstateStartDate = reinstateStartDate.addDays(1);
					}
					if (reinstateStartDate != null && reinstateStartDate <= System.today()) {
						return true;
					} else {
						return false;
					}
				}
			}
			return false;
		} catch (Exception e) {
			LPI_ExceptionManager.logException('LPI_BusinessUtility', 'checkForReinstatement', e);
			throw new AuraHandledException(e.getMessage());
		}
	}

	/**
	 * @author                      : MTX Group Product Team
	 * @since                       : 15th Feb
	 * @description                 : This method is to check whether present date lies within Reactivation period of BusinessLicense
	 * @return                      : boolean
	 * @last modified by            : MTX Group Product Team
	 * @last modified date          :
	 * @modified details            :
	 */
	public static boolean checkForReactivation(BusinessLicense blRecord) {
		try {
			if (
				blRecord.RegulatoryAuthorizationType.Reactivation_Period__c != null &&
				blrecord.RegulatoryAuthorizationType.Reactivation_Period__c != 0
			) {
				if (blRecord.Inactivation_Date__c != null) {
					Date reactivationStartDate = blRecord.Inactivation_Date__c;
					Date reactivationEndDate = reactivationStartDate.addMonths(
						Integer.valueOf(blRecord.RegulatoryAuthorizationType.Reactivation_Period__c)
					);
					if (
						reactivationStartDate != null &&
						reactivationStartDate <= System.today() &&
						reactivationEndDate > System.today()
					) {
						return true;
					}
				}
			} else {
				return true;
			}
			return false;
		} catch (Exception e) {
			LPI_ExceptionManager.logException('LPI_BusinessLicenseUtility', 'checkForReactivation', e);
			throw new AuraHandledException(e.getMessage());
		}
	}

	/**
	 * @author                      : MTX Group Product Team
	 * @since                       :
	 * @description                 : This method is to check whether present date lies within Renewal period (Open for renewal/ Late renewal) of BusinessLicense
	 * @return                      : boolean
	 * @last modified by            : MTX Group Product Team
	 * @last modified date          :
	 * @modified details            :
	 */
	public static boolean checkForRenewal(BusinessLicense blRecord) {
		try {
			if(HIDE_RENEWAL_LICENSE_SUB_STATUS_SET.contains(blRecord.License_Sub_status__c)){
				return false;
			}
			if (blRecord.PeriodEnd != null) {
				Date expiryDate = Date.newInstance(blRecord.PeriodEnd.year(), blRecord.PeriodEnd.month(), blRecord.PeriodEnd.day());
				Date renewalStartDate;
				if (blRecord.RegulatoryAuthorizationType.Open_for_Renewal__c != null) {
					renewalStartDate = expiryDate.addMonths(
						-Integer.valueOf(blRecord.RegulatoryAuthorizationType.Open_for_Renewal__c)
					);
				}else{
					renewalStartDate = expiryDate;
				}
				Date renewalEndDate;
				if (blRecord.RegulatoryAuthorizationType.Late_Renewal_Allowed__c != null) {
					renewalEndDate = expiryDate.addMonths(
						Integer.valueOf(blRecord.RegulatoryAuthorizationType.Late_Renewal_Allowed__c)
					);
				}else{
					renewalEndDate = expiryDate;
				}
				if((expiryDate.month() == 2 && FEB_END_DAYS_SET.contains(expiryDate.day())) || expiryDate.day() == date.daysInMonth(expiryDate.year(),expiryDate.month())){
					renewalStartDate = renewalStartDate.addMonths(1).toStartOfMonth();
					renewalEndDate = renewalEndDate.addMonths(1).toStartOfMonth().addDays(-1);
				}else{
					renewalStartDate = renewalStartDate.addDays(1);
				}
				if (renewalStartDate != null && renewalStartDate <= System.today() && renewalEndDate >= System.today()) {
					return true;
				}
			}
			return false;
		} catch (Exception e) {
			LPI_ExceptionManager.logException('LPI_BusinessLicenseUtility', 'checkForRenewal', e);
			throw new AuraHandledException(e.getMessage());
		}
	}

	/**
	 * @author                      : MTX Group Product Team
	 * @since                       : 24th June, 2023
	 * @description                 : This method is to check whether the current date lies in Reinstatemenet by Exam Period
	 * @return                      : boolean
	 * @last modified by            : MTX Group Product Team
	 * @last modified date          :
	 * @modified details            :
	 */
	public static boolean checkForReinstatementByExam(BusinessLicense blRecord) {
		try {
			if(blRecord.PeriodEnd != null){
				Date expiryDate = Date.newInstance(blRecord.PeriodEnd.year(), blRecord.PeriodEnd.month(), blRecord.PeriodEnd.day());
				Date reinstateByExamStartDate;
				Date reinstateByExamEndDate;
				if (
					blRecord.RegulatoryAuthorizationType.Extended_Expiry_Period__c != null &&
					blRecord.RegulatoryAuthorizationType.Extended_Expiry_Period__c != 0
				) {
					reinstateByExamStartDate = expiryDate.addMonths(Integer.valueOf(blRecord.RegulatoryAuthorizationType.Extended_Expiry_Period__c));
					if((expiryDate.month() == 2 && FEB_END_DAYS_SET.contains(expiryDate.day())) || expiryDate.day() == date.daysInMonth(expiryDate.year(),expiryDate.month())){
						reinstateByExamStartDate = reinstateByExamStartDate.addMonths(1).toStartOfMonth();
					}else{
						reinstateByExamStartDate = reinstateByExamStartDate.addDays(1);
					}
				}
				if (
					blrecord.RegulatoryAuthorizationType.Reinstatement_by_Exam_Period__c != null &&
					blrecord.RegulatoryAuthorizationType.Reinstatement_by_Exam_Period__c != 0
				) {
					reinstateByExamEndDate = reinstateByExamStartDate.addMonths(
								Integer.valueof(blRecord.RegulatoryAuthorizationType.Reinstatement_by_Exam_Period__c)
							);
				}
				if(reinstateByExamStartDate != null && reinstateByExamStartDate <= System.today()){
					if(reinstateByExamEndDate == null || (reinstateByExamEndDate != null && reinstateByExamEndDate > System.today())){
						return true;
					}else{
						return false;
					}
				}
			}
			return false;
		} catch (Exception e) {
			LPI_ExceptionManager.logException('LPI_BusinessLicenseUtility', 'checkForReinstatementByExam', e);
			throw new AuraHandledException(e.getMessage());
		}
	}
}