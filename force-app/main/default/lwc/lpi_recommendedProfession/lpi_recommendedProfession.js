import { LightningElement, track } from 'lwc';
import fetchProfessionDetails from '@salesforce/apex/LPI_RecommendedProfessionCtrl.fetchProfessionDetails';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import createApplication from '@salesforce/apex/LPI_RecommendedLicenseCtrl.createApplication';
import fetchBusinessLicenseId from '@salesforce/apex/LPI_RecommendedLicenseCtrl.fetchBusinessLicenseId';
import validateLicenseFromENotifyService from '@salesforce/apex/LPI_ApplicationViewController.validateLicenseFromENotifyService';
import fetchBLBadCheck from '@salesforce/apex/LPI_ApplicationFlowUtility.fetchBLBadCheck';
import getCurrentLanguage from '@salesforce/apex/EMP_LanguageCtrl.getCurrentLanguage';
import getLabels from '@salesforce/apex/EMP_LanguageCtrl.getLabels';
import setLanguage from '@salesforce/apex/EMP_LanguageCtrl.setLanguage';
import {
    RECOMMENDED_PROFESSION_LABEL_API_NAMES,
    mapApiToCamel,
    readStoredLanguage,
    writeStoredLanguage,
    withOmniLanguage,
    resolveOmniLanguageCode
} from 'c/lpLanguageUtils';

export default class Lpi_recommendedProfession extends LightningElement {
    @track labels = {
        applyNewCertificate: 'Apply for new License',
        recommended: 'Recommended',
        getALicense: 'Get a License',
        applyOnline: 'Apply Online',
        selectLicenseType: 'Select License Type',
        noSelection: 'No Selection',
        searchHere: 'Search here',
        individualProfessions: 'Individual Professions',
        businessEntityProfessions: 'Business/Entity Professions',
        schoolsPrograms: 'Schools/Programs',
        otherApplications: 'Other Applications',
        professionSearchPlaceholder:
            'Enter and choose the profession for which you want to obtain a license.',
        loading: 'Loading...',
        ok: 'OK',
        category: 'Category'
    };

    filterRegType = [];
    selectedRegType = 'Individual';
    @track professionData = [];
    @track searchAriaLabelLicense =
        'Enter and choose the profession for which you want to obtain a license.';
    searchAriaLabelBoard = 'Search Board here...';
    sortingAriaLabel = 'Sort elements in descending order';
    showSpinner = false;
    showRegList = true;
    licenseNameSearch = '';
    selectedSorting = 'asc';
    baordSearchName = '';
    statusCode = null;
    showEnotifyModal = false;
    enotifyMessageText = '';
    headerNotifyMsg = '';
    currentLanguage = 'en_US';

    @track selectedBoardFilter = '';
    @track mainRegList = [];
    @track allPageData;
    @track boardList = [];
    @track isOpen = true;
    @track requestData = {};

    get isColourRed() {
        return this.statusCode === 0;
    }
    get isColourGreen() {
        return this.statusCode === 2;
    }
    get isColourYellow() {
        return this.statusCode === 1;
    }
    get isError() {
        return this.statusCode === -1;
    }

    connectedCallback() {
        setTimeout(() => {
            const radioGroup = this.template.querySelector('.license-radio-group');
            if (radioGroup) {
                radioGroup.focus();
            }
        }, 1000);
        this.initLanguage();
    }

    async initLanguage() {
        const stored = readStoredLanguage();
        let lang = stored;
        if (!lang) {
            try {
                lang = await getCurrentLanguage();
            } catch (e) {
                lang = 'en_US';
            }
        }
        this.currentLanguage = lang === 'fr' ? 'fr' : 'en_US';
        writeStoredLanguage(this.currentLanguage);
        try {
            const apiMap = await getLabels({
                apiNames: RECOMMENDED_PROFESSION_LABEL_API_NAMES,
                language: this.currentLanguage
            });
            this.labels = { ...this.labels, ...mapApiToCamel(apiMap) };
            this.searchAriaLabelLicense = this.labels.professionSearchPlaceholder;
        } catch (e) {
            // keep defaults
        }
        this.fetchProfessionDetails();
    }

