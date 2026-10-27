import {
    LightningElement,
    track
} from 'lwc';
import {
    showAsyncErrorMessage,
    showMessageLinkable,
    showMessage
} from 'c/lpiUtil';
import getBoardNames from '@salesforce/apex/LPI_LicenseSearchDownloadController.getBoardNames';
import getFilesForSelectedBoard from '@salesforce/apex/LPI_LicenseSearchDownloadController.getFilesForSelectedBoard';
export default class LpiLicenseDownload extends LightningElement {
    showSpinner = true;
    selectedBoard;
    boardSelected;
    @track boardNames;
    @track filesList

    connectedCallback() {
        this.loadData()
    }

    loadData() {
        getBoardNames().then(result => {
            if (!result || result.length === 0) {
                showMessage(this, {
                    title: "Warning",
                    message: "No Data found.",
                    messageType: "warning",
                    mode: "dismissable"
                });
                this.boardNames = null;
            } else {
                this.boardNames = result;

            }
        }).catch(error => {
            showAsyncErrorMessage(this, error);
        }).finally(() => {
            this.showSpinner = false;
        })
    }

    handleChange(event) {
        this.boardSelected = event.target.value;
    }

    handleSubmit() {
        this.showSpinner = true;
        if (this.boardSelected != 'Nursing') {
            getFilesForSelectedBoard({
                jsonData: JSON.stringify({
                    'selectedBoard': this.boardSelected
                })
            }).then(result => {
                if (!result || result.length == 0) {
                    this.filesList = null;
                    showMessage(this, {
                        title: "Warning",
                        message: "No file was found to download.",
                        messageType: "warning",
                        mode: "dismissable"
                    });
                    //Added for Accessbility issue
                    setTimeout(() => {
                        this.template.querySelector(".boardSelectionFocus").focus();
                    }, 4000);  // 4000 milliseconds (4 seconds) delay

                } else {
                    this.selectedBoard = this.boardSelected;
                    this.filesList = result;
                    this.filesList.forEach(ele => {
                        if (ele.fileName) {
                            ele.ariaLabel = 'download button for ' + ele.fileName;
                        }
                    });
                }
            }).catch(error => {
                showAsyncErrorMessage(this, error);
            }).finally(() => {
                this.showSpinner = false;
            })
        } else {
            this.filesList = null;
            showMessageLinkable(this, {
                title: "Warning",
                message: 'The Board of Nursing does not provide Downloadable Listings. Please navigate to Nursys ({0}) to verify RN and LPN licenses.',
                messageData: [
                    {
                        url: 'https://www.nursys.com/',
                        label: 'https://www.nursys.com/',
                    },
                ],
                messageType: "Warning",
                mode: "dismissable"
            });

            //Added for Accessbility issue
            setTimeout(() => {
                this.template.querySelector(".boardSelectionFocus").focus();
                this.showSpinner = false;
            }, 4000);  // 4000 milliseconds (4 seconds) delay

        }
    }

    handleDownload(event) {
        window.open(event.target.dataset.url);
    }
}