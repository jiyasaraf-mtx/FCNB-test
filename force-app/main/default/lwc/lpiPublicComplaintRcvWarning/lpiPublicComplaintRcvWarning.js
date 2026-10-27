import { LightningElement, api } from "lwc";
import hasCaseRelatedRcv from "@salesforce/apex/LPI_PublicComplaintRcvController.hasCaseRelatedRcv";

export default class LpiPublicComplaintRcvWarning extends LightningElement {
	_recordId;
	showWarning = false;
	showSpinner = false;
	_checkInFlight = false;

	@api
	get recordId() {
		return this._recordId;
	}
	set recordId(value) {
		if (value && value !== this._recordId) {
			this._recordId = value;
			this.checkForRcv();
		} else {
			this._recordId = value;
		}
	}

	checkForRcv() {
		if (!this._recordId || this._checkInFlight) {
			return;
		}
		this._checkInFlight = true;
		this.showSpinner = true;
		hasCaseRelatedRcv({ publicComplaintId: this._recordId })
			.then((result) => {
				this.showWarning = result === true;
			})
			.catch(() => {
				this.showWarning = false;
			})
			.finally(() => {
				this.showSpinner = false;
				this._checkInFlight = false;
			});
	}

	handleClose() {
		this.showWarning = false;
	}
}