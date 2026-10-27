/**
 * @description       : 
 * @author            : Rahul Ameta
 * @group             : 
 * @last modified on  : 07-25-2024
 * @last modified by  : MTX Group Inc
  -------------------------------------------------------------------------------------------------------
 * Version      Date                Author                  Details
 *    1         17 March, 2023      Rahul Ameta             Initial Developement
 *    2         1 Sep, 2023         Ayush Yadav             Updated logic for multiple RegulatoryTrxnFee records
 * -------------------------------------------------------------------------------------------------------
 */
public with sharing class LPI_PaymentReceiptPDFController {
	public static final String CLASS_NAME = 'LPI_PaymentReceiptPDFController';
	public static final String PAID_STATUS = 'Paid';
    public static final String PAYMENT_PENDING = 'Payment Pending';
	public List<PaymentReceiptWrapper> paymentReceiptDataList { get; private set; }
	private String applicationName;
	private String businessLicenseName;

	/**
	 * @author                      : Rahul Ameta
	 * @since                       : March 17, 2023
	 * @description                 : This is a constructor, this will extract payment receipt data
	 * @last modified by            : MTX Group Inc
	 * @last modified date          :
	 * @modified details            :
	 */
	public LPI_PaymentReceiptPDFController() {
		try {
			Id targetId = ApexPages.currentPage().getParameters().get('targetId');
			if (String.isNotBlank(targetId)) {
				Id recordId = targetId;
				if(String.valueOf(recordId.getSObjectType()) == 'RegulatoryTrxnFee'){
					this.initPaymentPdfForSingleTrans(recordId);
				}else{
					this.initPaymentPDF(recordId);
				}

				if (!this.paymentReceiptDataList.isEmpty()) {
					String fileName = 'PaymentReceipt ' +(String.isNotBlank(this.applicationName) ? this.applicationName : this.businessLicenseName);
					Apexpages.currentPage()
						.getHeaders()
						.put('content-disposition', 'attachment; filename=' + fileName + '.pdf');
				}
			}
		} catch (Exception e) {
			LPI_ExceptionManager.logException(CLASS_NAME, 'getIdentificationCardDetail', e);
		}
	}

	/**
	 * @author                      : Rahul Ameta
	 * @since                       : March 20, 2023
	 * @description                 : Method to intitialize the data for payment receipt wrapper
	 * @last modified by            : MTX Group Inc
	 * @last modified date          :
	 * @modified details            :
	 */
	private void initPaymentPDF(Id targetId) {
		try {
			this.paymentReceiptDataList = new List<PaymentReceiptWrapper>();
			String objectType = String.valueOf(targetId.getSObjectType());
			String applicationId = '';
			String boardName = '';
			String licenseeName = '';
			String licenseNumber = '';
			String applicationNumber = '';
			String payeeName = '';

			String fieldToQuery =
				'Id, Name, LicenseType.IssuingDepartment.Name, SavedApplicationRef.BusinessAccountName.Name, ' +
				'SavedApplicationRef.Contact__r.Name, LicensePermitName.Name,LicensePermitName.Legacy_License_Number__c';
			String whereClause = 'Id = \'' + targetId + '\'';
			if (objectType == 'IndividualApplication') {
				List<IndividualApplication> iaList = LPI_IndividualApplicationDAO.getIndividualApplicationByDymanicQuery(
					fieldToQuery,
					whereClause,
					null,
					null,
					null
				);

				if (!iaList.isEmpty()) {
					applicationId = iaList[0].Id;
					boardName = iaList[0].LicenseType.IssuingDepartment.Name;
					licenseeName = iaList[0].SavedApplicationRef.BusinessAccountName.Name;
					licenseNumber = String.isNotBlank(iaList[0].LicensePermitName.Legacy_License_Number__c)
						? iaList[0].LicensePermitName.Legacy_License_Number__c
						: iaList[0].LicensePermitName.Name;
					if(licenseNumber == null){
						licenseNumber = '-';
					}
					applicationNumber = iaList[0].Name;
					payeeName = iaList[0].SavedApplicationRef.Contact__r.Name;
					this.applicationName = iaList[0].Name;
				}
			} else if (objectType == 'BusinessLicenseApplication') {
				List<BusinessLicenseApplication> blaList = LPI_BusinessLicenseApplicationDAO.getBusinessLicenseApplicationByDymanicQuery(
					fieldToQuery,
					whereClause,
					null,
					null,
					null
				);

				if (!blaList.isEmpty()) {
					applicationId = blaList[0].Id;
					boardName = blaList[0].LicenseType.IssuingDepartment.Name;
					licenseeName = blaList[0].SavedApplicationRef.BusinessAccountName.Name;
					licenseNumber = String.isNotBlank(blaList[0].LicensePermitName.Legacy_License_Number__c)
						? blaList[0].LicensePermitName.Legacy_License_Number__c
						: blaList[0].LicensePermitName.Name;
					applicationNumber = blaList[0].Name;
					payeeName = blaList[0].SavedApplicationRef.Contact__r.Name;
					this.applicationName = blaList[0].Name;
				}
			}

			String rtfFieldToQuery =
				'Id, Name, Paid_by_someone_other_than_applicant__c,Payer_Full_Name__c, Transaction_ID__c, ' +
				'Transaction_Date__c,Payment_Method__c,TotalFeeAmount,Transaction_Fee_Amount__c,' +
				'(SELECT Id,Name,FeeAmount FROM RegulatoryTrxnFeeItems)';
			List<RegulatoryTrxnFee> rtfList = LPI_RegulatoryTrxnFeeDAO.getRegulatoryTrxnFeeByDymanicQuery(
				rtfFieldToQuery,
				'ParentRecordId = \'' + applicationId + '\' AND (Status__c = \'' + PAID_STATUS + '\' OR Status__c = \'' + PAYMENT_PENDING + '\') ',
				null,
				'CreatedDate',
				'DESC'
			);
			Integer count = 0;
			for (RegulatoryTrxnFee rtf : rtfList) {
				PaymentReceiptWrapper receipt = new PaymentReceiptWrapper();
				receipt.boardName = boardName;
				receipt.licenseeName = licenseeName;
				receipt.licenseNumber = licenseNumber;
				receipt.applicationNumber = applicationNumber;
				receipt.payeeName = rtf.Payer_Full_Name__c != null ? rtf.Payer_Full_Name__c : payeeName;
				receipt.chequeNumber = rtf.Transaction_ID__c;
				receipt.dateReceived = rtf.Transaction_Date__c.format();
				receipt.paymentMethod = rtf.Payment_Method__c;
				receipt.paymentAmount = rtf.TotalFeeAmount;
				receipt.processingFee = rtf.Transaction_Fee_Amount__c != null ? rtf.Transaction_Fee_Amount__c : 0;
				receipt.paymentItems = new List<PaymentItemWrapper>();
				for (RegulatoryTrxnFeeItem feeItem : rtf.RegulatoryTrxnFeeItems) {
					receipt.paymentItems.add(new PaymentItemWrapper(feeItem.Name, feeItem.FeeAmount));
				}
				if (receipt.processingFee > 0) {
					receipt.paymentItems.add(new PaymentItemWrapper('Projected Card Fee', receipt.processingFee));
				}
				this.paymentReceiptDataList.add(receipt);
				count = count + 1;
				if (count == rtfList.size()) {
					receipt.breakPage = false;
				}
				if (rtfList.size() == 1) {
					receipt.receiptHeading = 'Receipt of Payment';
				} else {
					receipt.receiptHeading = 'Receipt of Payment - ' + count;
				}
			}
		} catch (Exception ex) {
			LPI_ExceptionManager.logException('LPI_PaymentReceiptPDFController', 'initPaymentPDF', ex);
		}
	}


	/**
	 * @author                      : Rahul Ameta
	 * @since                       : March 20, 2024
	 * @description                 : Method to intitialize the data for payment receipt wrapper
	 * @last modified by            : MTX Group Inc
	 * @last modified date          :
	 * @modified details            :
	 */
	private void initPaymentPdfForSingleTrans(Id targetId){
		try {
			this.paymentReceiptDataList = new List<PaymentReceiptWrapper>();
			Integer count = 0;
			String rtfFieldToQuery =
					'Id, Name, Paid_by_someone_other_than_applicant__c,Payer_Full_Name__c, Transaction_ID__c, ' +
					'Transaction_Date__c,Payment_Method__c,TotalFeeAmount,Transaction_Fee_Amount__c,' +
					'TYPEOF ParentRecord WHEN IndividualApplication THEN Name, LicenseType.IssuingDepartment.Name, '+
					'SavedApplicationRef.BusinessAccountName.Name, LicensePermitName.Legacy_License_Number__c, '+
					'SavedApplicationRef.Contact__r.Name END, '+
					'TYPEOF ParentRecord WHEN BusinessLicenseApplication THEN Name, LicenseType.IssuingDepartment.Name,'+
					' SavedApplicationRef.BusinessAccountName.Name, LicensePermitName.Legacy_License_Number__c, '+
					'SavedApplicationRef.Contact__r.Name END, '+
					'TYPEOF ParentRecord WHEN BusinessLicense THEN Board_Name__c, Business_Entity_Name__c, Contact.Name, '+
					'Legacy_License_Number__c, License_Name_With_NCBSN_Id__c END, '+
					'(SELECT Id,Name,FeeAmount FROM RegulatoryTrxnFeeItems)';

			List<RegulatoryTrxnFee> rtfList = LPI_RegulatoryTrxnFeeDAO.getRegulatoryTrxnFeeByDymanicQuery(
					rtfFieldToQuery,
					'Id = \'' + targetId + '\' AND Status__c = \'' + PAID_STATUS + '\'',
					null,
					'CreatedDate',
					'DESC'
			);

			if(!rtfList.isEmpty()){
				RegulatoryTrxnFee rtf = rtfList[0];
				PaymentReceiptWrapper receipt = new PaymentReceiptWrapper();
				if(rtf.ParentRecord instanceof BusinessLicense){
					receipt.boardName = ((BusinessLicense)rtf.ParentRecord).Board_Name__c;
					receipt.licenseeName = ((BusinessLicense)rtf.ParentRecord).Business_Entity_Name__c;
					String legacyLicenseNo = ((BusinessLicense)rtf.ParentRecord).Legacy_License_Number__c;
					String ncbsnId = ((BusinessLicense)rtf.ParentRecord).Name;
					receipt.licenseNumber = String.isNotBlank(legacyLicenseNo) ? legacyLicenseNo : ncbsnId;
					this.businessLicenseName = receipt.licenseNumber;
					String payeeName =  ((BusinessLicense)rtf.ParentRecord).Contact.Name;
					receipt.payeeName = rtf.Payer_Full_Name__c != null ? rtf.Payer_Full_Name__c : payeeName;

				}else if(rtf.ParentRecord instanceof IndividualApplication){
					receipt.boardName = ((IndividualApplication)rtf.ParentRecord).LicenseType.IssuingDepartment.Name;
					receipt.licenseeName = ((IndividualApplication)rtf.ParentRecord).SavedApplicationRef.BusinessAccountName.Name;
					String legacyLicenseNo = ((IndividualApplication)rtf.ParentRecord).LicensePermitName.Legacy_License_Number__c;
					String ncbsnId = ((IndividualApplication)rtf.ParentRecord).LicensePermitName.Name;
					receipt.licenseNumber = String.isNotBlank(legacyLicenseNo) ? legacyLicenseNo : ncbsnId;
					String payeeName =  ((IndividualApplication)rtf.ParentRecord).SavedApplicationRef.Contact__r.Name;
					receipt.payeeName = rtf.Payer_Full_Name__c != null ? rtf.Payer_Full_Name__c : payeeName;
					this.applicationName = ((IndividualApplication)rtf.ParentRecord).Name;
					receipt.applicationNumber = this.applicationName;

				}else if(rtf.ParentRecord instanceof BusinessLicenseApplication){
					receipt.boardName = ((BusinessLicenseApplication)rtf.ParentRecord).LicenseType.IssuingDepartment.Name;
					receipt.licenseeName = ((BusinessLicenseApplication)rtf.ParentRecord).SavedApplicationRef.BusinessAccountName.Name;
					String legacyLicenseNo = ((BusinessLicenseApplication)rtf.ParentRecord).LicensePermitName.Legacy_License_Number__c;
					String ncbsnId = ((BusinessLicenseApplication)rtf.ParentRecord).LicensePermitName.Name;
					receipt.licenseNumber = String.isNotBlank(legacyLicenseNo) ? legacyLicenseNo : ncbsnId;
					String payeeName = ((BusinessLicenseApplication)rtf.ParentRecord).SavedApplicationRef.Contact__r.Name;
					receipt.payeeName = rtf.Payer_Full_Name__c != null ? rtf.Payer_Full_Name__c : payeeName;
					this.applicationName = ((BusinessLicenseApplication)rtf.ParentRecord).Name;
					receipt.applicationNumber = this.applicationName;
				}
				receipt.chequeNumber = rtf.Transaction_ID__c;
				receipt.dateReceived = rtf.Transaction_Date__c.format();
				receipt.paymentMethod = rtf.Payment_Method__c;
				receipt.paymentAmount = rtf.TotalFeeAmount;
				receipt.processingFee = rtf.Transaction_Fee_Amount__c != null ? rtf.Transaction_Fee_Amount__c : 0;
				receipt.paymentItems = new List<PaymentItemWrapper>();
				for (RegulatoryTrxnFeeItem feeItem : rtf.RegulatoryTrxnFeeItems) {
					receipt.paymentItems.add(new PaymentItemWrapper(feeItem.Name, feeItem.FeeAmount));
				}
				if (receipt.processingFee > 0) {
					receipt.paymentItems.add(new PaymentItemWrapper('Projected Card Fee', receipt.processingFee));
				}
				this.paymentReceiptDataList.add(receipt);
				count = count + 1;
				if (count == rtfList.size()) {
					receipt.breakPage = false;
				}
				if (rtfList.size() == 1) {
					receipt.receiptHeading = 'Receipt of Payment';
				} else {
					receipt.receiptHeading = 'Receipt of Payment - ' + count;
				}

			}	
		} catch (Exception ex) {
			LPI_ExceptionManager.logException('LPI_PaymentReceiptPDFController', 'initPaymentPdfForSingleTrans', ex);	
		}
	}

	/**
	 * @author                      : Rahul Ameta
	 * @since                       : March 17, 2023
	 * @description                 : Main Wrapper class used to show payment receipt
	 * @last modified by            : MTX Group Inc
	 * @last modified date          :
	 * @modified details            :
	 */
	public class PaymentReceiptWrapper {
		public String boardName { get; private set; }
		public String licenseeName { get; private set; }
		public String payeeName { get; private set; }
		public String licenseNumber { get; private set; }
		public String chequeNumber { get; private set; }
		public String dateReceived { get; private set; }
		public String paymentMethod { get; private set; }
		public String applicationNumber { get; private set; }
		public Decimal paymentAmount { get; private set; }
		public Decimal processingFee { get; private set; }
		public Boolean breakPage { get; private set; }
		public String receiptHeading { get; private set; }
		public List<PaymentItemWrapper> paymentItems { get; private set; }

		public PaymentReceiptWrapper() {
			this.boardName = '';
			this.licenseeName = '';
			this.payeeName = '';
			this.licenseNumber = '';
			this.chequeNumber = '';
			this.dateReceived = '';
			this.paymentMethod = '';
			this.applicationNumber = '';
			this.paymentAmount = 0;
			this.processingFee = 0;
			this.paymentItems = new List<PaymentItemWrapper>();
			this.breakPage = true;
			this.receiptHeading = '';
		}
	}

	public class PaymentItemWrapper {
		public String feeName { get; private set; }
		public Decimal feeAmount { get; private set; }

		public PaymentItemWrapper(String feeName, Decimal feeAmount) {
			this.feeName = feeName;
			this.feeAmount = feeAmount;
		}
	}
}