import { LightningElement,api,track } from 'lwc';
import {
    showAsyncErrorMessage,
    checkLength
} from 'c/lpiUtil';
export default class LpiBoardSpecificComplaintQues extends LightningElement {
    
    @api boardName;
    @track inputWrapper= {
    }
    @track yesNoOptions = [{
        'label': 'Yes',
        'value': 'Yes'
    }, {
        'label': 'No',
        'value': 'No'
    }];

    @track complaintPraticeOptions = [{
        'label': 'Architecture',
        'value': 'Architecture'
    }, {
        'label': 'Engineering',
        'value': 'Engineering'
    },
    {
        'label': 'Land Surveying',
        'value': 'Land Surveying'
    },
    {
        'label': 'Landscape Architecture',
        'value': 'Landscape Architecture'
    }
    ];

    @track complaintNatureOptions = [{
        'label': 'Practice of unlicensed person',
        'value': 'Practice of unlicensed person'
    }, {
        'label': 'Incompetency',
        'value': 'Incompetency'
    }, {
        'label': 'Misconduct',
        'value': 'Misconduct'
    }, {
        'label': 'Gross Negligence',
        'value': 'Gross Negligence'
    }, {
        'label': 'Fraud',
        'value': 'Fraud'
    }, {
        'label': 'Dishonesty',
        'value': 'Dishonesty'
    }, {
        'label': 'Other',
        'value': 'Other'
    }
    ];
    get isPharmacy() {
        return this.boardName === 'Pharmacy';
    }
    get isArch() {
        return this.boardName === 'Architects, Engineers, Land Surveryors, and Landscape Architects';
    }
    get isOptometrist() { 
        return this.boardName === 'Optometry';
    }
    get isDental() {
        return this.boardName === 'Dental';
    }

    get hasDocsPhotosEvidence() {
        return this.inputWrapper.docEvidence ==='Yes';
    }
    get hasEvidenceInFormOfDrugsLabels() {
        return this.inputWrapper.prescriptionLabelEvidence ==='Yes';
    }
    get hasOutStandingBill() {
        return this.inputWrapper.outstandingBill ==='Yes';
    }
    get wasTreatedByDifferentDentist() {
        return this.inputWrapper.treatedByDifferentDentist ==='Yes';
    }
    get wasTreatedByOpto() {
        return this.inputWrapper.treatmentByDiffOpto ==='Yes';
    }
    get optoSimiliarPatients() {
        return this.inputWrapper.optoSimiliarPatients === 'Yes';
    }
    
    handleBlur(event) {
        this.dispatchEvent(new CustomEvent('focuschange',{
            detail : {
                sectionName : 'Board Specific Questions',
                name : event.currentTarget.name,
                value : event.currentTarget.value
            }
        }));
    }

    handleInputChange(event) {
        this.inputWrapper[event.currentTarget.name] = event.currentTarget.value;
    }

    @api
    checkValidity() {
        this.focus = false;
        this.focusIndex = -1;
        let isAllValid = [...this.template.querySelectorAll('lightning-input,lightning-radio-group,lightning-textarea,lightning-combobox')].reduce((validSoFar, input) => {
            input.reportValidity();
            // console.log(' INPUT NAME >> ' + input.name + ' >> ::  ' + input.checkValidity() + " <><><> " + checkLength(input));
            // if(input.name === 'outstandingBillAmount') return validSoFar;
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