import { LightningElement,api,track } from 'lwc';
import saveInspectionAssessmentResponses from '@salesforce/apex/LPI_VisitRegCodeViolationController.handleSaveInspectionQues';
import { 
    showAsyncErrorMessage,
    showMessage ,
    checkLength
} from 'c/lpiUtil';
const MULTIPICKLIST_DT_TYPE = 'Multi-Select Picklist';
const NUMBER_DT_TYPE = 'Number';
const PICKLIST_DT_TYPE = 'Picklist';
const TEXT_DT_TYPE = 'String';

export default class LpiQualityAssuranceDetails extends LightningElement {

    @track quesWrapperList = [];
    disableSubmit = true;
    
    showSpinner;
    @api 
    set questions(valRecieved) {
        this.quesWrapperList = valRecieved;
        this.quesWrapperList = this.quesWrapperList.map((quesRec,idx) => {
            let tmpRec = {
                ...quesRec, 
                isPicklist : quesRec.dataType === PICKLIST_DT_TYPE,
                isNumeric : quesRec.dataType === NUMBER_DT_TYPE,
                isMultiPicklist : quesRec.dataType === MULTIPICKLIST_DT_TYPE,
                isText : quesRec.dataType === TEXT_DT_TYPE,
                index : idx,
                readonly : (quesRec.value || quesRec.numberResponseValue)
            };
            this.disableSubmit = this.disableSubmit && tmpRec.readonly;
            return tmpRec;
        });
    }
    get questions() {
        return this.quesWrapperList;
    }

    get hasQuestions() {
        return this.quesWrapperList.length > 0;
    }

    handleInputChange(event) {
        if(!this.hasQuestions) {
            return;
        }
        const questionId = event.currentTarget.dataset.questionId;
        const type = event.currentTarget.dataset.type;
        // get the index 
        const currentQuestion = this.quesWrapperList.find(rec => rec.questionId === questionId);
        if(currentQuestion) {
            if(type === NUMBER_DT_TYPE) {
                currentQuestion.numberResponseValue = event.currentTarget.value;
            }
            else if(type === PICKLIST_DT_TYPE || type === TEXT_DT_TYPE) {
                currentQuestion.value = event.currentTarget.value;
            }
            else if(type === MULTIPICKLIST_DT_TYPE) {
                currentQuestion.multiPicklistValue = event.currentTarget.value;
            }
            this.quesWrapperList[currentQuestion.index] = {...currentQuestion};
        }
    }

    saveDetails() {
        this.showSpinner = true;
        if(this.checkValidity()){
            saveInspectionAssessmentResponses({
                jsonData : JSON.stringify(this.quesWrapperList)
            })
            .then(()=>{
                this.disableSubmit = true;
                showMessage(this, {
                    title: "Success",
                    message: "Quality Assurance Details Submitted Successfully",
                    messageType: "success",
                    mode: "dismissable"
                });
                this.showSpinner = false;
            })
            .catch(err=>{
                this.showSpinner = false;
                this.disableSubmit = false;
                showAsyncErrorMessage(this,err);
            })
        }else{
            this.showSpinner = false;
        }
       
    }

    checkValidity() {
        this.focus = false;
        this.focusIndex = -1;
        let isAllValid = [...this.template.querySelectorAll('lightning-textarea,lightning-combobox,lightning-input')].reduce((validSoFar, input) => {
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
            showAsyncErrorMessage(this, 'Please validate all the input fields.')

        }
        return isAllValid;
    }


}