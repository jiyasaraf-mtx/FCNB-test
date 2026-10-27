/**
 * @author      : Sudhanshu Jain
 * @since       : 08-31-2023
 * @description : This LPI_InstructionController class is used by DisplayInstructions lwc for visibility of instruction on the portal.
 *  ------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * Version      Date                Author                   Details
 *    1         08-31-2023        Sudhanshu Jain              Initial Developement
 *    2         06 Sep 2023       Piyush Aneja                Added Label.Mandatory_Instruction_Text_Label
 * -------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
public with sharing class LPI_InstructionController {
    // ********************************************** CONSTANTS ********************************************;
    private final static string SYSTEM_TODAY = 'System.Today';
    // ******************************************************************************************************

    /**
    * @author                      : Sudhanshu
    * @since                       : May 11, 2023 
    * @description                 : This method returns the Instructions present in our flow
    * @param parId                 : PreliminaryApplicationRef record Id
    * @return                      : String
    * @last modified by            : Ayush Dev
    * @last modified date          : 
    * @modified details            : 
    */
    @AuraEnabled(cacheable=true)
    public static String getInstruction(String parId) {
        try{
            String instructionText = '';
            if(String.isNotBlank(parId)){
                String fields = 'Id,App_Flow_Config_Id__c';
                String whereClause =
                    'Id =\'' +
                    String.escapeSingleQuotes(parId) +
                    '\' AND App_Flow_Config_Id__c != NULL';
                List<PreliminaryApplicationRef> parList = LPI_PreliminaryApplicationRefDAO.getPreliminaryApplicationRefByDymanicQuery(
                    fields,
                    whereClause,
                    '1',
                    null,
                    null
                );
                if(!parList.isEmpty()){
                    fields = 'Id, Instruction_Configuration__c, Instructions__c, Mandatory_Text_Visible__c';
                    whereClause =
                        'Id =\'' + parList[0].App_Flow_Config_Id__c + '\'';
                    List<Application_Flow_Config__c> appFlowConfList = LPI_ApplicationFlowConfigDAO.getApplicationFlowConfigByDymanicQuery(
                        fields,
                        whereClause,
                        null,
                        null,
                        null
                    );
                    Set<String> apiNameSet = new Set<String>();
                    if(!appFlowConfList.isEmpty()){
                        Map<String, String> replacementMap = new Map<String, String>();
                        if(String.isNotBlank(appFlowConfList[0].Instruction_Configuration__c)){
                            List<InstructionConfigurationWrapper> configObj = (List<InstructionConfigurationWrapper>) JSON.deserialize(appFlowConfList[0].Instruction_Configuration__c, List<InstructionConfigurationWrapper>.class);
                            for(InstructionConfigurationWrapper icWrapper : configObj){
                                if(String.isNotBlank(icWrapper.apiName)){
                                    String trimedApiName = icWrapper.apiName.trim();
                                    if(trimedApiName.equalsIgnoreCase(SYSTEM_TODAY)){
                                        apiNameSet.add('Id');
                                    }else{
                                        apiNameSet.add(trimedApiName);
                                    }
                                }
                            }
                            if(!apiNameSet.isEmpty()){
                                fields = String.join(new List<String>(apiNameSet), ',');
                                whereClause = 'Id =\''+String.escapeSingleQuotes(parId) +'\'';
                                parList = LPI_PreliminaryApplicationRefDAO.getPreliminaryApplicationRefByDymanicQuery(
                                            fields,
                                            whereClause,
                                            '1',
                                            null,
                                            null 
                                            );
                                
                                if(!parList.isEmpty()){
                                    for(InstructionConfigurationWrapper icWrapper : configObj){
                                        if(String.isNotBlank(icWrapper.apiName) && String.isNotBlank(icWrapper.name)){
                                            String trimedApiName = icWrapper.apiName.trim();
                                            if('date'.equalsIgnoreCase(icWrapper.type)){
                                                String result;
                                                object input = trimedApiName.equalsIgnoreCase(SYSTEM_TODAY) ? (object) Date.today() :
                                                getFieldFromNestedRelationship(parList[0],trimedApiName);
                                                String formatCode = String.isBlank(icWrapper.format) ? 'MM/dd/yyyy' : icWrapper.format;
                                                Integer valueToAdd = icWrapper.addValue;
                                                String addType = valueToAdd != null && String.isNotBlank(icWrapper.addType) ? icWrapper.addType: null;
                                                if(String.isNotBlank(icWrapper.conditionalAttribute) && String.isNotBlank(icWrapper.customLogicName)){
                                                    result = customLogicHandler(icWrapper.customLogicName,icWrapper.conditionalAttribute,parList[0]);
                                                }else{
                                                    result = formatAndModifyDate(input,formatCode,valueToAdd,addType);
                                                }   
                                                replacementMap.put(icWrapper.name, result);                                        
                                            }else if('string'.equalsIgnoreCase(icWrapper.type)){
                                                String result = getFieldFromNestedRelationship(parList[0],trimedApiName);
                                                String defaultValue = icWrapper.defaultValue;
                                                if(String.isBlank(result) && String.isNotBlank(defaultValue)){
                                                    result = defaultValue;
                                                }
                                                replacementMap.put(icWrapper.name, result != null ?result : '');
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        if(String.isNotBlank(appFlowConfList[0].Instructions__c)){
                            instructionText = replaceRichText(replacementMap,appFlowConfList[0].Instructions__c);
                        }
                        if (appFlowConfList[0].Mandatory_Text_Visible__c) {
                             instructionText = Label.Mandatory_Instruction_Text_Label + instructionText ;
                        }else if(String.isBlank(instructionText)){
                            instructionText = 'No Instruction Found.';
                        }
                    }
                }
            }
            return instructionText;
        }catch (Exception e) {
			LPI_ExceptionManager.logException('LPI_InstructionController', 'getInstruction', e);
            throw new AuraHandledException(e.getMessage()); 
		}
    }

    /**
    * @author                      : Sudhanshu
    * @since                       : May 11, 2023 
    * @description                 : This method returns the Instructions after replacing the placeholders with correct value.
    * @param replacementMap        : This map contains the replacement values.
    * @param richText              : This contains the richText that is configured on application flow config.
    * @return                      : String
    * @last modified by            : Ayush Dev
    * @last modified date          : 
    * @modified details            : 
    */
    private static String replaceRichText(Map<String, String> replacementMap, String richText) {
        for (String key : replacementMap.keySet()) {
            String replaceKey = '{{' + key + '}}';
            String replacementValue = replacementMap.get(key);
            richText = richText.replace(replaceKey, replacementValue);
        }
        return richText;
    }

    /**
    * @author                      : Sudhanshu
    * @since                       : May 11, 2023 
    * @description                 : This method returns the formated Date according to formatCode parameter.
    * @param input                 : input contains a date instance it might be in string, datetime and date.
    * @param formatCode            : this is a format parameter in which we can pass any standard format.
    * @param valueToAdd            : this is a number field.
    * @param addType               : this field contains a value year/month/or day.
    * @return                      : String
    * @last modified by            : Ayush Dev
    * @last modified date          : 
    * @modified details            : 
    */
    private static String formatAndModifyDate(Object input, String formatCode, Integer valueToAdd, String addType) {
        Datetime dt;
        if (input instanceOf Date) {
            dt = Datetime.newInstanceGMT(((Date)input).year(), ((Date)input).month(), ((Date)input).day());
        }else if (input instanceOf Datetime) {
            dt = (Datetime)input;
        }else if (input instanceOf String) {
            try {
                dt = Datetime.valueOf((String)input);
            } catch (Exception e) {
                return '';
            }
        } else {
            return '';
        }

        if (valueToAdd != null) {
            if (addType.equalsIgnoreCase('year')) {
                dt = dt.addYears(valueToAdd);
            } else if (addType.equalsIgnoreCase('month')) {
                dt = dt.addMonths(valueToAdd);
            } else if (addType.equalsIgnoreCase('day')) {
                dt = dt.addDays(valueToAdd);
            }
        }
        String formattedDate = dt.format(formatCode);
        return formattedDate;
    }

    /**
    * @author                      : Sudhanshu
    * @since                       : Oct 9, 2023 
    * @description                 : This method returns the formated Date according to customLogicName and conditionalAttribute.
    * @param customLogicName       : This contains the Logic Name.
    * @param conditionalAttribute  : This contains conditionalAttribute Name.
    * @return                      : String
    * @last modified by            : Ayush Dev
    * @last modified date          : 
    * @modified details            : 
    */
    private static String customLogicHandler(String customLogicName,String conditionalAttribute, PreliminaryApplicationRef par){
        if(String.isNotBlank(conditionalAttribute)){
            Integer currentYear = Date.today().year();
            if('Pharmacist_Renewal_Renewal'.equalsIgnoreCase(customLogicName) && 
                par != null && String.isNotBlank(par.Business_License__c)){
                Date renewalDate = par.Business_License__r.Renewal_date__c;
                Datetime periodStart = par.Business_License__r.PeriodStart;
                Integer periodStartYear = Integer.valueOf(periodStart.format('YYYY'));
                Datetime periodEnd = par.Business_License__r.PeriodEnd;
                Integer periodEndYear = Integer.valueOf(periodEnd.format('YYYY'));
                if('LastCycleExpiryDate'.equalsIgnoreCase(conditionalAttribute)){
                    return '10/31/'+String.valueOf(currentYear);
                }else if('LastCycleStartDate'.equalsIgnoreCase(conditionalAttribute)){
                    return '11/01/' + (renewalDate != null ? String.valueOf(currentYear-2) : String.valueOf(periodStartYear));
                }else if('LastCycleStartDateNextYear'.equalsIgnoreCase(conditionalAttribute)){
                    return '11/01/' + (renewalDate != null ? String.valueOf(currentYear-1) : String.valueOf(periodStartYear+1));
                }else if('ExemptionStartDate'.equalsIgnoreCase(conditionalAttribute)){
                    return '11/01/' + (String.valueOf(periodEndYear-1));
                }else if('ExemptionEndDate'.equalsIgnoreCase(conditionalAttribute)){
                    return '10/31/' + (String.valueOf(periodEndYear));
                }
            }else if('Behavior_Analyst_All_Type'.equalsIgnoreCase(customLogicName)) {
                Boolean isEvenYear =  math.mod(currentYear,2) == 0;
                if('evenYear'.equalsIgnoreCase(conditionalAttribute)){
                    return String.valueOf(isEvenYear ? currentYear : currentYear -1);
                }else if('oddYear'.equalsIgnoreCase(conditionalAttribute)){
                    return String.valueOf(isEvenYear ? currentYear+1 : currentYear);
                }else if('nextEvenYear'.equalsIgnoreCase(conditionalAttribute)){
                    return String.valueOf(isEvenYear ? currentYear : currentYear+1);
                }else if('nextOddYear'.equalsIgnoreCase(conditionalAttribute)){
                    return String.valueOf(isEvenYear ? currentYear-1 : currentYear);
                }
            }
        }
        return '';
    }

    /**
    * @author                      : Sudhanshu
    * @since                       : May 11, 2023 
    * @description                 : This method returns the value of given apiName from given object.
    * @param inputObject           : inputObject contains a object data.
    * @param apiName               : This contains an apiName so that we can fetch the value from given object.
    * @return                      : String
    * @last modified by            : Ayush Dev
    * @last modified date          : 
    * @modified details            : 
    */
    private static String getFieldFromNestedRelationship(SObject inputObject, String apiName) {
        List<String> relationshipNames = apiName.split('\\.');
        
        if (relationshipNames.isEmpty()) {
            return null; // No relationships provided
        }

        String firstRelationship = relationshipNames[0];

        if (relationshipNames.size() == 1) {
            return String.valueOf(inputObject.get(firstRelationship));
        }

        SObject relatedRecord = (SObject) inputObject.getSObject(firstRelationship);

        if (relatedRecord != null) {
            relationshipNames.remove(0);
            return getFieldFromNestedRelationship(relatedRecord, String.join(relationshipNames,'.'));
        }

        return null; // Relationship not found
    }


    /**
    * @author                      : Sudhanshu
    * @since                       : Sep 29, 2023 
    * @description                 : This method return whether flow has Instruction or Not
    * @param parId                 : PreliminaryApplicationRef record Id
    * @return                      : Boolean
    * @last modified by            : Ayush Dev
    * @last modified date          : 
    * @modified details            : 
    */
    @AuraEnabled(cacheable=true)
    public static Boolean hasInstruction(String parId) {
        Boolean hasInstruction = false;
        try{
            if(String.isNotBlank(parId)){
                    String fields = 'Id,App_Flow_Config_Id__c';
                    String whereClause =
                        'Id =\'' +
                        String.escapeSingleQuotes(parId) +
                        '\' AND App_Flow_Config_Id__c != NULL';
                    List<PreliminaryApplicationRef> parList = LPI_PreliminaryApplicationRefDAO.getPreliminaryApplicationRefByDymanicQuery(
                        fields,
                        whereClause,
                        '1',
                        null,
                        null
                    );
                    if(!parList.isEmpty()){
                        fields = 'Id, Instructions__c, Mandatory_Text_Visible__c';
                        whereClause =
                            'Id =\'' + parList[0].App_Flow_Config_Id__c + '\'';
                        List<Application_Flow_Config__c> appFlowConfList = LPI_ApplicationFlowConfigDAO.getApplicationFlowConfigByDymanicQuery(
                            fields,
                            whereClause,
                            null,
                            null,
                            null
                        );
                        if(!appFlowConfList.isEmpty() && 
                            (String.isNotBlank(appFlowConfList[0].Instructions__c)|| 
                            appFlowConfList[0].Mandatory_Text_Visible__c)){
                            hasInstruction = true;
                        }
                    }
            }
        }catch (Exception e) {
			LPI_ExceptionManager.logException('LPI_InstructionController', 'hasInstruction', e); 
		}
        return hasInstruction;
    }

    public class InstructionConfigurationWrapper {
        public String name;
        public String type;
        public String apiName;
        public String format;
        public String addType;
        public String defaultValue;
        public Integer addValue;
        public String conditionalAttribute;
        public String customLogicName;

    }
}