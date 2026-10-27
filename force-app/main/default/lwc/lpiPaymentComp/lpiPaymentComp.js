import { LightningElement, api, track, wire } from "lwc";
import { NavigationMixin, CurrentPageReference } from "lightning/navigation";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import createPAR from "@salesforce/apex/LPI_InternalRegistration.createPAR";
import checkApplyLicense from "@salesforce/apex/LPI_InternalRegistration.checkApplyLicense";
import fetchFeeFromRat from "@salesforce/apex/LPI_InternalPaymentController.fetchFeeFromRat";
import fetchAdditionalFeeTypeFromRat from "@salesforce/apex/LPI_InternalPaymentController.fetchAdditionalFeeTypeFromRat";
import fetchPaymentType from "@salesforce/apex/LPI_InternalPaymentController.fetchPaymentType";
import fetchProcess from "@salesforce/apex/LPI_InternalPaymentController.fetchProcess";
import fetchExceptionReason from "@salesforce/apex/LPI_InternalPaymentController.fetchExceptionReason";
import saveDetails from "@salesforce/apex/LPI_InternalPaymentController.saveDetails";
import checkPARExistInDraftOrNot from "@salesforce/apex/LPI_InternalPaymentController.checkPARExistInDraftOrNot";
import checkExemptedOrNot from "@salesforce/apex/LPI_InternalPaymentController.checkExemptedOrNot";
import fetchApplicationIdForNav from "@salesforce/apex/LPI_InternalPaymentController.fetchApplicationIdForNav";
import getLicenseDetail from "@salesforce/apex/LPI_InternalPaymentController.getLicenseDetail";
import allowResume from '@salesforce/apex/LPI_ApplicationViewController.allowResume';
import getApplicationData from '@salesforce/apex/LPI_ApplicationActionsController.getApplicationData';
import { loadStyle } from "lightning/platformResourceLoader";
import LPI_InternalCSS from "@salesforce/resourceUrl/LPI_Design";
import {
    buildOmniLwcName,
    resolveOmniLanguageCode
} from 'c/lpLanguageUtils';

export default class LpiPaymentComp extends NavigationMixin(LightningElement) {
   @api licenseTypeId;
   @api recordId;
   @api defaultType;
   @api defaultSubType;
   @api blId;
   @api additionalLicenseType;
   @api changeStatusAmendmentSubType;
   @api identificationCardId;
   @api applicationId;
   @api licenseName;
   @track process = 'CRR';
   @track applicationType;
   @track applicationSubType;
   @track paymentTypeOptions = [];
   @track processTypeOptions = [];
   @track exemptionReasonOptions = [];
   i = 0;
   totalFeeAmount = 0;
   remainingAmount = 0;
   dataObj = {};
   @track feeList = [];
   @track underPaymentFeeList = [];
   @track feeTypeOptions = [];
   @track orignalFeeTypeOptions = [];
   feeAmount;
   openAddFeeModal = false;
   showSpinner = false;
   isDisabled = true;
   isUnderPaymentModalOpen = false;
   selectTypeSubtype;
   paidBySomeoneOtherCondition;
   additionalFeeTypeName;
   Id;
   parId;
   showReadonlyText;
   objectCode;
   readOnlyText;
   rowId;
   minAmountToBeEntered = "";
   maxAmountToBeEntered = "";
   isrequired = true;
   exemptValue = false;
   isExempted = true;
   exemptionExpiryDate;
   checkNumberRequired = true;
   showTypeSubtypeComp = false;
   licenseNumber;
   licenseeName;
   boardName;
   authorisationType;
   @track applicationData;
   @track buttonList;
   _hasInitialized = false;

   @wire(CurrentPageReference)
   handlePageRef(pageRef) {
       if (!pageRef) {
           return;
       }
       this.applyPageState(pageRef.state);
       this.tryInitialize();
   }

   applyPageState(state) {
       if (!state) {
           return;
       }
       this.licenseTypeId = this.getStateValue(state, "c__licenseTypeId", this.licenseTypeId);
       this.recordId = this.getStateValue(state, "c__recordId", this.recordId);
       this.defaultType = this.getStateValue(state, "c__defaultType", this.defaultType);
       this.defaultSubType = this.getStateValue(state, "c__defaultSubType", this.defaultSubType);
       this.blId = this.getStateValue(state, "c__blId", this.blId);
       this.additionalLicenseType = this.getStateValue(state, "c__additionalLicenseType", this.additionalLicenseType);
       this.changeStatusAmendmentSubType = this.getStateValue(state, "c__changeStatusAmendmentSubType", this.changeStatusAmendmentSubType);
       this.identificationCardId = this.getStateValue(state, "c__identificationCardId", this.identificationCardId);
       this.applicationId = this.getStateValue(state, "c__applicationId", this.applicationId);
       this.licenseName = this.getStateValue(state, "c__licenseName", this.licenseName);
   }

