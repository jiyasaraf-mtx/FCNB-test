/**
 * @description Controller for Agent Review Portal organization administration pages.
 *              Uses typed @AuraEnabled DTOs so LWC receives list data in Experience Cloud.
 */
public without sharing class ARP_OrganizationAdminCtrl {

    private static final String CLASS_NAME = 'ARP_OrganizationAdminCtrl';
    private static final String DEMO_COMPANY_NAME = 'Atlantic Harbour Realty Inc';
    private static final String LEGACY_DEMO_COMPANY_NAME = 'Northstar Realty Group';
    public static final String DEFAULT_SPONSORED_PERMISSIONS =
        'Edit Personal Profile;View Sponsorship Status;Initiate New Applications;Upload Transaction Documents';

    public class DashboardDTO {
        @AuraEnabled public String companyName;
        @AuraEnabled public Integer portalUsers;
        @AuraEnabled public Integer activeUsers;
        @AuraEnabled public Integer branchCount;
        @AuraEnabled public Integer sponsoredCount;
        @AuraEnabled public List<ActivityDTO> recentDelegations;
        @AuraEnabled public List<OrgUserDTO> users;
    }

    public class OrgUserDTO {
        @AuraEnabled public Id id;
        @AuraEnabled public Id contactId;
        @AuraEnabled public String personName;
        @AuraEnabled public String emailAddress;
        @AuraEnabled public String company;
        @AuraEnabled public String role;
        @AuraEnabled public String status;
        @AuraEnabled public String accessType;
        @AuraEnabled public String license;
        @AuraEnabled public Id branchId;
        @AuraEnabled public String branch;
        @AuraEnabled public List<String> permissions;
        @AuraEnabled public String accessFrom;
        @AuraEnabled public String delegationTarget;
        @AuraEnabled public String accessSince;
        @AuraEnabled public String lastActivity;
        @AuraEnabled public Boolean isSponsored;
    }

    public class ActivityDTO {
        @AuraEnabled public Id id;
        @AuraEnabled public String dateLabel;
        @AuraEnabled public String fromPersonName;
        @AuraEnabled public String toPersonName;
        @AuraEnabled public String company;
        @AuraEnabled public String reason;
        @AuraEnabled public String status;
    }

    public class BranchDTO {
        @AuraEnabled public Id id;
        @AuraEnabled public String name;
        @AuraEnabled public String address;
        @AuraEnabled public String description;
        @AuraEnabled public Boolean isPrimary;
        @AuraEnabled public Integer userCount;
    }

    public class DelegateResultDTO {
        @AuraEnabled public String fromName;
        @AuraEnabled public String toName;
        @AuraEnabled public Id activityId;
    }

    @AuraEnabled
    public static DashboardDTO getDashboard() {
        try {
            Id accountId = resolveOrgAccountId();
            DashboardDTO result = new DashboardDTO();
            result.companyName = getAccountName(accountId);

            List<ARP_Organization_User__c> users = queryOrgUsers(accountId, false);
            Integer activeCount = 0;
            for (ARP_Organization_User__c u : users) {
                if (u.Status__c == 'Active') {
                    activeCount++;
                }
            }
            result.portalUsers = users.size();
            result.activeUsers = activeCount;
            result.branchCount = [
                SELECT COUNT() FROM ARP_Branch__c WHERE Account__c = :accountId
            ];
            result.sponsoredCount = [
                SELECT COUNT()
                FROM ARP_Organization_User__c
                WHERE Account__c = :accountId
                  AND Is_Sponsored_Agent__c = true
            ];
            result.recentDelegations = mapActivities(queryActivities(accountId, 3));
            result.users = mapUsers(users);
            return result;
        } catch (Exception ex) {
            throwAura(CLASS_NAME, 'getDashboard', ex);
            return null;
        }
    }

    @AuraEnabled
    public static List<OrgUserDTO> getOrganizationUsers() {
        try {
            return mapUsers(queryOrgUsers(resolveOrgAccountId(), false));
        } catch (Exception ex) {
            throwAura(CLASS_NAME, 'getOrganizationUsers', ex);
            return null;
        }
    }

    @AuraEnabled
    public static List<OrgUserDTO> getSponsoredAgents() {
        try {
            return mapUsers(queryOrgUsers(resolveOrgAccountId(), true));
        } catch (Exception ex) {
            throwAura(CLASS_NAME, 'getSponsoredAgents', ex);
            return null;
        }
    }

    @AuraEnabled
    public static List<BranchDTO> getBranches() {
        try {
            Id accountId = resolveOrgAccountId();
            List<BranchDTO> rows = new List<BranchDTO>();
            Map<Id, Integer> userCounts = new Map<Id, Integer>();
            for (AggregateResult ar : [
                SELECT Branch__c branchId, COUNT(Id) cnt
                FROM ARP_Organization_User__c
                WHERE Account__c = :accountId AND Branch__c != null
                GROUP BY Branch__c
            ]) {
                userCounts.put((Id) ar.get('branchId'), (Integer) ar.get('cnt'));
            }
            for (ARP_Branch__c b : [
                SELECT Id, Name, Street_Address__c, Description__c, Is_Primary__c
                FROM ARP_Branch__c
                WHERE Account__c = :accountId
                ORDER BY Is_Primary__c DESC, Name ASC
            ]) {
                BranchDTO row = new BranchDTO();
                row.id = b.Id;
                row.name = b.Name;
                row.address = b.Street_Address__c;
                row.description = b.Description__c;
                row.isPrimary = b.Is_Primary__c;
                row.userCount = userCounts.containsKey(b.Id) ? userCounts.get(b.Id) : 0;
                rows.add(row);
            }
            return rows;
        } catch (Exception ex) {
            throwAura(CLASS_NAME, 'getBranches', ex);
            return null;
        }
    }

    @AuraEnabled
    public static List<ActivityDTO> getDelegationActivity() {
        try {
            return mapActivities(queryActivities(resolveOrgAccountId(), 50));
        } catch (Exception ex) {
            throwAura(CLASS_NAME, 'getDelegationActivity', ex);
            return null;
        }
    }

    @AuraEnabled
    public static void updateUserStatus(Id organizationUserId, String status) {
        try {
            validateStatus(status);
            ARP_Organization_User__c row = [
                SELECT Id, Status__c, Account__c
                FROM ARP_Organization_User__c
                WHERE Id = :organizationUserId
                LIMIT 1
            ];
            assertSameOrg(row.Account__c);
            row.Status__c = status;
            row.Last_Activity__c = System.now();
            update row;
        } catch (Exception ex) {
            throwAura(CLASS_NAME, 'updateUserStatus', ex);
        }
    }

    @AuraEnabled
    public static void updateOrganizationUser(
        Id organizationUserId,
        String role,
        String status,
        Id branchId,
        String taskPermissions
    ) {
        try {
            ARP_Organization_User__c row = [
                SELECT Id, Account__c, Role__c, Status__c, Branch__c, Task_Permissions__c
                FROM ARP_Organization_User__c
                WHERE Id = :organizationUserId
                LIMIT 1
            ];
            assertSameOrg(row.Account__c);
            if (String.isNotBlank(role)) {
                row.Role__c = role;
            }
            if (String.isNotBlank(status)) {
                validateStatus(status);
                row.Status__c = status;
            }
            row.Branch__c = branchId;
            row.Task_Permissions__c = String.isBlank(taskPermissions)
                ? null
                : taskPermissions.replace('; ', ';');
            row.Last_Activity__c = System.now();
            update row;
        } catch (Exception ex) {
            throwAura(CLASS_NAME, 'updateOrganizationUser', ex);
        }
    }

    @AuraEnabled
    public static DelegateResultDTO delegateAccess(
        Id fromOrganizationUserId,
        Id toOrganizationUserId,
        String reason
    ) {
        try {
            Id accountId = resolveOrgAccountId();
            ARP_Organization_User__c fromUser = [
                SELECT Id, Account__c, Contact__c, Contact__r.Name, Status__c, Access_Type__c,
                       Delegated_To_Contact__c, Last_Activity__c
                FROM ARP_Organization_User__c
                WHERE Id = :fromOrganizationUserId AND Account__c = :accountId
                LIMIT 1
            ];
            ARP_Organization_User__c toUser = [
                SELECT Id, Account__c, Contact__c, Contact__r.Name, Status__c, Access_Type__c,
                       Delegated_From_Contact__c, Access_Since__c, Last_Activity__c
                FROM ARP_Organization_User__c
                WHERE Id = :toOrganizationUserId AND Account__c = :accountId
                LIMIT 1
            ];
            if (fromUser.Id == toUser.Id) {
                throw new AuraHandledException('Cannot delegate access to the same user.');
            }
            if (toUser.Status__c != 'Active') {
                throw new AuraHandledException('Receiving salesperson must be Active.');
            }

            Datetime nowTs = System.now();
            fromUser.Status__c = 'Inactive';
            fromUser.Access_Type__c = 'Delegated Out';
            fromUser.Delegated_To_Contact__c = toUser.Contact__c;
            fromUser.Last_Activity__c = nowTs;

            toUser.Status__c = 'Active';
            toUser.Access_Type__c = 'Using Delegated Access';
            toUser.Delegated_From_Contact__c = fromUser.Contact__c;
            toUser.Access_Since__c = nowTs;
            toUser.Last_Activity__c = nowTs;

            update new List<ARP_Organization_User__c>{ fromUser, toUser };

            ARP_Delegation_Activity__c activity = new ARP_Delegation_Activity__c(
                Account__c = accountId,
                From_Contact__c = fromUser.Contact__c,
                To_Contact__c = toUser.Contact__c,
                Reason__c = String.isBlank(reason) ? 'Not provided' : reason.trim(),
                Status__c = 'Completed',
                Delegated_Date__c = nowTs
            );
            insert activity;

            DelegateResultDTO result = new DelegateResultDTO();
            Map<Id, Contact> names = loadContactsById(new Set<Id>{ fromUser.Contact__c, toUser.Contact__c });
            result.fromName = contactDisplayName(names.get(fromUser.Contact__c));
            result.toName = contactDisplayName(names.get(toUser.Contact__c));
            result.activityId = activity.Id;
            return result;
        } catch (Exception ex) {
            throwAura(CLASS_NAME, 'delegateAccess', ex);
            return null;
        }
    }

    /**
     * Revokes a prior delegation: original holder returns to Active / Own Access,
     * and the receiving user returns to Own Access.
     */
    @AuraEnabled
    public static void revokeAccess(Id organizationUserId) {
        try {
            Id accountId = resolveOrgAccountId();
            ARP_Organization_User__c holder = [
                SELECT Id, Account__c, Contact__c, Status__c, Access_Type__c,
                       Delegated_To_Contact__c, Last_Activity__c
                FROM ARP_Organization_User__c
                WHERE Id = :organizationUserId AND Account__c = :accountId
                LIMIT 1
            ];
            if (holder.Access_Type__c != 'Delegated Out' || holder.Delegated_To_Contact__c == null) {
                throw new AuraHandledException('Only delegated-out access can be revoked.');
            }

            Id delegatedToContactId = holder.Delegated_To_Contact__c;
            Datetime nowTs = System.now();
            List<ARP_Organization_User__c> toUpdate = new List<ARP_Organization_User__c>();

            holder.Status__c = 'Active';
            holder.Access_Type__c = 'Own Access';
            holder.Delegated_To_Contact__c = null;
            holder.Last_Activity__c = nowTs;
            toUpdate.add(holder);

            List<ARP_Organization_User__c> receiverRows = [
                SELECT Id, Status__c, Access_Type__c, Delegated_From_Contact__c,
                       Access_Since__c, Last_Activity__c, Contact__c
                FROM ARP_Organization_User__c
                WHERE Account__c = :accountId
                  AND Contact__c = :delegatedToContactId
                LIMIT 1
            ];
            if (!receiverRows.isEmpty()) {
                ARP_Organization_User__c receiver = receiverRows[0];
                if (receiver.Access_Type__c == 'Using Delegated Access'
                    || receiver.Delegated_From_Contact__c == holder.Contact__c) {
                    receiver.Access_Type__c = 'Own Access';
                    receiver.Delegated_From_Contact__c = null;
                    receiver.Access_Since__c = null;
                    receiver.Status__c = 'Active';
                    receiver.Last_Activity__c = nowTs;
                    toUpdate.add(receiver);
                }
            }

            update toUpdate;
        } catch (Exception ex) {
            throwAura(CLASS_NAME, 'revokeAccess', ex);
        }
    }

    @AuraEnabled
    public static Id createBranch(String name, String address, String description) {
        try {
            if (String.isBlank(name)) {
                throw new AuraHandledException('Branch name is required.');
            }
            ARP_Branch__c branch = new ARP_Branch__c(
                Account__c = resolveOrgAccountId(),
                Name = name.trim(),
                Street_Address__c = address,
                Description__c = description,
                Is_Primary__c = false
            );
            insert branch;
            return branch.Id;
        } catch (Exception ex) {
            throwAura(CLASS_NAME, 'createBranch', ex);
            return null;
        }
    }

    @AuraEnabled
    public static void deleteBranch(Id branchId) {
        try {
            if (branchId == null) {
                throw new AuraHandledException('Branch is required.');
            }
            Id accountId = resolveOrgAccountId();
            List<ARP_Branch__c> branches = [
                SELECT Id, Account__c, Name
                FROM ARP_Branch__c
                WHERE Id = :branchId
                LIMIT 1
            ];
            if (branches.isEmpty()) {
                throw new AuraHandledException('Branch was not found or was already removed.');
            }
            ARP_Branch__c branch = branches[0];
            if (branch.Account__c != accountId) {
                throw new AuraHandledException('Branch does not belong to your organization.');
            }

            // Clear assignments first (lookup is SetNull on delete, but explicit clear
            // avoids portal CRUD surprises on related user rows).
            List<ARP_Organization_User__c> assignedUsers = [
                SELECT Id, Branch__c
                FROM ARP_Organization_User__c
                WHERE Account__c = :accountId AND Branch__c = :branchId
            ];
            if (!assignedUsers.isEmpty()) {
                for (ARP_Organization_User__c row : assignedUsers) {
                    row.Branch__c = null;
                }
                Database.update(assignedUsers, AccessLevel.SYSTEM_MODE);
            }
            Database.delete(branch, AccessLevel.SYSTEM_MODE);
        } catch (Exception ex) {
            throwAura(CLASS_NAME, 'deleteBranch', ex);
        }
    }

    @AuraEnabled
    public static Id createSponsoredAgent(
        String firstName,
        String lastName,
        String email,
        Id branchId,
        String taskPermissions
    ) {
        try {
            if (String.isBlank(firstName) || String.isBlank(lastName)) {
                throw new AuraHandledException('Agent first and last name are required.');
            }
            Id accountId = resolveOrgAccountId();
            Contact con = new Contact(
                AccountId = accountId,
                FirstName = firstName.trim(),
                LastName = lastName.trim(),
                Email = email
            );
            insert con;

            ARP_Organization_User__c orgUser = new ARP_Organization_User__c(
                Account__c = accountId,
                Contact__c = con.Id,
                Branch__c = branchId,
                Role__c = 'Sponsored Agent',
                Status__c = 'Active',
                Access_Type__c = 'Own Access',
                Is_Sponsored_Agent__c = true,
                Person_Name__c = (firstName.trim() + ' ' + lastName.trim()).trim(),
                Person_Email__c = email,
                Task_Permissions__c = String.isBlank(taskPermissions)
                    ? DEFAULT_SPONSORED_PERMISSIONS
                    : taskPermissions.replace('; ', ';'),
                Last_Activity__c = System.now()
            );
            insert orgUser;
            return orgUser.Id;
        } catch (Exception ex) {
            throwAura(CLASS_NAME, 'createSponsoredAgent', ex);
            return null;
        }
    }

    @TestVisible
    private static Id resolveOrgAccountId() {
        User u = [
            SELECT Id, AccountId, ContactId, Contact.AccountId
            FROM User
            WHERE Id = :UserInfo.getUserId()
            LIMIT 1
        ];
        Id accountId = u.AccountId != null
            ? u.AccountId
            : (u.Contact != null ? u.Contact.AccountId : null);

        if (accountId != null) {
            List<Account> acc = [
                SELECT Id, SelectedAccountId__c
                FROM Account
                WHERE Id = :accountId
                LIMIT 1
            ];
            if (!acc.isEmpty() && acc[0].SelectedAccountId__c != null) {
                accountId = acc[0].SelectedAccountId__c;
            }
            Integer orgUserCount = [
                SELECT COUNT()
                FROM ARP_Organization_User__c
                WHERE Account__c = :accountId
            ];
            if (orgUserCount > 0) {
                return accountId;
            }
        }

        // Fall back to seeded demo org when the current account has no ARP data
        List<Account> seeded = [
            SELECT Id, Name
            FROM Account
            WHERE Name = :DEMO_COMPANY_NAME OR Name = :LEGACY_DEMO_COMPANY_NAME
            ORDER BY CreatedDate DESC
            LIMIT 1
        ];
        if (!seeded.isEmpty()) {
            if (seeded[0].Name != DEMO_COMPANY_NAME) {
                seeded[0].Name = DEMO_COMPANY_NAME;
                update seeded[0];
            }
            return seeded[0].Id;
        }
        if (accountId != null) {
            return accountId;
        }
        throw new AuraHandledException('No organization account found for the current user.');
    }

    private static void assertSameOrg(Id accountId) {
        if (accountId != resolveOrgAccountId()) {
            throw new AuraHandledException('Record does not belong to your organization.');
        }
    }

    private static String getAccountName(Id accountId) {
        List<Account> rows = [SELECT Name FROM Account WHERE Id = :accountId LIMIT 1];
        return rows.isEmpty() ? '' : rows[0].Name;
    }

    private static List<ARP_Organization_User__c> queryOrgUsers(Id accountId, Boolean sponsoredOnly) {
        String soql =
            'SELECT Id, Role__c, Status__c, Access_Type__c, License_Number__c, Task_Permissions__c, ' +
            'Access_Since__c, Last_Activity__c, Is_Sponsored_Agent__c, Branch__c, Branch__r.Name, ' +
            'Contact__c, Delegated_From_Contact__c, Delegated_To_Contact__c, Account__r.Name, ' +
            'Person_Name__c, Person_Email__c ' +
            'FROM ARP_Organization_User__c WHERE Account__c = :accountId ';
        if (sponsoredOnly == true) {
            soql += 'AND Is_Sponsored_Agent__c = true ';
        }
        soql += 'ORDER BY Person_Name__c ASC NULLS LAST, License_Number__c ASC NULLS LAST';
        return Database.query(soql);
    }

    private static List<ARP_Delegation_Activity__c> queryActivities(Id accountId, Integer lim) {
        return [
            SELECT Id, Reason__c, Status__c, Delegated_Date__c, Account__r.Name,
                   From_Contact__c, To_Contact__c
            FROM ARP_Delegation_Activity__c
            WHERE Account__c = :accountId
            ORDER BY Delegated_Date__c DESC NULLS LAST
            LIMIT :lim
        ];
    }

    /**
     * Portal users often cannot read Contact records. Prefer denormalized Person_Name__c,
     * then names from other org-user rows, then a without-sharing Contact query.
     */
    private static Map<Id, Contact> loadContactsById(Set<Id> contactIds) {
        Map<Id, Contact> byId = new Map<Id, Contact>();
        if (contactIds == null || contactIds.isEmpty()) {
            return byId;
        }
        contactIds.remove(null);
        if (contactIds.isEmpty()) {
            return byId;
        }
        for (Contact c : [
            SELECT Id, Name, Email, FirstName, LastName
            FROM Contact
            WHERE Id IN :contactIds
        ]) {
            byId.put(c.Id, c);
        }
        return byId;
    }

    private static Map<Id, String> loadPersonNamesByContact(Set<Id> contactIds) {
        Map<Id, String> byContactId = new Map<Id, String>();
        if (contactIds == null || contactIds.isEmpty()) {
            return byContactId;
        }
        contactIds.remove(null);
        if (contactIds.isEmpty()) {
            return byContactId;
        }
        for (ARP_Organization_User__c row : [
            SELECT Contact__c, Person_Name__c
            FROM ARP_Organization_User__c
            WHERE Contact__c IN :contactIds
              AND Person_Name__c != null
        ]) {
            byContactId.put(row.Contact__c, row.Person_Name__c);
        }
        Map<Id, Contact> contacts = loadContactsById(contactIds);
        for (Id contactId : contactIds) {
            if (byContactId.containsKey(contactId) && String.isNotBlank(byContactId.get(contactId))) {
                continue;
            }
            String display = contactDisplayName(contacts.get(contactId));
            if (String.isNotBlank(display)) {
                byContactId.put(contactId, display);
            }
        }
        return byContactId;
    }

    private static String contactDisplayName(Contact c) {
        if (c == null) {
            return '';
        }
        if (String.isNotBlank(c.Name)) {
            return c.Name;
        }
        String first = c.FirstName == null ? '' : c.FirstName.trim();
        String last = c.LastName == null ? '' : c.LastName.trim();
        return (first + ' ' + last).trim();
    }

    private static List<OrgUserDTO> mapUsers(List<ARP_Organization_User__c> users) {
        Set<Id> contactIds = new Set<Id>();
        for (ARP_Organization_User__c u : users) {
            contactIds.add(u.Contact__c);
            contactIds.add(u.Delegated_From_Contact__c);
            contactIds.add(u.Delegated_To_Contact__c);
        }
        Map<Id, String> namesByContact = loadPersonNamesByContact(contactIds);
        Map<Id, Contact> contactsById = loadContactsById(contactIds);

        List<OrgUserDTO> rows = new List<OrgUserDTO>();
        for (ARP_Organization_User__c u : users) {
            List<String> permissions = new List<String>();
            if (String.isNotBlank(u.Task_Permissions__c)) {
                for (String p : u.Task_Permissions__c.split(';')) {
                    if (String.isNotBlank(p)) {
                        permissions.add(p.trim());
                    }
                }
            }
            Contact person = contactsById.get(u.Contact__c);
            String personName = String.isNotBlank(u.Person_Name__c)
                ? u.Person_Name__c
                : namesByContact.get(u.Contact__c);
            if (String.isBlank(personName)) {
                personName = contactDisplayName(person);
            }
            String emailAddress = String.isNotBlank(u.Person_Email__c)
                ? u.Person_Email__c
                : (person != null ? person.Email : '');

            OrgUserDTO row = new OrgUserDTO();
            row.id = u.Id;
            row.contactId = u.Contact__c;
            row.personName = personName == null ? '' : personName;
            row.emailAddress = emailAddress == null ? '' : emailAddress;
            row.company = u.Account__r != null ? u.Account__r.Name : '';
            row.role = u.Role__c;
            row.status = u.Status__c;
            row.accessType = u.Access_Type__c;
            row.license = u.License_Number__c;
            row.branchId = u.Branch__c;
            row.branch = u.Branch__r != null ? u.Branch__r.Name : '';
            row.permissions = permissions;
            row.accessFrom = namesByContact.containsKey(u.Delegated_From_Contact__c)
                ? namesByContact.get(u.Delegated_From_Contact__c)
                : '';
            row.delegationTarget = namesByContact.containsKey(u.Delegated_To_Contact__c)
                ? namesByContact.get(u.Delegated_To_Contact__c)
                : '';
            row.accessSince = u.Access_Since__c != null ? u.Access_Since__c.format() : '';
            row.lastActivity = u.Last_Activity__c != null ? u.Last_Activity__c.format() : '';
            row.isSponsored = u.Is_Sponsored_Agent__c == true;
            rows.add(row);
        }
        return rows;
    }

    private static List<ActivityDTO> mapActivities(List<ARP_Delegation_Activity__c> activities) {
        Set<Id> contactIds = new Set<Id>();
        for (ARP_Delegation_Activity__c a : activities) {
            contactIds.add(a.From_Contact__c);
            contactIds.add(a.To_Contact__c);
        }
        Map<Id, String> namesByContact = loadPersonNamesByContact(contactIds);

        List<ActivityDTO> rows = new List<ActivityDTO>();
        for (ARP_Delegation_Activity__c a : activities) {
            ActivityDTO row = new ActivityDTO();
            row.id = a.Id;
            row.dateLabel = a.Delegated_Date__c != null ? a.Delegated_Date__c.format() : '';
            row.fromPersonName = namesByContact.containsKey(a.From_Contact__c)
                ? namesByContact.get(a.From_Contact__c)
                : '';
            row.toPersonName = namesByContact.containsKey(a.To_Contact__c)
                ? namesByContact.get(a.To_Contact__c)
                : '';
            row.company = a.Account__r != null ? a.Account__r.Name : '';
            row.reason = a.Reason__c;
            row.status = a.Status__c;
            rows.add(row);
        }
        return rows;
    }

    private static void validateStatus(String status) {
        Set<String> allowed = new Set<String>{ 'Active', 'Inactive', 'Suspended' };
        if (!allowed.contains(status)) {
            throw new AuraHandledException('Invalid status value.');
        }
    }

    private static void throwAura(String className, String methodName, Exception ex) {
        LPI_ExceptionManager.logException(className, methodName, ex);
        String message = ex.getMessage();
        if (ex instanceof DmlException) {
            message = ((DmlException) ex).getDmlMessage(0);
        }
        if (String.isBlank(message) || message == 'Script-thrown exception') {
            message = 'Unable to save. Please try again or contact your administrator.';
        }
        AuraHandledException auraEx = new AuraHandledException(message);
        auraEx.setMessage(message);
        throw auraEx;
    }
}