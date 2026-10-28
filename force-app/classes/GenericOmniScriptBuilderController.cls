public with sharing class GenericOmniScriptBuilderController {

    // ==========================================
    // WRAPPER CLASSES FOR JSON DESERIALIZATION
    // ==========================================
    public class OptionWrapper {
        @AuraEnabled public String label;
        @AuraEnabled public String value;
    }

    public class FieldWrapper {
        @AuraEnabled public String name;
        @AuraEnabled public String label;
        @AuraEnabled public String dataType; 
        @AuraEnabled public Boolean required;
        @AuraEnabled public Boolean readOnly;
        @AuraEnabled public List<OptionWrapper> options; 
    }

    public class StepWrapper {
        @AuraEnabled public String stepName;
        @AuraEnabled public String stepLabel;
        @AuraEnabled public List<FieldWrapper> fields;
    }

    public class OmniScriptWrapper {
        @AuraEnabled public String name;
        @AuraEnabled public String title;
        @AuraEnabled public String type;
        @AuraEnabled public String subType;
        @AuraEnabled public String language;
        @AuraEnabled public List<StepWrapper> steps;
    }

    // ==========================================
    // MAIN METHOD CALLED FROM LWC
    // ==========================================
    @AuraEnabled
    public static String createOmniScriptFromJSON(String jsonPayload) {
        try {
            if (String.isBlank(jsonPayload)) {
                throw new AuraHandledException('JSON payload cannot be empty.');
            }

            OmniScriptWrapper osData = (OmniScriptWrapper) JSON.deserialize(jsonPayload, OmniScriptWrapper.class);

            // 1. Create Parent Record: OmniProcess
            OmniProcess omni = new OmniProcess(
                Name = osData.name,
                Type = String.isNotBlank(osData.type) ? osData.type : 'Custom',
                SubType = String.isNotBlank(osData.subType) ? osData.subType : 'Process',
                Language = String.isNotBlank(osData.language) ? osData.language : 'English',
                IsIntegrationProcedure = false,
                IsActive = false,
                PropertySetConfig = buildDefaultGlobalSettings()
            );
            insert omni;

            if (osData.steps == null || osData.steps.isEmpty()) {
                return omni.Id;
            }

            // 2. Iterate and Create Steppers & Child Fields
            List<OmniProcessElement> fieldsToInsert = new List<OmniProcessElement>();
            Integer stepOrder = 1;

            for (StepWrapper step : osData.steps) {
                // Create Step Element
                OmniProcessElement stepElement = new OmniProcessElement(
                    OmniProcessId = omni.Id,
                    Name = step.stepName,
                    Type = 'Step',
                    IsActive = true,
                    SequenceNumber = stepOrder++,
                    PropertySetConfig = '{"label":"' + escapeJson(step.stepLabel) + '","validationRequired":true}'
                );
                insert stepElement; 

                // Add Child Input Fields inside Step
                if (step.fields != null && !step.fields.isEmpty()) {
                    Integer fieldOrder = 1;
                    for (FieldWrapper fld : step.fields) {
                        fieldsToInsert.add(new OmniProcessElement(
                            OmniProcessId = omni.Id,
                            ParentElementId = stepElement.Id,
                            Name = fld.name,
                            Type = normalizeType(fld.dataType),
                            IsActive = true,
                            SequenceNumber = fieldOrder++,
                            PropertySetConfig = buildFieldPropertySetConfig(fld)
                        ));
                    }
                }
            }

            if (!fieldsToInsert.isEmpty()) {
                insert fieldsToInsert;
            }

            return omni.Id;

        } catch (Exception e) {
            throw new AuraHandledException('OmniScript Creation Error: ' + e.getMessage());
        }
    }

    // Helper: Sanitizes data type strings into valid picklist values
    private static String normalizeType(String inputType) {
        if (String.isBlank(inputType)) {
            return 'Text';
        }
        
        String cleanType = inputType.trim();
        String key = cleanType.toLowerCase().replaceAll('[^a-z]', '');
        
        switch on key {
            when 'datetime', 'dateandtime' {
                return 'Date Time';
            }
            when 'textarea' {
                return 'Text Area';
            }
            when 'multiselect' {
                return 'Multi-select';
            }
            when 'linebreak' {
                return 'Line Break';
            }
            when 'phone', 'telephone', 'mobile' {
                return 'Telephone';
            }
            when 'number', 'integer', 'decimal' {
                return 'Number';
            }
            when 'text', 'string' {
                return 'Text';
            }
            when 'date' {
                return 'Date';
            }
            when 'time' {
                return 'Time';
            }
            when 'email' {
                return 'Email';
            }
            when 'currency' {
                return 'Currency';
            }
            when 'checkbox', 'boolean' {
                return 'Checkbox';
            }
            when 'select', 'dropdown' {
                return 'Select';
            }
            when 'radio' {
                return 'Radio';
            }
            when 'file' {
                return 'File';
            }
            when 'headline' {
                return 'Headline';
            }
            when else {
                return cleanType;
            }
        }
    }

    // Helper: Generates dynamic PropertySetConfig JSON string for fields
    private static String buildFieldPropertySetConfig(FieldWrapper fld) {
        Map<String, Object> config = new Map<String, Object>();
        config.put('label', fld.label != null ? fld.label : fld.name);
        config.put('required', fld.required != null ? fld.required : false);
        config.put('readOnly', fld.readOnly != null ? fld.readOnly : false);

        if (fld.options != null && !fld.options.isEmpty()) {
            List<Map<String, String>> optionList = new List<Map<String, String>>();
            for (OptionWrapper opt : fld.options) {
                optionList.add(new Map<String, String>{
                    'name' => opt.value,
                    'value' => opt.label
                });
            }
            config.put('options', optionList);
        }

        return JSON.serialize(config);
    }

    // Helper: Global Settings JSON containing LWC flags
    private static String buildDefaultGlobalSettings() {
        Map<String, Object> settings = new Map<String, Object>{
            'allowSaveForLater' => true,
            'autoSaveOnStepNext' => false,
            'hideStepChart' => false,
            'stepChartPlacement' => 'right',
            'disableUnloadWarn' => true,
            'currentLanguage' => 'en_US',
            'enableLwc' => true,
            'isLwc' => true,
            'designerCustomizationType' => 'LWC'
        };
        return JSON.serialize(settings);
    }

    private static String escapeJson(String str) {
        return String.isBlank(str) ? '' : str.replace('"', '\\"');
    }
}