   getStateValue(state, key, fallback) {
       const value = state[key];
       return value !== undefined && value !== null && value !== "" ? value : fallback;
   }

   tryInitialize() {
       if (!this._hasInitialized && this.licenseTypeId) {
           this._hasInitialized = true;
           this.initializePaymentPage();
       }
   }

   connectedCallback() {
       loadStyle(this, LPI_InternalCSS + "/styles/internal-main.css");
       this.selectTypeSubtype = true;
       this.tryInitialize();
   }

   initializePaymentPage() {
       this.showSpinner = true;
       this.applicationType = this.defaultType;
       this.applicationSubType = this.defaultSubType;
       // Fetch Fee Type Options for Adding Additional Fee
       fetchAdditionalFeeTypeFromRat({ ratId: this.licenseTypeId })
           .then((result) => {
               this.orignalFeeTypeOptions = result;
               let i;
               for (i = 0; i < result.length; i++) {
                   if(result[i].Name != 'Underpayment'){
                       const option = {
                           label: result[i].Name,
                           value: result[i].Name
                       };
                       this.feeTypeOptions = [...this.feeTypeOptions, option];
                   }
               }
           })
           .catch((error) => {
               this.dispatchEvent(
                   new ShowToastEvent({
                       title: "Error",
                       message: "Problem in fetching fee type! " + JSON.stringify(error),
                       variant: "error"
                   })
               );
           }).finally(() => {
               this.showSpinner = false;
           });
       // Fetch Payment Type Options for Payment Information
       this.showSpinner = true;
       fetchPaymentType()
           .then((result) => {
               this.paymentTypeOptions = result;
           })
           .catch((error) => {
               this.dispatchEvent(
                   new ShowToastEvent({
                       title: "Error",
                       message: "Problem in fetching payment type! " + JSON.stringify(error),
                       variant: "error"
                   })
               );
           }).finally(() => {
               this.showSpinner = false;
           });


       // Fetch Process Options for Payment Information
       this.showSpinner = true;
       fetchProcess()
           .then((result) => {
               this.processTypeOptions = result;
           })
           .catch((error) => {
               this.dispatchEvent(
                   new ShowToastEvent({
                       title: "Error",
                       message: "Problem in fetching process! " + JSON.stringify(error),
                       variant: "error"
                   })
               );
           }).finally(() => {
               this.showSpinner = false;
           });


       this.showSpinner = true;
       fetchExceptionReason()
           .then((result) => {
               this.exemptionReasonOptions = result;
           })
           .catch((error) => {
               this.dispatchEvent(
                   new ShowToastEvent({
                       title: "Error",
                       message: "Problem in fetching process! " + JSON.stringify(error),
                       variant: "error"
                   })
               );
           }).finally(() => {
               this.showSpinner = false;
           });


       if(this.blId !== null && this.blId !== undefined){
           this.showSpinner = true;
           getLicenseDetail({recordId: this.blId}).then((result)=>{
               this.licenseNumber = result.licenseNumber;
               this.licenseeName = result.licenseeName;
               this.boardName = result.boardName
               this.authorisationType = result.authorisationType
           }).catch((error) => {
               this.dispatchEvent(
                   new ShowToastEvent({
                       title: "Error",
                       message: "Problem in fetching License Details! " + JSON.stringify(error),
                       variant: "error"
                   })
               );
           }).finally(() => {
               this.showTypeSubtypeComp = true;
               this.showSpinner = false;
           });
       } else {
           this.showTypeSubtypeComp = true;
       }
   }


   get showLicenseDetails(){
       return this.licenseNumber !== null &&  this.licenseNumber !== undefined;
   }


   openAddFeeModalWindow() {
       this.openAddFeeModal = true;
       this.showReadonlyText = false;
       this.feeAmount = 0;
       this.rowId = null;
   }


   closeAddFeeModalWindow() {
       this.openAddFeeModal = false;
   }


   // getting type of an Application from Child Component (modprFeeTypeSubtypeSelector)
   handleApplicationType(event) {
       this.applicationType = event.detail;
   }


