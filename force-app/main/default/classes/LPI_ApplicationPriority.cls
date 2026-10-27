/**
 * @description       : This Class Contains the logic for setting the priority of the application
 * @author            : MTX Group Product Team
 * @group             : 
 * @last modified on  : 07-30-2024
 * @last modified by  : MTX Group Product Team
**/

public with sharing class LPI_ApplicationPriority {
    
    public final static String MEDIUM_PRIORITY = 'Medium';
    public final static String HIGH_PRIORITY = 'High';
    public final static String CRITICAL_PRIORITY = 'Critical';
    public final static String LOW_PRIORITY = 'Low';
    public final static String COMPACT_DISCIPLINE_STATUS = 'Compact Discipline';
    public final static String HB_VISA = 'H1B Visa';
    public final static String VALUE_YES = 'Yes';
    public final static String VALUE_NO = 'No';
    public final static String US_PERMANENT_CARD_EXPIRED = 'Permanent Resident Card Expired - Extension Granted';
    public final static String RESPONSE_CODE_1 = '1';
    public final static String PRORITY_KEY = 'Priority';
    public final static String PRORITY_REASON_KEY = 'PriorityReason';
    public final static String US_PERMANENT_CARD = 'US Permanent Resident Card';
    public final static String VISA_WITH_STAMPED_DATE = 'Visa with stamped date of US entry';
    public final static String F1_STUDENT_VISA = 'F-1 Student Visa';
    public final static String RESPONSE_CODE_13 = '13';
    public final static String RESPONSE_CODE_28 = '28';
    public final static String FOREIGN = 'FOREIGN';

    /**
     * @author              : MTX Group Product Team
     * @since               : 2th May, 2023
     * @description         : This method contain logic for setting the priority of the application
    */
    public static void updatePriorityApplication(List<SObject> recordsList){
        try{
            String key = '';
            Set<String> ratNameSet = new Set<String>();
            Set<String> typeSet = new Set<String>();
            Set<String> subtypeSet = new Set<String>();
            Set<Id> parIdSet = new Set<Id>();
            Set<String> accIdSet = new Set<String>();
            Set<String> blIdSet = new Set<String>();
            Map<Id,PreliminaryApplicationRef>  parMap = new Map<Id,PreliminaryApplicationRef>();
            Map<Id,Account>  accountMap = new Map<Id,Account>();
            Map<Id,BusinessLicense>  businesLicenseMap = new Map<Id,BusinessLicense>();
            Map<String,List<Application_Priority_Config__mdt>> keyToMetadataMap = new Map<String, List<Application_Priority_Config__mdt>>();
            String priorityApplication;
            Map<String,Object> priorityMap = new Map<String,Object>();
            String sObjName = '';
            for (SObject rec : recordsList) {
                parIdSet.add((Id) rec.get('SavedApplicationRefId'));
                sObjName = String.valueOf(rec.getSObjectType());
                if (sObjName == LPI_LiteralConstant.IA_SOBJECT_API) {
                    accIdSet.add((String) rec.get('AccountId'));
                    if(!String.isEmpty((String) rec.get('LicensePermitNameId'))){
                        blIdSet.add((String) rec.get('LicensePermitNameId'));
                    }
                }
            }
            if(!accIdSet.isEmpty()){
                for(Account acc : LPI_AccountDAO.getAccountListByDynamicQuery(
                    new List<String>{'Id','LawfulPresenceExpirationDate__c','Proof_of_work_permit_in_United_States__c','LawfulPresence__c','Is_the_address_in_US_or_International__c', 'PermanentResidentCardExpiration__c', 'DateOfEntry__c', 'EADSExpirationDate__c', 'ProgramEndDate__c', 'Citizenship__c'},
                    'Id IN '+ LPI_ServiceUtility.getStringValuesByStringSet(accIdSet),null,null,null)){
                        accountMap.put(acc.Id,acc);
                }
            }
            if(!blIdSet.isEmpty()){
                for(BusinessLicense bl : LPI_BusinessLicenseDAO.fetchBusinessLicenseRecords(
                   'Id,PeriodEnd',
                    'Id IN '+ LPI_ServiceUtility.getStringValuesByStringSet(blIdSet))){
                        businesLicenseMap.put(bl.Id,bl);
                }
            }
            if(!parIdSet.isEmpty()){
                parMap = new Map<Id,PreliminaryApplicationRef>(LPI_PreliminaryApplicationRefDAO.getPARRecordsByID(parIdSet));
                for (PreliminaryApplicationRef parRec : parMap.values()) {
                    ratNameSet.add(parRec.Regulatory_Authorization_Type__r.Name);
                    typeSet.add(parRec.Type__c);
                    subtypeSet.add(parRec.Amendment_Type__c);
                }
                String whereClause = ' Regulatory_Authorization_Type_Name__c IN ' + LPI_ServiceUtility.getStringValuesByStringSet(ratNameSet) +
                    ' AND Type__c IN ' + LPI_ServiceUtility.getStringValuesByStringSet(typeSet) +
                    ' AND Sub_Type__c IN ' + LPI_ServiceUtility.getStringValuesByStringSet(subtypeSet) ;
                List<Application_Priority_Config__mdt> metaList = LPI_CustomMetadataTypeDAO.getCustomMetaDataByDymanicQuery(
                    'Id,Priority__c,Priority_Order__c,Type__c,Other_Fields_Api_Name__c,Regulatory_Authorization_Type_Name__c,Sub_Type__c,LicenseQuestionAPINameForNo__c,LicenseQuestionAPINameForYes__c',
                    'Application_Priority_Config__mdt',
                    whereClause,
                    null,'Priority_Order__c','asc');
                for (Application_Priority_Config__mdt rec: metaList) {
                    key = createKeyForMetaDataMap(rec.Regulatory_Authorization_Type_Name__c,rec.Type__c,rec.Sub_Type__c);
                    if(!keyToMetadataMap.containsKey(key)){
                        keyToMetadataMap.put(key,new List<Application_Priority_Config__mdt>());
                    }
                    keyToMetadataMap.get(key).add(rec);
                }
                for (SObject rec : recordsList) {
                    key = createKeyForMetaDataMap(parMap.get((Id) rec.get('SavedApplicationRefId')).Regulatory_Authorization_Type__r.Name,
                    parMap.get((Id) rec.get('SavedApplicationRefId')).Type__c,parMap.get((Id) rec.get('SavedApplicationRefId')).Amendment_Type__c);
                    if(!keyToMetadataMap.containsKey(key)){
                        priorityMap = generateReturnMap(MEDIUM_PRIORITY,null);
                    }else{
                        priorityMap = checklicenseQuestionResponses(parMap.get((Id) rec.get('SavedApplicationRefId')).License_Questions__c,
                        keyToMetadataMap.get(key));
                        if(priorityMap.get(PRORITY_KEY) == MEDIUM_PRIORITY){
                            priorityMap = checkApplicationFields(rec,keyToMetadataMap.get(key));
                        }
                    }
                    if(priorityMap.get(PRORITY_KEY) == MEDIUM_PRIORITY){
                        sObjName = rec.getSObjectType().getDescribe().getName();
                        if (sObjName == LPI_LiteralConstant.IA_SOBJECT_API) {
                            priorityMap = checkingForIndividualApplication(rec,
                                                accountMap.containsKey((Id) rec.get('AccountId')) ? accountMap.get((Id) rec.get('AccountId')) : null,
                                                businesLicenseMap.containsKey((Id) rec.get('LicensePermitNameId')) ? businesLicenseMap.get((Id) rec.get('LicensePermitNameId')) : null );
                        } else if (sObjName == LPI_LiteralConstant.BLA_SOBJECT_API) {
                            
                        }
                    }
                    if(priorityMap.get(PRORITY_KEY) == MEDIUM_PRIORITY){
                        priorityMap = checkInApplication(rec);
                    }
                    rec.put('Priority__c',priorityMap.get(PRORITY_KEY));
                    // rec.put('Priority_Reason__c',priorityMap.get(PRORITY_REASON_KEY));
                }
            }   
        }catch(Exception e){
            LPI_ExceptionManager.logException('LPI_ApplicationPriority', 'updatePriorityApplication', e);
        }
    }
    /**
     * @author              : MTX Group Product Team
     * @since               : 2th May, 2023
     * @description         : This method contain logic for application level
    */
    private static Map<String,Object> checkInApplication(SObject appRec){
        if((Boolean)appRec.get('Payment_Pending__c')){
            return generateReturnMap(LOW_PRIORITY,'Payment Pending');
        }
        return generateReturnMap(MEDIUM_PRIORITY,null);
    }
    /**
     * @author              : MTX Group Product Team
     * @since               : 2th May, 2023
     * @description         : This method contain logic for checklicenseQuestionResponses
    */
    private static Map<String,Object> checklicenseQuestionResponses(String licenseQuestion,List<Application_Priority_Config__mdt> metaDataRecList){
        Map<String, Object> deserializedLicenseQuestions = (Map<String, Object>) JSON.deserializeUntyped(
            String.valueOf(licenseQuestion));
        for(Application_Priority_Config__mdt metaDataRec : metaDataRecList){
            List<String> licesneQuestionApiNameYes = metaDataRec?.LicenseQuestionAPINameForYes__c?.split(',');
            List<String> licesneQuestionApiNameNo = metaDataRec?.LicenseQuestionAPINameForNo__c?.split(',');
            boolean result = true;
            for(String values : deserializedLicenseQuestions.keySet()) {
                if(licesneQuestionApiNameYes != null && licesneQuestionApiNameYes.contains('All') &&
                    deserializedLicenseQuestions.get(values) != null &&
                    String.valueOf(deserializedLicenseQuestions.get(values)) == 'No'){
                        result = false;
                        break;
                }else if(licesneQuestionApiNameNo != null &&  licesneQuestionApiNameNo.contains('All') &&
                        deserializedLicenseQuestions.get(values) != null &&
                        String.valueOf(deserializedLicenseQuestions.get(values)) == 'Yes'){
                            result = false;
                            break;
                }else if(licesneQuestionApiNameYes != null && licesneQuestionApiNameYes.contains(values) &&
                        deserializedLicenseQuestions.get(values) != null &&
                        String.valueOf(deserializedLicenseQuestions.get(values)) == 'No'){
                            result = false;
                            break;
                }else if(licesneQuestionApiNameNo != null && licesneQuestionApiNameNo.contains(values) &&
                        deserializedLicenseQuestions.get(values) != null &&
                        String.valueOf(deserializedLicenseQuestions.get(values)) == 'Yes'){
                            result = false;
                            break;
                }
            }
            if(result){
                return generateReturnMap(metaDataRec?.Priority__c,'Screening Questions');
            }
        }
        return generateReturnMap(MEDIUM_PRIORITY,null);
    }
    /**
     * @author              : MTX Group Product Team
     * @since               : 2th May, 2023
     * @description         : This method contain logic for checkApplicationFields
    */
    private static Map<String,Object> checkApplicationFields(SObject appRec,List<Application_Priority_Config__mdt> metaDataRecList){
        for(Application_Priority_Config__mdt metaDataRec : metaDataRecList){
            if(metaDataRec.Other_Fields_Api_Name__c != null){
                Map<String, Object> deserializedFields = (Map<String, Object>) JSON.deserializeUntyped(
                    String.valueOf(metaDataRec?.Other_Fields_Api_Name__c));
                boolean result = false;
                for(String values : deserializedFields.keySet()) {
                    if((String)appRec.get(values) == String.valueOf(deserializedFields.get(values))){
                            result = true;
                            break;
                    }
                }
                if(result){
                    return generateReturnMap(metaDataRec?.Priority__c,metaDataRec?.Priority_Reason__c);
                }
            }
        }
        return generateReturnMap(MEDIUM_PRIORITY,null);
    }
    /**
     * @author              : MTX Group Product Team
     * @since               : 2th May, 2023
     * @description         : This method contain logic for checkingForIndividualApplication
    */
    private static Map<String,Object> checkingForIndividualApplication(SObject appRec,Account accRec,BusinessLicense blRec){
        Map<String,Object> getPriorityMap = checkResponseCode(appRec);
        String priority  = (String)getPriorityMap.get(PRORITY_KEY);
        if(priority != MEDIUM_PRIORITY){
            return getPriorityMap;
        }
        if( (accRec.Proof_of_work_permit_in_United_States__c == US_PERMANENT_CARD_EXPIRED 
            || accRec.Proof_of_work_permit_in_United_States__c == US_PERMANENT_CARD) 
            && (accRec.PermanentResidentCardExpiration__c == null )){
            return generateReturnMap(CRITICAL_PRIORITY,'SAVE: AdmittedToDate unavailable');
        }
        if( accRec.Proof_of_work_permit_in_United_States__c == VISA_WITH_STAMPED_DATE
            && (accRec.DateOfEntry__c == null )){
            return generateReturnMap(CRITICAL_PRIORITY,'SAVE: NonCitEntryDate unavailable');
        }
        if( accRec.Proof_of_work_permit_in_United_States__c == F1_STUDENT_VISA
            && (accRec.ProgramEndDate__c == null )){
            return generateReturnMap(CRITICAL_PRIORITY,'SAVE: AdmittedToDate unavailable');
        }
        if(accRec.Proof_of_work_permit_in_United_States__c == F1_STUDENT_VISA
            && (accRec.EADSExpirationDate__c == null )){
            return generateReturnMap(CRITICAL_PRIORITY,'SAVE: NonCitEadsExpireDate unavailable');
        }
        if(accRec.Proof_of_work_permit_in_United_States__c == HB_VISA && accRec.LawfulPresence__c == VALUE_YES 
            && accRec.Is_the_address_in_US_or_International__c == VALUE_NO){
            return generateReturnMap(CRITICAL_PRIORITY,'H1B Visa');
        }
        Map<String,Object> priorityCheckMap;
        switch on (String)appRec.get('ApplicationType') {
            when 'New' {
                 If((String)appRec.get('Disciplinary_Status__c') == COMPACT_DISCIPLINE_STATUS){
                	return(generateReturnMap(HIGH_PRIORITY,null));
        		}
            }	
            when 'Renewal' {
                priorityCheckMap = checkingForRenewalIndApp(appRec,accRec,blRec);
            }
            when 'Reinstatement', 'Re-licensure', 'Re-authorization' {	
                priorityCheckMap = checkingForReinstatementIndApp(appRec,accRec,blRec);
            }
            when 'Amendments' {	
                 If((String)appRec.get('Disciplinary_Status__c') == COMPACT_DISCIPLINE_STATUS){
                	return(generateReturnMap(HIGH_PRIORITY,null));
        		}
            }
            when else {		
                return generateReturnMap(MEDIUM_PRIORITY,null);
            }
        } if(priorityCheckMap!=null && priorityCheckMap.get(PRORITY_KEY) != CRITICAL_PRIORITY && (String)appRec.get('Disciplinary_Status__c') == COMPACT_DISCIPLINE_STATUS){
            return generateReturnMap(HIGH_PRIORITY,null);
        }else if(priorityCheckMap!=null && priorityCheckMap.get(PRORITY_KEY) == CRITICAL_PRIORITY){
            return generateReturnMap(CRITICAL_PRIORITY,(String)priorityCheckMap.get(PRORITY_REASON_KEY));
        }
        return generateReturnMap(MEDIUM_PRIORITY,null); 
    }
    /**
     * @author              : MTX Group Product Team
     * @since               : 2th May, 2023
     * @description         : This method contain logic for checkingForIndividualApplication
    */
    private static Map<String,Object> checkingForRenewalIndApp(SObject appRec,Account accRec,BusinessLicense blRec){
            if(accRec.Citizenship__c == FOREIGN && accRec.LawfulPresenceExpirationDate__c != null && blRec.PeriodEnd != null && accRec.LawfulPresenceExpirationDate__c < Date.newInstance(blRec.PeriodEnd.year(), blRec.PeriodEnd.month(), blRec.PeriodEnd.day())){
                    return generateReturnMap(CRITICAL_PRIORITY,'Renewal: LawfulPresence expiring before renewal date');
            }
            return generateReturnMap(MEDIUM_PRIORITY,null);
    }
    private static  Map<String,Object> checkingForReinstatementIndApp(SObject appRec,Account accRec,BusinessLicense blRec){
        if(accRec.Citizenship__c == FOREIGN && accRec.LawfulPresenceExpirationDate__c != null && accRec.LawfulPresenceExpirationDate__c < Date.Today()){
                return generateReturnMap(CRITICAL_PRIORITY,'Reinstatement: LawfulPresence expired');
        }
        return generateReturnMap(MEDIUM_PRIORITY,null);
    }
    private static Map<String,Object> checkResponseCode(SObject appRec){
        Set<String> responseCodeForMedium = new Set<String>{'1','13','28','24'};
       
        return generateReturnMap(MEDIUM_PRIORITY,null);
    }
    public static Map<String,Object> generateReturnMap(String pri,String reason){
        return new Map<String,Object>{
            PRORITY_KEY => pri,
            PRORITY_REASON_KEY => reason
        };
    }
    /**
     * @author              : MTX Group Product Team
     * @since               : 2th May, 2023
     * @description         : This method contain logic for createKeyForMetaDataMap
    */
	private static String createKeyForMetaDataMap(String regAuthName, String type, String subType) {
		String key = '';
		key = regAuthName != null ? regAuthName : '';
		key += type != null ? '-' + type : '';
		key += subType != null ? '-' + subType : '';
		return key;
	}
}