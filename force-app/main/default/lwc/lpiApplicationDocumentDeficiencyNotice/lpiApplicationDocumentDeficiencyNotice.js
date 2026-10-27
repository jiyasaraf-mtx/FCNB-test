import {
  LightningElement,
  track,
  api
} from "lwc";
import {
  NavigationMixin
} from 'lightning/navigation';
import {
  ShowToastEvent
} from "lightning/platformShowToastEvent";
import {
  showAsyncErrorMessage,
  showMessage
} from "c/lpiUtil";
import createApplicationDocumentsForDeficiency from "@salesforce/apex/LPI_ApplicationDocumentDeficiencyCtrl.createApplicationDocumentsForDeficiency";
import checkChannelStatusValue from "@salesforce/apex/LPI_ApplicationDocumentDeficiencyCtrl.checkChannelStatusValue";
const MAX_FILE_SIZE = 2097152;
const DOWNLOAD_DOCUMENT_DEFICIENCY_NOTICE_URL = "/apex/LPI_DocumentDeficiencyNoticePDF?targetId=";
import getFileScanResult from '@salesforce/apex/LPI_OnBaseIntegrationController.bypassOnbase';
import createApplicationDocument from '@salesforce/apex/LPI_GetApplicationDocumentController.createApplicationDocument';
import downloadFile from '@salesforce/apex/LPI_OnBaseIntegrationController.downloadFileFromSf';
import handleFileDelete from '@salesforce/apex/LPI_OnBaseIntegrationController.handleFileDelete';
import handleCancel from '@salesforce/apex/LPI_OnBaseIntegrationController.handleCancel';
import updateOnbaseuploadStatus from '@salesforce/apex/LPI_OnBaseIntegrationController.updateOnbaseuploadStatus';
import handleContentDocumentDelete from '@salesforce/apex/LPI_OnBaseIntegrationController.handleContentDocumentDelete';
import fileScanSetTimoutValue from '@salesforce/label/c.Upload_File_Scan_Timeout_Value';
import lpiTheme from "@salesforce/resourceUrl/LPI_Design";
import { loadStyle } from "lightning/platformResourceLoader";
export default class LpiApplicationDocumentDeficiencyNotice extends NavigationMixin(LightningElement) {
  @api recordId;
  @track documentItems = [];
  @track isLoading = true;
  @track documentNameSet = new Set();
  @track deficiencyData = {
    dueDate: null,
    deficiencyComments: "",
    documentItems: [],
    additionalFeeDetailList: []
  };
  today;
  channel = true;
  twoByTwoPhotoRecommendation;
  isRichTextisValid = true;
  errorMsgForRichText = '';
  showUploadModal;
  modalHeading = 'Upload File';
  isDeleteModal;
  header;
  documentIdForUpload;
  @track lineItemSelected = {};
  @track fromDeficiency = true;
  @track docNameOptions = [];

  hideParentModal;
  @track deleteFileobj = {};
  get modeOptions() {
    return [{
      label: "Required",
      value: "true"
    },
    {
      label: "Optional",
      value: "false"
    }
    ];
  }

  /*get docNameOptions() {
    return [{
        label: "2x2 Photo",
        value: "2x2 Photo"
      },
      {
        label: "Postgraduate Reference Letter Form",
        value: "Postgraduate Reference Letter Form"
      },
      {
        label: "Copy of International Medical License",
        value: "Copy of International Medical License"
      },
      {
        label: "Original/Official Translations",
        value: "Original/Official Translations"
      }
    ];
  }*/

  @track feeNameWithObjectCode = {};
  @track feePicklistData = [];
  @track feeItems = [];

  get hasDocument() {
    return this.documentItems.length > 0;
  }

  get hasFeeItems() {
    return this.feeItems.length > 0;
  }

  get statusOptions() {
    return [{
      label: "Unsubmitted",
      value: "Unsubmitted"
    }];
  }


