import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getCompletePendingPaymentNavData from '@salesforce/apex/LPI_InternalPaymentController.getCompletePendingPaymentNavData';

export default class LpiCompletePendingPaymentAction extends NavigationMixin(LightningElement) {
	@api recordId;
	_hasNavigated = false;

	connectedCallback() {
		// Screen actions set recordId slightly after construct; retry briefly
		this.tryNavigate(0);
	}

	tryNavigate(attempt) {
		if (this._hasNavigated) {
			return;
		}
		if (!this.recordId) {
			if (attempt < 10) {
				// eslint-disable-next-line @lwc/lwc/no-async-operation
				window.setTimeout(() => this.tryNavigate(attempt + 1), 100);
			} else {
				this.showToast('Error', 'Record Id is missing.', 'error');
				this.closeAction();
			}
			return;
		}
		this.navigateToPendingPayment();
	}

	navigateToPendingPayment() {
		if (this._hasNavigated) {
			return;
		}
		this._hasNavigated = true;
		getCompletePendingPaymentNavData({ recordId: this.recordId })
			.then((navData) => {
				if (!navData || !navData.applicationId) {
					this.showToast('Error', 'Unable to load pending payment details.', 'error');
					this.closeAction();
					return;
				}
				if (!navData.isPaymentPending) {
					this.showToast(
						'Info',
						'There is no pending payment on this application.',
						'info'
					);
					this.closeAction();
					return;
				}
				const state = {
					c__recordId: navData.applicationId,
					c__applicationId: navData.applicationId,
					c__licenseTypeId: navData.licenseTypeId,
					c__accId: navData.accId,
					c__objectType: navData.objectType,
					c__applicationType: navData.applicationType,
					c__applicationSubType: navData.applicationSubType || '',
					c__isBadCheckPayment: 'false',
					c__isOverPayment: 'false'
				};
				if (navData.regTrxFeeId) {
					state.c__regTrxFeeId = navData.regTrxFeeId;
				}
				this[NavigationMixin.Navigate]({
					type: 'standard__component',
					attributes: {
						componentName: 'c__lpiPendingPaymentComp'
					},
					state
				});
				// Close modal after navigation is queued
				// eslint-disable-next-line @lwc/lwc/no-async-operation
				window.setTimeout(() => this.closeAction(), 300);
			})
			.catch((error) => {
				const message =
					(error && error.body && error.body.message) ||
					(error && error.message) ||
					'Something went wrong while opening pending payment.';
				this.showToast('Error', message, 'error');
				this.closeAction();
			});
	}

	closeAction() {
		this.dispatchEvent(new CloseActionScreenEvent());
	}

	showToast(title, message, variant) {
		this.dispatchEvent(
			new ShowToastEvent({
				title,
				message,
				variant
			})
		);
	}
}