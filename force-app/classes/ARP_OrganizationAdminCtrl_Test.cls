@IsTest
private class ARP_OrganizationAdminCtrl_Test {

    @TestSetup
    static void setupData() {
        Account company = new Account(Name = 'Atlantic Harbour Realty Inc');
        insert company;

        Contact adminContact = new Contact(
            AccountId = company.Id,
            FirstName = 'Test',
            LastName = 'Admin',
            Email = 'test.admin@atlanticharbour.test'
        );
        Contact salesContact = new Contact(
            AccountId = company.Id,
            FirstName = 'Test',
            LastName = 'Sales',
            Email = 'test.sales@atlanticharbour.test'
        );
        insert new List<Contact>{ adminContact, salesContact };

        ARP_Branch__c branch = new ARP_Branch__c(
            Account__c = company.Id,
            Name = 'Head Office',
            Street_Address__c = '100 Main',
            Is_Primary__c = true
        );
        insert branch;

        insert new List<ARP_Organization_User__c>{
            new ARP_Organization_User__c(
                Account__c = company.Id,
                Contact__c = adminContact.Id,
                Branch__c = branch.Id,
                Role__c = 'Company Administrator',
                Status__c = 'Active',
                Access_Type__c = 'Own Access',
                License_Number__c = 'NB-ADMIN',
                Task_Permissions__c = 'Edit Personal Profile;Manage Credentials & Licensing',
                Person_Name__c = 'Test Admin',
                Person_Email__c = 'test.admin@atlanticharbour.test',
                Last_Activity__c = System.now()
            ),
            new ARP_Organization_User__c(
                Account__c = company.Id,
                Contact__c = salesContact.Id,
                Branch__c = branch.Id,
                Role__c = 'Salesperson',
                Status__c = 'Active',
                Access_Type__c = 'Own Access',
                License_Number__c = 'NB-SALES',
                Task_Permissions__c = 'View Sponsorship Status;Initiate New Applications',
                Person_Name__c = 'Test Sales',
                Person_Email__c = 'test.sales@atlanticharbour.test',
                Last_Activity__c = System.now()
            )
        };

        insert new ARP_Delegation_Activity__c(
            Account__c = company.Id,
            From_Contact__c = adminContact.Id,
            To_Contact__c = salesContact.Id,
            Reason__c = 'Coverage',
            Status__c = 'Completed',
            Delegated_Date__c = System.now()
        );
    }

    @IsTest
    static void dashboard_returnsSeededRows() {
        Test.startTest();
        ARP_OrganizationAdminCtrl.DashboardDTO dash = ARP_OrganizationAdminCtrl.getDashboard();
        List<ARP_OrganizationAdminCtrl.OrgUserDTO> users = ARP_OrganizationAdminCtrl.getOrganizationUsers();
        List<ARP_OrganizationAdminCtrl.ActivityDTO> activities = ARP_OrganizationAdminCtrl.getDelegationActivity();
        List<ARP_OrganizationAdminCtrl.BranchDTO> branches = ARP_OrganizationAdminCtrl.getBranches();
        Test.stopTest();

        System.assertEquals('Atlantic Harbour Realty Inc', dash.companyName);
        System.assert(dash.portalUsers >= 2, 'Expected portal users');
        System.assert(!dash.recentDelegations.isEmpty(), 'Expected recent delegations');
        System.assert(users.size() >= 2, 'Expected org users');
        System.assert(!activities.isEmpty(), 'Expected activities');
        System.assert(!branches.isEmpty(), 'Expected branches');
        System.assertNotEquals(null, users[0].personName);
        System.assertNotEquals(null, activities[0].dateLabel);
        System.assert(String.isNotBlank(users[0].personName), 'Expected person name');
        System.assert(String.isNotBlank(activities[0].fromPersonName), 'Expected from name');
    }

    @IsTest
    static void deleteBranch_unassignsUsersAndRemovesBranch() {
        ARP_Branch__c branch = [
            SELECT Id FROM ARP_Branch__c WHERE Name = 'Head Office' LIMIT 1
        ];
        Integer beforeCount = [SELECT COUNT() FROM ARP_Branch__c];

        Test.startTest();
        ARP_OrganizationAdminCtrl.deleteBranch(branch.Id);
        Test.stopTest();

        System.assertEquals(
            beforeCount - 1,
            [SELECT COUNT() FROM ARP_Branch__c],
            'Branch should be deleted'
        );
        System.assertEquals(
            0,
            [SELECT COUNT() FROM ARP_Organization_User__c WHERE Branch__c = :branch.Id],
            'Users should be unassigned from deleted branch'
        );
    }
}
