/**
 * @description v38: helper for the LPI Portal Agent that grants the
 *              signed-in portal user access to the PreliminaryApplicationRef
 *              records the bot creates. Solves the
 *              "insufficient access rights on object id" error users hit
 *              on the intake form because the PAR is owned by the
 *              Einstein Agent service user (the messaging session never
 *              carries a real Contact Id, so the bot cannot set OwnerId
 *              correctly at insert time).
 *
 *              Strategy:
 *                * On PAR insert, share the record with the configured
 *                  public group of authorized portal users (default
 *                  group developer name: `LPI_Portal_Authorized_Users`)
 *                  via Apex Managed Sharing with Edit access.
 *                * If the public group is missing, fall back to a
 *                  no-op so behaviour does not regress for orgs that
 *                  have not configured the group yet (logged once
 *                  per transaction so the admin can find the warning).
 *                * The OmniScript hosting the intake form runs without
 *                  sharing for reads, so the user could already see the
 *                  PAR; we add Edit access so the submit DML succeeds.
 *
 *              Future work: replace this with Embedded Service
 *              Conversation Identity Verification so the messaging
 *              runtime supplies the portal user's ContactId and we can
 *              set OwnerId/BusinessAccountNameId/Contact__c at insert
 *              time. Once that is in place, this class can be deleted.
 */
