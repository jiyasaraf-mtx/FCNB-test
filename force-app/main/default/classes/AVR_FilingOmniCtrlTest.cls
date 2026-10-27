@IsTest
private class AVR_FilingOmniCtrlTest {
    @IsTest
    static void initCreatesAndReloadsSameDraft() {
        Account acc = new Account(Name = 'Harbour Employees Pension Plan');
        insert acc;
        Contact con = new Contact(
            FirstName = 'Nora',
            LastName = 'Gallant',
            Email = 'nora@example.com',
            AccountId = acc.Id
        );
        insert con;

        AVR_Filing__c existing = new AVR_Filing__c(
            Filing_Type__c = 'AVR',
            Status__c = 'Draft',
            Contact__c = con.Id,
            Account__c = acc.Id
        );
        insert existing;

        Map<String, Object> output1 = new Map<String, Object>();
        Map<String, Object> args1 = new Map<String, Object>{
            'input' => new Map<String, Object>(),
            'output' => output1,
            'options' => new Map<String, Object>()
        };

        Test.startTest();
        // Without ContactId on running user, Owner/CreatedBy draft should be reused
        Object result1 = new AVR_FilingOmniCtrl().call('initFiling', args1);
        Id firstId = (Id) output1.get('ContextId');

        Map<String, Object> output2 = new Map<String, Object>();
        Map<String, Object> args2 = new Map<String, Object>{
            'input' => new Map<String, Object>(),
            'output' => output2,
            'options' => new Map<String, Object>()
        };
        Object result2 = new AVR_FilingOmniCtrl().call('initFiling', args2);
        Test.stopTest();

        System.assertEquals(true, result1);
        System.assertEquals(true, result2);
        System.assertEquals(firstId, output2.get('ContextId'), 'Should reuse the same Draft');
        System.assertEquals(
            1,
            [SELECT COUNT() FROM AVR_Filing__c WHERE Status__c = 'Draft' AND CreatedById = :UserInfo.getUserId()],
            'Should not create another Draft for same user'
        );
        AVR_Filing__c owned = [
            SELECT OwnerId FROM AVR_Filing__c WHERE Id = :firstId
        ];
        System.assertEquals(UserInfo.getUserId(), owned.OwnerId, 'Draft owner must be running user for file upload');
    }

    @IsTest
    static void initReturnsBlankPlanDataWhenUnset() {
        AVR_Filing__c filing = new AVR_Filing__c(
            Filing_Type__c = 'AVR',
            Status__c = 'Draft'
        );
        insert filing;

        Map<String, Object> output = new Map<String, Object>();
        Map<String, Object> args = new Map<String, Object>{
            'input' => new Map<String, Object>{ 'ContextId' => filing.Id },
            'output' => output,
            'options' => new Map<String, Object>()
        };

        Test.startTest();
        new AVR_FilingOmniCtrl().call('initFiling', args);
        Test.stopTest();

        Map<String, Object> planData = (Map<String, Object>) output.get('PlanData');
        System.assertEquals('', planData.get('ActuaryName'));
        System.assertEquals('', planData.get('ActuaryFirm'));
        System.assertEquals('', planData.get('Notes'));
        System.assertEquals('', planData.get('ValuationDate'));
        System.assertEquals('', planData.get('FilingDueDate'));
    }

    @IsTest
    static void submitRequiresAttestation() {
        AVR_Filing__c filing = new AVR_Filing__c(
            Filing_Type__c = 'AVR',
            Status__c = 'Draft',
            Attestation_Confirmed__c = false
        );
        insert filing;

        Map<String, Object> output = new Map<String, Object>();
        Map<String, Object> args = new Map<String, Object>{
            'input' => new Map<String, Object>{
                'ContextId' => filing.Id,
                'AttestationConfirmed' => true
            },
            'output' => output,
            'options' => new Map<String, Object>()
        };

        Test.startTest();
        new AVR_FilingOmniCtrl().call('submitFiling', args);
        Test.stopTest();

        AVR_Filing__c updated = [
            SELECT Status__c, Attestation_Confirmed__c
            FROM AVR_Filing__c
            WHERE Id = :filing.Id
        ];
        System.assertEquals('Submitted', updated.Status__c);
        System.assertEquals(true, updated.Attestation_Confirmed__c);
    }
}