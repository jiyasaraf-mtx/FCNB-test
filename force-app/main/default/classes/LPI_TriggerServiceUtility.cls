/**
 * @description       : 
 * @author            : MTX Group Product Team
 * @group             : 
 * @last modified on  : 08-02-2024
 * @last modified by  : Uzma Md
**/
public with sharing class LPI_TriggerServiceUtility {

    private final static string LICENSEISSUED_STATUS = 'License Issued';
    public static final String DO_NOT_PRINT = 'Do not Print';
    private static final String AMENDMENT_SUBTYPE_CHANGE_OF_RESIDENCE_ADDRESS = 'Change of Residence Address';
    private static final String AMENDMENT_SUBTYPE_CHANGE_OF_MAILING_ADDRESS = 'Change of Mailing Address';
    private static final String AMENDMENT_SUBTYPE_ADDRESS = 'Change of Residence and/or Mailing Address';
    private static final String INDIVIDUAL_APPLICATION = 'IndividualApplication';
    private static final String AMENDMENT_SUBTYPE_CHANGE_OF_NAME = 'Change of Name';
    private static final String COSBAR_APPRENTICE_SUPERVISOR_RAT = 'COSBAR Apprentice Supervisor';
	private final static String  THIRD_PARTY_LOGISTICS_PROVIDER = 'Third-Party Logistics Provider';
    private static final String  INT_PHARMACIST_LICENSE_UNIQUE_KEY = 'forInternPharmacistBusinessLicense';
	private static final String PHARMACY_TECHNICIAN_LICENSE_UNIQUE_KEY = 'forPharmacyTechnicianBusinessLicense';
	private static final String PHARMACY_LICENSE_UNIQUE_KEY = 'forPharmacyBusinessLicense';
	private static final String DRUG_DISTRIBUTOR_LICENSE_UNIQUE_KEY = 'forDrugDistributorBusinessLicense';
	private static final String DRUG_OUTSOURCER_LICENSE_UNIQUE_KEY = 'forDrugOutsourcerBusinessLicense';
	private static final String THIRD_PARTY_LOGISTICS_PROVIDER_LICENSE_UNIQUE_KEY = 'forThirdPartyLogisticsProviderBusinessLicense';
    public static final String LPI_ALL = 'All';
    public static final String NUR_LICENSE_ISSUED_UNIQUE_KEY = 'ForNursingLicenseIssued';
    public static final String METADATA_BUSINESS_LICENSE_ISSUED = 'Business_License_Issued';
    public static final String SURRENDERED = 'Surrendered';
    public static final String CONTROLLED_SUBSTANCE_RX_AUTHORITY_TITLE = 'Controlled Substance Rx Authority';
    public static final String LICENSE_INTERPRETER = 'Interpreter';
    private static final String IA_SOBJECT = 'IndividualApplication';
    private static final String BLA_SOBJECT = 'BusinessLicenseApplication';
    private static final String REINSTATEMENT_BY_EXAM = 'Reinstatement by Exam';
    public static final Set<String> COSBAR_APPRENTICE_SUPERVISOR_EMAIL_SET = new Set<String>{
        'CosBarApprenticeSupervisorEmailNoti',
        'CosBarApprenticeRejectedEmailNoti',
        'CosBarAppSupervisorRejectedEmailNoti',
        'Business_License_Issued',
        'Business_License_Approval',
        'Business_License_Rejected',
        'Notification_of_Hair_Braiding_applicatio',
        'CosBarFieldTripRejectedEmailNotifi'
    };
    public static final Set<String> REINSTATEMENT_TYPE_SET = new Set<String>{
        'Reinstatement',
        'Re-licensure',
        'Re-authorization'
    };
   public static final Set<String> IA_EMAIL_APPROVAL_EMAIL_SET = new Set<String>{'IA_Approved_Email_for_Healing_Arts'};
    public static final String HEALING_ARTS_IA_APPROVAL_EMAIL = 'IA_Approved_Email_for_Healing_Arts';
    public static final String BUSINESS_LICENSE_APPROVED_EMAIL = 'Business_License_Approval';
    public static final String BUSINESS_LICENSE_ISSUED = 'Business_License_Issued';
	public static final String BUSINESS_LICENSE_REJECTED_EMAIL = 'Business_License_Rejected';
	public static final String DEFICIENCY_NOTIFICATION_EMAIL = 'Deficiency_Notification_Email_Offline';
	
	

    public static final String APPLICATION_SUBMISSION_EMAIL = 'Application_Submission_Email';

    
    private static final String COSBAR_APPRENTICE_APPROVED_SUPERVISOR_EMAIL = 'CosBarApprenticeSupervisorEmailNoti';
     private static final String STATUS_MISSING = 'Missing';
    public final static string IA_SOBJECT_API = 'IndividualApplication';
    public final static string BLA_SOBJECT_API = 'BusinessLicenseApplication';
    public static final Set<String> PRIMARY_BRANCH_AMENDMENT_SET = new Set<String>{
        'Primary',
        'Branch'
    };
	public static final string EMBALMER_AND_FD_BOARD = 'Embalmers & Funeral Directors';
	private final static String APELSPA_BOARD_NAME = 'Architects, Engineers, Land Surveryors, and Landscape Architects';
	public static final Set<String> APPLICATION_TYPE_SET = new Set<String>{
		'Renewal',
		'Reinstatement',
		'Amendment',
        'Re-licensure',
        'Re-authorization'
	};

    public static final Set<String> APPLICATION_SUBMISSION_EMAIL_SET = new Set<String>{'Application_Submission_Email'};


	public static final String APPLICATION_SUBMISSION_BELL_NOTIFICATION = 'Bell_notification_for_Submission';
	public static final String DEFICIENCY_RESPONSE_BELL_NOTIFICATION = 'Bell_notice_for_Deficiency_response';

    /**
    * @description 
    * @author MTX Group Product Team | 05-06-2024 
    * @param setOfDeveloperName 
    * @return Map<String, Notification_Message__mdt> 
    **/
    public static Map<String, Notification_Message__mdt> getMapOfNotificationByItsName(
        Set<String> setOfDeveloperName
    ) {
        Map<String, Notification_Message__mdt> mapOfNotificationByItsName = new Map<String, Notification_Message__mdt>();
        for (
            Notification_Message__mdt notiRec : LPI_CustomMetadataTypeDAO.getAllNotificationByDeveloperNames(
                setOfDeveloperName
            )
        ) {
            mapOfNotificationByItsName.put(notiRec.DeveloperName, notiRec);
        }
        return mapOfNotificationByItsName;
    }

   
    
    /**
     * @author                      : MTX Group Product Team
     * @since                       : 3rd May 2023
     * @description                 : This method is contains the logic to add payment details on IA and BLA
     * @param parWithAppIdMap       : Takes par id with application id
     * @return                      : `void`
     */
    public static void createRegulatoryTrxnFeeAndFeeItemRec(
        Map<Id, Id> parWithAppIdMap
    ) {
        try{     
        if (!parWithAppIdMap.keySet().isEmpty()) {
            List<RegulatoryTrxnFee> rtfRecs = new List<RegulatoryTrxnFee>();
            List<RegulatoryTrxnFeeItem> trxnFeeItemList = new List<RegulatoryTrxnFeeItem>();
            Map<String, List<Temp_Fee_Item__c>> uniqueIdWithTFI = new Map<String, List<Temp_Fee_Item__c>>();
            String tempFeeQueryFields = 'Id,FeeAmount__c, PreliminaryApplicationReference__c,PreliminaryApplicationReference__r.Regulatory_Authorization_Type__r.IssuingDepartment.Name,'+
            '(Select Id, Name, Temp_Fee__c, FeeAmount__c,Object_Code__c,Actual_Asked_Amount__c FROM Temp_Fee_Items__r),PreliminaryApplicationReference__r.BusinessAccountNameId, Memo__c , Deposit_Method__c ,Fee_State__c ,Payment_Method__c, Status__c,Transaction_ID__c, Paid_by_someone_other_than_applicant__c,Payer_Full_Name_Company_Name__c, Payer_Phone_Number__c, Transaction_Date__c,Transaction_Fee_Amount__c, Amount_Tendered__c, Billing_Information__c,Exempt__c,Exemption_Reason__c';
            String tempFeeWhereClauseFields =
                '(Status__c = \'Paid\' OR Status__c = \'Payment Pending\' OR PreliminaryApplicationReference__r.Is_Submitted_By_Internal_User__c = true)'+
                ' AND PreliminaryApplicationReference__c IN ' +
                LPI_ServiceUtility.getStringValuesBySet(
                    parWithAppIdMap.keySet()
                );

            for (
                Temp_Fee__c tempFeeData : LPI_TempFeeDAO.getTempFeeListByDynamicQuery(
                    tempFeeQueryFields,
                    tempFeeWhereClauseFields,
                    null,
                    null,
                    null
                )
            ) {
                
                RegulatoryTrxnFee regTrxn = new RegulatoryTrxnFee();
                regTrxn.ParentRecordId = parWithAppIdMap.get(
                    tempFeeData.PreliminaryApplicationReference__c
                );
                // skipPayment / Pay Later creates Payment Pending Temp Fee → unpaid RTF
                regTrxn.Status = (tempFeeData.Status__c == 'Paid') ? 'Paid' : 'Due';
                regTrxn.Status__c = tempFeeData.Status__c;
                regTrxn.AccountId = tempFeeData.PreliminaryApplicationReference__r.BusinessAccountNameId;
                regTrxn.Payment_Method__c = tempFeeData.Payment_Method__c;
                regTrxn.Transaction_Date__c = tempFeeData.Transaction_Date__c;
                regTrxn.Transaction_Fee_Amount__c = tempFeeData.Transaction_Fee_Amount__c;
                regTrxn.Payer_Full_Name__c = tempFeeData.Payer_Full_Name_Company_Name__c;
                regTrxn.Payer_Phone_Number__c = tempFeeData.Payer_Phone_Number__c;
                regTrxn.Amount_Tendered__c = tempFeeData.Amount_Tendered__c;
                regTrxn.Paid_by_someone_other_than_applicant__c = tempFeeData.Paid_by_someone_other_than_applicant__c;
                regTrxn.Transaction_ID__c = tempFeeData.Transaction_ID__c;
                regTrxn.Billing_Information__c = tempFeeData.Billing_Information__c;
                regTrxn.Comments = tempFeeData.Memo__c;
                regTrxn.Deposit_Method__c = tempFeeData.Deposit_Method__c;
                regTrxn.Board_Name__c = tempFeeData.PreliminaryApplicationReference__r.Regulatory_Authorization_Type__r.IssuingDepartment.Name;
                regTrxn.Fee_State__c = tempFeeData.Fee_State__c;
                regTrxn.Exempt__c = tempFeeData.Exempt__c;
                regTrxn.Exemption_Reason__c = tempFeeData.Exemption_Reason__c;
                rtfRecs.add(regTrxn);
                uniqueIdWithTFI.put(
                    tempFeeData.Transaction_ID__c,
                    tempFeeData.Temp_Fee_Items__r
                );
            }
            if (!rtfRecs.isEmpty()) {
                rtfRecs = (List<RegulatoryTrxnFee>) LPI_WithoutSharingUtility.insertSObjectRecord(
                        rtfRecs
                    )
                    .getRecords();
                List<SObject> appsPaymentPending = new List<SObject>();
                for (RegulatoryTrxnFee rtfData : rtfRecs) {
                    if (rtfData.Status__c == 'Payment Pending' || rtfData.Status == 'Due' || rtfData.Status == 'DUE') {
                        Id parentId = rtfData.ParentRecordId;
                        if (parentId != null) {
                            if (parentId.getSObjectType() == IndividualApplication.SObjectType) {
                                appsPaymentPending.add(
                                    new IndividualApplication(Id = parentId, Payment_Pending__c = true)
                                );
                            } else if (parentId.getSObjectType() == BusinessLicenseApplication.SObjectType) {
                                appsPaymentPending.add(
                                    new BusinessLicenseApplication(Id = parentId, Payment_Pending__c = true)
                                );
                            }
                        }
                    }
                    if (
                        uniqueIdWithTFI.containsKey(rtfData.Transaction_ID__c)
                    ) {
                        for (
                            Temp_Fee_Item__c tfiData : uniqueIdWithTFI.get(
                                rtfData.Transaction_ID__c
                            )
                        ) {
                            RegulatoryTrxnFeeItem feeItem = new RegulatoryTrxnFeeItem(
                                Name = tfiData.Name,
                                FeeAmount = tfiData.FeeAmount__c,
                                RegulatoryTrxnFeeId = rtfData.Id,
                                Object_Code__c = tfiData.Object_Code__c,
                                Actual_Asked_Amount__c = tfiData.Actual_Asked_Amount__c
                            );
                            trxnFeeItemList.add(feeItem);
                        }
                    }
                }
                if (!trxnFeeItemList.isEmpty()) {
                    LPI_WithoutSharingUtility.insertSObjectRecord(
                        trxnFeeItemList
                    );
                }
                if (!appsPaymentPending.isEmpty()) {
                    LPI_WithoutSharingUtility.updateSObjectList(appsPaymentPending);
                }
            }
        }
    }
    catch(Exception e){
        LPI_ExceptionManager.logException('LPI_TriggerServiceUtility', 'createRegulatoryTrxnFeeAndFeeItemRec', e);
    }
    }

    public static void createDueDiligenceRecord(List<SObject> recodsList) {
        Map<Id, Id> mapOfWorkFlowToAppId = new Map<Id, Id>();
        Map<Id, Id> mapWorkFlowLineItemToAppId = new Map<Id, Id>();
        List<Due_Diligence__c> lstDueDiligenceToCreate = new List<Due_Diligence__c>();
        String sObjName = '';

        for (SObject record : recodsList) {
            mapOfWorkFlowToAppId.put(
                (Id) record.get('Workflow__c'),
                (Id) record.get('Id')
            );
        }
        if (Schema.sObjectType.Workflow_Line_Item__c.isAccessible()) {
            if (!mapOfWorkFlowToAppId.isEmpty()) {
                String ltFields = 'Id, Workflow__c, Associated_Status__c, Sequence__c';
                String ltWhereClause =
                    'Workflow__c IN ' +
                    LPI_ServiceUtility.getStringValuesBySet(
                        mapOfWorkFlowToAppId.keySet()
                    );
                List<Workflow_Line_Item__c> lineItemList = LPI_WorkflowLineItemDAO.getWorkflowLineItemByDymanicQuery(
                    ltFields,
                    ltWhereClause,
                    null,
                    null,
                    null,
                    null
                );
                for (Workflow_Line_Item__c wlI : lineItemList) {
                    mapWorkFlowLineItemToAppId.put(
                        wlI.Id,
                        mapOfWorkFlowToAppId.get(wlI.Workflow__c)
                    );
                }
                if (!mapWorkFlowLineItemToAppId.isEmpty()) {
                    String ddFields = 'Id, Ad_hoc_Checklist_Item__c, Enable_Not_Applicable__c, Video_Link__c, Help_Text__c, Unique_API_Name__c, Checklist_Name__c, Automated__c, Sequence__c, Workflow_Line_Item__c, Workflow_Line_Item__r.Sequence__c, Workflow_Line_Item__r.Associated_Status__c, Workflow_Line_Item__r.Next_Application_Status__c,Is_Rejection_Reason__c';
                    String ddWhereClause =
                        'Workflow_Line_Item__c IN ' +
                        LPI_ServiceUtility.getStringValuesBySet(
                            mapWorkFlowLineItemToAppId.keySet()
                        );
                    List<Due_Diligence_Line_Item__c> ddLineItemList = LPI_DueDiligenceLineItemDAO.getDueDiligenceLineItemByDymanicQuery(
                        ddFields,
                        ddWhereClause,
                        null,
                        'Sequence__c',
                        null,
                        null
                    );
                    for (Due_Diligence_Line_Item__c ddlI : ddLineItemList) {
                        Due_Diligence__c ddToCreate = getMappedDueDiligenceFromDDLineItem( 
                            ddlI
                        );
                        sObjName = mapWorkFlowLineItemToAppId.get(
                                ddlI.Workflow_Line_Item__c
                            )
                            .getSObjectType()
                            .getDescribe()
                            .getName();
                        if (sObjName == LPI_LiteralConstant.IA_SOBJECT_API) {
                            ddToCreate.Individual_Application__c = mapWorkFlowLineItemToAppId.get(
                                ddlI.Workflow_Line_Item__c
                            );
                        } else if (
                            sObjName == LPI_LiteralConstant.BLA_SOBJECT_API
                        ) {
                            ddToCreate.Application__c = mapWorkFlowLineItemToAppId.get(
                                ddlI.Workflow_Line_Item__c
                            );
                        }
                        lstDueDiligenceToCreate.add(ddToCreate);
                    }
                }
            }
        }
        if (!lstDueDiligenceToCreate.isEmpty()) {
            LPI_WithoutSharingUtility.insertSObjectRecord(
                lstDueDiligenceToCreate
            );
        }
    }
    /**
     * @author                      : MTX Group Product Team
     * @since                       :
     * @description                 : This method is used to create AuthApplicationPlace record on IA and BLA
     */
    public static void createAuthApplicationPlace(Map<Id, Id> mapPARIdToIAId) {
        List<AuthApplicationPlace> lstAuthApplicationPlaceToInsert = new List<AuthApplicationPlace>();
        for (
            Temp_AuthApplicationPlace__c tmpAuthPlaceRec : new LPI_TempAuthApplicationPlaceDAO.LPI_TempAuthApplicationPlaceWithoutSharingDAO()
                .getTempAuthAppPlacesByPARId(mapPARIdToIAId.keySet())
        ) {
            AuthApplicationPlace newAuthAppPlaceRec = new AuthApplicationPlace();
            newAuthAppPlaceRec.RgltyAuthApplicationId = mapPARIdToIAId.get(
                tmpAuthPlaceRec.Preliminary_Application_Reference__c
            );
            newAuthAppPlaceRec.PlaceId = tmpAuthPlaceRec.Location__c;
            lstAuthApplicationPlaceToInsert.add(newAuthAppPlaceRec);
        }
        if (!lstAuthApplicationPlaceToInsert.isEmpty()) {
            LPI_WithoutSharingUtility.insertSObjectRecord(
                lstAuthApplicationPlaceToInsert
            );
        }
    }

    /**
     * @author                      : MTX Group Product Team
     * @since                       :
     * @description                 : This method is used to create Application_Content__c record on IA and BLA
     */
    public static void createApplicationContentRecord(
        Map<Id, Id> mapPARIdToIAId
    ) {
        List<Application_Content__c> appConDataToBeUpdated = new List<Application_Content__c>();
        String sObjName = '';
        for (
            Application_Content__c appConData : LPI_ApplicationContentDAO.getApplicationContentByPARId(
                mapPARIdToIAId.keySet()
            )
        ) {
            sObjName = mapPARIdToIAId.get(
                    appConData.Preliminary_Application_Reference__c
                )
                .getSObjectType()
                .getDescribe()
                .getName();
            if (sObjName == LPI_LiteralConstant.IA_SOBJECT_API) {
                appConData.Individual_Application__c = mapPARIdToIAId.get(
                    appConData.Preliminary_Application_Reference__c
                );
            } else if (sObjName == LPI_LiteralConstant.BLA_SOBJECT_API) {
                appConData.Business_License_Application__c = mapPARIdToIAId.get(
                    appConData.Preliminary_Application_Reference__c
                );
            }
            appConDataToBeUpdated.add(appConData);
        }
        if (!appConDataToBeUpdated.isEmpty()) {
            LPI_WithoutSharingUtility.updateSObjectRecord(
                appConDataToBeUpdated
            );
        }
    }

    /**
     * @author                      : MTX Group Product Team
     * @since                       :
     * @description                 : This method is used to create Person Examination record on IA
     */
    public static void createPersonExaminationRecord(
        Map<Id, Id> mapPARIdToIAId
    ) {
        List<PersonExamination> PersonExaminationList = new List<PersonExamination>();
        String sObjName = '';
        for (
            PersonExamination PerExam : LPI_PersonExaminationDAO.getPersonExaminationByParId(
                mapPARIdToIAId.keySet()
            )
        ) {
            sObjName = mapPARIdToIAId.get(
                    PerExam.Preliminary_Application_Reference__c
                )
                .getSObjectType()
                .getDescribe()
                .getName();
            if (sObjName == LPI_LiteralConstant.IA_SOBJECT_API) {
                PerExam.Individual_Application__c = mapPARIdToIAId.get(
                    PerExam.Preliminary_Application_Reference__c
                );
            }
            PersonExaminationList.add(PerExam);
        }
        if (!PersonExaminationList.isEmpty()) {
            LPI_WithoutSharingUtility.updateSObjectRecord(
                PersonExaminationList
            );
        }
    }

    /**
    * @description 
    * @author MTX Group Product Team | 05-06-2024 
    * @param ddLineItem 
    * @return Due_Diligence__c 
    **/
    public static Due_Diligence__c getMappedDueDiligenceFromDDLineItem(
        Due_Diligence_Line_Item__c ddLineItem
    ) {
        Due_Diligence__c ddToCreate = new Due_Diligence__c();
        ddToCreate.Ad_hoc_Checklist_Item__c = ddLineItem.Ad_hoc_Checklist_Item__c;
        ddToCreate.Automated__c = ddLineItem.Automated__c;
        ddToCreate.Checklist_Name__c = ddLineItem.Checklist_Name__c;
        ddToCreate.Enable_Not_Applicable__c = ddLineItem.Enable_Not_Applicable__c;
        ddToCreate.Help_Text__c = ddLineItem.Help_Text__c;
        ddToCreate.Responsible_Party__c = null;
        ddToCreate.Sequence__c = ddLineItem.Sequence__c;
        ddToCreate.Unique_API_Name__c = ddLineItem.Unique_API_Name__c;
        ddToCreate.Video_Link__c = ddLineItem.Video_Link__c;
        ddToCreate.Due_Diligence_Line_Item__c = ddLineItem.Id;
        ddToCreate.Application_Status__c = ddLineItem.Workflow_Line_Item__r.Associated_Status__c;
        ddToCreate.Next_Application_Status__c = ddLineItem.Workflow_Line_Item__r.Next_Application_Status__c;
		ddToCreate.Is_Rejection_Reason__c = ddLineItem.Is_Rejection_Reason__c;
		if(ddLineItem.Is_Rejection_Reason__c){
			ddToCreate.Status__c = LPI_LiteralConstant.Inspection_Status_COMPLETED;
		}
		else{
        	ddToCreate.Status__c = LPI_LiteralConstant.DD_NOT_STARTED_STATUS;
		}
        return ddToCreate;
    }

    /**
    * @description 
    * @author MTX Group Product Team | 05-06-2024 
    * @param applicationList 
    **/
    public static void updateExpiryDateOnBL(List<SObject> applicationList) {
        Map<Id, BusinessLicense> businessLicenseMap = new Map<Id, BusinessLicense>();
        Map<Id, RegulatoryAuthorizationType> mapOfRegAuth = new Map<Id, RegulatoryAuthorizationType>();
        Map<Id, SObject> mapOfAppIds = new Map<Id, SObject>();
        Set<Id> rugAuthSet = new Set<Id>();
        List<BusinessLicense> blRecordList = new List<BusinessLicense>();
        Set<String> amendTypeSet = new Set<String>{
            LPI_LiteralConstant.BL_STATUS_RETIRED,
            SURRENDERED
        };
        String objectName = String.valueOf(
            ((Id) applicationList[0].get('Id')).getSObjectType()
        );
        for (SObject appRec : applicationList) {
            String appType = (String) appRec.get('ApplicationType');
            if (
                appType.equalsIgnoreCase(
                    LPI_LiteralConstant.PAR_SOBJECT_TYPE_INACTIVATION
                ) ||
                appType.equalsIgnoreCase(
                    LPI_LiteralConstant.PAR_SOBJECT_TYPE_REACTIVATION
                ) ||
                appType.equalsIgnoreCase(
                    LPI_LiteralConstant.PAR_SOBJECT_TYPE_REINSTATEMENT
                ) ||
                appType.equalsIgnoreCase(
                    LPI_LiteralConstant.IA_RENEWAL_APPLICATIONTYPE
                ) ||
                appType.equalsIgnoreCase(
                    LPI_LiteralConstant.ANNUAL_REPORT_SURVEY
                ) ||
                appType.equalsIgnoreCase(REINSTATEMENT_BY_EXAM) ||
                (objectName.equalsIgnoreCase(IA_SOBJECT) &&
                (appType.equalsIgnoreCase(
                    LPI_LiteralConstant.BLA_NEW_APPLICATIONTYPE
                ) &&
                ((String) appRec.get('License_Type_Name__c') ==
                LICENSE_INTERPRETER)))
            ) {
                mapOfAppIds.put((Id) appRec.get('Id'), appRec);
                rugAuthSet.add((Id) appRec.get('LicenseTypeId'));
                businessLicenseMap.put(
                    (Id) appRec.get('LicensePermitNameId'),
                    null
                );
            }
        }
        if (!businessLicenseMap.isEmpty()) {
            for (
                BusinessLicense bl : LPI_BusinessLicenseDAO.fetchBusinessLicenseRecords(
                    'Id, Status, Reinstatement_Count__c, PeriodEnd',
                    'Id IN ' +
                    LPI_ServiceUtility.getStringValuesBySet(
                        businessLicenseMap.keySet()
                    )
                )
            ) {
                businessLicenseMap.put(bl.Id, bl);
            }
            for (
                RegulatoryAuthorizationType rat : LPI_RegulatoryAuthorizationTypeDAO.getRATTypeByID(
                    rugAuthSet
                )
            ) {
                mapOfRegAuth.put(rat.Id, rat);
            }
            Map<String, String> blNameWithIAId = new Map<String, String>();
            for (Id appId : mapOfAppIds.keyset()) {
                BusinessLicense blRec = new BusinessLicense();
                blRec.Id = (Id) mapOfAppIds.get(appId)
                    .get('LicensePermitNameId');
                String amendType = (String) mapOfAppIds.get(appId)
                    .get('Amendment_Type__c');
                String type = (String) mapOfAppIds.get(appId)
                    .get('ApplicationType');
                    if (
                    REINSTATEMENT_TYPE_SET.contains((String) mapOfAppIds.get(appId).get('ApplicationType'))
                ) {
                    blRec.Reinstatement_Count__c = (businessLicenseMap.get(
                                blRec.Id
                            )
                            .Reinstatement_Count__c == null)
                        ? 1
                        : businessLicenseMap.get(blRec.Id)
                              .Reinstatement_Count__c + 1;
                }
                blRec.Consent_for_Primary_Contact_Address__c = (Boolean) mapOfAppIds.get(
                        appId
                    )
                    .get('Consent_for_Primary_Contact_Address__c');
                if (
                    !(type.equalsIgnoreCase(
                        LPI_LiteralConstant.IA_RENEWAL_APPLICATIONTYPE
                    ) && amendTypeSet.contains(amendType))
                ) { 
                    blRec.PeriodEnd = validateAndGetExpiryDate(
                        mapOfAppIds.get(appId),
                        mapOfRegAuth.get(
                            (Id) mapOfAppIds.get(appId).get('LicenseTypeId')
                        ),
                        businessLicenseMap.get(blRec.Id)
                    );
                    if(
                        mapOfAppIds.get(appId).get('Board_Name__c') == APELSPA_BOARD_NAME &&
                        type.equalsIgnoreCase(LPI_LiteralConstant.IA_RENEWAL_APPLICATIONTYPE) && 
                        blRec.PeriodEnd != null
                    ){
                        DateTime expiryDate = businessLicenseMap.get(blRec.Id).PeriodEnd;
                        blRec.PeriodEnd = Datetime.newinstance(
                            expiryDate.year() + 2,
                            blRec.PeriodEnd.month(),
                            blRec.PeriodEnd.day(),
                            23,
                            59,
                            59
                        );
                    }
                }
                blRecordList.add(blRec);
            }
        }
        if (!blRecordList.isEmpty()) {
            LPI_WithoutSharingUtility.updateSObjectList(blRecordList);
        }
    }

    /**
    * @description 
    * @author MTX Group Product Team| 05-06-2024 
    * @param applicationRec 
    * @param regAuth 
    * @param blRec 
    * @return Datetime 
    **/
    public static Datetime validateAndGetExpiryDate(
        SObject applicationRec,
        RegulatoryAuthorizationType regAuth,
        BusinessLicense blRec
    ) {
        Datetime expiryDate;
        String appType = (String) applicationRec.get('ApplicationType');
        String amendType = (String) applicationRec.get('Amendment_Type__c');
        switch on appType {
            when 'Renewal', 'Reinstatement', 'Re-licensure', 'Re-authorization' {
                if (
                    (amendType.equalsIgnoreCase(
                        LPI_LiteralConstant.IA_RENEWAL_APPLICATIONTYPE
                    ) ||
                    amendType.equalsIgnoreCase(
                        LPI_LiteralConstant.IA_REINSTATEMENT_APPLICATIONTYPE
                    )) &&
                    ((String.isNotBlank(regAuth.Renewal_Expiration_Day__c) &&
                    String.isNotBlank(regAuth.Renewal_Expiration_Month__c) &&
                    String.isNotBlank(regAuth.Renewal_Expiration_Cycle__c)) ||
                    String.isNotBlank(regAuth.Renewal_Expiration_Period__c))
                ) {
                    if (
                        String.isNotBlank(
                            regAuth.Renewal_Expiration_Period__c
                        ) &&
                        regAuth.Renewal_Expiration_Period__c.contains('-Odd')
                    ) {
                        Integer endMonth = Integer.valueOf(
                            regAuth.Renewal_Expiration_Month__c.substring(0, 2)
                        );
                        Integer numYear = Integer.valueOf(
                            regAuth.Renewal_Expiration_Period__c.split('-')
                                .get(0)
                        );
                        expiryDate = Datetime.newinstance(
                            Date.today().year(),
                            endMonth,
                            Integer.valueOf(regAuth.Renewal_Expiration_Day__c),
                            23,
                			59,
                			59
                        );
                        expiryDate = expiryDate.addYears(
                            Math.mod(Date.today().year(), 2) == 1
                                ? 2 * numYear
                                : 2 * numYear - 1
                        );
                    } else {
                        RegulatoryAuthorizationType tempRegAuth = LPI_ServiceUtility.getRegAuthTypeToCalculateExpiryDate(
                            regAuth.Renewal_Expiry_Rule_Type__c,
                            regAuth.Renewal_Expiration_Day__c,
                            regAuth.Renewal_Expiration_Month__c,
                            regAuth.Renewal_Expiration_Cycle__c,
                            regAuth.Renewal_Expiration_Period__c,
                            (Integer) regAuth.Renewal_Window_Period_Before_Expiry__c,
                            (Integer) regAuth.Open_for_Renewal__c
                        );
                        expiryDate = LPI_ServiceUtility.getExpirationDate(
                            tempRegAuth
                        );
                    }
                } else if (
                    amendType.equalsIgnoreCase(
                        LPI_LiteralConstant.BLA_AMENDMENT_TYPE_COURSE_RENEWAL
                    ) &&
                    String.isNotBlank(regAuth.Course_Expiration_Day__c) &&
                    String.isNotBlank(regAuth.Course_Expiration_Month__c) &&
                    String.isNotBlank(regAuth.Course_Expiration_Cycle__c)
                ) {
                    RegulatoryAuthorizationType tempRegAuth = LPI_ServiceUtility.getRegAuthTypeToCalculateExpiryDate(
                        LPI_LiteralConstant.EXPIRY_RULE_TYPE_DAY_MONTH_CYCLE,
                        regAuth.Course_Expiration_Day__c,
                        regAuth.Course_Expiration_Month__c,
                        regAuth.Course_Expiration_Cycle__c,
                        regAuth.Course_Expiration_Period__c,
                        null,
                        null
                    );
                    expiryDate = LPI_ServiceUtility.getExpirationDate(
                        tempRegAuth
                    );
                } else {
                    expiryDate = LPI_ServiceUtility.getExpirationDate(
                        regAuth
                    );
                }
            }
            when 'Apply for Course Approval' {
                if (
                    String.isNotBlank(regAuth.Course_Expiration_Day__c) &&
                    String.isNotBlank(regAuth.Course_Expiration_Month__c) &&
                    String.isNotBlank(regAuth.Course_Expiration_Cycle__c)
                ) {
                    RegulatoryAuthorizationType tempRegAuth = LPI_ServiceUtility.getRegAuthTypeToCalculateExpiryDate(
                        LPI_LiteralConstant.EXPIRY_RULE_TYPE_DAY_MONTH_CYCLE,
                        regAuth.Course_Expiration_Day__c,
                        regAuth.Course_Expiration_Month__c,
                        regAuth.Course_Expiration_Cycle__c,
                        regAuth.Course_Expiration_Period__c,
                        null,
                        null
                    );
                    expiryDate = LPI_ServiceUtility.getExpirationDate(
                        tempRegAuth
                    );
                } else {
                    expiryDate = LPI_ServiceUtility.getExpirationDate(
                        regAuth
                    );
                }
            }
            when else {
                expiryDate = LPI_ServiceUtility.getExpirationDate(regAuth);
            }
        }
        return expiryDate;
    }

    /**
    * @description 
    * @author MTX Group Product Team | 05-06-2024 
    * @param newList 
    **/
    public static void linkAuditEscrowToBl(List<SObject> newList) {
        try {
            String fieldsToQueryAuditEscrow = 'Id, Preliminary_Application_Reference__c';
            String whereClauseAuditEscrow;
            Map<String, String> parIdToBLId = new Map<String, String>();
            for (SObject application : newList) {
                if ((Id) application.get('SavedApplicationRefId') != null) {
                    
                    parIdToBLId.put(
                        (String) application.get('SavedApplicationRefId'),
                        (String) application.get('LicensePermitNameId')
                    );
                }
            }
            if (!parIdToBLId.isEmpty() && parIdToBLId.keySet() != null) {
                whereClauseAuditEscrow =
                    'Preliminary_Application_Reference__c IN ' +
                    LPI_ServiceUtility.getStringValuesByStringSet(
                        parIdToBLId.keySet()
                    );
            }
            List<Bank_Account__c> updateAuditEscrowBlList = new List<Bank_Account__c>();
            if (String.isNotBlank(whereClauseAuditEscrow)) {
                for (
                    Bank_Account__c auditAcc : LPI_BankAccountDAO.getBankAccountByDymanicQuery(
                        fieldsToQueryAuditEscrow,
                        whereClauseAuditEscrow,
                        null,
                        null,
                        null
                    )
                ) {
                    if (
                        !parIdToBLId.isEmpty() &&
                        parIdToBLId.containsKey(
                            auditAcc.Preliminary_Application_Reference__c
                        )
                    ) {
                        auditAcc.Business_License__c = parIdToBLId.get(
                            auditAcc.Preliminary_Application_Reference__c
                        );
                        updateAuditEscrowBlList.add(auditAcc);
                    }
                }
            }
            if (!updateAuditEscrowBlList.isEmpty()) {
                LPI_DML.doUpdate(updateAuditEscrowBlList);
            }
        } catch (Exception exp) {
            LPI_ExceptionManager.logException(
                'LPI_TriggerServiceUtility',
                'linkAuditEscrowToBl',
                exp
            );
        }
    }

    /**
    * @description 
    * @author MTX Group Product Team | 05-06-2024 
    * @param newList 
    **/
    public static void linkInsuranceToBl(List<SObject> newList) {
        try {
            String fieldsToQueryInsuranceRec = 'Id, Liability_Insurance__c,Policy_Number__c';
            String whereClauseInsurance;
            Map<String, String> parIdToBLId = new Map<String, String>();
            for (SObject application : newList) {
                if (
                    (Id) application.get('SavedApplicationRefId') != null &&
                    (Id) application.get('LicensePermitNameId') != null &&
                    (String) application.get('ApplicationType') ==
                    LPI_LiteralConstant.IA_NEW_APPLICATIONTYPE
                ) {
                    parIdToBLId.put(
                        (String) application.get('SavedApplicationRefId'),
                        (String) application.get('LicensePermitNameId')
                    );
                } else {
                    return;
                }
            }

            whereClauseInsurance =
                'Id IN ' +
                LPI_ServiceUtility.getStringValuesByStringSet(
                    parIdToBLId.keySet()
                ) +
                ' AND ' +
                '(Liability_Insurance__c != null OR (Policy_Number__c!=null))';

            List<Insurance__c> insertInsuranceToBlList = new List<Insurance__c>();
            if (String.isNotBlank(whereClauseInsurance)) {
                for (
                    PreliminaryApplicationRef par : LPI_PreliminaryApplicationRefDAO.getPreliminaryApplicationRefByDymanicQuery(
                        fieldsToQueryInsuranceRec,
                        whereClauseInsurance,
                        null,
                        null,
                        null
                    )
                ) {
                    if (parIdToBLId.containsKey(par.Id)) {
                        Insurance__c ins = new Insurance__c();
                        ins.Liability_Insurance__c = par.Liability_Insurance__c;
                        ins.Business_License__c = parIdToBLId.get(par.Id);
                        insertInsuranceToBlList.add(ins);
                    }
                }
            }
            if (!insertInsuranceToBlList.isEmpty()) {
                LPI_DML.doInsert(insertInsuranceToBlList);
            }
        } catch (Exception exp) {
            LPI_ExceptionManager.logException(
                'LPI_TriggerServiceUtility',
                'linkInsuranceToBl',
                exp
            );
        }
    }

    public static void linkNotesFromApplicationToLicense(List<Sobject> recordList){
		try{
			Map<Id,Id> appToWithLicenseIdMap = new Map<Id,Id>();
			for (Sobject rec : recordList) {
				if((Id) rec.get('LicensePermitNameId') != null && !appToWithLicenseIdMap.containsKey((Id) rec.get('Id'))){
					appToWithLicenseIdMap.put((Id) rec.get('Id'),(Id) rec.get('LicensePermitNameId'));
				}
			}
			if(!appToWithLicenseIdMap.isEmpty()){
				List<ContentDocumentLink> contentDocumentLinkList = new LPI_ContentDocumentLinkDAO.LPI_ContentDocumentLinkWithoutSharingDAO().getContentDocumentLinkByDymanicQuery(
                    'Id,ContentDocumentId,LinkedEntityId',
                    'LinkedEntityId IN ' + LPI_ServiceUtility.getStringValuesBySet(appToWithLicenseIdMap.keySet()) 
                    + ' AND ContentDocument.FileType = \'SNOTE\'',null,null,null);
                Map<Id,Set<Id>> linkEntitiyWithDocumentIdMap = new Map<Id,Set<Id>>();
                List<ContentDocumentLink> insertCdlRecord = new List<ContentDocumentLink>();
                if(!contentDocumentLinkList.isEmpty()){
                    for(ContentDocumentLink cdl:contentDocumentLinkList){
                        if(!linkEntitiyWithDocumentIdMap.containsKey(cdl.LinkedEntityId)){
                            linkEntitiyWithDocumentIdMap.put(cdl.LinkedEntityId,new Set<Id>());
                        }
                        linkEntitiyWithDocumentIdMap.get(cdl.LinkedEntityId).add(cdl.ContentDocumentId);
                    }
                    if(!linkEntitiyWithDocumentIdMap.isEmpty()){
                        for(Id linkedEntityId : linkEntitiyWithDocumentIdMap.keySet()){
                            if(appToWithLicenseIdMap.containsKey(linkedEntityId)){
                                for(Id noteId : linkEntitiyWithDocumentIdMap.get(linkedEntityId)){
                                    ContentDocumentLink conDocLink = new ContentDocumentLink();
                                    conDocLink.LinkedEntityId = appToWithLicenseIdMap.get(linkedEntityId);
                                    conDocLink.ContentDocumentId = noteId;
                                    insertCdlRecord.add(conDocLink);
                                }
                            }
                        }
                    }
                    if(!insertCdlRecord.isEmpty()){
                        LPI_DML.doInsert(insertCdlRecord);
                    }
                }
			}
		}
		catch(Exception e){
            LPI_ExceptionManager.logException('LPI_TriggerServiceUtility', 'linkNotesFromApplicationToLicense', e);
        }
	}

    /**
    * @description 
    * @author MTX Group Product Team | 05-06-2024 
    * @param recordsList 
    **/
    public static void updateBusinessLicenseStatusOnApproval(
        List<SObject> recordsList
    ) {
        List<BusinessLicense> blUpdateList = new List<BusinessLicense>();
        Map<String, String> nextStatusMap = LPI_ServiceUtility.getNextStatusForBL(
            recordsList
        );
        String objectName = String.valueOf(
            ((Id) recordsList[0].get('Id')).getSObjectType()
        );
        for (SObject rec : recordsList) {
            String applicationType = (String) rec.get('ApplicationType');
            String amendType = (String) rec.get('Amendment_Type__c');
            amendType = String.isNotBlank(amendType) ? amendType : '';
            Id blId;
            if(rec.get('LicensePermitNameId') == null){
                blId = (Id) rec.get('Temporary_License_Number__c');
            } else{
                blId = (Id) rec.get('LicensePermitNameId');
            }
            BusinessLicense blToUpdate = new BusinessLicense(Id = blId);
            if (
                nextStatusMap.containsKey(blId) &&
                String.isNotBlank(nextStatusMap.get(blId))
            ) {
                blToUpdate.Status = nextStatusMap.get(blId);
            } else if (
                applicationType.equalsIgnoreCase(
                    LPI_LiteralConstant.PAR_SOBJECT_TYPE_INACTIVATION
                )
            ) {
                checkAmendmentTypeAndPopulateStatus(amendType, blToUpdate);
            } else if (
                applicationType.equalsIgnoreCase(
                    LPI_LiteralConstant.PAR_SOBJECT_TYPE_REACTIVATION
                )
            ) {
                blToUpdate.Status = LPI_LiteralConstant.STATUS_ACTIVE;
            } else if (
                applicationType.equalsIgnoreCase(
                    LPI_LiteralConstant.PAR_SOBJECT_TYPE_REINSTATEMENT
                )
            ) {
                blToUpdate.Reinstatement_Date__c = Date.today();
                checkAmendmentTypeAndPopulateStatus(amendType, blToUpdate);
            } else if (
                applicationType.equalsIgnoreCase(
                    LPI_LiteralConstant.IA_RENEWAL_APPLICATIONTYPE
                )
            ) {
                blToUpdate.Renewal_date__c = Date.today();
				blToUpdate.Number_of_Renewal_Notifications_sent__c = 0;
                blToUpdate.Is_Renewal_Submitted__c = false;
                if (
                    amendType.equalsIgnoreCase(
                        LPI_LiteralConstant.BL_STATUS_RETIRED
                    )
                ) {
                   
                }
                checkAmendmentTypeAndPopulateStatus(amendType, blToUpdate);
            } else if (
                applicationType.equalsIgnoreCase(
                    LPI_LiteralConstant.BL_STATUS_RETIRED
                )
            ) {
              
                checkAmendmentTypeAndPopulateStatus(amendType, blToUpdate);
            } else if (
                applicationType.equalsIgnoreCase(
                    LPI_LiteralConstant.BLA_CHANGE_OF_OWNERSHIP
                )
            ) {
                blToUpdate.Status = LPI_LiteralConstant.BLA_CLOSED_STATUS;
            } else if (
                applicationType.equalsIgnoreCase(REINSTATEMENT_BY_EXAM)
            ) {
                checkAmendmentTypeAndPopulateStatus(amendType, blToUpdate);
            } 
          
            else if (
                objectName.equalsIgnoreCase(IA_SOBJECT) &&
                applicationType.equalsIgnoreCase(
                    LPI_LiteralConstant.BLA_NEW_APPLICATIONTYPE
                ) &&
                (rec.get('License_Type_Name__c') == LICENSE_INTERPRETER
                )
            ) {
                blToUpdate.Status = LPI_LiteralConstant.BUSINESSLICENSE_STATUS_ACTIVE;
            }
            blUpdateList.add(blToUpdate);
        }
        if (!blUpdateList.isEmpty()) {
            LPI_WithoutSharingUtility.updateSObjectList(blUpdateList);
        }
    }

    /**
    * @description 
    * @author MTX Group Product Team | 05-06-2024 
    * @param amendType 
    * @param blRecord 
    **/
    private static void checkAmendmentTypeAndPopulateStatus(
        String amendType,
        BusinessLicense blRecord
    ) {
        if (amendType == LPI_LiteralConstant.PAR_SOBJECT_TYPE_INACTIVATION) {
            blRecord.Status = LPI_LiteralConstant.STATUS_INACTIVE;
        } else if (
            amendType == LPI_LiteralConstant.PAR_SOBJECT_TYPE_ACTIVATION ||
            amendType == LPI_LiteralConstant.IA_RENEWAL_APPLICATIONTYPE ||
            amendType == REINSTATEMENT_BY_EXAM || 
            amendType == LPI_LiteralConstant.PAR_SOBJECT_TYPE_REINSTATEMENT ||
            PRIMARY_BRANCH_AMENDMENT_SET.contains(amendType)
        ) {
            blRecord.Status = LPI_LiteralConstant.STATUS_ACTIVE;
        } else if (amendType == LPI_LiteralConstant.BL_STATUS_RETIRED) {
            blRecord.Status = LPI_LiteralConstant.BL_STATUS_RETIRED;
        } else if (amendType == SURRENDERED) {
            blRecord.Status = LPI_LiteralConstant.Business_License_Status_VOID;
            blRecord.License_Sub_status__c = SURRENDERED;
        }
    }

    /**
    * @description 
    * @author MTX Group Product Team | 05-06-2024 
    * @param mapOfPARIdAndLicenseId 
    * @param isInsertNeeded 
    * @return List<License_Content__c> 
    **/
    public static List<License_Content__c> cloneAppConToLicCon(
        Map<Id, Id> mapOfPARIdAndLicenseId,
        Boolean isInsertNeeded
    ) {
        List<License_Content__c> listOfLicenseContent = new List<License_Content__c>();
        String appConFields =
            'Id,Preliminary_Application_Reference__c,' +
            'Specify__c,Street_1__c,State_of_Licensure__c,' +
            'City__c,Zip_Code__c,Copy_To_License_Content__c,' +
            'License_Number__c,' +
            'Licensure_Date__c,Expiration_Date__c,Method_of_Licensure__c,' +
            'Is_your_license_in_force__c,Describe_why__c,' +
            'Term_Started__c,Term_Completed__c,First_Name__c,' +
            'Profession_of_Licensure__c,Country__c,' +
            'Email__c,Phone_Number__c,State__c,' +
            'Section_Header__c,Board_Name__c ,' +
            'Are_you_Board_Certified__c, ' +
			'Preliminary_Application_Reference__r.Type__c,Preliminary_Application_Reference__r.Regulatory_Authorization_Type__r.Name,Applicant_Reference_Type__c';
        String appConWhereClause =
            'Preliminary_Application_Reference__c IN ' +
            LPI_ServiceUtility.getStringValuesBySet(
                mapOfPARIdAndLicenseId.keySet()
            ) +
            ' AND Copy_To_License_Content__c = true';
        for (
            Application_Content__c appContent : LPI_ApplicationContentDAO.getApplicationContentByDymanicQuery(
                appConFields,
                appConWhereClause,
                null,
                null,
                null
            )
        ) {
            if (
                mapOfPARIdAndLicenseId.get(
                    appContent.Preliminary_Application_Reference__c
                ) == null
            ) {
                continue;
            }
            listOfLicenseContent.add(
                new License_Content__c(
                    Business_License__c =  mapOfPARIdAndLicenseId.get(
                              appContent.Preliminary_Application_Reference__c
                          ),
                    Section_Header__c = appContent.Section_Header__c,
                    License_Number__c = appContent.License_Number__c,
                    Licensure_Date__c = appContent.Licensure_Date__c,
                    Expiration_Date__c = appContent.Expiration_Date__c,
                    State_of_Licensure__c = appContent.State_of_Licensure__c,
                    Method_of_Licensure__c = appContent.Method_of_Licensure__c,
                    Is_your_license_in_force__c = appContent.Is_your_license_in_force__c,
                    Describe_why__c = appContent.Describe_why__c,
                    Specify__c = appContent.Specify__c,
                    Street_Address__c = appContent.Street_1__c,
                    City__c = appContent.City__c,
                    Zip_Code__c = appContent.Zip_Code__c,
                    Country__c = appContent.Country__c,
                    Profession_of_Licensure__c = appContent.Profession_of_Licensure__c,
                    Term_Completed__c = appContent.Term_Completed__c,
                    Term_Started__c = appContent.Term_Started__c,
                    First_Name__c = appContent.First_Name__c,
                    Email__c = appContent.Email__c,
                    Phone_Number__c = appContent.Phone_Number__c,
                    State__c = appContent.State__c,
                    Are_you_Board_Certified__c = appContent.Are_you_Board_Certified__c,
                    Application_Id__c = appContent.Preliminary_Application_Reference__c,
					Applicant_Reference_Type__c = appContent.Applicant_Reference_Type__c
                )
            );
        }
        if (isInsertNeeded && !listOfLicenseContent.isEmpty()) {
            listOfLicenseContent = (List<License_Content__c>) LPI_WithoutSharingUtility.insertSObjectList(
                listOfLicenseContent
            );
        }
        return listOfLicenseContent;
    }

    public static BusinessLicense getMappedCommonBLRecord(
        SObject appRec,
        Integer counter,
        RegulatoryAuthorizationType regAuth
    ) {
        BusinessLicense blRec = new BusinessLicense();
        blRec.Name =
            String.valueOf(Date.today().year()) +
            String.valueOf(counter).leftPad(6, '0');
        blRec.RegulatoryAuthorizationTypeId = regAuth.Id;
        blRec.Status = LPI_LiteralConstant.STATUS_ACTIVE;
        blRec.AccountId = (Id) appRec.get('AccountId');
        blRec.PeriodStart = DateTime.parse(System.Now().format());
        blRec.PeriodEnd = validateAndGetExpiryDate( 
            appRec,
            regAuth,
            null
        );
		if(
			regAuth.IssuingDepartment.Name == APELSPA_BOARD_NAME &&
			(String)appRec.get('ApplicationType') == LPI_LiteralConstant.IA_NEW_APPLICATIONTYPE &&
			blRec.PeriodEnd != null
		){
			blRec.PeriodEnd = Datetime.newinstance(
				Date.today().year(),
				blRec.PeriodEnd.month(),
				blRec.PeriodEnd.day(),
				23,
				59,
				59
			);
		}
        blRec.Consent_for_Primary_Contact_Address__c = (boolean) appRec.get(
            'Consent_for_Primary_Contact_Address__c'
        );
        return blRec;
    }

    public static void updateAuthApplicationPlace(
        List<SObject> applicationList
    ) {
        Set<String> amendmentType = new Set<String>{
            LPI_LiteralConstant.PAR_AMENDMENT_SUBTYPE_NAME_OR_ADDRESS_CHANGE,
            LPI_LiteralConstant.CHANGE_OF_INDIVIDUAL_BUSINESS_ADDRESS,
            AMENDMENT_SUBTYPE_CHANGE_OF_RESIDENCE_ADDRESS,
            AMENDMENT_SUBTYPE_CHANGE_OF_MAILING_ADDRESS,
            AMENDMENT_SUBTYPE_CHANGE_OF_NAME,
            AMENDMENT_SUBTYPE_ADDRESS
        };
        Map<Id, Id> appIdToBlId = new Map<Id, Id>();
        Map<id, List<Id>> blIdToLocId = new Map<id, List<Id>>();
        Set<Id> blIdSet = new Set<Id>();
        List<Schema.location> allLocIds = new List<Schema.location>();
        for (SObject rec : applicationList) {
            Id recordId = rec.Id;
            String objName = recordId.getSObjectType().getDescribe().getName();
            if (INDIVIDUAL_APPLICATION == objName) {
                IndividualApplication iaObj = (IndividualApplication) rec;
                if (amendmentType.contains(iaObj.Amendment_Type__c)) {
                    continue;
                }
            }
            if(rec.get('LicensePermitNameId') == null && rec.get('Temporary_License_Number__c') != null){
                blIdSet.add((Id) rec.get('Temporary_License_Number__c'));
                appIdToBlId.put((Id) rec.get('Id'), (Id) rec.get('Temporary_License_Number__c'));
            } else{
                blIdSet.add((Id) rec.get('LicensePermitNameId'));
                appIdToBlId.put(
                    (Id) rec.get('Id'),
                    (Id) rec.get('LicensePermitNameId')
                );
            }
        }
        LPI_AuthApplicationPlaceDAO.LPI_AuthApplicationPlaceWithoutSharingDAO aapWithoutSharing = new LPI_AuthApplicationPlaceDAO.LPI_AuthApplicationPlaceWithoutSharingDAO();
        LPI_AuthApplicationPlaceDAO.LPI_AuthApplicationPlaceWithoutSharingDAO aapByAuthIdWithoutSharing = new LPI_AuthApplicationPlaceDAO.LPI_AuthApplicationPlaceWithoutSharingDAO();
        if (!appIdToBlId.isEmpty()) {
            List<AuthApplicationPlace> aapList = new List<AuthApplicationPlace>();
            for (
                AuthApplicationPlace aap : aapByAuthIdWithoutSharing.getAuthApplicationPlaceByAuthorizationIdsWithoutSecurity(
                    blIdSet
                )
            ) {
                if (!blIdToLocId.containsKey(aap.AuthorizationId)) {
                    blIdToLocId.put(aap.AuthorizationId, new List<Id>());
                }
                blIdToLocId.get(aap.AuthorizationId).add(aap.PlaceId);
            }
            for (
                AuthApplicationPlace aap : aapWithoutSharing.getAuthApplicationPlaceByDymanicQuery(
                    'Id, RgltyAuthApplicationId,PlaceId',
                    'RgltyAuthApplicationId IN ' +
                    LPI_ServiceUtility.getStringValuesBySet(
                        appIdToBlId.keySet()
                    ),
                    null,
                    null,
                    null
                )
            ) {
                if (
                    !blIdToLocId.containsKey(
                        appIdToBlId.get(aap.RgltyAuthApplicationId)
                    ) ||
                    !blIdToLocId.get(
                            appIdToBlId.get(aap.RgltyAuthApplicationId)
                        )
                        .contains(aap.PlaceId)
                ) {
                    aap.AuthorizationId = appIdToBlId.get(
                        aap.RgltyAuthApplicationId
                    );
                    aapList.add(aap);
                }
                Schema.location loc = new Schema.location(Id = aap.PlaceId);
                loc.Status__c = 'Open';
                allLocIds.add(loc);
            }
            if (!aapList.isEmpty()) {
                LPI_DML.doUpdate(aapList);
            }
            if (!allLocIds.isEmpty()) {
                LPI_DML.doUpdate(allLocIds);
            }
        }
    }

    /**
    * @description 
    * @author MTX Group Product Team | 05-06-2024 
    * @param recordsList 
    **/
    public static void sendEmailNotificationToApprentice(
        List<IndividualApplication> recordsList
    ) {
        try {
            String developerName;
            Set<Id> parIdSet = new Set<Id>();
            Set<Id> brIdSet = new Set<Id>();
            Set<Id> apprenticeSupervisorBrIdSet = new Set<Id>();
            Set<Id> iaIdSet = new Set<Id>();
            Map<Id, String> accIdToEmailMap = new Map<Id, String>();
            Map<String, Notification_Message__mdt> devNameToEmailNotifRecMap = new Map<String, Notification_Message__mdt>();
            List<Notification_Message__mdt> notificationMessageList = new List<Notification_Message__mdt>();
            List<IndividualApplication> applicationApprovedRejectedIssuedList = new List<IndividualApplication>();
            List<LPI_Wrapper.NotificationEmailWrapper> notificationEmailWrapperList = new List<LPI_Wrapper.NotificationEmailWrapper>();
            
            for (IndividualApplication record : recordsList) {
                iaIdSet.add(record.Id);
                applicationApprovedRejectedIssuedList.add(record);
                parIdSet.add(record.SavedApplicationRefId);
            }

            for (PreliminaryApplicationRef parRecord : LPI_PreliminaryApplicationRefDAO.getPARRecordsByID(parIdSet)){
                if (parRecord.Regulatory_Authorization_Type__r.Name == COSBAR_APPRENTICE_SUPERVISOR_RAT){
                    apprenticeSupervisorBrIdSet.add(parRecord.Supervisor_ACR_Id__c);
                } else {
                    brIdSet.add(parRecord.Supervisor_ACR_Id__c);
                }
            }

            if (!apprenticeSupervisorBrIdSet.isEmpty()) {
                for (Business_Relationships__c brRecord : LPI_BusinessRelationshipDAO.getRelationRecordsById(apprenticeSupervisorBrIdSet)) {
                    accIdToEmailMap.put(
                        brRecord.Related_From__c,
                        brRecord.Related_To__r.PersonEmail
                    );
                }
            }

            if (!brIdSet.isEmpty()) {
                for (Business_Relationships__c brRecord : LPI_BusinessRelationshipDAO.getRelationRecordsById(brIdSet)){
                    accIdToEmailMap.put(
                        brRecord.Related_To__c,
                        brRecord.Related_From__r.PersonEmail
                    );
                }
            }
            
            notificationMessageList = LPI_CustomMetadataTypeDAO.getAllNotificationByDeveloperNames(COSBAR_APPRENTICE_SUPERVISOR_EMAIL_SET);
            for (Notification_Message__mdt noti : notificationMessageList) {
                devNameToEmailNotifRecMap.put(noti.DeveloperName,noti);
            }

            Map<String, String> iaIdToHtmlStringMap = new Map<String, String>();
            iaIdToHtmlStringMap = LPI_TriggerServiceUtility.fetchDueDiligenceItems(iaIdSet,recordsList);
            
            if (!iaIdSet.isEmpty()) {
                String fieldsToQuery =
                    'Id, Name, AccountId,ApplicationType,LicenseType.Name, LicenseType.IssuingDepartment.Name, Account.Name, LicenseType.Email_Specifications_Final__c,' +
                    'Applicant_submission_Date__c, LicenseTypeId, Status, Account.PersonEmail, License_Type_Name__c';
                String whereClauseToQuery =
                    'Id IN ' +
                    LPI_ServiceUtility.getStringValuesBySet(iaIdSet);
                
                for (IndividualApplication record : LPI_IndividualApplicationDAO.getIndividualApplicationByDymanicQuery(fieldsToQuery,whereClauseToQuery,null,null,null)){
                    Map<String, String> replaceTextMap = new Map<String, String>();
                    Map<String, Object> boardSignatureMap = (Map<String, Object>) JSON.deserializeUntyped(String.valueOf( record.LicenseType.Email_Specifications_Final__c));
                    
                    if (record.Status == LPI_LiteralConstant.IA_APPROVED_STATUS) {

                        developerName = BUSINESS_LICENSE_APPROVED_EMAIL;
                        replaceTextMap = new Map<String, String>{
                            'Application_Type' => record.ApplicationType,
						    'License_Type_Name' => record.LicenseType.Name,
                            'Name' => record.Account.Name,
                            'Application_Number' => record.Name
                        };
                        
                    } 
                    else if (record.Status == LPI_LiteralConstant.IA_SUBMITTED_STATUS) {
                        

                        developerName = APPLICATION_SUBMISSION_EMAIL;
                        replaceTextMap = new Map<String, String> {
                            'Name' => record.Account.Name,
                            'License_Type' => record.LicenseType.Name,
                            'Portal_Link' => LPI_LiteralConstant.LPI_PORTAL_LINK,
                            'Application_Number' => record.Name
                        };
                    }
                    
                    else if (record.Status == LPI_LiteralConstant.IA_REJECTED_STATUS) {
                        developerName = BUSINESS_LICENSE_REJECTED_EMAIL;
                        replaceTextMap = new Map<String, String>{
                            'Rejected_Reason' => '',
                            'License_Type_Name' => record.LicenseType.Name
                        };
                    } else if(record.Status == LPI_LiteralConstant.IA_LICENSEISSUED_STATUS){
                        developerName = BUSINESS_LICENSE_ISSUED;
                        replaceTextMap = new Map<String, String>{
                            'Board_Name' => String.isNotBlank(
                                    (String) boardSignatureMap.get('boardName')
                                )
                                ? (String) boardSignatureMap.get('boardName')
                                : '',
                            'Board_PO_box' => String.isNotBlank(
                                    (String) boardSignatureMap.get('boardPoBox')
                                )
                                ? (String) boardSignatureMap.get('boardPoBox')
                                : '',
                            'Application_Number' => record.Name,
                            'License_Type_Name' => record.License_Type_Name__c,
                            'Portal_Link' => System.Label.Site_Url,
                            'Board_Email_MO_DPR' => String.isNotBlank(
                                    (String) boardSignatureMap.get('boardEmail')
                                )
                                ? (String) boardSignatureMap.get('boardEmail')
                                : ''
                        };
                    }
                
                    String emailBody = devNameToEmailNotifRecMap.get(developerName).Description__c;

                    if (replaceTextMap != null) {
                        for (String key : replaceTextMap.keySet()) {
                            emailBody = emailBody.replaceAll('\\[' + key + '\\]', replaceTextMap.get(key));
                        }
                    }

                    Boolean attachmentreq = devNameToEmailNotifRecMap.get(developerName).Attachment_Required__c;
                    if (record.Status == LPI_LiteralConstant.BLA_APPROVED_STATUS) {
                        LPI_Wrapper.NotificationEmailWrapper notifcationWrapperApprove = new LPI_Wrapper.NotificationEmailWrapper();
                        notifcationWrapperApprove.templateName = devNameToEmailNotifRecMap.get(developerName).Template_Name__c;
                        notifcationWrapperApprove.subject = devNameToEmailNotifRecMap.get(developerName).Title__c;
                        notifcationWrapperApprove.replaceTextMap = replaceTextMap;
                        notifcationWrapperApprove.accountId = record.AccountId;
                        notifcationWrapperApprove.recipientEmail = String.isNotBlank(String.valueOf(accIdToEmailMap.get(record.AccountId))) ?  accIdToEmailMap.get(record.AccountId) : record.Account.PersonEmail;
                        notifcationWrapperApprove.description = emailBody;
                        notifcationWrapperApprove.iaId = record.Id;
                        notificationEmailWrapperList.add(notifcationWrapperApprove);
                    }else if (record.Status == LPI_LiteralConstant.BLA_LICENSEISSUED_STATUS) {
                        LPI_Wrapper.NotificationEmailWrapper notifcationWrapperApprove = new LPI_Wrapper.NotificationEmailWrapper();
                        notifcationWrapperApprove.templateName = devNameToEmailNotifRecMap.get(developerName).Template_Name__c;
                        notifcationWrapperApprove.subject = devNameToEmailNotifRecMap.get(developerName).Title__c;
                        notifcationWrapperApprove.pdfAttachmentName = devNameToEmailNotifRecMap.get(developerName).PDF_Attachment_Name__c;
                        notifcationWrapperApprove.attachmentRequired = String.valueOf(attachmentreq);
                        notifcationWrapperApprove.replaceTextMap = replaceTextMap;
                        notifcationWrapperApprove.accountId = record.AccountId;
                        notifcationWrapperApprove.recipientEmail = String.isNotBlank(String.valueOf(accIdToEmailMap.get(record.AccountId))) ?  accIdToEmailMap.get(record.AccountId) : record.Account.PersonEmail;
                        notifcationWrapperApprove.description = emailBody;
                        notifcationWrapperApprove.iaId = record.Id;
                        notificationEmailWrapperList.add(notifcationWrapperApprove);
                    }
                }
            }
             
            List<Notification__c> createdNotificationForBLIssuedList= new List<Notification__c>();

            if (!notificationEmailWrapperList.isEmpty()) {
                createdNotificationForBLIssuedList = LPI_ServiceUtility.createNotificationRecords(notificationEmailWrapperList);
            }
            for(Notification__c ntf : createdNotificationForBLIssuedList){
                if(ntf.Is_Attachments_Required__c == true){
                    LPI_GeneratePDF.generatePDF(ntf.Individual_Application__c,ntf.Id);
                }
            }
        } catch (Exception e) {
            LPI_ExceptionManager.logException(
                'LPI_TriggerServiceUtility',
                'sendEmailNotificationToApprentice',
                e
            );
        }
    }

    public static Map<String, String> fetchDueDiligenceItems(
        Set<Id> recordIdSet,
        List<SObject> recordList
    ) {
        Map<String, List<String>> iaIdToDueDiligenceMap = new Map<String, List<String>>();
        Map<String, String> iaIdToStringMap = new Map<String, String>();
        try {
            String fieldsToQuery = 'ID, Individual_Application__c, Application__c, Status__c, Comment__c, Checklist_Name__c';
            String whereClause =
                '(Application__c IN ' +
                LPI_ServiceUtility.getStringValuesBySet(recordIdSet) +
                +' OR Individual_Application__c IN ' +
                LPI_ServiceUtility.getStringValuesBySet(recordIdSet) +
                ')  AND Status__c = \'' +
                STATUS_MISSING +
                '\'';
            String orderBy = 'Sequence__c';
            List<Due_Diligence__c> dueDiligenceList = LPI_DueDiligenceDAO.getDueDiligenceByDymanicQuery(
                fieldsToQuery,
                whereClause,
                null,
                orderBy,
                null
            );
            for (Due_Diligence__c dd : dueDiligenceList) {
                String htmltag;
                if (String.isNotBlank(dd.Checklist_Name__c)) {
                    htmltag = '<li>' + dd.Checklist_Name__c;
                }
                if (String.isNotBlank(dd.Comment__c)) {
                    htmltag +=
                        '<ol type = "a"><li>' +
                        dd.Comment__c +
                        '</li></ol></li>';
                }
                String applicationId = dd.Application__c != null
                    ? dd.Application__c
                    : dd.Individual_Application__c;
                if (!iaIdToDueDiligenceMap.containsKey(applicationId)) {
                    iaIdToDueDiligenceMap.put(
                        applicationId,
                        new List<String>()
                    );
                }
                iaIdToDueDiligenceMap.get(applicationId).add(htmltag);
            }
            for (Sobject rec : recordList) {
				String comment = '<ol>';
				if(!iaIdToDueDiligenceMap.isEmpty()){
					comment += String.join(iaIdToDueDiligenceMap.get(rec.Id), ' ');
				}
                comment +=
                    '<li>' +
                    rec.get('Rejection_Reason__c') +
                    '</li></ol>';
                iaIdToStringMap.put(rec.Id, comment);
            }
        } catch (Exception e) {
            LPI_ExceptionManager.logException(
                'LPI_TriggerServiceUtility',
                'fetchDueDiligenceItems',
                e
            );
        }
        return iaIdToStringMap;
    }

    public static void createNotifications(List<IndividualApplication> recordsList) {
        try {
            String mdtDeveloperName;
            Set<Id> iaIdSet = new Set<Id>();
            Map<String, String> replaceTextMap = new Map<String, String>();
            Map<String, String> devNameToTemplateNameMap = new Map<String, String>();
            Map<String,String> devNameToEmailBody = new Map<String,String>();
            Map<String,String> devNameToEmailSubject = new Map<String,String>();
            Map<String,String> devNameToAttachmentRequired = new Map<String,String>();
            Map<String,String> devNameToPDFAttachmentName = new Map<String,String>();
            List<Notification_Message__mdt> notificationMessageList = new List<Notification_Message__mdt>();
            List<LPI_Wrapper.NotificationEmailWrapper> notificationEmailWrapperList = new List<LPI_Wrapper.NotificationEmailWrapper>();

            for (IndividualApplication record : recordsList) {
                iaIdSet.add(record.Id);
            }
            
            if (!iaIdSet.isEmpty()) {
                String fieldsToQuery = 'Id, Name, AccountId, LicenseType.IssuingDepartment.Name, Account.Name, LicenseType.Email_Specifications_Final__c,' +
                'Applicant_submission_Date__c, LicenseTypeId, Status, Account.PersonEmail, License_Type_Name__c';
                String whereClauseToQuery = 'Id IN ' + LPI_ServiceUtility.getStringValuesBySet(iaIdSet);
                for (IndividualApplication record : LPI_IndividualApplicationDAO.getIndividualApplicationByDymanicQuery(fieldsToQuery,whereClauseToQuery,null,null,null)){
                    Map<String, Object> boardSignatureMap = (Map<String, Object>) JSON.deserializeUntyped(String.valueOf(record.LicenseType.Email_Specifications_Final__c));
                    String emailBody;
                    if (record.Status == LPI_LiteralConstant.IA_SUBMITTED_STATUS) {
                        mdtDeveloperName = APPLICATION_SUBMISSION_EMAIL;
                        notificationMessageList = LPI_CustomMetadataTypeDAO.getAllNotificationByDeveloperNames(APPLICATION_SUBMISSION_EMAIL_SET);
                        replaceTextMap = new Map<String, String> {
                            'Name' => record.Account.Name,
                            'License_Type' => record.License_Type_Name__c,
                            'Portal_Link' => LPI_LiteralConstant.LPI_PORTAL_LINK,
                            'Application_Number' => record.Name
                        };
                    } else if (record.Status == LPI_LiteralConstant.IA_APPROVED_STATUS) {
                        mdtDeveloperName = BUSINESS_LICENSE_APPROVED_EMAIL;
                        notificationMessageList = LPI_CustomMetadataTypeDAO.getAllNotificationByDeveloperNames(IA_EMAIL_APPROVAL_EMAIL_SET);
                        replaceTextMap = new Map<String, String> {
                            'Name' => record.Account.Name,
                            'Application_Number' => record.Name
                        };
                        replaceTextMap.put('Approval_Date', String.valueOf(System.Today().format()));
                        if (String.isNotBlank((String) boardSignatureMap.get('boardName'))) {
                            replaceTextMap.put('Board_Name', (String) boardSignatureMap.get('boardName'));
                        }
                    }

                    for (Notification_Message__mdt noti : notificationMessageList) {
                        devNameToTemplateNameMap.put(noti.DeveloperName, noti.Template_Name__c);
                        devNameToEmailBody.put(noti.DeveloperName, noti.Description__c);
                        devNameToEmailSubject.put(noti.DeveloperName, noti.Title__c);
                        devNameToAttachmentRequired.put(noti.DeveloperName, String.valueOf(noti.Attachment_Required__c));
                        devNameToPDFAttachmentName.put(noti.DeveloperName, noti.PDF_Attachment_Name__c);
                    }

                    emailBody = devNameToEmailBody.get(mdtDeveloperName);

                    if (replaceTextMap != null) {
                        for (String key : replaceTextMap.keySet()) {
                            emailBody = emailBody.replaceAll('\\[' + key + '\\]', replaceTextMap.get(key));
                        }
                    }

                    LPI_Wrapper.NotificationEmailWrapper notifcationWrapper = new LPI_Wrapper.NotificationEmailWrapper();
                    notifcationWrapper.templateName = devNameToTemplateNameMap.get(mdtDeveloperName);
                    
                    LPI_Wrapper.NotificationEmailWrapper notifcationWrapperApprove = new LPI_Wrapper.NotificationEmailWrapper();
                    notifcationWrapperApprove.templateName = devNameToTemplateNameMap.get(mdtDeveloperName);
                    notifcationWrapperApprove.subject = devNameToEmailSubject.get(mdtDeveloperName);
                    notifcationWrapperApprove.replaceTextMap = replaceTextMap;
                    notifcationWrapperApprove.attachmentRequired = devNameToAttachmentRequired.get(mdtDeveloperName);
                    notifcationWrapperApprove.pdfAttachmentName = devNameToPDFAttachmentName.get(mdtDeveloperName);
                    notifcationWrapperApprove.accountId = record.AccountId;
                    notifcationWrapperApprove.recipientEmail = record.Account.PersonEmail;
                    notifcationWrapperApprove.description = emailBody;
                    notifcationWrapperApprove.iaId = record.Id;
                    notificationEmailWrapperList.add(notifcationWrapperApprove);
                }
            }
           
            List<Notification__c> createdNotificationList= new List<Notification__c>();
            if (!notificationEmailWrapperList.isEmpty()) {
                createdNotificationList = LPI_ServiceUtility.createNotificationRecords(
                    notificationEmailWrapperList
                );
            }
           

            for(Notification__c ntf : createdNotificationList){
                if(ntf.Is_Attachments_Required__c == true){
                   
                    LPI_GeneratePDF.generatePDF(ntf.Individual_Application__c,ntf.Id);
                }
            }

        } catch (Exception e) {
            LPI_ExceptionManager.logException(
                'LPI_TriggerServiceUtility',
                'createNotifications',
                e
            );
        }
    }

}