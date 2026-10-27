import { LightningElement,api,track } from 'lwc';
import { OmniscriptActionCommonUtil } from "omnistudio/omniscriptActionUtils";
import { OmniscriptBaseMixin } from 'omnistudio/omniscriptBaseMixin';
import { getNamespaceDotNotation } from "omnistudio/omniscriptInternalUtils";


export default class RatAmendmentTypePicklist extends OmniscriptBaseMixin(LightningElement){
        @api recordId;

        _actionUtil;
        _ns = getNamespaceDotNotation();

        options = [];
        values = [];
        @track amendmentTypeOption;
        @track selectedOptionsList;
        @track selectedAmendtype;
        @track statusChangeOptions;
        isLoading = true;
        selectedStatus;
        //Added By Rahul to make the solution dynamic
        @track licenseTypeOption = [];
        selectedLicenseType;
        CONSTANT = {OBTAIN_ADDITIONAL_LICENSE : 'Obtain Additional License',
                    CHANGE_STATUS_TO_OTHER :  'Change status to other status'};

        get isStatusChange() {
            return this.selectedAmendtype == this.CONSTANT.CHANGE_STATUS_TO_OTHER;
        }

        get isObtainLiceseSelected() {
            return this.selectedAmendtype == this.CONSTANT.OBTAIN_ADDITIONAL_LICENSE;
        }

        
        connectedCallback() {
            this._actionUtil = new OmniscriptActionCommonUtil();
            this.init();
        }


        init(){
            const params = {
                input: JSON.stringify(this.omniJsonData),
                sClassName: 'GetAmendmentType',
                sMethodName: 'getAmendType', 
                options: '{}',
            };
    
            this._actionUtil
            .executeAction(params, null, this, null, null)
            .then(response => {
                this.amendmentTypeOption = response.result.amendmentTypeList;
                console.log('this.amendmentTypeOption',JSON.stringify(this.amendmentTypeOption));
                this.isLoading = false;
            })
            .catch(error => {
                this.showMessage('Error occured while Loading. ', error.body.message, 'error', 'pester');
            });
        }


        /** 
         * @author         : Rachna Jadam
         * @since          : November 28, 2022
         * @description    : This method will call on 'statusChange' value change
        */
        handleStatusChangeOptions(event) {
            this.selectedStatus = event.detail.value;
        }


        handleChange(event){
            this.selectedAmendtype = event.detail.value;
            this.onAmendmentTypeChange( this.selectedAmendtype);
        }

        handleClick(event){
            let selectedValuesList = {
                selectedValue : this.selectedAmendtype,
                selectedStatus : this.selectedStatus,
                selectedAddLicenseType : this.selectedLicenseType
            };
            
            if(this.validateInputFields() && this.selectedAmendtype != null){
                this.omniUpdateDataJson(selectedValuesList);
                this.omniNextStep();
            }

        }

        validateInputFields() {
            let isAllValid = [
                ...this.template.querySelectorAll('lightning-radio-group')
            ].reduce((validSoFar, inputCmp) => {
                inputCmp.reportValidity();
                return validSoFar && inputCmp.checkValidity();
            }, true);
            let allInput = this.template.querySelector(".slds-has-error");
            if (allInput) {
                allInput.scrollIntoView();
                allInput.focus();
            }
		
            return isAllValid
    
        }


        /** 
         * @author         : Rahul Ameta
         * @since          : December 07, 2022
         * @description    : This method will define what depended picklist values will be fetched
         */
        onAmendmentTypeChange(amendmentType){
            if(amendmentType == this.CONSTANT.CHANGE_STATUS_TO_OTHER){
                this.getStatusChangeOptions();
            }else if(amendmentType ==  this.CONSTANT.OBTAIN_ADDITIONAL_LICENSE){
                this.getOptionList('Additional_License_Type__c');
            }
        }


        /** 
         * @author         : Rachna Jadam
         * @since          : November 28, 2022
         * @description    : This method will call GetAmendmentType.getStatusChangeOptions() and get 
         *                  picklist options of PreliminaryApplicationRef.Change_Status_to__c field
        */
         getStatusChangeOptions() {
            this.isLoading = true;
            const params = {
                input: JSON.stringify(this.omniJsonData),
                sClassName: 'GetAmendmentType',
                sMethodName: 'getStatusChangeOptions', 
                options: '{}',
            };
    
            this._actionUtil
            .executeAction(params, null, this, null, null)
            .then(response => {
                this.statusChangeOptions = response.result.statusChangeOptions;
                this.isLoading = false;
            })
            .catch(error => {
                this.showMessage('Error occured while Loading. ', error.body.message, 'error', 'pester');
            });
        }

         /** 
         * @author         : Rahul Ameta
         * @since          : December 07, 2022
         * @description    : This method will get list of options for the PreliminaryApplicationRef object
         */
        getOptionList(fieldName) {
            this.isLoading = true;
             const option = {fieldName: fieldName};
            const params = {
                input: JSON.stringify(this.omniJsonData),
                sClassName: 'GetAmendmentType',
                sMethodName: 'getOptionsFromPAR', 
                options: JSON.stringify(option),
            };
    
            this._actionUtil
            .executeAction(params, null, this, null, null)
            .then(response => {
                if(fieldName == 'Additional_License_Type__c'){
                    this.licenseTypeOption = response.result.optionList;
                }
                this.isLoading = false;
            })
            .catch(error => {
                this.showMessage('Error occured while Loading. ', error.body.message, 'error', 'pester');
            });
        }

         /** 
         * @author         : Rahul Ameta
         * @since          : December 07, 2022
         * @description    : On License Type radio button change
        */
        handleLicenseTypeSelection(event){
            this.selectedLicenseType = event.detail.value;
        }




    }