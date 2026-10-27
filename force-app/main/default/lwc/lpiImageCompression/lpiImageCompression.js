import {
    LightningElement,
    api
} from 'lwc';
import {
    showAsyncErrorMessage
} from 'c/lpiUtil';
import handleUploadFileSalesforce from '@salesforce/apex/LPI_GetApplicationDocumentController.handleUploadFileSalesforce';
const RESIZING_FACTOR = 0.2;
const IMAGE_QUALITY = 0.7;
export default class ImageCompressPOC extends LightningElement {
    originalImage;
    isProcessing;
    // @api 
    // linkedEntityId
    @api file;
    //added default image type
    selectedImgType = 'image/jpeg';
    @api
    async handleUpload(fileData, linkedEntityId) {
        const [imgToCompress] = fileData || this.file;
        this.linkedEntityId = linkedEntityId;
        this.originalImage = new Image();
        this.originalImage.name = imgToCompress.name;
        this.selectedImgType = imgToCompress.type;

        if (imgToCompress.size / 1e6 > 1) {
            //Bining On Load Event
            this.originalImage.onload = this.compressImageAndSave.bind(this);
            this.originalImage.src = await this.fileToDataUri(imgToCompress);
        } else {
            const base64String = await this.fileToDataUri(imgToCompress);
            return this.saveImage(base64String);
        }


    }
    compressImageAndSave() {
        const canvas = document.createElement("canvas");
        const context = canvas.getContext("2d");
        const originalWidth = this.originalImage.width;
        const originalHeight = this.originalImage.height;
        const canvasWidth = originalWidth * RESIZING_FACTOR;
        const canvasHeight = originalHeight * RESIZING_FACTOR;
        canvas.width = canvasWidth;
        canvas.height = canvasHeight;
        context.drawImage(this.originalImage,
            0, 0,
            canvasWidth,
            canvasHeight
        );
        const base64String = canvas.toDataURL(this.selectedImgType, IMAGE_QUALITY).replace(/^data:image\/(png|jpeg);base64,/, "");
        return this.saveImage(base64String);
    }

    async saveImage(base64String) {
        const base64Mark = 'base64,';
        const dataStart = base64String.indexOf(base64Mark) + base64Mark.length;

        base64String = base64String.substring(dataStart);
        this.isProcessing = true;
        let fileToUpload = {
            'fileName': this.originalImage.name,
            'base64': base64String,
            'fileType': this.selectedImgType,
            'linkedEntityId': this.linkedEntityId
        }

        await handleUploadFileSalesforce({
                jsonData: JSON.stringify(fileToUpload)
            })
            .then(() => {
                return 'success'
            }).catch(error => {
                showAsyncErrorMessage(this, error); // 'Error occured while Loading. ', error, 'error', 'pester'
            }).finally(() => {
                this.isProcessing = false;
            })
    }

    fileToDataUri(field) {
        return new Promise((resolve) => {
            const reader = new FileReader();
            reader.addEventListener("load", () => {
                resolve(reader.result);
            });
            reader.readAsDataURL(field);
        });
    }
}