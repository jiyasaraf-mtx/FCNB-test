import getProfileDetails from '@salesforce/apex/LPI_ProfileController.getProfileDetails';
import updateProfileDetails from '@salesforce/apex/LPI_ProfileController.updateProfileDetails';
import deleteSelectedfile from '@salesforce/apex/LPI_ProfileController.deleteUserPhoto';
import uploadProilePhoto from '@salesforce/apex/LPI_ProfileController.uploadProilePhoto';
import MODPR_MessageChannel from '@salesforce/messageChannel/MODPR_MessageChannel__c';
import ACCOUNT_OBJECT from '@salesforce/schema/Account';
import addressInUSOrInternational from '@salesforce/schema/Account.Is_the_address_in_US_or_International__c';
import ContactCountry from '@salesforce/schema/Account.PersonOtherCountryCode';
import ContactState from '@salesforce/schema/Account.PersonOtherStateCode';
import userId from "@salesforce/user/Id";
import {
    checkLength,
    formatPhoneNumber,
    showAsyncErrorMessage,
    showMessage,
} from 'c/lpiUtil';
import { MessageContext, publish } from 'lightning/messageService';
import { NavigationMixin } from 'lightning/navigation';
import {
    getObjectInfo,
    getPicklistValues
} from 'lightning/uiObjectInfoApi';
import {
    LightningElement,
    track,
    wire
} from 'lwc';

const EXPECTED_URL = '/license/profilephoto/005/F';

export default class LpiProfileCmp extends NavigationMixin(LightningElement) {
    @wire(MessageContext)
    messageContext;
    message;
    @track dataObj = {};
    @track countryOptions;
    @track addressOptions;
    @track stateOptions;
    showSpinner = true;
    fromFileUpload;
    documentId;
    fileName;
    userIdValue = (userId === '	0053R000002uDhUQAU');
    openConfirmationModal=false;
    modalHeading="";
    //Added for I-243580
    isPhoneNumChanged = false;
    isEmailChanged = false;
    patternObj = {
        email: '^([A-Za-z0-9_\-\.\+]+)@([A-Za-z0-9_\-\.]+)\.([A-Za-z]{2,10})$'
    };
    get acceptedFormats() {
        return ['.png', '.jpg', '.jpeg'];
    }
    // GET OBJECT INFO

    @wire(getObjectInfo, {
        objectApiName: ACCOUNT_OBJECT
    })
    objectInfo;

    // GET PICKLIST VALUES OF addressInUSOrInternational FIELD
    @wire(getPicklistValues, {
        recordTypeId: '$objectInfo.data.defaultRecordTypeId',
        fieldApiName: addressInUSOrInternational
    })
    wiredPicklistValuesAddressOptions({
        error,
        data
    }) {

        this.showSpinner = true;
        if (data && data.values) {
            this.addressOptions = data.values;
            this.showSpinner = false;
        } else if (error) {
            this.showSpinner = false;
            showAsyncErrorMessage(this, error);
        }

    }

    // GET PICKLIST VALUES OF STATE FIELD
    @wire(getPicklistValues, {
        recordTypeId: '$objectInfo.data.defaultRecordTypeId',
        fieldApiName: ContactState
    })
    wiredPicklistValues({
        error,
        data
    }) {

        this.showSpinner = true;
        if (data && data.values) {
            this.stateOptions = JSON.parse(JSON.stringify(data.values));
            if (this.dataObj && this.dataObj.state) {
                this.stateOptions.push({
                    label: this.dataObj.state,
                    value: this.dataObj.state
                });
            }

            this.showSpinner = false;
        } else if (error) {
            this.showSpinner = false;
            showAsyncErrorMessage(this, error);
        }

    }

    // GET PICKLIST VALUES OF COUNTRY FIELD
    @wire(getPicklistValues, {
        recordTypeId: '$objectInfo.data.defaultRecordTypeId',
        fieldApiName: ContactCountry
    })
    wiredCountryPicklistValues({
        error,
        data
    }) {
        this.showSpinner = true;
        if (data && data.values) {
            this.countryOptions = data.values;
            this.showSpinner = false;
        } else if (error) {
            this.showSpinner = false;
            showAsyncErrorMessage(this, error);
        }

    }
    //I-288456 Added By Mahesh
    get isProfileExist(){
        return this.dataObj.profileUrl == EXPECTED_URL
    }

