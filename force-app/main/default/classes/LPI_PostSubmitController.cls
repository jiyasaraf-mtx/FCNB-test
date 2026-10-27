/**
 * @description       : 
 * @author            : MTX Group Product Team
 * @group             : 
 * @last modified on  : 06-04-2024
 * @last modified by  :MTX Group Product Team
**/
global with sharing class LPI_PostSubmitController implements Callable {

    /**
	 * @author                      : MTX Group Product Team
	 * @since                       : 24 March, 2023
	 * @description                 : This method return the List of Object Data to Omnistudio component
	 * @param action
     * @param args
     * @return  `Object`
	 */
    global Object call(String action, Map<String, Object> args) {
        Map<String, Object> input = (Map<String, Object>) args.get('input');
        Map<String, Object> output = (Map<String, Object>) args.get('output');
        Map<String, Object> options = (Map<String, Object>) args.get('options');
        return invokeMethod(action, input, output, options);
    }

    /**
	 * @author                      : MTX Group Product Team
	 * @since                       : 24 March, 2023
	 * @description                 : This method return the output of called method
	 * @param methodName 
     * @param inputMap 
     * @param outMap 
     * @param options 
     * @return  `Boolean`
	 */
    private Boolean invokeMethod(String methodName, Map<String, Object> inputMap, Map<String, Object> outMap, Map<String, Object> options) {
        Boolean result = true;
        try {
            if (methodName == 'handlePostSubmit') {
                handlePostSubmit(inputMap, outMap);
            }
        } catch (Exception e) {
            LPI_ExceptionManager.logException('LPI_PostSubmitController', 'invokeMethod', e);
            result = false;
        }
        return result;
    }
    /** 
	 * @author                      : MTX Group Product Team
	 * @since                       : 24 March, 2023
	 * @description                 : This method performs after sumbmission actions like Temp Fee and its Item record creation and
     *                                if no fee applicable then moving the PAR to Converted status. 
	 * @param inputMap 
     * @param outMap 
	 * @last modified by            : MTX Group Product Team
	 * @last modified date          : (Add if modified by you)
	 * @last modified details       : (Add if modified by you)
	 */
    public static void handlePostSubmit(Map<String, Object> inputMap,Map<String, Object> outMap) {
        
        try {
            String parId = (String) inputMap.get('parId');
            if(String.isNotEmpty(parId)){
                Map<String,Object> paymentDataMap = new Map<String,Object>();
                LPI_FetchFeeDetails.fetchFeeRecords(inputMap,paymentDataMap);
                inputMap.put('PaymentData',paymentDataMap.get('PaymentData'));
                System.debug('line 66 >>>>>>>>' +inputmap.get('PaymentData'));
                String parFieldsToQuery = 'Id, Type__c,Business_License__c, BusinessAccountNameId, IsSubmitted, Status__c,Is_Submitted_By_Internal_User__c,'+
                'Contact__r.Name';
                String parWhereClause = 'Id =\'' + String.escapeSingleQuotes(parId) + '\'';
                
                List<PreliminaryApplicationRef> parRecords = LPI_PreliminaryApplicationRefDAO.getPreliminaryApplicationRefByDymanicQuery(
                    parFieldsToQuery,
                    parWhereClause,
                    null,
                    null,
                    null
                );
                
                Map<String,Object> mapOfPaymentData = (Map<String,Object>) inputMap.get('PaymentData');
                Double totalAmount = (Double)mapOfPaymentData.get('TotalAmount');
                System.debug('TOTAL @ Amount@@@@@'+ mapOfPaymentData.get('TotalAmount'));
                Boolean isPortalUser = (Boolean) mapOfPaymentData.get('currentUserIsPortalUser');
               
                Boolean isPayLater = false;
                if (inputMap.containsKey('PayLater')) {
                    System.debug('entered if block  >>>');
                    String payLaterStr = String.valueOf(inputMap.get('PayLater'));
                    isPayLater = (String.isNotBlank(payLaterStr) && payLaterStr.equalsIgnoreCase('True'));
                }
                Boolean isSkipPayment = isSkipPaymentSelected(inputMap);
                // IndividualInsurancePayment Pay Later (skipPayment = yes)
                if (isSkipPayment) {
                    isPayLater = true;
                }
                System.debug('paylater>>>> ' + isPayLater + ' skipPayment>>>> ' + isSkipPayment);
                Map<String,Object> mapOfPaymentStep = (Map<String,Object>) inputMap.get('Payment');
                Map<String , String> keyMapping = new Map<String , String>{
                    'AmountTendered'=>'Amount_Tendered__c',
                    'TransactionId' =>'Transaction_ID__c',
                    'PaidBySomeone' =>'Paid_by_someone_other_than_applicant__c',
                    'PayerFullName' =>'Payer_Full_Name_Company_Name__c',
                    'PayerPhoneNumber' =>'Payer_Phone_Number__c'
                };
                if(parRecords.size()>0 && !parRecords[0].IsSubmitted && parRecords[0].Status__c !='Converted'){
                    if(isPortalUser){
                        if(totalAmount>0){
                            system.debug('entered line 102 >>>');
                            String tempFeeQueryFields = 'Id, Status__c, Transaction_ID__c, PreliminaryApplicationReference__c';
                            String tempFeeWhereClauseFields = 'PreliminaryApplicationReference__c =\''+String.escapeSingleQuotes(parId)+'\' AND Status__c = \'Pending\'';
                            List<Temp_Fee__c> tempFeeData = LPI_TempFeeDAO.getTempFeeListByDynamicQuery(tempFeeQueryFields,tempFeeWhereClauseFields,null,null,null);
                            List<Temp_Fee__c> tempFeeDataToBeUpserted = new List<Temp_Fee__c>();
                            if(tempFeeData.size()>0){
                                System.debug('entered line 108, fee data size 0 nhi  h');
                                Temp_Fee__c tempFeeToBeUpserted = new Temp_Fee__c();
                                tempFeeToBeUpserted.Id= tempFeeData[0].Id;
                                tempFeeToBeUpserted.FeeAmount__c = totalAmount;
                                if(isPayLater || isSkipPayment){
                                    tempFeeToBeUpserted.Status__c ='Payment Pending';
                                }
                                
                                  tempFeeToBeUpserted.Payment_Method__c ='';
                                if (tempFeeToBeUpserted.Id != null) {
                                    LPI_WithoutSharingUtility.updateSObjectList(new List<Temp_Fee__c>{tempFeeToBeUpserted});
                                }
                                String tempFeeItemQueryFields = 'Id';
                                String tempFeeItemWhereClauseFields = 'Temp_Fee__c =\''+String.escapeSingleQuotes(tempFeeData[0].Id)+'\'';
                                List<Temp_Fee_Item__c> feeItemListTOBeDeleted = LPI_TempFeeItemDAO.getTempFeeItemListByDynamicQuery(tempFeeItemQueryFields,tempFeeItemWhereClauseFields,null,null,null);
                                if (feeItemListTOBeDeleted.size() > 0) {
                                    LPI_WithoutSharingUtility.deleteSObject(feeItemListTOBeDeleted);                   
                                }
                                List<Object> feeaItemObjList = new List<Object>();
                                if(isMap(mapOfPaymentData.get('FeesSummary'))){
                                    feeaItemObjList.add((Object) mapOfPaymentData.get('FeesSummary'));
                                } else {
                                    feeaItemObjList = (List<Object>) mapOfPaymentData.get('FeesSummary');
                                }
                                List<Temp_Fee_Item__c> dataToBeInserted = new List<Temp_Fee_Item__c>();
                                for (Object data : feeaItemObjList) {
                                    Map<String, Object> feeaItemData = (Map<String, Object>) data;
                                    Temp_Fee_Item__c tFIToBeInserted = new Temp_Fee_Item__c();
                                    tFIToBeInserted.Temp_Fee__c = tempFeeData[0].Id;
                                    tFIToBeInserted.Name = (String) feeaItemData.get('Name');
                                    tFIToBeInserted.FeeAmount__c = (Double) feeaItemData.get('Fee_Amount');
                                    tFIToBeInserted.Actual_Asked_Amount__c =  tFIToBeInserted.FeeAmount__c;
                                    tFIToBeInserted.Object_Code__c = (String) feeaItemData.get('Object_Code');
                                    dataToBeInserted.add(tFIToBeInserted);
                                }
                                if(dataToBeInserted.size()>0){
                                    LPI_DML.doInsert(dataToBeInserted);
                                }
                                if (isSkipPayment) {
                                    updatePar((String) inputMap.get('ViewApplicationURL'), parId, true, 'Converted');
                                }
                            } else {
                                System.debug('entered line 148');
    
                                Temp_Fee__c tempFeeToBeInserted = new Temp_Fee__c();
                                tempFeeToBeInserted.Status__c = (isPayLater || isSkipPayment) ? 'Payment Pending' : 'Pending';
                                System.debug('totalAmount #######'+totalAmount);
                                tempFeeToBeInserted.FeeAmount__c = totalAmount;
                                tempFeeToBeInserted.PreliminaryApplicationReference__c=parId;
                               
                                tempFeeToBeInserted.Payment_Method__c ='';
                                tempFeeToBeInserted.Transaction_ID__c = generateRandomNumber(15);
                                if(String.isBlank(tempFeeToBeInserted.Payer_Full_Name_Company_Name__c)){
                                    tempFeeToBeInserted.Payer_Full_Name_Company_Name__c = parRecords[0].Contact__r.Name;
                                }
                                tempFeeToBeInserted = (Temp_Fee__c) LPI_WithoutSharingUtility.insertSObject(tempFeeToBeInserted);
                                if(tempFeeToBeInserted.Id !=null){
                                    List<Object> feeaItemObjList = new List<Object>();
                                    if(isMap(mapOfPaymentData.get('FeesSummary'))){
                                        feeaItemObjList.add((Object) mapOfPaymentData.get('FeesSummary'));
                                    } else {
                                        feeaItemObjList = (List<Object>) mapOfPaymentData.get('FeesSummary');
                                    }
                                    List<Temp_Fee_Item__c> dataToBeInserted = new List<Temp_Fee_Item__c>();
                                    for (Object data : feeaItemObjList) {
                                        Map<String, Object> feeaItemData = (Map<String, Object>) data;
                                        Temp_Fee_Item__c tFIToBeInserted = new Temp_Fee_Item__c();
                                        tFIToBeInserted.Temp_Fee__c = tempFeeToBeInserted.Id;
                                        tFIToBeInserted.Name = (String) feeaItemData.get('Name');
                                        tFIToBeInserted.FeeAmount__c = (Double) feeaItemData.get('Fee_Amount');
                                        tFIToBeInserted.Actual_Asked_Amount__c = tFIToBeInserted.FeeAmount__c;
                                        tFIToBeInserted.Object_Code__c = (String) feeaItemData.get('Object_Code');
                                        dataToBeInserted.add(tFIToBeInserted);
                                    }
                                    if(dataToBeInserted.size()>0){
                                        System.debug('entered dml insert at 183');
                                        LPI_DML.doInsert(dataToBeInserted);
                                    }
                                }
                                if (isSkipPayment) {
                                    updatePar((String) inputMap.get('ViewApplicationURL'), parId, true, 'Converted');
                                } else {
                                    updatePar((String) inputMap.get('ViewApplicationURL'), parId, false, 'Payment Pending');
                                }
                            }
                        } 
                        else {
                            System.debug('entered line 190');
                            Temp_Fee__c tempFeeToBeInserted = new Temp_Fee__c();
                            if (isSkipPayment) {
                                tempFeeToBeInserted.Status__c = 'Payment Pending';
                                tempFeeToBeInserted.FeeAmount__c = totalAmount;
                                tempFeeToBeInserted.Payment_Method__c = '';
                                tempFeeToBeInserted.Transaction_Fee_Amount__c = 0;
                                tempFeeToBeInserted.Transaction_ID__c = generateRandomNumber(15);
                                tempFeeToBeInserted.PreliminaryApplicationReference__c=parId;
                                if(String.isBlank(tempFeeToBeInserted.Payer_Full_Name_Company_Name__c)){
                                    tempFeeToBeInserted.Payer_Full_Name_Company_Name__c = parRecords[0].Contact__r.Name;
                                }
                                tempFeeToBeInserted = (Temp_Fee__c) LPI_WithoutSharingUtility.insertSObject(tempFeeToBeInserted);
                                if(tempFeeToBeInserted.Id !=null && mapOfPaymentData.get('FeesSummary') != null){
                                    List<Object> feeaItemObjList = new List<Object>();
                                    if(isMap(mapOfPaymentData.get('FeesSummary'))){
                                        feeaItemObjList.add((Object) mapOfPaymentData.get('FeesSummary'));
                                    } else {
                                        feeaItemObjList = (List<Object>) mapOfPaymentData.get('FeesSummary');
                                    }
                                    List<Temp_Fee_Item__c> dataToBeInserted = new List<Temp_Fee_Item__c>();
                                    for (Object data : feeaItemObjList) {
                                        Map<String, Object> feeaItemData = (Map<String, Object>) data;
                                        Temp_Fee_Item__c tFIToBeInserted = new Temp_Fee_Item__c();
                                        tFIToBeInserted.Temp_Fee__c = tempFeeToBeInserted.Id;
                                        tFIToBeInserted.Name = (String) feeaItemData.get('Name');
                                        tFIToBeInserted.FeeAmount__c = (Double) feeaItemData.get('Fee_Amount');
                                        tFIToBeInserted.Actual_Asked_Amount__c = tFIToBeInserted.FeeAmount__c;
                                        tFIToBeInserted.Object_Code__c = (String) feeaItemData.get('Object_Code');
                                        dataToBeInserted.add(tFIToBeInserted);
                                    }
                                    if(dataToBeInserted.size()>0){
                                        LPI_DML.doInsert(dataToBeInserted);
                                    }
                                }
                                updatePar((String) inputMap.get('ViewApplicationURL'), parId, true, 'Converted');
                            } else {
                                tempFeeToBeInserted.Status__c = 'Paid';
                                tempFeeToBeInserted.FeeAmount__c = 0;
                                tempFeeToBeInserted.Payment_Method__c = 'Offline';
                                tempFeeToBeInserted.Transaction_Fee_Amount__c = 0;
                                tempFeeToBeInserted.Transaction_ID__c = generateRandomNumber(15);
                                tempFeeToBeInserted.Transaction_Date__c = System.now();
                                tempFeeToBeInserted.PreliminaryApplicationReference__c=parId;
                                tempFeeToBeInserted = (Temp_Fee__c) LPI_DML.doInsert(tempFeeToBeInserted);
        
                                Temp_Fee_Item__c tFIToBeInserted = new Temp_Fee_Item__c();
                                tFIToBeInserted.Temp_Fee__c = tempFeeToBeInserted.Id;
                                tFIToBeInserted.Name = 'Not Applicable';
                                tFIToBeInserted.FeeAmount__c = 0;
                                tFIToBeInserted.Actual_Asked_Amount__c = 0;
                                tFIToBeInserted = (Temp_Fee_Item__c) LPI_DML.doInsert(tFIToBeInserted);
                                updatePar((String) inputMap.get('ViewApplicationURL'), parId, true, 'Converted');
                            }
                        }
                    } else if(!parRecords[0].Is_Submitted_By_Internal_User__c) {
                        if(totalAmount>0){

                            Temp_Fee__c tempFeeToBeInserted = new Temp_Fee__c();
                            tempFeeToBeInserted.PreliminaryApplicationReference__c=parId;
                            if (isSkipPayment) {
                                tempFeeToBeInserted.Status__c = 'Payment Pending';
                                tempFeeToBeInserted.Payment_Method__c = '';
                                tempFeeToBeInserted.Transaction_Fee_Amount__c = 0;
                                tempFeeToBeInserted.FeeAmount__c = totalAmount;
                                tempFeeToBeInserted.Transaction_ID__c = generateRandomNumber(15);
                                tempFeeToBeInserted.Payer_Full_Name_Company_Name__c = parRecords[0].Contact__r.Name;
                            } else {
                                Map<String,Object> mapOfFeeDataBlock = (Map<String,Object>) mapOfPaymentStep.get('FeeDataBlock');
                                Map<String,Object> mapOfCardDetail = (Map<String,Object>) mapOfFeeDataBlock.get('InternalPaymentDetail');
                                tempFeeToBeInserted.Status__c = 'Paid';
                                tempFeeToBeInserted.Payment_Method__c = 'Offline';
                                tempFeeToBeInserted.Amount_Tendered__c = (Double) mapOfCardDetail.get('AmountTendered');
                                tempFeeToBeInserted.Transaction_ID__c = (String) mapOfCardDetail.get('TransactionId');
                                tempFeeToBeInserted.Transaction_Fee_Amount__c = 0;
                                tempFeeToBeInserted.FeeAmount__c = totalAmount;
                                tempFeeToBeInserted.Transaction_Date__c = System.now();
                                tempFeeToBeInserted.Paid_by_someone_other_than_applicant__c = (Boolean) mapOfCardDetail.get('PaidBySomeone');
                                tempFeeToBeInserted.Payer_Full_Name_Company_Name__c = (String) mapOfCardDetail.get('PayerFullName');
                                if(String.isBlank(tempFeeToBeInserted.Payer_Full_Name_Company_Name__c)){
                                    tempFeeToBeInserted.Payer_Full_Name_Company_Name__c = parRecords[0].Contact__r.Name;
                                }
                                tempFeeToBeInserted.Payer_Phone_Number__c =(String) mapOfCardDetail.get('PayerPhoneNumber') ;
                                tempFeeToBeInserted.Memo__c =(String) mapOfCardDetail.get('Memo') ;
                            }
                            tempFeeToBeInserted = (Temp_Fee__c) LPI_DML.doInsert(tempFeeToBeInserted);

                            if(tempFeeToBeInserted.Id !=null){
                                List<Object> feeaItemObjList = new List<Object>();
                                if(isMap(mapOfPaymentData.get('FeesSummary'))){
                                    feeaItemObjList.add((Object) mapOfPaymentData.get('FeesSummary'));
                                } else {
                                    feeaItemObjList = (List<Object>) mapOfPaymentData.get('FeesSummary');
                                }
                                List<Temp_Fee_Item__c> dataToBeInserted = new List<Temp_Fee_Item__c>();
                                for (Object data : feeaItemObjList) {
                                    Map<String, Object> feeaItemData = (Map<String, Object>) data;
                                    Temp_Fee_Item__c tFIToBeInserted = new Temp_Fee_Item__c();
                                    tFIToBeInserted.Temp_Fee__c = tempFeeToBeInserted.Id;
                                    tFIToBeInserted.Name = (String) feeaItemData.get('Name');
                                    tFIToBeInserted.FeeAmount__c = (Double) feeaItemData.get('Fee_Amount');
                                    tFIToBeInserted.Actual_Asked_Amount__c =  tFIToBeInserted.FeeAmount__c;
                                    tFIToBeInserted.Object_Code__c = (String) feeaItemData.get('Object_Code');
                                    dataToBeInserted.add(tFIToBeInserted);
                                }
                                if(dataToBeInserted.size()>0){
                                    LPI_DML.doInsert(dataToBeInserted);
                                }
                                updatePar((String) inputMap.get('ViewApplicationURL'), parId, true, 'Converted');
                            }
                        } 
                        else {
                            Temp_Fee__c tempFeeToBeInserted = new Temp_Fee__c();
                            if (isSkipPayment) {
                                tempFeeToBeInserted.Status__c = 'Payment Pending';
                                tempFeeToBeInserted.FeeAmount__c = 0;
                                tempFeeToBeInserted.Payment_Method__c = '';
                                tempFeeToBeInserted.Transaction_Fee_Amount__c = 0;
                                tempFeeToBeInserted.Transaction_ID__c = generateRandomNumber(15);
                                tempFeeToBeInserted.PreliminaryApplicationReference__c=parId;
                                tempFeeToBeInserted = (Temp_Fee__c) LPI_DML.doInsert(tempFeeToBeInserted);
                            } else {
                                tempFeeToBeInserted.Status__c = 'Paid';
                                System.debug('259 line>>>>>>>>');
                                tempFeeToBeInserted.FeeAmount__c = 0;
                                tempFeeToBeInserted.Payment_Method__c = 'Offline';
                                tempFeeToBeInserted.Transaction_Fee_Amount__c = 0;
                                tempFeeToBeInserted.Transaction_ID__c = generateRandomNumber(15);
                                tempFeeToBeInserted.Transaction_Date__c = System.now();
                                tempFeeToBeInserted.PreliminaryApplicationReference__c=parId;
                                tempFeeToBeInserted = (Temp_Fee__c) LPI_DML.doInsert(tempFeeToBeInserted);
        
                                Temp_Fee_Item__c tFIToBeInserted = new Temp_Fee_Item__c();
                                tFIToBeInserted.Temp_Fee__c = tempFeeToBeInserted.Id;
                                tFIToBeInserted.Name = 'Not Applicable';
                                tFIToBeInserted.FeeAmount__c = 0;
                                tFIToBeInserted.Actual_Asked_Amount__c = 0;
                                tFIToBeInserted = (Temp_Fee_Item__c) LPI_DML.doInsert(tFIToBeInserted);
                            }
                            updatePar((String) inputMap.get('ViewApplicationURL'), parId, true, 'Converted');
                            
                        }
                    } else if(parRecords[0].Is_Submitted_By_Internal_User__c){
                      	updatePar((String) inputMap.get('ViewApplicationURL'), parId, true, 'Converted');
                    }
                }
                
            
                String retURL = '';
                List<IndividualApplication> iaList= new LPI_IndividualApplicationDAO.LPI_DAO_IndividualApptWithoutSecurity().getILABySavedAppRefId(new Set<Id>{parId}); 
                List<BusinessLicenseApplication> blaList= new LPI_BusinessLicenseApplicationDAO.LPI_DAO_BusinessLiceWithoutSecurity().getBLABySavedAppRefId(new Set<Id>{parId});
                Boolean isFeeExempt = mapOfPaymentData != null && mapOfPaymentData.get('Exempt') == true;
                if (!isFeeExempt) {
                    isFeeExempt = isApplicantFeeExempt(inputMap);
                }
                if (isFeeExempt && !iaList.isEmpty()) {
                    List<IndividualApplication> iaExemptUpdates = new List<IndividualApplication>();
                    for (IndividualApplication ia : iaList) {
                        iaExemptUpdates.add(new IndividualApplication(Id = ia.Id, Is_Exempted__c = true));
                    }
                    LPI_WithoutSharingUtility.updateSObjectList(iaExemptUpdates);
                }
                if(isSkipPayment && isPortalUser){
                   if(blaList.size()>0){
                        retURL = '/s/success-page?blaId='+blaList[0].Id+'&status=Payment Pending&indAppId=null&parId=null';
                    } else if(iaList.size()>0){
                        retURL = '/s/success-page?indAppId='+iaList[0].Id+'&status=Payment Pending&blaId=null&parId=null';
                    } else {
                        retURL = '/s/success-page?parId='+parId+'&status=Payment Pending&indAppId=null&blaId=null';
                    }
                } else if(totalAmount == 0 && isPortalUser){
                   if(blaList.size()>0){
                        retURL = '/s/success-page?blaId='+blaList[0].Id+'&status=Paid&indAppId=null&parId=null';
                    } else if(iaList.size()>0){
                        retURL = '/s/success-page?indAppId='+iaList[0].Id+'&status=Paid&blaId=null&parId=null';
                    }
                } else if(totalAmount != 0 && isPortalUser){
                    retURL=  '/apex/LPI_JetPayIntegrationRedirectPage?parId='+parId;
                } else if(!isPortalUser){
                    if(blaList.size()>0){
                        retURL = '/'+blaList[0].Id;
                    } else if(iaList.size()>0){
                        retURL = '/'+iaList[0].Id;
                    }
                }
                outMap.put('retURL', retURL);
            }
        } catch (Exception e) {
            LPI_ExceptionManager.logException('LPI_PostSubmitController', 'handlePostSubmit', e);
        }
    }
    /**
     * @author                      : MTX Group Product Team
     * @since                       : 24 Mar 2023
     * @description                 : This Method is used to Update par record with respective status
	 * @return                      : void
     * @last modified by            : MTX Group Product Team
     * @last modified date          : 24 Mar 2023
     * @modified details            : None
    */
   public static void updatePar(String applicationURL, String parId, Boolean isSubmitted, String status) {
        PreliminaryApplicationRef parToBeUpdated = new PreliminaryApplicationRef();
        parToBeUpdated.Id = parId;
        parToBeUpdated.ViewApplicationURL__c =applicationURL;
        parToBeUpdated.IsSubmitted = isSubmitted;
        parToBeUpdated.Status__c =status; 
        
        if (parToBeUpdated.Id != null) {
            LPI_WithoutSharingUtility.updateSObjectList(new List<PreliminaryApplicationRef>{parToBeUpdated});
        }
   }
    /**
     * @author                      :MTX Group Product Team
     * @since                       : 24 Mar 2023
     * @description                 : This Method is used to generate a random number
     * @param length         
	 * @return                      : `String`
     * @last modified by            : MTX Group Product Team
     * @last modified date          : 24 Mar 2023
     * @modified details            : None
    */
    public static String generateRandomNumber(Integer length) {
        String result = '';
        while(result.length() < length){
            Blob privateKey = crypto.generateAesKey(256);
            String randomString = EncodingUtil.base64Encode(crypto.generateMac(LPI_LiteralConstant.SHA_HASHING_ALGO,privateKey,privateKey));
            result += randomString.replaceAll('[^a-zA-Z0-9]','');
        }
        result = result.substring(0,length);
        return result;
    }

    /**
	 * @author              : MTX Group Product Team
	 * @param obj           : object
	 * @description         : This Method will tell us weather deserialize object is Map or not
	 * @last modified by    : MTX Group Product Team
	 * @last modified date  :
	 * @modified details    :
	 */
    private static Boolean isMap(Object obj) {
        String str, firstCharacter, lastCharacter;
        if (obj != null) {
            str = String.valueOf(obj);
            firstCharacter = str.substring(0, 1);
            lastCharacter = str.substring(str.length() - 1, str.length());
        }
        return !(obj instanceof String) && '{'.equals(firstCharacter) && '}'.equals(lastCharacter);
    }

    /**
     * IndividualInsurancePayment radio: skipPayment = yes | no (legacy true | false also supported).
     * Value may sit at root or under Payment / Payment.Block2.
     */
    private static Boolean isSkipPaymentSelected(Map<String, Object> inputMap) {
        if (inputMap == null) {
            return false;
        }
        Object skipVal = inputMap.get('skipPayment');
        if (skipVal == null && inputMap.get('Payment') instanceof Map<String, Object>) {
            Map<String, Object> paymentStep = (Map<String, Object>) inputMap.get('Payment');
            skipVal = paymentStep.get('skipPayment');
            if (skipVal == null && paymentStep.get('Block2') instanceof Map<String, Object>) {
                skipVal = ((Map<String, Object>) paymentStep.get('Block2')).get('skipPayment');
            }
        }
        return isSkipPaymentValue(skipVal);
    }

    private static Boolean isSkipPaymentValue(Object skipVal) {
        if (skipVal == null) {
            return false;
        }
        if (skipVal instanceof Boolean) {
            return (Boolean) skipVal;
        }
        String skipPaymentStr = String.valueOf(skipVal).trim();
        return String.isNotBlank(skipPaymentStr) &&
            (skipPaymentStr.equalsIgnoreCase('yes') || skipPaymentStr.equalsIgnoreCase('true'));
    }

    /**
     * ApplicantInformation:ApplicantDetails:feeExempt = Yes (or true).
     */
    private static Boolean isApplicantFeeExempt(Map<String, Object> inputMap) {
        if (inputMap == null) {
            return false;
        }
        Object applicantInfoObj = inputMap.get('ApplicantInformation');
        if (!(applicantInfoObj instanceof Map<String, Object>)) {
            return false;
        }
        Object applicantDetailsObj = ((Map<String, Object>) applicantInfoObj).get('ApplicantDetails');
        if (!(applicantDetailsObj instanceof Map<String, Object>)) {
            return false;
        }
        Object feeExemptObj = ((Map<String, Object>) applicantDetailsObj).get('feeExempt');
        if (feeExemptObj == null) {
            return false;
        }
        String feeExemptVal = String.valueOf(feeExemptObj).trim();
        return feeExemptVal.equalsIgnoreCase('Yes') || feeExemptVal.equalsIgnoreCase('true');
    }
}