import { LightningElement, api, track, wire } from "lwc";
import { OmniscriptBaseMixin } from "omnistudio/omniscriptBaseMixin";
import { OmniscriptActionCommonUtil } from "omnistudio/omniscriptActionUtils";
import { getPicklistValues, getObjectInfo } from "lightning/uiObjectInfoApi";
import ADDRESS_OBJECT from "@salesforce/schema/Address";
import AddressState from "@salesforce/schema/Address.StateCode";
import AddressCountry from "@salesforce/schema/Address.CountryCode";

export default class LpiNewCountyZipPrePopulation extends OmniscriptBaseMixin(LightningElement) {
    @track dataObj = {};
    @track inputData = {};
    @track result = {};
    @track oldResult = {};
    @track reloadresult = {};
    @track streetaddressname;
    @track countryname;
    @track statepicklistname;
    @track statetextname;
    @track zipname;
    @track cityname;
    @track countyname;
    @track countryOptions;
    @track stateOptions;
    @track error;
    @track isUS = true;
    @track isCountryRO = false;
    @track isCountryVisible = true;
    isFieldRequired = true; //Added for I-241503
    isCountyRequired = false; //Added for I-267573

    streetRequired;
    countryRequired;
    statePicklistRequired;
    stateTextRequired;
    zipRequired;
    cityRequired;
    countyRequired;

    oldelementnameofstreetaddress;
    oldelementnameofcountry;
    oldelementnameofstatepicklist;
    oldelementnameofstatetext;
    oldelementnameofzipcode;
    oldelementnameofcity;
    oldelementnameofcounty;

    @api currentstepname;
    @api locationtype;
    @api stepstructure;
    @api blockstructure;
    @api allfieldname;

    @wire(getObjectInfo, {
        objectApiName: ADDRESS_OBJECT
    })
    objectInfo;

    // GET PICKLIST VALUES OF STATE FIELD
    @wire(getPicklistValues, {
        recordTypeId: "$objectInfo.data.defaultRecordTypeId",
        fieldApiName: AddressState
    })
    wiredPicklistValues({ error, data }) {
        if (data && data.values) {
            this.stateOptions = data.values;
            this.error = undefined;
        } else if (error) {
            this.error = error;
            console.log(JSON.stringify(error));
        }
    }

    // GET PICKLIST VALUES OF COUNTRY FIELD
    @wire(getPicklistValues, {
        recordTypeId: "$objectInfo.data.defaultRecordTypeId",
        fieldApiName: AddressCountry
    })
    wiredCountryPicklistValues({ error, data }) {
        if (data && data.values) {
            this.countryOptions = data.values;
            this.error = undefined;
        } else if (error) {
            this.error = error;
            console.log(JSON.stringify(error));
        }
    }

