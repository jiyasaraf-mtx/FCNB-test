/**
 * @description Seeds Atlantic Harbour Realty Inc dummy data for Agent Review Portal org admin pages.
 *              Run via: ARP_OrgAdminDataSeed.seed();
 */
public without sharing class ARP_OrgAdminDataSeed {

    public static final String COMPANY_NAME = 'Atlantic Harbour Realty Inc';
    private static final String LEGACY_COMPANY_NAME = 'Northstar Realty Group';
    private static final String DEFAULT_AGENT_PERMISSIONS =
        'Edit Personal Profile;View Sponsorship Status;Initiate New Applications;Upload Transaction Documents';
    private static final String DEFAULT_ADMIN_PERMISSIONS =
        'Edit Personal Profile;Manage Credentials & Licensing;View Sponsorship Status;Initiate New Applications;Upload Transaction Documents;Track Submission Progress;Manage Client Portfolios;Request Supervisor Sign-off';

    @AuraEnabled
    public static Id seed() {
        // Prefer renamed company; migrate legacy Northstar seed if present
        List<Account> existing = [
            SELECT Id, Name
            FROM Account
            WHERE Name = :COMPANY_NAME OR Name = :LEGACY_COMPANY_NAME
            ORDER BY CreatedDate DESC
            LIMIT 1
        ];
        Id accountId;
        if (!existing.isEmpty()) {
            accountId = existing[0].Id;
            if (existing[0].Name != COMPANY_NAME) {
                existing[0].Name = COMPANY_NAME;
                update existing[0];
            }
            delete [
                SELECT Id FROM ARP_Delegation_Activity__c WHERE Account__c = :accountId
            ];
            delete [
                SELECT Id FROM ARP_Organization_User__c WHERE Account__c = :accountId
            ];
            delete [
                SELECT Id FROM ARP_Branch__c WHERE Account__c = :accountId
            ];
            List<Contact> contacts = [
                SELECT Id FROM Contact WHERE AccountId = :accountId
            ];
            if (!contacts.isEmpty()) {
                delete contacts;
            }
        } else {
            Account acc = new Account(Name = COMPANY_NAME);
            // Prefer Business Account record type when present
            Map<String, Schema.RecordTypeInfo> rts = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName();
            if (rts.containsKey('Business_Account') && rts.get('Business_Account').isAvailable()) {
                acc.RecordTypeId = rts.get('Business_Account').getRecordTypeId();
            } else if (rts.containsKey('IndustriesBusiness') && rts.get('IndustriesBusiness').isAvailable()) {
                acc.RecordTypeId = rts.get('IndustriesBusiness').getRecordTypeId();
            }
            insert acc;
            accountId = acc.Id;
        }

        ARP_Branch__c head = new ARP_Branch__c(
            Account__c = accountId,
            Name = 'Head Office',
            Street_Address__c = '100 Main Street',
            Description__c = 'Primary administration',
            Is_Primary__c = true
        );
        ARP_Branch__c downtown = new ARP_Branch__c(
            Account__c = accountId,
            Name = 'Downtown Branch',
            Street_Address__c = '25 King Street',
            Description__c = 'Sales & review',
            Is_Primary__c = false
        );
        ARP_Branch__c westside = new ARP_Branch__c(
            Account__c = accountId,
            Name = 'Westside Branch',
            Street_Address__c = '88 Queen Avenue',
            Description__c = 'Sales',
            Is_Primary__c = false
        );
        insert new List<ARP_Branch__c>{ head, downtown, westside };

        Map<String, Contact> contactsByKey = new Map<String, Contact>();
        contactsByKey.put('alex', new Contact(AccountId = accountId, FirstName = 'Alex', LastName = 'Morgan', Email = 'alex.morgan@atlantic.com'));
        contactsByKey.put('emma', new Contact(AccountId = accountId, FirstName = 'Emma', LastName = 'Wilson', Email = 'emma.wilson@atlantic.com'));
        contactsByKey.put('daniel', new Contact(AccountId = accountId, FirstName = 'Daniel', LastName = 'Brooks', Email = 'daniel.brooks@atlantic.com'));
        contactsByKey.put('sophie', new Contact(AccountId = accountId, FirstName = 'Sophie', LastName = 'Martin', Email = 'sophie.martin@atlantic.com'));
        contactsByKey.put('liam', new Contact(AccountId = accountId, FirstName = 'Liam', LastName = 'Carter', Email = 'liam.carter@atlantic.com'));
        contactsByKey.put('olivia', new Contact(AccountId = accountId, FirstName = 'Olivia', LastName = 'Bennett', Email = 'olivia.bennett@atlantic.com'));
        contactsByKey.put('noah', new Contact(AccountId = accountId, FirstName = 'Noah', LastName = 'Thompson', Email = 'noah.thompson@atlantic.com'));
        contactsByKey.put('james', new Contact(AccountId = accountId, FirstName = 'James', LastName = 'Reed', Email = 'james.reed@atlantic.com'));
        contactsByKey.put('priya', new Contact(AccountId = accountId, FirstName = 'Priya', LastName = 'Nair', Email = 'priya.nair@atlantic.com'));
        insert contactsByKey.values();

        Datetime nowTs = System.now();
        List<ARP_Organization_User__c> orgUsers = new List<ARP_Organization_User__c>{
            buildUser(accountId, contactsByKey.get('alex'), head.Id, 'Company Administrator', 'Active', 'Own Access', null, null, 'NB-RE-ADMIN', DEFAULT_ADMIN_PERMISSIONS, false, nowTs.addHours(-2)),
            buildUser(accountId, contactsByKey.get('emma'), head.Id, 'Salesperson', 'Active', 'Own Access', null, null, 'NB-RE-10482', DEFAULT_AGENT_PERMISSIONS, false, nowTs.addMinutes(-40)),
            buildUser(accountId, contactsByKey.get('daniel'), westside.Id, 'Salesperson', 'Active', 'Own Access', null, null, 'NB-RE-11837', DEFAULT_AGENT_PERMISSIONS, false, nowTs.addHours(-1)),
            buildUser(accountId, contactsByKey.get('sophie'), downtown.Id, 'Salesperson', 'Active', 'Using Delegated Access', contactsByKey.get('liam').Id, null, 'NB-RE-12109', DEFAULT_AGENT_PERMISSIONS, false, nowTs.addDays(-1)),
            buildUser(accountId, contactsByKey.get('liam'), downtown.Id, 'Salesperson', 'Active', 'Own Access', null, contactsByKey.get('sophie').Id, 'NB-RE-09764', DEFAULT_AGENT_PERMISSIONS, false, nowTs.addDays(-1).addHours(-2)),
            buildUser(accountId, contactsByKey.get('olivia'), head.Id, 'Salesperson', 'Active', 'Own Access', null, null, 'NB-RE-11293', DEFAULT_AGENT_PERMISSIONS, false, nowTs.addDays(-3)),
            buildUser(accountId, contactsByKey.get('noah'), westside.Id, 'Salesperson', 'Inactive', 'Own Access', null, null, 'NB-RE-08931', DEFAULT_AGENT_PERMISSIONS, false, nowTs.addDays(-11)),
            buildUser(accountId, contactsByKey.get('james'), head.Id, 'Sponsored Agent', 'Active', 'Own Access', null, null, null, DEFAULT_AGENT_PERMISSIONS, true, nowTs.addDays(-2)),
            buildUser(accountId, contactsByKey.get('priya'), downtown.Id, 'Sponsored Agent', 'Active', 'Own Access', null, null, null, 'Edit Personal Profile;View Sponsorship Status;Track Submission Progress', true, nowTs.addDays(-2))
        };
        // Liam should show Delegated Out per HTML sample relationship with Sophie
        orgUsers[4].Access_Type__c = 'Delegated Out';
        insert orgUsers;

        List<ARP_Delegation_Activity__c> activities = new List<ARP_Delegation_Activity__c>{
            new ARP_Delegation_Activity__c(
                Account__c = accountId,
                From_Contact__c = contactsByKey.get('emma').Id,
                To_Contact__c = contactsByKey.get('daniel').Id,
                Reason__c = 'Vacation coverage',
                Status__c = 'Completed',
                Delegated_Date__c = Datetime.newInstance(2026, 9, 14, 18, 18, 0)
            ),
            new ARP_Delegation_Activity__c(
                Account__c = accountId,
                From_Contact__c = contactsByKey.get('liam').Id,
                To_Contact__c = contactsByKey.get('sophie').Id,
                Reason__c = 'Role coverage',
                Status__c = 'Completed',
                Delegated_Date__c = Datetime.newInstance(2026, 9, 12, 15, 44, 0)
            ),
            new ARP_Delegation_Activity__c(
                Account__c = accountId,
                From_Contact__c = contactsByKey.get('olivia').Id,
                To_Contact__c = contactsByKey.get('emma').Id,
                Reason__c = 'Temporary reassignment',
                Status__c = 'Completed',
                Delegated_Date__c = Datetime.newInstance(2026, 9, 10, 11, 6, 0)
            )
        };
        insert activities;

        return accountId;
    }

    private static ARP_Organization_User__c buildUser(
        Id accountId,
        Contact person,
        Id branchId,
        String role,
        String status,
        String accessType,
        Id delegatedFrom,
        Id delegatedTo,
        String license,
        String permissions,
        Boolean sponsored,
        Datetime lastActivity
    ) {
        String first = person != null && person.FirstName != null ? person.FirstName.trim() : '';
        String last = person != null && person.LastName != null ? person.LastName.trim() : '';
        String displayName = (first + ' ' + last).trim();
        return new ARP_Organization_User__c(
            Account__c = accountId,
            Contact__c = person != null ? person.Id : null,
            Branch__c = branchId,
            Role__c = role,
            Status__c = status,
            Access_Type__c = accessType,
            Delegated_From_Contact__c = delegatedFrom,
            Delegated_To_Contact__c = delegatedTo,
            Access_Since__c = accessType == 'Using Delegated Access' ? lastActivity : null,
            License_Number__c = license,
            Task_Permissions__c = permissions,
            Is_Sponsored_Agent__c = sponsored,
            Last_Activity__c = lastActivity,
            Person_Name__c = displayName,
            Person_Email__c = person != null ? person.Email : null
        );
    }
}