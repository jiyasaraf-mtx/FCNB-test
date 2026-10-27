public without sharing class LPI_GeneratePDF {

    @future(callout = true)
    public static void generatePDF(Id iaRecId, Id ntfRecId) {
		System.debug('Entered Generate PDF>>>>');
		List<ContentVersion> newCVList = new List<ContentVersion>();
            //Network netId = [SELECT Id, Name FROM Network Where Name = 'Licensing Portal'];
            	PageReference pdf;
				String PDFTitle = 'Test';
				String pdfUrl = '/apex/';
                Notification__c nt = [SELECT Id, Name, Template_Name__c,Individual_Application__r.Name,Business_License_Application__r.Name, 
											PDF_Attachment_Name__c 
											FROM Notification__c 
											WHERE Id=:ntfRecId];
				
				String pageName = nt.PDF_Attachment_Name__c;
				if(nt.Individual_Application__r.Name == null){
					PDFTitle = nt.Business_License_Application__r.Name;
				}else if(nt.Business_License_Application__r.Name == null){
					PDFTitle = nt.Individual_Application__r.Name;
				}
				pdf =new PageReference(pdfUrl + pageName);
				pdf.getParameters().put('targetId',iaRecId);
				Blob body;
				try{
					body = pdf.getContent();
					System.debug('DEBUG '+ body);
				}catch(VisualforceException e) {
					body = Blob.valueOf('PDF Get Failed');
				}
				ContentVersion cv = new ContentVersion();
				cv.Title = PDFTitle +'-'+ Date.today(); 
				cv.PathOnClient = '/ApplicationSubmitted/' + iaRecId + '/' + Date.today() + '.pdf';
				cv.FirstPublishLocationId = ntfRecId;
				cv.VersionData = body;
                cv.ContentLocation = 'S';
                //cv.OwnerId = ntfRecId.OwnerId;
                cv.NetworkId = LPI_LiteralConstant.NETWORK_ID_LICENSING_PORTAL;
				cv.IsMajorVersion = true;
				newCVList.add(cv);
                LPI_DML.doInsert(newCVList);
				List<Notification__c> toUpdateNTFList = new List<Notification__c>();
				Notification__c updateNtf = new Notification__c();
				updateNtf.Id = ntfRecId;
				updateNtf.Send_Email__c = true;
				toUpdateNTFList.add(updateNtf);
				LPI_DML.doUpdate(toUpdateNTFList);

    }
}