    connectedCallback() {
        console.log('-----====connectedcallback');
        // Setting up old element name of fields in OS as variables
        if (this.allfieldname != null && this.allfieldname != undefined) {
            var allfields = this.allfieldname.split("-");
            for (let i = 0; i < allfields.length; i++) {
                if (i == 0) {
                    // Street Address
                    this.oldelementnameofstreetaddress = allfields[i];
                } else if (i == 1) {
                    // Country
                    this.oldelementnameofcountry = allfields[i];
                } else if (i == 2) {
                    // State Picklist
                    this.oldelementnameofstatepicklist = allfields[i];
                } else if (i == 3) {
                    // State Text
                    this.oldelementnameofstatetext = allfields[i];
                } else if (i == 4) {
                    // Zipcode
                    this.oldelementnameofzipcode = allfields[i];
                } else if (i == 5) {
                    // City
                    this.oldelementnameofcity = allfields[i];
                } else if (i == 6) {
                    // County
                    this.oldelementnameofcounty = allfields[i];
                }
            }
        }

        // Creating unique Name for all fields
        this.streetaddressname = this.locationtype + this.oldelementnameofstreetaddress;
        this.countryname = this.locationtype + this.oldelementnameofcountry;
        this.statepicklistname = this.locationtype + this.oldelementnameofstatepicklist;
        this.statetextname = this.locationtype + this.oldelementnameofstatetext;
        this.zipname = this.locationtype + this.oldelementnameofzipcode;
        this.cityname = this.locationtype + this.oldelementnameofcity;
        this.countyname = this.locationtype + this.oldelementnameofcounty;

        // checking country is readonly or not
        this._actionUtil = new OmniscriptActionCommonUtil();
        this.inputData["parId"] = this.omniJsonData.parid;
        this.inputData["stepName"] = this.currentstepname;
        this.inputData["stepNameAndElementName"] = this.currentstepname + this.oldelementnameofcountry;
        const params2 = {
            input: this.inputData,
            sClassName: "LPI_CountyZipPrepopulationController",
            sMethodName: "checkfieldVisibility",
            options: "{}"
        };
        this._actionUtil
            .executeAction(params2, null, this, null, null)
            .then(response => {
                if (response.result != null && response.result.checkfieldVisibility != null) {
                    let resultResponse = response.result.checkfieldVisibility;
                    if (resultResponse.isCountryRO == true) {
                        this.isCountryRO = true;
                    }
                    if (resultResponse.isCountryVisible == false) {
                        this.isCountryVisible = false;
                    } else {
                        this.isCountryVisible = true;
                    }
                }
            })
            .catch(error => {
                this.error = error;
                console.error("An unexpected error occurred in checkReadOnlyField Method:", error);
            });

        // Fetching data from omnisavedState and prepopulate on UI
        let key = "customLwcKey";
        const state = this.omniGetSaveState(key);

        // Setting up default value of country and state Picklist
        if (this.dataObj.country == undefined || this.dataObj.country == "") {
            this.dataObj.country = "US";
            //this.dataObj.statepicklist = "MO";
        }
        this.inputData["country"] = "US";
        this.result[this.oldelementnameofcountry] = this.inputData.country;
        this.inputData["statepicklist"] = "MO";
        this.result[this.oldelementnameofstatepicklist] = this.inputData.statepicklist;
        this.omniUpdateDataJson(this.result);

        if (state != null) {
            // updating value from Omni saved state in dataObj
            this.dataObj.streetaddress = state[this.oldelementnameofstreetaddress];
            this.dataObj.county = state[this.oldelementnameofcounty];
            this.dataObj.zipcode = state[this.oldelementnameofzipcode];
            this.dataObj.city = state[this.oldelementnameofcity];
            this.dataObj.country = state[this.oldelementnameofcountry];
            if (state[this.oldelementnameofcountry] == "US") {
                this.isUS = true;
                //this.dataObj.statepicklist = state[this.oldelementnameofstatepicklist];
            } else {
                this.isUS = false;
                this.dataObj.statetext = state[this.oldelementnameofstatetext];
                //Added for I-241503
                if (this.currentstepname == "BusinessAccount") {
                    this.isFieldRequired = false;
                } else {
                    this.isFieldRequired = true;
                }
            }
            if (this.currentstepname == "PersonalInformation") {
                this.result[this.oldelementnameofcountry] = state[this.oldelementnameofcountry];
                this.result[this.oldelementnameofstatepicklist] = state[this.oldelementnameofstatepicklist];
                this.result[this.oldelementnameofstatetext] = state[this.oldelementnameofstatetext];
                this.result[this.oldelementnameofzipcode] = state[this.oldelementnameofzipcode];
                this.result[this.oldelementnameofcounty] = state[this.oldelementnameofcounty];
                this.result[this.oldelementnameofcity] = state[this.oldelementnameofcity];
                this.result[this.oldelementnameofstreetaddress] = state[this.oldelementnameofstreetaddress];
                this.omniUpdateDataJson(this.result);
            }

            // If value is not present in field help in throughing error
            this.streetRequired = state[this.streetaddressname];
            if (this.streetRequired == true) {
                this.dataObj.streetaddress = "";
                this.result[this.oldelementnameofstreetaddress] = "";
            }
            this.countyRequired = state[this.countyname];
            if (this.countyRequired == true) {
                this.dataObj.county = "";
                this.result[this.oldelementnameofcounty] = "";
            }
            this.zipRequired = state[this.zipname];
            if (this.zipRequired == true) {
                this.dataObj.zipcode = "";
                this.result[this.oldelementnameofzipcode] = "";
            }
            this.cityRequired = state[this.cityname];
            if (this.cityRequired == true) {
                this.dataObj.city = "";
                this.result[this.oldelementnameofcity] = "";
            }
            this.countryRequired = state[this.countryname];
            if (this.countryRequired == true) {
                this.dataObj.country = "";
                this.result[this.oldelementnameofcountry] = "";
            }
            if (state[this.oldelementnameofcountry] == "US") {
                this.statePicklistRequired = state[this.statepicklistname];
                if (this.statePicklistRequired == true) {
                    this.dataObj.statepicklist = "";
                    this.result[this.oldelementnameofstatepicklist] = "";
                }
            } else {
                this.stateTextRequired = state[this.statetextname];
                if (this.stateTextRequired == true) {
                    this.dataObj.statetext = "";
                    this.result[this.oldelementnameofstatetext] = "";
                }
            }

            if (this.currentstepname != "PersonalInformation") {
                this.omniUpdateDataJson(this.result);
            }

            if (this.currentstepname == "PersonalInformation") {
                var a = this.stepstructure != null ? this.stepstructure.split("-") : "";

                if (a != "") {
                    var b = this.omniJsonData[this.currentstepname];
                    for (let i = 0; i < a.length; i++) {
                        if (b == null) {
                            break;
                        }
                        b = b[a[i]];
                    }
                    if (b == null) {
                        this.zipRequired = false;
                        this.cityRequired = false;
                        this.countyRequired = false;
                        this.streetRequired = false;
                        this.countryRequired = false;
                        this.statePicklistRequired = false;
                        this.stateTextRequired = false;
                    }
                }
            }
        } else {
            // Setting up default value of country and state Picklist
            if (this.dataObj.country == undefined || this.dataObj.country == "") {
                this.dataObj.country = "US";
                //this.dataObj.statepicklist = "MO";
            }
            this.inputData["country"] = "US";
            this.result[this.oldelementnameofcountry] = this.inputData.country;
            this.inputData["statepicklist"] = "MO";
            this.result[this.oldelementnameofstatepicklist] = this.inputData.statepicklist;
            this.omniUpdateDataJson(this.result);

            // Fetching data from Backend address Object once data is saved and page is refreshed
            this._actionUtil = new OmniscriptActionCommonUtil();
            this.inputData["parId"] = this.omniJsonData.parid;
            this.inputData["addressType"] = this.locationtype;
            const params2 = {
                input: this.inputData,
                sClassName: "LPI_CountyZipPrepopulationController",
                sMethodName: "fetchSavedZipCountyCityValues",
                options: "{}"
            };
            this._actionUtil
                .executeAction(params2, null, this, null, null)
                .then(response => {
                    if (response != null && response.result != null) {
                        let resultResponse = response.result.savedValuesOfZipCountyCity;
                        this.dataObj.zipcode = resultResponse.zipcode;
                        this.dataObj.county = resultResponse.county;
                        this.dataObj.city = resultResponse.city;
                        this.dataObj.streetaddress = resultResponse.streetaddress;
                        this.dataObj.country = resultResponse.country;
                        if (resultResponse.country == "US") {
                            if (resultResponse.statepicklist != null && resultResponse.statepicklist != undefined) {
                                //this.dataObj.statepicklist = resultResponse.statepicklist;
                            }
                            this.isUS = true;
                        } else {
                            this.dataObj.statetext = resultResponse.statetext;
                            this.isUS = false;
                            //Added for I-241503
                            if (this.currentstepname == "BusinessAccount") {
                                this.isFieldRequired = false;
                            } else {
                                this.isFieldRequired = true;
                            }
                        }

                        this.result[this.oldelementnameofzipcode] = resultResponse.zipcode;
                        this.result[this.oldelementnameofcity] = resultResponse.city;
                        this.result[this.oldelementnameofcounty] = resultResponse.county;
                        this.result[this.oldelementnameofstreetaddress] = resultResponse.streetaddress;
                        this.result[this.oldelementnameofcountry] = resultResponse.country;
                        if (resultResponse.country == "US") {
                            if (resultResponse.statepicklist != null && resultResponse.statepicklist != undefined) {
                                this.result[this.oldelementnameofstatepicklist] = resultResponse.statepicklist;
                            }
                        } else {
                            this.result[this.oldelementnameofstatetext] = resultResponse.statetext;
                        }
                        this.omniUpdateDataJson(this.result);
                        let updatedJSON;
                        updatedJSON = Object.assign({}, state, this.result);
                        let mySaveState = updatedJSON;
                        let usePubSub = true;
                        this.omniSaveState(mySaveState, key, usePubSub);
                    }
                })
                .catch(error => {
                    this.error = error;
                    console.log("error->", JSON.stringify(error));
                });
        }
        // If block use to fetch the save data from backend when user hard refresh the page or click on back button

        if (
            this.currentstepname == "MailingAddressDetails" ||
            this.currentstepname == "SchoolInformation" ||
            this.currentstepname == "NURNursingProgramAdministratorInformation" ||
            this.currentstepname == "RSSchoolAdministratorInformation" ||
            this.currentstepname == "DesignatedInchargeInformation" ||
            this.currentstepname == "PersonalInformationNameAmendment" ||
            (this.currentstepname == "DesignatedBrokerDetails" &&
                this.streetRequired != true &&
                this.countryRequired != true &&
                this.statePicklistRequired != true &&
                this.stateTextRequired != true &&
                this.zipRequired != true &&
                this.cityRequired != true &&
                this.countyRequired != true) ||
            this.currentstepname == "AdminInfoAmendment" ||
            this.currentstepname == "NewLocationInformation" ||
            (this.currentstepname == "BusinessAccount" &&
                this.omniJsonData[this.currentstepname] != null &&
                this.omniJsonData[this.currentstepname].BusinessAccountEditableFieldsBlock != null &&
                this.omniJsonData[this.currentstepname].BusinessAccountEditableFieldsBlock.IsMailingAddressIsSameAsMyCurrentAddress == true)
        ) {
            this._actionUtil = new OmniscriptActionCommonUtil();
            this.inputData["parId"] = this.omniJsonData.parid;
            this.inputData["addressType"] = this.locationtype;
            const params2 = {
                input: this.inputData,
                sClassName: "LPI_CountyZipPrepopulationController",
                sMethodName: "fetchSavedZipCountyCityValues",
                options: "{}"
            };
            this._actionUtil
                .executeAction(params2, null, this, null, null)
                .then(response => {
                    if (response != null && response.result != null) {
                        let resultResponse = response.result.savedValuesOfZipCountyCity;
                        if (resultResponse.zipcode != null && resultResponse.zipcode != undefined) {
                            this.dataObj.zipcode = resultResponse.zipcode;
                            this.result[this.oldelementnameofzipcode] = resultResponse.zipcode;
                        }
                        if (resultResponse.county != null && resultResponse.county != undefined) {
                            this.dataObj.county = resultResponse.county;
                            this.result[this.oldelementnameofcounty] = resultResponse.county;
                        }
                        if (resultResponse.city != null && resultResponse.city != undefined) {
                            this.dataObj.city = resultResponse.city;
                            this.result[this.oldelementnameofcity] = resultResponse.city;
                        }
                        if (resultResponse.streetaddress != null && resultResponse.streetaddress != undefined) {
                            this.dataObj.streetaddress = resultResponse.streetaddress;
                            this.result[this.oldelementnameofstreetaddress] = resultResponse.streetaddress;
                        }
                        if (resultResponse.country != null && resultResponse.country != undefined) {
                            this.dataObj.country = resultResponse.country;
                            this.result[this.oldelementnameofcountry] = resultResponse.country;
                        }

                        if (resultResponse.country == "US" && resultResponse.country != null && resultResponse.country != undefined) {
                            if (resultResponse.statepicklist != null && resultResponse.statepicklist != undefined) {
                                //this.dataObj.statepicklist = resultResponse.statepicklist;
                                this.result[this.oldelementnameofstatepicklist] = resultResponse.statepicklist;
                            }
                            this.isUS = true;
                        } else if (resultResponse.country != "US" && resultResponse.country != null && resultResponse.country != undefined) {
                            if (resultResponse.statetext != null && resultResponse.statetext != undefined) {
                                this.dataObj.statetext = resultResponse.statetext;
                                this.isUS = false;
                                this.result[this.oldelementnameofstatetext] = resultResponse.statetext;
                                //Added for I-241503
                                if (this.currentstepname == "BusinessAccount") {
                                    this.isFieldRequired = false;
                                } else {
                                    this.isFieldRequired = true;
                                }
                            }
                        }
                        this.omniUpdateDataJson(this.result);
                        let updatedJSON;
                        updatedJSON = Object.assign({}, state, this.result);
                        let mySaveState = updatedJSON;
                        let usePubSub = true;
                        this.omniSaveState(mySaveState, key, usePubSub);
                    }
                })
                .catch(error => {
                    this.error = error;
                    console.error("An unexpected error occurred:", error);
                });
        }

        // Case for SAVE and EXIT
        var splitedData = this.blockstructure != null ? this.blockstructure.split("-") : "";
        if (
            this.blockstructure != null &&
            this.blockstructure.includes("-") &&
            this.omniJsonData != null &&
            this.omniJsonData[this.currentstepname] != null &&
            this.omniJsonData[this.currentstepname][splitedData[0]] != null &&
            this.omniJsonData[this.currentstepname][splitedData[0]][splitedData[1]] != null
        ) {
            if (
                this.omniJsonData[this.currentstepname][splitedData[0]][splitedData[1]][this.oldelementnameofstreetaddress] != null &&
                this.omniJsonData[this.currentstepname][splitedData[0]][splitedData[1]][this.oldelementnameofstreetaddress] != "" &&
                this.omniJsonData[this.currentstepname][splitedData[0]][splitedData[1]][this.oldelementnameofstreetaddress] != undefined
            ) {
                this.dataObj.streetaddress = this.omniJsonData[this.currentstepname][splitedData[0]][splitedData[1]][this.oldelementnameofstreetaddress];
                this.streetRequired = false;
            }
            if (
                this.omniJsonData[this.currentstepname][splitedData[0]][splitedData[1]][this.oldelementnameofcounty] != null &&
                this.omniJsonData[this.currentstepname][splitedData[0]][splitedData[1]][this.oldelementnameofcounty] != undefined &&
                this.omniJsonData[this.currentstepname][splitedData[0]][splitedData[1]][this.oldelementnameofcounty] != ""
            ) {
                this.dataObj.county = this.omniJsonData[this.currentstepname][splitedData[0]][splitedData[1]][this.oldelementnameofcounty];
                this.countyRequired = false;
            }
            if (
                this.omniJsonData[this.currentstepname][splitedData[0]][splitedData[1]][this.oldelementnameofcity] != null &&
                this.omniJsonData[this.currentstepname][splitedData[0]][splitedData[1]][this.oldelementnameofcity] != "" &&
                this.omniJsonData[this.currentstepname][splitedData[0]][splitedData[1]][this.oldelementnameofcity] != undefined
            ) {
                this.dataObj.city = this.omniJsonData[this.currentstepname][splitedData[0]][splitedData[1]][this.oldelementnameofcity];
                this.cityRequired = false;
            }
            if (
                this.omniJsonData[this.currentstepname][splitedData[0]][splitedData[1]][this.oldelementnameofzipcode] != null &&
                this.omniJsonData[this.currentstepname][splitedData[0]][splitedData[1]][this.oldelementnameofzipcode] != "" &&
                this.omniJsonData[this.currentstepname][splitedData[0]][splitedData[1]][this.oldelementnameofzipcode] != undefined
            ) {
                this.dataObj.zipcode = this.omniJsonData[this.currentstepname][splitedData[0]][splitedData[1]][this.oldelementnameofzipcode];
                this.zipRequired = false;
            }
            if (
                this.omniJsonData[this.currentstepname][splitedData[0]][splitedData[1]].hasOwnProperty(this.oldelementnameofstatetext) &&
                this.omniJsonData[this.currentstepname][splitedData[0]][splitedData[1]][this.oldelementnameofcountry] != "US"
            ) {
                this.isUS = false;
                if (
                    this.omniJsonData[this.currentstepname][splitedData[0]][splitedData[1]][this.oldelementnameofstatetext] != null &&
                    this.omniJsonData[this.currentstepname][splitedData[0]][splitedData[1]][this.oldelementnameofstatetext] != "" &&
                    this.omniJsonData[this.currentstepname][splitedData[0]][splitedData[1]][this.oldelementnameofstatetext] != undefined
                ) {
                    this.dataObj.statetext = this.omniJsonData[this.currentstepname][splitedData[0]][splitedData[1]][this.oldelementnameofstatetext];
                    this.stateTextRequired = false;
                }
            }
            if (
                this.omniJsonData[this.currentstepname][splitedData[0]][splitedData[1]].hasOwnProperty(this.oldelementnameofstatepicklist) &&
                this.omniJsonData[this.currentstepname][splitedData[0]][splitedData[1]][this.oldelementnameofcountry] == "US"
            ) {
                this.isUS = true;
                if (
                    this.omniJsonData[this.currentstepname][splitedData[0]][splitedData[1]][this.oldelementnameofstatepicklist] != null &&
                    this.omniJsonData[this.currentstepname][splitedData[0]][splitedData[1]][this.oldelementnameofstatepicklist] != "" &&
                    this.omniJsonData[this.currentstepname][splitedData[0]][splitedData[1]][this.oldelementnameofstatepicklist] != undefined
                ) {
                    this.dataObj.statepicklist = this.omniJsonData[this.currentstepname][splitedData[0]][splitedData[1]][this.oldelementnameofstatepicklist];
                    this.statePicklistRequired = false;
                }
            }
            if (
                this.omniJsonData[this.currentstepname][splitedData[0]][splitedData[1]][this.oldelementnameofcountry] != null &&
                this.omniJsonData[this.currentstepname][splitedData[0]][splitedData[1]][this.oldelementnameofcountry] != "" &&
                this.omniJsonData[this.currentstepname][splitedData[0]][splitedData[1]][this.oldelementnameofcountry] != undefined
            ) {
                this.dataObj.country = this.omniJsonData[this.currentstepname][splitedData[0]][splitedData[1]][this.oldelementnameofcountry];
                this.countryRequired = false;
            }
        } else if (
            this.blockstructure != null &&
            !this.blockstructure.includes("-") &&
            this.omniJsonData != null &&
            this.omniJsonData[this.currentstepname] != null &&
            this.omniJsonData[this.currentstepname][this.blockstructure] != null
        ) {
            if (
                this.omniJsonData[this.currentstepname][this.blockstructure][this.oldelementnameofstreetaddress] != null &&
                this.omniJsonData[this.currentstepname][this.blockstructure][this.oldelementnameofstreetaddress] != "" &&
                this.omniJsonData[this.currentstepname][this.blockstructure][this.oldelementnameofstreetaddress] != undefined
            ) {
                this.dataObj.streetaddress = this.omniJsonData[this.currentstepname][this.blockstructure][this.oldelementnameofstreetaddress];
                this.streetRequired = false;
            }

            if (
                this.omniJsonData[this.currentstepname][this.blockstructure][this.oldelementnameofcounty] != null &&
                this.omniJsonData[this.currentstepname][this.blockstructure][this.oldelementnameofcounty] != "" &&
                this.omniJsonData[this.currentstepname][this.blockstructure][this.oldelementnameofcounty] != undefined
            ) {
                this.dataObj.county = this.omniJsonData[this.currentstepname][this.blockstructure][this.oldelementnameofcounty];
                this.countyRequired = false;
            }

            if (
                this.omniJsonData[this.currentstepname][this.blockstructure][this.oldelementnameofcity] != null &&
                this.omniJsonData[this.currentstepname][this.blockstructure][this.oldelementnameofcity] != "" &&
                this.omniJsonData[this.currentstepname][this.blockstructure][this.oldelementnameofcity] != undefined
            ) {
                this.dataObj.city = this.omniJsonData[this.currentstepname][this.blockstructure][this.oldelementnameofcity];
                this.cityRequired = false;
            }

            if (
                this.omniJsonData[this.currentstepname][this.blockstructure][this.oldelementnameofzipcode] != null &&
                this.omniJsonData[this.currentstepname][this.blockstructure][this.oldelementnameofzipcode] != "" &&
                this.omniJsonData[this.currentstepname][this.blockstructure][this.oldelementnameofzipcode] != undefined
            ) {
                this.dataObj.zipcode = this.omniJsonData[this.currentstepname][this.blockstructure][this.oldelementnameofzipcode];
                this.zipRequired = false;
            }
            if (
                this.omniJsonData[this.currentstepname][this.blockstructure].hasOwnProperty(this.oldelementnameofstatetext) &&
                this.omniJsonData[this.currentstepname][this.blockstructure][this.oldelementnameofcountry] != "US"
            ) {
                this.isUS = false;
                if (
                    this.omniJsonData[this.currentstepname][this.blockstructure][this.oldelementnameofstatetext] != null &&
                    this.omniJsonData[this.currentstepname][this.blockstructure][this.oldelementnameofstatetext] != "" &&
                    this.omniJsonData[this.currentstepname][this.blockstructure][this.oldelementnameofstatetext] != undefined
                ) {
                    this.dataObj.statetext = this.omniJsonData[this.currentstepname][this.blockstructure][this.oldelementnameofstatetext];
                    this.stateTextRequired = false;
                }
            }
            if (
                this.omniJsonData[this.currentstepname][this.blockstructure].hasOwnProperty(this.oldelementnameofstatepicklist) &&
                this.omniJsonData[this.currentstepname][this.blockstructure][this.oldelementnameofcountry] == "US"
            ) {
                this.isUS = true;
                if (
                    this.omniJsonData[this.currentstepname][this.blockstructure][this.oldelementnameofstatepicklist] != null &&
                    this.omniJsonData[this.currentstepname][this.blockstructure][this.oldelementnameofstatepicklist] != "" &&
                    this.omniJsonData[this.currentstepname][this.blockstructure][this.oldelementnameofstatepicklist] != undefined
                ) {
                    this.dataObj.statepicklist = this.omniJsonData[this.currentstepname][this.blockstructure][this.oldelementnameofstatepicklist];
                    this.statePicklistRequired = false;
                }
            }

            if (
                this.omniJsonData[this.currentstepname][this.blockstructure][this.oldelementnameofcountry] != null &&
                this.omniJsonData[this.currentstepname][this.blockstructure][this.oldelementnameofcountry] != "" &&
                this.omniJsonData[this.currentstepname][this.blockstructure][this.oldelementnameofcountry] != undefined
            ) {
                this.dataObj.country = this.omniJsonData[this.currentstepname][this.blockstructure][this.oldelementnameofcountry];
                this.countryRequired = false;
            }
        }
        //checking county field is Required or Not (I-267573)
        this._actionUtil = new OmniscriptActionCommonUtil();
        this.inputData["parId"] = this.omniJsonData.parid;
        this.inputData["stepName"] = this.currentstepname;
        const countyRequiredParams = {
            input: this.inputData,
            sClassName: "LPI_CountyZipPrepopulationController",
            sMethodName: "checkCountyFieldRequired",
            options: "{}"
        };
        this._actionUtil
            .executeAction(countyRequiredParams, null, this, null, null)
            .then(response => {
                if (response.result != null && response.result.isCountyFieldRequired != null) {
                    this.isCountyRequired = response.result.isCountyFieldRequired;
                } else {
                    this.isCountyRequired = false;
                }
            })
            .catch(error => {
                this.error = error;
                console.error("An unexpected error occurred in checkReadOnlyField Method:", error);
            });
    }

