import { LightningElement, track } from 'lwc';
import fetchBoardsDetails from '@salesforce/apex/LPI_RecommendedLicenseCtrl.fetchBoardsDetails';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import createApplication from '@salesforce/apex/LPI_RecommendedLicenseCtrl.createApplication';
import setLanguage from '@salesforce/apex/EMP_LanguageCtrl.setLanguage';
import { withOmniLanguage, resolveOmniLanguageCode } from 'c/lpLanguageUtils';

export default class Lpi_recommendedLicenseContainer extends LightningElement {
    filterRegType = [
        { label: 'Apply for Individual License', value: 'Individual' },
        { label: 'Apply for Business/Entity License', value: 'Business' }
    ];
    selectedRegType = 'Individual';
    showSpinner = false;
    showRegList = true;
    licenseNameSearch = '';
    selectedSorting = 'asc';
    baordSearchName = '';
    searchAriaLabelLicense = 'Search License here...';
    searchAriaLabelBoard = 'Search Board here...';
    sortingDescAriaLabel = 'Sort elements in descending order';
    sortingAscAriaLabel = 'Sort elements in ascending order';

    @track selectedBoardFilter = '';
    @track mainRegList = [];
    @track allPageData;
    @track boardList = [];
    @track isOpen = true;

    get className() {
        return this.isOpen
            ? 'slds-accordion__section slds-is-open'
            : 'slds-accordion__section';
    }
    get icon() {
        return this.isOpen ? 'utility:chevrondown' : 'utility:chevronright';
    }