   // getting Subtype of an Application from Child Component (modprFeeTypeSubtypeSelector)
   handleApplicationSubType(event) {
       this.applicationSubType = event.detail;
   }


   // creating PAR when User click on Next Button
   createParRecord() {
       let child = this.template.querySelector("c-lpi-fee-type-subtype-selector");
       child.inputValidationOfChild();
       if (child.inputValidationOfChild() === true) {
           this.showSpinner = true;
           checkApplyLicense({
               regAuthId: this.licenseTypeId,
               accountId: this.recordId,
               type: this.applicationType,
               subtype: this.applicationSubType,
               blId: this.blId,
               icId: this.identificationCardId
           })
               .then((result) => {
                   if (result === "false") {
                       const paramsMap = { accountId: this.recordId,
                                           licenseId: this.licenseTypeId,
                                           type: this.applicationType,
                                           subtype: this.applicationSubType,
                                           changeStatusAmendmentSubType: this.changeStatusAmendmentSubType,
                                           additionalLicenseType: this.additionalLicenseType,
                                           blId: this.blId,
                                           icId: this.identificationCardId,
                                           applicationId: this.applicationId
                                       };
                       createPAR({ paramsMap: JSON.stringify(paramsMap) })
                           .then((parResult) => {
                               this.parId = parResult;
                               this.dataObj.parId = this.parId;
                               this.selectTypeSubtype = false;
                               this.showSpinner = false;
                               this.updateFeeDetailsOnUI();
                              
                               // if type not equal to new then fetch Exemption Date from Business license using PAR
                               checkExemptedOrNot({parId: this.parId,type : this.applicationType})
                                   .then((ExemptResult)=>{
                                       if(ExemptResult!= null)
                                       {
                                           this.exemptionExpiryDate  = ExemptResult;
                                           const today = new Date();
                                           const exemptionExDate = new Date(this.exemptionExpiryDate);
                                           if(exemptionExDate < today)
                                           {
                                                   this.isExempted = true;
                                           }else{
                                                   this.isExempted = false;                   
                                           }
                                       }
                                      
                                   }).catch((error)=>{
                                       this.dispatchEvent(
                                           new ShowToastEvent({
                                               title: "Error",
                                               message: "Problem in checking Exemption Logic" + JSON.stringify(error),
                                               variant: "error"
                                           })
                                       );
                                   })
                           })
                           .catch((error) => {
                               this.showSpinner = false;
                               this.error = true;
                               this.dispatchEvent(
                                   new ShowToastEvent({
                                       title: "Error",
                                       message: "Problem in creating PAR! " + JSON.stringify(error),
                                       variant: "error"
                                   })
                               );
                           });
                   } else {
                       this.showMessage(
                           "Info",
                           "Oops! It seems that a duplicate application has been created. Please revisit this page by clicking the cancel button." +
                               ""
                       );
                       this.showSpinner = false;
                   }
               })
               .catch((error) => {
                   this.showSpinner = false;
                   this.error = true;
                   this.dispatchEvent(
                       new ShowToastEvent({
                           title: "Error",
                           message: "Problem in checking validation of an application " + JSON.stringify(error),
                           variant: "error"
                       })
                   );
               });
          
          
       }
   }


   // Update Fee details on UI according to PAR
   updateFeeDetailsOnUI() {
       this.showSpinner = true;
       let sum = 0;
       fetchFeeFromRat({ ratId: this.licenseTypeId, type: this.applicationType, subtype: this.applicationSubType ,parId : this.parId })
           .then((result) => {
               this.feeList = JSON.parse(JSON.stringify(result));
               console.log("feelist -- "+this.feeList);
               this.feeList.forEach((row) => {
                   sum += row.Amount;
                   console.log('sum == '+sum);
                   this.totalFeeAmount = sum;
               });
               this.showSpinner = false;          
               if(this.totalFeeAmount !== 0)
               {
                   this.isrequired = true;
                   this.remainingAmount = this.totalFeeAmount;
               }else{
                   this.isrequired = false;
               }
               console.log('total fee amount --> '+this.totalFeeAmount);
               console.log('remaining amount --> '+this.remainingAmount);
           })
           .catch((error) => {
               this.error = true;
           });
   }


