/**
 * @author                      : Nitesh garg
 * @since                       :
 * @description                 : This class is used to show the list of profession
 * @last modified by            : (Add if modified by you)
 * @last modified date          : (Add if modified by you)
 * @last modified details       : (Add if modified by you)
 */
public with sharing class LPI_RecommendedProfessionCtrl {
    private static final Map<String, String> PROFESSION_LABEL_BY_NAME = new Map<String, String>{
        'Doctor' => 'LP_Profession_Doctor',
        'Educator' => 'LP_Profession_Educator',
        'Individual Insurance Agent' => 'LP_Profession_Individual_Insurance_Agent',
        'Interim Teachers Certificate Application' => 'LP_Profession_Interim_Teachers_Certificate',
        'Private Occupational Training Organization' => 'LP_Profession_Private_Occupational_Training',
        'Cosmetologist' => 'LP_Profession_Cosmetologist',
        'Preneed Seller' => 'LP_Profession_Preneed_Seller',
        'Real Estate Salesperson' => 'LP_Profession_Real_Estate_Salesperson',
        'Real Estate School Practitioner' => 'LP_Profession_Real_Estate_School_Practitioner'
    };

    /**
    * Description : Get All profession records
    * @author : Chetan Gupta
    * @return : Map<String,Object>
    */
    @AuraEnabled
    public static Map<String,Object> fetchProfessionDetails(String language){
        try {
            String lang = resolveLanguage(language);
            List<User> u = LPI_UserDao.getCurrentUserRecord();
            boolean showOnlyBusiness = false;
            if(!u.isEmpty() && String.isNotBlank(u[0].AccountId)) {
                List<Account> accList = LPI_AccountDAO.getAccountListByDynamicQuery(new List<String>{'Id','Person_Account_For_Business__c'},
                'Id = \''+u[0].AccountId+'\'',1,null,null);
                if(!accList.isEmpty()){
                    showOnlyBusiness = accList[0].Person_Account_For_Business__c;
                }
            }
            String applyOnlineLabel = getLabelValue('LP_Apply_Online', lang, 'Apply Online');
			String queryFields = ' Id,Name,Profession_Type__c,Exempt_Decision_Tree__c,Regulatory_Authorization_Type__c,System_Validation_Needed__c';
            Map<String,List<DataWrapper>> typeWithProfessionMap = new Map<String,List<DataWrapper>>();
            DataWrapper dW;
			for(Profession__c profession : LPI_ProfessionDAO.getProfessionByDymanicQuery(
                queryFields,null,null,'Name','asc')) {
                    if(!typeWithProfessionMap.containsKey(profession.Profession_Type__c)){
                        typeWithProfessionMap.put(profession.Profession_Type__c,new List<DataWrapper>());
                    }
                    String displayName = translateProfessionName(profession.Name, lang);
                    dW = new DataWrapper(
                        profession.Id,
                        displayName,
                        profession.Name,
                        profession.Exempt_Decision_Tree__c,
                        profession.Regulatory_Authorization_Type__c,
                        profession.System_Validation_Needed__c,
                        displayName + ' ' + applyOnlineLabel
                    );
                    typeWithProfessionMap.get(profession.Profession_Type__c).add(dW);
			}
            return new Map<String,Object>{
                'typeWithProfessionMap' => typeWithProfessionMap,
                'showOnlyBusiness' => showOnlyBusiness
            };
        } catch (Exception e) {
            LPI_ExceptionManager.logException('LPI_RecommendedProfessionCtrl', 'fetchProfessionDetails', e);
			throw new AuraHandledException(e.getMessage());
        }

    }

    private static String resolveLanguage(String language) {
        return (String.isNotBlank(language) && language.startsWith('fr')) ? 'fr' : 'en_US';
    }

    private static String normalizeProfessionKey(String name) {
        if (String.isBlank(name)) {
            return name;
        }
        return name.replace('’', '').replace('\'', '').replace('`', '');
    }

    private static String translateProfessionName(String name, String lang) {
        if (String.isBlank(name)) {
            return name;
        }
        String labelApi = PROFESSION_LABEL_BY_NAME.get(normalizeProfessionKey(name));
        if (String.isBlank(labelApi)) {
            return name;
        }
        return getLabelValue(labelApi, lang, name);
    }

    private static String getLabelValue(String apiName, String lang, String fallback) {
        try {
            String value = System.Label.get('', apiName, lang);
            return String.isNotBlank(value) ? value : fallback;
        } catch (Exception e) {
            return fallback;
        }
    }

    public class DataWrapper{
        @AuraEnabled public String id;
        @AuraEnabled public String name;
        @AuraEnabled public String originalName;
        @AuraEnabled public boolean systemValidation;
        @AuraEnabled public boolean exemptDecisonTree;
        @AuraEnabled public String regAuthId;
        @AuraEnabled public String ariaName;

        public DataWrapper(
            String id,
            String name,
            String originalName,
            boolean exemptDecisonTree,
            String regAuthId,
            boolean systemValidation,
            string ariaName
        ){
            this.id = id;
            this.name = name;
            this.originalName = originalName;
            this.exemptDecisonTree = exemptDecisonTree;
            this.regAuthId = regAuthId;
            this.systemValidation = systemValidation;
            this.ariaName = ariaName;
        }
    }
}