  get acceptedFormats() {
    ".doc",
      ".docx",
      ".ppt",
      ".pptx",
      ".pdf",
      ".bmp",
      ".jpeg",
      ".jpg",
      ".png",
      ".heic",
      ".webp"
  }

  connectedCallback() {
    this.today = new Date().toISOString().slice(0, 10);
    this.checkChannelStatus();
    loadStyle(this, lpiTheme + "/styles/internal-main.css");
  }

  checkChannelStatus() {
    checkChannelStatusValue({
      applicationId: this.recordId
    })
      .then((result) => {
        if (!result) {
          return;
        }
        this.feeNameWithObjectCode = result.feeNameWithObjectCode;
        if (this.feeNameWithObjectCode != null && Object.keys(this.feeNameWithObjectCode).length > 0) {
          this.feePicklistData = Object.keys(this.feeNameWithObjectCode).map((item) => {
            return { 'label': item, 'value': item };
          })
        }
        this.channel = result.channel === true;
        if (this.channel) {
          this.closeAction();
          this.showToast("Success", "Deficiency Notice Downloaded successfully", "success");
          window.open(`${DOWNLOAD_DOCUMENT_DEFICIENCY_NOTICE_URL + this.recordId}`, "_self");
          return;
        }
        let onbaseConfiguration = result.onbase ? JSON.parse(result.onbase) : null;
        this.docNameOptions = result?.docNameOptions ? JSON.parse(result.docNameOptions) : [];
        console.log('JSON.parse(result.docNameOptions) ==> ' + JSON.parse(result.docNameOptions));
        this.twoByTwoPhotoRecommendation =
          result.twoByTwoPhotoRecommendation && !this.twoByTwoPhotoRecommendation ?
            JSON.parse(result.twoByTwoPhotoRecommendation) :
            this.twoByTwoPhotoRecommendation;
        this.header = this.twoByTwoPhotoRecommendation.with2x2header;
        if (onbaseConfiguration) {
          if (
            onbaseConfiguration.onbaseConfig &&
            onbaseConfiguration.onbaseConfig[result.boardName + "-LICENSE"]
          ) {
            this.onbaseMetadata = JSON.parse(
              onbaseConfiguration.onbaseConfig[result.boardName + "-LICENSE"]
            );
          }
          if (
            this.onbaseMetadata &&
            this.onbaseMetadata.keywordCollection &&
            this.onbaseMetadata.keywordCollection.items
          ) {
            this.onbaseMetadata.keywordCollection.items.forEach((item) => {
              item.keywords.forEach((keyWord) => {
                keyWord.values.forEach((keyValue) => {
                  keyValue.value = result[keyValue.value];
                });
              });
            });
            this.onbaseMetadata.documentDate = result.documentDate;
          }
        }
      })
      .catch((error) => {
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Error",
            message: "Problem in checking Channel of Application " + JSON.stringify(error),
            variant: "error"
          })
        );
      })
      .finally(() => {
        this.isLoading = false;
      });
  }

  createApplicationDocuments() {
    this.isLoading = true;
    this.documentNameSet.clear();
    if (!this.isDuplicateNameFound()) {
      this.deficiencyData["documentItems"] = this.documentItems;
      this.deficiencyData["newDocNameList"] = Array.from(this.documentNameSet);
      this.deficiencyData["additionalFeeDetailList"] = this.feeItems;
      createApplicationDocumentsForDeficiency({
        applicationId: this.recordId,
        inputData: JSON.stringify(this.deficiencyData)
      })
        .then((response) => {
          console.log('response ==> ' + JSON.stringify(response));
          let reason = response["ErrorReason"];
          if (reason === "Success") {
            this.showToast("Success", "Deficiency Notice sent successfully", "success");
            const closeModalEvent = new CustomEvent("modalclose");
            this.dispatchEvent(closeModalEvent);

          } else if (reason === "DuplicateNameFoundError") {
            this.documentNameSet = new Set(JSON.parse(response["ErrorData"]));
            this.isDuplicateNameFound();
          } else if (reason === "StatusChangeDenied") {
            this.showToast("Error", "Deficiency Notice can not be send once license is issued", "error");
          } else {
            this.showToast("Error", "Something went wrong", "error");
          }
        })
        .catch((error) => {
          this.showToast("Error", "Something went wrong", "error");
        })
        .finally((_) => {
          this.isLoading = false;
        });
    } else {
      this.isLoading = false;
    }
  }

  closeAction() {
    let recordIdList = [];
    this.documentItems.forEach(document => {
      if (document.parentDocId) {
        recordIdList.push(document.parentDocId);
      }

      document.childAppDocIds.forEach(childDocId => {
        if (childDocId) {
          recordIdList.push(childDocId);
        }

      })
    })
    updateOnbaseuploadStatus({
      recordIdList: recordIdList
    }).then(() => {
      const closeModalEvent = new CustomEvent("modalclose");
      this.dispatchEvent(closeModalEvent);
    }).catch(error => {
      showAsyncErrorMessage(this, error);
    })

  }

  handleSave() {
    const inputElement = [...this.template.querySelectorAll(".reqVal")];
    let isValidData = inputElement.reduce((validSoFar, inputCmp) => {
      if (inputCmp.value != null && (JSON.stringify(inputCmp.value).includes('<') ||
        JSON.stringify(inputCmp.value).includes('>'))) {
        inputCmp.setCustomValidity('Invalid input. This field only accepts letters and numbers. Special characters are not allowed.');
      } else {
        inputCmp.setCustomValidity('');
      }
      inputCmp.reportValidity();
      if (!inputCmp.checkValidity()) {
        inputCmp.focus();
      }
      return validSoFar && inputCmp.checkValidity();
    }, true);
    const richTextLength = this.deficiencyData['deficiencyComments'].length;
    if (richTextLength > 25000) {
      this.isRichTextisValid = false;
      this.errorMsgForRichText = 'You have exceded the max length of 25000 Character';
    } else {
      this.isRichTextisValid = true;
      this.errorMsgForRichText = '';
    }
    if (isValidData && this.isRichTextisValid) {
      this.createApplicationDocuments();
    }
  }

  isDuplicateNameFound() {
    const inputElement = [...this.template.querySelectorAll(".dupVal")];
    for (var i = 0; i < inputElement.length; i++) {
      let item = inputElement[i];
      if (!this.documentNameSet.has(item.value)) {
        this.documentNameSet.add(item.value);
      } else {
        item.setCustomValidity(
          "An Application document exist with the same name. Please enter a different name."
        );
        item.reportValidity();
        item.setCustomValidity("");
        item.focus();
        return true;
      }
    }
    return false;
  }

  // Method to add a new line item
  addLineItem() {
    this.documentItems.push({
      key: Date.now(), // Unique key for each item
      documentName: "",
      documentDescription: "",
      isRequired: "false",
      isSubmissionRequired: "true",
      fileData: [],
      childAppDocIds: []
    });
  }

  addFeeLineItem() {
    this.feeItems.push({
      key: Date.now(), // Unique key for each item
      feeName: null,
      feeDescription: "",
      feeAmount: null,
      feeObjectCode: null
    });
  }

  // Method to handle "Remove" button click and remove the item from the list
  handleRemoveItem(event) {
    this.isLoading = true;
    const keyToRemove = event.target.dataset.key;
    this.lineItemSelected = this.documentItems.filter((item) => item.key == keyToRemove)[0];
    let recordIdList = [];
    if (this.lineItemSelected.parentDocId) {
      recordIdList.push(this.lineItemSelected.parentDocId)

    }
    this.lineItemSelected.childAppDocIds.forEach(appDocId => {
      if (appDocId) {
        recordIdList.push(appDocId);
      }

    })

    updateOnbaseuploadStatus({
      recordIdList: recordIdList
    }).then(() => {
      this.documentItems = this.documentItems.filter((item) => item.key != keyToRemove);
    }).catch(error => {
      showAsyncErrorMessage(this, error);
    }).finally(() => {
      this.isLoading = false;
    })
  }

  // Method to remove fee Item
  handleRemoveFeeItem(event) {
    const keyToRemove = event.target.dataset.key;
    this.feeItems = this.feeItems.filter((item) => item.key != keyToRemove);
  }

  inputHandler(event) {
    const lineItemKey = event.target.dataset.key;
    const apiName = event.target.dataset.apiname;
    console.log('apiName ==> ' + apiName);
    console.log('event.detail.value ==> ' + event.detail.value);
    if (lineItemKey) {
      this.documentItems.map((item) => {
        if (item.key == lineItemKey) {
          if (event.target.type == "checkbox") {
            item[apiName] = event.detail.checked;
          } else {
            if (apiName == 'documentName' && event.detail.value == 'Other') {
              item.showOtherDocNameInput = true;
            } else if (apiName == 'documentName') {
              item.showOtherDocNameInput = false;
            }
            item[apiName] = event.detail.value;
          }
        }
      });
    }
  }

  feeDetailHandler(event) {
    const lineItemKey = event.target.dataset.key;
    const name = event.target.name;
    if (lineItemKey) {
      this.feeItems.map((item) => {
        if (item.key == lineItemKey) {
          item[name] = event.detail.value;
          item.feeObjectCode = item.feeName != null &&
            item.feeName.length > 0 &&
            this.feeNameWithObjectCode != null &&
            this.feeNameWithObjectCode[item.feeName] ?
            this.feeNameWithObjectCode[item.feeName] : null
        }
      })
    }
  }

  showToast(title, msg, variant) {
    const event = new ShowToastEvent({
      title: title,
      message: msg,
      variant: variant,
      mode: "dismissable"
    });
    this.dispatchEvent(event);
  }


  deficiencyDataHandler(event) {
    const apiName = event.target.dataset.apiname;
    this.deficiencyData[apiName] = event.target.value;
  }


  createAppDoc(event) {
    // this.modalHeading = 'Upload File';
    let key = event.target.dataset.key;
    this.isLoading = true;
    this.lineItemSelected = this.documentItems.filter((item) => item.key == key)[0];
    let options = {
      'payload': JSON.stringify(this.onbaseMetadata),
      'createNewRec': (this.lineItemSelected.parentDocId) ? true : false,
      'appDocumentId': (this.lineItemSelected.parentDocId) ? this.lineItemSelected.parentDocId : null
    }
    console.log('lineItemSelected :>> ', JSON.stringify(this.lineItemSelected));

    createApplicationDocument({
      options: options
    }).then((response) => {
      // this.hideParentModal = true;
      this.documentIdForUpload = response.newid;
      // this.showUploadModal = true;
      if (!this.lineItemSelected.parentDocId) {
        this.lineItemSelected.parentDocId = response.newid;
      } else {
        this.lineItemSelected.childAppDocIds.push(response.newid)
      }
      this.handleUploadFinished(event);
    }).catch(error => {
      this.isLoading = false;
      showAsyncErrorMessage(this, error);
    }).finally(() => {
    })
  }

  handleUploadFinished(event) {
    try {
      // this.dispatchEvent(
      //   new ShowToastEvent({
      //     title: "Warning",
      //     message: "Document has been Uploaded and it is currently being scanned, do not refresh the page, or click on any button.",
      //     messageType: "warning"
      //   })
      // );
      let fileName = event.detail.files[0].name;
      // this.showUploadModal = false;
      let dataObj = {
        contentDocumentId: event.detail.files[0].documentId,
        markUnsubmitted: true,
        appDocumentId:this.documentIdForUpload,
        uploadByInternalUser : true,
        newDocumentName: 'Deficiency Notice Document'
      }
      setTimeout(() => {
        getFileScanResult({
          jsonData: JSON.stringify(dataObj)
        }).then((res) => {
          // this.hideParentModal = false;
          console.log('Bypass Response>>',res);

          this.dispatchEvent(
            new ShowToastEvent({
              title: "Success",
              message: "Document has been uploaded successfully.",
              messageType: "success",
              mode: "dismissable"
            })
          );
          this.fromDeficiency = false;
          this.lineItemSelected.fileData.push({
            fileName: fileName,
            parentRecId: this.documentIdForUpload
          })
        }).catch(error => {
            showAsyncErrorMessage(this, error);
        }).finally(() => {
          this.documentIdForUpload = null;
          this.isLoading = false;
        })
      }, fileScanSetTimoutValue);
    } catch (error) {
      this.isLoading = false;
      showAsyncErrorMessage(this, error);
    }
  }

  handleViewDocument(event) {
    this.showSpinner = true;
    showMessage(this, {
      title: "Info",
      message: 'Document will download shortly.',
      messageType: "info",
      mode: "dismissable"
    });
    let dataObj = {
      appDocId: event.target.dataset.parentid
    };
    let fromOnbase;
    downloadFile({
      recordId: event.target.dataset.parentid
    }).then((response) => {
      fromOnbase = response.fromOnbase;
      dataObj.contentDocId = response.contentDocId;
      window.open(response.downloadUrl.toString(), "_blank")

    }).then(() => {

      if (fromOnbase) {
        setTimeout(() => {
          handleContentDocumentDelete({
            contentDocumentId: dataObj.contentDocId,
            appDocId: dataObj.appDocId
          }).then().catch(error => {
            showAsyncErrorMessage(this, error)
          });
        }, 12000)
      }

    }).catch(error => {
      showAsyncErrorMessage(this, error)
    }).finally(() => {
      this.showSpinner = false;
    })
  }

  handleDeleteConfirmation(event) {
    this.isDeleteModal = true;
    this.modalHeading = 'File delete confirmation';
    this.deleteFileobj = {
      appDocumentId: event.target.dataset.parentid,
      intakeFileDelete: true

    }
    this.lineItemSelected = this.documentItems.filter((item) => item.key == event.target.dataset.key)[0];
    this.hideParentModal = true;
    this.showUploadModal = true;
  }

  handleDelete() {
    this.isLoading = true;
    handleFileDelete({
      jsonData: JSON.stringify(this.deleteFileobj)
    }).then((response) => {
      if (response.parentDeleted || (response.deletedAppRecId && response.deletedAppRecId.includes(this.lineItemSelected.parentDocId))) {
        this.lineItemSelected.parentDocId = null;
      }
      this.lineItemSelected.fileData = this.lineItemSelected.fileData.filter((doc) => doc.parentRecId != this.deleteFileobj.appDocumentId);
      this.dispatchEvent(
        new ShowToastEvent({
          title: "Success",
          message: 'File has been deleted successfully.',
          messageType: "success"
        })
      );
      this.handleClose();

    }).catch(error => {
      showAsyncErrorMessage(this, error);
    }).finally(() => {
      this.isLoading = false;
    })
  }

  handleClose() {
    if (!this.isDeleteModal) {
      handleCancel({
        recordId: this.documentIdForUpload
      }).then(() => {
        if (this.lineItemSelected.parentDocId == this.documentIdForUpload) {
          this.lineItemSelected.parentDocId = null;
        } else {
          this.lineItemSelected.childAppDocIds = this.lineItemSelected.childAppDocIds.filter(recordId => {
            recordId != this.documentIdForUpload
          })
        }
        this.documentIdForUpload = null;
        this.showUploadModal = false;
        this.hideParentModal = false;
        this.deleteFileobj = null;
        this.isDeleteModal = false;
      }).catch(error => {
        showAsyncErrorMessage(this, error);
      })
    }

  }

}