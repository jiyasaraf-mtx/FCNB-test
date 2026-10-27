/*
  @description       : Using this to open Inspection Report vfpage pdf in new tab
  @author            : Ankit Bansal
  @group             : 
  @last modified on  : 04-22-2024
  @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
*/
import { LightningElement,api } from 'lwc';

export default class LpiInspectionReportForm extends LightningElement {

    @api recordId;
    @api invoke() {
        // Construct the URL for the Visualforce page
        const vfPageUrl = '/apex/LPI_InspectionReport?id='+this.recordId;

        // Open the Visualforce page in a new browser tab or window
        window.open(vfPageUrl, '_blank');
    }
}