    disconnectedCallback() {
        let key = "customLwcKey";

        const state = this.omniGetSaveState(key);
        let updatedJSON;

        if (
            this.currentstepname == "PersonalInformation" &&
            this.locationtype == "Mailing" &&
            this.omniJsonData[this.currentstepname].ResidanceAddressEditBlock != null &&
            this.omniJsonData[this.currentstepname].ResidanceAddressEditBlock.MailingAddressSameAsCurrentAddress == true
        ) {
            this.result[this.oldelementnameofzipcode] = state["ZipCode"];
            this.result[this.oldelementnameofcity] = state["City"];
            this.result[this.oldelementnameofcounty] = state["County"];
            this.result[this.oldelementnameofstreetaddress] = state["StreetAddress"];
            this.result[this.oldelementnameofcountry] = state["ResCountry"];
            this.result[this.oldelementnameofstatepicklist] = state["statePicklistEdit"];
            this.result[this.oldelementnameofstatetext] = state["StateTextEdit"];
        } else if (
            this.currentstepname == "BusinessAccount" &&
            this.locationtype == "Mailing" &&
            this.omniJsonData[this.currentstepname].BusinessAccountEditableFieldsBlock != null &&
            this.omniJsonData[this.currentstepname].BusinessAccountEditableFieldsBlock.IsMailingAddressIsSameAsMyCurrentAddress == true
        ) {
            if (state != null) {
                this.result[this.oldelementnameofzipcode] = state["BusinessZipcode"];
                this.result[this.oldelementnameofcity] = state["BusinessCity"];
                this.result[this.oldelementnameofcounty] = state["BusinessCounty"];
                this.result[this.oldelementnameofstreetaddress] = state["BusinessStreetAddress"];
                this.result[this.oldelementnameofcountry] = state["BusinessCountryC"];
                this.result[this.oldelementnameofstatepicklist] = state["BusinessAddState"];
                this.result[this.oldelementnameofstatetext] = state["BusinessStateIfCountryIsNotUS"];
            }
        }

        let streetData = this.template.querySelector(`[data-id="${this.streetaddressname}"]`);
        let countryData = this.template.querySelector(`[data-id="${this.countryname}"]`);
        let statePicklistData = this.template.querySelector(`[data-id="${this.statepicklistname}"]`);
        let stateTextData = this.template.querySelector(`[data-id="${this.statetextname}"]`);
        let zipData = this.template.querySelector(`[data-id="${this.zipname}"]`);
        let cityData = this.template.querySelector(`[data-id="${this.cityname}"]`);
        let countyData = this.template.querySelector(`[data-id="${this.countyname}"]`);

        if (streetData != null) {
            this.streetRequired = streetData != null ? (streetData.value != null && streetData.value != "" ? false : true) : true;
            this.result[this.streetaddressname] = this.streetRequired;
        }
        if (countryData != null) {
            this.countryRequired = countryData != null ? (countryData.value != null && countryData.value != "" ? false : true) : true;
            this.result[this.countryname] = this.countryRequired;
        }
        if (statePicklistData != null) {
            this.statePicklistRequired = statePicklistData != null ? (statePicklistData.value != null && statePicklistData.value != "" ? false : true) : true;
            this.result[this.statepicklistname] = this.statePicklistRequired;
        }
        if (stateTextData != null) {
            //If country not US and Current step name is BusinessAccount.Then make state text as optional I-241503
            if (!this.isFieldRequired) {
                this.stateTextRequired = false;
                this.result[this.statetextname] = this.stateTextRequired;
            } else {
                this.stateTextRequired = stateTextData != null ? (stateTextData.value != null && stateTextData.value != "" ? false : true) : true;
                this.result[this.statetextname] = this.stateTextRequired;
            }
        }
        if (zipData != null) {
            //If country not US and Current step name is BusinessAccount.Then make ZipCode as optional I-241503
            if (!this.isFieldRequired) {
                this.zipRequired = false;
                this.result[this.zipname] = this.zipRequired;
            } else {
                this.zipRequired = zipData != null ? (zipData.value != null && zipData.value != "" ? false : true) : true;
                this.result[this.zipname] = this.zipRequired;
            }
        }
        if (cityData != null) {
            this.cityRequired = cityData != null ? (cityData.value != null && cityData.value != "" ? false : true) : true;
            this.result[this.cityname] = this.cityRequired;
        }
        if (countyData != null && this.isCountyRequired) {
            this.countyRequired = countyData != null ? (countyData.value != null && countyData.value != "" ? false : true) : true;
            this.result[this.countyname] = this.countyRequired;
        } else {
            this.countyRequired = false;
        }

        updatedJSON = Object.assign({}, state, this.result);
        // saving my data in omnistate when we are leaving that step
        let mySaveState = updatedJSON;
        let usePubSub = true;
        this.omniSaveState(mySaveState, key, usePubSub);
    }