    buildFilterOptions(showOnlyBusiness) {
        if (showOnlyBusiness) {
            return [
                {
                    label: this.labels.businessEntityProfessions,
                    value: 'Business'
                },
                { label: this.labels.schoolsPrograms, value: 'Schools/Programs' }
            ];
        }
        return [
            { label: this.labels.individualProfessions, value: 'Individual' },
            {
                label: this.labels.businessEntityProfessions,
                value: 'Business'
            },
            { label: this.labels.schoolsPrograms, value: 'Schools/Programs' },
            { label: this.labels.otherApplications, value: 'Other' }
        ];
    }

    fetchProfessionDetails() {
        fetchProfessionDetails({ language: this.currentLanguage })
            .then((result) => {
                this.allPageData = result;
                if (result.showOnlyBusiness) {
                    this.filterRegType = this.buildFilterOptions(true);
                    this.selectedRegType = 'Business';
                    this.professionData = JSON.parse(
                        JSON.stringify(result.typeWithProfessionMap.Business || [])
                    );
                } else {
                    this.filterRegType = this.buildFilterOptions(false);
                    this.selectedRegType = 'Individual';
                    this.professionData = JSON.parse(
                        JSON.stringify(
                            result.typeWithProfessionMap.Individual || []
                        )
                    );
                }
            })
            .catch((error) => {
                this.showToast('Error', this.resolveErrorMessage(error), 'error');
            });
    }

    resolveErrorMessage(error) {
        return (
            error?.body?.message ||
            error?.body?.pageErrors?.[0]?.message ||
            (Array.isArray(error?.body) ? error.body.map((e) => e.message).filter(Boolean).join(' ') : null) ||
            error?.message ||
            'Something went wrong. Please try again.'
        );
    }

    isObjectEmpty(objectName) {
        return Object.keys(objectName).length === 0;
    }

    handleApplyOnline(event) {
        const dataset = event.currentTarget?.dataset || event.target?.dataset || {};
        if (String(dataset.decision) === 'true') {
            let data = {
                type: 'New',
                regAuthId: dataset.reg
            };
            if (!data.regAuthId) {
                this.showToast(
                    'Error',
                    'Regulatory Authorization Type is missing for this profession.',
                    'error'
                );
                return;
            }
            this.showSpinner = true;
            fetchBusinessLicenseId({
                inputMap: data
            })
                .then((result) => {
                    if (result && !this.isObjectEmpty(result)) {
                        data = { ...data, ...result };
                        this.requestData = data;
                    }
                    if (data['type'] === 'Reinstatement') {
                        this.handleActionForReinstatement(data);
                    } else {
                        this.handleAction(data);
                    }
                })
                .catch((error) => {
                    this.showSpinner = false;
                    this.showToast('Error', this.resolveErrorMessage(error), 'error');
                });
        } else {
            let url = '/s/decision-tree?profesionId=' + dataset.id;
            window.open(url, '_self');
        }
    }

    handleActionForReinstatement(data) {
        this.showSpinner = true;
        validateLicenseFromENotifyService({
            blId: data['blId']
        })
            .then((result) => {
                if (result.isValidated) {
                    this.statusCode = result.status;
                    this.enotifyMessageText = result.message;
                    this.headerNotifyMsg = result.headerNotifyMsg;
                    this.showEnotifyModal = true;
                    this.showSpinner = false;
                }
            })
            .catch((error) => {
                this.showToast('Error', this.resolveErrorMessage(error), 'error');
                this.showSpinner = false;
            });
    }