    connectedCallback() {
        this.loadData();
    }


    loadData() {
        getProfileDetails().then(result => {
            if (this.fromFileUpload) {
                this.dataObj.profileUrl = result.profileUrl;
                let message = {
                    'profileUrl' : this.dataObj.profileUrl
                }
                publish(this.messageContext, MODPR_MessageChannel, message);

            } else {
                this.dataObj = result;
                this.dataObj.phone = this.dataObj.phone ? formatPhoneNumber(this.dataObj.phone) : this.dataObj.phone;
                this.dataObj.oldPhone = this.dataObj.oldPhone ? formatPhoneNumber(this.dataObj.oldPhone) : this.dataObj.oldPhone;
                if (this.stateOptions) {
                    this.stateOptions.push({
                        label: this.dataObj.state,
                        value: this.dataObj.state
                    });
                }

            }
            //this.testOnBase();

        }).catch(error => {
            showAsyncErrorMessage(this, error);
        }).finally(() => {
            this.showSpinner = false;
        })
    }

    handleDownload(){
        try{
            let documentIdSet = ['216395698','216395697'];

            documentIdSet.forEach(doc => {
                fetch('https://secureapidev.mo.gov/dev/mopro-upload-exp-api/api/documents/retrieve/'+doc, {
                    method: 'GET',
                    headers: {
                        // "Authorization": result,
                        "client_id" : "db8eac85cddf403b95f8f0c1f794836f",
                        "client_secret" : "7DeB2D1a4FCc413B8eFBd7735FC004f6",
                        "X-Correlation-Id" : "a2b72520-4035-11ee-bf72-ac1a3dd01993"
                        //"Access-Control-Allow-Origin": "*"
                    }
                })
                .then(res => res.blob())
                .then(blob => {
                    var reader = new FileReader();
                reader.readAsDataURL(blob);
                reader.onloadend = function () {
                    var base64data = reader.result;
                    const a = document.createElement("a");
                    document.body.appendChild(a);
                    // const blobUrl = window.URL.createObjectURL(blob);
                    a.href = base64data;
                    a.download = doc;
                    a.click();
                    document.body.removeChild(a);
                }
                   }).catch(error => {
                        console.error('Error:', error);
                    });
            })
        }catch(error){

        }
        
    }

    handleFile(event){
        let file = event.target.files[0];
        this.fileName = file.name.split('.')[0]
        // getAuthHeaderForOnbase()
        //   .then(result => {
            let formData = new FormData();
            let jsonPayloadData = {
                "documentTypeId": "1911",
                "comment": "mohit",
                "storeAsNew": true,
                "documentDate": "10-15-2023",
                "keywordCollection": {
                "items": [
                  {
                    "keywords": [
                      {
                        "typeId": "1273",
                        "values": [
                          {
                            "value": "212122"
                          }
                        ]
                      },
                      {
                        "typeId": "1095",
                        "values": [
                          {
                            "value": "212122"
                          }
                        ]
                      }]
                    }
                    
                ]
                }
            };



              const json = JSON.stringify(jsonPayloadData);
              const blob = new Blob([json], {
                type: 'application/json'
              });

            formData.append('jsonPayload',blob);
            formData.append('fileName', file);
            
            fetch('https://secureapidev.mo.gov/dev/mopro-upload-exp-api/api/documents/upload', {
                method: 'POST',
                headers: {
                    // "Authorization": result,
                    "client_id" : "db8eac85cddf403b95f8f0c1f794836f",
                    "client_secret" : "7DeB2D1a4FCc413B8eFBd7735FC004f6",
                    "X-Correlation-Id" : "a2b72520-4035-11ee-bf72-ac1a3dd01993"
                    //"Access-Control-Allow-Origin": "*"
                },
                body : formData
            })
            .then(output => {



                return output.json();
            }).then((data) =>{
                this.documentId = data.document_id;
              // `data` is the parsed version of the JSON returned from the above endpoint.
              console.log(data);  // { "userId": 1, "id": 1, "title": "...", "body": "..." }
            }).catch(error => console.log('---error' + error));
        //   })
        //   .catch(error => {
        //     console.error('Error:', error);
        // });

    }

    

