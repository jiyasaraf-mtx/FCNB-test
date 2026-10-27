/**
 * @author      : Neeraj Avadhanam
 * @since       : 02 Feb, 2023
 * @description : This Class Contains the Logic for Facility Name Change or DBA Name Change Controller
 *  -------------------------------------------------------------------------------------------------------
 * Version      Date                Author                  Details
 *    1         02 Feb, 2023        Neeraj Avadhanam        Initial Developement
 * -------------------------------------------------------------------------------------------------------
 */
global with sharing class LPI_FacilityOrDBANameChangeController implements Callable {
    /* ********* Class Constants ********* */
    public static final string AMENDMENT_TYPE_NEW = 'New';
    public static final string AMENDMENT_TYPE_CANCEL = 'Cancel';
    public static final string AMENDMENT_TYPE_RENEW = 'Renew';
    // public static final string REG_AUTH_TYPE_RS_PARTNERSHIP = 'Real Estate Partnership';

    /**
    * @description 
    * @author Ayush Dev | 05-06-2024 
    * @param action 
    * @param args 
    * @return Object 
    **/
    global Object call(String action, Map<String, Object> args) {
        Map<String, Object> input = (Map<String, Object>) args.get('input');
        Map<String, Object> output = (Map<String, Object>) args.get('output');
        Map<String, Object> options = (Map<String, Object>) args.get('options');

        return invokeMethod(action, input, output, options);
    }
    /**
     * @author            Neeraj Avadhanam
     * @updated           Neeraj Avadhanam
     * @description       This method will compare method from Omniscript and execute only that specific method
     * @return  `Boolean`
     */
    global Boolean invokeMethod(
        String methodName,
        Map<String, Object> inputMap,
        Map<String, Object> outMap,
        Map<String, Object> options
    ) {
        Boolean result = true;
        try {
            switch on methodName {
                // when 'RSBSaveNewBusinessName' {
                //     RSBSaveNewBusinessName(inputMap, outMap);
                // }
                when 'RSBSaveNewFictitiousNameName' {
                    RSBSaveNewFictitiousNameName(inputMap, outMap);
                }
                when 'RSBGetNewAndFormerBusinessNameOrFictitiousName' {
                    RSBGetNewAndFormerBusinessNameOrFictitiousName(
                        inputMap,
                        outMap
                    );
                }
                // when 'RSBSaveNewBusinessNameAndDbaName'{
                //     RSBSaveNewBusinessName(inputMap, outMap);
                //     RSBSaveNewFictitiousNameName(inputMap, outMap);
                // }
                when else {
                    result = false;
                }
            }
        } catch (Exception e) {
            result = false;
        }
        return result;
    }
    /**
     * @author                      : Neeraj Avadhanam
     * @since                       : 05 Dec, 2022
     * @description                 : This method is Used to save new Business name in Business Name Amendment Flow
     * @return                      : `void`
     * @last modified by            : MTX Group Inc
     * @last modified date          : 02 Feb, 2023
     * @last modified details       : Optimised Conditions
     */
    // public static void RSBSaveNewBusinessName(
    //     Map<String, Object> inputMap,
    //     Map<String, Object> outMap
    // ) {
    //     Map<String, Object> newBusinessStepInfo = (Map<String, Object>) inputMap.get(
    //         'BusinessNameChangeStep'
    //     );
    //     try {
    //         Map<String, String> keyMappingPAR = new Map<String, String>();
    //         keyMappingPAR.put('NewBusinessName', 'Business_Name__c');
    //         keyMappingPAR.put('FormerBusinessName', 'Other_Names__c');
    //         keyMappingPAR.put(
    //             'NewEffectiveDateOfNameChange',
    //             'Effective_Date__c'
    //         );
    //         PreliminaryApplicationRef amendPARDetailsRec = (PreliminaryApplicationRef) LPI_VlocityUtility.createSObject(
    //             newBusinessStepInfo,
    //             keyMappingPAR,
    //             'PreliminaryApplicationRef'
    //         );
    //         amendPARDetailsRec.Id = (Id) inputMap.get('parId');
    //         if ((Id) inputMap.get('parId') != null) {
    //             LPI_DML.doUpdate(amendPARDetailsRec);
    //         }
    //     } catch (Exception exp) {
    //         LPI_ExceptionManager.logException(
    //             'LPI_FacilityOrDBANameChangeController',
    //             'RSBSaveNewBusinessName',
    //             exp
    //         );
    //     }
    // }

    /**
     * @author                      : Neeraj Avadhanam
     * @since                       : 06 Dec, 2022
     * @description                 : This method is Used to save new Fictitious name in Business Name Amendment Flow
     * @return                      : `void`
     * @last modified by            : MTX Group Inc
     * @last modified date          : 02 Feb, 2023
     * @last modified details       : Optimised Conditions
     */
    public static void RSBSaveNewFictitiousNameName(
        Map<String, Object> inputMap,
        Map<String, Object> outMap
    ) {
        Map<String, Object> NewFictitiousNameStepInfo = (Map<String, Object>) inputMap.get(
            'RenewFictitiousNameAmendmentDetailsStep'
        );
        String amendmentRequestType = (String) newFictitiousNameStepInfo.get(
            'AmendmentRequestType'
        );
        try {
            Map<String, String> keyMappingPAR = new Map<String, String>();
            keyMappingPAR.put(
                'AmendmentRequestType',
                'Amendment_Request_Type__c'
            );
            keyMappingPAR.put('OldFictitiousName', 'Other_Names__c');
            // keyMappingPAR.put(
            //     'NewEffectiveDateOfNameChange',
            //     'Effective_Date__c'
            // );
            if (amendmentRequestType == AMENDMENT_TYPE_NEW) {
                keyMappingPAR.put(
                    'NewFictitiousName',
                    'Doing_Business_As_DBA_or_Trade_Name__c'
                );
            }
            if (
                amendmentRequestType == AMENDMENT_TYPE_CANCEL ||
                amendmentRequestType == AMENDMENT_TYPE_RENEW
            ) {
                keyMappingPAR.put(
                    'OldFictitiousName',
                    'Doing_Business_As_DBA_or_Trade_Name__c'
                );
            }
            PreliminaryApplicationRef amendPARDetailsRec = (PreliminaryApplicationRef) LPI_VlocityUtility.createSObject(
                newFictitiousNameStepInfo,
                keyMappingPAR,
                'PreliminaryApplicationRef'
            );
            amendPARDetailsRec.Id = (Id) inputMap.get('parId');
            if ((Id) inputMap.get('parId') != null) {
                LPI_DML.doUpdate(amendPARDetailsRec);
            }
        } catch (Exception exp) {
            LPI_ExceptionManager.logException(
                'LPI_FacilityOrDBANameChangeController',
                'RSBSaveNewFictitiousNameName',
                exp
            );
        }
    }
    /**
    * @author                      : Neeraj Avadhanam
    * @since                       : 06 Dec, 2022
    * @description                 : This method is Used to fetch the Old and New Business Name in
     								 Amendment Flow Review and Summary
    * @return                      : `void`
    * @last modified by            : MTX Group Inc
    * @last modified date          : 02 Feb, 2023
    * @last modified details       : Optimised Conditions
    */
    public static void RSBGetNewAndFormerBusinessNameOrFictitiousName(
        Map<String, Object> inputMap,
        Map<String, Object> outMap
    ) {
        try {
            List<PreliminaryApplicationRef> parList = new List<PreliminaryApplicationRef>();

            if (String.isNotBlank((String) inputMap.get('parId'))) {
                String fieldsToQueryPAR =
                    'Id,Business_Name__c,Business_License__c,' +
                    'Amendment_Request_Type__c,Doing_Business_As_DBA_or_Trade_Name__c, Other_Names__c';
                String whereClause =
                    'Id = \'' +
                    String.escapeSingleQuotes((Id) inputMap.get('parId')) +
                    '\'';
                parList = LPI_PreliminaryApplicationRefDAO.getPreliminaryApplicationRefByDymanicQuery(
                    fieldsToQueryPAR,
                    whereClause,
                    null,
                    null,
                    null
                );
            }
            System.debug('>>>>>-----'+parList);
            System.debug('>>>>>-----'+parList[0].Business_License__c);
            String accountId = null;

            if (!parList.isEmpty()) {
                if (parList[0].Business_Name__c != null) {
                    outMap.put('NewBusinessName', parList[0].Business_Name__c);
                }
                if (parList[0].Other_Names__c != null) {
                    outMap.put(
                        'FormerBusinessOrFictitiousNameForReview',
                        parList[0].Other_Names__c
                    );
                }
                if (parList[0].Doing_Business_As_DBA_or_Trade_Name__c != null) {
                    outMap.put(
                        'NewFictitiousName',
                        parList[0].Doing_Business_As_DBA_or_Trade_Name__c
                    );
                }
                // if (parList[0].Effective_Date__c != null) {
                //     outMap.put(
                //         'NewEffectiveDateOfNameChange',
                //         parList[0].Effective_Date__c
                //     );
                // }
                if (parList[0].Amendment_Request_Type__c != null) {
                    outMap.put(
                        'AmendmentRequestType',
                        parList[0].Amendment_Request_Type__c
                    );
                    outMap.put(
                        'AmendmentRequestTypeText',
                        parList[0].Amendment_Request_Type__c
                    );
                }
            }
            LPI_BusinessLicenseDAO.LPI_BusinessLicenseWithoutSharingDAO withoutShare = new LPI_BusinessLicenseDAO.LPI_BusinessLicenseWithoutSharingDAO();
            String fieldsToQueryBL =
                'Id,Business_Name__c,Effective_Date__c,Doing_Business_As_DBA_or_Trade_Name__c,' +
                'RegulatoryAuthorizationType.Name,AccountId, RegulatoryAuthorizationType.IssuingDepartment.Name';
            String whereClauseForBL =
                'Id = \'' +
                String.escapeSingleQuotes(parList[0].Business_License__c) +
                '\'';
            for (
                BusinessLicense bl : withoutShare.getBusinessLicenseByDymanicQuery(
                    fieldsToQueryBL,
                    whereClauseForBL,
                    null, 
                    null, 
                    null
                )
            ) {
                if (bl.AccountId != null) {
                    accountId = bl.AccountId;
                }

                if (bl.Business_Name__c != null) {
                    outMap.put('FormerBusinessName', bl.Business_Name__c);
                }
                if (bl.Doing_Business_As_DBA_or_Trade_Name__c != null) {
                    outMap.put(
                        'OldFictitiousName',
                        bl.Doing_Business_As_DBA_or_Trade_Name__c
                    );
                }
                if (
                    bl.Doing_Business_As_DBA_or_Trade_Name__c == null 
                    // &&
                    // bl.RegulatoryAuthorizationType.Name ==
                    // REG_AUTH_TYPE_RS_PARTNERSHIP
                ) {
                    outMap.put('hideDocumentsSection', true);
                } else {
                    outMap.put('hideDocumentsSection', false);
                }
                outMap.put(
                    'regAuthTypeName',
                    bl.RegulatoryAuthorizationType.Name
                );
                outMap.put(
                    'boardName',
                    bl.RegulatoryAuthorizationType.IssuingDepartment.Name
                );
            }
            System.debug('>>>>>-----'+outMap);
            String acrQueryFields = 'Id,Related_From__c,Related_To__c,Roles__c,Related_To__r.Name';
            String acrWhereClause =
                'Related_From__c = \'' +
                String.escapeSingleQuotes(accountId) +
                '\' AND ' +
                'Roles__c= \'' +
                LPI_LiteralConstant.ROLE_DESIGNATED_INCHARGE +
                '\'';
            LPI_BusinessRelationshipDAO.LPI_BusinessRelationshipsWithoutSharingDAO withoutSharingQuery = new LPI_BusinessRelationshipDAO.LPI_BusinessRelationshipsWithoutSharingDAO();
            List<Business_Relationships__c> listOfACR = withoutSharingQuery.getBusinessRelationshipsByDymanicQuery(
                acrQueryFields,
                acrWhereClause,
                '1',
                null,
                null
            );
            if (!listOfACR.isEmpty()) {
                outMap.put(
                    'DesignatedIncharge',
                    listOfACR[0].Related_To__r.Name
                );
            }
        } catch (Exception exp) {
            LPI_ExceptionManager.logException(
                'LPI_FacilityOrDBANameChangeController',
                'RSBGetNewAndFormerBusinessNameOrFictitiousName',
                exp
            );
        }
    }
}