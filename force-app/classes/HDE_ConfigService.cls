/**
 * Reads Handwritten Document Extraction settings from Custom Metadata.
 * Falls back to portable defaults when no CMDT row exists.
 */
public with sharing class HDE_ConfigService {
    @TestVisible
    private static final String DEFAULT_PROMPT_TEMPLATE = 'Document_Extraction';
    @TestVisible
    private static final String DEFAULT_PROMPT_INPUT_KEY = 'Input:documentText';
    @TestVisible
    private static final String DEFAULT_EXTENSIONS = 'pdf,png,jpg,jpeg,tif,tiff,txt,csv,gif,webp';
    @TestVisible
    private static final String DEFAULT_LAYOUT = 'lightning';
    @TestVisible
    private static final String DEFAULT_WRAPPER = 'omnistudio__vlocityLWCOmniWrapper';

    public class Settings {
        @AuraEnabled public String promptTemplateApiName;
        @AuraEnabled public String promptInputKey;
        @AuraEnabled public List<String> supportedExtensions;
        @AuraEnabled public String defaultLayout;
        @AuraEnabled public Boolean autoMatchEnabled;
        @AuraEnabled public String omniWrapperComponent;
        @AuraEnabled public List<String> acceptedFormats;
    }

    public static Settings getSettings() {
        Settings s = new Settings();
        HDE_Settings__mdt row = loadSettingsRow();

        s.promptTemplateApiName = firstNonBlank(
            row == null ? null : row.Prompt_Template_Api_Name__c,
            DEFAULT_PROMPT_TEMPLATE
        );
        s.promptInputKey = firstNonBlank(
            row == null ? null : row.Prompt_Input_Key__c,
            DEFAULT_PROMPT_INPUT_KEY
        );
        s.defaultLayout = firstNonBlank(
            row == null ? null : row.Default_Layout__c,
            DEFAULT_LAYOUT
        );
        s.omniWrapperComponent = firstNonBlank(
            row == null ? null : row.Omni_Wrapper_Component__c,
            DEFAULT_WRAPPER
        );
        s.autoMatchEnabled = row == null ? true : row.Auto_Match_Enabled__c;

        String extCsv = firstNonBlank(
            row == null ? null : row.Supported_Extensions__c,
            DEFAULT_EXTENSIONS
        );
        s.supportedExtensions = splitCsv(extCsv);
        s.acceptedFormats = new List<String>();
        for (String ext : s.supportedExtensions) {
            s.acceptedFormats.add('.' + ext);
        }
        return s;
    }

    public static Map<String, String> getFieldMappings(
        String omniType,
        String omniSubType,
        String omniLanguage
    ) {
        Map<String, String> mappings = new Map<String, String>();
        if (String.isBlank(omniType) || String.isBlank(omniSubType)) {
            return mappings;
        }

        String language = String.isBlank(omniLanguage) ? 'English' : omniLanguage;
        List<HDE_Field_Mapping__mdt> rows = [
            SELECT Field_Mappings_JSON__c
            FROM HDE_Field_Mapping__mdt
            WHERE Is_Active__c = true
              AND OmniScript_Type__c = :omniType
              AND OmniScript_SubType__c = :omniSubType
              AND OmniScript_Language__c = :language
            LIMIT 1
        ];
        if (rows.isEmpty()) {
            return mappings;
        }
        String jsonText = rows[0].Field_Mappings_JSON__c;
        if (String.isBlank(jsonText)) {
            return mappings;
        }
        try {
            Object parsed = JSON.deserializeUntyped(jsonText);
            if (parsed instanceof Map<String, Object>) {
                Map<String, Object> raw = (Map<String, Object>) parsed;
                for (String key : raw.keySet()) {
                    Object val = raw.get(key);
                    if (val != null) {
                        mappings.put(normalizeKey(key), String.valueOf(val));
                    }
                }
            }
        } catch (Exception e) {
            // Ignore invalid mapping JSON; auto-match remains available.
        }
        return mappings;
    }

    private static HDE_Settings__mdt loadSettingsRow() {
        List<HDE_Settings__mdt> rows = [
            SELECT
                Prompt_Template_Api_Name__c,
                Prompt_Input_Key__c,
                Supported_Extensions__c,
                Default_Layout__c,
                Auto_Match_Enabled__c,
                Omni_Wrapper_Component__c
            FROM HDE_Settings__mdt
            WHERE DeveloperName = 'Default'
            LIMIT 1
        ];
        if (!rows.isEmpty()) {
            return rows[0];
        }
        rows = [
            SELECT
                Prompt_Template_Api_Name__c,
                Prompt_Input_Key__c,
                Supported_Extensions__c,
                Default_Layout__c,
                Auto_Match_Enabled__c,
                Omni_Wrapper_Component__c
            FROM HDE_Settings__mdt
            LIMIT 1
        ];
        return rows.isEmpty() ? null : rows[0];
    }

    private static List<String> splitCsv(String csv) {
        List<String> out = new List<String>();
        if (String.isBlank(csv)) {
            return out;
        }
        for (String part : csv.split(',')) {
            String token = part == null ? '' : part.trim().toLowerCase().replace('.', '');
            if (String.isNotBlank(token)) {
                out.add(token);
            }
        }
        return out;
    }

    public static String normalizeKey(String raw) {
        if (raw == null) {
            return '';
        }
        return raw.replaceAll('[^A-Za-z0-9]', '').toLowerCase();
    }

    private static String firstNonBlank(String primary, String fallback) {
        return String.isNotBlank(primary) ? primary.trim() : fallback;
    }
}
