/**
 * @author      : Garvit Jain
 * @since       : June 15, 2023, 12:36 AM
 * @description : This class `LPI_AliasController` implements the `Callable` interface and contains the `invokeMethod()` method
 *                which is used to call the respective action methods based on the methodName passed as argument - S-49484
 * -------------------------------------------------------------------------------------------------------
 * Version      Date                 Author                   Details
 *    1         June 15, 2023        Garvit Jain              Initial Developement - S-49484 - Alias section on personal information across boards
 *    2         December 21, 2023    Aditya Chaturvedi        Segregated methods according to BoardName (Real Estate or Non Real Estate)
 * -------------------------------------------------------------------------------------------------------
 */
global with sharing class LPI_AliasController implements Callable {
    // *************************************** ALL CONSTANTS ***************************************************
    private static final String LPI_ALIAS_CONTROLLER_CLASS_NAME = 'LPI_AliasController';

    /**
     * @author                      : Garvit Jain
     * @since                       : June 15, 2023
     * @description                 : This method is used to internally call the `invokeMethod` method
     * @param action                : It contains method name which is called from OmniScript
     * @param args                  : It is Map<String, Object> which contanis `input`, `output` and `options`
     * @return                      : `Object`
     * @last modified by            : MTX Group Inc
     * @last modified date          : {Add if last modified by you}
     * @last modified details       : {Add if last modified by you}
     */
    global Object call(String action, Map<String, Object> args) {
        Map<String, Object> input = (Map<String, Object>) args.get('input');
        Map<String, Object> output = (Map<String, Object>) args.get('output');
        Map<String, Object> options = (Map<String, Object>) args.get('options');
        return invokeMethod(action, input, output, options);
    }

    /**
     * @author                      : Garvit Jain
     * @since                       : June 15, 2023
     * @description                 : This method is called from `call` method and internally calls the OmniScript methods
     * @param methodName            : It contains method name which is called from OmniScript
     * @param inputMap              : Input data passed from OmniScript
     * @param outMap                : Output data passed to OmniScript
     * @param options               : Optional Input passed from OmniScript
     * @return                      : `Boolean`
     * @last modified by            : MTX Group Inc
     * @last modified date          : December 21, 2023
     * @last modified details       : Real Estate Alias changes
     */
    private Boolean invokeMethod(String methodName, Map<String, Object> inputMap, Map<String, Object> outMap, Map<String, Object> options) {
        Boolean result = true;
        try {
            switch on methodName {
                when 'getAliasData' {
                    getAliasData(inputMap, outMap);
                }
                when 'upsertAliasData' {
                    String aliasName = '';
                    Map<String, Object> nonRealEstateBoardAliasFieldsMap = new Map<String, Object>();
                    Map<String, Object> realEstateBoardAliasFieldsMap = new Map<String, Object>();
                    if (inputMap.containsKey('AliasNonRealEstateBoardBlock')) {
                        nonRealEstateBoardAliasFieldsMap = (Map<String, Object>) inputMap.get('AliasNonRealEstateBoardBlock');
                        if (nonRealEstateBoardAliasFieldsMap != null) {
                            aliasName = (String) nonRealEstateBoardAliasFieldsMap.get('AliasName');
                        }
                    }
                    if (inputMap.containsKey('AliasRealEstateBoardBlock')) {
                        realEstateBoardAliasFieldsMap = (Map<String, Object>) inputMap.get('AliasRealEstateBoardBlock');
                        if (realEstateBoardAliasFieldsMap != null) {
                            aliasName = (String) realEstateBoardAliasFieldsMap.get('RealEstate_AliasName');
                        }
                    }
                    if (String.isNotBlank(aliasName)) {
                        upsertAliasData(inputMap, outMap, nonRealEstateBoardAliasFieldsMap, realEstateBoardAliasFieldsMap);
                    } 
                    else {
                        result = false;
                        throw new LPI_Exception('Please enter all Required fields');
                    }
                }
                when 'inactivateAliasData' {
                    inactivateAliasData(inputMap, outMap);
                }
            }
        }
        catch (Exception ex) {
            result = false;
            LPI_ExceptionManager.logException(LPI_ALIAS_CONTROLLER_CLASS_NAME, 'invokeMethod', ex);
            throw new LPI_Exception(ex.getMessage());
        }
        return result;
    }

    /**
     * @author                      : Garvit Jain
     * @since                       : June 15, 2023
     * @description                 : This method fetches Alias Data Records (Alias__c object)
     * @param inputMap              : Input data passed from OmniScript
     * @param outMap                : Output data passed to OmniScript
     * @return                      : `void`
     * @last modified by            : MTX Group Inc
     * @last modified date          : December 21, 2023
     * @last modified details       : Real Estate Alias changes
     */
    public static void getAliasData(Map<String, Object> inputMap, Map<String, Object> outMap) {
        try {
            String parId = inputMap.containsKey('parid') ? (String) inputMap.get('parid') : null;
            Boolean isSupervisorUser = false;
            String approvalSupervisorIds;
            String accountId;
            List<PreliminaryApplicationRef> parList = new List<PreliminaryApplicationRef>();
            if (parId != null) {
                String fields = 'Id, Is_Supervisor_User__c, Approval_Supervisors_AcrIds__c, BusinessAccountNameId';
                String whereClause = 'Id = \'' + String.escapeSingleQuotes(parId) + '\'';
                parList = LPI_PreliminaryApplicationRefDAO.getPreliminaryApplicationRefByDymanicQuery(fields, whereClause, null, null, null);
                if (!parList.isEmpty()) {
                    isSupervisorUser = parList[0].Is_Supervisor_User__c;
                    approvalSupervisorIds = parList[0].Approval_Supervisors_AcrIds__c;
                }
            }
            List<Map<String, Object>> aliasDataList = new List<Map<String, Object>>();
            List<Alias__c> aliasList = new List<Alias__c>();
            String fields = 'Account__c, Alias_From_Date__c, Status__c, Alias_Thru_Date__c, Alias_Type__c, Id, Name';
            if (isSupervisorUser && approvalSupervisorIds != null) {
                accountId = (String) parList[0].BusinessAccountNameId;
                String whereClause = 'Status__c = \'' + String.escapeSingleQuotes('Active') + '\' AND Is_Present_On_Account__c = false' +
                                        ' AND Account__c = \'' + String.escapeSingleQuotes(accountId) + '\'';
                LPI_AliasDAO.LPI_AliasWithoutSharingDAO withoutSharingQuery = new LPI_AliasDAO.LPI_AliasWithoutSharingDAO();
                aliasList = withoutSharingQuery.getAliasByDymanicQuery(fields, whereClause, null, null, null);
            } 
            else {
                accountId = (String) inputMap.get('accountId');
                String whereClause = 'Status__c = \'' + String.escapeSingleQuotes('Active') + '\' AND Is_Present_On_Account__c = false' +
                                        ' AND Account__c = \'' + String.escapeSingleQuotes(accountId) + '\'';
                aliasList = LPI_AliasDAO.getAliasByDymanicQuery(fields, whereClause, null, null, null);
            }
            if (aliasList.size() > 0) {
                Map<String, Object> aliasDataMap;
                Map<String, Object> realEstateBoardAliasFieldsMap;
                for (Alias__c aliasData : aliasList) {
                    aliasDataMap = new Map<String, Object>();
                    realEstateBoardAliasFieldsMap = new Map<String, Object>();
                    aliasDataMap.put('IdPhysicianIntake', aliasData.Id);
                    aliasDataMap.put('Status', aliasData.Status__c);
                    aliasDataMap.put('AliasType', aliasData.Alias_Type__c);
                    aliasDataMap.put('AliasName', aliasData.Name);
                    aliasDataMap.put('AliasFrom', aliasData.Alias_From_Date__c); 
                    aliasDataMap.put('AliasThru', aliasData.Alias_Thru_Date__c);
                    aliasDataMap.put('RealEstate_AliasType', aliasData.Alias_Type__c);
                    aliasDataMap.put('RealEstate_AliasName', aliasData.Name);
                    realEstateBoardAliasFieldsMap.put('RealEstate_AliasFrom', aliasData.Alias_From_Date__c);
                    realEstateBoardAliasFieldsMap.put('RealEstate_AliasThru', aliasData.Alias_Thru_Date__c);
                    aliasDataMap.put('AliasRealEstateBoardBlock', realEstateBoardAliasFieldsMap);
                    aliasDataList.add(aliasDataMap);
                }
                outMap.put('AliasTable', aliasDataList);
            }
        }
        catch (Exception ex) {
            LPI_ExceptionManager.logException(LPI_ALIAS_CONTROLLER_CLASS_NAME, 'getAliasData', ex);
            throw new LPI_Exception(ex.getMessage());
        }
    }

    /**
     * @author                                      : Garvit Jain
     * @since                                       : June 15, 2023
     * @description                                 : This method upserts Alias Data Records (Alias__c object)
     * @param inputMap                              : Input data passed from OmniScript
     * @param outMap                                : Output data passed to OmniScript
     * @param nonRealEstateBoardAliasFieldsMap      : AliasNonRealEstateBoardBlock Input data passed to OmniScript
     * @param realEstateBoardAliasFieldsMap         : AliasRealEstateBoardBlock Input data passed to OmniScript
     * @return                                      : `void`
     * @last modified by                            : MTX Group Inc
     * @last modified date                          : December 21, 2023
     * @last modified details                       : Real Estate Alias changes
     */
    public static Map<String, Object> upsertAliasData(Map<String, Object> inputMap, Map<String, Object> outMap, 
        Map<String, Object> nonRealEstateBoardAliasFieldsMap, Map<String, Object> realEstateBoardAliasFieldsMap) {
            Map<String, Object> response = new Map<String, Object>();
        try {
            Alias__c aliasData = new Alias__c();
            aliasData.Id = (String) inputMap.get('IdPhysicianIntake');
            if (nonRealEstateBoardAliasFieldsMap != null) {
                aliasData.Alias_Type__c = (String) nonRealEstateBoardAliasFieldsMap.get('AliasType');
                aliasData.Name = (String) nonRealEstateBoardAliasFieldsMap.get('AliasName');
                aliasData.Alias_From_Date__c = String.isNotBlank((String) nonRealEstateBoardAliasFieldsMap.get('AliasFrom'))
                                            ? Date.valueOf((String) nonRealEstateBoardAliasFieldsMap.get('AliasFrom')) : null;
                aliasData.Alias_Thru_Date__c = String.isNotBlank((String) nonRealEstateBoardAliasFieldsMap.get('AliasThru'))
                                            ? Date.valueOf((String) nonRealEstateBoardAliasFieldsMap.get('AliasThru')) : null;
            }
            else if (realEstateBoardAliasFieldsMap != null) {
                aliasData.Alias_Type__c = (String) realEstateBoardAliasFieldsMap.get('RealEstate_AliasType');
                aliasData.Name = (String) realEstateBoardAliasFieldsMap.get('RealEstate_AliasName');
            }
            aliasData.Account__c = (String) inputMap.get('ParentAccountId');
            aliasData.Status__c = 'Active';
            aliasData = (Alias__c) LPI_DML.doUpsert(aliasData);
            outMap.put('IdPhysicianIntake', aliasData.Id);

            response.put('status', 'success');
            response.put('message', 'Alias data saved successfully');
            response.put('IdPhysicianIntake', aliasData.Id);
            return response;
        }
        catch (Exception ex) {
            LPI_ExceptionManager.logException(LPI_ALIAS_CONTROLLER_CLASS_NAME, 'upsertAliasData', ex);
            throw new LPI_Exception(ex.getMessage());
        }
    }

    /**
     * @author                      : Garvit Jain
     * @since                       : June 15, 2023
     * @description                 : This method inactivates Alias Data Records (Alias__c object)
     * @param inputMap              : Input data passed from OmniScript
     * @param outMap                : Output data passed to OmniScript
     * @return                      : `void`
     * @last modified by            : MTX Group Inc
     * @last modified date          : December 21, 2023
     * @last modified details       : Code Beautification
     */
    public static void inactivateAliasData(Map<String, Object> inputMap, Map<String, Object> outMap) {
        try {
            Alias__c aliasData = new Alias__c();
            aliasData.Id = (String) inputMap.get('IdPhysicianIntake');
            aliasData.Status__c = 'Inactive';
            aliasData = (Alias__c) LPI_DML.doUpsert(aliasData);
        }
        catch (Exception ex) {
            LPI_ExceptionManager.logException(LPI_ALIAS_CONTROLLER_CLASS_NAME, 'inactivateAliasData', ex);
            throw new LPI_Exception(ex.getMessage());
        }
    }
}