   handleChange(event) {
       if(event.target.name === "paymentType"){
           if(event.target.value === "Cash")
           {
               this.checkNumberRequired = false;
           }
           else{
               this.checkNumberRequired = true;
           }
       }
       if (event.target.name === "paidBySomeoneOther") {
           this.dataObj.paidBySomeoneOther = event.target.checked;
           if (this.dataObj.paidBySomeoneOther === true) {
               this.paidBySomeoneOtherCondition = true;
           } else {
               this.paidBySomeoneOtherCondition = false;
               this.dataObj.payerName = null;
               this.dataObj.payerPhone = null;
           }
       } else {
           const rawValue = event.target.value;
           this.dataObj[event.target.name] = typeof rawValue === "string" ? rawValue.trim() : rawValue;
           if (event.target.name === "amountTendered") {
               this.remainingAmount = this.totalFeeAmount - Number(this.dataObj.amountTendered);
           }
       }
   }


   // Fetch Options picklist of Additional Fee Type
   handleAdditionalFeeTypeChange(event) {
       let updatedList = this.orignalFeeTypeOptions.filter((element) => element.Name === event.target.value);
       if (updatedList.length > 0) {
           this.feeAmount = updatedList[0].Amount;
           this.objectCode = updatedList[0].objectCode;
       }


       this.additionalFeeTypeName = event.target.value;
       if (this.feeAmount === 0) {
           this.isDisabled = false;
       } else {
           this.isDisabled = true;
       }


       //Setting the min amount and max amount that anyone can enter
       if (this.additionalFeeTypeName !== "Underpayment") {
           this.minAmountToBeEntered = 0;
           this.maxAmountToBeEntered = 999999;
       } else {
           this.minAmountToBeEntered = "";
           this.maxAmountToBeEntered = "";
       }
   }


   handleAmountChange(event) {
       this.feeAmount = Number(event.target.value);
       if (
           ((!this.showReadonlyText && this.additionalFeeTypeName === "Underpayment") ||
               (this.showReadonlyText && this.readOnlyText === "Underpayment")) &&
           this.feeAmount > 0
       ) {
           this.feeAmount = -this.feeAmount;
       }
   }


   saveAddFeeDetails() {
       let targetFeeAmount = this.template.querySelector(".targetFeeAmount");
       let feeTypePicklist = this.template.querySelector(".targetFeeType");
       //If Amount is not valid
       if (!targetFeeAmount.reportValidity()) {
           return;
       }
       //if FeeType is not valid
       if (feeTypePicklist !== null && feeTypePicklist !== undefined && !feeTypePicklist.reportValidity()) {
           return;
       }


       //For New Record creation
       if (this.rowId == null) {
           let data = {
               Amount: this.feeAmount,
               disableMenu: true,
               Id: this.feeList.length,
               Name: this.additionalFeeTypeName,
               objectCode: this.objectCode
           };
           // this.totalFeeAmount += this.feeAmount;
          
           this.feeList.push(data);
           this.totalFeeAmount = 0;
           for(let i = 0; i<this.feeList.length ;i++)
           {
               this.totalFeeAmount += this.feeList[i].Amount;
           }  
       }
       //For Record Edit
       else {
           this.totalFeeAmount = 0;
           // this.totalFeeAmount -= this.feeList[this.rowId].Amount;
           // this.totalFeeAmount += this.feeAmount;
           this.feeList[this.rowId].Amount = this.feeAmount;
           for(let i = 0; i<this.feeList.length ;i++)
           {
               this.totalFeeAmount += this.feeList[i].Amount;
           }  
          
       }


       if (this.dataObj.amountTendered != null) {
           this.remainingAmount = this.totalFeeAmount - this.dataObj.amountTendered;
       } else {
           this.remainingAmount = this.totalFeeAmount;
       }
       this.openAddFeeModal = false;
       if (this.totalFeeAmount === 0) {
           this.isrequired = false;
       } else {
           this.isrequired = true;
       }
       this.exemptValue = false;
   }


   deleteFeeDetails(event) {
       var selectedRowId = event.target.dataset.id;
       this.totalFeeAmount = this.totalFeeAmount - this.feeList[selectedRowId].Amount;
       this.feeList.splice(selectedRowId, 1);
       let newFeeList = this.feeList;


       for (let i = 0; i < newFeeList.length; i++) {
           newFeeList[i].Id = i;
       }
       this.feeList = newFeeList;
       // Updating Remaining Amount
       if (this.dataObj.amountTendered != null) {
           this.remainingAmount = this.totalFeeAmount - this.dataObj.amountTendered;
       } else {
           this.remainingAmount = this.totalFeeAmount;
       }
   }


