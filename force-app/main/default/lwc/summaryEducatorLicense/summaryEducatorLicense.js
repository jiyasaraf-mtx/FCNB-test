import { LightningElement,api,wire} from 'lwc';
import IADataWrapper from '@salesforce/apex/SummaryEducatorLicenseController.getPersonalInformation';
import getIaId from '@salesforce/apex/SummaryEducatorLicenseController.getIaId';
import { CurrentPageReference } from 'lightning/navigation';

export default class SummaryEducatorLicense extends LightningElement {
    @api recordId;
    iaId;
    resultData;
    urlId;
    iaId;
    iaName = '';
    
    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
       // console.log(json.stringify(currentPageReference));
       if (currentPageReference) {
          this.urlId = currentPageReference.state?.c__parid;
          console.log('this.urlId',this.urlId);
          this.iaId = this.urlId;
       }
    }
    @wire(CurrentPageReference)
    currentPageReference;
    connectedCallback() {
        console.log('recordId',this.recordId);
        console.log('current page url');
        console.log(window.location.href);  
        this.iaName = this.currentPageReference.state.name;    
        console.log('this.iaName',this.iaName);
       if(this.recordId != undefined ||  this.iaName != ''){
        IADataWrapper({recordId:this.recordId,IaName:this.iaName})
        .then(result=>{
            console.log('result',result);
            this.resultData = result;
            console.log('resultData', this.resultData.FirstName);
        })
        .catch(error=>{
            console.log('error',error);
        })
       }
       if(this.iaId != null && this.iaId != ''){
        getIaId({parId:this.iaId})
        .then(result=>{
            console.log('result',result);
            this.resultData = result;
            console.log('resultData', this.resultData.FirstName);
        })
        .catch(error=>{
            console.log('error',error);
        })
       }
       console.log('this.iaId ',this.iaId );
       if(this.iaId != null && this.iaId != ''){
        
       }
       

        // if (this.pageRef) {

        //     // Retrieve the URL parameters
            
        //     const urlParams = new URLSearchParams(this.pageRef.attributes.url);
            
        //     // Get the value of a specific parameter, for example, 'myParam'
            
        //     const myParamValue = urlParams.get('c__parid');
            
        //     // Do something with the parameter value
            
        //     console.log('myParamValue:', myParamValue);
            
        //     }
    }
    handleToggleSection(){

    }
}