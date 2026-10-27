import { LightningElement,track } from 'lwc';
import { showAsyncErrorMessage,showMessage } from 'c/lpiUtil';
import fetchRecords from '@salesforce/apex/LPI_VisitRegCodeViolationController.fetchVisitsViolationRecords';
import saveComments from '@salesforce/apex/LPI_VisitRegCodeViolationController.saveComments';
import lpiResource from '@salesforce/resourceUrl/LPI_Design';
export default class LpiViewVisitsRegCodeViolation extends LightningElement {
    
    _recordId;
    visitDetails=[];
    showSpinner = false;
    title='';
    modalHeading = '';
    @track signatureDataList = [];
    openConfirmationModal = false;
    submitDisabled = false;
	noRecord = lpiResource + '/media/icons/no-record.svg';
    patternObj = {
        text: '^((?!(<)|(>)).)*$',
        digits: '^(\\([0-9]{3}\\) |[0-9]{3}-)[0-9]{3}-[0-9]{4}$',
    }
    @track commentsData=[];
    hasEditableRec = true;
    get hasCommentsToUpdate() {
        return this.commentsData && this.commentsData.length>0;
    }
    get hasSignaturesToUpdate() {
        return this.signatureDataList && this.signatureDataList.length>0;
    }
    get isEditable() {
        return this.hasEditableRec && this.hasRecords;
    }
    connectedCallback() {
    
        const param = 'recordId';
        const paramValue = this.getUrlParamValue(window.location.href, param);
        if(paramValue) {
            this._recordId =paramValue;
            this.getAssociatedVisits();
        } 
    }

    getUrlParamValue(url, key) {
        return new URL(url).searchParams.get(key);
    }
    get hasRecords() {
        return this.visitDetails && this.visitDetails.length>0;
    }

    getAssociatedVisits() {
        this.showSpinner = true;
        fetchRecords({
            recordId : this._recordId
        })
        .then(rec=>{
            if(!rec || !rec.inspectionList) {
                return;
            }
            const {inspectionList,title} = rec;
            this.processData(inspectionList);
            this.title = title;
            this.showSpinner = false;

        })
        .catch(err=>{
            this.showSpinner = false;
            showAsyncErrorMessage(this,err);
        })
        
    }


    processData(inspectionList) {
        if(!inspectionList || inspectionList.length ===0) return;
        
        this.visitDetails = inspectionList?.map((d,idx)=> {
            let hideSubmitBtn = true;
            d.regCodeViolationList = d.regCodeViolationList?.map((s,idx)=> {
                let commentsAlreadyFilled = (s.licenseeComments?true:false);
                hideSubmitBtn = hideSubmitBtn && commentsAlreadyFilled
                return {
                    ...s,
                    sNo : idx+1,
                    isDisabled : commentsAlreadyFilled
                };
            })
            let signatureAlreadyFilled = d.comments?true:false;
            hideSubmitBtn = hideSubmitBtn && signatureAlreadyFilled;
            return {
                ...d,
                sectionDesc : `${idx+1}.    ${d.visitName}`,
                regCodeViolationSectionDesc : `Regulatory Code Violations for ${d.visitName}`,
                hasCodeViolation : d.regCodeViolationList.length>0,
                isDisabled : signatureAlreadyFilled,
                hasQualityAssuranceForm : d.inspectionAssessmentQuestions && d.inspectionAssessmentQuestions.length > 0,
                hideSubmitBtn : hideSubmitBtn,
                sNo : idx+1
            }
        });
    }

    specificSignDataObj = {};
    specificCommentList = [];
    storedVisitId;

