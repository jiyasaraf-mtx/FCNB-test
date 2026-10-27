import { LightningElement, api, wire } from "lwc";
import getDeadlineDays from "@salesforce/apex/LPI_ApplicationDeadlineCtrl.getDeadlineDays";

export default class LpiApplicationDeadlineNotice extends LightningElement {
  @api recordId;
  showNotice = false;
  deadlineMessage = "";

  @wire(getDeadlineDays, { applicationId: "$recordId" })
  wiredResult({ data, error }) {
    if (data !== undefined && data !== null) {
      this.deadlineMessage = `To complete the application: ${data} days.`;
      this.showNotice = true;
    } else {
      this.showNotice = false;
      if (error) {
        console.error("getDeadlineDays error", error);
      }
    }
  }
}