    //Added for issue I-263223
    handleErrorMsgsOnBlur(event) {
        let currentLabel = event.target.label;
        if (currentLabel == "Zip Code") {
            this.zipRequired = false;
        } else if (currentLabel == "County") {
            this.countyRequired = false;
        } else if (currentLabel == "City") {
            this.cityRequired = false;
        } else if (currentLabel == "Street Address") {
            this.streetRequired = false;
        } else if (currentLabel == "Country") {
            this.countryRequired = false;
        } else if (currentLabel == "State") {
            if (event.target.name == this.statepicklistname) {
                this.statePicklistRequired = false;
            } else if (event.target.name == this.statetextname) {
                this.stateTextRequired = false;
            }
        }
    }

    handleInputs(event) {
        let isHtmlTag = !/^((?!(<\s*|\s*>)).)*$/.test(event.detail.value);
        if (isHtmlTag) {
            event.target.setCustomValidity("Invalid input. This field only accepts letters and numbers. Special characters are not allowed.");
            event.target.reportValidity();
        } else {
            event.target.setCustomValidity("");
            event.target.reportValidity();

            this._actionUtil = new OmniscriptActionCommonUtil();

            if (event.target.name == this.streetaddressname) {
                this.dataObj.streetaddress = event.target.value.trim();
                this.inputData["streetaddress"] = event.target.value;
                this.result[this.oldelementnameofstreetaddress] = this.inputData.streetaddress;
            } else if (event.target.name == this.countryname) {
                this.dataObj.country = event.target.value.trim();
                if (this.dataObj.country == "US") {
                    this.isUS = true;
                    this.dataObj.statetext = null;
                    this.dataObj.statepicklist = null;
                    this.dataObj.zipcode = null;
                } else {
                    this.isUS = false;
                    this.dataObj.statetext = null;
                    this.dataObj.statepicklist = null;
                    this.dataObj.zipcode = null;
                    //Added for I-241503
                    if (this.currentstepname == "BusinessAccount") {
                        this.isFieldRequired = false;
                    } else {
                        this.isFieldRequired = true;
                    }
                }
                this.inputData["zipCode"] = "";
                this.result[this.oldelementnameofzipcode] = this.inputData.zipCode;
                this.inputData["statetext"] = "";
                this.result[this.oldelementnameofstatetext] = this.inputData.statetext;
                this.inputData["statepicklist"] = "";
                this.result[this.oldelementnameofstatepicklist] = this.inputData.statepicklist;
                this.inputData["country"] = event.target.value;
                this.result[this.oldelementnameofcountry] = this.inputData.country;
            } else if (event.target.name == this.statepicklistname) {
                this.dataObj.statepicklist = event.target.value.trim();
                this.inputData["statepicklist"] = event.target.value;
                this.result[this.oldelementnameofstatepicklist] = this.inputData.statepicklist;
            } else if (event.target.name == this.statetextname) {
                this.dataObj.statetext = event.target.value.trim();
                this.inputData["statetext"] = event.target.value;
                this.result[this.oldelementnameofstatetext] = this.inputData.statetext;
            } else if (event.target.name === this.zipname) {
                this.zipRequired = false;
                this.inputData["zipCode"] = event.target.value;
                this.dataObj.city = null;
                this.dataObj.county = null;

                if (this.inputData.zipCode != null) {
                    const params1 = {
                        input: this.inputData,
                        sClassName: "LPI_CountyZipPrepopulationController",
                        sMethodName: "getDataToPrepopulateBasedOnZipCode",
                        options: "{}"
                    };
                    this._actionUtil
                        .executeAction(params1, null, this, null, null)
                        .then(response => {
                            if (response != null && response.result.fetchCityCounty != null && this.inputData.zipCode.length >= 5) {
                                var result = response.result.fetchCityCounty;
                                // updating data JSON in omniscript
                                this.dataObj.zipcode = this.inputData.zipCode;
                                this.result[this.oldelementnameofzipcode] = this.inputData.zipCode;
                                this.result[this.oldelementnameofcity] = result.city;
                                this.dataObj.city = result.city;
                                this.cityRequired = false;
                                this.result[this.oldelementnameofcounty] = result.county;
                                this.dataObj.county = result.county;
                                this.countyRequired = false;
                            } else if (event.target.value == null || event.target.value == "") {
                                this.result[this.oldelementnameofzipcode] = null;
                                this.result[this.oldelementnameofcounty] = null;
                                this.result[this.oldelementnameofcity] = null;
                            }
                            this.omniUpdateDataJson(this.result);
                        })
                        .catch(error => {
                            this.error = error;
                            console.log("error->", JSON.stringify(error));
                        });
                } else if (event.target.value == null || event.target.value == "") {
                    this.result[this.oldelementnameofzipcode] = null;
                }
            } else if (event.target.name === this.cityname) {
                this.inputData["city"] = event.target.value;
                this.result[this.oldelementnameofcity] = this.inputData.city;
            } else if (event.target.name === this.countyname) {
                this.inputData["county"] = event.target.value;
                this.result[this.oldelementnameofcounty] = this.inputData.county;
            }
            this.omniUpdateDataJson(this.result);
        }
    }

    get errorMessages() {
        if (this.error) {
            return Array.isArray(this.error.body) ? this.error.body.map(e => e.message) : [this.error.body.message];
        }
        return [];
    }
}