    handleToggleAccordionClick(event) {
        this.isOpen = !this.isOpen;
    }
    connectedCallback() {
        this.fetchBoardsDetails();
    }
    fetchBoardsDetails() {
        fetchBoardsDetails({})
            .then((result) => {
                this.allPageData = result;
                if(result.showOnlyBusiness){
                    this.filterRegType =  [
                        { label: 'Apply for Business/Entity License', value: 'Business' }
                    ];
                    this.selectedRegType = 'Business';
                    this.mainRegList = JSON.parse(
                        JSON.stringify(result.typeWithRegAuthMap.Business)
                    );
                }else{
                    this.filterRegType =  [
                        { label: 'Apply for Individual License', value: 'Individual' },
                        { label: 'Apply for Business/Entity License', value: 'Business' }
                    ];
                    this.mainRegList = JSON.parse(
                        JSON.stringify(result.typeWithRegAuthMap.Individual)
                    );
                    this.selectedRegType = 'Individual';
                }
                this.boardList = JSON.parse(JSON.stringify(result.boardList));
								this.boardList.sort();
                console.log('--- this.boardList -->'+this.mainRegList);
                
            })
            .catch((error) => {
                this.showToast('Error', error.body.message, 'error');
            });
    }
    handleSelectedRegType(event) {
        this.selectedRegType = event.target.value;
        this.handleFetchData(this.licenseNameSearch, this.selectedBoardFilter);
    }
    showToast(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(evt);
    }
    searchLicenseAction(event) {
        this.searchAriaLabelLicense = '';
        this.licenseNameSearch = event.target.value;
        let searchKey = event.target.value;
        this.handleFetchData(searchKey, this.selectedBoardFilter);
    }
    sortTheData(event) {
        if (event != null) {
            this.selectedSorting = event.target.dataset.id;
        }
        if (this.selectedSorting == 'asc') {
            this.mainRegList.sort((a, b) => {
                if (a.name < b.name) {
                    return -1;
                }
                if (a.name > b.name) {
                    return 1;
                }
                return 0;
            });
        } else {
            this.mainRegList.sort((a, b) => {
                if (a.name > b.name) {
                    return -1;
                }
                if (a.name < b.name) {
                    return 1;
                }
                return 0;
            });
        }
        if (event != null) {
            // eslint-disable-next-line @lwc/lwc/no-async-operation
            setTimeout(() => {
                if (this.selectedSorting == 'asc') {
                    this.sortingAscAriaLabel =
                        'Elements sorted in ascending order';
                } else {
                    this.sortingDescAriaLabel =
                        'Elements sorted in descending order';
                }

                this.template
                    .querySelector(`[data-id="${this.selectedSorting}"]`)
                    .focus();
            }, 500);
        }
    }
    clearFilterAction() {
        this.selectedSorting = 'asc';
        this.licenseNameSearch = '';
        this.baordSearchName = '';
        this.mainRegList = JSON.parse(
            JSON.stringify(
                this.allPageData.typeWithRegAuthMap[this.selectedRegType]
            )
        );
        this.boardList = JSON.parse(JSON.stringify(this.allPageData.boardList));
        this.searchAriaLabelLicense = 'Search License here...';
        this.searchAriaLabelBoard = 'Search Board here...';
        setTimeout(() => {
            this.template.querySelector('.license-searchbox-input').focus();
        }, 500);
    }
    handleBoardChangeAction(event) {
        this.baordSearchName = event.target.value;
        let searchKey = event.target.value;
        var temArr = [];
        var mainData = JSON.parse(JSON.stringify(this.allPageData.boardList));
        mainData.forEach(function (arrayItem) {
            let name = arrayItem.toLowerCase();
            let subStr = searchKey.toLowerCase();
            if (name.includes(subStr)) {
                temArr.push(arrayItem);
            }
        });
        this.boardList = temArr;
        this.changeAriaLabelBoard();
    }
    handleSelectedBoard(event) {
        this.selectedBoardFilter = event.target.dataset.id;
        this.handleFetchData(this.licenseNameSearch, this.selectedBoardFilter);
        setTimeout(() => {
            this.template.querySelector('.focus-helper').focus();
        }, 500);
    }
    handleFetchData(searchKey, boardFilter) {
        var temArr = [];
        var mainData = JSON.parse(
            JSON.stringify(
                this.allPageData.typeWithRegAuthMap[this.selectedRegType]
            )
        );
        mainData.forEach(function (arrayItem) {
            let name = arrayItem.name.toLowerCase();
            let subStr = searchKey.toLowerCase();
            if (
                name.includes(subStr) &&
                (boardFilter == '' ||
                    (boardFilter != '' &&
                        arrayItem.issuingDepartmentName == boardFilter))
            ) {
                temArr.push(arrayItem);
            }
        });
        this.mainRegList = temArr;
        this.sortTheData(null);
        this.changeAriaLabelLicense();
    }
    handleApplyOnline(event) {
        this.showSpinner = true;
        let data = {
            regAuthId: event.target.dataset.id,
            type: 'New'
        };
        this.handleAction(data);
    }
    handleAction(data) {
        createApplication({
            inputMap: data
        })
            .then((result) => {
                this.showSpinner = false;
                if (result == 'Duplicate') {
                    this.showToast(
                        'Info',
                        'The same application has already been submitted or a draft application has been created. Go to My Applications section on Dashboard in order to access it.',
                        'info'
                    );
                } else if (result == 'Error') {
                    this.showToast(
                        'Error',
                        'Something went wrong.Please contact your adminstration!!',
                        'error'
                    );
                } else {
                    const lang = resolveOmniLanguageCode();
                    setLanguage({ languageLocaleKey: lang })
                        .catch(() => {
                            // Community users may be blocked from User language update
                        })
                        .finally(() => {
                            result = withOmniLanguage(result + '&type=New');
                            window.open(result, '_self');
                        });
                }
            })
            .catch((error) => {
                this.showSpinner = false;
                this.showToast('Error', error?.body?.message, 'error');
            });
    }
    knowMoreHandler(event) {
        let index = event.target.dataset.id;
        if (this.mainRegList[index]['knowMoreIsOpen']) {
            this.mainRegList[index]['knowMoreClassName'] =
                'slds-section slds-is-close';
            this.mainRegList[index]['knowMoreIconName'] =
                'utility:chevronright';
            this.mainRegList[index]['knowMoreIsOpen'] = false;
        } else {
            this.mainRegList[index]['knowMoreClassName'] =
                'slds-section slds-is-open';
            this.mainRegList[index]['knowMoreIconName'] = 'utility:chevrondown';
            this.mainRegList[index]['knowMoreIsOpen'] = true;
        }
    }
    changeAriaLabelLicense(e) {
        setTimeout(() => {
            if (this.mainRegList && this.mainRegList.length > 0) {
                this.searchAriaLabelLicense =
                    this.mainRegList.length + ' results found';
            } else {
                this.searchAriaLabelLicense = 'No results found';
            }
            this.template.querySelector('.license-searchbox-input').focus();
        }, 500);
    }
    changeAriaLabelBoard() {
        setTimeout(() => {
            if (this.boardList && this.boardList.length > 0) {
                this.searchAriaLabelBoard =
                    this.boardList.length + ' results found';
            } else {
                this.searchAriaLabelBoard = 'No results found';
            }
            this.template.querySelector('.board-searchbox-input').focus();
        }, 500);
    }
}