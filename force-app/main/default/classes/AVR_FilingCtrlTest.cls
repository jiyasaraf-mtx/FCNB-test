@IsTest
private class AVR_FilingCtrlTest {
    @IsTest
    static void coversFilingCrud() {
        Account acc = new Account(Name = 'Harbour Employees Pension Plan');
        insert acc;
        Contact con = new Contact(
            FirstName = 'Nora',
            LastName = 'Gallant',
            Email = 'nora.gallant@harbourplan-demo.ca',
            AccountId = acc.Id
        );
        insert con;

        AVR_Filing__c filing = new AVR_Filing__c(
            Filing_Type__c = 'AVR',
            Reporting_Year__c = '2025',
            Plan_Name__c = 'Harbour Employees Pension Plan',
            Plan_Registration_Number__c = 'PEN-NB-77821',
            First_Name__c = 'Nora',
            Last_Name__c = 'Gallant',
            Email__c = 'nora.gallant@harbourplan-demo.ca',
            Phone__c = '506-555-0100',
            Registration_Number__c = 'PEN-NB-77821',
            Valuation_Date__c = Date.newInstance(2025, 12, 31),
            Filing_Due_Date__c = Date.newInstance(2026, 9, 30),
            Actuary_Name__c = 'Demo Actuary',
            Actuary_Firm__c = 'Demo Actuary Inc.',
            Status__c = 'Draft',
            Account__c = acc.Id,
            Contact__c = con.Id
        );
        insert filing;

        Test.startTest();
        AVR_FilingCtrl.FilingPageResult page = AVR_FilingCtrl.getFilings();
        System.assertNotEquals(null, page);
        System.assert(page.filings.size() >= 1);

        AVR_FilingCtrl.FilingDTO dto = AVR_FilingCtrl.getFiling(filing.Id);
        System.assertEquals('2025', dto.reportingYear);

        Map<String, Object> payload = new Map<String, Object>{
            'id' => filing.Id,
            'notes' => 'Updated notes',
            'attestationConfirmed' => true,
            'status' => 'Draft'
        };
        AVR_FilingCtrl.FilingDTO saved = AVR_FilingCtrl.saveFiling(JSON.serialize(payload));
        System.assertEquals('Updated notes', saved.notes);

        AVR_FilingCtrl.FilingDTO submitted = AVR_FilingCtrl.submitFiling(filing.Id);
        System.assertEquals('Submitted', submitted.status);

        filing.Status__c = 'More Information Required';
        update filing;
        AVR_FilingCtrl.FilingDTO rmi = AVR_FilingCtrl.submitRmiResponse(
            filing.Id,
            'Additional schedule attached'
        );
        System.assertEquals('RMI Submitted', rmi.status);
        System.assertEquals('Additional schedule attached', rmi.rmiComments);

        Map<String, Object> createPayload = new Map<String, Object>{
            'filingType' => 'AVR',
            'reportingYear' => '2024',
            'planName' => 'Harbour Employees Pension Plan',
            'planRegistrationNumber' => 'PEN-NB-77821',
            'firstName' => 'Nora',
            'lastName' => 'Gallant',
            'email' => 'nora.gallant@harbourplan-demo.ca',
            'status' => 'Draft'
        };
        AVR_FilingCtrl.FilingDTO created = AVR_FilingCtrl.saveFiling(JSON.serialize(createPayload));
        System.assertNotEquals(null, created.id);
        Test.stopTest();
    }
}