   editFeeDetails(event) {
       this.rowId = event.target.dataset.id;
       this.openAddFeeModal = true;


       this.showReadonlyText = true;
       this.feeAmount = this.feeList[this.rowId].Amount;
       this.readOnlyText = this.feeList[this.rowId].Name;
       this.isDisabled = false;


       //Setting the min amount and max amount that anyone can enter
       if (this.readOnlyText === "Underpayment") {
           this.minAmountToBeEntered = "";
           this.maxAmountToBeEntered = 0;
       } else {
           this.minAmountToBeEntered = 0;
           this.maxAmountToBeEntered = "";
       }
   }


   handleSubmit() {
       if (this.isInputValid()) {
           this.showSpinner = true;
           if (this.remainingAmount < 0) {
               this.dispatchEvent(
                   new ShowToastEvent({
                       title: "Problem",
                       message: "Balance out the Fees, discrepancy found!",
                       variant: "error"
                   })
               );
               this.showSpinner = false;
           } else {
               this.underPaymentFeeList = [];
               this.feeList.forEach( element => {
                   element.actualAskedAmount = element.Amount;
                   let clonedElement = Object.assign({}, element);
                   clonedElement.pendingPaymentAmount = 0;
                   this.underPaymentFeeList.push(clonedElement);
               });
               if(this.remainingAmount !== 0){
                   this.isUnderPaymentModalOpen = true;
                   let leftAmount = -this.remainingAmount;
                   this.underPaymentFeeList.every(function(element) {
                       element.Amount = element.Amount + leftAmount;
                       if(element.Amount < 0){
                           leftAmount = element.Amount;
                           element.Amount = 0;
                           element.pendingPaymentAmount = element.actualAskedAmount - element.Amount;
                           return true;
                       } else {
                           element.pendingPaymentAmount = element.actualAskedAmount - element.Amount;
                           return false;
                       }
                   });
                   //this.feeList[0].Amount = this.feeList[0].Amount - this.remainingAmount;
                   this.showSpinner = false;
               } else {
                   this.saveDataInDatabase(this.feeList);
               }              
           }
       }
   }


   handleUnderPaymentConform(){
       this.showSpinner = true;
       this.saveDataInDatabase(this.underPaymentFeeList);
   }


   saveDataInDatabase(feeList){
       saveDetails({
           feeList: JSON.stringify(feeList),
           paymentInformation: JSON.stringify(this.dataObj),
           accountId: this.recordId,
           remainingAmount: this.remainingAmount
       })
           .then((result) => {
               this.hasError = false;
               if (result) {
                   fetchApplicationIdForNav({
                       licenseTypeId: this.licenseTypeId,
                       accId: this.recordId,
                       applicationType: this.applicationType,
                       applicationSubType: this.applicationSubType
                   })
                       .then((resultNew) => {
                           this.handleNavigation(resultNew);
                       })
                       .catch((errorNew) => {
                           if (typeof errorNew.body.message === "string") {
                               this.dispatchEvent(
                                   new ShowToastEvent({
                                       title: "Error",
                                       message: errorNew.body.message,
                                       variant: "error"
                                   })
                               );
                           }
                       }).finally(() =>{
                           this.showSpinner = false;
                       });
               }
           })
           .catch((error) => {
               if (typeof error.body.message === "string") {
                   this.dispatchEvent(
                       new ShowToastEvent({
                           title: "Error",
                           message: error.body.message,
                           variant: "error"
                       })
                   );
               }
               this.showSpinner = false;
           });
   }


   handleNavigation(resultNew){
       if(resultNew){
           this.handleLoad(resultNew);


       } else {
           if (this.blId) {
               this.navigateToBlRecordPage();
           } else {
               this.navigateToViewAccountPage();
           }
       }
   }


   handleLoad(resultNew) {
       let resultArr = resultNew.split('-');
       getApplicationData({ recordId: resultArr[1] })
           .then((response) => {
               this.applicationData = response.applicationData;
               this.buttonList = response.buttonList;
               this.handleResumeApplication(this.buttonList[1],resultArr);
           })
           .catch((error) => {
               this.dispatchEvent(
                   new ShowToastEvent({
                       title: "Error",
                       message: error,
                       variant: "error"
                   })
               );
           })
           .finally(()=>{
           })
   }


