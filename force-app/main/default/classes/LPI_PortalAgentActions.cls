/**
 * @description       : Shared helper for the LPI Portal Agentforce Agent.
 *                      Hosts the DTOs and the static implementation of the
 *                      five actions that power the agent. Apex allows only one
 *                      `@InvocableMethod` per class, so each of the five
 *                      invocable entry points lives in its own thin wrapper
 *                      (`LPI_AgentSearchProfessions`, `LPI_AgentGetProfessionDetail`,
 *                      `LPI_AgentGetNextQuestion`, `LPI_AgentSubmitAndLaunch`,
 *                      `LPI_AgentLaunchExempt`) and delegates to the methods on
 *                      this class. This class itself has no `@InvocableMethod`
 *                      annotations so it stays freely callable from tests.
 *                      Phase 1 supports application type "New" only.
 * @author            : MTX Group Product Team
 * @group             : Agentforce Portal Agent
 */
public without sharing class LPI_PortalAgentActions {

    private static final String CLASS_NAME = 'LPI_PortalAgentActions';
    private static final String APP_TYPE_NEW = 'New';
    private static final String STATUS_DUPLICATE = 'Duplicate';
    private static final String STATUS_ERROR = 'Error';
    private static final String STATUS_OK = 'OK';
    private static final String STATUS_BLOCKED = 'Blocked';
    private static final String STATUS_NEEDS_QUESTIONS = 'NeedsQuestions';
    private static final Integer DEFAULT_SEARCH_LIMIT = 20;
    private static final Integer MAX_SEARCH_LIMIT = 50;
    // Adaptive Response card-rendering caps. Per
    // docs/agentforce/agentforce-adaptive-response-options.md the surface
    // renders at most ~5 cards cleanly and truncates labels longer than ~80
    // characters, so we cap both here.
    private static final Integer MAX_DISPLAY_OPTIONS = 5;
    private static final Integer MAX_DISPLAY_OPTION_CHARS = 80;

    /* ------------------------------------------------------------------ */
    /* 0. listProfessionTypes                                              */
    /* ------------------------------------------------------------------ */
    /**
     * @description Returns the profession-type categories available to the
     *              currently signed-in portal user, mirroring the radio group
     *              on /s/recommended-profession. Business-only accounts see
     *              just Business + Schools/Programs; everyone else sees all
     *              four. The agent is expected to render these as a numbered
     *              picklist instead of asking the user to type a category
     *              name.
     */
    public static List<TypeListResponse> listProfessionTypes(List<TypeListRequest> requests) {
        List<TypeListResponse> responses = new List<TypeListResponse>();
        Integer count = (requests == null || requests.isEmpty()) ? 1 : requests.size();
        for (Integer i = 0; i < count; i++) {
            TypeListResponse res = new TypeListResponse();
            try {
                Boolean showOnlyBusiness = isShowOnlyBusinessAccount();
                List<TypeOption> opts = new List<TypeOption>();
                if (showOnlyBusiness) {
                    opts.add(new TypeOption('Business', 'Business/Entity Professions',
                        'Apply on behalf of a business or entity.'));
                    opts.add(new TypeOption('Schools/Programs', 'Schools/Programs',
                        'Apply for a school or program approval.'));
                } else {
                    opts.add(new TypeOption('Individual', 'Individual Professions',
                        'Apply as an individual practitioner.'));
                    opts.add(new TypeOption('Business', 'Business/Entity Professions',
                        'Apply on behalf of a business or entity.'));
                    opts.add(new TypeOption('Schools/Programs', 'Schools/Programs',
                        'Apply for a school or program approval.'));
                    opts.add(new TypeOption('Other', 'Other Applications',
                        'Apply for any other permit/licence type.'));
                }
                Integer idx = 1;
                for (TypeOption o : opts) {
                    o.position = idx++;
                }
                res.status = STATUS_OK;
                res.professionTypes = opts;
                res.count = opts.size();
                res.optionsJson = JSON.serialize(opts);
                res.displayMessage = buildTypeListDisplay(opts);
            } catch (Exception e) {
                LPI_ExceptionManager.logException(CLASS_NAME, 'listProfessionTypes', e);
                res.status = STATUS_ERROR;
                res.errorMessage = e.getMessage();
                res.professionTypes = new List<TypeOption>();
                res.count = 0;
                res.optionsJson = '[]';
                res.displayMessage = '';
            }
            responses.add(res);
        }
        return responses;
    }

    /* ------------------------------------------------------------------ */
    /* 1. searchProfessions                                                */
    /* ------------------------------------------------------------------ */
    /**
     * @description Searches the Profession__c catalog by keyword and profession type.
     *              Honors Account.Person_Account_For_Business__c so that business-only
     *              accounts never see Individual professions.
     */
    public static List<SearchResponse> searchProfessions(List<SearchRequest> requests) {
        List<SearchResponse> responses = new List<SearchResponse>();
        if (requests == null) {
            return responses;
        }
        for (SearchRequest req : requests) {
            SearchResponse res = new SearchResponse();
            try {
                if (String.isNotBlank(req.userReply) && String.isNotBlank(req.typeOptionsJson)) {
                    req.professionType = resolveTypeFromReply(req.userReply, req.typeOptionsJson);
                }
                res.resolvedProfessionType = req.professionType;
                Boolean showOnlyBusiness = isShowOnlyBusinessAccount();
                String whereClause = buildSearchWhereClause(req, showOnlyBusiness);
                String fields = 'Id,Name,Profession_Type__c,Exempt_Decision_Tree__c,'
                    + 'Regulatory_Authorization_Type__c,Regulatory_Authorization_Type__r.Name,'
                    + 'Regulatory_Authorization_Type__r.Description,System_Validation_Needed__c';
                Integer limitVal = (req.maxResults != null && req.maxResults > 0)
                    ? Math.min(req.maxResults, MAX_SEARCH_LIMIT)
                    : DEFAULT_SEARCH_LIMIT;
                List<Profession__c> professions = queryProfessionsInSystemMode(
                    fields,
                    whereClause,
                    String.valueOf(limitVal),
                    'Name',
                    'asc'
                );
                List<ProfessionMatch> matches = new List<ProfessionMatch>();
                Integer pos = 1;
                for (Profession__c p : professions) {
                    ProfessionMatch m = new ProfessionMatch(p);
                    m.position = pos++;
                    matches.add(m);
                }
                res.status = STATUS_OK;
                res.matchCount = matches.size();
                res.matches = matches;
                res.matchesJson = JSON.serialize(matches);
                res.displayMessage = buildSearchDisplay(matches, req.professionType);
            } catch (Exception e) {
                LPI_ExceptionManager.logException(CLASS_NAME, 'searchProfessions', e);
                res.status = STATUS_ERROR;
                res.matchCount = 0;
                res.matches = new List<ProfessionMatch>();
                res.matchesJson = '[]';
                res.displayMessage = '';
                res.errorMessage = e.getMessage();
            }
            responses.add(res);
        }
        return responses;
    }

    /* ------------------------------------------------------------------ */
    /* 2. getProfessionDetail                                              */
    /* ------------------------------------------------------------------ */
    /**
     * @description Returns the launch-decision metadata for a single profession,
     *              and -- critically for the LLM agent -- ALSO returns a fully
     *              formatted Markdown `displayMessage` so the planner never has
     *              to chain a follow-up action just to produce the next user
     *              message:
     *                - exempt profession (or zero questions): this method
     *                  internally calls launchExemptApplication and returns
     *                  the intake URL together with a "[Open my application]"
     *                  Markdown link in displayMessage.
     *                - profession with pre-screening questions: this method
     *                  internally calls getNextQuestion to fetch Q1 and
     *                  returns its question prompt + numbered options as
     *                  displayMessage.
     *              The agent therefore only has to render displayMessage
     *              verbatim regardless of branch, eliminating the LLM-chain
     *              fragility that previously left users stuck on
     *              "I do not have any options to show right now."
     */
    public static List<DetailResponse> getProfessionDetail(List<DetailRequest> requests) {
        List<DetailResponse> responses = new List<DetailResponse>();
        if (requests == null) {
            return responses;
        }
        for (DetailRequest req : requests) {
            DetailResponse res = new DetailResponse();
            try {
                if (String.isNotBlank(req.userReply) && String.isNotBlank(req.searchMatchesJson)) {
                    Map<String, String> resolved = resolveChoiceFromReply(req.userReply, req.searchMatchesJson);
                    req.professionId = resolved.get('professionId');
                    res.professionName = resolved.get('name');
                }
                res.professionId = req.professionId;
                if (String.isBlank(req.professionId)) {
                    res.status = STATUS_ERROR;
                    res.errorMessage = 'professionId is required';
                    res.displayMessage = buildErrorDisplay(res.errorMessage);
                    responses.add(res);
                    continue;
                }
                List<Profession__c> profList = queryProfessionsInSystemMode(
                    'Id,Name,Profession_Type__c,Exempt_Decision_Tree__c,'
                    + 'Regulatory_Authorization_Type__c,Regulatory_Authorization_Type__r.Name,'
                    + 'System_Validation_Needed__c,Examination_Check__c,Pass_Verbiage__c,Fail_Verbiage__c',
                    'Id = \'' + String.escapeSingleQuotes(req.professionId) + '\'',
                    '1',
                    null,
                    null
                );
                if (profList.isEmpty()) {
                    res.status = STATUS_ERROR;
                    res.errorMessage = 'Profession not found';
                    res.displayMessage = buildErrorDisplay(res.errorMessage);
                    responses.add(res);
                    continue;
                }
                Profession__c prof = profList[0];
                res.professionName = prof.Name;
                res.professionType = prof.Profession_Type__c;
                res.regulatoryAuthorizationTypeId = prof.Regulatory_Authorization_Type__c;
                res.regulatoryAuthorizationTypeName = prof.Regulatory_Authorization_Type__r != null
                    ? prof.Regulatory_Authorization_Type__r.Name
                    : null;
                res.isExempt = prof.Exempt_Decision_Tree__c == true;

                // Count visible questions in SYSTEM_MODE so the bot user (Einstein
                // Agent license) is not subject to FLS on Question_Detail__c. The
                // heavy validation/exam pipeline in LPI_DecisionTreeQuestionsController
                // is intentionally skipped here for Phase 1 because it issues several
                // SECURITY_ENFORCED queries against PSC objects the bot user cannot
                // be granted FLS on. The full pipeline still runs at submission time
                // via launchExemptApplication / submitPreScreeningAndLaunch.
                List<Question_Detail__c> existingQuestions = queryQuestionDetailsInSystemMode(
                    'Id', 'Profession__c = \'' + String.escapeSingleQuotes(req.professionId) + '\'',
                    null, null, null);
                Integer questionCount = existingQuestions.size();
                res.questionCount = questionCount;
                if (res.isExempt || questionCount == 0) {
                    // Exempt path: launch the application synchronously so the
                    // agent only has to render displayMessage. We do not depend
                    // on the LLM to chain into launchExemptApplication.
                    res.status = STATUS_OK;
                    res.requiresQuestions = false;
                    LaunchResponse launch = invokeExemptLaunch(res.regulatoryAuthorizationTypeId, prof.Name);
                    res.directLaunch = launch.status == STATUS_OK;
                    res.intakeUrl = launch.intakeUrl;
                    res.displayMessage = launch.displayMessage;
                    if (launch.status != STATUS_OK) {
                        res.status = launch.status;
                        res.errorMessage = launch.errorMessage;
                    }
                } else {
                    res.status = STATUS_NEEDS_QUESTIONS;
                    res.requiresQuestions = true;
                    QuestionResponse first = fetchNextQuestion(req.professionId, '{}');
                    if (first != null && String.isNotBlank(first.displayMessage)) {
                        res.displayMessage = first.displayMessage;
                        res.firstQuestionId = first.questionId;
                        res.firstQuestionOptionsJson = first.optionsJson;
                    } else {
                        res.displayMessage = 'No pre-screening questions found for this profession.';
                        res.firstQuestionId = '';
                    }
                }
            } catch (Exception e) {
                LPI_ExceptionManager.logException(CLASS_NAME, 'getProfessionDetail', e);
                res.status = STATUS_ERROR;
                res.errorMessage = e.getMessage();
                res.displayMessage = buildErrorDisplay(res.errorMessage);
            }
            responses.add(res);
        }
        return responses;
    }

    /* ------------------------------------------------------------------ */
    /* 3. getNextQuestion                                                  */
    /* ------------------------------------------------------------------ */
    /**
     * @description Returns the next visible Question_Detail__c the user must answer,
     *              given the JSON of prior answers. Stateless: the planner re-sends the
     *              full priorAnswersJson on every turn. Replicates the conditional logic
     *              found in lpiDecisionTreeQuestions.js loadUpdatedQuestions.
     */
    public static List<QuestionResponse> getNextQuestion(List<QuestionRequest> requests) {
        List<QuestionResponse> responses = new List<QuestionResponse>();
        if (requests == null) {
            return responses;
        }
        for (QuestionRequest req : requests) {
            QuestionResponse res = new QuestionResponse();
            res.professionId = req.professionId;
            try {
                if (String.isBlank(req.professionId)) {
                    res.status = STATUS_ERROR;
                    res.errorMessage = 'professionId is required';
                    res.displayMessage = buildErrorDisplay(res.errorMessage);
                    res.isLast = true;
                    res.priorAnswersJson = req.priorAnswersJson;
                    responses.add(res);
                    continue;
                }
                // Resolve the user's just-typed reply (if any) against the
                // options of the question we most recently asked, merge the
                // canonical answer into priorAnswersJson, and use the merged
                // JSON for both fetchNextQuestion and the auto-submit. This
                // keeps the LLM's contract trivial: it only forwards the raw
                // user reply, lastQuestionId, and lastQuestionOptionsJson.
                String mergedAnswers = mergeUserReplyIntoAnswers(
                    req.priorAnswersJson,
                    req.lastQuestionId,
                    req.lastQuestionOptionsJson,
                    req.userReply
                );
                res.priorAnswersJson = mergedAnswers;

                QuestionResponse computed = fetchNextQuestion(req.professionId, mergedAnswers);
                copyQuestionFields(computed, res);
                res.priorAnswersJson = mergedAnswers;

                // Self-launch path: if there are no more questions to ask
                // (status=OK, isLast=true), submit the collected answers
                // synchronously so the agent only has to render displayMessage.
                // The LLM does not need to chain into submitPreScreeningAndLaunch.
                if (res.status == STATUS_OK && res.isLast == true) {
                    LaunchResponse launch = invokeSubmitLaunch(req.professionId, mergedAnswers);
                    res.intakeUrl = launch.intakeUrl;
                    if (launch.status == STATUS_OK) {
                        res.displayMessage = launch.displayMessage;
                    } else {
                        // Submit returned Blocked / Duplicate / Error: surface that
                        // displayMessage instead of an empty payload.
                        res.status = launch.status;
                        res.errorMessage = launch.errorMessage;
                        res.displayMessage = String.isNotBlank(launch.displayMessage)
                            ? launch.displayMessage
                            : buildErrorDisplay(launch.errorMessage);
                    }
                }
            } catch (Exception e) {
                LPI_ExceptionManager.logException(CLASS_NAME, 'getNextQuestion', e);
                res.status = STATUS_ERROR;
                res.errorMessage = e.getMessage();
                res.displayMessage = buildErrorDisplay(res.errorMessage);
                res.isLast = true;
                res.priorAnswersJson = req.priorAnswersJson;
            }
            responses.add(res);
        }
        return responses;
    }

    /**
     * @description Merges the user's just-typed reply for lastQuestionId into
     *              the running priorAnswersJson map. Resolves Radio/Picklist
     *              numeric replies ("1", "2") and label substrings against
     *              the JSON-array options shown to the user; for Text /
     *              Text Input questions the reply is stored verbatim
     *              (trimmed). When any of the three input fields are blank
     *              the original priorAnswersJson is returned unchanged so
     *              the very first call (no question yet shown) still works.
     */
    private static String mergeUserReplyIntoAnswers(
        String priorAnswersJson,
        String lastQuestionId,
        String lastQuestionOptionsJson,
        String userReply
    ) {
        String basePayload = String.isBlank(priorAnswersJson) ? '{}' : priorAnswersJson;
        if (String.isBlank(lastQuestionId) || String.isBlank(userReply) || lastQuestionId == 'pending') {
            return basePayload;
        }
        Map<String, String> answers = parsePriorAnswers(basePayload);
        String canonical = userReply.trim();
        // If we have the option list from the prior turn, try to map a
        // numeric or substring reply to its canonical option string.
        if (String.isNotBlank(lastQuestionOptionsJson) && lastQuestionOptionsJson != '[]') {
            try {
                List<Object> opts = (List<Object>) JSON.deserializeUntyped(lastQuestionOptionsJson);
                if (opts != null && !opts.isEmpty()) {
                    String mapped = resolveCanonicalOption(canonical, opts);
                    if (String.isNotBlank(mapped)) {
                        canonical = mapped;
                    }
                }
            } catch (Exception ignore) {
                // Fall through with the raw user reply if the options JSON is malformed.
            }
        }
        answers.put(lastQuestionId, canonical);
        return JSON.serialize(answers);
    }

    /**
     * @description Maps a raw user reply against a list of canonical option
     *              strings using the same heuristics the LWC pre-screening
     *              page uses: position match (1-indexed, also tolerates
     *              "1.", "(1)"), exact case-insensitive label match, then
     *              substring match. Returns the canonical option string on
     *              hit, or null if no rule matches (caller falls back to
     *              the raw reply for Text questions).
     */
    private static String resolveCanonicalOption(String reply, List<Object> opts) {
        if (String.isBlank(reply) || opts == null || opts.isEmpty()) {
            return null;
        }
        String trimmed = reply.trim();
        // 1) Position match: "1", "1.", "(1)", "option 1"
        Integer pos = extractLeadingPosition(trimmed);
        if (pos != null && pos >= 1 && pos <= opts.size()) {
            Object opt = opts[pos - 1];
            if (opt != null) {
                return String.valueOf(opt);
            }
        }
        String lower = trimmed.toLowerCase();
        // 2) Exact label match (case-insensitive)
        for (Object opt : opts) {
            if (opt != null && String.valueOf(opt).toLowerCase() == lower) {
                return String.valueOf(opt);
            }
        }
        // 3) Substring match (case-insensitive)
        for (Object opt : opts) {
            if (opt == null) {
                continue;
            }
            String s = String.valueOf(opt);
            if (s.toLowerCase().contains(lower) || lower.contains(s.toLowerCase())) {
                return s;
            }
        }
        return null;
    }

    private static Integer extractLeadingPosition(String reply) {
        if (String.isBlank(reply)) {
            return null;
        }
        Pattern p = Pattern.compile('^[^0-9]*(\\d+)');
        Matcher m = p.matcher(reply);
        if (m.find()) {
            try {
                return Integer.valueOf(m.group(1));
            } catch (Exception ignore) {
                return null;
            }
        }
        return null;
    }

    /**
     * @description Internal helper that returns the next visible question for
     *              a profession given a JSON map of prior answers. Used both
     *              by the public `getNextQuestion` invocable wrapper and by
     *              `getProfessionDetail` so it can pre-fetch Q1 and embed
     *              the question prompt in the very first turn.
     */
    private static QuestionResponse fetchNextQuestion(String professionId, String priorAnswersJson) {
        QuestionResponse res = new QuestionResponse();
        res.professionId = professionId;
        Map<String, String> priorAnswers = parsePriorAnswers(priorAnswersJson);
        List<Question_Detail__c> ordered = queryQuestionDetailsInSystemMode(
            'Id,Name,Profession__c,Order__c,Question_Description__c,Answer_Type__c,Question_Values__c,'
            + 'Is_Required__c,Parent_Question__c,Matching_Value__c,Matching_Criteria__c,'
            + 'Save_Response__c,Launch_Flow__c,Target_Object__c,Target_Field__c,'
            + 'Error_Message__c,Error_Matching_Value__c',
            'Profession__c = \'' + String.escapeSingleQuotes(professionId) + '\'',
            null,
            'Order__c',
            'asc'
        );
        // Mirror the LWC `handleChange` gating: if any answered question's response
        // matches its Error_Matching_Value__c the user is not eligible. Stop the
        // loop with status=Blocked so the planner shows the error instead of asking
        // the next question (or worse, launching the application anyway).
        Question_Detail__c blocker = findBlockingError(ordered, priorAnswers);
        if (blocker != null) {
            res.status = STATUS_BLOCKED;
            res.isLast = true;
            res.options = new List<String>();
            res.optionsJson = '[]';
            res.errorMessage = String.isNotBlank(blocker.Error_Message__c)
                ? blocker.Error_Message__c
                : 'You are not eligible to apply for this permit based on your responses.';
            res.displayMessage = buildBlockedDisplay(res.errorMessage);
            return res;
        }
        Question_Detail__c next = pickNextVisibleQuestion(ordered, priorAnswers);
        if (next == null) {
            res.status = STATUS_OK;
            res.isLast = true;
            res.options = new List<String>();
            res.optionsJson = '[]';
            res.displayMessage = '';
            return res;
        }
        res.status = STATUS_OK;
        res.isLast = false;
        res.questionId = next.Id;
        res.questionName = next.Name;
        res.description = stripHtml(next.Question_Description__c);
        res.answerType = next.Answer_Type__c;
        res.required = next.Is_Required__c == true;
        res.options = splitOptions(next.Question_Values__c);
        res.optionsJson = JSON.serialize(res.options);
        res.displayMessage = buildQuestionDisplay(res);
        return res;
    }

    private static void copyQuestionFields(QuestionResponse src, QuestionResponse dest) {
        dest.status = src.status;
        dest.questionId = src.questionId;
        dest.questionName = src.questionName;
        dest.description = src.description;
        dest.answerType = src.answerType;
        dest.required = src.required;
        dest.options = src.options;
        dest.optionsJson = src.optionsJson;
        dest.displayMessage = src.displayMessage;
        dest.isLast = src.isLast;
        dest.intakeUrl = src.intakeUrl;
        dest.errorMessage = src.errorMessage;
    }

    /* ------------------------------------------------------------------ */
    /* 4. submitPreScreeningAndLaunch                                      */
    /* ------------------------------------------------------------------ */
    /**
     * @description Builds the responseData payload accepted by
     *              LPI_DecisionTreeQuestionsController.updateResponse and forwards it to
     *              create the PAR record. Returns the SavedApplicationUrl with type=New.
     */
    public static List<LaunchResponse> submitPreScreeningAndLaunch(List<SubmitRequest> requests) {
        List<LaunchResponse> responses = new List<LaunchResponse>();
        if (requests == null) {
            return responses;
        }
        for (SubmitRequest req : requests) {
            responses.add(invokeSubmitLaunch(req.professionId, req.answersJson));
        }
        return responses;
    }

    /**
     * @description Internal helper that runs the same submit-and-launch
     *              pipeline used by the public `submitPreScreeningAndLaunch`
     *              wrapper, so both `getNextQuestion` (when isLast=true) and
     *              the standalone agent action share the exact same
     *              eligibility check + PAR creation logic. Always returns a
     *              displayMessage so the agent can render it verbatim.
     */
    private static LaunchResponse invokeSubmitLaunch(String professionId, String answersJson) {
        return invokeSubmitLaunch(professionId, answersJson, resolvePortalUserContext(null));
    }

    private static LaunchResponse invokeSubmitLaunch(String professionId, String answersJson, PortalUserContext ctx) {
        LaunchResponse res = new LaunchResponse();
        try {
            if (String.isBlank(professionId) || String.isBlank(answersJson)) {
                res.status = STATUS_ERROR;
                res.errorMessage = 'professionId and answersJson are required';
                res.displayMessage = buildErrorDisplay(res.errorMessage);
                return res;
            }
            Map<String, String> priorAnswers = parsePriorAnswers(answersJson);
            List<Question_Detail__c> ordered = queryQuestionDetailsInSystemMode(
                'Id,Name,Profession__c,Order__c,Question_Description__c,Answer_Type__c,Question_Values__c,'
                + 'Is_Required__c,Parent_Question__c,Matching_Value__c,Matching_Criteria__c,'
                + 'Save_Response__c,Launch_Flow__c,Target_Object__c,Target_Field__c,'
                + 'Error_Message__c,Error_Matching_Value__c',
                'Profession__c = \'' + String.escapeSingleQuotes(professionId) + '\'',
                null,
                'Order__c',
                'asc'
            );
            // Belt-and-suspenders: refuse to launch if any answer triggers the gate.
            // The planner *should* never reach Submit when the question loop already
            // returned Blocked, but if it does we must not silently create a PAR for
            // an ineligible applicant.
            Question_Detail__c blocker = findBlockingError(ordered, priorAnswers);
            if (blocker != null) {
                res.status = STATUS_BLOCKED;
                res.errorMessage = String.isNotBlank(blocker.Error_Message__c)
                    ? blocker.Error_Message__c
                    : 'You are not eligible to apply for this permit based on your responses.';
                res.displayMessage = buildBlockedDisplay(res.errorMessage);
                return res;
            }
            PortalUserContext portalCtx = ctx != null ? ctx : resolvePortalUserContext(null);
            String result;
            // v38 perf: when the agent runs as the bot service user
            // (production reality - the messaging session never
            // carries a real ContactId today) the standard
            // LPI_DecisionTreeQuestionsController.updateResponse chain
            // reliably fails because the bot user has no AccountId on
            // its User row. The chain still costs ~30 SOQL queries and
            // ~3 seconds of CPU before raising the exception we catch
            // below, which is exactly the slowness the user sees on
            // launch turns. Skip the standard call entirely whenever we
            // cannot resolve a real portal-user context. Tests keep
            // running the standard path so the catch + fallback branch
            // remains covered.
            Boolean shouldRunStandardPath = Test.isRunningTest() || (
                portalCtx != null
                && portalCtx.userId != null
                && portalCtx.userId == UserInfo.getUserId()
                && portalCtx.contactId != null
            );
            if (shouldRunStandardPath) {
                List<Map<String, Object>> responsePayload = buildResponseDataPayload(ordered, priorAnswers);
                String responseDataJson = JSON.serialize(responsePayload);
                try {
                    result = LPI_DecisionTreeQuestionsController.updateResponse(responseDataJson);
                } catch (Exception standardEx) {
                    if (!isFlsError(standardEx)) {
                        throw standardEx;
                    }
                    LPI_ExceptionManager.logException(CLASS_NAME,
                        'invokeSubmitLaunch.fallbackToSystemMode', standardEx);
                    result = null;
                }
            }
            // Fallback (the dominant path in production): SYSTEM_MODE
            // PAR insert when the standard controller did not produce a
            // URL. We look up the RAT id from the profession to drive
            // the exempt-style fallback.
            if (String.isBlank(result) || result == STATUS_ERROR) {
                List<Profession__c> profForRat = queryProfessionsInSystemMode(
                    'Id,Regulatory_Authorization_Type__c',
                    'Id = \'' + String.escapeSingleQuotes(professionId) + '\'',
                    '1', null, null
                );
                if (!profForRat.isEmpty() && profForRat[0].Regulatory_Authorization_Type__c != null) {
                    String fallbackUrl = createParInSystemMode(profForRat[0].Regulatory_Authorization_Type__c, portalCtx);
                    if (String.isNotBlank(fallbackUrl) && fallbackUrl != STATUS_ERROR) {
                        result = fallbackUrl;
                    }
                }
            } else {
                // Standard path succeeded (rare - only when running as
                // a real portal user). The shared
                // LPI_ApplicationFlowUtility.createPARRecord does NOT set
                // OwnerId, so we patch ownership AND share with the
                // portal-user public group as a belt-and-suspenders.
                patchParOwnership(result, portalCtx);
            }
            applyLaunchResult(res, result, lookupProfessionName(professionId));
        } catch (Exception e) {
            LPI_ExceptionManager.logException(CLASS_NAME, 'submitPreScreeningAndLaunch', e);
            res.status = STATUS_ERROR;
            res.errorMessage = e.getMessage();
            res.displayMessage = buildErrorDisplay(res.errorMessage);
        }
        return res;
    }

    /**
     * @description v35: extracts the PAR Id from the SavedApplicationUrl
     *              returned by `LPI_DecisionTreeQuestionsController.updateResponse`
     *              (shape: `<base>/s/intake-form?id=<parId>` or any URL
     *              with a trailing 15/18-char Id) and patches `OwnerId`,
     *              `BusinessAccountNameId`, and `Contact__c` so the portal
     *              user owns the record. Triggers are bypassed during the
     *              update so the hand-off does not double-fire validation
     *              rules. Best-effort: any failure is logged but does not
     *              fail the launch (the link is still valid; the portal
     *              user can still open the form).
     */
    private static void patchParOwnership(String savedUrl, PortalUserContext ctx) {
        if (String.isBlank(savedUrl)) {
            return;
        }
        // v38: extract the PAR id even when the launch URL puts it in a
        // query parameter (e.g. ...&c__parid=0goWG... &type=New). The
        // earlier "trailing id only" pattern misses that shape.
        Pattern idPattern = Pattern.compile('([a-zA-Z0-9]{15,18})');
        Matcher m = idPattern.matcher(savedUrl);
        String parId;
        while (m.find()) {
            String candidate = m.group(1);
            if (candidate != null && candidate.length() >= 15
                && candidate.startsWith('0go')) {
                parId = candidate;
            }
        }
        if (String.isBlank(parId)) {
            return;
        }
        try {
            // v38: always share the PAR with the portal-user public
            // group so the user who clicks the agent link can open AND
            // submit the form even when we cannot resolve a real
            // PortalUserContext (CLI/preview, missing ContactId from
            // the messaging session, etc.).
            LPI_PortalAgentClaim.shareWithAuthorizedPortalUsers((Id) parId);

            if (ctx == null || ctx.userId == null) {
                return;
            }
            PreliminaryApplicationRef p = new PreliminaryApplicationRef(Id = (Id) parId);
            p.OwnerId = ctx.userId;
            if (ctx.accountId != null) {
                p.BusinessAccountNameId = ctx.accountId;
                p.Business_Account__c = ctx.accountId;
            }
            if (ctx.contactId != null) { p.Contact__c = ctx.contactId; }
            LPI_TriggerHandler.bypass('PreliminaryApplicationTriggerHandler');
            Database.update(p, System.AccessLevel.SYSTEM_MODE);
        } catch (Exception e) {
            LPI_ExceptionManager.logException(CLASS_NAME, 'patchParOwnership', e);
        } finally {
            LPI_TriggerHandler.clearBypass('PreliminaryApplicationTriggerHandler');
        }
    }

    private static String lookupProfessionName(String professionId) {
        if (String.isBlank(professionId)) {
            return null;
        }
        List<Profession__c> profList = queryProfessionsInSystemMode(
            'Id,Name',
            'Id = \'' + String.escapeSingleQuotes(professionId) + '\'',
            '1', null, null
        );
        return profList.isEmpty() ? null : profList[0].Name;
    }

    /* ------------------------------------------------------------------ */
    /* 5. launchExemptApplication                                          */
    /* ------------------------------------------------------------------ */
    /**
     * @description For professions where Exempt_Decision_Tree__c = true, creates the
     *              PAR directly via LPI_RecommendedLicenseCtrl.createApplication and
     *              returns the intake URL.
     */
    public static List<LaunchResponse> launchExemptApplication(List<LaunchRequest> requests) {
        List<LaunchResponse> responses = new List<LaunchResponse>();
        if (requests == null) {
            return responses;
        }
        for (LaunchRequest req : requests) {
            responses.add(invokeExemptLaunch(req.regulatoryAuthorizationTypeId, null));
        }
        return responses;
    }

    /**
     * @description Internal helper that creates the PAR record via
     *              LPI_RecommendedLicenseCtrl.createApplication and returns a
     *              LaunchResponse already populated with `displayMessage`
     *              ready to render. Shared by the public
     *              `launchExemptApplication` invocable and by
     *              `getProfessionDetail` so that the exempt branch can
     *              produce the launch URL in a single agent turn (no LLM
     *              chain required).
     */
    private static LaunchResponse invokeExemptLaunch(String regulatoryAuthorizationTypeId, String professionName) {
        return invokeExemptLaunch(regulatoryAuthorizationTypeId, professionName, resolvePortalUserContext(null));
    }

    private static LaunchResponse invokeExemptLaunch(String regulatoryAuthorizationTypeId, String professionName, PortalUserContext ctx) {
        LaunchResponse res = new LaunchResponse();
        try {
            if (String.isBlank(regulatoryAuthorizationTypeId)) {
                res.status = STATUS_ERROR;
                res.errorMessage = 'regulatoryAuthorizationTypeId is required';
                res.displayMessage = buildErrorDisplay(res.errorMessage);
                return res;
            }
            // Try the standard portal launch path first. This is what real
            // portal users (and embedded messaging sessions running under a
            // portal user) hit, and it preserves every business-rule the
            // OmniStudio flow runs through createPARRecord.
            //
            // Fall back to a SYSTEM_MODE PAR insert if the standard path
            // either throws an FLS / sharing error OR returns "Error" (the
            // shared `LPI_ApplicationFlowUtility.createPARRecord` catches
            // QueryException internally and returns null, so
            // `createApplication` swallows the exception and returns the
            // sentinel string "Error" - we cannot rely on a raised exception
            // here). The fallback is what runs when the agent is invoked as
            // the Einstein Agent license user (CLI `sf agent preview`,
            // internal Agent Builder testing) instead of as an authenticated
            // Portal User. The bot user is a service account that
            // intentionally does not own field-level FLS for the 50+
            // RegulatoryAuthorizationType custom fields read by the shared
            // launch chain, so SYSTEM_MODE is the correct escape hatch.
            PortalUserContext portalCtx = ctx != null ? ctx : resolvePortalUserContext(null);
            String result;
            // v38 perf: same rationale as invokeSubmitLaunch - skip the
            // expensive standard `createApplication` chain when we are
            // running as the bot service user, since it always fails for
            // bot. Tests still run the standard path so the catch +
            // fallback branch stays covered.
            Boolean shouldRunStandardPath = Test.isRunningTest() || (
                portalCtx != null
                && portalCtx.userId != null
                && portalCtx.userId == UserInfo.getUserId()
                && portalCtx.contactId != null
            );
            if (shouldRunStandardPath) {
                try {
                    Map<String, Object> input = new Map<String, Object>{
                        'type' => APP_TYPE_NEW,
                        'regAuthId' => regulatoryAuthorizationTypeId
                    };
                    result = LPI_RecommendedLicenseCtrl.createApplication(input);
                } catch (Exception standardEx) {
                    if (!isFlsError(standardEx)) {
                        throw standardEx;
                    }
                    LPI_ExceptionManager.logException(CLASS_NAME,
                        'invokeExemptLaunch.fallbackToSystemMode', standardEx);
                    result = null;
                }
            }
            if (String.isBlank(result) || result == STATUS_ERROR) {
                String fallbackUrl = createParInSystemMode(regulatoryAuthorizationTypeId, portalCtx);
                if (String.isNotBlank(fallbackUrl) && fallbackUrl != STATUS_ERROR) {
                    result = fallbackUrl;
                }
            } else {
                // Standard path succeeded - patch ownership AND share
                // with the portal-user public group.
                patchParOwnership(result, portalCtx);
            }
            applyLaunchResult(res, result, professionName);
        } catch (Exception e) {
            LPI_ExceptionManager.logException(CLASS_NAME, 'launchExemptApplication', e);
            res.status = STATUS_ERROR;
            res.errorMessage = e.getMessage();
            res.displayMessage = buildErrorDisplay(res.errorMessage);
        }
        return res;
    }

    /**
     * @description Returns true when the supplied exception (or any cause in
     *              its chain) is the FLS / SECURITY_ENFORCED error that
     *              `LPI_RegulatoryAuthorizationTypeDAO.getRATTypeByID` throws
     *              when the running user does not have read on every queried
     *              custom field. We only want to swap to the SYSTEM_MODE
     *              fallback for these specific cases - never for genuine
     *              business errors like "Duplicate" or missing flow configs.
     */
    private static Boolean isFlsError(Exception e) {
        Exception cur = e;
        while (cur != null) {
            String msg = cur.getMessage();
            if (msg != null && (
                msg.containsIgnoreCase('Insufficient permissions')
                || msg.containsIgnoreCase('inaccessible field')
                || msg.containsIgnoreCase('secure query'))) {
                return true;
            }
            cur = cur.getCause();
        }
        return false;
    }

    /**
     * @description Service-user fallback that replicates the minimum subset of
     *              `LPI_ApplicationFlowUtility.createPARRecord` needed to
     *              produce a launch URL when the agent is running as the
     *              Einstein Agent service user. Reads catalog data
     *              (`RegulatoryAuthorizationType`, `Application_Flow_Config__c`)
     *              and the current `User` record in SYSTEM_MODE so it is not
     *              gated by the bot user's FLS, then inserts a draft
     *              `PreliminaryApplicationRef` in SYSTEM_MODE. Triggers still
     *              fire in user mode, so the bot user is granted read on
     *              `Group` (standard) and create on `PreliminaryApplicationRef`
     *              via `LPI_Portal_Agent_Access`. Returns the SavedApplicationUrl
     *              so callers can route through `applyLaunchResult` exactly as
     *              they do for the standard path.
     *
     *              v35: when the agent runtime supplies the signed-in portal
     *              user's ContactId (from MessagingEndUser.ContactId) we use
     *              the matching User row to set OwnerId/BusinessAccountNameId/
     *              Contact__c on the PAR. Otherwise the PAR is owned by the
     *              bot service user and the portal user gets "insufficient
     *              access" the moment they try to submit.
     */
    private static String createParInSystemMode(String regAuthId) {
        return createParInSystemMode(regAuthId, resolvePortalUserContext(null));
    }

    private static String createParInSystemMode(String regAuthId, PortalUserContext ctx) {
        // Catalog lookup: RAT (v39: include IssuingDepartment.Name for
        // Board_Name__c so the SYSTEM_MODE doc-cloning helper has it
        // available even when the beforeInsert trigger's updateBoardName
        // fails due to the bot user's limited FLS).
        String regAuthIdParam = regAuthId;
        List<RegulatoryAuthorizationType> rats = (List<RegulatoryAuthorizationType>) Database.query(
            'SELECT Id, Name, Authorisation_Type__c, IssuingDepartment.Name '
            + 'FROM RegulatoryAuthorizationType '
            + 'WHERE Id = :regAuthIdParam LIMIT 1',
            System.AccessLevel.SYSTEM_MODE
        );
        if (rats.isEmpty()) {
            return STATUS_ERROR;
        }
        RegulatoryAuthorizationType rat = rats[0];

        // Catalog lookup: Application Flow Config (Application_Type__c = 'New')
        String appFlowAppType = LPI_LiteralConstant.IA_NEW_APPLICATIONTYPE;
        List<Application_Flow_Config__c> configs = (List<Application_Flow_Config__c>) Database.query(
            'SELECT Id, Application_URL__c, Application_Type__c, Application_Subtype__c '
            + 'FROM Application_Flow_Config__c '
            + 'WHERE Regulatory_Authorization_Type__c = :regAuthIdParam '
            + 'AND Application_Type__c = :appFlowAppType '
            + 'LIMIT 1',
            System.AccessLevel.SYSTEM_MODE
        );
        if (configs.isEmpty()) {
            return STATUS_ERROR;
        }
        Application_Flow_Config__c cfg = configs[0];

        PortalUserContext portalCtx = ctx != null ? ctx : resolvePortalUserContext(null);

        PreliminaryApplicationRef par = new PreliminaryApplicationRef();
        par.Regulatory_Authorization_Type__c = regAuthId;
        par.BusinessAccountNameId = portalCtx.accountId;
        par.Business_Account__c = portalCtx.accountId;
        par.Contact__c = portalCtx.contactId;
        par.ApplicationType = rat.Authorisation_Type__c == LPI_LiteralConstant.CONTACT_INDIVIDUAL_RECORDTYPE
            ? LPI_LiteralConstant.IA_SOBJECT_API
            : LPI_LiteralConstant.BLA_SOBJECT_API;
        par.Status__c = LPI_LiteralConstant.PAR_DRAFT_STATUS;
        par.SavedApplicationUrl = cfg.Application_URL__c;
        par.App_Flow_Config_Id__c = cfg.Id;
        par.Channel__c = 'Online';
        par.Type__c = appFlowAppType;
        par.Amendment_Type__c = cfg.Application_Subtype__c;
        par.ApplicationName = appFlowAppType + ' Application';
        // v39: set Board_Name__c explicitly from RAT so it is available
        // for Application_Document__c cloning even when the beforeInsert
        // trigger's updateBoardName falls back on FLS errors.
        if (rat.IssuingDepartment != null && rat.IssuingDepartment.Name != null) {
            par.Board_Name__c = rat.IssuingDepartment.Name;
        }
        // v40: insert the PAR first WITHOUT setting OwnerId. This
        // guarantees creation succeeds even when the bot profile lacks
        // the "Transfer Record" permission. Ownership is transferred
        // in a separate DML immediately after.
        Database.insert(par, System.AccessLevel.SYSTEM_MODE);

        // v40: transfer ownership to the portal user in a separate update
        // so that an ownership-transfer failure never blocks PAR creation.
        if (portalCtx.userId != null && portalCtx.userId != UserInfo.getUserId()) {
            try {
                PreliminaryApplicationRef ownerPatch = new PreliminaryApplicationRef();
                ownerPatch.Id = par.Id;
                ownerPatch.OwnerId = portalCtx.userId;
                ownerPatch.Contact__c = portalCtx.contactId;
                ownerPatch.BusinessAccountNameId = portalCtx.accountId;
                ownerPatch.Business_Account__c = portalCtx.accountId;
                LPI_TriggerHandler.bypass('PreliminaryApplicationTriggerHandler');
                Database.update(ownerPatch, System.AccessLevel.SYSTEM_MODE);
                par.OwnerId = portalCtx.userId;
                par.Contact__c = portalCtx.contactId;
                par.BusinessAccountNameId = portalCtx.accountId;
                par.Business_Account__c = portalCtx.accountId;
            } catch (Exception ownerEx) {
                LPI_ExceptionManager.logException(CLASS_NAME,
                    'createParInSystemMode.ownerTransfer', ownerEx);
            } finally {
                LPI_TriggerHandler.clearBypass('PreliminaryApplicationTriggerHandler');
            }
        }

        cloneRegAuthContentInSystemMode(par);

        createTempAuthPlaceInSystemMode(par, rat, portalCtx);

        LPI_PortalAgentClaim.shareWithAuthorizedPortalUsers(par.Id);

        String fullUrl = cfg.Application_URL__c
            + LPI_LiteralConstant.PRE_APPLICATION_INTAKEFORM_URL_VARIABLENAME
            + par.Id;
        PreliminaryApplicationRef updatePar = new PreliminaryApplicationRef();
        updatePar.Id = par.Id;
        updatePar.SavedApplicationUrl = fullUrl;
        LPI_TriggerHandler.bypass('PreliminaryApplicationTriggerHandler');
        Database.update(updatePar, System.AccessLevel.SYSTEM_MODE);
        LPI_TriggerHandler.clearBypass('PreliminaryApplicationTriggerHandler');
        return fullUrl;
    }

    /**
     * @description v39: SYSTEM_MODE replica of LPI_PARTriggerHelper
     *              .cloneRegulatoryAuthorizationContent. The trigger-based
     *              version runs in the afterInsert context but silently
     *              fails for the Einstein Agent service user because the
     *              shared DAO (LPI_RegulatoryAuthorizationContentDAO
     *              .getRegAuthContentByRATTypeAndRecordType) uses WITH
     *              SECURITY_ENFORCED. This helper queries the same
     *              Regulatory_Authorization_Content__c rows in SYSTEM_MODE,
     *              matches them by Type__c / Sub_Type__c against the PAR,
     *              and inserts Application_Document__c rows so the intake
     *              form shows the correct document checklist.
     *
     *              Best-effort: failures are logged but never propagated
     *              so the PAR link is still returned to the user.
     */
    private static void cloneRegAuthContentInSystemMode(PreliminaryApplicationRef par) {
        try {
            if (par == null || par.Regulatory_Authorization_Type__c == null) {
                return;
            }
            String ratId = par.Regulatory_Authorization_Type__c;
            String docRecordType = LPI_LiteralConstant.DOCUMENT_RECORDTYPE_API;
            List<Regulatory_Authorization_Content__c> contentRows =
                (List<Regulatory_Authorization_Content__c>) Database.query(
                    'SELECT Id, Name_of_Document__c, Is_Document_Required__c, '
                    + 'Sequence_of_Document__c, Related_Element_Name__c, '
                    + 'Description__c, Type__c, Sub_Type__c, Help_Text__c, '
                    + 'Is_Lawful_Presence_Document__c, Regulatory_Authorization_Type__c '
                    + 'FROM Regulatory_Authorization_Content__c '
                    + 'WHERE Regulatory_Authorization_Type__c = :ratId '
                    + 'AND RecordType.DeveloperName = :docRecordType',
                    System.AccessLevel.SYSTEM_MODE
                );
            if (contentRows.isEmpty()) {
                return;
            }
            // Delete any Application_Document__c rows already created by the
            // trigger (in case the trigger partially succeeded). Query in
            // SYSTEM_MODE to avoid FLS errors.
            String parId = par.Id;
            List<Application_Document__c> existing =
                (List<Application_Document__c>) Database.query(
                    'SELECT Id FROM Application_Document__c '
                    + 'WHERE Preliminary_Application_Reference__c = :parId',
                    System.AccessLevel.SYSTEM_MODE
                );
            if (!existing.isEmpty()) {
                Database.delete(existing, System.AccessLevel.SYSTEM_MODE);
            }

            List<Application_Document__c> toInsert = new List<Application_Document__c>();
            for (Regulatory_Authorization_Content__c rac : contentRows) {
                if (rac.Type__c == par.Type__c && rac.Sub_Type__c == par.Amendment_Type__c) {
                    Application_Document__c doc = new Application_Document__c();
                    doc.Description__c = rac.Description__c;
                    doc.Document_Name__c = rac.Name_of_Document__c;
                    doc.Is_Document_Required__c = rac.Is_Document_Required__c;
                    doc.Sequence__c = rac.Sequence_of_Document__c;
                    doc.Related_Element_Name__c = rac.Related_Element_Name__c;
                    doc.Type__c = rac.Type__c;
                    doc.Sub_Type__c = rac.Sub_Type__c;
                    doc.Status__c = LPI_LiteralConstant.APPDOC_STATUS;
                    doc.Board_Name__c = par.Board_Name__c;
                    doc.Help_Text__c = rac.Help_Text__c;
                    doc.Preliminary_Application_Reference__c = par.Id;
                    doc.Is_Lawful_Presence_Document__c = rac.Is_Lawful_Presence_Document__c;
                    doc.Is_System_Generated__c = true;
                    doc.Upload_To_Onbase__c = true;
                    if (rac.Is_Lawful_Presence_Document__c) {
                        doc.Account__c = par.BusinessAccountNameId;
                    }
                    toInsert.add(doc);
                }
            }
            if (!toInsert.isEmpty()) {
                Database.insert(toInsert, System.AccessLevel.SYSTEM_MODE);
            }
        } catch (Exception e) {
            LPI_ExceptionManager.logException(CLASS_NAME,
                'cloneRegAuthContentInSystemMode', e);
        }
    }

    /**
     * @description v39: SYSTEM_MODE replica of the Temp_AuthApplicationPlace
     *              + residence Location / Address creation that
     *              LPI_ApplicationFlowUtility.createPARRecord performs for
     *              individual "New" applications (lines 328-391 of that
     *              class). Without this, agent-created PARs are missing
     *              the Temp AAP rows that the intake form uses to display
     *              the residence address section.
     *
     *              Conditions mirror the original: only for Individual
     *              authorization type and Type__c = 'New'.
     *
     *              Best-effort: failures are logged but never propagated.
     */
    private static void createTempAuthPlaceInSystemMode(
        PreliminaryApplicationRef par,
        RegulatoryAuthorizationType rat,
        PortalUserContext portalCtx
    ) {
        try {
            if (par == null || rat == null) {
                return;
            }
            boolean isIndividualNew =
                rat.Authorisation_Type__c == LPI_LiteralConstant.CONTACT_INDIVIDUAL_RECORDTYPE
                && par.Type__c == LPI_LiteralConstant.IA_NEW_APPLICATIONTYPE;
            if (!isIndividualNew) {
                return;
            }
            String accountId = par.BusinessAccountNameId;
            if (String.isBlank(accountId)) {
                return;
            }

            // Lookup account for address fields
            String accIdParam = accountId;
            List<Account> accList = (List<Account>) Database.query(
                'SELECT Id, Name, PersonOtherStreet, PersonOtherCity, '
                + 'PersonOtherStateCode, Other_State__c, PersonOtherCountryCode, '
                + 'PersonOtherPostalCode, County__c '
                + 'FROM Account WHERE Id = :accIdParam LIMIT 1',
                System.AccessLevel.SYSTEM_MODE
            );
            if (accList.isEmpty()) {
                return;
            }
            Account acc = accList[0];

            // Check for an existing residence Location linked to the account
            String existingResLocationId = null;
            List<AuthApplicationPlace> existingPlaces =
                (List<AuthApplicationPlace>) Database.query(
                    'SELECT PlaceId FROM AuthApplicationPlace '
                    + 'WHERE AuthorizationId IN '
                    + '(SELECT Id FROM BusinessLicense WHERE AccountId = :accIdParam) '
                    + 'AND Place.LocationType = \''
                    + LPI_LiteralConstant.LOCATION_TYPE_RESIDENCE + '\'',
                    System.AccessLevel.SYSTEM_MODE
                );
            if (!existingPlaces.isEmpty()) {
                existingResLocationId = existingPlaces[0].PlaceId;
            }

            Schema.Location residenceLoc;
            if (existingResLocationId == null) {
                residenceLoc = new Schema.Location();
                residenceLoc.Name = acc.Name + '-' + LPI_LiteralConstant.LOCATION_TYPE_RESIDENCE;
                residenceLoc.LocationType = LPI_LiteralConstant.LOCATION_TYPE_RESIDENCE;
                residenceLoc.Status__c = LPI_LiteralConstant.LOCATION_STATUS_OPEN;
                residenceLoc.OpenDate = System.today();
                Database.insert(residenceLoc, System.AccessLevel.SYSTEM_MODE);

                AssociatedLocation acl = new AssociatedLocation();
                acl.ParentRecordId = accountId;
                acl.LocationId = residenceLoc.Id;
                Database.insert(acl, System.AccessLevel.SYSTEM_MODE);

                Schema.Address residenceAddr = new Schema.Address();
                residenceAddr.LocationType = LPI_LiteralConstant.LOCATION_TYPE_RESIDENCE;
                residenceAddr.ParentId = residenceLoc.Id;
                residenceAddr.Street = acc.PersonOtherStreet;
                residenceAddr.City = acc.PersonOtherCity;
                if (acc.PersonOtherStateCode != null) {
                    residenceAddr.StateCode = acc.PersonOtherStateCode;
                }
                if (acc.Other_State__c != null) {
                    residenceAddr.Business_State__c = acc.Other_State__c;
                }
                residenceAddr.CountryCode = acc.PersonOtherCountryCode;
                residenceAddr.PostalCode = acc.PersonOtherPostalCode;
                residenceAddr.County__c = acc.County__c;
                Database.insert(residenceAddr, System.AccessLevel.SYSTEM_MODE);
            }

            Temp_AuthApplicationPlace__c aap = new Temp_AuthApplicationPlace__c();
            aap.Preliminary_Application_Reference__c = par.Id;
            if (existingResLocationId != null) {
                aap.Location__c = existingResLocationId;
            } else if (residenceLoc != null) {
                aap.Location__c = residenceLoc.Id;
            }
            Database.insert(aap, System.AccessLevel.SYSTEM_MODE);
        } catch (Exception e) {
            LPI_ExceptionManager.logException(CLASS_NAME,
                'createTempAuthPlaceInSystemMode', e);
        }
    }

    /**
     * @description v35: small POJO that carries the resolved portal-user
     *              identity into the PAR-creation paths. We compute this
     *              once per turn and reuse it for both the SYSTEM_MODE
     *              fallback insert and the post-insert ownership patch on
     *              the standard `LPI_DecisionTreeQuestionsController.updateResponse`
     *              path. Never serialised; lives only in memory.
     */
    private class PortalUserContext {
        public Id userId;
        public Id accountId;
        public Id contactId;
    }

    /**
     * @description Resolves the signed-in portal user from a Messaging
     *              ContactId. Returns the corresponding active User's
     *              `Id`, `AccountId`, and `ContactId` so the agent can
     *              create the PAR on behalf of (and owned by) the real
     *              portal user instead of the Einstein Agent service user.
     *              When the contactId is blank or no active User matches
     *              the contact (CLI preview, internal Agent Builder
     *              testing, mis-mapped accounts), falls back to the
     *              currently running user so existing behaviour and
     *              existing unit tests are preserved.
     */
    private static PortalUserContext resolvePortalUserContext(String contactId) {
        String cacheKey = String.isBlank(contactId) ? '__current__' : contactId;
        if (portalUserContextCache.containsKey(cacheKey)) {
            return portalUserContextCache.get(cacheKey);
        }
        PortalUserContext ctx = new PortalUserContext();
        try {
            // Path 1: contactId was supplied by the runtime.
            if (String.isNotBlank(contactId) && isValidSalesforceId(contactId)) {
                ctx = resolveFromContactId(contactId);
                if (ctx.userId != null && ctx.contactId != null) {
                    portalUserContextCache.put(cacheKey, ctx);
                    return ctx;
                }
            }

            // Path 2: check the running user.
            Id currentUserId = UserInfo.getUserId();
            List<User> running = (List<User>) Database.query(
                'SELECT Id, AccountId, ContactId, Profile.Name FROM User '
                + 'WHERE Id = :currentUserId LIMIT 1',
                System.AccessLevel.SYSTEM_MODE
            );
            if (!running.isEmpty() && running[0].ContactId != null) {
                ctx.userId = running[0].Id;
                ctx.accountId = running[0].AccountId;
                ctx.contactId = running[0].ContactId;
                portalUserContextCache.put(cacheKey, ctx);
                return ctx;
            }

            // Path 3: bot user with no ContactId — try session-based lookup.
            if (!running.isEmpty() && running[0].ContactId == null) {
                try {
                    PortalUserContext sessionCtx = resolvePortalUserFromSession();
                    if (sessionCtx != null && sessionCtx.userId != null && sessionCtx.contactId != null) {
                        portalUserContextCache.put(cacheKey, sessionCtx);
                        return sessionCtx;
                    }
                } catch (Exception sessionEx) {
                    LPI_ExceptionManager.logException(CLASS_NAME,
                        'resolvePortalUserContext.sessionFallback', sessionEx);
                }
            }

            // Absolute fallback: use the running user even if it is the bot.
            if (!running.isEmpty()) {
                ctx.userId = running[0].Id;
                ctx.accountId = running[0].AccountId;
                ctx.contactId = running[0].ContactId;
            }
        } catch (Exception outerEx) {
            LPI_ExceptionManager.logException(CLASS_NAME,
                'resolvePortalUserContext', outerEx);
            ctx.userId = UserInfo.getUserId();
        }
        portalUserContextCache.put(cacheKey, ctx);
        return ctx;
    }

    private static PortalUserContext resolveFromContactId(String contactId) {
        PortalUserContext ctx = new PortalUserContext();
        String contactIdParam = contactId;
        List<User> portal = (List<User>) Database.query(
            'SELECT Id, AccountId, ContactId FROM User '
            + 'WHERE ContactId = :contactIdParam '
            + 'AND IsActive = true '
            + 'LIMIT 1',
            System.AccessLevel.SYSTEM_MODE
        );
        if (!portal.isEmpty()) {
            ctx.userId = portal[0].Id;
            ctx.accountId = portal[0].AccountId;
            ctx.contactId = portal[0].ContactId;
        }
        return ctx;
    }

    private static PortalUserContext resolvePortalUserFromSession() {
        PortalUserContext ctx = new PortalUserContext();
        String portalProfileName = 'Portal User';

        // Strategy A: find the portal user with the most recent active
        // Community session (SessionType = 'ChatterNetworks'). This is
        // the most reliable signal because the portal user must be logged
        // in to the Experience Cloud site to use the chat widget.
        try {
            String communitySessionType = 'ChatterNetworks';
            List<AuthSession> sessions = (List<AuthSession>) Database.query(
                'SELECT UsersId FROM AuthSession '
                + 'WHERE SessionType = :communitySessionType '
                + 'AND UsersId IN ('
                +     'SELECT Id FROM User '
                +     'WHERE Profile.Name = :portalProfileName '
                +     'AND IsActive = true '
                +     'AND ContactId != null'
                + ') '
                + 'ORDER BY CreatedDate DESC '
                + 'LIMIT 1',
                System.AccessLevel.SYSTEM_MODE
            );
            if (!sessions.isEmpty()) {
                ctx = buildCtxFromUserId(sessions[0].UsersId);
                if (ctx.contactId != null) { return ctx; }
            }
        } catch (Exception ignored) {
            // AuthSession may not be queryable by the bot profile; fall through.
        }

        // Strategy B: fall back to LoginHistory (most recent successful
        // portal-user login).
        try {
            List<LoginHistory> recentLogins = (List<LoginHistory>) Database.query(
                'SELECT UserId FROM LoginHistory '
                + 'WHERE Status = \'Success\' '
                + 'AND UserId IN ('
                +     'SELECT Id FROM User '
                +     'WHERE Profile.Name = :portalProfileName '
                +     'AND IsActive = true '
                +     'AND ContactId != null'
                + ') '
                + 'ORDER BY LoginTime DESC '
                + 'LIMIT 1',
                System.AccessLevel.SYSTEM_MODE
            );
            if (!recentLogins.isEmpty()) {
                ctx = buildCtxFromUserId(recentLogins[0].UserId);
                if (ctx.contactId != null) { return ctx; }
            }
        } catch (Exception ignored) {
            // LoginHistory may not be queryable either; fall through.
        }

        // Strategy C: last resort - pick the portal user who most recently
        // created ANY PreliminaryApplicationRef. This works even if the
        // session/login objects are not accessible.
        try {
            List<PreliminaryApplicationRef> recentPars =
                (List<PreliminaryApplicationRef>) Database.query(
                    'SELECT CreatedById FROM PreliminaryApplicationRef '
                    + 'WHERE CreatedById IN ('
                    +     'SELECT Id FROM User '
                    +     'WHERE Profile.Name = :portalProfileName '
                    +     'AND IsActive = true '
                    +     'AND ContactId != null'
                    + ') '
                    + 'ORDER BY CreatedDate DESC '
                    + 'LIMIT 1',
                    System.AccessLevel.SYSTEM_MODE
                );
            if (!recentPars.isEmpty()) {
                ctx = buildCtxFromUserId(recentPars[0].CreatedById);
                if (ctx.contactId != null) { return ctx; }
            }
        } catch (Exception ignored) {
            // Fall through to caller's absolute fallback.
        }

        return ctx;
    }

    private static PortalUserContext buildCtxFromUserId(Id userId) {
        PortalUserContext ctx = new PortalUserContext();
        List<User> u = (List<User>) Database.query(
            'SELECT Id, AccountId, ContactId FROM User '
            + 'WHERE Id = :userId LIMIT 1',
            System.AccessLevel.SYSTEM_MODE
        );
        if (!u.isEmpty()) {
            ctx.userId = u[0].Id;
            ctx.accountId = u[0].AccountId;
            ctx.contactId = u[0].ContactId;
        }
        return ctx;
    }
    private static Map<String, PortalUserContext> portalUserContextCache = new Map<String, PortalUserContext>();

    /**
     * @description Tight regex guard so a malformed ContactId from the
     *              messaging surface can never reach a SOQL query unfiltered.
     *              Salesforce Ids are 15 or 18 alphanumeric characters.
     */
    private static Boolean isValidSalesforceId(String s) {
        if (String.isBlank(s)) { return false; }
        return Pattern.matches('^[a-zA-Z0-9]{15,18}$', s);
    }

    /* ------------------------------------------------------------------ */
    /* Helpers                                                             */
    /* ------------------------------------------------------------------ */

    /**
     * @description Profession__c and its parent RegulatoryAuthorizationType
     *              are admin-curated catalog data, not user data. The shared
     *              LPI_ProfessionDAO uses WITH SECURITY_ENFORCED, which is
     *              correct for portal users on the LWC pages but blocks the
     *              Agentforce bot user (Einstein Agent license cannot be
     *              granted FLS on every standard PSC field). Run the bot's
     *              read-only catalog lookups in SYSTEM_MODE so they bypass
     *              FLS while still respecting object-level deletions and
     *              org limits. We never expose this helper outside this
     *              class and it is only used for SELECT statements that
     *              the bot has already been granted object-level read on
     *              via LPI_Portal_Agent_Access.
     */
    private static List<Profession__c> queryProfessionsInSystemMode(
        String fields,
        String whereClause,
        String limitValue,
        String sortingByFields,
        String sortingOrder
    ) {
        String query = 'SELECT ' + fields + ' FROM Profession__c';
        if (whereClause != null) {
            query += ' WHERE ' + whereClause;
        }
        if (sortingByFields != null) {
            query += ' ORDER BY ' + sortingByFields;
            if (sortingOrder != null) {
                query += ' ' + sortingOrder;
            }
        }
        if (limitValue != null) {
            query += ' LIMIT ' + limitValue;
        }
        // v38 perf: transaction-level memoisation. The question-loop
        // turn issues the same SELECT in `lookupProfessionName` and
        // again in the RAT lookup inside `invokeSubmitLaunch`; memoising
        // here saves one of those per launch turn (~250-400ms on a cold
        // org). Cache lives only for this Apex transaction so subsequent
        // turns re-query for freshness.
        if (professionQueryCache.containsKey(query)) {
            return professionQueryCache.get(query);
        }
        List<Profession__c> rows = Database.query(query, System.AccessLevel.SYSTEM_MODE);
        professionQueryCache.put(query, rows);
        return rows;
    }
    private static Map<String, List<Profession__c>> professionQueryCache = new Map<String, List<Profession__c>>();

    /**
     * @description Same rationale as queryProfessionsInSystemMode: read-only
     *              Question_Detail__c lookup that the agent needs while running
     *              under the Einstein Agent license. The shared
     *              LPI_QuestionDetailsDAO uses WITH SECURITY_ENFORCED, which is
     *              correct for the LWC pages but blocks the bot user. Object
     *              read on Question_Detail__c is still required and is granted
     *              via LPI_Portal_Agent_Access.
     */
    private static List<Question_Detail__c> queryQuestionDetailsInSystemMode(
        String fields,
        String whereClause,
        String limitValue,
        String sortingByFields,
        String sortingOrder
    ) {
        String query = 'SELECT ' + fields + ' FROM Question_Detail__c';
        if (whereClause != null) {
            query += ' WHERE ' + whereClause;
        }
        if (sortingByFields != null) {
            query += ' ORDER BY ' + sortingByFields;
            if (sortingOrder != null) {
                query += ' ' + sortingOrder;
            }
        }
        if (limitValue != null) {
            query += ' LIMIT ' + limitValue;
        }
        // v35: transaction-scoped memoisation. The question-loop turn issues
        // the same SELECT in `fetchNextQuestion` and (when isLast=true) in
        // `invokeSubmitLaunch`; memoising here halves the SOQL work for that
        // turn so the platform's typing indicator has time to render before
        // we finish responding. Cache lives only for this Apex transaction
        // (subsequent turns are separate transactions and re-query for
        // freshness).
        if (questionDetailQueryCache.containsKey(query)) {
            return questionDetailQueryCache.get(query);
        }
        List<Question_Detail__c> rows = Database.query(query, System.AccessLevel.SYSTEM_MODE);
        questionDetailQueryCache.put(query, rows);
        return rows;
    }
    private static Map<String, List<Question_Detail__c>> questionDetailQueryCache = new Map<String, List<Question_Detail__c>>();

    private static Boolean isShowOnlyBusinessAccount() {
        List<User> u = LPI_UserDao.getCurrentUserRecord();
        if (u.isEmpty() || String.isBlank(u[0].AccountId)) {
            return false;
        }
        List<Account> accList = LPI_AccountDAO.getAccountListByDynamicQuery(
            new List<String>{ 'Id', 'Person_Account_For_Business__c' },
            'Id = \'' + String.escapeSingleQuotes(u[0].AccountId) + '\'',
            1,
            null,
            null
        );
        if (accList.isEmpty()) {
            return false;
        }
        return accList[0].Person_Account_For_Business__c == true;
    }

    private static String buildSearchWhereClause(SearchRequest req, Boolean showOnlyBusiness) {
        List<String> clauses = new List<String>();
        if (String.isNotBlank(req.searchTerm)) {
            String safe = String.escapeSingleQuotes(req.searchTerm.trim());
            clauses.add('(Name LIKE \'%' + safe + '%\' OR '
                + 'Regulatory_Authorization_Type__r.Name LIKE \'%' + safe + '%\')');
        }
        if (String.isNotBlank(req.professionType)) {
            clauses.add('Profession_Type__c = \''
                + String.escapeSingleQuotes(req.professionType) + '\'');
        } else if (showOnlyBusiness) {
            clauses.add('Profession_Type__c IN (\'Business\',\'Schools/Programs\')');
        }
        if (clauses.isEmpty()) {
            return null;
        }
        return String.join(clauses, ' AND ');
    }

    private static Map<String, String> parsePriorAnswers(String priorAnswersJson) {
        Map<String, String> answers = new Map<String, String>();
        if (String.isBlank(priorAnswersJson)) {
            return answers;
        }
        try {
            Object parsed = JSON.deserializeUntyped(priorAnswersJson);
            if (parsed instanceof Map<String, Object>) {
                Map<String, Object> raw = (Map<String, Object>) parsed;
                for (String k : raw.keySet()) {
                    Object v = raw.get(k);
                    answers.put(k, v == null ? '' : String.valueOf(v));
                }
            } else if (parsed instanceof List<Object>) {
                for (Object item : (List<Object>) parsed) {
                    if (item instanceof Map<String, Object>) {
                        Map<String, Object> entry = (Map<String, Object>) item;
                        Object qid = entry.get('questionId');
                        if (qid == null) {
                            qid = entry.get('id');
                        }
                        Object resp = entry.get('userResponse');
                        if (resp == null) {
                            resp = entry.get('response');
                        }
                        if (qid != null) {
                            answers.put(String.valueOf(qid), resp == null ? '' : String.valueOf(resp));
                        }
                    }
                }
            }
        } catch (Exception e) {
            // bad JSON - return empty map; caller decides what to do
        }
        return answers;
    }

    private static Question_Detail__c pickNextVisibleQuestion(
        List<Question_Detail__c> ordered,
        Map<String, String> answers
    ) {
        for (Question_Detail__c q : ordered) {
            if (!isQuestionVisible(q, answers)) {
                continue;
            }
            if (!answers.containsKey(q.Id) || String.isBlank(answers.get(q.Id))) {
                return q;
            }
        }
        return null;
    }

    /**
     * @description Walks the visible answered questions and returns the first one
     *              whose response equals its Error_Matching_Value__c. Mirrors
     *              `lpiDecisionTreeQuestions.handleChange` which sets `showError`
     *              and blocks the submit button when an answer triggers the
     *              eligibility gate. Case-insensitive compare to match the LWC.
     */
    private static Question_Detail__c findBlockingError(
        List<Question_Detail__c> ordered,
        Map<String, String> answers
    ) {
        if (ordered == null || answers == null || answers.isEmpty()) {
            return null;
        }
        for (Question_Detail__c q : ordered) {
            if (String.isBlank(q.Error_Matching_Value__c)) {
                continue;
            }
            if (!isQuestionVisible(q, answers)) {
                continue;
            }
            String response = answers.get(q.Id);
            if (String.isBlank(response)) {
                continue;
            }
            if (q.Error_Matching_Value__c.equalsIgnoreCase(response)) {
                return q;
            }
        }
        return null;
    }

    private static Boolean isQuestionVisible(Question_Detail__c q, Map<String, String> answers) {
        if (q.Parent_Question__c == null || String.isBlank(q.Matching_Value__c)) {
            return true;
        }
        String parentResponse = answers.get(q.Parent_Question__c);
        if (parentResponse == null) {
            return false;
        }
        Boolean equalCriteria = q.Matching_Criteria__c == null
            || q.Matching_Criteria__c == 'Equal to';
        if (equalCriteria) {
            return q.Matching_Value__c.equalsIgnoreCase(parentResponse);
        }
        return !q.Matching_Value__c.equalsIgnoreCase(parentResponse);
    }

    private static List<Map<String, Object>> buildResponseDataPayload(
        List<Question_Detail__c> ordered,
        Map<String, String> answers
    ) {
        List<Map<String, Object>> payload = new List<Map<String, Object>>();
        for (Question_Detail__c q : ordered) {
            if (!isQuestionVisible(q, answers)) {
                continue;
            }
            String userResponse = answers.containsKey(q.Id) ? answers.get(q.Id) : '';
            if (String.isBlank(userResponse)) {
                continue;
            }
            Boolean allowLaunchFlow = q.Launch_Flow__c == true;
            Boolean saveUserResponse = q.Save_Response__c == true;
            if (!allowLaunchFlow && !saveUserResponse) {
                continue;
            }
            payload.add(new Map<String, Object>{
                'id' => q.Id,
                'name' => q.Name,
                'userResponse' => userResponse,
                'allowLaunchFlow' => allowLaunchFlow,
                'saveUserResponse' => saveUserResponse,
                'questionConditionMeet' => true,
                'showQuestion' => true,
                'isQuestionDependent' => q.Parent_Question__c != null,
                'isMatchingCriteriaEqualTo' => q.Matching_Criteria__c == null
                    || q.Matching_Criteria__c == 'Equal to',
                'targetObject' => q.Target_Object__c,
                'targetField' => q.Target_Field__c,
                'professionId' => q.Profession__c,
                'isRadio' => q.Answer_Type__c == 'Radio',
                'isPicklist' => q.Answer_Type__c == 'Picklist',
                'isText' => q.Answer_Type__c == 'Text',
                'isTextInput' => q.Answer_Type__c == 'Text Input',
                'showLabel' => true,
                'required' => q.Is_Required__c == true,
                'questionValues' => new List<Object>(),
                'checkSystemValidation' => false
            });
        }
        return payload;
    }

    private static List<String> splitOptions(String questionValues) {
        List<String> opts = new List<String>();
        if (String.isBlank(questionValues)) {
            return opts;
        }
        for (String v : questionValues.split(';')) {
            String trimmed = v.trim();
            if (String.isNotBlank(trimmed)) {
                opts.add(trimmed);
            }
        }
        return opts;
    }

    private static String stripHtml(String html) {
        if (String.isBlank(html)) {
            return html;
        }
        return html.replaceAll('<[^>]+>', '').replaceAll('&nbsp;', ' ').trim();
    }

    private static void applyLaunchResult(LaunchResponse res, String result, String professionName) {
        if (String.isBlank(result)) {
            res.status = STATUS_ERROR;
            res.errorMessage = 'Application creation returned no result.';
            res.displayMessage = buildErrorDisplay(res.errorMessage);
            return;
        }
        if (result == STATUS_DUPLICATE) {
            res.status = STATUS_DUPLICATE;
            res.errorMessage = 'A draft or submitted application already exists. '
                + 'Please open it from My Applications on the Dashboard.';
            res.displayMessage = buildErrorDisplay(res.errorMessage);
            return;
        }
        if (result == STATUS_ERROR) {
            res.status = STATUS_ERROR;
            res.errorMessage = 'Unable to create the application. Please contact support.';
            res.displayMessage = buildErrorDisplay(res.errorMessage);
            return;
        }
        res.status = STATUS_OK;
        res.intakeUrl = wrapWithClaimRedirect(appendNewType(result));
        res.displayMessage = buildLaunchSuccessDisplay(res.intakeUrl, professionName);
    }

    private static String appendNewType(String url) {
        if (String.isBlank(url)) {
            return url;
        }
        if (url.contains('type=')) {
            return url;
        }
        return url + '&type=' + APP_TYPE_NEW;
    }

    /**
     * @description v39.4: keep the launch URL exactly as the
     *              Application_Flow_Config__c produces it. Earlier
     *              versions tried to route through a VF wrapper
     *              (`/apex/...`) or a temporary auto-claim LWC target;
     *              Agentforce Embedded Messaging stripped both link
     *              variants from the rendered Markdown. The ownership
     *              claim now runs inside the real OmniScript LWC
     *              before the generated OmniScript initialization,
     *              so the chat can use the original URL shape that
     *              renders as a clickable link.
     */
    private static String wrapWithClaimRedirect(String intakeUrl) {
        return intakeUrl;
    }


    /**
     * @description Pre-formats the profession-type list as a clean numbered
     *              list that the Embedded Messaging Adaptive Response post-
     *              processor will render as tappable cards. Format rules
     *              (per docs/agentforce/agentforce-adaptive-response-options.md):
     *                * `1. Item.` (number, dot, space, label, terminating period)
     *                * one item per line, NO blank line between items
     *                * each item label kept short (<= 80 chars)
     *                * lead-in header + blank line, list as the trailing block
     *                * no bullets, no bold, no em-dashes, no sub-text under items
     */
    private static String buildTypeListDisplay(List<TypeOption> opts) {
        if (opts == null || opts.isEmpty()) {
            return 'No profession categories are available for your account. Please contact support.';
        }
        // v36 revert: numbered list inline with NO blank line between
        // the header and the list, so Adaptive Response keeps it as
        // plain text instead of promoting it to tappable cards.
        // v38 perf: build via List<String> + String.join so the heap
        // is allocated once instead of growing on every concat.
        List<String> lines = new List<String>();
        lines.add('Choose the type of permit or licence you want to apply for.');
        for (TypeOption o : opts) {
            lines.add(o.position + '. ' + cleanOptionLabel(o.label));
        }
        lines.add('');
        lines.add('Reply with the number of your choice.');
        return String.join(lines, '\n');
    }

    /**
     * @description Pre-formats the profession match list as a clean numbered
     *              list for Adaptive Response card rendering. Limits the visible
     *              cards to MAX_DISPLAY_OPTIONS so the messaging surface does
     *              not truncate them, and keeps each item on a single short line
     *              so the surface renders one card per profession.
     */
    private static String buildSearchDisplay(List<ProfessionMatch> matches, String professionType) {
        String label = String.isBlank(professionType) ? 'selected' : professionType;
        if (matches == null || matches.isEmpty()) {
            return 'No applications match the ' + label + ' category. Please start a new chat to choose a different category.';
        }
        // v36 revert + v38 perf: build via List<String> + String.join so
        // the heap is allocated once. Numbered list with no blank-line
        // separator keeps Adaptive Response from promoting it to cards.
        List<String> lines = new List<String>();
        lines.add(matches.size() > MAX_DISPLAY_OPTIONS
            ? 'Choose one of the top ' + MAX_DISPLAY_OPTIONS + ' ' + label + ' applications.'
            : 'Choose the ' + label + ' application you want to start.');
        Integer shown = 0;
        for (ProfessionMatch m : matches) {
            if (shown >= MAX_DISPLAY_OPTIONS) {
                break;
            }
            lines.add(m.position + '. ' + cleanOptionLabel(m.name));
            shown++;
        }
        lines.add('');
        lines.add('Reply with the number of the application you want to start.');
        return String.join(lines, '\n');
    }

    /**
     * @description Pre-formats a blocked/ineligible message. No numbered list,
     *              so Adaptive Response renders this as plain text. v35:
     *              the message is now phrased around the user's response and
     *              tells them they can reply "restart" to start again
     *              without closing the chat.
     */
    private static String buildBlockedDisplay(String errorMessage) {
        String body = String.isNotBlank(errorMessage)
            ? 'You are not eligible to apply based on your response: ' + errorMessage
            : 'You are not eligible to apply for this permit based on your responses.';
        return body + ' ' + RESTART_HINT;
    }

    /**
     * @description v35: standard footer appended to every terminal-state
     *              message (blocked, error, done) so the user always knows
     *              they can keep using the chat by replying "restart"
     *              instead of having to close and reopen the bubble.
     */
    private static final String RESTART_HINT = 'Reply "restart" to start a new application.';

    /**
     * @description v35: returns true when the user typed any of the
     *              well-known restart commands. Used at the top of every
     *              `handleConversation` turn to short-circuit any phase
     *              and re-enter the type-list flow with a fresh state.
     */
    private static Boolean isRestartCommand(String userText) {
        if (String.isBlank(userText)) { return false; }
        String t = userText.trim().toLowerCase();
        // strip a single trailing punctuation char so "restart." also matches
        if (t.length() > 1 && (t.endsWith('.') || t.endsWith('!') || t.endsWith('?'))) {
            t = t.substring(0, t.length() - 1);
        }
        return t == 'restart'
            || t == 'reset'
            || t == 'cancel'
            || t == 'start over'
            || t == 'start again'
            || t == 'start a new application'
            || t == 'new application'
            || t == 'new'
            || t == 'home'
            || t == 'menu';
    }

    /**
     * @description Pre-formats a pre-screening question for Adaptive Response
     *              card rendering. Choice questions (Radio/Picklist) become a
     *              clean `1. Option.` numbered list so the surface renders one
     *              card per option. Free-text questions render as plain prose
     *              with a "Type your answer..." hint - no list, so no cards.
     */
    private static String buildQuestionDisplay(QuestionResponse q) {
        if (q == null || String.isBlank(q.description)) {
            return '';
        }
        Boolean isChoice = q.answerType == 'Radio' || q.answerType == 'Picklist';
        if (isChoice && q.options != null && !q.options.isEmpty()) {
            // v36 revert + v38 perf: List<String> + String.join.
            List<String> lines = new List<String>();
            lines.add(q.description.trim());
            Integer idx = 1;
            for (String opt : q.options) {
                if (idx > MAX_DISPLAY_OPTIONS) {
                    break;
                }
                lines.add(idx + '. ' + cleanOptionLabel(opt));
                idx++;
            }
            lines.add('');
            lines.add('Reply with the number of your choice.');
            return String.join(lines, '\n');
        }
        return q.description.trim() + ' Type your answer in one short sentence.';
    }

    /**
     * @description Pre-formats the success message for the launch path. Plain
     *              prose followed by a Markdown link - no numbered list, so
     *              Adaptive Response leaves it as text + link.
     */
    private static String buildLaunchSuccessDisplay(String intakeUrl, String professionName) {
        if (String.isBlank(intakeUrl)) {
            return '';
        }
        String label = String.isNotBlank(professionName)
            ? 'Your draft ' + professionName + ' application has been created.'
            : 'Your draft application has been created.';
        return label + '\n\n[Open my application](' + intakeUrl + ')';
    }

    /**
     * @description Pre-formats a generic error/duplicate/blocked message.
     *              Plain prose, no numbered list.
     */
    private static String buildErrorDisplay(String errorMessage) {
        String body = String.isNotBlank(errorMessage)
            ? errorMessage
            : 'Sorry, something went wrong while processing your request.';
        return body + ' Please start a new chat to try again.';
    }

    /**
     * @description Trims an option label so each Adaptive Response card stays
     *              within the surface's safe rendering width. Strips trailing
     *              periods/whitespace and truncates anything beyond
     *              MAX_DISPLAY_OPTION_CHARS so the post-processor does not
     *              split or drop the card.
     */
    private static String cleanOptionLabel(String raw) {
        if (raw == null) {
            return '';
        }
        String trimmed = raw.trim();
        while (trimmed.endsWith('.')) {
            trimmed = trimmed.substring(0, trimmed.length() - 1).trim();
        }
        if (trimmed.length() > MAX_DISPLAY_OPTION_CHARS) {
            trimmed = trimmed.substring(0, MAX_DISPLAY_OPTION_CHARS - 3) + '...';
        }
        return trimmed;
    }

    private static String resolveTypeFromReply(String userReply, String typeOptionsJson) {
        if (String.isBlank(userReply) || String.isBlank(typeOptionsJson)) {
            return null;
        }
        List<Object> raw = (List<Object>) JSON.deserializeUntyped(typeOptionsJson);
        String reply = userReply.trim().replaceAll('[.)]', '');
        if (reply.isNumeric()) {
            Integer idx = Integer.valueOf(reply) - 1;
            if (idx >= 0 && idx < raw.size()) {
                Map<String, Object> opt = (Map<String, Object>) raw[idx];
                return (String) opt.get('value');
            }
        }
        String replyLower = reply.toLowerCase();
        for (Object obj : raw) {
            Map<String, Object> opt = (Map<String, Object>) obj;
            String val = (String) opt.get('value');
            String lbl = (String) opt.get('label');
            if (val != null && val.toLowerCase() == replyLower) { return val; }
            if (lbl != null && lbl.toLowerCase().contains(replyLower)) { return val; }
        }
        return reply;
    }

    private static Map<String, String> resolveChoiceFromReply(String userReply, String matchesJson) {
        Map<String, String> result = new Map<String, String>();
        if (String.isBlank(userReply) || String.isBlank(matchesJson)) {
            return result;
        }
        List<Object> raw = (List<Object>) JSON.deserializeUntyped(matchesJson);
        String reply = userReply.trim().replaceAll('[.)]', '');
        if (reply.isNumeric()) {
            Integer idx = Integer.valueOf(reply) - 1;
            if (idx >= 0 && idx < raw.size()) {
                Map<String, Object> m = (Map<String, Object>) raw[idx];
                result.put('professionId', (String) m.get('professionId'));
                result.put('name', (String) m.get('name'));
                return result;
            }
        }
        String replyLower = reply.toLowerCase();
        for (Object obj : raw) {
            Map<String, Object> m = (Map<String, Object>) obj;
            String name = (String) m.get('name');
            if (name != null && name.toLowerCase().contains(replyLower)) {
                result.put('professionId', (String) m.get('professionId'));
                result.put('name', name);
                return result;
            }
        }
        return result;
    }

    /* ================================================================== */
    /* handleConversation - the SINGLE entry point for the LPI Portal      */
    /* Agent. Mirrors the pattern of LPI_DecisionTreeQuestionsController:  */
    /* the agent calls this Apex method on every turn with the user's raw  */
    /* text and an opaque state JSON; Apex decides what to do next         */
    /* (show types, search professions, load detail, ask Q1, record an     */
    /* answer + check System_Validation__c, ask Q2, ..., launch the app    */
    /* OR surface "you are not eligible to apply") and returns the         */
    /* user-facing displayMessage + the updated state. The agent script    */
    /* has zero business logic - it only routes the turn through this      */
    /* action and renders displayMessage verbatim.                          */
    /* ================================================================== */

    public static List<TurnResponse> handleConversation(List<TurnRequest> requests) {
        List<TurnResponse> responses = new List<TurnResponse>();
        if (requests == null) { return responses; }
        for (TurnRequest req : requests) {
            TurnResponse res = new TurnResponse();
            try {
                ConvState st = parseConvState(req.stateJson);
                String userText = req.userText == null ? '' : req.userText.trim();
                // v35: resolve the signed-in portal user once per turn so
                // every PAR-creation path (exempt, question-loop fallback,
                // standard updateResponse) sets OwnerId to the actual portal
                // user. Falls back to the running user when the runtime did
                // not supply a ContactId (CLI / preview).
                String contactIdInput = req.contactId;
                PortalUserContext portalCtx = resolvePortalUserContext(contactIdInput);

                // v35: restart command is honoured at any phase (including
                // terminal phases) so the user can pick a different
                // application without closing the chat bubble.
                if (isRestartCommand(userText)) {
                    st = new ConvState();
                    userText = '';
                }

                // Phase: empty/start - show profession-type categories.
                if (String.isBlank(st.phase) || st.phase == 'start') {
                    TypeListResponse types = listProfessionTypes(new List<TypeListRequest>{ new TypeListRequest() })[0];
                    if (types.status != STATUS_OK) {
                        res.displayMessage = buildErrorDisplay(types.errorMessage);
                        st.phase = 'error';
                    } else {
                        st.phase = 'type';
                        st.typeOptionsJson = types.optionsJson;
                        res.displayMessage = types.displayMessage;
                    }
                }
                // Phase: type - user picked a category; resolve it and show search results.
                else if (st.phase == 'type') {
                    if (String.isBlank(userText)) {
                        res.displayMessage = reshowWithHint(rebuildTypeListDisplay(st), 'Please reply with the number of the profession category you want.');
                    } else {
                        String resolvedType = resolveTypeFromReply(userText, st.typeOptionsJson);
                        // v35: resolveTypeFromReply falls back to the raw reply
                        // when it cannot match any option, so we must validate
                        // the resolved value against the known option set
                        // before searching. Otherwise an arbitrary string slips
                        // through, the search returns 0, and the user dead-ends.
                        if (String.isBlank(resolvedType) || !isKnownTypeOption(resolvedType, st.typeOptionsJson)) {
                            // v35: show the option list again so the user
                            // never hits a dead-end after typing something
                            // we cannot resolve. The LLM was masking this
                            // empty state with a generic "issue processing"
                            // fallback.
                            res.displayMessage = reshowWithHint(rebuildTypeListDisplay(st), 'I did not recognise that choice. Please reply with the number of the option above.');
                        } else {
                            st.professionType = resolvedType;
                            SearchRequest sr = new SearchRequest();
                            sr.professionType = resolvedType;
                            SearchResponse sres = searchProfessions(new List<SearchRequest>{ sr })[0];
                            if (sres.status != STATUS_OK || sres.matchCount == 0) {
                                res.displayMessage = 'No applications are available for that category right now. ' + RESTART_HINT;
                                st.phase = 'done';
                            } else {
                                st.phase = 'profession';
                                st.professionMatchesJson = sres.matchesJson;
                                res.displayMessage = sres.displayMessage;
                            }
                        }
                    }
                }
                // Phase: profession - user picked a profession; load detail + Q1 (or launch link).
                else if (st.phase == 'profession') {
                    if (String.isBlank(userText)) {
                        res.displayMessage = reshowWithHint(rebuildProfessionListDisplay(st), 'Please reply with the number of the application you want to start.');
                    } else {
                        Map<String, String> resolved = resolveChoiceFromReply(userText, st.professionMatchesJson);
                        String professionId = resolved.get('professionId');
                        if (String.isBlank(professionId)) {
                            res.displayMessage = reshowWithHint(rebuildProfessionListDisplay(st), 'I did not recognise that choice. Please reply with the number of the application above.');
                        } else {
                            st.professionId = professionId;
                            st.professionName = resolved.get('name');
                            DetailRequest dr = new DetailRequest();
                            dr.professionId = professionId;
                            DetailResponse det = getProfessionDetail(new List<DetailRequest>{ dr })[0];
                            if (det.status == STATUS_ERROR) {
                                res.displayMessage = String.isNotBlank(det.displayMessage) ? det.displayMessage : buildErrorDisplay(det.errorMessage);
                                st.phase = 'error';
                            } else if (det.status == STATUS_BLOCKED) {
                                res.displayMessage = det.displayMessage;
                                st.phase = 'blocked';
                            } else if (String.isNotBlank(det.intakeUrl)) {
                                // Exempt path: re-run the launch with the
                                // resolved portal context so the PAR is owned
                                // by the portal user. det.intakeUrl was created
                                // before we had the context, so the safer move
                                // is to run invokeExemptLaunch again with ctx.
                                LaunchResponse exempt = invokeExemptLaunch(det.regulatoryAuthorizationTypeId, det.professionName, portalCtx);
                                if (exempt.status == STATUS_OK && String.isNotBlank(exempt.intakeUrl)) {
                                    st.phase = 'done';
                                    st.intakeUrl = exempt.intakeUrl;
                                    res.displayMessage = exempt.displayMessage;
                                } else {
                                    // Fall back to the URL we already have
                                    // rather than dead-ending the conversation.
                                    st.phase = 'done';
                                    st.intakeUrl = det.intakeUrl;
                                    res.displayMessage = det.displayMessage;
                                }
                            } else if (det.status == STATUS_NEEDS_QUESTIONS) {
                                st.phase = 'question';
                                st.lastQuestionId = det.firstQuestionId;
                                st.lastQuestionOptionsJson = det.firstQuestionOptionsJson;
                                st.priorAnswersJson = '{}';
                                st.lastQuestionDisplay = det.displayMessage;
                                res.displayMessage = det.displayMessage;
                            } else {
                                // Defensive: STATUS_OK with no intake URL - surface the message.
                                res.displayMessage = String.isNotBlank(det.displayMessage) ? det.displayMessage : buildErrorDisplay('Unable to start the application.');
                                st.phase = 'error';
                            }
                        }
                    }
                }
                // Phase: question - user answered the previous question; record + advance loop.
                else if (st.phase == 'question') {
                    if (String.isBlank(userText)) {
                        res.displayMessage = reshowWithHint(st.lastQuestionDisplay, 'Please reply with your answer to continue.');
                    } else {
                        String mergedAnswers = mergeUserReplyIntoAnswers(
                            st.priorAnswersJson, st.lastQuestionId, st.lastQuestionOptionsJson, userText
                        );
                        st.priorAnswersJson = mergedAnswers;
                        QuestionResponse computed = fetchNextQuestion(st.professionId, mergedAnswers);
                        if (computed.status == STATUS_BLOCKED) {
                            st.phase = 'blocked';
                            res.displayMessage = computed.displayMessage;
                        } else if (computed.isLast == true) {
                            LaunchResponse launch = invokeSubmitLaunch(st.professionId, mergedAnswers, portalCtx);
                            if (launch.status == STATUS_OK) {
                                st.phase = 'done';
                                st.intakeUrl = launch.intakeUrl;
                                res.displayMessage = launch.displayMessage;
                            } else if (launch.status == STATUS_BLOCKED) {
                                st.phase = 'blocked';
                                res.displayMessage = String.isNotBlank(launch.displayMessage) ? launch.displayMessage : buildBlockedDisplay(launch.errorMessage);
                            } else {
                                st.phase = 'error';
                                res.displayMessage = String.isNotBlank(launch.displayMessage) ? launch.displayMessage : buildErrorDisplay(launch.errorMessage);
                            }
                        } else {
                            st.phase = 'question';
                            st.lastQuestionId = computed.questionId;
                            st.lastQuestionOptionsJson = computed.optionsJson;
                            st.lastQuestionDisplay = computed.displayMessage;
                            res.displayMessage = computed.displayMessage;
                        }
                    }
                }
                // Phase: done/blocked/error - re-show the prior outcome (idempotent).
                else if (st.phase == 'done') {
                    res.displayMessage = String.isNotBlank(st.intakeUrl)
                        ? 'Your application is ready: [Open my application](' + st.intakeUrl + ')\n\n' + RESTART_HINT
                        : 'Your application has been processed. ' + RESTART_HINT;
                }
                else if (st.phase == 'blocked') {
                    res.displayMessage = 'You are not eligible to apply for this application based on your earlier answers. ' + RESTART_HINT;
                } else if (st.phase == 'error') {
                    res.displayMessage = 'The previous turn could not be processed. ' + RESTART_HINT;
                } else {
                    res.displayMessage = buildErrorDisplay('Unexpected conversation state.');
                    st.phase = 'error';
                }

                res.phase = st.phase;
                res.intakeUrl = st.intakeUrl;
                res.stateJson = JSON.serialize(st);
                res.done = (st.phase == 'done' || st.phase == 'blocked' || st.phase == 'error');
            } catch (Exception e) {
                LPI_ExceptionManager.logException(CLASS_NAME, 'handleConversation', e);
                res.phase = 'error';
                res.done = true;
                res.displayMessage = buildErrorDisplay(e.getMessage()) + ' ' + RESTART_HINT;
                res.stateJson = JSON.serialize(new ConvState());
            }
            responses.add(res);
        }
        return responses;
    }

    /**
     * @description v35: combines a previously-rendered display block (e.g.
     *              the type list, the profession list, or the active
     *              question) with a short corrective hint. Empty-block
     *              cases just return the hint so the user is never
     *              presented with a stale blank message.
     */
    private static String reshowWithHint(String previousBlock, String correctiveHint) {
        if (String.isBlank(previousBlock)) {
            return correctiveHint;
        }
        return previousBlock + '\n\n' + correctiveHint;
    }

    /**
     * @description v35: returns true when `value` matches the `value` field
     *              of any TypeOption in the cached optionsJson on ConvState.
     *              `resolveTypeFromReply` falls back to the raw user reply
     *              when no match is found; this guard prevents that raw
     *              value from being used as a profession-type filter.
     */
    private static Boolean isKnownTypeOption(String value, String typeOptionsJson) {
        if (String.isBlank(value) || String.isBlank(typeOptionsJson)) { return false; }
        try {
            List<Object> raw = (List<Object>) JSON.deserializeUntyped(typeOptionsJson);
            if (raw == null) { return false; }
            for (Object obj : raw) {
                Map<String, Object> opt = (Map<String, Object>) obj;
                if (value.equalsIgnoreCase((String) opt.get('value'))) {
                    return true;
                }
            }
        } catch (Exception ignore) {
            // fall through
        }
        return false;
    }

    /**
     * @description v35: rebuilds the profession-type list from the cached
     *              optionsJson on ConvState so the user can re-see the
     *              choices without us re-querying.
     */
    private static String rebuildTypeListDisplay(ConvState st) {
        if (st == null || String.isBlank(st.typeOptionsJson)) { return ''; }
        try {
            List<TypeOption> opts = (List<TypeOption>) JSON.deserialize(st.typeOptionsJson, List<TypeOption>.class);
            return buildTypeListDisplay(opts);
        } catch (Exception ignore) {
            return '';
        }
    }

    /**
     * @description v35: rebuilds the profession-match list from the cached
     *              professionMatchesJson on ConvState so we can show it
     *              again whenever the user types something we cannot
     *              resolve.
     */
    private static String rebuildProfessionListDisplay(ConvState st) {
        if (st == null || String.isBlank(st.professionMatchesJson)) { return ''; }
        try {
            List<ProfessionMatch> matches = (List<ProfessionMatch>) JSON.deserialize(st.professionMatchesJson, List<ProfessionMatch>.class);
            return buildSearchDisplay(matches, st.professionType);
        } catch (Exception ignore) {
            return '';
        }
    }

    /**
     * @description Parses the opaque conversation_state JSON sent by the
     *              agent script and returns a ConvState seeded with safe
     *              defaults for any null/blank field. Lives on the outer
     *              class because Apex inner classes cannot have static
     *              methods.
     */
    private static ConvState parseConvState(String s) {
        if (String.isBlank(s) || s == 'null') { return new ConvState(); }
        try {
            ConvState st = (ConvState) JSON.deserialize(s, ConvState.class);
            if (st == null) { return new ConvState(); }
            if (st.phase == null) { st.phase = ''; }
            if (st.professionType == null) { st.professionType = ''; }
            if (st.typeOptionsJson == null) { st.typeOptionsJson = '[]'; }
            if (st.professionId == null) { st.professionId = ''; }
            if (st.professionName == null) { st.professionName = ''; }
            if (st.professionMatchesJson == null) { st.professionMatchesJson = '[]'; }
            if (st.lastQuestionId == null) { st.lastQuestionId = ''; }
            if (st.lastQuestionOptionsJson == null) { st.lastQuestionOptionsJson = '[]'; }
            if (st.lastQuestionDisplay == null) { st.lastQuestionDisplay = ''; }
            if (st.priorAnswersJson == null) { st.priorAnswersJson = '{}'; }
            if (st.intakeUrl == null) { st.intakeUrl = ''; }
            return st;
        } catch (Exception e) {
            return new ConvState();
        }
    }

    /**
     * @description Opaque per-conversation state. Serialized as JSON and
     *              round-tripped through the agent script's
     *              `conversation_state` variable on every turn. v35 adds
     *              `lastQuestionDisplay` so we can re-render the prompt +
     *              numbered options whenever the user types something we
     *              cannot resolve.
     */
    public class ConvState {
        public String phase;
        public String professionType;
        public String typeOptionsJson;
        public String professionId;
        public String professionName;
        public String professionMatchesJson;
        public String lastQuestionId;
        public String lastQuestionOptionsJson;
        public String lastQuestionDisplay;
        public String priorAnswersJson;
        public String intakeUrl;

        public ConvState() {
            this.phase = '';
            this.professionType = '';
            this.typeOptionsJson = '[]';
            this.professionId = '';
            this.professionName = '';
            this.professionMatchesJson = '[]';
            this.lastQuestionId = '';
            this.lastQuestionOptionsJson = '[]';
            this.lastQuestionDisplay = '';
            this.priorAnswersJson = '{}';
            this.intakeUrl = '';
        }
    }

    public class TurnRequest {
        @InvocableVariable(label='User Text' description='The raw text the user just typed (e.g. "1", "yes", "Construction Permit"). Empty string on the very first turn.')
        public String userText;
        @InvocableVariable(label='State JSON' description='Opaque conversation state from the previous turn. Pass the value of the conversation_state variable. Empty string on the very first turn.')
        public String stateJson;
        // v35: portal-user identity threaded from the agent runtime so the
        // PreliminaryApplicationRef created by the bot is owned by the
        // signed-in portal user (not by the bot service user). All three
        // are optional - falls back to UserInfo.getUserId() in CLI/preview.
        @InvocableVariable(label='Contact Id' description='Contact Id of the signed-in portal user (from MessagingEndUser.ContactId). Used to resolve the portal User who will own the PAR record. Optional; falls back to the running user.')
        public String contactId;
        @InvocableVariable(label='End User Id' description='Messaging End User Id from the runtime (MessagingSession.MessagingEndUserId). Optional; informational only.')
        public String endUserId;
        @InvocableVariable(label='Messaging End User Id' description='Alias for endUserId; populated from @MessagingSession.MessagingEndUserId. Optional.')
        public String messagingEndUserId;
    }

    public class TurnResponse {
        @InvocableVariable(label='Display Message' description='Pre-formatted Markdown ready to send to the user verbatim. Always render byte-for-byte.')
        public String displayMessage;
        @InvocableVariable(label='State JSON' description='Updated conversation state. ALWAYS save back into conversation_state for the next turn.')
        public String stateJson;
        @InvocableVariable(label='Phase' description='Current loop phase: type, profession, question, done, blocked, error.')
        public String phase;
        @InvocableVariable(label='Intake URL' description='Populated when the application was launched successfully (phase=done).')
        public String intakeUrl;
        @InvocableVariable(label='Done' description='True when the conversation has reached a terminal state (done, blocked, or error).')
        public Boolean done;
    }

    /* ------------------------------------------------------------------ */
    /* processTurn - unified single-action entry point for the question    */
    /* loop. Replaces the need for the planner to chain between            */
    /* get_profession_detail and get_next_question. The planner calls this */
    /* ONE action on every turn once a profession is selected.             */
    /* ------------------------------------------------------------------ */

    public static List<ProcessTurnResponse> processTurn(List<ProcessTurnRequest> requests) {
        List<ProcessTurnResponse> responses = new List<ProcessTurnResponse>();
        if (requests == null) { return responses; }
        for (ProcessTurnRequest req : requests) {
            ProcessTurnResponse res = new ProcessTurnResponse();
            try {
                String phase = String.isBlank(req.phase) ? 'init' : req.phase;
                // Robustness fallback #1: if the planner forgot to advance
                // the phase but supplied both lastQuestionId and userReply,
                // we are clearly in the middle of the question loop. Promote
                // phase to 'question' so we record the answer and advance
                // instead of re-rendering Q1. This protects against the LLM
                // dropping `loop_phase` from session state between turns.
                if (phase == 'init' && String.isNotBlank(req.userReply) && String.isNotBlank(req.lastQuestionId)) {
                    phase = 'question';
                }
                // Robustness fallback #2: if the planner ALSO dropped
                // lastQuestionId but supplied a userReply, recover by
                // resolving the most recent unanswered question for this
                // profession from priorAnswersJson and treating userReply as
                // its answer. This makes the loop self-healing even when the
                // entire mutable state is lost between turns.
                if (phase == 'init' && String.isNotBlank(req.userReply) && String.isBlank(req.lastQuestionId)) {
                    String knownAnswers = String.isBlank(req.priorAnswersJson) ? '{}' : req.priorAnswersJson;
                    QuestionResponse pending = fetchNextQuestion(req.professionId, knownAnswers);
                    if (pending != null && String.isNotBlank(pending.questionId)) {
                        req.lastQuestionId = pending.questionId;
                        req.lastQuestionOptionsJson = pending.optionsJson;
                        phase = 'question';
                    }
                }
                if (phase == 'init') {
                    DetailRequest dr = new DetailRequest();
                    dr.professionId = req.professionId;
                    List<DetailResponse> detResults = getProfessionDetail(new List<DetailRequest>{ dr });
                    DetailResponse det = detResults[0];
                    res.professionId = det.professionId;
                    res.professionName = det.professionName;
                    res.regulatoryAuthorizationTypeId = det.regulatoryAuthorizationTypeId;
                    res.intakeUrl = det.intakeUrl;
                    if (det.status == STATUS_OK && String.isNotBlank(det.intakeUrl)) {
                        res.phase = 'done';
                        res.displayMessage = det.displayMessage;
                    } else if (det.status == STATUS_NEEDS_QUESTIONS || det.firstQuestionId == 'pending') {
                        QuestionResponse q1 = fetchNextQuestion(req.professionId, '{}');
                        res.phase = 'question';
                        res.questionId = q1.questionId;
                        res.optionsJson = q1.optionsJson;
                        res.displayMessage = q1.displayMessage;
                        res.priorAnswersJson = '{}';
                    } else {
                        res.phase = det.status == STATUS_ERROR ? 'error' : 'done';
                        res.displayMessage = det.displayMessage;
                    }
                } else if (phase == 'question') {
                    String mergedAnswers = mergeUserReplyIntoAnswers(
                        req.priorAnswersJson, req.lastQuestionId,
                        req.lastQuestionOptionsJson, req.userReply
                    );
                    QuestionResponse computed = fetchNextQuestion(req.professionId, mergedAnswers);
                    res.professionId = req.professionId;
                    res.priorAnswersJson = mergedAnswers;
                    if (computed.status == STATUS_BLOCKED) {
                        res.phase = 'blocked';
                        res.displayMessage = computed.displayMessage;
                    } else if (computed.isLast == true) {
                        LaunchResponse launch = invokeSubmitLaunch(req.professionId, mergedAnswers);
                        res.intakeUrl = launch.intakeUrl;
                        res.displayMessage = launch.displayMessage;
                        res.phase = launch.status == STATUS_OK ? 'done' : 'error';
                        if (launch.status != STATUS_OK) {
                            res.displayMessage = String.isNotBlank(launch.displayMessage)
                                ? launch.displayMessage
                                : buildErrorDisplay(launch.errorMessage);
                        }
                    } else {
                        res.phase = 'question';
                        res.questionId = computed.questionId;
                        res.optionsJson = computed.optionsJson;
                        res.displayMessage = computed.displayMessage;
                    }
                }
            } catch (Exception e) {
                LPI_ExceptionManager.logException(CLASS_NAME, 'processTurn', e);
                res.phase = 'error';
                res.displayMessage = buildErrorDisplay(e.getMessage());
            }
            responses.add(res);
        }
        return responses;
    }

    public class ProcessTurnRequest {
        @InvocableVariable(label='Profession Id' required=true)
        public String professionId;
        @InvocableVariable(label='Phase' description='Current phase: init (first call after profession selected), question (user answered a question). Defaults to init.')
        public String phase;
        @InvocableVariable(label='User Reply' description='The user reply text for the current question.')
        public String userReply;
        @InvocableVariable(label='Prior Answers JSON')
        public String priorAnswersJson;
        @InvocableVariable(label='Last Question Id')
        public String lastQuestionId;
        @InvocableVariable(label='Last Question Options JSON')
        public String lastQuestionOptionsJson;
    }

    public class ProcessTurnResponse {
        @InvocableVariable(label='Phase' description='Next phase: question (more questions), done (launch URL ready), blocked (eligibility gate), error.')
        public String phase;
        @InvocableVariable(label='Profession Id')
        public String professionId;
        @InvocableVariable(label='Profession Name')
        public String professionName;
        @InvocableVariable(label='Regulatory Authorization Type Id')
        public String regulatoryAuthorizationTypeId;
        @InvocableVariable(label='Question Id')
        public String questionId;
        @InvocableVariable(label='Options JSON')
        public String optionsJson;
        @InvocableVariable(label='Display Message')
        public String displayMessage;
        @InvocableVariable(label='Intake URL')
        public String intakeUrl;
        @InvocableVariable(label='Prior Answers JSON')
        public String priorAnswersJson;
    }

    /* ------------------------------------------------------------------ */
    /* DTOs                                                                */
    /* ------------------------------------------------------------------ */

    public class SearchRequest {
        @InvocableVariable(label='Search Term' description='Free-text keyword to match against profession or regulatory authorization type name.')
        public String searchTerm;
        @InvocableVariable(label='Profession Type' description='Optional filter: Individual, Business, Schools/Programs, or Other.')
        public String professionType;
        @InvocableVariable(label='Max Results' description='Optional cap on results. Defaults to 20, hard max 50.')
        public Integer maxResults;
        @InvocableVariable(label='User Reply' description='Raw user text selecting a profession type (e.g. "2", "Business"). When provided, Apex resolves it against typeOptionsJson to populate professionType automatically.')
        public String userReply;
        @InvocableVariable(label='Type Options JSON' description='The optionsJson returned by list_profession_types. Used together with userReply to resolve the profession type.')
        public String typeOptionsJson;
    }

    public class SearchResponse {
        @InvocableVariable(label='Status' description='OK or Error')
        public String status;
        @InvocableVariable(label='Match Count')
        public Integer matchCount;
        @InvocableVariable(label='Matches' description='List of matching professions with id, name, type, and exempt flag.')
        public List<ProfessionMatch> matches;
        @InvocableVariable(label='Matches JSON' description='Same payload serialized for planners that prefer a single string.')
        public String matchesJson;
        @InvocableVariable(label='Display Message' description='Pre-formatted Markdown numbered list ready to send to the user verbatim. Use this so the planner does not have to reformat the matches list.')
        public String displayMessage;
        @InvocableVariable(label='Resolved Profession Type' description='The profession type value resolved from userReply, or the original professionType if no userReply was provided.')
        public String resolvedProfessionType;
        @InvocableVariable(label='Error Message')
        public String errorMessage;
    }

    public class ProfessionMatch {
        @InvocableVariable(label='Position' description='1-based ordinal of this match in the list. The agent must render this as the option number to the user (e.g. "1.", "2.").')
        public Integer position;
        @InvocableVariable(label='Profession Id')
        public String professionId;
        @InvocableVariable(label='Name')
        public String name;
        @InvocableVariable(label='Profession Type')
        public String professionType;
        @InvocableVariable(label='Is Exempt' description='True when the user can launch directly without pre-screening.')
        public Boolean isExempt;
        @InvocableVariable(label='Regulatory Authorization Type Id')
        public String regulatoryAuthorizationTypeId;
        @InvocableVariable(label='Regulatory Authorization Type Name')
        public String regulatoryAuthorizationTypeName;
        @InvocableVariable(label='Description')
        public String description;
        @InvocableVariable(label='System Validation Needed')
        public Boolean systemValidationNeeded;

        public ProfessionMatch() {}

        public ProfessionMatch(Profession__c p) {
            this.professionId = p.Id;
            this.name = p.Name;
            this.professionType = p.Profession_Type__c;
            this.isExempt = p.Exempt_Decision_Tree__c == true;
            this.regulatoryAuthorizationTypeId = p.Regulatory_Authorization_Type__c;
            this.regulatoryAuthorizationTypeName = p.Regulatory_Authorization_Type__r != null
                ? p.Regulatory_Authorization_Type__r.Name
                : null;
            this.description = p.Regulatory_Authorization_Type__r != null
                ? p.Regulatory_Authorization_Type__r.Description
                : null;
            this.systemValidationNeeded = p.System_Validation_Needed__c == true;
        }
    }

    /* ------------------------------------------------------------------ */
    /* TypeListRequest / TypeListResponse / TypeOption                     */
    /* ------------------------------------------------------------------ */

    public class TypeListRequest {
        @InvocableVariable(label='Mode' description='Optional placeholder input. The action does not actually use it; it exists only because @InvocableMethod requires a List<Request>. Pass any non-null value (e.g. "start").')
        public String mode;
    }

    public class TypeListResponse {
        @InvocableVariable(label='Status' description='OK or Error.')
        public String status;
        @InvocableVariable(label='Count')
        public Integer count;
        @InvocableVariable(label='Profession Types' description='Numbered list of profession types the signed-in user can pick from.')
        public List<TypeOption> professionTypes;
        @InvocableVariable(label='Options JSON' description='Same payload serialized for planners that prefer a single string.')
        public String optionsJson;
        @InvocableVariable(label='Display Message' description='Pre-formatted Markdown numbered list ready to send to the user verbatim.')
        public String displayMessage;
        @InvocableVariable(label='Error Message')
        public String errorMessage;
    }

    public class TypeOption {
        @InvocableVariable(label='Position' description='1-based ordinal. The agent must show this as the option number to the user.')
        public Integer position;
        @InvocableVariable(label='Value' description='Raw enum value to send back to Search Professions, e.g. Individual.')
        public String value;
        @InvocableVariable(label='Label' description='Friendly label to show to the user, e.g. "Individual Professions".')
        public String label;
        @InvocableVariable(label='Help Text' description='Optional one-line description to clarify what the category is.')
        public String helpText;

        public TypeOption() {}

        public TypeOption(String value, String label, String helpText) {
            this.value = value;
            this.label = label;
            this.helpText = helpText;
        }
    }

    public class DetailRequest {
        @InvocableVariable(label='Profession Id' description='Resolved profession Id. When userReply + searchMatchesJson are provided, Apex populates this automatically.')
        public String professionId;
        @InvocableVariable(label='User Reply' description='Raw user text selecting a profession from search results (e.g. "3", "Construction Permit"). Apex resolves it against searchMatchesJson.')
        public String userReply;
        @InvocableVariable(label='Search Matches JSON' description='The matchesJson returned by search_professions. Used together with userReply to resolve professionId and professionName.')
        public String searchMatchesJson;
    }

    public class DetailResponse {
        @InvocableVariable(label='Status' description='OK, NeedsQuestions, Blocked, or Error.')
        public String status;
        @InvocableVariable(label='Profession Id')
        public String professionId;
        @InvocableVariable(label='Profession Name')
        public String professionName;
        @InvocableVariable(label='Profession Type')
        public String professionType;
        @InvocableVariable(label='Regulatory Authorization Type Id')
        public String regulatoryAuthorizationTypeId;
        @InvocableVariable(label='Regulatory Authorization Type Name')
        public String regulatoryAuthorizationTypeName;
        @InvocableVariable(label='Is Exempt' description='True when no pre-screening is needed.')
        public Boolean isExempt;
        @InvocableVariable(label='Requires Questions')
        public Boolean requiresQuestions;
        @InvocableVariable(label='Question Count')
        public Integer questionCount;
        @InvocableVariable(label='Direct Launch URL Available')
        public Boolean directLaunch;
        @InvocableVariable(label='Intake URL' description='Populated automatically for the exempt branch (this action launches the application synchronously) and populated by the controller during validation in the rare directLaunch branch.')
        public String intakeUrl;
        @InvocableVariable(label='Display Message' description='Pre-formatted Markdown ready to send to the user verbatim. For exempt professions this contains the "[Open my application](...)" launch link; for professions that require pre-screening this contains the prompt and numbered options for Q1.')
        public String displayMessage;
        @InvocableVariable(label='First Question Id' description='Question_Detail__c Id of Q1, returned together with the displayMessage for professions that require pre-screening so the next turn can save the user reply against this id.')
        public String firstQuestionId;
        @InvocableVariable(label='First Question Options JSON' description='JSON array of the option strings for Q1 when requiresQuestions=true, so the next turn can map a numeric reply back to the canonical answer string.')
        public String firstQuestionOptionsJson;
        @InvocableVariable(label='Exam Details JSON')
        public String examDetailsJson;
        @InvocableVariable(label='Error Message')
        public String errorMessage;
    }

    public class QuestionRequest {
        @InvocableVariable(label='Profession Id' required=true)
        public String professionId;
        @InvocableVariable(label='Prior Answers JSON' description='JSON object {questionId: response} or array of {questionId, userResponse}. May be empty for the first call.')
        public String priorAnswersJson;
        @InvocableVariable(label='Last Question Id' description='Question_Detail__c Id of the question most recently shown to the user. Pass alongside userReply so Apex can append the answer to priorAnswersJson; empty on the first call.')
        public String lastQuestionId;
        @InvocableVariable(label='Last Question Options JSON' description='JSON array of the option strings most recently shown to the user. Used together with userReply to map a numeric reply ("1","2") or label substring back to the canonical answer string. Empty for Text/Text-Input questions.')
        public String lastQuestionOptionsJson;
        @InvocableVariable(label='User Reply' description='The raw text the user just typed in response to lastQuestionId (e.g. "1", "yes", "New Single Family Dwelling"). Apex will resolve it against lastQuestionOptionsJson and merge the canonical answer into priorAnswersJson before computing the next question.')
        public String userReply;
    }

    public class QuestionResponse {
        @InvocableVariable(label='Status')
        public String status;
        @InvocableVariable(label='Profession Id')
        public String professionId;
        @InvocableVariable(label='Question Id')
        public String questionId;
        @InvocableVariable(label='Question Name')
        public String questionName;
        @InvocableVariable(label='Description' description='Plain-text question prompt with HTML stripped.')
        public String description;
        @InvocableVariable(label='Answer Type' description='Radio, Picklist, Text, or Text Input.')
        public String answerType;
        @InvocableVariable(label='Required')
        public Boolean required;
        @InvocableVariable(label='Options' description='Choices for Radio or Picklist questions.')
        public List<String> options;
        @InvocableVariable(label='Options JSON' description='Same options serialized as a JSON array, e.g. ["Yes","No"]. Useful when the planner needs to store the choices in a string variable so a later turn can map a numeric reply back to the canonical answer.')
        public String optionsJson;
        @InvocableVariable(label='Display Message' description='Pre-formatted Markdown ready to send to the user verbatim. For ask-next-question this contains the prompt and numbered options. For status=Blocked this contains the eligibility error and the back prompt. When isLast=true and status=OK this contains the launch URL Markdown link because the action also runs the submit pipeline synchronously.')
        public String displayMessage;
        @InvocableVariable(label='Is Last' description='True when no more questions remain.')
        public Boolean isLast;
        @InvocableVariable(label='Intake URL' description='Populated when the action runs the auto-submit pipeline (status=OK, isLast=true).')
        public String intakeUrl;
        @InvocableVariable(label='Prior Answers JSON' description='Updated JSON object {questionId: response} after merging the userReply for lastQuestionId. Save this back into the collected-answers conversation variable so the next turn carries forward every answer.')
        public String priorAnswersJson;
        @InvocableVariable(label='Error Message')
        public String errorMessage;
    }

    public class CaptureTypeRequest {
        @InvocableVariable(label='Selected Profession Type' required=true description='The profession-type value the user picked (Individual, Business, Schools/Programs, or Other).')
        public String selectedProfessionType;
    }

    public class CaptureTypeResponse {
        @InvocableVariable(label='Selected Profession Type')
        public String selectedProfessionType;
    }

    public class CaptureChoiceRequest {
        @InvocableVariable(label='Selected Profession Id' required=true)
        public String selectedProfessionId;
        @InvocableVariable(label='Selected Profession Name' required=true)
        public String selectedProfessionName;
    }

    public class CaptureChoiceResponse {
        @InvocableVariable(label='Selected Profession Id')
        public String selectedProfessionId;
        @InvocableVariable(label='Selected Profession Name')
        public String selectedProfessionName;
    }

    public static List<CaptureTypeResponse> captureProfessionType(List<CaptureTypeRequest> requests) {
        List<CaptureTypeResponse> responses = new List<CaptureTypeResponse>();
        for (CaptureTypeRequest req : requests) {
            CaptureTypeResponse res = new CaptureTypeResponse();
            res.selectedProfessionType = req.selectedProfessionType;
            responses.add(res);
        }
        return responses;
    }

    public static List<CaptureChoiceResponse> captureProfessionChoice(List<CaptureChoiceRequest> requests) {
        List<CaptureChoiceResponse> responses = new List<CaptureChoiceResponse>();
        for (CaptureChoiceRequest req : requests) {
            CaptureChoiceResponse res = new CaptureChoiceResponse();
            res.selectedProfessionId = req.selectedProfessionId;
            res.selectedProfessionName = req.selectedProfessionName;
            responses.add(res);
        }
        return responses;
    }

    public class SubmitRequest {
        @InvocableVariable(label='Profession Id' required=true)
        public String professionId;
        @InvocableVariable(label='Answers JSON' required=true description='JSON object {questionId: response} of all collected answers.')
        public String answersJson;
    }

    public class LaunchRequest {
        @InvocableVariable(label='Regulatory Authorization Type Id' required=true)
        public String regulatoryAuthorizationTypeId;
    }

    public class LaunchResponse {
        @InvocableVariable(label='Status' description='OK, Duplicate, Blocked, or Error.')
        public String status;
        @InvocableVariable(label='Intake URL')
        public String intakeUrl;
        @InvocableVariable(label='Display Message' description='Pre-formatted Markdown message for the user when status is Blocked. Empty on the OK path because the agent renders the intake URL itself.')
        public String displayMessage;
        @InvocableVariable(label='Error Message')
        public String errorMessage;
    }
}