    handleENotifyModalOnClose(event) {
        if (event.target.name && event.target.name === 'confirm') {
            if (this.isColourGreen) {
                this.showSpinner = true;
                fetchBLBadCheck({
                    inputMap: this.requestData
                })
                    .then((badCheck) => {
                        if (badCheck) {
                            this.showToast(
                                'Error',
                                'We regret to inform you that your License has been put on hold, therefore you will be unable to submit any new applications at this time. Please contact the board for further information.',
                                'error'
                            );
                            this.showSpinner = false;
                        } else {
                            this.handleAction(this.requestData);
                        }
                    })
                    .catch((error) => {
                        this.showToast('Error', this.resolveErrorMessage(error), 'error');
                        this.showSpinner = false;
                    });
            }
            this.showEnotifyModal = false;
        } else {
            this.showEnotifyModal = false;
        }
    }

    handleAction(data) {
        this.showSpinner = true;
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
                    result = result + '&type=' + data['type'];
                    if (data.hasOwnProperty('blId') && data['blId']) {
                        result = result + '&blId=' + data['blId'];
                    }
                    const lang = resolveOmniLanguageCode();
                    setLanguage({ languageLocaleKey: lang })
                        .catch(() => {
                            // Community users may be blocked from User language update
                        })
                        .finally(() => {
                            window.open(withOmniLanguage(result), '_self');
                        });
                }
            })
            .catch((error) => {
                this.showSpinner = false;
                this.showToast('Error', this.resolveErrorMessage(error), 'error');
            });
    }
    handleSelectedRegType(event) {
        this.selectedRegType = event.target.value;
        this.handleFetchData(this.licenseNameSearch);
    }
    handleFetchData(searchKey) {
        var temArr = [];
        var mainData = JSON.parse(
            JSON.stringify(
                this.allPageData.typeWithProfessionMap[this.selectedRegType] || []
            )
        );
        mainData.forEach(function (arrayItem) {
            let name = (arrayItem.name || '').toLowerCase();
            let originalName = (arrayItem.originalName || '').toLowerCase();
            let subStr = (searchKey || '').toLowerCase();
            if (name.includes(subStr) || originalName.includes(subStr)) {
                temArr.push(arrayItem);
            }
        });
        this.professionData = temArr;
        this.sortTheMainData(false);
        this.searchAriaLabelLicense = this.labels.professionSearchPlaceholder;
    }
    sortTheData(event) {
        if (this.selectedSorting == 'asc') {
            this.selectedSorting = 'desc';
        } else {
            this.selectedSorting = 'asc';
        }
        this.sortTheMainData(true);
    }
    sortTheMainData(changeAriaLable) {
        if (this.selectedSorting == 'asc') {
            this.professionData.sort((a, b) => {
                if (a.name < b.name) {
                    return -1;
                }
                if (a.name > b.name) {
                    return 1;
                }
                return 0;
            });
        } else {
            this.professionData.sort((a, b) => {
                if (a.name > b.name) {
                    return -1;
                }
                if (a.name < b.name) {
                    return 1;
                }
                return 0;
            });
        }
        if (changeAriaLable) {
            setTimeout(() => {
                if (this.selectedSorting == 'desc') {
                    this.sortingAriaLabel =
                        'Elements sorted in descending order';
                } else {
                    this.sortingAriaLabel =
                        'Elements sorted in ascending order';
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
        this.professionData = JSON.parse(
            JSON.stringify(
                this.allPageData.typeWithProfessionMap[this.selectedRegType] || []
            )
        );
        this.searchAriaLabelLicense = this.labels.professionSearchPlaceholder;
        setTimeout(() => {
            this.template.querySelector('.license-searchbox-input').focus();
        }, 500);
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
        this.handleFetchData(searchKey);
    }

    @track sectionClass1 =
        'slds-accordion__section custom-accordion slds-is-open';
    handleAccordianClick(event) {
        let name = event.currentTarget.dataset.name;
        let accordionStatus = this.template.querySelector(`[data-name="category"]`);
        if (name === 'category') {
            if (
                this.sectionClass1 ==
                'slds-accordion__section custom-accordion'
            ) {
                this.sectionClass1 =
                    'slds-accordion__section custom-accordion slds-is-open';
                accordionStatus.setAttribute('aria-expanded', true);
            } else {
                this.sectionClass1 =
                    'slds-accordion__section custom-accordion';
                accordionStatus.setAttribute('aria-expanded', false);
            }
        }
    }
}