public with sharing class LPI_PortalAgentClaim {

    private static final String CLASS_NAME = 'LPI_PortalAgentClaim';

    /**
     * @description Developer name of the public group that should be
     *              granted Edit access on every agent-created PAR.
     *              Admins must create this group manually (or via a
     *              one-off setup script) and add every authorized
     *              portal user to it. The group lookup is cached for
     *              the duration of the transaction so we never issue
     *              more than one SOQL for it per request.
     */
    public static final String AUTHORIZED_GROUP_DEVELOPER_NAME = 'LPI_Portal_Authorized_Users';

    /**
     * @description v38: TestVisible override of the developer name used
     *              for the lookup. Setup objects (Group) leak into Apex
     *              tests even without SeeAllData, so individual tests
     *              substitute a unique developer name to fully control
     *              whether the group is found.
     */
    @TestVisible
    private static String groupDeveloperNameOverride;

    private static Id cachedAuthorizedGroupId;
    private static Boolean groupLookupAttempted = false;

    /**
     * @description v39: result of a claim attempt by the portal user.
     *              `claimed` is true when this call performed the
     *              ownership transfer; false when the PAR was already
     *              owned by someone other than the bot (legitimate
     *              admin reassignment, or another user already
     *              claimed it). `ownerId` is the post-call OwnerId so
     *              the wrapper page can decide whether to grant the
     *              redirect.
     */
    public class ClaimResult {
        @AuraEnabled public Boolean claimed;
        @AuraEnabled public Id parId;
        @AuraEnabled public Id ownerId;
        @AuraEnabled public Id contactId;
        @AuraEnabled public Id accountId;
        @AuraEnabled public String errorMessage;
        /**
         * @description v39.3: full OmniScript URL the bot stored on the
         *              PAR at insert time (`SavedApplicationUrl`). The
         *              `lpiAgentParAutoClaim` LWC reads this off the
         *              claim result so the bot URL no longer needs to
         *              ferry the original `c__target` value through a
         *              `c__realTarget` query param. Carrying that
         *              param made the chat link long enough (and the
         *              substring "target=" suspicious enough) that the
         *              Adaptive Response post-processor stripped the
         *              link from the rendered Markdown entirely. With
         *              this field populated the bot URL stays the
         *              same shape as the long-working v37 community
         *              URL (only `c__target` swapped to the auto-claim
         *              LWC), which the post-processor leaves alone.
         */
        @AuraEnabled public String savedApplicationUrl;
        public ClaimResult() {
            this.claimed = false;
        }
    }

    /**
     * @description v39: claim ownership of an agent-created PAR for
     *              the running portal user. Designed to be invoked
     *              from the LPIAgentParClaim wrapper page and from
     *              `@AuraEnabled` LWC contexts. Idempotent:
     *                * if PAR is already owned by a non-bot user,
     *                  returns claimed=false and the existing OwnerId
     *                  so the caller can still redirect.
     *                * if PAR is owned by the bot AND the running
     *                  user has a ContactId, transfers OwnerId,
     *                  populates Contact__c and BusinessAccountNameId
     *                  if blank, and returns claimed=true.
     *                * if the running user is internal (no ContactId),
     *                  returns claimed=false with errorMessage so the
     *                  caller can decide whether to redirect anyway.
     *
     *              The DML is performed in SYSTEM_MODE to bypass FLS
     *              (the portal-user permission set does not grant
     *              edit on every PAR field) but explicitly bypasses
     *              the trigger handler so we don't fight the v38
     *              auto-claim hook.
     */
    @AuraEnabled
    public static ClaimResult claimAgentInitiatedPar(Id parId) {
        ClaimResult res = new ClaimResult();
        res.parId = parId;
        if (parId == null) {
            res.errorMessage = 'parId is required';
            return res;
        }
        try {
            Id parIdParam = parId;
            List<PreliminaryApplicationRef> rows = (List<PreliminaryApplicationRef>) Database.query(
                'SELECT Id, OwnerId, Contact__c, BusinessAccountNameId, SavedApplicationUrl '
                + 'FROM PreliminaryApplicationRef '
                + 'WHERE Id = :parIdParam LIMIT 1',
                System.AccessLevel.SYSTEM_MODE
            );
            if (rows.isEmpty()) {
                res.errorMessage = 'PAR not found or not accessible';
                return res;
            }
            PreliminaryApplicationRef par = rows[0];
            res.ownerId = par.OwnerId;
            res.contactId = par.Contact__c;
            res.accountId = par.BusinessAccountNameId;
            res.savedApplicationUrl = par.SavedApplicationUrl;

            // Already owned by a non-bot user (e.g. previous claim,
            // admin reassignment): nothing to do, but signal success
            // so the caller still redirects. Checked BEFORE the
            // ContactId guard so legitimate idempotent calls and
            // admin-debug clicks both return cleanly without an
            // errorMessage.
            if (!isBotOwner(par.OwnerId)) {
                res.claimed = false;
                res.errorMessage = null;
                return res;
            }

            // Look up the running user's identity. Standard internal
            // users have no ContactId/AccountId; we can't claim for
            // them, but we still let the redirect proceed because an
            // internal admin clicking a debug link is fine.
            Id runningUserId = UserInfo.getUserId();
            User running;
            try {
                running = [
                    SELECT Id, ContactId, AccountId, IsActive
                    FROM User WHERE Id = :runningUserId LIMIT 1
                ];
            } catch (Exception ex) {
                LPI_ExceptionManager.logException(CLASS_NAME,
                    'claimAgentInitiatedPar.userLookup', ex);
            }
            if (running == null || running.ContactId == null) {
                res.errorMessage = 'Running user has no ContactId; cannot claim. '
                    + 'This is expected for internal admin sessions.';
                return res;
            }

            par.OwnerId = runningUserId;
            if (par.Contact__c == null) { par.Contact__c = running.ContactId; }
            if (par.BusinessAccountNameId == null) { par.BusinessAccountNameId = running.AccountId; }
            // Bypass the v38 auto-claim trigger hook so we don't
            // re-process this update inside the trigger; we already
            // know the right values.
            LPI_TriggerHandler.bypass('PreliminaryApplicationTriggerHandler');
            try {
                Database.update(par, System.AccessLevel.SYSTEM_MODE);
            } finally {
                LPI_TriggerHandler.clearBypass('PreliminaryApplicationTriggerHandler');
            }
            res.claimed = true;
            res.ownerId = par.OwnerId;
            res.contactId = par.Contact__c;
            res.accountId = par.BusinessAccountNameId;
            return res;
        } catch (Exception e) {
            LPI_ExceptionManager.logException(CLASS_NAME, 'claimAgentInitiatedPar', e);
            res.errorMessage = e.getMessage();
            return res;
        }
    }

    /**
     * @description v39: TestVisible override for the bot user-id set
     *              consulted by claimAgentInitiatedPar. Tests inject a
     *              synthetic User Id; production resolves the
     *              "Einstein Agent User" profile.
     */
    @TestVisible
    private static Set<Id> claimBotUserIdOverride;
    private static Set<Id> cachedBotUserIds;
    private static Boolean botUserCacheInit = false;
    private static Boolean isBotOwner(Id ownerId) {
        if (claimBotUserIdOverride != null) {
            return claimBotUserIdOverride.contains(ownerId);
        }
        if (!botUserCacheInit) {
            botUserCacheInit = true;
            cachedBotUserIds = new Set<Id>();
            try {
                for (User u : [
                    SELECT Id FROM User
                    WHERE Profile.Name = 'Einstein Agent User' AND IsActive = true
                ]) {
                    cachedBotUserIds.add(u.Id);
                }
            } catch (Exception e) {
                LPI_ExceptionManager.logException(CLASS_NAME, 'isBotOwner', e);
            }
        }
        return cachedBotUserIds.contains(ownerId);
    }

    /**
     * @description Adds an Apex Managed Sharing row granting Edit
     *              access on the supplied PAR record to the configured
     *              public group of authorized portal users. Idempotent:
     *              an existing share row for the same parent + group
     *              is not duplicated. Best-effort: any failure is
     *              logged via LPI_ExceptionManager and swallowed so the
     *              caller's primary insert/update is never blocked by
     *              the sharing hand-off.
     */
    public static void shareWithAuthorizedPortalUsers(Id parId) {
        if (parId == null) { return; }
        try {
            Id groupId = resolveAuthorizedGroupId();
            if (groupId == null) {
                return;
            }
            Id parIdParam = parId;
            Id groupIdParam = groupId;
            List<PreliminaryApplicationRefShare> existing = (List<PreliminaryApplicationRefShare>) Database.query(
                'SELECT Id, AccessLevel FROM PreliminaryApplicationRefShare '
                + 'WHERE ParentId = :parIdParam AND UserOrGroupId = :groupIdParam '
                + 'AND RowCause = \'Manual\' LIMIT 1',
                System.AccessLevel.SYSTEM_MODE
            );
            if (!existing.isEmpty()) {
                if (existing[0].AccessLevel != 'Edit') {
                    PreliminaryApplicationRefShare patch = existing[0];
                    patch.AccessLevel = 'Edit';
                    Database.update(patch, System.AccessLevel.SYSTEM_MODE);
                }
                return;
            }
            PreliminaryApplicationRefShare share = new PreliminaryApplicationRefShare();
            share.ParentId = parId;
            share.UserOrGroupId = groupId;
            share.AccessLevel = 'Edit';
            share.RowCause = Schema.PreliminaryApplicationRefShare.RowCause.Manual;
            Database.insert(share, System.AccessLevel.SYSTEM_MODE);
        } catch (Exception e) {
            LPI_ExceptionManager.logException(CLASS_NAME, 'shareWithAuthorizedPortalUsers', e);
        }
    }

    /**
     * @description Looks up the public group used for sharing.
     *              Cached per Apex transaction. Returns null when the
     *              group does not exist (admin has not configured it
     *              yet) and logs a single warning so the configuration
     *              gap is visible without spamming the platform event
     *              log.
     */
    private static Id resolveAuthorizedGroupId() {
        if (groupLookupAttempted) {
            return cachedAuthorizedGroupId;
        }
        groupLookupAttempted = true;
        String developerName = String.isNotBlank(groupDeveloperNameOverride)
            ? groupDeveloperNameOverride
            : AUTHORIZED_GROUP_DEVELOPER_NAME;
        List<Group> groups = (List<Group>) Database.query(
            'SELECT Id FROM Group WHERE DeveloperName = :developerName '
            + 'AND Type = \'Regular\' LIMIT 1',
            System.AccessLevel.SYSTEM_MODE
        );
        if (groups.isEmpty()) {
            LPI_ExceptionManager.logException(
                CLASS_NAME,
                'resolveAuthorizedGroupId',
                'Public group missing',
                'No public group found with DeveloperName=' + developerName
                    + '. Agent-created PARs will be inaccessible to portal users '
                    + 'until the group is created and populated. Create the group '
                    + 'in Setup > Public Groups and add every authorized portal user.',
                null,
                null
            );
            cachedAuthorizedGroupId = null;
            return null;
        }
        cachedAuthorizedGroupId = groups[0].Id;
        return cachedAuthorizedGroupId;
    }
}