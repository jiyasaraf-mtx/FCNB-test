/**
 * @author      : MTX Group Product Team
 * @since       : 21st Nov 2022
 * @description : This apex class is used to handle payment related data retrivel and manupulation.
 * -------------------------------------------------------------------------------------------------------
 * Version      Date                Author                                 Details
 *    1         21 Oct, 2022        MTX Group Product Team           Initial Developement
 * 	  2			27 Jan, 2023		MTX Group Product Team       	  Shifting Query in DAO Class
 *    3         20 Sep 2023         MTX Group Product Team          Added '$'+ by MTX Group Product Team -  To Show the currency symbol in 
 * 														             "Payment amount" and "processing Fee".
 * -------------------------------------------------------------------------------------------------------
 */
global with sharing class LPI_PaymentController {

	/**
	 * @author                   : MTX Group Product Team
	 * @description              : This method will fetch DashBoard Payments
	 * @param  rtfId         	 : data we are fetching from the Vlocity component
	 * @return                   : `List<PaymentWrap>`
	 */
	@AuraEnabled(cacheable=true)
	public static List<PaymentWrap> getRTFData(Id rtfId) {
		try {
			List<PaymentWrap> payWrap = new List<PaymentWrap>();
			String objectType = String.valueOf(rtfId.getSObjectType());
			String fieldToQuery =
				'Id, Name, LicenseType.IssuingDepartment.Name, SavedApplicationRef.BusinessAccountName.Name, ' +
				'SavedApplicationRef.Contact__r.Name, LicensePermitName.Name, ' +
				'(SELECT Id, Name, Paid_by_someone_other_than_applicant__c, ' +
				'Payer_Full_Name__c, Transaction_ID__c, Transaction_Date__c, ' +
				'Payment_Method__c, TotalFeeAmount, Transaction_Fee_Amount__c ' +
				'FROM RegulatoryTrxnFees WHERE TotalFeeAmount > 0 order by CreatedDate DESC LIMIT 1)';
			String whereClause = 'Id = \'' + rtfId + '\'';

			if (objectType == 'IndividualApplication') {
				List<IndividualApplication> iaList = LPI_IndividualApplicationDAO.getIndividualApplicationByDymanicQuery(
					fieldToQuery,
					whereClause,
					null,
					null,
					null
				);
				if (!iaList.isEmpty() && !iaList[0].RegulatoryTrxnFees.isEmpty()) {
					new PaymentReceiptWrapper(iaList[0], payWrap);
				}
			} else if (objectType == 'BusinessLicenseApplication') {
				List<BusinessLicenseApplication> blaList = LPI_BusinessLicenseApplicationDAO.getBusinessLicenseApplicationByDymanicQuery(
					fieldToQuery,
					whereClause,
					null,
					null,
					null
				);
				if (!blaList.isEmpty() && !blaList[0].RegulatoryTrxnFees.isEmpty()) {
					new PaymentReceiptWrapper(blaList[0], payWrap);
				}
			}
			return payWrap;
		} catch (Exception e) {
			LPI_ExceptionManager.logException('LPI_PaymentController', 'getRTFData', e);
		}
		return null;
	}
	/**
	 * @author                      : MTX Group Product Team
	 * @since                       : May 17, 2023
	 * @description                 : Main Wrapper class used to show payment details
	 * @last modified by            : MTX Group Product Team
	 * @last modified date          :
	 * @modified details            :
	 */
	public class PaymentReceiptWrapper {
		/**
		* @description 
		* @author MTX Group Product Team
		* @param application 
		* @param payWrap 
		**/
		public PaymentReceiptWrapper(IndividualApplication application, List<PaymentWrap> payWrap) {
			payWrap.add(new PaymentWrap('Board', application.LicenseType.IssuingDepartment.Name, 'boardName'));
			payWrap.add(
				new PaymentWrap('Licensee', application.SavedApplicationRef.BusinessAccountName.Name, 'licenseeName')
			);
			payWrap.add(
				new PaymentWrap(
					'Payee',
					application.RegulatoryTrxnFees[0].Payer_Full_Name__c != null
						? application.RegulatoryTrxnFees[0].Payer_Full_Name__c
						: application.SavedApplicationRef.Contact__r.Name,
					'payeeName'
				)
			);
			payWrap.add(
				new PaymentWrap(
					'License Number',
					application.LicensePermitName.Name != null ? application.LicensePermitName.Name : '-',
					'licenseNumber'
				)
			);
			payWrap.add(
				new PaymentWrap(
					'Confirmation/Check Number',
					application.RegulatoryTrxnFees[0].Transaction_ID__c,
					'chequeNumber'
				)
			);
			payWrap.add(
				new PaymentWrap(
					'Date Received',
					application.RegulatoryTrxnFees[0].Transaction_Date__c != null
						? application.RegulatoryTrxnFees[0].Transaction_Date__c.format()
						: '',
					'dateReceived'
				)
			);
			payWrap.add(
				new PaymentWrap('Payment Method', application.RegulatoryTrxnFees[0].Payment_Method__c, 'paymentMethod')
			);
			payWrap.add(new PaymentWrap('Application Number', application.Name, 'applicationNumber'));
			payWrap.add(
				new PaymentWrap('Payment Amount', '$'+application.RegulatoryTrxnFees[0].TotalFeeAmount, 'paymentAmount')
			);
			if(application.RegulatoryTrxnFees[0].Transaction_Fee_Amount__c != null){
				payWrap.add(
					new PaymentWrap(
						'Projected Card Fee',
						'$'+application.RegulatoryTrxnFees[0].Transaction_Fee_Amount__c,
						'processingFee'
					)
				);
			}
			
		}

		/**
		* @description 
		* @author MTX Group Product Team
		* @param application 
		* @param payWrap 
		**/
		public PaymentReceiptWrapper(BusinessLicenseApplication application, List<PaymentWrap> payWrap) {
			payWrap.add(new PaymentWrap('Board', application.LicenseType.IssuingDepartment.Name, 'boardName'));
			payWrap.add(
				new PaymentWrap('Licensee', application.SavedApplicationRef.BusinessAccountName.Name, 'licenseeName')
			);
			payWrap.add(
				new PaymentWrap(
					'Payee',
					application.RegulatoryTrxnFees[0].Payer_Full_Name__c != null
						? application.RegulatoryTrxnFees[0].Payer_Full_Name__c
						: application.SavedApplicationRef.Contact__r.Name,
					'payeeName'
				)
			);
			payWrap.add(
				new PaymentWrap(
					'License Number',
					application.LicensePermitName.Name != null ? application.LicensePermitName.Name : '-',
					'licenseNumber'
				)
			);
			payWrap.add(
				new PaymentWrap(
					'Confirmation/Check Number',
					application.RegulatoryTrxnFees[0].Transaction_ID__c,
					'chequeNumber'
				)
			);
			payWrap.add(
				new PaymentWrap(
					'Date Received',
					application.RegulatoryTrxnFees[0].Transaction_Date__c != null
						? application.RegulatoryTrxnFees[0].Transaction_Date__c.format()
						: '',
					'dateReceived'
				)
			);
			payWrap.add(
				new PaymentWrap('Payment Method', application.RegulatoryTrxnFees[0].Payment_Method__c, 'paymentMethod')
			);
			payWrap.add(new PaymentWrap('Application Number', application.Name, 'applicationNumber'));
			payWrap.add(
				new PaymentWrap('Payment Amount', '$'+application.RegulatoryTrxnFees[0].TotalFeeAmount, 'paymentAmount')
			);
			if(application.RegulatoryTrxnFees[0].Transaction_Fee_Amount__c != null){
				payWrap.add(
					new PaymentWrap(
						'Projected Card Fee',
						'$'+application.RegulatoryTrxnFees[0].Transaction_Fee_Amount__c,
						'processingFee'
					)
				);
			}
		}
	}
	
	/**
	 * @description     : Wrapper Class which contains payment object's manupulated data.
	 */
	public class PaymentWrap {
		@AuraEnabled
		public String label;
		@AuraEnabled
		public Object value;
		@AuraEnabled
		public String key;
		public PaymentWrap(String label, Object value, String key) {
			this.label = label;
			this.value = value;
			this.key = key;
		}
	}
}