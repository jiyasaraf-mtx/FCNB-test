/**
 * @author              : Vipin Agarwal
 * @since               : 2nd Jan, 2023
 * @description         : This class is used to fetch Funeral Establishment and Embalmer Business Licenses.
 *                      To get acr records associate with person account as establishments and child embalmers.
 *                      To save, update and delete acr's associated as per actions.
 */
global with sharing class LPI_EstablishmentInformationController implements Callable {
	
    private static final String PROFESSIONAL_COUNSELOR_LICENSE_TYPE = 'Professional Counselor';
    private static final String PROVISIONAL_MARITAL_AND_FAMILY_THERAPIST_LICENSE_TYPE = 'Provisional Marital and Family Therapist';
    private static final String PROVISIONAL_LICENSE_PROFESSIONAL_COUNSELOR_LICENSE_TYPE = 'Provisional License Professional Counselor';
    private static final Map<String , Set<String>> SOCIAL_WOKER_MAP = new Map<String , Set<String>>{
        'CSW Under Supervision' =>  new Set<String>{'Clinical Social Worker'} ,
        'AMSW Under Supervision' => new Set<String>{'Baccalaureate Social Worker','Advanced Macro Social Worker'},
        'BSW Under Supervision' => new Set<String>{'Baccalaureate Social Worker','Clinical Social Worker'}
    };
    public static final Set<String> PROFESSIONAL_MFT_TYPEAHED_RAT_SET = new Set<String>{ 
        'Marital & Family Therapist',
        'Professional Counselor',
        'Clinical Social Worker',
        'Psychologist'
    };
	public static final Set<String> LIC_TYPE_ALlOWED_SET = new Set<String>{
		LPI_LiteralConstant.LICENSE_TYPE_FUNERAL_DIRECTOR_APPRENTICE,
		LPI_LiteralConstant.LICENSE_TYPE_EMBALMER_APPRENTICE,
		LPI_LiteralConstant.LICENSE_TYPE_EMBALMER_PRACTICUM
	};
    private static final String Employment_History_Verified = 'Verified';
    public static final Set<String> ROLES_ALLOWED = new Set<String>{
        LPI_LiteralConstant.FUNERAL_ESTABLISHMENT_EMPLOYEE,
        LPI_LiteralConstant.ROLE_PRIMARY_SUPERVISOR
    }; 
    private static final String ROLE_FUNERAL_ESTABLISHMENTS = 'Funeral Establishments';
    private static final Set<String> SUPERVISOR_RAT_SET = new Set<String>{
        LPI_LiteralConstant.LICENSE_TYPE_EMBALMER,
        LPI_LiteralConstant.LICENSE_TYPE_FUNERAL_DIRECTOR 
    };
	global Object call(String action, Map<String, Object> args) {
		Map<String, Object> input = (Map<String, Object>) args.get('input');
		Map<String, Object> output = (Map<String, Object>) args.get('output');
		Map<String, Object> options = (Map<String, Object>) args.get('options');
		return invokeMethod(action, input, output, options);
	}
    private static final Map<String,String> ratToRoleMap = new Map<String,String>{
        'Embalmer Practicum' => 'Embalmer Practicum',
        'Embalmer Apprentice' => 'Embalmer Apprentice',
        'Embalmer' => 'Embalmer',
        'Funeral Director Apprentice' => 'Funeral Director Apprentice',
        'Funeral Director Limited' => 'Funeral Director Limited',
        'Funeral Director' => 'Funeral Director'
    };

	/**
	 * @author          MTX Group Product Team
	 * @description     This method will compare method from Omniscript and execute only that specific method
	 * @return          `Boolean`
	 */
	private Boolean invokeMethod(
		String methodName,
		Map<String, Object> inputMap,
		Map<String, Object> outMap,
		Map<String, Object> options
	) {
		Boolean result = true;
		try {
			if (methodName == 'getEstablishmentInformation') {
				outMap.put('licData', JSON.deserializeUntyped(JSON.serialize(getEstablishmentInformation(inputMap))));
			} else if (methodName == 'deleteRecords') {
				outMap.put('deleteRecords', (deleteRecords(inputMap)));
			} else if (methodName == 'saveRecord') {
				outMap.put('saveRecord', (saveRecord(inputMap)));
			} else if (methodName == 'getRecords') {
				outMap.put('getRecords', JSON.deserializeUntyped(JSON.serialize(getRecords(inputMap))));
			} else if (methodName == 'getBusinessRecords') {
				outMap.put('getBusinessRecords', JSON.deserializeUntyped(JSON.serialize(getBusinessRecords(inputMap))));
			} else if (methodName == 'deleteBusinessRecords') {
				outMap.put('deleteBusinessRecords', (deleteBusinessRecords(inputMap)));
			} else if (methodName == 'saveBusinessRecord') {
				outMap.put('saveBusinessRecord', (saveBusinessRecord(inputMap)));
			} else if (methodName == 'displayEmbalmerSection') {
				outMap.put('displayEmbalmerSection', (displayEmbalmerSection(inputMap)));
			} else if (methodName == 'fetchApplyingContact') {
				outMap.put('fetchApplyingContact', (fetchApplyingContact(inputMap)));
			}
		} catch (Exception e) {
			LPI_ExceptionManager.logException('LPI_EstablishmentInformationController', 'invokeMethod', e);
			throw new AuraHandledException(e.getMessage() + e.getLineNumber());
		}
		return result;
	}

    /**
	 * @author                      : MTX Group Product Team
	 * @since                       : 2nd May, 2023
	 * @description                 : This method used to fetch logged in user account.
	 * @return                      : String
	 * @last modified by            : MTX Group Product Team
	 * @last modified date          : 
	 * @modified details            : 
	 */
    @AuraEnabled
	public static String fetchApplyingContact(Map<String, Object> inputMap) {
		try {
            Id parId = (Id) inputMap.get('parid');
            if(String.isNotBlank(parId)){
                String fieldsToQuery = 'Contact__c, Regulatory_Authorization_Type__r.Name ';
                String whereClause = 'Id = \'' + String.escapeSingleQuotes(parId) + '\'';
                
                List<PreliminaryApplicationRef> parObjList = LPI_PreliminaryApplicationRefDAO.getPreliminaryApplicationRefByDymanicQuery(
                    fieldsToQuery,
                    whereClause,
                    null,
                    null,
                    null
                );
                return parObjList[0].Contact__c;
            }
        }catch(Exception ex){
            LPI_ExceptionManager.logException('LPI_EstablishmentInformationController', 'fetchApplyingContact', ex);
        }
        return 'success';
    }

	/**
	 * @author          MTX Group Product Team
	 * @description     Method is used to check if embalmer section is applicable on the lic type or not
	 * @param           inputMap
	 * @return          `Boolean`
	 */
	private static Boolean displayEmbalmerSection(Map<String, Object> inputMap) {
		Boolean displaySection = false;
		try {
			
			Id parId = (Id) inputMap.get('parid');
            if(String.isNotBlank(parId)){
                String fieldsToQuery = 'Id, BusinessAccountNameId, Regulatory_Authorization_Type__r.Name ';
                String whereClause = 'Id = \'' + String.escapeSingleQuotes(parid) + '\'';
                
                for (
                    PreliminaryApplicationRef parObj : LPI_PreliminaryApplicationRefDAO.getPreliminaryApplicationRefByDymanicQuery(
                        fieldsToQuery,
                        whereClause,
                        null,
                        null,
                        null
                    )
                ) {
                    
                    if (
                        String.isNotBlank(parObj.Regulatory_Authorization_Type__r.Name) &&
                        LIC_TYPE_ALlOWED_SET.contains(parObj.Regulatory_Authorization_Type__r.Name)
                    ) {
                        displaySection = true;
                        break;
                    }
                }
            }
		} catch (Exception e) {
			LPI_ExceptionManager.logException(
				'LPI_EstablishmentInformationController',
				'displayEmbalmerSection',
				e
			);
			throw new AuraHandledException(e.getMessage() + e.getLineNumber());
		}
		return displaySection;
	}

	/**
	 * @author          MTX Group Product Team
	 * @description     Method is used to get all the related Business_Relationships__c associated with (par OR logged in Account id /Business Account Id)
	 *
	 * @param
	 * @return          `List<EstablishmentBusinessWrapper>`
	 */
	public static List<EstablishmentBusinessWrapper> getBusinessRecords(Map<String, Object> inputMap) {
		List<EstablishmentBusinessWrapper> estList = new List<EstablishmentBusinessWrapper>();
		try {
			 
			Id parId = (Id) inputMap.get('parid');
            if(String.isNotBlank(parId)){
                String fieldsToQuery = 'Id, BusinessAccountNameId, Regulatory_Authorization_Type__r.Name ';
                String whereClause = 'Id = \'' + String.escapeSingleQuotes(parid) + '\'';
                 
                List<PreliminaryApplicationRef> parObjList = LPI_PreliminaryApplicationRefDAO.getPreliminaryApplicationRefByDymanicQuery(
                    fieldsToQuery,
                    whereClause,
                    null,
                    null,
                    null
                );
                String accountId = !parObjList.isEmpty() ? parObjList[0].BusinessAccountNameId : '';
                integer count = 0;
                EstablishmentBusinessWrapper est;
                 
                if (String.isNotBlank(accountId)) {
                     
                    String fieldsToQueryBR = 'Id, Related_From__c, Related_To__c, Entity_License_Number__c, IsActive__c, ';
                    fieldsToQueryBR =
                        fieldsToQueryBR + 'If_Relationship_is_Associated_with_you__c, Begin_Date_by_Applicant__c, EndDate__c, Start_Date__c ';
                    String whereClauseBR = '(IsActive__c = true OR (IsActive__c = false AND EndDate__c = null)) AND ';
                    whereClauseBR = whereClauseBR + 'Roles__c = \''+String.escapeSingleQuotes(ROLE_FUNERAL_ESTABLISHMENTS)+'\' AND ';
                    whereClauseBR =
                        whereClauseBR +
                        '(Related_From__c = \'' +
                        String.escapeSingleQuotes(accountId) +
                        '\' OR Related_To__c = \'' +
                        String.escapeSingleQuotes(accountId) +
                        '\')';
                     
                    List<Business_Relationships__c> businessRelationshipList = LPI_BusinessRelationshipDAO.fetchBusinessRelationshipRecords(
                        fieldsToQueryBR,
                        whereClauseBR
                    );
                    
                    for (Business_Relationships__c br : businessRelationshipList) {
                        est = new EstablishmentBusinessWrapper();
                        est.id = br.Id;
                        est.serialNumber = count;
                        est.label = 'Establishment - ' + (count + 1);
                        est.relatedFrom = br.Related_From__c;
                        est.relatedTo = br.Related_To__c;
                        est.establishmentLicNo = br.Entity_License_Number__c;
                        est.isActive = br.IsActive__c;
                        est.relationshipAssociatedWithYou = br.If_Relationship_is_Associated_with_you__c;
                        est.beginDate = br.Begin_Date_by_Applicant__c != null ? br.Begin_Date_by_Applicant__c : br.Start_Date__c;
                        
                        if (br.IsActive__c || (!br.IsActive__c && br.Related_From__c == accountId)) {
                            est.hideDelete = true;
                            est.isDisable = false;
                        }else{
                            est.hideDelete = false;
                            est.isDisable = true;
                        }
                        estList.add(est);
                        count++;
                    }
                }
            }
		} catch (Exception e) {
			LPI_ExceptionManager.logException('LPI_EstablishmentInformationController', 'getBusinessRecords', e);
			throw new AuraHandledException(e.getMessage() + e.getLineNumber());
		}
		
		return estList;
	}
	/**
	 * @author          MTX Group Product Team
	 * @description     Method is used to save Business_Relationships__c information that is created or Updated on UI
	 *                  This Business Relationship Record will be created between logged in business Account and the selected business License --> Account field
	 * @return          `String`
	 */
	private static String saveBusinessRecord(Map<String, Object> inputMap) {
		try {
			 
			String json = (String) inputMap.get('json');
			 
			Id parId = (Id) inputMap.get('parid');
            Id blid = String.isNotBlank((String)inputMap.get('blid')) ? (Id) inputMap.get('blid') : null;
            if(String.isNotBlank(parId)){
                String fieldsToQuery = 'Id, BusinessAccountNameId, Regulatory_Authorization_Type__r.Name ';
                String whereClause = 'Id = \'' + String.escapeSingleQuotes(parId) + '\'';
                 
                List<PreliminaryApplicationRef> parObjList = LPI_PreliminaryApplicationRefDAO.getPreliminaryApplicationRefByDymanicQuery(
                    fieldsToQuery,
                    whereClause,
                    null,
                    null,
                    null
                );
                String accountId = !parObjList.isEmpty() ? parObjList[0].BusinessAccountNameId : '';
                List<EstablishmentBusinessWrapper> establishmentBusinessList = new List<EstablishmentBusinessWrapper>();
                establishmentBusinessList = (List<EstablishmentBusinessWrapper>) System.JSON.deserialize(
                    json,
                    List<EstablishmentBusinessWrapper>.class
                );
                List<Business_Relationships__c> brUpdateList = new List<Business_Relationships__c>();
                List<Business_Relationships__c> brInsertList = new List<Business_Relationships__c>();
                Set<String> brIdSet = new Set<String>();  
                Business_Relationships__c br;
                 
                for (EstablishmentBusinessWrapper est : establishmentBusinessList) {
                    br = new Business_Relationships__c();
                     
                    if (String.isNotBlank(est.id)) {
                        br.Id = est.id;
                       
                        if(est.isActive || (est.hideDelete && !est.isDisable)){
                            br.If_Relationship_is_Associated_with_you__c = est.relationshipAssociatedWithYou;
                            br.Begin_Date_by_Applicant__c = est.beginDate;
                        }else{
                            
                            br.Entity_License_Number__c = est.establishmentLicNo;
                            br.Related_From__c = est.relatedFrom;
                            br.Related_To__c = accountId;
                            br.Begin_Date_by_Applicant__c = est.beginDate;
                        }
                        brUpdateList.add(br);
                    } else {
                         
                        br.Entity_License_Number__c = est.establishmentLicNo;
                        br.Related_From__c = est.relatedFrom;
                        br.Related_To__c = accountId;
                        br.If_Relationship_is_Associated_with_you__c = true;
                        br.Start_Date__c = est.beginDate;
                        br.IsActive__c = false;
                        br.Related_From_License_Number__c = est.establishmentLicId;
                        br.Related_To_License_Number__c = String.isNotBlank(blid) ? blid : null;
                        br.Roles__c = ROLE_FUNERAL_ESTABLISHMENTS; 
                        brInsertList.add(br);
                    }
                }
                
                if (!brInsertList.isEmpty()) {
                    
                    LPI_WithoutSharingUtility.insertSObjectList(brInsertList);
                    for(Business_Relationships__c relation : brInsertList){
                        brIdSet.add(relation.Id);
                    }
                }
                
                if (!brUpdateList.isEmpty()) {
                    
                    LPI_WithoutSharingUtility.updateSObjectList(brUpdateList);
                    for(Business_Relationships__c relation : brUpdateList){
                        brIdSet.add(relation.Id);
                    }
                }
                if(!brIdSet.isEmpty()){
                    PreliminaryApplicationRef par = new PreliminaryApplicationRef();
                    par.Id = parId;
                    par.Employee_Information_ACR_Ids__c = String.join(new List<String>(brIdSet),',');
                    LPI_DML.doUpdate(par);
                }
            }
		} catch (Exception e) {
			LPI_ExceptionManager.logException('LPI_EstablishmentInformationController', 'saveBusinessRecord', e);
			throw new AuraHandledException(e.getMessage() + e.getLineNumber());
		}
		return 'success';
	}

	/**
	 * @author          MTX Group Product Team
	 * @description     Method is used to delete Business_Relationships__c records with IsActive__c = `false`
	 * @param           inputMap
	 * @return          `String`
	 */
	private static String deleteBusinessRecords(Map<String, Object> inputMap) {
		try {
			Id recordId = (Id) inputMap.get('recordId');
            if(String.isNotBlank(recordId)){
                 
                String fieldsToQuery = 'Id, IsActive__c ';
                String whereClause = 'Id = \'' + String.escapeSingleQuotes(recordId) + '\' AND IsActive__c = false AND EndDate__c = null';
                List<Business_Relationships__c> brList = LPI_BusinessRelationshipDAO.fetchBusinessRelationshipRecords(
                    fieldsToQuery,
                    whereClause
                );
                 
                if (!brList.isEmpty()) {
                     
                    LPI_WithoutSharingUtility.deleteSObject(brList);
                }
            }
		} catch (Exception e) {
			LPI_ExceptionManager.logException('LPI_EstablishmentInformationController', 'deleteBusinessRecords', e);
			throw new AuraHandledException(e.getMessage() + e.getLineNumber());
		}
		return 'success';
	}

    /**
     * @author          MTX Group Product Team
     * @description     Method is used to get all the related Business_Relationships__c related to contactId OR AccountId based on parid with the relavantfields
     *                  and creates a wrapeer with Establishment and Embalmer Section that will be rendered on UI
     * @param           inputmap
     * @return          `List<EstablishmentWrapper>`
    */
    public static List<EstablishmentWrapper> getRecords(Map<String, Object> inputMap) {
        List<EstablishmentWrapper> estList = new List<EstablishmentWrapper>();
        try {
             
            Id parId = (Id) inputMap.get('parid');
            if(String.isNotBlank(parId)){
                String fieldsToQuery = 'Contact__c, Regulatory_Authorization_Type__r.Name ';
                String whereClause = 'Id = \'' + String.escapeSingleQuotes(parId) + '\'';
                 
                List<PreliminaryApplicationRef> parObjList = LPI_PreliminaryApplicationRefDAO.getPreliminaryApplicationRefByDymanicQuery(
                    fieldsToQuery,
                    whereClause,
                    null,
                    null,
                    null
                );
                 
                String fieldsToQueryContacts = 'Id, AccountId';
                String whereClauseContacts = 'Id = \'' + String.escapeSingleQuotes(parObjList[0].Contact__c) + '\'';
                List<Contact> conList = LPI_ContactDAO.fetchContactRecords(fieldsToQueryContacts, whereClauseContacts);
                String contactId = (!conList.isEmpty() ? conList[0].Id : '');
                String accountId = (!conList.isEmpty() ? conList[0].AccountId : '');
                String ratName = (!parObjList.isEmpty() ? parObjList[0].Regulatory_Authorization_Type__r.Name : '');
                integer count = 0;
                 
                Map<String, List<EmbalmerDetailList>> licIdToEmbChildMap = new Map<String, List<EmbalmerDetailList>>();
                EstablishmentWrapper est;
                 
                List<String> parentLicNumList;
                EmbalmerDetailList embalmer;
                 
                fieldsToQuery = ' Id, Related_From__c, Related_To__c, Entity_License_Number__c, Roles__c, ';
                fieldsToQuery =
                    fieldsToQuery +
                    'IsActive__c, Begin_Date_by_Applicant__c, If_Relationship_is_Associated_with_you__c, EndDate__c, Start_Date__c, Parent_Relationship__c, License_Number__c';
                whereClause =
                    ' (IsActive__c = true OR (IsActive__c = false AND EndDate__c = null)) AND Related_To__c = \'' +
                    accountId +
                    '\' AND (Roles__c = \'' +String.escapeSingleQuotes(ratToRoleMap.get(ratName))+'\''+
                    ' OR Roles__c =\''+LPI_LiteralConstant.ROLE_PRIMARY_SUPERVISOR+'\''+')';
                
                LPI_BusinessRelationshipDAO.LPI_BusinessRelationshipsWithoutSharingDAO daoInnerObj = new LPI_BusinessRelationshipDAO.LPI_BusinessRelationshipsWithoutSharingDAO();
                for (
                    Business_Relationships__c businessRelationship : daoInnerObj.getBusinessRelationshipsByDymanicQuery(
                        fieldsToQuery,
                        whereClause,
                        null,
                        null,
                        null
                    )
                ) {
                     
                    if (businessRelationship.Roles__c == ratToRoleMap.get(ratName)) {
                        est = new EstablishmentWrapper();
                        est.establishmentLicNo = businessRelationship.Entity_License_Number__c;
                        est.id = businessRelationship.Id;
                        est.serialNumber = count;
                        est.label = 'Establishment - ' + (count + 1);
                        est.isChild = false;
                        est.hideDelete = false;
                        est.isActive = businessRelationship.IsActive__c;
                        est.isDisable = !businessRelationship.IsActive__c;
                        est.beginDate = businessRelationship.Begin_Date_by_Applicant__c != null ? businessRelationship.Begin_Date_by_Applicant__c : businessRelationship.Start_Date__c;
                        est.relationshipAssociatedWithYou = businessRelationship.If_Relationship_is_Associated_with_you__c;
                        est.startDate = businessRelationship.Start_Date__c;
                        est.endDate = businessRelationship.EndDate__c;
                         
                        if (businessRelationship.IsActive__c) {
                            est.hideDelete = true;
                        }
                        est.embalmerDetailList = new List<EmbalmerDetailList>();
                        estList.add(est);
                        count++;
                    }
                     
                    if (
                        String.isNotBlank(ratName) &&
                        LIC_TYPE_ALlOWED_SET.contains(ratName) &&
                        businessRelationship.Roles__c == LPI_LiteralConstant.ROLE_PRIMARY_SUPERVISOR &&
                        String.isNotBlank(businessRelationship.Parent_Relationship__c)
                    ) {
                        parentLicNumList = new List<String>();
                        embalmer = new EmbalmerDetailList();
                        embalmer.embalmerLicNo = businessRelationship.License_Number__c;
                        embalmer.id = businessRelationship.Id;
                        embalmer.serialNumber = 0;
                        embalmer.isActive = businessRelationship.IsActive__c;
                        embalmer.startDate = businessRelationship.Start_Date__c;
                        embalmer.endDate = businessRelationship.EndDate__c;
                        embalmer.parentRelationId = businessRelationship.Parent_Relationship__c;
                         
                        if (businessRelationship.IsActive__c) {
                            embalmer.hideDelete = true;
                        }
                        if (!licIdToEmbChildMap.containsKey(businessRelationship.Parent_Relationship__c)) {
                            licIdToEmbChildMap.put(businessRelationship.Parent_Relationship__c, new List<EmbalmerDetailList>());
                        }
                        licIdToEmbChildMap.get(businessRelationship.Parent_Relationship__c).add(embalmer);
                    }
                }
                 
                for (EstablishmentWrapper establishment : estList) {
                    if (licIdToEmbChildMap.containsKey(establishment.id)) {
                        establishment.embalmerDetailList = licIdToEmbChildMap.get(establishment.id);
                    }
                }
            }
        } catch (Exception e) {
            LPI_ExceptionManager.logException('LPI_EstablishmentInformationController', 'getRecords', e);
            throw new AuraHandledException(e.getMessage() + e.getLineNumber());
        }
        return estList;
    }

	/**
    * @author           MTX Group Product Team
    * @description      Method is used to save the Business_Relationships__c which is linked to Specific License Number selected on UI
                        Ex: If Establishment is Selected then -> businessRelationship will be created between Organization of seleceted business license and 
                        contact of parId (logged in contact id).
                        In case of embalmer businessRelationship will be created between Contact of Selected embalmer business license and 
                        Business Account of parId(logged in Bussiness Account id)
    * @param inputMap
    * @return  `String`
    */
    private static String saveRecord(Map<String, Object> inputMap) {
        try {
            String json = (String) inputMap.get('json');
             
            Id parId = (Id) inputMap.get('parid');
            Id blid = String.isNotBlank((String)inputMap.get('blid')) ? (Id) inputMap.get('blid') : null;
            if(String.isNotBlank(parId)){
                String fieldsToQuery = 'Contact__c, Regulatory_Authorization_Type__r.Name ';
                String whereClause = 'Id = \'' + String.escapeSingleQuotes(parId) + '\'';
                 
                List<PreliminaryApplicationRef> parObjList = LPI_PreliminaryApplicationRefDAO.getPreliminaryApplicationRefByDymanicQuery(
                    fieldsToQuery,
                    whereClause,
                    null,
                    null,
                    null
                );
                 
                List<EstablishmentWrapper> establishmentList = new List<EstablishmentWrapper>();
                establishmentList = (List<EstablishmentWrapper>) System.JSON.deserialize(
                    json,
                    List<EstablishmentWrapper>.class
                );
                List<Business_Relationships__c> businessRelationshipsList = new List<Business_Relationships__c>();
                 
                String fieldsToQueryContacts = 'Id, AccountId';
                String whereClauseContacts = 'Id = \'' + String.escapeSingleQuotes(parObjList[0].Contact__c) + '\'';
                
                List<Contact> conList = LPI_ContactDAO.fetchContactRecords(fieldsToQueryContacts, whereClauseContacts);
                Set<Id> contactIdSet = new Set<Id>();
                Set<Id> orgIdSet = new Set<Id>();
                Set<String> brIdSet = new Set<String>();  
                 
                for (EstablishmentWrapper est : establishmentList) {
                    orgIdSet.add(est.orgId);
                    for (EmbalmerDetailList embalmer : est.embalmerDetailList) {
                        orgIdSet.add(embalmer.contactId);
                    }
                }
                contactIdSet.add(conList[0].AccountId);
                String key = '';
                 
                Map<String, Business_Relationships__c> uniqueKeyToBusinessRelationshipMap = new Map<String, Business_Relationships__c>();
                 
                Map<String, Business_Relationships__c> embalmerKeyToBusinessRelationshipMap = new Map<String, Business_Relationships__c>();
                 
                String fieldsToQueryAcr = 'Id, Name, Related_From__c, Related_To__c, Roles__c, IsActive__c, Start_Date__c, EndDate__c, Parent_Relationship__c, Entity_License_Number__c';
                String whereClauseAcr =
                    ' (Related_From__c IN ' +
                    LPI_ServiceUtility.getStringValuesBySet(orgIdSet) +
                    ' OR Related_To__c IN ' +
                    LPI_ServiceUtility.getStringValuesBySet(contactIdSet) +
                    ') AND (Roles__c = \'' +String.escapeSingleQuotes(ratToRoleMap.get(parObjList[0].Regulatory_Authorization_Type__r.Name))+'\''+
                    ' OR Roles__c =\''+LPI_LiteralConstant.ROLE_PRIMARY_SUPERVISOR+'\''+')';
                 
                LPI_BusinessRelationshipDAO.LPI_BusinessRelationshipsWithoutSharingDAO daoInnerObj = new LPI_BusinessRelationshipDAO.LPI_BusinessRelationshipsWithoutSharingDAO();
                for (
                    Business_Relationships__c businessRelationshipsObj : daoInnerObj.getBusinessRelationshipsByDymanicQuery(
                        fieldsToQueryAcr,
                        whereClauseAcr,
                        null,
                        null,
                        null
                    )
                ) {
                    key = businessRelationshipsObj.Related_From__c + '-' + businessRelationshipsObj.Related_To__c+ '-' + businessRelationshipsObj.Roles__c;
                    if(businessRelationshipsObj.EndDate__c != null){
                        key = key+ '-' + businessRelationshipsObj.EndDate__c;
                    }
                    if(String.isNotBlank(businessRelationshipsObj.Parent_Relationship__c)){
                        key = key+ '-' + businessRelationshipsObj.Parent_Relationship__c;
                    }
                     
                    uniqueKeyToBusinessRelationshipMap.put(key, businessRelationshipsObj);
                }
                
                Set<String> licenseNumberSet = new Set<String>();
                 
                Map<String, Business_Relationships__c> parentLicenseNumberToBusinessRelationMap = new Map<String, Business_Relationships__c>();
                 
                for (EstablishmentWrapper est : establishmentList) {
                    if (!licenseNumberSet.contains(est.establishmentLicNo)) {
                        licenseNumberSet.add(est.establishmentLicNo);
                        key = est.orgId + '-' + conList[0].AccountId + '-' + ratToRoleMap.get(parObjList[0].Regulatory_Authorization_Type__r.Name);
                        Business_Relationships__c businessRelationship = new Business_Relationships__c();
                        
                        if (uniqueKeyToBusinessRelationshipMap.containsKey(key)) {
                            businessRelationship.Id = uniqueKeyToBusinessRelationshipMap.get(key).Id;
                            businessRelationship.Begin_Date_by_Applicant__c = est.beginDate;
                            businessRelationship.If_Relationship_is_Associated_with_you__c = est.relationshipAssociatedWithYou;
                            businessRelationship.Entity_License_Number__c = uniqueKeyToBusinessRelationshipMap.get(key).Entity_License_Number__c;  
                        } else {
                            
                            businessRelationship.Related_From__c = est.orgId;
                            businessRelationship.Related_To__c = conList[0].AccountId;
                            businessRelationship.IsActive__c = false;
                            businessRelationship.Start_Date__c = est.beginDate;
                            businessRelationship.Related_From_License_Number__c = est.establishmentLicId;
                            businessRelationship.Roles__c = ratToRoleMap.get(parObjList[0].Regulatory_Authorization_Type__r.Name);
                            businessRelationship.Entity_License_Number__c = est.establishmentLicNo;
                            businessRelationship.If_Relationship_is_Associated_with_you__c = true;
                            businessRelationship.Related_To_License_Number__c = String.isNotBlank(blid) ? blid : null;
                        }
                        businessRelationshipsList.add(businessRelationship);
                    }
                }
                if(!businessRelationshipsList.isEmpty()){
                    LPI_WithoutSharingUtility.upsertSObjectList(businessRelationshipsList);
                    for(Business_Relationships__c br : businessRelationshipsList){
                        brIdSet.add(br.Id);  
                        if(String.isNotBlank(br.Entity_License_Number__c)){
                            parentLicenseNumberToBusinessRelationMap.put(br.Entity_License_Number__c, br);
                        }
                    }
                }
                List<Business_Relationships__c> childsToInsert = new List<Business_Relationships__c>();
                 
                if (
                    String.isNotBlank(parObjList[0].Regulatory_Authorization_Type__r.Name) &&
                    LIC_TYPE_ALlOWED_SET.contains(parObjList[0].Regulatory_Authorization_Type__r.Name)
                ) {
                    for (EstablishmentWrapper est : establishmentList) {
                        for (EmbalmerDetailList embalmer : est.embalmerDetailList) {
                            if(String.isNotBlank(embalmer.id)){
                                brIdSet.add(embalmer.id);
                            }
                            key = embalmer.contactId + '-' +conList[0].AccountId + '-' + LPI_LiteralConstant.ROLE_PRIMARY_SUPERVISOR;
                            if(String.isNotBlank(embalmer.parentRelationId)){
                                key =  key + '-' + embalmer.parentRelationId;
                            }
                            if (!uniqueKeyToBusinessRelationshipMap.containsKey(key)) {
                                 
                                Business_Relationships__c businessRelationship = new Business_Relationships__c();
                                businessRelationship.Related_From__c = embalmer.contactId;
                                businessRelationship.Related_To__c = conList[0].AccountId;
                                businessRelationship.IsActive__c = false;
                                businessRelationship.Related_From_License_Number__c = embalmer.embalmerLicId;
                                businessRelationship.Start_Date__c = Date.today();
                                businessRelationship.If_Relationship_is_Associated_with_you__c = true;
                                businessRelationship.Roles__c = LPI_LiteralConstant.ROLE_PRIMARY_SUPERVISOR;
                                businessRelationship.License_Number__c = embalmer.embalmerLicNo;
                                businessRelationship.Parent_Relationship__c = parentLicenseNumberToBusinessRelationMap.get(est.establishmentLicNo).Id;
                                businessRelationship.Related_To_License_Number__c = String.isNotBlank(blid) ? blid : null;
                                childsToInsert.add(businessRelationship);
                            }
                        }
                    }
                    if(!childsToInsert.isEmpty()){
                        LPI_WithoutSharingUtility.insertSObjectList(childsToInsert);
                        for(Business_Relationships__c br : childsToInsert){
                            brIdSet.add(br.Id); 
                        }
                    }
                }
                
                if(!licenseNumberSet.isEmpty()){
                    
                    Map<String,PersonEmployment> empLicNumToEmpHisMap = new Map<String,PersonEmployment>();
                     
                    String fieldsToQueryEmpHis = 'Id, Employer_License_Number__c, StartDate, EndDate ';
                    String whereClauseEmpHis = 'RelatedPersonId = \'' + String.escapeSingleQuotes(conList[0].AccountId) + '\''+' AND Employer_License_Number__c IN ' + LPI_ServiceUtility.getStringValuesByStringSet(licenseNumberSet);
                     
                    LPI_PersonEmploymentDAO.LPI_EmploymentHistoryWithoutSharingDAO withoutSharing = new LPI_PersonEmploymentDAO.LPI_EmploymentHistoryWithoutSharingDAO();
                    
                    for(PersonEmployment empHis : withoutSharing.getEmploymentHistoryByDymanicQuery(fieldsToQueryEmpHis, whereClauseEmpHis, null, null, null)){
                        empLicNumToEmpHisMap.put(empHis.Employer_License_Number__c, empHis);
                    }
                     
                    List<PersonEmployment> empHisToUpsert = new List<PersonEmployment>();
                     
                    for (EstablishmentWrapper est : establishmentList) {
                        PersonEmployment empHis = new PersonEmployment();
                        
                        if(empLicNumToEmpHisMap.containsKey(est.establishmentLicNo)){
                            empHis.Id = empLicNumToEmpHisMap.get(est.establishmentLicNo).Id;
                             
                            if(empLicNumToEmpHisMap.get(est.establishmentLicNo).EndDate == null ||
                                (empLicNumToEmpHisMap.get(est.establishmentLicNo).EndDate != null &&
                                empLicNumToEmpHisMap.get(est.establishmentLicNo).EndDate >= est.beginDate)){
                                empHis.StartDate = est.beginDate;
                            }
                        }else{
                             
                            Map<String,String> fieldNameValue = new Map<String,String>{
                                'establishmentLicNo' => est.establishmentLicNo,
                                'establishmentName' => est.establishmentName,
                                'billingStreet' => est.billingStreet,
                                'billingCity' =>  est.billingCity,
                                'billingState' =>  est.billingState,
                                'billingPostalCode' =>  est.billingPostalCode,
                                'phone' =>  est.phone,
                                'inchargeName' =>  est.inchargeName,
                                'inchargeLicNumber' =>  est.inchargeLicNumber,
                                'beginDate' => String.valueOf(est.beginDate)
                            };
                            Map<String,String> keyMappingEmpHis = new Map<String,String>{
                                'establishmentLicNo' => 'Employer_License_Number__c',
                                'establishmentName' => 'Name',
                                'billingStreet' =>'EmployerStreet',
                                'billingCity' => 'EmployerCity',
                                'billingState' => 'EmployerState',
                                'billingPostalCode' => 'EmployerPostalCode',
                                'phone' => 'EmployerPhone',
                                'inchargeName' => 'Immediate_Supervisor_s_Name__c',
                                'inchargeLicNumber' => 'In_charge_License_No__c',
                                'beginDate' => 'StartDate'
                            };
                            empHis = (PersonEmployment) LPI_VlocityUtility.createSObject(
                                fieldNameValue,
                                keyMappingEmpHis,
                                'PersonEmployment'
                            );
                            empHis.RelatedPersonId = conList[0].AccountId;
                            empHis.Preliminary_Application_Reference__c = parId;
                        }
                        empHisToUpsert.add(empHis);
                    }
                    if(!empHisToUpsert.isEmpty()){
                        LPI_WithoutSharingUtility.upsertSObjectRecord(empHisToUpsert);
                    }
                }
                if(!brIdSet.isEmpty()){
                    PreliminaryApplicationRef par = new PreliminaryApplicationRef();
                    par.Id = parId;
                    par.Employee_Information_ACR_Ids__c = String.join(new List<String>(brIdSet),',');
                    LPI_DML.doUpdate(par);
                }
            }
        } catch (Exception e) {
            LPI_ExceptionManager.logException('LPI_EstablishmentInformationController', 'saveRecord', e);
            throw new AuraHandledException(e.getMessage() + e.getLineNumber());
        }
        return 'success';
    }

	/**
	 * @author          MTX Group Product Team
	 * @description     Method is used to delete Existing non active businessRelationship in Case of Establishment OR Embalmer which are only assiciated with one parent are deleted directly
	 *                  but Embalmer which are associated with more than 1 parent first they parent lic Number gets removed until they are connected to only one Establishment.
	 * @param           inputMap
	 * @return          `String`
	 */
	private static String deleteRecords(Map<String, Object> inputMap) {
		try {
			 
			Id recordId = (Id) inputMap.get('recordId');
            if(String.isNotBlank(recordId)){
                if(!LPI_WithoutSharingUtility.checkACRAccess(recordId)){
                    throw new LPI_Exception('You can\'t delete this record');
                }
               
                String estLicNumber = (String) inputMap.get('estLicNumber');
                
                Set<Id> allRecordId = new Set<Id>();
                
                allRecordId.add(recordId);
                 
                if (inputMap.get('childElementIdList') != null) {
                    for (Object instance : (List<Object>) inputMap.get('childElementIdList')) {
                        allRecordId.add((String) instance);
                    }
                }
                String fieldsToQuery = 'Id, Entity_License_Number__c, Related_From__c, IsActive__c, If_Relationship_is_Associated_with_you__c, Related_To__c ';
                String whereClause = 'Id IN ' + LPI_ServiceUtility.getStringValuesBySet(allRecordId)+ ' And IsActive__c = false';
                List<Business_Relationships__c> businessRelationshipsListToDelete = new List<Business_Relationships__c>();
                List<Business_Relationships__c> businessRelationshipsListToUpdate = new List<Business_Relationships__c>();
                Set<Id> personAccountIdSet = new Set<Id>();
                Set<String> licNumToDelEmpHisSet = new Set<String>();
                
                LPI_BusinessRelationshipDAO.LPI_BusinessRelationshipsWithoutSharingDAO daoInnerObj = new LPI_BusinessRelationshipDAO.LPI_BusinessRelationshipsWithoutSharingDAO();
                businessRelationshipsListToDelete = daoInnerObj.getBusinessRelationshipsByDymanicQuery(fieldsToQuery, whereClause, null, null, null);
                for (Business_Relationships__c businessRelationship : businessRelationshipsListToDelete) {
                    if (String.isNotBlank(businessRelationship.Related_To__c) &&
                    String.isNotBlank(businessRelationship.Entity_License_Number__c)) {
                         
                        personAccountIdSet.add(businessRelationship.Related_To__c);
                        licNumToDelEmpHisSet.add(businessRelationship.Entity_License_Number__c);
                    }
                }
                
                if (!businessRelationshipsListToDelete.isEmpty()) {
                    
                    LPI_WithoutSharingUtility.deleteSObject(businessRelationshipsListToDelete);
                }
                if(!personAccountIdSet.isEmpty() && !licNumToDelEmpHisSet.isEmpty()){
                    String fieldsToQueryToDeleteEmpHis = 'Id ';
                    String whereClauseToDeleteEmpHis = 'RelatedPersonId IN ' + LPI_ServiceUtility.getStringValuesBySet(personAccountIdSet) +' AND Employer_License_Number__c IN ' + LPI_ServiceUtility.getStringValuesByStringSet(licNumToDelEmpHisSet) +' AND Status__c != \'' +Employment_History_Verified +'\'';
                    
                    LPI_PersonEmploymentDAO.LPI_EmploymentHistoryWithoutSharingDAO withoutSharing = new LPI_PersonEmploymentDAO.LPI_EmploymentHistoryWithoutSharingDAO();
                    List<PersonEmployment> empHisToDelete = withoutSharing.getEmploymentHistoryByDymanicQuery(fieldsToQueryToDeleteEmpHis, whereClauseToDeleteEmpHis, null, null, null);
                    if(!empHisToDelete.isEmpty()){
                        
                        LPI_WithoutSharingUtility.deleteSObject(empHisToDelete);
                    }
                }
            }
		} catch (Exception e) {
			LPI_ExceptionManager.logException('LPI_EstablishmentInformationController', 'deleteRecords', e);
			throw new AuraHandledException(e.getMessage() + e.getLineNumber());
		}
		return 'success';
	}

    /**
	 * @author          MTX Group Product Team
	 * @description     Method is used to fetch the details relevant to selected license number based on param `isChild` and `searchKey`
	 * @param           inputMap
	 * @return          `List<Map<String, String>>`
	 */
	private static List<Map<String, String>> getEstablishmentInformation(Map<String, Object> inputMap) {
		List<Map<String, String>> allResultMap = new List<Map<String, String>>();
		try {
			String searchblock = '\'%' + String.escapeSingleQuotes((String) inputMap.get('searchKey')) + '%\'';
			Boolean isChild = (Boolean) inputMap.get('isChild');
            Boolean isSupervisorSearch = (Boolean) inputMap.get('isSupervisorSearch');
			String fullName = '';
			Map<String, String> resultMap;
			String fieldsToQuery = '';
			String whereClause = '';
			if (String.isNotBlank((String) inputMap.get('searchKey'))) {
				 
				if (isChild) {
                    List<BusinessLicense> blList = new List<BusinessLicense>();
					fieldsToQuery = 'ID, Name, First_Name__c, Middle_Name__c, Last_Name__c, Business_Name__c, ContactId, AccountId, Contact.AccountId, ';
					fieldsToQuery =
						fieldsToQuery +
						' RegulatoryAuthorizationType.Name, RegulatoryAuthorizationType.Authorisation_Type__c, License_Number_With_Rat_Name__c ';
					whereClause =
						'ContactId != null AND AccountId != null AND RegulatoryAuthorizationType.Authorisation_Type__c = \'' +
                        LPI_LiteralConstant.INDIVIDAULICENSE_APPTYPE + '\'';
                    
                     
                    if(!isSupervisorSearch){
                        whereClause =
                            whereClause +
                            ' AND RegulatoryAuthorizationType.Name IN ' + LPI_ServiceUtility.getStringValuesByStringSet(SUPERVISOR_RAT_SET) +
                            ' AND Name LIKE ' + searchblock ;
                        
                        blList = new LPI_BusinessLicenseDAO.LPI_BusinessLicenseWithoutSharingDAO().getBusinessLicenseByDymanicQuery(fieldsToQuery,whereClause,'100',null,null);
                    } else{
                        String regAuthTypeName = (String) inputMap.get('regAuthTypeName');
                        
                        whereClause += ' AND Status = \'Active\' AND Name LIKE ' + searchblock + ' AND Approved_Supervisor__c = true';
                        fieldsToQuery = fieldsToQuery + ', Account.PersonEmail, Account.PersonOtherCity, Account.PersonOtherState, Account.PersonOtherStreet, Account.PersonOtherPostalCode, Account.Phone ';
                        if(regAuthTypeName == PROVISIONAL_LICENSE_PROFESSIONAL_COUNSELOR_LICENSE_TYPE){
                            whereClause += ' AND Regulatory_Authorization_Type_Name__c = \'' + PROFESSIONAL_COUNSELOR_LICENSE_TYPE + '\'';
                        } else if (regAuthTypeName == PROVISIONAL_MARITAL_AND_FAMILY_THERAPIST_LICENSE_TYPE){
                            whereClause = whereClause + ' AND Regulatory_Authorization_Type_Name__c IN ' + LPI_ServiceUtility.getStringValuesByStringSet(PROFESSIONAL_MFT_TYPEAHED_RAT_SET);
                        } else if(SOCIAL_WOKER_MAP.containsKey(regAuthTypeName)){
                            whereClause += ' AND Regulatory_Authorization_Type_Name__c IN ' + LPI_ServiceUtility.getStringValuesByStringSet(SOCIAL_WOKER_MAP.get(regAuthTypeName));
                        }
                        blList = new LPI_BusinessLicenseDAO.LPI_BusinessLicenseWithoutSharingDAO().getBusinessLicenseByDymanicQuery(fieldsToQuery,whereClause,'100',null,null);
                    }
                        
					
                    for (
						BusinessLicense bl : blList
					) {
						resultMap = new Map<String, String>();
						
                        if(isSupervisorSearch){
                            resultMap.put('supervisorFirstName', (String) bl?.First_Name__c);
                            resultMap.put('supervisorMiddleName', (String) bl?.Middle_Name__c);
                            resultMap.put('supervisorLastName', (String) bl?.Last_Name__c);
                            resultMap.put('supervisorLicenseType', (String) bl?.RegulatoryAuthorizationType.Authorisation_Type__c);
                            resultMap.put('supervisorStreetAddress', (String) bl?.Account.PersonOtherStreet);
                            resultMap.put('supervisorCity', (String) bl?.Account.PersonOtherCity);
                            resultMap.put('supervisorState', (String) bl?.Account.PersonOtherState);
                            resultMap.put('supervisorZipCode', (String) bl?.Account.PersonOtherPostalCode);
                            String phoneNo = (String) bl?.Account.Phone;
                            resultMap.put('supervisorTelephoneNo', String.isBlank(phoneNo) ? '' : '(' + phoneNo.substring(0, 3) + ') ' + phoneNo.substring(3, 6) + '-' + phoneNo.substring(6));
                            resultMap.put('supervisorEmail', (String) bl?.Account.PersonEmail);
                            resultMap.put('supervisorLicNo', (String) bl?.Name);
                            resultMap.put('supervisorAccountId', (String) bl?.AccountId);
                        } else {
                            fullName = '';
                            fullName = fullName + bl.First_Name__c + ' ';
                            fullName = fullName + (String.isNotBlank(bl.Middle_Name__c) ? bl.Middle_Name__c + ' ' : '');
                            fullName = fullName + bl.Last_Name__c;
                            resultMap.put('Business_Name__c', (String) fullName);
                            resultMap.put('orgId', (String) bl?.AccountId);
                        }
                        resultMap.put('TypeAheadKey', (String) bl?.License_Number_With_Rat_Name__c);
                        resultMap.put('Name', (String) bl?.Name);
                        resultMap.put('Id', (String) bl?.Id);
                        resultMap.put('contactId', (String) bl?.Contact.AccountId);
						allResultMap.add(resultMap);
					}
				} else {
					 
					Set<Id> orgIdSet = new Set<Id>();
					Map<String, String> accountIdToInchargeNameMap = new Map<String, String>();
					Map<String, String> accountIdToInchargeIdMap = new Map<String, String>();
					Map<String, String> InchargeIdToLicNumberMap = new Map<String, String>();
					List<String> allowedRoles = new List<String>{
						LPI_LiteralConstant.ROLE_DESIGNATED_INCHARGE
					};
					 
					fieldsToQuery = 'ID, Name, Business_Name__c, ContactId, AccountId, Account.Phone, Account.BillingStreet, License_Number_With_Rat_Name__c, ';
					fieldsToQuery =
						fieldsToQuery +
						' Account.BillingCity, Account.BillingState, Account.BillingPostalCode, RegulatoryAuthorizationType.Name, Contact.AccountId ';
					whereClause =
						' AccountId != null AND RegulatoryAuthorizationType.Name = \'' +
						LPI_LiteralConstant.LICENSE_TYPE_FUNERAL_ESTABLISHMENT +
						'\'';
                    whereClause = whereClause + ' AND (Name LIKE ' + searchblock + ' OR Business_Name__c LIKE ' + searchblock +')';
					 
					LPI_BusinessLicenseDAO.LPI_BusinessLicenseWithoutSharingDAO classObj = new LPI_BusinessLicenseDAO.LPI_BusinessLicenseWithoutSharingDAO();
					List<BusinessLicense> blList = classObj.getBusinessLicenseByDymanicQuery(fieldsToQuery,whereClause,'100',null,null);
					for (
						BusinessLicense bl : blList
					) {
						orgIdSet.add(bl.AccountId);
					}
					if (!orgIdSet.isEmpty()) {
						 
						fieldsToQuery = ' Id, Roles__c, Related_From__c, Related_From__r.Name, Related_To__c, Related_To__r.Name ';
						whereClause =
							' IsActive__c = true AND Related_From__c IN ' + LPI_ServiceUtility.getStringValuesBySet(orgIdSet);
						whereClause =
							whereClause +
							' AND Roles__c IN ' +
							LPI_ServiceUtility.getStringValuesByList(allowedRoles);
						 
						LPI_BusinessRelationshipDAO.LPI_BusinessRelationshipsWithoutSharingDAO daoInnerObj = new LPI_BusinessRelationshipDAO.LPI_BusinessRelationshipsWithoutSharingDAO();
						for (
							Business_Relationships__c businessRelationship : daoInnerObj.getBusinessRelationshipsByDymanicQuery(
								fieldsToQuery,
								whereClause,
								null,
								null,
								null
							)
						) {
							accountIdToInchargeNameMap.put(businessRelationship.Related_From__c, businessRelationship.Related_To__r.Name);
							accountIdToInchargeIdMap.put(businessRelationship.Related_From__c, businessRelationship.Related_To__c);
						}
						if (!accountIdToInchargeIdMap.values().isEmpty()) {
							 
							fieldsToQuery = 'Id, Name, Contact.AccountId, RegulatoryAuthorizationType.Name ';
							whereClause =
								' Contact.AccountId IN ' +
								LPI_ServiceUtility.getStringValuesByList(accountIdToInchargeIdMap.values()) +
                                ' AND RegulatoryAuthorizationType.Name = \'' + LPI_LiteralConstant.LICENSE_TYPE_FUNERAL_DIRECTOR + '\'';
							 
                            LPI_BusinessLicenseDAO.LPI_BusinessLicenseWithoutSharingDAO classObjToFetchInchargeLicenses = new LPI_BusinessLicenseDAO.LPI_BusinessLicenseWithoutSharingDAO();
							for (
								BusinessLicense bl : classObjToFetchInchargeLicenses.getBusinessLicenseByDymanicQuery(
									fieldsToQuery,
									whereClause,
                                    '100',
                                    null,
                                    null
								)
							) {
								InchargeIdToLicNumberMap.put(bl.Contact.AccountId, bl.Name);
							}
						}
					}
					for (
						BusinessLicense bl : blList
					) {
						resultMap = new Map<String, String>();
						resultMap.put('Name', (String) bl?.Name);
						resultMap.put('Id', (String) bl?.Id);
						resultMap.put('Business_Name__c', (String) bl?.Business_Name__c);
						resultMap.put('BillingStreet', (String) bl?.Account.BillingStreet);
						resultMap.put('BillingCity', (String) bl?.Account.BillingCity);
						resultMap.put('BillingState', (String) bl?.Account.BillingState);
						resultMap.put('BillingPostalCode', (String) bl?.Account.BillingPostalCode);
						resultMap.put('Phone', (String) bl?.Account.Phone);
						resultMap.put('orgId', (String) bl?.AccountId);
                        resultMap.put('TypeAheadKey', (String) bl?.License_Number_With_Rat_Name__c);
						if (accountIdToInchargeNameMap.containsKey(bl.AccountId)) {
							resultMap.put('inchargeName', accountIdToInchargeNameMap.get(bl.AccountId));
							String contactId = '';
							 
							if (accountIdToInchargeIdMap.containsKey(bl.AccountId)) {
								contactId = accountIdToInchargeIdMap.get(bl.AccountId);
								if (InchargeIdToLicNumberMap.containsKey(contactId)) {
									 
									resultMap.put('inchargeLicNumber', InchargeIdToLicNumberMap.get(contactId));
								}
							}
						}
						 
						allResultMap.add(resultMap);
					}
				}
			}
		} catch (Exception e) {
			LPI_ExceptionManager.logException(
				'LPI_EstablishmentInformationController',
				'getEstablishmentInformation',
				e
			);
			throw new AuraHandledException(e.getStackTraceString());
		}
		return allResultMap;
	}

	 
	public class EstablishmentWrapper {
		public Integer serialNumber;
		public Integer memberCount;
		public String id;
		public Boolean hideDelete;
		public String label;
		public List<EmbalmerDetailList> embalmerDetailList;
		public List<String> childElementList;
		public String establishmentLicNo;
		public String establishmentLicId;
		public String establishmentName;
		public String orgId;
		public String billingStreet;
		public String billingCity;
		public String billingState;
		public String billingPostalCode;
		public String phone;
		public Boolean isChild;
		public Boolean isActive;
		public Boolean relationshipAssociatedWithYou;
		public Boolean isDisable;
		public Date beginDate;
		public String inchargeName;
		public String inchargeLicNumber;
        public Date startDate;
        public Date endDate;
		public EstablishmentWrapper() {
			this.serialNumber = 0;
			this.memberCount = 0;
			this.id = '';
			this.hideDelete = false;
			this.label = '';
			this.embalmerDetailList = new List<embalmerDetailList>();
			this.childElementList = new List<String>();
			this.establishmentLicNo = '';
			this.establishmentLicId = '';
			this.establishmentName = '';
			this.orgId = '';
			this.billingStreet = '';
			this.billingCity = '';
			this.billingState = '';
			this.billingPostalCode = '';
			this.phone = '';
			this.isChild = false;
			this.isActive = false;
			this.relationshipAssociatedWithYou = false;
			this.isDisable = false;
			this.beginDate = null;
			this.inchargeName = '';
			this.inchargeLicNumber = '';
            this.startDate = null;
            this.endDate = null;
		}
	}

	 
	public class EmbalmerDetailList {
		public String embalmerLicNo;
		public Integer memberCount;
		public Integer serialNumber;
		public String label;
		public Boolean hideDelete;
		public Boolean isChild;
		public Boolean isActive;
		public String embalmerName;
		public String contactId;
		public String id;
		public String embalmerLicId;
		public Boolean isDisable;
        public Date startDate;
        public Date endDate;
        public String parentRelationId;
		public EmbalmerDetailList() {
			this.embalmerLicNo = '';
			this.memberCount = 0;
			this.serialNumber = 0;
			this.label = '';
			this.hideDelete = false;
			this.isChild = false;
			this.isActive = false;
			this.embalmerName = '';
			this.contactId = '';
			this.id = '';
			this.embalmerLicId = '';
			this.isDisable = false;
            this.startDate = null;
            this.endDate = null;
            this.parentRelationId = '';
		}
	}

	 
	public class EstablishmentBusinessWrapper {
		public Integer serialNumber;
		public Integer memberCount;
		public String id;
		public Boolean hideDelete;
		public Boolean relationshipAssociatedWithYou;
		public Boolean isActive;
		public String label;
		public String establishmentLicNo;
		public String establishmentLicId;
		public String establishmentName;
		public String orgId;
		public String billingStreet;
		public String billingCity;
		public String billingState;
		public String billingPostalCode;
		public String phone;
		public Date beginDate;
		public String relatedFrom;
		public String relatedTo;
		public String inchargeName;
		public String inchargeLicNumber;
		public Boolean isDisable;
        public Date startDate;
        public Date endDate;
		public EstablishmentBusinessWrapper() {
			this.serialNumber = 0;
			this.memberCount = 0;
			this.id = '';
			this.hideDelete = false;
			this.relationshipAssociatedWithYou = false;
			this.isActive = false;
			this.label = '';
			this.establishmentLicNo = '';
			this.establishmentLicId = '';
			this.establishmentName = '';
			this.orgId = '';
			this.billingStreet = '';
			this.billingCity = '';
			this.billingState = '';
			this.billingPostalCode = '';
			this.phone = '';
			this.beginDate = null;
			this.relatedFrom = '';
			this.relatedTo = '';
			this.inchargeName = '';
			this.inchargeLicNumber = '';
			this.isDisable = false;
            this.startDate = null;
            this.endDate = null;
		}
	}
}