@IsTest
private class EMP_PremiumTaxCtrlTest {
    @IsTest
    static void prepareSuccessParams_and_getTaxReturn() {
        Tax_Return_Applications__c tra = new Tax_Return_Applications__c(
            Taxable_Premiums_NB__c = 100,
            Exempt_Premiums__c = 0,
            Rate__c = 2,
            Calculated_Levy__c = 2,
            Installments__c = 1,
            Currency__c = 0,
            Applicant__c = UserInfo.getUserId(),
            Tax_Type__c = 'Premium Tax',
            Reporting_Period__c = 'Q2 2026',
            Filing_Status__c = 'Draft',
            Status__c = 'Unpaid'
        );
        insert tra;
        tra = [SELECT Id, Name FROM Tax_Return_Applications__c WHERE Id = :tra.Id];

        Map<String, Object> input = new Map<String, Object>{ 'Id' => tra.Id };
        Map<String, Object> output = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();

        Test.startTest();
        Object callableResult = new EMP_PremiumTaxCtrl()
            .call(
                'prepareSuccessParams',
                new Map<String, Object>{
                    'input' => input,
                    'output' => output,
                    'options' => options
                }
            );
        EMP_PremiumTaxCtrl.TaxReturnDTO dto = EMP_PremiumTaxCtrl.getTaxReturn(tra.Id);
        EMP_PremiumTaxCtrl.PremiumTaxPageDTO page = EMP_PremiumTaxCtrl.getPremiumTaxFilings();
        Test.stopTest();

        System.assertEquals(true, callableResult);
        System.assertEquals(tra.Id, (Id) String.valueOf(output.get('ContextId')));
        System.assertEquals(tra.Name, String.valueOf(output.get('FilingNumber')));
        System.assertEquals(tra.Name, dto.name);
        System.assertNotEquals(null, page.returns);
        System.assert(page.returns.size() >= 1);
    }

    @IsTest
    static void getReturnDefaults_and_saveReturnHeader() {
        Map<String, Object> defaultsOut = new Map<String, Object>();
        Test.startTest();
        new EMP_PremiumTaxCtrl()
            .call(
                'getReturnDefaults',
                new Map<String, Object>{
                    'input' => new Map<String, Object>(),
                    'output' => defaultsOut,
                    'options' => new Map<String, Object>()
                }
            );

        Map<String, Object> saveOut = new Map<String, Object>();
        new EMP_PremiumTaxCtrl()
            .call(
                'saveReturnHeader',
                new Map<String, Object>{
                    'input' => new Map<String, Object>{
                        'Applicant' => UserInfo.getUserId(),
                        'TaxType' => 'Premium Tax',
                        'ReportingPeriod' => 'Q2 2026',
                        'FilingStatus' => 'Draft'
                    },
                    'output' => saveOut,
                    'options' => new Map<String, Object>()
                }
            );
        Test.stopTest();

        System.assertEquals('Premium Tax', String.valueOf(defaultsOut.get('TaxType')));
        System.assertEquals('Draft', String.valueOf(defaultsOut.get('FilingStatus')));
        System.assertEquals(UserInfo.getUserId(), (Id) String.valueOf(defaultsOut.get('Applicant')));
        System.assertNotEquals(null, saveOut.get('Id'));
        System.assertNotEquals(null, saveOut.get('ReturnId'));

        Id traId = (Id) String.valueOf(saveOut.get('Id'));
        Tax_Return_Applications__c saved = [
            SELECT Applicant__c, Tax_Type__c, Reporting_Period__c, Filing_Status__c, Calculated_Levy__c
            FROM Tax_Return_Applications__c
            WHERE Id = :traId
        ];
        System.assertEquals(UserInfo.getUserId(), saved.Applicant__c);
        System.assertEquals('Premium Tax', saved.Tax_Type__c);
        System.assertEquals('Q2 2026', saved.Reporting_Period__c);
        System.assertEquals('Draft', saved.Filing_Status__c);
    }
}