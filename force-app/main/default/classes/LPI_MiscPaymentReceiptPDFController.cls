/**
 * @description       : 
 * @author            : MTX Group Product Team
 * @group             : 
 * @last modified on  : 07-26-2024
 * @last modified by  : MTX Group Product Team
  -------------------------------------------------------------------------------------------------------
 * Version      Date                Author                              Details
 *    1         14 Aug 2023      MTX Group Product Team             Initial Developement
 * -------------------------------------------------------------------------------------------------------
 */
public with sharing class LPI_MiscPaymentReceiptPDFController {
 
	public static final String CLASS_NAME = 'LPI_MiscPaymentReceiptPDFController';

	public MiscPaymentReceiptWrapper paymentReceiptData { get; private set; }
	private String applicationName;

	/**
	 * @author                      : MTX Group Product Team
	 * @since                       : 14 Aug 2023
	 * @description                 : This is a constructor, this will extract payment receipt data
	 * @last modified by            : MTX Group Product Team
	 * @last modified date          :
	 * @modified details            :
	 */
	public LPI_MiscPaymentReceiptPDFController() {
		try {
			Id targetId = ApexPages.currentPage().getParameters().get('targetId');
			// For Misc Fee
			if (String.isNotBlank(targetId) && targetId.getSObjectType() == Schema.Miscellaneous_Fee__c.getSObjectType()) {
				this.miscPaymentPDF(targetId);
				if (this.paymentReceiptData != null) {
					string fileName = 'PaymentReceipt ' + this.applicationName;
					Apexpages.currentPage()
						.getHeaders()
						.put('content-disposition', 'attachment; filename=' + fileName + '.pdf');
				}
			}
			
		} catch (Exception e) {
			LPI_ExceptionManager.logException(CLASS_NAME, 'LPI_MiscPaymentReceiptPDFController', e);
		}
	}

	

	/**
	 * @author                      : MTX Group Product Team
	 * @since                       : 14 Aug 2023
	 * @description                 : Method to intitialize the data for payment receipt wrapper
	 * @last modified by            : MTX Group Product Team
	 * @last modified date          :
	 * @modified details            :
	 */
	private void miscPaymentPDF(Id targetId) {
		String fieldToQuery =
			'Id, Name, Fee_Name__c,Board__r.Name,Transaction_ID__c,Deposit_Number__c,Fee_Amount__c,Memo__c,Payer_Full_Name__c,Payer_Phone_Number__c,Payment_Method__c,Process__c,Transaction_Date__c';
		String whereClause = 'Id = \'' + targetId + '\'';

		if (targetId.getSObjectType()  == Schema.Miscellaneous_Fee__c.getSObjectType()) {
			List<Miscellaneous_Fee__c> miscList = LPI_MiscellaneousFeeDAO.getAccountListByDynamicQuery(
				fieldToQuery,
				whereClause,
				null,
				null,
				null
			);
			if (!miscList.isEmpty() ) {
				this.paymentReceiptData = new MiscPaymentReceiptWrapper(miscList[0]);
				this.applicationName = miscList[0].Name;
			}
            
		} 
	}


	public class MiscPaymentReceiptWrapper {
		public string boardName { get; private set; }
		public string payerName { get; private set; }
		public string chequeNumber { get; private set; }
		public DateTime dateReceived { get; private set; }
		public string paymentMethod { get; private set; }
		public string applicationNumber { get; private set; }
		public Decimal paymentAmount { get; private set; }
        public string feeName { get; private set; }
        public string payerPhone { get; private set; }
        public Boolean paidBySomeOneOther { get; private set; }
		

		public MiscPaymentReceiptWrapper(Miscellaneous_Fee__c miscFee) {
			this.boardName = miscFee.Board__r.Name;
			this.payerName = miscFee.Payer_Full_Name__c;
			this.chequeNumber = miscFee.Transaction_ID__c;		
			this.dateReceived = miscFee.Transaction_Date__c;
            if(miscFee.Payment_Method__c == 'Credit')
            {
                this.paymentMethod = 'Credit Card';
            }
            else if(miscFee.Payment_Method__c == 'Debit')
            {
                this.paymentMethod = 'Debit Card';
            }
            else{
                this.paymentMethod = miscFee.Payment_Method__c;
            }
			this.applicationNumber = miscFee.Name;
			this.paymentAmount = miscFee.Fee_Amount__c;
            this.feeName = miscFee.Fee_Name__c;
            this.payerPhone = miscFee.Payer_Phone_Number__c;
		}	
	}
    

}