   handleResumeApplication(buttonDetail,applicationData){
       if (applicationData == undefined) {
           return;
       }
       this.showSpinner = true;
       allowResume({ applicationId : applicationData[1]} )
       .then((result) => {
           if(result){
               const buttonJSON = JSON.parse(buttonDetail.buttonData);
               let type = buttonJSON['osType'];
               let subtype = buttonJSON['osSubType'];
               let language = buttonJSON['osLanguage'];
               let omniScriptName = buildOmniLwcName(type, subtype, language);
               this[NavigationMixin.Navigate]({
                   type: "standard__component",
                   attributes: {
                       componentName: "omnistudio__vlocityLWCOmniWrapper"
                   },
                   state: {
                       c__target: "c:" + omniScriptName,
                       c__layout: "lightning",
                       c__tabIcon: "custom:custom18",
                       c__tabLabel: "Apply for license",
                       c__accountId: this.applicationData.accountId,
                       c__ContextId: this.applicationData.licenceTypeId,
                       c__portalUser: "false",
                       c__parid: this.applicationData.parId,
                       c__blId: this.applicationData.licenceId,
                       c__language: resolveOmniLanguageCode()
                   }
               });
           }else{
               this[NavigationMixin.Navigate]({
                   type: "standard__recordPage",
                   attributes: {
                       recordId: applicationData[1],
                       objectApiName: applicationData[0],
                       actionName: "view"
                   }
               });
           }
       })
       .catch((error) => {
           const event = new ShowToastEvent({
               title: 'Error',
               message: 'Something went wrong! '+ error,
               variant: 'error',
           });
           this.dispatchEvent(event);
       }).finally(() => {
           this.showSpinner = false;
       });
   }


   closeUnderPaymentModal() {
       this.isUnderPaymentModalOpen = false;
       this.showSpinner = false;
   }






   handleAppTypeSubtypeSelectionCancel() {
       this.showSpinner = true;
       checkPARExistInDraftOrNot({
           accountId: this.recordId,
           licenseId: this.licenseTypeId
       })
           .then((result) => {
               this.showSpinner = false;
               if (result === true) {
                   if (this.blId) {
                       this.navigateToBlRecordPage();
                   } else if(this.applicationId){
                       this.navigateToIARecordPage();
                   } else {
                       this.navigateToViewAccountPage();
                   }
               }
           })
           .catch((error) => {
               this.showSpinner = false;
               if (typeof error.body.message === "string") {
                   this.dispatchEvent(
                       new ShowToastEvent({
                           title: "Error",
                           message: error.body.message,
                           variant: "error"
                       })
                   );
               }
           });
   }


   navigateToViewAccountPage() {
       this[NavigationMixin.Navigate]({
           type: "standard__recordPage",
           attributes: {
               recordId: this.recordId,
               objectApiName: "Account",
               actionName: "view"
           }
       });
   }
   navigateToBlRecordPage() {
       this[NavigationMixin.Navigate]({
           type: "standard__recordPage",
           attributes: {
               recordId: this.blId,
               objectApiName: "BusinessLicense",
               actionName: "view"
           }
       });
   }


   showMessage(title, message, variant, mode) {
       const toastEvt = new ShowToastEvent({
           title,
           message,
           variant,
           mode
       });
       this.dispatchEvent(toastEvt);
   }


   isInputValid() {
       let isValid = true;
       let inputFields = this.template.querySelectorAll(".validate");
       inputFields.forEach((inputField) => {
           if (!inputField.checkValidity()) {
               inputField.reportValidity();
               isValid = false;
           }
       });
       return isValid;
   }


   handleExemptChange(event) {
       this.exemptValue = event.target.checked;
       this.dataObj.exempt = event.target.checked;
       if (this.exemptValue === true) {
           this.totalFeeAmount = 0;
           this.remainingAmount = 0; //added for I-265078
           this.isrequired = false;
       }
       else{
           this.isrequired = true;
           this.totalFeeAmount = 0;
           for(let i = 0; i<this.feeList.length ;i++)
           {
               this.totalFeeAmount += this.feeList[i].Amount;
           }      
       }
   }


   get getTotalFeeAmount() {
       var formattedNumber = this.totalFeeAmount.toFixed(2);
       console.log('formatted number -- '+formattedNumber);
       return formattedNumber;
   }


   navigateToIARecordPage() {
       this[NavigationMixin.Navigate]({
           type: "standard__recordPage",
           attributes: {
               recordId: this.applicationId,
               objectApiName: "IndividualApplication",
               actionName: "view"
           }
       });
   }
   //matching = isMatch($String,'^[a-zA-Z0-9.]*$');check for transaction Id matching /Ankur
   }