    saveCommentsHandler(event) {
        const visitName = event.currentTarget.dataset.visitName;
        const visitId = event.currentTarget.dataset.visitId;
        console.log('visit id',visitId);
        let isValid = true;
        // Trimming down list to specific visit details card.
        this.specificSignDataObj = {};
        this.specificCommentList = [];
        
        this.template.querySelectorAll('.picMicSignature').forEach(rec => {
            rec.setCustomValidity('');
            rec.reportValidity();
            if(rec.dataset.visitId === visitId) {
                if(!rec.value) {
                    isValid = false;
                    rec.focus();
                    rec.setCustomValidity('PIC/MIC Signature is Required.');
                    rec.reportValidity();
                } else {
                    this.specificSignDataObj = {
                        visitId : visitId,
                        idx : rec.dataset.index,
                        comments : rec.value
                    }
                }
            }
        });


        //let specificCommentList = this.commentsData.filter(rec=>rec.visitId === visitId);
        this.template.querySelectorAll('.licenseeComments').forEach(rec => {
            rec.setCustomValidity('');
            rec.reportValidity();
            if(rec.dataset.visitId === visitId){
                if(!rec.value) {
                    rec.focus();
                    isValid = false;
                    rec.setCustomValidity('Licensee Comments is Required.');
                    rec.reportValidity();
                } else {
                    this.specificCommentList.push({
                        'rcvId' : rec.dataset.rcvId,
                        'comments' : rec.value,
                        'visitId' : rec.dataset.visitId
                    });
                }
            }
        });

        if(isValid) {
            this.storedVisitId = visitId;
            this.openModal(visitName);
        } else {
            showMessage(this, {
                title: "Error",
                message: "Please validate all the Inputs.",
                messageType: "error",
                mode: "dismissable"
            });
        }
        
    }


    saveCommentHelper() {
        this.openConfirmationModal = false;
        this.showSpinner = true;
        this.submitDisabled = true;
         console.log('specificCommentList',JSON.stringify(this.specificCommentList));
         console.log('specificSignDataObj',JSON.stringify(this.specificSignDataObj));
    
              saveComments({
                commentsWrapper : JSON.stringify({
                    licenseeCommentsDataList : this.specificCommentList,
                    picCommentsDataList :this.specificSignDataObj!=null?[this.specificSignDataObj]:[]
                })
            })
            
            .then(rec=>{
                if(!rec) return;
                showMessage(this, {
                    title: "Success",
                    message: "Thank you for your response, the board will reach out to you with the next steps.",
                    messageType: "success",
                    mode: "dismissable"
                });
                this.showSpinner = false;
                this.submitDisabled = false;

                this.disableCommentFieldsOnSave();

            })
            .catch(err=>{
                this.showSpinner = false;
                showAsyncErrorMessage(this,err);
            })
    }

    disableCommentFieldsOnSave() {

        this.template.querySelectorAll(`[data-visit-id="${this.storedVisitId},"]`).forEach(rec=>{
            rec.disabled = true;
        });
        this.visitDetails?.forEach( d => {
            if( d && d.visitId == this.storedVisitId) {

                d.regCodeViolationList?.forEach(s =>{
                    s.isDisabled  =true;
                    s.hideSubmitBtn = true;
                })
                d.isDisabled = true;
                d.hideSubmitBtn = true;
            }
        });
    }

    openModal(visitName) {
        this.modalHeading = 'Are you sure you want to Submit Details for '+visitName;
        this.openConfirmationModal = true;
    }

    handleCancelConfirmation() {
        this.openConfirmationModal = false;
        this.modalHeading = '';

    }
    checkValidity() {
        this.focus = false;
        this.focusIndex = -1;
        let isAllValid = [...this.template.querySelectorAll('lightning-input,lightning-textarea')].reduce((validSoFar, input) => {
            input.reportValidity();
            let valid = input.checkValidity();
            valid = input.disabled ? true : valid;
            if (!valid && (!this.focus || this.focusIndex == -1 || this.focusIndex > parseInt(input.dataset.index))) {
                input.focus();
                this.focus = true;
                this.focusIndex = input.dataset.index;
            }
            return validSoFar && valid;
        }, true);
       
        if (!isAllValid) {
            showAsyncErrorMessage(this, 'Please validate all the input fields.')
        }

        return isAllValid;
    }


}