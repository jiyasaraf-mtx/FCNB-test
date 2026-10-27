@IsTest
private class LPI_PortalNotificationTranslator_Test {

    @IsTest
    static void translate_deficiency_enToFr() {
        Notification__c n = new Notification__c(
            Description__c = '<b>Deficiency Notice: </b> Your New application for State Private Occupational Training Organization license has undergone review in the offices of the State Board of Private Occupational Training. However, certain items are required in order to further process your application. Click \'Respond\' to review and submit the necessary items.',
            Button_Label__c = 'Respond',
            Navigate_Component_API_Name__c = 'deficiency-response'
        );

        Test.startTest();
        List<Notification__c> outList = LPI_PortalNotificationTranslator.translate(
            new List<Notification__c>{ n },
            'fr'
        );
        Test.stopTest();

        System.assertEquals(1, outList.size());
        System.assert(
            outList[0].Description__c != null && outList[0].Description__c.toLowerCase().contains('avis de lacunes'),
            'Expected French deficiency description: ' + outList[0].Description__c
        );
        System.assertEquals('Répondre', outList[0].Button_Label__c);
        System.assert(
            outList[0].Description__c.contains('Private Occupational Training Organization'),
            'License type token should be preserved'
        );
    }

    @IsTest
    static void translate_deficiency_frToEn() {
        Notification__c n = new Notification__c(
            Description__c = '<b>Avis de lacunes : </b> Votre demande New pour le permis d\'État Individual Insurance Agent a été examinée aux bureaux de l\'État Financial and Consumer Services Commission of New Brunswick (FCNB). Cependant, certains éléments sont requis afin de poursuivre le traitement de votre demande. Cliquez sur \'Répondre\' pour examiner et soumettre les éléments nécessaires.',
            Button_Label__c = 'Répondre',
            Navigate_Component_API_Name__c = 'deficiency-response'
        );

        Test.startTest();
        List<Notification__c> outList = LPI_PortalNotificationTranslator.translate(
            new List<Notification__c>{ n },
            'en_US'
        );
        Test.stopTest();

        System.assertEquals(1, outList.size());
        System.assert(
            outList[0].Description__c != null && outList[0].Description__c.contains('Deficiency Notice'),
            'Expected English deficiency description: ' + outList[0].Description__c
        );
        System.assertEquals('Respond', outList[0].Button_Label__c);
    }

    @IsTest
    static void translate_rmiAndStatusAndPassthrough() {
        Notification__c rmi = new Notification__c(
            Description__c = '<b>Application Number: IA-1</b><br/>Comments: Please upload docs',
            Button_Label__c = 'Add More Info',
            Type__c = 'RMI_Application'
        );
        Notification__c statusN = new Notification__c(
            Description__c = 'IA-0000000427 status changed to Submitted.'
        );
        Notification__c unmatched = new Notification__c(
            Description__c = 'Some free-form portal note that is not templated.',
            Button_Label__c = 'Custom Action'
        );

        Test.startTest();
        List<Notification__c> frList = LPI_PortalNotificationTranslator.translate(
            new List<Notification__c>{ rmi, statusN, unmatched },
            'fr'
        );
        List<Notification__c> nullLang = LPI_PortalNotificationTranslator.translate(
            new List<Notification__c>{ statusN.clone(true, true, true, true) },
            null
        );
        Test.stopTest();

        System.assertEquals(3, frList.size());
        System.assert(
            frList[0].Description__c.contains('Numéro de demande') || frList[0].Description__c.contains('Commentaires'),
            'RMI should translate: ' + frList[0].Description__c
        );
        System.assertEquals('Ajouter plus d\'informations', frList[0].Button_Label__c);
        System.assert(
            frList[1].Description__c.toLowerCase().contains('statut')
                || frList[1].Description__c.toLowerCase().contains('modifi'),
            'Status should translate: ' + frList[1].Description__c
        );
        System.assertEquals(
            'Some free-form portal note that is not templated.',
            frList[2].Description__c,
            'Unmatched should pass through'
        );
        System.assertEquals(1, nullLang.size());
        System.assert(
            nullLang[0].Description__c.contains('status changed')
                || nullLang[0].Description__c.contains('IA-0000000427'),
            'Null language defaults to EN template merge'
        );
    }

    @IsTest
    static void translate_rmiNoCommentsPlaceholder() {
        Notification__c rmi = new Notification__c(
            Description__c = '<b>Application Number: IA-0000000364</b><br/>Comments: No comments provided.',
            Button_Label__c = 'Add More Info',
            Type__c = 'RMI_Application',
            Url_Param_Json__c = '{"appId":"a01","appNumber":"IA-0000000364","comments":"No comments provided."}'
        );

        Test.startTest();
        List<Notification__c> frList = LPI_PortalNotificationTranslator.translate(
            new List<Notification__c>{ rmi },
            'fr'
        );
        Test.stopTest();

        System.assertEquals(1, frList.size());
        System.assert(
            frList[0].Description__c.contains('Aucun commentaire fourni'),
            'Default comments should be French: ' + frList[0].Description__c
        );
        System.assert(
            frList[0].Url_Param_Json__c.contains('Aucun commentaire fourni'),
            'Modal comments payload should be French: ' + frList[0].Url_Param_Json__c
        );
    }

    @IsTest
    static void translate_emptyAndPayment() {
        System.assertEquals(
            0,
            LPI_PortalNotificationTranslator.translate(null, 'fr').size()
        );
        System.assertEquals(
            0,
            LPI_PortalNotificationTranslator.translate(new List<Notification__c>(), 'fr').size()
        );

        Notification__c payment = new Notification__c(
            Description__c = 'Your Payment is pending for IA-99.',
            Button_Label__c = 'Go To Payment',
            Navigate_Component_API_Name__c = 'payment-redirect'
        );
        List<Notification__c> outList = LPI_PortalNotificationTranslator.translate(
            new List<Notification__c>{ payment },
            'fr'
        );
        System.assert(
            outList[0].Description__c.toLowerCase().contains('paiement'),
            outList[0].Description__c
        );
        System.assertEquals('Aller au paiement', outList[0].Button_Label__c);
    }
}