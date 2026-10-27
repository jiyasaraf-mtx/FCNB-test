@IsTest
private class LPI_PortalSuccessCtrlTest {
    @IsTest
    static void getSuccessDetails_premiumTax_and_generic() {
        Tax_Return_Applications__c tra = new Tax_Return_Applications__c(
            Taxable_Premiums_NB__c = 100,
            Exempt_Premiums__c = 0,
            Rate__c = 2,
            Calculated_Levy__c = 2,
            Installments__c = 1,
            Currency__c = 0
        );
        insert tra;
        tra = [SELECT Id, Name FROM Tax_Return_Applications__c WHERE Id = :tra.Id];

        Test.startTest();
        LPI_PortalSuccessCtrl.SuccessDTO taxDto = LPI_PortalSuccessCtrl.getSuccessDetails(
            'PremiumTax',
            tra.Id
        );
        LPI_PortalSuccessCtrl.SuccessDTO inferDto = LPI_PortalSuccessCtrl.getSuccessDetails(
            null,
            tra.Id
        );
        LPI_PortalSuccessCtrl.SuccessDTO genericDto = LPI_PortalSuccessCtrl.getSuccessDetails(
            'Generic',
            null
        );
        LPI_PortalSuccessCtrl.SuccessDTO arpDto = LPI_PortalSuccessCtrl.getSuccessDetails(
            'AgentReview',
            null
        );
        Test.stopTest();

        System.assertEquals('PremiumTax', taxDto.flowKey);
        System.assertEquals(tra.Name, taxDto.recordNumber);
        System.assertEquals('PremiumTax', inferDto.flowKey);
        System.assertEquals('Generic', genericDto.flowKey);
        System.assertEquals('AgentReview', arpDto.flowKey);
        System.assert(!arpDto.nextSteps.isEmpty());
    }
}