    handleChange(event) {
        if (event.target.name === 'phone') {
            event.currentTarget.setCustomValidity("");
            event.currentTarget.reportValidity("");
            this.dataObj[event.target.name] = formatPhoneNumber(event.target.value);
            if(this.dataObj.phone != this.dataObj.oldPhone){
                this.isPhoneNumChanged = true;
            }else{
                this.isPhoneNumChanged = false;
            }
        } else {
            this.dataObj[event.target.name] = event.target.value;
            
            if(this.dataObj.email != this.dataObj.oldEmail){
                this.isEmailChanged = true;
            }else{
                this.isEmailChanged = false;
            }
        }
    }

    handleSave() {
        if (this.checkValidity()) {
            this.showSpinner = true;
            this.dataObj.phone = this.dataObj.phone ? this.dataObj.phone.replace(/[^\d]/g, "") : this.dataObj.phone;
            updateProfileDetails({
                jsonData: JSON.stringify(this.dataObj)
            }).then(result => {
                if (result) {
                    if(this.isPhoneNumChanged && this.isEmailChanged){
                        this.showToastMsg("Profile details have been updated successfully.", "success", "Success");
                        this.showToastMsg("To update your email address on record, please verify your email address by clicking on the link sent to your mail box.", "warning", "Action Required");
                    } else if (this.isPhoneNumChanged) {
                        this.showToastMsg("Profile details have been updated successfully.", "success", "Success");
                    } else if(this.isEmailChanged){
                        this.showToastMsg("To update your email address on record, please verify your email address by clicking on the link sent to your mail box.", "warning", "Action Required");
                    }
                    this.loadData()
                    this.isPhoneNumChanged = false;
                    this.isEmailChanged = false;
                } else {
                    showAsyncErrorMessage(this, "Error updating details.")
                }
            }).catch(error => {
                showAsyncErrorMessage(this, error)
            }).finally(() => {
                this.dataObj.phone = this.dataObj.phone ? formatPhoneNumber(this.dataObj.phone) : this.dataObj.phone;
                this.showSpinner = false;
            })
        }
        setTimeout(() => {
            this.template.querySelector(".savefocus").focus();
        }, 6000);
    }

    handleSaveandExit() {
        if (this.checkValidity()) {
            let successMsg;
            this.showSpinner = true;
            this.dataObj.phone = this.dataObj.phone ? this.dataObj.phone.replace(/[^\d]/g, "") : this.dataObj.phone;
            updateProfileDetails({
                jsonData: JSON.stringify(this.dataObj)
            }).then(result => {
                if (result) {
                    if(this.isPhoneNumChanged && this.isEmailChanged){
                        this.showToastMsg("Profile details have been updated successfully.", "success", "Success");
                        this.showToastMsg("To update your email address on record, please verify your email address by clicking on the link sent to your mail box.", "warning", "Action Required");
                    } else if (this.isPhoneNumChanged) {
                        this.showToastMsg("Profile details have been updated successfully.", "success", "Success");
                    } else if(this.isEmailChanged){
                        this.showToastMsg("To update your email address on record, please verify your email address by clicking on the link sent to your mail box.", "warning", "Action Required");
                    }
                    this.isPhoneNumChanged = false;
                    this.isEmailChanged = false
                } else {
                    showAsyncErrorMessage(this, "Error updating details.")
                }
            }).catch(error => {
                showAsyncErrorMessage(this, error)
            }).finally(() => {
                this.dataObj.phone = this.dataObj.phone ? formatPhoneNumber(this.dataObj.phone) : this.dataObj.phone;
                this.showSpinner = false;
                this.navigateToHomePage();
            })
        }
    }
    navigateToHomePage() {
        this[NavigationMixin.Navigate]({
                type: 'standard__webPage',
                attributes: {
                    url: '/s'
                }
            },
            true
        );
    }
    checkValidity() {
        this.focus = false;
        this.focusIndex = -1;
        let isAllValid;
        let regex = '^(\\([0-9]{3}\\) |[0-9]{3}-)[0-9]{3}-[0-9]{4}$';
        this.template.querySelectorAll('.phoneNumberField').forEach(input => {
            if (input.value && !input.value.match(regex)) {
                isAllValid = false;
                input.setCustomValidity("Please enter a valid telephone number.");
                input.reportValidity();
            }
        });

        isAllValid = [...this.template.querySelectorAll('.validate')].reduce((validSoFar, input) => {
            input.reportValidity();
            let valid = input.checkValidity() && checkLength(input);
            valid = input.disabled ? true : valid;
            if (!valid && (!this.focus || this.focusIndex == -1 || this.focusIndex > parseInt(input.dataset.index))) {
                input.focus();
                this.focus = true;
                this.focusIndex = input.dataset.index;
            }
            return validSoFar && valid;
        }, true);
        if (!isAllValid) {
            showAsyncErrorMessage(this, 'Please validate all the input fields.');
			this.focusFirstEle();
            // let allInput = this.template.querySelector(".slds-has-error");
            // if (allInput) {
            //     allInput.focus();
            // }
        }
        return isAllValid;
    }

