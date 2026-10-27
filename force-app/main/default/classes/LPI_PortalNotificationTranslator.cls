/**
 * @description Display-time EN/FR translation for portal Need Attention Notification__c cards.
 *              Clones records in memory and rebuilds Description/Button/Title from Custom Labels.
 *              Does not DML-update stored rows.
 */
public with sharing class LPI_PortalNotificationTranslator {
    public static final String CAT_DEFICIENCY = 'DEFICIENCY_NOTICE';
    public static final String CAT_PAYMENT = 'PAYMENT_PENDING';
    public static final String CAT_STATUS = 'STATUS_UPDATE';
    public static final String CAT_RMI = 'RMI_MORE_INFO';
    public static final String CAT_AUDIT = 'AUDIT';
    public static final String CAT_QA = 'QA_REPORT';
    public static final String CAT_RCV = 'RCV_COMPLIANCE';
    public static final String CAT_SCHOOL = 'SCHOOL_APPROVAL';
    public static final String CAT_MTS = 'MTS_SCHOOL';
    public static final String CAT_SUPERVISOR = 'SUPERVISOR_APPROVAL';
    public static final String CAT_PIC = 'PIC';
    public static final String CAT_ATTESTATION = 'ATTESTATION';
    public static final String CAT_ASSIGNED_TASK = 'ASSIGNED_TASK';

    private static final List<String> LABEL_API_NAMES = new List<String>{
        'LP_Portal_Btn_Respond',
        'LP_Portal_Btn_GoPayment',
        'LP_Portal_Btn_AddMoreInfo',
        'LP_Portal_Btn_Review',
        'LP_Portal_Btn_CompleteAudit',
        'LP_Portal_Btn_GoToTask',
        'LP_Portal_Def_Desc',
        'LP_Portal_Payment_Desc',
        'LP_Portal_Status_Changed',
        'LP_Portal_Rmi_Desc',
        'LP_Portal_Rmi_NoComments',
        'LP_Portal_Audit_Desc',
        'LP_Portal_QA_Desc',
        'LP_Portal_RCV_Desc',
        'LP_Portal_School_Desc',
        'LP_Portal_MTS_Desc',
        'LP_Portal_Supervisor_Desc',
        'LP_Portal_PIC_Desc',
        'LP_Portal_Attestation_Desc',
        'LP_Portal_AssignedTask_Desc',
        'LP_Portal_AssignedTask_Title'
    };

    /**
     * @description Translate portal notification display fields for the requested language.
     * @param notifs Source notifications (may be null)
     * @param language en_US or fr
     * @return Cloned list with translated Description__c / Button_Label__c / Title__c when matched
     */
    public static List<Notification__c> translate(List<Notification__c> notifs, String language) {
        List<Notification__c> result = new List<Notification__c>();
        if (notifs == null || notifs.isEmpty()) {
            return result;
        }

        String lang = resolveLanguage(language);
        Map<String, String> labels = loadLabels(lang);

        for (Notification__c source : notifs) {
            if (source == null) {
                continue;
            }
            Notification__c copy = source.clone(true, true, true, true);
            applyTranslation(copy, labels);
            result.add(copy);
        }
        return result;
    }

    @TestVisible
    private static void applyTranslation(Notification__c notif, Map<String, String> labels) {
        String category = resolveCategory(notif);
        if (String.isBlank(category)) {
            return;
        }

        if (CAT_DEFICIENCY.equals(category)) {
            Map<String, String> tokens = extractDeficiencyTokens(notif.Description__c);
            notif.Description__c = formatTemplate(
                labels.get('LP_Portal_Def_Desc'),
                tokens.get('appType'),
                tokens.get('licenseType'),
                tokens.get('boardName')
            );
            notif.Button_Label__c = labels.get('LP_Portal_Btn_Respond');
            return;
        }
        if (CAT_PAYMENT.equals(category)) {
            String appNumber = extractFirstGroup(
                notif.Description__c,
                '(?i)(?:Your Payment is pending for|Votre paiement est en attente pour)\\s+([^\\.]+)\\.?'
            );
            notif.Description__c = formatTemplate(labels.get('LP_Portal_Payment_Desc'), appNumber);
            notif.Button_Label__c = labels.get('LP_Portal_Btn_GoPayment');
            return;
        }
        if (CAT_STATUS.equals(category)) {
            Map<String, String> tokens = extractStatusTokens(notif.Description__c);
            notif.Description__c = formatTemplate(
                labels.get('LP_Portal_Status_Changed'),
                tokens.get('appNumber'),
                tokens.get('status')
            );
            return;
        }
        if (CAT_RMI.equals(category)) {
            Map<String, String> tokens = extractRmiTokens(notif.Description__c);
            String comments = localizeSystemPlaceholder(
                tokens.get('comments'),
                labels.get('LP_Portal_Rmi_NoComments')
            );
            notif.Description__c = formatTemplate(
                labels.get('LP_Portal_Rmi_Desc'),
                tokens.get('appNumber'),
                comments
            );
            notif.Button_Label__c = labels.get('LP_Portal_Btn_AddMoreInfo');
            localizeRmiUrlParams(notif, comments);
            return;
        }
        if (CAT_AUDIT.equals(category)) {
            String auditType = extractFirstGroup(
                notif.Description__c,
                '(?i)^(.+?)\\s+(?:Document Upload|Téléversement de documents)'
            );
            notif.Description__c = formatTemplate(labels.get('LP_Portal_Audit_Desc'), auditType);
            notif.Button_Label__c = labels.get('LP_Portal_Btn_CompleteAudit');
            return;
        }
        if (CAT_QA.equals(category)) {
            notif.Description__c = labels.get('LP_Portal_QA_Desc');
            notif.Button_Label__c = labels.get('LP_Portal_Btn_Respond');
            return;
        }
        if (CAT_RCV.equals(category)) {
            notif.Description__c = labels.get('LP_Portal_RCV_Desc');
            notif.Button_Label__c = labels.get('LP_Portal_Btn_Respond');
            return;
        }
        if (CAT_SCHOOL.equals(category)) {
            Map<String, String> tokens = extractApplicantLicenseTokens(
                notif.Description__c,
                '(?i)(.+?)\\s+has requested your approval to be associated with your school for their\\s+(.+?)\\s+license',
                '(?i)(.+?)\\s+a demandé votre approbation pour être associé à votre école pour leur permis\\s+(.+?)\\.'
            );
            // FR template ends without period sometimes — also try without trailing period
            if (String.isBlank(tokens.get('applicant'))) {
                tokens = extractApplicantLicenseTokens(
                    notif.Description__c,
                    '(?i)(.+?)\\s+has requested your approval to be associated with your school for their\\s+(.+?)\\s+license',
                    '(?i)(.+?)\\s+a demandé votre approbation pour être associé à votre école pour leur permis\\s+(.+?)(?:\\.|$)'
                );
            }
            notif.Description__c = formatTemplate(
                labels.get('LP_Portal_School_Desc'),
                tokens.get('applicant'),
                tokens.get('licenseType')
            );
            notif.Button_Label__c = labels.get('LP_Portal_Btn_Review');
            return;
        }
        if (CAT_MTS.equals(category)) {
            Map<String, String> tokens = extractApplicantLicenseTokens(
                notif.Description__c,
                '(?i)(.+?)\\s+has requested your approval to be associated with your school/mentorship for their\\s+(.+?)\\s+license',
                '(?i)(.+?)\\s+a demandé votre approbation pour être associé à votre école/mentorat pour leur permis\\s+(.+?)(?:\\.|$)'
            );
            notif.Description__c = formatTemplate(
                labels.get('LP_Portal_MTS_Desc'),
                tokens.get('applicant'),
                tokens.get('licenseType')
            );
            notif.Button_Label__c = labels.get('LP_Portal_Btn_Review');
            return;
        }
        if (CAT_SUPERVISOR.equals(category)) {
            Map<String, String> tokens = extractApplicantLicenseTokens(
                notif.Description__c,
                '(?i)(.+?)\\s+has appointed you as the Supervisor for their\\s+(.+?)(?:\\.\\s|$)',
                '(?i)(.+?)\\s+vous a nommé superviseur pour leur\\s+(.+?)(?:\\.\\s|$)'
            );
            notif.Description__c = formatTemplate(
                labels.get('LP_Portal_Supervisor_Desc'),
                tokens.get('applicant'),
                tokens.get('licenseType')
            );
            notif.Button_Label__c = labels.get('LP_Portal_Btn_Review');
            return;
        }
        if (CAT_PIC.equals(category)) {
            Map<String, String> tokens = extractApplicantLicenseTokens(
                notif.Description__c,
                '(?i)(.+?)\\s+has identified you as the Person In charge for their\\s+(.+?)\\s+application',
                '(?i)(.+?)\\s+vous a désigné comme personne responsable pour leur demande\\s+(.+?)(?:\\.\\s|$)'
            );
            notif.Description__c = formatTemplate(
                labels.get('LP_Portal_PIC_Desc'),
                tokens.get('applicant'),
                tokens.get('licenseType')
            );
            notif.Button_Label__c = labels.get('LP_Portal_Btn_Review');
            return;
        }
        if (CAT_ATTESTATION.equals(category)) {
            String applicant = extractFirstGroup(
                notif.Description__c,
                '(?i)^(.+?)\\s+(?:has requested an Attestation|a demandé une attestation)'
            );
            notif.Description__c = formatTemplate(labels.get('LP_Portal_Attestation_Desc'), applicant);
            notif.Button_Label__c = labels.get('LP_Portal_Btn_Review');
            return;
        }
        if (CAT_ASSIGNED_TASK.equals(category)) {
            Map<String, String> tokens = extractAssignedTaskTokens(notif);
            notif.Description__c = formatTemplate(
                labels.get('LP_Portal_AssignedTask_Desc'),
                tokens.get('user'),
                tokens.get('task'),
                tokens.get('caseNumber')
            );
            notif.Title__c = formatTemplate(
                labels.get('LP_Portal_AssignedTask_Title'),
                tokens.get('task'),
                tokens.get('caseNumber')
            );
            notif.Button_Label__c = labels.get('LP_Portal_Btn_GoToTask');
        }
    }

    @TestVisible
    private static String resolveCategory(Notification__c notif) {
        if (notif == null) {
            return null;
        }
        if (notif.Type__c == 'RMI_Application') {
            return CAT_RMI;
        }

        String nav = notif.Navigate_Component_API_Name__c;
        if (nav == 'deficiency-response') {
            return CAT_DEFICIENCY;
        }
        if (nav == 'payment-redirect') {
            return CAT_PAYMENT;
        }
        if (nav == 'audit-details') {
            return CAT_AUDIT;
        }
        if (nav == 'my-tasks') {
            return CAT_ASSIGNED_TASK;
        }

        String bodyNorm = normalize(notif.Description__c);
        String btn = normalize(notif.Button_Label__c);

        if (nav == 'inspection-violations') {
            if (containsAny(bodyNorm, new List<String>{
                'quality assurance',
                'assurance de la qualité'
            })) {
                return CAT_QA;
            }
            if (containsAny(bodyNorm, new List<String>{
                'not complying',
                'ne vous conformez',
                'non-compliant',
                'non conformes'
            })) {
                return CAT_RCV;
            }
        }

        if (containsAny(bodyNorm, new List<String>{ 'deficiency notice', 'avis de lacunes' })
            || ((btn == 'respond' || btn == 'répondre')
                && containsAny(bodyNorm, new List<String>{ 'deficiency', 'lacunes' }))) {
            return CAT_DEFICIENCY;
        }
        if (containsAny(bodyNorm, new List<String>{
            'payment is pending',
            'paiement est en attente'
        }) || btn == 'go to payment' || btn == 'aller au paiement') {
            return CAT_PAYMENT;
        }
        if (containsAny(bodyNorm, new List<String>{
            'status changed to',
            'statut modifié à',
            'a été modifié à'
        })) {
            return CAT_STATUS;
        }
        if (containsAny(bodyNorm, new List<String>{
            'application number:',
            'numéro de demande'
        }) || btn == 'add more info' || btn == 'ajouter plus d\'informations') {
            return CAT_RMI;
        }
        if (containsAny(bodyNorm, new List<String>{
            'complete audit',
            'compléter l\'audit',
            'document upload'
        }) || btn == 'complete audit' || btn == 'compléter l\'audit') {
            return CAT_AUDIT;
        }
        if (containsAny(bodyNorm, new List<String>{
            'quality assurance',
            'assurance de la qualité'
        })) {
            return CAT_QA;
        }
        if (containsAny(bodyNorm, new List<String>{
            'not complying',
            'ne vous conformez'
        })) {
            return CAT_RCV;
        }
        if (containsAny(bodyNorm, new List<String>{
            'school/mentorship',
            'école/mentorat'
        })) {
            return CAT_MTS;
        }
        if (containsAny(bodyNorm, new List<String>{
            'associated with your school for their',
            'associé à votre école pour leur permis'
        }) && !containsAny(bodyNorm, new List<String>{ 'school/mentorship', 'école/mentorat' })) {
            return CAT_SCHOOL;
        }
        if (containsAny(bodyNorm, new List<String>{
            'appointed you as the supervisor',
            'vous a nommé superviseur'
        })) {
            return CAT_SUPERVISOR;
        }
        if (containsAny(bodyNorm, new List<String>{
            'person in charge',
            'personne responsable'
        })) {
            return CAT_PIC;
        }
        if (containsAny(bodyNorm, new List<String>{
            'attestation of supervised',
            'attestation d\'expérience'
        })) {
            return CAT_ATTESTATION;
        }
        if (containsAny(bodyNorm, new List<String>{
            'has been assigned to you',
            'vous a été assigné'
        }) || btn == 'go to task' || btn == 'aller à la tâche') {
            return CAT_ASSIGNED_TASK;
        }
        return null;
    }

    private static Map<String, String> extractDeficiencyTokens(String description) {
        Map<String, String> tokens = new Map<String, String>{
            'appType' => '',
            'licenseType' => '',
            'boardName' => ''
        };
        if (String.isBlank(description)) {
            return tokens;
        }
        // EN: Your {appType} application for State {license} license ... State {board}.
        Matcher en = System.Pattern.compile(
            '(?is)Your\\s+(.+?)\\s+application for State\\s+(.+?)\\s+license has undergone review in the offices of the State\\s+(.+?)\\.'
        ).matcher(description);
        if (en.find()) {
            tokens.put('appType', en.group(1).trim());
            tokens.put('licenseType', en.group(2).trim());
            tokens.put('boardName', en.group(3).trim());
            return tokens;
        }
        // FR: Votre demande {appType} pour le permis d'État {license} ... l'État {board}.
        Matcher fr = System.Pattern.compile(
            '(?is)Votre demande\\s+(.+?)\\s+pour le permis d[\'’]État\\s+(.+?)\\s+a été examinée aux bureaux de l[\'’]État\\s+(.+?)\\.'
        ).matcher(description);
        if (fr.find()) {
            tokens.put('appType', fr.group(1).trim());
            tokens.put('licenseType', fr.group(2).trim());
            tokens.put('boardName', fr.group(3).trim());
        }
        return tokens;
    }

    private static Map<String, String> extractStatusTokens(String description) {
        Map<String, String> tokens = new Map<String, String>{
            'appNumber' => '',
            'status' => ''
        };
        if (String.isBlank(description)) {
            return tokens;
        }
        Matcher en = System.Pattern.compile('(?i)^(.+?)\\s+status changed to\\s+(.+?)\\.?$').matcher(description.trim());
        if (en.find()) {
            tokens.put('appNumber', en.group(1).trim());
            tokens.put('status', en.group(2).trim());
            return tokens;
        }
        Matcher fr = System.Pattern.compile(
            '(?i)^(?:Le statut de\\s+)?(.+?)\\s+(?:a été modifié à|statut modifié à)\\s+(.+?)\\.?$'
        ).matcher(description.trim());
        if (fr.find()) {
            tokens.put('appNumber', fr.group(1).trim());
            tokens.put('status', fr.group(2).trim());
        }
        return tokens;
    }

    private static Map<String, String> extractRmiTokens(String description) {
        Map<String, String> tokens = new Map<String, String>{
            'appNumber' => '',
            'comments' => ''
        };
        if (String.isBlank(description)) {
            return tokens;
        }
        Matcher m = System.Pattern.compile(
            '(?is)<b>(?:Application Number|Numéro de demande)\\s*:\\s*(.+?)</b>\\s*<br\\s*/?>\\s*(?:Comments|Commentaires)\\s*:\\s*(.*)$'
        ).matcher(description);
        if (m.find()) {
            tokens.put('appNumber', m.group(1).trim());
            tokens.put('comments', m.group(2).trim());
        }
        return tokens;
    }

    private static Map<String, String> extractApplicantLicenseTokens(
        String description,
        String enPattern,
        String frPattern
    ) {
        Map<String, String> tokens = new Map<String, String>{
            'applicant' => '',
            'licenseType' => ''
        };
        if (String.isBlank(description)) {
            return tokens;
        }
        Matcher en = System.Pattern.compile(enPattern).matcher(description);
        if (en.find()) {
            tokens.put('applicant', en.group(1).trim());
            tokens.put('licenseType', en.group(2).trim());
            return tokens;
        }
        Matcher fr = System.Pattern.compile(frPattern).matcher(description);
        if (fr.find()) {
            tokens.put('applicant', fr.group(1).trim());
            tokens.put('licenseType', fr.group(2).trim());
        }
        return tokens;
    }

    private static Map<String, String> extractAssignedTaskTokens(Notification__c notif) {
        Map<String, String> tokens = new Map<String, String>{
            'user' => '',
            'task' => '',
            'caseNumber' => ''
        };
        String description = notif.Description__c;
        String title = notif.Title__c;
        if (String.isNotBlank(description)) {
            Matcher en = System.Pattern.compile(
                '(?is)Hello\\s+(.+?)\\s+Your\\s+(.+?)\\s+for Case\\s+(.+?)\\s+has been assigned'
            ).matcher(description);
            if (en.find()) {
                tokens.put('user', en.group(1).trim());
                tokens.put('task', en.group(2).trim());
                tokens.put('caseNumber', en.group(3).trim());
                return tokens;
            }
            Matcher fr = System.Pattern.compile(
                '(?is)Bonjour\\s+(.+?)\\s+Votre\\s+(.+?)\\s+pour le dossier\\s+(.+?)\\s+vous a été assigné'
            ).matcher(description);
            if (fr.find()) {
                tokens.put('user', fr.group(1).trim());
                tokens.put('task', fr.group(2).trim());
                tokens.put('caseNumber', fr.group(3).trim());
                return tokens;
            }
        }
        if (String.isNotBlank(title)) {
            Matcher titleEn = System.Pattern.compile(
                '(?i)Your\\s+(.+?)\\s+for Case\\s+(.+?)\\s+has been assigned'
            ).matcher(title);
            if (titleEn.find()) {
                tokens.put('task', titleEn.group(1).trim());
                tokens.put('caseNumber', titleEn.group(2).trim());
            }
        }
        return tokens;
    }

    private static String extractFirstGroup(String source, String pattern) {
        if (String.isBlank(source)) {
            return '';
        }
        Matcher m = System.Pattern.compile(pattern).matcher(source);
        if (m.find()) {
            return m.group(1) != null ? m.group(1).trim() : '';
        }
        return '';
    }

    /**
     * Replaces known system placeholder text (EN/FR) with the selected-language label.
     * Real user comments are left unchanged.
     */
    private static String localizeSystemPlaceholder(String value, String localizedPlaceholder) {
        if (String.isBlank(value)) {
            return String.isBlank(localizedPlaceholder) ? value : localizedPlaceholder;
        }
        String normalized = value.trim().toLowerCase();
        if (normalized == 'no comments provided.'
            || normalized == 'no comments provided'
            || normalized == 'aucun commentaire fourni.'
            || normalized == 'aucun commentaire fourni') {
            return String.isBlank(localizedPlaceholder) ? value : localizedPlaceholder;
        }
        return value;
    }

    private static void localizeRmiUrlParams(Notification__c notif, String localizedComments) {
        if (notif == null || String.isBlank(notif.Url_Param_Json__c) || String.isBlank(localizedComments)) {
            return;
        }
        try {
            Map<String, Object> params = (Map<String, Object>) JSON.deserializeUntyped(notif.Url_Param_Json__c);
            Object rawComments = params.get('comments');
            String current = rawComments == null ? '' : String.valueOf(rawComments);
            String normalized = current.trim().toLowerCase();
            if (String.isBlank(current)
                || normalized == 'no comments provided.'
                || normalized == 'no comments provided'
                || normalized == 'aucun commentaire fourni.'
                || normalized == 'aucun commentaire fourni') {
                params.put('comments', localizedComments);
                notif.Url_Param_Json__c = JSON.serialize(params);
            }
        } catch (Exception e) {
            // Leave Url_Param_Json__c unchanged if JSON is unexpected.
        }
    }

    private static String formatTemplate(String template, String v0) {
        if (String.isBlank(template)) {
            return v0 == null ? '' : v0;
        }
        return template.replace('{0}', v0 == null ? '' : v0);
    }

    private static String formatTemplate(String template, String v0, String v1) {
        if (String.isBlank(template)) {
            return v0 == null ? '' : v0;
        }
        return template
            .replace('{0}', v0 == null ? '' : v0)
            .replace('{1}', v1 == null ? '' : v1);
    }

    private static String formatTemplate(String template, String v0, String v1, String v2) {
        if (String.isBlank(template)) {
            return v0 == null ? '' : v0;
        }
        return template
            .replace('{0}', v0 == null ? '' : v0)
            .replace('{1}', v1 == null ? '' : v1)
            .replace('{2}', v2 == null ? '' : v2);
    }

    private static Boolean containsAny(String haystack, List<String> needles) {
        if (String.isBlank(haystack) || needles == null) {
            return false;
        }
        for (String needle : needles) {
            if (String.isNotBlank(needle) && haystack.contains(needle)) {
                return true;
            }
        }
        return false;
    }

    private static String normalize(String value) {
        return String.isBlank(value) ? '' : value.toLowerCase().trim();
    }

    @TestVisible
    private static String resolveLanguage(String language) {
        if (String.isNotBlank(language) && language.startsWith('fr')) {
            return 'fr';
        }
        if (String.isBlank(language)) {
            try {
                String userLang = UserInfo.getLanguage();
                if (userLang != null && userLang.startsWith('fr')) {
                    return 'fr';
                }
            } catch (Exception e) {
                // fall through
            }
        }
        return 'en_US';
    }

    private static Map<String, String> loadLabels(String language) {
        Map<String, String> result = new Map<String, String>();
        String lang = resolveLanguage(language);
        for (String apiName : LABEL_API_NAMES) {
            try {
                result.put(apiName, System.Label.get('', apiName, lang));
            } catch (Exception e) {
                result.put(apiName, apiName);
            }
        }
        return result;
    }
}