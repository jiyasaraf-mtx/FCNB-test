import { LightningElement, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
// import My_Resource from '@salesforce/resourceUrl/LP_Design';
import getAcrRecords from '@salesforce/apex/LPI_FCDashboardProfileCompletion.getAcrRecords';
import updateAcrSelectedOnParentAccount from '@salesforce/apex/LPI_FCDashboardProfileCompletion.updateAcrSelectedOnParentAccount';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import MyResource from '@salesforce/resourceUrl/LPI_Design';

const INSURER_REVIEW_STORAGE_KEY = 'emp_insurer_review_page';
const INSURER_REVIEW_EVENT = 'empinsurernavigate';

export default class EmployerHomePage extends NavigationMixin(LightningElement) {
      // homepageDashboad = My_Resource + '/icons/homepage_dashboard.svg';
    // homepageLicense = My_Resource + '/icons/homepage_mylicenses.svg';
    // homepageApplications = My_Resource + '/icons/homepage_myapplication.svg';
    dashboardImg = MyResource + '/media/icons/dashboard.svg';

    openBusinessModal = false;
    showBusinessAccountList = false;
    isSelectBusinessTypeAvailable = false;
    @track pageMode = 'dashboard';

    get selectedAccountList() {
        return [
            { label: 'Personal Account', value: 'Personal Information' },
            { label: 'Existing Business Account', value: 'Business Account' },
            { label: 'New Business Account', value: 'New Business Account' }
        ];
    }

    get isDashboardMode() {
        return this.pageMode !== 'queue';
    }

    get isQueueMode() {
        return this.pageMode === 'queue';
    }

    connectedCallback() {
        this.pageMode = this.readInsurerReviewPage() || 'dashboard';
        this._onInsurerNav = (event) => {
            if (event?.detail?.page) {
                this.pageMode = event.detail.page;
            }
        };
        window.addEventListener(INSURER_REVIEW_EVENT, this._onInsurerNav);
        //S-44731
        this.selectBusinessAccount();
    }

    disconnectedCallback() {
        if (this._onInsurerNav) {
            window.removeEventListener(INSURER_REVIEW_EVENT, this._onInsurerNav);
        }
    }

    readInsurerReviewPage() {
        try {
            return window.sessionStorage.getItem(INSURER_REVIEW_STORAGE_KEY);
        } catch (e) {
            return null;
        }
    }
    handleAccount(event){
        this.showBusinessAccountList = false;
        this.selectedAccountId = this.psersonalAccountDetail.Id;
        this.template.querySelector('.selectPersonal').classList.add('active');
        this.template.querySelector('.selectBusiness').classList.remove('active');
        this.template.querySelector('.selectNewBusiness').classList.remove('active');
    }
    handleNewBusiness(event){
        this.showBusinessAccountList = false;
        this.selectedAccountId = this.psersonalAccountDetail.Id;
        this.template.querySelector('.selectNewBusiness').classList.add('active');
        this.template.querySelector('.selectBusiness').classList.remove('active');
        this.template.querySelector('.selectPersonal').classList.remove('active');
    }
    handleBusinessAccount(event){
        this.showBusinessAccountList = true;
        this.selectedAccountId = '';
        this.template.querySelector('.selectBusiness').classList.add('active');
        this.template.querySelector('.selectNewBusiness').classList.remove('active');
        this.template.querySelector('.selectPersonal').classList.remove('active');
    }

    // handleChangeAccount(event) {
    //     this.selectedType = event.target.value;
    //     if (this.selectedType == 'Business Account') {
    //         this.showBusinessAccountList = true;
    //         this.selectedAccountId = '';
    //     } else {
    //         this.showBusinessAccountList = false;
    //         this.selectedAccountId = this.psersonalAccountDetail.Id;
    //     }
    // }

    navigateToApplyForLicense(){
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: 'Recommended_Profession__c'
          }
        });
    }
    navigateToRenewLicense(){
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: 'Renew_License__c'
          }
        });
    }
    
    navigateToFileComplaints(){
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: 'complaint_form__c'
          }
        });
    }
    navigateToDashboard(){
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: 'Dashboard__c'
          }
        });
    }
    navigateToMyApplications(){
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: 'My_Applications__c'
          }
        });
    }
    navigateToMyLicenses(){
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: 'My_Licenses__c'
          }
        });
    }

    selectBusinessAccount() {
        getAcrRecords({})
            .then((result) => {
                if (result.accList) {
                    this.psersonalAccountDetail = result.accList[0];
                    this.acrList = result.accList;
                    this.acrList.shift();
                    this.acrList.shift();
                }
                if (result.accInfo) {
                    this.openBusinessModal = false;
                } else {
                    // Skip modal — default to Individual/Person Account (no flicker)
                    this.openBusinessModal = false;
                    this.selectedAccountId = this.psersonalAccountDetail?.Id;
                    this.selectedType = 'Personal Information';
                    if (this.selectedAccountId) {
                        updateAcrSelectedOnParentAccount({
                            accountId: this.selectedAccountId
                        }).catch((error) => {
                            this.showMessage(
                                'Error',
                                error?.body?.message,
                                'error'
                            );
                        });
                    }
                }
            })
            .catch((error) => {
                this.showMessage('Error', error?.body?.message, 'error');
            });
    }
    handleBusinessChange(event) {
        this.selectedAccountId = event.target.value;
        this.isSelectBusinessTypeAvailable = false;
    }
    handleConfirm() {
        try {
            if (
                this.selectedAccountId &&
                this.selectedAccountId !== '' &&
                this.selectedAccountId !== undefined
            ) {
                updateAcrSelectedOnParentAccount({
                    accountId: this.selectedAccountId
                })
                    .then((result) => {
                        location.reload();
                    })
                    .catch((error) => {
                        this.showMessage(
                            'Error',
                            error?.body?.message,
                            'error'
                        );
                    });
            } else {
                this.checkvalidity();
                const reqField = this.selectedType === null || this.selectedType === undefined ? 'Account Type' : 'Business Account';
                const evt = new ShowToastEvent({
                    title: 'Error',
                    message: 'Please select '+reqField+' Field!!',
                    variant: 'error'
                });
                this.dispatchEvent(evt);
                this.showSelectTypeErrorMsg();
            }
        } catch (error) {
            this.showMessage('Error', error?.body?.message, 'error');
        }
    }
    showSelectTypeErrorMsg(){
        if (this.selectedType === undefined || this.selectedType === null) {
            this.isSelectBusinessTypeAvailable = false;
            this.selectBusinessTypeErrorMessage = "";
        }else {
            this.isSelectBusinessTypeAvailable = true;
            this.selectBusinessTypeErrorMessage = "Error:Business Account is required.";
        }
    }
    checkvalidity() {
        let validRadio = [
            ...this.template.querySelectorAll('lightning-radio-group')
        ].reduce((validSoFar2, input) => {
            input.reportValidity();
            return validSoFar2 && input.checkValidity();
        }, true);

        let allInput = this.template.querySelector('.slds-has-error');

        if (allInput) {
            allInput.scrollIntoView();
            allInput.focus();
        }

        return validRadio;
    }
     // Focus Leak Acessibiltiy Issue 
     focusFirstEle() {
        const focusableElements = 'lightning-combobox, lightning-button-icon, button, lightning-helptext, lightning-input, lightning-button, lightning-radio-group';
        const modal = this.template.querySelector('.slds-modal');
        const firstFocusableElement = modal.querySelectorAll(focusableElements)[0];
        const focusableContent = modal.querySelectorAll(focusableElements);
        const lastFocusableElement = focusableContent[focusableContent.length - 1];
        firstFocusableElement.focus();
        this.template.addEventListener('keydown', function (event) {
            let isTabPressed = event.key === 'Tab' || event.keyCode === 9;
            if (!isTabPressed) {
                return;
            }
            if (event.shiftKey) {
                if (this.activeElement === firstFocusableElement) {
                    lastFocusableElement.focus();
                    event.stopPropagation()
                    event.preventDefault();
                }
            } else {
                if (this.activeElement === lastFocusableElement) {
                    firstFocusableElement.focus();
                    event.preventDefault();
                    event.stopPropagation()
                }
            }
        });
    }
    showMessage(title,message, variant) {
        const toastEvt = new ShowToastEvent({
            title,
            message,
            variant
        });
        this.dispatchEvent(toastEvt);
    } 

}