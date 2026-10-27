//  @author            : Saurabh singh
//  @description       : custom LWC for address type field in Personal Information step
//  @createdDate       : 17 Nov 2023
//  @last modified on  :
//  @last modified by  :

import { LightningElement, api, track } from "lwc";
import { OmniscriptBaseMixin } from "omnistudio/omniscriptBaseMixin";
import { OmniscriptActionCommonUtil } from "omnistudio/omniscriptActionUtils";
export default class LpiOverrideAddressType extends OmniscriptBaseMixin(LightningElement) {
    // ****************************************************** INSTRUCTIONS **********************************************************
    // this.omniJsonData //fetch all json from Omniscript
    // this.omniUpdateDataJson({}) // update json in Omniscript (Format of JSON not in our hand)
    // this.omniApplyCallResp({}) to change format of JSON in our own way (Format of JSON in our hand)
    // console.log('Element Name :'+this.elementname);
    // this.omniApplyCallResp({
    // 	"Step1":{
    // 		"PrimaryContactAddressBlock":{
    // 			"AddressTypePCA" : event.detail.value
    // 		}
    // 	}
    // });
    // this.omniJsonDef.name geive the element Name of Omniscript in this case ( AddressTypePCA ,AddressTypeLA , AddressTypePDA)
    // ******************************************************************************************************************************

    @api addresstypelabel;
    @api elementname;
    @api showedit;
    @api blockstructureforaddresstype;
    @api currentstepname;
    options;
    @track value;
    inputData = {};

    connectedCallback() {
        // In case parid Not present in JSON then fetch it from URL
        // var url = window.location.href;
        // var parid = this.getParameterByName(url, "c__parid");
        if (this.showedit == true) {
            this.showedit = false;
        } else {
            this.showedit = true;
        }
        /// new changes - GJ
        this._actionUtil = new OmniscriptActionCommonUtil();
        this.inputData["parId"] = this.omniJsonData.parid;
        this.inputData["addressType"] = this.addresstypelabel;

        if (this.options == null) {
            const params1 = {
                input: this.inputData,
                sClassName: "LPI_OverrideAddressType",
                sMethodName: "picklistValueOfAddressField",
                options: "{}"
            };
            this._actionUtil
                .executeAction(params1, null, this, null, null)
                .then(response => {
                    console.log('Response>>'+response);
                    let result = response.result.picklistOptions;
                    console.log('Result>>'+result);
                    this.options = result;
                })
                .catch(error => {
                    console.log("error->", error);
                });
        }
        const params2 = {
            input: this.inputData,
            sClassName: "LPI_OverrideAddressType",
            sMethodName: "fetchSavedAddressFieldOnReload",
            options: "{}"
        };
        this._actionUtil
            .executeAction(params2, null, this, null, null)
            .then(response => {
                let result = response.result.savedValues;
                if (result != null) {
                    if (this.addresstypelabel == "Primary Contact Address") {
                        console.log('addresstypelabel-->',this.addresstypelabel);
                        console.log('elementname-->',this.elementname);
                        console.log('showedit-->',this.showedit);
                        console.log('blockstructureforaddresstype-->',this.blockstructureforaddresstype);
                        console.log('currentstepname-->',this.currentstepname);
                        this.value = result;
                        this.omniUpdateDataJson({
                            AddressTypePCA: this.value
                        });
                    } else if (this.addresstypelabel == "License Address") {
                        this.value = result;
                        this.omniUpdateDataJson({
                            AddressTypeLA: this.value
                        });
                    } else if (this.addresstypelabel == "Publicly Displayed Address") {
                        this.value = result;
                        this.omniUpdateDataJson({
                            AddressTypePDA: this.value
                        });
                    }
                }
            })
            .catch(error => {
                console.log("error->", error);
            });

        // New changes - GJ - End

        // Case for SAVE and EXIT
        var splitedData = this.blockstructureforaddresstype != null ? this.blockstructureforaddresstype.split("-") : "";
        if (
            this.blockstructureforaddresstype != null &&
            this.omniJsonData != null &&
            this.omniJsonData[this.currentstepname] != null &&
            this.omniJsonData[this.currentstepname][splitedData[0]] != null &&
            this.omniJsonData[this.currentstepname][splitedData[0]][splitedData[1]] != null
        ) {
            this.value = this.omniJsonData[this.currentstepname][splitedData[0]][splitedData[1]][this.elementname];
        }
    }

    handleChange(event) {
        this.value = event.detail.value;
        var map;
        if (this.elementname == "AddressTypePCA") {
            map = {
                AddressTypePCA: event.detail.value
            };
        } else if (this.elementname == "AddressTypeLA") {
            map = {
                AddressTypeLA: event.detail.value
            };
        } else if (this.elementname == "AddressTypePDA") {
            map = {
                AddressTypePDA: event.detail.value
            };
        }
        this.omniUpdateDataJson(map);

        // Update validation state after selection. (Indireclty check for check validity method)
        this.omniValidate();
    }

    // Method to Fetch parid from Custom URL
    getParameterByName(url, name) {
        name = name.replace(/[\[]/, "\\[").replace(/[\]]/, "\\]");
        var regex = new RegExp("[\\?&]" + name + "=([^&#]*)");
        var results = regex.exec(url);
        return results === null ? "" : decodeURIComponent(results[1].replace(/\+/g, " "));
    }

    validateRequiredFields() {
        const isInputsCorrect = [...this.template.querySelectorAll("lightning-combobox")].reduce((validSoFar, inputField) => {
            let valid = inputField.checkValidity();
            return valid && validSoFar;
        }, true);

        return isInputsCorrect;
    }
}