    handleFileUpload(event) {
        this.showSpinner = true;
        let uploadedFiles = event.detail.files;
        uploadProilePhoto({
            documentId: uploadedFiles[0].documentId
        }).then(() => {
            showMessage(this, {
                title: "Success",
                message: "Profile picture has been updated.",
                messageType: "success",
                mode: "dismissable"
            });
            // window.location.reload();
            this.fromFileUpload = true;
            setTimeout(() => {
                this.loadData();
            }, 3000);

        }).catch(error => {
            showAsyncErrorMessage(this, error);
        }).finally(() => {
            this.showSpinner = false;
        })


    }
    showToastMsg(msg, msgType, msgTitle){
        showMessage(this, {
            title: msgTitle,
            message: msg,
            messageType: msgType,
            mode: "dismissable"
        });
    }

    handleCancelConfirmation() {
		this.courseDetailData = null;
		this.openConfirmationModal = false;
        setTimeout(() => {
			this.template.querySelector('.deleteFocus').focus();
			this.focusFirstEle();
		}, 200);
	}


    handleProfilePhotoDelete(event) {
		this.modalHeading = "Are you sure you want to delete this photo?";
		this.selectedCourseInfoIndex = event.currentTarget.dataset.index;
		this.openConfirmationModal = true;
		//S-57276 added by Vamshi
		setTimeout(() => {
			this.template.querySelector('.deleteFocus').focus();
			this.focusFirstEle();
		}, 200);
	}


    deleteSelectedRecords(event)
    {  
       deleteSelectedfile()
      .then(result => {
        
        showMessage(this, {
            title: "Success",
            message: "Profile picture has been deleted.",
            messageType: "success",
            mode: "dismissable"
        });
        setTimeout(() => {
            this.loadData();
        }, 1000)
      })
      .catch(error => {
        this.showToastMsg("Something went wrong.", "error", "Error");

        })
        .finally(()=>{
            this.showSpinner=false;
            this.openConfirmationModal = false;
            this.focusOnInitialButton("fileUploadFocus");
        })
    }
    showToastMsg(msg, msgType, msgTitle){
        showMessage(this, {
            title: msgTitle,
            message: msg,
            messageType: msgType,
            mode: "dismissable"
        });
    }
    focusOnInitialButton(className) {
		var focusOnInitial = this.template.querySelector(`.${className}`);
		if (focusOnInitial) {
			focusOnInitial.focus();
		}
	}

    handleEscKeyDown(event) {
        if (event.code === 'Escape' || event.keyCode === 27) {
            this.handleCancelConfirmation();
		}
	}

    focusFirstEle() {
		const focusableElements =
			"lightning-button-icon, lightning-helptext,lightning-button, button, lightning-input, lightning-textarea, lightning-combobox";
		const modal = this.template.querySelector(".slds-modal");
		const firstFocusableElement = modal.querySelectorAll(focusableElements)[0];
		const focusableContent = modal.querySelectorAll(focusableElements);
		const lastFocusableElement = focusableContent[focusableContent.length - 1];
		firstFocusableElement.focus();
		this.template.addEventListener("keydown", function (event) {
			let isTabPressed = event.key === "Tab" || event.keyCode === 9;
			if (!isTabPressed) {
				return;
			}
			if (event.shiftKey) {
				if (this.activeElement === firstFocusableElement) {
					lastFocusableElement.focus();
					event.stopPropagation();
					event.preventDefault();
				}
			} else {
				if (this.activeElement === lastFocusableElement) {
					firstFocusableElement.focus();
					event.preventDefault();
					event.stopPropagation();
				}
			}
		});
	}

    
}