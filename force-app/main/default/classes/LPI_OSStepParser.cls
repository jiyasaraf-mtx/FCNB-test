/**
 * @author                      : MTX Group Product Team
 * @since                       : march 30,2023
 * @description                 : This is a self contain service class using which we can parse any omniscript step
 */
public with sharing class LPI_OSStepParser {
     
    private String stepName;
    private String osName;
    private List<StepElementWrapper> stepElementsWrapperList;
    private String stepLabel;
    private Map<String, String> commonVariableMap = new Map<String, String>();
    private Map<String, Object> topLevelDataJSON = new Map<String, Object>();
    private Set<String> typeSet = new Set<String>();

     
    private final static string ENG_LANG = 'English';
     
    public final static Set<String> ELEMENT_TYPE_SET = new Set<String>{
        'Radio',
        'Select',
        'Text',
        'Date',
        'Text Block',
        'Multi-select',
        'Checkbox',
        'Currency',
        'Date/Time',
        'Email',
        'Number',
        'Telephone',
        'Text Area',
        'Time',
        'Block',
        'Type Ahead Block',
        'Disclosure'
    };

    
    public final static Set<String> SHOW_CONDITION_VALUE_TO_RENDER = new Set<String>{ 'Hide if False', '' };
    private Boolean hasReplacebleText = false;
    private Map<String, String> replaceTextMap = new Map<String, String>();
    private Boolean showTextBlock = true;
    /**
     * @author                      :  MTX Group Product Team
     * @since                       : march 31,2023
     * @description                 : This method is a Contructor
     * @return                      : void
     * @last modified by            : MTX Group Product Team
     * @last modified date          :
     * @modified details            :
     */
    public LPI_OSStepParser(String stepName) {
        if (stepName.contains('{') && stepName.contains('}')) {
            LPI_PaymentStepController.StepWrapper stepData = (LPI_PaymentStepController.StepWrapper) JSON.deserialize(
                stepName,
                LPI_PaymentStepController.StepWrapper.class
            );
            this.stepName = stepData.stepName;
            this.osName = stepData.osName;
        } else {
            this.stepName = stepName;
            this.osName = '';
        }
        this.typeSet.add('Step');
        this.stepElementsWrapperList = new List<StepElementWrapper>();
        prepareElementWrapperList();
    }

    /**
     * @author                      : MTX Group Product Team
     * @since                       : Dec 19, 2023
     * @description                 : This method is a Contructor if you want to show only a specific block in the PDF
     * @return                      : void
     * @last modified by            : MTX Group Product Team
     * @last modified date          :
     * @modified details            :
     */
    public LPI_OSStepParser(String blockName, Boolean isBlockElement) {
        this.stepName = blockName;
        this.osName = '';
        if (isBlockElement) {
            this.typeSet.add('Block');
        }
        this.stepElementsWrapperList = new List<StepElementWrapper>();
        prepareElementWrapperList();
    }

    /**
     * @author                      : MTX Group Product Team
     * @since                       : march 31,2023
     * @description                 : This method is a Contructor
     *  @param stepName             : String
     *  @param parRecord            : PreliminaryApplicationRef
     * @return                      : void
     * @last modified by            : MTX Group Product Team
     * @last modified date          :
     * @modified details            :
     */
    public LPI_OSStepParser(String stepName, PreliminaryApplicationRef parRecord) {
        this(stepName);
        commonVariableMap.put('type', parRecord.Type__c);
        commonVariableMap.put('applicationType', parRecord.Type__c);
        commonVariableMap.put('regAuthTypeName', parRecord.Regulatory_Authorization_Type__r.Name);
        commonVariableMap.put('subTypeCategory', parRecord.Amendment_Type__c);
        commonVariableMap.put('subType', parRecord.Amendment_Type__c);
    }

    /**
     * @author                      : MTX Group Product Team
     * @since                       : May 09, 2023
     * @description                 : This method is a Contructor
     *  @param stepName             : String
     *  @param parRecord            : PreliminaryApplicationRef
     *  @param replaceTextMap       : Map<String, String>
     * @return                      : void
     * @last modified by            : MTX Group Product Team
     * @last modified date          :
     * @modified details            :
     */
    public LPI_OSStepParser(
        String stepName,
        PreliminaryApplicationRef parRecord,
        Map<String, String> replaceTextMap
    ) {
        this(stepName, parRecord);
        this.replaceTextMap = replaceTextMap;
        this.hasReplacebleText = replaceTextMap.isEmpty() ? false : true;
    }

    /**
     * @author                      : MTX Group Product Team
     * @since                       : march 31,2023
     * @description                 : This method will prepare StepElementWrapperList
     * @return                      : void
     * @last modified by            : MTX Group Product Team
     * @last modified date          :
     * @modified details            :
     */
    private void prepareElementWrapperList() {
        try {
            String fieldToQuery = '';
            String whereClause = '';
            String omniprocessId = '';

             
            if (String.isNotBlank(this.osName)) {
                fieldToQuery = 'Id, Name';
                whereClause =
                    'Name = \'' +
                    this.osName +
                    '\'' +
                    ' AND Language = \'' +
                    ENG_LANG +
                    '\'' +
                    ' AND IsActive = true';
                List<OmniProcess> osObject = LPI_OmniProcessDAO.getOmniProcessByDymanicQuery(
                    fieldToQuery,
                    whereClause,
                    null,
                    null,
                    null
                );
                if (osObject == null || osObject.isEmpty()) {
                    return;
                }
                omniprocessId = osObject[0].Id;
            } else {
                fieldToQuery = 'Id, Name,OmniProcessId';
                whereClause =
                    'Name = \'' +
                    this.stepName +
                    '\'' +
                    ' AND Type IN ' +
                    LPI_ServiceUtility.getStringValuesByStringSet(this.typeSet) +
                    ' AND OmniProcess.IsActive = true' +
                    ' AND IsActive = true';
                List<OmniProcessElement> stepElement = LPI_OmniProcessElementDAO.getOmniProcessElementByDymanicQuery(
                    fieldToQuery,
                    whereClause,
                    null,
                    null,
                    null
                );
                omniprocessId = stepElement[0].OmniProcessId;
            }

            fieldToQuery = 'Id, Name, Type, level, SequenceNumber, ParentElementName, OmniProcessId, PropertySetConfig';
            whereClause =
                'OmniProcessId = \'' +
                omniprocessId +
                '\'' +
                ' AND OmniProcess.IsActive = true' +
                ' AND ParentElement.IsActive = true' +
                ' AND IsActive = true' +
                ' AND Type IN ' +
                LPI_ServiceUtility.getStringValuesByStringSet(ELEMENT_TYPE_SET);
            string sortingByFields = 'Level, SequenceNumber';

            List<OmniProcessElement> osElements = LPI_OmniProcessElementDAO.getOmniProcessElementByDymanicQuery(
                fieldToQuery,
                whereClause,
                null,
                sortingByFields,
                null
            );
            Map<String, StepElementWrapper> nameToElementWrapperMap = new Map<String, StepElementWrapper>();
            Set<String> stepElementSet = new Set<String>{ this.stepName };
            for (OmniProcessElement element : osElements) {
                if (stepElementSet.contains(element.ParentElementName)) {
                    stepElementSet.add(element.Name);
                    StepElementWrapper elementWrapper = new StepElementWrapper(element);
                    if (element.ParentElementName == this.stepName) {
                        this.stepElementsWrapperList.add(elementWrapper);
                    } else {
                        nameToElementWrapperMap.get(element.ParentElementName).addChildElement(elementWrapper);
                    }
                    nameToElementWrapperMap.put(element.Name, elementWrapper);
                }
            }
        } catch (Exception e) {
            LPI_ExceptionManager.logException('LPI_OSStepParser', 'prepareElementWrapperList', e);
        }
    }

    /**
     * @author                      : MTX Group Product Team
     * @since                       : march 31,2023
     * @description                 : This method will return a PDF section Wrapper
     * @param jsonString            : String
     * @param stepLabel             : String
     * @return                      : LPI_PDFSectionWrapper
     * @last modified by            :  
     * @last modified date          :
     * @modified details            :
     */
    public LPI_PDFSectionWrapper getPDFSectionWrapper(String jsonString, String stepLabel) {
        List<LPI_PDFSectionWrapper.LicenseQuestionWrapper> licenseQuestions;
        try {
            if (String.isBlank(jsonString)) {
                return null;
            }
            this.stepLabel = stepLabel;
            if (
                
                (this.stepLabel == 'Instructions' &&
                this.stepName != 'ECApplicationInstructions')  
                 ) {
                this.showTextBlock = false;
            }
            Map<String, Object> deserializedValueMap = (Map<String, Object>) JSON.deserializeUntyped(
                String.valueOf(jsonString)
            );
            this.topLevelDataJSON = deserializedValueMap;
            licenseQuestions = getQuestionsList(this.stepElementsWrapperList, deserializedValueMap);
            transformQuestionList(licenseQuestions);
            
        } catch (Exception e) {
            LPI_ExceptionManager.logException('LPI_OSStepParser', 'prepareElementWrapperList', e);
        }
        return new LPI_PDFSectionWrapper(stepLabel, licenseQuestions);
    }

    /**
     * @author                      : MTX Group Product Team
     * @since                       : march 31,2023
     * @description                 : This is a recursive method which will return list of questions to render on section
     * @param elementList           : List<StepElementWrapper>
     * @param jsonData              : Map<String, Object>
     * @return                      : List<LPI_PDFSectionWrapper.LicenseQuestionWrapper>
     * @last modified by            : MTX Group Product Team
     * @last modified date          :
     * @modified details            :
     */
    private List<LPI_PDFSectionWrapper.LicenseQuestionWrapper> getQuestionsList(
        List<StepElementWrapper> elementList,
        Map<String, Object> jsonData
    ) {
        List<LPI_PDFSectionWrapper.LicenseQuestionWrapper> licenseQuestions = new List<LPI_PDFSectionWrapper.LicenseQuestionWrapper>();
        for (StepElementWrapper element : elementList) {
            if (
                !element.isHidden &&
                (element.showConditionMap == null ||
                !SHOW_CONDITION_VALUE_TO_RENDER.contains(element.conditionType) ||
                getConditionResult((Map<String, Object>) element.showConditionMap.get('group'), jsonData))
            ) {
                String topElementAPI = element.elementType == 'Type Ahead Block'
                    ? element.apiName + '-Block'
                    : element.apiName;

                if (!jsonData.containsKey(element.apiName)) {
                    jsonData.put(element.apiName, '');
                }
                
                if (element.elementType == 'Block' || element.elementType == 'Type Ahead Block') {
                    
                    if (
                        element.elementType == 'Type Ahead Block' &&
                        jsonData.containsKey(topElementAPI) &&
                        jsonData.get(topElementAPI) != null
                    ) {
                        LPI_PDFSectionWrapper.DataWrapper dataWrapper;
                        Map<String, Object> blockMap = (Map<String, Object>) jsonData.get(topElementAPI);
                        if (blockMap != null && blockMap.containsKey(element.apiName)) {
                            String dataValue = String.valueOf(blockMap.get(element.apiName));
                            dataWrapper = new LPI_PDFSectionWrapper.DataWrapper(element.label, dataValue);
                            if (element.controlWidth == 12 || licenseQuestions.isEmpty()) {
                                licenseQuestions.add(
                                    new LPI_PDFSectionWrapper.LicenseQuestionWrapper(dataWrapper, 3)
                                );
                            } else {
                                licenseQuestions[licenseQuestions.size() - 1].addDependentQuestion(dataWrapper);
                            }
                        }
                    }

                    
                    if (!element.childElements.isEmpty() && jsonData.get(topElementAPI) != null) {
                        List<Object> repeatBlockDataList = new List<Object>();
                        if (element.isRepeatBlock && jsonData.get(topElementAPI) instanceof List<Object>) {
                            repeatBlockDataList = (List<Object>) jsonData.get(topElementAPI);
                        } else {
                            repeatBlockDataList.add(jsonData.get(topElementAPI));
                        }
                        for (Object repeatBlockData : repeatBlockDataList) {
                            if (String.isNotBlank(element.label) && element.elementType == 'Block') {
                                LPI_PDFSectionWrapper.DataWrapper dataWrapper = new LPI_PDFSectionWrapper.DataWrapper(
                                    element.label,
                                    '',
                                    'bold-heading'
                                );
                                licenseQuestions.add(
                                    new LPI_PDFSectionWrapper.LicenseQuestionWrapper(dataWrapper, 3)
                                );
                            }
                            licenseQuestions.addAll(
                                getQuestionsList(element.childElements, (Map<String, Object>) repeatBlockData)
                            );
                        }
                    }
                }
                
                else if (element.elementType == 'Text Block' && element.text != null && this.showTextBlock) {
                     
                    if(this.stepLabel == LPI_ApplicationDataUtility.TAX_COMPLIANCE_STEP && element.apiName != 'TextBlock1'){
                        continue;
                    }
                    
                    LPI_PDFSectionWrapper.DataWrapper dataWrapper;
                    String elementText = getTransformedText(element.text);
                    dataWrapper = new LPI_PDFSectionWrapper.DataWrapper(elementText, '');
                    licenseQuestions.add(new LPI_PDFSectionWrapper.LicenseQuestionWrapper(dataWrapper, 3));
                }
                
                else if (
                    jsonData.containsKey(element.apiName) &&
                    (!element.isRequired || jsonData.get(element.apiName) != null) &&
                    element.elementType != 'Text Block'
                ) {
                    String dataValue = '';
                    if (String.valueOf(jsonData.get(element.apiName)) == '') {
                        dataValue = '';
                    } else if (element.elementType == 'Date') {
                        String dateString = String.valueOf(jsonData.get(element.apiName));
                        if (String.isNotBlank(dateString)) {
                            dataValue = dateString.contains('-')
                                ? Date.valueOf(String.valueOf(jsonData.get(element.apiName)))?.format()
                                : Date.parse(String.valueOf(jsonData.get(element.apiName)))?.format();
                        } else {
                            dataValue = '-';
                        }
                    } else if (element.elementType == 'Date/Time') {
                        dataValue = DateTime.valueOf(String.valueOf(jsonData.get(element.apiName)))?.format();
                    } else if (
                        (element.elementType == 'Radio' || element.elementType == 'Select') &&
                        !element.labelValueMap.isEmpty()
                    ) {
                        String valueAPI = String.valueOf(jsonData.get(element.apiName));
                        dataValue = element.labelValueMap.containsKey(valueAPI)
                            ? element.labelValueMap.get(valueAPI)
                            : valueAPI;
                    } else if (element.elementType == 'Multi-select') {
                        String valueAPI = String.valueOf(jsonData.get(element.apiName));
                        for (String selectedOption : valueAPI.split(';')) {
                            String optionLabel = element.labelValueMap.containsKey(selectedOption)
                                ? element.labelValueMap.get(selectedOption)
                                : selectedOption;
                            dataValue += String.isNotBlank(dataValue) ? '<br/>' + optionLabel : optionLabel;
                        }
                    } else {
                        dataValue = String.valueOf(jsonData.get(element.apiName));
                    }
                    LPI_PDFSectionWrapper.DataWrapper dataWrapper;
                    if (element.elementType == 'Checkbox' || element.elementType == 'Disclosure') {
                        String fieldLabel = String.isNotBlank(element.label)
                            ? element.label
                            : getTransformedText(element.text);
                        dataWrapper = new LPI_PDFSectionWrapper.DataWrapper(fieldLabel, dataValue, 'checkbox');
                    } else {
                        dataWrapper = new LPI_PDFSectionWrapper.DataWrapper(element.label, dataValue);
                    }
                    if (element.controlWidth == 12) {
                        licenseQuestions.add(new LPI_PDFSectionWrapper.LicenseQuestionWrapper(dataWrapper, 3));
                    } else if (licenseQuestions.isEmpty()) {
                        licenseQuestions.add(new LPI_PDFSectionWrapper.LicenseQuestionWrapper(null, 3));
                        licenseQuestions[0].addDependentQuestion(dataWrapper);
                    } else {
                        licenseQuestions[licenseQuestions.size() - 1].addDependentQuestion(dataWrapper);
                    }
                }
            }
        }
        return licenseQuestions;
    }

    /**
     * @author                      :  MTX Group Product Team
     * @since                       : march 31,2023
     * @description                 : This will return condition result to render an element on pdf
     * @param conditionMap          : Map<String,Object>
     * @param jsonData              : Map<String,Object>
     * @return                      : Boolean
     * @last modified by            : MTX Group Product Team
     * @last modified date          :
     * @modified details            :
     */
    private Boolean getConditionResult(Map<String, Object> conditionMap, Map<String, Object> jsonData) {
        Boolean result;
        String operator = '';
        if (conditionMap == null || jsonData == null) {
            return false;
        }
         
        List<Boolean> childConditionResult = new List<Boolean>();
        if (conditionMap.containsKey('operator')) {
            operator = String.valueOf(conditionMap.get('operator'));
        }

        if (conditionMap.containsKey('rules')) {
            for (Object ruleNode : (List<Object>) conditionMap.get('rules')) {
                Map<String, Object> rule = (Map<String, Object>) ruleNode;
                if (rule.containsKey('group')) {
                    childConditionResult.add(getConditionResult((Map<String, Object>) rule.get('group'), jsonData));
                } else {
                    String field = rule.containsKey('field') ? String.valueOf(rule.get('field')) : '';
                    String condition = rule.containsKey('condition') ? String.valueOf(rule.get('condition')) : '';
                    String data = rule.containsKey('data') ? String.valueOf(rule.get('data')) : '';
                    childConditionResult.add(evaluateExpression(field, condition, data, jsonData));
                }
            }
        }

        

        for (Boolean childResult : childConditionResult) {
            if (result == null) {
                result = childResult;
            } else if (operator == 'AND') {
                result = result && childResult;
            } else if (operator == 'OR') {
                result = result || childResult;
            }
        }

        return result;
    }

    /**
     * @author                      : MTX Group Product Team
     * @since                       : march 31,2023
     * @description                 : This will return the result of an expression
     * @param field                 : String
     * @param condition             : String
     * @param data                  : String
     * @param jsonData              : Map<String, Object>
     * @return                      : Boolean
     * @last modified by            : MTX Group Product Team
     * @last modified date          :
     * @modified details            :
     */
    private Boolean evaluateExpression(String field, String condition, String data, Map<String, Object> jsonData) {
        
        if (String.isNotBlank(field) && field.contains(':')) {
            for (String splittedString : field.split(':')) {
                field = splittedString;
            }
        }
        
        String fieldValue = '';
        if (jsonData.containsKey(field)) {
            fieldValue = String.valueOf(jsonData.get(field));
        } else if (jsonData.containsKey(field + 'Formula')) {
            fieldValue = String.valueOf(jsonData.get(field + 'Formula'));
        } else if (this.commonVariableMap.containsKey(field)) {
            fieldValue = this.commonVariableMap.get(field);
        } else if (this.topLevelDataJSON.containsKey(field)) {
            fieldValue = String.valueOf(this.topLevelDataJSON.get(field));
        } else {
            return false;
        }

        switch on condition {
            when '=' {
                return (fieldValue == data);
            }
            when '<>' {
                return (fieldValue != data);
            }
            when '>' {
                return (fieldValue > data);
            }
            when '<' {
                return (fieldValue < data);
            }
            when '<=' {
                return (fieldValue < data || fieldValue == data);
            }
            when '>=' {
                return (fieldValue == data || fieldValue > data);
            }
        }

        return true;
    }

    /**
     * @author                      : MTX Group Product Team
     * @since                       : August 3,2023
     * @description                 : Transform the text
     * @param inputText             : String
     * @return                      : String
     * @last modified by            : MTX Group Product Team
     * @last modified date          :
     * @modified details            :
     */
    private String getTransformedText(String inputText) {
        
        if (this.hasReplacebleText) {
            for (String replacebleText : this.replaceTextMap.keySet()) {
                if (inputText.contains(replacebleText) || '*'.equals(replacebleText)) {
                    inputText = inputText.replace(replacebleText, this.replaceTextMap.get(replacebleText));
                }
            }
        }
        return inputText;
    }

    /**
     * @author                      : MTX Group Product Team
     * @since                       : Jan 11,2024
     * @description                 : Transform Question List and fix the problem of having a quetion without label
     * @param inputText             : String
     * @return                      : String
     * @last modified by            : MTX Group Product Team
     * @last modified date          :
     * @modified details            :
     */
    private void transformQuestionList(List<LPI_PDFSectionWrapper.LicenseQuestionWrapper> questionsList) {
        Integer i = 0;
        Integer j = 1;
        while (j < questionsList.size()) {
            if (
                String.isBlank(questionsList[i].mainQuestion.fieldValue) &&
                String.isBlank(questionsList[j].mainQuestion.fieldLabel) &&
                String.isNotBlank(questionsList[j].mainQuestion.fieldValue)
            ) {
                questionsList[j].mainQuestion.fieldLabel = questionsList[i]
                    .mainQuestion.fieldLabel.replaceAll('<([a-z]+)(?![^>]*\\/>)[^>]*>', '');
                questionsList.remove(i);
            }
            i++;
            j++;
        }
    }

    /**
     * @author                      : MTX Group Product Team
     * @since                       : march 30,2023
     * @description                 : A Wrapper Class to for each element in omniscript step
     * @last modified by            : MTX Group Product Team
     * @last modified date          :
     * @modified details            :
     */
    public class StepElementWrapper {
        public string apiName;
        public string elementType;
        public string label;
        public string text;
        public string parentName;
        public Integer controlWidth;
        public Map<String, Object> showConditionMap;
        public List<StepElementWrapper> childElements;
        public Decimal level;
        public String conditionType;
        public Boolean isRequired;
        public Map<String, String> labelValueMap = new Map<String, String>();
        public Boolean isHidden;
        public Boolean isRepeatBlock = false;

        public StepElementWrapper(OmniProcessElement element) {
            this.apiName = element.Name;
            this.elementType = element.Type;
            Map<String, Object> deserializedValueMap = (Map<String, Object>) JSON.deserializeUntyped(
                String.valueOf(element.PropertySetConfig)
            );

            if (this.elementType == 'Radio' || this.elementType == 'Select' || this.elementType == 'Multi-select') {
                List<Object> optionsList = (List<Object>) deserializedValueMap.get('options');
                if (!optionsList.isEmpty()) {
                    preLoadOptionsMap(optionsList);
                }
            }

            String keyForLabel = this.elementType == 'Checkbox' ||
                this.elementType == 'Disclosure'
                ? 'checkLabel'
                : 'label';
            this.label = deserializedValueMap.containsKey(keyForLabel)
                ? String.valueOf(deserializedValueMap.get(keyForLabel))
                : '';

            this.text = deserializedValueMap.containsKey('text')
                ? String.valueOf(deserializedValueMap.get('text'))
                : '';

            this.parentName = element.ParentElementName;

            this.controlWidth = deserializedValueMap.containsKey('controlWidth')
                ? Integer.valueOf(deserializedValueMap.get('controlWidth'))
                : null;

            this.showConditionMap = deserializedValueMap.containsKey('show') && deserializedValueMap.get('show') != null
                ? (Map<String, Object>) (deserializedValueMap.get('show'))
                : null;

            this.conditionType = deserializedValueMap.containsKey('conditionType') &&
                deserializedValueMap.get('conditionType') != null
                ? String.valueOf(deserializedValueMap.get('conditionType'))
                : '';
            if (this.elementType == 'Checkbox') {
                this.isRequired = true;
            } else {
                this.isRequired = deserializedValueMap.containsKey('required') &&
                    deserializedValueMap.get('required') != null
                    ? Boolean.valueOf(deserializedValueMap.get('required'))
                    : false;
            }

            this.isHidden = deserializedValueMap.containsKey('hide') && deserializedValueMap.get('hide') != null
                ? Boolean.valueOf(deserializedValueMap.get('hide'))
                : false;

            if (this.elementType == 'Block') {
                this.isRepeatBlock = deserializedValueMap.containsKey('repeat') &&
                    deserializedValueMap.get('repeat') != null
                    ? Boolean.valueOf(deserializedValueMap.get('repeat'))
                    : false;
            }

            this.childElements = new List<StepElementWrapper>();
            this.level = element.level;
        }

        public void addChildElement(StepElementWrapper element) {
            this.childElements.add(element);
        }

        public void preLoadOptionsMap(List<Object> optionsList) {
            labelValueMap = new Map<String, String>();
            for (Object obj : optionsList) {
                Map<String, Object> optionMap = (Map<String, Object>) obj;
                labelValueMap.put(String.valueOf(optionMap.get('name')), String.valueOf(optionMap.get('value')));
            }
        }
    }
}