import { LightningElement, api } from "lwc";
import fetchFeeSubType from "@salesforce/apex/LPI_InternalPaymentController.fetchFeeSubType";

export default class LpiFeeTypeSubtypeSelector extends LightningElement {
   @api showSpinnerParent;
   @api defaultSelectedType;
   @api defaultSelectedSubType;
   @api licenseTypeId;
   @api boardName;
   @api authorisationType;
   error;
  
   applicationTypeList;
   applicationSubTypeList = [];
   showSpinner = false;
   isSubTypeDisabled = false;
   typeOfApplication;
   subTypeOfApplication;
   applicationType;
   applicationSubType;

   connectedCallback() {
       this.applicationType = this.defaultSelectedType;
       this.searchKeyType = this.applicationType;
      
       //Image()
       const appType = new CustomEvent("getapplicationtype", { detail: this.applicationType });
       this.dispatchEvent(appType);
       fetchFeeSubType({ selectedType: this.applicationType, licenseType: this.licenseTypeId })
           .then((result) => {
               this.applicationSubTypeList = result;
               if(this.defaultSelectedType != 'New' && (result.length == 1 || this.defaultSelectedType == 'Amendment')){
                   this.isSubTypeDisabled = true;
                   this.searchKeySubType = this.defaultSelectedSubType;
               } else {
                   this.isSubTypeDisabled = false;
               }
           })
           .catch((error) => {
               this.error = error;
           });
   }

   get isTypeDisabled() {
       return (
           this.defaultSelectedType !== "" &&
           this.defaultSelectedType !== null &&
           this.defaultSelectedType !== undefined
       );
   }

   handleChangeForSubType(event) {
       this.applicationSubType = event.detail.value;
       const appSubType = new CustomEvent("getapplicationsubtype", { detail: this.applicationSubType });
       this.dispatchEvent(appSubType);
   }

   handleSelectForType() {
       const appType = new CustomEvent("getapplicationtype", { detail: this.applicationType });
       this.dispatchEvent(appType);
   }

   @api inputValidationOfChild(){
       let applicationSubType = this.template.querySelector(".targetApplicationSubtype");
       let feeType = applicationSubType.value;
       if (feeType == null) {
           applicationSubType.setCustomValidity("Error : Please select application subType");
           applicationSubType.reportValidity();
           return false;
       }else{
           applicationSubType.setCustomValidity("");
           applicationSubType.reportValidity();
           return true;
       }
   }
}